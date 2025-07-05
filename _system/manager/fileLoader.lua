---@class FileLoader
---@field LoadChunkedTable fun(strPath: string, bMerge?: boolean): table<any, any>|nil
FileLoader = {}

local function is_sequence(t)
	local c = 0

	for k in pairs(t) do
		c = c + 1
	end

	local l = #t

	if c ~= l then
		return false
	end

	if t[0] ~= nil then
		return false
	end

	for i = 1, l do
		if t[i] == nil then
			return false
		end
	end

	return true
end

function FileLoader.LoadChunkedTable(folder, bMerge)
	local src = Sirin.getFileList(folder)
	local t = {}
	local tmp = {}
	local bSequence = true
	local bSucc = true

	for _,v in ipairs(src) do
		local f, err = loadfile(v)

		if not f then
			bSucc = false
			print(err)
			break
		end

		local status, ret = pcall(f)

		if not status then
			bSucc = false
			print(ret)
			break
		end

		table.insert(tmp, ret)

		if bSequence then
			bSequence = is_sequence(ret)
		end
	end

	for _,v in ipairs(tmp) do
		if bSequence then
			if #t == 0 then
				t = v
			else
				for _,tv in pairs(v) do
					table.insert(t, tv)
				end
			end
		else
			for tk,tv in pairs(v) do
				if bMerge and type(tv) == "table" then
					if not t[tk] then
						t[tk] = {}
					end

					for _,ttv in pairs(tv) do
						table.insert(t[tk], ttv)
					end
				else
					t[tk] = tv
				end
			end
		end
	end

	if bSucc then
		return t
	else
		return nil
	end
end
