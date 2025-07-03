local sirinStoneMgr = {}

---@param _this CHolyStone
---@param nPart integer
---@return number
function sirinStoneMgr.GetDefGap(_this, nPart)
	return _this.m_pRec.m_fDefGap
end

---@param _this CHolyStone
---@param nPart integer
---@return number
function sirinStoneMgr.GetDefFacing(_this, nPart)
	return _this.m_pRec.m_fDefFacing
end

---@param _this CHolyStone
---@param nAttactPart integer
---@param pAttChar CCharacter
---@return integer nDefFC
---@return integer nConvertPart
function sirinStoneMgr.CPlayer__GetDefFC(_this, nAttactPart, pAttChar)
	if nAttactPart == -1 then
		return _this:m_nDefPart_get(math.random(0, 4)), 0
	else
		return _this:m_nDefPart_get(nAttactPart), 0
	end
end

---@param _this CHolyStone
---@return number
function sirinStoneMgr.GetWeaponAdjust(_this)
	return _this.m_pRec.m_fDefGap -- yes, this is not my mistake
end

return sirinStoneMgr