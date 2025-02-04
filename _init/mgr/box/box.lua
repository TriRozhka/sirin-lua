---@class (exact) SirinBoxOpen
---@field __index table
---@field pszModBoxOpenLogPath string
local SirinBoxOpen = {
	pszModBoxOpenLogPath = '.\\sirin-log\\guard\\ModBoxOpen.log',
}

---@return SirinBoxOpen self
function SirinBoxOpen:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

BoxOpenMgr = SirinBoxOpen:new()

---@return boolean
function SirinBoxOpen:loadScripts()
	return Sirin.mainThread.modBoxOpen.loadScripts()
end

---@return boolean
function SirinBoxOpen:loadFiles()
	local bSucc = true

	repeat
		TmpBoxItemOut = FileLoader.LoadChunkedTable(".\\sirin-lua\\BoxItemOut")

		if not TmpBoxItemOut then
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Failed to load 'BoxItemOut' scripts!\n")
			Sirin.WriteA(self.pszModBoxOpenLogPath, "Failed to load 'BoxItemOut' scripts!\n", true, true)
			bSucc = false
			break
		end

	until true

	return bSucc
end