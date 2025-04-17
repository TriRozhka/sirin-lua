
local projectName = 'yourproject' -- example: MyProject
local moduleName = 'module_unique_name' -- example: `ModuleMgr` name must be unique across all the code.

local script = {
	m_strUUID = projectName .. ".lua." .. moduleName,
}

function script.hookHandler() -- each hook must have own handler

end

function script.onThreadBegin()
	-- your optional load state routine here
end

function script.onThreadEnd()
	-- your optional save state routine here
end

-- hooks and thread routine must be declared above this line

local function autoInit()
	if not _G[moduleName] then -- one time initialization during Lua thread life
		_G[moduleName] = script -- bind your script to a global variable. Variable name must be unique.

		table.insert(SirinLua.onThreadBegin, function() _G[moduleName].onThreadBegin() end)
		table.insert(SirinLua.onThreadEnd, function() _G[moduleName].onThreadEnd() end)
	end

	SirinLua.HookMgr.releaseHookByUID(script.m_strUUID)
	--SirinLua.HookMgr.addHook("function_name1", HOOK_POS.original, script.m_strUUID, script.hookHandler1) -- add necessary hooks
	--SirinLua.HookMgr.addHook("function_name2", HOOK_POS.original, script.m_strUUID, script.hookHandler2) -- add necessary hooks

	-- your optional initialization routine below this line

end

autoInit()

-- other logic below this line
