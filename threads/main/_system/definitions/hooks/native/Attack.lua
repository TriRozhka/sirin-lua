--[[

Functions, which exists in native RF Online code. Attack related hooks.

--]]

---Purpose: apply damage event.
---Hook positions: 'pre_event'.
---@param pTarget CPlayer
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
local function CPlayer__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial) end

---Purpose: apply damage event.
---Hook positions: 'pre_event'.
---@param pTarget CAnimus
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
local function CAnimus__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial) end

---Purpose: apply damage event.
---Hook positions: 'pre_event'.
---@param pTarget CGuardTower
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
local function CGuardTower__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial) end

---Purpose: apply damage event.
---Hook positions: 'pre_event'.
---@param pTarget CHolyKeeper
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
local function CHolyKeeper__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial) end

---Purpose: apply damage event.
---Hook positions: 'pre_event'.
---@param pTarget CHolyStone
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
local function CHolyStone__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial) end

---Purpose: apply damage event.
---Hook positions: 'pre_event'.
---@param pTarget CTrap
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
local function CTrap__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial) end

---Purpose: apply damage event.
---Hook positions: 'pre_event'.
---@param pTarget CMonster
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
local function CMonster__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial) end

---Purpose: apply damage event.
---Hook positions: 'pre_event'.
---@param pTarget AutominePersonal
---@param nDamage integer
---@param nHPLeft integer
---@param pSrc CCharacter
---@param nAttackType integer
---@param dwAttackSerial integer
local function AutominePersonal__SetDamage(pTarget, nDamage, nHPLeft, pSrc, nAttackType, dwAttackSerial) end

---Purpose: Kill notification to player.
---Hook positions: 'after_event'.
---@param pPlayer CPlayer
---@param pDier CCharacter
local function CPlayer__RecvKillMessage(pPlayer, pDier) end

---Purpose: Animus attack process.
---Hook positions: 'original'.
---@param pAnimus CAnimus
---@param skill integer
---@return boolean
local function CAnimus__Attack(pAnimus, skill) return false end

---Purpose: Animus heal process.
---Hook positions: 'original'.
---@param pAnimus CAnimus
---@param skill integer
---@return boolean
local function CAnimus__Heal(pAnimus, skill) return false end

---Purpose: Tower attack process.
---Hook positions: 'original'.
---@param pTower CGuardTower
---@param pTarget CCharacter
local function CGuardTower__Attack(pTower, pTarget) end

---Purpose: Nuclear bomb detonation notification.
---Hook positions: 'pre_event, original'.
---@param pBomb CNuclearBomb
local function CNuclearBomb__NuclearDamege(pBomb) end

---Purpose: Nuclear Bomb attack process.
---Hook positions: 'original'.
---@param pNuke CNuclearBomb
---@param StartNum integer
---@param Obj_num integer
local function CNuclearBomb__Attack(pNuke, StartNum, Obj_num) end

---Purpose: Trap attack process.
---Hook positions: 'original'.
---@param pTrap CTrap
---@param pTarget CCharacter
local function CTrap__Attack(pTrap, pTarget) end

---Purpose: Monster attack process.
---Hook positions: 'original'.
---@param pMonster CMonster
---@param pDst CCharacter
---@param pskill CMonsterSkill
---@return integer
local function CMonster__Attack(pMonster, pDst, pskill) return 0  end

---Purpose: Player gen attack process.
---Hook positions: 'original'.
---@param pPlayer CPlayer
---@param pDst CCharacter
---@param byAttPart integer
---@param wBulletSerial integer
---@param wEffBtSerial integer
---@param bCount boolean
local function CPlayer__pc_PlayAttack_Gen(pPlayer, pDst, byAttPart, wBulletSerial, wEffBtSerial, bCount) end

---Purpose: Player skill attack process.
---Hook positions: 'original'.
---@param pPlayer CPlayer
---@param pDst CCharacter
---@param x number
---@param y number
---@param z number
---@param byEffectCode integer
---@param wSkillIndex  integer
---@param wBulletSerial integer
---@param consumeSerial_1 integer
---@param consumeSerial_2 integer
---@param consumeSerial_3 integer
---@param wEffBtSerial integer
local function CPlayer__pc_PlayAttack_Skill(pPlayer, pDst, x, y, z, byEffectCode, wSkillIndex, wBulletSerial, consumeSerial_1, consumeSerial_2, consumeSerial_3, wEffBtSerial) end

---Purpose: Player force attack process.
---Hook positions: 'original'.
---@param pPlayer CPlayer
---@param pDst CCharacter
---@param x number
---@param y number
---@param z number
---@param wForceSerial integer
---@param consumeSerial_1 integer
---@param consumeSerial_2 integer
---@param consumeSerial_3 integer
---@param wEffBtSerial integer
local function CPlayer__pc_PlayAttack_Force(pPlayer, pDst, x, y, z, wForceSerial, consumeSerial_1, consumeSerial_2, consumeSerial_3, wEffBtSerial) end

---Purpose: Player MAU attack process.
---Hook positions: 'original'.
---@param pPlayer CPlayer
---@param pDst CCharacter
---@param byWeaponPart integer
local function CPlayer__pc_PlayAttack_Unit(pPlayer, pDst, byWeaponPart) end

---Purpose: Player siege kit attack process.
---Hook positions: 'original'.
---@param pPlayer  CPlayer
---@param pDst CCharacter
---@param x number
---@param y number
---@param z number
---@param byAttPart integer
---@param wBulletSerial integer
---@param wEffBtSerial integer
local function CPlayer__pc_PlayAttack_Siege(pPlayer, pDst, x, y, z, byAttPart, wBulletSerial, wEffBtSerial) end

---Purpose: Player self destruction attack process.
---Hook positions: 'original'.
---@param pPlayer CPlayer
local function CPlayer__pc_PlayAttack_SelfDestruction(pPlayer) end

---Purpose: `flash` type attack process.
---Hook positions: 'original'.
---@param pAttack CAttack
---@param nLimDist integer
---@param nAttPower integer
---@param nAngle integer
---@param nEffAttPower integer
---@param bUseEffBullet boolean
local function CAttack__FlashDamageProc(pAttack, nLimDist, nAttPower, nAngle, nEffAttPower, bUseEffBullet) end

---Purpose: `area` type attack process.
---Hook positions: 'original'.
---@param pAttack CAttack
---@param nLimitRadius integer
---@param nAttPower integer
---@param x number
---@param y number
---@param z number
---@param nEffAttPower integer
---@param bUseEffBullet boolean
local function CAttack__AreaDamageProc(pAttack, nLimitRadius, nAttPower, x, y, z, nEffAttPower, bUseEffBullet) end

---Purpose: `sector` type attack process.
---Hook positions: 'original'.
---@param pAttack CAttack
---@param nSkillLv integer
---@param nAttPower integer
---@param nAngle integer
---@param nShotNum integer
---@param nWeaponRange integer
---@param nEffAttPower integer
---@param bUseEffBullet boolean
local function CAttack__SectorDamageProc(pAttack, nSkillLv, nAttPower, nAngle, nShotNum, nWeaponRange, nEffAttPower, bUseEffBullet) end

---Purpose: final damage calculation.
---Hook positions: 'original'.
---@param pCharacter CCharacter
---@param nAttPnt integer
---@param nAttPart integer
---@param nTolType TOL_CODE|integer
---@param pDst CCharacter
---@param bBackAttack boolean
---@return integer
local function CCharacter__GetAttackDamPoint(pCharacter, nAttPnt, nAttPart, nTolType, pDst, bBackAttack) return 0 end
