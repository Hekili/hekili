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


    spec:RegisterPack( "Subtlety", 20190201.2322, [[daLimbqiqLEeOInPK8jOsrnkcvDkcvwfLI8kqvZIsYTusv7sk)IsyyuQ4yqfltsXZGQY0usPRrPW2OujFJsLQXPKkX5OuuTokvkZdQK7bk7Jsv)JsrjDqOQklusPhcvQMiLOUiuPiBujv8rLujzKkPsQtQKk1kLu9sOsHMjuPGBcvkzNus9tkffdvjfTuOQYtH0ujuUkLiSvOsP(kLi6SukkXEP4Vs1GfDyHfdXJLyYOCzKndLpdIrRuNwXQPuuQxReMnQUTKSBGFRQHdshxjfworpxLPt66eSDOkFNqgpLiDELO1dvv18PuA)uTbhJyguwOKX6ASdo2C7uJDWPvd(QPgCS5guDjuYGcnklciKbfevKbfvar5KU0GcnwY)GzeZGEVGSqg0TQqp7Mfwaz0TasR8vwCtLap05bfzGPwCtvXce(JybcwSEgHNfqLp2WPZI1us4xmSZI1e)643drG6OcikN0LTBQkgueHHRRBGbXGYcLmwxJDWXMBNASdoTAWxn1GJD3Ggc6(Lgu0Pc3nO7HXiGbXGYORyqHJNOcikN0LEIFpebYRdhp3Qc9SBwybKr3ciTYxzXnvc8qNhuKbMAXnvflq4pIfiyX6zeEwav(ydNolwtjHFXWolwt8RJFpebQJkGOCsx2UPQ41HJNRdHifc5spXXkpRXo4yZ9C9Ewd(SB1GJx3RdhpX9DaGqNDZRdhpxVN4pgJyEIBCkl8uFpzewiWvpJIopWt(CAZRdhpxVN4hv94rmp1qcH0(G5z5bSrNh45d8e3kKliMNyV0tltHUBED44569e)XyeZtlXrEUUvQ6Agu(C6zeZGEkfCDtmJygRXXiMbLabcNyMAnOf5OKCcdkIagw7uk46Uja1GgfDEGb92b7fDQCwqg1yDngXmOeiq4eZuRbTihLKtyqlFfY3H(dqVgJWMYOEIlyEIJNR3tX7PgCcOngrqjz)uzObeQQrGaHtmpx5P49eradRHxaMB3eG6PT26zG)j5Out3uhBKN2zbOqnceiCI55kpHRNAWjG2yHCr)2b7f1iqGWjMNR8eUEQbNaA7equsIjaHAeiq4eZtX5P4mOrrNhyqlbN3JIopOZNtnO850oiQidk2aMBBuJ14ZiMbLabcNyMAnOrrNhyqVDWErNkNfKbTihLKtyq1GtaTDursAxPYgmRHa1iqGWjMNR8udob0g2ayDruSaq31iqGWjMNR8KricyynSbW6IOybGURjPQyaNN4YtC8CLNhuIZ7AiHq61UTGCwqG(PVSYtyEwJNR8udjesB6urD97SH8C9EkPQyaNN27PDzqlllCQRHecPNXACmQX61AeZGsGaHtmtTg0ICusoHbfUEQbNaAJreus2pvgAaHQAeiq4eZZvEg4Fsok1q4bJ6dORBQF7G9IUMmal8eMN4ZZvEEqjoVRHecPx72cYzbb6N(YkpH5j(mOrrNhyqVDWErNkNfKrnwBdJyguceiCIzQ1GwKJsYjmOhuIZ7AiHq65P9W8eFg0OOZdmO3wqoliq)0xwzuJ12LrmdAu05bg0BhSx0PYzbzqjqGWjMPwJAudkJWcbUAeZynogXmOrrNhyqpLcUUnOeiq4eZuRrnwxJrmdAu05bg0ftzHbLabcNyMAnQXA8zeZGsGaHtmtTg0OOZdmOLGZ7rrNh05ZPgu(CAhevKbTWoJASETgXmOeiq4eZuRbTihLKtyqpLcUUjwl4CdAu05bguPaOhfDEqNpNAq5ZPDqurg0tPGRBIzuJ12WiMbLabcNyMAnOf5OKCcdQgsiK20PI663zd5P9EAxEUYtjvfd48exEcPWAvHL65kplFfY3H(dqppThMNR1Z17P49uNkYtC5jo2XtX5Pn5zng0OOZdmOGbYwr4bJmQXA7YiMbLabcNyMAnO4fCbYGcvoVC0LD5RHopWZvEEqjoVRHecPx72cYzbb6N(YkpThMN1yqJIopWGIxiNaHtgu8czhevKbv4Oou58Yrx2LVg68aJAS2UBeZGsGaHtmtTg0ICusoHbfVqobcNAch1HkNxo6YU81qNhyqJIopWGwcoVhfDEqNpNAq5ZPDqurg0tPGR7EHDg1y96IrmdkbceoXm1AqXl4cKbTgB4j8EQbNaAdVbYlBeiq4eZtBYt8zdpH3tn4eqBvXPKS)y9BhSx01iqGWjMN2KN1ydpH3tn4eqB3oyVOo2xeUgbceoX80M8Sg74j8EQbNaAl4rro6YgbceoX80M8eh74j8EIJn80M8u8EEqjoVRHecPx72cYzbb6N(YkpThMN4ZtXzqJIopWGIxiNaHtgu8czhevKb9uk46URBjD7NZmQXABUrmdkbceoXm1AqlYrj5egucqsilBmcBkJ6jUG5jEHCceo1oLcUU76ws3(5mpx5z5Rq(o0Fa61ye2ug1t7H55AnOrrNhyqlbN3JIopOZNtnO850oiQid6PuW1DVWoJASgh7yeZGsGaHtmtTg0ICusoHbLaKeYYgJWMYOEIlyEIxiNaHtTtPGR7UUL0TFoZZvEQbNaAJfYf9BhSxuJabcNyEUYtn4eqBhvKK2vQSbZAiqnceiCI55kpl)ZzViq7OIK0UsLnywdbQja1ZvEEqjoVRHecPx72cYzbb6N(YkpXfmpxRbnk68adAj48Eu05bD(CQbLpN2brfzqpLcUU7f2zuJ14GJrmdkbceoXm1AqlYrj5eg0YxH8DO)a0RXiSPmQN4cMN44PT26Povux)oBipXfmpXXZvEw(kKVd9hGEEApmpXNbnk68adAj48Eu05bD(CQbLpN2brfzqXgWCBJASgNAmIzqjqGWjMPwdArokjNWGEqjoVRHecPx72cYzbb6N(YkpH55A9CLNLVc57q)bONN2dZZ1AqJIopWGwcoVhfDEqNpNAq5ZPDqurguSbm32OgRXbFgXmOeiq4eZuRbTihLKtyqjajHSSXiSPmQN4cMN4fYjq4u7uk46URBjD7NZmOrrNhyqlbN3JIopOZNtnO850oiQidkIWWzg1ynoR1iMbLabcNyMAnOf5OKCcdkbijKLngHnLr90EyEIJn8eEpjajHSSjjieWGgfDEGbnKLaqD9LscOg1yno2WiMbnk68adAilbG6qf4hzqjqGWjMPwJASgh7YiMbnk68adkFGS1RBZwGbPIaQbLabcNyMAnQrnOqLu5Rqc1iMXACmIzqjqGWjMPwJASUgJyguceiCIzQ1OgRXNrmdkbceoXm1AuJ1R1iMbLabcNyMAnQXAByeZGgfDEGb9uk462GsGaHtmtTg1yTDzeZGsGaHtmtTg0OOZdmOvHCbX6yVSZOq3guOsQ8viH2pQ8a2zqXXgg1yTD3iMbLabcNyMAnOrrNhyqVDWErDeEWOZGcvsLVcj0(rLhWodkog1y96IrmdAu05bguOVopWGsGaHtmtTg1OgueHHZmIzSghJyguceiCIzQ1GwKJsYjmOhuIZ7AiHq65P9W8SgdAu05bg0BliNfeOF6lRmQX6AmIzqJIopWGcH)FfcpyKbLabcNyMAnQXA8zeZGgfDEGbfjklonqmOeiq4eZuRrnQbTWoJygRXXiMbLabcNyMAnOf5OKCcdkIagwdH)pJlCAtsrr90wB9eradRDlRqE(1FSoJcD3eG65kpfVNicyyTBhSxuhHhm6Acq90wB9S8pN9IaTBhSxuhHhm6AsQkgW5jUG5jo2XtXzqJIopWGc915bg1yDngXmOeiq4eZuRbnk68adkEHCceo1hGsGB0LDidKaVNR9)kdNh6aG0Luu0xAqlYrj5eguebmS2TSc55x)X6mk0DtaQN2ARN6urD97SH8exEwJDmOGOImO4fYjq4uFakbUrx2Hmqc8EU2)RmCEOdasxsrrFPrnwJpJyguceiCIzQ1GwKJsYjmOicyyTBzfYZV(J1zuO7MaudAu05bguHJ6JsvNrnwVwJyguceiCIzQ1GwKJsYjmOicyyTBzfYZV(J1zuO7MaudAu05bgue()SoMGCPrnwBdJyguceiCIzQ1GwKJsYjmOicyyTBzfYZV(J1zuO7MaudAu05bguesEKCXaGyuJ12LrmdkbceoXm1AqlYrj5eguebmS2TSc55x)X6mk0DtaQbnk68adk2ije()mJAS2UBeZGsGaHtmtTg0ICusoHbfradRDlRqE(1FSoJcD3eGAqJIopWGgGcDQm49sW5g1y96IrmdkbceoXm1AqlYrj5egu46jIagw72b7f1zbOqnbOEUYtebmS2TfKZcc01xcc23eG65kpreWWA3wqoliqxFjiyFtsvXaopXfmpXxZgg0OOZdmO3oyVOolafYGkCu)XW6qkmdkog1yTn3iMbLabcNyMAnOf5OKCcdkIagw72cYzbb66lbb7Bcq9CLNicyyTBliNfeORVeeSVjPQyaNN4cMN4RzddAu05bg0BzfYZV(J1zuOBdQWr9hdRdPWmO4yuJ14yhJyguceiCIzQ1GwKJsYjmOSxBGbYwr4bJA6uwmaiEUYtX7jC9udob02TfKZcc01xcc23iqGWjMN2ARNAWjG2UDWErDSViCnceiCI5PT265bL48UgsiKETBliNfeOF6lR8exEIppT1wpHRNL)5SxeODBb5SGaD9LGG9nbOEkodAu05bg0BzfYZV(J1zuOBJASghCmIzqjqGWjMPwdArokjNWGkJH1j8iG2cg7Acq9CLNI3tnKqiTPtf11VZgYtC5z5Rq(o0Fa61ye2ug1tBT1t465PuW1nXAbN75kplFfY3H(dqVgJWMYOEApmplq7vHL2pOeG5P4mOrrNhyqRc5cI1XEzNrHUnQXACQXiMbLabcNyMAnOf5OKCcdQmgwNWJaAlySRnapT3t8zhpxVNYyyDcpcOTGXUgtqg68apx5jC98uk46MyTGZ9CLNLVc57q)bOxJrytzupThMNfO9QWs7hucWmOrrNhyqRc5cI1XEzNrHUnQXACWNrmdkbceoXm1AqlYrj5eg0YxH8DO)a0RXiSPmQN2dZZA8eEppLcUUjwl4CdAu05bg0BhSxuhHhm6mQXACwRrmdkbceoXm1AqlYrj5eg0dkX5DnKqi980EyEIppx5jC9udob02Td2lQJ9fHRrGaHtmpx5j71gyGSveEWOMoLfdaINR8eUEEkfCDtSwW5EUYZY)C2lc0ULvip)6pwNrHUBcq9CLNL)5SxeOD7G9I6SauOwzhsi05P9W8ehdAu05bg0BliNfeORVeeS3OgRXXggXmOeiq4eZuRbTihLKtyqpOeN31qcH0Zt7H5j(8CLNAWjG2UDWErDSViCnceiCI55kpzV2adKTIWdg10PSyaq8CLNicyyTBzfYZV(J1zuO7MaudAu05bg0BliNfeORVeeS3OgRXXUmIzqjqGWjMPwdArokjNWGcxpreWWA3oyVOolafQja1ZvEQtf11VZgYtCbZtB4j8EQbNaA7equsIjaHAeiq4eZZvEcxpLXW6eEeqBbJDnbOg0OOZdmO3oyVOolafYOg1GEkfCD3lSZiMXACmIzqjqGWjMPwdkEbxGmOL)5SxeOD7G9I6SauOwzhsi01XKrrNheCpThMN40S72WGgfDEGbfVqobcNmO4fYoiQid6TzDDlPB)CMrnwxJrmdkbceoXm1AqlYrj5egu46jEHCceo1UnRRBjD7NZ8CLNmcradRHnawxefla0Dnjvfd48exEIJNR8S8viFh6pa9AmcBkJ6P9EIJbnk68adkEbyUTrnwJpJyguceiCIzQ1GgfDEGbf6)8UKUxqwidkzPQm6r1laud6ATJbf7LDazPQXACmQX61AeZGsGaHtmtTg0ICusoHbLaKeYspThMNR1oEUYtcqsilBmcBkJ6P9W8eh745kpHRN4fYjq4u72SUUL0TFoZZvEYiebmSg2ayDruSaq31KuvmGZtC5joEUYZYxH8DO)a0RXiSPmQN27jog0OOZdmO3oyVOkIZmQXAByeZGsGaHtmtTg0ICusoHbv8Ecxp1GtaTXc5I(Td2lQrGaHtmpT1wpzV2adKTIWdg1KuvmGZt7H5Pn8eEp1GtaTDcikjXeGqnceiCI5P48CLNI3t46PgCcOnWazRNg8fKSrGaHtmpx5jC9udob0glKl63oyVOgbceoX80wB9eUEIxiNaHtnHJ6qLZlhDzx(AOZd80wB9S8viFh6pa9AmcBkJ6jUG5joEcVN14Pn5zG)j5Out3uhBKN2zbOqnceiCI5P48CLNI3t8c5eiCQDBwx3s62pN5PT26jIagw7wwH88R)yDgf6UjPQyaNN2dZtCA14PT265bL48UgsiKETBliNfeOF6lR80EyEUwpx5z5Fo7fbA3YkKNF9hRZOq3njvfd480EpXXoEkodAu05bg0BhSxuNfGczuJ12LrmdkbceoXm1AqlYrj5eguDQOU(D2qEIlpl)ZzViq7wwH88R)yDgf6UjPQyaNNR8eUEkJH1j8iG2cg7AcqnOrrNhyqVDWErDwakKrnQbfBaZTnIzSghJyguceiCIzQ1GwKJsYjmOAWjG2UDWErDSViCnceiCI55kpreWWAGbYwVoEeacfGc1eG65kppOeN31qcH0RDBb5SGa9tFzLN2dZZA8eEpXNN2KNAWjG2oQijTRuzdM1qGAeiq4eZGgfDEGbLWBUcjdLmQX6AmIzqjqGWjMPwdArokjNWGkEpHRNAWjG2yHCr)2b7f1iqGWjMN2ARNW1tebmS2Td2lQZcqHAcq9uCEUYtnKqiTPtf11VZgYZ17PKQIbCEAVN2LNR8usvXaopXLN6uw01PI80M8SgdAu05bguWazRi8Grg1yn(mIzqjqGWjMPwdAu05bguWazRi8Grg0ICusoHbfUEIxiNaHtnHJ6qLZlhDzx(AOZd8CLNhuIZ7AiHq61UTGCwqG(PVSYt7H5znEUYtX7zG)j5Oudmq261XJaqOauOgbceoX80wB9eUEg4Fsok1Keu(ucDaq63oyVORrGaHtmpT1wppOeN31qcH0RDBb5SGa9tFzLNR3ZOOdEuN9Admq2kcpyKN2dZZA8uCEUYt46jIagw72b7f1zbOqnbOEUYtnKqiTPtf11VZgYt7H5P490gEcVNI3ZA80M8S8viFh6pa98uCEkopx5PKWK0TdeozqlllCQRHecPNXACmQX61AeZGsGaHtmtTg0ICusoHbvsvXaopXLNL)5SxeODlRqE(1FSoJcD3KuvmGZt49eh745kpl)ZzViq7wwH88R)yDgf6UjPQyaNN4cMN2WZvEQHecPnDQOU(D2qEUEpLuvmGZt79S8pN9IaTBzfYZV(J1zuO7MKQIbCEcVN2WGgfDEGbfmq2kcpyKrnwBdJyguceiCIzQ1GwKJsYjmOicyyTBzfYZV(J1zuO7Maupx5P49eUEQbNaAJfYf9BhSxuJabcNyEARTEIiGH1UDWErDwakutaQNIZGgfDEGb9OIK0UsLnywdbYOgRTlJyguceiCIzQ1GwKJsYjmOhuIZ7AiHq61UTGCwqG(PVSYt7H5znEcVNAWjG2yHCr)2b7f1iqGWjMNW7PgCcOnWazRNg8fKSrGaHtmdAu05bg0Jkss7kv2GzneiJAS2UBeZGgfDEGbLWBUcjdLmOeiq4eZuRrnQrnO4rYBEGX6ASdoRl4Gdo28wn4uJDzqffsWaGCg01Df0xQeZt7UNrrNh4jFo9AEDdku5JnCYGchprfquoPl9e)EicKxhoEUvf6z3SWciJUfqALVYIBQe4HopOidm1IBQkwGWFelqWI1Zi8SaQ8XgoDwSMsc)IHDwSM4xh)Eicuhvar5KUSDtvXRdhpxhcrkeYLEIJvEwJDWXM7569Sg8z3QbhVUxhoEI77aaHo7MxhoEUEpXFmgX8e34uw4P(EYiSqGREgfDEGN850MxhoEUEpXpQ6XJyEQHecP9bZZYdyJopWZh4jUvixqmpXEPNwMcD386WXZ17j(JXiMNwIJ8CDRu1186ED44jUjlLkckX8eHWEj5z5Rqc1tecYaUMN4VsHGQNNGhS(DiRWe4EgfDEW55d4lBE9OOZdUgujv(kKqHHXJBHxpk68GRbvsLVcju4HzriaPIaAOZd86rrNhCnOsQ8viHcpmlW(N51HJNOGa6TF1tzmmpreWWiMNNg65jcH9sYZYxHeQNieKbCEgaMNqL06H(QoaiEoNNShqnVEu05bxdQKkFfsOWdZIdeqV9R9td986rrNhCnOsQ8viHcpmloLcUU96rrNhCnOsQ8viHcpmlQc5cI1XEzNrHUTcQKkFfsO9JkpGDWWXgE9OOZdUgujv(kKqHhMf3oyVOocpy0zfujv(kKq7hvEa7GHJxpk68GRbvsLVcju4Hzb0xNh4196WXtCtwkveuI5jHhjx6PovKN6M8mk6l9Copd8IHhiCQ51HJN4hDkfCD75G5j0)UbHtEkEW7jEcCajdeo5jbOQHophGNLVcjuX51JIop4GDkfCD71JIop4GhMflMYcVoC8e33uzHN4ULppd1tSrEQxpk68GdEywucoVhfDEqNpNAfiQiyf251HJN4NaWtmboFPNNOrlB68uFp1n5jQsbx3eZt871qNh4P4rw6j7haepV3kph1tSxwOZtO)ZhaephmpbVUhaepNZZaVy4bcNexZRhfDEWbpmlKcGEu05bD(CQvGOIGDkfCDtmRgmyNsbx3eRfCUxhoEI)GcLV0tRhiBfHhmYZq9Sg49e3xtpzcYbaXtDtEInYt9eh745rLhWoR8mWus6PUd1Z1cVN4(A65G55OEswk0rsNNIgDpap1n5jGSu1Z1v4UL98LEoNNGx9uaQxpk68GdEywagiBfHhmYQbdMgsiK20PI663zdzVDTssvXaoCbPWAvHLUQ8viFh6pa9Sh2AxV41PIWfo2rC2unED44PndGV0ZYoaqipLVg68aphmpfrEUd8ipHkNxo6YU81qNh45rQNbG5zLaxhOCYtnKqi98uaAZRhfDEWbpmlWlKtGWjRarfbt4Oou58Yrx2LVg68aRWl4cemOY5LJUSlFn05bRoOeN31qcH0RDBb5SGa9tFzL9WQXRdhpxt58Yrx6j(9AOZdSz1tCdKIB(8eYGh5z4zrgq9mqEb1tcqsil9e7LEQBYZtPGRBpXDlFEkEeHHZiPNNoCUNs6Gsf1ZrfxZtBweGALNJ6zjaEIqEQ7q98MkOCQ51JIop4GhMfLGZ7rrNh05ZPwbIkc2PuW1DVWoRgmy4fYjq4ut4Oou58Yrx2LVg68aVoC80sCeZt99KrydG8u0MaEQVNch55PuW1TN4ULppFPNicdNrYZRhfDEWbpmlWlKtGWjRarfb7uk46URBjD7NZScVGlqWQXgWRbNaAdVbYlBeiq4eZMWNnGxdob0wvCkj7pw)2b7fDnceiCIzt1yd41GtaTD7G9I6yFr4Aeiq4eZMQXoWRbNaAl4rro6YgbceoXSjCSd84ydBs8huIZ7AiHq61UTGCwqG(PVSYEy4tCED44jU)GByK0tHBaq8m8evPGRBpXDl7POnb8usrzpaiEQBYtcqsil9u3s62pN5zayEUd8gaeppOrH8e7LEgQNCko1Z16jUVME9OOZdo4Hzrj48Eu05bD(CQvGOIGDkfCD3lSZQbdgbijKLngHnLrXfm8c5eiCQDkfCD31TKU9ZzRkFfY3H(dqVgJWMYO2dBTED44PLC0TNwoKl8eDhSxKvEg879u4ipdprvk462tC3YEkAtapLuu2daIN6M8KaKeYsp1TKU9ZzEgaMNOursQNIrLnywdbYZ58usbBzZtBgaFPNHNqIb4Paup13Z16PgsiKEnVEu05bh8WSOeCEpk68GoFo1kqurWoLcUU7f2z1GbJaKeYYgJWMYO4cgEHCceo1oLcUU76ws3(5SvAWjG2yHCr)2b7f1iqGWj2kn4eqBhvKK2vQSbZAiqnceiCITQ8pN9IaTJkss7kv2GzneOMa0vhuIZ7AiHq61UTGCwqG(PVScxWwRxhoEUodyUTNH65AH3trJUFb1tlJALN2aEpfn62tlJ6P4Fb9gg55PuW1T486rrNhCWdZIsW59OOZd685uRarfbdBaZTTAWGv(kKVd9hGEngHnLrXfmCS1wDQOU(D2q4cgoRkFfY3H(dqp7HHpVoC80so62tlJ6zWV3tSbm32Zq9CTW7zajgWPEswAuu(spxRNAiHq65P4Fb9gg55PuW1T486rrNhCWdZIsW59OOZd685uRarfbdBaZTTAWGDqjoVRHecPx72cYzbb6N(YkyRDv5Rq(o0Fa6zpS161HJNwIJ8m8ery4ms6POnb8usrzpaiEQBYtcqsil9u3s62pN51JIop4GhMfLGZ7rrNh05ZPwbIkcgIWWzwnyWiajHSSXiSPmkUGHxiNaHtTtPGR7UUL0TFoZRdhpXn8IOt9eQCE5Ol9CaEgCUNpMN6M8e)TM4g8eHkHWrEoQNLq4OZZWZ1v4UL96rrNhCWdZIqwca11xkjGA1GbJaKeYYgJWMYO2ddhBapbijKLnjbHaE9OOZdo4HzrilbG6qf4h51JIop4GhMf8bYwVUnBbgKkcOEDVoC8SwHHZi551JIop4AicdNb72cYzbb6N(YkRgmyhuIZ7AiHq6zpSA86rrNhCneHHZGhMfq4)xHWdg51JIop4AicdNbpmlqIYItdeVUxhoEI7)ZzViW51JIop4Af2bd6RZdSAWGHiGH1q4)Z4cN2KuuuBTfradRDlRqE(1FSoJcD3eGUs8icyyTBhSxuhHhm6AcqT12Y)C2lc0UDWErDeEWORjPQyahUGHJDeNxhoEUobNpaiEIeLfEQVNmcle4QNJsvEkCbeYU5PL4ipfn62t0Lvip)88X80YuO7Mxpk68GRvyh8WSq4O(OuLvGOIGHxiNaHt9bOe4gDzhYajW75A)VYW5HoaiDjff9LwnyWqeWWA3YkKNF9hRZOq3nbO2ARovux)oBiCvJD86rrNhCTc7GhMfch1hLQoRgmyicyyTBzfYZV(J1zuO7MauVEu05bxRWo4Hzbc)FwhtqU0QbdgIagw7wwH88R)yDgf6Uja1RhfDEW1kSdEywGqYJKlgaeRgmyicyyTBzfYZV(J1zuO7MauVEu05bxRWo4Hzb2ije()mRgmyicyyTBzfYZV(J1zuO7MauVEu05bxRWo4Hzrak0PYG3lbNB1GbdradRDlRqE(1FSoJcD3eG61HJNwIJ80YbOqE(yyRhsH5jcH9sYtDtEInYt9eDliNfeWtu9LvEIj)kpf7LGG9Ew(k68CanVEu05bxRWo4HzXTd2lQZcqHSs4O(JH1HuyWWXQbdgCreWWA3oyVOolafQjaDfIagw72cYzbb66lbb7BcqxHiGH1UTGCwqGU(sqW(MKQIbC4cg(A2WRdhpfVLaWP78m4skyl9uaQNiujeoYtrKN6)l8eDhSxKNRZxeoX5PWrEIUSc55NNpg26HuyEIqyVK8u3KNyJ8upr3cYzbb8evFzLNyYVYtXEjiyVNLVIophqZRhfDEW1kSdEywClRqE(1FSoJcDBLWr9hdRdPWGHJvdgmebmS2TfKZcc01xcc23eGUcradRDBb5SGaD9LGG9njvfd4Wfm81SHxhoEAjoYt0Lvip)88bEw(NZErapfFGPK0tSrEQNwpq2kcpyK48uaWP78ue5zijpH8daIN67j0hQNI9sqWEpdaZt27j4vp3bEKNO7G9I8CD(IW186rrNhCTc7GhMf3YkKNF9hRZOq3wnyWyV2adKTIWdg10PSyaqwjE4QbNaA72cYzbb66lbb7Beiq4eZwB1GtaTD7G9I6yFr4Aeiq4eZwBpOeN31qcH0RDBb5SGa9tFzfUWNT2c3Y)C2lc0UTGCwqGU(sqW(MauX51HJNRBmpdg78mKKNcqTYZdmqjp1n55dipfn62t(lIo1tXeZYnpTeh5POnb8KTCaq8eloLKEQ7a4jUVMEYiSPmQNV0tWREEkfCDtmpfn6(fupdWspX91S51JIop4Af2bpmlQc5cI1XEzNrHUTAWGjJH1j8iG2cg7AcqxjEnKqiTPtf11VZgcxLVc57q)bOxJrytzuBTfUNsbx3eRfC(QYxH8DO)a0RXiSPmQ9Wkq7vHL2pOeGjoVoC8CDJ5j49mySZtrdN7jBipfn6EaEQBYtazPQN4ZoNvEkCKN4wyw2Zh4jYFNNIgD)cQNbyPN4(A6zayEcEppLcUUBE9OOZdUwHDWdZIQqUGyDSx2zuOBRgmyYyyDcpcOTGXU2aShF2z9YyyDcpcOTGXUgtqg68GvW9uk46MyTGZxv(kKVd9hGEngHnLrThwbAVkS0(bLamVEu05bxRWo4HzXTd2lQJWdgDwnyWkFfY3H(dqVgJWMYO2dRg4pLcUUjwl4CVoC8e)PEIp49u0O7xq9eDhSxKNRZxeopfoYtXEjiyVNIgD7j6BzpdaZtlhGc5PKc2YMNwsYtrdN7j0hQN6(pYtec7LKN6M8eBKN65PVSYZYxrNNdO51JIop4Af2bpmlUTGCwqGU(sqWERgmyhuIZ7AiHq6zpm8TcUAWjG2UDWErDSViCnceiCITI9Admq2kcpyutNYIbazfCpLcUUjwl48vL)5SxeODlRqE(1FSoJcD3eGUQ8pN9IaTBhSxuNfGc1k7qcHo7HHJxhoEI)upXh8EkA0TNO7G9I8CD(IW5PWrEk2lbb79u0OBprFl7zWLuWw6Pa0Mxpk68GRvyh8WS42cYzbb66lbb7TAWGDqjoVRHecPN9WW3kn4eqB3oyVOo2xeUgbceoXwXETbgiBfHhmQPtzXaGScradRDlRqE(1FSoJcD3eG61JIop4Af2bpmlUDWErDwakKvdgm4IiGH1UDWErDwakuta6kDQOU(D2q4cMnGxdob02jGOKetac1iqGWj2k4kJH1j8iG2cg7Acq96ED4456mG52K886WXtCt4nxHKHsEUhiB6upHkNxo6spd1ZAG3tnKqi98u0OBpr3b7f5568fHZtXBd49u0OBprPIKupfJkBWSgcKNdWZGXgDEG48mampTEGSvCZNN42eacfGc5Pa0Mxpk68GRHnG52Wi8MRqYqjRgmyAWjG2UDWErDSViCnceiCITcradRbgiB964raiuakuta6QdkX5DnKqi9A3wqoliq)0xwzpSAGhF2KgCcOTJkss7kv2GzneOgbceoX86WXtCJeb1tbOEA9azRi8GrEoyEoQNZ5zG8cQN67Pua45lOnpT87j4vpfoYtRR1tMGCaq80YbOqw55G5PgCcOeZZbOVNwoKl8eDhSxuZRhfDEW1WgWCB4HzbyGSveEWiRgmyIhUAWjG2yHCr)2b7f1iqGWjMT2cxebmS2Td2lQZcqHAcqf3knKqiTPtf11VZgA9sQkgWzVDTssvXaoCPtzrxNkYMQXRdhpXTe46WEvhaepFb9gg5PLdqH88bEQHecPNN6oupfnCUN8bpYtSx6PUjpzcYqNh45J5P1dKTIWdgzLNscts32tMGCaq8eAayu1uAEIBjW1H9QNX5j)bq8mopRbEp1qcH0Zt27j4vp3bEKNwpq2kcpyKNcq9u0OBpXpckFkHoaiEIUd2l68u8caoDNNlFbp3bEKNwpq2kU5ZtCBcaHcqH8u)xCnVEu05bxdBaZTHhMfGbYwr4bJSQSSWPUgsiKEWWXQbdgCXlKtGWPMWrDOY5LJUSlFn05bRoOeN31qcH0RDBb5SGa9tFzL9WQzL4d8pjhLAGbYwVoEeacfGc1iqGWjMT2c3a)tYrPMKGYNsOdas)2b7fDnceiCIzRThuIZ7AiHq61UTGCwqG(PVSA9rrh8Oo71gyGSveEWi7HvJ4wbxebmS2Td2lQZcqHAcqxPHecPnDQOU(D2q2dt82aEXxJnv(kKVd9hGEItCRKeMKUDGWjVoC8e)imjDBpTEGSveEWipPqYx65G55OEkA4Cpjlf6ijpzcYbaXt0Lvip)AEA53tDhQNscts32ZbZt03YEcH0ZtjfSLEoap1n5jGSu1tBCnVEu05bxdBaZTHhMfGbYwr4bJSAWGjPQyahUk)ZzViq7wwH88R)yDgf6UjPQyah84yNvL)5SxeODlRqE(1FSoJcD3KuvmGdxWSXknKqiTPtf11VZgA9sQkgWzF5Fo7fbA3YkKNF9hRZOq3njvfd4G3gED44jkvKK6PyuzdM1qG8KjihaeprxwH88R5PLC0TNwoKl8eDhSxKNpGV0tMGCaq8eDhSxKNwoafYtXla0H7PUL0TFoZZb4jGSu1t(aiX186rrNhCnSbm3gEywCursAxPYgmRHaz1GbdradRDlRqE(1FSoJcD3eGUs8Wvdob0glKl63oyVOgbceoXS1webmS2Td2lQZcqHAcqfNxhoEAjhD7jbEbiBp1qcH0ZZGlkwEEkCKNOurmQ45d8e3TCZRhfDEW1WgWCB4HzXrfjPDLkBWSgcKvdgSdkX5DnKqi9A3wqoliq)0xwzpSAGxdob0glKl63oyVOgbceoXGxdob0gyGS1td(cs2iqGWjMxpk68GRHnG52WdZccV5kKmuYR71HJNOkfCD7jU)pN9IaNxhoEUUM4qjPN42HCceo51JIop4ANsbx39c7GHxiNaHtwbIkc2TzDDlPB)CMv4fCbcw5Fo7fbA3oyVOolafQv2HecDDmzu05bb3Ey40S72WRdhpXTdWCBpfaC6opfrEgsYZa5fup13Zsa1Zh4PLdqH8SSdje6AEAZa4l9u0MaEUodG5PLKIfa6opNZZa5fup13tPaWZxqBE9OOZdU2PuW1DVWo4HzbEbyUTvdgm4IxiNaHtTBZ66ws3(5SvmcradRHnawxefla0Dnjvfd4WfoRkFfY3H(dqVgJWMYO2JJxhoEUM)Z9e7LEIUd2lQI4mpH3t0DWErNkNfKNcaoDNNIipdj5zG8cQN67zjG65d80YbOqEw2HecDnpTza8LEkAtapxNbW80ssXcaDNNZ5zG8cQN67Pua45lOnVEu05bx7uk46Uxyh8WSa6)8UKUxqwiRWEzhqwQcdhRilvLrpQEbGcBT2XRhfDEW1oLcUU7f2bpmlUDWErveNz1GbJaKeYs7HTw7SIaKeYYgJWMYO2ddh7ScU4fYjq4u72SUUL0TFoBfJqeWWAydG1frXcaDxtsvXaoCHZQYxH8DO)a0RXiSPmQ9441HJNwYr3EA5qUWt0DWErE(a(spTCakKNI2eWtRhiBfHhmYtrdN75PXspfG280sCKNmb5aG4j6YkKNFE(spdKhpYtDlPB)CwZtBgaFPNie2ljpXgWCBsEEoyEkI8Ch4rEgvq9udob0ZZaW8eQCE5Ol9u(AOZdAE9OOZdU2PuW1DVWo4HzXTd2lQZcqHSAWGjE4QbNaAJfYf9BhSxuJabcNy2Al71gyGSveEWOMKQIbC2dZgWRbNaA7equsIjaHAeiq4etCRepC1GtaTbgiB90GVGKnceiCITcUAWjG2yHCr)2b7f1iqGWjMT2cx8c5eiCQjCuhQCE5Ol7YxdDEGT2w(kKVd9hGEngHnLrXfmCGVgBkW)KCuQPBQJnYt7SauOgbceoXe3kXJxiNaHtTBZ66ws3(5mBTfradRDlRqE(1FSoJcD3KuvmGZEy40QXwBpOeN31qcH0RDBb5SGa9tFzL9Ww7QY)C2lc0ULvip)6pwNrHUBsQkgWzpo2rCE9OOZdU2PuW1DVWo4HzXTd2lQZcqHSAWGPtf11VZgcxL)5SxeODlRqE(1FSoJcD3KuvmGBfCLXW6eEeqBbJDnbOEDVoC8evPGRBI5j(9AOZd86WXZ1nMNNsbx3EoNNcqTYtrKNsk48LEkkaQN67PWrEIUd2l6u5SG8uFpriaHn65jM8R8u3KNqJ7g8iprEGWzLNeEeWZbZtrKNHK8mupRcl1ZcupfpM8R8u3KNqLu5Rqc1tClmllUMxpk68GRDkfCDtmy3oyVOtLZcYQbdgIagw7uk46Uja1RdhpxNbm32Zq9CTW7jUVMEkA09lOEAzuR80gW7POr3EAzuR8mampTlpfn62tlJ6zGPK0tC7am32Zx6PyBYZ1zKN6PLdqH8mampbVNwoKl8eDhSxKNW7j49evarjjMaeYRhfDEW1oLcUUjg8WSOeCEpk68GoFo1kqurWWgWCBRgmyLVc57q)bOxJrytzuCbdN1lEn4eqBmIGsY(PYqdiuvJabcNyRepIagwdVam3Uja1wBd8pjhLA6M6yJ80olafQrGaHtSvWvdob0glKl63oyVOgbceoXwbxn4eqBNaIssmbiuJabcNyItCED44j(t9Sgp1qcH0ZtrJU9eLkss9umQSbZAiqEUGiOEka1Z1zampTKuSaq35jYsplll8baXt0DWErNkNfuZRhfDEW1oLcUUjg8WS42b7fDQCwqwvww4uxdjespy4y1Gbtdob02rfjPDLkBWSgcuJabcNyR0GtaTHnawxefla0DnceiCITIricyynSbW6IOybGURjPQyahUWz1bL48UgsiKETBliNfeOF6lRGvZknKqiTPtf11VZgA9sQkgWzVD51HJNwYr3VG6PLjckj9evLHgqOkpdaZt85j(fGfNNpMN1Ydg55a8u3KNO7G9Ioph1Z58u0l1TNc3aG4j6oyVOtLZcYZh4j(8udjesVMxpk68GRDkfCDtm4HzXTd2l6u5SGSAWGbxn4eqBmIGsY(PYqdiuvJabcNyRc8pjhLAi8Gr9b01n1VDWErxtgGfWW3QdkX5DnKqi9A3wqoliq)0xwbdFE9OOZdU2PuW1nXGhMf3wqoliq)0xwz1Gb7GsCExdjesp7HHpVEu05bx7uk46MyWdZIBhSx0PYzbzqpOuXyDn2fog1Ogda]] )


end
