local sirinQuest = {}

---@param pQuestMgr CQuestMgr
---@param pQuestFld _Quest_fld
---@return boolean
function sirinQuest.isPossibleTakeNPCQuest(pQuestMgr, pQuestFld)
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

function sirinQuest.onLoop()

end

---@param pPlayer CPlayer
---@param pStore? CItemStore
---@param dwNPCQuestIndex integer
function sirinQuest.CPlayer__pc_RequestQuestFromNPC(pPlayer, pStore, dwNPCQuestIndex)
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
function sirinQuest.CQuestMgr__CheckNPCQuestList(pQuestMgr, pszEventCode, byRaceCode, pQuestIndexData)
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
function sirinQuest.CQuestMgr__CheckNPCQuestStartable(pQuestMgr, pszEventCode, byRaceCode, dwQuestIndex, dwHappenIndex)
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
function sirinQuest.CPlayer___Reward_Quest(pPlayer, pQuestFld, byRewardItemIndex)
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

return sirinQuest