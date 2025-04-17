---@class (exact) sirinAutoLootMgr
---@field initHooks fun()
---@field canUseAutoLoot fun(pKiller: CPlayer, pMonster: CMonster): boolean
local sirinAutoLootMgr = {}

function sirinAutoLootMgr.initHooks()
	SirinLua.HookMgr.addHook("canUseAutoLoot", HOOK_POS.filter, "sirin.lua.sirinAutoLootMgr", sirinAutoLootMgr.canUseAutoLoot)
end

---@param pKiller CPlayer
---@param pMonster CMonster
---@return boolean
function sirinAutoLootMgr.canUseAutoLoot(pKiller, pMonster)
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

	if bNeedFreeSlot and pOwner.m_Param.m_dbInven:GetIndexEmptyCon() == 255 then -- disable autoloot when inven is full
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
	if bHaveItem then -- check for item. This method is slow and should not be used. Code provided as item search example.
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

return sirinAutoLootMgr
