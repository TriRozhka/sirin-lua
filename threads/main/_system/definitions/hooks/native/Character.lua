--[[

Functions, which exists in native RF Online code. Character related hooks.

--]]

---Purpose: Apply continuing force effect result notification.
---Hook positions: 'after_event'.
---@param pSrcChar CCharacter
---@param pDstChar CCharacter
---@param pForceFld _force_fld
---@param nForceLv integer
---@param byErrorCode integer
---@param bUpMty boolean
---@param bRet boolean
local function CCharacter__AssistForce(pSrcChar, pDstChar, pForceFld, nForceLv, byErrorCode, bUpMty, bRet) end

---Purpose: Apply continuing force effect result notification.
---Hook positions: 'after_event'.
---@param pSrcChar CCharacter
---@param pDstChar CCharacter
---@param pForceFld _force_fld
---@param nForceLv integer
---@param bRet boolean
local function CCharacter__AssistForceToOne(pSrcChar, pDstChar, pForceFld, nForceLv, bRet) end

---Purpose: Apply continuing skill effect result notification.
---Hook positions: 'after_event'.
---@param pSrcChar CCharacter
---@param pDstChar CCharacter
---@param nEffectCode integer
---@param pSkillFld _skill_fld
---@param nSkillLv integer
---@param byErrorCode integer
---@param bUpMty boolean
---@param bRet boolean
local function CCharacter__AssistSkill(pSrcChar, pDstChar, nEffectCode, pSkillFld, nSkillLv, byErrorCode, bUpMty, bRet) end

---Purpose: Apply continuing skill effect result notification.
---Hook positions: 'after_event'.
---@param pSrcChar CCharacter
---@param pDstChar CCharacter
---@param nEffectCode integer
---@param pSkillFld _skill_fld
---@param nSkillLv integer
---@param bRet boolean
local function CCharacter__AssistSkillToOne(pSrcChar, pDstChar, nEffectCode, pSkillFld, nSkillLv, bRet) end

---Purpose: apply damage event.
---Hook positions: 'after_event'.
---@param pDstChar CCharacter
---@param byContCode integer
---@param byEffectCode integer
---@param dwEffectIndex integer
---@param wDurSec integer
---@param byLv integer
---@param bUpMty boolean
---@param pSrcChar CCharacter
---@param byRet integer
local function CCharacter__InsertSFContEffect(pDstChar, byContCode, byEffectCode, dwEffectIndex, wDurSec, byLv, bUpMty, pSrcChar, byRet) end