local baseToUnmannedMinerItem = Sirin.mainThread.baseToUnmannedMinerItem
local g_Main = Sirin.mainThread.g_Main

local sirinAutominePersonalMgr = {}

---@param pAMP AutominePersonal
---@param nPart integer
---@return number
function sirinAutominePersonalMgr.GetDefGap(pAMP, nPart)
	if pAMP.m_pItem then
		local pFld = baseToUnmannedMinerItem(g_Main:m_tblItemData_get(TBL_CODE.umtool):GetRecord(pAMP.m_pItem.m_wItemIndex))

		if pFld then
			return pFld.m_fDefGap
		end
	end

	return 0.5
end

---@param pAMP AutominePersonal
---@param nPart integer
---@return number
function sirinAutominePersonalMgr.GetDefFacing(pAMP, nPart)
	if pAMP.m_pItem then
		local pFld = baseToUnmannedMinerItem(g_Main:m_tblItemData_get(TBL_CODE.umtool):GetRecord(pAMP.m_pItem.m_wItemIndex))

		if pFld then
			return pFld.m_fDefFacing
		end
	end

	return 0.5
end

---@param pAMP AutominePersonal
---@param nAttactPart integer
---@param pAttChar CCharacter
---@return integer nDefFC
---@return integer nConvertPart
function sirinAutominePersonalMgr.GetDefFC(pAMP, nAttactPart, pAttChar)
	if pAMP.m_pItem then
		local pFld = baseToUnmannedMinerItem(g_Main:m_tblItemData_get(TBL_CODE.umtool):GetRecord(pAMP.m_pItem.m_wItemIndex))

		if pFld then
			return pFld.m_nDefFc, 0
		end
	end

	return 1, 0
end

return sirinAutominePersonalMgr