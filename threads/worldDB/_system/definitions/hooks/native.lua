--[[

Functions, which exists in native RF Online code. World database related hooks.

--]]

---Purpose: Guild ranking.
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param szDate string
---@return boolean
local function CRFWorldDatabase__Update_GuildRank_Step1(pWorldDatabase, szDate) return false end

---Purpose: Rank in guild.
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param dwGuildSerial integer
---@return integer
local function CRFWorldDatabase__Update_RankInGuild_Step1(pWorldDatabase, dwGuildSerial) return 0 end

---Purpose: Guild rank on server startup.
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param szDate string
---@return boolean
local function CRFWorldDatabase__Update_GuildRank(pWorldDatabase, szDate) return false end

---Purpose: Loading guild mambers.
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param wMaxMember integer
---@param dwGuildSerial integer
---@param pGuildMemberInfo _worlddb_guild_member_info
---@return boolean
local function CRFWorldDatabase__Select_GuildMemberData(pWorldDatabase, wMaxMember, dwGuildSerial, pGuildMemberInfo) return false end

---Purpose: Settlement owner decision.
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param szDate string
---@param byRace integer
---@param byLimitCnt integer
---@param pkInfo _weeklyguildrank_owner_info
---@return integer
local function CRFWorldDatabase__Select_WeeklyGuildRankOwnerGuild(pWorldDatabase, szDate, byRace, byLimitCnt, pkInfo) return 0 end

---Purpose: Weekly pvp/kill point update on logout.
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param dwSerial integer
---@param dPvpPoint number
---@return boolean
local function CRFWorldDatabase__Update_IncreaseWeeklyGuildKillPvpPointSum(pWorldDatabase, dwSerial, dPvpPoint) return false end

---Purpose: Weekly guild battle point update.
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param dwSerial integer
---@param dPvpPoint number
---@return boolean
local function CRFWorldDatabase__Update_IncreaseWeeklyGuildGuildBattlePvpPointSum(pWorldDatabase, dwSerial, dPvpPoint) return false end

---Purpose: Additional criteria for Settlement owner apply.
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param szDate string
---@param byRace integer
---@param byLimitCnt integer
---@param byLimitGrade integer
---@return boolean
local function CRFWorldDatabase__Update_PvpPointGuildRankSumLv(pWorldDatabase, szDate, byRace, byLimitCnt, byLimitGrade) return false end

---Purpose: AH tax loading on server startup.
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param byRace integer
---@return integer #nErrCode
---@return string #name of tax applier
---@return integer #byCurTax
---@return integer #byNextTax
local function CRFWorldDatabase__select_atrade_taxrate(pWorldDatabase, byRace) return 0, "", 5, 5 end

---Purpose: Race rank on server startup (all steps).
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param szDate string
---@return boolean
local function CRFWorldDatabase__Update_RaceRank(pWorldDatabase, szDate) return false end

---Purpose: Race rank temp table Bellato (daily ranking).
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param szDate string
---@return boolean
local function CRFWorldDatabase__Update_RaceRank_Step1(pWorldDatabase, szDate) return false end

---Purpose: Race rank temp table Cora (daily ranking).
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param szDate string
---@return boolean
local function CRFWorldDatabase__Update_RaceRank_Step2(pWorldDatabase, szDate) return false end

---Purpose: Race rank temp table Accretia (daily ranking).
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param szDate string
---@return boolean
local function CRFWorldDatabase__Update_RaceRank_Step3(pWorldDatabase, szDate) return false end

---Purpose: Race rank pvp rank decision (daily ranking).
---Hook positions: 'original'
---@param pWorldDatabase CRFWorldDatabase
---@param szDate string
---@return boolean
local function CRFWorldDatabase__Update_RaceRank_Step5(pWorldDatabase, szDate) return false end