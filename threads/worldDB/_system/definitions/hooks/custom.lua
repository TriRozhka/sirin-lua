--[[

New functions, added in Sirin guard, and never existed in native RF Online code.

--]]

---Purpose: Prepare avator load notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
local function SirinWorldDB_UserLoad(dwAvatorSerial) end

---Purpose: Prepare avator logout notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
local function SirinWorldDB_UserLogout(dwAvatorSerial) end

---Purpose: Prepare avator move lobby notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
local function SirinWorldDB_UserLobby(dwAvatorSerial) end

---Purpose: Prepare avator update notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
local function SirinWorldDB_UserUpdate(dwAvatorSerial) end
