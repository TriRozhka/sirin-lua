local math = math
local _EFF_PLUS = _EFF_PLUS
local _EFF_RATE = _EFF_RATE

local baseToMonsterCharacter = Sirin.mainThread.baseToMonsterCharacter
local sendBuf = Sirin.mainThread.CLuaSendBuffer.Instance()

local sirinMonsterMgr = {}

---@param pMonster CMonster
---@return integer
function sirinMonsterMgr.GetAttackPart(pMonster)
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

---@param pMonster CMonster
---@param pDst CCharacter
---@param pSkill CMonsterSkill
---@return sirinCMonsterAttack
function sirinMonsterMgr.make_skill_attack_param(pMonster, pDst, pSkill)
	local pAT = SirinCMonsterAttack:new()
	pAT.m_pAttChar = pMonster
	pAT.m_pAttMonster = pMonster
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst

	if pDst then
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pDst)
		pAP.fArea_x = pDst.m_fCurPos_x
		pAP.fArea_y = pDst.m_fCurPos_y
		pAP.fArea_z = pDst.m_fCurPos_z
	else
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pMonster)
		pAP.fArea_x = pMonster.m_fCurPos_x
		pAP.fArea_y = pMonster.m_fCurPos_y
		pAP.fArea_z = pMonster.m_fCurPos_z
	end

	pAP.nClass = pMonster.m_pMonRec.m_bAttRangeType
	pAP.nTol = pSkill.m_Element
	pAP.nMinAF = pSkill.m_MinDmg
	pAP.nMaxAF = pSkill.m_MaxDmg
	pAP.nMinSel = pSkill.m_MinProb
	pAP.nMaxSel = pSkill.m_MaxProb
	pAP.pFld = pSkill.m_pSF_Fld
	pAP.nExtentRange = 20
	pAP.nShotNum = 1
	pAP.nAddAttPnt = 0
	pAP.nMaxAttackPnt = 0
	pAP.nMastery = 99

	if pSkill.m_nSFCode == 2 then
		pAP.byEffectCode = 2
		pAP.nLevel = 1
	else
		pAP.byEffectCode = 0
		pAP.nLevel = pSkill.m_nSFLv + math.floor(pMonster.m_EP:GetEff_Plus(_EFF_PLUS.SK_LvUp))

		if pAP.nLevel > 7 then
			pAP.nLevel = 7
		end
	end

	return pAT
end

---@param pMonster CMonster
---@param pDst CCharacter
---@param pSkill CMonsterSkill
---@return sirinCMonsterAttack
function sirinMonsterMgr.make_force_attack_param(pMonster, pDst, pSkill)
	local pAT = SirinCMonsterAttack:new()
	pAT.m_pAttChar = pMonster
	pAT.m_pAttMonster = pMonster
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst

	if pDst then
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pDst)
		pAP.fArea_x = pDst.m_fCurPos_x
		pAP.fArea_y = pDst.m_fCurPos_y
		pAP.fArea_z = pDst.m_fCurPos_z
	else
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pMonster)
		pAP.fArea_x = pMonster.m_fCurPos_x
		pAP.fArea_y = pMonster.m_fCurPos_y
		pAP.fArea_z = pMonster.m_fCurPos_z
	end

	pAP.nClass = pMonster.m_pMonRec.m_bAttRangeType
	pAP.nTol = pSkill.m_Element
	pAP.nMinAF = pSkill.m_MinDmg
	pAP.nMaxAF = pSkill.m_MaxDmg
	pAP.nMinSel = pSkill.m_MinProb
	pAP.nMaxSel = pSkill.m_MaxProb
	pAP.pFld = pSkill.m_pSF_Fld
	pAP.nLevel = pSkill.m_nSFLv
	pAP.nExtentRange = 0
	pAP.nShotNum = 0
	pAP.nAddAttPnt = 0
	pAP.nMaxAttackPnt = 0
	pAP.byEffectCode = 1
	pAP.nMastery = 1

	return pAT
end

---@param pMonster CMonster
---@param pDst CCharacter
---@return sirinCMonsterAttack
function sirinMonsterMgr.make_gen_attack_param(pMonster, pDst)
	local pAT = SirinCMonsterAttack:new()
	pAT.m_pAttChar = pMonster
	pAT.m_pAttMonster = pMonster
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst

	if pDst then
		pAP.nPart = CharacterMgr.GetAttackRandomPart(pDst)
		pAP.fArea_x = pDst.m_fCurPos_x
		pAP.fArea_y = pDst.m_fCurPos_y
		pAP.fArea_z = pDst.m_fCurPos_z
	else
		pAP.nPart = sirinMonsterMgr.GetAttackPart(pMonster)
	end

	pAP.nClass = pMonster.m_pMonRec.m_bAttRangeType

	local pSkill = pMonster.m_MonsterSkillPool:GetMonSkillKind(0)

	if pSkill then
		pAP.nTol = pSkill.m_Element
		pAP.nMinAF = pSkill.m_MinDmg
		pAP.nMaxAF = pSkill.m_MaxDmg
		pAP.nMinSel = pSkill.m_MinProb
		pAP.nMaxSel = pSkill.m_MaxProb
	else
		pAP.nTol = -1
		pAP.nMinAF = 0
		pAP.nMaxAF = 500
		pAP.nMinSel = 0
		pAP.nMaxSel = 100
	end

	pAP.bPassCount = pMonster.m_pMonRec.m_bMonsterCondition == 1

	if pMonster.m_pMonRec.m_nAttType > 2 then
		pAP.nAttactType = 6
		pAP.nExtentRange = 90
	end

	return pAT
end

---@param pMonster CMonster
---@param pDst CCharacter
---@param pSkill CMonsterSkill
---@return integer
function sirinMonsterMgr.Attack(pMonster, pDst, pSkill)
	if not pSkill or pSkill.m_UseType ~= 0 then
		return 0
	end

	if pDst then
		pMonster:UpdateLookAtPos(pDst.m_fCurPos_x, pDst.m_fCurPos_y, pDst.m_fCurPos_z)
	end

	---@type sirinCMonsterAttack
	local pAT

	if pSkill.m_nSFCode == 0 then
		pAT = sirinMonsterMgr.make_gen_attack_param(pMonster, pDst)
		pAT:AttackMonsterGen(pMonster.m_bApparition)

		sendBuf:Init()
		sendBuf:PushUInt8(pMonster.m_ObjID.m_byID)
		sendBuf:PushUInt32(pMonster.m_dwObjSerial)
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

		pMonster:CircleReport(5, 7, sendBuf, false)
	elseif pSkill.m_nSFCode == 1 then
		pAT = sirinMonsterMgr.make_skill_attack_param(pMonster, pDst, pSkill)
		pAT:AttackMonsterSkill()

		--[[
		struct _attack_skill_result_zocl
		{
			char byAtterID;
			unsigned int dwAtterSerial;
			char byEffectCode;
			unsigned __int16 wSkillIndex;
			char bySkillLv;
			char byAttackPart;
			unsigned __int16 wBulletIndex;
			bool bCritical;
			__int16 zAttackPos[2];
			bool bWPActive;
			char byListNum;
			_attack_gen_result_zocl::_dam_list DamList[32];
		};
		--]]

		sendBuf:Init()
		sendBuf:PushUInt8(pMonster.m_ObjID.m_byID)
		sendBuf:PushUInt32(pMonster.m_dwObjSerial)
		sendBuf:PushUInt8(pAT.m_pp.byEffectCode)
		sendBuf:PushUInt16(pAT.m_pp.pFld.m_dwIndex)
		sendBuf:PushInt8(pAT.m_pp.nLevel)
		sendBuf:PushInt8(pAT.m_pp.nPart)
		sendBuf:PushInt16(-1)
		sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
		sendBuf:PushInt16(pAT.m_pp.fArea_x)
		sendBuf:PushInt16(pAT.m_pp.fArea_z)
		sendBuf:PushUInt8(pAT.m_bActiveSucc and 1 or 0)
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

		pMonster:CircleReport(5, 8, sendBuf, false)
	elseif pSkill.m_nSFCode == 2 then
		pAT = sirinMonsterMgr.make_skill_attack_param(pMonster, pDst, pSkill)
		pAT:AttackMonsterSkill()

		sendBuf:Init()
		sendBuf:PushUInt8(pMonster.m_ObjID.m_byID)
		sendBuf:PushUInt32(pMonster.m_dwObjSerial)
		sendBuf:PushUInt8(pAT.m_pp.byEffectCode)
		sendBuf:PushUInt16(pAT.m_pp.pFld.m_dwIndex)
		sendBuf:PushInt8(pAT.m_pp.nLevel)
		sendBuf:PushInt8(pAT.m_pp.nPart)
		sendBuf:PushInt16(-1)
		sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
		sendBuf:PushInt16(pAT.m_pp.fArea_x)
		sendBuf:PushInt16(pAT.m_pp.fArea_z)
		sendBuf:PushUInt8(pAT.m_bActiveSucc and 1 or 0)
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

		pMonster:CircleReport(5, 8, sendBuf, false)
	elseif pSkill.m_nSFCode == 3 then
		pAT = sirinMonsterMgr.make_force_attack_param(pMonster, pDst, pSkill)
		pAT:AttackMonsterForce()

		--[[
		struct _attack_force_result_zocl
		{
			char byAtterID;
			unsigned int dwAtterSerial;
			char byForceIndex;
			char byForceLv;
			__int16 zAreaPos[2];
			char byAttackPart;
			bool bCritical;
			bool bWPActive;
			char byListNum;
			_attack_gen_result_zocl::_dam_list DamList[32];
		};
		--]]

		sendBuf:Init()
		sendBuf:PushUInt8(pMonster.m_ObjID.m_byID)
		sendBuf:PushUInt32(pMonster.m_dwObjSerial)
		sendBuf:PushUInt8(pAT.m_pp.pFld.m_dwIndex)
		sendBuf:PushInt8(pAT.m_pp.nLevel)
		sendBuf:PushInt16(pAT.m_pp.fArea_x)
		sendBuf:PushInt16(pAT.m_pp.fArea_z)
		sendBuf:PushInt8(pAT.m_pp.nPart)
		sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
		sendBuf:PushUInt8(pAT.m_bActiveSucc and 1 or 0)
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

		pMonster:CircleReport(5, 9, sendBuf, false)
	else
		return 0
	end

	if not pAT then
		return 0
	end

	local nLv = pMonster:GetLevel()

	for _,d in ipairs(pAT.m_DamList) do
		d.m_pChar:SetDamage(d.m_nDamage, pMonster, nLv, pAT.m_bIsCrtAtt, -1, 0, true)
	end

	pSkill.m_BefTime = Sirin.mainThread.GetLoopTime()
	pSkill.m_nAccumulationCount = pSkill.m_nAccumulationCount + 1

	if pMonster.m_bMove then
		pMonster:Stop()
	end

	return 1
end

---@param pMonster CMonster
---@param nPart integer
---@return number
function sirinMonsterMgr.GetDefGap(pMonster, nPart)
	return baseToMonsterCharacter(pMonster.m_pRecordSet).m_fDefGap
end

---@param pMonster CMonster
---@param nPart integer
---@return number
function sirinMonsterMgr.GetDefFacing(pMonster, nPart)
	return baseToMonsterCharacter(pMonster.m_pRecordSet).m_fDefFacing
end

---@param pMonster CMonster
---@param nAttactPart integer
---@param pAttChar CCharacter
---@return integer nDefFC
---@return integer nConvertPart
function sirinMonsterMgr.GetDefFC(pMonster, nAttactPart, pAttChar)
	if pMonster.m_pMonRec then
		if pAttChar and pMonster.m_pMonRec.m_nShieldBlock == 1 and math.random(0, 99) < pMonster.m_pMonRec.m_nBlockPer then
			return -2, 0
		end

		local defFC = 0

		if nAttactPart == -1 then
			defFC =  pMonster:m_DefPart_get(math.random(0, 4))
		else
			defFC =  pMonster:m_DefPart_get(nAttactPart)
		end

		defFC = math.floor(defFC * pMonster.m_EP:GetEff_Rate(_EFF_RATE.DefFc))

		return defFC, 0
	else
		return 0, 0
	end
end

---@param pMonster CMonster
---@return number
function sirinMonsterMgr.GetWeaponAdjust(pMonster)
	return baseToMonsterCharacter(pMonster.m_pRecordSet).m_fAttGap
end

return sirinMonsterMgr
