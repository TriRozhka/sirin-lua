local _EFF_RATE = _EFF_RATE
local _EFF_PLUS = _EFF_PLUS
local _EFF_STATE = _EFF_STATE
local _EFF_HAVE = _EFF_HAVE
local math = math
local objectToCharacter = Sirin.mainThread.objectToCharacter
local objectToPlayer = Sirin.mainThread.objectToPlayer
local objectToAnimus = Sirin.mainThread.objectToAnimus
local objectToTower = Sirin.mainThread.objectToTower
local objectToTrap = Sirin.mainThread.objectToTrap
local objectToAMP = Sirin.mainThread.objectToAMP

local baseToSkill = Sirin.mainThread.baseToSkill
local baseToForce = Sirin.mainThread.baseToForce

local CONST_ChipBreakerBonus_Atk = CONST_ChipBreakerBonus_Atk
local CONST_PatriarchBonus_Atk = CONST_PatriarchBonus_Atk
local CONST_AttackCouncilBonus_Atk = CONST_AttackCouncilBonus_Atk

local s_nLimitDist = CONST_nLimitDist
local s_nLimitAngle = CONST_nLimitAngle
local s_nLimitRadius = CONST_nLimitRadius

local s_nAddMstFc = {}

for i = 0, 99 do
	s_nAddMstFc[i] = math.floor(math.sqrt((i ^ 3) * 2))
end

---@class (exact) sirin_be_damaged_char
---@field __index table
---@field m_pChar CCharacter
---@field m_nDamage integer
---@field m_bActiveSucc boolean
---@field m_nActiveDamage integer
local sirin_be_damaged_char = {
	m_nDamage = 0,
	m_bActiveSucc = false,
	m_nActiveDamage = 0,
}
Sirin_be_damaged_char = sirin_be_damaged_char

---@return sirin_be_damaged_char self
function sirin_be_damaged_char:new(o)
	local _i = clone(self)
	for k,v in pairs(o or {}) do _i[k] = v end
	self.__index = self
	return setmetatable(_i, self)
end

---@class (exact) sirin_attack_param
---@field __index table
---@field pDst CCharacter?
---@field nPart integer
---@field nTol integer
---@field nClass integer
---@field nMinAF integer
---@field nMaxAF integer
---@field nMinSel integer
---@field nMaxSel integer
---@field nExtentRange integer
---@field nShotNum integer
---@field nAddAttPnt integer
---@field nWpType integer
---@field byEffectCode integer
---@field pFld _base_fld
---@field fArea_x number
---@field fArea_y number
---@field fArea_z number
---@field nLevel integer
---@field nMastery integer
---@field bPassCount boolean
---@field nAttactType integer
---@field bMatchless boolean
---@field nMaxAttackPnt integer
---@field bBackAttack boolean
---@field nMinAFPlus integer
---@field nMaxAFPlus integer
---@field nEffShotNum integer
local sirin_attack_param = {
	nPart = 0,
	nTol = 0,
	nClass = 0,
	nMinAF = 0,
	nMaxAF = 0,
	nMinSel = 0,
	nMaxSel = 0,
	nExtentRange = 0,
	nShotNum = 0,
	nAddAttPnt = 0,
	nWpType = 0,
	byEffectCode = 0,
	fArea_x = 0,
	fArea_y = 0,
	fArea_z = 0,
	nLevel = 0,
	nMastery = 0,
	bPassCount = false,
	nAttactType = 0,
	bMatchless = false,
	nMaxAttackPnt = 0,
	bBackAttack = false,
	nMinAFPlus = 0,
	nMaxAFPlus = 0,
	nEffShotNum = 0,
}

Sirin_attack_param = sirin_attack_param

---@return sirin_attack_param self
function sirin_attack_param:new(o)
	local _i = clone(self)
	for k,v in pairs(o or {}) do _i[k] = v end
	self.__index = self
	return setmetatable(_i, self)
end

---@class (exact) sirinCAttack
---@field __index table
---@field m_pp sirin_attack_param
---@field m_pAttChar CCharacter
---@field m_bIsCrtAtt boolean
---@field m_bActiveSucc boolean
---@field m_nDamagedObjNum integer
---@field m_DamList table<integer, sirin_be_damaged_char>
---@field m_bFailure boolean
---@field IsCharInSector fun(pCheckObj: CGameObject, pSrcObj: CGameObject, pDstObj: CGameObject, angle: number, radius: number): boolean
local sirinCAttack = {
	m_bIsCrtAtt = false,
	m_bActiveSucc = false,
	m_nDamagedObjNum = 0,
	m_DamList = {},
	m_bFailure = false,
}

SirinCAttack = sirinCAttack

---@return sirinCAttack self
function sirinCAttack:new(o)
	local _i = clone(self)
	for k,v in pairs(o or {}) do _i[k] = v end
	self.__index = self
	return setmetatable(_i, self)
end

---@param pDst CCharacter
---@param bBackAttack boolean
---@return integer
function sirinCAttack:MonsterCritical_Exception_Rate(pDst, bBackAttack)
	local rate = 0

	if pDst and pDst.m_ObjID.m_byID == ID_CHAR.monster then
		local pDstMon = Sirin.mainThread.objectToMonster(pDst)
		rate = pDstMon:GetCritical_Exception_Rate()
		local result, out = pDstMon:GetViewAngleCap(2)

		if bBackAttack and result then
			rate = rate * (100 - out) / 100

			if rate < 0 then
				rate = 0
			end
		end
	end

	return math.floor(rate)
end

---@param bUseEffBullet boolean
---@return integer
function sirinCAttack:_CalcGenAttPnt(bUseEffBullet)
	local nCrtAF = 0
	local nAFBlk = 0

	if bUseEffBullet then
		nCrtAF = self.m_pp.nMaxAFPlus
		nCrtAF = math.floor(nCrtAF * (nCrtAF + 125.0) / (nCrtAF + 50.0) + 0.5)
		nAFBlk = math.floor((self.m_pp.nMaxAFPlus + self.m_pp.nMinAFPlus) / 2 + 0.5)
	else
		nCrtAF = self.m_pp.nMaxAF
		nCrtAF = math.floor(nCrtAF * (nCrtAF + 125.0) / (nCrtAF + 50.0) + 0.5)
		nAFBlk = math.floor((self.m_pp.nMaxAF + self.m_pp.nMinAF) / 2 + 0.5)
	end

	if self.m_pAttChar.m_EP:GetEff_State(_EFF_STATE.Abs_Crt) or self.m_pp.nMaxAttackPnt > 0 then
		return nCrtAF
	elseif self.m_pp.nMaxAttackPnt == 0 then
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
			if bUseEffBullet then
				if nAFBlk - self.m_pp.nMinAFPlus <= 0 then
					return self.m_pp.nMinAFPlus
				else
					return self.m_pp.nMinAFPlus + math.random(0, 0x7FFF) % (nAFBlk - self.m_pp.nMinAFPlus)
				end
			else
				if nAFBlk - self.m_pp.nMinAF <= 0 then
					return self.m_pp.nMinAF
				else
					return self.m_pp.nMinAF + math.random(0, 0x7FFF) % (nAFBlk - self.m_pp.nMinAF)
				end
			end
		elseif rnd <= aboveAverage then
			if bUseEffBullet then
				if self.m_pp.nMaxAFPlus - nAFBlk <= 0 then
					return nAFBlk
				else
					return nAFBlk + math.random(0, 0x7FFF) % (self.m_pp.nMaxAFPlus - nAFBlk)
				end
			else
				if self.m_pp.nMaxAF - nAFBlk <= 0 then
					return nAFBlk
				else
					return nAFBlk + math.random(0, 0x7FFF) % (self.m_pp.nMaxAF - nAFBlk)
				end
			end
		else
			self.m_bIsCrtAtt = true
			return nCrtAF
		end
	elseif bUseEffBullet then
		return self.m_pp.nMinAFPlus
	else
		return self.m_pp.nMinAF
	end
end

---@param pPlayer CPlayer
---@param bySkill integer
---@param bNear boolean
---@param bUnit boolean
---@return number
function sirinCAttack:GetAttackFC(pPlayer, bySkill, bNear, bUnit)
	local pWeaponCon = pPlayer.m_Param.m_dbEquip:m_pStorageList_get(TBL_CODE.weapon)

	if pWeaponCon.m_byLoad == 1 then
		local pWeaponFld = Sirin.mainThread.baseToWeaponItem(Sirin.mainThread.g_Main:m_tblItemData_get(TBL_CODE.weapon):GetRecord(pWeaponCon.m_wItemIndex))
		local mastery = pPlayer.m_pmMst:GetMasteryPerMast(0, pPlayer.m_pmWpn.byWpClass)
		local attFc = 0

		if bySkill == 0 or bySkill == 1 then
			if bUnit then
				attFc = s_nAddMstFc[mastery] + pWeaponFld.m_fGAMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) -- potion ineffectinve in all MAU calculations except certain AoP
			else
				attFc = s_nAddMstFc[mastery] + pPlayer.m_pmWpn.nGaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) -- potion ineffectinve in all MAU calculations except certain AoP
			end

			if bNear and GetWeaponClass(pWeaponFld) == 0 then
				attFc = attFc * pPlayer.m_EP:GetEff_Rate(bySkill * 2 + _EFF_RATE.GE_AttFc_)
			elseif not bNear and GetWeaponClass(pWeaponFld) ~= 0 then
				attFc = attFc * pPlayer.m_EP:GetEff_Rate(bySkill * 2 + _EFF_RATE.GA1)
			else
				attFc = 0
			end
		else
			if bUnit then
				attFc = pPlayer.m_pmMst.m_mtyStaff + pWeaponFld.m_fMAMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) -- potion ineffectinve in all MAU calculations except certain AoP
			else
				attFc = pPlayer.m_pmMst.m_mtyStaff + pPlayer.m_pmWpn.nMaMaxAF * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Inc_Fc) -- potion ineffectinve in all MAU calculations except certain AoP
			end
		end

		return attFc
	else
		return 0
	end
end

function sirinCAttack:CalcAvgDamage()
	local dam = 1

	if #self.m_DamList == 1 then
		if self.m_DamList[1].m_nDamage == -2 then
			dam = 2
		else
			dam = self.m_DamList[1].m_nDamage
		end
	elseif #self.m_DamList > 1 then
		local damSum = 0

		for _,d in ipairs(self.m_DamList) do
			if  d.m_nDamage ~= -2 then
				damSum = damSum + d.m_nDamage
			end
		end

		dam = damSum / #self.m_DamList
	end

	if dam <= 1 then
		self.m_bIsCrtAtt = false
		self.m_bFailure = true
	end
end

---@param pDst CCharacter
---@return boolean bResult
---@return boolean bInGuildBattle
function sirinCAttack:CheckGuildBattleLimit(pDst)
	local bResult, bInGuildBattle = false, false

	repeat
		if self.m_pAttChar.m_ObjID.m_byID ~= ID_CHAR.player then
			break
		end

		if pDst.m_ObjID.m_byID ~= ID_CHAR.player then
			break
		end

		local pSrcPlyer = objectToPlayer(self.m_pAttChar)
		local pDstPlayer = objectToPlayer(pDst)

		if pSrcPlyer.m_bInGuildBattle or pDstPlayer.m_bInGuildBattle then
			bInGuildBattle = true
		end

		if pSrcPlyer.m_bInGuildBattle and pSrcPlyer.m_bTakeGravityStone then
			bResult = true
			break
		end

		if pDstPlayer.m_bInGuildBattle and pDstPlayer.m_bTakeGravityStone then
			bResult = true
			break
		end

		if pSrcPlyer.m_bInGuildBattle and pDstPlayer.m_bInGuildBattle and pSrcPlyer.m_byGuildBattleColorInx ~= pDstPlayer.m_byGuildBattleColorInx then
			break
		end

		if bInGuildBattle then
			bResult = true
		end

	until true

	return bResult, bInGuildBattle
end

---@param pCheckObj CGameObject
---@param pSrcObj CGameObject
---@param pDstObj CGameObject
---@param angle number
---@param radius number
---@return boolean
function sirinCAttack.IsCharInSector(pCheckObj, pSrcObj, pDstObj, angle, radius)
	if pSrcObj.m_fCurPos_x == pDstObj.m_fCurPos_x and pSrcObj.m_fCurPos_z == pDstObj.m_fCurPos_z then
		return false
	end

	if pCheckObj.m_fCurPos_x == pDstObj.m_fCurPos_x and pCheckObj.m_fCurPos_z == pDstObj.m_fCurPos_z then
		return true
	end

	local ax, ay, az = pCheckObj.m_fCurPos_x - pDstObj.m_fCurPos_x, pCheckObj.m_fCurPos_y - pDstObj.m_fCurPos_y, pCheckObj.m_fCurPos_z - pDstObj.m_fCurPos_z
	local tmp = math.sqrt(ax ^ 2 + ay ^ 2 + az ^ 2)

	if tmp > radius then
		return false
	end

	ax = ax / tmp
	ay = ay / tmp
	az = az / tmp

	local bx, by, bz = pDstObj.m_fCurPos_x - pSrcObj.m_fCurPos_x, pDstObj.m_fCurPos_y - pSrcObj.m_fCurPos_y, pDstObj.m_fCurPos_z - pSrcObj.m_fCurPos_z

	tmp = math.sqrt(bx ^ 2 + by ^ 2 + bz ^ 2)
	bx = bx / tmp
	by = by / tmp
	bz = bz / tmp

	if math.deg((math.acos(ax * bx + ay * by + az * bz))) < angle / 2 then
		return true
	end

	return false
end

---@param bMustMiss boolean
---@param bUseEffBullet boolean
function sirinCAttack:AttackGen(bMustMiss, bUseEffBullet)
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

		if self.m_pp.bMatchless then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = pDst:GetHP() }
			self.m_nDamagedObjNum = 1
			return
		end

		if pDst.m_EP:GetEff_State(_EFF_STATE.Abs_Avd) then
			bSucc = false
		else
			if self.m_pAttChar:GetGenAttackProb(pDst, self.m_pp.nPart, self.m_pp.bBackAttack) < math.random(0, 99) then
				bSucc = false
			end
		end

		if bSucc and bMustMiss then
			bSucc = false
		end

		if not bSucc then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
			self.m_nDamagedObjNum = 1
			return
		end
	end

	local attPnt = self:_CalcGenAttPnt(false)
	local attPntEff = self:_CalcGenAttPnt(true)

	if self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.player then
		local pSrcPlayer = objectToPlayer(self.m_pAttChar)

		if Sirin.mainThread.g_HolySys:GetDestroyerSerial() == self.m_pAttChar.m_dwObjSerial or pSrcPlayer.m_Param.m_bLastAttBuff then
			attPnt = attPnt * CONST_ChipBreakerBonus_Atk
			attPntEff = attPntEff * CONST_ChipBreakerBonus_Atk
		end

		if not pSrcPlayer.m_bInGuildBattle then
			local byBossType = Sirin.mainThread.CPvpUserAndGuildRankingSystem.Instance():GetBossType(pSrcPlayer:GetObjRace(), pSrcPlayer.m_dwObjSerial)

			if byBossType == 0 then
				attPnt = attPnt * CONST_PatriarchBonus_Atk
				attPntEff = attPntEff * CONST_PatriarchBonus_Atk
			elseif byBossType == 2 or byBossType == 6 then
				attPnt = attPnt * CONST_AttackCouncilBonus_Atk
				attPntEff = attPntEff * CONST_AttackCouncilBonus_Atk
			end
		end
	elseif self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.animus then
		local pSrcAnimus = objectToAnimus(self.m_pAttChar)

		if pSrcAnimus.m_pMaster then
			if SERVER_AOP then
				local embellishList = pSrcAnimus.m_pMaster.m_Param.m_dbEmbellish:GetUseList()

				for _,e in ipairs(embellishList) do
					if e.m_byTableCode == TBL_CODE.bullet then
						local pBulletFld = Sirin.mainThread.baseToBulletItem(Sirin.mainThread.g_Main:m_tblItemData_get(TBL_CODE.bullet):GetRecord(e.m_wItemIndex))

						if pBulletFld.m_strBulletType == 'Q' then
							local bns = pBulletFld.m_fGAAF * self:GetAttackFC(pSrcAnimus.m_pMaster, 2, true, false) * (pSrcAnimus.m_pMaster.m_EP:GetEff_Rate(_EFF_RATE.FC_AttFc) - 1) * 2
							local left = pSrcAnimus.m_pMaster:Emb_AlterDurPoint(STORAGE_POS.embellish, e.m_byStorageIndex, -1, false, true)

							if left == 0 then
								Sirin.WriteA(pSrcAnimus.m_pMaster.m_szItemHistoryFileName, string.format("CONSUM: %s_@0[%d] [%s]", pBulletFld.m_strCode, e.m_lnUID, os.date()), false, false)
							else
								local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
								buf:Init()
								buf:PushUInt16(e.m_wSerial)
								buf:PushUInt16(left)
								buf:SendBuffer(pSrcAnimus.m_pMaster, 5, 21)
							end

							attPnt = attPnt + bns
							attPntEff = attPntEff + bns
						end
					end
				end
			else
				local tmp = self:GetAttackFC(pSrcAnimus.m_pMaster, 2, true, false) * (pSrcAnimus.m_pMaster.m_EP:GetEff_Rate(_EFF_RATE.Animus_AttFc_ByMst_FC) - 1)
				tmp = tmp + self:GetAttackFC(pSrcAnimus.m_pMaster, 0, true, false)* (pSrcAnimus.m_pMaster.m_EP:GetEff_Rate(_EFF_RATE.Animus_AttFc_ByMst_GE) - 1)
				tmp = tmp + self:GetAttackFC(pSrcAnimus.m_pMaster, 0, false, false)* (pSrcAnimus.m_pMaster.m_EP:GetEff_Rate(_EFF_RATE.Animus_AttFc_ByMst_GA1) - 1)
				tmp = tmp + self:GetAttackFC(pSrcAnimus.m_pMaster, 1, true, false)* (pSrcAnimus.m_pMaster.m_EP:GetEff_Rate(_EFF_RATE.Animus_AttFc_ByMst_SK) - 1)
				tmp = tmp + self:GetAttackFC(pSrcAnimus.m_pMaster, 1, false, false)* (pSrcAnimus.m_pMaster.m_EP:GetEff_Rate(_EFF_RATE.Animus_AttFc_ByMst_SA1) - 1)
				attPnt = attPnt + tmp
				attPntEff = attPntEff + tmp
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

	if pDst and (self.m_pp.nAttactType == 0 or self.m_pp.nAttactType == 1 or self.m_pp.nAttactType == 2) then
		self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, bUseEffBullet and math.floor(attPntEff) or math.floor(attPnt), self.m_pp.nPart, self.m_pp.nTol, pDst, self.m_pp.bBackAttack) }
		self.m_nDamagedObjNum = 1
	elseif self.m_pp.nAttactType == 5 and self.m_pp.nExtentRange > 0 then
		self:FlashDamageProc(self.m_pp.nExtentRange, math.floor(attPnt), 90, math.floor(attPntEff), bUseEffBullet)
	elseif self.m_pp.nAttactType == 6 and self.m_pp.nExtentRange > 0 then
		self:AreaDamageProc(self.m_pp.nExtentRange, math.floor(attPnt), self.m_pp.fArea_x, self.m_pp.fArea_y, self.m_pp.fArea_z, math.floor(attPntEff), bUseEffBullet)
	else
		self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
		self.m_nDamagedObjNum = 1
	end

	self:CalcAvgDamage()
end

---@param nLimDist integer
---@param nAttPower integer
---@param nAngle integer
---@param nEffAttPower integer
---@param bUseEffBullet boolean
function sirinCAttack:FlashDamageProc(nLimDist, nAttPower, nAngle, nEffAttPower, bUseEffBullet)
	repeat
		local pDst = self.m_pp.pDst

		if not pDst then
			break
		end

		if self.m_pAttChar.m_pCurMap ~= pDst.m_pCurMap then
			Sirin.mainThread.g_Main.m_logSystemError:Write(string.format("FlashDamage Error AttackTarget Map : Attack Obj( %s : %s ) Dst Obj( %s : %s )", self.m_pAttChar:GetObjName(), self.m_pAttChar.m_pCurMap.m_pMapSet.m_strCode, self.m_pp.pDst:GetObjName(), self.m_pp.pDst.m_pCurMap.m_pMapSet.m_strCode))
			break
		end

		if self.m_pp.bMatchless then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = pDst:GetHP() }
			self.m_nDamagedObjNum = 1
		else
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, bUseEffBullet and nEffAttPower or nAttPower, self.m_pp.nPart, self.m_pp.nTol, self.m_pp.pDst, self.m_pp.bBackAttack) }
			self.m_nDamagedObjNum = 1
		end

		local secIndex = pDst:GetCurSecNum()

		if secIndex == 0xFFFFFFFF then
			break
		end

		---@param pTestTar CCharacter
		---@return boolean
		local targetHandler = function(pTestTar)
			local bValid = false

			repeat
				if IsSameObject(pTestTar, self.m_pAttChar) then
					break
				end

				if IsSameObject(pTestTar, pDst) then
					break
				end

				if not pTestTar.m_bLive or pTestTar.m_bCorpse then
					break
				end

				if not pTestTar:IsBeAttackedAble(false) then
					break
				end

				local gvgLim, inGvG = self:CheckGuildBattleLimit(pTestTar)

				if gvgLim then
					break
				end

				if not pTestTar:IsBeDamagedAble(self.m_pAttChar) then
					break
				end

				if not self.m_pAttChar:IsAttackableInTown() and not pTestTar:IsAttackableInTown() and (self.m_pAttChar:IsInTown() or pTestTar:IsInTown()) then
					break
				end

				if math.abs(self.m_pAttChar.m_fCurPos_y - pTestTar.m_fCurPos_y) > 350 then
					break
				end

				if inGvG then
					bValid = true
					break
				end

				local bSameRace = self.m_pAttChar:GetObjRace() == pTestTar:GetObjRace()

				if not bSameRace then
					bValid = true
					break
				end

				if self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.monster or pTestTar.m_ObjID.m_byID == ID_CHAR.monster then
					bValid = true
					break
				end

				local pSrcPlayer

				if self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.player then
					pSrcPlayer = objectToPlayer(self.m_pAttChar)
				elseif self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.animus then
					pSrcPlayer = objectToAnimus(self.m_pAttChar).m_pMaster

					if pSrcPlayer and IsSameObject(pTestTar, pSrcPlayer) then
						break
					end
				elseif self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.tower then
					pSrcPlayer = objectToTower(self.m_pAttChar).m_pMasterTwr

					if pSrcPlayer and IsSameObject(pTestTar, pSrcPlayer) then
						break
					end
				elseif self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.trap then
					pSrcPlayer = objectToTrap(self.m_pAttChar).m_pMaster

					if pSrcPlayer and IsSameObject(pTestTar, pSrcPlayer) then
						break
					end
				end

				if not pSrcPlayer then
					break
				end

				local pDstPlayer

				if pTestTar.m_ObjID.m_byID == ID_CHAR.player then
					pDstPlayer = objectToPlayer(pTestTar)
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.animus then
					pDstPlayer = objectToAnimus(pTestTar).m_pMaster

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.tower then
					pDstPlayer = objectToTower(pTestTar).m_pMasterTwr

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.trap then
					pDstPlayer = objectToTrap(pTestTar).m_pMaster

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.amine_personal then
					pDstPlayer = objectToAMP(pTestTar).m_pOwner

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				end

				if not pDstPlayer then
					break
				end

				if pSrcPlayer:IsChaosMode() or pDstPlayer:IsPunished(1, false) then
					bValid = true
					break
				end

			until true

			if bValid then
				local dist = GetSqrt(pDst.m_fCurPos_x, pDst.m_fCurPos_z, pTestTar.m_fCurPos_x, pTestTar.m_fCurPos_z) - pTestTar:GetWidth() / 2

				if dist < nLimDist then
					if self.IsCharInSector(pTestTar, self.m_pAttChar, pDst, nAngle, nLimDist) then
						if self.m_pp.bMatchless then
							table.insert(self.m_DamList, Sirin_be_damaged_char:new{ m_pChar = pTestTar, m_nDamage = pTestTar:GetHP() })
						else
							local dam_obj = Sirin_be_damaged_char:new{ m_pChar = pTestTar, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, bUseEffBullet and nEffAttPower or nAttPower, CharacterMgr.GetAttackRandomPart(pTestTar), self.m_pp.nTol, pTestTar, false) }

							if dam_obj.m_nDamage ~= -2 then
								dam_obj.m_nDamage = math.floor(dam_obj.m_nDamage * (nLimDist - dist) / nLimDist)

								if dam_obj.m_nDamage >= 1 then
									table.insert(self.m_DamList, dam_obj)
								end
							end
						end

						self.m_nDamagedObjNum = #self.m_DamList
					end
				end
			end

			return self.m_nDamagedObjNum < 30
		end

		local nearPlyers = pDst.m_pCurMap:GetPlayerListInRadius(pDst.m_wMapLayerIndex, secIndex, 1)

		for _,p in ipairs(nearPlyers) do
			if not targetHandler(p) then
				break
			end
		end

		if self.m_nDamagedObjNum >= 30 then
			break
		end

		local nearCharacters = pDst.m_pCurMap:GetObjectListInRadius(pDst.m_wMapLayerIndex, secIndex, 1, 2298) -- 2298 is a bitmask for no player damageable objects

		for _,p in ipairs(nearCharacters) do
			if not targetHandler(objectToCharacter(p)) then
				break
			end
		end

	until true
end

---@param nLimitRadius integer
---@param nAttPower integer
---@param x number
---@param y number
---@param z number
---@param nEffAttPower integer
---@param bUseEffBullet boolean
function sirinCAttack:AreaDamageProc(nLimitRadius, nAttPower, x, y, z, nEffAttPower, bUseEffBullet)
	repeat
		local pDst = self.m_pp.pDst

		if pDst then
			if self.m_pAttChar.m_pCurMap ~= pDst.m_pCurMap then
				Sirin.mainThread.g_Main.m_logSystemError:Write(string.format("AreaDamage Error AttackTarget Map : Attack Obj( %s : %s ) Dst Obj( %s : %s )", self.m_pAttChar:GetObjName(), self.m_pAttChar.m_pCurMap.m_pMapSet.m_strCode, self.m_pp.pDst:GetObjName(), self.m_pp.pDst.m_pCurMap.m_pMapSet.m_strCode))
				break
			end

			if not IsSameObject(pDst, self.m_pAttChar) then
				if self.m_pp.bMatchless then
					self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = pDst:GetHP() }
					self.m_nDamagedObjNum = 1
				else
					self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, bUseEffBullet and nEffAttPower or nAttPower, self.m_pp.nPart, self.m_pp.nTol, self.m_pp.pDst, self.m_pp.bBackAttack) }
					self.m_nDamagedObjNum = 1
				end
			end
		end

		local secIndex = 0xFFFFFFFF

		if pDst then
			secIndex = pDst:GetCurSecNum()
		else
			secIndex = self.m_pAttChar.m_pCurMap:GetSectorIndex(x, z)
		end

		if secIndex == 0xFFFFFFFF then
			break
		end

		---@param pTestTar CCharacter
		---@return boolean
		local targetHandler = function(pTestTar)
			local bValid = false

			repeat
				if IsSameObject(pTestTar, self.m_pAttChar) then
					break
				end

				if pDst and IsSameObject(pTestTar, pDst) then
					break
				end

				if not pTestTar.m_bLive or pTestTar.m_bCorpse then
					break
				end

				if not pTestTar:IsBeAttackedAble(false) then
					break
				end

				local gvgLim, inGvG = self:CheckGuildBattleLimit(pTestTar)

				if gvgLim then
					break
				end

				if not pTestTar:IsBeDamagedAble(self.m_pAttChar) then
					break
				end

				if not self.m_pAttChar:IsAttackableInTown() and not pTestTar:IsAttackableInTown() and (self.m_pAttChar:IsInTown() or pTestTar:IsInTown()) then
					break
				end

				if math.abs(self.m_pAttChar.m_fCurPos_y - pTestTar.m_fCurPos_y) > 350 then
					break
				end

				if inGvG then
					bValid = true
					break
				end

				local bSameRace = self.m_pAttChar:GetObjRace() == pTestTar:GetObjRace()

				if not bSameRace then
					bValid = true
					break
				end

				if self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.monster or pTestTar.m_ObjID.m_byID == ID_CHAR.monster then
					bValid = true
					break
				end

				local pSrcPlayer

				if self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.player then
					pSrcPlayer = objectToPlayer(self.m_pAttChar)
				elseif self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.animus then
					pSrcPlayer = objectToAnimus(self.m_pAttChar).m_pMaster

					if pSrcPlayer and IsSameObject(pTestTar, pSrcPlayer) then
						break
					end
				elseif self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.tower then
					pSrcPlayer = objectToTower(self.m_pAttChar).m_pMasterTwr

					if pSrcPlayer and IsSameObject(pTestTar, pSrcPlayer) then
						break
					end
				elseif self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.trap then
					pSrcPlayer = objectToTrap(self.m_pAttChar).m_pMaster

					if pSrcPlayer and IsSameObject(pTestTar, pSrcPlayer) then
						break
					end
				end

				if not pSrcPlayer then
					break
				end

				local pDstPlayer

				if pTestTar.m_ObjID.m_byID == ID_CHAR.player then
					pDstPlayer = objectToPlayer(pTestTar)
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.animus then
					pDstPlayer = objectToAnimus(pTestTar).m_pMaster

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.tower then
					pDstPlayer = objectToTower(pTestTar).m_pMasterTwr

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.trap then
					pDstPlayer = objectToTrap(pTestTar).m_pMaster

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.amine_personal then
					pDstPlayer = objectToAMP(pTestTar).m_pOwner

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				end

				if not pDstPlayer then
					break
				end

				if pSrcPlayer:IsChaosMode() or pDstPlayer:IsPunished(1, false) then
					bValid = true
					break
				end

			until true

			if bValid then
				local dist = GetSqrt(x, z, pTestTar.m_fCurPos_x, pTestTar.m_fCurPos_z) - pTestTar:GetWidth() / 2

				if dist < nLimitRadius then
					if self.m_pp.bMatchless then
						table.insert(self.m_DamList, Sirin_be_damaged_char:new{ m_pChar = pTestTar, m_nDamage = pTestTar:GetHP() })
					else
						local dam_obj = Sirin_be_damaged_char:new{ m_pChar = pTestTar, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, bUseEffBullet and nEffAttPower or nAttPower, CharacterMgr.GetAttackRandomPart(pTestTar), self.m_pp.nTol, pTestTar, false) }

						if dam_obj.m_nDamage ~= -2 then
							dam_obj.m_nDamage = math.floor(dam_obj.m_nDamage * (nLimitRadius - dist) / nLimitRadius)

							if dam_obj.m_nDamage >= 1 then
								table.insert(self.m_DamList, dam_obj)
							end
						end
					end

					self.m_nDamagedObjNum = #self.m_DamList
				end
			end

			return self.m_nDamagedObjNum < 30
		end

		local nearPlyers = self.m_pAttChar.m_pCurMap:GetPlayerListInRadius(self.m_pAttChar.m_wMapLayerIndex, secIndex, 1)

		for _,p in ipairs(nearPlyers) do
			if not targetHandler(p) then
				break
			end
		end

		if self.m_nDamagedObjNum >= 30 then
			break
		end

		local nearCharacters = self.m_pAttChar.m_pCurMap:GetObjectListInRadius(self.m_pAttChar.m_wMapLayerIndex, secIndex, 1, 2298) -- 2298 is a bitmask for no player damageable objects

		for _,p in ipairs(nearCharacters) do
			if not targetHandler(objectToCharacter(p)) then
				break
			end
		end

	until true
end

---@param nAttPower integer
---@param nAngle integer
---@param nShotNum integer
---@param nWeaponRange integer
---@param nEffAttPower integer
---@param bUseEffBullet boolean
function sirinCAttack:SectorDamageProc(nAttPower, nAngle, nShotNum, nWeaponRange, nEffAttPower, bUseEffBullet)
	local nMaxRange = nWeaponRange
	local nMinRange = math.floor(nWeaponRange / 4)

	repeat
		local pDst = self.m_pp.pDst

		if not pDst then
			break
		end

		if self.m_pAttChar.m_pCurMap ~= pDst.m_pCurMap then
			Sirin.mainThread.g_Main.m_logSystemError:Write(string.format("SectorDamage Error AttackTarget Map : Attack Obj( %s : %s ) Dst Obj( %s : %s )", self.m_pAttChar:GetObjName(), self.m_pAttChar.m_pCurMap.m_pMapSet.m_strCode, self.m_pp.pDst:GetObjName(), self.m_pp.pDst.m_pCurMap.m_pMapSet.m_strCode))
			break
		end

		if self.m_pp.bMatchless then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = pDst:GetHP() }
			self.m_nDamagedObjNum = 1
		else
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, bUseEffBullet and nEffAttPower or nAttPower, self.m_pp.nPart, self.m_pp.nTol, self.m_pp.pDst, self.m_pp.bBackAttack) }
			self.m_nDamagedObjNum = 1
		end

		local secIndex = pDst:GetCurSecNum()

		if secIndex == 0xFFFFFFFF then
			break
		end

		if nShotNum <= 1 then
			break
		end

		---@param pTestTar CCharacter
		---@return boolean
		local targetHandler = function(pTestTar)
			local bValid = false

			repeat
				if IsSameObject(pTestTar, self.m_pAttChar) then
					break
				end

				if IsSameObject(pTestTar, pDst) then
					break
				end

				if not pTestTar.m_bLive or pTestTar.m_bCorpse then
					break
				end

				if not pTestTar:IsBeAttackedAble(false) then
					break
				end

				local gvgLim, inGvG = self:CheckGuildBattleLimit(pTestTar)

				if gvgLim then
					break
				end

				if not pTestTar:IsBeDamagedAble(self.m_pAttChar) then
					break
				end

				if not self.m_pAttChar:IsAttackableInTown() and not pTestTar:IsAttackableInTown() and (self.m_pAttChar:IsInTown() or pTestTar:IsInTown()) then
					break
				end

				if math.abs(self.m_pAttChar.m_fCurPos_y - pTestTar.m_fCurPos_y) > 350 then
					break
				end

				if inGvG then
					bValid = true
					break
				end

				local bSameRace = self.m_pAttChar:GetObjRace() == pTestTar:GetObjRace()

				if not bSameRace then
					bValid = true
					break
				end

				if self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.monster or pTestTar.m_ObjID.m_byID == ID_CHAR.monster then
					bValid = true
					break
				end

				local pSrcPlayer

				if self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.player then
					pSrcPlayer = objectToPlayer(self.m_pAttChar)
				elseif self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.animus then
					pSrcPlayer = objectToAnimus(self.m_pAttChar).m_pMaster

					if pSrcPlayer and IsSameObject(pTestTar, pSrcPlayer) then
						break
					end
				elseif self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.tower then
					pSrcPlayer = objectToTower(self.m_pAttChar).m_pMasterTwr

					if pSrcPlayer and IsSameObject(pTestTar, pSrcPlayer) then
						break
					end
				elseif self.m_pAttChar.m_ObjID.m_byID == ID_CHAR.trap then
					pSrcPlayer = objectToTrap(self.m_pAttChar).m_pMaster

					if pSrcPlayer and IsSameObject(pTestTar, pSrcPlayer) then
						break
					end
				end

				if not pSrcPlayer then
					break
				end

				local pDstPlayer

				if pTestTar.m_ObjID.m_byID == ID_CHAR.player then
					pDstPlayer = objectToPlayer(pTestTar)
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.animus then
					pDstPlayer = objectToAnimus(pTestTar).m_pMaster

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.tower then
					pDstPlayer = objectToTower(pTestTar).m_pMasterTwr

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.trap then
					pDstPlayer = objectToTrap(pTestTar).m_pMaster

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				elseif pTestTar.m_ObjID.m_byID == ID_CHAR.amine_personal then
					pDstPlayer = objectToAMP(pTestTar).m_pOwner

					if pDstPlayer and IsSameObject(self.m_pAttChar, pDstPlayer) then
						break
					end
				end

				if not pDstPlayer then
					break
				end

				if pSrcPlayer:IsChaosMode() or pDstPlayer:IsPunished(1, false) then
					bValid = true
					break
				end

			until true

			if bValid then
				local dist = GetSqrt(pDst.m_fCurPos_x, pDst.m_fCurPos_z, pTestTar.m_fCurPos_x, pTestTar.m_fCurPos_z) - pTestTar:GetWidth()
				dist = dist < 0 and 0 or math.floor(dist)

				if dist <= nMaxRange and dist >= nMinRange then
					if self.IsCharInSector(pTestTar, self.m_pAttChar, pDst, nAngle, nWeaponRange) then
						if self.m_pp.bMatchless then
							table.insert(self.m_DamList, Sirin_be_damaged_char:new{ m_pChar = pTestTar, m_nDamage = pTestTar:GetHP() })
						else
							local dam_obj = Sirin_be_damaged_char:new{ m_pChar = pTestTar, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, bUseEffBullet and nEffAttPower or nAttPower, CharacterMgr.GetAttackRandomPart(pTestTar), self.m_pp.nTol, pTestTar, false) }

							if dam_obj.m_nDamage ~= -2 then
								dam_obj.m_nDamage = math.floor(dam_obj.m_nDamage * (nWeaponRange - dist) / nWeaponRange)

								if dam_obj.m_nDamage >= 1 then
									table.insert(self.m_DamList, dam_obj)
								end
							end
						end

						self.m_nDamagedObjNum = #self.m_DamList
					end
				end
			end

			return self.m_nDamagedObjNum < 30 and self.m_nDamagedObjNum < nShotNum
		end

		local nearPlyers = pDst.m_pCurMap:GetPlayerListInRadius(pDst.m_wMapLayerIndex, secIndex, 1)

		for _,p in ipairs(nearPlyers) do
			if not targetHandler(p) then
				break
			end
		end

		if self.m_nDamagedObjNum >= 30 or self.m_nDamagedObjNum >= nShotNum then
			break
		end

		local nearCharacters = pDst.m_pCurMap:GetObjectListInRadius(pDst.m_wMapLayerIndex, secIndex, 1, 2298) -- 2298 is a bitmask for no player damageable objects

		for _,p in ipairs(nearCharacters) do
			if not targetHandler(objectToCharacter(p)) then
				break
			end
		end

	until true
end

---@param bUseEffBullet boolean
---@return integer
function sirinCAttack:_CalcForceAttPnt(bUseEffBullet)
	local pForceFld = baseToForce(self.m_pp.pFld)
	local fR = 0.847
	local fRLf = 0.86472
	local fRMf = 0.28824
	local fRLVf = self.m_pp.nLevel + (7 - self.m_pp.nLevel) * 0.5
	local l_fConst = pForceFld.m_fAttFormulaConstant
	local l_nMinAf = 0
	local l_nMaxAf = 0

	if bUseEffBullet then
		l_nMinAf = math.floor((self.m_pp.nMinAFPlus * (fR + (fRLVf / 7 * fRLf) + (self.m_pp.nMastery / 99 * fRMf)) * l_fConst) + 0.5)
		l_nMaxAf = math.floor((self.m_pp.nMaxAFPlus * (fR + (fRLVf / 7 * fRLf) + (self.m_pp.nMastery / 99 * fRMf)) * l_fConst) + 0.5)
	else
		l_nMinAf = math.floor((self.m_pp.nMinAF * (fR + (fRLVf / 7 * fRLf) + (self.m_pp.nMastery / 99 * fRMf)) * l_fConst) + 0.5)
		l_nMaxAf = math.floor((self.m_pp.nMaxAF * (fR + (fRLVf / 7 * fRLf) + (self.m_pp.nMastery / 99 * fRMf)) * l_fConst) + 0.5)
	end

	if l_nMaxAf < 0 then
		local errStr = string.format("Force Attack Error : Force(%s), FIndex(%d), l_fConst(%f), fRLVf(%f), nMastery(%d), nMaxAF(%d), nMinAF(%d)\n",
			pForceFld.m_strCode,
			pForceFld.m_dwIndex,
			l_fConst,
			fRLVf,
			self.m_pp.nMastery,
			bUseEffBullet and self.m_pp.nMaxAFPlus or self.m_pp.nMaxAF,
			bUseEffBullet and self.m_pp.nMinAFPlus or self.m_pp.nMinAF
		)
		Sirin.mainThread.g_Main.m_logSystemError:Write(errStr)
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, errStr)
		l_nMinAf = 1
		l_nMaxAf = 1
	end

	local l_nCrtAf = math.floor(l_nMaxAf * ((125 + l_nMaxAf) / (50 + l_nMaxAf)) + 0.5)

	if self.m_pp.nMaxAttackPnt > 0 then
		return l_nCrtAf
	elseif self.m_pp.nMaxAttackPnt < 0 then
		return l_nMinAf
	else
		local l_nAttBlk = math.floor((l_nMinAf + l_nMaxAf) / 2 + 0.5)
		local belowAverage = self.m_pp.nMinSel - self.m_pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.GE_CrtExt)
		local aboveAverage = self.m_pp.nMaxSel + self.m_pp.nMinSel - self.m_pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.GE_CrtExt)

		if self.m_pp.pDst and not IsSameObject(self.m_pAttChar, self.m_pp.pDst) then
			belowAverage = belowAverage + self.m_pp.pDst.m_EP:GetEff_Plus(_EFF_PLUS.All_AvdCrt)
			aboveAverage = aboveAverage + self.m_pp.pDst.m_EP:GetEff_Plus(_EFF_PLUS.All_AvdCrt)
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

---@param bUseEffBullet boolean
function sirinCAttack:AttackForce(bUseEffBullet)
	local bSucc = true
	self.m_pAttChar:BreakStealth()
	local pDst = self.m_pp.pDst

	if pDst then
		if pDst.m_EP:GetEff_State(_EFF_STATE.Abs_Avd) then
			bSucc = false
		else
			local nSuccRate = self.m_pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.FC_HitRate) + 100 - pDst:GetAvoidRate()

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

	local attPnt = self.m_pp.nAddAttPnt + self:_CalcForceAttPnt(false)
	local attPntEff = self.m_pp.nAddAttPnt + self:_CalcForceAttPnt(true)

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

	local pForceFld= baseToForce(self.m_pp.pFld)
	local nAttType = pForceFld.m_nEffectGroup

	if pDst and nAttType >= 0 and nAttType <=2 then
		self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, bUseEffBullet and math.floor(attPntEff) or math.floor(attPnt), self.m_pp.nPart, self.m_pp.nTol, pDst, self.m_pp.bBackAttack) }
		self.m_nDamagedObjNum = 1
	elseif nAttType == 4 or nAttType == 6 then
		self:AreaDamageProc(s_nLimitRadius[pForceFld.m_nLv + 1], math.floor(attPnt), self.m_pp.fArea_x, self.m_pp.fArea_y, self.m_pp.fArea_z, math.floor(attPntEff), bUseEffBullet)
	elseif nAttType == 5 then
		self:FlashDamageProc(s_nLimitDist[pForceFld.m_nLv + 1], math.floor(attPnt), s_nLimitAngle[2][pForceFld.m_nLv + 1], math.floor(attPntEff), bUseEffBullet)
	else
		return
	end

	self:CalcAvgDamage()
end

---@type table<integer, integer>
local s_Mon_nLimitDist = { 42, 56, 70, 84 }
---@type table<integer, integer>
local s_Mon_nLimitRadius = { 42, 56, 70, 84 }
---@type table<integer, table<integer, integer>>
local s_Mon_nLimitAngle = { { 180, 180, 180, 180 }, { 180, 180, 180, 180 }, { 180, 180, 180, 180 }, { 180, 180, 180, 180 } }
---@type integer
local monsterForcePowerRate = 40 -- value from MonsterSet.ini

---@class (exact) sirinCMonsterAttack : sirinCAttack
---@field m_pAttMonster CMonster
local sirinCMonsterAttack = SirinCAttack:new()
SirinCMonsterAttack = sirinCMonsterAttack

---@return sirinCMonsterAttack
function sirinCMonsterAttack:new(o)
	local _i = clone(self)
	for k,v in pairs(o or {}) do _i[k] = v end
	self.__index = self
	return setmetatable(_i, self)
end

---@param fAttFc number
---@return number
function sirinCMonsterAttack:ModifyMonsterAttFc(fAttFc)
	if 1 -  fAttFc <= 0 then
		return fAttFc
	else
		return 1 - (1 - fAttFc) * 0.25
	end
end

---@param bMustMiss boolean
function sirinCMonsterAttack:AttackMonsterGen(bMustMiss)
	local bSucc = true
	self.m_pAttChar:BreakStealth()
	local pDst = self.m_pp.pDst

	if pDst then
		local bIsCounterAttack = false

		if pDst.m_EP:GetEff_State(_EFF_STATE.Res_Att) then
			bIsCounterAttack = true
		else
			local fCounterRate = pDst.m_EP:GetEff_Plus(_EFF_PLUS.Avoid_Con)

			if fCounterRate > 0 then
				if math.random(0,99) < fCounterRate then
					bIsCounterAttack = true
				end
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
		end

		if self.m_pp.bMatchless then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = pDst:GetHP() }
			self.m_nDamagedObjNum = 1
			return
		end

		if pDst.m_EP:GetEff_State(_EFF_STATE.Abs_Avd) then
			bSucc = false
		else
			if self.m_pAttChar:GetGenAttackProb(pDst, self.m_pp.nPart, self.m_pp.bBackAttack) < math.random(0, 99) then
				bSucc = false
			end
		end

		if bSucc and bMustMiss then
			bSucc = false
		end

		if not bSucc then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
			self.m_nDamagedObjNum = 1
			return
		end
	end

	local attPnt = self:_CalcGenAttPnt(false) + self.m_pp.nAddAttPnt
	attPnt = attPnt * self:ModifyMonsterAttFc(self.m_pAttChar.m_EP:GetEff_Rate(self.m_pp.nWpType == 7 and _EFF_RATE.Fg_Lcr or self.m_pp.nClass))

	if pDst and (self.m_pp.nAttactType == 0 or self.m_pp.nAttactType == 1 or self.m_pp.nAttactType == 2) then
		self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, math.floor(attPnt), self.m_pp.nPart, self.m_pp.nTol, pDst, self.m_pp.bBackAttack) }
		self.m_nDamagedObjNum = 1
	elseif self.m_pp.nAttactType == 5 and self.m_pp.nExtentRange > 0 then
		self:FlashDamageProc(self.m_pp.nExtentRange, math.floor(attPnt), 90, 0, false)
	elseif self.m_pp.nAttactType == 6 and self.m_pp.nExtentRange > 0 then
		self:AreaDamageProc(self.m_pp.nExtentRange, math.floor(attPnt), self.m_pp.fArea_x, self.m_pp.fArea_y, self.m_pp.fArea_z, 0, false)
	else
		self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
		self.m_nDamagedObjNum = 1
	end

	self:CalcAvgDamage()
end

---@return integer
function sirinCMonsterAttack:_CalcMonSkillAttPnt()
	local pSkillFld = baseToSkill(self.m_pp.pFld)
	local fR = 0.847
	local fRLf = 0.86472
	local fRMf = 0.28824
	local fRLVf = self.m_pp.nLevel + (7 - self.m_pp.nLevel) * 0.5
	local l_fConst = pSkillFld.m_fAttFormulaConstant
	local l_nLvConst = pSkillFld:m_nAttConstant_get(self.m_pp.nLevel - 1)
	local l_nMinAf = math.floor(l_nLvConst / 788 * (self.m_pp.nMinAF * (fR + (fRLVf / 7 * fRLf) + (self.m_pp.nMastery / 99 * fRMf)) * l_fConst ) + 0.5)
	local l_nMaxAf = math.floor(l_nLvConst / 788 * (self.m_pp.nMaxAF * (fR + (fRLVf / 7 * fRLf) + (self.m_pp.nMastery / 99 * fRMf)) * l_fConst ) + 0.5)

	if l_nMaxAf < 0 then
		local errStr = string.format("Skill Attack Error : Skill(%s), SIndex(%d), l_fConst(%f), l_nLvConst(%d), nMastery(%d), nMaxAF(%d), nMinAF(%d)\n",
			pSkillFld.m_strCode,
			pSkillFld.m_dwIndex,
			l_fConst,
			l_nLvConst,
			self.m_pp.nMastery,
			self.m_pp.nMaxAF,
			self.m_pp.nMinAF
		)
		Sirin.mainThread.g_Main.m_logSystemError:Write(errStr)
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, errStr)
		l_nMinAf = 1
		l_nMaxAf = 1
	end

	local l_nCrtAf = math.floor(l_nMaxAf * ((125 + l_nMaxAf) / (50 + l_nMaxAf)) + 0.5)

	if self.m_pp.nMaxAttackPnt > 0 then
		return l_nCrtAf
	elseif self.m_pp.nMaxAttackPnt < 0 then
		return l_nMinAf
	else
		local l_nAttBlk = math.floor((l_nMinAf + l_nMaxAf) / 2 + 0.5)
		local belowAverage = self.m_pp.nMinSel - self.m_pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.GE_CrtExt)
		local aboveAverage = self.m_pp.nMaxSel + self.m_pp.nMinSel - self.m_pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.GE_CrtExt)

		if self.m_pp.pDst and not IsSameObject(self.m_pAttChar, self.m_pp.pDst) then
			belowAverage = belowAverage + self.m_pp.pDst.m_EP:GetEff_Plus(_EFF_PLUS.All_AvdCrt)
			aboveAverage = aboveAverage + self.m_pp.pDst.m_EP:GetEff_Plus(_EFF_PLUS.All_AvdCrt)
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

function sirinCMonsterAttack:AttackMonsterSkill()
	local bSucc = true
	self.m_pAttChar:BreakStealth()
	local pDst = self.m_pp.pDst

	if pDst then
		local bIsCounterAttack = false

		if pDst.m_EP:GetEff_State(_EFF_STATE.Res_Att) then
			bIsCounterAttack = true
		else
			local fCounterRate = pDst.m_EP:GetEff_Plus(_EFF_PLUS.Avoid_Con)

			if fCounterRate > 0 then
				if math.random(0,99) < fCounterRate then
					bIsCounterAttack = true
				end
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
		end

		if self.m_pp.bMatchless then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = pDst:GetHP() }
			self.m_nDamagedObjNum = 1
			return
		end

		if pDst.m_EP:GetEff_State(_EFF_STATE.Abs_Avd) then
			bSucc = false
		else
			local nRate = math.floor(self.m_pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.SK_HitRate) + 150 - pDst:GetAvoidRate())

			if nRate < 0 then
				nRate = 0
			elseif nRate > 100 then
				nRate = 100
			end

			if math.random(0, 99) >= nRate then
				bSucc = false
			end
		end

		if not bSucc then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
			self.m_nDamagedObjNum = 1
			return
		end
	end

	local attPnt = self:_CalcMonSkillAttPnt() + self.m_pp.nAddAttPnt
	local pSkillFld = baseToSkill(self.m_pp.pFld)
	local nAttType = pSkillFld:m_nAttType_get(self.m_pp.byEffectCode == 0 and (self.m_pp.nLevel - 1) or 0)

	if nAttType >= 0 and nAttType <=3 and pDst then
		self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, math.floor(attPnt), self.m_pp.nPart, self.m_pp.nTol, pDst, self.m_pp.bBackAttack) }
		self.m_nDamagedObjNum = 1
	elseif nAttType == 4 or nAttType == 6 then
		self:AreaDamageProc(s_Mon_nLimitRadius[pSkillFld.m_nLv + 1], math.floor(attPnt), self.m_pp.fArea_x, self.m_pp.fArea_y, self.m_pp.fArea_z, 0, false)
	elseif nAttType == 5 then
		self:FlashDamageProc(s_Mon_nLimitDist[pSkillFld.m_nLv + 1], math.floor(attPnt), s_Mon_nLimitAngle[1][pSkillFld.m_nLv + 1], 0, false)
	elseif nAttType == 7 then
		self:SectorDamageProc(math.floor(attPnt), s_Mon_nLimitAngle[1][pSkillFld.m_nLv + 1], self.m_pp.nShotNum, self.m_pp.nExtentRange, 0, false)
	else
		return
	end

	self:CalcAvgDamage()
end

function sirinCMonsterAttack:AttackMonsterForce()
	local bSucc = true
	self.m_pAttChar:BreakStealth()
	local pDst = self.m_pp.pDst

	if pDst then
		if pDst.m_EP:GetEff_State(_EFF_STATE.Abs_Avd) then
			bSucc = false
		else
			local nRate = math.floor(self.m_pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.FC_HitRate) + 100 - pDst:GetAvoidRate())

			if nRate < 0 then
				nRate = 0
			elseif nRate > 100 then
				nRate = 100
			end

			if math.random(0, 99) >= nRate then
				bSucc = false
			end
		end

		if not bSucc then
			self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = 0 }
			self.m_nDamagedObjNum = 1
			return
		end
	end

	local attPnt = self:_CalcForceAttPnt(false) * monsterForcePowerRate / 100
	attPnt = attPnt * self:ModifyMonsterAttFc(self.m_pAttChar.m_EP:GetEff_Rate(_EFF_RATE.FC_AttFc))
	local pForceFld = baseToForce(self.m_pp.pFld)

	if pForceFld.m_nEffectGroup <= 2 and pDst then
		self.m_DamList[1] = Sirin_be_damaged_char:new{ m_pChar = pDst, m_nDamage = CharacterMgr.GetAttackDamPoint(self.m_pAttChar, math.floor(attPnt), self.m_pp.nPart, self.m_pp.nTol, pDst, self.m_pp.bBackAttack) }
		self.m_nDamagedObjNum = 1
	elseif pForceFld.m_nEffectGroup == 4 or pForceFld.m_nEffectGroup == 6 then
		self:AreaDamageProc(s_Mon_nLimitRadius[pForceFld.m_nLv + 1], math.floor(attPnt), self.m_pp.fArea_x, self.m_pp.fArea_y, self.m_pp.fArea_z, 0, false)
	elseif pForceFld.m_nEffectGroup == 5 then
		self:FlashDamageProc(s_Mon_nLimitDist[pForceFld.m_nLv + 1], math.floor(attPnt), s_Mon_nLimitAngle[2][pForceFld.m_nLv + 1], 0, false)
	else
		return
	end

	self:CalcAvgDamage()
end
