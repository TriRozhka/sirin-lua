-- Rename or remove functions in this file to use default game server logic.

---@param pPlayer CPlayer
---@param pMsg _combine_ex_item_request_clzo
function MainThread.CPlayer__pc_CombineItemEx(pPlayer, pMsg)
    -- Implementation of this function is optional
    CombineExMgr.CPlayer__pc_CombineItemEx(pPlayer, pMsg)
end

--[[
---@param pTower CGuardTower
---@return CCharacter?
function MainThread.CGuardTower__SearchNearEnemy(pTower)
	-- Implementation of this function is optional
	return TowerMgr:SearchNearEnemy(pTower)
end
--]]

--[[
---@param pTower CGuardTower
---@return boolean
function MainThread.CGuardTower__IsValidTarget(pTower)
	-- Implementation of this function is optional
	return TowerMgr:IsValidTarget(pTower)
end
--]]

---@param pPlayer CPlayer
---@param pposTalik _STORAGE_POS_INDIV
---@param pposToolItem _STORAGE_POS_INDIV
---@param pposUpgItem _STORAGE_POS_INDIV
---@param jewels table<integer, _STORAGE_POS_INDIV>
function MainThread.CPlayer__pc_UpgradeItem(pPlayer, pposTalik, pposToolItem, pposUpgItem, jewels)
	-- Implementation of this function is optional
	PlayerMgr.pc_UpgradeItem(pPlayer, pposTalik, pposToolItem, pposUpgItem, jewels)
end

---@param pPlayer CPlayer
---@param pipMakeTool _STORAGE_POS_INDIV
---@param wManualIndex integer
---@param materials table<integer, _STORAGE_POS_INDIV>
function MainThread.CPlayer__pc_MakeItem(pPlayer, pipMakeTool, wManualIndex, materials)
	-- Implementation of this function is optional
	PlayerMgr.CPlayer__pc_MakeItem(pPlayer, pipMakeTool, wManualIndex, materials)
end

--[[
---@param pSrcChar CCharacter
---@param nAttPnt integer
---@param nAttPart integer
---@param nTolType integer
---@param pDstChar CCharacter
---@param bBackAttack boolean
---@return integer
function MainThread.CCharacter__GetAttackDamPoint(pSrcChar, nAttPnt, nAttPart, nTolType, pDstChar, bBackAttack)
	-- Implementation of this function is optional
	return 1
end
--]]

--[[
---@param pPlayer CPlayer
---@param nEffCode integer
---@param fVal number
---@param bAdd boolean
---@param nDiffCnt integer
function MainThread.CPlayer__apply_have_item_std_effect(pPlayer, nEffCode, fVal, bAdd, nDiffCnt)
	-- Implementation of this function is optional
	PlayerMgr.CPlayer__apply_have_item_std_effect(pPlayer, nEffCode, fVal, bAdd, nDiffCnt)
end
--]]

--[[
---@param pPlayer CPlayer
---@param nEffCode integer
---@param fVal number
---@param bEquip boolean
function MainThread.CPlayer__apply_normal_item_std_effect(pPlayer, nEffCode, fVal, bEquip)
	-- Implementation of this function is optional
	PlayerMgr.CPlayer__apply_normal_item_std_effect(pPlayer, nEffCode, fVal, bEquip)
end
--]]

--[[
---@param pPlayer CPlayer
---@param pItem _STORAGE_LIST___db_con
---@param bEquip boolean
function MainThread.CPlayer__apply_case_equip_upgrade_effect(pPlayer, pItem, bEquip)
	-- Implementation of this function is optional
	PlayerMgr.CPlayer__apply_case_equip_upgrade_effect(pPlayer, pItem, bEquip)
end
--]]

--[[
---@param pAttack CAttack
---@param nLimDist integer
---@param nAttPower integer
---@param nAngle integer
---@param nEffAttPower integer
---@param bUseEffBullet boolean
function MainThread.CAttack__FlashDamageProc(pAttack, nLimDist, nAttPower, nAngle, nEffAttPower, bUseEffBullet)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pAttack CAttack
---@param nLimitRadius integer
---@param nAttPower integer
---@param TarPos table<integer, number>
---@param nEffAttPower integer
---@param bUseEffBullet boolean
function MainThread.CAttack__AreaDamageProc(pAttack, nLimitRadius, nAttPower, TarPos, nEffAttPower, bUseEffBullet)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pAttack CAttack
---@param nSkillLv integer
---@param nAttPower integer
---@param nAngle integer
---@param nShotNum integer
---@param nWeaponRange integer
---@param nEffAttPower integer
---@param bUseEffBullet boolean
function MainThread.CAttack__SectorDamageProc(pAttack, nSkillLv, nAttPower, nAngle, nShotNum, nWeaponRange, nEffAttPower, bUseEffBullet)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pKiller CPlayer
---@param pDier CPlayer
function MainThread.CPlayer__CalcPvP(pKiller, pDier)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pKiller CPlayer
---@param pDier CPlayer
function MainThread.CPlayer__CalPvpTempCash(pKiller, pDier)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pPlayer CPlayer
---@return boolean
function MainThread.CPlayer__IsHaveEmptyTower(pPlayer)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pMonster CMonster
---@param pOwner CPlayer
---@return boolean
function MainThread.CMonster___LootItem_Std(pMonster, pOwner)
	-- Implementation of this function is optional
	return LootingMgr:lootItemStd(pMonster, pOwner)
end
--]]

--[[
---@param pCombineMgr ItemCombineMgr
---@param pPlayerItemDB _ITEMCOMBINE_DB_BASE
---@param pRecv _combine_ex_item_accept_request_clzo
---@param pSend _combine_ex_item_accept_result_zocl
---@return integer
function MainThread.ItemCombineMgr__MakeNewItems(pCombineMgr, pPlayerItemDB, pRecv, pSend)
	-- Implementation of this function is optional
	return CombineExMgr.MakeNewItems(pCombineMgr, pPlayerItemDB, pRecv, pSend)
end
--]]

--[[
---@param pQuestMgr CQuestMgr
---@param byQuestDBSlot integer
---@return boolean
function MainThread.CQuestMgr__CanGiveupQuest(pQuestMgr, byQuestDBSlot)
	-- Implementation of this function is optional
	return true
end
--]]

--[[
---@param pQuestMgr CQuestMgr
---@param pStore? CItemStore
---@param dwNPCQuestIndex integer
function MainThread.CPlayer__pc_RequestQuestFromNPC(pQuestMgr, pStore, dwNPCQuestIndex)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pQuestMgr CQuestMgr
---@param pszEventCode string
---@param byRaceCode integer
---@param pQuestIndexData _NPCQuestIndexTempData
function MainThread.CQuestMgr__CheckNPCQuestList(pQuestMgr, pszEventCode, byRaceCode, pQuestIndexData)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pQuestMgr CQuestMgr
---@param pszEventCode? string
---@param byRaceCode integer
---@param dwQuestIndex integer
---@param dwHappenIndex integer
---@return boolean
function MainThread.CQuestMgr__CheckNPCQuestStartable(pQuestMgr, pszEventCode, byRaceCode, dwQuestIndex, dwHappenIndex)
	-- Implementation of this function is optional
	return true
end
--]]

--[[
---@param pActChar CCharacter
---@param pTargetChar any
---@param fEffectValue number
---@return boolean
---@return integer
function MainThread.DE_Potion_Trunk_Extend(pActChar, pTargetChar, fEffectValue)
	-- Implementation of this function is optional
	return true, 0
end
--]]
