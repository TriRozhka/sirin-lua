local sirinCombineEx = {}
local sirinCombineList = require('Combine_Ex.combine_ex')

function sirinCombineEx.init()
	for _,v in ipairs(sirinCombineList.initFunction) do
		v()
	end
end

---@param pPlayer CPlayer
---@param pRecv _combine_ex_item_request_clzo
function sirinCombineEx.CPlayer__pc_CombineItemEx(pPlayer, pRecv)
	local pSend = Sirin.mainThread._combine_ex_item_result_zocl()
	pSend.byErrCode = 0

	repeat
		local ppConMats = {}
		local pipMats = {}
		local lim = pRecv.byCombineSlotNum - 1

		for i = 0, lim do
			local pMaterial = pRecv:iCombineSlot_get(i)
			local pSrcCon = pPlayer.m_Param.m_dbInven:GetPtrFromSerial(pMaterial.wItemSerial)

			if not pSrcCon then
				pPlayer:SendMsg_AdjustAmountInform(STORAGE_POS.inven, pMaterial.wItemSerial, 0)
				pSend.byDlgType = 255
				pSend.byErrCode = 4
				break
			end

			if pSrcCon.m_bLock then
				pSend.byDlgType = 255
				pSend.byErrCode = 5
				break
			end

			if Sirin.mainThread.IsOverLapItem(pSrcCon.m_byTableCode) and pMaterial.byAmount > pSrcCon.m_dwDur then
				pPlayer:SendMsg_AdjustAmountInform(STORAGE_POS.inven, pMaterial.wItemSerial, pSrcCon.m_dwDur)
				pSend.byDlgType = 255
				pSend.byErrCode = 6
				break
			end

			if i > 0 then
				for j = 0, i - 1 do
					if pRecv:iCombineSlot_get(j).wItemSerial == pMaterial.wItemSerial then
						pSend.byDlgType = 255
						pSend.byErrCode = 6
						break
					end
				end
			end

			if pSend.byErrCode ~= 0 then
				break
			end

			table.insert(ppConMats, pSrcCon)
			table.insert(pipMats, pMaterial)
		end

		local suitCombines = {}

		for k,v in ipairs(sirinCombineList.fastCheck) do
			if v(ppConMats) then
				table.insert(suitCombines, sirinCombineList.combineFunction[k])
			end
		end

		local bCombineSucc = false

		for k,v in ipairs(suitCombines) do
			if v(pPlayer, ppConMats, pipMats, pSend) then
				bCombineSucc = true
				break
			end
		end

		if not bCombineSucc then
			pSend.byDlgType = 255
			pSend.byErrCode = 1
		end

	until true

	pPlayer:SendMsg_CombineItemExResult(pSend)
end

---@param pCombineMgr ItemCombineMgr
---@param pPlayerItemDB _ITEMCOMBINE_DB_BASE
---@param pRecv _combine_ex_item_accept_request_clzo
---@param pSend _combine_ex_item_accept_result_zocl
---@return integer
function sirinCombineEx.MakeNewItems(pCombineMgr, pPlayerItemDB, pRecv, pSend)
	local lnUIDs = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	local Dst = { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false }
	local byRewardTypeList = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

	local bySelectNum = pRecv.SelectItemBuff.bySelectNum

	if bySelectNum > pPlayerItemDB.m_bySelectItemCount then
		bySelectNum = pPlayerItemDB.m_bySelectItemCount
	end

	if bySelectNum > 24 then
		bySelectNum = 24
	end

	if pPlayerItemDB.m_byDlgType == 0 then
		for j = 0, bySelectNum - 1 do
			if pRecv.SelectItemBuff:bySelectIndexList_get(j) < 24 then
				Dst[pRecv.SelectItemBuff:bySelectIndexList_get(j) + 1] = true
			end
		end
	elseif pPlayerItemDB.m_byDlgType == 1 then
		if pPlayerItemDB.m_byItemListNum > 24 then
			bySelectNum = 24
		else
			bySelectNum = pPlayerItemDB.m_byItemListNum
		end

		for j = 1, bySelectNum do
			Dst[j] = true
		end
	end

	local byListNum = pPlayerItemDB.m_byItemListNum

	if byListNum > 24 then
		byListNum = 24
	end

	for j = 1, byListNum do
		repeat
			if not Dst[j] or not pPlayerItemDB:m_List_get(j - 1).Key:IsFilled() then
				break
			end

			local Con = pPlayerItemDB:m_List_get(j - 1)
			local Item = Sirin.mainThread._STORAGE_LIST___db_con()
			Item.m_byTableCode = Con.Key.byTableCode
			Item.m_wItemIndex = Con.Key.wItemIndex

			if Sirin.mainThread.IsOverLapItem(Item.m_byTableCode) then
				Item.m_dwDur = Con.dwDur
			else
				Item.m_dwDur = Sirin.mainThread.GetItemDurPoint(Item.m_byTableCode, Item.m_wItemIndex)
			end

			local byKind = GetItemKindCode(Item.m_byTableCode)

			if byKind ~= 0 then
				if byKind == 1 then
					Item.m_dwDur = Con.dwDur
					Item.m_dwLv = Con.dwUpt
				end
			else
				if Con.dwUpt == 0x0FFFFFFF then
					local SockLim = Sirin.mainThread.GetDefItemUpgSocketNum(Item.m_byTableCode, Item.m_wItemIndex)

					if SockLim ~= 0 then
						Item.m_dwLv = Sirin.mainThread.GetBitAfterSetLimSocket(math.random(1, SockLim))
					end
				else
					Item.m_dwLv = Con.dwUpt
				end

				-- Skin module requirement

				if Item.m_byTableCode < 8 and Con.dwDur > 0x100 then
					Item.m_dwDur = SKIN_MAGIC * 0x100000000 + Con.dwDur
				end
			end

			if pCombineMgr.m_pMaster.m_Param.m_dbInven:GetIndexEmptyCon() == 255 then
				Sirin.mainThread.createItemBoxForAutoLoot(Item, pCombineMgr.m_pMaster, 0xFFFFFFFF, false, nil, 3, pCombineMgr.m_pMaster.m_pCurMap, pCombineMgr.m_pMaster.m_wMapLayerIndex, { pCombineMgr.m_pMaster:m_fCurPos_x(), pCombineMgr.m_pMaster:m_fCurPos_y(), pCombineMgr.m_pMaster:m_fCurPos_z() }, false)
				byRewardTypeList[j] = 2
			else
				Item.m_wSerial = pCombineMgr.m_pMaster.m_Param:GetNewItemSerial()

				local pTimeItemFld = Sirin.mainThread.TimeItem__FindTimeRec(Item.m_byTableCode, Item.m_wItemIndex)

				if pTimeItemFld and pTimeItemFld.m_nCheckType then
					local CurTime = os.time()
					Item.m_byCsMethod = pTimeItemFld.m_nCheckType
					Item.m_dwT = CurTime + pTimeItemFld.m_nUseTime
					Item.m_dwLendRegdTime = CurTime
				end

				local pNewCon = pCombineMgr.m_pMaster:Emb_AddStorage(STORAGE_POS.inven, Item, false, true)

				if not pNewCon then
					local str = string.format("Amb_AddStorage ERR - item:[%d-%d], CodePos:(ItemCombineMgr::MakeNewItems - Emb_AddStorage() Fail)", Item.m_byTableCode, Item.m_wItemIndex)
					Sirin.WriteA(pCombineMgr.m_pMaster.m_szItemHistoryFileName, str, false, false)
					break
				end

				pCombineMgr.m_pMaster:SendMsg_RewardAddItem(Item, 0)
				byRewardTypeList[j] = 1
				lnUIDs[j] = pNewCon.m_lnUID

				if Sirin.mainThread.modItemPropertySkin.isSkinItem(pNewCon.m_dwDur) then
					Sirin.mainThread.modItemPropertySkin.insertProperty(pNewCon.m_lnUID, pCombineMgr.m_pMaster.m_pUserDB.m_dwAccountSerial, pNewCon.m_dwDur & 0xFFFFFFFF)
				end
			end

			if pPlayerItemDB.m_byItemListNum == 1 then
				if pPlayerItemDB.m_dwResultEffectType == 1 then
					pCombineMgr.m_pMaster:SendMsg_FanfareItem(1, Item, nil)
				end
			else
				pCombineMgr.m_pMaster:SendMsg_FanfareItem(1, Item, nil)
			end
		until true
	end

	Sirin.mainThread.CMgrAvatorItemHistory.Instance():combine_ex_reward_item(pCombineMgr.m_pMaster, bySelectNum, pPlayerItemDB, byRewardTypeList, lnUIDs)

	return 0
end

return sirinCombineEx
