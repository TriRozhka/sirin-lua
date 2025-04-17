--[[

Functions, which exists in native RF Online code. Potion effect related hooks.

--]]

---Purpose: Trunk extend potion routine.
---Hook positions: 'original'
---@param pActChar CCharacter
---@param pTargetChar CCharacter
---@param fEffectValue number
---@return boolean #Result
---@return integer #Error code
local function DE_Potion_Trunk_Extend(pActChar, pTargetChar, fEffectValue) return true, 0 end
