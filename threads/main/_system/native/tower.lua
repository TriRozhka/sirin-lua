---@class (exact) sirinTowerMgr
---@field m_bSystemTowerAssist boolean
---@field m_bPlayerTowerAssist boolean
---@field m_bTowerSelfDefense boolean
---@field m_strUUID string
---@field initHooks fun()
---@field testTowerTarget fun(pTower: CGuardTower, pTarget: CCharacter): boolean
---@field searchNearEnemy fun(pTower:CGuardTower): CCharacter?
local sirinTowerMgr = {
	m_bSystemTowerAssist = true,
	m_bPlayerTowerAssist = false,
	m_bTowerSelfDefense = true,
	m_strUUID = 'sirin.lua.sirinTowerMgr',
}

function sirinTowerMgr.initHooks()
	SirinLua.HookMgr.addHook("CGuardTower__SearchNearEnemy", HOOK_POS.original, sirinTowerMgr.m_strUUID,
		---@param pTower CGuardTower
		---@return CCharacter?
		function (pTower) return sirinTowerMgr.searchNearEnemy(pTower) end)
	SirinLua.HookMgr.addHook("CGuardTower__IsValidTarget", HOOK_POS.original, sirinTowerMgr.m_strUUID,
		---@param pTower CGuardTower
		---@return boolean
		function (pTower) return sirinTowerMgr.testTowerTarget(pTower, pTower.m_pTarget) end)
end

---@param pTower CGuardTower
---@param pTarget CCharacter
---@return boolean
function sirinTowerMgr.testTowerTarget(pTower, pTarget)
	local bRet = false

	repeat
		if not pTarget or not pTower then
			break
		end

		if not pTarget.m_bLive or pTarget.m_bCorpse then
			break
		end

		if pTower.m_pCurMap ~= pTarget.m_pCurMap then
			break
		end

		if pTower.m_wMapLayerIndex ~= pTarget.m_wMapLayerIndex then
			break
		end

		if pTarget:GetCurSecNum() == 0xFFFFFFFF then
			break
		end

		if not pTarget:IsBeAttackedAble(true) then
			break
		end

		if pTarget:GetStealth(true) then
			break
		end

		local fDistToTarget = GetSqrt(pTower.m_fCurPos_x, pTower.m_fCurPos_z, pTarget.m_fCurPos_x, pTarget.m_fCurPos_z)
		local fMaxDist = Sirin.mainThread.baseToGuardTowerItem(pTower.m_pRecordSet).m_nGADst + pTarget:GetWidth() / 2.0

		if fDistToTarget > fMaxDist then
			break
		end

		if math.abs(pTower.m_fCurPos_y - pTarget.m_fCurPos_y) >= fMaxDist then
			break
		end

		local bSucc = pTower.m_pCurMap.m_Level.mBsp:CanYouGoThere(pTower.m_fCurPos_x, pTower.m_fCurPos_y, pTower.m_fCurPos_z, pTarget.m_fCurPos_x, pTarget.m_fCurPos_y, pTarget.m_fCurPos_z)

		if not bSucc then
			break
		end

		if pTarget:IsInTown() and not pTarget:IsAttackableInTown() then
			break
		end

		---@type CPlayer
		local pTarPlayer

		if pTarget.m_ObjID.m_byID == ID_CHAR.player then
			pTarPlayer = Sirin.mainThread.objectToPlayer(pTarget)
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.animus then
			pTarPlayer = Sirin.mainThread.objectToAnimus(pTarget).m_pMaster
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.tower then
			pTarPlayer = Sirin.mainThread.objectToTower(pTarget).m_pMasterTwr
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.trap then
			-- pTarPlayer = Sirin.mainThread.objectToTrap(pTarget).m_pMaster
			break -- for now do not let towers hit traps.
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.amine_personal then
			pTarPlayer = Sirin.mainThread.objectToAMP(pTarget).m_pOwner
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.holy_stone then
			break -- towers not deal damage to stones
		end

		local bSameRace = pTower:GetObjRace() == pTarget:GetObjRace()

		if pTower.m_pMasterTwr then -- we are non system tower
			if pTower.m_pMasterTwr.m_bInGuildBattle then -- we are in guild battle
				if not pTarPlayer or not pTarPlayer.m_bInGuildBattle or pTower.m_pMasterTwr.m_byGuildBattleColorInx == pTarPlayer.m_byGuildBattleColorInx then
					break -- we not allowed to attack anything beside opposite team
				end
			else -- we are not in guild battle
				if pTarPlayer and pTarPlayer.m_bInGuildBattle then
					break -- we not allwed to touch objects in guild battle
				end

				if pTarPlayer and bSameRace and not pTarPlayer:IsPunished(1, false) and not pTower.m_pMasterTwr:IsChaosMode() then
					break -- not allowed to attack player related objects of same race if not have conditions
				end
			end

			if sirinTowerMgr.m_bPlayerTowerAssist and pTarget.m_ObjID.m_byID == ID_CHAR.monster then
				local pMonTar = Sirin.mainThread.objectToMonster(pTarget).m_pTargetChar

				if not pMonTar or not pMonTar.m_bLive or pMonTar.m_bCorpse then
					break -- not allow attack monster with no target
				end

				if pMonTar and pMonTar:GetObjRace() ~= pTower:GetObjRace() then
					break -- system towers not attack monsters who attack enemy race
				end
			end
		else -- we are system tower
			if pTarPlayer and pTarPlayer.m_bInGuildBattle then
				break -- we not allwed to touch objects in guild battle
			end

			if bSameRace then
				break -- not allowed attack same race to system towers
			end

			if sirinTowerMgr.m_bSystemTowerAssist and pTarget.m_ObjID.m_byID == ID_CHAR.monster then
				local pMonTar = Sirin.mainThread.objectToMonster(pTarget).m_pTargetChar

				if not pMonTar or not pMonTar.m_bLive or pMonTar.m_bCorpse then
					break -- not allow attack monster with no target
				end

				if pMonTar and pMonTar:GetObjRace() ~= pTower:GetObjRace() then
					break -- system towers not attack monsters who attack enemy race
				end
			end
		end

		bRet = true

	until true

	return bRet
end

---@param pTower CGuardTower
---@return CCharacter?
function sirinTowerMgr.searchNearEnemy(pTower)
	---@type CCharacter?
	local pRet = nil

	if pTower.m_pMasterSetTarget then
		return pTower.m_pMasterSetTarget
	end

	local nAttackRadius = Sirin.mainThread.baseToGuardTowerItem(pTower.m_pRecordSet).m_nGADst
	local nRadius = math.floor(nAttackRadius / 100)
	nRadius = nRadius + (nAttackRadius % 100 ~= 0 and 1 or 0)

	---@type table<integer, CPlayer>
	local aroundEnemyPlayers = {}

	---@type table<integer, CCharacter>
	local aroundEnemyPlayerProperty = {}

	---@type table<integer, CCharacter>
	local aroundEnemyMonsters = {}

	local ListPlayers = pTower.m_pCurMap:GetPlayerListInRadius(pTower.m_wMapLayerIndex, pTower:GetCurSecNum(), nRadius, pTower.m_fCurPos_x, pTower.m_fCurPos_y, pTower.m_fCurPos_z, true)

	for _,pTestObj in ipairs(ListPlayers) do
		repeat
			if pTestObj.m_bCorpse or pTower:GetObjRace() == pTestObj:GetObjRace() or not sirinTowerMgr.testTowerTarget(pTower, pTestObj) then
				break
			end

			table.insert(aroundEnemyPlayers, pTestObj)

		until true

		if #aroundEnemyPlayers > 0 then
			break
		end
	end

	if #aroundEnemyPlayers == 0 then
		--local CharMask = 2 ^ ID_CHAR.monster + 2 ^ ID_CHAR.animus + 2 ^ ID_CHAR.tower + 2 ^ ID_CHAR.amine_personal -- = 2074
		local ListObjects = pTower.m_pCurMap:GetObjectListInRadius(pTower.m_wMapLayerIndex, pTower:GetCurSecNum(), nRadius, 2074, 0, pTower.m_fCurPos_x, pTower.m_fCurPos_y, pTower.m_fCurPos_z, true)

		for _,pTestObj in ipairs(ListObjects) do
			repeat
				if IsSameObject(pTower, pTestObj) or pTower:GetObjRace() == pTestObj:GetObjRace() then
					break
				end

				local pTestChar = Sirin.mainThread.objectToCharacter(pTestObj)
				local idChar = pTestObj.m_ObjID.m_byID

				if idChar == ID_CHAR.animus
					or idChar == ID_CHAR.tower
					or idChar == ID_CHAR.amine_personal
					then
					if sirinTowerMgr.testTowerTarget(pTower, pTestChar) then
						table.insert(aroundEnemyPlayerProperty, pTestChar)
					end
				elseif idChar == ID_CHAR.monster then
					local pMonTar = Sirin.mainThread.objectToMonster(pTestObj).m_pTargetChar

					if pMonTar and (sirinTowerMgr.m_bTowerSelfDefense and IsSameObject(pTower, pMonTar) or ((sirinTowerMgr.m_bSystemTowerAssist and not pTower.m_pMasterTwr or sirinTowerMgr.m_bPlayerTowerAssist and pTower.m_pMasterTwr) and pMonTar:GetObjRace() == pTower:GetObjRace())) and sirinTowerMgr.testTowerTarget(pTower, pTestChar) then
						table.insert(aroundEnemyMonsters, pTestChar)
					end
				end

				if #aroundEnemyPlayerProperty > 0 then
					break
				end

			until true
		end
	end

	if #aroundEnemyPlayers > 0 then
		pRet = aroundEnemyPlayers[1]
	elseif #aroundEnemyPlayerProperty > 0 then
		pRet = aroundEnemyPlayerProperty[1]
	elseif #aroundEnemyMonsters > 0 then
		pRet = aroundEnemyMonsters[1]
	end

	return pRet
end

return sirinTowerMgr
