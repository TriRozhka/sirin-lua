local t = {
	[1] = { -- [1] window with index 1 is always function window
		name = {
			default = "Function window",
		},
		-- 12 entiries - requires 12 state flags
		data = {
			{
				icon = { 4, 13, 4, 0 },
				clientWindow = 1, -- CHAR INFO
				-- customWindow = 2, -- Optional. 2-... for client custom windows (this script windows) instant open.
				-- raceLimit = { 0, 1, 2 },  -- Optional.
				-- raceBoss = { 0, 1, 2, 3, 4, 5, 6, 7, 8 },  -- Optional.
				-- guildGrade = { 1, 2 },  -- Optional.
				-- isGM = false,  -- Optional.
				-- isPremium = false,  -- Optional.
			},
			{
				icon = { 4, 13, 12, 0 },
				clientWindow = 2, -- INVENTORY
			},
			{
				icon = { 4, 13, 5, 0 },
				clientWindow = 3, -- SKILL
			},
			{
				icon = { 4, 13, 6, 0 },
				clientWindow = 4, -- FORCE
			},
			{
				icon = { 4, 13, 7, 0 },
				raceLimit = { 1 },
				clientWindow = 5, -- SUMMON (CORA ONLY)
			},
			{
				icon = { 4, 13, 11, 0 },
				clientWindow = 6, -- MACRO
			},
			{
				icon = { 4, 13, 8, 0 },
				clientWindow = 7, -- PARTY
			},
			{
				icon = { 4, 13, 9, 0 },
				clientWindow = 8, -- GUILD
			},
			{
				icon = { 4, 13, 13, 0 },
				clientWindow = 9, -- MAIL
			},
			{
				icon = { 4, 13, 14, 0 },
				clientWindow = 10, -- REP BELLATO
				raceLimit = { 0 },
				raceBoss = { 0, 1, 5 },
			},
			{
				icon = { 4, 13, 15, 0 },
				clientWindow = 10, -- REP CORA
				raceLimit = { 1 },
				raceBoss = { 0, 1, 5 },
			},
			{
				icon = { 4, 13, 16, 0 },
				clientWindow = 10, -- REP ACCRETIA
				raceLimit = { 2 },
				raceBoss = { 0, 1, 5 },
			},
			{
				icon = { 8, 0, 7, 1 },
				clientWindow = 49, -- REMAIN ORE
			},
			{
				-- VISIBLE TO GM ONLY
				icon = { 4, 13, 3, 0 },
				customWindow = 2,
				isGM = true
			},
		},
	},
	[2] = {
		name = {
			default = "Custom window",
		},
		width = 400,
		height = 250,
		layout = { 50, 50, 50, 0 }, -- column width
		headerWindowID = 0, -- Optional
		footerWindowID = 0, -- Optional
		strModal_Ok = { -- optional.
			default = "OK",
		},
		strModal_Cancel = { -- optional.
			default = "Cancel",
		},
		strModal_Text = { -- optional.
			default = "Are you sure? ",
		},
		overlayIcons = { -- optional. max 32
			{ 8, 0, 19, 295 },
			{ 23, 3, 9, 0 },
			{ 0, 0, 0, 0 },
			{ 0, 0, 0, 0 },
		},
		data = {
			{
				icon = { 8, 0, 26, 183 },
				description = { -- Optional.
					default = "custom tooltip",
				},
				durability = 0, -- Optional.
				tooltip = { -- Optional.
					name = {
						text = {
							default = "Pseudo name",
						},
						color = 0xFF00FF00,
					},
					info = {
						default = {
							{ "Left 1", "Right 1" },
							{ "Left 2", "Right 2" },
							{ "Left 3", "Right 3" },
						},
					},
				},
			},
			{
				item = "iwswd45",
				upgrade = 0x7FFF0000,
				durability = 0, -- Optional
			},
			{
				icon = { 8, 0, 26, 195 },
				description = {
					default = "on hover text",
				},
			},
			{
				text = {
					default = "Text Button",
				},
			},
		},
	},
}

return t