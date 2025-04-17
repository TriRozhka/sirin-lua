--[[

Functions, which exists in native RF Online code. Crystal battle related hooks.

--]]

---Purpose: Change battle scene notification.
---Hook positions: 'after_event'.
---@param pHolySys CHolyStoneSystem
---@param byNumOfTime integer
---@param nSceneCode integer
---@param nPassTime integer
---@param nChangeReason integer
local function CHolyStoneSystem__SetScene(pHolySys, byNumOfTime, nSceneCode, nPassTime, nChangeReason) end

---Purpose: Chip holder arrive succ/failure notification.
---Hook positions: 'after_event'.
---@param pHolySys CHolyStoneSystem
---@param byArrive integer
local function CHolyStoneSystem__SendIsArriveDestroyer(pHolySys, byArrive) end

---Purpose: Holy stone destroy notification.
---Hook positions: 'after_event'.
---@param pStone CHolyStone
---@param byDestroyCode integer
---@param pAtter CCharacter
local function CHolyStone__Destroy(pStone, byDestroyCode, pAtter) end
