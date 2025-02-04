
local t = {
{ "town", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		local pMap, x, y, z = Sirin.mainThread.g_MapOper:GetPosStartMap(pPlayer:GetObjRace(), false)

		if pMap ~= nil then
			Sirin.mainThread.teleportPlayer(pPlayer, pMap, x, y, z, 0)
			return true
		else
			return false
		end
	end
}, -- dont forget separating comma
{
	"btown", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		local pMap, x, y, z = Sirin.mainThread.g_MapOper:GetPosStartMap(0, false)

		if pMap ~= nil then
			Sirin.mainThread.teleportPlayer(pPlayer, pMap, x, y, z, 0)
			return true
		else
			return false
		end
	end
}, -- dont forget separating comma
{
	"ctown", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		local pMap, x, y, z = Sirin.mainThread.g_MapOper:GetPosStartMap(1, false)

		if pMap ~= nil then
			Sirin.mainThread.teleportPlayer(pPlayer, pMap, x, y, z, 0)
			return true
		else
			return false
		end
	end
}, -- dont forget separating comma
{
	"atown", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		local pMap, x, y, z = Sirin.mainThread.g_MapOper:GetPosStartMap(2, false)

		if pMap ~= nil then
			Sirin.mainThread.teleportPlayer(pPlayer, pMap, x, y, z, 0)
			return true
		else
			return false
		end
	end
}, -- dont forget separating comma
{
	"short link", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		local Cmd = "moncall 00000"
		local n = Sirin.mainThread.getCheatWordNum()

		if n > 0 then
			n = n - 1

			for i = 0, n do
				Cmd = Cmd .. " " .. Sirin.mainThread.getCheatWord(i)
			end
		end

		return Sirin.mainThread.processCheatCommand(pPlayer, Cmd)
	end
}, -- dont forget separating comma
{
	"rift reload", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		return RiftMgr:loadScripts()
	end
},
{
	"button reload", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		return ButtonMgr:loadScripts()
	end
},
{
	"potion reload", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		return PotionMgr:loadScripts()
	end
},
{
	"bot add", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		BotMgr.makeBot(pPlayer, math.floor(tonumber(Sirin.mainThread.getCheatWord(0)) or 0))
		return true
	end
},
{
	"bot wipe", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		BotMgr.wipeBot()
		return true
	end
},
{
	"wipe quests", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		local list = pPlayer.m_Param.m_QuestDB:GetActiveQuestList()
		for k,v in ipairs(list) do
			repeat
				if v.byQuestType == 255 then
					break
				end

				pPlayer:SendMsg_QuestFailure(5, k - 1)
				pPlayer.m_QuestMgr:DeleteQuestData(k - 1)
				pPlayer.m_pUserDB:Update_QuestDelete(k - 1)
			until true
		end
		return true
	end
},
{
	"begin quest", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		if Sirin.mainThread.getCheatWordNum() < 1 then
			return false
		end

		local race = pPlayer:GetObjRace()

		if Sirin.mainThread.getCheatWordNum() > 1 then
			race = math.floor(tonumber(Sirin.mainThread.getCheatWord(1)) or race)

			if race > 2 then
				race = 2
			end
		end

		local event = Sirin.mainThread.baseToQuestEvent(Sirin.mainThread.CQuestMgr__s_tblQuestHappenEvent_get(1):GetRecord(math.floor(tonumber(Sirin.mainThread.getCheatWord(0)) or 0)))
		local pCont = Sirin.mainThread._happen_event_cont()
		pCont.m_pEvent = event:m_Node_get(race)
		pPlayer.m_QuestMgr.m_LastHappenEvent.m_pEvent = pCont.m_pEvent
		return pPlayer:Emb_StartQuest(255, pCont)
	end
},
{
	"insert quest", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		if Sirin.mainThread.getCheatWordNum() < 1 then
			return false
		end

		local questFld = Sirin.mainThread.baseToQuest(Sirin.mainThread.CQuestMgr__s_tblQuest():GetRecord(Sirin.mainThread.getCheatWord(0)))
		local bSucc = false

		if not questFld then
			return false
		end

		for index = 1, 30 do
			local value = pPlayer.m_Param.m_QuestDB:m_List_get(index - 1)

			if value.byQuestType == 255 then
				bSucc = true
				value.byQuestType = 0 -- 0 - normal (no start history), 1 - NPC/repeatable (with start history)
				value.wIndex = questFld.m_dwIndex
				value.dwPassSec = 0

				for i = 0, 2 do
					value:wNum_set(i, 65535)
					if questFld:m_ActionNode_get(i).m_nActType ~= -1 then
						value:wNum_set(i, 0)
					end

					if questFld:m_ActionNode_get(i).m_nReqAct == -1 then
						value:wNum_set(i, 65535)
					end
				end

				pPlayer.m_pUserDB:Update_QuestInsert(index - 1, value)

				if value.byQuestType > 0 then
					local pHisData = Sirin.mainThread._QUEST_DB_BASE___START_NPC_QUEST_HISTORY()
					pHisData.szQuestCode = questFld.m_strCode
					pHisData.byLevel = pPlayer.m_Param.m_dbChar.m_byLevel
					pPlayer.m_pUserDB:Update_StartNPCQuestHistory(pHisData)
				end

				pPlayer:SendMsg_InsertNewQuest(index - 1)
				break
			end
		end

		return bSucc
	end
},
{
	"advance quest", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		local quest_index = 0
		local task_index = 0

		if Sirin.mainThread.getCheatWordNum() > 1 then
			quest_index = math.floor(tonumber(Sirin.mainThread.getCheatWord(0)) or 0)
			task_index = math.floor(tonumber(Sirin.mainThread.getCheatWord(1)) or 0)
		end

		if pPlayer.m_Param.m_QuestDB:m_List_get(quest_index).byQuestType == 255 then
			return false
		end

		pPlayer.m_Param.m_QuestDB:m_List_get(quest_index):wNum_set(task_index, 1)
		pPlayer.m_pUserDB:Update_QuestUpdate(quest_index, pPlayer.m_Param.m_QuestDB:m_List_get(quest_index), true)

		-- CPlayer::SendMsg_QuestProcess(...)
		local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
		buf:Init()
		buf:PushUInt8(0)
		buf:PushUInt8(0)
		buf:PushUInt16(1)
		buf:SendBuffer(pPlayer, 24, 6)
		--
		return true
	end
},
{
	"complete quest", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		local quest_index = 0

		if Sirin.mainThread.getCheatWordNum() > 0 then
			quest_index = math.floor(tonumber(Sirin.mainThread.getCheatWord(0)) or 0)
		end

		if pPlayer.m_Param.m_QuestDB:m_List_get(quest_index).byQuestType == 255 then
			return false
		end

		pPlayer.m_Param.m_QuestDB:m_List_get(quest_index):wNum_set(0, 0xFFFF)
		pPlayer.m_Param.m_QuestDB:m_List_get(quest_index):wNum_set(1, 0xFFFF)
		pPlayer.m_Param.m_QuestDB:m_List_get(quest_index):wNum_set(2, 0xFFFF)
		pPlayer.m_pUserDB:Update_QuestUpdate(quest_index, pPlayer.m_Param.m_QuestDB:m_List_get(quest_index), true)
		pPlayer:Emb_CompleteQuest(quest_index, 255, 255)
		return true
	end
},
{
	"load npc quests", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		if Sirin.mainThread.getCheatWordNum() < 1 then
			return false
		end

		pPlayer.m_NPCQuestIndexTempData:Init()
		pPlayer.m_QuestMgr:CheckNPCQuestList(Sirin.mainThread.getCheatWord(0), pPlayer:GetObjRace(), pPlayer.m_NPCQuestIndexTempData)
		pPlayer:SendMsg_NpcQuestListResult()
		return true
	end
},
{
	"set daily reset", "111100", "111",
	---@param pPlayer CPlayer
	---@return boolean
	function (pPlayer)
		Sirin.mainThread.modQuestHistory.setDailyReset(0, 0)
		return true
	end
},
}

return t
