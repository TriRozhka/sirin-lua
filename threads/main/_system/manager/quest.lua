local sirinQuestMgr = {}

---@param pQuestMgr CQuestMgr
---@param pQuestFld _Quest_fld
---@return boolean
function sirinQuestMgr.isPossibleTakeNPCQuest(pQuestMgr, pQuestFld)
	local list = pQuestMgr.m_pQuestData:GetActiveQuestList(1)

	for _, v in ipairs(list) do
		repeat
			if v[2].wIndex == pQuestFld.m_dwIndex then
				return false
			end

			if pQuestFld.m_nLinkQuestGroupID ~= 0 then
				local pFld = Sirin.mainThread.baseToQuest(Sirin.mainThread.CQuestMgr__s_tblQuest():GetRecord(v[2].wIndex))

				if pFld.m_nLinkQuestGroupID == pQuestFld.m_nLinkQuestGroupID then
					return false
				end
			end

		until true
	end

	local tmCurTime = os.time()
	local tmDailyReset = Sirin.mainThread.modQuestHistory.s_tmLastDailyResetTime
	local tmWeeklyReset = Sirin.mainThread.modQuestHistory.s_tmLastWeeklyResetTime
	local tmMonthlyReset = Sirin.mainThread.modQuestHistory.s_tmLastMonthlyResetTime
	local bPossible = true
	local list = pQuestMgr.m_pQuestData:GetStartHistoryList()

	for _,v in ipairs(list) do
		if v.pQuestFld.m_bQuestRepeat ~= 0 then
			if pQuestFld.m_nLinkQuestGroupID ~= 0 and pQuestFld.m_nLinkQuestGroupID == v.pQuestFld.m_nLinkQuestGroupID or pQuestFld.m_dwIndex == v.pQuestFld.m_dwIndex then
				local nResetDelay = math.floor(pQuestFld.m_dRepeatTime)

				if nResetDelay == 24 * 60 * 60 then
					bPossible = bPossible and (v.nEndTime < tmDailyReset)
				elseif nResetDelay == 7 * 24 * 60 * 60 then
					bPossible = bPossible and (v.nEndTime < tmWeeklyReset)
				elseif nResetDelay == 30 * 24 * 60 * 60 then
					bPossible = bPossible and (v.nEndTime < tmMonthlyReset)
				else
					bPossible = bPossible and (v.nEndTime + nResetDelay < tmCurTime)
				end
			end

			if not bPossible then
				break
			end
		elseif pQuestFld.m_dwIndex == v.pQuestFld.m_dwIndex then
			bPossible = false
			break
		end
	end

	return bPossible
end

function sirinQuestMgr.onLoop()

end

---@param pPlayer CPlayer
---@param pStore? CItemStore
---@param dwNPCQuestIndex integer
function sirinQuestMgr.CPlayer__pc_RequestQuestFromNPC(pPlayer, pStore, dwNPCQuestIndex)
	local bResult = false

	if pPlayer.m_bySubDgr ~= 0 then
		bResult = true
	elseif pStore then
		repeat
			if GetSqrt(pPlayer.m_fCurPos_x, pPlayer.m_fCurPos_z, pStore.m_pDum.m_pDumPos:m_fCenterPos_get(0), pStore.m_pDum.m_pDumPos:m_fCenterPos_get(2)) > 80 then
				break
			end

			if pStore.m_byNpcRaceCode ~= 255 and pStore.m_byNpcRaceCode ~= pPlayer:GetObjRace() then
				break
			end

			if not pStore.m_pRec then
				break
			end

			bResult = true
		until true
	end

	if bResult then
		local ret = pPlayer:Emb_CreateNPCQuest(pStore and pStore.m_pRec.m_strStore_NPCcode or nil, dwNPCQuestIndex)
		local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
		buf:Init()
		buf:PushUInt8(ret and 1 or 0)
		buf:SendBuffer(pPlayer, 24, 18)
	end
end

---@param pQuestMgr CQuestMgr
---@param pszEventCode string
---@param byRaceCode integer
---@param pQuestIndexData _NPCQuestIndexTempData
function sirinQuestMgr.CQuestMgr__CheckNPCQuestList(pQuestMgr, pszEventCode, byRaceCode, pQuestIndexData)
	local pEventFld = Sirin.mainThread.baseToQuestEvent(Sirin.mainThread.CQuestMgr__s_tblQuestHappenEvent_get(QUEST_HAPPEN.quest_happen_type_npc):GetRecord(pszEventCode))

	if  not pEventFld then
		return
	end

	local i, j = pEventFld.m_dwIndex, 0

	while j < 30 do
		pEventFld = Sirin.mainThread.baseToQuestEvent(Sirin.mainThread.CQuestMgr__s_tblQuestHappenEvent_get(QUEST_HAPPEN.quest_happen_type_npc):GetRecord(i))

		if not pEventFld or pszEventCode ~= pEventFld.m_strCode then
			break
		end

		repeat
			local EventNode = pEventFld:m_Node_get(byRaceCode)

			if EventNode.m_nUse == 0 then
				break
			end

			local pQuestFld = Sirin.mainThread.baseToQuest(Sirin.mainThread.CQuestMgr__s_tblQuest():GetRecord(EventNode:m_strLinkQuest_get(0)))

			if  not pQuestFld or pQuestFld.m_nLimLv ~= -1 and pQuestFld.m_nLimLv < pQuestMgr.m_pMaster.m_Param.m_dbChar.m_byLevel then
				break
			end

			local bConditionPass = true
			local k = 0

			while k < 5 and EventNode:m_CondNode_get(k).m_nCondType ~= -1 do
				if not pQuestMgr:_CheckCondition(EventNode:m_CondNode_get(k)) then
					bConditionPass = false
					break
				end

				k = k + 1
			end

			if not bConditionPass then
				break
			end

			if not Sirin.mainThread.modQuestHistory.isPossibleTakeNPCQuest(pQuestMgr, pQuestFld) then
				break
			end

			local data = pQuestIndexData:IndexData_get(j)
			data.dwQuestIndex = pQuestFld.m_dwIndex
			data.dwQuestHappenIndex = i
			j = j + 1
			pQuestIndexData.nQuestNum = j

		until true

		i = i + 1
	end
end

---This function called insinde Emb_CreateNPCQuest and accepts NPC code as pszEventCode which can be nil
---@param pQuestMgr CQuestMgr
---@param pszEventCode? string
---@param byRaceCode integer
---@param dwQuestIndex integer
---@param dwHappenIndex integer
---@return boolean
function sirinQuestMgr.CQuestMgr__CheckNPCQuestStartable(pQuestMgr, pszEventCode, byRaceCode, dwQuestIndex, dwHappenIndex)
	local bRet = false

	repeat
		local pQuestEventFld = Sirin.mainThread.baseToQuestEvent(Sirin.mainThread.CQuestMgr__s_tblQuestHappenEvent_get(QUEST_HAPPEN.quest_happen_type_npc):GetRecord(dwHappenIndex))

		if not pQuestEventFld then
			break
		end

		local pQuestFld = Sirin.mainThread.baseToQuest(Sirin.mainThread.CQuestMgr__s_tblQuest():GetRecord(dwQuestIndex))

		if not pQuestFld then
			break
		end

		if pQuestMgr.m_pMaster.m_byUserDgr == 0 then
			if not pszEventCode then
				break
			end

			if pszEventCode ~= pQuestEventFld.m_strCode then
				break
			end
		end

		local EventNode = pQuestEventFld:m_Node_get(byRaceCode)

		if EventNode.m_nUse == 0 then
			break
		end

		local pQuestFldFromEvent = Sirin.mainThread.baseToQuest(Sirin.mainThread.CQuestMgr__s_tblQuest():GetRecord(EventNode:m_strLinkQuest_get(0)))

		if not pQuestEventFld or pQuestFld.m_dwIndex ~= pQuestFldFromEvent.m_dwIndex then
			break
		end

		if pQuestFld.m_nLimLv ~= -1 and pQuestFld.m_nLimLv < pQuestMgr.m_pMaster.m_Param.m_dbChar.m_byLevel then
			break
		end

		local bConditionPass = true
		local k = 0

		while k < 5 and EventNode:m_CondNode_get(k).m_nCondType ~= -1 do
			if not pQuestMgr:_CheckCondition(EventNode:m_CondNode_get(k)) then
				bConditionPass = false
				break
			end

			k = k + 1
		end

		if not bConditionPass then
			break
		end

		if not Sirin.mainThread.modQuestHistory.isPossibleTakeNPCQuest(pQuestMgr, pQuestFld) then
			break
		end

		pQuestMgr.m_LastHappenEvent.m_pEvent = EventNode
		pQuestMgr.m_LastHappenEvent.m_QtHpType = QUEST_HAPPEN.quest_happen_type_npc
		pQuestMgr.m_LastHappenEvent.m_nIndexInType = pQuestEventFld.m_dwIndex
		pQuestMgr.m_LastHappenEvent.m_nRaceCode = byRaceCode
		bRet = true

	until true

	return bRet
end

---@param pPlayer CPlayer
---@param pQuestFld _Quest_fld
---@param byRewardItemIndex integer
---@return _base_fld?
function sirinQuestMgr.CPlayer___Reward_Quest(pPlayer, pQuestFld, byRewardItemIndex)
	local pNextQuest = nil
	--local dPenaltyRate = Sirin.mainThread.g_Main.m_pTimeLimitMgr:GetPlayerPenalty(pPlayer.m_id.wIndex)
	local dPenaltyRate = 1.0

	if pQuestFld.m_nMaxLevel ~= -1 then
		pPlayer:AlterMaxLevel(pQuestFld.m_nMaxLevel)
	end

	if pQuestFld.m_dConsExp > 0.0 then
		pPlayer:AlterExp(pQuestFld.m_dConsExp, true, false, true)
	end

	if pQuestFld.m_nConsContribution > 0 then
		pPlayer:AlterPvPPoint(pQuestFld.m_nConsContribution, PVP_ALTER_TYPE.quest_inc, 0xFFFFFFFF)
	end

	if pQuestFld.m_nConspvppoint > 0 then
		pPlayer:AlterPvPCashBag(pQuestFld.m_nConspvppoint * dPenaltyRate, PVP_MONEY_ALTER_TYPE.pm_quest)
	end

	if pQuestFld.m_nConsDalant > 0 or pQuestFld.m_nConsGold > 0 then
		pPlayer:AlterDalant(pQuestFld.m_nConsDalant)
		pPlayer:AlterGold(pQuestFld.m_nConsGold)
		pPlayer:SendMsg_AlterMoneyInform(0)
		local dwAddDalant = math.floor(pQuestFld.m_nConsDalant * dPenaltyRate)
		local dwAddGold = math.floor(pQuestFld.m_nConsGold * dPenaltyRate)
		Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("REWARD: %s /MONEY rev(D:%d G:%d) $D:%d $G:%d [%s]\n", "Quest", dwAddDalant, dwAddGold, pPlayer.m_Param:GetDalant(), pPlayer.m_Param:GetGold(), os.date(_, os.time())), false, false)
	end

	for j = 0, 5 do
		--if Sirin.mainThread.g_Main.m_pTimeLimitMgr:GetPlayerStatus(pPlayer.m_id.wIndex) == 99 then
		--	break
		--end

		local pQstReward = pQuestFld:m_RewardItem_get(j)

		repeat
			if byRewardItemIndex ~= 255 then
				if j ~= byRewardItemIndex then
					break
				end

				if pQstReward.m_nLinkQuestIdx ~= -1 then
					pNextQuest = Sirin.mainThread.CQuestMgr__s_tblQuest():GetRecord(pQuestFld:m_strLinkQuest_get(pQstReward.m_nLinkQuestIdx))
				end
			end

			if pQstReward.m_strConsITCode == "-1" then
				break
			end

			local nTableCode = Sirin.mainThread.GetItemTableCode(pQstReward.m_strConsITCode)

			if nTableCode == -1 then
				break
			end

			local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(nTableCode):GetRecordByHash(pQstReward.m_strConsITCode, 2, 5)

			if not pFld then
				break
			end

			local pItem = Sirin.mainThread.makeLoot(nTableCode, pFld.m_dwIndex)

			if Sirin.mainThread.IsOverLapItem(nTableCode) then
				pItem.m_dwDur = pQstReward.m_nConsITCnt
			end

			if pPlayer.m_Param.m_dbInven:GetIndexEmptyCon() == 255 then
				Sirin.mainThread.createItemBoxForAutoLoot(pItem, pPlayer, 0xFFFFFFFF, false, nil, 3, pPlayer.m_pCurMap, pPlayer.m_wMapLayerIndex, { pPlayer.m_fCurPos_x, pPlayer.m_fCurPos_y, pPlayer.m_fCurPos_z }, false)

				if pItem.m_byCsMethod ~= 0 then
					Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("REWARD: Quest G (%s) /ITEM %s_%d_@%X[%d] [%s]==[LendTime:%d][EndTime:%d][TimeKind:%d]\n", pFld.m_strCode, pFld.m_strCode, pItem.m_dwDur, pItem.m_dwLv, pItem.m_lnUID, os.date(_, os.time()), pItem.m_dwLendRegdTime, pItem.m_dwT, pItem.m_byCsMethod), false, false)
				else
					Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("REWARD: Quest G (%s) /ITEM %s_%d_@%X[%d] [%s]\n", pFld.m_strCode, pFld.m_strCode, pItem.m_dwDur, pItem.m_dwLv, pItem.m_lnUID, os.date(_, os.time())), false, false)
				end
			else
				 pItem.m_wSerial = pPlayer.m_Param:GetNewItemSerial()
				 local pNewCon = pPlayer:Emb_AddStorage(STORAGE_POS.inven, pItem, false, true)

				 if not pNewCon then
					Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("Emb_AddStorage ERR - item:[%d-%d], CodePos:(sirinQuest.CPlayer___Reward_Quest() - Emb_AddStorage() Fail)\n", pItem.m_byTableCode, pItem.m_wItemIndex), false, false)
					break
				 end

				 pPlayer:SendMsg_RewardAddItem(pItem, 2)

				 if pItem.m_byCsMethod ~= 0 then
					Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("REWARD: Quest (%s) /ITEM %s_%d_@%X[%d] [%s]==[LendTime:%d][EndTime:%d][TimeKind:%d]\n", pFld.m_strCode, pFld.m_strCode, pItem.m_dwDur, pItem.m_dwLv, pItem.m_lnUID, os.date(_, os.time()), pItem.m_dwLendRegdTime, pItem.m_dwT, pItem.m_byCsMethod), false, false)
				else
					Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("REWARD: Quest (%s) /ITEM %s_%d_@%X[%d] [%s]\n", pFld.m_strCode, pFld.m_strCode, pItem.m_dwDur, pItem.m_dwLv, pItem.m_lnUID, os.date(_, os.time())), false, false)
				end
			end

			pPlayer:SendMsg_FanfareItem(5, pItem, nil)

		until true

		if byRewardItemIndex == 255 and pQstReward.m_strConsITCode == "-1" then
			break
		end
	end

	for j = 0, 1 do
		local rewardMastery = pQuestFld:m_RewardMastery_get(j)

		if rewardMastery.m_nConsMasteryID == -1 then
			break
		end

		pPlayer:Emb_AlterStat(rewardMastery.m_nConsMasteryID, rewardMastery.m_nConsMasterySubID, rewardMastery.m_nConsMasteryCnt, 2, "CPlayer::_Reward_Quest()---0", true)
	end

	if pQuestFld.m_strConsSkillCode ~= "-1" then
		local pSkillFld = Sirin.mainThread.g_Main:m_tblEffectData_get(EFF_CODE.skill):GetRecord(pQuestFld.m_strConsSkillCode)

		if pSkillFld then
			pPlayer:Emb_AlterStat(3, pSkillFld.m_dwIndex, pQuestFld.m_nConsSkillCnt, 2, "CPlayer::_Reward_Quest()---1", true)
		end
	end

	if pQuestFld.m_strConsForceCode ~= "-1" then
		local pForceFld = Sirin.mainThread.g_Main:m_tblEffectData_get(EFF_CODE.force):GetRecord(pQuestFld.m_strConsForceCode)

		if pForceFld then
			local forceList = pPlayer.m_Param.m_dbForce:GetUseList()

			for _,f in pairs(forceList) do
				if f.m_wItemIndex == pForceFld.m_dwIndex then
					pPlayer:Emb_AlterDurPoint(3, f.m_byStorageIndex, pQuestFld.m_nConsForceCnt, false, false)
					break
				end
			end
		end
	end

	return pNextQuest
end

---@param pQuestMgr CQuestMgr
---@param nReqAct integer
---@param pszReqCode string
---@return boolean
function sirinQuestMgr.CQuestMgr____CheckCond_Have(pQuestMgr, nReqAct, pszReqCode)
	local byTableCode = Sirin.mainThread.GetItemTableCode(pszReqCode)

	if byTableCode == -1 then
		return false
	end

	local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(byTableCode):GetRecordByHash(pszReqCode, 2, 5)

	if not pFld then
		return false
	end

	local numFound = 0

	for i = 0, pQuestMgr.m_pMaster.m_Param.m_dbChar.m_byUseBagNum * 20 - 1 do
		local pCon = pQuestMgr.m_pMaster.m_Param.m_dbInven:m_pStorageList_get(i)

		if pCon.m_byLoad ~= 0 and pCon.m_byTableCode == byTableCode and pCon.m_wItemIndex == pFld.m_dwIndex then
			if IsOverlapItem(pCon.m_byTableCode) then
				numFound = numFound + pCon.m_dwDur
			else
				numFound = numFound + 1
			end

			if numFound >= nReqAct then
				return true
			end
		end
	end

	return false
end

---@type table<integer, fun(pQuestMgr: CQuestMgr, pCond: _happen_event_condition_node): boolean>
local condHandlers = {
	[1] = function(pQuestMgr, pCond) -- Lv
		local lv = pQuestMgr.m_pMaster:GetLevel()

		if pCond.m_nCondSubType == 0 and lv == tonumber(pCond.m_sCondVal) then
			return true
		elseif pCond.m_nCondSubType == 1 and lv < tonumber(pCond.m_sCondVal)then
			return true
		elseif pCond.m_nCondSubType == 2 and lv > tonumber(pCond.m_sCondVal)then
			return true
		end

		return false
	end,
	[2] = function(pQuestMgr, pCond) -- Grade
		local grade = pQuestMgr.m_pMaster.m_Param.m_byPvPGrade

		if pCond.m_nCondSubType == 0 and grade == tonumber(pCond.m_sCondVal) then
			return true
		elseif pCond.m_nCondSubType == 1 and grade < tonumber(pCond.m_sCondVal)then
			return true
		elseif pCond.m_nCondSubType == 2 and grade > tonumber(pCond.m_sCondVal)then
			return true
		end

		return false
	end,
	[3] = function(pQuestMgr, pCond) -- Dalant
		local money = pQuestMgr.m_pMaster.m_Param:GetDalant()

		if pCond.m_nCondSubType == 0 and money == tonumber(pCond.m_sCondVal) then
			return true
		elseif pCond.m_nCondSubType == 1 and money < tonumber(pCond.m_sCondVal)then
			return true
		elseif pCond.m_nCondSubType == 2 and money > tonumber(pCond.m_sCondVal)then
			return true
		end

		return false
	end,
	[4] = function(pQuestMgr, pCond) -- Gold
		local money = pQuestMgr.m_pMaster.m_Param:GetGold()

		if pCond.m_nCondSubType == 0 and money == tonumber(pCond.m_sCondVal) then
			return true
		elseif pCond.m_nCondSubType == 1 and money < tonumber(pCond.m_sCondVal)then
			return true
		elseif pCond.m_nCondSubType == 2 and money > tonumber(pCond.m_sCondVal)then
			return true
		end

		return false
	end,
	[5] = function(pQuestMgr, pCond) -- Party
		if pCond.m_nCondSubType ~= 0 then
			return not (pQuestMgr.m_pMaster.m_pPartyMgr.m_pPartyBoss and true or false)
		else
			return pQuestMgr.m_pMaster.m_pPartyMgr.m_pPartyBoss and true or false
		end
	end,
	[6] = function(pQuestMgr, pCond) -- Guild
		if pCond.m_nCondSubType ~= 0 then
			return not (pQuestMgr.m_pMaster.m_Param.m_pGuild and true or false)
		else
			return pQuestMgr.m_pMaster.m_Param.m_pGuild and true or false
		end
	end,
	[7] = function(pQuestMgr, pCond) -- Nation
		return false
	end,
	[8] = function(pQuestMgr, pCond) -- Equip
		local byTableCode = Sirin.mainThread.GetItemTableCode(pCond.m_sCondVal)

		if byTableCode == -1 then
			return false
		end

		local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(byTableCode):GetRecordByHash(pCond.m_sCondVal, 2, 5)

		if not pFld then
			return false
		end

		local pCon = pQuestMgr.m_pMaster.m_Param.m_dbEquip:m_pStorageList_get(byTableCode)

		if pCon.m_byLoad ~= 0 and pCon.m_wItemIndex == pFld.m_dwIndex then
			return true
		end

		return false
	end,
	[9] = function(pQuestMgr, pCond) -- Have item in inven
		return sirinQuestMgr.CQuestMgr____CheckCond_Have(pQuestMgr, pCond.m_nCondSubType, pCond.m_sCondVal)
	end,
	[10] = function(pQuestMgr, pCond) -- Mastery
		local type, sub_type, value = pCond.m_sCondVal:match("(%d)(%d%d)(%d%d)")
		type, sub_type, value = math.floor(tonumber(type) or 0), math.floor(tonumber(sub_type) or 0), math.floor(tonumber(value) or 0)

		if not IsValidMasteryCode(type, sub_type) then
			return false
		end

		return pQuestMgr.m_pMaster.m_pmMst:GetMasteryPerMast(type, sub_type) >= value
	end,
	[11] = function(pQuestMgr, pCond) -- Dummy
		return false
	end,
	[12] = function(pQuestMgr, pCond) -- Race
		local byRaceSex = pQuestMgr.m_pMaster.m_Param.m_dbChar.m_byRaceSexCode + 1

		return pCond.m_sCondVal:sub(byRaceSex, byRaceSex) == '1'
	end,
	[13] = function(pQuestMgr, pCond)
		for i = 0, 3 do
			local class = pQuestMgr.m_pMaster.m_Param:m_ppHistoryEffect_get(i)

			if not class then
				break
			end

			if class.m_strCode == pCond.m_sCondVal then
				return true
			end
		end

		return false
	end,
}

---@param pQuestMgr CQuestMgr
---@param pCond _happen_event_condition_node
---@return boolean
function sirinQuestMgr.CQuestMgr___CheckCondition(pQuestMgr, pCond)
	if condHandlers[pCond.m_nCondType + 1] then
		return condHandlers[pCond.m_nCondType + 1](pQuestMgr, pCond)
	end

	return false
end

---@param pQuestMgr CQuestMgr
---@param nActCode integer
---@param pszReqCode integer
---@param wActCount integer
---@param bPartyState boolean
---@return _quest_check_result?
function sirinQuestMgr.CQuestMgr__CheckReqAct(pQuestMgr, nActCode, pszReqCode, wActCount, bPartyState)
	local s_QuestCKRet = Sirin.mainThread.s_QuestCKRet
	s_QuestCKRet.m_byCheckNum = 0

	local quests = pQuestMgr.m_pQuestData:GetActiveQuestList()

	for _,q in ipairs(quests) do
		repeat
			local pFld = Sirin.mainThread.CQuestMgr__s_tblQuest():GetRecord(q[2].wIndex)

			if not pFld then
				break
			end

			pFld = Sirin.mainThread.baseToQuest(pFld)

			if pFld.m_nQuestType == 0 and bPartyState then
				break
			end

			for i = 0, 2 do
				repeat
					if q[2]:wNum_get(i) == 0xFFFF then
						break
					end

					local actionNode = pFld:m_ActionNode_get(i)

					if actionNode.m_nActType == -1 then
						break
					end

					if actionNode.m_nActType ~= nActCode then
						break
					end

					if nActCode == 6 then
						if tonumber(pszReqCode) < tonumber(actionNode.m_strActSub) then
							break
						end
					elseif nActCode == 14 then
						if pszReqCode ~= actionNode.m_strActSub or not sirinQuestMgr.CQuestMgr____CheckCond_Have(pQuestMgr, actionNode.m_nReqAct, actionNode.m_strActSub2) then
							break
						end

						wActCount = actionNode.m_nReqAct
					elseif actionNode.m_strActSub ~= pszReqCode then
						break
					end

					if actionNode.m_strActArea ~= '-1' and not Sirin.mainThread.g_MapOper:IsInRegion(actionNode.m_strActArea, pQuestMgr.m_pMaster) then
						break
					end

					local orederPass = true

					if actionNode.m_nOrder > 0 then
						for j = 0, 2 do
							if pFld:m_ActionNode_get(j).m_nOrder < actionNode.m_nOrder and q[2]:wNum_get(j) ~= 0xFFFF then
								orederPass = false
								break
							end
						end
					end

					if not orederPass then
						break
					end

					if math.random(0, 99) >= actionNode.m_nSetCntPro_100 then
						break
					end

					local questResult = s_QuestCKRet:m_List_get(s_QuestCKRet.m_byCheckNum)
					s_QuestCKRet.m_byCheckNum = s_QuestCKRet.m_byCheckNum + 1

					questResult.byQuestDBSlot = q[1]
					questResult.byActIndex = i
					questResult.wCount = q[2]:wNum_get(i) + wActCount
					questResult.bORComplete = false

					if wActCount + q[2]:wNum_get(i) >= actionNode.m_nReqAct then
						questResult.wCount = 0xFFFF

						if nActCode == 14 and not pQuestMgr:DeleteQuestItem(actionNode.m_strActSub2, actionNode.m_nReqAct) then
							Sirin.mainThread.g_Main.m_logSystemError:Write(string.format("Lua. sirinQuestMgr.CQuestMgr__CheckReqAct : DeleteQuestItem(%s, %d) : Player: %d(%d)",
								actionNode.m_strActSub2,
								actionNode.m_nReqAct,
								pQuestMgr.m_pMaster.m_dwObjSerial,
								pQuestMgr.m_pMaster.m_pUserDB.m_dwAccountSerial
							))
						end

						if pFld.m_bCompQuestType ~= 0 then
							questResult.bORComplete = true
						end
					end

				until true
			end

		until true
	end

	if s_QuestCKRet.m_byCheckNum > 0 then
		return Sirin.mainThread.cloneQuestResult()
	end
end

return sirinQuestMgr
