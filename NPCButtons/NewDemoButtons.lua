local t = {
[167] = { -- first button index that not exists ins GU is 164, AoP - 167
	actionType = 0,
	clientName = {
		default = "button name",
	},
	-- color = 0xFFE8E8E8, -- Optional color in ARGB format
	data = function(pPlayer) end, -- custom function to be called
}, -- dont forget separating comma

[168] = {
	actionType = 1,
	clientName = {
		default = "Other name",
	},
	-- color = 0xFFE8E8E8, -- Optional color in ARGB format
	data = 1, -- combine table recipe index for exachange
}, -- dont forget separating comma

[169] = {
	actionType = 2,
	clientName = {
		default = "Buff button renamed",
	},
	-- color = 0xFFE8E8E8, -- Optional color in ARGB format
	data = { -- list of buffs
		{
			skillType = 1, -- 0 - skill, 1 - force, 2 - class skill, 3 - bullet
			id = "8005", -- Dark velocity
			overrideExisting = false, -- optional allow to rebuff if already have same effect applied
			lv = 7, -- [1 to 7] 7 is GM
			-- durSec = 10000, -- optional duration
			description = { -- optional
				default = "description line 1\ndescription line 2\ndescription line 3",
			},
			conditions = { -- optional parameter. each of the following parameters are optional
				premiumUser = true,
				minLevel = 45,
				maxLevel = 55,
				rank = 0, -- [0 to 7] CPT rank
				item = {
					{
						code = "irjad01",
						consumeNum = 0, -- if 0 item must present but not consumed
					},
				},
				money = {
					currency = 0, -- 0 dalant, 1 gold, 2 pvp cash, 3 cpt, 4 processing point, 5 huncting point, 6 golden point
					value = 500,
				},
			}
		},
		{
			skillType = 1, -- 0 - skill, 1 - force, 2 - class skill, 3 - bullet
			id = "7105", -- Holy velocity
			overrideExisting = false, -- optional allow to rebuff if already have same effect applied
			lv = 7, -- [1 to 7] 7 is GM
			-- durSec = 10000, -- optional duration override
			description = { -- optional
				default = "description line 1\ndescription line 2\ndescription line 3",
			},
			conditions = { -- optional parameter. each of the following parameters are optional
				premiumUser = true,
				minLevel = 45,
				maxLevel = 55,
				rank = 0, -- [0 to 7] CPT rank
				item = {
					{
						code = "irjad01",
						consumeNum = 0, -- if 0 item must present but not consumed
					},
				},
				money = {
					currency = 0, -- 0 dalant, 1 gold, 2 pvp cash, 3 cpt, 4 processing point, 5 huncting point, 6 golden point
					value = 500,
				},
			}
		},
	},
}, -- dont forget trailing comma
}

return t
