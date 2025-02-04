-- Require all combine function files 
local skin = require('Combine_Ex.skins')
local socketExt = require('Combine_Ex.socket_extender')
local example = require('Combine_Ex.combine_example')

local sirinCombineList = {}

-- Fast combination check functions
sirinCombineList.fastCheck = {
	skin.isSkinReplaceCombination,
	socketExt.combineChecker,
	--example.combineChecker,
}

-- Execute the combination
sirinCombineList.combineFunction = {
	skin.doSkinReplaceCombination,
	socketExt.combineWorker,
	--example.combineWorker,
}

-- Init (optional)
sirinCombineList.initFunction = {
	--example.init,
}

return sirinCombineList;
