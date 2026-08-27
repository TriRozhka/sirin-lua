--[[

Functions, which exists in native RF Online code. Cashshop related hooks.

--]]

---Purpose: Inform cash shop purchase result.
---Hook positions: 'after_event'.
---@param pPlayer CPlayer
---@param pItem _param_cash_update____item
---@param Ret boolean
local function CashDbWorker___insert_to_inven(pPlayer, pItem, Ret) end

---Purpose: Filter cash shop purchase.
---Hook positions: 'filter'.
---@param pCashItemStore CashItemRemoteStore
---@param wSock integer player index
---@param pRecv _request_csi_buy_clzo
---@return boolean
local function CashItemRemoteStore__BuyByCash(pCashItemStore, wSock, pRecv) return true end