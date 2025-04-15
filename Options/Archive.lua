                                --[[ forecastingSection = {
                                    type = "header",
                                    name = "Forecasting",
                                    order = 0.1,
                                    width = "full",
                                },

                                forecastingDescription = {
                                    type = "description",
                                    name = function ()
                                        local flame_shock = Hekili:GetSpellLinkWithTexture( 470411 )

                                    return format( "%sForecasting|r enables recommendations that are timed more precisely, when the conditions for using an ability are not immediately met.\n\n"
                                    .. "For example, if %s is used when %s is not active on your target, but your target has 1 second remaining, forecasting allows a recommendation of %s with a 1 second delay.\n\n"
                                    .. "If a lower priority ability is available sooner, it will be recommended instead.\n\n", BlizzBlue, flame_shock, flame_shock, flame_shock )
                                    end,
                                    order = 0.11,
                                    width = "full",
                                    fontSize = "small"
                                },

                                throttleForecastingCount = {
                                    type = "range",
                                    name = NewFeature .. " Maximum Forecasting Steps",
                                    desc = function () return format( "When generating recommendations, priority entries whose criteria are not met may be retested based on calculated delays.\n\n"
                                    .. "This forecasting enables recommendations to be timed more precisely, such as waiting for resource gains or auras to become refreshable, but can increase processing time.\n\n"
                                    .. "If set above zero, the forecasting window is limited to the specified number of steps, which may reduce processing time but |cffff0000may result in fewer/no recommendation(s) being generated|r.\n\n"
                                    .. "This value is disabled |cFFFFD100(0)|r by default, allowing any number of forecasting steps.\n\n"
                                    .. "%sRecommended: 0 (disabled)|r\n\n", BlizzBlue )
                                    end,
                                    order = 0.12,
                                    width = "full",
                                    min = 0,
                                    max = 10,
                                    step = 1
                                },

                                throttleForecastingTime = {
                                    type = "range",
                                    name = NewFeature .. " Maximum Forecasting Time (sec)",
                                    desc = function () return format( "When generating recommendations, priority entries whose criteria are not met may be retested based on calculated delays.\n\n"
                                    .. "This forecasting enables recommendations to be timed more precisely, such as waiting for resource gains or auras to become refreshable, but can increase processing time.\n\n"
                                    .. "If set above zero, the forecasting window is limited to the specified time in seconds, which may reduce processing time but |cffff0000may result in fewer/no recommendation(s) being generated|r.\n\n"
                                    .. "This value is disabled |cFFFFD100(0)|r by default, allowing forecasting up to 10 seconds in the future.\n\n"
                                    .. "%sRecommended: 0 (disabled)|r", BlizzBlue )
                                    end,
                                    order = 0.13,
                                    width = "full",
                                    min = 0,
                                    max = 10,
                                    step = 0.1
                                },

                                throttleForecastingAuto = {
                                    type = "toggle",
                                    name = NewFeature .. " Autotune Forecasting",
                                    desc = "When enabled, the engine will tune its Forecasting Steps and Forecasting Time based on whether the forecasting has successfully improved recommendations.",
                                    order = 0.14,
                                    width = "full",
                                },

                                throttlingSection = {
                                    type = "header",
                                    name = "Throttling",
                                    order = 0.2,
                                    width = "full",
                                },

                                throttlingDescription = {
                                    type = "description",
                                    name = function () return format( "%sThrottling|r limits the amount of processing time used to generate recommendation.\n\n"
                                    .. "These limits can help expedite recommendations or reduce the impact on CPU usage or FPS.\n\n", BlizzBlue )
                                    end,
                                    order = 0.21,
                                    width = "full",
                                    fontSize = "small"
                                },

                                throttleFrames = {
                                    type = "range",
                                    name = function () return format( "%s Target Minimum FPS (Actual FPS: %d)", NewFeature, GetFramerate() ) end,
                                    desc = function () return format( "By default, up to |cffffd10015ms|r per frame may be used to generate recommendations.\n\n"
                                    .. "This value is roughly equivalent to a Target Minimum FPS value of |cffffd10060|r.\n\n"
                                    .. "Reducing this setting will allow |cffffd100more|r processing time per frame, improving responsiveness but potentially reducing FPS.\n\n"
                                    .. "Increasing this setting will allow |cffffd100less|r processing time per frame, potentially improving FPS but reducing responsiveness.\n\n"
                                    .. "%sRecommended: 0 or 60 (default)|r", BlizzBlue )
                                    end,
                                    order = 0.22,
                                    width = "full",
                                    min = 0,
                                    max = 200,
                                    step = 1
                                },

                                throttleMinimum = {
                                    type = "range",
                                    name = NewFeature .. " Minimum Time Allowance (ms)",
                                    desc = function ()
                                        local fps = GetFramerate()
                                        local currentFrameTime = fps > 0 and ( 1000 / fps ) or 0
                                        local warning = currentFrameTime > 0 and format( "At your current (%d) FPS, values above |cffffd100%d|r may impact your framerate.\n\n", fps, currentFrameTime ) or ""

                                        return format( "By default, at least |cffffd1005ms|r may be used to generate recommendations.\n\n" .. warning
                                    .. "Increasing this setting may generate recommendations in fewer frames, improving responsiveness but potentially reducing FPS.\n\n"
                                    .. "Reducing this setting may generate recommendations over more frames, potentially improving FPS but reducing responsiveness.\n\n"
                                    .. "%sRecommended: 5ms (default)|r", BlizzBlue )
                                    end,
                                    order = 0.23,
                                    width = "full",
                                    min = 5,
                                    max = 200,
                                    step = 1
                                },

                                throttleMaximum = {
                                    type = "range",
                                    name = NewFeature .. " Maximum Time Allowance (ms)",
                                    desc = function ()
                                        local fps = GetFramerate()
                                        local currentFrameTime = fps > 0 and ( 1000 / fps ) or 0
                                        local warning = currentFrameTime > 0 and format( "At your current (%d) FPS, values above |cffffd100%d|r may impact your framerate.\n\n", fps, currentFrameTime ) or ""

                                        return format( "By default, up to |cffffd10015ms|r may be used to generate recommendations.\n\n" .. warning
                                    .. "Increasing this setting may generate recommendations in fewer frames, increasing responsiveness but potentially reducing FPS.\n\n"
                                    .. "Reducing this setting may generate recommendations over more frames, reducing responsiveness but decreasing impact to FPS.\n\n"
                                    .. "%sRecommended: 15ms (default)|r", BlizzBlue )
                                    end,
                                    order = 0.24,
                                    width = "full",
                                    min = 5,
                                    max = 200,
                                    step = 1
                                },

                                throttlePercent = {
                                    type = "range",
                                    name = NewFeature .. " Maximum Frame Time %",
                                    desc = function ()
                                        local fps = GetFramerate()
                                        local currentFrameTime = fps > 0 and ( 1000 / fps ) or 0
                                        local cap = self.DB.profile.specs[ id ].throttleMaximum or 0
                                        local warning = ""


                                        if cap > 0 then
                                            warning = format( "At your current |cFFFFD100Maximum Time Allowance|r, processing time would be limited to %d per frame.\n\n", fps, cap )
                                        elseif currentFrameTime > 0 then
                                            warning = format( "At your current (%d) FPS, processing time would be limited to %d per frame.\n\n", fps, currentFrameTime )
                                        end

                                        return format( "By default, up to |cffffd10090%%|r may be used to generate recommendations.\n\n" .. warning
                                    .. "Increasing this setting may generate recommendations in fewer frames, increasing responsiveness but potentially reducing FPS.\n\n"
                                    .. "Reducing this setting may generate recommendations over more frames, reducing responsiveness but decreasing impact to FPS.\n\n"
                                    .. "%sRecommended: 90%% (default)|r", BlizzBlue )
                                    end,
                                    order = 0.25,
                                    width = "full",
                                    min = 0,
                                    max = 1,
                                    step = 0.01,
                                    isPercent = true
                                }, ]]



                                                -- Toggles
                --[[ BuildToggleList( options, id, "cooldowns",  "Cooldowns" )
                BuildToggleList( options, id, "essences",   "Minor CDs" )
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
                end ) ]]



                --[[local function BuildToggleList( options, specID, section, useName, description, extraOptions )
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

                            e = tlEntry( section .. "Toggle" .. ability )
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

                            offset = offset + 0.001

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
                end--]]

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

                                --[[ essLineBreak1 = {
                                    type = "description",
                                    name = "",
                                    width = "full",
                                    order = 2.1
                                },

                                essIndent1 = {
                                    type = "description",
                                    name = "",
                                    width = 1,
                                    order = 2.2
                                },

                                separate = {
                                    type = "toggle",
                                    name = format( "Show in Separate %s Cooldowns Display", AtlasToString( "chromietime-32x32" ) ),
                                    desc = format( "If checked, abilities that require the |cFFFFD100Minor Cooldowns|r toggle will be shown separately in your |W%s "
                                        .. "|cFFFFD100Cooldowns|r|w display when the toggle is enabled.\n\n"
                                        .. "This is an experimental feature and may not work well for some specializations.", AtlasToString( "chromietime-32x32" ) ),
                                    width = 2,
                                    order = 3,
                                }, ]]


                                --[[ potLineBreak1 = {
                                    type = "description",
                                    name = "",
                                    width = "full",
                                    order = 2.1
                                },

                                potIndent1 = {
                                    type = "description",
                                    name = "",
                                    width = 1,
                                    order = 2.2
                                },

                                separate = {
                                    type = "toggle",
                                    name = format( "Show in Separate %s Cooldowns Display", AtlasToString( "chromietime-32x32" ) ),
                                    desc = format( "If checked, abilities that require the |cFFFFD100Potions|r toggle will be shown separately in your |W%s "
                                        .. "|cFFFFD100Cooldowns|r|w display when the toggle is enabled.\n\n"
                                        .. "This is an experimental feature and may not work well for some specializations.", AtlasToString( "chromietime-32x32" ) ),
                                    width = 2,
                                    order = 3,
                                }, ]]
                                --[[ autoDesc = {
                                    type = "description",
                                    name = "Automatic mode uses the Primary display and makes recommendations based on the number of enemies automatically detected.",
                                    width = 2.85,
                                    order = 3.2,
                                }, ]]

                                                                --[[ singleDesc = {
                                    type = "description",
                                    name = "Single-Target mode uses the Primary display and makes recommendations as though you have a single target.  This mode can be useful when focusing down an enemy inside a larger group.",
                                    width = 2.85,
                                    order = 4.2,
                                }, ]]

                                                                --[[ aoeDesc = {
                                    type = "description",
                                    name = function ()
                                        return format( "AOE mode uses the Primary display and makes recommendations as though you have |cFFFFD100%d|r (or more) targets.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                                    end,
                                    width = 2.85,
                                    order = 5.2,
                                }, ]]

                                                                --[[ dualDesc = {
                                    type = "description",
                                    name = function ()
                                        return format( "Dual mode shows single-target recommendations in the Primary display and multi-target (|cFFFFD100%d|r or more enemies) recommendations in the AOE display.  Both displays are shown at all times.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                                    end,
                                    width = 2.85,
                                    order = 6.2,
                                }, ]]

                                                                --[[ reactiveDesc = {
                                    type = "description",
                                    name = function ()
                                        return format( "Dual mode shows single-target recommendations in the Primary display and multi-target recommendations in the AOE display.  The Primary display is always active, while the AOE display activates only when |cFFFFD100%d|r or more targets are detected.", self.DB.profile.specs[ state.spec.id ].aoe or 3 )
                                    end,
                                    width = 2.85,
                                    order = 7.2,
                                },]]

                                                --[[q5 = {
                        type = "header",
                        name = "Something's Wrong",
                        order = 5,
                        width = "full",
                    },
                    a5 = {
                        type = "description",
                        name = "You can submit questions, concerns, and ideas via the link found in the |cFFFFD100Snapshots (Troubleshooting)|r section.\n\n" ..
                            "If you disagree with the addon's recommendations, the |cFFFFD100Snapshot|r feature allows you to capture a log of the addon's decision-making taken at the exact moment specific recommendations are shown.  " ..
                            "When you submit your question, be sure to take a snapshot (not a screenshot!), place the text on Pastebin, and include the link when you submit your issue ticket.",
                        order = 5.1,
                        fontSize = "medium",
                        width = "full",
                    }--]]