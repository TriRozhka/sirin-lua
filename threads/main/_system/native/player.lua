local _EFF_HAVE = _EFF_HAVE
local _EFF_PLUS = _EFF_PLUS
local _EFF_RATE = _EFF_RATE
local _EFF_STATE = _EFF_STATE
local baseToUnitFrame = Sirin.mainThread.baseToUnitFrame
local baseToItemUpgrade = Sirin.mainThread.baseToItemUpgrade
local baseToDfnEquipItem = Sirin.mainThread.baseToDfnEquipItem
local baseToWeaponItem = Sirin.mainThread.baseToWeaponItem
local g_Main = Sirin.mainThread.g_Main
local CONST_ChipBreakerBonus_Def = CONST_ChipBreakerBonus_Def
local CONST_PatriarchBonus_Def = CONST_PatriarchBonus_Def
local CONST_ArchonBonus_Def = CONST_ArchonBonus_Def
local CONST_DefenseCouncilBonus_Def = CONST_DefenseCouncilBonus_Def
local CONST_s_fPartGravity = CONST_s_fPartGravity
local math = math
local sendBuf = Sirin.mainThread.CLuaSendBuffer.Instance()

---@class sirinPlayerMgr
local sirinPlayerMgr = {
	m_strUUID = 'sirin.lua.sirinPlayerMgr',
	m_ProtectEffectIndex = { {}, {} },
	SuccRates = {
		{ 1000,		750,		500,		250,		100,		50,			0 },
		{ 1000,		750,		500,		250,		100,		50,			0 },
		{ 1000,		750,		500,		250,		100,		50,			0 },
		{ 1000,		750,		500,		250,		100,		50,			0 },
		{ 328,		246,		164,		82,			49,			16,			0 },
		{ 640,		480,		320,		160,		96,			32,			0 },
		{ 512,		384,		256,		128,		77,			26,			0 },
		{ 410,		307,		205,		102,		61,			20,			0 },
		{ 800,		600,		400,		200,		120,		40,			0 },
		{ 262,		197,		131,		66,			39,			13,			0 },
		{ 210,		157,		105,		52,			31,			10,			0 },
	},
	ItemLostRates = {
		{ 0,		0,			0,			0,			1600,		3200,		6400 },
		{ 0,		0,			1200,		1600,		3000,		4400,		6800 },
		{ 0,		0,			0,			1000,		2250,		3500,		5750 },
		{ 0,		750,		1125,		1500,		2375,		3250,		4625 },
		{ 2400,		3940,		6170,		6790,		7470,		8220,		9040 },
		{ 7000,		7700,		8470,		9320,		10000,		10000,		10000 },
		{ 4900,		6160,		7620,		8390,		9220,		10000,		10000 },
		{ 3430,		4930,		6860,		7550,		8300,		9130,		10000 },
		{ 10000,	10000,		10000,		10000,		10000,		10000,		10000 },
		{ 1680,		3150,		5560,		6110,		6720,		7400,		8140 },
		{ 1180,		2520,		5000,		5500,		6050,		6660,		7320 },
	},
	UpgLostRates = {
		{ 0,		0,			0,			0,			2000,		4000,		8000 },
		{ 0,		0,			2400,		3200,		6000,		8800,		9500 },
		{ 0,		0,			0,			2000,		4500,		7000,		9500 },
		{ 0,		3000,		4500,		6000,		9500,		9500,		9500 },
		{ 0,		7300,		9500,		9500,		9500,		9500,		9500 },
		{ 0,		4300,		6400,		8600,		9500,		9500,		9500 },
		{ 0,		5100,		7600,		9500,		9500,		9500,		9500 },
		{ 0,		6100,		9100,		9500,		9500,		9500,		9500 },
		{ 0,		3600,		5400,		7200,		9500,		9500,		9500 },
		{ 0,		8700,		9500,		9500,		9500,		9500,		9500 },
		{ 0,		9500,		9500,		9500,		9500,		9500,		9500 },
	}
}

function sirinPlayerMgr.initHooks()
	SirinLua.HookMgr.addHook("CPlayer__pc_UpgradeItem", HOOK_POS.original, sirinPlayerMgr.m_strUUID, sirinPlayerMgr.pc_UpgradeItem)
	SirinLua.HookMgr.addHook("CPlayer__pc_MakeItem", HOOK_POS.original, sirinPlayerMgr.m_strUUID, sirinPlayerMgr.pc_MakeItem)
	--SirinLua.HookMgr.addHook("CPlayer__apply_have_item_std_effect", HOOK_POS.original, sirinPlayerMgr.m_strUUID, sirinPlayerMgr.apply_have_item_std_effect)
	--SirinLua.HookMgr.addHook("CPlayer__apply_normal_item_std_effect", HOOK_POS.original, sirinPlayerMgr.m_strUUID, sirinPlayerMgr.apply_normal_item_std_effect)
	--SirinLua.HookMgr.addHook("CPlayer__apply_case_equip_upgrade_effect", HOOK_POS.original, sirinPlayerMgr.m_strUUID, sirinPlayerMgr.apply_case_equip_upgrade_effect)
end

function sirinPlayerMgr.init()
	--sirinPlayerMgr.addUpgradeProtectionPotion(PROTECT_TYPE.ItemLost, "ipcsa00")
	--sirinPlayerMgr.addUpgradeProtectionPotion(PROTECT_TYPE.UpgradeLost, "ipcsa00")
end

---@param pPlayer CPlayer
---@param nAlter number
function sirinPlayerMgr.alterDalant(pPlayer, nAlter)
	pPlayer:AlterDalant(nAlter)
	pPlayer:SendMsg_AlterMoneyInform(0)
	NetMgr.alterMoneyInform(pPlayer, 0, nAlter)
end

---@param pPlayer CPlayer
---@param nAlter number
function sirinPlayerMgr.alterGold(pPlayer, nAlter)
	pPlayer:AlterGold(nAlter)
	pPlayer:SendMsg_AlterMoneyInform(0)
	NetMgr.alterMoneyInform(pPlayer, 1, nAlter)
end

---@param pPlayer CPlayer
---@param nAlter number
function sirinPlayerMgr.alterPVPCash(pPlayer, nAlter)
	if pPlayer:GetLevel() < 40 or pPlayer.m_Param.m_pClassData.m_nGrade < 1 then
		return
	end

	pPlayer:AlterPvPCashBag(nAlter, PVP_MONEY_ALTER_TYPE.pm_shop)
	NetMgr.alterMoneyInform(pPlayer, 2, nAlter)
end

---@param pPlayer CPlayer
---@param nAlter number
function sirinPlayerMgr.alterPVP(pPlayer, nAlter)
	pPlayer:AlterPvPPoint(nAlter, PVP_ALTER_TYPE.logoff_inc, 0xFFFFFFFF)
	NetMgr.alterMoneyInform(pPlayer, 3, nAlter)
end

---@param pPlayer CPlayer
---@param nAlter number
---@param byPointType integer
---@return boolean
function sirinPlayerMgr.alterActionPoint(pPlayer, nAlter, byPointType)
	if byPointType < 0 or byPointType > 2 then
		return false
	end

	if Sirin.mainThread.CActionPointSystemMgr.Instance():GetEventStatus(byPointType) ~= 2 then
		return false
	end

	local nOldPoint = pPlayer.m_pUserDB:GetActPoint(byPointType)
	local nPoint = nOldPoint + math.floor(nAlter)

	if nPoint < 0 then
		nPoint = 0
	end

	if nPoint ~= nOldPoint then
		pPlayer.m_pUserDB:Update_User_Action_Point(byPointType, nPoint)
		local NewPoint = pPlayer.m_pUserDB:GetActPoint(byPointType)
		nPoint = NewPoint - nOldPoint

		if nPoint ~= 0 then
			pPlayer:SendMsg_Alter_Action_Point(byPointType, NewPoint)
			NetMgr.alterMoneyInform(pPlayer, 4 + byPointType, nPoint)
		end
	end

	return true
end

---@param pPlayer CPlayer
---@param nAlter integer
---@param bBreakCap boolean
---@return boolean
function sirinPlayerMgr.alterLevel(pPlayer, nAlter, bBreakCap)
	local nOldLevel = pPlayer:GetLevel()
	local nNewLevel = nOldLevel + nAlter
	local nMaxScriptlevel = Sirin.mainThread.cStaticMember_Player.Instance()._nMaxLv

	if nNewLevel < 1 then
		nNewLevel = 1
	end

	if nNewLevel > nMaxScriptlevel then
		nNewLevel = nMaxScriptlevel
	end

	if nNewLevel > pPlayer.m_Param.m_dbChar.m_byMaxLevel then
		if not bBreakCap then
			nNewLevel = pPlayer.m_Param.m_dbChar.m_byMaxLevel
		else
			local nLv = nNewLevel

			while nLv < nMaxScriptlevel do
				local szBufr = string.format("%d", nLv)

				if Sirin.mainThread.CQuestMgr__s_tblQuestHappenEvent_get(8):GetRecord(szBufr) then
					break
				end

				nLv = nLv + 1
			end

			pPlayer.m_Param.m_dbChar.m_byMaxLevel = nLv
			pPlayer.m_pUserDB:Update_MaxLevel(nLv)
		end
	end

	if nNewLevel == nOldLevel then
		return false
	end

	if nNewLevel < nOldLevel then
		local OldDegree = pPlayer.m_byUserDgr
		pPlayer.m_byUserDgr = 2
		pPlayer.m_pUserDB.m_byUserDgr = 2
		pPlayer.m_Param.m_dbChar.m_dExp = 0
		pPlayer.m_dwExpRate = 0
		pPlayer:SetLevelD(nNewLevel)
		pPlayer.m_byUserDgr = OldDegree
		pPlayer.m_pUserDB.m_byUserDgr = OldDegree
	else
		pPlayer.m_Param.m_dbChar.m_dExp = 0
		pPlayer.m_dwExpRate = 0
		pPlayer:SetLevel(nNewLevel)
	end

	return true
end

---@param pPlayer CPlayer
---@param nVal integer
---@param bBreakCap boolean
---@param bAllowDeLevel boolean
---@return boolean
function sirinPlayerMgr.setLevel(pPlayer, nVal, bBreakCap, bAllowDeLevel)
	local nOldLevel = pPlayer:GetLevel()
	local nNewLevel = nVal
	local nMaxScriptlevel = Sirin.mainThread.cStaticMember_Player.Instance()._nMaxLv

	if nNewLevel < nOldLevel and not bAllowDeLevel then
		return false
	end

	if nNewLevel > nMaxScriptlevel then
		nNewLevel = nMaxScriptlevel
	end

	if nNewLevel > pPlayer.m_Param.m_dbChar.m_byMaxLevel then
		if not bBreakCap then
			nNewLevel = pPlayer.m_Param.m_dbChar.m_byMaxLevel
		else
			local nLv = nNewLevel

			while nLv < nMaxScriptlevel do
				local szBufr = string.format("%d", nLv)

				if Sirin.mainThread.CQuestMgr__s_tblQuestHappenEvent_get(8):GetRecord(szBufr) then
					break
				end

				nLv = nLv + 1
			end

			pPlayer.m_Param.m_dbChar.m_byMaxLevel = nLv
			pPlayer.m_pUserDB:Update_MaxLevel(nLv)
		end
	end

	if nNewLevel == nOldLevel then
		return false
	end

	if nNewLevel < nOldLevel then
		local OldDegree = pPlayer.m_byUserDgr
		pPlayer.m_byUserDgr = 2
		pPlayer.m_pUserDB.m_byUserDgr = 2
		pPlayer.m_Param.m_dbChar.m_dExp = 0
		pPlayer.m_dwExpRate = 0
		pPlayer:SetLevelD(nNewLevel)
		pPlayer.m_byUserDgr = OldDegree
		pPlayer.m_pUserDB.m_byUserDgr = OldDegree
	else
		pPlayer.m_Param.m_dbChar.m_dExp = 0
		pPlayer.m_dwExpRate = 0
		pPlayer:SetLevel(nNewLevel)
	end

	return true
end

---@param nSkillGrade integer
---@param dwHitCount integer
---@return integer
function sirinPlayerMgr.GetSFLevel(nSkillGrade, dwHitCount)
	local sR = { 200, 200, 200, 200 }
	local nLv = math.floor(math.sqrt(math.sqrt((dwHitCount + 1) / sR[nSkillGrade + 1])) + 0.9999)

	if nLv > 7 then
		nLv = 7
	elseif nLv < 1 then
		nLv = 1
	end

	return nLv
end

---@param nSkillGrade integer
---@param byLv integer
---@return integer
function sirinPlayerMgr.GetSFHitCount(nSkillGrade, byLv)
	local sR = { 200, 200, 200, 200 }
	return math.floor((((byLv - 0.9999) ^ 2) ^ 2) * sR[nSkillGrade + 1])
end

---@param nMasteryCode integer
---@param nMasteryIndex integer
---@param dwMasteryCum integer
---@return number
function sirinPlayerMgr.CalcMastery(nMasteryCode, nMasteryIndex, dwMasteryCum)
	local fRet = 0.0

	if nMasteryCode == 0 or nMasteryCode == 1 then
		fRet = dwMasteryCum + 1.0
		fRet = math.sqrt(math.sqrt(fRet) + fRet / 1000.0)
	elseif nMasteryCode == 2 then
		fRet = dwMasteryCum + 1.0
		fRet = math.sqrt(math.sqrt(fRet) + fRet / 100.0)
	elseif nMasteryCode == 3 then
		fRet = dwMasteryCum + 1.0
		fRet = math.sqrt(math.sqrt(fRet * 10.0))
	elseif nMasteryCode == 4 then
		fRet = dwMasteryCum + 1.0
		fRet = math.sqrt(math.sqrt(fRet * 14.0))
	elseif nMasteryCode == 5 then
		if nMasteryIndex == 0 or nMasteryIndex == 1 then
			fRet = (3 * dwMasteryCum) / 1.1 + 1.0
		else
			fRet = (3 * dwMasteryCum) / 10.0 + 1.0
		end

		fRet = math.sqrt(fRet)
	elseif nMasteryCode == 6 then
		if nMasteryIndex == 0 or nMasteryIndex == 1 then
			fRet = math.sqrt(dwMasteryCum / 15000.0) + 1.0
		else
			fRet = dwMasteryCum + 1.0
			fRet = math.sqrt(math.sqrt(fRet) + fRet / 1000.0)
		end
	else
		return fRet
	end

	if fRet < 1.0 then
		fRet = 1.0
	end

	if fRet > 99.0 then
		fRet = 99.0
	end

	return fRet
end

---@param nMasteryCode integer
---@param nMasteryIndex integer
---@param fMasteryPt number
---@return integer
function sirinPlayerMgr.GetCumForMastery(nMasteryCode, nMasteryIndex, fMasteryPt)
	if fMasteryPt < 1.0 then
		return 0
	end

	if fMasteryPt > 99.0 then
		fMasteryPt = 99.0
	end

	local fRet = 0

	if nMasteryCode == 0 or nMasteryCode == 1 then
		fRet = ((-1000.0 + math.sqrt(1000000.0 + 4000.0 * (fMasteryPt ^ 2))) / 2.0) ^ 2
	elseif nMasteryCode == 2 then
		fRet = ((-100.0 + math.sqrt(10000.0 + 400.0 * (fMasteryPt ^ 2))) / 2.0) ^ 2
	elseif nMasteryCode == 3 then
		fRet = (fMasteryPt ^ 4) / 10.0
	elseif nMasteryCode == 4 then
		fRet = (fMasteryPt ^ 4) / 14.0
	elseif nMasteryCode == 5 then
		if nMasteryIndex == 0 or nMasteryIndex == 1 then
			fRet = ((fMasteryPt ^ 2) - 1.0) * 1.1 / 3.0 + 1.0
		else
			fRet = ((fMasteryPt ^ 2) - 1.0) * 10.0 / 3.0 + 1.0
		end
	elseif nMasteryCode == 6 then
		if nMasteryIndex == 0 or nMasteryIndex == 1 then
			fRet = ((fMasteryPt - 1) ^ 2) * 15000.0
		else
			fRet = ((-1000.0 + math.sqrt(1000000.0 + 4000.0 * (fMasteryPt ^ 2))) / 2.0) ^ 2
		end
	else
		return 0
	end

	return math.floor(fRet)
end

---@param byMasteryClass integer
---@param byIndex integer
---@return integer
function sirinPlayerMgr.GetStatIndex(byMasteryClass, byIndex)
	if byMasteryClass == 0 then
		return byIndex
	elseif byMasteryClass == 1 then
		return 2
	elseif byMasteryClass == 2 then
		return 3
	elseif byMasteryClass == 3 then
		return byIndex + 4
	elseif byMasteryClass == 4 then
		return byIndex + 52
	elseif byMasteryClass == 5 then
		return byIndex + 76
	elseif byMasteryClass == 6 then
		return 79
	else
		return -1
	end
end

---@param pPlayer CPlayer
---@param nPTIndex integer
---@param nDeltaPt integer
---@return boolean
function sirinPlayerMgr.alterPT(pPlayer, nPTIndex, nDeltaPt)
	local byMastCode = 255
	local byMastIndex = 255

	if nPTIndex == 1 then
		byMastCode = 0
		byMastIndex = 0
	elseif nPTIndex == 2 then
		byMastCode = 0
		byMastIndex = 1
	elseif nPTIndex == 3 then
		byMastCode = 1
		byMastIndex = 0
	elseif nPTIndex == 4 then
		byMastCode = 2
		byMastIndex = 0
	elseif nPTIndex == 5 then
		byMastCode = 5
		byMastIndex = 0
	elseif nPTIndex == 6 then
		byMastCode = 5
		byMastIndex = 1
	elseif nPTIndex == 7 then
		byMastCode = 5
		byMastIndex = 2
	elseif nPTIndex == 8 then
		byMastCode = 6
		byMastIndex = 0
	else
		return false
	end

	local dwCumLim = pPlayer:_check_mastery_cum_lim(byMastCode, byMastIndex)
	local dwCum = pPlayer.m_pmMst:GetCumPerMast(byMastCode, byMastIndex)

	if (dwCum >= dwCumLim and nDeltaPt > 0) or (dwCum == 0 and nDeltaPt < 0) then
		return false
	end

	local nStatIndex = sirinPlayerMgr.GetStatIndex(byMastCode, byMastIndex)

	if nStatIndex == -1 then
		return false
	end

	if (nStatIndex == 79 and pPlayer.m_Param:GetRaceCode() == 2) or (nStatIndex < 4 and nStatIndex ~= 2) then
		if nDeltaPt < 0 then
			pPlayer.m_bDownCheckEquipEffect = true
		else
			pPlayer.m_bUpCheckEquipEffect = true
		end
	end

	local fNewPT = sirinPlayerMgr.CalcMastery(byMastCode, byMastCode ~= 6 and byMastIndex or pPlayer.m_Param:GetRaceCode(), dwCum) + nDeltaPt

	if fNewPT < 1.0 then
		fNewPT = 1.0
	end

	local dwNewCum = sirinPlayerMgr.GetCumForMastery(byMastCode, byMastIndex, fNewPT)

	if dwNewCum >= dwCumLim then
		dwNewCum = dwCumLim
	end

	local OldDegree = pPlayer.m_pUserDB.m_byUserDgr

	if nDeltaPt < 0 then
		pPlayer.m_pUserDB.m_byUserDgr = 2
	end

	pPlayer:Emb_UpdateStat(nStatIndex, dwNewCum, dwCum)
	pPlayer.m_pmMst:UpdateCumPerMast(byMastCode, byMastIndex, dwNewCum)

	if nDeltaPt < 0 then
		pPlayer.m_pUserDB.m_byUserDgr = OldDegree
	end

	pPlayer:SendMsg_StatInform(nStatIndex, dwNewCum, 0)
	pPlayer:ReCalcMaxHFSP(true, false)

	return true
end

---@param pPlayer CPlayer
---@param byMastIndex integer
---@param nDeltaPt integer
---@return boolean
function sirinPlayerMgr.alterSkillMastery(pPlayer, byMastIndex, nDeltaPt)
	local byMastCode = 3

	local pFld = g_Main:m_tblEffectData_get(EFF_CODE.skill):GetRecord(byMastIndex)

	if not pFld then
		return false
	end

	local pSkillFld = Sirin.mainThread.baseToSkill(pFld)
	local dwCumLim = pPlayer:_check_mastery_cum_lim(byMastCode, pSkillFld.m_nMastIndex)
	local dwCum = pPlayer.m_pmMst:GetCumPerMast(byMastCode, pSkillFld.m_nMastIndex)

	if (dwCum >= dwCumLim and nDeltaPt > 0) or (dwCum == 0 and nDeltaPt < 0) then
		return false
	end

	local nStatIndex = sirinPlayerMgr.GetStatIndex(byMastCode, byMastIndex)

	if nStatIndex == -1 then
		return false
	end

	local fNewPT = sirinPlayerMgr.CalcMastery(byMastCode, byMastIndex, dwCum) + nDeltaPt

	if fNewPT < 1.0 then
		fNewPT = 1.0
	end

	local dwNewCum = sirinPlayerMgr.GetCumForMastery(byMastCode, byMastIndex, fNewPT)

	if dwNewCum >= dwCumLim then
		dwNewCum = dwCumLim
	end

	local OldDegree = pPlayer.m_pUserDB.m_byUserDgr

	if nDeltaPt < 0 then
		pPlayer.m_pUserDB.m_byUserDgr = 2
	end

	local dwOldHitCount = pPlayer.m_pmMst.m_BaseCum:m_dwSkillCum_get(byMastIndex)
	local nNewHitCount = dwNewCum - dwCum + dwOldHitCount

	if nNewHitCount < 0 then
		nNewHitCount = 0
	end

	pPlayer:Emb_UpdateStat(nStatIndex, nNewHitCount, dwOldHitCount)
	pPlayer.m_pmMst:UpdateCumPerMast(byMastCode, byMastIndex, nNewHitCount)
	pPlayer.m_pmMst:m_dwSkillMasteryCum_set(pSkillFld.m_nMastIndex, pPlayer.m_pmMst:m_dwSkillMasteryCum_get(pSkillFld.m_nMastIndex) - dwOldHitCount)

	if nDeltaPt < 0 then
		pPlayer.m_pUserDB.m_byUserDgr = OldDegree
	end

	pPlayer:SendMsg_StatInform(nStatIndex, nNewHitCount, 0)

	return true
end

---@param pPlayer CPlayer
---@param byMastIndex integer
---@param nDeltaPt integer
---@return boolean
function sirinPlayerMgr.alterForceMastery(pPlayer, byMastIndex, nDeltaPt)
	local byMastCode = 4
	local dwCumLim = pPlayer:_check_mastery_cum_lim(byMastCode, byMastIndex)
	local dwCum = pPlayer.m_pmMst:GetCumPerMast(byMastCode, byMastIndex)

	if (dwCum >= dwCumLim and nDeltaPt > 0) or (dwCum == 0 and nDeltaPt < 0) then
		return false
	end

	local nStatIndex = sirinPlayerMgr.GetStatIndex(byMastCode, byMastIndex)

	if nStatIndex == -1 then
		return false
	end

	if nDeltaPt < 0 then
		pPlayer.m_bDownCheckEquipEffect = true
	else
		pPlayer.m_bUpCheckEquipEffect = true
	end

	local fNewPT = sirinPlayerMgr.CalcMastery(byMastCode, byMastIndex, dwCum) + nDeltaPt

	if fNewPT < 1.0 then
		fNewPT = 1.0
	end

	local dwNewCum = sirinPlayerMgr.GetCumForMastery(byMastCode, byMastIndex, fNewPT)

	if dwNewCum >= dwCumLim then
		dwNewCum = dwCumLim
	end

	local OldDegree = pPlayer.m_pUserDB.m_byUserDgr

	if nDeltaPt < 0 then
		pPlayer.m_pUserDB.m_byUserDgr = 2
	end

	pPlayer:Emb_UpdateStat(nStatIndex, dwNewCum, dwCum)
	pPlayer.m_pmMst:UpdateCumPerMast(byMastCode, byMastIndex, dwNewCum)

	if nDeltaPt < 0 then
		pPlayer.m_pUserDB.m_byUserDgr = OldDegree
	end

	pPlayer:SendMsg_StatInform(nStatIndex, dwNewCum, 0)
	pPlayer:ReCalcMaxHFSP(true, false)

	return true
end

---@enum PROTECT_TYPE
PROTECT_TYPE = {
	ItemLost = 1,
	UpgradeLost = 2,
}

---@param type PROTECT_TYPE
function sirinPlayerMgr.resetUpgradeProtectionPotion(type)
	sirinPlayerMgr.m_ProtectEffectIndex[type] = {}
end

---@param type PROTECT_TYPE
---@param code string
function sirinPlayerMgr.addUpgradeProtectionPotion(type, code)
	repeat
		if code == "" then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, "sirinPlayerMgr.addUpgradeProtectionPotion(...): Invalid potion code: empty\n")
			break
		end

		local byTableCode = Sirin.mainThread.GetItemTableCode(code)

		if byTableCode ~= TBL_CODE.potion then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("sirinPlayerMgr.addUpgradeProtectionPotion(...): Invalid potion code: %s\n", code))
			break
		end

		local pFld = g_Main:m_tblItemData_get(TBL_CODE.potion):GetRecordByHash(code, 2, 5)

		if not pFld then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("sirinPlayerMgr.addUpgradeProtectionPotion(...): Potion item not exists: %s\n", code))
			break
		end

		table.insert(sirinPlayerMgr.m_ProtectEffectIndex[type], pFld.m_dwIndex)

	until true
end

---@param type PROTECT_TYPE
---@param index integer
---@return boolean
function sirinPlayerMgr.isUpgradeProtectEffect(type, index)
	local bHave = false
	local tblEff = sirinPlayerMgr.m_ProtectEffectIndex[type]

	if tblEff and #tblEff > 0 then
		for _,e in ipairs(tblEff) do
			if e == index then
				bHave = true
				break
			end
		end
	end

	return bHave
end

---@enum UPG_RATE_TYPE
UPG_RATE_TYPE = {
	Base = 1,
	ItemLost = 2,
	UpgradeLost = 3,
}

---@param type UPG_RATE_TYPE
---@param grade integer
---@param level integer
---@param rate integer
function sirinPlayerMgr.setUpgradeRate(type, grade, level, rate)
	if rate > 10000 or rate < 0 then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("sirinPlayerMgr.setUpgradeRate(...): Rate out of range: %n\n", rate))
		return
	end

	if level > 7 or level < 1 then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("sirinPlayerMgr.setUpgradeRate(...): Upgrade level out of range: %n\n", level))
		return
	end

	if grade > 11 or grade < 1 then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("sirinPlayerMgr.setUpgradeRate(...): Item garde out of range: %n\n", grade))
		return
	end

	if type == UPG_RATE_TYPE.Base then sirinPlayerMgr.SuccRates[grade][level] = rate
	elseif type == UPG_RATE_TYPE.ItemLost then sirinPlayerMgr.ItemLostRates[grade][level] = rate
	elseif type == UPG_RATE_TYPE.UpgradeLost then sirinPlayerMgr.UpgLostRates[grade][level] = rate end
end

---@param pPlayer CPlayer
---@param pposTalik _STORAGE_POS_INDIV
---@param pposToolItem _STORAGE_POS_INDIV
---@param pposUpgItem _STORAGE_POS_INDIV
---@param pposUpgJewel table<integer, _STORAGE_POS_INDIV>
function sirinPlayerMgr.pc_UpgradeItem(pPlayer, pposTalik, pposToolItem, pposUpgItem, pposUpgJewel)
	---@type integer
	local byErrCode = 0
	local pUpgItemStorage = pPlayer.m_Param:m_pStoragePtr_get(pposUpgItem.byStorageCode)
	---@type __ITEM
	local pTalikCon = nil
	---@type __ITEM
	local pUpgItemCon = nil
	---@type table<integer, __ITEM>
	local pJewelCon = {}
	---@type _ItemUpgrade_fld
	local pTalikUpgFld = nil
	---@type table<integer, _ItemUpgrade_fld>
	local pJewelUpgFld = {}
	---@type integer
	local bySocketLim = 0

	repeat
		if pPlayer.m_EP:GetEff_State(_EFF_STATE.Stone_Lck) then
			byErrCode = 8
			break
		end

		if pPlayer.m_EP:GetEff_State(_EFF_STATE.Invincible) then
			byErrCode = 8
			break
		end

		pUpgItemCon = pUpgItemStorage:GetPtrFromSerial(pposUpgItem.wItemSerial)

		if not pUpgItemCon then
			byErrCode = 5
			break
		end

		if pUpgItemCon.m_bLock then
			byErrCode = 13
			break
		end

		if GetItemKindCode(pUpgItemCon.m_byTableCode) ~= 0 then
			byErrCode = 9
			break
		end

		if Sirin.mainThread.GetDefItemUpgSocketNum(pUpgItemCon.m_byTableCode, pUpgItemCon.m_wItemIndex) == 0 then
			byErrCode = 9
			break
		end

		bySocketLim = Sirin.mainThread.GetItemUpgLimSocket(pUpgItemCon.m_dwLv)

		if Sirin.mainThread.GetItemUpgedLv(pUpgItemCon.m_dwLv) >= bySocketLim then
			byErrCode = 10
			break
		end

		pTalikCon = pPlayer.m_Param.m_dbInven:GetPtrFromSerial(pposTalik.wItemSerial)

		if not pTalikCon then
			pPlayer:SendMsg_AdjustAmountInform(0, pposTalik.wItemSerial, 0)
			byErrCode = 1
			break
		end

		if pTalikCon.m_byTableCode ~= TBL_CODE.res then
			byErrCode = 2
			break
		end

		if pTalikCon.m_bLock then
			byErrCode = 13
			break
		end

		pTalikUpgFld = g_Main.m_tblItemUpgrade:GetRecordFromRes(pTalikCon.m_wItemIndex)

		if not pTalikUpgFld then
			byErrCode = 2
			break
		end

		if pTalikUpgFld.m_dwIndex >= 13 then
			byErrCode = 2
			break
		end

		if not SirinLua.HookMgr.callHook(HOOK_POS.filter, "canUseWithNoTool", false, pPlayer, 3) then
			local pToolCon = pPlayer.m_Param.m_dbInven:GetPtrFromSerial(pposToolItem.wItemSerial)

			if not pToolCon then
				pPlayer:SendMsg_AdjustAmountInform(0, pposToolItem.wItemSerial, 0)
				byErrCode = 3
				break
			end

			if pToolCon.m_byTableCode ~= TBL_CODE.maketool then
				byErrCode = 4
				break
			end

			if pToolCon.m_bLock then
				byErrCode = 13
				break
			end
		end

		if #pposUpgJewel > 4 then
			byErrCode = 7
			break
		end

		for i = 1, #pposUpgJewel do
			pJewelCon[i] = pPlayer.m_Param.m_dbInven:GetPtrFromSerial(pposUpgJewel[i].wItemSerial)

			if not pJewelCon[i] then
				pPlayer:SendMsg_AdjustAmountInform(0, pposUpgJewel[i].wItemSerial, 0)
				byErrCode = 6
				break
			end

			if pJewelCon[i].m_byTableCode ~= TBL_CODE.res then
				byErrCode = 7
				 break
			end

			if pJewelCon[i].m_bLock then
				byErrCode = 13
				break
			end

			pJewelUpgFld[i] = g_Main.m_tblItemUpgrade:GetRecordFromRes(pJewelCon[i].m_wItemIndex)

			if not pJewelUpgFld[i] then
				byErrCode = 7
				break
			end

			local j = 1

			while j < i do
				if pJewelCon[j] == pJewelCon[i] or pJewelUpgFld[j] == pJewelUpgFld[i] then
					byErrCode = 7
					break
				end

				j = j + 1
			end

			if byErrCode ~= 0 then
				break
			end

			if pJewelUpgFld[i] == pTalikUpgFld then
				byErrCode = 7
				break
			end
		end

		if byErrCode ~= 0 then
			break
		end

		if not Sirin.mainThread.IsAddAbleTalikToItem(pUpgItemCon.m_byTableCode, pUpgItemCon.m_wItemIndex, pUpgItemCon.m_dwLv, pTalikUpgFld) then
			byErrCode = 11
			break
		end

		local ItemCopy = Sirin.mainThread._STORAGE_LIST___db_con(pUpgItemCon)
		local TalikCopy = Sirin.mainThread._STORAGE_LIST___db_con(pTalikCon)
		local JewelCopy = {}

		for i = 1, #pJewelCon do
			table.insert(JewelCopy, Sirin.mainThread._STORAGE_LIST___db_con(pJewelCon[i]))
		end

		pPlayer:Emb_AlterDurPoint(0, pTalikCon.m_byStorageIndex, -1, false, false)

		for i = 1, #pJewelCon do
			pPlayer:Emb_AlterDurPoint(0, pJewelCon[i].m_byStorageIndex, -1, false, false)
		end

		local fJewelCumRate = 0.0

		for i = 1, 4 do
			if pJewelUpgFld[i] then
				fJewelCumRate = fJewelCumRate + pJewelUpgFld[i].m_fJewelFieldValue
			else
				fJewelCumRate = fJewelCumRate + 0.125
			end
		end

		local bStatUpdate = true

		if g_Main.m_bReleaseServiceMode and pPlayer.m_byUserDgr ~= 0 then
			bStatUpdate = false
		end

		if bStatUpdate then
			local pDayStat = Sirin.mainThread.g_GameStatistics:CurWriteData()
			pDayStat.dwDaePokUse_Evt = pDayStat.dwDaePokUse_Evt + math.floor(fJewelCumRate)
		end

		local byItemGrade = Sirin.mainThread.GetItemGrade(pUpgItemCon.m_byTableCode, pUpgItemCon.m_wItemIndex) + 1
		local _byUpgedLv = Sirin.mainThread.GetItemUpgedLv(pUpgItemCon.m_dwLv)
		local byUpgedLv = _byUpgedLv + 1

		if byItemGrade > 11 or _byUpgedLv > 7 then
			byErrCode = 20
			break
		end

		local dwTotalRate = math.floor(sirinPlayerMgr.SuccRates[byItemGrade][byUpgedLv] * fJewelCumRate / 4 * 100)
		local nItemLv = Sirin.mainThread.GetItemEquipLevel(pUpgItemCon.m_byTableCode, pUpgItemCon.m_wItemIndex)

		if nItemLv > 0 then
			dwTotalRate = math.floor(dwTotalRate * 30 / nItemLv)
		end

		if pPlayer.m_bCheat_100SuccMake then
			dwTotalRate = 0xFFFFFFFF
		end

		if dwTotalRate >= math.random(1, 100000) then
			-- upgrade success
			pPlayer:Emb_ItemUpgrade(0, pUpgItemStorage.m_nListCode, pUpgItemCon.m_byStorageIndex, Sirin.mainThread.GetBitAfterUpgrade(pUpgItemCon.m_dwLv, pTalikUpgFld.m_dwIndex, _byUpgedLv))
			pPlayer:SendMsg_FanfareItem(0, pUpgItemCon, nil)
			local pItemFld = g_Main:m_tblItemData_get(pUpgItemCon.m_byTableCode):GetRecord(pUpgItemCon.m_wItemIndex)
			pPlayer:Emb_CheckActForQuest(10, pItemFld.m_strCode, 1, false)

			if bStatUpdate then
				local pDayStat = Sirin.mainThread.g_GameStatistics:CurWriteData()

				if _byUpgedLv == 3 then
					if pTalikUpgFld.m_dwIndex == 0 then
						pDayStat.dw4MuUpgradeSucc_Evt = pDayStat.dw4MuUpgradeSucc_Evt + 1
					elseif pTalikUpgFld.m_dwIndex == 5 then
						pDayStat.dw4EunUpgradeSucc_Evt = pDayStat.dw4EunUpgradeSucc_Evt + 1
					elseif pTalikUpgFld.m_dwIndex == 12 then
						pDayStat.dw4JaUpgradeSucc_Evt = pDayStat.dw4JaUpgradeSucc_Evt + 1
					end
				elseif _byUpgedLv == 4 then
					if pTalikUpgFld.m_dwIndex == 0 then
						pDayStat.dw5MuUpgradeSucc_Evt = pDayStat.dw5MuUpgradeSucc_Evt + 1
					elseif pTalikUpgFld.m_dwIndex == 5 then
						pDayStat.dw5EunUpgradeSucc_Evt = pDayStat.dw5EunUpgradeSucc_Evt + 1
					elseif pTalikUpgFld.m_dwIndex == 12 then
						pDayStat.dw5JaUpgradeSucc_Evt = pDayStat.dw5JaUpgradeSucc_Evt + 1
					end
				end
			end
		else
			-- upgrade failed
			if sirinPlayerMgr.ItemLostRates[byItemGrade][byUpgedLv] >= math.random(1, 10000) then
				local bSaveSucc = false
				local ContData = Sirin.mainThread._ContPotionData()

				if not Sirin.mainThread.modContEffect.isUse() then
					for i = 0, 1 do
						if pPlayer.m_PotionParam:m_ContCommonPotionData_get(i):IsLive() and sirinPlayerMgr.isUpgradeProtectEffect(PROTECT_TYPE.ItemLost, pPlayer.m_PotionParam:m_ContCommonPotionData_get(i):GetEffectIndex()) then
							bSaveSucc = true
							ContData = pPlayer.m_PotionParam:m_ContCommonPotionData_get(i)
							break
						end
					end
				else
					for i = 0, Sirin.mainThread.modContEffect.getMaxPotionNum() - 1 do
						local pPotionEff = Sirin.mainThread.modContEffect.getPlayerPotion(pPlayer, i)

						if pPotionEff.m_bExist and sirinPlayerMgr.isUpgradeProtectEffect(PROTECT_TYPE.ItemLost, pPotionEff.m_dwEffectIndex) then
							bSaveSucc = true
							ContData.m_dwPotionEffectIndex = i
							break
						end
					end
				end

				if bSaveSucc then
					Sirin.mainThread.g_PotionMgr:RemovePotionContEffect(pPlayer, ContData)
					byErrCode = 100
				else
					local DeleteSkinUUID = Sirin.mainThread.modItemPropertySkin.isSkinItem(pUpgItemCon.m_dwDur) and pUpgItemCon.m_lnUID or 0

					if not pPlayer:Emb_DelStorage(pUpgItemStorage.m_nListCode, pUpgItemCon.m_byStorageIndex, false, true, "Lua. sirinPlayerMgr.pc_UpgradeItem()") then
						byErrCode = 255
						break
					end

					if DeleteSkinUUID ~= 0 then
						Sirin.mainThread.modItemPropertySkin.deleteProperty(DeleteSkinUUID)
					end

					-- for NATS integration
					-- NATS_Mgr.CPlayer__pc_UpgradeItem(pPlayer, ItemCopy)

					byErrCode = 102
				end
			elseif sirinPlayerMgr.UpgLostRates[byItemGrade][byUpgedLv] >= math.random(1, 10000) then
				local bSaveSucc = false
				local ContData = Sirin.mainThread._ContPotionData()

				if not Sirin.mainThread.modContEffect.isUse() then
					for i = 0, 1 do
						if pPlayer.m_PotionParam:m_ContCommonPotionData_get(i):IsLive() and sirinPlayerMgr.isUpgradeProtectEffect(PROTECT_TYPE.UpgradeLost, pPlayer.m_PotionParam:m_ContCommonPotionData_get(i):GetEffectIndex()) then
							bSaveSucc = true
							ContData = pPlayer.m_PotionParam:m_ContCommonPotionData_get(i)
							break
						end
					end
				else
					for i = 0, Sirin.mainThread.modContEffect.getMaxPotionNum() - 1 do
						local pPotionEff = Sirin.mainThread.modContEffect.getPlayerPotion(pPlayer, i)

						if pPotionEff.m_bExist and sirinPlayerMgr.isUpgradeProtectEffect(PROTECT_TYPE.UpgradeLost, pPotionEff.m_dwEffectIndex) then
							bSaveSucc = true
							ContData.m_dwPotionEffectIndex = i
							break
						end
					end
				end

				if bSaveSucc then
					Sirin.mainThread.g_PotionMgr:RemovePotionContEffect(pPlayer, ContData)
					byErrCode = 100
				else
					pPlayer:Emb_ItemUpgrade(2, pposUpgItem.byStorageCode, pUpgItemCon.m_byStorageIndex, Sirin.mainThread.GetBitAfterSetLimSocket(bySocketLim))
					byErrCode = 101
				end
			else
				byErrCode = 100
			end
		end

		Sirin.mainThread.CMgrAvatorItemHistory.Instance():grade_up_item(pPlayer, ItemCopy, TalikCopy, JewelCopy, byErrCode, pUpgItemCon.m_dwLv)
	until true

	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	buf:PushUInt8(byErrCode)
	buf:SendBuffer(pPlayer, 7, 18)
end

---@param pPlayer CPlayer
---@param pipMakeTool _STORAGE_POS_INDIV
---@param wManualIndex integer
---@param materials table<integer, _STORAGE_POS_INDIV>
function sirinPlayerMgr.pc_MakeItem(pPlayer, pipMakeTool, wManualIndex, materials)
	local byErrCode = 0
	local byMaterialNum = pPlayer.m_bCheat_makeitem_no_use_matrial and 0 or #materials
	local pMakeItemFld = Sirin.mainThread.baseToItemMakeData(g_Main.m_tblItemMakeData:GetRecord(wManualIndex))
	local byMasteryType = 1 -- 0 weapon, 1 armor, 2 bullet
	local byMasteryValue = 0
	local bPureCraftsman = false
	---@type _base_fld
	local pNewItemFld
	---@type table<integer, _STORAGE_LIST___db_con>
	local materialConList = {}
	---@type table<integer, _STORAGE_LIST___db_con>
	local pCopyMat = {}
	---@type table<integer, integer>
	local pbyMtrNum = {}
	local nTableCode = 0
	local A = 0
	local Lv = 0

	repeat
		if not pMakeItemFld then
			byErrCode = 12
			break
		end

		local byRaceSexCode = pPlayer.m_Param.m_dbChar.m_byRaceSexCode + 1

		if string.sub(pMakeItemFld.m_strCivil, byRaceSexCode, byRaceSexCode) ~= "1" then
			byErrCode = 11
			break
		end

		nTableCode = Sirin.mainThread.GetItemTableCode(pMakeItemFld.m_strCode)

		if nTableCode == 10 then
			byMasteryType = 2
		elseif nTableCode == 6 then
			byMasteryType = 0
		end

		byMasteryValue = pPlayer.m_pmMst:GetMasteryPerMast(5, byMasteryType)

		if pMakeItemFld.m_nMakeMastery > byMasteryValue then
			byErrCode = 13
			break
		end

		if GetItemKindCode(nTableCode) ~= 0 then
			byErrCode = 9
			break
		end

		if not pPlayer.m_bFreeSFByClass then
			local bCanUseTool = false

			for i = 0, 3 do
				local pClassFld = pPlayer.m_Param:m_ppHistoryEffect_get(i)

				if not pClassFld then
					break
				end

				if byMasteryType == 0 then
					bCanUseTool = pClassFld.m_bWMKToolUsable > 0 and true or false
				elseif byMasteryType == 1 then
					bCanUseTool = pClassFld.m_bDMKToolUnitUsable > 0 and true or false
				else
					bCanUseTool = pClassFld.m_bBMKToolUnitUsable > 0 and true or false
				end

				if bCanUseTool then
					break
				end
			end

			if not bCanUseTool then
				byErrCode = 7
				break
			end
		end

		local pCurClass = pPlayer.m_Param.m_pClassData

		if pCurClass.m_nGrade > 1 and pCurClass.m_nClass == 3 then
			local pBaseClass = pPlayer.m_Param:m_pClassHistory_get(0) or pCurClass

			if pCurClass.m_nClass == pBaseClass.m_nClass and pCurClass.m_dwIndex ~= 49 then
				bPureCraftsman = true
			end
		end

		if not SirinLua.HookMgr.callHook(HOOK_POS.filter, "canUseWithNoTool", false, pPlayer, byMasteryType) then
			local pMakeToolItemCon = pPlayer.m_Param.m_dbInven:GetPtrFromSerial(pipMakeTool.wItemSerial)

			if not pMakeToolItemCon then
				byErrCode = 1
				break
			end

			if pMakeToolItemCon.m_byTableCode ~= 11 then
				byErrCode = 2
				break
			end

			if pMakeToolItemCon.m_bLock then
				byErrCode = 10
				break
			end
		end

		if pPlayer.m_Param.m_dbInven:GetIndexEmptyCon() == 255 then
			byErrCode = 3
			break
		end

		if bPureCraftsman then
			local dwRand = math.random(0, 9999)
			local dwCumulRate = 0

			for i = 0, 29 do
				local pOutput = pMakeItemFld:m_listOutput_get(i)

				if pOutput.m_itmPdOutput == "-1" then
					break
				end

				dwCumulRate = dwCumulRate + pOutput.m_dwPdProp

				if dwRand < dwCumulRate then
					nTableCode = Sirin.mainThread.GetItemTableCode(pOutput.m_itmPdOutput)

					if nTableCode ~= -1 then
						pNewItemFld = g_Main:m_tblItemData_get(nTableCode):GetRecordByHash(pOutput.m_itmPdOutput, 2, 5)
					end

					break
				end
			end
		else
			pNewItemFld = g_Main:m_tblItemData_get(nTableCode):GetRecordByHash(pMakeItemFld.m_strCode, 2, 5)
		end

		if not pNewItemFld then
			byErrCode = 12
			break
		end

		if not pPlayer.m_bCheat_makeitem_no_use_matrial then
			local consumeList = {}

			for i = 0, 4 do
				local _itemConsume = {}
				local pMaterial = pMakeItemFld:m_listMaterial_get(i)
				_itemConsume.m_itmPdMat = pMaterial.m_itmPdMat
				_itemConsume.m_nPdMatNum = pMaterial.m_nPdMatNum
				table.insert(consumeList, _itemConsume)
			end

			for k, v in ipairs(materials) do
				local pMatCon = pPlayer.m_Param.m_dbInven:GetPtrFromSerial(v.wItemSerial)

				if not pMatCon then
					pPlayer:SendMsg_AdjustAmountInform(STORAGE_POS.inven, v.wItemSerial, 0)
					byErrCode = 4
					break
				end

				if pMatCon.m_bLock then
					byErrCode = 10
					break
				end

				if v.byNum > pMatCon.m_dwDur then
					pPlayer:SendMsg_AdjustAmountInform(STORAGE_POS.inven, v.wItemSerial, pMatCon.m_dwDur)
					byErrCode = 5
					break
				end

				if k > 1 then
					for i = 1, k - 1 do
						if v.wItemSerial == materials[i].wItemSerial then
							byErrCode = 5
							break
						end
					end

					if byErrCode ~= 0 then
						break
					end
				end

				local bValidMaterial = false
				local pMatFld = g_Main:m_tblItemData_get(pMatCon.m_byTableCode):GetRecord(pMatCon.m_wItemIndex)

				for i = 1, 5 do
					if consumeList[i].m_itmPdMat == pMatFld.m_strCode then
						consumeList[i].m_nPdMatNum = consumeList[i].m_nPdMatNum - v.byNum
						bValidMaterial = true
						break
					end
				end

				if not bValidMaterial then
					byErrCode = 8
					break
				end

				table.insert(materialConList, pMatCon)
			end

			if byErrCode ~= 0 then
				break
			end

			for k, v in ipairs(consumeList) do
				if v.m_itmPdMat ~= "-1" and v.m_nPdMatNum > 0 then
					byErrCode = 6
					break
				end
			end

			if byErrCode ~= 0 then
				break
			end
		end
	until true

	if byErrCode == 0 then
		if not pPlayer.m_bCheat_makeitem_no_use_matrial then
			for i = 1, byMaterialNum do
				table.insert(pCopyMat, Sirin.mainThread._STORAGE_LIST___db_con(materialConList[i]))
				table.insert(pbyMtrNum, materials[i].byNum)
			end
		end

		local bySuccRate = 0

		if nTableCode == TBL_CODE.bullet then
			bySuccRate = math.floor(byMasteryValue * 0.5 + 40)
		else
			A = math.floor(math.sqrt(150 * byMasteryValue + 1300) / 2 + 0.5 - 18)
			Lv = Sirin.mainThread.GetItemEquipLevel(nTableCode, pNewItemFld.m_dwIndex)
			bySuccRate = math.floor((50 - (Lv - A) * 11.25) / 2)
		end

		if pPlayer.m_bCheat_100SuccMake then
			bySuccRate = 100
		elseif bySuccRate > 95 then
			bySuccRate = 95
		elseif bySuccRate < 0 then
			bySuccRate = 0
		end

		if bySuccRate < pPlayer.m_MakeRandTable:GetRand() then
			byErrCode = 100
		end

		if not pPlayer.m_bCheat_makeitem_no_use_matrial then
			for k, v in ipairs(materialConList) do
				pPlayer:Emb_AlterDurPoint(STORAGE_POS.inven, v.m_byStorageIndex, -materials[k].byNum, false, false)
			end
		end

		local pItem = Sirin.mainThread._STORAGE_LIST___db_con()

		if byErrCode == 0 then
			pItem.m_byTableCode = nTableCode
			pItem.m_wItemIndex = pNewItemFld.m_dwIndex
			pItem.m_dwDur = Sirin.mainThread.GetItemDurPoint(nTableCode, pNewItemFld.m_dwIndex)
			local bySocketNum = Sirin.mainThread.GetDefItemUpgSocketNum(nTableCode, pNewItemFld.m_dwIndex)

			if bySocketNum > 0 then
				bySocketNum = math.random(1, bySocketNum)
			end

			pItem.m_dwLv = Sirin.mainThread.GetBitAfterSetLimSocket(bySocketNum)
			pItem.m_wSerial = pPlayer.m_Param:GetNewItemSerial()

			if not pPlayer:Emb_AddStorage(STORAGE_POS.inven, pItem, false, true) then
				byErrCode = 255
			else
				pPlayer:SendMsg_FanfareItem(0, pItem, nil)
				pPlayer:SendMsg_InsertItemInform(STORAGE_POS.inven, pItem)
			end

			if nTableCode == 10 then
				pPlayer:Emb_AlterStat(5, byMasteryType, 1, 0, "Lua. sirinPlayerMgr.pc_MakeItem---1", true)
			elseif A - Lv <= 4 then
				pPlayer:Emb_AlterStat(5, byMasteryType, 1, 0, "Lua. sirinPlayerMgr.pc_MakeItem---0", true)
			end

			pPlayer:Emb_CheckActForQuest(5, pNewItemFld.m_strCode, 1, false)
		end

		if not pPlayer.m_bCheat_makeitem_no_use_matrial then
			Sirin.mainThread.CMgrAvatorItemHistory.Instance():make_item(pPlayer, materialConList, pbyMtrNum, byErrCode, true, pItem)
		else
			Sirin.mainThread.CMgrAvatorItemHistory.Instance():cheat_make_item_no_material(pPlayer, byErrCode, pItem)
		end
	end

	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	buf:PushUInt8(byErrCode)
	buf:SendBuffer(pPlayer, 7, 16)
end

---@type table<integer, fun(pPlayer: CPlayer, fVal: number, bAdd: boolean, nDiffCnt?: integer)>
local apply_case_have = {
	[15] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(9, fVal, bAdd)
	end,
	[16] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(10, fVal, bAdd)
	end,
	[17] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(11, fVal, bAdd)
	end,
	[18] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(0, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(1, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(2, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(3, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(4, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(29, fVal, bAdd)
	end,
	[19] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(0, fVal, bAdd)
	end,
	[20] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(2, fVal, bAdd)
	end,
	[21] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(1, fVal, bAdd)
	end,
	[22] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(3, fVal, bAdd)
	end,
	[23] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(4, fVal, bAdd)
	end,
	[24] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(6, fVal, bAdd)
	end,
	[25] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(12, fVal, bAdd)
	end,
	[26] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(13, fVal, bAdd)
	end,
	[27] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(40, fVal, bAdd)
	end,
	[29] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(41, fVal, bAdd)
	end,
	[30] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(42, fVal, bAdd)
	end,
	[31] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(43, fVal, bAdd)
	end,
	[32] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(44, fVal, bAdd)
	end,
	[33] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(57, fVal, bAdd)
	end,
	[34] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(58, fVal, bAdd)
	end,
	[35] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(59, fVal, bAdd)
	end,
	[36] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(60, fVal, bAdd)
	end,
	[37] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(61, fVal, bAdd)
	end,
	[38] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(0, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(1, fVal, bAdd)
	end,
	[39] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(6, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(7, fVal, bAdd)
	end,
	[40] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(23, 1.0, bAdd)
	end,
	[41] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(20, fVal, bAdd)
	end,
	[43] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(0, fVal, bAdd)
	end,
	[44] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(1, fVal, bAdd)
	end,
	[45] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(31, fVal, bAdd)
	end,
	[46] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(30, fVal, bAdd)
	end,
	[47] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(14, fVal, bAdd)
	end,
	[48] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(40, fVal, bAdd)
	end,
	[49] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(3, fVal, bAdd)
	end,
	[50] = function(pPlayer, fVal, bAdd)
		pPlayer:HideNameEffect(bAdd)
	end,
	[56] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_State(8, bAdd)
	end,
	[57] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(29, fVal, bAdd)
	end,
	[59] = function(pPlayer, fVal, bAdd)
		pPlayer:SetMstPt(0, fVal, bAdd, 0)
	end,
	[60] = function(pPlayer, fVal, bAdd)
		pPlayer:SetMstPt(0, fVal, bAdd, 1)
	end,
	[61] = function(pPlayer, fVal, bAdd)
		pPlayer:SetMstPt(4, fVal, bAdd, 0)
	end,
	[62] = function(pPlayer, fVal, bAdd)
		pPlayer:SetMstPt(1, fVal, bAdd, 0)
	end,
	[63] = function(pPlayer, fVal, bAdd)
		pPlayer:SetMstPt(2, fVal, bAdd, 0)
	end,
	[64] = function(pPlayer, fVal, bAdd)
		pPlayer:SetMstPt(6, fVal, bAdd, 0)
	end,
	[65] = function(pPlayer, fVal, bAdd)
		pPlayer:SetMstPt(6, fVal, bAdd, 0)
	end,
	[76] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(22, fVal, bAdd)
	end,
	[77] = function(pPlayer, fVal, bAdd, nDiffCnt)
		if nDiffCnt > 0 and bAdd then
			pPlayer:DecHalfSFContDam(nDiffCnt * 0.01)
		end
	end,
	[78] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Plus(28, fVal, bAdd)
	end,
	[79] = function(pPlayer, fVal, bAdd, nDiffCnt)
		if nDiffCnt ~= 1 and fVal >= 1.0 then
			pPlayer:SetEquipJadeEffect(79, fVal, bAdd)
		end
	end,
	[80] = function(pPlayer, fVal, bAdd, nDiffCnt)
		if nDiffCnt ~= 1 and fVal >= 1.0 then
			pPlayer:SetEquipJadeEffect(80, fVal, bAdd)
		end
	end,
}

if SERVER_AOP then
	apply_case_have[88] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(62, fVal, bAdd)
	end
	apply_case_have[89] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(63, fVal, bAdd)
	end
	apply_case_have[90] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(64, fVal, bAdd)
	end
	apply_case_have[91] = function(pPlayer, fVal, bAdd)
		pPlayer.m_EP:SetEff_Rate(65, fVal, bAdd)
	end
end

---@param pPlayer CPlayer
---@param nEffCode integer
---@param fVal number
---@param bAdd boolean
---@param nDiffCnt integer
function sirinPlayerMgr.apply_have_item_std_effect(pPlayer, nEffCode, fVal, bAdd, nDiffCnt)
	-- Implementation of this function is optional
	local handler = apply_case_have[nEffCode]

	if handler then
		handler(pPlayer, fVal, bAdd, nDiffCnt)
	end
end

---@type table<integer, fun(pPlayer: CPlayer, fVal: number, bEquip: boolean)>
local apply_case_std = {
	[1] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(11, fVal, bEquip)
	end,
	[2] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(7, fVal, bEquip)
	end,
	[3] = function(pPlayer, fVal, bEquip)
		for nParamIndex = 0, 1 do
			pPlayer.m_EP:SetEff_Plus(nParamIndex, fVal, bEquip)
		end

		pPlayer.m_EP:SetEff_Plus(2, fVal, bEquip)
	end,
	[4] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(3, fVal, bEquip)
	end,
	[5] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(9, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(10, fVal, bEquip)
	end,
	[6] = function(pPlayer, fVal, bEquip)
		for nParamIndex = 0, 1 do
			pPlayer.m_EP:SetEff_Rate(nParamIndex, fVal, bEquip)
			pPlayer.m_EP:SetEff_Rate(nParamIndex + 2, fVal, bEquip)
		end

		pPlayer.m_EP:SetEff_Rate(4, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(29, fVal, bEquip)
	end,
	[7] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(6, fVal, bEquip)
	end,
	[8] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(19, fVal, bEquip)
	end,
	[9] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(21, 1.0, bEquip)
	end,
	[10] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(22, 1.0, bEquip)
	end,
	[11] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(23, 1.0, bEquip)
	end,
	[12] = function(pPlayer, fVal, bEquip)
		if not pPlayer.m_bInGuildBattle or not pPlayer.m_bTakeGravityStone then
			pPlayer.m_EP:SetEff_Plus(20, fVal, bEquip)
		end
	end,
	[13] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(24, 1.0, bEquip)
	end,
	[14] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(25, fVal, bEquip)
	end,
	[15] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(4, fVal, bEquip)
	end,
	[16] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(10, fVal, bEquip)
	end,
	[17] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(12, fVal, bEquip)
	end,
	[18] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(13, fVal, bEquip)
	end,
	[19] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(14, fVal, bEquip)
	end,
	[20] = function(pPlayer, fVal, bEquip)
		for nParamIndex = 0, 1 do
			pPlayer.m_EP:SetEff_Plus(nParamIndex + 4, fVal, bEquip)
			pPlayer.m_EP:SetEff_Plus(nParamIndex + 6, fVal, bEquip)
		end

		pPlayer.m_EP:SetEff_Plus(36, fVal, bEquip)
	end,
	[21] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(6, fVal, bEquip)
	end,
	[22] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(8, fVal, bEquip)
	end,
	[23] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(14, fVal, bEquip)
	end,
	[24] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(3, fVal, bEquip)
	end,
	[25] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(11, fVal, bEquip)
	end,
	[26] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(8, fVal, bEquip)
	end,
	[27] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(37, fVal, bEquip)
	end,
	[28] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(29, fVal, bEquip)
	end,
	[29] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(15, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(16, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(17, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(18, fVal, bEquip)
	end,
	[30] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(9, fVal, bEquip)
	end,
	[31] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(8, fVal, bEquip)
	end,
	[32] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(28, fVal, bEquip)
	end,
	[33] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(10, fVal, bEquip)
	end,
	[34] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(12, fVal, bEquip)
	end,
	[35] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(13, fVal, bEquip)
	end,
	[36] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(38, fVal, bEquip)
	end,
}

---@param pPlayer CPlayer
---@param nEffCode integer
---@param fVal number
---@param bEquip boolean
function sirinPlayerMgr.apply_normal_item_std_effect(pPlayer, nEffCode, fVal, bEquip)
	-- Implementation of this function is optional
	local handler = apply_case_std[nEffCode]

	if handler then
		handler(pPlayer, fVal, bEquip)
	end
end

---@type table<integer, fun(pPlayer: CPlayer, fVal: number, bEquip: boolean, pItem?: _STORAGE_LIST___db_con)>
local apply_case_talik = {
	[0] = function(pPlayer, fVal, bEquip)
		for nParamIndex = 0, 1 do
			pPlayer.m_EP:SetEff_Rate(nParamIndex, fVal, bEquip)
			pPlayer.m_EP:SetEff_Rate(nParamIndex + 2, fVal, bEquip)
		end

		pPlayer.m_EP:SetEff_Rate(4, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(29, fVal, bEquip)
	end,
	[1] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(12, fVal, bEquip)
	end,
	[2] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(28, fVal, bEquip)
	end,
	[3] = function(pPlayer, fVal, bEquip, pItem)
		if pItem.m_byTableCode == 7 then
			pPlayer.m_EP:SetEff_Plus(37, fVal, bEquip)
		else
			pPlayer.m_EP:SetEff_Plus(14, fVal, bEquip)
		end
	end,
	[4] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(5, fVal, bEquip)

		-- required by radius fix
		pPlayer.m_EP:SetEff_Plus(7, fVal, bEquip)
	end,
	[5] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Rate(6, fVal, bEquip)
	end,
	[6] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(38, fVal, bEquip)
	end,
	[7] = function(pPlayer, fVal, bEquip, pItem)
		if pItem.m_byTableCode ~= 6 then
			pPlayer.m_EP:SetEff_Plus(15, fVal, bEquip)
		end
	end,
	[8] = function(pPlayer, fVal, bEquip, pItem)
		if pItem.m_byTableCode ~= 6 then
			pPlayer.m_EP:SetEff_Plus(16, fVal, bEquip)
		end
	end,
	[9] = function(pPlayer, fVal, bEquip, pItem)
		if pItem.m_byTableCode ~= 6 then
			pPlayer.m_EP:SetEff_Plus(17, fVal, bEquip)
		end
	end,
	[10] = function(pPlayer, fVal, bEquip, pItem)
		if pItem.m_byTableCode ~= 6 then
			pPlayer.m_EP:SetEff_Plus(18, fVal, bEquip)
		end
	end,
	[11] = function(pPlayer, fVal, bEquip)
		for nParamIndex = 0, 1 do
			pPlayer.m_EP:SetEff_Plus(nParamIndex, fVal, bEquip)
		end

		pPlayer.m_EP:SetEff_Plus(2, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(31, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(30, fVal, bEquip)
	end,
	[12] = function(pPlayer, fVal, bEquip)
		pPlayer.m_EP:SetEff_Plus(3, fVal / 2.0, bEquip)
	end,
}

---@param pPlayer CPlayer
---@param pItem _STORAGE_LIST___db_con
---@param bEquip boolean
function sirinPlayerMgr.apply_case_equip_upgrade_effect(pPlayer, pItem, bEquip)
	-- Implementation of this function is optional
	local dwLvBit = pItem.m_dwLv
	local byUpgLv = GetItemUpgedLv(dwLvBit)
	local fApplyEff = 0

	if byUpgLv == 0 or Sirin.mainThread.GetDefItemUpgSocketNum(pItem.m_byTableCode, pItem.m_wItemIndex) == 0 then
		if pItem.m_byTableCode == TBL_CODE.weapon then
			if Sirin.mainThread.GetItemGrade(pItem.m_byTableCode, pItem.m_wItemIndex) < 3 then
				local byEffLv = math.floor(pPlayer.m_EP:GetEff_Have(79)) - 1

				if byEffLv > 4 then
					byEffLv = 4
				end

				if byEffLv >= 0 then
					local pUpgFld = baseToItemUpgrade(g_Main.m_tblItemUpgrade.m_tblItemUpgrade:GetRecord(0))

					if byEffLv == 0 then
						fApplyEff = pUpgFld.m_fUp1
					elseif byEffLv == 1 then
						fApplyEff = pUpgFld.m_fUp2
					elseif byEffLv == 2 then
						fApplyEff = pUpgFld.m_fUp3
					elseif byEffLv == 3 then
						fApplyEff = pUpgFld.m_fUp4
					elseif byEffLv == 4 then
						fApplyEff = pUpgFld.m_fUp5
					elseif byEffLv == 5 then
						fApplyEff = pUpgFld.m_fUp6
					elseif byEffLv == 6 then
						fApplyEff = pUpgFld.m_fUp7
					end

					for nParamIndex = 0, 1 do
						pPlayer.m_EP:SetEff_Rate(nParamIndex, fApplyEff, bEquip)
						pPlayer.m_EP:SetEff_Rate(nParamIndex + 2, fApplyEff, bEquip)
					end

					pPlayer.m_EP:SetEff_Rate(4, fApplyEff, bEquip)
					pPlayer.m_EP:SetEff_Rate(29, fApplyEff, bEquip)
				end
			end
		else
			local byEffLv = math.floor(pPlayer.m_EP:GetEff_Have(80)) - 1

			if byEffLv > 3 then
				byEffLv = 3
			end

			if byEffLv >= 0 then
				local pUpgFld = baseToItemUpgrade(g_Main.m_tblItemUpgrade.m_tblItemUpgrade:GetRecord(5))

				if byEffLv == 0 then
					fApplyEff = pUpgFld.m_fUp1
				elseif byEffLv == 1 then
					fApplyEff = pUpgFld.m_fUp2
				elseif byEffLv == 2 then
					fApplyEff = pUpgFld.m_fUp3
				elseif byEffLv == 3 then
					fApplyEff = pUpgFld.m_fUp4
				elseif byEffLv == 4 then
					fApplyEff = pUpgFld.m_fUp5
				elseif byEffLv == 5 then
					fApplyEff = pUpgFld.m_fUp6
				elseif byEffLv == 6 then
					fApplyEff = pUpgFld.m_fUp7
				end

				pPlayer.m_EP:SetEff_Rate(6, fApplyEff, bEquip)

				if bEquip then
					pPlayer.m_fTalik_DefencePoint = pPlayer.m_fTalik_DefencePoint + fApplyEff
				else
					pPlayer.m_fTalik_DefencePoint = pPlayer.m_fTalik_DefencePoint - fApplyEff
				end
			end
		end
	else
		for i = 1, byUpgLv do
			repeat
				local talik_index = GetTalikFromSocket(dwLvBit, i - 1)

				if talik_index == 15 then
					break
				end

				local talik_num = 0

				for j = i, byUpgLv do
					if GetTalikFromSocket(dwLvBit, j - 1) == talik_index then
						talik_num = talik_num + 1
						dwLvBit = dwLvBit | (0xF << (j - 1) * 4)
					end
				end

				local pUpgFld = baseToItemUpgrade(g_Main.m_tblItemUpgrade.m_tblItemUpgrade:GetRecord(talik_index))

				if not pUpgFld then
					break
				end

				if talik_num > 7 then
					break
				end

				local byEffLv = talik_num - 1

				if talik_index == 0 then
					if pItem.m_byTableCode == TBL_CODE.weapon and Sirin.mainThread.GetItemGrade(pItem.m_byTableCode, pItem.m_wItemIndex) < 3 then
						local byCharmEffLv = math.floor(pPlayer.m_EP:GetEff_Have(79)) - 1

						if byCharmEffLv > 4 then
							byCharmEffLv = 4
						end

						if byCharmEffLv > byEffLv then
							byEffLv = byCharmEffLv
						end
					end
				elseif talik_index == 5 then
					local byCharmEffLv = math.floor(pPlayer.m_EP:GetEff_Have(80)) - 1

					if byCharmEffLv > 3 then
						byCharmEffLv = 3
					end
					if byCharmEffLv > byEffLv then
						byEffLv = byCharmEffLv
					end
				end

				if byEffLv == 0 then
					fApplyEff = pUpgFld.m_fUp1
				elseif byEffLv == 1 then
					fApplyEff = pUpgFld.m_fUp2
				elseif byEffLv == 2 then
					fApplyEff = pUpgFld.m_fUp3
				elseif byEffLv == 3 then
					fApplyEff = pUpgFld.m_fUp4
				elseif byEffLv == 4 then
					fApplyEff = pUpgFld.m_fUp5
				elseif byEffLv == 5 then
					fApplyEff = pUpgFld.m_fUp6
				elseif byEffLv == 6 then
					fApplyEff = pUpgFld.m_fUp7
				end

				local handler = apply_case_talik[talik_index]

				if handler then
					handler(pPlayer, fApplyEff, bEquip, pItem)
				end

				if talik_index == 5 then
					if bEquip then
						pPlayer.m_fTalik_DefencePoint = pPlayer.m_fTalik_DefencePoint + fApplyEff
					else
						pPlayer.m_fTalik_DefencePoint = pPlayer.m_fTalik_DefencePoint - fApplyEff
					end
				elseif talik_index == 12 then
					if bEquip then
						pPlayer.m_fTalik_AvoidPoint = pPlayer.m_fTalik_AvoidPoint + (fApplyEff / 2)
					else
						pPlayer.m_fTalik_AvoidPoint = pPlayer.m_fTalik_AvoidPoint - (fApplyEff / 2)
					end
				end
			until true
		end
	end
end

---@param pPlayer CPlayer
---@param byItemTableCode integer
---@param dwItemIndex integer
---@param nFitNum? integer
---@return integer wSerial
function sirinPlayerMgr.GetIncompleteStackSerial(pPlayer, byItemTableCode, dwItemIndex, nFitNum)
	local wSerial = 0xFFFF

	if Sirin.mainThread.IsOverLapItem(byItemTableCode) then
		nFitNum = nFitNum or 1
		local nStackSize = Sirin.mainThread.modStackExt.GetStackSize()
		---@type table<integer, _STORAGE_LIST___db_con>
		local Inven = {}

		for i = 0, pPlayer.m_Param.m_dbInven.m_nUsedNum - 1 do
			local pCon = pPlayer.m_Param.m_dbInven:m_List_get(i)
			if pCon.m_byLoad == 1 and not pCon.m_bLock and pCon.m_byTableCode == byItemTableCode and pCon.m_wItemIndex == dwItemIndex and pCon.m_dwDur + nFitNum <= nStackSize then
				table.insert(Inven, pCon)
			end
		end

		if #Inven > 0 then
			table.sort(Inven, function(a, b) return a.m_byClientIndex < b.m_byClientIndex end)
			wSerial = Inven[1].m_wSerial
		end
	end

	return wSerial
end

---@param pPlayer CPlayer
---@param dwSound integer
function sirinPlayerMgr.playSound(pPlayer, dwSound)
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	buf:PushUInt32(dwSound)
	buf:SendBuffer(pPlayer, 101, 13)
end

---@param pPlayer CPlayer
---@param nDstLevel integer
---@return boolean bRet
---@return boolean bGetAttExp
function sirinPlayerMgr.isPassExpLimitLvDiff(pPlayer, nDstLevel)
	local nLevelDiff = pPlayer:GetLevel() - nDstLevel
	local nBonus = math.floor(pPlayer.m_EP:GetEff_Have(_EFF_HAVE.Mob_Lv_Lmt_Extend))

	if nLevelDiff >= 0 and nLevelDiff < nBonus + 3 then -- monster smaller than 3 levels does not give exp
		return false, false
	elseif -10 - nBonus > nLevelDiff then -- monsters greater than 10 levels does not give exp
		if SERVER_2232 then
			if pPlayer.m_pPartyMgr:IsPartyMode() then
				return true, false
			end
		end

		return false, false
	end

	return true, true
end

---@param nPartyMemberLevel integer
---@param nMaxLevel integer
---@param n2ndLevel integer
---@return number
function sirinPlayerMgr.getPartyExpDistributionRate(nPartyMemberLevel, nMaxLevel, n2ndLevel)
	if nMaxLevel > 0  and n2ndLevel > 0 then
		local fRate = 0.05

		if nPartyMemberLevel >= nMaxLevel then
			fRate = fRate * (nPartyMemberLevel - n2ndLevel)
		else
			fRate = fRate * (nPartyMemberLevel - nMaxLevel)
		end

		return fRate
	end

	return 0
end

---@param pPlayer CPlayer
---@param pDst CCharacter
---@param nDam integer
---@param kPartyExpNotify CPartyModeKillMonsterExpNotify|sirin_CPartyModeKillMonsterExpNotify
function sirinPlayerMgr.calcExp(pPlayer, pDst, nDam, kPartyExpNotify)
	if not (pDst.m_ObjID.m_byID == ID_CHAR.monster and nDam > 0 and not pPlayer:IsInTown()) then
		return
	end

	local nDstLv = pDst:GetLevel()
	local bIsPass, bGetAttExp = sirinPlayerMgr.isPassExpLimitLvDiff(pPlayer, nDstLv)
	local pMonFld = Sirin.mainThread.baseToMonsterCharacter(pDst.m_pRecordSet)
	local nHPLeft = pDst:GetHP() - nDam

	if pMonFld.m_bMonsterCondition then -- CMonster::IsBossMonster()
		bGetAttExp = false
	end

	if bIsPass and bGetAttExp then
		local nHPConsumed = nDam

		if nHPLeft < 0 then
			nHPConsumed = pDst:GetHP()
		end

		local fExp = pMonFld.m_fExt * 0.7 * nHPConsumed / pMonFld.m_fMaxHP

		if pPlayer:IsRidingUnit() then
			if SERVER_AOP then -- UNIT_HIT_EXP exists in AOP only
				pPlayer:AlterExp(fExp * Sirin.mainThread.UNIT_HIT_EXP, false, false, false)
			end

			pPlayer:Emb_AlterStat(MTY_CODE.special, 0, math.floor(fExp / 180 + nDstLv), 0, "sirinPlayerMgr.calcExp() -- 0", true)
		else
			pPlayer:AlterExp(fExp, false, false, false)
		end
	end

	if nHPLeft < 0 then
		nHPLeft = 0
	end

	if nHPLeft == 0 then
		local fExp = pMonFld.m_fExt * 0.3
		local pMon = Sirin.mainThread.objectToMonster(pDst)

		if (pMon.m_nCommonStateChunk >> 2) & 7 == 4 then -- CMonster::GetEmotionState()
			fExp = pMonFld.m_fExt * 0.5
		end

		if pPlayer.m_pPartyMgr:IsPartyMode() then
			local pPartyList = pPlayer:_GetPartyMemberInCircle(true)

			if #pPartyList > 0 then
				fExp = fExp * ExpDivUnderParty_Kill[#pPartyList]
			end

			local nMaxLevel = 0
			local n2ndLevel = 0
			local nTotalLevel = 0

			for _,v in pairs(pPartyList) do
				local nLv = v:GetLevel()
				nTotalLevel = nTotalLevel + nLv

				if nLv <= nMaxLevel then
					if nLv > n2ndLevel then
						n2ndLevel = nLv
					end
				else
					n2ndLevel = nMaxLevel
					nMaxLevel = nLv
				end
			end

			kPartyExpNotify.m_bKillMonster = true -- CPartyModeKillMonsterExpNotify::SetKillMonsterFlag()

			for _,v in pairs(pPartyList) do
				local nPartyLevel = v:GetLevel()
				local fPartyExp =  nPartyLevel / nTotalLevel * fExp
				fPartyExp = fPartyExp + (fPartyExp * sirinPlayerMgr.getPartyExpDistributionRate(nPartyLevel, nMaxLevel, n2ndLevel))

				if fPartyExp > 1.0 then
					if bIsPass then
						if v:IsRidingUnit() then
							if SERVER_AOP then
								v:AlterExp(fPartyExp, false, false, false)
								kPartyExpNotify:Add(v, fPartyExp)
							end

							v:Emb_AlterStat(MTY_CODE.special, 0, math.floor(fPartyExp / 180 + nDstLv), 0, "sirinPlayerMgr.calcExp() -- 1", true)
						else
							v:AlterExp(fPartyExp, false, false, false)
							kPartyExpNotify:Add(v, fPartyExp)
						end
					end

					if SERVER_AOP and v.m_pRecalledAnimusChar and math.abs(v.m_pRecalledAnimusChar:GetLevel() - nDstLv) <= 10 then
						v.m_pRecalledAnimusChar:AlterExp(math.floor(fPartyExp / 5000 + nDstLv))
					end
				end
			end
		else
			if pPlayer:IsRidingUnit() then
				if SERVER_AOP then
					pPlayer:AlterExp(fExp, false, false, false)
				end

				pPlayer:Emb_AlterStat(MTY_CODE.special, 0, math.floor(fExp / 180 + nDstLv), 0, "sirinPlayerMgr.calcExp() -- 2", true)
			else
				pPlayer:AlterExp(fExp, false, false, false)
			end

			if SERVER_AOP and pPlayer.m_pRecalledAnimusChar and math.abs(pPlayer.m_pRecalledAnimusChar:GetLevel() - nDstLv) <= 10 then
				pPlayer.m_pRecalledAnimusChar:AlterExp(math.floor(fExp / 5000 + nDstLv))
			end
		end
	end
end

---@param pPlayer CPlayer
---@return boolean
function sirinPlayerMgr.isHaveEmptyTower(pPlayer)
	for i = 0, 5 do
		if not pPlayer.m_pmTwr:m_List_get(i).m_pTowerItem then
			return true
		end
	end

	return false
end

---@param pPlayer CPlayer
---@param byTableCode integer
---@param wItemIndex integer
---@param byStorageCode STORAGE_POS
---@return _STORAGE_LIST___db_con|nil
function sirinPlayerMgr.getFirstNonEmptyStack(pPlayer, byTableCode, wItemIndex, byStorageCode)
	local byStorageCode = byStorageCode or STORAGE_POS.inven
	local storage = pPlayer.m_Param:m_pStoragePtr_get(byStorageCode)
	local list = storage:GetUseList(true)
	local stackSize = Sirin.mainThread.modStackExt.GetStackSize()

	for _,v in ipairs(list) do
		if v.m_byTableCode == byTableCode and v.m_wItemIndex == wItemIndex and v.m_dwDur < stackSize then
			return v
		end
	end

	return nil
end

---@param pMst _MASTERY_PARAM
---@param byClass integer
---@return number
function sirinPlayerMgr.GetAveForceMasteryPerClass(pMst, byClass)
	local mty = 0

	for i = 0, 3 do
		mty = mty + pMst:m_mtyForce_get(4 * byClass + i)
	end

	return mty / 4
end

---@param pMst _MASTERY_PARAM
---@param byClass integer
---@return number
function sirinPlayerMgr.GetAveSkillMasteryPerClass(pMst, byClass)
	local mty = 0

	if byClass == 0 then
		for i = 0, 3 do
			mty = mty + pMst:m_mtySkill_get(4 * byClass + i)
		end

		mty = mty / 4
	elseif byClass == 1 then
		for i = 4, 6 do
			mty = mty + pMst:m_mtySkill_get(4 * byClass + i)
		end

		mty = mty / 3
	end

	return mty
end

---@param pPlayer CPlayer
---@return integer
function sirinPlayerMgr.calcMaxHP(pPlayer)
	return math.floor(math.sqrt((pPlayer:GetLevel() ^ 2) * (pPlayer.m_pmMst:GetMasteryPerMast(1, 0) + pPlayer:m_nAddPointByClass_get(0))) * 20 + 80)
end

---@param pPlayer CPlayer
---@return integer
function sirinPlayerMgr.calcMaxFP(pPlayer)
	local tmp = 0
	local byRace = pPlayer.m_Param:GetRaceCode()

	if byRace == 0 then
		tmp = sirinPlayerMgr.GetAveForceMasteryPerClass(pPlayer.m_pmMst, 1) * 0.4				-- Holy force average mastery
		tmp = tmp + sirinPlayerMgr.GetAveForceMasteryPerClass(pPlayer.m_pmMst, 2) * 0.075		-- Fire force average mastery
		tmp = tmp + sirinPlayerMgr.GetAveForceMasteryPerClass(pPlayer.m_pmMst, 3) * 0.1125		-- Water force average mastery
		tmp = tmp + sirinPlayerMgr.GetAveForceMasteryPerClass(pPlayer.m_pmMst, 4) * 0.1125		-- Terra force average mastery
		tmp = tmp + sirinPlayerMgr.GetAveForceMasteryPerClass(pPlayer.m_pmMst, 5) * 0.075		-- Wind force average mastery
		tmp = tmp + sirinPlayerMgr.GetAveSkillMasteryPerClass(pPlayer.m_pmMst, 0) * 0.1125		-- Melee skills average mastery
		tmp = tmp + sirinPlayerMgr.GetAveSkillMasteryPerClass(pPlayer.m_pmMst, 1) * 0.1125		-- Range skills average mastery
	elseif byRace == 1 then
		tmp = sirinPlayerMgr.GetAveForceMasteryPerClass(pPlayer.m_pmMst, 0) * 0.4				-- Dark force average mastery
		tmp = tmp + sirinPlayerMgr.GetAveForceMasteryPerClass(pPlayer.m_pmMst, 2) * 0.075
		tmp = tmp + sirinPlayerMgr.GetAveForceMasteryPerClass(pPlayer.m_pmMst, 3) * 0.1125
		tmp = tmp + sirinPlayerMgr.GetAveForceMasteryPerClass(pPlayer.m_pmMst, 4) * 0.1125
		tmp = tmp + sirinPlayerMgr.GetAveForceMasteryPerClass(pPlayer.m_pmMst, 5) * 0.075
		tmp = tmp + sirinPlayerMgr.GetAveSkillMasteryPerClass(pPlayer.m_pmMst, 0) * 0.1125
		tmp = tmp + sirinPlayerMgr.GetAveSkillMasteryPerClass(pPlayer.m_pmMst, 1) * 0.1125
	elseif byRace == 2 then
		tmp = sirinPlayerMgr.GetAveSkillMasteryPerClass(pPlayer.m_pmMst, 0) * 0.5
		tmp = tmp + sirinPlayerMgr.GetAveSkillMasteryPerClass(pPlayer.m_pmMst, 1) * 0.5
	end

	tmp = tmp + pPlayer:m_nAddPointByClass_get(1) -- Class bonus

	return math.floor(math.sqrt((tmp ^ 2) * pPlayer:GetLevel()) * 5 + 40)
end

---@param pPlayer CPlayer
---@return integer
function sirinPlayerMgr.calcMaxSP(pPlayer)
	local tmp = pPlayer.m_pmMst:GetMasteryPerMast(0, 0) * 0.2	-- PT Melee
	tmp = tmp + pPlayer.m_pmMst:GetMasteryPerMast(0, 1) * 0.8	-- PT Range
	tmp = tmp + pPlayer:m_nAddPointByClass_get(2)				-- Class bonus

	return math.floor(math.sqrt((tmp ^ 2) * pPlayer:GetLevel()) * 2.5 + 160)
end

---@param pPlayer CPlayer
---@param nIndex integer
---@return integer
function sirinPlayerMgr.GetGauge(pPlayer, nIndex)
	if nIndex == 1 then
		return pPlayer:GetHP()
	elseif nIndex == 2 then
		return pPlayer:GetFP()
	elseif nIndex == 3 then
		return pPlayer:GetSP()
	end

	return 0
end

---@param pPlayer CPlayer
---@param nIndex integer
---@param nValue integer
---@param bOver boolean
function sirinPlayerMgr.SetGauge(pPlayer, nIndex, nValue, bOver)
	if nIndex == 1 then
		pPlayer:SetHP(nValue, bOver)
	elseif nIndex == 2 then
		pPlayer:SetFP(nValue, bOver)
	elseif nIndex == 3 then
		pPlayer:SetSP(nValue, bOver)
	end
end

---@param pPlayer CPlayer
---@param consumeList table<integer, sirin_consume_item>
function sirinPlayerMgr.DeleteUseConsumeItem(pPlayer, consumeList)
	for k,v in ipairs(consumeList) do
		if v.dwDur > 0 then
			if v.bOverlap then
				local durLeft = pPlayer:Emb_AlterDurPoint(v.pCon.m_pInList.m_nListCode, v.pCon.m_byStorageIndex, -(v.dwDur), false, false)

				if durLeft > 0 then
					pPlayer:SendMsg_AdjustAmountInform(v.pCon.m_pInList.m_nListCode, v.pCon.m_wSerial, durLeft)
				else
					local pFld = g_Main:m_tblItemData_get(v.pCon.m_byTableCode):GetRecord(v.pCon.m_wItemIndex)

					Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("CONSUM: %s [%d] [%s]", pFld.m_strCode, v.pCon.m_lnUID, os.date(_, os.time())), false, false)
				end
			else
				pPlayer:Emb_DelStorage(v.pCon.m_pInList.m_nListCode, v.pCon.m_byStorageIndex, false, true, "sirinPlayerMgr.DeleteUseConsumeItem()")

				local pFld = g_Main:m_tblItemData_get(v.pCon.m_byTableCode):GetRecord(v.pCon.m_wItemIndex)

				Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("CONSUM: %s [%d] [%s]", pFld.m_strCode, v.pCon.m_lnUID, os.date(_, os.time())), false, false)
			end
		end
	end
end

---@param pPlayer CPlayer
---@return number
function sirinPlayerMgr.CalcDPRate(pPlayer)
	local fDPRate = 2 * pPlayer.m_Param.m_dbChar.m_dwDP / pPlayer.m_nMaxDP - 0.4

	if fDPRate < 0 then
		return 0
	end

	if fDPRate > 1 then
		fDPRate = 1
	end

	return fDPRate
end

---For other objects (monster, animus, trap, tower, etc) GetAvoidRate() returns 0
---@param pPlayer CPlayer
---@return integer
function sirinPlayerMgr.GetAvoidRate(pPlayer)
	if pPlayer.m_fTalik_AvoidPoint > 0 then
		return math.floor(pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.GE_Avd) - pPlayer.m_fTalik_AvoidPoint * (1 - sirinPlayerMgr.CalcDPRate(pPlayer)))
	else
		return math.floor(pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.GE_Avd))
	end
end

---@param pPlayer CPlayer
---@param byStorageCode integer
---@param bySlotIndex integer
---@return integer
function sirinPlayerMgr.GetEffectEquipCode(pPlayer, byStorageCode, bySlotIndex)
	if byStorageCode == STORAGE_POS.equip then
		return pPlayer:m_byEffectEquipCode_get(bySlotIndex)
	else
		return pPlayer:m_byEffectEquipCode_get(bySlotIndex + 8)
	end
end

---@param pPlayer CPlayer
---@param nPart integer
---@return number
function sirinPlayerMgr.GetDefGap(pPlayer, nPart)
	if pPlayer:IsRidingUnit() then
		return baseToUnitFrame(g_Main.m_tblUnitFrame:GetRecord(pPlayer.m_pUsingUnit.byFrame)).m_fDefGap
	else
		if nPart >= 8 or nPart < 0 then
			return 0.5
		else
			local wItemIndex = pPlayer.m_Param.m_dbChar:m_byDftPart_get(nPart)
			local pCon = pPlayer.m_Param.m_dbEquip:m_List_get(nPart)

			if pCon.m_byLoad == 1 and sirinPlayerMgr.GetEffectEquipCode(pPlayer, STORAGE_POS.equip, nPart) == 1 then
				wItemIndex = pCon.m_wItemIndex
			end

			local pFld = baseToDfnEquipItem(g_Main:m_tblItemData_get(nPart):GetRecord(wItemIndex))

			if pFld then
				return pFld.m_fDefGap
			end
		end
	end

	return 0.5
end

---@param pPlayer CPlayer
---@param nPart integer
---@return number
function sirinPlayerMgr.GetDefFacing(pPlayer, nPart)
	if pPlayer:IsRidingUnit() then
		return baseToUnitFrame(g_Main.m_tblUnitFrame:GetRecord(pPlayer.m_pUsingUnit.byFrame)).m_fDefFacing
	else
		if nPart >= 8 or nPart < 0 then
			return 0.5
		else
			local wItemIndex = pPlayer.m_Param.m_dbChar:m_byDftPart_get(nPart)
			local pCon = pPlayer.m_Param.m_dbEquip:m_List_get(nPart)

			if pCon.m_byLoad == 1 and sirinPlayerMgr.GetEffectEquipCode(pPlayer, STORAGE_POS.equip, nPart) == 1 then
				wItemIndex = pCon.m_wItemIndex
			end

			local pFld = baseToDfnEquipItem(g_Main:m_tblItemData_get(nPart):GetRecord(wItemIndex))

			if pFld then
				return pFld.m_fDefFacing
			end
		end
	end

	return 0.5
end

---@param pPlayer CPlayer
---@return number
function sirinPlayerMgr.GetWeaponAdjust(pPlayer)
	if pPlayer:IsRidingUnit() then
		return 1.0
	else
		local pCon = pPlayer.m_Param.m_dbEquip:m_List_get(6)

		if pCon.m_byLoad == 1 and sirinPlayerMgr.GetEffectEquipCode(pPlayer, STORAGE_POS.equip, 6) == 1 then
			return baseToWeaponItem(g_Main:m_tblItemData_get(6):GetRecord(pCon.m_wItemIndex)).m_fAttGap
		end

		return 0
	end
end

---@param pPlayer CPlayer
---@param nAttactPart integer
---@param pAttChar CCharacter
---@return integer nDefFC
---@return integer nConvertPart
function sirinPlayerMgr.GetDefFC(pPlayer, nAttactPart, pAttChar)
	local defFC = 0
	local nConvertPart = nAttactPart
	pPlayer.m_nLastBeatenPart = nAttactPart

	if pPlayer:IsRidingUnit() then
		defFC = pPlayer.m_nUnitDefFc * pPlayer.m_fUnitPv_DefFc

		if SERVER_AOP and pPlayer.m_bGeneratorDefense then
			local fAvgEquipDefFC = 1

			if pAttChar.m_ObjID.m_byID == ID_CHAR.player then
				for i = 0, 4 do
					local pCon = pPlayer.m_Param.m_dbEquip:m_List_get(i)

					if pCon.m_byLoad == 1 then
						fAvgEquipDefFC = fAvgEquipDefFC + baseToDfnEquipItem(g_Main:m_tblItemData_get(i):GetRecord(pCon.m_wItemIndex))
					end
				end
			end

			pPlayer.m_EP.m_bLock = false
			-- Original calculation was unclear so i fixed it according to attack bonus logic.
			local bnsDef = pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Dec_Def)

			if pPlayer.m_EP:GetEff_Have(_EFF_HAVE.Def_Enchant_Unit) > 0 then
				bnsDef = bnsDef + pPlayer.m_EP:GetEff_Rate(_EFF_RATE.DefFc) - 1
				bnsDef = bnsDef + pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_Enchant_AttFc_byMst_Def_Fc) - 1
			end

			bnsDef = bnsDef + pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_AttFc_byMst_Def_Fc) - 1
			defFC = defFC + fAvgEquipDefFC / 5 * bnsDef

			-- original logic
			--[[
			defFC = defFC + fAvgEquipDefFC / 5
			defFC = defFC + pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Dec_Def) - 1

			if pPlayer.m_EP:GetEff_Have(_EFF_HAVE.Def_Enchant_Unit) > 0 then
				defFC = defFC + fAvgEquipDefFC * (pPlayer.m_EP:GetEff_Rate(_EFF_RATE.DefFc) - 1)
				defFC = defFC + pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_Enchant_AttFc_byMst_Def_Fc) - 1
			end

			defFC = defFC * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Unit_AttFc_byMst_Def_Fc)
			--]]
			--

			pPlayer.m_EP.m_bLock = true
		end
	else
		local bPierceShield = false

		if pAttChar and pAttChar.m_ObjID.m_byID == ID_CHAR.player then
			bPierceShield = pAttChar.m_EP:GetEff_State(_EFF_STATE.Dst_No_Shd)

			if not bPierceShield then
				local fAntiShield = pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.Dst_Shd)

				if fAntiShield > 0 then
					fAntiShield = fAntiShield + pAttChar.m_EP:GetEff_Plus(_EFF_PLUS.Potion_Inc_Ignore_Sheild)

					if math.random(0, 99) <= fAntiShield then
						bPierceShield = true
					end
				end
			end
		end

		if bPierceShield then
			CharacterMgr.SendMsg_AttackActEffect(pAttChar, 1, pPlayer)
		end

		local bEquipShield = false
		local pShieldCon = pPlayer.m_Param.m_dbEquip:m_List_get(5)

		if pShieldCon.m_byLoad == 1 and sirinPlayerMgr.GetEffectEquipCode(pPlayer, STORAGE_POS.equip, 5) == 1 then
			bEquipShield = true
		end

		if bEquipShield then
			local pWeaponCon = pPlayer.m_Param.m_dbEquip:m_List_get(6)

			if pWeaponCon.m_byLoad == 1 then
				local pWeaponFld = baseToWeaponItem(g_Main:m_tblItemData_get(TBL_CODE.weapon):GetRecord(pWeaponCon.m_wItemIndex))

				if pWeaponFld.m_nFixPart == 100 then
					bEquipShield = false
				end
			end
		end

		if pAttChar and bEquipShield and not bPierceShield then
			local blockRate = pPlayer.m_pmMst:GetMasteryPerMast(2, 0) / 99 * 20 + 5 + pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.DEF_ShdDefRate)

			if blockRate > 100 then
				blockRate = 100
			end

			if math.random(0, 99) < blockRate then
				pPlayer.m_nLastBeatenPart = 5
				return -2, nConvertPart
			end
		end

		if bEquipShield then
			for i = 0, 4 do
				local pCon = pPlayer.m_Param.m_dbEquip:m_List_get(i)

				if pCon.m_byLoad == 1 and sirinPlayerMgr.GetEffectEquipCode(pPlayer, STORAGE_POS.equip, i) == 1 then
					local pFld = baseToDfnEquipItem(g_Main:m_tblItemData_get(i):GetRecord(pCon.m_wItemIndex))

					if pFld then
						defFC = defFC + pFld.m_fDefFc * CONST_s_fPartGravity[i + 1]
					end
				else
					local pFld = baseToDfnEquipItem(g_Main:m_tblItemData_get(i):GetRecord(pPlayer.m_Param.m_dbChar:m_byDftPart_get(i)))

					if pFld then
						defFC = defFC + pFld.m_fDefFc * CONST_s_fPartGravity[i + 1]
					end
				end
			end

			defFC = defFC + baseToDfnEquipItem(g_Main:m_tblItemData_get(5):GetRecord(pShieldCon.m_wItemIndex)).m_fDefFc
			defFC = defFC * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Shield_Def)
		else
			local pCon = pPlayer.m_Param.m_dbEquip:m_List_get(pPlayer.m_nLastBeatenPart)

			if pCon.m_byLoad == 1 and sirinPlayerMgr.GetEffectEquipCode(pPlayer, STORAGE_POS.equip, pPlayer.m_nLastBeatenPart) == 1 then
				local pFld = baseToDfnEquipItem(g_Main:m_tblItemData_get(pPlayer.m_nLastBeatenPart):GetRecord(pCon.m_wItemIndex))

				if pFld then
					defFC = pFld.m_fDefFc
				end
			else
				local pFld = baseToDfnEquipItem(g_Main:m_tblItemData_get(pPlayer.m_nLastBeatenPart):GetRecord(pPlayer.m_Param.m_dbChar:m_byDftPart_get(pPlayer.m_nLastBeatenPart)))

				if pFld then
					defFC = pFld.m_fDefFc
				end
			end
		end

		nConvertPart = pPlayer.m_nLastBeatenPart
		defFC = defFC * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Dec_Def)

		if pPlayer:IsSiegeMode() then
			defFC = defFC * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.DEF_SiegeMode)
		end
	end

	if not pPlayer.m_bInGuildBattle then
		local byBossType = Sirin.mainThread.CPvpUserAndGuildRankingSystem.Instance():GetBossType(pPlayer:GetObjRace(), pPlayer.m_dwObjSerial)

		if byBossType == 0 then
			defFC = defFC * CONST_PatriarchBonus_Def
		elseif byBossType == 1 or byBossType == 5 then
			defFC = defFC * CONST_ArchonBonus_Def
		elseif byBossType == 3 or byBossType == 7 then
			defFC = defFC * CONST_DefenseCouncilBonus_Def
		end
	end

	if Sirin.mainThread.g_HolySys:GetDestroyerSerial() == pPlayer.m_dwObjSerial or pPlayer.m_Param.m_bLastAttBuff then
		defFC = defFC * CONST_ChipBreakerBonus_Def
	end

	if not pPlayer:IsRidingUnit() then
		if pPlayer.m_fTalik_DefencePoint > 0 then
			defFC = defFC * (pPlayer.m_EP:GetEff_Rate(_EFF_RATE.DefFc) - pPlayer.m_fTalik_AvoidPoint * (1 - sirinPlayerMgr.CalcDPRate(pPlayer)))
		else
			defFC = defFC * pPlayer.m_EP:GetEff_Rate(_EFF_RATE.DefFc)
		end
	end

	return math.floor(defFC), nConvertPart
end

---@param pPlayer CPlayer
---@param bySlotIndex integer
---@param bUseNPCLinkIntem boolean
---@param bUnitRepairOut boolean
function sirinPlayerMgr.CPlayer__pc_UnitFrameRepairRequest(pPlayer, bySlotIndex, bUseNPCLinkIntem, bUnitRepairOut)
	local byErrCode = 0
	local pData = pPlayer.m_Param.m_UnitDB:m_List_get(bySlotIndex)
	local byFrame = pData.byFrame
	local dwNewGauge = 0
	local dwRepPrice = 0
	local dwRepairValue = 0

	if not pPlayer.m_pUserDB then
		return
	end

	repeat
		if pPlayer:GetObjRace() ~= 0 then
			byErrCode = 1
			break
		end

		if pPlayer.m_pUsingUnit then
			byErrCode = 2
			break
		end

		if not bUseNPCLinkIntem and not Sirin.mainThread.modButtonExt.IsBeNearButton(pPlayer, 10) then
			byErrCode = 21
			break
		end

		if byFrame == 255 then
			byErrCode = 5
			break
		end

		local pFld = Sirin.mainThread.g_Main.m_tblUnitFrame:GetRecord(byFrame)

		if not pFld then
			byErrCode = 5
			break
		end

		local pFrameFld = Sirin.mainThread.baseToUnitFrame(pFld)

		if pFrameFld.m_bRepair == 0 then
			byErrCode = 37
			break
		end

		dwNewGauge = pFrameFld.m_nUnit_HP
		dwRepairValue = dwNewGauge - pData.dwGauge

		if dwRepairValue <= 0 then
			byErrCode = 14
			break
		end

		dwRepPrice = pFrameFld.m_nRepPrice
		local dwDesRepPrice = 0

		for i = 0, 5 do
			local pPartFld = Sirin.mainThread.g_Main:m_tblUnitPart_get(i):GetRecord(pData:byPart_get(i))

			if pPartFld then
				local pUnitPartFld = Sirin.mainThread.baseToUnitPart(pPartFld)

				dwRepPrice = dwRepPrice + pUnitPartFld.m_nRepPrice

				if pData.dwGauge == 0 then
					dwDesRepPrice = dwDesRepPrice + pUnitPartFld.m_nDesrepPrice
				end
			end
		end

		dwRepPrice = math.floor(dwDesRepPrice + dwRepPrice * dwRepairValue * pPlayer.m_fUnitPv_RepPr)

		if bUnitRepairOut then
			byErrCode = 43
			break
		end

		if pPlayer.m_Param:GetDalant() < dwRepPrice then
			byErrCode = 7
			break
		end

	until true

	if byErrCode == 0 then
		pData.dwGauge = dwNewGauge
		local dbData = pPlayer.m_pUserDB.m_AvatorData.dbUnit:m_List_get(bySlotIndex)
		dbData.dwGauge = dwNewGauge
		pPlayer.m_pUserDB.m_bDataUpdate = true

		if dwRepPrice > 0 then
			pPlayer:AlterDalant(-dwRepPrice)
			Sirin.WriteA(pPlayer.m_szItemHistoryFileName, string.format("PAY: Unit_Repair pay(D:%u G:0) $D:%u $G:%u", dwRepPrice, pPlayer.m_Param:GetDalant(), pPlayer.m_Param:GetGold()), false, false)
		end
	end

	-- CPlayer::SendMsg_UnitFrameRepairResult(...)
	--[[
	struct _unit_frame_repair_result_zocl
	{
		char byRetCode;
		char bySlotIndex;
		unsigned int dwNewGauge;
		unsigned int dwConsumDalant;
		unsigned char by2ndValue; // AoP only. Value in braces of repair result window.
		unsigned int dwLeftDalant;
	};
	--]]

	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	buf:PushUInt8(byErrCode)
	buf:PushUInt8(bySlotIndex)
	buf:PushUInt32(dwNewGauge)
	buf:PushUInt32(dwRepPrice)

	if SERVER_AOP then
		buf:PushUInt8(math.floor(dwRepairValue / dwNewGauge * 100))
	end

	buf:PushUInt32(pPlayer.m_Param:GetDalant())
	buf:SendBuffer(pPlayer, 23, 8)
	--
end

return sirinPlayerMgr
