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

		if is_sequence(ret) then
			for _,tv in pairs(ret) do
				table.insert(t, tv)
			end
		else
			for tk,tv in pairs(ret) do
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
