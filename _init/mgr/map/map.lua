---@class (exact) sirinMap
---@field __index table
local sirinMap = {}

---@return sirinMap self
function sirinMap:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

MapMgr = sirinMap:new()

---@param pMap CMapData
---@param wLayerIndex integer
function sirinMap:clearLayer(pMap, wLayerIndex)
	repeat
		if pMap.m_pMapSet.m_nMapType == 0 or wLayerIndex >= pMap.m_pMapSet.m_nLayerNum then
			break
		end

		local ls = pMap:m_ls_get(wLayerIndex)

		if not ls:IsActiveLayer() then
			break
		end

		---@type table<integer, CItemBox>
		local LootList = {}
		---@type table<integer, CParkingUnit>
		local ParkingUnitList = {}
		---@type table<integer, CMonster>
		local MonsterList = {}
		---@type table<integer, CReturnGate>
		local ReturnGateList = {}
		---@type table<integer, CGuardTower>
		local TowerList = {}
		---@type table<integer, CTrap>
		local TrapList = {}
		---@type table<integer, CPlayer>
		local PlayerList = {}

		for i = 0, pMap.m_SecInfo.m_nSecNum - 1 do
			repeat
				local pObjList = pMap:GetSectorListObj(wLayerIndex, i)

				if not pObjList then
					break
				end

				local pPoint = pObjList.m_Head.m_pNext

				repeat
					if pPoint == pObjList.m_Tail then
						break
					end

					local pObj = pPoint.m_pItem
					pPoint = pPoint.m_pNext

					if pObj.m_ObjID.m_byKind == OBJ_KIND.item then
						if pObj.m_ObjID.m_byID == ID_ITEM.itembox then
							table.insert(LootList, Sirin.mainThread.objectToItemBox(pObj))
						elseif pObj.m_ObjID.m_byID == ID_ITEM.parking_unit then
							table.insert(ParkingUnitList, Sirin.mainThread.objectToParkingUnit(pObj))
						elseif pObj.m_ObjID.m_byID == ID_ITEM.return_gate then
							table.insert(ReturnGateList, Sirin.mainThread.objectToReturnGate(pObj))
						else
							print(string.format("Lua. clearLayer: Invalid item object ID %d", pObj.m_ObjID.m_byID))
						end
					else
						if pObj.m_ObjID.m_byID == ID_CHAR.player then
							table.insert(PlayerList, Sirin.mainThread.objectToPlayer(pObj))
						elseif pObj.m_ObjID.m_byID == ID_CHAR.monster then
							table.insert(MonsterList, Sirin.mainThread.objectToMonster(pObj))
						elseif pObj.m_ObjID.m_byID == ID_CHAR.tower then
							table.insert(TowerList, Sirin.mainThread.objectToTower(pObj))
						elseif pObj.m_ObjID.m_byID == ID_CHAR.trap then
							table.insert(TrapList, Sirin.mainThread.objectToTrap(pObj))
						else
							print(string.format("Lua. clearLayer: Invalid character object ID %d", pObj.m_ObjID.m_byID))
						end
					end
				until false
			until true
		end

		for _,v in ipairs(LootList) do
			v:Destroy()
		end

		for _,v in ipairs(ParkingUnitList) do
			v.m_pOwner:ForcePullUnit(false)
		end

		for _,v in ipairs(MonsterList) do
			v:Destroy(1, nil)
		end

		for _,v in ipairs(ReturnGateList) do
			v:Close()
		end

		for _,v in ipairs(TowerList) do
			v.m_pMasterTwr:_TowerReturn(v.m_pItem)
		end

		for _,v in ipairs(TrapList) do
			if not v.m_pMaster then
				v:Destroy(3)
			else
				v.m_pMaster:_TrapReturn(v, PlayerMgr.GetIncompleteStackSerial(v.m_pMaster, TBL_CODE.trap, v.m_pRecordSet.m_dwIndex, 1))
			end
		end

		for _,v in ipairs(PlayerList) do
			---@type CMapData
			local pDstMap
			---@type number
			local x, y, z

			if v:OutOfMap(pDstMap, 0, 4, x, y, x) then
				local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
				buf:Init()

				buf:PushUInt8(0)
				buf:PushUInt8(pDstMap.m_pMapSet.m_dwIndex)
				buf:PushFloat(x)
				buf:PushFloat(y)
				buf:PushFloat(z)
				buf:PushUInt8(4)

				buf:SendBuffer(v, 4, 29)
			end
		end
	until true
end