local insert = table.insert
local format = string.format
local tostring = tostring
local type = type

local function serialize(t)
    local mark={}
    local assign={}

    local tb_cache = {}
    local function tb(len)
        if tb_cache[len] then 
            return tb_cache[len]
        end
        local ret = ''
        while len > 1 do
            ret = ret .. '       '
            len = len - 1
        end
        if len >= 1 then
            ret = ret .. '├┄┄'
        end
        tb_cache[len] = ret
        return ret
    end

    local function table2str(t, parent, deep)
        if type(t) == "table" and t.__tostring then 
            return tostring(t)
        end

        deep = deep or 0
        mark[t] = parent
        local ret = {}
		local worker = function(f, v)
            local k = type(f)=="number" and "["..f.."]" or tostring(f)
            local t = type(v)
            if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
                insert(ret, format("%s=%q", k, tostring(v)))
            elseif t == "table" then
                local dotkey = parent..(type(f)=="number" and k or "."..k)
                if mark[v] then
                    insert(assign, dotkey.."="..mark[v])
                else
                    insert(ret, format("%s=%s", k, table2str(v, dotkey, deep + 1)))
                end
            elseif t == "string" then
                insert(ret, format("%s=%q", k, v))
            elseif t == "number" then
                if v == math.huge then
                    insert(ret, format("%s=%s", k, "math.huge"))
                elseif v == -math.huge then
                    insert(ret, format("%s=%s", k, "-math.huge"))
                else
                    insert(ret, format("%s=%s", k, tostring(v)))
                end
            else
                insert(ret, format("%s=%s", k, tostring(v)))
            end
        end
        for k, v in pairs(t) do worker(k, v) end
        return "{\n" .. tb(deep + 2) .. table.concat(ret,",\n" .. tb(deep + 2)) .. '\n' .. tb(deep+1) .."}"
    end

    if type(t) == "table" then
        if t.__tostring then 
            return tostring(t)
        end
        local str = format("%s%s",  table2str(t,"_"), table.concat(assign," "))
        return "\n<<table>>" .. str
    else
        return tostring(t)
    end
end


function dump(...)
	local n = select('#', ...)
	local tb = {}
	table.insert(tb, '\n')

	for i = 1, n do
		local v = select(i, ...)
		local str = serialize(v)
		table.insert(tb, str)
	end

    local ret = table.concat(tb, '  ')
	print(ret)
end


function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end
