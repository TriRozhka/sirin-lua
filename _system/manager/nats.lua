local json = require('_system.utility.json')
local nats = {
	m_strUUID = "sirin.lua.nats",
}

function nats.initHooks_main()
	SirinLua.HookMgr.addHook("enterAccountReport", HOOK_POS.after_event, nats.m_strUUID, nats.enterAccountReport)
	SirinLua.HookMgr.addHook("exitAccountReport", HOOK_POS.after_event, nats.m_strUUID, nats.exitAccountReport)
end

function nats.initHooks_account()
	SirinLua.HookMgr.addHook("transAccountReport", HOOK_POS.after_event, nats.m_strUUID, nats.transAccountReport)
end

local function getGiveItemError(retCode)
	if retCode == 10 then return 'Invalid item type' end
	if retCode == 11 then return 'Item not found' end
	if retCode == 12 then return 'Invalid map' end
	if retCode == 13 then return 'No empty space' end
	if retCode == 14 then return 'Emb_AddStorage failed' end
	if retCode == 15 then return 'Player not found' end

	if retCode == 20 then return 'Invalid talic code' end
	if retCode == 21 then return 'Empty slot in upgrade code' end
	if retCode == 22 then return 'Exceed max talic of the same type' end
	if retCode == 23 then return 'Exceed max talic of the same type' end
	if retCode == 24 then return 'Exceed max talic of the same type' end
	if retCode == 25 then return 'Exceed max talic of the same type' end
	if retCode == 26 then return 'Exceed max talic of the same type' end
	if retCode == 27 then return 'Exceed max talic of the same type' end
	if retCode == 28 then return 'Exceed max talic of the same type' end
	if retCode == 29 then return 'Exceed max talic of the same type' end
	if retCode == 30 then return 'Invalid weapon type' end
	if retCode == 31 then return 'Exceed max talic of the same type' end
	if retCode == 32 then return 'Invalid item type' end
	return string.format('unknown error (%d)', retCode)
end

local function getTakeItemError(retCode)
	if retCode == -10 then return 'Invalid item type' end
	if retCode == -11 then return 'Item not found' end
	if retCode == -15 then return 'Player not found' end

	if retCode == -20 then return 'Invalid syntax Num and UUID' end
	if retCode == -21 then return 'Invalid level' end
	if retCode == -22 then return 'Invalid level' end
	if retCode == -23 then return 'Animus not found' end
	if retCode == -24 then return 'Not have enough amount' end

	return string.format('unknown error (%d)', retCode)
end

local function getTeleportResultError(retCode)
	if retCode == 1 then return 'Invalid map' end
	if retCode == 2 then return 'Invalid position' end
	if retCode == 3 then return 'Player not found' end
	return string.format('unknown error (%d)', retCode)
end

local function _giveItemByName(paramIn, uuid)
	local s = Sirin.mainThread.modChargeItem.giveItemByName(paramIn.name, paramIn.itemCode, paramIn.itemDur, tonumber(paramIn.upgrade, 16), paramIn.time)
	local o = {}
	o.type = 'item_obtained'
	o.id = uuid
	o.param = {}

	if s < 256 then
		o.param.status = 'error'
		o.param.error = getGiveItemError(s)
		Sirin.NATS.publish('rf.b1.response', json.encode(o))

		-- debug purpose only
		print(json.encode(o))
	else
		o.param.status = 'ok'
		o.param.error = 'success'
		o.param.itemSerial = s
		Sirin.NATS.publish('rf.b1.response', json.encode(o))

		-- debug purpose only
		--print(json.encode(o))
	end
end

local function _giveItemBySerial(paramIn, uuid)
	local s = Sirin.mainThread.modChargeItem.giveItemBySerial(paramIn.character_serial, paramIn.item_code, paramIn.dur, tonumber(paramIn.upgrade, 16), paramIn.time)
	local o = {}
	o.type = 'item_obtained'
	o.id = uuid
	o.param = {}

	if s < 256 then
		o.param.status = 'error'
		o.param.error = getGiveItemError(s)
		Sirin.NATS.publish('rf.b1.response', json.encode(o))

		-- debug purpose only
		print(json.encode(o))
	else
		o.param.status = 'ok'
		o.param.error = 'success'
		o.param.itemSerial = s
		Sirin.NATS.publish('rf.b1.response', json.encode(o))

		-- debug purpose only
		--print(json.encode(o))
	end
end

local function _takeItemBySerial(paramIn, uuid)
	local s = Sirin.mainThread.modChargeItem.takeItemBySerial(paramIn.character_serial, paramIn.item_code, tonumber(paramIn.upgrade, 16), paramIn.uid, tonumber(paramIn.storageMask, 2), paramIn.num)
	local o = {}
	o.type = 'item_removed'
	o.id = uuid
	o.param = {}

	if s <= 0 then
		o.param.status = 'error'
		o.param.error = getTakeItemError(s)
		Sirin.NATS.publish('rf.b1.response', json.encode(o))

		-- debug purpose only
		print(json.encode(o))
	else
		o.param.status = 'ok'
		o.param.error = 'success'
		o.param.itemSerial = s
		Sirin.NATS.publish('rf.b1.response', json.encode(o))

		-- debug purpose only
		print(json.encode(o))
	end
end

local function getTransAccountError(retCode)
	if retCode == 0 then return 'success'
	elseif retCode == 1 then return 'already logged in. push required'
	elseif retCode == 2 then return 'operated by gm'
	elseif retCode == 3 then return 'already logged in. waiting push to complete'
	elseif retCode == 4 then return 'push close wait'
	elseif retCode == 5 then return 'max online reached'
	elseif retCode == 55 then return 'internal error'
	else return string.format('unknown error (%d)', retCode) end
end

local function _enterWorldRequest(paramIn, uuid)
	local retCode = Sirin.accountThread.enterWorldRequest(
		uuid, paramIn.account_serial, paramIn.serialSupervisor, paramIn.isPush, paramIn.ip, paramIn.isPremium,
		paramIn.isChatLock, paramIn.grade, paramIn.subGrade)

	if retCode ~= 0 then
		local o = {}
		o.type = 'session_created'
		o.id = uuid
		o.param = {}
		o.param.status = 'error'
		o.param.error = getTransAccountError(retCode)
		o.param.account_serial = paramIn.serial
		o.param.key = { 0, 0, 0, 0 }
		Sirin.NATS.publish('rf.b1.response', json.encode(o))

		-- debug purpose only
		print(json.encode(o))
	end
end

local function _closeAccountRequest(paramIn, uuid)
	Sirin.accountThread.closeAccountRequest(paramIn.account_serial)
end

local function _pushUserSave(paramIn, uuid)
	local o = {}
	o.type = 'data_saved'
	o.id = uuid
	o.param = {}

	for i = 0, 2531 do
		local userDB = Sirin.mainThread.g_UserDB_get(i)

		if userDB.m_bActive and userDB.m_bField and userDB.m_dwSerial == paramIn.character_serial then
			o.param.status = 'ok'

			if userDB.m_bDBWaitState then
				o.param.status = 'error'
				o.param.error = 'save in progress'
			elseif not userDB.m_bDataUpdate then
				o.param.status = 'error'
				o.param.error = 'no changes to save'
			else
				userDB.m_dwTermContSaveTime = 0
			end

			break
		end
	end

	if not o.param.status then
		o.param.status = 'error'
		o.param.error = 'player not in game'
	end

	Sirin.NATS.publish('rf.b1.response', json.encode(o))
end

local function _teleportPlayer(paramIn, uuid)
	local retCode = Sirin.mainThread.teleportPlayer(paramIn.player_serial, paramIn.map_index, paramIn.x, paramIn.y, paramIn.z, paramIn.layer)
	local o = {}
	o.type = 'player_teleported'
	o.id = uuid
	o.param = {}

	if retCode ~= 0 then
		o.param.status = 'error'
		o.param.error = getTeleportResultError(retCode)
		Sirin.NATS.publish('rf.events.response', json.encode(o))

		-- debug purpose only
		print(json.encode(o))
	else
		o.param.status = 'ok'
		o.param.error = 'success'
		Sirin.NATS.publish('rf.events.response', json.encode(o))

		-- debug purpose only
		print(json.encode(o))
	end
end

function nats.transAccountReport(uuid, retCode, serial, key_1, key_2, key_3, key_4)
	local o = {}
	o.type = 'session_created'
	o.id = uuid
	o.param = {}
	o.param.status = retCode > 0 and 'error' or 'ok'
	o.param.error = getTransAccountError(retCode)
	o.param.account_serial = serial
	o.param.key = { key_1, key_2, key_3, key_4 }
	Sirin.NATS.publish('rf.b1.response', json.encode(o))

	-- debug purpose only
	print(json.encode(o))
end

function nats.exitAccountReport(uuid, serial)
	local o = {}
	o.type = 'account_out_of_game'
	o.id = uuid
	o.param = {}
	o.param.account_serial = serial
	Sirin.NATS.publish('rf.b1.response', json.encode(o))

	-- debug purpose only
	print(json.encode(o))
end

function nats.enterAccountReport(uuid, serial)
	local o = {}
	o.type = 'account_in_game'
	o.id = uuid
	o.param = {}
	o.param.account_serial = serial
	Sirin.NATS.publish('rf.b1.response', json.encode(o))

	-- debug purpose only
	print(json.encode(o))
end

function nats.CPlayer__SetDamage(_this, nDam, dwHPLeft, pAttChar, nAtkType, dwAtkSerial)
	if not pAttChar or pAttChar == 0 then return end
	if pAttChar.m_ObjID.m_byID == 1 then return end -- ignore damge dealt by monsters

	local o = {}

	if dwHPLeft == 0 then
		o.type = 'pvp_kill'
		o.param = {}
		o.param.dstSerial = _this.m_dwObjSerial

		if pAttChar.m_ObjID.m_byID == 3 then -- animus
			o.param.srcSerial = Sirin.mainThread.objectToAnimus(pAttChar).m_dwMasterSerial
		elseif pAttChar.m_ObjID.m_byID == 4 then -- tower
			o.param.srcSerial = Sirin.mainThread.objectToTower(pAttChar).m_dwMasterSerial
		elseif pAttChar.m_ObjID.m_byID == 7 then -- trap
			o.param.srcSerial = Sirin.mainThread.objectToTrap(pAttChar).m_dwMasterSerial
		elseif pAttChar.m_ObjID.m_byID == 0 then -- player
			o.param.srcSerial = pAttChar.m_dwObjSerial
		else
			-- we should never get there
			return
		end

		o.param.map = _this.m_pCurMap.m_pMapSet.m_dwIndex
		o.param.layer = _this.m_wMapLayerIndex
		Sirin.NATS.publish('rf.b1.damage_dealt', json.encode(o))

		-- debug purpose only
		-- print(json.encode(o))

		return
	end

	--[[
	o.type = 'damage_dealt'
	o.param = {}
	o.param.dstSerial = _this.m_dwObjSerial
	o.param.damage = nDam
	o.param.hpLeft = dwHPLeft
	o.param.srcType = pAttChar.m_ObjID.m_byID
	o.param.map = _this.m_pCurMap.m_pMapSet.m_dwIndex
	o.param.layer = _this.m_wMapLayerIndex
	o.param.pos = { _this.m_fCurPos_x, _this.m_fCurPos_y, _this.m_fCurPos_z }	
	o.param.atkType = nAtkType
	o.param.atkSerial = dwAtkSerial
	Sirin.NATS.publish('rf.b1.damage_dealt', json.encode(o))
	--]]
	-- debug purpose only
	-- print(json.encode(o))
end

function nats.CPlayer__pc_UpgradeItem(_this, ItemCopy)
	local o = {}
	o.type = 'enchanting_item_destroy'
	o.id = Sirin.getUUIDv4()
	o.param = {}
	o.param.character_serial = _this.m_dwObjSerial
	local t = Sirin.mainThread.g_Main:m_tblItemData_get(ItemCopy.m_byTableCode)
	o.param.item_code = t:GetRecord(ItemCopy.m_wItemIndex).m_strCode
	o.param.upgrade = string.format('%x', ItemCopy.m_dwLv)
	o.param.item_uid = ItemCopy.m_lnUID
	Sirin.NATS.publish('rf.events.response', json.encode(o))

	-- debug purpose only
	print(json.encode(o))
end

function nats.CPlayer__pc_DarkHoleOpenRequest(_this, bSucc, pBaseFld, uuid)
	local o = {}
	o.type = 'dungeon_open'
	o.id = uuid
	o.param = {}
	o.param.character_serial = _this.m_dwObjSerial
	o.param.open_success = bSucc
	o.param.item_code = pBaseFld.m_strCode
	Sirin.NATS.publish('rf.events.response', json.encode(o))

	-- debug purpose only
	print(json.encode(o))
end

function nats.CDarkHoleChannel__SendMsg_ChannelClose(uuid, bReward)
	local o = {}
	o.type = 'dungeon_close'
	o.id = uuid
	o.param = {}
	o.param.reward = bReward
	Sirin.NATS.publish('rf.events.response', json.encode(o))

	-- debug purpose only
	print(json.encode(o))
end

function nats.CPlayer__OutOfMap(_this, pIntoMap, wLayerIndex, byMapOutType, fX, fY, fZ)
	local o = {}
	o.type = 'map_leave'
	o.id = Sirin.getUUIDv4()
	o.param = {}
	o.param.srcMap = _this.m_pCurMap.m_pMapSet.m_dwIndex
	o.param.dstMap = pIntoMap.m_pMapSet.m_dwIndex
	Sirin.NATS.publish('rf.events.response', json.encode(o))

	-- debug purpose only
	print(json.encode(o))
end

function nats.onButtonPressed(pPlayer, buttonID)
	local o = {}
	o.type = 'push_button'
	o.id = tostring(Sirin.getUUIDv4())
	o.param = {}
	o.param.playerSerial = pPlayer.m_dwObjSerial
	o.param.button = buttonID
	o.param.maxFP = pPlayer:GetMaxFP()
	o.param.avoid_rate = pPlayer.m_EP:GetEff_Plus(_EFF_PLUS.GE_Avd)
	Sirin.NATS.publish('rf.events.response', json.encode(o))
	pPlayer:SendData_ChatTrans(0, 0xFFFFFFFF, 0xFF, false, string.format('Player %d pressed button %d', pPlayer.m_dwObjSerial, buttonID), 0xFF, nil)

	-- debug purpose only
	print(json.encode(o))
end

local handlers = { -- { Thread ID, handler function }
	giveItemByName = { 0, _giveItemByName },
	item_give = { 0, _giveItemBySerial },
	session_create = { 1, _enterWorldRequest },
	terminate_session = { 1, _closeAccountRequest },
	takeItemBySerial = { 0, _takeItemBySerial },
	pushUserSave = { 0, _pushUserSave },
	teleportPlayer = { 0, _teleportPlayer },
}

function nats.parseMessage(msg)
	local j = json.decode(msg)

	if not j then
		print 'msg decode failed. j is nil'
	else
		dump(j)
	end

	if j and j.type and handlers[j.type] then
		handlers[j.type][2](j.param, j.id)
		return 1
	else
		return 0
	end
end

function nats.getThreadType(msg)
	local j = json.decode(msg)

	if j and j.type and handlers[j.type] then
		return handlers[j.type][1]
	end

	return -1
end

return nats
