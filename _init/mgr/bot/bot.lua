---@type table
local sirinBot = {}

local presetsArmor = {
	{ -- bellato
		{ -- warrior
			{ "ihbwb50", "iubwb50", "ilbwb50", "igbwb50", "isbwb50" },
			{ "ihbwb53", "iubwb53", "ilbwb53", "igbwb53", "isbwb53" },
			{ "ihbwb55", "iubwb55", "ilbwb55", "igbwb55", "isbwb55" },
			{ "ihbwb57", "iubwb57", "ilbwb57", "igbwb57", "isbwb57" },
		},
		{ -- ranger
			{ "ihbrb50", "iubrb50", "ilbrb50", "igbrb50", "isbrb50" },
			{ "ihbrb53", "iubrb53", "ilbrb53", "igbrb53", "isbrb53" },
			{ "ihbrb55", "iubrb55", "ilbrb55", "igbrb55", "isbrb55" },
			{ "ihbrb57", "iubrb57", "ilbrb57", "igbrb57", "isbrb57" },
		},
		{ -- magician
			{ "ihbfb50", "iubfb50", "ilbfb50", "igbfb50", "isbfb50" },
			{ "ihbfb53", "iubfb53", "ilbfb53", "igbfb53", "isbfb53" },
			{ "ihbfb55", "iubfb55", "ilbfb55", "igbfb55", "isbfb55" },
			{ "ihbfb57", "iubfb57", "ilbfb57", "igbfb57", "isbfb57" },
		},
	},
	{ -- cora
		{ -- warrior
			{ "ihcwb50", "iucwb50", "ilcwb50", "igcwb50", "iscwb50" },
			{ "ihcwb53", "iucwb53", "ilcwb53", "igcwb53", "iscwb53" },
			{ "ihcwb55", "iucwb55", "ilcwb55", "igcwb55", "iscwb55" },
			{ "ihcwb57", "iucwb57", "ilcwb57", "igcwb57", "iscwb57" },
		},
		{ -- ranger
			{ "ihcrb50", "iucrb50", "ilcrb50", "igcrb50", "iscrb50" },
			{ "ihcrb53", "iucrb53", "ilcrb53", "igcrb53", "iscrb53" },
			{ "ihcrb55", "iucrb55", "ilcrb55", "igcrb55", "iscrb55" },
			{ "ihcrb57", "iucrb57", "ilcrb57", "igcrb57", "iscrb57" },
		},
		{ -- magician
			{ "ihcfb50", "iucfb50", "ilcfb50", "igcfb50", "iscfb50" },
			{ "ihcfb53", "iucfb53", "ilcfb53", "igcfb53", "iscfb53" },
			{ "ihcfb55", "iucfb55", "ilcfb55", "igcfb55", "iscfb55" },
			{ "ihcfb57", "iucfb57", "ilcfb57", "igcfb57", "iscfb57" },
		},
	},
	{ -- accretia
		{ -- warrior
			{ "ihawb50", "iuawb50", "ilawb50", "igawb50", "isawb50" },
			{ "ihawb53", "iuawb53", "ilawb53", "igawb53", "isawb53" },
			{ "ihawb55", "iuawb55", "ilawb55", "igawb55", "isawb55" },
			{ "ihawb57", "iuawb57", "ilawb57", "igawb57", "isawb57" },
		},
		{ -- ranger
			{ "iharb50", "iuarb50", "ilarb50", "igarb50", "isarb50" },
			{ "iharb53", "iuarb53", "ilarb53", "igarb53", "isarb53" },
			{ "iharb55", "iuarb55", "ilarb55", "igarb55", "isarb55" },
			{ "iharb57", "iuarb57", "ilarb57", "igarb57", "isarb57" },
		},
		{ -- magician
			{ "ihafb50", "iuafb50", "ilafb50", "igafb50", "isafb50" },
			{ "ihafb53", "iuafb53", "ilafb53", "igafb53", "isafb53" },
			{ "ihafb55", "iuafb55", "ilafb55", "igafb55", "isafb55" },
			{ "ihafb57", "iuafb57", "ilafb57", "igafb57", "isafb57" },
		},
	},
}

local presetsWeapon = {
	{ -- warrior
		{ "iwswb50", "iwswb55", "iwspb50", "iwspb55", "iwspd52" },
	},
	{ -- ranger
		{ "iwbob50", "iwbob55", "iwfib50", "iwfib55", "iwfid59", "iwbod51" },
	},
	{ -- magician
		{ "iwstb45", "iwstb50", "iwstb55", "iwstd52" },
		{ "iwlub51", "iwlub55", "iwlud54" },
	},
}

local presetsBullet = {
	{ -- warrior
	},
	{ -- ranger
		{ 351, 351, 104, 104, 104, 1 },
	},
	{ -- magician
		{ 337, 345, 337 },
	},
}

local presetsSkill = {
	{ -- warrior
		{ 6, 7, 8, 12, 13, 14 }
	},
	{ -- ranger
		{ 24, 30, 36 },
		{ 24, 31, 37 },
	},
	{ -- magician
		{ 24, 26, 27, 28, 30, 31, 32, 34, 35, 40, 41, 44, 45, 48, 56, 57, 60, 61, 64, 65, 72, 76, 80, 81 },
		{ 211, 216 },
	},
}

function sirinBot.Init()
	sirinBot.startSerial = 4000000001
	sirinBot.startIndex = 1
	sirinBot.loopIndex = 1
	sirinBot.presetsArmor = {}
	sirinBot.presetsWeapon = {}

	for ri,r in ipairs(presetsArmor) do
		sirinBot.presetsArmor[ri] = {}

		for ci,c in ipairs(r) do
			sirinBot.presetsArmor[ri][ci] = {}

			for si,s in ipairs(c) do
				sirinBot.presetsArmor[ri][ci][si] = {-1, -1, -1, -1, -1}

				for _,a in ipairs(s) do
					local tblCode = Sirin.mainThread.GetItemTableCode(a)

					if tblCode == -1 then
						print(string.format("invalid item type %s", a))
					else
						local pItemFld = Sirin.mainThread.g_Main:m_tblItemData_get(tblCode):GetRecordByHash(a, 2, 5)

						if not pItemFld then
							print(string.format("item not found %s", a))
						else
							sirinBot.presetsArmor[ri][ci][si][tblCode + 1] = pItemFld.m_dwIndex
						end
					end
				end
			end
		end
	end

	for ci,c in ipairs(presetsWeapon) do
		sirinBot.presetsWeapon[ci] = {}

		for si,s in ipairs(c) do
			sirinBot.presetsWeapon[ci][si] = {}

			for _,a in ipairs(s) do
				local tblCode = Sirin.mainThread.GetItemTableCode(a)

				if tblCode == -1 then
					print(string.format("invalid item type %s", a))
				else
					local pItemFld = Sirin.mainThread.g_Main:m_tblItemData_get(tblCode):GetRecordByHash(a, 2, 5)

					if not pItemFld then
						print(string.format("item not found %s", a))
					else
						table.insert(sirinBot.presetsWeapon[ci][si], pItemFld.m_dwIndex)
					end
				end
			end
		end
	end
end

function sirinBot.OnRun()
	if #sirinBot.bots == 0 then
		return
	end

	local time = Sirin.mainThread.g_dwCurTime
	local i = 0
	local maxPerLoop = math.floor(#sirinBot.bots / 10) + 1

	repeat
		if sirinBot.loopIndex > #sirinBot.bots then
			sirinBot.loopIndex = 1
		end

		local bot = sirinBot.bots[sirinBot.loopIndex]

		if not bot.live then
			bot.live = true
			bot.actionType = 0 -- 0 - idle, 1 - move, 2 - attack
			bot.actionStart = time
			bot.actionTime = math.random(1, 20) * 50 + 1000
			bot.lastSendTime = time
--[[
4, 9
struct _player_fixpositon_zocl
{
	WORD wIndex;
	DWORD dwSerial;
	WORD wEquipVer;
	BYTE byRaceCode;
	WORD zCur[3];
	WORD wLastEffectCode;
	QWORD dwStateFlag;
	QWORD dwStateFlagEx; -- AoP only
	BYTE byColor;
};
]]--
			local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
			buf:Init()
			buf:PushUInt16(MAX_PLAYERS + bot.index)
			buf:PushUInt32(bot.objSerial)
			buf:PushUInt16(0)
			buf:PushUInt8(bot.byRaceSexCode)
			buf:PushInt16(math.floor(bot.pos[1]))
			buf:PushInt16(math.floor(bot.pos[2]))
			buf:PushInt16(math.floor(bot.pos[3]))
			--print(string.format("Bot (%d) pos %.0f, %.0f, %.0f", bot.index, bot.pos[1], bot.pos[2], bot.pos[3]))
			buf:PushUInt16(0xFFFF)
			buf:PushInt64(sirinBot.player.m_dwLastState)
			buf:PushInt64(sirinBot.player.m_dwLastStateEx)
			buf:PushUInt8(0xFF)
			buf:SendBuffer(sirinBot.player, 4, 9)
		else
--[[
4, 10
struct _object_real_fixpositon_zocl
{
	BYTE byObjKind;
	BYTE byObjID;
	WORD wIndex;
	DWORD dwSerial;
};
]]--
			if time - bot.lastSendTime > 4000 then
				bot.lastSendTime = time
				local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
				buf:Init()
				buf:PushUInt8(0)
				buf:PushUInt8(0)
				buf:PushUInt16(MAX_PLAYERS + bot.index)
				buf:PushUInt32(bot.objSerial)
				buf:SendBuffer(sirinBot.player, 4, 10)
				--print(string.format("Bot (%d) real fix", bot.index))
			end

			if time - bot.actionStart > bot.actionTime then
				bot.actionStart = time
				local raction = math.random(1, 100)

				if raction <= 10 then -- action idle (0)
					bot.actionType = 0
					bot.actionTime = math.random(1, 20) * 50 + 1000
					--print(string.format("Bot (%d) idle. time %d", bot.index, bot.actionTime))
				elseif raction <= 40 then -- action move (1)
					bot.actionType = 1
					local newPos = { bot.center[1] + math.random(0, 200) - 100, bot.center[2], bot.center[3] + math.random(0, 200) - 100 }
					local dist = GetSqrt(bot.pos[1], bot.pos[3], newPos[1], newPos[3])
					local pRet = 0
					pRet, newPos[2] = sirinBot.player.m_pCurMap.m_Level:GetNextYposForServerFar(bot.pos[1], bot.pos[2], bot.pos[3], newPos[1], newPos[2], newPos[3])
					bot.actionTime = math.floor(dist / ( 15 * 5 * 0.001 ))
					--print(string.format("Bot (%d) move. dist %.0f; time %d", bot.index, dist, bot.actionTime))
--[[
4, 4
struct _player_move_zocl
{
	DWORD dwSerial;
	WORD zCur[3];
	WORD zTar[2];
	WORD nAddSpeed;
	BYTE byDirect;
};
]]--
					local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
					buf:Init()
					buf:PushUInt32(bot.objSerial)
					buf:PushInt16(math.floor(bot.pos[1]))
					buf:PushInt16(math.floor(bot.pos[2]))
					buf:PushInt16(math.floor(bot.pos[3]))
					buf:PushInt16(math.floor(newPos[1]))
					buf:PushInt16(math.floor(newPos[3]))
					buf:PushInt16(5)
					buf:PushUInt8(0)
					buf:SendBuffer(sirinBot.player, 4, 4)
					bot.pos = newPos
				else -- action attack (2)
					bot.actionType = 2
					bot.actionTime = math.random(1, 20) * 50 + 2000
					--print(string.format("Bot (%d) attack. time %d", bot.index, bot.actionTime))
--[[
struct _attack_gen_result_zocl::_dam_list
{
	BYTE byDstID;
	DWORD dwDstSerial;
	WORD wDamage;
	bool bActive;
	WORD wActiveDamage;
};

5, 9
struct _attack_force_result_zocl
{
	BYTE byAtterID;
	DWORD dwAtterSerial;
	BYTE byForceIndex;
	BYTE byForceLv;
	WORD zAreaPos[2];
	BYTE byAttackPart;
	bool bCritical;
	bool bWPActive;
	BYTE byListNum;
	_attack_gen_result_zocl::_dam_list DamList[32];
};

5, 8
struct _attack_skill_result_zocl
{
	BYTE byAtterID;
	DWORD dwAtterSerial;
	BYTE byEffectCode;
	WORD wSkillIndex;
	BYTE bySkillLv;
	BYTE byAttackPart;
	WORD wBulletIndex;
	bool bCritical;
	WORD zAttackPos[2];
	bool bWPActive;
	BYTE byListNum;
	_attack_gen_result_zocl::_dam_list DamList[32];
};
]]--
					local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
					buf:Init()

					if bot.byClass == 2 and bot.byRaceSexCode ~= 4 then -- attack force
						buf:PushUInt8(0)
						buf:PushUInt32(bot.objSerial)
						buf:PushUInt8(presetsSkill[3][1][math.random(1, #presetsSkill[3][1])])
						buf:PushUInt8(7)
						buf:PushInt16(math.floor(bot.tar.pos[1]))
						buf:PushInt16(math.floor(bot.tar.pos[3]))
						buf:PushUInt8(0)
						buf:PushUInt8(0)
						buf:PushUInt8(0)
						buf:PushUInt8(1)
						buf:PushUInt8(0)
						buf:PushUInt32(bot.tar.objSerial)
						buf:PushUInt16(12345)
						buf:PushUInt8(0)
						buf:PushUInt16(0)
						buf:SendBuffer(sirinBot.player, 5, 9)
					else -- attack skill
						buf:PushUInt8(0)
						buf:PushUInt32(bot.objSerial)

						if bot.byClass == 0 then
							buf:PushUInt8(EFF_CODE.skill)
							buf:PushUInt16(presetsSkill[1][1][math.random(1, #presetsSkill[1][1])])
						elseif bot.byClass == 1 then
							buf:PushUInt8(EFF_CODE.skill)
							buf:PushUInt16(presetsSkill[2][bot.wptype == 5 and 1 or 2][math.random(1, #presetsSkill[2][bot.wptype == 5 and 1 or 2])])
						else
							buf:PushUInt8(EFF_CODE.class)
							buf:PushUInt16(presetsSkill[3][2][math.random(1, #presetsSkill[3][2])])
						end

						buf:PushUInt8(bot.byClass ~= 2 and 7 or 1)
						buf:PushUInt8(0)
						buf:PushUInt16(bot.bullet)
						buf:PushUInt8(0)
						buf:PushInt16(math.floor(bot.tar.pos[1]))
						buf:PushInt16(math.floor(bot.tar.pos[3]))
						buf:PushUInt8(0)
						buf:PushUInt8(1)
						buf:PushUInt8(0)
						buf:PushUInt32(bot.tar.objSerial)
						buf:PushUInt16(12345)
						buf:PushUInt8(0)
						buf:PushUInt16(0)
						buf:SendBuffer(sirinBot.player, 5, 8)
					end
				end
			end
		end

		sirinBot.loopIndex = sirinBot.loopIndex + 1
		i = i + 1
	until i >= maxPerLoop
end

sirinBot.bots = {}

---@param pPlayer CPlayer
---@param nNum integer
function sirinBot.makeBot(pPlayer, nNum)
	sirinBot.player = pPlayer
	local pos = { pPlayer.m_fOldPos_x, pPlayer.m_fOldPos_z }
	local lookAt = { pPlayer.m_fCurPos_x, pPlayer.m_fCurPos_z }
	local pov = 75
	local angle = math.atan(lookAt[2] - pos[2], lookAt[1] - pos[1])

	for i = 1, nNum do
		local couple = {}
		local race = {
			{0, 1},
			{2, 3},
			{4}
		}

		local rrace = math.random(0, #race - 1)
		local rangle = math.rad(math.random(0, pov) - pov / 2)
  		rangle = rangle + angle
  		local rdist = math.sqrt(math.random(0, 25000) * 10)
		local rpos = { rdist * math.cos(rangle) + pos[1], rdist * math.sin(rangle) + pos[2] }

		for j = 0, 1 do
			local bot = {}
			bot.live = false
			bot.index = sirinBot.startIndex
			sirinBot.startIndex = sirinBot.startIndex + 1
			bot.objSerial = sirinBot.startSerial
			sirinBot.startSerial = sirinBot.startSerial + 1
			local drace = race[(rrace + j) % #race + 1]
			bot.byRaceSexCode = drace[math.random(1, #drace)]
			bot.byClass = math.random(0, 2)
			bot.center = clone(rpos)
			bot.center[3] = bot.center[2]
			local pRet = 0
			pRet, bot.center[2] = pPlayer.m_pCurMap.m_Level:GetNextYposForServerFar(pPlayer.m_fCurPos_x, pPlayer.m_fCurPos_y, pPlayer.m_fCurPos_z, bot.center[1], pPlayer.m_fCurPos_y, bot.center[3])
			bot.pos = { bot.center[1] + math.random(0, 200) - 100, bot.center[2], bot.center[3] + math.random(0, 200) - 100 }
			pRet, bot.pos[2] = pPlayer.m_pCurMap.m_Level:GetNextYposForServerFar(bot.center[1], bot.center[2], bot.center[3], bot.pos[1], bot.center[2], bot.pos[3])
			local equipPreset = sirinBot.presetsArmor[math.floor(bot.byRaceSexCode / 2) + 1][bot.byClass + 1]
			local weaponPreset = sirinBot.presetsWeapon[bot.byClass + 1][bot.byClass == 2 and bot.byRaceSexCode == 4 and 2 or 1]
			bot.face = 15 * bot.byRaceSexCode + math.random(0, 4)
			bot.hair = 15 * bot.byRaceSexCode + math.random(0, 4)
			bot.equip = clone(equipPreset[math.random(1, #equipPreset)])
			bot.equip[TBL_CODE.shield + 1] = -1
			local rweapon = math.random(1, #weaponPreset)
			bot.equip[TBL_CODE.weapon + 1] = weaponPreset[rweapon]
			local pWeaponFld = Sirin.mainThread.baseToWeaponItem( Sirin.mainThread.g_Main:m_tblItemData_get(TBL_CODE.weapon):GetRecord(bot.equip[TBL_CODE.weapon + 1]))
			bot.wptype = pWeaponFld.m_nType
			bot.bullet = 0xFFFF

			if bot.byClass == 1 or (bot.byClass == 2 and bot.byRaceSexCode == 4) then
				bot.bullet = presetsBullet[bot.byClass + 1][1][rweapon]
			end

			bot.equip[TBL_CODE.cloak + 1] = -1

			table.insert(couple, bot)
			table.insert(sirinBot.bots, bot)

		end

		couple[1].tar = couple[2]
		couple[2].tar = couple[1]
	end
end

function sirinBot.wipeBot()
	sirinBot.bots = {}
	sirinBot.startIndex = 1
	sirinBot.loopIndex = 1
	--sirinBot.startSerial = 4000000001
end

--[[
3, 31
struct _other_shape_all_zocl
{
	_model
	{
		WORD wPartIndex;
		BYTE byLv;
	};

	WORD wIndex;
	DWORD dwSerial;
	WORD wEquipVer;
	BYTE byCashChangeStateFlag;
	BYTE byRecIndex;
	BYTE byFaceIndex;
	BYTE byHairIndex;
	_model ModelPerPart[8];
	BYTE byUserGrade;
	DWORD dwGuildSerial;
	char wszName[17];
	BYTE byColor;
	BYTE byHonorGuildRank;
	BYTE bySpecialPart;
	BYTE byFrameIndex;
	BYTE byUnitPartIndex[6];
};

3, 32
struct _other_shape_part_zocl
{
	WORD wIndex;
	DWORD dwSerial;
	WORD wEquipVer;
	BYTE byCashChangeStateFlag;
	_model ModelPerPart[8];
	BYTE byHonorGuildRank;
	BYTE bySpecialPart;
	BYTE byFrameIndex;
	BYTE byUnitPartIndex[6];
};
]]--

---@param pPlayer CPlayer
---@param wIndex integer
---@param byType integer
---@param byCashChangeStateFlag integer
function sirinBot.otherShapeRequest(pPlayer, wIndex, byType, byCashChangeStateFlag)
	--print(string.format("otherShapeRequest %d %d", byType, wIndex))
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	local t1, t2 = 3, 31
	local bot = sirinBot.bots[wIndex - MAX_PLAYERS]

	if not bot then
		return
	end

	if byType == 0 then
		buf:PushUInt16(MAX_PLAYERS + bot.index)
		buf:PushUInt32(bot.objSerial)
		buf:PushUInt16(0)
		buf:PushUInt8(0)
		buf:PushUInt8(bot.byRaceSexCode)
		buf:PushUInt8(bot.face)
		buf:PushUInt8(bot.hair)

		for i = 1, 8 do
			buf:PushInt16(bot.equip[i])
			buf:PushUInt8(bot.equip[i] == -1 and 0 or 7)
		end

		buf:PushUInt8(0)
		buf:PushInt32(-1)
		buf:PushString("Bot", 17)
		buf:PushUInt8(0xFF)
		buf:PushUInt8(0xFF)
		buf:PushUInt8(0xFF)
		buf:PushUInt8(0xFF)

		for i = 1, 6 do
			buf:PushUInt8(0xFF)
		end

		buf:SendBuffer(pPlayer, t1, t2)
	elseif byType == 1 then
		t2 = 32
		buf:PushUInt16(MAX_PLAYERS + bot.index)
		buf:PushUInt32(bot.objSerial)
		buf:PushUInt16(0)
		buf:PushUInt8(0)

		for i = 1, 8 do
			buf:PushInt16(bot.equip[i])
			buf:PushUInt8(bot.equip[i] == -1 and 0 or 7)
		end

		buf:PushUInt8(0xFF)
		buf:PushUInt8(0xFF)
		buf:PushUInt8(0xFF)

		for i = 1, 6 do
			buf:PushUInt8(0xFF)
		end

		buf:SendBuffer(pPlayer, t1, t2)
	end
end

return sirinBot
