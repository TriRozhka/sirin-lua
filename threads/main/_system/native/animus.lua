---@type table
local sirinAnimusMgr = {}

---@param pAnimus CAnimus
---@param pAT CAttack
function sirinAnimusMgr.calcAttExpForPlayer(pAnimus, pAT)
	if pAnimus:IsInTown() then
		return
	end

	local pPlayer = pAnimus.m_pMaster
	local nAnimusLv = pAnimus:GetLevel()
	local bExpForAnimus = true

	if nAnimusLv - 1 >= 50 and pPlayer:GetLevel() < nAnimusLv - 1 then
		bExpForAnimus = false
	end

	local nDamagedObjNum = pAT.m_nDamagedObjNum - 1

	for i = 0, nDamagedObjNum do
		repeat
			local pList = pAT:m_DamList_get(i)
			local pDst = pList.m_pChar
			local nDam = pList.m_nDamage
			local nDstLv = pDst:GetLevel()
			local bExpForMaster, bGetAttExp = PlayerMgr.isPassExpLimitLvDiff(pPlayer, nDstLv)

			if (not bExpForMaster and not bExpForAnimus) or math.abs(nAnimusLv - nDstLv) > 10 or pDst.m_ObjID.m_byID ~= ID_CHAR.monster or nDam < 1 then
				break
			end

			local pMonFld = Sirin.mainThread.baseToMonsterCharacter(pDst.m_pRecordSet)
			local nHPLeft = pDst:GetHP() - nDam

			if pMonFld.m_bMonsterCondition then -- CMonster::IsBossMonster()
				bGetAttExp = false
			end

			if bGetAttExp and bExpForAnimus then
				local nHPConsumed = nDam

				if nHPLeft < 0 then
					nHPConsumed = pDst:GetHP()
				end

				pAnimus:AlterExp(math.floor(pMonFld.m_fExt * 0.7 * nHPConsumed / pMonFld.m_fMaxHP + nDstLv))
			end

			if nHPLeft < 0 then
				nHPLeft = 0
			end

			if nHPLeft == 0 then
				local fExp = pMonFld.m_fExt * 0.3
				local pMon = Sirin.mainThread.objectToMonster(pDst)

				if (pMon.m_nCommonStateChunk >> 2) & 7 == 4 then -- CMonster::GetEmotionState()
					fExp = pMonFld.m_fExt * 0.5
				end

				if pPlayer.m_pPartyMgr:IsPartyMode() then
					local pPartyList = pPlayer:_GetPartyMemberInCircle(true)

					if #pPartyList > 0 then
						fExp = fExp * ExpDivUnderParty_Kill[#pPartyList]
					end

					local nTotalLevel = 0
					---@type table<integer, integer>
					local nPartyLvWeight = {}

					for k,v in pairs(pPartyList) do
						nPartyLvWeight[k] = v:GetLevel() ^ 3
						nTotalLevel = nTotalLevel + nPartyLvWeight[k]
					end

					for k,v in pairs(pPartyList) do
						local fPartyExp =  fExp * nPartyLvWeight[k] / nTotalLevel

						if fPartyExp >= 1.0 then
							if IsSameObject(v, pPlayer) then
								if bExpForAnimus then
									pAnimus:AlterExp(math.floor(fPartyExp / 500 + nDstLv))
								end
							else

							end

							if (SERVER_AOP and bExpForMaster) or not SERVER_AOP then
								if v:IsRidingUnit() then
									if SERVER_AOP then
										v:AlterExp(fPartyExp, false, false, false)
									end

									v:Emb_AlterStat(MTY_CODE.special, 0, math.floor(fPartyExp / 180 + nDstLv), 0, "Lua. sirinAnimusMgr.calcAttExpForPlayer() -- 1", true)
								else
									v:AlterExp(fPartyExp, false, false, false)
								end
							end

							if SERVER_AOP and not IsSameObject(v, pPlayer) and v.m_pRecalledAnimusChar then
								v.m_pRecalledAnimusChar:AlterExp(math.floor(fPartyExp / 5000 + nDstLv))
							end
						end
					end
				else
					if SERVER_AOP and bExpForMaster then
						if pPlayer:IsRidingUnit() then
							if SERVER_AOP then
								pPlayer:AlterExp(fExp, false, false, false)
							end

							pPlayer:Emb_AlterStat(MTY_CODE.special, 0, math.floor(fExp / 180 + nDstLv), 0, "Lua. sirinAnimusMgr.calcAttExpForPlayer() -- 2", true)
						else
							pPlayer:AlterExp(fExp, false, false, false)
						end
					end

					if (SERVER_AOP and bExpForAnimus) or not SERVER_AOP then
						pAnimus:AlterExp(math.floor(fExp / 500 + nDstLv))
					end
				end
			end

		until true
	end
end

return sirinAnimusMgr
