---@class (exact) sirinCustomWindows
---@field m_pszLogPath string
---@field m_strUUID string
---@field initHooks fun()
---@field CPlayer__Load fun(pPlayer: CPlayer, pUserDB: CUserDB, bFirstStart: boolean)
---@field loadScripts fun(): boolean
local sirinCustomWindows = {
	m_pszLogPath = '.\\sirin-log\\guard\\ModWindowExt.log',
	m_strUUID = "sirin.lua.modCustomWindows",
}

function sirinCustomWindows.initHooks()
	SirinLua.HookMgr.addHook("CPlayer__Load", HOOK_POS.after_event, sirinCustomWindows.m_strUUID, sirinCustomWindows.CPlayer__Load)
end

---@param pPlayer CPlayer
---@param pUserDB CUserDB
---@param bFirstStart boolean
function sirinCustomWindows.CPlayer__Load(pPlayer, pUserDB, bFirstStart)
	if SirinScript_CustomWindows[1] and #SirinScript_CustomWindows[1].data > 0 then
		local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
		buf:Init()
		buf:PushUInt32(1)
		buf:PushUInt32(#SirinScript_CustomWindows[1].data)

		for i = 1, #SirinScript_CustomWindows[1].data - 1 do
			buf:PushUInt32(tonumber("101", 2)) -- state flags
			buf:PushUInt32(0) -- delay remain in seconds
			buf:PushUInt32(0) -- delay total in seconds
			buf:PushUInt32(0) -- counter on icon
			buf:PushUInt32(0) -- counter 2 on icon
		end

		buf:PushUInt32(tonumber("1101", 2)) -- Server request
		buf:PushUInt32(0)
		buf:PushUInt32(0)
		buf:PushUInt32(0)
		buf:PushUInt32(0)

		buf:SendBuffer(pPlayer, 80, 12)
	end
end

---@return boolean
function sirinCustomWindows.loadScripts()
	local bSucc = true

	repeat
		---@type table<integer, sirin_CustomWindow>?
		SirinTmp_CustomWindows = FileLoader.LoadChunkedTable(".\\sirin-lua\\threads\\main\\ReloadableScripts\\CustomWindows")

		if not SirinTmp_CustomWindows then
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Failed to load 'CustomWindows' scripts!\n")
			Sirin.WriteA(sirinCustomWindows.m_pszLogPath, "Failed to load 'CustomButtons' scripts!\n", true, true)
			bSucc = false
			break
		end

		for k,v in pairs(SirinTmp_CustomWindows) do
			repeat
				if type(v["name"]) ~= "table" then
					local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'name' invalid format! Table expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
					bSucc = false
					break
				end

				for tk,tv in pairs(v["name"]) do
					repeat
						if type(tv) ~= "string" then
							local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'name[%s]' invalid format! String expected.\n", k, tk)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
							bSucc = false
							break
						end
					until true
				end

				if k ~= 1 then
					if math.type(v["width"]) ~= "integer" then
						local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'width' invalid format! Number expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					if math.type(v["height"]) ~= "integer" then
						local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'height' invalid format! Number expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					if type(v["layout"]) ~= "table" then
						local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'layout' invalid format! Table expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					for tk,tv in ipairs(v["layout"]) do
						repeat
							if math.type(tv) ~= "integer" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'layout[%d]' invalid format! Integer expected.\n", k, tk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end
						until true
					end
				end

				if v["headerWindowID"] and math.type(v["headerWindowID"]) ~= "integer" then
					local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'headerWindowID' invalid format! Integer expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
					bSucc = false
					break
				end

				if v["footerWindowID"] and math.type(v["footerWindowID"]) ~= "integer" then
					local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'footerWindowID' invalid format! Integer expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
					bSucc = false
					break
				end

				if v["strModal_Ok"] then
					if type(v["strModal_Ok"]) ~= "table" then
						local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'strModal_Ok' invalid format! Table expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					for tk,tv in pairs(v["strModal_Ok"]) do
						repeat
							if type(tv) ~= "string" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'strModal_Ok[%s]' invalid format! String expected.\n", k, tk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end
						until true
					end
				end

				if v["strModal_Cancel"] then
					if type(v["strModal_Cancel"]) ~= "table" then
						local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'strModal_Cancel' invalid format! Table expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					for tk,tv in pairs(v["strModal_Cancel"]) do
						repeat
							if type(tv) ~= "string" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'strModal_Cancel[%s]' invalid format! String expected.\n", k, tk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end
						until true
					end
				end

				if v["strModal_Text"] then
					if type(v["strModal_Text"]) ~= "table" then
						local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'strModal_Text' invalid format! Table expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					for tk,tv in pairs(v["strModal_Text"]) do
						repeat
							if type(tv) ~= "string" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'strModal_Text[%s]' invalid format! String expected.\n", k, tk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end
						until true
					end
				end

				if v["overlayIcons"] then
					if type(v["overlayIcons"]) ~= "table" then
						local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'overlayIcons' invalid format! Table expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
						bSucc = false
						break
					end

					for ik,iv in ipairs(v["overlayIcons"]) do
						repeat
							if type(iv) ~= "table" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'overlayIcons[%d]' invalid format! Table expected.\n", k, ik)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if #iv ~= 4 then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'overlayIcons[%d]' Out of range! Table size 4 expected.\n", k, ik)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for sk,sv in ipairs(iv) do
								repeat
									if math.type(sv) ~= "integer" then
										local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'overlayIcons[%d][%d]' invalid format! Integer expected.\n", k, ik, sk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						until true
					end
				end

				if type(v["data"]) ~= "table" then
					local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data' invalid format! Table expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
					bSucc = false
					break
				end

				for dk,dv in ipairs(v["data"]) do
					repeat
						if dv["icon"] then
							if type(dv["icon"]) ~= "table" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][icon]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if #dv["icon"] < 4 then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][icon]' Out of range! Table size >= 4 expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in ipairs(dv["icon"]) do
								repeat
									if math.type(tv) ~= "integer" then
										local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][icon][%d]' invalid format! Integer expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						end

						if dv["text"] then
							if type(dv["text"]) ~= "table" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][text]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in pairs(dv["text"]) do
								repeat
									if type(tv) ~= "string" then
										local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][text][%s]' invalid format! String expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						end

						if dv["item"] then
							if type(dv["item"]) ~= "string" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][item]' invalid format! String expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							local itemCode = tostring(dv["item"])
							local nTableType = Sirin.mainThread.GetItemTableCode(itemCode)

							if nTableType == -1 then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][item] = %s' Invalid item type!\n", k, dk, itemCode)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(nTableType):GetRecordByHash(itemCode, 2, 5)

							if not pFld then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][item] = %s' Item not found!\n", k, dk, itemCode)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							dv["item"] = { nTableType, pFld.m_dwIndex }
						end

						if dv["tooltip"] then
							if type(dv["tooltip"]["name"]) ~= "table" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][tooltip][name]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if type(dv["tooltip"]["name"]["text"]) ~= "table" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][tooltip][name][text]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in pairs(dv["tooltip"]["name"]["text"]) do
								repeat
									if type(tv) ~= "string" then
										local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][tooltip][name][text][%s]' invalid format! String expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end

							if dv["tooltip"]["name"]["color"] and math.type(dv["tooltip"]["name"]["color"]) ~= "integer" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][tooltip][name][color]' invalid format! Integer expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if dv["tooltip"]["info"] then
								if type(dv["tooltip"]["info"]) ~= "table" then
									local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][tooltip][info]' invalid format! Table expected.\n", k, dk)
									Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
									Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
									bSucc = false
									break
								end

								for tk,tv in pairs(dv["tooltip"]["info"]) do
									repeat
										for ik,iv in ipairs(tv) do
											repeat
												if type(iv[1]) ~= "string" then
													local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][tooltip][info][%s][%d][1]' invalid format! String expected.\n", k, dk, tk, ik)
													Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
													Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
													bSucc = false
													break
												end

												if type(iv[2]) ~= "string" then
													local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][tooltip][info][%s][%d][2]' invalid format! String expected.\n", k, dk, tk, ik)
													Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
													Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
													bSucc = false
													break
												end

												if iv[3] and math.type(iv[3]) ~= "integer" then
													local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][tooltip][info][%s][%d][3]' invalid format! Integer expected.\n", k, dk, tk, ik)
													Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
													Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
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
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][description]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in pairs(dv["description"]) do
								repeat
									if type(tv) ~= "string" then
										local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][description][%s]' invalid format! String expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						end

						if dv["durability"] and math.type(dv["durability"]) ~= "integer" then
							local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][durability]' invalid format! Integer expected.\n", k, dk)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if dv["upgrade"] and math.type(dv["upgrade"]) ~= "integer" then
							local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][upgrade]' invalid format! Integer expected.\n", k, dk)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if dv["clientWindow"] and math.type(dv["clientWindow"]) ~= "integer" then
							local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][clientWindow]' invalid format! Integer expected.\n", k, dk)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if dv["npcCode"] then
							if type(dv["npcCode"]) ~= "string" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][npcCode]' invalid format! String expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							--TODO: NPC code verification
							--Sirin.mainThread.CItemStoreManager.Instance()
						end

						if dv["customWindow"] and math.type(dv["customWindow"]) ~= "integer" then
							local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][customWindow]' invalid format! Integer expected.\n", k, dk)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if dv["raceLimit"] then
							if type(dv["raceLimit"]) ~= "table" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][raceLimit]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in ipairs(dv["raceLimit"]) do
								repeat
									if math.type(tv) ~= "integer" then
										local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][raceLimit][%d]' invalid format! Integer expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						end

						if dv["raceBoss"] then
							if type(dv["raceBoss"]) ~= "table" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][raceBoss]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in ipairs(dv["raceBoss"]) do
								repeat
									if math.type(tv) ~= "integer" then
										local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][raceBoss][%d]' invalid format! Integer expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
										bSucc = false
										break
									end
								until true
							end
						end

						if dv["guildClass"] then
							if type(dv["guildClass"]) ~= "table" then
								local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][guildClass]' invalid format! Table expected.\n", k, dk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
								bSucc = false
								break
							end

							for tk,tv in ipairs(dv["guildClass"]) do
								repeat
									if math.type(tv) ~= "integer" then
										local fmt = string.format("Lua. sirinCustomWindows.loadScripts() Window record:%d 'data[%d][guildClass][%d]' invalid format! Integer expected.\n", k, dk, tk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
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
			Sirin.mainThread.modWindowExt.RegisterAsset()

			if Sirin.CAssetController.instance():makeAssetData("sirin.asset.windows") then
				Sirin.CAssetController.instance():sendAssetData("sirin.asset.windows")

				if SirinScript_CustomWindows[1] and #SirinScript_CustomWindows[1].data > 0 then
					local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
					local players = Sirin.mainThread.getActivePlayers()

					for _,p in ipairs(players) do
						buf:Init()
						buf:PushUInt32(1)
						buf:PushUInt32(#SirinScript_CustomWindows[1].data)

						for i = 1, #SirinScript_CustomWindows[1].data do
							buf:PushUInt32(tonumber("101", 2)) -- state flags
							buf:PushUInt32(0) -- delay remain in seconds
							buf:PushUInt32(0) -- delay total in seconds
							buf:PushUInt32(0) -- counter on icon
							buf:PushUInt32(0) -- counter 2 on icon
						end

						buf:SendBuffer(p, 80, 12)
					end
				end
			else
				local fmt = "CustomWindows:loadScripts: makeAssetData() == false!\n"
				Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
				Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
			end
		else
			local fmt = "CustomWindows:loadScripts: bSucc == false!\n"
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
			Sirin.WriteA(sirinCustomWindows.m_pszLogPath, fmt, true, true)
		end

	until true

	return bSucc
end

---@param pPlayer CPlayer
---@param dwWindowID integer
local function example_updateState(pPlayer, dwWindowID)
	local w = SirinScript_CustomWindows[dwWindowID]

	if not w or not w.data or #w.data == 0 then
		return
	end

	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	buf:PushUInt32(dwWindowID)
	buf:PushUInt32(#w.data)

	for i = 1, #w.data do
		buf:PushUInt32(tonumber("1111", 2)) -- state flags: bit 0 is visible, bit 1 is active, bit 2 is button, bit 3 is need server report, bits 4-31 overlay icon apply
		buf:PushUInt32(0) -- delay remain in seconds
		buf:PushUInt32(0) -- delay total in seconds
		buf:PushUInt32(0) -- counter on icon
		buf:PushUInt32(0) -- counter 2 on icon
	end

	buf:SendBuffer(pPlayer, 80, 12)
end

---@param pPlayer CPlayer
---@param dwWindowID integer
---@param dwObjectIndex integer
---@param byType integer
local function example_updateData(pPlayer, dwWindowID, dwObjectIndex, byType)
	local w = SirinScript_CustomWindows[dwWindowID]

	if not w then
		return
	end

	if byType > 1 and (not w.data or #w.data == 0) then
		return
	end

	local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
	buf:Init()
	buf:PushUInt32(dwWindowID)
	buf:PushUInt8(byType)

	if byType == 0 then -- Update layout
		buf:PushUInt8(4) -- num of columns
		buf:PushUInt32(0) -- col 1 is icon
		buf:PushUInt32(0) -- col 2 is icon
		buf:PushUInt32(0) -- col 3 is icon
		buf:PushUInt32(1) -- col 4 is text
	elseif byType == 1 then -- update overlay icon list
		local ln = 8
		buf:PushUInt8(ln) -- num of overlay icons

		for i = 1, ln do
			buf:PushUInt8(0) -- sprite id
			buf:PushUInt8(0) -- group id
			buf:PushUInt8(0) -- frame id
			buf:PushUInt16(0) -- grid index
		end
	elseif byType == 2 then -- update icon or text of particular object
		buf:PushUInt32(dwObjectIndex) -- object index to update

		if true then -- if object is icon
			buf:PushUInt8(0) -- sprite id
			buf:PushUInt8(0) -- group id
			buf:PushUInt8(0) -- frame id
			buf:PushUInt16(0) -- grid index
			buf:PushUInt32(0) -- width
			buf:PushUInt32(0) -- height
			local str = "on hover text"
			buf:PushString(str, str:len() + 1)
		else -- if object is text
			local str = "Text with tags"
			buf:PushString(str, str:len() + 1)
		end
	elseif byType == 3 then -- update state and delay of particular object
		buf:PushUInt32(dwObjectIndex) -- object index to update
		buf:PushUInt32(tonumber("1111", 2)) -- state flags: see manual
		buf:PushUInt32(0) -- delay remain in seconds
		buf:PushUInt32(0) -- delay total in seconds
		buf:PushUInt32(0) -- counter on icon
		buf:PushUInt32(0) -- counter 2 on icon
	else
		return
	end

	buf:SendBuffer(pPlayer, 80, 14)
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
	buf:SendBuffer(pPlayer, 80, 15)
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
---@field name table<string, sirin_ToolTipName>
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

return sirinCustomWindows
