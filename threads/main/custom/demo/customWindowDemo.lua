local projectName = 'customWindowDemo'
local moduleName = 'module_customWindowDemo'

local script = {
    m_strUUID = projectName .. ".lua." .. moduleName,
}

-- Respond to 'onPressCustomWindowButton' hook
function script.onButtonPress(pPlayer, dwActWindowID, dwActButtonID, dwParentWindowID, dwSelectedID)
    -- Check if component 12 of Function Menu index 1 is pressed
    if dwActWindowID == 1 and dwActButtonID == 12 then
        
        -- Custom Window defined in 'ReloadableScripts/CustomWindodws/default.lua'
        local buf = Sirin.mainThread.CLuaSendBuffer.Instance()
        buf:Init() -- Create new buffer 'buf' to store the state of all components in Custom Window
		buf:PushUInt32(2) -- Index 2 for Custom Window
		buf:PushUInt32(4) -- Number of components in Custom Window

        -- Loop 4 times
		for i = 1, 4 do
			buf:PushUInt32(tonumber("101", 2)) -- set state flag  [Visible, Not Disabled, IsButton] 
			buf:PushUInt32(1) -- set delay remaining (seconds)
			buf:PushUInt32(1) -- set delay total (seconds)
			buf:PushUInt32(0xFFFFFFFF) -- counter on icon (Disabled with 0xFFFFFFFF)
			buf:PushUInt32(0xFFFFFFFF) -- counter Max on icon (Disabled with 0xFFFFFFFF)
		end

        -- Send packet to player with data in buffer `buf`
		buf:SendBuffer(pPlayer, 80, 12)
    end
end

-- Print to server console script loaded
function script.onThreadBegin()
    print("'customWindowDemo' Script Loaded")
end

function script.onThreadEnd()
end

local function autoInit()
    if not _G[moduleName] then -- One time initialization
        _G[moduleName] = script -- Bind your script to a global variable. Variable name must be unique.

        table.insert(SirinLua.onThreadBegin, function() _G[moduleName].onThreadBegin() end)
        table.insert(SirinLua.onThreadEnd, function() _G[moduleName].onThreadEnd() end)
    else
        _G[moduleName] = script -- On reload 
    end
    SirinLua.HookMgr.releaseHookByUID(script.m_strUUID)

    -- Add hook to respond to clicks from Function Menu. Call -> onButtonPressed
    SirinLua.HookMgr.addHook("onPressCustomWindowButton", HOOK_POS.after_event, script.m_strUUID, script.onButtonPress)
end

autoInit()