local function SetEnvironment( func, env )
    if type(func) == "function" then
        if setfenv then
            setfenv( func, env ) -- Lua 5.1
        else
            debug.setupvalue( func, 1, env ) -- Lua 5.2+
        end
    end
end 