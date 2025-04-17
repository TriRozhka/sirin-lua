---@class (exact) sirinDummyRift
---@field __index table
---@field m_strScriptID string
---@field m_pCObj? CDummyRift
---@field m_LuaScript table
---@field m_bOpen boolean
---@field m_bReOpen boolean
---@field m_tNextOpenTime integer
---@field m_tNextCloseTime integer
---@field m_ExitDummyGate? sirinDummyRift
---@field m_pDstMap? CMapData
---@field m_DstPos table
---@field m_pSrcMap? CMapData
---@field m_nUseLeft integer
---@field m_bDelete boolean
local sirinDummyRift = {
	m_strScriptID = "",
	m_pCObj = nil,
	m_LuaScript = {},
	m_bOpen = false,
	m_bReOpen = false,
	m_tNextOpenTime = -1,
	m_tNextCloseTime = -1,
	m_ExitDummyGate = nil, -- lua object ref SirinDummyRift or SirinRift
	m_pDstMap = nil, -- C object ptr CMapData
	m_DstPos = {}, -- lua table ref
	m_pSrcMap = nil, -- C object ptr CMapData
	m_nUseLeft = -1,
	m_bDelete = true, -- flag to delete ExitGates from container when closed
}

---@return sirinDummyRift self
function sirinDummyRift:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

---@class sirinRift: sirinDummyRift
local sirinRift = sirinDummyRift:new{m_bDelete = false}

---@class (exact) sirinRiftMgr
---@field m_bSaveState boolean
---@field m_tLoopTime integer
---@field m_Gates table<string, sirinRift>
---@field m_ListGates table<string, sirinDummyRift>
---@field m_bDebugLog boolean
---@field m_strUUID string
---@field m_pszModReturnGateLogPath string
---@field m_pszModReturnGateConfigPath string
---@field initHooks fun()
---@field init fun()
---@field uninit fun()
---@field loadScripts fun(): boolean
---@field validateScriptData fun(): boolean
---@field isSaveState fun(): boolean
---@field setSaveState fun(bSet: boolean)
---@field getRift fun(pCobj: CDummyRift): sirinDummyRift?
---@field addRift fun(pCobj: CDummyRift, pRift: sirinDummyRift)
---@field removeRift fun(pCobj: CDummyRift)
---@field saveState fun()
---@field createRift fun(pCobj: CDummyRift)
---@field destroyRift fun(pCobj: CDummyRift)
---@field onLoop fun()
---@field getLoopTime fun(): integer
---@field canUseRift fun(pRift: sirinDummyRift, pPlayer: CPlayer): integer
---@field onUse fun(pRift:sirinDummyRift, pPlayer: CPlayer)
local sirinRiftMgr = {
	m_bSaveState = true,
	m_tLoopTime = os.time(),
	m_Gates = {},
	m_ListGates = {},
	m_bDebugLog = true,
	m_strUUID = 'sirin.lua.sirinRiftMgr',
	m_pszModReturnGateLogPath = '.\\sirin-log\\guard\\ModReturnGate.log',
	m_pszModReturnGateConfigPath = '..\\SystemSave\\ModReturnGate.ini',
}

local pszMapType = { "src", "dst" }
local armorParts = { "_upper", "_lower", "_gloves", "_shoes", "_helmet", "_shield", "_weapon", "_cloak" }
local timeInterval = { "year", "month", "day", "hour", "minute", "second" }
local limitMin = { 0, 1, 1, 0, 0, 0 }
local limitMax = { 0x7FFFFFFFFFFFFFFF, 12, 31, 23, 59, 59 }

function sirinRiftMgr.initHooks()
	SirinLua.HookMgr.addHook("CDummyRift__CDummyRift_ctor", HOOK_POS.original, sirinRiftMgr.m_strUUID, sirinRiftMgr.createRift)
	SirinLua.HookMgr.addHook("CDummyRift__CDummyRift_dtor", HOOK_POS.original, sirinRiftMgr.m_strUUID, sirinRiftMgr.destroyRift)
	SirinLua.HookMgr.addHook("CDummyRift__Enter", HOOK_POS.original, sirinRiftMgr.m_strUUID,
		---@param pCObj CDummyRift
		---@param pPlayer CPlayer
		---@return integer
		function (pCObj, pPlayer)
			local rift = sirinRiftMgr.getRift(pCObj)
			if rift then return rift:Enter(pPlayer) end
			return 3
		end
	)
	SirinLua.HookMgr.addHook("CDummyRift__Close", HOOK_POS.original, sirinRiftMgr.m_strUUID,
		---@param pCObj CDummyRift
		function (pCObj)
			local rift = sirinRiftMgr.getRift(pCObj)
			if rift then rift:Close() end
		end
	)
	SirinLua.HookMgr.addHook("CDummyRift__IsClose", HOOK_POS.original, sirinRiftMgr.m_strUUID,
		---@param pCObj CDummyRift
		---@return boolean
		function (pCObj)
			local rift = sirinRiftMgr.getRift(pCObj)
			if rift then return rift:IsClose() end
			return true
		end
	)
	SirinLua.HookMgr.addHook("CDummyRift__IsValidOwner", HOOK_POS.original, sirinRiftMgr.m_strUUID,
		---@param pCObj CDummyRift
		---@return boolean
		function (pCObj)
			local rift = sirinRiftMgr.getRift(pCObj)
			if rift then return rift:IsValidOwner() end
			return true
		end
	)
	SirinLua.HookMgr.addHook("CDummyRift__SendMsg_Create", HOOK_POS.original, sirinRiftMgr.m_strUUID,
		---@param pCObj CDummyRift
		function (pCObj)
			local rift = sirinRiftMgr.getRift(pCObj)
			if rift then rift:SendMsg_Create() end
		end
	)
	SirinLua.HookMgr.addHook("CDummyRift__SendMsg_Destroy", HOOK_POS.original, sirinRiftMgr.m_strUUID,
		---@param pCObj CDummyRift
		function (pCObj)
			local rift = sirinRiftMgr.getRift(pCObj)
			if rift then rift:SendMsg_Destroy() end
		end
	)
	SirinLua.HookMgr.addHook("CDummyRift__SendMsg_FixPosition", HOOK_POS.original, sirinRiftMgr.m_strUUID,
		---@param pCObj CDummyRift
		---@param nIndex integer
		function (pCObj, nIndex)
			local rift = sirinRiftMgr.getRift(pCObj)
			if rift then rift:SendMsg_FixPosition(nIndex) end
		end
	)
	SirinLua.HookMgr.addHook("CDummyRift__SendMsg_MovePortal", HOOK_POS.original, sirinRiftMgr.m_strUUID,
		---@param pCObj CDummyRift
		---@param pPlayer CPlayer
		function (pCObj, pPlayer)
			local rift = sirinRiftMgr.getRift(pCObj)
 			if rift then rift:SendMsg_MovePortal(pPlayer) end
		end
	)
end

---@param bSet boolean
function sirinRiftMgr.setSaveState(bSet)
	sirinRiftMgr.m_bSaveState = bSet
end

---@return boolean m_bSaveState
function sirinRiftMgr.isSaveState()
	return sirinRiftMgr.m_bSaveState
end

---@param pRift CDummyRift
---@return sirinDummyRift?
function sirinRiftMgr.getRift(pRift)
	return sirinRiftMgr.m_ListGates[pRift.m_strObjectUUID]
end

---@param pRift CDummyRift
---@param pLuaRift sirinDummyRift
function sirinRiftMgr.addRift(pRift, pLuaRift)
	sirinRiftMgr.m_ListGates[pRift.m_strObjectUUID] = pLuaRift
end

---@param pRift CDummyRift
function sirinRiftMgr.removeRift(pRift)
	sirinRiftMgr.m_ListGates[pRift.m_strObjectUUID] = nil
end

---@return boolean
function sirinRiftMgr.loadScripts()
	local bSucc = false

	repeat
		SirinTmp_DynamicPortals = FileLoader.LoadChunkedTable(".\\sirin-lua\\threads\\main\\ReloadableScripts\\Rifts")

		if not SirinTmp_DynamicPortals then
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Failed to load 'Rifts' scripts!\n")
			Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, "Failed to load 'Rifts' scripts!\n", true, true)
			break
		end

		if not sirinRiftMgr.validateScriptData() then
			break
		end

		sirinRiftMgr.uninit()
		sirinRiftMgr.init()
		bSucc = true
	until true

	return bSucc
end

---@return boolean #Is script data valid
function sirinRiftMgr.validateScriptData()
	local bSucc = true

	repeat
		local luaScript = SirinTmp_DynamicPortals

		if type(luaScript) ~= 'table' then
			bSucc = false
			break
		end

		for strCode,portal_data in pairs(luaScript) do
			repeat
				if type(portal_data) ~= 'table' then
					bSucc = false
					Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s invalid format!\n", strCode), true, true)
					break
				end

				if type(portal_data.portalType) ~= 'number' then
					bSucc = false
					Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s portalType invalid format!\n", strCode), true, true)
					break
				end

				if portal_data.portalType ~= 0 then
					bSucc = false
					Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s portalType out of range!\n", strCode), true, true)
					break
				end

				for _,t in ipairs(pszMapType) do
					repeat
						local pszBufr = string.format("%sMap", t)

						if not portal_data[pszBufr] or type(portal_data[pszBufr]) ~= 'string' then
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s %s invalid!\n", strCode, pszBufr), true, true)
							bSucc = false
							break
						end

						local strMapName = portal_data[pszBufr]
						local pMap = Sirin.mainThread.getMapData(strMapName)

						if not pMap then
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s %s (%s) not found!\n", strCode, pszBufr, strMapName), true, true)
							bSucc = false
							break
						end

						portal_data[pszBufr] = pMap

						pszBufr = string.format("%sPos", t)

						if not portal_data[pszBufr] or type(portal_data[pszBufr]) ~= 'table' or #portal_data[pszBufr] == 0 then
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s %s invalid format!\n", strCode, pszBufr), true, true)
							bSucc = false
							break
						end

						for dwIndex,pos in pairs(portal_data[pszBufr]) do
							repeat
								if not pos or type(pos) ~= 'table' or #pos < 4 then
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s %s[%d] invalid format!\n", strCode, pszBufr, dwIndex), true, true)
									bSucc = false
									break
								end

								for j = 1, 4 do
									if type(pos[j]) ~= 'number' then
										bSucc = false
										break
									end
								end

								if not bSucc then
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s %s[%d] invalid format!\n", strCode, pszBufr, dwIndex), true, true)
									break
								end

								if not pMap:IsMapIn(pos[1], pos[2], pos[3]) then
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s %s[%d] not in Map range!\n", strCode, pszBufr, dwIndex), true, true)
									bSucc = false
									break
								end

								if pMap.m_Level:GetNextYposForServer(pos[1], pos[2], pos[3]) ~= 1 then
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s %s[%d] there is no valid Y coordinate for this position!\n", strCode, pszBufr, dwIndex), true, true)
									bSucc = false
									break
								end

								local MapFld = Sirin.mainThread.baseToMap(pMap.m_pMapSet)

								if MapFld.m_nMapType ~= 0 and pos[4] >= MapFld.m_nLayerNum then
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s layer id (%d) >= Max layer (%d) !\n", strCode, pos[4], MapFld.m_nLayerNum), true, true)
									bSucc = false
									break
								end

								if MapFld.m_nMapType == 0 and pos[4] ~= 0 then
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s layer id (%d) != 0 (%d) !\n", strCode, pos[4], MapFld.m_nLayerNum), true, true)
									bSucc = false
									break
								end

							until true

							if not bSucc then
								break
							end
						end

					until true

					if not bSucc then
						break
					end
				end

				if not bSucc then
					break
				end

				if portal_data.exitGateType then
					if type(portal_data.exitGateType) ~= 'number' then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s exitGateType invalid format!\n", strCode), true, true)
						break
					end

					if portal_data.exitGateType < 0 or portal_data.exitGateType > 2 then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s exitGateType out of range!\n", strCode), true, true)
						break
					end
				end

				if portal_data.exitGateDelay then
					if type(portal_data.exitGateDelay) ~= 'number' then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s exitGateDelay invalid format!\n", strCode), true, true)
						break
					end

					if portal_data.exitGateDelay < 0 then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s exitGateDelay out of range!\n", strCode), true, true)
						break
					end
				end

				if portal_data.probability then
					if type(portal_data.probability) ~= 'number' then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s probability invalid format!\n", strCode), true, true)
						break
					end

					if portal_data.probability == 0 then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s probability out of range!\n", strCode), true, true)
						break
					end
				end

				if portal_data.useCount then
					if type(portal_data.useCount) ~= 'number' then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s useCount invalid format!\n", strCode), true, true)
						break
					end

					if portal_data.useCount == 0 then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s useCount out of range!\n", strCode), true, true)
						break
					end
				end

				if portal_data.buttonName then
					if type(portal_data.buttonName) ~= 'table' then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s buttonName invalid format!\n", strCode), true, true)
						break
					end

					if not portal_data.buttonName.default then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s buttonName.default invalid format!\n", strCode), true, true)
						break
					end
				end

				if portal_data.description then
					if type(portal_data.description) ~= 'table' then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s description invalid format!\n", strCode), true, true)
						break
					end

					if not portal_data.description.default then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s description.default invalid format!\n", strCode), true, true)
						break
					end
				end

				if portal_data.onOpen and type(portal_data.onOpen) ~= 'function' then
					bSucc = false
					Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s description.onOpen invalid format!\n", strCode), true, true)
					break
				end

				if portal_data.onClose and type(portal_data.onClose) ~= 'function' then
					bSucc = false
					Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s description.onClose invalid format!\n", strCode), true, true)
					break
				end

				if type(portal_data.onCheckUseConditions) ~= 'function' then
					bSucc = false
					Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s description.onCheckUseConditions invalid format!\n", strCode), true, true)
					break
				end

				if type(portal_data.onUse) ~= 'function' then
					bSucc = false
					Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s description.onUse invalid format!\n", strCode), true, true)
					break
				end

				if portal_data.conditions then
					if type(portal_data.conditions) ~= 'table' then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions invalid format!\n", strCode), true, true)
						break
					end

					local c = portal_data.conditions

					if c.minLevel and type(c.minLevel) ~= 'number' then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.minLevel invalid format!\n", strCode), true, true)
						break
					end

					if c.maxLevel and type(c.maxLevel) ~= 'number' then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.maxLevel invalid format!\n", strCode), true, true)
						break
					end

					if c.pvpGradeLimit then
						if type(c.pvpGradeLimit) ~= 'number' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.pvpGradeLimit invalid format!\n", strCode), true, true)
							break
						end

						if c.pvpGradeLimit > 7 then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.pvpGradeLimit out of range!\n", strCode), true, true)
							break
						end
					end

					if c.patriarchGroupLimit then
						if type(c.patriarchGroupLimit) ~= 'table' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.patriarchGroupLimit invalid format!\n", strCode), true, true)
							break
						end

						for dwIndex,v in ipairs(c.patriarchGroupLimit) do
							if type(v) ~= 'number' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.patriarchGroupLimit[%d] invalid format!\n", strCode, dwIndex), true, true)
								break
							end

							if v > 9 or v < -9 then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.patriarchGroupLimit[%d] out of range!\n", strCode, dwIndex), true, true)
								break
							end
						end

						if not bSucc then
							break
						end
					end

					if c.raceLimit then
						if type(c.raceLimit) ~= 'table' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.raceLimit invalid format!\n", strCode), true, true)
							break
						end

						for dwIndex,v in ipairs(c.raceLimit) do
							if type(v) ~= 'number' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.raceLimit[%d] invalid format!\n", strCode, dwIndex), true, true)
								break
							end

							if v > 9 or v < -9 then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.raceLimit[%d] out of range!\n", strCode, dwIndex), true, true)
								break
							end
						end

						if not bSucc then
							break
						end
					end

					if c.itemRequire then
						if type(c.itemRequire) ~= 'table' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemRequire invalid format!\n", strCode), true, true)
							break
						end

						for _,t in ipairs(armorParts) do
							repeat
								if c.itemRequire[t] then
									if type(c.itemRequire[t]) ~= 'table' then
										Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemRequire.%s invalid format!\n", strCode, t), true, true)
										bSucc = false
										break
									end

									for dwIndex,part in ipairs(c.itemRequire[t]) do
										if type(part) ~= 'table' then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemRequire.%s.[%d] invalid format!\n", strCode, t, dwIndex), true, true)
											break
										end

										if part.grade and type(part.grade) ~= 'number' then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemRequire.%s.[%d] grade invalid format!\n", strCode, t, dwIndex), true, true)
											break
										end

										if part.lv and type(part.lv) ~= 'number' then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemRequire.%s.[%d] lv invalid format!\n", strCode, t, dwIndex), true, true)
											break
										end

										if part.upgLv and type(part.upgLv) ~= 'number' then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemRequire.%s.[%d] upgLv invalid format!\n", strCode, t, dwIndex), true, true)
											break
										end
									end

									if not bSucc then
										break
									end
								end

							until true

							if not bSucc then
								break
							end
						end

						if not bSucc then
							break
						end
					end

					if c.itemConsume then
						if type(c.itemConsume) ~= 'table' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemConsume invalid format!\n", strCode), true, true)
							break
						end

						local ConsumeItemList = {}

						for dwIndex,consume in ipairs(c.itemConsume) do
							if type(consume) ~= 'table' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemConsume[%d] invalid format!\n", strCode, dwIndex), true, true)
								break
							end

							if not consume.itemCode or type(consume.itemCode) ~= 'string' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemConsume[%d].itemCode invalid format!\n", strCode, dwIndex), true, true)
								break
							end

							consume["tableCode"] = Sirin.mainThread.GetItemTableCode(consume.itemCode)

							if consume["tableCode"] == -1 then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemConsume[%d].itemCode %s invalid type!\n", strCode, dwIndex, consume.itemCode), true, true)
								break
							end

							consume["pBaseFld"] = Sirin.mainThread.g_Main:m_tblItemData_get(Sirin.mainThread.GetItemTableCode(consume.itemCode)):GetRecord(consume.itemCode)

							if not consume["pBaseFld"] then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemConsume[%d].itemCode %s item not exist!\n", strCode, dwIndex, consume.itemCode), true, true)
								break
							end

							consume["tableIndex"] = consume["pBaseFld"].m_dwIndex

							if consume.quantity then
								if type(consume.quantity) ~= 'number' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemConsume[%d].quantity invalid format!\n", strCode, dwIndex), true, true)
									break
								end
							end

							if ConsumeItemList[consume.itemCode] then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.itemConsume[%d].itemCode %s duplicate item!\n", strCode, dwIndex, consume.itemCode), true, true)
								break
							end

							ConsumeItemList[consume.itemCode] = true
						end

						if not bSucc then
							break
						end
					end

					if c.haveEffectRequire then
						if type(c.haveEffectRequire) ~= 'table' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.haveEffectRequire invalid format!\n", strCode), true, true)
							break
						end

						local MaxHaveEffID = 0

						if SERVER_AOP then
							MaxHaveEffID = 91
						elseif SERVER_2232 then
							MaxHaveEffID = 82
						else
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, "Lua. Check init.lua server version setting!", true, true)
							break
						end

						for id,v in pairs(c.haveEffectRequire) do
							if id > MaxHaveEffID or id < 0 then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.haveEffectRequire. Key %d out of range!\n", strCode, id), true, true)
								break
							end

							if type(v) ~= 'function' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.haveEffectRequire[%d] invalid format!\n", strCode, id), true, true)
								break
							end
						end

						if not bSucc then
							break
						end
					end

					if c.costDalant then
						if type(c.costDalant) ~= 'number' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.costDalant invalid format!\n", strCode), true, true)
							break
						end
					end

					if c.costGold then
						if type(c.costGold) ~= 'number' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.costGold invalid format!\n", strCode), true, true)
							break
						end
					end

					if c.costProcessingPoint then
						if type(c.costProcessingPoint) ~= 'number' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.costProcessingPoint invalid format!\n", strCode), true, true)
							break
						end
					end

					if c.costHuntingPoint then
						if type(c.costHuntingPoint) ~= 'number' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.costHuntingPoint invalid format!\n", strCode), true, true)
							break
						end
					end

					if c.costGoldenPoint then
						if type(c.costGoldenPoint) ~= 'number' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.costGoldenPoint invalid format!\n", strCode), true, true)
							break
						end
					end

					if c.costPvPCash then
						if type(c.costPvPCash) ~= 'number' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s conditions.costPvPCash invalid format!\n", strCode), true, true)
							break
						end
					end
				end

				if portal_data.openSchedule then
					if type(portal_data.openSchedule) ~= 'table' then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule invalid format!\n", strCode), true, true)
						break
					end

					local sz = 0

					for _ in pairs(portal_data.openSchedule) do sz = sz + 1 end

					if sz > 1 then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule only one type allowed at a time!\n", strCode), true, true)
						break
					end

					if portal_data.openSchedule.absolute then
						if type(portal_data.openSchedule.absolute) ~= 'table' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.absolute invalid format!\n", strCode), true, true)
							break
						end

						local schedule = portal_data.openSchedule.absolute

						for k,v in ipairs(timeInterval) do
							if schedule[v] then
								if type(schedule[v]) ~= 'number' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.absolute.%s invalid format!\n", strCode, v), true, true)
									break
								end

								if schedule[v] < limitMin[k] or schedule[v] > limitMax[k] then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.absolute.%s out of range!\n", strCode, v), true, true)
									break
								end
							else
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.absolute.%s invalid format!\n", strCode, v), true, true)
								break
							end
						end

						if not bSucc then
							break
						end
					end

					if portal_data.openSchedule.after then
						if type(portal_data.openSchedule.after) ~= 'table' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.after invalid format!\n", strCode), true, true)
							break
						end

						local schedule = portal_data.openSchedule.after

						for _,v in ipairs(timeInterval) do
							if schedule[v] then
								if type(schedule[v]) ~= 'number' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.after.%s invalid format!\n", strCode, v), true, true)
									break
								end

								if schedule[v] < 0 then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.after.%s out of range!\n", strCode, v), true, true)
									break
								end
							end
						end

						if not bSucc then
							break
						end
					end

					if portal_data.openSchedule.every then
						if type(portal_data.openSchedule.every) ~= 'table' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every invalid format!\n", strCode), true, true)
							break
						end

						local schedule = portal_data.openSchedule.every
						local sz = 0

						for _ in pairs(schedule) do sz = sz + 1 end

						if sz > 1 then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every only one type allowed at a time!\n", strCode), true, true)
							break
						end

						if schedule.dayOfMonth then
							if type(schedule.dayOfMonth) ~= 'table' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfMonth invalid format!\n", strCode), true, true)
								break
							end

							for dwIndex,interval in ipairs(schedule.dayOfMonth) do
								if type(interval) ~= 'table' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfMonth[%d] invalid format!\n", strCode, dwIndex), true, true)
									break
								end

								if not interval.val or type(interval.val) ~= 'number' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfMonth[%d].val invalid format!\n", strCode, dwIndex), true, true)
									break
								end

								if interval.val < 1 or interval.val > 31 then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfMonth[%d].val out of range!\n", strCode, dwIndex), true, true)
									break
								end

								if interval.offset then
									if type(interval.offset) ~= 'table' then
										bSucc = false
										Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfMonth[%d].offset invalid format!\n", strCode, dwIndex), true, true)
										break
									end

									if interval.offset.hour then
										if type(interval.offset.hour) ~= 'number' then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfMonth[%d].offset.hour invalid format!\n", strCode, dwIndex), true, true)
											break
										end

										if interval.offset.hour < 0 or interval.offset.hour > 23 then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfMonth[%d].offset.hour out of range!\n", strCode, dwIndex), true, true)
											break
										end
									end

									if interval.offset.minute then
										if type(interval.offset.minute) ~= 'number' then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfMonth[%d].offset.minute invalid format!\n", strCode, dwIndex), true, true)
											break
										end

										if interval.offset.minute < 0 or interval.offset.minute > 59 then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfMonth[%d].offset.minute out of range!\n", strCode, dwIndex), true, true)
											break
										end
									end
								end
							end

							if not bSucc then
								break
							end
						end

						if schedule.dayOfWeek then
							if type(schedule.dayOfWeek) ~= 'table' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfWeek invalid format!\n", strCode), true, true)
								break
							end

							for dwIndex,interval in ipairs(schedule.dayOfWeek) do
								if type(interval) ~= 'table' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfWeek[%d] invalid format!\n", strCode, dwIndex), true, true)
									break
								end

								if not interval.val or type(interval.val) ~= 'number' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfWeek[%d].val invalid format!\n", strCode, dwIndex), true, true)
									break
								end

								if interval.val < 1 or interval.val > 7 then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfWeek[%d].val out of range!\n", strCode, dwIndex), true, true)
									break
								end

								if interval.offset then
									if type(interval.offset) ~= 'table' then
										bSucc = false
										Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfWeek[%d].offset invalid format!\n", strCode, dwIndex), true, true)
										break
									end

									if interval.offset.hour then
										if type(interval.offset.hour) ~= 'number' then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfWeek[%d].offset.hour invalid format!\n", strCode, dwIndex), true, true)
											break
										end

										if interval.offset.hour < 0 or interval.offset.hour > 23 then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfWeek[%d].offset.hour out of range!\n", strCode, dwIndex), true, true)
											break
										end
									end

									if interval.offset.minute then
										if type(interval.offset.minute) ~= 'number' then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfWeek[%d].offset.minute invalid format!\n", strCode, dwIndex), true, true)
											break
										end

										if interval.offset.minute < 0 or interval.offset.minute > 59 then
											bSucc = false
											Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.dayOfWeek[%d].offset.minute out of range!\n", strCode, dwIndex), true, true)
											break
										end
									end
								end
							end

							if not bSucc then
								break
							end
						end

						if schedule.day then
							if type(schedule.day) ~= 'table' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.day invalid format!\n", strCode), true, true)
								break
							end

							for dwIndex,interval in ipairs(schedule.day) do
								if type(interval) ~= 'table' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.day[%d] invalid format!\n", strCode, dwIndex), true, true)
									break
								end

								if not interval.hour or type(interval.hour) ~= 'number' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.day[%d].hour invalid format!\n", strCode, dwIndex), true, true)
									break
								end

								if interval.hour < 0 or interval.hour > 23 then
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.day[%d].hour out of range!\n", strCode, dwIndex), true, true)
									bSucc = false
									break
								end

								if interval.minute then
									if type(interval.minute) ~= 'number' then
										bSucc = false
										Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.day[%d].minute invalid format!\n", strCode, dwIndex), true, true)
										break
									end

									if interval.minute < 0 or interval.minute > 59 then
										bSucc = false
										Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.day[%d].hour out of range!\n", strCode, dwIndex), true, true)
										break
									end
								end
							end

							if not bSucc then
								break
							end
						end

						if schedule.hour then
							if type(schedule.hour) ~= 'table' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.hour invalid format!\n", strCode), true, true)
								break
							end

							if not schedule.hour.val or type(schedule.hour.val) ~= 'number' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.hour.val invalid format!\n", strCode), true, true)
								break
							end

							if schedule.hour.val < 1 or (24 % schedule.hour.val) ~= 0 then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.hour.val out of range!\n", strCode), true, true)
								break
							end

							if schedule.hour.offset then
								if type(schedule.hour.offset) ~= 'table' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.hour.offset invalid format!\n", strCode), true, true)
									break
								end

								if schedule.hour.offset.hour then
									if type(schedule.hour.offset.hour) ~= 'number' then
										bSucc = false
										Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.hour.offset.hour invalid format!\n", strCode), true, true)
										break
									end

									if schedule.hour.offset.hour < 0 or schedule.hour.offset.hour >= schedule.hour.val then
										bSucc = false
										Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.hour.offset.hour out of range!\n", strCode), true, true)
										break
									end
								end

								if schedule.hour.offset.minute then
									if type(schedule.hour.offset.minute) ~= 'number' then
										bSucc = false
										Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.hour.offset.minute invalid format!\n", strCode), true, true)
										break
									end

									if schedule.hour.offset.minute < 0 or schedule.hour.offset.minute > 59 then
										bSucc = false
										Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.hour.offset.minute out of range!\n", strCode), true, true)
										break
									end
								end
							end
						end

						if schedule.minute then
							if type(schedule.minute) ~= 'table' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.minute invalid format!\n", strCode), true, true)
								break
							end

							if not schedule.minute.val or type(schedule.minute.val) ~= 'number' then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.minute.val invalid format!\n", strCode), true, true)
								break
							end

							if schedule.minute.val < 1 or (60 % schedule.minute.val) ~= 0 then
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.minute.val out of range!\n", strCode), true, true)
								break
							end

							if schedule.minute.offset then
								if type(schedule.minute.offset) ~= 'table' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.minute.offset invalid format!\n", strCode), true, true)
									break
								end

								if schedule.minute.offset.minute then
									if type(schedule.minute.offset.minute) ~= 'number' then
										bSucc = false
										Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.minute.offset.minute invalid format!\n", strCode), true, true)
										break
									end

									local nVal = schedule.minute.offset.minute

									if schedule.minute.offset.minute < 0 or schedule.minute.offset.minute >= schedule.minute.val then
										bSucc = false
										Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s openSchedule.every.minute.offset.minute out of range!\n", strCode), true, true)
										break
									end
								end
							end
						end
					end
				end

				if portal_data.closeSchedule then
					if type(portal_data.closeSchedule) ~= 'table' then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s closeSchedule invalid format!\n", strCode), true, true)
						break
					end

					local sz = 0

					for _ in pairs(portal_data.closeSchedule) do sz = sz + 1 end

					if sz > 1 then
						bSucc = false
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s closeSchedule only one type allowed at a time!\n", strCode), true, true)
						break
					end

					if portal_data.closeSchedule.absolute then
						if type(portal_data.closeSchedule.absolute) ~= 'table' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s closeSchedule.absolute invalid format!\n", strCode), true, true)
							break
						end

						local schedule = portal_data.closeSchedule.absolute

						for k,v in ipairs(timeInterval) do
							if schedule[v] then
								if type(schedule[v]) ~= 'number' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s closeSchedule.absolute.%s invalid format!\n", strCode, timeInterval[k]), true, true)
									break
								end

								if schedule[v] < limitMin[k] or schedule[v] > limitMax[k] then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s closeSchedule.absolute.%s out of range!\n", strCode, timeInterval[k]), true, true)
									break
								end
							else
								bSucc = false
								Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s closeSchedule.absolute.%s invalid format!\n", strCode, timeInterval[k]), true, true)
								break
							end
						end

						if not bSucc then
							break
						end
					end

					if portal_data.closeSchedule.after then
						if type(portal_data.closeSchedule.after) ~= 'table' then
							bSucc = false
							Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s closeSchedule.after invalid format!\n", strCode), true, true)
							break
						end

						local schedule = portal_data.closeSchedule.after

						for _,v in ipairs(timeInterval) do
							if schedule[v] then
								if type(schedule[v]) ~= 'number' then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s closeSchedule.after.%s invalid format!\n", strCode, v), true, true)
									break
								end

								if schedule[v] < 0 then
									bSucc = false
									Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Portal record:%s closeSchedule.after.%s out of range!\n", strCode, v), true, true)
									break
								end
							end
						end

						if not bSucc then
							break
						end
					end
				end

			until true
		end

		if not bSucc then
			SirinTmp_DynamicPortals = nil
			Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, "sirinRiftMgr.validateScriptData(...) bSucc == false!\n", true, true)
		end

	until true

	return bSucc
end

---@param pRift CDummyRift
function sirinRiftMgr.createRift(pRift)
	if sirinRiftMgr.m_bDebugLog then
		print "create object rift"
	end
end

---@param pRift CDummyRift
function sirinRiftMgr.destroyRift(pRift)
	if sirinRiftMgr.m_bDebugLog then
		print "destroy object rift"
	end
end

function sirinRiftMgr.onLoop()
	sirinRiftMgr.m_tLoopTime = os.time()

	for id, Gate in pairs(sirinRiftMgr.m_Gates) do
		repeat
			if Gate.m_bDelete or Gate.m_bOpen then
				break
			end

			if Gate.m_tNextOpenTime >= 0 and Gate.m_tNextOpenTime < sirinRiftMgr.m_tLoopTime then
				if not Gate.m_LuaScript.probability or Gate.m_LuaScript.probability < 0 or math.random(0, 99) < Gate.m_LuaScript.probability then
					Gate:openEnterDummy()
				else
					Gate.m_tNextOpenTime = Gate:GetOpenNext()

					if sirinRiftMgr.m_bDebugLog then
						---@type string|osdate
						local szBufr = "never"

						if Gate.m_tNextOpenTime > 0 then
							szBufr = os.date(_, Gate.m_tNextOpenTime)
						end

						print(string.format("Rift '%s' open fail (random). Next open: %s", Gate.m_strScriptID, szBufr))
						Sirin.WriteA(sirinRiftMgr.m_pszModReturnGateLogPath, string.format("Rift '%s' open fail (random). Next open: %s\n", Gate.m_strScriptID, szBufr), true, true)
					end
				end
			end

		until true
	end
end

function sirinRiftMgr.saveState()
	local t = {}

	for _,v in pairs(sirinRiftMgr.m_ListGates) do
		local s = t[v.m_strScriptID] or {}
		s[v.m_bDelete and 1 or 0] = Sirin.mainThread.objectToVoid(v.m_pCObj)
		t[v.m_strScriptID] = s
	end

	local Ctx = Sirin.luaThreadManager.LuaGetThread("sirin.guard.data")

	Ctx:Lock()

	Sirin.luaThreadManager.CopyToContext(Ctx, "RiftActiveData", t)

	Ctx:Unlock()
end

function sirinRiftMgr.uninit()
	sirinRiftMgr.setSaveState(false)

	for _,Gate in pairs(sirinRiftMgr.m_Gates) do
		if Gate:IsOpen() then
			Gate:Close()
		end

		sirinRiftMgr.m_Gates[Gate.m_strScriptID] = nil
	end

	sirinRiftMgr.setSaveState(true)

	if SirinTmp_DynamicPortals then
		SirinScript_DynamicPortals = SirinTmp_DynamicPortals
		SirinTmp_DynamicPortals = nil
	end
end

function sirinRiftMgr.init()
	local t = {}
	local Ctx = Sirin.luaThreadManager.LuaGetThread("sirin.guard.data")

	Ctx:Lock()

	if Sirin.luaThreadManager.IsExistGlobal(Ctx, "RiftActiveData") then
		t = Sirin.luaThreadManager.CopyFromContext(Ctx, "RiftActiveData")
		Sirin.luaThreadManager.DeleteGlobal(Ctx, "RiftActiveData")
	end

	Ctx:Unlock()

	local tCurTime = os.time()

	if type(SirinScript_DynamicPortals) ~= 'table' then
		return
	end

	for k,rg in pairs(SirinScript_DynamicPortals) do
		if rg.portalType == 0 then
			local NewGate = sirinRift:new()
			NewGate.m_LuaScript = rg
			NewGate.m_strScriptID = k
			NewGate.m_pDstMap = rg.dstMap
			NewGate.m_pSrcMap = rg.srcMap

			local fnCheckState = function()
				NewGate.m_bOpen = Sirin.GetPrivateProfileIntA(NewGate.m_strScriptID, "IsOpen", 0, sirinRiftMgr.m_pszModReturnGateConfigPath) ~= 0 and true or false
				NewGate.m_nUseLeft = Sirin.GetPrivateProfileIntA(NewGate.m_strScriptID, "UseLeft", -1, sirinRiftMgr.m_pszModReturnGateConfigPath)
				local _, szValue = Sirin.GetPrivateProfileStringA(NewGate.m_strScriptID, "CloseTime", "-1", sirinRiftMgr.m_pszModReturnGateConfigPath)
				NewGate.m_tNextCloseTime = math.floor(tonumber(szValue) or -1)

				if NewGate.m_bOpen then -- check last state
					if tCurTime > NewGate.m_tNextCloseTime then -- check last state expired
						NewGate.m_bOpen = false
						Sirin.WritePrivateProfileStringA(NewGate.m_strScriptID, "IsOpen", "0", sirinRiftMgr.m_pszModReturnGateConfigPath)
					else -- if not expired check change limit conditions
						NewGate.m_bReOpen = true

						if rg.useCount then
							if NewGate.m_nUseLeft > rg.useCount or (NewGate.m_nUseLeft < 0 and rg.useCount > 0) then
								NewGate.m_nUseLeft = rg.useCount
							end
						else
							NewGate.m_nUseLeft = -1
						end
					end
				end

				if not NewGate.m_bOpen then -- if not opened or expired, process missed open check
					NewGate.m_tNextOpenTime = NewGate:GetOpenLast()

					if NewGate.m_tNextOpenTime >= 0 and NewGate.m_tNextOpenTime < tCurTime then -- if missed, do open
						NewGate.m_bReOpen = false
						NewGate.m_bOpen = true
						NewGate.m_tNextCloseTime = NewGate:GetCloseNext()

						if NewGate.m_tNextCloseTime >= 0 and tCurTime > NewGate.m_tNextCloseTime then -- check for instant close because of expired
							NewGate.m_bOpen = false
						end
					end
				end
			end

			if rg.openSchedule then
				if rg.openSchedule.absolute then
					fnCheckState()
				elseif rg.openSchedule.after then
					NewGate.m_tNextOpenTime = NewGate:GetOpenLast();
				elseif rg.openSchedule.every then
					fnCheckState();
				else

				end

				if not NewGate.m_bOpen and NewGate.m_tNextOpenTime < tCurTime then -- if not still active or missed open in past, reschedule new open
					NewGate.m_tNextOpenTime = NewGate:GetOpenNext()
				end
			end

			if NewGate.m_bOpen then
				local s = t[NewGate.m_strScriptID]

				if s and s[0] then
					NewGate.m_pCObj = Sirin.mainThread.objectToDummyRift(Sirin.mainThread.voidToObject(s[0]))
					sirinRiftMgr.addRift(NewGate.m_pCObj, NewGate)

					if s[1] then
						repeat
							if NewGate.m_LuaScript.exitGateType and NewGate.m_LuaScript.exitGateType == 1 then
								break
							end

							NewGate.m_ExitDummyGate = sirinDummyRift:new()
							NewGate.m_ExitDummyGate.m_strScriptID = NewGate.m_strScriptID
							NewGate.m_ExitDummyGate.m_pCObj = Sirin.mainThread.objectToDummyRift(Sirin.mainThread.voidToObject(s[1]))
							NewGate.m_ExitDummyGate.m_bOpen = true
							sirinRiftMgr.addRift(NewGate.m_ExitDummyGate.m_pCObj, NewGate.m_ExitDummyGate)

							if not NewGate.m_LuaScript.exitGateType or NewGate.m_LuaScript.exitGateType == 0 then
								NewGate.m_ExitDummyGate.m_tNextCloseTime = -1
							elseif NewGate.m_LuaScript.exitGateType == 2 then
								NewGate.m_ExitDummyGate.m_tNextCloseTime = RiftMgr:getLoopTime() + (NewGate.m_LuaScript.exitGateDelay or 60)
							else
								break
							end
						until true
					else
						NewGate:openExitDummy(false)
					end
				else
					NewGate:openEnterDummy()
				end
			end

			sirinRiftMgr.m_Gates[NewGate.m_strScriptID] = NewGate
		end
	end
end

---@return integer m_tLoopTime
function sirinRiftMgr.getLoopTime()
	return sirinRiftMgr.m_tLoopTime
end

---@param pLuaRift sirinDummyRift
---@param pPlayer CPlayer
---@return integer #Error code
function sirinRiftMgr.canUseRift(pLuaRift, pPlayer)
	local c =  pLuaRift.m_LuaScript.conditions or {}
	local nErr = 0

	repeat
		if pPlayer.m_bInGuildBattle then
			nErr = 6
			break
		end

		if c.minLevel and pPlayer:GetLevel() < c.minLevel then
			nErr = 50
			break
		end

		if c.maxLevel and pPlayer:GetLevel() > c.maxLevel then
			nErr = 50
			break
		end

		if c.pvpGradeLimit and pPlayer.m_Param.m_byPvPGrade < c.pvpGradeLimit then
			nErr = 51
			break
		end

		if c.patriarchGroupLimit and #c.patriarchGroupLimit > 0 then
			local byPatriarchGroup = Sirin.mainThread.CPvpUserAndGuildRankingSystem.Instance():GetBossType(pPlayer:GetObjRace(), pPlayer.m_Param:GetCharSerial()) + 1
			local CheckAnyOf = false
			local AnyOf = false

			for _,v in ipairs(c.patriarchGroupLimit) do
				if v > 0 then
					CheckAnyOf = true

					if byPatriarchGroup == v then
						AnyOf = true
					end
				else
					if byPatriarchGroup == -v then
						nErr = 52
						break
					end
				end
			end

			if CheckAnyOf and not AnyOf then
				nErr = 52
			end

			if nErr > 0 then
				break
			end
		end

		if c.raceLimit and #c.raceLimit > 0 then
			local byRace = pPlayer:GetObjRace()
			local AnyOf = false

			for _,v in ipairs(c.raceLimit) do
				if byRace == v then
					AnyOf = true
				end
			end

			if not AnyOf then
				nErr = 53
			end

			if nErr > 0 then
				break
			end
		end

		if c.itemRequire then
			for byCurEquip,equipName in ipairs(armorParts) do
				repeat
					local bConditionPassed = false

					if pPlayer.m_Param.m_dbEquip:m_List_get(byCurEquip - 1).m_byLoad == 0 then
						nErr = 60 + byCurEquip - 1
						break
					end

					if not c.itemRequire[equipName] then
						break
					end

					for _,v in ipairs(c.itemRequire[equipName]) do
						repeat
							local pFldItem = Sirin.mainThread.g_Main:m_tblItemData_get(byCurEquip - 1):GetRecord(pPlayer.m_Param.m_dbEquip:m_List_get(byCurEquip - 1).m_wItemIndex)

							if equipName == '_weapon' then
								local pWeaponFld = Sirin.mainThread.baseToWeaponItem(pFldItem)

								if v.grade and pWeaponFld.m_nItemGrade < v.grade then
									do break end
								end

								if v.lv and pWeaponFld.m_nLevelLim < v.lv then
									do break end
								end
							else
								local pArmorFld = Sirin.mainThread.baseToDfnEquipItem(pFldItem)

								if v.grade and pArmorFld.m_nItemGrade < v.grade then
									do break end
								end

								if v.lv and pArmorFld.m_nLevelLim < v.lv then
									do break end
								end
							end

							if v.upgLv and Sirin.mainThread.GetItemUpgedLv(pPlayer.m_Param.m_dbEquip:m_List_get(byCurEquip - 1).m_dwLv) < v.upgLv then
								do break end
							end

							bConditionPassed = true

						until true

						if bConditionPassed then
							break
						end
					end

					if not bConditionPassed then
						nErr = 60 + byCurEquip - 1
						break
					end

				until true

				if nErr > 0 then
					break
				end
			end

			if nErr > 0 then
				break
			end
		end

		local AlterList = {}
		local DeleteList = {}

		if type(c.itemConsume) == 'table' and #c.itemConsume > 0 then
			local ConsumeList = {}

			for _,v in ipairs(c.itemConsume) do
				local _ItemConsume = {}
				_ItemConsume.m_byTableCode = v.tableCode
				_ItemConsume.m_wItemIndex = v.tableIndex
				_ItemConsume.m_qwQuantity = v.quantity or 0
				table.insert(ConsumeList, _ItemConsume)
			end

			local Inven = {}

			for j = 0, pPlayer.m_Param.m_dbInven.m_nUsedNum - 1 do
				local pCon = pPlayer.m_Param.m_dbInven:m_List_get(j)

				if pCon.m_byLoad == 1 and not pCon.m_bLock then
					table.insert(Inven, pCon)
				end
			end

			table.sort(Inven, function(a, b) return a.m_byClientIndex < b.m_byClientIndex end)

			for _,item in pairs(Inven) do
				for k,consume in pairs(ConsumeList) do
					if item.m_byTableCode == consume.m_byTableCode and item.m_wItemIndex == consume.m_wItemIndex then
						if consume.m_qwQuantity > 0 then
							if Sirin.mainThread.IsOverLapItem(consume.m_byTableCode) then
								if item.m_dwDur > consume.m_qwQuantity then
									table.insert(AlterList, { pCon = item, nAlter = -consume.m_qwQuantity })
									consume.m_qwQuantity = 0
								else
									table.insert(DeleteList, { pCon = item, nAlter = 0 })
									consume.m_qwQuantity = consume.m_qwQuantity - item.m_dwDur
								end
							else
								table.insert(DeleteList, { pCon = item, nAlter = 0 })
								consume.m_qwQuantity = consume.m_qwQuantity - 1
							end
						end

						if consume.m_qwQuantity == 0 then
							ConsumeList[k] = nil
						end
					end
				end
			end

			for _,v in pairs(ConsumeList) do
				nErr = 54
				break
			end

			if nErr ~= 0 then
				break
			end
		end

		local bHaveEffPass = true

		if type(c.haveEffectRequire) == 'table' then
			for k,v in pairs(c.haveEffectRequire) do
				if type(v) == 'function' then
					bHaveEffPass = bHaveEffPass and v(pPlayer.m_EP:GetEff_Have(k))
				end
			end
		end

		if not bHaveEffPass then
			nErr = 55
			break
		end

		if c.costDalant and c.costDalant > 0 and pPlayer.m_Param:GetDalant() < c.costDalant then
			nErr = 70
			break
		end

		if c.costGold and c.costGold > 0 and pPlayer.m_Param:GetGold() < c.costGold then
			nErr = 71
			break
		end

		if c.costProcessingPoint and c.costProcessingPoint > 0 and pPlayer.m_pUserDB:GetActPoint(0) < c.costProcessingPoint then
			nErr = 72
			break
		end

		if c.costHuntingPoint and c.costHuntingPoint > 0 and pPlayer.m_pUserDB:GetActPoint(1) < c.costHuntingPoint then
			nErr = 73
			break
		end

		if c.costGoldenPoint and c.costGoldenPoint > 0 and pPlayer.m_pUserDB:GetActPoint(2) < c.costGoldenPoint then
			nErr = 74
			break
		end

		if c.costPvPCash and c.costPvPCash > 0 then
			if pPlayer:GetLevel() < 40 or pPlayer.m_Param.m_pClassData.m_nGrade < 1 then
				nErr = 75
				break
			end

			if pPlayer.m_kPvpOrderView:GetPvpCash() < c.costPvPCash then
				nErr = 75
				break
			end
		end

		-- at this point we done with checks and now going to remove of consumables

		for _,alter in pairs(AlterList) do
			local wSerial = alter.pCon.m_wSerial
			local Left = pPlayer:Emb_AlterDurPoint(STORAGE_POS.inven, alter.pCon.m_byStorageIndex, alter.nAlter, false, false)
			pPlayer:SendMsg_AdjustAmountInform(STORAGE_POS.inven, wSerial, Left)
		end

		for _,del in pairs(DeleteList) do
			pPlayer:Emb_DelStorage(STORAGE_POS.inven, del.pCon.m_byStorageIndex, false, true, "Lua. sirinRiftMgr.canUseRift(...)")
		end

		if c.costDalant and c.costDalant > 0 then
			pPlayer:AlterDalant(-c.costDalant)
			pPlayer:SendMsg_AlterMoneyInform(0)
		end

		if c.costGold and c.costGold > 0 then
			pPlayer:AlterGold(-c.costGold)
			pPlayer:SendMsg_AlterMoneyInform(0)
		end

		if c.costProcessingPoint and c.costProcessingPoint > 0 then
			pPlayer:SubActPoint(0, c.costProcessingPoint)
			pPlayer:SendMsg_Alter_Action_Point(0, pPlayer.m_pUserDB:GetActPoint(0))
		end

		if c.costHuntingPoint and c.costHuntingPoint > 0 then
			pPlayer:SubActPoint(1, c.costHuntingPoint)
			pPlayer:SendMsg_Alter_Action_Point(1, pPlayer.m_pUserDB:GetActPoint(1))
		end

		if c.costGoldenPoint and c.costGoldenPoint > 0 then
			pPlayer:SubActPoint(2, c.costGoldenPoint)
			pPlayer:SendMsg_Alter_Action_Point(2, pPlayer.m_pUserDB:GetActPoint(2))
		end

		if c.costPvPCash and c.costPvPCash > 0 then
			pPlayer:AlterPvPCashBag(-c.costPvPCash, PVP_MONEY_ALTER_TYPE.pm_shop)
		end
	until true

	return nErr
end

---@param pLuaRift sirinDummyRift
---@param pPlayer CPlayer
function sirinRiftMgr.onUse(pLuaRift, pPlayer)
	local result = true
	result, pLuaRift.m_pCObj.m_fBindPos_x, pLuaRift.m_pCObj.m_fBindPos_y, pLuaRift.m_pCObj.m_fBindPos_z = pLuaRift.m_pCObj.m_pDestMap:GetRandPosInRange(pLuaRift.m_DstPos[1], pLuaRift.m_DstPos[2], pLuaRift.m_DstPos[3], 50)

	if not result then
		return
	end

	pPlayer:OutOfMap(pLuaRift.m_pCObj.m_pDestMap, pLuaRift.m_DstPos[4], 3, pLuaRift.m_pCObj.m_fBindPos_x, pLuaRift.m_pCObj.m_fBindPos_y, pLuaRift.m_pCObj.m_fBindPos_z)
	pLuaRift.m_pCObj:SendMsg_MovePortal(pPlayer)

	pLuaRift:openExitDummy(true)

	if pLuaRift.m_nUseLeft > 0 then
		--if pPlayer.m_byUserDgr == 0 then -- todo: after test make GMs not affect counters.
			pLuaRift.m_nUseLeft = pLuaRift.m_nUseLeft - 1
		--end

		local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
		buf:Init()

		buf:PushUInt16(pLuaRift.m_pCObj:GetIndex())
		buf:PushUInt32(pLuaRift.m_pCObj.m_dwObjSerial)
		buf:PushUInt32(pLuaRift.m_pCObj.m_dwOwnerSerial)

		buf:PushUInt16(0)
		buf:PushUInt16(0)
		buf:PushInt16(pLuaRift.m_nUseLeft)
		buf:PushUInt8(0)
		buf:PushUInt32(0)
		buf:PushUInt32(0)
		buf:PushUInt16(0)

		buf:PushInt16(math.floor(pLuaRift.m_pCObj.m_fCurPos_x))
		buf:PushInt16(math.floor(pLuaRift.m_pCObj.m_fCurPos_y))
		buf:PushInt16(math.floor(pLuaRift.m_pCObj.m_fCurPos_z))

		pLuaRift.m_pCObj:CircleReport(4, 170, buf, false)

		Sirin.WritePrivateProfileStringA(pLuaRift.m_strScriptID, "UseLeft", string.format("%d", pLuaRift.m_nUseLeft), sirinRiftMgr.m_pszModReturnGateConfigPath)
	end

	if sirinRiftMgr.m_bDebugLog then
		print (pLuaRift.m_strScriptID .. " useleft :" .. pLuaRift.m_nUseLeft)
	end
end

---@param pPlayer CPlayer
---@return integer #Error code
function sirinDummyRift:Enter(pPlayer)
	return 3
end

function sirinDummyRift:Close()
	if not self.m_bOpen then
		return
	end

	self.m_bOpen = false
	sirinRiftMgr.removeRift(self.m_pCObj)
end

---@return boolean
function sirinDummyRift:IsClose()
	if not self.m_bOpen then
		return true
	end

	if self.m_tNextCloseTime >= 0 and RiftMgr:getLoopTime() > self.m_tNextCloseTime then
		return true
	end

	return false
end

---@return boolean
function sirinDummyRift:IsValidOwner()
	return true
end

---@param pParam CReturnGateCreateParam
---@return boolean
function sirinDummyRift:Open(pParam)
	local bRet = false

	repeat
		if not self.m_pCObj:Create(pParam) then
			Sirin.WriteA(RiftMgr.m_pszModReturnGateLogPath, string.format("Lua sirinDummyRift:Open(pParam) Rift:'%s' CGameObject::Create() Failed!\n", self.m_strScriptID), true, true)
			break
		end

		self.m_pCObj.m_dwOwnerSerial = 0
		self.m_pCObj.m_dwObjSerial = self.m_pCObj:GetIndex()
		self.m_pCObj.m_eState = 1 -- REG_WAIT
		self.m_bOpen = true
		bRet = true

	until true

	if bRet then
		sirinRiftMgr.addRift(self.m_pCObj, self)
		self.m_pCObj:SendMsg_Create()
	end

	return bRet
end

---@return boolean
function sirinDummyRift:IsOpen()
	return self.m_bOpen
end

--[[
struct _mod_open_return_gate_inform_zocl
{
	unsigned __int16 wGateInx;
	unsigned int dwObjSerial;
	unsigned int dwOpenerSerial;
	union {
		char wszOpenerName[17];

		struct
		{
			WORD wMinLv;
			WORD wMaxLv;
			WORD wUseLeft;
			BYTE byMapID;
			DWORD dwFlag;
			DWORD dwReserved;
			WORD wReserved;
		}pRiftParam;
	};
	__int16 zPos[3];
	size_t Size() { return sizeof(*this); }
};
--]]

function sirinDummyRift:SendMsg_Create()
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()

	buf:PushUInt16(self.m_pCObj:GetIndex())
	buf:PushUInt32(self.m_pCObj.m_dwObjSerial)
	buf:PushUInt32(self.m_pCObj.m_dwOwnerSerial)

	buf:PushUInt16(0)
	buf:PushUInt16(0)
	buf:PushInt16(self.m_nUseLeft)
	buf:PushUInt8(0)
	buf:PushUInt32(0)
	buf:PushUInt32(0)
	buf:PushUInt16(0)

	buf:PushInt16(math.floor(self.m_pCObj.m_fCurPos_x))
	buf:PushInt16(math.floor(self.m_pCObj.m_fCurPos_y))
	buf:PushInt16(math.floor(self.m_pCObj.m_fCurPos_z))

	self.m_pCObj:CircleReport(8, 7, buf, false)

	if self.m_LuaScript.buttonName then
		for i = 0, 2531 do
			repeat
				local pPlayer = Sirin.mainThread.g_Player_get(i)

				if not pPlayer.m_bLive or not pPlayer.m_bOper or pPlayer.m_pCurMap ~= self.m_pCObj.m_pCurMap then
					break
				end

				local strPrefix = GetPlayerLanguagePrefix(i) or 'default'
				local strButtonName = ""
				local strDescription = ""

				if type(self.m_LuaScript.buttonName) == 'table' then
					strButtonName = self.m_LuaScript.buttonName[strPrefix] or self.m_LuaScript.buttonName['default'] or 'Lua. Invalid string.'
				end

				if type(self.m_LuaScript.description) == 'table' then
					strDescription = self.m_LuaScript.description[strPrefix] or self.m_LuaScript.description['default'] or 'Lua. Invalid string.'
				end

				self:SendMsg_PopupWindowData(pPlayer, strButtonName, strDescription)

			until true
		end
	end
end

function sirinDummyRift:SendMsg_Destroy()
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()

	buf:PushUInt32(self.m_pCObj.m_dwObjSerial)

	for i = 0, 2531 do
		local pPlayer = Sirin.mainThread.g_Player_get(i)

		if pPlayer.m_bLive and pPlayer.m_bOper and pPlayer.m_pCurMap == self.m_pCObj.m_pCurMap then
			buf:SendBuffer(pPlayer, 8, 8)
		end
	end
end

--[[
struct _mod_return_gate_fix_position_zocl
{
	unsigned __int16 wGateInx;
	unsigned int dwObjSerial;
	unsigned int dwOpenerSerial;
	union {
		char wszOpenerName[17];

		struct
		{
			WORD wMinLv;
			WORD wMaxLv;
			WORD wUseLeft;
			BYTE byMapID;
			DWORD dwFlag;
			DWORD dwReserved;
			WORD wReserved;
		}pRiftParam;
	};
	__int16 zPos[3];
	size_t Size() { return sizeof(*this); }
};
--]]

---@param nIndex integer #Player socket ID
function sirinDummyRift:SendMsg_FixPosition(nIndex)
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()

	buf:PushUInt16(self.m_pCObj:GetIndex())
	buf:PushUInt32(self.m_pCObj.m_dwObjSerial)
	buf:PushUInt32(self.m_pCObj.m_dwOwnerSerial)

	buf:PushUInt16(0)
	buf:PushUInt16(0)
	buf:PushInt16(self.m_nUseLeft)
	buf:PushUInt8(0)
	buf:PushUInt32(0)
	buf:PushUInt32(0)
	buf:PushUInt16(0)

	buf:PushInt16(math.floor(self.m_pCObj.m_fCurPos_x))
	buf:PushInt16(math.floor(self.m_pCObj.m_fCurPos_y))
	buf:PushInt16(math.floor(self.m_pCObj.m_fCurPos_z))

	buf:SendBuffer(Sirin.mainThread.g_Player_get(nIndex), 4, 170)

	if self.m_LuaScript.buttonName then
		local pPlayer = Sirin.mainThread.g_Player_get(nIndex)
		local strPrefix = GetPlayerLanguagePrefix(nIndex) or 'default'
		local strButtonName = ""
		local strDescription = ""

		if type(self.m_LuaScript.buttonName) == 'table' then
			strButtonName = self.m_LuaScript.buttonName[strPrefix] or self.m_LuaScript.buttonName['default'] or 'Lua. Invalid string.'
		end

		if type(self.m_LuaScript.description) == 'table' then
			strDescription = self.m_LuaScript.description[strPrefix] or self.m_LuaScript.description['default'] or 'Lua. Invalid string.'
		end

		self:SendMsg_PopupWindowData(pPlayer, strButtonName, strDescription)
	end
end

---@param pPlayer CPlayer
function sirinDummyRift:SendMsg_MovePortal(pPlayer)
	-- we do nothng here
end

--[[
struct _RiftData_zocl
{
	unsigned m_dwObjID;
	int m_nUseLeft;
	unsigned m_dwButtonNameLen;
	unsigned m_dwDescLen;

private:
	char m_szButtonName[1];
	char m_szDesc[1];
}
--]]

---@param pPlayer CPlayer
---@param strButtonName string
---@param strDescription string
function sirinDummyRift:SendMsg_PopupWindowData(pPlayer, strButtonName, strDescription)
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()

	buf:PushUInt32(self.m_pCObj.m_dwObjSerial)
	buf:PushInt32(self.m_nUseLeft)
	buf:PushUInt32(string.len(strButtonName))
	buf:PushUInt32(string.len(strDescription))
	buf:PushString(strButtonName, string.len(strButtonName) + 1)
	buf:PushString(strDescription, string.len(strDescription) + 1)

	buf:SendBuffer(pPlayer, 101, 7)
end

---@return integer
function sirinDummyRift:GetOpenLast()
	local tPrevOpenTime = -1
	local tCurTime = os.time()

	repeat
		local ScriptData = self.m_LuaScript

		if type(ScriptData.openSchedule) ~= 'table' then
			break
		end

		local Schedule = ScriptData.openSchedule

		if type(Schedule.absolute) == 'table' then
			local _Schedule = Schedule.absolute
			tPrevOpenTime = os.time{
			year = _Schedule.year,
			month = _Schedule.month,
			day = _Schedule.day,
			hour = _Schedule.hour,
			min = _Schedule.minute,
			sec = _Schedule.second,
			isdst = USE_DST or false,
			}
			break
		end

		if type(Schedule.after) == 'table' then
			local _Schedule = Schedule.after
			tPrevOpenTime = tCurTime
			tPrevOpenTime = tPrevOpenTime + (_Schedule.year or 0) * 365 * 24 * 60 * 60
			tPrevOpenTime = tPrevOpenTime + (_Schedule.month or 0) * 30 * 24 * 60 * 60
			tPrevOpenTime = tPrevOpenTime + (_Schedule.day or 0) * 24 * 60 * 60
			tPrevOpenTime = tPrevOpenTime + (_Schedule.hour or 0) * 60 * 60
			tPrevOpenTime = tPrevOpenTime + (_Schedule.minute or 0) * 60
			tPrevOpenTime = tPrevOpenTime + (_Schedule.second or 0)
			break
		end

		local o = os.date("*t", tCurTime)
		local t = {}
		o.sec = 0

		if Schedule.every then
			local _Schedule = Schedule.every

			if type(_Schedule.dayOfMonth) == 'table' then
				for _,s in ipairs(_Schedule.dayOfMonth) do
					t = clone(o)
					t.hour = 0
					t.min = 0
					t.day = s.val

					if s.offset then
						if s.offset.hour then
							t.hour = s.offset.hour
						end

						if s.offset.minute then
							t.min = s.offset.minute
						end
					end

					local u = os.time(t)

					if u > tCurTime then
						t.month = t.month - 1

						if t.month == 0 then
							t.year = t.year - 1
							t.month = 12
						end

						u = os.time(t)
					end

					if u > tPrevOpenTime and u <= tCurTime then
						tPrevOpenTime = u
					end
				end

				do break end
			end

			if type(_Schedule.dayOfWeek) == 'table' then
				for _,s in ipairs(_Schedule.dayOfWeek) do
					t = clone(o)
					t.hour = 0
					t.min = 0
					local diff = t.wday - s.val

					if s.offset then
						if s.offset.hour then
							t.hour = s.offset.hour
						end

						if s.offset.minute then
							t.min = s.offset.minute
						end
					end

					local u = os.time(t)

					if diff < 0 then
						u = u - (7 + diff) * 24 * 60 * 60
					end

					if diff > 0 then
						u = u - diff * 24 * 60 * 60
					end

					if u > tPrevOpenTime and u <= tCurTime then
						tPrevOpenTime = u
					end
				end

				do break end
			end

			if type(_Schedule.day) == 'table' then
				for _,s in ipairs(_Schedule.day) do
					t = clone(o)
					t.hour = 0
					t.min = 0
					t.hour = s.hour

					if s.minute then
						t.min = s.minute
					end

					local u = os.time(t)

					if u > tCurTime then
						u = u - 24 * 60 * 60
					end

					if u > tPrevOpenTime and u <= tCurTime then
						tPrevOpenTime = u
					end
				end

				do break end
			end

			if type(_Schedule.hour) == 'table' then
				t = clone(o)
				t.min = 0
				local v = _Schedule.hour.val
				t.hour = math.floor(t.hour / v) * v

				if _Schedule.hour.offset then
					if _Schedule.hour.offset.hour then
						t.hour = t.hour + _Schedule.hour.offset.hour
					end

					if _Schedule.hour.offset.minute then
						t.min = _Schedule.hour.offset.minute
					end
				end

				local u = os.time(t)

				if u > tCurTime then
					u = u - v * 60 * 60
				end

				if u > tPrevOpenTime and u <= tCurTime then
					tPrevOpenTime = u
				end

				do break end
			end

			if type(_Schedule.minute) == 'table' then
				t = clone(o)
				local v = _Schedule.minute.val
				t.min = math.floor(t.min / v) * v

				if _Schedule.minute.offset then
					if _Schedule.minute.offset.minute then
						t.min = t.min + _Schedule.minute.offset.minute
					end
				end

				local u = os.time(t)

				if u > tCurTime then
					u = u - v * 60
				end

				if u > tPrevOpenTime and u <= tCurTime then
					tPrevOpenTime = u
				end

				do break end
			end
		end

	until true

	return tPrevOpenTime
end

---@return integer
function sirinDummyRift:GetOpenNext()
	local tCurTime = os.time()
	local tNextOpenTime = 0x7FFFFFFFFFFFFFFF

	repeat
		local ScriptData = self.m_LuaScript

		if not ScriptData.openSchedule then
			break
		end

		if type(ScriptData.openSchedule) ~= 'table' then
			tNextOpenTime = -1
			break
		end

		local Schedule = ScriptData.openSchedule

		if Schedule.absolute then
			tNextOpenTime = -1 -- there is no reopen for 'absolute' schedule
			break
		end

		if Schedule.after then
			tNextOpenTime = -1 -- there is no reopen for 'after' schedule
			break
		end

		local o = os.date("*t", tCurTime)
		local t = {}
		o.sec = 0

		if Schedule.every then
			local _Schedule = Schedule.every

			if type(_Schedule.dayOfMonth) == 'table' then
				for _,s in ipairs(_Schedule.dayOfMonth) do
					t = clone(o)
					t.hour = 0
					t.min = 0
					t.day = s.val

					if s.offset then
						if s.offset.hour then
							t.hour = s.offset.hour
						end

						if s.offset.minute then
							t.min = s.offset.minute
						end
					end

					local u = os.time(t)

					if u <= tCurTime then
						t.month = t.month + 1

						if t.month == 13 then
							t.year = t.year + 1
							t.month = 1
						end

						u = os.time(t)
					end

					if u < tNextOpenTime then
						tNextOpenTime = u
					end
				end

				do break end
			end

			if type(_Schedule.dayOfWeek) == 'table' then
				for _,s in ipairs(_Schedule.dayOfWeek) do
					t = clone(o)
					t.hour = 0
					t.min = 0
					local diff = s.val - t.wday

					if s.offset then
						if s.offset.hour then
							t.hour = s.offset.hour
						end

						if s.offset.minute then
							t.min = s.offset.minute
						end
					end

					local u = os.time(t)

					if diff > 0 then
						u = u + diff * 24 * 60 * 60
					end

					if diff < 0 then
						u = u + (7 + diff) * 24 * 60 * 60
					end

					if u < tNextOpenTime then
						tNextOpenTime = u
					end
				end

				do break end
			end

			if type(_Schedule.day) == 'table' then
				for _,s in ipairs(_Schedule.day) do
					t = clone(o)
					t.hour = 0
					t.min = 0
					t.hour = s.hour

					if s.minute then
						t.min = s.minute
					end

					local u = os.time(t)

					if u <= tCurTime then
						u = u + 24 * 60 * 60
					end

					if u < tNextOpenTime then
						tNextOpenTime = u
					end
				end

				do break end
			end

			if type(_Schedule.hour) == 'table' then
				t = clone(o)
				t.min = 0
				local v = _Schedule.hour.val
				t.hour = math.floor(t.hour / v) * v

				if _Schedule.hour.offset then
					if _Schedule.hour.offset.hour then
						t.hour = t.hour + _Schedule.hour.offset.hour
					end

					if _Schedule.hour.offset.minute then
						t.min = _Schedule.hour.offset.minute
					end
				end

				local u = os.time(t)

				if u <= tCurTime then
					u = u + v * 60 * 60
				end

				if u < tNextOpenTime then
					tNextOpenTime = u
				end

				do break end
			end

			if type(_Schedule.minute) == 'table' then
				t = clone(o)
				local v = _Schedule.minute.val
				t.min = math.floor(t.min / v) * v

				if _Schedule.minute.offset then
					if _Schedule.minute.offset.minute then
						t.min = t.min + _Schedule.minute.offset.minute
					end
				end

				local u = os.time(t)

				if u <= tCurTime then
					u = u + v * 60
				end

				if u < tNextOpenTime then
					tNextOpenTime = u
				end

				do break end
			end
		end

	until true

	return tNextOpenTime
end

---@return integer
function sirinDummyRift:GetCloseNext()
	local tNextCloseTime = -1

	repeat
		local ScriptData = self.m_LuaScript

		if not ScriptData.closeSchedule then
			break
		end

		if type(ScriptData.closeSchedule) ~= 'table' then
			break
		end

		local Schedule = ScriptData.closeSchedule

		if type(Schedule.absolute) == 'table' then
			local _Schedule = Schedule.absolute
			tNextCloseTime = os.time{
			year = _Schedule.year,
			month = _Schedule.month,
			day = _Schedule.day,
			hour = _Schedule.hour,
			min = _Schedule.minute,
			sec = _Schedule.second,
			isdst = USE_DST or false,
			}
			break
		end

		if type(Schedule.after) == 'table' then
			local _Schedule = Schedule.after
			tNextCloseTime = self.m_tNextOpenTime
			tNextCloseTime = tNextCloseTime + (_Schedule.year or 0) * 365 * 24 * 60 * 60
			tNextCloseTime = tNextCloseTime + (_Schedule.month or 0) * 30 * 24 * 60 * 60
			tNextCloseTime = tNextCloseTime + (_Schedule.day or 0) * 24 * 60 * 60
			tNextCloseTime = tNextCloseTime + (_Schedule.hour or 0) * 60 * 60
			tNextCloseTime = tNextCloseTime + (_Schedule.minute or 0) * 60
			tNextCloseTime = tNextCloseTime + (_Schedule.second or 0)
			break
		end

	until true

	return tNextCloseTime
end

---@param bUse? boolean If open happens on portal usage
function sirinDummyRift:openExitDummy(bUse)
	if self.m_LuaScript.exitGateType then
		if self.m_LuaScript.exitGateType == 1 or (self.m_LuaScript.exitGateType == 2 and not bUse) then
			return
		end
	end

	if not self.m_ExitDummyGate then
		self.m_ExitDummyGate = sirinDummyRift:new()
		self.m_ExitDummyGate.m_strScriptID = self.m_strScriptID
	end

	if not self.m_ExitDummyGate:IsOpen() then
		local param = Sirin.mainThread.CReturnGateCreateParam(nil)
		self.m_ExitDummyGate.m_pCObj = Sirin.mainThread.modReturnGate.CreateDummyRift()
		self.m_ExitDummyGate.m_pCObj.m_strObjectUUID = Sirin.getUUIDv4()
		param.m_pRecordSet = nil
		param.m_pMap = self.m_pCObj.m_pDestMap
		param.m_fStartPos_x = self.m_DstPos[1]
		param.m_fStartPos_y = self.m_DstPos[2]
		param.m_fStartPos_z = self.m_DstPos[3]
		param.m_nLayerIndex = self.m_DstPos[4] or 0

		if not self.m_ExitDummyGate:Open(param) then
			if sirinRiftMgr.m_bDebugLog then
				print(string.format("Rift '%s' exit dummy open fail", self.m_strScriptID))
				Sirin.WriteA(RiftMgr.m_pszModReturnGateLogPath, string.format("Rift '%s' exit dummy open fail\n", self.m_strScriptID), true, true)
			end

			self.m_ExitDummyGate.m_bOpen = false
			self.m_ExitDummyGate.m_tNextOpenTime = -1
		end
	end

	if not self.m_LuaScript.exitGateType or self.m_LuaScript.exitGateType == 0 then
		self.m_ExitDummyGate.m_tNextCloseTime = -1
	else
		self.m_ExitDummyGate.m_tNextCloseTime = RiftMgr:getLoopTime() + (self.m_LuaScript.exitGateDelay or 60)
	end
end

function sirinDummyRift:openEnterDummy()
	local param = Sirin.mainThread.CReturnGateCreateParam(nil)
	self.m_pCObj = Sirin.mainThread.modReturnGate.CreateDummyRift()
	self.m_pCObj.m_strObjectUUID = Sirin.getUUIDv4()
	param.m_pRecordSet = nil

	if not self.m_pSrcMap then
		Sirin.WriteA(RiftMgr.m_pszModReturnGateLogPath, string.format("Lua. sirinDummyRift:openEnterDummy() Rift:'%s' self.m_pSrcMap == NULL\n", self.m_strScriptID), true, true)
		return
	end

	param.m_pMap = self.m_pSrcMap
	local srcPos = self.m_LuaScript.srcPos[math.random(1, #self.m_LuaScript.srcPos)]
	param.m_fStartPos_x = srcPos[1]
	param.m_fStartPos_y = srcPos[2]
	param.m_fStartPos_z = srcPos[3]
	param.m_nLayerIndex = srcPos[4] or 0

	if not self:Open(param) then
		if sirinRiftMgr.m_bDebugLog then
			print(string.format("Rift '%s' open fail", self.m_strScriptID))
			Sirin.WriteA(RiftMgr.m_pszModReturnGateLogPath, string.format("Rift '%s' open fail\n", self.m_strScriptID), true, true)
		end

		self.m_bOpen = false
		self.m_bReOpen = false
		self.m_tNextOpenTime = -1
	else
		if sirinRiftMgr.m_bDebugLog then
			---@type string|osdate
			local szBufr = "never"

			if self.m_tNextCloseTime > 0 then
				szBufr = os.date(_, self.m_tNextCloseTime)
			end

			print(string.format("Rift '%s' open success. Next close: %s", self.m_strScriptID, szBufr))
			Sirin.WriteA(RiftMgr.m_pszModReturnGateLogPath, string.format("Rift '%s' open success. Next close: %s\n", self.m_strScriptID, szBufr), true, true)
		end

		self:openExitDummy()
	end
end

---@return sirinRift self
function sirinRift:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

---@param pPlayer CPlayer
---@return integer #Error code
function sirinRift:Enter(pPlayer)
	local nErr = 0

	repeat
		if self.m_pCObj.m_pCurMap ~= pPlayer.m_pCurMap or not self.m_pCObj:IsValidPosition(pPlayer.m_fCurPos_x, pPlayer.m_fCurPos_y, pPlayer.m_fCurPos_z) or self.m_pCObj.m_wMapLayerIndex ~= pPlayer.m_wMapLayerIndex then
			nErr = 3
			break
		end

		if self.m_LuaScript.onCheckUseConditions then
			nErr = self.m_LuaScript.onCheckUseConditions(self, pPlayer)
		end

		if nErr ~= 0 then
			break
		end

		if self.m_LuaScript.onUse then
			self.m_LuaScript.onUse(self, pPlayer)
		end

	until true

	return nErr
end

function sirinRift:Close()
	if not self.m_bOpen then -- to prevent double close
		return
	end

	self.m_bOpen = false
	self.m_bReOpen = false
	self.m_nUseLeft = -1

	if sirinRiftMgr.isSaveState() then
		self.m_tNextOpenTime = self:GetOpenNext()

		if self.m_ExitDummyGate and self.m_ExitDummyGate:IsOpen() then
			self.m_ExitDummyGate.m_bOpen = false
		end

		if sirinRiftMgr.m_bDebugLog then
			---@type string|osdate
			local szBufr = "never"

			if self.m_tNextOpenTime > 0 then
				szBufr = os.date(_, self.m_tNextOpenTime)
			end

			print(string.format("Rift '%s' closed. Next open: %s", self.m_strScriptID, szBufr))
			Sirin.WriteA(RiftMgr.m_pszModReturnGateLogPath, string.format("Rift '%s' closed. Next open: %s\n", self.m_strScriptID, szBufr), true, true)
		end

		Sirin.WritePrivateProfileStringA(self.m_strScriptID, "IsOpen", "0", RiftMgr.m_pszModReturnGateConfigPath)

		if self.m_LuaScript.onClose then
			self.m_LuaScript.onClose(self)
		end
	else
		self.m_tNextOpenTime = -1
	end

	sirinRiftMgr.removeRift(self.m_pCObj)
end

---@return boolean
function sirinRift:IsClose()
	if self.m_tNextCloseTime >= 0 and RiftMgr:getLoopTime() > self.m_tNextCloseTime then
		return true
	end

	if self.m_nUseLeft == 0 then
		return true
	end

	return false
end

---@return boolean
function sirinRift:IsValidOwner()
	if self.m_nUseLeft == 0 then
		return false
	end

	return true
end

---@param pParam CReturnGateCreateParam
---@return boolean
function sirinRift:Open(pParam)
	local bRet = false

	repeat
		if not self.m_pDstMap then
			Sirin.WriteA(RiftMgr.m_pszModReturnGateLogPath, string.format("Lua. SirinRift:Open(pParam) Rift:'%s' self.m_pDstMap == NULL\n", self.m_strScriptID), true, true)
			break
		end

		self.m_pCObj.m_pDestMap = self.m_pDstMap
		self.m_DstPos = self.m_LuaScript.dstPos[math.random(1, #self.m_LuaScript.dstPos)]
		local MapFld = Sirin.mainThread.baseToMap(self.m_pCObj.m_pDestMap.m_pMapSet)

		if MapFld.m_nMapType ~= 0 then
			if not self.m_pCObj.m_pDestMap:m_ls_get(self.m_DstPos[4]):IsActiveLayer() then
				local nErr = Sirin.mainThread.activateLayer(MapFld.m_dwIndex, self.m_DstPos[4], true)

				if nErr ~= 0 then
					Sirin.WriteA(RiftMgr.m_pszModReturnGateLogPath, string.format("Lua. SirinRift:Open(pParam) Rift:'%s' Dst.activateLayer(%d, %d, true) != E_OK\n", self.m_strScriptID, MapFld.m_dwIndex, self.m_DstPos[4]), true, true)
					break
				end
			end
		end

		MapFld = Sirin.mainThread.baseToMap(pParam.m_pMap.m_pMapSet)

		if MapFld.m_nMapType ~= 0 then
			if not pParam.m_pMap:m_ls_get(pParam.m_nLayerIndex):IsActiveLayer() then
				local nErr = Sirin.mainThread.activateLayer(MapFld.m_dwIndex, pParam.m_nLayerIndex, true)

				if nErr ~= 0 then
					Sirin.WriteA(RiftMgr.m_pszModReturnGateLogPath, string.format("Lua. SirinRift:Open(pParam) Rift:'%s' Src.activateLayer(%d, %d, true) != E_OK\n", self.m_strScriptID, MapFld.m_dwIndex, pParam.m_nLayerIndex), true, true)
					break
				end
			end
		end

		if not self.m_pCObj:Create(pParam) then
			Sirin.WriteA(RiftMgr.m_pszModReturnGateLogPath, string.format("Lua. SirinRift:Open(pParam) Rift:'%s' CGameObject::Create() Failed!\n", self.m_strScriptID), true, true)
			break
		end

		self.m_pCObj.m_dwOwnerSerial = 0xFFFFFFFF
		self.m_pCObj.m_dwObjSerial = self.m_pCObj:GetIndex()
		self.m_pCObj.m_eState = 1 -- REG_WAIT
		self.m_bOpen = true

		if not self.m_bReOpen then
			self.m_nUseLeft = self.m_LuaScript.useCount or -1
			self.m_tNextCloseTime = self:GetCloseNext()
			Sirin.WritePrivateProfileStringA(self.m_strScriptID, "IsOpen", "1", RiftMgr.m_pszModReturnGateConfigPath)
			Sirin.WritePrivateProfileStringA(self.m_strScriptID, "UseLeft", string.format("%d", self.m_nUseLeft), RiftMgr.m_pszModReturnGateConfigPath)
			Sirin.WritePrivateProfileStringA(self.m_strScriptID, "CloseTime", string.format("%d", self.m_tNextCloseTime), RiftMgr.m_pszModReturnGateConfigPath)
		end

		sirinRiftMgr.addRift(self.m_pCObj, self)
		self.m_pCObj:SendMsg_Create()

		if self.m_LuaScript.onOpen then
			self.m_LuaScript.onOpen(self)
		end

		bRet = true

	until true

	return bRet
end

--[[
struct _move_potal_result_zocl
{
	unsigned char byRet;
	unsigned char byMapIndex;
	float fStartPos[3];
	unsigned char byZoneCode;
	size_t Size() { return sizeof(*this); }
};
--]]

---@param pPlayer CPlayer
function sirinRift:SendMsg_MovePortal(pPlayer)
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()

	buf:PushUInt8(0)
	buf:PushUInt8(self.m_pCObj.m_pDestMap.m_pMapSet.m_dwIndex)
	buf:PushFloat(self.m_pCObj.m_fBindPos_x)
	buf:PushFloat(self.m_pCObj.m_fBindPos_y)
	buf:PushFloat(self.m_pCObj.m_fBindPos_z)
	buf:PushUInt8(2)

	buf:SendBuffer(pPlayer, 8, 2)
end

return sirinRiftMgr
