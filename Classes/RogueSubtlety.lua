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


    spec:RegisterPack( "Subtlety", 20200910, [[dav(LbqiiKhbv0MKiFcvvQmkiuNccAvqaEfe1SqvClja7ss)sIYWueDmOsltc5zOQQPjb6AsqTnjG(Mev04qvLCojQuRtcsAEkc3trTpsL(heOihevvOfkH6HsqmrjQ6IOQsvBecKpIQkLgjeOuNevvWkvKEjeOKzIQkf3ucsStuL(jeOWqHaAPsqQNcPPsQ4QsuHTcbQ(QevYzHaf1Ej6VImyPomvlgkpwutMWLr2miFgQA0G60kTAuvrETcA2KCBsz3a)wLHRqhhvvulhLNRQPt56OY2rv57KQgpuHoVcSEOcMpez)clXvQJev4gj5TOjlAYjl34ozf3cSGfXF(Le1gmss0rpp0XtsuGRrsuuomtr2aj6OpqDUqQJe9powMKOWMn(fQLvg(1G5WQ5tRSF14uUThiZCiRSF1YLjrX4wLXpaKysuHBKK3IMSOjNSCJ7KvClWcwe)lNsuNZGpMefD1kejk8keeqIjrf0NLO4mAuomtr2GOl0hEokMIZOrPrJ0Wiw04ojprx0KfnPevTV9sDKOVrUYGjHuhjV4k1rI6zBpGe9vohEyJysuc4yksilwAsElsQJeLaoMIeYILOz2AeBDjkIJ2CfbSk0cej9Kpeq)xjGJPir0iHu0)iPujZz4j7RpmhBhsG0Bhtl6jIM)rJWOlfnIJgJdcQ(g5kdUYngnsifngheuLphSpCLBmAekr9SThqI(WU40)gBhsstYl)L6irjGJPiHSyjAMTgXwxIIXbbvFyo2oKaj7yaxCvUXOlfD(0WU04Ta7RccAZRf9eZrxKe1Z2EajA2vQKNT9aj1(MevTVLaUgjrHwW(WstYBbL6irjGJPiHSyjAMTgXwxI(JKsLmNHNSV(WCSDibsVDmTONJUGrxk68PHDPXBb2hTUZrxqjQNT9as0SRujpB7bsQ9njQAFlbCnsIcTG9HLMK3cl1rIsahtrczXs0mBnITUenFAyxA8wG9vbbT51IEI5OXn6ciAehT5kcyvbrJel9gZnhpPvjGJPir0LIgJdcQYNd2hUYngncLOE22dirZUsL8SThiP23KOQ9TeW1ijk0c2hwAsElqPosuc4yksilwIMzRrS1LOooqS1O6iXGoMBuL5GHrR7C0ffDPO)rsPsMZWt2xFyo2oKaP3oMw0tmhDrsupB7bKO4v3PHPCbjnjVLtPosuc4yksilwI6zBpGe9HDXP)n2oKKOz2AeBDjQ5kcy1NYmYsgLHbl)mhvjGJPir0LI2CfbSk0cej9Kpeq)xjGJPir0LIwqyCqqvOfis6jFiG(VYinFbF0tenUrxk6FKuQK5m8K91hMJTdjq6TJPf9C0ffDPOTvJs2LelfDbenJ08f8rRB0fOenpiROK5m8K9sEXvAsE5xsDKOeWXuKqwSenZwJyRlrru0MRiGvfensS0Bm3C8KwLaoMIerxkAhhi2Auft5ckTGKbtPh2fN(VYCWWONJM)rxk6FKuQK5m8K91hMJTdjq6TJPf9C08xI6zBpGe9HDXP)n2oKKMK3YTuhjkbCmfjKflrZS1i26su(C26ykQY9uAKThBTbj2zUThi6srJ4OnxraRcTarsp5db0)vc4ykseDPOfegheufAbIKEYhcO)RmsZxWh9erJB0iHu0MRiGv1t(4b083iwLaoMIerxk6FKuQK5m8K91hMJTdjq6TJPf9eZrxWOrcPODCGyRr1fq8TMJTQ1gujGJPir0LIgJdcQ(d0Wo1NoOKGCdUYngDPO)rsPsMZWt2xFyo2oKaP3oMw0tmhn)Jg5ODCGyRrvmLlO0csgmLEyxC6)kbCmfjIgHsupB7bKOpSlo9VX2HK0K8I7KsDKOeWXuKqwSenZwJyRlr)rsPsMZWt2hTUZrZFjQNT9as0hMJTdjq6TJPjnjV4IRuhjQNT9as0h2fN(3y7qsIsahtrczXstAsu6FcKPxQJKxCL6irjGJPiHSyjAMTgXwxIsaIHFq1wnkzxsZXXO1nACJUu0ikAmoiO6pqd7uF6GscYn4k3y0LIgXrJOOfNvZhitaJ5gjsqkxJsyCmq128WfGp6srJOO9SThOMpqMagZnsKGuUgvxqcsT4HTOrcPOH4uQeJYWodpLSvJIEIOXNfvnhhJgHsupB7bKO5dKjGXCJejiLRrstYBrsDKOeWXuKqwSenZwJyRlrru057uItpO(WU40NWuUG(k3y0LIoFNsC6b1FGg2P(0bLeKBWvUXOrcPOHw8WwIrA(c(ONyoACNuI6zBpGeftDNiDqjdMseG0ginjV8xQJe1Z2EajkEoNjwhKoOKJde7myjkbCmfjKflnjVfuQJeLaoMIeYILOz2AeBDjkIJ(hjLkzodpzF9H5y7qcKE7yArR7C0ffnsifnZxrI4Jaw1fIVUGO1n6cCYOry0LIgrrNVtjo9G6pqd7uF6GscYn4k3y0LIgrrJXbbv)bAyN6thusqUbx5gJUu0eGy4hufe0MxlADNJM)tkr9SThqIcDzUNejhhi2AucJCnPj5TWsDKOeWXuKqwSenZwJyRlr)rsPsMZWt2xFyo2oKaP3oMw06ohDrrJesrZ8vKi(iGvDH4RliADJUaNuI6zBpGeDKJTqdwa(eMYFtAsElqPosuc4yksilwIMzRrS1LOyCqqvgLhQO)tqhltvUXOrcPOX4GGQmkpur)NGowMs5JdyeR(MNhg9erJ7KsupB7bKOgmL4ayhhqKGowMKMK3YPuhjQNT9asu2ooQO0cs)ONjjkbCmfjKflnjV8lPosuc4yksilwIMzRrS1LO57uItpO(d0Wo1NoOKGCdUYinFbF0teDHJgjKIgAXdBjgP5l4JEIOXLFjr9SThqIQ)ykbF0csm6pGdYK0K8wUL6irjGJPiHSyjAMTgXwxIsaIHFq0teDbNm6srJXbbv)bAyN6thusqUbx5gLOE22dir1iTJniDqjfxEfjbJCTxAsEXDsPosuc4yksilwI6zBpGeLr(4cWNGuUg9s0mBnITUe1CgEYQ2Qrj7sILIEIOXTw4OrcPOrC0ioAZz4jRctUYGRJzlADJMFnz0iHu0MZWtwfMCLbxhZw0tmhDrtgncJUu0ioApBlFuIaK2sF0ZrJB0iHu0MZWtw1wnkzxsSu06gDrL7Ory0imAKqkAehT5m8KvTvJs2LgZwQOjJw3O5)KrxkAehTNTLpkrasBPp65OXnAKqkAZz4jRARgLSljwkADJUGfmAegncLO5bzfLmNHNSxYlUstAsubb5CktQJKxCL6irjGJPiHSyjAMTgXwxIIOOFJCLbtIk7WZrsupB7bKOd38qPj5TiPosupB7bKOVrUYGLOeWXuKqwS0K8YFPosuc4yksilwI6zBpGen7kvYZ2EGKAFtIQ23saxJKOzXlnjVfuQJeLaoMIeYILOz2AeBDj6BKRmysuDLsI6zBpGeLXbsE22dKu7Bsu1(wc4AKe9nYvgmjKMK3cl1rIsahtrczXs0mBnITUe1wnkzxsSu06gDbgDPOzKMVGp6jIgFwu1CCm6srNpnSlnElW(O1Do6cgDbenIJ2wnk6jIg3jJgHrJaIUijQNT9asug3OXXiPj5TaL6irjGJPiHSyj6nkrFYKOE22dir5ZzRJPijkFUIJKOJS9yRniXoZT9arxk6FKuQK5m8K91hMJTdjq6TJPfTUZrxKeLpNLaUgjr5EknY2JT2Ge7m32dinjVLtPosuc4yksilwIMzRrS1LO85S1XuuL7P0iBp2AdsSZCBpGe1Z2EajA2vQKNT9aj1(MevTVLaUgjrFJCLbNYIxAsE5xsDKOeWXuKqwSe9gLOpzsupB7bKO85S1XuKeLpxXrs0IkC0ihT5kcyv(w8hRsahtrIOrarZ)chnYrBUIawvZFJyPdk9WU40)vc4yksenci6IkC0ihT5kcy1h2fN(e0L5(kbCmfjIgbeDrtgnYrBUIaw1vEMT2GkbCmfjIgbenUtgnYrJBHJgbenIJ(hjLkzodpzF9H5y7qcKE7yArR7C08pAekr5ZzjGRrs03ixzWjdMrp8PestYB5wQJeLaoMIeYILOz2AeBDjkbig(bvbbT51IEI5O5ZzRJPO6BKRm4KbZOh(ucjQNT9as0SRujpB7bsQ9njQAFlbCnsI(g5kdoLfV0K8I7KsDKOeWXuKqwSenZwJyRlrZNg2LgVfyFvqqBETONyoACJgjKI2wnkzxsSu0tmhnUrxk68PHDPXBb2hTUZrZFjQNT9as0SRujpB7bsQ9njQAFlbCnsIcTG9HLMKxCXvQJeLaoMIeYILOz2AeBDj6pskvYCgEY(6dZX2Hei92X0IEo6cgDPOZNg2LgVfyF06ohDbLOE22dirZUsL8SThiP23KOQ9TeW1ijk0c2hwAsEXTiPosuc4yksilwIMzRrS1LOeGy4hufe0Mxl6jMJMpNToMIQVrUYGtgmJE4tjKOE22dirZUsL8SThiP23KOQ9TeW1ijkg3QestYlU8xQJeLaoMIeYILOz2AeBDjkbig(bvbbT51Iw35OXTWrJC0eGy4huzeEcir9SThqI6SSdOKDmgbmPj5f3ck1rI6zBpGe1zzhqPro1tsuc4yksilwAsEXTWsDKOE22dirvlEy7t8tCc8AeWKOeWXuKqwS0K8IBbk1rI6zBpGefZXNoOKX28WxIsahtrczXstAs0rgLpnm3K6i5fxPosupB7bKOVrUYGLOeWXuKqwS0K8wKuhjQNT9as0f8MdS04T)bKOeWXuKqwS0K8YFPosupB7bKOz2ooQwa(04T)bKOeWXuKqwS0K8wqPosuc4yksilwIMzRrS1LOmcIrpSJPOOlfnII2CfbS6iJ0iXAUThOsahtrcjQNT9as0xTzk5arsSzsAsElSuhjkbCmfjKflr9SThqIQ5SHKibDSKGCdwIoYO8PH5w6P8beVef3clnjVfOuhjkbCmfjKflrbUgjrDC4HDM)jOdyPdknE6jMe1Z2EajQJdpSZ8pbDalDqPXtpXKMK3YPuhjQNT9as0XZ2dirjGJPiHSyPjnjkg3QesDK8IRuhjkbCmfjKflrZS1i26s0FKuQK5m8K9rR7C0ffnYrJ4OnxraRIxDNgMYfuLaoMIerxkAhhi2AuDKyqhZnQYCWWO1Do6IIgHsupB7bKOpmhBhsG0BhttAsElsQJe1Z2EajkLHVfGpXOr2Q5aHeLaoMIeYILMKx(l1rIsahtrczXs0mBnITUenFAyxA8wG9vbbT51IEIOXnAKJwqyCqq1Nym3irc7au6h3Hu9nppuI6zBpGe9jgZnsKWoaL(XDijnjVfuQJe1Z2EajkE1DAykxqsuc4yksilwAsElSuhjQNT9asumpp8nhtIsahtrczXstAs0S4L6i5fxPosuc4yksilwIMzRrS1LOikAmoiO6d7ItFs4Gmv5gJUu0yCqq1hMJTdjqYogWfxLBm6srJXbbvFyo2oKaj7yaxCvgP5l4JEI5O5FTWsupB7bKOpSlo9jHdYKeL7P0bbLWNfsEXvAsElsQJeLaoMIeYILOz2AeBDjkgheu9H5y7qcKSJbCXv5gJUu0yCqq1hMJTdjqYogWfxLrA(c(ONyoA(xlSe1Z2Eaj6pqd7uF6GscYnyjk3tPdckHplK8IR0K8YFPosuc4yksilwIMzRrS1LOik63ixzWKO6kv0LIwCwLXnACmQABE4cWhnsifn9pbYufJrUbNoOKbtjXGfGVQ58thl6srBRgfTUZrxKe1Z2EajA2vQKNT9aj1(MevTVLaUgjrP)jqMEPj5TGsDKOeWXuKqwSe1Z2Eaj64DQeJ(JJLjjAMTgXwxIIOOnxraR(WU40NGUm3xjGJPiHef6yjaHJMKxCLMK3cl1rIsahtrczXs0mBnITUeLaed)GO1Do6cCYOlfT4SkJB04yu128WfGp6srNVtjo9G6pqd7uF6GscYn4k3y0LIoFNsC6b1h2fN(KWbzQMHDgE6Jw35OXvI6zBpGe9H5y7qcKSJbCXjnjVfOuhjkbCmfjKflrZS1i26suXzvg3OXXOQT5HlaF0LIgrrNVtjo9G6d7ItFct5c6RCJrxkAehnII2CfbS6dZX2Heizhd4IRsahtrIOrcPOnxraR(WU40NGUm3xjGJPir0iHu057uItpO(WCSDibs2XaU4QmsZxWhTUrxu0im6srJ4Oru00)eitvm1DI0bLmykrasBqvZ5Now0iHu057uItpOIPUtKoOKbtjcqAdQmsZxWhTUrxu0iuI6zBpGe9hOHDQpDqjb5gS0K8woL6irjGJPiHSyjQNT9asunNnKejOJLeKBWs0mBnITUeL5Rir8raR6cXx5gJUu0ioAZz4jRARgLSljwk6jIoFAyxA8wG9vbbT51IgjKIgrr)g5kdMevxPIUu05td7sJ3cSVkiOnVw06ohDEmP54y6hjGiAekrZdYkkzodpzVKxCLMKx(LuhjkbCmfjKflrZS1i26suMVIeXhbSQleFDbrRB08FYOlGOz(kseFeWQUq8vbhZT9arxkAef9BKRmysuDLk6srNpnSlnElW(QGG28ArR7C05XKMJJPFKacjQNT9asunNnKejOJLeKBWstYB5wQJeLaoMIeYILOz2AeBDjkII(nYvgmjQUsfDPOfNvzCJghJQ2MhUa8rxk68PHDPXBb2xfe0MxlADNJUijQNT9as0h2fN(eMYf0lnjV4oPuhjQNT9as0Ng)9LOeWXuKqwS0K8IlUsDKOeWXuKqwSenZwJyRlrnxraR(WU40NGUm3xjGJPir0LIwCwLXnACmQABE4cWhDPOX4GGQ)anSt9Pdkji3GRCJsupB7bKOpmhBhsGKDmGloPj5f3IK6irjGJPiHSyjAMTgXwxIIOOX4GGQpSlo9jHdYuLBm6srBRgLSljwk6jMJUWrJC0MRiGvFomJyqC4PkbCmfjIUu0ikAMVIeXhbSQleFLBuI6zBpGe9HDXPpjCqMKMKxC5VuhjkbCmfjKflrZS1i26sumoiOkM6oHI7TkJ8Sfnsifngheu9hOHDQpDqjb5gCLBm6srJ4OX4GGQpSlo9jmLlOVYngnsifD(oL40dQpSlo9jmLlOVYinFbF0tmhnUtgncLOE22dirhpBpG0K8IBbL6irjGJPiHSyjAMTgXwxIIXbbv)bAyN6thusqUbx5gLOE22dirXu3jsqCSbstYlUfwQJeLaoMIeYILOz2AeBDjkgheu9hOHDQpDqjb5gCLBuI6zBpGefJypXgUa8stYlUfOuhjkbCmfjKflrZS1i26sumoiO6pqd7uF6GscYn4k3Oe1Z2Eajk0Yim1DcPj5f3YPuhjkbCmfjKflrZS1i26sumoiO6pqd7uF6GscYn4k3Oe1Z2EajQdY0BmxLYUsjnjV4YVK6irjGJPiHSyjQNT9as08GS6m2b2Cct5VjrZS1i26suef9BKRmysuDLk6srloRY4gnogvTnpCb4JUu0ikAmoiO6pqd7uF6GscYn4k3y0LIMaed)GQGG28ArR7C08FsjkbbrzlbCnsIMhKvNXoWMtyk)nPj5f3YTuhjkbCmfjKflr9SThqI64Wd7m)tqhWshuA80tmjAMTgXwxIIOOX4GGQpSlo9jHdYuLBm6srNVtjo9G6pqd7uF6GscYn4kJ08f8rpr04oPef4AKe1XHh2z(NGoGLoO04PNystYBrtk1rIsahtrczXsupB7bKO(dZNdOpXCC4yP8XCLenZwJyRlrfegheuL54WXs5J5QKGW4GGQItpiAKqkAbHXbbvZhqWLTLpkTGHjbHXbbv5gJUu0MZWtwfMCLbxhZw0ten)lk6srBodpzvyYvgCDmBrR7C08FYOrcPOru0ccJdcQMpGGlBlFuAbdtccJdcQYngDPOrC0ccJdcQYCC4yP8XCvsqyCqq1388WO1Do6IkC0fq04oz0iGOfegheuftDNiDqjdMseG0gu5gJgjKIgAXdBjgP5l4JEIOl4KrJWOlfngheu9hOHDQpDqjb5gCLrA(c(O1nA(Lef4AKe1Fy(Ca9jMJdhlLpMRKMK3IWvQJeLaoMIeYILOaxJKOAde(NmxTVMdKOE22dir1gi8pzUAFnhinjVfvKuhjkbCmfjKflrZS1i26sumoiO6pqd7uF6GscYn4k3y0iHu0qlEylXinFbF0teDrtkr9SThqIY9uAns7LM0KOVrUYGtzXl1rYlUsDKOeWXuKqwSe9gLOpzsupB7bKO85S1XuKeLpxXrs08DkXPhuFyxC6tchKPAg2z4PpbX8SThWvrR7C04wlNfwIYNZsaxJKOpSizWm6HpLqAsElsQJeLaoMIeYILOz2AeBDjkIIMpNToMIQpSizWm6HpLi6srNpnSlnElW(QGG28ArRB04gDPOfegheufAbIKEYhcO)RmsZxWh9erJB0LIoFNsC6b1FGg2P(0bLeKBWvgP5l4Jw35O5Ve1Z2EajkFoyFyPj5L)sDKOeWXuKqwSe1Z2Eaj64DQeJ(JJLjjkHJgZtU2XbmjAbNuIcDSeGWrtYlUstYBbL6irjGJPiHSyjAMTgXwxIsaIHFq06ohDbNm6srtaIHFqvqqBETO1DoACNm6srJOO5ZzRJPO6dlsgmJE4tjIUu05td7sJ3cSVkiOnVw06gnUrxkAbHXbbvHwGiPN8Ha6)kJ08f8rpr04kr9SThqI(WU40RrkH0K8wyPosuc4yksilwIEJs0NmjQNT9asu(C26yksIYNR4ijA(0WU04Ta7RccAZRfTUZrxWOlGOrC0MRiGvfensS0Bm3C8KwLaoMIerxkAehTJdeBnQAWucAzVLeoitvc4ykseDPOru0MRiGvfoBy6HDXPVsahtrIOlfnII2CfbS6ZHzedIdpvjGJPir0LI(hjLkzodpzF9H5y7qcKE7yArpr08pAegncLO85SeW1ij6dls5td7sJ3cSxAsElqPosuc4yksilwIEJs0NmjQNT9asu(C26yksIYNR4ijA(0WU04Ta7RccAZRf9eZrJB0ihDrrJaI2XbITgvnykbTS3schKPkbCmfjKOz2AeBDjkFoBDmfv5EknY2JT2Ge7m32deDPOrC0MRiGvblEy7nxnKyvc4yksensifT5kcyvHZgMEyxC6ReWXuKiAekr5ZzjGRrs0hwKYNg2LgVfyV0K8woL6irjGJPiHSyjAMTgXwxIYNZwhtr1hwKYNg2LgVfyF0LIgXrJOOnxraRkC2W0d7ItFLaoMIerJesrloRY4gnogvzKMVGpADNJUWrJC0MRiGvFomJyqC4PkbCmfjIgHrxkAehnFoBDmfvFyrYGz0dFkr0iHu0yCqq1FGg2P(0bLeKBWvgP5l4Jw35OXTwu0iHu0)iPujZz4j7RpmhBhsG0BhtlADNJUGrxk68DkXPhu)bAyN6thusqUbxzKMVGpADJg3jJgHsupB7bKOpSlo9jHdYK0K8YVK6irjGJPiHSyjAMTgXwxIYNZwhtr1hwKYNg2LgVfyF0LI2wnkzxsSu0teD(oL40dQ)anSt9Pdkji3GRmsZxWhDPOru0mFfjIpcyvxi(k3Oe1Z2Eaj6d7ItFs4GmjnPjrHwW(WsDK8IRuhjkbCmfjKflrHowcq4Oj5fxjQNT9as0X7ujg9hhltstYBrsDKOeWXuKqwSenZwJyRlrrC0ikAZveWQcNnm9WU40xjGJPir0iHu0ikAmoiO6d7ItFs4Gmv5gJgHrxkAB1OKDjXsrxarZinFbF06gDbgDPOzKMVGp6jI228WKTAu0iGOlsI6zBpGeLXnACmsAsE5VuhjkbCmfjKflr9SThqIY4gnogjrZS1i26suefnFoBDmfv5EknY2JT2Ge7m32deDPO)rsPsMZWt2xFyo2oKaP3oMw06ohDrrxkAehnII2XbITgvz0OAZUTa8Ph2fN(VsahtrIOrcPO)rsPsMZWt2xFyo2oKaP3oMw0fq0E2w(OK4SkJB04yu06ohDrrJWOlfnIIgJdcQ(WU40NeoitvUXOlfTTAuYUKyPO1DoAehDHJg5OrC0ffnci68PHDPXBb2hncJgHrxkAgbXOh2XuKenpiROK5m8K9sEXvAsElOuhjkbCmfjKflrZS1i26sugP5l4JEIOZ3PeNEq9hOHDQpDqjb5gCLrA(c(OroACNm6srNVtjo9G6pqd7uF6GscYn4kJ08f8rpXC0fo6srBRgLSljwk6ciAgP5l4Jw3OZ3PeNEq9hOHDQpDqjb5gCLrA(c(Oro6clr9SThqIY4gnogjnjVfwQJe1Z2Eaj6tzgzjJYWGLFMJKOeWXuKqwS0K8wGsDKOeWXuKqwSenZwJyRlrzeeJEyhtrsupB7bKOVAZuYbIKyZK0K8woL6ir9SThqIs8TFMyUrsuc4yksilwAstAsu(i2VhqYBrtw0KtwUNSGsu9odSa8VeLFqB8ygjIMFfTNT9arR23(AmvIoYoOvrsuCgnkhMPiBq0f6dphftXz0O0OrAyelACNKNOlAYIMmMgtXz0fcSdWtFHAmfNrxarZpkeKiAeS28WOTlAbb5CklApB7bIwTVvJP4m6ci6cnPD8rIOnNHNS0cfD(aI12de9bIUqXzdjr0qhl6YtUbxJP4m6ciA(rHGerxoEkA(bJ0(AmnMIZO53JJuMZir0ye0XOOZNgMBrJr4xWxJMFmNPr7JgCGca2zAqCQO9STh4J(aQb1ykoJ2Z2EGVoYO8PH52mKY)HXuCgTNT9aFDKr5tdZnKNlZ5WRraZT9aXuCgTNT9aFDKr5tdZnKNld6ormfNrJc8Xh(SOz(kIgJdcIer)MBF0ye0XOOZNgMBrJr4xWhTderpYOcy8mBb4JE)OfhGQXuCgTNT9aFDKr5tdZnKNl7b(4dFw6n3(yQNT9aFDKr5tdZnKNl7nYvgCm1Z2EGVoYO8PH5gYZLTG3CGLgV9pqm1Z2EGVoYO8PH5gYZLLz74OAb4tJ3(hiM6zBpWxhzu(0WCd55YE1MPKdejXMjEwOzgbXOh2XuujezUIawDKrAKyn32dujGJPirm1Z2EGVoYO8PH5gYZLP5SHKibDSKGCdMNrgLpnm3spLpG4NXTWXupB7b(6iJYNgMBipxg3tP1inEaUgn74Wd7m)tqhWshuA80tSyQNT9aFDKr5tdZnKNlB8S9aX0ykoJMFposzoJert8rSbrBRgfTbtr7z7yrVF0oF(QCmfvJP4m6cn9g5kdo6fk6X7)ftrrJyWfnFCkaXCmffnbiTL(Oxq05tdZnegt9STh4NhU5H8SqZi6nYvgmjQSdphft9STh4rEUS3ixzWXuCgDHat5HrxiL)J2TOHw2BXupB7bEKNll7kvYZ2EGKAFJhGRrZzXhtXz0fAoq0qCk1GOF9RLHPpA7I2GPOrnYvgmjIUqFMB7bIgXydIwClaF0)Xt0Rfn0XY0h94DQfGp6fkAWzWlaF07hTZNVkhtriSgt9STh4rEUmghi5zBpqsTVXdW1O53ixzWKGNfA(nYvgmjQUsftXz08JJJQbrZ7Ih2WuUGI2TOlc5Oleey0co2cWhTbtrdTS3Ig3jJ(P8beppr7qgXI2GDl6cIC0fccm6fk61IMWXXLrF06xdEbrBWu0achTO53wiLp6Jf9(rdolAUXyQNT9apYZLX4gnogXZcnBRgLSljws3cSeJ08f8tGplQAoowkFAyxA8wG96oxWcaX2QrtG7KiebuumfNrJGbqni6mSdWtrZoZT9arVqrRNIg25JIEKThBTbj2zUThi6NSODGiAnoLTJkkAZz4j7JMBSgt9STh4rEUm(C26ykIhGRrZCpLgz7XwBqIDMB7b4HpxXrZJS9yRniXoZT9aL(rsPsMZWt2xFyo2oKaP3oMMUZfftXz0iq2ES1geDH(m32dGGPO53qg)UpA8lFu0E0zMpgTJDCw0eGy4hen0XI2GPOFJCLbhDHu(pAeJXTkbXI(TvPIMr)iLTOxdH1OrWm3iprVw0zhengfTb7w0)QnQOAm1Z2EGh55YYUsL8SThiP234b4A08BKRm4uw88SqZ85S1XuuL7P0iBp2AdsSZCBpqmfNrxoEseTDrliOfqrRhMarBx0Cpf9BKRm4OlKY)rFSOX4wLGyFm1Z2EGh55Y4ZzRJPiEaUgn)g5kdozWm6HpLGh(CfhnxuHr2CfbSkFl(JvjGJPibcG)fgzZveWQA(BelDqPh2fN(VsahtrceqrfgzZveWQpSlo9jOlZ9vc4yksGakAsKnxraR6kpZwBqLaoMIeiaCNezClmcaX)iPujZz4j7RpmhBhsG0Bhtt3z(JWykoJUqoWVcIfn3Va8r7rJAKRm4OlKYhTEycenJ8m8cWhTbtrtaIHFq0gmJE4tjIPE22d8ipxw2vQKNT9aj1(gpaxJMFJCLbNYINNfAMaed)GQGG28AtmZNZwhtr13ixzWjdMrp8PeXuCgncAb7dhTBrxqKJw)AWhNfD5r5j6cJC06xdo6YJgnIpo7xbf9BKRmyegt9STh4rEUSSRujpB7bsQ9nEaUgndTG9H5zHMZNg2LgVfyFvqqBETjMXfjKSvJs2LelnXmULYNg2LgVfyVUZ8pMIZOlxRbhD5rJ2v)fn0c2hoA3IUGihTJ3xWBrt4ONn1GOly0MZWt2hnIpo7xbf9BKRmyegt9STh4rEUSSRujpB7bsQ9nEaUgndTG9H5zHM)rsPsMZWt2xFyo2oKaP3oM2CblLpnSlnElWEDNlymfNrxoEkApAmUvjiw06Hjq0mYZWlaF0gmfnbig(brBWm6HpLiM6zBpWJ8CzzxPsE22dKu7B8aCnAgJBvcEwOzcqm8dQccAZRnXmFoBDmfvFJCLbNmyg9WNsetXz08Bo90BrpY2JT2GOxq0Usf9bfTbtrZpIa53engLDUNIETOZo3tF0E08BlKYht9STh4rEUmNLDaLSJXiGXZcntaIHFqvqqBEnDNXTWitaIHFqLr4jqm1Z2EGh55YCw2buAKt9um1Z2EGh55YulEy7t8tCc8AeWIPE22d8ipxgMJpDqjJT5HFmnMIZOlMBvcI9XupB7b(kg3QeZpmhBhsG0BhtJNfA(hjLkzodpzVUZfHmInxraRIxDNgMYfuLaoMIeLCCGyRr1rIbDm3OkZbd1DUiegt9STh4RyCRsG8Czug(wa(eJgzRMdeXupB7b(kg3Qeipx2tmMBKiHDak9J7qINfAoFAyxA8wG9vbbT51MaxKfegheu9jgZnsKWoaL(XDivFZZdJPE22d8vmUvjqEUm8Q70WuUGIPE22d8vmUvjqEUmmpp8nhlMgtXz0fYDkXPh8XuCgD54POlVdYu0heubGplIgJGogfTbtrdTS3IgfMJTdjq0O2X0IgIDArRZXaU4IoFA0h9cQXupB7b(Aw8ZpSlo9jHdYepCpLoiOe(SygxEwOzeHXbbvFyxC6tchKPk3yjmoiO6dZX2Heizhd4IRYnwcJdcQ(WCSDibs2XaU4QmsZxWpXm)RfoMIZOrC5aOO)J2vmYfdIMBmAmk7CpfTEkA7UHrJc7ItF0iOlZ9imAUNIgDGg2P(OpiOcaFwengbDmkAdMIgAzVfnkmhBhsGOrTJPfne70IwNJbCXfD(0Op6fuJPE22d81S4rEUSFGg2P(0bLeKBW8W9u6GGs4ZIzC5zHMX4GGQpmhBhsGKDmGlUk3yjmoiO6dZX2Heizhd4IRYinFb)eZ8Vw4yQNT9aFnlEKNll7kvYZ2EGKAFJhGRrZ0)eitppl0mIEJCLbtIQRuLeNvzCJghJQ2MhUa8iHe9pbYufJrUbNoOKbtjXGfGVQ58thRKTAKUZfftXz0iW7urdDSO15yaxCrpYOca9kF06xdoAu4YhnJCXGO1dtGObNfnJdawa(Orrq1yQNT9aFnlEKNlB8ovIr)XXYepqhlbiC0MXLNfAgrMRiGvFyxC6tqxM7ReWXuKiMIZOlhpfTohd4Il6rgfn6v(O1dtGO1trd78rrBWu0eGy4heTEyYGjw0qStl6X7ulaF06xd(4SOrrqrFSO5N4ElA8eGyUsnOgt9STh4RzXJ8CzpmhBhsGKDmGloEwOzcqm8d0DUaNSK4SkJB04yu128WfGVu(oL40dQ)anSt9Pdkji3GRCJLY3PeNEq9HDXPpjCqMQzyNHNEDNXnMIZOlhpfn6anSt9rFGOZ3PeNEq0i2HmIfn0YElAEx8WgMYfecJMdOO)JwpfTZOOXFlaF02f94ngTohd4IlAhiIwCrdolAyNpkAuyxC6JgbDzUVgt9STh4RzXJ8Cz)anSt9Pdkji3G5zHMfNvzCJghJQ2MhUa8Lqu(oL40dQpSlo9jmLlOVYnwcXiYCfbS6dZX2Heizhd4IRsahtrcKqYCfbS6d7ItFc6YCFLaoMIeiHu(oL40dQpmhBhsGKDmGlUkJ08f86weclHyer)tGmvXu3jshuYGPebiTbvnNF6yiHu(oL40dQyQ7ePdkzWuIaK2GkJ08f86wecJP4mA(bOODH4J2zu0CJ8e9d2rkAdMI(au06xdoA1PNElAD0P81OlhpfTEyceTyWcWhnK)gXI2GDq0fccmAbbT51I(yrdol63ixzWKiA9RbFCw0oyq0fccSgt9STh4RzXJ8CzAoBijsqhlji3G5jpiROK5m8K9Z4YZcnZ8vKi(iGvDH4RCJLqS5m8KvTvJs2Lelnr(0WU04Ta7RccAZRHesi6nYvgmjQUsvkFAyxA8wG9vbbT510DopM0CCm9JeqGWykoJMFakAWfTleF06xLkAXsrRFn4feTbtrdiC0IM)t(8en3trxOav(Opq0y3)rRFn4JZI2bdIUqqGr7ar0Gl63ixzW1yQNT9aFnlEKNltZzdjrc6yjb5gmpl0mZxrI4Jaw1fIVUaD5)KfaZxrI4Jaw1fIVk4yUThOeIEJCLbtIQRuLYNg2LgVfyFvqqBEnDNZJjnhht)ibeXupB7b(Aw8ipx2d7ItFct5c65zHMr0BKRmysuDLQK4SkJB04yu128WfGVu(0WU04Ta7RccAZRP7CrXupB7b(Aw8ipx2tJ)(XuCgD5An4Orrq8e9cfn4SODfJCXGOfhG4jAUNIwNJbCXfT(1GJg9kF0CJ1yQNT9aFnlEKNl7H5y7qcKSJbCXXZcnBUIaw9HDXPpbDzUVsahtrIsIZQmUrJJrvBZdxa(syCqq1FGg2P(0bLeKBWvUXyQNT9aFnlEKNl7HDXPpjCqM4zHMregheu9HDXPpjCqMQCJLSvJs2LelnXCHr2CfbS6ZHzedIdpvjGJPirjeX8vKi(iGvDH4RCJXupB7b(Aw8ipx24z7b4zHMX4GGQyQ7ekU3QmYZgsiHXbbv)bAyN6thusqUbx5glHymoiO6d7ItFct5c6RCJiHu(oL40dQpSlo9jmLlOVYinFb)eZ4ojcJPE22d81S4rEUmm1DIeehBapl0mgheu9hOHDQpDqjb5gCLBmM6zBpWxZIh55YWi2tSHlappl0mgheu9hOHDQpDqjb5gCLBmM6zBpWxZIh55YGwgHPUtWZcnJXbbv)bAyN6thusqUbx5gJPE22d81S4rEUmhKP3yUkLDLINfAgJdcQ(d0Wo1NoOKGCdUYngt9STh4RzXJ8CzCpLwJ04HGGOSLaUgnNhKvNXoWMtyk)nEwOze9g5kdMevxPkjoRY4gnogvTnpCb4lHimoiO6pqd7uF6GscYn4k3yjcqm8dQccAZRP7m)NmM6zBpWxZIh55Y4EkTgPXdW1OzhhEyN5Fc6aw6GsJNEIXZcnJimoiO6d7ItFs4Gmv5glLVtjo9G6pqd7uF6GscYn4kJ08f8tG7KXuCgncoXgen74WdRgenJtrrFqrBWCAyl0sIO1Cd(JgJuN(c1Olhpfn0XIMFamC8erNzRXt0Nbtm97trRFn4OrVYhTBrxuHro6388Wp6JfnUfg5O1VgC0U6VOlwDNiAUXAm1Z2EGVMfpYZLX9uAnsJhGRrZ(dZNdOpXCC4yP8XCfpl0SGW4GGQmhhowkFmxLeegheuvC6biHKGW4GGQ5di4Y2YhLwWWKGW4GGQCJLmNHNSkm5kdUoMTj4FrLmNHNSkm5kdUoMnDN5)KiHeIeegheunFabx2w(O0cgMeegheuLBSeIfegheuL54WXs5J5QKGW4GGQV55H6oxuHlaCNebiimoiOkM6or6GsgmLiaPnOYnIesqlEylXinFb)efCsewcJdcQ(d0Wo1NoOKGCdUYinFbVU8RyQNT9aFnlEKNlJ7P0AKgpaxJM1gi8pzUAFnhetXz0LNGCoLfnKRuyEEy0qhlAU3Xuu0RrAFHA0LJNIw)AWrJoqd7uF0hu0LNCdUgt9STh4RzXJ8CzCpLwJ0EEwOzmoiO6pqd7uF6GscYn4k3isibT4HTeJ08f8tu0KX0ykoJMF))eitFm1Z2EGVs)tGm9Z5dKjGXCJejiLRr8SqZeGy4huTvJs2L0CCuxClHimoiO6pqd7uF6GscYn4k3yjeJiXz18bYeWyUrIeKY1OeghduTnpCb4lHipB7bQ5dKjGXCJejiLRr1fKGulEydjKG4uQeJYWodpLSvJMaFwu1CCeHXupB7b(k9pbY0J8CzyQ7ePdkzWuIaK2aEwOzeLVtjo9G6d7ItFct5c6RCJLY3PeNEq9hOHDQpDqjb5gCLBejKGw8WwIrA(c(jMXDYyQNT9aFL(Naz6rEUm8CotSoiDqjhhi2zWXupB7b(k9pbY0J8CzqxM7jrYXbITgLWixJNfAgX)iPujZz4j7RpmhBhsG0Bhtt35IqcjMVIeXhbSQleFDb6wGtIWsikFNsC6b1FGg2P(0bLeKBWvUXsicJdcQ(d0Wo1NoOKGCdUYnwIaed)GQGG28A6oZ)jJPE22d8v6FcKPh55Yg5yl0GfGpHP834zHM)rsPsMZWt2xFyo2oKaP3oMMUZfHesmFfjIpcyvxi(6c0TaNmM6zBpWxP)jqMEKNlZGPeha74aIe0XYepl0mgheuLr5Hk6)e0XYuLBejKW4GGQmkpur)NGowMs5JdyeR(MNhobUtgt9STh4R0)eitpYZLX2XrfLwq6h9mft9STh4R0)eitpYZLP)ykbF0csm6pGdYepl0C(oL40dQ)anSt9Pdkji3GRmsZxWprHrcjOfpSLyKMVGFcC5xXupB7b(k9pbY0J8CzAK2XgKoOKIlVIKGrU2ZZcntaIHFWefCYsyCqq1FGg2P(0bLeKBWvUXykoJgb7tjIUqt(4cWhncs5A0hn0XIMWrkZzu0mhGNI(yrpCvQOX4GGEEIEHIE8(FXuunA(rLEFWhTXgeTDrJNSOnykA1PNEl68DkXPhenM)Ki6deTZNVkhtrrtasBPVgt9STh4R0)eitpYZLXiFCb4tqkxJEEYdYkkzodpz)mU8SqZMZWtw1wnkzxsS0e4wlmsiHyeBodpzvyYvgCDmB6YVMejKmNHNSkm5kdUoMTjMlAsewcXE2w(OebiTL(zCrcjZz4jRARgLSljws3Ik3ieHiHeInNHNSQTAuYU0y2sfnPU8FYsi2Z2YhLiaPT0pJlsizodpzvB1OKDjXs6wWcIqegtJP4mAe0c2hMyFm1Z2EGVcTG9HNhVtLy0FCSmXd0XsachTzCJP4mAeSiAmAUXO5DXdBykxqrVqrVw07hTJDCw02fnJde9Xz1Ol)fn4SO5EkAEloAbhBb4JU8oit8e9cfT5kcyKi6fyx0L3zdJgf2fN(Am1Z2EGVcTG9HrEUmg3OXXiEwOzeJiZveWQcNnm9WU40xjGJPibsiHimoiO6d7ItFs4Gmv5gryjB1OKDjXsfaJ08f86wGLyKMVGFcBZdt2QriGIIP4m6cfoLTIZSfGp6JZ(vqrxEhKPOpq0MZWt2hTb7w06xLkA1Yhfn0XI2GPOfCm32de9bfnVlEydt5cINOzeeJE4OfCSfGp6rhiiTnxJUqHtzR4SO9pA1bWhT)rxeYrBodpzF0IlAWzrd78rrZ7Ih2WuUGIMBmA9RbhDHMgvB2TfGpAuyxC6)Ormhqr)h9GJlAyNpkAEx8Wg)UpAeCcGNCqMI2UdH1yQNT9aFfAb7dJ8CzmUrJJr8KhKvuYCgEY(zC5zHMreFoBDmfv5EknY2JT2Ge7m32du6hjLkzodpzF9H5y7qcKE7yA6oxujeJihhi2AuLrJQn72cWNEyxC6)kbCmfjqcPFKuQK5m8K91hMJTdjq6TJPvaE2w(OK4SkJB04yKUZfHWsicJdcQ(WU40NeoitvUXs2Qrj7sIL0DgXfgzexeciFAyxA8wG9ieHLyeeJEyhtrXuCgDHMGy0dhnVlEydt5ckAYzQbrVqrVw06xLkAchhxgfTGJTa8rJoqd7uFn6YFrBWUfnJGy0dh9cfn6v(OXt2hnJCXGOxq0gmfnGWrl6c)1yQNT9aFfAb7dJ8CzmUrJJr8SqZmsZxWpr(oL40dQ)anSt9Pdkji3GRmsZxWJmUtwkFNsC6b1FGg2P(0bLeKBWvgP5l4NyUWLSvJs2LelvamsZxWRB(oL40dQ)anSt9Pdkji3GRmsZxWJCHJPE22d8vOfSpmYZL9uMrwYOmmy5N5OyQNT9aFfAb7dJ8CzVAZuYbIKyZepl0mJGy0d7ykkM6zBpWxHwW(WipxgX3(zI5gftJP4mAuJCLbhDHCNsC6bFmfNrJGnPgjw0i4oBDmfft9STh4RVrUYGtzXpZNZwhtr8aCnA(HfjdMrp8Pe8WNR4O58DkXPhuFyxC6tchKPAg2z4PpbX8SThWv6oJBTCw4ykoJgb3b7dhnhqr)hTEkANrr7yhNfTDrN9XOpq0L3bzk6mSZWtFnAemaQbrRhMarJGwGi6Yf5db0)rVF0o2XzrBx0moq0hNvJPE22d813ixzWPS4rEUm(CW(W8SqZiIpNToMIQpSizWm6HpLOu(0WU04Ta7RccAZRPlULeegheufAbIKEYhcO)RmsZxWpbULY3PeNEq9hOHDQpDqjb5gCLrA(cEDN5FmfNrJaVtfn0XIgf2fNEnsjIg5OrHDXP)n2oKIMdOO)JwpfTZOODSJZI2UOZ(y0hi6Y7GmfDg2z4PVgncga1GO1dtGOrqlqeD5I8Ha6)O3pAh74SOTlAghi6JZQXupB7b(6BKRm4uw8ipx24DQeJ(JJLjEGowcq4OnJlpeoAmp5AhhWMl4KXupB7b(6BKRm4uw8ipx2d7ItVgPe8SqZeGy4hO7CbNSebig(bvbbT510Dg3jlHi(C26ykQ(WIKbZOh(uIs5td7sJ3cSVkiOnVMU4wsqyCqqvOfis6jFiG(VYinFb)e4gtXz0fccmAgXpZTmsJawHA0L3bzkA3IwD6JUqqGrJniAbb5CkRgnIr5WmMNT9arVF0E05BCq0qStlAdMI(nYvWKiAOfSpmXIo7kv0qhlADqqLpAyhiulaFfHXupB7b(6BKRm4uw8ipxgFoBDmfXdW1O5hwKYNg2LgVfypp85koAoFAyxA8wG9vbbT510DUGfaInxraRkiAKyP3yU54jTkbCmfjkHyhhi2Au1GPe0YEljCqMQeWXuKOeImxraRkC2W0d7ItFLaoMIeLqK5kcy1NdZigehEQsahtrIs)iPujZz4j7RpmhBhsG0BhtBc(JqegtXz0fccmAgXpZTmsJawHA0L3bzk6dOgengbDmkAOfSpmX(OxOO1trd78rr7AJrBUIa2hTderpY2JT2GOzN52EGAm1Z2EGV(g5kdoLfpYZLXNZwhtr8aCnA(HfP8PHDPXBb2ZdFUIJMZNg2LgVfyFvqqBETjMXf5IqaooqS1OQbtjOL9ws4GmvjGJPibpl0mFoBDmfv5EknY2JT2Ge7m32ducXMRiGvblEy7nxnKyvc4yksGesMRiGvfoBy6HDXPVsahtrcegtXz0LR1GJU8oBy0OWU40h9budIU8oitrRhMarZ7Ih2WuUGIw)Qur)MpiAUXA0LJNIwWXwa(OrhOHDQp6JfTJD8rrBWm6HpLOgD5YxlAOJfnVi4rJXbbfT(1GJUiK5fbVgt9STh4RVrUYGtzXJ8CzpSlo9jHdYepl0mFoBDmfvFyrkFAyxA8wG9LqmImxraRkC2W0d7ItFLaoMIeiHK4SkJB04yuLrA(cEDNlmYMRiGvFomJyqC4PkbCmfjqyjeZNZwhtr1hwKmyg9WNsGesyCqq1FGg2P(0bLeKBWvgP5l41Dg3AriH0pskvYCgEY(6dZX2Hei92X00DUGLY3PeNEq9hOHDQpDqjb5gCLrA(cEDXDsegtXz0fZXarZinFblaF0L3bz6JgJGogfTbtrBodpzrlw6JEHIg9kF06pa)olAmkAg5IbrVGOTvJQXupB7b(6BKRm4uw8ipx2d7ItFs4GmXZcnZNZwhtr1hwKYNg2LgVfyFjB1OKDjXstKVtjo9G6pqd7uF6GscYn4kJ08f8LqeZxrI4Jaw1fIVYngtJP4mAuJCLbtIOl0N52EGyQNT9aF9nYvgmjqEUSx5C4HnIftXz08dqrJAKRm4Y4Zb7dhTZOO5g5jAUNIgf2fN(3y7qkA7IgJae0ArdXoTOnyk6r))LpkASdW9r7ar0iOfiIUCr(qa9pprt8rGOxOO1tr7mkA3IwZXXOleey0igIDArBWu0JmkFAyUfDHcu5rynM6zBpWxFJCLbtI5h2fN(3y7qINfAgXMRiGvHwGiPN8Ha6)kbCmfjqcPFKuQK5m8K91hMJTdjq6TJPnb)ryjeJXbbvFJCLbx5grcjmoiOkFoyF4k3icJP4mAe0c2hoA3IM)ihDHGaJw)AWhNfD5rJUSOliYrRFn4OlpA06xdoAuyo2oKarRZXaU4IgJdckAUXOTlANVBfr)NgfDHGaJwV)gf9VgNB7b(Am1Z2EGV(g5kdMeipxw2vQKNT9aj1(gpaxJMHwW(W8SqZyCqq1hMJTdjqYogWfxLBSu(0WU04Ta7RccAZRnXCrXuCgn)O6VOFhII2UOHwW(Wr7w0fe5Oleey06xdoAch9SPgeDbJ2CgEY(A0ig11OO9p6JZ(vqr)g5kdUIWyQNT9aF9nYvgmjqEUSSRujpB7bsQ9nEaUgndTG9H5zHM)rsPsMZWt2xFyo2oKaP3oM2CblLpnSlnElWEDNlymfNrJGwW(Wr7w0fe5Oleey06xd(4SOlpkprxyKJw)AWrxEuEI2bIOlWO1VgC0LhnAhYiw0i4oyF4Opw06atrJGw2BrxEhKPOroAEx8W2hncoHNCqMIPE22d813ixzWKa55YYUsL8SThiP234b4A0m0c2hMNfAoFAyxA8wG9vbbT51Myg3caXMRiGvfensS0Bm3C8KwLaoMIeLW4GGQ85G9HRCJimMIZOlhpfn)w1DAykxqrF8rSOrHDXP)n2oKI2bIOrTJPfT(1GJUiKJgbsmOJ5gfTBrxu0hlAf9F0MZWt2xJPE22d813ixzWKa55YWRUtdt5cINfA2XbITgvhjg0XCJQmhmu35Ik9JKsLmNHNSV(WCSDibsVDmTjMlkMIZO5hTOlkAZz4j7Jw)AWrJszgzrRdLHbl)mhf9qIgJMBmAe0cerxUiFiG(pASbrNhKvlaF0OWU40)gBhs1yQNT9aF9nYvgmjqEUSh2fN(3y7qIN8GSIsMZWt2pJlpl0S5kcy1NYmYsgLHbl)mhvjGJPirjZveWQqlqK0t(qa9FLaoMIeLeegheufAbIKEYhcO)RmsZxWpbUL(rsPsMZWt2xFyo2oKaP3oM2CrLSvJs2LelvamsZxWRBbgtXz0LR1Gpol6Yt0iXIg1yU54jTODGiA(hDH2bd)OpOOlw5ck6feTbtrJc7It)h9ArVF06pMbhn3Va8rJc7It)BSDif9bIM)rBodpzFnM6zBpWxFJCLbtcKNl7HDXP)n2oK4zHMrK5kcyvbrJel9gZnhpPvjGJPirjhhi2Auft5ckTGKbtPh2fN(VYCWWz(x6hjLkzodpzF9H5y7qcKE7yAZ8pMIZOrqhl6r2ES1gen7m32dWt0CpfnkSlo9VX2Hu0hFelAu7yArJlcJw)AWrxUkuI2X7l4TO5gJ2UOly0MZWt2Zt0fHWOxOOrqLRO3pAghaSa8rFqqrJ4deTdgeTRDCal6dkAZz4j7riprFSO5pcJ2UO1CCC1wCGIg9kF0eoAe43deT(1GJMFaq8TMJTQ1ge9bIM)rBodpzF0iUGrRFn4OlEnuewJPE22d813ixzWKa55YEyxC6FJTdjEwOz(C26ykQY9uAKThBTbj2zUThOeInxraRcTarsp5db0)vc4yksusqyCqqvOfis6jFiG(VYinFb)e4IesMRiGv1t(4b083iwLaoMIeL(rsPsMZWt2xFyo2oKaP3oM2eZfejKCCGyRr1fq8TMJTQ1gujGJPirjmoiO6pqd7uF6GscYn4k3yPFKuQK5m8K91hMJTdjq6TJPnXm)r2XbITgvXuUGslizWu6HDXP)ReWXuKaHXupB7b(6BKRmysG8CzpmhBhsG0BhtJNfA(hjLkzodpzVUZ8pM6zBpWxFJCLbtcKNl7HDXP)n2oKKO)iLL8wubIR0KMuc]] )


end
