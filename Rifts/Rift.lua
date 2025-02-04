local t = {
rift = { -- You may put any unique name. Only letters and underscore allowed in short form. Fulll form is: ["any string"] = {...},
	portalType = 0, -- 0 Rift (map to map), 1 - Darkhole (map to dungeon. Not implemented yet. Reserverd for future purposes.)
	srcMap = "NeutralC",
	srcPos = {
		{7065, -154, 1169, 0}, -- x, y, z, layer (layer is reserverd for future purposes.)
		--{0, 0, 0, 0},
	},
	dstMap = "NeutralC",
	dstPos = {
		{7475, -157, 1306, 0}, -- x, y, z, layer (layer is reserverd for future purposes.)
		--{0, 0, 0, 0},
	},
	exitGateType = 0,						-- 0 (default) Show exit swirl always, 1 Do not show, 2 Show after usage. Optional.
	exitGateDelay = 15,						-- If exitGateType set to 2 then this parameter responsible for exit gate live time in seconds. Default 60. Optional.
	--probability = 33,						-- open probability. 0-100%. Default 100. Optional.
	--useCount = 2,							-- how many players can pass through. Unlimited if < 0. Default -1. Optional
	buttonName = {
		default = 'Button name 3',
	},
	description = {
		default = 'Description line 1\nDescription line 2\nDescription line 3',
	},

	onOpen = function (pLuaRift)
		local announceMsg = { 
			default = "Rift just opened",
		}
		NetMgr.SendGlobalChatData(announceMsg, CHAT_TYPE.System, ANN_TYPE.mid3, nil, 0xFF00FF00)
	end,

	onClose = function (pLuaRift)
		local announceMsg = { 
			default = "Rift closed",
		}
		NetMgr.SendGlobalChatData(announceMsg, CHAT_TYPE.System, ANN_TYPE.mid3, nil, 0xFF00FF00)
	end,

	conditions = {
		-- All values below are optional and displayed to show use syntax only. You may skip any of them in final script.
		-- If value not set, then default applied
		--minLevel = 10,							-- can use if level >= value.
		--maxLevel = 50,							-- can use if level <= value.
		--pvpGradeLimit = -1,						-- can use if pvp grade >= value. 0-7
		--patriarchGroupLimit = { 1, 2, 6 },		-- 1 - patriarch, 2,6 - archon, 3,7 - attack officer, 4,8 - defence officer, 5,9 - support officer, 255 - normal player
		-- or -1, -2, -6							-- negative values treated as exceptions. Example: everyone except patriarch and archons
		--raceLimit = { 0, 1 },						-- 0 - Bellato, 1 - Cora, 2 - Accretia. If not set - all races allowed.
		--[[
		itemRequire = { -- entrance based on level/grade/upgarde of equipmnet
			_upper = { -- following are options. if any those satisfied then requirement passed.
				{
					grade = 0, -- 0 white 1, intense, ...
					lv = 50,
					upgLv = 5, -- Upgrade level (total inserted talik)
				},
				{
					grade = 1, -- 0 white 1, intense, ...
					lv = 45,
					upgLv = 3, -- Upgrade level (total inserted talik)
				},
			},
			_lower = {}, -- any unnecessary types can be removed
			_gloves = {}, -- empty table require any item to be equipped
			_shoes = {},
			_helmet = {},
			_shield = {},
			_weapon = {},
			_cloak = {},
		},
		]]--
		--[[
		itemConsume = { -- require/consume item(s)
			{
				itemCode = "irmap01",
				quantity = 1, -- if <= 0 or not set then item required to be in inventory/equipped but not consumed
			},
			{
				itemCode = "iwstb65",
			},
		},
		]]--
		--[[
		haveEffectRequire = { -- effects from resource item. [effect id] = comparison function with one argument (for example `v`) which is value of have effect with id `effect id`
			[0] = function(v) return v > 1.5 end, -- condition passed if have effect 0 value > 1.5
			[5] = function(v) return v >= -2.0 and v <= 0 end, -- condition passed if have effect 5 >= -2.0 and <= 0.0
		},
		]]--
		--costDalant = 0,
		--costGold = 0,
		--costProcessingPoint = 0,
		--costHuntingPoint = 0,
		--costGoldenPoint = 0,
		--costPvPCash = 0,
	},

	onCheckUseConditions = function (pLuaRift, pPlayer) -- must return true or false if player allowed or not allowed to use this rift
		return RiftMgr:canUseRift(pLuaRift, pPlayer) -- return error code. 0 - no error. 1-254 specific error codes which shown user automatically. 255 silent error code with no error display, suitable for cutom error messages.
	end,

	onUse = function (pLuaRift, pPlayer) -- what will happen after player pass condition check
		RiftMgr:onUse(pLuaRift, pPlayer)
	end,

	openSchedule = {
		-- one of following open types:
		--absolute = { -- (open once)
		--	year = 2023,
		--	month = 2, -- 1-Jan, 2-Feb ...
		--	day = 18, -- 1-31
		--	hour = 2, -- 0-23
		--	minute = 13, -- 0-59
		--	second = 0, -- 0-59
		--},
		-- or
		--[[
		after = { -- time since server startup (open once)
			year = 1, -- 365 days
			month = 2, -- 30 days
			day = 3,
			hour = 4,
			minute = 5,
			second = 6,
		},
		--]]
		-- or
		every = { -- (repeated open)
			-- one of following:
		--	dayOfMonth = {
		--		{
		--			val = 1, -- 1 - 31
		--			offset = {
		--				hour = 13,
		--				minute = 30,
		--			},
		--		},
				--[[
				{
					val = 15, -- 1 - 31
					offset = {
						hour = 13,
						minute = 30,
					},
				},
				--]]
		--	},
			-- or
			--[[
			dayOfWeek = {
				{
					val = 1, -- 1 - Sun, 2 - Mon ...
					offset = {
						hour = 13,
						minute = 30,
					},
				},
				{
					val = 4, -- 1 - Sun, 2 - Mon ...
					offset = {
						hour = 13,
						minute = 30,
					},
				},
			},
			--]]
			-- or
			--[[
			day = {
				{
					hour = 10,
					minute = 30,
				},
				{
					hour = 18,
					minute = 30,
				},
			},
			--]]
			-- or
			--[[
			hour = {
				val = 2, -- repeat in hours: every 1 hour, every 2 hours, 3, 4, 6, 8, 12. (24 % val == 0)
				offset = {
					hour = 13, -- hour < val
					minute = 30,
				},
			},
			--]]
			-- or	
			minute = {
				val = 5, -- repeat in minutes: every 1 minute, every 2 minutes ... (60 % val == 0)
				--offset = {
				--	minute = 30, -- minute < val
				--},
			},
		}
	},	

	closeSchedule = {
		--[[
		absolute = {
			year = 2023,
			month = 8,
			day = 15,
			hour = 15,
			minute = 59,
			second = 59,
		},
		--]]
		-- or	
		after = {
			--year = 1,
			--month = 2,
			--day = 3,
			--hour = 4,
			minute = 3,
			--second = 30,
		},
	},
},
}

return t
