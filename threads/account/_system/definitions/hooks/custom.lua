--[[

New functions, added in Sirin guard, and not exists in native RF Online code.

--]]

---Purpose: notification for response of Zone's CMainThread::pc_TransIPKeyInform
---Hook positions: 'after_event'
---@param uuid string
---@param retCode integer
---@param serial integer
---@param key_1 integer
---@param key_2 integer
---@param key_3 integer
---@param key_4 integer
local function transAccountReport(uuid, retCode, serial, key_1, key_2, key_3, key_4) end
