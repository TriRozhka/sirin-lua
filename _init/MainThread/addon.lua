---@param pUserDB CUserDB
---@param pszName string
---@return boolean
function MainThread.isValidPlayerName(pUserDB, pszName)
	-- Implementation of this function is optional
	return true
end

---@param pPlayer CPlayer
---@param pszGuildName string
---@return boolean
function MainThread.isValidGuildName(pPlayer, pszGuildName)
	-- Implementation of this function is optional
	return true
end

---@param dwSocket integer
---@return integer
function MainThread.getPlayerLanguage(dwSocket)
	return Sirin.CLanguageAsset.instance():getPlayerLanguage(dwSocket)
end

---@param dwSocket integer
---@return string
function MainThread.getPlayerLanguagePrefix(dwSocket)
	return Sirin.CLanguageAsset.instance():getPlayerLanguagePrefix(dwSocket)
end

---@param uuid string
---@param serial integer
function MainThread.exitAccountReport(uuid, serial)
	-- Implementation of this function is optional
end

---@param uuid string
---@param serial integer
function MainThread.enterAccountReport(uuid, serial)
	-- Implementation of this function is optional
end

---@param pRift CDummyRift
function MainThread.CDummyRift__CDummyRift_ctor(pRift)
	-- Implementation of this function is optional
	RiftMgr:createRift(pRift)
end

---@param pRift CDummyRift
function MainThread.CDummyRift__CDummyRift_dtor(pRift)
	-- Implementation of this function is optional
	RiftMgr:destroyRift(pRift)
end

---@param pRift CDummyRift
---@param pPlayer CPlayer
---@return integer
function MainThread.CDummyRift__Enter(pRift, pPlayer)
	-- Implementation of this function is optional

	local rift = RiftMgr:getRift(pRift)

	if rift then
		return rift:Enter(pPlayer)
	end

	return 3
end

---@param pRift CDummyRift
function MainThread.CDummyRift__Close(pRift)
	-- Implementation of this function is optional

	local rift = RiftMgr:getRift(pRift)

	if rift then
		rift:Close()
	end
end

---@param pRift CDummyRift
---@return boolean
function MainThread.CDummyRift__IsClose(pRift)
	-- Implementation of this function is optional

	local rift = RiftMgr:getRift(pRift)

	if rift then
		return rift:IsClose()
	end

	return true
end

---@param pRift CDummyRift
---@return boolean
function MainThread.CDummyRift__IsValidOwner(pRift)
	-- Implementation of this function is optional

	local rift = RiftMgr:getRift(pRift)

	if rift then
		return rift:IsValidOwner()
	end

	return true
end

---@param pRift CDummyRift
function MainThread.CDummyRift__SendMsg_Create(pRift)
	-- Implementation of this function is optional

	local rift = RiftMgr:getRift(pRift)

	if rift then
		return rift:SendMsg_Create()
	end
end

---@param pRift CDummyRift
function MainThread.CDummyRift__SendMsg_Destroy(pRift)
	-- Implementation of this function is optional

	local rift = RiftMgr:getRift(pRift)

	if rift then
		return rift:SendMsg_Destroy()
	end
end

---@param pRift CDummyRift
---@param nIndex integer
function MainThread.CDummyRift__SendMsg_FixPosition(pRift, nIndex)
	-- Implementation of this function is optional

	local rift = RiftMgr:getRift(pRift)

	if rift then
		return rift:SendMsg_FixPosition(nIndex)
	end
end

---@param pRift CDummyRift
---@param pPlayer CPlayer
function MainThread.CDummyRift__SendMsg_MovePortal(pRift, pPlayer)
	-- Implementation of this function is optional

	local rift = RiftMgr:getRift(pRift)

	if rift then
		return rift:SendMsg_MovePortal(pPlayer)
	end
end

---@param dwRetCode integer
---@param strParam string
---@param nAlterValue integer
---@param dwCashLeft integer
---@param pPlayer? CPlayer
function MainThread.AlterCashComplete(dwRetCode, strParam, nAlterValue, dwCashLeft, pPlayer)
	-- Implementation of this function is optional
end

--[[
---@param pCharacter CCharacter
---@param sf _sf_continous_ex
---@param bInit boolean
function MainThread.CCharacter__OnContEffInsert(pCharacter, sf, bInit)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pCharacter CCharacter
---@param sf _sf_continous_ex
---@param bTime boolean
function MainThread.CCharacter__OnContEffRemove(pCharacter, sf, bTime)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pPlayer CPlayer
---@param sf _sf_continous_ex
---@---@param bInit boolean
function MainThread.CPlayer__OnPotionEffInsert(pPlayer, sf, bInit)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pPlayer CPlayer
---@param sf _sf_continous_ex
---@param bTime boolean
function MainThread.CPlayer__OnPotionEffRemove(pPlayer, sf, bTime)
	-- Implementation of this function is optional
end
]]--

---@param pKiller CPlayer
---@param pMonster CMonster
function MainThread.CanUseAutoLoot(pKiller, pMonster)
	local bNoAutoLoot = true
	local pOwner = pKiller
	local bNoBoss = false
	local bNeedFreeSlot = false
	local bNoMAU = false
	local bNoAnimus = false
	local bNoSiegeMode = false
	local bNoParty = false
	local bNoTowers = false
	local bHaveItem = false

	if bNoAutoLoot then -- if auto loot disabled
		return false
	end

	if pKiller.m_pPartyMgr:IsPartyMode() then
		if bNoParty then
			return false
		end

		pOwner = pKiller.m_pPartyMgr:GetLootAuthor()

		if not pOwner then -- loot shared across party
			return false
		end
	end

	if pOwner.m_bCorpse then -- disable autoloot for dead players
		return false
	end

	if pOwner.m_pCurMap ~= pMonster.m_pCurMap then -- cross map autoloot disable
		return false
	else
		local dist = GetSqrt(pOwner.m_fCurPos_x, pOwner.m_fCurPos_z, pMonster.m_fCurPos_x, pMonster.m_fCurPos_z)

		if dist > 300 then -- too far from looting point
			return false
		end
	end

	if bNeedFreeSlot and pOwner.m_Param.m_dbInven:GetIndexEmptyCon() == 0xFF then -- disable autoloot when inven is full
		return false
	end

	if bNoBoss and pMonster.m_pMonRec.m_bMonsterCondition ~= 0 then -- disable for bosses
		return false
	end

	if bNoMAU and pOwner:IsRidingUnit() then -- disable for MAU
		return false
	end

	if bNoAnimus and pOwner.m_pRecalledAnimusChar then -- disable for animus
		return false
	end

	if bNoSiegeMode and pOwner:IsSiegeMode() then -- disable for siege
		return false
	end

	if bNoTowers and pOwner.m_pmTwr.m_nCount > 0 then
		return false
	end

--[[
	if bHaveItem then -- check for item. This method is slow.
		local szItemCode = "iyyyy01"
		local byTblCode = Sirin.mainThread.GetItemTableCode(szItemCode)

		if byTblCode == -1 then
			return false
		end

		local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(byTblCode):GetRecordByHash(szItemCode, 2, 5)

		if not pFld then
			return false
		end

		local bItemFound = false
		local invenSize = pOwner.m_Param.m_dbInven.m_nUsedNum - 1

		for i = 0, invenSize do
			local pCon = pOwner.m_Param.m_dbInven:m_List_get(i)

			if pCon.m_bLoad and not pCon.m_bLock and pCon.m_byTableCode == byTblCode and pCon.m_wItemIndex == pFld.m_dwIndex then
				bItemFound = true
				break
			end
		end

		if not bItemFound then
			return false
		end
	end
--]]

	if bHaveItem then
		local bEffectFound = false
		local dwEffID = 0

		if SERVER_AOP then
			dwEffID = 83
		elseif SERVER_2232 then
			dwEffID = 81
		end

		local bLock = pOwner.m_EP.m_bLock
		pOwner.m_EP.m_bLock = false

		if pOwner.m_EP:GetEff_Have(dwEffID) > 0 then
			bEffectFound = true
		end

		pOwner.m_EP.m_bLock = bLock

		if not bEffectFound then
			return false
		end
	end

	return true
end

---@param dwRetCode integer
---@param dwGuildSerial integer
---@param dTotalDalant number
---@param dTotalGold number
function MainThread.CGuild__PushMoneyComplete(dwRetCode, dwGuildSerial, dTotalDalant, dTotalGold)
	-- Implementation of this function is optional
end

---@param dwRetCode integer
---@param dwProcRet integer
---@param dwGuildSerial integer
---@param dTotalDalant number
---@param dTotalGold number
function MainThread.CGuild__PopMoneyComplete(dwRetCode, dwProcRet, dwGuildSerial, dTotalDalant, dTotalGold)
	-- Implementation of this function is optional
end
