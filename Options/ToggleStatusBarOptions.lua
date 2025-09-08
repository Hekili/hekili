-- ToggleStatusBarOptions.lua
-- Toggle Status Bar options module

local addon, ns = ...
local Hekili = _G[ addon ]
local state = Hekili.State

local ACD = LibStub( "AceConfigDialog-3.0" )

local ToggleStatusBarOptions = {}

-- Helper function to automatically determine label position based on display setup
local function GetAutomaticLabelPosition()
    local settings = Hekili.DB.profile.toggleBar
    local displayMode = settings.displayMode or "standard"
    local curveAngle = settings.minimalistAngle or 0
    
    if displayMode == "standard" then
        local direction = settings.direction or "HORIZONTAL"
        if direction == "VERTICAL" then
            return "LEFT"
        else -- HORIZONTAL
            return "TOP"
        end
    else -- minimalist
        local layout = settings.minimalistLayout or "horizontal"
        if layout == "vertical" then
            if curveAngle > 0 then
                return "RIGHT"
            else
                return "LEFT"
            end
        else -- horizontal
            if curveAngle < 0 then
                return "BOTTOM"
            else
                return "TOP"
            end
        end
    end
end

function ToggleStatusBarOptions.GetOptionsTable()
    return {
        toggleStatusBarBtn = {
            type = "execute",
            name = "Toggle Status Bar",
            desc = "Configure the Toggle Status Bar display for enabling/disabling options like CDs, Defensives, etc.",
            func = function ()
                ACD:SelectGroup( "Hekili", "displays", "toggleStatusBar" )
            end,
            order = 940,
        },

        toggleStatusBar = {
            type = "group",
            name = "|cFF1EFF00Toggle Status Bar|r",
            desc = "Configure the Toggle Status Bar display for enabling/disabling options like CDs, Defensives, etc.",
            order = 941,
            childGroups = "tab",
            get = function( info )
                local settings = Hekili.DB.profile.toggleBar
                return settings and settings[ info[ #info ] ]
            end,
            set = function( info, value )
                local settings = Hekili.DB.profile.toggleBar
                if not settings then
                    Hekili.DB.profile.toggleBar = {}
                    settings = Hekili.DB.profile.toggleBar
                end
                settings[ info[ #info ] ] = value
                Hekili:BuildToggleStatusBar()
            end,
            args = {
                topRow = {
                    type = "group",
                    name = "",
                    inline = true,
                    order = 1,
                    args = {
                        enabled = {
                            type = "toggle",
                            name = "Enabled",
                            order = 1,
                            width = 1.0,
                        },

                        displayMode = {
                            type = "select",
                            name = "Status Bar Mode",
                            desc = "Choose between Standard (full bar with multiple toggles) or Minimalist (compact indicators)",
                            order = 2,
                            width = 1.2,
                            values = {
                                standard = "Standard",
                                minimalist = "Minimalist"
                            },
                            get = function()
                                return Hekili.DB.profile.toggleBar.displayMode or "standard"
                            end,
                            set = function(info, value)
                                Hekili.DB.profile.toggleBar.displayMode = value
                                
                                -- Automatically adjust label position
                                Hekili.DB.profile.toggleBar.labelPosition = GetAutomaticLabelPosition()
                                
                                Hekili:BuildToggleStatusBar()
                                LibStub("AceConfigRegistry-3.0"):NotifyChange("Hekili")
                            end,
                        },
                    },
                },

                standard = {
                    type = "group",
                    name = "Standard Settings",
                    order = 10,
                    hidden = function() return (Hekili.DB.profile.toggleBar.displayMode or "standard") ~= "standard" end,
                    args = {
                        toggleVisibility = {
                            type = "group",
                            name = "Toggle Visibility",
                            inline = true,
                            desc = "Choose which toggles to display on the bar.",
                            order = 1,
                            get = function( info )
                                local idx = tonumber( info[ #info ] )
                                local settings = Hekili.DB.profile.toggleBar
                                return settings and settings[ idx ] and settings[ idx ].enabled ~= false
                            end,
                            set = function( info, value )
                                local idx = tonumber( info[ #info ] )
                                local settings = Hekili.DB.profile.toggleBar
                                if settings and settings[ idx ] then
                                    settings[ idx ].enabled = value
                                    Hekili:BuildToggleStatusBar()
                                end
                            end,
                            args = {
                                ["1"] = { type = "toggle", name = "Major CDs", desc = "Show Major Cooldowns toggle", order = 1, width = 1.49 },
                                ["2"] = { type = "toggle", name = "Minor CDs", desc = "Show Minor Cooldowns toggle", order = 2, width = 1.49 },
                                ["3"] = { type = "toggle", name = "Defensives", desc = "Show Defensives toggle", order = 3, width = 1.49 },
                                ["4"] = { type = "toggle", name = "Interrupts", desc = "Show Interrupts toggle", order = 4, width = 1.49 },
                                ["5"] = { type = "toggle", name = "Potions", desc = "Show Potions toggle", order = 5, width = 1.49 },
                                ["6"] = { type = "toggle", name = "Funnel", desc = "Show Funnel toggle (only available for specs that support funneling)", order = 6, width = 1.49, disabled = function() return not Hekili.DB.profile.specs[state.spec.id].canFunnel end },
                                ["7"] = { type = "toggle", name = "Display Mode", desc = "Show Display Mode toggle", order = 7, width = 1.49 },
                                ["8"] = { type = "toggle", name = "Custom 1", desc = "Show Custom 1 toggle", order = 8, width = 1.49 },
                                ["9"] = { type = "toggle", name = "Custom 2", desc = "Show Custom 2 toggle", order = 9, width = 1.49 },
                            }
                        },

                        anchoring = {
                            type = "group",
                            name = "Position & Anchoring",
                            inline = true,
                            order = 2,
                            args = {
                                anchorMode = {
                                    type = "select",
                                    name = "Anchor Mode",
                                    desc = "How to position the toggle bar",
                                    order = 1,
                                    width = "full",
                                    values = { screen = "Screen", primary = "Hekili Primary Display" },
                                    get = function() return Hekili.DB.profile.toggleBar.anchorTarget == "UIParent" and "screen" or "primary" end,
                                    set = function(info, value)
                                        if value == "screen" then
                                            Hekili.DB.profile.toggleBar.anchorTarget = "UIParent"
                                            Hekili.DB.profile.toggleBar.anchor = "CENTER"
                                            Hekili.DB.profile.toggleBar.anchorPoint = "CENTER"
                                        else
                                            Hekili.DB.profile.toggleBar.anchorTarget = "HekiliDisplay1"
                                            Hekili.DB.profile.toggleBar.anchor = "TOP"
                                            Hekili.DB.profile.toggleBar.anchorPoint = "BOTTOM"
                                        end
                                        Hekili:BuildToggleStatusBar()
                                    end,
                                },
                                anchor = {
                                    type = "select",
                                    name = "Anchor Point",
                                    desc = "Which point of the primary display to attach to",
                                    order = 2,
                                    width = 1.49,
                                    values = { TOPLEFT = "Top Left", TOP = "Top", TOPRIGHT = "Top Right", LEFT = "Left", CENTER = "Center", RIGHT = "Right", BOTTOMLEFT = "Bottom Left", BOTTOM = "Bottom", BOTTOMRIGHT = "Bottom Right" },
                                    hidden = function() return Hekili.DB.profile.toggleBar.anchorTarget == "UIParent" end,
                                    get = function() return Hekili.DB.profile.toggleBar.anchorPoint or "BOTTOM" end,
                                    set = function(info, value) Hekili.DB.profile.toggleBar.anchorPoint = value; Hekili:BuildToggleStatusBar() end,
                                },
                                anchorPoint = {
                                    type = "select",
                                    name = "From Point",
                                    desc = "Which point of the toggle bar to anchor from",
                                    order = 3,
                                    width = 1.49,
                                    values = { TOPLEFT = "Top Left", TOP = "Top", TOPRIGHT = "Top Right", LEFT = "Left", CENTER = "Center", RIGHT = "Right", BOTTOMLEFT = "Bottom Left", BOTTOM = "Bottom", BOTTOMRIGHT = "Bottom Right" },
                                    hidden = function() return Hekili.DB.profile.toggleBar.anchorTarget == "UIParent" end,
                                    get = function() return Hekili.DB.profile.toggleBar.anchor or "TOP" end,
                                    set = function(info, value) Hekili.DB.profile.toggleBar.anchor = value; Hekili:BuildToggleStatusBar() end,
                                },
                                x = { type = "range", name = "X Offset", min = -500, max = 500, step = 1, width = 1.49, order = 4, get = function() return Hekili.DB.profile.toggleBar.x or 0 end, set = function(info, value) Hekili.DB.profile.toggleBar.x = value; Hekili:BuildToggleStatusBar() end },
                                y = { type = "range", name = "Y Offset", min = -500, max = 500, step = 1, width = 1.49, order = 5, get = function() return Hekili.DB.profile.toggleBar.y or 0 end, set = function(info, value) Hekili.DB.profile.toggleBar.y = value; Hekili:BuildToggleStatusBar() end },
                            },
                        },

                        layoutGroup = {
                            type = "group",
                            name = "Appearance",
                            inline = true,
                            order = 3,
                            args = {
                                direction = {
                                    type = "select",
                                    name = "Direction",
                                    order = 1,
                                    width = 1.49,
                                    values = { HORIZONTAL = "Horizontal", VERTICAL = "Vertical" },
                                    set = function(info, value)
                                        local settings = Hekili.DB.profile.toggleBar
                                        local oldDirection = settings.direction or "HORIZONTAL"
                                        
                                        -- If direction is actually changing, swap rows and columns
                                        if oldDirection ~= value then
                                            local currentMaxColumns = settings.maxColumns or 9
                                            local currentMaxRows = settings.maxRows or 1
                                            
                                            -- Swap the values
                                            settings.maxColumns = currentMaxRows
                                            settings.maxRows = currentMaxColumns
                                        end
                                        
                                        settings.direction = value
                                        
                                        -- Automatically adjust label position
                                        settings.labelPosition = GetAutomaticLabelPosition()
                                        
                                        Hekili:BuildToggleStatusBar()
                                        
                                        -- Force refresh of the options UI to update slider displays
                                        LibStub("AceConfigRegistry-3.0"):NotifyChange("Hekili")
                                    end
                                },
                                buttonSize = { type = "range", name = "Icon Size", desc = "Size of each toggle icon", min = 16, max = 64, step = 1, order = 2, width = 1.49 },
                                spacing = { type = "range", name = "Spacing", desc = "Space between buttons", min = 0, max = 20, step = 1, order = 3, width = 1.49 },
                                maxColumns = {
                                    type = "range",
                                    name = "Max Columns",
                                    desc = "Maximum number of columns",
                                    min = 1, max = 9, step = 1,
                                    order = 4,
                                    width = 1.49,
                                    set = function(info, value)
                                        local settings = Hekili.DB.profile.toggleBar
                                        settings.maxColumns = value
                                        -- Auto-adjust rows if needed
                                        local enabledCount = 0
                                        for i = 1, 9 do
                                            if settings[i] and settings[i].enabled ~= false then
                                                enabledCount = enabledCount + 1
                                            end
                                        end
                                        local neededRows = math.ceil(enabledCount / value)
                                        if settings.maxRows < neededRows then
                                            settings.maxRows = neededRows
                                        end
                                        Hekili:BuildToggleStatusBar()
                                    end
                                },
                                maxRows = {
                                    type = "range",
                                    name = "Max Rows",
                                    desc = "Maximum number of rows",
                                    min = 1, max = 9, step = 1,
                                    order = 5,
                                    width = 1.49,
                                    set = function(info, value)
                                        local settings = Hekili.DB.profile.toggleBar
                                        settings.maxRows = value
                                        -- Auto-adjust columns if needed
                                        local enabledCount = 0
                                        for i = 1, 9 do
                                            if settings[i] and settings[i].enabled ~= false then
                                                enabledCount = enabledCount + 1
                                            end
                                        end
                                        local neededColumns = math.ceil(enabledCount / value)
                                        if settings.maxColumns < neededColumns then
                                            settings.maxColumns = neededColumns
                                        end
                                        Hekili:BuildToggleStatusBar()
                                    end
                                },
                            },
                        },

                        styleGroup = {
                            type = "group",
                            name = "Style",
                            inline = true,
                            order = 4,
                            args = {
                                style = { type = "select", name = "Style", order = 1, width = 2.98, values = { none = "None", default = "Default", elvui = "ElvUI (if available)" } },
                            },
                        },
                    }
                },

                minimalist = {
                    type = "group",
                    name = "Minimalist Settings",
                    order = 20,
                    hidden = function() return (Hekili.DB.profile.toggleBar.displayMode or "standard") ~= "minimalist" end,
                    args = {
                        anchoring = {
                            type = "group",
                            name = "Position & Anchoring",
                            inline = true,
                            order = 1,
                            args = {
                                minimalistAnchor = { 
                                    type = "select", 
                                    name = "Anchor Mode", 
                                    desc = "How to position the minimalist indicators", 
                                    order = 1, 
                                    width = "full", 
                                    values = { primary = "Hekili Primary Display", screen = "Screen" }, 
                                    get = function() return Hekili.DB.profile.toggleBar.minimalistAnchor or "primary" end, 
                                    set = function(info, value) Hekili.DB.profile.toggleBar.minimalistAnchor = value; Hekili:BuildToggleStatusBar() end 
                                },
                                minimalistAnchorPoint = {
                                    type = "select",
                                    name = "Anchor Point",
                                    desc = "Which point of the primary display to attach to",
                                    order = 2,
                                    width = 1.49,
                                    values = { TOPLEFT = "Top Left", TOP = "Top", TOPRIGHT = "Top Right", LEFT = "Left", CENTER = "Center", RIGHT = "Right", BOTTOMLEFT = "Bottom Left", BOTTOM = "Bottom", BOTTOMRIGHT = "Bottom Right" },
                                    hidden = function() return Hekili.DB.profile.toggleBar.minimalistAnchor == "screen" end,
                                    get = function() return Hekili.DB.profile.toggleBar.minimalistAnchorPoint or "BOTTOM" end,
                                    set = function(info, value) Hekili.DB.profile.toggleBar.minimalistAnchorPoint = value; Hekili:BuildToggleStatusBar() end,
                                },
                                minimalistFromPoint = {
                                    type = "select",
                                    name = "From Point",
                                    desc = "Which point of the minimalist bar to anchor from",
                                    order = 3,
                                    width = 1.49,
                                    values = { TOPLEFT = "Top Left", TOP = "Top", TOPRIGHT = "Top Right", LEFT = "Left", CENTER = "Center", RIGHT = "Right", BOTTOMLEFT = "Bottom Left", BOTTOM = "Bottom", BOTTOMRIGHT = "Bottom Right" },
                                    hidden = function() return Hekili.DB.profile.toggleBar.minimalistAnchor == "screen" end,
                                    get = function() return Hekili.DB.profile.toggleBar.minimalistFromPoint or "TOP" end,
                                    set = function(info, value) Hekili.DB.profile.toggleBar.minimalistFromPoint = value; Hekili:BuildToggleStatusBar() end,
                                },
                                minimalistX = { 
                                    type = "range", 
                                    name = "X Offset", 
                                    min = -500,
                                    max = 500,
                                    step = 1, 
                                    width = 1.49, 
                                    order = 4, 
                                    get = function() return (Hekili.DB.profile.toggleBar.minimalistAnchor == "screen" and Hekili.DB.profile.toggleBar.minimalistX) or Hekili.DB.profile.toggleBar.minimalistPrimaryX or 0 end, 
                                    set = function(info, value) 
                                        if Hekili.DB.profile.toggleBar.minimalistAnchor == "screen" then
                                            Hekili.DB.profile.toggleBar.minimalistX = value
                                        else
                                            Hekili.DB.profile.toggleBar.minimalistPrimaryX = value
                                        end
                                        Hekili:BuildToggleStatusBar() 
                                    end 
                                },
                                minimalistY = { 
                                    type = "range", 
                                    name = "Y Offset", 
                                    min = -500,
                                    max = 500,
                                    step = 1, 
                                    width = 1.49, 
                                    order = 5, 
                                    get = function() return (Hekili.DB.profile.toggleBar.minimalistAnchor == "screen" and Hekili.DB.profile.toggleBar.minimalistY) or Hekili.DB.profile.toggleBar.minimalistPrimaryY or -5 end, 
                                    set = function(info, value) 
                                        if Hekili.DB.profile.toggleBar.minimalistAnchor == "screen" then
                                            Hekili.DB.profile.toggleBar.minimalistY = value
                                        else
                                            Hekili.DB.profile.toggleBar.minimalistPrimaryY = value
                                        end
                                        Hekili:BuildToggleStatusBar() 
                                    end 
                                },
                            }
                        },
                        minimalistToggles = {
                            type = "group",
                            name = "Active Toggles (Max 3)",
                            inline = true,
                            order = 2,
                            args = {
                                minimalistToggle1 = { type = "select", name = "Indicator 1", desc = "First toggle to display", order = 1, width = 1.49, values = { none = "None", cooldowns = "Major CDs", essences = "Minor CDs", defensives = "Defensives", interrupts = "Interrupts", potions = "Potions" }, get = function() return Hekili.DB.profile.toggleBar.minimalistToggle1 or "cooldowns" end, set = function(info, value) Hekili.DB.profile.toggleBar.minimalistToggle1 = value; Hekili:BuildToggleStatusBar() end },
                                minimalistToggle2 = { type = "select", name = "Indicator 2", desc = "Second toggle to display", order = 2, width = 1.49, values = { none = "None", cooldowns = "Major CDs", essences = "Minor CDs", defensives = "Defensives", interrupts = "Interrupts", potions = "Potions" }, get = function() return Hekili.DB.profile.toggleBar.minimalistToggle2 or "defensives" end, set = function(info, value) Hekili.DB.profile.toggleBar.minimalistToggle2 = value; Hekili:BuildToggleStatusBar() end },
                                minimalistToggle3 = { type = "select", name = "Indicator 3", desc = "Third toggle to display", order = 3, width = 1.49, values = { none = "None", cooldowns = "Major CDs", essences = "Minor CDs", defensives = "Defensives", interrupts = "Interrupts", potions = "Potions" }, get = function() return Hekili.DB.profile.toggleBar.minimalistToggle3 or "interrupts" end, set = function(info, value) Hekili.DB.profile.toggleBar.minimalistToggle3 = value; Hekili:BuildToggleStatusBar() end },
                            }
                        },

                        layoutGroup = {
                            type = "group",
                            name = "Appearance",
                            inline = true,
                            order = 3,
                            args = {
                                minimalistLayout = {
                                    type = "select",
                                    name = "Layout Style",
                                    desc = "How to arrange the minimalist indicators",
                                    order = 1,
                                    width = 1.49,
                                    values = { horizontal = "Horizontal", vertical = "Vertical" },
                                    get = function() return Hekili.DB.profile.toggleBar.minimalistLayout or "horizontal" end,
                                    set = function(info, value)
                                        Hekili.DB.profile.toggleBar.minimalistLayout = value
                                        
                                        -- Automatically adjust label position
                                        Hekili.DB.profile.toggleBar.labelPosition = GetAutomaticLabelPosition()
                                        
                                        Hekili:BuildToggleStatusBar()
                                        LibStub("AceConfigRegistry-3.0"):NotifyChange("Hekili")
                                    end,
                                },
                                minimalistAngle = {
                                    type = "range",
                                    name = "Curve Angle",
                                    desc = "Curve the indicator pattern. 0 = straight line, positive values curve one way, negative the other",
                                    order = 2,
                                    width = 1.49,
                                    min = -90,
                                    max = 90,
                                    step = 5,
                                    get = function() return Hekili.DB.profile.toggleBar.minimalistAngle or 0 end,
                                    set = function(info, value)
                                        Hekili.DB.profile.toggleBar.minimalistAngle = value
                                        
                                        -- Automatically adjust label position
                                        Hekili.DB.profile.toggleBar.labelPosition = GetAutomaticLabelPosition()
                                        
                                        Hekili:BuildToggleStatusBar()
                                    end,
                                },
                                minimalistSize = {
                                    type = "range",
                                    name = "Size",
                                    desc = "Size of minimalist indicators",
                                    order = 3,
                                    width = 1.49,
                                    min = 10,
                                    max = 50,
                                    step = 1,
                                    get = function() return Hekili.DB.profile.toggleBar.minimalistSize or 12 end,
                                    set = function(info, value)
                                        Hekili.DB.profile.toggleBar.minimalistSize = value
                                        Hekili:BuildToggleStatusBar()
                                    end,
                                },
                                minimalistSpacing = {
                                    type = "range",
                                    name = "Spacing",
                                    desc = "Space between minimalist indicators",
                                    order = 4,
                                    width = 1.49,
                                    min = 0,
                                    max = 20,
                                    step = 1,
                                    get = function() return Hekili.DB.profile.toggleBar.minimalistSpacing or 2 end,
                                    set = function(info, value)
                                        Hekili.DB.profile.toggleBar.minimalistSpacing = value
                                        Hekili:BuildToggleStatusBar()
                                    end,
                                },
                            },
                        },

                        colorGroup = {
                            type = "group",
                            name = "Colors",
                            inline = true,
                            order = 4,
                            args = {
                                minimalistColorEnabled = {
                                    type = "color",
                                    name = "Enabled Color",
                                    desc = "Color for enabled toggles",
                                    order = 1,
                                    width = 1.49,
                                    hasAlpha = true,
                                    get = function()
                                        local color = Hekili.DB.profile.toggleBar.minimalistColorEnabled or { r = 0, g = 1, b = 0, a = 1 }
                                        return color.r, color.g, color.b, color.a
                                    end,
                                    set = function(info, r, g, b, a)
                                        Hekili.DB.profile.toggleBar.minimalistColorEnabled = { r = r, g = g, b = b, a = a }
                                        Hekili:BuildToggleStatusBar()
                                    end,
                                },
                                minimalistColorDisabled = {
                                    type = "color",
                                    name = "Disabled Color",
                                    desc = "Color for disabled toggles",
                                    order = 2,
                                    width = 1.49,
                                    hasAlpha = true,
                                    get = function()
                                        local color = Hekili.DB.profile.toggleBar.minimalistColorDisabled or { r = 0.5, g = 0.5, b = 0.5, a = 1 }
                                        return color.r, color.g, color.b, color.a
                                    end,
                                    set = function(info, r, g, b, a)
                                        Hekili.DB.profile.toggleBar.minimalistColorDisabled = { r = r, g = g, b = b, a = a }
                                        Hekili:BuildToggleStatusBar()
                                    end,
                                },
                            },
                        },
                    }
                },

                behavior = {
                    type = "group",
                    name = "Behavior",
                    order = 30,
                    args = {
                        tooltipOutOfCombat = { type = "toggle", name = "Show Tooltips Out of Combat", desc = "If checked, tooltips will be shown when hovering over toggle icons while out of combat.", order = 1, width = 2.98 },
                        clickable = { type = "toggle", name = "Clickable Toggles", desc = "If checked, clicking on toggle icons will toggle them on/off.", order = 2, width = 2.98 },
                    },
                },

                labels = {
                    type = "group",
                    name = "Labels",
                    order = 40,
                    args = {
                        showLabels = { type = "toggle", name = "Show Labels", desc = "Display text labels for each toggle button", order = 1, width = 2.98 },
                        labelPosition = { 
                            type = "select", 
                            name = "Label Position", 
                            desc = "Where to position the label relative to the icon (automatically adjusts based on display mode and orientation)", 
                            order = 2, 
                            width = 1.49, 
                            disabled = function() return not Hekili.DB.profile.toggleBar.showLabels end, 
                            values = { TOP = "Top", BOTTOM = "Bottom", LEFT = "Left", RIGHT = "Right" },
                            set = function(info, value)
                                Hekili.DB.profile.toggleBar.labelPosition = value
                                Hekili:BuildToggleStatusBar()
                            end
                        },
                        labelFontSize = { type = "range", name = "Font Size", desc = "Size of the label text", min = 8, max = 20, step = 1, order = 3, width = 1.49, disabled = function() return not Hekili.DB.profile.toggleBar.showLabels end, set = function(info, value) Hekili.DB.profile.toggleBar.labelFontSize = value; Hekili:BuildToggleStatusBar() end },

                        customSettingsInfo = {
                            type = "description",
                            name = "\n|cFFFFD100Custom Button Settings|r\nNote: Custom icons only apply to Standard mode. Custom labels apply to both Standard and Minimalist modes.",
                            order = 10,
                            width = 2.98,
                        },

                        button1Label = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[1] and Hekili.DB.profile.toggleBar[1].toggle or "cooldowns"
                                return (toggleNames[toggle] or toggle) .. " Label"
                            end,
                            desc = "Custom label text for this toggle (applies to both modes)",
                            order = 11,
                            width = 1.49,
                            get = function() return Hekili.DB.profile.toggleBar[1] and Hekili.DB.profile.toggleBar[1].label or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[1] then Hekili.DB.profile.toggleBar[1] = {} end
                                Hekili.DB.profile.toggleBar[1].label = value ~= "" and value or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },
                        button1Icon = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[1] and Hekili.DB.profile.toggleBar[1].toggle or "cooldowns"
                                return (toggleNames[toggle] or toggle) .. " Icon"
                            end,
                            desc = "Custom icon texture ID (numbers only, Standard mode only)",
                            order = 12,
                            width = 1.49,
                            validate = function(info, value)
                                if value == "" then return true end
                                local num = tonumber(value)
                                if not num then return "Please enter a valid number" end
                                return true
                            end,
                            get = function() return Hekili.DB.profile.toggleBar[1] and tostring(Hekili.DB.profile.toggleBar[1].icon or "") or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[1] then Hekili.DB.profile.toggleBar[1] = {} end
                                Hekili.DB.profile.toggleBar[1].icon = value ~= "" and tonumber(value) or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },

                        button2Label = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[2] and Hekili.DB.profile.toggleBar[2].toggle or "essences"
                                return (toggleNames[toggle] or toggle) .. " Label"
                            end,
                            desc = "Custom label text for this toggle (applies to both modes)",
                            order = 13,
                            width = 1.49,
                            get = function() return Hekili.DB.profile.toggleBar[2] and Hekili.DB.profile.toggleBar[2].label or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[2] then Hekili.DB.profile.toggleBar[2] = {} end
                                Hekili.DB.profile.toggleBar[2].label = value ~= "" and value or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },
                        button2Icon = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[2] and Hekili.DB.profile.toggleBar[2].toggle or "essences"
                                return (toggleNames[toggle] or toggle) .. " Icon"
                            end,
                            desc = "Custom icon texture ID (numbers only, Standard mode only)",
                            order = 14,
                            width = 1.49,
                            validate = function(info, value)
                                if value == "" then return true end
                                local num = tonumber(value)
                                if not num then return "Please enter a valid number" end
                                return true
                            end,
                            get = function() return Hekili.DB.profile.toggleBar[2] and tostring(Hekili.DB.profile.toggleBar[2].icon or "") or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[2] then Hekili.DB.profile.toggleBar[2] = {} end
                                Hekili.DB.profile.toggleBar[2].icon = value ~= "" and tonumber(value) or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },

                        button3Label = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[3] and Hekili.DB.profile.toggleBar[3].toggle or "defensives"
                                return (toggleNames[toggle] or toggle) .. " Label"
                            end,
                            desc = "Custom label text for this toggle (applies to both modes)",
                            order = 15,
                            width = 1.49,
                            get = function() return Hekili.DB.profile.toggleBar[3] and Hekili.DB.profile.toggleBar[3].label or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[3] then Hekili.DB.profile.toggleBar[3] = {} end
                                Hekili.DB.profile.toggleBar[3].label = value ~= "" and value or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },
                        button3Icon = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[3] and Hekili.DB.profile.toggleBar[3].toggle or "defensives"
                                return (toggleNames[toggle] or toggle) .. " Icon"
                            end,
                            desc = "Custom icon texture ID (numbers only, Standard mode only)",
                            order = 16,
                            width = 1.49,
                            validate = function(info, value)
                                if value == "" then return true end
                                local num = tonumber(value)
                                if not num then return "Please enter a valid number" end
                                return true
                            end,
                            get = function() return Hekili.DB.profile.toggleBar[3] and tostring(Hekili.DB.profile.toggleBar[3].icon or "") or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[3] then Hekili.DB.profile.toggleBar[3] = {} end
                                Hekili.DB.profile.toggleBar[3].icon = value ~= "" and tonumber(value) or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },

                        button4Label = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[4] and Hekili.DB.profile.toggleBar[4].toggle or "interrupts"
                                return (toggleNames[toggle] or toggle) .. " Label"
                            end,
                            desc = "Custom label text for this toggle (applies to both modes)",
                            order = 17,
                            width = 1.49,
                            get = function() return Hekili.DB.profile.toggleBar[4] and Hekili.DB.profile.toggleBar[4].label or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[4] then Hekili.DB.profile.toggleBar[4] = {} end
                                Hekili.DB.profile.toggleBar[4].label = value ~= "" and value or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },
                        button4Icon = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[4] and Hekili.DB.profile.toggleBar[4].toggle or "interrupts"
                                return (toggleNames[toggle] or toggle) .. " Icon"
                            end,
                            desc = "Custom icon texture ID (numbers only, Standard mode only)",
                            order = 18,
                            width = 1.49,
                            validate = function(info, value)
                                if value == "" then return true end
                                local num = tonumber(value)
                                if not num then return "Please enter a valid number" end
                                return true
                            end,
                            get = function() return Hekili.DB.profile.toggleBar[4] and tostring(Hekili.DB.profile.toggleBar[4].icon or "") or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[4] then Hekili.DB.profile.toggleBar[4] = {} end
                                Hekili.DB.profile.toggleBar[4].icon = value ~= "" and tonumber(value) or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },

                        button5Label = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[5] and Hekili.DB.profile.toggleBar[5].toggle or "potions"
                                return (toggleNames[toggle] or toggle) .. " Label"
                            end,
                            desc = "Custom label text for this toggle (applies to both modes)",
                            order = 19,
                            width = 1.49,
                            get = function() return Hekili.DB.profile.toggleBar[5] and Hekili.DB.profile.toggleBar[5].label or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[5] then Hekili.DB.profile.toggleBar[5] = {} end
                                Hekili.DB.profile.toggleBar[5].label = value ~= "" and value or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },
                        button5Icon = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[5] and Hekili.DB.profile.toggleBar[5].toggle or "potions"
                                return (toggleNames[toggle] or toggle) .. " Icon"
                            end,
                            desc = "Custom icon texture ID (numbers only, Standard mode only)",
                            order = 20,
                            width = 1.49,
                            validate = function(info, value)
                                if value == "" then return true end
                                local num = tonumber(value)
                                if not num then return "Please enter a valid number" end
                                return true
                            end,
                            get = function() return Hekili.DB.profile.toggleBar[5] and tostring(Hekili.DB.profile.toggleBar[5].icon or "") or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[5] then Hekili.DB.profile.toggleBar[5] = {} end
                                Hekili.DB.profile.toggleBar[5].icon = value ~= "" and tonumber(value) or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },

                        button6Label = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[6] and Hekili.DB.profile.toggleBar[6].toggle or "funnel"
                                return (toggleNames[toggle] or toggle) .. " Label"
                            end,
                            desc = "Custom label text for this toggle (applies to both modes)",
                            order = 21,
                            width = 1.49,
                            hidden = function() return not Hekili.DB.profile.specs[state.spec.id].canFunnel end,
                            get = function() return Hekili.DB.profile.toggleBar[6] and Hekili.DB.profile.toggleBar[6].label or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[6] then Hekili.DB.profile.toggleBar[6] = {} end
                                Hekili.DB.profile.toggleBar[6].label = value ~= "" and value or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },
                        button6Icon = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[6] and Hekili.DB.profile.toggleBar[6].toggle or "funnel"
                                return (toggleNames[toggle] or toggle) .. " Icon"
                            end,
                            desc = "Custom icon texture ID (numbers only, Standard mode only)",
                            order = 22,
                            width = 1.49,
                            hidden = function() return not Hekili.DB.profile.specs[state.spec.id].canFunnel end,
                            validate = function(info, value)
                                if value == "" then return true end
                                local num = tonumber(value)
                                if not num then return "Please enter a valid number" end
                                return true
                            end,
                            get = function() return Hekili.DB.profile.toggleBar[6] and tostring(Hekili.DB.profile.toggleBar[6].icon or "") or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[6] then Hekili.DB.profile.toggleBar[6] = {} end
                                Hekili.DB.profile.toggleBar[6].icon = value ~= "" and tonumber(value) or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },

                        button7Label = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[7] and Hekili.DB.profile.toggleBar[7].toggle or "mode"
                                return (toggleNames[toggle] or toggle) .. " Label"
                            end,
                            desc = "Custom label text for this toggle (applies to both modes)",
                            order = 23,
                            width = 1.49,
                            get = function() return Hekili.DB.profile.toggleBar[7] and Hekili.DB.profile.toggleBar[7].label or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[7] then Hekili.DB.profile.toggleBar[7] = {} end
                                Hekili.DB.profile.toggleBar[7].label = value ~= "" and value or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },
                        button7Icon = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[7] and Hekili.DB.profile.toggleBar[7].toggle or "mode"
                                return (toggleNames[toggle] or toggle) .. " Icon"
                            end,
                            desc = "Custom icon texture ID (numbers only, Standard mode only)",
                            order = 24,
                            width = 1.49,
                            validate = function(info, value)
                                if value == "" then return true end
                                local num = tonumber(value)
                                if not num then return "Please enter a valid number" end
                                return true
                            end,
                            get = function() return Hekili.DB.profile.toggleBar[7] and tostring(Hekili.DB.profile.toggleBar[7].icon or "") or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[7] then Hekili.DB.profile.toggleBar[7] = {} end
                                Hekili.DB.profile.toggleBar[7].icon = value ~= "" and tonumber(value) or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },

                        button8Label = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[8] and Hekili.DB.profile.toggleBar[8].toggle or "custom1"
                                return (toggleNames[toggle] or toggle) .. " Label"
                            end,
                            desc = "Custom label text for this toggle (applies to both modes)",
                            order = 25,
                            width = 1.49,
                            get = function() return Hekili.DB.profile.toggleBar[8] and Hekili.DB.profile.toggleBar[8].label or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[8] then Hekili.DB.profile.toggleBar[8] = {} end
                                Hekili.DB.profile.toggleBar[8].label = value ~= "" and value or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },
                        button8Icon = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[8] and Hekili.DB.profile.toggleBar[8].toggle or "custom1"
                                return (toggleNames[toggle] or toggle) .. " Icon"
                            end,
                            desc = "Custom icon texture ID (numbers only, Standard mode only)",
                            order = 26,
                            width = 1.49,
                            validate = function(info, value)
                                if value == "" then return true end
                                local num = tonumber(value)
                                if not num then return "Please enter a valid number" end
                                return true
                            end,
                            get = function() return Hekili.DB.profile.toggleBar[8] and tostring(Hekili.DB.profile.toggleBar[8].icon or "") or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[8] then Hekili.DB.profile.toggleBar[8] = {} end
                                Hekili.DB.profile.toggleBar[8].icon = value ~= "" and tonumber(value) or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },

                        button9Label = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[9] and Hekili.DB.profile.toggleBar[9].toggle or "custom2"
                                return (toggleNames[toggle] or toggle) .. " Label"
                            end,
                            desc = "Custom label text for this toggle (applies to both modes)",
                            order = 27,
                            width = 1.49,
                            get = function() return Hekili.DB.profile.toggleBar[9] and Hekili.DB.profile.toggleBar[9].label or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[9] then Hekili.DB.profile.toggleBar[9] = {} end
                                Hekili.DB.profile.toggleBar[9].label = value ~= "" and value or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },
                        button9Icon = {
                            type = "input",
                            name = function()
                                local toggleNames = {
                                    cooldowns = "Major Cooldowns",
                                    essences = "Minor Cooldowns",
                                    defensives = "Defensives",
                                    interrupts = "Interrupts",
                                    potions = "Potions",
                                    funnel = "Funnel",
                                    mode = "Mode",
                                    custom1 = "Custom 1",
                                    custom2 = "Custom 2"
                                }
                                local toggle = Hekili.DB.profile.toggleBar[9] and Hekili.DB.profile.toggleBar[9].toggle or "custom2"
                                return (toggleNames[toggle] or toggle) .. " Icon"
                            end,
                            desc = "Custom icon texture ID (numbers only, Standard mode only)",
                            order = 28,
                            width = 1.49,
                            validate = function(info, value)
                                if value == "" then return true end
                                local num = tonumber(value)
                                if not num then return "Please enter a valid number" end
                                return true
                            end,
                            get = function() return Hekili.DB.profile.toggleBar[9] and tostring(Hekili.DB.profile.toggleBar[9].icon or "") or "" end,
                            set = function(info, value)
                                if not Hekili.DB.profile.toggleBar[9] then Hekili.DB.profile.toggleBar[9] = {} end
                                Hekili.DB.profile.toggleBar[9].icon = value ~= "" and tonumber(value) or nil
                                Hekili:BuildToggleStatusBar()
                            end,
                        },
                    },
                },
            }
        },
    }
end

-- Store in namespace for access
ns.ToggleStatusBarOptions = ToggleStatusBarOptions

return ToggleStatusBarOptions