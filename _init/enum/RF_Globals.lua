---@enum OBJ_KIND
OBJ_KIND = {
	char			= 0,
	item			= 1,
}

---@enum ID_CHAR
ID_CHAR = {
	player			= 0,
	monster			= 1,
	npc				= 2,
	animus			= 3,
	tower			= 4,
	holy_stone		= 5,
	holy_keeper		= 6,
	trap			= 7,
	gr_stone_regen	= 8,
	circle_zone		= 9,
	--unknown		= 10,
	amine_personal	= 11,
	nuclear_bomb	= 12,
}

---@enum ID_ITEM
ID_ITEM = {
	itembox			= 0,
	dungeon_gate	= 1,
	parking_unit	= 2,
	return_gate		= 3,
	gravity_stone	= 4,
}

---@enum TBL_CODE
TBL_CODE = {
	upper			= 0,
	lower			= 1,
	gauntlet		= 2,
	shoe			= 3,
	helmet			= 4,
	shield			= 5,
	weapon			= 6,
	cloak			= 7,
	ring			= 8,
	amulet			= 9,
	bullet			= 10,
	maketool		= 11,
	bag				= 12,
	potion			= 13,
	face			= 14,
	fcitem			= 15,
	battery			= 16,
	ore				= 17,
	res				= 18,
	key				= 19,
	booty			= 20,
	map				= 21,
	town			= 22,
	bdungeon		= 23,
	animus			= 24,
	tower			= 25,
	trap			= 26,
	siegekit		= 27,
	ticket			= 28,
	event			= 29,
	recovery		= 30,
	box				= 31,
	firecracker		= 32,
	umtool			= 33,
	radar			= 34,
	npclink			= 35,
	coupon			= 36,
}

---@enum MTY_CODE
MTY_CODE = {
	weapon		= 0,
	defence		= 1,
	shield		= 2,
	skill		= 3,
	force		= 4,
	make		= 5,
	special		= 6,
}

---@enum MAKE_ITEM
MAKE_ITEM = {
	shield		= 0,
	armor		= 1,
	bullet		= 2,
}

---@enum TOL_CODE
TOL_CODE = {
	fire			= 0,
	water			= 1,
	soil			= 2,
	wind			= 3,
	nothing			= 255,
}

---@enum STORAGE_POS
STORAGE_POS = {
	inven		= 0,
	equip		= 1,
	embellish	= 2,
	force		= 3,
	animus		= 4,
	trunk		= 5,
	amine		= 6,
	ext_trunk	= 7,
}

---@enum WPN_TYPE
WPN_TYPE = {
	knife			= 0,
	sword			= 1,
	axe				= 2,
	mace			= 3,
	spear			= 4,
	bow				= 5,
	firearm			= 6,
	luancher		= 7,
	throw			= 8,
	staff			= 9,
	mine			= 10,
	grelauncher		= 11,
}

---@enum WPN_LU_SUB
WPN_LU_SUB = {
	rocket		= 0,
	flame		= 1,
	faust		= 2,
}

---@enum ATK_RANGE
ATK_RANGE = {
	short			= 0,
	long			= 1,
}

---@enum WPN_CLASS
WPN_CLASS = {
	short = 0,
	long = 1,
}

---@enum EFF_CODE
EFF_CODE = {
	skill			= 0,
	force			= 1,
	class			= 2,
	bullet			= 3,
}

---@enum UNIT_PART
UNIT_PART = {
	head			= 0,
	upper			= 1,
	lower			= 2,
	arms			= 3,
	shoulder		= 4,
	back			= 5,
}

MAX_PLAYERS = 2532
PARTY_SIZE = 8

---@enum CHAT_TYPE
CHAT_TYPE = {
	Normal			= 0,
	Party			= 1,
	Guild			= 2,
	System			= 3,
	Race			= 4,
	PM				= 5,
	Transport		= 6,
	Map				= 7,
	ImportantAll	= 8,
	Scramble		= 9,
	PT				= 10,
	Whole			= 11,
	Monster			= 12,
	Trade			= 13,
}

---@enum ANN_TYPE
ANN_TYPE = {
	top				= 1 * 2 ^ 0, -- scroll sctring on top of the screen (no color)
	mid1			= 1 * 2 ^ 1, -- position where race shout appears usually. with color.
	mid2			= 1 * 2 ^ 2, -- position where yellow gm notice appears usually. with color.
	mid3			= 1 * 2 ^ 3, -- position where red system message appears usually. with color.
	char			= 1 * 2 ^ 4, -- position where pt/skill lvl up message appears usually. with color.
}

SKIN_MAGIC = 1313426259

---@enum STATE
STATE = {
	EMPTY = 0,
	REG_WAIT = 1,
	WAIT_CANCEL = 2,
	CANCEL_SUCC_COMPLETE = 3,
	CANCEL_FAIL_COMPLETE = 4,
}

---@enum PVP_ALTER_TYPE
PVP_ALTER_TYPE = {
	kill_s_inc = 0,
	kill_p_inc = 1,
	die_dec = 2,
	quest_inc = 3,
	holy_dec = 4,
	cheat = 5,
	logoff_inc = 6,
	guildbattle = 7,
	logoff_dec = 8,
	holy_award = 9,
}

---@enum PVP_MONEY_ALTER_TYPE
PVP_MONEY_ALTER_TYPE = {
	pm_kill = 0,
	pm_reward = 1,
	pm_scaner = 2,
	pm_shop = 3,
	pm_quest = 4,
}

FOREGROUND_BLUE      = 0x0001 -- text color contains blue.
FOREGROUND_GREEN     = 0x0002 -- text color contains green.
FOREGROUND_RED       = 0x0004 -- text color contains red.
FOREGROUND_INTENSITY = 0x0008 -- text color is intensified.
BACKGROUND_BLUE      = 0x0010 -- background color contains blue.
BACKGROUND_GREEN     = 0x0020 -- background color contains green.
BACKGROUND_RED       = 0x0040 -- background color contains red.
BACKGROUND_INTENSITY = 0x0080 -- background color is intensified.

---@enum ConsoleForeground
ConsoleForeground = {
	BLACK = 0,
	DARKBLUE = FOREGROUND_BLUE,
	DARKGREEN = FOREGROUND_GREEN,
	DARKCYAN = FOREGROUND_GREEN | FOREGROUND_BLUE,
	DARKRED = FOREGROUND_RED,
	DARKMAGENTA = FOREGROUND_RED | FOREGROUND_BLUE,
	DARKYELLOW = FOREGROUND_RED | FOREGROUND_GREEN,
	DARKGRAY = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE,
	GRAY = FOREGROUND_INTENSITY,
	BLUE = FOREGROUND_INTENSITY | FOREGROUND_BLUE,
	GREEN = FOREGROUND_INTENSITY | FOREGROUND_GREEN,
	CYAN = FOREGROUND_INTENSITY | FOREGROUND_GREEN | FOREGROUND_BLUE,
	RED = FOREGROUND_INTENSITY | FOREGROUND_RED,
	MAGENTA = FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_BLUE,
	YELLOW = FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN,
	WHITE = FOREGROUND_INTENSITY | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE,
}

---@enum ConsoleBackground
ConsoleBackground = {
	BLACK = 0,
	DARKBLUE = BACKGROUND_BLUE,
	DARKGREEN = BACKGROUND_GREEN,
	DARKCYAN = BACKGROUND_GREEN | BACKGROUND_BLUE,
	DARKRED = BACKGROUND_RED,
	DARKMAGENTA = BACKGROUND_RED | BACKGROUND_BLUE,
	DARKYELLOW = BACKGROUND_RED | BACKGROUND_GREEN,
	DARKGRAY = BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE,
	GRAY = BACKGROUND_INTENSITY,
	BLUE = BACKGROUND_INTENSITY | BACKGROUND_BLUE,
	GREEN = BACKGROUND_INTENSITY | BACKGROUND_GREEN,
	CYAN = BACKGROUND_INTENSITY | BACKGROUND_GREEN | BACKGROUND_BLUE,
	RED = BACKGROUND_INTENSITY | BACKGROUND_RED,
	MAGENTA = BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_BLUE,
	YELLOW = BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN,
	WHITE = BACKGROUND_INTENSITY | BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE,
}

---@enum BTN_TYPE
BTN_TYPE = {
	func = 0,
	exchange = 1,
	buff = 2,
}

---@enum ACT_P_TYPE Action point type
ACT_P_TYPE = {
	processing = 0,
	hunting = 1,
	golden = 2,
}

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

---@param a CGameObject
---@param b CGameObject
---@return boolean
function IsSameObject(a, b)
	return a.m_ObjID.m_byKind == b.m_ObjID.m_byKind and
	a.m_ObjID.m_byID == b.m_ObjID.m_byID and
	a.m_ObjID.m_wIndex == b.m_ObjID.m_wIndex
end

---@type table<integer, number>
ExpDivUnderParty_Kill = { 1.0, 1.1, 1.5, 2.0, 2.5, 3.0, 3.5, 4.5 }

---@enum QUEST_HAPPEN
QUEST_HAPPEN = {
	quest_happen_type_dummy = 0,
	quest_happen_type_npc = 1,
	quest_happen_type_pk = 2,
	quest_happen_type_lv = 3,
	quest_happen_type_class = 4,
	quest_happen_type_grade = 5,
	quest_happen_type_item = 6,
	quest_happen_type_mastery = 7,
	quest_happen_type_maxlevel = 8,
	QUEST_HAPPEN_TYPE_NUM = 9,
}