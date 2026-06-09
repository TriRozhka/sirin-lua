--[[

Functions, which exists in native RF Online code. History and logs related hooks.

--]]


---Purpose: Hook on logging item add reward.
---Hook positions: 'after_event'
---@param pHistory CMgrAvatorItemHistory
---@param nIndex integer [0 - 2531]
---@param pszClause string
---@param pItem _STORAGE_LIST___db_con
---@param pszFileName string
---@param nSecretNum? integer AoP Only
local function CMgrAvatorItemHistory__reward_add_item(pHistory, nIndex, pszClause, pItem, pszFileName, nSecretNum) end

---Purpose: Hook on logging hero combine add reward.
---Hook positions: 'after_event'
---@param pHistory CMgrAvatorItemHistory
---@param nIndex integer [0 - 2531]
---@param byMakeNum integer
---@param pCombineDB _ITEMCOMBINE_DB_BASE
---@param luaRewardTypeList table<integer, integer> type 1 - add to inven; type 2 - drop on ground.
---@param luaUIDs table<integer, integer>
---@param strFileName string
local function CMgrAvatorItemHistory__combine_ex_reward_item(pHistory, nIndex, byMakeNum, pCombineDB, luaRewardTypeList, luaUIDs, strFileName) end

---Purpose: Hook on logging hero combine consume materials.
---Hook positions: 'after_event'
---@param pHistory CMgrAvatorItemHistory
---@param nIndex integer [0 - 2531]
---@param dwCheckKey integer
---@param bySlotNum integer
---@param luaMaterials table<integer, _STORAGE_LIST___db_con>
---@param luaMatNum table<integer, integer>
---@param dwFee integer
---@param strFileName string
---@param nSucc integer
---@param dwFailCount integer
local function CMgrAvatorItemHistory__combine_ex_using_material(pHistory, nIndex, dwCheckKey, bySlotNum, luaMaterials, luaMatNum, dwFee, strFileName, nSucc, dwFailCount) end