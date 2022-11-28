-- Options.lua
-- Everything related to building/configuring options.

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local scripts = Hekili.Scripts
local state = Hekili.State

local format, lower, match = string.format, string.lower, string.match
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe

local callHook = ns.callHook

local SpaceOut = ns.SpaceOut

local formatKey = ns.formatKey
local orderedPairs = ns.orderedPairs
local tableCopy = ns.tableCopy

local GetItemInfo = ns.CachedGetItemInfo

-- Atlas/Textures
local AtlasToString, GetAtlasFile, GetAtlasCoords = ns.AtlasToString, ns.GetAtlasFile, ns.GetAtlasCoords

-- Options Functions
local TableToString, StringToTable, SerializeActionPack, DeserializeActionPack, SerializeDisplay, DeserializeDisplay, SerializeStyle, DeserializeStyle

local ACD = LibStub( "AceConfigDialog-3.0" )
local LDBIcon = LibStub( "LibDBIcon-1.0", true )
local LSM = LibStub( "LibSharedMedia-3.0" )
local SF = SpellFlashCore

local NewFeature = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0|t"
local GreenPlus = "Interface\\AddOns\\Hekili\\Textures\\GreenPlus"
local RedX = "Interface\\AddOns\\Hekili\\Textures\\RedX"
local BlizzBlue = "|cFF00B4FF"
local ClassColor = C_ClassColor.GetClassColor( class.file )


-- One Time Fixes
local oneTimeFixes = {
    resetAberrantPackageDates_20190728_1 = function( p )
        for _, v in pairs( p.packs ) do
            if type( v.date ) == 'string' then v.date = tonumber( v.date ) or 0 end
            if type( v.version ) == 'string' then v.date = tonumber( v.date ) or 0 end
            if v.date then while( v.date > 21000000 ) do v.date = v.date / 10 end end
            if v.version then while( v.version > 21000000 ) do v.version = v.version / 10 end end
        end
    end,

    forceEnableEnhancedRecheckBoomkin_20210712 = function( p )
        local s = rawget( p.specs, 102 )
        if s then s.enhancedRecheck = true end
    end,

    updateMaxRefreshToNewSpecOptions_20220222 = function( p )
        for id, spec in pairs( p.specs ) do
            if spec.settings.maxRefresh then
                spec.settings.combatRefresh = 1 / spec.settings.maxRefresh
                spec.settings.regularRefresh = min( 1, 5 * spec.settings.combatRefresh )
                spec.settings.maxRefresh = nil
            end
        end
    end,

    forceEnableAllClassesOnceDueToBug_20220225 = function( p )
        for id, spec in pairs( p.specs ) do
            spec.enabled = true
        end
    end,

    forceReloadAllDefaultPriorities_20220228 = function( p )
        for name, pack in pairs( p.packs ) do
            if pack.builtIn then
                Hekili.DB.profile.packs[ name ] = nil
                Hekili:RestoreDefault( name )
            end
        end
    end,

    forceReloadClassDefaultOptions_20220306 = function( p )
        local sendMsg = false
        for spec, data in pairs( class.specs ) do
            if spec > 0 and not p.runOnce[ 'forceReloadClassDefaultOptions_20220306_' .. spec ] then
                local cfg = p.specs[ spec ]
                for k, v in pairs( data.options ) do
                    if cfg[ k ] == ns.specTemplate[ k ] and cfg[ k ] ~= v then
                        cfg[ k ] = v
                        sendMsg = true
                    end
                end
                p.runOnce[ 'forceReloadClassDefaultOptions_20220306_' .. spec ] = true
            end
        end
        if sendMsg then
            C_Timer.After( 5, function()
                if Hekili.DB.profile.notifications.enabled then Hekili:Notify( "Some specialization options were reset.", 6 ) end
                Hekili:Print( "Some specialization options were reset to default; this can occur once per profile/specialization." )
            end )
        end
        p.runOnce.forceReloadClassDefaultOptions_20220306 = nil
    end,

    forceDeleteBrokenMultiDisplay_20220319 = function( p )
        if rawget( p.displays, "Multi" ) then
            p.displays.Multi = nil
        end

        p.runOnce.forceDeleteBrokenMultiDisplay_20220319 = nil
    end,

    forceSpellFlashBrightness_20221030 = function( p )
        for display, data in pairs( p.displays ) do
            if data.flash and data.flash.brightness and data.flash.brightness > 100 then
                data.flash.brightness = 100
            end
        end
    end,
}


function Hekili:RunOneTimeFixes()
    local profile = Hekili.DB.profile
    if not profile then return end

    profile.runOnce = profile.runOnce or {}

    for k, v in pairs( oneTimeFixes ) do
        if not profile.runOnce[ k ] then
            profile.runOnce[k] = true
            local ok, err = pcall( v, profile )
            if err then
                Hekili:Error( "One-Time update failed: " .. k .. ": " .. err )
                profile.runOnce[ k ] = nil
            end
        end
    end
end


-- Display Controls
--    Single Display -- single vs. auto in one display.
--    Dual Display   -- single in one display, aoe in another.
--    Hybrid Display -- automatic in one display, can toggle to single/AOE.

local displayTemplate = {
    enabled = true,

    numIcons = 4,

    primaryWidth = 50,
    primaryHeight = 50,

    elvuiCooldown = false,

    keepAspectRatio = true,
    zoom = 30,

    frameStrata = "LOW",
    frameLevel = 10,

    queue = {
        anchor = 'RIGHT',
        direction = 'RIGHT',
        style = 'RIGHT',
        alignment = 'CENTER',

        width = 50,
        height = 50,

        -- offset = 5, -- deprecated.
        offsetX = 5,
        offsetY = 0,
        spacing = 5,

        elvuiCooldown = false,

        --[[ font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 12,
        fontStyle = "OUTLINE" ]]
    },

    visibility = {
        advanced = false,

        mode = {
            aoe = true,
            automatic = true,
            dual = true,
            single = true,
            reactive = true,
        },

        pve = {
            alpha = 1,
            always = 1,
            target = 1,
            combat = 1,
            combatTarget = 1,
            hideMounted = false,
        },

        pvp = {
            alpha = 1,
            always = 1,
            target = 1,
            combat = 1,
            combatTarget = 1,
            hideMounted = false,
        },
    },

    border = {
        enabled = true,
        width = 1,
        coloring = 'custom',
        color = { 0, 0, 0, 1 },
    },

    range = {
        enabled = true,
        type = 'ability',
    },

    glow = {
        enabled = false,
        queued = false,
        mode = "autocast",
        coloring = "default",
        color = { 0.95, 0.95, 0.32, 1 },

        highlight = true,
    },

    flash = {
        enabled = false,
        color = { 255/255, 215/255, 0, 1 }, -- gold.
        blink = false,
        suppress = false,
        combat = false,

        size = 240,
        brightness = 100,
        speed = 0.4,

        fixedSize = false,
        fixedBrightness = false
    },

    captions = {
        enabled = false,
        queued = false,

        align = "CENTER",
        anchor = "BOTTOM",
        x = 0,
        y = 0,

        font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 12,
        fontStyle = "OUTLINE",

        color = { 1, 1, 1, 1 },
    },

    empowerment = {
        enabled = true,
        queued = true,

        align = "CENTER",
        anchor = "BOTTOM",
        x = 0,
        y = 1,

        font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 16,
        fontStyle = "THICKOUTLINE",

        color = { 1, 0.8196079, 0, 1 },
    },

    indicators = {
        enabled = true,
        queued = true,

        anchor = "RIGHT",
        x = 0,
        y = 0,
    },

    targets = {
        enabled = true,

        font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 12,
        fontStyle = "OUTLINE",

        anchor = "BOTTOMRIGHT",
        x = 0,
        y = 0,

        color = { 1, 1, 1, 1 },
    },

    delays = {
        type = "__NA",
        fade = false,
        extend = true,
        elvuiCooldowns = false,

        font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 12,
        fontStyle = "OUTLINE",

        anchor = "TOPLEFT",
        x = 0,
        y = 0,

        color = { 1, 1, 1, 1 },
    },

    keybindings = {
        enabled = true,
        queued = true,

        font = ElvUI and "PT Sans Narrow" or "Arial Narrow",
        fontSize = 12,
        fontStyle = "OUTLINE",

        lowercase = false,

        queuedFont = ElvUI and "PT Sans Narrow" or "Arial Narrow",
        queuedFontSize = 12,
        queuedFontStyle = "OUTLINE",

        queuedLowercase = false,

        anchor = "TOPRIGHT",
        x = 1,
        y = -1,

        cPortOverride = true,
        cPortZoom = 0.6,

        color = { 1, 1, 1, 1 },
        queuedColor = { 1, 1, 1, 1 },
    },

}


local actionTemplate = {
    action = "heart_essence",
    enabled = true,
    criteria = "",
    caption = "",
    description = "",

    -- Shared Modifiers
    early_chain_if = "",  -- NYI

    cycle_targets = 0,
    max_cycle_targets = 3,
    max_energy = 0,

    interrupt = 0,  --NYI
    interrupt_if = "",  --NYI
    interrupt_immediate = 0,  -- NYI

    travel_speed = nil,

    enable_moving = false,
    moving = nil,
    sync = "",

    use_while_casting = 0,
    use_off_gcd = 0,

    wait_on_ready = 0, -- NYI

    -- Call/Run Action List
    list_name = nil,
    strict = nil,

    -- Pool Resource
    wait = "0.5",
    for_next = 0,
    extra_amount = "0",

    -- Potion
    potion = "default",

    -- Variable
    op = "set",
    condition = "",
    default = "",
    value = "",
    value_else = "",
    var_name = "unnamed",

    -- Wait
    sec = "1",
}


local packTemplate = {
    spec = 0,
    builtIn = false,

    author = UnitName("player"),
    desc = "This is a package of action lists for Hekili.",
    source = "",
    date = tonumber( date("%Y%M%D.%H%M") ),
    warnings = "",

    hidden = false,

    lists = {
        precombat = {
            {
                enabled = false,
                action = "heart_essence",
            },
        },
        default = {
            {
                enabled = false,
                action = "heart_essence",
            },
        },
    }
}

local specTemplate = ns.specTemplate


do
    local defaults

    -- Default Table
    function Hekili:GetDefaults()
        defaults = defaults or {
            global = {
                styles = {},
            },

            profile = {
                enabled = true,
                minimapIcon = false,
                autoSnapshot = true,
                screenshot = true,

                flashTexture = "Interface\\Cooldown\\star4",

                toggles = {
                    pause = {
                        key = "ALT-SHIFT-P",
                    },

                    snapshot = {
                        key = "ALT-SHIFT-[",
                    },

                    mode = {
                        key = "ALT-SHIFT-N",
                        -- type = "AutoSingle",
                        automatic = true,
                        single = true,
                        value = "automatic",
                    },

                    cooldowns = {
                        key = "ALT-SHIFT-R",
                        value = false,
                        override = false,
                        separate = false,
                    },

                    defensives = {
                        key = "ALT-SHIFT-T",
                        value = false,
                        separate = false,
                    },

                    potions = {
                        key = "",
                        value = false,
                    },

                    interrupts = {
                        key = "ALT-SHIFT-I",
                        value = false,
                        separate = false,
                    },

                    essences = {
                        key = "ALT-SHIFT-G",
                        value = true,
                        override = true,
                    },

                    custom1 = {
                        key = "",
                        value = false,
                        name = "Custom #1"
                    },

                    custom2 = {
                        key = "",
                        value = false,
                        name = "Custom #2"
                    }
                },

                specs = {
                    ['**'] = specTemplate
                },

                packs = {
                    ['**'] = packTemplate
                },

                notifications = {
                    enabled = true,

                    x = 0,
                    y = 0,

                    font = ElvUI and "Expressway" or "Arial Narrow",
                    fontSize = 20,
                    fontStyle = "OUTLINE",
                    color = { 1, 1, 1, 1 },

                    width = 600,
                    height = 40,
                },

                displays = {
                    Primary = {
                        enabled = true,
                        builtIn = true,

                        name = "Primary",

                        relativeTo = "SCREEN",
                        displayPoint = "TOP",
                        anchorPoint = "BOTTOM",

                        x = 0,
                        y = -225,

                        numIcons = 3,
                        order = 1,

                        flash = {
                            color = { 1, 0, 0, 1 },
                        },

                        glow = {
                            enabled = true,
                            mode = "autocast"
                        },
                    },

                    AOE = {
                        enabled = true,
                        builtIn = true,

                        name = "AOE",

                        x = 0,
                        y = -170,

                        numIcons = 3,
                        order = 2,

                        flash = {
                            color = { 0, 1, 0, 1 },
                        },

                        glow = {
                            enabled = true,
                            mode = "autocast",
                        },
                    },

                    Cooldowns = {
                        enabled = true,
                        builtIn = true,

                        name = "Cooldowns",
                        filter = 'cooldowns',

                        x = 0,
                        y = -280,

                        numIcons = 1,
                        order = 3,

                        flash = {
                            color = { 1, 0.82, 0, 1 },
                        },

                        glow = {
                            enabled = true,
                            mode = "autocast",
                        },
                    },

                    Defensives = {
                        enabled = true,
                        builtIn = true,

                        name = "Defensives",
                        filter = 'defensives',

                        x = -110,
                        y = -225,

                        numIcons = 1,
                        order = 4,

                        flash = {
                            color = { 0.522, 0.302, 1, 1 },
                        },

                        glow = {
                            enabled = true,
                            mode = "autocast",
                        },
                    },

                    Interrupts = {
                        enabled = true,
                        builtIn = true,

                        name = "Interrupts",
                        filter = 'interrupts',

                        x = -55,
                        y = -225,

                        numIcons = 1,
                        order = 5,

                        flash = {
                            color = { 1, 1, 1, 1 },
                        },

                        glow = {
                            enabled = true,
                            mode = "autocast",
                        },
                    },

                    ['**'] = displayTemplate
                },

                -- STILL NEED TO REVISE.
                Clash = 0,
                -- (above)

                runOnce = {
                },

                clashes = {
                },
                trinkets = {
                    ['**'] = {
                        disabled = false,
                        minimum = 0,
                        maximum = 0,
                    }
                },

                interrupts = {
                    pvp = {},
                    encounters = {},
                },

                iconStore = {
                    hide = false,
                },
            },
        }

        for id, spec in pairs( class.specs ) do
            if id > 0 then
                defaults.profile.specs[ id ] = defaults.profile.specs[ id ] or tableCopy( specTemplate )
                for k, v in pairs( spec.options ) do
                    defaults.profile.specs[ id ][ k ] = v
                end
            end
        end

        return defaults
    end
end


do
    local shareDB = {
        displays = {},
        styleName = "",
        export = "",
        exportStage = 0,

        import = "",
        imported = {},
        importStage = 0
    }

    function Hekili:GetDisplayShareOption( info )
        local n = #info
        local option = info[ n ]

        if shareDB[ option ] then return shareDB[ option ] end
        return shareDB.displays[ option ]
    end


    function Hekili:SetDisplayShareOption( info, val, v2, v3, v4 )
        local n = #info
        local option = info[ n ]

        if type(val) == 'string' then val = val:trim() end
        if shareDB[ option ] then shareDB[ option ] = val; return end

        shareDB.displays[ option ] = val
        shareDB.export = ""
    end



    local multiDisplays = {
        Primary = true,
        AOE = true,
        Cooldowns = false,
        Defensives = false,
        Interrupts = false,
    }

    local frameStratas = ns.FrameStratas

    -- Display Config.
    function Hekili:GetDisplayOption( info )
        local n = #info
        local display, category, option = info[ 2 ], info[ 3 ], info[ n ]

        if category == "shareDisplays" then
            return self:GetDisplayShareOption( info )
        end

        local conf = self.DB.profile.displays[ display ]

        if category ~= option and category ~= "main" then
            conf = conf[ category ]
        end

        if option == "color" or option == "queuedColor" then return unpack( conf.color ) end
        if option == "frameStrata" then return frameStratas[ conf.frameStrata ] or 3 end
        if option == "name" then return display end

        return conf[ option ]
    end

    local multiSet = false
    local rebuild = false

    local function QueueRebuildUI()
        rebuild = true
        C_Timer.After( 0.5, function ()
            if rebuild then
                Hekili:BuildUI()
                rebuild = false
            end
        end )
    end

    function Hekili:SetDisplayOption( info, val, v2, v3, v4 )
        local n = #info
        local display, category, option = info[ 2 ], info[ 3 ], info[ n ]
        local set = false

        local all = false

        if category == "shareDisplays" then
            self:SetDisplayShareOption( info, val, v2, v3, v4 )
            return
        end

        local conf = self.DB.profile.displays[ display ]
        if category ~= option and category ~= 'main' then conf = conf[ category ] end

        if option == 'color' or option == 'queuedColor' then
            conf[ option ] = { val, v2, v3, v4 }
            set = true
        elseif option == 'frameStrata' then
            conf.frameStrata = frameStratas[ val ] or "LOW"
            set = true
        end

        if not set then
            val = type( val ) == 'string' and val:trim() or val
            conf[ option ] = val
        end

        if not multiSet then QueueRebuildUI() end
    end


    function Hekili:GetMultiDisplayOption( info )
        info[ 2 ] = "Primary"
        local val, v2, v3, v4 = self:GetDisplayOption( info )
        info[ 2 ] = "Multi"
        return val, v2, v3, v4
    end

    function Hekili:SetMultiDisplayOption( info, val, v2, v3, v4 )
        multiSet = true

        local orig = info[ 2 ]

        for display, active in pairs( multiDisplays ) do
            if active then
                info[ 2 ] = display
                self:SetDisplayOption( info, val, v2, v3, v4 )
            end
        end
        QueueRebuildUI()
        info[ 2 ] = orig

        multiSet = false
    end


    local function GetNotifOption( info )
        local n = #info
        local option = info[ n ]

        local conf = Hekili.DB.profile.notifications

        if option == "color" then return unpack( conf[ option ] ) end
        return conf[ option ]
    end

    local function SetNotifOption( info, val )
        local n = #info
        local option = info[ n ]

        local conf = Hekili.DB.profile.notifications

        conf[ option ] = val
        QueueRebuildUI()
    end

    local fontStyles = {
        ["MONOCHROME"] = "Monochrome",
        ["MONOCHROME,OUTLINE"] = "Monochrome, Outline",
        ["MONOCHROME,THICKOUTLINE"] = "Monochrome, Thick Outline",
        ["NONE"] = "None",
        ["OUTLINE"] = "Outline",
        ["THICKOUTLINE"] = "Thick Outline"
    }

    local fontElements = {
        font = {
            type = "select",
            name = "Font",
            order = 1,
            width = 1.49,
            dialogControl = 'LSM30_Font',
            values = LSM:HashTable("font"),
        },

        fontStyle = {
            type = "select",
            name = "Style",
            order = 2,
            values = fontStyles,
            width = 1.49
        },

        break01 = {
            type = "description",
            name = " ",
            order = 2.1,
            width = "full"
        },

        fontSize = {
            type = "range",
            name = "Size",
            order = 3,
            min = 8,
            max = 64,
            step = 1,
            width = 1.49
        },

        color = {
            type = "color",
            name = "Color",
            order = 4,
            width = 1.49
        }
    }

    local anchorPositions = {
        TOP = 'Top',
        TOPLEFT = 'Top Left',
        TOPRIGHT = 'Top Right',
        BOTTOM = 'Bottom',
        BOTTOMLEFT = 'Bottom Left',
        BOTTOMRIGHT = 'Bottom Right',
        LEFT = 'Left',
        LEFTTOP = 'Left Top',
        LEFTBOTTOM = 'Left Bottom',
        RIGHT = 'Right',
        RIGHTTOP = 'Right Top',
        RIGHTBOTTOM = 'Right Bottom',
    }


    local realAnchorPositions = {
        TOP = 'Top',
        TOPLEFT = 'Top Left',
        TOPRIGHT = 'Top Right',
        BOTTOM = 'Bottom',
        BOTTOMLEFT = 'Bottom Left',
        BOTTOMRIGHT = 'Bottom Right',
        CENTER = "Center",
        LEFT = 'Left',
        RIGHT = 'Right',
    }


    local function getOptionTable( info, notif )
        local disp = info[2]
        local tab = Hekili.Options.args.displays

        if notif then
            tab = tab.args.nPanel
        else
            tab = tab.plugins[ disp ][ disp ]
        end

        for i = 3, #info do
            tab = tab.args[ info[i] ]
        end

        return tab
    end

    local function rangeXY( info, notif )
        local tab = getOptionTable( info, notif )

        local resolution = GetCVar( "gxWindowedResolution" ) or "1280x720"
        local width, height = resolution:match( "(%d+)x(%d+)" )

        width = tonumber( width )
        height = tonumber( height )

        tab.args.x.min = -1 * width
        tab.args.x.max = width
        tab.args.x.softMin = -1 * width * 0.5
        tab.args.x.softMax = width * 0.5

        tab.args.y.min = -1 * height
        tab.args.y.max = height
        tab.args.y.softMin = -1 * height * 0.5
        tab.args.y.softMax = height * 0.5
    end


    local function setWidth( info, field, condition, if_true, if_false )
        local tab = getOptionTable( info )

        if condition then
            tab.args[ field ].width = if_true or "full"
        else
            tab.args[ field ].width = if_false or "full"
        end
    end


    local function rangeIcon( info )
        local tab = getOptionTable( info )

        local display = info[2]
        display = display == "Multi" and "Primary" or display

        local data = display and Hekili.DB.profile.displays[ display ]

        if data then
            tab.args.x.min = -1 * max( data.primaryWidth, data.queue.width )
            tab.args.x.max = max( data.primaryWidth, data.queue.width )

            tab.args.y.min = -1 * max( data.primaryHeight, data.queue.height )
            tab.args.y.max = max( data.primaryHeight, data.queue.height )

            return
        end

        tab.args.x.min = -50
        tab.args.x.max = 50

        tab.args.y.min = -50
        tab.args.y.max = 50
    end


    local dispCycle = { "Primary", "AOE", "Cooldowns", "Defensives", "Interrupts" }

    local MakeMultiDisplayOption
    local modified = {}

    local function GetOptionData( db, info )
        local display = info[ 2 ]
        local option = db[ display ][ display ]
        local desc, set, get = nil, option.set, option.get

        for i = 3, #info do
            local category = info[ i ]

            if not option then
                break

            elseif option.args then
                if not option.args[ category ] then
                    break
                end
                option = option.args[ category ]

            else
                break
            end

            get = option and option.get or get
            set = option and option.set or set
            desc = option and option.desc or desc
        end

        return option, get, set, desc
    end

    local function WrapSetter( db, data )
        local _, _, setfunc = GetOptionData( db, data )
        if setfunc and modified[ setfunc ] then return setfunc end

        local newFunc = function( info, val, v2, v3, v4 )
            multiSet = true

            for display, active in pairs( multiDisplays ) do
                if active then
                    info[ 2 ] = display

                    _, _, setfunc = GetOptionData( db, info )

                    if type( setfunc ) == "string" then
                        Hekili[ setfunc ]( Hekili, info, val, v2, v3, v4 )
                    elseif type( setfunc ) == "function" then
                        setfunc( info, val, v2, v3, v4 )
                    end
                end
            end

            multiSet = false

            info[ 2 ] = "Multi"
            QueueRebuildUI()
        end

        modified[ newFunc ] = true
        return newFunc
    end

    local function WrapDesc( db, data )
        local option, _, _, descfunc = GetOptionData( db, data )
        if descfunc and modified[ descfunc ] then
            return descfunc
        end

        local newFunc = function( info )
            local output

            for _, display in ipairs( dispCycle ) do
                info[ 2 ] = display
                option, getfunc, _, descfunc = GetOptionData( db, info )

                if not output then
                    output = option and type( option.desc ) == "function" and ( option.desc( info ) or "" ) or ( option.desc or "" )
                    if output:len() > 0 then output = output .. "\n" end
                end

                local val, v2, v3, v4

                if not getfunc then
                    val, v2, v3, v4 = Hekili:GetDisplayOption( info )
                elseif type( getfunc ) == "function" then
                    val, v2, v3, v4 = getfunc( info )
                elseif type( getfunc ) == "string" then
                    val, v2, v3, v4 = Hekili[ getfunc ]( Hekili, info )
                end

                if val == nil then
                    Hekili:Error( "Unable to get a value for %s in WrapDesc.", table.concat( info, ":" ) )
                    info[ 2 ] = "Multi"
                    return output
                end

                -- Sanitize/format values.
                if type( val ) == "boolean" then
                    val = val and "|cFF00FF00Checked|r" or "|cFFFF0000Unchecked|r"

                elseif option.type == "color" then
                    val = string.format( "|A:WhiteCircle-RaidBlips:16:16:0:0:%d:%d:%d|a |cFFFFD100#%02x%02x%02x|r", val * 255, v2 * 255, v3 * 255, val * 255, v2 * 255, v3 * 255 )

                elseif option.type == "select" and option.values and not option.dialogControl then
                    if type( option.values ) == "function" then
                        val = option.values( data )[ val ] or val
                    else
                        val = option.values[ val ] or val
                    end

                    if type( val ) == "number" then
                        if val % 1 == 0 then
                            val = format( "|cFFFFD100%d|r", val )
                        else
                            val = format( "|cFFFFD100%.2f|r", val )
                        end
                    else
                        val = format( "|cFFFFD100%s|r", tostring( val ) )
                    end

                elseif type( val ) == "number" then
                    if val % 1 == 0 then
                        val = format( "|cFFFFD100%d|r", val )
                    else
                        val = format( "|cFFFFD100%.2f|r", val )
                    end

                else
                    if val == nil then
                        Hekili:Error( "Value not found for %s, defaulting to '???'.", table.concat( data, ":" ))
                        val = "|cFFFF0000???|r"
                    else
                        val = "|cFFFFD100" .. val .. "|r"
                    end
                end

                output = format( "%s%s%s%s:|r %s", output, output:len() > 0 and "\n" or "", BlizzBlue, display, val )
            end

            info[ 2 ] = "Multi"
            return output
        end

        modified[ newFunc ] = true
        return newFunc
    end

    local function GetDeepestSetter( db, info )
        local position = db.Multi.Multi
        local setter

        for i = 3, #info - 1 do
            local key = info[ i ]
            position = position.args[ key ]

            local setfunc = rawget( position, "set" )

            if setfunc and type( setfunc ) == "function" then
                setter = setfunc
            end
        end

        return setter
    end

    MakeMultiDisplayOption = function( db, t, inf )
        local info = {}

        if not inf or #inf == 0 then
            info[1] = "displays"
            info[2] = "Multi"

            for k, v in pairs( t ) do
                -- Only load groups in the first level (bypasses selection for which display to edit).
                if v.type == "group" then
                    info[3] = k
                    MakeMultiDisplayOption( db, v.args, info )
                    info[3] = nil
                end
            end

            return

        else
            for i, v in ipairs( inf ) do
                info[ i ] = v
            end
        end

        for k, v in pairs( t ) do
            if k:match( "^MultiMod" ) then
                -- do nothing.
            elseif v.type == "group" then
                info[ #info + 1 ] = k
                MakeMultiDisplayOption( db, v.args, info )
                info[ #info ] = nil
            elseif inf and v.type ~= "description" then
                info[ #info + 1 ] = k
                v.desc = WrapDesc( db, info )

                if rawget( v, "set" ) then
                    v.set = WrapSetter( db, info )
                else
                    local setfunc = GetDeepestSetter( db, info )
                    if setfunc then v.set = WrapSetter( db, info ) end
                end

                info[ #info ] = nil
            end
        end
    end


    local function newDisplayOption( db, name, data, pos )
        name = tostring( name )

        local fancyName

        if name == "Multi" then fancyName = AtlasToString( "auctionhouse-icon-favorite" ) .. " Multiple"
        elseif name == "Defensives" then fancyName = AtlasToString( "nameplates-InterruptShield" ) .. " Defensives"
        elseif name == "Interrupts" then fancyName = AtlasToString( "voicechat-icon-speaker-mute" ) .. " Interrupts"
        elseif name == "Cooldowns" then fancyName = AtlasToString( "chromietime-32x32" ) .. " Cooldowns"
        else fancyName = name end

        local option = {
            ['btn'..name] = {
                type = 'execute',
                name = fancyName,
                desc = data.desc,
                order = 10 + pos,
                func = function () ACD:SelectGroup( "Hekili", "displays", name ) end,
            },

            [name] = {
                type = 'group',
                name = function ()
                    if name == "Multi" then return "|cFF00FF00" .. fancyName .. "|r"
                    elseif data.builtIn then return '|cFF00B4FF' .. fancyName .. '|r' end
                    return fancyName
                end,
                desc = function ()
                    if name == "Multi" then
                        return "Allows editing of multiple displays at once.  Settings displayed are from the Primary display (other display settings are shown in the tooltip).\n\nCertain options are disabled when editing multiple displays."
                    end
                    return data.desc
                end,
                set = name == "Multi" and "SetMultiDisplayOption" or "SetDisplayOption",
                get = name == "Multi" and "GetMultiDisplayOption" or "GetDisplayOption",
                childGroups = "tab",
                order = 100 + pos,

                args = {
                    MultiModPrimary = {
                        type = "toggle",
                        name = function() return multiDisplays.Primary and "|cFF00FF00Primary|r" or "|cFFFF0000Primary|r" end,
                        desc = function()
                            if multiDisplays.Primary then return "Changes |cFF00FF00will|r be applied to the Primary display." end
                            return "Changes |cFFFF0000will not|r be applied to the Primary display."
                        end,
                        order = 0.01,
                        width = 0.65,
                        get = function() return multiDisplays.Primary end,
                        set = function() multiDisplays.Primary = not multiDisplays.Primary end,
                        hidden = function () return name ~= "Multi" end,
                    },
                    MultiModAOE = {
                        type = "toggle",
                        name = function() return multiDisplays.AOE and "|cFF00FF00AOE|r" or "|cFFFF0000AOE|r" end,
                        desc = function()
                            if multiDisplays.AOE then return "Changes |cFF00FF00will|r be applied to the AOE display." end
                            return "Changes |cFFFF0000will not|r be applied to the AOE display."
                        end,
                        order = 0.02,
                        width = 0.65,
                        get = function() return multiDisplays.AOE end,
                        set = function() multiDisplays.AOE = not multiDisplays.AOE end,
                        hidden = function () return name ~= "Multi" end,
                    },
                    MultiModCooldowns = {
                        type = "toggle",
                        name = function () return AtlasToString( "chromietime-32x32" ) .. ( multiDisplays.Cooldowns and " |cFF00FF00Cooldowns|r" or " |cFFFF0000Cooldowns|r" ) end,
                        desc = function()
                            if multiDisplays.Cooldowns then return "Changes |cFF00FF00will|r be applied to the Cooldowns display." end
                            return "Changes |cFFFF0000will not|r be applied to the Cooldowns display."
                        end,
                        order = 0.03,
                        width = 0.65,
                        get = function() return multiDisplays.Cooldowns end,
                        set = function() multiDisplays.Cooldowns = not multiDisplays.Cooldowns end,
                        hidden = function () return name ~= "Multi" end,
                    },
                    MultiModDefensives = {
                        type = "toggle",
                        name = function () return AtlasToString( "nameplates-InterruptShield" ) .. ( multiDisplays.Defensives and " |cFF00FF00Defensives|r" or " |cFFFF0000Defensives|r" ) end,
                        desc = function()
                            if multiDisplays.Defensives then return "Changes |cFF00FF00will|r be applied to the Defensives display." end
                            return "Changes |cFFFF0000will not|r be applied to the Defensives display."
                        end,
                        order = 0.04,
                        width = 0.65,
                        get = function() return multiDisplays.Defensives end,
                        set = function() multiDisplays.Defensives = not multiDisplays.Defensives end,
                        hidden = function () return name ~= "Multi" end,
                    },
                    MultiModInterrupts = {
                        type = "toggle",
                        name = function () return AtlasToString( "voicechat-icon-speaker-mute" ) .. ( multiDisplays.Interrupts and " |cFF00FF00Interrupts|r" or " |cFFFF0000Interrupts|r" ) end,
                        desc = function()
                            if multiDisplays.Interrupts then return "Changes |cFF00FF00will|r be applied to the Interrupts display." end
                            return "Changes |cFFFF0000will not|r be applied to the Interrupts display."
                        end,
                        order = 0.05,
                        width = 0.65,
                        get = function() return multiDisplays.Interrupts end,
                        set = function() multiDisplays.Interrupts = not multiDisplays.Interrupts end,
                        hidden = function () return name ~= "Multi" end,
                    },
                    main = {
                        type = 'group',
                        name = "Main",
                        desc = "Includes display position, icons, primary icon size/shape, etc.",
                        order = 1,

                        args = {
                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                desc = "If disabled, this display will not appear under any circumstances.",
                                order = 0.5,
                                hidden = function () return data.name == "Primary" or data.name == "AOE" or data.name == "Cooldowns"  or data.name == "Defensives" or data.name == "Interrupts" end
                            },

                            elvuiCooldown = {
                                type = "toggle",
                                name = "Apply ElvUI Cooldown Style",
                                desc = "If ElvUI is installed, you can apply the ElvUI cooldown style to your queued icons.\n\nDisabling this setting requires you to reload your UI (|cFFFFD100/reload|r).",
                                width = "full",
                                order = 0.51,
                                hidden = function () return _G["ElvUI"] == nil end,
                            },

                            numIcons = {
                                type = 'range',
                                name = "Icons Shown",
                                desc = "Specify the number of recommendations to show.  Each icon shows an additional step forward in time.",
                                min = 1,
                                max = 10,
                                step = 1,
                                width = "full",
                                order = 1,
                                disabled = function()
                                    return name == "Multi"
                                end,
                                hidden = function( info, val )
                                    local n = #info
                                    local display = info[2]

                                    if display == "Defensives" or display == "Interrupts" then
                                        return true
                                    end

                                    return false
                                end,
                            },

                            pos = {
                                type = "group",
                                inline = true,
                                name = function( info ) rangeXY( info ); return "Position" end,
                                order = 10,

                                args = {
                                    --[[
                                    relativeTo = {
                                        type = "select",
                                        name = "Anchored To",
                                        values = {
                                            SCREEN = "Screen",
                                            PERSONAL = "Personal Resource Display",
                                            CUSTOM = "Custom"
                                        },
                                        order = 1,
                                        width = 1.49,
                                    },

                                    customFrame = {
                                        type = "input",
                                        name = "Custom Frame",
                                        desc = "Specify the name of the frame to which this display will be anchored.\n" ..
                                                "If the frame does not exist, the display will not be shown.",
                                        order = 1.1,
                                        width = 1.49,
                                        hidden = function() return data.relativeTo ~= "CUSTOM" end,
                                    },

                                    setParent = {
                                        type = "toggle",
                                        name = "Set Parent to Anchor",
                                        desc = "If checked, the display will be shown/hidden when the anchor is shown/hidden.",
                                        order = 3.9,
                                        width = 1.49,
                                        hidden = function() return data.relativeTo == "SCREEN" end,
                                    },

                                    preXY = {
                                        type = "description",
                                        name = " ",
                                        width = "full",
                                        order = 97
                                    }, ]]

                                    x = {
                                        type = "range",
                                        name = "X",
                                        desc = "Set the horizontal position for this display's primary icon relative to the center of the screen.  Negative " ..
                                            "values will move the display left; positive values will move it to the right.",
                                        min = -512,
                                        max = 512,
                                        step = 1,

                                        order = 98,
                                        width = 1.49,

                                        disabled = function()
                                            return name == "Multi"
                                        end,
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y",
                                        desc = "Set the vertical position for this display's primary icon relative to the center of the screen.  Negative " ..
                                            "values will move the display down; positive values will move it up.",
                                        min = -384,
                                        max = 384,
                                        step = 1,

                                        order = 99,
                                        width = 1.49,

                                        disabled = function()
                                            return name == "Multi"
                                        end,
                                    },
                                },
                            },

                            primaryIcon = {
                                type = "group",
                                name = "Primary Icon",
                                inline = true,
                                order = 15,
                                args = {
                                    primaryWidth = {
                                        type = "range",
                                        name = "Width",
                                        desc = "Specify the width of the primary icon for " .. ( name == "Multi" and "each display." or ( "your " .. name .. " Display." ) ),
                                        min = 10,
                                        max = 500,
                                        step = 1,

                                        width = 1.49,
                                        order = 1,
                                    },

                                    primaryHeight = {
                                        type = "range",
                                        name = "Height",
                                        desc = "Specify the height of the primary icon for " .. ( name == "Multi" and "each display." or ( "your " .. name .. " Display." ) ),
                                        min = 10,
                                        max = 500,
                                        step = 1,

                                        width = 1.49,
                                        order = 2,
                                    },

                                    spacer01 = {
                                        type = "description",
                                        name = " ",
                                        width = "full",
                                        order = 3
                                    },

                                    zoom = {
                                        type = "range",
                                        name = "Icon Zoom",
                                        desc = "Select the zoom percentage for the icon textures in this display. (Roughly 30% will trim off the default Blizzard borders.)",
                                        min = 0,
                                        softMax = 100,
                                        max = 200,
                                        step = 1,

                                        width = 1.49,
                                        order = 4,
                                    },

                                    keepAspectRatio = {
                                        type = "toggle",
                                        name = "Keep Aspect Ratio",
                                        desc = "If your primary or queued icons are not square, checking this option will prevent the icon textures from being " ..
                                            "stretched and distorted, trimming some of the texture instead.",
                                        disabled = function( info, val )
                                            return not ( data.primaryHeight ~= data.primaryWidth or ( data.numIcons > 1 and data.queue.height ~= data.queue.width ) )
                                        end,
                                        width = 1.49,
                                        order = 5,
                                    },
                                },
                            },

                            advancedFrame = {
                                type = "group",
                                name = "Frame Layer",
                                inline = true,
                                order = 16,
                                args = {
                                    frameStrata = {
                                        type = "select",
                                        name = "Strata",
                                        desc =  "Frame Strata determines which graphical layer that this display is drawn on.\n\n" ..
                                                "The default layer is |cFFFFD100MEDIUM|r.",
                                        values = {
                                            "BACKGROUND",
                                            "LOW",
                                            "MEDIUM",
                                            "HIGH",
                                            "DIALOG",
                                            "FULLSCREEN",
                                            "FULLSCREEN_DIALOG",
                                            "TOOLTIP"
                                        },
                                        width = 1.49,
                                        order = 1,
                                    },

                                    frameLevel = {
                                        type = "range",
                                        name = "Level",
                                        desc = "Frame Level determines the display's position within its current layer.\n\n" ..
                                                "Default value is |cFFFFD10010|r.",
                                        min = 1,
                                        max = 10000,
                                        step = 1,
                                        width = 1.49,
                                        order = 2,
                                    }
                                }
                            },
                        },
                    },

                    queue = {
                        type = "group",
                        name = "Queue",
                        desc = "Includes anchoring, size, shape, and position settings when a display can show more than one icon.",
                        order = 2,
                        disabled = function ()
                            return data.numIcons == 1
                        end,

                        args = {
                            elvuiCooldown = {
                                type = "toggle",
                                name = "Apply ElvUI Cooldown Style",
                                desc = "If ElvUI is installed, you can apply the ElvUI cooldown style to your queued icons.\n\nDisabling this setting requires you to reload your UI (|cFFFFD100/reload|r).",
                                width = "full",
                                order = 1,
                                hidden = function () return _G["ElvUI"] == nil end,
                            },

                            iconSizeGroup = {
                                type = "group",
                                inline = true,
                                name = "Icon Size",
                                order = 2,
                                args = {
                                    width = {
                                        type = 'range',
                                        name = 'Width',
                                        desc = "Select the width of the queued icons.",
                                        min = 10,
                                        max = 500,
                                        step = 1,
                                        bigStep = 1,
                                        order = 10,
                                        width = 1.49
                                    },

                                    height = {
                                        type = 'range',
                                        name = 'Height',
                                        desc = "Select the height of the queued icons.",
                                        min = 10,
                                        max = 500,
                                        step = 1,
                                        bigStep = 1,
                                        order = 11,
                                        width = 1.49
                                    },
                                }
                            },

                            anchorGroup = {
                                type = "group",
                                inline = true,
                                name = "Positioning",
                                order = 3,
                                args = {
                                    anchor = {
                                        type = 'select',
                                        name = 'Anchor To',
                                        desc = "Select the point on the primary icon to which the queued icons will attach.",
                                        values = anchorPositions,
                                        width = 1.49,
                                        order = 1,
                                    },

                                    direction = {
                                        type = 'select',
                                        name = 'Grow Direction',
                                        desc = "Select the direction for the icon queue.",
                                        values = {
                                            TOP = 'Up',
                                            BOTTOM = 'Down',
                                            LEFT = 'Left',
                                            RIGHT = 'Right'
                                        },
                                        width = 1.49,
                                        order = 1.1,
                                    },

                                    spacer01 = {
                                        type = "description",
                                        name = " ",
                                        order = 1.2,
                                        width = "full",
                                    },

                                    offsetX = {
                                        type = 'range',
                                        name = 'X Offset',
                                        desc = 'Specify the horizontal offset (in pixels) for the queue, in relation to the anchor point on the primary icon for this display.  Positive numbers move the queue to the right, negative numbers move it to the left.',
                                        min = -100,
                                        max = 500,
                                        step = 1,
                                        width = 1.49,
                                        order = 2,
                                    },

                                    offsetY = {
                                        type = 'range',
                                        name = 'Y Offset',
                                        desc = 'Specify the vertical offset (in pixels) for the queue, in relation to the anchor point on the primary icon for this display.  Positive numbers move the queue up, negative numbers move it down.',
                                        min = -100,
                                        max = 500,
                                        step = 1,
                                        width = 1.49,
                                        order = 2.1,
                                    },

                                    spacer02 = {
                                        type = "description",
                                        name = " ",
                                        order = 2.2,
                                        width = "full",
                                    },

                                    spacing = {
                                        type = 'range',
                                        name = 'Icon Spacing',
                                        desc = "Select the number of pixels between icons in the queue.",
                                        softMin = ( data.queue.direction == "LEFT" or data.queue.direction == "RIGHT" ) and -data.queue.width or -data.queue.height,
                                        softMax = ( data.queue.direction == "LEFT" or data.queue.direction == "RIGHT" ) and data.queue.width or data.queue.height,
                                        min = -500,
                                        max = 500,
                                        step = 1,
                                        order = 3,
                                        width = 2.98
                                    },
                                }
                            },
                        },
                    },

                    visibility = {
                        type = 'group',
                        name = 'Visibility',
                        desc = "Visibility and transparency settings in PvE / PvP.",
                        order = 3,

                        args = {

                            advanced = {
                                type = "toggle",
                                name = "Advanced",
                                desc = "If checked, options are provided to fine-tune display visibility and transparency.",
                                width = "full",
                                order = 1,
                            },

                            simple = {
                                type = 'group',
                                inline = true,
                                name = "",
                                hidden = function() return data.visibility.advanced end,
                                get = function( info )
                                    local option = info[ #info ]

                                    if option == 'pveAlpha' then return data.visibility.pve.alpha
                                    elseif option == 'pvpAlpha' then return data.visibility.pvp.alpha end
                                end,
                                set = function( info, val )
                                    local option = info[ #info ]

                                    if option == 'pveAlpha' then data.visibility.pve.alpha = val
                                    elseif option == 'pvpAlpha' then data.visibility.pvp.alpha = val end

                                    QueueRebuildUI()
                                end,
                                order = 2,
                                args = {
                                    pveAlpha = {
                                        type = "range",
                                        name = "PvE Alpha",
                                        desc = "Set the transparency of the display when in PvE environments.  If set to 0, the display will not appear in PvE.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        order = 1,
                                        width = 1.49,
                                    },
                                    pvpAlpha = {
                                        type = "range",
                                        name = "PvP Alpha",
                                        desc = "Set the transparency of the display when in PvP environments.  If set to 0, the display will not appear in PvP.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        order = 1,
                                        width = 1.49,
                                    },
                                }
                            },

                            pveComplex = {
                                type = 'group',
                                inline = true,
                                name = "PvE",
                                get = function( info )
                                    local option = info[ #info ]

                                    return data.visibility.pve[ option ]
                                end,
                                set = function( info, val )
                                    local option = info[ #info ]

                                    data.visibility.pve[ option ] = val
                                    QueueRebuildUI()
                                end,
                                hidden = function() return not data.visibility.advanced end,
                                order = 2,
                                args = {
                                    always = {
                                        type = "range",
                                        name = "Default",
                                        desc = "If non-zero, this display is shown with the specified level of opacity by default.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = 1.49,
                                        order = 1,
                                    },

                                    combat = {
                                        type = "range",
                                        name = "Combat",
                                        desc = "If non-zero, this display is shown with the specified level of opacity in PvE combat.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = 1.49,
                                        order = 3,
                                    },

                                    break01 = {
                                        type = "description",
                                        name = " ",
                                        width = "full",
                                        order = 2.1
                                    },

                                    target = {
                                        type = "range",
                                        name = "Target",
                                        desc = "If non-zero, this display is shown with the specified level of opacity when you have an attackable PvE target.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = 1.49,
                                        order = 2,
                                    },

                                    combatTarget = {
                                        type = "range",
                                        name = "Combat w/ Target",
                                        desc = "If non-zero, this display is shown with the specified level of opacity when you are in combat and have an attackable PvE target.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = 1.49,
                                        order = 4,
                                    },

                                    hideMounted = {
                                        type = "toggle",
                                        name = "Hide When Mounted",
                                        desc = "If checked, the display will not be visible when you are mounted when out of combat.",
                                        width = "full",
                                        order = 0.5,
                                    }
                                },
                            },

                            pvpComplex = {
                                type = 'group',
                                inline = true,
                                name = "PvP",
                                get = function( info )
                                    local option = info[ #info ]

                                    return data.visibility.pvp[ option ]
                                end,
                                set = function( info, val )
                                    local option = info[ #info ]

                                    data.visibility.pvp[ option ] = val
                                    QueueRebuildUI()
                                    Hekili:UpdateDisplayVisibility()
                                end,
                                hidden = function() return not data.visibility.advanced end,
                                order = 2,
                                args = {
                                    always = {
                                        type = "range",
                                        name = "Default",
                                        desc = "If non-zero, this display is shown with the specified level of opacity by default.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = 1.49,
                                        order = 1,
                                    },

                                    combat = {
                                        type = "range",
                                        name = "Combat",
                                        desc = "If non-zero, this display is shown with the specified level of opacity in PvP combat.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = 1.49,
                                        order = 3,
                                    },

                                    break01 = {
                                        type = "description",
                                        name = " ",
                                        width = "full",
                                        order = 2.1
                                    },

                                    target = {
                                        type = "range",
                                        name = "Target",
                                        desc = "If non-zero, this display is shown with the specified level of opacity when you have an attackable PvP target.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = 1.49,
                                        order = 2,
                                    },

                                    combatTarget = {
                                        type = "range",
                                        name = "Combat w/ Target",
                                        desc = "If non-zero, this display is shown with the specified level of opacity when you are in combat and have an attackable PvP target.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = 1.49,
                                        order = 4,
                                    },

                                    hideMounted = {
                                        type = "toggle",
                                        name = "Hide When Mounted",
                                        desc = "If checked, the display will not be visible when you are mounted unless you are in combat.",
                                        width = "full",
                                        order = 0.5,
                                    }
                                },
                            },
                        },
                    },

                    keybindings = {
                        type = "group",
                        name = "Keybinds",
                        desc = "Options for keybinding text on displayed icons.",
                        order = 7,

                        args = {
                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                order = 1,
                                width = 1.49,
                            },

                            queued = {
                                type = "toggle",
                                name = "Enabled for Queued Icons",
                                order = 2,
                                width = 1.49,
                                disabled = function () return data.keybindings.enabled == false end,
                            },

                            pos = {
                                type = "group",
                                inline = true,
                                name = function( info ) rangeIcon( info ); return "Position" end,
                                order = 3,
                                args = {
                                    anchor = {
                                        type = "select",
                                        name = 'Anchor Point',
                                        order = 2,
                                        width = 1,
                                        values = realAnchorPositions
                                    },

                                    x = {
                                        type = "range",
                                        name = "X Offset",
                                        order = 3,
                                        width = 0.99,
                                        min = -max( data.primaryWidth, data.queue.width ),
                                        max = max( data.primaryWidth, data.queue.width ),
                                        disabled = function( info )
                                            return false
                                        end,
                                        step = 1,
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y Offset",
                                        order = 4,
                                        width = 0.99,
                                        min = -max( data.primaryHeight, data.queue.height ),
                                        max = max( data.primaryHeight, data.queue.height ),
                                        step = 1,
                                    }
                                }
                            },

                            textStyle = {
                                type = "group",
                                inline = true,
                                name = "Font and Style",
                                order = 5,
                                args = tableCopy( fontElements ),
                            },

                            lowercase = {
                                type = "toggle",
                                name = "Use Lowercase",
                                order = 5.1,
                                width = "full",
                            },

                            separateQueueStyle = {
                                type = "toggle",
                                name = "Use Different Settings for Queue",
                                order = 6,
                                width = "full",
                            },

                            queuedTextStyle = {
                                type = "group",
                                inline = true,
                                name = "Queued Font and Style",
                                order = 7,
                                hidden = function () return not data.keybindings.separateQueueStyle end,
                                args = {
                                    queuedFont = {
                                        type = "select",
                                        name = "Font",
                                        order = 1,
                                        width = 1.49,
                                        dialogControl = 'LSM30_Font',
                                        values = LSM:HashTable("font"),
                                    },

                                    queuedFontStyle = {
                                        type = "select",
                                        name = "Style",
                                        order = 2,
                                        values = fontStyles,
                                        width = 1.49
                                    },

                                    break01 = {
                                        type = "description",
                                        name = " ",
                                        width = "full",
                                        order = 2.1
                                    },

                                    queuedFontSize = {
                                        type = "range",
                                        name = "Size",
                                        order = 3,
                                        min = 8,
                                        max = 64,
                                        step = 1,
                                        width = 1.49
                                    },

                                    queuedColor = {
                                        type = "color",
                                        name = "Color",
                                        order = 4,
                                        width = 1.49
                                    }
                                },
                            },

                            queuedLowercase = {
                                type = "toggle",
                                name = "Use Lowercase in Queue",
                                order = 7.1,
                                width = 1.49,
                                hidden = function () return not data.keybindings.separateQueueStyle end,
                            },

                            cPort = {
                                name = "ConsolePort",
                                type = "group",
                                inline = true,
                                order = 4,
                                args = {
                                    cPortOverride = {
                                        type = "toggle",
                                        name = "Use ConsolePort Buttons",
                                        order = 6,
                                        width = 1.49,
                                    },

                                    cPortZoom = {
                                        type = "range",
                                        name = "ConsolePort Button Zoom",
                                        desc = "The ConsolePort button textures generally have a significant amount of blank padding around them. " ..
                                            "Zooming in removes some of this padding to help the buttons fit on the icon.  The default is |cFFFFD1000.6|r.",
                                        order = 7,
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = 1.49,
                                    },
                                },
                                disabled = function() return ConsolePort == nil end,
                            },

                        }
                    },

                    border = {
                        type = "group",
                        name = "Border",
                        desc = "Enable/disable or set the color for icon borders.\n\n" ..
                            "You may want to disable this if you use Masque or other tools to skin your Hekili icons.",
                        order = 4,

                        args = {
                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                desc = "If enabled, each icon in this display will have a thin border.",
                                order = 1,
                                width = "full",
                            },

                            thickness = {
                                type = "range",
                                name = "Border Thickness",
                                desc = "Determines the thickness (width) of the border.  Default is 1.",
                                softMin = 1,
                                softMax = 20,
                                step = 1,
                                order = 2,
                                width = 1.49,
                            },

                            fit = {
                                type = "toggle",
                                name = "Border Inside",
                                desc = "If enabled, when borders are enabled, the button's border will fit inside the button (instead of around it).",
                                order = 2.5,
                                width = 1.49
                            },

                            break01 = {
                                type = "description",
                                name = " ",
                                width = "full",
                                order = 2.6
                            },

                            coloring = {
                                type = "select",
                                name = "Coloring Mode",
                                desc = "Specify whether to use Class or Custom color borders.\n\nClass-colored borders will automatically change to match the class you are playing.",
                                width = 1.49,
                                order = 3,
                                values = {
                                    class = format( "Class |A:WhiteCircle-RaidBlips:16:16:0:0:%d:%d:%d|a #%s", ClassColor.r * 255, ClassColor.g * 255, ClassColor.b * 255, ClassColor:GenerateHexColor():sub( 3, 8 ) ),
                                    custom = "Specify a Custom Color"
                                },
                                disabled = function() return data.border.enabled == false end,
                            },

                            color = {
                                type = "color",
                                name = "Custom Color",
                                desc = "When borders are enabled and the Coloring Mode is set to |cFFFFD100Custom Color|r, the border will use this color.",
                                order = 4,
                                width = 1.49,
                                disabled = function () return data.border.enabled == false or data.border.coloring ~= "custom" end,
                            }
                        }
                    },

                    range = {
                        type = "group",
                        name = "Range",
                        desc = "Preferences for range-check warnings, if desired.",
                        order = 5,
                        args = {
                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                desc = "If enabled, the addon will provide a red warning highlight when you are not in range of your enemy.",
                                width = 1.49,
                                order = 1,
                            },

                            type = {
                                type = "select",
                                name = 'Range Checking',
                                desc = "Select the kind of range checking and range coloring to be used by this display.\n\n" ..
                                    "|cFFFFD100Ability|r - Each ability is highlighted in red if that ability is out of range.\n\n" ..
                                    "|cFFFFD100Melee|r - All abilities are highlighted in red if you are out of melee range.\n\n" ..
                                    "|cFFFFD100Exclude|r - If an ability is not in-range, it will not be recommended.",
                                values = {
                                    ability = "Per Ability",
                                    melee = "Melee Range",
                                    xclude = "Exclude Out-of-Range"
                                },
                                width = 1.49,
                                order = 2,
                                disabled = function () return data.range.enabled == false end,
                            }
                        }
                    },

                    glow = {
                        type = "group",
                        name = "Glows",
                        desc = "Preferences for Blizzard action button glows (not SpellFlash).",
                        order = 6,
                        args = {
                            enabled = {
                                type = "toggle",
                                name = "Enable Overlay Glow",
                                desc = "If enabled, when the ability for the first icon has an active glow (or overlay), it will also glow in this display.",
                                width = 1.49,
                                order = 1,
                            },

                            queued = {
                                type = "toggle",
                                name = "Enabled for Queued Icons",
                                desc = "If enabled, abilities that have active glows (or overlays) will also glow in your queue.\n\n" ..
                                    "This may not be ideal, the glow may no longer be correct by that point in the future.",
                                width = 1.49,
                                order = 2,
                                disabled = function() return data.glow.enabled == false end,
                            },

                            break01 = {
                                type = "description",
                                name = " ",
                                order = 2.1,
                                width = "full"
                            },

                            mode = {
                                type = "select",
                                name = "Glow Style",
                                desc = "Select the glow style for your display.",
                                width = 1,
                                order = 3,
                                values = {
                                    default = "Default Button Glow",
                                    autocast = "AutoCast Shine",
                                    pixel = "Pixel Glow",
                                },
                                disabled = function() return data.glow.enabled == false end,
                            },

                            coloring = {
                                type = "select",
                                name = "Coloring Mode",
                                desc = "Select the coloring mode for this glow effect.\n\nClass-colored borders will automatically change to match the class you are playing.",
                                width = 0.99,
                                order = 4,
                                values = {
                                    default = "Use Default Color",
                                    class = format( "Class |A:WhiteCircle-RaidBlips:16:16:0:0:%d:%d:%d|a #%s", ClassColor.r * 255, ClassColor.g * 255, ClassColor.b * 255, ClassColor:GenerateHexColor():sub( 3, 8 ) ),
                                    custom = "Specify a Custom Color"
                                },
                                disabled = function() return data.glow.enabled == false end,
                            },

                            color = {
                                type = "color",
                                name = "Glow Color",
                                desc = "Select the custom glow color for your display.",
                                width = 0.99,
                                order = 5,
                                disabled = function() return data.glow.coloring ~= "custom" end,
                            },

                            break02 = {
                                type = "description",
                                name = " ",
                                order = 10,
                                width = "full",
                            },

                            highlight = {
                                type = "toggle",
                                name = "Enable Action Highlight",
                                desc = "If enabled, the addon will apply the default highlight when the first recommended item/ability is currently queued.",
                                width = "full",
                                order = 11
                            }
                        },
                    },

                    flash = {
                        type = "group",
                        name = "SpellFlash",
                        desc = function ()
                            if SF then
                                return "If enabled, the addon can highlight abilities on your action bars when they are recommended for use."
                            end
                            return "This feature requires the SpellFlashCore addon or library to function properly."
                        end,
                        order = 8,
                        args = {
                            warning = {
                                type = "description",
                                name = "These settings are unavailable because the SpellFlashCore addon / library is not installed or is disabled.",
                                order = 0,
                                fontSize = "medium",
                                width = "full",
                                hidden = function () return SF ~= nil end,
                            },

                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                desc = "If enabled, the addon will place a colorful glow on the first recommended ability for this display.",

                                width = 1.49,
                                order = 1,
                                hidden = function () return SF == nil end,
                            },

                            color = {
                                type = "color",
                                name = "Color",
                                desc = "Specify a glow color for the SpellFlash highlight.",
                                order = 2,
                                width = 1.49,
                                hidden = function () return SF == nil end,
                            },

                            break00 = {
                                type = "description",
                                name = " ",
                                order = 2.1,
                                width = "full",
                                hidden = function () return SF == nil end,
                            },

                            sample = {
                                type = "description",
                                name = "",
                                image = function() return Hekili.DB.profile.flashTexture end,
                                order = 3,
                                width = 0.3,
                                hidden = function () return SF == nil end,
                            },

                            flashTexture = {
                                type = "select",
                                name = "Texture",
                                icon =  function() return data.flash.texture or "Interface\\Cooldown\\star4" end,
                                desc = "Your selection will override the SpellFlash texture for all displays' flashes.\n\nRequires |cFFFFD100/reload|r.",
                                order = 3.1,
                                width = 1.19,
                                values = {
                                    ["Interface\\Cooldown\\star4"] = "Star (Default)",
                                    ["Interface\\Cooldown\\ping4"] = "Circle",
                                    ["Interface\\Cooldown\\starburst"] = "Starburst",
                                    ["Interface\\AddOns\\Hekili\\Textures\\MonoCircle2"] = "Monochrome Circle Thin",
                                    ["Interface\\AddOns\\Hekili\\Textures\\MonoCircle5"] = "Monochrome Circle Thick",
                                },
                                get = function()
                                    return Hekili.DB.profile.flashTexture
                                end,
                                set = function( _, val )
                                    Hekili.DB.profile.flashTexture = val
                                end,
                                hidden = function () return SF == nil end,
                            },

                            speed = {
                                type = "range",
                                name = "Speed",
                                desc = "Specify how frequently the flash should restart.  The default is |cFFFFD1000.4s|r.",
                                min = 0.1,
                                max = 2,
                                step = 0.1,
                                order = 3.2,
                                width = 1.49,
                                hidden = function () return SF == nil end,
                            },

                            break01 = {
                                type = "description",
                                name = " ",
                                order = 4,
                                width = "full",
                                hidden = function () return SF == nil end,
                            },

                            size = {
                                type = "range",
                                name = "Flash Size",
                                desc = "Specify the size of the SpellFlash glow.  The default size is |cFFFFD100240|r.",
                                order = 5,
                                min = 0,
                                max = 240 * 8,
                                step = 1,
                                width = 1.49,
                                hidden = function () return SF == nil end,
                            },

                            fixedSize = {
                                type = "toggle",
                                name = "Fixed Size",
                                desc = "If checked, the SpellFlash pulse (grow and shrink) animation will be suppressed.",
                                order = 6,
                                width = 1.49,
                                hidden = function () return SF == nil end,
                            },

                            break02 = {
                                type = "description",
                                name = " ",
                                order = 7,
                                width = "full",
                                hidden = function () return SF == nil end,
                            },

                            brightness = {
                                type = "range",
                                name = "Flash Brightness",
                                desc = "Specify the brightness of the SpellFlash glow.  The default brightness is |cFFFFD100100|r.",
                                order = 8,
                                min = 0,
                                max = 100,
                                step = 1,
                                width = 1.49,
                                hidden = function () return SF == nil end,
                            },

                            fixedBrightness = {
                                type = "toggle",
                                name = "Fixed Brightness",
                                desc = "If checked, the SpellFlash glow will not dim/brighten.",
                                order = 9,
                                width = 1.49,
                                hidden = function () return SF == nil end,
                            },

                            break03 = {
                                type = "description",
                                name = " ",
                                order = 10,
                                width = "full",
                                hidden = function () return SF == nil end,
                            },

                            combat = {
                                type = "toggle",
                                name = "Combat Only",
                                desc = "If checked, the addon will only create flashes when you are in combat.",
                                order = 11,
                                width = "full",
                                hidden = function () return SF == nil end,
                            },

                            suppress = {
                                type = "toggle",
                                name = "Hide Display",
                                desc = "If checked, the addon will not show this display and will make recommendations via SpellFlash only.",
                                order = 12,
                                width = "full",
                                hidden = function () return SF == nil end,
                            },

                            blink = {
                                type = "toggle",
                                name = "Button Blink",
                                desc = "If enabled, the whole action button will fade in and out.  The default is |cFFFF0000disabled|r.",
                                order = 13,
                                width = "full",
                                hidden = function () return SF == nil end,
                            },
                        },
                    },

                    captions = {
                        type = "group",
                        name = "Captions",
                        desc = "Captions are brief descriptions sometimes (rarely) used in action lists to describe why the action is shown.",
                        order = 9,
                        args = {
                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                desc = "If enabled, when the first ability shown has a descriptive caption, the caption will be shown.",
                                order = 1,
                                width = 1.49,
                            },

                            queued = {
                                type = "toggle",
                                name = "Enabled for Queued Icons",
                                desc = "If enabled, descriptive captions will be shown for queued abilities, if appropriate.",
                                order = 2,
                                width = 1.49,
                                disabled = function () return data.captions.enabled == false end,
                            },

                            position = {
                                type = "group",
                                inline = true,
                                name = function( info ) rangeIcon( info ); return "Position" end,
                                order = 3,
                                args = {
                                    anchor = {
                                        type = "select",
                                        name = 'Anchor Point',
                                        order = 1,
                                        width = 1,
                                        values = {
                                            TOP = 'Top',
                                            BOTTOM = 'Bottom',
                                        }
                                    },

                                    x = {
                                        type = "range",
                                        name = "X Offset",
                                        order = 2,
                                        width = 0.99,
                                        step = 1,
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y Offset",
                                        order = 3,
                                        width = 0.99,
                                        step = 1,
                                    },

                                    break01 = {
                                        type = "description",
                                        name = " ",
                                        order = 3.1,
                                        width = "full",
                                    },

                                    align = {
                                        type = "select",
                                        name = "Alignment",
                                        order = 4,
                                        width = 1.49,
                                        values = {
                                            LEFT = "Left",
                                            RIGHT = "Right",
                                            CENTER = "Center"
                                        },
                                    },
                                }
                            },

                            textStyle = {
                                type = "group",
                                inline = true,
                                name = "Text",
                                order = 4,
                                args = tableCopy( fontElements ),
                            },
                        }
                    },

                    empowerment = {
                        type = "group",
                        name = NewFeature .. "Empowerment",
                        desc = "Empowerment stages are shown with additional text placed on the recommendation icon.",
                        order = 9.1,
                        args = {
                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                desc = "If enabled, when the first ability shown is an empowered spell, the empowerment stage of the spell will be shown.",
                                order = 1,
                                width = 1.49,
                            },

                            queued = {
                                type = "toggle",
                                name = "Enabled for Queued Icons",
                                desc = "If enabled, empowerment stage text will be shown for queued empowered abilities.",
                                order = 2,
                                width = 1.49,
                                disabled = function () return data.empowerment.enabled == false end,
                            },

                            position = {
                                type = "group",
                                inline = true,
                                name = function( info ) rangeIcon( info ); return "Position" end,
                                order = 3,
                                args = {
                                    anchor = {
                                        type = "select",
                                        name = 'Anchor Point',
                                        order = 1,
                                        width = 1,
                                        values = {
                                            TOP = 'Top',
                                            BOTTOM = 'Bottom',
                                        }
                                    },

                                    x = {
                                        type = "range",
                                        name = "X Offset",
                                        order = 2,
                                        width = 0.99,
                                        step = 1,
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y Offset",
                                        order = 3,
                                        width = 0.99,
                                        step = 1,
                                    },

                                    break01 = {
                                        type = "description",
                                        name = " ",
                                        order = 3.1,
                                        width = "full",
                                    },

                                    align = {
                                        type = "select",
                                        name = "Alignment",
                                        order = 4,
                                        width = 1.49,
                                        values = {
                                            LEFT = "Left",
                                            RIGHT = "Right",
                                            CENTER = "Center"
                                        },
                                    },
                                }
                            },

                            textStyle = {
                                type = "group",
                                inline = true,
                                name = "Text",
                                order = 4,
                                args = tableCopy( fontElements ),
                            },
                        }
                    },

                    targets = {
                        type = "group",
                        name = "Targets",
                        desc = "A target count indicator can be shown on the display's first recommendation.",
                        order = 10,
                        args = {
                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                desc = "If enabled, the addon will show the number of active (or virtual) targets for this display.",
                                order = 1,
                                width = "full",
                            },

                            pos = {
                                type = "group",
                                inline = true,
                                name = function( info ) rangeIcon( info ); return "Position" end,
                                order = 2,
                                args = {
                                    anchor = {
                                        type = "select",
                                        name = "Anchor To",
                                        values = realAnchorPositions,
                                        order = 1,
                                        width = 1,
                                    },

                                    x = {
                                        type = "range",
                                        name = "X Offset",
                                        min = -max( data.primaryWidth, data.queue.width ),
                                        max = max( data.primaryWidth, data.queue.width ),
                                        step = 1,
                                        order = 2,
                                        width = 0.99,
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y Offset",
                                        min = -max( data.primaryHeight, data.queue.height ),
                                        max = max( data.primaryHeight, data.queue.height ),
                                        step = 1,
                                        order = 2,
                                        width = 0.99,
                                    }
                                }
                            },

                            textStyle = {
                                type = "group",
                                inline = true,
                                name = "Text",
                                order = 3,
                                args = tableCopy( fontElements ),
                            },
                        }
                    },

                    delays = {
                        type = "group",
                        name = "Delays",
                        desc = "When an ability is recommended some time in the future, a colored indicator or countdown timer can " ..
                            "communicate that there is a delay.",
                        order = 11,
                        args = {
                            extend = {
                                type = "toggle",
                                name = "Extend Spiral",
                                desc = "If checked, the primary icon's cooldown spiral will continue until the ability should be used.",
                                width = 1.49,
                                order = 1,
                            },

                            fade = {
                                type = "toggle",
                                name = "Fade as Unusable",
                                desc = "Fade the primary icon when you should wait before using the ability, similar to when an ability is lacking required resources.",
                                width = 1.49,
                                order = 1.1
                            },

                            break01 = {
                                type = "description",
                                name = " ",
                                order = 1.2,
                                width = "full",
                            },

                            type = {
                                type = "select",
                                name = "Indicator",
                                desc = "Specify the type of indicator to use when you should wait before casting the ability.",
                                values = {
                                    __NA = "No Indicator",
                                    ICON = "Show Icon (Color)",
                                    TEXT = "Show Text (Countdown)",
                                },
                                width = 1.49,
                                order = 2,
                            },

                            pos = {
                                type = "group",
                                inline = true,
                                name = function( info ) rangeIcon( info ); return "Position" end,
                                order = 3,
                                args = {
                                    anchor = {
                                        type = "select",
                                        name = 'Anchor Point',
                                        order = 2,
                                        width = 1,
                                        values = realAnchorPositions
                                    },

                                    x = {
                                        type = "range",
                                        name = "X Offset",
                                        order = 3,
                                        width = 0.99,
                                        min = -max( data.primaryWidth, data.queue.width ),
                                        max = max( data.primaryWidth, data.queue.width ),
                                        step = 1,
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y Offset",
                                        order = 4,
                                        width = 0.99,
                                        min = -max( data.primaryHeight, data.queue.height ),
                                        max = max( data.primaryHeight, data.queue.height ),
                                        step = 1,
                                    }
                                },
                                disabled = function () return data.delays.type == "__NA" end,
                            },

                            textStyle = {
                                type = "group",
                                inline = true,
                                name = "Text",
                                order = 4,
                                args = tableCopy( fontElements ),
                                disabled = function () return data.delays.type ~= "TEXT" end,
                            },
                        }
                    },

                    indicators = {
                        type = "group",
                        name = "Indicators",
                        desc = "Indicators are small icons that can indicate target-swapping or (rarely) cancelling auras.",
                        order = 11,
                        args = {
                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                desc = "If enabled, small indicators for target-swapping, aura-cancellation, etc. may appear on your primary icon.",
                                order = 1,
                                width = 1.49,
                            },

                            queued = {
                                type = "toggle",
                                name = "Enabled for Queued Icons",
                                desc = "If enabled, these indicators will appear on queued icons as well as the primary icon, when appropriate.",
                                order = 2,
                                width = 1.49,
                                disabled = function () return data.indicators.enabled == false end,
                            },

                            pos = {
                                type = "group",
                                inline = true,
                                name = function( info ) rangeIcon( info ); return "Position" end,
                                order = 2,
                                args = {
                                    anchor = {
                                        type = "select",
                                        name = "Anchor To",
                                        values = realAnchorPositions,
                                        order = 1,
                                        width = 1,
                                    },

                                    x = {
                                        type = "range",
                                        name = "X Offset",
                                        min = -max( data.primaryWidth, data.queue.width ),
                                        max = max( data.primaryWidth, data.queue.width ),
                                        step = 1,
                                        order = 2,
                                        width = 0.99,
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y Offset",
                                        min = -max( data.primaryHeight, data.queue.height ),
                                        max = max( data.primaryHeight, data.queue.height ),
                                        step = 1,
                                        order = 2,
                                        width = 0.99,
                                    }
                                }
                            },
                        }
                    },
                },
            },
        }

        return option
    end


    function Hekili:EmbedDisplayOptions( db )
        db = db or self.Options
        if not db then return end

        local section = db.args.displays or {
            type = "group",
            name = "Displays",
            childGroups = "tree",
            cmdHidden = true,
            get = 'GetDisplayOption',
            set = 'SetDisplayOption',
            order = 30,

            args = {
                header = {
                    type = "description",
                    name = "Hekili has up to five built-in displays (identified in blue) that can display " ..
                        "different kinds of recommendations.  The addon's recommendations are based upon the " ..
                        "Priorities that are generally (but not exclusively) based on SimulationCraft profiles " ..
                        "so that you can compare your performance to the results of your simulations.",
                    fontSize = "medium",
                    width = "full",
                    order = 1,
                },

                displays = {
                    type = "header",
                    name = "Displays",
                    order = 10,
                },


                nPanelHeader = {
                    type = "header",
                    name = "Notification Panel",
                    order = 950,
                },

                nPanelBtn = {
                    type = "execute",
                    name = "Notification Panel",
                    desc = "The Notification Panel provides brief updates when settings are changed or " ..
                        "toggled while in combat.",
                    func = function ()
                        ACD:SelectGroup( "Hekili", "displays", "nPanel" )
                    end,
                    order = 951,
                },

                nPanel = {
                    type = "group",
                    name = "|cFF1EFF00Notification Panel|r",
                    desc = "The Notification Panel provides brief updates when settings are changed or " ..
                        "toggled while in combat.",
                    order = 952,
                    get = GetNotifOption,
                    set = SetNotifOption,
                    args = {
                        enabled = {
                            type = "toggle",
                            name = "Enabled",
                            order = 1,
                            width = "full",
                        },

                        posRow = {
                            type = "group",
                            name = function( info ) rangeXY( info, true ); return "Position" end,
                            inline = true,
                            order = 2,
                            args = {
                                x = {
                                    type = "range",
                                    name = "X",
                                    desc = "Enter the horizontal position of the notification panel, " ..
                                        "relative to the center of the screen.  Negative values move the " ..
                                        "panel left; positive values move the panel right.",
                                    min = -512,
                                    max = 512,
                                    step = 1,

                                    width = 1.49,
                                    order = 1,
                                },

                                y = {
                                    type = "range",
                                    name = "Y",
                                    desc = "Enter the vertical position of the notification panel, " ..
                                        "relative to the center of the screen.  Negative values move the " ..
                                        "panel down; positive values move the panel up.",
                                    min = -384,
                                    max = 384,
                                    step = 1,

                                    width = 1.49,
                                    order = 2,
                                },
                            }
                        },

                        sizeRow = {
                            type = "group",
                            name = "Size",
                            inline = true,
                            order = 3,
                            args = {
                                width = {
                                    type = "range",
                                    name = "Width",
                                    min = 50,
                                    max = 1000,
                                    step = 1,

                                    width = "full",
                                    order = 1,
                                },

                                height = {
                                    type = "range",
                                    name = "Height",
                                    min = 20,
                                    max = 600,
                                    step = 1,

                                    width = "full",
                                    order = 2,
                                },
                            }
                        },

                        fontGroup = {
                            type = "group",
                            inline = true,
                            name = "Text",

                            order = 5,
                            args = tableCopy( fontElements ),
                        },
                    }
                },

                fontHeader = {
                    type = "header",
                    name = "Fonts",
                    order = 960,
                },

                fontWarn = {
                    type = "description",
                    name = "Changing the font below will modify |cFFFF0000ALL|r text on all displays.\n" ..
                            "To modify one bit of text individually, select the Display (at left) and select the appropriate text.",
                    order = 960.01,
                },

                font = {
                    type = "select",
                    name = "Font",
                    order = 960.1,
                    width = 1.5,
                    dialogControl = 'LSM30_Font',
                    values = LSM:HashTable("font"),
                    get = function( info )
                        -- Display the information from Primary, Keybinds.
                        return Hekili.DB.profile.displays.Primary.keybindings.font
                    end,
                    set = function( info, val )
                        -- Set all fonts in all displays.
                        for _, display in pairs( Hekili.DB.profile.displays ) do
                            for _, data in pairs( display ) do
                                if type( data ) == "table" and data.font then data.font = val end
                            end
                        end
                        QueueRebuildUI()
                    end,
                },

                fontSize = {
                    type = "range",
                    name = "Size",
                    order = 960.2,
                    min = 8,
                    max = 64,
                    step = 1,
                    get = function( info )
                        -- Display the information from Primary, Keybinds.
                        return Hekili.DB.profile.displays.Primary.keybindings.fontSize
                    end,
                    set = function( info, val )
                        -- Set all fonts in all displays.
                        for _, display in pairs( Hekili.DB.profile.displays ) do
                            for _, data in pairs( display ) do
                                if type( data ) == "table" and data.fontSize then data.fontSize = val end
                            end
                        end
                        QueueRebuildUI()
                    end,
                    width = 1.5,
                },

                fontStyle = {
                    type = "select",
                    name = "Style",
                    order = 960.3,
                    values = {
                        ["MONOCHROME"] = "Monochrome",
                        ["MONOCHROME,OUTLINE"] = "Monochrome, Outline",
                        ["MONOCHROME,THICKOUTLINE"] = "Monochrome, Thick Outline",
                        ["NONE"] = "None",
                        ["OUTLINE"] = "Outline",
                        ["THICKOUTLINE"] = "Thick Outline"
                    },
                    get = function( info )
                        -- Display the information from Primary, Keybinds.
                        return Hekili.DB.profile.displays.Primary.keybindings.fontStyle
                    end,
                    set = function( info, val )
                        -- Set all fonts in all displays.
                        for _, display in pairs( Hekili.DB.profile.displays ) do
                            for _, data in pairs( display ) do
                                if type( data ) == "table" and data.fontStyle then data.fontStyle = val end
                            end
                        end
                        QueueRebuildUI()
                    end,
                    width = 1.5,
                },

                color = {
                    type = "color",
                    name = "Color",
                    order = 960.4,
                    get = function( info )
                        return unpack( Hekili.DB.profile.displays.Primary.keybindings.color )
                    end,
                    set = function( info, ... )
                        for name, display in pairs( Hekili.DB.profile.displays ) do
                            for _, data in pairs( display ) do
                                if type( data ) == "table" and data.color then data.color = { ... } end
                            end
                        end
                        QueueRebuildUI()
                    end,
                    width = 1.5
                },

                shareHeader = {
                    type = "header",
                    name = "Sharing",
                    order = 996,
                },

                shareBtn = {
                    type = "execute",
                    name = "Share Styles",
                    desc = "Your display styles can be shared with other addon users with these export strings.\n\n" ..
                        "You can also import a shared export string here.",
                    func = function ()
                        ACD:SelectGroup( "Hekili", "displays", "shareDisplays" )
                    end,
                    order = 998,
                },

                shareDisplays = {
                    type = "group",
                    name = "|cFF1EFF00Share Styles|r",
                    desc = "Your display options can be shared with other addon users with these export strings.\n\n" ..
                        "You can also import a shared export string here.",
                    childGroups = "tab",
                    get = 'GetDisplayShareOption',
                    set = 'SetDisplayShareOption',
                    order = 999,
                    args = {
                        import = {
                            type = "group",
                            name = "Import",
                            order = 1,
                            args = {
                                stage0 = {
                                    type = "group",
                                    name = "",
                                    inline = true,
                                    order = 1,
                                    args = {
                                        guide = {
                                            type = "description",
                                            name = "Select a saved Style or paste an import string in the box provided.",
                                            order = 1,
                                            width = "full",
                                            fontSize = "medium",
                                        },

                                        separator = {
                                            type = "header",
                                            name = "Import String",
                                            order = 1.5,
                                        },

                                        selectExisting = {
                                            type = "select",
                                            name = "Select a Saved Style",
                                            order = 2,
                                            width = "full",
                                            get = function()
                                                return "0000000000"
                                            end,
                                            set = function( info, val )
                                                local style = self.DB.global.styles[ val ]

                                                if style then shareDB.import = style.payload end
                                            end,
                                            values = function ()
                                                local db = self.DB.global.styles
                                                local values = {
                                                    ["0000000000"] = "Select a Saved Style"
                                                }

                                                for k, v in pairs( db ) do
                                                    values[ k ] = k .. " (|cFF00FF00" .. v.date .. "|r)"
                                                end

                                                return values
                                            end,
                                        },

                                        importString = {
                                            type = "input",
                                            name = "Import String",
                                            get = function () return shareDB.import end,
                                            set = function( info, val )
                                                val = val:trim()
                                                shareDB.import = val
                                            end,
                                            order = 3,
                                            multiline = 5,
                                            width = "full",
                                        },

                                        btnSeparator = {
                                            type = "header",
                                            name = "Import",
                                            order = 4,
                                        },

                                        importBtn = {
                                            type = "execute",
                                            name = "Import Style",
                                            order = 5,
                                            func = function ()
                                                shareDB.imported, shareDB.error = DeserializeStyle( shareDB.import )

                                                if shareDB.error then
                                                    shareDB.import = "The Import String provided could not be decompressed.\n" .. shareDB.error
                                                    shareDB.error = nil
                                                    shareDB.imported = {}
                                                else
                                                    shareDB.importStage = 1
                                                end
                                            end,
                                            disabled = function ()
                                                return shareDB.import == ""
                                            end,
                                        },
                                    },
                                    hidden = function () return shareDB.importStage ~= 0 end,
                                },

                                stage1 = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 1,
                                    args = {
                                        guide = {
                                            type = "description",
                                            name = function ()
                                                local creates, replaces = {}, {}

                                                for k, v in pairs( shareDB.imported ) do
                                                    if rawget( self.DB.profile.displays, k ) then
                                                        insert( replaces, k )
                                                    else
                                                        insert( creates, k )
                                                    end
                                                end

                                                local o = ""

                                                if #creates > 0 then
                                                    o = o .. "The imported style will create the following display(s):  "
                                                    for i, display in orderedPairs( creates ) do
                                                        if i == 1 then o = o .. display
                                                        else o = o .. ", " .. display end
                                                    end
                                                    o = o .. ".\n"
                                                end

                                                if #replaces > 0 then
                                                    o = o .. "The imported style will overwrite the following display(s):  "
                                                    for i, display in orderedPairs( replaces ) do
                                                        if i == 1 then o = o .. display
                                                        else o = o .. ", " .. display end
                                                    end
                                                    o = o .. "."
                                                end

                                                return o
                                            end,
                                            order = 1,
                                            width = "full",
                                            fontSize = "medium",
                                        },

                                        separator = {
                                            type = "header",
                                            name = "Apply Changes",
                                            order = 2,
                                        },

                                        apply = {
                                            type = "execute",
                                            name = "Apply Changes",
                                            order = 3,
                                            confirm = true,
                                            func = function ()
                                                for k, v in pairs( shareDB.imported ) do
                                                    if type( v ) == "table" then self.DB.profile.displays[ k ] = v end
                                                end

                                                shareDB.import = ""
                                                shareDB.imported = {}
                                                shareDB.importStage = 2

                                                self:EmbedDisplayOptions()
                                                QueueRebuildUI()
                                            end,
                                        },

                                        reset = {
                                            type = "execute",
                                            name = "Reset",
                                            order = 4,
                                            func = function ()
                                                shareDB.import = ""
                                                shareDB.imported = {}
                                                shareDB.importStage = 0
                                            end,
                                        },
                                    },
                                    hidden = function () return shareDB.importStage ~= 1 end,
                                },

                                stage2 = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 3,
                                    args = {
                                        note = {
                                            type = "description",
                                            name = "Imported settings were successfully applied!\n\nClick Reset to start over, if needed.",
                                            order = 1,
                                            fontSize = "medium",
                                            width = "full",
                                        },

                                        reset = {
                                            type = "execute",
                                            name = "Reset",
                                            order = 2,
                                            func = function ()
                                                shareDB.import = ""
                                                shareDB.imported = {}
                                                shareDB.importStage = 0
                                            end,
                                        }
                                    },
                                    hidden = function () return shareDB.importStage ~= 2 end,
                                }
                            },
                            plugins = {
                            }
                        },

                        export = {
                            type = "group",
                            name = "Export",
                            order = 2,
                            args = {
                                stage0 = {
                                    type = "group",
                                    name = "",
                                    inline = true,
                                    order = 1,
                                    args = {
                                        guide = {
                                            type = "description",
                                            name = "Select the display style settings to export, then click Export Styles to generate an export string.",
                                            order = 1,
                                            fontSize = "medium",
                                            width = "full",
                                        },

                                        displays = {
                                            type = "header",
                                            name = "Displays",
                                            order = 2,
                                        },

                                        exportHeader = {
                                            type = "header",
                                            name = "Export",
                                            order = 1000,
                                        },

                                        exportBtn = {
                                            type = "execute",
                                            name = "Export Style",
                                            order = 1001,
                                            func = function ()
                                                local disps = {}
                                                for key, share in pairs( shareDB.displays ) do
                                                    if share then insert( disps, key ) end
                                                end

                                                shareDB.export = SerializeStyle( unpack( disps ) )
                                                shareDB.exportStage = 1
                                            end,
                                            disabled = function ()
                                                local hasDisplay = false

                                                for key, value in pairs( shareDB.displays ) do
                                                    if value then hasDisplay = true; break end
                                                end

                                                return not hasDisplay
                                            end,
                                        },
                                    },
                                    plugins = {
                                        displays = {}
                                    },
                                    hidden = function ()
                                        local plugins = self.Options.args.displays.args.shareDisplays.args.export.args.stage0.plugins.displays
                                        wipe( plugins )

                                        local i = 1
                                        for dispName, display in pairs( self.DB.profile.displays ) do
                                            local pos = 20 + ( display.builtIn and display.order or i )
                                            plugins[ dispName ] = {
                                                type = "toggle",
                                                name = function ()
                                                    if display.builtIn then return "|cFF00B4FF" .. dispName .. "|r" end
                                                    return dispName
                                                end,
                                                order = pos,
                                                width = "full"
                                            }
                                            i = i + 1
                                        end

                                        return shareDB.exportStage ~= 0
                                    end,
                                },

                                stage1 = {
                                    type = "group",
                                    name = "",
                                    inline = true,
                                    order = 1,
                                    args = {
                                        exportString = {
                                            type = "input",
                                            name = "Style String",
                                            order = 1,
                                            multiline = 8,
                                            get = function () return shareDB.export end,
                                            set = function () end,
                                            width = "full",
                                            hidden = function () return shareDB.export == "" end,
                                        },

                                        instructions = {
                                            type = "description",
                                            name = "You can copy the above string to share your selected display style settings, or " ..
                                                "use the options below to store these settings (to be retrieved at a later date).",
                                            order = 2,
                                            width = "full",
                                            fontSize = "medium"
                                        },

                                        store = {
                                            type = "group",
                                            inline = true,
                                            name = "",
                                            order = 3,
                                            hidden = function () return shareDB.export == "" end,
                                            args = {
                                                separator = {
                                                    type = "header",
                                                    name = "Save Style",
                                                    order = 1,
                                                },

                                                exportName = {
                                                    type = "input",
                                                    name = "Style Name",
                                                    get = function () return shareDB.styleName end,
                                                    set = function( info, val )
                                                        val = val:trim()
                                                        shareDB.styleName = val
                                                    end,
                                                    order = 2,
                                                    width = "double",
                                                },

                                                storeStyle = {
                                                    type = "execute",
                                                    name = "Store Export String",
                                                    desc = "By storing your export string, you can save these display settings and retrieve them later if you make changes to your settings.\n\n" ..
                                                        "The stored style can be retrieved from any of your characters, even if you are using different profiles.",
                                                    order = 3,
                                                    confirm = function ()
                                                        if shareDB.styleName and self.DB.global.styles[ shareDB.styleName ] ~= nil then
                                                            return "There is already a style with the name '" .. shareDB.styleName .. "' -- overwrite it?"
                                                        end
                                                        return false
                                                    end,
                                                    func = function ()
                                                        local db = self.DB.global.styles
                                                        db[ shareDB.styleName ] = {
                                                            date = tonumber( date("%Y%m%d.%H%M%S") ),
                                                            payload = shareDB.export,
                                                        }
                                                        shareDB.styleName = ""
                                                    end,
                                                    disabled = function ()
                                                        return shareDB.export == "" or shareDB.styleName == ""
                                                    end,
                                                }
                                            }
                                        },


                                        restart = {
                                            type = "execute",
                                            name = "Restart",
                                            order = 4,
                                            func = function ()
                                                shareDB.styleName = ""
                                                shareDB.export = ""
                                                wipe( shareDB.displays )
                                                shareDB.exportStage = 0
                                            end,
                                        }
                                    },
                                    hidden = function () return shareDB.exportStage ~= 1 end
                                }
                            },
                            plugins = {
                                displays = {}
                            },
                        }
                    }
                },
            },
            plugins = {},
        }
        db.args.displays = section
        wipe( section.plugins )

        local i = 1

        for name, data in pairs( self.DB.profile.displays ) do
            local pos = data.builtIn and data.order or i
            section.plugins[ name ] = newDisplayOption( db, name, data, pos )
            if not data.builtIn then i = i + 1 end
        end

        section.plugins[ "Multi" ] = newDisplayOption( db, "Multi", self.DB.profile.displays[ "Primary" ], 0 )
        MakeMultiDisplayOption( section.plugins, section.plugins.Multi.Multi.args )
    end
end


do
    local impControl = {
        name = "",
        source = UnitName( "player" ) .. " @ " .. GetRealmName(),
        apl = "Paste your SimulationCraft action priority list or profile here.",

        lists = {},
        warnings = ""
    }

    Hekili.ImporterData = impControl


    local function AddWarning( s )
        if impControl.warnings then
            impControl.warnings = impControl.warnings .. s .. "\n"
            return
        end

        impControl.warnings = s .. "\n"
    end


    function Hekili:GetImporterOption( info )
        return impControl[ info[ #info ] ]
    end


    function Hekili:SetImporterOption( info, value )
        if type( value ) == 'string' then value = value:trim() end
        impControl[ info[ #info ] ] = value
        impControl.warnings = nil
    end


    function Hekili:ImportSimcAPL( name, source, apl, pack )

        name = name or impControl.name
        source = source or impControl.source
        apl = apl or impControl.apl

        impControl.warnings = ""

        local lists = {
            precombat = "",
            default = "",
        }

        local count = 0

        -- Rename the default action list to 'default'
        apl = "\n" .. apl
        apl = apl:gsub( "actions(%+?)=", "actions.default%1=" )

        local comment

        for line in apl:gmatch( "\n([^\n^$]*)") do
            local newComment = line:match( "^# (.+)" )
            if newComment then comment = newComment end

            local list, action = line:match( "^actions%.(%S-)%+?=/?([^\n^$]*)" )

            if list and action then
                lists[ list ] = lists[ list ] or ""

                --[[ if action:sub( 1, 6 ) == "potion" then
                    local potion = action:match( ",name=(.-),") or action:match( ",name=(.-)$" ) or class.potion or ""
                    action = action:gsub( potion, "\"" .. potion .. "\"" )
                end ]]

                if action:sub( 1, 16 ) == "call_action_list" or action:sub( 1, 15 ) == "run_action_list" then
                    local name = action:match( ",name=(.-)," ) or action:match( ",name=(.-)$" )
                    if name then action:gsub( ",name=" .. name, ",name=\"" .. name .. "\"" ) end
                end

                if comment then
                    action = action .. ',description=' .. comment:gsub( ",", ";" )
                    comment = nil
                end

                lists[ list ] = lists[ list ] .. "actions+=/" .. action .. "\n"
            end
        end

        if lists.precombat:len() == 0 then lists.precombat = "actions+=/heart_essence,enabled=0" end
        if lists.default  :len() == 0 then lists.default   = "actions+=/heart_essence,enabled=0" end

        local count = 0
        local output = {}

        for name, list in pairs( lists ) do
            local import, warnings = self:ParseActionList( list )

            if warnings then
                AddWarning( "The import for '" .. name .. "' required some automated changes." )

                for i, warning in ipairs( warnings ) do
                    AddWarning( warning )
                end

                AddWarning( "" )
            end

            if import then
                output[ name ] = import

                for i, entry in ipairs( import ) do
                    if entry.enabled == nil then entry.enabled = not ( entry.action == 'heroism' or entry.action == 'bloodlust' )
                    elseif entry.enabled == "0" then entry.enabled = false end
                end

                count = count + 1
            end
        end

        local use_items_found = false
        local trinket1_found = false
        local trinket2_found = false

        for _, list in pairs( output ) do
            for i, entry in ipairs( list ) do
                if entry.action == "use_items" then use_items_found = true end
                if entry.action == "trinket1" then trinket1_found = true end
                if entry.action == "trinket2" then trinket2_found = true end
            end
        end

        if not use_items_found and not ( trinket1_found and trinket2_found ) then
            AddWarning( "This profile is missing support for generic trinkets.  It is recommended that every priority includes either:\n" ..
                " - [Use Items], which includes any trinkets not explicitly included in the priority; or\n" ..
                " - [Trinket 1] and [Trinket 2], which will recommend the trinket for the numbered slot." )
        end

        if not output.default then output.default = {} end
        if not output.precombat then output.precombat = {} end

        if count == 0 then
            AddWarning( "No action lists were imported from this profile." )
        else
            AddWarning( "Imported " .. count .. " action lists." )
        end

        return output, impControl.warnings
    end
end


local snapshots = {
    snaps = {},
    empty = {},

    selected = 0
}


local config = {
    qsDisplay = 99999,

    qsShowTypeGroup = false,
    qsDisplayType = 99999,
    qsTargetsAOE = 3,

    displays = {}, -- auto-populated and recycled.
    displayTypes = {
        [1] = "Primary",
        [2] = "AOE",
        [3] = "Automatic",
        [99999] = " "
    },

    expanded = {
        cooldowns = true
    },
    adding = {},
}


local specs = {}
local activeSpec

local function GetCurrentSpec()
    activeSpec = activeSpec or GetSpecializationInfo( GetSpecialization() )
    return activeSpec
end

local function SetCurrentSpec( _, val )
    activeSpec = val
end

local function GetCurrentSpecList()
    return specs
end


do
    local packs = {}

    local specNameByID = {}
    local specIDByName = {}

    local shareDB = {
        actionPack = "",
        packName = "",
        export = "",

        import = "",
        imported = {},
        importStage = 0
    }


    function Hekili:GetPackShareOption( info )
        local n = #info
        local option = info[ n ]

        return shareDB[ option ]
    end


    function Hekili:SetPackShareOption( info, val, v2, v3, v4 )
        local n = #info
        local option = info[ n ]

        if type(val) == 'string' then val = val:trim() end

        shareDB[ option ] = val

        if option == "actionPack" and rawget( self.DB.profile.packs, shareDB.actionPack ) then
            shareDB.export = SerializeActionPack( shareDB.actionPack )
        else
            shareDB.export = ""
        end
    end


    function Hekili:SetSpecOption( info, val )
        local n = #info
        local spec, option = info[1], info[n]

        spec = specIDByName[ spec ]
        if not spec then return end

        if type( val ) == 'string' then val = val:trim() end

        self.DB.profile.specs[ spec ] = self.DB.profile.specs[ spec ] or {}
        self.DB.profile.specs[ spec ][ option ] = val

        if option == "package" then self:UpdateUseItems(); self:ForceUpdate( "SPEC_PACKAGE_CHANGED" )
        elseif option == "potion" and state.spec[ info[1] ] then class.potion = val
        elseif option == "enabled" then ns.StartConfiguration() end

        Hekili:UpdateDamageDetectionForCLEU()
    end


    function Hekili:GetSpecOption( info )
        local n = #info
        local spec, option = info[1], info[n]

        spec = specIDByName[ spec ]
        if not spec then return end

        self.DB.profile.specs[ spec ] = self.DB.profile.specs[ spec ] or {}

        if option == "potion" then
            local p = self.DB.profile.specs[ spec ].potion

            if not class.potionList[ p ] then
                return class.potions[ p ] and class.potions[ p ].key or p
            end
        end

        return self.DB.profile.specs[ spec ][ option ]
    end


    function Hekili:SetSpecPref( info, val )
    end

    function Hekili:GetSpecPref( info )
    end


    function Hekili:SetAbilityOption( info, val )
        local n = #info
        local ability, option = info[2], info[n]

        local spec = GetCurrentSpec()

        self.DB.profile.specs[ spec ].abilities[ ability ][ option ] = val
        if option == "toggle" then Hekili:EmbedAbilityOption( nil, ability ) end
    end

    function Hekili:GetAbilityOption( info )
        local n = #info
        local ability, option = info[2], info[n]

        local spec = GetCurrentSpec()

        return self.DB.profile.specs[ spec ].abilities[ ability ][ option ]
    end


    function Hekili:SetItemOption( info, val )
        local n = #info
        local item, option = info[2], info[n]

        local spec = GetCurrentSpec()

        self.DB.profile.specs[ spec ].items[ item ][ option ] = val
        if option == "toggle" then Hekili:EmbedItemOption( nil, item ) end
    end

    function Hekili:GetItemOption( info )
        local n = #info
        local item, option = info[2], info[n]

        local spec = GetCurrentSpec()

        return self.DB.profile.specs[ spec ].items[ item ][ option ]
    end


    function Hekili:EmbedAbilityOption( db, key )
        db = db or self.Options
        if not db or not key then return end

        local ability = class.abilities[ key ]
        if not ability then return end

        local toggles = {}

        local k = class.abilityList[ ability.key ]
        local v = ability.key

        if not k or not v then return end

        local useName = class.abilityList[ v ] and class.abilityList[v]:match("|t (.+)$") or ability.name

        if not useName then
            Hekili:Error( "No name available for %s (id:%d) in EmbedAbilityOption.", ability.key or "no_id", ability.id or 0 )
            useName = ability.key or ability.id or "???"
        end

        local option = db.args.abilities.plugins.actions[ v ] or {}

        option.type = "group"
        option.name = function () return useName .. ( state:IsDisabled( v, true ) and "|cFFFF0000*|r" or "" ) end
        option.order = 1
        option.set = "SetAbilityOption"
        option.get = "GetAbilityOption"
        option.args = {
            disabled = {
                type = "toggle",
                name = function () return "Disable " .. ( ability.item and ability.link or k ) end,
                desc = function () return "If checked, this ability will |cffff0000NEVER|r be recommended by the addon.  This can cause " ..
                    "issues for some specializations, if other abilities depend on you using " .. ( ability.item and ability.link or k ) .. "." end,
                width = 1.5,
                order = 1,
            },

            boss = {
                type = "toggle",
                name = "Boss Encounter Only",
                desc = "If checked, the addon will not recommend " .. k .. " unless you are in a boss fight (or encounter).  If left unchecked, " .. k .. " can be recommended in any type of fight.",
                width = 1.5,
                order = 1.1,
            },

            keybind = {
                type = "input",
                name = "Override Keybind Text",
                desc = "If specified, the addon will show this text in place of the auto-detected keybind text when recommending this ability.  " ..
                    "This can be helpful if the addon incorrectly detects your keybindings.",
                validate = function( info, val )
                    val = val:trim()
                    if val:len() > 20 then return "Keybindings should be no longer than 20 characters in length." end
                    return true
                end,
                width = 1.5,
                order = 2,
            },

            toggle = {
                type = "select",
                name = "Require Toggle",
                desc = "Specify a required toggle for this action to be used in the addon action list.  When toggled off, abilities are treated " ..
                    "as unusable and the addon will pretend they are on cooldown (unless specified otherwise).",
                width = 1.5,
                order = 3,
                values = function ()
                    table.wipe( toggles )

                    local t = class.abilities[ v ].toggle or "none"
                    if t == "essences" then t = "covenants" end

                    toggles.none = "None"
                    toggles.default = "Default |cffffd100(" .. t .. ")|r"
                    toggles.cooldowns = "Cooldowns"
                    toggles.essences = "Covenants"
                    toggles.defensives = "Defensives"
                    toggles.interrupts = "Interrupts"
                    toggles.potions = "Potions"
                    toggles.custom1 = "Custom 1"
                    toggles.custom2 = "Custom 2"

                    return toggles
                end,
            },

            targetMin = {
                type = "range",
                name = "Minimum Targets",
                desc = "If set above zero, the addon will only allow " .. k .. " to be recommended, if there are at least this many detected enemies.  All other action list conditions must also be met.\nSet to zero to ignore.",
                width = 1.5,
                min = 0,
                max = 15,
                step = 1,
                order = 3.1,
            },

            targetMax = {
                type = "range",
                name = "Maximum Targets",
                desc = "If set above zero, the addon will only allow " .. k .. " to be recommended if there are this many detected enemies (or fewer).  All other action list conditions must also be met.\nSet to zero to ignore.",
                width = 1.5,
                min = 0,
                max = 15,
                step = 1,
                order = 3.2,
            },

            clash = {
                type = "range",
                name = "Clash",
                desc = "If set above zero, the addon will pretend " .. k .. " has come off cooldown this much sooner than it actually has.  " ..
                    "This can be helpful when an ability is very high priority and you want the addon to prefer it over abilities that are available sooner.",
                width = 3,
                min = -1.5,
                max = 1.5,
                step = 0.05,
                order = 4,
            },
        }

        db.args.abilities.plugins.actions[ v ] = option
    end



    local testFrame = CreateFrame( "Frame" )
    testFrame.Texture = testFrame:CreateTexture()

    function Hekili:EmbedAbilityOptions( db )
        db = db or self.Options
        if not db then return end

        local abilities = {}
        local toggles = {}

        for k, v in pairs( class.abilityList ) do
            local a = class.abilities[ k ]
            if a and a.id and ( a.id > 0 or a.id < -100 ) and a.id ~= 61304 and not a.item then
                abilities[ v ] = k
            end
        end

        for k, v in orderedPairs( abilities ) do
            local ability = class.abilities[ v ]
            local useName = class.abilityList[ v ] and class.abilityList[v]:match("|t (.+)$") or ability.name

            if not useName then
                Hekili:Error( "No name available for %s (id:%d) in EmbedAbilityOptions.", ability.key or "no_id", ability.id or 0 )
                useName = ability.key or ability.id or "???"
            end

            local option = {
                type = "group",
                name = function () return useName .. ( state:IsDisabled( v, true ) and "|cFFFF0000*|r" or "" ) end,
                order = 1,
                set = "SetAbilityOption",
                get = "GetAbilityOption",
                args = {
                    disabled = {
                        type = "toggle",
                        name = function () return "Disable " .. ( ability.item and ability.link or k ) end,
                        desc = function () return "If checked, this ability will |cffff0000NEVER|r be recommended by the addon.  This can cause " ..
                            "issues for some specializations, if other abilities depend on you using " .. ( ability.item and ability.link or k ) .. "." end,
                        width = 1,
                        order = 1,
                    },

                    boss = {
                        type = "toggle",
                        name = "Boss Encounter Only",
                        desc = "If checked, the addon will not recommend " .. k .. " unless you are in a boss fight (or encounter).  If left unchecked, " .. k .. " can be recommended in any type of fight.",
                        width = 1,
                        order = 1.1,
                    },

                    toggle = {
                        type = "select",
                        name = "Require Toggle",
                        desc = "Specify a required toggle for this action to be used in the addon action list.  When toggled off, abilities are treated " ..
                            "as unusable and the addon will pretend they are on cooldown (unless specified otherwise).",
                        width = 1,
                        order = 1.2,
                        values = function ()
                            table.wipe( toggles )

                            local t = class.abilities[ v ].toggle or "none"
                            if t == "essences" then t = "covenants" end

                            toggles.none = "None"
                            toggles.default = "Default |cffffd100(" .. t .. ")|r"
                            toggles.cooldowns = "Cooldowns"
                            toggles.essences = "Covenants"
                            toggles.defensives = "Defensives"
                            toggles.interrupts = "Interrupts"
                            toggles.potions = "Potions"
                            toggles.custom1 = "Custom 1"
                            toggles.custom2 = "Custom 2"

                            return toggles
                        end,
                    },

                    lineBreak1 = {
                        type = "description",
                        name = " ",
                        width = "full",
                        order = 1.9
                    },

                    targetMin = {
                        type = "range",
                        name = "Minimum Targets",
                        desc = "If set above zero, the addon will only allow " .. k .. " to be recommended, if there are at least this many detected enemies.  All other action list conditions must also be met.\nSet to zero to ignore.",
                        width = 1,
                        min = 0,
                        max = 15,
                        step = 1,
                        order = 2,
                    },

                    targetMax = {
                        type = "range",
                        name = "Maximum Targets",
                        desc = "If set above zero, the addon will only allow " .. k .. " to be recommended if there are this many detected enemies (or fewer).  All other action list conditions must also be met.\nSet to zero to ignore.",
                        width = 1,
                        min = 0,
                        max = 15,
                        step = 1,
                        order = 2.1,
                    },

                    clash = {
                        type = "range",
                        name = "Clash",
                        desc = "If set above zero, the addon will pretend " .. k .. " has come off cooldown this much sooner than it actually has.  " ..
                            "This can be helpful when an ability is very high priority and you want the addon to prefer it over abilities that are available sooner.",
                        width = 1,
                        min = -1.5,
                        max = 1.5,
                        step = 0.05,
                        order = 2.2,
                    },

                    lineBreak2 = {
                        type = "description",
                        name = "",
                        width = "full",
                        order = 2.9,
                    },

                    keybind = {
                        type = "input",
                        name = "Keybind Text",
                        desc = "If specified, the addon will show this text in place of the auto-detected keybind text when recommending this ability.  " ..
                            "This can be helpful if the addon incorrectly detects your keybindings.",
                        validate = function( info, val )
                            val = val:trim()
                            if val:len() > 6 then return "Keybindings should be no longer than 6 characters in length." end
                            return true
                        end,
                        width = 1.5,
                        order = 3,
                    },

                    noIcon = {
                        type = "input",
                        name = "Icon Replacement",
                        desc = "If specified, the addon will attempt to load this texture instead of the default icon.  This can be a texture ID or a path to a texture file.\n\n" ..
                            "Leave blank and press Enter to reset to the default icon.",
                        icon = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return options and options[ v ] and options[ v ].icon or nil
                        end,
                        validate = function( info, val )
                            val = val:trim()
                            testFrame.Texture:SetTexture( "?" )
                            testFrame.Texture:SetTexture( val )
                            return testFrame.Texture:GetTexture() ~= "?"
                        end,
                        set = function( info, val )
                            val = val:trim()
                            if val:len() == 0 then val = nil end

                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            options[ v ].icon = val
                        end,
                        hidden = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return ( options and rawget( options, v ) and options[ v ].icon )
                        end,
                        width = 1.5,
                        order = 3.1,
                    },

                    hasIcon = {
                        type = "input",
                        name = "Icon Replacement",
                        desc = "If specified, the addon will attempt to load this texture instead of the default icon.  This can be a texture ID or a path to a texture file.\n\n" ..
                            "Leave blank and press Enter to reset to the default icon.",
                        icon = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return options and options[ v ] and options[ v ].icon or nil
                        end,
                        validate = function( info, val )
                            val = val:trim()
                            testFrame.Texture:SetTexture( "?" )
                            testFrame.Texture:SetTexture( val )
                            return testFrame.Texture:GetTexture() ~= "?"
                        end,
                        get = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return options and rawget( options, v ) and options[ v ].icon
                        end,
                        set = function( info, val )
                            val = val:trim()
                            if val:len() == 0 then val = nil end

                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            options[ v ].icon = val
                        end,
                        hidden = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return not ( options and rawget( options, v ) and options[ v ].icon )
                        end,
                        width = 1.3,
                        order = 3.2,
                    },

                    showIcon = {
                        type = 'description',
                        name = "",
                        image = function()
                            local options = Hekili:GetActiveSpecOption( "abilities" )
                            return options and rawget( options, v ) and options[ v ].icon
                        end,
                        width = 0.2,
                        order = 3.3,
                    }
                }
            }

            db.args.abilities.plugins.actions[ v ] = option
        end
    end


    function Hekili:EmbedItemOption( db, item )
        db = db or self.Options
        if not db then return end

        local ability = class.abilities[ item ]
        local toggles = {}

        local k = class.itemList[ ability.item ] or ability.name
        local v = ability.itemKey or ability.key

        if not item or not ability.item or not k then
            Hekili:Error( "Unable to find %s / %s / %s in the itemlist.", item or "unknown", ability.item or "unknown", k or "unknown" )
            return
        end

        local option = db.args.items.plugins.equipment[ v ] or {}

        option.type = "group"
        option.name = function () return ability.name .. ( state:IsDisabled( v, true ) and "|cFFFF0000*|r" or "" ) end
        option.order = 1
        option.set = "SetItemOption"
        option.get = "GetItemOption"
        option.args = {
            disabled = {
                type = "toggle",
                name = function () return "Disable " .. ( ability.item and ability.link or k ) end,
                desc = function () return "If checked, this ability will |cffff0000NEVER|r be recommended by the addon.  This can cause " ..
                    "issues for some specializations, if other abilities depend on you using " .. ( ability.item and ability.link or k ) .. "." end,
                width = 1.5,
                order = 1,
            },

            boss = {
                type = "toggle",
                name = "Boss Encounter Only",
                desc = "If checked, the addon will not recommend " .. k .. " via [Use Items] unless you are in a boss fight (or encounter).  If left unchecked, " .. k .. " can be recommended in any type of fight.",
                width = 1.5,
                order = 1.1,
            },

            keybind = {
                type = "input",
                name = "Override Keybind Text",
                desc = "If specified, the addon will show this text in place of the auto-detected keybind text when recommending this ability.  " ..
                    "This can be helpful if the addon incorrectly detects your keybindings.",
                validate = function( info, val )
                    val = val:trim()
                    if val:len() > 6 then return "Keybindings should be no longer than 6 characters in length." end
                    return true
                end,
                width = 1.5,
                order = 2,
            },

            toggle = {
                type = "select",
                name = "Require Toggle",
                desc = "Specify a required toggle for this action to be used in the addon action list.  When toggled off, abilities are treated " ..
                    "as unusable and the addon will pretend they are on cooldown (unless specified otherwise).",
                width = 1.5,
                order = 3,
                values = function ()
                    table.wipe( toggles )

                    toggles.none = "None"
                    toggles.default = "Default" .. ( class.abilities[ v ].toggle and ( " |cffffd100(" .. class.abilities[ v ].toggle .. ")|r" ) or " |cffffd100(none)|r" )
                    toggles.cooldowns = "Cooldowns"
                    toggles.essences = "Covenants"
                    toggles.defensives = "Defensives"
                    toggles.interrupts = "Interrupts"
                    toggles.potions = "Potions"
                    toggles.custom1 = "Custom 1"
                    toggles.custom2 = "Custom 2"

                    return toggles
                end,
            },

            --[[ clash = {
                type = "range",
                name = "Clash",
                desc = "If set above zero, the addon will pretend " .. k .. " has come off cooldown this much sooner than it actually has.  " ..
                    "This can be helpful when an ability is very high priority and you want the addon to prefer it over abilities that are available sooner.",
                width = "full",
                min = -1.5,
                max = 1.5,
                step = 0.05,
                order = 4,
            }, ]]

            targetMin = {
                type = "range",
                name = "Minimum Targets",
                desc = "If set above zero, the addon will only allow " .. k .. " to be recommended via [Use Items] if there are at least this many detected enemies.\nSet to zero to ignore.",
                width = 1.5,
                min = 0,
                max = 15,
                step = 1,
                order = 5,
            },

            targetMax = {
                type = "range",
                name = "Maximum Targets",
                desc = "If set above zero, the addon will only allow " .. k .. " to be recommended via [Use Items] if there are this many detected enemies (or fewer).\nSet to zero to ignore.",
                width = 1.5,
                min = 0,
                max = 15,
                step = 1,
                order = 6,
            },
        }

        db.args.items.plugins.equipment[ v ] = option
    end


    function Hekili:EmbedItemOptions( db )
        db = db or self.Options
        if not db then return end

        local abilities = {}
        local toggles = {}

        for k, v in pairs( class.abilities ) do
            if k == "potion" or v.item and not abilities[ v.itemKey or v.key ] then
                local name = class.itemList[ v.item ] or v.name
                if name then abilities[ name ] = v.itemKey or v.key end
            end
        end

        for k, v in orderedPairs( abilities ) do
            local ability = class.abilities[ v ]
            local option = {
                type = "group",
                name = function () return ability.name .. ( state:IsDisabled( v, true ) and "|cFFFF0000*|r" or "" ) end,
                order = 1,
                set = "SetItemOption",
                get = "GetItemOption",
                args = {
                    multiItem = {
                        type = "description",
                        name = function ()
                            return "These settings will apply to |cFF00FF00ALL|r of the " .. ability.name .. " PvP trinkets."
                        end,
                        fontSize = "medium",
                        width = "full",
                        order = 1,
                        hidden = function () return ability.key ~= "gladiators_badge" and ability.key ~= "gladiators_emblem" and ability.key ~= "gladiators_medallion" end,
                    },

                    disabled = {
                        type = "toggle",
                        name = function () return "Disable " .. ( ability.item and ability.link or k ) end,
                        desc = function () return "If checked, this ability will |cffff0000NEVER|r be recommended by the addon.  This can cause " ..
                            "issues for some specializations, if other abilities depend on you using " .. ( ability.item and ability.link or k ) .. "." end,
                        width = 1.5,
                        order = 1.05,
                    },

                    boss = {
                        type = "toggle",
                        name = "Boss Encounter Only",
                        desc = "If checked, the addon will not recommend " .. ( ability.item and ability.link or k ) .. " via [Use Items] unless you are in a boss fight (or encounter).  If left unchecked, " .. ( ability.item and ability.link or k ) .. " can be recommended in any type of fight.",
                        width = 1.5,
                        order = 1.1,
                    },

                    keybind = {
                        type = "input",
                        name = "Override Keybind Text",
                        desc = "If specified, the addon will show this text in place of the auto-detected keybind text when recommending this ability.  " ..
                            "This can be helpful if the addon incorrectly detects your keybindings.",
                        validate = function( info, val )
                            val = val:trim()
                            if val:len() > 6 then return "Keybindings should be no longer than 6 characters in length." end
                            return true
                        end,
                        width = 1.5,
                        order = 2,
                    },

                    toggle = {
                        type = "select",
                        name = "Require Toggle",
                        desc = "Specify a required toggle for this action to be used in the addon action list.  When toggled off, abilities are treated " ..
                            "as unusable and the addon will pretend they are on cooldown (unless specified otherwise).",
                        width = 1.5,
                        order = 3,
                        values = function ()
                            table.wipe( toggles )

                            toggles.none = "None"
                            toggles.default = "Default" .. ( class.abilities[ v ].toggle and ( " |cffffd100(" .. class.abilities[ v ].toggle .. ")|r" ) or " |cffffd100(none)|r" )
                            toggles.cooldowns = "Cooldowns"
                            toggles.essences = "Covenants"
                            toggles.defensives = "Defensives"
                            toggles.interrupts = "Interrupts"
                            toggles.potions = "Potions"
                            toggles.custom1 = "Custom 1"
                            toggles.custom2 = "Custom 2"

                            return toggles
                        end,
                    },

                    --[[ clash = {
                        type = "range",
                        name = "Clash",
                        desc = "If set above zero, the addon will pretend " .. k .. " has come off cooldown this much sooner than it actually has.  " ..
                            "This can be helpful when an ability is very high priority and you want the addon to prefer it over abilities that are available sooner.",
                        width = "full",
                        min = -1.5,
                        max = 1.5,
                        step = 0.05,
                        order = 4,
                    }, ]]

                    targetMin = {
                        type = "range",
                        name = "Minimum Targets",
                        desc = "If set above zero, the addon will only allow " .. ( ability.item and ability.link or k ) .. " to be recommended via [Use Items] if there are at least this many detected enemies.\nSet to zero to ignore.",
                        width = 1.5,
                        min = 0,
                        max = 15,
                        step = 1,
                        order = 5,
                    },

                    targetMax = {
                        type = "range",
                        name = "Maximum Targets",
                        desc = "If set above zero, the addon will only allow " .. ( ability.item and ability.link or k ) .. " to be recommended via [Use Items] if there are this many detected enemies (or fewer).\nSet to zero to ignore.",
                        width = 1.5,
                        min = 0,
                        max = 15,
                        step = 1,
                        order = 6,
                    },
                }
            }

            db.args.items.plugins.equipment[ v ] = option
        end

        self.NewItemInfo = false
    end


    local ToggleCount = {}
    local tAbilities = {}
    local tItems = {}


    local function BuildToggleList( options, specID, section, useName, description, extraOptions )
        local db = options.args.toggles.plugins[ section ]
        local e

        local function tlEntry( key )
            if db[ key ] then
                v.hidden = nil
                return db[ key ]
            end
            db[ key ] = {}
            return db[ key ]
        end

        if db then
            for k, v in pairs( db ) do
                v.hidden = true
            end
        else
            db = {}
        end

        local nToggles = ToggleCount[ specID ] or 0
        nToggles = nToggles + 1

        local hider = function()
            return not config.expanded[ section ]
        end

        local settings = Hekili.DB.profile.specs[ specID ]

        wipe( tAbilities )
        for k, v in pairs( class.abilityList ) do
            local a = class.abilities[ k ]
            if a and a.id and ( a.id > 0 or a.id < -100 ) and a.id ~= 61304 and not a.item then
                if settings.abilities[ k ].toggle == section or a.toggle == section and settings.abilities[ k ].toggle == 'default' then
                    tAbilities[ k ] = class.abilityList[ k ] or v
                end
            end
        end

        e = tlEntry( section .. "Spacer" )
        e.type = "description"
        e.name = ""
        e.order = nToggles
        e.width = "full"

        e = tlEntry( section .. "Expander" )
        e.type = "execute"
        e.name = ""
        e.order = nToggles + 0.01
        e.width = 0.15
        e.image = function ()
            if not config.expanded[ section ] then return "Interface\\AddOns\\Hekili\\Textures\\WhiteRight" end
            return "Interface\\AddOns\\Hekili\\Textures\\WhiteDown"
        end
        e.imageWidth = 20
        e.imageHeight = 20
        e.func = function( info )
            config.expanded[ section ] = not config.expanded[ section ]
        end

        if type( useName ) == "function" then
            useName = useName()
        end

        e = tlEntry( section .. "Label" )
        e.type = "description"
        e.name = useName or section
        e.order = nToggles + 0.02
        e.width = 2.85
        e.fontSize = "large"

        if description then
            e = tlEntry( section .. "Description" )
            e.type = "description"
            e.name = description
            e.order = nToggles + 0.05
            e.width = "full"
            e.hidden = hider
        else
            if db[ section .. "Description" ] then db[ section .. "Description" ].hidden = true end
        end

        local count, offset = 0, 0

        for ability, isMember in orderedPairs( tAbilities ) do
            if isMember then
                if count % 2 == 0 then
                    e = tlEntry( section .. "LB" .. count )
                    e.type = "description"
                    e.name = ""
                    e.order = nToggles + 0.1 + offset
                    e.width = "full"
                    e.hidden = hider

                    offset = offset + 0.001
                end

                e = tlEntry( section .. "Remove" .. ability )
                e.type = "execute"
                e.name = ""
                e.desc = function ()
                    local a = class.abilities[ ability ]
                    local desc
                    if a then
                        if a.item then desc = a.link or a.name
                        else desc = class.abilityList[ a.key ] or a.name end
                    end
                    desc = desc or ability

                    return "Remove " .. desc .. " from " .. ( useName or section ) .. " toggle."
                end
                e.image = RedX
                e.imageHeight = 16
                e.imageWidth = 16
                e.order = nToggles + 0.1 + offset
                e.width = 0.15
                e.func = function ()
                    settings.abilities[ ability ].toggle = 'none'
                    -- e.hidden = true
                    Hekili:EmbedSpecOptions()
                end
                e.hidden = hider

                offset = offset + 0.001


                e = tlEntry( section .. ability .. "Name" )
                e.type = "description"
                e.name = function ()
                    local a = class.abilities[ ability ]
                    if a then
                        if a.item then return a.link or a.name end
                        return class.abilityList[ a.key ] or a.name
                    end
                    return ability
                end
                e.order = nToggles + 0.1 + offset
                e.fontSize = "medium"
                e.width = 1.35
                e.hidden = hider

                offset = offset + 0.001

                --[[ e = tlEntry( section .. "Toggle" .. ability )
                e.type = "toggle"
                e.icon = RedX
                e.name = function ()
                    local a = class.abilities[ ability ]
                    if a then
                        if a.item then return a.link or a.name end
                        return a.name
                    end
                    return ability
                end
                e.desc = "Remove this from " .. ( useName or section ) .. "?"
                e.order = nToggles + 0.1 + offset
                e.width = 1.5
                e.hidden = hider
                e.get = function() return true end
                e.set = function()
                    settings.abilities[ ability ].toggle = 'none'
                    Hekili:EmbedSpecOptions()
                end

                offset = offset + 0.001 ]]

                count = count + 1
            end
        end


        e = tlEntry( section .. "FinalLB" )
        e.type = "description"
        e.name = ""
        e.order = nToggles + 0.993
        e.width = "full"
        e.hidden = hider

        e = tlEntry( section .. "AddBtn" )
        e.type = "execute"
        e.name = ""
        e.image = "Interface\\AddOns\\Hekili\\Textures\\GreenPlus"
        e.imageHeight = 16
        e.imageWidth = 16
        e.order = nToggles + 0.995
        e.width = 0.15
        e.func = function ()
            config.adding[ section ]  = true
        end
        e.hidden = hider


        e = tlEntry( section .. "AddText" )
        e.type = "description"
        e.name = "Add Ability"
        e.fontSize = "medium"
        e.width = 1.35
        e.order = nToggles + 0.996
        e.hidden = function ()
            return hider() or config.adding[ section ]
        end


        e = tlEntry( section .. "Add" )
        e.type = "select"
        e.name = ""
        e.values = function()
            local list = {}

            for k, v in pairs( class.abilityList ) do
                local a = class.abilities[ k ]
                if a and ( a.id > 0 or a.id < -100 ) and a.id ~= 61304 and not a.item then
                    if settings.abilities[ k ].toggle == 'default' or settings.abilities[ k ].toggle == 'none' then
                        list[ k ] = class.abilityList[ k ] or v
                    end
                end
            end

            return list
        end
        e.sorting = function()
            local list = {}

            for k, v in pairs( class.abilityList ) do
                insert( list, {
                    k, class.abilities[ k ].name or v or k
                } )
            end

            sort( list, function( a, b ) return a[2] < b[2] end )

            for i = 1, #list do
                list[ i ] = list[ i ][ 1 ]
            end

            return list
        end
        e.order = nToggles + 0.997
        e.width = 1.35
        e.get = function () end
        e.set = function ( info, val )
            local a = class.abilities[ val ]
            if a then
                settings[ a.item and "items" or "abilities" ][ val ].toggle = section
                config.adding[ section ] = false
                Hekili:EmbedSpecOptions()
            end
        end
        e.hidden = function ()
            return hider() or not config.adding[ section ]
        end


        e = tlEntry( section .. "Reload" )
        e.type = "execute"
        e.name = ""
        e.order = nToggles + 0.998
        e.width = 0.15
        e.image = GetAtlasFile( "transmog-icon-revert" )
        e.imageCoords = GetAtlasCoords( "transmog-icon-revert" )
        e.imageWidth = 16
        e.imageHeight = 16
        e.func = function ()
            for k, v in pairs( settings.abilities ) do
                local a = class.abilities[ k ]
                if a and not a.item and v.toggle == section or ( class.abilities[ k ].toggle == section ) then v.toggle = 'default' end
            end
            for k, v in pairs( settings.items ) do
                local a = class.abilities[ k ]
                if a and a.item and v.toggle == section or ( class.abilities[ k ].toggle == section ) then v.toggle = 'default' end
            end
            Hekili:EmbedSpecOptions()
        end
        e.hidden = hider


        e = tlEntry( section .. "ReloadText" )
        e.type = "description"
        e.name = "Reload Defaults"
        e.fontSize = "medium"
        e.order = nToggles + 0.999
        e.width = 1.35
        e.hidden = hider


        if extraOptions then
            for k, v in pairs( extraOptions ) do
                e = tlEntry( section .. k )
                e.type = v.type or "description"
                e.name = v.name or ""
                e.desc = v.desc or ""
                e.order = v.order or ( nToggles + 1 )
                e.width = v.width or 1.35
                e.hidden = v.hidden or hider
                e.get = v.get
                e.set = v.set
                for opt, val in pairs( v ) do
                    if e[ opt ] == nil then
                        e[ opt ] = val
                    end
                end
            end
        end

        ToggleCount[ specID ] = nToggles
        options.args.toggles.plugins[ section ] = db
    end


    -- Options table constructors.
    function Hekili:EmbedSpecOptions( db )
        db = db or self.Options
        if not db then return end

        local i = 1

        while( true ) do
            local id, name, description, texture, role = GetSpecializationInfo( i )

            if not id then break end
            if description then description = description:match( "^(.-)\n" ) end

            local spec = class.specs[ id ]

            if spec then
                local sName = lower( name )
                specNameByID[ id ] = sName
                specIDByName[ sName ] = id

                specs[ id ] = '|T' .. texture .. ':0|t ' .. name

                local options = {
                    type = "group",
                    -- name = specs[ id ],
                    name = name,
                    icon = texture,
                    -- iconCoords = { 0.1, 0.9, 0.1, 0.9 },
                    desc = description,
                    order = 50 + i,
                    childGroups = "tab",
                    get = "GetSpecOption",
                    set = "SetSpecOption",

                    args = {
                        core = {
                            type = "group",
                            name = "Core",
                            desc = "Core features and specialization options for " .. specs[ id ] .. ".",
                            order = 1,
                            args = {
                                enabled = {
                                    type = "toggle",
                                    name = "Enabled",
                                    desc = "If checked, the addon will provide priority recommendations for " .. name .. " based on the selected priority list.",
                                    order = 0,
                                    width = "full",
                                },


                                --[[ packInfo = {
                                    type = 'group',
                                    name = "",
                                    inline = true,
                                    order = 1,
                                    args = {

                                    }
                                }, ]]

                                package = {
                                    type = "select",
                                    name = "Priority",
                                    desc = "The addon will use the selected package when making its priority recommendations.",
                                    order = 1,
                                    width = 2.85,
                                    values = function( info, val )
                                        wipe( packs )

                                        for key, pkg in pairs( self.DB.profile.packs ) do
                                            local pname = pkg.builtIn and "|cFF00B4FF" .. key .. "|r" or key
                                            if pkg.spec == id then
                                                packs[ key ] = '|T' .. texture .. ':0|t ' .. pname
                                            end
                                        end

                                        packs[ '(none)' ] = '(none)'

                                        return packs
                                    end,
                                },

                                openPackage = {
                                    type = 'execute',
                                    name = "",
                                    desc = "Open and view this priority pack and its action lists.",
                                    image = GetAtlasFile( "communities-icon-searchmagnifyingglass" ),
                                    imageCoords = GetAtlasCoords( "communities-icon-searchmagnifyingglass" ),
                                    imageHeight = 24,
                                    imageWidth = 24,
                                    disabled = function( info, val )
                                        local pack = self.DB.profile.specs[ id ].package
                                        return rawget( self.DB.profile.packs, pack ) == nil
                                    end,
                                    func = function ()
                                        ACD:SelectGroup( "Hekili", "packs", self.DB.profile.specs[ id ].package )
                                    end,
                                    order = 1.1,
                                    width = 0.15,
                                },

                                blankLine1 = {
                                    type = 'description',
                                    name = '',
                                    order = 1.2,
                                    width = 'full'
                                },

                                potion = {
                                    type = "select",
                                    name = "Default Potion",
                                    desc = "When recommending a potion, the addon will suggest this potion unless the action list specifies otherwise.",
                                    order = 2,
                                    width = 3,
                                    values = function ()
                                        local v = {}

                                        for k, p in pairs( class.potionList ) do
                                            if k ~= "default" then v[ k ] = p end
                                        end

                                        return v
                                    end,
                                },

                                blankLine2 = {
                                    type = 'description',
                                    name = '',
                                    order = 2.1,
                                    width = 'full'
                                }

                            },
                            plugins = {
                                settings = {}
                            },
                        },

                        targets = {
                            type = "group",
                            name = "Targeting",
                            desc = "Settings related to how enemies are identified and counted by the addon.",
                            order = 3,
                            args = {
                                -- Nameplate Quasi-Group
                                nameplates = {
                                    type = "toggle",
                                    name = "Use Nameplate Detection",
                                    desc = "If checked, the addon will count any enemies with visible nameplates within a small radius of your character.  " ..
                                        "This is typically desirable for |cFFFF0000melee|r specializations.",
                                    width = "full",
                                    order = 1,
                                },

                                nameplateRange = {
                                    type = "range",
                                    name = "Nameplate Detection Range",
                                    desc = "When |cFFFFD100Use Nameplate Detection|r is checked, the addon will count any enemies with visible nameplates within this radius of your character.",
                                    width = "full",
                                    hidden = function()
                                        return self.DB.profile.specs[ id ].nameplates == false
                                    end,
                                    min = 0,
                                    max = 100,
                                    step = 1,
                                    order = 2,
                                },

                                nameplateSpace = {
                                    type = "description",
                                    name = " ",
                                    width = "full",
                                    hidden = function()
                                        return self.DB.profile.specs[ id ].nameplates == false
                                    end,
                                    order = 3,
                                },


                                -- Pet-Based Cluster Detection
                                petbased = {
                                    type = "toggle",
                                    name = "Use Pet-Based Detection",
                                    desc = function ()
                                        local msg = "If checked and properly configured, the addon will count targets near your pet as valid targets, when your target is also within range of your pet."

                                        if Hekili:HasPetBasedTargetSpell() then
                                            local spell = Hekili:GetPetBasedTargetSpell()
                                            local name, _, tex = GetSpellInfo( spell )

                                            msg = msg .. "\n\n|T" .. tex .. ":0|t |cFFFFD100" .. name .. "|r is on your action bar and will be used for all your " .. UnitClass("player") .. " pets."
                                        else
                                            msg = msg .. "\n\n|cFFFF0000Requires pet ability on one of your action bars.|r"
                                        end

                                        if GetCVar( "nameplateShowEnemies" ) == "1" then
                                            msg = msg .. "\n\nEnemy nameplates are |cFF00FF00enabled|r and will be used to detect targets near your pet."
                                        else
                                            msg = msg .. "\n\n|cFFFF0000Requires enemy nameplates.|r"
                                        end

                                        return msg
                                    end,
                                    width = "full",
                                    hidden = function ()
                                        return Hekili:GetPetBasedTargetSpells() == nil
                                    end,
                                    order = 3.1
                                },

                                petbasedGuidance = {
                                    type = "description",
                                    name = function ()
                                        local out

                                        if not self:HasPetBasedTargetSpell() then
                                            out = "For pet-based detection to work, you must take an ability from your |cFF00FF00pet's spellbook|r and place it on one of |cFF00FF00your|r action bars.\n\n"
                                            local spells = Hekili:GetPetBasedTargetSpells()

                                            if not spells then return " " end

                                            out = out .. "For %s, |T%d:0|t |cFFFFD100%s|r is recommended due to its range.  It will work for all your pets."

                                            if spells.count > 1 then
                                                out = out .. "\nAlternative(s): "
                                            end

                                            local n = 1

                                            local name, _, tex = GetSpellInfo( spells.best )
                                            out = format( out, UnitClass( "player" ), tex, name )
                                            for spell in pairs( spells ) do
                                                if type( spell ) == "number" and spell ~= spells.best then
                                                    n = n + 1

                                                    name, _, tex = GetSpellInfo( spell )

                                                    if n == 2 and spells.count == 2 then
                                                        out = out .. "|T" .. tex .. ":0|t |cFFFFD100" .. name .. "|r."
                                                    elseif n ~= spells.count then
                                                        out = out .. "|T" .. tex .. ":0|t |cFFFFD100" .. name .. "|r, "
                                                    else
                                                        out = out .. "and |T" .. tex .. ":0|t |cFFFFD100" .. name .. "|r."
                                                    end
                                                end
                                            end
                                        end

                                        if GetCVar( "nameplateShowEnemies" ) ~= "1" then
                                            if not out then
                                                out = "|cFFFF0000WARNING!|r  Pet-based target detection requires |cFFFFD100enemy nameplates|r to be enabled."
                                            else
                                                out = out .. "\n\n|cFFFF0000WARNING!|r  Pet-based target detection requires |cFFFFD100enemy nameplates|r to be enabled."
                                            end
                                        end

                                        return out
                                    end,
                                    fontSize = "medium",
                                    width = "full",
                                    hidden = function ( info, val )
                                        if Hekili:GetPetBasedTargetSpells() == nil then return true end
                                        if self.DB.profile.specs[ id ].petbased == false then return true end
                                        if self:HasPetBasedTargetSpell() and GetCVar( "nameplateShowEnemies" ) == "1" then return true end

                                        return false
                                    end,
                                    order = 3.11,
                                },

                                -- Damage Detection Quasi-Group
                                damage = {
                                    type = "toggle",
                                    name = "Detect Damaged Enemies",
                                    desc = "If checked, the addon will count any enemies that you've hit (or hit you) within the past several seconds as active enemies.  " ..
                                        "This is typically desirable for |cFFFF0000ranged|r specializations.",
                                    width = "full",
                                    order = 4,
                                },

                                damageDots = {
                                    type = "toggle",
                                    name = "Detect Dotted Enemies",
                                    desc = "When checked, the addon will continue to count enemies who are taking damage from your damage over time effects (bleeds, etc.), even if they are not nearby or taking other damage from you.\n\n" ..
                                        "This may not be ideal for melee specializations, as enemies may wander away after you've applied your dots/bleeds.  If used with |cFFFFD100Use Nameplate Detection|r, dotted enemies that are no longer in melee range will be filtered.\n\n" ..
                                        "For ranged specializations with damage over time effects, this should be enabled.",
                                    width = 1.49,
                                    hidden = function () return self.DB.profile.specs[ id ].damage == false end,
                                    order = 5,
                                },

                                damagePets = {
                                    type = "toggle",
                                    name = "Detect Enemies Damaged by Pets",
                                    desc = "If checked, the addon will count enemies that your pets or minions have hit (or hit you) within the past several seconds.  " ..
                                        "This may give misleading target counts if your pet/minions are spread out over the battlefield.",
                                    width = 1.49,
                                    hidden = function () return self.DB.profile.specs[ id ].damage == false end,
                                    order = 5.1
                                },

                                damageOnScreen = {
                                    type = "toggle",
                                    name = NewFeature .. "On Screen Enemies Only",
                                    desc = function()
                                        return "If checked, the damage-based target system will only count enemies that are on screen.  If unchecked, offscreen targets can be included in target counts.\n\n"
                                            .. ( GetCVar( "nameplateShowEnemies" ) == "0" and "|cFFFF0000Requires Enemy Nameplates|r" or "|cFF00FF00Requires Enemy Nameplates|r" )
                                    end,
                                    width = 1.49,
                                    hidden = function () return self.DB.profile.specs[ id ].damage == false end,
                                    order = 5.15,
                                },

                                damageRange = {
                                    type = "range",
                                    name = "Filter Damaged Enemies by Range",
                                    desc = "If set above 0, the addon will attempt to avoid counting targets that were out of range when last seen.  This is based on cached data and may be inaccurate.",
                                    width = 1.49,
                                    hidden = function () return self.DB.profile.specs[ id ].damage == false end,
                                    min = 0,
                                    max = 100,
                                    step = 1,
                                    order = 5.2,
                                },

                                damageExpiration = {
                                    type = "range",
                                    name = "Damage Detection Timeout",
                                    desc = "When |cFFFFD100Detect Damaged Enemies|r is checked, the addon will remember enemies until they have been ignored/undamaged for this amount of time.  " ..
                                        "Enemies will also be forgotten if they die or despawn.  This is helpful when enemies spread out or move out of range.",
                                    width = "full",
                                    softMin = 3,
                                    min = 1,
                                    max = 10,
                                    step = 0.1,
                                    hidden = function() return self.DB.profile.specs[ id ].damage == false end,
                                    order = 5.3,
                                },

                                damageSpace = {
                                    type = "description",
                                    name = " ",
                                    width = "full",
                                    hidden = function() return self.DB.profile.specs[ id ].damage == false end,
                                    order = 7,
                                },

                                cycle = {
                                    type = "toggle",
                                    name = "Recommend Target Swaps",
                                    desc = "When target swapping is enabled, the addon may show an icon (|TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t) when you should use an ability on a different target.  " ..
                                        "This works well for some specs that simply want to apply a debuff to another target (like Windwalker), but can be less-effective for specializations that are concerned with " ..
                                        "maintaining dots/debuffs based on their durations (like Affliction).  This feature is targeted for improvement in a future update.",
                                    width = "full",
                                    order = 8
                                },

                                cycle_min = {
                                    type = "range",
                                    name = "Minimum Target Time-to-Die",
                                    desc = "When |cffffd100Recommend Target Swaps|r is checked, this value determines which targets are counted for target swapping purposes.  If set to 5, the addon will " ..
                                            "not recommend swapping to a target that will die in fewer than 5 seconds.  This can be beneficial to avoid applying damage-over-time effects to a target that will die " ..
                                            "too quickly to be damaged by them.\n\nSet to 0 to count all detected targets.",
                                    width = "full",
                                    min = 0,
                                    max = 15,
                                    step = 1,
                                    hidden = function() return not self.DB.profile.specs[ id ].cycle end,
                                    order = 9
                                },

                                aoe = {
                                    type = "range",
                                    name = "AOE Display:  Minimum Targets",
                                    desc = "When the AOE Display is shown, its recommendations will be made assuming this many targets are available.",
                                    width = "full",
                                    min = 2,
                                    max = 10,
                                    step = 1,
                                    order = 10,
                                },
                            }
                        },

                        toggles = {
                            type = "group",
                            name = "Toggles",
                            desc = "Specify which abilities are controlled by each toggle keybind for this specialization.",
                            order = 2,
                            args = {
                                toggleDesc = {
                                    type = "description",
                                    name = "This section shows which Abilities are enabled/disabled when you toggle each category when in this specialization.  Gear and Items can be adjusted via their own section (left).\n\n" ..
                                        "Removing an ability from its toggle leaves it |cFF00FF00ENABLED|r regardless of whether the toggle is active.",
                                    fontSize = "medium",
                                    order = 1,
                                    width = "full",
                                },
                            },
                            plugins = {
                                cooldowns = {},
                                essences = {},
                                defensives = {},
                                utility = {},
                                custom1 = {},
                                custom2 = {},
                            }
                        },

                        performance = {
                            type = "group",
                            name = "Performance",
                            order = 10,
                            args = {
                                throttleRefresh = {
                                    type = "toggle",
                                    name = "Throttle Updates",
                                    desc = "By default, the addon will update its recommendations immediately following |cffff0000critical|r combat events, within |cffffd1000.1|rs of routine combat events, or every |cffffd1000.5|rs.\n" ..
                                        "If |cffffd100Throttle Updates|r is checked, you can specify the |cffffd100Combat Refresh Interval|r and |cff00ff00Regular Refresh Interval|r for this specialization.",
                                    order = 1,
                                    width = "full",
                                },

                                perfSpace01 = {
                                    type = "description",
                                    name = " ",
                                    order = 1.05,
                                    width = "full"
                                },

                                regularRefresh = {
                                    type = "range",
                                    name = "Regular Refresh Interval",
                                    desc = "In the absence of combat events, this addon will allow itself to update according to the specified interval.  Specifying a higher value may reduce CPU usage but will result in slower updates, though " ..
                                        "combat events will always force the addon to update more quickly.\n\nIf set to |cffffd1001.0|rs, the addon will not provide new updates until 1 second after its last update (unless forced by a combat event).\n\n" ..
                                        "Default value:  |cffffd1000.5|rs.",
                                    order = 1.1,
                                    width = 1.5,
                                    min = 0.05,
                                    max = 1,
                                    step = 0.05,
                                    hidden = function () return self.DB.profile.specs[ id ].throttleRefresh == false end,
                                },

                                combatRefresh = {
                                    type = "range",
                                    name = "Combat Refresh Interval",
                                    desc = "When routine combat events occur, the addon will update more frequently than its Regular Refresh Interval.  Specifying a higher value may reduce CPU usage but will result in slower updates, though " ..
                                        "critical combat events will always force the addon to update more quickly.\n\nIf set to |cffffd1000.2|rs, the addon will not provide new updates until 0.2 seconds after its last update (unless forced by a critical combat event).\n\n" ..
                                        "Default value:  |cffffd1000.1|rs.",
                                    order = 1.2,
                                    width = 1.5,
                                    min = 0.05,
                                    max = 0.5,
                                    step = 0.05,
                                    hidden = function () return self.DB.profile.specs[ id ].throttleRefresh == false end,
                                },

                                perfSpace = {
                                    type = "description",
                                    name = " ",
                                    order = 1.9,
                                    width = "full"
                                },

                                throttleTime = {
                                    type = "toggle",
                                    name = "Throttle Time",
                                    desc = "By default, when the addon needs to generate new recommendations, it will use up to |cffffd10010ms|r per frame or up to half a frame, whichever is lower.  If you get 60 FPS, that is 1 second / 60 frames, which equals equals 16.67ms.  " ..
                                        "Half of 16.67 is ~|cffffd1008ms|r, so the addon could use up to ~8ms per frame until it has successfully updated its recommendations for all visible displays.  If more time is needed, the work will be split across multiple frames.\n\n" ..
                                        "If you choose to |cffffd100Throttle Time|r, you can specify the |cffffd100Maximum Update Time|r the addon should use per frame.",
                                    order = 2,
                                    width = 1,
                                },

                                maxTime = {
                                    type = "range",
                                    name = "Maximum Update Time (ms)",
                                    desc = "Specify the maximum amount of time (in milliseconds) that the addon can use |cffffd100per frame|r when updating its recommendations.\n\n" ..
                                        "If set to |cffffd10010|r, then recommendations should not impact a 100 FPS system (1 second / 100 frames = 10ms).\n" ..
                                        "If set to |cffffd10016|r, then recommendations should not impact a 60 FPS system (1 second / 60 frames = 16.7ms).\n\n" ..
                                        "If you set this value too low, the addon can take more frames to update its recommendations and may feel delayed.  " ..
                                        "If set too high, the addon will do more work each frame, finishing faster but potentially impacting your FPS.  The default value is |cffffd10010ms|r.",
                                    order = 2.1,
                                    min = 2,
                                    max = 100,
                                    width = 2,
                                    hidden = function () return self.DB.profile.specs[ id ].throttleTime == false end,
                                },

                                throttleSpace = {
                                    type = "description",
                                    name = " ",
                                    order = 3,
                                    width = "full",
                                    hidden = function () return self.DB.profile.specs[ id ].throttleRefresh == false end,
                                },

                                --[[ gcdSync = {
                                    type = "toggle",
                                    name = "Start after Global Cooldown",
                                    desc = "If checked, the addon's first recommendation will be delayed to the start of the GCD in your Primary and AOE displays.  This can reduce flickering if trinkets or off-GCD abilities are appearing briefly during the global cooldown, " ..
                                        "but will cause abilities intended to be used while the GCD is active (i.e., Recklessness) to bounce backward in the queue.",
                                    width = "full",
                                    order = 4,
                                }, ]]

                                enhancedRecheck = {
                                    type = "toggle",
                                    name = "Enhanced Recheck",
                                    desc = "When the addon cannot recommend an ability at the present time, it rechecks action's conditions at a few points in the future.  If checked, this feature will enable the addon to do additional checking on entries that use the 'variable' feature.  " ..
                                        "This may use slightly more CPU, but can reduce the likelihood that the addon will fail to make a recommendation.",
                                    width = "full",
                                    order = 5,
                                }

                            }
                        }
                    },
                }

                local specCfg = class.specs[ id ] and class.specs[ id ].settings
                local specProf = self.DB.profile.specs[ id ]

                if #specCfg > 0 then
                    options.args.core.plugins.settings.prefSpacer = {
                        type = "description",
                        name = " ",
                        order = 100,
                        width = "full"
                    }

                    options.args.core.plugins.settings.prefHeader = {
                        type = "header",
                        name = "Preferences",
                        order = 100.1,
                    }

                    for i, option in ipairs( specCfg ) do
                        if i > 1 and i % 2 == 1 then
                            -- Insert line break.
                            options.args.core.plugins.settings[ sName .. "LB" .. i ] = {
                                type = "description",
                                name = "",
                                width = "full",
                                order = option.info.order - 0.01
                            }
                        end

                        options.args.core.plugins.settings[ option.name ] = option.info
                        if self.DB.profile.specs[ id ].settings[ option.name ] == nil then
                            self.DB.profile.specs[ id ].settings[ option.name ] = option.default
                        end
                    end
                end

                -- Toggles
                BuildToggleList( options, id, "cooldowns",  "Cooldowns", nil, {
                        -- Test Option for Separate Cooldowns
                        noFeignedCooldown = {
                            type = "toggle",
                            name = "Cooldown: Show Separately - Use Actual Cooldowns",
                            desc = "If checked, when using the Cooldown: Show Separately feature and Cooldowns are enabled, the addon will |cFFFF0000NOT|r pretend your " ..
                                "cooldown abilities are fully on cooldown.  This may help resolve scenarios where abilities become desynchronized due to behavior differences " ..
                                "between the Cooldowns display and your other displays.\n\n" ..
                                "See |cFFFFD100Toggles|r > |cFFFFD100Cooldowns|r for the |cFFFFD100Cooldown: Show Separately|r feature.",
                            order = 1.051,
                            width = "full",
                            disabled = function ()
                                return not self.DB.profile.toggles.cooldowns.separate
                            end,
                            set = function()
                                self.DB.profile.specs[ id ].noFeignedCooldown = not self.DB.profile.specs[ id ].noFeignedCooldown
                            end,
                            get = function()
                                return self.DB.profile.specs[ id ].noFeignedCooldown
                            end,
                        }
                 } )
                BuildToggleList( options, id, "essences",   "Covenants" )
                BuildToggleList( options, id, "interrupts", "Utility / Interrupts" )
                BuildToggleList( options, id, "defensives", "Defensives",   "The defensive toggle is generally intended for tanking specializations, " ..
                                                                            "as you may want to turn on/off recommendations for damage mitigation abilities " ..
                                                                            "for any number of reasons during a fight.  DPS players may want to add their own " ..
                                                                            "defensive abilities, but would also need to add the abilities to their own custom " ..
                                                                            "priority packs." )
                BuildToggleList( options, id, "custom1", function ()
                    return specProf.custom1Name or "Custom 1"
                end )
                BuildToggleList( options, id, "custom2", function ()
                    return specProf.custom2Name or "Custom 2"
                end )

                db.plugins.specializations[ sName ] = options
            end

            i = i + 1
        end

    end


    local packControl = {
        listName = "default",
        actionID = "0001",

        makingNew = false,
        newListName = nil,

        showModifiers = false,

        newPackName = "",
        newPackSpec = "",
    }


    local nameMap = {
        call_action_list = "list_name",
        run_action_list = "list_name",
        potion = "potion",
        variable = "var_name",
        op = "op"
    }


    local defaultNames = {
        list_name = "default",
        potion = "prolonged_power",
        var_name = "unnamed_var",
    }


    local toggleToNumber = {
        cycle_targets = true,
        for_next = true,
        max_energy = true,
        strict = true,
        use_off_gcd = true,
        use_while_casting = true,
    }


    local function GetListEntry( pack )
        local entry = rawget( Hekili.DB.profile.packs, pack )

        if rawget( entry.lists, packControl.listName ) == nil then
            packControl.listName = "default"
        end

        if entry then entry = entry.lists[ packControl.listName ] else return end

        if rawget( entry, tonumber( packControl.actionID ) ) == nil then
            packControl.actionID = "0001"
        end

        local listPos = tonumber( packControl.actionID )
        if entry and listPos > 0 then entry = entry[ listPos ] else return end

        return entry
    end


    function Hekili:GetActionOption( info )
        local n = #info
        local pack, option = info[ 2 ], info[ n ]

        if rawget( self.DB.profile.packs[ pack ].lists, packControl.listName ) == nil then
            packControl.listName = "default"
        end

        local actionID = tonumber( packControl.actionID )
        local data = self.DB.profile.packs[ pack ].lists[ packControl.listName ]

        if option == 'position' then return actionID
        elseif option == 'newListName' then return packControl.newListName end

        if not data then return end

        if not data[ actionID ] then
            actionID = 1
            packControl.actionID = "0001"
        end
        data = data[ actionID ]

        if option == "inputName" or option == "selectName" then
            option = nameMap[ data.action ]
            if not data[ option ] then data[ option ] = defaultNames[ option ] end
        end

        if option == "op" and not data.op then return "set" end

        if option == "potion" then
            if not data.potion then return "default" end
            if not class.potionList[ data.potion ] then
                return class.potions[ data.potion ] and class.potions[ data.potion ].key or data.potion
            end
        end

        if toggleToNumber[ option ] then return data[ option ] == 1 end
        return data[ option ]
    end


    function Hekili:SetActionOption( info, val )
        local n = #info
        local pack, option = info[ 2 ], info[ n ]

        local actionID = tonumber( packControl.actionID )
        local data = self.DB.profile.packs[ pack ].lists[ packControl.listName ]

        if option == 'newListName' then
            packControl.newListName = val:trim()
            return
        end

        if not data then return end
        data = data[ actionID ]

        if option == "inputName" or option == "selectName" then option = nameMap[ data.action ] end

        if toggleToNumber[ option ] then val = val and 1 or 0 end
        if type( val ) == 'string' then val = val:trim() end

        data[ option ] = val

        if option == "enable_moving" and not val then
            data.moving = nil
        end

        if option == "line_cd" and not val then
            data.line_cd = nil
        end

        if option == "use_off_gcd" and not val then
            data.use_off_gcd = nil
        end

        if option == "strict" and not val then
            data.strict = nil
        end

        if option == "use_while_casting" and not val then
            data.use_while_casting = nil
        end

        if option == "action" then
            self:LoadScripts()
        else
            self:LoadScript( pack, packControl.listName, actionID )
        end

        if option == "enabled" then
            Hekili:UpdateDisplayVisibility()
        end
    end


    function Hekili:GetPackOption( info )
        local n = #info
        local category, subcat, option = info[ 2 ], info[ 3 ], info[ n ]

        if rawget( self.DB.profile.packs, category ) and rawget( self.DB.profile.packs[ category ].lists, packControl.listName ) == nil then
            packControl.listName = "default"
        end

        if option == "newPackSpec" and packControl[ option ] == "" then
            packControl[ option ] = GetCurrentSpec()
        end

        if packControl[ option ] ~= nil then return packControl[ option ] end

        if subcat == 'lists' then return self:GetActionOption( info ) end

        local data = rawget( self.DB.profile.packs, category )
        if not data then return end

        if option == 'date' then return tostring( data.date ) end

        return data[ option ]
    end


    function Hekili:SetPackOption( info, val )
        local n = #info
        local category, subcat, option = info[ 2 ], info[ 3 ], info[ n ]

        if packControl[ option ] ~= nil then
            packControl[ option ] = val
            if option == "listName" then packControl.actionID = "0001" end
            return
        end

        if subcat == 'lists' then return self:SetActionOption( info, val ) end
        -- if subcat == 'newActionGroup' or ( subcat == 'actionGroup' and subtype == 'entry' ) then self:SetActionOption( info, val ); return end

        local data = rawget( self.DB.profile.packs, category )
        if not data then return end

        if type( val ) == 'string' then val = val:trim() end

        if option == "desc" then
            -- Auto-strip comments prefix
            val = val:gsub( "^#+ ", "" )
            val = val:gsub( "\n#+ ", "\n" )
        end

        data[ option ] = val
    end


    function Hekili:EmbedPackOptions( db )
        db = db or self.Options
        if not db then return end

        local packs = db.args.packs or {
            type = "group",
            name = "Priorities",
            desc = "Priorities (or action packs) are bundles of action lists used to make recommendations for each specialization.",
            get = 'GetPackOption',
            set = 'SetPackOption',
            order = 65,
            childGroups = 'tree',
            args = {
                packDesc = {
                    type = "description",
                    name = "Priorities (or action packs) are bundles of action lists used to make recommendations for each specialization.  " ..
                        "They can be customized and shared.  |cFFFF0000Imported SimulationCraft priorities often require some translation before " ..
                        "they will work with this addon.  No support is offered for customized or imported priorities.|r",
                    order = 1,
                    fontSize = "medium",
                },

                newPackHeader = {
                    type = "header",
                    name = "Create a New Priority",
                    order = 200
                },

                newPackName = {
                    type = "input",
                    name = "Priority Name",
                    desc = "Enter a new, unique name for this package.  Only alphanumeric characters, spaces, underscores, and apostrophes are allowed.",
                    order = 201,
                    width = "full",
                    validate = function( info, val )
                        val = val:trim()
                        if rawget( Hekili.DB.profile.packs, val ) then return "Please specify a unique pack name."
                        elseif val == "UseItems" then return "UseItems is a reserved name."
                        elseif val == "(none)" then return "Don't get smart, missy."
                        elseif val:find( "[^a-zA-Z0-9 _']" ) then return "Only alphanumeric characters, spaces, underscores, and apostrophes are allowed in pack names." end
                        return true
                    end,
                },

                newPackSpec = {
                    type = "select",
                    name = "Specialization",
                    order = 202,
                    width = "full",
                    values = specs,
                },

                createNewPack = {
                    type = "execute",
                    name = "Create New Pack",
                    order = 203,
                    disabled = function()
                        return packControl.newPackName == "" or packControl.newPackSpec == ""
                    end,
                    func = function ()
                        Hekili.DB.profile.packs[ packControl.newPackName ].spec = packControl.newPackSpec
                        Hekili:EmbedPackOptions()
                        ACD:SelectGroup( "Hekili", "packs", packControl.newPackName )
                        packControl.newPackName = ""
                        packControl.newPackSpec = ""
                    end,
                },

                shareHeader = {
                    type = "header",
                    name = "Sharing",
                    order = 100,
                },

                shareBtn = {
                    type = "execute",
                    name = "Share Priorities",
                    desc = "Each Priority can be shared with other addon users with these export strings.\n\n" ..
                        "You can also import a shared export string here.",
                    func = function ()
                        ACD:SelectGroup( "Hekili", "packs", "sharePacks" )
                    end,
                    order = 101,
                },

                sharePacks = {
                    type = "group",
                    name = "|cFF1EFF00Share Priorities|r",
                    desc = "Your Priorities can be shared with other addon users with these export strings.\n\n" ..
                        "You can also import a shared export string here.",
                    childGroups = "tab",
                    get = 'GetPackShareOption',
                    set = 'SetPackShareOption',
                    order = 1001,
                    args = {
                        import = {
                            type = "group",
                            name = "Import",
                            order = 1,
                            args = {
                                stage0 = {
                                    type = "group",
                                    name = "",
                                    inline = true,
                                    order = 1,
                                    args = {
                                        guide = {
                                            type = "description",
                                            name = "Paste a Priority import string here to begin.",
                                            order = 1,
                                            width = "full",
                                            fontSize = "medium",
                                        },

                                        separator = {
                                            type = "header",
                                            name = "Import String",
                                            order = 1.5,
                                        },

                                        importString = {
                                            type = "input",
                                            name = "Import String",
                                            get = function () return shareDB.import end,
                                            set = function( info, val )
                                                val = val:trim()
                                                shareDB.import = val
                                            end,
                                            order = 3,
                                            multiline = 5,
                                            width = "full",
                                        },

                                        btnSeparator = {
                                            type = "header",
                                            name = "Import",
                                            order = 4,
                                        },

                                        importBtn = {
                                            type = "execute",
                                            name = "Import Priority",
                                            order = 5,
                                            func = function ()
                                                shareDB.imported, shareDB.error = DeserializeActionPack( shareDB.import )

                                                if shareDB.error then
                                                    shareDB.import = "The Import String provided could not be decompressed.\n" .. shareDB.error
                                                    shareDB.error = nil
                                                    shareDB.imported = {}
                                                else
                                                    shareDB.importStage = 1
                                                end
                                            end,
                                            disabled = function ()
                                                return shareDB.import == ""
                                            end,
                                        },
                                    },
                                    hidden = function () return shareDB.importStage ~= 0 end,
                                },

                                stage1 = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 1,
                                    args = {
                                        packName = {
                                            type = "input",
                                            order = 1,
                                            name = "Pack Name",
                                            get = function () return shareDB.imported.name end,
                                            set = function ( info, val ) shareDB.imported.name = val:trim() end,
                                            width = "full",
                                        },

                                        packDate = {
                                            type = "input",
                                            order = 2,
                                            name = "Pack Date",
                                            get = function () return tostring( shareDB.imported.date ) end,
                                            set = function () end,
                                            width = "full",
                                            disabled = true,
                                        },

                                        packSpec = {
                                            type = "input",
                                            order = 3,
                                            name = "Pack Specialization",
                                            get = function () return select( 2, GetSpecializationInfoByID( shareDB.imported.payload.spec or 0 ) ) or "No Specialization Set" end,
                                            set = function () end,
                                            width = "full",
                                            disabled = true,
                                        },

                                        guide = {
                                            type = "description",
                                            name = function ()
                                                local listNames = {}

                                                for k, v in pairs( shareDB.imported.payload.lists ) do
                                                    insert( listNames, k )
                                                end

                                                table.sort( listNames )

                                                local o

                                                if #listNames == 0 then
                                                    o = "The imported Priority has no lists included."
                                                elseif #listNames == 1 then
                                                    o = "The imported Priority has one action list:  " .. listNames[1] .. "."
                                                elseif #listNames == 2 then
                                                    o = "The imported Priority has two action lists:  " .. listNames[1] .. " and " .. listNames[2] .. "."
                                                else
                                                    o = "The imported Priority has the following lists included:  "
                                                    for i, name in ipairs( listNames ) do
                                                        if i == 1 then o = o .. name
                                                        elseif i == #listNames then o = o .. ", and " .. name .. "."
                                                        else o = o .. ", " .. name end
                                                    end
                                                end

                                                return o
                                            end,
                                            order = 4,
                                            width = "full",
                                            fontSize = "medium",
                                        },

                                        separator = {
                                            type = "header",
                                            name = "Apply Changes",
                                            order = 10,
                                        },

                                        apply = {
                                            type = "execute",
                                            name = "Apply Changes",
                                            order = 11,
                                            confirm = function ()
                                                if rawget( self.DB.profile.packs, shareDB.imported.name ) then
                                                    return "You already have a \"" .. shareDB.imported.name .. "\" Priority.\nOverwrite it?"
                                                end
                                                return "Create a new Priority named \"" .. shareDB.imported.name .. "\" from the imported data?"
                                            end,
                                            func = function ()
                                                self.DB.profile.packs[ shareDB.imported.name ] = shareDB.imported.payload
                                                shareDB.imported.payload.date = shareDB.imported.date
                                                shareDB.imported.payload.version = shareDB.imported.date

                                                shareDB.import = ""
                                                shareDB.imported = {}
                                                shareDB.importStage = 2

                                                self:LoadScripts()
                                                self:EmbedPackOptions()
                                            end,
                                        },

                                        reset = {
                                            type = "execute",
                                            name = "Reset",
                                            order = 12,
                                            func = function ()
                                                shareDB.import = ""
                                                shareDB.imported = {}
                                                shareDB.importStage = 0
                                            end,
                                        },
                                    },
                                    hidden = function () return shareDB.importStage ~= 1 end,
                                },

                                stage2 = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 3,
                                    args = {
                                        note = {
                                            type = "description",
                                            name = "Imported settings were successfully applied!\n\nClick Reset to start over, if needed.",
                                            order = 1,
                                            fontSize = "medium",
                                            width = "full",
                                        },

                                        reset = {
                                            type = "execute",
                                            name = "Reset",
                                            order = 2,
                                            func = function ()
                                                shareDB.import = ""
                                                shareDB.imported = {}
                                                shareDB.importStage = 0
                                            end,
                                        }
                                    },
                                    hidden = function () return shareDB.importStage ~= 2 end,
                                }
                            },
                            plugins = {
                            }
                        },

                        export = {
                            type = "group",
                            name = "Export",
                            order = 2,
                            args = {
                                guide = {
                                    type = "description",
                                    name = "Select a Priority pack to export.",
                                    order = 1,
                                    fontSize = "medium",
                                    width = "full",
                                },

                                actionPack = {
                                    type = "select",
                                    name = "Priorities",
                                    order = 2,
                                    values = function ()
                                        local v = {}

                                        for k, pack in pairs( Hekili.DB.profile.packs ) do
                                            if pack.spec and class.specs[ pack.spec ] then
                                                v[ k ] = k
                                            end
                                        end

                                        return v
                                    end,
                                    width = "full"
                                },

                                exportString = {
                                    type = "input",
                                    name = "Priority Export String\n|cFFFFFFFFPress CTRL+A to select, then CTRL+C to copy.|r",
                                    order = 3,
                                    get = function ()
                                        if rawget( Hekili.DB.profile.packs, shareDB.actionPack ) then
                                            shareDB.export = SerializeActionPack( shareDB.actionPack )
                                        else
                                            shareDB.export = ""
                                        end
                                        return shareDB.export
                                    end,
                                    set = function () end,
                                    width = "full",
                                    hidden = function () return shareDB.export == "" end,
                                },
                            },
                        }
                    }
                },
            },
            plugins = {
                packages = {},
                links = {},
            }
        }

        wipe( packs.plugins.packages )
        wipe( packs.plugins.links )

        local count = 0

        for pack, data in orderedPairs( self.DB.profile.packs ) do
            if data.spec and class.specs[ data.spec ] and not data.hidden then
                packs.plugins.links.packButtons = packs.plugins.links.packButtons or {
                    type = "header",
                    name = "Installed Packs",
                    order = 10,
                }

                packs.plugins.links[ "btn" .. pack ] = {
                    type = "execute",
                    name = pack,
                    order = 11 + count,
                    func = function ()
                        ACD:SelectGroup( "Hekili", "packs", pack )
                    end,
                }

                local opts = packs.plugins.packages[ pack ] or {
                    type = "group",
                    name = function ()
                        local p = rawget( Hekili.DB.profile.packs, pack )
                        if p.builtIn then return '|cFF00B4FF' .. pack .. '|r' end
                        return pack
                    end,
                    icon = function()
                        return class.specs[ data.spec ].texture
                    end,
                    childGroups = "tab",
                    order = 100 + count,
                    args = {
                        pack = {
                            type = "group",
                            name = data.builtIn and ( BlizzBlue .. "Summary|r" ) or "Summary",
                            order = 1,
                            args = {
                                isBuiltIn = {
                                    type = "description",
                                    name = function ()
                                        return BlizzBlue .. "This is a default priority package.  It will be automatically updated when the addon is updated.  If you want to customize this priority, " ..
                                            "make a copy by clicking |TInterface\\Addons\\Hekili\\Textures\\WhiteCopy:0|t.|r"
                                    end,
                                    fontSize = "medium",
                                    width = 3,
                                    order = 0.1,
                                    hidden = not data.builtIn
                                },

                                lb01 = {
                                    type = "description",
                                    name = "",
                                    order = 0.11,
                                    hidden = not data.builtIn
                                },

                                toggleActive = {
                                    type = "toggle",
                                    name = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        if p and p.builtIn then return BlizzBlue .. "Active|r" end
                                        return "Active"
                                    end,
                                    desc = "If checked, the addon's recommendations for this specialization are based on this priority package.",
                                    order = 0.2,
                                    width = 3,
                                    get = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return Hekili.DB.profile.specs[ p.spec ].package == pack
                                    end,
                                    set = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        if Hekili.DB.profile.specs[ p.spec ].package == pack then
                                            if p.builtIn then
                                                Hekili.DB.profile.specs[ p.spec ].package = "(none)"
                                            else
                                                for def, data in pairs( Hekili.DB.profile.packs ) do
                                                    if data.spec == p.spec and data.builtIn then
                                                        Hekili.DB.profile.specs[ p.spec ].package = def
                                                        return
                                                    end
                                                end
                                            end
                                        else
                                            Hekili.DB.profile.specs[ p.spec ].package = pack
                                        end
                                    end,
                                },

                                lb04 = {
                                    type = "description",
                                    name = "",
                                    order = 0.21,
                                    width = "full"
                                },

                                packName = {
                                    type = "input",
                                    name = "Priority Name",
                                    order = 0.25,
                                    width = 2.7,
                                    validate = function( info, val )
                                        val = val:trim()
                                        if rawget( Hekili.DB.profile.packs, val ) then return "Please specify a unique pack name."
                                        elseif val == "UseItems" then return "UseItems is a reserved name."
                                        elseif val == "(none)" then return "Don't get smart, missy."
                                        elseif val:find( "[^a-zA-Z0-9 _'()]" ) then return "Only alphanumeric characters, spaces, parentheses, underscores, and apostrophes are allowed in pack names." end
                                        return true
                                    end,
                                    get = function() return pack end,
                                    set = function( info, val )
                                        local profile = Hekili.DB.profile

                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        Hekili.DB.profile.packs[ pack ] = nil

                                        val = val:trim()
                                        Hekili.DB.profile.packs[ val ] = p

                                        for _, spec in pairs( Hekili.DB.profile.specs ) do
                                            if spec.package == pack then spec.package = val end
                                        end

                                        Hekili:EmbedPackOptions()
                                        Hekili:LoadScripts()
                                        ACD:SelectGroup( "Hekili", "packs", val )
                                    end,
                                    disabled = data.builtIn
                                },

                                copyPack = {
                                    type = "execute",
                                    name = "",
                                    desc = "Copy Priority",
                                    order = 0.26,
                                    width = 0.15,
                                    image = [[Interface\AddOns\Hekili\Textures\WhiteCopy]],
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    confirm = function () return "Create a copy of this priority pack?" end,
                                    func = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                        local newPack = tableCopy( p )
                                        newPack.builtIn = false
                                        newPack.basedOn = pack

                                        local newPackName, num = pack:match("^(.+) %((%d+)%)$")

                                        if not num then
                                            newPackName = pack
                                            num = 1
                                        end

                                        num = num + 1
                                        while( rawget( Hekili.DB.profile.packs, newPackName .. " (" .. num .. ")" ) ) do
                                            num = num + 1
                                        end
                                        newPackName = newPackName .. " (" .. num ..")"

                                        Hekili.DB.profile.packs[ newPackName ] = newPack
                                        Hekili:EmbedPackOptions()
                                        Hekili:LoadScripts()
                                        ACD:SelectGroup( "Hekili", "packs", newPackName )
                                    end
                                },

                                reloadPack = {
                                    type = "execute",
                                    name = "",
                                    desc = "Reload Priority",
                                    order = 0.27,
                                    width = 0.15,
                                    image = GetAtlasFile( "transmog-icon-revert" ),
                                    imageCoords = GetAtlasCoords( "transmog-icon-revert" ),
                                    imageWidth = 25,
                                    imageHeight = 24,
                                    confirm = function ()
                                        return "Reload this priority pack from defaults?"
                                    end,
                                    hidden = not data.builtIn,
                                    func = function ()
                                        Hekili.DB.profile.packs[ pack ] = nil
                                        Hekili:RestoreDefault( pack )
                                        Hekili:EmbedPackOptions()
                                        Hekili:LoadScripts()
                                        ACD:SelectGroup( "Hekili", "packs", pack )
                                    end
                                },

                                deletePack = {
                                    type = "execute",
                                    name = "",
                                    desc = "Delete Priority",
                                    order = 0.27,
                                    width = 0.15,
                                    image = GetAtlasFile( "communities-icon-redx" ),
                                    imageCoords = GetAtlasCoords( "communities-icon-redx" ),
                                    imageHeight = 24,
                                    imageWidth = 24,
                                    confirm = function () return "Delete this priority package?" end,
                                    func = function ()
                                        local defPack

                                        local specId = data.spec
                                        local spec = specId and Hekili.DB.profile.specs[ specId ]

                                        if specId then
                                            for pId, pData in pairs( Hekili.DB.profile.packs ) do
                                                if pData.builtIn and pData.spec == specId then
                                                    defPack = pId
                                                    if spec.package == pack then spec.package = pId; break end
                                                end
                                            end
                                        end

                                        Hekili.DB.profile.packs[ pack ] = nil
                                        Hekili.Options.args.packs.plugins.packages[ pack ] = nil

                                        -- Hekili:EmbedPackOptions()
                                        ACD:SelectGroup( "Hekili", "packs" )
                                    end,
                                    hidden = data.builtIn
                                },

                                lb02 = {
                                    type = "description",
                                    name = "",
                                    order = 0.3,
                                    width = "full",
                                },

                                spec = {
                                    type = "select",
                                    name = "Specialization",
                                    order = 1,
                                    width = 3,
                                    values = specs,
                                    disabled = data.builtIn and not Hekili.Version:sub(1, 3) == "Dev"
                                },

                                lb03 = {
                                    type = "description",
                                    name = "",
                                    order = 1.01,
                                    width = "full",
                                    hidden = data.builtIn
                                },

                                --[[ applyPack = {
                                    type = "execute",
                                    name = "Use Priority",
                                    order = 1.5,
                                    width = 1,
                                    func = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        Hekili.DB.profile.specs[ p.spec ].package = pack
                                    end,
                                    hidden = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return Hekili.DB.profile.specs[ p.spec ].package == pack
                                    end,
                                }, ]]

                                desc = {
                                    type = "input",
                                    name = "Description",
                                    multiline = 15,
                                    order = 2,
                                    width = "full",
                                },
                            }
                        },

                        profile = {
                            type = "group",
                            name = "Profile",
                            desc = "If this Priority was generated with a SimulationCraft profile, the profile can be stored " ..
                                "or retrieved here.  The profile can also be re-imported or overwritten with a newer profile.",
                            order = 2,
                            args = {
                                signature = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 3,
                                    args = {
                                        source = {
                                            type = "input",
                                            name = "Source",
                                            desc = "If the Priority is based on a SimulationCraft profile or a popular guide, it is a " ..
                                                "good idea to provide a link to the source (especially before sharing).",
                                            order = 1,
                                            width = 3,
                                        },

                                        break1 = {
                                            type = "description",
                                            name = "",
                                            width = "full",
                                            order = 1.1,
                                        },

                                        author = {
                                            type = "input",
                                            name = "Author",
                                            desc = "The author field is automatically filled out when creating a new Priority.  " ..
                                                "You can update it here.",
                                            order = 2,
                                            width = 2,
                                        },

                                        date = {
                                            type = "input",
                                            name = "Last Updated",
                                            desc = "This date is automatically updated when any changes are made to the action lists for this Priority.",
                                            width = 1,
                                            order = 3,
                                            set = function () end,
                                            get = function ()
                                                local d = data.date or 0

                                                if type(d) == "string" then return d end
                                                return format( "%.4f", d )
                                            end,
                                        },
                                    },
                                },

                                profile = {
                                    type = "input",
                                    name = "Profile",
                                    desc = "If this pack's action lists were imported from a SimulationCraft profile, the profile is included here.",
                                    order = 4,
                                    multiline = 20,
                                    width = "full",
                                },

                                warnings = {
                                    type = "input",
                                    name = "Import Log",
                                    order = 5,
                                    -- fontSize = "medium",
                                    width = "full",
                                    multiline = 20,
                                    hidden = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return not p.warnings or p.warnings == ""
                                    end,
                                },

                                reimport = {
                                    type = "execute",
                                    name = "Import",
                                    desc = "Rebuild the action list(s) from the profile above.",
                                    order = 5,
                                    func = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        local profile = p.profile:gsub( '"', '' )

                                        local result, warnings = Hekili:ImportSimcAPL( nil, nil, profile )

                                        wipe( p.lists )

                                        for k, v in pairs( result ) do
                                            p.lists[ k ] = v
                                        end

                                        p.warnings = warnings
                                        p.date = tonumber( date("%Y%m%d.%H%M%S") )

                                        if not p.lists[ packControl.listName ] then packControl.listName = "default" end

                                        local id = tonumber( packControl.actionID )
                                        if not p.lists[ packControl.listName ][ id ] then packControl.actionID = "zzzzzzzzzz" end

                                        self:LoadScripts()
                                    end,
                                },
                            }
                        },

                        lists = {
                            type = "group",
                            childGroups = "select",
                            name = "Action Lists",
                            desc = "Action Lists are used to determine which abilities should be used at what time.",
                            order = 3,
                            args = {
                                listName = {
                                    type = "select",
                                    name = "Action List",
                                    desc = "Select the action list to view or modify.",
                                    order = 1,
                                    width = 2.7,
                                    values = function ()
                                        local v = {
                                            -- ["zzzzzzzzzz"] = "|cFF00FF00Add New Action List|r"
                                        }

                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                        for k in pairs( p.lists ) do
                                            local err = false

                                            if Hekili.Scripts and Hekili.Scripts.DB then
                                                local scriptHead = "^" .. pack .. ":" .. k .. ":"
                                                for k, v in pairs( Hekili.Scripts.DB ) do
                                                    if k:match( scriptHead ) and v.Error then err = true; break end
                                                end
                                            end

                                            if err then
                                                v[ k ] = "|cFFFF0000" .. k .. "|r"
                                            elseif k == 'precombat' or k == 'default' then
                                                v[ k ] = "|cFF00B4FF" .. k .. "|r"
                                            else
                                                v[ k ] = k
                                            end
                                        end

                                        return v
                                    end,
                                },

                                newListBtn = {
                                    type = "execute",
                                    name = "",
                                    desc = "Create a New Action List",
                                    order = 1.1,
                                    width = 0.15,
                                    image = "Interface\\AddOns\\Hekili\\Textures\\GreenPlus",
                                    -- image = GetAtlasFile( "communities-icon-addgroupplus" ),
                                    -- imageCoords = GetAtlasCoords( "communities-icon-addgroupplus" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    func = function ()
                                        packControl.makingNew = true
                                    end,
                                },

                                delListBtn = {
                                    type = "execute",
                                    name = "",
                                    desc = "Delete this Action List",
                                    order = 1.2,
                                    width = 0.15,
                                    image = RedX,
                                    -- image = GetAtlasFile( "communities-icon-redx" ),
                                    -- imageCoords = GetAtlasCoords( "communities-icon-redx" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    confirm = function() return "Delete this action list?" end,
                                    disabled = function () return packControl.listName == "default" or packControl.listName == "precombat" end,
                                    func = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        p.lists[ packControl.listName ] = nil
                                        Hekili:LoadScripts()
                                        packControl.listName = "default"
                                    end,
                                },

                                lineBreak = {
                                    type = "description",
                                    name = "",
                                    width = "full",
                                    order = 1.9
                                },

                                actionID = {
                                    type = "select",
                                    name = "Entry",
                                    desc = "Select the entry to modify in this action list.\n\n" ..
                                        "Entries in red are disabled, have no action set, have a conditional error, or use actions that are disabled/toggled off.",
                                    order = 2,
                                    width = 2.4,
                                    values = function ()
                                        local v = {}

                                        local data = rawget( Hekili.DB.profile.packs, pack )
                                        local list = rawget( data.lists, packControl.listName )

                                        if list then
                                            local last = 0

                                            for i, entry in ipairs( list ) do
                                                local key = format( "%04d", i )
                                                local action = entry.action
                                                local desc

                                                local warning, color = false

                                                if not action then
                                                    action = "Unassigned"
                                                    warning = true
                                                else
                                                    if not class.abilities[ action ] then warning = true
                                                    else
                                                        if state:IsDisabled( action, true ) then warning = true end
                                                        action = class.abilityList[ action ] and class.abilityList[ action ]:match( "|t (.+)$" ) or class.abilities[ action ] and class.abilities[ action ].name or action
                                                    end
                                                end

                                                local scriptID = pack .. ":" .. packControl.listName .. ":" .. i
                                                local script = Hekili.Scripts.DB[ scriptID ]

                                                if script and script.Error then warning = true end

                                                local cLen = entry.criteria and entry.criteria:len()

                                                if entry.caption and entry.caption:len() > 0 then
                                                    desc = entry.caption

                                                elseif entry.action == "variable" then
                                                    if entry.op == "reset" then
                                                        desc = format( "reset |cff00ccff%s|r", entry.var_name or "unassigned" )
                                                    elseif entry.op == "default" then
                                                        desc = format( "|cff00ccff%s|r default = |cffffd100%s|r", entry.var_name or "unassigned", entry.value or "0" )
                                                    elseif entry.op == "set" or entry.op == "setif" then
                                                        desc = format( "set |cff00ccff%s|r = |cffffd100%s|r", entry.var_name or "unassigned", entry.value or "nothing" )
                                                    else
                                                        desc = format( "%s |cff00ccff%s|r (|cffffd100%s|r)", entry.op or "set", entry.var_name or "unassigned", entry.value or "nothing" )
                                                    end

                                                    if cLen and cLen > 0 then
                                                        desc = format( "%s, if |cffffd100%s|r", desc, entry.criteria )
                                                    end

                                                elseif entry.action == "call_action_list" or entry.action == "run_action_list" then
                                                    if not entry.list_name or not rawget( data.lists, entry.list_name ) then
                                                        desc = "|cff00ccff(not set)|r"
                                                        warning = true
                                                    else
                                                        desc = "|cff00ccff" .. entry.list_name .. "|r"
                                                    end

                                                    if cLen and cLen > 0 then
                                                        desc = desc .. ", if |cffffd100" .. entry.criteria .. "|r"
                                                    end

                                                elseif entry.action == "cancel_buff" then
                                                    if not entry.buff_name then
                                                        desc = "|cff00ccff(not set)|r"
                                                        warning = true
                                                    else
                                                        local a = class.auras[ entry.buff_name ]

                                                        if a then
                                                            desc = "|cff00ccff" .. a.name .. "|r"
                                                        else
                                                            desc = "|cff00ccff(not found)|r"
                                                            warning = true
                                                        end
                                                    end

                                                    if cLen and cLen > 0 then
                                                        desc = desc .. ", if |cffffd100" .. entry.criteria .. "|r"
                                                    end

                                                elseif entry.action == "cancel_action" then
                                                    if not entry.action_name then
                                                        desc = "|cff00ccff(not set)|r"
                                                        warning = true
                                                    else
                                                        local a = class.abilities[ entry.action_name ]

                                                        if a then
                                                            desc = "|cff00ccff" .. a.name .. "|r"
                                                        else
                                                            desc = "|cff00ccff(not found)|r"
                                                            warning = true
                                                        end
                                                    end

                                                    if cLen and cLen > 0 then
                                                        desc = desc .. ", if |cffffd100" .. entry.criteria .. "|r"
                                                    end

                                                elseif cLen and cLen > 0 then
                                                    desc = "|cffffd100" .. entry.criteria .. "|r"

                                                end

                                                if not entry.enabled then
                                                    warning = true
                                                    color = "|cFF808080"
                                                end

                                                if desc then desc = desc:gsub( "[\r\n]", "" ) end

                                                if not color then
                                                    color = warning and "|cFFFF0000" or "|cFFFFD100"
                                                end

                                                if entry.empower_to then
                                                    action = action .. " (" .. entry.empower_to .. ")"
                                                end

                                                if desc then
                                                    v[ key ] = color .. i .. ".|r " .. action .. " - " .. "|cFFFFD100" .. desc .. "|r"
                                                else
                                                    v[ key ] = color .. i .. ".|r " .. action
                                                end

                                                last = i + 1
                                            end
                                        end

                                        return v
                                    end,
                                    hidden = function ()
                                        return packControl.makingNew == true
                                    end,
                                },

                                moveUpBtn = {
                                    type = "execute",
                                    name = "",
                                    image = "Interface\\AddOns\\Hekili\\Textures\\WhiteUp",
                                    -- image = GetAtlasFile( "hud-MainMenuBar-arrowup-up" ),
                                    -- imageCoords = GetAtlasCoords( "hud-MainMenuBar-arrowup-up" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    width = 0.15,
                                    order = 2.1,
                                    func = function( info )
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        local data = p.lists[ packControl.listName ]
                                        local actionID = tonumber( packControl.actionID )

                                        local a = remove( data, actionID )
                                        insert( data, actionID - 1, a )
                                        packControl.actionID = format( "%04d", actionID - 1 )

                                        local listName = format( "%s:%s:", pack, packControl.listName )
                                        scripts:SwapScripts( listName .. actionID, listName .. ( actionID - 1 ) )
                                    end,
                                    disabled = function ()
                                        return tonumber( packControl.actionID ) == 1
                                    end,
                                    hidden = function () return packControl.makingNew end,
                                },

                                moveDownBtn = {
                                    type = "execute",
                                    name = "",
                                    image = "Interface\\AddOns\\Hekili\\Textures\\WhiteDown",
                                    -- image = GetAtlasFile( "hud-MainMenuBar-arrowdown-up" ),
                                    -- imageCoords = GetAtlasCoords( "hud-MainMenuBar-arrowdown-up" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    width = 0.15,
                                    order = 2.2,
                                    func = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        local data = p.lists[ packControl.listName ]
                                        local actionID = tonumber( packControl.actionID )

                                        local a = remove( data, actionID )
                                        insert( data, actionID + 1, a )
                                        packControl.actionID = format( "%04d", actionID + 1 )

                                        local listName = format( "%s:%s:", pack, packControl.listName )
                                        scripts:SwapScripts( listName .. actionID, listName .. ( actionID + 1 ) )
                                    end,
                                    disabled = function()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return not p.lists[ packControl.listName ] or tonumber( packControl.actionID ) == #p.lists[ packControl.listName ]
                                    end,
                                    hidden = function () return packControl.makingNew end,
                                },

                                newActionBtn = {
                                    type = "execute",
                                    name = "",
                                    image = "Interface\\AddOns\\Hekili\\Textures\\GreenPlus",
                                    -- image = GetAtlasFile( "communities-icon-addgroupplus" ),
                                    -- imageCoords = GetAtlasCoords( "communities-icon-addgroupplus" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    width = 0.15,
                                    order = 2.3,
                                    func = function()
                                        local data = rawget( self.DB.profile.packs, pack )
                                        if data then
                                            insert( data.lists[ packControl.listName ], { {} } )
                                            packControl.actionID = format( "%04d", #data.lists[ packControl.listName ] )
                                        else
                                            packControl.actionID = "0001"
                                        end
                                    end,
                                    hidden = function () return packControl.makingNew end,
                                },

                                delActionBtn = {
                                    type = "execute",
                                    name = "",
                                    image = RedX,
                                    -- image = GetAtlasFile( "communities-icon-redx" ),
                                    -- imageCoords = GetAtlasCoords( "communities-icon-redx" ),
                                    imageHeight = 20,
                                    imageWidth = 20,
                                    width = 0.15,
                                    order = 2.4,
                                    confirm = function() return "Delete this entry?" end,
                                    func = function ()
                                        local id = tonumber( packControl.actionID )
                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                        remove( p.lists[ packControl.listName ], id )

                                        if not p.lists[ packControl.listName ][ id ] then id = id - 1; packControl.actionID = format( "%04d", id ) end
                                        if not p.lists[ packControl.listName ][ id ] then packControl.actionID = "zzzzzzzzzz" end

                                        self:LoadScripts()
                                    end,
                                    disabled = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return not p.lists[ packControl.listName ] or #p.lists[ packControl.listName ] < 2
                                    end,
                                    hidden = function () return packControl.makingNew end,
                                },

                                --[[ actionGroup = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 3,
                                    hidden = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                        if packControl.makingNew or rawget( p.lists, packControl.listName ) == nil or packControl.actionID == "zzzzzzzzzz" then
                                            return true
                                        end
                                        return false
                                    end,
                                    args = {
                                        entry = {
                                            type = "group",
                                            inline = true,
                                            name = "",
                                            order = 2,
                                            -- get = 'GetActionOption',
                                            -- set = 'SetActionOption',
                                            hidden = function( info )
                                                local id = tonumber( packControl.actionID )
                                                local p = rawget( Hekili.DB.profile.packs, pack )
                                                return not packControl.actionID or packControl.actionID == "zzzzzzzzzz" or not p.lists[ packControl.listName ][ id ]
                                            end,
                                            args = { ]]
                                                enabled = {
                                                    type = "toggle",
                                                    name = "Enabled",
                                                    desc = "If disabled, this entry will not be shown even if its criteria are met.",
                                                    order = 3.0,
                                                    width = "full",
                                                },

                                                action = {
                                                    type = "select",
                                                    name = "Action",
                                                    desc = "Select the action that will be recommended when this entry's criteria are met.",
                                                    values = class.abilityList,
                                                    sorting = function()
                                                        local list = {}

                                                        for k, v in pairs( class.abilityList ) do
                                                            insert( list, {
                                                                k, class.abilities[ k ].name or v or k
                                                            } )
                                                        end

                                                        sort( list, function( a, b ) return a[2] < b[2] end )

                                                        for i = 1, #list do
                                                            list[ i ] = list[ i ][ 1 ]
                                                        end

                                                        return list
                                                    end,
                                                    order = 3.1,
                                                    width = 1.5,
                                                },

                                                list_name = {
                                                    type = "select",
                                                    name = "Action List",
                                                    values = function ()
                                                        local e = GetListEntry( pack )
                                                        local v = {}

                                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                                        for k in pairs( p.lists ) do
                                                            if k ~= packControl.listName then
                                                                if k == 'precombat' or k == 'default' then
                                                                    v[ k ] = "|cFF00B4FF" .. k .. "|r"
                                                                else
                                                                    v[ k ] = k
                                                                end
                                                            end
                                                        end

                                                        return v
                                                    end,
                                                    order = 3.2,
                                                    width = 1.5,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return not ( e.action == "call_action_list" or e.action == "run_action_list" )
                                                    end,
                                                },

                                                buff_name = {
                                                    type = "select",
                                                    name = "Buff Name",
                                                    order = 3.2,
                                                    width = 1.5,
                                                    desc = "Specify the buff to remove.",
                                                    values = class.auraList,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "cancel_buff"
                                                    end,
                                                },

                                                action_name = {
                                                    type = "select",
                                                    name = "Action Name",
                                                    order = 3.2,
                                                    width = 1.5,
                                                    desc = "Specify the action to cancel; the result is that the addon will allow the channel to be removed immediately.",
                                                    values = class.abilityList,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "cancel_action"
                                                    end,
                                                },

                                                potion = {
                                                    type = "select",
                                                    name = "Potion",
                                                    order = 3.2,
                                                    -- width = "full",
                                                    values = class.potionList,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "potion"
                                                    end,
                                                    width = 1.5,
                                                },

                                                sec = {
                                                    type = "input",
                                                    name = "Seconds",
                                                    order = 3.2,
                                                    width = 1.5,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "wait"
                                                    end,
                                                },

                                                max_energy = {
                                                    type = "toggle",
                                                    name = "Max Energy",
                                                    order = 3.2,
                                                    width = 1.5,
                                                    desc = "When checked, this entry will require that the player have enough energy to trigger Ferocious Bite's full damage bonus.",
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "ferocious_bite"
                                                    end,
                                                },

                                                empower_to = {
                                                    type = "select",
                                                    name = "Empower To",
                                                    order = 3.2,
                                                    width = 1.5,
                                                    desc = "For Empowered spells, specify the empowerment level for this usage (default is max).",
                                                    values = {
                                                        [1] = "I",
                                                        [2] = "II",
                                                        [3] = "III",
                                                        [4] = "IV",
                                                        maximum = "Max"
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local action = e.action
                                                        local ability = action and class.abilities[ action ]
                                                        return not ( ability and ability.empowered )
                                                    end,
                                                },

                                                lb00 = {
                                                    type = "description",
                                                    name = "",
                                                    order = 3.201,
                                                    width = "full",
                                                },

                                                caption = {
                                                    type = "input",
                                                    name = "Caption",
                                                    desc = "Captions are |cFFFF0000very|r short descriptions that can appear on the icon of a recommended ability.\n\n" ..
                                                        "This can be useful for understanding why an ability was recommended at a particular time.\n\n" ..
                                                        "Requires Captions to be Enabled on each display.",
                                                    order = 3.202,
                                                    width = 1.5,
                                                    validate = function( info, val )
                                                        val = val:trim()
                                                        if val:len() > 20 then return "Captions should be 20 characters or less." end
                                                        return true
                                                    end,
                                                    hidden = function()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not ability or ( ability.id < 0 and ability.id > -10 )
                                                    end,
                                                },

                                                description = {
                                                    type = "input",
                                                    name = "Description",
                                                    desc = "This allows you to provide text that explains this entry, which will show when you Pause and mouseover the ability to see " ..
                                                        "why this entry was recommended.",
                                                    order = 3.205,
                                                    width = "full",
                                                },

                                                lb01 = {
                                                    type = "description",
                                                    name = "",
                                                    order = 3.21,
                                                    width = "full"
                                                },

                                                var_name = {
                                                    type = "input",
                                                    name = "Variable Name",
                                                    order = 3.3,
                                                    width = 1.5,
                                                    desc = "Specify a name for this variable.  Variables must be lowercase with no spaces or symbols aside from the underscore.",
                                                    validate = function( info, val )
                                                        if val:len() < 3 then return "Variables must be at least 3 characters in length." end

                                                        local check = formatKey( val )
                                                        if check ~= val then return "Invalid characters entered.  Try again." end

                                                        return true
                                                    end,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "variable"
                                                    end,
                                                },

                                                op = {
                                                    type = "select",
                                                    name = "Operation",
                                                    values = {
                                                        add = "Add Value",
                                                        ceil = "Ceiling of Value",
                                                        default = "Set Default Value",
                                                        div = "Divide Value",
                                                        floor = "Floor of Value",
                                                        max = "Maximum of Values",
                                                        min = "Minimum of Values",
                                                        mod = "Modulo of Value",
                                                        mul = "Multiply Value",
                                                        pow = "Raise Value to X Power",
                                                        reset = "Reset to Default",
                                                        set = "Set Value",
                                                        setif = "Set Value If...",
                                                        sub = "Subtract Value",
                                                    },
                                                    order = 3.31,
                                                    width = 1.5,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "variable"
                                                    end,
                                                },

                                                modPooling = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 3.5,
                                                    args = {
                                                        for_next = {
                                                            type = "toggle",
                                                            name = function ()
                                                                local n = packControl.actionID; n = tonumber( n ) + 1
                                                                local e = Hekili.DB.profile.packs[ pack ].lists[ packControl.listName ][ n ]

                                                                local ability = e and e.action and class.abilities[ e.action ]
                                                                ability = ability and ability.name or "Not Set"

                                                                return "Pool for Next Entry (" .. ability ..")"
                                                            end,
                                                            desc = "If checked, the addon will pool resources until the next entry has enough resources to use.",
                                                            order = 5,
                                                            width = 1.5,
                                                            hidden = function ()
                                                                local e = GetListEntry( pack )
                                                                return e.action ~= "pool_resource"
                                                            end,
                                                        },

                                                        wait = {
                                                            type = "input",
                                                            name = "Pooling Time",
                                                            desc = "Specify the time, in seconds, as a number or as an expression that evaluates to a number.\n" ..
                                                                "Default is |cFFFFD1000.5|r.  An example expression would be |cFFFFD100energy.time_to_max|r.",
                                                            order = 6,
                                                            width = 1.5,
                                                            multiline = 3,
                                                            hidden = function ()
                                                                local e = GetListEntry( pack )
                                                                return e.action ~= "pool_resource" or e.for_next == 1
                                                            end,
                                                        },

                                                        extra_amount = {
                                                            type = "input",
                                                            name = "Extra Pooling",
                                                            desc = "Specify the amount of extra resources to pool in addition to what is needed for the next entry.",
                                                            order = 6,
                                                            width = 1.5,
                                                            hidden = function ()
                                                                local e = GetListEntry( pack )
                                                                return e.action ~= "pool_resource" or e.for_next ~= 1
                                                            end,
                                                        },
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= 'pool_resource'
                                                    end,
                                                },

                                                criteria = {
                                                    type = "input",
                                                    name = "Conditions",
                                                    order = 3.6,
                                                    width = "full",
                                                    multiline = 6,
                                                    dialogControl = "HekiliCustomEditor",
                                                    arg = function( info )
                                                        local pack, list, action = info[ 2 ], packControl.listName, tonumber( packControl.actionID )
                                                        local results = {}

                                                        state.reset( "Primary", true )

                                                        local apack = rawget( self.DB.profile.packs, pack )

                                                        -- Let's load variables, just in case.
                                                        for name, alist in pairs( apack.lists ) do
                                                            for i, entry in ipairs( alist ) do
                                                                if name ~= list or i ~= action then
                                                                    if entry.action == "variable" and entry.var_name then
                                                                        state:RegisterVariable( entry.var_name, pack .. ":" .. name .. ":" .. i, name )
                                                                    end
                                                                end
                                                            end
                                                        end

                                                        local entry = apack and apack.lists[ list ]
                                                        entry = entry and entry[ action ]

                                                        state.this_action = entry.action

                                                        local scriptID = pack .. ":" .. list .. ":" .. action
                                                        state.scriptID = scriptID
                                                        scripts:StoreValues( results, scriptID )

                                                        return results, list, action
                                                    end,
                                                },

                                                value = {
                                                    type = "input",
                                                    name = "Value",
                                                    desc = "Provide the value to store (or calculate) when this variable is invoked.",
                                                    order = 3.61,
                                                    width = "full",
                                                    multiline = 3,
                                                    dialogControl = "HekiliCustomEditor",
                                                    arg = function( info )
                                                        local pack, list, action = info[ 2 ], packControl.listName, tonumber( packControl.actionID )
                                                        local results = {}

                                                        state.reset( "Primary", true )

                                                        local apack = rawget( self.DB.profile.packs, pack )

                                                        -- Let's load variables, just in case.
                                                        for name, alist in pairs( apack.lists ) do
                                                            for i, entry in ipairs( alist ) do
                                                                if name ~= list or i ~= action then
                                                                    if entry.action == "variable" and entry.var_name then
                                                                        state:RegisterVariable( entry.var_name, pack .. ":" .. name .. ":" .. i, name )
                                                                    end
                                                                end
                                                            end
                                                        end

                                                        local entry = apack and apack.lists[ list ]
                                                        entry = entry and entry[ action ]

                                                        state.this_action = entry.action

                                                        local scriptID = pack .. ":" .. list .. ":" .. action
                                                        state.scriptID = scriptID
                                                        scripts:StoreValues( results, scriptID, "value" )

                                                        return results, list, action
                                                    end,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "variable" or e.op == "reset" or e.op == "ceil" or e.op == "floor"
                                                    end,
                                                },

                                                value_else = {
                                                    type = "input",
                                                    name = "Value Else",
                                                    desc = "Provide the value to store (or calculate) if this variable's conditions are not met.",
                                                    order = 3.62,
                                                    width = "full",
                                                    multiline = 3,
                                                    dialogControl = "HekiliCustomEditor",
                                                    arg = function( info )
                                                        local pack, list, action = info[ 2 ], packControl.listName, tonumber( packControl.actionID )
                                                        local results = {}

                                                        state.reset( "Primary", true )

                                                        local apack = rawget( self.DB.profile.packs, pack )

                                                        -- Let's load variables, just in case.
                                                        for name, alist in pairs( apack.lists ) do
                                                            for i, entry in ipairs( alist ) do
                                                                if name ~= list or i ~= action then
                                                                    if entry.action == "variable" and entry.var_name then
                                                                        state:RegisterVariable( entry.var_name, pack .. ":" .. name .. ":" .. i, name )
                                                                    end
                                                                end
                                                            end
                                                        end

                                                        local entry = apack and apack.lists[ list ]
                                                        entry = entry and entry[ action ]

                                                        state.this_action = entry.action

                                                        local scriptID = pack .. ":" .. list .. ":" .. action
                                                        state.scriptID = scriptID
                                                        scripts:StoreValues( results, scriptID, "value_else" )

                                                        return results, list, action
                                                    end,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        -- if not e.criteria or e.criteria:trim() == "" then return true end
                                                        return e.action ~= "variable" or e.op == "reset" or e.op == "ceil" or e.op == "floor"
                                                    end,
                                                },

                                                showModifiers = {
                                                    type = "toggle",
                                                    name = "Show Modifiers",
                                                    desc = "If checked, some additional modifiers and conditions may be set.",
                                                    order = 20,
                                                    width = "full",
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not ability -- or ( ability.id < 0 and ability.id > -100 )
                                                    end,
                                                },

                                                modCycle = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 21,
                                                    args = {
                                                        cycle_targets = {
                                                            type = "toggle",
                                                            name = "Cycle Targets",
                                                            desc = "If checked, the addon will check each available target and show whether to switch targets.",
                                                            order = 1,
                                                            width = "single",
                                                        },

                                                        max_cycle_targets = {
                                                            type = "input",
                                                            name = "Max Cycle Targets",
                                                            desc = "If cycle targets is checked, the addon will check up to the specified number of targets.",
                                                            order = 2,
                                                            width = "double",
                                                            disabled = function( info )
                                                                local e = GetListEntry( pack )
                                                                return e.cycle_targets ~= 1
                                                            end,
                                                        }
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not packControl.showModifiers or ( not ability or ( ability.id < 0 and ability.id > -100 ) )
                                                    end,
                                                },

                                                modMoving = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 22,
                                                    args = {
                                                        enable_moving = {
                                                            type = "toggle",
                                                            name = "Check Movement",
                                                            desc = "If checked, this entry can only be recommended when your character movement matches the setting.",
                                                            order = 1,
                                                        },

                                                        moving = {
                                                            type = "select",
                                                            name = "Movement",
                                                            desc = "If set, this entry can only be recommended when your movement matches the setting.",
                                                            order = 2,
                                                            width = "double",
                                                            values = {
                                                                [0]  = "Stationary",
                                                                [1]  = "Moving"
                                                            },
                                                            disabled = function( info )
                                                                local e = GetListEntry( pack )
                                                                return not e.enable_moving
                                                            end,
                                                        }
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not packControl.showModifiers or ( not ability or ( ability.id < 0 and ability.id > -100 ) )
                                                    end,
                                                },

                                                modAsyncUsage = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 22.1,
                                                    args = {
                                                        use_off_gcd = {
                                                            type = "toggle",
                                                            name = "Use Off GCD",
                                                            desc = "If checked, this entry can be checked even if the global cooldown (GCD) is active.",
                                                            order = 1,
                                                            width = 0.99,
                                                        },
                                                        use_while_casting = {
                                                            type = "toggle",
                                                            name = "Use While Casting",
                                                            desc = "If checked, this entry can be checked even if you are already casting or channeling.",
                                                            order = 2,
                                                            width = 0.99
                                                        },
                                                        only_cwc = {
                                                            type = "toggle",
                                                            name = "During Channel",
                                                            desc = "If checked, this entry can only be used if you are channeling another spell.",
                                                            order = 3,
                                                            width = 0.99
                                                        }
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not packControl.showModifiers or ( not ability or ( ability.id < 0 and ability.id > -100 ) )
                                                    end,
                                                },

                                                modCooldown = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 23,
                                                    args = {
                                                        --[[ enable_line_cd = {
                                                            type = "toggle",
                                                            name = "Line Cooldown",
                                                            desc = "If enabled, this entry cannot be recommended unless the specified amount of time has passed since its last use.",
                                                            order = 1,
                                                        }, ]]

                                                        line_cd = {
                                                            type = "input",
                                                            name = "Entry Cooldown",
                                                            desc = "If set, this entry cannot be recommended unless this time has passed since the last time the ability was used.",
                                                            order = 1,
                                                            width = "full",
                                                            --[[ disabled = function( info )
                                                                local e = GetListEntry( pack )
                                                                return not e.enable_line_cd
                                                            end, ]]
                                                        },
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not packControl.showModifiers or ( not ability or ( ability.id < 0 and ability.id > -100 ) )
                                                    end,
                                                },

                                                modAPL = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 24,
                                                    args = {
                                                        strict = {
                                                            type = "toggle",
                                                            name = "Strict / Time Insensitive",
                                                            desc = "If checked, the addon will assume this entry is not time-sensitive and will not test actions in the linked priority list if criteria are not presently met.",
                                                            order = 1,
                                                            width = "full",
                                                        }
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        local ability = e.action and class.abilities[ e.action ]

                                                        return not packControl.showModifiers or ( not ability or not ( ability.key == "call_action_list" or ability.key == "run_action_list" ) )
                                                    end,
                                                },

                                                --[[ deleteHeader = {
                                                    type = "header",
                                                    name = "Delete Action",
                                                    order = 100,
                                                    hidden = function ()
                                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                                        return #p.lists[ packControl.listName ] < 2 end
                                                },

                                                delete = {
                                                    type = "execute",
                                                    name = "Delete Entry",
                                                    order = 101,
                                                    confirm = true,
                                                    func = function ()
                                                        local id = tonumber( packControl.actionID )
                                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                                        remove( p.lists[ packControl.listName ], id )

                                                        if not p.lists[ packControl.listName ][ id ] then id = id - 1; packControl.actionID = format( "%04d", id ) end
                                                        if not p.lists[ packControl.listName ][ id ] then packControl.actionID = "zzzzzzzzzz" end

                                                        self:LoadScripts()
                                                    end,
                                                    hidden = function ()
                                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                                        return #p.lists[ packControl.listName ] < 2
                                                    end
                                                }
                                            },
                                        },
                                    }
                                }, ]]

                                newListGroup = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 2,
                                    hidden = function ()
                                        return not packControl.makingNew
                                    end,
                                    args = {
                                        newListName = {
                                            type = "input",
                                            name = "List Name",
                                            order = 1,
                                            validate = function( info, val )
                                                local p = rawget( Hekili.DB.profile.packs, pack )

                                                if val:len() < 2 then return "Action list names should be at least 2 characters in length."
                                                elseif rawget( p.lists, val ) then return "There is already an action list by that name."
                                                elseif val:find( "[^a-zA-Z0-9_]" ) then return "Only alphanumeric characters and underscores can be used in list names." end
                                                return true
                                            end,
                                            width = 3,
                                        },

                                        lineBreak = {
                                            type = "description",
                                            name = "",
                                            order = 1.1,
                                            width = "full"
                                        },

                                        createList = {
                                            type = "execute",
                                            name = "Add List",
                                            disabled = function() return packControl.newListName == nil end,
                                            func = function ()
                                                local p = rawget( Hekili.DB.profile.packs, pack )
                                                p.lists[ packControl.newListName ] = { {} }
                                                packControl.listName = packControl.newListName
                                                packControl.makingNew = false

                                                packControl.actionID = "0001"
                                                packControl.newListName = nil

                                                Hekili:LoadScript( pack, packControl.listName, 1 )
                                            end,
                                            width = 1,
                                            order = 2,
                                        },

                                        cancel = {
                                            type = "execute",
                                            name = "Cancel",
                                            func = function ()
                                                packControl.makingNew = false
                                            end,
                                        }
                                    }
                                },

                                newActionGroup = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 3,
                                    hidden = function ()
                                        return packControl.makingNew or packControl.actionID ~= "zzzzzzzzzz"
                                    end,
                                    args = {
                                        createEntry = {
                                            type = "execute",
                                            name = "Create New Entry",
                                            order = 1,
                                            func = function ()
                                                local p = rawget( Hekili.DB.profile.packs, pack )
                                                insert( p.lists[ packControl.listName ], {} )
                                                packControl.actionID = format( "%04d", #p.lists[ packControl.listName ] )
                                            end,
                                        }
                                    }
                                }
                            },
                            plugins = {
                            }
                        },

                        export = {
                            type = "group",
                            name = "Export",
                            order = 4,
                            args = {
                                exportString = {
                                    type = "input",
                                    name = "Priority Export String\n|cFFFFFFFFPress CTRL+A to select, then CTRL+C to copy.|r",
                                    get = function( info )
                                        return SerializeActionPack( pack )
                                    end,
                                    set = function () end,
                                    order = 1,
                                    width = "full"
                                }
                            }
                        }
                    },
                }

                --[[ wipe( opts.args.lists.plugins.lists )

                local n = 10
                for list in pairs( data.lists ) do
                    opts.args.lists.plugins.lists[ list ] = EmbedActionListOptions( n, pack, list )
                    n = n + 1
                end ]]

                packs.plugins.packages[ pack ] = opts
                count = count + 1
            end
        end

        collectgarbage()
        db.args.packs = packs
    end

end


do
    local completed = false
    local SetOverrideBinds

    SetOverrideBinds = function ()
        if InCombatLockdown() then
            C_Timer.After( 5, SetOverrideBinds )
            return
        end

        if completed then
            ClearOverrideBindings( Hekili_Keyhandler )
            completed = false
        end

        for name, toggle in pairs( Hekili.DB.profile.toggles ) do
            if toggle.key and toggle.key ~= "" then
                SetOverrideBindingClick( Hekili_Keyhandler, true, toggle.key, "Hekili_Keyhandler", name )
                completed = true
            end
        end
    end

    function Hekili:OverrideBinds()
        SetOverrideBinds()
    end

    local function SetToggle( info, val )
        local self = Hekili
        local p = self.DB.profile
        local n = #info
        local bind, option = info[ 2 ], info[ n ]

        local toggle = p.toggles[ bind ]
        if not toggle then return end

        if option == 'value' then
            if bind == 'pause' then self:TogglePause()
            elseif bind == 'mode' then toggle.value = val
            else self:FireToggle( bind ) end

        elseif option == 'type' then
            toggle.type = val

            if val == "AutoSingle" and not ( toggle.value == "automatic" or toggle.value == "single" ) then toggle.value = "automatic" end
            if val == "AutoDual" and not ( toggle.value == "automatic" or toggle.value == "dual" ) then toggle.value = "automatic" end
            if val == "SingleAOE" and not ( toggle.value == "single" or toggle.value == "aoe" ) then toggle.value = "single" end
            if val == "ReactiveDual" and toggle.value ~= "reactive" then toggle.value = "reactive" end

        elseif option == 'key' then
            for t, data in pairs( p.toggles ) do
                if data.key == val then data.key = "" end
            end

            toggle.key = val
            self:OverrideBinds()

        elseif option == 'override' then
            toggle[ option ] = val
            ns.UI.Minimap:RefreshDataText()

        else
            toggle[ option ] = val

        end
    end

    local function GetToggle( info )
        local self = Hekili
        local p = Hekili.DB.profile
        local n = #info
        local bind, option = info[2], info[ n ]

        local toggle = bind and p.toggles[ bind ]
        if not toggle then return end

        if bind == 'pause' and option == 'value' then return self.Pause end
        return toggle[ option ]
    end

    -- Bindings.
    function Hekili:EmbedToggleOptions( db )
        db = db or self.Options
        if not db then return end

        db.args.toggles = db.args.toggles or {
            type = 'group',
            name = 'Toggles',
            order = 20,
            get = GetToggle,
            set = SetToggle,
            args = {
                info = {
                    type = "description",
                    name = "Toggles are keybindings that you can use to direct the addon's recommendations and how they are presented.",
                    order = 0.5,
                    fontSize = "medium",
                },

                cooldowns = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 2,
                    args = {
                        key = {
                            type = "keybinding",
                            name = "Cooldowns",
                            desc = "Set a key to toggle cooldown recommendations on/off.",
                            order = 1,
                        },

                        value = {
                            type = "toggle",
                            name = "Show Cooldowns",
                            desc = "If checked, abilities marked as cooldowns can be recommended.",
                            order = 2,
                        },

                        separate = {
                            type = "toggle",
                            name = "Show Separately",
                            desc = "If checked, cooldown abilities will be shown separately in your Cooldowns Display.\n\n" ..
                                "This is an experimental feature and may not work well for some specializations.",
                            order = 3,
                        },

                        lineBreak = {
                            type = "description",
                            name = "",
                            width = "full",
                            order = 3.1,
                        },

                        indent = {
                            type = "description",
                            name = "",
                            width = 1,
                            order = 3.2
                        },

                        override = {
                            type = "toggle",
                            name = "Bloodlust Override",
                            desc = "If checked, when Bloodlust (or similar effects) are active, the addon will recommend cooldown abilities even if Show Cooldowns is not checked.",
                            order = 4,
                        }
                    }
                },

                essences = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 2.1,
                    args = {
                        key = {
                            type = "keybinding",
                            name = "Covenants",
                            desc = "Set a key to toggle Covenant recommendations on/off.",
                            order = 1,
                        },

                        value = {
                            type = "toggle",
                            name = "Show Covenants",
                            desc = "If checked, abilities from Covenants can be recommended.",
                            order = 2,
                        },

                        override = {
                            type = "toggle",
                            name = "Cooldowns Override",
                            desc = "If checked, when Cooldowns are enabled, the addon will also recommend Covenants even if Show Covenants is not checked.",
                            order = 3,
                        },
                    }
                },

                defensives = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 5,
                    args = {
                        key = {
                            type = "keybinding",
                            name = "Defensives",
                            desc = "Set a key to toggle defensive/mitigation recommendations on/off.\n" ..
                                "\nThis applies only to tanking specializations.",
                            order = 1,
                        },

                        value = {
                            type = "toggle",
                            name = "Show Defensives",
                            desc = "If checked, abilities marked as defensives can be recommended.\n" ..
                                "\nThis applies only to tanking specializations.",
                            order = 2,
                        },

                        separate = {
                            type = "toggle",
                            name = "Show Separately",
                            desc = "If checked, defensive/mitigation abilities will be shown separately in your Defensives Display.\n" ..
                                "\nThis applies only to tanking specializations.",
                            order = 3,
                        }
                    }
                },

                interrupts = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 4,
                    args = {
                        key = {
                            type = "keybinding",
                            name = "Interrupts",
                            desc = "Set a key to use for toggling interrupts on/off.",
                            order = 1,
                        },

                        value = {
                            type = "toggle",
                            name = "Show Interrupts",
                            desc = "If checked, abilities marked as interrupts can be recommended.",
                            order = 2,
                        },

                        separate = {
                            type = "toggle",
                            name = "Show Separately",
                            desc = "If checked, interrupt abilities will be shown separately in the Interrupts Display only (if enabled).",
                            order = 3,
                        }
                    }
                },

                potions = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 6,
                    args = {
                        key = {
                            type = "keybinding",
                            name = "Potions",
                            desc = "Set a key to toggle potion recommendations on/off.",
                            order = 1,
                        },

                        value = {
                            type = "toggle",
                            name = "Show Potions",
                            desc = "If checked, abilities marked as potions can be recommended.",
                            order = 2,
                        },
                    }
                },

                displayModes = {
                    type = "header",
                    name = "Display Modes",
                    order = 10,
                },

                mode = {
                    type = "group",
                    inline = true,
                    name = "",
                    order = 10.1,
                    args = {
                        key = {
                            type = 'keybinding',
                            name = 'Display Mode',
                            desc = "Pressing this binding will cycle your Display Mode through the options checked below.",
                            order = 1,
                            width = 1,
                        },

                        value = {
                            type = "select",
                            name = "Current Display Mode",
                            desc = "Select your current Display Mode.",
                            values = {
                                automatic = "Automatic",
                                single = "Single-Target",
                                aoe = "AOE (Multi-Target)",
                                dual = "Fixed Dual Display",
                                reactive = "Reactive Dual Display"
                            },
                            width = 2,
                            order = 1.02,
                        },

                        modeLB2 = {
                            type = "description",
                            name = "Select the |cFFFFD100Display Modes|r that you wish to use.  Each time you press your |cFFFFD100Display Mode|r keybinding, the addon will switch to the next checked mode.",
                            fontSize = "medium",
                            width = "full",
                            order = 1.03
                        },

                        automatic = {
                            type = "toggle",
                            name = "Automatic",
                            desc = "If checked, the Display Mode toggle can select Automatic mode.\n\nThe Primary display shows recommendations based upon the detected number of enemies (based on your specialization's options).",
                            width = 1.5,
                            order = 1.1,
                        },

                        single = {
                            type = "toggle",
                            name = "Single-Target",
                            desc = "If checked, the Display Mode toggle can select Single-Target mode.\n\nThe Primary display shows recommendations as though you have one target (even if more targets are detected).",
                            width = 1.5,
                            order = 1.2,
                        },

                        aoe = {
                            type = "toggle",
                            name = "AOE (Multi-Target)",
                            desc = function ()
                                return format( "If checked, the Display Mode toggle can select AOE mode.\n\nThe Primary display shows recommendations as though you have at least |cFFFFD100%d|r targets (even if fewer are detected).\n\n" ..
                                                "The number of targets is set in your specialization's options.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                            end,
                            width = 1.5,
                            order = 1.3,
                        },

                        dual = {
                            type = "toggle",
                            name = "Fixed Dual Display",
                            desc = function ()
                                return format( "If checked, the Display Mode toggle can select Dual Display mode.\n\nThe Primary display shows single-target recommendations and the AOE display shows recommendations for |cFFFFD100%d|r or more targets (even if fewer are detected).\n\n" ..
                                                "The number of AOE targets is set in your specialization's options.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                            end,
                            width = 1.5,
                            order = 1.4,
                        },

                        reactive = {
                            type = "toggle",
                            name = "Reactive Dual Display",
                            desc = function ()
                                return format( "If checked, the Display Mode toggle can select Reactive mode.\n\nThe Primary display shows single-target recommendations, while the AOE display remains hidden until/unless |cFFFFD100%d|r or more targets are detected.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                            end,
                            width = 1.5,
                            order = 1.5,
                        },

                        --[[ type = {
                            type = "select",
                            name = "Modes",
                            desc = "Select the Display Modes that can be cycled using your Display Mode key.\n\n" ..
                                "|cFFFFD100Auto vs. Single|r - Using only the Primary display, toggle between automatic target counting and single-target recommendations.\n\n" ..
                                "|cFFFFD100Single vs. AOE|r - Using only the Primary display, toggle between single-target recommendations and AOE (multi-target) recommendations.\n\n" ..
                                "|cFFFFD100Auto vs. Dual|r - Toggle between one display using automatic target counting and two displays, with one showing single-target recommendations and the other showing AOE recommendations.  This will use additional CPU.\n\n" ..
                                "|cFFFFD100Reactive AOE|r - Use the Primary display for single-target recommendations, and when additional enemies are detected, show the AOE display.  (Disables Mode Toggle)",
                            values = {
                                AutoSingle = "Auto vs. Single",
                                SingleAOE = "Single vs. AOE",
                                AutoDual = "Auto vs. Dual",
                                ReactiveDual = "Reactive AOE",
                            },
                            order = 2,
                        }, ]]
                    },
                },

                troubleshooting = {
                    type = "header",
                    name = "Troubleshooting",
                    order = 20,
                },

                pause = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 20.1,
                    args = {
                        key = {
                            type = 'keybinding',
                            name = function () return Hekili.Pause and "Unpause" or "Pause" end,
                            desc =  "Set a key to pause processing of your action lists. Your current display(s) will freeze, " ..
                                    "and you can mouseover each icon to see information about the displayed action.\n\n" ..
                                    "This will also create a Snapshot that can be used for troubleshooting and error reporting.",
                            order = 1,
                        },
                        value = {
                            type = 'toggle',
                            name = 'Pause',
                            order = 2,
                        },
                    }
                },

                snapshot = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 20.2,
                    args = {
                        key = {
                            type = 'keybinding',
                            name = 'Snapshot',
                            desc = "Set a key to make a snapshot (without pausing) that can be viewed on the Snapshots tab.  This can be useful information for testing and debugging.",
                            order = 1,
                        },
                    }
                },

                customHeader = {
                    type = "header",
                    name = "Custom",
                    order = 30,
                },

                custom1 = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 30.1,
                    args = {
                        key = {
                            type = "keybinding",
                            name = "Custom #1",
                            desc = "Set a key to toggle your first custom set.",
                            order = 1,
                        },

                        value = {
                            type = "toggle",
                            name = "Show Custom #1",
                            desc = "If checked, abilities linked to Custom #1 can be recommended.",
                            order = 2,
                        },

                        name = {
                            type = "input",
                            name = "Custom #1 Name",
                            desc = "Specify a descriptive name for this custom toggle.",
                            order = 3
                        }
                    }
                },

                custom2 = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 30.2,
                    args = {
                        key = {
                            type = "keybinding",
                            name = "Custom #2",
                            desc = "Set a key to toggle your second custom set.",
                            order = 1,
                        },

                        value = {
                            type = "toggle",
                            name = "Show Custom #2",
                            desc = "If checked, abilities linked to Custom #2 can be recommended.",
                            order = 2,
                        },

                        name = {
                            type = "input",
                            name = "Custom #2 Name",
                            desc = "Specify a descriptive name for this custom toggle.",
                            order = 3
                        }
                    }
                },

                --[[ specLinks = {
                    type = "group",
                    inline = true,
                    name = "",
                    order = 10,
                    args = {
                        header = {
                            type = "header",
                            name = "Specializations",
                            order = 1,
                        },

                        specsInfo = {
                            type = "description",
                            name = "There may be additional toggles or settings for your specialization(s).  Use the buttons below to jump to that section.",
                            order = 2,
                            fontSize = "medium",
                        },
                    },
                    hidden = function( info )
                        local hide = true

                        for i = 1, 4 do
                            local id, name, desc = GetSpecializationInfo( i )
                            if not id then break end

                            local sName = lower( name )

                            if db.plugins.specializations[ sName ] then
                                db.args.toggles.args.specLinks.args[ sName ] = db.args.toggles.args.specLinks.args[ sName ] or {
                                    type = "execute",
                                    name = name,
                                    desc = desc,
                                    order = 5 + i,
                                    func = function ()
                                        ACD:SelectGroup( "Hekili", sName )
                                    end,
                                }
                                hide = false
                            end
                        end

                        return hide
                    end,
                } ]]
            }
        }
    end
end


do
    -- Generate a spec skeleton.
    local listener = CreateFrame( "Frame" )
    Hekili:ProfileFrame( "SkeletonListener", listener )

    local indent = ""
    local output = {}

    local key = formatKey

    local function increaseIndent()
        indent = indent .. "    "
    end

    local function decreaseIndent()
        indent = indent:sub( 1, indent:len() - 4 )
    end

    local function append( s )
        insert( output, indent .. s )
    end

    local function appendAttr( t, s )
        if t[ s ] ~= nil then
            if type( t[ s ] ) == 'string' then
                insert( output, indent .. s .. ' = "' .. tostring( t[s] ) .. '",' )
            else
                insert( output, indent .. s .. ' = ' .. tostring( t[s] ) .. ',' )
            end
        end
    end

    local spec = ""
    local specID = 0

    local mastery_spell = 0

    local resources = {}
    local talents = {}
    local talentSpells = {}
    local pvptalents = {}
    local auras = {}
    local abilities = {}

    listener:RegisterEvent( "PLAYER_SPECIALIZATION_CHANGED" )
    listener:RegisterEvent( "PLAYER_ENTERING_WORLD" )
    listener:RegisterEvent( "UNIT_AURA" )
    listener:RegisterEvent( "SPELLS_CHANGED" )
    listener:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED" )
    listener:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )

    local applications = {}
    local removals = {}

    local lastAbility = nil
    local lastTime = 0

    local run = 0

    local function EmbedSpellData( spellID, token, talent, pvp )
        local name, _, texture, castTime, minRange, maxRange = GetSpellInfo( spellID )

        local haste = UnitSpellHaste( "player" )
        haste = 1 + ( haste / 100 )

        if name then
            token = token or key( name )

            if castTime % 10 ~= 0 then
                castTime = castTime * haste * 0.001
                castTime = tonumber( format( "%.2f", castTime ) )
            else
                castTime = castTime * 0.001
            end

            local cost, min_cost, max_cost, spendPerSec, cost_percent, resource

            local costs = GetSpellPowerCost( spellID )

            if costs then
                for k, v in pairs( costs ) do
                    if not v.hasRequiredAura or IsPlayerSpell( v.requiredAuraID ) then
                        cost = v.costPercent > 0 and v.costPercent / 100 or v.cost
                        spendPerSec = v.costPerSecond
                        resource = key( v.name )
                        break
                    end
                end
            end

            local passive = IsPassiveSpell( spellID )
            local harmful = IsHarmfulSpell( name )
            local helpful = IsHelpfulSpell( name )

            local _, charges, _, recharge = GetSpellCharges( spellID )
            local cooldown, gcd, icd
                cooldown, gcd = GetSpellBaseCooldown( spellID )
                if cooldown then cooldown = cooldown / 1000 end

            if gcd == 1000 then gcd = "totem"
            elseif gcd == 1500 then gcd = "spell"
            elseif gcd == 0 then gcd = "off"
            else
                icd = gcd / 1000
                gcd = "off"
            end

            if recharge and recharge > cooldown then
                if ( recharge * 1000 ) % 10 ~= 0 then
                    recharge = recharge * haste
                    recharge = tonumber( format( "%.2f", recharge ) )
                end
                cooldown = recharge
            end

            local selfbuff = SpellIsSelfBuff( spellID )
            talent = talent or IsTalentSpell( spellID )

            if selfbuff or passive then
                auras[ token ] = auras[ token ] or {}
                auras[ token ].id = spellID
            end

            local empowered = IsPressHoldReleaseSpell( spellID )
            -- SpellIsTargeting ?

            if not passive then
                local a = abilities[ token ] or {}

                -- a.key = token
                a.desc = GetSpellDescription( spellID ):gsub( "\r", " " ):gsub( "\n", " " ):gsub( "%s%s+", " " )
                a.id = spellID
                a.spend = cost
                a.spendType = resource
                a.spendPerSec = spendPerSec
                a.cast = castTime
                a.empowered = empowered
                a.gcd = gcd or "spell"
                a.icd = icd

                a.texture = texture

                if talent then a.talent = token end
                if pvp then a.pvptalent = token end

                a.startsCombat = harmful == true or helpful == false

                a.cooldown = cooldown
                a.charges = charges
                a.recharge = recharge

                abilities[ token ] = a
            end
        end
    end

    local function CLEU( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceName and UnitIsUnit( sourceName, "player" ) and type( spellName ) == 'string' then
            local now = GetTime()
            local token = key( spellName )

            if subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REFRESH" or
               subtype == "SPELL_PERIODIC_AURA_APPLIED" or subtype == "SPELL_PERIODIC_AURA_APPLIED_DOSE" or subtype == "SPELL_PERIODIC_AURA_REFRESH" then
                -- the last ability probably refreshed this aura.
                if lastAbility and now - lastTime < 0.25 then
                    -- Go ahead and attribute it to the last cast.
                    local a = abilities[ lastAbility ]

                    if a then
                        a.applies = a.applies or {}
                        a.applies[ token ] = spellID
                    end
                else
                    insert( applications, { s = token, i = spellID, t = now } )
                end
            elseif subtype == "SPELL_AURA_REMOVED" or subtype == "SPELL_AURA_REMOVED_DOSE" or subtype == "SPELL_AURA_REMOVED" or
                   subtype == "SPELL_PERIODIC_AURA_REMOVED" or subtype == "SPELL_PERIODIC_AURA_REMOVED_DOSE" or subtype == "SPELL_PERIODIC_AURA_BROKEN" then
                if lastAbility and now - lastTime < 0.25 then
                    -- Go ahead and attribute it to the last cast.
                    local a = abilities[ lastAbility ]

                    if a then
                        a.applies = a.applies or {}
                        a.applies[ token ] = spellID
                    end
                else
                    insert( removals, { s = token, i = spellID, t = now } )
                end
            end
        end
    end

    local function skeletonHandler( self, event, ... )
        local unit = select( 1, ... )

        if ( event == "PLAYER_SPECIALIZATION_CHANGED" and UnitIsUnit( unit, "player" ) ) or event == "PLAYER_ENTERING_WORLD" then
            local sID, s = GetSpecializationInfo( GetSpecialization() )
            if specID ~= sID then
                wipe( resources )
                wipe( auras )
                wipe( abilities )
            end
            specID = sID
            spec = s

            mastery_spell = GetSpecializationMasterySpells( GetSpecialization() )

            for k, i in pairs( Enum.PowerType ) do
                if k ~= "NumPowerTypes" and i >= 0 then
                    if UnitPowerMax( "player", i ) > 0 then resources[ k ] = i end
                end
            end

            wipe( talents )
            local configID = C_ClassTalents.GetActiveConfigID() or -1
            local configInfo = C_Traits.GetConfigInfo( configID )
            for _, treeID in ipairs( configInfo.treeIDs ) do
                local nodes = C_Traits.GetTreeNodes( treeID )
                for _, nodeID in ipairs( nodes ) do
                    local node = C_Traits.GetNodeInfo( configID, nodeID )

                    local isSpec = false
                    for _, cond in ipairs( node.conditionIDs ) do
                        local c = C_Traits.GetConditionInfo( configID, cond )
                        if c.specSetID then isSpec = true; break end
                    end

                    if node.maxRanks > 0 then
                        for _, entryID in ipairs( node.entryIDs ) do
                            local entryInfo = C_Traits.GetEntryInfo( configID, entryID )
                            local definitionInfo = C_Traits.GetDefinitionInfo( entryInfo.definitionID )

                            local spellID = definitionInfo.spellID
                            local name = definitionInfo.overrideName or GetSpellInfo( spellID )
                            local subtext = GetSpellSubtext( spellID )

                            if subtext then
                                local rank = subtext:match( "^Rank (%d+)$" )
                                if rank then name = name .. "_" .. rank end
                            end

                            local token = key( name )

                            insert( talents, { name = token, talent = nodeID, specialization = isSpec, definition = entryInfo.definitionID, spell = spellID, ranks = node.maxRanks } )

                            if not IsPassiveSpell( spellID ) then
                                EmbedSpellData( spellID, token, true )
                            end
                        end
                    end
                end
            end

            wipe( pvptalents )
            local row = C_SpecializationInfo.GetPvpTalentSlotInfo( 1 )

            for i, tID in ipairs( row.availableTalentIDs ) do
                local _, name, _, _, _, sID = GetPvpTalentInfoByID( tID )
                name = key( name )
                insert( pvptalents, { name = name, talent = tID, spell = sID } )

                if not IsPassiveSpell( sID ) then
                    EmbedSpellData( sID, name, nil, true )
                end
            end

            sort( pvptalents, function( a, b ) return a.name < b.name end )

            for i = 1, GetNumSpellTabs() do
                local tab, _, offset, n = GetSpellTabInfo( i )

                if i == 2 or tab == spec then
                    for j = offset + 1, offset + n do
                        local name, _, texture, castTime, minRange, maxRange, spellID = GetSpellInfo( j, "spell" )
                        if name then EmbedSpellData( spellID, key( name ) ) end
                    end
                end
            end
        elseif event == "SPELLS_CHANGED" then
            for i = 1, GetNumSpellTabs() do
                local tab, _, offset, n = GetSpellTabInfo( i )

                if i == 2 or tab == spec then
                    for j = offset + 1, offset + n do
                        local name, _, texture, castTime, minRange, maxRange, spellID = GetSpellInfo( j, "spell" )
                        if name then EmbedSpellData( spellID, key( name ) ) end
                    end
                end
            end
        elseif event == "UNIT_AURA" then
            if UnitIsUnit( unit, "player" ) or UnitCanAttack( "player", unit ) then
                for i = 1, 40 do
                    local name, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, _, castByPlayer = UnitBuff( unit, i, "PLAYER" )

                    if not name then break end

                    local token = key( name )

                    local a = auras[ token ] or {}

                    if duration == 0 then duration = 3600 end

                    a.id = spellID
                    a.duration = duration
                    a.type = debuffType
                    a.max_stack = max( a.max_stack or 1, count )

                    auras[ token ] = a
                end

                for i = 1, 40 do
                    local name, icon, count, debuffType, duration, expirationTime, caster, canStealOrPurge, _, spellID, canApplyAura, _, castByPlayer = UnitDebuff( unit, i, "PLAYER" )

                    if not name then break end

                    local token = key( name )

                    local a = auras[ token ] or {}

                    if duration == 0 then duration = 3600 end

                    a.id = spellID
                    a.duration = duration
                    a.type = debuffType
                    a.max_stack = max( a.max_stack or 1, count )

                    auras[ token ] = a
                end
            end

        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            if UnitIsUnit( "player", unit ) then
                local spellID = select( 3, ... )
                local token = spellID and class.abilities[ spellID ] and class.abilities[ spellID ].key

                local now = GetTime()

                if not token then return end

                lastAbility = token
                lastTime = now

                local a = abilities[ token ]

                if not a then
                    return
                end

                for k, v in pairs( applications ) do
                    if now - v.t < 0.5 then
                        a.applies = a.applies or {}
                        a.applies[ v.s ] = v.i
                    end
                    applications[ k ] = nil
                end

                for k, v in pairs( removals ) do
                    if now - v.t < 0.5 then
                        a.removes = a.removes or {}
                        a.removes[ v.s ] = v.i
                    end
                    removals[ k ] = nil
                end
            end
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            CLEU( event, CombatLogGetCurrentEventInfo() )
        end
    end

    function Hekili:StartListeningForSkeleton()
        -- listener:SetScript( "OnEvent", skeletonHandler )
        skeletonHandler( listener, "PLAYER_SPECIALIZATION_CHANGED", "player" )
        skeletonHandler( listener, "SPELLS_CHANGED" )
    end


    function Hekili:EmbedSkeletonOptions( db )
        db = db or self.Options
        if not db then return end

        db.args.skeleton = db.args.skeleton or {
            type = "group",
            name = "Skeleton",
            order = 100,
            args = {
                spooky = {
                    type = "input",
                    name = "Skeleton",
                    desc = "A rough skeleton of your current spec, for development purposes only.",
                    order = 1,
                    get = function( info )
                        return Hekili.Skeleton or ""
                    end,
                    multiline = 25,
                    width = "full"
                },
                regen = {
                    type = "execute",
                    name = "Generate Skeleton",
                    order = 2,
                    func = function()
                        skeletonHandler( listener, "PLAYER_SPECIALIZATION_CHANGED", "player" )
                        skeletonHandler( listener, "SPELLS_CHANGED" )

                        run = run + 1

                        indent = ""
                        wipe( output )

                        local playerClass = UnitClass( "player" ):gsub( " ", "" )
                        local playerSpec = select( 2, GetSpecializationInfo( GetSpecialization() ) ):gsub( " ", "" )

                        if run % 2 > 0 then
                            append( "-- " .. playerClass .. playerSpec .. ".lua\n-- " .. date( "%B %Y" ) .. "\n" )
                            append( [[if UnitClassBase( "player" ) ~= "]] .. UnitClassBase( "player" ) .. [[" then return end]] )

                            append( "\nlocal addon, ns = ...\nlocal Hekili = _G[ addon ]\nlocal class, state = Hekili.Class, Hekili.State\n" )

                            append( "local spec = Hekili:NewSpecialization( " .. specID .. " )\n" )

                            for k, i in pairs( resources ) do
                                append( "spec:RegisterResource( Enum.PowerType." .. k .. " )" )
                            end

                            append( "" )
                            append( "-- Talents" )
                            append( "spec:RegisterTalents( {" )
                            increaseIndent()
                            append( "-- " .. playerClass )

                            table.sort( talents, function( a, b )
                                if a.specialization ~= b.specialization then return b.specialization end
                                return a.name < b.name
                            end )

                            local max_talent_length = 10

                            for i, tal in ipairs( talents ) do
                                local chars = tal.name:len()
                                if chars > max_talent_length then max_talent_length = chars end
                            end

                            local formatStr = "%-" .. max_talent_length .. "s = { %5d, %-6d, %d }, -- %s"

                            local classes = true

                            for i, tal in ipairs( talents ) do
                                if classes and tal.specialization then
                                    classes = false
                                    append( "" )
                                    append( "-- " .. playerSpec )
                                end
                                local line = format( formatStr, tal.name, tal.talent, tal.spell, tal.ranks or 0, GetSpellDescription( tal.spell ):gsub( "\n", " " ):gsub( "\r", " " ):gsub( "%s%s+", " " ) )
                                append( line )
                            end

                            decreaseIndent()
                            append( "} )\n\n" )

                            append( "-- PvP Talents" )
                            append( "spec:RegisterPvpTalents( { " )
                            increaseIndent()

                            local max_pvptalent_length = 10
                            for i, tal in ipairs( pvptalents ) do
                                local chars = tal.name:len()
                                if chars > max_pvptalent_length then max_pvptalent_length = chars end
                            end

                            local formatPvp = "%-" .. max_pvptalent_length .. "s = %-4d, -- (%d) %s"

                            for i, tal in ipairs( pvptalents ) do
                                append( format( formatPvp, tal.name, tal.talent, tal.spell, GetSpellDescription( tal.spell ):gsub( "\n", " " ):gsub( "\r", " " ):gsub( "%s%s+", " " ) ) )
                            end
                            decreaseIndent()
                            append( "} )\n\n" )

                            append( "-- Auras" )
                            append( "spec:RegisterAuras( {" )
                            increaseIndent()

                            for k, aura in orderedPairs( auras ) do
                                if aura.desc then append( "-- " .. aura.desc ) end
                                append( k .. " = {" )
                                increaseIndent()
                                append( "id = " .. aura.id .. "," )

                                for key, value in pairs( aura ) do
                                    if key ~= "id" then
                                        if type(value) == 'string' then
                                            append( key .. ' = "' .. value .. '",' )
                                        else
                                            append( key .. " = " .. value .. "," )
                                        end
                                    end
                                end

                                decreaseIndent()
                                append( "}," )
                            end

                            decreaseIndent()
                            append( "} )\n\n" )


                            append( "-- Abilities" )
                            append( "spec:RegisterAbilities( {" )
                            increaseIndent()

                            local count = 1
                            for k, a in orderedPairs( abilities ) do
                                count = count + 1
                                if a.desc then append( "-- " .. a.desc ) end
                                append( k .. " = {" )
                                increaseIndent()
                                appendAttr( a, "id" )
                                appendAttr( a, "cast" )
                                appendAttr( a, "charges" )
                                appendAttr( a, "cooldown" )
                                appendAttr( a, "recharge" )
                                appendAttr( a, "gcd" )
                                if a.icd ~= nil then appendAttr( a, "icd" ) end
                                append( "" )
                                appendAttr( a, "spend" )
                                appendAttr( a, "spendPerSec" )
                                appendAttr( a, "spendType" )
                                if a.spend ~= nil or a.spendPerSec ~= nil or a.spendType ~= nil then
                                    append( "" )
                                end
                                appendAttr( a, "talent" )
                                appendAttr( a, "pvptalent" )
                                appendAttr( a, "startsCombat" )
                                appendAttr( a, "texture" )
                                append( "" )
                                if a.cooldown >= 60 then append( "toggle = \"cooldowns\",\n" ) end
                                append( "handler = function ()" )

                                if a.applies or a.removes then
                                    increaseIndent()
                                    if a.applies then
                                        for name, id in pairs( a.applies ) do
                                            append( "-- applies " .. name .. " (" .. id .. ")" )
                                        end
                                    end
                                    if a.removes then
                                        for name, id in pairs( a.removes ) do
                                            append( "-- removes " .. name .. " (" .. id .. ")" )
                                        end
                                    end
                                    decreaseIndent()
                                end
                                append( "end," )
                                decreaseIndent()
                                append( "}," )
                            end

                            decreaseIndent()
                            append( "} )" )

                            append( "\nspec:RegisterPriority( \"" .. playerSpec .. "\", " .. date( "%Y%m%d" ) .. ",\n-- Notes\n" ..
                                "[[\n\n" ..
                                "]],\n-- Priority\n" ..
                                "[[\n\n" ..
                                "]] )" )
                        else
                            local aggregate = {}

                            for k,v in pairs( auras ) do
                                if not aggregate[k] then aggregate[k] = {} end
                                aggregate[k].id = v.id
                                aggregate[k].aura = true
                            end

                            for k,v in pairs( abilities ) do
                                if not aggregate[k] then aggregate[k] = {} end
                                aggregate[k].id = v.id
                                aggregate[k].ability = true
                            end

                            for k,v in pairs( talents ) do
                                if not aggregate[v.name] then aggregate[v.name] = {} end
                                aggregate[v.name].id = v.spell
                                aggregate[v.name].talent = true
                            end

                            for k,v in pairs( pvptalents ) do
                                if not aggregate[v.name] then aggregate[v.name] = {} end
                                aggregate[v.name].id = v.spell
                                aggregate[v.name].pvptalent = true
                            end

                            -- append( select( 2, GetSpecializationInfo(GetSpecialization())) .. "\nKey\tID\tIs Aura\tIs Ability\tIs Talent\tIs PvP" )
                            for k,v in orderedPairs( aggregate ) do
                                if v.id then
                                    append( k .. "\t" .. v.id .. "\t" .. ( v.aura and "Yes" or "No" ) .. "\t" .. ( v.ability and "Yes" or "No" ) .. "\t" .. ( v.talent and "Yes" or "No" ) .. "\t" .. ( v.pvptalent and "Yes" or "No" ) .. "\t" .. ( v.desc or GetSpellDescription( v.id ) or "" ):gsub( "\r", " " ):gsub( "\n", " " ):gsub( "%s%s+", " " ) )
                                end
                            end
                        end

                        Hekili.Skeleton = table.concat( output, "\n" )
                    end,
                }
            },
            hidden = function()
                return not Hekili.Skeleton
            end,
        }

    end
end


do
    local selectedError = nil
    local errList = {}

    function Hekili:EmbedErrorOptions( db )
        db = db or self.Options
        if not db then return end

        db.args.errors = {
            type = "group",
            name = "Warnings",
            order = 99,
            args = {
                errName = {
                    type = "select",
                    name = "Warning Identifier",
                    width = "full",
                    order = 1,

                    values = function()
                        wipe( errList )

                        for i, err in ipairs( self.ErrorKeys ) do
                            local eInfo = self.ErrorDB[ err ]

                            errList[ i ] = "[" .. eInfo.last .. " (" .. eInfo.n .. "x)] " .. err
                        end

                        return errList
                    end,

                    get = function() return selectedError end,
                    set = function( info, val ) selectedError = val end,
                },

                errorInfo = {
                    type = "input",
                    name = "Warning Information",
                    width = "full",
                    multiline = 10,
                    order = 2,

                    get = function ()
                        if selectedError == nil then return "" end
                        return Hekili.ErrorKeys[ selectedError ]
                    end,

                    dialogControl = "HekiliCustomEditor",
                }
            },
            disabled = function() return #self.ErrorKeys == 0 end,
        }
    end
end


function Hekili:GenerateProfile()
    local s = state

    local spec = s.spec.key

    local talents = Hekili.CurrentTalentExport

    for k, v in orderedPairs( s.talent ) do
        if v.enabled then
            if talents then talents = format( "%s\n    %s = %d/%d", talents, k, v.rank, v.max )
            else talents = k end
        end
    end

    local pvptalents
    for k,v in orderedPairs( s.pvptalent ) do
        if v.enabled then
            if pvptalents then pvptalents = format( "%s\n   %s", pvptalents, k )
            else pvptalents = k end
        end
    end

    local covenants = { "kyrian", "necrolord", "night_fae", "venthyr" }
    local covenant = "none"
    for i, v in ipairs( covenants ) do
        if state.covenant[ v ] then covenant = v; break end
    end

    local conduits
    for k,v in orderedPairs( s.conduit ) do
        if v.enabled then
            if conduits then conduits = format( "%s\n   %s = %d", conduits, k, v.rank )
            else conduits = format( "%s = %d", k, v.rank ) end
        end
    end

    local soulbinds

    local activeBind = C_Soulbinds.GetActiveSoulbindID()
    if activeBind then
        soulbinds = "[" .. formatKey( C_Soulbinds.GetSoulbindData( activeBind ).name ) .. "]"
    end

    for k,v in orderedPairs( s.soulbind ) do
        if v.enabled then
            if soulbinds then soulbinds = format( "%s\n   %s = %d", soulbinds, k, v.rank )
            else soulbinds = format( "%s = %d", k, v.rank ) end
        end
    end

    local sets
    for k, v in orderedPairs( class.gear ) do
        if s.set_bonus[ k ] > 0 then
            if sets then sets = format( "%s\n    %s = %d", sets, k, s.set_bonus[k] )
            else sets = format( "%s = %d", k, s.set_bonus[k] ) end
        end
    end

    local gear, items
    for k, v in orderedPairs( state.set_bonus ) do
        if v > 0 then
            if type(k) == 'string' then
            if gear then gear = format( "%s\n    %s = %d", gear, k, v )
            else gear = format( "%s = %d", k, v ) end
            elseif type(k) == 'number' then
                if items then items = format( "%s, %d", items, k )
                else items = tostring(k) end
            end
        end
    end

    local legendaries
    for k, v in orderedPairs( state.legendary ) do
        if k ~= "no_trait" and v.rank > 0 then
            if legendaries then legendaries = format( "%s\n    %s = %d", legendaries, k, v.rank )
            else legendaries = format( "%s = %d", k, v.rank ) end
        end
    end

    local settings
    if state.settings.spec then
        for k, v in orderedPairs( state.settings.spec ) do
            if type( v ) ~= "table" then
                if settings then settings = format( "%s\n    %s = %s", settings, k, tostring( v ) )
                else settings = format( "%s = %s", k, tostring( v ) ) end
            end
        end
        for k, v in orderedPairs( state.settings.spec.settings ) do
            if type( v ) ~= "table" then
                if settings then settings = format( "%s\n    %s = %s", settings, k, tostring( v ) )
                else settings = format( "%s = %s", k, tostring( v ) ) end
            end
        end
    end

    local toggles
    for k, v in orderedPairs( self.DB.profile.toggles ) do
        if type( v ) == "table" and rawget( v, "value" ) ~= nil then
            if toggles then toggles = format( "%s\n    %s = %s %s", toggles, k, tostring( v.value ), ( v.separate and "[separate]" or ( k ~= "cooldowns" and v.override and self.DB.profile.toggles.cooldowns.value and "[overridden]" ) or "" ) )
            else toggles = format( "%s = %s %s", k, tostring( v.value ), ( v.separate and "[separate]" or ( k ~= "cooldowns" and v.override and self.DB.profile.toggles.cooldowns.value and "[overridden]" ) or "" ) ) end
        end
    end

    local keybinds = ""
    local bindLength = 1

    for name in pairs( Hekili.KeybindInfo ) do
        if name:len() > bindLength then
            bindLength = name:len()
        end
    end

    for name, data in orderedPairs( Hekili.KeybindInfo ) do
        local action = format( "%-" .. bindLength .. "s =", name )
        local count = 0
        for i = 1, 12 do
            local bar = data.upper[ i ]
            if bar then
                if count > 0 then action = action .. "," end
                action = format( "%s %-4s[%02d]", action, bar, i )
                count = count + 1
            end
        end
        keybinds = keybinds .. "\n    " .. action
    end


    local warnings

    for i, err in ipairs( Hekili.ErrorKeys ) do
        if warnings then warnings = format( "%s\n[#%d] %s", warnings, i, err:gsub( "\n\n", "\n" ) )
        else warnings = format( "[#%d] %s", i, err:gsub( "\n\n", "\n" ) ) end
    end


    return format( "build: %s\n" ..
        "level: %d (%d)\n" ..
        "class: %s\n" ..
        "spec: %s\n\n" ..
        "talents: %s\n\n" ..
        "pvptalents: %s\n\n" ..
        "covenant: %s\n\n" ..
        "conduits: %s\n\n" ..
        "soulbinds: %s\n\n" ..
        "sets: %s\n\n" ..
        "gear: %s\n\n" ..
        "legendaries: %s\n\n" ..
        "itemIDs: %s\n\n" ..
        "settings: %s\n\n" ..
        "toggles: %s\n\n" ..
        "keybinds: %s\n\n" ..
        "warnings: %s\n\n",
        Hekili.Version or "no info",
        UnitLevel( 'player' ) or 0, UnitEffectiveLevel( 'player' ) or 0,
        class.file or "NONE",
        spec or "none",
        talents or "none",
        pvptalents or "none",
        covenant or "none",
        conduits or "none",
        soulbinds or "none",
        sets or "none",
        gear or "none",
        legendaries or "none",
        items or "none",
        settings or "none",
        toggles or "none",
        keybinds or "none",
        warnings or "none" )
end


do
    local Options = {
        name = "Hekili " .. Hekili.Version,
        type = "group",
        handler = Hekili,
        get = 'GetOption',
        set = 'SetOption',
        childGroups = "tree",
        args = {
            general = {
                type = "group",
                name = "General",
                order = 10,
                childGroups = "tab",
                args = {
                    enabled = {
                        type = "toggle",
                        name = "Enabled",
                        desc = "Enables or disables the addon.",
                        order = 1
                    },

                    minimapIcon = {
                        type = "toggle",
                        name = "Hide Minimap Icon",
                        desc = "If checked, the minimap icon will be hidden.",
                        order = 2,
                    },

                    monitorPerformance = {
                        type = "toggle",
                        name = BlizzBlue .. "Monitor Performance|r",
                        desc = "If checked, the addon will track processing time and volume of events.",
                        order = 3,
                        hidden = function()
                            return not Hekili.Version:match("Dev")
                        end,
                    },

                    welcome = {
                        type = 'description',
                        name = "",
                        fontSize = "medium",
                        image = "Interface\\Addons\\Hekili\\Textures\\Taco256",
                        imageWidth = 96,
                        imageHeight = 96,
                        order = 5,
                        width = "full"
                    },

                    supporters = {
                        type = "description",
                        name = function ()
                            return "|cFF00CCFFTHANK YOU TO OUR SUPPORTERS!|r\n\n" .. ns.Patrons .. ".\n\n" ..
                                "Please see the |cFFFFD100Issue Reporting|r tab for information about reporting bugs.\n\n"
                        end,
                        fontSize = "medium",
                        order = 6,
                        width = "full"
                    },

                    curse = {
                        type = "input",
                        name = "Curse",
                        order = 10,
                        get = function () return "https://www.curseforge.com/wow/addons/hekili" end,
                        set = function () end,
                        width = "full",
                        dialogControl = "SFX-Info-URL",
                    },

                    github = {
                        type = "input",
                        name = "GitHub",
                        order = 11,
                        get = function () return "https://github.com/Hekili/hekili/" end,
                        set = function () end,
                        width = "full",
                        dialogControl = "SFX-Info-URL",
                    },

                    simulationcraft = {
                        type = "input",
                        name = "SimC",
                        order = 12,
                        get = function () return "https://github.com/simulationcraft/simc/wiki" end,
                        set = function () end,
                        width = "full",
                        dialogControl = "SFX-Info-URL",
                    }
                }
            },


            --[[ gettingStarted = {
                type = "group",
                name = "Getting Started",
                order = 11,
                childGroups = "tree",
                args = {
                    q1 = {
                        type = "header",
                        name = "Moving the Displays",
                        order = 1,
                        width = "full"
                    },
                    a1 = {
                        type = "description",
                        name = "When these options are open, all displays are visible and can be moved by clicking and dragging.  You can move this options screen out of the way by clicking the |cFFFFD100Hekili|r title and dragging it out of the way.\n\n" ..
                            "You can also set precise X/Y positioning in the |cFFFFD100Displays|r section, on each display's |cFFFFD100Main|r tab.\n\n" ..
                            "You can also move the displays by typing |cFFFFD100/hek move|r in chat.  Type |cFFFFD100/hek move|r again to lock the displays.\n",
                        order = 1.1,
                        width = "full",
                    },

                    q2 = {
                        type = "header",
                        name = "Using Toggles",
                        order = 2,
                        width = "full",
                    },
                    a2 = {
                        type = "description",
                        name = "The addon has several |cFFFFD100Toggles|r available that help you control the type of recommendations you receive while in combat.  See the |cFFFFD100Toggles|r section for specifics.\n\n" ..
                            "|cFFFFD100Mode|r:  By default, |cFFFFD100Automatic Mode|r automatically detects how many targets you are engaged with, and gives recommendations based on the number of targets detected.  In some circumstances, you may want the addon to pretend there is only 1 target, or that there are multiple targets, " ..
                            "or show recommendations for both scenarios.  You can use the |cFFFFD100Mode|r toggle to swap between Automatic, Single-Target, AOE, and Reactive modes.\n\n" ..
                            "|cFFFFD100Abilities|r:  Some of your abilities can be controlled by specific toggles.  For example, your major DPS cooldowns are assigned to the |cFFFFD100Cooldowns|r toggle.  This feature allows you to enable/disable these abilities in combat by using the assigned keybinding.  You can add abilities to (or remove abilities from) " ..
                            "these toggles in the |cFFFFD100Abilities|r or |cFFFFD100Gear and Trinkets|r sections.  When removed from a toggle, an ability can be recommended at any time, regardless of whether that toggle is on or off.\n\n" ..
                            "|cFFFFD100Displays|r:  Your Interrupts, Defensives, and Cooldowns toggles have a special relationship with the displays of the same names.  If |cFFFFD100Show Separately|r is checked for that toggle, those abilities will show in that toggle's display instead of the |cFFFFD100Primary|r or |cFFFFD100AOE|r display.\n",
                        order = 2.1,
                        width = "full",
                    },

                    q3 = {
                        type = "header",
                        name = "Importing a Profile",
                        order = 3,
                        width = "full",
                    },
                    a3 = {
                        type = "description",
                        name = "|cFFFF0000You do not need to import a SimulationCraft profile to use this addon.|r\n\n" ..
                            "Before trying to import a profile, please consider the following:\n\n" ..
                            " - SimulationCraft action lists tend not to change significantly for individual characters.  The profiles are written to include conditions that work for all gear, talent, and other factors combined.\n\n" ..
                            " - Most SimulationCraft action lists require some additional customization to work with the addon.  For example, |cFFFFD100target_if|r conditions don't translate directly to the addon and have to be rewritten.\n\n" ..
                            " - Some SimulationCraft action profiles are revised for the addon to be more efficient and use less processing time.\n\n" ..
                            "The default priorities included within the addon are kept up to date, are compatible with your character, and do not require additional changes.  |cFFFF0000No support is offered for custom or imported priorities from elsewhere.|r\n",
                        order = 3.1,
                        width = "full",
                    },

                    q4 = {
                        type = "header",
                        name = "Something's Wrong",
                        order = 4,
                        width = "full",
                    },
                    a4 = {
                        type = "description",
                        name = "You can submit questions, concerns, and ideas via the link found in the |cFFFFD100Issue Reporting|r section.\n\n" ..
                            "If you disagree with the addon's recommendations, the |cFFFFD100Snapshot|r feature allows you to capture a log of the addon's decision-making taken at the exact moment specific recommendations are shown.  " ..
                            "When you submit your question, be sure to take a snapshot (not a screenshot!), place the text on Pastebin, and include the link when you submit your issue ticket.",
                        order = 4.1,
                        width = "full",
                    }
                }
            }, ]]

            abilities = {
                type = "group",
                name = "Abilities",
                order = 80,
                childGroups = "select",
                args = {
                    spec = {
                        type = "select",
                        name = "Specialization",
                        desc = "These options apply to your selected specialization.",
                        order = 0.1,
                        width = "full",
                        set = SetCurrentSpec,
                        get = GetCurrentSpec,
                        values = GetCurrentSpecList,
                    },
                },
                plugins = {
                    actions = {}
                }
            },

            items = {
                type = "group",
                name = "Gear and Items",
                order = 81,
                childGroups = "select",
                args = {
                    spec = {
                        type = "select",
                        name = "Specialization",
                        desc = "These options apply to your selected specialization.",
                        order = 0.1,
                        width = "full",
                        set = SetCurrentSpec,
                        get = GetCurrentSpec,
                        values = GetCurrentSpecList,
                    },
                },
                plugins = {
                    equipment = {}
                }
            },

            issues = {
                type = "group",
                name = "Issue Reporting",
                order = 85,
                args = {
                    header = {
                        type = "description",
                        name = "If you are having a technical issue with the addon, please submit an issue report via the link below.  When submitting your report, please include the information " ..
                            "below (specialization, talents, traits, gear), which can be copied and pasted for your convenience.  If you have a concern about the addon's recommendations, it is preferred " ..
                            "that you provide a Snapshot (which will include this information) instead.",
                        order = 10,
                        fontSize = "medium",
                        width = "full",
                    },
                    profile = {
                        type = "input",
                        name = "Character Data",
                        order = 20,
                        width = "full",
                        multiline = 10,
                        get = 'GenerateProfile',
                        set = function () end,
                    },
                    link = {
                        type = "input",
                        name = "Link",
                        order = 30,
                        width = "full",
                        get = function() return "http://github.com/Hekili/hekili/issues" end,
                        set = function() end,
                        dialogControl = "SFX-Info-URL"
                    },
                }
            },

            snapshots = {
                type = "group",
                name = "Snapshots",
                order = 86,
                args = {
                    autoSnapshot = {
                        type = "toggle",
                        name = "Auto Snapshot",
                        desc = "If checked, the addon will automatically create a snapshot whenever it failed to generate a recommendation.\n\n" ..
                            "This automatic snapshot can only occur once per episode of combat.",
                        order = 1,
                        width = "full",
                    },

                    screenshot = {
                        type = "toggle",
                        name = "Take Screenshot",
                        desc = "If checked, the addon will take a screenshot when you manually create a snapshot.\n\n" ..
                            "Submitting both with your issue tickets will provide useful information for investigation purposes.",
                        order = 2,
                        width = "full",
                    },

                    prefHeader = {
                        type = "header",
                        name = "Snapshots / Troubleshooting",
                        order = 2.5,
                        width = "full"
                    },

                    header = {
                        type = "description",
                        name = function()
                            return "Snapshots are logs of the addon's decision-making process for a set of recommendations.  If you have questions about -- or disagree with -- the addon's recommendations, " ..
                            "reviewing a snapshot can help identify what factors led to the specific recommendations that you saw.\n\n" ..
                            "Snapshots only capture a specific point in time, so snapshots have to be taken at the time you saw the specific recommendations that you are concerned about.  You can generate " ..
                            "snapshots by using the |cffffd100Snapshot|r binding ( |cffffd100" .. ( Hekili.DB.profile.toggles.snapshot.key or "NOT BOUND" ) .. "|r ) from the Toggles section.\n\n" ..
                            "You can also freeze the addon's recommendations using the |cffffd100Pause|r binding ( |cffffd100" .. ( Hekili.DB.profile.toggles.pause.key or "NOT BOUND" ) .. "|r ).  Doing so will freeze the addon's recommendations, allowing you to mouseover the display " ..
                            "and see which conditions were met to display those recommendations.  Press Pause again to unfreeze the addon.\n\n" ..
                            "Finally, using the settings at the bottom of this panel, you can ask the addon to automatically generate a snapshot for you when no recommendations were able to be made.\n\n"
                        end,
                        fontSize = "medium",
                        order = 10,
                        width = "full",
                    },

                    SnapID = {
                        type = "select",
                        name = "Select Snapshot",
                        desc = "Select a Snapshot to export.",
                        values = function( info )
                            if #ns.snapshots == 0 then
                                snapshots.snaps[ 0 ] = "No snapshots have been generated."
                            else
                                snapshots.snaps[ 0 ] = nil
                                for i, snapshot in ipairs( ns.snapshots ) do
                                    snapshots.snaps[ i ] = "|cFFFFD100" .. i .. ".|r " .. snapshot.header
                                end
                            end

                            return snapshots.snaps
                        end,
                        set = function( info, val )
                            snapshots.selected = val
                        end,
                        get = function( info )
                            return snapshots.selected
                        end,
                        order = 12,
                        width = "full",
                        disabled = function() return #ns.snapshots == 0 end,
                    },

                    Snapshot = {
                        type = 'input',
                        name = "Export Snapshot",
                        desc = "Click here and press CTRL+A, CTRL+C to copy the snapshot.\n\nPaste in a text editor to review or upload to Pastebin to support an issue ticket.",
                        order = 20,
                        get = function( info )
                            if snapshots.selected == 0 then return "" end
                            return ns.snapshots[ snapshots.selected ].log
                        end,
                        set = function() end,
                        width = "full",
                        hidden = function() return snapshots.selected == 0 or #ns.snapshots == 0 end,
                    },
                }
            },
        },

        plugins = {
            specializations = {},
        }
    }

    function Hekili:GetOptions()
        self:EmbedToggleOptions( Options )

        --[[ self:EmbedDisplayOptions( Options )

        self:EmbedPackOptions( Options )

        self:EmbedAbilityOptions( Options )

        self:EmbedItemOptions( Options )

        self:EmbedSpecOptions( Options ) ]]

        self:EmbedSkeletonOptions( Options )

        self:EmbedErrorOptions( Options )

        Hekili.OptionsReady = false

        return Options
    end
end


function Hekili:TotalRefresh( noOptions )
    if Hekili.PLAYER_ENTERING_WORLD then
        self:SpecializationChanged()
        self:RestoreDefaults()
    end

    for i, queue in pairs( ns.queue ) do
        for j, _ in pairs( queue ) do
            ns.queue[ i ][ j ] = nil
        end
        ns.queue[ i ] = nil
    end

    callHook( "onInitialize" )

    for specID, spec in pairs( class.specs ) do
        if specID > 0 then
            local options = self.DB.profile.specs[ specID ]

            for k, v in pairs( spec.options ) do
                if rawget( options, k ) == nil then options[ k ] = v end
            end
        end
    end

    self:RunOneTimeFixes()
    ns.checkImports()

    -- self:LoadScripts()
    if Hekili.OptionsReady then
        if Hekili.Config then
            self:RefreshOptions()
            ACD:SelectGroup( "Hekili", "profiles" )
        else Hekili.OptionsReady = false end
    end
    self:UpdateDisplayVisibility()
    self:BuildUI()

    self:OverrideBinds()

    if WeakAuras and WeakAuras.ScanEvents then
        for name, toggle in pairs( Hekili.DB.profile.toggles ) do
            WeakAuras.ScanEvents( "HEKILI_TOGGLE", name, toggle.value )
        end
    end

    if ns.UI.Minimap then ns.UI.Minimap:RefreshDataText() end
end


function Hekili:RefreshOptions()
    if not self.Options then return end

    self:EmbedDisplayOptions()
    self:EmbedPackOptions()
    self:EmbedSpecOptions()
    self:EmbedAbilityOptions()
    self:EmbedItemOptions()

    Hekili.OptionsReady = true

    -- Until I feel like making this better at managing memory.
    collectgarbage()
end


function Hekili:GetOption( info, input )
    local category, depth, option = info[1], #info, info[#info]
    local profile = Hekili.DB.profile

    if category == 'general' then
        return profile[ option ]

    elseif category == 'bindings' then

        if option:match( "TOGGLE" ) or option == "HEKILI_SNAPSHOT" then
            return select( 1, GetBindingKey( option ) )

        elseif option == 'Pause' then
            return self.Pause

        else
            return profile[ option ]

        end

    elseif category == 'displays' then

        -- This is a generic display option/function.
        if depth == 2 then
            return nil

            -- This is a display (or a hook).
        else
            local dispKey, dispID = info[2], tonumber( match( info[2], "^D(%d+)" ) )
            local hookKey, hookID = info[3], tonumber( match( info[3] or "", "^P(%d+)" ) )
            local display = profile.displays[ dispID ]

            -- This is a specific display's settings.
            if depth == 3 or not hookID then

                if option == 'x' or option == 'y' then
                    return tostring( display[ option ] )

                elseif option == 'spellFlashColor' or option == 'iconBorderColor' then
                    if type( display[option] ) ~= 'table' then display[option] = { r = 1, g = 1, b = 1, a = 1 } end
                    return display[option].r, display[option].g, display[option].b, display[option].a

                elseif option == 'Copy To' or option == 'Import' then
                    return nil

                else
                    return display[ option ]

                end

                -- This is a priority hook.
            else
                local hook = display.Queues[ hookID ]

                if option == 'Move' then
                    return hookID

                else
                    return hook[ option ]

                end

            end

        end

    elseif category == 'actionLists' then

        -- This is a general action list option.
        if depth == 2 then
            return nil

        else
            local listKey, listID = info[2], tonumber( match( info[2], "^L(%d+)" ) )
            local actKey, actID = info[3], tonumber( match( info[3], "^A(%d+)" ) )
            local list = listID and profile.actionLists[ listID ]

            -- This is a specific action list.
            if depth == 3 or not actID then
                return list[ option ]

                -- This is a specific action.
            elseif listID and actID then
                local action = list.Actions[ actID ]

                if option == 'ConsumableArgs' then option = 'Args' end

                if option == 'Move' then
                    return actID

                else
                    return action[ option ]

                end

            end

        end

    elseif category == "snapshots" then
        return profile[ option ]
    end

    ns.Error( "GetOption() - should never see." )

end


local getUniqueName = function( category, name )
    local numChecked, suffix, original = 0, 1, name

    while numChecked < #category do
        for i, instance in ipairs( category ) do
            if name == instance.Name then
                name = original .. ' (' .. suffix .. ')'
                suffix = suffix + 1
                numChecked = 0
            else
                numChecked = numChecked + 1
            end
        end
    end

    return name
end


function Hekili:SetOption( info, input, ... )
    local category, depth, option = info[1], #info, info[#info]
    local Rebuild, RebuildUI, RebuildScripts, RebuildOptions, RebuildCache, Select
    local profile = Hekili.DB.profile

    if category == 'general' then
        -- We'll preset the option here; works for most options.
        profile[ option ] = input

        if option == 'enabled' then
            if input then
                self:Enable()
                ACD:SelectGroup( "Hekili", "general" )
            else self:Disable() end

            self:UpdateDisplayVisibility()

            return

        elseif option == 'minimapIcon' then
            profile.iconStore.hide = input
            if input then
                LDBIcon:Hide( "Hekili" )
            else
                LDBIcon:Show( "Hekili" )
            end
        end

        -- General options do not need add'l handling.
        return

    elseif category == "snapshots" then
        profile[ option ] = input
    end

    if Rebuild then
        ns.refreshOptions()
        ns.loadScripts()
        QueueRebuildUI()
    else
        if RebuildOptions then ns.refreshOptions() end
        if RebuildScripts then ns.loadScripts() end
        if RebuildCache and not RebuildUI then self:UpdateDisplayVisibility() end
        if RebuildUI then QueueRebuildUI() end
    end

    if ns.UI.Minimap then ns.UI.Minimap:RefreshDataText() end

    if Select then
        ACD:SelectGroup( "Hekili", category, info[2], Select )
    end
end


do
    local validCommands = {
        makedefaults = true,
        import = true,
        skeleton = true,
        recover = true,
        center = true,

        profile = true,
        set = true,
        enable = true,
        disable = true,
        move = true,
        unlock = true,
        lock = true,
        dotinfo = true,
    }

    local toggleToIndex = {
        cooldowns = 51,
        interrupts = 52,
        potions = 53,
        defensives = 54,
        covenants = 55,
        custom1 = 56,
        custom2 = 57,
    }

    local indexToToggle = {
        [51] = { "cooldowns", "Cooldowns" },
        [52] = { "interrupts", "Interrupts" },
        [53] = { "potions", "Potions" },
        [54] = { "defensives", "Defensives" },
        [55] = { "essences", "Covenants" },
        [56] = { "custom1", "Custom #1" },
        [57] = { "custom2", "Custom #2" },
    }

    local toggleInstructions = {
        "on|r (to enable)",
        "off|r (to disable)",
        "|r (to toggle)",
    }

    local info = {}
    local priorities = {}

    local function countPriorities()
        wipe( priorities )

        local spec = state.spec.id

        for priority, data in pairs( Hekili.DB.profile.packs ) do
            if data.spec == spec then
                insert( priorities, priority )
            end
        end

        sort( priorities )

        return #priorities
    end

    function Hekili:CmdLine( input )
        if not input or input:trim() == "" or input:trim() == "skeleton" then
            if input:trim() == 'skeleton' then
                self:StartListeningForSkeleton()
                self:Print( "Addon will now gather specialization information.  Select all talents and use all abilities for best results." )
                self:Print( "See the Skeleton tab for more information. ")
                Hekili.Skeleton = ""
            end

            ns.StartConfiguration()
            return

        elseif input:trim() == "recover" then
            local defaults = self:GetDefaults()

            for k, v in pairs( self.DB.profile.displays ) do
                local default = defaults.profile.displays[ k ]
                if defaults.profile.displays[ k ] then
                    for key, value in pairs( default ) do
                        if type( value ) == "table" then v[ key ] = tableCopy( value )
                        else v[ key ] = value end

                        if type( value ) == "table" then
                            for innerKey, innerValue in pairs( value ) do
                                if v[ key ][ innerKey ] == nil then
                                    if type( innerValue ) == "table" then v[ key ][ innerKey ] = tableCopy( innerValue )
                                    else v[ key ][ innerKey ] = innerValue end
                                end
                            end
                        end
                    end

                    for key, value in pairs( self.DB.profile.displays["**"] ) do
                        if type( value ) == "table" then v[ key ] = tableCopy( value )
                        else v[ key ] = value end

                        if type( value ) == "table" then
                            for innerKey, innerValue in pairs( value ) do
                                if v[ key ][ innerKey ] == nil then
                                    if type( innerValue ) == "table" then v[ key ][ innerKey ] = tableCopy( innerValue )
                                    else v[ key ][ innerKey ] = innerValue end
                                end
                            end
                        end
                    end
                end
            end
            self:RestoreDefaults()
            self:RefreshOptions()
            self:BuildUI()
            self:Print( "Default displays and action lists restored." )
            return

        end

        if input then
            input = input:trim()
            local args = {}

            for arg in string.gmatch( input, "%S+" ) do
                insert( args, lower( arg ) )
            end

            if ( "set" ):match( "^" .. args[1] ) then
                local profile = Hekili.DB.profile
                local spec = profile.specs[ state.spec.id ]
                local prefs = spec.settings
                local settings = class.specs[ state.spec.id ].settings

                local index

                if args[2] then
                    if ( "target_swap" ):match( "^" .. args[2] ) or ( "swap" ):match( "^" .. args[2] ) or ( "cycle" ):match( "^" .. args[2] ) then
                        index = -1
                    elseif ( "mode" ):match( "^" .. args[2] ) then
                        index = -2
                    elseif ( "priority" ):match( "^" .. args[2] ) then
                        index = -3
                    else
                        for i, setting in ipairs( settings ) do
                            if setting.name:match( "^" .. args[2] ) then
                                index = i
                                break
                            end
                        end

                        if not index then
                            -- Check toggles instead.
                            for toggle, num in pairs( toggleToIndex ) do
                                if toggle:match( "^" .. args[2] ) then
                                    index = num
                                    break
                                end
                            end
                        end
                    end
                end

                if #args == 1 or not index then
                    -- No arguments, list options.
                    local output = "Use |cFFFFD100/hekili set|r to adjust your specialization options via chat or macros.\n\nOptions for " .. state.spec.name .. " are:"

                    local hasToggle, hasNumber = false, false
                    local exToggle, exNumber

                    for i, setting in ipairs( settings ) do
                        if not setting.info.arg or setting.info.arg() then
                            if setting.info.type == "toggle" then
                                output = format( "%s\n - |cFFFFD100%s|r = %s|r (%s)", output, setting.name, prefs[ setting.name ] and "|cFF00FF00ON" or "|cFFFF0000OFF", setting.info.name )
                                hasToggle = true
                                exToggle = setting.name
                            elseif setting.info.type == "range" then
                                output = format( "%s\n - |cFFFFD100%s|r = |cFF00FF00%.2f|r, min: %.2f, max: %.2f (%s)", output, setting.name, prefs[ setting.name ], ( setting.info.min and format( "%.2f", setting.info.min ) or "N/A" ), ( setting.info.max and format( "%.2f", setting.info.max ) or "N/A" ), setting.info.name )
                                hasNumber = true
                                exNumber = setting.name
                            end
                        end
                    end

                    output = format( "%s\n - |cFFFFD100cycle|r, |cFFFFD100swap|r, or |cFFFFD100target_swap|r = %s|r (%s)", output, spec.cycle and "|cFF00FF00ON" or "|cFFFF0000OFF", "Recommend Target Swaps" )

                    output = format( "%s\n\nTo control your toggles (|cFFFFD100cooldowns|r, |cFFFFD100covenants|r, |cFFFFD100defensives|r, |cFFFFD100interrupts|r, |cFFFFD100potions|r, |cFFFFD100custom1|r, and |cFFFFD100custom2|r):\n" ..
                        " - Enable Cooldowns:  |cFFFFD100/hek set cooldowns on|r\n" ..
                        " - Disable Interrupts:  |cFFFFD100/hek set interupts off|r\n" ..
                        " - Toggle Defensives:  |cFFFFD100/hek set defensives|r", output )

                    output = format( "%s\n\nTo control your display mode (currently |cFFFFD100%s|r):\n - Toggle Mode:  |cFFFFD100/hek set mode|r\n - Set Mode:  |cFFFFD100/hek set mode aoe|r (or |cFFFFD100automatic|r, |cFFFFD100single|r, |cFFFFD100dual|r, |cFFFFD100reactive|r)", output, self.DB.profile.toggles.mode.value or "unknown" )

                    if hasToggle then
                        output = format( "%s\n\nTo set a |cFFFFD100specialization toggle|r, use the following commands:\n" ..
                            " - Toggle On/Off:  |cFFFFD100/hek set %s|r\n" ..
                            " - Enable:  |cFFFFD100/hek set %s on|r\n" ..
                            " - Disable:  |cFFFFD100/hek set %s off|r\n" ..
                            " - Reset to Default:  |cFFFFD100/hek set %s default|r", output, exToggle, exToggle, exToggle, exToggle )
                    end

                    if hasNumber then
                        output = format( "%s\n\nTo set a |cFFFFD100number|r value, use the following commands:\n" ..
                            " - Set to #:  |cFFFFD100/hek set %s #|r\n" ..
                            " - Reset to Default:  |cFFFFD100/hek set %s default|r", output, exNumber, exNumber )
                    end

                    Hekili:Print( output )
                    return
                end

                local toggle = indexToToggle[ index ]

                if toggle then
                    local tab, text, to = toggle[ 1 ], toggle[ 2 ]

                    if args[3] then
                        if args[3] == "on" then to = true
                        elseif args[3] == "off" then to = false
                        elseif args[3] == "default" then to = false
                        else
                            Hekili:Print( format( "'%s' is not a valid option for |cFFFFD100%s|r.", args[3], text ) )
                            return
                        end
                    else
                        to = not profile.toggles[ tab ].value
                    end

                    Hekili:Print( format( "|cFFFFD100%s|r toggle set to %s.", text, ( to and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r" ) ) )

                    profile.toggles[ tab ].value = to

                    Hekili:ForceUpdate( "HEKILI_TOGGLE", tab )
                    return
                end

                -- Two or more arguments, we're setting (or querying).
                if index == -1 then
                    local to

                    if args[3] then
                        if args[3] == "on" then to = true
                        elseif args[3] == "off" then to = false
                        elseif args[3] == "default" then to = false
                        else
                            Hekili:Print( format( "'%s' is not a valid option for |cFFFFD100%s|r.", args[3] ) )
                            return
                        end
                    else
                        to = not spec.cycle
                    end

                    Hekili:Print( format( "Recommend Target Swaps set to %s.", ( to and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r" ) ) )

                    spec.cycle = to

                    Hekili:ForceUpdate( "CLI_TOGGLE" )
                    return
                elseif index == -2 then
                    if args[3] then
                        Hekili:SetMode( args[3] )
                    else
                        Hekili:FireToggle( "mode" )
                    end
                    return
                end

                local setting = settings[ index ]

                if setting.info.type == "toggle" then
                    local to

                    if args[3] then
                        if args[3] == "on" then to = true
                        elseif args[3] == "off" then to = false
                        elseif args[3] == "default" then to = setting.default
                        else
                            Hekili:Print( format( "'%s' is not a valid option for |cFFFFD100%s|r.", args[3] ) )
                            return
                        end
                    else
                        to = not setting.info.get( info )
                    end

                    Hekili:Print( format( "%s set to %s.", setting.info.name, ( to and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r" ) ) )

                    info[ 1 ] = setting.name
                    setting.info.set( info, to )

                    Hekili:ForceUpdate( "CLI_TOGGLE" )
                    return

                elseif setting.info.type == "range" then
                    local to

                    if args[3] == "default" then
                        to = setting.default
                    else
                        to = tonumber( args[3] )
                    end

                    if to and ( ( setting.info.min and to < setting.info.min ) or ( setting.info.max and to > setting.info.max ) ) then
                        Hekili:Print( format( "The value for %s must be between %s and %s.", args[2], ( setting.info.min and format( "%.2f", setting.info.min ) or "N/A" ), ( setting.info.max and format( "%.2f", setting.info.max ) or "N/A" ) ) )
                        return
                    end

                    if not to then
                        Hekili:Print( format( "You must provide a number value for %s (or default).", args[2] ) )
                        return
                    end

                    Hekili:Print( format( "%s set to |cFF00B4FF%.2f|r.", setting.info.name, to ) )
                    prefs[ setting.name ] = to
                    Hekili:ForceUpdate( "CLI_NUMBER" )
                    return

                end


            elseif ( "profile" ):match( "^" .. args[1] ) then
                if not args[2] then
                    local output = "Use |cFFFFD100/hekili profile name|r to swap profiles via command-line or macro.\nValid profile |cFFFFD100name|rs are:"

                    for name, prof in ns.orderedPairs( Hekili.DB.profiles ) do
                        output = format( "%s\n - |cFFFFD100%s|r %s", output, name, Hekili.DB.profile == prof and "|cFF00FF00(current)|r" or "" )
                    end

                    output = format( "%s\nTo create a new profile, see |cFFFFD100/hekili|r > |cFFFFD100Profiles|r.", output )

                    Hekili:Print( output )
                    return
                end

                local profileName = input:match( "%s+(.+)$" )

                if not rawget( Hekili.DB.profiles, profileName ) then
                    local output = format( "'%s' is not a valid profile name.\nValid profile |cFFFFD100name|rs are:", profileName )

                    local count = 0

                    for name, prof in ns.orderedPairs( Hekili.DB.profiles ) do
                        count = count + 1
                        output = format( "%s\n - |cFFFFD100%s|r %s", output, name, Hekili.DB.profile == prof and "|cFF00FF00(current)|r" or "" )
                    end

                    output = format( "%s\n\nTo create a new profile, see |cFFFFD100/hekili|r > |cFFFFD100Profiles|r.", output )

                    Hekili:Notify( output )
                    return
                end

                Hekili:Print( format( "Set profile to |cFF00FF00%s|r.", profileName ) )
                self.DB:SetProfile( profileName )
                return

            elseif ( "priority" ):match( "^" .. args[1] ) then
                local n = countPriorities()

                if not args[2] then
                    local output = "Use |cFFFFD100/hekili priority name|r to change your current specialization's priority via command-line or macro."

                    if n < 2 then
                        output = output .. "\n\n|cFFFF0000You must have multiple priorities for your specialization to use this feature.|r"
                    else
                        output = output .. "\nValid priority |cFFFFD100name|rs are:"
                        for i, priority in ipairs( priorities ) do
                            output = format( "%s\n - %s%s|r %s", output, Hekili.DB.profile.packs[ priority ].builtIn and BlizzBlue or "|cFFFFD100", priority, Hekili.DB.profile.specs[ state.spec.id ].package == priority and "|cFF00FF00(current)|r" or "" )
                        end
                    end

                    output = format( "%s\n\nTo create a new priority, see |cFFFFD100/hekili|r > |cFFFFD100Priorities|r.", output )

                    if Hekili.DB.profile.notifications.enabled then Hekili:Notify( output ) end
                    Hekili:Print( output )
                    return
                end

                -- Setting priority via commandline.
                -- Requires multiple priorities loaded for one's specialization.
                -- This also prepares the priorities table with relevant priority names.

                if n < 2 then
                    Hekili:Print( "You must have multiple priorities for your specialization to use this feature." )
                    return
                end

                if not args[2] then
                    local output = "You must provide the priority name (case sensitive).\nValid options are"
                    for i, priority in ipairs( priorities ) do
                        output = output .. format( " %s%s|r%s", Hekili.DB.profile.packs[ priority ].builtIn and BlizzBlue or "|cFFFFD100", priority, i == #priorities and "." or "," )
                    end
                    Hekili:Print( output )
                    return
                end

                local raw = input:match( "^%S+%s+(.+)$" )
                local name = raw:gsub( "%%", "%%%%" ):gsub( "^%^", "%%^" ):gsub( "%$$", "%%$" ):gsub( "%(", "%%(" ):gsub( "%)", "%%)" ):gsub( "%.", "%%." ):gsub( "%[", "%%[" ):gsub( "%]", "%%]" ):gsub( "%*", "%%*" ):gsub( "%+", "%%+" ):gsub( "%-", "%%-" ):gsub( "%?", "%%?" )

                for i, priority in ipairs( priorities ) do
                    if priority:match( "^" .. name ) then
                        Hekili.DB.profile.specs[ state.spec.id ].package = priority
                        local output = format( "Priority set to %s%s|r.", Hekili.DB.profile.packs[ priority ].builtIn and BlizzBlue or "|cFFFFD100", priority )
                        if Hekili.DB.profile.notifications.enabled then Hekili:Notify( output ) end
                        Hekili:Print( output )
                        Hekili:ForceUpdate( "CLI_TOGGLE" )
                        return
                    end
                end

                local output = format( "No match found for priority '%s'.\nValid options are", raw )

                for i, priority in ipairs( priorities ) do
                    output = output .. format( " %s%s|r%s", Hekili.DB.profile.packs[ priority ].builtIn and BlizzBlue or "|cFFFFD100", priority, i == #priorities and "." or "," )
                end

                if Hekili.DB.profile.notifications.enabled then Hekili:Notify( output ) end
                Hekili:Print( output )
                return

            elseif ( "enable" ):match( "^" .. args[1] ) or ( "disable" ):match( "^" .. args[1] ) then
                local enable = ( "enable" ):match( "^" .. args[1] ) or false

                for i, buttons in ipairs( ns.UI.Buttons ) do
                    for j, _ in ipairs( buttons ) do
                        if not enable then
                            buttons[j]:Hide()
                        else
                            buttons[j]:Show()
                        end
                    end
                end

                self.DB.profile.enabled = enable

                if enable then
                    Hekili:Print( "Addon |cFFFFD100ENABLED|r." )
                    self:Enable()
                else
                    Hekili:Print( "Addon |cFFFFD100DISABLED|r." )
                    self:Disable()
                end

            elseif ( "move" ):match( "^" .. args[1] ) or ( "unlock" ):match( "^" .. args[1] ) then
                if InCombatLockdown() then
                    Hekili:Print( "Movers cannot be activated while in combat." )
                    return
                end

                if not Hekili.Config then
                    ns.StartConfiguration( true )
                elseif ( "move" ):match( "^" .. args[1] ) and Hekili.Config then
                    ns.StopConfiguration()
                end

            elseif ("stress" ):match( "^" .. args[1] ) then
                if InCombatLockdown() then
                    Hekili:Print( "Unable to stress test abilities and auras while in combat." )
                    return
                end

                local precount = 0
                for k, v in pairs( self.ErrorDB ) do
                    precount = precount + v.n
                end

                local results, count, specs = "", 0, {}
                for i in ipairs( class.specs ) do
                    if i ~= 0 then insert( specs, i ) end
                end
                sort( specs )

                for i, specID in ipairs( specs ) do
                    local spec = class.specs[ specID ]
                    results = format( "%sSpecialization: %s\n", results, spec.name )

                    for key, aura in ipairs( spec.auras ) do
                        local keyNamed = false
                        -- Avoid duplicates.
                        if aura.key == key then
                            for k, v in pairs( aura ) do
                                if type( v ) == "function" then
                                    local ok, val = pcall( v )
                                    if not ok then
                                        if not keyNamed then results = format( "%s - Aura: %s\n", results, k ); keyNamed = true end
                                        results = format( "%s    - %s = %s\n", results, tostring( val ) )
                                        count = count + 1
                                    end
                                end
                            end
                            for k, v in pairs( aura.funcs ) do
                                if type( v ) == "function" then
                                    local ok, val = pcall( v )
                                    if not ok then
                                        if not keyNamed then results = format( "%s - Aura: %s\n", results, k ); keyNamed = true end
                                        results = format( "%s    - %s = %s\n", results, tostring( val ) )
                                        count = count + 1
                                    end
                                end
                            end
                        end
                    end

                    for key, ability in ipairs( spec.abilities ) do
                        local keyNamed = false
                        -- Avoid duplicates.
                        if ability.key == key then
                            for k, v in pairs( ability ) do
                                if type( v ) == "function" then
                                    local ok, val = pcall( v )
                                    if not ok then
                                        if not keyNamed then results = format( "%s - Ability: %s\n", results, k ); keyNamed = true end
                                        results = format( "%s    - %s = %s\n", results, tostring( val ) )
                                        count = count + 1
                                    end
                                end
                            end
                            for k, v in pairs( ability.funcs ) do
                                if type( v ) == "function" then
                                    local ok, val = pcall( v )
                                    if not ok then
                                        if not keyNamed then results = format( "%s - Ability: %s\n", results, k ); keyNamed = true end
                                        results = format( "%s    - %s = %s\n", results, tostring( val ) )
                                        count = count + 1
                                    end
                                end
                            end
                        end
                    end
                end

                local postcount = 0
                for k, v in pairs( self.ErrorDB ) do
                    postcount = postcount + v.n
                end

                if count > 0 then
                    Hekili:Print( results )
                    Hekili:Error( results )
                end

                if postcount > precount then Hekili:Print( "New warnings were loaded in /hekili > Warnings." ) end
                if count == 0 and postcount == precount then Hekili:Print( "Stress test completed; no issues found." ) end

            elseif ( "lock" ):match( "^" .. args[1] ) then
                if Hekili.Config then
                    ns.StopConfiguration()
                else
                    Hekili:Print( "Displays are not unlocked.  Use |cFFFFD100/hek move|r or |cFFFFD100/hek unlock|r to allow click-and-drag." )
                end
            elseif ( "dotinfo" ):match( "^" .. args[1] ) then
                local aura = args[2] and args[2]:trim()
                Hekili:DumpDotInfo( aura )
            end
        else
            LibStub( "AceConfigCmd-3.0" ):HandleCommand( "hekili", "Hekili", input )
        end
    end
end


-- Import/Export
-- Nicer string encoding from WeakAuras, thanks to Stanzilla.

local bit_band, bit_lshift, bit_rshift = bit.band, bit.lshift, bit.rshift
local string_char = string.char

local bytetoB64 = {
    [0]="a","b","c","d","e","f","g","h",
    "i","j","k","l","m","n","o","p",
    "q","r","s","t","u","v","w","x",
    "y","z","A","B","C","D","E","F",
    "G","H","I","J","K","L","M","N",
    "O","P","Q","R","S","T","U","V",
    "W","X","Y","Z","0","1","2","3",
    "4","5","6","7","8","9","(",")"
}

local B64tobyte = {
    a = 0, b = 1, c = 2, d = 3, e = 4, f = 5, g = 6, h = 7,
    i = 8, j = 9, k = 10, l = 11, m = 12, n = 13, o = 14, p = 15,
    q = 16, r = 17, s = 18, t = 19, u = 20, v = 21, w = 22, x = 23,
    y = 24, z = 25, A = 26, B = 27, C = 28, D = 29, E = 30, F = 31,
    G = 32, H = 33, I = 34, J = 35, K = 36, L = 37, M = 38, N = 39,
    O = 40, P = 41, Q = 42, R = 43, S = 44, T = 45, U = 46, V = 47,
    W = 48, X = 49, Y = 50, Z = 51,["0"]=52,["1"]=53,["2"]=54,["3"]=55,
    ["4"]=56,["5"]=57,["6"]=58,["7"]=59,["8"]=60,["9"]=61,["("]=62,[")"]=63
}

-- This code is based on the Encode7Bit algorithm from LibCompress
-- Credit goes to Galmok (galmok@gmail.com)
local encodeB64Table = {};

local function encodeB64(str)
    local B64 = encodeB64Table;
    local remainder = 0;
    local remainder_length = 0;
    local encoded_size = 0;
    local l=#str
    local code
    for i=1,l do
        code = string.byte(str, i);
        remainder = remainder + bit_lshift(code, remainder_length);
        remainder_length = remainder_length + 8;
        while(remainder_length) >= 6 do
            encoded_size = encoded_size + 1;
            B64[encoded_size] = bytetoB64[bit_band(remainder, 63)];
            remainder = bit_rshift(remainder, 6);
            remainder_length = remainder_length - 6;
        end
    end
    if remainder_length > 0 then
        encoded_size = encoded_size + 1;
        B64[encoded_size] = bytetoB64[remainder];
    end
    return table.concat(B64, "", 1, encoded_size)
end

local decodeB64Table = {}

local function decodeB64(str)
    local bit8 = decodeB64Table;
    local decoded_size = 0;
    local ch;
    local i = 1;
    local bitfield_len = 0;
    local bitfield = 0;
    local l = #str;
    while true do
        if bitfield_len >= 8 then
            decoded_size = decoded_size + 1;
            bit8[decoded_size] = string_char(bit_band(bitfield, 255));
            bitfield = bit_rshift(bitfield, 8);
            bitfield_len = bitfield_len - 8;
        end
        ch = B64tobyte[str:sub(i, i)];
        bitfield = bitfield + bit_lshift(ch or 0, bitfield_len);
        bitfield_len = bitfield_len + 6;
        if i > l then
            break;
        end
        i = i + 1;
    end
    return table.concat(bit8, "", 1, decoded_size)
end


-- Import/Export Strings
local Compresser = LibStub:GetLibrary("LibCompress")
local Encoder = Compresser:GetChatEncodeTable()

local LibDeflate = LibStub:GetLibrary("LibDeflate")
local ldConfig = { level = 5 }

local Serializer = LibStub:GetLibrary("AceSerializer-3.0")


TableToString = function( inTable, forChat )
    local serialized = Serializer:Serialize( inTable )
    local compressed = LibDeflate:CompressDeflate( serialized, ldConfig )

    return format( "Hekili:%s", forChat and ( LibDeflate:EncodeForPrint( compressed ) ) or ( LibDeflate:EncodeForWoWAddonChannel( compressed ) ) )
end


StringToTable = function( inString, fromChat )
    local modern = false
    if inString:sub( 1, 7 ) == "Hekili:" then
        modern = true
        inString = inString:sub( 8 )
    end

    local decoded, decompressed, errorMsg

    if modern then
        decoded = fromChat and LibDeflate:DecodeForPrint(inString) or LibDeflate:DecodeForWoWAddonChannel(inString)
        if not decoded then return "Unable to decode." end

        decompressed = LibDeflate:DecompressDeflate(decoded)
        if not decompressed then return "Unable to decompress decoded string." end
    else
        decoded = fromChat and decodeB64(inString) or Encoder:Decode(inString)
        if not decoded then return "Unable to decode." end

        decompressed, errorMsg = Compresser:Decompress(decoded);
        if not decompressed then return "Unable to decompress decoded string: " .. errorMsg end
    end

    local success, deserialized = Serializer:Deserialize(decompressed);
    if not success then return "Unable to deserialized decompressed string: " .. deserialized end

    return deserialized
end


SerializeDisplay = function( display )
    local serial = rawget( Hekili.DB.profile.displays, display )
    if not serial then return end

    return TableToString( serial, true )
end


DeserializeDisplay = function( str )
    local display = StringToTable( str, true )
    return display
end


SerializeActionPack = function( name )
    local pack = rawget( Hekili.DB.profile.packs, name )
    if not pack then return end

    local serial = {
        type = "package",
        name = name,
        date = tonumber( date("%Y%m%d.%H%M%S") ),
        payload = tableCopy( pack )
    }

    serial.payload.builtIn = false

    return TableToString( serial, true )
end


DeserializeActionPack = function( str )
    local serial = StringToTable( str, true )

    if not serial or type( serial ) == "string" or serial.type ~= "package" then
        return serial or "Unable to restore Priority from the provided string."
    end

    serial.payload.builtIn = false

    return serial
end
Hekili.DeserializeActionPack = DeserializeActionPack


SerializeStyle = function( ... )
    local serial = {
        type = "style",
        date = tonumber( date("%Y%m%d.%H%M%S") ),
        payload = {}
    }

    local hasPayload = false

    for i = 1, select( "#", ... ) do
        local dispName = select( i, ... )
        local display = rawget( Hekili.DB.profile.displays, dispName )

        if not display then return "Attempted to serialize an invalid display (" .. dispName .. ")" end

        serial.payload[ dispName ] = tableCopy( display )
        hasPayload = true
    end

    if not hasPayload then return "No displays selected to export." end
    return TableToString( serial, true )
end


DeserializeStyle = function( str )
    local serial = StringToTable( str, true )

    if not serial or type( serial ) == 'string' or not serial.type == "style" then
        return nil, serial
    end

    return serial.payload
end

-- End Import/Export Strings


local Sanitize

-- Begin APL Parsing
do
    local ignore_actions = {
        snapshot_stats = 1,
        flask = 1,
        food = 1,
        augmentation = 1
    }

    local expressions = {
        { "stealthed"                                   , "stealthed.rogue"                 },
        { "cooldown"                                    , "action_cooldown"                 },
        { "covenant%.([%w_]+)%.enabled"                 , "covenant.%1"                     },
        { "talent%.([%w_]+)"                            , "talent.%1.enabled"               },
        { "legendary%.([%w_]+)"                         , "legendary.%1.enabled"            },
        { "runeforge%.([%w_]+)"                         , "runeforge.%1.enabled"            },
        { "rune_word%.([%w_]+)"                         , "buff.rune_word_%1.up"            },
        { "rune_word%.([%w_]+)%.enabled"                , "buff.rune_word_%1.up"            },
        { "conduit%.([%w_]+)"                           , "conduit.%1.enabled"              },
        { "soulbind%.([%w_]+)"                          , "soulbind.%1.enabled"             },
        { "pet.[%w_]+%.([%w_]+)%.([%w%._]+)"            , "%1.%2"                           },
        { "essence%.([%w_]+).rank(%d)"                  , "essence.%1.rank>=%2"             },
        { "target%.1%.time_to_die"                      , "time_to_die"                     },
        { "time_to_pct_(%d+)%.remains"                  , "time_to_pct_%1"                  },
        { "trinket%.(%d)%.([%w%._]+)"                   , "trinket.t%1.%2"                  },
        { "trinket%.([%w_]+)%.cooldown"                 , "trinket.%1.cooldown.duration"    },
        { "trinket%.([%w_]+)%.proc%.([%w_]+)%.duration" , "trinket.%1.buff_duration"        },
        { "trinket%.([%w_]+)%.proc%.([%w_]+)%.[%w_]+"   , "trinket.%1.has_use_buff"         },
        { "trinket%.([%w_]+)%.has_buff%.([%w_]+)"       , "trinket.%1.has_use_buff"         },
        { "min:([%w_]+)"                                , "%1"                              },
        { "position_back"                               , "true"                            },
        { "max:(%w_]+)"                                 , "%1"                              },
        { "incanters_flow_time_to%.(%d+)"               , "incanters_flow_time_to_%.%1.any" },
        { "exsanguinated%.([%w_]+)"                     , "debuff.%1.exsanguinated"         },
        { "time_to_sht%.(%d+)%.plus"                    , "time_to_sht_plus.%1"             },
        { "target"                                      , "target.unit"                     },
        { "player"                                      , "player.unit"                     },
        { "gcd"                                         , "gcd.max"                         },

        { "equipped%.(%d+)", nil, function( item )
            item = tonumber( item )

            if not item then return "equipped.none" end

            if class.abilities[ item ] then
                return "equipped." .. ( class.abilities[ item ].key or "none" )
            end

            return "equipped[" .. item .. "]"
        end },

        { "trinket%.([%w_]+)%.cooldown%.([%w_]+)", nil, function( trinket, token )
            if class.abilities[ trinket ] then
                return "cooldown." .. trinket .. "." .. token
            end

            return "trinket." .. trinket .. ".cooldown." .. token
        end,  },

    }

    local operations = {
        { "=="  , "="  },
        { "%%"  , "/"  },
        { "//"  , "%%" }
    }


    function Hekili:AddSanitizeExpr( from, to, func )
        insert( expressions, { from, to, func } )
    end

    function Hekili:AddSanitizeOper( from, to )
        insert( operations, { from, to } )
    end

    Sanitize = function( segment, i, line, warnings )
        if i == nil then return end

        local operators = {
            [">"] = true,
            ["<"] = true,
            ["="] = true,
            ["~"] = true,
            ["+"] = true,
            ["-"] = true,
            ["%%"] = true,
            ["*"] = true
        }

        local maths = {
            ['+'] = true,
            ['-'] = true,
            ['*'] = true,
            ['%%'] = true
        }

        local times = 0
        local output, pre = "", ""

        for op1, token, op2 in gmatch( i, "([^%w%._ ]*)([%w%._]+)([^%w%._ ]*)" ) do
            --[[ if op1 and op1:len() > 0 then
                pre = op1
                for _, subs in ipairs( operations ) do
                    op1, times = op1:gsub( subs[1], subs[2] )

                    if times > 0 then
                        insert( warnings, "Line " .. line .. ": Converted '" .. pre .. "' to '" .. op1 .. "' (" ..times .. "x)." )
                    end
                end
            end ]]

            if token and token:len() > 0 then
                pre = token
                for _, subs in ipairs( expressions ) do
                    if subs[2] then
                        times = 0
                        local s1, s2, s3, s4, s5 = token:match( "^" .. subs[1] .. "$" )
                        if s1 then
                            token = subs[2]
                            token, times = token:gsub( "%%1", s1 )

                            if s2 then token = token:gsub( "%%2", s2 ) end
                            if s3 then token = token:gsub( "%%3", s3 ) end
                            if s4 then token = token:gsub( "%%4", s4 ) end
                            if s5 then token = token:gsub( "%%5", s5 ) end

                            if times > 0 then
                                insert( warnings, "Line " .. line .. ": Converted '" .. pre .. "' to '" .. token .. "' (" .. times .. "x)." )
                            end
                        end
                    elseif subs[3] then
                        local val, v2, v3, v4, v5 = token:match( "^" .. subs[1] .. "$" )
                        if val ~= nil then
                            token = subs[3]( val, v2, v3, v4, v5 )
                            insert( warnings, "Line " .. line .. ": Converted '" .. pre .. "' to '" .. token .. "'." )
                        end
                    end
                end
            end

            --[[
            if op2 and op2:len() > 0 then
                for _, subs in ipairs( operations ) do
                    op2, times = op2:gsub( subs[1], subs[2] )
                    if times > 0 then
                        insert( warnings, "Line " .. line .. ": Converted '" .. pre .. "' to '" .. op2 .. "' (" ..times .. "x)." )
                    end
                end
            end ]]

            output = output .. ( op1 or "" ) .. ( token or "" ) .. ( op2 or "" )
        end

        local ops_swapped = false
        pre = output

        -- Replace operators after its been stitched back together.
        for _, subs in ipairs( operations ) do
            output, times = output:gsub( subs[1], subs[2] )
            if times > 0 then
                ops_swapped = true
            end
        end

        if ops_swapped then
            insert( warnings, "Line " .. line .. ": Converted operations in '" .. pre .. "' to '" .. output .. "'." )
        end

        return output
    end

    local function strsplit( str, delimiter )
        local result = {}
        local from = 1

        if not delimiter or delimiter == "" then
            result[1] = str
            return result
        end

        local delim_from, delim_to = string.find( str, delimiter, from )

        while delim_from do
            insert( result, string.sub( str, from, delim_from - 1 ) )
            from = delim_to + 1
            delim_from, delim_to = string.find( str, delimiter, from )
        end

        insert( result, string.sub( str, from ) )
        return result
    end

    local parseData = {
        warnings = {},
        missing = {},
    }

    local nameMap = {
        call_action_list = "list_name",
        run_action_list = "list_name",
        potion = "potion",
        variable = "var_name",
        cancel_action = "action_name",
        cancel_buff = "buff_name",
        op = "op",
    }

    function Hekili:ParseActionList( list )
        local line, times = 0, 0
        local output, warnings, missing = {}, parseData.warnings, parseData.missing

        wipe( warnings )
        wipe( missing )

        list = list:gsub( "(|)([^|])", "%1|%2" ):gsub( "|||", "||" )

        local n = 0
        for aura in list:gmatch( "buff%.([a-zA-Z0-9_]+)" ) do
            if not class.auras[ aura ] then
                missing[ aura ] = true
                n = n + 1
            end
        end

        for aura in list:gmatch( "active_dot%.([a-zA-Z0-9_]+)" ) do
            if not class.auras[ aura ] then
                missing[ aura ] = true
                n = n + 1
            end
        end

        -- TODO: Revise to start from beginning of string.
        for i in list:gmatch( "action.-=/?([^\n^$]*)") do
            line = line + 1

            if i:sub(1, 3) == 'jab' then
                for token in i:gmatch( 'cooldown%.expel_harm%.remains>=gcd' ) do

                    local times = 0
                    while (i:find(token)) do
                        local strpos, strend = i:find(token)

                        local pre = strpos > 1 and i:sub( strpos - 1, strpos - 1 ) or ''
                        local post = strend < i:len() and i:sub( strend + 1, strend + 1 ) or ''
                        local repl = ( ( strend < i:len() and pre ) and pre or post ) or ""

                        local start = strpos > 2 and i:sub( 1, strpos - 2 ) or ''
                        local finish = strend < i:len() - 1 and i:sub( strend + 2 ) or ''

                        i = start .. repl .. finish
                        times = times + 1
                    end
                    insert( warnings, "Line " .. line .. ": Removed unnecessary expel_harm cooldown check from action entry for jab (" .. times .. "x)." )
                end
            end

            --[[ for token in i:gmatch( 'spell_targets[.%a_]-' ) do

                local times = 0
                while (i:find(token)) do
                    local strpos, strend = i:find(token)

                    local start = strpos > 2 and i:sub( 1, strpos - 1 ) or ''
                    local finish = strend < i:len() - 1 and i:sub( strend + 1 ) or ''

                    i = start .. enemies .. finish
                    times = times + 1
                end
                insert( warnings, "Line " .. line .. ": Replaced unsupported '" .. token .. "' with '" .. enemies .. "' (" .. times .. "x)." )
            end ]]

            if i:sub(1, 13) == 'fists_of_fury' then
                for token in i:gmatch( "energy.time_to_max>cast_time" ) do
                    local times = 0
                    while (i:find(token)) do
                        local strpos, strend = i:find(token)

                        local pre = strpos > 1 and i:sub( strpos - 1, strpos - 1 ) or ''
                        local post = strend < i:len() and i:sub( strend + 1, strend + 1 ) or ''
                        local repl = ( ( strend < i:len() and pre ) and pre or post ) or ""

                        local start = strpos > 2 and i:sub( 1, strpos - 2 ) or ''
                        local finish = strend < i:len() - 1 and i:sub( strend + 2 ) or ''

                        i = start .. repl .. finish
                        times = times + 1
                    end
                    insert( warnings, "Line " .. line .. ": Removed unnecessary energy cap check from action entry for fists_of_fury (" .. times .. "x)." )
                end
            end

            local components = strsplit( i, "," )
            local result = {}

            for a, str in ipairs( components ) do
                -- First element is the action, if supported.
                if a == 1 then
                    local ability = str:trim()

                    if ability and ( ability == "use_item" or class.abilities[ ability ] ) then
                        if ability == "pocketsized_computation_device" then ability = "cyclotronic_blast" end
                        -- Stub abilities that are replaced sometimes.
                        if ability == "any_dnd" or ability == "wound_spender" or ability == "summon_pet" then
                            result.action = ability
                        else
                            result.action = class.abilities[ ability ] and class.abilities[ ability ].key or ability
                        end
                    elseif not ignore_actions[ ability ] then
                        insert( warnings, "Line " .. line .. ": Unsupported action '" .. ability .. "'." )
                        result.action = ability
                    end

                else
                    local key, value = str:match( "^(.-)=(.-)$" )

                    if key and value then
                        -- TODO:  Automerge multiple criteria.
                        if key == 'if' or key == 'condition' then key = 'criteria' end

                        if key == 'criteria' or key == 'target_if' or key == 'value' or key == 'value_else' or key == 'sec' or key == 'wait' then
                            value = Sanitize( 'c', value, line, warnings )
                            value = SpaceOut( value )
                        end

                        if key == 'description' then
                            value = value:gsub( ";", "," )
                        end

                        result[ key ] = value
                    end
                end
            end

            if nameMap[ result.action ] then
                result[ nameMap[ result.action ] ] = result.name
                result.name = nil
            end

            if result.target_if then result.target_if = result.target_if:gsub( "min:", "" ):gsub( "max:", "" ) end

            -- As of 11/11/2022 (11/11/2022 in Europe), empower_to is purely a number 1-4.
            if result.empower_to then result.empower_to = tonumber( result.empower_to ) end
            if result.for_next then result.for_next = tonumber( result.for_next ) end
            if result.cycle_targets then result.cycle_targets = tonumber( result.cycle_targets ) end
            if result.max_energy then result.max_energy = tonumber( result.max_energy ) end

            if result.use_off_gcd then result.use_off_gcd = tonumber( result.use_off_gcd ) end
            if result.use_while_casting then result.use_while_casting = tonumber( result.use_while_casting ) end
            if result.strict then result.strict = tonumber( result.strict ) end
            if result.moving then result.enable_moving = true; result.moving = tonumber( result.moving ) end

            if result.target_if and not result.criteria then
                result.criteria = result.target_if
                result.target_if = nil
            end

            if result.action == "use_item" then
                if result.effect_name and class.abilities[ result.effect_name ] then
                    result.action = class.abilities[ result.effect_name ].key
                elseif result.name and class.abilities[ result.name ] then
                    result.action = result.name
                elseif ( result.slot or result.slots ) and class.abilities[ result.slot or result.slots ] then
                    result.action = result.slot or result.slots
                end

                if result.action == "use_item" then
                    insert( warnings, "Line " .. line .. ": Unsupported use_item action [ " .. ( result.effect_name or result.name or "unknown" ) .. "]; entry disabled." )
                    result.action = nil
                    result.enabled = false
                end
            end

            if result.action == "wait_for_cooldown" then
                if result.name then
                    result.action = "wait"
                    result.sec = "cooldown." .. result.name .. ".remains"
                    result.name = nil
                else
                    insert( warnings, "Line " .. line .. ": Unable to convert wait_for_cooldown,name=X to wait,sec=cooldown.X.remains; entry disabled." )
                    result.action = "wait"
                    result.enabled = false
                end
            end

            if result.action == 'use_items' and ( result.slot or result.slots ) then
                result.action = result.slot or result.slots
            end

            if result.action == 'variable' and not result.op then
                result.op = 'set'
            end

            if result.cancel_if and not result.interrupt_if then
                result.interrupt_if = result.cancel_if
                result.cancel_if = nil
            end

            insert( output, result )
        end

        if n > 0 then
            insert( warnings, "The following auras were used in the action list but were not found in the addon database:" )
            for k in orderedPairs( missing ) do
                insert( warnings, " - " .. k )
            end
        end

        return #output > 0 and output or nil, #warnings > 0 and warnings or nil
    end
end

-- End APL Parsing


local warnOnce = false

-- Begin Toggles
function Hekili:TogglePause( ... )

    Hekili.btns = ns.UI.Buttons

    if not self.Pause then
        self:MakeSnapshot()
        self.Pause = true

        --[[ if self:SaveDebugSnapshot() then
            if not warnOnce then
                self:Print( "Snapshot saved; snapshots are viewable via /hekili (until you reload your UI)." )
                warnOnce = true
            else
                self:Print( "Snapshot saved." )
            end
        end ]]

    else
        self.Pause = false
        self.ActiveDebug = false

        -- Discard the active update thread so we'll definitely start fresh at next update.
        Hekili:ForceUpdate( "TOGGLE_PAUSE", true )
    end

    local MouseInteract = self.Pause or self.Config

    for _, group in pairs( ns.UI.Buttons ) do
        for _, button in pairs( group ) do
            if button:IsShown() then
                button:EnableMouse( MouseInteract )
            end
        end
    end

    self:Print( ( not self.Pause and "UN" or "" ) .. "PAUSED." )
    self:Notify( ( not self.Pause and "UN" or "" ) .. "PAUSED" )

end


-- Key Bindings
function Hekili:MakeSnapshot( isAuto )
    if isAuto and not Hekili.DB.profile.autoSnapshot then
        return
    end

    self.ActiveDebug = true
    Hekili.Update()
    self.ActiveDebug = false

    HekiliDisplayPrimary.activeThread = nil
end



function Hekili:Notify( str, duration )
    if not self.DB.profile.notifications.enabled then
        self:Print( str )
        return
    end

    HekiliNotificationText:SetText( str )
    HekiliNotificationText:SetTextColor( 1, 0.8, 0, 1 )
    UIFrameFadeOut( HekiliNotificationText, duration or 3, 1, 0 )
end


do
    local modes = {
        "automatic", "single", "aoe", "dual", "reactive"
    }

    local modeIndex = {
        automatic = { 1, "Automatic" },
        single = { 2, "Single-Target" },
        aoe = { 3, "AOE (Multi-Target)" },
        dual = { 4, "Fixed Dual" },
        reactive = { 5, "Reactive Dual" },
    }

    local toggles = setmetatable( {
        custom1 = "Custom #1",
        custom2 = "Custom #2",
    }, {
        __index = function( t, k )
            if k == "essences" then k = "covenants" end

            local name = k:gsub( "^(.)", strupper )
            t[k] = name
            return name
        end,
    } )


    function Hekili:SetMode( mode )
        mode = lower( mode:trim() )

        if not modeIndex[ mode ] then
            Hekili:Print( "SetMode failed:  '%s' is not a valid mode.\nTry |cFFFFD100automatic|r, |cFFFFD100single|r, |cFFFFD100aoe|r, |cFFFFD100dual|r, or |cFFFFD100reactive|r." )
            return
        end

        self.DB.profile.toggles.mode.value = mode

        if self.DB.profile.notifications.enabled then
            self:Notify( "Mode: " .. modeIndex[ mode ][2] )
        else
            self:Print( modeIndex[ mode ][2] .. " mode activated." )
        end
    end


    function Hekili:FireToggle( name )
        local toggle = name and self.DB.profile.toggles[ name ]

        if not toggle then return end

        if name == 'mode' then
            local current = toggle.value
            local c_index = modeIndex[ current ][ 1 ]

            local i = c_index + 1

            while true do
                if i > #modes then i = i % #modes end
                if i == c_index then break end

                local newMode = modes[ i ]

                if toggle[ newMode ] then
                    toggle.value = newMode
                    break
                end

                i = i + 1
            end

            if self.DB.profile.notifications.enabled then
                self:Notify( "Mode: " .. modeIndex[ toggle.value ][2] )
            else
                self:Print( modeIndex[ toggle.value ][2] .. " mode activated." )
            end

        elseif name == 'pause' then
            self:TogglePause()
            return

        elseif name == 'snapshot' then
            self:MakeSnapshot()
            return

        else
            toggle.value = not toggle.value

            if toggle.name then toggles[ name ] = toggle.name end

            if self.DB.profile.notifications.enabled then
                self:Notify( toggles[ name ] .. ": " .. ( toggle.value and "ON" or "OFF" ) )
            else
                self:Print( toggles[ name ].. ( toggle.value and " |cFF00FF00ENABLED|r." or " |cFFFF0000DISABLED|r." ) )
            end
        end

        if WeakAuras and WeakAuras.ScanEvents then WeakAuras.ScanEvents( "HEKILI_TOGGLE", name, toggle.value ) end
        if ns.UI.Minimap then ns.UI.Minimap:RefreshDataText() end
        self:UpdateDisplayVisibility()

        self:ForceUpdate( "HEKILI_TOGGLE", true )
    end


    function Hekili:GetToggleState( name, class )
        local t = name and self.DB.profile.toggles[ name ]

        return t and t.value
    end
end

-- End Toggles