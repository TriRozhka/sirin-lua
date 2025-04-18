
local projectName = 'sirin' -- example: MyProject
local moduleName = 'sirinBossLifeAnnounceMgr' -- example: `ModuleMgr` name must be unique across all the code.

local script = {
	m_strUUID = projectName .. ".lua." .. moduleName,
}

local isTransport = false

---@param pMonster CMonster
---@param pData _monster_create_setdata
function script.onMonsterCreate(pMonster, pData)
	if isTransport then
		isTransport = false
	else
		local pMonFld = Sirin.mainThread.baseToMonsterCharacter(pData.m_pRecordSet)

		if pMonFld.m_nMobGrade == 2 and pData.m_pMap.m_pMapSet.m_nMapType == 0 then
			NetMgr.monsterLifeStateInform(
				0, -- message create
				pMonFld,
				pMonster.m_pCurMap
			)
		end
	end
end

---@param pMonster CMonster
---@param byDestroyCode integer
---@param pAttObj CGameObject
function script.onMonsterDestroy(pMonster, byDestroyCode, pAttObj)
	if byDestroyCode ~= 0 then
		return
	end

	local pMonFld = Sirin.mainThread.baseToMonsterCharacter(pMonster.m_pRecordSet)

	if pMonFld.m_nMobGrade == 2 and pMonster.m_pCurMap.m_pMapSet.m_nMapType == 0 then
		NetMgr.monsterLifeStateInform(
			1, -- 1 - msg destroy with killer name, 2 - msg destroy without killer name
			pMonFld,
			pMonster.m_pCurMap,
			pAttObj and pAttObj.m_ObjID.m_byID == 0 and Sirin.mainThread.objectToPlayer(pAttObj) or nil
		)
	end
end

---@param pMonster CMonster
---@param dwOldSerial integer
function script.onMonsterTransport(pMonster, dwOldSerial)
	isTransport = true
end

function script.onThreadBegin()
	-- your optional load state routine here
end

function script.onThreadEnd()
	-- your optional save state routine here
end

local function autoInit()
	if not _G[moduleName] then
		_G[moduleName] = script
		table.insert(SirinLua.onThreadBegin, function() _G[moduleName].onThreadBegin() end)
		table.insert(SirinLua.onThreadEnd, function() _G[moduleName].onThreadEnd() end)
	else
		_G[moduleName] = script
	end

	SirinLua.HookMgr.releaseHookByUID(script.m_strUUID)
	SirinLua.HookMgr.addHook("CMonster__Create", HOOK_POS.after_event, script.m_strUUID, script.onMonsterCreate)
	SirinLua.HookMgr.addHook("CMonster__Destroy", HOOK_POS.pre_event, script.m_strUUID, script.onMonsterDestroy)
	SirinLua.HookMgr.addHook("CMonsterHelper__TransPort", HOOK_POS.after_event, script.m_strUUID, script.onMonsterTransport)

	-- your optional initialization routine below this line

end

autoInit()
