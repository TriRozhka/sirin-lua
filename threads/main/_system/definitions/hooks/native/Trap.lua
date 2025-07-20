--[[

Functions, which exists in native RF Online code. Guard tower related hooks.

--]]


---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pTrap CTrap
---@param nPart integer
---@return number
local function CTrap__GetDefGap(pTrap, nPart) return 0.5 end

---Purpose: DefFacing script value return.
---Hook positions: 'original'
---@param pTrap CTrap
---@param nPart integer
---@return number
local function CTrap__GetDefFacing(pTrap, nPart) return 0.5 end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pTrap CTrap
---@param nAttactPart integer
---@param pAttackerChar CCharacter
---@return integer #Err code
---@return integer #Def point
local function CTrap__GetDefFC(pTrap, nAttactPart, pAttackerChar) return 0, 0 end

---Purpose: AttGap script value return.
---Hook positions: 'original'
---@param pTrap CTrap
---@return integer
local function CTrap__GetWeaponAdjust(pTrap) return 0.5 end