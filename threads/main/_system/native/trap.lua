local math = math

local baseToTrapItem = Sirin.mainThread.baseToTrapItem

local sendBuf = Sirin.mainThread.CLuaSendBuffer.Instance()

local sirinTrapMgr = {}

---@param pTrap CTrap
---@param pDst CCharacter
---@return sirinCAttack
function sirinTrapMgr.make_trap_attack_param(pTrap, pDst)
	local pAT = SirinCAttack:new()
	pAT.m_pp = Sirin_attack_param:new()
	local pAP = pAT.m_pp
	pAP.pDst = pDst
	pAP.nPart = CharacterMgr.GetAttackRandomPart(pDst and pDst or pTrap)
	local pTrapFld = baseToTrapItem(pTrap.m_pRecordSet)
	pAP.nTol = pTrapFld.m_nProperty
	pAP.nClass = 1
	pAP.nMinAF = pTrapFld.m_nGAMinAF
	pAP.nMaxAF = pTrapFld.m_nGAMaxAF
	pAP.nMinSel = pTrapFld.m_nGAMinSelProb
	pAP.nMaxSel = pTrapFld.m_nGAMaxSelProb
	pAP.nAttactType = 6
	pAP.nExtentRange = math.floor(pTrapFld.m_fGADst)
	pAP.fArea_x = pTrap.m_fCurPos_x
	pAP.fArea_y = pTrap.m_fCurPos_y
	pAP.fArea_z = pTrap.m_fCurPos_z
	pAP.nMaxAttackPnt = pTrap.m_nTrapMaxAttackPnt

	return pAT
end

---@param pTrap CTrap
---@param pTarget CCharacter
function sirinTrapMgr.CTrap__Attack(pTrap, pTarget)
	repeat
		local pAT = sirinTrapMgr.make_trap_attack_param(pTrap, pTarget)
		pAT:AttackGen(false, false)

		if #pAT.m_DamList == 0 then
			break
		end

		--[[
		struct _attack_trap_inform_zocl
		{
			unsigned int dwAtterSerial;
			bool bCritical;
			char byListNum;
			_attack_gen_result_zocl::_dam_list DamList[32];
		};
		--]]

		sendBuf:Init()
		sendBuf:PushUInt32(pTrap.m_dwObjSerial)
		sendBuf:PushUInt8(pAT.m_bIsCrtAtt and 1 or 0)
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

		pTrap:CircleReport(5, 152, sendBuf, false)

		for _,d in ipairs(pAT.m_DamList) do
			d.m_pChar:SetDamage(d.m_nDamage, pTrap, pTrap:GetLevel(), pAT.m_bIsCrtAtt, -1, 0, true)
		end

	until true
end

return sirinTrapMgr
