-- RogueSubtlety.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'ROGUE' then
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
        find_weakness = 19234, -- 91023
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
        relentless = 3460, -- 196029
        gladiators_medallion = 3457, -- 208683
        adaptation = 3454, -- 214027

        smoke_bomb = 1209, -- 212182
        shadowy_duel = 153, -- 207736
        silhouette = 856, -- 197899
        maneuverability = 3447, -- 197000
        veil_of_midnight = 136, -- 198952
        dagger_in_the_dark = 846, -- 198675
        thiefs_bargain = 146, -- 212081
        phantom_assassin = 143, -- 216883
        shiv = 3450, -- 248744
        cold_blood = 140, -- 213981
        death_from_above = 3462, -- 269513
        honor_among_thieves = 3452, -- 198032
    } )

    -- Auras
    spec:RegisterAuras( {
    	alacrity = {
            id = 193538,
            duration = 20,
            max_stack = 5,
        },
        cheap_shot = {
            id = 1833,
            duration = 1,
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
        },
        deepening_shadows = {
            id = 185314,
        },
        evasion = {
            id = 5277,
        },
        feeding_frenzy = {
            id = 242705,
            duration = 30,
            max_stack = 3,
        },
        feint = {
            id = 1966,
            duration = 5,
            max_stack = 1,
        },
        find_weakness = {
            id = 91021,
            duration = 10,
            max_stack = 1,
        },
        fleet_footed = {
            id = 31209,
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
        nightblade = {
            id = 195452,
            duration = function () return talent.deeper_stratagem.enabled and 18 or 16 end,
            tick_time = function () return 2 * haste end,
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
        shadow_gestures = {
            id = 257945,
            duration = 15
        },
        shadows_grasp = {
            id = 206760,
            duration = 8.001,
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
        vanish = {
            id = 11327,
            duration = 3,
            max_stack = 1,
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

            if subtype:sub( 1, 5 ) == 'SWING' and not multistrike then
                if subtype == 'SWING_MISSED' then
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
        if resource == 'combo_points' then
            if amt > 0 then
                gain( 6 * amt, "energy" )
            end

            if level < 116 and amt > 0 and equipped.denial_of_the_halfgiants then
                if buff.shadow_blades.up then
                    buff.shadow_blades.expires = buff.shadow_blades.expires + 0.2 * amt
                end
            end

            if talent.alacrity.enabled and amt >= 5 then
                addStack( "alacrity", 20, 1 )
            end

            if talent.secret_technique.enabled then
                cooldown.secret_technique.expires = max( 0, cooldown.secret_technique.expires - amt )
            end

            cooldown.shadow_blades.expires = max( 0, cooldown.shadow_blades.expires - ( amt * 1.5 ) )

            if level < 116 and amt > 0 and set_bonus.tier21_2pc > 0 then
                if cooldown.symbols_of_death.remains > 0 then
                    cooldown.symbols_of_death.expires = cooldown.symbols_of_death.expires - ( 0.2 * amt )
                end
            end
        end
    end

    spec:RegisterHook( 'spend', comboSpender )
    -- spec:RegisterHook( 'spendResources', comboSpender )


    spec:RegisterStateExpr( "mantle_duration", function ()
        if level > 115 then return 0 end

        if stealthed.mantle then return cooldown.global_cooldown.remains + 5
        elseif buff.master_assassins_initiative.up then return buff.master_assassins_initiative.remains end
        return 0
    end )


    spec:RegisterStateExpr( "priority_rotation", function ()
        return false
    end )


    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.mantle and ( not a or a.startsCombat ) then
            if level < 116 and stealthed.mantle and equipped.mantle_of_the_master_assassin then
                applyBuff( "master_assassins_initiative", 5 )
                -- revisit for subterfuge?
            end

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
                applyDebuff( 'target', "shadows_grasp", 8 )
                if azerite.perforate.enabled and buff.perforate.up then
                    -- We'll assume we're attacking from behind if we've already put up Perforate once.
                    addStack( "perforate", nil, 1 )
                    gainChargeTime( "shadow_blades", 0.5 )
                end
            	gain( buff.shadow_blades.up and 2 or 1, 'combo_points')
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
              applyDebuff( 'target', 'blind', 60)
            end,
        },


        cheap_shot = {
            id = 1833,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () 
                if buff.shot_in_the_dark.up then return 0 end
                return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132092,

            handler = function ()
            	if talent.find_weakness.enabled then
            		applyDebuff( 'target', 'find_weakness' )
            	end
            	if talent.prey_on_the_weak.enabled then
                    applyDebuff( 'target', 'prey_on_the_weak' )
                end
                if talent.subterfuge.enabled then
                	applyBuff( 'subterfuge' )
                end

                applyDebuff( 'target', 'cheap_shot' )
                removeBuff( "shot_in_the_dark" )

                gain( 2 + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
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
                applyBuff( 'cloak_of_shadows', 5 )
            end,
        },


        crimson_vial = {
            id = 185311,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            toggle = "cooldowns",

            spend = function () return 30 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 1373904,

            handler = function ()
                applyBuff( 'crimson_vial', 6 )
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
            	applyBuff( 'evasion', 10 )
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
                applyBuff( 'feint', 5 )
            end,
        },


        gloomblade = {
            id = 200758,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            talent = 'gloomblade',

            startsCombat = true,
            texture = 1035040,

            handler = function ()
            applyDebuff( 'target', "shadows_grasp", 8 )
            	if buff.stealth.up then
            		removeBuff( "stealth" )
            	end
            	gain( buff.shadow_blades.up and 2 or 1, 'combo_points' )
            end,
        },


        kick = {
            id = 1766,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            toggle = 'interrupts', 
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

                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },


        marked_for_death = {
            id = 137619,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            talent = 'marked_for_death', 

            toggle = "cooldowns",

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return settings.mfd_waste or combo_points.current == 0, "combo_point (" .. combo_points.current .. ") waste not allowed"
            end,

            handler = function ()
                gain( 5, 'combo_points')
                applyDebuff( 'target', 'marked_for_death', 60 )
            end,
        },


        nightblade = {
            id = 195452,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 25 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            cycle = "nightblade",

            startsCombat = true,
            texture = 1373907,

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end
                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )

                if azerite.nights_vengeance.enabled then applyBuff( "nights_vengeance" ) end

                applyDebuff( "target", "nightblade", 8 + 2 * ( combo - 1 ) )
                spend( combo, "combo_points" )
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
                applyDebuff( 'target', 'sap', 60 )
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

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then addStack( "alacrity", 20, 1 ) end                
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
            	applyBuff( 'shadow_blades', 20 )
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

            ready = function () return max( energy.time_to_max, buff.shadow_dance.remains ) end,

            usable = function () return not stealthed.all end,
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
            	applyBuff( "shadowstep", 2 )
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
                gain( buff.shadow_blades.up and 3 or 2, 'combo_points' )
                if azerite.blade_in_the_shadows.enabled then addStack( "blade_in_the_shadows", nil, 1 ) end

                if talent.find_weakness.enabled then
                    applyDebuff( "target", "find_weakness" )
                end
            end,
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
                applyBuff( 'shroud_of_concealment', 15 )
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
            	gain( active_enemies + ( buff.shadow_blades.up and 1 or 0 ), 'combo_points')
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

            talent = 'shuriken_tornado',

            startsCombat = true,
            texture = 236282,

            handler = function ()
             	applyBuff( 'shuriken_tornado', 4 )
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
                applyBuff( 'sprint', 8 )
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
                applyBuff( 'stealth' )
                if talent.shot_in_the_dark.enabled then applyBuff( "shot_in_the_dark" ) end

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

            startsCombat = false,
            texture = 252272,

            handler = function ()
                gain ( 40, 'energy')
                applyBuff( "symbols_of_death" )
            end,
        },


        tricks_of_the_trade = {
            id = 57934,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 236283,

            handler = function ()
                applyBuff( 'tricks_of_the_trade' )
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

            usable = function () return boss and group end,
            handler = function ()
                applyBuff( 'vanish', 3 )
                applyBuff( "stealth" )
                emu_stealth_change = query_time
            end,
        },


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]
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


    spec:RegisterSetting( "mfd_waste", false, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If checked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
        width = 1.5
    } )  


    spec:RegisterPack( "Subtlety", 20200212, [[davOMbqiispcIQnjQ8jvikJckQtbfzvQiQxbLAwOQClrbTlj9lrPggeXXqvSmkKNHQuttfHRjk02uHW3eLOgNOaDoikvRtfrAEQiDpiSpku)dIsjDqikYcvH6HOkPjkkPlcrPyJquYhfLqzKqukXjHOOwPkQxkkH0mfLqCtrb0orv1pfLq1qHOWsfLipfQMQOORkkbBvfr8vviYzHOuQ9sP)kYGL6WuTyi9yjMmHlJSzq9zvQrdYPvSAviQETky2eDBkA3Q63knCvYXffGLJYZbMoPRJkBhk57uW4rvIZlQA9QqA(qH9lSLhBMwCHRKLFJqIribjgXJrvJmkJgDclUM)IS4xE5GFtw83njloohQkjnVf)YZlxxyZ0IdwowHS4qQEboPzN99OqCO1YAMnym5KUo7xyoSMnymlzBXr5gPIm)wulUWvYYVriXiKGeJ4XOQrgLrJ4Dw2I7Ck0YS44JjVAXHgHGElQfxqGIfh5rJZHQssZhDwAV5O4mYJgs1lWjn7SVhfIdTwwZSbJjN01z)cZH1SbJzj74mYJgzrOmoNLpAEmIVOncjgHK4CCg5rZRq(FtGtACg5rNHrJmjeKi6SOt5q06gTGGDoPgTx0z)OLdqRXzKhDggDwImxSir0QZUjnnWrx2xm6SF07hDgOZoqIOHxw0zLCfQgNrE0zy0itcbjIolaOOrMvYeuT4YbOaBMwCGsUuHiHntl)8yZ0ItVJkjH9ylEHnkXg3IJ5OvxsVwHNxKmq(HNaGk9oQKerJbgrdUiPmPo7MuqfaXXMd0Na6YmJ(0O5D0yk6CrJ5Or5GHRaLCPcv5UIgdmIgLdgUIL)daQYDfnMS4ErN9T4aixSgakBoqw1YVr2mT407Ossyp2IxyJsSXT4OCWWvaehBoqFsx27ITYDfDUOlRj6MU25vqvqWtz0Opfr0gzX9Io7BXlUuM8Io7NKdqT4YbOP3njlo88daYQw(5Tntlo9oQKe2JT4f2OeBClo4IKYK6SBsbvaehBoqFcOlZmAerFIOZfDznr301oVcI2yerFclUx0zFlEXLYKx0z)KCaQfxoan9UjzXHNFaqw1Y)jSzAXP3rLKWESfVWgLyJBXlRj6MU25vqvqWtz0Opfr08eDggnMJwDj9Avq0fXsaL5QFtMv6DujjIox0yoAuoy4kw(paOk3v0yGr0(rj2OuvHOe8WaAs4FHQ07OsseDUOrA0QlPxRcNDibGCXAOsVJkjr05IgPrRUKETc4qvIbZDtv6DujjIox0GlsktQZUjfubqCS5a9jGUmZOpnAEhnMIgtwCVOZ(w8IlLjVOZ(j5aulUCaA6DtYIdp)aGSQL)mAZ0ItVJkjH9ylEHnkXg3I7hLyJs1lIbVmxPkZ)drBmIOnk6CrdUiPmPo7MuqfaXXMd0Na6YmJ(uerBKf3l6SVf)wURjQ0fKvT8Fe2mT407Ossyp2I7fD23IdGCXAaOS5azXlSrj24wC1L0RvavyKMuQa9tgahvP3rLKi6CrRUKETcpVizG8dpbav6DujjIox0ccLdgUcpVizG8dpbavgz6ZdI(0O5j6CrdUiPmPo7MuqfaXXMd0Na6YmJgr0gfDUO1XKs6MedfDggnJm95brBC0hHfVKViPK6SBsbw(5XQw(ZY2mT407Ossyp2IxyJsSXT4inA1L0RvbrxelbuMR(nzwP3rLKi6Cr7hLyJsvuPlO08jfIsaixSgavM)hIgr08o6CrdUiPmPo7MuqfaXXMd0Na6YmJgr082I7fD23IdGCXAaOS5azvl)zqBMwC6DujjShBXlSrj24wCSC24OsQYbO0fBw2O5tSvDD2p6CrJ5OvxsVwHNxKmq(HNaGk9oQKerNlAbHYbdxHNxKmq(HNaGkJm95brFA08engyeT6s61QbYV230bkXQ07OsseDUObxKuMuNDtkOcG4yZb6taDzMrFkIOpr0yGr0(rj2OuDEcRrD0roA(k9oQKerNlAuoy4kiVj6kbPfojixHQCxrNlAWfjLj1z3KcQaio2CG(eqxMz0NIiAEhn2r7hLyJsvuPlO08jfIsaixSgav6DujjIgtwCVOZ(wCaKlwdaLnhiRA5hz3MPfNEhvsc7Xw8cBuInUfhCrszsD2nPGOngr082I7fD23IdG4yZb6taDzMw1YppiXMPf3l6SVfha5I1aqzZbYItVJkjH9yRAvloba0xiGntl)8yZ0ItVJkjH9ylEHnkXg3ItpXUZx1XKs6MmDEjAJJMNOZfnsJgLdgUcYBIUsqAHtcYvOk3v05IgZrJ0OfRwl7xOxzUsIeS0nPekh7R6uom)D05IgPr7fD2Vw2VqVYCLejyPBs15tWY5gsJgdmIgMtktmQa5SBkPJjf9PrFxevtNxIgtwCVOZ(w8Y(f6vMRKiblDtYQw(nYMPfNEhvsc7Xw8cBuInUfhPrx2vkwdFfa5I1qcv6ccu5UIox0LDLI1Wxb5nrxjiTWjb5kuL7kAmWiADmPKUjXqrFkIO5bjwCVOZ(wCu5UI0cNuikrpzM3Qw(5TntlUx0zFl(nNZeJ)Pfo5hLyRczXP3rLKWESvT8FcBMwC6DujjShBXlSrj24wCmhn4IKYK6SBsbvaehBoqFcOlZmAJreTrrJbgrZ8rKiSOxRUqaQZhTXrFeijAmfDUOrA0LDLI1Wxb5nrxjiTWjb5kuL7k6CrJ0Or5GHRG8MOReKw4KGCfQYDfDUOPNy35RccEkJgTXiIM3iXI7fD23IdVfoajs(rj2OucLCtRA5pJ2mT407Ossyp2IxyJsSXT4GlsktQZUjfubqCS5a9jGUmZOngr0gfngyenZhrIWIET6cbOoF0gh9rGelUx0zFl(fhBGZp)Dcv6a1Qw(pcBMwC6DujjShBXlSrj24wCuoy4kJkhKeaKGxwHQCxrJbgrJYbdxzu5GKaGe8YkuQSCVsSkq9YHOpnAEqIf3l6SVfxHOe3JUCVibVSczvl)zzBMwCVOZ(wC2CDjP08jWLxilo9oQKe2JTQL)mOntlo9oQKe2JT4f2OeBClEzxPyn8vqEt0vcslCsqUcvzKPppi6tJoJrJbgrRJjL0njgk6tJMNmOf3l6SVf3WYKcSO5tmcSV)fYQw(r2TzAXP3rLKWESfVWgLyJBXPNy35J(0OpbsIox0OCWWvqEt0vcslCsqUcv5US4ErN9T4MK5YYNw4KKRmIKGrUjWQw(5bj2mT407Ossyp2IxyJsSXT4QZUjTcrUuHQxfnAJJodIKOXaJOvNDtAfICPcvVkA0NIiAJqs0yGr0QZUjTQJjL0nDv0KrijAJJM3iXI7fD23IZi)A(7eS0njGvTQfxqWoNuTzA5NhBMwC6DujjShBXlSrj24wCKgnqjxQqKOY2BoYI7fD23IFykhSQLFJSzAX9Io7BXbk5sfYItVJkjH9yRA5N32mT407Ossyp2I7fD23IxCPm5fD2pjhGAXLdqtVBsw8Iayvl)NWMPfNEhvsc7Xw8cBuInUfhOKlvisuDP0I7fD23IZ4(Kx0z)KCaQfxoan9UjzXbk5sfIew1YFgTzAXP3rLKWESfVWgLyJBX1XKs6MedfTXrFerNlAgz6ZdI(0OVlIQPZlrNl6YAIUPRDEfeTXiI(erNHrJ5O1XKI(0O5bjrJPOp5OnYI7fD23I)ZnKIkDbzvl)hHntlo9oQKe2JT47LfhqQf3l6SVfhlNnoQKS4y5soYIFXMLnA(eBvxN9Jox0GlsktQZUjfubqCS5a9jGUmZOngr0gzXXYzP3njlohGsxSzzJMpXw11zFRA5plBZ0ItVJkjH9ylEHnkXg3IJLZghvsvoaLUyZYgnFITQRZ(wCVOZ(w8IlLjVOZ(j5aulUCaA6DtYIduYLkuQiaw1YFg0MPfNEhvsc7Xw89YIdi1I7fD23IJLZghvswCSCjhzXnkJrJD0QlPxRyn3lRsVJkjr0NC08oJrJD0QlPxRMoqjwAHtaixSgav6DujjI(KJ2Omgn2rRUKETcGCXAibVfoqLEhvsIOp5OncjrJD0QlPxRU0lSrZxP3rLKi6toAEqs0yhnpzm6toAmhn4IKYK6SBsbvaehBoqFcOlZmAJrenVJgtwCSCw6DtYIduYLkusHyeaALcRA5hz3MPfNEhvsc7Xw8cBuInUfNEIDNVki4PmA0NIiASC24OsQcuYLkusHyeaALclUx0zFlEXLYKx0z)KCaQfxoan9UjzXbk5sfkveaRA5NhKyZ0ItVJkjH9ylEHnkXg3I7hLyJs1FUHuqcl6Vj)luLEhvsIOZfnsJgLdgU(ZnKcsyr)n5FHQCxrNl6YAIUPRDEfufe8ugnAJJMNOZfnMJgCrszsD2nPGkaIJnhOpb0Lzg9PrBu0yGr0y5SXrLuLdqPl2SSrZNyR66SF0yk6CrJ5Ol7kfRHVcYBIUsqAHtcYvOkJm95brFkIO5D0yGr0yoA)OeBuQ(ZnKcsyr)n5FHQm)peTXiI2OOZfnkhmCfK3eDLG0cNeKRqvgz6ZdI24O5D05IgPrduYLkejQUugDUOl7kfRHVcGCXAij8Vq1cKZUjqcM5fD23LrBmIOrsfzpAmfnMS4ErN9T4)CdPOsxqw1Ypp8yZ0ItVJkjH9ylEHnkXg3Ixwt0nDTZRGQGGNYOrFkIO5jAmWiADmPKUjXqrFkIO5j6Crxwt0nDTZRGOngr082I7fD23IxCPm5fD2pjhGAXLdqtVBswC45haKvT8ZJr2mT407Ossyp2IxyJsSXT4GlsktQZUjfubqCS5a9jGUmZOre9jIox0L1eDtx78kiAJre9jS4ErN9T4fxktErN9tYbOwC5a007MKfhE(bazvl)8WBBMwC6DujjShBXlSrj24wC6j2D(QGGNYOrFkIOXYzJJkPkqjxQqjfIraOvkS4ErN9T4fxktErN9tYbOwC5a007MKfhLBKcRA5NNtyZ0ItVJkjH9ylEHnkXg3ItpXUZxfe8ugnAJrenpzmASJMEIDNVYOB6T4ErN9T4oR4pL0LXOxTQLFEYOntlUx0zFlUZk(tPlojGS407Ossyp2Qw(55iSzAX9Io7BXLZnKcsh5CIBt6vlo9oQKe2JTQLFEYY2mT4ErN9T4O(DAHtkBkhawC6DujjShBvRAXVyuznrD1MPLFESzAX9Io7BXbk5sfYItVJkjH9yRA53iBMwC6DujjShBX9Io7BXnD2bsKGxwsqUczXVyuznrDnbOY(cGfNNmAvl)82MPfNEhvsc7Xw83njlUFuaKZCqcEFnTWPR1aXS4ErN9T4(rbqoZbj4910cNUwdeZQw(pHntlUx0zFl(1QZ(wC6DujjShBvRAXr5gPWMPLFESzAXP3rLKWESfVWgLyJBXbxKuMuNDtkiAJreTrrJD0yoA1L0R1B5UMOsxqv6DujjIox0(rj2Ou9IyWlZvQY8)q0gJiAJIgtwCVOZ(wCaehBoqFcOlZ0Qw(nYMPf3l6SVf)wURjQ0fKfNEhvsc7Xw1YpVTzAX9Io7BXr9YbG6OwC6DujjShBvRAXlcGntl)8yZ0ItVJkjH9ylEHnkXg3IJ0Or5GHRaixSgsc)luL7k6CrJYbdxbqCS5a9jDzVl2k3v05IgLdgUcG4yZb6t6YExSvgz6ZdI(uerZ7AgT4ErN9T4aixSgsc)lKfNdqPfgoDxew(5XQw(nYMPfNEhvsc7Xw8cBuInUfhLdgUcG4yZb6t6YExSvUROZfnkhmCfaXXMd0N0L9UyRmY0Nhe9PiIM31mAX9Io7BXb5nrxjiTWjb5kKfNdqPfgoDxew(5XQw(5Tntlo9oQKe2JT4f2OeBClosJgOKlvisuDPm6CrlwT(ZnKIkDbv1PCy(BlUx0zFlEXLYKx0z)KCaQfxoan9UjzXjaG(cbSQL)tyZ0ItVJkjH9ylUx0zFl(1UYeJalhRqw8cBuInUfhPrRUKETcGCXAibVfoqLEhvsclo8YspXlQLFESQL)mAZ0ItVJkjH9ylEHnkXg3ItpXUZhTXiI(iqs05IwSA9NBifv6cQQt5W83rNl6YUsXA4RG8MOReKw4KGCfQYDfDUOl7kfRHVcGCXAij8Vq1cKZUjq0gJiAES4ErN9T4aio2CG(KUS3fRvT8Fe2mT407Ossyp2IxyJsSXT4IvR)CdPOsxqvDkhM)o6CrJ0Ol7kfRHVcGCXAiHkDbbQCxrNlAmhnsJwDj9AfaXXMd0N0L9UyR07OssengyeT6s61kaYfRHe8w4av6DujjIgdmIUSRuSg(kaIJnhOpPl7DXwzKPppiAJJ2OOXu05IgZrJ0OjaG(cvrL7kslCsHOe9Kz(QPFKVSOXaJOl7kfRHVIk3vKw4Kcrj6jZ8vgz6ZdI24OnkAmfDUOXC0(rj2Ou9NBifKWI(BY)cvz(Fi6tJ2OOXaJOr5GHR)CdPGew0Ft(xOk3v0yYI7fD23IdYBIUsqAHtcYviRA5plBZ0ItVJkjH9ylUx0zFlUPZoqIe8YscYvilEHnkXg3IZ8rKiSOxRUqaQCxrNlAmhT6SBsR6ysjDtIHI(0OlRj6MU25vqvqWtz0OXaJOrA0aLCPcrIQlLrNl6YAIUPRDEfufe8ugnAJreD5kz68scCrViAmzXl5lskPo7MuGLFESQL)mOntlo9oQKe2JT4f2OeBCloZhrIWIET6cbOoF0ghnVrs0zy0mFejcl61QleGQGJ56SF05IgPrduYLkejQUugDUOlRj6MU25vqvqWtz0Ongr0LRKPZljWf9clUx0zFlUPZoqIe8YscYviRA5hz3MPfNEhvsc7Xw8cBuInUfhPrduYLkejQUugDUOfRw)5gsrLUGQ6uom)D05IUSMOB6ANxbvbbpLrJ2yerBKf3l6SVfha5I1qcv6ccyvl)8GeBMwC6DujjShBXlSrj24wC1L0RvaKlwdj4TWbQ07OsseDUOfRw)5gsrLUGQ6uom)D05IgLdgUcYBIUsqAHtcYvOk3Lf3l6SVfhaXXMd0N0L9UyTQLFE4XMPfNEhvsc7Xw8cBuInUfhPrJYbdxbqUynKe(xOk3v05IwhtkPBsmu0NIi6mgn2rRUKETc4qvIbZDtv6DujjIox0inAMpIeHf9A1fcqL7YI7fD23IdGCXAij8Vqw1YppgzZ0ItVJkjH9ylEHnkXg3IJYbdxrL7kKCaTYiVOrJbgrJYbdxb5nrxjiTWjb5kuL7k6CrJ5Or5GHRaixSgsOsxqGk3v0yGr0LDLI1WxbqUynKqLUGavgz6ZdI(uerZdsIgtwCVOZ(w8RvN9TQLFE4Tntlo9oQKe2JT4f2OeBClokhmCfK3eDLG0cNeKRqvUllUx0zFloQCxrcMJL3Qw(55e2mT407Ossyp2IxyJsSXT4OCWWvqEt0vcslCsqUcv5US4ErN9T4OedqSdZFBvl)8KrBMwC6DujjShBXlSrj24wCuoy4kiVj6kbPfojixHQCxwCVOZ(wC4HrOYDfw1YpphHntlo9oQKe2JT4f2OeBClokhmCfK3eDLG0cNeKRqvUllUx0zFlU)fcOmxMkUuAvl)8KLTzAXP3rLKWESf3l6SVfVKVixLT)usOshOw8cBuInUfhPrduYLkejQUugDUOfRw)5gsrLUGQ6uom)D05IgPrJYbdxb5nrxjiTWjb5kuL7k6CrtpXUZxfe8ugnAJrenVrIfNGHPIME3KS4L8f5QS9Nscv6a1Qw(5jdAZ0ItVJkjH9ylUx0zFlUFuaKZCqcEFnTWPR1aXS4f2OeBClosJgLdgUcGCXAij8VqvUROZfDzxPyn8vqEt0vcslCsqUcvzKPppi6tJMhKyXF3KS4(rbqoZbj4910cNUwdeZQw(5bz3MPfNEhvsc7XwCVOZ(wChaHL)eiX8JUSuzzU0IxyJsSXT4ccLdgUY8JUSuzzUmjiuoy4Qyn8rJbgrliuoy4AzFbxrhSO08hsccLdgUYDfDUOvNDtAvhtkPB6QOjEJKOpn6mgngyensJwqOCWW1Y(cUIoyrP5pKeekhmCL7k6CrJ5OfekhmCL5hDzPYYCzsqOCWWvG6LdrBmIOnkJrNHrZdsI(KJwqOCWWvu5UI0cNuikrpzMVYDfngyeToMus3KyOOpn6tGKOXu05IgLdgUcYBIUsqAHtcYvOkJm95brBC0zql(7MKf3bqy5pbsm)OllvwMlTQLFJqIntlo9oQKe2JT4VBswCZ8chKuxoat)T4ErN9T4M5foiPUCaM(Bvl)gXJntlo9oQKe2JT4f2OeBClokhmCfK3eDLG0cNeKRqvUROXaJO1XKs6Medf9PrBesS4ErN9T4CaknkzcSQvT4aLCPcLkcGntl)8yZ0ItVJkjH9yl(EzXbKAX9Io7BXXYzJJkjlowUKJS4LDLI1WxbqUynKe(xOAbYz3eibZ8Io77YOngr08uZYz0IJLZsVBswCaKiPqmcaTsHvT8BKntlo9oQKe2JT4f2OeBClosJglNnoQKQairsHyeaALIOZfDznr301oVcQccEkJgTXrZt05IwqOCWWv45fjdKF4jaOYitFEq0NgnprNl6YUsXA4RG8MOReKw4KGCfQYitFEq0gJiAEBX9Io7BXXY)bazvl)82MPfNEhvsc7XwCVOZ(w8RDLjgbwowHS4eVOmp5Ml3Rw8tGelo8YspXlQLFESQL)tyZ0ItVJkjH9ylEHnkXg3ItpXUZhTXiI(eij6CrtpXUZxfe8ugnAJrenpij6CrJ0OXYzJJkPkasKuigbGwPi6Crxwt0nDTZRGQGGNYOrBC08eDUOfekhmCfEErYa5hEcaQmY0Nhe9PrZJf3l6SVfha5I1Gjjfw1YFgTzAXP3rLKWESfFVS4asT4ErN9T4y5SXrLKfhlxYrw8YAIUPRDEfufe8ugnAJre9jS4y5S07MKfhajsL1eDtx78kWQw(pcBMwC6DujjShBX3lloGulUx0zFlowoBCujzXXYLCKfVSMOB6ANxbvbbpLrJ(uerZt0yhTrrFYr7hLyJsvfIsWddOjH)fQsVJkjHfVWgLyJBXXYzJJkPkhGsxSzzJMpXw11z)OZfnMJwDj9A9NBifOU8aXQ07OssengyeT6s61QWzhsaixSgQ07OssenMS4y5S07MKfhajsL1eDtx78kWQw(ZY2mT407Ossyp2IxyJsSXT4y5SXrLufajsL1eDtx78ki6CrJ5OrA0QlPxRcNDibGCXAOsVJkjr0yGr0IvR)CdPOsxqvgz6ZdI2yerNXOXoA1L0RvahQsmyUBQsVJkjr0yk6CrJ5OXYzJJkPkasKuigbGwPiAmWiAuoy4kiVj6kbPfojixHQmY0NheTXiIMNQrrJbgrdUiPmPo7MuqfaXXMd0Na6YmJ2yerFIOZfDzxPyn8vqEt0vcslCsqUcvzKPppiAJJMhKenMIox0yoA)OeBuQ(ZnKcsyr)n5FHQm)pe9PrBu0yGr0OCWW1FUHuqcl6Vj)luL7kAmzX9Io7BXbqUynKe(xiRA5pdAZ0ItVJkjH9ylEHnkXg3IJLZghvsvaKivwt0nDTZRGOZfToMus3KyOOpn6YUsXA4RG8MOReKw4KGCfQYitFEq05IgPrZ8rKiSOxRUqaQCxwCVOZ(wCaKlwdjH)fYQw1Idp)aGSzA5NhBMwC6DujjShBXHxw6jErT8ZJf3l6SVf)AxzIrGLJviRA53iBMwC6DujjShBXlSrj24wCuoy46p3qkiHf93K)fQYDzX9Io7BXjSgqHyUsw1YpVTzAXP3rLKWESfVWgLyJBXXC0inA1L0RvHZoKaqUynuP3rLKiAmWiAKgnkhmCfa5I1qs4FHQCxrJPOZfToMus3KyOOZWOzKPppiAJJ(iIox0mY0Nhe9PrRt5qshtk6toAJS4ErN9T4)CdPOsxqw1Y)jSzAXP3rLKWESf3l6SVf)NBifv6cYIxyJsSXT4inASC24OsQYbO0fBw2O5tSvDD2p6CrdUiPmPo7MuqfaXXMd0Na6YmJ2yerBu05IgZr7hLyJs1FUHuqcl6Vj)luLEhvsIOXaJOrA0(rj2OuLrxYP4683jaKlwdGk9oQKerJbgrdUiPmPo7MuqfaXXMd0Na6YmJodJ2l6GfLeRw)5gsrLUGI2yerBu0yk6CrJ0Or5GHRaixSgsc)luL7k6CrRJjL0njgkAJrenMJoJrJD0yoAJI(KJUSMOB6ANxbrJPOXu05IMrWmca5OsYIxYxKusD2nPal)8yvl)z0MPfNEhvsc7Xw8cBuInUfNrM(8GOpn6YUsXA4RG8MOReKw4KGCfQYitFEq0yhnpij6Crx2vkwdFfK3eDLG0cNeKRqvgz6ZdI(uerNXOZfToMus3KyOOZWOzKPppiAJJUSRuSg(kiVj6kbPfojixHQmY0Nhen2rNrlUx0zFl(p3qkQ0fKvT8Fe2mT4ErN9T4aQWinPub6NmaoYItVJkjH9yRA5plBZ0I7fD23ItynGcXCLS407Ossyp2Qw1QwCSigy23YVriXiKGeJqYryXn4SF(BGfhz28AzkjIodgTx0z)OLdqb14Sf)ITWJKS4ipACouvsA(OZs7nhfNrE0qQEboPzN99OqCO1YAMnym5KUo7xyoSMnymlzhNrE0ilcLX5S8rZJr8fTriXiKeNJZipAEfY)BcCsJZip6mmAKjHGerNfDkhIw3OfeSZj1O9Io7hTCaAnoJ8OZWOZsK5IfjIwD2nPPbo6Y(IrN9JE)OZaD2bsen8YIoRKRq14mYJodJgzsiir0zbafnYSsMGACooJ8Or2WluHtjr0Oe8YOOlRjQRrJs3ZdQrJmvk0LcI(3pdHCMjmNmAVOZ(GO3xMVgNrE0ErN9b1lgvwtuxralDWH4mYJ2l6SpOEXOYAI6k2iY25UnPxDD2poJ8O9Io7dQxmQSMOUInISH3veNrE04VFbGwnAMpIOr5GHjr0a1vq0Oe8YOOlRjQRrJs3ZdI2Fr0xmkdVwvN)o6beTyFQgNrE0ErN9b1lgvwtuxXgr2G3VaqRMaQRG4Sx0zFq9IrL1e1vSrKnqjxQqXzVOZ(G6fJkRjQRyJiBtNDGej4LLeKRq8DXOYAI6AcqL9fae8KX4Sx0zFq9IrL1e1vSrKnhGsJsM89UjHWpkaYzoibVVMw401AGyXzVOZ(G6fJkRjQRyJi7RvN9JZXzKhnYgEHkCkjIMWIy5JwhtkAfII2l6YIEar7y5J0rLunoJ8OZseqjxQqrpWrFTaWGkPOX8VrJfN8jMJkPOPNmhce98rxwtuxXuC2l6SpaXHPCGVbgbsbk5sfIev2EZrXzVOZ(aSrKnqjxQqXzKhnVcrLdrZRzfeTRrdpmGgN9Io7dWgr2fxktErN9tYbO89UjHOiaXzKhDwI7JgMtkZhnWWOficeTUrRqu04k5sfIerNLw11z)OXmA(Of783rdw(IE0OHxwHarFTRC(7Oh4O)vHM)o6beTJLpshvsyQgN9Io7dWgr2mUp5fD2pjhGY37MecGsUuHibFdmcGsUuHir1LY4mYJgz66sMpA(NBifv6ckAxJ2iSJMxrgrl4yZFhTcrrdpmGgnpijAav2xa4lAhwjw0kKRrFcSJMxrgrpWrpA0eVCnmceTHrHMpAfII(jErJolgVM1Oxw0di6F1O5UIZErN9byJi7FUHuuPli(gye6ysjDtIHm(iYXitFEWP3fr105LCL1eDtx78kWyeNidXSoM0P8GemDYgfNrE0zXFz(Olq(FtrZw11z)Oh4Onqrd5yrrFXMLnA(eBvxN9JgqA0(lI2KtQZLKIwD2nPGO5UQXzVOZ(aSrKnwoBCujX37MecoaLUyZYgnFITQRZ(8HLl5iexSzzJMpXw11z)CGlsktQZUjfubqCS5a9jGUmtJryuCg5rJmyZYgnF0zPvDD2hzRrNfH0Jmq03dwu0E0fMFfTJUCA00tS78rdVSOvikAGsUuHIMxZkiAmJYnsbXIgOJugnJaxurJEumvJgzBUl(IE0Ol(hnkfTc5A0GX8ss14Sx0zFa2iYU4szYl6SFsoaLV3njeaLCPcLkcaFdmcSC24OsQYbO0fBw2O5tSvDD2poJ8OZcaseTUrli45POnarF06gnhGIgOKlvOO51ScIEzrJYnsbXaXzVOZ(aSrKnwoBCujX37MecGsUuHskeJaqRuWhwUKJqyugXwDj9AfR5Ezv6DujjozENrSvxsVwnDGsS0cNaqUynaQ07OssCYgLrSvxsVwbqUynKG3chOsVJkjXjBesWwDj9A1LEHnA(k9oQKeNmpibBEY4jJzWfjLj1z3KcQaio2CG(eqxMPXi4nMIZipAEDFWiiw0CG5VJ2JgxjxQqrZRznAdq0hnJ8c083rRqu00tS78rRqmcaTsrC2l6SpaBezxCPm5fD2pjhGY37MecGsUuHsfbGVbgb9e7oFvqWtz0trGLZghvsvGsUuHskeJaqRueNrE08p3q6rgi6tc93K)f6Kgn)ZnKIkDbfnkbVmkA88MOReeTRrlxdrZRiJO1n6YAIopfn5mz(OzemJaqrByuOOVjvN)oAfIIgLdgoAURA0itsWgTCnenVImIwWXM)oA88MOReenkPgi6JoR(xiq0ggfkAJWoA(pj14Sx0zFa2iY(NBifv6cIVbgHFuInkv)5gsbjSO)M8Vqv6DujjYHuuoy46p3qkiHf93K)fQYDLRSMOB6ANxbvbbpLrnMNCygCrszsD2nPGkaIJnhOpb0LzEQryGbwoBCujv5au6InlB08j2QUo7JPCyUSRuSg(kiVj6kbPfojixHQmY0NhCkcEJbgy2pkXgLQ)CdPGew0Ft(xOkZ)dgJWOCOCWWvqEt0vcslCsqUcvzKPppWyENdPaLCPcrIQlL5k7kfRHVcGCXAij8Vq1cKZUjqcM5fD23LgJajvKDmHP4mYJgzn)aGI21Opb2rByuOLtJoR48fDgXoAdJcfDwXJgZlNcgbfnqjxQqyko7fD2hGnISlUuM8Io7NKdq57Dtcb88daIVbgrznr301oVcQccEkJEkcEWadDmPKUjXqNIGNCL1eDtx78kWye8ooJ8OpsJcfDwXJ2LGnA45hau0Ug9jWoA)2NhOrt8Ixuz(Opr0QZUjfenMxofmckAGsUuHWuC2l6SpaBezxCPm5fD2pjhGY37Mec45haeFdmcWfjLj1z3KcQaio2CG(eqxMjItKRSMOB6ANxbgJ4eXzKhDwaqr7rJYnsbXI2ae9rZiVan)D0kefn9e7oF0keJaqRueN9Io7dWgr2fxktErN9tYbO89UjHaLBKc(gye0tS78vbbpLrpfbwoBCujvbk5sfkPqmcaTsrCg5rNfznqan6l2SSrZh98r7sz0lC0kefnYeYils0OuX5au0JgDX5aeiAp6Sy8AwJZErN9byJiBNv8Ns6Yy0R8nWiONy35RccEkJAmcEYi20tS78vgDtFC2l6SpaBez7SI)u6ItcO4Sx0zFa2iYwo3qkiDKZjUnPxJZErN9byJiBu)oTWjLnLdG4CCg5rFm3ifedeN9Io7dQOCJuGaaXXMd0Na6Ym5BGraUiPmPo7MuGXimcBmRUKETEl31ev6cQsVJkjro)OeBuQErm4L5kvz(FWyegHP4Sx0zFqfLBKcSrK9TCxtuPlO4Sx0zFqfLBKcSrKnQxoauhnohNrE086UsXA4bXzKhDwaqrNv)lu0lmCgExerJsWlJIwHOOHhgqJghIJnhOpACDzMrdZwZOZCzVl2OlRjbIE(AC2l6SpOweaeaixSgsc)leFCakTWWP7Iabp8nWiqkkhmCfa5I1qs4FHQCx5q5GHRaio2CG(KUS3fBL7khkhmCfaXXMd0N0L9UyRmY0NhCkcExZyCg5rJ5SWljaiAxYixKpAUROrPIZbOOnqrR7EiACixSgIgzTfoaMIMdqrJN3eDLGOxy4m8UiIgLGxgfTcrrdpmGgnoehBoqF046YmJgMTMrN5YExSrxwtce9814Sx0zFqTiayJiBqEt0vcslCsqUcXhhGslmC6UiqWdFdmcuoy4kaIJnhOpPl7DXw5UYHYbdxbqCS5a9jDzVl2kJm95bNIG31mgN9Io7dQfbaBezxCPm5fD2pjhGY37MeccaOVqa(gyeifOKlvisuDPmNy16p3qkQ0fuvNYH5VJZipAKXUYOHxw0zUS3fB0xmkdX3SgTHrHIghkRrZixKpAdq0h9VA0mU)N)oACKvno7fD2hulca2iY(AxzIrGLJvi(Gxw6jErrWdFdmcKQUKETcGCXAibVfoqLEhvsI4mYJolaOOZCzVl2OVyu04BwJ2ae9rBGIgYXIIwHOOPNy35J2aePqelAy2Ag91UY5VJ2WOqlNgnoYk6Lf9rohqJ(MEI5sz(AC2l6SpOweaSrKnaIJnhOpPl7DXY3aJGEIDN3yehbsYjwT(ZnKIkDbv1PCy(7CLDLI1Wxb5nrxjiTWjb5kuL7kxzxPyn8vaKlwdjH)fQwGC2nbmgbpXzKhDwaqrJN3eDLGO3p6YUsXA4JgZoSsSOHhgqJM)5gsrLUGWu0CVKaGOnqr7mk67D(7O1n6R9k6mx27InA)frl2O)vJgYXIIghYfRHOrwBHduJZErN9b1IaGnISb5nrxjiTWjb5keFdmcXQ1FUHuuPlOQoLdZFNdPLDLI1WxbqUynKqLUGavURCygPQlPxRaio2CG(KUS3fBLEhvscmWqDj9Afa5I1qcElCGk9oQKeyGrzxPyn8vaehBoqFsx27ITYitFEGXgHPCygPeaqFHQOYDfPfoPquIEYmF10pYxggyu2vkwdFfvURiTWjfIs0tM5RmY0NhySrykhM9JsSrP6p3qkiHf93K)fQY8)WPgHbgOCWW1FUHuqcl6Vj)luL7ctXzKhnYmC0UqaI2zu0Cx8fn4NlkAfIIEFkAdJcfTCnqan6mZmR1OZcakAdq0hTi)83rd7aLyrRq(hnVImIwqWtz0Oxw0)QrduYLkejI2WOqlNgT)5JMxrg14Sx0zFqTiayJiBtNDGej4LLeKRq8vYxKusD2nPae8W3aJG5JiryrVwDHau5UYHz1z3Kw1XKs6MedDAznr301oVcQccEkJIbgifOKlvisuDPmxznr301oVcQccEkJAmIYvY05Le4IEbMIZipAKz4O)nAxiarByKYOfdfTHrHMpAfII(jErJM3ibWx0Cak6mq4Sg9(rJUaq0ggfA50O9pF08kYiA)fr)B0aLCPcvJZErN9b1IaGnISnD2bsKGxwsqUcX3aJG5JiryrVwDHauN3yEJKmK5JiryrVwDHaufCmxN9ZHuGsUuHir1LYCL1eDtx78kOki4PmQXikxjtNxsGl6fXzVOZ(GAraWgr2aixSgsOsxqa(gyeifOKlvisuDPmNy16p3qkQ0fuvNYH5VZvwt0nDTZRGQGGNYOgJWO4mYJ(inku04il(IEGJ(xnAxYixKpAX(eFrZbOOZCzVl2Onmku04BwJM7QgN9Io7dQfbaBezdG4yZb6t6YExS8nWiuxsVwbqUynKG3chOsVJkjroXQ1FUHuuPlOQoLdZFNdLdgUcYBIUsqAHtcYvOk3vC2l6SpOweaSrKnaYfRHKW)cX3aJaPOCWWvaKlwdjH)fQYDLthtkPBsm0PiYi2QlPxRaouLyWC3uLEhvsICiL5JiryrVwDHau5UIZErN9b1IaGnISVwD2NVbgbkhmCfvURqYb0kJ8IIbgOCWWvqEt0vcslCsqUcv5UYHzuoy4kaYfRHeQ0feOYDHbgLDLI1WxbqUynKqLUGavgz6ZdofbpibtXzVOZ(GAraWgr2OYDfjyowE(gyeOCWWvqEt0vcslCsqUcv5UIZErN9b1IaGnISrjgGyhM)MVbgbkhmCfK3eDLG0cNeKRqvUR4Sx0zFqTiayJiB4HrOYDf8nWiq5GHRG8MOReKw4KGCfQYDfN9Io7dQfbaBez7FHakZLPIlL8nWiq5GHRG8MOReKw4KGCfQYDfN9Io7dQfbaBezZbO0OKjFemmv007MeIs(ICv2(tjHkDGY3aJaPaLCPcrIQlL5eRw)5gsrLUGQ6uom)DoKIYbdxb5nrxjiTWjb5kuL7kh9e7oFvqWtzuJrWBKeN9Io7dQfbaBezZbO0OKjFVBsi8JcGCMdsW7RPfoDTgigFdmcKIYbdxbqUynKe(xOk3vUYUsXA4RG8MOReKw4KGCfQYitFEWP8GK4mYJ(KqS8rZwUBiz(OzCsk6foAfIZeDGhseTPRqGOrj5A4KgDwaqrdVSOrM)dxRi6cBu(IEviIzyau0ggfkA8nRr7A0gLrSJgOE5ai6Lfnpze7Onmku0UeSrFSCxr0Cx14Sx0zFqTiayJiBoaLgLm57DtcHdGWYFcKy(rxwQSmxY3aJqqOCWWvMF0LLklZLjbHYbdxfRHhdmeekhmCTSVGROdwuA(djbHYbdx5UYPo7M0QoMus30vrt8gjNMrmWaPccLdgUw2xWv0blkn)HKGq5GHRCx5WSGq5GHRm)OllvwMltccLdgUcuVCWyegLXmKhKCYccLdgUIk3vKw4Kcrj6jZ8vUlmWqhtkPBsm0PNajykhkhmCfK3eDLG0cNeKRqvgz6ZdmodgN9Io7dQfbaBezZbO0OKjFVBsimZlCqsD5am9poJ8OZkb7CsnAyxkr9YHOHxw0CahvsrpkzcoPrNfau0ggfkA88MORee9chDwjxHQXzVOZ(GAraWgr2Caknkzc4BGrGYbdxb5nrxjiTWjb5kuL7cdm0XKs6MedDQrijohNrE0iBaa6leio7fD2hujaG(cbqu2VqVYCLejyPBs8nWiONy35R6ysjDtMoVymp5qkkhmCfK3eDLG0cNeKRqvURCygPIvRL9l0Rmxjrcw6MucLJ9vDkhM)ohs9Io7xl7xOxzUsIeS0nP68jy5CdPyGbmNuMyubYz3usht607IOA68cMIZErN9bvcaOVqaSrKnQCxrAHtkeLONmZZ3aJaPLDLI1WxbqUynKqLUGavURCLDLI1Wxb5nrxjiTWjb5kuL7cdm0XKs6MedDkcEqsC2l6SpOsaa9fcGnISV5CMy8pTWj)OeBvO4Sx0zFqLaa6leaBezdVfoajs(rj2OucLCt(gyeygCrszsD2nPGkaIJnhOpb0LzAmcJWadMpIeHf9A1fcqDEJpcKGPCiTSRuSg(kiVj6kbPfojixHQCx5qkkhmCfK3eDLG0cNeKRqvURC0tS78vbbpLrngbVrsC2l6SpOsaa9fcGnISV4ydC(5VtOshO8nWiaxKuMuNDtkOcG4yZb6taDzMgJWimWG5JiryrVwDHauN34JajXzVOZ(Gkba0xia2iYwHOe3JUCVibVScX3aJaLdgUYOYbjbaj4LvOk3fgyGYbdxzu5GKaGe8YkuQSCVsSkq9YHt5bjXzVOZ(Gkba0xia2iYMnxxsknFcC5fko7fD2hujaG(cbWgr2gwMuGfnFIrG99Vq8nWik7kfRHVcYBIUsqAHtcYvOkJm95bNMrmWqhtkPBsm0P8KbJZErN9bvcaOVqaSrKTjzUS8Pfoj5kJijyKBc4BGrqpXUZF6jqsouoy4kiVj6kbPfojixHQCxXzVOZ(Gkba0xia2iYMr(183jyPBsa(gyeQZUjTcrUuHQxf14misWad1z3KwHixQq1RIEkcJqcgyOo7M0QoMus30vrtgHeJ5nsIZXzKhnYA(barmqC2l6SpOcp)aGqCTRmXiWYXkeFWll9eVOi4joJ8Or2G1akeZvkAihen0Cdran6l2SSrZhTHrHIM)5gspYarFsO)M8VqrZDvJZErN9bv45hae2iYMWAafI5kX3aJaLdgU(ZnKcsyr)n5FHQCxXzKhDwuIUIM7kA(NBifv6ck6bo6rJEar7OlNgTUrZ4(OxoTgDw3O)vJMdqrZ)Xrl4yZFhDw9Vq8f9ahT6s6vse986gDwD2HOXHCXAOgN9Io7dQWZpaiSrK9p3qkQ0feFdmcmJu1L0RvHZoKaqUynuP3rLKadmqkkhmCfa5I1qs4FHQCxykNoMus3KyOmKrM(8aJpICmY0NhCQoLdjDmPt2O4mYJodKtQJyvD(7Oxofmck6S6FHIE)OvNDtkiAfY1Onmsz0YblkA4LfTcrrl4yUo7h9chn)ZnKIkDbXx0mcMraOOfCS5VJ(YFbzoLA0zGCsDeRgTdIwU)D0oiAJWoA1z3KcIwSr)RgnKJffn)ZnKIkDbfn3v0ggfk6SeDjNIRZFhnoKlwdGOXm3ljai68lx0qowu08p3q6rgi6tc93K)fkADxmvJZErN9bv45hae2iY(NBifv6cIVs(IKsQZUjfGGh(gyeiflNnoQKQCakDXMLnA(eBvxN9ZbUiPmPo7MuqfaXXMd0Na6YmngHr5WSFuInkv)5gsbjSO)M8Vqv6DujjWadK6hLyJsvgDjNIRZFNaqUynaQ07OssGbgGlsktQZUjfubqCS5a9jGUmZm0l6GfLeRw)5gsrLUGmgHrykhsr5GHRaixSgsc)luL7kNoMus3KyiJrG5mInMn6KlRj6MU25vaMWuogbZiaKJkP4mYJolrWmcafn)ZnKIkDbfn5mz(Oh4OhnAdJugnXlxdJIwWXM)oA88MOReuJoRB0kKRrZiygbGIEGJgFZA03KcIMrUiF0ZhTcrr)eVOrNrqno7fD2huHNFaqyJi7FUHuuPli(gyemY0NhCAzxPyn8vqEt0vcslCsqUcvzKPppaBEqsUYUsXA4RG8MOReKw4KGCfQYitFEWPiYyoDmPKUjXqziJm95bgx2vkwdFfK3eDLG0cNeKRqvgz6ZdWoJXzVOZ(Gk88dacBezdOcJ0KsfOFYa4O4Sx0zFqfE(baHnISjSgqHyUsX54mYJgxjxQqrZR7kfRHheNrE0iBHKxel6tIZghvsXzVOZ(GkqjxQqPIaGalNnoQK47DtcbasKuigbGwPGpSCjhHOSRuSg(kaYfRHKW)cvlqo7MajyMx0zFxAmcEQz5mgNrE0Ne)hau0CVKaGOnqr7mkAhD50O1n6IFf9(rNv)lu0fiNDtGA0zXFz(OnarF0iR5frFKi)Wtaq0diAhD50O1nAg3h9YP14Sx0zFqfOKlvOuraWgr2y5)aG4BGrGuSC24OsQcGejfIraOvkYvwt0nDTZRGQGGNYOgZtobHYbdxHNxKmq(HNaGkJm95bNYtUYUsXA4RG8MOReKw4KGCfQYitFEGXi4DCg5rJm2vgn8YIghYfRbtskIg7OXHCXAaOS5afn3ljaiAdu0oJI2rxonADJU4xrVF0z1)cfDbYz3eOgDw8xMpAdq0hnYAEr0hjYp8eae9aI2rxonADJMX9rVCAno7fD2hubk5sfkveaSrK91UYeJalhRq8bVS0t8IIGh(iErzEYnxUxrCcKeN9Io7dQaLCPcLkca2iYga5I1Gjjf8nWiONy35ngXjqso6j2D(QGGNYOgJGhKKdPy5SXrLufajskeJaqRuKRSMOB6ANxbvbbpLrnMNCccLdgUcpVizG8dpbavgz6ZdoLN4mYJMxrgrZOmaUHrM0RN0OZQ)fkAxJwUgIMxrgrJMpAbb7CsTgN9Io7dQaLCPcLkca2iYglNnoQK47DtcbasKkRj6MU25vaFy5socrznr301oVcQccEkJAmIteNrE08kYiAgLbWnmYKE9KgDw9VqrVVmF0Oe8YOOHNFaqede9ahTbkAihlkA38kA1L0RGO9xe9fBw2O5JMTQRZ(14Sx0zFqfOKlvOuraWgr2y5SXrLeFVBsiaqIuznr301oVc4dlxYrikRj6MU25vqvqWtz0trWd2gDY(rj2OuvHOe8WaAs4FHQ07OssW3aJalNnoQKQCakDXMLnA(eBvxN9ZHz1L0R1FUHuG6YdeRsVJkjbgyOUKETkC2HeaYfRHk9oQKeykoJ8OpsJcfDwD2HOXHCXAi69L5JoR(xOOnarF08p3qkQ0fu0ggPmAG65JM7QgDwaqrl4yZFhnEEt0vcIEzr7Olwu0keJaqRuuJ(i5Jgn8YIM)ts0OCWWrByuOOncB(pj14Sx0zFqfOKlvOuraWgr2aixSgsc)leFdmcSC24OsQcGePYAIUPRDEfKdZivDj9Av4SdjaKlwdv6DujjWadXQ1FUHuuPlOkJm95bgJiJyRUKETc4qvIbZDtv6DujjWuomJLZghvsvaKiPqmcaTsbgyGYbdxb5nrxjiTWjb5kuLrM(8aJrWt1imWaCrszsD2nPGkaIJnhOpb0LzAmItKRSRuSg(kiVj6kbPfojixHQmY0Nhympibt5WSFuInkv)5gsbjSO)M8VqvM)ho1imWaLdgU(ZnKcsyr)n5FHQCxykoJ8OpMJ9rZitF(5VJoR(xiq0Oe8YOOvikA1z3KgTyiq0dC04BwJ2W(hzA0Ou0mYf5JE(O1XKQXzVOZ(GkqjxQqPIaGnISbqUynKe(xi(gyey5SXrLufajsL1eDtx78kiNoMus3KyOtl7kfRHVcYBIUsqAHtcYvOkJm95b5qkZhrIWIET6cbOYDfNJZipACLCPcrIOZsR66SFCg5rJmdhnUsUuHYgl)hau0oJIM7IVO5au04qUynau2CGIw3OrPNGhnAy2AgTcrrF5aWGffn6(CGO9xenYAEr0hjYp8eaWx0ew0h9ahTbkANrr7A0MoVenVImIgZWS1mAfII(IrL1e11OZaHZkMQXzVOZ(GkqjxQqKabaYfRbGYMdeFdmcmRUKETcpVizG8dpbav6DujjWadWfjLj1z3KcQaio2CG(eqxM5P8gt5WmkhmCfOKlvOk3fgyGYbdxXY)bav5UWuCg5rJSMFaqr7A08g7O5vKr0ggfA50OZkE0zh9jWoAdJcfDwXJ2WOqrJdXXMd0hDMl7DXgnkhmC0CxrRB0ow7iIgSMu08kYiAdoqPObJY56SpOgN9Io7dQaLCPcrcSrKDXLYKx0z)KCakFVBsiGNFaq8nWiq5GHRaio2CG(KUS3fBL7kxznr301oVcQccEkJEkcJIZipAKjjyJg4Wu06gn88dakAxJ(eyhnVImI2WOqrt8Ixuz(Opr0QZUjfuJgZ4UjfTdIE5uWiOObk5sfQIP4Sx0zFqfOKlvisGnISlUuM8Io7NKdq57Dtcb88daIVbgb4IKYK6SBsbvaehBoqFcOlZeXjYvwt0nDTZRaJrCI4mYJgzn)aGI21Opb2rZRiJOnmk0YPrNvC(IoJyhTHrHIoR48fT)IOpIOnmku0zfpAhwjw0Ne)hau0ll6mHOOrwddOrNv)lu0(lI(3OZQZoenoKlwdrJD0)gnohQsmyUBko7fD2hubk5sfIeyJi7IlLjVOZ(j5au(E3Kqap)aG4BGruwt0nDTZRGQGGNYONIGNmeZQlPxRcIUiwcOmx9BYSsVJkjromJYbdxXY)bav5UWad)OeBuQQqucEyanj8Vqv6DujjYHu1L0RvHZoKaqUynuP3rLKihsvxsVwbCOkXG5UPk9oQKe5axKuMuNDtkOcG4yZb6taDzMNYBmHP4mYJolaOOZIj31ev6ck6flIfnoKlwdaLnhOO9xenUUmZOnmku0gHD0idIbVmxPODnAJIEzrljaiA1z3KcQXzVOZ(GkqjxQqKaBezFl31ev6cIVbgHFuInkvVig8YCLQm)pymcJYbUiPmPo7MuqfaXXMd0Na6YmpfHrXzKhnYKgTrrRo7Muq0ggfkACQWin6mPc0pzaCu0hi6kAUROrwZlI(ir(HNaGOrZhDjFro)D04qUynau2CGQXzVOZ(GkqjxQqKaBezdGCXAaOS5aXxjFrsj1z3KcqWdFdmc1L0RvavyKMuQa9tgahvP3rLKiN6s61k88IKbYp8eauP3rLKiNGq5GHRWZlsgi)WtaqLrM(8Gt5jh4IKYK6SBsbvaehBoqFcOlZeHr50XKs6MedLHmY0Nhy8reNrE0hPrHwon6Ss0fXIgxzU63Kz0(lIM3rNL8)ai6fo6JLUGIE(OvikACixSgarpA0diAdltHIMdm)D04qUynau2CGIE)O5D0QZUjfuJZErN9bvGsUuHib2iYga5I1aqzZbIVbgbsvxsVwfeDrSeqzU63KzLEhvsIC(rj2Oufv6cknFsHOeaYfRbqL5)be8oh4IKYK6SBsbvaehBoqFcOlZebVJZipAK1YI(InlB08rZw11zF(IMdqrJd5I1aqzZbk6flIfnUUmZO5btrByuOOpszGr73(8anAURO1n6teT6SBsb8fTryk6boAK1rk6benJ7)5VJEHHJgZ7hT)5J2nxUxJEHJwD2nPamXx0llAEJPO1nAtNxgZ5Ou04BwJM4fLEWSF0ggfkAK5NWAuhDKJMp69JM3rRo7Muq0y(erByuOOpEuCmvJZErN9bvGsUuHib2iYga5I1aqzZbIVbgbwoBCujv5au6InlB08j2QUo7NdZQlPxRWZlsgi)WtaqLEhvsICccLdgUcpVizG8dpbavgz6ZdoLhmWqDj9A1a5x7B6aLyv6DujjYbUiPmPo7MuqfaXXMd0Na6YmpfXjWad)OeBuQopH1Oo6ihnFLEhvsICOCWWvqEt0vcslCsqUcv5UYbUiPmPo7MuqfaXXMd0Na6YmpfbVX2pkXgLQOsxqP5tkeLaqUynaQ07OssGP4Sx0zFqfOKlvisGnISbqCS5a9jGUmt(gyeGlsktQZUjfymcEhN9Io7dQaLCPcrcSrKnaYfRbGYMdKfhCrfl)gDe8yvRAT]] )


end
