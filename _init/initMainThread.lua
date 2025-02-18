---@module '_init.definitions.sirinDefinitionsMainThread2.lua'
---@module '_init.definitions.sirinDefinitionsMainThread.lua'
---@module '_init.definitions.sirinDefinitionsMainThread_Structs.lua'

--collectgarbage('setpause', 150)
--collectgarbage('setstepmul', 300)
collectgarbage('incremental', 150, 300, 13)

require('init')
require('_init.enum.EffectParameter')
require('_init.file_loader.file_loader')
require('_init.event_handlers.MainThreadEvtMgr')
NetMgr = require('_init.mgr.net.Networking')
require('_init.mgr.rifts.rifts')
PlayerMgr = require('_init.mgr.player.player')
CharacterMgr = require('_init.mgr.character.character')
CombineExMgr = require('_init.mgr.combine_ex.combine_ex')
require('_init.mgr.extra_gm_commands.GmCommandsMgr')
require('_init.mgr.npc_buttons.ButtonMgr')
require('_init.mgr.potion.potion')
require('_init.mgr.map.map')
BotMgr = require('_init.mgr.bot.bot')
require('_init.mgr.box.box')
QuestMgr = require('_init.mgr.quest.quest')
require('_init.mgr.monster_schedule.monster_schedule')
require('_init.mgr.looting.looting')
require('_init.mgr.tower.tower')

OnThreadBegin = {
	function() RiftMgr:loadScripts(); ZoneEventMgr:addMainLoopCallback(RiftMgr.m_strUUID, function() RiftMgr:onLoop() end, 100) end,
	function() GmCommMgr:loadScripts() end,
	function() ButtonMgr:loadScripts() end,
	function() PotionMgr:loadScripts() end,
	function() PlayerMgr.init() end,
	function() CombineExMgr.init() end,
	function() BotMgr.Init(); ZoneEventMgr:addMainLoopCallback("sirin.mgr.bot", function() BotMgr.OnRun() end, 50) end,
	function() BoxOpenMgr:loadScripts() end,
	function() MonsterScheduleMgr:loadScripts(); ZoneEventMgr:addMainLoopCallback(MonsterScheduleMgr.m_strUUID, function() MonsterScheduleMgr:onLoop() end, 1000) end,
	--function() LootingMgr:loadScripts(); ZoneEventMgr:addMainLoopCallback(LootingMgr.m_strUUID, function() LootingMgr:onLoop() end, 100) end,
}

OnThreadEnd = {
	function() RiftMgr:saveState() end,
	function() PotionMgr:uninit() end,
	function() MonsterScheduleMgr:saveState() end,
	--function() LootingMgr:saveState() end,
}

MainThread = {}

require('_init.MainThread.addon')
require('_init.MainThread.extend')
require('_init.MainThread.replace')

-- MobDebug Debugger
--require('mobdebug').checkcount = 1
--require("mobdebug").start()
--require("mobdebug").off()
--

-- Lua Debug by actboy168
--require "debugger":start "0.0.0.0:12306":event "wait"
--