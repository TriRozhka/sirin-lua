---@meta

---@type any Placeholder arg for lua funcs
_ = nil

---@type boolean Configuration definition in init.lua
SERVER_AOP = false
---@type boolean Configuration definition in init.lua
SERVER_2232 = false

---@class (exact) Sirin
---@field NATS NATS
---@field worldDBThread worldDBThread
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
---@field voidToSQLResultSet fun(ptr: lightuserdata): CSQLResultSet
---@field sqlResultSetToVoid fun(ptr: CSQLResultSet): lightuserdata
---@field voidToBinaryData fun(ptr: lightuserdata): CBinaryData
---@field binaryDataToVoid fun(ptr: CBinaryData): lightuserdata
Sirin = {}

---@class (exact) NATS
---@field publish fun(pszSubject: string, pszData: string, headers? :table<string, string?>)
---@field initNATS fun()
local NATS = {}

---@class (exact) worldDBThread
---@field g_WorldDatabaseEx CWorldSQLDatabase
local worldDBThread = {}

---@class (exact) CSQLDatabase
local CSQLDatabase = {}
---@param szQuery string
---@param lLen integer SQLINTEGER
---@return integer #SQLRETURN
function CSQLDatabase:SQLExecDirect(szQuery, lLen) end
---@param ipar integer SQLUSMALLINT
---@param fParamType integer SQLSMALLINT
---@param fCType integer SQLSMALLINT
---@param fSqlType integer SQLSMALLINT
---@param cbColDef integer SQLULEN
---@param ibScale any SQLSMALLINT
---@param rgbValue CBinaryData
---@param cbValueMax integer SQLLEN
---@param cbValue? integer SQLLEN
---@return integer #SQLRETURN
function CSQLDatabase:SQLBindParam(ipar, fParamType, fCType, fSqlType, cbColDef, ibScale, rgbValue, cbValueMax, cbValue) end
---@return integer #SQLRETURN
---@return integer #affected row count in last request
function CSQLDatabase:SQLRowCount() end
---@return integer #SQLRETURN
function CSQLDatabase:SQLFetch() end
---@param ColumnNumber integer SQLUSMALLINT
---@param TargetType integer SQLSMALLINT
---@param pData integer CBinaryData
---@param BufferLength integer SQLLEN
---@return integer #SQLRETURN
---@return integer #SQLLEN bytes read
function CSQLDatabase:SQLGetData(ColumnNumber, TargetType, pData, BufferLength) end
---@return integer #SQLRETURN
---@return integer #SQLLEN ParamId
function CSQLDatabase:SQLParamData() end
---@param buf CBinaryData
---@param bufLen integer SQLLEN
---@return integer #SQLRETURN
function CSQLDatabase:SQLPutData(buf, bufLen) end
---@param sqlRet integer SQLRETURN
---@param pszQuery string Failed query
---@param pszInfo string Optional data (function name)
function CSQLDatabase:ErrorAction(sqlRet, pszQuery, pszInfo) end
---@param Option integer SQLUSMALLINT
---@return integer #SQLRETURN
function CSQLDatabase:SQLFreeStmt(Option) end
---@param bSet boolean
function CSQLDatabase:SetAutoCommitMode(bSet) end
---@return boolean
function CSQLDatabase:CommitTransaction() end
---@return boolean
function CSQLDatabase:RollbackTransaction() end
---@param ElementSize integer Total size of single return row
---@return integer #SQLRETURN
---@return CSQLResultSet
function CSQLDatabase:FetchSelected(ElementSize) end

---@class (exact) CWorldSQLDatabase: CSQLDatabase
local CWorldSQLDatabase = {}

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
function CBinaryData:PushString(str, len) end
---@param a1 integer
function CBinaryData:PushInt8(a1) end
---@param a1 integer
function CBinaryData:PushInt16(a1) end
---@param a1 integer
function CBinaryData:PushInt32(a1) end
---@param a1 integer
function CBinaryData:PushInt64(a1) end
---@param a1 integer
function CBinaryData:PushUInt8(a1) end
---@param a1 integer
function CBinaryData:PushUInt16(a1) end
---@param a1 integer
function CBinaryData:PushUInt32(a1) end
---@param a1 integer
function CBinaryData:PushUInt64(a1) end
---@param a1 number
function CBinaryData:PushFloat(a1) end
---@param a1 number
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

---@class UUIDv4
---@field fromStrFactory fun(str: string): UUIDv4
local UUIDv4 = {}
function UUIDv4:rand() end
---@return string
function UUIDv4:str() end

---@class (exact) CAssetController
---@field instance fun(): CAssetController
local CAssetController = {}
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

---@class (exact) CTranslationAsset
---@field instance fun(): CTranslationAsset
local CTranslationAsset = {}
---@param pszMsgID string
---@param t table Translation table
function CTranslationAsset:loadTranslationTable(pszMsgID, t) end

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

---@class (exact) luaThreadManager
---@field LuaGetThread fun(ThreadID: string|integer): ILuaContext
---@field IsExistGlobal fun(Ctx: ILuaContext, pszGlobalName: string): boolean
---@field DeleteGlobal fun(Ctx: ILuaContext, pszGlobalName: string)
---@field CopyToContext fun(DstCtx: ILuaContext, pszDstGlobalname: string, val: any)
---@field CopyFromContext fun(SrcCtx: ILuaContext, pszSrcGlobalname: string): any
local luaThreadManager = {}

---@class (exact) console
---@field LogEx fun(fore: ConsoleForeground, back: ConsoleBackground, fmt: string)
---@field LogEx_NoFile fun(fore: ConsoleForeground, back: ConsoleBackground, fmt: string)
local console = {}

Sirin.NATS = NATS
Sirin.UUIDv4 = UUIDv4
Sirin.CAssetController = CAssetController
Sirin.CLanguageAsset = CLanguageAsset
Sirin.CTranslationAsset = CTranslationAsset
Sirin.luaThreadManager = luaThreadManager
Sirin.console = console
Sirin.worldDBThread = worldDBThread
