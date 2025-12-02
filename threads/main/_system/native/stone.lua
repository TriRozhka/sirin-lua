local sirinStoneMgr = {}

---@param pStone CHolyStone
---@param nPart integer
---@return number
function sirinStoneMgr.GetDefGap(pStone, nPart)
	return pStone.m_pRec.m_fDefGap
end

---@param pStone CHolyStone
---@param nPart integer
---@return number
function sirinStoneMgr.GetDefFacing(pStone, nPart)
	return pStone.m_pRec.m_fDefFacing
end

---@param pStone CHolyStone
---@param nAttactPart integer
---@param pAttChar CCharacter
---@return integer nDefFC
---@return integer nConvertPart
function sirinStoneMgr.GetDefFC(pStone, nAttactPart, pAttChar)
	if nAttactPart == -1 then
		return pStone:m_nDefPart_get(math.random(0, 4)), 0
	else
		return pStone:m_nDefPart_get(nAttactPart), 0
	end
end

---@param pStone CHolyStone
---@return number
function sirinStoneMgr.GetWeaponAdjust(pStone)
	return pStone.m_pRec.m_fDefGap -- yes, this is not my mistake
end

return sirinStoneMgr