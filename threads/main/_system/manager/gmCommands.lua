---@class (exact) sirinGMCommandsMgr
---@field m_pszModExtraGMCommandsLogPath string
---@field loadScripts fun(): boolean
local sirinGMCommandsMgr = {
	m_pszModExtraGMCommandsLogPath = '.\\sirin-log\\guard\\ModExtraGMCommands.log',
}

---@return boolean
function sirinGMCommandsMgr.loadScripts()
	local bSucc = false

	repeat
		SirinTmp_GMCommands = FileLoader.LoadChunkedTable(".\\sirin-lua\\threads\\main\\ReloadableScripts\\GMCommands")

		if not SirinTmp_GMCommands then
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Failed to load 'GMCommands' scripts!\n")
			Sirin.WriteA(sirinGMCommandsMgr.m_pszModExtraGMCommandsLogPath, "Failed to load 'GMCommands' scripts!\n", true, true)
			break
		end

		---@type table<string, fun(pOne?: CPlayer): boolean>
		local newCheatTable = {}

		for _,v in ipairs(SirinTmp_GMCommands) do
			repeat
				if type(v[1]) ~= "string" or type(v[2]) ~= "string" or type(v[3]) ~= "string" or type(v[4]) ~= "function" then
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Lua. sirinGMCommandsMgr.loadScripts() Invalid parameter given!\n")
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

		SirinScript_GMCommands = newCheatTable
		SirinTmp_GMCommands = nil
		bSucc = true
	until true

	return bSucc
end

return sirinGMCommandsMgr
