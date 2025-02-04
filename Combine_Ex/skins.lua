local skin = {};

local function isCompatibleRace(dst, src)
	for i = 1, 5 do
		if string.sub(dst, i, i) == '1' and string.sub(src, i, i) == '0' then
			return false
		end
	end

	return true
end

skin.isSkinReplaceCombination = function(ppConMats)
	repeat
		if #ppConMats > 3 then
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
			if v == 2 then
				return true
			end
		end

	until true

	return false
end

skin.doSkinReplaceCombination = function(pPlayer, ppConMats, pipMats, pSend)
	---@type _STORAGE_LIST___db_con
	local pSrcItem = nil
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
			if not pSrcItem then
				pSrcItem = v
			elseif pSrcItem.m_wItemIndex < v.m_wItemIndex then
				pDstItem = pSrcItem
				pSrcItem = v
			else
				pDstItem = v
			end
		end
	end

	if pSrcItem.m_byTableCode == 6 then
		local pSrcFld = Sirin.mainThread.baseToWeaponItem(Sirin.mainThread.g_Main:m_tblItemData_get(pSrcItem.m_byTableCode):GetRecord(pSrcItem.m_wItemIndex))
		local pDstFld = Sirin.mainThread.baseToWeaponItem(Sirin.mainThread.g_Main:m_tblItemData_get(pSrcItem.m_byTableCode):GetRecord(pDstItem.m_wItemIndex))

		if pSrcFld.m_nType ~= pDstFld.m_nType or pSrcFld.m_nSubType ~= pDstFld.m_nSubType or pSrcFld.m_nFixPart ~= pDstFld.m_nFixPart or string.sub(pSrcFld.m_strModel, 2, 4) ~= string.sub(pDstFld.m_strModel, 2, 4) then
			return false
		end

		if not isCompatibleRace(pDstFld.m_strCivil, pSrcFld.m_strCivil) then
			return false
		end
	elseif pSrcItem.m_byTableCode == 7 or pSrcItem.m_byTableCode < 6 then
		local pSrcFld = Sirin.mainThread.baseToDfnEquipItem(Sirin.mainThread.g_Main:m_tblItemData_get(pSrcItem.m_byTableCode):GetRecord(pSrcItem.m_wItemIndex))
		local pDstFld = Sirin.mainThread.baseToDfnEquipItem(Sirin.mainThread.g_Main:m_tblItemData_get(pSrcItem.m_byTableCode):GetRecord(pDstItem.m_wItemIndex))

		if not isCompatibleRace(pDstFld.m_strCivil, pSrcFld.m_strCivil) then
			return false
		end
	end

	pSend.byDlgType = 1
	pSend.bySelectItemCount = 0
	pSend.dwDalant = 0
	pSend.dwResultEffectType = 1
	pSend.dwResultEffectMsgCode = 3605
	pSend.ItemBuff.byItemListNum = 1

	local SkinKey = pSrcItem.m_wItemIndex * 0x10000 + pDstItem.m_byTableCode * 0x100
	local pNewCon = Sirin.mainThread._STORAGE_LIST___storage_con()
	pNewCon.m_byTableCode = pDstItem.m_byTableCode
	pNewCon.m_wItemIndex = pDstItem.m_wItemIndex
	pNewCon.m_dwDur = SKIN_MAGIC * 0x100000000 + SkinKey
	pNewCon.m_dwLv = pDstItem.m_dwLv
	pNewCon.m_wSerial = pPlayer.m_Param:GetNewItemSerial()
	pNewCon.m_lnUID = pDstItem.m_lnUID
	pNewCon.m_byCsMethod = pDstItem.m_byCsMethod
	pNewCon.m_dwT = pDstItem.m_dwT
	pNewCon.m_dwLendRegdTime = pDstItem.m_dwLendRegdTime

	local RewardItem = pSend.ItemBuff:RewardItemList_get(0)
	RewardItem.Key.byTableCode = pNewCon.m_byTableCode
	RewardItem.Key.wItemIndex = pNewCon.m_wItemIndex
	RewardItem.Key.byRewardIndex = 0
	RewardItem.dwDur = SkinKey
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

			if Sirin.mainThread.modItemPropertySkin.isSkinItem(pDstItem.m_dwDur) then
				Sirin.mainThread.modItemPropertySkin.updateProperty(pDstItem.m_lnUID, SkinKey)
			else
				Sirin.mainThread.modItemPropertySkin.insertProperty(pNewCon.m_lnUID, pPlayer.m_pUserDB.m_dwAccountSerial, SkinKey)
			end
		end
	end

	pPlayer:Emb_DelStorage(STORAGE_POS.inven, pDstItem.m_byStorageIndex, false, true, "Lua. doSkinReplaceCombination(...)")
	pPlayer:Emb_DelStorage(STORAGE_POS.inven, pSrcItem.m_byStorageIndex, false, true, "Lua. doSkinReplaceCombination(...)")
	pPlayer:Emb_AlterDurPoint(STORAGE_POS.inven, pMaterial.m_byStorageIndex, nMatSub, true, true)

	return true
end

return skin
