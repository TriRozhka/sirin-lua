---@class (exact) callbackObject
---@field __index table
---@field callbackFun fun(pObj?: CGameObject)
---@field period integer
---@field lastCall integer
local callbackObject = {
	period = 0,
	lastCall = 0,
}

function callbackObject:new(o)
	local _i = clone(self)
	for k,v in pairs(o or {}) do _i[k] = v end
	self.__index = self
	return setmetatable(_i, self)
end

---@class (exact) sirinZoneLoopMgr
---@field m_objectLoopHandlers table<integer, table<string, callbackObject>>
---@field m_mainLoopHandlers table<string, callbackObject>
---@field m_strUUID string
---@field addObjLoopCallback fun(obj_kind: OBJ_KIND, obj_id: ID_CHAR|ID_ITEM, uid: string, callback: function)
---@field removeObjLoopCallback fun(obj_kind: OBJ_KIND, obj_id: ID_CHAR|ID_ITEM, uid: string)
---@field addMainLoopCallback fun(uid: string, callback: fun(), period?: integer)
---@field removeMainLoopCallback fun(uid: string)
---@field onMainThreadRun fun(pMain: CMainThread)
---@field onObjectLoop fun(obj_id: _object_id, pObj: CGameObject)
---@field initHooks fun()
local sirinZoneLoopMgr = {
	m_strUUID = 'sirin.lua.sirinZoneLoopMgr',
	m_objectLoopHandlers = {},
	m_mainLoopHandlers = {},
}

function sirinZoneLoopMgr.initHooks()
	SirinLua.HookMgr.addHook("CMainThread__OnRun", HOOK_POS.after_event, sirinZoneLoopMgr.m_strUUID, sirinZoneLoopMgr.onMainThreadRun)
end

---@param obj_kind OBJ_KIND
---@param obj_id ID_CHAR|ID_ITEM
---@param uid string
---@param callback function
function sirinZoneLoopMgr.addObjLoopCallback(obj_kind, obj_id, uid, callback)
	if not uid or uid == "" then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.addObjLoopCallback: Invalid uid(%s)!\n", tostring(uid)))
		return
	end

	if obj_kind == OBJ_KIND.char then
		if obj_id < ID_CHAR.player or obj_id > ID_CHAR.nuclear_bomb then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.addObjLoopCallback: obj_kind(%d) Invalid obj_id(%d)!\n", obj_kind, obj_id))
			return
		end
	elseif obj_kind == OBJ_KIND.item then
		if obj_id < ID_ITEM.itembox or obj_id > ID_ITEM.gravity_stone then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.addObjLoopCallback: obj_kind(%d) Invalid obj_id(%d)!\n", obj_kind, obj_id))
			return
		end
	else
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.addObjLoopCallback: Invalid obj_kind(%d)!\n", obj_kind))
		return
	end

	local _id = obj_id * 0x100 + obj_kind
	local objHandler = sirinZoneLoopMgr.m_objectLoopHandlers[_id] or {}
	local prev = objHandler[uid]

	if prev then
		Sirin.console.LogEx(ConsoleForeground.YELLOW, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.addObjLoopCallback: obj_kind(%d) obj_id(%d) uid(%s) callback exists and was replaced.\n", obj_kind, obj_id, uid))
	end

	objHandler[uid] = callbackObject:new{callbackFun = callback}
	sirinZoneLoopMgr.m_objectLoopHandlers[_id] = objHandler
end

---@param obj_kind OBJ_KIND
---@param obj_id ID_CHAR|ID_ITEM
---@param uid string
function sirinZoneLoopMgr.removeObjLoopCallback(obj_kind, obj_id, uid)
	if not uid or uid == "" then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.removeObjLoopCallback: Invalid uid(%s)!\n", tostring(uid)))
		return
	end

	if obj_kind == OBJ_KIND.char then
		if obj_id < ID_CHAR.player or obj_id > ID_CHAR.nuclear_bomb then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.removeObjLoopCallback: obj_kind(%d) Invalid obj_id(%d)!\n", obj_kind, obj_id))
			return
		end
	elseif obj_kind == OBJ_KIND.item then
		if obj_id < ID_ITEM.itembox or obj_id > ID_ITEM.gravity_stone then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.removeObjLoopCallback: obj_kind(%d) Invalid obj_id(%d)!\n", obj_kind, obj_id))
			return
		end
	else
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.removeObjLoopCallback: Invalid obj_kind(%d)!\n", obj_kind))
		return
	end

	local _id = obj_id * 0x100 + obj_kind
	local objHandler = sirinZoneLoopMgr.m_objectLoopHandlers[_id] or {}
	local prev = objHandler[uid]

	if not prev then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.removeObjLoopCallback: obj_kind(%d) obj_id(%d) uid(%s) callback not exists!\n", obj_kind, obj_id, uid))
		return
	end

	objHandler[uid] = nil
end

---@param uid string
---@param callback fun()
---@param period? integer
function sirinZoneLoopMgr.addMainLoopCallback(uid, callback, period)
	period = period or 0

	if not uid or uid == "" then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.addMainLoopCallback: Invalid uid(%s)!\n", tostring(uid)))
		return
	end

	local prev = sirinZoneLoopMgr.m_mainLoopHandlers[uid]

	if prev then
		Sirin.console.LogEx(ConsoleForeground.YELLOW, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.addMainLoopCallback: uid(%s) callback exists and was replaced.\n", uid))
	end

	sirinZoneLoopMgr.m_mainLoopHandlers[uid] = callbackObject:new{callbackFun = callback, period = period}
end

---@param uid string
function sirinZoneLoopMgr.removeMainLoopCallback(uid)
	if not uid or uid == "" then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.removeMainLoopCallback: Invalid uid(%s)!\n", tostring(uid)))
		return
	end

	local prev = sirinZoneLoopMgr.m_mainLoopHandlers[uid]

	if not prev then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.removeMainLoopCallback: uid(%s) callback not exists!\n", uid))
		return
	end

	sirinZoneLoopMgr.m_mainLoopHandlers[uid] = nil
end

function sirinZoneLoopMgr.onMainThreadRun()
	local loop_time = Sirin.mainThread.GetLoopTime()

	for k,v in pairs(sirinZoneLoopMgr.m_mainLoopHandlers) do
		repeat
			if v.period == 0 or (v.period > 0 and v.lastCall + v.period <= loop_time) then
				local succ, ret = pcall(v.callbackFun)

				if not succ then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, "Lua. sirinZoneLoopMgr.onMainThreadRun(...) exception:\n" .. tostring(ret) .. "\n")
					sirinZoneLoopMgr.m_mainLoopHandlers[k] = nil
					break
				end

				if v.period > 0 then
					v.lastCall = loop_time
				end
			end

		until true
	end
end

SirinMainLoop = sirinZoneLoopMgr.onMainThreadRun

---@param obj_id _object_id
---@param pObj CGameObject
function sirinZoneLoopMgr.onObjectLoop(obj_id, pObj)
	local _id = obj_id.m_byID * 0x100 + obj_id.m_byKind
	local list = sirinZoneLoopMgr.m_objectLoopHandlers[_id] or {}

	for k,v in pairs(list) do
		local succ, ret = pcall(v.callbackFun, pObj)

		if not succ then
			Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. sirinZoneLoopMgr.onObjectLoop() obj_kind(%d) obj_id(%d) index(%d) uid(%s) exception:\n%s\n", obj_id.m_byKind, obj_id.m_byID, obj_id.m_wIndex, k, tostring(ret)))
			sirinZoneLoopMgr.m_mainLoopHandlers[k] = nil
			break
		end
	end
end

return sirinZoneLoopMgr
