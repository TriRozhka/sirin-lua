local math = math

local sirinKeeperMgr = {}

---@param pKeeper CHolyKeeper
---@param nPart integer
---@return number
function sirinKeeperMgr.GetDefGap(pKeeper, nPart)
	return pKeeper.m_pRec.m_fDefGap
end

---@param pKeeper CHolyKeeper
---@param nPart integer
---@return number
function sirinKeeperMgr.GetDefFacing(pKeeper, nPart)
	return pKeeper.m_pRec.m_fDefFacing
end

---@param pKeeper CHolyKeeper
---@param nAttactPart integer
---@param pAttChar CCharacter
---@return integer nDefFC
---@return integer nConvertPart
function sirinKeeperMgr.GetDefFC(pKeeper, nAttactPart, pAttChar)
	if nAttactPart == -1 then
		return pKeeper:m_nDefPart_get(math.random(0, 4)), 0
	else
		return pKeeper:m_nDefPart_get(nAttactPart), 0
	end
end

---@param pKeeper CHolyKeeper
---@return number
function sirinKeeperMgr.GetWeaponAdjust(pKeeper)
	return pKeeper.m_pRec.m_fDefGap -- yes, this is not my mistake
end

return sirinKeeperMgr