--[[

New functions, added in Sirin guard, and never existed in native RF Online code.

--]]

---Purpose: Operations with database on server startup.
---Hook positions: 'filter'
---@return boolean
local function checkDatabase() return true end

---Purpose: Post insert avator routine notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
local function SirinWorldDB_PlayerInsert(dwAvatorSerial)  end

---Purpose: Post delete avator routine notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
local function SirinWorldDB_PlayerDelete(dwAvatorSerial) end

---Purpose: Post load avator routine notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
---@param dwAccountSerial integer
---@param multiSQLResultSet CMultiSQLResultSet
local function SirinWorldDB_PlayerLoad(dwAvatorSerial, dwAccountSerial, multiSQLResultSet) end

---Purpose: Post logout avator routine notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
---@param multiBinaryData CMultiBinaryData
local function SirinWorldDB_PlayerLogout(dwAvatorSerial, multiBinaryData) end

---Purpose: Post lobby move avator routine notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
---@param multiBinaryData CMultiBinaryData
local function SirinWorldDB_PlayerLobby(dwAvatorSerial, multiBinaryData) end

---Purpose: Post update avator routine notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
---@param multiBinaryData CMultiBinaryData
local function SirinWorldDB_PlayerUpdate(dwAvatorSerial, multiBinaryData) end