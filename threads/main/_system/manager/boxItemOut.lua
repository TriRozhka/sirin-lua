---@class (exact) sirinBoxOpenMgr
---@field m_pszModBoxOpenLogPath string
---@field loadScripts fun(): boolean
---@field loadFiles fun(): boolean
local sirinBoxOpenMgr = {
	m_pszModBoxOpenLogPath = '.\\sirin-log\\guard\\ModBoxOpen.log',
}

---@return boolean
function sirinBoxOpenMgr.loadScripts()
	return Sirin.mainThread.modBoxOpen.loadScripts()
end

---@return boolean
function sirinBoxOpenMgr.loadFiles()
	local bSucc = true

	repeat
		SirinTmp_BoxItemOut = FileLoader.LoadChunkedTable(".\\sirin-lua\\threads\\main\\ReloadableScripts\\BoxItemOut")

		if not SirinTmp_BoxItemOut then
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Failed to load 'BoxItemOut' scripts!\n")
			Sirin.WriteA(sirinBoxOpenMgr.m_pszModBoxOpenLogPath, "Failed to load 'BoxItemOut' scripts!\n", true, true)
			bSucc = false
			break
		end

	until true

	return bSucc
end

return sirinBoxOpenMgr
