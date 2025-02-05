---@meta

---@type any Placeholder arg for lua funcs
_ = nil

---@type boolean Configuration definition in init.lua
SERVER_AOP = false
---@type boolean Configuration definition in init.lua
SERVER_2232 = false

---@class (exact) Sirin
---@field NATS NATS
---@field mainThread mainThread
---@field accountThread accountThread
---@field processAsyncCallback fun(strThreadID: string, strNameSpace: string, strFuncName: string, strParam: string, qwDelay: integer)
---@field WritePrivateProfileStringA fun(pszAppName: string, pszKeyName: string, pszValue: string, pszFileName: string)
---@field GetPrivateProfileIntA fun(pszAppName: string, pszKeyName: string, nDefault: integer, pszFileName: string): integer
---@field GetPrivateProfileStringA fun(pszAppName: string, pszKeyName: string, pszDefault: string, pszFileName: string): integer, string
---@field WriteA fun(pszFileName: string, pszWriteData: string, bWithTime: boolean, bWithDate: boolean)
---@field getUUIDv4 fun(): string
---@field UUIDv4 (fun(): UUIDv4)|(fun(src: UUIDv4): UUIDv4)
---@field getZoneVersion fun(): integer
---@field CAssetController CAssetController
---@field CLanguageAsset CLanguageAsset
---@field CTranslationAsset CTranslationAsset
---@field luaThreadManager luaThreadManager
---@field console console
---@field getFileList fun(strFolderPath: string): table<integer, string>
Sirin = {}

---@class (exact) NATS
---@field publish fun(pszSubject: string, pszData: string, headers? :table<string, string?>)
---@field initNATS fun()
local NATS = {}

---@class (exact) luaThreadManager
---@field LuaGetThread fun(ThreadID: string|integer): ILuaContext
---@field IsExistGlobal fun(Ctx: ILuaContext, pszGlobalName: string): boolean
---@field DeleteGlobal fun(Ctx: ILuaContext, pszGlobalName: string)
---@field CopyToContext fun(DstCtx: ILuaContext, pszDstGlobalname: string, val: any)
---@field CopyFromContext fun(SrcCtx: ILuaContext, pszSrcGlobalname: string): any
local luaThreadManager = {}

---@class (exact) ILuaContext
local ILuaContext = {}
function ILuaContext:Lock() end
function ILuaContext:Unlock() end
---@param pszLuaCode string
---@return boolean
function ILuaContext:DoString(pszLuaCode) end
---@param pszLuaFilePath string
---@return boolean
function ILuaContext:DoFile(pszLuaFilePath) end
---@param pszGlobalName string
---@param pszLuaCode string
---@return boolean
function ILuaContext:MakeGlobalFromString(pszGlobalName, pszLuaCode) end
---@param pszGlobalName string
---@param pszLuaFilePath string
---@return boolean
function ILuaContext:MakeGlobalFromFile(pszGlobalName, pszLuaFilePath) end
---@param pszGlobalName string
---@param pszLuaFolderPath string
---@return boolean
function ILuaContext:MakeGlobalFromChunkedFile(pszGlobalName, pszLuaFolderPath) end
---@param pszGlobalName string
---@param pszLuaFolderPath string
---@return boolean
function ILuaContext:MakeGlobalFromChunkedTable(pszGlobalName, pszLuaFolderPath) end

---@class UUIDv4
---@field fromStrFactory fun(str: string): UUIDv4
local UUIDv4 = {}
function UUIDv4:rand() end
---@return string
function UUIDv4:str() end

---@class (exact) console
---@field LogEx fun(fore: ConsoleForeground, back: ConsoleBackground, fmt: string)
---@field LogEx_NoFile fun(fore: ConsoleForeground, back: ConsoleBackground, fmt: string)
local console = {}

---@class (exact) mainThread
---@field g_dwCurTime integer
---@field ITEM_ROOT_RATE number
---@field MINE_SPEED_RATE number
---@field FORCE_LIVER_ACCUM_RATE number
---@field MASTERY_GET_RATE number
---@field ANIMUS_EXP_RATE number
---@field PLAYER_EXP_RATE number
---@field TSVR_ADD_DARKHOLE_REWARD_RATE number
---@field PLAYER_LOST_EXP number
---@field UNIT_HIT_EXP number
---@field PCBANG_PRIMIUM_FAVOR__MINING_SPEED number
---@field PCBANG_PRIMIUM_FAVOR__PLAYER_EXP number
---@field PCBANG_PRIMIUM_FAVOR__ANIMUS_EXP number
---@field PCBANG_PRIMIUM_FAVOR__BASE_MASTERY number
---@field PCBANG_PRIMIUM_FAVOR__SKILL_FORCE_MASTERY number
---@field PCBANG_PRIMIUM_FAVOR__ITEM_DROP number
---@field PCBANG_PRIMIUM_FAVOR__PVP_RATE number
---@field PCBANG_PRIMIUM_FAVOR__PLAYER_LOST_EXP number
---@field Major_Bind_HQ integer
---@field Major_Sette_Mine_Elan_Map integer
---@field Major_Scroll_Item integer
---@field Major_Cash_Item integer
---@field Major_Add_Character integer
---@field processCheatCommand fun(pOne: CPlayer, strCmd: string): boolean
---@field processAsyncCheatCommand fun(pOne: CPlayer, strCmd: string): boolean
---@field processCheatCommandSilent fun(pOne: CPlayer, strCmd: string): boolean
---@field processAsyncCheatCommandSilent fun(pOne: CPlayer, strCmd: string): boolean
---@field getCheatWordNum fun(): integer
---@field getCheatWord fun(nIndex: integer): string
---@field registCheat fun(strCmdCode: string, strUse: string, strMgr: string): boolean
---@field unregistCheat fun(strCmdCode: string): boolean
---@field objectToCharacter fun(this: CGameObject): CCharacter
---@field objectToAMP fun(this: CGameObject): AutominePersonal
---@field objectToAnimus fun(this: CGameObject): CAnimus
---@field objectToTower fun(this: CGameObject): CGuardTower
---@field objectToHolyKeeper fun(this: CGameObject): CHolyKeeper
---@field objectToHolyStone fun(this: CGameObject): CHolyStone
---@field getMapData (fun(strMapCode: string): CMapData)|(fun(nMapIndex: integer): CMapData)
---@field objectToMonster fun(this: CGameObject): CMonster
---@field objectToNuclearBomb fun(this: CGameObject): CNuclearBomb
---@field g_Player_get fun(nIndex: integer): CPlayer
---@field getPlayerBySerial fun(integer): CPlayer
---@field getActivePlayers fun(): table<integer, CPlayer>
---@field objectToPlayer fun(this: CGameObject): CPlayer
---@field CQuestMgr__s_tblQuestHappenEvent_get fun(nIndex: integer): CRecordData
---@field CQuestMgr__s_tblQuest fun(): CRecordData
---@field objectToReturnGate fun(this: CGameObject): CReturnGate
---@field objectToTrap fun(this: CGameObject): CTrap
---@field g_UserDB_get fun(nIndex: integer): CUserDB
---@field g_ItemBox_get fun(nIndex: integer): CItemBox
---@field getEmptyItemBoxList fun(num: integer): table<integer, CItemBox>
---@field objectToItemBox fun(this: CGameObject): CItemBox
---@field objectToParkingUnit fun(this: CGameObject): CParkingUnit
---@field baseToAmuletItem fun(this: _base_fld): _AmuletItem_fld
---@field baseToAnimus fun(this: _base_fld): _animus_fld
---@field baseToAnimusItem fun(this: _base_fld): _AnimusItem_fld
---@field baseToBagItem fun(this: _base_fld): _BagItem_fld
---@field baseToBatteryItem fun(this: _base_fld): _BatteryItem_fld
---@field baseToBattleDungeonItem fun(this: _base_fld): _BattleDungeonItem_fld
---@field baseToBootyItem fun(this: _base_fld): _BootyItem_fld
---@field baseToBoxItem fun(this: _base_fld): _BoxItem_fld
---@field baseToBulletItem fun(this: _base_fld): _BulletItem_fld
---@field baseToCheckPotion fun(this: _base_fld): _CheckPotion_fld
---@field baseToClass fun(this: _base_fld): _class_fld
---@field baseToCouponItem fun(this: _base_fld): _CouponItem_fld
---@field baseToDfnEquipItem fun(this: _base_fld): _DfnEquipItem_fld
---@field baseToCloakItem fun(this: _base_fld): _CloakItem_fld
---@field baseToEventItem fun(this: _base_fld): _EventItem_fld
---@field baseToFaceItem fun(this: _base_fld): _FaceItem_fld
---@field baseToFirecrackerItem fun(this: _base_fld): _FIRECRACKER_fld
---@field baseToForce fun(this: _base_fld): _force_fld
---@field baseToForceItem fun(this: _base_fld): _ForceItem_fld
---@field baseToGuardTowerItem fun(this: _base_fld): _GuardTowerItem_fld
---@field baseToItemLooting fun(this: _base_fld): _ItemLooting_fld
---@field baseToItemMakeData fun(this: _base_fld): _ItemMakeData_fld
---@field baseToItemUpgrade fun(this: _base_fld): _ItemUpgrade_fld
---@field baseToMakeToolItem fun(this: _base_fld): _MakeToolItem_fld
---@field baseToMap fun(this: _base_fld): _map_fld
---@field baseToMapItem fun(this: _base_fld): _MapItem_fld
---@field baseToMonBlock fun(this: _base_fld): _mon_block_fld
---@field baseToMonActive fun(this: _base_fld): _mon_active_fld
---@field baseToMonsterCharacter fun(this: _base_fld): _monster_fld
---@field baseToNPCharacter fun(this: _base_fld): _npc_fld
---@field baseToNPCLinkItem fun(this: _base_fld): _NPCLink_fld
---@field baseToOreCutting fun(this: _base_fld): _OreCutting_fld
---@field baseToOreItem fun(this: _base_fld): _OreItem_fld
---@field baseToPlayerCharacter fun(this: _base_fld): _player_fld
---@field baseToPortal fun(this: _base_fld): _portal_fld
---@field baseToPotionItemFld fun(this: _base_fld): _PotionItem_fld
---@field baseToQuestEvent fun(this: _base_fld): _QuestHappenEvent_fld
---@field baseToQuest fun(this: _base_fld): _Quest_fld
---@field baseToRadarItem fun(this: _base_fld): _RadarItem_fld
---@field baseToRecoveryItem fun(this: _base_fld): _RecoveryItem_fld
---@field baseToResourceItem fun(this: _base_fld): _ResourceItem_fld
---@field baseToRingItem fun(this: _base_fld): _RingItem_fld
---@field baseToSetItemEff fun(this: _base_fld): _SetItemEff_fld
---@field baseToSiegeKitItem fun(this: _base_fld): _SiegeKitItem_fld
---@field baseToSkill fun(this: _base_fld): _skill_fld
---@field baseToStoreList fun(this: _base_fld): _StoreList_fld
---@field baseToTicketItem fun(this: _base_fld): _TicketItem_fld
---@field baseToTimeItem fun(this: _base_fld): _TimeItem_fld
---@field baseToTownItem fun(this: _base_fld): _TOWNItem_fld
---@field baseToTrapItem fun(this: _base_fld): _TrapItem_fld
---@field baseToUnitBullet fun(this: _base_fld): _UnitBullet_fld
---@field baseToUnitFrame fun(this: _base_fld): _UnitFrame_fld
---@field baseToUnitKeyItem fun(this: _base_fld): _UnitKeyItem_fld
---@field baseToUnitPart fun(this: _base_fld): _UnitPart_fld
---@field baseToUnmannedMinerItem fun(this: _base_fld): _UNmannedminer_fld
---@field baseToWeaponItem fun(this: _base_fld): _WeaponItem_fld
---@field createItemBox fun(strItemCode: string, dwUpgrade: integer, qwDurPoint: integer, dwLendTime: integer, byCreateCode: integer, pMap: CMapData, wLayerIndex: integer, fPosX: number, fPosY: number, fPosZ: number, dwRange: integer, bHide: boolean, pOwner: CPlayer, bPartyShare: boolean, pThrower: CCharacter, pAttacker: CPlayer, byEventItemLootAuth: integer, bHolyScanner: boolean): CItemBox
---@field createItemBox_Monster fun(pBox?: CItemBox, byTableCode: integer, pFld: _base_fld, qwDurPoint: integer, byCreateCode: integer, pMap: CMapData, wLayerIndex: integer, fPosX: number, fPosY: number, fPosZ: number, dwRange: integer, bHide: boolean, dwOwnerObjSerial: integer, wOwnerObjIndex: integer, dwThrowerObjSerial: integer, wThrowerObjIndex: integer, pMonRec: _monster_fld): CItemBox
---@field createItemBoxForAutoLoot fun(pItem: _STORAGE_LIST___db_con, pOwner: CPlayer, dwPartyBossSerial: integer, bPartyShare: boolean, pThrower?: CCharacter, byCreateCode: integer, pMap: CMapData, wLayerIndex: integer, fStdPos: table<integer, number>, bHide: boolean): CItemBox
---@field makeLoot fun(byTableCode: integer, wItemIndex: integer): _STORAGE_LIST___db_con
---@field createMonster fun(pMap: CMapData, wLayerIndex: integer, fPosX: number, fPosY: number, fPosZ: number, strMonCode: string, bRobExp: boolean, bRewardExp: boolean, bWithoutFail: boolean): CMonster
---@field AddCash fun(pPlayer: CPlayer, nValue: integer)
---@field AddPremDays fun(pPlayer: CPlayer, nValue: integer)
---@field AddPremSeconds fun(pPlayer: CPlayer, nValue: integer)
---@field IsOverLapItem fun(byTableCode: integer): boolean
---@field IsProtectItem fun(byTableCode: integer): boolean
---@field IsItemEquipCivil fun(nTableCode: integer, nItemIndex: integer, byRaceSexCode: integer): boolean
---@field GetItemEquipGrade (fun(byTableCode: integer, nIndex: integer): integer)|(fun(byTableCode: integer, strItemCode: string): integer)
---@field GetLoopTime fun(): integer
---@field GetItemTableCode fun(strCode: string): integer
---@field GetAnimusFldFromExp fun(nAnimusClass: integer, qwExp: integer): _animus_fld
---@field GetAnimusFldFromLv fun(nAnimusClass: integer, dwLv: integer): _animus_fld
---@field GetMaxParamFromExp fun(nAnimusClass: integer, qwExp: integer): integer
---@field GetDefItemUpgSocketNum fun(byTableCode: integer, nIndex: integer): integer
---@field GetItemDurPoint fun(byTableCode: integer, nIndex: integer): integer
---@field GetItemUpgLimSocket fun(dwUpgrade: integer): integer
---@field GetItemUpgedLv fun(dwUpgrade: integer): integer
---@field GetItemGrade fun(byTableCode: integer, nIndex: integer): integer
---@field GetBitAfterUpgrade fun(dwCurUpgrade: integer, dwTalikCode: integer, byCurLv: integer): integer
---@field GetBitAfterSetLimSocket fun(byLimSocketNum: integer): integer
---@field SearchAvatorWithName fun(strName: string): CUserDB
---@field objectToDummyRift fun(this: CGameObject): CDummyRift
---@field teleportPlayer (fun(dwPlayerSerial: integer, dwDstMapIndex: integer, fPosX: number, fPosY: number, fPosZ: number, wLayer: integer): integer)|(fun(pPlayer: CPlayer, pMap: CMapData, fPosX: number, fPosY: number, fPosZ: number, wLayer: integer): integer)
---@field activateLayer fun(dwDstMapIndex: integer, wLayer: integer, bActivate: boolean): integer
---@field CReturnGateCreateParam fun(a1?: CPlayer): CReturnGateCreateParam
---@field _STORAGE_LIST___storage_con fun(src?: _STORAGE_LIST___storage_con): _STORAGE_LIST___storage_con
---@field _STORAGE_LIST___db_con fun(src?: _STORAGE_LIST___db_con): _STORAGE_LIST___db_con
---@field _object_id fun(): _object_id
---@field _combine_ex_item_result_zocl fun(): _combine_ex_item_result_zocl
---@field voidToObject fun(ptr: lightuserdata): CGameObject
---@field objectToVoid fun(ptr: CGameObject): lightuserdata
---@field voidToBase fun(ptr: lightuserdata): _base_fld
---@field baseToVoid fun(ptr: _base_fld): lightuserdata
---@field voidToMapData fun(ptr: lightuserdata): CMapData
---@field mapDataToVoid fun(ptr: CMapData): lightuserdata
---@field IsAddAbleTalikToItem fun(byItemTableCode: integer, wItemIndex: integer, dwItemCurLv: integer, pUpgTalik: _ItemUpgrade_fld): boolean
---@field GetItemEquipLevel fun(nTableCode: integer, nItemIndex: integer): integer
---@field _ContPotionData fun(): _ContPotionData
---@field attackToPlayerAttack fun(pAT: CAttack): CPlayerAttack
---@field attackToMonsterAttack fun(pAt: CAttack): CMonsterAttack
---@field AlterCashAsync fun(dwAccountSerial: integer, nAlterValue: integer, strParam: string)
---@field g_Guild_get fun(nIndex: integer): CGuild
---@field _happen_event_cont fun(): _happen_event_cont
---@field TimeItem__FindTimeRec fun(nTblCode: integer, nIndex: integer): _TimeItem_fld
---@field GetActiveGuildList fun(): table<integer, CGuild>
---@field GetGuildBySerial fun(dwSerial: integer): CGuild
---@field GuildPushMoney fun(pGuild: CGuild, dwAddDalant: integer, dwAddGold: integer, byIOType: integer, dwIOerSerial, pszIOerName): boolean
---@field GuildPopMoney fun(pGuild: CGuild, dwSubDalant: integer, dwSubGold: integer, byIOType: integer, dwIOerSerial, pszIOerName): boolean
---@field _QUEST_DB_BASE___START_NPC_QUEST_HISTORY fun(): _QUEST_DB_BASE___START_NPC_QUEST_HISTORY
---@field CMonster__s_logTrace_Boss_Looting CLogFile
---@field modChargeItem modChargeItem
---@field modContEffect modContEffect
---@field modReturnGate modReturnGate
---@field modItemPropertySkin modItemPropertySkin
---@field modPotionEffect modPotionEffect
---@field modButtonExt modButtonExt
---@field modStackExt modStackExt
---@field modGuardTowerController modGuardTowerController
---@field modQuestHistory modQuestHistory
---@field modBoxOpen modBoxOpen
---@field modInfinitePotion modInfinitePotion
---@field modRaceSexClassChange modRaceSexClassChange
---@field modForceLogoutAfterUsePotion modForceLogoutAfterUsePotion
---@field g_pAttack CAttack
---@field g_dwAttType integer
---@field g_HolySys CHolyStoneSystem
---@field g_Main CMainThread
---@field g_MapOper CMapOperation
---@field g_PotionMgr CPotionMgr
---@field g_GameStatistics CGameStatistics
---@field CMgrAvatorItemHistory CMgrAvatorItemHistory
---@field CLuaSendBuffer CLuaSendBuffer
---@field cStaticMember_Player cStaticMember_Player
---@field CPvpUserAndGuildRankingSystem CPvpUserAndGuildRankingSystem
---@field CActionPointSystemMgr CActionPointSystemMgr
local mainThread = {}

---@class (exact) accountThread
---@field enterWorldRequest fun(pszUUIDv4: string, nAccountSerial: integer, nSupervisorAccount: integer, bPush: boolean, dwIPAddr:integer, bIsPCBang:boolean, bChatLock:boolean, byGrade:integer, bySubGrade:integer): integer
---@field closeAccountRequest fun(nAccountSerial: integer)
local accountThread = {}

---@class (exact) modChargeItem
---@field giveItemByName fun(pszPlayerName: string, pszItemCode: string, qwDur: integer, dwUpgrade: integer, dwT: integer, bSameStack?: boolean): integer
---@field giveItemBySerial fun(dwPlayerSerial: integer, pszItemCode: string, qwDur: integer, dwUpgrade: integer, dwT: integer, bSameStack?: boolean): integer
---@field takeItemBySerial fun(dwPlayerSerial: integer, pszItemCode: string, dwUpgrade: integer, qwUID: integer, dwStorageMask: integer, nNum: integer): integer
---@field pushChargeItem fun(pPlayer: CPlayer, pszItemCode: string, qwD: integer, dwU: integer, dwT: integer)
---@field pushChargeItemBySerial fun(dwPlayerSerial: integer, pszItemCode: string, qwD: integer, dwU: integer, dwT: integer)
local modChargeItem = {}

---@class (exact) modContEffect
---@field isUse fun(): boolean
---@field getMaxSFNum fun(nContCode: integer): integer
---@field getMaxPotionNum fun(): integer
---@field sfcontTosfcontEx fun(a1: _sf_continous): _sf_continous_ex
---@field getPlayersfcontEx fun(pPlayer: CPlayer, nContCode: integer, nEffectIndex: integer): _sf_continous_ex
---@field getPlayerPotion fun(pPlayer: CPlayer, nEffectIndex: integer): _sf_continous_ex
local modContEffect = {}

---@class (exact) modReturnGate
---@field CreateDummyRift fun(): CDummyRift
local modReturnGate = {}

---@class (exact) modItemPropertySkin
---@field isSkinItem fun(qwD: integer): boolean
---@field insertProperty fun(qwUUID: integer, dwAccountSerial: integer, dwK: integer)
---@field updateProperty fun(qwUUID: integer, dwK: integer)
---@field updateOwner fun(qwUUID: integer, dwAccountSerial: integer)
---@field deleteProperty fun(qwUUID: integer)
---@field applySkinToItem fun(dwPlayerSerial: integer, qwUUID: integer, byTableCode: integer, wItemIndex: integer)
local modItemPropertySkin = {}

---@class (exact) modPotionEffect
---@field addHandler fun(nPotionIndex: integer): boolean
---@field removeHandler fun(nPotionIndex: integer): boolean
local modPotionEffect = {}

---@class (exact) modButtonExt
---@field RegisterButtons fun()
---@field IsBeNearExchangeButton fun(pOne: CPlayer, dwButtonID: integer): boolean
---@field IsBeNearButton fun(pOne: CPlayer, dwButtonID: integer): boolean
local modButtonExt = {}

---@class (exact) modStackExt
---@field GetStackSize fun(): integer
local modStackExt = {}

---@class (exact) modGuardTowerController
---@field createGuardTower fun(pMap: CMapData, wLayer: integer, x: number, y: number, z: number, pItem: _STORAGE_LIST___db_con, pMaster: CPlayer, byRace: integer, bQuick: boolean): CGuardTower
---@field createSystemTower fun(pMap: CMapData, wLayer: integer, x: number, y: number, z: number, nTowerIndex: integer, byRace: integer, nINIindex: integer): CGuardTower
---@field getTowerByIndex fun(nIndex: integer): CGuardTower
local modGuardTowerController = {}

---@class (exact) modQuestHistory
---@field setDailyReset fun(hour: integer, minute: integer)
---@field setWeeklyReset fun(dayOfWeek: integer, hour: integer, minute: integer)
---@field setMonthlyReset fun(day: integer, hour: integer, minute: integer)
---@field isPossibleTakeNPCQuest fun(pQuestMgr: CQuestMgr, pQuestFld: _Quest_fld): boolean
---@field s_tmNextDailyResetTime integer
---@field s_tmNextWeeklyResetTime integer
---@field s_tmNextMonthlyResetTime integer
---@field s_tmLastDailyResetTime integer
---@field s_tmLastWeeklyResetTime integer
---@field s_tmLastMonthlyResetTime integer
local modQuestHistory = {}

---@class (exact) modBoxOpen
---@field loadScripts fun(): boolean
local modBoxOpen = {}

---@class (exact) modInfinitePotion
---@field s_bIsInfinite boolean
local modInfinitePotion = {}

---@class (exact) modRaceSexClassChange
---@field updateRaceSexClass fun(pPlayer: CPlayer, byNewRaceSex: integer, pszClassCode: string): integer
---@field updateBaseShape fun(pPlayer: CPlayer, dwBaseShape: integer): integer
local modRaceSexClassChange = {}

---@class (exact) modForceLogoutAfterUsePotion
---@field s_bNeedForceLogout boolean
local modForceLogoutAfterUsePotion = {}

---@class (exact) AutominePersonal: CCharacter
---@field m_bDBLoad boolean
---@field m_bOpenUI_Inven boolean
---@field m_bOpenUI_Battery boolean
---@field m_bInstalled boolean
---@field m_bInvenFull boolean
---@field m_bStart boolean
---@field m_bySelOre integer
---@field m_wItemSerial integer
---@field m_byFilledSlotCnt integer
---@field m_dwNextSendTime_CurState integer
---@field m_dwDelaySec integer
---@field m_dwDelay integer
---@field m_dwNextMineTime integer
---@field m_dwChangeSendTime integer
---@field m_nMaxHP integer
---@field m_pItem _STORAGE_LIST___db_con
---@field m_pOwner CPlayer
---@field m_byUseBattery integer
---@field m_pBatterySlot lightuserdata AP_BatterySlot
---@field m_bChanged boolean
---@field m_changed_packet lightuserdata _personal_amine_mineore_zocl
---@field m_update_mineore_old lightuserdata _qry_case_update_mineore
---@field m_update_mineore_new lightuserdata _qry_case_update_mineore
---@field m_logProcess CLogFile
---@field m_logSysErr CLogFile
local AutominePersonal = {}
---@param a1 integer
---@return integer
function AutominePersonal:m_dwMineCount_get(a1) end
---@param a1 integer
---@param a2 integer
function AutominePersonal:m_dwMineCount_set(a1, a2) end

---@class (exact) CActionPointSystemMgr
---@field Instance fun(): CActionPointSystemMgr
local CActionPointSystemMgr = {}
---@param a1 integer
---@return integer
function CActionPointSystemMgr:GetEventStatus(a1) end

---@class (exact) _animus_create_setdata : _character_create_setdata
---@field nHP integer
---@field nFP integer
---@field dwExp integer
---@field pMaster CPlayer
---@field nMaxAttackPnt integer
local _animus_create_setdata = {}

---@class (exact) CAnimus: CCharacter
---@field m_byClassCode integer
---@field m_nHP integer
---@field m_nFP integer
---@field m_dwExp integer
---@field m_pMaster CPlayer
---@field m_dwMasterSerial integer
---@field m_wszMasterName string
---@field m_aszMasterName string
---@field m_byRoleCode integer
---@field m_dwLastDestroyTime integer
---@field m_fMoveSpeed number
---@field m_byPosRaceTown integer
---@field m_pBeforeTownCheckMap CMapData
---@field m_fBeforeTownCheckPos_x number
---@field m_fBeforeTownCheckPos_y number
---@field m_dwStunTime integer
---@field m_dwBeAttackedTargetTime integer
---@field m_pNextTarget CCharacter
---@field m_nMaxAttackPnt integer
---@field m_tmNextEatMasterFP integer
---@field m_pRecord _animus_fld
---@field m_nMaxHP integer
---@field m_nMaxFP integer
---@field m_Mightiness number
---@field m_dwAIMode integer
---@field m_pTarget CCharacter
local CAnimus = {}
---@param a1 integer
---@return integer
function CAnimus:m_DefPart_get(a1) end
---@param a1 integer
---@param a2 integer
function CAnimus:m_DefPart_set(a1, a2) end
---@param a1 integer
---@return lightuserdata CAITimer
function CAnimus:m_AITimer_get(a1) end
---@param a1 integer
---@return lightuserdata SKILL
function CAnimus:m_Skill_get(a1) end
---@param nAddExp integer
function CAnimus:AlterExp(nAddExp) end

---@class (exact) CAssetController
---@field instance fun(): CAssetController
local CAssetController = {}
---@param a1 string
---@return lightuserdata IBaseAsset
function CAssetController:getAsset(a1) end
---@param a1 string
---@param a2 lightuserdata IBaseAsset
function CAssetController:addAsset(a1, a2) end
---@return boolean
function CAssetController:makeAssetData() end
function CAssetController:sendAssetData() end

---@class (exact) CAttack
---@field m_pp _attack_param
---@field m_pAttChar CCharacter
---@field m_bIsCrtAtt boolean
---@field m_bActiveSucc boolean
---@field m_nDamagedObjNum integer
---@field m_bFailure boolean
local CAttack = {}
---@param a1 integer
---@return _be_damaged_char
function CAttack:m_DamList_get(a1) end

---@class (exact) CBsp
local CBsp = {}
---@param from_x number
---@param from_y number
---@param from_z number
---@param to_x number
---@param to_y number
---@param to_z number
---@return integer # BOOL can or not
---@return number # stop x
---@return number # stop y
---@return number # stop z
function CBsp:CanYouGoThere(from_x, from_y, from_z, to_x, to_y, to_z) end
---@param from_x number
---@param from_y number
---@param from_z number
---@param to_x number
---@param to_y number
---@param to_z number
---@return integer # unsigned long unknown
---@return integer # size of returned table
---@return table # table of {x, y, z}
function CBsp:GetPathFind(from_x, from_y, from_z, to_x, to_y, to_z) end

---@class (exact) _character_create_setdata: _object_create_setdata
local _character_create_setdata = {}

---@class (exact) CCharacter: CGameObject
---@field m_fTarPos_x number
---@field m_fTarPos_y number
---@field m_fTarPos_z number
---@field m_AroundNum integer
---@field m_dwNextGenAttackTime integer
---@field m_dwEffSerialCounter integer
---@field m_bLastContEffectUpdate boolean
---@field m_wLastContEffect integer
---@field m_EP _effect_parameter
---@field m_wEffectTempValue integer
---@field m_dwPlayerSerial integer
---@field m_wszPlayerName string
---@field m_nContEffectSec integer
---@field m_tmrSFCont lightuserdata CMyTimer
local CCharacter = {}
---@param a1 integer
---@return CCharacter
function CCharacter:m_AroundSlot_get(a1) end
---@param a1 integer
---@param a2 CCharacter
function CCharacter:m_AroundSlot_set(a1, a2) end
---@param a1 integer
---@param a2 integer
---@return _sf_continous
function CCharacter:m_SFCont_get(a1, a2) end
---@param a1 integer
---@param a2 integer
---@return _sf_continous
function CCharacter:m_SFContAura_get(a1, a2) end
---@param byContCode integer Buff (1) or debuff (0)
---@param byEffectCode integer|EFF_CODE
---@param dwEffectIndex integer Effect script index
---@param wDurSec integer Duration seconds
---@param byLv integer Effect level
---@param pActChar CCharacter|nil Who applied effect
---@return integer # Error code
---@return boolean # Is mastery can grow 
function CCharacter:InsertSFContEffect(byContCode, byEffectCode, dwEffectIndex, wDurSec, byLv, pActChar) end
function CCharacter:UpdateSFCont() end
---@param a1 integer
---@param a2 integer
---@param a3 boolean
---@param a4 boolean
function CCharacter:RemoveSFContEffect(a1, a2, a3, a4) end
---@param pDstChar CCharacter Who applied effect
---@param pForceFld _force_fld
---@param nForceLv integer
---@return boolean
---@return integer # Error code
---@return boolean # Is mastery can grow 
function CCharacter:AssistForce(pDstChar, pForceFld, nForceLv) end
---@param pDstChar CCharacter Who applied effect
---@param nEffectCode integer:eff_code
---@param pSkillFld _skill_fld
---@param nSkillLv integer
---@return boolean
---@return integer # Error code
---@return boolean # Is mastery can grow 
function CCharacter:AssistSkill(pDstChar, nEffectCode, pSkillFld, nSkillLv) end
---@param a1 boolean
---@return boolean
function CCharacter:GetStealth(a1) end

---@class (exact) CDummyRift: CReturnGate
---@field m_strObjectUUID string
local CDummyRift = {}

---@class (exact) CGameObject
---@field m_pRecordSet _base_fld
---@field m_ObjID _object_id
---@field m_dwObjSerial integer
---@field m_bLive boolean
---@field m_nTotalObjIndex integer
---@field m_bCorpse boolean
---@field m_bMove boolean
---@field m_bStun boolean
---@field m_bMapLoading boolean
---@field m_dwLastSendTime integer
---@field m_fCurPos_x number
---@field m_fCurPos_y number
---@field m_fCurPos_z number
---@field m_fAbsPos_x number
---@field m_fAbsPos_y number
---@field m_fAbsPos_z number
---@field m_nScreenPos_x integer
---@field m_nScreenPos_y integer
---@field m_fOldPos_x number
---@field m_fOldPos_y number
---@field m_fOldPos_z number
---@field m_pCurMap CMapData
---@field m_rtPer100 lightuserdata _100_per_random_table
---@field m_nCirclePlayerNum integer
---@field m_wMapLayerIndex integer
---@field m_SectorPoint _object_list_point
---@field m_SectorNetPoint _object_list_point
---@field m_dwNextFreeStunTime integer
---@field m_dwOldTickBreakTranspar integer
---@field m_bBreakTranspar boolean
---@field m_bMaxVision boolean
---@field m_bObserver boolean
---@field m_dwCurSec integer
local CGameObject = {}
---@param a1 boolean
function CGameObject:SetStun(a1) end
---@return integer
function CGameObject:CalcCurHPRate() end
---@param a1 boolean
function CGameObject:SendMsg_RealFixPosition(a1) end
function CGameObject:Loop() end
function CGameObject:AlterSec() end
function CGameObject:OutOfSec() end
---@param a1 integer
function CGameObject:SendMsg_FixPosition(a1) end
---@param a1 integer
function CGameObject:SendMsg_RealMovePoint(a1) end
function CGameObject:SendMsg_StunInform() end
function CGameObject:SendMsg_SetHPInform() end
---@return integer
function CGameObject:GetHP() end
---@param a1 integer
---@param a2 boolean
---@return boolean
function CGameObject:SetHP(a1, a2) end
---@return integer
function CGameObject:GetMaxHP() end
---@param a1 CCharacter
function CGameObject:RecvKillMessage(a1) end
---@param a1 integer
---@param a2 integer
---@param a3 boolean
---@param a4 CPlayer
function CGameObject:SFContInsertMessage(a1, a2, a3, a4) end
---@param a1 integer
---@param a2 integer
---@param a3 boolean
---@param a4 boolean
function CGameObject:SFContDelMessage(a1, a2, a3, a4) end
---@param a1 integer
---@param a2 integer
---@param a3 integer
function CGameObject:SFContUpdateTimeMessage(a1, a2, a3) end
---@param a1 CCharacter
function CGameObject:BeTargeted(a1) end
---@param a1 CCharacter
---@param a2 integer
---@return boolean
function CGameObject:RobbedHP(a1, a2) end
---@param a1 CCharacter
---@param a2 integer
---@return boolean
function CGameObject:FixTargetWhile(a1, a2) end
---@param a1 integer
function CGameObject:SetAttackPart(a1) end
---@param a1 CCharacter
---@param a2 integer
---@param a3 boolean
---@return integer
function CGameObject:GetGenAttackProb(a1, a2, a3) end
---@param a1 integer
---@param a2 CCharacter
---@param a3 integer
---@param a4 boolean
---@param a5 integer
---@param a6 integer
---@param a7 boolean
---@return integer
function CGameObject:SetDamage(a1, a2, a3, a4, a5, a6, a7) end
---@param nAttactPart integer
---@param pAttChar CCharacter Attacker
---@return integer # result value
---@return integer # converted part
function CGameObject:GetDefFC(nAttactPart, pAttChar) end
---@return integer
function CGameObject:GetFireTol() end
---@return integer
function CGameObject:GetWaterTol() end
---@return integer
function CGameObject:GetSoilTol() end
---@return integer
function CGameObject:GetWindTol() end
---@param a1 integer
---@return number
function CGameObject:GetDefGap(a1) end
---@param a1 integer
---@return number
function CGameObject:GetDefFacing(a1) end
---@return number
function CGameObject:GetWeaponAdjust() end
---@return integer
function CGameObject:GetLevel() end
---@param a1 boolean
---@return integer
function CGameObject:GetDefSkill(a1) end
---@return number
function CGameObject:GetWidth() end
---@return number
function CGameObject:GetAttackRange() end
---@return integer
function CGameObject:AttackableHeight() end
---@return integer
function CGameObject:GetWeaponClass() end
---@return integer
function CGameObject:GetAvoidRate() end
---@return integer
function CGameObject:GetAttackLevel() end
---@return integer
function CGameObject:GetAttackDP() end
---@return integer
function CGameObject:GetObjRace() end
---@param a1 CGameObject
---@return string
function CGameObject:GetObjName(a1) end
---@return boolean
function CGameObject:IsRecvableContEffect() end
---@param a1 boolean
---@return boolean
function CGameObject:IsBeAttackedAble(a1) end
---@return boolean
function CGameObject:IsRewardExp() end
---@param a1 CCharacter
---@return boolean
function CGameObject:IsBeDamagedAble(a1) end
---@return boolean
function CGameObject:IsInTown() end
---@return boolean
function CGameObject:IsAttackableInTown() end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_AttHPtoDstFP_Once(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_ContDamageTimeInc_Once(a1, a2) end
---@param a1 CCharacter
---@return boolean
function CGameObject:SF_Resurrect_Once(a1) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_HPInc_Once(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_STInc_Once(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_ContHelpTimeInc_Once(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_OverHealing_Once(a1, a2) end
---@param a1 CCharacter
---@return boolean
function CGameObject:SF_LateContHelpSkillRemove_Once(a1) end
---@param a1 CCharacter
---@return boolean
function CGameObject:SF_LateContHelpForceRemove_Once(a1) end
---@param a1 CCharacter
---@return boolean
function CGameObject:SF_LateContDamageRemove_Once(a1) end
---@param a1 CCharacter
---@return boolean
function CGameObject:SF_AllContHelpSkillRemove_Once(a1) end
---@param a1 CCharacter
---@return boolean
function CGameObject:SF_AllContHelpForceRemove_Once(a1) end
---@param a1 CCharacter
---@return boolean
function CGameObject:SF_AllContDamageForceRemove_Once(a1) end
---@param a1 number
---@return boolean
function CGameObject:SF_OthersContHelpSFRemove_Once(a1) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_SkillContHelpTimeInc_Once(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_ConvertMonsterTarget(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_TransMonsterHP(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_ReleaseMonsterTarget(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_IncHPCircleParty(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_Stun(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_SPDec(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_FPDec(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_DamageAndStun(a1, a2) end
---@param pDstObj CCharacter Receiver
---@param fEffectValue number how much
---@return boolean # result
---@return integer # error code
function CGameObject:SF_TransDestHP(pDstObj, fEffectValue) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_RemoveAllContHelp_Once(a1, a2) end
---@param pDstObj CCharacter Probably not needed
---@param fEffectValue number Probably not needed
---@return boolean # result
---@return integer # error code
function CGameObject:SF_MakePortalReturnBindPositionPartyMember(pDstObj, fEffectValue) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_ReturnBindPosition(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_IncreaseDP(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_ConvertTargetDest(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_RecoverAllReturnStateAnimusHPFull(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_MakeZeroAnimusRecallTimeOnce(a1, a2) end
---@param a1 CCharacter
---@param a2 number
---@return boolean
function CGameObject:SF_SelfDestruction(a1, a2) end
---@param a1 CCharacter
---@param a2 boolean
---@return boolean
function CGameObject:SF_TeleportToDestination(a1, a2) end
---@return boolean
function CGameObject:Is_Battle_Mode() end
---@param a1 _object_create_setdata
---@return boolean
function CGameObject:Create(a1) end
---@param byType integer Packet ID
---@param bySubType integer Packet sub ID
---@param buffer CLuaSendBuffer
---@param bToSelf boolean Including self
---@param dwPassObjSerial? integer Exclude this object
---@return integer
function CGameObject:CircleReport(byType, bySubType, buffer, bToSelf, dwPassObjSerial) end
---@return integer
function CGameObject:GetCurSecNum() end

---@class (exact) _tower_create_setdata : _character_create_setdata
---@field nHP integer
---@field pMaster CPlayer
---@field byRaceCode integer
---@field pItem _STORAGE_LIST___db_con
---@field nIniIndex integer
---@field bQuick integer
local _tower_create_setdata = {}

---@class (exact) CGuardTower: CCharacter
---@field m_nHP integer
---@field m_pMasterTwr CPlayer
---@field m_dwMasterSerial integer
---@field m_byRaceCode integer
---@field m_pItem _STORAGE_LIST___db_con
---@field m_wItemSerial integer
---@field m_bSystemStruct boolean
---@field m_nIniIndex integer
---@field m_dwStartMakeTime integer
---@field m_bComplete boolean
---@field m_bQuick boolean
---@field m_pTarget CCharacter
---@field m_pMasterSetTarget CCharacter
---@field m_dwLastDestroyTime integer
local CGuardTower = {}
---@param byDesType integer
---@param bSystemBack boolean
---@return boolean
function CGuardTower:Destroy(byDesType, bSystemBack) end

---@class (exact) _keeper_create_setdata : _character_create_setdata
---@field nMasterRace integer
---@field pPosCreate _dummy_position
---@field pPosActive _dummy_position
---@field pPosCenter _dummy_position
local _keeper_create_setdata = {}

---@class (exact) CHolyKeeper: CCharacter
---@field m_nHP integer
---@field m_dwLastDestroyTime integer
---@field m_pRec _monster_fld
---@field m_pPosCreate _dummy_position
---@field m_pPosActive _dummy_position
---@field m_pPosCenter _dummy_position
---@field m_nMasterRace integer
---@field m_bExit boolean
---@field m_bChaos boolean
---@field m_dwLastStopTime integer
---@field m_pLastMoveTarget CPlayer
---@field m_at CAttack
---@field m_ap _attack_param
---@field m_bDamageAbleState boolean
---@field m_nCurrLootIndex integer
---@field m_nEndLootIndex integer
---@field m_nCurrDropIndex integer
---@field m_wMagnifications integer
---@field m_wRange integer
---@field m_wDropCntOnce integer
---@field m_tmrDropTime lightuserdata CMyTimer
local CHolyKeeper = {}
---@param a1 integer
---@return integer
function CHolyKeeper:m_nDefPart_get(a1) end
---@param a1 integer
---@param a2 integer
function CHolyKeeper:m_nDefPart_set(a1, a2) end

---@class (exact) CHolyScheduleData
---@field m_bSet boolean
---@field m_pSchedule CHolyScheduleData____HolyScheduleNode
---@field m_nTotalSchedule integer
local CHolyScheduleData = {}

---@class (exact) CHolyScheduleData____HolyScheduleNode
local CHolyScheduleData____HolyScheduleNode = {}
---@param a1 integer
---@return integer
function CHolyScheduleData____HolyScheduleNode:m_nSceneTime_get(a1) end
---@param a1 integer
---@param a2 integer
function CHolyScheduleData____HolyScheduleNode:m_nSceneTime_set(a1, a2) end

---@class (exact) CHolyStone: CCharacter
---@field m_bOper boolean
---@field m_nHP integer
---@field m_nMaxHP integer
---@field m_dwLastDestroyTime integer
---@field m_pRec _monster_fld
---@field m_pDum _dummy_position
---@field m_byMasterRaceCode integer
---@field m_nOldRate integer
---@field m_dwLastRecoverTime integer
---@field m_nCurrLootIndex integer
---@field m_nEndLootIndex integer
---@field m_nCurrDropIndex integer
---@field m_wMagnifications integer
---@field m_wRange integer
---@field m_wDropCntOnce integer
---@field m_wAddCountWithPlayer integer
---@field m_tmrDropTime lightuserdata CMyTimer
local CHolyStone = {}
---@param a1 integer
---@return integer
function CHolyStone:m_nDefPart_get(a1) end
---@param a1 integer
---@param a2 integer
function CHolyStone:m_nDefPart_set(a1, a2) end

---@class (exact) CHolyStoneSaveData
---@field m_nSceneCode integer
---@field m_dwPassTimeInScene integer
---@field m_nStartStoneHP integer
---@field m_nHolyMasterRace integer
---@field m_nDestroyStoneRace integer
---@field m_byNumOfTime integer
---@field m_dwCumPlayerNum integer
---@field m_dwCumCount integer
---@field m_wStartYear integer
---@field m_byStartMonth integer
---@field m_byStartDay integer
---@field m_byStartHour integer
---@field m_byStartMin integer
---@field m_dwDestroyerSerial integer
---@field m_eDestroyerState integer
---@field m_dwOreRemainAmount integer
---@field m_dwOreTotalAmount integer
---@field m_dwDestroyerGuildSerial integer
---@field m_byOreTransferCount integer
---@field m_dwOreTransferAmount integer
local CHolyStoneSaveData = {}
---@param a1 integer
---@return integer
function CHolyStoneSaveData:m_nStoneHP_Buffer_get(a1) end
---@param a1 integer
---@param a2 integer
function CHolyStoneSaveData:m_nStoneHP_Buffer_set(a1, a2) end
---@param a1 integer
---@return integer
function CHolyStoneSaveData:m_dwTerm_get(a1) end
---@param a1 integer
---@param a2 integer
function CHolyStoneSaveData:m_dwTerm_set(a1, a2) end

---@class (exact) CHolyStoneSystem
---@field m_tblQuest CRecordData
---@field m_logQuest CLogFile
---@field m_logQuestDestroy CLogFile
---@field m_logPer10Min CLogFile
---@field m_tmrHSKSystem lightuserdata CMyTimer
---@field m_pkDestroyer CPlayer
---@field m_dwNextStartTime integer
---@field m_nHolyStoneNum integer
---@field m_HolyKeeperData __holy_keeper_data
---@field m_ScheculeData CHolyScheduleData
---@field m_SaveData CHolyStoneSaveData
---@field m_tmrCumPlayer lightuserdata CMyTimer
---@field m_strHolyMental string
---@field m_fKeeperHPRate number
---@field m_fFirstKeeperHPRate number
---@field m_bScheduleCodePre integer
---@field m_byKeeperDestroyRace integer
---@field m_bConsumable boolean
---@field m_pMentalPass boolean
---@field bFreeMining boolean
local CHolyStoneSystem = {}
---@param a1 integer
---@return __holy_stone_data
function CHolyStoneSystem:m_HolyStoneData_get(a1) end
---@param a1 integer
---@return integer
function CHolyStoneSystem:m_dwCheckTime_get(a1) end
---@param a1 integer
---@param a2 integer
function CHolyStoneSystem:m_dwCheckTime_set(a1, a2) end
---@param a1 integer
---@return _QUEST_CASH
function CHolyStoneSystem:m_cashQuest_get(a1) end
---@param a1 integer
---@return _QUEST_CASH_OTHER
function CHolyStoneSystem:m_cashQuestOther_get(a1) end
---@param a1 integer
---@return _portal_dummy
function CHolyStoneSystem:m_pPortalDummy_get(a1) end
---@param a1 integer
---@param a2 integer
---@return integer
function CHolyStoneSystem:m_nRaceBattlePoint_get(a1, a2) end
---@param a1 integer
---@param a2 integer
---@param a3 integer
function CHolyStoneSystem:m_nRaceBattlePoint_set(a1, a2, a3) end
---@return integer
function CHolyStoneSystem:GetDestroyerState() end
---@return integer
function CHolyStoneSystem:GetDestroyerSerial() end
---@return integer
function CHolyStoneSystem:GetDestroyerGuildSerial() end
---@return integer
function CHolyStoneSystem:GetNumOfTime() end
---@return integer
function CHolyStoneSystem:GetSceneCode() end
---@param a1 integer
function CHolyStoneSystem:SetKeeperDestroyRace(a1) end

---@class (exact) CItemBox: CGameObject
---@field m_dwOwnerSerial integer
---@field m_wOwnerIndex integer
---@field m_dwThrowerSerial integer
---@field m_byThrowerID integer
---@field m_wThrowerIndex integer
---@field m_wMonRecIndex integer
---@field m_bBossMob boolean
---@field m_wszThrowerName string
---@field m_aszThrowerName string
---@field m_dwThrowerCharSerial integer
---@field m_szThrowerID string
---@field m_byThrowerRaceCode integer
---@field m_byThrowerDegree integer
---@field m_szThrowerItemHistoryFileName string
---@field m_dwLootStartTime integer
---@field m_nStateCode integer
---@field m_dwLastDestroyTime integer
---@field m_byCreateCode integer
---@field m_dwPartyBossSerial integer
---@field m_bPartyShare boolean
---@field m_bCompDgr boolean
---@field m_dwEventPartyBoss integer
---@field m_dwEventGuildSerial integer
---@field m_byEventRaceCode integer
---@field m_byEventLootAuth integer
---@field m_bHolyScanner integer
---@field m_Item _STORAGE_LIST___db_con
---@field m_bHide boolean
local CItemBox = {}
---@param a1 CPlayer
---@return boolean
function CItemBox:IsTakeRight(a1) end
---@return boolean
function CItemBox:Destroy() end

---@class (exact) CLanguageAsset
---@field instance fun(): CLanguageAsset
local CLanguageAsset = {}
---@param a1 integer
---@param a2 string
---@param a3 string
---@param a4 integer
function CLanguageAsset:addLanguage(a1, a2, a3, a4) end
---@param a1 integer
function CLanguageAsset:setDefaultLanguage(a1) end
---@param a1 integer
---@return integer
function CLanguageAsset:getPlayerLanguage(a1) end
---@param a1 integer
---@return string
function CLanguageAsset:getPlayerLanguagePrefix(a1) end
---@return boolean
function CLanguageAsset:makeAssetData() end
---@return table
function CLanguageAsset:getLanguageTable() end

---@class (exact) CLevel
---@field mMapName string
---@field mMatView lightuserdata D3DXMATRIX
---@field mIsLoadedBsp integer
---@field mBsp CBsp
---@field mSkyBox lightuserdata CSkyBox
---@field mAutoAniCam lightuserdata CAniCamera
---@field mTimer lightuserdata CTimer
---@field mDummy lightuserdata CExtDummy
---@field mLightTexMemSize integer
---@field mMapTexMemSize integer
---@field mSkyTexMemSize integer
---@field mEntityTexMemSize integer
---@field mEnvironment integer
local CLevel = {}
---@param a1 integer
---@return number
function CLevel:mCamPos_get(a1) end
---@param from_x number
---@param from_y number
---@param from_z number
---@param to_x number
---@param to_y number
---@param to_z number
---@return integer # BOOL result
---@return number # Y position
function CLevel:GetNextYposForServerFar(from_x, from_y, from_z, to_x, to_y, to_z) end
---@param from_x number
---@param from_y number
---@param from_z number
---@param to_x number
---@param to_y number
---@param to_z number
---@return integer # BOOL result
---@return number # Y position
function CLevel:GetNextYposFarProgress(from_x, from_y, from_z, to_x, to_y, to_z) end
---@param from_x number
---@param from_y number
---@param from_z number
---@return integer # BOOL result
---@return number # Y position
function CLevel:GetNextYposForServer(from_x, from_y, from_z) end

---@class (exact) CLuaSendBuffer
---@field Instance fun(): CLuaSendBuffer
local CLuaSendBuffer = {}
---@param a1 string
---@param a2 integer
function CLuaSendBuffer:PushString(a1, a2) end
---@param a1 CPlayer
---@param a2 integer
---@param a3 integer
function CLuaSendBuffer:SendBuffer(a1, a2, a3) end
function CLuaSendBuffer:Init() end
---@param a1 integer
function CLuaSendBuffer:PushInt8(a1) end
---@param a1 integer
function CLuaSendBuffer:PushInt16(a1) end
---@param a1 integer
function CLuaSendBuffer:PushInt32(a1) end
---@param a1 integer
function CLuaSendBuffer:PushInt64(a1) end
---@param a1 integer
function CLuaSendBuffer:PushUInt8(a1) end
---@param a1 integer
function CLuaSendBuffer:PushUInt16(a1) end
---@param a1 integer
function CLuaSendBuffer:PushUInt32(a1) end
---@param a1 integer
function CLuaSendBuffer:PushUInt64(a1) end
---@param a1 number
function CLuaSendBuffer:PushFloat(a1) end
---@param a1 number
function CLuaSendBuffer:PushDouble(a1) end

---@class (exact) CMainThread
---@field m_Rand lightuserdata _SRAND
---@field m_pWorldDB lightuserdata CRFWorldDatabase
---@field m_MainFrameRate lightuserdata CFrameRate
---@field m_DBFrameRate lightuserdata CFrameRate
---@field m_GameMsg lightuserdata CMsgProcess
---@field m_MgrConnNum lightuserdata CConnNumPHMgr
---@field m_HisMainFPS lightuserdata CConnNumPHMgr
---@field m_HisSendFPS lightuserdata CConnNumPHMgr
---@field m_HisDataFPS lightuserdata CConnNumPHMgr
---@field m_tmServerState lightuserdata CMyTimer
---@field m_bVerCheck boolean
---@field m_tmEconomyState lightuserdata CMyTimer
---@field m_tmDbUpdate integer
---@field m_listDQSData lightuserdata CNetIndexList
---@field m_listDQSDataComplete lightuserdata CNetIndexList
---@field m_listDQSDataEmpty lightuserdata CNetIndexList
---@field m_CheckSum lightuserdata CCheckSum
---@field m_nLimUserNum integer
---@field m_szWorldName string
---@field m_wszWorldName string
---@field m_wszMainGreetingMsg string
---@field m_wszRaceGreetingMsg_b string
---@field m_wszRaceGreetingMsg_c string
---@field m_wszRaceGreetingMsg_a string
---@field m_wszGMName string
---@field m_wszBossName_b string
---@field m_wszBossName_c string
---@field m_wszBossName_a string
---@field m_bAwayPartyConsumeItem boolean
---@field m_strAwayPartyItemCode string
---@field m_bAwayPartyConsumeMoney boolean
---@field m_dwAwayPartyMoney integer
---@field m_strAllRaceChatItemCode string
---@field m_bAllRaceChatItemConsume boolean
---@field m_bAllRaceChatMoneyConsume boolean
---@field m_dwAllRaceChatMoney integer
---@field m_byWorldCode integer
---@field m_bWorldOpen boolean
---@field m_bWorldService boolean
---@field m_szWorldDBName string
---@field m_dwMessengerIP integer
---@field m_dwAccountIP integer
---@field m_dwCheckAccountOldTick integer
---@field m_tmrCheckAvator lightuserdata CMyTimer
---@field m_tmrCheckLoop lightuserdata CMyTimer
---@field m_tmrAccountPing lightuserdata CMyTimer
---@field m_tmrStateMsgGotoWeb lightuserdata CMyTimer
---@field m_tmrCheckRadarDelay lightuserdata CMyTimer
---@field m_bFreeServer integer
---@field m_bRuleThread boolean
---@field m_bDQSThread boolean
---@field m_tblPlayer CRecordData
---@field m_tblMonster CRecordData
---@field m_tblNPC CRecordData
---@field m_tblAnimus CRecordData
---@field m_tblClass CRecordData
---@field m_tblExp CRecordData
---@field m_tblGrade CRecordData
---@field m_tblItemLoot lightuserdata CItemLootTable
---@field m_tblOreCutting lightuserdata COreCuttingTable
---@field m_tblItemMakeData CRecordData
---@field m_tblItemCombineData CRecordData
---@field m_tblItemExchangeData CRecordData
---@field m_tblItemUpgrade CItemUpgradeTable
---@field m_tblUnitBullet CRecordData
---@field m_tblUnitFrame CRecordData
---@field m_tblEditData CRecordData
---@field m_MonsterBaseSPData CRecordData
---@field m_MonsterSPGroupTable lightuserdata CMonsterSPGroupTable
---@field m_logBillCheck CLogFile
---@field m_logSystemError CLogFile
---@field m_logLoadingError CLogFile
---@field m_logDungeon CLogFile
---@field m_logKillMon CLogFile
---@field m_logServerState CLogFile
---@field m_logDTrade CLogFile
---@field m_logGuild CLogFile
---@field m_logDQS CLogFile
---@field m_logRename CLogFile
---@field m_logAutoTrade CLogFile
---@field m_logEvent CLogFile
---@field m_logMove CLogFile
---@field m_logSave CLogFile
---@field m_logReturnGate CLogFile
---@field m_logHack CLogFile
---@field m_logPvP CLogFile
---@field m_logMonNum CLogFile
---@field m_logAPIBilling CLogFile
---@field m_logRenewalData CLogFile
---@field m_tmForceUserExit lightuserdata CMyTimer
---@field m_nForceExitSocketIndexOffset integer
---@field m_bServerClosing boolean
---@field m_bCheckOverTickCount boolean
---@field m_nSleepTerm integer
---@field m_nSleepValue integer
---@field m_nSleepIgnore integer
---@field m_bCheckSumActive boolean
---@field m_byWebAgentServerNetInx integer
---@field m_bConnectedWebAgentServer boolean
---@field m_byControllServerNetInx integer
---@field m_bConnectedControllServer boolean
---@field m_iOldDay integer
---@field m_byWorldType integer
---@field m_bReleaseServiceMode boolean
---@field m_bExcuteService boolean
---@field m_byServiceCompanyMode integer
---@field m_pRFEvent_ClassRefine lightuserdata RFEventBase
---@field m_kEtcNotifyInfo lightuserdata CNotifyNotifyRaceLeaderSownerUTaxrate
---@field m_BattleTournamentInfo lightuserdata CBattleTournamentInfo
---@field m_GuildCreateEventInfo lightuserdata GuildCreateEventInfo
---@field m_ServerRateLoad lightuserdata _server_rate_realtime_load
---@field m_pTimeLimitMgr lightuserdata TimeLimitMgr
---@field m_tmCheckForceClose lightuserdata CMyTimer
---@field m_MobMessage lightuserdata _mob_message
---@field m_bLimitPlayerLevel integer
---@field m_byLimitPlayerLevel integer
---@field m_bFlyOnOff boolean
---@field m_bFlyLog boolean
---@field m_bFlyUserCut boolean
---@field m_dwGuildEntryDelay integer
---@field m_byPlayerInteg integer
---@field m_dwServerResetToken integer
---@field m_dwCheatSetPlayTime integer
---@field m_dwCheatSetScanerCnt integer
---@field m_dwCheatSetLevel integer
local CMainThread = {}
---@param a1 TBL_CODE|integer
---@return CRecordData
function CMainThread:m_tblItemData_get(a1) end
---@param a1 EFF_CODE|integer
---@return CRecordData
function CMainThread:m_tblEffectData_get(a1) end
---@param a1 UNIT_PART|integer
---@return CRecordData
function CMainThread:m_tblUnitPart_get(a1) end
---@param a1 integer
---@return integer
function CMainThread:m_dwGuildPower_get(a1) end
---@param a1 integer
---@param a2 integer
function CMainThread:m_dwGuildPower_set(a1, a2) end

---@class (exact) _pnt_rect
---@field nStartx integer
---@field nStarty integer
---@field nEndx integer
---@field nEndy integer
local _pnt_rect = {}

---@class (exact) CMapData
---@field m_bUse boolean
---@field m_bLoad boolean
---@field m_nMapIndex integer
---@field m_Level CLevel
---@field m_nMapCode integer
---@field m_mb lightuserdata _MULTI_BLOCK
---@field m_Dummy lightuserdata CExtDummy
---@field m_nMapInPlayerNum integer
---@field m_nMapInMonsterNum integer
---@field m_nMonBlockNum integer
---@field m_pMonBlock lightuserdata _mon_block
---@field m_nMonDumNum integer
---@field m_nPortalNum integer
---@field m_pPortal _portal_dummy
---@field m_nItemStoreDumNum integer
---@field m_pItemStoreDummy _store_dummy
---@field m_nStartDumNum integer
---@field m_pStartDummy lightuserdata _start_dummy
---@field m_nBindDumNum integer
---@field m_pBindDummy lightuserdata _bind_dummy
---@field m_nResDumNum integer
---@field m_pResDummy lightuserdata _res_dummy
---@field m_nQuestDumNum integer
---@field m_pQuestDummy lightuserdata _quest_dummy
---@field m_pMapSet _map_fld
---@field m_pExtDummy_Town lightuserdata CExtDummy
---@field m_nSafeDumNum integer
---@field m_pSafeDummy lightuserdata _safe_dummy
---@field m_tbSafeDumPos lightuserdata CDummyPosTable
---@field m_tbMonBlk CRecordData
---@field m_tbPortal CRecordData
---@field m_tbMonDumPos lightuserdata CDummyPosTable
---@field m_tbPortalDumPos lightuserdata CDummyPosTable
---@field m_tbStoreDumPos lightuserdata CDummyPosTable
---@field m_tbStartDumPos lightuserdata CDummyPosTable
---@field m_tbBindDumPos lightuserdata CDummyPosTable
---@field m_tbResDumPosHigh lightuserdata CDummyPosTable
---@field m_tbResDumPosMiddle lightuserdata CDummyPosTable
---@field m_tbResDumPosLow lightuserdata CDummyPosTable
---@field m_tbQuestDumPos lightuserdata CDummyPosTable
---@field m_BspInfo lightuserdata _bsp_info
---@field m_SecInfo _sec_info
---@field m_tmrMineGradeReSet lightuserdata CMyTimer
---@field m_nMonTotalCount integer
local CMapData = {}
---@param a1 integer
---@return _LAYER_SET
function CMapData:m_ls_get(a1) end
---@param in_x number
---@param in_y number
---@param in_z number
---@param nRange integer
---@return boolean
---@return number x
---@return number y
---@return number z
---@nodiscard
function CMapData:GetRandPosInRange(in_x, in_y, in_z, nRange) end
---@param in_x number
---@param in_y number
---@param in_z number
---@return boolean
function CMapData:IsMapIn(in_x, in_y, in_z) end
---@param nRadius integer
---@param dwCurSec integer Current sector number
---@return _pnt_rect
function CMapData:GetRectInRadius(nRadius, dwCurSec) end
---@param wLayerIndex integer
---@param dwSecIndex integer
---@return CObjectList
function CMapData:GetSectorListObj(wLayerIndex, dwSecIndex) end
---@param wLayerIndex integer
---@param dwSecIndex integer
---@param nRadius? integer
---@param dwObjCharMask? integer
---@param dwObjItemMask? integer
---@param fRefPosX? number Required for sorting
---@param fRefPosY? number Required for sorting
---@param fRefPosZ? number Required for sorting
---@param bSortAsc? boolean Sort targets by distance in ascending order
---@return table<integer, CGameObject>
function CMapData:GetObjectListInRadius(wLayerIndex, dwSecIndex, nRadius, dwObjCharMask, dwObjItemMask, fRefPosX, fRefPosY, fRefPosZ, bSortAsc) end
---@param wLayerIndex integer
---@param dwSecIndex integer
---@param nRadius? integer
---@param fRefPosX? number Required for sorting
---@param fRefPosY? number Required for sorting
---@param fRefPosZ? number Required for sorting
---@param bSortAsc? boolean Sort targets by distance in ascending order
---@return table<integer, CPlayer>
function CMapData:GetPlayerListInRadius(wLayerIndex, dwSecIndex, nRadius, fRefPosX, fRefPosY, fRefPosZ, bSortAsc) end
---@param x number
---@param z number
---@return integer
function CMapData:GetSectorIndex(x, z) end

---@class (exact) CMapOperation
local CMapOperation = {}
---@param byRace integer
---@param bRand boolean
---@return CMapData
---@return number x
---@return number y
---@return number z
---@nodiscard
function CMapOperation:GetPosStartMap(byRace, bRand) end

---@class (exact) _monster_create_setdata : _character_create_setdata
---@field pActiveRec lightuserdata _mon_active
---@field pDumPosition _dummy_position
---@field bDungeon boolean
---@field bRobExp boolean
---@field bRewardExp boolean
---@field pParent CMonster
local _monster_create_setdata = {}

---@class (exact) CMonster: CCharacter
---@field m_bOper boolean
---@field m_bApparition boolean
---@field m_bDungeon boolean
---@field m_dwLastDestroyTime integer
---@field m_dwDestroyNextTime integer
---@field m_dwLastRecoverTime integer
---@field m_fCreatePos_x number
---@field m_fCreatePos_y number
---@field m_fCreatePos_z number
---@field m_fLookAtPos_x number
---@field m_fLookAtPos_y number
---@field m_fLookAtPos_z number
---@field m_bRobExp boolean
---@field m_bRewardExp boolean
---@field m_bStdItemLoot boolean
---@field m_pActiveRec lightuserdata _mon_active
---@field m_pMonRec _monster_fld
---@field m_pDumPosition _dummy_position
---@field m_nHP integer
---@field m_LootMgr CLootingMgr
---@field m_AggroMgr lightuserdata CMonsterAggroMgr
---@field m_MonHierarcy lightuserdata CMonsterHierarchy
---@field m_SFContDamageTolerance lightuserdata MonsterSFContDamageToleracne
---@field m_LifeMax integer
---@field m_LifeCicle integer
---@field m_nCommonStateChunk integer
---@field m_EmotionPresentationCheck lightuserdata EmotionPresentationChecker
---@field m_fYAngle number
---@field m_fStartLookAtPos_x number
---@field m_fStartLookAtPos_y number
---@field m_fStartLookAtPos_z number
---@field m_bRotateMonster boolean
---@field m_MonsterStateData lightuserdata MonsterStateData
---@field m_BeforeMonsterStateData lightuserdata MonsterStateData
---@field m_pTargetChar CCharacter
---@field m_MonsterSkillPool lightuserdata CMonsterSkillPool
---@field m_nEventItemNum integer
---@field m_pEventRespawn lightuserdata _event_respawn
---@field m_pEventSet lightuserdata _event_set
---@field m_AI lightuserdata CMonsterAI
---@field m_LuaSignalReActor lightuserdata CLuaSignalReActor
local CMonster = {}
---@param a1 integer
---@return integer
function CMonster:m_byCreateDate_get(a1) end
---@param a1 integer
---@param a2 integer
function CMonster:m_byCreateDate_set(a1, a2) end
---@param a1 CMonster
---@return integer
function CMonster:m_nMove_State_get(a1) end
---@param a1 CMonster
---@return integer
function CMonster:m_nCombat_State_get(a1) end
---@param a1 CMonster
---@return integer
function CMonster:m_nEmotion_State_get(a1) end
---@param a1 integer
---@return integer
function CMonster:m_DefPart_get(a1) end
---@param a1 integer
---@param a2 integer
function CMonster:m_DefPart_set(a1, a2) end
---@param a1 integer
---@return lightuserdata _event_loot_item
function CMonster:m_eventItem_get(a1) end
---@return integer
function CMonster:GetCritical_Exception_Rate() end
---@param nCapKind integer
---@return boolean
---@return integer nOutValue
---@nodiscard
function CMonster:GetViewAngleCap(nCapKind) end
---@param byDestroyCode integer
---@param pAttObj? CGameObject
---@return boolean
function CMonster:Destroy(byDestroyCode, pAttObj) end

---@class (exact) _nuclear_create_setdata : _character_create_setdata
---@field pMaster CPlayer
---@field nMasterSirial integer
---@field m_dwWarnTime boolean
---@field m_dwAttInformTime boolean
---@field m_dwAttStartTime integer
local _nuclear_create_setdata = {}

---@class (exact) CNuclearBomb: CCharacter
---@field m_wItemIndex integer
---@field m_wControlSerial integer
---@field m_bUse boolean
---@field m_bIsLive boolean
---@field m_dwStartTime integer
---@field m_dwDurTime integer
---@field m_dwDelayTime integer
---@field m_dwWarnTime integer
---@field m_dwAttInformTime integer
---@field m_dwAttStartTime integer
---@field m_byBombState integer
---@field m_nDamagedObjNum integer
---@field m_nEffObjNum integer
---@field m_nStartDmLoop integer
---@field m_pMaster CPlayer
local CNuclearBomb = {}
---@param a1 integer
---@return number
function CNuclearBomb:m_fDropPos_get(a1) end
---@param a1 integer
---@param a2 number
function CNuclearBomb:m_fDropPos_set(a1, a2) end
---@param a1 integer
---@return _be_damaged_player
function CNuclearBomb:m_DamList_get(a1) end
---@param a1 integer
---@return _be_damaged_char
function CNuclearBomb:m_EffList_get(a1) end

---@class (exact) CObjectList
---@field m_Head _object_list_point
---@field m_Tail _object_list_point
---@field m_nSize integer
local CObjectList = {}

---@class (exact) CPartyPlayer
---@field m_bLogin boolean
---@field m_id _CLID
---@field m_wszName string
---@field m_wZoneIndex integer
---@field m_pPartyBoss CPartyPlayer
---@field m_bLock boolean
---@field m_byLootShareSystem integer
---@field m_pLootAuthor CPartyPlayer
---@field m_pDarkHole lightuserdata CDarkHole
local CPartyPlayer = {}
---@param a1 integer
---@return CPartyPlayer
function CPartyPlayer:m_pPartyMember_get(a1) end
---@return boolean
function CPartyPlayer:IsPartyBoss() end
---@return boolean
function CPartyPlayer:IsPartyMode() end
---@return CPlayer
function CPartyPlayer:GetLootAuthor() end
---@param a1 CPlayer
---@return boolean
function CPartyPlayer:IsPartyMember(a1) end

---@class (exact) CPlayer: CCharacter
---@field m_bLoad boolean
---@field m_bOper boolean
---@field m_bPostLoad boolean
---@field m_bFullMode boolean
---@field m_byUserDgr integer
---@field m_bySubDgr integer
---@field m_bFirstStart boolean
---@field m_bOutOfMap boolean
---@field m_byMoveDirect integer
---@field m_byPlusKey integer
---@field m_wXorKey integer
---@field m_dwMoveCount integer
---@field m_dwTargetCount integer
---@field m_dwAttackCount integer
---@field m_bBaseDownload boolean
---@field m_bInvenDownload boolean
---@field m_bForceDownload boolean
---@field m_bCumDownload boolean
---@field m_bQuestDownload boolean
---@field m_bSpecialDownload boolean
---@field m_bLinkBoardDownload boolean
---@field m_bAMPInvenDownload boolean
---@field m_bGuildListDownload boolean
---@field m_bGuildDownload boolean
---@field m_bBuddyListDownload boolean
---@field m_bBlockParty boolean
---@field m_bBlockWhisper boolean
---@field m_bBlockTrade boolean
---@field m_bCreateComplete boolean
---@field m_dwSelfDestructionTime integer
---@field m_fSelfDestructionDamage number
---@field m_bTakeGravityStone boolean
---@field m_bBlockGuildBattleMsg boolean
---@field m_bInGuildBattle boolean
---@field m_bNotifyPosition boolean
---@field m_byGuildBattleColorInx integer
---@field m_bTakeSoccerBall boolean
---@field m_pSoccerItem _STORAGE_LIST___db_con
---@field m_pUserDB CUserDB
---@field m_pPartyMgr CPartyPlayer
---@field m_Param CPlayerDB
---@field m_id _CLID
---@field m_byMoveType integer
---@field m_byModeType integer
---@field m_byStandType integer
---@field m_kMoveDelayChecker lightuserdata CRealMoveRequestDelayChecker
---@field m_pmWpn _WEAPON_PARAM
---@field m_pmTrd lightuserdata _DTRADE_PARAM
---@field m_pmMst _MASTERY_PARAM
---@field m_pmTwr _TOWER_PARAM
---@field m_pmTrp _TRAP_PARAM
---@field m_pmBuddy lightuserdata _BUDDY_LIST
---@field m_QuestMgr CQuestMgr
---@field m_ItemCombineMgr ItemCombineMgr
---@field m_byMapInModeBuffer integer
---@field m_nVoteSerial integer
---@field m_bWarCount boolean
---@field m_dwLastCheckRegionTime integer
---@field m_wRegionMapIndex integer
---@field m_wRegionIndex integer
---@field m_byHSKQuestCode integer
---@field m_MinigTicket lightuserdata MiningTicket
---@field m_nHSKPvpPoint integer
---@field m_wKillPoint integer
---@field m_byHSKTime integer
---@field m_wDiePoint integer
---@field m_byCristalBattleDBInfo integer
---@field m_clsSetItem lightuserdata CSetItemEffect
---@field m_pDHChannel lightuserdata CDarkHoleChannel
---@field m_fTalik_DefencePoint number
---@field m_fTalik_AvoidPoint number
---@field m_bCheat_100SuccMake boolean
---@field m_bCheat_makeitem_no_use_matrial boolean
---@field m_bCheat_Matchless boolean
---@field m_bFreeRecallWaitTime boolean
---@field m_bFreeSFByClass boolean
---@field m_bLootFree boolean
---@field m_bNeverDie boolean
---@field m_nMaxAttackPnt integer
---@field m_bSpyGM boolean
---@field m_nAnimusAttackPnt integer
---@field m_nTrapMaxAttackPnt integer
---@field m_byDamagePart integer
---@field m_bRecvMapChat boolean
---@field m_bRecvAllChat boolean
---@field EquipItemSFAgent lightuserdata CEquipItemSFAgent
---@field m_pmCryMsg lightuserdata _CRYMSG_LIST
---@field m_bSnowMan boolean
---@field m_byStoneMapMoveInfo integer
---@field m_dwPatriarchAppointTime integer
---@field m_byPatriarchAppointPropose integer
---@field m_bAfterEffect boolean
---@field m_bSFDelayNotCheck boolean
---@field m_ReNamePotionUseInfo lightuserdata _RENAME_POTION_USE_INFO
---@field m_bCommunionEffectAnimus boolean
---@field m_byCommunionStep integer
---@field m_bGeneratorAttack boolean
---@field m_byUnitEffectAttackStep integer
---@field m_bGeneratorDefense boolean
---@field m_byUnitEffectDefenseStep integer
---@field m_CashChangeStateFlag integer union CPlayer__CashChangeStateFlag
---@field m_NPCQuestIndexTempData _NPCQuestIndexTempData
---@field m_wVisualVer integer
---@field m_nLastBeatenPart integer
---@field m_dwLastState integer
---@field m_dwLastStateEx integer
---@field m_dwExpRate integer
---@field m_nAddDfnMstByClass integer
---@field m_nMaxDP integer
---@field m_fEquipSpeed number
---@field m_nOldMaxDP integer
---@field m_fSendTarPos_x number
---@field m_fSendTarPos_y number
---@field m_byLastDirect integer
---@field m_fLastRecvPos_x number
---@field m_fLastRecvPos_y number
---@field m_fLastRecvPos_z number
---@field m_byLastRecvMapIndex integer
---@field m_dwLastTakeItemTime integer
---@field m_nCheckMovePacket integer
---@field m_bCheckMovePacket boolean
---@field m_byDefMatCount integer
---@field m_MakeRandTable _100_per_random_table
---@field m_pBindMapData CMapData
---@field m_pBindDummyData _dummy_position
---@field m_dwNextTimeDungeonDie integer
---@field m_dwLastTimeCheckUnitViewOver integer
---@field m_dwUnitViewOverTime integer
---@field m_pUsingUnit _UNIT_DB_BASE___LIST
---@field m_pParkingUnit lightuserdata CParkingUnit
---@field m_byUsingWeaponPart integer
---@field m_nUnitDefFc integer
---@field m_pSiegeItem _STORAGE_LIST___db_con
---@field m_bIsSiegeActing boolean
---@field m_tmrSiegeTime lightuserdata CMyTimer
---@field m_pRecalledAnimusItem _STORAGE_LIST___db_con
---@field m_pRecalledAnimusChar CAnimus
---@field m_dwLastRecallTime integer
---@field m_byNextRecallReturn integer
---@field m_wTimeFreeRecallSerial integer
---@field m_tmrIntervalSec lightuserdata CMyTimer
---@field m_dwLastSetPointTime integer
---@field m_tmrBilling lightuserdata CMyTimer
---@field m_fBeforeDungeonPos_x number
---@field m_fBeforeDungeonPos_y number
---@field m_fBeforeDungeonPos_z number
---@field m_pBeforeDungeonMap CMapData
---@field m_dwContItemEffEndTime integer
---@field m_PotionParam CPotionParam
---@field m_PotionBufUse CExtPotionBuf
---@field m_bCntEnable integer
---@field m_tmLoginTime lightuserdata _SYSTEMTIME
---@field m_tmCalcTime lightuserdata _SYSTEMTIME
---@field m_tmrAccumPlayingTime lightuserdata CMyTimer
---@field m_bUpCheckEquipEffect boolean
---@field m_bDownCheckEquipEffect boolean
---@field m_byPosRaceTown integer
---@field m_pBeforeTownCheckMap CMapData
---@field m_fBeforeTownCheckPos_x number
---@field m_fBeforeTownCheckPos_y number
---@field m_TargetObject CPlayer____target
---@field m_tmrGroupTargeting lightuserdata CMyTimer
---@field m_bMineMode boolean
---@field m_dwMineNextTime integer
---@field m_wBatterySerialTmp integer
---@field m_bySelectOreIndex integer
---@field m_byDelaySec integer
---@field m_zMinePos_x integer
---@field m_zMinePos_y integer
---@field m_AttDelayChker lightuserdata _ATTACK_DELAY_CHECKER
---@field m_fUnitPv_AttFc number
---@field m_fUnitPv_DefFc number
---@field m_fUnitPv_RepPr number
---@field m_kPvpPointLimiter lightuserdata CPvpPointLimiter
---@field m_nChaosMode integer
---@field m_dwChaosModeTime10Per integer
---@field m_dwChaosModeEndTime integer
---@field m_nCashAmount integer
---@field m_kPvpOrderView CPvpOrderView
---@field m_byBattleMode integer
---@field m_dwBattleTime integer
---@field m_tmrAuraSkill lightuserdata CMyTimer
---@field m_kPvpCashPoint lightuserdata CPvpCashPoint
---@field m_kPcBangCoupon lightuserdata CCouponMgr
---@field m_tmrEffectStartTime lightuserdata CMyTimer
---@field m_tmrEffectEndTime lightuserdata CMyTimer
---@field m_byBattleTournamentGrade integer
---@field m_NameChangeBuddyInfo lightuserdata _NameChangeBuddyInfo
---@field m_dwPcBangGiveItemListIndex integer
---@field m_dwRaceBuffClearKey lightuserdata MiningTicket___AuthKeyTicket
---@field m_tmrPremiumPVPInform lightuserdata CMyTimer
---@field m_szItemHistoryFileName string
---@field m_szLvHistoryFileName string
---@field m_dwUMWHLastTime integer
---@field m_bufShapeAll lightuserdata _other_shape_all_zocl
---@field m_bufSpapePart lightuserdata _other_shape_part_zocl
local CPlayer = {}
---@param a1 integer
---@return integer
function CPlayer:m_nAddPointByClass_get(a1) end
---@param a1 integer
---@param a2 integer
function CPlayer:m_nAddPointByClass_set(a1, a2) end
---@param a1 integer
---@return integer
function CPlayer:m_nMaxPoint_get(a1) end
---@param a1 integer
---@param a2 integer
function CPlayer:m_nMaxPoint_set(a1, a2) end
---@param a1 integer
---@return integer
function CPlayer:m_nTolValue_get(a1) end
---@param a1 integer
---@param a2 integer
function CPlayer:m_nTolValue_set(a1, a2) end
---@param a1 integer
---@return integer
function CPlayer:m_zLastTol_get(a1) end
---@param a1 integer
---@param a2 integer
function CPlayer:m_zLastTol_set(a1, a2) end
---@param a1 integer
---@return integer
function CPlayer:m_nOldPoint_get(a1) end
---@param a1 integer
---@param a2 integer
function CPlayer:m_nOldPoint_set(a1, a2) end
---@param a1 integer
---@return lightuserdata _MEM_PAST_WHISPER
function CPlayer:m_PastWhiper_get(a1) end
---@param a1 integer
---@return integer
function CPlayer:m_byEffectEquipCode_get(a1) end
---@param a1 integer
---@return lightuserdata CPlayer____target
function CPlayer:m_GroupTargetObject_get(a1) end
---@param a1 integer
---@return integer
function CPlayer:m_wPointRate_PartySend_get(a1) end
---@param a1 integer
---@param a2 integer
---@return number
function CPlayer:m_fGroupMapPoint_get(a1, a2) end
---@param a1 integer
---@param a2 integer
---@param a3 number
function CPlayer:m_fGroupMapPoint_set(a1, a2, a3) end
---@param a1 integer
---@return integer
function CPlayer:m_byGroupMapPointMapCode_get(a1) end
---@param a1 integer
---@param a2 integer
function CPlayer:m_byGroupMapPointMapCode_set(a1, a2) end
---@param a1 integer
---@return integer
function CPlayer:m_wGroupMapPointLayerIndex_get(a1) end
---@param a1 integer
---@param a2 integer
function CPlayer:m_wGroupMapPointLayerIndex_set(a1, a2) end
---@param a1 integer
---@return integer
function CPlayer:m_dwLastGroupMapPointTime_get(a1) end
---@param a1 integer
---@param a2 integer
function CPlayer:m_dwLastGroupMapPointTime_set(a1, a2) end
---@return boolean
function CPlayer:IsApplyPcbangPrimium() end
---@return boolean
function CPlayer:IsChaosMode() end
---@param a1 integer
---@param a2 boolean
---@return boolean
function CPlayer:IsPunished(a1, a2) end
---@return integer
function CPlayer:GetMaxFP() end
---@return integer
function CPlayer:GetFP() end
---@return integer
function CPlayer:GetMaxSP() end
---@return integer
function CPlayer:GetSP() end
---@param a1 boolean
---@param a2 boolean
function CPlayer:ReCalcMaxHFSP(a1, a2) end
---@param a1 integer
---@param a2 integer
---@param a3 integer
---@param a4 boolean
---@param a5 string
---@param a6 integer
---@param a7 string
function CPlayer:SendData_ChatTrans(a1, a2, a3, a4, a5, a6, a7) end
---@return boolean
function CPlayer:IsRidingUnit() end
---@return boolean
function CPlayer:IsSiegeMode() end
---@param a1 integer
---@param a2 integer
---@param a3 integer
---@return integer
function CPlayer:Emb_UpdateStat(a1, a2, a3) end
---@param a1 integer
---@param a2 integer
---@param a3 integer
function CPlayer:SendMsg_StatInform(a1, a2, a3) end
---@param a1 integer
---@param a2 _STORAGE_LIST___storage_con
---@param a3 boolean
---@param a4 boolean
---@return _STORAGE_LIST___db_con
function CPlayer:Emb_AddStorage(a1, a2, a3, a4) end
---@param a1 integer
---@param a2 _STORAGE_LIST___db_con
function CPlayer:SendMsg_TakeNewResult(a1, a2) end
---@param a1 integer
---@param a2 integer
---@param a3 boolean
---@param a4 boolean
---@param a5 string
---@return boolean
function CPlayer:Emb_DelStorage(a1, a2, a3, a4, a5) end
---@param a1 integer
---@param a2 integer
function CPlayer:SendMsg_DeleteStorageInform(a1, a2) end
---@param a1 integer
---@param a2 integer
---@param a3 integer
---@param a4 boolean
---@param a5 boolean
---@return integer
function CPlayer:Emb_AlterDurPoint(a1, a2, a3, a4, a5) end
---@param a1 integer
---@param a2 integer
---@param a3 integer
function CPlayer:SendMsg_AdjustAmountInform(a1, a2, a3) end
---@param a1 number
function CPlayer:AlterDalant(a1) end
---@param a1 number
function CPlayer:AlterGold(a1) end
---@param a1 integer
function CPlayer:SendMsg_AlterMoneyInform(a1) end
---@param a1 integer
---@param a2 integer
function CPlayer:SubActPoint(a1, a2) end
---@param a1 integer
---@param a2 integer
function CPlayer:SendMsg_Alter_Action_Point(a1, a2) end
---@param a1 number
---@param a2 PVP_ALTER_TYPE
---@param a3 integer
function CPlayer:AlterPvPPoint(a1, a2, a3) end
---@param a1 number
---@param a2 PVP_MONEY_ALTER_TYPE
function CPlayer:AlterPvPCashBag(a1, a2) end
---@param a1 number
---@param a2 PVP_ALTER_TYPE
---@param a3 integer
function CPlayer:IncPvPPoint(a1, a2, a3) end
---@param a1 integer
function CPlayer:SetLevel(a1) end
---@param a1 integer
function CPlayer:SetLevelD(a1) end
---@param a1 integer
function CPlayer:AlterMaxLevel(a1) end
---@param a1 integer
---@param a2 integer
---@return integer
function CPlayer:_check_mastery_cum_lim(a1, a2) end
---@param bIncludeSelf boolean
---@return table<integer, CPlayer>
function CPlayer:_GetPartyMemberInCircle(bIncludeSelf) end
---@param pIntoMap CMapData
---@param wLayerIndex integer
---@param byMapOutType integer
---@param to_x number
---@param to_y number
---@param to_z number
---@return boolean
function CPlayer:OutOfMap(pIntoMap, wLayerIndex, byMapOutType, to_x, to_y, to_z) end
---@param a1 _combine_ex_item_result_zocl
function CPlayer:SendMsg_CombineItemExResult(a1) end
---@param a1 _STORAGE_LIST___db_con
---@param a2 integer
function CPlayer:SendMsg_RewardAddItem(a1, a2) end
---@param a1 integer
---@param a2 integer
---@param a3 integer
function CPlayer:SendMsg_AlterItemDurInform(a1, a2, a3) end
---@param byUpgradeType integer
---@param byStorageCode integer
---@param byStorageIndex integer
---@param dwGradeInfo integer
function CPlayer:Emb_ItemUpgrade(byUpgradeType, byStorageCode, byStorageIndex, dwGradeInfo) end
---@param byGetType integer
---@param pItemCon _STORAGE_LIST___db_con
---@param pItemBox? CItemBox
function CPlayer:SendMsg_FanfareItem(byGetType, pItemCon, pItemBox) end
---@param nActCode integer
---@param pszReqCode string
---@param wAddCount integer
---@param bParty boolean
---@return boolean
function CPlayer:Emb_CheckActForQuest(nActCode, pszReqCode, wAddCount, bParty) end
---@param byStorageCode integer
---@param pItem _STORAGE_LIST___db_con
function CPlayer:SendMsg_InsertItemInform(byStorageCode, pItem) end
---@param byMasteryClass integer
---@param byIndex integer
---@param dwAlter integer
---@param byReason integer
---@param strErrorCodePos string
---@param bPcbangPrimiumFavorReward boolean
function CPlayer:Emb_AlterStat(byMasteryClass, byIndex, dwAlter, byReason, strErrorCodePos, bPcbangPrimiumFavorReward) end
---@param pTrap CTrap
---@param wAddSerial integer
function CPlayer:_TrapReturn(pTrap, wAddSerial) end
---@param pTowerCon _STORAGE_LIST___db_con
---@return integer
function CPlayer:_TowerReturn(pTowerCon) end
---@param byErrCode integer
---@param wItemSerial integer
---@param wLeftHP integer
function CPlayer:SendMsg_BackTowerResult(byErrCode, wItemSerial, wLeftHP) end
---@param fEffVal number
function CPlayer:DecHalfSFContDam(fEffVal) end
---@param bAdd boolean
function CPlayer:HideNameEffect(bAdd) end
---@param nMstCode integer
---@param fVal number
---@param bAdd boolean
---@param nWpType integer
function CPlayer:SetMstPt(nMstCode, fVal, bAdd, nWpType) end
---@param nParam integer
---@param fCurVal number
---@param bAdd boolean
function CPlayer:SetEquipJadeEffect(nParam, fCurVal, bAdd) end
---@param bLogout boolean
function CPlayer:ForcePullUnit(bLogout) end
---@param byReturnType integer
function CPlayer:_AnimusReturn(byReturnType) end
---@param dAlterExp number
---@param bReward boolean
---@param bUseExpRecoverItem boolean
---@param bUseExpAdditionItem boolean
function CPlayer:AlterExp(dAlterExp, bReward, bUseExpRecoverItem, bUseExpAdditionItem) end
---@param bySelectQuest integer
---@param pHappenEvent _happen_event_cont
---@return boolean
function CPlayer:Emb_StartQuest(bySelectQuest, pHappenEvent) end
---@param bySelectQuest integer
---@param byRewardIndex integer
---@param byLinkQuestIndex integer
function CPlayer:Emb_CompleteQuest(bySelectQuest, byRewardIndex, byLinkQuestIndex) end
---@param bySlotIndex integer
---@param pQuestDB _QUEST_DB_BASE___LIST
function CPlayer:SendMsg_InsertNextQuest(bySlotIndex, pQuestDB) end
---@param byFailCode integer
---@param bySlotIndex integer
function CPlayer:SendMsg_QuestFailure(byFailCode, bySlotIndex) end
---@param pszEventCode? string
---@param dwNPCQuestIndex integer
---@return boolean
function CPlayer:Emb_CreateNPCQuest(pszEventCode, dwNPCQuestIndex) end
function CPlayer:SendMsg_NpcQuestListResult() end
---@param dbIndex integer
function CPlayer:SendMsg_InsertNewQuest(dbIndex) end
---@param byErrCode integer 0xFE empty box, 0xFD need slots. dwDur of dummy con is how many slots needed,  0xFC success with custom result
---@param pDummmyCon _STORAGE_LIST___db_con
function CPlayer:SendMsg_ExchangeItemResult(byErrCode, pDummmyCon) end
---@param byErrCode integer 0xFE empty box, 0xFD need slots. dwDur of dummy con is how many slots needed,  0xFC success with custom result
---@param pDummmyCon _STORAGE_LIST___db_con
function CPlayer:SendMsg_ExchangeLendItemResult(byErrCode, pDummmyCon) end

---@class (exact) CPlayerDB
---@field m_byPvPGrade integer
---@field m_dbChar _character_db_load
---@field m_dbInven _bag_db_load
---@field m_dbEquip _equip_db_load
---@field m_dbEmbellish _embellish_db_load
---@field m_dbForce _force_db_load
---@field m_dbAnimus _animus_db_load
---@field m_dbTrunk _trunk_db_load
---@field m_dbExtTrunk _Exttrunk_db_load
---@field m_UnitDB _UNIT_DB_BASE
---@field m_QuestDB _QUEST_DB_BASE
---@field m_SFContDB lightuserdata _SFCONT_DB_BASE
---@field m_ItemCombineDB _ITEMCOMBINE_DB_BASE
---@field m_PostStorage lightuserdata CPostStorage
---@field m_ReturnPostStorage lightuserdata CPostReturnStorage
---@field m_bPersonalAmineInven boolean
---@field m_pAPM AutominePersonal
---@field m_dbPersonalAmineInven _personal_amine_inven_db_load
---@field m_byNameLen integer
---@field m_pClassData _class_fld
---@field m_pGuild CGuild
---@field m_pGuildMemPtr _guild_member_info
---@field m_byClassInGuild integer
---@field m_pApplyGuild CGuild
---@field m_bGuildLock boolean
---@field m_bTrunkOpen boolean
---@field m_wszTrunkPasswd string
---@field m_dTrunkDalant number
---@field m_dTrunkGold number
---@field m_byTrunkSlotNum integer
---@field m_byTrunkHintIndex integer
---@field m_wszTrunkHintAnswer string
---@field m_byExtTrunkSlotNum integer
---@field m_byTrunkIteg integer
---@field m_nMakeTrapMaxNum integer
---@field m_dPvpPointLeak number
---@field m_bLastAttBuff boolean
---@field m_dwGuildEntryDelay integer
---@field m_byPlayerInteg integer
---@field m_wSerialCount integer
---@field m_pThis CPlayer
---@field m_aszName string
local CPlayerDB = {}
---@param a1 integer
---@return _STORAGE_LIST
function CPlayerDB:m_pStoragePtr_get(a1) end
---@param a1 integer
---@return integer
function CPlayerDB:m_wCuttingResBuffer_get(a1) end
---@param a1 integer
---@return integer
function CPlayerDB:m_dwAlterMastery_get(a1) end
---@param a1 integer
---@return _class_fld
function CPlayerDB:m_pClassHistory_get(a1) end
---@param a1 integer
---@return _class_fld
function CPlayerDB:m_ppHistoryEffect_get(a1) end
---@param a1 integer
---@return lightuserdata _quick_link
function CPlayerDB:m_QLink_get(a1) end
---@return integer
function CPlayerDB:GetCharSerial() end
---@return number
function CPlayerDB:GetPvPPoint() end
---@return integer
function CPlayerDB:GetRaceCode() end
---@return integer
function CPlayerDB:GetDalant() end
---@return integer
function CPlayerDB:GetGold() end
---@return integer
function CPlayerDB:GetNewItemSerial() end

---@class (exact) CPotionMgr
---@field m_PotionInnerData lightuserdata PotionInnerData
---@field m_tblPotionEffectData CRecordData
---@field m_tblPotionCheckData CRecordData
local CPotionMgr = {}
---@param pApplyPlayer CPlayer
---@param pData _ContPotionData
---@return integer
function CPotionMgr:RemovePotionContEffect(pApplyPlayer, pData) end
---@param pApplyPlayer CPlayer
---@param pContPotionData _ContPotionData
---@param pEffecFld _skill_fld
---@param dwDurTime integer
---@return integer
function CPotionMgr:InsertPotionContEffect(pApplyPlayer, pContPotionData, pEffecFld, dwDurTime) end
---@param pUsePlayer CPlayer
---@param pApplyPlayer CPlayer
---@param pEffecFld _skill_fld
---@param pCheckFld? _CheckPotion_fld
---@param pPotionFld _PotionItem_fld
---@param bCommonPotion boolean
---@return integer
function CPotionMgr:ApplyPotion(pUsePlayer, pApplyPlayer, pEffecFld, pCheckFld, pPotionFld, bCommonPotion) end
---@param pApplyPlayer CPlayer
---@param pEffectFld _skill_fld
function CPotionMgr:SendMsg_InsertPotionContEffect(pApplyPlayer, pEffectFld) end

---@class (exact) CPotionParam
---@field m_StoneOfMovePotionData _ContPotionData
---@field m_pMaster CPlayer
local CPotionParam = {}
---@param a1 integer
---@return _ContPotionData
function CPotionParam:m_ContCommonPotionData_get(a1) end

---@class (exact) CPvpOrderView
---@field m_dwLastAttackTime integer
---@field m_dwLastDamagedTime integer
---@field m_nKillCnt integer
---@field m_nDeahtCnt integer
---@field m_dTodayPvpPoint number
---@field m_dOriginalPvpPoint number
---@field m_dPvpPoint number
---@field m_dPvpTempCash number
---@field m_dPvpCash number
---@field m_bAttack boolean
---@field m_bDamaged boolean
---@field m_pkInfo lightuserdata _PVP_ORDER_VIEW_DB_BASE
local CPvpOrderView = {}
---@return number
function CPvpOrderView:GetPvpTempCash() end
---@param a1 integer
function CPvpOrderView:Update_ContLoseCash(a1) end
---@param a1 integer
---@param a2 number
function CPvpOrderView:Update_PvpTempCash(a1, a2) end
---@param a1 integer
function CPvpOrderView:Update_ContHaveCash(a1) end
---@return number
function CPvpOrderView:GetPvpCash() end

---@class (exact) CPvpUserAndGuildRankingSystem
---@field m_pkLogger CLogFile
---@field m_bInit boolean
---@field m_kUserRankingProcess lightuserdata CUserRankingProcess
---@field Instance fun(): CPvpUserAndGuildRankingSystem
local CPvpUserAndGuildRankingSystem = {}
---@param a1 integer
---@param a2 integer
---@return integer
function CPvpUserAndGuildRankingSystem:GetBossType(a1, a2) end
---@param byRace integer
---@return table<integer, integer>
function CPvpUserAndGuildRankingSystem:GetBossListByRace(byRace) end

---@class (exact) CRecordData
---@field m_bLoad boolean
---@field m_szFileName string
---@field m_dwTotalSize integer
---@field m_Header _record_bin_header
---@field m_nLowNum integer
local CRecordData = {}
---@param nItemIndex integer
---@return _base_fld
---@overload fun(any, szRecordCode: string): _base_fld
---@overload fun(any, szRecordCode: string, nCompareLen: integer): _base_fld
function CRecordData:GetRecord(nItemIndex) end
---@param szRecordCode string
---@param offset integer
---@param len integer
---@return _base_fld
function CRecordData:GetRecordByHash(szRecordCode, offset, len) end

---@class (exact) CItemUpgradeTable
---@field m_tblItemUpgrade CRecordData
---@field m_nResNum integer
local CItemUpgradeTable = {}
---@param index integer
---@return integer
function CItemUpgradeTable:m_pwResIndex_get(index) end
---@param index integer
---@return _ItemUpgrade_fld
function CItemUpgradeTable:GetRecordFromRes(index) end

---@class (exact) CReturnGate: CGameObject
---@field m_eState STATE
---@field m_pkOwner CPlayer
---@field m_dwOwnerSerial integer
---@field m_pDestMap CMapData
---@field m_fBindPos_x number
---@field m_fBindPos_y number
---@field m_fBindPos_z number
---@field m_dwCloseTime integer
local CReturnGate = {}
function CReturnGate:Clear() end
function CReturnGate:Close() end
---@param a1 CPlayer
---@return integer
function CReturnGate:Enter(a1) end
---@return integer
function CReturnGate:GetIndex() end
---@return CPlayer
function CReturnGate:GetOwner() end
---@return boolean
function CReturnGate:IsClose() end
---@return boolean
function CReturnGate:IsOpen() end
---@return boolean
function CReturnGate:IsValidOwner() end
---@param x number
---@param y number
---@param z number
---@return boolean
function CReturnGate:IsValidPosition(x, y, z) end
---@param a1 CReturnGateCreateParam
---@return boolean
function CReturnGate:Open(a1) end
function CReturnGate:SendMsg_Create() end
function CReturnGate:SendMsg_Destroy() end
---@param a1 integer
function CReturnGate:SendMsg_FixPosition(a1) end
---@param a1 CPlayer
function CReturnGate:SendMsg_MovePortal(a1) end

---@class (exact) CReturnGateCreateParam: _object_create_setdata
---@field m_pkOwner CPlayer
local CReturnGateCreateParam = {}
---@return CPlayer
function CReturnGateCreateParam:GetOwner() end

---@class (exact) CTranslationAsset
---@field instance fun(): CTranslationAsset
local CTranslationAsset = {}
---@param pszMsgID string
---@param t table Translation table
function CTranslationAsset:loadTranslationTable(pszMsgID, t) end

---@class (exact) _trap_create_setdata : _character_create_setdata
---@field nHP integer
---@field pMaster CPlayer
---@field nTrapMaxAttackPnt integer
local _trap_create_setdata = {}

---@class (exact) CTrap: CCharacter
---@field m_nHP integer
---@field m_pMaster CPlayer
---@field m_byRaceCode integer
---@field m_dwMasterSerial integer
---@field m_wszMasterName string
---@field m_aszMasterName string
---@field m_dMasterPvPPoint number
---@field m_dwStartMakeTime integer
---@field m_bComplete boolean
---@field m_bBreakTransparBuffer boolean
---@field m_dwLastDestroyTime integer
---@field m_nTrapMaxAttackPnt integer
local CTrap = {}
---@param byDesType integer
---@return boolean
function CTrap:Destroy(byDesType) end

---@class (exact) CUserDB
---@field m_gidGlobal lightuserdata _GLBID
---@field m_idWorld _CLID
---@field m_dwIP integer
---@field m_dwTotalPlayMin integer
---@field m_szAccountID string
---@field m_dwAccountSerial integer
---@field m_ipAddress integer
---@field m_byUserDgr integer
---@field m_bySubDgr integer
---@field m_wszAvatorName string
---@field m_aszAvatorName string
---@field m_dwSerial integer
---@field m_byNameLen integer
---@field m_AvatorData lightuserdata _AVATOR_DATA
---@field m_AvatorData_bk lightuserdata _AVATOR_DATA
---@field m_bActive boolean
---@field m_bField boolean
---@field m_bWndFullMode boolean
---@field m_bDBWaitState boolean
---@field m_pDBPushData lightuserdata _DB_QRY_SYN_DATA
---@field m_bChatLock boolean
---@field m_ss lightuserdata _SYNC_STATE
---@field m_dwOperLobbyTime integer
---@field m_bCreateTrunkFree boolean
---@field m_tmrCheckPlayMin lightuserdata CMyTimer
---@field m_bDataUpdate boolean
---@field m_dwTermContSaveTime integer
---@field m_dwLastContSaveTime integer
---@field m_bNoneUpdateData boolean
---@field m_BillingInfo lightuserdata _BILLING_INFO
---@field m_bBillingNoLogout boolean
---@field m_nTrans integer
---@field m_RadarItemMgr lightuserdata CRadarItemMgr
local CUserDB = {}
---@param a1 CUserDB
---@param a2 integer
---@return lightuserdata _REGED
function CUserDB:m_RegedList_get(a1, a2) end
---@param a1 CUserDB
---@param a2 integer
---@return lightuserdata _NOT_ARRANGED_AVATOR_DB
function CUserDB:m_NotArrangedChar_get(a1, a2) end
---@param a1 CUserDB
---@param a2 integer
---@return integer
function CUserDB:m_dwArrangePassCase0_get(a1, a2) end
---@param a1 integer
---@return integer
function CUserDB:GetActPoint(a1) end
---@param a1 integer
---@param a2 integer
---@return boolean
function CUserDB:Update_User_Action_Point(a1, a2) end
---@param a1 integer
function CUserDB:Update_MaxLevel(a1) end
---@param byStorageCode integer
---@param bySlot integer
---@param qwAmount integer
---@param bUpdate integer
---@return boolean
function CUserDB:Update_ItemDur(byStorageCode, bySlot, qwAmount, bUpdate) end
---@param byStorageCode integer
---@param bySlot integer
---@param dwUpgrade integer
---@param bUpdate integer
---@return boolean
function CUserDB:Update_ItemUpgrade(byStorageCode, bySlot, dwUpgrade, bUpdate) end
---@param bySlotIndex integer
---@return boolean
function CUserDB:Update_QuestDelete(bySlotIndex) end
---@param bySlotIndex integer
---@param pSlotData _QUEST_DB_BASE___LIST
---@return boolean
function CUserDB:Update_QuestInsert(bySlotIndex, pSlotData) end
---@param bySlotIndex integer
---@param pSlotData _QUEST_DB_BASE___LIST
---@param bUpdate boolean
---@return boolean
function CUserDB:Update_QuestUpdate(bySlotIndex, pSlotData, bUpdate) end
---@param pHisData _QUEST_DB_BASE___START_NPC_QUEST_HISTORY
---@return boolean
function CUserDB:Update_StartNPCQuestHistory(pHisData) end
---@param bySlotNum integer
---@return boolean
function CUserDB:Update_TrunkSlotNum(bySlotNum) end
---@param bySlotNum integer
---@return boolean
function CUserDB:Update_ExtTrunkSlotNum(bySlotNum) end
---@param byKickType integer
---@param dwPushIP integer
---@param bSlow boolean
---@param pszReason string
function CUserDB:ForceCloseCommand(byKickType, dwPushIP, bSlow, pszReason) end
---@return boolean
function CUserDB:Lobby_Char_Request() end

---@class (exact) EffectData
---@field m_bExist integer
local EffectData = {}

---@class (exact) ItemCombineMgr
---@field m_pMaster CPlayer
local ItemCombineMgr = {}
---@param a1 _combine_ex_item_result_zocl
---@return integer
function ItemCombineMgr:UpdateDB_CombineResult(a1) end

---@class (exact) _STORAGE_POS
---@field byStorageCode integer
local _STORAGE_POS = {}

---@class (exact) _STORAGE_POS_INDIV : _STORAGE_POS
---@field wItemSerial integer
---@field byNum integer
local _STORAGE_POS_INDIV = {}

---@class (exact) _CLID
---@field wIndex integer
---@field dwSerial integer
local _CLID = {}

---@class (exact) _COMBINEKEY
---@field byRewardIndex integer
---@field byTableCode integer
---@field wItemIndex integer
local _COMBINEKEY = {}
function _COMBINEKEY:SetRelease() end
---@param a1 integer
function _COMBINEKEY:LoadDBKey(a1) end
---@return integer
function _COMBINEKEY:CovDBKey() end
---@return boolean
function _COMBINEKEY:IsFilled() end

---@class (exact) _ContPotionData
---@field m_dwPotionEffectIndex integer
---@field m_dwStartSec integer
---@field m_wDurCapSec integer
---@field m_dwID integer
local _ContPotionData = {}
---@return boolean
function _ContPotionData:IsLive() end
---@return integer
function _ContPotionData:GetEffectIndex() end

---@class (exact) _Exttrunk_db_load: _STORAGE_LIST
local _Exttrunk_db_load = {}
---@param a1 integer
---@return integer
function _Exttrunk_db_load:m_byItemSlotRace_get(a1) end
---@param a1 integer
---@return _STORAGE_LIST___db_con
function _Exttrunk_db_load:m_ExtList_get(a1) end

---@class (exact) _ITEMCOMBINE_DB_BASE
---@field m_bIsResult boolean
---@field m_byItemListNum integer
---@field m_byDlgType integer
---@field m_dwDalant integer
---@field m_dwCheckKey integer
---@field m_bySelectItemCount integer
---@field m_dwResultEffectType integer
---@field m_dwResultEffectMsgCode integer
local _ITEMCOMBINE_DB_BASE = {}
---@param a1 integer
---@return _ITEMCOMBINE_DB_BASE___LIST
function _ITEMCOMBINE_DB_BASE:m_List_get(a1) end
---@param a1 _ITEMCOMBINE_DB_BASE
---@return boolean
function _ITEMCOMBINE_DB_BASE:IsCombineData(a1) end

---@class (exact) _ITEMCOMBINE_DB_BASE___LIST
---@field Key _COMBINEKEY
---@field dwDur integer
---@field dwUpt integer
local _ITEMCOMBINE_DB_BASE___LIST = {}

---@class (exact) _LAYER_SET
---@field m_nSecNum integer
---@field m_pListSectorObj CObjectList
---@field m_pListSectorPlayer CObjectList
---@field m_pListSectorTower CObjectList
---@field m_pMB lightuserdata _MULTI_BLOCK
---@field m_dwStartActiveTime integer
---@field m_dwLastInertTime integer
local _LAYER_SET = {}
---@param a1 integer
---@param a2 integer
---@return lightuserdata _mon_active
function _LAYER_SET:m_MonAct_get(a1, a2) end
---@return boolean
function _LAYER_SET:IsActiveLayer() end

---@class (exact) _MASTERY_PARAM
---@field m_byRaceCode integer
---@field m_BaseCum _STAT_DB_BASE
---@field m_mtySuffer integer
---@field m_mtyShield integer
---@field m_mtyStaff integer
---@field m_mtySpecial integer
---@field m_MastUpData _mastery_up_data
---@field m_SkillUpData _skill_lv_up_data
---@field m_bUpdateEquipMast boolean
local _MASTERY_PARAM = {}
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_dwSkillMasteryCum_get(a1) end
---@param a1 integer
---@param a2 integer
function _MASTERY_PARAM:m_dwSkillMasteryCum_set(a1, a2) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_dwForceLvCum_get(a1) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_mtyWp_get(a1) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_lvSkill_get(a1) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_mtySkill_get(a1) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_mtyForce_get(a1) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_mtyMakeItem_get(a1) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_ppdwMasteryCumPtr_get(a1) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_ppbyMasteryPtr_get(a1) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_ppbyEquipMasteryPrt_get(a1) end
---@param a1 integer
---@param a2 integer
---@return integer
function _MASTERY_PARAM:GetMasteryPerMast(a1, a2) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:GetSkillLv(a1) end
---@param a1 integer
---@param a2 integer
---@return integer
function _MASTERY_PARAM:GetCumPerMast(a1, a2) end
---@param a1 integer
---@param a2 integer
---@param a3 integer
function _MASTERY_PARAM:UpdateCumPerMast(a1, a2, a3) end

---@class (exact) _QUEST_CASH
---@field dwAvatorSerial integer
---@field byQuestType integer
---@field nPvpPoint integer
---@field wKillPoint integer
---@field wDiePoint integer
---@field byCristalBattleDBInfo integer
---@field byHSKTime integer
local _QUEST_CASH = {}

---@class (exact) _QUEST_CASH_OTHER
---@field dwAvatorSerial integer
---@field byStoneMapMoveInfo integer
local _QUEST_CASH_OTHER = {}

---@class (exact) _STAT_DB_BASE
---@field m_dwDefenceCnt integer
---@field m_dwShieldCnt integer
---@field m_dwSpecialCum integer
local _STAT_DB_BASE = {}
---@param a1 integer
---@return integer
function _STAT_DB_BASE:m_dwDamWpCnt_get(a1) end
---@param a1 integer
---@return integer
function _STAT_DB_BASE:m_dwSkillCum_get(a1) end
---@param a1 integer
---@return integer
function _STAT_DB_BASE:m_dwForceCum_get(a1) end
---@param a1 integer
---@return integer
function _STAT_DB_BASE:m_dwMakeCum_get(a1) end

---@class (exact) _STORAGE_LIST
---@field m_nListNum integer
---@field m_nUsedNum integer
---@field m_nListCode integer
local _STORAGE_LIST = {}
---@param a1 integer
---@return _STORAGE_LIST___db_con
function _STORAGE_LIST:m_pStorageList_get(a1) end
---@param a1 integer
---@return _STORAGE_LIST___db_con
function _STORAGE_LIST:GetPtrFromSerial(a1) end
---@return integer
function _STORAGE_LIST:GetNumEmptyCon() end
---@return integer
function _STORAGE_LIST:GetIndexEmptyCon() end
---returns list of used and non locked slots in container. optional client index ascending order possible.
---@param bSort? boolean
---@return table<integer, _STORAGE_LIST___db_con>
function _STORAGE_LIST:GetUseList(bSort) end

---@class (exact) _STORAGE_LIST___db_con: _STORAGE_LIST___storage_con
---@field m_pInList _STORAGE_LIST
---@field m_byStorageIndex integer
local _STORAGE_LIST___db_con = {}

---@alias __ITEM _STORAGE_LIST___db_con

---@class (exact) _STORAGE_LIST___storage_con
---@field m_bLoad integer
---@field m_byTableCode integer
---@field m_byClientIndex integer
---@field m_wItemIndex integer
---@field m_dwDur integer
---@field m_dwLv integer
---@field m_wSerial integer
---@field m_bLock boolean
---@field m_dwETSerialNumber integer
---@field m_lnUID integer
---@field m_byCsMethod integer
---@field m_dwT integer
---@field m_dwLendRegdTime integer
local _STORAGE_LIST___storage_con = {}

---@class (exact) _TOWER_PARAM
---@field m_nCount integer
local _TOWER_PARAM = {}
---@param a1 integer
---@return _TOWER_PARAM___list
function _TOWER_PARAM:m_List_get(a1) end

---@class (exact) _TOWER_PARAM___list
---@field m_pTowerItem _STORAGE_LIST___db_con
---@field m_wItemSerial integer
---@field m_pTowerObj CGuardTower
local _TOWER_PARAM___list = {}

---@class (exact) _TRAP_PARAM
---@field m_nCount integer
local _TRAP_PARAM = {}
---@param a1 integer
---@return _TRAP_PARAM___param
function _TRAP_PARAM:m_Item_get(a1) end

---@class (exact) _TRAP_PARAM___param
---@field pItem CTrap
---@field dwSerial integer
local _TRAP_PARAM___param = {}

---@class (exact) _UNIT_DB_BASE
local _UNIT_DB_BASE = {}
---@param a1 integer
---@return _UNIT_DB_BASE___LIST
function _UNIT_DB_BASE:m_List_get(a1) end

---@class (exact) _UNIT_DB_BASE___LIST
---@field bySlotIndex integer
---@field byFrame integer
---@field dwGauge integer
---@field nPullingFee integer
---@field dwCutTime integer
---@field wBooster integer
local _UNIT_DB_BASE___LIST = {}
---@param a1 integer
---@return integer
function _UNIT_DB_BASE___LIST:byPart_get(a1) end
---@param a1 integer
---@return integer
function _UNIT_DB_BASE___LIST:dwBullet_get(a1) end
---@param a1 integer
---@return integer
function _UNIT_DB_BASE___LIST:dwSpare_get(a1) end

---@class (exact) _WEAPON_PARAM
---@field pFixWp _STORAGE_LIST___db_con
---@field pFixUnit _UNIT_DB_BASE___LIST
---@field nGaMaxAF integer
---@field nGaMinAF integer
---@field byGaMinSel integer
---@field byGaMaxSel integer
---@field nMaMaxAF integer
---@field nMaMinAF integer
---@field byMaMinSel integer
---@field byMaMaxSel integer
---@field byAttTolType integer
---@field byWpClass integer
---@field byWpType integer
---@field wGaAttRange integer
---@field wMaAttRange integer
---@field nActiveType integer
---@field strActiveCode_key string
---@field nActiveEffLvl integer
---@field nActiveProb integer
---@field strEffBulletType string
local _WEAPON_PARAM = {}

---@class (exact) __holy_keeper_data
---@field pCreateMap CMapData
---@field CreateDummy _dummy_position
---@field ActiveDummy _dummy_position
---@field CenterDummy _dummy_position
---@field pRec _monster_fld
local __holy_keeper_data = {}

---@class (exact) __holy_stone_data
---@field pCreateMap CMapData
---@field CreateDummy _dummy_position
---@field pRec _monster_fld
---@field nRace integer
local __holy_stone_data = {}

---@class (exact) _action_node
---@field m_nActType integer
---@field m_strActSub string
---@field m_strActSub2 string
---@field m_strActArea string
---@field m_nReqAct integer
---@field m_nSetCntPro_100 integer
---@field m_strLinkQuestItem string
---@field m_nOrder integer
local _action_node = {}

---@class (exact) _animus_db_load: _STORAGE_LIST
local _animus_db_load = {}
---@param a1 integer
---@return _STORAGE_LIST___db_con
function _animus_db_load:m_List_get(a1) end

---@class (exact) _attack_param
---@field pDst CCharacter
---@field nPart integer
---@field nTol integer
---@field nClass integer
---@field nMinAF integer
---@field nMaxAF integer
---@field nMinSel integer
---@field nMaxSel integer
---@field nExtentRange integer
---@field nShotNum integer
---@field nAddAttPnt integer
---@field nWpType integer
---@field byEffectCode integer
---@field pFld _base_fld
---@field nLevel integer
---@field nMastery integer
---@field bPassCount boolean
---@field nAttactType integer
---@field bMatchless boolean
---@field nMaxAttackPnt integer
---@field bBackAttack boolean
---@field nMinAFPlus integer
---@field nMaxAFPlus integer
---@field nEffShotNum integer
local _attack_param = {}
---@param a1 _attack_param
---@return number
function _attack_param:fArea_x(a1) end
---@param a1 _attack_param
---@return number
function _attack_param:fArea_y(a1) end
---@param a1 _attack_param
---@return number
function _attack_param:fArea_z(a1) end

---@class (exact) _bag_db_load: _STORAGE_LIST
local _bag_db_load = {}
---@param a1 integer
---@return _STORAGE_LIST___db_con
function _bag_db_load:m_List_get(a1) end

---@class (exact) _be_damaged_char
---@field m_pChar CCharacter
---@field m_nDamage integer
---@field m_bActiveSucc boolean
---@field m_nActiveDamage integer
local _be_damaged_char = {}

---@class (exact) _be_damaged_player
---@field m_pChar CCharacter
---@field m_dwDamCharSerial integer
---@field m_nDamage integer
local _be_damaged_player = {}

---@class (exact) _character_db_load
---@field m_wszCharID string
---@field m_dwSerial integer
---@field m_byRaceSexCode integer
---@field m_dwHP integer
---@field m_dwFP integer
---@field m_dwSP integer
---@field m_dwDP integer
---@field m_dExp number
---@field m_dLossExp number
---@field m_dwRank integer
---@field m_wRankRate integer
---@field m_dPvPPoint number
---@field m_dPvPCashBag number
---@field m_byLevel integer
---@field m_dwDalant integer
---@field m_dwGold integer
---@field m_sStartMapCode integer
---@field m_byDftPart_Face integer
---@field m_byUseBagNum integer
---@field m_byMaxLevel integer
local _character_db_load = {}
---@param a1 integer
---@return number
function _character_db_load:m_fStartPos_get(a1) end
---@param a1 integer
---@return integer
function _character_db_load:m_byDftPart_get(a1) end

---@class (exact) _combine_ex_item_request_clzo
---@field wManualIndex integer
---@field byCombineSlotNum integer
---@field bUseNpcLink integer
---@field clientTimeSerial integer
local _combine_ex_item_request_clzo = {}
---@param a1 integer
---@return _combine_ex_item_request_clzo___list
function _combine_ex_item_request_clzo:iCombineSlot_get(a1) end

---@class (exact) _combine_ex_item_request_clzo___list
---@field byStorageCode integer
---@field wItemSerial integer
---@field byAmount integer
local _combine_ex_item_request_clzo___list = {}

---@class (exact) _combine_ex_item_result_zocl
---@field byErrCode integer
---@field byDlgType integer
---@field dwDalant integer
---@field dwCheckKey integer
---@field bySelectItemCount integer
---@field ItemBuff _combine_ex_item_result_zocl___Result_ItemList_Buff
---@field dwResultEffectType integer
---@field dwResultEffectMsgCode integer
local _combine_ex_item_result_zocl = {}

---@class (exact) _combine_ex_item_result_zocl___Result_ItemList_Buff
---@field byItemListNum integer
local _combine_ex_item_result_zocl___Result_ItemList_Buff = {}
---@param a1 integer
---@return _combine_ex_item_result_zocl____item
function _combine_ex_item_result_zocl___Result_ItemList_Buff:RewardItemList_get(a1) end

---@class (exact) _combine_ex_item_result_zocl____item
---@field Key _COMBINEKEY
---@field dwDur integer
---@field dwUpt integer
local _combine_ex_item_result_zocl____item = {}

---@class (exact) _consume_item_list
---@field m_itmNeedItemCode string
---@field m_nNeedItemCount integer
local _consume_item_list = {}

---@class (exact) _cont_param_list
---@field m_nContParamCode integer
---@field m_nContParamIndex integer
local _cont_param_list = {}
---@param a1 integer
---@return number
function _cont_param_list:m_fContValue_get(a1) end

---@class (exact) _dummy_position
---@field m_szCode string
---@field m_wLineIndex integer
---@field m_bPosAble boolean
---@field m_wActiveMon integer
local _dummy_position = {}
---@param a1 integer
---@return integer
function _dummy_position:m_zLocalMin_get(a1) end
---@param a1 integer
---@param a2 integer
function _dummy_position:m_zLocalMin_set(a1, a2) end
---@param a1 integer
---@return integer
function _dummy_position:m_zLocalMax_get(a1) end
---@param a1 integer
---@param a2 integer
function _dummy_position:m_zLocalMax_set(a1, a2) end
---@param a1 integer
---@return number
function _dummy_position:m_fMin_get(a1) end
---@param a1 integer
---@param a2 number
function _dummy_position:m_fMin_set(a1, a2) end
---@param a1 integer
---@return number
function _dummy_position:m_fMax_get(a1) end
---@param a1 integer
---@param a2 number
function _dummy_position:m_fMax_set(a1, a2) end
---@param a1 integer
---@return number
function _dummy_position:m_fRT_get(a1) end
---@param a1 integer
---@param a2 number
function _dummy_position:m_fRT_set(a1, a2) end
---@param a1 integer
---@return number
function _dummy_position:m_fLB_get(a1) end
---@param a1 integer
---@param a2 number
function _dummy_position:m_fLB_set(a1, a2) end
---@param a1 integer
---@return number
function _dummy_position:m_fCenterPos_get(a1) end
---@param a1 integer
---@param a2 number
function _dummy_position:m_fCenterPos_set(a1, a2) end
---@param a1 integer
---@return number
function _dummy_position:m_fDirection_get(a1) end
---@param a1 integer
---@param a2 number
function _dummy_position:m_fDirection_set(a1, a2) end

---@class (exact) _effect_parameter
---@field m_pDataParam lightuserdata _effect_parameter____param_data
---@field m_bLock boolean
local _effect_parameter = {}
---@param a1 integer
---@return number
function _effect_parameter:GetEff_Rate(a1) end
---@param a1 integer
---@return number
function _effect_parameter:GetEff_Plus(a1) end
---@param a1 integer
---@return boolean
function _effect_parameter:GetEff_State(a1) end
---@param a1 integer
---@return number
function _effect_parameter:GetEff_Have(a1) end
---@param a1 integer
---@param a2 number
---@param a3 boolean
---@return boolean
function _effect_parameter:SetEff_Rate(a1, a2, a3) end
---@param a1 integer
---@param a2 number
---@param a3 boolean
---@return boolean
function _effect_parameter:SetEff_Plus(a1, a2, a3) end
---@param a1 integer
---@param a2 boolean
---@return boolean
function _effect_parameter:SetEff_State(a1, a2) end

---@class (exact) _embellish_db_load: _STORAGE_LIST
local _embellish_db_load = {}
---@param a1 integer
---@return _STORAGE_LIST___db_con
function _embellish_db_load:m_List_get(a1) end

---@class (exact) _equip_db_load: _STORAGE_LIST
local _equip_db_load = {}
---@param a1 integer
---@return _STORAGE_LIST___db_con
function _equip_db_load:m_List_get(a1) end

---@class (exact) _force_db_load: _STORAGE_LIST
local _force_db_load = {}
---@param a1 integer
---@return _STORAGE_LIST___db_con
function _force_db_load:m_List_get(a1) end

---@class (exact) _happen_event_condition_node
---@field m_nCondType integer
---@field m_nCondSubType integer
---@field m_sCondVal string
local _happen_event_condition_node = {}

---@class (exact) _happen_event_node
---@field m_bUse integer
---@field m_bQuestRepeat integer
---@field m_nQuestType integer
---@field m_bSelectQuestManual integer
---@field m_nAcepProNum integer
---@field m_nAcepProDen integer
local _happen_event_node = {}
---@param a1 integer
---@return _happen_event_condition_node
function _happen_event_node:m_CondNode_get(a1) end
---@param a1 integer
---@return string
function _happen_event_node:m_strLinkQuest_get(a1) end

---@class (exact) _mastery_lim_data
---@field m_nBnsSMastery integer
---@field m_nBnsDefMastery integer
---@field m_nBnsPryMastery integer
local _mastery_lim_data = {}
---@param a1 integer
---@return integer
function _mastery_lim_data:m_nBnsMMastery_get(a1) end
---@param a1 integer
---@return integer
function _mastery_lim_data:m_nBnsMakeMastery_get(a1) end
---@param a1 integer
---@return integer
function _mastery_lim_data:m_nBnsSkillMastery_get(a1) end
---@param a1 integer
---@return integer
function _mastery_lim_data:m_nBnsForceMastery_get(a1) end

---@class (exact) _mastery_up_data
---@field bUpdate boolean
---@field byCode integer
---@field byIndex integer
---@field byMastery integer
local _mastery_up_data = {}

---@class (exact) _object_create_setdata
---@field m_pRecordSet _base_fld
---@field m_pMap CMapData
---@field m_nLayerIndex integer
---@field m_fStartPos_x number
---@field m_fStartPos_y number
---@field m_fStartPos_z number
local _object_create_setdata = {}

---@class (exact) _object_id
---@field m_byKind integer
---@field m_byID integer
---@field m_wIndex integer
local _object_id = {}

---@class (exact) _object_list_point
---@field m_pItem CGameObject
---@field m_pNext _object_list_point
---@field m_pPrev _object_list_point
local _object_list_point = {}

---@class (exact) _personal_amine_inven_db_load: _STORAGE_LIST
local _personal_amine_inven_db_load = {}
---@param a1 integer
---@return _STORAGE_LIST___db_con
function _personal_amine_inven_db_load:m_List_get(a1) end

---@class (exact) _portal_dummy
---@field m_pPortalRec _portal_fld
---@field m_pDumPos _dummy_position
local _portal_dummy = {}

---@class (exact) _quest_fail_condition
---@field m_nFailCondition integer
---@field m_strFailCode string
local _quest_fail_condition = {}

---@class (exact) _quest_reward_item
---@field m_strConsITCode string
---@field m_nConsITCnt integer
---@field m_nLinkQuestIdx integer
local _quest_reward_item = {}

---@class (exact) _quest_reward_mastery
---@field m_nConsMasteryID integer
---@field m_nConsMasterySubID integer
---@field m_nConsMasteryCnt integer
local _quest_reward_mastery = {}

---@class (exact) _record_bin_header
---@field m_nRecordNum integer
---@field m_nFieldNum integer
---@field m_nRecordSize integer
local _record_bin_header = {}

---@class (exact) _sec_info
---@field m_nSecNumW integer
---@field m_nSecNumH integer
---@field m_nSecNum integer
local _sec_info = {}

---@class (exact) _sf_continous
---@field m_bExist boolean
---@field m_byEffectCode integer
---@field m_wEffectIndex integer
---@field m_byLv integer
---@field m_dwStartSec integer
---@field m_wDurSec integer
---@field m_dwEffSerial integer
---@field m_nCumulCounter integer
---@field m_dwPlayerSerial integer
---@field m_wszPlayerName string
local _sf_continous = {}

---@class (exact) _sf_continous_ex
---@field m_bExist boolean
---@field m_byLv integer
---@field m_byCumulCounter integer
---@field m_byEffectCode integer
---@field m_dwEffectIndex integer
---@field m_dwDurSec integer
---@field m_dwEffSerial integer
---@field m_tmApplyTime integer
---@field m_tmEndTime integer
local _sf_continous_ex = {}

---@class (exact) _skill_lv_up_data
---@field bUpdate boolean
---@field wIndex integer
---@field byLv integer
local _skill_lv_up_data = {}

---@class (exact) _trunk_db_load: _STORAGE_LIST
local _trunk_db_load = {}
---@param a1 integer
---@return integer
function _trunk_db_load:m_byItemSlotRace_get(a1) end
---@param a1 integer
---@return _STORAGE_LIST___db_con
function _trunk_db_load:m_List_get(a1) end

---@class (exact) cStaticMember_Player
---@field _nMaxLv integer
---@field Instance fun(): cStaticMember_Player
local cStaticMember_Player = {}
---@param a1 integer
---@return number
function cStaticMember_Player:_pLimExp_get(a1) end

---@class (exact) effect_parameter____param_data
local effect_parameter____param_data = {}
---@param a1 integer
---@return number
function effect_parameter____param_data:m_fEff_Rate_get(a1) end
---@param a1 integer
---@param a2 number
function effect_parameter____param_data:m_fEff_Rate_set(a1, a2) end
---@param a1 integer
---@return number
function effect_parameter____param_data:m_fEff_Plus_get(a1) end
---@param a1 integer
---@param a2 number
function effect_parameter____param_data:m_fEff_Plus_set(a1, a2) end
---@param a1 integer
---@return integer
function effect_parameter____param_data:m_bEff_State_get(a1) end
---@param a1 integer
---@param a2 integer
function effect_parameter____param_data:m_bEff_State_set(a1, a2) end
---@param a1 integer
---@return number
function effect_parameter____param_data:m_fEff_Have_get(a1) end
---@param a1 integer
---@param a2 number
function effect_parameter____param_data:m_fEff_Have_set(a1, a2) end

---@class (exact) sell_info
---@field m_strStore_NPCcode string
---@field m_nMaxCount integer
local sell_info = {}

---@class (exact) CGameStatistics___map
---@field pMapName string
---@field dwMaxHourPerMap_Hour integer
local CGameStatistics___map = {}

---@class (exact) CGameStatistics___DAY
---@field dwEderEnter_Evt integer
---@field dwMaxUserHour_Hour integer
---@field dwMaxUser_Hour integer
---@field MaxHourPerMap_Hour_get fun(index: integer): CGameStatistics___map
---@field dwDropStdItem_Evt integer
---@field dwDropRareItem_Evt integer
---@field dw4MuUpgradeSucc_Evt integer
---@field dw4EunUpgradeSucc_Evt integer
---@field dw4JaUpgradeSucc_Evt integer
---@field dw5MuUpgradeSucc_Evt integer
---@field dw5EunUpgradeSucc_Evt integer
---@field dw5JaUpgradeSucc_Evt integer
---@field dwDaePokUse_Evt integer
local CGameStatistics___DAY = {}

---@class (exact) CGameStatistics
---@field m_day CGameStatistics___DAY
local CGameStatistics = {}
---@return CGameStatistics___DAY
function CGameStatistics:CurWriteData() end

---@class (exact) CMgrAvatorItemHistory
---@field Instance fun(): CMgrAvatorItemHistory
local CMgrAvatorItemHistory = {}
---@param pPlayer CPlayer
---@param pItemCon _STORAGE_LIST___db_con
---@param pTalikCon _STORAGE_LIST___db_con
---@param ppJewelCon table<integer, _STORAGE_LIST___db_con>
---@param byErrCode integer
---@param dwAfterLv integer
function CMgrAvatorItemHistory:grade_up_item(pPlayer, pItemCon, pTalikCon, ppJewelCon, byErrCode, dwAfterLv) end
---@param pPlayer CPlayer
---@param byMakeNum integer
---@param pCombineDB _ITEMCOMBINE_DB_BASE
---@param pbyRewardTypeList table<integer, integer>
---@param plnUUIDs table<integer, integer>
function CMgrAvatorItemHistory:combine_ex_reward_item(pPlayer, byMakeNum, pCombineDB, pbyRewardTypeList, plnUUIDs) end
---@param pPlayer CPlayer
---@param pMaterial table<integer, _STORAGE_LIST___db_con>
---@param pbyMtrNum table<integer, integer>
---@param byRetCode integer
---@param bInsert boolean
---@param pMakeItem _STORAGE_LIST___db_con
function CMgrAvatorItemHistory:make_item(pPlayer, pMaterial, pbyMtrNum, byRetCode, bInsert, pMakeItem) end
---@param pPlayer CPlayer
---@param byRetCode integer
---@param pMakeItem _STORAGE_LIST___db_con
function CMgrAvatorItemHistory:cheat_make_item_no_material(pPlayer, byRetCode, pMakeItem) end

---@class (exact) _100_per_random_table
---@field m_wCurTable integer
---@field m_wCurPoint integer
local _100_per_random_table = {}
---@return integer
function _100_per_random_table:GetRand() end

---@class (exact) CParkingUnit : CGameObject
---@field m_pOwner CPlayer
---@field m_dwOwnerSerial integer
---@field m_byFrame integer
---@field m_byCreateType integer
---@field m_byTransDistCode integer
---@field m_dwParkingStartTime integer
---@field m_wHPRate integer
---@field m_dwLastDestroyTime integer
local CParkingUnit = {}
---@param index integer
---@return integer
function CParkingUnit:m_byPartCode_get(index) end

---@class (exact) CPlayerAttack : CAttack
---@field m_pAttPlayer CPlayer
local CPlayerAttack = {}

---@class (exact) CMonsterAttack : CAttack
---@field m_pAttMonster CMonster
local CMonsterAttack = {}

---@class (exact) CPlayer____target
---@field pObject CGameObject
---@field byKind integer
---@field byID integer
---@field dwSerial integer
---@field wHPRate integer
local CPlayer____target = {}

---@class (exact) CExpInfo
---@field m_fExp number
---@field m_pkMember CPlayer
local CExpInfo = {}

---@class (exact) CPartyModeKillMonsterExpNotify
---@field m_bKillMonster boolean
---@field m_byMemberCnt integer
local CPartyModeKillMonsterExpNotify = {}
---@param index integer
---@return CExpInfo
function CPartyModeKillMonsterExpNotify:m_kInfo_get(index) end
---@param pPartyPlayer CPlayer
---@param fExp number
---@return boolean
function CPartyModeKillMonsterExpNotify:Add(pPartyPlayer, fExp) end

---@class (exact) _guild_member_info
---@field dwSerial integer
---@field wszName string
---@field byClassInGuild integer
---@field byLv integer
---@field dwPvpPoint integer
---@field byRank integer
---@field byGrade integer
---@field pPlayer CPlayer
---@field bVote boolean
local _guild_member_info = {}

---@class (exact) _guild_master_info
---@field dwSerial integer
---@field byPrevGrade integer
---@field pMember _guild_member_info
local _guild_master_info = {}

---@class (exact) _io_money_data
---@field wszIOerName string
---@field dwIOerSerial integer
---@field dIODalant number
---@field dIOGold number
---@field dLeftDalant number
---@field dLeftGold number
local _io_money_data = {}
---@param i integer
---@return integer
function _io_money_data:byDate_get(i) end

---@class (exact) _guild_applier_info
---@field pPlayer CPlayer
---@field dwApplyTime integer
local _guild_applier_info = {}

---@class (exact) CExtPotionBuf
---@field m_bExtPotionBufUse boolean
---@field m_bDayChange boolean
---@field m_dwEndPotionTime integer
local CExtPotionBuf = {}

---@class (exact) CGuild
---@field m_nIndex integer
---@field m_dwSerial integer
---@field m_wszName string
---@field m_aszName string 
---@field m_byGrade integer
---@field m_dTotalDalant number
---@field m_dTotalGold number
---@field m_dwEmblemBack integer
---@field m_dwEmblemMark integer
---@field m_byRace integer
---@field m_wszGreetingMsg string
---@field m_MasterData _guild_master_info
---@field m_nMemberNum integer
---@field m_nApplierNum integer
---@field m_bNowProcessSgtMter boolean
---@field m_dwSuggesterSerial integer
---@field m_SuggestedMatter lightuserdata
---@field m_GuildBattleSugestMatter lightuserdata
---@field m_bInGuildBattle boolean
---@field m_bPossibleElectMaster boolean
---@field m_dwGuildBattleTotWin integer
---@field m_dwGuildBattleTotDraw integer
---@field m_dwGuildBattleTotLose integer
---@field m_DownPacket_Member lightuserdata
---@field m_DownPacket_Applier lightuserdata
---@field m_QueryPacket_Info lightuserdata
---@field m_MoneyIO_List lightuserdata
---@field m_Buddy_List lightuserdata
---@field m_nIOMoneyHistoryNum integer
---@field m_bDBWait boolean
---@field m_bIOWait boolean
---@field m_bRankWait boolean
---@field m_byMoneyOutputKind integer
---@field m_nTempMemberNum integer
---@field m_dwLastLoopTime integer
---@field m_szHistoryFileName string
local CGuild = {}
---@param i integer
---@return _guild_member_info
function CGuild:m_MemberData_get(i) end
---@param i integer
---@return _guild_member_info
function CGuild:m_pGuildCommittee_get(i) end
---@param i integer
---@return _guild_applier_info
function CGuild:m_ApplierData_get(i) end
---@param i integer
---@return _io_money_data
function CGuild:m_IOMoneyHistory_get(i) end
---@return table<integer, _guild_member_info>
function CGuild:GetGuildMemberList() end
---@return table<integer, _guild_applier_info>
function CGuild:GetGuildApplierList() end

---@class (exact) CLootingMgr___list
---@field pAtter CPlayer
---@field dwAtterSerial integer
---@field dwAttCount integer
---@field dwDamage integer
---@field dwLastAttTime integer
local CLootingMgr___list = {}

---@class (exact) CLootingMgr
---@field m_bFirst boolean
---@field m_byUserNode integer
local CLootingMgr = {}
---@param i integer
---@return CLootingMgr___list
function CLootingMgr:m_AtterList_get(i) end

---@class (exact) _QUEST_DB_BASE___LIST
---@field byQuestType integer
---@field wIndex integer
---@field dwPassSec integer
local _QUEST_DB_BASE___LIST = {}
---@param i integer
---@return integer
function _QUEST_DB_BASE___LIST:wNum_get(i) end
---@param i integer
---@param val integer
function _QUEST_DB_BASE___LIST:wNum_set(i, val) end
---@return table<integer, integer>
function _QUEST_DB_BASE___LIST:GetNumList() end

---@class (exact) _QUEST_DB_BASE___NPC_QUEST_HISTORY
---@field szQuestCode string
---@field nEventNo integer
---@field byLevel integer
---@field dwEventEndTime integer
local _QUEST_DB_BASE___NPC_QUEST_HISTORY = {}

---@class (exact) _QUEST_DB_BASE___START_NPC_QUEST_HISTORY
---@field szQuestCode string for Data located in CPlayerDB class this field not used
---@field pQuestFld _Quest_fld for Data located in CUserDB class this field not used
---@field byLevel integer
---@field nEndTime integer
local _QUEST_DB_BASE___START_NPC_QUEST_HISTORY = {}
---@return integer
function _QUEST_DB_BASE___START_NPC_QUEST_HISTORY:tmStartTime() end

---@class (exact) _QUEST_DB_BASE
---@field dwListCnt integer
local _QUEST_DB_BASE = {}
---@param i integer
---@return _QUEST_DB_BASE___LIST
function _QUEST_DB_BASE:m_List_get(i) end
---@return table<integer, _QUEST_DB_BASE___LIST>
function _QUEST_DB_BASE:GetActiveQuestList() end
---@param i integer
---@return _QUEST_DB_BASE___NPC_QUEST_HISTORY
function _QUEST_DB_BASE:m_History_get(i) end
---@param i integer
---@return _QUEST_DB_BASE___START_NPC_QUEST_HISTORY
function _QUEST_DB_BASE:m_StartHistory_get(i) end
---@return table<integer, _QUEST_DB_BASE___START_NPC_QUEST_HISTORY>
function _QUEST_DB_BASE:GetStartHistoryList() end

---@class (exact) CQuestMgr
---@field m_pMaster CPlayer
---@field m_pQuestData _QUEST_DB_BASE
---@field m_LastHappenEvent _happen_event_cont
---@field m_dwOldTimeoutChecktime integer
local CQuestMgr = {}
---@param i integer
---@return _happen_event_cont
function CQuestMgr:m_pTempHappenEvent_get(i) end
---@param pszQuestCode string
---@return boolean #returns true if pszQuestCode present in active quest list. Only for quest type 1.
function CQuestMgr:IsProcNpcQuest(pszQuestCode) end
---@param nLinkQuestGroupID integer
---@return boolean #returns false if nLinkQuestGroupID > 0 and present in active quest list. IsProcLinkNpcQuest
function CQuestMgr:IsProcLinkNpcQuest(nLinkQuestGroupID) end
---@param bySlotIndex integer
function CQuestMgr:DeleteQuestData(bySlotIndex) end
---@param pszEventCode string
---@param byRaceCode integer
---@param pQuestIndexData _NPCQuestIndexTempData
function CQuestMgr:CheckNPCQuestList(pszEventCode, byRaceCode, pQuestIndexData) end
---@param pszQuestCode string
---@param nLinkQuestGroupID integer
---@return boolean
function CQuestMgr:IsPossibleRepeatNpcQuest(pszQuestCode, nLinkQuestGroupID) end
---@param byQuestDBSlot integer
---@return boolean
function CQuestMgr:CanGiveupQuest(byQuestDBSlot) end
---@param pCond _happen_event_condition_node
---@return boolean
function CQuestMgr:_CheckCondition(pCond) end

---@class (exact) _NPCQuestIndexTempData___IndexData
---@field dwQuestHappenIndex integer
---@field dwQuestIndex integer
local _NPCQuestIndexTempData___IndexData = {}

---@class (exact) _NPCQuestIndexTempData
---@field nQuestNum integer
local _NPCQuestIndexTempData = {}
---@param a integer
---@return _NPCQuestIndexTempData___IndexData
function _NPCQuestIndexTempData:IndexData_get(a) end
function _NPCQuestIndexTempData:Init() end

---@class (exact) _INVENKEY
---@field bySlotIndex integer
---@field byTableCode integer
---@field wItemIndex integer
local _INVENKEY = {}

---@class (exact) _good_storage_info
---@field byItemTableCode integer
---@field wItemIndex integer
---@field bExist boolean
---@field byMoneyUnit integer
---@field nStdPrice integer
---@field nStdPoint integer
---@field nGoldPoint integer
---@field nKillPoint integer
---@field nResPoint integer
---@field dwDurPoint integer
---@field dwUpCode integer
---@field byType integer
---@field dwLimitIndex integer
local _good_storage_info = {}

---@class (exact) _buy_offer
---@field byGoodIndex integer
---@field byGoodAmount integer
---@field byStorageCode integer
---@field Item _STORAGE_LIST___db_con
---@field wSerial integer
local _buy_offer = {}

---@class (exact) _sell_offer
---@field pItem _STORAGE_LIST___db_con
---@field byAmount integer
---@field bySlotIndex integer
---@field byStorageCode integer
local _sell_offer = {}

---@class (exact) _limit_item_info
---@field bLoad boolean
---@field dwStorageIndex integer
---@field nLimitNum integer
---@field Key _INVENKEY
local _limit_item_info = {}

---@class (exact) CItemStore
---@field m_bLive boolean
---@field m_nIndex integer
---@field m_dwSecIndex integer
---@field m_byNpcRaceCode integer
---@field m_pExistMap CMapData
---@field m_pDum _store_dummy
---@field m_pRec _StoreList_fld
---@field m_nStorageItemNum integer
---@field m_dwLimitInitTime integer
---@field m_bDBDataCheck boolean
---@field m_dwDBSerial integer
---@field m_nLimitStorageItemNum integer
---@field m_bUpdate boolean
---@field m_dwLastTradeDalant integer not used
---@field m_dwLastTradeGold integer not used
---@field m_dwLastTradePoint integer not used
local CItemStore = {}
---not used
---@param i integer
---@return integer
function CItemStore:m_dwLastTradeActPoint_get(i) end
---@return table<integer, _good_storage_info>
function CItemStore:GetStoreList() end
---@return table<integer, _limit_item_info>
function CItemStore:GetLimitStoreList() end

---@class (exact) _Select_ItemList_buff
---@field bySelectNum integer
local _Select_ItemList_buff = {}
---@param i integer
---@return integer
function _Select_ItemList_buff:bySelectIndexList_get(i) end

---@class (exact) _combine_ex_item_accept_request_clzo
---@field byDlgType integer
---@field dwCheckKey integer
---@field SelectItemBuff _Select_ItemList_buff
local _combine_ex_item_accept_request_clzo = {}

---@class (exact) _combine_ex_item_accept_result_zocl
---@field byErrCode integer
local _combine_ex_item_accept_request_clzo = {}

---@class (exact) _store_dummy
---@field m_nStoreType integer
---@field m_pStoreRec _base_fld
---@field m_pDumPos _dummy_position
local _store_dummy = {}

---@class (exact) CLogFile
---@field m_szFileName string
---@field m_dwLogCount integer
---@field m_bWriteAble integer
---@field m_bAddCount boolean
---@field m_bDate boolean
---@field m_bTrace boolean
---@field m_bInit boolean
local CLogFile = {}
---@param str string
function CLogFile:Write(str) end
---@param file_name string
---@param bWritable integer
---@param bTrace boolean
---@param bDate boolean
---@param bAddCount boolean
function CLogFile:SetWriteLogFile(file_name, bWritable, bTrace, bDate, bAddCount) end

Sirin.NATS = NATS
Sirin.UUIDv4 = UUIDv4
Sirin.CAssetController = CAssetController
Sirin.CLanguageAsset = CLanguageAsset
Sirin.CTranslationAsset = CTranslationAsset
Sirin.luaThreadManager = luaThreadManager
Sirin.console = console
Sirin.mainThread = mainThread
Sirin.mainThread.modChargeItem = modChargeItem
Sirin.mainThread.modContEffect = modContEffect
Sirin.mainThread.modReturnGate = modReturnGate
Sirin.mainThread.modItemPropertySkin = modItemPropertySkin
Sirin.mainThread.modPotionEffect = modPotionEffect
Sirin.mainThread.modButtonExt = modButtonExt
Sirin.mainThread.modStackExt = modStackExt
Sirin.mainThread.modGuardTowerController = modGuardTowerController
Sirin.mainThread.modQuestHistory = modQuestHistory
Sirin.mainThread.modBoxOpen = modBoxOpen
Sirin.mainThread.modInfinitePotion = modInfinitePotion
Sirin.mainThread.modRaceSexClassChange = modRaceSexClassChange
Sirin.mainThread.modForceLogoutAfterUsePotion = modForceLogoutAfterUsePotion
Sirin.mainThread.g_pAttack = CAttack
Sirin.mainThread.g_HolySys = CHolyStoneSystem
Sirin.mainThread.g_Main = CMainThread
Sirin.mainThread.g_MapOper = CMapOperation
Sirin.mainThread.g_PotionMgr = CPotionMgr
Sirin.mainThread.g_GameStatistics = CGameStatistics
Sirin.mainThread.CMgrAvatorItemHistory = CMgrAvatorItemHistory
Sirin.mainThread.CLuaSendBuffer = CLuaSendBuffer
Sirin.mainThread.cStaticMember_Player = cStaticMember_Player
Sirin.mainThread.CPvpUserAndGuildRankingSystem = CPvpUserAndGuildRankingSystem
Sirin.mainThread.CActionPointSystemMgr = CActionPointSystemMgr
