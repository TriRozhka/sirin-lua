
local projectName = 'Sirin'
local moduleName = 'SirinDatabaseHandlerDemo'

local script = {
	m_strUUID = projectName .. ".lua." .. moduleName,
	m_data = {},
	m_oldData = {},
}

--- On lua thread restart we need to load our lua data from data thread.
function script.onThreadBegin()
	local t = {}
	local Ctx = Sirin.luaThreadManager.LuaGetThread("sirin.guard.data")

	Ctx:Lock()

	if Sirin.luaThreadManager.IsExistGlobal(Ctx, "Sirin_DatabaseHandlerDemoData") then
		t = Sirin.luaThreadManager.CopyFromContext(Ctx, "Sirin_DatabaseHandlerDemoData")
		Sirin.luaThreadManager.DeleteGlobal(Ctx, "Sirin_DatabaseHandlerDemoData")
	end

	Ctx:Unlock()

	if #t > 0 then
		for _,v in ipairs(t) do
			script.m_data[v[1]] = v[2]
			script.m_oldData[v[1]] = v[3]
		end
	end
end

--- On lua thread restart we need to sace our lua data to data thread. You can save tables (numeric or string keys only), strings, numbers, ZoneObject pointers (you sould use corresponding functions and cast them to VoidPtr type)
function script.onThreadEnd()
	local t = {}

	for k,v in pairs(script.m_data) do
		table.insert(t, { k, v, script.m_oldData[k] or 0 })
	end

	local Ctx = Sirin.luaThreadManager.LuaGetThread("sirin.guard.data")

	if #t > 0 then
		Ctx:Lock()

		Sirin.luaThreadManager.CopyToContext(Ctx, "Sirin_DatabaseHandlerDemoData", t)

		Ctx:Unlock()
	end
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
	SirinLua.HookMgr.addHook("SirinWorldDB_PlayerSave_Prepare", HOOK_POS.pre_event, script.m_strUUID, script.onPlayerSavePrepare) -- happens before DQS cases 5, 6, 12
	SirinLua.HookMgr.addHook("SirinWorldDB_PlayerUpdate_Complete", HOOK_POS.after_event, script.m_strUUID, script.onPlayerUpdateComplete) -- happens after DQS case 12 processed
	SirinLua.HookMgr.addHook("SirinWorldDB_PlayerLoad_Complete", HOOK_POS.after_event, script.m_strUUID, script.onPlayerLoadComplete) -- happens after DQS case 3 processed

end

---This hook allows you to prepare data you want to save in database. Each module can have own hook. Hooks called sequentially.
---@param dwPlayerSerial integer
---@param wClientIndex integer CPlayer array index [0 - 2531]
---@param byQryCase integer 5 - logoff, 6 - lobby, 12 - periodic save
---@param multiBinaryData CMultiBinaryData -- container to accept data.
function script.onPlayerSavePrepare(dwPlayerSerial, wClientIndex, byQryCase, multiBinaryData)
	local data, oldData = (script.m_data[wClientIndex] or 0), (script.m_oldData[wClientIndex] or 0)

	if data ~= oldData then -- check if data had changed
		local buf = Sirin.CBinaryData(8) -- allocate buffer to store data
		buf:PushUInt32(dwPlayerSerial)
		buf:PushUInt32(data)
		multiBinaryData:PushData(1, buf) -- 1 is your unique data identifier
	end
end

---This hook inform mainThread about data update results. Each module can have own hook. Hooks called sequentially.
---@param byErrCode integer
---@param dwPlayerSerial integer
---@param wClientIndex integer
---@param multiBinaryData CMultiBinaryData
function script.onPlayerUpdateComplete(byErrCode, dwPlayerSerial, wClientIndex, multiBinaryData)
	if byErrCode ~= 0 then
		return
	end

	local data = multiBinaryData:GetData(1) -- 1 is your unique data identifier

	if not data then
		return
	end

	local pPlayer = Sirin.mainThread.g_Player_get(wClientIndex)

	-- check player object is still the same player after async operation was completed.
	if not pPlayer or not pPlayer.m_bLive or not pPlayer.m_bOper or pPlayer.m_dwObjSerial ~= dwPlayerSerial then
		return
	end

	data:SetReadPos(4) -- first 4 bytes is player serial (line 43 of this file). we skipp them to read data we pushed.

	local succ, val = data:PopUInt32()

	if not succ then
		return
	end

	script.m_oldData[wClientIndex] = val -- oldData stores last saved state of player.
end

---This hook inform mainThread about data load results. Each module can have own hook. Hooks called sequentially.
---@param bError boolean
---@param byErrCode integer
---@param dwPlayerSerial integer
---@param wClientIndex integer
---@param multiSQLResultSet CMultiSQLResultSet
function script.onPlayerLoadComplete(bError, byErrCode, dwPlayerSerial, wClientIndex, multiSQLResultSet)
	if bError then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, "onPlayerLoadComplete: bError ~= 0\n")
		return
	end

	local set = multiSQLResultSet:GetData(1) -- 1 is your unique data identifier

	if not set then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, "onPlayerLoadComplete: set == nil\n")
		return
	end

	local l = set:GetList() -- obtain list of sql rows

	-- Set default data id nothing was loaded.
	if not l or #l == 0 then
		script.m_data[wClientIndex] = 0
		script.m_oldData[wClientIndex] = 0
		return
	end

	local data = l[1] -- set may contain many lines in list but in this example we receive only one row per request

	if not data then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, "onPlayerLoadComplete: data == nil\n")
		return
	end

	local suc, val = data:PopUInt32()

	if not suc then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, "onPlayerLoadComplete: data:PopUInt32() 1 suc == false\n")
		return
	end

	if val ~= dwPlayerSerial then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("onPlayerLoadComplete: val(%d) ~= dwPlayerSerial(%d)\n", val, dwPlayerSerial))
		return
	end

	suc, val = data:PopUInt32()

	if not suc then
		Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, "onPlayerLoadComplete: data:PopUInt32() 2 suc == false\n")
		return
	end

	-- Save loaded data to our script local storage
	script.m_data[wClientIndex] = val
	script.m_oldData[wClientIndex] = val
end

autoInit()
