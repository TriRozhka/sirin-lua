
local projectName = 'sirin'
local moduleName = 'show_upgrade_succ_rate'

local script = {
	m_strUUID = projectName .. ".lua." .. moduleName,
}

---@param pPlayer CPlayer
---@param pUserDB CUserDB
---@param bFirstStart boolean
function script.CPlayer__Load(pPlayer, pUserDB, bFirstStart)
	if not script.netOP then
		local send = {}
		send.ct = 0
		send.noGemRate = 0.125
		send.SuccRates = {}

		for k,v in ipairs(PlayerMgr.SuccRates) do
			local t = {}
			t.id = k
			t.data = clone(v)
			table.insert(send.SuccRates, t)
		end

		script.netOP = NetOP:new()
		script.netOP:SendData(pPlayer, "sirin.proto.upgradeRates", send, true)
	else
		script.netOP:Send(pPlayer)
	end
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
	SirinLua.HookMgr.addHook("CPlayer__Load", HOOK_POS.after_event, script.m_strUUID, script.CPlayer__Load)

end

autoInit()
