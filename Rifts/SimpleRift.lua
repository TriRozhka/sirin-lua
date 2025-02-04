local t = {
simpleRift = {
    portalType = 0,
    srcMap = "NeutralC",
	srcPos = {
		{7065, -154, 1169, 0},
	},
	dstMap = "NeutralC",
	dstPos = {
		{7475, -157, 1306, 0},
	},

    onOpen = function (pLuaRift)
		local announceMsg = { 
			default = "Simple Rift just opened",
		}
		NetMgr.SendGlobalChatData(announceMsg, CHAT_TYPE.System, ANN_TYPE.mid3, nil, 0x00FFFF00)
	end,

    onClose = function (pLuaRift)
		local announceMsg = { 
			default = "Simple Rift closed",
		}
		NetMgr.SendGlobalChatData(announceMsg, CHAT_TYPE.System, ANN_TYPE.mid3, nil, 0x00FFFF00)
	end,

    onCheckUseConditions = function (pLuaRift, pPlayer)
		return RiftMgr:canUseRift(pLuaRift, pPlayer)
	end,

	onUse = function (pLuaRift, pPlayer)
		RiftMgr:onUse(pLuaRift, pPlayer)
	end,

    openSchedule = {
        every = {
            minute = {
				val = 3,
			},
        }
    },

    closeSchedule = {
		after = {
			minute = 1,
		},
	},
},
}

return t
