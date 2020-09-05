-- RogueSubtlety.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR


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
            alias = { "instant_poison", "wound_poison" },
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
            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up
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
                return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 )
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

            spend = function () return 20 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
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

            spend = function () return 30 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
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
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },


        feint = {
            id = 1966,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
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
            end,
        },


        kidney_shot = {
            id = 408,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 25 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
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
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },


        sap = {
            id = 6770,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
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
            
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then addStack( "alacrity", nil, 1 ) end                
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },


        shadowstep = {
            id = 36554,
            cast = 0,
            charges = 2,
            cooldown = 30,
            recharge = 30,
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

            usable = function () return stealthed.all end,
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

                applyDebuff( "target", "find_weakness" )
            end,
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

            usable = function () return time == 0 and not buff.stealth.up and not buff.vanish.up end,            
            readyTime = function () return buff.shadow_dance.remains end,
            handler = function ()
                applyBuff( "stealth" )
                if talent.shot_in_the_dark.enabled then applyBuff( "shot_in_the_dark" ) end
                if talent.premeditation.enabled then applyBuff( "premeditation" ) end

                emu_stealth_change = query_time
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


    spec:RegisterPack( "Subtlety", 20200904, [[dafLUbqiOqpckQnjj9jOiHrPi1PuKSkOi6vqPMfQk3IIGDjXVuegguWXqvSmjrpdvPMgfrxtsrBtsj9njLW4qvsDofrvRdvjX8uiDpqSpjH)bfjshusjAHkepKIqturKlkPq1gHIuFusHIrcfjQtcfjTsfvVusbYmLuO0nLua7evv)usbQHcfHLkPqEkunvksxvsbTvfrLVQikDwOirSxk9xrgSuhwyXq6XIAYK6YiBguFgKgneNwPvJQK0RvOMnj3Mc7g43QmCfCCfrXYr55QA6exhv2ouY3POgpQsCEjvRxsPMVIY(PAlpwtT46qil)vIHkXagM8yWKfEQK31cEBslUuFGS4drECaLS4GWGS44COIIK6w8HOU6cT1ul(FCSmzXrez45vMycORGWHwYNXe)AWPczpqMfWYe)AKNWIJYTkbtfyrT46qil)vIHkXagM8yWKfEQK310Kw8GtqoMfhFnmrloYQ1eWIAX10NT4y2BCourrsDVRrhuoYNJzVXPbHmqjM3MKpVRedvIbFUphZEBIibak98k(Cm7Tj4DTuRjT31G28yVLZBnbhCkX7il7b8wTVu85y2BtW7AezCyrAVLGbLK0c7D(a6v2d49b8UgiyJjT3WhZ7jrHGu85y2BtW7APwtAVRHp5nMQqgFXIR2xERPw8xOqjiK2AQLFESMAXJSShWI)QGdkIqmlobcufPTJyfl)vAn1ItGavrA7iw8mBfITHfFAVLqraPaVaDYmfJb0)fceOks79SzE)dKsLKGbLKV8iCSDmbsVCmdVh1BE79uEx17P9gLdgU8cfkbPWn49SzEJYbdxWka7Ju4g8EklEKL9aw8hj0N5xy7yYkw(5T1ulobcufPTJyXZSvi2gwCuoy4YJWX2Xeijhde6RWn4DvVZNb6LgUfiFrtWBEfVhfI3vAXJSShWINdLkfzzpqsTVyXv7ljqyqwC4fSpIvS8BsRPwCceOksBhXINzRqSnS4)aPujjyqj5lpchBhtG0lhZWBiEBsVR6D(mqV0WTa59UciEBslEKL9aw8COuPil7bsQ9flUAFjbcdYIdVG9rSIL)AAn1ItGavrA7iw8mBfITHfpFgOxA4wG8fnbV5v8EuiEZJ3MG3t7Tekcifnrdel9clKakzuiqGQiT3v9EAVr5GHlyfG9rkCdEpBM3rTj2kurqOe8YEjPdqMkeiqvK27QE)dKsLKGbLKV8iCSDmbsVCmdVh1BE7DvVr5GHlGfkI8jSiaukazQWn49uEpLfpYYEalEouQuKL9aj1(IfxTVKaHbzXHxW(iwXYFTAn1ItGavrA7iw8mBfITHfpQnXwHkded(yHqfwag7Dfq8UsVR69pqkvscgus(YJWX2Xei9YXm8EuiExPfpYYEalou1DgOQqtwXYFTWAQfNabQI02rS4rw2dyXFKqFMFHTJjlEMTcX2WIlHIas5PmJKKqzeWoz4OcbcufP9UQ3sOiGuGxGozMIXa6)cbcufP9UQ3AcLdgUaVaDYmfJb0)fgzel49EuV5X7QE)dKsLKGbLKV8iCSDmbsVCmdVH4DLEx1BznOKCj9sEBcEZiJybV3v4DTAXZ1ZkkjbdkjVLFESILFET1ulobcufPTJyXZSvi2gwCm6Tekcifnrdel9clKakzuiqGQiT3v9oQnXwHkOQqtPfKeek9iH(m)fwag7neV5T3v9(hiLkjbdkjF5r4y7ycKE5ygEdXBEBXJSShWI)iH(m)cBhtwXY)K3AQfNabQI02rS4z2keBdlowbBdufv4EknW2JTs9e7Kq2d4DvVN2BjueqkWlqNmtXya9FHabQI0Ex1BnHYbdxGxGozMIXa6)cJmIf8EpQ3849SzElHIasXmfdhWiEHyfceOks7DvV)bsPssWGsYxEeo2oMaPxoMH3JcXBt69SzEh1MyRqLfqyTsGUQvQxiqGQiT3v9gLdgU81nqp1No4KMcbPWn4DvV)bsPssWGsYxEeo2oMaPxoMH3JcXBE7n2Eh1MyRqfuvOP0csccLEKqFM)cbcufP9EklEKL9aw8hj0N5xy7yYkw(5bdwtT4eiqvK2oIfpZwHyByX)bsPssWGsY7Dfq8M3w8il7bS4pchBhtG0lhZWkw(5HhRPw8il7bS4psOpZVW2XKfNabQI02rSIvS40)eitV1ul)8yn1ItGavrA7iw8mBfITHfNaedA9ISgusUKrWlExH384DvVXO3OCWWLVUb6P(0bN0uiifUbVR690EJrV1NuYhitaHfcPtWQWGsOCmqr284fa17QEJrVJSShOKpqMaclesNGvHbvwqcwTqreVNnZByoLkXOmsWGsjzniVh1BOzDXi4fVNYIhzzpGfpFGmbewiKobRcdYkw(R0AQfNabQI02rS4z2keBdlog9oFNsFMbLhj0N5eQk00x4g8UQ357u6ZmO81nqp1No4KMcbPWn49SzEdVqrKeJmIf8EpkeV5bdw8il7bS4OQ70PdojiuIaKrDRy5N3wtT4rw2dyXHYfm9gG0bNIAtStqS4eiqvK2oIvS8BsRPwCceOksBhXINzRqSnS4t79pqkvscgus(YJWX2Xei9YXm8UciExP3ZM5nlwDIWIasj06VSaVRW7AfdEpL3v9gJENVtPpZGYx3a9uF6GtAkeKc3G3v9gJEJYbdx(6gON6thCstHGu4g8UQ3eGyqRx0e8MxX7kG4nVXGfpYYEalo8L5EsNIAtSvOekfgwXYFnTMAXjqGQiTDelEMTcX2WI)dKsLKGbLKV8iCSDmbsVCmdVRaI3v69SzEZIvNiSiGucT(llW7k8UwXGfpYYEal(ahBHRVaOjuv8IvS8xRwtT4eiqvK2oIfpZwHyByXr5GHlmkpwr)NGpwMkCdEpBM3OCWWfgLhRO)tWhltP8XbeIvEjYJ9EuV5bdw8il7bS4ccL4aOhhqNGpwMSIL)AH1ulEKL9awC2omOO0cs)qKjlobcufPTJyfl)8ARPwCceOksBhXINzRqSnS457u6ZmO81nqp1No4KMcbPWiJybV3J6Dn9E2mVHxOisIrgXcEVh1BE41w8il7bS4MpMsJfTGeJ(deGmzfl)tERPwCceOksBhXINzRqSnS4eGyqR79OEBsm4DvVr5GHlFDd0t9PdoPPqqkCdw8il7bS4gKXXQNo4KIlV6KMrHXBfl)8GbRPwCceOksBhXIhzzpGfNrXWcGMGvHb9w8mBfITHfxcguskYAqj5s6L8EuV5PutVNnZ7P9EAVLGbLKccfkbPmKfVRWBEng8E2mVLGbLKccfkbPmKfVhfI3vIbVNY7QEpT3rwwSOebiJLEVH4npEpBM3sWGssrwdkjxsVK3v4DLtEVNY7P8E2mVN2BjyqjPiRbLKlnKLuLyW7k8M3yW7QEpT3rwwSOebiJLEVH4npEpBM3sWGssrwdkjxsVK3v4TjnP3t59uw8C9SIssWGsYB5NhRyflUMGdoLyn1YppwtT4eiqvK2oIfpZwHyByXXO3VqHsqiDHDq5ilEKL9aw8XBESvS8xP1ulEKL9aw8xOqjiwCceOksBhXkw(5T1ulobcufPTJyXJSShWINdLkfzzpqsTVyXv7ljqyqw8S(TILFtAn1ItGavrA7iw8mBfITHf)fkuccPlHszXJSShWIZ4aPil7bsQ9flUAFjbcdYI)cfkbH0wXYFnTMAXjqGQiTDelEMTcX2WIlRbLKlPxY7k8Uw9UQ3mYiwW79OEdnRlgbV4DvVZNb6LgUfiV3vaXBt6Tj490ElRb59OEZdg8EkVXKExPfpYYEaloJBq4yKvS8xRwtT4eiqvK2oIf)gS4pjw8il7bS4yfSnqvKfhRqXrw8b2ESvQNyNeYEaVR69pqkvscgus(YJWX2Xei9YXm8UciExPfhRGLaHbzX5EknW2JTs9e7Kq2dyfl)1cRPwCceOksBhXINzRqSnS4yfSnqvuH7P0aBp2k1tStczpGfpYYEalEouQuKL9aj1(IfxTVKaHbzXFHcLGKY63kw(51wtT4eiqvK2oIf)gS4pjw8il7bS4yfSnqvKfhRqXrw8kRP3y7TekcifSwOhRqGavrAVXKEZ7A6n2ElHIasXiEHyPdo9iH(m)fceOks7nM07kRP3y7TekciLhj0N5e8L5(cbcufP9gt6DLyWBS9wcfbKsOImBL6fceOks7nM0BEWG3y7np10BmP3t79pqkvscgus(YJWX2Xei9YXm8UciEZBVNYIJvWsGWGS4VqHsqsccJEKtPTIL)jV1ulobcufPTJyXZSvi2gwCcqmO1lAcEZR49Oq8gRGTbQIkVqHsqsccJEKtPT4rw2dyXZHsLISShiP2xS4Q9Leimil(luOeKuw)wXYppyWAQfNabQI02rS4z2keBdlEuBITcvalue5tyraOuaYuHabQI0Ex1Bm6nkhmCbSqrKpHfbGsbitfUbVR6D(mqV0WTa5lAcEZR4DfEZJ3v9EAV)bsPssWGsYxEeo2oMaPxoMH3J6DLEpBM3yfSnqvuH7P0aBp2k1tStczpG3t5DvVN278Dk9zgu(6gON6thCstHGuyKrSG37rH4nV9E2mVN27O2eBfQawOiYNWIaqPaKPclaJ9UciExP3v9gLdgU81nqp1No4KMcbPWiJybV3v4nV9UQ3y07xOqjiKUekL3v9oFNsFMbLhj0N5KoazQKrcgu6tWSil7bcL3vaXBmuM8EpL3tzXJSShWIZ4geogzfl)8WJ1ulobcufPTJyXZSvi2gw88zGEPHBbYx0e8MxX7rH4npEpBM3YAqj5s6L8EuiEZJ3v9oFgOxA4wG8ExbeV5TfpYYEalEouQuKL9aj1(IfxTVKaHbzXHxW(iwXYppvAn1ItGavrA7iw8mBfITHf)hiLkjbdkjF5r4y7ycKE5ygEdXBt6DvVZNb6LgUfiV3vaXBtAXJSShWINdLkfzzpqsTVyXv7ljqyqwC4fSpIvS8ZdVTMAXjqGQiTDelEMTcX2WItaIbTErtWBEfVhfI3yfSnqvu5fkucssqy0JCkTfpYYEalEouQuKL9aj1(IfxTVKaHbzXr5wL2kw(5XKwtT4eiqvK2oIfpZwHyByXjaXGwVOj4nVI3vaXBEQP3y7nbig06fgbLaw8il7bS4blhakjhJraXkw(5PMwtT4rw2dyXdwoauAGt9KfNabQI02rSILFEQvRPw8il7bS4QfkI8jEvonudciwCceOksBhXkw(5Pwyn1IhzzpGfhnGMo4KW2843ItGavrA7iwXkw8bgLpd0qSMA5NhRPw8il7bS4VqHsqS4eiqvK2oIvS8xP1ulEKL9aw8f8saK0WT)bS4eiqvK2oIvS8ZBRPw8il7bS4z2omOwa00WT)bS4eiqvK2oIvS8BsRPwCceOksBhXINzRqSnS4mcMrpsGQiVR6ng9wcfbKYaJmi9kHShOqGavrAlEKL9aw8xTzkfaDsVzYkw(RP1ulobcufPTJyXJSShWIBeSXKobFSKMcbXIpWO8zGgs6P8b0VfNNAAfl)1Q1ulobcufPTJyXbHbzXJA)ibl(e8bK0bNgoZeZIhzzpGfpQ9JeS4tWhqshCA4mtmRy5Vwyn1IhzzpGfF4K9awCceOksBhXkwXIJYTkT1ul)8yn1ItGavrA7iw8mBfITHf)hiLkjbdkjV3vaX7k9gBVN2Bjueqkqv3zGQcnviqGQiT3v9oQnXwHkded(yHqfwag7Dfq8UsVNYIhzzpGf)r4y7ycKE5ygwXYFLwtT4rw2dyXPmYTaOjgnWwJaOT4eiqvK2oIvS8ZBRPwCceOksBhXINzRqSnS45Za9sd3cKVOj4nVI3J6npEJT3AcLdgU8eJfcPtOhGs)WoMkVe5Xw8il7bS4pXyHq6e6bO0pSJjRy53KwtT4rw2dyXHQUZavfAYItGavrA7iwXYFnTMAXJSShWIJg5XVeOwCceOksBhXkwXIN1V1ul)8yn1ItGavrA7iw8mBfITHfhJEJYbdxEKqFMt6aKPc3G3v9gLdgU8iCSDmbsYXaH(kCdEx1Buoy4YJWX2Xeijhde6RWiJybV3JcXBExQPfpYYEal(Je6ZCshGmzX5EkDWWjOzTLFESIL)kTMAXjqGQiTDelEMTcX2WIJYbdxEeo2oMaj5yGqFfUbVR6nkhmC5r4y7ycKKJbc9vyKrSG37rH4nVl10IhzzpGf)RBGEQpDWjnfcIfN7P0bdNGM1w(5Xkw(5T1ulobcufPTJyXZSvi2gwCm69luOeesxcLY7QERpPW4geogvKnpEbq9E2mVP)jqMkOmkeK0bNeekPRVaOfJGx9yEx1BzniVRaI3vAXJSShWINdLkfzzpqsTVyXv7ljqyqwC6FcKP3kw(nP1ulobcufPTJyXJSShWIpCNkXO)4yzYINzRqSnS4y0BjueqkpsOpZj4lZ9fceOksBXHpwcq8Iy5NhRy5VMwtT4eiqvK2oIfpZwHyByXjaXGw37kG4DTIbVR6T(KcJBq4yur284fa17QENVtPpZGYx3a9uF6GtAkeKc3G3v9oFNsFMbLhj0N5KoazQKrcgu69UciEZJfpYYEal(JWX2Xeijhde6Zkw(RvRPwCceOksBhXINzRqSnS46tkmUbHJrfzZJxauVR6ng9oFNsFMbLhj0N5eQk00x4g8UQ3t7ng9wcfbKYJWX2Xeijhde6RqGavrAVNnZBjueqkpsOpZj4lZ9fceOks79SzENVtPpZGYJWX2Xeijhde6RWiJybV3v4DLEpL3v9EAVXO30)eitfu1D60bNeekraYOEXi4vpM3ZM5D(oL(mdkOQ70PdojiuIaKr9cJmIf8ExH3v69uEx17P9oQnXwHkGfkI8jSiaukazQWcWyVh17k9E2mVr5GHlGfkI8jSiaukazQWn49uw8il7bS4FDd0t9PdoPPqqSIL)AH1ulobcufPTJyXJSShWIBeSXKobFSKMcbXINzRqSnS4Sy1jclciLqR)c3G3v9EAVLGbLKISgusUKEjVh178zGEPHBbYx0e8MxX7zZ8gJE)cfkbH0LqP8UQ35Za9sd3cKVOj4nVI3vaX78qYi4L0pqaT3tzXZ1ZkkjbdkjVLFESILFET1ulobcufPTJyXZSvi2gwCwS6eHfbKsO1FzbExH38gdEBcEZIvNiSiGucT(lAowi7b8UQ3y07xOqjiKUekL3v9oFgOxA4wG8fnbV5v8UciENhsgbVK(bcOT4rw2dyXnc2ysNGpwstHGyfl)tERPwCceOksBhXINzRqSnS4y07xOqjiKUekL3v9wFsHXniCmQiBE8cG6DvVZNb6LgUfiFrtWBEfVRaI3vAXJSShWI)iH(mNqvHMERy5Nhmyn1IhzzpGf)PHFFlobcufPTJyfl)8WJ1ulobcufPTJyXZSvi2gwCjueqkpsOpZj4lZ9fceOks7DvV1NuyCdchJkYMhVaOEx1Buoy4Yx3a9uF6GtAkeKc3GfpYYEal(JWX2Xeijhde6Zkw(5PsRPwCceOksBhXINzRqSnS4y0Buoy4YJe6ZCshGmv4g8UQ3YAqj5s6L8EuiExtVX2BjueqkphQqmyoOuHabQI0Ex1Bm6nlwDIWIasj06VWnyXJSShWI)iH(mN0bitwXYpp82AQfNabQI02rS4z2keBdlokhmCbvDNwX9sHrrw8E2mVr5GHlFDd0t9PdoPPqqkCdEx17P9gLdgU8iH(mNqvHM(c3G3ZM5D(oL(mdkpsOpZjuvOPVWiJybV3JcXBEWG3tzXJSShWIpCYEaRy5NhtAn1ItGavrA7iw8mBfITHfhLdgU81nqp1No4KMcbPWnyXJSShWIJQUtNG5y1TILFEQP1ulobcufPTJyXZSvi2gwCuoy4Yx3a9uF6GtAkeKc3GfpYYEalokXEInEbqTILFEQvRPwCceOksBhXINzRqSnS4OCWWLVUb6P(0bN0uiifUblEKL9awC4LrOQ70wXYpp1cRPwCceOksBhXINzRqSnS4OCWWLVUb6P(0bN0uiifUblEKL9aw8aKPxyHkLdLYkw(5HxBn1ItGavrA7iw8il7bS456z1jSdS5eQkEXINzRqSnS4y07xOqjiKUekL3v9wFsHXniCmQiBE8cG6DvVXO3OCWWLVUb6P(0bN0uiifUbVR6nbig06fnbV5v8UciEZBmyXjyykljqyqw8C9S6e2b2CcvfVyfl)8m5TMAXjqGQiTDelEKL9aw8O2psWIpbFajDWPHZmXS4z2keBdlog9gLdgU8iH(mN0bitfUbVR6D(oL(mdkFDd0t9PdoPPqqkmYiwW79OEZdgS4GWGS4rTFKGfFc(as6GtdNzIzfl)vIbRPwCceOksBhXIhzzpGfpEeSca9jwu7JLYhluw8mBfITHfxtOCWWfwu7JLYhlujnHYbdx0NzG3ZM5TMq5GHl5dO5YYIfLwW4KMq5GHlCdEx1BjyqjPGqHsqkdzX7r9M3v6DvVLGbLKccfkbPmKfVRaI38gdEpBM3y0BnHYbdxYhqZLLflkTGXjnHYbdx4g8UQ3t7TMq5GHlSO2hlLpwOsAcLdgU8sKh7Dfq8UYA6Tj4npyWBmP3AcLdgUGQUtNo4KGqjcqg1lCdEpBM3WluejXiJybV3J6TjXG3t5DvVr5GHlFDd0t9PdoPPqqkmYiwW7DfEZRT4GWGS4XJGvaOpXIAFSu(yHYkw(RKhRPwCceOksBhXIdcdYIBuxhFsc1(gbWIhzzpGf3OUo(KeQ9ncGvS8xzLwtT4eiqvK2oIfpZwHyByXr5GHlFDd0t9PdoPPqqkCdEpBM3WluejXiJybV3J6DLyWIhzzpGfN7P0kKXBfRyXFHcLGKY63AQLFESMAXjqGQiTDel(nyXFsS4rw2dyXXkyBGQilowHIJS457u6ZmO8iH(mN0bitLmsWGsFcMfzzpqO8UciEZtPwutlowblbcdYI)i6KGWOh5uARy5VsRPwCceOksBhXINzRqSnS4y0BSc2gOkQ8i6KGWOh5uAVR6D(mqV0WTa5lAcEZR4DfEZJ3v9wtOCWWf4fOtMPymG(VWiJybV3J6npEx178Dk9zgu(6gON6thCstHGuyKrSG37kG4nVT4rw2dyXXka7Jyfl)82AQfNabQI02rS4rw2dyXhUtLy0FCSmzXjEryrkmooGyXnjgS4WhlbiErS8ZJvS8BsRPwCceOksBhXINzRqSnS4eGyqR7Dfq82KyW7QEtaIbTErtWBEfVRaI38GbVR6ng9gRGTbQIkpIojim6roL27QENpd0lnClq(IMG38kExH384DvV1ekhmCbEb6KzkgdO)lmYiwW79OEZJfpYYEal(Je6ZSbP0wXYFnTMAXjqGQiTDel(nyXFsS4rw2dyXXkyBGQilowHIJS45Za9sd3cKVOj4nVI3vaXBt6Tj490ElHIasrt0aXsVWcjGsgfceOks7DvVN27O2eBfQiiucEzVK0bitfceOks7DvVXO3sOiGu0bBC6rc9zUqGavrAVR6ng9wcfbKYZHkedMdkviqGQiT3v9(hiLkjbdkjF5r4y7ycKE5ygEpQ3827P8EklowblbcdYI)i6u(mqV0WTa5TIL)A1AQfNabQI02rS43Gf)jXIhzzpGfhRGTbQIS4yfkoYINpd0lnClq(IMG38kEpkeV5XBS9UsVXKEh1MyRqfbHsWl7LKoazQqGavrAlEMTcX2WIJvW2avrfUNsdS9yRupXojK9aEx17P9wcfbKcyHIiVeQXeRqGavrAVNnZBjueqk6Gno9iH(mxiqGQiT3tzXXkyjqyqw8hrNYNb6LgUfiVvS8xlSMAXjqGQiTDelEMTcX2WIJvW2avrLhrNYNb6LgUfiV3v9EAVXO3sOiGu0bBC6rc9zUqGavrAVNnZB9jfg3GWXOcJmIf8ExbeVRP3y7TekciLNdvigmhuQqGavrAVNY7QEpT3yfSnqvu5r0jbHrpYP0EpBM3OCWWLVUb6P(0bN0uiifgzel49UciEZtPsVNnZ7FGuQKemOK8LhHJTJjq6LJz4Dfq82KEx178Dk9zgu(6gON6thCstHGuyKrSG37k8Mhm49uEx17P9oQnXwHkGfkI8jSiaukazQWcWyVh17k9E2mVr5GHlGfkI8jSiaukazQWn49uw8il7bS4psOpZjDaYKvS8ZRTMAXjqGQiTDelEMTcX2WIJvW2avrLhrNYNb6LgUfiV3v9wwdkjxsVK3J6D(oL(mdkFDd0t9PdoPPqqkmYiwW7DvVXO3Sy1jclciLqR)c3GfpYYEal(Je6ZCshGmzfRyXHxW(iwtT8ZJ1ulobcufPTJyXHpwcq8Iy5NhlEKL9aw8H7ujg9hhltwXYFLwtT4eiqvK2oIfpZwHyByXr5GHlGfkI8jSiaukazQWn4DvVN27FGuQKemOK8LhHJTJjq6LJz49OExP3ZM5nwbBdufv4EknW2JTs9e7Kq2d49SzEJrVLqraP8uMrssOmcyNmCuHabQI0EpBM3y078Dk9zguEkZijjugbStgoQWn49uw8il7bS4ew7NjwiKvS8ZBRPwCceOksBhXINzRqSnS4t7ng9wcfbKIoyJtpsOpZfceOks79SzEJrVr5GHlpsOpZjDaYuHBW7P8UQ3YAqj5s6L82e8MrgXcEVRW7A17QEZiJybV3J6TS5XjzniVXKExPfpYYEaloJBq4yKvS8BsRPwCceOksBhXIhzzpGfNXniCmYINzRqSnS4y0BSc2gOkQW9uAGThBL6j2jHShW7QE)dKsLKGbLKV8iCSDmbsVCmdVRaI3v6DvVN27O2eBfQawOiYNWIaqPaKPcbcufP9E2mVXO3rTj2kuHrdQnhYcGMEKqFM)cbcufP9E2mV)bsPssWGsYxEeo2oMaPxoMH3MG3rwwSOK(KcJBq4yK3vaX7k9EkVR6ng9gLdgU8iH(mN0bitfUbVR6TSgusUKEjVRaI3t7Dn9gBVN27k9gt6D(mqV0WTa59EkVNY7QEZiyg9ibQIS456zfLKGbLK3YppwXYFnTMAXjqGQiTDelEMTcX2WIZiJybV3J6D(oL(mdkFDd0t9PdoPPqqkmYiwW7n2EZdg8UQ357u6ZmO81nqp1No4KMcbPWiJybV3JcX7A6DvVL1GsYL0l5Tj4nJmIf8ExH357u6ZmO81nqp1No4KMcbPWiJybV3y7DnT4rw2dyXzCdchJSIL)A1AQfpYYEal(tzgjjHYiGDYWrwCceOksBhXkw(RfwtT4eiqvK2oIfpZwHyByXzemJEKavrw8il7bS4VAZuka6KEZKvS8ZRTMAXJSShWItyTFMyHqwCceOksBhXkwXkwCSi2VhWYFLyOsmGHALhtAXnhmWcG(wCmvJHJjK2BET3rw2d4TAF5l(Cl(a7GxfzXXS34COIIK6ExJoOCKphZEJtdczGsmVnjFExjgQed(CFoM92ercau65v85y2BtW7APwtAVRbT5XElN3Aco4uI3rw2d4TAFP4ZXS3MG31iY4WI0ElbdkjPf278b0RShW7d4DnqWgtAVHpM3tIcbP4ZXS3MG31sTM0ExdFYBmvHm(Ip3NJzVRX5fkZjK2Buc(yK35ZaneVrjOl4lExlZzAqEVbhWeqcMbmNY7il7bEVpGQEXNJzVJSSh4ldmkFgOHabwf)yFoM9oYYEGVmWO8zGgc2qMi4GAqajK9a(Cm7DKL9aFzGr5ZaneSHmb8DAFoM9ghedpYjEZIv7nkhmmP9(LqEVrj4JrENpd0q8gLGUG37aO9EGrMWWjYcG69(ERpav85y27il7b(YaJYNbAiydzIhedpYjPxc595rw2d8LbgLpd0qWgYeVqHsq85rw2d8LbgLpd0qWgYel4LaiPHB)d4ZJSSh4ldmkFgOHGnKjYSDyqTaOPHB)d4ZJSSh4ldmkFgOHGnKjE1MPua0j9Mj(wyimcMrpsGQOQyucfbKYaJmi9kHShOqGavrAFEKL9aFzGr5ZaneSHmHrWgt6e8XsAkee(gyu(mqdj9u(a6hcp10NhzzpWxgyu(mqdbBitW9uAfYGpqyqqIA)ibl(e8bK0bNgoZeZNhzzpWxgyu(mqdbBitmCYEaFUphZExJZluMtiT3eweRU3YAqEliK3rwoM377DGvSQavrfFoM9UgrVqHsq8EH9E4(FrvK3tdoVXItbiwGQiVjazS079c8oFgOHmLppYYEGhY4npMVfgcgFHcLGq6c7GYr(8il7bESHmXluOeeFoM92erO8yVnXj9EhI3Wl7fFEKL9ap2qMihkvkYYEGKAFHpqyqqY63NJzVRrCaVH5uQ6E)MxjJqV3Y5TGqEJluOees7Dn6Kq2d490O19wFlaQ3)XN3R4n8XY079WDQfa17f2BWjilaQ377DGvSQavrtv85rw2d8ydzcghifzzpqsTVWhimiiVqHsqinFlmKxOqjiKUekLphZExlhgu19M)fkIGQcn5DiExj2EBIycV1CSfa1BbH8gEzV4npyW7NYhq)85DaleZBbjeVnj2EBIycVxyVxXBIxgwg9EBEfKf4TGqEdiEr8UgJjojVpM377n4eV5g85rw2d8ydzcg3GWXi(wyiYAqj5s6LQOwRYiJyb)OqZ6IrWlvZNb6LgUfiFfqmPjmTSg0O8GHPWKv6ZXS31GbQ6ENrcauYB2jHShW7f2BZK3ibwK3dS9yRupXojK9aE)K4Da0EBWPKDqrElbdkjV3CdfFEKL9ap2qMaRGTbQI4degeeUNsdS9yRupXojK9a8HvO4iidS9yRupXojK9av)bsPssWGsYxEeo2oMaPxoMrfqQ0NJzVXeS9yRu37A0jHShatPExJLemfV3qxSiVdVZSyW7a94eVjaXGw3B4J5TGqE)cfkbXBtCsV3tJYTknX8(LvP8Mr)aLfVxzQI3ykHBGpVxX7Ca8gL8wqcX7FnguuXNhzzpWJnKjYHsLISShiP2x4degeKxOqjiPS(5BHHGvW2avrfUNsdS9yRupXojK9a(Cm7Dn8jT3Y5TMGxa5Tzec4TCEZ9K3VqHsq82eN079X8gLBvAI9(8il7bESHmbwbBdufXhimiiVqHsqsccJEKtP5dRqXrqQSMylHIasbRf6XkeiqvKgtY7AITekcifJ4fILo40Je6Z8xiqGQinMSYAITekciLhj0N5e8L5(cbcufPXKvIbSLqraPeQiZwPEHabQI0ysEWa28utm50)aPujjyqj5lpchBhtG0lhZOci8EkFoM92epWVAI5n3VaOEhEJluOeeVnXj5Tzec4nJImYcG6TGqEtaIbTU3ccJEKtP95rw2d8ydzICOuPil7bsQ9f(aHbb5fkucskRF(wyieGyqRx0e8MxzuiyfSnqvu5fkucssqy0JCkTphZEZ)cfrWu8Ep5iaukazIxXB(xOicQk0K3Oe8XiVXRBGEQ37q8wDM92eXeElN35ZaDbK3uWu19MrWm6r828kiEdLezbq9wqiVr5GH9MBO4DTu9N3QZS3MiMWBnhBbq9gVUb6PEVrjXmraVNuaY07T5vq8UsS9M)jxXNhzzpWJnKjyCdchJ4BHHe1MyRqfWcfr(eweakfGmviqGQiDvmIYbdxalue5tyraOuaYuHBOA(mqV0WTa5lAcEZRubpvN(hiLkjbdkjF5r4y7ycKE5ygJw5SzyfSnqvuH7P0aBp2k1tStczpWuvNoFNsFMbLVUb6P(0bN0uiifgzel4hfcVNnB6O2eBfQawOiYNWIaqPaKPclaJRasLvr5GHlFDd0t9PdoPPqqkmYiwWxbVRIXxOqjiKUekv18Dk9zguEKqFMt6aKPsgjyqPpbZISShiuvabdLj)ut5ZXS3y6fSpI3H4TjX2BZRGCCI3tcNpVRj2EBEfeVNeU3tFCYVAY7xOqjit5ZJSSh4XgYe5qPsrw2dKu7l8bcdcc8c2hHVfgs(mqV0WTa5lAcEZRmkeEMntwdkjxsV0Oq4PA(mqV0WTa5RacV95y27j7kiEpjCVd1FEdVG9r8oeVnj2EhqJf8I3eVezrv3Bt6TemOK8Ep9Xj)QjVFHcLGmLppYYEGhBitKdLkfzzpqsTVWhimiiWlyFe(wyi)aPujjyqj5lpchBhtG0lhZaIjRMpd0lnClq(kGysFoM9Ug(K3H3OCRstmVnJqaVzuKrwauVfeYBcqmO19wqy0JCkTppYYEGhBitKdLkfzzpqsTVWhimiiOCRsZ3cdHaedA9IMG38kJcbRGTbQIkVqHsqsccJEKtP95y27ASNz6fVhy7XwPU3lW7qP8(G9wqiVRLyIASEJs5G7jVxX7CW907D4DngtCs(8il7bESHmrWYbGsYXyeq4BHHqaIbTErtWBELkGWtnXMaedA9cJGsaFEKL9ap2qMiy5aqPbo1t(8il7bESHmHAHIiFIxLtd1GaIppYYEGhBitGgqthCsyBE87Z95y27r4wLMyVppYYEGVGYTknKhHJTJjq6LJzW3cd5hiLkjbdkjFfqQe7PLqraPavDNbQk0uHabQI0vJAtSvOYaXGpwiuHfGXvaPYP85rw2d8fuUvPXgYeug5wa0eJgyRra0(8il7b(ck3Q0ydzINySqiDc9au6h2XeFlmK8zGEPHBbYx0e8MxzuEWwtOCWWLNySqiDc9au6h2Xu5Lip2NhzzpWxq5wLgBitavDNbQk0KppYYEGVGYTkn2qManYJFjq95(Cm7TjENsFMbVphZExdFY7jfGm59bdBcqZAVrj4JrEliK3Wl7fVXr4y7yc4nUCmdVHzNH3MEmqOpVZNb9EVGIppYYEGVK1pKhj0N5KoazIpUNshmCcAwdHh(wyiyeLdgU8iH(mN0bitfUHQOCWWLhHJTJjqsogi0xHBOkkhmC5r4y7ycKKJbc9vyKrSGFui8UutFoM9E6Aiqr)7DOyuOR7n3G3Ouo4EYBZK3YDJ9ghj0NzVX0xM7NYBUN8gVUb6PEVpyytaAw7nkbFmYBbH8gEzV4nochBhtaVXLJz4nm7m820Jbc95D(mO37fu85rw2d8LS(XgYeFDd0t9PdoPPqq4J7P0bdNGM1q4HVfgckhmC5r4y7ycKKJbc9v4gQIYbdxEeo2oMaj5yGqFfgzel4hfcVl10NhzzpWxY6hBitKdLkfzzpqsTVWhimii0)eitpFlmem(cfkbH0LqPQQpPW4geogvKnpEbqNnJ(NazQGYOqqshCsqOKU(cGwmcE1JvvwdQciv6ZXS3yI7uEdFmVn9yGqFEpWita)MK3MxbXBCKj5nJcDDVnJqaVbN4nJdawauVXX0fFEKL9aFjRFSHmXWDQeJ(JJLj(Gpwcq8IaHh(wyiyucfbKYJe6ZCc(YCFHabQI0(Cm7Dn8jVn9yGqFEpWiVXVj5Tzec4TzYBKalYBbH8MaedADVnJqccX8gMDgEpCNAbq928kihN4noM27J5nVk3lEdLaeluQ6fFEKL9aFjRFSHmXJWX2Xeijhde6JVfgcbig06vaPwXqv9jfg3GWXOIS5XlaA18Dk9zgu(6gON6thCstHGu4gQMVtPpZGYJe6ZCshGmvYibdk9vaHhFoM9Ug(K341nqp179b8oFNsFMbEpDaleZB4L9I38VqreuvOPP8MdOO)92m5DWiVHElaQ3Y59Wn4TPhde6Z7aO9wFEdoXBKalYBCKqFM9gtFzUV4ZJSSh4lz9JnKj(6gON6thCstHGW3cdrFsHXniCmQiBE8cGwfJ57u6ZmO8iH(mNqvHM(c3q1PXOekciLhHJTJjqsogi0xHabQI0ZMjHIas5rc9zobFzUVqGavr6zZY3P0Nzq5r4y7ycKKJbc9vyKrSGVIkNQ60yK(NazQGQUtNo4KGqjcqg1lgbV6XMnlFNsFMbfu1D60bNeekraYOEHrgXc(kQCQQth1MyRqfWcfr(eweakfGmvyby8OvoBgkhmCbSqrKpHfbGsbitfUHP85y2BmvyVdT(9oyK3Cd859d2bYBbH8(aK3MxbXB1zMEXBtnDsfVRHp5Tzec4TU(cG6nC8cX8wqcG3MiMWBnbV5v8(yEdoX7xOqjiK2BZRGCCI3bOU3MiMO4ZJSSh4lz9JnKjmc2ysNGpwstHGWxUEwrjjyqj5HWdFlmewS6eHfbKsO1FHBO60sWGssrwdkjxsV0O5Za9sd3cKVOj4nVYSzy8fkuccPlHsvnFgOxA4wG8fnbV5vQasEize8s6hiGEkFoM9gtf2BW5DO1V3MxLYB9sEBEfKf4TGqEdiEr8M3y45ZBUN8UgaEsEFaVrV)928kihN4DaQ7TjIj8oaAVbN3VqHsqk(8il7b(sw)ydzcJGnM0j4JL0uii8TWqyXQteweqkHw)LfubVXGjWIvNiSiGucT(lAowi7bQIXxOqjiKUekv18zGEPHBbYx0e8MxPci5HKrWlPFGaAFEKL9aFjRFSHmXJe6ZCcvfA65BHHGXxOqjiKUekvv9jfg3GWXOIS5XlaA18zGEPHBbYx0e8MxPciv6ZJSSh4lz9JnKjEA433NJzVNSRG4noMMpVxyVbN4DOyuOR7T(aeFEZ9K3MEmqOpVnVcI343K8MBO4ZJSSh4lz9JnKjEeo2oMaj5yGqF8TWqKqraP8iH(mNGVm3xiqGQiDv9jfg3GWXOIS5XlaAvuoy4Yx3a9uF6GtAkeKc3GppYYEGVK1p2qM4rc9zoPdqM4BHHGruoy4YJe6ZCshGmv4gQkRbLKlPxAui1eBjueqkphQqmyoOuHabQI0vXilwDIWIasj06VWn4ZJSSh4lz9JnKjgozpaFlmeuoy4cQ6oTI7LcJISmBgkhmC5RBGEQpDWjnfcsHBO60OCWWLhj0N5eQk00x4gMnlFNsFMbLhj0N5eQk00xyKrSGFui8GHP85rw2d8LS(XgYeOQ70jyowD(wyiOCWWLVUb6P(0bN0uiifUbFEKL9aFjRFSHmbkXEInEbq5BHHGYbdx(6gON6thCstHGu4g85rw2d8LS(XgYeWlJqv3P5BHHGYbdx(6gON6thCstHGu4g85rw2d8LS(XgYebitVWcvkhkfFlmeuoy4Yx3a9uF6GtAkeKc3GppYYEGVK1p2qMG7P0kKbFemmLLeimii56z1jSdS5eQkEHVfgcgFHcLGq6sOuv1NuyCdchJkYMhVaOvXikhmC5RBGEQpDWjnfcsHBOkbig06fnbV5vQacVXGppYYEGVK1p2qMG7P0kKbFGWGGe1(rcw8j4diPdonCMjgFlmemIYbdxEKqFMt6aKPc3q18Dk9zgu(6gON6thCstHGuyKrSGFuEWGphZEp5iwDVzhhuevDVzCkY7d2BbHZaDHxs7TriiV3OK6mZR4Dn8jVHpM3yQGXdN27mBf(8(eeIzEFYBZRG4n(njVdX7kRj2E)sKh)EFmV5PMy7T5vq8ou)59iQ70EZnu85rw2d8LS(XgYeCpLwHm4degeK4rWka0NyrTpwkFSqX3cdrtOCWWfwu7JLYhlujnHYbdx0NzWSzAcLdgUKpGMlllwuAbJtAcLdgUWnuvcguskiuOeKYqwgL3vwvcguskiuOeKYqwQacVXWSzyutOCWWL8b0CzzXIslyCstOCWWfUHQtRjuoy4clQ9Xs5JfQKMq5GHlVe5XvaPYAAc8GbmPMq5GHlOQ70PdojiuIaKr9c3WSzWluejXiJyb)OMedtvfLdgU81nqp1No4KMcbPWiJybFf8AFEKL9aFjRFSHmb3tPvid(aHbbXOUo(KeQ9ncGphZEpjco4uI3WHsHg5XEdFmV5(avrEVcz88kExdFYBZRG4nEDd0t9EFWEpjkeKIppYYEGVK1p2qMG7P0kKXZ3cdbLdgU81nqp1No4KMcbPWnmBg8cfrsmYiwWpALyWN7ZXS314)tGm9(8il7b(c9pbY0djFGmbewiKobRcdIVfgcbig06fznOKCjJGxQGNQyeLdgU81nqp1No4KMcbPWnuDAmQpPKpqMaclesNGvHbLq5yGIS5XlaAvmgzzpqjFGmbewiKobRcdQSGeSAHIiZMbZPujgLrcgukjRbnk0SUye8Yu(8il7b(c9pbY0JnKjqv3PthCsqOebiJ68TWqWy(oL(mdkpsOpZjuvOPVWnunFNsFMbLVUb6P(0bN0uiifUHzZGxOisIrgXc(rHWdg85rw2d8f6FcKPhBitaLly6naPdof1MyNG4ZJSSh4l0)eitp2qMa(YCpPtrTj2kucLcd(wyit)dKsLKGbLKV8iCSDmbsVCmJkGu5SzSy1jclciLqR)YcQOwXWuvXy(oL(mdkFDd0t9PdoPPqqkCdvXikhmC5RBGEQpDWjnfcsHBOkbig06fnbV5vQacVXGppYYEGVq)tGm9ydzIbo2cxFbqtOQ4f(wyi)aPujjyqj5lpchBhtG0lhZOcivoBglwDIWIasj06VSGkQvm4ZJSSh4l0)eitp2qMqqOeha94a6e8XYeFlmeuoy4cJYJv0)j4JLPc3WSzOCWWfgLhRO)tWhltP8XbeIvEjYJhLhm4ZJSSh4l0)eitp2qMGTddkkTG0pezYNhzzpWxO)jqMESHmH5JP0yrliXO)abit8TWqY3P0Nzq5RBGEQpDWjnfcsHrgXc(rR5SzWluejXiJyb)O8WR95rw2d8f6FcKPhBityqghRE6GtkU8QtAgfgpFlmecqmO1h1KyOkkhmC5RBGEQpDWjnfcsHBWNJzVXu(uAVRrumSaOEJPvHb9EdFmVjEHYCc5nlaqjVpM3JxLYBuoy4NpVxyVhU)xufv8UwQmh1FVfwDVLZBOK4TGqERoZ0lENVtPpZaVrJN0EFaVdSIvfOkYBcqgl9fFEKL9aFH(Naz6XgYemkgwa0eSkmONVC9SIssWGsYdHh(wyisWGssrwdkjxsV0O8uQ5SztpTemOKuqOqjiLHSubVgdZMjbdkjfekucszilJcPsmmv1PJSSyrjcqgl9q4z2mjyqjPiRbLKlPxQIkN8tn1SztlbdkjfznOKCPHSKQedvWBmuD6illwuIaKXspeEMntcguskYAqj5s6LQWKMCQP85(Cm7nMEb7JqS3NhzzpWxGxW(iqgUtLy0FCSmXh8XsaIxei84ZXS314yTFMyHqEJeV3ilue6fVhy7XwPU3MxbXB(xOicMI37jhbGsbitEZnu827ACEjtdYEaV337A5vJ7TomcOK3MriG34u2uk79(EZOqxV4ZJSSh4lWlyFeSHmbH1(zIfcX3cdbLdgUawOiYNWIaqPaKPc3q1P)bsPssWGsYxEeo2oMaPxoMXOvoBgwbBdufv4EknW2JTs9e7Kq2dmBggLqraP8uMrssOmcyNmCuHabQI0ZMHX8Dk9zguEkZijjugbStgoQWnmLphZExdIObV5g8M)fkIGQcn59c79kEVV3b6XjElN3moG3hNu8EsN3Gt8M7jV5FeV1CSfa17jfGmXN3lS3sOiGqAVxGCEpPGn2BCKqFMl(8il7b(c8c2hbBitW4geogX3cdzAmkHIasrhSXPhj0N5cbcufPNndJOCWWLhj0N5KoazQWnmvvznOKCj9sMaJmIf8vuRvzKrSGFuzZJtYAqyYk95y27AaoLS6tKfa17Jt(vtEpPaKjVpG3sWGsY7TGeI3MxLYB1If5n8X8wqiV1CSq2d49b7n)luebvfAIpVzemJEeV1CSfa17HaOjJnx8UgGtjR(eVJ3B1bG6D8Exj2ElbdkjV36ZBWjEJeyrEZ)cfrqvHM8MBWBZRG4DnIguBoKfa1BCKqFMFVNMdOO)9U(X5nsGf5n)luebtX79KJaqPaKjVL7MQ4ZJSSh4lWlyFeSHmbJBq4yeF56zfLKGbLKhcp8TWqWiwbBdufv4EknW2JTs9e7Kq2du9hiLkjbdkjF5r4y7ycKE5ygvaPYQth1MyRqfWcfr(eweakfGmviqGQi9SzymQnXwHkmAqT5qwa00Je6Z8xiqGQi9Sz)aPujjyqj5lpchBhtG0lhZWeISSyrj9jfg3GWXOkGu5uvXikhmC5rc9zoPdqMkCdvL1GsYL0lvbKPRj2txjMmFgOxA4wG8tnvvgbZOhjqvKphZExJiyg9iEZ)cfrqvHM8McMQU3lS3R4T5vP8M4LHLrER5ylaQ341nqp1x8EsN3csiEZiyg9iEVWEJFtYBOK8EZOqx37f4TGqEdiEr8UMFXNhzzpWxGxW(iydzcg3GWXi(wyimYiwWpA(oL(mdkFDd0t9PdoPPqqkmYiwWJnpyOA(oL(mdkFDd0t9PdoPPqqkmYiwWpkKAwvwdkjxsVKjWiJybFf57u6ZmO81nqp1No4KMcbPWiJybp210NhzzpWxGxW(iydzINYmsscLra7KHJ85rw2d8f4fSpc2qM4vBMsbqN0BM4BHHWiyg9ibQI85rw2d8f4fSpc2qMGWA)mXcH85(Cm7nUqHsq82eVtPpZG3NJzVXuMudeZ7jxW2avr(8il7b(YluOeKuw)qWkyBGQi(aHbb5r0jbHrpYP08HvO4ii57u6ZmO8iH(mN0bitLmsWGsFcMfzzpqOQacpLArn95y27jxa2hXBoGI(3BZK3bJ8oqpoXB58ohdEFaVNuaYK3zKGbL(I31GbQ6EBgHaEJPxG27jlfJb0)EVV3b6XjElN3moG3hNu85rw2d8LxOqjiPS(XgYeyfG9r4BHHGrSc2gOkQ8i6KGWOh5u6Q5Za9sd3cKVOj4nVsf8uvtOCWWf4fOtMPymG(VWiJyb)O8unFNsFMbLVUb6P(0bN0uiifgzel4RacV95y2BmXDkVHpM34iH(mBqkT3y7nosOpZVW2XK3Caf9V3MjVdg5DGECI3Y5Dog8(aEpPaKjVZibdk9fVRbdu192mcb8gtVaT3twkgdO)9EFVd0Jt8woVzCaVpoP4ZJSSh4lVqHsqsz9JnKjgUtLy0FCSmXh8XsaIxei8WhXlclsHXXbeiMed(8il7b(YluOeKuw)ydzIhj0NzdsP5BHHqaIbTEfqmjgQsaIbTErtWBELkGWdgQIrSc2gOkQ8i6KGWOh5u6Q5Za9sd3cKVOj4nVsf8uvtOCWWf4fOtMPymG(VWiJyb)O84ZXS3MiMWBgnz4wgzqaHxX7jfGm5DiERoZEBIycVrR7TMGdoLu8EACouHfzzpG377D4D(gQ7nm7m8wqiVFHcfcP9gEb7JqmVZHs5n8X82um9K8gjaA1cGwMYNhzzpWxEHcLGKY6hBitGvW2avr8bcdcYJOt5Za9sd3cKNpScfhbjFgOxA4wG8fnbV5vQaIjnHPLqraPOjAGyPxyHeqjJcbcufPRoDuBITcveekbVSxs6aKPcbcufPRIrjueqk6Gno9iH(mxiqGQiDvmkHIas55qfIbZbLkeiqvKU6pqkvscgus(YJWX2Xei9YXmgL3tnLphZEBIycVz0KHBzKbbeEfVNuaYK3hqv3Buc(yK3WlyFeI9EVWEBM8gjWI8omg8wcfbK37aO9EGThBL6EZojK9afFEKL9aF5fkucskRFSHmbwbBdufXhimiipIoLpd0lnClqE(WkuCeK8zGEPHBbYx0e8Mxzui8GDLyYO2eBfQiiucEzVK0bitfceOksZ3cdbRGTbQIkCpLgy7XwPEIDsi7bQoTekcifWcfrEjuJjwHabQI0ZMjHIasrhSXPhj0N5cbcufPNYNJzVNSRG49Kc2yVXrc9z27dOQ79KcqM82mcb8M)fkIGQcn5T5vP8(LOU3CdfVRHp5TMJTaOEJx3a9uV3hZ7a9WI8wqy0JCkDX7jBSI3WhZB(NCEJYbd7T5vq8UsS5FYv85rw2d8LxOqjiPS(XgYepsOpZjDaYeFlmeSc2gOkQ8i6u(mqV0WTa5RongLqraPOd240Je6ZCHabQI0ZMPpPW4geogvyKrSGVci1eBjueqkphQqmyoOuHabQI0tvDASc2gOkQ8i6KGWOh5u6zZq5GHlFDd0t9PdoPPqqkmYiwWxbeEkvoB2pqkvscgus(YJWX2Xei9YXmQaIjRMVtPpZGYx3a9uF6GtAkeKcJmIf8vWdgMQ60rTj2kubSqrKpHfbGsbitfwagpALZMHYbdxalue5tyraOuaYuHBykFoM9EeogWBgzelybq9EsbitV3Oe8XiVfeYBjyqjXB9sV3lS343K828bWuiEJsEZOqx37f4TSguXNhzzpWxEHcLGKY6hBit8iH(mN0bit8TWqWkyBGQOYJOt5Za9sd3cKVQSgusUKEPrZ3P0Nzq5RBGEQpDWjnfcsHrgXc(QyKfRoryraPeA9x4g85(Cm7nUqHsqiT31OtczpGppYYEGV8cfkbH0ydzIxfCqreI5ZXS3yQWEJluOeKjWka7J4DWiV5g4ZBUN8ghj0N5xy7yYB58gLae8kEdZodVfeY7H4)flYB0dW9EhaT3y6fO9EYsXya9pFEtyraVxyVntEhmY7q82i4fVnrmH3tdZodVfeY7bgLpd0q8UgaEstv85rw2d8LxOqjiKgYJe6Z8lSDmX3cdzAjueqkWlqNmtXya9FHabQI0ZM9dKsLKGbLKV8iCSDmbsVCmJr59uvNgLdgU8cfkbPWnmBgkhmCbRaSpsHBykFoM9gtVG9r8oeV5n2EBIycVnVcYXjEpjCVNWBtIT3MxbX7jH7T5vq8ghHJTJjG3MEmqOpVr5GH9MBWB58oW6wT3)zqEBIycVnhVqE)RWfYEGV4ZJSSh4lVqHsqin2qMihkvkYYEGKAFHpqyqqGxW(i8TWqq5GHlpchBhtGKCmqOVc3q18zGEPHBbYx0e8Mxzuiv6ZXS31s1FE)bm5TCEdVG9r8oeVnj2EBIycVnVcI3eVezrv3Bt6TemOK8fVNgpmiVJ37Jt(vtE)cfkbPmLppYYEGV8cfkbH0ydzICOuPil7bsQ9f(aHbbbEb7JW3cd5hiLkjbdkjF5r4y7ycKE5ygqmz18zGEPHBbYxbet6ZXS3y6fSpI3H4TjX2Btet4T5vqooX7jHZN31eBVnVcI3tcNpVdG27A1BZRG49KW9oGfI59Kla7J49X82ueYBm9YEX7jfGm5n2EZ)cfrEVNCeukazYNhzzpWxEHcLGqASHmrouQuKL9aj1(cFGWGGaVG9r4BHHKpd0lnClq(IMG38kJcHhtyAjueqkAIgiw6fwibuYOqGavr6QtJYbdxWka7Ju4gMnlQnXwHkccLGx2ljDaYuHabQI0v)bsPssWGsYxEeo2oMaPxoMXO8UkkhmCbSqrKpHfbGsbitfUHPMYNJzVRHp5Dng1DgOQqtEFyrmVXrc9z(f2oM8oaAVXLJz4T5vq8UsS9gtqm4Jfc5DiExP3hZBf9V3sWGsYx85rw2d8LxOqjiKgBitavDNbQk0eFlmKO2eBfQmqm4JfcvybyCfqQS6pqkvscgus(YJWX2Xei9YXmgfsL(Cm7DTu8UsVLGbLK3BZRG4noLzK4TPugbStgoY7Xen4n3G3y6fO9EYsXya9V3O19oxpRwauVXrc9z(f2oMk(8il7b(YluOeesJnKjEKqFMFHTJj(Y1ZkkjbdkjpeE4BHHiHIas5PmJKKqzeWoz4OcbcufPRkHIasbEb6KzkgdO)leiqvKUQMq5GHlWlqNmtXya9FHrgXc(r5P6pqkvscgus(YJWX2Xei9YXmGuzvznOKCj9sMaJmIf8vuR(Cm79KDfKJt8EsenqmVXfwibuYW7aO9M3ExJcW437d27ruHM8EbEliK34iH(m)EVI377T5JjiEZ9laQ34iH(m)cBhtEFaV5T3sWGsYx85rw2d8LxOqjiKgBit8iH(m)cBht8TWqWOekcifnrdel9clKakzuiqGQiD1O2eBfQGQcnLwqsqO0Je6Z8xybymeEx9hiLkjbdkjF5r4y7ycKE5ygq4TphZEJPpM3dS9yRu3B2jHShGpV5EYBCKqFMFHTJjVpSiM34YXm8MNP828kiEpzRb8oGgl4fV5g8woVnP3sWGsYZN3voL3lS3y6jR377nJdawauVpyyVN(aEhG6Ehghhq8(G9wcgus(P4Z7J5nVNYB582i4L1yRn5n(njVjEriWVhWBZRG4nMkGWALaDvRu37d4nV9wcgusEVN2KEBEfeVhzf8Pk(8il7b(YluOeesJnKjEKqFMFHTJj(wyiyfSnqvuH7P0aBp2k1tStczpq1PLqraPaVaDYmfJb0)fceOksxvtOCWWf4fOtMPymG(VWiJyb)O8mBMekcifZumCaJ4fIviqGQiD1FGuQKemOK8LhHJTJjq6LJzmketoBwuBITcvwaH1kb6QwPEHabQI0vr5GHlFDd0t9PdoPPqqkCdv)bsPssWGsYxEeo2oMaPxoMXOq4n2rTj2kubvfAkTGKGqPhj0N5VqGavr6P85rw2d8LxOqjiKgBit8iCSDmbsVCmd(wyi)aPujjyqj5RacV95rw2d8LxOqjiKgBit8iH(m)cBhtw8FGYw(RSw5XkwXAba]] )


end
