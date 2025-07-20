--[[

Functions, which exists in native RF Online code. Guard tower related hooks.

--]]

---Purpose: Tower target search routine.
---Hook positions: 'original'.
---@param pTower CGuardTower
---@return CCharacter?
local function CGuardTower__SearchNearEnemy(pTower) return nil end

---Purpose: Tower target validation routine.
---Hook positions: 'original'.
---@param pTower CGuardTower
---@return boolean
local function CGuardTower__IsValidTarget(pTower) return false end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pTower CGuardTower
---@param nPart integer
---@return number
local function CGuardTower__GetDefGap(pTower, nPart) return 0.5 end

---Purpose: DefFacing script value return.
---Hook positions: 'original'
---@param pTower CGuardTower
---@param nPart integer
---@return number
local function CGuardTower__GetDefFacing(pTower, nPart) return 0.5 end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pTower CGuardTower
---@param nAttactPart integer
---@param pAttackerChar CCharacter
---@return integer #Err code
---@return integer #Def point
local function CGuardTower__GetDefFC(pTower, nAttactPart, pAttackerChar) return 0, 0 end

---Purpose: AttGap script value return.
---Hook positions: 'original'
---@param pTower CGuardTower
---@return integer
local function CGuardTower__GetWeaponAdjust(pTower) return 0.5 end