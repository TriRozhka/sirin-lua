
local projectName = 'Sirin'
local moduleName = 'RadarCustomHandler'

local g_Player_get = Sirin.mainThread.g_Player_get
local g_Monster_get = Sirin.mainThread.g_Monster_get

local script = {
	m_strUUID = projectName .. ".lua." .. moduleName,
}

---@param pRadarMgr CRadarItemMgr
---@param pRadarFld _RadarItem_fld
---@return boolean
function script.CRadarItemMgr__RadarProc(pRadarMgr, pRadarFld)
	pRadarMgr.m_bSameRace = false
	pRadarMgr.m_bNorDiffRace = false
	pRadarMgr.m_bChiefDiffRace = false
	pRadarMgr.m_bEliteMonster = false
	pRadarMgr.m_RadarResult:init()

	if not pRadarMgr.m_bUse or not pRadarMgr.m_pMaster or not pRadarMgr.m_pDestMap or not pRadarFld then
		pRadarMgr.m_bPlayerEnd = true
		pRadarMgr.m_bMonEnd = true
		return false
	end

	if pRadarMgr.m_bPlayerEnd == true and pRadarMgr.m_bMonEnd == true then
		return false
	end

	local pParty = pRadarMgr.m_pMaster.m_pPartyMgr
	local byRace = pRadarMgr.m_pMaster:GetObjRace()

	if pRadarFld.m_strEffSort:sub(1, 1) == "1" then
		pRadarMgr.m_bSameRace = true
	end

	if pRadarFld.m_strEffSort:sub(2, 2) == "1" then
		pRadarMgr.m_bNorDiffRace = true
	end

	if pRadarFld.m_strEffSort:sub(3, 3) == "1" then
		pRadarMgr.m_bChiefDiffRace = true
	end

	if pRadarFld.m_strEffSort:sub(4, 4) == "1" then
		pRadarMgr.m_bEliteMonster = true
	else
		pRadarMgr.m_bMonEnd = true
	end

	local nUsedNum = 0
	local bCapreached = false

	if not pRadarMgr.m_bPlayerEnd then
		local pRankMgr = Sirin.mainThread.CPvpUserAndGuildRankingSystem.Instance()
		local bossList = {}

		for j = 0, 2 do
			bossList[j] = pRankMgr:GetCurrentRaceBossSerial(j, 0)
		end

		for i = pRadarMgr.m_nPlayerNum, 2531 do
			if nUsedNum >= 50 or nUsedNum < 0 then
				bCapreached = true
				pRadarMgr.m_nPlayerNum = i
				break
			end

			repeat
				local pTestPlayer = g_Player_get(i)
				local dwTestSerial = pTestPlayer.m_id.dwSerial
				local byTestRace = pTestPlayer:GetObjRace()

				if not pTestPlayer.m_bLive or pTestPlayer.m_pCurMap ~= pRadarMgr.m_pDestMap then
					break
				end

				if pRadarMgr.m_bChiefDiffRace and byRace ~= byTestRace then
					if dwTestSerial == bossList[byTestRace] then
						nUsedNum = pRadarMgr.m_RadarResult:AddCharInfo(3, pTestPlayer.m_fCurPos_x, pTestPlayer.m_fCurPos_z)
						break
					end
				end

				if pRadarMgr.m_bNorDiffRace and byRace ~= byTestRace then
					nUsedNum = pRadarMgr.m_RadarResult:AddCharInfo(2, pTestPlayer.m_fCurPos_x, pTestPlayer.m_fCurPos_z)
					break
				end

				if pRadarMgr.m_bSameRace and byRace == byTestRace and not IsSameObject(pRadarMgr.m_pMaster, pTestPlayer) then
					if dwTestSerial == bossList[byRace] then
						nUsedNum = pRadarMgr.m_RadarResult:AddCharInfo(1, pTestPlayer.m_fCurPos_x, pTestPlayer.m_fCurPos_z)
						break
					end

					if not pParty:IsPartyMode() or not pParty:IsPartyMember(pTestPlayer) then
						nUsedNum = pRadarMgr.m_RadarResult:AddCharInfo(0, pTestPlayer.m_fCurPos_x, pTestPlayer.m_fCurPos_z)
						break
					end
				end

			until true
		end

		if not bCapreached then
			pRadarMgr.m_bPlayerEnd = true
		end
	end

	if not pRadarMgr.m_bMonEnd then
		bCapreached = false

		for i = pRadarMgr.m_nMonNum, 29999 do
			if nUsedNum >= 50 or nUsedNum < 0 then
				bCapreached = true
				pRadarMgr.m_nMonNum = i
				break
			end

			repeat
				local pTestMon = g_Monster_get(i)

				if not pTestMon.m_bLive or pTestMon.m_pCurMap ~= pRadarMgr.m_pDestMap or pTestMon.m_pMonRec.m_nMobGrade ~= 2 then
					break
				end

				nUsedNum = pRadarMgr.m_RadarResult:AddCharInfo(4, pTestMon.m_fCurPos_x, pTestMon.m_fCurPos_z)

			until true
		end

		if not bCapreached then
			pRadarMgr.m_bMonEnd = true
		end
	end

	return true
end

function script.onThreadBegin()
end

function script.onThreadEnd()
end

local function autoInit()
	if not _G[moduleName] then
		_G[moduleName] = script
		table.insert(SirinLua.onThreadBegin, function() _G[moduleName].onThreadBegin() end)
		table.insert(SirinLua.onThreadEnd, function() _G[moduleName].onThreadEnd() end)
	else
		_G[moduleName] = script
	end

	SirinLua.HookMgr.releaseHookByUID(script.m_strUUID)
	SirinLua.HookMgr.addHook("CRadarItemMgr__RadarProc", HOOK_POS.original, script.m_strUUID, script.CRadarItemMgr__RadarProc)

end

autoInit()
