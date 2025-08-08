
local projectName = 'sirin' 
local moduleName = 'sirinPatriacrhVote'

local script = {
	m_strUUID = projectName .. ".lua." .. moduleName,
}

function script.hookHandler()

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
	SirinLua.HookMgr.addHook("initVoteParams", HOOK_POS.pre_event, script.m_strUUID, script.initVoteParams)
	SirinLua.HookMgr.addHook("canVote", HOOK_POS.filter, script.m_strUUID, script.canVote)
	SirinLua.HookMgr.addHook("getVoiceWeight", HOOK_POS.special, script.m_strUUID, script.getVoiceWeight)
	SirinLua.HookMgr.addHook("votePatriarch", HOOK_POS.after_event, script.m_strUUID, script.votePatriarch)
	SirinLua.HookMgr.addHook("canRegistElection", HOOK_POS.special, script.m_strUUID, script.canRegistElection)
	SirinLua.HookMgr.addHook("registElection", HOOK_POS.after_event, script.m_strUUID, script.registElection)
	SirinLua.HookMgr.addHook("canAutoAddPatriarchGroup", HOOK_POS.filter, script.m_strUUID, script.canAutoAddPatriarchGroup)

end

function script.initVoteParams()
	Sirin.mainThread.g_Main.m_dwCheatSetLevel = 50
	Sirin.mainThread.g_Main.m_dwCheatSetScanerCnt = 0
	Sirin.mainThread.g_Main.m_dwCheatSetPlayTime = 600
end

---@param pPlayer CPlayer
---@param bVote boolean Is real vote - true, votepaper send check - false
---@return boolean
function script.canVote(pPlayer, bVote)
	local bSucc = false

	repeat
		if pPlayer.m_pUserDB.m_AvatorData.dbAvator.m_byLastClassGrade < 2 then
			break
		end

		if pPlayer.m_pUserDB.m_AvatorData.dbSupplement.dwAccumPlayTime < Sirin.mainThread.g_Main.m_dwCheatSetPlayTime then
			break
		end

		if pPlayer.m_pUserDB.m_AvatorData.dbSupplement.VoteEnable == 0 or pPlayer.m_pUserDB.m_AvatorData.dbSupplement.byVoted ~= 0 then
			break
		end

		if pPlayer.m_pUserDB.m_AvatorData.dbSupplement.wScanerCnt < Sirin.mainThread.g_Main.m_dwCheatSetScanerCnt then
			break
		end

		if pPlayer.m_pUserDB.m_AvatorData.dbAvator.m_byLevel < Sirin.mainThread.g_Main.m_dwCheatSetLevel then
			break
		end

		if Sirin.mainThread.CandidateMgr.Instance():IsRegistedAvator_2(pPlayer:GetObjRace(), pPlayer.m_dwObjSerial) then
			break
		end

		bSucc = true

	until true

	if bVote and bSucc then
		-- consume items. do stuff. optionally.
	end

	return bSucc
end

---@param pPlayer CPlayer
---@return number
function script.getVoiceWeight(pPlayer)
	if pPlayer.m_Param.m_byPvPGrade >= 4 then
		return 0.02 -- return multiplied by 100. 1.01 -> 101. Score is just a number used to decide who is winner.
	end

	return 0.01
end

---@param pPlayer CPlayer
---@param bAbstain boolean
---@param pCandidate? _candidate_info
function script.votePatriarch(pPlayer, bAbstain, pCandidate)
	-- do stuff here. consume items, report services, etc.
end

---@param pPlayer CPlayer
---@return integer #return 0 if no error.
function script.canRegistElection(pPlayer)
	if pPlayer.m_Param.m_byPvPGrade < 3 then
		return 4
	end

	if pPlayer.m_Param:GetDalant() < 10000000 then
		return 5
	end

	if Sirin.mainThread.CandidateMgr.Instance():IsRegistedAvator_1(pPlayer:GetObjRace(), pPlayer.m_dwObjSerial) then
		return 3
	end

	return 0
end

---@param pPlayer CPlayer
function script.registElection(pPlayer)
	-- do stuff here. consume items, report services, etc.
end

---@return boolean
function script.canAutoAddPatriarchGroup()
	return true -- if true, empty positions filled by race rank. if false - empty positions stay empty.
end

autoInit()
