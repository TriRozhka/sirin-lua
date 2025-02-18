local t = {
-- Example add cash potion
-- ipcsa01 = { 1, 999 }, -- Make sure you put comma.

-- Example add premium potion 7 days.
-- ipcsa02 = { 2, 7 },

-- Example add premium potion 300 seconds (5 minutes).
-- ipcsa03 = { 3, 300 },

-- Example summon monster potion.
-- ipcsa04 = { 4, { "00000", false, true, true, true } }, -- Read ModPotionEffect.lua for parameter description.

-- Example add/sub contribution points potion.
-- ipcsa05 = { 5, 999 },

-- Example add/sub pvp cash potion.
-- ipcsa06 = { 6, 999 },

-- Example add/sub race currency potion.
-- ipcsa07 = { 7, 999 },

-- Example add/sub gold currency potion,
-- ipcsa08 = { 8, 999 },

-- Example add/sub level potion
-- ipcsa09 = { 9, { 15, true } }, -- Read ModPotionEffect.lua for parameter description.

-- Example set level potion.
-- ipcsa10 = { 10, { 55, true, false } }, -- Read ModPotionEffect.lua for parameter description.

-- Exmaple buff/debuff skill potion.
-- ipcsa11 = { 11, { "AF000", true, 7 } }, -- Read ModPotionEffect.lua for parameter description.

-- Exmaple buff/debuff force potion.
-- ipcsa12 = { 12, { "8005", true, 7 } }, -- Read ModPotionEffect.lua for parameter description.

-- Exmaple buff/debuff class skill potion.
-- ipcsa13 = { 13, { "7F018", true, 7 } }, -- Read ModPotionEffect.lua for parameter description.

-- Exmaple buff/debuff bullet potion.
-- ipcsa14 = { 14, { "B", true, 2 } }, -- Read ModPotionEffect.lua for parameter description.

-- Example add/sub PT potion.
-- ipcsa15 = { 15, { 3, 10 } }, -- Read ModPotionEffect.lua for parameter description.

-- Example add/sub skill group mastery through skill potion.
-- ipcsa16 = { 16, { 13, 5 } }, -- Read ModPotionEffect.lua for parameter description.

-- Example add/sub force group mastery potion.
-- ipcsa17 = { 17, { 9, -15 } }, -- Read ModPotionEffect.lua for parameter description.

-- Example add/sub processing/hunting/golden point potion.
-- ipcsa18 = { 18, { 0, 999 } }, -- Read ModPotionEffect.lua for parameter description.

--[[
	---@param pActChar CCharacter
	---@param pTargetChar CCharacter
	---@return integer
	ipgld01 = function(pActChar, pTargetChar) -- Potion changes race and gender to bellato male and class to Warrior.
		return RaceSexClassUpdate(Sirin.mainThread.objectToPlayer(pTargetChar), 0, "BWB0")
	end,

	---@param pActChar CCharacter
	---@param pTargetChar CCharacter
	---@return integer
	ipgld02 = function(pActChar, pTargetChar) -- Gender switch potion
		local pPlayer = Sirin.mainThread.objectToPlayer(pTargetChar)
		local byRaceSexCode = pPlayer.m_Param.m_dbChar.m_byRaceSexCode

		if (byRaceSexCode & 1) == 1 then
			byRaceSexCode = byRaceSexCode & 0xFE
		else
			byRaceSexCode = byRaceSexCode + 1
		end

		return RaceSexClassUpdate(pPlayer, byRaceSexCode)
	end,

	---@param pActChar CCharacter
	---@param pTargetChar CCharacter
	---@return integer
	ipgld03 = function(pActChar, pTargetChar) -- default upper part cyclic change potion
		return BaseShapeUpdate(Sirin.mainThread.objectToPlayer(pTargetChar), TBL_CODE.face)
	end,
--]]
}
--[[
--- Move this function somewhere in your code
---@param pPlayer CPlayer
---@param byNewRaceSex integer
---@param strNewClassCode? string
---@return integer
function RaceSexClassUpdate(pPlayer, byNewRaceSex, strNewClassCode)
	local byErrCode = Sirin.mainThread.modRaceSexClassChange.updateRaceSexClass(pPlayer, byNewRaceSex, strNewClassCode)

	if byErrCode == 0 then
		Sirin.mainThread.modForceLogoutAfterUsePotion.s_bNeedForceLogout = true -- Used with potion only. For NPC button use `push lobby` GM command as example
	else
		if byErrCode < 10 then
		elseif byErrCode < 20 then
			if byErrCode == 11 then
				-- battle mode
			elseif byErrCode == 12 then
				-- trade mode
			elseif byErrCode == 13 then
				-- corpse state
			elseif byErrCode == 14 then
				-- on layered map
			elseif byErrCode == 15 then
				-- in dungeon
			elseif byErrCode == 16 then
				-- potion will have no effect (already applied)
			end
		elseif byErrCode < 30 then
			if byErrCode == 21 then
				-- nuclear attack effect active
			elseif byErrCode == 22 then
				-- in MAU / have summoned MAU
			elseif byErrCode == 23 then
				-- animus equipped
			elseif byErrCode == 24 then
				-- incompatible race equip detected
			elseif byErrCode == 25 then
				-- incompatible race accessory detected
			end
		elseif byErrCode < 40 then
			if byErrCode == 31 then
				-- in guild
			elseif byErrCode == 32 then
				-- is in active race boss group
			elseif byErrCode == 33 then
				-- is in next race boss group
			elseif byErrCode == 34 then
				-- is registered in race boss vote
			elseif byErrCode == 35 then
				-- have item on auction
			elseif byErrCode == 36 then
				-- incompatible race force reaver detected
			end
		elseif byErrCode >= 40 and byErrCode <= 100 then
			-- class init error
		elseif byErrCode > 100 then
			if byErrCode == 101 then
				-- invalid script data: racesexcode > 4
			elseif byErrCode == 102 then
				-- invalid script data: class code missing
			elseif byErrCode == 103 then
				-- invalid script data: class not found
			elseif byErrCode == 104 then
				-- invalid script data: not base class
			elseif byErrCode == 105 then
				-- invalid script data: class race is different from new race
			end
		end
	end

	return byErrCode
end

--- Move this function somewhere in your code
---@param pPlayer CPlayer
---@param part TBL_CODE
---@return integer
function BaseShapeUpdate(pPlayer, part)
	local byErrCode = 0

	if part > TBL_CODE.helmet and part ~= TBL_CODE.face then
		return 101
	end

	local byRaceSexCode = pPlayer.m_Param.m_dbChar.m_byRaceSexCode
	local dwBaseShape = 0

	for i = 0, 4 do
		if i == part then
			local index = pPlayer.m_Param.m_dbChar:m_byDftPart_get(i) - byRaceSexCode * 16
			index = index + 1
			index = index % 5
			dwBaseShape = dwBaseShape + (index << (4 * i))
		else
			dwBaseShape = dwBaseShape + (0xF << (4 * i))
		end
	end

	if part == TBL_CODE.face then
		local index = pPlayer.m_Param.m_dbChar.m_byDftPart_Face - byRaceSexCode * 16
		index = index + 1
		index = index % 5
		dwBaseShape = dwBaseShape + (index << 20)
	else
		dwBaseShape = dwBaseShape + (0xF << 20)
	end

	byErrCode = Sirin.mainThread.modRaceSexClassChange.updateBaseShape(pPlayer, dwBaseShape)

	if byErrCode == 1 then
		-- New shape is same with old shape
	elseif byErrCode == 2 then
		-- Changing is part equipped
	elseif byErrCode == 101 then
		-- invalid part index
	end

	return byErrCode
end
--]]

return t
