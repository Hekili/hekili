-- Options/ChatCommands.lua
-- Handles /hekili CLI commands.

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local scripts = Hekili.Scripts
local state = Hekili.State

local format, lower, match = string.format, string.lower, string.match
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe

local tableCopy =  ns.tableCopy

function Hekili:countPriorities()
    local priorities = {}
    local spec = state.spec.id

    for priority, data in pairs( Hekili.DB.profile.packs ) do
        if data.spec == spec then
            table.insert( priorities, priority )
        end
    end

    table.sort( priorities )
    return priorities
end

function Hekili:CmdLine( input )
    -- Trim the input once and handle empty or 'skeleton' input
    input = input and input:trim() or ""

    if input == "" or input == "skeleton" then
        self:HandleSkeletonCommand( input )
        return true  -- Ensure return true to close chat box
    end

    -- Parse arguments into a table
    local args = {}
    for arg in string.gmatch( input, "%S+" ) do
        table.insert( args, arg )
    end

    -- Alias maps for argument substitutions
    local arg1Aliases = {
        prio        = "priority",
        snap        = "snapshot"
    }
    local arg2Aliases = {
        cd          = "cooldowns",
        cds         = "cooldowns",
        pot         = "potions",
        display     = "mode",
        target_swap = "cycle",
        swap        = "cycle",
        covenants   = "essences",
        apl         = "pack",
        rotation    = "pack",
        lost        = "lostmyui",

    }
    local arg3Aliases = {
        auto        = "automatic",
        pi          = "infusion",
    }

    -- Apply aliases to arguments
    if args[1] and arg1Aliases[ args[1]:lower() ] then args[1] = arg1Aliases[ args[1]:lower() ] end
    if args[2] and arg2Aliases[ args[2]:lower() ] then args[2] = arg2Aliases[ args[2]:lower() ] end
    if args[3] and arg3Aliases[ args[3]:lower() ] then args[3] = arg3Aliases[ args[3]:lower() ] end

    local command = args[1]

    -- Command handlers mapping
    local commandHandlers = {
        set      = function () self:HandleSetCommand( args ) end,
        profile  = function () self:HandleProfileCommand( args ) end,
        priority = function () self:HandlePriorityCommand( args ) end,
        enable   = function () self:HandleEnableDisableCommand( args ) end,
        disable  = function () self:HandleEnableDisableCommand( args ) end,
        move     = function () self:HandleMoveCommand( args ) end,
        unlock   = function () self:HandleMoveCommand( args ) end,
        lock     = function () self:HandleMoveCommand( args ) end,
        stress   = function () self:RunStressTest() end,
        dotinfo  = function () self:DumpDotInfo( args[2] ) end,
        recover  = function () self:HandleRecoverCommand() end,
        fix      = function () self:HandleFixCommand( args ) end,
        snapshot = function () self:MakeSnapshot() end
    }

    -- Execute the corresponding command handler or show error message
    if commandHandlers[ command ] then
        commandHandlers[ command ]()
        self:UpdateDisplayVisibility()
        return true
    elseif command == "help" then
        self:DisplayChatCommandList( "all" )
    else
        self:Print( "Invalid command. Type '/hekili help' to see the available commands." )
        return true
    end
end

function Hekili:HandleSetCommand( args )
    local profile = self.DB.profile
    local mainToggle = args[2] and args[2]:lower()  -- Convert to lowercase
    local subToggleOrState = args[3] and args[3]:lower()
    local explicitState = args[4]

    -- No Main Toggle Provided
    if not mainToggle then
        self:DisplayChatCommandList( "all" )
        return true
    end

    -- Special Case for cycle
    if mainToggle == "cycle" then
        -- Check for whole number minimum time to die (from 0 to 20 seconds)
        local cycleValue = tonumber( subToggleOrState )
        if cycleValue and cycleValue >= 0 and cycleValue <= 20 and floor( cycleValue ) == cycleValue then
            profile.specs[ state.spec.id ].cycle_min = cycleValue
            self:Print( format( "Target Swap minimum time to die set to %d seconds.", cycleValue ) )
        elseif subToggleOrState == nil then
            -- Toggle cycle if no state is provided
            profile.specs[ state.spec.id ].cycle = not profile.specs[ state.spec.id ].cycle
            local toggleStateText = profile.specs[ state.spec.id ].cycle and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"
            self:Print( format( "Target Swap toggle set to %s.", toggleStateText ) )
        elseif subToggleOrState == "on" or subToggleOrState == "off" then
            -- Explicitly set cycle to on or off
            local toggleState = ( subToggleOrState == "on" )
            profile.specs[ state.spec.id ].cycle = toggleState
            local toggleStateText = toggleState and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"
            self:Print( format( "Target Swap toggle set to %s.", toggleStateText ) )
        else
            -- Invalid parameter handling
            self:Print( "Invalid input for 'cycle'. Use 'on', 'off', leave blank to toggle, or provide a whole number from 0 to 20 to set the minimum time to die." )
        end
        self:ForceUpdate( "CLI_TOGGLE" )
        return true
    end

    -- Handle display mode setting
    if mainToggle == "mode" then
        if subToggleOrState then
            self:SetMode( subToggleOrState )
            if WeakAuras and WeakAuras.ScanEvents then WeakAuras.ScanEvents( "HEKILI_TOGGLE", "mode", args[3] ) end
            if ns.UI.Minimap then ns.UI.Minimap:RefreshDataText() end
        return true
        else
            Hekili:FireToggle( "mode" )
        end
        return true
    end

    -- Handle specialization settings
    if mainToggle == "spec" then
        if self:HandleSpecSetting( subToggleOrState, explicitState) then
            return true
        else
            self:Print( "Invalid spec setting specified." )
            return true
        end
    end

    -- Main Toggle and Sub-Toggle Handling
    -- Explicit State Check for Main Toggle
    local toggleCategory = profile.toggles[ mainToggle ]
    if toggleCategory then
        if subToggleOrState == "on" or subToggleOrState == "off" then
            toggleCategory.value = ( subToggleOrState == "on" )
            local stateText = toggleCategory.value and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"
            self:Print( format( "|cFFFFD100%s|r is now %s.", mainToggle, stateText ) )
            self:ForceUpdate( "CLI_TOGGLE" )
            return true
        end

        -- Sub-Toggle Handling with Validation
        if subToggleOrState then
            -- Convert keys of toggleCategory to lowercase to handle case-insensitivity
            local lowerToggleCategory = {}
            for k, v in pairs( toggleCategory) do
                lowerToggleCategory[ k:lower() ] = v
            end

            -- Check if sub-toggle exists in main toggle
            if lowerToggleCategory[ subToggleOrState ] ~= nil then
                if explicitState == "on" or explicitState == "off" then
                    lowerToggleCategory[ subToggleOrState ] = ( explicitState == "on" )
                elseif explicitState == nil then
                    lowerToggleCategory[ subToggleOrState ] = not lowerToggleCategory[ subToggleOrState ]
                else
                    self:Print( "Invalid explicit state. Use 'on' or 'off'." )
                    return true
                end

                toggleCategory[ subToggleOrState ] = lowerToggleCategory[ subToggleOrState ]  -- Update the original case-sensitive table
                local stateText = lowerToggleCategory[ subToggleOrState ] and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"
                self:Print( format( "|cFFFFD100%s_%s|r is now %s.", mainToggle, subToggleOrState, stateText ) )
                self:ForceUpdate("CLI_TOGGLE" )
                return true
            else
                self:Print("Invalid sub-toggle specified." )
                return true
            end
        end

        -- Default Toggle Behavior for Main Toggle (Toggle)
        self:FireToggle( mainToggle, explicitState )
        local mainToggleState = profile.toggles[ mainToggle ].value and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"
        self:Print( format( "|cFFFFD100%s|r is now %s.", mainToggle, mainToggleState ) )
        self:ForceUpdate( "CLI_TOGGLE" )
        return true
    end
    -- Invalid Toggle or Setting
    self:Print( "Invalid toggle or setting specified." )
    return true
end

function Hekili:HandleFixCommand( args )

    local DB = Hekili.DB
    local profile = DB.profile
    local defaults = DB.defaults
    profile.enabled = true

    local fixType = args[2] and args[2]:lower()  -- Convert to lowercase

    if fixType == "pack" then
        local packName = state.system.packName
        local pack = profile.packs[ packName ]

        if not pack or not pack.builtIn then
            return false
        end

        profile.packs[ packName ] = nil
        Hekili:RestoreDefault( packName )
        Hekili:EmbedPackOptions()
        Hekili:LoadScripts()
        ACD:SelectGroup( "Hekili", "packs", packName )
        if profile.notifications.enabled then
            Hekili:Notify( "Your pack has been reset to default", 6 )
        end

        return true
    end

    if fixType == "lostmyui" then
        local displays = profile.displays
        local displayDefaults = defaults.profile.displays

        for name, display in pairs( displays ) do
            if type( display ) == "table" then
                -- Pull defaults if they exist
                local def = displayDefaults[ name ]

                display.enabled = true
                display.frameStrata = "DIALOG"

                -- Reset anchor and position (use defaults if available)
                display.relativeTo = def and def.relativeTo or "SCREEN"
                display.anchorPoint = def and def.anchorPoint or "BOTTOM"
                display.displayPoint = def and def.displayPoint or "TOP"
                display.x = def and def.x or 0
                display.y = def and def.y or -200

                -- Ensure visibility is sane
                display.visibility = display.visibility or {}
                display.visibility.pve = display.visibility.pve or {}
                display.visibility.pvp = display.visibility.pvp or {}
                display.visibility.pve.alpha = 1
                display.visibility.pvp.alpha = 1
            end
        end

        -- Reset display mode to automatic.
        self:SetMode( "automatic" )

        self:Print( "Your UI displays have been restored to default positions and visibility." )
        self:BuildUI()
        self:UpdateDisplayVisibility()
        self:ForceUpdate( "CLI_TOGGLE" )
        return true
    end

    if fixType == "toggles" then
        for name, toggle in pairs( profile.toggles ) do
            if type( toggle ) == "table" and toggle.value ~= nil then
                if name == "mode" then
                    -- Skip mode toggle.
                elseif name == "funnel" then
                    self:FireToggle( name, "off" )
                else
                    self:FireToggle( name, "on" )
                end
            end
        end

        self:Print( "All standard toggles have been fixed (enabled), except 'funnel' (disabled) and 'mode' (unchanged)." )
        return true
    end

    if fixType == "interrupts" then
        local interrupts = profile.toggles.interrupts
        self:FireToggle( "interrupts", "on" )

        if type( interrupts ) == "table" then
            interrupts.separate = true
        end

        interrupts.castRemainingThreshold = defaults.profile.castRemainingThreshold
        interrupts.filterCasts = defaults.profile.filterCasts

        self:Print( "Interrupt display has been restored, set to separate mode, and interrupt tuning values reset." )
        self:BuildUI()
        self:UpdateDisplayVisibility()
        self:ForceUpdate( "CLI_TOGGLE" )
        return true
    end

    --[[if fixtype == "lowdps" then
        if profile.notifications.enabled then
            Hekili:Notify( "skill issue", 6 )
        end
    end--]]

end

function Hekili:HandleSpecSetting( specSetting, specValue )
    local profile = self.DB.profile
    local settings = class.specs[ state.spec.id ].settings

    -- Search for the spec setting within the settings table
    for i, setting in ipairs( settings ) do
        if setting.name:match( "^" .. specSetting ) then
            if setting.info.type == "toggle" then
                -- If specValue is nil, treat it as a toggle command
                if specValue == nil or specValue == "toggle" then
                    local newValue = not profile.specs[ state.spec.id ].settings[ setting.name ]
                    profile.specs[ state.spec.id ].settings[ setting.name ] = newValue
                    local stateText = newValue and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"
                    self:Print( format( "%s set to %s.", setting.name, stateText ) )
                elseif specValue == "on" then
                    profile.specs[state.spec.id].settings[setting.name] = true
                    self:Print( format( "%s set to |cFF00FF00ON|r.", setting.name ) )
                elseif specValue == "off" then
                    profile.specs[state.spec.id].settings[setting.name] = false
                    self:Print( format( "%s set to |cFFFF0000OFF|r.", setting.name ) )
                else
                    self:Print( "Invalid input. Use 'on', 'off', or leave blank to toggle for toggle settings." )
                end
                return true

            elseif setting.info.type == "range" then
                -- Ensure specValue is a number within the allowed range
                local newValue = tonumber( specValue )
                if newValue and newValue >= ( setting.info.min or -math.huge ) and newValue <= ( setting.info.max or math.huge ) then
                    profile.specs[ state.spec.id ].settings[ setting.name ] = newValue
                    self:Print( format( "%s set to |cFF00B4FF%.2f|r.", setting.name, newValue ) )
                else
                    self:Print( format( "Invalid value for %s. Must be between %.2f and %.2f.", setting.name, setting.info.min or 0, setting.info.max or 100 ) )
                end
                return true
            end
        end
    end

    self:Print( "Invalid spec setting specified." )
    return false
end

function Hekili:DisplayChatCommandList( list )
    local profile = self.DB.profile

    -- Generate and print the "all" overview message.
    if list == "all" then
        self:Print( "Use |cFFFFD100/hekili set|r to adjust toggles, display modes, and specialization settings via chat commands or macros.\n\n" )
    end

    -- Toggle Options Section
    local function getTogglesChunk()
        return "Toggle Options:\n" ..
            " - |cFFFFD100cooldowns|r, |cFFFFD100potions|r, |cFFFFD100interrupts|r, etc.\n" ..
            " - Example commands:\n" ..
            "   - Enable Cooldowns: |cFFFFD100/hek set cooldowns on|r\n" ..
            "   - Disable Interrupts: |cFFFFD100/hek set interrupts off|r\n" ..
            "   - Toggle Defensives: |cFFFFD100/hek set defensives|r\n\n"
    end

    -- Display Mode Control Section
    local function getModesChunk()
        return format( "Display Mode Control (currently |cFFFFD100%s|r):\n", profile.toggles.mode.value or "unknown" ) ..
            " - Toggle Mode: |cFFFFD100/hek set mode|r\n" ..
            " - Set specific mode:\n" ..
            "   - |cFFFFD100/hek set mode automatic|r\n" ..
            "   - |cFFFFD100/hek set mode single|r\n" ..
            "   - |cFFFFD100/hek set mode aoe|r\n" ..
            "   - |cFFFFD100/hek set mode dual|r\n" ..
            "   - |cFFFFD100/hek set mode reactive|r\n\n"
    end

    -- Target Swap (Cycle) Setting Section
    local function getCycleChunk()
        return "Target Swap Setting:\n" ..
            " - Toggle Target Swap: |cFFFFD100/hek set cycle|r\n" ..
            " - Set minimum time to die for target swaps: |cFFFFD100/hek set cycle #|r (0-20)\n" ..
            " - Enable: |cFFFFD100/hek set cycle on|r\n" ..
            " - Disable: |cFFFFD100/hek set cycle off|r\n\n"
    end

    -- Specialization Settings Section
    local function getSpecializationChunk()
        local output = "Specialization Settings for " .. ( state.spec.name or "your specialization" ) .. ":\n"
        local hasToggle, hasNumber = false, false
        local exToggle, exNumber, exMin, exMax, exStep

        -- Loop through specialization settings if they exist
        local settings = class.specs[ state.spec.id ] and class.specs[ state.spec.id ].settings or {}
        for i, setting in ipairs( settings ) do
            if not setting.info.arg or setting.info.arg() then
                if setting.info.type == "toggle" then
                    output = output .. format(
                        " - |cFFFFD100%s|r = %s|r (%s)\n",
                        setting.name,
                        profile.specs[ state.spec.id ].settings[ setting.name ] and "|cFF00FF00ON" or "|cFFFF0000OFF",
                        type( setting.info.name ) == "function" and setting.info.name() or setting.info.name
                    )
                    hasToggle = true
                    exToggle = setting.name
                elseif setting.info.type == "range" then
                    output = output .. format(
                        " - |cFFFFD100%s|r = |cFF00FF00%.2f|r, min: %.2f, max: %.2f\n",
                        setting.name,
                        profile.specs[ state.spec.id ].settings[ setting.name ],
                        setting.info.min and format( "%.2f", setting.info.min ) or "N/A",
                        setting.info.max and format( "%.2f", setting.info.max ) or "N/A"
                    )
                    hasNumber = true
                    exNumber = setting.name
                    exMin = setting.info.min
                    exMax = setting.info.max
                    exStep = setting.info.step
                end
            end
        end

        -- Example Commands for Specialization Settings
        if hasToggle then
            output = output .. format(
                "\nExample commands for toggling specialization settings:\n" ..
                " - Toggle On/Off: |cFFFFD100/hek set spec %s|r\n" ..
                " - Enable: |cFFFFD100/hek set spec %s on|r\n" ..
                " - Disable: |cFFFFD100/hek set spec %s off|r\n",
                exToggle, exToggle, exToggle
            )
        end

        if hasNumber then
            -- Adjust range display based on step size
            local rangeFormat = exStep and exStep >= 1 and "%d-%d" or "%.1f-%.1f"
            output = output .. format(
                "\nExample command for setting numeric values:\n" ..
                " - Set to a value within range: |cFFFFD100/hek set spec %s #|r ( " .. rangeFormat .. ")\n",
                exNumber, exMin or 0, exMax or 100
            )
        end

        return output .. "\n"
    end

    -- Other Commands Section (only included with "all")
    local function getOtherCommandsChunk()
        return "Other available commands:\n" ..
            " - |cFFFFD100/hekili priority|r - View or change priority settings\n" ..
            " - |cFFFFD100/hekili profile|r - View or change profiles\n" ..
            " - |cFFFFD100/hekili move|r - Unlock or lock the UI for positioning\n" ..
            " - |cFFFFD100/hekili enable|r or |cFFFFD100/hekili disable|r - Enable or disable the addon\n"
    end

    -- Determine which sections to print based on the input
    if list == "all" then
        self:Print( getTogglesChunk() )
        self:Print( getModesChunk() )
        self:Print( getCycleChunk() )
        self:Print( getSpecializationChunk() )
        self:Print( getOtherCommandsChunk() )
    elseif list == "toggles" then
        self:Print( getTogglesChunk() )
    elseif list == "modes" then
        self:Print( getModesChunk() )
    elseif list == "cycle" then
        self:Print( getCycleChunk() )
    elseif list == "specialization" then
        self:Print( getSpecializationChunk() )
    end
end

function Hekili:HandleSkeletonCommand( input )
    if input == "skeleton" then
        self.Skeleton = ""  -- must happen BEFORE NotifyChange!
        LibStub("AceConfigRegistry-3.0"):NotifyChange("Hekili")
        self:StartSkeletonListener()
        self:Print( "Addon will now gather specialization information. Select all talents and use all abilities for best results." )
    end
end


function Hekili:HandleProfileCommand( args )
    if not args[2] then
        local output = "Use |cFFFFD100/hekili profile name|r to swap profiles. Valid profile names are:"
        for name, prof in ns.orderedPairs( Hekili.DB.profiles ) do
            output = output .. format( "\n - |cFFFFD100%s|r %s", name, Hekili.DB.profile == prof and "|cFF00FF00(current)|r" or "" )
        end
        self:Print( output )
        return
    end

    local profileName = args[2]
    if not rawget( Hekili.DB.profiles, profileName ) then
        self:Print( "Invalid profile name. Please choose a valid profile." )
        return
    end

    self:Print( format( "Set profile to |cFF00FF00%s|r.", profileName ) )
    self.DB:SetProfile( profileName )
    return
end

function Hekili:HandleEnableDisableCommand( args )
    local enable = args[1] == "enable"
    self.DB.profile.enabled = enable

    for _, buttons in ipairs( ns.UI.Buttons ) do
        for _, button in ipairs( buttons ) do
            if enable then button:Show() else button:Hide() end
        end
    end

    if enable then
        self:Print( "Addon enabled." )
        self:Enable()
    else
        self:Print( "Addon disabled." )
        self:Disable()
    end
    return
end

function Hekili:HandleMoveCommand( args )
    if InCombatLockdown() then
        self:Print( "Cannot unlock UI elements in combat." )
        return
    end

    if args[1] == "lock" then
        ns.StopConfiguration()
        self:Print( "UI locked." )
    else
        ns.StartConfiguration()
        self:Print( "UI unlocked for movement." )
    end
    return
end

function Hekili:HandleRecoverCommand()
    local defaults = self:GetDefaults()
    for k, v in pairs( self.DB.profile.displays ) do
        local default = defaults.profile.displays[k]
        if default then
            for key, value in pairs( default ) do
                v[ key ] = ( type( value) == "table" ) and tableCopy( value ) or value
            end
        end
    end
    self:RestoreDefaults()
    self:RefreshOptions()
    self:BuildUI()
    self:Print( "Default displays and action lists restored." )
    return
end

function Hekili:HandlePriorityCommand( args )
    local priorities = self:countPriorities()
    local spec = state.spec.id

    -- Check for "default" keyword as the second argument
    if args[2] == "default" then
        local defaultPriority = nil

        -- Search for the built-in default priority in the current spec
        for _, priority in ipairs( priorities ) do
            if Hekili.DB.profile.packs[ priority ].builtIn then
                defaultPriority = priority
                break
            end
        end

        -- Set the default priority if found
        if defaultPriority then
            Hekili.DB.profile.specs[ spec ].package = defaultPriority
            local output = format("Switched to the built-in default priority for your specialization: %s%s|r.", Hekili.DB.profile.packs[ defaultPriority ].builtIn and BlizzBlue or "|cFFFFD100", defaultPriority )
            self:Print( output )
            self:ForceUpdate( "CLI_TOGGLE" )
        else
            -- If no built-in default is found, display an error message
            self:Print( "No built-in default priority available for this specialization." )
        end
        return true
    end

    -- No additional argument provided, show available priorities
    if not args[2] then
        local output = "Use |cFFFFD100/hekili priority name|r to change your current specialization's priority via command-line or macro."

        if #priorities < 2 then
            output = output .. "\n\n|cFFFF0000You must have multiple priorities for your specialization to use this feature.|r"
        else
            output = output .. "\nValid priority |cFFFFD100name|rs are:"
            for _, priority in ipairs( priorities ) do
                local isCurrent = Hekili.DB.profile.specs[ spec ].package == priority
                output = format( "%s\n - %s%s|r %s", output, Hekili.DB.profile.packs[ priority ].builtIn and BlizzBlue or "|cFFFFD100", priority, isCurrent and "|cFF00FF00(current)|r" or "" )
            end
        end

        output = format( "%s\n\nTo create a new priority, see |cFFFFD100/hekili|r > |cFFFFD100Priorities|r.", output )
        self:Print( output )
        return true
    end

    -- Combine args into full priority name (case-insensitive) if provided
    local rawName = table.concat( args, " ", 2 ):lower()
    local pattern = "^" .. rawName:gsub( "%%", "%%%%" ):gsub( "%^", "%%^" ):gsub( "%$", "%%$" ):gsub( "%(", "%%(" ):gsub( "%)", "%%)" ):gsub( "%.", "%%." ):gsub( "%[", "%%[" ):gsub( "%]", "%%]" ):gsub( "%*", "%%*" ):gsub( "%+", "%%+" ):gsub( "%-", "%%-" ):gsub( "%?", "%%?" )

    for _, priority in ipairs( priorities ) do
        if priority:lower():match( pattern ) then
            Hekili.DB.profile.specs[ spec ].package = priority
            local output = format( "Priority set to %s%s|r.", Hekili.DB.profile.packs[ priority ].builtIn and BlizzBlue or "|cFFFFD100", priority )
            self:Print( output )
            self:ForceUpdate( "CLI_TOGGLE" )
            return true
        end
    end

    -- If no matching priority found, display valid options
    local output = format( "No match found for priority '%s'.\nValid options are:", rawName )
    for i, priority in ipairs( priorities ) do
        output = output .. format( " %s%s|r%s", Hekili.DB.profile.packs[ priority ].builtIn and BlizzBlue or "|cFFFFD100", priority, i == #priorities and "." or "," )
    end
    self:Print( output )
    return true
end