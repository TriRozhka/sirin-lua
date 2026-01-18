---@meta

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

---@class (exact) CLevel
---@field mMapName string
---@field mCamPos_x number
---@field mCamPos_y number
---@field mCamPos_z number
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

---@class (exact) _TRUNK_DB_BASE
---@field wszPasswd string
---@field dDalant number
---@field dGold number
---@field byHintIndex integer
---@field wszHintAnswer string
---@field bySlotNum integer
---@field byExtSlotNum integer
---@field byTrunkInteg integer
local _TRUNK_DB_BASE = {}
---@param index integer
---@return _TRUNK_DB_BASE___LIST
function _TRUNK_DB_BASE:m_List_get(index) end
---@param index integer
---@return _TRUNK_DB_BASE___LIST
function _TRUNK_DB_BASE:m_ExtList_get(index) end

---@class (exact) _AIOC_A_MACRODATA__MACRO_POTIONDATA
local _AIOC_A_MACRODATA__MACRO_POTIONDATA = {}
---@param a1 integer
---@return integer
function _AIOC_A_MACRODATA__MACRO_POTIONDATA:Potion_get(a1) end
---@param a1 integer
---@param a2 integer
function _AIOC_A_MACRODATA__MACRO_POTIONDATA:Potion_set(a1, a2) end
---@param a1 integer
---@return integer
function _AIOC_A_MACRODATA__MACRO_POTIONDATA:PotionValue_get(a1) end
---@param a1 integer
---@param a2 integer
function _AIOC_A_MACRODATA__MACRO_POTIONDATA:PotionValue_set(a1, a2) end

---@class (exact) _AIOC_A_MACRODATA__MACRO_ACTIONDATA
local _AIOC_A_MACRODATA__MACRO_ACTIONDATA = {}
---@param a1 integer
---@return integer
function _AIOC_A_MACRODATA__MACRO_ACTIONDATA:Action_get(a1) end
---@param a1 integer
---@param a2 integer
function _AIOC_A_MACRODATA__MACRO_ACTIONDATA:Action_set(a1, a2) end

---@class (exact) _AIOC_A_MACRODATA__MACRO_CHATDATA
local _AIOC_A_MACRODATA__MACRO_CHATDATA = {}
---@param a1 integer
---@return string
function _AIOC_A_MACRODATA__MACRO_CHATDATA:Chat_get(a1) end
---@param a1 integer
---@param a2 string
function _AIOC_A_MACRODATA__MACRO_CHATDATA:Chat_set(a1, a2) end

---@class (exact) _AIOC_A_MACRODATA
local _AIOC_A_MACRODATA = {}
---@return _AIOC_A_MACRODATA__MACRO_POTIONDATA
function _AIOC_A_MACRODATA:mcr_Potion() end
---@param a1 integer
---@return _AIOC_A_MACRODATA__MACRO_ACTIONDATA
function _AIOC_A_MACRODATA:mcr_Action_get(a1) end
---@param a1 integer
---@return _AIOC_A_MACRODATA__MACRO_CHATDATA
function _AIOC_A_MACRODATA:mcr_Chat_get(a1) end

---@class (exact) _POSTSTORAGE_DB_BASE____list
---@field dwPSSerial integer
---@field nNumber integer
---@field byState integer
---@field nKey integer
---@field dwDur integer
---@field dwUpt integer
---@field dwGold integer
---@field bUpdate boolean
---@field bRetProc boolean
---@field bNew boolean
---@field bUpdateIndex boolean
---@field wszSendName string
---@field wszRecvName string
---@field wszTitle string
---@field wszContent string
---@field lnUID integer
local _POSTSTORAGE_DB_BASE____list = {}

---@class (exact) _POSTSTORAGE_DB_BASE
---@field m_bUpdate boolean
local _POSTSTORAGE_DB_BASE = {}
---@param index integer
---@return _POSTSTORAGE_DB_BASE____list
function _POSTSTORAGE_DB_BASE:m_PostList_get(index) end

---@class (exact) _RETURNPOST_DB_BASE
---@field m_bUpdate boolean
---@field m_nMax integer
---@field m_nCum integer
local _RETURNPOST_DB_BASE = {}
---@param index integer
---@return integer
function _RETURNPOST_DB_BASE:m_RetSerials_get(index) end
---@param index integer
---@param val integer
function _RETURNPOST_DB_BASE:m_RetSerials_set(index, val) end

---@class (exact) _DELPOST_DB_BASE____list
---@field dwDelSerial integer
---@field nStorageIndex integer
local _DELPOST_DB_BASE____list = {}

---@class (exact) _DELPOST_DB_BASE
---@field m_bUpdate boolean
---@field m_nMax integer
---@field m_nCum integer
local _DELPOST_DB_BASE = {}
---@param index integer
---@return _DELPOST_DB_BASE____list
function _DELPOST_DB_BASE:m_List_get(index) end

---@class (exact) _POSTDATA_DB_BASE
---@field dbPost _POSTSTORAGE_DB_BASE
---@field dbRetPost _RETURNPOST_DB_BASE
---@field dbDelPost _DELPOST_DB_BASE
local _POSTDATA_DB_BASE = {}

---@class (exact) _CRYMSG_DB_BASE___LIST
---@field wszCryMsg string
local _CRYMSG_DB_BASE___LIST = {}

---@class (exact) _CRYMSG_DB_BASE
local _CRYMSG_DB_BASE = {}
---@param index integer
---@return _CRYMSG_DB_BASE___LIST
function _CRYMSG_DB_BASE:m_List_get(index) end

---@class (exact) _PERSONALAMINE_INVEN_DB_BASE___LIST
---@field Key _INVENKEY
---@field dwDur integer
local _PERSONALAMINE_INVEN_DB_BASE___LIST = {}

---@class (exact) _PERSONALAMINE_INVEN_DB_BASE
---@field bUsable boolean
local _PERSONALAMINE_INVEN_DB_BASE = {}
---@param index integer
---@return _PERSONALAMINE_INVEN_DB_BASE___LIST
function _PERSONALAMINE_INVEN_DB_BASE:m_List_get(index) end

---@class (exact) _PVPPOINT_LIMIT_DB_BASE
---@field tUpdatedate integer
---@field bUseUp boolean
---@field byLimitRate integer
---@field dOriginalPoint number
---@field dLimitPoint number
---@field dUsePoint number
local _PVPPOINT_LIMIT_DB_BASE = {}

---@class (exact) _PVP_ORDER_VIEW_DB_BASE
---@field tUpdatedate integer
---@field nDeath integer
---@field nKill integer
---@field dTodayStacked number
---@field dPvpPoint number
---@field dPvpTempCash number
---@field dPvpCash number
---@field byContHaveCash integer
---@field byContLoseCash integer
---@field bRaceWarRecvr boolean
local _PVP_ORDER_VIEW_DB_BASE = {}
---@param index integer
---@return integer
function _PVP_ORDER_VIEW_DB_BASE:dwKillerSerial_get(index) end
---@param index integer
---@param val integer
function _PVP_ORDER_VIEW_DB_BASE:dwKillerSerial_set(index, val) end

---@class (exact) _worlddb_sf_delay_info___eff_list
---@field byEffectCode integer
---@field wEffectIndex integer
---@field dwNextTime integer
local _worlddb_sf_delay_info___eff_list = {}

---@class (exact) _worlddb_sf_delay_info___mas_list
---@field byEffectCode integer
---@field byMastery integer
---@field dwNextTime integer
local _worlddb_sf_delay_info___mas_list = {}

---@class (exact) _worlddb_sf_delay_info
local _worlddb_sf_delay_info = {}
---@param index integer
---@return _worlddb_sf_delay_info___eff_list
function _PVP_ORDER_VIEW_DB_BASE:EFF_get(index) end
---@param index integer
---@return _worlddb_sf_delay_info___mas_list
function _PVP_ORDER_VIEW_DB_BASE:MAS_get(index) end

---@class (exact) _SUPPLEMENT_DB_BASE
---@field dPvpPointLeak number
---@field bLastAttBuff boolean
---@field dwBufPotionEndTime integer
---@field dwRaceBuffClear integer
---@field byVoted integer
---@field VoteEnable integer
---@field wScanerCnt integer
---@field dwScanerGetDate integer
---@field dwAccumPlayTime integer
---@field dwLastResetDate integer
---@field dwGuildEntryDelay integer
---@field byPlayerInteg integer
local _SUPPLEMENT_DB_BASE = {}
---@param index integer
---@return integer
function _SUPPLEMENT_DB_BASE:dwActionPoint_get(index) end
---@param index integer
---@param val integer
function _SUPPLEMENT_DB_BASE:dwActionPoint_set(index, val) end

---@class (exact) _PCBANG_PLAY_TIME
---@field dwAccSerial integer
---@field dwLastConnTime integer
---@field dwContPlayTime integer
---@field bForcedClose boolean
---@field byReceiveCoupon integer
---@field byEnsureTime integer
local _PCBANG_PLAY_TIME = {}

---@class (exact) _POTION_NEXT_USE_TIME_DB_BASE
local _POTION_NEXT_USE_TIME_DB_BASE = {}
---@param index integer
---@return integer
function _POTION_NEXT_USE_TIME_DB_BASE:dwPotionNextUseTime_get(index) end
---@param index integer
---@param val integer
function _POTION_NEXT_USE_TIME_DB_BASE:dwPotionNextUseTime_set(index, val) end

---@class (exact) _PCBANG_FAVOR_ITEM_DB_BASE
local _PCBANG_FAVOR_ITEM_DB_BASE = {}
---@param index integer
---@return integer
function _PCBANG_FAVOR_ITEM_DB_BASE:lnUID_get(index) end
---@param index integer
---@param val integer
function _PCBANG_FAVOR_ITEM_DB_BASE:lnUID_set(index, val) end

---@class (exact) _TIMELIMITINFO_DB_BASE
---@field dwAccSerial integer
---@field dwFatigue integer
---@field byTLStatus integer
---@field dwLastLogoutTime integer
local _TIMELIMITINFO_DB_BASE = {}

---@class (exact) _AVATOR_DATA
---@field dbAvator _AVATOR_DB_BASE
---@field dbLink _LINK_DB_BASE
---@field dbEquip _EQUIP_DB_BASE
---@field dbForce _FORCE_DB_BASE
---@field dbAnimus _ANIMUS_DB_BASE
---@field dbStat _STAT_DB_BASE
---@field dbInven _INVEN_DB_BASE
---@field dbCutting _CUTTING_DB_BASE
---@field dbQuest _QUEST_DB_BASE
---@field dbUnit _UNIT_DB_BASE
---@field dbSfcont _SFCONT_DB_BASE
---@field dbTrade _TRADE_DB_BASE
---@field dbBuddy _BUDDY_DB_BASE
---@field dbTrunk _TRUNK_DB_BASE
---@field dbItemCombineEx _ITEMCOMBINE_DB_BASE
---@field dbMacro _AIOC_A_MACRODATA
---@field dbPostData _POSTDATA_DB_BASE
---@field dbBossCry _CRYMSG_DB_BASE
---@field m_byHSKTime integer
---@field m_byPvpGrade integer
---@field m_wKillPoint integer
---@field m_iPvpPoint integer
---@field m_wDiePoint integer
---@field m_byCristalBattleDBInfo integer
---@field dbPersonalAmineInven _PERSONALAMINE_INVEN_DB_BASE
---@field dbPvpPointLimit _PVPPOINT_LIMIT_DB_BASE
---@field dbPvpOrderView _PVP_ORDER_VIEW_DB_BASE
---@field dbSFDelay _worlddb_sf_delay_info
---@field dbSupplement _SUPPLEMENT_DB_BASE
---@field dbPlayTimeInPcbang _PCBANG_PLAY_TIME
---@field m_nCristalBattleDateUpdate integer m_bCristalBattleDateUpdate
---@field dbPotionNextUseTime _POTION_NEXT_USE_TIME_DB_BASE
---@field dbPcBangFavorItem _PCBANG_FAVOR_ITEM_DB_BASE
---@field dbTimeLimitInfo _TIMELIMITINFO_DB_BASE
local _AVATOR_DATA = {}

---@class (exact) _quest_check_result___node
---@field byQuestDBSlot integer
---@field byActIndex integer
---@field wCount integer
---@field bORComplete boolean
local _quest_check_result___node = {}

---@class (exact) _quest_check_result
---@field m_byCheckNum integer
local _quest_check_result = {}
---@param index integer
---@return _quest_check_result___node
function _quest_check_result:m_List_get(index) end

---@class (exact) _param_cash_update____item
---@field byRet integer
---@field in_strItemCode string
---@field in_byOverlapNum integer
---@field in_byTblCode integer
---@field in_wItemIdx integer
---@field in_nDiscount integer
---@field in_nPrice integer
---@field in_nLendType integer
---@field in_dwLendTime integer
---@field in_nEventType integer
---@field in_nHostEventType integer
---@field in_bIsApplyCoupon boolean
---@field in_lnUID integer
---@field out_cState integer
---@field out_nCashAmount integer
---@field out_nStdPrice integer
---@field out_nBuyPrice integer
---@field out_wItemSerial integer
---@field out_nState integer
---@field out_TransactionId64 integer
---@field out_dwT integer
local _param_cash_update____item = {}

---@class (exact) _param_cash
---@field in_dwAccountSerial integer
---@field in_dwAvatorSerial integer
---@field in_wSockIndex integer
---@field in_bAdjustDiscount boolean
---@field in_bOneN_One boolean
---@field in_bSetDiscount boolean
---@field in_bLimited_Sale boolean
local _param_cash = {}

---@class (exact) _param_cash_update: _param_cash
---@field in_szAcc string
---@field in_szJpnUSN string
---@field in_szSvrName string
---@field in_szAvatorName string
---@field in_nCashAmount integer
---@field in_nNum10 integer
---@field in_bySetKind integer
---@field in_nCouponCnt integer
---@field out_nCashAmount integer
---@field in_dwIP integer
---@field szLogTableName string
---@field out_bReturn integer
local _param_cash_update = {}
---@param index integer
---@return _STORAGE_POS_INDIV
function _param_cash_update:in_CouponItem_get(index) end
---@param index integer
---@return integer
function _param_cash_update:dwBillingID_get(index) end
---@param index integer
---@param val integer
function _param_cash_update:dwBillingID_set(index, val) end
---@param index integer
---@return _param_cash_update____item
function _param_cash_update:in_item_get(index) end
---@return table<integer, _param_cash_update____item>
function _param_cash_update:GetItemList() end

---@class (exact) CNormalGuildBattleLogger
---@field m_pkLogger CLogFile
local CNormalGuildBattleLogger = {}

---@class (exact) CNormalGuildBattleGuildMember
---@field m_dwSerial integer
---@field m_bRestart boolean
---@field m_pOldBindMapData CMapData
---@field m_pOldBindDummyData _dummy_position
---@field m_szOldBindMapCode string
---@field m_szOldBindDummy string
---@field m_usGoalCnt integer
---@field m_usKillCnt integer
---@field m_dPvpPoint number
---@field m_pkMember _guild_member_info
local CNormalGuildBattleGuildMember = {}
---@return boolean
function CNormalGuildBattleGuildMember:IsEmpty() end

---@class (exact) CNormalGuildBattleGuild
---@field m_byID integer
---@field m_byColorInx integer
---@field m_dwGoalCnt integer
---@field m_dwScore integer
---@field m_dwKillPoint integer
---@field m_pkGuild CGuild
---@field m_byNotifyPositionMemberCnt integer
---@field m_dwKillCountSum integer
---@field m_dwMaxJoinMemberCnt integer
---@field m_dwCurJoinMember integer
local CNormalGuildBattleGuild = {}
---@param index integer
---@return CNormalGuildBattleGuildMember
function CNormalGuildBattleGuild:m_pkNotifyPositionMember_get(index) end
---@param index integer
---@return CNormalGuildBattleGuildMember
function CNormalGuildBattleGuild:m_kMember_get(index) end
---@return table<integer, CNormalGuildBattleGuildMember>
function CNormalGuildBattleGuild:GetMemberList() end

---@class (exact) CGuildBattle
local CGuildBattle = {}

---@class (exact) _dh_player_mgr___pos
---@field pMap CMapData
---@field wLayer integer
---@field fPos_x number
---@field fPos_y number
---@field fPos_z number
local _dh_player_mgr___pos = {}

---@class (exact) _dh_player_mgr
---@field pOne CPlayer
---@field dwSerial integer
---@field LastPos _dh_player_mgr___pos
---@field nEnterOrder integer
local _dh_player_mgr = {}

---@class (exact) CDarkHoleChannel
---@field m_wChannelIndex integer
---@field m_dwChannelSerial integer
---@field m_pHoleObj lightuserdata CDarkHole
---@field m_dwHoleSerial integer
---@field m_dwQuestStartTime integer
---@field m_pQuestSetup lightuserdata _dh_quest_setup
---@field m_wLayerIndex integer
---@field m_pLayerSet _LAYER_SET
---@field m_MissionMgr lightuserdata _dh_mission_mgr
---@field m_wszOpenerName string
---@field m_aszOpenerName string
---@field m_dwOpenerSerial integer
---@field m_nOpenerDegree integer
---@field m_nOpenerSubDegree integer
---@field m_bCheckMemberClose boolean
---@field m_pPartyMng CPartyPlayer
---@field m_pLeaderPtr _dh_player_mgr
---@field m_dwEnterOrderCounter integer
---@field m_dwNextCloseTime integer
---@field m_dwSendNewMissionMsgNextTime integer
---@field m_listEnterMember lightuserdata CIndexList
---@field m_bMoveNextMission boolean
local CDarkHoleChannel = {}
---@return _dh_player_mgr
function CDarkHoleChannel:m_Quester_get(index) end
---@return table<integer, _dh_player_mgr>
function CDarkHoleChannel:GetActiveMemberList() end

---@class (exact) CNormalGuildBattle: CGuildBattle
---@field m_dwID integer
---@field m_bInit boolean
---@field m_kLogger CNormalGuildBattleLogger
---@field m_byGuildBattleNumber integer
---@field m_k1P CNormalGuildBattleGuild
---@field m_k2P CNormalGuildBattleGuild
---@field m_pkField lightuserdata
---@field m_byWinResult integer
---@field m_pkWin CNormalGuildBattleGuild
---@field m_pkLose CNormalGuildBattleGuild
---@field m_pkRed CNormalGuildBattleGuild
---@field m_pkBlue CNormalGuildBattleGuild
---@field m_pkStateList lightuserdata
local CNormalGuildBattle = {}

---@class (exact) _total_guild_rank_info___list
---@field wRank integer
---@field dwSerial integer
---@field dPowerPoint number
---@field wszGuildName string
---@field byRace integer
---@field byGrade integer
---@field dwMasterSerial integer
---@field wszMasterName string
local _total_guild_rank_info___list = {}

---@class (exact) _total_guild_rank_info
---@field wCount integer
local _total_guild_rank_info = {}
---@param index integer
---@return integer
function _total_guild_rank_info:wRaceCnt_get(index) end
---@param index integer
---@param val integer
---@return integer
function _total_guild_rank_info:wRaceCnt_set(index, val) end
---@param index integer
---@return _total_guild_rank_info___list
function _total_guild_rank_info:list_get(index) end
---@param byRace integer
---@return table<integer, _total_guild_rank_info___list>
function _total_guild_rank_info:GetListByRace(byRace) end

---@class (exact) _candidate_info
---@field bLoad boolean
---@field bUpdateClassType boolean
---@field bRefund boolean
---@field eStatus CANDIDATE_STATUS
---@field eClassType CANDIDATE_CLASS
---@field byRace integer
---@field byLevel integer
---@field dwRank integer
---@field dwAvatorSerial integer
---@field dwGuildSerial integer
---@field wszName string
---@field wszGuildName string
---@field dPvpPoint number
---@field dwWinCnt integer
---@field dwScore integer
---@field bValidChar boolean
---@field byGrade integer
local _candidate_info = {}

---@class (exact) _pt_trans_votepaper_zocl____body
---@field byRank integer
---@field wszAvatorName string
---@field wszGuildName string
---@field dwWinCnt integer
local _pt_trans_votepaper_zocl____body = {}

---@class (exact) _pt_trans_votepaper_zocl
---@field byCnt integer
local _pt_trans_votepaper_zocl = {}
---@param index integer
---@return _pt_trans_votepaper_zocl____body
function _pt_trans_votepaper_zocl:body_get(index) end

---@class (exact) _pt_notify_vote_score_zocl____body
---@field byRank integer
---@field wszAvatorName string
---@field byScoreRate integer
local _pt_notify_vote_score_zocl____body = {}

---@class (exact) _pt_notify_vote_score_zocl
---@field byRace integer
---@field byVoteRate integer
---@field byNonvoteRate integer
---@field byCnt integer
local _pt_notify_vote_score_zocl = {}
---@param index integer
---@return _pt_notify_vote_score_zocl____body
function _pt_notify_vote_score_zocl:body_get(index) end

---@class (exact) ElectProcessor
---@field _bEnable boolean
---@field _nProcesor ELECT_PROCESSOR
---@field _kSysLog CLogFile
local ElectProcessor = {}
---@param cmd ELECT_PROC_CMD
---@param pPlayer? CPlayer
---@param pData? CBinaryData
---@return integer
function ElectProcessor:DoIt(cmd, pPlayer, pData) end

---@class (exact) Voter : ElectProcessor
local Voter = {}
---@param byRace integer
---@return _pt_trans_votepaper_zocl
function Voter:_kCandidateInfo_get(byRace) end
---@param byRace integer
---@return _pt_notify_vote_score_zocl
function Voter:_kVoteScoreInfo_get(byRace) end
---@param byRace integer
---@param pszDstName string
---@param bAbstain boolean
function Voter:_SetVoteScoreInfo(byRace, pszDstName, bAbstain) end
---@param byRace integer
function Voter:_SendVoteScoreAll(byRace) end

---@class (exact) _pt_result_fcandidacy_list_zocl____candi_info
---@field byGrade integer
---@field dPvpPoint number
---@field dwWinCnt integer
---@field wszAvatorName string
---@field wszGuildName string
local _pt_result_fcandidacy_list_zocl____candi_info = {}

---@class (exact) _pt_result_fcandidacy_list_zocl
---@field byCnt integer
local _pt_result_fcandidacy_list_zocl = {}
---@param index integer
---@return _pt_result_fcandidacy_list_zocl____candi_info
function _pt_result_fcandidacy_list_zocl:Candidacy_get(index) end

---@class (exact) CandidateRegister : ElectProcessor
---@field _bInitCandidate boolean
local CandidateRegister = {}
---@param index integer
---@return integer
function CandidateRegister:_byPtType_get(index) end
---@param byRace integer
---@return _pt_result_fcandidacy_list_zocl
function CandidateRegister:_kSend_get(byRace) end
---@param pPlayer CPlayer
---@param dwWinCnt integer
---@return boolean
function CandidateRegister:_AddToPacket(pPlayer, dwWinCnt) end

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
---@field m_SFContDB _SFCONT_DB_BASE
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
---@param a2 _STORAGE_LIST
function CPlayerDB:m_pStoragePtr_set(a1, a2) end
---@param a1 integer
---@return integer
function CPlayerDB:m_wCuttingResBuffer_get(a1) end
---@param a1 integer
---@param a2 integer
function CPlayerDB:m_wCuttingResBuffer_set(a1, a2) end
---@param a1 integer
---@return integer
function CPlayerDB:m_dwAlterMastery_get(a1) end
---@param a1 integer
---@param a2 integer
function CPlayerDB:m_dwAlterMastery_set(a1, a2) end
---@param a1 integer
---@return _class_fld
function CPlayerDB:m_pClassHistory_get(a1) end
---@param a1 integer
---@param a2 _class_fld
function CPlayerDB:m_pClassHistory_set(a1, a2) end
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
---@param a2 integer
function _MASTERY_PARAM:m_dwForceLvCum_set(a1, a2) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_mtyWp_get(a1) end
---@param a1 integer
---@param a2 integer
function _MASTERY_PARAM:m_mtyWp_set(a1, a2) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_lvSkill_get(a1) end
---@param a1 integer
---@param a2 integer
function _MASTERY_PARAM:m_lvSkill_set(a1, a2) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_mtySkill_get(a1) end
---@param a1 integer
---@param a2 integer
function _MASTERY_PARAM:m_mtySkill_set(a1, a2) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_mtyForce_get(a1) end
---@param a1 integer
---@param a2 integer
function _MASTERY_PARAM:m_mtyForce_set(a1, a2) end
---@param a1 integer
---@return integer
function _MASTERY_PARAM:m_mtyMakeItem_get(a1) end
---@param a1 integer
---@param a2 integer
function _MASTERY_PARAM:m_mtyMakeItem_set(a1, a2) end
---@param a1 integer
---@param a2 integer
---@return integer
function _MASTERY_PARAM:m_ppdwMasteryCumPtr_get(a1, a2) end
---@param a1 integer
---@param a2 integer
---@return integer
function _MASTERY_PARAM:m_ppbyMasteryPtr_get(a1, a2) end
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

---@class (exact) ControllerTaxRate
---@field m_bInit boolean
---@field m_fMinTaxRate number
---@field m_fMaxTaxRate number
---@field m_fCurTaxRate number
local ControllerTaxRate = {}

---@class (exact) _suggested_matter_change_taxrate
---@field byMatterType integer
---@field dwMatterDst integer
---@field wszMatterDst string
---@field dwNext integer
---@field dwSuggestedTime integer
local _suggested_matter_change_taxrate = {}

---@class (exact) TRC_AutoTrade
---@field m_bInit boolean
---@field m_byCurDay integer
---@field m_wCurMonth integer
---@field m_wCurYear integer
---@field m_bChangeTaxRate boolean
---@field m_fCommonTaxRate number
---@field m_pOwnerGuild CGuild
---@field m_Controller ControllerTaxRate
---@field m_sysLog CLogFile
---@field m_serviceLog CLogFile
---@field m_dwTrade integer
---@field m_dIncomeMoney number
---@field m_byRace integer
---@field m_suggested _suggested_matter_change_taxrate
local TRC_AutoTrade = {}