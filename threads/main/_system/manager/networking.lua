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

---@type table<string, fun(a: NetOP, ...)>
local tblPackFunc = {}

---@class (exact) NetOP
---@field __index table
---@field strPacketID string
---@field netBuf CProtoDataObject
NetOP = {}

---@return NetOP self
function NetOP:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

function NetOP:GetValueName(tblName)
	if type(tblName) == 'table' then
		return tblName[2][1]
	end
	return tblName
end

function NetOP:TypeCount(nIndex, szType)
	nIndex = nIndex or 0
	local nType = 0
	if type(szType) == "table" then
		nType = 2
	else
		local t = string.sub(szType, 1, 1)

		if t == 'u' or t == 'i' or t == 'b' then
			nType = 0
		elseif t == 's' or t == 't' or t == 'p' then
			nType = 2
		elseif t == 'd' then
			nType = 1
		elseif t == 'f' then
			nType = 5
		end
	end
	return (nIndex * 8 + nType)
end

---@param val boolean
function NetOP:PackBool(val)
	if val then
		self.netBuf:PackUInt32(1)
	else
		self.netBuf:PackUInt32(0)
	end
end

function NetOP:PackSingleElement(tblData, tblType, nType)
	for k = 1, #tblData do
		self.netBuf:PackUInt32(nType)--wire type
		for i = 1, #tblType do
			local nSubType = self:TypeCount(i, tblType[i])
			if type(tblType[i]) == "table" then
				tblPackFunc['t'](self, tblData[k][i], tblType[i], nSubType)
			else
				if string.sub(tblType[i], 1, 1) ~= 't' then
					tblPackFunc[tblType[i]](self, tblData[k][i], tblType[i])
				else
					tblPackFunc[tblType[i]](self, tblData[k][i], tblType[i], nSubType)
				end
			end
		end
	end
end

function NetOP:PackTable(tblData, tblType, nType)
	local bMulTable = tblType[1]
	local tblType = tblType[2]

	if bMulTable == true then
		--if #tblType == 1 then--{an1}
		--	self:PackSingleElement(tblData, tblType, nType)
		--else--{sub msg repeat}
			for k = 1, #tblData do
				self.netBuf:PackUInt32(nType)--wire type
				local nPreSize = self.netBuf:GetWritePacketSize()
				self:PackSubTable(tblData[k], tblType)
				self.netBuf:PacketBufInsert(self.netBuf:GetWritePacketSize() - nPreSize, nPreSize)--single list length
			end
		--end
	else-- submsg no repeat
		self.netBuf:PackUInt32(nType)--wire type
		local nPreSize = self.netBuf:GetWritePacketSize()
		self:PackSubTable(tblData, tblType, true)
		self.netBuf:PacketBufInsert(self.netBuf:GetWritePacketSize() - nPreSize, nPreSize)--single list length
	end
end

function NetOP:PackSubTable(tblData, tblType, bNoRepeat)
	for i = 1, #tblType do
		if tblData[i] ~= nil then
			local nSubType = self:TypeCount(i, tblType[i])
			if type(tblType[i]) == "table" then
				tblPackFunc['t'](self, tblData[i], tblType[i], nSubType)
			else
				if string.sub(tblType[i], 1, 1) ~= 't' then
					--if #tblType > 1 or bNoRepeat then
						self.netBuf:PackUInt32(nSubType)
					--end
					tblPackFunc[tblType[i]](self, tblData[i], tblType[i])
				else
					tblPackFunc[tblType[i]](self, tblData[i], tblType[i], nSubType)
				end
			end
		end
	end
end

function NetOP:PackRepeatInt(tblData, szType, nType)
	local szSubType = string.sub(szType, 2, -1)
	for i = 1, #tblData do
		self.netBuf:PackUInt32(nType)
		tblPackFunc[szSubType](self, tblData[i])
	end
end

function NetOP:PackRepeatIntPacked(tblData, szType)
	local nPacketLen = self.netBuf:GetWritePacketSize();
	local szSubType	 = string.sub(szType, 2, -1)
	for i = 1, #tblData do
		tblPackFunc[szSubType](self, tblData[i])
	end
	self.netBuf:PacketBufInsert(self.netBuf:GetWritePacketSize() - nPacketLen, nPacketLen)--single list length
end

function NetOP:UnpackSingleValue(tblName, tblData)
	local valData = {}
	if tblData == nil then
		valData = nil
	elseif type(tblName) == 'table' then
		valData = self:UnpackSubStruct(tblName, tblData)
	else
		valData = tblData
	end
	return valData
end

function NetOP:UnpackStruct(tblName, tblData)
	local tblStruct = {}
	local szName 	= 0
	for i = 1, #tblName do
		szName = self:GetValueName(tblName[i])
		tblStruct[i] = self:UnpackSingleValue(tblName[i], tblData[szName])
	end
	return tblStruct
end

function NetOP:UnpackSubStruct(tblName, tblData)
	local tblSubStruct	= {}
	local bMulTable		= tblName[1]
	local tblName		= tblName[2]
	local szName		= 0

	if bMulTable == false then
		for i = 2, #tblName do
			szName = self:GetValueName(tblName[i])
			tblSubStruct[i - 1] = self:UnpackSingleValue(tblName[i], tblData[szName])
		end
	else
		for i = 1, #tblData do
			local tblTemp = {}
			for k = 2, #tblName do
				szName = self:GetValueName(tblName[k])
				tblTemp[k - 1] = self:UnpackSingleValue(tblName[k], tblData[i][szName])
			end
			table.insert(tblSubStruct, tblTemp)
		end
	end
	return tblSubStruct
end

local protoTypes = {
	["sirin.proto.customWindows"] = {
		4096,
		{ 'u32', { true, { 'u32', 'u32', 's', 'u32', 'u32', 'u32', 'u32', 'pu32', 'pu32', 's', 's', 's', { true, { 'u32' ,'pu32' } }, 'u32', 'u32',
			{ true, { 'u32', 'pu32', 's', 'u32', 'u32', 's', 'pu32', { false, { { false, { 's', 'u32' } }, { true, { 'u32', 's', 's', 'u32' } } } }, 'u32', 'u32', 'u32', 'pu32', 'pu32', 'pu32', 'b', 'b', 'u32', 'u32', 'pu32', 'pi32' } } } } },
		{ 'ct', { true, { 'data', 'id', 'visualVer', 'name', 'width', 'height', 'headerWindowID', 'footerWindowID', 'layout', 'backgroundImage', 'strModal_Ok', 'strModal_Cancel', 'strModal_Text', { true, { 'overlayIcons', 'id', 'icon' } }, 'iconSize', 'stateFlags',
			{ true, { 'data', 'id', 'icon', 'description', 'durability', 'upgrade', 'text', 'item', { false, { 'tooltip', { false, { 'name', 'text', 'color' } }, { true, { 'info', 'id', 'left', 'right', 'color' } } } }, 'clientWindow', 'npcCode', 'customWindow', 'raceLimit', 'raceBoss', 'guildClass', 'isGM', 'isPremium', 'stateFlags', 'overlayFlags', 'delay', 'counter' } } } } },
	},
	["sirin.proto.onScreentext"] = {
		2048,
		{ 'u32', { true, { 'u32', 'b', 'u32', { false, { 's', 'u32' } }, { false, { 's', 'u32' } }, 'i32', 'i32', 'u32', 'f' } } },
		{ 'ct', { true, { 'data', 'id', 'visible', 'type', { false, { 'text', 'str', 'color' } }, { false, { 'name', 'str', 'color' } }, 'x', 'y', 'flags', 'scale' } } },
	},
}

---Convert lua table to protobuf format
---@param szID string
---@param tblData any
---@param bSendSerialize boolean
function NetOP:MakeData(szID, tblData, bSendSerialize)
	local tblType = protoTypes[szID]

	if not tblType or not tblData then
		return
	end

	if not self.netBuf then
		self.netBuf = Sirin.mainThread.CProtoDataObject()
	end

	self.netBuf:Init(tblType[1])
	self.strPacketID = szID

	local tblName	= tblType[3]
	---@type any
	local tblType	= tblType[2]

	if bSendSerialize then
		tblData = self:UnpackStruct(tblName, tblData)
	end

	if #tblData < #tblType then
		print("Send Packet Data not long enough, add NULL for option")
		--return nil

		local n = #tblType
		local idx = #tblData
		while idx < n do
			table.insert(tblData, nil)
			idx = idx + 1
		end
	end

	for i = 1, #tblData do
		if tblData[i] ~= nil then
			local nType = self:TypeCount(i, tblType[i])
			if type(tblType[i]) == "table" then
				tblPackFunc['t'](self, tblData[i], tblType[i], nType)
			else
				if string.sub(tblType[i], 1, 1) ~= 't' then
					self.netBuf:PackUInt32(nType)
					tblPackFunc[tblType[i]](self, tblData[i], tblType[i])
				else
					tblPackFunc[tblType[i]](self, tblData[i], tblType[i], nType)
				end
			end
		end
	end
end

---Convert lua table to protobuf format and send to client
---@param pPlayer CPlayer
---@param szID string
---@param tblData any
---@param bSendSerialize boolean
function NetOP:SendData(pPlayer, szID, tblData, bSendSerialize)
	self:MakeData(szID, tblData, bSendSerialize)
	self.netBuf:Send(pPlayer.m_id.wIndex, szID)
end

---Send protobuf data if exists
---@param pPlayer CPlayer
function NetOP:Send(pPlayer)
	if self.netBuf and self.netBuf:GetWritePacketSize() > 0 then
		self.netBuf:Send(pPlayer.m_id.wIndex, self.strPacketID or "invalid id")
	end
end

tblPackFunc = {
	["b"] 	= NetOP.PackBool,
	["u32"] = function(netOP, v) netOP.netBuf:PackUInt32(v) end,
	["u64"] = function(netOP, v) netOP.netBuf:PackUInt64(v) end,
	["i32"] = function(netOP, v) netOP.netBuf:PackSInt32(v) end,
	["i64"] = function(netOP, v) netOP.netBuf:PackSInt64(v) end,
	["f"]	= function(netOP, v) netOP.netBuf:PackFloat(v) end,
	["d"]	= function(netOP, v) netOP.netBuf:PackDouble(v) end,
	["s"]	= function(netOP, v) netOP.netBuf:PackString(v) end,
	["t"]	= NetOP.PackTable,
	["ts"]	= NetOP.PackRepeatInt,
	["pb"]	= NetOP.PackRepeatIntPacked,
	["pu32"] = NetOP.PackRepeatIntPacked,
	["pu64"] = NetOP.PackRepeatIntPacked,
	["pi32"] = NetOP.PackRepeatIntPacked,
	["pi64"] = NetOP.PackRepeatIntPacked,
	["pf"]	= NetOP.PackRepeatIntPacked,
	["pd"]	= NetOP.PackRepeatIntPacked,
}

return sirinNetworkMgr
