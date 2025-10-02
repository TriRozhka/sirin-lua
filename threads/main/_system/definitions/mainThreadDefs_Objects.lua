---@meta

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
---@field m_rtPer100 _100_per_random_table
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
---@param nDamage integer
---@param pDst CCharacter
---@param nDstLv integer
---@param bCrt boolean
---@param nAttackType integer
---@param dwAttackSerial integer
---@param bJadeReturn boolean
---@return integer
function CGameObject:SetDamage(nDamage, pDst, nDstLv, bCrt, nAttackType, dwAttackSerial, bJadeReturn) end
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
---@return string
function CGameObject:GetObjName() end
---@return boolean
function CGameObject:IsRecvableContEffect() end
---@param bFirst boolean
---@return boolean
function CGameObject:IsBeAttackedAble(bFirst) end
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
function CGameObject:SendMsg_BreakStop() end

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
---@field m_nHolyScanner integer m_bHolyScanner
---@field m_Item _STORAGE_LIST___db_con
---@field m_bHide boolean
local CItemBox = {}
---@param a1 CPlayer
---@return boolean
function CItemBox:IsTakeRight(a1) end
---@return boolean
function CItemBox:Destroy() end

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
---@param index integer
---@param val integer
function CParkingUnit:m_byPartCode_set(index, val) end

---@class (exact) CReturnGateCreateParam: _object_create_setdata
---@field m_pkOwner CPlayer
local CReturnGateCreateParam = {}
---@return CPlayer
function CReturnGateCreateParam:GetOwner() end

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

---@class (exact) CDummyRift: CReturnGate
---@field m_strObjectUUID string
local CDummyRift = {}

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
---@param byContCode integer
---@param wListIndex integer
---@param bInit boolean
---@param bAura boolean
function CCharacter:RemoveSFContEffect(byContCode, wListIndex, bInit, bAura) end
---@param nContParamCode integer
---@param nContParamIndex integer
function CCharacter:RemoveSFContHelpByEffect(nContParamCode, nContParamIndex) end
---@param pDstChar CCharacter
---@param pForceFld _force_fld
---@param nForceLv integer
---@return boolean
---@return integer # Error code
---@return boolean # Is mastery can grow 
function CCharacter:AssistForce(pDstChar, pForceFld, nForceLv) end
---@param pDstChar CCharacter
---@param pForceFld _force_fld
---@param nForceLv integer
---@return boolean
function CCharacter:AssistForceToOne(pDstChar, pForceFld, nForceLv) end
---@param pDstChar CCharacter
---@param nEffectCode integer|EFF_CODE skill class or bullet
---@param pSkillFld _skill_fld
---@param nSkillLv integer
---@return boolean
---@return integer # Error code
---@return boolean # Is mastery can grow 
function CCharacter:AssistSkill(pDstChar, nEffectCode, pSkillFld, nSkillLv) end
---@param pDstChar CCharacter
---@param nEffectCode integer|EFF_CODE skill class or bullet
---@param pSkillFld _skill_fld
---@param nSkillLv integer
---@return boolean
function CCharacter:AssistSkillToOne(pDstChar, nEffectCode, pSkillFld, nSkillLv) end
---@param a1 boolean
---@return boolean
function CCharacter:GetStealth(a1) end
function CCharacter:BreakStealth() end
function CCharacter:Stop() end
---@param nEffectCode integer
---@param nAreaType integer
---@param nLv integer
---@param bBenefit boolean
---@param pOriDst CCharacter
---@param strActableDst string
---@return table<integer, CCharacter>
function CCharacter:FindEffectDst(nEffectCode, nAreaType, nLv, bBenefit, pOriDst, strActableDst) end
---@param strActableDst string
---@param pDst CCharacter
---@return boolean
function CCharacter:IsEffectableDst(strActableDst, pDst) end
---@param nAttPnt integer
---@param nAttPart integer
---@param nTolType integer
---@param pDst CCharacter
---@param bBackAttack boolean
---@return integer
function CCharacter:GetAttackDamPoint(nAttPnt, nAttPart, nTolType, pDst, bBackAttack) end

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

---@class (exact) SKILL
---@field m_Type integer
---@field m_Element integer
---@field m_MinDmg integer
---@field m_StdDmg integer
---@field m_MaxDmg integer
---@field m_CritDmg integer
---@field m_MinProb integer
---@field m_MaxProb integer
---@field m_IsCritical integer
---@field m_param _attack_param
---@field m_Len integer
---@field m_CastDelay integer
---@field m_Delay integer
---@field m_bLoad integer
---@field m_Active integer
---@field m_BefTime integer
local SKILL = {}

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
---@return SKILL
function CAnimus:m_Skill_get(a1) end
---@param a1 integer
function CAnimus:AlterExp(a1) end

---@class (exact) _tower_create_setdata : _character_create_setdata
---@field nHP integer
---@field pMaster CPlayer
---@field byRaceCode integer
---@field pItem _STORAGE_LIST___db_con
---@field nIniIndex integer
---@field bQuick boolean
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

---@class (exact) CMonsterSkillPool
---@field m_pMyMon CMonster
---@field m_nSize integer
local CMonsterSkillPool = {}
---@param index integer
---@return CMonsterSkill
function CMonsterSkillPool:m_MonSkill_get(index) end
---@param nKind integer
---@return CMonsterSkill
function CMonsterSkillPool:GetMonSkillKind(nKind) end

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
---@field m_MonsterSkillPool CMonsterSkillPool
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
function CMonster:m_nMove_State(a1) end
---@param a1 CMonster
---@return integer
function CMonster:m_nCombat_State(a1) end
---@param a1 CMonster
---@return integer
function CMonster:m_nEmotion_State(a1) end
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
---@param x number
---@param y number
---@param z number
function CMonster:UpdateLookAtPos(x, y, z) end
---@param pTarget CCharacter
---@return boolean
function CMonster:IsViewArea(pTarget) end

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
---@field m_fDropPos_x number
---@field m_fDropPos_y number
---@field m_fDropPos_z number
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
---@return _be_damaged_player
function CNuclearBomb:m_DamList_get(a1) end
---@param a1 integer
---@return _be_damaged_char
function CNuclearBomb:m_EffList_get(a1) end

---@class (exact) _ATTACK_DELAY_CHECKER___eff_list
---@field byEffectCode integer
---@field wEffectIndex integer
---@field dwNextTime integer
local _ATTACK_DELAY_CHECKER___eff_list = {}

---@class (exact) _ATTACK_DELAY_CHECKER___mas_list
---@field byEffectCode integer
---@field byMastery integer
---@field dwNextTime integer
local _ATTACK_DELAY_CHECKER___mas_list = {}

---@class (exact) _ATTACK_DELAY_CHECKER
---@field dwNextEffTime integer
---@field dwNextGenTime integer
---@field dwLastGnAttackTime integer
---@field dwLastSFAttackTime integer
---@field nFailCount integer
---@field m_nNextAddTime integer
---@field byTemp_EffectCode integer
---@field wTemp_EffectIndex integer
---@field byTemp_EffectMastery integer
local _ATTACK_DELAY_CHECKER = {}
---@param nDelay integer
function _ATTACK_DELAY_CHECKER:SetDelay(nDelay) end
---@param dwCode integer
---@param dwIndex integer
---@param dwMastery integer
---@return boolean
function _ATTACK_DELAY_CHECKER:IsDelay(dwCode, dwIndex, dwMastery) end

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
---@field m_pParkingUnit CParkingUnit
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
---@field m_nCntEnable integer m_bCntEnable
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
---@field m_AttDelayChker _ATTACK_DELAY_CHECKER
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
---@param a2 integer
function CPlayer:m_byEffectEquipCode_set(a1, a2) end
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
---@param byStorageCode integer
---@param byStorageIndex integer
---@param bEquipChange boolean
---@param bDelete boolean
---@param strErrorCodePos string
---@return boolean
function CPlayer:Emb_DelStorage(byStorageCode, byStorageIndex, bEquipChange, bDelete, strErrorCodePos) end
---@param a1 integer
---@param a2 integer
function CPlayer:SendMsg_DeleteStorageInform(a1, a2) end
---@param byStorageCode integer
---@param byStorageIndex integer
---@param nAlter integer
---@param bUpdate boolean
---@param bSend boolean
---@return integer
function CPlayer:Emb_AlterDurPoint(byStorageCode, byStorageIndex, nAlter, bUpdate, bSend) end
---@param byStorageCode integer
---@param wSerial integer
---@param dwDur integer
function CPlayer:SendMsg_AdjustAmountInform(byStorageCode, wSerial, dwDur) end
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
---@deprecated
---@param nActCode integer
---@param pszReqCode string
---@param wAddCount integer
---@return boolean
function CPlayer:Emb_CheckActForQuestParty(nActCode, pszReqCode, wAddCount) end
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
---@param pDst CCharacter
---@param bCounter boolean
---@param wBulletSerial integer
---@param wEffBtSerial integer
---@return integer nErrCode
---@return _STORAGE_LIST___db_con pBulletCon
---@return _BulletItem_fld pBulletFld
---@return _STORAGE_LIST___db_con pEffBulletCon
---@return _BulletItem_fld pEffBulletFld
function CPlayer:_pre_check_normal_attack(pDst, bCounter, wBulletSerial, wEffBtSerial) end
---@param pDst? CCharacter
---@param x number
---@param y number
---@param z number
---@param byEffectCode integer
---@param pSkillFld _skill_fld
---@param wBulletSerial integer
---@param nEffectGroup integer
---@param wEffBtSerial integer
---@return integer nErrCode
---@return _STORAGE_LIST___db_con pBulletCon
---@return _BulletItem_fld pBulletFld
---@return _STORAGE_LIST___db_con pEffBulletCon
---@return _BulletItem_fld pEffBulletFld
---@return integer wCosnumeHP
---@return integer wCosnumeFP
---@return integer wCosnumeSP
function CPlayer:_pre_check_skill_attack(pDst, x, y, z, byEffectCode, pSkillFld, wBulletSerial, nEffectGroup, wEffBtSerial) end
---@param pDst? CCharacter
---@param x number
---@param y number
---@param z number
---@param wForceSerial integer
---@param wEffBtSerial integer
---@return integer nErrCode
---@return _STORAGE_LIST___db_con pForceCon
---@return _force_fld pForceFld
---@return _STORAGE_LIST___db_con pEffBulletCon
---@return _BulletItem_fld pEffBulletFld
---@return integer wCosnumeHP
---@return integer wCosnumeFP
---@return integer wCosnumeSP
function CPlayer:_pre_check_force_attack(pDst, x, y, z, wForceSerial, wEffBtSerial) end
---@param pDst CCharacter
---@param byPart integer
---@return integer nErrCode
---@return _UnitPart_fld pUnitPartFld
---@return _UnitBullet_fld pUnitBulletFld
---@return integer wLeftNum
function CPlayer:_pre_check_unit_attack(pDst, byPart) end
---@param pDst? CCharacter
---@param x number
---@param y number
---@param z number
---@param wBulletSerial integer
---@param wEffBtSerial integer
---@return integer nErrCode
---@return _STORAGE_LIST___db_con pBulletCon
---@return _BulletItem_fld pBulletFld
---@return _STORAGE_LIST___db_con pEffBulletCon
---@return _BulletItem_fld pEffBulletFld
function CPlayer:_pre_check_siege_attack(pDst, x, y, z, wBulletSerial, wEffBtSerial) end
---@param nValue integer
---@param bOver boolean
---@return boolean
function CPlayer:SetFP(nValue, bOver) end
---@param nValue integer
---@param bOver boolean
---@return boolean
function CPlayer:SetSP(nValue, bOver) end
function CPlayer:SenseState() end

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

