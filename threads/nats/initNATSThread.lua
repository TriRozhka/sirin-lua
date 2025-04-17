---@module '_system.definitions.natsThreadDefs.lua'

collectgarbage('generational')

require('init')


-- Enums and globals
require('_system.enum.RF_Globals')
require('_system.enum.EffectParameter')


-- Native logic implementations


-- System objects. Cannot be renamed.
SirinLua = {}


-- Custom logic implementations
NATSLua = require('_system.manager.nats')


SirinLua.onThreadBegin = {
}

SirinLua.onThreadEnd = {
}

-- Custom modules initialization
require('threads.nats.custom.init')


-- MobDebug Debugger
--require('_system.utility.mobdebug').checkcount = 1
--require('_system.utility.mobdebug').start()
--require('_system.utility.mobdebug').off()
--

-- Lua Debug by actboy168
--require('_system.utility.debugger'):start "0.0.0.0:12306":event "wait"
--