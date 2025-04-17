--[[

Functions, which exists in native RF Online code. Darkhole dungeon related hooks.

--]]

---Purpose: Open darkhole result notification.
---Hook positions: 'after_event'.
---@param pPlayer CPlayer
---@param bOpen boolean
---@param pFld _base_fld
---@param uuid string
local function CPlayer__pc_DarkHoleOpenRequest(pPlayer, bOpen, pFld, uuid) end

---Purpose: Close darkhole result notification.
---Hook positions: 'after_event'.
---@param uuid string
---@param bSucc boolean
local function CDarkHoleChannel__SendMsg_ChannelClose(uuid, bSucc) end
