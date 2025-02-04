local sirinQuest = {}

---@param pQuestMgr CQuestMgr
---@param pQuestFld _Quest_fld
---@return boolean
function sirinQuest.isPossibleTakeNPCQuest(pQuestMgr, pQuestFld)
	local list = pQuestMgr.m_pQuestData:GetActiveQuestList()

	for _, v in ipairs(list) do
		repeat
			if v.byQuestType ~= 1 then
				break
			end

			if v.wIndex == pQuestFld.m_dwIndex then
				return false
			end

			if pQuestFld.m_nLinkQuestGroupID ~= 0 then
				local pFld = Sirin.mainThread.baseToQuest(Sirin.mainThread.CQuestMgr__s_tblQuest():GetRecord(v.wIndex))

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
			local EventNode = pEventFld:m_Node_get(byRaceCode);

			if EventNode.m_bUse == 0 then
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

		if EventNode.m_bUse == 0 then
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

return sirinQuest