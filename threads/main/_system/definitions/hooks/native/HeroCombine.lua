--[[

Functions, which exists in native RF Online code. Hero combine related hooks.

--]]

---Purpose: Lua process of unknown hero combination.
---Hook positions: 'original'.
---@param pPlayer CPlayer
---@param pRecv _combine_ex_item_request_clzo
local function CPlayer__pc_CombineItemEx(pPlayer, pRecv) end

---Purpose: Select combine reward notification.
---Hook positions: 'after_event'.
---@param pPlayer CPlayer
---@param Selected table<integer, integer>
local function ItemCombineMgr__RequestCombineAcceptProcess(pPlayer, Selected) end

---Purpose: Make new items in result of combination.
---Hook positions: 'original, after_event'.
---@param pCombineMgr ItemCombineMgr
---@param pPlayerItemDB _ITEMCOMBINE_DB_BASE
---@param pRecv _combine_ex_item_accept_request_clzo
---@param Ret integer Error code provided in after_event hooks
---@return integer #return required for original hook only
local function ItemCombineMgr__MakeNewItems(pCombineMgr, pPlayerItemDB, pRecv, Ret) return 0 end
