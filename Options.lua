-- Options.lua
-- Everything related to building/configuring options.

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local scripts = Hekili.Scripts
local state = Hekili.State

local format, lower, match, upper = string.format, string.lower, string.match, string.upper
local insert, wipe = table.insert, table.wipe

local callHook = ns.callHook
local getSpecializationID = ns.getSpecializationID

local GetResourceKey = ns.GetResourceKey
local SpaceOut = ns.SpaceOut

local escapeMagic = ns.escapeMagic
local fsub = ns.fsub
local formatKey = ns.formatKey
local orderedPairs = ns.orderedPairs
local tableCopy = ns.tableCopy

local GetItemInfo = ns.CachedGetItemInfo

local LDB = LibStub( "LibDataBroker-1.1", true )
local LDBIcon = LibStub( "LibDBIcon-1.0", true )


-- Interrupts
do
    local db = {}

    -- Generate encounter DB.
    local function GenerateEncounterDB()
        local active = EJ_GetCurrentTier()
        wipe( db )

        for t = 1, EJ_GetNumTiers() do
            EJ_SelectTier( t )
            
            local i = 1
            while EJ_GetInstanceByIndex( i, true ) do
                local instanceID, name = EJ_GetInstanceByIndex( i, true )                
                i = i + 1

                local j = 1
                while EJ_GetEncounterInfoByIndex( j, instanceID ) do
                    local name, _, encounterID = EJ_GetEncounterInfoByIndex( j, instanceID )
                    db[ encounterID ] = name
                    j = j + 1
                end
            end
        end
    end

    GenerateEncounterDB()

    function Hekili:GetEncounterList()
        return db
    end
end


local defaultAPLs = {
    ['Survival Primary'] = { "SimC Survival: precombat", "SimC Survival: default" },
    ['Survival AOE'] = { "SimC Survival: precombat", "SimC Survival: default" },
    
    ['Windwalker Primary'] = { "SimC Windwalker: precombat", "SimC Windwalker: default" },
    ['Windwalker AOE'] = { "SimC Windwalker: precombat", "SimC Windwalker: default" },
    
    ['Brewmaster Primary'] = { 0, "Brewmaster: Default" },
    ['Brewmaster AOE'] = { 0, "Brewmaster: Default" },
    ['Brewmaster Defensives'] = { 0, "Brewmaster: Defensives" },
    
    ['Enhancement Primary'] = { 'SimC Enhancement: precombat', 'SimC Enhancement: default' },
    ['Enhancement AOE'] = { 'SimC Enhancement: precombat', 'SimC Enhancement: default' },
    
    ['Elemental Primary'] = { 'SEL Elemental Precombat', 'SEL Elemental Default' },
    ['Elemental AOE'] = { 'SEL Elemental Precombat', 'SEL Elemental Default' },
    
    ['Retribution Primary'] = { 'SimC Retribution: precombat', 'SimC Retribution: default' },
    ['Retribution AOE'] = { 'SimC Retribution: precombat', 'SimC Retribution: default' },
    
    ['Protection Primary'] = { 0, 'Protection Default' }
} 


-- One Time Fixes
local oneTimeFixes = {
    refreshForBfA_II = function( p )
        for k, v in pairs( p.displays ) do
            if type( k ) == 'number' then
                p.displays[ k ] = nil
            end
        end

        p.runOnce.refreshForBfA_II = nil
        p.actionLists = nil
    end,

    reviseDisplayModes_20180709 = function( p )
        if p.toggles.mode.type ~= "AutoDual" and p.toggles.mode.type ~= "AutoSingle" and p.toggles.mode.type ~= "SingleAOE" then
            p.toggles.mode.type = "AutoDual"
        end

        if p.toggles.mode.value ~= "automatic" and p.toggles.mode.value ~= "single" and p.toggles.mode.value ~= "aoe" and p.toggles.mode.value ~= "dual" then
            p.toggles.mode.value = "automatic"
        end
    end,

    reviseDisplayQueueAnchors_20180718 = function( p )
        for name, display in pairs( p.displays ) do
            if display.queue.offset then
                if display.queue.anchor:sub( 1, 3 ) == "TOP" or display.queue.anchor:sub( 1, 6 ) == "BOTTOM" then
                    display.queue.offsetY = display.queue.offset
                    display.queue.offsetX = 0
                else
                    display.queue.offsetX = display.queue.offset
                    display.queue.offsetY = 0
                end
                display.queue.offset = nil
            end
        end

        p.runOnce.reviseDisplayQueueAnchors_20180718 = nil
    end,

    enableAllOfTheThings_20180820 = function( p )
        for name, spec in pairs( p.specs ) do
            spec.enabled = true
        end
    end,

    wipeSpecPotions_20180910_1 = function( p )
        local latestVersion = 20180919.1

        for id, spec in pairs( class.specs ) do            
            if id > 0 and ( not p.specs[ id ].potionsReset or type( p.specs[ id ].potionsReset ) ~= 'number' or p.specs[ id ].potionsReset < latestVersion ) then
                p.specs[ id ].potion = spec.potion
                p.specs[ id ].potionsReset = latestVersion
            end
        end
        p.runOnce.wipeSpecPotions_20180910_1 = nil
    end,
}


function Hekili:RunOneTimeFixes()   
    local profile = Hekili.DB.profile
    if not profile then return end
    
    profile.runOnce = profile.runOnce or {}
    
    for k, v in pairs( oneTimeFixes ) do
        if not profile.runOnce[ k ] then
            profile.runOnce[k] = true
            v( profile )
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

    keepAspectRatio = true,
    zoom = 30,

    font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
    fontSize = 12,
    fontStyle = "OUTLINE",

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
        
        font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 12,
        fontStyle = "OUTLINE"
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
        },

        pvp = {
            alpha = 1,
            always = 1,
            target = 1,
            combat = 1,
        },
    },

    border = {
        enabled = true,
        color = { 0, 0, 0, 1 },
    },

    range = {
        enabled = true,
        type = 'ability',
    },

    glow = {
        enabled = false,
        queued = false,
        shine = false,
    },

    flash = {
        enabled = false,
        color = { 255/255, 215/255, 0, 1 }, -- gold.
        suppress = false,
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
        fontStyle = "OUTLINE"
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
    },

    delays = {
        type = "TEXT",

        font = ElvUI and 'PT Sans Narrow' or 'Arial Narrow',
        fontSize = 12,
        fontStyle = "OUTLINE",

        anchor = "TOPLEFT",
        x = 0,
        y = 0,
    },

    keybindings = {
        enabled = true,
        queued = true,

        font = ElvUI and "PT Sans Narrow" or "Arial Narrow",
        fontSize = 12,
        fontStyle = "OUTLINE",

        lowercase = false,

        anchor = "TOPRIGHT",
        x = 1,
        y = -1,
    },

}


local actionTemplate = {
    enabled = true,
    action = "wait",
    criteria = "",
    caption = "",

    -- Shared Modifiers
    chain = 0,  -- NYI
    early_chain_if = "",  -- NYI

    cycle_targets = 0,
    max_cycle_targets = 3,

    interrupt = 0,  --NYI
    interrupt_if = "",  --NYI
    interrupt_immediate = 0,  -- NYI

    travel_speed = nil,

    line_cd = 0,
    moving = 0,
    sync = "",

    wait_on_ready = 0, -- NYI
    
    -- Call/Run Action List
    list_name = "default",
    
    -- Pool Resource
    wait = "0.5",
    for_next = 1,
    extra_amount = "0",
    
    -- Potion
    potion = "default",

    -- Variable
    op = "set",
    condition = "",
    value = "",
    value_else = "",
    var_name = "unnamed",

    -- Wait
    sec = 1,
}


local packTemplate = {
    spec = 0,
    builtIn = false,

    author = UnitName("player"),
    desc = "This is a package of action lists for Hekili.",
    source = "",
    date = date("%Y-%m-%d %H:%M"),

    hidden = false,

    lists = {
        precombat = {
        },
        default = {
        },
    }
}


-- Default Table
function Hekili:GetDefaults()
    local defaults = {
        global = {
            styles = {},
        },

        profile = {
            enabled = true,
            minimapIcon = false,

            toggles = {
                pause = {
                    key = "ALT-SHIFT-P",
                },

                snapshot = {
                    key = "ALT-SHIFT-[",                    
                },

                mode = {
                    key = "ALT-SHIFT-N",
                    type = "AutoSingle",
                    value = "automatic",
                },

                cooldowns = {
                    key = "ALT-SHIFT-R",
                    value = false,
                    override = false,
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
            },
            
            specs = {
                ['**'] = {
                    abilities = {
                        ['**'] = {
                            disabled = false,
                            toggle = "default",
                            clash = 0,
                            targetMin = 0,
                            targetMax = 0
                        }
                    },
                    items = {
                        ['**'] = {
                            disabled = false,
                            toggle = "default",
                            clash = 0,
                            targetMin = 0,
                            targetMax = 0,
                            boss = false,
                            criteria = nil
                        }
                    },
                    settings = {},
                },
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

                width = 600,
                height = 40,
            },

            displays = {
                Primary = {
                    enabled = true,
                    builtIn = true,

                    name = "Primary",

                    x = -82,
                    y = -225,
                
                    numIcons = 4,
                    order = 1,

                    flash = {
                        color = { 1, 0, 0, 1 },
                    },

                    glow = {
                        enabled = true,
                        shine = true
                    },
                },

                AOE = {
                    enabled = true,
                    builtIn = true,

                    name = "AOE",
                    
                    x = -82,
                    y = -170,

                    numIcons = 4,
                    order = 2,

                    flash = { 
                        color = { 0, 1, 0, 1 },
                    },

                    glow = {
                        enabled = true,
                        shine = true,
                    },
                },

                Defensives = {
                    enabled = true,
                    builtIn = true,

                    name = "Defensives",
                    filter = 'defensives',

                    x = -192,
                    y = -225,

                    numIcons = 1,
                    order = 3,

                    flash = {
                        color = { 0, 0, 1, 1 },
                    },
                },

                Interrupts = {
                    enabled = true,
                    builtIn = true,

                    name = "Interrupts",
                    filter = 'interrupts',

                    x = -137,
                    y = -225,

                    numIcons = 1,
                    order = 4,

                    flash = {
                        color = { 1, 1, 1, 1 },
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
    
    return defaults
end


-- Instead of repetitive nested tables, moving config categories to the main panel and having you pick which spec you're modifying at a given time.
local optionSpec = "current"

local function GetContext( info )
    
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

    -- Display Config.
    function Hekili:GetDisplayOption( info )
        local n = #info
        local display, category, option = info[ 2 ], info[ 3 ], info[ n ]

        if category == "shareDisplays" then
            return self:GetDisplayShareOption( info )
        end

        local conf = self.DB.profile.displays[ display ]
        if category ~= option and category ~= 'main' then
            conf = conf[ category ]
        end

        if option == 'color' then return unpack( conf.color ) end
        if option == 'name' then return display end
        return conf[ option ]
    end

    function Hekili:SetDisplayOption( info, val, v2, v3, v4 )
        local n = #info
        local display, category, option = info[ 2 ], info[ 3 ], info[ n ]
        local set = false

        if category == "shareDisplays" then
            self:SetDisplayShareOption( info, val, v2, v3, v4 )
            return
        end

        local conf = self.DB.profile.displays[ display ]
        if category ~= option and category ~= 'main' then conf = conf[ category ] end

        if option == 'color' then
            conf.color = { val, v2, v3, v4 }
            set = true
        end

        if not set then 
            val = type( val ) == 'string' and val:trim() or val
            conf[ option ] = val 
        end

        self:BuildUI()
    end


    local function GetNotifOption( info )
        local n = #info
        local option = info[ n ]

        local conf = Hekili.DB.profile.notifications

        return conf[ option ]
    end

    local function SetNotifOption( info, val )
        local n = #info
        local option = info[ n ]

        local conf = Hekili.DB.profile.notifications

        conf[ option ] = val
        Hekili:BuildUI()
    end

    local ACD = LibStub( "AceConfigDialog-3.0" )
    local LSM = LibStub( "LibSharedMedia-3.0" )
    local SF = SpellFlash or SpellFlashCore

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
            width = "double",
            dialogControl = 'LSM30_Font',
            values = LSM:HashTable("font"),
        },

        fontSize = {
            type = "range",
            name = "Size",
            order = 2,
            min = 8,
            max = 64,
            step = 1,
        },

        fontStyle = {
            type = "select",
            name = "Style",
            order = 3,
            values = fontStyles,
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

        local monitor = ( tonumber( GetCVar( 'gxMonitor' ) ) or 0 ) + 1
        local resolutions = { GetScreenResolutions() }
        local resolution = resolutions[ GetCurrentResolution() ] or GetCVar( "gxWindowedResolution" )
        local width, height = resolution:match( "(%d+)x(%d+)" )       

        tab.args.x.min = -1 * width * 0.5
        tab.args.x.max = width * 0.5

        tab.args.y.min = -1 * height * 0.5
        tab.args.y.max = height * 0.5
    end


    local function rangeIcon( info )
        local tab = getOptionTable( info )

        local display = info[2]
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


    local function newDisplayOption( db, name, data, pos )
        name = tostring( name )

        return {
            ['btn'..name] = {
                type = 'execute',
                name = name,
                desc = data.desc,
                order = 10 + pos,
                func = function () ACD:SelectGroup( "Hekili", "displays", name ) end,
            },

            [name] = {
                type = 'group',
                name = function ()
                    if data.builtIn then return '|cFF00B4FF' .. name .. '|r' end
                    return name
                end,
                childGroups = "tab",
                desc = data.desc,
                order = 100 + pos,
                args = {
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
                                hidden = function () return name == "Primary" or name == "AOE" or name == "Defensives" or name == "Interrupts" end
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
                                hidden = function( info, val )
                                    local n = #info
                                    local display = info[2]

                                    if display == "Interrupts" or display == "Defensives" then
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
                                    x = {
                                        type = "range",
                                        name = "X",
                                        desc = "Set the horizontal position for this display relative to the center of the screen.  Negative " ..
                                            "values will move the display left; positive values will move it to the right.",
                                        min = -512,
                                        max = 512,
                                        step = 1,

                                        order = 1,
                                        width = "full",
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y",
                                        desc = "Set the vertical position for this display relative to the center of the screen.  Negative " ..
                                            "values will move the display down; positive values will move it up.",
                                        min = -384,
                                        max = 384,
                                        step = 1,

                                        order = 2,
                                        width = "full",
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
                                        desc = "Specify the width of the primary icon for your " .. name .. " Display.",
                                        min = 10,
                                        max = 500,
                                        step = 1,
                                        
                                        width = "full",
                                        order = 1,
                                    },
                                    
                                    primaryHeight = {
                                        type = "range",
                                        name = "Height",
                                        desc = "Specify the height of the primary icon for your " .. name .. " Display.",
                                        min = 10,
                                        max = 500,
                                        step = 1,
                                        
                                        width = "full",
                                        order = 2,                                            
                                    },
                                },
                            },

                            zoom = {
                                type = "range",
                                name = "Icon Zoom",
                                desc = "Select the zoom percentage for the icon textures in this display. (Roughly 30% will trim off the default Blizzard borders.)",
                                min = 0,
                                max = 100,
                                step = 1,

                                width = "full",
                                order = 20,
                            },

                            keepAspectRatio = {
                                type = "toggle",
                                name = "Keep Aspect Ratio",
                                desc = "If your primary or queued icons are not square, checking this option will prevent the icon textures from being " ..
                                    "stretched and distorted, trimming some of the texture instead.",
                                disabled = function( info, val )
                                    return not ( data.primaryHeight ~= data.primaryWidth or ( data.numIcons > 1 and data.queue.height ~= data.queue.width ) )
                                end,
                                width = "full",
                                order = 25,
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
                            anchor = {
                                type = 'select',
                                name = 'Anchor To',
                                desc = "Select the point on the primary icon to which the queued icons will attach.",
                                values = anchorPositions,
                                width = "full",
                                order = 1,
                            },

                            offsetX = {
                                type = 'range',
                                name = 'Queue Horizontal Offset',
                                desc = 'Specify the offset (in pixels) for the queue, in relation to the anchor point on the primary icon for this display.',
                                min = -100,
                                max = 500,
                                step = 1,
                                width = "full",
                                order = 2,
                            },
        
                            offsetY = {
                                type = 'range',
                                name = 'Queue Vertical Offset',
                                desc = 'Specify the offset (in pixels) for the queue, in relation to the anchor point on the primary icon for this display.',
                                min = -100,
                                max = 500,
                                step = 1,
                                width = "full",
                                order = 2,
                            },
        

                            direction = {
                                type = 'select',
                                name = 'Direction',
                                desc = "Select the direction for the icon queue.",
                                values = {
                                    TOP = 'Up',
                                    BOTTOM = 'Down',
                                    LEFT = 'Left',
                                    RIGHT = 'Right'
                                },
                                width = "full",
                                order = 5,
                            },
        

                            width = {
                                type = 'range',
                                name = 'Width',
                                desc = "Select the width of the queued icons.",
                                min = 10,
                                max = 500,
                                step = 1,
                                bigStep = 1,
                                order = 10,
                                width = "full"
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
                                width = "full"
                            },
                                            
                            spacing = {
                                type = 'range',
                                name = 'Spacing',
                                desc = "Select the number of pixels between icons in the queue.",
                                min = ( data.queue.direction == "LEFT" or data.queue.direction == "RIGHT" ) and -data.queue.width or -data.queue.height,
                                max = 500,
                                step = 1,
                                order = 16,
                                width = 'full'
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

                                    Hekili:BuildUI()
                                end,
                                order = 2,
                                args = {
                                    pveAlpha = {
                                        type = "range",
                                        name = "PvE Alpha",
                                        desc = "Set the transparency of the display when in PvE combat.  If set to 0, the display will not appear in PvE.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        order = 1,
                                        width = "full",
                                    },
                                    pvpAlpha = {
                                        type = "range",
                                        name = "PvP Alpha",
                                        desc = "Set the transparency of the display when in PvP combat.  If set to 0, the display will not appear in PvP.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        order = 1,
                                        width = "full",
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
                                    Hekili:BuildUI()
                                end,
                                hidden = function() return not data.visibility.advanced end,
                                order = 2,
                                args = {
                                    always = {
                                        type = "range",                                        
                                        name = "Always",
                                        desc = "If non-zero, this display is always shown in PvE areas, both in and out of combat.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = "full",
                                        order = 1,
                                    },

                                    combat = {
                                        type = "range",
                                        name = "Combat",
                                        desc = "If non-zero, this display is always shown in PvE combat.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = "full",
                                    },

                                    target = {
                                        type = "range",
                                        name = "Target",
                                        desc = "If non-zero, this display is always shown when you have an attackable PvE target.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = "full",
                                    },
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
                                    Hekili:BuildUI()
                                    Hekili:UpdateDisplayVisibility()
                                end,
                                hidden = function() return not data.visibility.advanced end,
                                order = 2,
                                args = {
                                    always = {
                                        type = "range",                                        
                                        name = "Always",
                                        desc = "If non-zero, this display is always shown in PvP areas, both in and out of combat.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = "full",
                                        order = 1,
                                    },

                                    combat = {
                                        type = "range",
                                        name = "Combat",
                                        desc = "If non-zero, this display is always shown in PvP combat.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = "full",
                                    },

                                    target = {
                                        type = "range",
                                        name = "Target",
                                        desc = "If non-zero, this display is always shown when you have an attackable PvP target.",
                                        min = 0,
                                        max = 1,
                                        step = 0.01,
                                        width = "full",
                                    },
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
                                width = 'full',                                
                            },

                            queued = {
                                type = "toggle",
                                name = "Enabled for Queued Icons",
                                order = 2,
                                width = "full",
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
                                        width = 'full',
                                        values = realAnchorPositions
                                    },
                                    
                                    x = {
                                        type = "range",
                                        name = "X Offset",
                                        order = 3,
                                        width = "full",
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
                                        width = "full",
                                        min = -max( data.primaryHeight, data.queue.height ),
                                        max = max( data.primaryHeight, data.queue.height ),
                                        step = 1,
                                    }                                    
                                }
                            },

                            textStyle = {
                                type = "group",
                                inline = true,
                                name = "Text",
                                order = 4,
                                args = fontElements,
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

                            fit = {
                                type = "toggle",
                                name = "Border Inside",
                                desc = "If enabled, when borders are enabled, the button's border will fit inside the button (instead of around it).",
                                order = 2,
                                width = "full",
                            },

                            color = {
                                type = "color",
                                name = "Border Color",
                                desc = "When borders are enabled, the border will use this color.",
                                order = 3,
                                width = "full",
                                disabled = function () return data.border.enabled == false end,
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
                                width = "full",
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
                                width = "full",
                                order = 2,
                                disabled = function () return data.range.enabled == false end,
                            }
                        }
                    },
                    
                    glow = {
                        type = "group",
                        name = "Glows",
                        desc = "Preferences for glows or overlays.",
                        order = 6,
                        args = {
                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                desc = "If enabled, when the ability for the first icon has an active glow (or overlay), it will also glow in this display.",
                                width = "full",
                                order = 1,
                            },

                            queued = {
                                type = "toggle",
                                name = "Enabled for Queued Icons",
                                desc = "If enabled, abilities that have active glows (or overlays) will also glow in your queue.\n\n" ..
                                    "This may not be ideal, the glow may no longer be correct by that point in the future.",
                                width = "full",
                                order = 2,
                                disabled = function() return data.glow.enabled == false end,
                            },

                            shine = {
                                type = "toggle",
                                name = "Use Shine Effect",
                                desc = "If enabled, the addon will use the 'shine' effect for a less visually intrusive glow.",
                                width = "full",
                                order = 3,
                                disabled = function () return data.glow.enabled == false end,
                            }


                        }
                    },

                    flash = {
                        type = "group",
                        name = "SpellFlash",
                        desc = function ()
                            if SF then
                                return "If enabled, the addon can highlight abilities on your action bars when they are recommended for use."
                            end
                            return "This feature requires the SpellFlash addon or library to function properly."
                        end,
                        order = 8,
                        args = {
                            warning = {
                                type = "description",
                                name = "These settings are unavailable because the SpellFlash addon / library is not installed or is disabled.",
                                order = 0,
                                fontSize = "medium",
                                width = "full",
                                hidden = function () return SF ~= nil end,
                            },

                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                desc = "If enabled, the addon will place a colorful glow on the first recommended ability for this display.",
                                
                                width = "full",
                                order = 1,
                                hidden = function () return SF == nil end,
                            },

                            color = {
                                type = "color",
                                name = "Color",
                                desc = "Specify a glow color for the SpellFlash highlight.",
                                order = 2,

                                width = "full",
                                hidden = function () return SF == nil end,
                            },

                            suppress = {
                                type = "toggle",
                                name = "Hide Display",
                                desc = "If checked, the addon will not show this display and will make recommendations via SpellFlash only.",
                                order = 3,
                                width = "full",
                                hidden = function () return SF == nil end,
                            }
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
                                width = "full",
                            },

                            queued = {
                                type = "toggle",
                                name = "Enabled for Queued Icons",
                                desc = "If enabled, descriptive captions will be shown for queued abilities, if appropriate.",
                                order = 2,
                                width = "full",                                
                                disabled = function () return data.captions.enabled == false end,
                            },

                            position = {
                                type = "group",
                                inline = true,
                                name = function( info ) rangeIcon( info ); return "Position" end,
                                order = 3,
                                args = {
                                    align = {
                                        type = "select",                                        
                                        name = "Alignment",
                                        order = 1,
                                        width = "full",
                                        values = {
                                            LEFT = "Left",
                                            RIGHT = "Right",
                                            CENTER = "Center"
                                        },
                                    },

                                    anchor = {
                                        type = "select",
                                        name = 'Anchor Point',
                                        order = 2,
                                        width = 'full',
                                        values = {
                                            TOP = 'Top',
                                            BOTTOM = 'Bottom',
                                        }
                                    },
                                    
                                    x = {
                                        type = "range",
                                        name = "X Offset",
                                        order = 3,
                                        width = "full",
                                        step = 1,
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y Offset",
                                        order = 4,
                                        width = "full",
                                        step = 1,
                                    }
                                }
                            },

                            textStyle = {
                                type = "group",
                                inline = true,
                                name = "Text",
                                order = 4,
                                args = fontElements,
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
                                        width = "full",
                                    },

                                    x = {
                                        type = "range",
                                        name = "X Offset",
                                        min = -max( data.primaryWidth, data.queue.width ),
                                        max = max( data.primaryWidth, data.queue.width ),
                                        step = 1,
                                        order = 2,
                                        width = "full",
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y Offset",
                                        min = -max( data.primaryHeight, data.queue.height ),
                                        max = max( data.primaryHeight, data.queue.height ),
                                        step = 1,
                                        order = 2,
                                        width = "full",
                                    }
                                }
                            },

                            textStyle = {
                                type = "group",
                                inline = true,
                                name = "Text",
                                order = 3,
                                args = fontElements,
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
                            type = {
                                type = "select",
                                name = "Indicator",
                                desc = "Specify the type of indicator to use when you should wait before casting the ability.",                                
                                values = {
                                    __NA = "No Indicator",
                                    ICON = "Show Icon (Color)",
                                    TEXT = "Show Text (Countdown)",
                                    FADE = "Fade Icon"
                                },                        
                                width = "full",
                                order = 1,
                            },

                            fade = {
                                type = "toggle",
                                name = "Fade as Unusable",
                                desc = "Fade the primary icon when you should wait before using the ability, similar to when an ability is lacking required resources.",
                                width = "full",
                                order = 1.5
                            },

                            pos = {
                                type = "group",
                                inline = true,
                                name = function( info ) rangeIcon( info ); return "Position" end,
                                order = 2,
                                args = {
                                    anchor = {
                                        type = "select",
                                        name = 'Anchor Point',
                                        order = 2,
                                        width = 'full',
                                        values = realAnchorPositions
                                    },
                                    
                                    x = {
                                        type = "range",
                                        name = "X Offset",
                                        order = 3,
                                        width = "full",
                                        min = -max( data.primaryWidth, data.queue.width ),
                                        max = max( data.primaryWidth, data.queue.width ),
                                        step = 1,
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y Offset",
                                        order = 4,
                                        width = "full",
                                        min = -max( data.primaryHeight, data.queue.height ),
                                        max = max( data.primaryHeight, data.queue.height ),
                                        step = 1,
                                    }                                    
                                }
                            },

                            textStyle = {
                                type = "group",
                                inline = true,
                                name = "Text",
                                order = 3,
                                args = fontElements,
                                hidden = function () return data.delays.type ~= "TEXT" end,
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
                                width = "full",
                            },

                            queued = {
                                type = "toggle",
                                name = "Enabled for Queued Icons",
                                desc = "If enabled, these indicators will appear on queued icons as well as the primary icon, when appropriate.",
                                order = 2,
                                width = "full",
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
                                        width = "full",
                                    },

                                    x = {
                                        type = "range",
                                        name = "X Offset",
                                        min = -max( data.primaryWidth, data.queue.width ),
                                        max = max( data.primaryWidth, data.queue.width ),
                                        step = 1,
                                        order = 2,
                                        width = "full",
                                    },

                                    y = {
                                        type = "range",
                                        name = "Y Offset",
                                        min = -max( data.primaryHeight, data.queue.height ),
                                        max = max( data.primaryHeight, data.queue.height ),
                                        step = 1,
                                        order = 2,
                                        width = "full",
                                    }
                                }
                            },                            
                        }
                    },
                },
            },
        }
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
                    name = "Hekili has up to four built-in displays (identified in blue) that can display " ..
                        "different kinds of recommendations.  The addons recommendations are based upon the " ..
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

                                    width = "full",
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

                                    width = "full",
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
                            args = fontElements,
                        },
                    }                    
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
                                                shareDB.imported, shareDB.error = self:DeserializeStyle( shareDB.import )
        
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
                                                        table.insert( replaces, k )
                                                    else
                                                        table.insert( creates, k )
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
                                                self:BuildUI()
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
                                                    if share then table.insert( disps, key ) end
                                                end
        
                                                shareDB.export = self:SerializeStyle( unpack( disps ) )
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

        wipe( section.plugins )

        local i = 1

        for name, data in pairs( self.DB.profile.displays ) do
            local pos = data.builtIn and data.order or i
            section.plugins[ name ] = newDisplayOption( db, name, data, pos )
            if not data.builtIn then i = i + 1 end
        end

        db.args.displays = section

    end
end


ns.ClassSettings = function ()
    
    local option = {
        type = 'group',
        name = "Class/Specialization",
        order = 20,
        args = {},
        childGroups = "select",
        hidden = function()
            return #class.toggles == 0 and #class.settings == 0
        end
    }
    
    option.args.toggles = {
        type = 'group',
        name = 'Toggles',
        order = 10,
        inline = true,
        args = {
        },
        hidden = function()
            return #class.toggles == 0
        end
    }
    
    for i = 1, #class.toggles do
        option.args.toggles.args[ 'Bind: ' .. class.toggles[i].name ] = {
            type = 'keybinding',
            name = class.toggles[i].option,
            desc = class.toggles[i].oDesc,
            order = ( i - 1 ) * 2
        }
        option.args.toggles.args[ 'State: ' .. class.toggles[i].name ] = {
            type = 'toggle',
            name = class.toggles[i].option,
            desc = class.toggles[i].oDesc,
            width = 'double',
            order = 1 + ( i - 1 ) * 2
        }
    end
    
    option.args.settings = {
        type = 'group',
        name = 'Settings',
        order = 20,
        inline = true,
        args = {},
        hidden = function()
            return #class.settings == 0
        end
    }
    
    for i, setting in ipairs(class.settings) do
        option.args.settings.args[ setting.name ] = setting.option
        option.args.settings.args[ setting.name ].order = i
    end

    return option

end


local abilityToggles = {}

ns.AbilitySettings = function ()
    
    local option = {
        type = 'group',
        name = "Abilities and Items",
        order = 65,
        childGroups = 'select',
        args = {
            heading = {
                type = 'description',
                name = "These settings allow you to make minor changes to abilities that can impact how this addon makes its recommendations.  Read the " ..
                    "tooltips carefully, as some options can result in odd or undesirable behavior if misused.\n",
                order = 1,
                width = "full",
            }
        }
    }

    local abilities = {} 
    for k, v in pairs( class.abilities ) do
        if not v.unlisted and v.name and not abilities[ v.name ] and ( v.id > 0 or v.id < -99 ) then
            abilities[ v.name ] = v.key
        end
    end
    
    for k, v in pairs( abilities ) do
        local ability = class.abilities[ k ]

        local abOption = {
            type = 'group',
            name = ability.name or k or v,
            order = 2,
            -- childGroups = "inline",
            args = {
                exclude = {
                    type = 'toggle',
                    name = function () return 'Disable ' .. ( ability.item and ability.link or k ) end,
                    desc = function () return "If checked, this ability will |cFFFF0000NEVER|r be recommended by the addon.  This can cause issues for some classes or " ..
                        "specializations, if other abilities depend on you using " .. ( ability.item and ability.link or k ) .. "." end,
                    width = 'full',
                    order = 1
                },
                toggle = {
                    type = 'select',
                    name = 'Require Active Toggle',
                    desc = "Specify a required toggle for this action to be used in the addon action list.  When toggled off, abilities are treated " ..
                        "as unusable and the addon will pretend they are on cooldown (unless specified otherwise).",
                    width = 'full',
                    order = 2,
                    values = function ()
                        wipe( abilityToggles )

                        abilityToggles[ 'none' ] = 'None'
                        abilityToggles[ 'default' ] = 'Default' .. ( ability.toggle and ( ' |cFFFFD100(' .. ability.toggle .. ')|r' ) or ' |cFFFFD100(none)|r' )
                        abilityToggles[ 'defensives' ] = 'Defensives'
                        abilityToggles[ 'cooldowns' ] = 'Cooldowns'
                        abilityToggles[ 'interrupts' ] = 'Interrupts'
                        abilityToggles[ 'potions' ] = 'Potions'

                        return abilityToggles
                    end,
                },
                clash = {
                    type = 'range',
                    name = 'Clash Value',
                    desc = "If set above zero, the addon will pretend " .. k .. " has come off cooldown this much sooner than it actually has.  " ..
                        "This can be helpful when an ability is very high priority and you want the addon to consider it a bit earlier than it would actually be ready.",
                    width = "full",
                    min = -1.5,
                    max = 1.5,
                    step = 0.05,
                    order = 3
                },
                
                spacer01 = {
                    type = "description",
                    name = " ",
                    width = "full",
                    order = 19,
                    hidden = function() return ability.item == nil end,
                },

                itemHeader = {
                    type = "description",
                    name = "|cFFFFD100Usable Items|r",
                    order = 20,
                    fontSize = "medium",
                    width = "full",
                    hidden = function() return ability.item == nil end,
                },
    
                itemDescription = {
                    type = "description",
                    name = function () return "This ability requires that " .. ( ability.link or ability.name ) .. " is equipped.  This item can be recommended via |cFF00CCFF[Use Items]|r in your " ..
                        "action lists.  If you do not want the addon to recommend this ability via |cff00ccff[Use Items]|r, you can disable it here.  " ..
                        "You can also specify a minimum or maximum number of targets for the item to be used.\n" end,
                    order = 21,
                    width = "full",
                    hidden = function() return ability.item == nil end,
                },
    
                spacer02 = {
                    type = "description",
                    name = " ",
                    width = "full",
                    order = 49
                },
            }
        }

        if ability and ability.item then
            if class.itemSettings[ ability.item ] then
                for setting, config in pairs( class.itemSettings[ ability.item ].options ) do
                    abOption.args[ setting ] = config
                end
            end
        end

        abOption.hidden = function( info )
            -- Hijack this function to build toggle list for action list entries.

            abOption.args.listHeader = abOption.args.listHeader or {
                type = "description",
                name = "|cFFFFD100Action Lists|r",
                order = 50,
                fontSize = "medium",
                width = "full",
            }
            abOption.args.listHeader.hidden = true

            abOption.args.listDescription = abOption.args.listDescription or {
                type = "description",
                name = "This ability is listed in the action list(s) below.  You can disable any entries here, if desired.",
                order = 51,
                width = "full",
            }
            abOption.args.listDescription.hidden = true

            for key, opt in pairs( abOption.args ) do
                if key:match( "^(%d+):(%d+)" ) then
                    opt.hidden = true
                end
            end

            local entries = 51

            for i, list in ipairs( Hekili.DB.profile.actionLists ) do
                if list.Name ~= "Usable Items" then
                    for a, action in ipairs( list.Actions ) do
                        if action.Ability == v then
                            entries = entries + 1

                            local toggle = option.args[ v ].args[ i .. ':' .. a ] or {}

                            toggle.type = "toggle"
                            toggle.name = "Disable " .. ( ability.item and ability.link or k ) .. " (#|cFFFFD100" .. a .. "|r) in |cFFFFD100" .. ( list.Name or "Unnamed List" ) .. "|r"
                            toggle.desc = "This ability is used in entry #" .. a .. " of the |cFFFFD100" .. list.Name .. "|r action list."
                            toggle.order = entries
                            toggle.width = "full"
                            toggle.hidden = false

                            abOption.args[ i .. ':' .. a ] = toggle
                        end
                    end
                end
            end

            if entries > 51 then
                abOption.args.listHeader.hidden = false
                abOption.args.listDescription.hidden = false
            end

            return false
        end

        option.args[ v ] = abOption
    end
    
    return option
    
end


ns.TrinketSettings = function ()
    
    local option = {
        type = 'group',
        name = "Trinkets/Gear",
        order = 22,
        args = {
            heading = {
                type = 'description',
                name = "These settings apply to trinkets/gear that are used via the [Use Items] action in your action lists.  Instead of " ..
                    "manually editing your action lists, you can enable/disable specific trinkets or require a minimum or maximum number of " ..
                    "enemies before allowing the trinket to be used.\n\n" ..
                    "|cFFFFD100If your action list has a specific entry for a certain trinket with specific criteria, you will likely want to disable " ..
                    "the trinket here.|r",
                order = 1,
                width = "full",
            }
        },
        childGroups = 'select'
    }

    local trinkets = Hekili.DB.profile.trinkets

    for i, setting in pairs( class.itemSettings ) do
        option.args[ setting.key ] = {
            type = "group",
            name = setting.name,
            order = 10 + i,
            -- inline = true,
            args = setting.options
        }

        option.args[ setting.key ].hidden = function( info )

            -- Hide toggles in case they're outdated.
            for k, v in pairs( setting.options ) do
                if k:match( "^(%d+):(%d+)$") then
                    v.hidden = true
                end
            end

            for i, list in ipairs( Hekili.DB.profile.actionLists ) do
                local entries = 100

                if list.Name ~= 'Usable Items' then
                    for a, action in ipairs( list.Actions ) do
                        if action.Ability == setting.key then
                            entries = entries + 1
                            local toggle = option.args[ setting.key ].args[ i .. ':' .. a ] or {}

                            local name = type( setting.name ) == 'function' and setting.name() or setting.name 

                            toggle.type = "toggle"
                            toggle.name = "Disable " .. name .. " in |cFFFFD100" .. ( list.Name or "(no list name)" ) .. " (#" .. a .. ")|r"
                            toggle.desc = "This item is used in entry #" .. a .. " of the |cFFFFD100" .. list.Name .. "|r action list.\n\n" ..
                                "This usually means that there is class- or spec-specific criteria for using this item.  If you do not want this item " ..
                                "to be recommended via this action list, check this box."
                            toggle.order = entries
                            toggle.width = "full"
                            toggle.hidden = false

                            option.args[ setting.key ].args[ i .. ':' .. a ] = toggle
                        end
                    end
                end
            end

            return false
        end

        trinkets[ setting.key ] = trinkets[ setting.key ] or {
            disabled = false,
            minimum = 1,
            maximum = 0
        }

    end
    
    return option
    
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

        for list, action in apl:gmatch( "\nactions%.(%S-)%+?=/?([^\n^$]*)" ) do
            lists[ list ] = lists[ list ] or ""

            --[[ if action:sub( 1, 6 ) == "potion" then
                local potion = action:match( ",name=(.-),") or action:match( ",name=(.-)$" ) or class.potion or ""
                action = action:gsub( potion, "\"" .. potion .. "\"" )
            end ]]

            if action:sub( 1, 16 ) == "call_action_list" or action:sub( 1, 15 ) == "run_action_list" then
                local name = action:match( ",name=(.-)," ) or action:match( ",name=(.-)$" )
                if name then action:gsub( ",name=" .. name, ",name=\"" .. name .. "\"" ) end
            end

            lists[ list ] = lists[ list ] .. "actions+=/" .. action .. "\n"
        end
            
        local count = 0
        local output = {}
            
        for name, list in pairs( lists ) do
            local import, warnings = self:ParseActionList( list )

            if warnings then
                AddWarning( "WARNING:  The import for '" .. name .. "' required some automated changes." )

                for i, warning in ipairs( warnings ) do
                    AddWarning( warning )
                end

                AddWarning( "" )
            end

            if import then
                output[ name ] = import

                for i, entry in ipairs( import ) do
                    entry.enabled = not ( entry.action == 'heroism' or entry.action == 'bloodlust' )
                end

                count = count + 1
            end
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


local optionBuffer = {}

local buffer = function( msg )
    optionBuffer[ #optionBuffer + 1 ] = msg
end

local getBuffer = function()
    local output = table.concat( optionBuffer )
    wipe( optionBuffer )
    return output
end

local getColoredName = function( tab )
    if not tab then return '(none)'
    elseif tab.Default then return '|cFF00C0FF' .. tab.Name .. '|r'
else return '|cFFFFC000' .. tab.Name .. '|r' end
end


local snapshots = {
    displays = {},
    snaps = {},
    empty = {},
    
    display = "none",
    snap = {},
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
}


function Hekili:NewGetOption( info )
    
    local depth = #info
    local option = depth and info[depth] or nil
    
    if not option then return end
    
    if config[ option ] then return config[ option ] end
    
    return
end


function Hekili:NewSetOption( info, value )
    
    local depth = #info
    local option = depth and info[depth] or nil
    
    if not option then return end
    
    local nValue = tonumber( value )
    local sValue = tostring( value )
    
    if option == 'qsShowTypeGroup' then config[option] = value
    else config[option] = nValue end
    
    return
end


local specs = {}
local activeSpec

local function GetCurrentSpec()
    local id, name = GetSpecializationInfo( GetSpecialization() )
    return activeSpec or id
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

    local ACD = LibStub( "AceConfigDialog-3.0" )

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
            shareDB.export = self:SerializeActionPack( shareDB.actionPack )
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
    end


    function Hekili:GetSpecOption( info )
        local n = #info
        local spec, option = info[1], info[n]

        spec = specIDByName[ spec ]
        if not spec then return end

        self.DB.profile.specs[ spec ] = self.DB.profile.specs[ spec ] or {}
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
    end
    
    function Hekili:GetItemOption( info )
        local n = #info
        local item, option = info[2], info[n]

        local spec = GetCurrentSpec()

        return self.DB.profile.specs[ spec ].items[ item ][ option ]
    end


    function Hekili:EmbedAbilityOptions( db )
        db = db or self.Options
        if not db then return end

        local abilities = {}
        local toggles = {}

        for k, v in pairs( class.abilityList ) do
            local a = class.abilities[ k ]
            if a and ( a.id > 0 or a.id < -100 ) and a.id ~= 61304 and not a.item then
                abilities[ v ] = k
            end
        end

        for k, v in orderedPairs( abilities ) do
            local ability = class.abilities[ v ]
            local option = {
                type = "group",
                name = function () return ability.name end,
                order = 1,
                set = "SetAbilityOption",
                get = "GetAbilityOption",
                args = {
                    disabled = {
                        type = "toggle",
                        name = function () return "Disable " .. ( ability.item and ability.link or k ) end,
                        desc = function () return "If checked, this ability will |cffff0000NEVER|r be recommended by the addon.  This can cause " ..
                            "issues for some specializations, if other abilities depend on you using " .. ( ability.item and ability.link or k ) .. "." end,
                        width = "full",
                        order = 1,
                    },

                    keybind = {
                        type = "input",
                        name = "Keybinding",
                        desc = "If specified, the addon will show this text in place of the auto-detected keybind text when recommending this ability.  " ..
                            "This can be helpful if the addon incorrectly detects your keybindings.",
                        validate = function( info, val )
                            val = val:trim()
                            if val:len() > 6 then return "Keybindings should be no longer than 6 characters in length." end
                            return true
                        end,
                        width = "single",
                        order = 2,
                    },

                    toggle = {
                        type = "select",
                        name = "Require Toggle",
                        desc = "Specify a required toggle for this action to be used in the addon action list.  When toggled off, abilities are treated " ..
                            "as unusable and the addon will pretend they are on cooldown (unless specified otherwise).",
                        width = "full",
                        order = 3,
                        values = function ()
                            table.wipe( toggles )

                            toggles.none = "None"
                            toggles.default = "Default" .. ( class.abilities[ v ].toggle and ( " |cffffd100(" .. class.abilities[ v ].toggle .. ")|r" ) or " |cffffd100(none)|r" )
                            toggles.defensives = "Defensives"
                            toggles.cooldowns = "Cooldowns"
                            toggles.interrupts = "Interrupts"
                            toggles.potions = "Potions"

                            return toggles
                        end,
                    },

                    targetMin = {
                        type = "range",
                        name = "Minimum Targets",
                        desc = "If set above zero, the addon will only allow " .. k .. " to be recommended, if there are at least this many detected enemies.  All other action list conditions must also be met.\nSet to zero to ignore.",
                        width = "full",
                        min = 0,
                        max = 15,
                        step = 1,
                        order = 3.1,
                    },

                    targetMax = {
                        type = "range",
                        name = "Maximum Targets",
                        desc = "If set above zero, the addon will only allow " .. k .. " to be recommended if there are this many detected enemies (or fewer).  All other action list conditions must also be met.\nSet to zero to ignore.",
                        width = "full",
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
                        width = "full",
                        min = -1.5,
                        max = 1.5,
                        step = 0.05,
                        order = 4,
                    },
                }
            }

            db.args.abilities.plugins.actions[ v ] = option
        end
    end


    function Hekili:EmbedItemOptions( db )
        db = db or self.Options
        if not db then return end

        local abilities = {}
        local toggles = {}

        for k, v in pairs( class.abilities ) do
            if v.item and not abilities[ v.key ] and class.itemList[ v.item ] then
                abilities[ class.itemList[ v.item ] ] = v.key
            end
        end

        for k, v in orderedPairs( abilities ) do
            local ability = class.abilities[ v ]
            local option = {
                type = "group",
                name = function () return ability.name end,
                order = 1,
                set = "SetItemOption",
                get = "GetItemOption",
                args = {
                    disabled = {
                        type = "toggle",
                        name = function () return "Disable " .. ( ability.item and ability.link or k ) end,
                        desc = function () return "If checked, this ability will |cffff0000NEVER|r be recommended by the addon.  This can cause " ..
                            "issues for some specializations, if other abilities depend on you using " .. ( ability.item and ability.link or k ) .. "." end,
                        width = "full",
                        order = 1,
                    },

                    keybind = {
                        type = "input",
                        name = "Keybinding",
                        desc = "If specified, the addon will show this text in place of the auto-detected keybind text when recommending this ability.  " ..
                            "This can be helpful if the addon incorrectly detects your keybindings.",
                        validate = function( info, val )
                            val = val:trim()
                            if val:len() > 6 then return "Keybindings should be no longer than 6 characters in length." end
                            return true
                        end,
                        width = "single",
                        order = 2,
                    },

                    toggle = {
                        type = "select",
                        name = "Require Toggle",
                        desc = "Specify a required toggle for this action to be used in the addon action list.  When toggled off, abilities are treated " ..
                            "as unusable and the addon will pretend they are on cooldown (unless specified otherwise).",
                        width = "full",
                        order = 3,
                        values = function ()
                            table.wipe( toggles )

                            toggles.none = "None"
                            toggles.default = "Default" .. ( class.abilities[ v ].toggle and ( " |cffffd100(" .. class.abilities[ v ].toggle .. ")|r" ) or " |cffffd100(none)|r" )
                            toggles.defensives = "Defensives"
                            toggles.cooldowns = "Cooldowns"
                            toggles.interrupts = "Interrupts"
                            toggles.potions = "Potions"

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
                        width = "full",
                        min = 0,
                        max = 15,
                        step = 1,
                        order = 5,
                    },

                    targetMax = {
                        type = "range",
                        name = "Maximum Targets",
                        desc = "If set above zero, the addon will only allow " .. k .. " to be recommended via [Use Items] if there are this many detected enemies (or fewer).\nSet to zero to ignore.",
                        width = "full",
                        min = 0,
                        max = 15,
                        step = 1,
                        order = 6,
                    },

                    boss = {
                        type = "toggle",
                        name = "Boss Encounter Only",
                        desc = "If checked, the addon will not recommend " .. k .. " via [Use Items] unless you are in a boss fight (or encounter).  If left unchecked, " .. k .. " can be recommended in any type of fight.",
                        width = "full",
                        order = 7
                    }
                }
            }

            db.args.items.plugins.equipment[ v ] = option
        end
    end


    -- Options table constructors.
    function Hekili:EmbedSpecOptions( db )
        db = db or self.Options
        if not db then return end

        local i = 1
        
        while( true ) do
            local id, name, description, texture, role = GetSpecializationInfo( i )

            if not id then break end
            
            if role ~= "HEALER" and class.specs[ id ] then
                local sName = lower( name )
                specNameByID[ id ] = sName
                specIDByName[ sName ] = id

                specs[ id ] = '|T' .. texture .. ':0|t ' .. name

                db.plugins.specializations[ sName ] = {
                    type = "group",
                    name = specs[ id ],
                    desc = description,
                    order = 50 + i,
                    childGroups = "tree",
                    get = "GetSpecOption",
                    set = "SetSpecOption",
                    
                    args = {
                        enabled = {
                            type = "toggle",
                            name = "Enabled",
                            desc = "If checked, the addon will provide priority recommendations for " .. name .. ".",
                            order = 0,
                            width = "full",
                        },

                        packInfo = {
                            type = 'group',
                            name = "",
                            inline = true,
                            order = 10,
                            args = {
                                package = {
                                    type = "select",
                                    name = "Priority",
                                    desc = "The addon will use the selected package when making its priority recommendations.",
                                    order = 1,
                                    width = "full",
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
                                    name = "View Priority",
                                    desc = "Open and view this priority pack and its action lists.",
                                    order = 2,
                                    width = "single",
                                    disabled = function( info, val )
                                        local pack = self.DB.profile.specs[ id ].package
                                        return rawget( self.DB.profile.packs, pack ) == nil
                                    end,
                                    func = function ()
                                        ACD:SelectGroup( "Hekili", "packs", self.DB.profile.specs[ id ].package )
                                    end,
                                }
                            }
                        },

                        potion = {
                            type = "select",
                            name = "Default Potion",
                            desc = "When recommending a potion, the addon will suggest this potion unless unless the action list specifies otherwise.",
                            order = 11,
                            width = "full",
                            values = function ()
                                local v = {}
                                
                                for k, p in pairs( class.potionList ) do
                                    if k ~= "default" then v[ k ] = p end
                                end

                                return v
                            end,
                        },

                        spacing3 = {
                            type = "description",
                            name = " ",
                            order = 11.01,
                            width = "full",
                        },

                        padding = {
                            type = "group",
                            inline = true,
                            name = "Aura Padding",
                            order = 11.1,
                            args = {
                                buffPadding = {
                                    type = "range",
                                    name = "Buff Padding",
                                    desc = "This setting will cause the addon to treat your buffs as though they are going to fall off earlier than they " ..
                                        "actually will.  For instance, if set to |cFFFFD1000.25|r seconds, then a buff that will expire in |cFFFFD1004|r seconds will " ..
                                        "be treated as though it would fall off in |cFFFFD1003.75|r seconds.  Depending on your spec's priority, this may lead you to " ..
                                        "refresh your buffs more frequently, which is helpful when trying to chain a buff or maintain stacks without the buff falling off.",
                                    order = 1,
                                    width = "full",
                                    min = 0,
                                    max = 1,
                                    step = 0.01
                                },
                                debuffPadding = {
                                    type = "range",
                                    name = "Debuff Padding",
                                    desc = "This setting will cause the addon to treat your debuffs (or DoT effects) as though they are going to fall off earlier than they " ..
                                        "actually will.  For instance, if set to |cFFFFD1000.25|r seconds, then a debuff that will expire in |cFFFFD1004|r seconds will " ..
                                        "be treated as though it will expire in |cFFFFD1003.75|r seconds.  Depending on your spec's priority, this may lead you to " ..
                                        "refresh your debuffs more frequently, which is helpful when trying to chain a debuff or maintain stacks without the debuff falling off.",
                                    order = 1,
                                    width = "full",
                                    min = 0,
                                    max = 1,
                                    step = 0.01
                                },                                
                            }
                        },

                        spacing4 = {
                            type = "description",
                            name = " ",
                            order = 13,
                            width = "full",
                        },

                        targetDetection = {
                            type = "group",
                            name = "Target Handling",
                            inline = true,
                            order = 15,
                            args = {
                                nameplates = {
                                    type = "toggle",
                                    name = "Use Nameplate Detection",
                                    desc = "If checked, the addon will count any enemies with visible nameplates within a small radius of your character.  " ..
                                        "This is typically desirable for melee character specializations.",
                                    width = "full",
                                    order = 1,
                                },
        
                                nameplateRange = {
                                    type = "range",
                                    name = "Nameplate Detection Range",
                                    desc = "When |cFFFFD100Use Nameplate Detection|r is checked, the addon will count any enemies with visible nameplates within this radius of your character.",
                                    width = "full",
                                    disabled = function( info, val )
                                        return self.DB.profile.specs[ id ].nameplates == false
                                    end,
                                    order = 2,
                                },

                                aoe = {
                                    type = "range",
                                    name = "AOE Target Count",
                                    desc = "When the AOE Display is shown, it will assume that there are at least this many active targets.",
                                    width = "full",
                                    min = 2,
                                    max = 5,
                                    step = 1,
                                    order = 3,
                                },
        
                                cycle = {
                                    type = "toggle",
                                    name = "Recommend Target Cycling",
                                    desc = "When target cycling is enabled, the addon may show an icon (|TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t) when you should use an ability on a different target.  " ..
                                        "This works well for some specs, that simply want to apply a debuff to another target (like Windwalker), but can be less-effective for specializations that are concerned with " ..
                                        "maintaining dots/debuffs based on their durations (like Affliction).  This feature is targeted for improvement in a future update.",
                                    width = "full",
                                    order = 3.1
                                },

                                gcdSync = {
                                    type = "toggle",
                                    name = "Sync First Recommendation with GCD",
                                    desc = "If checked (default), the addon's first recommendation will be delayed to the start of the GCD in your Primary and AOE displays.",
                                    width = "full",
                                    order = 3.2,
                                },
        
                                damage = {
                                    type = "toggle",
                                    name = "Detect Enemies by Damage",
                                    desc = "If checked, the addon will count any enemies that you've hit (or hit you) within the past several seconds as active enemies.  " ..
                                        "This is typically desirable for ranged character specializations.",
                                    width = "full",
                                    order = 4,                                    
                                },
        
                                damageDots = {
                                    type = "toggle",
                                    name = "Detect Enemies by Damage over Time",
                                    desc = "When checked, the addon will continue to count enemies who are taking damage from your damage over time effects (bleeds, etc.), even if they are not nearby or taking other damage from you.  " ..
                                        "This may not be ideal for melee specializations, if you are no longer near the enemy that is taking damage over time.  For ranged specializations with damage over time effects, this should be enabled.",
                                    width = "full",
                                    disabled = function () return self.DB.profile.specs[ id ].damage == false end,
                                    order = 5,
                                },

                                damageExpiration = {
                                    type = "range",
                                    name = "Damage Detection Timeout",
                                    desc = "When |cFFFFD100Detect Enemies by Damage|r is checked, the addon will count enemies for up to this many seconds before forgetting about them.  " ..
                                        "Enemies will also be forgotten if they die or despawn.  This is helpful when enemies spread out or move out of range.",
                                    width = "full",
                                    min = 3,
                                    max = 10,
                                    step = 0.1,
                                    disabled = function( info, val )
                                        return self.DB.profile.specs[ id ].damage == false
                                    end,
                                    order = 6,
                                },
                            }
                        },

                        performance = {
                            type = "group",
                            name = "Performance",
                            inline = true,
                            order = 20,
                            args = {
                                throttleRefresh = {
                                    type = "toggle",
                                    name = "Throttle Updates",
                                    desc = "By default, the addon will update its recommendations after any relevant combat events.  However, some combat events can occur in rapid succession, " ..
                                        "leading to higher CPU usage and reduced game performance.  If you choose to |cffffd100Throttle Updates|r, you can specify the |cffffd100Maximum Update Frequency|r" ..
                                        "for this specialization.",
                                    order = 1,
                                    width = "full",
                                },

                                maxRefresh = {
                                    type = "range",
                                    name = "Maximum Update Frequency",
                                    desc = "Specify the maximum number of times per second that the addon should update its recommendations.\n\n" ..
                                        "If set to |cffffd1004|r, the addon will not update its recommendations more frequently than every |cffffd1000.25|r seconds.\n\n" ..
                                        "If set to |cffffd10020|r, the addon will not update its recommendations more frequently than every |cffffd1000.05|r seconds.\n\n" ..
                                        "The addon aims for updates every 0.1 seconds (10 updates per second) by default.",
                                    order = 2,
                                    width = "full",
                                    min = 4,
                                    max = 20,
                                    step = 1,
                                    disabled = function () return self.DB.profile.specs[ id ].throttleRefresh == false end,
                                },
                            }
                        }
                    },

                    plugins = {
                        prefs = {}
                    }
                }

                local userPrefs = class.specs[ id ] and class.specs[ id ].prefs
                

            end

            i = i + 1
        end

        --[[ db.args.specs.args.header = {
            type = "description",
            name = i > 1 and "Hekili supports the following specializations for your current class.  You can customize settings " ..
                "for your specialization in the appropriate section below." or "No specializations for your current class are supported by Hekili.",
            fontSize = 'medium',
            order = 1,
        } ]]

    end


    local packControl = {
        listName = "default",
        actionID = "0001",
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
    }


    local defaultNames = {
        list_name = "default",
        potion = "prolonged_power",
        var_name = "unnamed_var",
    }


    local toggleToNumber = {
        for_next = true,
        cycle_targets = true,        
    }


    local function GetListEntry( pack )
        local entry = rawget( Hekili.DB.profile.packs, pack )

        if entry then entry = entry.lists[ packControl.listName ] else return end

        local listPos = tonumber( packControl.actionID )
        if entry and listPos > 0 then entry = entry[ listPos ] else return end

        return entry
    end


    function Hekili:GetActionOption( info )
        local n = #info
        local pack, option = info[ 2 ], info[ n ]

        local actionID = tonumber( packControl.actionID )
        local data = self.DB.profile.packs[ pack ].lists[ packControl.listName ]

        if option == 'position' then return actionID
        elseif option == 'newListName' then return packControl.newListName end

        if not data then return end
        data = data[ actionID ]

        if option == "inputName" or option == "selectName" then
            option = nameMap[ data.action ]
            if not data[ option ] then data[ option ] = defaultNames[ option ] end
        end
        
        if toggleToNumber[ option ] then return data[ option ] == 1 end
        return data[ option ]
    end


    function Hekili:SetActionOption( info, val )
        local n = #info
        local pack, option = info[ 2 ], info[ n ]

        local actionID = tonumber( packControl.actionID )
        local data = self.DB.profile.packs[ pack ].lists[ packControl.listName ]

        if option == 'position' then
            local a = table.remove( data, actionID )
            table.insert( data, val, a )
            packControl.actionID = format( "%04d", val )
            self:LoadScripts()
            return
        
        elseif option == 'newListName' then
            packControl.newListName = val:trim()
            self:LoadScripts()
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

        self:LoadScripts()
    end


    function Hekili:GetPackOption( info )
        local n = #info
        local category, subcat, option = info[ 2 ], info[ 3 ], info[ n ]

        if packControl[ option ] ~= nil then return packControl[ option ] end        

        if subcat == 'lists' then return self:GetActionOption( info ) end
        -- if subcat == 'newActionGroup' or ( subcat == 'actionGroup' and subtype == 'entry' ) then return self:GetActionOption( info ) end

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
            if option == "listName" then packControl.actionID = "zzzzzzzzzz" end
            if option == "actionID" and val == "zzzzzzzzzz" then
                local data = rawget( self.DB.profile.packs, category )
                if data then
                    table.insert( data.lists[ packControl.listName ], { {} } )
                    packControl.actionID = format( "%04d", #data.lists[ packControl.listName ] )
                else
                    packControl.actionID = "0001"
                end
            end
            return
        end

        if subcat == 'lists' then return self:SetActionOption( info, val ) end
        -- if subcat == 'newActionGroup' or ( subcat == 'actionGroup' and subtype == 'entry' ) then self:SetActionOption( info, val ); return end

        local data = rawget( self.DB.profile.packs, category )
        if not data then return end

        if type( val ) == 'string' then val = val:trim() end

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
                        "They can be customized and shared.",
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
                    name = "Pack Name",
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
                                                shareDB.imported, shareDB.error = self:DeserializeActionPack( shareDB.import )
        
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
                                                    table.insert( listNames, k )
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
                                    name = "Priority Export String",
                                    order = 3,
                                    multiline = 8,
                                    get = function ()
                                        if rawget( Hekili.DB.profile.packs, shareDB.actionPack ) then
                                            shareDB.export = self:SerializeActionPack( shareDB.actionPack )
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
                    childGroups = "tab",
                    order = 100 + count,
                    args = {
                        pack = {
                            type = "group",
                            name = function ()
                                local p = rawget( Hekili.DB.profile.packs, pack )
                                if p.builtIn then return '|cFF00B4FF' .. pack .. '|r' end
                                return pack
                            end,
                            order = 1,
                            args = {
                                spec = {
                                    type = "select",
                                    name = "Specialization",
                                    order = 1,
                                    width = "full",
                                    values = specs,
                                },
            
                                desc = {
                                    type = "input",
                                    name = "Description",
                                    multiline = 15,
                                    order = 2,
                                    width = "full",
                                },

                                reload = {
                                    type = "execute",
                                    name = "Reload Pack",
                                    order = 3,
                                    confirm = true,
                                    hidden = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return p and not p.builtIn
                                    end,
                                    func = function ()
                                        Hekili.DB.profile.packs[ pack ] = nil
                                        Hekili:RestoreDefault( pack )
                                        Hekili:EmbedPackOptions()
                                        Hekili:LoadScripts()
                                        ACD:SelectGroup( "Hekili", "packs", pack )
                                    end
                                },

                                delete = {
                                    type = "execute",
                                    name = "Delete Pack",
                                    order = 3,
                                    confirm = true,
                                    hidden = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return p and p.builtIn
                                    end,
                                    func = function ()
                                        Hekili.DB.profile.packs[ pack ] = nil
                                        Hekili:EmbedPackOptions()
                                        ACD:SelectGroup( "Hekili", "packs" )
                                    end,
                                }
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
                                            width = "full",
                                        },
                    
                                        author = {
                                            type = "input",
                                            name = "Author",
                                            desc = "The author field is automatically filled out when creating a new Priority.  " ..
                                                "You can update it here.",
                                            order = 2,
                                            width = "double",
                                        },
                    
                                        date = {
                                            type = "input",
                                            name = "Last Updated",
                                            desc = "This date is automatically updated when any changes are made to the action lists for this Priority.",
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
                                    desc = "If this pack's action lists were imported from a SimulationCraft profile, any details logged at import are included here.",
                                    order = 5,
                                    multiline = 10,
                                    width = "full",                                
                                    hidden = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        return not p.warnings or p.warnings == ""
                                    end,
                                },
            
                                reimport = {
                                    type = "execute",
                                    name = "(Re)Import",
                                    desc = "Rebuild the action list(s) from the profile above.",
                                    order = 5,
                                    func = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )
                                        local result, warnings = Hekili:ImportSimcAPL( nil, nil, p.profile )

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
                                nav = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 1,
                                    args = {
                                        listName = {
                                            type = "select",
                                            name = "Select an Action List",
                                            desc = "Select the action list to view or modify.",
                                            order = 1,
                                            width = "full",
                                            values = function ()
                                                local v = {
                                                    ["zzzzzzzzzz"] = "|cFF00FF00Create a New Action List|r"
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

                                        actionID = {
                                            type = "select",
                                            name = "Select an Entry",
                                            desc = "Select the entry to modify in this action list.",
                                            order = 2,
                                            width = "full",
                                            values = function ()
                                                local v = {}

                                                local list = rawget( Hekili.DB.profile.packs[ pack ].lists, packControl.listName )

                                                if list then
                                                    local last = 0

                                                    for i, entry in ipairs( list ) do
                                                        local key = format( "%04d", i )
                                                        local action = entry.action
                                                        local desc
                                                        
                                                        if not action then action = "Unassigned"
                                                        else action = class.abilities[ action ] and class.abilities[ action ].name or action end

                                                        local warning = false

                                                        local scriptID = pack .. ":" .. packControl.listName .. ":" .. i
                                                        local script = Hekili.Scripts.DB[ scriptID ]

                                                        if script and script.Error then warning = true end

                                                        if entry.caption and entry.caption:len() > 0 then
                                                            desc = entry.caption

                                                        elseif entry.action == "variable" then
                                                            desc = format( "|cff00ccff%s|r = |cffffd100%s|r", entry.var_name or "unassigned", entry.value or "nothing" )

                                                            if entry.criteria and entry.criteria:len() > 0 then
                                                                desc = format( "%s, if |cffffd100%s|r", desc, entry.criteria )
                                                            end

                                                        elseif entry.action == "call_action_list" or entry.action == "run_action_list" then
                                                            desc = "|cff00ccff" .. ( entry.list_name or "unassigned" ) .. "|r"
                                                            if entry.criteria and entry.criteria:len() > 0 then desc = desc .. ", if |cffffd100" .. entry.criteria .. "|r" end

                                                        elseif entry.criteria and entry.criteria:len() > 0 then
                                                            desc = entry.criteria 
                                                        
                                                        end

                                                        if desc then desc = desc:gsub( "[\r\n]", "" ) end

                                                        local color = warning and "|cFFFF0000" or "|cFFFFD100"

                                                        if desc then
                                                            v[ key ] = color .. i .. ".|r " .. action .. " - " .. "|cFFFFD100" .. desc .. "|r"
                                                        else
                                                            v[ key ] = color .. i .. ".|r " .. action
                                                        end
                                                        last = i + 1
                                                    end

                                                    v.zzzzzzzzzz = "|cFF00FF00Create a New Action Entry|r"

                                                end

                                                return v
                                            end,
                                            hidden = function ()
                                                return packControl.listName == "zzzzzzzzzz"
                                            end,
                                        },
                                    }
                                },

                                actionGroup = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 2,
                                    hidden = function ()
                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                        if packControl.listName == "zzzzzzzzzz" or rawget( p.lists, packControl.listName ) == nil or packControl.actionID == "zzzzzzzzzz" then
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
                                            args = {
                                                enabled = {
                                                    type = "toggle",
                                                    name = "Enabled",
                                                    desc = "If disabled, this entry will not be shown even if its criteria are met.",
                                                    order = 1,
                                                    width = "full",
                                                },

                                                position = {
                                                    type = "select",
                                                    name = "Position",
                                                    desc = "Use this box to move this entry to another position in this Action List.",
                                                    order = 2,
                                                    values = function ()
                                                        local v = {}
                                                        
                                                        local p = rawget( Hekili.DB.profile.packs, pack )

                                                        for i = 1, #p.lists[ packControl.listName ] do
                                                            v[ i ] = i
                                                        end
            
                                                        return v
                                                    end,
                                                },        

                                                topRow = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 3,
                                                    args = {
                                                        action = {
                                                            type = "select",
                                                            name = "Action",
                                                            desc = "Select the action that will be recommended when this entry's criteria are met.",
                                                            values = class.abilityList,
                                                            order = 1,
                                                            width = "double",
                                                        },

                                                        --[[ invalid = {
                                                            type = "description",
                                                            name = function () return GetListEntry( pack ).action end,
                                                            desc = "This action is not supported.  Choose another at left.",
                                                            order = 1.5,
                                                        }, ]]

                                                        caption = {
                                                            type = "input",
                                                            name = "Caption",
                                                            desc = "Captions are short descriptions that can appear on the icon of a recommended ability.\n" ..
                                                                "This can be useful for understanding why an ability was recommended at a particular time.",
                                                            order = 2,
                                                            width = "single",
                                                            validate = function( info, val )
                                                                if val:len() > 20 then return "Captions should be 10 characters or less." end
                                                                return true
                                                            end,
                                                            hidden = function()
                                                                local e = GetListEntry( pack )
                                                                local ability = e.action and class.abilities[ e.action ]
                                                                
                                                                return not ability or ( ability.id < 0 and ability.id > -10 )
                                                            end,
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
                                                            order = 4,
                                                            -- width = "full",
                                                            hidden = function ()
                                                                local e = GetListEntry( pack )
                                                                return not ( e.action == "call_action_list" or e.action == "run_action_list" )
                                                            end,                                                    
                                                        },
            
                                                        potion = {
                                                            type = "select",
                                                            name = "Potion",
                                                            order = 4,
                                                            -- width = "full",
                                                            values = class.potionList,
                                                            hidden = function ()
                                                                local e = GetListEntry( pack )
                                                                return e.action ~= "potion"
                                                            end,
                                                        },

                                                        sec = {
                                                            type = "input",
                                                            name = "Seconds",
                                                            order = 4,
                                                            hidden = function ()
                                                                local e = GetListEntry( pack )
                                                                return e.action ~= "wait"
                                                            end,
                                                        }
                                                    }
                                                },

                                                modVariable = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "Variable",
                                                    order = 5,
                                                    args = {
                                                        op = {
                                                            type = "select",
                                                            name = "Operation",
                                                            values = {
                                                                set = "Set Value",
                                                                max = "Maximum Value",
                                                                setif = "Set Value If...",
                                                                add = "Add Value",
                                                                sub = "Subtract Value",
                                                                min = "Minimum Value"
                                                            },
                                                            order = 1,
                                                            width = "single",
                                                        },

                                                        var_name = {
                                                            type = "input",
                                                            name = "Name",
                                                            desc = "Specify a name for this variable.  Variables must be lowercase with no spaces or symbols aside from the underscore.",
                                                            validate = function( info, val )
                                                                if val:len() < 3 then return "Variables must be at least 3 characters in length." end

                                                                local check = formatKey( val )
                                                                if check ~= val then return "Invalid characters entered.  Try again." end

                                                                return true
                                                            end,
                                                            order = 2,
                                                            width = "double",
                                                        },

                                                        value = {
                                                            type = "input",
                                                            name = "Value",
                                                            desc = "Provide the value to store (or calculate) when this variable is invoked.",
                                                            order = 6,
                                                            width = "full",
                                                            multiline = 3,
                                                            dialogControl = "HekiliCustomEditor",
                                                            arg = function( info )
                                                                local pack, list, action = info[ 2 ], packControl.listName, tonumber( packControl.actionID )        
                                                                local results = {}
        
                                                                state.reset()

                                                                local apack = rawget( self.DB.profile.packs, pack )

                                                                -- Let's load variables, just in case.
                                                                for name, alist in pairs( apack.lists ) do
                                                                    for i, entry in ipairs( alist ) do
                                                                        if name ~= list or i ~= action then
                                                                            if entry.action == "variable" then
                                                                                local scriptID = pack .. ":" .. name .. ":" .. i
                                                                                scripts:ImportModifiers( scriptID )
                                                                                local vname = state.args.var_name

                                                                                if vname then state.variable[ "_" .. vname ] = scriptID end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                                
                                                                local entry = apack and apack.lists[ list ]
                                                                entry = entry and entry[ action ]        
        
                                                                state.this_action = entry.action

                                                                local scriptID = pack .. ":" .. list .. ":" .. action
        
                                                                scripts:ImportModifiers( scriptID )
                                                                scripts:StoreValues( results, scriptID, "value" )
                                                                
                                                                return results, list, action
                                                            end,
                                                            hidden = function ()
                                                                local e = GetListEntry( pack )
                                                                return e.action ~= "variable"
                                                            end,
                                                        },
                                                    },
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action ~= "variable"
                                                    end,
                                                },

                                                modPooling = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "Pooling",
                                                    order = 5,
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
                                                            width = "full",
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
                                                            width = "full",
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
                                                            width = "full",
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
                                                    order = 10,
                                                    width = "full",
                                                    multiline = 6,
                                                    dialogControl = "HekiliCustomEditor",
                                                    arg = function( info )
                                                        local pack, list, action = info[ 2 ], packControl.listName, tonumber( packControl.actionID )        
                                                        local results = {}

                                                        state.reset()

                                                        local apack = rawget( self.DB.profile.packs, pack )

                                                        -- Let's load variables, just in case.
                                                        for name, alist in pairs( apack.lists ) do
                                                            for i, entry in ipairs( alist ) do
                                                                if name ~= list or i ~= action then
                                                                    if entry.action == "variable" then
                                                                        local scriptID = pack .. ":" .. name .. ":" .. i
                                                                        scripts:ImportModifiers( scriptID )
                                                                        local vname = state.args.var_name

                                                                        if vname then state.variable[ "_" .. vname ] = scriptID end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                        
                                                        local entry = apack and apack.lists[ list ]
                                                        entry = entry and entry[ action ]        

                                                        state.this_action = entry.action

                                                        local scriptID = pack .. ":" .. list .. ":" .. action

                                                        scripts:ImportModifiers( scriptID )
                                                        scripts:StoreValues( results, scriptID )
                                                        
                                                        return results, list, action
                                                    end,                                      
                                                        --[[ local pack, list, action = info[ 2 ], packControl.listName, tonumber( packControl.actionID )

                                                        local entry = rawget( self.DB.profile.packs, pack )
                                                        entry = entry and entry.lists[ list ]
                                                        entry = entry and entry[ action ]

                                                        local results = {}

                                                        state.reset()
                                                        state.this_action = entry.action

                                                        local scriptID = pack .. ":" .. list .. ":" .. action

                                                        scripts:ImportModifiers( scriptID )
                                                        scripts:StoreValues( results, scriptID )
                                                        
                                                        return results, list, action
                                                    end,
                                                    hidden = function ()
                                                        local e = GetListEntry( pack )
                                                        return e.action == "use_items"
                                                    end, ]]
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

                                                        return not ability or ( ability.id < 0 and ability.id > -100 )
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

                                                modCooldown = {
                                                    type = "group",
                                                    inline = true,
                                                    name = "",
                                                    order = 22,
                                                    args = {
                                                        enable_line_cd = {
                                                            type = "toggle",
                                                            name = "Line Cooldown",
                                                            desc = "If enabled, this entry cannot be recommended unless the specified amount of time has passed since its last use.",
                                                            order = 1,
                                                        },

                                                        line_cd = {
                                                            type = "input",
                                                            name = "Entry Cooldown",
                                                            desc = "If set, this entry cannot be recommended unless this time has passed since the last time the ability was used.",
                                                            order = 2,
                                                            width = "double", 
                                                            disabled = function( info )
                                                                local e = GetListEntry( pack )
                                                                return not e.enable_line_cd
                                                            end,
                                                        },
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
                                                    order = 23,
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

                                                deleteHeader = {
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

                                                        table.remove( p.lists[ packControl.listName ], id )

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
                                },

                                newListGroup = {
                                    type = "group",
                                    inline = true,
                                    name = "",
                                    order = 3,
                                    hidden = function ()
                                        return packControl.listName ~= "zzzzzzzzzz"
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
                                            width = "full",
                                        },

                                        createList = {
                                            type = "execute",
                                            name = "Create New List",
                                            order = 2,
                                            disabled = function() return packControl.newListName == nil end,
                                            func = function ()
                                                local p = rawget( Hekili.DB.profile.packs, pack )
                                                p.lists[ packControl.newListName ] = { {} }                                                
                                                packControl.listName = packControl.newListName
                                                packControl.actionID = "0001"
                                                packControl.newListName = nil
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
                                        return packControl.listName == "zzzzzzzzzz" or packControl.actionID ~= "zzzzzzzzzz"
                                    end,
                                    args = {
                                        createEntry = {
                                            type = "execute",
                                            name = "Create New Entry",
                                            order = 1,
                                            func = function ()
                                                local p = rawget( Hekili.DB.profile.packs, pack )
                                                table.insert( p.lists[ packControl.listName ], {} )
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
                                    name = "Export String",
                                    multiline = 5,
                                    get = function( info )
                                        return self:SerializeActionPack( pack )
                                    end,
                                    set = function () return end,
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

        db.args.packs = packs
    end

end


do
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
    end


    local ACD = LibStub( "AceConfigDialog-3.0" )

    local modeTypes = {
        oneAuto = 1,
        oneSingle = 2,
        oneAOE = 3,
        twoDisplays = 4,
        reactive = 5,
    }    

    local function SetToggle( info, val )
        local self = Hekili
        local p = self.DB.profile
        local n = #info
        local bind, option = info[ 2 ], info[ n ]

        local toggle = p.toggles[ bind ]
        if not toggle then return end

        if option == 'value' then
            if bind == 'pause' then self:TogglePause()            
            else self:FireToggle( bind ) end
        
        elseif option == 'type' then
            toggle.type = val

            if val == "AutoSingle" and not ( toggle.value == "automatic" or toggle.value == "single" ) then toggle.value = "automatic" end
            if val == "AutoDual" and not ( toggle.value == "automatic" or toggle.value == "dual" ) then toggle.value = "automatic" end
            if val == "SingleAOE" and not ( toggle.value == "single" or toggle.value == "aoe" ) then toggle.value = "single" end
            if val == "ReactiveDual" and not toggle.value == "reactive" then toggle.value = "reactive" end

        elseif option == 'key' then
            for t, data in pairs( p.toggles ) do
                if data.key == val then data.key = "" end
            end
            
            toggle.key = val
            self:OverrideBinds()
        
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

                pause = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 1,
                    args = {
                        key = {
                            type = 'keybinding',
                            name = 'Pause',
                            desc = "Set a key to pause processing of your action lists. Your current display(s) will freeze, and you can mouseover each icon to see information about the displayed action.",
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
                    order = 2,
                    args = {
                        key = {
                            type = 'keybinding',
                            name = 'Snapshot',
                            desc = "Set a key to make a snapshot (without pausing) that can be viewed on the Snapshots tab.  This can be useful information for testing and debugging.",
                            order = 1,
                        },
                    }
                },

                mode = {
                    type = "group",
                    inline = true,
                    name = "",
                    order = 3,
                    args = {
                        key = {
                            type = 'keybinding',
                            name = 'Display Mode',
                            desc = "Pressing this key will force the addon to switch between one or two displays.  You can specify the modes available as well.\n" ..
                            "|cFFFFD100Automatic|r:  In this mode, the addon will show one display that automatically adjusts to the number of enemies detected.\n" ..
                            "|cFFFFD100Dual Display|r:  In this mode, the addon will show two displays; the Primary display will show single-target recommendations and the AOE display will show recommendations for more enemies.",
                        order = 1,
                        },

                        type = {
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
                        },

                        value = {
                            type = "select",
                            name = "Mode",
                            desc = function( info, val )
                                local mType = self.DB.profile.toggles.mode.type
                                
                                local output = "Select your Display Mode."

                                if mType == "AutoSingle" or mType == "AutoDual" then
                                    output = output .. "\n\n|cffffd100Automatic|r - Recommendations are based on the number of detected enemies."
                                end

                                if mType == "AutoSingle" or mType == "SingleAOE" then
                                    output = output .. "\n\n|cffffd100Single|r - Recommendations are generated assuming a single target is active."
                                end

                                if mType == "SingleAOE" then
                                    output = output .. "\n\n|cffffd100AOE|r - Recommendations are generated assuming multiple enemies are active."
                                end

                                if mType == "AutoDual" then
                                    output = output .. "\n\n|cffffd100Dual|r - The Primary display shows single-target recommendations and the AOE display shows multi-target recommendations."
                                end

                                if mType == "ReactiveDual" then
                                    output = output .."\n\n|cffffd100Reactive|r - The mode toggle is disabled; the addon will also display the AOE display when more enemies are detected."
                                end

                                return output
                            end,
                            values = function( info, val )
                                local mType = self.DB.profile.toggles.mode.type

                                local v = {
                                    automatic = "Automatic",
                                    single = "Single",
                                    aoe = "AOE",
                                    dual = "Dual",
                                    reactive = "Reactive"
                                }

                                if mType == "AutoSingle" then
                                    v.aoe = nil
                                    v.dual = nil
                                    v.reactive = nil
                                elseif mType == "SingleAOE" then
                                    v.automatic = nil
                                    v.dual = nil
                                    v.reactive = nil
                                elseif mType == "AutoDual" then
                                    v.single = nil
                                    v.aoe = nil
                                    v.reactive = nil
                                elseif mType == "ReactiveDual" then
                                    v.automatic = nil
                                    v.single = nil
                                    v.aoe = nil
                                    v.dual = nil
                                end

                                return v
                            end,
                            width = "single",
                            order = 3,
                        }
                    },
                },

                cooldowns = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 4,
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

                        bloodlust = {
                            type = "toggle",
                            name = "Bloodlust Override",
                            desc = "If checked, when Bloodlust (or similar haste effects) are active, the addon will recommend cooldown abilities even if Show Cooldowns is not checked.",
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
                    order = 6,
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
                    order = 7,
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

                specLinks = {
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
                                        ACD:SelectGroup( "Hekili", "specs", sName )
                                    end,
                                }
                                hide = false
                            end
                        end

                        return hide
                    end,
                }
            }
        }
    end
end


do
    -- Generate a spec skeleton.
    local listener = CreateFrame( "Frame" )
    
    local indent = ""
    local output = {}
                        
    local function key( s )
        return ( lower( s or '' ):gsub( "[^a-z0-9_ ]", "" ):gsub( "%s", "_" ) )
    end

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
            for j = 1, 7 do
                for k = 1, 3 do
                    local tID, name, _, _, _, sID = GetTalentInfoBySpecialization( GetSpecialization(), j, k )
                    name = key( name )
                    insert( talents, { name = name, talent = tID, spell = sID } )
                end
            end

            wipe( pvptalents )
            for i = 1, 2 do
                local row = C_SpecializationInfo.GetPvpTalentSlotInfo( i )

                for i, tID in ipairs( row.availableTalentIDs ) do
                    local _, name, _, _, _, sID = GetPvpTalentInfoByID( tID )
                    name = key( name )
                    insert( pvptalents, { name = name, talent = tID, spell = sID } )
                end
            end

            local haste = UnitSpellHaste( "player" )
            haste = 1 + ( haste / 100 )

            for i = 1, GetNumSpellTabs() do
                local tab, _, offset, n = GetSpellTabInfo( i )

                if tab == spec then
                    for j = offset, offset + n do
                        local name, _, texture, castTime, minRange, maxRange, spellID = GetSpellInfo( j, "spell" )
                        
                        if name and spellID ~= mastery_spell then 
                            local token = key( name )
                            
                            castTime = castTime / 1000

                            local cost, min_cost, max_cost, cost_per_sec, cost_percent, resource
                            
                            local costs = GetSpellPowerCost( spellID )
                            
                            if costs then
                                for k, v in pairs( costs ) do
                                    if not v.hasRequiredAura or IsPlayerSpell( v.requiredAuraID ) then
                                        cost = v.costPercent > 0 and v.costPercent / 100 or v.cost
                                        cost_per_sec = v.costPerSecond
                                        resource = key( v.name )
                                        break
                                    end
                                end
                            end
                            
                            local passive = IsPassiveSpell( spellID )
                            local harmful = IsHarmfulSpell( spellID )
                            local helpful = IsHelpfulSpell( spellID )
                            
                            local _, charges, _, recharge = GetSpellCharges( spellID )
                            local cooldown
                            if recharge then cooldown = recharge
                            else
                                cooldown = GetSpellBaseCooldown( spellID )
                                if cooldown then cooldown = cooldown / 1000 end
                            end
                            
                            local selfbuff = SpellIsSelfBuff( spellID )
                            local talent = IsTalentSpell( spellID )
                            
                            if selfbuff or passive then
                                auras[ token ] = auras[ token ] or {}
                                auras[ token ].id = spellID
                            end
                            
                            if not passive then
                                local a = abilities[ token ] or {}

                                -- a.key = token
                                a.desc = GetSpellDescription()
                                if a.desc then a.desc = a.desc:gsub( "\n", " " ):gsub( "\r", " " ):gsub( " ", " " ) end
                                a.id = spellID
                                a.spend = cost
                                a.spendType = resource
                                a.spendPerSec = cost_per_sec
                                a.cast = castTime
                                a.gcd = "spell"

                                a.texture = texture

                                if talent then a.talent = token end

                                if talents[ sKey ] then
                                    a.talent = sKey
                                end

                                a.startsCombat = not helpful
                                
                                a.cooldown = cooldown
                                if a.charges and a.charges > 1 then 
                                    a.charges = charges
                                    a.recharge = recharge
                                end

                                abilities[ token ] = a
                            end
                        end
                    end
                end
            end
        elseif event == "SPELLS_CHANGED" then
            local haste = UnitSpellHaste( "player" )
            haste = 1 + ( haste / 100 )

            for i = 1, GetNumSpellTabs() do
                local tab, _, offset, n = GetSpellTabInfo( i )

                if tab == spec then
                    for j = offset, offset + n do
                        local name, _, texture, castTime, minRange, maxRange, spellID = GetSpellInfo( j, "spell" )
                        
                        if name and spellID ~= mastery_spell then 
                            local token = key( name )
                            
                            if castTime % 10 > 0 then
                                -- We can catch hasted cast times 90% of the time...
                                castTime = castTime * haste
                            end
                            castTime = castTime / 1000

                            local cost, min_cost, max_cost, spendPerSec, cost_percent, resource
                            
                            local costs = GetSpellPowerCost( spellID )
                            
                            if costs then
                                for k, v in pairs( costs ) do
                                    if not v.hasRequiredAura or IsPlayerSpell( v.requiredAuraID ) then
                                        cost = v.costPercent > 0 and v.costPercent / 100 or v.cost
                                        cost_per_sec = v.costPerSecond
                                        resource = key( v.name )
                                        break
                                    end
                                end
                            end
                            
                            local passive = IsPassiveSpell( spellID )
                            local harmful = IsHarmfulSpell( spellID )
                            local helpful = IsHelpfulSpell( spellID )
                            
                            local _, charges, _, recharge = GetSpellCharges( spellID )
                            local cooldown
                            if recharge then cooldown = recharge
                            else
                                cooldown = GetSpellBaseCooldown( spellID )
                                if cooldown then cooldown = cooldown / 1000 end
                            end
                            
                            local selfbuff = SpellIsSelfBuff( spellID )
                            local talent = IsTalentSpell( spellID )
                            
                            if selfbuff or passive then
                                auras[ token ] = auras[ token ] or {}
                                auras[ token ].id = spellID
                            end
                            
                            if not passive then
                                local a = abilities[ token ] or {}

                                -- a.key = token
                                a.desc = GetSpellDescription()
                                if a.desc then a.desc = a.desc:gsub( "\n", " " ):gsub( "\r", " " ):gsub( " ", " " ) end
                                a.id = spellID
                                a.spend = cost
                                a.spendType = resource
                                a.spendPerSec = cost_per_sec
                                a.cast = castTime
                                a.gcd = "spell"

                                a.texture = texture

                                if talent then a.talent = token end

                                if talents[ sKey ] then
                                    a.talent = sKey
                                end

                                a.startsCombat = not helpful
                                
                                a.cooldown = cooldown
                                a.charges = charges
                                a.recharge = recharge

                                abilities[ token ] = a
                            end
                        end
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
        listener:SetScript( "OnEvent", skeletonHandler )

        skeletonHandler( listener, "PLAYER_SPECIALIZATION_CHANGED", "player" )
        skeletonHandler( listener, "SPELLS_CHANGED" )
    end

    local SpecInfo = ""



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
                        return skeleton or ""
                    end,
                    multiline = 25,
                    width = "full"
                },
                regen = {
                    type = "execute",
                    name = "Generate Skeleton",
                    order = 2,
                    func = function()
                        indent = ""
                        wipe( output )
                        
                        append( "if UnitClassBase( 'player' ) == '" .. UnitClassBase( "player" ) .. "' then" )
                        increaseIndent()

                        append( "local spec = Hekili:NewSpecialization( " .. specID .. " )\n" )

                        for k, i in pairs( resources ) do
                            append( "spec:RegisterResource( Enum.PowerType." .. k .. " )" )
                        end

                        append( "" )
                        append( "-- Talents" )
                        append( "spec:RegisterTalents( {" )                        
                        increaseIndent()

                        for i, tal in ipairs( talents ) do
                            append( tal.name .. " = " .. tal.talent .. ", -- " .. tal.spell .. ( ( i % 3 == 0 and i < #talents ) and "\n" or "" ) )
                        end

                        decreaseIndent()
                        append( "} )\n" )

                        append( "-- PvP Talents" )
                        append( "spec:RegisterPvpTalents( { " )
                        increaseIndent()

                        for i, tal in ipairs( pvptalents ) do
                            append( tal.name .. " = " .. tal.talent .. ", -- " .. tal.spell )
                        end
                        decreaseIndent()
                        append( "} )\n" )

                        append( "-- Auras" )
                        append( "spec:RegisterAuras( {" )
                        increaseIndent()

                        for k, aura in orderedPairs( auras ) do
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
                        append( "} )\n" )


                        append( "-- Abilities" )
                        append( "spec:RegisterAbilities( {" )
                        increaseIndent()

                        count = 1
                        for k, a in orderedPairs( abilities ) do
                            if count > 1 then append( "\n" ) end
                            count = count + 1
                            append( k .. " = {" )
                            increaseIndent()
                            appendAttr( a, "id" )
                            appendAttr( a, "cast" )
                            appendAttr( a, "charges" )
                            appendAttr( a, "cooldown" )
                            appendAttr( a, "recharge" )
                            appendAttr( a, "gcd" )
                            append( "" )
                            appendAttr( a, "spend" )
                            appendAttr( a, "spendPerSec" )
                            appendAttr( a, "spendType" )
                            if a.spend ~= nil or a.spendPerSec ~= nil or a.spendType ~= nil then
                                append( "" )
                            end
                            appendAttr( a, "talent" )
                            if a.cooldown >= 60 then append( "toggle = \"cooldowns\",\n" ) end
                            if a.talent ~= nil then append( "" ) end
                            appendAttr( a, "startsCombat" )
                            appendAttr( a, "texture" )
                            append( "" )
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
                        append( "} )\n" )

                        skeleton = table.concat( output, "\n" )
                    end,
                }
            },
            hidden = function()
                return not Hekili.Skeleton
            end,
        }
    
    end
end


function Hekili:GenerateProfile()
    local s = state

    local spec = s.spec.key

    local talents
    for k, v in orderedPairs( s.talent ) do
        if v.enabled then
            if talents then talents = format( "%s\n    %s", talents, k )
            else talents = k end
        end
    end

    local traits
    for k, v in orderedPairs( s.artifact ) do
        if v.rank > 0 then
            if traits then traits = format( "%s\n    %s=%d", traits, k, v.rank )
            else traits = format( "%s=%d", k, v.rank ) end
        end
    end

    local sets
    for k, v in orderedPairs( class.gear ) do
        if s.set_bonus[ k ] > 0 then
            if sets then sets = format( "%s\n    %s=%d", sets, k, s.set_bonus[k] )
            else sets = format( "%s=%d", k, s.set_bonus[k] ) end
        end
    end

    local gear
    for k, v in pairs( state.set_bonus ) do
        if type(k) == 'string' and v > 0 then
            if gear then gear = format( "%s\n    %s=%d", gear, k, v )
            else gear = format( "    %s=%d", k, v ) end
        end
    end

    return format( "build: %s\n" ..
        "level: %d\n" ..
        "class: %s\n" ..
        "spec: %s\n\n" ..
        "talents: %s\n\n" ..
        "traits: %s\n\n" ..
        "sets/legendaries/artifacts: %s\n\n" ..
        "gear: %s",
        Hekili.Version or "no info",
        UnitLevel( 'player' ) or 0,
        class.file or "NONE",
        spec or "none",
        talents or "none",
        traits or "none",
        sets or "none",
        gear or "none" )
end


function Hekili:GetOptions()
    local Options = {
        name = "Hekili",
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
                    topRow = {
                        type = "group",
                        inline = true,
                        name = "",
                        order = 1,
                        width = "full",
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
                        },                      
                    },

                    welcome = {
                        type = "group",
                        name = "",
                        inline = true,
                        order = 5,
                        args = {
                            desc = {
                                type = 'description',
                                name = function ()
                                    local output = "\n|cFF00CCFFTHANK YOU TO ALL PATRONS SUPPORTING THIS ADDON'S DEVELOPMENT!|r\n\n"
        
                                    for i, name in ipairs( ns.Patrons ) do
                                        if i == 1 then
                                            output = output .. name
                                        elseif i == #ns.Patrons then
                                            output = output .. ", and " .. name .. "."
                                        else
                                            output = output .. ", " .. name
                                        end
                                    end
                                    
                                    output = output .. "\n\nPlease see the |cFFFFD100Issue Reporting|r tab for information about reporting bugs.\n"
                                    return output
                                end,
                                image = "Interface\\Addons\\Hekili\\Textures\\LOGO-ORANGE",
                                imageWidth = 150,
                                imageHeight = 150,
                                fontSize = "medium",
                                order = 2,
                                width = "full"
                            },
        
                            curse = {
                                type = 'input',
                                name = "Twitch / Curse",
                                order = 3,
                                get = function () return "https://www.curse.com/addons/wow/hekili/" end,
                                set = function () end,
                                width = "full",
                            },
        
                            github = {
                                type = "input",
                                name = "GitHub",
                                order = 4,
                                get = function () return "http://github.com/Hekili/hekili/" end,
                                set = function () end,
                                width = "full",
                            },
                        }
                    },
                }
            },

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
                    },                },
                plugins = {
                    actions = {}
                }
            },

            items = {
                type = "group",
                name = "Gear and Trinkets",
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
                        get = function() return "https://wow.curseforge.com/projects/hekili/issues" end,
                        set = function() return end,
                    }
                }
            },

            snapshots = {
                type = "group",
                name = "Snapshots",
                order = 86,
                args = {                    
                    Display = {
                        type = "select",
                        name = "Display",
                        desc = "Select the display to show (if any snapshots have been taken).",
                        order = 1,
                        values = function( info )
                            local displays = snapshots.displays
                            
                            for k in pairs( ns.snapshots ) do
                                displays[k] = k
                            end
                            
                            return displays
                        end,
                        set = function( info, val )
                            snapshots.display = val
                        end,
                        get = function( info )
                            return snapshots.display
                        end,
                        width = "double"
                    },
                    SnapID = {
                        type = "select",
                        name = "Snapshot",
                        desc = "Select the display to show (if any snapshots have been taken).",
                        order = 2,
                        values = function( info )
                            for k, v in pairs( ns.snapshots ) do
                                snapshots.snaps[k] = snapshots.snaps[k] or {}
                                
                                for idx in pairs( v ) do
                                    snapshots.snaps[k][idx] = idx
                                end
                            end
                            
                            return snapshots.display and snapshots.snaps[ snapshots.display ] or snapshots.empty
                        end,
                        set = function( info, val )
                            snapshots.snap[ snapshots.display ] = val
                        end,
                        get = function( info )
                            return snapshots.snap[ snapshots.display ]
                        end
                    },
                    Snapshot = {
                        type = 'input',
                        name = "Log",
                        desc = "Any available debug information is available here.",
                        order = 3,
                        get = function( info )
                            local display = snapshots.display
                            local snap = display and snapshots.snap[ display ]
                            
                            return snap and ns.snapshots[ display ][ snap ]
                        end,
                        disabled = false,
                        multiline = 25,
                        width = "full",
                    }
                }
            },
        },

        plugins = {
            specializations = {},
        }
    }
   
    self:EmbedToggleOptions( Options )

    self:EmbedDisplayOptions( Options )

    self:EmbedPackOptions( Options )

    self:EmbedAbilityOptions( Options )
    
    self:EmbedItemOptions( Options )

    self:EmbedSpecOptions( Options )

    self:EmbedSkeletonOptions( Options )
    
    return Options
end


function Hekili:TotalRefresh()
    
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
    
    self:RunOneTimeFixes()
    ns.checkImports()
    
    -- self:LoadScripts()
    self:RefreshOptions()
    self:UpdateDisplayVisibility()
    self:BuildUI()

    self:OverrideBinds()

    LibStub("LibDBIcon-1.0"):Refresh( "Hekili", self.DB.profile.iconStore )
    
end


function Hekili:RefreshOptions()
    if not self.Options then return end

    -- db.args.abilities = ns.AbilitySettings()

    self:EmbedDisplayOptions()
    self:EmbedPackOptions()
    self:EmbedSpecOptions()
    self:EmbedAbilityOptions()
    self:EmbedItemOptions()

    self.Options.args.class = ns.ClassSettings()
    
    -- Until I feel like making this better at managing memory.
    collectgarbage()
end


function Hekili:GetOption( info, input )
    local category, depth, option = info[1], #info, info[#info]
    local profile = Hekili.DB.profile
    
    if category == 'general' then
        return profile[ option ]
        
    --[[ elseif category == 'class' then
        if info[2] == 'toggles' then
            return profile['Toggle '..option]
            
        elseif info[2] == 'settings' then
            return profile['Class Option: '..option]

        end ]]
            
    --[[ elseif category == 'abilities' then
        local ability = info[2]

        if option == 'exclude' then return profile.blacklist[ ability ]
        elseif option == 'clash' then return profile.clashes[ ability ] or 0
        elseif option == 'toggle' then return profile.toggles[ ability ] or 'default'
        elseif option:match( "^(%d+):(%d+)$" ) then
            local list, action = option:match( "^(%d+):(%d+)$" )
            list = tonumber( list )
            action = tonumber( action )

            return not profile.actionLists[ list ].Actions[ action ].Enabled
        end

        if profile.trinkets[ ability ] ~= nil then return profile.trinkets[ ability ][ option ] end

        return ]]

    --[[ elseif category == 'notifs' then
        if option == 'Notification X' or option == 'Notification Y' then
            return tostring( profile[ option ] )
        end
        return profile[option] ]]
        
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
    local category, depth, option, subcategory = info[1], #info, info[#info], nil
    local Rebuild, RebuildUI, RebuiltScripts, RebuildOptions, RebuildCache, Select
    local profile = Hekili.DB.profile
    
    if category == 'general' then
        -- We'll preset the option here; works for most options.
        profile[ option ] = input
        
        if option == 'enabled' then
            for i, buttons in ipairs( ns.UI.Buttons ) do
                for j, _ in ipairs( buttons ) do
                    if input == false then
                        buttons[j]:Hide()
                    else
                        buttons[j]:Show()
                    end
                end
            end
            
            if input == true then self:Enable()
            else self:Disable() end
            
            return
            
        elseif option == 'minimapIcon' then
            profile.iconStore.hide = input
            
            if LDBIcon then
                if input then
                    LDBIcon:Hide( "Hekili" )
                else
                    LDBIcon:Show( "Hekili" )
                end
            end
            
        elseif option == 'Audit Targets' then
            return
            
        end
        
        -- General options do not need add'l handling.
        return
        
    --[[ elseif category == 'class' then
        subcategory = info[2]
        
        if subcategory == 'toggles' then
            if option:match("State:") then
                Hekili:ClassToggle( option:match("State: (.-)$") )
            else
                profile[ 'Toggle ' .. option ] = input
                Hekili:OverrideBinds()
            end
            
        elseif subcategory == 'settings' then
            profile[ 'Class Option: '..option] = input

        end ]]
            
    --[[ elseif category == 'abilities' then
        local ability = info[2]

        if option == 'exclude' then profile.blacklist[ ability ] = input
        elseif option == 'clash' then profile.clashes[ ability ] = tonumber( input ) or 0
        elseif option == 'toggle' then profile.toggles[ ability ] = input or 'default'
        elseif option:match( "^(%d+):(%d+)$" ) then
            local list, action = option:match( "^(%d+):(%d+)$" )

            list = tonumber( list )
            action = tonumber( action )

            profile.actionLists[ list ].Actions[ action ].Enabled = not input
            Hekili:UpdateDisplayVisibility()
        elseif profile.trinkets[ ability ] ~= nil then
            profile.trinkets[ ability ][ option ] = input
        end

        Hekili:ForceUpdate()
        return ]]
        
    --[[ elseif category == 'notifs' then
        profile[ option ] = input
        
        if option == 'Notification X' or option == 'Notification Y' then
            profile[ option ] = tonumber( input )
        end
        
        RebuildUI = true ]]
        
    elseif category == 'bindings' then
        
        local revert = profile[ option ]
        profile[ option ] = input
        
        if option:match( "TOGGLE" ) or option == "HEKILI_SNAPSHOT" then
            if GetBindingKey( option ) then
                SetBinding( GetBindingKey( option ) )
            end
            SetBinding( input, option )
            SaveBindings( GetCurrentBindingSet() )
            
        elseif option == 'Mode' then
            profile[option] = revert
            self:ToggleMode()
            
        elseif option == 'Pause' then
            profile[option] = revert
            self:TogglePause()
            return

        elseif option == 'Cooldowns' then
            profile[option] = revert
            self:ToggleCooldowns()
            return

        elseif option == 'Artifact' then
            profile[option] = revert
            self:ToggleArtifact()
            return
            
        elseif option == 'Potions' then
            profile[option] = revert
            self:TogglePotions()
            return
            
        elseif option == 'Hardcasts' then
            profile[option] = revert
            self:ToggleHardcasts()
            return
            
        elseif option == 'Interrupts' then
            profile[option] = revert
            self:ToggleInterrupts()
            return
            
        elseif option == 'Switch Type' then
            if input == 0 then
                if profile['Mode Status'] == 1 or profile['Mode Status'] == 2 then
                    -- Check that the current mode is supported.
                    profile['Mode Status'] = 0
                    self:Print("Switch type updated; reverting to single-target.")
                end
            elseif input == 1 then
                if profile['Mode Status'] == 1 or profile['Mode Status'] == 3 then
                    profile['Mode Status'] = 0
                    self:Print("Switch type updated; reverting to single-target.")
                end
            end
            
        elseif option == 'Mode Status' or option:match("Toggle_") or option == 'BloodlustCooldowns' or option == 'CooldownArtifact' then
            -- do nothing, we're good.
            
        else -- Toggle Names.
            if input:trim() == "" then
                profile[ option ] = nil
            end
            
        end
        
        -- Bindings do not need add'l handling.
        return
        
    elseif category == 'displays' then
        
        -- This is a generic display option/function.
        if depth == 2 then
            
            if option == 'newDisplay' then
                self.DB.profile.displays[ key ] = {}
                self:EmbedDisplayOptions()
                
                C_Timer.After( 0.25, self[ 'ProcessDisplay'..index ] )
                
            elseif option == 'importDisplay' then
                local import = ns.deserializeDisplay( input )
                
                if not import then
                    Hekili:Print("Unable to import from given input string.")
                    return
                end
                
                import.Name = getUniqueName( profile.displays, import.Name )
                table.insert( profile.displays, import )
                
            end
            
            Rebuild = true
            
            -- This is a display (or a hook).
        else
            local dispKey, dispID = info[2], info[2] and tonumber( match( info[2], "^D(%d+)" ) )
            local hookKey, hookID = info[3], info[3] and tonumber( match( info[3], "^P(%d+)" ) )
            local display = dispID and profile.displays[ dispID ]
            
            -- This is a specific display's settings.
            if depth == 3 or not hookID then
                local revert = display[option]
                display[option] = input
                
                if option == 'x' or option == 'y' then
                    display[option] = tonumber( input )
                    RebuildUI = true
                    
                elseif option == 'Name' then
                    Hekili.Options.args.displays.args[ dispKey ].name = input
                    if input ~= revert and display.Default then display.Default = false end
                    
                elseif option == 'enabled' then
                    -- Might want to replace this with RebuildUI = true
                    for i, button in ipairs( ns.UI.Buttons[ dispID ] ) do
                        if not input then
                            button:Hide()
                        else
                            button:Show()
                        end
                    end
                    RebuildUI = true
                    
                elseif option == 'minST' or option == 'maxST' or option == 'minAE' or option == 'maxAE' then
                    -- do nothing, it's already set.
                    
                elseif option == 'spellFlash' then
                    
                elseif option == 'spellFlashColor' or option == 'iconBorderColor' then
                    if type( display[ option ] ~= 'table' ) then display[ option ] = {} end
                    display[ option ].r = input
                    display[ option ].g = select( 1, ... )
                    display[ option ].b = select( 2, ... )
                    display[ option ].a = select( 3, ... )
                    
                elseif option == 'Script' then
                    display[option] = input:trim()
                    RebuildScripts = true
                    
                elseif option == 'Copy To' then
                    local index = #profile.displays + 1
                    
                    profile.displays[ index ] = tableCopy( display )
                    profile.displays[ index ].Name = input
                    profile.displays[ index ].Default = false
                    
                    Rebuild = true
                    
                elseif option == 'Import' then
                    local import = ns.deserializeDisplay( input )
                    
                    if not import then
                        Hekili:Print("Unable to import from given input string.")
                        return
                    end

                    local name = display.Name

                    local validSpecs = { [0] = 1 }
                    
                    for i = 1, GetNumSpecializations() do
                        validSpecs[ GetSpecializationInfo( i ) ] = 1
                    end

                    if not validSpecs[ import.Specialization ] then import.Specialization = profile.displays[ dispID ].Specialization end

                    profile.displays[ dispID ] = import
                    profile.displays[ dispID ].Name = name
                    
                    Rebuild = true
                    
                elseif option == 'Icons Shown' then
                    if ns.queue[ dispID ] then
                        for i = input + 1, #ns.queue[ dispID ] do
                            ns.queue[ dispID ][ i ] = nil
                        end
                    end
                    
                end
                
                RebuildUI = true
                
                -- This is a priority hook.
            else
                local hook = display.Queues[ hookID ]
                
                if option == 'Move' then
                    local placeholder = table.remove( display.Queues, hookID )
                    table.insert( display.Queues, input, placeholder )
                    Rebuild, Select = true, 'P'..input
                    
                elseif option == 'Script' then
                    hook[ option ] = input:trim()
                    RebuildScripts = true
                    
                elseif option == 'Name' then
                    Hekili.Options.args.displays.args[ dispKey ].args[ hookKey ].name = '|cFFFFD100' .. hookID .. '.|r ' .. input
                    hook[ option ] = input
                    
                elseif option == 'Action List' or option == 'Enabled' then
                    hook[ option ] = input
                    RebuildCache = true
                    
                else
                    hook[ option ] = input
                    
                end
                
            end
        end
        
    elseif category == 'actionLists' then
        
        if depth == 2 then
            
            if option == 'New Action List' then
                local key = ns.newActionList( input )
                if key then
                    RebuildOptions, RebuildCache = true, true
                end
                
            elseif option == 'Import Action List' then
                local import = ns.deserializeActionList( input )
                
                if not import or type( import ) == 'string' then
                    Hekili:Print("Unable to import from given input string.")
                    return
                end
                
                import.Name = getUniqueName( profile.actionLists, import.Name )
                profile.actionLists[ #profile.actionLists + 1 ] = import
                Rebuild = true
                
            end
            
        else
            local listKey, listID = info[2], info[2] and tonumber( match( info[2], "^L(%d+)" ) )
            local actKey, actID = info[3], info[3] and tonumber( match( info[3], "^A(%d+)" ) )
            local list = profile.actionLists[ listID ]
            
            if depth == 3 or not actID then
                
                local revert = list[ option ]
                list[option] = input
                
                if option == 'Name' then
                    Hekili.Options.args.actionLists.args[ listKey ].name = input
                    if input ~= revert and list.Default then list.Default = false end
                    
                elseif option == 'Enabled' or option == 'Specialization' then
                    RebuildCache = true
                    
                elseif option == 'Script' then
                    list[ option ] = input:trim()
                    RebuildScripts = true
                    
                    -- Import/Exports
                elseif option == 'Copy To' then
                    list[option] = nil
                    
                    local index = #profile.actionLists + 1
                    
                    profile.actionLists[ index ] = tableCopy( list )
                    profile.actionLists[ index ].Name = input
                    profile.actionLists[ index ].Default = false
                    
                    Rebuild = true
                    
                elseif option == 'Import Action List' then
                    list[option] = nil
                    
                    local import = ns.deserializeActionList( input )
                    
                    if not import or type( import ) == 'string' then
                        Hekili:Print("Unable to import from given import string.")
                        return
                    end
                    
                    import.Name = list.Name
                    table.remove( profile.actionLists, listID )
                    table.insert( profile.actionLists, listID, import )
                    -- profile.actionLists[ listID ] = import
                    Rebuild = true
                    
                elseif option == 'SimulationCraft' then
                    list[option] = nil
                    
                    local import, warnings = self:ImportSimulationCraftActionList( input )
                    
                    if warnings then
                        Hekili:Print( "|cFFFF0000WARNING:|r\nThe following issues were noted during actionlist import." )
                        for i = 1, #warnings do
                            Hekili:Print( warnings[i] )
                        end
                    end
                    
                    if not import then
                        Hekili:Print( "No actions were successfully imported." )
                        return
                    end
                    
                    wipe( list.Actions )
                    
                    for i, entry in ipairs( import ) do
                        
                        local key = ns.newAction( listID, class.abilities[ entry.Ability ].name )
                        
                        local action = list.Actions[ i ]
                        
                        action.Ability = entry.Ability
                        action.Args = entry.Args
                        
                        action.CycleTargets = entry.CycleTargets
                        action.MaximumTargets = entry.MaximumTargets
                        action.CheckMovement = entry.CheckMovement or false
                        action.Movement = entry.Movement
                        action.ModName = entry.ModName or ''
                        action.ModVarName = entry.ModVarName or ''
                        
                        action.Indicator = 'none'
                        
                        action.Script = entry.Script
                        action.Enabled = true
                    end
                    
                    Rebuild = true
                    
                end
                
                -- This is a specific action.
            else
                local list = profile.actionLists[ listID ]
                local action = list.Actions[ actID ]
                
                action[ option ] = input
                
                if option == 'Name' then
                    Hekili.Options.args.actionLists.args[ listKey ].args[ actKey ].name = '|cFFFFD100' .. actID .. '.|r ' .. input
                    
                elseif option == 'Enabled' then
                    RebuildCache = true
                    
                elseif option == 'Move' then
                    action[ option ] = nil
                    local placeholder = table.remove( list.Actions, actID )
                    table.insert( list.Actions, input, placeholder )
                    Rebuild, Select = true, 'A'..input
                    
                elseif option == 'Script' or option == 'Args' then
                    input = input:trim()
                    RebuildScripts = true
                    
                elseif option == 'ReadyTime' then
                    list[ option ] = input:trim()
                    RebuildScripts = true
                    
                elseif option == 'ConsumableArgs' then
                    action[ option ] = nil
                    action.Args = input
                    RebuildScripts = true
                    
                end
                
            end
        end
    end
    
    if Rebuild then
        ns.refreshOptions()
        ns.loadScripts()
        Hekili:BuildUI()
    else
        if RebuildOptions then ns.refreshOptions() end
        if RebuildScripts then ns.loadScripts() end
        if RebuildCache and not RebuildUI then Hekili:UpdateDisplayVisibility() end
        if RebuildUI then Hekili:BuildUI() end
    end
    
    if ns.UI.Minimap then ns.UI.Minimap:RefreshDataText() end
    
    if Select then
        LibStub( "AceConfigDialog-3.0" ):SelectGroup( "Hekili", category, info[2], Select )
    end
    
end


function Hekili:CmdLine( input )
    if not input or input:trim() == "" or input:trim() == "makedefaults" or input:trim() == 'import' or input:trim() == 'skeleton' then
        --[[ if InCombatLockdown() and input:trim() ~= 'force' then
            Hekili:Print( "This addon cannot be configured while in combat." )
            return
        end ]]
        if input:trim() == 'makedefaults' then
            Hekili.MakeDefaults = true
        end
        if input:trim() == 'import' then
            Hekili.AllowSimCImports = true
        end
        if input:trim() == 'skeleton' then
            self:StartListeningForSkeleton()
            self:Print( "Addon will now gather specialization information.  Select all talents and use all abilities for best results." )
            self:Print( "See the Skeleton tab for more information. ")
            Hekili.Skeleton = true
        end
        ns.StartConfiguration()
        
    elseif input:trim() == 'center' then                
        for i, v in ipairs( Hekili.DB.profile.displays ) do
            ns.UI.Buttons[i][1]:ClearAllPoints()
            ns.UI.Buttons[i][1]:SetPoint("CENTER", 0, (i-1) * 50 )
        end
        self:SaveCoordinates()
        
    elseif input:trim() == 'recover' then
        self.DB.profile.displays = {}
        self.DB.profile.actionLists = {}
        self:RestoreDefaults()
        -- ns.convertDisplays()
        self:BuildUI()
        self:Print("Default displays and action lists restored.")
        
    else
        LibStub( "AceConfigCmd-3.0" ):HandleCommand( "hekili", "Hekili", input )
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

function encodeB64(str)
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

function decodeB64(str)
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

local Compresser = LibStub:GetLibrary("LibCompress");
local Encoder = Compresser:GetChatEncodeTable()
local Serializer = LibStub:GetLibrary("AceSerializer-3.0");


function TableToString(inTable, forChat)
    local serialized = Serializer:Serialize(inTable);
    local compressed = Compresser:CompressHuffman(serialized);
    if(forChat) then
        return encodeB64(compressed);
    else
        return Encoder:Encode(compressed);
    end
end


function StringToTable(inString, fromChat)
    local decoded;
    if(fromChat) then
        decoded = decodeB64(inString);
    else
        decoded = Encoder:Decode(inString);
    end
    local decompressed, errorMsg = Compresser:Decompress(decoded);
    if not(decompressed) then
        return "Error decompressing: "..errorMsg;
    end
    local success, deserialized = Serializer:Deserialize(decompressed);
    if not(success) then
        return "Error deserializing "..deserialized;
    end
    return deserialized;
end


function ns.serializeDisplay( display )
    if not Hekili.DB.profile.displays[ display ] then return nil end
    local serial = tableCopy( Hekili.DB.profile.displays[ display ] )
    
    -- Change actionlist IDs to actionlist names so we can validate later.
    if serial.precombatAPL ~= 0 then serial.precombatAPL = Hekili.DB.profile.actionLists[ serial.precombatAPL ].Name end
    if serial.defaultAPL ~= 0 then serial.defaultAPL = Hekili.DB.profile.actionLists[ serial.defaultAPL ].Name end
    
    return TableToString( serial, true )
end

Hekili.SerializeDisplay = ns.serializeDisplay


function ns.deserializeDisplay( str )
    local display = StringToTable( str, true )
    
    if type( display.precombatAPL ) == 'string' then
        for i, list in ipairs( Hekili.DB.profile.actionLists ) do
            if display.precombatAPL == list.Name then
                display.precombatAPL = i
                break
            end
        end
        
        if type( display.precombatAPL ) == 'string' then
            display.precombatAPL = 0
        end
    end
    
    if type( display.defaultAPL ) == 'string' then
        for i, list in ipairs( Hekili.DB.profile.actionLists ) do
            if display.defaultAPL == list.Name then
                display.defaultAPL = i
                break
            end
        end
        
        if type( display.defaultAPL ) == 'string' then
            display.defaultAPL = 0
        end
    end
    
    return display
end

Hekili.DeserializeDisplay = ns.deserializeDisplay


function Hekili:SerializeActionPack( name )
    local pack = rawget( self.DB.profile.packs, name )
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


function Hekili:DeserializeActionPack( str )
    local serial = StringToTable( str, true )
    
    if not serial or type( serial ) == "string" or serial.type ~= "package" then
        return serial or "Unable to restore Priority from the provided string."
    end

    serial.payload.builtIn = false
    
    return serial
end


function Hekili:SerializeStyle( ... )
    local serial = {
        type = "style",
        date = tonumber( date("%Y%m%d.%H%M%S") ),
        payload = {}
    }

    local hasPayload = false

    for i = 1, select( "#", ... ) do
        local dispName = select( i, ... )
        local display = rawget( self.DB.profile.displays, dispName )

        if not display then return "Attempted to serialize an invalid display (" .. dispName .. ")" end

        serial.payload[ dispName ] = tableCopy( display )
        hasPayload = true
    end

    if not hasPayload then return "No displays selected to export." end
    return TableToString( serial, true )
end


function Hekili:DeserializeStyle( str )
    local serial = StringToTable( str, true )

    if not serial or type( serial ) == 'string' or not serial.type == "style" then
        return nil, serial
    end

    return serial.payload
end


function ns.serializeActionList( num ) 
    if not Hekili.DB.profile.actionLists[ num ] then return nil end
    local serial = tableCopy( Hekili.DB.profile.actionLists[ num ] )
    return TableToString( serial, true )
end


function ns.deserializeActionList( str )
    return StringToTable( str, true )
end



local ignore_actions = {
    -- call_action_list = 1,
    -- run_action_list = 1,
    snapshot_stats = 1,
    -- auto_attack = 1,
    -- use_item = 1,
    flask = 1,
    food = 1,
    augmentation = 1
}


local function make_substitutions( i, swaps, prefixes, postfixes ) 
    
    if not i then return nil end
    
    for k,v in pairs( swaps ) do
        
        for token in i:gmatch( k ) do
            
            local times = 0
            while (i:find(token)) do
                local strpos, strend = i:find(token)
                
                local pre = i:sub( strpos - 1, strpos - 1 )
                local j = 2
                
                while ( pre == '(' and strpos - j > 0 ) do
                    pre = i:sub( strpos - j, strpos - j )
                    j = j + 1
                end
                
                local post = i:sub( strend + 1, strend + 1 )
                j = 2
                
                while ( post == ')' and strend + j < i:len() ) do
                    post = i:sub( strend + j, strend + j )
                    j = j + 1
                end
                
                local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
                local finish = strend < i:len() and i:sub( strend + 1 ) or ''
                
                if not ( prefixes and prefixes[ pre ] ) and pre ~= '.' and pre ~= '_' and not pre:match('%a') and not ( postfixes and postfixes[ post ] ) and post ~= '.' and post ~= '_' and not post:match('%a') then
                    i = start .. '\a' .. finish
                else
                    i = start .. '\v' .. finish
                end
                
            end
            
            i = i:gsub( '\v', token )
            i = i:gsub( '\a', v )
            
        end
        
    end
    
    return i
    
end
ns.accomm = accommodate_targets


local function accommodate_targets( targets, ability, i, line, warnings )
    local insert_targets = targets
    local insert_ability = ability
    
    if ability == 'storm_earth_and_fire' then
        insert_targets = type( targets ) == 'number' and min( 2, ( targets - 1 ) ) or 2
        insert_ability = 'storm_earth_and_fire_target'
    elseif ability == 'windstrike' then
        insert_ability = 'stormstrike'
    end
    
    local swaps = {}
    
    swaps["d?e?buff%."..insert_ability.."%.up"] = "active_dot."..insert_ability.. ">=" ..insert_targets
    swaps["d?e?buff%."..insert_ability.."%.down"] = "active_dot."..insert_ability.. "<" ..insert_targets
    swaps["dot%."..insert_ability.."%.up"] = "active_dot."..insert_ability..'>=' ..insert_targets
    swaps["dot%."..insert_ability.."%.ticking"] = "active_dot."..insert_ability..'>=' ..insert_targets
    swaps["dot%."..insert_ability.."%.down"] = "active_dot."..insert_ability..'<' ..insert_targets
    swaps["up"] = "active_dot."..insert_ability..">=" ..insert_targets
    swaps["ticking"] = "active_dot."..insert_ability..">=" ..insert_targets
    swaps["down"] = "active_dot."..insert_ability.."<" ..insert_targets 
    
    return make_substitutions( i, swaps )
end


local function Sanitize( segment, i, line, warnings )
    
    if i == nil then return i end
    
    local operators = {
        [">"] = true,
        ["<"] = true,
        ["="] = true,
        ["~"] = true,
        ["+"] = true,
        ["-"] = true,
        ["%"] = true,
        ["*"] = true
    }
    
    local maths = {
        ['+'] = true,
        ['-'] = true,
        ['*'] = true,
        ['%%'] = true
    }
    
    local times = 0
    

    for token in i:gmatch( "stealthed" ) do
        
        local times = 0
        while (i:find(token)) do
            
            local strpos, strend = i:find(token)
            
            local pre = strpos > 1 and i:sub( strpos - 1, strpos - 1 ) or ''
            local post = strend < i:len() and i:sub( strend + 1, strend + 1 ) or ''
            local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
            local finish = strend < i:len() and i:sub( strend + 1 ) or ''
            
            if pre ~= '.' and pre ~= '_' and not pre:match('%a') and post ~= '.' and post ~= '_' and not post:match('%a') then
                i = start .. '\a' .. finish
            else
                i = start .. '\v' .. finish
            end
            
        end
        
        i = i:gsub( '\v', token )
        i = i:gsub( '\a', token..'.rogue' )
        
    end 

    for token in i:gmatch( "equipped%.[0-9]+" ) do
        
        local itemID = tonumber( token:match( "([0-9]+)" ) )
        local itemName = GetItemInfo( itemID )
        local itemKey = formatKey( itemName )
        
        if itemKey and itemKey ~= '' then
            i = i:gsub( tostring( itemID ), itemKey )
        end
        
    end   
    
    i, times = i:gsub( "pet%.[%w_]+%.([%w_]+)%.", "%1." )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Converted 'pet.X.Y...' to 'Y...' (" .. times .. "x)." )
    end
    
    i, times = i:gsub( "pet%.[%w_]+%.[%w_]+%.([%w_]+)%.", "%1." )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Converted 'pet.X.Y.Z...' to 'Z...' (" .. times .. "x)." )
    end
    
    --[[ i, times = i:gsub( "gcd%.max", "gcd" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Converted 'gcd.max' to 'gcd' (" .. times .. "x)." )
    end
    
    i, times = i:gsub( "gcd%.remains", "cooldown.global_cooldown.remains" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Converted gcd.remains to cooldown.global_cooldown.remains (" .. times .. "x)." )
    end ]]
    
    --[[ i, times = i:gsub( "[!+-%*]?raid_event[.a-z0-9_><=~%-%+*]+", "" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Removed 'raid_event' check(s) (" .. times .. "x)." )
        
        local cleaning = true
        i = i:gsub( "||", "|" )
        while( cleaning ) do
            
            cleaning = false
            i, times = i:gsub( "%(%)", "" )
            cleaning = cleaning or times > 0
            
            i, times = i:gsub( "^[|&]+", "" )
            cleaning = cleaning or times > 0
            
            i, times = i:gsub( "[|&]+$", "" )
            cleaning = cleaning or times > 0
            
            i, times = i:gsub( "%([|&]+", "(" )
            cleaning = cleaning or times > 0
            
            i, times = i:gsub( "[|&]+%)", ")" )
            cleaning = cleaning or times > 0
            
            i = i:gsub( "||", "|" )
            i = i:gsub( "|&", "|" )
            i = i:gsub( "&|", "&" )
            i = i:gsub( "&&", "&" )
            
            -- i, times = i:gsub( "([|&])[|&]", "%1" )
            -- cleaning = cleaning or times > 0
            
        end
        i = i:gsub( "|", "||" )
    end ]]
    
    --[[ i, times = i:gsub( "debuff%.judgment%.up", "judgment_override" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Replaced 'debuff.judgment.up' with 'judgment_override' (" .. times .. "x)." )
    end ]]
    
    --[[ i, times = i:gsub( "desired_targets", "1" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Replaced 'desired_targets' with '1' (" .. times .. "x)." )
    end ]]
    
    i, times = i:gsub( "min:[a-z0-9_%.]+(,?$?)", "%1" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Removed min:X check (not available in emulation) -- (" .. times .. "x)." )
    end
    
    i, times = i:gsub( "max:[a-z0-9_%.]+(,?$?)", "%1" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Removed max:X check (not available in emulation) -- (" .. times .. "x)." )
    end
    
    --[[ i, times = i:gsub( "buff.out_of_range.up", "!target.in_range" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Replaced 'buff.out_of_range.up' with '!target.in_range' (" .. times .. "x)." )
    end
    
    i, times = i:gsub( "buff.out_of_range.down", "target.in_range" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Replaced 'buff.out_of_range.down' with 'target.in_range' (" .. times .. "x)." )
    end ]]
    
    --[[ i, times = i:gsub( "movement.distance", "target.distance" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Replaced 'movement.distance' with 'target.distance' (" .. times .. "x)." )
    end ]]
    
    --[[ i, times = i:gsub( "buff.metamorphosis.extended_by_demonic", "buff.demonic_extended_metamorphosis.up" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Replaced 'buff.metamorphosis.extended_by_demonic' with 'buff.demonic_extended_metamorphosis.up' (" .. times .. "x)." )
    end ]]

    --[[ i, times = i:gsub( "buff.active_uas", "unstable_afflictions" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Replaced 'buff.active_uas' with 'unstable_afflictions' (" .. times .. "x)." )
    end ]]

    --[[ i, times = i:gsub( "rune%.([a-z0-9_]+)", "runes.%1")
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Replaced 'rune.X' with 'runes.X' (" .. times .. "x)." )
    end ]]

    --[[ i, times = i:gsub( "cooldown%.strike%.", "cooldown.stormstrike." )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Replaced 'cooldown.strike' with 'cooldown.stormstrike' (" .. times .. "x)." )
    end ]]

    --[[ i, times = i:gsub( "spell_targets%.[a-zA-Z0-9_]+", "active_enemies" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Converted spell_targets.X syntax to active_enemies(" .. times .. "x)." )
    end ]]
    
    
    --[[ for token in i:gmatch( "incoming_damage_%d+m?s" ) do
        local times = 0
        while (i:find(token)) do
            local strpos, strend = i:find(token)
            
            local pre = i:sub( strpos - 1, strpos - 1 )
            local j = 2
            
            while ( pre == '(' and strpos - j > 0 ) do
                pre = i:sub( strpos - j, strpos - j )
                j = j + 1
            end
            
            local post = i:sub( strend + 1, strend + 1 )
            j = 2
            
            while ( post == ')' and strend + j < i:len() ) do
                post = i:sub( strend + j, strend + j )
                j = j + 1
            end
            
            if not operators[pre] and not operators[post] then
                i = i:sub( 1, strpos - 1 ) .. '\v' .. '>0' .. i:sub( strend + 1 )
                times = times + 1
            else
                i = i:sub( 1, strpos - 1 ) .. '\v' .. i:sub( strend + 1 )
            end
        end
        
        if times > 0 then
            table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. "' to '" .. token .. ">0' (" .. times .. "x)." )
        end
        i = i:gsub( '\v', token )
    end ]]
    
    
    --[[ for token in i:gmatch( "set_bonus%.[%a%d_]+" ) do
        local times = 0
        while (i:find(token)) do
            local strpos, strend = i:find(token)
            
            local pre = i:sub( strpos - 1, strpos - 1 )
            local j = 2
            
            while ( pre == '(' and strpos - j > 0 ) do
                pre = i:sub( strpos - j, strpos - j )
                j = j + 1
            end
            
            local post = i:sub( strend + 1, strend + 1 )
            j = 2
            
            while ( post == ')' and strend + j < i:len() ) do
                post = i:sub( strend + j, strend + j )
                j = j + 1
            end
            
            if not operators[pre] and not operators[post] then
                i = i:sub( 1, strpos - 1 ) .. '\v' .. '>0' .. i:sub( strend + 1 )
                times = times + 1
            else
                i = i:sub( 1, strpos - 1 ) .. '\v' .. i:sub( strend + 1 )
            end
        end
        
        if times > 0 then
            table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. "' to '" .. token .. "=1' (" .. times .. "x)." )
        end
        i = i:gsub( '\v', token )
    end ]]
    
    
    --[[ for token in i:gmatch( "cooldown%.[%a_]+%.remains" ) do
        local times = 0
        while (i:find(token)) do
            local strpos, strend = i:find(token)
            
            local pre = i:sub( strpos - 1, strpos - 1 )
            local j = 2
            
            while ( pre == '(' and strpos - j > 0 ) do
                pre = i:sub( strpos - j, strpos - j )
                j = j + 1
            end
            
            local post = i:sub( strend + 1, strend + 1 )
            j = 2
            
            while ( post == ')' and strend + j < i:len() ) do
                post = i:sub( strend + j, strend + j )
                j = j + 1
            end
            
            local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
            local finish = strend < i:len() and i:sub( strend + 1 ) or ''
            
            if not operators[pre] and not operators[post] then
                i = start .. '\v' .. '>0' .. finish
                times = times + 1
            else
                i = start .. '\v' .. finish
            end
        end
        
        i = i:gsub( '\v', token )
        if times > 0 then
            table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. "' to '" .. token .. ">0' (" .. times .. "x)." )
        end
        table.insert( warnings, "Line " .. line .. ": This entry checks the cooldown for '" .. token .. "' which can be result in odd behavior if '" .. token .. "' is toggled off/disabled." )
    end ]]

    
    --[[ for token in i:gmatch( "artifact%.[%a_]+%.rank" ) do
        local times = 0
        while (i:find(token)) do
            local strpos, strend = i:find(token)
            
            local pre = i:sub( strpos - 1, strpos - 1 )
            local j = 2
            
            while ( pre == '(' and strpos - j > 0 ) do
                pre = i:sub( strpos - j, strpos - j )
                j = j + 1
            end
            
            local post = i:sub( strend + 1, strend + 1 )
            j = 2
            
            while ( post == ')' and strend + j < i:len() ) do
                post = i:sub( strend + j, strend + j )
                j = j + 1
            end
            
            local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
            local finish = strend < i:len() and i:sub( strend + 1 ) or ''
            
            if not operators[pre] and not operators[post] then
                i = start .. '\v' .. '>0' .. finish
                times = times + 1
            else
                i = start .. '\v' .. finish
            end
        end
        
        i = i:gsub( '\v', token )
        if times > 0 then
            table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. "' to '" .. token .. ">0' (" .. times .. "x)." )
        end
    end ]]
    
    --[[ for token, attr in i:gmatch( "(d?e?buff%.[%a_]+%.)(remains)" ) do
        local times = 0
        while (i:find(token..attr)) do
            local strpos, strend = i:find(token..attr)
            
            local pre = i:sub( strpos - 1, strpos - 1 )
            local j = 2
            
            while ( pre == '(' and strpos - j > 0 ) do
                pre = i:sub( strpos - j, strpos - j )
                j = j + 1
            end
            
            local post = i:sub( strend + 1, strend + 1 )
            j = 2
            
            while ( post == ')' and strend + j < i:len() ) do
                post = i:sub( strend + j, strend + j )
                j = j + 1
            end
            
            local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
            local finish = strend < i:len() and i:sub( strend + 1 ) or ''
            
            if not operators[pre] and not operators[post] then
                i = start .. '\v' .. 'up' .. finish
                times = times + 1
            else
                i = start .. '\v' .. attr .. finish
            end
        end
        
        i = i:gsub( '\v', token )
        if times > 0 then
            table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. attr .. "' to '" .. token .. "up' (" .. times .. "x)." )
        end
    end ]]
    
    
    --[[ for token, attr in i:gmatch( "(d?e?buff%.[%a_]+%.)(react)" ) do
        local times = 0
        while (i:find(token..attr)) do
            local strpos, strend = i:find(token..attr)
            
            local pre = i:sub( strpos - 1, strpos - 1 )
            local j = 2
            
            while ( pre == '(' and strpos - j > 0 ) do
                pre = i:sub( strpos - j, strpos - j )
                j = j + 1
            end
            
            local post = i:sub( strend + 1, strend + 1 )
            j = 2
            
            while ( post == ')' and strend + j < i:len() ) do
                post = i:sub( strend + j, strend + j )
                j = j + 1
            end
            
            local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
            local finish = strend < i:len() and i:sub( strend + 1 ) or ''
            
            if not operators[pre] and not operators[post] then
                i = start .. '\v' .. 'up' .. finish
                times = times + 1
            else
                i = start .. '\v' .. attr .. finish
            end
        end
        
        if times > 0 then
            table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. attr .. "' to '" .. token .. "up' (" .. times .. "x)." )
        end
        i = i:gsub( '\v', token )
    end ]]
    
    
    --[[ for token, attr in i:gmatch( "(trinket%.[%a%._]+%.)(react)" ) do
        local times = 0
        while (i:find(token..attr)) do
            local strpos, strend = i:find(token..attr)
            
            local pre = i:sub( strpos - 1, strpos - 1 )
            local j = 2
            
            while ( pre == '(' and strpos - j > 0 ) do
                pre = i:sub( strpos - j, strpos - j )
                j = j + 1
            end
            
            local post = i:sub( strend + 1, strend + 1 )
            j = 2
            
            while ( post == ')' and strend + j < i:len() ) do
                post = i:sub( strend + j, strend + j )
                j = j + 1
            end
            
            local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
            local finish = strend < i:len() and i:sub( strend + 1 ) or ''
            
            if not operators[pre] and not operators[post] then
                i = start .. '\v' .. 'up' .. finish
                times = times + 1
            else
                i = start .. '\v' .. attr .. finish
            end
        end
        
        if times > 0 then
            table.insert( warnings, "Line " .. line .. ": Converted unconditional '" .. token .. attr .. "' to '" .. token .. "up' (" .. times .. "x)." )
        end
        i = i:gsub( '\v', token )
    end ]]
    
    
    --[[ for token, attr in i:gmatch( "(talent%.[%a%._]+%.)(enabled)" ) do
        local times = 0
        while (i:find(token..attr)) do
            local strpos, strend = i:find(token..attr)
            
            local pre = i:sub( strpos - 1, strpos - 1 )
            local j = 2
            
            while ( pre == '(' and strpos - j > 0 ) do
                pre = i:sub( strpos - j, strpos - j )
                j = j + 1
            end
            
            local post = i:sub( strend + 1, strend + 1 )
            j = 2
            
            while ( post == ')' and strend + j < i:len() ) do
                post = i:sub( strend + j, strend + j )
                j = j + 1
            end
            
            local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
            local finish = strend < i:len() and i:sub( strend + 1 ) or ''
            
            if maths[pre] or maths[post] then
                i = start .. '\a' .. finish
                times = times + 1
            else
                i = start .. '\v' .. finish
            end
        end
        
        if times > 0 then
            table.insert( warnings, "Line " .. line .. ": Converted '" .. token .. attr .. "' to '" .. token .. "rank' for mathematical comparison (" .. times .. "x)." )
        end
        i = i:gsub( '\a', token .. 'rank' ) 
        i = i:gsub( '\v', token .. attr )
    end ]]

   
    --[[ for token, attr in i:gmatch( "(d?e?buff%.[%a%._]+%.)(up)" ) do
        local times = 0
        while (i:find(token..attr)) do
            local strpos, strend = i:find(token..attr)
            
            local pre = i:sub( strpos - 1, strpos - 1 )
            local j = 2
            
            while ( pre == '(' and strpos - j > 0 ) do
                pre = i:sub( strpos - j, strpos - j )
                j = j + 1
            end
            
            local post = i:sub( strend + 1, strend + 1 )
            j = 2
            
            while ( post == ')' and strend + j < i:len() ) do
                post = i:sub( strend + j, strend + j )
                j = j + 1
            end
            
            local start = strpos > 1 and i:sub( 1, strpos - 1 ) or ''
            local finish = strend < i:len() and i:sub( strend + 1 ) or ''
            
            if maths[pre] or maths[post] then
                i = start .. '\a' .. finish
                times = times + 1
            else
                i = start .. '\v' .. finish
            end
        end
        
        if times > 0 then
            table.insert( warnings, "Line " .. line .. ": Converted '" .. token .. attr .. "' to '" .. token .. "rank' for mathematical comparison (" .. times .. "x)." )
        end
        i = i:gsub( '\a', token .. 'rank' ) 
        i = i:gsub( '\v', token .. attr )
    end ]]


    if segment == 'c' then
        for token in i:gmatch( "target" ) do
            local times = 0
            while (i:find(token)) do
                local strpos, strend = i:find(token)
                
                local pre = i:sub( strpos - 1, strpos - 1 )
                local post = i:sub( strend + 1, strend + 1 )
                
                if pre ~= '_' and post ~= '.' then
                    i = i:sub( 1, strpos - 1 ) .. '\v.unit' .. i:sub( strend + 1 )
                    times = times + 1
                else
                    i = i:sub( 1, strpos - 1 ) .. '\v' .. i:sub( strend + 1 )
                end
            end
            
            if times > 0 then
                table.insert( warnings, "Line " .. line .. ": Converted non-specific 'target' to 'target.unit' (" .. times .. "x)." )
            end
            i = i:gsub( '\v', token )
        end
    end 
    
    
    for token in i:gmatch( "player" ) do
        local times = 0
        while (i:find(token)) do
            local strpos, strend = i:find(token)
            
            local pre = i:sub( strpos - 1, strpos - 1 )
            local post = i:sub( strend + 1, strend + 1 )
            
            if pre ~= '_' and post ~= '.' then
                i = i:sub( 1, strpos - 1 ) .. '\v.unit' .. i:sub( strend + 1 )
                times = times + 1
            else
                i = i:sub( 1, strpos - 1 ) .. '\v' .. i:sub( strend + 1 )
            end
        end
        
        if times > 0 then
            table.insert( warnings, "Line " .. line .. ": Converted non-specific 'player' to 'player.unit' (" .. times .. "x)." )
        end
        i = i:gsub( '\v', token )
    end
    
    --[[ i,times = i:gsub( "(set_bonus%.[^%.=|&]+)=1", "%1" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Converted set_bonus.X=1 to set_bonus.X (" .. times .. "x)." )
    end
    i,times = i:gsub( "(set_bonus%.[^%.=|&]+)=0", "!%1" )
    if times > 0 then
        table.insert( warnings, "Line " .. line .. ": Converted set_bonus.X=0 to !set_bonus.X (" .. times .. "x)." )
    end ]]
    
    return i
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
        table.insert( result, string.sub( str, from, delim_from - 1 ) )
        from = delim_to + 1
        delim_from, delim_to = string.find( str, delimiter, from )
    end
    
    table.insert( result, string.sub( str, from ) )
    return result
end


--[[ local function StoreModifier( entry, key, value )
    
    if key ~= 'if' and key ~= 'ability' then
        if not entry.Args then entry.Args = key .. '=' .. value
        else entry.Args = entry.Args .. "," .. key .. "=" .. value end
    end
    
    if key == 'if' then
        entry.Script = value
        
    elseif key == 'cycle_targets' then
        entry.CycleTargets = tonumber( value ) == 1 and true or false
        
    elseif key == 'max_cycle_targets' then
        entry.MaximumTargets = value
        
    elseif key == 'moving' then
        entry.CheckMovement = true
        entry.Moving = tonumber( value )
        
    elseif key == 'name' then
        local v = value:match( '"(.*)"'' ) or value
        entry.ModName = v
        entry.ModVarName = v
        
    elseif key == 'value' then -- for 'variable' type, overwrites Script
        entry.Script = value
        
    elseif key == 'target_if' then
        entry.TargetIf = value

    elseif key == 'pct_health' then
        entry.PctHealth = value

    elseif key == 'interval' then
        entry.Interval = value

    elseif key == 'for_next' then
        entry.PoolForNext = tonumber( value ) ~= 0

    elseif key == 'wait' then
        entry.PoolTime = tonumber( value ) or 0

    elseif key == 'extra_amount' then
        entry.PoolExtra = tonumber( value ) or 0

    elseif key == 'sec' then
        entry.WaitSeconds = value
        
    end
    
end ]]

do
    local parseData = {
        warnings = {},
        missing = {},
    }

    local nameMap = {
        call_action_list = "list_name",
        run_action_list = "list_name",
        potion = "potion",
        variable = "var_name",
        cancel_buff = "buff_name",
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
                    table.insert( warnings, "Line " .. line .. ": Removed unnecessary expel_harm cooldown check from action entry for jab (" .. times .. "x)." )
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
                table.insert( warnings, "Line " .. line .. ": Replaced unsupported '" .. token .. "' with '" .. enemies .. "' (" .. times .. "x)." )
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
                    table.insert( warnings, "Line " .. line .. ": Removed unnecessary energy cap check from action entry for fists_of_fury (" .. times .. "x)." )
                end
            end
        
            local components = strsplit( i, "," )
            local result = {}
            
            for a, str in ipairs( components ) do                
                -- First element is the action, if supported.
                if a == 1 then
                    local ability = str:trim()
                    
                    if ability and ( ability == 'use_item' or class.abilities[ ability ] ) then                   
                        result.action = class.abilities[ ability ] and class.abilities[ ability ].key or ability
                    elseif not ignore_actions[ ability ] then
                        table.insert( warnings, "Line " .. line .. ": Unsupported action '" .. ability .. "'." )
                        result.action = ability
                    end
                    
                else
                    local key, value = str:match( "^(.-)=(.-)$" )

                    if key and value then
                        if key == 'if' then key = 'criteria' end

                        if key == 'criteria' or key == 'target_if' or key == 'value' or key == 'value_else' or key == 'sec' or key == 'wait' then
                            value = Sanitize( 'c', value, line, warnings )
                            value = SpaceOut( value )
                        end

                        result[ key ] = value
                        -- StoreModifier( result, key, value )
                    end
                end
            end

            if nameMap[ result.action ] then
                result[ nameMap[ result.action ] ] = result.name
                result.name = nil
            end
        
            --[[ if result.target_if then
                if result.criteria and result.criteria:len() > 0 then   
                    result.criteria = format( "( %s ) & ( %s )", result.criteria, result.target_if )
                else
                    result.criteria = result.target_if
                end
            end ]]

            if result.target_if then result.target_if = result.target_if:gsub( "min:", "" ):gsub( "max:", "" ) end

            if result.for_next then result.for_next = tonumber( result.for_next ) end
            if result.cycle_targets then result.cycle_targets = tonumber( result.cycle_targets ) end

            if result.target_if and not result.criteria then
                result.criteria = result.target_if
                result.target_if = nil
            end

            if result.action == 'use_item' and result.name and class.abilities[ result.name ] then
                result.action = result.name
            end

            --[[ if result.criteria then
                result.criteria = Sanitize( 'c', result.criteria, line, warnings )
                result.criteria = SpaceOut( result.criteria )
            end ]]

            table.insert( output, result )
        end
    
        if n > 0 then
            table.insert( warnings, "The following auras were used in the action list but were not found in the addon database:" )
            for k in orderedPairs( missing ) do
                table.insert( warnings, " - " .. k )
            end
        end
        
        return #output > 0 and output or nil, #warnings > 0 and warnings or nil    
    end
end



local warnOnce = false

-- Key Bindings
function Hekili:TogglePause( ... )

    Hekili.btns = ns.UI.Buttons
    
    if not self.Pause then
        self.ActiveDebug = true

        for i, display in pairs( ns.UI.Displays ) do
            if self:IsDisplayActive( i ) and display.alpha > 0 then
                self:ProcessHooks( i )
            end
        end

        self.Pause = true
        self:SaveDebugSnapshot()
        self:Print( "Snapshot saved." )
        self.ActiveDebug = false

        if not warnOnce then
            Hekili:Print( "Snapshots are viewable via /hekili (until you reload your UI)." )
            warnOnce = true
        end
    else
        self.Pause = false
    end
    
    local MouseInteract = self.Pause or self.Config
    
    for _, group in pairs( ns.UI.Buttons ) do
        for _, button in pairs( group ) do
            button:EnableMouse( MouseInteract )
        end
    end
    
    self:Print( ( not self.Pause and "UN" or "" ) .. "PAUSED." )
    self:Notify( ( not self.Pause and "UN" or "" ) .. "PAUSED" )

end


-- Key Bindings
function Hekili:MakeSnapshot( ... )
    
    self.ActiveDebug = true

    for i, display in pairs( ns.UI.Displays ) do
        if self:IsDisplayActive( i ) and display.alpha > 0 then
            self:ProcessHooks( i )
        end
    end

    self:SaveDebugSnapshot()
    self:Print( "Snapshot saved." )
    self.ActiveDebug = false

    self:Print( "Snapshots are viewable via /hekili (until you reload your UI)." )

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


function Hekili:FireToggle( name )
    local toggle = name and self.DB.profile.toggles[ name ]

    if not toggle then return end

    if name == 'mode' then
        if toggle.type == "AutoSingle" then
            if toggle.value == "automatic" then toggle.value = "single" else toggle.value = "automatic" end
        elseif toggle.type == "SingleAOE" then
            if toggle.value == "single" then toggle.value = "aoe" else toggle.value = "single" end
        elseif toggle.type == "AutoDual" then
            if toggle.value == "automatic" then toggle.value = "dual" else toggle.value = "automatic" end
        end

        if toggle.type == "ReactiveDual" then       
            toggle.value = "reactive"
        else
            local mode = "Unknown"
            if toggle.value == "automatic" then mode = "Automatic"
            elseif toggle.value == "single" then mode = "Single-Target"
            elseif toggle.value == "aoe" then mode = "AOE"
            elseif toggle.value == "dual" then mode = "Dual Display" end

            if self.DB.profile.notifications.enabled then
                self:Notify( "Mode: " .. mode )
            else
                self:Print( mode .. " mode activated." )
            end
        end
    
    elseif name == 'pause' then
        self:TogglePause()
        return

    elseif name == 'snapshot' then
        self:MakeSnapshot()
        return

    else
        toggle.value = not toggle.value

        if self.DB.profile.notifications.enabled then
            self:Notify( name:gsub( "^(.)", strupper ) .. ": " .. ( toggle.value and "ON" or "OFF" ) )
        else
            self:Print( name:gsub( "^(.)", strupper ) .. ( toggle.value and " |cFF00FF00ENABLED|r." or " |cFFFF0000DISABLED|r." ) )
        end
    end

    if WeakAuras then WeakAuras.ScanEvents( "HEKILI_TOGGLE", name, toggle.value ) end
    if ns.UI.Minimap then ns.UI.Minimap:RefreshDataText() end
    self:UpdateDisplayVisibility()

    self:ForceUpdate( "HEKILI_TOGGLE", true )
end


function Hekili:GetToggleState( name, class )
    local t = name and self.DB.profile.toggles[ name ]

    return t and t.value
end
