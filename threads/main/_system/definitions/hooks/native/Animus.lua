--[[

Functions, which exists in native RF Online code. Animus related hooks.

--]]

---Purpose: calculate animus attack exp.
---Hook positions: 'original'
---@param pAnimus CAnimus
---@param pAT CAttack
local function CAnimus__CalcAttExp(pAnimus, pAT) end

---Purpose: alter value of added animus exp.
---Hook positions: 'special'
---@param pAnimus CAnimus
---@param nAddExp integer
---@return integer New exp value
local function CAnimus__AlterExp(pAnimus, nAddExp)
	-- Do not call pAnimus:AlterExp(...) during this function call!
	return nAddExp
end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pAnimus CAnimus
---@param nPart integer
---@return number
local function CAnimus__GetDefGap(pAnimus, nPart) return 0.5 end

---Purpose: DefFacing script value return.
---Hook positions: 'original'
---@param pAnimus CAnimus
---@param nPart integer
---@return number
local function CAnimus__GetDefFacing(pAnimus, nPart) return 0.5 end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pAnimus CAnimus
---@param nAttactPart integer
---@param pAttackerChar CCharacter
---@return integer #Err code
---@return integer #Def point
local function CAnimus__GetDefFC(pAnimus, nAttactPart, pAttackerChar) return 0, 0 end

---Purpose: AttGap script value return.
---Hook positions: 'original'
---@param pAnimus CAnimus
---@return integer
local function CAnimus__GetWeaponAdjust(pAnimus) return 0.5 end