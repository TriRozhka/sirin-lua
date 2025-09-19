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
---@field processAsyncCallback fun(qwDelay:integer, strThreadID: string, strNameSpace: string, strFuncName: string, ...)
---@field processAsyncPoolCallback fun(qwDelay:integer, dwPoolID: integer, strThreadID: string, strNameSpace: string, strFuncName: string, ...)
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
---@field CBinaryData fun(size: integer): CBinaryData
---@field CSQLResultSet fun(size: integer): CSQLResultSet
---@field CMultiBinaryData fun(): CMultiBinaryData
---@field CMultiSQLResultSet fun(): CMultiSQLResultSet
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
---@field _100_per_random_table _100_per_random_table
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
---@field g_Monster_get fun(nIndex: integer): CMonster
---@field getActiveMonsters fun(strMapCode?: string, nLayerIndex?: integer): table<integer, CMonster>
---@field objectToMonster fun(this: CGameObject): CMonster
---@field objectToNuclearBomb fun(this: CGameObject): CNuclearBomb
---@field g_Player_get fun(nIndex: integer): CPlayer
---@field g_Stone_get fun(nIndex: integer): CHolyStone
---@field getPlayerBySerial fun(integer): CPlayer
---@field getActivePlayers fun(): table<integer, CPlayer>
---@field objectToPlayer fun(this: CGameObject): CPlayer
---@field CQuestMgr__s_tblQuestHappenEvent_get fun(nIndex: integer): CRecordData
---@field CQuestMgr__s_tblQuest fun(): CRecordData
---@field s_QuestCKRet _quest_check_result
---@field objectToReturnGate fun(this: CGameObject): CReturnGate
---@field objectToTrap fun(this: CGameObject): CTrap
---@field g_UserDB_get fun(nIndex: integer): CUserDB
---@field getAccountBySerial fun(integer): CUserDB
---@field getActiveAccounts fun(): table<integer, CUserDB>
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
---@field createItemBox fun(strItemCode: string, dwUpgrade: integer, qwDurPoint: integer, dwLendTime: integer, byCreateCode: integer, pMap: CMapData, wLayerIndex: integer, fPosX: number, fPosY: number, fPosZ: number, dwRange: integer, bHide: boolean, pOwner?: CPlayer, bPartyShare: boolean, pThrower?: CCharacter, pAttacker?: CPlayer, byEventItemLootAuth: integer, bHolyScanner: boolean): CItemBox?
---@field createItemBox_Monster fun(pBox?: CItemBox, byTableCode: integer, pFld: _base_fld, qwDurPoint: integer, byCreateCode: integer, pMap: CMapData, wLayerIndex: integer, fPosX: number, fPosY: number, fPosZ: number, dwRange: integer, bHide: boolean, dwOwnerObjSerial: integer, wOwnerObjIndex: integer, dwThrowerObjSerial: integer, wThrowerObjIndex: integer, pMonRec: _monster_fld): CItemBox?
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
---@field AlterCashAsync fun(dwAccountSerial: integer, nAlterValue: integer, strParam: string): boolean
---@field g_Guild_get fun(nIndex: integer): CGuild
---@field _happen_event_cont fun(): _happen_event_cont
---@field TimeItem__FindTimeRec fun(nTblCode: integer, nIndex: integer): _TimeItem_fld
---@field GetActiveGuildList fun(): table<integer, CGuild>
---@field GetGuildBySerial fun(dwSerial: integer): CGuild
---@field GuildPushMoney fun(pGuild: CGuild, dwAddDalant: integer, dwAddGold: integer, byIOType: integer, dwIOerSerial, pszIOerName): boolean
---@field GuildPopMoney fun(pGuild: CGuild, dwSubDalant: integer, dwSubGold: integer, byIOType: integer, dwIOerSerial, pszIOerName): boolean
---@field _QUEST_DB_BASE___START_NPC_QUEST_HISTORY fun(): _QUEST_DB_BASE___START_NPC_QUEST_HISTORY
---@field _attack_param fun(): _attack_param
---@field _guild_honor_set_request_clzo fun(): _guild_honor_set_request_clzo
---@field CProtoDataObject fun(): CProtoDataObject
---@field CloseConnect fun(dwSocket: integer, strReason?: string)
---@field electProcessorToVoter fun(electProc: ElectProcessor): Voter
---@field electProcessorToCandidateRegister fun(electProc: ElectProcessor): CandidateRegister
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
---@field modRaceBossChipHolderBonus modRaceBossChipHolderBonus
---@field modNetwork modNetwork
---@field g_pAttack CAttack
---@field g_dwAttType integer
---@field g_HolySys CHolyStoneSystem
---@field g_Main CMainThread
---@field g_MapOper CMapOperation
---@field g_PotionMgr CPotionMgr
---@field g_GameStatistics CGameStatistics
---@field g_Keeper CHolyKeeper
---@field CMgrAvatorItemHistory CMgrAvatorItemHistory
---@field CLuaSendBuffer CLuaSendBuffer
---@field cStaticMember_Player cStaticMember_Player
---@field CPvpUserAndGuildRankingSystem CPvpUserAndGuildRankingSystem
---@field CActionPointSystemMgr CActionPointSystemMgr
---@field CNuclearBombMgr CNuclearBombMgr
---@field CGuildRoomSystem CGuildRoomSystem
---@field CHonorGuild CHonorGuild
---@field CandidateMgr CandidateMgr
---@field PatriarchElectProcessor PatriarchElectProcessor
---@field CWeeklyGuildRankManager CWeeklyGuildRankManager
local mainThread = {}

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
---@field RegisterAsset fun(): boolean
local modButtonExt = {}

---@class (exact) modStackExt
---@field GetStackSize fun(): integer
local modStackExt = {}

---@class (exact) modGuardTowerController
---@field createGuardTower fun(pMap: CMapData, wLayer: integer, x: number, y: number, z: number, pItem: _STORAGE_LIST___db_con, pMaster: CPlayer, byRace: integer, bQuick: boolean): CGuardTower
---@field createSystemTower fun(pMap: CMapData, wLayer: integer, x: number, y: number, z: number, nTowerIndex: integer, byRace: integer, nINIindex: integer): CGuardTower
---@field getTowerByIndex fun(nIndex: integer): CGuardTower
---@field getAllTowers fun(): table<integer, CGuardTower>
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
---@field updateRaceSexClass fun(pPlayer: CPlayer, byNewRaceSex: integer, pszClassCode?: string, bSkipForceReaverCheck?: boolean): integer
---@field updateBaseShape fun(pPlayer: CPlayer, dwBaseShape: integer): integer
local modRaceSexClassChange = {}

---@class (exact) modForceLogoutAfterUsePotion
---@field s_bNeedForceLogout boolean
local modForceLogoutAfterUsePotion = {}

---@class (exact) modRaceBossChipHolderBonus
---@field GetAttackBonus fun(pPlayer: CPlayer, bActiveSkill: boolean): number
---@field GetUnitAttackBonus fun(pPlayer: CPlayer, bGenerator: boolean): number
---@field GetDefenseBonus fun(pPlayer: CPlayer): number
---@field GetHPBonus fun(pPlayer: CPlayer): number
local modRaceBossChipHolderBonus = {}

---@class (exact) modNetwork
---@field getPlayerHWID fun(dwIndex: integer): boolean, string?
local modNetwork = {}

---@class (exact) CAssetController
---@field instance fun(): CAssetController
local CAssetController = {}
---@param strName string
function CAssetController:addAsset(strName) end
---@param ID string|integer
function CAssetController:removeAsset(ID) end
---@return boolean
function CAssetController:makeAllAssetData() end
function CAssetController:sendAllAssetData() end
---@param strID string
---@return boolean
function CAssetController:makeAssetData(strID) end
---@param strID string
---@return boolean
function CAssetController:sendAssetData(strID) end

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
---@return integer
function CLanguageAsset:getDefaultLanguage() end
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

---@class (exact) TIMESTAMP_STRUCT
---@field year integer
---@field month integer
---@field day integer
---@field hour integer?
---@field min integer?
---@field sec integer?
---@field ms integer?
local TIMESTAMP_STRUCT = {}

---@class (exact) CSQLResultSet
local CSQLResultSet = {}
---@return table<integer, CBinaryData>
function CSQLResultSet:GetList() end

---@class (exact) CBinaryData
local CBinaryData = {}
---@param str string
---@param len integer
---@return boolean
function CBinaryData:PushString(str, len) end
---@param a1 integer
---@return boolean
function CBinaryData:PushInt8(a1) end
---@param a1 integer
---@return boolean
function CBinaryData:PushInt16(a1) end
---@param a1 integer
---@return boolean
function CBinaryData:PushInt32(a1) end
---@param a1 integer
---@return boolean
function CBinaryData:PushInt64(a1) end
---@param a1 integer
---@return boolean
function CBinaryData:PushUInt8(a1) end
---@param a1 integer
---@return boolean
function CBinaryData:PushUInt16(a1) end
---@param a1 integer
---@return boolean
function CBinaryData:PushUInt32(a1) end
---@param a1 integer
---@return boolean
function CBinaryData:PushUInt64(a1) end
---@param a1 number
---@return boolean
function CBinaryData:PushFloat(a1) end
---@param a1 number
---@return boolean
function CBinaryData:PushDouble(a1) end
---@param len integer
---@return boolean
---@return string
function CBinaryData:PopString(len) end
---@return boolean
---@return integer
function CBinaryData:PopInt8() end
---@return boolean
---@return integer
function CBinaryData:PopInt16() end
---@return boolean
---@return integer
function CBinaryData:PopInt32() end
---@return boolean
---@return integer
function CBinaryData:PopInt64() end
---@return boolean
---@return integer
function CBinaryData:PopUInt8() end
---@return boolean
---@return integer
function CBinaryData:PopUInt16() end
---@return boolean
---@return integer
function CBinaryData:PopUInt32() end
---@return boolean
---@return integer
function CBinaryData:PopUInt64() end
---@return boolean
---@return number
function CBinaryData:PopFloat() end
---@return boolean
---@return number
function CBinaryData:PopDouble() end
---@return integer
function CBinaryData:GetReadPos() end
---@param pos integer
---@return boolean
function CBinaryData:SetReadPos(pos) end
---@return integer
function CBinaryData:GetWritePos() end
---@param pos integer
---@return boolean
function CBinaryData:SetWritePos(pos) end
---@param year integer
---@param month integer
---@param day integer
---@param hour integer
---@param minute integer
---@param second integer
---@param millisec? integer
---@return boolean
function CBinaryData:PushSQLTimeStampStruct(year, month, day, hour, minute, second, millisec) end
---@return boolean
---@return TIMESTAMP_STRUCT?
function CBinaryData:PopSQLTimeStampStruct() end

---@class (exact) CMultiSQLResultSet
local CMultiSQLResultSet = {}
---@param key integer
---@param data CSQLResultSet
function CMultiSQLResultSet:PushData(key, data) end
---@param key integer
---@return CSQLResultSet?
function CMultiSQLResultSet:GetData(key) end
---@return table<integer, CSQLResultSet>
function CMultiSQLResultSet:GetList() end

---@class (exact) CMultiBinaryData
local CMultiBinaryData = {}
---@param key integer
---@param data CBinaryData
function CMultiBinaryData:PushData(key, data) end
---@param key integer
---@return CBinaryData?
function CMultiBinaryData:GetData(key) end
---@return table<integer, CBinaryData>
function CMultiBinaryData:GetList() end

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
---@field m_nFreeServer integer m_bFreeServer
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
---@field m_nLimitPlayerLevel integer m_bLimitPlayerLevel
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
---@param a1 integer
---@return lightuserdata _WAIT_ENTER_ACCOUNT
function CMainThread:m_WaitEnterAccount_get(a1) end
---@param a1 integer
---@return string
function CMainThread:m_wszRaceGreetingMsg_get(a1) end
---@param a1 integer
---@param a2 string
function CMainThread:m_wszRaceGreetingMsg_set(a1, a2) end
---@param a1 integer
---@return string
function CMainThread:m_wszBossName_get(a1) end
---@param a1 integer
---@param a2 string
function CMainThread:m_wszBossName_set(a1, a2) end
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
function CMainThread:m_dwStartNPCQuestCnt_get(a1) end
---@param a1 integer
---@return integer
function CMainThread:m_dwGuildPower_get(a1) end
---@param a1 integer
---@param a2 integer
function CMainThread:m_dwGuildPower_set(a1, a2) end

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
---@param pszRegionCode string
---@param pObj CGameObject
---@return boolean
function CMapOperation:IsInRegion(pszRegionCode, pObj) end

---@class (exact) CActionPointSystemMgr
---@field Instance fun(): CActionPointSystemMgr
local CActionPointSystemMgr = {}
---@param a1 integer
---@return integer
function CActionPointSystemMgr:GetEventStatus(a1) end

---@class (exact) CObjectList
---@field m_Head _object_list_point
---@field m_Tail _object_list_point
---@field m_nSize integer
local CObjectList = {}

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

---@class (exact) CHolyScheduleData____HolyScheduleNode
local CHolyScheduleData____HolyScheduleNode = {}
---@param a1 integer
---@return integer
function CHolyScheduleData____HolyScheduleNode:m_nSceneTime_get(a1) end
---@param a1 integer
---@param a2 integer
function CHolyScheduleData____HolyScheduleNode:m_nSceneTime_set(a1, a2) end

---@class (exact) CHolyScheduleData
---@field m_bSet boolean
---@field m_pSchedule CHolyScheduleData____HolyScheduleNode
---@field m_nTotalSchedule integer
local CHolyScheduleData = {}

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
---@field m_nScheduleCodePre integer m_bScheduleCodePre
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
---@param a2 _portal_dummy
function CHolyStoneSystem:m_pPortalDummy_set(a1, a2) end
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
---@param a1 integer
---@param a2 CPartyPlayer
function CPartyPlayer:m_pPartyMember_set(a1, a2) end
---@return boolean
function CPartyPlayer:IsPartyBoss() end
---@return boolean
function CPartyPlayer:IsPartyMode() end
---@return CPlayer
function CPartyPlayer:GetLootAuthor() end
---@param a1 CPlayer
---@return boolean
function CPartyPlayer:IsPartyMember(a1) end

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
---@param a1 integer
---@return integer
function CPotionParam:m_dwNextUseTime_get(a1) end
---@param a1 integer
---@param a2 integer
function CPotionParam:m_dwNextUseTime_set(a1, a2) end

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
---@param byRace integer
---@param dwSerial integer
---@return integer
function CPvpUserAndGuildRankingSystem:GetBossType(byRace, dwSerial) end
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

---@class (exact) CTranslationAsset
---@field instance fun(): CTranslationAsset
local CTranslationAsset = {}
---@param pszMsgID string
---@param t table Translation table
function CTranslationAsset:loadTranslationTable(pszMsgID, t) end

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
---@field m_AvatorData _AVATOR_DATA
---@field m_AvatorData_bk _AVATOR_DATA
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
---@param a2 integer
function CUserDB:m_dwArrangePassCase0_set(a1, a2) end
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
---@param bUpdate boolean
---@return boolean
function CUserDB:Update_ItemDur(byStorageCode, bySlot, qwAmount, bUpdate) end
---@param byStorageCode integer
---@param bySlot integer
---@param dwUpgrade integer
---@param bUpdate boolean
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
---@field nEffCode integer
---@field fEffUnit number
---@field fEffUnitMax number
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
---@param nIndex integer
---@return integer
function _Exttrunk_db_load:m_byItemSlotRace_get(nIndex) end
---@param nIndex integer
---@param val integer
function _Exttrunk_db_load:m_byItemSlotRace_set(nIndex, val) end
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
---@field m_byLoad integer m_bLoad
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
---@param a2 number
function _character_db_load:m_fStartPos_set(a1, a2) end
---@param a1 integer
---@return integer
function _character_db_load:m_byDftPart_get(a1) end
---@param a1 integer
---@param a2 integer
function _character_db_load:m_byDftPart_set(a1, a2) end

---@class (exact) _combine_ex_item_request_clzo
---@field wManualIndex integer
---@field byCombineSlotNum integer
---@field nUseNpcLink integer bUseNpcLink
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
---@field m_pDataParam _effect_parameter____param_data
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
---@field m_nUse integer m_bUse
---@field m_nQuestRepeat integer m_bQuestRepeat
---@field m_nQuestType integer
---@field m_nSelectQuestManual integer m_bSelectQuestManual
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
---@param nIndex integer
---@return integer
function _trunk_db_load:m_byItemSlotRace_get(nIndex) end
---@param nIndex integer
---@param val integer
function _trunk_db_load:m_byItemSlotRace_set(nIndex, val) end
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
---@param a1 integer
---@param a2 number
function cStaticMember_Player:_pLimExp_set(a1, a2) end

---@class (exact) _effect_parameter____param_data
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
---@param a1 integer
---@return CGameStatistics___map
function CGameStatistics___DAY:MaxHourPerMap_Hour_get(a1) end

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
---@field s_wRecord_get fun(x: integer, y: integer): integer
---@field s_wRecord_set fun(x: integer, y: integer, val: integer)
local _100_per_random_table = {}
---@return integer
function _100_per_random_table:GetRand() end

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
---@param a1 integer
---@return integer
function _io_money_data:byDate_get(a1) end
---@param a1 integer
---@param a2 integer
function _io_money_data:byDate_set(a1, a2) end

---@class (exact) _guild_applier_info
---@field pPlayer CPlayer
---@field dwApplyTime integer
local _guild_applier_info = {}

---@class (exact) CExtPotionBuf
---@field m_bExtPotionBufUse boolean
---@field m_bDayChange boolean
---@field m_dwEndPotionTime integer
local CExtPotionBuf = {}

---@class (exact) _guild_member_download_zocl
---@field byDownType integer
---@field dwGuildSerial integer
---@field byGuildGrade integer
---@field dwEmblemBack integer
---@field dwEmblemMark integer
---@field dDalant number
---@field dGold number
---@field byGuildRoomType integer
---@field GuildRoomRestTime integer
---@field byCurTax integer
---@field dwTotWin integer
---@field dwTotDraw integer
---@field dwTotLose integer
---@field bPossibleElectMaster boolean
---@field wDataSize integer
local _guild_member_download_zocl = {}

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
---@field m_DownPacket_Member _guild_member_download_zocl
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
---@param a1 integer
---@param a2 _guild_member_info
function CGuild:m_pGuildCommittee_set(a1, a2) end
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
function CGuild:MakeDownMemberPacket() end
---@param dwSerial integer
---@return _guild_member_info
function CGuild:GetMemberFromSerial(dwSerial) end
---@param byDowntype integer
---@param pMember _guild_member_info
function CGuild:SendMsg_DownPacket(byDowntype, pMember) end

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

---@class (exact) sirinActiveQuestData
---@field [1] integer
---@field [2] _QUEST_DB_BASE___LIST
local sirinActiveQuestData = {}

---@class (exact) _QUEST_DB_BASE
---@field dwListCnt integer
local _QUEST_DB_BASE = {}
---@param i integer
---@return _QUEST_DB_BASE___LIST
function _QUEST_DB_BASE:m_List_get(i) end
---@param byType? integer
---@return table<integer, sirinActiveQuestData>
function _QUEST_DB_BASE:GetActiveQuestList(byType) end
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
---@param pszItemCode string
---@param wCount integer
---@return boolean
function CQuestMgr:DeleteQuestItem(pszItemCode, wCount) end

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

---@class (exact) _EQUIPKEY
---@field zItemIndex integer
local _EQUIPKEY = {}

---@class (exact) _LINKKEY
---@field wEffectCode integer
local _LINKKEY = {}

---@class (exact) _EMBELLKEY
---@field bySlotIndex integer
---@field byTableCode integer
---@field wItemIndex integer
local _EMBELLKEY = {}

---@class (exact) _FORCEKEY
---@field dwKey integer
local _FORCEKEY = {}

---@class (exact) _ANIMUSKEY
---@field byItemIndex integer
local _ANIMUSKEY = {}

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
---not used
---@param a1 integer
---@param a2 integer
function CItemStore:m_dwLastTradeActPoint_set(a1, a2) end
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
---@param a1 integer
---@param a2 integer
function _Select_ItemList_buff:bySelectIndexList_set(a1, a2) end

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
---@field m_nWriteAble integer m_bWriteAble
---@field m_bAddCount boolean
---@field m_bDate boolean
---@field m_bTrace boolean
---@field m_bInit boolean
local CLogFile = {}
---@param str string
function CLogFile:Write(str) end
---@param file_name string
---@param nIsWritable integer
---@param bTrace boolean
---@param bDate boolean
---@param bAddCount boolean
function CLogFile:SetWriteLogFile(file_name, nIsWritable, bTrace, bDate, bAddCount) end

---@class (exact) _REGED_AVATOR_DB
---@field m_wszAvatorName string
---@field m_dwRecordNum integer
---@field m_byRaceSexCode integer
---@field m_bySlotIndex integer
---@field m_szClassCode string
---@field m_byLevel integer
---@field m_dwDalant integer
---@field m_dwGold integer
---@field m_dwBaseShape integer
---@field m_dwLastConnTime integer
local _REGED_AVATOR_DB = {}
---@param index integer
---@return _EQUIPKEY
function _REGED_AVATOR_DB:m_EquipKey_get(index) end
---@param index integer
---@return integer
function _REGED_AVATOR_DB:m_byEquipLv_get(index) end
---@param index integer
---@param val integer
function _REGED_AVATOR_DB:m_byEquipLv_set(index, val) end

---@class (exact) _REGED : _REGED_AVATOR_DB
local _REGED = {}
---@param index integer
---@return integer
function _REGED:m_dwFixEquipLv_get(index) end
---@param index integer
---@param val integer
function _REGED:m_dwFixEquipLv_set(index, val) end
---@param index integer
---@return integer
function _REGED:m_dwItemETSerial_get(index) end
---@param index integer
---@param val integer
function _REGED:m_dwItemETSerial_set(index, val) end
---@param index integer
---@return integer
function _REGED:m_lnUID_get(index) end
---@param index integer
---@param val integer
function _REGED:m_lnUID_set(index, val) end
---@param index integer
---@return integer
function _REGED:m_byCsMethod_get(index) end
---@param index integer
---@param val integer
function _REGED:m_byCsMethod_set(index, val) end
---@param index integer
---@return integer
function _REGED:m_dwET_get(index) end
---@param index integer
---@param val integer
function _REGED:m_dwET_set(index, val) end
---@param index integer
---@return integer
function _REGED:m_dwLendRegdTime_get(index) end
---@param index integer
---@param val integer
function _REGED:m_dwLendRegdTime_set(index, val) end

---@class (exact) _AVATOR_DB_BASE : _REGED
---@field m_dwHP integer
---@field m_dwFP integer
---@field m_dwSP integer
---@field m_dwDP integer
---@field m_dExp number
---@field m_dLossExp number
---@field m_dPvPPoint number
---@field m_dPvPCashBag number
---@field m_dwPvpRank integer
---@field m_wRankRate integer
---@field m_dwRadarDelayTime integer
---@field m_byBagNum integer
---@field m_byMapCode integer
---@field m_dwClassInitCnt integer
---@field m_byLastClassGrade integer
---@field m_fStartPos_x number
---@field m_fStartPos_y number
---@field m_fStartPos_z number
---@field m_dwTotalPlayMin integer
---@field m_dwStartPlayTime integer
---@field m_szBindMapCode string
---@field m_szBindDummy string
---@field m_dwGuildSerial integer
---@field m_byClassInGuild integer
---@field m_dwGuildExplusDate integer
---@field m_byGuildExplusApprovNum integer
---@field m_byGuildExplusSeniorNum integer
---@field m_dwAccountSerial integer
---@field m_bOverlapVote boolean
---@field m_dwGivebackCount integer
---@field m_dwCashAmount integer
---@field m_dwTakeLastMentalTicket integer
---@field m_dwTakeLastCriTicket integer
---@field m_byMaxLevel integer
---@field m_dPvPPointLeak number
---@field m_dwGuildEntryDelay integer
---@field m_byPlayerInteg integer
local _AVATOR_DB_BASE = {}
---@param index integer
---@return integer
function _AVATOR_DB_BASE:m_zClassHistory_get(index) end
---@param index integer
---@param val integer
function _AVATOR_DB_BASE:m_zClassHistory_set(index, val) end
---@param index integer
---@return integer
function _AVATOR_DB_BASE:m_dwPunishment_get(index) end
---@param index integer
---@param val integer
function _AVATOR_DB_BASE:m_dwPunishment_set(index, val) end
---@param index integer
---@return integer
function _AVATOR_DB_BASE:m_dwElectSerial_get(index) end
---@param index integer
---@param val integer
function _AVATOR_DB_BASE:m_dwElectSerial_set(index, val) end
---@param index integer
---@return integer
function _AVATOR_DB_BASE:m_dwRaceBattleRecord_get(index) end
---@param index integer
---@param val integer
function _AVATOR_DB_BASE:m_dwRaceBattleRecord_set(index, val) end

---@class (exact) _LINK_DB_BASE___LIST
---@field Key integer
local _LINK_DB_BASE___LIST = {}

---@class (exact) _LINK_DB_BASE
---@field m_byLinkBoardLock integer
---@field m_dwInven integer
local _LINK_DB_BASE = {}
---@param a1 integer
---@return _LINK_DB_BASE___LIST
function _LINK_DB_BASE:m_LinkList_get(a1) end
---@param a1 integer
---@return integer
function _LINK_DB_BASE:m_dwSkill_get(a1) end
---@param a1 integer
---@param a2 integer
function _LINK_DB_BASE:m_dwSkill_set(a1, a2) end
---@param a1 integer
---@return integer
function _LINK_DB_BASE:m_dwForce_get(a1) end
---@param a1 integer
---@param a2 integer
function _LINK_DB_BASE:m_dwForce_set(a1, a2) end
---@param a1 integer
---@return integer
function _LINK_DB_BASE:m_dwCharacter_get(a1) end
---@param a1 integer
---@param a2 integer
function _LINK_DB_BASE:m_dwCharacter_set(a1, a2) end
---@param a1 integer
---@return integer
function _LINK_DB_BASE:m_dwAnimus_get(a1) end
---@param a1 integer
---@param a2 integer
function _LINK_DB_BASE:m_dwAnimus_set(a1, a2) end
---@param a1 integer
---@return integer
function _LINK_DB_BASE:m_dwInvenBag_get(a1) end
---@param a1 integer
---@param a2 integer
function _LINK_DB_BASE:m_dwInvenBag_set(a1, a2) end

---@class (exact) _EQUIP_DB_BASE___EMBELLISH_LIST
---@field Key _EMBELLKEY
---@field wAmount integer
---@field dwItemETSerial integer
---@field lnUID integer
---@field byCsMethod integer
---@field dwT integer
---@field dwLendRegdTime integer
local _EQUIP_DB_BASE___EMBELLISH_LIST = {}

---@class (exact) _EQUIP_DB_BASE
local _EQUIP_DB_BASE = {}
---@param index integer
---@return _EQUIP_DB_BASE___EMBELLISH_LIST
function _EQUIP_DB_BASE:m_EmbellishList_get(index) end

---@class (exact) _FORCE_DB_BASE___LIST
---@field Key _FORCEKEY
---@field dwItemETSerial integer
---@field lnUID integer
---@field byCsMethod integer
---@field dwT integer
---@field m_dwLendRegdTime integer
local _FORCE_DB_BASE___LIST = {}

---@class (exact) _FORCE_DB_BASE
local _FORCE_DB_BASE = {}
---@param index integer
---@return _FORCE_DB_BASE___LIST
function _FORCE_DB_BASE:m_List_get(index) end

---@class (exact) _ANIMUS_DB_BASE___LIST
---@field Key _ANIMUSKEY
---@field dwExp integer
---@field dwParam integer
---@field dwItemETSerial integer
---@field lnUID integer
---@field byCsMethod integer
---@field dwT integer
---@field dwLendRegdTime integer
local _ANIMUS_DB_BASE___LIST = {}

---@class (exact) _ANIMUS_DB_BASE
local _ANIMUS_DB_BASE = {}
---@param index integer
---@return _ANIMUS_DB_BASE___LIST
function _ANIMUS_DB_BASE:m_List_get(index) end

---@class (exact) _STAT_DB_BASE
---@field m_dwDefenceCnt integer
---@field m_dwShieldCnt integer
---@field m_dwSpecialCum integer
local _STAT_DB_BASE = {}
---@param a1 integer
---@return integer
function _STAT_DB_BASE:m_dwDamWpCnt_get(a1) end
---@param a1 integer
---@param a2 integer
function _STAT_DB_BASE:m_dwDamWpCnt_set(a1, a2) end
---@param a1 integer
---@return integer
function _STAT_DB_BASE:m_dwSkillCum_get(a1) end
---@param a1 integer
---@param a2 integer
function _STAT_DB_BASE:m_dwSkillCum_set(a1, a2) end
---@param a1 integer
---@return integer
function _STAT_DB_BASE:m_dwForceCum_get(a1) end
---@param a1 integer
---@param a2 integer
function _STAT_DB_BASE:m_dwForceCum_set(a1, a2) end
---@param a1 integer
---@return integer
function _STAT_DB_BASE:m_dwMakeCum_get(a1) end
---@param a1 integer
---@param a2 integer
function _STAT_DB_BASE:m_dwMakeCum_set(a1, a2) end

---@class (exact) _INVEN_DB_BASE___LIST
---@field Key _INVENKEY
---@field dwDur integer
---@field dwUpt integer
---@field dwItemETSerial integer
---@field lnUID integer
---@field byCsMethod integer
---@field dwT integer
---@field dwLendRegdTime integer
local _INVEN_DB_BASE___LIST = {}

---@class (exact) _INVEN_DB_BASE
local _INVEN_DB_BASE = {}
---@param index integer
---@return _INVEN_DB_BASE___LIST
function _INVEN_DB_BASE:m_List_get(index) end

---@class (exact) _CUTTING_DB_BASE___LIST
---@field Key _INVENKEY
---@field dwDur integer
local _CUTTING_DB_BASE___LIST = {}

---@class (exact) _CUTTING_DB_BASE
---@field m_bOldDataLoad boolean
---@field m_byLeftNum integer
local _CUTTING_DB_BASE = {}
---@param index integer
---@return _CUTTING_DB_BASE___LIST
function _CUTTING_DB_BASE:m_List_get(index) end

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
---@param a2 integer
function _UNIT_DB_BASE___LIST:byPart_set(a1, a2) end
---@param a1 integer
---@return integer
function _UNIT_DB_BASE___LIST:dwBullet_get(a1) end
---@param a1 integer
---@param a2 integer
function _UNIT_DB_BASE___LIST:dwBullet_set(a1, a2) end
---@param a1 integer
---@return integer
function _UNIT_DB_BASE___LIST:dwSpare_get(a1) end
---@param a1 integer
---@param a2 integer
function _UNIT_DB_BASE___LIST:dwSpare_set(a1, a2) end

---@class (exact) _UNIT_DB_BASE
local _UNIT_DB_BASE = {}
---@param index integer
---@return _UNIT_DB_BASE___LIST
function _UNIT_DB_BASE:m_List_get(index) end

---@class (exact) _SFCONT_DB_BASE___LIST
---@field dwKey integer
local _SFCONT_DB_BASE___LIST = {}

---@class (exact) _SFCONT_DB_BASE
local _SFCONT_DB_BASE = {}
---@param index integer
---@param sub_index integer
---@return _SFCONT_DB_BASE___LIST
function _SFCONT_DB_BASE:m_List_get(index, sub_index) end

---@class (exact) _TRADE_DB_BASE___LIST
---@field byState integer
---@field dwRegistSerial integer
---@field byInvenIndex integer
---@field dwPrice integer
---@field tStartTime integer
---@field bySellTurm integer
---@field dwBuyerSerial integer
---@field dwTax integer
---@field tResultTime integer
---@field wszBuyerName string
---@field szBuyerAccount string
local _TRADE_DB_BASE___LIST = {}

---@class (exact) _TRADE_DB_BASE
local _TRADE_DB_BASE = {}
---@param index integer
---@return _TRADE_DB_BASE___LIST
function _TRADE_DB_BASE:m_List_get(index) end

---@class (exact) _BUDDY_DB_BASE___LIST
---@field dwSerial integer
---@field wszName string
local _BUDDY_DB_BASE___LIST = {}

---@class (exact) _BUDDY_DB_BASE
local _BUDDY_DB_BASE = {}
---@param index integer
---@return _BUDDY_DB_BASE___LIST
function _BUDDY_DB_BASE:m_List_get(index) end

---@class (exact) _TRUNK_DB_BASE___LIST
---@field Key _INVENKEY
---@field dwDur integer
---@field dwUpt integer
---@field byRace integer
---@field dwItemETSerial integer
---@field lnUID integer
---@field byCsMethod integer
---@field dwT integer
---@field dwLendRegdTime integer
local _TRUNK_DB_BASE___LIST = {}

---@class (exact) CMonsterSkill
---@field m_bExit boolean
---@field m_UseType integer
---@field m_nSFCode integer
---@field m_wSFIndex integer
---@field m_pSF_Fld _base_fld
---@field m_pSPConst _monster_sp_fld
---@field m_BefTime integer
---@field m_dwDelayTime integer
---@field m_dwCastDelay integer
---@field m_fAttackDist number
---@field m_nMotive integer
---@field m_nMotivevalue integer
---@field m_nCaseType integer
---@field m_nAccumulationCount integer
---@field m_nSFLv integer
---@field m_Element integer
---@field m_StdDmg integer
---@field m_MinDmg integer
---@field m_MaxDmg integer
---@field m_MinProb integer
---@field m_MaxProb integer
local CMonsterSkill = {}

---@class (exact) CNuclearBombMgr
---@field Instance fun(): CNuclearBombMgr
---@field m_szStickCode string
---@field m_dwWarnTime integer
---@field m_dwAttInformTime integer
---@field m_dwAttStartTime integer
local CNuclearBombMgr = {}
---@param i integer
---@param j integer
---@return CNuclearBomb
function CNuclearBombMgr:m_Missile_get(i, j) end

---@class (exact) CGuildRoomSystem
---@field GetInstance fun(): CGuildRoomSystem
local CGuildRoomSystem = {}
---@param dwGuildSerial integer
---@param n integer
---@param dwCharSerial integer
---@return boolean
function CGuildRoomSystem:IsGuildRoomMemberIn(dwGuildSerial, n, dwCharSerial) end
---@param byRace integer
---@param byMapType integer
---@return CMapData
function CGuildRoomSystem:GetMapData(byRace, byMapType) end

---@class (exact) _guild_honor_list_result_zocl____list
---@field dwGuildSerial integer
---@field dwEmblemBack integer
---@field dwEmblemMark integer
---@field wszGuildName string
---@field wszMasterName string
---@field byTaxRate integer
local _guild_honor_list_result_zocl____list = {}

---@class (exact) _guild_honor_list_result_zocl
---@field byListNum integer
---@field byUI integer
local _guild_honor_list_result_zocl = {}
---@param index integer
---@return _guild_honor_list_result_zocl____list
function _guild_honor_list_result_zocl:GuildList_get(index) end

---@class (exact) _guild_honor_set_request_clzo____list
---@field wszGuildName string
---@field byTaxRate integer
local _guild_honor_set_request_clzo____list = {}

---@class (exact) _guild_honor_set_request_clzo
---@field byListNum integer
local _guild_honor_set_request_clzo = {}
---@param index integer
---@return _guild_honor_set_request_clzo____list
function _guild_honor_set_request_clzo:GuildList_get(index) end

---@class (exact) CHonorGuild
---@field Instance fun(): CHonorGuild
local CHonorGuild = {}
---@param index integer
---@return boolean
function CHonorGuild:m_bNext_get(index) end
---@param index integer
---@param val boolean
function CHonorGuild:m_bNext_set(index, val) end
---@param index integer
---@return boolean
function CHonorGuild:m_bSendInform_get(index) end
---@param index integer
---@param val boolean
function CHonorGuild:m_bSendInform_set(index, val) end
---@param index integer
---@return _guild_honor_list_result_zocl
function CHonorGuild:m_pCurrHonorGuild_get(index) end
---@param index integer
---@return _guild_honor_list_result_zocl
function CHonorGuild:m_pNextHonorGuild_get(index) end
---@param index integer
---@return boolean
function CHonorGuild:m_bChageInform_get(index) end
---@param index integer
---@param val boolean
function CHonorGuild:m_bChageInform_set(index, val) end
---@param index integer
---@return integer
function CHonorGuild:m_uiProccessIndex_get(index) end
---@param index integer
---@param val integer
function CHonorGuild:m_uiProccessIndex_set(index, val) end
---@param byRace integer
---@param pReq _guild_honor_set_request_clzo
---@return integer
function CHonorGuild:SetNextHonorGuild(byRace, pReq) end
---@param byRace integer
function CHonorGuild:ChangeHonorGuild(byRace) end

---@class CProtoDataObject
local CProtoDataObject = {}
---@param dwBufSize integer
function CProtoDataObject:Init(dwBufSize) end
---@param strData string
function CProtoDataObject:PackString(strData) end
---@param u32Var integer
function CProtoDataObject:PackUInt32(u32Var) end
---@param u64Var integer
function CProtoDataObject:PackUInt64(u64Var) end
---@param i32Var integer
function CProtoDataObject:PackSInt32(i32Var) end
---@param i64Var integer
function CProtoDataObject:PackSInt64(i64Var) end
---@param fVar number
function CProtoDataObject:PackFloat(fVar) end
---@param dVar number
function CProtoDataObject:PackDouble(dVar) end
---@param dwSize integer
---@param dwIndex integer
function CProtoDataObject:PacketBufInsert(dwSize, dwIndex) end
---@return integer
function CProtoDataObject:GetWritePacketSize() end
---@param dwSocket integer
---@param pszID string
function CProtoDataObject:Send(dwSocket, pszID) end

---@class (exact) CandidateMgr
---@field Instance fun(): CandidateMgr
---@field _nMaxNum integer
---@field _kSysLog CLogFile
---@field _kVoteResultLog CLogFile
local CandidateMgr = {}
---@param byRace integer
---@param dwIndex integer
---@return _candidate_info
function CandidateMgr:_kCandidate_get(byRace, dwIndex) end
---@param byRace integer
---@param dwIndex integer
---@return _candidate_info
function CandidateMgr:_kCandidate_old_get(byRace, dwIndex) end
---@param byRace integer
---@param dwIndex integer
---@return _candidate_info
function CandidateMgr:_kPatriarchGroup_get(byRace, dwIndex) end
---@param byRace integer
---@return integer
function CandidateMgr:_nCandidateCnt_1st_get(byRace) end
---@param byRace integer
---@param dwIndex integer
---@return _candidate_info
function CandidateMgr:_pkCandidateLink_1st_get(byRace, dwIndex) end
---@param byRace integer
---@return integer
function CandidateMgr:_nCandidateCnt_2st_get(byRace) end
---@param byRace integer
---@param dwIndex integer
---@return _candidate_info
function CandidateMgr:_pkCandidateLink_2st_get(byRace, dwIndex) end
---@param byRace integer
---@param dwSerial integer
---@return boolean
function CandidateMgr:IsRegistedAvator_1(byRace, dwSerial) end
---@param byRace integer
---@param param integer|string Serial or name
---@return boolean
function CandidateMgr:IsRegistedAvator_2(byRace, param) end
---@param pPlayer CPlayer
---@return boolean
function CandidateMgr:Regist(pPlayer) end
---@param pPlayer CPlayer
---@param group CANDIDATE_CLASS
---@return boolean
function CandidateMgr:AppointPatriarchGroup(pPlayer, group) end
---@param byRace integer
---@param dwSerial integer
---@return integer
function CandidateMgr:GetWinCnt(byRace, dwSerial) end

---@class (exact) PatriarchElectProcessor
---@field Instance fun(): PatriarchElectProcessor
---@field _eProcessType ELECT_PROCESSOR
---@field _kRunningProcessor ElectProcessor
---@field _bTimeCheck boolean
---@field _bInitProce boolean
---@field _dwNextCheckTime integer
---@field _dwNextCheckDay integer
---@field _dwNextScoreUpdateTime integer
---@field _dwElectSerial integer
---@field _dwCurrPatriarchElectSerial integer
---@field _kSysLog CLogFile
local PatriarchElectProcessor = {}
---@param byRace integer
---@return integer
function PatriarchElectProcessor:m_dwNonvoteCnt_get(byRace) end
---@param byRace integer
---@param val integer
---@return integer
function PatriarchElectProcessor:m_dwNonvoteCnt_set(byRace, val) end
---@param byRace integer
---@return integer
function PatriarchElectProcessor:m_dwTotalVoteCnt_get(byRace) end
---@param byRace integer
---@param val integer
---@return integer
function PatriarchElectProcessor:m_dwTotalVoteCnt_set(byRace, val) end
---@param byRace integer
---@return integer
function PatriarchElectProcessor:m_dwHighGradeNum_get(byRace) end
---@param byRace integer
---@param val integer
---@return integer
function PatriarchElectProcessor:m_dwHighGradeNum_set(byRace, val) end
---@param index ELECT_PROCESSOR
---@return ElectProcessor
function PatriarchElectProcessor:_kProcessor_get(index) end
---@param cmd ELECT_PROC_CMD
---@param pPlayer? CPlayer
---@param pData? CBinaryData
---@return integer
function PatriarchElectProcessor:DoIt(cmd, pPlayer, pData) end

---@class (exact) CWeeklyGuildRankManager
---@field Instance fun(): CWeeklyGuildRankManager
---@field m_tNextUpdateTime integer
---@field m_tNextSetOwnerTime integer
---@field m_kInfo lightuserdata
local CWeeklyGuildRankManager = {}

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
Sirin.mainThread.modRaceBossChipHolderBonus = modRaceBossChipHolderBonus
Sirin.mainThread.modNetwork = modNetwork
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
Sirin.mainThread.CNuclearBombMgr = CNuclearBombMgr
Sirin.mainThread._100_per_random_table = _100_per_random_table
Sirin.mainThread.CGuildRoomSystem = CGuildRoomSystem
Sirin.mainThread.CHonorGuild = CHonorGuild
Sirin.mainThread.CandidateMgr = CandidateMgr
Sirin.mainThread.PatriarchElectProcessor = PatriarchElectProcessor
Sirin.mainThread.CWeeklyGuildRankManager = CWeeklyGuildRankManager