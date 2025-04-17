local combineData = {}

function combineData.init()

end

---@param ppConMats table<integer, _STORAGE_LIST___db_con>
---@return boolean
function combineData.combineChecker(ppConMats)
	repeat
		if #ppConMats > 2 then
			break
		end

		local srcNum = { 0, 0, 0, 0, 0, 0, 0, 0 }
		local bHaveRecipe = false

		for _,v in ipairs(ppConMats) do
			if v.m_byTableCode < 8 then
				srcNum[v.m_byTableCode + 1] = srcNum[v.m_byTableCode + 1] + 1
			end

			if v.m_byTableCode == 20 and v.m_wItemIndex == 103 then
				bHaveRecipe = true
			end
		end

		if not bHaveRecipe then
			break
		end

		for _,v in ipairs(srcNum) do
			if v == 1 then
				return true
			end
		end

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
	---@type _STORAGE_LIST___db_con
	local pDstItem = nil
	---@type _STORAGE_LIST___db_con
	local pMaterial = nil
	local nMatSub = 0

	for k,v in ipairs(ppConMats) do
		if v.m_byTableCode == 20 then
			nMatSub = -pipMats[k].byAmount

			if v.m_dwDur < pipMats[k].byAmount or pipMats[k].byAmount ~= 1 then
				return false
			else
				pMaterial = v
			end
		else
			pDstItem = v
		end
	end

	local maxSlot = Sirin.mainThread.GetDefItemUpgSocketNum(pDstItem.m_byTableCode, pDstItem.m_wItemIndex)
	local curSlot = Sirin.mainThread.GetItemUpgLimSocket(pDstItem.m_dwLv)

	if curSlot >= maxSlot then
		return false
	end

	if not CombineExMgr.pricePopUp(pPlayer, combineData, pRecv) then
		return true
	end

	if combineData.price and combineData.price > 0 and combineData.price > pPlayer.m_Param:GetDalant() then
		return false
	end

	local oldUpg = pDstItem.m_dwLv % 0x10000000
	local newUpg = (curSlot + 1) * 0x10000000 + oldUpg

	pSend.byDlgType = 1
	pSend.bySelectItemCount = 0
	pSend.dwDalant = 0
	pSend.dwResultEffectType = 1
	pSend.dwResultEffectMsgCode = 3605
	pSend.ItemBuff.byItemListNum = 1

	local pNewCon = Sirin.mainThread._STORAGE_LIST___storage_con()
	pNewCon.m_byTableCode = pDstItem.m_byTableCode
	pNewCon.m_wItemIndex = pDstItem.m_wItemIndex
	pNewCon.m_dwDur = pDstItem.m_dwDur
	pNewCon.m_dwLv = newUpg
	pNewCon.m_wSerial = pPlayer.m_Param:GetNewItemSerial()
	pNewCon.m_lnUID = pDstItem.m_lnUID
	pNewCon.m_byCsMethod = pDstItem.m_byCsMethod
	pNewCon.m_dwT = pDstItem.m_dwT
	pNewCon.m_dwLendRegdTime = pDstItem.m_dwLendRegdTime

	local RewardItem = pSend.ItemBuff:RewardItemList_get(0)
	RewardItem.Key.byTableCode = pNewCon.m_byTableCode
	RewardItem.Key.wItemIndex = pNewCon.m_wItemIndex
	RewardItem.Key.byRewardIndex = 0
	RewardItem.dwDur = pDstItem.m_dwDur % 0x100000000
	RewardItem.dwUpt = pNewCon.m_dwLv

	if pPlayer.m_Param.m_dbInven:GetIndexEmptyCon() == 255 then
		local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(pNewCon.m_byTableCode):GetRecord(pNewCon.m_wItemIndex)

		if pNewCon.m_byCsMethod == 1 then
			pNewCon.m_dwT = pNewCon.m_dwT - os.time()
			pNewCon.m_dwT = pNewCon.m_dwT <= 0 and 1 or pNewCon.m_dwT
		end

		Sirin.mainThread.modChargeItem.pushChargeItem(pPlayer, pFld.m_strCode, pNewCon.m_dwDur, pNewCon.m_dwLv, pNewCon.m_dwT)
	else
		local pCon = pPlayer:Emb_AddStorage(STORAGE_POS.inven, pNewCon, false, true)

		if pCon then
			pPlayer:SendMsg_TakeNewResult(0, pCon)
		end
	end

	pPlayer:Emb_DelStorage(STORAGE_POS.inven, pDstItem.m_byStorageIndex, false, true, "Lua. doSkinReplaceCombination(...)")
	pPlayer:Emb_AlterDurPoint(STORAGE_POS.inven, pMaterial.m_byStorageIndex, nMatSub, true, true)

	return true
end

return { ["example socket extender"] = combineData }
