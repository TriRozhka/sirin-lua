
local projectName = 'sirin'
local moduleName = 'Sirin_HaveEffectLimiter'

local script = {
	m_strUUID = projectName .. ".lua." .. moduleName,
	m_EffMax_41 = 2.0
}

---@param pPlayer CPlayer
local function checkLimits(pPlayer)
	local EP = pPlayer.m_EP.m_pDataParamExt -- use Ext version when ModEffectParamExt enabled or you will crash server.
	local diff = script.m_EffMax_41 - EP:m_fEff_Have_get(41) -- since bAdd = false reserved in apply_have_item_std_effect(...) we add negative value to reduce effect.

	if diff < 0 then
		 EP:m_fEff_Have_set(41, script.m_EffMax_41) -- have value must be updated before calling apply_have_item_std_effect(..., true, ...)
		pPlayer:apply_have_item_std_effect(41, diff, true, 0)
	end
end

---@param pPlayer CPlayer
---@param bLogin boolean
function script.CPlayer__SetHaveEffect(pPlayer, bLogin)
	checkLimits(pPlayer)
end

---@param pPlayer CPlayer
---@param pFld _ResourceItem_fld
---@param pItem _STORAGE_LIST___db_con
---@param bAdd boolean
---@param nAlter integer
function script.CPlayer__SetMstHaveEffect(pPlayer, pFld, pItem, bAdd, nAlter)
	checkLimits(pPlayer)
end

function script.onThreadBegin()
end

function script.onThreadEnd()
end

local function autoInit()
	if not _G[moduleName] then
		_G[moduleName] = script
		table.insert(SirinLua.onThreadBegin, function() _G[moduleName].onThreadBegin() end)
		table.insert(SirinLua.onThreadEnd, function() _G[moduleName].onThreadEnd() end)
	else
		_G[moduleName] = script
	end

	SirinLua.HookMgr.releaseHookByUID(script.m_strUUID)
	SirinLua.HookMgr.addHook("CPlayer__SetHaveEffect", HOOK_POS.after_event, script.m_strUUID, script.CPlayer__SetHaveEffect)
	SirinLua.HookMgr.addHook("CPlayer__SetMstHaveEffect", HOOK_POS.after_event, script.m_strUUID, script.CPlayer__SetMstHaveEffect)
end

autoInit()
