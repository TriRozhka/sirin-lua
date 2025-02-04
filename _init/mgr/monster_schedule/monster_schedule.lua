---@param script SirinMonsterScheduleScript
---@return integer #Prev scheduled time
---@return integer #Next scheduled time
local function getScheduleTime(script)
	local tPrevScheduledTime = -1
	local tNextScheduledTime = 0x7FFFFFFFFFFFFFFF
	local tCurTime = os.time()

	repeat
		if type(script.schedule) ~= 'table' then
			break
		end

		local schedule = script.schedule

		if type(schedule.scheduleType) ~= 'string' then
			break
		end

		if type(schedule.intervals) ~= 'table' then
			break
		end

		local o = os.date("*t", tCurTime)
		local t = {}
		o.sec = 0

		if schedule.scheduleType == 'dayOfMonth' then
			for _,s in pairs(schedule.intervals) do
				t = clone(o)
				t.hour = 0
				t.min = 0
				t.day = s.val

				if s.hour then
					t.hour = s.hour
				end

				if s.minute then
					t.min = s.minute
				end

				local u = os.time(t)

				if u >= tCurTime then
					if u < tNextScheduledTime then
						tNextScheduledTime = u
					end

					t.month = t.month - 1

					if t.month == 0 then
						t.year = t.year - 1
						t.month = 12
					end

					u = os.time(t)

					if u > tPrevScheduledTime then
						tPrevScheduledTime = u
					end
				else
					if u > tPrevScheduledTime then
						tPrevScheduledTime = u
					end

					t.month = t.month + 1

					if t.month == 13 then
						t.year = t.year + 1
						t.month = 1
					end

					u = os.time(t)

					if u < tNextScheduledTime then
						tNextScheduledTime = u
					end
				end
			end

			do break end
		end

		if schedule.scheduleType == 'dayOfWeek' then
			for _,s in pairs(schedule.intervals) do
				t = clone(o)
				t.hour = 0
				t.min = 0
				local diff = s.val - t.wday

				if s.hour then
					t.hour = s.hour
				end

				if s.minute then
					t.min = s.minute
				end

				local u = os.time(t)

				if diff > 0 then
					local p = u - (7 - diff) * 24 * 60 * 60
					local f = u + diff * 24 * 60 * 60

					if p > tPrevScheduledTime then
						tPrevScheduledTime = p
					end

					if f < tNextScheduledTime then
						tNextScheduledTime = f
					end
				elseif diff < 0 then
					local p = u + diff * 24 * 60 * 60
					local f = u + (7 + diff) * 24 * 60 * 60

					if p > tPrevScheduledTime then
						tPrevScheduledTime = p
					end

					if f < tNextScheduledTime then
						tNextScheduledTime = f
					end
				else
					if u >= tCurTime then
						if u < tNextScheduledTime then
							tNextScheduledTime = u
						end

						u = u - 7 * 24 * 60 * 60

						if u > tPrevScheduledTime then
							tPrevScheduledTime = u
						end
					else
						if u > tPrevScheduledTime then
							tPrevScheduledTime = u
						end

						u = u + 7 * 24 * 60 * 60

						if u < tNextScheduledTime then
							tNextScheduledTime = u
						end
					end
				end
			end

			do break end
		end

		if schedule.scheduleType == 'day' then
			for _,s in pairs(schedule.intervals) do
				t = clone(o)
				t.hour = 0
				t.min = 0

				if s.hour then
					t.hour = s.hour
				end

				if s.minute then
					t.min = s.minute
				end

				local u = os.time(t)

				if u >= tCurTime then
					if u < tNextScheduledTime then
						tNextScheduledTime = u
					end

					u = u - 24 * 60 * 60

					if u > tPrevScheduledTime then
						tPrevScheduledTime = u
					end
				else
					if u > tPrevScheduledTime then
						tPrevScheduledTime = u
					end

					u = u + 24 * 60 * 60

					if u < tNextScheduledTime then
						tNextScheduledTime = u
					end
				end
			end

			do break end
		end

		if schedule.scheduleType == 'hour' then
			for _,s in pairs(schedule.intervals) do
				t = clone(o)
				t.min = 0

				if s.minute then
					t.min = s.minute
				end

				local u = os.time(t)

				if u >= tCurTime then
					if u < tNextScheduledTime then
						tNextScheduledTime = u
					end

					u = u - 60 * 60

					if u > tPrevScheduledTime then
						tPrevScheduledTime = u
					end
				else
					if u > tPrevScheduledTime then
						tPrevScheduledTime = u
					end

					u = u + 60 * 60

					if u < tNextScheduledTime then
						tNextScheduledTime = u
					end
				end
			end

			do break end
		end

		if schedule.scheduleType == 'delay' then
			local int = schedule.intervals[math.random(#schedule.intervals)] or 0

			tNextScheduledTime = tCurTime

			if int then
				if int.hour then
					tNextScheduledTime = tNextScheduledTime + 60 * 60 * int.hour
				end

				if int.minute then
					tNextScheduledTime = tNextScheduledTime + 60 * int.minute
				end
			end

			do break end
		end

	until true

	return tPrevScheduledTime, tNextScheduledTime
end

---@class SirinMonsterScheduleInterval
---@field val? integer
---@field hour? integer
---@field minute? integer
local SirinMonsterScheduleInterval = {}

---@class SirinMonsterSchedulePosition
---@field [1] CMapData map
---@field [2] integer layer
---@field [3] number position X
---@field [4] number position y
---@field [5] number position z
---@field [6] number range
local SirinMonsterSchedulePosition = {}

---@class SirinMonsterScheduleSchedule
---@field scheduleType string
---@field intervals table<integer, SirinMonsterScheduleInterval>
local SirinMonsterScheduleSchedule = {}

---@class (exact) SirinMonsterScheduleScript
---@field __index table
---@field tRuleStartTime integer
---@field tRuleEndTime integer
---@field monster _monster_fld
---@field schedule SirinMonsterScheduleSchedule
---@field positions table<integer, SirinMonsterSchedulePosition>
---@field window integer
---@field succRate integer
---@field duration integer
local SirinMonsterScheduleScript = {
	tRuleStartTime = 0,
	tRuleEndTime = 0x7FFFFFFFFFFFFFFF,
}

---@return SirinMonsterScheduleScript self
function SirinMonsterScheduleScript:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

---@param t? integer
---@return boolean
function SirinMonsterScheduleScript:isActive(t)
	local _t = t or MonsterScheduleMgr.m_tLoopTime
	return _t > self.tRuleStartTime and (self.tRuleEndTime == 0 or _t < self.tRuleEndTime)
end

---@class (exact) SirinMonsterSpawnRule
---@field __index table
---@field m_strScriptID string
---@field m_luaObj SirinMonster
---@field m_tNextScheduleRefreshTime integer
---@field m_tLastScheduleRefreshTime integer
---@field m_tNextBirthTime integer
---@field m_tLastBirthTime integer
---@field m_tLastDeathTime integer
---@field m_Script SirinMonsterScheduleScript
local SirinMonsterSpawnRule = {}

---@return SirinMonsterSpawnRule self
function SirinMonsterSpawnRule:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

---@param t integer
---@return boolean
function SirinMonsterSpawnRule:isInNextSummonWindow(t)
	if self.m_Script.window and self.m_Script.window > 0 then
		local w = math.floor(self.m_Script.window * 60 / 2)
		local tNextWindowMin, tNextWindowMax = self.m_tNextScheduleRefreshTime - w, self.m_tNextScheduleRefreshTime + w

		return t >= tNextWindowMin and t <= tNextWindowMax
	else
		return t == self.m_tNextScheduleRefreshTime
	end
end

function SirinMonsterSpawnRule:updateSummonTime()
	if self.m_Script.window and self.m_Script.window > 0  then
		local w = math.floor(self.m_Script.window * 60 / 2)
		local tNextWindowMin, tNextWindowMax = self.m_tNextScheduleRefreshTime - w, self.m_tNextScheduleRefreshTime + w

		if self.m_tNextBirthTime < tNextWindowMin or self.m_tNextBirthTime > tNextWindowMax then
			self.m_tNextBirthTime = self.m_tNextScheduleRefreshTime + math.random(-w, 0)
			Sirin.WritePrivateProfileStringA(self.m_strScriptID, "NextBirth", tostring(self.m_tNextBirthTime), MonsterScheduleMgr.pszSavePath)

			if MonsterScheduleMgr.m_bDebugLog then
				local emsg = string.format("Monster summon time update. id: %s next summon: %s", self.m_strScriptID, os.date(_, self.m_tNextBirthTime))
				print(os.date(_, os.time()) .. " " .. emsg)
				Sirin.WriteA(MonsterScheduleMgr.pszLogPath, emsg, true, true)
			end
		else
			if MonsterScheduleMgr.m_bDebugLog then
				local emsg = string.format("Monster summon time update. id: %s next summon: (unchanged) %s", self.m_strScriptID, os.date(_, self.m_tNextBirthTime))
				print(os.date(_, os.time()) .. " " .. emsg)
				Sirin.WriteA(MonsterScheduleMgr.pszLogPath, emsg, true, true)
			end
		end
	else
		if self.m_tNextBirthTime ~= self.m_tNextScheduleRefreshTime then
			self.m_tNextBirthTime = self.m_tNextScheduleRefreshTime
			Sirin.WritePrivateProfileStringA(self.m_strScriptID, "NextBirth", tostring(self.m_tNextBirthTime), MonsterScheduleMgr.pszSavePath)

			if MonsterScheduleMgr.m_bDebugLog then
				local emsg = string.format("Monster summon time update. id: %s next summon: %s", self.m_strScriptID, os.date(_, self.m_tNextBirthTime))
				print(os.date(_, os.time()) .. " " .. emsg)
				Sirin.WriteA(MonsterScheduleMgr.pszLogPath, emsg, true, true)
			end
		end
	end
end

---@class (exact) SirinMonster
---@field __index table
---@field m_strScriptID string
---@field m_pCObj? CMonster
---@field m_dwObjectSerial integer
---@field m_Rule SirinMonsterSpawnRule
local SirinMonster = {}

---@return boolean
function SirinMonster:isLive()
	return self.m_pCObj ~= nil
end

function SirinMonster:respawn()
	if self:isLive() then
		local pMap, wLayer, x, y, z = self.m_pCObj.m_pCurMap, self.m_pCObj.m_wMapLayerIndex, self.m_pCObj.m_fCurPos_x, self.m_pCObj.m_fCurPos_y, self.m_pCObj.m_fCurPos_z
		self:despawn()
		self.m_pCObj = Sirin.mainThread.createMonster(pMap, wLayer, x, y, z, self.m_Rule.m_Script.monster.m_strCode, true, true, true)

		if not self.m_pCObj then
			local emsg = string.format("Monster schedule re-spawn failure! id: %s", self.m_strScriptID)
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, emsg)
			Sirin.WriteA(MonsterScheduleMgr.pszLogPath, emsg, true, true)
		else
			self.m_dwObjectSerial = self.m_pCObj.m_dwObjSerial
			MonsterScheduleMgr.m_Monsteres[self.m_dwObjectSerial] = self

			if MonsterScheduleMgr.m_bDebugLog then
				local emsg = string.format("Monster re-birth. id: %s map: %s layer: %d pos(%.2f, %.2f, %.2f)", self.m_strScriptID, pMap.m_pMapSet.m_strCode, wLayer, x, y, z)
				print(os.date(_, os.time()) .. " " .. emsg)
				Sirin.WriteA(MonsterScheduleMgr.pszLogPath, emsg, true, true)
			end
		end
	else
		self:spawn()
	end
end

function SirinMonster:despawn()
	MonsterScheduleMgr.m_Monsteres[self.m_dwObjectSerial] = nil

	if self.m_pCObj then
		self.m_pCObj:Destroy(1, nil)
		self.m_pCObj = nil
	end
end

function SirinMonster:spawn()
	local s = self.m_Rule.m_Script.positions[math.random(#self.m_Rule.m_Script.positions)]
	local x, y, z = s[3], s[4], s[5]
	local r = false

	if s[6] and s[6] > 0 then
		r, x, y, z = s[1]:GetRandPosInRange(x, y, z, s[6])

		if not r then
			local emsg = string.format("Monster schedule GetRandPosInRange failure! id: %s map: %s layer: %d pos(%.2f, %.2f, %.2f)", self.m_strScriptID, s[1].m_pMapSet.m_strCode, s[2], s[3], s[4], s[5])
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, emsg)
			Sirin.WriteA(MonsterScheduleMgr.pszLogPath, emsg, true, true)
		end
	end

	self.m_pCObj = Sirin.mainThread.createMonster(s[1], s[2], x, y, z, self.m_Rule.m_Script.monster.m_strCode, true, true, true)

	if not self.m_pCObj then
		local emsg = string.format("Monster schedule spawn failure! id: %s", self.m_strScriptID)
		Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, emsg)
		Sirin.WriteA(MonsterScheduleMgr.pszLogPath, emsg, true, true)
	else
		self.m_dwObjectSerial = self.m_pCObj.m_dwObjSerial
		MonsterScheduleMgr.m_Monsteres[self.m_dwObjectSerial] = self

		if MonsterScheduleMgr.m_bDebugLog then
			local emsg = string.format("Monster birth. id: %s map: %s layer: %d pos(%.2f, %.2f, %.2f)", self.m_strScriptID, self.m_pCObj.m_pCurMap.m_pMapSet.m_strCode, self.m_pCObj.m_wMapLayerIndex, self.m_pCObj.m_fCurPos_x, self.m_pCObj.m_fCurPos_y, self.m_pCObj.m_fCurPos_z)
			print(os.date(_, os.time()) .. " " .. emsg)
			Sirin.WriteA(MonsterScheduleMgr.pszLogPath, emsg, true, true)
		end
	end
end

function SirinMonster:die()
	if MonsterScheduleMgr.m_bDebugLog then
		local emsg = string.format("Monster die. id: %s map: %s layer: %d pos(%.2f, %.2f, %.2f)", self.m_strScriptID, self.m_pCObj.m_pCurMap.m_pMapSet.m_strCode, self.m_pCObj.m_wMapLayerIndex, self.m_pCObj.m_fCurPos_x, self.m_pCObj.m_fCurPos_y, self.m_pCObj.m_fCurPos_z)
		print(os.date(_, self.m_Rule.m_tLastDeathTime) .. " " .. emsg)
		Sirin.WriteA(MonsterScheduleMgr.pszLogPath, emsg, true, true)
	end

	MonsterScheduleMgr.m_Monsteres[self.m_dwObjectSerial] = nil
	self.m_Rule.m_tLastDeathTime = os.time()
	self.m_pCObj = nil
	Sirin.WritePrivateProfileStringA(self.m_strScriptID, "LastDeath", tostring(self.m_Rule.m_tLastDeathTime), MonsterScheduleMgr.pszSavePath)

	if self.m_Rule.m_Script.schedule.scheduleType == "delay" then
		local l, n = getScheduleTime(self.m_Rule.m_Script)
		self.m_Rule.m_tLastScheduleRefreshTime = l
		self.m_Rule.m_tNextScheduleRefreshTime = n
		self.m_Rule:updateSummonTime()
	end
end

---@return SirinMonster self
function SirinMonster:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

---@class (exact) SirinMonsterScheduleMgr
---@field __index table
---@field m_SpawnRules table<string, SirinMonsterSpawnRule>
---@field m_Monsteres table<integer, SirinMonster>
---@field m_bDebugLog boolean
---@field m_tLoopTime integer
---@field m_strUUID string
---@field pszLogPath string
---@field pszSavePath string
local SirinMonsterScheduleMgr = {
	m_SpawnRules = {},
	m_Monsteres = {},
	m_bDebugLog = false,
	m_tLoopTime = 0,
	m_strUUID = Sirin.getUUIDv4(),
	pszLogPath = '.\\sirin-log\\guard\\LuaMonsterSchedule.log',
	pszSavePath = '..\\SystemSave\\LuaMonsterSchedule.ini',
}

---@return SirinMonsterScheduleMgr self
function SirinMonsterScheduleMgr:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

MonsterScheduleMgr = SirinMonsterScheduleMgr:new()

---@param pMonster CMonster
---@param dwOldSerial integer
function SirinMonsterScheduleMgr:onMonsterTransport(pMonster, dwOldSerial)
	if self.m_Monsteres[dwOldSerial] then
		self.m_Monsteres[pMonster.m_dwObjSerial] = self.m_Monsteres[dwOldSerial]
		self.m_Monsteres[dwOldSerial] = nil
	end
end

---@param pMonster CMonster
function SirinMonsterScheduleMgr:onMonsterDestroy(pMonster)
	if self.m_Monsteres[pMonster.m_dwObjSerial] then
		self.m_Monsteres[pMonster.m_dwObjSerial]:die()
	end
end

---@return boolean
function SirinMonsterScheduleMgr:loadScripts()
	local bSucc = false

	repeat
		TmpMonsterSchedule = FileLoader.LoadChunkedTable(".\\sirin-lua\\MonsterSchedule")

		if not TmpMonsterSchedule then
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Failed to load 'Monster schedule' scripts!\n")
			Sirin.WriteA(self.pszLogPath, "Failed to load 'Monster schedule' scripts!\n", true, true)
			break
		end

		if not self:validateScriptData() then
			break
		end

		self:init()
		bSucc = true
	until true

	return bSucc
end

---@return boolean #Is script data valid
function SirinMonsterScheduleMgr:validateScriptData()
	local bSucc = true

	repeat
		local luaScript = TmpMonsterSchedule

		if type(luaScript) ~= 'table' then
			bSucc = false
			break
		end

		for strCode,monster_data in pairs(luaScript) do
			repeat
				local newSchedule = SirinMonsterScheduleScript:new()

				if monster_data.ruleStartTime then
					if type(monster_data.ruleStartTime) ~= "string" then
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'ruleStartTime' is not a string type!\n", strCode))
						break
					end

					if not monster_data.ruleStartTime:find("%d%d%-%d%d%-%d%d%d%d %d%d:%d%d:%d%d") then
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'ruleStartTime' invalid time format!\n", strCode))
						break
					end

					local d, m, y, h, mi, se = monster_data.ruleStartTime:match("(%d+)-(%d+)-(%d+)%s+(%d+):(%d+):(%d+)")
					newSchedule.tRuleStartTime = os.time{year = y, month = m, day = d, hour = h, min = mi, sec = se}
				end

				if monster_data.ruleEndTime then
					if type(monster_data.ruleEndTime) ~= "string" then
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'ruleEndTime' is not a string type!\n", strCode))
						break
					end

					if not monster_data.ruleEndTime:find("%d%d%-%d%d%-%d%d%d%d %d%d:%d%d:%d%d") then
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'ruleEndTime' invalid time format!\n", strCode))
						break
					end

					local d, m, y, h, mi, se = monster_data.ruleEndTime:match("(%d+)-(%d+)-(%d+)%s+(%d+):(%d+):(%d+)")
					newSchedule.tRuleEndTime = os.time{year = y, month = m, day = d, hour = h, min = mi, sec = se}
				end

				if type(monster_data.monsterCode) ~= "string" then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'monsterCode' is not a string type!\n", strCode))
					break
				end

				newSchedule.monster = Sirin.mainThread.baseToMonsterCharacter(Sirin.mainThread.g_Main.m_tblMonster:GetRecord(monster_data.monsterCode))

				if not newSchedule.monster then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'monsterCode'(%s) not exists!\n", strCode, monster_data.monsterCode))
					break
				end

				if type(monster_data.schedule) ~= "table" then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'schedule' is not a table type!\n", strCode))
					break
				end

				if type(monster_data.schedule.scheduleType) ~= "string" then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'schedule.scheduleType' is not a string type!\n", strCode))
					break
				end

				local schedule_types = { "hour", "day", "dayOfWeek", "dayOfMonth", "delay" }
				bSucc = false

				for _,v in pairs(schedule_types) do
					if v == monster_data.schedule.scheduleType then
						bSucc = true
						break
					end
				end

				if not bSucc then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'schedule.scheduleType' invalid value!\n", strCode))
					break
				end

				if type(monster_data.schedule.intervals) ~= "table" then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'schedule.intervals' is not a table type!\n", strCode))
					break
				end

				for k,v in pairs(monster_data.schedule.intervals) do
					if type(v) ~= "table" then
						bSucc = false
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'schedule.intervals[%s]' is not a table type!\n", strCode, tostring(k)))
						break
					end

					if not v.hour and not v.minute and not v.val then
						Sirin.console.LogEx(ConsoleForeground.YELLOW, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'schedule.intervals[%s]' does not contain nor 'val', nor 'hour', nor 'minute' parameters!\n", strCode, tostring(k)))
					end
				end

				if not bSucc then
					break
				end

				newSchedule.schedule = monster_data.schedule

				if type(monster_data.positions) ~= "table" then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'positions' is not a table type!\n", strCode))
					break
				end

				newSchedule.positions = {}

				for k,v in pairs(monster_data.positions) do
					if type(v) ~= "table" then
						bSucc = false
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'positions[%s]' is not a table type!\n", strCode, tostring(k)))
						break
					end

					if type(v[1]) ~= "string" then
						bSucc = false
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'positions[%s][1]' is not a string type!\n", strCode, tostring(k)))
						break
					end

					local pMap = Sirin.mainThread.getMapData(v[1])

					if not pMap then
						bSucc = false
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'positions[%s][1]' is not a valid map code!\n", strCode, tostring(k)))
						break
					end

					local pos_data = {}
					table.insert(pos_data, pMap)

					if type(v[2]) ~= "number" or math.type(v[2]) ~= "integer" then
						bSucc = false
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'positions[%s][2]' is not an integer type!\n", strCode, tostring(k)))
						break
					end

					local MapFld = Sirin.mainThread.baseToMap(pMap.m_pMapSet)

					if MapFld.m_nMapType ~= 0 and v[2] >= MapFld.m_nLayerNum then
						bSucc = false
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'positions[%s][2]' layer id (%d) >= Max layer (%d) !\n", strCode, tostring(k), v[2], MapFld.m_nLayerNum))
						break
					end

					if MapFld.m_nMapType == 0 and v[2] ~= 0 then
						bSucc = false
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'positions[%s][2]' layer id (%d) != 0 (%d) !\n", strCode, tostring(k), v[2], MapFld.m_nLayerNum))
						break
					end

					table.insert(pos_data, v[2])

					for i = 3, 5 do
						if type(v[i]) ~= "number" then
							bSucc = false
							Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'positions[%s][%d]' is not a numeric type!\n", strCode, tostring(k), i))
							break
						end
					end

					if not bSucc then
						break
					end

					if not pMap:IsMapIn(v[3], v[4], v[5]) then
						bSucc = false
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'positions[%s]' not in Map range!\n", strCode, tostring(k)))
						break
					end

					if pMap.m_Level:GetNextYposForServer(v[3], v[4], v[5]) ~= 1 then
						bSucc = false
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'positions[%s]' there is no valid Y coordinate for this position!\n", strCode, tostring(k)))
						break
					end

					table.insert(pos_data, v[3])
					table.insert(pos_data, v[4])
					table.insert(pos_data, v[5])
					table.insert(pos_data, v[6] or 0)

					if v[6] and (type(v[6]) ~= "number" or math.type(v[6]) ~= "integer") then
						bSucc = false
						Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'positions[%s][6]' is not an integer type!\n", strCode, tostring(k)))
						break
					end

					table.insert(newSchedule.positions, pos_data)
				end

				if not bSucc then
					break
				end

				if monster_data.window and type(monster_data.window) ~= "number" then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'window' is not a numeric type!\n", strCode))
					break
				end

				newSchedule.window = monster_data.window and math.floor(monster_data.window) or 0

				if monster_data.succRate and type(monster_data.succRate) ~= "number" then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'succRate' is not a numeric type!\n", strCode))
					break
				end

				newSchedule.succRate = monster_data.succRate and math.floor(monster_data.succRate) or 100

				if monster_data.duration and type(monster_data.duration) ~= "number" then
					Sirin.console.LogEx(ConsoleForeground.RED, ConsoleBackground.BLACK, string.format("Lua. Monster schedule script parse error! id: %s 'duration' is not a numeric type!\n", strCode))
					break
				end

				newSchedule.duration = monster_data.duration and math.floor(monster_data.duration) or 0
				TmpMonsterSchedule[strCode] = newSchedule

			until true
		end

		if not bSucc then
			TmpMonsterSchedule = nil
			Sirin.WriteA(self.pszLogPath, "SirinMonsterScheduleMgr:validateScriptData(...) bSucc == false!\n", true, true)
		end

	until true

	return bSucc
end

function SirinMonsterScheduleMgr:onLoop()
	self.m_tLoopTime = os.time()

	for k,v in pairs(self.m_SpawnRules) do
		if v.m_Script:isActive() then
			if v.m_luaObj:isLive() and v.m_Script.duration > 0 and self.m_tLoopTime > v.m_tLastBirthTime + v.m_Script.duration then
				v.m_luaObj:despawn()
				v.m_tLastDeathTime = self.m_tLoopTime
				Sirin.WritePrivateProfileStringA(k, "LastDeath", tostring(v.m_tLastDeathTime), self.pszSavePath)

				if v.m_Script.schedule.scheduleType == "delay" then
					local l, n = getScheduleTime(v.m_Script)
					v.m_tLastScheduleRefreshTime = l
					v.m_tNextScheduleRefreshTime = n
					v:updateSummonTime()
				end

				if self.m_bDebugLog then
					local emsg = string.format("Monster schedule duration despawn id: %s", k)
					print(os.date(_, self.m_tLoopTime) .. " " .. emsg)
					Sirin.WriteA(self.pszLogPath, emsg, true, true)
				end
			end

			if self.m_tLoopTime > v.m_tNextScheduleRefreshTime and v.m_Script.schedule.scheduleType ~= "delay" then
				local l, n = getScheduleTime(v.m_Script)
				v.m_tLastScheduleRefreshTime = l
				v.m_tNextScheduleRefreshTime = n
			end

			if not v.m_luaObj:isLive() then
				if v.m_tNextBirthTime > v.m_tLastBirthTime and self.m_tLoopTime > v.m_tNextBirthTime and v.m_Script:isActive(v.m_tNextBirthTime) then
					v.m_tLastBirthTime = v.m_tNextBirthTime
					Sirin.WritePrivateProfileStringA(k, "LastBirth", tostring(v.m_tLastBirthTime), self.pszSavePath)

					if math.random(100) <= v.m_Script.succRate then
						v.m_luaObj:spawn()
					else
						if self.m_bDebugLog then
							local emsg = string.format("Monster schedule spawn failure (random)! id: %s", k)
							print(os.date(_, self.m_tLoopTime) .. " " .. emsg)
							Sirin.WriteA(self.pszLogPath, emsg, true, true)
						end
					end
				end
			end

			if self.m_tLoopTime > v.m_tNextBirthTime and not v:isInNextSummonWindow(v.m_tNextBirthTime) and v.m_Script.schedule.scheduleType ~= "delay" then
				v:updateSummonTime()
			end
		else
			v.m_tNextScheduleRefreshTime = 0
			v.m_tNextBirthTime = 0
			v.m_tLastBirthTime = 0
			v.m_tLastDeathTime = 0
			Sirin.WritePrivateProfileStringA(k, "NextBirth", "0", self.pszSavePath)
			Sirin.WritePrivateProfileStringA(k, "LastBirth", "0", self.pszSavePath)
			Sirin.WritePrivateProfileStringA(k, "LastDeath", "0", self.pszSavePath)

			if v.m_luaObj:isLive() then
				v.m_luaObj:despawn()

				if self.m_bDebugLog then
					local emsg = string.format("Monster schedule inactive despawn id: %s", k)
					print(os.date(_, self.m_tLoopTime) .. " " .. emsg)
					Sirin.WriteA(self.pszLogPath, emsg, true, true)
				end
			end
		end
	end
end

function SirinMonsterScheduleMgr:saveState()
	local t = {}

	for _,v in pairs(self.m_SpawnRules) do
		t[v.m_strScriptID] = { Sirin.mainThread.objectToVoid(v.m_luaObj.m_pCObj), v.m_tNextBirthTime, v.m_tLastBirthTime, v.m_tLastDeathTime }
	end

	local Ctx = Sirin.luaThreadManager.LuaGetThread("sirin.guard.data")

	Ctx:Lock()

	Sirin.luaThreadManager.CopyToContext(Ctx, "MonsterActiveData", t)

	Ctx:Unlock()
end

function SirinMonsterScheduleMgr:init()
	local t = {}
	local Ctx = Sirin.luaThreadManager.LuaGetThread("sirin.guard.data")

	Ctx:Lock()

	if Sirin.luaThreadManager.IsExistGlobal(Ctx, "MonsterActiveData") then
		t = Sirin.luaThreadManager.CopyFromContext(Ctx, "MonsterActiveData")
		Sirin.luaThreadManager.DeleteGlobal(Ctx, "MonsterActiveData")
	end

	Ctx:Unlock()

	if TmpMonsterSchedule then
		---@type table<string, SirinMonsterScheduleScript>
		ScriptMonsterSchedule = TmpMonsterSchedule
		TmpMonsterSchedule = nil
	end

	if type(ScriptMonsterSchedule) ~= 'table' then
		return
	end

	self.m_Monsteres = {}
	local oldRules = self.m_SpawnRules
	self.m_SpawnRules = {}
	self.m_tLoopTime = os.time()

	for k, v in pairs(ScriptMonsterSchedule) do
		local newRule = SirinMonsterSpawnRule:new()
		self.m_SpawnRules[k] = newRule
		newRule.m_Script = v
		newRule.m_strScriptID = k
		newRule.m_luaObj = oldRules[k] and oldRules[k].m_luaObj or SirinMonster:new()
		newRule.m_luaObj.m_Rule = newRule
		newRule.m_luaObj.m_strScriptID = k

		local lastScheduleUpdate, nextScheduleUpdate = getScheduleTime(v)
		newRule.m_tNextScheduleRefreshTime = nextScheduleUpdate
		newRule.m_tLastScheduleRefreshTime = lastScheduleUpdate

		local bShouldBeSpawned = false

		if oldRules[k] then
			newRule.m_tNextBirthTime = oldRules[k].m_tNextBirthTime
			newRule.m_tLastBirthTime = oldRules[k].m_tLastBirthTime
			newRule.m_tLastDeathTime = oldRules[k].m_tLastDeathTime
			bShouldBeSpawned = newRule.m_luaObj:isLive()
		elseif t[k] then
			newRule.m_luaObj.m_pCObj = Sirin.mainThread.objectToMonster(Sirin.mainThread.voidToObject(t[k][1]))

			if newRule.m_luaObj:isLive() then
				bShouldBeSpawned = true
				newRule.m_luaObj.m_dwObjectSerial = newRule.m_luaObj.m_pCObj.m_dwObjSerial
			end

			newRule.m_tNextBirthTime = t[k][2]
			newRule.m_tLastBirthTime = t[k][3]
			newRule.m_tLastDeathTime = t[k][4]
			t[k] = nil
		else
			local len, str = Sirin.GetPrivateProfileStringA(k, "NextBirth", "0", self.pszSavePath)
			newRule.m_tNextBirthTime = tonumber(str) or 0
			len, str = Sirin.GetPrivateProfileStringA(k, "LastBirth", "0", self.pszSavePath)
			newRule.m_tLastBirthTime = tonumber(str) or 0
			len, str = Sirin.GetPrivateProfileStringA(k, "LastDeath", "0", self.pszSavePath)
			newRule.m_tLastDeathTime = tonumber(str) or 0
			bShouldBeSpawned = newRule.m_tLastBirthTime > newRule.m_tLastDeathTime
		end

		if not newRule.m_Script:isActive() then
			bShouldBeSpawned = false
			newRule.m_tNextBirthTime = 0
			newRule.m_tLastBirthTime = 0
			newRule.m_tLastDeathTime = 0
			Sirin.WritePrivateProfileStringA(k, "NextBirth", "0", self.pszSavePath)
			Sirin.WritePrivateProfileStringA(k, "LastBirth", "0", self.pszSavePath)
			Sirin.WritePrivateProfileStringA(k, "LastDeath", "0", self.pszSavePath)
		else
			if newRule.m_tNextBirthTime == 0 then
				newRule:updateSummonTime()
			end

			if not bShouldBeSpawned and newRule.m_tNextBirthTime > newRule.m_tLastBirthTime and self.m_tLoopTime > newRule.m_tNextBirthTime and newRule.m_Script:isActive(newRule.m_tNextBirthTime) then
				bShouldBeSpawned = true
				newRule.m_tLastBirthTime = newRule.m_tNextBirthTime
				Sirin.WritePrivateProfileStringA(k, "LastBirth", tostring(newRule.m_tLastBirthTime), self.pszSavePath)
			end
		end

		if newRule.m_luaObj:isLive()then
			if not bShouldBeSpawned  then
				newRule.m_luaObj:despawn()
			elseif v.monster.m_dwIndex ~= newRule.m_luaObj.m_pCObj.m_pMonRec.m_dwIndex then
				newRule.m_luaObj:respawn()
			else
				self.m_Monsteres[newRule.m_luaObj.m_dwObjectSerial] = newRule.m_luaObj
			end
		end

		if bShouldBeSpawned and not newRule.m_luaObj:isLive() then
			newRule.m_luaObj:spawn()
		end

		oldRules[k] = nil
	end

	for k, v in pairs(t) do
		local pMon = Sirin.mainThread.objectToMonster(Sirin.mainThread.voidToObject(v[1]))

		if pMon then
			pMon:Destroy(1, nil)
		end

		Sirin.WritePrivateProfileStringA(k, "NextBirth", "0", self.pszSavePath)
		Sirin.WritePrivateProfileStringA(k, "LastBirth", "0", self.pszSavePath)
		Sirin.WritePrivateProfileStringA(k, "LastDeath", "0", self.pszSavePath)
	end

	for k, v in pairs(oldRules) do
		if v.m_luaObj:isLive() then
			v.m_luaObj:despawn()
		end

		Sirin.WritePrivateProfileStringA(k, "NextBirth", "0", self.pszSavePath)
		Sirin.WritePrivateProfileStringA(k, "LastBirth", "0", self.pszSavePath)
		Sirin.WritePrivateProfileStringA(k, "LastDeath", "0", self.pszSavePath)
	end
end