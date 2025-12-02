--[[

Functions, which exists in native RF Online code. Darkhole dungeon related hooks.

--]]

---Purpose: Open darkhole result notification.
---Hook positions: 'after_event'.
---@param pPlayer CPlayer
---@param pChannel CDarkHoleChannel
---@param strUUID string
---@param pFldKey _base_fld
local function onDungeonOpen(pPlayer, pChannel, strUUID, pFldKey) end

---Purpose: Pass dungeon notification.
---Hook positions: 'pre_event'.
---@param pChannel CDarkHoleChannel
---@param strUUID string
---@param pFldKey _base_fld
local function onDungeonSuccess(pChannel, strUUID, pFldKey) end

---Purpose: Close darkhole result notification.
---Hook positions: 'pre_event'.
---@param pChannel CDarkHoleChannel
---@param strUUID string
---@param bSucc boolean
local function onDungeonClose(pChannel, strUUID, bSucc) end
