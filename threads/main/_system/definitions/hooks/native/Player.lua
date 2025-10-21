--[[

Functions, which exists in native RF Online code. Player related hooks.

--]]

---Purpose: Player map load complete.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
local function CPlayer__pc_NewPosStart(pPlayer) end

---Purpose: Player teleportation start.
---Hook positions: 'pre_event'
---@param pPlayer CPlayer
---@param pIntoMap CMapData
---@param wLayerIndex integer
---@param byMapOutType integer
---@param x number
---@param y number
---@param z number
local function CPlayer__OutOfMap(pPlayer, pIntoMap, wLayerIndex, byMapOutType, x, y,z) end

---Purpose: apply have item std effect (resource effect handler) routine.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@param nEffCode integer
---@param fVal number
---@param bAdd boolean
---@param nDiffCnt integer
local function CPlayer__apply_have_item_std_effect(pPlayer, nEffCode, fVal, bAdd, nDiffCnt) end

---Purpose: apply normal item std effect (equipment effect handler) routine.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@param nEffCode integer
---@param fVal number
---@param bEquip boolean
local function CPlayer__apply_normal_item_std_effect(pPlayer, nEffCode, fVal, bEquip) end

---Purpose: apply equip upgrade effect (talik effect handler) routine.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@param pItem _STORAGE_LIST___db_con
---@param bEquip boolean
local function CPlayer__apply_case_equip_upgrade_effect(pPlayer, pItem, bEquip) end

---Purpose: Player enter game notification.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
---@param pUserDB CUserDB
---@param bFirstStart boolean
local function CPlayer__Load(pPlayer, pUserDB, bFirstStart) end

---Purpose: Player leave game notification.
---Hook positions: 'pre_event'
---@param pPlayer CPlayer
---@param bMoveOutLobby boolean
local function CPlayer__NetClose(pPlayer, bMoveOutLobby) end

---Purpose: Player enter game notification (later than Load).
---Hook positions: 'after_event'
---@param pPlayer CPlayer
local function CPlayer__Create(pPlayer) end

---Purpose: Player enter game notification (later than Create).
---Hook positions: 'after_event'
---@param pPlayer CPlayer
local function CPlayer__CreateComplete(pPlayer) end

---Purpose: Player reset class notification.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
local function CPlayer__pc_InitClass(pPlayer) end

---Purpose: Player take class snotification.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
---@param wSelClassIndex integer
local function CPlayer__SendMsg_SelectClassResult(pPlayer, wSelClassIndex) end

---Purpose: calculate player attack exp.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@param pDst CCharacter
---@param nDam integer
---@param kPartyExpNotify CPartyModeKillMonsterExpNotify
local function CPlayer__CalcExp(pPlayer, pDst, nDam, kPartyExpNotify) end

---Purpose: alter value of added player exp.
---Hook positions: 'special'
---@param pPlayer CPlayer
---@param dAlterExp number
---@param bReward boolean
---@param bUseExpRecoverItem boolean
---@param bUseExpAdditionItem boolean
---@return integer New exp value
local function CPlayer__AlterExp(pPlayer, dAlterExp, bReward, bUseExpRecoverItem, bUseExpAdditionItem)
	-- Do not call pPlayer:AlterExp(...) during this function call!
	return dAlterExp
end

---Purpose: Add storage notification.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
---@param byStorageCode integer
---@param pCon _STORAGE_LIST___storage_con
---@param bEquipChange boolean
---@param bAdd boolean
---@param Ret _STORAGE_LIST___db_con
local function CPlayer__Emb_AddStorage(pPlayer, byStorageCode, pCon, bEquipChange, bAdd, Ret) end

---Purpose: Delete storage notification.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
---@param byStorageCode integer
---@param byStorageIndex integer
---@param bEquipChange boolean
---@param bDelete boolean
---@param strErrorCodePos string
---@param Ret boolean
local function CPlayer__Emb_DelStorage(pPlayer, byStorageCode, byStorageIndex, bEquipChange, bDelete, strErrorCodePos, Ret) end

---Purpose: Alter dur point (stack size) notification.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
---@param byStorageCode integer
---@param byStorageIndex integer
---@param nAlter integer
---@param bUpdate boolean
---@param bSend boolean
---@param Ret integer
local function CPlayer__Emb_AlterDurPoint(pPlayer, byStorageCode, byStorageIndex, nAlter, bUpdate, bSend, Ret) end

---Purpose: Calc pvp points routine.
---Hook positions: 'original'
---@param pKiller CPlayer
---@param pDier CPlayer
local function CPlayer__CalcPvP(pKiller, pDier) end

---Purpose: Calc pvp cash routine.
---Hook positions: 'original'
---@param pKiller CPlayer
---@param pDier CPlayer
local function CPlayer__CalPvpTempCash(pKiller, pDier) end

---Purpose: Player level up notification.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
---@param byNewLevel integer
local function CPlayer__SetLevel(pPlayer, byNewLevel) end

---Purpose: Player level down notification.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
---@param byNewLevel integer
local function CPlayer__SetLevelD(pPlayer, byNewLevel) end

---Purpose: Max HP calculation.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@return integer
local function CPlayer___CalcMaxHP(pPlayer) return 1 end

---Purpose: Max FP calculation.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@return integer
local function CPlayer___CalcMaxFP(pPlayer) return 0 end

---Purpose: Max SP calculation.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@return integer
local function CPlayer___CalcMaxSP(pPlayer) return 0 end

---Purpose: Action point change notification.
---Hook positions: 'pre_event'
---@param pUserDB CUserDB
---@param byActionCode integer
---@param dwPoint integer
local function CUserDB__Update_User_Action_Point(pUserDB, byActionCode, dwPoint) end

---Purpose: Contribution point change notification.
---Hook positions: 'pre_event'
---@param pPlayer CPlayer
---@param dAlter number
---@param AlterType PVP_ALTER_TYPE
---@param dwDstSerial integer
local function CPlayer__AlterPvPPoint(pPlayer, dAlter, AlterType, dwDstSerial) end

---Purpose: Temp PvP Cash point change notification.
---Hook positions: 'pre_event'
---@param pOrderView CPvpOrderView
---@param wIndex integer index in g_Player array
---@param dTempPvpCash number
local function CPvpOrderView__Update_PvpTempCash(pOrderView, wIndex, dTempPvpCash) end

---Purpose: Fixed PvP Cash point change notification.
---Hook positions: 'pre_event'
---@param pPlayer CPlayer
---@param dAlter number
---@param IOCode PVP_MONEY_ALTER_TYPE
local function CPlayer__AlterPvPCashBag(pPlayer, dAlter, IOCode) end

---Purpose: Overrides HQ map
---Hook positions: 'original'
---@param pMapOper CMapOperation
---@param byRaceCode number
---@return CMapData?
local function CMapOperation__GetStartMap(pMapOper, byRaceCode) end

---Purpose: Update state flags event.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
local function CPlayer__SetStateFlag(pPlayer) end

---Purpose: Update state Ex flags event. AoP Only.
---Hook positions: 'after_event'
---@param pPlayer CPlayer
local function CPlayer__SetStateFlagEx(pPlayer) end

---Purpose: Dodge rate calculation.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@return integer
local function CPlayer__GetAvoidRate(pPlayer) return 0 end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@param nPart integer
---@return number
local function CPlayer__GetDefGap(pPlayer, nPart) return 0.5 end

---Purpose: DefFacing script value return.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@param nPart integer
---@return number
local function CPlayer__GetDefFacing(pPlayer, nPart) return 0.5 end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@param nAttactPart integer
---@param pAttackerChar CCharacter
---@return integer #Err code
---@return integer #Def point
local function CPlayer__GetDefFC(pPlayer, nAttactPart, pAttackerChar) return 0, 0 end

---Purpose: AttGap script value return.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@return integer
local function CPlayer__GetWeaponAdjust(pPlayer) return 0.5 end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pAMP AutominePersonal
---@param nPart integer
---@return number
local function AutominePersonal__GetDefGap(pAMP, nPart) return 0.5 end

---Purpose: DefFacing script value return.
---Hook positions: 'original'
---@param pAMP AutominePersonal
---@param nPart integer
---@return number
local function AutominePersonal__GetDefFacing(pAMP, nPart) return 0.5 end

---Purpose: DefGap script value return.
---Hook positions: 'original'
---@param pAMP AutominePersonal
---@param nAttactPart integer
---@param pAttackerChar CCharacter
---@return integer #Err code
---@return integer #Def point
local function AutominePersonal__GetDefFC(pAMP, nAttactPart, pAttackerChar) return 0, 0 end

---Purpose: Unit repair rutine.
---Hook positions: 'original'
---@param pPlayer CPlayer
---@param bySlotIndex integer
---@param bUseNPCLinkIntem boolean
---@param bUnitRepairOut boolean AoP only
local function CPlayer__pc_UnitFrameRepairRequest(pPlayer, bySlotIndex, bUseNPCLinkIntem, bUnitRepairOut) end

---Purpose: Teleport potion filter.
---Hook positions: 'filter'
---@param pPlayer CPlayer
---@param pDstObj CCharacter
---@param bStone boolean
---@return boolean
local function CPlayer__SF_TeleportToDestination(pPlayer, pDstObj, bStone) return true end

---Purpose: Map teleport filter.
---Hook positions: 'filter'
---@param pPlayer CPlayer
---@param nPortalIndex integer
---@param pConsumeSerial_1 integer
---@param pConsumeSerial_2 integer
---@param pConsumeSerial_3 integer
---@return boolean
local function CPlayer__pc_MovePortal(pPlayer, nPortalIndex, pConsumeSerial_1, pConsumeSerial_2, pConsumeSerial_3) return true end