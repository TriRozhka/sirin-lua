function MainThread.CMainThread__OnRun()
	-- Implementation of this function is optional
	ZoneEventMgr:OnRun()
end

---@param pPlayer CPlayer
function MainThread.CPlayer__pc_NewPosStart(pPlayer)
	-- Implementation of this function is optional
end

---@param pPlayer CPlayer
---@param pIntoMap CMapData
---@param wLayerIndex integer
---@param byMapOutType integer
---@param x number
---@param y number
---@param z number
function MainThread.CPlayer__OutOfMap(pPlayer, pIntoMap, wLayerIndex, byMapOutType, x, y,z)
	-- Implementation of this function is optional
end

---@param pPlayer CPlayer
---@param pUserDB CUserDB
---@param bFirstStart boolean
function MainThread.CPlayer__Load(pPlayer, pUserDB, bFirstStart)
	-- Implementation of this function is optional
end

---@param pPlayer CPlayer
---@param bMoveOutLobby boolean
function MainThread.CPlayer__NetClose(pPlayer, bMoveOutLobby)
	-- Implementation of this function is optional
end

---@param pPlayer CPlayer
function MainThread.CPlayer__Create(pPlayer)
	-- Implementation of this function is optional
end

---@param pHolySys CHolyStoneSystem
---@param byNumOfTime integer
---@param nSceneCode integer
---@param nPassTime integer
---@param nChangeReason integer
function MainThread.CHolyStoneSystem__SetScene(pHolySys, byNumOfTime, nSceneCode, nPassTime, nChangeReason)
	-- Implementation of this function is optional
end

---@param pHolySys CHolyStoneSystem
---@param byArrive integer
function MainThread.CHolyStoneSystem__SendIsArriveDestroyer(pHolySys, byArrive)
	-- Implementation of this function is optional
end

---@param pMonster CMonster
---@param pData _monster_create_setdata
function MainThread.CMonster__Create(pMonster, pData)
	-- Implementation of this function is optional

	local pMonFld = Sirin.mainThread.baseToMonsterCharacter(pData.m_pRecordSet)

	if pMonFld.m_nMobGrade == 2 and pData.m_pMap.m_pMapSet.m_nMapType == 0 then
		NetMgr.monsterLifeStateInform(
			0,
			pMonFld,
			pMonster.m_pCurMap)
	end
end

---@param pMonster CMonster
---@param byDestroyCode integer
---@param pAttObj CGameObject
function MainThread.CMonster__Destroy(pMonster, byDestroyCode, pAttObj)
	-- Implementation of this function is optional

	local pMonFld = Sirin.mainThread.baseToMonsterCharacter(pMonster.m_pRecordSet)

	if byDestroyCode == 0 and pAttObj and pAttObj.m_ObjID.m_byID == 0 and pMonFld.m_nMobGrade == 2 and pMonster.m_pCurMap.m_pMapSet.m_nMapType == 0 then
		NetMgr.monsterLifeStateInform(
			1,
			pMonFld,
			pMonster.m_pCurMap,
			Sirin.mainThread.objectToPlayer(pAttObj))
	end

	if byDestroyCode == 0 then
		MonsterScheduleMgr:onMonsterDestroy(pMonster)
	end
end

---@param pMonster CMonster
---@param dwOldSerial integer
function MainThread.CMonsterHelper__TransPort(pMonster, dwOldSerial)
	-- Implementation of this function is optional
	MonsterScheduleMgr:onMonsterTransport(pMonster, dwOldSerial)
end

--[[
---@param pPlayer CPlayer
---@param Selected table<integer, integer>
function MainThread.ItemCombineMgr__RequestCombineAcceptProcess(pPlayer, Selected)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pTarget CPlayer
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
function MainThread.CPlayer__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pTarget CAnimus
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
function MainThread.CAnimus__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pTarget CGuardTower
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
function MainThread.CGuardTower__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pTarget CHolyKeeper
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
function MainThread.CHolyKeeper__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pTarget CHolyStone
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
function MainThread.CHolyStone__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pTarget CTrap
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
function MainThread.CTrap__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pTarget CMonster
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
function MainThread.CMonster__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pTarget AutominePersonal
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
function MainThread.AutominePersonal__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pPlayer CPlayer
---@param pDst CCharacter
---@param nDam integer
---@param kPartyExpNotify CPartyModeKillMonsterExpNotify
function MainThread.CPlayer__CalcExp(pPlayer, pDst, nDam, kPartyExpNotify)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pPlayer CPlayer
---@param dAlterExp number
---@param bReward boolean
---@param bUseExpRecoverItem boolean
---@param bUseExpAdditionItem boolean
---@return integer New exp value
function MainThread.CPlayer__AlterExp(pPlayer, dAlterExp, bReward, bUseExpRecoverItem, bUseExpAdditionItem)
	-- Implementation of this function is optional
	-- Do not call pPlayer:AlterExp(...) during this function call!

	return dAlterExp
end
]]--

--[[
---@param pAnimus CAnimus
---@param pAT CAttack
function MainThread.CAnimus__CalcAttExp(pAnimus, pAT)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pAnimus CAnimus
---@param nAddExp integer
---@return integer New exp value
function MainThread.CAnimus__AlterExp(pAnimus, nAddExp)
	-- Implementation of this function is optional
	-- Do not call pAnimus:AlterExp(...) during this function call!

	return nAddExp
end
]]--

--[[
---@param pPlayer CPlayer
---@param byStorageCode integer
---@param pCon _STORAGE_LIST___storage_con
---@param bEquipChange boolean
---@param bAdd boolean
---@param Ret _STORAGE_LIST___db_con
function MainThread.CPlayer__OnEmb_AddStorage(pPlayer, byStorageCode, pCon, bEquipChange, bAdd, Ret)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pPlayer CPlayer
---@param byStorageCode integer
---@param byStorageIndex integer
---@param bEquipChange boolean
---@param bDelete boolean
---@param strErrorCodePos string
---@param Ret boolean
function MainThread.CPlayer__OnEmb_DelStorage(pPlayer, byStorageCode, byStorageIndex, bEquipChange, bDelete, strErrorCodePos, Ret)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pPlayer CPlayer
---@param byStorageCode integer
---@param byStorageIndex integer
---@param nAlter integer
---@param bUpdate boolean
---@param bSend boolean
---@param Ret integer
function MainThread.CPlayer__OnEmb_AlterDurPoint(pPlayer, byStorageCode, byStorageIndex, nAlter, bUpdate, bSend, Ret)
	-- Implementation of this function is optional
end
]]--

---@param pPlayer CPlayer
---@param wIndex integer
---@param byType integer
---@param byCashChangeStateFlag integer
function MainThread.CNetworkEX__OtherShapeRequest(pPlayer, wIndex, byType, byCashChangeStateFlag)
	BotMgr.otherShapeRequest(pPlayer, wIndex, byType, byCashChangeStateFlag)
end

--[[
---@param pPlayer CPlayer
---@param bySlotIndex integer
---@param pQuestDB _QUEST_DB_BASE___LIST
function MainThread.CPlayer__SendMsg_InsertNewQuest(pPlayer, bySlotIndex, pQuestDB)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pPlayer CPlayer
---@param bySlotIndex integer
---@param pQuestDB _QUEST_DB_BASE___LIST
function MainThread.CPlayer__SendMsg_InsertNextQuest(pPlayer, bySlotIndex, pQuestDB)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pPlayer CPlayer
---@param byFailCode integer
---@param byQuestDBSlot integer
function MainThread.CPlayer__SendMsg_QuestFailure(pPlayer, byFailCode, byQuestDBSlot)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pPlayer CPlayer
---@param byQuestDBSlot integer
function MainThread.CPlayer__pc_QuestGiveupRequest(pPlayer, byQuestDBSlot)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pPlayer CPlayer
---@param pQuestFld _Quest_fld
---@param byRewardItemIndex integer
function MainThread.CPlayer___Reward_Quest(pPlayer, pQuestFld, byRewardItemIndex)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pPlayer CPlayer
---@param byQuestDBSlot integer
function MainThread.CPlayer__SendMsg_QuestComplete(pPlayer, byQuestDBSlot)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pQuestMgr CQuestMgr
---@param pCond _happen_event_condition_node
function MainThread.CQuestMgr___CheckCondition(pQuestMgr, pCond)
	-- Implementation of this function is optional
	return true
end
--]]

--[[
---@param pStore CItemStore
---@param pPlayer CPlayer
---@param offer table<integer, _buy_offer>
---@param fDiscountRate number
---@return boolean
function MainThread.CItemStore__IsSell(pStore, pPlayer, offer, fDiscountRate)
	-- Implementation of this function is optional
	return true
end
--]]

--[[
---@param pPlayer CPlayer
---@param strGuildName string
---@return boolean
function MainThread.CPlayer__pc_GuildEstablishRequest(pPlayer, strGuildName)
	-- Implementation of this function is optional
	return true
end
]]--

--[[
---@param pGuild CGuild
function MainThread.CPlayer__Guild_Insert_Complete(pGuild)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pPlayer CPlayer
---@param pGuild CGuild
---@return boolean
function MainThread.CPlayer__pc_GuildJoinApplyRequest(pPlayer, pGuild)
	-- Implementation of this function is optional
	return true
end
]]--

--[[
---@param pPlayer CPlayer
function MainThread.CPlayer__SendMsg_GuildJoinApplyCancelResult(pPlayer)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pPlayer CPlayer
---@param dwApplierSerial integer
---@param bAccept boolean
---@return boolean
function MainThread.CPlayer__pc_GuildJoinAcceptRequest(pPlayer, dwApplierSerial, bAccept)
	-- Implementation of this function is optional
	return true
end
]]--#region

--[[
---@param nGuildSerial integer
---@param nApplierSerial integer
function MainThread.CPlayer__Guild_Join_Accept_Complete(nGuildSerial, nApplierSerial)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pPlayer CPlayer
---@return boolean
function MainThread.CPlayer__pc_GuildSelfLeaveRequest(pPlayer)
	-- Implementation of this function is optional
	return true
end
]]--

--[[
---@param nGuildSerial integer
---@param nApplierSerial integer
function MainThread.CPlayer__Guild_Self_Leave_Complete(nGuildSerial, nApplierSerial)
	-- Implementation of this function is optional
end
]]--

--[[
---@param pGuild CGuild
---@param dwMemberSerial integer
function MainThread.CGuild__ManageExpulseMember(pGuild, dwMemberSerial)
	-- Implementation of this function is optional
	return true
end
--]]

--[[
---@param nGuildSerial integer
---@param nLeaverSerial integer
function MainThread.CPlayer__Guild_Force_Leave_Complete(nGuildSerial, nLeaverSerial)
	-- Implementation of this function is optional
end
--]]

--[[
---@param nGuildSerial integer
function MainThread.CPlayer__Guild_Disjoint_Complete(nGuildSerial)
	-- Implementation of this function is optional
end
]]--

--[[
---@param nGuildSerial integer
---@param nNewMasterSerial integer
---@param nOldMasterSerial integer
function MainThread.CPlayer__Guild_Update_GuildMater_Complete(nGuildSerial, nNewMasterSerial, nOldMasterSerial)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pPlayer CPlayer
function MainThread.CPlayer__pc_InitClass(pPlayer)
	-- Implementation of this function is optional
end
--]]

--[[
---@param pPlayer CPlayer
---@param wSelClassIndex integer
function MainThread.CPlayer__SendMsg_SelectClassResult(pPlayer, wSelClassIndex)
	-- Implementation of this function is optional
end
--]]