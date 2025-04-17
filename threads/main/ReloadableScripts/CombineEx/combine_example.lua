local combineData = {
	m_strUUID = "example_unique_name",
}

function combineData.init()
	combineData.combineFormula = { { "iycsa13", 1 }, { "iyred01", 2 } }
	combineData.combineReward = { { "ircsa01", 1 }, { "ircsa02", 1 }, { "ircsa03", 1 }, { "ircsa04", 1 }, { "irtal01", 1 }, { "irtal06", 1 }, { "ipcsa01", 1 }, { "ipcsa04", 1 } }
	combineData.price = 0

	combineData.materials_fld = {}
	combineData.materials_num = {}
	combineData.reward_fld = {}
	combineData.reward_num = {}

	for k, v in ipairs(combineData.combineFormula) do
		local byTableCode = Sirin.mainThread.GetItemTableCode(v[1])

		if byTableCode == -1 then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Combine Ex. Invalid material item type: combineData.combineFormula[%d][1] = '%s'", k, v[1]))
			return
		end

		local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(byTableCode):GetRecordByHash(v[1], 2, 5)

		if not pFld then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Combine Ex. Invalid material item code: combineData.combineFormula[%d][1] = '%s'", k, v[1]))
			return
		end

		table.insert(combineData.materials_fld, { byTableCode, pFld.m_dwIndex } )
		table.insert(combineData.materials_num, v[2])
	end

	for k, v in ipairs(combineData.combineReward) do
		local byTableCode = Sirin.mainThread.GetItemTableCode(v[1])

		if byTableCode == -1 then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Combine Ex. Invalid reward item type: combineData.combineReward[%d][1] = '%s'", k, v[1]))
			return
		end

		local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(byTableCode):GetRecordByHash(v[1], 2, 5)

		if not pFld then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Combine Ex. Invalid reward item code: combineData.combineReward[%d][1] = '%s'", k, v[1]))
			return
		end

		table.insert(combineData.reward_fld, { byTableCode, pFld.m_dwIndex } )
		table.insert(combineData.reward_num, v[2])
	end
end

---@param ppConMats table<integer, _STORAGE_LIST___db_con>
---@return boolean
function combineData.combineChecker(ppConMats)
	repeat
		if #ppConMats ~= 2 then
			break
		end

		local srcNum = { 0, 0 }
		local bInvalidCombine = false

		for _,v in ipairs(ppConMats) do
			if v.m_byTableCode ~= TBL_CODE.booty then
				bInvalidCombine = true
				break
			end

			if v.m_wItemIndex == combineData.materials_fld[1][2] then
				srcNum[1] = srcNum[1] + 1
			elseif v.m_wItemIndex == combineData.materials_fld[2][2] then
				srcNum[2] = srcNum[2] + 1
			else
				break
			end
		end

		for _,v in ipairs(srcNum) do
			if v ~= 1 then
				bInvalidCombine = true
				break
			end
		end

		if bInvalidCombine then
			break
		end

		return true

	until true

	return false
end

---@param pPlayer CPlayer
---@param ppConMats table<integer, _STORAGE_LIST___db_con>
---@param pipMats table<integer, _combine_ex_item_request_clzo___list>
---@param pSend _combine_ex_item_result_zocl
---@param pRecv _combine_ex_item_request_clzo
---@return boolean
function combineData.combineWorker(pPlayer, ppConMats, pipMats, pSend, pRecv)
	local matIndexTable = { 0, 0 }
	local removeMatNum = clone(combineData.materials_num)

	for k,v in ipairs(ppConMats) do
		if v.m_byTableCode == combineData.materials_fld[1][1] and v.m_wItemIndex == combineData.materials_fld[1][2] then
			matIndexTable[1] = k
		elseif v.m_byTableCode == combineData.materials_fld[2][1] and v.m_wItemIndex == combineData.materials_fld[2][2] then
			matIndexTable[2] = k
		end
	end

	for k,v in ipairs(combineData.materials_fld) do
		if IsOverlapItem(v[1]) and combineData.materials_num[k] ~= pipMats[matIndexTable[k]].byAmount then
			return false
		end
	end

	if not CombineExMgr.pricePopUp(pPlayer, combineData, pRecv) then
		return true
	end

	if combineData.price and combineData.price > 0 and combineData.price > pPlayer.m_Param:GetDalant() then
		return false
	end

	pSend.dwDalant = combineData.price -- not used by client

	if math.random(0, 99) < 50 then
		-- combine success
		pSend.dwCheckKey = (Sirin.mainThread.GetLoopTime() & 0xFFFFFF) >> 8 -- combination check key. do not change. must present.
		pSend.byDlgType = 1 -- 255 error, 0 success selectable, 1 success non selectable, 2 combination failure
		pSend.bySelectItemCount = 0 -- 0 if non selectable combination, or how many items allowed to choice
		pSend.dwResultEffectType = 1 -- not used by client
		pSend.ItemBuff.byItemListNum = #combineData.combineReward -- how many result items
		pSend.dwResultEffectMsgCode = 3605 -- text ID

		for i = 1, pSend.ItemBuff.byItemListNum do
			local RewardItem = pSend.ItemBuff:RewardItemList_get(i - 1)
			RewardItem.Key.byTableCode = combineData.reward_fld[i][1]
			RewardItem.Key.wItemIndex = combineData.reward_fld[i][2]
			RewardItem.Key.byRewardIndex = i - 1 -- not used by client
			RewardItem.dwDur = combineData.reward_num[i]
			RewardItem.dwUpt = 0xFFFFFFFF
		end

		local bySaveErr = pPlayer.m_ItemCombineMgr:UpdateDB_CombineResult(pSend)

		if bySaveErr ~= 0 then
			pSend.byErrCode = bySaveErr
			pSend.byDlgType = 255
		end

		local szBufr = string.format("\r\nCOMBINE_EX[CONSUME]\r\n\tCombine: demo,  num:%d, (D:%d) [%s] : Succ", #combineData.materials_fld, combineData.price, os.date(_, os.time()))
		Sirin.WriteA(pPlayer.m_szItemHistoryFileName, szBufr, false, false)
	else
		-- combine failed
		pSend.byDlgType = 2 -- 255 error, 0 success selectable, 1 success non selectable, 2 combination failure
		pSend.bySelectItemCount = 0
		pSend.ItemBuff.byItemListNum = 0 -- do not change value at this line

		-- decide which items need to be saved. #use_your_brain_here to create your own logic
		removeMatNum[1] = 0 -- we will save iycsa13 material by setting remove value = 0
		--

		for k,v in ipairs(matIndexTable) do
			if removeMatNum[k] ~= 0 then
				local RewardItem = pSend.ItemBuff:RewardItemList_get(pSend.ItemBuff.byItemListNum)
				RewardItem.Key.byTableCode = ppConMats[v].m_byTableCode
				RewardItem.Key.wItemIndex = ppConMats[v].m_wItemIndex
				RewardItem.Key.byRewardIndex = 0 -- not used by client
				RewardItem.dwDur = pipMats[v].byAmount
				RewardItem.dwUpt = ppConMats[v].m_dwLv
				pSend.ItemBuff.byItemListNum = pSend.ItemBuff.byItemListNum + 1
			end
		end

		local szBufr = string.format("\r\nCOMBINE_EX[CONSUME]\r\n\tCombine: demo,  num:%d, (D:%d) [%s] : Fail( %u )", pSend.ItemBuff.byItemListNum, combineData.price, os.date(_, os.time()), pSend.ItemBuff.byItemListNum)
		Sirin.WriteA(pPlayer.m_szItemHistoryFileName, szBufr, false, false)
	end

	for k,v in ipairs(matIndexTable) do
		if removeMatNum[k] ~= 0 then
			pPlayer:Emb_AlterDurPoint(STORAGE_POS.inven, ppConMats[v].m_byStorageIndex, -combineData.materials_num[k], true, true)
			local szBufr = string.format("\t - %s_%u [%u] [%d] Delete", combineData.combineFormula[k][1], ppConMats[v].m_dwDur, combineData.materials_num[k], ppConMats[v].m_lnUID)
			Sirin.WriteA(pPlayer.m_szItemHistoryFileName, szBufr, false, false)
		else
			local szBufr = string.format("\t - %s_%u [%u] [%d]", combineData.combineFormula[k][1], ppConMats[v].m_dwDur, combineData.materials_num[k], ppConMats[v].m_lnUID)
			Sirin.WriteA(pPlayer.m_szItemHistoryFileName, szBufr, false, false)
		end
	end

	if combineData.price > 0 then
		pPlayer:AlterDalant(-combineData.price)
		pPlayer:SendMsg_AlterMoneyInform(0)
	end

	return true
end

return { [combineData.m_strUUID] = combineData }
