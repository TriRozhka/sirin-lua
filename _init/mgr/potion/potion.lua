---@class (exact) PotionManager
---@field __index table
---@field pszModPotionEffectLogPath string
---@field handlers table<integer, fun(pActChar: CCharacter, pTargetChar: CCharacter, effect: number|table): boolean, integer>
---@field registered table<integer, integer>
local PotionManager = {
	pszModPotionEffectLogPath = '.\\sirin-log\\guard\\ModPotionEffect.log',
	handlers = {
		---1. Add cash handler
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param fEffectValue number
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, fEffectValue)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			Sirin.mainThread.AddCash(Sirin.mainThread.objectToPlayer(pTargetChar), math.floor(fEffectValue))

			return true, 0
		end,
		---2. Add premium days
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param fEffectValue number
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, fEffectValue)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			if fEffectValue < 0 then
				return false, 2
			end

			Sirin.mainThread.AddPremDays(Sirin.mainThread.objectToPlayer(pTargetChar), math.floor(fEffectValue))

			return true, 0
		end,
		---3. Add premium seconds
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param fEffectValue number
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, fEffectValue)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			if fEffectValue < 0 then
				return false, 2
			end

			Sirin.mainThread.AddPremSeconds(Sirin.mainThread.objectToPlayer(pTargetChar), math.floor(fEffectValue))

			return true, 0
		end,
		---4. Summon monster
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param effect MonCreatePotionParam
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, effect)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			if pTargetChar:IsInTown() and not effect[2] then
				return false, 3
			end

			local pMonFld = Sirin.mainThread.baseToMonsterCharacter(Sirin.mainThread.g_Main.m_tblMonster:GetRecord(effect[1]))

			if not pMonFld then
				return false, 5
			end

			local pMon = Sirin.mainThread.createMonster(pTargetChar.m_pCurMap, pTargetChar.m_wMapLayerIndex, pTargetChar.m_fCurPos_x, pTargetChar.m_fCurPos_y, pTargetChar.m_fCurPos_z, effect[1], effect[3] and pMonFld.m_bExpDown > 0 or effect[4], effect[5], true)

			if not pMon then
				return false, 6
			end

			return true, 0
		end,
		---5. Alter CPT point
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param fEffectValue number
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, fEffectValue)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			PlayerMgr.alterPVP(Sirin.mainThread.objectToPlayer(pTargetChar), fEffectValue)

			return true, 0
		end,
		---6. Alter PvP Cash point
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param fEffectValue number
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, fEffectValue)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			local pPlayer = Sirin.mainThread.objectToPlayer(pTargetChar)

			if pPlayer:GetLevel() < 40 or pPlayer.m_Param.m_pClassData.m_nGrade < 1 then
				return false, 2
			end

			PlayerMgr.alterPVPCash(pPlayer, fEffectValue)

			return true, 0
		end,
		---7. Alter dalant
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param fEffectValue number
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, fEffectValue)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			PlayerMgr.alterDalant(Sirin.mainThread.objectToPlayer(pTargetChar), fEffectValue)

			return true, 0
		end,
		---8. Alter gold
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param fEffectValue number
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, fEffectValue)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			PlayerMgr.alterGold(Sirin.mainThread.objectToPlayer(pTargetChar), fEffectValue)

			return true, 0
		end,
		---9. Add level
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param effect AddLevelPotionParam
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, effect)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			if not PlayerMgr.alterLevel(Sirin.mainThread.objectToPlayer(pTargetChar), effect[1], effect[2]) then
				return false, 2
			end

			return true, 0
		end,
		---10. Set level
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param effect SetLevelPotionParam
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, effect)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			if not PlayerMgr.setLevel(Sirin.mainThread.objectToPlayer(pTargetChar), effect[1], effect[2], effect[3]) then
				return false, 2
			end

			return true, 0
		end,
		---11. Apply Skill effect
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param effect ApplyEffectPotionParam
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, effect)
			if pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			local bSucc, err, upMty = CharacterMgr.assistSkill(pActChar, pTargetChar, EFF_CODE.skill, Sirin.mainThread.baseToSkill(effect[1]), effect[3], effect[2], effect[4])

			return bSucc, err
		end,
		---12. Apply Force effect
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param effect ApplyEffectPotionParam
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, effect)
			if pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			local bSucc, err, upMty = CharacterMgr.assistForce(pActChar, pTargetChar, Sirin.mainThread.baseToForce(effect[1]), effect[3], effect[2], effect[4])

			return bSucc, err
		end,
		---13. Apply Class Skill effect
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param effect ApplyEffectPotionParam
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, effect)
			if pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			local bSucc, err, upMty = CharacterMgr.assistSkill(pActChar, pTargetChar, EFF_CODE.class, Sirin.mainThread.baseToSkill(effect[1]), effect[3], effect[2], effect[4])

			return bSucc, err
		end,
		---14. Apply Bullet effect
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param effect ApplyEffectPotionParam
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, effect)
			if pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			local bSucc, err, upMty = CharacterMgr.assistSkill(pActChar, pTargetChar, EFF_CODE.bullet, Sirin.mainThread.baseToSkill(effect[1]), effect[3], effect[2], effect[4])

			return bSucc, err
		end,
		---15. Alter PT
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param effect AlterPTPotionParam
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, effect)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			if not PlayerMgr.alterPT(Sirin.mainThread.objectToPlayer(pTargetChar), effect[1], effect[2]) then
				return false, 2
			end

			return true, 0
		end,
		---16. Alter mastery Skill
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param effect AlterSkillMasteryPotionParam
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, effect)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			if not PlayerMgr.alterSkillMastery(Sirin.mainThread.objectToPlayer(pTargetChar), effect[1], effect[2]) then
				return false, 2
			end

			return true, 0
		end,
		---17. Alter mastery Force
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param effect AlterForceMasteryPotionParam
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, effect)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			if not PlayerMgr.alterForceMastery(Sirin.mainThread.objectToPlayer(pTargetChar), effect[1], effect[2]) then
				return false, 2
			end

			return true, 0
		end,
		---18. Alter action point
		---@param pActChar CCharacter
		---@param pTargetChar CCharacter
		---@param effect AlterActionPointPotionParam
		---@return boolean
		---@return integer
		function (pActChar, pTargetChar, effect)
			if pTargetChar.m_ObjID.m_byID > 0 or pTargetChar.m_ObjID.m_byKind > 0 then
				return false, 1
			end

			if not PlayerMgr.alterActionPoint(Sirin.mainThread.objectToPlayer(pTargetChar), effect[2], effect[1]) then
				return false, 2
			end

			return true, 0
		end,
	},
	registered = {},
}

---@return PotionManager self
function PotionManager:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

---@enum POTION_EFF
POTION_EFF = {
	add_cash = 1,
	add_prem_days = 2,
	add_prem_sec = 3,
	monster_call = 4,
	alter_cpt = 5,
	alter_pvp_cash = 6,
	alter_dalant = 7,
	alter_gold = 8,
	alter_level = 9,
	set_level = 10,
	apply_skill = 11,
	apply_force = 12,
	apply_cskill = 13,
	apply_bullet = 14,
	alter_pt = 15,
	alter_mastery_skill = 16,
	alter_mastery_force = 17,
	alter_action_point = 18,
}

PotionMgr = PotionManager:new()

function PotionManager:uninit()
	for _,v in ipairs(self.registered) do
		Sirin.mainThread.modPotionEffect.removeHandler(v)
	end
end

---@return boolean
function PotionManager:loadScripts()
	local bSucc = true

	repeat
		TmpPotionEffect = FileLoader.LoadChunkedTable(".\\sirin-lua\\PotionEffect")

		if not TmpPotionEffect then
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, "Failed to load 'PotionEffect' scripts!\n")
			Sirin.WriteA(self.pszModPotionEffectLogPath, "Failed to load 'PotionEffect' scripts!\n", true, true)
			bSucc = false
			break
		end

		local newScriptData = {}

		for k,v in pairs(TmpPotionEffect) do
			repeat
				local pFld = Sirin.mainThread.g_Main:m_tblItemData_get(TBL_CODE.potion):GetRecordByHash(k, 2, 5)

				if not pFld then
					local fmt = string.format("Potion record:%s invalid potion code!\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
					bSucc = false
					break
				end

				if type(v) == "function" then
					newScriptData[pFld.m_dwIndex] = v
					do break end
				elseif type(v) == "table" then
					if type(v[1]) ~= "number" then
						local fmt = string.format("Potion record:%s[1] invalid type! Number expected.\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
						bSucc = false
						break
					end

					if v[1] < 1 or v[1]> #self.handlers then
						local fmt = string.format("Potion record:%s[1] out of range!\n", k)
						Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
						Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
						bSucc = false
						break
					end

					if v[1] == 4 then
						if type(v[2]) ~= "table" then
							local fmt = string.format("Potion record:%s[2] invalid type! Table expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][1]) ~= "string" then
							local fmt = string.format("Potion record:%s[2][1] invalid type! String expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						for i = 2, 5 do
							if type(v[2][i]) ~= "boolean" then
								local fmt = string.format("Potion record:%s[2][%d] invalid type! Boolean expected.\n", k, i)
								Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
								Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
								bSucc = false
								break
							end
						end

						if not bSucc then
							break
						end

						if not Sirin.mainThread.g_Main.m_tblMonster:GetRecord(v[2][1]) then
							local fmt = string.format("Potion record:%s[2] invalid monster code: (%s)!\n", k, v[2][1])
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end
					elseif v[1] <= 8 then
						if type(v[2]) ~= "number" then
							local fmt = string.format("Potion record:%s[2] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end
					elseif v[1] == 9 then
						if type(v[2]) ~= "table" then
							local fmt = string.format("Potion record:%s[2] invalid type! Table expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][1]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][1] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][2]) ~= "boolean" then
							local fmt = string.format("Potion record:%s[2][2] invalid type! Boolean expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end
					elseif v[1] == 10 then
						if type(v[2]) ~= "table" then
							local fmt = string.format("Potion record:%s[2] invalid type! Table expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][1]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][1] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][2]) ~= "boolean" then
							local fmt = string.format("Potion record:%s[2][2] invalid type! Boolean expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][3]) ~= "boolean" then
							local fmt = string.format("Potion record:%s[2][3] invalid type! Boolean expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end
					elseif v[1] <= 14 then
						if type(v[2]) ~= "table" then
							local fmt = string.format("Potion record:%s[2] invalid type! Table expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][1]) ~= "string" then
							local fmt = string.format("Potion record:%s[2][1] invalid type! String expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][2]) ~= "boolean" then
							local fmt = string.format("Potion record:%s[2][2] invalid type! Boolean expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][3]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][3] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if v[2][4] and type(v[2][4]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][4] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						local pEffFld = Sirin.mainThread.g_Main:m_tblEffectData_get(v[1] - 11):GetRecord(v[2][1])

						if not pEffFld then
							local fmt = string.format("Potion record:%s[2][1] invalid effect code: (%s)!\n", k, v[2][1])
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						v[2][1] = pEffFld

						if v[2][3] < 1 or v[2][3] > 7 then
							local fmt = string.format("Potion record:%s[2][3] out of range!\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end
					elseif v[1] == 15 then
						if type(v[2]) ~= "table" then
							local fmt = string.format("Potion record:%s[2] invalid type! Table expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][1]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][1] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][2]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][2] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if v[2][1] < 1 or v[2][1] > 8 then
							local fmt = string.format("Potion record:%s[2][1] out of range!\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end
					elseif v[1] == 16 then
						if type(v[2]) ~= "table" then
							local fmt = string.format("Potion record:%s[2] invalid type! Table expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][1]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][1] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][2]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][2] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if v[2][1] < 0 or v[2][1] > 47 then
							local fmt = string.format("Potion record:%s[2][1] out of range!\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end
					elseif v[1] == 17 then
						if type(v[2]) ~= "table" then
							local fmt = string.format("Potion record:%s[2] invalid type! Table expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][1]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][1] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][2]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][2] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if v[2][1] < 1 or v[2][1] > 23 then
							local fmt = string.format("Potion record:%s[2][1] out of range!\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end
					elseif v[1] == 18 then
						if type(v[2]) ~= "table" then
							local fmt = string.format("Potion record:%s[2] invalid type! Table expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][1]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][1] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if type(v[2][2]) ~= "number" then
							local fmt = string.format("Potion record:%s[2][2] invalid type! Number expected.\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end

						if v[2][1] < 0 or v[2][1] > 2 then
							local fmt = string.format("Potion record:%s[2][1] out of range!\n", k)
							Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
							Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
							bSucc = false
							break
						end
					end
				else
					local fmt = string.format("Potion record:%s invalid type! Function or table expected.\n", k)
					Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
					Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
					bSucc = false
					break
				end

				newScriptData[pFld.m_dwIndex] = v
			until true
		end

		if bSucc then
			ScriptPotionEffect = newScriptData
			TmpPotionEffect = nil

			self:uninit()
			self.registered = {}

			for k,v in pairs(ScriptPotionEffect) do
				Sirin.mainThread.modPotionEffect.addHandler(k)
				table.insert(self.registered, k)
			end
		else
			local fmt = "PotionManager:loadScripts: bSucc == false!\n"
			Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
			Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
		end

	until true

	return bSucc
end

---@param pActChar CCharacter
---@param pTargetChar CCharacter
---@param fEffectValue number
---@return boolean bSucc
---@return integer byRet
function PotionManager:DefaultHandler(pActChar, pTargetChar, fEffectValue)
	local byRet = 0
	local bSucc = false

	repeat
		if not ScriptPotionEffect then
			byRet = 100
			break
		end

		local effect = ScriptPotionEffect[math.floor(fEffectValue)]

		if not effect then
			byRet = 101
			break
		end

		if type(effect) == "function" then
			local status, err = pcall(effect, pActChar, pTargetChar)

			if not status then
				local fmt = string.format("PotionManager:DefaultHandler(): potion:%d Handler call failed! \n%s\n", math.floor(fEffectValue), err)
				Sirin.console.LogEx_NoFile(ConsoleForeground.RED, ConsoleBackground.BLACK, fmt)
				Sirin.WriteA(self.pszModPotionEffectLogPath, fmt, true, true)
				byRet = 102
				break
			end

			if err > 0 then
				byRet = err
				break
			end

			bSucc = true
		else
			local effID = effect[1]

			if effID < POTION_EFF.add_cash or effID > POTION_EFF.alter_action_point then
				byRet = 102
				break
			end

			bSucc, byRet = self.handlers[effID](pActChar, pTargetChar, effect[2])
		end
	until true

	return bSucc, byRet
end

---@class MonCreatePotionParam
---@field [1] string Monster code
---@field [2] boolean Allow summon in town
---@field [3] boolean User m_bRobExp from script (if killed my monster can loose exp)
---@field [4] boolean Rob exp (if killed my monster can loose exp)
---@field [5] boolean Reward exp (allow gain exp from this monster)
local MonCreatePotionParam = {}

---@class AddLevelPotionParam
---@field [1] integer Value to add
---@field [2] boolean Break level cap
local AddLevelPotionParam = {}

---@class SetLevelPotionParam
---@field [1] integer Value to add
---@field [2] boolean Break level cap
---@field [3] boolean Allow de-level
local SetLevelPotionParam = {}

---@class ApplyEffectPotionParam
---@field [1] _base_fld Effect pointer
---@field [2] boolean Allow override existing effect
---@field [3] integer Effect level
---@field [4] integer|nil Custom duration
local ApplyEffectPotionParam = {}

---@class AlterPTPotionParam
---@field [1] integer PT index
---@field [2] integer Delta value
local AlterPTPotionParam = {}

---@class AlterSkillMasteryPotionParam
---@field [1] integer Skill mastery index
---@field [2] integer Delta value
local AlterSkillMasteryPotionParam = {}

---@class AlterForceMasteryPotionParam
---@field [1] integer Force mastery index
---@field [2] integer Delta value
local AlterForceMasteryPotionParam = {}

---@class AlterActionPointPotionParam
---@field [1] ACT_P_TYPE Point type
---@field [2] integer Delta value
local AlterActionPointPotionParam = {}
