--
-- MobDebug -- Lua remote debugger
-- Copyright 2011-23 Paul Kulchenko
-- Based on RemDebug 1.0 Copyright Kepler Project 2005
--

-- use loaded modules or load explicitly on those systems that require that
local require = require
local io = io or require "io"
local table = table or require "table"
local string = string or require "string"
local coroutine = coroutine or require "coroutine"
local debug = require "debug"
-- protect require "os" as it may fail on embedded systems without os module
local os = os or (function(module)
  local ok, res = pcall(require, module)
  return ok and res or nil
end)("os")

local mobdebug = {
  _NAME = "mobdebug",
  _VERSION = "0.805",
  _COPYRIGHT = "Paul Kulchenko",
  _DESCRIPTION = "Mobile Remote Debugger for the Lua programming language",
  port = os and os.getenv and tonumber((os.getenv("MOBDEBUG_PORT"))) or 8172,
  checkcount = 200,
  yieldtimeout = 0.02, -- yield timeout (s)
  connecttimeout = 2, -- connect timeout (s)
}

local HOOKMASK = "lcr"
local error = error
--local getfenv = getfenv
--local setfenv = setfenv
local getfenv
local setfenv
--local loadstring = loadstring or load -- "load" replaced "loadstring" in Lua 5.2
local loadstring = load -- "load" replaced "loadstring" in Lua 5.2
local pairs = pairs
local setmetatable = setmetatable
local tonumber = tonumber
--local unpack = table.unpack or unpack
local unpack = table.unpack
local rawget = rawget
local gsub, sub, find = string.gsub, string.sub, string.find

-- if strict.lua is used, then need to avoid referencing some global
-- variables, as they can be undefined;
-- use rawget to avoid complaints from strict.lua at run-time.
-- it's safe to do the initialization here as all these variables
-- should get defined values (if any) before the debugging starts.
-- there is also global 'wx' variable, which is checked as part of
-- the debug loop as 'wx' can be loaded at any time during debugging.

local genv = _G or _ENV
local jit = rawget(genv, "jit")
local MOAICoroutine = rawget(genv, "MOAICoroutine")

-- ngx_lua/Openresty requires special handling as its coroutine.*
-- methods use a different mechanism that doesn't allow resume calls
-- from debug hook handlers.
-- Instead, the "original" coroutine.* methods are used.
-- `rawget` needs to be used to protect against `strict` checks
local ngx = rawget(genv, "ngx")
if not ngx then
  -- "older" versions of ngx_lua (0.10.x at least) hide ngx table in metatable,
  -- so need to use that
  local metagindex = getmetatable(genv) and getmetatable(genv).__index
  ngx = type(metagindex) == "table" and metagindex.rawget and metagindex:rawget("ngx") or nil
end
--local corocreate = ngx and coroutine._create or coroutine.create
--local cororesume = ngx and coroutine._resume or coroutine.resume
--local coroyield = ngx and coroutine._yield or coroutine.yield
--local corostatus = ngx and coroutine._status or coroutine.status
local corocreate = coroutine.create
local cororesume = coroutine.resume
local coroyield = coroutine.yield
local corostatus = coroutine.status
local corowrap = coroutine.wrap

--if not setfenv then -- Lua 5.2+
  -- based on http://lua-users.org/lists/lua-l/2010-06/msg00314.html
  -- this assumes f is a function
  local function findenv(f)
    if not debug.getupvalue then return nil end
    local level = 1
    repeat
      local name, value = debug.getupvalue(f, level)
      if name == '_ENV' then return level, value end
      level = level + 1
    until name == nil
    return nil end
  getfenv = function (f) return(select(2, findenv(f)) or _G) end
  setfenv = function (f, t)
    local level = findenv(f)
    if level then debug.setupvalue(f, level, t) end
    return f end
--end

-- check for OS and convert file names to lower case on windows
-- (its file system is case insensitive, but case preserving), as setting a
-- breakpoint on x:\Foo.lua will not work if the file was loaded as X:\foo.lua.
-- OSX and Windows behave the same way (case insensitive, but case preserving).
-- OSX can be configured to be case-sensitive, so check for that. This doesn't
-- handle the case of different partitions having different case-sensitivity.
local win = os and os.getenv and (os.getenv('WINDIR') or (os.getenv('OS') or ''):match('[Ww]indows')) and true or false
local mac = not win and (os and os.getenv and os.getenv('DYLD_LIBRARY_PATH') or not io.open("/proc")) and true or false
local iscasepreserving = win or (mac and io.open('/library') ~= nil)

-- turn jit off based on Mike Pall's comment in this discussion:
-- http://www.freelists.org/post/luajit/Debug-hooks-and-JIT,2
-- "You need to turn it off at the start if you plan to receive
-- reliable hook calls at any later point in time."
if jit and jit.off then jit.off() end

local socket = require('_system.utility.socket')
local coro_debugger
local coro_debugee
local coroutines = {}; setmetatable(coroutines, {__mode = "k"}) -- "weak" keys
local events = { BREAK = 1, WATCH = 2, RESTART = 3, STACK = 4 }
local breakpoints = {}
local watches = {}
local lastsource
local lastfile
local watchescnt = 0
local abort -- default value is nil; this is used in start/loop distinction
local seen_hook = false
local checkcount = 0
local step_into = false
---@type boolean|thread|string
local step_over = false
local step_level = 0
local stack_level = 0
local SAFEWS = "\012" -- "safe" whitespace value
local server
local buf
local outputs = {}
local iobase = {print = print}
local basedir = ""
local deferror = "execution aborted at default debugee"
local debugee = function ()
  local a = 1
  for _ = 1, 10 do a = a + 1 end
  error(deferror)
end
local function q(s) return string.gsub(s, '([%(%)%.%%%+%-%*%?%[%^%$%]])','%%%1') end

mobdebug.line = SRP.line
mobdebug.dump = SRP.dump
mobdebug.linemap = nil
mobdebug.loadstring = loadstring

local function removebasedir(path, basedir)
  if iscasepreserving then
    -- check if the lowercased path matches the basedir
    -- if so, return substring of the original path (to not lowercase it)
    return path:lower():find('^'..q(basedir:lower()))
      and path:sub(#basedir+1) or path
  else
    return string.gsub(path, '^'..q(basedir), '')
  end
end

local function stack(start)
  local function vars(f)
    local func = debug.getinfo(f, "f").func
    local i = 1
    local locals = {}
    -- get locals
    while true do
      local name, value = debug.getlocal(f, i)
      if not name then break end
      if string.sub(name, 1, 1) ~= '(' then
        locals[name] = {value, select(2,pcall(tostring,value))}
      end
      i = i + 1
    end
    -- get varargs (these use negative indices)
    i = 1
    while true do
      local name, value = debug.getlocal(f, -i)
      if not name then break end
      locals[name:gsub("%)$"," "..i..")")] = {value, select(2,pcall(tostring,value))}
      i = i + 1
    end
    -- get upvalues
    i = 1
    local ups = {}
    while func and debug.getupvalue do -- check for func as it may be nil for tail calls
      local name, value = debug.getupvalue(func, i)
      if not name then break end
      ups[name] = {value, select(2,pcall(tostring,value))}
      i = i + 1
    end
    return locals, ups
  end

  local stack = {}
  local linemap = mobdebug.linemap
  for i = (start or 0), 100 do
    local source = debug.getinfo(i, "Snl")
    if not source then break end

    local src = source.source
    if src:find("@") == 1 then
      src = src:sub(2):gsub("\\", "/")
      if src:find("%./") == 1 then src = src:sub(3) end
    end

    table.insert(stack, { -- remove basedir from source
      {source.name, removebasedir(src, basedir),
       linemap and linemap(source.linedefined, source.source) or source.linedefined,
       linemap and linemap(source.currentline, source.source) or source.currentline,
       source.what, source.namewhat, source.short_src},
      vars(i+1)})
  end
  return stack
end

local full_path

local function set_breakpoint(file, line)
	if not full_path then full_path = string.sub(package.path, 1, string.find(package.path, "?") - 1); full_path = full_path:gsub("\\", "/") end
	file = full_path .. file
  if file == '-' and lastfile then file = lastfile
  elseif iscasepreserving then file = string.lower(file) end
  if not breakpoints[line] then breakpoints[line] = {} end
  breakpoints[line][file] = true
end

local function remove_breakpoint(file, line)
	if not full_path then full_path = string.sub(package.path, 1, string.find(package.path, "?") - 1); full_path = full_path:gsub("\\", "/") end
	file = full_path .. file
  if file == '-' and lastfile then file = lastfile
  elseif file == '*' and line == 0 then breakpoints = {}
  elseif iscasepreserving then file = string.lower(file) end
  if breakpoints[line] then breakpoints[line][file] = nil end
end

local function has_breakpoint(file, line)
  return breakpoints[line]
     and breakpoints[line][iscasepreserving and string.lower(file) or file]
end

local function restore_vars(vars)
  if type(vars) ~= 'table' then return end

  -- locals need to be processed in the reverse order, starting from
  -- the inner block out, to make sure that the localized variables
  -- are correctly updated with only the closest variable with
  -- the same name being changed
  -- first loop find how many local variables there is, while
  -- the second loop processes them from i to 1
  local i = 1
  while true do
    local name = debug.getlocal(3, i)
    if not name then break end
    i = i + 1
  end
  i = i - 1
  local written_vars = {}
  while i > 0 do
    local name = debug.getlocal(3, i)
    if not written_vars[name] then
      if string.sub(name, 1, 1) ~= '(' then
        debug.setlocal(3, i, rawget(vars, name))
      end
      written_vars[name] = true
    end
    i = i - 1
  end

  i = 1
  local func = debug.getinfo(3, "f").func
  while debug.getupvalue do
    local name = debug.getupvalue(func, i)
    if not name then break end
    if not written_vars[name] then
      if string.sub(name, 1, 1) ~= '(' then
        debug.setupvalue(func, i, rawget(vars, name))
      end
      written_vars[name] = true
    end
    i = i + 1
  end
end

local function capture_vars(level, thread)
  level = (level or 0)+2 -- add two levels for this and debug calls
  local func = (thread and debug.getinfo(thread, level, "f") or debug.getinfo(level, "f") or {}).func
  if not func then return {} end

  local vars = {['...'] = {}}
  local i = 1
  while debug.getupvalue do
    local name, value = debug.getupvalue(func, i)
    if not name then break end
    if string.sub(name, 1, 1) ~= '(' then vars[name] = value end
    i = i + 1
  end
  i = 1
  while true do
    local name, value
    if thread then
      name, value = debug.getlocal(thread, level, i)
    else
      name, value = debug.getlocal(level, i)
    end
    if not name then break end
    if string.sub(name, 1, 1) ~= '(' then vars[name] = value end
    i = i + 1
  end
  -- get varargs (these use negative indices)
  i = 1
  while true do
    local name, value
    if thread then
      name, value = debug.getlocal(thread, level, -i)
    else
      name, value = debug.getlocal(level, -i)
    end
    if not name then break end
    vars['...'][i] = value
    i = i + 1
  end
  -- returned 'vars' table plays a dual role: (1) it captures local values
  -- and upvalues to be restored later (in case they are modified in "eval"),
  -- and (2) it provides an environment for evaluated chunks.
  -- getfenv(func) is needed to provide proper environment for functions,
  -- including access to globals, but this causes vars[name] to fail in
  -- restore_vars on local variables or upvalues with `nil` values when
  -- 'strict' is in effect. To avoid this `rawget` is used in restore_vars.
  setmetatable(vars, { __index = getfenv(func), __newindex = getfenv(func), __mode = "v" })
  return vars
end

local function stack_depth(start_depth)
  for i = start_depth, 0, -1 do
    if debug.getinfo(i, "l") then return i+1 end
  end
  return start_depth
end

local function is_safe(stack_level)
  -- the stack grows up: 0 is getinfo, 1 is is_safe, 2 is debug_hook, 3 is user function
  if stack_level == 3 then return true end
  for i = 3, stack_level do
    -- return if it is not safe to abort
    local info = debug.getinfo(i, "S")
    if not info then return true end
    if info.what == "C" then return false end
  end
  return true
end

local function in_debugger()
  local this = debug.getinfo(1, "S").source
  -- only need to check few frames as mobdebug frames should be close
  for i = 3, 7 do
    local info = debug.getinfo(i, "S")
    if not info then return false end
    if info.source == this then return true end
  end
  return false
end

local function is_pending(peer)
  -- if there is something already in the buffer, skip check
  if not buf and checkcount >= mobdebug.checkcount then
    peer:settimeout(0) -- non-blocking
    buf = peer:receive(1)
    peer:settimeout() -- back to blocking
    checkcount = 0
  end
  return buf
end

local function readnext(peer, num)
  peer:settimeout(0) -- non-blocking
  local res, err, partial = peer:receive(num)
  peer:settimeout() -- back to blocking
  return res or partial or '', err
end

local function handle_breakpoint(peer)
  -- check if the buffer has the beginning of SETB/DELB command;
  -- this is to avoid reading the entire line for commands that
  -- don't need to be handled here.
  if not buf or not (buf:sub(1,1) == 'S' or buf:sub(1,1) == 'D') then return end

  -- check second character to avoid reading STEP or other S* and D* commands
  if #buf == 1 then buf = buf .. readnext(peer, 1) end
  if buf:sub(2,2) ~= 'E' then return end

  -- need to read few more characters
  buf = buf .. readnext(peer, 5-#buf)
  if buf ~= 'SETB ' and buf ~= 'DELB ' then return end

  local res, _, partial = peer:receive("*l") -- get the rest of the line; blocking
  if not res then
    if partial then buf = buf .. partial end
    return
  end

  local _, _, cmd, file, line = (buf..res):find("^([A-Z]+)%s+(.-)%s+(%d+)%s*$")
  if cmd == 'SETB' then set_breakpoint(file, tonumber(line))
  elseif cmd == 'DELB' then remove_breakpoint(file, tonumber(line))
  else
    -- this looks like a breakpoint command, but something went wrong;
    -- return here to let the "normal" processing to handle,
    -- although this is likely to not go well.
    return
  end

  buf = nil
end

local function normalize_path(file)
  local n
  repeat
    file, n = file:gsub("/+%.?/+","/") -- remove all `//` and `/./` references
  until n == 0
  -- collapse all up-dir references: this will clobber UNC prefix (\\?\)
  -- and disk on Windows when there are too many up-dir references: `D:\foo\..\..\bar`;
  -- handle the case of multiple up-dir references: `foo/bar/baz/../../../more`;
  -- only remove one at a time as otherwise `../../` could be removed;
  repeat
    file, n = file:gsub("[^/]+/%.%./", "", 1)
  until n == 0
  -- there may still be a leading up-dir reference left (as `/../` or `../`); remove it
  return (file:gsub("^(/?)%.%./", "%1"))
end

local function debug_hook(event, line)
  -- (1) LuaJIT needs special treatment. Because debug_hook is set for
  -- *all* coroutines, and not just the one being debugged as in regular Lua
  -- (http://lua-users.org/lists/lua-l/2011-06/msg00513.html),
  -- need to avoid debugging mobdebug's own code as LuaJIT doesn't
  -- always correctly generate call/return hook events (there are more
  -- calls than returns, which breaks stack depth calculation and
  -- 'step' and 'step over' commands stop working; possibly because
  -- 'tail return' events are not generated by LuaJIT).
  -- the next line checks if the debugger is run under LuaJIT and if
  -- one of debugger methods is present in the stack, it simply returns.
  -- ngx_lua/Openresty requires a slightly different handling, as it
  -- creates a coroutine wrapper, so this processing needs to be skipped.
--  if jit and not (ngx and type(ngx) == "table" and ngx.say) then
--    -- when luajit is compiled with LUAJIT_ENABLE_LUA52COMPAT,
--    -- coroutine.running() returns non-nil for the main thread.
--    local coro, main = coroutine.running()
--    if not coro or main then coro = 'main' end
--    local disabled = coroutines[coro] == false
--      or coroutines[coro] == nil and coro ~= (coro_debugee or 'main')
--    if coro_debugee and disabled or not coro_debugee and (disabled or in_debugger()) then
--      return
--    end
--  end

  -- (2) check if abort has been requested and it's safe to abort
  if abort and is_safe(stack_level) then error(abort) end

  -- (3) also check if this debug hook has not been visited for any reason.
  -- this check is needed to avoid stepping in too early
  -- (for example, when coroutine.resume() is executed inside start()).
  if not seen_hook and in_debugger() then return end

  if event == "call" then
    stack_level = stack_level + 1
  elseif event == "return" or event == "tail return" then
    stack_level = stack_level - 1
  elseif event == "line" then
    if mobdebug.linemap then
      local ok, mappedline = pcall(mobdebug.linemap, line, debug.getinfo(2, "S").source)
      if ok then line = mappedline end
      if not line then return end
    end

    -- may need to fall through because of the following:
    -- (1) step_into
    -- (2) step_over and stack_level <= step_level (need stack_level)
    -- (3) breakpoint; check for line first as it's known; then for file
    -- (4) socket call (only do every Xth check)
    -- (5) at least one watch is registered
    if not (
      step_into or step_over or breakpoints[line] or watchescnt > 0
      or is_pending(server)
    ) then checkcount = checkcount + 1; return end

    checkcount = mobdebug.checkcount -- force check on the next command

    -- this is needed to check if the stack got shorter or longer.
    -- unfortunately counting call/return calls is not reliable.
    -- the discrepancy may happen when "pcall(load, '')" call is made
    -- or when "error()" is called in a function.
    -- in either case there are more "call" than "return" events reported.
    -- this validation is done for every "line" event, but should be "cheap"
    -- as it checks for the stack to get shorter (or longer by one call).
    -- start from one level higher just in case we need to grow the stack.
    -- this may happen after coroutine.resume call to a function that doesn't
    -- have any other instructions to execute. it triggers three returns:
    -- "return, tail return, return", which needs to be accounted for.
    stack_level = stack_depth(stack_level+1)

    local caller = debug.getinfo(2, "S")

    -- grab the filename and fix it if needed
    local file = lastfile
    if (lastsource ~= caller.source) then
      file, lastsource = caller.source, caller.source
      -- technically, users can supply names that may not use '@',
      -- for example when they call loadstring('...', 'filename.lua').
      -- Unfortunately, there is no reliable/quick way to figure out
      -- what is the filename and what is the source code.
      -- If the name doesn't start with `@`, assume it's a file name if it's all on one line.
      if find(file, "^@") or not find(file, "[\r\n]") then
        file = gsub(gsub(file, "^@", ""), "\\", "/")
        -- normalize paths that may include up-dir or same-dir references
        -- if the path starts from the up-dir or reference,
        -- prepend `basedir` to generate absolute path to keep breakpoints working.
        -- ignore qualified relative path (`D:../`) and UNC paths (`\\?\`)
        if find(file, "^%.%./") then file = basedir..file end
        if find(file, "/%.%.?/") then file = normalize_path(file) end
        -- need this conversion to be applied to relative and absolute
        -- file names as you may write "require 'Foo'" to
        -- load "foo.lua" (on a case insensitive file system) and breakpoints
        -- set on foo.lua will not work if not converted to the same case.
        if iscasepreserving then file = string.lower(file) end
        if find(file, "^%./") then file = sub(file, 3) end
        -- remove basedir, so that breakpoints are checked properly
        file = gsub(file, "^"..q(basedir), "")
        -- some file systems allow newlines in file names; remove these.
        file = gsub(file, "\n", ' ')
      else
        file = mobdebug.line(file)
      end

      -- set to true if we got here; this only needs to be done once per
      -- session, so do it here to at least avoid setting it for every line.
      seen_hook = true
      lastfile = file
    end

    if is_pending(server) then handle_breakpoint(server) end

    local vars, status, res
    if (watchescnt > 0) then
      vars = capture_vars(1)
      for index, value in pairs(watches) do
        setfenv(value, vars)
        local ok, fired = pcall(value)
        if ok and fired then
          status, res = cororesume(coro_debugger, events.WATCH, vars, file, line, index)
          break -- any one watch is enough; don't check multiple times
        end
      end
    end

    -- need to get into the "regular" debug handler, but only if there was
    -- no watch that was fired. If there was a watch, handle its result.
    local getin = (status == nil) and
      (step_into
      -- when coroutine.running() return `nil` (main thread in Lua 5.1),
      -- step_over will equal 'main', so need to check for that explicitly.
      or (step_over and step_over == (coroutine.running() or 'main') and stack_level <= step_level)
      or has_breakpoint(file, line)
      or is_pending(server))

    if getin then
      vars = vars or capture_vars(1)
      step_into = false
      step_over = false
      status, res = cororesume(coro_debugger, events.BREAK, vars, file, line)
    end

    -- handle 'stack' command that provides stack() information to the debugger
    while status and res == 'stack' do
      -- resume with the stack trace and variables
      if vars then restore_vars(vars) end -- restore vars so they are reflected in stack values
      status, res = cororesume(coro_debugger, events.STACK, stack(3), file, line)
    end

    -- need to recheck once more as resume after 'stack' command may
    -- return something else (for example, 'exit'), which needs to be handled
    if status and res and res ~= 'stack' then
      if not abort and res == "exit" then mobdebug.onexit(1, true); return end
      if not abort and res == "done" then mobdebug.done(); return end
      abort = res
      -- only abort if safe; if not, there is another (earlier) check inside
      -- debug_hook, which will abort execution at the first safe opportunity
      if is_safe(stack_level) then error(abort) end
    elseif not status and res then
      error(res, 2) -- report any other (internal) errors back to the application
    end

    if vars then restore_vars(vars) end

    -- last command requested Step Over/Out; store the current thread
    if step_over == true then step_over = coroutine.running() or 'main' end
  end
end

local function stringify_results(params, status, ...)
  if not status then return status, ... end -- on error report as it

  params = params or {}
  if params.nocode == nil then params.nocode = true end
  if params.comment == nil then params.comment = 1 end

  local t = {}
  for i = 1, select('#', ...) do -- stringify each of the returned values
    local ok, res = pcall(mobdebug.line, select(i, ...), params)
    t[i] = ok and res or ("%q"):format(res):gsub("\010","n"):gsub("\026","\\026")
  end
  -- stringify table with all returned values
  -- this is done to allow each returned value to be used (serialized or not)
  -- intependently and to preserve "original" comments
  return pcall(mobdebug.dump, t, {sparse = false})
end

local function isrunning()
  return coro_debugger and (corostatus(coro_debugger) == 'suspended' or corostatus(coro_debugger) == 'running')
end

-- this is a function that removes all hooks and closes the socket to
-- report back to the controller that the debugging is done.
-- the script that called `done` can still continue.
local function done()
  if not (isrunning() and server) then return end

  if not jit then
    for co, debugged in pairs(coroutines) do
      if debugged then debug.sethook(co) end
    end
  end

  debug.sethook()
  server:close()

  coro_debugger = nil -- to make sure isrunning() returns `false`
  seen_hook = false -- to make sure that the next start() call works
  abort = nil -- to make sure that callback calls use proper "abort" value
  basedir = "" -- to reset basedir in case the same module/state is reused
end

local function debugger_loop(sev, svars, sfile, sline)
  local command
  local eval_env = svars or {}
  local function emptyWatch () return false end
  local loaded = {}
  for k in pairs(package.loaded) do loaded[k] = true end

  while true do
    local line, err
    if mobdebug.yield and server.settimeout then server:settimeout(mobdebug.yieldtimeout) end
    while true do
      line, err = server:receive("*l")
      if not line then
        if err == "timeout" then
          if mobdebug.yield then mobdebug.yield() end
        elseif err == "closed" then
          error("Debugger connection closed", 0)
        else
          error(("Unexpected socket error: %s"):format(err), 0)
        end
      else
        -- if there is something in the pending buffer, prepend it to the line
        if buf then line = buf .. line; buf = nil end
        break
      end
    end
    if server.settimeout then server:settimeout() end -- back to blocking
    command = string.sub(line, string.find(line, "^[A-Z]+") or 0)
    if command == "SETB" then
      local _, _, _, file, line = string.find(line, "^([A-Z]+)%s+(.-)%s+(%d+)%s*$")
      if file and line then
        set_breakpoint(file, tonumber(line))
        server:send("200 OK\n")
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "DELB" then
      local _, _, _, file, line = string.find(line, "^([A-Z]+)%s+(.-)%s+(%d+)%s*$")
      if file and line then
        remove_breakpoint(file, tonumber(line))
        server:send("200 OK\n")
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "EXEC" then
      -- extract any optional parameters
      local params = string.match(line, "--%s*(%b{})%s*$")
      local _, _, chunk = string.find(line, "^[A-Z]+%s+(.+)$")
      if chunk then
        -- \r is optional, as it may be stripped by some luasocket versions, like the one in LOVE2d
        chunk = chunk:gsub("\r?"..SAFEWS, "\n") -- convert safe whitespace back to new line
        local func, res = mobdebug.loadstring(chunk)
        local status
        if func then
          local pfunc = params and loadstring("return "..params) -- use internal function
          params = pfunc and pfunc()
          params = (type(params) == "table" and params or {})
          local stack = tonumber(params.stack)
          -- if the requested stack frame is not the current one, then use a new capture
          -- with a specific stack frame: `capture_vars(0, coro_debugee)`
          local env = stack and coro_debugee and capture_vars(stack-1, coro_debugee) or eval_env
          setfenv(func, env)
          status, res = stringify_results(params, pcall(func, unpack(rawget(env,'...') or {})))
        end
        if status then
          if mobdebug.onscratch then mobdebug.onscratch(res) end
          server:send("200 OK " .. tostring(#res) .. "\n")
          server:send(res)
        else
          -- fix error if not set (for example, when loadstring is not present)
          if not res then res = "Unknown error" end
          server:send("401 Error in Expression " .. tostring(#res) .. "\n")
          server:send(res)
        end
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "LOAD" then
      local _, _, size, name = string.find(line, "^[A-Z]+%s+(%d+)%s+(%S.-)%s*$")
      size = tonumber(size)

      if abort == nil then -- no LOAD/RELOAD allowed inside start()
        if size > 0 then server:receive(size) end
        if sfile and sline then
          server:send("201 Started " .. sfile .. " " .. tostring(sline) .. "\n")
        else
          server:send("200 OK 0\n")
        end
      else
        -- reset environment to allow required modules to load again
        -- remove those packages that weren't loaded when debugger started
        for k in pairs(package.loaded) do
          if not loaded[k] then package.loaded[k] = nil end
        end

        if size == 0 and name == '-' then -- RELOAD the current script being debugged
          server:send("200 OK 0\n")
          coroyield("load")
        else
          -- receiving 0 bytes blocks (at least in luasocket 2.0.2), so skip reading
          local chunk = size == 0 and "" or server:receive(size)
          if chunk then -- LOAD a new script for debugging
            local func, res = mobdebug.loadstring(chunk, "@"..name)
            if func then
              server:send("200 OK 0\n")
              debugee = func
              coroyield("load")
            else
              server:send("401 Error in Expression " .. tostring(#res) .. "\n")
              server:send(res)
            end
          else
            server:send("400 Bad Request\n")
          end
        end
      end
    elseif command == "SETW" then
      local _, _, exp = string.find(line, "^[A-Z]+%s+(.+)%s*$")
      if exp then
        local func, res = mobdebug.loadstring("return(" .. exp .. ")")
        if func then
          watchescnt = watchescnt + 1
          local newidx = #watches + 1
          watches[newidx] = func
          server:send("200 OK " .. tostring(newidx) .. "\n")
        else
          server:send("401 Error in Expression " .. tostring(#res) .. "\n")
          server:send(res)
        end
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "DELW" then
      local _, _, index = string.find(line, "^[A-Z]+%s+(%d+)%s*$")
      index = tonumber(index) or 0
      if index > 0 and index <= #watches then
        watchescnt = watchescnt - (watches[index] ~= emptyWatch and 1 or 0)
        watches[index] = emptyWatch
        server:send("200 OK\n")
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "RUN" then
      server:send("200 OK\n")

      local ev, vars, file, line, idx_watch = coroyield()
      eval_env = vars
      if ev == events.BREAK then
        server:send("202 Paused " .. file .. " " .. tostring(line) .. "\n")
      elseif ev == events.WATCH then
        server:send("203 Paused " .. file .. " " .. tostring(line) .. " " .. tostring(idx_watch) .. "\n")
      elseif ev == events.RESTART then
        -- nothing to do
      else
        server:send("401 Error in Execution " .. tostring(#file) .. "\n")
        server:send(file)
      end
    elseif command == "STEP" then
      server:send("200 OK\n")
      step_into = true

      local ev, vars, file, line, idx_watch = coroyield()
      eval_env = vars
      if ev == events.BREAK then
        server:send("202 Paused " .. file .. " " .. tostring(line) .. "\n")
      elseif ev == events.WATCH then
        server:send("203 Paused " .. file .. " " .. tostring(line) .. " " .. tostring(idx_watch) .. "\n")
      elseif ev == events.RESTART then
        -- nothing to do
      else
        server:send("401 Error in Execution " .. tostring(#file) .. "\n")
        server:send(file)
      end
    elseif command == "OVER" or command == "OUT" then
      server:send("200 OK\n")
      step_over = true

      -- OVER and OUT are very similar except for
      -- the stack level value at which to stop
      if command == "OUT" then step_level = stack_level - 1
      else step_level = stack_level end

      local ev, vars, file, line, idx_watch = coroyield()
      eval_env = vars
      if ev == events.BREAK then
        server:send("202 Paused " .. file .. " " .. tostring(line) .. "\n")
      elseif ev == events.WATCH then
        server:send("203 Paused " .. file .. " " .. tostring(line) .. " " .. tostring(idx_watch) .. "\n")
      elseif ev == events.RESTART then
        -- nothing to do
      else
        server:send("401 Error in Execution " .. tostring(#file) .. "\n")
        server:send(file)
      end
    elseif command == "BASEDIR" then
      local _, _, dir = string.find(line, "^[A-Z]+%s+(.+)%s*$")
      if dir then
        basedir = iscasepreserving and string.lower(dir) or dir
        -- reset cached source as it may change with basedir
        lastsource = nil
        server:send("200 OK\n")
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "SUSPEND" then
      -- do nothing; it already fulfilled its role
    elseif command == "DONE" then
      coroyield("done")
      return -- done with all the debugging
    elseif command == "STACK" then
      -- first check if we can execute the stack command
      -- as it requires yielding back to debug_hook it cannot be executed
      -- if we have not seen the hook yet as happens after start().
      -- in this case we simply return an empty result
      local vars, ev = {}, nil
      if seen_hook then
        ev, vars = coroyield("stack")
      end
      if ev and ev ~= events.STACK then
        server:send("401 Error in Execution " .. tostring(#vars) .. "\n")
        server:send(vars)
      else
        local params = string.match(line, "--%s*(%b{})%s*$")
        local pfunc = params and loadstring("return "..params) -- use internal function
        params = pfunc and pfunc()
        params = (type(params) == "table" and params or {})
        if params.nocode == nil then params.nocode = true end
        if params.sparse == nil then params.sparse = false end
        -- take into account additional levels for the stack frames and data management
        if tonumber(params.maxlevel) then params.maxlevel = tonumber(params.maxlevel)+4 end

        local ok, res = pcall(mobdebug.dump, vars, params)
        if ok then
          server:send("200 OK " .. tostring(res) .. "\n")
        else
          server:send("401 Error in Execution " .. tostring(#res) .. "\n")
          server:send(res)
        end
      end
    elseif command == "OUTPUT" then
      local _, _, stream, mode = string.find(line, "^[A-Z]+%s+(%w+)%s+([dcr])%s*$")
      if stream and mode and stream == "stdout" then
        -- assign "print" in the global environment
        local default = mode == 'd'
        local genv_print = default and iobase.print or corowrap(function()
          -- wrapping into coroutine.wrap protects this function from
          -- being stepped through in the debugger.
          -- don't use vararg (...) as it adds a reference for its values,
          -- which may affect how they are garbage collected
          while true do
            local tbl = {coroutine.yield()}
            if mode == 'c' then iobase.print(unpack(tbl)) end
            for n = 1, #tbl do
              tbl[n] = select(2, pcall(mobdebug.line, tbl[n], {nocode = true, comment = false})) end
            local file = table.concat(tbl, "\t").."\n"
            server:send("204 Output " .. stream .. " " .. tostring(#file) .. "\n" .. file)
          end
        end)
        if not default then genv_print() end -- "fake" print to start printing loop
        server:send("200 OK\n")
      else
        server:send("400 Bad Request\n")
      end
    elseif command == "EXIT" then
      server:send("200 OK\n")
      coroyield("exit")
    else
      server:send("400 Bad Request\n")
    end
  end
end

local function output(stream, data)
  if server then return server:send("204 Output "..stream.." "..tostring(#data).."\n"..data) end
end

local function connect(controller_host, controller_port)
  local sock, err = socket.tcp()
  if not sock then return nil, err end

  if sock.settimeout then sock:settimeout(mobdebug.connecttimeout) end
  local res, err = sock:connect(controller_host, tostring(controller_port))
  if sock.settimeout then sock:settimeout() end

  if not res then return nil, err end
  return sock
end

local lasthost, lastport

-- Starts a debug session by connecting to a controller
local function start(controller_host, controller_port)
  -- only one debugging session can be run (as there is only one debug hook)
  if isrunning() then return end

  lasthost = controller_host or lasthost
  lastport = controller_port or lastport

  controller_host = lasthost or "localhost"
  controller_port = lastport or mobdebug.port

  local err
  server, err = mobdebug.connect(controller_host, controller_port)
  if server then
    -- correct stack depth which already has some calls on it
    -- so it doesn't go into negative when those calls return
    -- as this breaks subsequence checks in stack_depth().
    -- start from 16th frame, which is sufficiently large for this check.
    stack_level = stack_depth(16)

    coro_debugger = corocreate(debugger_loop)
    debug.sethook(debug_hook, HOOKMASK)
    seen_hook = false -- reset in case the last start() call was refused
    step_into = true -- start with step command
    return true
  else
    print(("Could not connect to %s:%s: %s")
      :format(controller_host, controller_port, err or "unknown error"))
  end
end

local function controller(controller_host, controller_port, scratchpad)
  -- only one debugging session can be run (as there is only one debug hook)
  if isrunning() then return end

  lasthost = controller_host or lasthost
  lastport = controller_port or lastport

  controller_host = lasthost or "localhost"
  controller_port = lastport or mobdebug.port

  local exitonerror = not scratchpad
  local err
  server, err = mobdebug.connect(controller_host, controller_port)
  if server then
    local function report(trace, err)
      local msg = err .. "\n" .. trace
      server:send("401 Error in Execution " .. tostring(#msg) .. "\n")
      server:send(msg)
      return err
    end

    seen_hook = true -- allow to accept all commands
    coro_debugger = corocreate(debugger_loop)

    while true do
      step_into = true -- start with step command
      abort = false -- reset abort flag from the previous loop
      if scratchpad then checkcount = mobdebug.checkcount end -- force suspend right away

      coro_debugee = corocreate(debugee)
      debug.sethook(coro_debugee, debug_hook, HOOKMASK)
      local status, err = cororesume(coro_debugee, unpack(arg or {}))

      -- was there an error or is the script done?
      -- 'abort' state is allowed here; ignore it
      if abort then
        if tostring(abort) == 'exit' then break end
      else
        if status then -- no errors
          if corostatus(coro_debugee) == "suspended" then
            -- the script called `coroutine.yield` in the "main" thread
            error("attempt to yield from the main thread", 3)
          end
          break -- normal execution is done
        elseif err and not string.find(tostring(err), deferror) then
          -- report the error back
          -- err is not necessarily a string, so convert to string to report
          report(debug.traceback(coro_debugee), tostring(err))
          if exitonerror then break end
          -- check if the debugging is done (coro_debugger is nil)
          if not coro_debugger then break end
          -- resume once more to clear the response the debugger wants to send
          -- need to use capture_vars(0) to capture only two (default) levels,
          -- as even though there is controller() call, because of the tail call,
          -- the caller may not exist for it;
          -- This is not entirely safe as the user may see the local
          -- variable from console, but they will be reset anyway.
          -- This functionality is used when scratchpad is paused to
          -- gain access to remote console to modify global variables.
          local status, err = cororesume(coro_debugger, events.RESTART, capture_vars(0))
          if not status or status and err == "exit" then break end
        end
      end
    end
  else
    print(("Could not connect to %s:%s: %s")
      :format(controller_host, controller_port, err or "unknown error"))
    return false
  end
  return true
end

local function scratchpad(controller_host, controller_port)
  return controller(controller_host, controller_port, true)
end

local function loop(controller_host, controller_port)
  return controller(controller_host, controller_port, false)
end

local function on()
	if not (isrunning() and server) then return end

	-- main is set to true under Lua5.2 for the "main" chunk.
	-- Lua5.1 returns co as `nil` in that case.
	local co, main = coroutine.running()
--	if main then co = nil end
--	if co then
	if not main then
		coroutines[co] = true
		debug.sethook(co, debug_hook, HOOKMASK)
	else
		if jit then coroutines.main = true end
		debug.sethook(debug_hook, HOOKMASK)
	end
end

local function off()
	if not (isrunning() and server) then return end

	-- main is set to true under Lua5.2 for the "main" chunk.
	-- Lua5.1 returns co as `nil` in that case.
	local co, main = coroutine.running()
--	if main then co = nil end

	-- don't remove coroutine hook under LuaJIT as there is only one (global) hook
--	if co then
	if not main then
		coroutines[co] = false
		if not jit then debug.sethook(co) end
	else
		if jit then coroutines.main = false end
		if not jit then debug.sethook() end
	end

 	-- check if there is any thread that is still being debugged under LuaJIT;
 	-- if not, turn the debugging off
	if jit then
		local remove = true
		for _, debugged in pairs(coroutines) do
			if debugged then remove = false; break end
		end
		if remove then debug.sethook() end
	end
end

-- Handles server debugging commands
local function handle(params, client, options)
  -- when `options.verbose` is not provided, use normal `print`; verbose output can be
  -- disabled (`options.verbose == false`) or redirected (`options.verbose == function()...end`)
  local verbose = not options or options.verbose ~= nil and options.verbose
  local print = verbose and (type(verbose) == "function" and verbose or print) or function(...) end
  local file, line, watch_idx
  local _, _, command = string.find(params, "^([a-z]+)")
  if command == "run" or command == "step" or command == "out"
  or command == "over" or command == "exit" then
    client:send(string.upper(command) .. "\n")
    client:receive("*l") -- this should consume the first '200 OK' response
    while true do
      local done = true
      local breakpoint = client:receive("*l")
      if not breakpoint then
        print("Program finished")
        return nil, nil, false
      end
      local _, _, status = string.find(breakpoint, "^(%d+)")
      if status == "200" then
        -- don't need to do anything
      elseif status == "202" then
        _, _, file, line = string.find(breakpoint, "^202 Paused%s+(.-)%s+(%d+)%s*$")
        if file and line then
          print("Paused at file " .. file .. " line " .. line)
        end
      elseif status == "203" then
        _, _, file, line, watch_idx = string.find(breakpoint, "^203 Paused%s+(.-)%s+(%d+)%s+(%d+)%s*$")
        if file and line and watch_idx then
          print("Paused at file " .. file .. " line " .. line .. " (watch expression " .. watch_idx .. ": [" .. watches[watch_idx] .. "])")
        end
      elseif status == "204" then
        local _, _, stream, size = string.find(breakpoint, "^204 Output (%w+) (%d+)$")
        if stream and size then
          local size = tonumber(size)
          local msg = size > 0 and client:receive(size) or ""
          print(msg)
          if outputs[stream] then outputs[stream](msg) end
          -- this was just the output, so go back reading the response
          done = false
        end
      elseif status == "401" then
        local _, _, size = string.find(breakpoint, "^401 Error in Execution (%d+)$")
        if size then
          local msg = client:receive(tonumber(size))
          print("Error in remote application: " .. msg)
          return nil, nil, msg
        end
      else
        print("Unknown error")
        return nil, nil, "Debugger error: unexpected response '" .. breakpoint .. "'"
      end
      if done then break end
    end
  elseif command == "done" then
    client:send(string.upper(command) .. "\n")
    -- no response is expected
  elseif command == "setb" or command == "asetb" then
    _, _, _, file, line = string.find(params, "^([a-z]+)%s+(.-)%s+(%d+)%s*$")
    if file and line then
      -- if this is a file name, and not a file source
      if not file:find('^".*"$') then
        file = string.gsub(file, "\\", "/") -- convert slash
        file = removebasedir(file, basedir)
      end
      client:send("SETB " .. file .. " " .. line .. "\n")
      if command == "asetb" or client:receive("*l") == "200 OK" then
        set_breakpoint(file, line)
      else
        print("Error: breakpoint not inserted")
      end
    else
      print("Invalid command")
    end
  elseif command == "setw" then
    local _, _, exp = string.find(params, "^[a-z]+%s+(.+)$")
    if exp then
      client:send("SETW " .. exp .. "\n")
      local answer = client:receive("*l")
      local _, _, watch_idx = string.find(answer, "^200 OK (%d+)%s*$")
      if watch_idx then
        watches[watch_idx] = exp
        print("Inserted watch exp no. " .. watch_idx)
      else
        local _, _, size = string.find(answer, "^401 Error in Expression (%d+)$")
        if size then
          local err = client:receive(tonumber(size)):gsub(".-:%d+:%s*","")
          print("Error: watch expression not set: " .. err)
        else
          print("Error: watch expression not set")
        end
      end
    else
      print("Invalid command")
    end
  elseif command == "delb" or command == "adelb" then
    _, _, _, file, line = string.find(params, "^([a-z]+)%s+(.-)%s+(%d+)%s*$")
    if file and line then
      -- if this is a file name, and not a file source
      if not file:find('^".*"$') then
        file = string.gsub(file, "\\", "/") -- convert slash
        file = removebasedir(file, basedir)
      end
      client:send("DELB " .. file .. " " .. line .. "\n")
      if command == "adelb" or client:receive("*l") == "200 OK" then
        remove_breakpoint(file, line)
      else
        print("Error: breakpoint not removed")
      end
    else
      print("Invalid command")
    end
  elseif command == "delallb" then
    local file, line = "*", 0
    client:send("DELB " .. file .. " " .. tostring(line) .. "\n")
    if client:receive("*l") == "200 OK" then
      remove_breakpoint(file, line)
    else
      print("Error: all breakpoints not removed")
    end
  elseif command == "delw" then
    local _, _, index = string.find(params, "^[a-z]+%s+(%d+)%s*$")
    if index then
      client:send("DELW " .. index .. "\n")
      if client:receive("*l") == "200 OK" then
        watches[index] = nil
      else
        print("Error: watch expression not removed")
      end
    else
      print("Invalid command")
    end
  elseif command == "delallw" then
    for index, exp in pairs(watches) do
      client:send("DELW " .. index .. "\n")
      if client:receive("*l") == "200 OK" then
        watches[index] = nil
      else
        print("Error: watch expression at index " .. index .. " [" .. exp .. "] not removed")
      end
    end
  elseif command == "eval" or command == "exec"
      or command == "load" or command == "loadstring"
      or command == "reload" then
    local _, _, exp = string.find(params, "^[a-z]+%s+(.+)$")
    if exp or (command == "reload") then
      if command == "eval" or command == "exec" then
        exp = exp:gsub("\r?\n", "\r"..SAFEWS) -- convert new lines, so the fragment can be passed as one line
        if command == "eval" then exp = "return " .. exp end
        client:send("EXEC " .. exp .. "\n")
      elseif command == "reload" then
        client:send("LOAD 0 -\n")
      elseif command == "loadstring" then
        local _, _, _, file, lines = string.find(exp, "^([\"'])(.-)%1%s(.+)")
        if not file then
           _, _, file, lines = string.find(exp, "^(%S+)%s(.+)")
        end
        client:send("LOAD " .. tostring(#lines) .. " " .. file .. "\n")
        client:send(lines)
      else
        local file = io.open(exp, "r")
--        if not file and pcall(require, "winapi") then
--          -- if file is not open and winapi is there, try with a short path;
--          -- this may be needed for unicode paths on windows
--          winapi.set_encoding(winapi.CP_UTF8)
--          local shortp = winapi.short_path(exp)
--          file = shortp and io.open(shortp, "r")
--        end
        if not file then return nil, nil, "Cannot open file " .. exp end
        -- read the file and remove the shebang line as it causes a compilation error
        local lines = file:read("*all"):gsub("^#!.-\n", "\n")
        file:close()

        local fname = string.gsub(exp, "\\", "/") -- convert slash
        fname = removebasedir(fname, basedir)
        client:send("LOAD " .. tostring(#lines) .. " " .. fname .. "\n")
        if #lines > 0 then client:send(lines) end
      end
      while true do
        local params, err = client:receive("*l")
        if not params then
          return nil, nil, "Debugger connection " .. (err or "error")
        end
        local done = true
        local _, _, status, len = string.find(params, "^(%d+).-%s+(%d+)%s*$")
        if status == "200" then
          len = tonumber(len)
          if len > 0 then
            local status, res
            local str = client:receive(len)
            -- handle serialized table with results
            local func, err = loadstring(str)
            if func then
              status, res = pcall(func)
              if not status then err = res
              elseif type(res) ~= "table" then
                err = "received "..type(res).." instead of expected 'table'"
              end
            end
            if err then
              print("Error in processing results: " .. err)
              return nil, nil, "Error in processing results: " .. err
            end
            print(unpack(res))
            return res[1], res
          end
        elseif status == "201" then
          _, _, file, line = string.find(params, "^201 Started%s+(.-)%s+(%d+)%s*$")
        elseif status == "202" or params == "200 OK" then
          -- do nothing; this only happens when RE/LOAD command gets the response
          -- that was for the original command that was aborted
        elseif status == "204" then
          local _, _, stream, size = string.find(params, "^204 Output (%w+) (%d+)$")
          if stream and size then
            local size = tonumber(size)
            local msg = size > 0 and client:receive(size) or ""
            print(msg)
            if outputs[stream] then outputs[stream](msg) end
            -- this was just the output, so go back reading the response
            done = false
          end
        elseif status == "401" then
          len = tonumber(len)
          local res = client:receive(len)
          print("Error in expression: " .. res)
          return nil, nil, res
        else
          print("Unknown error")
          return nil, nil, "Debugger error: unexpected response after EXEC/LOAD '" .. params .. "'"
        end
        if done then break end
      end
    else
      print("Invalid command")
    end
  elseif command == "listb" then
    for l, v in pairs(breakpoints) do
      for f in pairs(v) do
        print(f .. ": " .. l)
      end
    end
  elseif command == "listw" then
    for i, v in pairs(watches) do
      print("Watch exp. " .. i .. ": " .. v)
    end
  elseif command == "suspend" then
    client:send("SUSPEND\n")
  elseif command == "stack" then
    local opts = string.match(params, "^[a-z]+%s+(.+)$")
    client:send("STACK" .. (opts and " "..opts or "") .."\n")
    local resp = client:receive("*l")
    local _, _, status, res = string.find(resp, "^(%d+)%s+%w+%s+(.+)%s*$")
    if status == "200" then
      local func, err = loadstring(res)
      if func == nil then
        print("Error in stack information: " .. err)
        return nil, nil, err
      end
      local ok, stack = pcall(func)
      if not ok then
        print("Error in stack information: " .. stack)
        return nil, nil, stack
      end
      for _,frame in ipairs(stack) do
        print(mobdebug.line(frame[1], {comment = false}))
      end
      return stack
    elseif status == "401" then
      local _, _, len = string.find(resp, "%s+(%d+)%s*$")
      len = tonumber(len)
      local res = len > 0 and client:receive(len) or "Invalid stack information."
      print("Error in expression: " .. res)
      return nil, nil, res
    else
      print("Unknown error")
      return nil, nil, "Debugger error: unexpected response after STACK"
    end
  elseif command == "output" then
    local _, _, stream, mode = string.find(params, "^[a-z]+%s+(%w+)%s+([dcr])%s*$")
    if stream and mode then
      client:send("OUTPUT "..stream.." "..mode.."\n")
      local resp, err = client:receive("*l")
      if not resp then
        print("Unknown error: "..err)
        return nil, nil, "Debugger connection error: "..err
      end
      local _, _, status = string.find(resp, "^(%d+)%s+%w+%s*$")
      if status == "200" then
        print("Stream "..stream.." redirected")
        outputs[stream] = type(options) == 'table' and options.handler or nil
      -- the client knows when she is doing, so install the handler
      elseif type(options) == 'table' and options.handler then
        outputs[stream] = options.handler
      else
        print("Unknown error")
        return nil, nil, "Debugger error: can't redirect "..stream
      end
    else
      print("Invalid command")
    end
  elseif command == "basedir" then
    local _, _, dir = string.find(params, "^[a-z]+%s+(.+)$")
    if dir then
      dir = string.gsub(dir, "\\", "/") -- convert slash
      if not string.find(dir, "/$") then dir = dir .. "/" end

      local remdir = dir:match("\t(.+)")
      if remdir then dir = dir:gsub("/?\t.+", "/") end
      basedir = dir

      client:send("BASEDIR "..(remdir or dir).."\n")
      local resp, err = client:receive("*l")
      if not resp then
        print("Unknown error: "..err)
        return nil, nil, "Debugger connection error: "..err
      end
      local _, _, status = string.find(resp, "^(%d+)%s+%w+%s*$")
      if status == "200" then
        print("New base directory is " .. basedir)
      else
        print("Unknown error")
        return nil, nil, "Debugger error: unexpected response after BASEDIR"
      end
    else
      print(basedir)
    end
  elseif command == "help" then
    print("setb <file> <line>    -- sets a breakpoint")
    print("delb <file> <line>    -- removes a breakpoint")
    print("delallb               -- removes all breakpoints")
    print("setw <exp>            -- adds a new watch expression")
    print("delw <index>          -- removes the watch expression at index")
    print("delallw               -- removes all watch expressions")
    print("run                   -- runs until next breakpoint")
    print("step                  -- runs until next line, stepping into function calls")
    print("over                  -- runs until next line, stepping over function calls")
    print("out                   -- runs until line after returning from current function")
    print("listb                 -- lists breakpoints")
    print("listw                 -- lists watch expressions")
    print("eval <exp>            -- evaluates expression on the current context and returns its value")
    print("exec <stmt>           -- executes statement on the current context")
    print("load <file>           -- loads a local file for debugging")
    print("reload                -- restarts the current debugging session")
    print("stack                 -- reports stack trace")
    print("output stdout <d|c|r> -- capture and redirect io stream (default|copy|redirect)")
    print("basedir [<path>]      -- sets the base path of the remote application, or shows the current one")
    print("done                  -- stops the debugger and continues application execution")
    print("exit                  -- exits debugger and the application")
  else
    local _, _, spaces = string.find(params, "^(%s*)$")
    if spaces then
      return nil, nil, "Empty command"
    else
      print("Invalid command")
      return nil, nil, "Invalid command"
    end
  end
  return file, line
end

-- Starts debugging server
local function listen(host, port)
  host = host or "*"
  port = port or mobdebug.port

  local socket = require('_system.utility.socket')

  print("Lua Remote Debugger")
  print("Run the program you wish to debug")

  local server = socket.bind(host, port)
  if not server then print("socket.bind(...) failed"); return end
  local client = server:accept()

  client:send("STEP\n")
  client:receive("*l")

  local breakpoint = client:receive("*l")
  local _, _, file, line = string.find(breakpoint, "^202 Paused%s+(.-)%s+(%d+)%s*$")
  if file and line then
    print("Paused at file " .. file )
    print("Type 'help' for commands")
  else
    local _, _, size = string.find(breakpoint, "^401 Error in Execution (%d+)%s*$")
    if size then
      print("Error in remote application: ")
      print(client:receive(size))
    end
  end

  while true do
    io.write("> ")
    local file, _, err = handle(io.read("*line"), client)
    if not file and err == false then break end -- completed debugging
  end

  client:close()
end

local cocreate
local function coro()
	if cocreate then return end -- only set once
	cocreate = cocreate or coroutine.create
--	coroutine.create = function(f, ...)
	coroutine.create = function(f)
--		return cocreate(function(...) mobdebug.on(); return f(...) end, ...)
		return cocreate(function(...) mobdebug.on(); return f(...) end)
	end
end

local moconew
local function moai()
  if moconew then return end -- only set once
  moconew = moconew or (MOAICoroutine and MOAICoroutine.new)
  if not moconew then return end
  MOAICoroutine.new = function(...)
    local thread = moconew(...)
    -- need to support both thread.run and getmetatable(thread).run, which
    -- was used in earlier MOAI versions
    local mt = thread.run and thread or getmetatable(thread)
    local patched = mt.run
    mt.run = function(self, f, ...)
      return patched(self,  function(...)
        mobdebug.on()
        return f(...)
      end, ...)
    end
    return thread
  end
end

-- make public functions available
mobdebug.setbreakpoint = set_breakpoint
mobdebug.removebreakpoint = remove_breakpoint
mobdebug.listen = listen
mobdebug.loop = loop
mobdebug.scratchpad = scratchpad
mobdebug.handle = handle
mobdebug.connect = connect
mobdebug.start = start
mobdebug.on = on
mobdebug.off = off
mobdebug.moai = moai
mobdebug.coro = coro
mobdebug.done = done
mobdebug.pause = function() step_into = true end
mobdebug.yield = nil -- callback
mobdebug.output = output
mobdebug.onexit = os and os.exit or done
mobdebug.onscratch = nil -- callback
mobdebug.basedir = function(b) if b then basedir = b end return basedir end

return mobdebug