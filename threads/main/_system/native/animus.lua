local _EFF_HAVE = _EFF_HAVE
local _EFF_PLUS = _EFF_PLUS
local _EFF_RATE = _EFF_RATE
local _EFF_STATE = _EFF_STATE
local math = math

local baseToMonsterCharacter = Sirin.mainThread.baseToMonsterCharacter
local objectToCharacter = Sirin.mainThread.objectToCharacter
local objectToPlayer = Sirin.mainThread.objectToPlayer
local objectToMonster = Sirin.mainThread.objectToMonster
local sendBuf = Sirin.mainThread.CLuaSendBuffer.Instance()

---@type table
local sirinAnimusMgr = {}

---@param pAnimus CAnimus
---@param pAT sirinCAttack
function sirinAnimusMgr.CalcAttExpForPlayer(pAnimus, pAT)
	if pAnimus:IsInTown() then
		return
	end

	local pPlayer = pAnimus.m_pMaster
	local nAnimusLv = pAnimus:GetLevel()
	local bExpForAnimus = true

	if nAnimusLv - 1 >= 50 and pPlayer:GetLevel() < nAnimusLv - 1 then
		bExpForAnimus = false
	end

	for _,d in ipairs (pAT.m_DamList) do
		repeat
			local pDst = d.m_pChar
			local nDam = d.m_nDamage
			local nDstLv = pDst:GetLevel()
			local bExpForMaster, bGetAttExp = PlayerMgr.isPassExpLimitLvDiff(pPlayer, nDstLv)

			if (not bExpForMaster and not bExpForAnimus) or math.abs(nAnimusLv - nDstLv) > 10 or pDst.m_ObjID.m_byID ~= ID_CHAR.monster or nDam < 1 then
				break
			end

			local pMonFld = baseToMonsterCharacter(pDst.m_pRecordSet)
			local nHPLeft = pDst:GetHP() - nDam

			if pMonFld.m_bMonsterCondition then -- CMonster::IsBossMonster()
				bGetAttExp = false
			end

			if bGetAttExp and bExpForAnimus then
				local nHPConsumed = nDam

				if nHPLeft < 0 then
					nHPConsumed = pDst:GetHP()
				end

				pAnimus:AlterExp(math.floor(pMonFld.m_fExt * 0.7 * nHPConsumed / pMonFld.m_fMaxHP + nDstLv))
			end

			if nHPLeft < 0 then
				nHPLeft = 0
			end

			if nHPLeft == 0 then
				local fExp = pMonFld.m_fExt * 0.3
				local pMon = objectToMonster(pDst)

				if (pMon.m_nCommonStateChunk >> 2) & 7 == 4 then -- CMonster::GetEmotionState()
					fExp = pMonFld.m_fExt * 0.5
				end

				if pPlayer.m_pPartyMgr:IsPartyMode() then
					local pPartyList = pPlayer:_GetPartyMemberInCircle(true)

					if #pPartyList > 0 then
						fExp = fExp * ExpDivUnderParty_Kill[#pPartyList]
					end

					local nTotalLevel = 0
					---@type table<integer, integer>
					local nPartyLvWeight = {}

					for k,v in pairs(pPartyList) do
						nPartyLvWeight[k] = v:GetLevel() ^ 3
						nTotalLevel = nTotalLevel + nPartyLvWeight[k]
					end

					for k,v in pairs(pPartyList) do
						local fPartyExp =  fExp * nPartyLvWeight[k] / nTotalLevel

						if fPartyExp >= 1.0 then
							if IsSameObject(v, pPlayer) then
								if bExpForAnimus then
									pAnimus:AlterExp(math.floor(fPartyExp / 500 + nDstLv))
								end
							else

							end

							if (SERVER_AOP and bExpForMaster) or not SERVER_AOP then
								if v:IsRidingUnit() then
									if SERVER_AOP then
										v:AlterExp(fPartyExp, false, false, false)
									end

									v:Emb_AlterStat(MTY_CODE.special, 0, math.floor(fPartyExp / 180 + nDstLv), 0, "Lua. sirinAnimusMgr.calcAttExpForPlayer() -- 1", true)
								else
									v:AlterExp(fPartyExp, false, false, false)
								end
							end

							if SERVER_AOP and not IsSameObject(v, pPlayer) and v.m_pRecalledAnimusChar then
								v.m_pRecalledAnimusChar:AlterExp(math.floor(fPartyExp / 5000 + nDstLv))
							end
						end
					end
				else
					if SERVER_AOP and bExpForMaster then
						if pPlayer:IsRidingUnit() then
							if SERVER_AOP then
								pPlayer:AlterExp(fExp, false, false, false)
							end

							pPlayer:Emb_AlterStat(MTY_CODE.special, 0, math.floor(fExp / 180 + nDstLv), 0, "Lua. sirinAnimusMgr.calcAttExpForPlayer() -- 2", true)
						else
							pPlayer:AlterExp(fExp, false, false, false)
						end
					end

					if (SERVER_AOP and bExpForAnimus) or not SERVER_AOP then
						pAnimus:AlterExp(math.floor(fExp / 500 + nDstLv))
					end
				end
			end

		until true
	end
end

---@param pAnimus CAnimus
---@return integer
function sirinAnimusMgr.GetAttackPart(pAnimus)
	local r = math.random(0, 99)

	if r <= 20 then
		return 4
	elseif r <= 43 then
		return 0
	elseif r <= 65 then
		return 1
	elseif r <= 83 then
		return 2
	else
		return 3
	end
end

---@param pAnimus CAnimus
---@return boolean
function sirinAnimusMgr.IsValidTarget(pAnimus)
	local pTarget = pAnimus.m_pTarget

	repeat
		if not pTarget or not pAnimus.m_pMaster then
			break
		end

		if not pTarget.m_bLive or pTarget.m_bCorpse then
			break
		end

		if pTarget.m_pCurMap ~= pAnimus.m_pCurMap then
			break
		end

		if pTarget.m_wMapLayerIndex ~= pAnimus.m_wMapLayerIndex then
			break
		end

		if pTarget.m_dwCurSec == 0xFFFFFFFF or pAnimus.m_dwCurSec == 0xFFFFFFFF then
			break
		end

		if pAnimus.m_byRoleCode ~= 3 then
			if pAnimus.m_pTarget:GetObjRace() == pAnimus:GetObjRace() then
				local pTarPlayer = objectToPlayer(pTarget)

				if pTarget.m_ObjID.m_byID ~= ID_CHAR.player or (not pTarPlayer:IsPunished(1, false) and not pAnimus.m_pMaster:IsChaosMode()) then
					break
				end
			end

			if not pTarget:IsBeAttackedAble(true) then
				break
			end

			if pTarget.m_bObserver then
				break
			end

			if pTarget:GetStealth(true) then
				break
			end

			if (pAnimus:IsInTown() or pTarget:IsInTown()) and not pTarget:IsAttackableInTown() then
				break
			end
		else
			local pTarPlayer = objectToPlayer(pTarget)

			if pAnimus.m_pTarget:GetObjRace() ~= pAnimus:GetObjRace() or pTarget.m_ObjID.m_byID ~= ID_CHAR.player or (not IsSameObject(pTarget, pAnimus.m_pMaster) and (pTarPlayer:IsPunished(1, false) or pAnimus.m_pMaster:IsChaosMode())) then
				break
			end
		end

		return true

	until true

	return false
end

---@param pAnimus CAnimus
---@param pDst CCharacter
---@param byPart integer
---@param nSkillIndex integer
---@return sirinCAttack
function sirinAnimusMgr.make_gen_attack_param(pAnimus, pDst, byPart, nSkillIndex)
	local pAT = SirinCAttack:new()
	pAT.m_pAttChar = pAnimus
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst
	local pDstPlayer = objectToPlayer(pDst)

	if not pDst or pDst.m_ObjID.m_byID ~= ID_CHAR.player or pDstPlayer.m_byDamagePart == 255 then
		pAP.nPart = byPart
	else
		pAP.nPart = pDstPlayer.m_byDamagePart
	end

	pAP.nClass = pAnimus.m_byRoleCode == 1 and 0 or 1
	local sk = pAnimus:m_Skill_get(nSkillIndex)
	pAP.nTol = sk.m_Element
	pAP.nMinAF = sk.m_MinDmg
	pAP.nMaxAF = sk.m_MaxDmg

	if pAnimus.m_byRoleCode == 4 then
		pAP.nMaxAF = pAP.nMaxAF * pAnimus.m_pMaster.m_EP:GetEff_Rate(_EFF_RATE.Fg_Animus)
	end

	pAP.nMinSel = sk.m_MinProb
	pAP.nMaxSel = sk.m_MaxProb

	if pAnimus.m_byRoleCode == 2 then
		pAP.nMaxSel = pAP.nMaxSel - pAnimus.m_pMaster.m_EP:GetEff_Plus(_EFF_PLUS.Fg_Crt)
		pAP.nAttactType = 6
		pAP.nExtentRange = 15

		if pDst then
			pAP.fArea_x = pDst.m_fCurPos_x
			pAP.fArea_y = pDst.m_fCurPos_y
			pAP.fArea_z = pDst.m_fCurPos_z
		end
	end

	pAP.nMaxAttackPnt = pAnimus.m_nMaxAttackPnt

	return pAT
end

---@param pAnimus CAnimus
---@param nSkill integer
---@return boolean
function sirinAnimusMgr.Attack(pAnimus, nSkill)
	local pTarget = pAnimus.m_pTarget

	repeat
		if not pTarget then
			break
		end

		--if not sirinAnimusMgr.IsValidTarget(pAnimus) then break end -- double unnecessary check. already checked in CAnimus::Action()

		local nRet = pAnimus.m_pCurMap.m_Level.mBsp:CanYouGoThere(pAnimus.m_fCurPos_x, pAnimus.m_fCurPos_y, pAnimus.m_fCurPos_z, pTarget.m_fCurPos_x, pTarget.m_fCurPos_y, pTarget.m_fCurPos_z)

		if nRet == 0 then
			break
		end

		local sk = pAnimus:m_Skill_get(nSkill)

		if sk.m_Type == 0 then
			local pAT = sirinAnimusMgr.make_gen_attack_param(pAnimus, pTarget, sirinAnimusMgr.GetAttackPart(pAnimus), nSkill)
			pAT:AttackGen(false, false)
			--[[
			struct _attack_gen_result_zocl
			{
				struct _dam_list
				{
					uint8_t byDstID;
					uint32_t dwDstSerial;
					uint16_t wDamage;
					bool bActive;
					uint16_t wActiveDamage;
				};

				uint8_t byAtterID;
				uint32_t dwAtterSerial;
				uint8_t byAttackPart;
				uint16_t wBulletIndex;
				bool bCritical;
				bool bWPActive;
				uint8_t byListNum;
				_dam_list DamList[32];
			};
			--]]

			sendBuf:Init()
			sendBuf:PushUInt8(pAnimus.m_ObjID.m_byID)
			sendBuf:PushUInt32(pAnimus.m_dwObjSerial)
			sendBuf:PushInt8(pAT.m_pp.nPart)
			sendBuf:PushInt16(-1)
			sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
			sendBuf:PushUInt8(0)
			sendBuf:PushUInt8(#pAT.m_DamList)

			for _,d in ipairs(pAT.m_DamList) do
				sendBuf:PushUInt8(d.m_pChar.m_ObjID.m_byID)
				sendBuf:PushUInt32(d.m_pChar.m_dwObjSerial)

				if d.m_nDamage < 0 then
					sendBuf:PushInt16(d.m_nDamage)
				else
					sendBuf:PushUInt16(d.m_nDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
				end

				sendBuf:PushUInt8(0)
				sendBuf:PushUInt16(0)
			end

			pAnimus:CircleReport(5, 7, sendBuf, false)

			if not pAT.m_bFailure and pAnimus.m_byRoleCode ~= 1 then
				sirinAnimusMgr.CalcAttExpForPlayer(pAnimus, pAT)
			end

			local nLv = pAnimus:GetLevel()

			for _,d in ipairs(pAT.m_DamList) do
				d.m_pChar:SetDamage(d.m_nDamage, pAnimus, nLv, pAT.m_bIsCrtAtt, -1, 0, true)
			end
		end

		return true

	until true

	pAnimus.m_pTarget = nil

	return false
end

---@param pSkill SKILL
---@param fDmgRate number
---@return integer
function sirinAnimusMgr.SKILL__GetDmg(pSkill, fDmgRate)
	local ret = 0

	repeat
		local stdDmg = pSkill.m_StdDmg * fDmgRate
		local minDmg = pSkill.m_MinDmg
		local maxDmg = pSkill.m_MaxDmg
		local tmp = stdDmg * 0.9

		if stdDmg - tmp <= 0 then
			minDmg = 0
		else
			minDmg = math.random(0, 0x7FFF) % (stdDmg - tmp) + tmp
		end

		maxDmg = 2 * stdDmg - minDmg

		local nCrtAF = math.floor(maxDmg * (maxDmg + 125) / (maxDmg + 50) + 0.5)

		pSkill.m_IsCritical = 0

		if stdDmg == minDmg or maxDmg == stdDmg then
			break
		end

		local rnd = math.random(0, 99)

		if rnd > pSkill.m_MinProb + pSkill.m_MaxProb then
			pSkill.m_IsCritical = 1
			ret = nCrtAF
		elseif rnd > pSkill.m_MinProb then
			ret = math.floor(stdDmg + math.random(0, 0x7FFF) % (maxDmg - stdDmg))
		else
			ret = math.floor(minDmg + math.random(0, 0x7FFF) % (stdDmg - minDmg))
		end
	until true

	return ret
end

---@param pAnimus CAnimus
---@param nSkill integer
---@return boolean
function sirinAnimusMgr.Heal(pAnimus, nSkill)
	repeat
		local pHealChar = pAnimus.m_pMaster

		if pAnimus.m_pTarget then
			if pAnimus.m_pTarget.m_ObjID.m_byID ~= ID_CHAR.player then
				break
			end

			local pTarPlayer = objectToPlayer(pAnimus.m_pTarget)

			if pTarPlayer.m_bInGuildBattle and pAnimus.m_pMaster.m_bInGuildBattle then
				if pTarPlayer.m_byGuildBattleColorInx ~= pAnimus.m_pMaster.m_byGuildBattleColorInx then
					break
				end

				if pTarPlayer.m_bTakeGravityStone then
					break
				end
			elseif pTarPlayer.m_bInGuildBattle or pAnimus.m_pMaster.m_bInGuildBattle then
				break
			elseif pAnimus:GetObjRace() ~= pTarPlayer:GetObjRace() then
				break
			end

			pHealChar = pTarPlayer
		end

		pAnimus.m_pTarget = pAnimus.m_pMaster

		local haveHP = pHealChar:GetHP()

		if haveHP <= 0 then
			break
		end

		if haveHP / pHealChar:GetMaxHP() >= 1 then
			break
		end

		local nAddHP = sirinAnimusMgr.SKILL__GetDmg(pAnimus:m_Skill_get(0), pAnimus.m_pMaster.m_EP:GetEff_Rate(_EFF_RATE.Fg_Rev))

		if nAddHP <= 0 then
			break
		end

		--[[
		struct _animus_act_heal_inform_zocl
		{
		  unsigned int dwAnimusSerial;
		  unsigned int dwDstSerial;
		  unsigned __int16 wAddHP;
		};
		--]]

		sendBuf:Init()
		sendBuf:PushUInt32(pAnimus.m_dwObjSerial)
		sendBuf:PushUInt32(pHealChar.m_dwObjSerial)
		sendBuf:PushUInt16(nAddHP > 0xFFFF and 0xFFFF or nAddHP)
		pAnimus:CircleReport(22, 14, sendBuf, false)

		pHealChar:SetHP(haveHP + nAddHP, false)

		sendBuf:Init()
		sendBuf:PushUInt16(pHealChar:GetHP() > 0xFFFF and 0xFFFF or pHealChar:GetHP())
		sendBuf:SendBuffer(objectToPlayer(pHealChar), 11, 14)

		if not pAnimus:IsInTown() then
			local nLv = pAnimus:GetLevel()

			if nLv - 1 < 50 or pAnimus.m_pMaster:GetLevel() >= nLv - 1 then
				pAnimus:AlterExp(nAddHP * 2)
			end
		end

		local _10per = math.floor(nAddHP / 10)

		if _10per > 0 then
			pAnimus.m_nHP = pAnimus.m_nHP - _10per

			if pAnimus.m_nHP > 0 then
				pAnimus:AlterHP_MasterReport()
			else
				pAnimus.m_nHP = 0
				pAnimus.m_pMaster.m_byNextRecallReturn = 1
			end
		end

		return true

	until true

	pAnimus.m_pTarget = pAnimus.m_pMaster

	return false
end

---@param pAnimus CAnimus
---@param nPart integer
---@return number
function sirinAnimusMgr.GetDefGap(pAnimus, nPart)
	return pAnimus.m_pRecord.m_fDefGap
end

---@param pAnimus CAnimus
---@param nPart integer
---@return number
function sirinAnimusMgr.GetDefFacing(pAnimus, nPart)
	return pAnimus.m_pRecord.m_fDefFacing
end

---@param pAnimus CAnimus
---@param nAttactPart integer
---@param pAttChar CCharacter
---@return integer nDefFC
---@return integer nConvertPart
function sirinAnimusMgr.GetDefFC(pAnimus, nAttactPart, pAttChar)
	local defFC = pAnimus.m_pRecord.m_nStdDefFc

	if pAnimus.m_byRoleCode == 1 and pAnimus.m_pMaster then
		defFC = math.floor(defFC * pAnimus.m_pMaster.m_EP:GetEff_Rate(_EFF_RATE.Fg_Def))
	end

	return defFC, 0
end

---@param pAnimus CAnimus
---@return number
function sirinAnimusMgr.GetWeaponAdjust(pAnimus)
	return pAnimus.m_pRecord.m_fAttGap
end

return sirinAnimusMgr
