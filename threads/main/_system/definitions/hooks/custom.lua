--[[

New functions, added in Sirin guard, and never existed in native RF Online code.

--]]

---Purpose: player session closed
---Hook positions: 'after_event'
---@param uuid string
---@param serial integer
local function exitAccountReport(uuid, serial) end

---Purpose: player session started
---Hook positions: 'after_event'
---@param uuid string
---@param serial integer
local function enterAccountReport(uuid, serial) end

---Purpose: check new player name and name used in rename potion.
---Hook positions: 'filter'
---@param pUserDB CUserDB
---@param pszName string
---@return boolean
local function isValidPlayerName(pUserDB, pszName) return true end

---Purpose: check new guild name.
---Hook positions: 'filter'
---@param pPlayer CPlayer
---@param pszGuildName string
---@return boolean
local function isValidGuildName(pPlayer, pszGuildName) return true end

---Purpose: check new character.
---Hook positions: 'filter'
---@param pUserDB CUserDB
---@param pwszCharName string
---@param byRaceSexCode integer
---@param pszClassCode string
---@param dwBaseShape integer
---@return boolean
local function canCreateCharacter(pUserDB, pwszCharName, byRaceSexCode, pszClassCode, dwBaseShape) return true end

---Purpose: check delete character.
---Hook positions: 'filter'
---@param pUserDB CUserDB
---@param bySlotIndex integer
---@return boolean
local function canDeleteCharacter(pUserDB, bySlotIndex) return true end

---Purpose: check can use auto loot.
---Hook positions: 'filter'
---@param pPlayer CPlayer
---@param pMonster CMonster
---@return boolean
local function canUseAutoLoot(pPlayer, pMonster) return false end

---Purpose: rift based object create notification.
---Hook positions: 'after_event'
---@param pRift CDummyRift
local function CDummyRift__CDummyRift_ctor(pRift) end

---Purpose: rift based object destroy notification.
---Hook positions: 'after_event'
---@param pRift CDummyRift
local function CDummyRift__CDummyRift_dtor(pRift) end

---Purpose: player enter rift based object routine and result notification.
---Hook positions: 'original', 'after_event'
---@param pRift CDummyRift
---@param pPlayer CPlayer
---@param ret? integer Present in 'after_event' hook only.
---@return integer? #return for original hook only
local function CDummyRift__Enter(pRift, pPlayer, ret) return 3 end

---Purpose: close rift based object routine and result notification.
---Hook positions: 'original', 'after_event'
---@param pRift CDummyRift
local function CDummyRift__Close(pRift) end

---Purpose: rift based object is close check routine.
---Hook positions: 'original'
---@param pRift CDummyRift
---@return boolean
local function CDummyRift__IsClose(pRift) return true end

---Purpose: rift based object is valid owner check routine.
---Hook positions: 'original'
---@param pRift CDummyRift
---@return boolean
local function CDummyRift__IsValidOwner(pRift) return true end

---Purpose: rift based object 'create' notification routine for nearby objects.
---Hook positions: 'original'
---@param pRift CDummyRift
local function CDummyRift__SendMsg_Create(pRift) end

---Purpose: rift based object 'destroy' notification routine for nearby objects.
---Hook positions: 'original'
---@param pRift CDummyRift
local function CDummyRift__SendMsg_Destroy(pRift) end

---Purpose: rift based object 'fix position' notification routine for object just entered view range.
---Hook positions: 'original', 'after_event'
---@param pRift CDummyRift
---@param nIndex integer
local function CDummyRift__SendMsg_FixPosition(pRift, nIndex) end

---Purpose: initiate client side teleportation process.
---Hook positions: 'original', 'after_event'
---@param pRift CDummyRift
---@param pPlayer CPlayer
local function CDummyRift__SendMsg_MovePortal(pRift, pPlayer) end

---Purpose: Sirin.mainThread.AlterCashAsync async callback.
---Hook positions: 'after_event'
---@param dwRetCode integer
---@param strParam string
---@param nAlterValue integer
---@param dwCashLeft integer
---@param pPlayer? CPlayer
local function AlterCashComplete(dwRetCode, strParam, nAlterValue, dwCashLeft, pPlayer) end

---Purpose: buff/debuff effect insert notification.
---Hook positions: 'after_event'
---@param pCharacter CCharacter
---@param sf _sf_continous_ex
---@param bLogin boolean
local function OnContEffectInsert(pCharacter, sf, bLogin) end

---Purpose: buff/debuff effect remove notification.
---Hook positions: 'after_event'
---@param pCharacter CCharacter
---@param sf _sf_continous_ex
---@param bByTime boolean
local function OnContEffectRemove(pCharacter, sf, bByTime) end

---Purpose: potion effect insert notification.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
---@param sf _sf_continous_ex
---@param bByTime boolean
local function OnPotionEffectInsert(pPlayer, sf, bByTime) end

---Purpose: potion effect remove notification.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
---@param sf _sf_continous_ex
---@param bTime boolean
local function OnPotionEffectRemove(pPlayer, sf, bTime) end

---Purpose: Sirin.mainThread.GuildPushMoney async callback.
---Hook positions: 'after_event'
---@param dwRetCode integer
---@param dwGuildSerial integer
---@param dTotalDalant number
---@param dTotalGold number
local function CGuild__PushMoneyComplete(dwRetCode, dwGuildSerial, dTotalDalant, dTotalGold) end

---Purpose: Sirin.mainThread.GuildPopMoney async callback.
---Hook positions: 'after_event'
---@param dwRetCode integer
---@param dwProcRet integer
---@param dwGuildSerial integer
---@param dTotalDalant number
---@param dTotalGold number
local function CGuild__PopMoneyComplete(dwRetCode, dwProcRet, dwGuildSerial, dTotalDalant, dTotalGold) end

---Purpose: Check player can place a tower routine.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@return boolean
local function CPlayer__IsHaveEmptyTower(pPlayer) return false end

---Purpose: Shape request for Bot.
---Hook positions: 'special'
---@param pPlayer CPlayer
---@param wIndex integer
---@param byReqType integer
---@param byCashChangeStateFlag integer
local function CNetworkEX__OtherShapeRequest(pPlayer, wIndex, byReqType, byCashChangeStateFlag) end

---Purpose: Prepare avator load notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
local function SirinWorldDB_UserLoad_Prepare(dwAvatorSerial) end

---Purpose: Prepare avator logout notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
local function SirinWorldDB_UserLogout_Prepare(dwAvatorSerial) end

---Purpose: Prepare avator move lobby notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
local function SirinWorldDB_UserLobby_Prepare(dwAvatorSerial) end

---Purpose: Prepare avator update notification.
---Hook positions: 'after_event'
---@param dwAvatorSerial integer
local function SirinWorldDB_UserUpdate_Prepare(dwAvatorSerial) end

---Purpose: Complete avator load notification.
---Hook positions: 'after_event'
---@param bError boolean
---@param byErrCode integer
---@param dwAvatorSerial integer
local function SirinWorldDB_UserLoad_Complete(bError, byErrCode, dwAvatorSerial) end

---Purpose: Complete avator logout notification.
---Hook positions: 'pre_event'
---@param bError boolean
---@param bActive boolean
---@param dwAvatorSerial integer
local function SirinWorldDB_UserLogout_Complete(bError, bActive, dwAvatorSerial) end

---Purpose: Complete avator move lobby notification.
---Hook positions: 'pre_event'
---@param bError boolean
---@param bActive boolean
---@param dwAvatorSerial integer
local function SirinWorldDB_UserLobby_Complete(bError, bActive, dwAvatorSerial) end

---Purpose: Complete avator update notification.
---Hook positions: 'after_event'
---@param byErrCode integer
---@param dwAvatorSerial integer
local function SirinWorldDB_UserUpdate_Complete(byErrCode, dwAvatorSerial) end