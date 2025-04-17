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
