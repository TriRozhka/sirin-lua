--[[

Functions, which exists in native RF Online code. Monster related hooks.

--]]

---Purpose: Create monster notification.
---Hook positions: 'after_event'.
---@param pMonster CMonster
---@param pData _monster_create_setdata
local function CMonster__Create(pMonster, pData) end

---Purpose: Destroy monster notification.
---Hook positions: 'pre_event'.
---@param pMonster CMonster
---@param byDestroyCode integer
---@param pAttObj CGameObject
local function CMonster__Destroy(pMonster, byDestroyCode, pAttObj) end

---Purpose: Monster transport notification.
---Hook positions: 'after_event'.
---@param pMonster CMonster
---@param dwOldSerial integer
local function CMonsterHelper__TransPort(pMonster, dwOldSerial) end

---Purpose: Monster looting routine.
---Hook positions: 'original'.
---@param pMonster CMonster
---@param pOwner CPlayer
---@return boolean
local function CMonster___LootItem_Std(pMonster, pOwner) return false end
