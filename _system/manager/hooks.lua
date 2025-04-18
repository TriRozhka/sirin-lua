---@enum HOOK_POS
HOOK_POS = {
	filter = 1,
	pre_event = 2,
	original = 3,
	after_event = 4,
	special = 5,
}

local hook_pos_str = { 'filter', 'pre_event', 'original', 'after_event', 'special' }

---@class (exact) sirinHookMgr
---@field m_Hooks table<HOOK_POS, table>
---@field addHook fun(func_name: string, pos: HOOK_POS, uid: string, func_handler: fun(...):...?): boolean
---@field removeHook fun(func_name: string, pos: HOOK_POS, uid: string): boolean
---@field releaseHookByUID fun(uid: string)
local sirinHookMgr = {
	m_Hooks = { {}, {}, {}, {}, {} },
}

---@param func_name string
---@param pos HOOK_POS
---@param uid string
---@param func_handler fun(...?):...?
---@return boolean
function sirinHookMgr.addHook(func_name, pos, uid, func_handler)
	local bSucc = false
	local error_str_funcnil = "Lua. sirinHookMgr.addHook(%s, %s, %s, func) func is nil."
	local warning_str_hook_rewrite = "Lua. sirinHookMgr.addHook(%s, %s, %s, func) already hooked by '%s'. Hook was overwritten."

	repeat
		if not func_handler then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format(error_str_funcnil, func_name, hook_pos_str[pos], uid))
			break
		end

		local p = sirinHookMgr.m_Hooks[pos] or {}
		local h = p[func_name] or {}

		if pos == HOOK_POS.original or pos == HOOK_POS.special then
			if h[1] and h[1] ~= uid then
				Sirin.console.LogEx(ConsoleForeground.YELLOW, ConsoleBackground.BLACK, string.format(warning_str_hook_rewrite, func_name, hook_pos_str[pos], uid, h[1]))
			end

			h = { uid, func_handler }
		else
			h[uid] = func_handler
		end

		p[func_name] = h
		sirinHookMgr.m_Hooks[pos] = p
		bSucc = true

	until true

	return bSucc
end

---@param func_name string
---@param pos HOOK_POS
---@param uid string
---@return boolean
function sirinHookMgr.removeHook(func_name, pos, uid)
	local bSucc = false
	local error_str = "Lua. sirinHookMgr.removeHook(%s, %s, %s) not found."
	local p = sirinHookMgr.m_Hooks[pos] or {}
	local h = p[func_name] or {}

	if pos == HOOK_POS.original or pos == HOOK_POS.special then
		if h[1] and h[1] == uid then
			h = nil
			bSucc = true
		end
	else
		if h[uid] then
			h[uid] = nil
			bSucc = true
		end
	end

	if not bSucc then
		Sirin.console.LogEx(ConsoleForeground.YELLOW, ConsoleBackground.BLACK, string.format(error_str, func_name, hook_pos_str[pos], uid))
	end

	return bSucc
end

---@param uid string
function sirinHookMgr.releaseHookByUID(uid)
	for k,p in pairs(sirinHookMgr.m_Hooks) do
		if k == HOOK_POS.original or k == HOOK_POS.special then
			for _,h in pairs(p) do
				if h[1] == uid then
					h = nil
				end
			end
		else
			for _,h in pairs(p) do
				if h[uid] then
					h[uid] = nil
				end
			end
		end
	end
end

return sirinHookMgr
