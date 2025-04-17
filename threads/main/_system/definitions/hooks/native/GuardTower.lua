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
