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

            disabled = function ()
                return not ( boss and group )
            end,

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


    spec:RegisterPack( "Subtlety", 20200514, [[daL3RbqiLsEeivBsc9jqkjJsjvNsjLvbsrVcvPzHQYTqvf7su)sjyykL6yqPwMeXZqv00KG6AOQQTPKiFtjr14qvqNtjHADkjkZtj09GI9rr5FGusPdQKalujPhIQknrjsUOeKQnIQaFucsPrcsjvNeKs1kbjVucc1mLGqUjiLYoPO6NsqkgkifwQee9uOAQsGRkbjBfKs8vLe0zbPKI9kYFP0GL6WclgspwstMWLr2meFgeJguNwXQLGGxRenBIUnf2nWVvz4kvhxjHSCuEUQMoPRJkBhk57uKXJQqNxIA9sKA(kf7NQtyNkiHlcLsMxY2LS928h7cN3MhY)vCjjCT8oLW3J6YacLWbHbLWX5qvjPLt47rz5fIubj8)4yvkHdR6(VYwybiJcZHMRNXc)yWjdDoqLfi6c)yuxiHJYnsfAhKqt4IqPK5LSDjBVn)XUW5T5H8FfJn)t4bNcFSeo(yWVjC4riiqcnHlOVMWHU34COQK0YExipiCKdf09gw19FLTWcqgfMdnxpJf(XGtg6CGklq0f(XOUGdf09gAlk7n2yZN3LSDjB7q5qbDV5x4aaH(vMdf09MF8EfieKW7cXtDP365TGqcoP6Du15aElNxZouq3B(X7cjzCyrcV1GbHu7G4D9aIrNd49b8gAlyljH3ihZ7srHcNDOGU38J3RaHGeExOEYBODLm(CcxoV(Pcs4VsHuHjrQGK5yNkiHtGavsI0Qj8kBuInrcFDV1qsanJmaH1eflb0)zceOss49MnE)7KuA1GbH0p)WCSzjbSVEmdVx0BE69AEx0719gLdbj)kfsfoZT79MnEJYHGKXkaZdN529ETeEu15aj8hoeNPxzZskPjZljvqcNabQKePvt4v2OeBIeokhcs(H5yZscy1JbcXL529UO31Za9S73a0pliKPoQ3lIX7ss4rvNdKWRHuAJQohWkNxt4Y5vlimOeoYaMhoPjZ5zQGeobcujjsRMWRSrj2ej8FNKsRgmiK(5hMJnljG91Jz4ngVlS3f9UEgOND)gG(EBggVlCcpQ6CGeEnKsBu15aw58AcxoVAbHbLWrgW8WjnzEHtfKWjqGkjrA1eELnkXMiHxpd0ZUFdq)SGqM6OEVigVX2B(X719wdjb0SGODIzFLfAaHmYeiqLKW7IEVU3OCiizScW8WzUDV3SX7O0eBukRWKfzyVAfbOszceOss4DrV3YBnKeqZIGT0(WH4mLjqGkjH3f9ElV1qsan)COkXq4GqzceOss4DrV)DskTAWGq6NFyo2SKa2xpMH3l6np9EnVxlHhvDoqcVgsPnQ6CaRCEnHlNxTGWGs4idyE4KMmN)Pcs4eiqLKiTAcVYgLytKWJstSrP8oXqowOuMfGLEBggVlX7IE)7KuA1GbH0p)WCSzjbSVEmdVxeJ3LKWJQohiHdrENbQmeustMVsPcs4eiqLKiTAcpQ6CGe(dhIZ0RSzjLWRSrj2ejCnKeqZpvzKAvQcdMvehLjqGkjH3f9wdjb0mYaewtuSeq)NjqGkjH3f9wqOCiizKbiSMOyjG(pZiJyaV3l6n2Ex07FNKsRgmiK(5hMJnljG91Jz4ngVlX7IERJbz1ZkgYB(XBgzed492mVxPeETCvswnyqi9tMJDstMVYtfKWjqGkjrA1eELnkXMiHVL3AijGMfeTtm7RSqdiKrMabQKeEx07O0eBukJkdbzhGvHj7dhIZ0NzbyP3y8MNEx07FNKsRgmiK(5hMJnljG91Jz4ngV5zcpQ6CGe(dhIZ0RSzjL0K58WubjCceOssKwnHxzJsSjs4yfSjqLuM7j7oBo2OLTStdDoG3f9EDV1qsanJmaH1eflb0)zceOss4DrVfekhcsgzacRjkwcO)ZmYigW79IEJT3B24TgscOztuSFaJ4vILjqGkjH3f9(3jP0QbdcPF(H5yZscyF9ygEVigVlS3B24DuAInkLhaH1Ob6ihTCMabQKeEx0BuoeK8x2a9KV9qScku4m3U3f9(3jP0QbdcPF(H5yZscyF9ygEVigV5P386DuAInkLrLHGSdWQWK9HdXz6ZeiqLKW71s4rvNdKWF4qCMELnlPKMmFfNkiHtGavsI0Qj8kBuInrc)3jP0QbdcPV3MHXBEMWJQohiH)WCSzjbSVEmJKMmh7TtfKWJQohiH)WH4m9kBwsjCceOssKwnPjnHt)tGk9PcsMJDQGeobcujjsRMWRSrj2ejCcqmiLZ6yqw9Sgbp6TzEJT3f9ElVr5qqYFzd0t(2dXkOqHZC7Ex0719ElVfNMRhOsaLfkjSiYWGSOCmqwN6YbaX7IEVL3rvNdKRhOsaLfkjSiYWGYdWIihiWQ3B24ncNuAzufoyqiRogK3l6nKQiBe8O3RLWJQohiHxpqLaklusyrKHbL0K5LKkiHtGavsI0Qj8kBuInrcFlVR3jfNjq(HdXzYIkdb9zUDVl6D9oP4mbYFzd0t(2dXkOqHZC7EVzJ36yqw9SIH8ErmEJ92j8OQZbs4OY7e2dXQWKLaKr5KMmNNPcs4rvNdKWHWfmXea7HyJstStHt4eiqLKiTAstMx4ubjCceOssKwnHxzJsSjs4R79VtsPvdges)8dZXMLeW(6Xm82mmExI3B24nlgHLWIaAoeIppaVnZ7vABVxZ7IEVL317KIZei)Lnqp5BpeRGcfoZT7DrV3YBuoeK8x2a9KV9qScku4m3U3f9Maeds5SGqM6OEBggV552j8OQZbs4ixL7jHnknXgLSOuyK0K58pvqcNabQKePvt4v2OeBIe(VtsPvdges)8dZXMLeW(6Xm82mmExI3B24nlgHLWIaAoeIppaVnZ7vA7eEu15aj8Do2GuEaqSOY41KMmFLsfKWjqGkjrA1eELnkXMiHJYHGKzuDPK(3ICSkL529EZgVr5qqYmQUus)BrowLS1JdOel)Aux69IEJ92j8OQZbs4kmz5aOhhqyrowLsAY8vEQGeEu15ajC2SVlj7aS)EuPeobcujjsRM0K58WubjCceOssKwnHxzJsSjs417KIZei)Lnqp5BpeRGcfoZiJyaV3l6n)9EZgV1XGS6zfd59IEJnpmHhvDoqc30XKcSObyz0FGauPKMmFfNkiHtGavsI0Qj8kBuInrcNaedszVx07cVT3f9gLdbj)Lnqp5BpeRGcfoZTNWJQohiHBqghRS9qSsU6iScgfgFstMJ92Pcs4eiqLKiTAcpQ6CGeoJI9baXIidd6t4v2OeBIeUgmiKM1XGS6zfd59IEJDM)EVzJ3R796ERbdcPzykKkCEVQEBM38WT9EZgV1GbH0mmfsfoVxvVxeJ3LST3R5DrVx37OQdwKLaKXqV3y8gBV3SXBnyqinRJbz1ZkgYBZ8UKvS3R59AEVzJ3R7TgmiKM1XGS6z3RQTKT92mV552Ex0719oQ6Gfzjazm07ngVX27nB8wdgesZ6yqw9SIH82mVlCH9EnVxlHxlxLKvdges)K5yN0KMWfesWj1ubjZXovqcNabQKePvt4v2OeBIe(wE)kfsfMez2bHJs4rvNdKWxo1LjnzEjPcs4rvNdKWFLcPcNWjqGkjrA1KMmNNPcs4eiqLKiTAcpQ6CGeEnKsBu15aw58AcxoVAbHbLWRIpPjZlCQGeobcujjsRMWRSrj2ej8xPqQWKihszcpQ6CGeoJdyJQohWkNxt4Y5vlimOe(RuivysK0K58pvqcNabQKePvt4v2OeBIeUogKvpRyiVnZ7vY7IEZiJyaV3l6nKQiBe8O3f9UEgOND)gG(EBggVlS38J3R7TogK3l6n2B79AEdn9UKeEu15ajCWabwrLHGsAY8vkvqcNabQKePvt43Ec)jnHhvDoqchRGnbQKs4yfsokHVZMJnAzl70qNd4DrV)DskTAWGq6NFyo2SKa2xpMH3MHX7ss4yfmlimOeo3t2D2CSrlBzNg6CGKMmFLNkiHtGavsI0Qj8kBuInrchRGnbQKYCpz3zZXgTSLDAOZbs4rvNdKWRHuAJQohWkNxt4Y5vlimOe(RuivyBv8jnzopmvqcNabQKePvt43Ec)jnHhvDoqchRGnbQKs4yfsokHxc)9MxV1qsanJ1a5yzceOss4n00BEYFV51BnKeqZgXReZEi2hoeNPptGavscVHMExc)9MxV1qsan)WH4mzrUk3NjqGkjH3qtVlzBV51BnKeqZHmQSrlNjqGkjH3qtVXEBV51BS5V3qtVx37FNKsRgmiK(5hMJnljG91Jz4Tzy8MNEVwchRGzbHbLWFLcPcBvyg9WNuK0K5R4ubjCceOssKwnHxzJsSjs4eGyqkNfeYuh17fX4nwbBcujLFLcPcBvyg9WNuKWJQohiHxdP0gvDoGvoVMWLZRwqyqj8xPqQW2Q4tAYCS3ovqcNabQKePvt4v2OeBIeEuAInkLbdey9TyraiuaQuMabQKeEx07T8gLdbjdgiW6BXIaqOauPm3U3f9UEgOND)gG(zbHm1r92mVX27IEVU3)ojLwnyqi9ZpmhBwsa7RhZW7f9UeV3SXBSc2eOskZ9KDNnhB0Yw2PHohW718UO3R7D9oP4mbYFzd0t(2dXkOqHZmYigW79Iy8MNEVzJ3R7DuAInkLbdey9TyraiuaQuMfGLEBggVlX7IEJYHGK)YgON8ThIvqHcNzKrmG3BZ8MNEx07T8(vkKkmjYHu6DrVR3jfNjq(HdXzYkcqLYv4GbHElclQ6CGq6Tzy8E78k2718ETeEu15ajCWabwrLHGsAYCSXovqcNabQKePvt4v2OeBIeE9mqp7(na9ZcczQJ69Iy8gBV3SXBDmiREwXqEVigVX27IExpd0ZUFdqFVndJ38mHhvDoqcVgsPnQ6CaRCEnHlNxTGWGs4idyE4KMmh7ssfKWjqGkjrA1eELnkXMiH)7KuA1GbH0p)WCSzjbSVEmdVX4DH9UO31Za9S73a03BZW4DHt4rvNdKWRHuAJQohWkNxt4Y5vlimOeoYaMhoPjZXMNPcs4eiqLKiTAcVYgLytKWjaXGuoliKPoQ3lIXBSc2eOsk)kfsf2QWm6HpPiHhvDoqcVgsPnQ6CaRCEnHlNxTGWGs4OCJuK0K5yx4ubjCceOssKwnHxzJsSjs4eGyqkNfeYuh1BZW4n283BE9Maeds5mJGqGeEu15aj8Gvdaz1JXiGM0K5yZ)ubj8OQZbs4bRgaYUZjFkHtGavsI0Qjnzo2RuQGeEu15ajC5abwFBHaNaIbb0eobcujjsRM0K5yVYtfKWJQohiHJgqShIvztD5NWjqGkjrA1KM0e(oJQNbAOPcsMJDQGeEu15aj8xPqQWjCceOssKwnPjZljvqcNabQKePvt4rvNdKWnc2ssyroMvqHcNW3zu9mqd1(u9aIpHJn)tAYCEMkiHtGavsI0QjCqyqj8O0pCWI3ICa1Ei29ZeXs4rvNdKWJs)WblElYbu7Hy3ptelPjZlCQGeEu15aj89tNdKWjqGkjrA1KM0eoYaMhovqYCStfKWjqGkjrA1eoYXSaIh1K5yNWJQohiHVFN0YO)4yvkPjZljvqcNabQKePvt4v2OeBIeokhcsgmqG13IfbGqbOszUDVl696E)7KuA1GbH0p)WCSzjbSVEmdVx07s8EZgVXkytGkPm3t2D2CSrlBzNg6CaV3SX7T8wdjb08tvgPwLQWGzfXrzceOss49MnEVL317KIZei)uLrQvPkmywrCuMB371s4rvNdKWjSMVsSqPKMmNNPcs4eiqLKiTAcVYgLytKWx37T8wdjb0SiylTpCiotzceOss49MnEVL3OCii5hoeNjRiavkZT79AEx0BDmiREwXqEZpEZiJyaV3M59k5DrVzKrmG37f9wN6sRogK3qtVljHhvDoqchmqGvuziOKMmVWPcs4eiqLKiTAcpQ6CGeoyGaROYqqj8kBuInrcFlVXkytGkPm3t2D2CSrlBzNg6CaVl69VtsPvdges)8dZXMLeW(6Xm82mmExI3f9EDVJstSrPmyGaRVflcaHcqLYeiqLKW7nB8ElVJstSrPmJ2Ltn0baX(WH4m9zceOss49MnE)7KuA1GbH0p)WCSzjbSVEmdV5hVJQoyrwXPzWabwrLHG82mmExI3R5DrV3YBuoeK8dhIZKveGkL529UO36yqw9SIH82mmEVU383BE9EDVlXBOP31Za9S73a03718EnVl6nJqy0dhOskHxlxLKvdges)K5yN0K58pvqcNabQKePvt4v2OeBIeoJmIb8EVO317KIZei)Lnqp5BpeRGcfoZiJyaV386n2B7DrVR3jfNjq(lBGEY3EiwbfkCMrgXaEVxeJ3837IERJbz1ZkgYB(XBgzed492mVR3jfNjq(lBGEY3EiwbfkCMrgXaEV51B(NWJQohiHdgiWkQmeustMVsPcs4rvNdKWFQYi1QufgmRiokHtGavsI0Qjnz(kpvqcpQ6CGeoH18vIfkLWjqGkjrA1KM0eEv8PcsMJDQGeobcujjsRMWRSrj2ej8T8gLdbj)WH4mzfbOszUDVl6nkhcs(H5yZscy1JbcXL529UO3OCii5hMJnljGvpgiexMrgXaEVxeJ38mZ)eEu15aj8hoeNjRiavkHZ9K9qqSqQIK5yN0K5LKkiHtGavsI0Qj8kBuInrchLdbj)WCSzjbS6XaH4YC7Ex0BuoeK8dZXMLeWQhdeIlZiJyaV3lIXBEM5FcpQ6CGe(x2a9KV9qScku4eo3t2dbXcPksMJDstMZZubjCceOssKwnHxzJsSjs4B59RuivysKdP07IElondgiWkQmeuwN6YbaX7nB8M(NavkJYOqHThIvHjRO8aGKnIcHJ5DrV1XG82mmExscpQ6CGeEnKsBu15aw58AcxoVAbHbLWP)jqL(KMmVWPcs4eiqLKiTAcpQ6CGe((DslJ(JJvPeELnkXMiHVL3AijGMF4qCMSixL7ZeiqLKiHJCmlG4rnzo2jnzo)tfKWjqGkjrA1eELnkXMiHtaIbPS3MHX7vABVl6T40myGaROYqqzDQlhaeVl6D9oP4mbYFzd0t(2dXkOqHZC7Ex076DsXzcKF4qCMSIauPCfoyqO3BZW4n2j8OQZbs4pmhBwsaREmqiUKMmFLsfKWjqGkjrA1eELnkXMiHlondgiWkQmeuwN6YbaX7IEVL317KIZei)WH4mzrLHG(m3U3f9EDV3YBnKeqZpmhBwsaREmqiUmbcujj8EZgV1qsan)WH4mzrUk3NjqGkjH3B24D9oP4mbYpmhBwsaREmqiUmJmIb8EBM3L49AEx0719ElVP)jqLYOY7e2dXQWKLaKr5SruiCmV3SX76DsXzcKrL3jShIvHjlbiJYzgzed492mVlX718UO3R7DuAInkLbdey9TyraiuaQuMfGLEVO3L49MnEJYHGKbdey9TyraiuaQuMB371s4rvNdKW)YgON8ThIvqHcN0K5R8ubjCceOssKwnHhvDoqc3iyljHf5ywbfkCcVYgLytKWzXiSeweqZHq8zUDVl696ERbdcPzDmiREwXqEVO31Za9S73a0pliKPoQ3B249wE)kfsfMe5qk9UO31Za9S73a0pliKPoQ3MHX76U1i4r7VtaH3RLWRLRsYQbdcPFYCStAYCEyQGeobcujjsRMWRSrj2ejCwmclHfb0CieFEaEBM38CBV5hVzXiSeweqZHq8zbhl05aEx07T8(vkKkmjYHu6DrVRNb6z3VbOFwqitDuVndJ31DRrWJ2FNaIeEu15ajCJGTKewKJzfuOWjnz(kovqcNabQKePvt4v2OeBIe(wE)kfsfMe5qk9UO3ItZGbcSIkdbL1PUCaq8UO31Za9S73a0pliKPoQ3MHX7ss4rvNdKWF4qCMSOYqqFstMJ92Pcs4eiqLKiTAcVYgLytKW1qsan)WH4mzrUk3NjqGkjH3f9wCAgmqGvuziOSo1LdaI3f9gLdbj)Lnqp5BpeRGcfoZTNWJQohiH)WCSzjbS6XaH4sAYCSXovqcNabQKePvt4v2OeBIe(wEJYHGKF4qCMSIauPm3U3f9whdYQNvmK3lIXB(7nVERHKaA(5qvIHWbHYeiqLKW7IEVL3SyewclcO5qi(m3EcpQ6CGe(dhIZKveGkL0K5yxsQGeobcujjsRMWRSrj2ejCuoeKmQ8oHK71mJIQ69MnEJYHGK)YgON8ThIvqHcN529UO3R7nkhcs(HdXzYIkdb9zUDV3SX76DsXzcKF4qCMSOYqqFMrgXaEVxeJ3yVT3RLWJQohiHVF6CGKMmhBEMkiHtGavsI0Qj8kBuInrchLdbj)Lnqp5BpeRGcfoZTNWJQohiHJkVtyr4yLtAYCSlCQGeobcujjsRMWRSrj2ejCuoeK8x2a9KV9qScku4m3EcpQ6CGeokXEITCaqsAYCS5FQGeobcujjsRMWRSrj2ejCuoeK8x2a9KV9qScku4m3EcpQ6CGeoYWiu5DIKMmh7vkvqcNabQKePvt4v2OeBIeokhcs(lBGEY3EiwbfkCMBpHhvDoqcpav6vwiT1qktAYCSx5Pcs4eiqLKiTAcpQ6CGeETCvEk7at1IkJxt4v2OeBIe(wE)kfsfMe5qk9UO3ItZGbcSIkdbL1PUCaq8UO3B5nkhcs(lBGEY3EiwbfkCMB37IEtaIbPCwqitDuVndJ38C7eoHGqv1ccdkHxlxLNYoWuTOY41KMmhBEyQGeobcujjsRMWJQohiHhL(Hdw8wKdO2dXUFMiwcVYgLytKW3YBuoeK8dhIZKveGkL529UO317KIZei)Lnqp5BpeRGcfoZiJyaV3l6n2BNWbHbLWJs)WblElYbu7Hy3ptelPjZXEfNkiHtGavsI0Qj8OQZbs4XdJvaO3YIsFmB9yHmHxzJsSjs4ccLdbjZIsFmB9yH0kiuoeKS4mb8EZgVfekhcsUEabxvhSi7awAfekhcsMB37IERbdcPzDmiRE29QA552EVO3837nB8ElVfekhcsUEabxvhSi7awAfekhcsMB37IEVU3ccLdbjZIsFmB9yH0kiuoeK8RrDP3MHX7s4V38J3yVT3qtVfekhcsgvENWEiwfMSeGmkN529EZgV1XGS6zfd59IEx4T9EnVl6nkhcs(lBGEY3EiwbfkCMrgXaEVnZBEychegucpEySca9wwu6JzRhlKjnzEjBNkiHtGavsI0QjCqyqjCJYI4TAiN3iaj8OQZbs4gLfXB1qoVrasAY8sWovqcNabQKePvt4v2OeBIeokhcs(lBGEY3EiwbfkCMB37nB8whdYQNvmK3l6DjBNWJQohiHZ9KDuY4tAst4VsHuHTvXNkizo2Pcs4eiqLKiTAc)2t4pPj8OQZbs4yfSjqLuchRqYrj86DsXzcKF4qCMSIauPCfoyqO3IWIQohiKEBggVXoVY5FchRGzbHbLWFyHvHz0dFsrstMxsQGeobcujjsRMWRSrj2ej8T8gRGnbQKYpSWQWm6HpPW7IExpd0ZUFdq)SGqM6OEBM3y7DrVfekhcsgzacRjkwcO)ZmYigW79IEJT3f9UENuCMa5VSb6jF7HyfuOWzgzed492mmEZZeEu15ajCScW8WjnzoptfKWjqGkjrA1eEu15aj897Kwg9hhRsjCIhvwydJJdOj8cVDch5ywaXJAYCStAY8cNkiHtGavsI0Qj8kBuInrcNaedszVndJ3fEBVl6nbigKYzbHm1r92mmEJ92Ex07T8gRGnbQKYpSWQWm6HpPW7IExpd0ZUFdq)SGqM6OEBM3y7DrVfekhcsgzacRjkwcO)ZmYigW79IEJDcpQ6CGe(dhIZKbjfjnzo)tfKWjqGkjrA1e(TNWFst4rvNdKWXkytGkPeowHKJs41Za9S73a0pliKPoQ3MHX7c7n)496ERHKaAwq0oXSVYcnGqgzceOss4DrVx37O0eBukRWKfzyVAfbOszceOss4DrV3YBnKeqZIGT0(WH4mLjqGkjH3f9ElV1qsan)COkXq4GqzceOss4DrV)DskTAWGq6NFyo2SKa2xpMH3l6np9EnVxlHJvWSGWGs4pSWwpd0ZUFdq)KMmFLsfKWjqGkjrA1e(TNWFst4rvNdKWXkytGkPeowHKJs41Za9S73a0pliKPoQ3lIXBS9MxVlXBOP3rPj2OuwHjlYWE1kcqLYeiqLKiHxzJsSjs4yfSjqLuM7j7oBo2OLTStdDoG3f9EDV1qsandgiW6RHCjXYeiqLKW7nB8wdjb0SiylTpCiotzceOss49AjCScMfeguc)Hf26zGE29Ba6N0K5R8ubjCceOssKwnHxzJsSjs4yfSjqLu(Hf26zGE29Ba67DrVx37T8wdjb0SiylTpCiotzceOss49MnElondgiWkQmeuMrgXaEVndJ383BE9wdjb08ZHQedHdcLjqGkjH3R5DrVx3BSc2eOsk)WcRcZOh(KcV3SXBuoeK8x2a9KV9qScku4mJmIb8EBggVXoxI3B249VtsPvdges)8dZXMLeW(6Xm82mmExyVl6D9oP4mbYFzd0t(2dXkOqHZmYigW7TzEJ92EVM3f9EDVJstSrPmyGaRVflcaHcqLYSaS07f9UeV3SXBuoeKmyGaRVflcaHcqLYC7EVwcpQ6CGe(dhIZKveGkL0K58WubjCceOssKwnHxzJsSjs4yfSjqLu(Hf26zGE29Ba67DrV1XGS6zfd59IExVtkotG8x2a9KV9qScku4mJmIb8Ex07T8MfJWsyranhcXN52t4rvNdKWF4qCMSIauPKM0eok3ifPcsMJDQGeobcujjsRMWRSrj2ej8FNKsRgmiK(EBggVlXBE9EDV1qsandrENbQmeuMabQKeEx07O0eBukVtmKJfkLzbyP3MHX7s8ETeEu15aj8hMJnljG91JzK0K5LKkiHhvDoqchI8oduziOeobcujjsRM0K58mvqcpQ6CGeoAux(AGMWjqGkjrA1KM0KMWXIy)CGK5LSDjBVnp552jCtbdmaiFchA3y)ykj8Mh6Du15aElNx)Sdvc)3PAY8swjSt47SdzKuch6EJZHQssl7DH8GWrouq3Byv3)v2clazuyo0C9mw4hdozOZbQSarx4hJ6couq3BOTOS3yJnFExY2LSTdLdf09MFHdae6xzouq3B(X7vGqqcVlep1LERN3ccj4KQ3rvNd4TCEn7qbDV5hVlKKXHfj8wdgesTdI31digDoG3hWBOTGTKeEJCmVlffkC2Hc6EZpEVcecs4DH6jVH2vY4Zououq37cDEKQCkj8gLqog5D9mqd1BucYa(S3RGAL213BWb4h4GzGWj9oQ6CG37dilNDOGU3rvNd85Dgvpd0qXGiJFPdf09oQ6CGpVZO6zGgkVywi4Gyqan05aouq37OQZb(8oJQNbAO8IzbK7eouq3BCqS)WN6nlgH3OCiiKW7xd99gLqog5D9mqd1BucYaEVdGW7DgXp7NQdaI3Z7T4au2Hc6EhvDoWN3zu9mqdLxml8Gy)Hp1(AOVdvu15aFENr1ZanuEXSWRuivyhQOQZb(8oJQNbAO8IzbJGTKewKJzfuOW8TZO6zGgQ9P6bepgS5Vdvu15aFENr1ZanuEXSa3t2rjd(aHbHjk9dhS4TihqThID)mrmhQOQZb(8oJQNbAO8IzH9tNd4q5qbDVl05rQYPKWBclIv2BDmiVvyY7OQhZ759oWkgzGkPSdf09UqsVsHuH9Eq8E)(FqLK3RdoVXItciwGkjVjazm079a8UEgOHUMdvu15apMLtDjFdcMTELcPctIm7GWrourvNd88IzHxPqQWouq3B(fMQl9MFl17DOEJmSxDOIQoh45fZc1qkTrvNdyLZR8bcdctv8ouq37cjhWBeoPSS3VPrRW07TEERWK34kfsfMeExipn05aEVoAzVf3aG49F859OEJCSk9EVFNCaq8Eq8gCk8aG498EhyfJmqL0AzhQOQZbEEXSaJdyJQohWkNx5degeMxPqQWKGVbbZRuivysKdP0Hc6EVc23LL928bcSIkdb5DOExcVEZVqdVfCSbaXBfM8gzyV6n2B79t1diE(8oquI5TchQ3fMxV5xOH3dI3J6nXJ7dJEVnnk8a8wHjVbepQExOLFlL3hZ759gCQ3C7ourvNd88IzbWabwrLHG4BqWOJbz1ZkgYSvQiJmIb8lcPkYgbpwSEgOND)gG(MHPW8Z66yqlI92RbnlXHc6ExObil7DfoaqiVzNg6CaVheVnrEdhyrEVZMJnAzl70qNd49tQ3bq4TbNuNDj5TgmiK(EZTNDOIQoh45fZcyfSjqLeFGWGWW9KDNnhB0Yw2PHohGpScjhHzNnhB0Yw2PHohO4VtsPvdges)8dZXMLeW(6Xmmdtjouq3BObBo2OL9UqEAOZbGwR3fIifA17nKblY7W7kl29oqpo1BcqmiL9g5yERWK3VsHuH9MFl1796OCJuqmVFDKsVz0Vtv17rxl7n0A425Z7r9UgaVrjVv4q9(hJDjLDOIQoh45fZc1qkTrvNdyLZR8bcdcZRuivyBv88niyWkytGkPm3t2D2CSrlBzNg6CahkO7DH6jH365TGqga5Tjyc4TEEZ9K3VsHuH9MFl179X8gLBKcI9ourvNd88IzbSc2eOsIpqyqyELcPcBvyg9WNuWhwHKJWuc)5vdjb0mwdKJLjqGkjb0KN8NxnKeqZgXReZEi2hoeNPptGavscOzj8NxnKeqZpCiotwKRY9zceOssanlzBE1qsanhYOYgTCMabQKeqtS3MxS5p0C9FNKsRgmiK(5hMJnljG91JzyggEUMdf09MFpWpcI5n3paiEhEJRuivyV53s5Tjyc4nJIk8aG4TctEtaIbPS3kmJE4tkCOIQoh45fZc1qkTrvNdyLZR8bcdcZRuivyBv88niyiaXGuoliKPo6IyWkytGkP8RuivyRcZOh(KchkO7T5deyfA17n0cbGqbOsRmVnFGaROYqqEJsihJ8gVSb6jFVd1B5zYB(fA4TEExpd0bqEtbtw2BgHWOh2BtJc7nes1baXBfM8gLdbXBU9S3Ra5FElptEZVqdVfCSbaXB8YgON89gLuteb8UubOsV3Mgf27s41BZHwYourvNd88IzbWabwrLHG4BqWeLMyJszWabwFlweacfGkLjqGkjrXTq5qqYGbcS(wSiaekavkZTxSEgOND)gG(zbHm1rnd7IR)7KuA1GbH0p)WCSzjbSVEmJflzZgSc2eOskZ9KDNnhB0Yw2PHohyTIRxVtkotG8x2a9KV9qScku4mJmIb8lIHNB2SEuAInkLbdey9TyraiuaQuMfGLMHPKIOCii5VSb6jF7HyfuOWzgzed4nJNf36vkKkmjYHuwSENuCMa5hoeNjRiavkxHdge6TiSOQZbcPzy2oVIxBnhkO7npyaZd7DOExyE920OWhN6DPW5ZB(ZR3Mgf27sH796hN(JG8(vkKk8AourvNd88IzHAiL2OQZbSY5v(aHbHbzaZdZ3GGPEgOND)gG(zbHm1rxed2B2OJbz1ZkgArmyxSEgOND)gG(MHHNouq37v4OWExkCVd5FEJmG5H9ouVlmVEhqIb8Q3epgvvw27c7TgmiK(EV(XP)iiVFLcPcVMdvu15apVywOgsPnQ6CaRCELpqyqyqgW8W8niy(DskTAWGq6NFyo2SKa2xpMbMcxSEgOND)gG(MHPWouq37c1tEhEJYnsbX82emb8MrrfEaq8wHjVjaXGu2BfMrp8jfourvNd88IzHAiL2OQZbSY5v(aHbHbLBKc(gemeGyqkNfeYuhDrmyfSjqLu(vkKkSvHz0dFsHdf09Uq0zIE17D2CSrl79a8oKsVpeVvyY7va0OqK3Oun4EY7r9UgCp9EhExOLFlLdvu15apVywiy1aqw9ymcO8niyiaXGuoliKPoQzyWM)8saIbPCMrqiGdvu15apVywiy1aq2Do5tourvNd88Izb5abwFBHaNaIbbuhQOQZbEEXSaAaXEiwLn1LVdLdf09EvUrki27qfvDoWNr5gPaZdZXMLeW(6Xm4BqW87KuA1GbH03mmLW76AijGMHiVZavgcktGavsIIrPj2OuENyihlukZcWsZWuYAourvNd8zuUrk4fZcqK3zGkdb5qfvDoWNr5gPGxmlGg1LVgOououq3B(9oP4mbEhkO7DH6jVlvaQK3hcc)aPk8gLqog5TctEJmSx9ghMJnljG346Xm8gHDgExWXaH48UEg079aYourvNd85Q4X8WH4mzfbOs8X9K9qqSqQcmyZ3GGzluoeK8dhIZKveGkL52lIYHGKFyo2SKaw9yGqCzU9IOCii5hMJnljGvpgiexMrgXa(fXWZm)DOGU3RxOas6FVdjJcrzV529gLQb3tEBI8wVBP34WH4m5np4QC)AEZ9K34Lnqp579HGWpqQcVrjKJrERWK3id7vVXH5yZsc4nUEmdVryNH3fCmqioVRNb9EpGSdvu15aFUkEEXSWx2a9KV9qSckuy(4EYEiiwivbgS5BqWGYHGKFyo2SKaw9yGqCzU9IOCii5hMJnljGvpgiexMrgXa(fXWZm)DOIQoh4ZvXZlMfQHuAJQohWkNx5degeg6FcuPNVbbZwVsHuHjroKYIItZGbcSIkdbL1PUCaq2SH(NavkJYOqHThIvHjRO8aGKnIcHJvuhdYmmL4qbDVHg3j9g5yExWXaH48ENr8d(vkVnnkS34WLYBgfIYEBcMaEdo1BghamaiEJZdYourvNd85Q45fZc73jTm6powL4d5ywaXJkgS5BqWSLgscO5hoeNjlYv5(mbcujjCOGU3fQN8UGJbcX59oJ8g)kL3MGjG3MiVHdSiVvyYBcqmiL92emPWeZBe2z49(DYbaXBtJcFCQ348aVpM3fcCV6necqSqklNDOIQoh4ZvXZlMfEyo2SKaw9yGqC8niyiaXGu2mmR02ffNMbdeyfvgckRtD5aGuSENuCMa5VSb6jF7HyfuOWzU9I17KIZei)WH4mzfbOs5kCWGqVzyW2Hc6ExOEYB8YgON89(aExVtkotaVxpquI5nYWE1BZhiWkQme0AEZbK0)EBI8oyK3qUbaXB98E)29UGJbcX5DaeEloVbN6nCGf5noCiotEZdUk3NDOIQoh4ZvXZlMf(YgON8ThIvqHcZ3GGrCAgmqGvuziOSo1LdasXTQ3jfNjq(HdXzYIkdb9zU9IRVLgscO5hMJnljGvpgiexMabQKeB2OHKaA(HdXzYICvUptGavsInBQ3jfNjq(H5yZscy1JbcXLzKrmG3SswR46Br)tGkLrL3jShIvHjlbiJYzJOq4yB2uVtkotGmQ8oH9qSkmzjazuoZiJyaVzLSwX1JstSrPmyGaRVflcaHcqLYSaSCXs2SbLdbjdgiW6BXIaqOauPm3(Aouq3BODeVdH49oyK3C7859dMDYBfM8(aK3Mgf2B5zIE17ckOuzVlup5Tjyc4TO8aG4ns8kX8wHdG38l0WBbHm1r9(yEdo17xPqQWKWBtJcFCQ3bOS38l0i7qfvDoWNRINxmlyeSLKWICmRGcfMVA5QKSAWGq6JbB(gemSyewclcO5qi(m3EX11GbH0SogKvpRyOfRNb6z3VbOFwqitD0nB26vkKkmjYHuwSEgOND)gG(zbHm1rndtD3Ae8O93jGynhkO7n0oI3GZ7qiEVnnsP3IH820OWdWBfM8gq8O6np3(5ZBUN8gAdPuEFaVrV)920OWhN6Dak7n)cn8oacVbN3VsHuHZourvNd85Q45fZcgbBjjSihZkOqH5BqWWIryjSiGMdH4ZdWmEUn)WIryjSiGMdH4ZcowOZbkU1RuivysKdPSy9mqp7(na9ZcczQJAgM6U1i4r7VtaHdvu15aFUkEEXSWdhIZKfvgc65BqWS1RuivysKdPSO40myGaROYqqzDQlhaKI1Za9S73a0pliKPoQzykXHc6EVchf2BCEaFEpiEdo17qYOqu2BXbi(8M7jVl4yGqCEBAuyVXVs5n3E2HkQ6CGpxfpVyw4H5yZscy1JbcXX3GGrdjb08dhIZKf5QCFMabQKeffNMbdeyfvgckRtD5aGueLdbj)Lnqp5BpeRGcfoZT7qfvDoWNRINxml8WH4mzfbOs8niy2cLdbj)WH4mzfbOszU9I6yqw9SIHwed)5vdjb08ZHQedHdcLjqGkjrXTyXiSeweqZHq8zUDhQOQZb(Cv88IzH9tNdW3GGbLdbjJkVti5EnZOOQB2GYHGK)YgON8ThIvqHcN52lUokhcs(HdXzYIkdb9zU9nBQ3jfNjq(HdXzYIkdb9zgzed4xed2BVMdvu15aFUkEEXSaQ8oHfHJvMVbbdkhcs(lBGEY3EiwbfkCMB3HkQ6CGpxfpVywaLypXwoai8niyq5qqYFzd0t(2dXkOqHZC7ourvNd85Q45fZcidJqL3j4BqWGYHGK)YgON8ThIvqHcN52DOIQoh4ZvXZlMfcqLELfsBnKs(gemOCii5VSb6jF7HyfuOWzUDhQOQZb(Cv88IzbUNSJsg8riiuvTGWGWulxLNYoWuTOY4v(gemB9kfsfMe5qklkondgiWkQmeuwN6YbaP4wOCii5VSb6jF7HyfuOWzU9IeGyqkNfeYuh1mm8CBhQOQZb(Cv88IzbUNSJsg8bcdctu6hoyXBroGApe7(zIy8niy2cLdbj)WH4mzfbOszU9I17KIZei)Lnqp5BpeRGcfoZiJya)IyVTdf09gAHyL9MDCqGLL9MXjjVpeVvyod0bziH3gHc)EJsYZ0kZ7c1tEJCmVH2bl3pH3v2O859PWeZ08K3Mgf2B8RuEhQ3LWFE9(1OU89(yEJn)51BtJc7Di)Z7vL3j8MBp7qfvDoWNRINxmlW9KDuYGpqyqyIhgRaqVLfL(y26XcjFdcgbHYHGKzrPpMTESqAfekhcswCMaB2iiuoeKC9acUQoyr2bS0kiuoeKm3ErnyqinRJbz1ZUxvlp3Er(VzZwccLdbjxpGGRQdwKDalTccLdbjZTxCDbHYHGKzrPpMTESqAfekhcs(1OU0mmLWF(b7THMccLdbjJkVtypeRctwcqgLZC7B2OJbz1ZkgAXcV9Afr5qqYFzd0t(2dXkOqHZmYigWBgp0HkQ6CGpxfpVywG7j7OKbFGWGWyuweVvd58gbWHc6Exkcj4KQ3iHuIg1LEJCmV5(avsEpkz8RmVlup5TPrH9gVSb6jFVpeVlffkC2HkQ6CGpxfpVywG7j7OKXZ3GGbLdbj)Lnqp5BpeRGcfoZTVzJogKvpRyOflzBhkhkO7DH()eOsVdvu15aFM(Nav6XupqLaklusyrKHbX3GGHaeds5SogKvpRrWJMHDXTq5qqYFzd0t(2dXkOqHZC7fxFlXP56bQeqzHsclImmilkhdK1PUCaqkUvu15a56bQeqzHsclImmO8aSiYbcSUzdcNuAzufoyqiRog0IqQISrWJR5qfvDoWNP)jqLEEXSaQ8oH9qSkmzjazuMVbbZw17KIZei)WH4mzrLHG(m3EX6DsXzcK)YgON8ThIvqHcN523SrhdYQNvm0IyWEBhQOQZb(m9pbQ0ZlMfGWfmXea7HyJstStHDOIQoh4Z0)eOspVywa5QCpjSrPj2OKfLcd(gemR)7KuA1GbH0p)WCSzjbSVEmdZWuYMnSyewclcO5qi(8amBL2ETIBvVtkotG8x2a9KV9qScku4m3EXTq5qqYFzd0t(2dXkOqHZC7fjaXGuoliKPoQzy452ourvNd8z6FcuPNxmlSZXgKYdaIfvgVY3GG53jP0QbdcPF(H5yZscyF9ygMHPKnByXiSeweqZHq85by2kTTdvu15aFM(Nav65fZckmz5aOhhqyrowL4BqWGYHGKzuDPK(3ICSkL523SbLdbjZO6sj9Vf5yvYwpoGsS8RrD5IyVTdvu15aFM(Nav65fZcSzFxs2by)9OsourvNd8z6FcuPNxmly6ysbw0aSm6pqaQeFdcM6DsXzcK)YgON8ThIvqHcNzKrmGFr(VzJogKvpRyOfXMh6qfvDoWNP)jqLEEXSGbzCSY2dXk5QJWkyuy88niyiaXGuEXcVDruoeK8x2a9KV9qScku4m3Udf09gA9tk8UqsX(aG4npqgg07nYX8M4rQYPK3SaaH8(yEVCKsVr5qqE(8Eq8E)(FqLu27vG0uu(9wzL9wpVHqQ3km5T8mrV6D9oP4mb8gnEs49b8oWkgzGkjVjazm0NDOIQoh4Z0)eOspVywGrX(aGyrKHb98vlxLKvdgesFmyZ3GGrdgesZ6yqw9SIHwe7m)3Sz911GbH0mmfsfoVxvZ4HBVzJgmiKMHPqQW59QUiMs2ETIRhvDWISeGmg6XG9MnAWGqAwhdYQNvmKzLSIxBTnBwxdgesZ6yqw9S7v1wY2MXZTlUEu1blYsaYyOhd2B2ObdcPzDmiREwXqMv4cV2Aououq3BEWaMhMyVdvu15aFgzaZdJz)oPLr)XXQeFihZciEuXGTdf09UqhR5ReluYB449gEGatV69oBo2OL920OWEB(abwHw9EdTqaiuaQK3C7zV9UqNhR0UohW759EfCf6ElcJac5Tjyc4novlGQEpV3mkeLZourvNd8zKbmpmVywGWA(kXcL4BqWGYHGKbdey9TyraiuaQuMBV46)ojLwnyqi9ZpmhBwsa7RhZyXs2SbRGnbQKYCpz3zZXgTSLDAOZb2SzlnKeqZpvzKAvQcdMvehLjqGkjXMnBvVtkotG8tvgPwLQWGzfXrzU91COGU3fIjA3BUDVnFGaROYqqEpiEpQ3Z7DGECQ365nJd49XPzVl15n4uV5EYBZx1BbhBaq8UubOs859G4TgscOKW7bON3Lkyl9ghoeNPSdvu15aFgzaZdZlMfadeyfvgcIVbbZ6BPHKaAweSL2hoeNPmbcujj2SzluoeK8dhIZKveGkL52xROogKvpRyi(HrgXaEZwPImYigWVOo1LwDmiOzjouq3BOnoPoIt1baX7Jt)rqExQaujVpG3AWGq67TchQ3MgP0B5Gf5nYX8wHjVfCSqNd49H4T5deyfvgcIpVzecJEyVfCSbaX79aiiJPM9gAJtQJ4uVJ3B5bG4D8ExcVERbdcPV3IZBWPEdhyrEB(abwrLHG8MB3BtJc7DHK2Ltn0baXBC4qCMEVxNdiP)9U8X5nCGf5T5deyfA17n0cbGqbOsER3Tw2HkQ6CGpJmG5H5fZcGbcSIkdbXxTCvswnyqi9XGnFdcMTWkytGkPm3t2D2CSrlBzNg6CGI)ojLwnyqi9ZpmhBwsa7RhZWmmLuC9O0eBukdgiW6BXIaqOauPmbcujj2SzRO0eBukZOD5udDaqSpCiotFMabQKeB287KuA1GbH0p)WCSzjbSVEmd(jQ6GfzfNMbdeyfvgcYmmLSwXTq5qqYpCiotwraQuMBVOogKvpRyiZWSo)5D9sGM1Za9S73a0FT1kYieg9WbQKCOGU3fscHrpS3MpqGvuziiVPGjl79G49OEBAKsVjECFyK3co2aG4nEzd0t(zVl15TchQ3mcHrpS3dI34xP8gcPV3mkeL9EaERWK3aIhvV5)NDOIQoh4ZidyEyEXSayGaROYqq8niyyKrmGFX6DsXzcK)YgON8ThIvqHcNzKrmGNxS3Uy9oP4mbYFzd0t(2dXkOqHZmYigWVig(xuhdYQNvme)WiJyaVz17KIZei)Lnqp5BpeRGcfoZiJyapV83HkQ6CGpJmG5H5fZcpvzKAvQcdMveh5qfvDoWNrgW8W8IzbcR5ReluYHYHc6EJRuivyV537KIZe4DOGU3qRtYDI5n0sWMavsourvNd85xPqQW2Q4XGvWMavs8bcdcZdlSkmJE4tk4dRqYryQ3jfNjq(HdXzYkcqLYv4GbHElclQ6CGqAggSZRC(7qbDVHwcW8WEZbK0)EBI8oyK3b6XPERN31y37d4DPcqL8Uchmi0N9Uqdqw2BtWeWBEWaeEVcPyjG(3759oqpo1B98MXb8(40Sdvu15aF(vkKkSTkEEXSawbyEy(gemBHvWMavs5hwyvyg9WNuuSEgOND)gG(zbHm1rnd7IccLdbjJmaH1eflb0)zgzed4xe7I17KIZei)Lnqp5BpeRGcfoZiJyaVzy4Pdf09gACN0BKJ5noCiotgKu4nVEJdhIZ0RSzj5nhqs)7TjY7GrEhOhN6TEExJDVpG3LkavY7kCWGqF27cnazzVnbtaV5bdq49kKILa6FVN37a94uV1ZBghW7JtZourvNd85xPqQW2Q45fZc73jTm6powL4d5ywaXJkgS5J4rLf2W44akMcVTdvu15aF(vkKkSTkEEXSWdhIZKbjf8niyiaXGu2mmfE7IeGyqkNfeYuh1mmyVDXTWkytGkP8dlSkmJE4tkkwpd0ZUFdq)SGqM6OMHDrbHYHGKrgGWAIILa6)mJmIb8lITdf09MFHgEZOve3WidcORmVlvaQK3H6T8m5n)cn8gTS3ccj4KA271X5qvwu15aEpV3H31BVS3iSZWBfM8(vkKWKWBKbmpmX8UgsP3ihZ7c4bLYB4aiKdasEnhQOQZb(8RuivyBv88IzbSc2eOsIpqyqyEyHTEgOND)gG(8Hvi5im1Za9S73a0pliKPoQzykm)SUgscOzbr7eZ(kl0aczKjqGkjrX1JstSrPSctwKH9QveGkLjqGkjrXT0qsanlc2s7dhIZuMabQKef3sdjb08ZHQedHdcLjqGkjrXFNKsRgmiK(5hMJnljG91JzSipxBnhkO7n)cn8MrRiUHrgeqxzExQaujVpGSS3OeYXiVrgW8We79Eq82e5nCGf5DyS7TgscOV3bq49oBo2OL9MDAOZbYourvNd85xPqQW2Q45fZcyfSjqLeFGWGW8WcB9mqp7(na95dRqYryQNb6z3VbOFwqitD0fXGnVLanJstSrPSctwKH9QveGkLjqGkjbFdcgSc2eOskZ9KDNnhB0Yw2PHohO46AijGMbdey91qUKyzceOssSzJgscOzrWwAF4qCMYeiqLKynhkO79kCuyVlvWw6noCiotEFazzVlvaQK3MGjG3MpqGvuziiVnnsP3VgL9MBp7DH6jVfCSbaXB8YgON89(yEhOhwK3kmJE4tkYEVcJr9g5yEBo0I3OCiiEBAuyVlHxZHwYourvNd85xPqQW2Q45fZcpCiotwraQeFdcgSc2eOsk)WcB9mqp7(na9lU(wAijGMfbBP9HdXzktGavsInBeNMbdeyfvgckZiJyaVzy4pVAijGMFouLyiCqOmbcujjwR46yfSjqLu(HfwfMrp8jfB2GYHGK)YgON8ThIvqHcNzKrmG3mmyNlzZMFNKsRgmiK(5hMJnljG91JzygMcxSENuCMa5VSb6jF7HyfuOWzgzed4nd7TxR46rPj2OugmqG13IfbGqbOszwawUyjB2GYHGKbdey9TyraiuaQuMBFnhkO79QCmG3mYigWaG4DPcqLEVrjKJrERWK3AWGqQ3IHEVheVXVs5TPdaTs9gL8MrHOS3dWBDmOSdvu15aF(vkKkSTkEEXSWdhIZKveGkX3GGbRGnbQKYpSWwpd0ZUFdq)I6yqw9SIHwSENuCMa5VSb6jF7HyfuOWzgzed4lUflgHLWIaAoeIpZT7q5qbDVXvkKkmj8UqEAOZbCOGU3q7iEJRuiv4fWkaZd7DWiV525ZBUN8ghoeNPxzZsYB98gLaeYOEJWodVvyY794)blYB0dW9EhaH38Gbi8EfsXsa9pFEtyraVheVnrEhmY7q92i4rV5xOH3RJWodVvyY7Dgvpd0q9gAdPuRLDOIQoh4ZVsHuHjbMhoeNPxzZsIVbbZ6AijGMrgGWAIILa6)mbcujj2S53jP0QbdcPF(H5yZscyF9yglYZ1kUokhcs(vkKkCMBFZguoeKmwbyE4m3(Aouq3BEWaMh27q9MN86n)cn820OWhN6DPW9EbVlmVEBAuyVlfU3Mgf2BCyo2SKaExWXaH48gLdbXBUDV1Z7aRBeE)Nb5n)cn82u8k59pkxOZb(Sdvu15aF(vkKkmj4fZc1qkTrvNdyLZR8bcdcdYaMhMVbbdkhcs(H5yZscy1JbcXL52lwpd0ZUFdq)SGqM6OlIPehkO79kq(N3FGqERN3idyEyVd17cZR38l0WBtJc7nXJrvLL9UWERbdcPF271XddY749(40FeK3VsHuHZR5qfvDoWNFLcPctcEXSqnKsBu15aw58kFGWGWGmG5H5BqW87KuA1GbH0p)WCSzjbSVEmdmfUy9mqp7(na9ndtHDOGU38GbmpS3H6DH51B(fA4TPrHpo17sHZN38NxVnnkS3LcNpVdGW7vYBtJc7DPW9oquI5n0saMh27J5DbWK38GH9Q3LkavY7ai8gCExQGT0BC4qCM8MxVbN34COkXq4GqourvNd85xPqQWKGxmludP0gvDoGvoVYhimimidyEy(gem1Za9S73a0pliKPo6IyWMFwxdjb0SGODIzFLfAaHmYeiqLKO46OCiizScW8WzU9nBIstSrPSctwKH9QveGkLjqGkjrXT0qsanlc2s7dhIZuMabQKef3sdjb08ZHQedHdcLjqGkjrXFNKsRgmiK(5hMJnljG91JzSipxBnhkO7DH6jVl0kVZavgcY7dlI5noCiotVYMLK3bq4nUEmdVnnkS3LWR3qdIHCSqjVd17s8(yElP)9wdges)Sdvu15aF(vkKkmj4fZcqK3zGkdbX3GGjknXgLY7ed5yHszwawAgMsk(7KuA1GbH0p)WCSzjbSVEmJfXuIdf09EfOExI3AWGq67TPrH9gNQms9UaQcdMveh59sI29MB3BEWaeEVcPyjG(3B0YExlxLdaI34WH4m9kBwszhQOQZb(8RuivysWlMfE4qCMELnlj(QLRsYQbdcPpgS5BqWOHKaA(PkJuRsvyWSI4OmbcujjkQHKaAgzacRjkwcO)ZeiqLKOOGq5qqYidqynrXsa9FMrgXa(fXU4VtsPvdges)8dZXMLeW(6XmWusrDmiREwXq8dJmIb8MTsouq37v4OWhN6DPiANyEJRSqdiKH3bq4np9UqgGLV3hI3Rkdb59a8wHjVXHdXz69EuVN3BthtH9M7haeVXHdXz6v2SK8(aEZtV1GbH0p7qfvDoWNFLcPctcEXSWdhIZ0RSzjX3GGzlnKeqZcI2jM9vwObeYitGavsIIrPj2OugvgcYoaRct2hoeNPpZcWsm8S4VtsPvdges)8dZXMLeW(6XmWWthkO7np4yEVZMJnAzVzNg6Ca(8M7jVXHdXz6v2SK8(WIyEJRhZWBSxZBtJc79keAZ7asmGx9MB3B98UWERbdcPpFExYAEpiEZdwHEpV3moayaq8(qq8E9d4Dak7DyCCa17dXBnyqi9xJpVpM38CnV1ZBJGhhJP0K34xP8M4rLa)CaVnnkS3q7acRrd0roAzVpG380Bnyqi99E9c7TPrH9E1rXxl7qfvDoWNFLcPctcEXSWdhIZ0RSzjX3GGbRGnbQKYCpz3zZXgTSLDAOZbkUUgscOzKbiSMOyjG(ptGavsIIccLdbjJmaH1eflb0)zgzed4xe7nB0qsanBII9dyeVsSmbcujjk(7KuA1GbH0p)WCSzjbSVEmJfXu4nBIstSrP8aiSgnqh5OLZeiqLKOikhcs(lBGEY3EiwbfkCMBV4VtsPvdges)8dZXMLeW(6Xmwedp5nknXgLYOYqq2byvyY(WH4m9zceOssSMdvu15aF(vkKkmj4fZcpmhBwsa7RhZGVbbZVtsPvdgesFZWWthQOQZb(8RuivysWlMfE4qCMELnlPKM0uca]] )


end
