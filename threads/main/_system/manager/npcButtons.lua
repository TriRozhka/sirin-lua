---@class (exact) invenList
---@field pCon _STORAGE_LIST___db_con
---@field nAlter integer
local invenList = {}

---@class (exact) sirinCustomNpcButtons
---@field m_pszModButtonExtLogPath string
---@field loadScripts fun(): boolean
---@field canUseBuff fun(pPlayer: CPlayer, buffData: table): integer, table<integer, invenList>, table<integer, invenList>
---@field useBuffButton fun(pPlayer: CPlayer, dwButtonID: integer, dwBuffIndex: integer): integer
local sirinCustomNpcButtons = {
	m_pszModButtonExtLogPath = '.\\sirin-log\\guard\\ModButtonExt.log',
}

---@return boolean
function sirinCustomNpcButtons.loadScripts()
	local bSucc = true

	repeat
		SirinTmp_CustomNPCButtons = FileLoader.LoadChunkedTable(".\\sirin-lua\\threads\\main\\ReloadableScripts\\NPCButtons")

		if not SirinTmp_CustomNPCButtons then
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Failed to load 'NPCButtons' scripts!\n")
			Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, "Failed to load 'NPCButtons' scripts!\n", true, true)
			bSucc = false
			break
		end

		for k,v in pairs(SirinTmp_CustomNPCButtons) do
			repeat
				if type(v["actionType"]) ~= "number" then
					local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d 'actionType' invalid format! Number expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
					bSucc = false
					break
				end

				if v["actionType"] > BTN_TYPE.buff then
					local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d 'actionType' out of range!\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
					bSucc = false
					break
				end

				if type(v["clientName"]) ~= "table" then
					local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d 'clientName' invalid format! Table expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
					bSucc = false
					break
				end

				if v["color"] and type(v["color"]) ~= "number" then
					local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d 'color' invalid format! Number or nil expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
					bSucc = false
					break
				end

				if v["actionType"] == BTN_TYPE.func then
					if type(v["data"]) ~= "function" then
						local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d 'data' invalid format! Function expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
						bSucc = false
						break
					end
				elseif v["actionType"] == BTN_TYPE.exchange then
					if type(v["data"]) ~= "number" then
						local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d 'data' invalid format! Number expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
						bSucc = false
						break
					end

					local pFld = Sirin.mainThread.g_Main.m_tblItemCombineData:GetRecord(v["data"])

					if not pFld then
						local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d 'data' invalid combine index!\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
						bSucc = false
						break
					end
				elseif v["actionType"] == BTN_TYPE.buff then
					if type(v["data"]) ~= "table" then
						local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d 'data' invalid format! Table expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
						bSucc = false
						break
					end

					for bk,bv in ipairs(v["data"]) do
						repeat
							if type(bv["skillType"]) ~= "number" then
								local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d] 'skillType' invalid format! Number expected.\n", k, bk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if bv["skillType"] > EFF_CODE.bullet then
								local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d] 'skillType' out of range!\n", k, bk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if type(bv["id"]) ~= "string" then
								local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d] 'id' invalid format! Number expected.\n", k, bk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
								bSucc = false
								break
							end

							bv["pBaseFld"] = Sirin.mainThread.g_Main:m_tblEffectData_get(bv["skillType"]):GetRecord(bv["id"])

							if not bv["pBaseFld"] then
								local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d] 'id' invalid code: %s!\n", k, bk, bv["id"])
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if type(bv["overrideExisting"]) ~= "nil" and type(bv["overrideExisting"]) ~= "boolean" then
								local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d] 'overrideExisting' invalid format! Boolean expected.\n", k, bk)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
								bSucc = false
								break
							end

							if bv["handler"] then
								if type(bv["handler"]) ~= "function" then
									local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d] 'handler' invalid format! Function expected.\n", k, bk)
									Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
									Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
									bSucc = false
									break
								else
									bv["lv"] = 0
								end
							else
								if type(bv["lv"]) ~= "number" then
									local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d] 'lv' invalid format! Number expected.\n", k, bk)
									Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
									Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
									bSucc = false
									break
								end

								if bv["lv"] < 1 or bv["lv"] > 7 then
									local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d] 'lv' out of range!\n", k, bk)
									Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
									Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
									bSucc = false
									break
								end
							end

							if bv["durSec"] then
								if type(bv["durSec"]) ~= "number" then
									local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d] 'durSec' invalid format! Number expected.\n", k, bk)
									Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
									Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
									bSucc = false
									break
								end
							end

							bv["durSec"] = bv["durSec"] or 0

							if bv["description"] then
								if type(bv["description"]) ~= "table" then
									local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d] 'description' invalid format! Table expected.\n", k, bk)
									Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
									Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
									bSucc = false
									break
								end
							end

							if bv["conditions"] then
								local conditions = bv["conditions"]

								if type(conditions) ~= "table" then
									local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d] 'conditions' invalid format! Table expected.\n", k, bk)
									Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
									Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
									bSucc = false
									break
								end

								if type(conditions["premiumUser"]) ~= "nil" and type(conditions["premiumUser"]) ~= "boolean" then
									local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions] 'premiumUser' invalid format! Boolean expected.\n", k, bk)
									Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
									Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
									bSucc = false
									break
								end

								if conditions["minLevel"] then
									if type(conditions["minLevel"]) ~= "number" then
										local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions] 'minLevel' invalid format! Number expected.\n", k, bk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
										bSucc = false
										break
									end
								end

								if conditions["maxLevel"] then
									if type(conditions["maxLevel"]) ~= "number" then
										local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions] 'maxLevel' invalid format! Number expected.\n", k, bk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
										bSucc = false
										break
									end
								end

								if conditions["rank"] then
									if type(conditions["rank"]) ~= "number" then
										local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions] 'rank' invalid format! Number expected.\n", k, bk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
										bSucc = false
										break
									end

									if conditions["rank"] < 0 or conditions["rank"] > 7 then
										local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions] 'rank' out of range!\n", k, bk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
										bSucc = false
										break
									end
								end

								if conditions["item"] then
									if type(conditions["item"]) ~= "table" then
										local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions] 'item' invalid format! Table expected.\n", k, bk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
										bSucc = false
										break
									end

									for ck,cv in ipairs(conditions["item"]) do
										repeat
											if type(cv["code"]) ~= "string" then
												local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][item][%d] 'code' invalid format! String expected.\n", k, bk, ck)
												Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
												Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
												bSucc = false
												break
											end

											cv["tableCode"] = Sirin.mainThread.GetItemTableCode(cv["code"])

											if cv["tableCode"] == -1 then
												local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][item][%d] 'code' invalid item type: %s!\n", k, bk, ck, cv["code"])
												Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
												Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
												bSucc = false
												break
											end

											cv["pBaseFld"] = Sirin.mainThread.g_Main:m_tblItemData_get(cv["tableCode"]):GetRecord(cv["code"])

											if not cv["pBaseFld"] then
												local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][item][%d] 'code' invalid item: %s!\n", k, bk, ck, cv["code"])
												Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
												Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
												bSucc = false
												break
											end

											cv["tableIndex"] = cv["pBaseFld"].m_dwIndex

											if type(cv["consumeNum"]) ~= "number" then
												local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][item][%d] 'consumeNum' invalid format! Number expected.\n", k, bk, ck)
												Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
												Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
												bSucc = false
												break
											end
										until true
									end

									if not bSucc then
										break
									end
								end

								if conditions["money"] then
									if type(conditions["money"]) ~= "table" then
										local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions] 'money' invalid format! Table expected.\n", k, bk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
										bSucc = false
										break
									end

									if type(conditions["money"]["currency"]) ~= "number" then
										local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions][money] 'currency' invalid format! Number expected.\n", k, bk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
										bSucc = false
										break
									end

									if conditions["money"]["currency"] < 0 or conditions["money"]["currency"] > 6 then
										local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions][money] 'currency' invalid format! out of range!\n", k, bk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
										bSucc = false
										break
									end

									if type(conditions["money"]["value"]) ~= "number" then
										local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions][money] 'value' invalid format! Number expected.\n", k, bk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
										bSucc = false
										break
									end
								end

								if conditions["raceLimit"] then
									if type(conditions["raceLimit"]) ~= "table" then
										local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions] 'raceLimit' invalid format! Table expected.\n", k, bk)
										Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
										Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
										bSucc = false
										break
									end

									for rk,rv in ipairs(conditions["raceLimit"]) do
										if rv < 0 or rv > 2 then
											local fmt = string.format("Lua. sirinCustomNpcButtons.loadScripts() Button record:%d[%d][conditions][raceLimit][%d] out of range!\n", k, bk, rk)
											Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
											Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
											bSucc = false
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
						break
					end
				end
			until true
		end

		if bSucc then
			SirinScript_CustomNPCButtons = SirinTmp_CustomNPCButtons
			SirinTmp_CustomNPCButtons = nil
			Sirin.mainThread.modButtonExt.RegisterButtons()
			Sirin.mainThread.modButtonExt.RegisterAsset()

			if Sirin.CAssetController.instance():makeAssetData("sirin.asset.npc_buttons") then
				Sirin.CAssetController.instance():sendAssetData("sirin.asset.npc_buttons")
			else
				local fmt = "CustomNpcButtons:loadScripts: makeAssetData() == false!\n"
				Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
				Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
			end
		else
			local fmt = "CustomNpcButtons:loadScripts: bSucc == false!\n"
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
			Sirin.WriteA(sirinCustomNpcButtons.m_pszModButtonExtLogPath, fmt, true, true)
		end

	until true

	return bSucc
end

---@param pPlayer CPlayer
---@param buffData table
---@return integer nErrCode
---@return table<integer, invenList> alterList
---@return table<integer, invenList> deleteList
function sirinCustomNpcButtons.canUseBuff(pPlayer, buffData)
	local nErrCode = 0
	---@type table<integer, invenList>
	local alterList = {}
	---@type table<integer, invenList>
	local deleteList = {}

	repeat
		if buffData["conditions"] then
			local buffCond = buffData["conditions"]

			if buffCond.raceLimit and #buffCond.raceLimit > 0 then
				local byRace = pPlayer:GetObjRace()
				local anyOf = false

				for _,v in ipairs(buffCond.raceLimit) do
					if byRace == v then
						anyOf = true
						break
					end
				end

				if not anyOf then
					nErrCode = -14
					break
				end
			else
				local byRaceSex = pPlayer.m_Param.m_dbChar.m_byRaceSexCode + 1
				local strUseRace = ""

				if buffData["skillType"] == EFF_CODE.force then
					local pFld = Sirin.mainThread.baseToForce(buffData["pBaseFld"])
					strUseRace = pFld.m_strUsableRace
				else
					local pFld = Sirin.mainThread.baseToSkill(buffData["pBaseFld"])
					strUseRace = pFld.m_strUsableRace
				end

				if strUseRace:sub(byRaceSex, byRaceSex) ~= '1' then
					nErrCode = -14
					break
				end
			end

			if buffCond["premiumUser"] and not pPlayer:IsApplyPcbangPrimium() then
				nErrCode = -3
				break
			end

			if buffCond["minLevel"] and pPlayer:GetLevel() < buffCond["minLevel"] then
				nErrCode = -4
				break
			end

			if buffCond["maxLevel"] and pPlayer:GetLevel() > buffCond["maxLevel"] then
				nErrCode = -4
				break
			end

			if buffCond["rank"] and pPlayer.m_Param.m_byPvPGrade < buffCond["rank"] then
				nErrCode = -5
				break
			end

			if type(buffCond["item"]) == 'table' and #buffCond["item"] > 0 then
				local consumeList = {}

				for _,v in ipairs(buffCond["item"]) do
					local _itemConsume = {}
					_itemConsume.m_byTableCode = v.tableCode
					_itemConsume.m_wItemIndex = v.tableIndex
					_itemConsume.m_qwQuantity = v.consumeNum or 0
					table.insert(consumeList, _itemConsume)
				end

				---@type table<integer, _STORAGE_LIST___db_con>
				local Inven = {}

				for j = 0, pPlayer.m_Param.m_dbInven.m_nUsedNum - 1 do
					local pCon = pPlayer.m_Param.m_dbInven:m_List_get(j)

					if pCon.m_byLoad == 1 and not pCon.m_bLock then
						table.insert(Inven, pCon)
					end
				end

				table.sort(Inven, function(a, b) return a.m_byClientIndex < b.m_byClientIndex end)

				for _,item in pairs(Inven) do
					for k,consume in pairs(consumeList) do
						if item.m_byTableCode == consume.m_byTableCode and item.m_wItemIndex == consume.m_wItemIndex then
							if consume.m_qwQuantity > 0 then
								if Sirin.mainThread.IsOverLapItem(consume.m_byTableCode) then
									if item.m_dwDur > consume.m_qwQuantity then
										table.insert(alterList, { pCon = item, nAlter = -consume.m_qwQuantity })
										consume.m_qwQuantity = 0
									else
										table.insert(deleteList, { pCon = item, nAlter = 0 })
										consume.m_qwQuantity = consume.m_qwQuantity - item.m_dwDur
									end
								else
									table.insert(deleteList, { pCon = item, nAlter = 0 })
									consume.m_qwQuantity = consume.m_qwQuantity - 1
								end
							end

							if consume.m_qwQuantity == 0 then
								consumeList[k] = nil
							end
						end
					end
				end

				for _,v in pairs(consumeList) do
					nErrCode = -6
					break
				end

				if nErrCode ~= 0 then
					break
				end
			end

			if buffCond["money"] then
				local value = buffCond["money"]["value"]
				local currency = buffCond["money"]["currency"]

				if currency == 0 then
					if value > pPlayer.m_Param:GetDalant() then
						nErrCode = -7
						break
					end
				elseif currency == 1 then
					if value > pPlayer.m_Param:GetGold() then
						nErrCode = -8
						break
					end
				elseif currency == 2 then
					if pPlayer:GetLevel() < 40 or pPlayer.m_Param.m_pClassData.m_nGrade < 1 then
						nErrCode = -9
						break
					end

					if value > pPlayer.m_kPvpOrderView:GetPvpCash() then
						nErrCode = -9
						break
					end
				elseif currency == 3 then
					if value > pPlayer.m_Param:GetPvPPoint() then
						nErrCode = -10
						break
					end
				elseif currency == 4 then
					if value > pPlayer.m_pUserDB:GetActPoint(0) then
						nErrCode = -11
						break
					end
				elseif currency == 5 then
					if value > pPlayer.m_pUserDB:GetActPoint(1) then
						nErrCode = -12
						break
					end
				elseif currency == 6 then
					if value > pPlayer.m_pUserDB:GetActPoint(2) then
						nErrCode = -13
						break
					end
				end
			end
		end
	until true

	return nErrCode, alterList, deleteList
end

---@param pPlayer CPlayer
---@param dwButtonID integer
---@param dwBuffIndex integer
---@return integer nErrCode
function sirinCustomNpcButtons.useBuffButton(pPlayer, dwButtonID, dwBuffIndex)
	local nErrCode = 0

	repeat
		local button = SirinScript_CustomNPCButtons[dwButtonID]

		if not button then
			nErrCode = -1
			break
		end

		if not Sirin.mainThread.modButtonExt.IsBeNearButton(pPlayer, dwButtonID) then
			nErrCode = -2
			break
		end

		if dwBuffIndex == 0 then
			local resultList = {}

			for _, v in ipairs(button["data"]) do
				local byRet = sirinCustomNpcButtons.canUseBuff(pPlayer, v)
				table.insert(resultList, byRet)
			end

			local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
			buf:Init()
			buf:PushInt32(0)
			buf:PushUInt32(#resultList)

			for _,v in ipairs(resultList) do
				if v == -14 then
					buf:PushInt8(0)
				elseif v ~= 0 then
					buf:PushInt8(1)
				else
					buf:PushInt8(3)
				end
			end

			buf:SendBuffer(pPlayer, 80, 5)
		else
			local buffData = button["data"][dwBuffIndex]

			if not buffData then
				nErrCode = -1
				break
			end

			local byRet, alterList, deleteList = sirinCustomNpcButtons.canUseBuff(pPlayer, buffData)

			if byRet ~= 0 then
				nErrCode = byRet
				break
			end

			if buffData["handler"] then
                nErrCode = buffData["handler"](pPlayer)
                break
            end

			local bApplyResult = false

			if buffData["skillType"] == EFF_CODE.skill then
				local res, err, mty = CharacterMgr.assistSkill(pPlayer, pPlayer, EFF_CODE.skill, Sirin.mainThread.baseToSkill(buffData["pBaseFld"]), buffData["lv"], buffData["overrideExisting"], buffData["durSec"])
				bApplyResult = res
				nErrCode = err
			elseif buffData["skillType"] == EFF_CODE.force then
				local res, err, mty = CharacterMgr.assistForce(pPlayer, pPlayer, Sirin.mainThread.baseToForce(buffData["pBaseFld"]), buffData["lv"], buffData["overrideExisting"], buffData["durSec"])
				bApplyResult = res
				nErrCode = err
			elseif buffData["skillType"] == EFF_CODE.class then
				local res, err, mty = CharacterMgr.assistSkill(pPlayer, pPlayer, EFF_CODE.class, Sirin.mainThread.baseToSkill(buffData["pBaseFld"]), buffData["lv"], buffData["overrideExisting"], buffData["durSec"])
				bApplyResult = res
				nErrCode = err
			elseif buffData["skillType"] == EFF_CODE.bullet then
				local res, err, mty = CharacterMgr.assistSkill(pPlayer, pPlayer, EFF_CODE.bullet, Sirin.mainThread.baseToSkill(buffData["pBaseFld"]), buffData["lv"], buffData["overrideExisting"], buffData["durSec"])
				bApplyResult = res
				nErrCode = err
			end

			if bApplyResult then
				for _,alter in pairs(alterList) do
					local wSerial = alter.pCon.m_wSerial
					local Left = pPlayer:Emb_AlterDurPoint(STORAGE_POS.inven, alter.pCon.m_byStorageIndex, alter.nAlter, false, false)
					pPlayer:SendMsg_AdjustAmountInform(STORAGE_POS.inven, wSerial, Left)
				end

				for _,del in pairs(deleteList) do
					pPlayer:Emb_DelStorage(STORAGE_POS.inven, del.pCon.m_byStorageIndex, false, true, "Lua. CustomNpcButtons:useBuffButton(...)")
				end

				if buffData["conditions"] then
					if buffData["conditions"]["money"] then
						local value = buffData["conditions"]["money"]["value"]
						local currency = buffData["conditions"]["money"]["currency"]

						if currency == 0 then
							pPlayer:AlterDalant(-value)
							pPlayer:SendMsg_AlterMoneyInform(0)
						elseif currency == 1 then
							pPlayer:AlterGold(-value)
							pPlayer:SendMsg_AlterMoneyInform(0)
						elseif currency == 2 then
							pPlayer:AlterPvPCashBag(-value, PVP_MONEY_ALTER_TYPE.pm_shop)
						elseif currency == 3 then
							pPlayer:AlterPvPPoint(-value, PVP_ALTER_TYPE.logoff_dec, 0xFFFFFFFF)
						elseif currency == 4 then
							pPlayer:SubActPoint(0, value)
							pPlayer:SendMsg_Alter_Action_Point(0, pPlayer.m_pUserDB:GetActPoint(0))
						elseif currency == 5 then
							pPlayer:SubActPoint(0, value)
							pPlayer:SendMsg_Alter_Action_Point(1, pPlayer.m_pUserDB:GetActPoint(1))
						elseif currency == 6 then
							pPlayer:SubActPoint(0, value)
							pPlayer:SendMsg_Alter_Action_Point(2, pPlayer.m_pUserDB:GetActPoint(2))
						end
					end
				end
			else
				if nErrCode > 0 then
					if nErrCode == 0xF3 then
						nErrCode = 13
					end

					nErrCode = nErrCode * -1 - 5
				end
			end
		end
	until true

	return nErrCode
end

return sirinCustomNpcButtons
