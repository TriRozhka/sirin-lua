local projectName = 'sirin'
local moduleName = 'modCustomWindows'

local script = {
    m_strUUID = projectName .. ".lua." .. moduleName,
	m_pszLogPath = '.\\sirin-log\\guard\\ModWindowExt.log',
}

--- Respond to 'onPressCustomWindowButton' hook
---@param pPlayer CPlayer
---@param dwActWindowID integer
---@param dwActDataID integer
---@param dwSelectWindowID integer
---@param dwSelectDataID integer
---@param dwVisualVer integer
---@param strInput string
function script.onButtonPress(pPlayer, dwActWindowID, dwActDataID, dwSelectWindowID, dwSelectDataID, dwVisualVer, strInput)
    print(string.format("actBtn: %d actWnd: %d selBtn: %d selWnd: %d ver: %d", dwActWindowID, dwActDataID, dwSelectWindowID, dwSelectDataID, dwVisualVer))

    if dwActWindowID == 1 then
		local langId = Sirin.CLanguageAsset.instance():getPlayerLanguage(pPlayer.m_id.wIndex)
		local windows = SirinScript_CustomWindowsByLangID[langId]

		if dwActDataID ~= #windows[1].data then
			return
		end

		local send = {}
		send.ct = 3
		send.data = {}
		local w = {}
		table.insert(send.data, w)
		w.id = 2
		w.data = {}

		for i = 1, #windows[2].data do
			local data = {}
			data.id = i
			data.stateFlags = tonumber("101", 2)
			data.delay = { 1, 1 }
			data.counter = { -1, -1 }
			table.insert(w.data, data)
		end

		local netOP = NetOP:new()
		netOP:SendData(pPlayer, "sirin.proto.customWindows", send, true)
    end
end

---@param pPlayer CPlayer
local function sendUpdatedData(pPlayer)
	local langId = Sirin.CLanguageAsset.instance():getPlayerLanguage(pPlayer.m_id.wIndex)
	local windows = SirinScript_CustomWindowsByLangID[langId]
	local send = {}
	send.ct = 0 -- 0 init, 1 add (set), 2 delete, 3 update
	send.data = {}

	for _,sw in pairs(windows) do
		local w = clone(sw)

		if w.id == 1 and #w.data > 0 then
			for i = 1, #w.data - 1 do
				w.data[i].stateFlags = tonumber("101", 2)
			end

			w.data[#w.data].stateFlags = tonumber("1101", 2)
		end

		table.insert(send.data, w)
	end

	local netOP = NetOP:new()
	netOP:SendData(pPlayer, "sirin.proto.customWindows", send, true)
end

---@param pPlayer CPlayer
---@param pUserDB CUserDB
---@param bFirstStart boolean
function script.CPlayer__Load(pPlayer, pUserDB, bFirstStart)
	sendUpdatedData(pPlayer)
end

-- Print to server console script loaded
function script.onThreadBegin()
	script.loadScripts()
    print("'customWindowDemo' Script Loaded")
end

function script.onThreadEnd()
end

local function autoInit()
    if not _G[moduleName] then -- One time initialization
        _G[moduleName] = script -- Bind your script to a global variable. Variable name must be unique.

        table.insert(SirinLua.onThreadBegin, function() _G[moduleName].onThreadBegin() end)
        table.insert(SirinLua.onThreadEnd, function() _G[moduleName].onThreadEnd() end)
    else
        _G[moduleName] = script -- On reload 
    end
    SirinLua.HookMgr.releaseHookByUID(script.m_strUUID)

	SirinLua.HookMgr.addHook("CPlayer__Load", HOOK_POS.after_event, script.m_strUUID, script.CPlayer__Load)
    -- Add hook to respond to clicks from Function Menu. Call -> onButtonPressed
    SirinLua.HookMgr.addHook("onPressCustomWindowButton", HOOK_POS.after_event, script.m_strUUID, script.onButtonPress)
end

---@return boolean
function script.loadScripts()
	local bSucc = true

	repeat
		---@type table<integer, sirin_CustomWindow>?
		SirinTmp_CustomWindows = FileLoader.LoadChunkedTable(".\\sirin-lua\\threads\\main\\ReloadableScripts\\CustomWindows")

		if not SirinTmp_CustomWindows then
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Failed to load 'CustomWindows' scripts!\n")
			Sirin.WriteA(script.m_pszLogPath, "Failed to load 'CustomButtons' scripts!\n", true, true)
			bSucc = false
			break
		end

		for k,v in pairs(SirinTmp_CustomWindows) do
			repeat
				if type(v["name"]) ~= "table" then
					local fmt = string.format("Lua. script.loadScripts() Window record:%d 'name' invalid format! Table expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
					bSucc = false
					break
				end

				for tk,tv in pairs(v["name"]) do
					repeat
						if type(tv) ~= "string" then
							local fmt = string.format("Lua. script.loadScripts() Window record:%d 'name[%s]' invalid format! String expected.\n", k, tk)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
							bSucc = false
							break
						end
					until true
				end

				if k ~= 1 then
					if math.type(v["width"]) ~= "integer" then
						local fmt = string.format("Lua. script.loadScripts() Window record:%d 'width' invalid format! Number expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					if math.type(v["height"]) ~= "integer" then
						local fmt = string.format("Lua. script.loadScripts() Window record:%d 'height' invalid format! Number expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					if type(v["layout"]) ~= "table" then
						local fmt = string.format("Lua. script.loadScripts() Window record:%d 'layout' invalid format! Table expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					for tk,tv in ipairs(v["layout"]) do
						repeat
							if math.type(tv) ~= "integer" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'layout[%d]' invalid format! Integer expected.\n", k, tk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end
						until true
					end
				end

				if v["headerWindowID"] and math.type(v["headerWindowID"]) ~= "integer" then
					local fmt = string.format("Lua. script.loadScripts() Window record:%d 'headerWindowID' invalid format! Integer expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
					bSucc = false
					break
				end

				if v["footerWindowID"] and math.type(v["footerWindowID"]) ~= "integer" then
					local fmt = string.format("Lua. script.loadScripts() Window record:%d 'footerWindowID' invalid format! Integer expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
					bSucc = false
					break
				end

				if v["strModal_Ok"] then
					if type(v["strModal_Ok"]) ~= "table" then
						local fmt = string.format("Lua. script.loadScripts() Window record:%d 'strModal_Ok' invalid format! Table expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					for tk,tv in pairs(v["strModal_Ok"]) do
						repeat
							if type(tv) ~= "string" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'strModal_Ok[%s]' invalid format! String expected.\n", k, tk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end
						until true
					end
				end

				if v["strModal_Cancel"] then
					if type(v["strModal_Cancel"]) ~= "table" then
						local fmt = string.format("Lua. script.loadScripts() Window record:%d 'strModal_Cancel' invalid format! Table expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					for tk,tv in pairs(v["strModal_Cancel"]) do
						repeat
							if type(tv) ~= "string" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'strModal_Cancel[%s]' invalid format! String expected.\n", k, tk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end
						until true
					end
				end

				if v["strModal_Text"] then
					if type(v["strModal_Text"]) ~= "table" then
						local fmt = string.format("Lua. script.loadScripts() Window record:%d 'strModal_Text' invalid format! Table expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					for tk,tv in pairs(v["strModal_Text"]) do
						repeat
							if type(tv) ~= "string" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'strModal_Text[%s]' invalid format! String expected.\n", k, tk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end
						until true
					end
				end

				if v["overlayIcons"] then
					if type(v["overlayIcons"]) ~= "table" then
						local fmt = string.format("Lua. script.loadScripts() Window record:%d 'overlayIcons' invalid format! Table expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					for ik,iv in ipairs(v["overlayIcons"]) do
						repeat
							if type(iv) ~= "table" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'overlayIcons[%d]' invalid format! Table expected.\n", k, ik)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if #iv ~= 4 then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'overlayIcons[%d]' Out of range! Table size 4 expected.\n", k, ik)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for sk,sv in ipairs(iv) do
								repeat
									if math.type(sv) ~= "integer" then
										local fmt = string.format("Lua. script.loadScripts() Window record:%d 'overlayIcons[%d][%d]' invalid format! Integer expected.\n", k, ik, sk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						until true
					end
				end

				if type(v["data"]) ~= "table" then
					local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data' invalid format! Table expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
					bSucc = false
					break
				end

				for dk,dv in ipairs(v["data"]) do
					repeat
						if dv["icon"] then
							if type(dv["icon"]) ~= "table" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][icon]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if #dv["icon"] < 4 then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][icon]' Out of range! Table size >= 4 expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in ipairs(dv["icon"]) do
								repeat
									if math.type(tv) ~= "integer" then
										local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][icon][%d]' invalid format! Integer expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						end

						if dv["text"] then
							if type(dv["text"]) ~= "table" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][text]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in pairs(dv["text"]) do
								repeat
									if type(tv) ~= "string" then
										local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][text][%s]' invalid format! String expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						end

						if dv["item"] then
							if type(dv["item"]) ~= "string" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][item]' invalid format! String expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							local itemCode = tostring(dv["item"])
							local nTableType = Sirin.mainThread.GetItemTableCode(itemCode)

							if nTableType == -1 then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][item] = %s' Invalid item type!\n", k, dk, itemCode)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(nTableType):GetRecordByHash(itemCode, 2, 5)

							if not pFld then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][item] = %s' Item not found!\n", k, dk, itemCode)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							dv["item"] = { nTableType, pFld.m_dwIndex }
						end

						if dv["tooltip"] then
							if type(dv["tooltip"]["name"]) ~= "table" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][tooltip][name]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if type(dv["tooltip"]["name"]["text"]) ~= "table" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][tooltip][name][text]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in pairs(dv["tooltip"]["name"]["text"]) do
								repeat
									if type(tv) ~= "string" then
										local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][tooltip][name][text][%s]' invalid format! String expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end

							if dv["tooltip"]["name"]["color"] and math.type(dv["tooltip"]["name"]["color"]) ~= "integer" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][tooltip][name][color]' invalid format! Integer expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if dv["tooltip"]["info"] then
								if type(dv["tooltip"]["info"]) ~= "table" then
									local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][tooltip][info]' invalid format! Table expected.\n", k, dk)
									Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
									Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
									bSucc = false
									break
								end

								for tk,tv in pairs(dv["tooltip"]["info"]) do
									repeat
										for ik,iv in ipairs(tv) do
											repeat
												if type(iv[1]) ~= "string" then
													local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][tooltip][info][%s][%d][1]' invalid format! String expected.\n", k, dk, tk, ik)
													Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
													Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
													bSucc = false
													break
												end

												if type(iv[2]) ~= "string" then
													local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][tooltip][info][%s][%d][2]' invalid format! String expected.\n", k, dk, tk, ik)
													Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
													Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
													bSucc = false
													break
												end

												if iv[3] and math.type(iv[3]) ~= "integer" then
													local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][tooltip][info][%s][%d][3]' invalid format! Integer expected.\n", k, dk, tk, ik)
													Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
													Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
													bSucc = false
													break
												end
											until true
										end
									until true
								end
							end
						end

						if dv["description"] then
							if type(dv["description"]) ~= "table" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][description]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in pairs(dv["description"]) do
								repeat
									if type(tv) ~= "string" then
										local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][description][%s]' invalid format! String expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						end

						if dv["durability"] and math.type(dv["durability"]) ~= "integer" then
							local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][durability]' invalid format! Integer expected.\n", k, dk)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if dv["upgrade"] and math.type(dv["upgrade"]) ~= "integer" then
							local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][upgrade]' invalid format! Integer expected.\n", k, dk)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if dv["clientWindow"] and math.type(dv["clientWindow"]) ~= "integer" then
							local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][clientWindow]' invalid format! Integer expected.\n", k, dk)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if dv["npcCode"] then
							if type(dv["npcCode"]) ~= "string" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][npcCode]' invalid format! String expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							--TODO: NPC code verification
							--Sirin.mainThread.CItemStoreManager.Instance()
						end

						if dv["customWindow"] and math.type(dv["customWindow"]) ~= "integer" then
							local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][customWindow]' invalid format! Integer expected.\n", k, dk)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if dv["raceLimit"] then
							if type(dv["raceLimit"]) ~= "table" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][raceLimit]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in ipairs(dv["raceLimit"]) do
								repeat
									if math.type(tv) ~= "integer" then
										local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][raceLimit][%d]' invalid format! Integer expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						end

						if dv["raceBoss"] then
							if type(dv["raceBoss"]) ~= "table" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][raceBoss]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in ipairs(dv["raceBoss"]) do
								repeat
									if math.type(tv) ~= "integer" then
										local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][raceBoss][%d]' invalid format! Integer expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						end

						if dv["guildClass"] then
							if type(dv["guildClass"]) ~= "table" then
								local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][guildClass]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in ipairs(dv["guildClass"]) do
								repeat
									if math.type(tv) ~= "integer" then
										local fmt = string.format("Lua. script.loadScripts() Window record:%d 'data[%d][guildClass][%d]' invalid format! Integer expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						end
					until true
				end
			until true
		end

		if bSucc then
			SirinScript_CustomWindows = SirinTmp_CustomWindows
			SirinTmp_CustomWindows = nil
			SirinScript_CustomWindowsByLangID = {}

			local lngAst = Sirin.CLanguageAsset.instance()
			local langs = lngAst:getLanguageTable()

			for _,l in ipairs(langs) do
				SirinScript_CustomWindowsByLangID[l[1]] = script.getWindowDataForLanguage(l[2])
			end

			local onlinePlayers = Sirin.mainThread.getActivePlayers()

			for _,p in ipairs(onlinePlayers) do
				sendUpdatedData(p)
			end
		else
			local fmt = "CustomWindows:loadScripts: bSucc == false!\n"
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
			Sirin.WriteA(script.m_pszLogPath, fmt, true, true)
		end

	until true

	return bSucc
end

---@param langPref string
---@return table
function script.getWindowDataForLanguage(langPref)
	local wd = {}

	for id,sw in pairs(SirinScript_CustomWindows) do
		local w = {}
		w.id = id
		wd[id] = w

		if sw.name then w.name = sw.name[langPref] or sw.name.default or "NO DEFAULT DATA line: " .. __LINE__() end
		if sw.width then w.width = sw.width end
		if sw.height then w.height = sw.height end
		if sw.headerWindowID then w.headerWindowID = sw.headerWindowID end
		if sw.footerWindowID then w.footerWindowID = sw.footerWindowID end
		if sw.layout then w.layout = clone(sw.layout) end
		if sw.strModal_Ok then w.strModal_Ok = sw.strModal_Ok[langPref] or sw.strModal_Ok.default or "NO DEFAULT DATA line: " .. __LINE__() end
		if sw.strModal_Cancel then w.strModal_Cancel = sw.strModal_Cancel[langPref] or sw.strModal_Cancel.default or "NO DEFAULT DATA line: " .. __LINE__() end
		if sw.strModal_Text then w.strModal_Text = sw.strModal_Text[langPref] or sw.strModal_Text.default or "NO DEFAULT DATA line: " .. __LINE__() end
		if sw.overlayIcons then
			w.overlayIcons = {}
			for k,oi in ipairs(sw.overlayIcons) do
				local o = {}
				o.id = k
				o.icon = clone(oi)
				w.overlayIcons[k] = o
			end
		end
		if sw.data then
			w.data = {}
			for k,sd in ipairs(sw.data) do
				local d = {}
				d.id = k
				if sd.icon then d.icon = clone(sd.icon) end
				if sd.description then d.description = sd.description[langPref] or sd.description.default or "NO DEFAULT DATA line: " .. __LINE__() end
				if sd.durability then d.durability = sd.durability end
				if sd.upgrade then d.upgrade = sd.upgrade end
				if sd.text then d.text = sd.text[langPref] or sd.text.default or "NO DEFAULT DATA line: " .. __LINE__() end
				if sd.item then d.item = clone(sd.item) end
				if sd.tooltip then
					d.tooltip = {}
					d.tooltip.name = {}
					d.tooltip.name.text = sd.tooltip.name.text[langPref] or sd.tooltip.name.text.default or "NO DEFAULT DATA line: " .. __LINE__()
					if sd.tooltip.name.color then d.tooltip.name.color = sd.tooltip.name.color end
					if sd.tooltip.info then
						d.tooltip.info = {}
						local si = sd.tooltip.info[langPref] or sd.tooltip.info.default or { { "NO DEFAULT DATA", "line: " .. __LINE__(), 0xFFFF0000 } }
						for j,sl in ipairs(si) do
							local l = {}
							l.id = j
							l.left = sl[1]
							l.right = sl[2]
							if sl[3] then l.color = sl[3] end
							d.tooltip.info[j] = l
						end
					end
				end
				if sd.clientWindow then d.clientWindow = sd.clientWindow end
				if sd.npcCode then d.npcCode = sd.npcCode end
				if sd.customWindow then d.customWindow = sd.customWindow end
				if sd.raceLimit then d.raceLimit = clone(sd.raceLimit) end
				if sd.raceBoss then d.raceBoss = clone(sd.raceBoss) end
				if sd.guildClass then d.guildClass = clone(sd.guildClass) end
				if sd.isGM then d.isGM = true end
				if sd.isPremium then d.isPremium = true end
				w.data[k] = d
			end
		end
	end

	return wd
end

---@param pPlayer CPlayer
---@param dwWindowID integer
---@param byType integer
local function example_openWindow(pPlayer, dwWindowID, byType)
	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	buf:PushUInt8(byType) -- 0 default window, 1 custom window
	buf:PushUInt32(dwWindowID) -- window index
	buf:PushUInt32(0) -- NPC Code for store and AH buy. in other case 0. Example: tonumber("01234", 16)
	buf:SendBuffer(pPlayer, 80, 12)
end

---@class (exact) sirin_IconData
---@field [1] integer sprite
---@field [2] integer group
---@field [3] integer frame
---@field [4] integer index
---@field [5]? integer width
---@field [6]? integer height
local sirin_LayoutData = {}

---@class (exact) sirin_ToolTipName
---@field text table<string, string>
---@field color integer
local sirin_ToolTipName = {}

---@class (exact) sirin_ToolTipInfo
---@field [1] string Left
---@field [2] string Right
---@field [3]? integer Color
local sirin_ToolTipInfo = {}

---@class (exact) sirin_ToolTip
---@field name sirin_ToolTipName
---@field info table<string, table<integer, sirin_ToolTipInfo>>
local sirin_ToolTip = {}

---@class (exact) sirin_CustomWindow_Data
---@field icon sirin_IconData
---@field item string|table<integer, integer>
---@field text table<string, string>
---@field description table<string, string>
---@field durability integer
---@field upgrade integer
---@field tooltip sirin_ToolTip
---@field clientWindow integer
---@field customWindow integer
---@field npcCode integer
---@field raceLimit table<integer, integer>
---@field raceBoss table<integer, integer>
---@field guildClass table<integer, integer>
---@field isGM boolean
---@field isPremium boolean
local sirin_CustomWindow_Data = {}

---@class (exact) sirin_CustomWindow
---@field name table<string, string>
---@field width integer
---@field height integer
---@field layout table<integer, integer>
---@field headerWindowID integer
---@field footerWindowID integer
---@field strModal_Ok table<string, string>
---@field strModal_Cancel table<string, string>
---@field strModal_Text table<string, string>
---@field overlayIcons table<integer, sirin_IconData>
---@field data table<integer, sirin_CustomWindow_Data>
local sirin_CustomWindow = {}

autoInit()