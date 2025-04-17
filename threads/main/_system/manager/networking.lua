local sirinNetworkMgr = {}

--[[
byType = { 101, 4 }
struct _sirin_pt_chat_msg {
	unsigned short m_wChatType;
	unsigned char m_byAnnounceMask;
	unsigned m_dwColor;
	unsigned m_dwSound;
	unsigned short m_wMsgLen;
	char m_szMsg[];
}
--]]

---@param pPlayer CPlayer
---@param Msg table<string, string>|string
---@param optMsgType? integer
---@param optColor? integer
---@param optSound? integer
function sirinNetworkMgr.privateChatMsg(pPlayer, Msg, optMsgType, optColor, optSound)
	local Messages = {}

	if type(Msg) == 'table' then
		Messages = Msg
	else
		Messages.default = Msg
	end

	local strMessage = Messages[GetPlayerLanguagePrefix(pPlayer.m_id.wIndex)] or Messages.default or "Lua. sirinNetworkMgr.privateChatMsg(...) Invalid message."
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	buf:PushUInt16(optMsgType or 0)
	buf:PushUInt8(0)
	buf:PushUInt32(optColor or 0xFFFFFFFF)
	buf:PushUInt32(optSound or 0)
	buf:PushUInt16(string.len(strMessage) + 1)
	buf:PushString(strMessage, string.len(strMessage) + 1)
	buf:SendBuffer(pPlayer, 101, 4)
end

---@param pPlayer CPlayer
---@param Msg table<string, string>|string
---@param optMsgType? integer
---@param optAnnounceType? integer
---@param optColor? integer
---@param optSound? integer
function sirinNetworkMgr.privateAnnounceMsg(pPlayer, Msg, optMsgType, optAnnounceType, optColor, optSound)
	local Messages = {}

	if type(Msg) == 'table' then
		Messages = Msg
	else
		Messages.default = Msg
	end

	local strMessage = Messages[GetPlayerLanguagePrefix(pPlayer.m_id.wIndex)] or Messages.default or "Lua. sirinNetworkMgr.privateAnnounceMsg(...) Invalid message."
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	buf:PushUInt16(optMsgType or 0xFFFF)
	buf:PushUInt8(optAnnounceType or 0)
	buf:PushUInt32(optColor or 0xFFFFFFFF)
	buf:PushUInt32(optSound or 0)
	buf:PushUInt16(string.len(strMessage) + 1)
	buf:PushString(strMessage, string.len(strMessage) + 1)
	buf:SendBuffer(pPlayer, 101, 4)
end

---@param Msg table<string, string>|string
---@param optMsgType? integer
---@param optAnnounceType? integer
---@param optRace? integer
---@param optColor? integer
---@param optSound? integer
function sirinNetworkMgr.SendGlobalChatData(Msg, optMsgType, optAnnounceType, optRace, optColor, optSound) -- color is ARGB hex (0xFF0000FF Blue, 0xFFFF0000 Red etc)
	local Messages = {}

	if type(Msg) == 'table' then
		Messages = Msg
	else
		Messages.default = Msg
	end

	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()

	for i = 0, 2531 do
		local pPlayer = Sirin.mainThread.g_Player_get(i)

		if pPlayer.m_bLive and pPlayer.m_bOper and (not optRace or pPlayer:GetObjRace() == optRace) then
			local a = GetPlayerLanguagePrefix(i)
			local strMessage = Messages[a] or Messages.default or "Lua. sirinNetworkMgr.SendGlobalChatData(...) Message arg was nil."
			buf:Init()
			buf:PushUInt16(optMsgType or 0xFFFF)
			buf:PushUInt8(optAnnounceType or 0)
			buf:PushUInt32(optColor or 0xFFFFFFFF)
			buf:PushUInt32(optSound or 0)
			buf:PushUInt16(string.len(strMessage) + 1)
			buf:PushString(strMessage, string.len(strMessage) + 1)
			buf:SendBuffer(pPlayer, 101, 4)
		end
	end
end

function sirinNetworkMgr.globalChatMsg(Msg, optMsgType)
	sirinNetworkMgr.SendGlobalChatData(Msg, optMsgType or 0)
end

function sirinNetworkMgr.bellatoChatMsg(Msg, optMsgType)
	sirinNetworkMgr.SendGlobalChatData(Msg, optMsgType or 0, nil, 0)
end

function sirinNetworkMgr.coraChatMsg(Msg, optMsgType)
	sirinNetworkMgr.SendGlobalChatData(Msg, optMsgType or 0, nil, 1)
end

function sirinNetworkMgr.accretiaChatMsg(Msg, optMsgType)
	sirinNetworkMgr.SendGlobalChatData(Msg, optMsgType or 0, nil, 2)
end

function sirinNetworkMgr.globalAnnounceMsg(Msg, optAnnType)
	sirinNetworkMgr.SendGlobalChatData(Msg, 0xFFFF, optAnnType or 0)
end

function sirinNetworkMgr.bellatoAnnounceMsg(Msg, optAnnType)
	sirinNetworkMgr.SendGlobalChatData(Msg, 0xFFFF, optAnnType or 0, 0)
end

function sirinNetworkMgr.coraAnnounceMsg(Msg, optAnnType)
	sirinNetworkMgr.SendGlobalChatData(Msg, 0xFFFF, optAnnType or 0, 1)
end

function sirinNetworkMgr.accretiaAnnounceMsg(Msg, optAnnType)
	sirinNetworkMgr.SendGlobalChatData(Msg, 0xFFFF, optAnnType or 0, 2)
end

--[[
byType = { 101, 11 }
struct _sirin_pt_alter_money {
{
	unsigned dwCurrencyType;
	int nAlter;
};
--]]

---@param pPlayer CPlayer
---@param dwCurrencyType integer
---@param nAlter number
function sirinNetworkMgr.alterMoneyInform(pPlayer, dwCurrencyType, nAlter)
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	buf:PushUInt32(dwCurrencyType)
	buf:PushInt32(math.floor(nAlter))
	buf:SendBuffer(pPlayer, 101, 11)
end

--[[
byType = { 101, 12 }
struct _sirin_pt_monster_msg {
{
	unsigned char m_byMsgType;		// 0 - guard.msg.monster.create, 1 - guard.msg.monster.destroy_by, 2 - guard.msg.monster.destroy
	unsigned short m_wChatType;		// enum CHAT_TYPE
	unsigned char m_byAnnounceMask;	// enum ANN_TYPE
	unsigned m_dwColor; 			// color ARGB
	unsigned m_dwMapIndex;
	unsigned m_dwMonsterIndex;
	char m_szPlayerName[];
};
--]]

---@param byType integer
---@param pMonRecordFld _monster_fld
---@param pMapData CMapData
---@param pKillerPlayer? CPlayer
---@param dwColor? integer
---@param byAnnounceMask? integer
---@param byChatType? integer
function sirinNetworkMgr.monsterLifeStateInform(byType, pMonRecordFld, pMapData, pKillerPlayer, dwColor, byAnnounceMask, byChatType)
	byType = not pKillerPlayer and (byType == 1) and 2 or byType
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	buf:PushUInt8(byType)
	buf:PushUInt16(byChatType or 0xFFFF)
	buf:PushUInt8(byAnnounceMask or ANN_TYPE.mid3)
	buf:PushUInt32(dwColor or 0xFFFFFF00)
	buf:PushUInt32(pMapData.m_pMapSet.m_dwIndex)
	buf:PushUInt32(pMonRecordFld.m_dwIndex)

	if byType == 1 and pKillerPlayer then
		buf:PushString(pKillerPlayer.m_Param.m_dbChar.m_wszCharID, 17)
	end

	for i = 0, 2531 do
		local pPlayer = Sirin.mainThread.g_Player_get(i)

		if pPlayer.m_bLive and pPlayer.m_bOper then
			buf:SendBuffer(pPlayer, 101, 12)
		end
	end
end

return sirinNetworkMgr
