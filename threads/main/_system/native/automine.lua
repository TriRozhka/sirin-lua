local baseToUnmannedMinerItem = Sirin.mainThread.baseToUnmannedMinerItem
local g_Main = Sirin.mainThread.g_Main

local sirinAutominePersonalMgr = {}

---@param _this AutominePersonal
---@param nPart integer
---@return number
function sirinAutominePersonalMgr.GetDefGap(_this, nPart)
	if _this.m_pItem then
		local pFld = baseToUnmannedMinerItem(g_Main:m_tblItemData_get(TBL_CODE.umtool):GetRecord(_this.m_pItem.m_wItemIndex))

		if pFld then
			return pFld.m_fDefGap
		end
	end

	return 0.5
end

---@param _this AutominePersonal
---@param nPart integer
---@return number
function sirinAutominePersonalMgr.GetDefFacing(_this, nPart)
	if _this.m_pItem then
		local pFld = baseToUnmannedMinerItem(g_Main:m_tblItemData_get(TBL_CODE.umtool):GetRecord(_this.m_pItem.m_wItemIndex))

		if pFld then
			return pFld.m_fDefFacing
		end
	end

	return 0.5
end

---@param _this AutominePersonal
---@param nAttactPart integer
---@param pAttChar CCharacter
---@return integer nDefFC
---@return integer nConvertPart
function sirinAutominePersonalMgr.CPlayer__GetDefFC(_this, nAttactPart, pAttChar)
	if _this.m_pItem then
		local pFld = baseToUnmannedMinerItem(g_Main:m_tblItemData_get(TBL_CODE.umtool):GetRecord(_this.m_pItem.m_wItemIndex))

		if pFld then
			return pFld.m_nDefFc, 0
		end
	end

	return 1, 0
end

return sirinAutominePersonalMgr