--[[

Functions, which exists in native RF Online code. Guild related hooks.

--]]

---Purpose: Filter guild establish requests.
---Hook positions: 'filter'.
---@param pPlayer CPlayer
---@param pwszGuildName string
---@return boolean
local function CPlayer__pc_GuildEstablishRequest(pPlayer, pwszGuildName) return true end

---Purpose: Guild establish notification.
---Hook positions: 'after_event'.
---@param pGuild CGuild
local function CPlayer__Guild_Insert_Complete(pGuild) end

---Purpose: Filter guild join requests.
---Hook positions: 'filter'.
---@param pPlayer CPlayer
---@param pGuild CGuild
---@return boolean
local function CPlayer__pc_GuildJoinApplyRequest(pPlayer, pGuild) return true end

---Purpose: Guild join cancel notification.
---Hook positions: 'after_event'.
---@param pPlayer CPlayer
local function CPlayer__SendMsg_GuildJoinApplyCancelResult(pPlayer) end

---Purpose: Filter guild join accept requests.
---Hook positions: 'filter'.
---@param pPlayer CPlayer
---@param dwApplierSerial integer
---@param bAccept boolean
---@return boolean
local function CPlayer__pc_GuildJoinAcceptRequest(pPlayer, dwApplierSerial, bAccept) return true end

---Purpose: Guild join accept notification.
---Hook positions: 'after_event'.
---@param dwGuildSerial integer
---@param dwApplierSerial integer
local function CPlayer__Guild_Join_Accept_Complete(dwGuildSerial, dwApplierSerial) end

---Purpose: Filter guild self leave requests.
---Hook positions: 'filter'.
---@param pPlayer CPlayer
---@return boolean
local function CPlayer__pc_GuildSelfLeaveRequest(pPlayer) return true end

---Purpose: Guild self leave complete notification.
---Hook positions: 'pre_event'.
---@param dwGuildSerial integer
---@param dwLeaverSerial integer
local function CPlayer__Guild_Self_Leave_Complete(dwGuildSerial, dwLeaverSerial) end

---Purpose: Filter guild force leave requests.
---Hook positions: 'filter'.
---@param pGuild CGuild
---@param dwMemberSerial integer
---@return boolean
local function CGuild__ManageExpulseMember(pGuild, dwMemberSerial) return true end

---Purpose: Guild force leave complete notification.
---Hook positions: 'pre_event'.
---@param dwGuildSerial integer
---@param dwLeaverSerial integer
local function CPlayer__Guild_Force_Leave_Complete(dwGuildSerial, dwLeaverSerial) end

---Purpose: Guild disjoint complete notification.
---Hook positions: 'pre_event'.
---@param dwGuildSerial integer
local function CPlayer__Guild_Disjoint_Complete(dwGuildSerial) end

---Purpose: Guild disjoint complete notification.
---Hook positions: 'pre_event'.
---@param dwGuildSerial integer
---@param dwNewMasterSerial integer
---@param dwOldMasterSerial integer
local function CPlayer__Guild_Update_GuildMater_Complete(dwGuildSerial, dwNewMasterSerial, dwOldMasterSerial) end

---Purpose: Guild battle result notification.
---Hook positions: 'after_event'.
---@param pGuildBattle CNormalGuildBattle
---@param byRet integer
local function CNormalGuildBattle__JudgeBattle(pGuildBattle, byRet) end