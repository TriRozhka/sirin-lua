---@module '_system.definitions.userDBThreadDefs.lua'

collectgarbage('generational')

require('init')


-- Enums and globals
require('_system.enum.RF_Globals')


-- Native logic implementations


-- System objects. Cannot be renamed.
SirinLua = {}
SirinLua.HookMgr = require('_system.manager.hooks')


-- Custom logic implementations


SirinLua.onThreadBegin = {
}

SirinLua.onThreadEnd = {
}

-- Custom modules initialization
require('threads.userDB.custom.init')


-- MobDebug Debugger
--require('_system.utility.mobdebug').checkcount = 1
--require('_system.utility.mobdebug').start()
--require('_system.utility.mobdebug').off()
--

-- Lua Debug by actboy168
--require('_system.utility.debugger'):start "0.0.0.0:12306":event "wait"
--