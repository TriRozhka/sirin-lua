---@meta

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
