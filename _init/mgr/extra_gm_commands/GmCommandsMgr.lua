---@class (exact) ExtraGmCommands
---@field __index table
---@field pszModExtraGMCommandsLogPath string
local ExtraGmCommands = {
	pszModExtraGMCommandsLogPath = '.\\sirin-log\\guard\\ModExtraGMCommands.log',
}

---@return ExtraGmCommands self
function ExtraGmCommands:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

GmCommMgr = ExtraGmCommands:new()

---@return boolean
function ExtraGmCommands:loadScripts()
	local bSucc = false

	repeat
		TmpGMCommands = FileLoader.LoadChunkedTable(".\\sirin-lua\\GMCommands")

		if not TmpGMCommands then
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Failed to load 'GMCommands' scripts!\n")
			Sirin.WriteA(self.pszModExtraGMCommandsLogPath, "Failed to load 'GMCommands' scripts!\n", true, true)
			break
		end

		---@type table<string, fun(pOne?: CPlayer): boolean>
		local newCheatTable = {}

		for _,v in ipairs(TmpGMCommands) do
			repeat
				if type(v[1]) ~= "string" or type(v[2]) ~= "string" or type(v[3]) ~= "string" or type(v[4]) ~= "function" then
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "ExtraGmCommands:loadScripts() Invalid parameter given!\n")
					dump(v)
					break
				end

				repeat
					if not Sirin.mainThread.registCheat(v[1], v[2], v[3]) then
						Sirin.mainThread.unregistCheat(v[1])

						if not Sirin.mainThread.registCheat(v[1], v[2], v[3]) then
							break
						end
					end

					newCheatTable[v[1]] = v[4]
				until true
			until true
		end

		ScriptGMCommands = newCheatTable
		TmpGMCommands = nil
		bSucc = true
	until true

	return bSucc
end
