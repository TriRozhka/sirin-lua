---@param nTableCode integer
---@return integer
function GetItemKindCode(nTableCode)
	if nTableCode == 19 then
		return 2
	elseif nTableCode == 24 then
		return 1
	end

	return 0
end

---@param dwLvBit integer
---@return integer
function GetItemUpgedLv(dwLvBit)
	local byTalikNum = 0
	local bySlotNum = dwLvBit >> 28

	if bySlotNum > 7 and bySlotNum ~= 15 then
		bySlotNum = 7
	elseif bySlotNum == 15 then
		bySlotNum = 0
	end

	if bySlotNum > 0 then
		for i = 1, bySlotNum do
			if dwLvBit % 0x10 ~= 0xF then
				byTalikNum = byTalikNum + 1
			else
				break
			end

			dwLvBit = dwLvBit >> 4
		end
	end

	return byTalikNum > bySlotNum and bySlotNum or byTalikNum
end

---@param dwLvBit integer
---@param index integer
---@return integer
function GetTalikFromSocket(dwLvBit, index)
	if dwLvBit == 0 then
		return 15
	end

	return (dwLvBit >> (index * 4)) & 0xF
end

---@param nTableCode integer
---@return boolean
function IsOverlapItem(nTableCode)
	return nTableCode == 13
	or nTableCode == 17
	or nTableCode == 18
	or nTableCode == 20
	or nTableCode == 22
	or nTableCode == 31
	or nTableCode == 23
	or nTableCode == 30
	or nTableCode == 26
	or nTableCode == 32
	or nTableCode == 34
	or nTableCode == 35
end

---@param strName string
---@return CPlayer?
function FindPlayerByName(strName)
	local len = string.len(strName)

	for i = 0, 2531 do
		local pPlayer = Sirin.mainThread.g_Player_get(i)

		if pPlayer.m_bLive and pPlayer.m_Param.m_byNameLen == len then
			local name = pPlayer.m_Param.m_dbChar.m_wszCharID

			if name == strName then
				return pPlayer
			end
		end
	end

  	return nil
end

function GetSqrt(ax, az, bx, bz)
	return math.sqrt((ax - bx) ^ 2 + (az - bz) ^ 2)
end

function Get3DSqrt(ax, ay, az, bx, by, bz)
	return math.sqrt((ax - bx) ^ 2 + (ay - by) ^ 2 + (az - bz) ^ 2)
end

---@param a CGameObject
---@param b CGameObject
---@return boolean
function IsSameObject(a, b)
	return a.m_ObjID.m_byKind == b.m_ObjID.m_byKind and
	a.m_ObjID.m_byID == b.m_ObjID.m_byID and
	a.m_ObjID.m_wIndex == b.m_ObjID.m_wIndex
end

---@param dwSocket integer
---@return integer
function GetPlayerLanguage(dwSocket)
	return Sirin.CLanguageAsset.instance():getPlayerLanguage(dwSocket)
end

---@param dwSocket integer
---@return string
function GetPlayerLanguagePrefix(dwSocket)
	return Sirin.CLanguageAsset.instance():getPlayerLanguagePrefix(dwSocket)
end

---@param byCode integer
---@param byIndex integer
---@return boolean
function IsValidMasteryCode(byCode, byIndex)
	if byCode == 0 and byIndex > 1 then
		return false
	elseif (byCode == 1 or byCode == 2 or byCode == 6) and byIndex > 0 then
		return false
	elseif byCode == 3 and byIndex > 7 then
		return false
	elseif byCode == 4 and byIndex > 23 then
		return false
	elseif byCode == 5 and byIndex > 2 then
		return false
	elseif byCode > 6 or byCode < 0 then
		return false
	end

	return true
end

local weaponClassTable = {
	[0] = 0,
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
	[5] = 1,
	[6] = 1,
	[7] = 1,
	[8] = 1,
	[9] = 0,
	[10] = 0,
	[11] = 1,
}

---@param pWeaponFld _WeaponItem_fld
---@return integer
function GetWeaponClass(pWeaponFld)
	return weaponClassTable[pWeaponFld.m_nType] or 0
end

---@param nTempEffectType integer
---@return boolean
function IsUsableTempEffectAtStoneState(nTempEffectType)
	return (nTempEffectType >= 0 and (nTempEffectType == 5 or (nTempEffectType > 4 and (nTempEffectType <= 14 or nTempEffectType == 28))))
end

CONST_ChipBreakerBonus_Atk = 1.3
CONST_PatriarchBonus_Atk = 1.3
CONST_AttackCouncilBonus_Atk = 1.2
CONST_ChipBreakerBonus_Def = 1.3
CONST_PatriarchBonus_Def = 1.3
CONST_ArchonBonus_Def = 1.5
CONST_DefenseCouncilBonus_Def = 1.2

CONST_nLimitDist = { 42, 56, 70, 84 }
CONST_nLimitAngle = { { 180, 180, 180, 180 }, { 180, 180, 180, 180 }, { 180, 180, 180, 180 }, { 180, 180, 180, 180 } }
CONST_nLimitRadius = { 42, 56, 70, 84 }
CONST_s_fPartGravity = { 0.2, 0,23, 0.22, 0.18, 0.17 }
