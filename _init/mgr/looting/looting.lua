local monsterLevelDiffRate = {
	same = 1.0,
	small = {
		1.0, -- 1
		0.9, -- 2
		0.7, -- 3
		0.6, -- 4
		0.5, -- 5
		0.4, -- 6
		0.3, -- 7
		0.2, -- 8
		0.1, -- 9
		0.05, -- 10+
	},
	big = {
		1.0, -- 1
		1.0, -- 2
		0.9, -- 3
		0.8, -- 4
		0.7, -- 5
		0.6, -- 6
		0.5, -- 7
		0.4, -- 8
		0.3, -- 9
		0.2, -- 10+
	},
}

---@class (exact) SirinLootingMgr
---@field __index table
---@field m_nBossDropDelay integer
---@field m_nBbossDropRange integer
---@field m_bDropShuffle boolean
---@field m_delayedDrop table<integer, SirinDelayedLootRecord>
---@field m_bDebugLog boolean
---@field m_tLoopTime integer
---@field m_strUUID string
---@field pszLogPath string
local SirinLootingMgr = {
	m_nBossDropDelay = 10,
	m_nBbossDropRange = 150,
	m_bDropShuffle = true,
	m_delayedDrop = {},
	m_bDebugLog = false,
	m_tLoopTime = 0,
	m_strUUID = Sirin.getUUIDv4(),
	pszLogPath = '.\\sirin-log\\guard\\LuaLooting.log',
}

---@return SirinLootingMgr self
function SirinLootingMgr:new(o)
o = o or {}
self.__index = self
return setmetatable(o, self)
end

LootingMgr = SirinLootingMgr:new()

---@return boolean
function SirinLootingMgr:loadScripts()
	local bSucc = false

	local dLoadStart = os.clock()
	print "Looting table load start"

	repeat
		TmpItemLooting = FileLoader.LoadChunkedTable(".\\sirin-lua\\ItemLooting")

		if not TmpItemLooting then
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Failed to load 'Item looting' scripts!\n")
			Sirin.WriteA(self.pszLogPath, "Failed to load 'Item looting' scripts!\n", true, true)
			break
		end

		if not self:validateScriptData() then
			break
		end

		if TmpItemLooting then
			---@type table<integer, table<integer, SirinLootRecord>>?
			ScriptItemLooting = TmpItemLooting
			TmpItemLooting = nil
		else
			break
		end

		bSucc = true
	until true

	print(string.format("Looting table load end. Elapsed: %d", math.floor((os.clock() - dLoadStart) * 1000)))

	return bSucc
end

---@return boolean
function SirinLootingMgr:validateScriptData()
	local bSucc = true

	repeat
		local luaScript = TmpItemLooting

		if type(luaScript) ~= 'table' then
			bSucc = false
			break
		end

		---@type table<integer, table<integer, SirinLootRecord>>
		TmpItemLooting = {}

		for strCode, lootData in pairs(luaScript) do
			repeat
				if type(strCode) ~= "string" then
					bSucc = false
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster looting script parse error! key:%s script table key (type: %s) is not a string type!\n", tostring(strCode) or "type convert failure", type(strCode)))
					break
				end

				local pMonFld = Sirin.mainThread.g_Main.m_tblMonster:GetRecord(strCode)

				if not pMonFld then
					bSucc = false
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster looting script parse error! id: %s monster data not exists!\n", strCode))
					break
				end

				---@type table<integer, SirinLootRecord>
				local newMonsterLootTable = {}

				for k,v in ipairs(lootData) do
					repeat
						if type(v[1]) ~= "function" then
							bSucc = false
							Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster looting script parse error! id: script['%s'][%d][1] is not a function type!\n", strCode, k))
							break
						end

						if type(v[2]) ~= "number" or math.type(v[2]) ~= "integer" then
							bSucc = false
							Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster looting script parse error! id: script['%s'][%d][2] is not an integer type!\n", strCode, k))
							break
						end

						if v[2] < 0 or v[2] > 0x7FFF7FFF then
							bSucc = false
							Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster looting script parse error! id: script['%s'][%d][2] value out of range!\n", strCode, k))
							break
						end

						if v[2] == 0 then
							break
						end

						if type(v[4]) ~= "number" or math.type(v[4]) ~= "integer" then
							bSucc = false
							Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster looting script parse error! id: script['%s'][%d][4] is not an integer type!\n", strCode, k))
							break
						end

						if v[4] == 0 then
							break
						end

						if type(v[5]) ~= "number" or math.type(v[5]) ~= "integer" then
							bSucc = false
							Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster looting script parse error! id: script['%s'][%d][5] is not an integer type!\n", strCode, k))
							break
						end

						if v[5] == 0 then
							break
						end

						local newLootItems = {}

						for i = 1, v[5] do
							if not v[5 + i] then
								break
							end

							if type(v[5 + i]) ~= "string" then
								bSucc = false
								Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster looting script parse error! id: script['%s'][%d][%d] is not a string type!\n", strCode, k, 5 + i))
								break
							end

							if v[5 + i] == "0" then
								break
							end

							local nTableCode = Sirin.mainThread.GetItemTableCode(v[5 + i])

							if nTableCode == -1 then
								bSucc = false
								Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster looting script parse error! id: script['%s'][%d][%d] %s is not a valid item type!\n", strCode, k, 5 + i, v[5 + i]))
								break
							end

							local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(nTableCode):GetRecordByHash(v[5 + i], 2, 5)

							if not pFld then
								bSucc = false
								Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster looting script parse error! id: script['%s'][%d][%d] %s item code not exists!\n", strCode, k, 5 + i, v[5 + i]))
								break
							end

							---@type SirinLootItem
							local newLootItem = { nTableCode, pFld }
							table.insert(newLootItems, newLootItem)
						end

						if #newLootItems == 0 then
							break
						end

						---@type SirinLootRecord
						local newLootRecord = { v[1], v[2], v[4], newLootItems }
						table.insert(newMonsterLootTable, newLootRecord)
					until true
				end

				if #newMonsterLootTable > 0 then
					TmpItemLooting[pMonFld.m_dwIndex] = newMonsterLootTable
				end

			until true
		end

	until true

	if not bSucc then
		TmpItemLooting = nil
	end

	return bSucc
end

function SirinLootingMgr:onLoop()
	self.m_tLoopTime = Sirin.mainThread.g_dwCurTime

	for k,v in pairs (self.m_delayedDrop) do
		if v.dwDropTime < self.m_tLoopTime then
			local dropNum = #v.lootTable - v.dwNextDropIndex + 1

			if dropNum > 25 then
				dropNum = 25
			end

			local pBoxList = Sirin.mainThread.getEmptyItemBoxList(dropNum)

			for _,b in pairs(pBoxList) do
				local lootItem = v.lootTable[v.dwNextDropIndex]

				if lootItem then
					if self.m_bDebugLog then
						local emsg = string.format("Loot Drop (%d). id: map: %s layer: %d pos(%.2f, %.2f, %.2f)", v.dwNextDropIndex, v.pMap.m_pMapSet.m_strCode, v.wLayerIndex, v.pos[1], v.pos[2], v.pos[3])
						print(emsg)
					end

					if not Sirin.mainThread.createItemBox_Monster(b, lootItem[1], lootItem[2], 0, 0, v.pMap, v.wLayerIndex, v.pos[1], v.pos[2], v.pos[3], self.m_nBbossDropRange, false, v.dwOwnerObjSerial, v.wOwnerObjIndex, v.dwThrowerObjSerial, v.wThrowerObjIndex, v.pMonRecFld) then
						break
					end

					b.m_byThrowerID = ID_CHAR.monster
					b.m_dwPartyBossSerial = v.dwPartyBossSerial
					b.m_bPartyShare = v.bPartyShare
					b.m_bCompDgr = v.byOwnerUserDgr ~= 0
					v.dwNextDropIndex = v.dwNextDropIndex + 1
				end
			end

			local msg = {
				default = string.format("Items to drop remaining: %d", #v.lootTable - v.dwNextDropIndex + 1),
			}

			local nSecIndex = v.pMap:GetSectorIndex(v.pos[1], v.pos[3])
			local listPlayer = v.pMap:GetPlayerListInRadius(v.wLayerIndex, nSecIndex, 10, v.pos[1], v.pos[2], v.pos[3])

			for _,p in pairs (listPlayer) do
				NetMgr.privateAnnounceMsg(p, msg, 0xFFFF, ANN_TYPE.mid3, 0xFFFFFF00)
			end

			if v.dwNextDropIndex > #v.lootTable then
				self.m_delayedDrop[k] = nil
			else
				v.dwDropTime = self.m_tLoopTime + 1000
			end
		else
			local secRemain = math.floor((v.dwDropTime - self.m_tLoopTime) / 1000)

			if secRemain < v.dwAnnounceTime and v.dwNextDropIndex == 1 then
				v.dwAnnounceTime = secRemain

				local msg = {
					default = string.format("Seconds before reward drop: %d", secRemain + 1),
				}

				local nSecIndex = v.pMap:GetSectorIndex(v.pos[1], v.pos[3])
				local listPlayer = v.pMap:GetPlayerListInRadius(v.wLayerIndex, nSecIndex, 10, v.pos[1], v.pos[2], v.pos[3])

				for _,p in pairs (listPlayer) do
					NetMgr.privateAnnounceMsg(p, msg, 0xFFFF, ANN_TYPE.mid3, 0xFFFFFF00)
				end
			end
		end
	end
end

---@param pMonster CMonster
---@param pPlayer CPlayer
---@return boolean
function SirinLootingMgr:lootItemStd(pMonster, pPlayer)
	local bSuccDrop = false

	repeat
		if not pMonster.m_bStdItemLoot then
			break
		end

		local lootTable = ScriptItemLooting[pMonster.m_pMonRec.m_dwIndex]

		if not lootTable then
			break
		end

		local bPartyShare = false
		local pOwner = pPlayer
		local dwPartyBossSerial = 0xFFFFFFFF

		if pPlayer.m_pPartyMgr:IsPartyMode() then
			dwPartyBossSerial = pPlayer.m_pPartyMgr.m_pPartyBoss.m_id.dwSerial
			pOwner = pPlayer.m_pPartyMgr:GetLootAuthor()

			if not pOwner then
				bPartyShare = true
				pOwner = pPlayer
			end
		end

		local fDropRate = 0
		local fMonLvDiffRate = 1.0
		local fSTD_DROP_RATE = Sirin.mainThread.ITEM_ROOT_RATE
		local fPREMIUM_DROP_RATE = Sirin.mainThread.PCBANG_PRIMIUM_FAVOR__ITEM_DROP

		if pMonster.m_pMonRec.m_bMonsterCondition ~= 0 or not pPlayer:IsApplyPcbangPrimium() then
			fDropRate = fSTD_DROP_RATE
		else
			fDropRate = fPREMIUM_DROP_RATE
		end

		if pMonster.m_pMonRec.m_bMonsterCondition == 0 then
			if pPlayer:IsRidingUnit() then
				pPlayer.m_EP.m_bLock = false
			end

			fDropRate = fDropRate + (pPlayer.m_EP:GetEff_Have(_EFF_HAVE.Item_Drop_Prof) - 1.0)
			fDropRate = fDropRate + (pPlayer.m_EP:GetEff_Rate(_EFF_RATE.Potion_Item_Drop_Rate) - 1.0)
			fDropRate = fDropRate + (pPlayer.m_EP:GetEff_Have(_EFF_HAVE.Drop_Prof_Item1) - 1.0)

			if pPlayer:IsApplyPcbangPrimium() then
				local fRate = pPlayer.m_EP:GetEff_Have(_EFF_HAVE.Drop_Prof_Item2)

				if fRate > fPREMIUM_DROP_RATE then
					fDropRate = fDropRate + (fRate - fPREMIUM_DROP_RATE)
				end

				fRate = pPlayer.m_EP:GetEff_Have(_EFF_HAVE.Drop_Prof_Item3)

				if fRate > fPREMIUM_DROP_RATE then
					fDropRate = fDropRate + (fRate - fPREMIUM_DROP_RATE)
				end
			else
				fDropRate = fDropRate + (pPlayer.m_EP:GetEff_Have(_EFF_HAVE.Drop_Prof_Item2) - 1.0)
				fDropRate = fDropRate + (pPlayer.m_EP:GetEff_Have(_EFF_HAVE.Drop_Prof_Item3) - 1.0)
			end

			if pPlayer:IsRidingUnit() then
				pPlayer.m_EP.m_bLock = true
			end
		end

		if pPlayer:IsRidingUnit() then
			pPlayer.m_EP.m_bLock = false
		end

		local fBonusLv = pPlayer.m_EP:GetEff_Have(_EFF_HAVE.Mob_Lv_Lmt_Extend)

		if pPlayer:IsRidingUnit() then
			pPlayer.m_EP.m_bLock = true
		end

		local nDiffLv = pPlayer:GetLevel() - pMonster:GetLevel()

		if nDiffLv <= 0 then
			nDiffLv = math.floor(nDiffLv + fBonusLv)
		else
			nDiffLv = math.floor(nDiffLv - fBonusLv)
		end

		if pMonster.m_pMonRec.m_nUpLooting ~= -1 and pMonster.m_pMonRec.m_nUpLooting ~= 0 then
			nDiffLv = nDiffLv - pMonster.m_pMonRec.m_nUpLooting

			if nDiffLv == 0 then
				fMonLvDiffRate = monsterLevelDiffRate.same
			elseif nDiffLv < 0 then
				nDiffLv = math.abs(nDiffLv)
				nDiffLv = nDiffLv < 10 and nDiffLv or 10
				fMonLvDiffRate = monsterLevelDiffRate.small[nDiffLv]
			else
				nDiffLv = nDiffLv < 10 and nDiffLv or 10
				fMonLvDiffRate = monsterLevelDiffRate.big[nDiffLv]
			end

			if fMonLvDiffRate <= 0 then
				fMonLvDiffRate = 0.01
			end
		end

		---@type table<integer, SirinLootItem>
		local lootItems = {}

		for _,v in pairs(lootTable) do
			repeat
				if not v[1]() or #v[4] == 0 or v[3] == 0 or v[2] == 0 then
					break
				end

				local nLootCount = math.floor(v[3] * fDropRate + 0.5)

				for i = 1, nLootCount do
					local r = (math.random(0, 32767) << 16) + math.random(0, 32767)

					if pOwner.m_bLootFree or r < v[2] * fMonLvDiffRate then
						local pLootData = v[4][math.random(#v[4])]
						table.insert(lootItems, pLootData)
					end
				end
			until true
		end

		if #lootItems > 0 and self.m_bDropShuffle then
			bSuccDrop = true

			for i = #lootItems, 2, -1 do
				local j = math.random(i)
				lootItems[i], lootItems[j] = lootItems[j], lootItems[i]
			end
		end

		local bStat = true

		if Sirin.mainThread.g_Main.m_bReleaseServiceMode and pPlayer.m_byUserDgr > 0 then
			bStat = false
		end

		if pMonster.m_pMonRec.m_bMonsterCondition ~= 0 and self.m_nBossDropDelay > 0 then
			---@type SirinDelayedLootRecord
			local dropData = {
				dwDropTime = Sirin.mainThread.g_dwCurTime + self.m_nBossDropDelay * 1000,
				pMap = pMonster.m_pCurMap,
				wLayerIndex = pMonster.m_wMapLayerIndex,
				pos = {pMonster.m_fCurPos_x, pMonster.m_fCurPos_y, pMonster.m_fCurPos_z},
				dwOwnerObjSerial = pOwner.m_dwObjSerial,
				wOwnerObjIndex = pOwner.m_ObjID.m_wIndex,
				byOwnerUserDgr = pOwner.m_byUserDgr,
				dwThrowerObjSerial = pMonster.m_dwObjSerial,
				wThrowerObjIndex = pMonster.m_ObjID.m_wIndex,
				dwPartyBossSerial = dwPartyBossSerial,
				bPartyShare = bPartyShare,
				pMonRecFld = pMonster.m_pMonRec,
				lootTable = lootItems,
				dwNextDropIndex = 1,
				dwAnnounceTime = self.m_nBossDropDelay,
			}

			table.insert(self.m_delayedDrop, dropData)

			for _, v in pairs(lootItems) do
				Sirin.mainThread.CMonster__s_logTrace_Boss_Looting:Write(string.format("\t LootItem : %s", v[2].m_strCode))

				if bStat and v[1] < TBL_CODE.ring then
					if Sirin.mainThread.GetItemGrade(v[1], v[2].m_dwIndex) <= 0 then
						Sirin.mainThread.g_GameStatistics.m_day.dwDropStdItem_Evt = Sirin.mainThread.g_GameStatistics.m_day.dwDropStdItem_Evt + 1
					else
						Sirin.mainThread.g_GameStatistics.m_day.dwDropRareItem_Evt = Sirin.mainThread.g_GameStatistics.m_day.dwDropRareItem_Evt + 1
					end
				end
			end
		else
			for _, v in pairs(lootItems) do
				local pCon = Sirin.mainThread.makeLoot(v[1], v[2].m_dwIndex)
				Sirin.mainThread.createItemBoxForAutoLoot(pCon, pOwner, dwPartyBossSerial, bPartyShare, pMonster, 0, pMonster.m_pCurMap, pMonster.m_wMapLayerIndex, {pMonster.m_fCurPos_x, pMonster.m_fCurPos_y, pMonster.m_fCurPos_z}, false)

				if pMonster.m_pMonRec.m_bMonsterCondition == 1 then
					Sirin.mainThread.CMonster__s_logTrace_Boss_Looting:Write(string.format("\t LootItem : %s", v[2].m_strCode))
				end

				if bStat and v[1] < TBL_CODE.ring then
					if Sirin.mainThread.GetItemGrade(v[1], v[2].m_dwIndex) <= 0 then
						Sirin.mainThread.g_GameStatistics.m_day.dwDropStdItem_Evt = Sirin.mainThread.g_GameStatistics.m_day.dwDropStdItem_Evt + 1
					else
						Sirin.mainThread.g_GameStatistics.m_day.dwDropRareItem_Evt = Sirin.mainThread.g_GameStatistics.m_day.dwDropRareItem_Evt + 1
					end
				end
			end
		end

	until true

	return bSuccDrop
end

---@class SirinLootItem
---@field [1] integer byTableCode
---@field [2] _base_fld pFld
local SirinLootItem = {}

---@class SirinLootRecord
---@field [1] fun(): boolean canDropLoot()
---@field [2] integer rate
---@field [3] integer count
---@field [4] table<integer, SirinLootItem>
local SirinLootRecord = {}

---@class (exact) SirinDelayedLootRecord
---@field dwDropTime integer
---@field pMap CMapData
---@field wLayerIndex integer
---@field pos table<integer, number>
---@field dwOwnerObjSerial integer
---@field wOwnerObjIndex integer
---@field byOwnerUserDgr integer
---@field dwThrowerObjSerial integer
---@field wThrowerObjIndex integer
---@field dwPartyBossSerial integer
---@field bPartyShare boolean
---@field pMonRecFld _monster_fld
---@field lootTable table<integer, SirinLootItem>
---@field dwNextDropIndex integer
---@field dwAnnounceTime integer
local SirinDelayedLootRecord = {}
