--[[

Functions, which exists in native RF Online code. Store related hooks.

--]]

---Purpose: Filter purchase requests.
---Hook positions: 'filter'.
---@param pStore CItemStore
---@param pPlayer CPlayer
---@param offer table<integer, _buy_offer>
---@param fDiscountRate number
---@return boolean
local function CItemStore__IsSell(pStore, pPlayer, offer, fDiscountRate) return true end

---Purpose: NPC store purchase notification.
---Hook positions: 'pre_event'.
---@param pPlayer CPlayer
---@param pStore CItemStore
---@param offer table<integer, _buy_offer>
---@param byErrCode integer
local function CPlayer__SendMsg_BuyItemStoreResult(pPlayer, pStore, offer, byErrCode) end
