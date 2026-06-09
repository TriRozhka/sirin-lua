
local projectName = 'sirin'
local moduleName = 'NoPasswordTrunk'

local script = {
	m_strUUID = projectName .. ".lua." .. moduleName,
}

---@param pPlayer CPlayer
---@param pszPasword? string
function script.canUseTrunkWithNoPassword(pPlayer, pszPasword)
	if pszPasword == "" then
		return true
	end

	return false
end

---@param pPlayer CPlayer
function script.canUseTrunkWithNoBeeper(pPlayer)
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
	SirinLua.HookMgr.addHook("canUseTrunkWithNoPassword", HOOK_POS.filter, script.m_strUUID, script.canUseTrunkWithNoPassword)

	-- Enable this if you want to open trunk using custom window button.
	--SirinLua.HookMgr.addHook("canUseTrunkWithNoBeeper", HOOK_POS.filter, script.m_strUUID, script.canUseTrunkWithNoBeeper)
end

autoInit()
