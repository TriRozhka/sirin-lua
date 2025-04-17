--[[

Functions, which exists in native RF Online code. Quest related hooks.

--]]

---Purpose: Start new quest notification.
---Hook positions: 'pre_event'
---@param pPlayer CPlayer
---@param bySlotIndex integer
---@param pQuestDB _QUEST_DB_BASE___LIST
local function CPlayer__SendMsg_InsertNewQuest(pPlayer, bySlotIndex, pQuestDB) end

---Purpose: Start next quest notification.
---Hook positions: 'pre_event'
---@param pPlayer CPlayer
---@param bySlotIndex integer
---@param pQuestDB _QUEST_DB_BASE___LIST
local function CPlayer__SendMsg_InsertNextQuest(pPlayer, bySlotIndex, pQuestDB) end

---Purpose: Remove quest notification.
---Hook positions: 'pre_event'
---@param pPlayer CPlayer
---@param byFailCode integer
---@param byQuestDBSlot integer
local function CPlayer__SendMsg_QuestFailure(pPlayer, byFailCode, byQuestDBSlot) end

---Purpose: User cancel quest quest notification.
---Hook positions: 'pre_event'
---@param pPlayer CPlayer
---@param byQuestDBSlot integer
local function CPlayer__pc_QuestGiveupRequest(pPlayer, byQuestDBSlot) end

---Purpose: Check can cancel quest routine.
---Hook positions: 'original'
---@param pQuestMgr CQuestMgr
---@param byQuestDBSlot integer
---@return boolean
local function CQuestMgr__CanGiveupQuest(pQuestMgr, byQuestDBSlot) return false end

---Purpose: Reward quest notification and routine.
---Hook positions: 'pre_event, original'
---@param pPlayer CPlayer
---@param pQuestFld _Quest_fld
---@param byRewardItemIndex integer
---@return _base_fld? #next quest selected by reward or nil
local function CPlayer___Reward_Quest(pPlayer, pQuestFld, byRewardItemIndex) return nil end

---Purpose: Check quest condition routine.
---Hook positions: 'original'
---@param pQuestMgr CQuestMgr
---@param pCond _happen_event_condition_node
---@return boolean
local function CQuestMgr___CheckCondition(pQuestMgr, pCond) return false end

---Purpose: Create list of available quests for NPC.
---Hook positions: 'original'
---@param pQuestMgr CQuestMgr
---@param pszEventCode string
---@param byRaceCode integer
---@param pQuestIndexData _NPCQuestIndexTempData
local function CQuestMgr__CheckNPCQuestList(pQuestMgr, pszEventCode, byRaceCode, pQuestIndexData) end

---Purpose: Check selected NPC quest is startable.
---Hook positions: 'original'
---@param pQuestMgr CQuestMgr
---@param pszEventCode? string
---@param byRaceCode integer
---@param dwQuestIndex integer
---@param dwHappenIndex integer
---@return boolean
local function CQuestMgr__CheckNPCQuestStartable(pQuestMgr, pszEventCode, byRaceCode, dwQuestIndex, dwHappenIndex) return false end

---Purpose: Take NPC quest routine.
---Hook positions: 'original'
---@param pQuestMgr CQuestMgr
---@param pStore? CItemStore
---@param dwNPCQuestIndex integer
local function CPlayer__pc_RequestQuestFromNPC(pQuestMgr, pStore, dwNPCQuestIndex) end

---Purpose: Quest success complete notification.
---Hook positions: 'pre_event'
---@param pPlayer CPlayer
---@param byQuestDBSlot integer
local function CPlayer__SendMsg_QuestComplete(pPlayer, byQuestDBSlot) end

---Purpose: Quest conditions check routine.
---Hook positions: 'original'
---@param pQuestMgr CQuestMgr
---@param nActCode integer
---@param pszReqCode integer
---@param wActCount integer
---@param bPartyState boolean
---@return _quest_check_result?
local function CQuestMgr__CheckReqAct(pQuestMgr, nActCode, pszReqCode, wActCount, bPartyState) return nil end

---Purpose: Quest one second loop notify.
---Hook positions: 'pre_event'
---@param pQuestMgr CQuestMgr
local function CQuestMgr__Loop(pQuestMgr) end
