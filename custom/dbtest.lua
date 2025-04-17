require ('_system.enum.SQL_Globals')

local function defaultHandler() end

local dbTest = {}

---@param case integer
function dbTest.worldDBThreadAsyncCallbackHandler(case)
	if dbTest.dbCase[case] then
		local ret = dbTest.dbCase[case]()

		if ret then
			Sirin.processAsyncCallback(0, 'sirin.guard.mainThread', 'SirinLua', 'asyncHandler', case, ret)
		end
	else
		print("Lua. worldDB thread task handler. invalid case:" .. case)
	end
end

---@param case integer
---@param param? CSQLResultSet
function dbTest.mainThreadAsyncCallbackHandler(case, param)
	if dbTest.mainCase[case] then
		dbTest.mainCase[case](param)
	else
		print("Lua. worldDB thread callback handler. invalid case:" .. case)
	end
end

function dbTest.insert()
	local AffectedRowNum = 0
	local sqlRet = SQL_SUCCESS
	local pszQuery = "{ CALL Sirin_InsertTestData ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ) }"
	local buf = Sirin.CBinaryData(256)

	repeat
		buf:PushUInt8(0)
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLBindParam(1, SQL_PARAM_INPUT, SQL_C_BIT, SQL_BIT, 0, 0, buf, 1)
		if sqlRet ~= SQL_SUCCESS then break end

		buf:PushInt8(-1)
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLBindParam(2, SQL_PARAM_INPUT, SQL_C_UTINYINT, SQL_TINYINT, 0, 0, buf, 1)
		if sqlRet ~= SQL_SUCCESS then break end

		buf:PushUInt16(0xFFFF)
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLBindParam(3, SQL_PARAM_INPUT, SQL_C_SSHORT, SQL_SMALLINT, 0, 0, buf, 2)
		if sqlRet ~= SQL_SUCCESS then break end

		buf:PushUInt32(0xFFFFFFFF)
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLBindParam(4, SQL_PARAM_INPUT, SQL_C_SLONG, SQL_INTEGER, 0, 0, buf, 4)
		if sqlRet ~= SQL_SUCCESS then break end

		buf:PushUInt64(0)
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLBindParam(5, SQL_PARAM_INPUT, SQL_C_SBIGINT, SQL_BIGINT, 0, 0, buf, 8)
		if sqlRet ~= SQL_SUCCESS then break end

		buf:PushFloat(6.12345678901)
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLBindParam(6, SQL_PARAM_INPUT, SQL_C_FLOAT, SQL_REAL, 0, 0, buf, 4)
		if sqlRet ~= SQL_SUCCESS then break end

		buf:PushDouble(7.123456789012345)
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLBindParam(7, SQL_PARAM_INPUT, SQL_C_DOUBLE, SQL_FLOAT, 0, 0, buf, 8)
		if sqlRet ~= SQL_SUCCESS then break end

		buf:PushSQLTimeStampStruct(2025, 3, 31, 4, 28, 15, 123)
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLBindParam(8, SQL_PARAM_INPUT, SQL_C_TYPE_TIMESTAMP, SQL_TYPE_TIMESTAMP, 23, 3, buf, 16, 16)
		if sqlRet ~= SQL_SUCCESS then break end

		buf:PushSQLTimeStampStruct(2025, 3, 31, 4, 28, 15, 456)
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLBindParam(9, SQL_PARAM_INPUT, SQL_C_TYPE_TIMESTAMP, SQL_TYPE_TIMESTAMP, 23, 3, buf, 16, 16)
		if sqlRet ~= SQL_SUCCESS then break end

		buf:PushString("test string data", 32)
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLBindParam(10, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_VARCHAR, 32, 0, buf, 32, SQL_NTS)
		if sqlRet ~= SQL_SUCCESS then break end

		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLExecDirect(pszQuery, SQL_NTS)

		if sqlRet ~= SQL_SUCCESS and sqlRet ~= SQL_SUCCESS_WITH_INFO then
			break
		else
			sqlRet, AffectedRowNum = Sirin.worldDBThread.g_WorldDatabaseEx:SQLRowCount()
		end

	until true

	if sqlRet ~= SQL_SUCCESS and sqlRet ~= SQL_SUCCESS_WITH_INFO then
		Sirin.worldDBThread.g_WorldDatabaseEx:ErrorAction(sqlRet, pszQuery, "dbTest.callbackHandler()")
	end

	sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLFreeStmt(SQL_CLOSE)

	if sqlRet ~= SQL_SUCCESS and sqlRet ~= SQL_SUCCESS_WITH_INFO then
		Sirin.worldDBThread.g_WorldDatabaseEx:ErrorAction(sqlRet, "SQLFreeStmt", "dbTest.callbackHandler()")
	end

	print(AffectedRowNum)
end

function dbTest.select()
	local set = nil
	local sqlRet = SQL_SUCCESS
	local pszQuery = "{ CALL Sirin_SelectTestData }"

	repeat
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLExecDirect(pszQuery, SQL_NTS)

		if sqlRet ~= SQL_SUCCESS and sqlRet ~= SQL_SUCCESS_WITH_INFO then
			if sqlRet == SQL_NO_DATA then
				sqlRet = SQL_SUCCESS
				set = Sirin.CSQLResultSet(84)
			end
		else
			sqlRet, set = Sirin.worldDBThread.g_WorldDatabaseEx:FetchSelected(84)
		end

	until true

	if sqlRet ~= SQL_SUCCESS and sqlRet ~= SQL_SUCCESS_WITH_INFO then
		Sirin.worldDBThread.g_WorldDatabaseEx:ErrorAction(sqlRet, pszQuery, "dbTest.select()")
		set = nil
	end

	sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLFreeStmt(SQL_CLOSE)

	if sqlRet ~= SQL_SUCCESS and sqlRet ~= SQL_SUCCESS_WITH_INFO then
		Sirin.worldDBThread.g_WorldDatabaseEx:ErrorAction(sqlRet, "SQLFreeStmt", "dbTest.select()")
	end

	return set
end

function dbTest.select2()
	local set = nil
	local sqlRet = SQL_SUCCESS
	local pszQuery = "SELECT CAST([ItemCode] AS binary(8)) FROM tbl_sirin_chargeItem"

	repeat
		sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLExecDirect(pszQuery, SQL_NTS)

		if sqlRet ~= SQL_SUCCESS and sqlRet ~= SQL_SUCCESS_WITH_INFO then
			if sqlRet == SQL_NO_DATA then
				sqlRet = SQL_SUCCESS
				set = Sirin.CSQLResultSet(8)
			end
		else
			sqlRet, set = Sirin.worldDBThread.g_WorldDatabaseEx:FetchSelected(8)
		end

	until true

	if sqlRet ~= SQL_SUCCESS and sqlRet ~= SQL_SUCCESS_WITH_INFO then
		Sirin.worldDBThread.g_WorldDatabaseEx:ErrorAction(sqlRet, pszQuery, "dbTest.select2()")
		set = nil
	end

	sqlRet = Sirin.worldDBThread.g_WorldDatabaseEx:SQLFreeStmt(SQL_CLOSE)

	if sqlRet ~= SQL_SUCCESS and sqlRet ~= SQL_SUCCESS_WITH_INFO then
		Sirin.worldDBThread.g_WorldDatabaseEx:ErrorAction(sqlRet, "SQLFreeStmt", "dbTest.select2()")
	end

	return set
end

---@param set? CSQLResultSet
function dbTest.result(set)
	if not set then return end

	local serial, a, b, c, d, e, f, g, h, hh, k, l

	local ret = set:GetList()

	for _,v in ipairs(ret) do
		local succ, param = v:PopInt32()

		if not succ then
			print "failed to read serial"
			break
		else
			serial = param
		end

		succ, param = v:PopInt8()

		if not succ then
			print "failed to read a"
			break
		else
			a = param
		end

		succ, param = v:PopInt8()

		if not succ then
			print "failed to read b"
			break
		else
			b = param
		end

		succ, param = v:PopInt16()

		if not succ then
			print "failed to read c"
			break
		else
			c = param
		end

		succ, param = v:PopInt32()

		if not succ then
			print "failed to read d"
			break
		else
			d = param
		end

		succ, param = v:PopInt64()

		if not succ then
			print "failed to read e"
			break
		else
			e = param
		end

		succ, param = v:PopFloat()

		if not succ then
			print "failed to read f"
			break
		else
			f = param
		end

		succ, param = v:PopDouble()

		if not succ then
			print "failed to read g"
			break
		else
			g = param
		end

		succ, param = v:PopSQLTimeStampStruct()

		if not succ then
			print "failed to read h"
			break
		else
			h = os.time(param)
			hh = param.ms or 0
		end

		succ, param = v:PopString(32)

		if not succ then
			print "failed to read k"
			break
		else
			k = param
		end

		succ, param = v:PopInt32()

		if not succ then
			print "failed to read l"
			break
		else
			l = param
		end

		print(string.format("%d %s %d %d %d %d %.7f %.15f %s %d '%s' %d",
			serial, (a ~= 0 and "true" or "false"), b, c, d, e, f, g, os.date("%c", h), hh, k, l
		))
	end
end

---@param set? CSQLResultSet
function dbTest.result2(set)
	if not set then return end

	local ret = set:GetList()

	for _,v in ipairs(ret) do

		local succ, param = v:PopString(8)

		if not succ then
			print "failed to read k"
			break
		end

		print(string.format("'%s'", param))
	end
end

dbTest.dbCase = {
	dbTest.insert,
	dbTest.select,
	dbTest.select2,
}

dbTest.mainCase = {
	defaultHandler,
	dbTest.result,
	dbTest.result2,
}

return dbTest
