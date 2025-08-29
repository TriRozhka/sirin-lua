local _EFF_RATE = _EFF_RATE
local _EFF_PLUS = _EFF_PLUS
local STORAGE_POS = STORAGE_POS
local TBL_CODE = TBL_CODE
local EFF_CODE = EFF_CODE
local math = math
local et = {} -- empty table (et)

local baseToGuardTowerItem = Sirin.mainThread.baseToGuardTowerItem
local baseToDfnEquipItem = Sirin.mainThread.baseToDfnEquipItem
local baseToWeaponItem = Sirin.mainThread.baseToWeaponItem
local baseToSiegeKitItem = Sirin.mainThread.baseToSiegeKitItem
local baseToSkill = Sirin.mainThread.baseToSkill
local baseToForce = Sirin.mainThread.baseToForce
local baseToBulletItem = Sirin.mainThread.baseToBulletItem
local baseToUnitPart = Sirin.mainThread.baseToUnitPart
local objectToPlayer = Sirin.mainThread.objectToPlayer
local objectToMonster = Sirin.mainThread.objectToMonster
local objectToAnimus = Sirin.mainThread.objectToAnimus
local objectToTower = Sirin.mainThread.objectToTower
local GetItemTableCode = Sirin.mainThread.GetItemTableCode
local sendBuf = Sirin.mainThread.CLuaSendBuffer.Instance()
local g_Main = Sirin.mainThread.g_Main

local CONST_ChipBreakerBonus_Atk = CONST_ChipBreakerBonus_Atk
local CONST_PatriarchBonus_Atk = CONST_PatriarchBonus_Atk
local CONST_AttackCouncilBonus_Atk = CONST_AttackCouncilBonus_Atk

local s_nLimitDist = CONST_nLimitDist
local s_nLimitAngle = CONST_nLimitDist
local s_nLimitRadius = CONST_nLimitRadius

local s_nAddMstFc = {}

for i = 0, 99 do
	s_nAddMstFc[i] = math.floor(math.sqrt((i ^ 3) * 2))
end

---@class (exact) sirin_consume_data
---@field byTableCode integer
---@field wItemIndex integer
---@field nConsumeNum integer
local sirin_consume_data = {}

---@type table<integer, table<integer, table<integer, sirin_consume_data>>>
local consumeListCache = {
	[EFF_CODE.skill] = {},
	[EFF_CODE.force] = {},
	[EFF_CODE.class] = {},
	[EFF_CODE.bullet] = {},
}

---@class (exact) sirin_consume_item
---@field pCon _STORAGE_LIST___db_con
---@field dwDur integer
---@field bOverlap boolean
local sirin_consume_item = {}

---@class (exact) sirinCPlayerAttack : sirinCAttack
---@field m_pAttPlayer CPlayer
local sirinCPlayerAttack = SirinCAttack:new()

---@return sirinCPlayerAttack self
function sirinCPlayerAttack:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

---@param bUseEffBullet boolean
function sirinCPlayerAttack:_CalcSkillAttPnt(bUseEffBullet)
	local pSkillFld = baseToSkill(self.m_pp.pFld)
	local fR = 0.847
	local fRLf = 0.86472
	local fRMf = 0.28824
	local fRLVf = self.m_pp.nLevel + (7 - self.m_pp.nLevel) * 0.5
	local l_fConst = pSkillFld.m_fAttFormulaConstant
	local l_nLvConst = pSkillFld:m_nAttConstant_get(self.m_pp.nLevel - 1);
	local l_nMinAf = 0
	local l_nMaxAf = 5

	if bUseEffBullet then
		l_nMinAf = l_nLvConst / 788 * (self.m_pp.nMinAFPlus * (fR + (fRLVf / 7 * fRLf) + (self.m_pp.nMastery / 99 * fRMf)) * l_fConst ) + 0.5
		l_nMaxAf = l_nLvConst / 788 * (self.m_pp.nMaxAFPlus * (fR + (fRLVf / 7 * fRLf) + (self.m_pp.nMastery / 99 * fRMf)) * l_fConst ) + 0.5
	else
		l_nMinAf = l_nLvConst / 788 * (self.m_pp.nMinAF * (fR + (fRLVf / 7 * fRLf) + (self.m_pp.nMastery / 99 * fRMf)) * l_fConst ) + 0.5
		l_nMaxAf = l_nLvConst / 788 * (self.m_pp.nMaxAF * (fR + (fRLVf / 7 * fRLf) + (self.m_pp.nMastery / 99 * fRMf)) * l_fConst ) + 0.5
	end

	if l_nMaxAf < 0 then
		local errStr = string.format("Skill Attack Error : Skill(%s), SIndex(%d), l_fConst(%f), l_nLvConst(%d), nMastery(%d), nMaxAF(%d), nMinAF(%d)\n",
			pSkillFld.m_strCode,
			pSkillFld.m_dwIndex,
			l_fConst,
			l_nLvConst,
			self.m_pp.nMastery,
			bUseEffBullet and self.m_pp.nMaxAFPlus or self.m_pp.nMaxAF,
			bUseEffBullet and self.m_pp.nMinAFPlus or self.m_pp.nMinAF
		)
		Sirin.mainThread.g_Main.m_logSystemError:Write(errStr)
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, errStr)
		l_nMinAf = 1
		l_nMaxAf = 1
	end

	local l_nCrtAf = l_nMaxAf * ((125 + l_nMaxAf) / (50 + l_nMaxAf)) + 0.5

	if self.m_pp.nMaxAttackPnt > 0 then
		return l_nCrtAf
	elseif self.m_pp.nMaxAttackPnt < 0 then
		return l_nMinAf
	else
		local l_nAttBlk = math.floor((l_nMinAf + l_nMaxAf) / 2 + 0.5)
		local belowAverage = self.m_pp.nMinSel - self.m_pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.GE_CrtExt)
		local aboveAverage = self.m_pp.nMaxSel + self.m_pp.nMinSel - self.m_pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.GE_CrtExt)

		if self.m_pp.pDst and not IsSameObject(self.m_pAttChar, self.m_pp.pDst) then
			local tmp = self.m_pp.pDst.m_EP:GetEff_Plus(_EFF_PLUS.All_AvdCrt) + self:MonsterCritical_Exception_Rate(self.m_pp.pDst, self.m_pp.bBackAttack)
			belowAverage = belowAverage + tmp
			aboveAverage = aboveAverage + tmp
		end

		if belowAverage < 0 then
			belowAverage = 0
		end

		if aboveAverage < 0 then
			aboveAverage = 0
		end

		local rnd = self.m_pAttChar.m_rtPer100:GetRand()

		if rnd <= belowAverage then
			if l_nAttBlk - l_nMinAf <= 0 then
				return l_nMinAf
			else
				return l_nMinAf + math.random(0, 0x7FFF) % (l_nAttBlk - l_nMinAf)
			end
		elseif rnd <= aboveAverage then
			if l_nMaxAf - l_nAttBlk <= 0 then
				return l_nAttBlk
			else
				return l_nAttBlk + math.random(0, 0x7FFF) % (l_nMaxAf - l_nAttBlk)
			end
		else
			self.m_bIsCrtAtt = true
			return l_nCrtAf
		end
	end
end

function sirinCPlayerAttack:WPActiveAttackSkill()
	--self.m_pAttChar:BreakStealth() -- not needed here
	local pDst = self.m_pp.pDst
	local pSkillFld = baseToSkill(self.m_pp.pFld)
	local attPnt = self.m_pp.nAddAttPnt + self:_CalcSkillAttPnt(false)

	if self.m_pp.nWpType == 7 then
		attPnt = attPnt * self.m_pAttChar.m_EP:GetEff_Rate(_EFF_RATE.Fg_Lcr)
	else
		attPnt = attPnt * self.m_pAttChar.m_EP:GetEff_Rate(_EFF_RATE.SK_AttFc_ + self.m_pp.nClass)
	end

	-- it is missing in original code. replace 'false' with 'true' if you want to enable.
	if false and (Sirin.mainThread.g_HolySys:GetDestroyerSerial() == self.m_pAttChar.m_dwObjSerial or self.m_pAttPlayer.m_Param.m_bLastAttBuff) then
		attPnt = attPnt * CONST_ChipBreakerBonus_Atk
	end

	if not self.m_pAttPlayer.m_bInGuildBattle then
		local byBossType = Sirin.mainThread.CPvpUserAndGuildRankingSystem.Instance():GetBossType(self.m_pAttPlayer:GetObjRace(), self.m_pAttPlayer.m_dwObjSerial)

		if byBossType == 0 then
			attPnt = attPnt * CONST_PatriarchBonus_Atk
		elseif byBossType == 2 or byBossType == 6 then
			attPnt = attPnt * CONST_AttackCouncilBonus_Atk
		end
	end

	if pDst and (self.m_pp.nAttactType == 0 or self.m_pp.nAttactType == 1 or self.m_pp.nAttactType == 2 or self.m_pp.nAttactType == 3) then
		self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, math.floor(attPnt), self.m_pp.nPart, self.m_pp.nTol, pDst, self.m_pp.bBackAttack) }
		self.m_nDamagedObjNum = 1
	elseif self.m_pp.nAttactType == 5 then
		self:FlashDamageProc(s_nLimitDist[pSkillFld.m_nLv + 1], math.floor(attPnt), s_nLimitAngle[1][pSkillFld.m_nLv + 1], 0, false)
	elseif self.m_pp.nAttactType == 4 or self.m_pp.nAttactType == 6 then
		self:AreaDamageProc(s_nLimitRadius[pSkillFld.m_nLv + 1], math.floor(attPnt), self.m_pp.fArea_x, self.m_pp.fArea_y, self.m_pp.fArea_z, 0, false)
	elseif self.m_pp.nAttactType == 7 then
		self:SectorDamageProc(math.floor(attPnt), s_nLimitAngle[1][pSkillFld.m_nLv + 1], self.m_pp.nShotNum, self.m_pp.nExtentRange, 0, false)
	else
		return
	end

	self:CalcAvgDamage()
end

function sirinCPlayerAttack:WPActiveAttackForce()
	local pDst = self.m_pp.pDst
	local pForceFld = baseToForce(self.m_pp.pFld)
	local attPnt = self.m_pp.nAddAttPnt + self:_CalcForceAttPnt(false)
	attPnt = attPnt * self.m_pAttChar.m_EP:GetEff_Rate(_EFF_RATE.FC_AttFc)

	-- it is missing in original code. replace 'false' with 'true' if you want to enable.
	if false and (Sirin.mainThread.g_HolySys:GetDestroyerSerial() == self.m_pAttChar.m_dwObjSerial or self.m_pAttPlayer.m_Param.m_bLastAttBuff) then
		attPnt = attPnt * CONST_ChipBreakerBonus_Atk
	end

	if not self.m_pAttPlayer.m_bInGuildBattle then
		local byBossType = Sirin.mainThread.CPvpUserAndGuildRankingSystem.Instance():GetBossType(self.m_pAttPlayer:GetObjRace(), self.m_pAttPlayer.m_dwObjSerial)

		if byBossType == 0 then
			attPnt = attPnt * CONST_PatriarchBonus_Atk
		elseif byBossType == 2 or byBossType == 6 then
			attPnt = attPnt * CONST_AttackCouncilBonus_Atk
		end
	end

	if pForceFld.m_nEffectGroup >= 0 and pForceFld.m_nEffectGroup <= 2 then
		if pDst then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, math.floor(attPnt), self.m_pp.nPart, self.m_pp.nTol, pDst, self.m_pp.bBackAttack) }
			self.m_nDamagedObjNum = 1
		end
	elseif pForceFld.m_nEffectGroup == 5 then
		self:FlashDamageProc(s_nLimitDist[pForceFld.m_nLv + 1], math.floor(attPnt), s_nLimitAngle[2][pForceFld.m_nLv + 1], 0, false)
	elseif self.m_pp.nAttactType == 4 or self.m_pp.nAttactType == 6 then
		self:AreaDamageProc(s_nLimitRadius[pForceFld.m_nLv + 1], math.floor(attPnt), self.m_pp.fArea_x, self.m_pp.fArea_y, self.m_pp.fArea_z, 0, false)
	else
		return
	end

	self:CalcAvgDamage()
end

---@param bUseEffBullet boolean
function sirinCPlayerAttack:AttackSkill(bUseEffBullet)
	local bSucc = true
	self.m_pAttChar:BreakStealth()
	local pDst = self.m_pp.pDst

	if pDst then
		local bIsCounterAttack = false

		if pDst.m_EP:GetEff_State(_EFF_STATE.Res_Att) then
			bIsCounterAttack = true
		else
			local fCounterRate = pDst.m_EP:GetEff_Plus(_EFF_PLUS.Avoid_Con)

			if fCounterRate > 0 and math.random(0,99) < fCounterRate then
				bIsCounterAttack = true
			end
		end

		if bIsCounterAttack then
			if not self.m_pp.bPassCount and not self.m_pp.nClass and pDst:GetWeaponClass() == 0 then
				local fCounterAttDist = pDst:GetAttackRange() + self.m_pAttChar:GetWidth() / 2 + pDst.m_EP:GetEff_Plus(_EFF_PLUS.GE_Att_Dist_)

				if fCounterAttDist >= GetSqrt(pDst.m_fCurPos_x, pDst.m_fCurPos_z, self.m_pAttChar.m_fCurPos_x, self.m_pAttChar.m_fCurPos_z) then
					self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = -1 }
					self.m_nDamagedObjNum = 1
					CharacterMgr.SendMsg_AttackActEffect(self.m_pAttChar, 0, pDst)
					return
				end

				self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
				self.m_nDamagedObjNum = 1
				return
			end

			if pDst.m_EP:GetEff_Plus(_EFF_PLUS.Avoid_Con) > 0 then
				self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
				self.m_nDamagedObjNum = 1
				return
			end
		end

		if pDst.m_EP:GetEff_State(_EFF_STATE.Abs_Avd) then
			bSucc = false
		else
			local nSuccRate = self.m_pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.SK_HitRate) + 100 - pDst:GetAvoidRate()

			if self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.player then
				nSuccRate = nSuccRate + self.m_pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.Potion_Inc_All_Hit)
			end

			if nSuccRate < 0 then
				nSuccRate = 0
			elseif nSuccRate > 100 then
				nSuccRate = 100
			end

			if math.floor(nSuccRate) <= math.random(0, 99) then
				bSucc = false
			end
		end

		if not bSucc then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
			self.m_nDamagedObjNum = 1
			return
		end
	end

	local attPnt = self.m_pp.nAddAttPnt + self:_CalcSkillAttPnt(false)
	local attPntEff = self.m_pp.nAddAttPnt + self:_CalcSkillAttPnt(true)

	if self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.player then
		local pSrcPlyer = objectToPlayer(self.m_pAttChar)

		if Sirin.mainThread.g_HolySys:GetDestroyerSerial() == self.m_pAttChar.m_dwObjSerial or pSrcPlyer.m_Param.m_bLastAttBuff then
			attPnt = attPnt * CONST_ChipBreakerBonus_Atk
			attPntEff = attPntEff * CONST_ChipBreakerBonus_Atk
		end

		if not pSrcPlyer.m_bInGuildBattle then
			local byBossType = Sirin.mainThread.CPvpUserAndGuildRankingSystem.Instance():GetBossType(pSrcPlyer:GetObjRace(), pSrcPlyer.m_dwObjSerial)

			if byBossType == 0 then
				attPnt = attPnt * CONST_PatriarchBonus_Atk
				attPntEff = attPntEff * CONST_PatriarchBonus_Atk
			elseif byBossType == 2 or byBossType == 6 then
				attPnt = attPnt * CONST_AttackCouncilBonus_Atk
				attPntEff = attPntEff * CONST_AttackCouncilBonus_Atk
			end
		end
	end

	if self.m_pp.nWpType == 7 then
		local bns = self.m_pAttChar.m_EP:GetEff_Rate(_EFF_RATE.Fg_Lcr)
		attPnt = attPnt * bns
		attPntEff = attPntEff * bns
	else
		local bns = self.m_pAttChar.m_EP:GetEff_Rate(self.m_pp.nClass)
		attPnt = attPnt * bns
		attPntEff = attPntEff * bns
	end

	local pSkillFld = baseToSkill(self.m_pp.pFld)
	local nAttType = (self.m_pp.byEffectCode == EFF_CODE.skill and pSkillFld:m_nAttType_get(self.m_pp.nLevel - 1) or pSkillFld:m_nAttType_get(0))

	if pDst and nAttType >= 0 and nAttType <=3 then
		self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, bUseEffBullet and math.floor(attPntEff) or math.floor(attPnt), self.m_pp.nPart, self.m_pp.nTol, pDst, self.m_pp.bBackAttack) }
		self.m_nDamagedObjNum = 1
	elseif nAttType == 4 or nAttType == 6 then
		self:AreaDamageProc(s_nLimitRadius[pSkillFld.m_nLv + 1], math.floor(attPnt), self.m_pp.fArea_x, self.m_pp.fArea_y, self.m_pp.fArea_z, math.floor(attPntEff), bUseEffBullet)
	elseif nAttType == 5 then
		self:FlashDamageProc(s_nLimitDist[pSkillFld.m_nLv + 1], math.floor(attPnt), s_nLimitAngle[1][pSkillFld.m_nLv + 1], math.floor(attPntEff), bUseEffBullet)
	elseif nAttType == 7 then
		self:SectorDamageProc(math.floor(attPnt), s_nLimitAngle[1][pSkillFld.m_nLv + 1], self.m_pp.nShotNum, self.m_pp.nExtentRange, math.floor(attPntEff), bUseEffBullet)
	else
		return
	end

	self:CalcAvgDamage()
end

---@param fBulletGARate number
function sirinCPlayerAttack:AttackUnit(fBulletGARate)
	local bSucc = true
	self.m_pAttChar:BreakStealth()
	local pDst = self.m_pp.pDst
	local pAttPlayer = self.m_pAttPlayer
	local pWeaponFld = baseToUnitPart(self.m_pp.pFld)
	local nAttType = pWeaponFld.m_nEffectGroup

	if pDst and nAttType ~= 4 then
		local bIsCounterAttack = false

		if pDst.m_EP:GetEff_State(_EFF_STATE.Res_Att) then
			bIsCounterAttack = true
		else
			local fCounterRate = pDst.m_EP:GetEff_Plus(_EFF_PLUS.Avoid_Con)

			if fCounterRate > 0 and math.random(0,99) < fCounterRate then
				bIsCounterAttack = true
			end
		end

		if bIsCounterAttack then
			if not self.m_pp.bPassCount and not self.m_pp.nClass and pDst:GetWeaponClass() == 0 then
				local fCounterAttDist = pDst:GetAttackRange() + self.m_pAttChar:GetWidth() / 2 + pDst.m_EP:GetEff_Plus(_EFF_PLUS.GE_Att_Dist_)

				if fCounterAttDist >= GetSqrt(pDst.m_fCurPos_x, pDst.m_fCurPos_z, self.m_pAttChar.m_fCurPos_x, self.m_pAttChar.m_fCurPos_z) then
					self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = -1 }
					self.m_nDamagedObjNum = 1
					CharacterMgr.SendMsg_AttackActEffect(self.m_pAttChar, 0, pDst)
					return
				end

				self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
				self.m_nDamagedObjNum = 1
				return
			end

			if pDst.m_EP:GetEff_Plus(_EFF_PLUS.Avoid_Con) > 0 then
				self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
				self.m_nDamagedObjNum = 1
				return
			end
		end

		if pDst.m_EP:GetEff_State(_EFF_STATE.Abs_Avd) then
			bSucc = false
		else
			local nSuccRate = self.m_pAttChar:GetGenAttackProb(pDst, self.m_pp.nPart, self.m_pp.bBackAttack)

			if nSuccRate <= math.random(0, 99) then
				bSucc = false
			end
		end

		if not bSucc then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
			self.m_nDamagedObjNum = 1
			return
		end

		local attPnt = self.m_pp.nAddAttPnt + self:_CalcGenAttPnt(false)

		if SERVER_AOP and pAttPlayer.m_bGeneratorAttack then
			local atkDif = pAttPlayer.m_pmWpn.nGaMaxAF - pAttPlayer.m_pmWpn.nGaMinAF

			if atkDif <= 0 then
				atkDif = pAttPlayer.m_pmWpn.nGaMinAF
			else
				atkDif = math.random(0, atkDif) + pAttPlayer.m_pmWpn.nGaMinAF + 1
			end

			local atkBns = pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Fg_Unit)

			if not pAttPlayer.m_bInGuildBattle then
				local byBossType = Sirin.mainThread.CPvpUserAndGuildRankingSystem.Instance():GetBossType(pAttPlayer:GetObjRace(), pAttPlayer.m_dwObjSerial)

				if byBossType == 0 then
					atkBns = atkBns + CONST_PatriarchBonus_Atk - 1
				elseif byBossType == 2 or byBossType == 6 then
					atkBns = atkBns + CONST_AttackCouncilBonus_Atk - 1
				end
			end

			pAttPlayer.m_EP.m_bLock = false

			if self.m_pp.nClass == 0 then
				atkBns = atkBns + pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.GE_AttFc_) - 1
			else
				atkBns = atkBns + pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.GA1) - 1
			end

			atkBns = atkBns + pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) - 1
			atkBns = atkBns + pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_AttFc_byMst_Close_Fc) - 1
			atkBns = atkBns + pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_AttFc_byMst_Long_Fc) - 1
			atkBns = atkBns + pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_AttFc_byMst_FC) - 1

			if atkBns < 1 then
				atkBns = 1
			end

			atkDif = atkDif * atkBns
			atkBns = 1

			if self.m_pp.nClass == 0 then
				atkBns = atkBns + pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_Enchant_AttFc_byMst_Close_Fc) - 1
			else
				atkBns = atkBns + pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_Enchant_AttFc_byMst_Long_Fc) - 1
			end

			atkDif = atkDif * atkBns

			pAttPlayer.m_EP.m_bLock = true

			attPnt = attPnt + atkDif
		else -- 2232 or AoP when no mau gen (gen from AoP)
			attPnt = attPnt * pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Fg_Unit)

			if not pAttPlayer.m_bInGuildBattle then
				local byBossType = Sirin.mainThread.CPvpUserAndGuildRankingSystem.Instance():GetBossType(pAttPlayer:GetObjRace(), pAttPlayer.m_dwObjSerial)

				if byBossType == 0 then
					attPnt = attPnt * CONST_PatriarchBonus_Atk
				elseif byBossType == 2 or byBossType == 6 then
					attPnt = attPnt * CONST_AttackCouncilBonus_Atk
				end
			end

			local avgDefFc = 0

			for i = 0, 4 do
				local defFC = pAttPlayer:GetDefFC(i, pAttPlayer)
				avgDefFc = avgDefFc + defFC
			end

			avgDefFc = avgDefFc / 5

			local bnsDef = math.floor(avgDefFc * (pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_AttFc_byMst_Def_Fc) - 1))
			local bnsForce = self:GetAttackFC(pAttPlayer, 2, true, true) * (pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_AttFc_byMst_FC) - 1)
			local bnsMelee = (self:GetAttackFC(pAttPlayer, 0, true, true) + self:GetAttackFC(pAttPlayer, 1, true, true)) * (pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_AttFc_byMst_Close_Fc) - 1)
			local bnsRange = (self:GetAttackFC(pAttPlayer, 0, false, true) + self:GetAttackFC(pAttPlayer, 1, false, true)) * (pAttPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_AttFc_byMst_Long_Fc) - 1)
			attPnt = attPnt + bnsDef + bnsForce + bnsMelee + bnsRange
		end

		if pDst and nAttType >= 0 and nAttType <=3 then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, math.floor(attPnt), self.m_pp.nPart, self.m_pp.nTol, pDst, self.m_pp.bBackAttack) }
			self.m_nDamagedObjNum = 1
		elseif nAttType == 6 then -- fArea was not filled in make_param for unit
			self:AreaDamageProc(s_nLimitRadius[4], math.floor(attPnt), self.m_pp.fArea_x, self.m_pp.fArea_y, self.m_pp.fArea_z, 0, false)
		elseif nAttType == 5 then
			self:FlashDamageProc(s_nLimitDist[4], math.floor(attPnt), s_nLimitAngle[1][4], 0, false)
		elseif nAttType == 7 then
			self:SectorDamageProc(math.floor(attPnt), s_nLimitAngle[1][4], self.m_pp.nShotNum, self.m_pp.nExtentRange, 0, false)
		else
			return
		end

		self:CalcAvgDamage()
	end
end

---@class (exact) sirin_CPartyModeKillMonsterExpNotify
---@field __index table
---@field m_bKillMonster boolean
---@field m_byMemberCnt integer
---@field m_kInfo table<integer, CExpInfo>
local sirin_CPartyModeKillMonsterExpNotify = {
	m_bKillMonster = false,
	m_byMemberCnt = 0,
	m_kInfo = {},
}
Sirin_CPartyModeKillMonsterExpNotify = sirin_CPartyModeKillMonsterExpNotify

---@return sirin_CPartyModeKillMonsterExpNotify self
function sirin_CPartyModeKillMonsterExpNotify:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

---@param pkMember CPlayer
---@param fExp number
---@return boolean
function sirin_CPartyModeKillMonsterExpNotify:Add(pkMember, fExp)
	for _,m in ipairs(self.m_kInfo) do
		if m.m_pkMember.m_ObjID.m_wIndex == pkMember.m_ObjID.m_wIndex then
			m.m_fExp = m.m_fExp + fExp
			return true
		end
	end

	---@type CExpInfo
	local newInfo = {
		m_pkMember = pkMember,
		m_fExp = fExp,
	}
	table.insert(self.m_kInfo, newInfo)
	self.m_byMemberCnt = #self.m_kInfo

	return true
end

function sirin_CPartyModeKillMonsterExpNotify:Notify()
	if self.m_bKillMonster and #self.m_kInfo > 0 then
		for _,m in ipairs(self.m_kInfo) do
			if m.m_pkMember.m_bOper and m.m_fExp ~= 0 then
				sendBuf:Init()
				sendBuf:PushFloat(m.m_fExp)
				sendBuf:SendBuffer(m.m_pkMember, 11, 30)
			end
		end
	end
end

---@param pPlayer CPlayer
---@param pWeaponFld? _WeaponItem_fld
---@param wBulletSerial integer
---@return _STORAGE_LIST___db_con?
---@return _BulletItem_fld?
local function isBulletValidity(pPlayer, pWeaponFld, wBulletSerial)
	local bBulletSucc = false
	local pBulletCon = nil
	local pBulletFld = nil

	repeat
		pBulletCon = pPlayer.m_Param.m_dbEmbellish:GetPtrFromSerial(wBulletSerial)

		if not pBulletCon then
			pPlayer:SendMsg_AdjustAmountInform(STORAGE_POS.embellish, wBulletSerial, 0)
			break
		end

		if pBulletCon.m_byTableCode ~= TBL_CODE.bullet then
			break
		end

		pBulletFld = baseToBulletItem(g_Main:m_tblItemData_get(TBL_CODE.bullet):GetRecord(pBulletCon.m_wItemIndex))

		if not pBulletFld then
			break
		end

		if pBulletFld.m_nUsePCCash == 0 then

		elseif pBulletFld.m_nUsePCCash == 1 then
			if not pPlayer:IsApplyPcbangPrimium() then
				-- CPlayer::SendMsg_PremiumCashItemUse
				sendBuf:Init()
				sendBuf:PushUInt16(0xFFFF)
				sendBuf:SendBuffer(pPlayer, 59, 16)
				--
				break
			end
		else
			break
		end

		if not pWeaponFld then
			break
		end

		if pWeaponFld.m_strBulletType ~= "-1" and not pBulletFld.m_strBulletType:find(pWeaponFld.m_strBulletType) then
			break
		end

		bBulletSucc = true

	until true

	if not bBulletSucc then
		return nil, nil
	end

	return pBulletCon, pBulletFld
end

---@param pPlayer CPlayer
---@param pWeaponFld? _WeaponItem_fld
---@param wEffBtSerial integer
---@return _STORAGE_LIST___db_con?
---@return _BulletItem_fld?
local function isEffBulletValidity(pPlayer, pWeaponFld, wEffBtSerial)
	local bEffBtSucc = false
	local pEffBtCon = nil
	local pEffBtFld = nil

	repeat
		pEffBtCon = pPlayer.m_Param.m_dbEmbellish:GetPtrFromSerial(wEffBtSerial)

		if not pEffBtCon then
			pPlayer:SendMsg_AdjustAmountInform(STORAGE_POS.embellish, wEffBtSerial, 0)
			break
		end

		if pEffBtCon.m_byTableCode ~= TBL_CODE.bullet then
			break
		end

		pEffBtFld = baseToBulletItem(g_Main:m_tblItemData_get(TBL_CODE.bullet):GetRecord(pEffBtCon.m_wItemIndex))

		if not pEffBtFld then
			break
		end

		if pEffBtFld.m_nUsePCCash == 0 then

		elseif pEffBtFld.m_nUsePCCash == 1 then
			if not pPlayer:IsApplyPcbangPrimium() then
				-- CPlayer::SendMsg_PremiumCashItemUse
				sendBuf:Init()
				sendBuf:PushUInt16(0xFFFF)
				sendBuf:SendBuffer(pPlayer, 59, 16)
				--
				break
			end
		else
			break
		end

		if not pWeaponFld then
			break
		end

		if pWeaponFld.m_strEffBulletType ~= "-1" or pEffBtFld.m_strEffBulletType ~= "-1" or not pEffBtFld.m_strEffBulletType:find(pWeaponFld.m_strEffBulletType) then
			break
		end

		bEffBtSucc = true

	until true

	if not bEffBtSucc then
		return nil, nil
	end

	return pEffBtCon, pEffBtFld
end

local sirinPlayerAttack = {}

---@param pPlayer CPlayer
---@param list table<integer, sirin_consume_data>
---@param serials table<integer, integer>
---@return boolean
---@return table<integer, sirin_consume_item>
function sirinPlayerAttack.GetUseConsumeItem(pPlayer, list, serials)
	if #list then
		local r = {}

		for k,v in ipairs(list) do
			if not serials[k] or serials[k] == 0xFFFF then
				return false, et
			end

			local pCon = pPlayer.m_Param.m_dbInven:GetPtrFromSerial(serials[k])

			if not pCon or pCon.m_byTableCode ~= v.byTableCode or pCon.m_wItemIndex ~= v.wItemIndex then
				return false, et
			end

			---@type sirin_consume_item
			local consume = {
				pCon = pCon,
				dwDur = v.nConsumeNum,
				bOverlap = IsOverlapItem(pCon.m_byTableCode),
			}

			if v.nConsumeNum > 0 and IsOverlapItem(pCon.m_byTableCode) then
				if pCon.m_dwDur < v.nConsumeNum then
					return false, et
				end
			end

			table.insert(r, consume)
		end

		return true, r
	else
		return true, et
	end
end

---@param pPlayer CPlayer
---@param damList table<integer, sirin_be_damaged_char>
---@param kPartyExpNotify sirin_CPartyModeKillMonsterExpNotify
---@return integer
function sirinPlayerAttack._check_exp_after_attack(pPlayer, damList, kPartyExpNotify)
	local totalDam = 0

	for _,d in ipairs(damList) do
		if d.m_nDamage > 0 then
			totalDam = totalDam + d.m_nDamage + d.m_nActiveDamage
		end

		if d.m_pChar:IsRewardExp() and d.m_nDamage > 1 then
			PlayerMgr.calcExp(pPlayer, d.m_pChar, d.m_nDamage + d.m_nActiveDamage, kPartyExpNotify)
		end
	end

	return totalDam
end

---@param pPlayer CPlayer
---@param nTotalDam integer
---@param pDst? CCharacter
function sirinPlayerAttack._check_dst_param_after_attack(pPlayer, nTotalDam, pDst)
	local fFPAbsorbRate = pPlayer.m_EP:GetEff_Rate(_EFF_RATE.FP_Absorb)

	if fFPAbsorbRate > 1.0 then
		local fp = nTotalDam * (fFPAbsorbRate - 1.0)
		fp  = fp * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.FP_Potion_Rev) + pPlayer:GetFP()

		if fp > pPlayer:GetMaxFP() then
			fp = pPlayer:GetMaxFP()
		end

		-- CPlayer::SetFP(...)
		if not pPlayer.m_bNeverDie then
			pPlayer.m_Param.m_dbChar.m_dwFP = math.floor(fp)
		end
		--
	end

	local fHPAbsorbRate = pPlayer.m_EP:GetEff_Rate(_EFF_RATE.HP_Absorb)

	if fHPAbsorbRate > 1.0 then
		pPlayer:SetHP(math.floor(nTotalDam * (fHPAbsorbRate - 1.0) * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.HP_Potion_Rev) + pPlayer:GetHP()), false)
	end

	local fSPAbsorbRate = pPlayer.m_EP:GetEff_Rate(_EFF_RATE.SP_Absorb)

	if fSPAbsorbRate > 1.0 then
		local sp = nTotalDam * (fSPAbsorbRate - 1.0)
		sp  = sp * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.SP_Potion_Rev) + pPlayer:GetSP()

		if sp > pPlayer:GetMaxSP() then
			sp = pPlayer:GetMaxSP()
		end

		-- CPlayer::SetSP(...)
		if not pPlayer.m_bNeverDie then
			pPlayer.m_Param.m_dbChar.m_dwSP = math.floor(sp)
		end
		--
	end

	if not pDst then
		return
	end

	local pDstPlayer = objectToPlayer(pDst)

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Dst_Make_Stun) and pDst:GetHP() > 0 and (pDst.m_ObjID.m_byID ~= ID_CHAR.player or not pDstPlayer.m_bInGuildBattle or not pDstPlayer.m_bTakeGravityStone) then
		pDst:SetStun(true)
		pDst:SendMsg_StunInform()
	elseif pPlayer.m_EP:GetEff_Rate(_EFF_RATE.GE_Stun) > 1 then
		local nStunRate = math.floor((pPlayer.m_EP:GetEff_Rate(_EFF_RATE.GE_Stun) - 1) * 100) + 1

		if pDst:GetHP() > 0 and math.random(1000) < nStunRate and (pDst.m_ObjID.m_byID ~= ID_CHAR.player or not pDstPlayer.m_bInGuildBattle or not pDstPlayer.m_bTakeGravityStone) then
			pDst:SetStun(true)
			pDst:SendMsg_StunInform()
		end
	end
end

function sirinPlayerAttack.SendMsg_AttackResult_Error(pPlayer, nErrCode)
	sendBuf:Init()
	sendBuf:PushInt8(nErrCode)
	sendBuf:SendBuffer(pPlayer, 5, 6)
end

---@param pPlayer CPlayer
---@param pAT sirinCAttack
function sirinPlayerAttack.SendMsg_AttackResult_Count(pPlayer, pAT)
	sendBuf:Init()
	sendBuf:PushUInt32(pPlayer.m_dwObjSerial)
	sendBuf:PushUInt8(pAT.m_pp.nPart)
	sendBuf:PushUInt32(pPlayer.m_dwObjSerial)
	sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
	sendBuf:PushUInt8(pAT.m_bActiveSucc and 1 or 0)
	sendBuf:PushUInt8(#pAT.m_DamList)

	for _,d in ipairs(pAT.m_DamList) do
		sendBuf:PushUInt8(d.m_pChar.m_ObjID.m_byID)
		sendBuf:PushUInt32(d.m_pChar.m_dwObjSerial)
		sendBuf:PushUInt16(d.m_nDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
		sendBuf:PushUInt8(d.m_bActiveSucc and 1 or 0)
		sendBuf:PushUInt16(d.m_nActiveDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
	end

	pPlayer:CircleReport(5, 11, sendBuf, true)
end

---@param pPlayer CPlayer
---@param pAT sirinCAttack
---@param wBulletIndex integer
function sirinPlayerAttack.SendMsg_AttackResult_Gen(pPlayer, pAT, wBulletIndex)
	sendBuf:Init()
	sendBuf:PushUInt8(pPlayer.m_ObjID.m_byID)
	sendBuf:PushUInt32(pPlayer.m_dwObjSerial)
	sendBuf:PushUInt8(pAT.m_pp.nPart)
	sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
	sendBuf:PushUInt16(wBulletIndex)
	sendBuf:PushUInt8(pAT.m_bActiveSucc and 1 or 0)
	sendBuf:PushUInt8(#pAT.m_DamList)

	for _,d in ipairs(pAT.m_DamList) do
		sendBuf:PushUInt8(d.m_pChar.m_ObjID.m_byID)
		sendBuf:PushUInt32(d.m_pChar.m_dwObjSerial)
		sendBuf:PushUInt16(d.m_nDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
		sendBuf:PushUInt8(d.m_bActiveSucc and 1 or 0)
		sendBuf:PushUInt16(d.m_nActiveDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
	end

	pPlayer:CircleReport(5, 7, sendBuf, true)
end

---@param pPlayer CPlayer
---@param byEffectCode integer
---@param pAT sirinCAttack
---@param wBulletIndex integer
function sirinPlayerAttack.SendMsg_AttackResult_Skill(pPlayer, byEffectCode, pAT, wBulletIndex)
	sendBuf:Init()
	sendBuf:PushUInt8(pPlayer.m_ObjID.m_byID)
	sendBuf:PushUInt32(pPlayer.m_dwObjSerial)
	sendBuf:PushUInt8(byEffectCode)
	sendBuf:PushUInt16(pAT.m_pp.pFld.m_dwIndex)
	sendBuf:PushUInt8(pAT.m_pp.nLevel)
	sendBuf:PushUInt8(pAT.m_pp.nPart)
	sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
	sendBuf:PushUInt16(wBulletIndex)
	sendBuf:PushInt16(math.floor(pAT.m_pp.fArea_x))
	sendBuf:PushInt16(math.floor(pAT.m_pp.fArea_z))
	sendBuf:PushUInt8(pAT.m_bActiveSucc and 1 or 0)
	sendBuf:PushUInt8(#pAT.m_DamList)

	for _,d in ipairs(pAT.m_DamList) do
		sendBuf:PushUInt8(d.m_pChar.m_ObjID.m_byID)
		sendBuf:PushUInt32(d.m_pChar.m_dwObjSerial)
		sendBuf:PushUInt16(d.m_nDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
		sendBuf:PushUInt8(d.m_bActiveSucc and 1 or 0)
		sendBuf:PushUInt16(d.m_nActiveDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
	end

	pPlayer:CircleReport(5, 8, sendBuf, true)
end

function sirinPlayerAttack.SendMsg_AttackResult_Force(pPlayer, pAT)
	sendBuf:Init()
	sendBuf:PushUInt8(pPlayer.m_ObjID.m_byID)
	sendBuf:PushUInt32(pPlayer.m_dwObjSerial)
	sendBuf:PushUInt8(pAT.m_pp.pFld.m_dwIndex)
	sendBuf:PushUInt8(pAT.m_pp.nLevel)
	sendBuf:PushInt16(math.floor(pAT.m_pp.fArea_x))
	sendBuf:PushInt16(math.floor(pAT.m_pp.fArea_z))
	sendBuf:PushUInt8(pAT.m_pp.nPart)
	sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
	sendBuf:PushUInt8(pAT.m_bActiveSucc and 1 or 0)
	sendBuf:PushUInt8(#pAT.m_DamList)

	for _,d in ipairs(pAT.m_DamList) do
		sendBuf:PushUInt8(d.m_pChar.m_ObjID.m_byID)
		sendBuf:PushUInt32(d.m_pChar.m_dwObjSerial)
		sendBuf:PushUInt16(d.m_nDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
		sendBuf:PushUInt8(d.m_bActiveSucc and 1 or 0)
		sendBuf:PushUInt16(d.m_nActiveDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
	end

	pPlayer:CircleReport(5, 9, sendBuf, true)
end

---@param pPlayer CPlayer
---@param pAT sirinCAttack
---@param byWeaponPart integer
---@param wBulletIndex integer
function sirinPlayerAttack.SendMsg_AttackResult_Unit(pPlayer, pAT, byWeaponPart, wBulletIndex)
	sendBuf:Init()
	sendBuf:PushUInt32(pPlayer.m_dwObjSerial)
	sendBuf:PushUInt8(byWeaponPart)
	sendBuf:PushInt16(pAT.m_pp.pFld.m_dwIndex)
	sendBuf:PushInt16(wBulletIndex)
	sendBuf:PushUInt8(pAT.m_pp.nPart)
	sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
	sendBuf:PushUInt8(#pAT.m_DamList)

	for _,d in ipairs(pAT.m_DamList) do
		sendBuf:PushUInt8(d.m_pChar.m_ObjID.m_byID)
		sendBuf:PushUInt32(d.m_pChar.m_dwObjSerial)
		sendBuf:PushUInt16(d.m_nDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
	end

	pPlayer:CircleReport(5, 10, sendBuf, true)
end

---@param pPlayer CPlayer
---@param pAT sirinCAttack
---@param wBulletIndex integer
function sirinPlayerAttack.SendMsg_AttackResult_Siege(pPlayer, pAT, wBulletIndex)
	sendBuf:Init()
	sendBuf:PushUInt8(pPlayer.m_ObjID.m_byID)
	sendBuf:PushUInt32(pPlayer.m_dwObjSerial)
	sendBuf:PushUInt8(pAT.m_pp.nPart)
	sendBuf:PushInt16(wBulletIndex)
	sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
	sendBuf:PushInt16(math.floor(pAT.m_pp.fArea_x))
	sendBuf:PushInt16(math.floor(pAT.m_pp.fArea_z))
	sendBuf:PushUInt8(#pAT.m_DamList)

	for _,d in ipairs(pAT.m_DamList) do
		sendBuf:PushUInt8(d.m_pChar.m_ObjID.m_byID)
		sendBuf:PushUInt32(d.m_pChar.m_dwObjSerial)
		sendBuf:PushUInt16(d.m_nDamage >= 0xFFFE and 0xFFFD or d.m_nDamage)
	end

	pPlayer:CircleReport(5, 122, sendBuf, true)
end

---@param pPlayer CPlayer
---@param wItemSerial integer
---@param wDurLeft integer
function sirinPlayerAttack.SendMsg_AlterWeaponBulletInform(pPlayer, wItemSerial, wDurLeft)
	sendBuf:Init()
	sendBuf:PushUInt16(wItemSerial)
	sendBuf:PushUInt16(wDurLeft)
	sendBuf:SendBuffer(pPlayer, 5, 21)
end

---@param pPlayer CPlayer
---@param pDst CCharacter
---@param byPart integer
---@param pBulletFld? _BulletItem_fld
---@param fBulletGARate number
---@param pEffBtFld? _BulletItem_fld
---@param fEffBtGARate number
---@return sirinCAttack
function sirinPlayerAttack.make_gen_attack_param(pPlayer, pDst, byPart, pBulletFld, fBulletGARate, pEffBtFld, fEffBtGARate)
	local pAT = SirinCAttack:new()
	pAT.m_pAttChar = pPlayer
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst
	local pDstPlayer = objectToPlayer(pDst)

	if not pDst or pDst.m_ObjID.m_byID ~= ID_CHAR.player or pDstPlayer.m_byDamagePart == 255 then
		pAP.nPart = byPart
	else
		pAP.nPart = pDstPlayer.m_byDamagePart
	end

	if pBulletFld then
		pAP.nTol = pBulletFld.m_nProperty
	else
		pAP.nTol = pPlayer.m_pmWpn.byAttTolType
	end

	pAP.nClass = pPlayer.m_pmWpn.byWpClass

	local mastery = 1

	if pPlayer.m_pmWpn.byWpType == 7 then
		mastery = pPlayer.m_pmMst:GetMasteryPerMast(6, 0)
	else
		mastery = pPlayer.m_pmMst:GetMasteryPerMast(0, pPlayer.m_pmWpn.byWpClass)
	end

	if pEffBtFld and pPlayer.m_pmWpn.strEffBulletType ~= "-1" then
		pAP.nMinAFPlus = math.floor(pPlayer.m_pmWpn.nGaMinAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate * fEffBtGARate) + s_nAddMstFc[mastery]
		pAP.nMaxAFPlus = math.floor(pPlayer.m_pmWpn.nGaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate * fEffBtGARate) + s_nAddMstFc[mastery]
	end

	pAP.nMinAF = math.floor(pPlayer.m_pmWpn.nGaMinAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate) + s_nAddMstFc[mastery]
	pAP.nMaxAF = math.floor(pPlayer.m_pmWpn.nGaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate) + s_nAddMstFc[mastery]
	pAP.nMinSel = pPlayer.m_pmWpn.byGaMinSel
	pAP.nMaxSel = pPlayer.m_pmWpn.byGaMaxSel
	pAP.nExtentRange = 20

	if pBulletFld then
		pAP.nAttactType = pBulletFld.m_nEffectGroup
		pAP.nShotNum = 1
	end

	if pEffBtFld then
		pAP.nEffShotNum = 1
	end

	if pDst then
		pAP.fArea_x = pDst.m_fCurPos_x
		pAP.fArea_y = pDst.m_fCurPos_y
		pAP.fArea_z = pDst.m_fCurPos_z
	end

	pAP.bMatchless = pPlayer.m_bCheat_Matchless
	pAP.nMaxAttackPnt = pPlayer.m_nMaxAttackPnt

	if pDst and pDst.m_ObjID.m_byID == ID_CHAR.monster then
		local pDstMonster = objectToMonster(pDst)

		if not pDstMonster:IsViewArea(pPlayer) then
			pAP.bBackAttack = true
		end
	end
	return pAT
end

---@param pPlayer CPlayer
---@param pDst? CCharacter
---@param x number
---@param y number
---@param z number
---@param byEffectCode integer
---@param pSkillFld _skill_fld
---@param nAttType integer
---@param pBulletFld? _BulletItem_fld
---@param fBulletGARate number
---@param pEffBtFld? _BulletItem_fld
---@param fEffBtGARate number
---@return sirinCPlayerAttack
function sirinPlayerAttack.make_skill_attack_param(pPlayer, pDst, x, y, z, byEffectCode, pSkillFld, nAttType, pBulletFld, fBulletGARate, pEffBtFld, fEffBtGARate)
	local pAT = sirinCPlayerAttack:new()
	pAT.m_pAttChar = pPlayer
	pAT.m_pAttPlayer = pPlayer
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst

	if pDst then
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pDst)
	else
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pPlayer)
	end

	if pBulletFld then
		pAP.nTol = pBulletFld.m_nProperty
	else
		pAP.nTol = pPlayer.m_pmWpn.byAttTolType
	end

	pAP.nClass = pPlayer.m_pmWpn.byWpClass

	if pPlayer.m_pmWpn.nGaMaxAF < 0 or pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) < 0 or fBulletGARate < 0 then
		g_Main.m_logSystemError:Write(string.format("Skill Attack Warning : nGaMaxAF(%d), Potion_Inc_Fc(%.3f), fAddBulletFc(%.3f)", pPlayer.m_pmWpn.nGaMaxAF, pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc), fBulletGARate))
	end

	local mastery = 1

	if pPlayer.m_pmWpn.byWpType == 7 then
		mastery = pPlayer.m_pmMst:GetMasteryPerMast(6, 0)
	else
		mastery = pPlayer.m_pmMst:GetMasteryPerMast(0, pPlayer.m_pmWpn.byWpClass)
	end

	if pEffBtFld and pPlayer.m_pmWpn.strEffBulletType ~= "-1" then
		pAP.nMinAFPlus = math.floor(pPlayer.m_pmWpn.nGaMinAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate * fEffBtGARate) + mastery
		pAP.nMaxAFPlus = math.floor(pPlayer.m_pmWpn.nGaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate * fEffBtGARate) + mastery
	end

	pAP.nMinAF = math.floor(pPlayer.m_pmWpn.nGaMinAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate) + mastery
	pAP.nMaxAF = math.floor(pPlayer.m_pmWpn.nGaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate) + mastery

	if pPlayer:IsSiegeMode() then
		local pSiegeFld = baseToSiegeKitItem(g_Main:m_tblItemData_get(TBL_CODE.siegekit):GetRecord(pPlayer.m_pSiegeItem.m_wItemIndex))

		pAP.nMinAF = math.floor(pAP.nMinAF * pSiegeFld.m_fGAAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.FC_SiegeMode))
		pAP.nMaxAF = math.floor(pAP.nMaxAF * pSiegeFld.m_fGAAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.FC_SiegeMode))

		if pEffBtFld and pPlayer.m_pmWpn.strEffBulletType ~= "-1" then
			pAP.nMinAFPlus = math.floor(pAP.nMinAFPlus * pSiegeFld.m_fGAAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.FC_SiegeMode))
			pAP.nMaxAFPlus = math.floor(pAP.nMaxAFPlus * pSiegeFld.m_fGAAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.FC_SiegeMode))
		end
	end

	pAP.nMinSel = pPlayer.m_pmWpn.byGaMinSel
	pAP.nMaxSel = pPlayer.m_pmWpn.byGaMaxSel
	pAP.nExtentRange = 20

	if pBulletFld then
		pAP.nShotNum = pSkillFld.m_nAttNeedBt

		if pEffBtFld then
			pAP.nEffShotNum = 1
		end
	end

	if nAttType == 3 then
		pAP.nAddAttPnt = math.floor(pPlayer:GetHP() * 0.9)
	end

	pAP.pFld = pSkillFld
	pAP.byEffectCode = byEffectCode

	if byEffectCode == EFF_CODE.skill then
		pAP.nLevel = pPlayer.m_pmMst:GetSkillLv(pSkillFld.m_dwIndex)

		if pAP.nLevel > 7 then
			pAP.nLevel = 7
		end

		pAP.nMastery = pPlayer.m_pmMst:GetMasteryPerMast(3, pSkillFld.m_nMastIndex)
	else
		pAP.nLevel = 1
		pAP.nMastery = 99
	end

	pAP.fArea_x = x
	pAP.fArea_y = y
	pAP.fArea_z = z
	pAP.nMaxAttackPnt = pPlayer.m_nMaxAttackPnt

	if pDst and pDst.m_ObjID == ID_CHAR.monster then
		if not objectToMonster(pDst):IsViewArea(pPlayer) then
			pAP.bBackAttack = true
		end
	end

	return pAT
end

---@param pPlayer CPlayer
---@param pDst? CCharacter
---@param x number
---@param y number
---@param z number
---@param pForceFld _force_fld
---@param nForceLv integer
---@param pEffBtFld? _BulletItem_fld
---@param fEffBtGARate number
---@return sirinCAttack
function sirinPlayerAttack.make_force_attack_param(pPlayer, pDst,  x, y, z, pForceFld, nForceLv, pEffBtFld, fEffBtGARate)
	local pAT = SirinCAttack:new()
	pAT.m_pAttChar = pPlayer
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst

	if pDst then
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pDst)
	else
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pPlayer)
	end

	pAP.nTol = pForceFld.m_nProperty
	pAP.nClass = pPlayer.m_pmWpn.byWpClass

	if pEffBtFld and pPlayer.m_pmWpn.strEffBulletType ~= "-1" then
		pAP.nMinAFPlus = math.floor(pPlayer.m_pmWpn.nMaMinAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fEffBtGARate) + pPlayer.m_pmMst.m_mtyStaff
		pAP.nMaxAFPlus = math.floor(pPlayer.m_pmWpn.nMaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fEffBtGARate) + pPlayer.m_pmMst.m_mtyStaff
	end

	pAP.nMinAF = math.floor(pPlayer.m_pmWpn.nMaMinAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc)) + pPlayer.m_pmMst.m_mtyStaff
	pAP.nMaxAF = math.floor(pPlayer.m_pmWpn.nMaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc)) + pPlayer.m_pmMst.m_mtyStaff
	pAP.nMinSel = pPlayer.m_pmWpn.byMaMinSel
	pAP.nMaxSel = pPlayer.m_pmWpn.byMaMaxSel
	pAP.pFld = pForceFld
	pAP.byEffectCode = EFF_CODE.force
	pAP.nLevel = nForceLv
	pAP.nMastery = pPlayer.m_pmMst:GetMasteryPerMast(4, pForceFld.m_nMastIndex)

	if pDst then
		pAP.fArea_x = pDst.m_fCurPos_x
		pAP.fArea_y = pDst.m_fCurPos_y
		pAP.fArea_z = pDst.m_fCurPos_z
	else
		pAP.fArea_x = x
		pAP.fArea_y = y
		pAP.fArea_z = z
	end

	pAP.nMaxAttackPnt = pPlayer.m_nMaxAttackPnt

	if pDst and pDst.m_ObjID == ID_CHAR.monster then
		if not objectToMonster(pDst):IsViewArea(pPlayer) then
			pAP.bBackAttack = true
		end
	end

	if pEffBtFld then
		pAP.nEffShotNum = 1
	end

	return pAT
end

---@param pPlayer CPlayer
---@param pDst CCharacter
---@param pWeaponFld _UnitPart_fld
---@param fBulletGARate number
---@return sirinCPlayerAttack
function sirinPlayerAttack.make_unit_attack_param(pPlayer, pDst, pWeaponFld, fBulletGARate)
	local pAT = sirinCPlayerAttack:new()
	pAT.m_pAttChar = pPlayer
	pAT.m_pAttPlayer = pPlayer
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst

	if pDst then
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pDst)
	else
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pPlayer)
	end

	pAP.nTol = -1
	pAP.nClass = pWeaponFld.m_nWPType
	pAP.nMinAF = math.floor(pWeaponFld.m_nGAMinAF * fBulletGARate * pPlayer.m_fUnitPv_AttFc)
	pAP.nMaxAF = math.floor((pWeaponFld.m_nGAMinAF * fBulletGARate + pPlayer.m_pmMst:GetMasteryPerMast(6, 0)) * pPlayer.m_fUnitPv_AttFc)
	pAP.nMinSel = pWeaponFld.m_nGAMinSelProb
	pAP.nMaxSel = pWeaponFld.m_nGAMaxSelProb
	pAP.nExtentRange = math.floor(pWeaponFld.m_fAttackRange)
	pAP.pFld = pWeaponFld

	if pDst and pDst.m_ObjID == ID_CHAR.monster then
		if not objectToMonster(pDst):IsViewArea(pPlayer) then
			pAP.bBackAttack = true
		end
	end

	return pAT
end

---@param pPlayer CPlayer
---@param byEffectCode integer
---@param pSkillFld _skill_fld
---@param wBulletSerial integer
---@return boolean
---@return _STORAGE_LIST___db_con? pBulletCon
---@return _BulletItem_fld? pBulletFld
function sirinPlayerAttack._pre_check_wpactive_skill_attack(pPlayer, byEffectCode, pSkillFld, wBulletSerial)
	local bSucc = false
	local pBulletCon = nil
	local pBulletFld = nil

	repeat
		if pPlayer:IsSiegeMode() then
			break
		end

		if pPlayer:IsRidingUnit() then
			break
		end

		local pWeaponCon = pPlayer.m_Param.m_dbEquip:m_List_get(TBL_CODE.weapon)
		local pWeaponFld = nil

		if pWeaponCon.m_byLoad ~= 0 then
			pWeaponFld = baseToWeaponItem(g_Main:m_tblItemData_get(TBL_CODE.weapon):GetRecord(pWeaponCon.m_wItemIndex))
		end

		if wBulletSerial ~= 0xFFFF then
			pBulletCon, pBulletFld = isBulletValidity(pPlayer, pWeaponFld, wBulletSerial)
		end

		if pPlayer.m_pmWpn.byWpType == 5 or pPlayer.m_pmWpn.byWpType == 6 or pPlayer.m_pmWpn.byWpType == 7 or pPlayer.m_pmWpn.byWpType == 11 then
			if not pBulletCon or not pBulletFld then
				break
			end

			if pBulletCon.m_bLock then
				break
			end

			if byEffectCode == EFF_CODE.bullet and pSkillFld.m_strCode ~= pBulletFld.m_strEffectIndex then
				break
			end
		end

		if pSkillFld.m_nMastIndex > 8 then
			break
		end

		bSucc = true

	until true

	if not bSucc then
		pBulletCon = nil
		pBulletFld = nil
	end

	return bSucc, pBulletCon, pBulletFld
end

---@param pPlayer CPlayer
---@param pDst CCharacter
---@param pSkillFld _skill_fld
---@param byEffectCode integer
---@param pBulletFld? _BulletItem_fld
---@return sirinCPlayerAttack
function sirinPlayerAttack.make_wpactive_skill_attack_param(pPlayer, pDst, pSkillFld, byEffectCode, pBulletFld)
	local pAT = sirinCPlayerAttack:new()
	pAT.m_pAttChar = pPlayer
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst
	local pDstPlayer = objectToPlayer(pDst)
	pAT.m_pAttPlayer = pDstPlayer

	if not pDst then
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pPlayer)
	else
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pDst)
	end

	local fBulletGARate = 1.0

	if byEffectCode == 0 then
		pAP.nAttactType = pSkillFld:m_nAttType_get(pPlayer.m_pmWpn.nActiveEffLvl - 1)
	else
		pAP.nAttactType = pSkillFld:m_nAttType_get(0)
	end

	if pBulletFld then
		pAP.nTol = pBulletFld.m_nProperty
		fBulletGARate = pBulletFld.m_fGAAF
	else
		pAP.nTol = pPlayer.m_pmWpn.byAttTolType
	end

	pAP.nClass = pPlayer.m_pmWpn.byWpClass
	pAP.nWpType = pPlayer.m_pmWpn.byWpClass -- was missing in original code

	local mastery = 1

	if pPlayer.m_pmWpn.byWpType == 7 then
		mastery = pPlayer.m_pmMst:GetMasteryPerMast(6, 0)
	else
		mastery = pPlayer.m_pmMst:GetMasteryPerMast(0, pPlayer.m_pmWpn.byWpClass)
	end

	pAP.nMinAF = math.floor(pPlayer.m_pmWpn.nGaMinAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate) + mastery
	pAP.nMaxAF = math.floor(pPlayer.m_pmWpn.nGaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate) + mastery
	pAP.nMinSel = pPlayer.m_pmWpn.byGaMinSel
	pAP.nMaxSel = pPlayer.m_pmWpn.byGaMaxSel
	pAP.nExtentRange = 20
	pAP.nShotNum = pSkillFld.m_nAttNeedBt

	if pAP.nAttactType == 3 then
		pAP.nAddAttPnt = math.floor(pPlayer:GetHP() * 0.9)
	end

	pAP.pFld = pSkillFld
	pAP.byEffectCode = byEffectCode

	if byEffectCode ~= 0 then
		pAP.nLevel = 1
		pAP.nMastery = 99
	else
		pAP.nLevel = pPlayer.m_pmWpn.nActiveEffLvl

		if pAP.nLevel > 7 then
			pAP.nLevel = 7
		end

		pAP.nMastery = pPlayer.m_pmMst:GetMasteryPerMast(3, pSkillFld.m_nMastIndex)
	end

	pAP.fArea_x = pDst.m_fCurPos_x
	pAP.fArea_y = pDst.m_fCurPos_y
	pAP.fArea_z = pDst.m_fCurPos_z
	pAP.nMaxAttackPnt = pPlayer.m_nMaxAttackPnt

	if pDst.m_ObjID.m_byID == ID_CHAR.monster then
		local pDstMonster = objectToMonster(pDst)

		if not pDstMonster:IsViewArea(pPlayer) then
			pAP.bBackAttack = true
		end
	end
	return pAT
end

---@param pPlayer CPlayer
---@param pDst CCharacter
---@param x number
---@param y number
---@param z number
---@param byPart integer
---@param pBulletFld _BulletItem_fld
---@param fBulletGARate number
---@param pEffBtFld? _BulletItem_fld
---@param fEffBtGARate number
---@return sirinCAttack
function sirinPlayerAttack.make_siege_attack_param(pPlayer, pDst, x, y, z, byPart, pBulletFld, fBulletGARate, pEffBtFld, fEffBtGARate)
	local pAT = SirinCAttack:new()
	pAT.m_pAttChar = pPlayer
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst
	local pDstPlayer = objectToPlayer(pDst)

	if not pDst or pDst.m_ObjID.m_byID ~= ID_CHAR.player or pDstPlayer.m_byDamagePart == 255 then
		pAP.nPart = byPart
	else
		pAP.nPart = pDstPlayer.m_byDamagePart
	end

	if pBulletFld then
		pAP.nTol = pBulletFld.m_nProperty
	else
		pAP.nTol = pPlayer.m_pmWpn.byAttTolType
	end

	pAP.nClass = pPlayer.m_pmWpn.byWpClass
	pAP.nWpType = pPlayer.m_pmWpn.byWpType

	local mastery = 1

	if pPlayer.m_pmWpn.byWpType == 7 then
		mastery = pPlayer.m_pmMst:GetMasteryPerMast(6, 0)
	else
		mastery = pPlayer.m_pmMst:GetMasteryPerMast(0, pPlayer.m_pmWpn.byWpClass)
	end

	local fSiegeGARate = baseToSiegeKitItem(g_Main:m_tblItemData_get(TBL_CODE.siegekit):GetRecord(pPlayer.m_pSiegeItem.m_wItemIndex)).m_fGAAF

	if pEffBtFld and pPlayer.m_pmWpn.strEffBulletType ~= "-1" then
		pAP.nMinAFPlus = math.floor((pPlayer.m_pmWpn.nGaMinAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate * fEffBtGARate + s_nAddMstFc[mastery]) * fSiegeGARate * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.FC_SiegeMode))
		pAP.nMaxAFPlus = math.floor((pPlayer.m_pmWpn.nGaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate * fEffBtGARate + s_nAddMstFc[mastery]) * fSiegeGARate * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.FC_SiegeMode))
	end

	pAP.nMinAF = math.floor((pPlayer.m_pmWpn.nGaMinAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate + s_nAddMstFc[mastery]) * fSiegeGARate * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.FC_SiegeMode))
	pAP.nMaxAF = math.floor((pPlayer.m_pmWpn.nGaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * fBulletGARate + s_nAddMstFc[mastery]) * fSiegeGARate * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.FC_SiegeMode))
	pAP.nMinSel = pPlayer.m_pmWpn.byGaMinSel
	pAP.nMaxSel = pPlayer.m_pmWpn.byGaMaxSel
	pAP.nExtentRange = 20

	if pBulletFld then
		pAP.nAttactType = pBulletFld.m_nEffectGroup
		pAP.nShotNum = 1
	end

	if pEffBtFld then
		pAP.nEffShotNum = 1
	end

	pAP.fArea_x = x
	pAP.fArea_y = y
	pAP.fArea_z = z
	pAP.nMaxAttackPnt = pPlayer.m_nMaxAttackPnt

	if pDst and pDst.m_ObjID.m_byID == ID_CHAR.monster then
		local pDstMonster = objectToMonster(pDst)

		if not pDstMonster:IsViewArea(pPlayer) then
			pAP.bBackAttack = true
		end
	end
	return pAT
end

---@param pPlayer CPlayer
---@param damList table<integer, sirin_be_damaged_char>
---@param pSkillFld _skill_fld
---@param byEffectCode integer
---@param nShotNum integer
---@param wBulletSerial integer
---@return boolean
---@return integer? nSFShotNum
function sirinPlayerAttack.pc_WPActiveAttack_Skill(pPlayer, damList, pSkillFld, byEffectCode, nShotNum, wBulletSerial)
	local bSucc, pBulletCon, pBulletFld = sirinPlayerAttack._pre_check_wpactive_skill_attack(pPlayer, byEffectCode, pSkillFld, wBulletSerial)

	if not bSucc then
		return false
	end

	if pBulletCon and pBulletCon.m_dwDur <= nShotNum then
		return false
	end

	local pAT = sirinPlayerAttack.make_wpactive_skill_attack_param(pPlayer, damList[1].m_pChar, pSkillFld, byEffectCode, pBulletFld)

	if pBulletCon and pAT.m_pp.nShotNum + nShotNum > pBulletCon.m_dwDur then
		pAT.m_pp.nShotNum = pBulletCon.m_dwDur
	end

	pAT:WPActiveAttackSkill()

	if #pAT.m_DamList > 0 then
		for _,a in ipairs(pAT.m_DamList) do
			local bProcessed = false

			for _,d in ipairs(damList) do
				if IsSameObject(d.m_pChar, a.m_pChar) then
					bProcessed = true
					d.m_bActiveSucc = a.m_nDamage > 0
					d.m_nActiveDamage = a.m_nDamage
					break
				end
			end

			if not bProcessed and #damList < 30 then
				local nd = Sirin_be_damaged_char:new{ m_pChar = a.m_pChar, m_nDamage = 0, m_bActiveSucc = a.m_nDamage > 0, m_nActiveDamage = a.m_nDamage }
				table.insert(damList, nd)
			end
		end
	end

	return true
end

---@param pPlayer CPlayer
---@param damList table<integer, sirin_be_damaged_char>
---@param pSkillFld _skill_fld
---@param nEffectCode integer
---@return boolean
function sirinPlayerAttack.WPActiveSkill(pPlayer, damList, pSkillFld, nEffectCode)
	if #damList == 0 or not pSkillFld then
		return false
	end

	if nEffectCode == EFF_CODE.skill and pSkillFld.m_nMastIndex > 8 then
		return false
	end

	if pSkillFld.m_nTempEffectType >= 150 then
		return false
	end

	if pSkillFld.m_nTempEffectType == -1 and pSkillFld.m_nContEffectType == -1 then
		return false
	end

	local bInsStoneUsable = IsUsableTempEffectAtStoneState(pSkillFld.m_nTempEffectType)
	local nLv = 1

	if nEffectCode == EFF_CODE.skill then
		nLv = pPlayer.m_pmWpn.nActiveEffLvl
	end

	if nLv > 7 then
		nLv = 7
	end

	if #damList == 1 then
		local pDst = damList[1].m_pChar

		if not pPlayer:IsEffectableDst(pSkillFld.m_strActableDst, pDst) then
			return false
		end

		if pSkillFld.m_nContEffectType ~= -1 and not pDst:IsRecvableContEffect() then
			return false
		end

		if pSkillFld.m_nContEffectType == 0 and not pPlayer:IsAttackableInTown() and not pDst:IsAttackableInTown() then
			if pPlayer:IsInTown() or pDst:IsInTown() then
				return false
			end

			if pPlayer.m_Param.m_pGuild
			and Sirin.mainThread.CGuildRoomSystem.GetInstance():IsGuildRoomMemberIn(pPlayer.m_Param.m_pGuild.m_dwSerial, pPlayer.m_ObjID.m_wIndex, pPlayer.m_dwObjSerial) then
				return false
			end
		end

		local bSucc, nErrCode = pPlayer:AssistSkill(pDst, nEffectCode, pSkillFld, nLv)

		if nErrCode == 0 then
			damList[1].m_bActiveSucc = true
		end

		return bSucc
	elseif pSkillFld.m_nContEffectType ~= 0 or not pPlayer.m_Param.m_pGuild or not Sirin.mainThread.CGuildRoomSystem.GetInstance():IsGuildRoomMemberIn(pPlayer.m_Param.m_pGuild.m_dwSerial, pPlayer.m_ObjID.m_wIndex, pPlayer.m_dwObjSerial) then
		local bSucc = false

		for _,d in ipairs (damList) do
			local pDst = d.m_pChar

			repeat
				if not pPlayer:IsEffectableDst(pSkillFld.m_strActableDst, pDst) then
					break
				end

				if pSkillFld.m_nContEffectType ~= -1 and not pDst:IsRecvableContEffect() then
					break
				end

				if pDst.m_EP:GetEff_State(_EFF_STATE.Invincible) then
					break
				end

				if pDst.m_EP:GetEff_State(_EFF_STATE.Stone_Lck) and (not bInsStoneUsable or pSkillFld.m_nTempEffectType == -1) then
					break
				end

				if pSkillFld.m_nContEffectType == 0 and not pPlayer:IsAttackableInTown() and not pDst:IsAttackableInTown() then
					if pPlayer:IsInTown() or pDst:IsInTown() then
						break
					end
				end

				if pPlayer:AssistSkillToOne(pDst, nEffectCode, pSkillFld, nLv) then
					d.m_bActiveSucc = true
					bSucc = true
				end

			until true
		end

		return bSucc
	end

	return false
end

---@param pPlayer CPlayer
---@return boolean
function sirinPlayerAttack._pre_check_wpactive_force_attack(pPlayer)
	if pPlayer:IsSiegeMode() then
		return false
	end

	if pPlayer:IsRidingUnit() then
		return false
	end

	return true
end

---@param pPlayer CPlayer
---@param pDst CCharacter
---@param pForceFld _force_fld
---@return sirinCPlayerAttack
function sirinPlayerAttack.make_wpactive_force_attack_param(pPlayer, pDst, pForceFld)
	local pAT = sirinCPlayerAttack:new()
	pAT.m_pAttChar = pPlayer
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst
	local pDstPlayer = objectToPlayer(pDst)
	pAT.m_pAttPlayer = pDstPlayer

	if not pDst then
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pPlayer)
	else
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pDst)
	end

	pAP.nTol = pForceFld.m_nProperty

	pAP.nMinAF = math.floor(pPlayer.m_pmWpn.nMaMinAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc)) + pPlayer.m_pmMst.m_mtyStaff
	pAP.nMaxAF = math.floor(pPlayer.m_pmWpn.nMaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc)) + pPlayer.m_pmMst.m_mtyStaff
	pAP.nMinSel = pPlayer.m_pmWpn.byMaMinSel
	pAP.nMaxSel = pPlayer.m_pmWpn.byMaMaxSel
	pAP.pFld = pForceFld
	pAP.byEffectCode = EFF_CODE.force
	pAP.nLevel = pPlayer.m_pmWpn.nActiveEffLvl
	pAP.nMastery = pPlayer.m_pmMst:GetMasteryPerMast(4, pForceFld.m_nMastIndex)
	pAP.fArea_x = pDst.m_fCurPos_x
	pAP.fArea_y = pDst.m_fCurPos_y
	pAP.fArea_z = pDst.m_fCurPos_z
	pAP.nMaxAttackPnt = pPlayer.m_nMaxAttackPnt

	if pDst.m_ObjID.m_byID == ID_CHAR.monster then
		local pDstMonster = objectToMonster(pDst)

		if not pDstMonster:IsViewArea(pPlayer) then
			pAP.bBackAttack = true
		end
	end
	return pAT
end

---@param pPlayer CPlayer
---@param damList table<integer, sirin_be_damaged_char>
---@param pForceFld _force_fld
---@return boolean
function sirinPlayerAttack.pc_WPActiveAttack_Force(pPlayer, damList, pForceFld)
	if not sirinPlayerAttack._pre_check_wpactive_force_attack(pPlayer) then
		return false
	end

	local pAT = sirinPlayerAttack.make_wpactive_force_attack_param(pPlayer, damList[1].m_pChar, pForceFld)

	pAT:WPActiveAttackForce()

	if #pAT.m_DamList > 0 then
		for _,a in ipairs(pAT.m_DamList) do
			local bProcessed = false

			for _,d in ipairs(damList) do
				if IsSameObject(d.m_pChar, a.m_pChar) then
					bProcessed = true
					d.m_bActiveSucc = a.m_nDamage > 0
					d.m_nActiveDamage = a.m_nDamage
					break
				end
			end

			if not bProcessed and #damList < 30 then
				local nd = Sirin_be_damaged_char:new{ m_pChar = a.m_pChar, m_nDamage = 0, m_bActiveSucc = a.m_nDamage > 0, m_nActiveDamage = a.m_nDamage }
				table.insert(damList, nd)
			end
		end
	end

	return true
end

---@param pPlayer CPlayer
---@param damList table<integer, sirin_be_damaged_char>
---@param pForceFld _force_fld
---@return boolean
function sirinPlayerAttack.WPActiveForce(pPlayer, damList, pForceFld)
		if #damList == 0 or not pForceFld then
		return false
	end

	if pForceFld.m_nTempEffectType >= 150 then
		return false
	end

	if pForceFld.m_nTempEffectType == -1 and pForceFld.m_nContEffectType == -1 then
		return false
	end

	local bInsStoneUsable = IsUsableTempEffectAtStoneState(pForceFld.m_nTempEffectType)
	local nLv = pPlayer.m_pmWpn.nActiveEffLvl

	if nLv > 7 then
		nLv = 7
	end

	if #damList == 1 then
		local pDst = damList[1].m_pChar

		if not pPlayer:IsEffectableDst(pForceFld.m_strActableDst, pDst) then
			return false
		end

		if pForceFld.m_nContEffectType ~= -1 and not pDst:IsRecvableContEffect() then
			return false
		end

		if pForceFld.m_nContEffectType == 0 and not pPlayer:IsAttackableInTown() and not pDst:IsAttackableInTown() then
			if pPlayer:IsInTown() or pDst:IsInTown() then
				return false
			end

			if pPlayer.m_Param.m_pGuild
			and Sirin.mainThread.CGuildRoomSystem.GetInstance():IsGuildRoomMemberIn(pPlayer.m_Param.m_pGuild.m_dwSerial, pPlayer.m_ObjID.m_wIndex, pPlayer.m_dwObjSerial) then
				return false
			end
		end

		local bSucc, nErrCode = pPlayer:AssistForce(pDst, pForceFld, nLv)

		if nErrCode == 0 then
			damList[1].m_bActiveSucc = true
		end

		return bSucc
	elseif pForceFld.m_nContEffectType ~= 0 or not pPlayer.m_Param.m_pGuild or not Sirin.mainThread.CGuildRoomSystem.GetInstance():IsGuildRoomMemberIn(pPlayer.m_Param.m_pGuild.m_dwSerial, pPlayer.m_ObjID.m_wIndex, pPlayer.m_dwObjSerial) then
		local bSucc = false

		for _,d in ipairs (damList) do
			local pDst = d.m_pChar

			repeat
				if not pPlayer:IsEffectableDst(pForceFld.m_strActableDst, pDst) then
					break
				end

				if pForceFld.m_nContEffectType ~= -1 and not pDst:IsRecvableContEffect() then
					break
				end

				if pDst.m_EP:GetEff_State(_EFF_STATE.Invincible) then
					break
				end

				if pDst.m_EP:GetEff_State(_EFF_STATE.Stone_Lck) and (not bInsStoneUsable or pForceFld.m_nTempEffectType == -1) then
					break
				end

				if pForceFld.m_nContEffectType == 0 and not pPlayer:IsAttackableInTown() and not pDst:IsAttackableInTown() then
					if pPlayer:IsInTown() or pDst:IsInTown() then
						break
					end
				end

				if pPlayer:AssistForceToOne(pDst, pForceFld, nLv) then
					d.m_bActiveSucc = true
					bSucc = true
				end

			until true
		end

		return bSucc
	end

	return false
end

---@param pPlayer CPlayer
---@param damList table<integer, sirin_be_damaged_char>
---@param nShotNum integer
---@param wBulletSerial integer
---@return boolean
---@return integer? #nSFShotNum
function sirinPlayerAttack.WeaponSFActive(pPlayer, damList, nShotNum, wBulletSerial)
	if #damList == 0 then
		return false
	end

	if pPlayer.m_pmWpn.nActiveType == EFF_CODE.skill or pPlayer.m_pmWpn.nActiveType == EFF_CODE.class then
		local pFld = baseToSkill(g_Main:m_tblEffectData_get(pPlayer.m_pmWpn.nActiveType):GetRecord(pPlayer.m_pmWpn.strActiveCode_key))

		if pFld then
			if pFld.m_nAttackable ~= 0 then
				return sirinPlayerAttack.pc_WPActiveAttack_Skill(pPlayer, damList, pFld, pPlayer.m_pmWpn.nActiveType, nShotNum, wBulletSerial)
			else
				return sirinPlayerAttack.WPActiveSkill(pPlayer, damList, pFld, pPlayer.m_pmWpn.nActiveType)
			end
		end
	elseif pPlayer.m_pmWpn.nActiveType == EFF_CODE.force then
		local pFld = baseToForce(g_Main:m_tblEffectData_get(pPlayer.m_pmWpn.nActiveType):GetRecord(pPlayer.m_pmWpn.strActiveCode_key))

		if pFld then
			if pFld.m_bAttackable ~= 0 then
				return sirinPlayerAttack.pc_WPActiveAttack_Force(pPlayer, damList, pFld)
			else
				return sirinPlayerAttack.WPActiveForce(pPlayer, damList, pFld)
			end
		end
	end

	return false
end

---@param pPlayer CPlayer
---@return integer
function sirinPlayerAttack.CalcEquipAttackDelay(pPlayer)
	local delay = 0

	for i = 0, 5 do
		local pCon = pPlayer.m_Param.m_dbEquip:m_List_get(i)

		if pCon.m_byLoad ~= 0 then
			local pFld = baseToDfnEquipItem(g_Main:m_tblItemData_get(i):GetRecord(pCon.m_wItemIndex))
			delay = delay + pFld.m_nGASpd
		end
	end

	local pCon = pPlayer.m_Param.m_dbEquip:m_List_get(TBL_CODE.weapon)

	if pCon.m_byLoad ~= 0 then
		local pFld = baseToWeaponItem(g_Main:m_tblItemData_get(TBL_CODE.weapon):GetRecord(pCon.m_wItemIndex))
		delay = delay + pFld.m_nGASpd
	end

	if pPlayer:IsSiegeMode() then
		local pFld = baseToSiegeKitItem(g_Main:m_tblItemData_get(TBL_CODE.siegekit):GetRecord(pPlayer.m_pSiegeItem.m_wItemIndex))
		delay = delay + pFld.m_nGACorSpd
	end

	return delay
end

---@param pPlayer CPlayer
---@param pTarget CCharacter
---@return integer
function sirinPlayerAttack._pre_check_in_guild_battle(pPlayer, pTarget)
	if pPlayer.m_bInGuildBattle then
		local pDstPlayer = nil

		if pTarget.m_ObjID.m_byID == ID_CHAR.player then
			pDstPlayer = objectToPlayer(pTarget)
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.animus then
			pDstPlayer = objectToAnimus(pTarget).m_pMaster
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.tower then
			pDstPlayer = objectToTower(pTarget).m_pMasterTwr
		end

		if not pDstPlayer or not pDstPlayer.m_bInGuildBattle or pPlayer.m_byGuildBattleColorInx == pDstPlayer.m_byGuildBattleColorInx then
			return -6
		end
	else
		local pDstPlayer = nil

		if pTarget.m_ObjID.m_byID == ID_CHAR.player then
			pDstPlayer = objectToPlayer(pTarget)
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.animus then
			pDstPlayer = objectToAnimus(pTarget).m_pMaster
		elseif pTarget.m_ObjID.m_byID == ID_CHAR.tower then
			pDstPlayer = objectToTower(pTarget).m_pMasterTwr
		end

		if pDstPlayer and pDstPlayer.m_bInGuildBattle then
			return -6
		end

		if pDstPlayer then
			if pPlayer:GetObjRace() == pDstPlayer:GetObjRace() and pPlayer.m_nChaosMode == 0 and not pDstPlayer:IsPunished(1, false) then
				return -6
			end
		else
			if pPlayer:GetObjRace() == pTarget:GetObjRace() then
				return -6
			end
		end
	end

	return 0
end

---@param pPlayer CPlayer
---@param pDst CCharacter
---@param bCounter boolean
---@param wBulletSerial integer
---@param wEffBtSerial integer
---@return integer nErrCode
---@return _STORAGE_LIST___db_con? pBulletCon
---@return _BulletItem_fld? pBulletFld
---@return _STORAGE_LIST___db_con? pEffBulletCon
---@return _BulletItem_fld? pEffBulletFld
function sirinPlayerAttack._pre_check_normal_attack(pPlayer, pDst, bCounter, wBulletSerial, wEffBtSerial)
	if not bCounter and not pPlayer.m_bSFDelayNotCheck and not pPlayer.m_AttDelayChker:IsDelay(255, 255, 255) then -- IsDelay return false if delay NOT finished yet
		return -5
	end

	if not pDst then
		return -6
	end

	if pPlayer:GetObjRace() == 2 and pPlayer.m_bIsSiegeActing then
		return -60
	end

	local nGuildBattleError = sirinPlayerAttack._pre_check_in_guild_battle(pPlayer, pDst)

	if nGuildBattleError ~= 0 then
		return nGuildBattleError
	end

	if not pPlayer:IsAttackableInTown() and not pDst:IsAttackableInTown() and (pPlayer:IsInTown() or pDst:IsInTown()) then
		return -31
	end

	if not pDst:IsBeDamagedAble(pPlayer) or not pDst:IsBeAttackedAble(true) then
		return -6
	end

	if pPlayer.m_pmWpn.byWpType == 7 and not pPlayer.m_bFreeSFByClass then
		local bCanUseLauncher = false

		for i = 0, 3 do
			local pClassFld = pPlayer.m_Param:m_ppHistoryEffect_get(i)

			if not pClassFld then break end

			bCanUseLauncher = bCanUseLauncher or pClassFld.m_bLauncherUsable ~= 0

			if bCanUseLauncher then break end
		end

		if not bCanUseLauncher then
			return -27
		end
	elseif pPlayer.m_pmWpn.byWpType == 10 or pPlayer.m_pmWpn.byWpType == 11 then
		return -9
	end

	if pPlayer:IsRidingUnit() then
		return -21
	end

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Stone_Lck) then
		return -37
	end

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Invincible) then
		return -37
	end

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Suspend_Lck) then
		return -38
	end

	if pPlayer.m_byMoveType == 2 then
		return -41
	end

	local pBulletCon = nil
	local pBulletFld = nil
	local pEffBtCon = nil
	local pEffBtFld = nil
	local pWeaponCon = pPlayer.m_Param.m_dbEquip:m_List_get(TBL_CODE.weapon)
	local pWeaponFld = nil

	if pWeaponCon.m_byLoad ~= 0 then
		pWeaponFld = baseToWeaponItem(g_Main:m_tblItemData_get(TBL_CODE.weapon):GetRecord(pWeaponCon.m_wItemIndex))
	end

	if wBulletSerial ~= 0xFFFF then
		pBulletCon, pBulletFld = isBulletValidity(pPlayer, pWeaponFld, wBulletSerial)
	end

	if pPlayer.m_pmWpn.byWpType == 5 or pPlayer.m_pmWpn.byWpType == 6 or pPlayer.m_pmWpn.byWpType == 7 then
		if not pBulletCon or not pBulletFld then
			return -17
		end

		if pBulletCon.m_bLock then
			return -29
		end
	end

	if wEffBtSerial ~= 0xFFFF then
		pEffBtCon, pEffBtFld = isEffBulletValidity(pPlayer, pWeaponFld, wEffBtSerial)
	end

	local dist = pPlayer.m_pmWpn.wGaAttRange + pDst:GetWidth() / 2

	if pPlayer.m_pmWpn.byWpType == 7 then
		dist = dist + pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.Lcr_Att_Dist)
	else
		dist = dist + pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.GE_Att_Dist_ + pPlayer.m_pmWpn.byWpClass)
	end

	if Get3DSqrt(pPlayer.m_fCurPos_x, pPlayer.m_fCurPos_y, pPlayer.m_fCurPos_z, pDst.m_fCurPos_x, pDst.m_fCurPos_y, pDst.m_fCurPos_z) > dist
	and Get3DSqrt(pPlayer.m_fCurPos_x, pPlayer.m_fCurPos_y, pPlayer.m_fCurPos_z, pDst.m_fOldPos_x, pDst.m_fOldPos_y, pDst.m_fOldPos_z) > dist then
		return -3
	end

	return 0, pBulletCon, pBulletFld, pEffBtCon, pEffBtFld
end

---@param pPlayer CPlayer
---@param pTarget CCharacter
---@param byAttPart integer
---@param wBulletSerial integer
---@param wEffBtSerial integer
---@param bCount boolean
function sirinPlayerAttack.CPlayer__pc_PlayAttack_Gen(pPlayer, pTarget, byAttPart, wBulletSerial, wEffBtSerial, bCount)
	if bCount and pPlayer.m_pmWpn.byWpClass then
		return
	end

	local nErr, pBulletCon, pBulletFld, pEffBtCon, pEffBtFld = sirinPlayerAttack._pre_check_normal_attack(pPlayer, pTarget, bCount, wBulletSerial, wEffBtSerial)

	if nErr ~= 0 then
		sirinPlayerAttack.SendMsg_AttackResult_Error(pPlayer, nErr)

		if pPlayer.m_bMove then
			pPlayer:Stop()
			pPlayer:SendMsg_BreakStop()
		end

		return
	end

	local fBulletGARate = 1.0
	local fEffBtGARate = 1.0
	local wBulletIndex = 0xFFFF

	if pBulletCon and pBulletFld then
		fBulletGARate = pBulletFld.m_fGAAF
		wBulletIndex = pBulletCon.m_wItemIndex
	end

	if pEffBtCon and pEffBtFld then
		fEffBtGARate = pEffBtFld.m_fGAAF
	end

	local pAT = sirinPlayerAttack.make_gen_attack_param(pPlayer, pTarget, byAttPart, pBulletFld, fBulletGARate, pEffBtFld, fEffBtGARate)

	if pEffBtCon and pEffBtFld then
		pAT:AttackGen(false, true)
	else
		pAT:AttackGen(false, false)
	end

	if pAT.m_DamList[1].m_nDamage > 0 and pPlayer.m_pmWpn.nActiveType > -1 and math.random(100) <= pPlayer.m_pmWpn.nActiveProb then
		local bSFsucc, nSFShotNum = sirinPlayerAttack.WeaponSFActive(pPlayer, pAT.m_DamList, pAT.m_pp.nShotNum, wBulletSerial)
		pAT.m_bActiveSucc = bSFsucc
		pAT.m_pp.nShotNum = pAT.m_pp.nShotNum + (nSFShotNum or 0)
		pAT.m_nDamagedObjNum = #pAT.m_DamList
	end

	if not bCount then
		local dwDelay = sirinPlayerAttack.CalcEquipAttackDelay(pPlayer) + 1000

		if pPlayer.m_pmWpn.byWpType ~= 7 then
			dwDelay = dwDelay + pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.GE_Att_Spd_ + pPlayer.m_pmWpn.byWpClass)
		else
			dwDelay = dwDelay + pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.Lcr_Att_Spd)
		end

		pPlayer.m_AttDelayChker:SetDelay(dwDelay)
	end

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Res_Att) then
		pPlayer:RemoveSFContHelpByEffect(2, 14)
	end

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Suspend_Lck) and (pAT.m_pp.nAttactType == 4 or pAT.m_pp.nAttactType == 5 or pAT.m_pp.nAttactType == 6 or pAT.m_pp.nAttactType == 7) then
		pPlayer:RemoveSFContHelpByEffect(2, 21)
	end

	if pPlayer.m_bFreeSFByClass then
		pAT.m_bIsCrtAtt = true
	end

	local kPartyExpNotify = sirin_CPartyModeKillMonsterExpNotify:new()

	if not pAT.m_bFailure then
		local nTotalDam = sirinPlayerAttack._check_exp_after_attack(pPlayer, pAT.m_DamList, kPartyExpNotify)

		if nTotalDam > 0 then
			sirinPlayerAttack._check_dst_param_after_attack(pPlayer, nTotalDam, pTarget)
		end
	end

	if bCount then
		sirinPlayerAttack.SendMsg_AttackResult_Count(pPlayer, pAT)
	else
		sirinPlayerAttack.SendMsg_AttackResult_Gen(pPlayer, pAT, wBulletIndex)
	end

	kPartyExpNotify:Notify()

	local totalMasteryCumul = 0
	local targetCount = 0

	for _,d in ipairs(pAT.m_DamList) do
		repeat
			d.m_pChar:SetDamage(d.m_nDamage + d.m_nActiveDamage, pPlayer, pPlayer:GetLevel(), pAT.m_bIsCrtAtt, -1, 0, true)

			if pPlayer:GetObjRace() == d.m_pChar:GetObjRace() then
				break
			end

			if pAT.m_bFailure then
				break
			end

			-- CPlayer::IsPassMasteryLimitLvDiff()
			local lvDiff = pPlayer:GetLevel() - d.m_pChar:GetLevel()

			if lvDiff >= -10 and lvDiff <= 3 then
				if d.m_nDamage / d.m_pChar:GetMaxHP() >= 0.01 then
					-- CPlayer::GetMasteryCumAfterAttack(
					if lvDiff >= 0 then
						lvDiff = 1
					elseif lvDiff < -5 then
						lvDiff = 5
					else
						lvDiff = -(lvDiff)
					end

					local point = math.ceil(d.m_pChar:GetLevel() / 10)
					totalMasteryCumul = totalMasteryCumul + (lvDiff > point and point or lvDiff)
					--
					targetCount = targetCount + 1
				end
			end
			--

		until true
	end

	if targetCount > 0 and not pPlayer:IsInTown() then
		local dwStatAlter = math.floor(totalMasteryCumul / targetCount)

		if dwStatAlter > 0 then
			if pPlayer.m_pmWpn.byWpType == 7 then
				pPlayer:Emb_AlterStat(6, 0, dwStatAlter, 0, "sirinPlayerAttack.CPlayer__pc_PlayAttack_Gen()---0", true)
			else
				pPlayer:Emb_AlterStat(0, pPlayer.m_pmWpn.byWpClass, dwStatAlter, 0, "sirinPlayerAttack.CPlayer__pc_PlayAttack_Gen()---1", true)
			end
		end
	end

	if pTarget and pTarget:GetHP() > 0 then
		-- CAnimus::MasterAttack_MasterInform()
		if pPlayer.m_pRecalledAnimusChar and not pPlayer.m_pRecalledAnimusChar.m_pTarget then
			pPlayer.m_pRecalledAnimusChar.m_pTarget = pTarget
		end
		--
		-- _TOWER_PARAM::NotifyOwnerAttackInform()
		for i = 0, 6 do
			local list = pPlayer.m_pmTwr:m_List_get(i)

			if list.m_pTowerObj then
				local pTowerFld = baseToGuardTowerItem(list.m_pTowerObj.m_pRecordSet)
				if list.m_pTowerObj.m_pCurMap == pTarget.m_pCurMap
				and not IsSameObject(list.m_pTowerObj.m_pMasterSetTarget, pTarget)
				and math.abs(list.m_pTowerObj.m_fCurPos_y - pTarget.m_fCurPos_y) <= 400
				and GetSqrt(list.m_pTowerObj.m_fCurPos_x, list.m_pTowerObj.m_fCurPos_z, pTarget.m_fCurPos_x, pTarget.m_fCurPos_z) <= pTowerFld.m_nGADst + pTarget:GetWidth() / 2 then
					list.m_pTowerObj.m_pMasterSetTarget = pTarget
					list.m_pTowerObj.m_pTarget = nil
				end
			end
		end
		--
	end

	if pBulletCon and pBulletFld and pAT.m_pp.nShotNum > 0 then
		local durLeft = pPlayer:Emb_AlterDurPoint(STORAGE_POS.embellish, pBulletCon.m_byStorageIndex, -(pAT.m_pp.nShotNum), false, true)

		if durLeft > 0 then
			sirinPlayerAttack.SendMsg_AlterWeaponBulletInform(pPlayer, pBulletCon.m_wSerial, durLeft)
		else
			Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("CONSUM: %s [%d] [%s]", pBulletFld.m_strCode, pBulletCon.m_lnUID, os.date(_, os.time())), false, false)
		end
	end

	if pEffBtCon and pEffBtFld and pAT.m_pp.nEffShotNum > 0 then
		local durLeft = pPlayer:Emb_AlterDurPoint(STORAGE_POS.embellish, pEffBtCon.m_byStorageIndex, -(pAT.m_pp.nEffShotNum), false, true)

		if durLeft > 0 then
			sirinPlayerAttack.SendMsg_AlterWeaponBulletInform(pPlayer, pEffBtCon.m_wSerial, durLeft)
		else
			Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("CONSUM: %s [%d] [%s]", pEffBtFld.m_strCode, pEffBtCon.m_lnUID, os.date(_, os.time())), false, false)
		end
	end

	-- CPlayer::SetBattleMode()
	pPlayer.m_byBattleMode = 1
	pPlayer.m_dwBattleTime = Sirin.mainThread.GetLoopTime()
	--
end

---@param pPlayer CPlayer
---@param pTarget? CCharacter
---@param x number
---@param y number
---@param z number
---@param byEffectCode integer
---@param wSkillIndex integer
---@param wBulletSerial integer
---@param wConsumeSerial_1 integer
---@param wConsumeSerial_2 integer
---@param wConsumeSerial_3 integer
---@param wEffBtSerial integer
function sirinPlayerAttack.CPlayer__pc_PlayAttack_Skill(pPlayer, pTarget, x, y, z, byEffectCode, wSkillIndex, wBulletSerial, wConsumeSerial_1, wConsumeSerial_2, wConsumeSerial_3, wEffBtSerial)
	local pSkillFld = baseToSkill(g_Main:m_tblEffectData_get(byEffectCode):GetRecord(wSkillIndex))
	local nEffectGroup = 0

	if byEffectCode == EFF_CODE.skill then
		nEffectGroup = pSkillFld:m_nAttType_get(pPlayer.m_pmMst:GetSkillLv(pSkillFld.m_dwIndex))
	else
		nEffectGroup = pSkillFld:m_nAttType_get(0)
	end

	if nEffectGroup == 4 then
		x, y, z = pPlayer.m_fCurPos_x, pPlayer.m_fCurPos_y, pPlayer.m_fCurPos_z
	end

	if pTarget then
		x, y, z = pTarget.m_fCurPos_x, pTarget.m_fCurPos_y, pTarget.m_fCurPos_z
	end

	local nErr, pBulletCon, pBulletFld, pEffBtCon, pEffBtFld, wHPCost, wFPCost, wSPCost = pPlayer:_pre_check_skill_attack(pTarget, x, y, z, byEffectCode, pSkillFld, wBulletSerial, nEffectGroup, wEffBtSerial)
	local consSerials = {wConsumeSerial_1, wConsumeSerial_2, wConsumeSerial_3}
	local consData = consumeListCache[byEffectCode][pSkillFld.m_dwIndex]

	if not consData then -- fill cache table
		local consumeList = {}

		for i = 0, 2 do
			repeat
				local cl = pSkillFld:m_ConsumeItemList_get(i)

				if cl.m_itmNeedItemCode ~= "-1" then
					local tableCode = GetItemTableCode(cl.m_itmNeedItemCode)

					if tableCode ~= -1 then
						local pFld = g_Main:m_tblItemData_get(tableCode):GetRecordByHash(cl.m_itmNeedItemCode, 2, 5)

						if pFld then
							---@type sirin_consume_data
							local data = {
								byTableCode = tableCode,
								wItemIndex = pFld.m_dwIndex,
								nConsumeNum = cl.m_nNeedItemCount,
							}

							table.insert(consumeList, data)
							break
						end
					end

					table.insert(consumeList, {byTableCode = -1, wItemIndex = 0xFFFF, nConsumeNum = 0})
				end
			until true
		end

		consumeListCache[byEffectCode][pSkillFld.m_dwIndex] = consumeList
		consData = consumeList
	end

	local bConsSucc, consList = sirinPlayerAttack.GetUseConsumeItem(pPlayer, consData, consSerials)

	if nErr == 0 and not bConsSucc then
		nErr = -61
	end

	if nErr ~= 0 then
		sirinPlayerAttack.SendMsg_AttackResult_Error(pPlayer, nErr)

		if pPlayer.m_bMove then
			pPlayer:Stop()
			pPlayer:SendMsg_BreakStop()
		end

		return
	end

	local fBulletGARate = 1.0
	local fEffBtGARate = 1.0
	local wBulletIndex = 0xFFFF

	if pBulletCon and pBulletFld then
		fBulletGARate = pBulletFld.m_fGAAF
		wBulletIndex = pBulletCon.m_wItemIndex
	end

	if pEffBtCon and pEffBtFld then
		fEffBtGARate = pEffBtFld.m_fGAAF
	end

	local pAT = sirinPlayerAttack.make_skill_attack_param(pPlayer, pTarget, x, y, z, byEffectCode, pSkillFld, nEffectGroup, pBulletFld, fBulletGARate, pEffBtFld, fEffBtGARate)

	if pAT.m_pp.nShotNum > pBulletCon.m_dwDur then
		pAT.m_pp.nShotNum = pBulletCon.m_dwDur
	end

	if pEffBtCon and pEffBtFld then
		pAT:AttackSkill(true)
	else
		pAT:AttackSkill(false)
	end

	if pAT.m_DamList[1].m_nDamage > 0 and pPlayer.m_pmWpn.nActiveType > -1 and math.random(100) <= pPlayer.m_pmWpn.nActiveProb then
		local bSFsucc, nSFShotNum = sirinPlayerAttack.WeaponSFActive(pPlayer, pAT.m_DamList, pAT.m_pp.nShotNum, wBulletSerial)
		pAT.m_bActiveSucc = bSFsucc
		pAT.m_pp.nShotNum = pAT.m_pp.nShotNum + (nSFShotNum or 0)
		pAT.m_nDamagedObjNum = #pAT.m_DamList
	end

	pPlayer.m_AttDelayChker:SetDelay(math.floor(pSkillFld.m_fActDelay) + pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.SK_Spd))

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Res_Att) then
		pPlayer:RemoveSFContHelpByEffect(2, _EFF_STATE.Res_Att)
	end

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Suspend_Lck) then
		if pAT.m_pp.nAttactType < 4 or pAT.m_pp.nAttactType > 7 then -- not 4 5 6 7 
			return
		end

		pPlayer:RemoveSFContHelpByEffect(2, _EFF_STATE.Suspend_Lck)
	end

	local newHP = PlayerMgr.GetGauge(pPlayer, 1) - wHPCost

	if newHP < 0 then
		newHP = 0
	end

	 PlayerMgr.SetGauge(pPlayer, 1, newHP, true)

	local newFP = PlayerMgr.GetGauge(pPlayer, 2) - wFPCost

	if newFP < 0 then
		newFP = 0
	end

	PlayerMgr.SetGauge(pPlayer, 2, newFP, true)

	local newSP = PlayerMgr.GetGauge(pPlayer, 3) - wSPCost

	if newSP < 0 then
		newSP = 0
	end

	PlayerMgr.SetGauge(pPlayer, 3, newSP, true)

	-- CPlayer::SendMsg_Recover()
	sendBuf:Init()
	sendBuf:PushUInt16(PlayerMgr.GetGauge(pPlayer, 1))
	sendBuf:PushUInt16(PlayerMgr.GetGauge(pPlayer, 2))
	sendBuf:PushUInt16(PlayerMgr.GetGauge(pPlayer, 3))
	sendBuf:PushUInt16(pPlayer.m_Param.m_dbChar.m_dwDP)
	sendBuf:SendBuffer(pPlayer, 11, 2)
	--

	local kPartyExpNotify = sirin_CPartyModeKillMonsterExpNotify:new()

	if not pAT.m_bFailure then
		local nTotalDam = sirinPlayerAttack._check_exp_after_attack(pPlayer, pAT.m_DamList, kPartyExpNotify)

		--if nTotalDam > 0 then -- not checked in skill
			sirinPlayerAttack._check_dst_param_after_attack(pPlayer, nTotalDam, pTarget)
		--end
	end

	if pBulletCon and pBulletFld and pAT.m_pp.nShotNum > 0 then
		local durLeft = pPlayer:Emb_AlterDurPoint(STORAGE_POS.embellish, pBulletCon.m_byStorageIndex, -(pAT.m_pp.nShotNum), false, true)

		if durLeft > 0 then
			sirinPlayerAttack.SendMsg_AlterWeaponBulletInform(pPlayer, pBulletCon.m_wSerial, durLeft)
		else
			Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("CONSUM: %s [%d] [%s]", pBulletFld.m_strCode, pBulletCon.m_lnUID, os.date(_, os.time())), false, false)
		end
	end

	if pEffBtCon and pEffBtFld and pAT.m_pp.nEffShotNum > 0 then
		local durLeft = pPlayer:Emb_AlterDurPoint(STORAGE_POS.embellish, pEffBtCon.m_byStorageIndex, -(pAT.m_pp.nEffShotNum), false, true)

		if durLeft > 0 then
			sirinPlayerAttack.SendMsg_AlterWeaponBulletInform(pPlayer, pEffBtCon.m_wSerial, durLeft)
		else
			Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("CONSUM: %s [%d] [%s]", pEffBtFld.m_strCode, pEffBtCon.m_lnUID, os.date(_, os.time())), false, false)
		end
	end

	PlayerMgr.DeleteUseConsumeItem(pPlayer, consList)

	if pSkillFld.m_nAttackable == 2 then
		pAT.m_bIsCrtAtt = true
	end

	sirinPlayerAttack.SendMsg_AttackResult_Skill(pPlayer, byEffectCode, pAT, wBulletIndex)
	kPartyExpNotify:Notify()

	local totalMasteryCumul = 0
	local targetCount = 0

	for _,d in ipairs(pAT.m_DamList) do
		repeat
			d.m_pChar:SetDamage(d.m_nDamage + d.m_nActiveDamage, pPlayer, pPlayer:GetLevel(), pAT.m_bIsCrtAtt, -1, 0, true)

			if pPlayer:GetObjRace() == d.m_pChar:GetObjRace() then
				break
			end

			if pAT.m_bFailure then
				break
			end

			if byEffectCode ~= EFF_CODE.skill or pSkillFld.m_nMastIndex >= 8 then
				break
			end

			-- CPlayer::IsPassMasteryLimitLvDiff()
			local lvDiff = pPlayer:GetLevel() - d.m_pChar:GetLevel()

			if lvDiff >= -10 and lvDiff <= 3 then
				if d.m_nDamage / d.m_pChar:GetMaxHP() >= 0.01 then
					-- CPlayer::GetMasteryCumAfterAttack(
					if lvDiff >= 0 then
						lvDiff = 1
					elseif lvDiff < -5 then
						lvDiff = 5
					else
						lvDiff = -(lvDiff)
					end

					local point = math.ceil(d.m_pChar:GetLevel() / 10)
					totalMasteryCumul = totalMasteryCumul + ((lvDiff > point and point or lvDiff) * (pSkillFld.m_nClass == 1) and 2 or 1)
					--
					targetCount = targetCount + 1
				end
			end
			--

		until true
	end

	if byEffectCode == EFF_CODE.skill and targetCount > 0 and not pPlayer:IsInTown() then
		local dwStatAlter = math.floor(totalMasteryCumul / targetCount)

		if dwStatAlter > 0 then
			pPlayer:Emb_AlterStat(3, pSkillFld.m_dwIndex, dwStatAlter, 0, "sirinPlayerAttack.CPlayer__pc_PlayAttack_Skill()---0", true)

			if pPlayer.m_pmWpn.byWpType == 7 then
				pPlayer:Emb_AlterStat(6, 0, 1, 0, "sirinPlayerAttack.CPlayer__pc_PlayAttack_Skill---1", true)
			else
				pPlayer:Emb_AlterStat(0, pPlayer.m_pmWpn.byWpClass, 1, 0, "sirinPlayerAttack.CPlayer__pc_PlayAttack_Skill---2", true)
			end
		end
	end

	if pTarget and pTarget:GetHP() > 0 then
		-- CAnimus::MasterAttack_MasterInform()
		if pPlayer.m_pRecalledAnimusChar and not pPlayer.m_pRecalledAnimusChar.m_pTarget then
			pPlayer.m_pRecalledAnimusChar.m_pTarget = pTarget
		end
		--
		-- _TOWER_PARAM::NotifyOwnerAttackInform()
		for i = 0, 6 do
			local list = pPlayer.m_pmTwr:m_List_get(i)

			if list.m_pTowerObj then
				local pTowerFld = baseToGuardTowerItem(list.m_pTowerObj.m_pRecordSet)
				if list.m_pTowerObj.m_pCurMap == pTarget.m_pCurMap
				and not IsSameObject(list.m_pTowerObj.m_pMasterSetTarget, pTarget)
				and math.abs(list.m_pTowerObj.m_fCurPos_y - pTarget.m_fCurPos_y) <= 400
				and GetSqrt(list.m_pTowerObj.m_fCurPos_x, list.m_pTowerObj.m_fCurPos_z, pTarget.m_fCurPos_x, pTarget.m_fCurPos_z) <= pTowerFld.m_nGADst + pTarget:GetWidth() / 2 then
					list.m_pTowerObj.m_pMasterSetTarget = pTarget
					list.m_pTowerObj.m_pTarget = nil
				end
			end
		end
		--
	end

	if pPlayer:IsSiegeMode() and pPlayer:Emb_AlterDurPoint(STORAGE_POS.inven, pPlayer.m_pSiegeItem.m_byStorageIndex, -1, false, true) == 0 then
		local pSiegeFld = g_Main:m_tblItemData_get(TBL_CODE.siegekit):GetRecord(pPlayer.m_pSiegeItem.m_wItemIndex)

		Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("CONSUM: %s [%d] [%s]", pSiegeFld.m_strCode, pEffBtCon.m_lnUID, os.date(_, os.time())), false, false)
	end

	-- CPlayer::SetBattleMode()
	pPlayer.m_byBattleMode = 1
	pPlayer.m_dwBattleTime = Sirin.mainThread.GetLoopTime()
	--
end

---@param pPlayer CPlayer
---@param pTarget? CCharacter
---@param x number
---@param y number
---@param z number
---@param wForceSerial integer
---@param wConsumeSerial_1 integer
---@param wConsumeSerial_2 integer
---@param wConsumeSerial_3 integer
---@param wEffBtSerial integer
function sirinPlayerAttack.CPlayer__pc_PlayAttack_Force(pPlayer, pTarget, x, y, z, wForceSerial, wConsumeSerial_1, wConsumeSerial_2, wConsumeSerial_3, wEffBtSerial)
	if pTarget then
		x, y, z = pTarget.m_fCurPos_x, pTarget.m_fCurPos_y, pTarget.m_fCurPos_z
	end

	local nErr, pForceItemCon, pForceFld, pEffBtCon, pEffBtFld, wHPCost, wFPCost, wSPCost = pPlayer:_pre_check_force_attack(pTarget, x, y, z, wForceSerial, wEffBtSerial)

	local consSerials = {wConsumeSerial_1, wConsumeSerial_2, wConsumeSerial_3}
	local consData = consumeListCache[EFF_CODE.force][pForceFld.m_dwIndex]

	if not consData then -- fill cache table
		local consumeList = {}

		for i = 0, 2 do
			repeat
				local cl = pForceFld:m_ConsumeItemList_get(i)

				if cl.m_itmNeedItemCode ~= "-1" then
					local tableCode = GetItemTableCode(cl.m_itmNeedItemCode)

					if tableCode ~= -1 then
						local pFld = g_Main:m_tblItemData_get(tableCode):GetRecordByHash(cl.m_itmNeedItemCode, 2, 5)

						if pFld then
							---@type sirin_consume_data
							local data = {
								byTableCode = tableCode,
								wItemIndex = pFld.m_dwIndex,
								nConsumeNum = cl.m_nNeedItemCount,
							}

							table.insert(consumeList, data)
							break
						end
					end

					table.insert(consumeList, {byTableCode = -1, wItemIndex = 0xFFFF, nConsumeNum = 0})
				end
			until true
		end

		consumeListCache[EFF_CODE.force][pForceFld.m_dwIndex] = consumeList
		consData = consumeList
	end

	local bConsSucc, consList = sirinPlayerAttack.GetUseConsumeItem(pPlayer, consData, consSerials)

	if nErr == 0 and not bConsSucc then
		nErr = -61
	end

	if nErr ~= 0 then
		sirinPlayerAttack.SendMsg_AttackResult_Error(pPlayer, nErr)

		if pPlayer.m_bMove then
			pPlayer:Stop()
			pPlayer:SendMsg_BreakStop()
		end

		return
	end

	if pForceFld.m_nEffectGroup == 4 or pForceFld.m_nEffectGroup == 6 then
		pTarget = nil
	end

	if pForceFld.m_nEffectGroup == 4 then
		x, y, z = pPlayer.m_fCurPos_x, pPlayer.m_fCurPos_y, pPlayer.m_fCurPos_z
	end

	local fEffBtGARate = 1.0

	if pEffBtCon and pEffBtFld then
		fEffBtGARate = pEffBtFld.m_fGAAF
	end

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Res_Att) then
		pPlayer:RemoveSFContHelpByEffect(2, _EFF_STATE.Res_Att)
	end

	local pAT = sirinPlayerAttack.make_force_attack_param(pPlayer, pTarget, x, y, z, pForceFld, PlayerMgr.GetSFLevel(pForceFld.m_nLv, pForceItemCon.m_dwDur), pEffBtFld, fEffBtGARate)

	if pEffBtCon and pEffBtFld then
		pAT:AttackForce(true)
	else
		pAT:AttackForce(false)
	end

	if pAT.m_DamList[1].m_nDamage > 0 and pPlayer.m_pmWpn.nActiveType > -1 and math.random(100) <= pPlayer.m_pmWpn.nActiveProb then
		local bSFsucc, nSFShotNum = sirinPlayerAttack.WeaponSFActive(pPlayer, pAT.m_DamList, pAT.m_pp.nShotNum, 0xFFFF)
		pAT.m_bActiveSucc = bSFsucc
		pAT.m_pp.nShotNum = pAT.m_pp.nShotNum + (nSFShotNum or 0)
		pAT.m_nDamagedObjNum = #pAT.m_DamList
	end

	pPlayer.m_AttDelayChker:SetDelay(math.floor(pForceFld.m_fActDelay) + pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.FC_Spd))

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Suspend_Lck) then
		if pAT.m_pp.nAttactType < 4 or pAT.m_pp.nAttactType > 7 then -- not 4 5 6 7 
			return
		end

		pPlayer:RemoveSFContHelpByEffect(2, _EFF_STATE.Suspend_Lck)
	end

	local newHP = PlayerMgr.GetGauge(pPlayer, 1) - wHPCost

	if newHP < 0 then
		newHP = 0
	end

	 PlayerMgr.SetGauge(pPlayer, 1, newHP, true)

	local newFP = PlayerMgr.GetGauge(pPlayer, 2) - wFPCost

	if newFP < 0 then
		newFP = 0
	end

	PlayerMgr.SetGauge(pPlayer, 2, newFP, true)

	local newSP = PlayerMgr.GetGauge(pPlayer, 3) - wSPCost

	if newSP < 0 then
		newSP = 0
	end

	PlayerMgr.SetGauge(pPlayer, 3, newSP, true)

	-- CPlayer::SendMsg_Recover()
	sendBuf:Init()
	sendBuf:PushUInt16(PlayerMgr.GetGauge(pPlayer, 1))
	sendBuf:PushUInt16(PlayerMgr.GetGauge(pPlayer, 2))
	sendBuf:PushUInt16(PlayerMgr.GetGauge(pPlayer, 3))
	sendBuf:PushUInt16(pPlayer.m_Param.m_dbChar.m_dwDP)
	sendBuf:SendBuffer(pPlayer, 11, 2)
	--

	local kPartyExpNotify = sirin_CPartyModeKillMonsterExpNotify:new()

	if not pAT.m_bFailure then
		local nTotalDam = sirinPlayerAttack._check_exp_after_attack(pPlayer, pAT.m_DamList, kPartyExpNotify)

		if nTotalDam > 0 then
			sirinPlayerAttack._check_dst_param_after_attack(pPlayer, nTotalDam, pTarget)
		end
	end

	if pEffBtCon and pEffBtFld and pAT.m_pp.nEffShotNum > 0 then
		local durLeft = pPlayer:Emb_AlterDurPoint(STORAGE_POS.embellish, pEffBtCon.m_byStorageIndex, -(pAT.m_pp.nEffShotNum), false, true)

		if durLeft > 0 then
			sirinPlayerAttack.SendMsg_AlterWeaponBulletInform(pPlayer, pEffBtCon.m_wSerial, durLeft)
		else
			Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("CONSUM: %s [%d] [%s]", pEffBtFld.m_strCode, pEffBtCon.m_lnUID, os.date(_, os.time())), false, false)
		end
	end

	PlayerMgr.DeleteUseConsumeItem(pPlayer, consList)
	sirinPlayerAttack.SendMsg_AttackResult_Force(pPlayer, pAT)
	kPartyExpNotify:Notify()

	local totalMasteryCumul = 0
	local targetCount = 0

	for _,d in ipairs(pAT.m_DamList) do
		repeat
			d.m_pChar:SetDamage(d.m_nDamage + d.m_nActiveDamage, pPlayer, pPlayer:GetLevel(), pAT.m_bIsCrtAtt, -1, 0, true)

			if pPlayer:GetObjRace() == d.m_pChar:GetObjRace() then
				break
			end

			if pAT.m_bFailure then
				break
			end

			if pForceFld.m_nMastIndex >= 24 then
				break
			end

			-- CPlayer::IsPassMasteryLimitLvDiff()
			local lvDiff = pPlayer:GetLevel() - d.m_pChar:GetLevel()

			if lvDiff >= -10 and lvDiff <= 3 then
				if d.m_nDamage / d.m_pChar:GetMaxHP() >= 0.01 then
					-- CPlayer::GetMasteryCumAfterAttack(
					if lvDiff >= 0 then
						lvDiff = 1
					elseif lvDiff < -5 then
						lvDiff = 5
					else
						lvDiff = -(lvDiff)
					end

					local point = math.ceil(d.m_pChar:GetLevel() / 10)
					totalMasteryCumul = totalMasteryCumul + (lvDiff > point and point or lvDiff)
					--
					targetCount = targetCount + 1
				end
			end
			--

		until true
	end

	if targetCount > 0 and not pPlayer:IsInTown() then
		local dwStatAlter = math.floor(totalMasteryCumul / targetCount)

		if dwStatAlter > 0 then
			pPlayer:Emb_AlterStat(4, pForceFld.m_nMastIndex, dwStatAlter, 0, "sirinPlayerAttack.CPlayer__pc_PlayAttack_Force()---0", true)

			local dwForceAlter = 5 * (pPlayer:GetLevel() / 10 + 1) * dwStatAlter
			local fHaveRate_Mastery = pPlayer.m_EP:GetEff_Have(_EFF_HAVE.Mastery_Prof)
			dwForceAlter = dwForceAlter * (pPlayer:IsApplyPcbangPrimium() and Sirin.mainThread.PCBANG_PRIMIUM_FAVOR__SKILL_FORCE_MASTERY or Sirin.mainThread.FORCE_LIVER_ACCUM_RATE) + (fHaveRate_Mastery <= 1 and 0 or (dwForceAlter * (fHaveRate_Mastery - 1)))
			local dwNewDur = pPlayer:Emb_AlterDurPoint(STORAGE_POS.force, pForceItemCon.m_byStorageIndex, math.floor(dwForceAlter), false, true)
			-- CPlayer::SendMsg_FcitemInform()
			sendBuf:Init()
			sendBuf:PushUInt16(wForceSerial)
			sendBuf:PushUInt32(dwNewDur)
			sendBuf:SendBuffer(pPlayer, 3, 44)
			--
		end
	end

	if pTarget and pTarget:GetHP() > 0 then
		-- CAnimus::MasterAttack_MasterInform()
		if pPlayer.m_pRecalledAnimusChar and not pPlayer.m_pRecalledAnimusChar.m_pTarget then
			pPlayer.m_pRecalledAnimusChar.m_pTarget = pTarget
		end
		--
		-- _TOWER_PARAM::NotifyOwnerAttackInform()
		for i = 0, 6 do
			local list = pPlayer.m_pmTwr:m_List_get(i)

			if list.m_pTowerObj then
				local pTowerFld = baseToGuardTowerItem(list.m_pTowerObj.m_pRecordSet)
				if list.m_pTowerObj.m_pCurMap == pTarget.m_pCurMap
				and not IsSameObject(list.m_pTowerObj.m_pMasterSetTarget, pTarget)
				and math.abs(list.m_pTowerObj.m_fCurPos_y - pTarget.m_fCurPos_y) <= 400
				and GetSqrt(list.m_pTowerObj.m_fCurPos_x, list.m_pTowerObj.m_fCurPos_z, pTarget.m_fCurPos_x, pTarget.m_fCurPos_z) <= pTowerFld.m_nGADst + pTarget:GetWidth() / 2 then
					list.m_pTowerObj.m_pMasterSetTarget = pTarget
					list.m_pTowerObj.m_pTarget = nil
				end
			end
		end
		--
	end

	-- CPlayer::SetBattleMode()
	pPlayer.m_byBattleMode = 1
	pPlayer.m_dwBattleTime = Sirin.mainThread.GetLoopTime()
	--
end

---@param pPlayer CPlayer
---@param pTarget CCharacter
---@param byWeaponPart integer
function sirinPlayerAttack.CPlayer__pc_PlayAttack_Unit(pPlayer, pTarget, byWeaponPart)
	local nErr, pUnitWeaponFld, pBulletFld, wLeftNum = pPlayer:_pre_check_unit_attack(pTarget, byWeaponPart)

	if nErr ~= 0 then
		sirinPlayerAttack.SendMsg_AttackResult_Error(pPlayer, nErr)

		if pPlayer.m_bMove then
			pPlayer:Stop()
			pPlayer:SendMsg_BreakStop()
		end

		return
	end

	local fBulletGARate = 1.0
	local wBulletIndex = 0xFFFF

	if pBulletFld then
		fBulletGARate = pBulletFld.m_fGAAF
		wBulletIndex = pBulletFld.m_dwIndex
	end

	local pAT = sirinPlayerAttack.make_unit_attack_param(pPlayer, pTarget, pUnitWeaponFld, fBulletGARate)

	pPlayer.m_byUsingWeaponPart = byWeaponPart
	pAT:AttackUnit(fBulletGARate)
	pPlayer.m_AttDelayChker:SetDelay(pUnitWeaponFld.m_nAttackDel)

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Res_Att) then
		pPlayer:RemoveSFContHelpByEffect(2, _EFF_STATE.Res_Att)
	end

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Suspend_Lck) then
		if pAT.m_pp.nAttactType < 4 or pAT.m_pp.nAttactType > 7 then -- not 4 5 6 7 
			return
		end

		pPlayer:RemoveSFContHelpByEffect(2, _EFF_STATE.Suspend_Lck)
	end

	local kPartyExpNotify = sirin_CPartyModeKillMonsterExpNotify:new()

	if not pAT.m_bFailure then
		sirinPlayerAttack._check_exp_after_attack(pPlayer, pAT.m_DamList, kPartyExpNotify)
	end

	wLeftNum = wLeftNum - pUnitWeaponFld.m_nNeedBt

	if wLeftNum < 0 then
		wLeftNum = 0
	end

	-- CPlayer::SendMsg_AlterUnitBulletInform(...)
	sendBuf:Init()
	sendBuf:PushUInt8(byWeaponPart)
	sendBuf:PushUInt16(wLeftNum)
	sendBuf:SendBuffer(pPlayer, 5, 22)
	--

	if wLeftNum == 0 then
		pPlayer.m_pUsingUnit:dwBullet_set(byWeaponPart, 0xFFFFFFFF)
	else
		pPlayer.m_pUsingUnit:dwBullet_set(byWeaponPart, (wLeftNum << 16) + pBulletFld.m_dwIndex)
	end

	sirinPlayerAttack.SendMsg_AttackResult_Unit(pPlayer, pAT, byWeaponPart, wBulletIndex)
	kPartyExpNotify:Notify()

	for _,d in ipairs(pAT.m_DamList) do
		d.m_pChar:SetDamage(d.m_nDamage + d.m_nActiveDamage, pPlayer, pPlayer:GetLevel(), pAT.m_bIsCrtAtt, -1, 0, true)
	end

	-- CPlayer::SetBattleMode()
	pPlayer.m_byBattleMode = 1
	pPlayer.m_dwBattleTime = Sirin.mainThread.GetLoopTime()
	--
end

---@param pPlayer CPlayer
---@param pTarget CCharacter
---@param x number
---@param y number
---@param z number
---@param byAttPart integer
---@param wBulletSerial integer
---@param wEffBtSerial integer
function sirinPlayerAttack.CPlayer__pc_PlayAttack_Siege(pPlayer, pTarget, x, y, z, byAttPart, wBulletSerial, wEffBtSerial)
	if pTarget then
		x = pTarget.m_fCurPos_x
		y = pTarget.m_fCurPos_y
		z = pTarget.m_fCurPos_z
	end

	local nErr, pBulletCon, pBulletFld, pEffBtCon, pEffBtFld = pPlayer:_pre_check_siege_attack(pTarget, x, y, z, wBulletSerial, wEffBtSerial)

	if nErr ~= 0 then
		sirinPlayerAttack.SendMsg_AttackResult_Error(pPlayer, nErr)

		if pPlayer.m_bMove then
			pPlayer:Stop()
			pPlayer:SendMsg_BreakStop()
		end

		return
	end

	local fBulletGARate = 1.0
	local fEffBtGARate = 1.0
	local wBulletIndex = 0xFFFF

	if pBulletCon and pBulletFld then
		fBulletGARate = pBulletFld.m_fGAAF
		wBulletIndex = pBulletCon.m_wItemIndex
	end

	if pEffBtCon and pEffBtFld then
		fEffBtGARate = pEffBtFld.m_fGAAF
	end

	local pAT = sirinPlayerAttack.make_siege_attack_param(pPlayer, pTarget, x, y, z, byAttPart, pBulletFld, fBulletGARate, pEffBtFld, fEffBtGARate)

	if pEffBtCon and pEffBtFld then
		pAT:AttackGen(false, true)
	else
		pAT:AttackGen(false, false)
	end

	-- stupid piece of default logic
	for _,d in ipairs(pAT.m_DamList) do
		d.m_nDamage = math.floor(d.m_nDamage * 1.25)
	end

	local dwDelay = sirinPlayerAttack.CalcEquipAttackDelay(pPlayer) + 1000

	if pPlayer.m_pmWpn.byWpType ~= 7 then
		dwDelay = dwDelay + pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.GE_Att_Spd_ + pPlayer.m_pmWpn.byWpClass)
	else
		dwDelay = dwDelay + pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.Lcr_Att_Spd)
	end

	pPlayer.m_AttDelayChker:SetDelay(dwDelay)

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Res_Att) then
		pPlayer:RemoveSFContHelpByEffect(2, _EFF_STATE.Res_Att)
	end

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Suspend_Lck) then
		if pAT.m_pp.nAttactType < 4 or pAT.m_pp.nAttactType > 7 then -- not 4 5 6 7 
			return
		end

		pPlayer:RemoveSFContHelpByEffect(2, _EFF_STATE.Suspend_Lck)
	end

	if pPlayer.m_bFreeSFByClass then
		pAT.m_bIsCrtAtt = true
	end

	local kPartyExpNotify = sirin_CPartyModeKillMonsterExpNotify:new()

	if not pAT.m_bFailure then
		local nTotalDam = sirinPlayerAttack._check_exp_after_attack(pPlayer, pAT.m_DamList, kPartyExpNotify)

		if nTotalDam > 0 then -- not checked in skill
			sirinPlayerAttack._check_dst_param_after_attack(pPlayer, nTotalDam, pTarget)
		end
	end

	sirinPlayerAttack.SendMsg_AttackResult_Siege(pPlayer, pAT, wBulletIndex)
	kPartyExpNotify:Notify()

	local totalMasteryCumul = 0
	local targetCount = 0

	for _,d in ipairs(pAT.m_DamList) do
		repeat
			d.m_pChar:SetDamage(d.m_nDamage + d.m_nActiveDamage, pPlayer, pPlayer:GetLevel(), pAT.m_bIsCrtAtt, -1, 0, true)

			if pPlayer:GetObjRace() == d.m_pChar:GetObjRace() then
				break
			end

			if pAT.m_bFailure then
				break
			end

			-- CPlayer::IsPassMasteryLimitLvDiff()
			local lvDiff = pPlayer:GetLevel() - d.m_pChar:GetLevel()

			if lvDiff >= -10 and lvDiff <= 3 then
				if d.m_nDamage / d.m_pChar:GetMaxHP() >= 0.03 then
					-- CPlayer::GetMasteryCumAfterAttack(
					if lvDiff >= 0 then
						lvDiff = 1
					elseif lvDiff < -5 then
						lvDiff = 5
					else
						lvDiff = -(lvDiff)
					end

					local point = math.ceil(d.m_pChar:GetLevel() / 10)
					totalMasteryCumul = totalMasteryCumul + (lvDiff > point and point or lvDiff)
					--
					targetCount = targetCount + 1
				end
			end
			--

		until true
	end

	if targetCount > 0 and not pPlayer:IsInTown() then
		local dwStatAlter = math.floor(totalMasteryCumul / targetCount)

		if dwStatAlter > 0 then
			if pPlayer.m_pmWpn.byWpType == 7 then
				pPlayer:Emb_AlterStat(6, 0, dwStatAlter, 0, "sirinPlayerAttack.CPlayer__pc_PlayAttack_Siege()---0", true)
			else
				pPlayer:Emb_AlterStat(0, pPlayer.m_pmWpn.byWpClass, dwStatAlter, 0, "sirinPlayerAttack.CPlayer__pc_PlayAttack_Siege()---1", true)
			end
		end
	end

	if pBulletCon and pBulletFld and pAT.m_pp.nShotNum > 0 then
		local durLeft = pPlayer:Emb_AlterDurPoint(STORAGE_POS.embellish, pBulletCon.m_byStorageIndex, -(pAT.m_pp.nShotNum), false, true)

		if durLeft > 0 then
			sirinPlayerAttack.SendMsg_AlterWeaponBulletInform(pPlayer, pBulletCon.m_wSerial, durLeft)
		else
			Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("CONSUM: %s [%d] [%s]", pBulletFld.m_strCode, pBulletCon.m_lnUID, os.date(_, os.time())), false, false)
		end
	end

	if pEffBtCon and pEffBtFld and pAT.m_pp.nEffShotNum > 0 then
		local durLeft = pPlayer:Emb_AlterDurPoint(STORAGE_POS.embellish, pEffBtCon.m_byStorageIndex, -(pAT.m_pp.nEffShotNum), false, true)

		if durLeft > 0 then
			sirinPlayerAttack.SendMsg_AlterWeaponBulletInform(pPlayer, pEffBtCon.m_wSerial, durLeft)
		else
			Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("CONSUM: %s [%d] [%s]", pEffBtFld.m_strCode, pEffBtCon.m_lnUID, os.date(_, os.time())), false, false)
		end
	end

	if pPlayer:IsSiegeMode() then
		local durLeft = pPlayer:Emb_AlterDurPoint(STORAGE_POS.inven, pPlayer.m_pSiegeItem.m_byStorageIndex, -1, false, true)

		if durLeft == 0 then
			local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(TBL_CODE.siegekit):GetRecord(pPlayer.m_pSiegeItem.m_wItemIndex)
			Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("CONSUM: %s [%d] [%s]", pFld.m_strCode, pPlayer.m_pSiegeItem.m_lnUID, os.date(_, os.time())), false, false)
		end
	end

	-- CPlayer::SetBattleMode()
	pPlayer.m_byBattleMode = 1
	pPlayer.m_dwBattleTime = Sirin.mainThread.GetLoopTime()
	--
end

---@param pPlayer CPlayer
function sirinPlayerAttack.CPlayer__pc_PlayAttack_SelfDestruction(pPlayer)
	local nErr = 0

	repeat
		if not pPlayer:IsAttackableInTown() and pPlayer:IsInTown() then
			nErr = -31
			break
		end

		if pPlayer.m_pmWpn.byWpType == 11 or pPlayer.m_pmWpn.byWpType == 10 then
			nErr = -9
			break
		end

		if pPlayer:IsRidingUnit() then
			nErr = -21
			break
		end

		if pPlayer.m_EP:GetEff_State(_EFF_STATE.Stone_Lck) then
			nErr = -37
			break
		end

		if pPlayer.m_EP:GetEff_State(_EFF_STATE.Invincible) then
			nErr = -37
			break
		end

		if pPlayer.m_EP:GetEff_State(_EFF_STATE.Suspend_Lck) then
			nErr = -38
			break
		end

		if pPlayer.m_byMoveType == 2 then
			nErr = -41
			break
		end
	until true

	if nErr ~= 0 then
		sirinPlayerAttack.SendMsg_AttackResult_Error(pPlayer, nErr)

		if pPlayer.m_bMove then
			pPlayer:Stop()
			pPlayer:SendMsg_BreakStop()
		end

		return
	end

	local pAT = SirinCAttack:new()
	pAT.m_pAttChar = pPlayer
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp

	pAP.fArea_x = pPlayer.m_fCurPos_x
	pAP.fArea_y = pPlayer.m_fCurPos_y
	pAP.fArea_z = pPlayer.m_fCurPos_z
	pAP.nPart = CharacterMgr.GetAttackRandomPart(pPlayer)
	pAP.nTol = -1
	pAP.nClass = 1
	pAP.nMinAF = math.floor(pPlayer.m_pmWpn.nGaMinAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Fg_Lcr) * pPlayer.m_fSelfDestructionDamage)
	pAP.nMaxAF = math.floor(pPlayer.m_pmWpn.nGaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Fg_Lcr) * pPlayer.m_fSelfDestructionDamage)
	pAP.nMaxAttackPnt = pPlayer.m_nMaxAttackPnt
	pAP.nMinSel = 30
	pAP.nMaxSel = 50
	pAP.nAttactType = 6
	pAP.nExtentRange = 110
	pAT:AttackGen(false, false)

	if pPlayer.m_EP:GetEff_State(_EFF_STATE.Res_Att) then
		pPlayer:RemoveSFContHelpByEffect(2, _EFF_STATE.Res_Att)
	end

	local kPartyExpNotify = sirin_CPartyModeKillMonsterExpNotify:new()

	if not pAT.m_bFailure then
		sirinPlayerAttack._check_exp_after_attack(pPlayer, pAT.m_DamList, kPartyExpNotify)
	end

	sirinPlayerAttack.SendMsg_AttackResult_SelfDestruction(pPlayer, pAT)
	kPartyExpNotify:Notify()

	for _,d in ipairs(pAT.m_DamList) do
		d.m_pChar:SetDamage(d.m_nDamage + d.m_nActiveDamage, pPlayer, pPlayer:GetLevel(), pAT.m_bIsCrtAtt, -1, 0, true)
	end

	-- CPlayer::SetBattleMode()
	pPlayer.m_byBattleMode = 1
	pPlayer.m_dwBattleTime = Sirin.mainThread.GetLoopTime()
	--

	pPlayer.m_byMoveType = 0
	pPlayer:SenseState()
	pPlayer:SetHP(1, true)
	pPlayer:SetFP(1, true)
	pPlayer:SetSP(1, true)

	-- CPlayer::SendMsg_Recover()
	sendBuf:Init()
	sendBuf:PushUInt16(PlayerMgr.GetGauge(pPlayer, 1))
	sendBuf:PushUInt16(PlayerMgr.GetGauge(pPlayer, 2))
	sendBuf:PushUInt16(PlayerMgr.GetGauge(pPlayer, 3))
	sendBuf:PushUInt16(pPlayer.m_Param.m_dbChar.m_dwDP)
	sendBuf:SendBuffer(pPlayer, 11, 2)
	--
end

return sirinPlayerAttack
