---@class (exact) CallbackObject
---@field __index table
---@field callbackFun fun(pObj?: CGameObject)
---@field period integer
---@field lastCall integer
local CallbackObject = {
	period = 0,
	lastCall = 0,
}

function CallbackObject:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

---@class (exact) EventMgr
---@field __index table
---@field objectLoopHandlers table<ID_CHAR, table<string, CallbackObject>>
---@field mainLoopHandlers table<string, CallbackObject>
local EventMgr = {
	objectLoopHandlers = {},
	mainLoopHandlers = {},
}

---@return EventMgr
function EventMgr:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

ZoneEventMgr = EventMgr:new()

for i = 0, 12 do
	ZoneEventMgr.objectLoopHandlers[i] = {}
end

---@param obj_id ID_CHAR
---@param uid string
---@param callback function
function EventMgr:addObjLoopCallback(obj_id, uid, callback)
	if not uid or uid == "" then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("EventMgr:addObjLoopCallback: Invalid uid(%s)!\n", tostring(uid)))
		return
	end

	if obj_id > ID_CHAR.nuclear_bomb then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("EventMgr:addObjLoopCallback: Invalid obj_id(%d)!\n", obj_id))
		return
	end

	local prev = self.objectLoopHandlers[obj_id][uid]

	if prev then
		Sirin.console.LogEx(ConsoleForeground.YELLOW, ConsoleBackground.BLACK, string.format("EventMgr:addObjLoopCallback: obj_id(%d) uid(%s) callback exists and was replaced.\n", obj_id, uid))
	end

	self.objectLoopHandlers[obj_id][uid] = CallbackObject:new{callbackFun = callback}
end

---@param obj_id ID_CHAR
---@param uid string
function EventMgr:removeObjLoopCallback(obj_id, uid)
	if not uid or uid == "" then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("EventMgr:removeObjLoopCallback: Invalid uid(%s)!\n", tostring(uid)))
		return
	end

	if obj_id > ID_CHAR.nuclear_bomb then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("EventMgr:removeObjLoopCallback: Invalid obj_id(%d)!\n", obj_id))
		return
	end

	local prev = self.objectLoopHandlers[obj_id][uid]

	if not prev then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("EventMgr:removeObjLoopCallback: obj_id(%d) uid(%s) callback not exists!\n", obj_id, uid))
		return
	end

	self.objectLoopHandlers[obj_id][uid] = nil
end

---@param uid string
---@param callback function
---@param period? integer
function EventMgr:addMainLoopCallback(uid, callback, period)
	period = period or 0

	if not uid or uid == "" then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("EventMgr:addMainLoopCallback: Invalid uid(%s)!\n", tostring(uid)))
		return
	end

	local prev = self.mainLoopHandlers[uid]

	if prev then
		Sirin.console.LogEx(ConsoleForeground.YELLOW, ConsoleBackground.BLACK, string.format("EventMgr:addMainLoopCallback: uid(%s) callback exists and was replaced.\n", uid))
	end

	self.mainLoopHandlers[uid] = CallbackObject:new{callbackFun = callback, period = period}
end

---@param uid string
function EventMgr:removeMainLoopCallback(uid)
	if not uid or uid == "" then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("EventMgr:removeMainLoopCallback: Invalid uid(%s)!\n", tostring(uid)))
		return
	end

	local prev = self.mainLoopHandlers[uid]

	if not prev then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("EventMgr:removeMainLoopCallback: uid(%s) callback not exists!\n", uid))
		return
	end

	self.mainLoopHandlers[uid] = nil
end

function EventMgr:OnRun()
	local loop_time = Sirin.mainThread.GetLoopTime()

	for k,v in pairs(self.mainLoopHandlers) do
		repeat
			if v.period == 0 or (v.period > 0 and v.lastCall + v.period <= loop_time) then
				local succ, ret = pcall(v.callbackFun)

				if not succ then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, "Lua.EventMgr:OnRun() exception:\n" .. tostring(ret) .. "\n")
					self.mainLoopHandlers[k] = nil
					break
				end

				if v.period > 0 then
					v.lastCall = loop_time
				end
			end

		until true
	end
end