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


    spec:RegisterPack( "Subtlety", 20190401.1444, [[daLarbqiIk9iLuTjLOpjrvYOGI6uquTkbjEfezwevDlOiTlj9lbLHjqCmOultjLNbL00eK6AcK2Mev13eKuJdkH6CevuRtqsMheL7bs7tq1)eqk5GqjQfkr5HevyIcOUOasXgLOsFekIQrkGuQtkrvSsLWlHsintOeIBcfr2PG4NqrugkuewkuI8uinvb4QcizRcivFLOICwjQs1Ef6Vs1GfDyQwmOESuMmQUmYMHQpdHrRuNwXQLOkLxlrMnHBlHDd8BvnCqCCOeSCuEUktN01jY2HcFNOmEbeNxjz9suX8fO2pLJyhdiIYDLIHSwqWwohKqheSRyh6qhASIfhr1vqOikeVvYrqruGxqruujyvq6QikeFL4DEmGi69sSgfr3Qc5cvHfgIr3sW12xe2nfscxNh0yoUg2nfTWIOWsJqlpGiCeL7kfdzTGGTCoiHoiyxXo0Ho0yf7iQlP7NfrrNc5iIUhoNar4ikNUweDDlrLGvbPRSel9iKiBX6wUvfYfQclmeJULGRTViSBkKeUopOXCCnSBkAHzlw3sSme2iSeB5TCTGGTC2sm1YGiNdvbroBlSfRBPCSDac6cv2I1TetTelZ5e3sSOtRKL6BjNWDjHAP305bwkMtR2I1TetTelrfpge3s1ziiTp4w2EaF05bw(alXKCwjIBj(ZSmWKR7QTyDlXulXYCoXTmqDKLLhLkUAevmNEXaIONsUq3epgqmeSJberjGdliESSiAJnkXgpIIzlvxqaTIpaExg5La0Dvc4WcIBzWbB5bHeIU6meKE1BlXMseOF6ZkSezwIvlrULlTeZwclHJxpLCHURsqSm4GTewchVIHdMBxLGyjYJOEtNherVTZFzNYMsuuJHSwmGikbCybXJLfrBSrj24r02xa)Di)a0RYj8PnQLidQLyBjMAjMTuDbb0kNiieRFkZvhbvujGdliULlTeZwclHJxXWbZTRsqSm4GT0lhInkv1n1Xh2PDUdAuLaoSG4wU0s5AP6ccOvUZk1VTZFzvc4WcIB5slLRLQliGwpjyLy4siOkbCybXTe5wI8iQ305br0MleDVPZd6I50iQyoTd8ckIIpG52rngcwJberjGdliESSiAJnkXgpI6LdXgLQqig(ZCLQmhuYYWHA5AwU0YdcjeD1zii9Q3wInLiq)0NvyjYGA5AruVPZdIOie)xalCof1yiHogqeLaoSG4XYIOEtNherVTZFzNYMsueTXgLyJhrvxqaTEuJrAxP2gmybjQsahwqClxAP6ccOv8bW7YiVeGURsahwqClxAjNGLWXR4dG3LrEjaDxLrf(aolrMLyB5slpiKq0vNHG0REBj2uIa9tFwHLqTCnlxAPofux)oFilXulzuHpGZYWTS8JOTvnb1vNHG0lgc2rngsqJberjGdliESSiAJnkXgpIkxlvxqaTYjccX6NYC1rqfvc4WcIB5sl9YHyJsvyHZP(a66M6325VSRYCqjlHAjwTCPLhesi6QZqq6vVTeBkrG(PpRWsOwI1iQ305br0B78x2PSPef1yiLFmGikbCybXJLfrBSrj24rumC24WcQkDuhcBE2OR6SxDDEGLlTeZwQUGaAfFa8UmYlbO7QeWHfe3YLwYjyjC8k(a4DzKxcq3vzuHpGZsKzj2wgCWwQUGaAvg5qEqHFkXQeWHfe3YLwEqiHORodbPx92sSPeb6N(SclrguldTLbhSLE5qSrP6aimg1HhXORQeWHfe3YLwclHJxVvfWV46pENtUURsqSCPLhesi6QZqq6vVTeBkrG(PpRWsKb1sSAjsw6LdXgLQWcNt9b01n1VTZFzxLaoSG4wI8iQ305br0B78x2PSPef1yiH6yaruc4WcIhllI2yJsSXJOhesi6QZqq6zz4qTeRruVPZdIO3wInLiq)0Nve1yiyXXaIOEtNherVTZFzNYMsueLaoSG4XYIAuJOCc3LeAmGyiyhdiI6nDEqe9uYf6oIsahwq8yzrngYAXaIOEtNherlnTsruc4WcIhllQXqWAmGikbCybXJLfr9MopiI2CHO7nDEqxmNgrfZPDGxqr0g)IAmKqhdiIsahwq8yzr0gBuInEe9uYf6M4vxiIOEtNherzsGU305bDXCAevmN2bEbfrpLCHUjEuJHe0yaruc4WcIhllI2yJsSXJOQZqqAvNcQRFNpKLHBz5B5slzuHpGZsKzjIgVw4bILlTS9fWFhYpa9SmCOwgAlXulXSL6uqwImlXoiwICldflxlI6nDEqefmi2kSW5uuJHu(XaIOeWHfepwwefdxirruiS5zJUQZE115bwU0YdcjeD1zii9Q3wInLiq)0Nvyz4qTCTiQ305brumC24WckIIHZ6aVGIOsh1HWMNn6Qo7vxNhe1yiH6yaruc4WcIhllI2yJsSXJOy4SXHfuv6Ooe28Srx1zV668GiQ305br0MleDVPZd6I50iQyoTd8ckIEk5cD3B8lQXqWIJberjGdliESSikgUqIIORfulrYs1feqRymiEwLaoSG4wgkwI1GAjswQUGaATWpLy9hVFBN)YUkbCybXTmuSCTGAjswQUGaA92o)L1X)M0vjGdliULHILRfelrYs1feqRUWBSrxvjGdliULHILyhelrYsSdQLHILy2YdcjeD1zii9Q3wInLiq)0Nvyz4qTeRwI8iQ305brumC24WckIIHZ6aVGIONsUq3DDZOB)cEuJHiNJberjGdliESSiAJnkXgpIsaIHyvLt4tBulrgulXWzJdlO6PKl0Dx3m62VGhr9MopiI2CHO7nDEqxmNgrfZPDGxqr0tjxO7EJFrngc2bjgqeLaoSG4XYIOn2OeB8iA7lG)oKFa6v5e(0g1sKb1sSTm4GTuNcQRFNpKLidQLyB5slBFb83H8dqpldhQLynI6nDEqeT5cr3B68GUyonIkMt7aVGIO4dyUDuJHGn2XaIOeWHfepwweTXgLyJhrpiKq0vNHG0REBj2uIa9tFwHLqTm0wU0Y2xa)Di)a0ZYWHAzOJOEtNherBUq09MopOlMtJOI50oWlOik(aMBh1yiyVwmGikbCybXJLfrBSrj24rucqmeRQCcFAJAjYGAjgoBCybvpLCHU76Mr3(f8iQ305br0MleDVPZd6I50iQyoTd8ckIclncEuJHGnwJberjGdliESSiAJnkXgpIsaIHyvLt4tBuldhQLyhulrYscqmeRQmcbbIOEtNherDwZbuxFgJaAuJHGDOJber9MopiI6SMdOoejXrruc4WcIhllQXqWoOXaIOEtNherfdITE9YBsCefeqJOeWHfepwwuJAefcJAFbSRXaIHGDmGikbCybXJLf1yiRfdiIsahwq8yzrngcwJberjGdliESSOgdj0XaIOeWHfepwwuJHe0yaruVPZdIONsUq3ruc4WcIhllQXqk)yaruc4WcIhllI6nDEqeTWzLiEh)zDo56oIcHrTVa21(rThWVik2bnQXqc1XaIOeWHfepwwe1B68Gi6TD(lRdlCoDruimQ9fWU2pQ9a(frXoQXqWIJber9MopiIc515bruc4WcIhllQrnIIpG52XaIHGDmGikbCybXJLfrBSrj24ru1feqR325VSo(3KUkbCybXTCPLWs44vWGyRxhdcGGCqJQsqSCPLhesi6QZqq6vVTeBkrG(PpRWYWHA5AwIKLy1YqXs1feqRh1yK2vQTbdwqIQeWHfepI6nDEqeLWyUgXCLIAmK1IberjGdliESSiAJnkXgpIIzlLRLQliGw5oRu)2o)LvjGdliULbhSLY1syjC86TD(lRZDqJQsqSe5wU0s1ziiTQtb11VZhYsm1sgv4d4SmCllFlxAjJk8bCwIml1PvQRtbzzOy5AruVPZdIOGbXwHfoNIAmeSgdiIsahwq8yzruVPZdIOGbXwHfoNIOn2OeB8iQCTedNnoSGQsh1HWMNn6Qo7vxNhy5slpiKq0vNHG0REBj2uIa9tFwHLHd1Y1SCPLy2sVCi2Oufmi261XGaiih0OkbCybXTm4GTuUw6LdXgLQmcIyAUoae9B78x2vjGdliULbhSLhesi6QZqq6vVTeBkrG(PpRWsm1sVPdguN)Afmi2kSW5KLHd1Y1Se5wU0s5AjSeoE92o)L15oOrvjiwU0sDkOU(D(qwgoulXSLb1sKSeZwUMLHILTVa(7q(bONLi3sKB5slzeoJUTdlOiABvtqD1zii9IHGDuJHe6yaruc4WcIhllI2yJsSXJOmQWhWzjYSS9VG)Ya1Bvb8lU(J35KR7kJk8bCwIKLyhelxAz7Fb)LbQ3Qc4xC9hVZjx3vgv4d4SezqTmOwU0s1ziiTQtb11VZhYsm1sgv4d4SmClB)l4Vmq9wva)IR)4Do56UYOcFaNLizzqJOEtNherbdITclCof1yibngqeLaoSG4XYIOn2OeB8ikSeoE9wva)IR)4Do56UkbXYLwIzlLRLQliGw5oRu)2o)LvjGdliULbhSLWs441B78xwN7GgvLGyjYJOEtNherpQXiTRuBdgSGef1yiLFmGikbCybXJLfrBSrj24r0dcjeD1zii9Q3wInLiq)0Nvyz4qTCnlrYs1feqRCNvQFBN)YQeWHfe3sKSuDbb0kyqS1tDrjIvjGdliEe1B68Gi6rngPDLABWGfKOOgdjuhdiI6nDEqeLWyUgXCLIOeWHfepwwuJAeTXVyaXqWogqeLaoSG4XYIOn2OeB8ikSeoEfw8pxiDALrEtTm4GTewchVERkGFX1F8oNCDxLGy5slXSLWs441B78xwhw4C6QsqSm4GTS9VG)Ya1B78xwhw4C6QmQWhWzjYGAj2bXsKhr9MopiIc515brngYAXaIOeWHfepwwe1B68GikgoBCyb1hGsGB0vDedchJxO9)AJq46aq0zK30NfrBSrj24ruyjC86TQa(fx)X7CY1DvcILbhSL6uqD978HSezwUwqIOaVGIOy4SXHfuFakbUrx1rmiCmEH2)RncHRdarNrEtFwuJHG1yaruc4WcIhllI2yJsSXJOWs441Bvb8lU(J35KR7QeKiQ305bruPJ6JsfxuJHe6yaruc4WcIhllI2yJsSXJOWs441Bvb8lU(J35KR7QeKiQ305bruyX)8oUeBvuJHe0yaruc4WcIhllI2yJsSXJOWs441Bvb8lU(J35KR7QeKiQ305bruyIDeR0aqe1yiLFmGikbCybXJLfrBSrj24ruyjC86TQa(fx)X7CY1Dvcse1B68Gik(WiyX)8OgdjuhdiIsahwq8yzr0gBuInEefwchVERkGFX1F8oNCDxLGer9MopiI6GgDkZf9MlerngcwCmGikbCybXJLfrBSrj24ru5AjSeoE92o)L15oOrvjiwU0syjC86TLytjc01NbC(xLGy5slHLWXR3wInLiqxFgW5FLrf(aolrgulXAnOruVPZdIO325VSo3bnkIkDu)XX7iA8ik2rngICogqeLaoSG4XYIOn2OeB8ikSeoE92sSPeb66Zao)RsqSCPLWs441BlXMseORpd48VYOcFaNLidQLyTg0iQ305br0Bvb8lU(J35KR7iQ0r9hhVJOXJOyh1yiyhKyaruc4WcIhllI2yJsSXJO8xRGbXwHfoNQ60knaewU0smBPCTuDbb06TLytjc01NbC(xjGdliULbhSLQliGwVTZFzD8VjDvc4WcIBzWbB5bHeIU6meKE1BlXMseOF6ZkSezwIvldoylLRLT)f8xgOEBj2uIaD9zaN)vjiwI8iQ305br0Bvb8lU(J35KR7OgdbBSJberjGdliESSiAJnkXgpIY8H3jmiGwDo)QsqSCPLy2s1ziiTQtb11VZhYsKzz7lG)oKFa6v5e(0g1YGd2s5A5PKl0nXRUqy5slBFb83H8dqVkNWN2OwgoulBq6fEG0pieGBjYJOEtNherlCwjI3XFwNtUUJAmeSxlgqeLaoSG4XYIOn2OeB8ikZhENWGaA158Roald3sSgelXulz(W7egeqRoNFvUeZ15bwU0s5A5PKl0nXRUqy5slBFb83H8dqVkNWN2OwgoulBq6fEG0pieGhr9MopiIw4SseVJ)SoNCDh1yiyJ1yaruc4WcIhllI2yJsSXJOTVa(7q(bOxLt4tBuldhQLRzjswEk5cDt8QleruVPZdIO325VSoSW50f1yiyh6yaruc4WcIhllI2yJsSXJOhesi6QZqq6zz4qTeRwU0s5AP6ccO1B78xwh)BsxLaoSG4wU0s(RvWGyRWcNtvDALgaclxAPCT8uYf6M4vxiSCPLT)f8xgOERkGFX1F8oNCDxLGy5slB)l4Vmq92o)L15oOr122ziOZYWHAj2ruVPZdIO3wInLiqxFgW5FuJHGDqJberjGdliESSiAJnkXgpIEqiHORodbPNLHd1sSA5slvxqaTEBN)Y64Ft6QeWHfe3YLwYFTcgeBfw4CQQtR0aqy5slHLWXR3Qc4xC9hVZjx3vjiruVPZdIO3wInLiqxFgW5FuJHGD5hdiIsahwq8yzr0gBuInEevUwclHJxVTZFzDUdAuvcILlTuNcQRFNpKLidQLb1sKSuDbb06jbRedxcbvjGdliULlTuUwY8H3jmiGwDo)QsqIOEtNherVTZFzDUdAuuJAe9uYf6U34xmGyiyhdiIsahwq8yzrumCHefrB)l4Vmq92o)L15oOr122ziORJZ8MopWfwgoulXUgQdAe1B68GikgoBCybfrXWzDGxqr0BZ76Mr3(f8OgdzTyaruc4WcIhllI2yJsSXJOY1smC24WcQEBEx3m62VGB5slBFb83H8dqVkNWN2OwgULyB5sl5eSeoEfFa8UmYlbO7QmQWhWzjYSe7iQ305brumCWC7OgdbRXaIOeWHfepwwe1B68GikK)fDgDVeRrrukquM39IxcOr0qhKik(Z6akq0yiyh1yiHogqeLaoSG4XYIOn2OeB8ikbigIvwgouldDqSCPLeGyiwv5e(0g1YWHAj2bXYLwkxlXWzJdlO6T5DDZOB)cULlTS9fWFhYpa9QCcFAJAz4wITLlTKtWs44v8bW7YiVeGURYOcFaNLiZsSJOEtNherVTZFzfKGh1yibngqeLaoSG4XYIOy4cjkI2(c4Vd5hGEvoHpTrTmCOwg6iQ305brumC24WckIIHZ6aVGIO3M3BFb83H8dqVOgdP8JberjGdliESSiQ305brumC24WckIIHlKOiA7lG)oKFa6v5e(0g1sKb1sSTejlxZYqXsVCi2Ouv3uhFyN25oOrvc4WcIhrBSrj24rumC24WcQkDuhcBE2OR6SxDDEGLlTeZwQUGaAfmi26PUOeXQeWHfe3YGd2s1feqRCNvQFBN)YQeWHfe3sKhrXWzDGxqr0BZ7TVa(7q(bOxuJHeQJberjGdliESSiAJnkXgpIIHZghwq1BZ7TVa(7q(bONLlTeZwkxlvxqaTYDwP(TD(lRsahwqCldoyl5VwbdITclCovzuHpGZYWHAzqTejlvxqaTEsWkXWLqqvc4WcIBjYTCPLy2smC24WcQEBEx3m62VGBzWbBjSeoE9wva)IR)4Do56UYOcFaNLHd1sSRRzzWbB5bHeIU6meKE1BlXMseOF6ZkSmCOwgAlxAz7Fb)LbQ3Qc4xC9hVZjx3vgv4d4SmClXoiwI8iQ305br0B78xwN7Ggf1yiyXXaIOeWHfepwweTXgLyJhrXWzJdlO6T592xa)Di)a0ZYLwQtb11VZhYsKzz7Fb)LbQ3Qc4xC9hVZjx3vgv4d4SCPLY1sMp8oHbb0QZ5xvcse1B68Gi6TD(lRZDqJIAuJOWsJGhdigc2XaIOeWHfepwweTXgLyJhrpiKq0vNHG0ZYWHA5AwIKLy2s1feqRie)xalCovjGdliULlT0lhInkvHqm8N5kvzoOKLHd1Y1Se5ruVPZdIO3wInLiq)0Nve1yiRfdiI6nDEqefH4)cyHZPikbCybXJLf1yiyngqe1B68GikS3kDQdhrjGdliESSOg1OgrXGy38GyiRfeSLZbbRyhKAqWoibnIkZzGbG4IOLNciptjULHAl9MopWsXC6vTfr0dc1IHSw5JDefc7Xhbfrx3sujyvq6klXspcjYwSULBvHCHQWcdXOBj4A7lc7McjHRZdAmhxd7MIwy2I1TeldHnclXwElxliylNTetTmiY5qvqKZ2cBX6wkhBhGGUqLTyDlXulXYCoXTel60kzP(wYjCxsOw6nDEGLI50QTyDlXulXsuXJbXTuDgcs7dULThWhDEGLpWsmjNvI4wI)mldm56UAlw3sm1sSmNtClduhzz5rPIRAlSfRBzGMaHAskXTeMWFgzz7lGD1sycXaUQLy5wJGONLGhGPBNvGljS0B68GZYhiwvTfEtNhCvimQ9fWUcfx4xjBH305bxfcJAFbSRibnmxcrbbuxNhyl8Mop4Qqyu7lGDfjOHH)p3wSULOahYTF1sMpClHLWXjULN66zjmH)mYY2xa7QLWeIbCw6aULqyeMc5vDaiSCol5pGQ2cVPZdUkeg1(cyxrcAyhWHC7x7N66zl8Mop4Qqyu7lGDfjOHDk5cDBl8Mop4Qqyu7lGDfjOHv4SseVJ)SoNCDlpeg1(cyx7h1Ea)GIDqTfEtNhCvimQ9fWUIe0WUTZFzDyHZPtEimQ9fWU2pQ9a(bfBBH305bxfcJAFbSRibnmiVopWwylw3Yanbc1KuIBjHbXwzPofKL6MS0B6ZSColDm8r4WcQAlw3sSeDk5cDB5GBjK)UbwqwIzWBjgscaXCybzjbOIHolhGLTVa2vKBl8Mop4GEk5cDBl8Mop4qcAyLMwjBX6wkhBQvYs5iWNLUAj(Wo1w4nDEWHe0WAUq09MopOlMtLh4fe0g)SfRBjwscyjUKqSYYt2OTnDwQVL6MSevjxOBIBjw6vxNhyjMHxzj)haclVxElh1s8N1OZsi)lgaclhClbVUhaclNZshdFeoSGqE1w4nDEWHe0WysGU305bDXCQ8aVGGEk5cDtC5hCONsUq3eV6cHTyDlXYqGiwzzidITclCozPRwUgswkhycl5sSbGWsDtwIpStTe7Gy5rThWp5T0XvIzPUD1YqJKLYbMWYb3YrTKceidJolLn6EawQBYsafiQLyYLJaB5ZSColbVAPeeBH305bhsqddmi2kSW5K8dou1ziiTQtb11VZhk8YFjJk8bCidrJxl8azz7lG)oKFa6fo0qJPywNcczyheKhkRzlw3smzaXklBBhGGSK9QRZdSCWTugz52XGSecBE2OR6SxDDEGLhPw6aULfscDGiilvNHG0ZsjivBH305bhsqdddNnoSGKh4feuPJ6qyZZgDvN9QRZdKhdxirqHWMNn6Qo7vxNhS8GqcrxDgcsV6TLytjc0p9zfHdDnBX6wIjyZZgDLLyPxDDEqGwwIfH0YRZsedgKLULnMdXsh(LuljaXqSYs8NzPUjlpLCHUTuoc8zjMHLgbNywE6iewYOdc1ulhf5vllVlbrElh1YMdSeMSu3UA5nfqeu1w4nDEWHe0WAUq09MopOlMtLh4fe0tjxO7EJFYp4qXWzJdlOQ0rDiS5zJUQZE115b2I1TmqDe3s9TKt4dGSu2MawQVLshz5PKl0TLYrGplFMLWsJGtSZw4nDEWHe0WWWzJdli5bEbb9uYf6URBgD7xWLhdxirqxlOiPUGaAfJbXZQeWHfepuWAqrsDbb0AHFkX6pE)2o)LDvc4WcIhkRfuKuxqaTEBN)Y64Ft6QeWHfepuwliiPUGaA1fEJn6QkbCybXdfSdcsyh0qbZhesi6QZqq6vVTeBkrG(PpRiCOyf52I1TuoEWnCIzP0naew6wIQKl0TLYrGTu2MawYiVThacl1nzjbigIvwQBgD7xWTfEtNhCibnSMleDVPZd6I5u5bEbb9uYf6U34N8doucqmeRQCcFAJImOy4SXHfu9uYf6URBgD7xWTfRBz5oG52w6QLHgjlLn6(LuldmQ8wguKSu2OBldmQLy(L0B4KLNsUq3i3w4nDEWHe0WAUq09MopOlMtLh4feu8bm3w(bhA7lG)oKFa6v5e(0gfzqXo4G1PG6635dHmOyVS9fWFhYpa9chkwTfRBPCA0TLbg1sxCVL4dyUTLUAzOrYshHpGtTKceVPIvwgAlvNHG0Zsm)s6nCYYtjxOBKBl8Mop4qcAynxi6EtNh0fZPYd8cck(aMBl)Gd9GqcrxDgcsV6TLytjc0p9zfqd9Y2xa)Di)a0lCOH2wSULbQJS0TewAeCIzPSnbSKrEBpaewQBYscqmeRSu3m62VGBl8Mop4qcAynxi6EtNh0fZPYd8cckS0i4Yp4qjaXqSQYj8PnkYGIHZghwq1tjxO7UUz0TFb3wSULyrEz0PwcHnpB0vwoalDHWYh3sDtwILXeyrSeMAU0rwoQLnx6OZs3sm5YrGTfEtNhCibnmN1Ca11NXiGk)GdLaedXQkNWN2OHdf7GIebigIvvgHGa2cVPZdoKGgMZAoG6qKehzl8Mop4qcAyIbXwVE5njoIccO2cBX6wwM0i4e7SfEtNhCvyPrWHEBj2uIa9tFwH8do0dcjeD1zii9ch6AiHz1feqRie)xalCovjGdli(sVCi2OufcXWFMRuL5GsHdDnKBl8Mop4QWsJGJe0Wqi(Vaw4CYw4nDEWvHLgbhjOHb7TsN6W2cBX6wkh)l4VmWzl8Mop4Qn(bfYRZdKFWHclHJxHf)ZfsNwzK30GdgwchVERkGFX1F8oNCDxLGSeZWs441B78xwhw4C6Qsqco42)c(lduVTZFzDyHZPRYOcFahYGIDqqUTyDllxxigaclH9wjl13soH7sc1YrPclLohbfQSmqDKLYgDBj6Qc4xCw(4wgyY1D1w4nDEWvB8djOHjDuFuQqEGxqqXWzJdlO(aucCJUQJyq4y8cT)xBecxhaIoJ8M(m5hCOWs441Bvb8lU(J35KR7QeKGdwNcQRFNpeYwli2cVPZdUAJFibnmPJ6JsfN8douyjC86TQa(fx)X7CY1DvcITWB68GR24hsqddw8pVJlXwj)GdfwchVERkGFX1F8oNCDxLGyl8Mop4Qn(He0WGj2rSsdaH8douyjC86TQa(fx)X7CY1DvcITWB68GR24hsqddFyeS4FU8douyjC86TQa(fx)X7CY1DvcITWB68GR24hsqdZbn6uMl6nxiKFWHclHJxVvfWV46pENtUURsqSfRBzG6ildSdAKLpooMIOXTeMWFgzPUjlXh2PwIULytjcyjQ(SclXzFHLb8mGZFlBFbDwoGQTWB68GR24hsqd72o)L15oOrYlDu)XX7iACOyl)GdvUWs441B78xwN7GgvLGSewchVEBj2uIaD9zaN)vjilHLWXR3wInLiqxFgW5FLrf(aoKbfR1GAlw3smhOac6olDbJC(klLGyjm1CPJSugzP(Fjlr3o)Lzz5(nPd5wkDKLORkGFXz5JJJPiAClHj8NrwQBYs8HDQLOBj2uIawIQpRWsC2xyzapd483Y2xqNLdOAl8Mop4Qn(He0WUvfWV46pENtUULx6O(JJ3r04qXw(bhkSeoE92sSPeb66Zao)RsqwclHJxVTeBkrGU(mGZ)kJk8bCidkwRb1wSULbQJSeDvb8lolFGLT)f8xgWsm74kXSeFyNAzidITclCoHClLac6olLrw6mYse)aqyP(wc5Hyzapd483shWTK)wcE1YTJbzj625Vmll3VjDvBH305bxTXpKGg2TQa(fx)X7CY1T8dou(RvWGyRWcNtvDALgaILywUQliGwVTeBkrGU(mGZ)kbCybXdoy1feqR325VSo(3KUkbCybXdo4dcjeD1zii9Q3wInLiq)0NvGmSgCWYT9VG)Ya1BlXMseORpd48Vkbb52I1TS8GBPZ5NLoJSucI8wEGbczPUjlFazPSr3wkEz0PwgqabUAzG6ilLTjGL8vdaHL4(PeZsD7alLdmHLCcFAJA5ZSe8QLNsUq3e3szJUFj1shSYs5atuTfEtNhC1g)qcAyfoReX74pRZjx3Yp4qz(W7egeqRoNFvjilXS6meKw1PG6635dHS2xa)Di)a0RYj8PnAWbl3tjxOBIxDHyz7lG)oKFa6v5e(0gnCOni9cpq6hecWrUTyDllp4wcElDo)Su2iewYhYszJUhGL6MSeqbIAjwdYjVLshzjMeEGT8bwc)3zPSr3VKAPdwzPCGjS0bClbVLNsUq3vBH305bxTXpKGgwHZkr8o(Z6CY1T8douMp8oHbb0QZ5xDaHJ1GGPmF4DcdcOvNZVkxI568GLY9uYf6M4vxiw2(c4Vd5hGEvoHpTrdhAdsVWdK(bHaCBH305bxTXpKGg2TD(lRdlCoDYp4qBFb83H8dqVkNWN2OHdDnKoLCHUjE1fcBX6wILvlXkswkB09lPwIUD(lZYY9BsNLshzzapd483szJUTe9dSLoGBzGDqJSKroFv1s5ezPSriSeYdXsD)hzjmH)mYsDtwIpStT80Nvyz7lOZYbuTfEtNhC1g)qcAy3wInLiqxFgW5V8do0dcjeD1zii9chkwxkx1feqR325VSo(3KUkbCybXxYFTcgeBfw4CQQtR0aqSuUNsUq3eV6cXY2)c(lduVvfWV46pENtUURsqw2(xWFzG6TD(lRZDqJQTTZqqx4qX2wSULyz1sSIKLYgDBj625Vmll3VjDwkDKLb8mGZFlLn62s0pWw6cg58vwkbPAl8Mop4Qn(He0WUTeBkrGU(mGZF5hCOhesi6QZqq6fouSUuDbb06TD(lRJ)nPRsahwq8L8xRGbXwHfoNQ60knaelHLWXR3Qc4xC9hVZjx3vji2cVPZdUAJFibnSB78xwN7Ggj)GdvUWs441B78xwN7GgvLGSuNcQRFNpeYGguKuxqaTEsWkXWLqqvc4WcIVuUmF4DcdcOvNZVQeeBHTyDll3bm3MyNTyDld0GXCnI5kz5EqSPtTecBE2ORS0vlxdjlvNHG0ZszJUTeD78xMLL73KolXCqrYszJUTeLAmsTmaQTbdwqISCaw6C(OZdqULoGBzidITwEDwgOtaeKdAKLsqQ2cVPZdUk(aMBdLWyUgXCLKFWHQUGaA92o)L1X)M0vjGdli(syjC8kyqS1RJbbqqoOrvjilpiKq0vNHG0REBj2uIa9tFwr4qxdjSgkQliGwpQXiTRuBdgSGevjGdliUTyDlXIseelLGyzidITclCoz5GB5OwoNLo8lPwQVLmjGLVKwTmWVLGxTu6ildPml5sSbGWYa7GgjVLdULQliGsClhG(wgyNvYs0TZFzvBH305bxfFaZTrcAyGbXwHfoNKFWHIz5QUGaAL7Ss9B78xwLaoSG4bhSCHLWXR325VSo3bnQkbb5lvNHG0Qofux)oFimLrf(aUWl)LmQWhWHmDAL66uqHYA2I1TetssOd)vDaiS8L0B4KLb2bnYYhyP6meKEwQBxTu2iewkgmilXFML6MSKlXCDEGLpULHmi2kSW5K8wYiCgDBl5sSbGWsioGtftRAjMKKqh(Rw6NLIhGWs)SCnKSuDgcspl5VLGxTC7yqwgYGyRWcNtwkbXszJUTelrqetZ1bGWs0TZFzNLywciO7SC1lz52XGSmKbXwlVold0jacYbnYs9FKxTfEtNhCv8bm3gjOHbgeBfw4Cs(2QMG6QZqq6bfB5hCOYfdNnoSGQsh1HWMNn6Qo7vxNhS8GqcrxDgcsV6TLytjc0p9zfHdDTLy2lhInkvbdITEDmiacYbnQsahwq8GdwUE5qSrPkJGiMMRdar)2o)LDvc4WcIhCWhesi6QZqq6vVTeBkrG(PpRat9MoyqD(RvWGyRWcNtHdDnKVuUWs441B78xwN7GgvLGSuNcQRFNpu4qXCqrcZRfkTVa(7q(bOhYr(sgHZOB7WcYwSULyjcNr32YqgeBfw4CYsYzIvwo4woQLYgHWskqGmmYsUeBaiSeDvb8lUQLb(Tu3UAjJWz0TTCWTe9dSLii9SKroFLLdWsDtwcOarTmOx1w4nDEWvXhWCBKGggyqSvyHZj5hCOmQWhWHS2)c(lduVvfWV46pENtUURmQWhWHe2bzz7Fb)LbQ3Qc4xC9hVZjx3vgv4d4qg0GUuDgcsR6uqD978HWugv4d4cV9VG)Ya1Bvb8lU(J35KR7kJk8bCifuBX6wIsngPwga12GblirwYLydaHLORkGFXvTuon62Ya7SswIUD(lZYhiwzjxInaewIUD(lZYa7GgzjMLa6iSu3m62VGB5aSeqbIAPyaeYR2cVPZdUk(aMBJe0WoQXiTRuBdgSGej)GdfwchVERkGFX1F8oNCDxLGSeZYvDbb0k3zL6325VSkbCybXdoyyjC86TD(lRZDqJQsqqUTyDlLtJUTKaVeITLQZqq6zPlK5RolLoYsuQfa1S8bwkhbUAl8Mop4Q4dyUnsqd7OgJ0UsTnyWcsK8do0dcjeD1zii9Q3wInLiq)0Nveo01qsDbb0k3zL6325VSkbCybXrsDbb0kyqS1tDrjIvjGdliUTWB68GRIpG52ibnmcJ5AeZvYwylw3suLCHUTuo(xWFzGZwSULbAtcieZYaDNnoSGSfEtNhC1tjxO7EJFqXWzJdli5bEbb928UUz0TFbxEmCHebT9VG)Ya1B78xwN7GgvBBNHGUooZB68axeouSRH6GAlw3YaDhm32sjGGUZszKLoJS0HFj1s9TS5qS8bwgyh0ilBBNHGUQLyYaIvwkBtall3bWTuorEjaDNLZzPd)sQL6Bjtcy5lPvBH305bx9uYf6U34hsqdddhm3w(bhQCXWzJdlO6T5DDZOB)c(Y2xa)Di)a0RYj8PnA4yVKtWs44v8bW7YiVeGURYOcFahYW2wSULyI)fwI)mlr3o)LvqcULizj625VStztjYsjGGUZszKLoJS0HFj1s9TS5qS8bwgyh0ilBBNHGUQLyYaIvwkBtall3bWTuorEjaDNLZzPd)sQL6Bjtcy5lPvBH305bx9uYf6U34hsqddY)IoJUxI1i5XFwhqbIcfB5ParzE3lEjGcn0bXw4nDEWvpLCHU7n(He0WUTZFzfKGl)GdLaedXQWHg6GSKaedXQkNWN2OHdf7GSuUy4SXHfu928UUz0TFbFz7lG)oKFa6v5e(0gnCSxYjyjC8k(a4DzKxcq3vzuHpGdzyBlw3s5atyjJWcsdJkiGgQSmWoOrw6QLIxMLYbMWs4vwYjCxsOvBH305bx9uYf6U34hsqdddNnoSGKh4fe0BZ7TVa(7q(bON8y4cjcA7lG)oKFa6v5e(0gnCOH2wSULYbMWsgHfKggvqanuzzGDqJS8bIvwct4pJSeFaZTj2z5GBPmYYTJbzPxaXs1feqplDa3siS5zJUYs2RUopOAl8Mop4QNsUq39g)qcAyy4SXHfK8aVGGEBEV9fWFhYpa9KhdxirqBFb83H8dqVkNWN2Oidk2iTwO4LdXgLQ6M64d70o3bnQsahwqC5hCOy4SXHfuv6Ooe28Srx1zV668GLywDbb0kyqS1tDrjIvjGdliEWbRUGaAL7Ss9B78xwLaoSG4i3wSULYPr3wgyNvYs0TZFzw(aXkldSdAKLY2eWYqgeBfw4CYszJqy5P(klLGuTmqDKLCj2aqyj6Qc4xCw(mlD4hdYsDZOB)cE1w4nDEWvpLCHU7n(He0WUTZFzDUdAK8doumC24WcQEBEV9fWFhYpa9wIz5QUGaAL7Ss9B78xwLaoSG4bhm)1kyqSvyHZPkJk8bCHdnOiPUGaA9KGvIHlHGQeWHfeh5lXmgoBCybvVnVRBgD7xWdoyyjC86TQa(fx)X7CY1DLrf(aUWHIDDTGd(GqcrxDgcsV6TLytjc0p9zfHdn0lB)l4Vmq9wva)IR)4Do56UYOcFax4yheKBlw3YYKyalzuHpGbGWYa7GgDwct4pJSu3KLQZqqQL8HolhClr)aBPShuEPwctwYiNVYYbyPofu1w4nDEWvpLCHU7n(He0WUTZFzDUdAK8doumC24WcQEBEV9fWFhYpa9wQtb11VZhczT)f8xgOERkGFX1F8oNCDxzuHpGBPCz(W7egeqRoNFvji2cBHTyDlrvYf6M4wILE115b2I1TS8GBjQsUq3HHHdMBBPZilLGiVLshzj625VStztjYs9TeMae(OwIZ(cl1nzje)UbdYs4hiDw6aULL7a4wkNiVeGUtEljmiGLdULYilDgzPRww4bILYbMWsmJZ(cl1nzjeg1(cyxTetcpWiVAl8Mop4QNsUq3eh6TD(l7u2uIKFWHIz1feqR4dG3LrEjaDxLaoSG4bh8bHeIU6meKE1BlXMseOF6Zkqgwr(smdlHJxpLCHURsqcoyyjC8kgoyUDvccYTfRBz5oG52w6QLHgjlLdmHLYgD)sQLbgvEldkswkB0TLbgvElDa3YY3szJUTmWOw64kXSmq3bZTT8zwgWMSSCh2Pwgyh0ilDa3sWBzGDwjlr3o)LzjswcElrLGvIHlHGSfEtNhC1tjxOBIJe0WAUq09MopOlMtLh4feu8bm3w(bhA7lG)oKFa6v5e(0gfzqXgtXS6ccOvorqiw)uMRocQOsahwq8LygwchVIHdMBxLGeCWE5qSrPQUPo(WoTZDqJQeWHfeFPCvxqaTYDwP(TD(lRsahwq8LYvDbb06jbRedxcbvjGdlioYrUTyDlduhzjMCX)fWcNtw(yqmlr3o)LDkBkrw6aULO6ZkSu2OBlxdjlXeed)zUsw6QLRz5ZSuq3zP6meKEvBH305bx9uYf6M4ibnmeI)lGfoNKFWH6LdXgLQqig(ZCLQmhukCORT8GqcrxDgcsV6TLytjc0p9zfid6A2I1TelRwUMLQZqq6zPSr3wIsngPwga12GblirwwIiiwkbXYYDaClLtKxcq3zj8klBRAIbGWs0TZFzNYMsu1w4nDEWvpLCHUjosqd72o)LDkBkrY3w1euxDgcspOyl)GdvDbb06rngPDLABWGfKOkbCybXxQUGaAfFa8UmYlbO7QeWHfeFjNGLWXR4dG3LrEjaDxLrf(aoKH9YdcjeD1zii9Q3wInLiq)0NvaDTL6uqD978HWugv4d4cV8TfRBPCA09lPwgyIGqmlrvMRocQWshWTeRwILCqPZYh3YYeoNSCawQBYs0TZFzNLJA5Cwk7z62sPBaiSeD78x2PSPez5dSeRwQodbPx1w4nDEWvpLCHUjosqd72o)LDkBkrYp4qLR6ccOvorqiw)uMRocQOsahwq8LE5qSrPkSW5uFaDDt9B78x2vzoOeuSU8GqcrxDgcsV6TLytjc0p9zfqXQTyDll3Nzje28Srxzj7vxNhiVLshzj625VStztjYYhdIzjQ(SclXg5wkB0TLYjmjlDe(ao1sjiwQVLH2s1zii9K3Y1qULdULLRCYY5SKjbadaHLpoULy(bw6Gvw6fVeqT8XTuDgcspKlVLpZsSICl13YcpqMIPCilr)aBjfikbU5bwkB0TLLhaHXOo8igDLLpWsSAP6meKEwI5qBPSr3ww2OOiVAl8Mop4QNsUq3ehjOHDBN)YoLnLi5hCOy4SXHfuv6Ooe28Srx1zV668GLywDbb0k(a4DzKxcq3vjGdli(soblHJxXhaVlJ8sa6UkJk8bCid7GdwDbb0QmYH8Gc)uIvjGdli(YdcjeD1zii9Q3wInLiq)0NvGmOHo4G9YHyJs1bqymQdpIrxvjGdli(syjC86TQa(fx)X7CY1DvcYYdcjeD1zii9Q3wInLiq)0NvGmOyfjVCi2Oufw4CQpGUUP(TD(l7QeWHfeh52cVPZdU6PKl0nXrcAy3wInLiq)0Nvi)Gd9GqcrxDgcsVWHIvBH305bx9uYf6M4ibnSB78x2PSPef1OgJa]] )


end
