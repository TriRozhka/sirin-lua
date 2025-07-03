
---@module 'threads.main._system.definitions.mainThreadDefs_Classes3.lua'
---@module 'threads.main._system.definitions.mainThreadDefs_Objects.lua'
---@module 'threads.main._system.definitions.mainThreadDefs_MainThread.lua'
---@module 'threads.main._system.definitions.mainThreadDefs_Structs.lua'

collectgarbage('generational')

require('init')


-- Enums and globals
require('_system.enum.RF_Globals')
require('_system.enum.EffectParameter')
require('_system.manager.fileLoader') -- global FileLoader
require('threads.main._system.globals')


-- Native logic implementations
CharacterMgr = require('threads.main._system.native.character')
PlayerMgr = require('threads.main._system.native.player')
AnimusMgr = require('threads.main._system.native.animus')
TowerMgr = require('threads.main._system.native.tower')
QuestMgr = require('threads.main._system.manager.quest')


-- System objects. Cannot be renamed.
SirinLua = {}
SirinLua.HookMgr = require('_system.manager.hooks')
SirinLua.LoopMgr = require('threads.main._system.manager.zoneLoop')
SirinLua.BoxOpenMgr = require('threads.main._system.manager.boxItemOut')
SirinLua.ButtonMgr = require('threads.main._system.manager.npcButtons')
SirinLua.PotionMgr = require('threads.main._system.manager.potionEffect')
SirinLua.GmCommMgr = require('threads.main._system.manager.gmCommands')
SirinLua.ClientWindowMgr = require('threads.main._system.manager.customWindow')


-- Custom logic implementations
NATSLua = require('_system.manager.nats')
NetMgr = require('threads.main._system.manager.networking')
MapMgr = require('threads.main._system.manager.map')
AutoLootMgr = require('threads.main._system.manager.autoloot')
BotMgr = require('threads.main._system.manager.bot')


-- Reloadable script handlers
RiftMgr = require('threads.main._system.manager.rifts')
CombineExMgr = require('threads.main._system.manager.combineEx')
MonsterScheduleMgr = require('threads.main._system.manager.monsterSchedule')
LootingMgr = require('threads.main._system.manager.itemLooting')


SirinLua.onThreadBegin = {
	function() if Sirin.NATS then NATSLua.initHooks_main(); Sirin.NATS.initNATS() end end,
	function() SirinLua.LoopMgr.initHooks() end,
	function() SirinLua.BoxOpenMgr.loadScripts() end,
	function() SirinLua.ButtonMgr.loadScripts() end,
	function() SirinLua.PotionMgr.loadScripts() end,
	function() SirinLua.GmCommMgr.loadScripts() end,
	function() SirinLua.ClientWindowMgr.initHooks(); SirinLua.ClientWindowMgr.loadScripts() end,
	function() PlayerMgr.initHooks(); PlayerMgr.init() end,
	function() AutoLootMgr.initHooks() end,
	function() TowerMgr.initHooks() end,
	function() RiftMgr.initHooks(); RiftMgr.loadScripts(); SirinLua.LoopMgr.addMainLoopCallback(RiftMgr.m_strUUID, function() RiftMgr.onLoop() end, 100) end,
	function() CombineExMgr.initHooks(); CombineExMgr.loadScripts() end,
	function() BotMgr.initHooks(); BotMgr.init(); SirinLua.LoopMgr.addMainLoopCallback(BotMgr.m_strUUID, function() BotMgr.onLoop() end, 50) end,
	function() MonsterScheduleMgr.initHooks(); MonsterScheduleMgr.loadScripts(); SirinLua.LoopMgr.addMainLoopCallback(MonsterScheduleMgr.m_strUUID, function() MonsterScheduleMgr.onLoop() end, 1000) end,
	--function() LootingMgr.initHooks(); LootingMgr.loadScripts(); SirinLua.LoopMgr.addMainLoopCallback(LootingMgr.m_strUUID, function() LootingMgr.onLoop() end, 100) end,
}

SirinLua.onThreadEnd = {
	function() SirinLua.PotionMgr.uninit() end,
	function() RiftMgr.saveState() end,
	function() MonsterScheduleMgr.saveState() end,
	--function() LootingMgr.saveState() end,
}

-- Custom modules initialization
require('threads.main.custom.init')


-- MobDebug Debugger
--require('_system.utility.mobdebug').checkcount = 1
--require('_system.utility.mobdebug').start()
--require('_system.utility.mobdebug').off()
--

-- Lua Debug by actboy168
--require('_system.utility.debugger'):start "0.0.0.0:12306":event "wait"
--