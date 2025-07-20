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

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pKeeper CHolyKeeper
---@param nPart integer
---@return number
local function CHolyKeeper__GetDefGap(pKeeper, nPart) return 0.5 end

---Purpose: DefFacing script value return.
---Hook positions: 'original'
---@param pKeeper CHolyKeeper
---@param nPart integer
---@return number
local function CHolyKeeper__GetDefFacing(pKeeper, nPart) return 0.5 end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pKeeper CHolyKeeper
---@param nAttactPart integer
---@param pAttackerChar CCharacter
---@return integer #Err code
---@return integer #Def point
local function CHolyKeeper__GetDefFC(pKeeper, nAttactPart, pAttackerChar) return 0, 0 end

---Purpose: AttGap script value return.
---Hook positions: 'original'
---@param pKeeper CHolyKeeper
---@return integer
local function CHolyKeeper__GetWeaponAdjust(pKeeper) return 0.5 end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pStone CHolyStone
---@param nPart integer
---@return number
local function CHolyStone__GetDefGap(pStone, nPart) return 0.5 end

---Purpose: DefFacing script value return.
---Hook positions: 'original'
---@param pStone CHolyStone
---@param nPart integer
---@return number
local function CHolyStone__GetDefFacing(pStone, nPart) return 0.5 end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pStone CHolyStone
---@param nAttactPart integer
---@param pAttackerChar CCharacter
---@return integer #Err code
---@return integer #Def point
local function CHolyStone__GetDefFC(pStone, nAttactPart, pAttackerChar) return 0, 0 end

---Purpose: AttGap script value return.
---Hook positions: 'original'
---@param pStone CHolyStone
---@return integer
local function CHolyStone__GetWeaponAdjust(pStone) return 0.5 end