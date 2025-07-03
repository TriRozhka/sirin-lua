local math = math

local objectToCharacter = Sirin.mainThread.objectToCharacter
local objectToPlayer = Sirin.mainThread.objectToPlayer
local objectToMonster = Sirin.mainThread.objectToMonster
local objectToAnimus = Sirin.mainThread.objectToAnimus
local objectToTower = Sirin.mainThread.objectToTower
local objectToTrap = Sirin.mainThread.objectToTrap
local objectToAMP = Sirin.mainThread.objectToAMP
local baseToGuardTowerItem = Sirin.mainThread.baseToGuardTowerItem

local sendBuf = Sirin.mainThread.CLuaSendBuffer.Instance()

---@class sirinTowerMgr
---@field m_bSystemTowerAssist boolean
---@field m_bPlayerTowerAssist boolean
---@field m_bTowerSelfDefense boolean
---@field m_strUUID string
---@field initHooks fun()
---@field testTowerTarget fun(pTower: CGuardTower, pTarget: CCharacter): boolean
---@field searchNearEnemy fun(pTower:CGuardTower): CCharacter?
---@field make_tower_attack_param fun(pTower: CGuardTower, pDst: CCharacter): sirinCAttack
---@field Attack fun(pTower: CGuardTower, pTarget: CCharacter)
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
		local fMaxDist = baseToGuardTowerItem(pTower.m_pRecordSet).m_nGADst + pTarget:GetWidth() / 2.0

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
			pTarPlayer = objectToPlayer(pTarget)
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.animus then
			pTarPlayer = objectToAnimus(pTarget).m_pMaster
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.tower then
			pTarPlayer = objectToTower(pTarget).m_pMasterTwr
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.trap then
			-- pTarPlayer = objectToTrap(pTarget).m_pMaster
			break -- for now do not let towers hit traps.
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.amine_personal then
			pTarPlayer = objectToAMP(pTarget).m_pOwner
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
				local pMonTar = objectToMonster(pTarget).m_pTargetChar

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
				local pMonTar = objectToMonster(pTarget).m_pTargetChar

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

	local nAttackRadius = baseToGuardTowerItem(pTower.m_pRecordSet).m_nGADst
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

				local pTestChar = objectToCharacter(pTestObj)
				local idChar = pTestObj.m_ObjID.m_byID

				if idChar == ID_CHAR.animus
					or idChar == ID_CHAR.tower
					or idChar == ID_CHAR.amine_personal
					then
					if sirinTowerMgr.testTowerTarget(pTower, pTestChar) then
						table.insert(aroundEnemyPlayerProperty, pTestChar)
					end
				elseif idChar == ID_CHAR.monster then
					local pMonTar = objectToMonster(pTestObj).m_pTargetChar

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

---@param pTower CGuardTower
---@param pDst CCharacter
---@return sirinCAttack
function sirinTowerMgr.make_tower_attack_param(pTower, pDst)
	local pAT = SirinCAttack:new()
	pAT.m_pAttChar = pTower
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst
	pAP.nPart = CharacterMgr.GetAttackRandomPart(pDst and pDst or pTower)
	local pTowerFld = baseToGuardTowerItem(pTower.m_pRecordSet)
	pAP.nTol = pTowerFld.m_nProperty
	pAP.nClass = 1
	pAP.nMinAF = pTowerFld.m_nGAMinAF
	pAP.nMaxAF = pTowerFld.m_nGAMaxAF
	pAP.nMinSel = pTowerFld.m_nGAMinSelProb
	pAP.nMaxSel = pTowerFld.m_nGAMaxSelProb

	return pAT
end

---@param pTower CGuardTower
---@param pTarget CCharacter
function sirinTowerMgr.Attack(pTower, pTarget)
	repeat
		local nRet = pTower.m_pCurMap.m_Level.mBsp:CanYouGoThere(pTarget.m_fCurPos_x, pTarget.m_fCurPos_y, pTarget.m_fCurPos_z, pTower.m_fCurPos_x, pTower.m_fCurPos_y, pTower.m_fCurPos_z)

		if nRet == 0 then
			break
		end

		local pAT = sirinTowerMgr.make_tower_attack_param(pTower, pTarget)
		pAT:AttackGen(false, false)

		if #pAT.m_DamList == 0 then
			break
		end

		--[[
		struct _attack_tower_inform_zocl
		{
			unsigned int dwAtterSerial;
			char byAttackPart;
			bool bCritical;
			char byDstID;
			unsigned int dwDstSerial;
			unsigned __int16 wDamage;
		};
		--]]

		sendBuf:Init()
		sendBuf:PushUInt32(pTower.m_dwObjSerial)
		sendBuf:PushUInt8(pAT.m_pp.nPart)
		sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
		sendBuf:PushUInt8(pTarget.m_ObjID.m_byID)
		sendBuf:PushUInt32(pTarget.m_dwObjSerial)

		local d = pAT.m_DamList[1]

		if d.m_nDamage < 0 then
			sendBuf:PushInt16(d.m_nDamage)
		else
			sendBuf:PushUInt16(d.m_nDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
		end

		pTower:CircleReport(5, 15, sendBuf, false)

		for _,d in ipairs(pAT.m_DamList) do
			d.m_pChar:SetDamage(d.m_nDamage, pTower, pTower:GetLevel(), pAT.m_bIsCrtAtt, -1, 0, true)
		end

	until true
end

---@param _this CGuardTower
---@param nPart integer
---@return number
function sirinTowerMgr.GetDefGap(_this, nPart)
	return baseToGuardTowerItem(_this.m_pRecordSet).m_fDefGap
end

---@param _this CGuardTower
---@param nPart integer
---@return number
function sirinTowerMgr.GetDefFacing(_this, nPart)
	return baseToGuardTowerItem(_this.m_pRecordSet).m_fDefFacing
end

---@param _this CGuardTower
---@param nAttactPart integer
---@param pAttChar CCharacter
---@return integer nDefFC
---@return integer nConvertPart
function sirinTowerMgr.CPlayer__GetDefFC(_this, nAttactPart, pAttChar)
	return baseToGuardTowerItem(_this.m_pRecordSet).m_nDefFc, 0
end

---@param _this CGuardTower
---@return number
function sirinTowerMgr.GetWeaponAdjust(_this)
	return baseToGuardTowerItem(_this.m_pRecordSet).m_fAttGap
end

return sirinTowerMgr
