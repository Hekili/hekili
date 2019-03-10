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
            cooldown = 180,
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

            usable = function () return boss end,
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

        usable = function () return boss and race.night_elf end,
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

        potion = "battle_potion_of_agility",

        package = "Subtlety",
    } )


    spec:RegisterPack( "Subtlety", 20190310.0105, [[dafupbqiurEKskBsj6tsiQgfusNckYQKq4vqKzrfClikTlj9ljOHHk4yqPwMsQEguIPjH01OIY2ucLVrfvmoLqkNdIcwhvuP5br19aP9Pe8pjefoivuLfkH6Hqr1erf1fHOqTrLq8rjeLgPeIIoPsizLsuVeviXmHOqUPeIStjWprfsAOqrXsHIspfstLk0vPIQAROcP(kQqCwLqQAVu1FLQbl6WclgupwktgLlJSzO6Zqy0k1PvSALqQ8AjYSj62uPDRQFdmCqCCikA5eEUktN01rvBhk8DuPXJkuNxjz9kHQ5tfz)u2JT3rpkluYxW6CaBKboGfS5qLdyZHII96EuDfeYJcjALceKh9dxYJIYdRssx5rHeRKGG5D0JEaErJ8OBvHCo3cleXOBE4Ad4w4nU8YqhW3ebUw4nUTc9OW8JuxuVh2JYcL8fSohWgzGdybBou5a2COOCOOE0Gx3aHhfDCXCp6Eym69WEugDnp6AwIYdRssxzjMfGGNSYRz5wviNZTWcrm6MhU2aUfEJlVm0b8nrGRfEJBRqR8AwwKcrBBj2CWblxNdyJmyjYAjh4GZ1zohRSvEnlX8D8iOZ5ALxZsK1sNhJrml5OmTswQalzeEWlvlJMoG3s5CA1kVMLiRLywYfGbXSudbcs7dULnWZgDaVLG3YIuikrmlXbcl5mf6UALxZsK1sNhJrmlD(hz5Isj3R6rLZPN3rp6Pui1nX8o6laBVJEu6dyjX8f7rBIrjXeEuSAPgs61k(8Soxkk90Dv6dyjXS0jNS8GqszxdbcsV6T5ftj67NceUwIClXILyYYLwIvlH5XXRNsHu3vEiw6KtwcZJJxXi(52vEiwIjpA00b8E0Bhma3tftjYR(cw37OhL(awsmFXE0MyusmHhTbCHbDiG51RYi8PnQLihQLyBjYAjwTudj9ALrees0pveAGGCR0hWsIz5slXQLW844vmIFUDLhILo5KLXItIrPQUPo(ioTZIVrv6dyjXSCPLCYsnK0Rvwik1VDWaCR0hWsIz5sl5KLAiPxRhpSscCEeuL(awsmlXKLyYJgnDaVhTfszpA6a(UCo1JkNt7F4sEu85NB7vFbyX7OhL(awsmFXE0OPd49O3oyaUNkMsKhTjgLet4r1qsVwpQjiTRuB)dYKNQ0hWsIz5sl1qsVwXNN15srPNURsFaljMLlTKrW844v85zDUuu6P7QcYnM)Se5wITLlT8GqszxdbcsV6T5ftj67NceUwc1Y1TCPL64sDf0zdzjYAPGCJ5plxWYfZJ2w1KuxdbcspFby7vFbf17OhL(awsmFXE0MyusmHhLtwQHKETYiccj6NkcnqqUv6dyjXSCPLXItIrPkSmyuF(UUP(TdgG7vfXxYsOwIflxA5bHKYUgceKE1BZlMs03pfiCTeQLyXJgnDaVh92bdW9uXuI8QVaN5D0JsFaljMVypAtmkjMWJIriMawsv(J6qedqm6QUaOHoG3YLwIvl1qsVwXNN15srPNURsFaljMLlTKrW844v85zDUuu6P7QcYnM)Se5wITLo5KLAiPxRCPac4DJtjrL(awsmlxA5bHKYUgceKE1BZlMs03pfiCTe5qTSOw6KtwglojgLQZtymAapYrxvPpGLeZYLwcZJJxVvUWa51b4Dgf6UYdXYLwEqiPSRHabPx928IPe99tbcxlroulXILizzS4KyuQcldg1NVRBQF7Gb4Ev6dyjXSetE0OPd49O3oyaUNkMsKx9fSyEh9O0hWsI5l2J2eJsIj8Ohesk7Aiqq6z5cqTelE0OPd49O3MxmLOVFkq46vFbohVJE0OPd49O3oyaUNkMsKhL(awsmFXE1REugHh8s17OVaS9o6rJMoG3JEkfsD7rPpGLeZxSx9fSU3rpA00b8E0stRKhL(awsmFXE1xaw8o6rPpGLeZxShnA6aEpAlKYE00b8D5CQhvoN2)WL8On25vFbf17OhL(awsmFXE0MyusmHh9ukK6My1qk9OrthW7rf8FpA6a(UCo1JkNt7F4sE0tPqQBI5vFboZ7OhL(awsmFXE0MyusmHhvdbcsR64sDf0zdz5cwUywU0sb5gZFwIClr0yv3GJTCPLnGlmOdbmVEwUaullQLiRLy1sDCjlrULyZblXKLfHLR7rJMoG3J(dITcldg5vFblM3rpk9bSKy(I9OyesEYJcrmaXOR6cGg6aElxA5bHKYUgceKE1BZlMs03pfiCTCbOwUUhnA6aEpkgHycyj5rXie9pCjpk)rDiIbigDvxa0qhW7vFbohVJEu6dyjX8f7rBIrjXeEumcXeWsQYFuhIyaIrx1fan0b8E0OPd49OTqk7rthW3LZPEu5CA)dxYJEkfsD3BSZR(cw08o6rPpGLeZxShfJqYtE01DMLizPgs61kgdcGOsFaljMLfHLyXzwIKLAiPxRUXPKOdW73oyaUxL(awsmllclx3zwIKLAiPxR3oyaUDCqJ)Q0hWsIzzry56CWsKSudj9AnKrtm6Qk9bSKywwewInhSejlX2zwwewIvlpiKu21qGG0REBEXuI((PaHRLla1sSyjM8OrthW7rXietaljpkgHO)Hl5rpLcPU76wq3gizE1xaYG3rpk9bSKy(I9OnXOKycpk9KaXQkJWN2OwICOwIriMaws1tPqQ7UUf0TbsMhnA6aEpAlKYE00b8D5CQhvoN2)WL8ONsHu39g78QVaS5G3rpk9bSKy(I9OnXOKycpAd4cd6qaZRxLr4tBulroulX2sNCYsDCPUc6SHSe5qTeBlxAzd4cd6qaZRNLla1sS4rJMoG3J2cPShnDaFxoN6rLZP9pCjpk(8ZT9QVaSX27OhL(awsmFXE0MyusmHh9GqszxdbcsV6T5ftj67NceUwc1YIA5slBaxyqhcyE9SCbOwwupA00b8E0wiL9OPd47Y5upQCoT)Hl5rXNFUTx9fG96Eh9O0hWsI5l2J2eJsIj8O0tceRQmcFAJAjYHAjgHycyjvpLcPU76wq3gizE0OPd49OTqk7rthW3LZPEu5CA)dxYJcZpsMx9fGnw8o6rPpGLeZxShTjgLet4rPNeiwvze(0g1YfGAj2oZsKSKEsGyvvqiO3JgnDaVhneT4PUcec6vV6la7I6D0JgnDaVhneT4PoeE5rEu6dyjX8f7vFby7mVJE0OPd49OYbXwV(IoEgcx6vpk9bSKy(I9Qx9Oqeud4chQ3rFby7D0JsFaljMVyV6lyDVJEu6dyjX8f7vFbyX7OhL(awsmFXE1xqr9o6rPpGLeZxSx9f4mVJE0OPd49ONsHu3Eu6dyjX8f7vFblM3rpk9bSKy(I9OrthW7rDdrjI1XbIoJcD7rHiOgWfo0(rnWZopk2oZR(cCoEh9O0hWsI5l2JgnDaVh92bdWTdldgDEuicQbCHdTFud8SZJITx9fSO5D0JgnDaVhfcqhW7rPpGLeZxSx9QhfF(52Eh9fGT3rpk9bSKy(I9OnXOKycpQgs616TdgGBhh04Vk9bSKywU0syEC86pi261XGEeu8nQYdXYLwEqiPSRHabPx928IPe99tbcxlxaQLRBjswIfllcl1qsVwpQjiTRuB)dYKNQ0hWsI5rJMoG3JsymxJeHsE1xW6Eh9O0hWsI5l2J2eJsIj8Oy1sozPgs61kleL63oyaUv6dyjXS0jNSKtwcZJJxVDWaC7S4BuLhILyYYLwQHabPvDCPUc6SHSezTuqUX8NLly5Iz5slfKBm)zjYTuNwPUoUKLfHLR7rJMoG3J(dITcldg5vFbyX7OhL(awsmFXE0OPd49O)GyRWYGrE0MyusmHhLtwIriMawsv(J6qedqm6QUaOHoG3YLwEqiPSRHabPx928IPe99tbcxlxaQLRB5slXQLXItIrP6pi261XGEeu8nQsFaljMLo5KLCYYyXjXOuvqqKtl05r0VDWaCVk9bSKyw6KtwEqiPSRHabPx928IPe99tbcxlrwlJMoyqDgqR)GyRWYGrwUaulx3smz5sl5KLW8441Bhma3ol(gv5Hy5sl1XL6kOZgYYfGAjwT0zwIKLy1Y1TSiSSbCHbDiG51ZsmzjMSCPLccxq3oGLKhTTQjPUgceKE(cW2R(ckQ3rpk9bSKy(I9OnXOKycpQGCJ5plrULnaqYaC)6TYfgiVoaVZOq3vb5gZFwIKLyZblxAzdaKma3VERCHbYRdW7mk0DvqUX8NLihQLoZYLwQHabPvDCPUc6SHSezTuqUX8NLlyzdaKma3VERCHbYRdW7mk0DvqUX8NLizPZ8OrthW7r)bXwHLbJ8QVaN5D0JsFaljMVypAtmkjMWJcZJJxVvUWa51b4Dgf6UYdXYLwIvl5KLAiPxRSquQF7Gb4wPpGLeZsNCYsyEC86TdgGBNfFJQ8qSetE0OPd49Oh1eK2vQT)bzYtE1xWI5D0JsFaljMVypAtmkjMWJEqiPSRHabPx928IPe99tbcxlxaQLRBjswQHKETYcrP(TdgGBL(awsmlrYsnK0R1FqS1tdzjsuPpGLeZJgnDaVh9OMG0UsT9pitEYR(cCoEh9OrthW7rjmMRrIqjpk9bSKy(I9Qx9On25D0xa2Eh9O0hWsI5l2J2eJsIj8OW844vyjaWK8Nwfu0ulDYjlH5XXR3kxyG86a8oJcDx5Hy5slXQLW8441Bhma3oSmy0v5HyPtozzdaKma3VE7Gb42HLbJUQGCJ5plroulXMdwIjpA00b8EuiaDaVx9fSU3rpk9bSKy(I9OrthW7rXietalP(8k93OR6igebgaP2bxBKYqNhrxqrtbcpAtmkjMWJcZJJxVvUWa51b4Dgf6UYdXsNCYsDCPUc6SHSe5wUoh8OF4sEumcXeWsQpVs)n6QoIbrGbqQDW1gPm05r0fu0uGWR(cWI3rpk9bSKy(I9OnXOKycpkmpoE9w5cdKxhG3zuO7kpepA00b8Eu(J6JsUNx9fuuVJEu6dyjX8f7rBIrjXeEuyEC86TYfgiVoaVZOq3vEiE0OPd49OWsaG1X5fR8QVaN5D0JsFaljMVypAtmkjMWJcZJJxVvUWa51b4Dgf6UYdXJgnDaVhfMehjknpcV6lyX8o6rPpGLeZxShTjgLet4rH5XXR3kxyG86a8oJcDx5H4rJMoG3JIpccwcamV6lW54D0JsFaljMVypAtmkjMWJcZJJxVvUWa51b4Dgf6UYdXJgnDaVhn(gDQiK9wiLE1xWIM3rpk9bSKy(I9OnXOKycpkNSeMhhVE7Gb42zX3OkpelxAjmpoE928IPe9Dfi(GbQ8qSCPLW8441BZlMs03vG4dgOki3y(ZsKd1sSuDMhnA6aEp6TdgGBNfFJ8O8h1b44DenMhfBV6lazW7OhL(awsmFXE0MyusmHhfMhhVEBEXuI(UceFWavEiwU0syEC86T5ftj67kq8bdufKBm)zjYHAjwQoZJgnDaVh9w5cdKxhG3zuOBpk)rDaoEhrJ5rX2R(cWMdEh9O0hWsI5l2J2eJsIj8OmGw)bXwHLbJQ60knpclxAjwTKtwQHKETEBEXuI(UceFWav6dyjXS0jNSudj9A92bdWTJdA8xL(awsmlDYjlpiKu21qGG0REBEXuI((PaHRLi3sSyPtozjNSSbasgG7xVnVykrFxbIpyGkpelXKhnA6aEp6TYfgiVoaVZOq3E1xa2y7D0JsFaljMVypAtmkjMWJkIH1jmOxRbJDvEiwU0sSAPgceKw1XL6kOZgYsKBzd4cd6qaZRxLr4tBulDYjl5KLNsHu3eRgsPLlTSbCHbDiG51RYi8PnQLla1YgKUBWX9dc9mlXKhnA6aEpQBikrSooq0zuOBV6la719o6rPpGLeZxShTjgLet4rfXW6eg0R1GXU68wUGLyHdwISwkIH1jmOxRbJDvgVi0b8wU0soz5Pui1nXQHuA5slBaxyqhcyE9QmcFAJA5cqTSbP7gCC)GqpZJgnDaVh1neLiwhhi6mk0Tx9fGnw8o6rPpGLeZxShTjgLet4rBaxyqhcyE9QmcFAJA5cqTCDlrYYtPqQBIvdP0JgnDaVh92bdWTdldgDE1xa2f17OhL(awsmFXE0MyusmHh9GqszxdbcsplxaQLyXYLwYjl1qsVwVDWaC74Gg)vPpGLeZYLwYaA9heBfwgmQQtR08iSCPLCYYtPqQBIvdP0YLw2aajdW9R3kxyG86a8oJcDx5Hy5slBaGKb4(1Bhma3ol(gvB7qGGolxaQLy7rJMoG3JEBEXuI(UceFWaE1xa2oZ7OhL(awsmFXE0MyusmHh9GqszxdbcsplxaQLyXYLwQHKETE7Gb42Xbn(RsFaljMLlTKb06pi2kSmyuvNwP5ry5slH5XXR3kxyG86a8oJcDx5H4rJMoG3JEBEXuI(UceFWaE1xa2lM3rpk9bSKy(I9OnXOKycpkNSeMhhVE7Gb42zX3OkpelxAPoUuxbD2qwICOw6mlrYsnK0R1JhwjbopcQsFaljMLlTKtwkIH1jmOxRbJDvEiE0OPd49O3oyaUDw8nYRE1JEkfsD3BSZ7OVaS9o6rPpGLeZxShfJqYtE0gaizaUF92bdWTZIVr12oeiORJlIMoGpKwUaulXU6CCMhnA6aEpkgHycyj5rXie9pCjp6TzDDlOBdKmV6lyDVJEu6dyjX8f7rBIrjXeEuozjgHycyjvVnRRBbDBGKz5slBaxyqhcyE9QmcFAJA5cwITLlTKrW844v85zDUuu6P7QcYnM)Se5wIThnA6aEpkgXp32R(cWI3rpk9bSKy(I9OrthW7rHaaYUGoaVOrEuIJvr0dxa)RE0IYbpkoq0FIJvFby7vFbf17OhL(awsmFXE0MyusmHhLEsGyLLla1YIYblxAj9KaXQkJWN2OwUaulXMdwU0sozjgHycyjvVnRRBbDBGKz5slBaxyqhcyE9QmcFAJA5cwITLlTKrW844v85zDUuu6P7QcYnM)Se5wIThnA6aEp6TdgGRljzE1xGZ8o6rPpGLeZxShfJqYtE0gWfg0HaMxVkJWN2OwUaullQhnA6aEpkgHycyj5rXie9pCjp6Tz9gWfg0HaMxpV6lyX8o6rPpGLeZxShnA6aEpkgHycyj5rXiK8KhTbCHbDiG51RYi8PnQLihQLyBjswUULfHLXItIrPQUPo(ioTZIVrv6dyjX8OnXOKycpkgHycyjv5pQdrmaXOR6cGg6aElxAjwTudj9A9heB90qwIev6dyjXS0jNSudj9ALfIs9Bhma3k9bSKywIjpkgHO)Hl5rVnR3aUWGoeW865vFbohVJEu6dyjX8f7rBIrjXeEumcXeWsQEBwVbCHbDiG51ZYLwIvl5KLAiPxRSquQF7Gb4wPpGLeZsNCYsgqR)GyRWYGrvb5gZFwUaulDMLizPgs616XdRKaNhbvPpGLeZsmz5slXQLyeIjGLu92SUUf0TbsMLo5KLW8441BLlmqEDaENrHURcYnM)SCbOwIDDDlDYjlpiKu21qGG0REBEXuI((PaHRLla1YIA5slBaGKb4(1BLlmqEDaENrHURcYnM)SCblXMdwIjpA00b8E0Bhma3ol(g5vFblAEh9O0hWsI5l2J2eJsIj8OyeIjGLu92SEd4cd6qaZRNLlTuhxQRGoBilrULnaqYaC)6TYfgiVoaVZOq3vb5gZFwU0sozPigwNWGETgm2v5H4rJMoG3JE7Gb42zX3iV6vpkm)izEh9fGT3rpk9bSKy(I9OnXOKycp6bHKYUgceKEwUaulx3JgnDaVh928IPe99tbcxV6lyDVJE0OPd49OiKaGlSmyKhL(awsmFXE1xaw8o6rJMoG3JchTsNgWEu6dyjX8f7vV6vpkgK4gW7lyDoGnYahwNdyxxhlRVUhLBi(5rCE0fLleGqjMLohlJMoG3s5C6vTYE0dc18fS(IHThfIaGpsYJUMLO8WQK0vwIzbi4jR8AwUvfY5ClSqeJU5HRnGBH34YldDaFte4AH342k0kVMLfPq02wInhCWY15a2idwISwYbo4CDMZXkBLxZsmFhpc6CUw51SezT05XyeZsoktRKLkWsgHh8s1YOPd4TuoNwTYRzjYAjMLCbyqml1qGG0(GBzd8SrhWBj4TSifIseZsCGWsotHURw51SezT05XyeZsN)rwUOuY9QwzR8AwImMJPgVsmlHjCGGSSbCHd1sycX8x1sNxRrq0ZYh8i7oeU48slJMoG)Se8YvvRC00b8xfIGAax4qHIlJRKvoA6a(RcrqnGlCOibTWGhHl9AOd4TYrthWFvicQbCHdfjOfIdamR8AwI(bKBdulfXWSeMhhNywEAONLWeoqqw2aUWHAjmHy(ZY4zwcrqileGQZJWY5SKbEQALJMoG)Qqeud4chksql8(aYTbA)0qpRC00b8xfIGAax4qrcAHNsHu3w5OPd4Vkeb1aUWHIe0cDdrjI1XbIoJcD7aeb1aUWH2pQbE2bfBNzLJMoG)Qqeud4chksql82bdWTdldgDoarqnGlCO9JAGNDqX2khnDa)vHiOgWfouKGwieGoG3kBLxZsKXCm14vIzjHbjwzPoUKL6MSmAkqy5CwgyeJmGLu1kVMLyw6ukK62Yb3siG7gyjzjwFGLyWlFseWsYs6j3HolN3YgWfoumzLJMoG)GEkfsDBLJMoG)qcAHLMwjR8AwI5BQvYsmNZNLHAj(io1khnDa)He0cBHu2JMoGVlNtD4dxcAJDw51SeZY)wIZlLRS84oABtNLkWsDtwIQui1nXSeZc0qhWBjwHxzjdmpclpGdwoQL4arJolHaaY5ry5GB5d098iSColdmIrgWsctvRC00b8hsqluW)9OPd47Y5uh(WLGEkfsDtmhgCONsHu3eRgsPvEnlDEqGixzzbdITcldgzzOwUoswI5yglz8I5ryPUjlXhXPwInhS8Og4zNdwg4kjSu3HAzrrYsmhZy5GB5OwsCmKrqNLChDpVL6MS8jowTSilMZzlbclNZYhOwYdXkhnDa)He0c)bXwHLbJCyWHQHabPvDCPUc6SHwyXwki3y(d5iASQBWXlBaxyqhcyE9waArrwSQJlHCS5aMkI1TYRzjh1xUYY2oEeKLcGg6aElhCl5swUdmilHigGy0vDbqdDaVLhPwgpZsxEPoqKKLAiqq6zjpKQvoA6a(djOfIriMawso8HlbL)OoeXaeJUQlaAOd4DaJqYtqHigGy0vDbqdDa)YdcjLDneii9Q3MxmLOVFkq4Ua01TYRzjMrmaXORSeZc0qhWxKHLiJiTi)SeXGbzzyzteqSmGb8QL0tceRSehiSu3KLNsHu3wI5C(SeRW8JKrclpDKslf0bHAQLJIPQLl65H4GLJAzlElHjl1DOwEJlejvTYrthWFibTWwiL9OPd47Y5uh(WLGEkfsD3BSZHbhkgHycyjv5pQdrmaXOR6cGg6aER8Aw68pIzPcSKr4ZtwYDtVLkWs(JS8ukK62smNZNLaHLW8JKrIZkhnDa)He0cXietaljh(WLGEkfsD31TGUnqYCaJqYtqx3ziPHKETIXGaiQ0hWsIveyXziPHKET6gNsIoaVF7Gb4Ev6dyjXkI1DgsAiPxR3oyaUDCqJ)Q0hWsIveRZbK0qsVwdz0eJUQsFaljwrGnhqcBNvey9GqszxdbcsV6T5ftj67NceUlaflyYkVMLyo4VHrcl5V5ryzyjQsHu3wI5C2sUB6TuqrBppcl1nzj9KaXkl1TGUnqYSYrthWFibTWwiL9OPd47Y5uh(WLGEkfsD3BSZHbhk9KaXQkJWN2OihkgHycyjvpLcPU76wq3gizw51SCrMFUTLHAzrrYsUJUb8QLCg1blDgswYD0TLCg1sSc41ByKLNsHu3yYkhnDa)He0cBHu2JMoGVlNtD4dxck(8ZTDyWH2aUWGoeW86vze(0gf5qX2jN0XL6kOZgc5qXEzd4cd6qaZR3cqXIvEnl5iJUTKZOwgYdyj(8ZTTmullkswgiI5p1sIJJMkxzzrTudbcsplXkGxVHrwEkfsDJjRC00b8hsqlSfszpA6a(UCo1HpCjO4Zp32Hbh6bHKYUgceKE1BZlMs03pfiCHw0LnGlmOdbmVElaTOw51S05FKLHLW8JKrcl5UP3sbfT98iSu3KL0tceRSu3c62ajZkhnDa)He0cBHu2JMoGVlNtD4dxckm)izom4qPNeiwvze(0gf5qXietalP6Pui1Dx3c62ajZkVMLiJaCPtTeIyaIrxz58wgsPLaCl1nzPZdZGmYsyQf8hz5Ow2c(JoldllYI5C2khnDa)He0cdrlEQRaHGE1Hbhk9KaXQkJWN2OlafBNHe9KaXQQGqqVvoA6a(djOfgIw8uhcV8iRC00b8hsqluoi261x0XZq4sVALTYRzzX8JKrIZkhnDa)vH5hjd6T5ftj67NceUom4qpiKu21qGG0BbORBLJMoG)QW8JKHe0cribaxyzWiRC00b8xfMFKmKGwiC0kDAaBLTYRzjMdasgG7Fw5OPd4VAJDqHa0b8om4qH5XXRWsaGj5pTkOOPo5empoE9w5cdKxhG3zuO7kpKLyfMhhVE7Gb42HLbJUkpeNCQbasgG7xVDWaC7WYGrxvqUX8hYHInhWKvEnlxKqkNhHLWrRKLkWsgHh8s1Yrjxl5Vab5CT05FKLChDBj6kxyG8SeGBjNPq3vRC00b8xTXoKGwi)r9rjxh(WLGIriMaws95v6Vrx1rmicmasTdU2iLHopIUGIMceom4qH5XXR3kxyG86a8oJcDx5H4Kt64sDf0zdH815GvoA6a(R2yhsqlK)O(OK75WGdfMhhVERCHbYRdW7mk0DLhIvoA6a(R2yhsqlewcaSooVyLddouyEC86TYfgiVoaVZOq3vEiw5OPd4VAJDibTqysCKO08iCyWHcZJJxVvUWa51b4Dgf6UYdXkhnDa)vBSdjOfIpccwcamhgCOW8441BLlmqEDaENrHUR8qSYrthWF1g7qcAHX3OtfHS3cP0HbhkmpoE9w5cdKxhG3zuO7kpeR8Aw68pYsohFJSeGJJSiAmlHjCGGSu3KL4J4ulr38IPe9wIQaHRL4cGRLoceFWaw2aU0z58vRC00b8xTXoKGw4TdgGBNfFJCG)OoahVJOXGITddouobZJJxVDWaC7S4BuLhYsyEC86T5ftj67kq8bdu5HSeMhhVEBEXuI(UceFWavb5gZFihkwQoZkVMLy15)s6oldPGc2kl5Hyjm1c(JSKlzPcaLSeDhmaxlxeqJ)WKL8hzj6kxyG8SeGJJSiAmlHjCGGSu3KL4J4ulr38IPe9wIQaHRL4cGRLoceFWaw2aU0z58vRC00b8xTXoKGw4TYfgiVoaVZOq3oWFuhGJ3r0yqX2HbhkmpoE928IPe9Dfi(GbQ8qwcZJJxVnVykrFxbIpyGQGCJ5pKdflvNzLxZsN)rwIUYfgiplbVLnaqYaCFlXAGRKWs8rCQLfmi2kSmyeMSK)L0DwYLSmeKLiaZJWsfyjeaelDei(GbSmEMLmGLpqTChyqwIUdgGRLlcOXFvRC00b8xTXoKGw4TYfgiVoaVZOq3om4qzaT(dITcldgv1PvAEelXkN0qsVwVnVykrFxbIpyGk9bSKyo5Kgs616TdgGBhh04Vk9bSKyo50bHKYUgceKE1BZlMs03pfiCrowCYjo1aajdW9R3MxmLOVRaXhmqLhcMSYRz5Ic3YGXoldbzjpehS8(bczPUjlbpzj3r3wkbCPtT0rh5C1sN)rwYDtVLSvZJWs84usyPUJ3smhZyjJWN2Owcew(a1YtPqQBIzj3r3aE1Y4xzjMJzQw5OPd4VAJDibTq3quIyDCGOZOq3om4qfXW6eg0R1GXUkpKLyvdbcsR64sDf0zdH8gWfg0HaMxVkJWN2Oo5eNoLcPUjwnKYLnGlmOdbmVEvgHpTrxaAds3n44(bHEgMSYRz5Ic3YhyzWyNLChP0s2qwYD098wQBYYN4y1sSWHZbl5pYYIeoNTe8wcdUZsUJUb8QLXVYsmhZyz8mlFGLNsHu3vRC00b8xTXoKGwOBikrSooq0zuOBhgCOIyyDcd61AWyxD(fWchqwrmSoHb9AnySRY4fHoGFjNoLcPUjwnKYLnGlmOdbmVEvgHpTrxaAds3n44(bHEMvoA6a(R2yhsql82bdWTdldgDom4qBaxyqhcyE9QmcFAJUa01r6ukK6My1qkTYRzPZtTelizj3r3aE1s0DWaCTCran(Zs(JS0rG4dgWsUJUTefWzlJNzjNJVrwkOGTQAjhHSK7iLwcbaXsDdoYsychiil1nzj(io1YtbcxlBax6SC(QvoA6a(R2yhsql828IPe9Dfi(GbCyWHEqiPSRHabP3cqXYsoPHKETE7Gb42Xbn(RsFalj2sgqR)GyRWYGrvDALMhXsoDkfsDtSAiLlBaGKb4(1BLlmqEDaENrHUR8qw2aajdW9R3oyaUDw8nQ22HabDlafBR8Aw68ulXcswYD0TLO7Gb4A5IaA8NL8hzPJaXhmGLChDBjkGZwgsbfSvwYdPALJMoG)Qn2He0cVnVykrFxbIpyahgCOhesk7Aiqq6TauSSudj9A92bdWTJdA8xL(awsSLmGw)bXwHLbJQ60knpILW8441BLlmqEDaENrHUR8qSYrthWF1g7qcAH3oyaUDw8nYHbhkNG5XXR3oyaUDw8nQYdzPoUuxbD2qihQZqsdj9A94HvsGZJGQ0hWsITKtIyyDcd61AWyxLhIv2kVMLlY8ZTjXzLxZsKXymxJeHswUheB6ulHigGy0vwgQLRJKLAiqq6zj3r3wIUdgGRLlcOXFwIvNHKLChDBjk1eKAPJuB)dYKNSCEldgB0b8yYY4zwwWGyRf5NLC00JGIVrwYdPALJMoG)Q4Zp3gkHXCnsek5WGdvdj9A92bdWTJdA8xL(awsSLW8441FqS1RJb9iO4BuLhYYdcjLDneii9Q3MxmLOVFkq4Ua01rclfHgs616rnbPDLA7FqM8uL(awsmR8AwYrHiiwYdXYcgeBfwgmYYb3YrTColdyaVAPcSuW)wc41QLCgy5dul5pYYck2sgVyEewY54BKdwo4wQHKELywoVcSKZHOKLO7Gb4wTYrthWFv85NBJe0c)bXwHLbJCyWHIvoPHKETYcrP(TdgGBL(awsmNCItW8441Bhma3ol(gv5HGPLAiqqAvhxQRGoBiKvqUX83cl2sb5gZFixNwPUoUurSUvEnlls8sDyavNhHLaE9ggzjNJVrwcEl1qGG0ZsDhQLChP0s5GbzjoqyPUjlz8IqhWBja3YcgeBfwgmYblfeUGUTLmEX8iSes8mYDAvlls8sDya1Y4SucEewgNLRJKLAiqq6zjdy5dul3bgKLfmi2kSmyKL8qSK7OBlXSee50cDEewIUdgG7zjw5FjDNLRa8wUdmillyqS1I8ZsoA6rqX3ilvaatvRC00b8xfF(52ibTWFqSvyzWihARAsQRHabPhuSDyWHYjmcXeWsQYFuhIyaIrx1fan0b8lpiKu21qGG0REBEXuI((PaH7cqxFjwJfNeJs1FqS1RJb9iO4BuL(awsmNCItXItIrPQGGiNwOZJOF7Gb4Ev6dyjXCYPdcjLDneii9Q3MxmLOVFkq4ISrthmOodO1FqSvyzWOfGUoMwYjyEC86TdgGBNfFJQ8qwQJl1vqNn0cqXQZqcRRxenGlmOdbmVEyctlfeUGUDaljR8AwIzjCbDBllyqSvyzWilPqixz5GB5OwYDKsljogYiilz8I5ryj6kxyG8QwYzGL6oulfeUGUTLdULOaoBjcsplfuWwz58wQBYYN4y1sNDvRC00b8xfF(52ibTWFqSvyzWihgCOcYnM)qEdaKma3VERCHbYRdW7mk0DvqUX8hsyZHLnaqYaC)6TYfgiVoaVZOq3vb5gZFihQZwQHabPvDCPUc6SHqwb5gZFl0aajdW9R3kxyG86a8oJcDxfKBm)HKZSYRzjk1eKAPJuB)dYKNSKXlMhHLORCHbYRAjhz0TLCoeLSeDhmaxlbVCLLmEX8iSeDhmaxl5C8nYsSY)6iTu3c62ajZY5T8jowTuopHPQvoA6a(RIp)CBKGw4rnbPDLA7FqM8KddouyEC86TYfgiVoaVZOq3vEilXkN0qsVwzHOu)2bdWTsFaljMtobZJJxVDWaC7S4BuLhcMSYRzjhz0TL0d4rSTudbcspldj3y1zj)rwIsnhPMLG3smNZvRC00b8xfF(52ibTWJAcs7k12)Gm5jhgCOhesk7Aiqq6vVnVykrF)uGWDbORJKgs61kleL63oyaUv6dyjXqsdj9A9heB90qwIev6dyjXSYrthWFv85NBJe0cjmMRrIqjRSvEnlrvkK62smhaKma3)SYRzzrMKecjSKJoetaljRC00b8x9ukK6U3yhumcXeWsYHpCjO3M11TGUnqYCaJqYtqBaGKb4(1Bhma3ol(gvB7qGGUoUiA6a(qUauSRohNzLxZso64NBBj)lP7SKlzziildyaVAPcSSfqSe8wY54BKLTDiqqx1soQVCLLC30B5ImpZsocfLE6olNZYagWRwQalf8VLaETALJMoG)QNsHu39g7qcAHye)CBhgCOCcJqmbSKQ3M11TGUnqYw2aUWGoeW86vze(0gDbSxYiyEC8k(8Soxkk90Dvb5gZFihBR8AwIzaaPL4aHLO7Gb46ssMLizj6oyaUNkMsKL8VKUZsUKLHGSmGb8QLkWYwaXsWBjNJVrw22HabDvl5O(YvwYDtVLlY8ml5iuu6P7SColdyaVAPcSuW)wc41QvoA6a(REkfsD3BSdjOfcbaKDbDaErJCahi6pXXkuSDG4yve9WfW)k0IYbRC00b8x9ukK6U3yhsql82bdW1LKmhgCO0tceRwaAr5Ws6jbIvvgHpTrxak2CyjNWietalP6TzDDlOBdKSLnGlmOdbmVEvgHpTrxa7LmcMhhVIppRZLIspDxvqUX8hYX2kVMLyoMXsbHm5hb5sV6CTKZX3ild1sjGRLyoMXs4vwYi8GxQvRC00b8x9ukK6U3yhsqleJqmbSKC4dxc6Tz9gWfg0HaMxphWiK8e0gWfg0HaMxVkJWN2OlaTOw51SeZXmwkiKj)iix6vNRLCo(gzj4LRSeMWbcYs85NBtIZYb3sUKL7adYYWfILAiPxplJNzjeXaeJUYsbqdDaF1khnDa)vpLcPU7n2He0cXietaljh(WLGEBwVbCHbDiG51ZbmcjpbTbCHbDiG51RYi8PnkYHInsRxeXItIrPQUPo(ioTZIVrv6dyjXCyWHIriMawsv(J6qedqm6QUaOHoGFjw1qsVw)bXwpnKLirL(awsmNCsdj9ALfIs9Bhma3k9bSKyyYkVMLCKr3wY5quYs0DWaCTe8YvwY54BKLC30BzbdITcldgzj3rkT80yLL8qQw68pYsgVyEewIUYfgiplbcldyagKL6wq3gizvRC00b8x9ukK6U3yhsql82bdWTZIVrom4qXietalP6Tz9gWfg0HaMxVLyLtAiPxRSquQF7Gb4wPpGLeZjNyaT(dITcldgvfKBm)TauNHKgs616XdRKaNhbvPpGLedtlXkgHycyjvVnRRBbDBGK5KtW8441BLlmqEDaENrHURcYnM)wak211DYPdcjLDneii9Q3MxmLOVFkq4Ua0IUSbasgG7xVvUWa51b4Dgf6Uki3y(BbS5aMSYRzzX8I3sb5gZppcl5C8n6SeMWbcYsDtwQHabPwYg6SCWTefWzl5c(IC1syYsbfSvwoVL64svRC00b8x9ukK6U3yhsql82bdWTZIVrom4qXietalP6Tz9gWfg0HaMxVL64sDf0zdH8gaizaUF9w5cdKxhG3zuO7QGCJ5VLCsedRtyqVwdg7Q8qSYwzR8AwIQui1nXSeZc0qhWBLxZYffULOkfsDxigXp32YqqwYdXbl5pYs0DWaCpvmLilvGLW0t4JAjUa4APUjlHe3nyqwcdE(ZY4zwUiZZSKJqrPNUZbljmO3Yb3sUKLHGSmulDdo2smhZyjwXfaxl1nzjeb1aUWHAzrcNZyQALJMoG)QNsHu3ed6TdgG7PIPe5WGdfRAiPxR4ZZ6CPO0t3vPpGLeZjNoiKu21qGG0REBEXuI((PaHlYXcMwIvyEC86Pui1DLhItobZJJxXi(52vEiyYkVMLlY8ZTTmullkswI5ygl5o6gWRwYzuhS0zizj3r3wYzuhSmEMLlMLChDBjNrTmWvsyjhD8ZTTeiS0Xnz5ImItTKZX3ilJNz5dSKZHOKLO7Gb4Ajsw(alr5HvsGZJGSYrthWF1tPqQBIHe0cBHu2JMoGVlNtD4dxck(8ZTDyWH2aUWGoeW86vze(0gf5qXgzXQgs61kJiiKOFQi0ab5wPpGLeBjwH5XXRye)C7kpeNCkwCsmkv1n1XhXPDw8nQsFalj2soPHKETYcrP(TdgGBL(awsSLCsdj9A94HvsGZJGQ0hWsIHjmzLxZsNNA56wQHabPNLChDBjk1eKAPJuB)dYKNSSerqSKhILlY8ml5iuu6P7SeELLTvn58iSeDhma3tftjQALJMoG)QNsHu3edjOfE7Gb4EQykro0w1KuxdbcspOy7WGdvdj9A9OMG0UsT9pitEQsFalj2snK0Rv85zDUuu6P7Q0hWsITKrW844v85zDUuu6P7QcYnM)qo2lpiKu21qGG0REBEXuI((PaHl01xQJl1vqNneYki3y(BHfZkVMLCKr3aE1soteesyjQkcnqqUwgpZsSyjMn(sNLaCllwgmYY5Tu3KLO7Gb4EwoQLZzjxGq3wYFZJWs0DWaCpvmLilbVLyXsneii9Qw5OPd4V6Pui1nXqcAH3oyaUNkMsKddouoPHKETYiccj6NkcnqqUv6dyjXwglojgLQWYGr9576M63oyaUxveFjOyz5bHKYUgceKE1BZlMs03pfiCHIfR8AwUiaHLqedqm6klfan0b8oyj)rwIUdgG7PIPezjadsyjQceUwInMSK7OBl5ifjldeX8NAjpelvGLf1sneii9CWY1XKLdULlchXY5SuW))8iSeGJBjwbVLXVYYWfW)QLaCl1qGG0dtoyjqyjwWKLkWs3GJh3zXjlrbC2sIJv6Vb8wYD0TLlQNWy0aEKJUYsWBjwSudbcsplXArTK7OBllEuumvTYrthWF1tPqQBIHe0cVDWaCpvmLihgCOyeIjGLuL)OoeXaeJUQlaAOd4xIvnK0Rv85zDUuu6P7Q0hWsITKrW844v85zDUuu6P7QcYnM)qo2o5Kgs61kxkGaE34usuPpGLeB5bHKYUgceKE1BZlMs03pfiCro0I6KtXItIrP68egJgWJC0vv6dyjXwcZJJxVvUWa51b4Dgf6UYdz5bHKYUgceKE1BZlMs03pfiCrouSGuS4KyuQcldg1NVRBQF7Gb4Ev6dyjXWKvoA6a(REkfsDtmKGw4T5ftj67NceUom4qpiKu21qGG0BbOyXkhnDa)vpLcPUjgsql82bdW9uXuI8Qx9Ea]] )


end
