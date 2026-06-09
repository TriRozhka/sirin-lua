
local projectName = 'sirin'
local moduleName = 'CustomDotClickHandler'

local script = {
	m_strUUID = projectName .. ".lua." .. moduleName,
}

---@param pPlayer CPlayer
---@param dwID integer
---@param byType integer
---@param byAction integer 0 - left click, 1 - right click
function script.onClickCustomRadarDot(pPlayer, dwID, byType, byAction)
	print("Dort click. ID: ", dwID, "; Type: ", byType, "; Action: ", byAction)
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
	SirinLua.HookMgr.addHook("onClickCustomRadarDot", HOOK_POS.pre_event, script.m_strUUID, script.onClickCustomRadarDot)

end

autoInit()
