
local sirinNuclearBombMgr = {}

---@param pBomb CNuclearBomb
function sirinNuclearBombMgr.CNuclearBomb__NuclearDamege(pBomb)
	local pFldTrap = Sirin.mainThread.baseToTrapItem(pBomb.m_pRecordSet)
	local nRadius = math.floor(pFldTrap.m_fGADst / 100)
	local list = pBomb.m_pCurMap:GetPlayerListInRadius(pBomb.m_wMapLayerIndex, pBomb.m_dwCurSec, nRadius, pBomb.m_fCurPos_x, pBomb.m_fCurPos_y, pBomb.m_fCurPos_z, true)

	for _,p in ipairs(list) do
		repeat
			if not p.m_bLive or p.m_bCorpse then
				break
			end

			if not p:IsBeAttackedAble(true) then
				break
			end

			if p:GetObjRace() == pBomb.m_pMaster:GetObjRace() then
				break
			end

			if p:IsInTown() and not p:IsAttackableInTown() then
				break
			end

			if p:GetWidth() / 2 + pFldTrap.m_fGADst < GetSqrt(pBomb.m_fCurPos_x, pBomb.m_fCurPos_z, p.m_fCurPos_x, p.m_fCurPos_z) then
				break
			end

			local dam = pBomb:m_DamList_get(pBomb.m_nDamagedObjNum)
			dam.m_pChar = p
			dam.m_dwDamCharSerial = p.m_dwObjSerial
			dam.m_nDamage = pFldTrap.m_nGAMaxAF
			pBomb.m_nDamagedObjNum = pBomb.m_nDamagedObjNum + 1

			if pBomb.m_nDamagedObjNum >= 300 then
				return
			end

		until true
	end
end

---@param pBomb CNuclearBomb
---@param StartNum integer
---@param Obj_num integer
function sirinNuclearBombMgr.CNuclearBomb__Attack(pBomb, StartNum, Obj_num)
	for i = 1, Obj_num do
		local dam = pBomb:m_DamList_get(StartNum * 30 + i - 1)

		if dam.m_pChar.m_bLive and dam.m_dwDamCharSerial == dam.m_pChar.m_dwObjSerial then
			dam.m_pChar:SetDamage(dam.m_nDamage, pBomb, pBomb:GetLevel(), false, -1, 0, true)
		end
	end
end

return sirinNuclearBombMgr
