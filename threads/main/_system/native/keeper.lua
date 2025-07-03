local math = math

local sirinKeeperMgr = {}

---@param _this CHolyKeeper
---@param nPart integer
---@return number
function sirinKeeperMgr.GetDefGap(_this, nPart)
	return _this.m_pRec.m_fDefGap
end

---@param _this CHolyKeeper
---@param nPart integer
---@return number
function sirinKeeperMgr.GetDefFacing(_this, nPart)
	return _this.m_pRec.m_fDefFacing
end

---@param _this CHolyKeeper
---@param nAttactPart integer
---@param pAttChar CCharacter
---@return integer nDefFC
---@return integer nConvertPart
function sirinKeeperMgr.CPlayer__GetDefFC(_this, nAttactPart, pAttChar)
	if nAttactPart == -1 then
		return _this:m_nDefPart_get(math.random(0, 4)), 0
	else
		return _this:m_nDefPart_get(nAttactPart), 0
	end
end

---@param _this CHolyKeeper
---@return number
function sirinKeeperMgr.GetWeaponAdjust(_this)
	return _this.m_pRec.m_fDefGap -- yes, this is not my mistake
end

return sirinKeeperMgr