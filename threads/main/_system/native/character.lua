---@table
local sirinCharacterMgr = {}

---@param pSrcCharacter CCharacter
---@param pDstCharacter CCharacter
---@param nEffectCode integer
---@param pSkillFld _skill_fld
---@param nLv integer
---@param bOverride? boolean
---@param dwDurationOverride? integer
---@return boolean bResult
---@return integer byErrCode
---@return boolean bUpMastery
function sirinCharacterMgr.assistSkill(pSrcCharacter, pDstCharacter, nEffectCode, pSkillFld, nLv, bOverride, dwDurationOverride)
	if bOverride then
		local deleteIndex = sirinCharacterMgr.getAppliedEffectIndex(pDstCharacter, nEffectCode, pSkillFld.m_dwIndex)

		if deleteIndex ~= 0xFFFF then
			pDstCharacter:RemoveSFContEffect(pSkillFld.m_nContEffectType, deleteIndex, false, false)
		end
	end

	if dwDurationOverride and dwDurationOverride > 0 then
		local oldDuration = pSkillFld:m_nContEffectSec_get(nLv - 1)
		pSkillFld:m_nContEffectSec_set(nLv - 1, dwDurationOverride)
		local a, b, c = pSrcCharacter:AssistSkill(pDstCharacter, nEffectCode, pSkillFld, nLv)
		pSkillFld:m_nContEffectSec_set(nLv - 1, oldDuration)
		return a, b, c
	else
		return pSrcCharacter:AssistSkill(pDstCharacter, nEffectCode, pSkillFld, nLv)
	end
end

---@param pSrcCharacter CCharacter
---@param pDstCharacter CCharacter
---@param pForceFld _force_fld
---@param nLv integer
---@param bOverride? boolean
---@param dwDurationOverride? integer
---@return boolean bResult
---@return integer byErrCode
---@return boolean bUpMastery
function sirinCharacterMgr.assistForce(pSrcCharacter, pDstCharacter, pForceFld, nLv, bOverride, dwDurationOverride)
	if bOverride then
		local deleteIndex = sirinCharacterMgr.getAppliedEffectIndex(pDstCharacter, EFF_CODE.force, pForceFld.m_dwIndex)

		if deleteIndex ~= 0xFFFF then
			pDstCharacter:RemoveSFContEffect(pForceFld.m_nContEffectType, deleteIndex, false, false)
		end
	end

	if dwDurationOverride and dwDurationOverride > 0 then
		local oldDuration = pForceFld:m_nContEffectSec_get(nLv - 1)
		pForceFld:m_nContEffectSec_set(nLv - 1, dwDurationOverride)
		local a, b, c = pSrcCharacter:AssistForce(pDstCharacter, pForceFld, nLv)
		pForceFld:m_nContEffectSec_set(nLv - 1, oldDuration)
		return a, b, c
	else
		return pSrcCharacter:AssistForce(pDstCharacter, pForceFld, nLv)
	end
end

---@param pCharacter CCharacter
---@param nEffectCode integer
---@param dwScriptIndex integer
---@return integer
function sirinCharacterMgr.getAppliedEffectIndex(pCharacter, nEffectCode, dwScriptIndex)
	local wDeleteIndex = 0xFFFF

	repeat
		if nEffectCode < EFF_CODE.skill or nEffectCode > EFF_CODE.bullet then
			break
		end

		local pFld = Sirin.mainThread.g_Main:m_tblEffectData_get(nEffectCode):GetRecord(dwScriptIndex)

		if not pFld then
			break
		end

		local nEffectClass = 0
		local nContType = 0

		if nEffectCode == EFF_CODE.force then
			local pForceFld = Sirin.mainThread.baseToForce(pFld)
			nEffectClass = pForceFld.m_nClass
			nContType = pForceFld.m_nContEffectType
		else
			local pSkillFld = Sirin.mainThread.baseToSkill(pFld)
			nEffectClass = pSkillFld.m_nClass
			nContType = pSkillFld.m_nContEffectType
		end

		if Sirin.mainThread.modContEffect.isUse() and pCharacter.m_ObjID.m_byID == ID_CHAR.player and not (nEffectCode == EFF_CODE.skill and nEffectClass == 4) then
			local pPlayer = Sirin.mainThread.objectToPlayer(pCharacter)
			local EffNum = Sirin.mainThread.modContEffect.getMaxSFNum(nContType) - 1

			for i = 0, EffNum do
				repeat
					local _sf_continous_ex = Sirin.mainThread.modContEffect.getPlayersfcontEx(pPlayer, nContType, i)

					if not _sf_continous_ex.m_bExist then
						break
					end

					if _sf_continous_ex.m_byEffectCode ~= nEffectCode then
						break
					end

					if _sf_continous_ex.m_dwEffectIndex ~= pFld.m_dwIndex then
						break
					end

					if wDeleteIndex == 0xFFFF then
						wDeleteIndex = i
					end

				until true

				if wDeleteIndex ~= 0xFFFF then
					break
				end
			end
		elseif nEffectCode == EFF_CODE.skill and nEffectClass == 4 then
			for i = 0, 7 do
				repeat
					local sf = pCharacter:m_SFContAura_get(nContType, i)

					if not sf.m_bExist then
						break
					end

					if sf.m_byEffectCode ~= nEffectCode then
						break
					end

					if sf.m_wEffectIndex ~= pFld.m_dwIndex then
						break
					end

					if wDeleteIndex == 0xFFFF then
						wDeleteIndex = i
					end

				until true

				if wDeleteIndex ~= 0xFFFF then
					break
				end
			end
		else
			for i = 0, 7 do
				repeat
					local sf = pCharacter:m_SFCont_get(nContType, i)

					if not sf.m_bExist then
						break
					end

					if sf.m_byEffectCode ~= nEffectCode then
						break
					end

					if sf.m_wEffectIndex ~= pFld.m_dwIndex then
						break
					end

					if wDeleteIndex == 0xFFFF then
						wDeleteIndex = i
					end

				until true

				if wDeleteIndex ~= 0xFFFF then
					break
				end
			end
		end

	until true

	return wDeleteIndex
end

---@param pCharacter CCharacter
---@param byTolType integer
---@param nDamPoint integer
---@return integer
local function GetTotalTol(pCharacter, byTolType, nDamPoint)
	local fire = pCharacter:GetFireTol() / 100.0
	local water = pCharacter:GetWaterTol() / 100.0
	local soil = pCharacter:GetSoilTol() / 100.0
	local wind = pCharacter:GetWindTol() / 100.0
	local nRet = 0

	if byTolType == TOL_CODE.fire then
		nRet = nDamPoint * soil * 0.9 - nDamPoint * fire * 0.1 - nDamPoint * water * 0.9
	elseif byTolType == TOL_CODE.water then
		nRet = nDamPoint * fire * 0.9 - nDamPoint * water * 0.1 - nDamPoint * wind * 0.9
	elseif byTolType == TOL_CODE.soil then
		nRet = nDamPoint * wind * 0.9 - nDamPoint * soil * 0.1 - nDamPoint * fire * 0.9
	elseif byTolType == TOL_CODE.wind then
		nRet = nDamPoint * water * 0.9 - nDamPoint * wind * 0.1 - nDamPoint * soil * 0.9
	else
	end

	return math.floor(nRet)
end

---@param pAttacker CCharacter
---@param nAttPnt integer
---@param nAttPart integer
---@param nTolType integer
---@param pDst CCharacter
---@param bBackAttack boolean
---@return integer
function sirinCharacterMgr.GetAttackDamPoint(pAttacker, nAttPnt, nAttPart, nTolType, pDst, bBackAttack)
	local fDefPnt = 0.0
	local nTolFc = GetTotalTol(pDst, nTolType, nAttPnt)
	local nAttakedPart = nAttPart

	if not pDst.m_EP:GetEff_State(_EFF_STATE.Dst_No_Def) then
		fDefPnt, nAttakedPart = pDst:GetDefFC(nAttPart, pAttacker)

		if pDst.m_ObjID.m_byID == ID_CHAR.monster then
			local bRet, nOutValue = Sirin.mainThread.objectToMonster(pDst):GetViewAngleCap(1)

			if bRet and nOutValue > 0 and not (nOutValue > 100) then
				fDefPnt = fDefPnt * ( 1.0 - nOutValue / 100.0)
			end
		end
	else
		pDst:SetAttackPart(nAttPart)
	end

	if fDefPnt == -2.0 then
		return -2
	end

	local fDefFacing = pDst:GetDefFacing(nAttakedPart)
	local fDefGap = pDst:GetDefGap(nAttakedPart)

	if nAttakedPart == 5 then
		if fDefFacing > pDst:GetDefFacing(nAttPart) then
			fDefFacing = pDst:GetDefFacing(nAttPart)
		end
		if pDst:GetDefGap(nAttPart) > fDefGap then
			fDefGap = pDst:GetDefGap(nAttPart)
		end
	end

	if fDefPnt < 1.0 then
		fDefPnt = 1.0
	end

	local fStdAttFc = 0.0
	local fSceDstFc = 0.0

	local fAveAdj = (fDefGap + pAttacker:GetWeaponAdjust()) / 2.0
	local fDono1 = fDefFacing - 1.0

	if fDono1 == 0.0 then
		fStdAttFc = 0.0
	else
		fStdAttFc = (fDefFacing * fDefPnt * fDefGap - fDefPnt) / fDono1
	end

	local fDono2 = fStdAttFc - fDefPnt * fAveAdj

	if fDono2 == 0.0 then
		fSceDstFc = 0.0
	else
		fSceDstFc = (fStdAttFc - fDefPnt) / fDono2
	end

	local fProp = 1.2

	if nTolType == TOL_CODE.nothing
		or nTolType == -1 then -- // fix of all melee have element 20% attack bonus
		fProp = 1.0
	end

	local nDamage = math.floor((nAttPnt * fProp + nTolFc - fDefPnt * fAveAdj) * fSceDstFc)
	-- print(string.format("%d %.3f %d %.4f %.4f %.4f %d", nAttPnt, fProp, nTolFc, fDefPnt, fAveAdj, fSceDstFc, nDamage))

	if nDamage < 1 then
		nDamage = 1
	end

	if pDst.m_ObjID.m_byID == ID_CHAR.player and nDamage >= 1 and nDamage <= 300 and pDst:GetLevel() >= 30 then
		nDamage = math.random(1, 300)
	end

	return nDamage
end

return sirinCharacterMgr
