-- RogueSubtlety.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR


-- Conduits
-- [x] deeper_daggers
-- [x] perforated_veins
-- [-] planned_execution
-- [-] stiletto_staccato


if UnitClassBase( "player" ) == "ROGUE" then
    local spec = Hekili:NewSpecialization( 261 )

    spec:RegisterResource( Enum.PowerType.Energy, {
        shadow_techniques = {
            last = function () return state.query_time end,
            interval = function () return state.time_to_sht[5] end,
            value = 8,
            stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
        }, 
    } )

    spec:RegisterResource( Enum.PowerType.ComboPoints, {
        shadow_techniques = {
            last = function () return state.query_time end,
            interval = function () return state.time_to_sht[5] end,
            value = 1,
            stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
        },

        shuriken_tornado = {
            aura = "shuriken_tornado",
            last = function ()
                local app = state.buff.shuriken_tornado.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x ) return state.buff.shuriken_tornado.remains == 0 end,

            interval = 0.95,
            value = function () return state.active_enemies + ( state.buff.shadow_blades.up and 1 or 0 ) end,
        },
    } )

    -- Talents
    spec:RegisterTalents( {
        weaponmaster = 19233, -- 193537
        premeditation = 19234, -- 343160
        gloomblade = 19235, -- 200758

        nightstalker = 22331, -- 14062
        subterfuge = 22332, -- 108208
        shadow_focus = 22333, -- 108209

        vigor = 19239, -- 14983
        deeper_stratagem = 19240, -- 193531
        marked_for_death = 19241, -- 137619

        soothing_darkness = 22128, -- 200759
        cheat_death = 22122, -- 31230
        elusiveness = 22123, -- 79008

        shot_in_the_dark = 23078, -- 257505
        night_terrors = 23036, -- 277953
        prey_on_the_weak = 22115, -- 131511

        dark_shadow = 22335, -- 245687
        alacrity = 19249, -- 193539
        enveloping_shadows = 22336, -- 238104

        master_of_shadows = 22132, -- 196976
        secret_technique = 23183, -- 280719
        shuriken_tornado = 21188, -- 277925
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        cold_blood = 140, -- 213981
        dagger_in_the_dark = 846, -- 198675
        death_from_above = 3462, -- 269513
        honor_among_thieves = 3452, -- 198032
        maneuverability = 3447, -- 197000
        shadowy_duel = 153, -- 207736
        silhouette = 856, -- 197899
        smoke_bomb = 1209, -- 212182
        thiefs_bargain = 146, -- 212081
        veil_of_midnight = 136, -- 198952
    } )

    -- Auras
    spec:RegisterAuras( {
    	alacrity = {
            id = 193538,
            duration = 20,
            max_stack = 5,
        },
        blind = {
            id = 2094,
            duration = 60,
            max_stack = 1,
        },
        cheap_shot = {
            id = 1833,
            duration = 4,
            max_stack = 1,
        },
        cloak_of_shadows = {
            id = 31224,
            duration = 5,
            max_stack = 1,
        },
        death_from_above = {
            id = 152150,
            duration = 1,
        },
        crimson_vial = {
            id = 185311,
            duration = 4,
            max_stack = 1,
        },
        crippling_poison = {
            id = 3408,
            duration = 3600,
            max_stack = 1,
        },
        crippling_poison_dot = {
            id = 3409,
            duration = 12,
            max_stack = 1,
        },
        evasion = {
            id = 5277,
            duration = 10,
            max_stack = 1,
        },
        feint = {
            id = 1966,
            duration = 5,
            max_stack = 1,
        },
        find_weakness = {
            id = 316220,
            duration = 18,
            max_stack = 1,
        },
        fleet_footed = {
            id = 31209,
        },
        instant_poison = {
            id = 315584,
            duration = 3600,
            max_stack = 1,
        },
        kidney_shot = {
            id = 408,
            duration = 6,
            max_stack = 1,
        },
        marked_for_death = {
            id = 137619,
            duration = 60,
            max_stack = 1,
        },
        master_of_shadows = {
            id = 196980,
            duration = 3,
            max_stack = 1,
        },
        premeditation = {
            id = 343173,
            duration = 3600,
            max_stack = 1,
        },
        prey_on_the_weak = {
            id = 255909,
            duration = 6,
            max_stack = 1,
        },
        relentless_strikes = {
            id = 58423,
        },
        --[[ Share Assassination implementation to avoid errors.
        rupture = {
            id = 1943,
            duration = function () return talent.deeper_stratagem.enabled and 28 or 24 end,
            max_stack = 1,
        }, ]]
        shadow_blades = {
            id = 121471,
            duration = 20,
            max_stack = 1,
        },
        shadow_dance = {
            id = 185422,
            duration = function () return talent.subterfuge.enabled and 6 or 5 end,
            max_stack = 1,
        },
        shadows_grasp = {
            id = 206760,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        shadow_techniques = {
            id = 196912,
        },
        shadowstep = {
            id = 36554,
            duration = 2,
            max_stack = 1,
        },
        shot_in_the_dark = {
            id = 257506,
            duration = 3600,
            max_stack = 1,
        },
        shroud_of_concealment = {
            id = 114018,
            duration = 15,
            max_stack = 1,
        },
        shuriken_tornado = {
            id = 277925,
            duration = 4,
            max_stack = 1,
        },
        slice_and_dice = {
            id = 315496,
            duration = 10,
            max_stack = 1,
        },
        sprint = {
            id = 2983,
            duration = 8,
            max_stack = 1,
        },
        stealth = {
            id = function () return talent.subterfuge.enabled and 115191 or 1784 end,
            duration = 3600,
            max_stack = 1,
            copy = { 115191, 1784 }
        },
        subterfuge = {
            id = 115192,
            duration = 3,
            max_stack = 1,
        },
        symbols_of_death = {
            id = 212283,
            duration = 10,
            max_stack = 1,
        },
        symbols_of_death_crit = {
            id = 227151,
            duration = 10,
            max_stack = 1,
        },
        vanish = {
            id = 11327,
            duration = 3,
            max_stack = 1,
        },
        wound_poison = {
            id = 8679,
            duration = 3600,
            max_stack = 1,
        },


        lethal_poison = {
            alias = { "instant_poison", "wound_poison", "slaughter_poison" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600
        },
        nonlethal_poison = {
            alias = { "crippling_poison", "numbing_poison" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600
        },


        -- Azerite Powers
        blade_in_the_shadows = {
            id = 279754,
            duration = 60,
            max_stack = 10,
        },

        nights_vengeance = {
            id = 273424,
            duration = 8,
            max_stack = 1,
        },

        perforate = {
            id = 277720,
            duration = 12,
            max_stack = 1
        },

        replicating_shadows = {
            id = 286131,
            duration = 1,
            max_stack = 50
        },

        the_first_dance = {
            id = 278981,
            duration = function () return buff.shadow_dance.duration end,
            max_stack = 1,
        },


        -- Legendaries (Shadowlands)
        deathly_shadows = {
            id = 341202,
            duration = 15,
            max_stack = 3,
        }

    } )


    local true_stealth_change = 0
    local emu_stealth_change = 0

    spec:RegisterEvent( "UPDATE_STEALTH", function ()
        true_stealth_change = GetTime()
    end )

    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            if k == "rogue" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up
            elseif k == "rogue_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains )

            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "mantle_remains" then
                return max( buff.stealth.remains, buff.vanish.remains )
            
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up
            elseif k == "remains" or k == "all_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains )
            end

            return false
        end
    } ) )


    local last_mh = 0
    local last_oh = 0
    local last_shadow_techniques = 0
    local swings_since_sht = 0

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID then
            if subtype == "SPELL_ENERGIZE" and spellID == 196911 then
                last_shadow_techniques = GetTime()
                swings_since_sht = 0
            end

            if subtype:sub( 1, 5 ) == "SWING" and not multistrike then
                if subtype == "SWING_MISSED" then
                    offhand = spellName
                end

                local now = GetTime()

                if now > last_shadow_techniques + 3 then
                    swings_since_sht = swings_since_sht + 1
                end

                if offhand then last_mh = GetTime()
                else last_mh = GetTime() end
            end
        end
    end )


    local sht = {}

    spec:RegisterStateTable( "time_to_sht", setmetatable( {}, {
        __index = function( t, k )
            local n = tonumber( k )
            n = n - ( n % 1 )

            if not n or n > 5 then return 3600 end

            if n <= swings_since_sht then return 0 end

            local mh_speed = swings.mainhand_speed
            local mh_next = ( swings.mainhand > now - 3 ) and ( swings.mainhand + mh_speed ) or now + ( mh_speed * 0.5 )

            local oh_speed = swings.offhand_speed               
            local oh_next = ( swings.offhand > now - 3 ) and ( swings.offhand + oh_speed ) or now

            table.wipe( sht )

            sht[1] = mh_next + ( 1 * mh_speed )
            sht[2] = mh_next + ( 2 * mh_speed )
            sht[3] = mh_next + ( 3 * mh_speed )
            sht[4] = mh_next + ( 4 * mh_speed )
            sht[5] = oh_next + ( 1 * oh_speed )
            sht[6] = oh_next + ( 2 * oh_speed )
            sht[7] = oh_next + ( 3 * oh_speed )
            sht[8] = oh_next + ( 4 * oh_speed )


            local i = 1

            while( sht[i] ) do
                if sht[i] < last_shadow_techniques + 3 then
                    table.remove( sht, i )
                else
                    i = i + 1
                end
            end

            if #sht > 0 and n - swings_since_sht < #sht then
                table.sort( sht )
                return max( 0, sht[ n - swings_since_sht ] - query_time )
            else
                return 3600
            end
        end
    } ) )


    spec:RegisterStateExpr( "bleeds", function ()
        return ( debuff.garrote.up and 1 or 0 ) + ( debuff.rupture.up and 1 or 0 )
    end )


    spec:RegisterStateExpr( "cp_max_spend", function ()
        return combo_points.max
    end )

    -- Legendary from Legion, shows up in APL still.
    spec:RegisterGear( "cinidaria_the_symbiote", 133976 )
    spec:RegisterGear( "denial_of_the_halfgiants", 137100 )

    local function comboSpender( amt, resource )
        if resource == "combo_points" then
            if amt > 0 then
                gain( 6 * amt, "energy" )
            end

            if talent.alacrity.enabled and amt >= 5 then
                addStack( "alacrity", 20, 1 )
            end

            if talent.secret_technique.enabled then
                cooldown.secret_technique.expires = max( 0, cooldown.secret_technique.expires - amt )
            end

            cooldown.shadow_blades.expires = max( 0, cooldown.shadow_blades.expires - ( amt * 1.5 ) )
        end
    end

    spec:RegisterHook( "spend", comboSpender )
    -- spec:RegisterHook( "spendResources", comboSpender )


    spec:RegisterStateExpr( "mantle_duration", function ()
        return 0

        --[[ if stealthed.mantle then return cooldown.global_cooldown.remains + 5
        elseif buff.master_assassins_initiative.up then return buff.master_assassins_initiative.remains end
        return 0 ]]
    end )


    spec:RegisterStateExpr( "priority_rotation", function ()
        return false
    end )


    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.mantle and ( not a or a.startsCombat ) then
            if talent.subterfuge.enabled and stealthed.mantle then
                applyBuff( "subterfuge" )
            end

            if buff.stealth.up then 
                setCooldown( "stealth", 2 )
            end
            removeBuff( "stealth" )
            removeBuff( "vanish" )
            removeBuff( "shadowmeld" )
        end
    end )


    spec:RegisterGear( "insignia_of_ravenholdt", 137049 )
    spec:RegisterGear( "mantle_of_the_master_assassin", 144236 )
        spec:RegisterAura( "master_assassins_initiative", {
            id = 235027,
            duration = 5
        } )

        spec:RegisterStateExpr( "mantle_duration", function()
            if stealthed.mantle then return cooldown.global_cooldown.remains + buff.master_assassins_initiative.duration
            elseif buff.master_assassins_initiative.up then return buff.master_assassins_initiative.remains end
            return 0
        end )


    spec:RegisterGear( "shadow_satyrs_walk", 137032 )
        spec:RegisterStateExpr( "ssw_refund_offset", function()
            return target.distance
        end )

    spec:RegisterGear( "soul_of_the_shadowblade", 150936 )
    spec:RegisterGear( "the_dreadlords_deceit", 137021 )
        spec:RegisterAura( "the_dreadlords_deceit", {
            id = 228224, 
            duration = 3600,
            max_stack = 20,
            copy = 208693
        } )

    spec:RegisterGear( "the_first_of_the_dead", 151818 )
        spec:RegisterAura( "the_first_of_the_dead", {
            id = 248210, 
            duration = 2 
        } )

    spec:RegisterGear( "will_of_valeera", 137069 )
        spec:RegisterAura( "will_of_valeera", {
            id = 208403, 
            duration = 5 
        } )

    -- Tier Sets
    spec:RegisterGear( "tier21", 152163, 152165, 152161, 152160, 152162, 152164 )
    spec:RegisterGear( "tier20", 147172, 147174, 147170, 147169, 147171, 147173 )
    spec:RegisterGear( "tier19", 138332, 138338, 138371, 138326, 138329, 138335 )


    -- Abilities
    spec:RegisterAbilities( {
        backstab = {
            id = 53,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132090,

            notalent = "gloomblade",

            handler = function ()
                applyDebuff( "target", "shadows_grasp", 8 )
                if azerite.perforate.enabled and buff.perforate.up then
                    -- We'll assume we're attacking from behind if we've already put up Perforate once.
                    addStack( "perforate", nil, 1 )
                    gainChargeTime( "shadow_blades", 0.5 )
                end
                gain( buff.shadow_blades.up and 2 or 1, "combo_points" )
                removeBuff( "symbols_of_death_crit" )
                removeBuff( "perforated_veins" )
            end,
        },


        blind = {
            id = 2094,
            cast = 0,
            cooldown = function () return 120 - ( talent.blinding_powder.enabled and 30 or 0 ) end,
            gcd = "spell",

            startsCombat = true,
            texture = 136175,

            handler = function ()
              applyDebuff( "target", "blind", 60)
            end,
        },


        cheap_shot = {
            id = 1833,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () 
                if buff.shot_in_the_dark.up then return 0 end
                return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 - conduit.rushed_setup.mod * 0.01 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132092,

            cycle = function ()
                if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
            end,

            usable = function ()
                if boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all or buff.subterfuge.up, "not stealthed"
            end,

            handler = function ()
                applyDebuff( "target", "find_weakness" )

                if talent.prey_on_the_weak.enabled then
                    applyDebuff( "target", "prey_on_the_weak" )
                end

                if talent.subterfuge.enabled then
                	applyBuff( "subterfuge" )
                end

                applyDebuff( "target", "cheap_shot" )
                removeBuff( "shot_in_the_dark" )

                gain( 2 + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
                removeBuff( "symbols_of_death_crit" )
            end,
        },


        cloak_of_shadows = {
            id = 31224,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136177,

            handler = function ()
                applyBuff( "cloak_of_shadows", 5 )
            end,
        },


        crimson_vial = {
            id = 185311,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            toggle = "cooldowns",

            spend = function () return ( 20 - conduit.nimble_fingers.mod ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 1373904,

            handler = function ()
                applyBuff( "crimson_vial", 6 )
            end,
        },


        crippling_poison = {
            id = 3408,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            essential = true,
            
            startsCombat = false,
            texture = 132274,
            
            readyTime = function () return buff.nonlethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "crippling_poison" )
            end,
        },


        distract = {
            id = 1725,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return 30 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132289,

            handler = function ()
            end,
        },


        evasion = {
            id = 5277,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136205,

            handler = function ()
            	applyBuff( "evasion", 10 )
            end,
        },


        eviscerate = {
            id = 196819,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132292,

            usable = function () return combo_points.current > 0 end,
            handler = function ()
            	if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end
                removeBuff( "nights_vengeance" )

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )

                if conduit.deeper_daggers.enabled then applyBuff( "deeper_daggers" ) end
            end,

            auras = {
                -- Conduit
                deeper_daggers = {
                    id = 341550,
                    duration = 5,
                    max_stack = 1
                }
            }
        },


        feint = {
            id = 1966,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = function () return ( 35 - conduit.nimble_fingers.mod ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132294,

            handler = function ()
                applyBuff( "feint", 5 )
            end,
        },


        gloomblade = {
            id = 200758,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            talent = "gloomblade",

            startsCombat = true,
            texture = 1035040,

            handler = function ()
                applyDebuff( "target", "shadows_grasp", 8 )
            	if buff.stealth.up then
            		removeBuff( "stealth" )
            	end
                gain( buff.shadow_blades.up and 2 or 1, "combo_points" )
                removeBuff( "symbols_of_death_crit" )
            end,
        },


        instant_poison = {
            id = 315584,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            essential = true,
            
            startsCombat = false,
            texture = 132273,
            
            readyTime = function () return buff.lethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "instant_poison" )
            end,
        },


        kick = {
            id = 1766,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            toggle = "interrupts", 
            interrupt = true,

            startsCombat = true,
            texture = 132219,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
                
                if conduit.prepared_for_all.enabled and cooldown.cloak_of_shadows.remains > 0 then
                    reduceCooldown( "cloak_of_shadows", 2 * conduit.prepared_for_all.mod )
                end
            end,
        },


        kidney_shot = {
            id = 408,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 25 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132298,

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )
                applyBuff( "kidney_shot", 2 + 1 * ( combo - 1 ) )

                if talent.prey_on_the_weak.enabled then applyDebuff( "target", "prey_on_the_weak" ) end

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },


        marked_for_death = {
            id = 137619,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            talent = "marked_for_death", 

            toggle = "cooldowns",

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return settings.mfd_waste or combo_points.current == 0, "combo_point (" .. combo_points.current .. ") waste not allowed"
            end,

            handler = function ()
                gain( 5, "combo_points")
                applyDebuff( "target", "marked_for_death", 60 )
            end,
        },


        numbing_poison = {
            id = 5761,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            essential = true,
            
            startsCombat = false,
            texture = 136066,
            
            readyTime = function () return buff.nonlethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "numbing_poison" )
            end,
        },

        pick_lock = {
            id = 1804,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136058,

            handler = function ()
            end,
        },


        pick_pocket = {
            id = 921,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            startsCombat = false,
            texture = 133644,

            handler = function ()
            end,
        },


        rupture = {
            id = 1943,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 25 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132302,
            
            handler = function ()
                if talent.alacrity.enabled and combo_points.current >= 5 then addStack( "alacrity", nil, 1 ) end
                applyDebuff( "target", "rupture", 4 + ( 4 * combo_points.current ) )

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },


        sap = {
            id = 6770,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132310,

            handler = function ()
                applyDebuff( "target", "sap", 60 )
            end,
        },


        secret_technique = {
            id = 280719,
            cast = 0,
            cooldown = function () return 45 - min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ) end,
            gcd = "spell",

            spend = function () return 30 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132305,

            usable = function () return combo_points.current > 0, "requires combo_points" end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then addStack( "alacrity", nil, 1 ) end                
                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },


        shadow_blades = {
            id = 121471,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 376022,

            handler = function ()
            	applyBuff( "shadow_blades" )
            end,
        },


        shadow_dance = {
            id = 185313,
            cast = 0,
            charges = 2,
            cooldown = 60,
            recharge = 60,
            gcd = "off",

            startsCombat = false,
            texture = 236279,

            nobuff = "shadow_dance",

            usable = function () return not stealthed.all, "not used in stealth" end,
            handler = function ()
                applyBuff( "shadow_dance" )
                if talent.shot_in_the_dark.enabled then applyBuff( "shot_in_the_dark" ) end
                if talent.master_of_shadows.enabled then applyBuff( "master_of_shadows", 3 ) end
                if azerite.the_first_dance.enabled then
                    gain( 2, "combo_points" )
                    applyBuff( "the_first_dance" )
                end
            end,
        },
        

        shadow_vault = {
            id = 319175,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 135430,

            usable = function () return combo_points.current > 0, "requires combo_points" end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then addStack( "alacrity", nil, 1 ) end
                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
                if conduit.deeper_daggers.enabled then applyBuff( "deeper_daggers" ) end
            end,
        },


        shadowstep = {
            id = 36554,
            cast = 0,
            charges = 2,
            cooldown = function () return 30 * ( 1 - conduit.quick_decisions.mod * 0.01 ) end,
            recharge = function () return 30 * ( 1 - conduit.quick_decisions.mod * 0.01 ) end,
            gcd = "off",

            startsCombat = false,
            texture = 132303,

            handler = function ()
            	applyBuff( "shadowstep" )
            end,
        },


        shadowstrike = {
            id = 185438,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( azerite.blade_in_the_shadows.enabled and 38 or 40 ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            cycle = function () return talent.find_weakness.enabled and "find_weakness" or nil end,

            startsCombat = true,
            texture = 1373912,

            usable = function () return stealthed.all, "requires stealth" end,
            handler = function ()
                gain( buff.shadow_blades.up and 3 or 2, "combo_points" )
                removeBuff( "symbols_of_death_crit" )

                if azerite.blade_in_the_shadows.enabled then addStack( "blade_in_the_shadows", nil, 1 ) end
                if buff.premeditation.up then
                    if buff.slice_and_dice.up then
                        gain( 2, "combo_points" )
                        if buff.slice_and_dice.remains < 10 then buff.slice_and_dice.expires = query_time + 10 end
                    else
                        applyBuff( "slice_and_dice", 10 )
                    end
                    removeBuff( "premeditation" )
                end

                if conduit.perforated_veins.enabled then
                    addStack( "perforated_veins", nil, 1 )
                end

                applyDebuff( "target", "find_weakness" )
            end,

            auras = {
                -- Conduit
                perforated_veins = {
                    id = 341572,
                    duration = 12,
                    max_stack = 3
                },
            }
        },


        shiv = {
            id = 5938,
            cast = 0,
            cooldown = 25,
            gcd = "spell",
            
            spend = function () return 25 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 135428,
            
            handler = function ()
                gain( 1, "combo_points" )
                removeBuff( "symbols_of_death_crit" )
                applyDebuff( "target", "crippling_poison_shiv" )
            end,

            auras = {
                crippling_poison_shiv = {
                    id = 319504,
                    duration = 9,
                    max_stack = 1,        
                },
            }
        },


        shroud_of_concealment = {
            id = 114018,
            cast = 0,
            cooldown = 360,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 635350,

            handler = function ()
                applyBuff( "shroud_of_concealment" )
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
            end,
        },


        shuriken_storm = {
            id = 197835,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 1375677,

            handler = function ()
                gain( active_enemies + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
                removeBuff( "symbols_of_death_crit" )
            end,
        },


        shuriken_tornado = {
            id = 277925,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = function () return 60 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            toggle = "cooldowns",

            talent = "shuriken_tornado",

            startsCombat = true,
            texture = 236282,

            handler = function ()
             	applyBuff( "shuriken_tornado" )
            end,
        },


        shuriken_toss = {
            id = 114014,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 135431,

            handler = function ()
                gain( active_enemies + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
                removeBuff( "symbols_of_death_crit" )
            end,
        },


        slice_and_dice = {
            id = 315496,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = false,
            texture = 132306,

            usable = function()
                return combo_points.current > 0, "requires combo_points"
            end,

            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )
                applyBuff( "slice_and_dice", 6 + 6 * combo )
                spend( combo, "combo_points" )
            end,
        },


        sprint = {
            id = 2983,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            startsCombat = false,
            texture = 132307,

            handler = function ()
                applyBuff( "sprint" )
            end,
        },


        stealth = {
            id = function () return talent.subterfuge.enabled and 115191 or 1784 end,
            known = 1784,
            cast = 0,
            cooldown = 2,
            gcd = "off",

            startsCombat = false,
            texture = 132320,

            usable = function ()
                if time > 0 then return false, "cannot use in combat" end
                if buff.stealth.up then return false, "cannot use in stealth" end
                if buff.vanish.up then return false, "cannot use while vanished" end
                return true
            end,
            readyTime = function () return buff.shadow_dance.remains end,
            handler = function ()
                applyBuff( "stealth" )
                if talent.shot_in_the_dark.enabled then applyBuff( "shot_in_the_dark" ) end
                if talent.premeditation.enabled then applyBuff( "premeditation" ) end

                emu_stealth_change = query_time

                if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end  
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end              
            end,

            copy = { 1784, 115191 }
        },


        symbols_of_death = {
            id = 212283,
            cast = 0,
            charges = 1,
            cooldown = 30,
            recharge = 30,
            gcd = "off",

            spend = -40,
            spendType = "energy",

            startsCombat = false,
            texture = 252272,

            handler = function ()
                applyBuff( "symbols_of_death" )
                applyBuff( "symbols_of_death_crit" )
            end,
        },


        tricks_of_the_trade = {
            id = 57934,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 236283,

            usable = function () return group, "requires an ally" end,
            handler = function ()
                applyBuff( "tricks_of_the_trade" )
            end,
        },


        vanish = {
            id = 1856,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 132331,

            disabled = function ()
                return not ( boss and group )
            end,

            handler = function ()
                applyBuff( "vanish", 3 )
                applyBuff( "stealth" )
                emu_stealth_change = query_time

                if legendary.deathly_shadows.enabled then
                    gain( 5, "combo_points" )
                    applyBuff( "deathly_shadows" )
                end

                if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
            end,
        },


        wound_poison = {
            id = 8679,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 134194,

            readyTime = function () return buff.lethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "wound_poison" )
            end,
        }


    } )


    -- Override this for rechecking.
    spec:RegisterAbility( "shadowmeld", {
        id = 58984,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        usable = function () return boss and group end,
        handler = function ()
            applyBuff( "shadowmeld" )
        end,
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "potion_of_unbridled_fury",

        package = "Subtlety",
    } )


    spec:RegisterSetting( "mfd_waste", true, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If unchecked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
        width = "full"
    } )  


    spec:RegisterPack( "Subtlety", 20200915, [[daf3VbqiOQ6rIG2Kc8jiHsgfKkNcs0QGQsVcszwOkULiQSlr9lfKHPq1XGKwMi0ZqvvtteLRHQkBtbL(MiaJtbvoNckSofuK5Pq5EGyFKk(NiqrhueOAHIipuevnribxueO0gHeYhfbkmsiHsDsrazLGuVubfvntfuuUjKqv7KuPFcjuzOqQQwQiqEketfvLRQGQARqcfFvbv5SkOOYEj8xbdwLdtzXq5XcnzIUmYMv0NHkJguNwPvlcOEniz2KCBsz3a)wvdxKooKQYYr55snDQUoQSDuL(oPQXdPkNxHSEOQy(qv2VKfOk4tGinNe6M44jo(4ddu5xg1HJFjGKLaei(OusGKArOmCKabyAKabHdZvKpsGKAJuVjf8jq6NJfjbcS7P9W0qdHBDyoSC81gQxnoL57dImB6d1RwCibcg3Q8eiGatGinNe6M44jo(4ddu5xg1HJFjGKXFbIX5WptGGSAjVabELsciWeisQJcKewhchMRiFuDjOhhhvqNW6qOuN0WiwDOYpEQlXXtCCbIABVf8jqANmLdtsbFcDrvWNaHagMIKIKeir26eBnbIVAuDJvhQcel67deiTY4Wb7et4cDtuWNaHagMIKIKeir26eBnbc6QdJBoZTtMYHZCP1HhE1HXnNzEnW2WzU06qPaXI((absdBYxF7Sfks4cD5VGpbcbmmfjfjjqIS1j2AcemU5m3WCSfkce8Nbm5N5sRBqDXxd7dP)c8olP5gxVUXGuxIcel67deirtPcw03heuB7ce12EayAKazUGTHfUq3Kj4tGqadtrsrscKiBDITMaPtjLk4gdh5DUH5yluei0(Z0QdsDjRUb1fFnSpK(lW760bsDjtGyrFFGajAkvWI((GGABxGO22datJeiZfSnSWf6YpbFcecyykskssGezRtS1eiXxd7dP)c8olP5gxVUXGuhQ1LC1HU6CtrapljkLyH2zMB4iTmbmmfjRBqDORomU5mZRb2goZLwhE4vNHpeBDk7WuyUS2dsdePmbmmfjRBqDDkPub3y4iVZnmhBHIaH2FMwDJvh)RdL1HsbIf99bcKOPubl67dcQTDbIABpamnsGmxW2WcxO7Wk4tGqadtrsrscel67deinSjF9TZwOibsKToXwtG4MIaEUPiJ8GtryWI(4OmbmmfjRBqDscJBoZZfid6jdka1DMrA2c66gRouRBqDDkPub3y4iVZnmhBHIaH2FMwDqQlX6guNBmCKN9vJc(hKlvxYvhJ0Sf01PtDdRajokQOGBmCK3cDrv4cDtac(eieWWuKuKKajYwNyRjqWFDUPiGNLeLsSq7mZnCKwMagMIK1nOodFi26ugtzskSGGdtHg2KV(oZmau1bPo(x3G66usPcUXWrENByo2cfbcT)mT6Guh)fiw03hiqAyt(6BNTqrcxO7Wj4tGqadtrsrscKiBDITMaHxJTgMIYCnfsz7ZwFuG9U57dQBqDORojHXnN55cKb9KbfG6oZinBbDDJvhQ1HhE15MIaEwpzPpqZANyzcyyksw3G66usPcUXWrENByo2cfbcT)mT6gdsDjRo8WRodFi26uEbeVRByRA9rzcyyksw3G6W4MZCpsd7vD4NbjzoCMlTUb11PKsfCJHJ8o3WCSfkceA)zA1ngK64FDOvNHpeBDkJPmjfwqWHPqdBYxFNjGHPizDOuGyrFFGaPHn5RVD2cfjCHUddbFcecyykskssGezRtS1eiDkPub3y4iVRthi1XFbIf99bcKgMJTqrGq7ptt4cDrDCbFcecyykskssGezRtS1eiscJBoZZfid6jdka1DMrA2c66gdsDOwhE4vx8FL81dY9inSx1HFgKK5WzgPzlORBS6qD4QBqDscJBoZZfid6jdka1DMrA2c66gRU4)k5RhK7rAyVQd)mijZHZmsZwqlqSOVpqG0WM813oBHIeUqxurvWNaHagMIKIKeiZNfae65cDrvGyrFFGaj9FvGr9ZXIKWf6IAIc(eieWWuKuKKajYwNyRjqWFDmoanFgokBqzgB7q)CQWKz40iGNj0h3MMsY6gux8bsU1ZTY4Wb7el0rJ1zcyyksw3G6IpqYTEUvghoyNyHoASoZmau1PdK6qTo0QZnfb8SEYsFGM1oXYeWWuKuGyrFFGaPvghoyNycxOlQ8xWNaHagMIKIKeir26eBnbc(RJXbO5ZWrzdkZyBh6NtfMmdNgb8mH(420usw3G6qxDg(qS1PCkXMpZCkZmau1PdK6sSUb11PKsfCJHJ8o3WCSfkceA)zA1ngK6sSo8WRomU5mNsS5ZmNKbEPf052Tiu1PdK64FDdQl(aj365uInFM5KmWlTGoZmau1PdK6qxD8VUKRU4dKCRNLeLsSG0WHJyDMagMIK1HV1LyDOSoukqSOVpqGGt9VgMYKKWf6IAYe8jqiGHPiPijbsKToXwtGG)6yCaA(mCu2GYm22H(5uHjZWPraptOpUnnLK1nOomU5mNsS5ZmNKbEPf052Tiu1PdK64FDdQl(aj365uInFM5KmWlTGoZmau1PdK6gU6sU6CtrapRNS0hOzTtSmbmmfjRdFRlrbIf99bcemlcv7gMWf6Ik)e8jqSOVpqG0WM813oBHIeieWWuKuKKWfUaH6MarQf8j0fvbFcecyykskssGezRtS1eieGy4gL9vJc(h0m0RoDQd16guh(RdJBoZ9inSx1HFgKK5WzU06guh6Qd)1jFphFqKaoZCsgMktJcyCmq23iulaxDdQd)1zrFFqo(GibCM5KmmvMgLxqyQwCWED4HxDtoLkWOiSXWrbF1O6gRoCrzwZqV6qPaXI((abs8brc4mZjzyQmns4cDtuWNaHagMIKIKeir26eBnbc(Rl(Vs(6b5g2KV(aMYKuN5sRBqDX)vYxpi3J0WEvh(zqsMdN5sRdp8QBU4G9aJ0Sf01ngK6qDCbIf99bcem1)YWpdomfiaPns4cD5VGpbIf99bceCCgtUgi8ZGHpe7DybcbmmfjfjjCHUjtWNaHagMIKIKeir26eBnbc6QRtjLk4gdh5DUH5yluei0(Z0Qthi1LyD4HxDmBLbIxc4ztk78cQtN6g2XRdL1nOo8xx8FL81dY9inSx1HFgKK5WzU06guh(RdJBoZ9inSx1HFgKK5WzU06guhbigUrzjn3461PdK64)4cel67deiZpY1Kmy4dXwNcyKPjCHU8tWNaHagMIKIKeir26eBnbsNskvWngoY7CdZXwOiqO9NPvNoqQlX6WdV6y2kdeVeWZMu25fuNo1nSJlqSOVpqGKYX25OfGlGPS2fUq3HvWNaHagMIKIKeir26eBnbcg3CMzuekf1Dy(SiL5sRdp8QdJBoZmkcLI6omFwKcXNd4el3UfHQUXQd1Xfiw03hiqCykWbWEoGmmFwKeUq3eGGpbIf99bce2MMQOWccDQfjbcbmmfjfjjCHUdNGpbcbmmfjfjjqIS1j2AcK4)k5RhK7rAyVQd)mijZHZmsZwqx3y1XV6WdV6MloypWinBbDDJvhQdNaXI((abI(NPK8sliWO(bgiscxO7WqWNaHagMIKIKeir26eBnbcbigUr1nwDjB86guhg3CM7rAyVQd)mijZHZCPcel67deiAK2Zgf(zqXfxzqYitRfUqxuhxWNaHagMIKIKeir26eBnbYCXb7bgPzlORBS6qnZV6WdV6qxDORo3y4ipdtMYHZPrVoDQB4gVo8WRo3y4ipdtMYHZPrVUXGuxIJxhkRBqDORol6lVuGaK2sDDqQd16WdV6MloypWinBbDD6uxIdJ6qzDOSo8WRo0vNBmCKN9vJc(hsJEiXXRtN64)41nOo0vNf9LxkqasBPUoi1HAD4HxDZfhShyKMTGUoDQlzjRouwhkfiw03hiqyKLUaCHPY0Ow4cxGiPPXPCbFcDrvWNaXI((abcuBekbcbmmfjfjjCHUjk4tGyrFFGaPDYuoSaHagMIKIKeUqx(l4tGqadtrsrscel67deirtPcw03heuB7ce12EayAKajkBHl0nzc(eieWWuKuKKajYwNyRjqANmLdtYSPucel67deimoqWI((GGABxGO22datJeiTtMYHjPWf6YpbFcecyykskssGezRtS1eiZfhShyKMTGUoDQByRBqDyCZzUvBKcgqgKBKYmsZwqx3y1HlkZAg6v3G6IVg2hs)f4DD6aPUKvxYvh6QZxnQUXQd1XRdL1HV1LOaXI((absR2ifmGmi3ijCHUdRGpbcbmmfjfjjq(ubstUaXI((abcVgBnmfjq41uCKajLTpB9rb27MVpOUb11PKsfCJHJ8o3WCSfkceA)zA1PdK6suGWRXcatJeiCnfsz7ZwFuG9U57deUq3eGGpbcbmmfjfjjqIS1j2AceEn2AykkZ1uiLTpB9rb27MVpqGyrFFGajAkvWI((GGABxGO22datJeiTtMYHdrzlCHUdNGpbcbmmfjfjjq(ubstUaXI((abcVgBnmfjq41uCKajr(vhA15MIaEM3f3ZYeWWuKSo8TUehVo0QZnfb8SM1oXc)m0WM813zcyykswh(wxIJxhA15MIaEUHn5Rpm)ixNjGHPizD4BDjYV6qRo3ueWZMYIS1hLjGHPizD4BDjoEDOvxI8Ro8To0vxNskvWngoY7CdZXwOiqO9NPvNoqQlz1HsbcVglamnsG0ozkho4WmQHFLu4cDhgc(eieWWuKuKKa5tfin5cel67dei8AS1WuKaHxtXrcKehVo0QZnfb8mVlUNLjGHPizD4BD8Ro0QZnfb8SM1oXc)m0WM813zcyykswh(wh)QdT6Ctrap3WM81hMFKRZeWWuKSo8TouhVo0QZnfb8SPSiB9rzcyykswh(wxIJxhA1X)XRdFRdD11PKsfCJHJ8o3WCSfkceA)zA1PdK64FDOuGezRtS1eiXhi5wp3kJdhStSqhnwNjGHPizDdQl(aj365wzC4GDIf6OX6mZaqvNoqQd16qRo3ueWZ6jl9bAw7eltadtrsbcVglamnsG0ozkho4WmQHFLu4cDrDCbFcecyykskssGezRtS1eieGy4gLL0CJRx3yqQJxJTgMIYTtMYHdomJA4xjfiw03hiqIMsfSOVpiO22fiQT9aW0ibs7KPC4qu2cxOlQOk4tGqadtrsrscKiBDITMaj(AyFi9xG31bPodSAwe2y4iziMkqSOVpqGenLkyrFFqqTTlquB7bGPrcK5c2gw4cDrnrbFcecyykskssGezRtS1eiXxd7dP)c8olP5gxVUXGuhQ1HhE15gdh5zF1OG)b5s1ngK6qTUb1fFnSpK(lW760bsD8xGyrFFGajAkvWI((GGABxGO22datJeiZfSnSWf6Ik)f8jqiGHPiPijbsKToXwtG0PKsfCJHJ8o3WCSfkceA)zA1bPUKv3G6IVg2hs)f4DD6aPUKjqSOVpqGenLkyrFFqqTTlquB7bGPrcK5c2gw4cDrnzc(eieWWuKuKKajYwNyRjqiaXWnklP5gxVUXGuhVgBnmfLBNmLdhCyg1WVskqSOVpqGenLkyrFFqqTTlquB7bGPrcemUvjfUqxu5NGpbcbmmfjfjjqIS1j2AcecqmCJYsAUX1Rthi1Hk)QdT6iaXWnkZiCeqGyrFFGaXyrdqb)zmc4cxOlQdRGpbIf99bceJfnafs5unjqiGHPiPijHl0f1eGGpbIf99bce1Id27qcmNeNgbCbcbmmfjfjjCHUOoCc(eiw03hiqWmCHFgC2gHQfieWWuKuKKWfUajLrXxdZCbFcDrvWNaXI((abILMQgfs)TFGaHagMIKIKeUq3ef8jqiGHPiPijHl0L)c(eieWWuKuKKWf6MmbFcecyykskss4cD5NGpbcbmmfjfjjCHUdRGpbIf99bcK2jt5Wcecyykskss4cDtac(eieWWuKuKKaXI((abIMXGIKH5ZcsYCybskJIVgM5HMIpq2ceu5NWf6oCc(eieWWuKuKKaXI((absR2ifmGmi3ijqszu81Wmp0u8bYwGKOWf6ome8jqiGHPiPijbIf99bcKg2KV(aMYKulqszu81Wmp0u8bYwGGQWf6I64c(eiw03hiqsFFFGaHagMIKIKeUqxurvWNaHagMIKIKeiatJeig(0WgZ6W8bE4NH0xpXeiw03hiqm8PHnM1H5d8WpdPVEIjCHlqW4wLuWNqxuf8jqiGHPiPijbsKToXwtG0PKsfCJHJ8UoDGuxI1HwDORo3ueWZ4u)RHPmjLjGHPizDdQZWhIToLtj28zMtzMbGQoDGuxI1HsbIf99bcKgMJTqrGq7ptt4cDtuWNaHagMIKIKeir26eBnbs8FL81dYnXyMtYa2dOqNUqr5iSXWrDyYSOVpWu1PdK6smNa4NaXI((abstmM5KmG9ak0PluKWf6YFbFcel67deiue(xaUaJszRMbKcecyykskss4cDtMGpbIf99bceCQ)1WuMKeieWWuKuKKWf6YpbFcel67deiyweQ2nmbcbmmfjfjjCHlqIYwWNqxuf8jqiGHPiPijbsKToXwtGG)6W4MZCdBYxFqAGiL5sRBqDyCZzUH5yluei4pdyYpZLw3G6W4MZCdZXwOiqWFgWKFMrA2c66gdsD8pZpbIf99bcKg2KV(G0arsGW1u4NZaUOuOlQcxOBIc(eieWWuKuKKajYwNyRjqW4MZCdZXwOiqWFgWKFMlTUb1HXnN5gMJTqrGG)mGj)mJ0Sf01ngK64FMFcel67dei9inSx1HFgKK5WceUMc)CgWfLcDrv4cD5VGpbcbmmfjfjjqIS1j2Ace0vhJdqZNHJYAgdQWpdomf0S2jwW626Ebzc9XTPPKSo8WRoghGMpdhLLK5WQrHg2KV(otOpUnnLK1HY6guhg3CM7rAyVQd)mijZHZCP1nOomU5m3WM81hKgiszU06guNM1oXcw3w3liWinBbDDqQB86guhg3CMLK5WQrHg2KV(olF9abIf99bceEnW2WcxOBYe8jqiGHPiPijbsKToXwtGG)6ANmLdtYSPu1nOomU5m3QnsbdidYnszU06WdV6OUjqKYymYC4WpdomfKJwaUSMLa)S6guNVAuD6aPUefiw03hiqIMsfSOVpiO22fiQT9aW0ibc1nbIulCHU8tWNaHagMIKIKeiw03hiqs)xfyu)CSijqIS1j2Ace8xNBkc45g2KV(W8JCDMagMIKcK5Zcac9CHUOkCHUdRGpbcbmmfjfjjqIS1j2AcecqmCJQthi1nSJx3G6W4MZCR2ifmGmi3iL5sRBqDX)vYxpi3J0WEvh(zqsMdN5sRBqDX)vYxpi3WM81hKgis5iSXWrDD6aPoufiw03hiqAyo2cfbc(ZaM8fUq3eGGpbcbmmfjfjjqSOVpqG0eJzojdypGcD6cfjqIS1j2AcemU5m3QnsbdidYnszU06guh(Rt(EUjgZCsgWEaf60fkkiFp7BeQfGRo8WRU5Id2dmsZwqx3yqQJFcK4OOIcUXWrEl0fvHl0D4e8jqiGHPiPijbsKToXwtGGXnN5wTrkyazqUrkZLw3G6WFDX)vYxpi3WM81hWuMK6mxADdQdD15MIaEMa8sQpDb4cnSjF9DMagMIK1HhE1f)xjF9GCdBYxFqAGiLJWgdh11PdK6qTouw3G6qxD4Vo3ueWZnmhBHIab)zat(zcyykswhE4vNBkc45g2KV(W8JCDMagMIK1HhE1f)xjF9GCdZXwOiqWFgWKFMrA2c660PUeRdL1nOo0vh(RJ6MarkJP(xg(zWHPabiTrznlb(z1HhE1f)xjF9GmM6Fz4NbhMceG0gLzKMTGUoDQlX6qPaXI((abspsd7vD4NbjzoSWf6ome8jqiGHPiPijbIf99bcenJbfjdZNfKK5WcKiBDITMaHzRmq8sapBszN5sRBqDORo3y4ip7Rgf8pixQUXQl(AyFi9xG3zjn3461HhE1H)6ANmLdtYSPu1nOU4RH9H0FbENL0CJRxNoqQlMg0m0l0PeqwhkfiXrrffCJHJ8wOlQcxOlQJl4tGqadtrsrscKiBDITMaHzRmq8sapBszNxqD6uh)hVUKRoMTYaXlb8SjLDwYXmFFqDdQd)11ozkhMKztPQBqDXxd7dP)c8olP5gxVoDGuxmnOzOxOtjGuGyrFFGarZyqrYW8zbjzoSWf6IkQc(eieWWuKuKKajYwNyRjqWFDTtMYHjz2uQ6guhg3CMB1gPGbKb5gPmxADdQl(AyFi9xG3zjn3461PdK6suGyrFFGaPHn5RpGPmj1cxOlQjk4tGqadtrsrscKiBDITMaXnfb8CdBYxFy(rUotadtrY6guhg3CMB1gPGbKb5gPmxADdQdJBoZ9inSx1HFgKK5WzUubIf99bcKgMJTqrGG)mGjFHl0fv(l4tGqadtrsrscKiBDITMab)1HXnN5g2KV(G0arkZLw3G6MloypWinBbDDJbPo(vhA15MIaEU5WCIn5Wrzcyyksw3G6WFDmBLbIxc4ztk7mxQaXI((absdBYxFqAGijCHUOMmbFcecyykskssGezRtS1eiyCZzgt9VuX1EMrw0Rdp8QdJBoZ9inSx1HFgKK5WzU06guh6QdJBoZnSjF9bmLjPoZLwhE4vx8FL81dYnSjF9bmLjPoZinBbDDJbPouhVoukqSOVpqGK(((aHl0fv(j4tGqadtrsrscKiBDITMabJBoZ9inSx1HFgKK5WzUubIf99bcem1)YWKJns4cDrDyf8jqiGHPiPijbsKToXwtGGXnN5EKg2R6WpdsYC4mxQaXI((abcgXAIb1cWjCHUOMae8jqiGHPiPijbsKToXwtGGXnN5EKg2R6WpdsYC4mxQaXI((abYCzeM6FPWf6I6Wj4tGqadtrsrscKiBDITMabJBoZ9inSx1HFgKK5WzUubIf99bcedeP2zMkenLs4cDrDyi4tGqadtrsrscel67deiXrr17ShSXaMYAxGezRtS1ei4VU2jt5WKmBkvDdQdJBoZTAJuWaYGCJuMlTUb1H)6W4MZCpsd7vD4NbjzoCMlTUb1raIHBuwsZnUED6aPo(pUaHMtk6bGPrcK4OO6D2d2yatzTlCHUjoUGpbcbmmfjfjjqSOVpqGy4tdBmRdZh4HFgsF9etGezRtS1ei4VomU5m3WM81hKgiszU06gux8FL81dY9inSx1HFgKK5WzgPzlORBS6qDCbcW0ibIHpnSXSomFGh(zi91tmHl0nruf8jqiGHPiPijbIf99bceRH51auhyg(8Sq8zMsGezRtS1eiscJBoZmdFEwi(mtfKeg3CMLVEqD4HxDscJBoZXhi5I(YlfwaubjHXnNzU06guNBmCKNHjt5W50Ox3y1X)eRBqDUXWrEgMmLdNtJED6aPo(pED4HxD4VojHXnN54dKCrF5LclaQGKW4MZmxADdQdD1jjmU5mZm85zH4ZmvqsyCZzUDlcvD6aPUe5xDjxDOoED4BDscJBoZyQ)LHFgCykqasBuMlTo8WRU5Id2dmsZwqx3y1LSXRdL1nOomU5m3J0WEvh(zqsMdNzKMTGUoDQB4eiatJeiwdZRbOoWm85zH4ZmLWf6MyIc(eieWWuKuKKabyAKarBK06GBQT1mGaXI((abI2iP1b3uBRzaHl0nr(l4tGqadtrsrscKiBDITMabJBoZ9inSx1HFgKK5WzU06WdV6MloypWinBbDDJvxIJlqSOVpqGW1uyDsRfUWfiTtMYHdrzl4tOlQc(eieWWuKuKKa5tfin5cel67dei8AS1WuKaHxtXrcK4)k5RhKByt(6dsdePCe2y4Oomzw03hyQ60bsDOMta8tGWRXcatJeinSm4WmQHFLu4cDtuWNaHagMIKIKeir26eBnbc(RJxJTgMIYnSm4WmQHFLSUb1fFnSpK(lW7SKMBC960Poufiw03hiq41aBdlCHU8xWNaHagMIKIKeir26eBnbc(RJxJTgMIYnSm4WmQHFLuGyrFFGaPP0EBHl0nzc(eieWWuKuKKaXI((abs6)QaJ6NJfjbcHEoZcM2ZbCbsYgxGmFwaqONl0fvHl0LFc(eieWWuKuKKajYwNyRjqiaXWnQoDGuxYgVUb1raIHBuwsZnUED6aPouhVUb1H)641yRHPOCdldomJA4xjRBqDXxd7dP)c8olP5gxVoDQd16guNKW4MZ8CbYGEYGcqDNzKMTGUUXQdvbIf99bcKg2KVEnsjfUq3HvWNaHagMIKIKeiFQaPjxGyrFFGaHxJTgMIei8AkosGeFnSpK(lW7SKMBC960bsDjRUKRo0vNBkc4zjrPel0oZCdhPLjGHPizDdQdD1z4dXwNYomfMlR9G0arktadtrY6guh(RZnfb8S0yqfAyt(6ZeWWuKSUb1H)6Ctrap3CyoXMC4OmbmmfjRBqDDkPub3y4iVZnmhBHIaH2FMwDJvh)RdL1HsbcVglamnsG0WYq81W(q6VaVfUq3eGGpbcbmmfjfjjq(ubstUaXI((abcVgBnmfjq41uCKaj(AyFi9xG3zjn3461ngK6qTo0QlX6W36m8HyRtzhMcZL1EqAGiLjGHPiPajYwNyRjq41yRHPOmxtHu2(S1hfyVB((G6guh6QZnfb8myXb7TBkOiwMagMIK1HhE15MIaEwAmOcnSjF9zcyykswhkfi8ASaW0ibsdldXxd7dP)c8w4cDhobFcecyykskssGezRtS1ei8AS1WuuUHLH4RH9H0FbEx3G6qxD8AS1WuuUHLbhMrn8RK1HhE1HXnN5EKg2R6WpdsYC4mJ0Sf01PdK6qnNyD4HxDDkPub3y4iVZnmhBHIaH2FMwD6aPUKv3G6I)RKVEqUhPH9Qo8ZGKmhoZinBbDD6uhQJxhkfiw03hiqAyt(6dsdejHl0Dyi4tGqadtrsrscKiBDITMaHxJTgMIYnSmeFnSpK(lW76gu3CXb7bgPzlORBS6I)RKVEqUhPH9Qo8ZGKmhoZinBbDDdQd)1XSvgiEjGNnPSZCPcel67deinSjF9bPbIKWfUazUGTHf8j0fvbFcecyykskssGmFwaqONl0fvbIf99bcK0)vbg1phlscxOBIc(eieWWuKuKKajYwNyRjqW4MZCR2ifmGmi3iLzKMTGUUXQBU4G9aJ0Sf01nOomU5m3QnsbdidYnszgPzlORBS6qxDOwhA1fFnSpK(lW76qzD4BDOMhobIf99bcKwTrkyazqUrs4cD5VGpbcbmmfjfjjqIS1j2Ace3y4ip7Rgf8pixQUKRogPzlORtN6g26guhJMmQHnmfjqSOVpqGW4sDogjCHUjtWNaHagMIKIKeiw03hiqyCPohJeir26eBnbc(RJxJTgMIYCnfsz7ZwFuG9U57dQBqDDkPub3y4iVZnmhBHIaH2FMwD6aPUeRBqDUXWrE2xnk4FqUuD6aPo0vh)QdT6qxDjwh(wx81W(q6VaVRdL1HY6guhJMmQHnmfjqIJIkk4gdh5TqxufUqx(j4tGqadtrsrscKiBDITMaHrA2c66gRU4)k5RhK7rAyVQd)mijZHZmsZwqxhA1H641nOU4)k5RhK7rAyVQd)mijZHZmsZwqx3yqQJF1nOo3y4ip7Rgf8pixQUKRogPzlORtN6I)RKVEqUhPH9Qo8ZGKmhoZinBbDDOvh)eiw03hiqyCPohJeUq3HvWNaXI((abstrg5bNIWGf9Xrcecyykskss4cDtac(eiw03hiqiE3osmZjbcbmmfjfjjCHlCbcVeR3hi0nXXtC8XhgOoUarVXalaxlqsG0sFMtY6gU6SOVpOo12ENlOfiPSFUksGKW6q4WCf5JQlb944Oc6ewhcL6KggXQdv(XtDjoEIJxqxqNW6sWIEuKZjzDy08zuDXxdZ86WiClOZ1LGhJuQ31bEqYbBmTjNQol67d66EGAuUG2I((GoNYO4RHzoelnvnkK(B)GcAl67d6CkJIVgM5ObzOPYAOkOTOVpOZPmk(AyMJgKHmoCAeWnFFqbTf99bDoLrXxdZC0Gm08FzbDcRdbyPn871XSvwhg3CsY6A38UomA(mQU4RHzEDyeUf01zazDPmk5sF3xaU62Uo5dOCbTf99bDoLrXxdZC0GmudS0g(9q7M3f0w03h05ugfFnmZrdYqTtMYHlOTOVpOZPmk(AyMJgKH0mguKmmFwqsMdZtkJIVgM5HMIpq2qqLFf0w03h05ugfFnmZrdYqTAJuWaYGCJepPmk(AyMhAk(azdjXcAl67d6CkJIVgM5ObzOg2KV(aMYKuZtkJIVgM5HMIpq2qqTG2I((GoNYO4RHzoAqgk999bf0w03h05ugfFnmZrdYqCnfwN04byAeedFAyJzDy(ap8Zq6RNyf0f0jSUeSOhf5CswhXlXgvNVAuDomvNf9Nv321z8ARYWuuUG2I((GgcuBeQc6ewxcIANmLdx3oRl97EXuuDOd81XlNcqmdtr1rasBPUUfux81WmhLf0w03h0ObzO2jt5Wf0jSUKhMIqvxYJcDDMx3CzTxqBrFFqJgKHIMsfSOVpiO225byAeKOSlOtyDjioqDtoLAuDT(1JWuxN)15WuDiozkhMK1LGE389b1HoSr1j)fGRU(5PU1RB(Si11L(VAb4QBN1bEhEb4QB76mETvzykcL5cAl67dA0GmeJdeSOVpiO225byAeK2jt5WKKNDcPDYuomjZMsvqNW6sWttvJQdrTrQodiRdf2ivN51LiA1L8O)6KCSfGRohMQBUS2Rd1XRRP4dKnp1ztNy15WMxxYqRUKh9x3oRB96i0lDzuxN(1HxqDomvhGqpVUemsEuOUNv321bEVoU0cAl67dA0GmuR2ifmGmi3iXZoHmxCWEGrA2cADg2byCZzUvBKcgqgKBKYmsZwqpgUOmRzO3G4RH9H0FbERdKKLCOZxnAmuhhL4BIf0jSouCa1O6IWgahvh7DZ3hu3oRtpvhSXlvxkBF26JcS3nFFqDn51zazDACkFtvuDUXWrExhxAUG2I((GgnidXRXwdtr8amnccxtHu2(S1hfyVB((aE41uCeKu2(S1hfyVB((GbDkPub3y4iVZnmhBHIaH2FMMoqsSGoH1H(z7ZwFuDjO3nFFqcM1nmJCuS66WT8s1z1fzwADg2Z51raIHBuDZNvNdt11ozkhUUKhf66qhg3QKeRU2xLQog1Pu0RBDuMRByoUuEQB96IgOomQoh2866vlvr5cAl67dA0Gmu0uQGf99bb12opatJG0ozkhoeLnp7ecVgBnmfL5AkKY2NT(Oa7DZ3huqNW6g(njRZ)6K0CbuD6HjqD(xhxt11ozkhUUKhf66EwDyCRssSUG2I((GgnidXRXwdtr8amncs7KPC4GdZOg(vsE41uCeKe5hAUPiGN5DX9SmbmmfjX3ehhn3ueWZAw7el8ZqdBYxFNjGHPij(M44O5MIaEUHn5Rpm)ixNjGHPij(Mi)qZnfb8SPSiB9rzcyyksIVjooAjYp8fDDkPub3y4iVZnmhBHIaH2FMMoqsgklOtyDjissZfq1nFwDikJdhStS6iaXWnQG2I((GgnidXRXwdtr8amncs7KPC4GdZOg(vsE(uin58StiXhi5wp3kJdhStSqhnwNjGHPi5G4dKCRNBLXHd2jwOJgRZmdaLoqqfn3ueWZ6jl9bAw7eltadtrsE41uCeKehhn3ueWZ8U4EwMagMIK4l)qZnfb8SM1oXc)m0WM813zcyyksIV8dn3ueWZnSjF9H5h56mbmmfjXxuhhn3ueWZMYIS1hLjGHPij(M44OX)XXx01PKsfCJHJ8o3WCSfkceA)zA6aH)OSGoH1L8pOxjXQJRxaU6S6qCYuoCDjpkuNEycuhJSi8cWvNdt1raIHBuDomJA4xjlOTOVpOrdYqrtPcw03heuB78amncs7KPC4qu28StieGy4gLL0CJRpgeEn2Aykk3ozkho4WmQHFLSG2I((GgnidfnLkyrFFqqTTZdW0iiZfSnmp7es81W(q6VaVHyGvZIWgdhjdX0c6ewhkAbBdxN51Lm0Qt)6WpNxhkGWtD8dT60VoCDOasDO758ELuDTtMYHrzbTf99bnAqgkAkvWI((GGABNhGPrqMlyByE2jK4RH9H0FbENL0CJRpgeuXdp3y4ip7Rgf8pixAmiOoi(AyFi9xG36aH)f0jSUH36W1Hci1zQ(RBUGTHRZ86sgA1z4Sf0EDe6zrxnQUKvNBmCK31HUNZ7vs11ozkhgLf0w03h0ObzOOPubl67dcQTDEaMgbzUGTH5zNq6usPcUXWrENByo2cfbcT)mnijBq81W(q6VaV1bsYkOtyDd)MQZQdJBvsIvNEycuhJSi8cWvNdt1raIHBuDomJA4xjlOTOVpOrdYqrtPcw03heuB78amnccg3QK8StieGy4gLL0CJRpgeEn2Aykk3ozkho4WmQHFLSGoH1nm71tTxxkBF26JQBb1zkvD)SohMQlbh9pmRomkACnv361fnUM66S6sWi5rHcAl67dA0GmKXIgGc(ZyeW5zNqiaXWnklP5gxxhiOYp0iaXWnkZiCeOG2I((GgnidzSObOqkNQPcAl67dA0GmKAXb7DibMtItJaEbTf99bnAqgcZWf(zWzBeQUGUGoH1Le3QKeRlOTOVpOZyCRscPH5yluei0(Z04zNq6usPcUXWrERdKerdDUPiGNXP(xdtzsktadtrYbg(qS1PCkXMpZCkZmau6ajruwqBrFFqNX4wLenid1eJzojdypGcD6cfXZoHe)xjF9GCtmM5KmG9ak0PluuocBmCuhMml67dmLoqsmNa4xbTf99bDgJBvs0GmefH)fGlWOu2QzazbTf99bDgJBvs0Gmeo1)Ayktsf0w03h0zmUvjrdYqyweQ2nSc6c6ewxY)Vs(6bDbDcRB43uDOGbIuD)CMC4IY6WO5ZO6CyQU5YAVoeyo2cfbQdXFMwDt2RvhFpdyYVU4RrDDlixqBrFFqNJYgsdBYxFqAGiXdxtHFod4IsiOYZoHGFmU5m3WM81hKgiszU0byCZzUH5yluei4pdyYpZLoaJBoZnmhBHIab)zat(zgPzlOhdc)Z8RGoH1HUHpqrDxNPyKjhvhxADyu04AQo9uD()qvhcSjF91HI(ixJY64AQoKrAyVQR7NZKdxuwhgnFgvNdt1nxw71HaZXwOiqDi(Z0QBYET647zat(1fFnQRBb5cAl67d6Cu2ObzOEKg2R6WpdsYCyE4Ak8ZzaxucbvE2jemU5m3WCSfkce8Nbm5N5shGXnN5gMJTqrGG)mGj)mJ0Sf0JbH)z(vqBrFFqNJYgnidXRb2gMNDcbDmoanFgokRzmOc)m4WuqZANybRBR7fKj0h3MMss8WJXbO5ZWrzjzoSAuOHn5RVZe6JBttjjkhGXnN5EKg2R6WpdsYC4mx6amU5m3WM81hKgiszU0bAw7elyDBDVGaJ0Sf0qgFag3CMLK5WQrHg2KV(olF9GcAl67d6Cu2ObzOOPubl67dcQTDEaMgbH6MarQ5zNqWF7KPCysMnLAag3CMB1gPGbKb5gPmxkE4rDtGiLXyK5WHFgCykihTaCznlb(zd8vJ0bsIf0jSo0))Q6MpRo(EgWKFDPmk5qEuOo9RdxhcmkuhJm5O60dtG6aVxhJdawaU6qqr5cAl67d6Cu2ObzO0)vbg1phls8mFwaqONdbvE2je87MIaEUHn5Rpm)ixNjGHPizbDcRB43uD89mGj)6szuDipkuNEycuNEQoyJxQohMQJaed3O60dtomXQBYET6s)xTaC1PFD4NZRdbfv3ZQlbMR96WraIzk1OCbTf99bDokB0GmudZXwOiqWFgWKpp7ecbigUr6azyhFag3CMB1gPGbKb5gPmx6G4)k5RhK7rAyVQd)mijZHZCPdI)RKVEqUHn5RpinqKYryJHJADGGAbTf99bDokB0GmutmM5KmG9ak0PluepXrrffCJHJ8gcQ8StiyCZzUvBKcgqgKBKYCPdWV89CtmM5KmG9ak0Pluuq(E23iulahE4nxCWEGrA2c6XGWVc6ew3WVP6qgPH9QUUhux8FL81dQdD20jwDZL1EDiauaL1Xbuu31PNQZyuD4(fGRo)Rl9tRJVNbm5xNbK1j)6aVxhSXlvhcSjF91HI(ixNlOTOVpOZrzJgKH6rAyVQd)mijZH5zNqW4MZCR2ifmGmi3iL5shG)4)k5RhKByt(6dyktsDMlDa6CtraptaEj1NUaCHg2KV(otadtrs8Wl(Vs(6b5g2KV(G0arkhHngoQ1bcQOCa6WVBkc45gMJTqrGG)mGj)mbmmfjXdp3ueWZnSjF9H5h56mbmmfjXdV4)k5RhKByo2cfbc(ZaM8ZmsZwqRtIOCa6Wp1nbIugt9Vm8ZGdtbcqAJYAwc8ZWdV4)k5RhKXu)ld)m4WuGaK2OmJ0Sf06KiklOtyDjqZ6mPSRZyuDCP8uxd2uQohMQ7buD6xhUo1RNAVo(4dfY1n8BQo9WeOo5OfGRUP1oXQZHnqDjp6Vojn34619S6aVxx7KPCyswN(1HFoVodmQUKh9NlOTOVpOZrzJgKH0mguKmmFwqsMdZtCuurb3y4iVHGkp7ecZwzG4LaE2KYoZLoaDUXWrE2xnk4FqU0yXxd7dP)c8olP5gxhp8WF7KPCysMnLAq81W(q6VaVZsAUX11bsmnOzOxOtjGeLf0jSUeOzDGVotk760VkvDYLQt)6WlOohMQdqONxh)hV5PoUMQdf)efQ7b1H9DxN(1HFoVodmQUKh9xNbK1b(6ANmLdNlOTOVpOZrzJgKH0mguKmmFwqsMdZZoHWSvgiEjGNnPSZlqh(pEYXSvgiEjGNnPSZsoM57dgG)2jt5WKmBk1G4RH9H0FbENL0CJRRdKyAqZqVqNsazbTf99bDokB0GmudBYxFatzsQ5zNqWF7KPCysMnLAag3CMB1gPGbKb5gPmx6G4RH9H0FbENL0CJRRdKelOtyDdV1HRdbfXtD7SoW71zkgzYr1jFaXtDCnvhFpdyYVo9RdxhYJc1XLMlOTOVpOZrzJgKHAyo2cfbc(ZaM85zNqCtrap3WM81hMFKRZeWWuKCag3CMB1gPGbKb5gPmx6amU5m3J0WEvh(zqsMdN5slOTOVpOZrzJgKHAyt(6dsdejE2je8JXnN5g2KV(G0arkZLoyU4G9aJ0Sf0JbHFO5MIaEU5WCIn5Wrzcyyksoa)mBLbIxc4ztk7mxAbTf99bDokB0Gmu677d4zNqW4MZmM6FPIR9mJSOJhEyCZzUhPH9Qo8ZGKmhoZLoaDyCZzUHn5RpGPmj1zUu8Wl(Vs(6b5g2KV(aMYKuNzKMTGEmiOooklOTOVpOZrzJgKHWu)ldto2iE2jemU5m3J0WEvh(zqsMdN5slOTOVpOZrzJgKHWiwtmOwaoE2jemU5m3J0WEvh(zqsMdN5slOTOVpOZrzJgKHMlJWu)l5zNqW4MZCpsd7vD4NbjzoCMlTG2I((GohLnAqgYarQDMPcrtP4zNqW4MZCpsd7vD4NbjzoCMlTG2I((GohLnAqgIRPW6Kgp0CsrpamncsCuu9o7bBmGPS25zNqWF7KPCysMnLAag3CMB1gPGbKb5gPmx6a8JXnN5EKg2R6WpdsYC4mx6acqmCJYsAUX11bc)hVG2I((GohLnAqgIRPW6KgpatJGy4tdBmRdZh4HFgsF9eJNDcb)yCZzUHn5RpinqKYCPdI)RKVEqUhPH9Qo8ZGKmhoZinBb9yOoEbDcRdfdXgvh75WbRgvhJtr19Z6CyonSDUKSonZH76Wi1RFyQUHFt1nFwDjqaOsFzDr268u37Wet)2uD6xhUoKhfQZ86sKFOvx7weQUUNvhQ8dT60VoCDMQ)6ss9VSoU0CbTf99bDokB0GmextH1jnEaMgbXAyEna1bMHppleFMP4zNqKeg3CMzg(8Sq8zMkijmU5mlF9a8WtsyCZzo(ajx0xEPWcGkijmU5mZLoWngoYZWKPC4CA0hJ)joWngoYZWKPC4CA01bc)hhp8WVKW4MZC8bsUOV8sHfavqsyCZzMlDa6Keg3CMzg(8Sq8zMkijmU5m3UfHshijYVKd1XXxjHXnNzm1)YWpdomfiaPnkZLIhEZfhShyKMTGESKnokhGXnN5EKg2R6WpdsYC4mJ0Sf06mCf0w03h05OSrdYqCnfwN04byAeeTrsRdUP2wZaf0jSouGMgNYRBAkfMfHQU5ZQJRnmfv36Kwpmv3WVP60VoCDiJ0WEvx3pRdfiZHZf0w03h05OSrdYqCnfwN0AE2jemU5m3J0WEvh(zqsMdN5sXdV5Id2dmsZwqpwIJxqxqNW6sW2nbIuxqBrFFqNPUjqKAiXhejGZmNKHPY0iE2jecqmCJY(Qrb)dAg6PdQdWpg3CM7rAyVQd)mijZHZCPdqh(LVNJpisaNzojdtLPrbmogi7BeQfGBa(TOVpihFqKaoZCsgMktJYlimvloyhp8MCkvGrryJHJc(QrJHlkZAg6HYcAl67d6m1nbIuJgKHWu)ld)m4WuGaK2iE2je8h)xjF9GCdBYxFatzsQZCPdI)RKVEqUhPH9Qo8ZGKmhoZLIhEZfhShyKMTGEmiOoEbTf99bDM6MarQrdYq44mMCnq4NbdFi27Wf0w03h0zQBcePgnidn)ixtYGHpeBDkGrMgp7ec66usPcUXWrENByo2cfbcT)mnDGKiE4XSvgiEjGNnPSZlqNHDCuoa)X)vYxpi3J0WEvh(zqsMdN5shGFmU5m3J0WEvh(zqsMdN5shqaIHBuwsZnUUoq4)4f0w03h0zQBcePgnidLYX25OfGlGPS25zNq6usPcUXWrENByo2cfbcT)mnDGKiE4XSvgiEjGNnPSZlqNHD8cAl67d6m1nbIuJgKHCykWbWEoGmmFwK4zNqW4MZmJIqPOUdZNfPmxkE4HXnNzgfHsrDhMplsH4ZbCILB3IqngQJxqBrFFqNPUjqKA0GmeBttvuybHo1IubTf99bDM6MarQrdYq6FMsYlTGaJ6hyGiXZoHe)xjF9GCpsd7vD4NbjzoCMrA2c6X4hE4nxCWEGrA2c6XqD4kOTOVpOZu3eisnAqgsJ0E2OWpdkU4kdsgzAnp7ecbigUrJLSXhGXnN5EKg2R6WpdsYC4mxAbDcRdf7xjRlbrw6cWvhkszAux38z1rOhf5CQoMbWr19S6GAvQ6W4MZMN62zDPF3lMIY1LGR0BJ66C2O68VoCKxNdt1PE9u71f)xjF9G6WSMK19G6mETvzykQocqAl15cAl67d6m1nbIuJgKHyKLUaCHPY0OMNDczU4G9aJ0Sf0JHAMF4Hh6qNBmCKNHjt5W50ORZWnoE45gdh5zyYuoCon6JbjXXr5a0zrF5LceG0wQHGkE4nxCWEGrA2cADsCyGsuIhEOZngoYZ(Qrb)dPrpK446W)XhGol6lVuGaK2sneuXdV5Id2dmsZwqRtYsgkrzbDbDcRdfTGTHjwxqBrFFqNNlyByiP)RcmQFowK4z(SaGqphcQf0w03h055c2ggnid1QnsbdidYns8StiyCZzUvBKcgqgKBKYmsZwqp2CXb7bgPzlOhGXnN5wTrkyazqUrkZinBb9yOdv0IVg2hs)f4nkXxuZdxbDcRByEIsRJlTUeexQZXO62zDRx321zypNxN)1X4a19CEUG2I((GopxW2WObzigxQZXiE2je3y4ip7Rgf8pixk5yKMTGwNHDaJMmQHnmfvqNW6qXZP8v(UVaC15gdh5DDoS51PFvQ6ulVuDZNvNdt1j5yMVpOUFwxcIl15yep1XOjJA46KCSfGRUudijTnMlOTOVpOZZfSnmAqgIXL6CmIN4OOIcUXWrEdbvE2je8ZRXwdtrzUMcPS9zRpkWE389bd6usPcUXWrENByo2cfbcT)mnDGK4a3y4ip7Rgf8pixshiOJFOHUeX34RH9H0FbEJsuoGrtg1WgMIkOtyDjiAYOgUUeexQZXO6iJPgv3oRB960VkvDe6LUmQojhBb4QdzKg2R6CDOWxNdBEDmAYOgUUDwhYJc1HJ8UogzYr1TG6CyQoaHEED8RZf0w03h055c2ggnidX4sDogXZoHWinBb9yX)vYxpi3J0WEvh(zqsMdNzKMTGgnuhFq8FL81dY9inSx1HFgKK5WzgPzlOhdc)g4gdh5zF1OG)b5sjhJ0Sf06e)xjF9GCpsd7vD4NbjzoCMrA2cA04xbTf99bDEUGTHrdYqnfzKhCkcdw0hhvqBrFFqNNlyBy0GmeX72rIzovqxqNW6qCYuoCDj))k5Rh0f0jSouSjvkXQdfJXwdtrf0w03h052jt5WHOSHWRXwdtr8amncsdldomJA4xj5HxtXrqI)RKVEqUHn5RpinqKYryJHJ6WKzrFFGP0bcQ5ea)kOtyDOymW2W1Xbuu31PNQZyuDg2Z515FDrlTUhuhkyGivxe2y4OoxqBrFFqNBNmLdhIYgnidXRb2gMNDcb)8AS1WuuUHLbhMrn8RKdIVg2hs)f4DwsZnUUoOwqBrFFqNBNmLdhIYgnid1uAVnp7ec(51yRHPOCdldomJA4xjlOtyDO))v1nFwDiWM81RrkzDOvhcSjF9TZwOO64akQ760t1zmQod75868VUOLw3dQdfmqKQlcBmCuNRdfhqnQo9WeOou0cK1n8idka1DDBxNH9CED(xhJdu3Z55cAl67d6C7KPC4qu2ObzO0)vbg1phls8mFwaqONdbvEi0ZzwW0EoGdjzJxqBrFFqNBNmLdhIYgnid1WM81Rrkjp7ecbigUr6ajzJpGaed3OSKMBCDDGG64dWpVgBnmfLByzWHzud)k5G4RH9H0FbENL0CJRRdQdKeg3CMNlqg0tguaQ7mJ0Sf0JHAbDcRl5r)1Xi0h3Yinc4dt1Hcgis1zEDQxFDjp6VoSr1jPPXP8CDOdHdZzw03hu321z1f)0r1nzVwDomvx7KPGjzDZfSnmXQlAkvDZNvhFOiuOoydivlaxgLf0w03h052jt5WHOSrdYq8AS1WuepatJG0WYq81W(q6VaV5HxtXrqIVg2hs)f4DwsZnUUoqswYHo3ueWZsIsjwODM5gosltadtrYbOZWhIToLDykmxw7bPbIuMagMIKdWVBkc4zPXGk0WM81NjGHPi5a87MIaEU5WCIn5WrzcyyksoOtjLk4gdh5DUH5yluei0(Z0gJ)OeLf0jSUKh9xhJqFClJ0iGpmvhkyGiv3duJQdJMpJQBUGTHjwx3oRtpvhSXlvNPLwNBkc4DDgqwxkBF26JQJ9U57dYf0w03h052jt5WHOSrdYq8AS1WuepatJG0WYq81W(q6VaV5HxtXrqIVg2hs)f4DwsZnU(yqqfTeXxdFi26u2HPWCzThKgiszcyyksYZoHWRXwdtrzUMcPS9zRpkWE389bdqNBkc4zWId2B3uqrSmbmmfjXdp3ueWZsJbvOHn5RptadtrsuwqNW6qbdeP6KCSfGRoKrAyVQR7z1zypVuDomJA4xjZf0w03h052jt5WHOSrdYqnSjF9bPbIep7ecVgBnmfLByzi(AyFi9xG3dqhVgBnmfLByzWHzud)kjE4HXnN5EKg2R6WpdsYC4mJ0Sf06ab1CI4HxNskvWngoY7CdZXwOiqO9NPPdKKni(Vs(6b5EKg2R6WpdsYC4mJ0Sf06G64OSGoH1LehduhJ0SfSaC1HcgisDDy08zuDomvNBmCKxNCPUUDwhYJc1P)bOy51Hr1XitoQUfuNVAuUG2I((Go3ozkhoeLnAqgQHn5RpinqK4zNq41yRHPOCdldXxd7dP)c8EWCXb7bgPzlOhl(Vs(6b5EKg2R6WpdsYC4mJ0Sf0dWpZwzG4LaE2KYoZLwqxqNW6qCYuomjRlb9U57dkOtyD8HIdfqXnmv3WpvAovNEycuNEQoyJxQUu2NsS6ALXHd2jwDP)2pOomU5So9RdxhHEPlBuD(xNMbfvNdVDD6Fgu1zDDwDyCZzDwAQAJMVpOG2I((Go3ozkhMKqALXHd2jgp7eIVA0yOwqNW6sGM1H4KPC4H41aBdxNXO64s5PoUMQdb2KV(2zluuD(xhgbO561nzVwDomvxQ19Ylvh2d466mGSou0cK1n8idka1np1r8sG62zD6P6mgvN51PzOxDjp6Vo0nzVwDomvxkJIVgM51HIFIcOmxqBrFFqNBNmLdts0GmudBYxF7SfkINDcbDyCZzUDYuoCMlfp8W4MZmVgyB4mxkklOtyDOOfSnCDMxh)rRUKh9xN(1HFoVouaPUHQlzOvN(1HRdfqQt)6W1HaZXwOiqD89mGj)6W4MZ64sRZ)6mE)vwx)AuDjp6Vo9w7uD96CMVpOZf0w03h052jt5WKenidfnLkyrFFqqTTZdW0iiZfSnmp7ecg3CMByo2cfbc(ZaM8ZCPdIVg2hs)f4DwsZnU(yqsSGoH1LGR6VU2MuD(x3CbBdxN51Lm0Ql5r)1PFD46i0ZIUAuDjRo3y4iVZ1HoetJQZ66EoVxjvx7KPC4mklOTOVpOZTtMYHjjAqgkAkvWI((GGABNhGPrqMlyByE2jKoLuQGBmCK35gMJTqrGq7ptdsYgeFnSpK(lWBDGKSc6ewhkAbBdxN51Lm0Ql5r)1PFD4NZRdfq4Po(HwD6xhUouaHN6mGSUHTo9RdxhkGuNnDIvhkgdSnCDpRo(GP6qrlR96qbdeP6qRoDxCWExhkgchzGivqBrFFqNBNmLdts0Gmu0uQGf99bb12opatJGmxW2W8StiXxd7dP)c8olP5gxFmiOMCOZnfb8SKOuIfANzUHJ0YeWWuKCa6W4MZmVgyB4mxkE4z4dXwNYomfMlR9G0arktadtrYbDkPub3y4iVZnmhBHIaH2FM2y8hLOSGoH1LG71LyDUXWrExN(1HRdHImYRJpkcdw0hhvhueLwhxADOOfiRB4rguaQ76WgvxCuuTaC1HaBYxF7SfkkxqBrFFqNBNmLdts0GmudBYxF7SfkIN4OOIcUXWrEdbvE2je3ueWZnfzKhCkcdw0hhLjGHPi5ajHXnN55cKb9KbfG6oZinBb9yOoOtjLk4gdh5DUH5yluei0(Z0GK4a3y4ip7Rgf8pixk5yKMTGwNHTGoH1n8wh(586qbIsjwDioZCdhPvNbK1X)6sqgaQUUFwxskts1TG6CyQoeyt(676wVUTRt)ZC4646fGRoeyt(6BNTqr19G64FDUXWrENlOTOVpOZTtMYHjjAqgQHn5RVD2cfXZoHGF3ueWZsIsjwODM5gosltadtrYbg(qS1PmMYKuybbhMcnSjF9DMzaOGW)bDkPub3y4iVZnmhBHIaH2FMge(xqNW6qrpRUu2(S1hvh7DZ3hWtDCnvhcSjF9TZwOO6EEjwDi(Z0QdvuwN(1HRB4HIVodNTG2RJlTo)Rlz15gdh5np1LikRBN1HIgE1TDDmoayb4Q7NZ6q3dQZaJQZ0EoGx3pRZngoYBuYtDpRo(JY68Vond9wTfFO6qEuOoc9Cc07dQt)6W1LabiEx3Ww16JQ7b1X)6CJHJ8Uo0LS60VoCDjTockZf0w03h052jt5WKenid1WM813oBHI4zNq41yRHPOmxtHu2(S1hfyVB((GbOtsyCZzEUazqpzqbOUZmsZwqpgQ4HNBkc4z9KL(anRDILjGHPi5GoLuQGBmCK35gMJTqrGq7ptBmijdp8m8HyRt5fq8UUHTQ1hLjGHPi5amU5m3J0WEvh(zqsMdN5sh0PKsfCJHJ8o3WCSfkceA)zAJbH)Oz4dXwNYyktsHfeCyk0WM813zcyyksIYcAl67d6C7KPCysIgKHAyo2cfbcT)mnE2jKoLuQGBmCK36aH)f0jSoeyt(6BNTqr15FDmAYOgUou0cK1n8idka1DDgqwN)1rGMJr1PNQlAG6IgJnQUNxIvNv3KtPQdfn8QBb(xNdt1bi0ZRd5rH62zDPF3lMIYf0w03h052jt5WKenid1WM813oBHI4zNqKeg3CMNlqg0tguaQ7mJ0Sf0Jbbv8Wl(Vs(6b5EKg2R6WpdsYC4mJ0Sf0JH6WnqsyCZzEUazqpzqbOUZmsZwqpw8FL81dY9inSx1HFgKK5WzgPzlOlOTOVpOZTtMYHjjAqgk9FvGr9ZXIepZNfae65qqTG2I((Go3ozkhMKObzOwzC4GDIXZoHGFghGMpdhLnOmJTDOFovyYmCAeWZe6JBttj5G4dKCRNBLXHd2jwOJgRZeWWuKCq8bsU1ZTY4Wb7el0rJ1zMbGshiOIMBkc4z9KL(anRDILjGHPizbTf99bDUDYuomjrdYq4u)RHPmjXZoHGFghGMpdhLnOmJTDOFovyYmCAeWZe6JBttj5a0z4dXwNYPeB(mZPmZaqPdKeh0PKsfCJHJ8o3WCSfkceA)zAJbjr8WdJBoZPeB(mZjzGxAbDUDlcLoq4)G4dKCRNtj28zMtYaV0c6mZaqPde0X)Kl(aj36zjrPelinC4iwNjGHPij(MikrzbTf99bDUDYuomjrdYqyweQ2nmE2je8Z4a08z4OSbLzSTd9ZPctMHtJaEMqFCBAkjhGXnN5uInFM5KmWlTGo3UfHshi8Fq8bsU1ZPeB(mZjzGxAbDMzaO0bYWLCUPiGN1tw6d0S2jwMagMIK4BIf0w03h052jt5WKenid1WM813oBHIeiDkff6M4WIQWfUqa]] )


end
