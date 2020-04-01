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


    spec:RegisterSetting( "mfd_waste", true, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If unchecked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
        width = "full"
    } )  


    spec:RegisterPack( "Subtlety", 20200330, [[davGRbqiLs9iqQ2Ke6tkPGgLsjNsjXQaPOxHQywue3IIe7su)sjyykP6yOkTmjONbLQPjr01Oi12usrFtjL04KiW5usPSoLuQMNsO7bf7JIY)aPKIdkrOwOsspKIKMOejxujfyJqPKpkrimsqkP6KGuQwji5LseIMPeHKBcsPStkQ(PeHudfKclfkL6Pq1uLaxvIG2kiL4RkPqNfKskTxk9xrgSuhwyXq6XsAYeUmYMH4ZGy0G60kwniLKxRenBIUnf2nWVvz4kvhxjLy5O8CvnDsxhv2ouY3rvnEOuCEjQ1lrQ5RuSFQ2YRTalUiuYAEHRx46RJDSVEUW1510RJDlUwENS47rDzaHS4GWGS44COQK0Yw89OS8cHTal(FCSkzXHvD)x7lSaKrH5qZ1ZyHFm4KHohOYceDHFmQlyXr5gPcTdSOwCrOK18cxVW1xh7yF9CHRZBjn9AZIhCk8XS44JHPAXHhHGawulUG(Qfh6EJZHQssl7n2(GWrouq3Byv3)1(clazuyo0C9mw4hdozOZbQSarx4hJ6couq3BOTGvH9g7RBI3fUEHR7q5qbDVnv4aaH(1Udf092u8UeleKW7sKtDP365TGqcoP6Du15aElNxZouq3BtXBSnzCyrcV1GbH00G4D9aIrNd49b8gAlyljH3ihZ7srHcNDOGU3MI3LyHGeExcFYBODLm(SfxoV(2cS4VsHuHjHTaR58AlWItGavsc7Qw8kBuInHfFlV1qsanJmarIpflb0)zceOss49MnE)7KuM0GbH0p)WCSzjbsVEmdVx0BS79kEx07T8gLdbj)kfsfoZT79MnEJYHGKXkaZdN529EflEu15aw8hoeh)xzZsYQwZl0wGfNabQKe2vT4v2OeBclokhcs(H5yZscK0JbcXL529UO31Za9s73a0pliKPoQ3lIX7cT4rvNdyXRHuMIQohijNxT4Y51eimiloYaMh2QwZXUTalobcujjSRAXRSrj2ew8FNKYKgmiK(5hMJnljq61Jz4ngVlP3f9UEgOxA)gG(EBggVlPfpQ6CalEnKYuu15aj58QfxoVMaHbzXrgW8Ww1AEjTfyXjqGkjHDvlELnkXMWIxpd0lTFdq)SGqM6OEVigV51BtX7T8wdjb0SGODILELfAaHmYeiqLKW7IEVL3OCiizScW8WzUDV3SX7O0eBukRWuczyVMebOszceOss4DrV32BnKeqZIGTm9WH44NjqGkjH3f9EBV1qsan)COkXq4GqzceOss4DrV)DsktAWGq6NFyo2SKaPxpMH3l6n29EfVxXIhvDoGfVgszkQ6CGKCE1IlNxtGWGS4idyEyRAn302cS4eiqLKWUQfVYgLytyXJstSrP8oXqowOuMfGLEBggVl07IE)7KuM0GbH0p)WCSzjbsVEmdVxeJ3fAXJQohWIdrENbQmeKvTMVM2cS4eiqLKWUQfpQ6Cal(dhIJ)RSzjzXRSrj2ewCnKeqZpvzKMuQcdM1chLjqGkjH3f9wdjb0mYaej(uSeq)NjqGkjH3f9wqOCiizKbis8PyjG(pZiJyaV3l6nVEx07FNKYKgmiK(5hMJnljq61Jz4ngVl07IERJbL0ljgYBtXBgzed492mVxtlETCvsjnyqi9TMZRvTMVwTfyXjqGkjHDvlELnkXMWIVT3AijGMfeTtS0RSqdiKrMabQKeEx07O0eBukJkdbLgqsHP0dhIJ)NzbyP3y8g7Ex07FNKYKgmiK(5hMJnljq61Jz4ngVXUfpQ6Cal(dhIJ)RSzjzvR5LaBbwCceOssyx1IxzJsSjS4yfSjqLuM7P0oBo2OLtStdDoG3f9ElV1qsanJmarIpflb0)zceOss4DrVfekhcsgzaIeFkwcO)ZmYigW79IEZR3B24TgscOz(uSFaJ4vILjqGkjH3f9(3jPmPbdcPF(H5yZscKE9ygEVigVlP3B24DuAInkLhaH1Ob6ihTCMabQKeEx0BuoeK8x2a9KF6qscku4m3U3f9(3jPmPbdcPF(H5yZscKE9ygEVigVXU384DuAInkLrLHGsdiPWu6HdXX)ZeiqLKW7vS4rvNdyXF4qC8FLnljRAnFTzlWItGavsc7Qw8kBuInHf)3jPmPbdcPV3MHXBSBXJQohWI)WCSzjbsVEmdRAnN31TfyXJQohWI)WH44)kBwswCceOssyx1Qw1It)tGk92cSMZRTalobcujjSRAXRSrj2ewCcqmiLZ6yqj9sgb24TzEZR3f9EBVr5qqYFzd0t(PdjjOqHZC7Ex07T8EBVfNMRhOsaLfkjsiYWGsOCmqwN6YbaX7IEVT3rvNdKRhOsaLfkjsiYWGYdiHihiWQ3B24ncNuMyufoyqOKogK3l6nKQiBeyJ3RyXJQohWIxpqLaklusKqKHbzvR5fAlWItGavsc7Qw8kBuInHfFBVR3jfhFq(HdXXpHkdb9zUDVl6D9oP44dYFzd0t(PdjjOqHZC7EVzJ36yqj9sIH8ErmEZ76w8OQZbS4OY7ePdjPWuIaKrzRAnh72cS4rvNdyXHWfmXeG0HKIstStHT4eiqLKWUQvTMxsBbwCceOssyx1IxzJsSjS4B59Vtszsdges)8dZXMLei96Xm82mmExO3B24nlgrIWIaAoeIppaVnZ71CDVxX7IEVT317KIJpi)Lnqp5NoKKGcfoZT7DrV32BuoeK8x2a9KF6qscku4m3U3f9Maeds5SGqM6OEBggVX(6w8OQZbS4ixL7jrkknXgLsOuyyvR5M2wGfNabQKe2vT4v2OeBcl(Vtszsdges)8dZXMLei96Xm82mmExO3B24nlgrIWIaAoeIppaVnZ71CDlEu15aw8Do2GuEaqsOY4vRAnFnTfyXjqGkjHDvlELnkXMWIJYHGKzuDPK(pHCSkL529EZgVr5qqYmQUus)NqowLs1JdOel)Aux69IEZ76w8OQZbS4kmL4aOhhqKqowLSQ181QTalEu15awC2SVlP0as)EujlobcujjSRAvR5LaBbwCceOssyx1IxzJsSjS417KIJpi)Lnqp5NoKKGcfoZiJyaV3l6TP9EZgV1XGs6Led59IEZBjWIhvDoGfN)XKcSObKy0FGaujRAnFTzlWItGavsc7Qw8kBuInHfNaedszVx07sUU3f9gLdbj)Lnqp5NoKKGcfoZTBXJQohWIBqghRC6qssU6iscgfgVvTMZ762cS4eiqLKWUQfpQ6CaloJI9bajHidd6T4v2OeBclUgmiKM1XGs6Led59IEZB20EVzJ3B59wERbdcPzykKkCEVQEBM3LG19EZgV1GbH0mmfsfoVxvVxeJ3fUU3R4DrV3Y7OQdwuIaKXqV3y8MxV3SXBnyqinRJbL0ljgYBZ8UW1M3R49kEVzJ3B5TgmiKM1XGs6L2RAQW192mVX(6Ex07T8oQ6GfLiazm07ngV517nB8wdgesZ6yqj9sIH82mVlzj9EfVxXIxlxLusdgesFR58AvRAXfesWjvBbwZ51wGfNabQKe2vT4v2OeBcl(2E)kfsfMez2bHJS4rvNdyXxo1Lw1AEH2cS4rvNdyXFLcPcBXjqGkjHDvRAnh72cS4eiqLKWUQfpQ6CalEnKYuu15aj58QfxoVMaHbzXRI3QwZlPTalobcujjSRAXRSrj2ew8xPqQWKihsPfpQ6CaloJdKIQohijNxT4Y51eimil(RuivysyvR5M2wGfNabQKe2vT4v2OeBclUogusVKyiVnZ7107IEZiJyaV3l6nKQiBeyJ3f9UEgOxA)gG(EBggVlP3MI3B5TogK3l6nVR79kEdn9UqlEu15awCWabwrLHGSQ1810wGfNabQKe2vT43Uf)j1IhvDoGfhRGnbQKS4yfsoYIVZMJnA5e70qNd4DrV)DsktAWGq6NFyo2SKaPxpMH3MHX7cT4yfSeimilo3tPD2CSrlNyNg6CaRAnFTAlWItGavsc7Qw8kBuInHfhRGnbQKYCpL2zZXgTCIDAOZbS4rvNdyXRHuMIQohijNxT4Y51eimil(Ruiv4uv8w1AEjWwGfNabQKe2vT43Uf)j1IhvDoGfhRGnbQKS4yfsoYIxOP9MhV1qsanJ1a5yzceOss4n00BSBAV5XBnKeqZgXRelDiPhoeh)ptGavscVHMExOP9MhV1qsan)WH44NqUk3NjqGkjH3qtVlCDV5XBnKeqZHmQSrlNjqGkjH3qtV5DDV5XBEnT3qtV3Y7FNKYKgmiK(5hMJnljq61Jz4Tzy8g7EVIfhRGLaHbzXFLcPcNuyg9WNuyvR5RnBbwCceOssyx1IxzJsSjS4eGyqkNfeYuh17fX4nwbBcujLFLcPcNuyg9WNuyXJQohWIxdPmfvDoqsoVAXLZRjqyqw8xPqQWPQ4TQ1CEx3wGfNabQKe2vT4v2OeBclEuAInkLbdey9tyraiuaQuMabQKeEx07T9gLdbjdgiW6NWIaqOauPm3U3f9UEgOxA)gG(zbHm1r92mV517IEVL3)ojLjnyqi9ZpmhBwsG0RhZW7f9UqV3SXBSc2eOskZ9uANnhB0Yj2PHohW7v8UO3B5D9oP44dYFzd0t(PdjjOqHZmYigW79Iy8g7EVzJ3B5DuAInkLbdey9tyraiuaQuMfGLEBggVl07IEJYHGK)YgON8thssqHcNzKrmG3BZ8g7Ex07T9(vkKkmjYHu6DrVR3jfhFq(HdXXpjcqLYv4GbH(eclQ6CGq6Tzy8E98AZ7v8EflEu15awCWabwrLHGSQ1CE51wGfNabQKe2vT4v2OeBclE9mqV0(na9ZcczQJ69Iy8MxV3SXBDmOKEjXqEVigV517IExpd0lTFdqFVndJ3y3IhvDoGfVgszkQ6CGKCE1IlNxtGWGS4idyEyRAnN3cTfyXjqGkjHDvlELnkXMWI)7KuM0GbH0p)WCSzjbsVEmdVX4Dj9UO31Za9s73a03BZW4DjT4rvNdyXRHuMIQohijNxT4Y51eimiloYaMh2QwZ5f72cS4eiqLKWUQfVYgLytyXjaXGuoliKPoQ3lIXBSc2eOsk)kfsfoPWm6HpPWIhvDoGfVgszkQ6CGKCE1IlNxtGWGS4OCJuyvR58wsBbwCceOssyx1IxzJsSjS4eGyqkNfeYuh1BZW4nVM2BE8Maeds5mJGqalEu15aw8GvdaL0JXiGAvR58AABbw8OQZbS4bRgakTZjFYItGavsc7Qw1AoVRPTalEu15awC5abw)e0kobedcOwCceOssyx1QwZ5DTAlWIhvDoGfhnGKoKKYM6Y3ItGavsc7Qw1Qw8Dgvpd0qTfynNxBbw8OQZbS4VsHuHT4eiqLKWUQvTMxOTalobcujjSRAXJQohWIBeSLKiHCSKGcf2IVZO6zGgA6P6beVfNxtBvR5y3wGfNabQKe2vT4GWGS4rPF4GfFc5aA6qs7hFIzXJQohWIhL(Hdw8jKdOPdjTF8jMvTMxsBbw8OQZbS47NohWItGavsc7Qw1QwCKbmpSTaR58AlWItGavsc7QwCKJLae2OwZ51IhvDoGfF)ozIr)XXQKvTMxOTalobcujjSRAXRSrj2ewCuoeKmyGaRFclcaHcqLYC7Ex07T8(3jPmPbdcPF(H5yZscKE9ygEVO3f69MnEJvWMavszUNs7S5yJwoXon05aEVzJ3B7TgscO5NQmstkvHbZAHJYeiqLKW7nB8EBVR3jfhFq(PkJ0KsvyWSw4Om3U3RyXJQohWItynFLyHsw1Ao2TfyXjqGkjHDvlELnkXMWIVL3B7TgscOzrWwME4qC8ZeiqLKW7nB8EBVr5qqYpCio(jraQuMB37v8UO36yqj9sIH82u8MrgXaEVnZ7107IEZiJyaV3l6To1LjDmiVHMExOfpQ6CaloyGaROYqqw1AEjTfyXjqGkjHDvlEu15awCWabwrLHGS4v2OeBcl(2EJvWMavszUNs7S5yJwoXon05aEx07FNKYKgmiK(5hMJnljq61Jz4Tzy8UqVl69wEhLMyJszWabw)eweacfGkLjqGkjH3B2492EhLMyJszgTlNAOdas6HdXX)ZeiqLKW7nB8(3jPmPbdcPF(H5yZscKE9ygEBkEhvDWIsItZGbcSIkdb5Tzy8UqVxX7IEVT3OCii5hoeh)KiavkZT7DrV1XGs6Led5Tzy8ElVnT3849wExO3qtVRNb6L2VbOV3R49kEx0BgHWOhoqLKfVwUkPKgmiK(wZ51QwZnTTalobcujjSRAXRSrj2ewCgzed49ErVR3jfhFq(lBGEYpDijbfkCMrgXaEV5XBEx37IExVtko(G8x2a9KF6qscku4mJmIb8EVigVnT3f9whdkPxsmK3MI3mYigW7TzExVtko(G8x2a9KF6qscku4mJmIb8EZJ3M2IhvDoGfhmqGvuziiRAnFnTfyXJQohWI)uLrAsPkmywlCKfNabQKe2vTQ181QTalEu15awCcR5ReluYItGavsc7Qw1Qw8Q4TfynNxBbwCceOssyx1IxzJsSjS4B7nkhcs(HdXXpjcqLYC7Ex0BuoeK8dZXMLeiPhdeIlZT7DrVr5qqYpmhBwsGKEmqiUmJmIb8EVigVXE20w8OQZbS4pCio(jraQKfN7P0HGKGufwZ51QwZl0wGfNabQKe2vT4v2OeBclokhcs(H5yZscK0JbcXL529UO3OCii5hMJnljqspgiexMrgXaEVxeJ3ypBAlEu15aw8VSb6j)0HKeuOWwCUNshcscsvynNxRAnh72cS4eiqLKWUQfVYgLytyX327xPqQWKihsP3f9wCAgmqGvuziOSo1LdaIfpQ6CalEnKYuu15aj58QfxoVMaHbzXP)jqLERAnVK2cS4eiqLKWUQfpQ6Cal((DYeJ(JJvjlELnkXMWIVT3AijGMF4qC8tixL7ZeiqLKWIJCSeGWg1AoVw1AUPTfyXjqGkjHDvlELnkXMWItaIbPS3MHX71CDVl6T40myGaROYqqzDQlhaeVl6D9oP44dYFzd0t(PdjjOqHZC7Ex076DsXXhKF4qC8tIauPCfoyqO3BZW4nVw8OQZbS4pmhBwsGKEmqioRAnFnTfyXjqGkjHDvlELnkXMWIlondgiWkQmeuwN6YbaX7IEVT317KIJpi)WH44NqLHG(m3U3f9ElV32BnKeqZpmhBwsGKEmqiUmbcujj8EZgV1qsan)WH44NqUk3NjqGkjH3B24D9oP44dYpmhBwsGKEmqiUmJmIb8EBM3f69kEx07T8EBVP)jqLYOY7ePdjPWuIaKr5SraT6yEVzJ317KIJpiJkVtKoKKctjcqgLZmYigW7TzExO3R4DrV3Y7O0eBukdgiW6NWIaqOauPmlal9ErVl07nB8gLdbjdgiW6NWIaqOauPm3U3RyXJQohWI)Lnqp5NoKKGcf2QwZxR2cS4eiqLKWUQfpQ6CalUrWwsIeYXsckuylELnkXMWIZIrKiSiGMdH4ZC7Ex07T8wdgesZ6yqj9sIH8ErVRNb6L2VbOFwqitDuV3SX7T9(vkKkmjYHu6DrVRNb6L2VbOFwqitDuVndJ319KrGnPFNacVxXIxlxLusdgesFR58AvR5LaBbwCceOssyx1IxzJsSjS4SyejclcO5qi(8a82mVX(6EBkEZIrKiSiGMdH4ZcowOZb8UO3B79RuivysKdP07IExpd0lTFdq)SGqM6OEBggVR7jJaBs)obew8OQZbS4gbBjjsihljOqHTQ181MTalobcujjSRAXRSrj2ew8T9(vkKkmjYHu6DrVfNMbdeyfvgckRtD5aG4DrVRNb6L2VbOFwqitDuVndJ3fAXJQohWI)WH44NqLHGERAnN31TfyXjqGkjHDvlELnkXMWIRHKaA(HdXXpHCvUptGavscVl6T40myGaROYqqzDQlhaeVl6nkhcs(lBGEYpDijbfkCMB3IhvDoGf)H5yZscK0JbcXzvR58YRTalobcujjSRAXRSrj2ew8T9gLdbj)WH44NebOszUDVl6TogusVKyiVxeJ3M2BE8wdjb08ZHQedHdcLjqGkjH3f9EBVzXiseweqZHq8zUDlEu15aw8hoeh)KiavYQwZ5TqBbwCceOssyx1IxzJsSjS4OCiizu5Dcj3Rzgfv17nB8gLdbj)Lnqp5NoKKGcfoZT7DrV3YBuoeK8dhIJFcvgc6ZC7EVzJ317KIJpi)WH44NqLHG(mJmIb8EVigV5DDVxXIhvDoGfF)05aw1AoVy3wGfNabQKe2vT4v2OeBclokhcs(lBGEYpDijbfkCMB3IhvDoGfhvENiHWXkBvR58wsBbwCceOssyx1IxzJsSjS4OCii5VSb6j)0HKeuOWzUDlEu15awCuI9eB5aGyvR58AABbwCceOssyx1IxzJsSjS4OCii5VSb6j)0HKeuOWzUDlEu15awCKHrOY7ew1AoVRPTalobcujjSRAXRSrj2ewCuoeK8x2a9KF6qscku4m3UfpQ6CalEaQ0RSqMQHuAvR58UwTfyXjqGkjHDvlEu15aw8A5Q8u2bMAcvgVAXRSrj2ew8T9(vkKkmjYHu6DrVfNMbdeyfvgckRtD5aG4DrV32BuoeK8x2a9KF6qscku4m3U3f9Maeds5SGqM6OEBggVX(6wCcbHQAcegKfVwUkpLDGPMqLXRw1AoVLaBbwCceOssyx1IhvDoGfpk9dhS4tihqthsA)4tmlELnkXMWIVT3OCii5hoeh)KiavkZT7DrVR3jfhFq(lBGEYpDijbfkCMrgXaEVx0BEx3IdcdYIhL(Hdw8jKdOPdjTF8jMvTMZ7AZwGfNabQKe2vT4rvNdyXJhgRaqFIfL(yP6XcPfVYgLytyXfekhcsMfL(yP6XczsqOCiizXXh49MnEliuoeKC9acUQoyrPbSmjiuoeKm3U3f9wdgesZ6yqj9s7vnH919ErVnT3B2492EliuoeKC9acUQoyrPbSmjiuoeKm3U3f9ElVfekhcsMfL(yP6XczsqOCii5xJ6sVndJ3fAAVnfV5DDVHMEliuoeKmQ8or6qskmLiazuoZT79MnERJbL0ljgY7f9UKR79kEx0BuoeK8x2a9KF6qscku4mJmIb8EBM3LaloimilE8Wyfa6tSO0hlvpwiTQ18cx3wGfNabQKe2vT4GWGS4gLfXN0qoVraS4rvNdyXnklIpPHCEJayvR5fYRTalobcujjSRAXRSrj2ewCuoeK8x2a9KF6qscku4m3U3B24TogusVKyiVx07cx3IhvDoGfN7P0OKXBvRAXFLcPcNQI3wG1CETfyXjqGkjHDvl(TBXFsT4rvNdyXXkytGkjlowHKJS417KIJpi)WH44NebOs5kCWGqFcHfvDoqi92mmEZBETAAlowblbcdYI)WIKcZOh(KcRAnVqBbwCceOssyx1IxzJsSjS4B7nwbBcujLFyrsHz0dFsH3f9UEgOxA)gG(zbHm1r92mV517IEliuoeKmYaej(uSeq)NzKrmG37f9MxVl6D9oP44dYFzd0t(PdjjOqHZmYigW7Tzy8g7w8OQZbS4yfG5HTQ1CSBlWItGavsc7Qw8OQZbS473jtm6powLS4e2OSifghhqT4LCDloYXsacBuR58AvR5L0wGfNabQKe2vT4v2OeBclobigKYEBggVl56Ex0BcqmiLZcczQJ6Tzy8M319UO3B7nwbBcujLFyrsHz0dFsH3f9UEgOxA)gG(zbHm1r92mV517IEliuoeKmYaej(uSeq)NzKrmG37f9MxlEu15aw8hoehFdskSQ1CtBlWItGavsc7Qw8B3I)KAXJQohWIJvWMavswCScjhzXRNb6L2VbOFwqitDuVndJ3L0BtX7T8wdjb0SGODILELfAaHmYeiqLKW7IEVL3rPj2OuwHPeYWEnjcqLYeiqLKW7IEVT3AijGMfbBz6HdXXptGavscVl692ERHKaA(5qvIHWbHYeiqLKW7IE)7KuM0GbH0p)WCSzjbsVEmdVx0BS79kEVIfhRGLaHbzXFyrQEgOxA)gG(w1A(AAlWItGavsc7Qw8B3I)KAXJQohWIJvWMavswCScjhzXRNb6L2VbOFwqitDuVxeJ386npExO3qtVJstSrPSctjKH9AseGkLjqGkjHfVYgLytyXXkytGkPm3tPD2CSrlNyNg6CaVl69wERHKaAgmqG1xd5sILjqGkjH3B24TgscOzrWwME4qC8ZeiqLKW7vS4yfSeimil(dls1Za9s73a03QwZxR2cS4eiqLKWUQfVYgLytyXXkytGkP8dls1Za9s73a037IEVL3B7TgscOzrWwME4qC8ZeiqLKW7nB8wCAgmqGvuziOmJmIb8EBggVnT384TgscO5NdvjgchektGavscVxX7IEVL3yfSjqLu(HfjfMrp8jfEVzJ3OCii5VSb6j)0HKeuOWzgzed492mmEZBUqV3SX7FNKYKgmiK(5hMJnljq61Jz4Tzy8UKEx076DsXXhK)YgON8thssqHcNzKrmG3BZ8M319EfVl69wEhLMyJszWabw)eweacfGkLzbyP3l6DHEVzJ3OCiizWabw)eweacfGkL529EflEu15aw8hoeh)KiavYQwZlb2cS4eiqLKWUQfVYgLytyXXkytGkP8dls1Za9s73a037IERJbL0ljgY7f9UENuC8b5VSb6j)0HKeuOWzgzed49UO3B7nlgrIWIaAoeIpZTBXJQohWI)WH44NebOsw1QwCuUrkSfynNxBbwCceOssyx1IxzJsSjS4)ojLjnyqi992mmExO3849wERHKaAgI8oduziOmbcujj8UO3rPj2OuENyihlukZcWsVndJ3f69kw8OQZbS4pmhBwsG0RhZWQwZl0wGfpQ6Caloe5DgOYqqwCceOssyx1QwZXUTalEu15awC0OU81a1ItGavsc7Qw1Qw1IJfX(5awZlC9cxF9c5Tqlo)GbgaK3IdTBSFmLeExc8oQ6CaVLZRF2HYI)7u1AEHRjVw8D2HmsYIdDVX5qvjPL9gBFq4ihkO7nSQ7)AFHfGmkmhAUEgl8JbNm05avwGOl8JrDbhkO7n0wWQWEJ91nX7cxVW1DOCOGU3MkCaGq)A3Hc6EBkExIfcs4DjYPU0B98wqibNu9oQ6CaVLZRzhkO7TP4n2MmoSiH3AWGqAAq8UEaXOZb8(aEdTfSLKWBKJ5DPOqHZouq3BtX7sSqqcVlHp5n0UsgF2HYHc6EVgGnuLtjH3OeYXiVRNbAOEJsqgWN9UexR0U(EdoGPahmdeoP3rvNd8EFaz5Sdf09oQ6CGpVZO6zGgkgez8lDOGU3rvNd85Dgvpd0q5bZcbhedcOHohWHc6EhvDoWN3zu9mqdLhmlGCNWHc6EJdI9h(uVzXi8gLdbHeE)AOV3OeYXiVRNbAOEJsqgW7DaeEVZitz)uDaq8EEVfhGYouq37OQZb(8oJQNbAO8GzHhe7p8PPxd9DOIQoh4Z7mQEgOHYdMfELcPc7qfvDoWN3zu9mqdLhmlyeSLKiHCSKGcf2KDgvpd0qtpvpG4XWRPDOIQoh4Z7mQEgOHYdMf4EknkzycimimrPF4GfFc5aA6qs7hFI5qfvDoWN3zu9mqdLhmlSF6CahkhkO79Aa2qvoLeEtyrSYERJb5TctEhv9yEpV3bwXidujLDOGU3yB6vkKkS3dI373)dQK8ElW5nwCsaXcuj5nbiJHEVhG31Zan0vCOIQoh4XSCQlnzqWS9RuivysKzheoYHkQ6CGNhml8kfsf2Hc6EBQWuDP3MAPEVd1BKH9Qdvu15appywOgszkQ6CGKCE1eqyqyQI3Hc6EJT5aEJWjLL9(5pAfMEV1ZBfM8gxPqQWKWBS9PHohW7Tql7T4gaeV)ZeVh1BKJvP3797KdaI3dI3GtHhaeVN37aRyKbQKwj7qfvDoWZdMfyCGuu15aj58QjGWGW8kfsfMeMmiyELcPctICiLouq37s8(USS3MpqGvuziiVd17c5XBtfA4TGJnaiERWK3id7vV5DDVFQEaXBI3bIsmVv4q9UK84TPcn8Eq8EuVjSzFy07n)rHhG3km5nGWg17seMAP8(yEpV3Gt9MB3HkQ6CGNhmlagiWkQmeKjdcgDmOKEjXqMTMfzKrmGFrivr2iWMI1Za9s73a03mmL0u2shdArExFfOzHouq37s0azzVRWbac5n70qNd49G4nFYB4alY7D2CSrlNyNg6CaVFs9oacVn4K6SljV1GbH03BU9Sdvu15appywaRGnbQKmbegegUNs7S5yJwoXon05aMGvi5im7S5yJwoXon05af)DsktAWGq6NFyo2SKaPxpMHzyk0Hc6EdnyZXgTS3y7tdDoa0A8UefPRHV3qgSiVdVRSy37a94uVjaXGu2BKJ5TctE)kfsf2BtTuV3BHYnsbX8(1rk9Mr)ovvVhDLS3qRLB3eVh17Aa8gL8wHd17Fm2Lu2HkQ6CGNhmludPmfvDoqsoVAcimimVsHuHtvXBYGGbRGnbQKYCpL2zZXgTCIDAOZbCOGU3LWNeERN3cczaK38HjG365n3tE)kfsf2BtTuV3hZBuUrki27qfvDoWZdMfWkytGkjtaHbH5vkKkCsHz0dFsHjyfsoctHMMhnKeqZynqowMabQKeqtSBAE0qsanBeVsS0HKE4qC8)mbcujjGMfAAE0qsan)WH44NqUk3NjqGkjb0SW15rdjb0CiJkB0YzceOssan5DDE410qZT(DsktAWGq6NFyo2SKaPxpMHzyW(kouq3Bt9a)iiM3C)aG4D4nUsHuH92ulL38HjG3mkQWdaI3km5nbigKYERWm6HpPWHkQ6CGNhmludPmfvDoqsoVAcimimVsHuHtvXBYGGHaeds5SGqM6OlIbRGnbQKYVsHuHtkmJE4tkCOGU3MpqG11W3BOfcaHcqLw7EB(abwrLHG8gLqog5nEzd0t(EhQ3YJV3Mk0WB98UEgOdG8McMSS3mcHrpS38hf2BiKQdaI3km5nkhcI3C7zVlXY)8wE892uHgEl4ydaI34Lnqp57nkP8jc4DPcqLEV5pkS3fYJ3MdTKDOIQoh45bZcGbcSIkdbzYGGjknXgLYGbcS(jSiaekavktGavsIIBJYHGKbdey9tyraiuaQuMBVy9mqV0(na9ZcczQJAgVf363jPmPbdcPF(H5yZscKE9yglw4MnyfSjqLuM7P0oBo2OLtStdDoWkf3QENuC8b5VSb6j)0HKeuOWzgzed4xed23SzRO0eBukdgiW6NWIaqOauPmlalndtHfr5qqYFzd0t(PdjjOqHZmYigWBg2lU9RuivysKdPSy9oP44dYpCio(jraQuUchmi0NqyrvNdesZWSEETTYkouq3BS1aMh27q9UK84n)rHpo17sHBI3MMhV5pkS3Lc37Too9hb59Ruiv4vCOIQoh45bZc1qktrvNdKKZRMacdcdYaMh2Kbbt9mqV0(na9ZcczQJUigE3SrhdkPxsm0Iy4Ty9mqV0(na9ndd2DOGU3RXrH9Uu4EhY)8gzaZd7DOExsE8oGed4vVjSjQQSS3L0Bnyqi99ERJt)rqE)kfsfEfhQOQZbEEWSqnKYuu15aj58QjGWGWGmG5HnzqW87KuM0GbH0p)WCSzjbsVEmdmLSy9mqV0(na9ndtjDOGU3LWN8o8gLBKcI5nFyc4nJIk8aG4TctEtaIbPS3kmJE4tkCOIQoh45bZc1qktrvNdKKZRMacdcdk3ifMmiyiaXGuoliKPo6IyWkytGkP8Ruiv4KcZOh(KchkO7DjQJp9Q37S5yJw27b4DiLEFiERWK3LyOrjkVrPAW9K3J6Dn4E69o8UeHPwkhQOQZbEEWSqWQbGs6XyeqnzqWqaIbPCwqitDuZWWRP5Haeds5mJGqahQOQZbEEWSqWQbGs7CYNCOIQoh45bZcYbcS(jOvCcigeqDOIQoh45bZcObK0HKu2ux(ououq37v5gPGyVdvu15aFgLBKcmpmhBwsG0RhZWKbbZVtszsdgesFZWuipBPHKaAgI8oduziOmbcujjkgLMyJs5DIHCSqPmlalndtHR4qfvDoWNr5gPGhmlarENbQmeKdvu15aFgLBKcEWSaAux(AG6q5qbDVn17KIJp4DOGU3LWN8UubOsEFiiMcKQWBuc5yK3km5nYWE1BCyo2SKaEJRhZWBe2z4DbhdeIZ76zqV3di7qfvDoWNRIhZdhIJFseGkzc3tPdbjbPkWWRjdcMTr5qqYpCio(jraQuMBVikhcs(H5yZscK0JbcXL52lIYHGKFyo2SKaj9yGqCzgzed4xed2ZM2Hc6EVvjeiP)9oKmkeL9MB3BuQgCp5nFYB9ULEJdhIJV3yRRY9R4n3tEJx2a9KV3hcIPaPk8gLqog5TctEJmSx9ghMJnljG346Xm8gHDgExWXaH48UEg079aYourvNd85Q45bZcFzd0t(PdjjOqHnH7P0HGKGufy41Kbbdkhcs(H5yZscK0JbcXL52lIYHGKFyo2SKaj9yGqCzgzed4xed2ZM2HkQ6CGpxfppywOgszkQ6CGKCE1eqyqyO)jqLEtgemB)kfsfMe5qklkondgiWkQmeuwN6YbaXHc6EdnUt6nYX8UGJbcX59oJmf8RuEZFuyVXHlL3mkeL9Mpmb8gCQ3moayaq8ghBLDOIQoh4ZvXZdMf2VtMy0FCSkzcYXsacBum8AYGGzBnKeqZpCio(jKRY9zceOss4qbDVlHp5DbhdeIZ7Dg5n(vkV5dtaV5tEdhyrERWK3eGyqk7nFysHjM3iSZW797KdaI38hf(4uVXXwEFmVHwX9Q3qiaXcPSC2HkQ6CGpxfppyw4H5yZscK0JbcXzYGGHaedszZWSMRxuCAgmqGvuziOSo1LdasX6DsXXhK)YgON8thssqHcN52lwVtko(G8dhIJFseGkLRWbdc9MHHxhkO7Dj8jVXlBGEY37d4D9oP44d8ERarjM3id7vVnFGaROYqqR4nhqs)7nFY7GrEd5gaeV1Z79B37cogieN3bq4T48gCQ3WbwK34WH447n26QCF2HkQ6CGpxfppyw4lBGEYpDijbfkSjdcgXPzWabwrLHGY6uxoaif3UENuC8b5hoeh)eQme0N52lU12AijGMFyo2SKaj9yGqCzceOssSzJgscO5hoeh)eYv5(mbcujj2SPENuC8b5hMJnljqspgiexMrgXaEZkCLIBTn9pbQugvENiDijfMseGmkNncOvhBZM6DsXXhKrL3jshssHPebiJYzgzed4nRWvkUvuAInkLbdey9tyraiuaQuMfGLlw4MnOCiizWabw)eweacfGkL52xXHc6EdTJ4DieV3bJ8MB3eVFWStERWK3hG8M)OWElp(0RExqbLk7Dj8jV5dtaVfLhaeVrIxjM3kCa82uHgEliKPoQ3hZBWPE)kfsfMeEZFu4Jt9oaL92uHgzhQOQZb(Cv88GzbJGTKejKJLeuOWMulxLusdgesFm8AYGGHfJiryranhcXN52lULgmiKM1XGs6LedTy9mqV0(na9ZcczQJUzZ2VsHuHjroKYI1Za9s73a0pliKPoQzyQ7jJaBs)obeR4qbDVH2r8gCEhcX7n)rk9wmK38hfEaERWK3acBuVX(6VjEZ9K3qBiLY7d4n69V38hf(4uVdqzVnvOH3bq4n48(vkKkC2HkQ6CGpxfppywWiyljrc5yjbfkSjdcgwmIeHfb0CieFEaMH91nfwmIeHfb0CieFwWXcDoqXTFLcPctICiLfRNb6L2VbOFwqitDuZWu3tgb2K(DciCOIQoh4ZvXZdMfE4qC8tOYqqVjdcMTFLcPctICiLffNMbdeyfvgckRtD5aGuSEgOxA)gG(zbHm1rndtHouq3714OWEJJTmX7bXBWPEhsgfIYEloazI3Cp5DbhdeIZB(Jc7n(vkV52ZourvNd85Q45bZcpmhBwsGKEmqiotgemAijGMF4qC8tixL7ZeiqLKOO40myGaROYqqzDQlhaKIOCii5VSb6j)0HKeuOWzUDhQOQZb(Cv88GzHhoeh)KiavYKbbZ2OCii5hoeh)KiavkZTxuhdkPxsm0IymnpAijGMFouLyiCqOmbcujjkUnlgrIWIaAoeIpZT7qfvDoWNRINhmlSF6CatgemOCiizu5Dcj3RzgfvDZguoeK8x2a9KF6qscku4m3EXTq5qqYpCio(juziOpZTVzt9oP44dYpCio(juziOpZiJya)Iy4D9vCOIQoh4ZvXZdMfqL3jsiCSYMmiyq5qqYFzd0t(PdjjOqHZC7ourvNd85Q45bZcOe7j2YbaXKbbdkhcs(lBGEYpDijbfkCMB3HkQ6CGpxfppywazyeQ8oHjdcguoeK8x2a9KF6qscku4m3Udvu15aFUkEEWSqaQ0RSqMQHuAYGGbLdbj)Lnqp5NoKKGcfoZT7qfvDoWNRINhmlW9uAuYWecbHQAcegeMA5Q8u2bMAcvgVAYGGz7xPqQWKihszrXPzWabwrLHGY6uxoaif3gLdbj)Lnqp5NoKKGcfoZTxKaeds5SGqM6OMHb7R7qfvDoWNRINhmlW9uAuYWeqyqyIs)Wbl(eYb00HK2p(eZKbbZ2OCii5hoeh)KiavkZTxSENuC8b5VSb6j)0HKeuOWzgzed4xK31DOGU3qleRS3SJdcSSS3moj59H4TcZzGoidj82iu43BusE8x7ExcFYBKJ5n0oy5(j8UYg1eVpfMy8NN8M)OWEJFLY7q9UqtZJ3Vg1LV3hZBEnnpEZFuyVd5FEVQ8oH3C7zhQOQZb(Cv88GzbUNsJsgMacdct8Wyfa6tSO0hlvpwinzqWiiuoeKmlk9Xs1JfYKGq5qqYIJpyZgbHYHGKRhqWv1blknGLjbHYHGK52lQbdcPzDmOKEP9QMW(6lA6nB2wqOCii56beCvDWIsdyzsqOCiizU9IBjiuoeKmlk9Xs1JfYKGq5qqYVg1LMHPqtBk8Uo0uqOCiizu5DI0HKuykraYOCMBFZgDmOKEjXqlwY1xPikhcs(lBGEYpDijbfkCMrgXaEZkbourvNd85Q45bZcCpLgLmmbegegJYI4tAiN3iaouq37sribNu9gjKs0OU0BKJ5n3hOsY7rjJFT7Dj8jV5pkS34Lnqp579H4DPOqHZourvNd85Q45bZcCpLgLmEtgemOCii5VSb6j)0HKeuOWzU9nB0XGs6LedTyHR7q5qbDVxd(Nav6DOIQoh4Z0)eOspM6bQeqzHsIeImmitgemeGyqkN1XGs6LmcSXmElUnkhcs(lBGEYpDijbfkCMBV4wBlonxpqLaklusKqKHbLq5yGSo1LdasXTJQohixpqLaklusKqKHbLhqcroqG1nBq4KYeJQWbdcL0XGwesvKncSzfhQOQZb(m9pbQ0ZdMfqL3jshssHPebiJYMmiy2UENuC8b5hoeh)eQme0N52lwVtko(G8x2a9KF6qscku4m3(Mn6yqj9sIHwedVR7qfvDoWNP)jqLEEWSaeUGjMaKoKuuAIDkSdvu15aFM(Nav65bZcixL7jrkknXgLsOuyyYGGzRFNKYKgmiK(5hMJnljq61JzygMc3SHfJiryranhcXNhGzR56RuC76DsXXhK)YgON8thssqHcN52lUnkhcs(lBGEYpDijbfkCMBVibigKYzbHm1rndd2x3HkQ6CGpt)tGk98GzHDo2GuEaqsOY4vtgem)ojLjnyqi9ZpmhBwsG0RhZWmmfUzdlgrIWIaAoeIppaZwZ1DOIQoh4Z0)eOsppywqHPeha94aIeYXQKjdcguoeKmJQlL0)jKJvPm3(MnOCiizgvxkP)tihRsP6XbuILFnQlxK31DOIQoh4Z0)eOsppywGn77sknG0VhvYHkQ6CGpt)tGk98Gzb(htkWIgqIr)bcqLmzqWuVtko(G8x2a9KF6qscku4mJmIb8lA6nB0XGs6LedTiVLahQOQZb(m9pbQ0ZdMfmiJJvoDijjxDejbJcJ3KbbdbigKYlwY1lIYHGK)YgON8thssqHcN52DOGU3qRFsH3yBk2haeVXwYWGEVroM3e2qvoL8MfaiK3hZ7LJu6nkhcYBI3dI373)dQKYExIL8JYV3kRS365nes9wHjVLhF6vVR3jfhFG3OXtcVpG3bwXiduj5nbiJH(Sdvu15aFM(Nav65bZcmk2haKeImmO3KA5QKsAWGq6JHxtgemAWGqAwhdkPxsm0I8Mn9MnBTLgmiKMHPqQW59QAwjy9nB0GbH0mmfsfoVx1fXu46RuCROQdwuIaKXqpgE3SrdgesZ6yqj9sIHmRW12kRSzZwAWGqAwhdkPxAVQPcx3mSVEXTIQoyrjcqgd9y4DZgnyqinRJbL0ljgYSswYvwXHYHc6EJTgW8We7DOIQoh4ZidyEym73jtm6powLmb5yjaHnkgEDOGU3RbynFLyHsEdhV3Wdey6vV3zZXgTS38hf2BZhiW6A47n0cbGqbOsEZTN9271aSPs76CaVN37s8Tg4TimciK38HjG34uTaQ698EZOquo7qfvDoWNrgW8W8GzbcR5ReluYKbbdkhcsgmqG1pHfbGqbOszU9IB97KuM0GbH0p)WCSzjbsVEmJflCZgSc2eOskZ9uANnhB0Yj2PHohyZMT1qsan)uLrAsPkmywlCuMabQKeB2SD9oP44dYpvzKMuQcdM1chL52xXHc6ExIKODV52928bcSIkdb59G49OEpV3b6XPERN3moG3hNM9UuN3Gt9M7jVnFvVfCSbaX7sfGkzI3dI3AijGscVhGEExQGT0BC4qC8ZourvNd8zKbmpmpywamqGvuziitgemBTTgscOzrWwME4qC8ZeiqLKyZMTr5qqYpCio(jraQuMBFLI6yqj9sIHmfgzed4nBnlYiJya)I6uxM0XGGMf6qbDVH24K6iovhaeVpo9hb5DPcqL8(aERbdcPV3kCOEZFKsVLdwK3ihZBfM8wWXcDoG3hI3MpqGvuziit8Mrim6H9wWXgaeV3dGGmMA2BOnoPoIt9oEVLhaI3X7DH84TgmiK(EloVbN6nCGf5T5deyfvgcYBUDV5pkS3yBAxo1qhaeVXHdXX)9EloGK(37YhN3WbwK3MpqG11W3BOfcaHcqL8wVBLSdvu15aFgzaZdZdMfadeyfvgcYKA5QKsAWGq6JHxtgemBJvWMavszUNs7S5yJwoXon05af)DsktAWGq6NFyo2SKaPxpMHzykS4wrPj2OugmqG1pHfbGqbOszceOssSzZ2rPj2OuMr7YPg6aGKE4qC8)mbcujj2S53jPmPbdcPF(H5yZscKE9ygMsu1blkjondgiWkQmeKzykCLIBJYHGKF4qC8tIauPm3ErDmOKEjXqMHzltZZwfcnRNb6L2VbO)kRuKrim6Hduj5qbDVX2ecJEyVnFGaROYqqEtbtw27bX7r9M)iLEtyZ(WiVfCSbaXB8YgON8ZExQZBfouVzecJEyVheVXVs5nesFVzuik79a8wHjVbe2OEB6p7qfvDoWNrgW8W8GzbWabwrLHGmzqWWiJya)I17KIJpi)Lnqp5NoKKGcfoZiJyapp8UEX6DsXXhK)YgON8thssqHcNzKrmGFrmMUOogusVKyitHrgXaEZQ3jfhFq(lBGEYpDijbfkCMrgXaEEmTdvu15aFgzaZdZdMfEQYinPufgmRfoYHkQ6CGpJmG5H5bZcewZxjwOKdLdf09gxPqQWEBQ3jfhFW7qbDVHwNK7eZBOLGnbQKCOIQoh4ZVsHuHtvXJbRGnbQKmbegeMhwKuyg9WNuycwHKJWuVtko(G8dhIJFseGkLRWbdc9jewu15aH0mm8MxRM2Hc6EdTeG5H9MdiP)9Mp5DWiVd0Jt9wpVRXU3hW7sfGk5DfoyqOp7DjAGSS38HjG3yRbi8EnsXsa9V3Z7DGECQ365nJd49XPzhQOQZb(8Ruiv4uv88GzbScW8WMmiy2gRGnbQKYpSiPWm6HpPOy9mqV0(na9ZcczQJAgVffekhcsgzaIeFkwcO)ZmYigWViVfR3jfhFq(lBGEYpDijbfkCMrgXaEZWGDhkO7n04oP3ihZBC4qC8niPWBE8ghoeh)xzZsYBoGK(3B(K3bJ8oqpo1B98Ug7EFaVlvaQK3v4GbH(S3LObYYEZhMaEJTgGW71iflb0)EpV3b6XPERN3moG3hNMDOIQoh4ZVsHuHtvXZdMf2VtMy0FCSkzcYXsacBum8AcHnklsHXXbumLCDhQOQZb(8Ruiv4uv88GzHhoehFdskmzqWqaIbPSzyk56fjaXGuoliKPoQzy4D9IBJvWMavs5hwKuyg9WNuuSEgOxA)gG(zbHm1rnJ3IccLdbjJmarIpflb0)zgzed4xKxhkO7TPcn8MrRfUHrgeqx7ExQaujVd1B5X3BtfA4nAzVfesWj1S3BHZHQSOQZb8EEVdVR3EzVryNH3km59RuiHjH3idyEyI5DnKsVroM3fGTkL3WbqihaK8kourvNd85xPqQWPQ45bZcyfSjqLKjGWGW8WIu9mqV0(na9nbRqYryQNb6L2VbOFwqitDuZWustzlnKeqZcI2jw6vwObeYitGavsIIBfLMyJszfMsid71KiavktGavsIIBRHKaAweSLPhoeh)mbcujjkUTgscO5NdvjgchektGavsII)ojLjnyqi9ZpmhBwsG0RhZyrSVYkouq3BtfA4nJwlCdJmiGU29UubOsEFazzVrjKJrEJmG5Hj279G4nFYB4alY7Wy3BnKeqFVdGW7D2CSrl7n70qNdKDOIQoh4ZVsHuHtvXZdMfWkytGkjtaHbH5HfP6zGEP9Ba6BcwHKJWupd0lTFdq)SGqM6OlIHxEkeAgLMyJszfMsid71KiavktGavsctgemyfSjqLuM7P0oBo2OLtStdDoqXT0qsandgiW6RHCjXYeiqLKyZgnKeqZIGTm9WH44NjqGkjXkouq3714OWExQGT0BC4qC89(aYYExQaujV5dtaVnFGaROYqqEZFKsVFnk7n3E27s4tEl4ydaI34Lnqp579X8oqpSiVvyg9WNuK9EngJ6nYX82COfVr5qq8M)OWExipMdTKDOIQoh4ZVsHuHtvXZdMfE4qC8tIaujtgemyfSjqLu(HfP6zGEP9Ba6xCRT1qsanlc2Y0dhIJFMabQKeB2iondgiWkQmeuMrgXaEZWyAE0qsan)COkXq4GqzceOssSsXTWkytGkP8dlskmJE4tk2SbLdbj)Lnqp5NoKKGcfoZiJyaVzy4nx4Mn)ojLjnyqi9ZpmhBwsG0RhZWmmLSy9oP44dYFzd0t(PdjjOqHZmYigWBgVRVsXTIstSrPmyGaRFclcaHcqLYSaSCXc3SbLdbjdgiW6NWIaqOauPm3(kouq37v5yaVzKrmGbaX7sfGk9EJsihJ8wHjV1GbHuVfd9EpiEJFLYB(hynu9gL8MrHOS3dWBDmOSdvu15aF(vkKkCQkEEWSWdhIJFseGkzYGGbRGnbQKYpSivpd0lTFdq)I6yqj9sIHwSENuC8b5VSb6j)0HKeuOWzgzed4lUnlgrIWIaAoeIpZT7q5qbDVXvkKkmj8gBFAOZbCOGU3q7iEJRuiv4fWkaZd7DWiV52nXBUN8ghoeh)xzZsYB98gLaeYOEJWodVvyY794)blYB0dW9EhaH3yRbi8EnsXsa9VjEtyraVheV5tEhmY7q92iWgVnvOH3BHWodVvyY7Dgvpd0q9gAdPuRKDOIQoh4ZVsHuHjbMhoeh)xzZsYKbbZwAijGMrgGiXNILa6)mbcujj2S53jPmPbdcPF(H5yZscKE9yglI9vkUfkhcs(vkKkCMBFZguoeKmwbyE4m3(kouq3BS1aMh27q9g784TPcn8M)OWhN6DPW9EbVljpEZFuyVlfU38hf2BCyo2SKaExWXaH48gLdbXBUDV1Z7aRBeE)Nb5TPcn8MF8k59pkxOZb(Sdvu15aF(vkKkmj4bZc1qktrvNdKKZRMacdcdYaMh2Kbbdkhcs(H5yZscK0JbcXL52lwpd0lTFdq)SGqM6OlIPqhkO7Djw(N3FGqERN3idyEyVd17sYJ3Mk0WB(Jc7nHnrvLL9UKERbdcPF27TWddY749(40FeK3VsHuHZR4qfvDoWNFLcPctcEWSqnKYuu15aj58QjGWGWGmG5HnzqW87KuM0GbH0p)WCSzjbsVEmdmLSy9mqV0(na9ndtjDOGU3yRbmpS3H6Dj5XBtfA4n)rHpo17sHBI3MMhV5pkS3Lc3eVdGW710B(Jc7DPW9oquI5n0saMh27J5DbWK3yRH9Q3LkavY7ai8gCExQGT0BC4qC89MhVbN34COkXq4GqourvNd85xPqQWKGhmludPmfvDoqsoVAcimimidyEytgem1Za9s73a0pliKPo6Iy41u2sdjb0SGODILELfAaHmYeiqLKO4wOCiizScW8WzU9nBIstSrPSctjKH9AseGkLjqGkjrXT1qsanlc2Y0dhIJFMabQKef3wdjb08ZHQedHdcLjqGkjrXFNKYKgmiK(5hMJnljq61JzSi2xzfhkO7Dj8jVlriVZavgcY7dlI5noCio(VYMLK3bq4nUEmdV5pkS3fYJ3qdIHCSqjVd17c9(yElP)9wdges)Sdvu15aF(vkKkmj4bZcqK3zGkdbzYGGjknXgLY7ed5yHszwawAgMcl(7KuM0GbH0p)WCSzjbsVEmJfXuOdf09UeRExO3AWGq67n)rH9gNQms9UaQcdM1ch59sI29MB3BS1aeEVgPyjG(3B0YExlxLdaI34WH44)kBwszhQOQZb(8RuivysWdMfE4qC8FLnljtQLRskPbdcPpgEnzqWOHKaA(PkJ0KsvyWSw4OmbcujjkQHKaAgzaIeFkwcO)ZeiqLKOOGq5qqYidqK4tXsa9FMrgXa(f5T4Vtszsdges)8dZXMLei96XmWuyrDmOKEjXqMcJmIb8MTMouq3714OWhN6DPiANyEJRSqdiKH3bq4n29gBhGLV3hI3Rkdb59a8wHjVXHdXX)9EuVN3B(htH9M7haeVXHdXX)v2SK8(aEJDV1GbH0p7qfvDoWNFLcPctcEWSWdhIJ)RSzjzYGGzBnKeqZcI2jw6vwObeYitGavsIIrPj2OugvgcknGKctPhoeh)pZcWsmyV4Vtszsdges)8dZXMLei96XmWGDhkO7n26yEVZMJnAzVzNg6Cat8M7jVXHdXX)v2SK8(WIyEJRhZWBExXB(Jc79AeAZ7asmGx9MB3B98UKERbdcPVjEx4kEpiEJTwJEpV3moayaq8(qq8ERd4Dak7DyCCa17dXBnyqi9xXeVpM3yFfV1ZBJaBgJP0K34xP8MWgLa)CaV5pkS3q7acRrd0roAzVpG3y3Bnyqi99ERs6n)rH9E1rXxj7qfvDoWNFLcPctcEWSWdhIJ)RSzjzYGGbRGnbQKYCpL2zZXgTCIDAOZbkULgscOzKbis8PyjG(ptGavsIIccLdbjJmarIpflb0)zgzed4xK3nB0qsanZNI9dyeVsSmbcujjk(7KuM0GbH0p)WCSzjbsVEmJfXuYnBIstSrP8aiSgnqh5OLZeiqLKOikhcs(lBGEYpDijbfkCMBV4Vtszsdges)8dZXMLei96Xmwed25jknXgLYOYqqPbKuyk9WH44)zceOssSIdvu15aF(vkKkmj4bZcpmhBwsG0RhZWKbbZVtszsdgesFZWGDhQOQZb(8RuivysWdMfE4qC8FLnljRAvRf]] )


end
