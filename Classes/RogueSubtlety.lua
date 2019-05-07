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

        potion = "battle_potion_of_agility",

        package = "Subtlety",
    } )


    spec:RegisterPack( "Subtlety", 20190417.2216, [[dafctbqiIk9iLK2Ks4tkjqJckXPGISkjGEfe1SiQ6wqrzxs6xsidtcYXGsTmjkpJOIPjb11KaTnLe6BqKQXPKGCoisY6eqyEqe3dc7tc1)usa5GqjLfkr1dHIQjkG6IqjH2OsI8risQgPscQoPsIYkvIEjusWmHiPCtLev7uG8tLeGHcrILcLKEkKMQaCvbeTvOKOVcLuDwLeqTxH(RunyrhMQfdQhlLjt4YiBgQ(minAL60kwTsckVwImBuDBbTBGFRQHdIJdrklhLNRY0jDDISDOW3jkJxaPZRKA9saMVa1(PCe7yaruHRumOYke2ivfQWyJ0RLvg2RyHlyevxdHIOq8wjhkfrbEifrrLGvoPRJOq8183fXaIO3lXAueDRkKlquurqhDlbxBFyr3ekXDDEqJ54Ar3e2kkIclnCDLbIWruHRumOYke2ivfQWyJ0RLvg2RyHJOUKUFwefDcX8i6EecceHJOc6Ar0vTevcw5KU2sS6dvISLRA5wvixGOOIGo6wcU2(WIUjuI768GgZX1IUjSvKTCvlXAqyd3sSr6YBzzfcBKklXmllRSarHkKT0wUQLy(2bqPlqylx1smZsSMqqclXkmTswQVLcc3L4QLEtNhyjFoTAlx1smZsSkf(yqclvNbL0(GBz7bIrNhy5dSCL7SsKWs8NzzGjx3vB5QwIzwI1ecsyzG8ilxzkfE1ikFo9IberpLCUUjrmGyqyhdiIsahMtIy5r0gBuInEeflwQoNaAfFaIUmYlbO7QeWH5KWYGd2YdcX5D1zqj9Q3wInLiq)0NfAjsSuowIjlxyjwSewchVEk5CDxLGyzWbBjSeoEfdhm3UkbXsmfr9MopiIEBx8YoLnLOOgdQSyaruc4WCselpI2yJsSXJOTpe(7q(bOxvq4tBulrcclX2smZsSyP6CcOvbrqiw)uMRoukSsahMtclxyjwSewchVIHdMBxLGyzWbBPxaeBuQQBQJpSt7ch0OkbCyojSCHLY1s15eqRcNvQFBx8YQeWH5KWYfwkxlvNtaTEsWkXWLGsvc4WCsyjMSetruVPZdIOnNZ7EtNh05ZPru(CAh4HuefFaZTJAmi5ediIsahMtIy5r0gBuInEe1laInkvHqm8N5kvzoOKLfJWYYSCHLheIZ7QZGs6vVTeBkrG(Ppl0sKGWYYIOEtNherHY)peM7ckQXGkCmGikbCyojILhr9MopiIEBx8YoLnLOiAJnkXgpIQoNaA9OgJ0UsTnyqAsuLaomNewUWs15eqR4dq0LrEjaDxLaomNewUWsbblHJxXhGOlJ8sa6UkJc9bCwIelX2YfwEqioVRodkPx92sSPeb6N(SqlryzzwUWsDcPU(DXqwIzwYOqFaNLfB5kgrBRBCQRodkPxmiSJAmOcgdiIsahMtIy5r0gBuInEevUwQoNaAvqeeI1pL5QdLcReWH5KWYfw6faXgLQWCxq9b01n1VTlEzxL5GswIWs5y5clpieN3vNbL0REBj2uIa9tFwOLiSuoruVPZdIO32fVStztjkQXGwXyaruc4WCselpI2yJsSXJOy4SXH5uv6Ooe28Srx3zV668alxyjwSuDob0k(aeDzKxcq3vjGdZjHLlSuqWs44v8bi6YiVeGURYOqFaNLiXsSTm4GTuDob0QmYH8Gq)uIvjGdZjHLlS8GqCExDgusV6TLytjc0p9zHwIeewwyldoyl9cGyJs1bqymQdp8rxxjGdZjHLlSewchVERdHF(1F8UGCDxLGy5clpieN3vNbL0REBj2uIa9tFwOLibHLYXsKT0laInkvH5UG6dORBQFBx8YUkbCyojSetruVPZdIO32fVStztjkQXGq6XaIOeWH5KiwEeTXgLyJhrpieN3vNbL0ZYIryPCIOEtNherVTeBkrG(PplmQXGwHIber9MopiIEBx8YoLnLOikbCyojILh1OgrfeUlX1yaXGWogqe1B68Gi6PKZ1DeLaomNeXYJAmOYIber9MopiIwAALIOeWH5KiwEuJbjNyaruc4WCselpI6nDEqeT5CE3B68GoFonIYNt7apKIOnXf1yqfogqeLaomNeXYJOn2OeB8i6PKZ1njQoNhr9MopiIYKaDVPZd6850ikFoTd8qkIEk5CDtIOgdQGXaIOeWH5KiwEeTXgLyJhrvNbL0QoHux)Uyill2Yv0YfwYOqFaNLiXsOnrn0dulxyz7dH)oKFa6zzXiSSWwIzwIfl1jKSejwIDHSetwwGwwwe1B68GikyGUvyUlOOgdAfJberjGdZjrS8ikgoxIIOqyZZgDDN9QRZdSCHLheIZ7QZGs6vVTeBkrG(Ppl0YIryzzruVPZdIOy4SXH5uefdN1bEifrLoQdHnpB01D2RUopiQXGq6XaIOeWH5KiwEeTXgLyJhrXWzJdZPQ0rDiS5zJUUZE115bruVPZdIOnNZ7EtNh05ZPru(CAh4Hue9uY56U3exuJbTcfdiIsahMtIy5rumCUefrlRGwISLQZjGwXyG(SkbCyojSSaTuof0sKTuDob0AOFkX6pE)2U4LDvc4WCsyzbAzzf0sKTuDob06TDXlRJ)nPRsahMtcllqllRqwISLQZjGwDU3yJUUsahMtcllqlXUqwISLyxqllqlXILheIZ7QZGs6vVTeBkrG(Ppl0YIryPCSetruVPZdIOy4SXH5uefdN1bEifrpLCUU76Mr3(5IOgdcPkgqeLaomNeXYJOn2OeB8ikbig01vbHpTrTejiSedNnomNQNsox3DDZOB)Cre1B68GiAZ58U305bD(CAeLpN2bEifrpLCUU7nXf1yqyxOyaruc4WCselpI2yJsSXJOEbqSrPkyGU1RJbbGsoOrvc4WCsy5clpieN3vNbL0REBj2uIa9tFwOLiXYYSCHLT)5IxgOERdHF(1F8UGCDxzuOpGZsKGWs5y5clLRLWs44vWaDRxhdcaLCqJQsqSCHLTpe(7q(bONLfJWYYIOEtNherbd0TcZDbf1yqyJDmGikbCyojILhrBSrj24r02hc)Di)a0Rki8PnQLibHLyBzWbBPoHux)UyilrcclX2Yfw2(q4Vd5hGEwwmclLte1B68GiAZ58U305bD(CAeLpN2bEifrXhWC7Ogdc7YIberjGdZjrS8iAJnkXgpIEqioVRodkPx92sSPeb6N(SqlryzHTCHLTpe(7q(bONLfJWYchr9MopiI2CoV7nDEqNpNgr5ZPDGhsru8bm3oQXGWwoXaIOeWH5KiwEeTXgLyJhrjaXGUUki8PnQLibHLy4SXH5u9uY56URBgD7NlIOEtNherBoN39MopOZNtJO850oWdPikS0Wfrnge2fogqeLaomNeXYJOn2OeB8ikbig01vbHpTrTSyewIDbTezljaXGUUYiOeiI6nDEqe1znhqD9zmcOrnge2fmgqe1B68GiQZAoG6qK4hfrjGdZjrS8Ogdc7vmgqe1B68GikFGU1RVctsanKaAeLaomNeXYJAuJOqyu7dHDngqmiSJberjGdZjrS8OgdQSyaruc4WCselpQXGKtmGikbCyojILh1yqfogqeLaomNeXYJAmOcgdiI6nDEqe9uY56oIsahMtIy5rng0kgdiIsahMtIy5ruVPZdIOHoRej64pRlix3ruimQ9HWU2pQ9aXfrXUGrngespgqeLaomNeXYJOEtNherVTlEzDyUlOlIcHrTpe21(rThiUik2rng0kumGiQ305bruiVopiIsahMtIy5rnQru8bm3ogqmiSJberjGdZjrS8iAJnkXgpIQoNaA92U4L1X)M0vjGdZjHLlSewchVcgOB96yqaOKdAuvcILlS8GqCExDgusV6TLytjc0p9zHwwmcllZsKTuowwGwQoNaA9OgJ0UsTnyqAsuLaomNeruVPZdIOegZ1iMRuuJbvwmGikbCyojILhrBSrj24ruSyPCTuDob0QWzL632fVSkbCyojSm4GTuUwclHJxVTlEzDHdAuvcILyYYfwQodkPvDcPU(DXqwIzwYOqFaNLfB5kA5clzuOpGZsKyPoTsDDcjllqlllI6nDEqefmq3km3fuuJbjNyaruc4WCselpI6nDEqefmq3km3fueTXgLyJhrLRLy4SXH5uv6Ooe28Srx3zV668alxy5bH48U6mOKE1BlXMseOF6ZcTSyewwMLlSelw6faXgLQGb6wVogeak5GgvjGdZjHLbhSLY1sVai2OuLrq4tZ1baTFBx8YUkbCyojSm4GT8GqCExDgusV6TLytjc0p9zHwIzw6nDWG6IxRGb6wH5UGSSyewwMLyYYfwkxlHLWXR32fVSUWbnQkbXYfwQti11VlgYYIryjwSSGwISLyXYYSSaTS9HWFhYpa9SetwIjlxyjJWz0TDyofrBRBCQRodkPxmiSJAmOchdiIsahMtIy5r0gBuInEeLrH(aolrILT)5IxgOERdHF(1F8UGCDxzuOpGZsKTe7cz5clB)ZfVmq9whc)8R)4Db56UYOqFaNLibHLf0YfwQodkPvDcPU(DXqwIzwYOqFaNLfBz7FU4LbQ36q4NF9hVlix3vgf6d4Sezllye1B68GikyGUvyUlOOgdQGXaIOeWH5KiwEeTXgLyJhrHLWXR36q4NF9hVlix3vjiwUWsSyPCTuDob0QWzL632fVSkbCyojSm4GTewchVEBx8Y6ch0OQeelXue1B68Gi6rngPDLABWG0KOOgdAfJberjGdZjrS8iAJnkXgpIEqioVRodkPx92sSPeb6N(SqllgHLLzjYwQoNaAv4Ss9B7IxwLaomNewISLQZjGwbd0TEQZlrSkbCyojIOEtNherpQXiTRuBdgKMef1yqi9yaruVPZdIOegZ1iMRueLaomNeXYJAuJOnXfdige2XaIOeWH5KiwEeTXgLyJhrHLWXRW8)fCPtRmYBQLbhSLWs441BDi8ZV(J3fKR7QeelxyjwSewchVEBx8Y6WCxqxvcILbhSLT)5IxgOEBx8Y6WCxqxLrH(aolrcclXUqwIPiQ305bruiVopiQXGklgqeLaomNeXYJOEtNherXWzJdZP(aucCJUUdDG6y8CT)xB4Cxha0oJ8M(SiAJnkXgpIclHJxV1HWp)6pExqUURsqSm4GTuNqQRFxmKLiXYYkuef4HuefdNnomN6dqjWn66o0bQJXZ1(FTHZDDaq7mYB6ZIAmi5ediIsahMtIy5r0gBuInEefwchVERdHF(1F8UGCDxLGer9MopiIkDuFuk8IAmOchdiIsahMtIy5r0gBuInEefwchVERdHF(1F8UGCDxLGer9MopiIcZ)x0XLyRJAmOcgdiIsahMtIy5r0gBuInEefwchVERdHF(1F8UGCDxLGer9MopiIctSJyLga0OgdAfJberjGdZjrS8iAJnkXgpIclHJxV1HWp)6pExqUURsqIOEtNherXhgbZ)xe1yqi9yaruc4WCselpI2yJsSXJOWs441BDi8ZV(J3fKR7QeKiQ305bruh0OtzoV3CopQXGwHIberjGdZjrS8iAJnkXgpIkxlHLWXR32fVSUWbnQkbXYfwclHJxVTeBkrGU(mGl(QeelxyjSeoE92sSPeb66ZaU4Rmk0hWzjsqyPCQfmI6nDEqe92U4L1foOrruPJ6poEhAterXoQXGqQIberjGdZjrS8iAJnkXgpIclHJxVTeBkrGU(mGl(QeelxyjSeoE92sSPeb66ZaU4Rmk0hWzjsqyPCQfmI6nDEqe9whc)8R)4Db56oIkDu)XX7qBIik2rnge2fkgqeLaomNeXYJOn2OeB8iQ41kyGUvyUlOQoTsdaQLlSelwkxlvNtaTEBj2uIaD9zax8vc4WCsyzWbBP6CcO1B7Ixwh)BsxLaomNewgCWwEqioVRodkPx92sSPeb6N(SqlrILYXYGd2s5Az7FU4LbQ3wInLiqxFgWfFvcILykI6nDEqe9whc)8R)4Db56oQXGWg7yaruc4WCselpI2yJsSXJOmFeDcdcOvxiUQeelxyjwSuDgusR6esD97IHSejw2(q4Vd5hGEvbHpTrTm4GTuUwEk5CDtIQZ5wUWY2hc)Di)a0Rki8PnQLfJWYgKEOhO9dcbewIPiQ305br0qNvIeD8N1fKR7Ogdc7YIberjGdZjrS8iAJnkXgpIY8r0jmiGwDH4QdWYITuofYsmZsMpIoHbb0QlexviXCDEGLlSuUwEk5CDtIQZ5wUWY2hc)Di)a0Rki8PnQLfJWYgKEOhO9dcberuVPZdIOHoRej64pRlix3rnge2YjgqeLaomNeXYJOn2OeB8iA7dH)oKFa6vfe(0g1YIryzzwISLNsox3KO6CEe1B68Gi6TDXlRdZDbDrnge2fogqeLaomNeXYJOn2OeB8i6bH48U6mOKEwwmclLJLlSuUwQoNaA92U4L1X)M0vjGdZjHLlSu8Afmq3km3fuvNwPba1YfwkxlpLCUUjr15Clxyz7FU4LbQ36q4NF9hVlix3vjiwUWY2)CXlduVTlEzDHdAuTTDgu6SSyewIDe1B68Gi6TLytjc01NbCXh1yqyxWyaruc4WCselpI2yJsSXJOheIZ7QZGs6zzXiSuowUWs15eqR32fVSo(3KUkbCyojSCHLIxRGb6wH5UGQ60knaOwUWsyjC86Toe(5x)X7cY1Dvcse1B68Gi6TLytjc01NbCXh1yqyVIXaIOeWH5KiwEeTXgLyJhrLRLWs441B7Ixwx4GgvLGy5cl1jK663fdzjsqyzbTezlvNtaTEsWkXWLGsvc4WCsy5clLRLmFeDcdcOvxiUQeKiQ305br0B7Ixwx4Ggf1OgrpLCUU7nXfdige2XaIOeWH5KiwEefdNlrr02)CXlduVTlEzDHdAuTTDgu664mVPZdCULfJWsSRi9cgr9MopiIIHZghMtrumCwh4Hue92IUUz0TFUiQXGklgqeLaomNeXYJOn2OeB8iQCTedNnomNQ3w01nJU9ZfwUWY2hc)Di)a0Rki8PnQLfBj2wUWsbblHJxXhGOlJ8sa6UkJc9bCwIelXoI6nDEqefdhm3oQXGKtmGikbCyojILhr9MopiIc5FENr3lXAueLcuL5Dp8LaAeTWfkII)SoGcunge2rnguHJberjGdZjrS8iAJnkXgpIsaIbDTLfJWYcxilxyjbig01vbHpTrTSyewIDHSCHLY1smC24WCQEBrx3m62pxy5clBFi83H8dqVQGWN2OwwSLyB5clfeSeoEfFaIUmYlbO7Qmk0hWzjsSe7iQ305br0B7IxwiXfrngubJberjGdZjrS8ikgoxIIOTpe(7q(bOxvq4tBullgHLfoI6nDEqefdNnomNIOy4SoWdPi6Tf92hc)Di)a0lQXGwXyaruc4WCselpI6nDEqefdNnomNIOy4CjkI2(q4Vd5hGEvbHpTrTejiSeBlr2YYSSaT0laInkv1n1Xh2PDHdAuLaomNer0gBuInEefdNnomNQsh1HWMNn66o7vxNhy5clXILQZjGwbd0TEQZlrSkbCyojSm4GTuDob0QWzL632fVSkbCyojSetrumCwh4Hue92IE7dH)oKFa6f1yqi9yaruc4WCselpI2yJsSXJOy4SXH5u92IE7dH)oKFa6z5clXILY1s15eqRcNvQFBx8YQeWH5KWYGd2sXRvWaDRWCxqvgf6d4SSyewwqlr2s15eqRNeSsmCjOuLaomNewIjlxyjwSedNnomNQ3w01nJU9ZfwgCWwclHJxV1HWp)6pExqUURmk0hWzzXiSe7AzwgCWwEqioVRodkPx92sSPeb6N(SqllgHLf2Yfw2(NlEzG6Toe(5x)X7cY1DLrH(aoll2sSlKLykI6nDEqe92U4L1foOrrng0kumGikbCyojILhrBSrj24rumC24WCQEBrV9HWFhYpa9SCHL6esD97IHSejw2(NlEzG6Toe(5x)X7cY1DLrH(aolxyPCTK5JOtyqaT6cXvLGer9MopiIEBx8Y6ch0OOg1ikS0WfXaIbHDmGikbCyojILhrBSrj24r0dcX5D1zqj9SSyewwMLiBjwSuDob0ku()HWCxqvc4WCsy5cl9cGyJsvied)zUsvMdkzzXiSSmlXue1B68Gi6TLytjc0p9zHrnguzXaIOEtNherHY)peM7ckIsahMtIy5rngKCIber9MopiIc7TsN6Wruc4WCselpQrnQrumi2npiguzfcBKQcv4cHDf7cx4chrL5mWaGEr0vwiKNPKWsKULEtNhyjFo9Q2Yi6bHAXGkBfXoIcH94dNIORAjQeSYjDTLy1hQezlx1YTQqUarrfbD0TeCT9HfDtOe315bnMJRfDtyRiB5QwI1GWgULyJ0L3YYke2ivwIzwwwzbIcviBPTCvlX8TdGsxGWwUQLyMLynHGewIvyALSuFlfeUlXvl9MopWs(CA1wUQLyMLyvk8XGewQodkP9b3Y2deJopWYhy5k3zLiHL4pZYatUUR2YvTeZSeRjeKWYa5rwUYuk8Q2sB5QwIvmqPMKsclHj8Nrw2(qyxTeMGoGRAjwR1ii6zj4by22zH4sCl9Mop4S8b81vBP305bxfcJAFiSRiW5(vYw6nDEWvHWO2hc7kYikYLGgsa115b2sVPZdUkeg1(qyxrgrr4)lSLRAjkWHC7xTK5JWsyjCCsy5PUEwct4pJSS9HWUAjmbDaNLoqyjegHzqEvhaulNZsXdOQT0B68GRcHrTpe2vKru0bCi3(1(PUE2sVPZdUkeg1(qyxrgrrNsox32sVPZdUkeg1(qyxrgrrHoRej64pRlix3YdHrTpe21(rThioeyxqBP305bxfcJAFiSRiJOOB7IxwhM7c6KhcJAFiSR9JApqCiW2w6nDEWvHWO2hc7kYikcYRZdSL2YvTeRyGsnjLewsyqS1wQtizPUjl9M(mlNZshdF4omNQ2YvTeRsNsox3wo4wc5VBG5KLyb8wIHehqmhMtwsakCOZYbyz7dHDft2sVPZdoeNsox32sVPZdoKruuPPvYwUQLy(MALSeZd8zPRwIpStTLEtNhCiJOOMZ5DVPZd685u5bEiHOjoB5QwIvLawIlX5RT8KnABtNL6BPUjlrvY56MewIvF115bwIf41wk(ba1Y7L3YrTe)zn6SeY)8ba1Yb3sWR7ba1Y5S0XWhUdZjmvTLEtNhCiJOiMeO7nDEqNpNkpWdjeNsox3Kq(bhXPKZ1njQoNBlx1sSgei81wg0aDRWCxqw6QLLHSLyosXsHeBaqTu3KL4d7ulXUqwEu7bItElDCLywQBxTSWiBjMJuSCWTCulPafYWOZszJUhGL6MSeqbQAjsDmpWw(mlNZsWRwkbXw6nDEWHmIIad0TcZDbj)GJqDgusR6esD97IHkEfxWOqFahsG2e1qpqx0(q4Vd5hGEfJOWygw0jKqc2fctfyz2YvTCfaGV2Y22bqjlzV668alhClLrwUDmilHWMNn66o7vxNhy5rQLoqyzOexhiCYs1zqj9Sucs1w6nDEWHmIIWWzJdZj5bEiHq6Ooe28Srx3zV668a5XW5seciS5zJUUZE115bloieN3vNbL0REBj2uIa9tFwyXikZwUQLif28SrxBjw9vxNhScKLi1iDf8Se6GbzPBzJ5qS0HFj1scqmORTe)zwQBYYtjNRBlX8aFwIfyPHliMLNoCULm6Gqn1YrXu1YvGLGiVLJAzZbwctwQBxT8MqiCQAl9Mop4qgrrnNZ7EtNh05ZPYd8qcXPKZ1DVjo5hCey4SXH5uv6Ooe28Srx3zV668aB5QwgipsyP(wki8bqwkBtal13sPJS8uY562smpWNLpZsyPHli2zl9Mop4qgrry4SXH5K8apKqCk5CD31nJU9ZfYJHZLieLvqKvNtaTIXa9zvc4WCsuGYPGiRoNaAn0pLy9hVFBx8YUkbCyojkWYkiYQZjGwVTlEzD8VjDvc4WCsuGLviKvNtaT6CVXgDDLaomNefi2fczSlybILdcX5D1zqj9Q3wInLiq)0Nfwmc5GjB5QwI5p4gbXSu6gaulDlrvY562smpWwkBtalzK32daQL6MSKaed6Al1nJU9Zf2sVPZdoKruuZ58U305bD(CQ8apKqCk5CD3BIt(bhbbig01vbHpTrrccmC24WCQEk5CD31nJU9Zf2YvTmOb6wxbplXkjauYbnkqyzqd0TcZDbzjmH)mYs01HWp)S0vl5VmlXCKIL6Bz7dHhazj5m(AlzeoJUTLYgDBjus1ba1sDtwclHJBPeKQT0B68GdzefbgOBfM7cs(bhHxaeBuQcgOB96yqaOKdAuLaomNeloieN3vNbL0REBj2uIa9tFwiskBr7FU4LbQ36q4NF9hVlix3vgf6d4qcc5SqUWs44vWaDRxhdcaLCqJQsqw0(q4Vd5hGEfJOmB5QwUsdyUTLUAzHr2szJUFj1YaJkVLfezlLn62YaJAjwEj9gbz5PKZ1nMSLEtNhCiJOOMZ5DVPZd685u5bEiHaFaZTLFWr0(q4Vd5hGEvbHpTrrccSdoyDcPU(DXqibb2lAFi83H8dqVIrihB5QwI1hDBzGrT053Bj(aMBBPRwwyKT0H6d4ulPa1BkFTLf2s1zqj9SelVKEJGS8uY56gt2sVPZdoKruuZ58U305bD(CQ8apKqGpG52Yp4ioieN3vNbL0REBj2uIa9tFwiIcVO9HWFhYpa9kgrHTLRAzG8ilDlHLgUGywkBtalzK32daQL6MSKaed6Al1nJU9Zf2sVPZdoKruuZ58U305bD(CQ8apKqalnCH8doccqmORRccFAJIeey4SXH5u9uY56URBgD7NlSLRAjsTxgDQLqyZZgDTLdWsNZT8XTu3KLynKcsnlHPMlDKLJAzZLo6S0TePoMhyBP305bhYikYznhqD9zmcOYp4iiaXGUUki8PnAXiWUGitaIbDDLrqjGT0B68Gdzef5SMdOoej(r2sVPZdoKrueFGU1RVctsanKaQT0wUQLLlnCbXoBP305bxfwA4ce3wInLiq)0Nfk)GJ4GqCExDgusVIrugYyrDob0ku()HWCxqvc4WCsSWlaInkvHqm8N5kvzoOuXikdt2sVPZdUkS0WfiJOiO8)dH5UGSLEtNhCvyPHlqgrrWER0PoST0wUQLy()CXldC2sVPZdUAtCiG868a5hCeWs44vy()cU0Pvg5nn4GHLWXR36q4NF9hVlix3vjilWcSeoE92U4L1H5UGUQeKGdU9px8Ya1B7IxwhM7c6Qmk0hWHeeyximzlx1YvY58ba1syVvYs9Tuq4UexTCuk0sPZHsbcldKhzPSr3wIUoe(5NLpULbMCDxTLEtNhC1M4qgrrsh1hLcLh4HecmC24WCQpaLa3OR7qhOogpx7)1go31baTZiVPpt(bhbSeoE9whc)8R)4Db56Ukbj4G1jK663fdHKYkKT0B68GR2ehYiks6O(Ou4j)GJawchVERdHF(1F8UGCDxLGyl9Mop4QnXHmIIG5)l64sS1Yp4iGLWXR36q4NF9hVlix3vji2sVPZdUAtCiJOiyIDeR0aGk)GJawchVERdHF(1F8UGCDxLGyl9Mop4QnXHmIIWhgbZ)xi)GJawchVERdHF(1F8UGCDxLGyl9Mop4QnXHmIICqJoL58EZ5C5hCeWs441BDi8ZV(J3fKR7QeeB5QwgipYYa7Ggz5JJJzqBclHj8NrwQBYs8HDQLOBj2uIawIQpl0sC2hAzapd4I3Y2hsNLdOAl9Mop4QnXHmIIUTlEzDHdAK8sh1FC8o0Mab2Yp4iKlSeoE92U4L1foOrvjilGLWXR3wInLiqxFgWfFvcYcyjC86TLytjc01NbCXxzuOpGdjiKtTG2YvTelbsaNUZsNZixS2sjiwctnx6ilLrwQ)xYs0TlEzwUsFt6WKLshzj66q4NFw(44yg0MWsyc)zKL6MSeFyNAj6wInLiGLO6ZcTeN9HwgWZaU4TS9H0z5aQ2sVPZdUAtCiJOOBDi8ZV(J3fKRB5LoQ)44DOnbcSLFWralHJxVTeBkrGU(mGl(QeKfWs441BlXMseORpd4IVYOqFahsqiNAbTLRAzG8ilrxhc)8ZYhyz7FU4LbSeloUsmlXh2Pwg0aDRWCxqyYsjaNUZszKLoJSe6paOwQVLqEiwgWZaU4T0bclfVLGxTC7yqwIUDXlZYv6Bsx1w6nDEWvBIdzefDRdHF(1F8UGCDl)GJq8Afmq3km3fuvNwPbaDbwKR6CcO1BlXMseORpd4IVsahMtIGdwDob06TDXlRJ)nPRsahMtIGd(GqCExDgusV6TLytjc0p9zHirobhSCB)ZfVmq92sSPeb66ZaU4RsqWKTCvlxz4w6cXzPZilLGiVLhyGqwQBYYhqwkB0TL8xgDQLbeqGRwgipYszBcyPy9aGAjUFkXSu3oWsmhPyPGWN2Ow(mlbVA5PKZ1njSu2O7xsT0bRTeZrkvBP305bxTjoKruuOZkrIo(Z6cY1T8docMpIoHbb0QlexvcYcSOodkPvDcPU(DXqiP9HWFhYpa9QccFAJgCWY9uY56MevNZx0(q4Vd5hGEvbHpTrlgrdsp0d0(bHacmzlx1YvgULG3sxiolLnCULIHSu2O7byPUjlbuGQwkNcDYBP0rwUYXdSLpWs4)olLn6(LulDWAlXCKILoqyj4T8uY56UAl9Mop4QnXHmIIcDwjs0XFwxqUULFWrW8r0jmiGwDH4QdOy5uimJ5JOtyqaT6cXvfsmxNhSqUNsox3KO6C(I2hc)Di)a0Rki8PnAXiAq6HEG2pieqyl9Mop4QnXHmIIUTlEzDyUlOt(bhr7dH)oKFa6vfe(0gTyeLH8PKZ1njQoNBlx1sSMAPCq2szJUFj1s0TlEzwUsFt6Su6ild4zax8wkB0TLOFGT0bcldSdAKLmYfRRwI1jlLnCULqEiwQ7)ilHj8NrwQBYs8HDQLN(SqlBFiDwoGQT0B68GR2ehYik62sSPeb66ZaU4LFWrCqioVRodkPxXiKZc5QoNaA92U4L1X)M0vjGdZjXcXRvWaDRWCxqvDALga0fY9uY56MevNZx0(NlEzG6Toe(5x)X7cY1DvcYI2)CXlduVTlEzDHdAuTTDgu6kgb22YvTeRPwkhKTu2OBlr3U4Lz5k9nPZsPJSmGNbCXBPSr3wI(b2sNZixS2sjivBP305bxTjoKru0TLytjc01NbCXl)GJ4GqCExDgusVIriNfQZjGwVTlEzD8VjDvc4WCsSq8Afmq3km3fuvNwPbaDbSeoE9whc)8R)4Db56UkbXw6nDEWvBIdzefDBx8Y6ch0i5hCeYfwchVEBx8Y6ch0OQeKf6esD97IHqcIcIS6CcO1tcwjgUeuQsahMtIfYL5JOtyqaT6cXvLGylTLRA5knG52e7SLRAjwrmMRrmxjl3d0nDQLqyZZgDTLUAzziBP6mOKEwkB0TLOBx8YSCL(M0zjwkiYwkB0TLOuJrQLbqTnyqAsKLdWsxigDEaMS0bcldAGU1vWZsSscaLCqJSucs1w6nDEWvXhWCBeegZ1iMRK8doc15eqR32fVSo(3KUkbCyojwalHJxbd0TEDmiauYbnQkbzXbH48U6mOKE1BlXMseOF6ZclgrzilNcuDob06rngPDLABWG0KOkbCyojSLRAjwbIGyPeeldAGUvyUlilhClh1Y5S0HFj1s9TKjbS8L0QLb(Te8QLshzzqLBPqInaOwgyh0i5TCWTuDobusy5a03Ya7SswIUDXlRAl9Mop4Q4dyUnYikcmq3km3fK8docSix15eqRcNvQFBx8YQeWH5Ki4GLlSeoE92U4L1foOrvjiyAH6mOKw1jK663fdHzmk0hWv8kUGrH(aoKOtRuxNqQalZwUQLRCjUoIx1ba1YxsVrqwgyh0ilFGLQZGs6zPUD1szdNBjFWGSe)zwQBYsHeZ15bw(4wg0aDRWCxqYBjJWz0TTuiXgaulH4abfoTQLRCjUoIxT0pl5paQL(zzziBP6mOKEwkElbVA52XGSmOb6wH5UGSucILYgDBjwLGWNMRdaQLOBx8YolXIeGt3z56xYYTJbzzqd0TUcEwIvsaOKdAKL6)yQAl9Mop4Q4dyUnYikcmq3km3fK8T1no1vNbL0db2Yp4iKlgoBCyovLoQdHnpB01D2RUopyXbH48U6mOKE1BlXMseOF6ZclgrzlWIxaeBuQcgOB96yqaOKdAuLaomNebhSC9cGyJsvgbHpnxha0(TDXl7QeWH5Ki4GpieN3vNbL0REBj2uIa9tFwiM5nDWG6IxRGb6wH5UGkgrzyAHCHLWXR32fVSUWbnQkbzHoHux)UyOIrGLcImwkRaBFi83H8dqpmHPfmcNr32H5KTCvlXQeoJUTLbnq3km3fKLKZ4RTCWTCulLnCULuGczyKLcj2aGAj66q4NFvld8BPUD1sgHZOBB5GBj6hylHs6zjJCXAlhGL6MSeqbQAzbVQT0B68GRIpG52iJOiWaDRWCxqYp4iyuOpGdjT)5IxgOERdHF(1F8UGCDxzuOpGdzSl0I2)CXlduV1HWp)6pExqUURmk0hWHeefCH6mOKw1jK663fdHzmk0hWvC7FU4LbQ36q4NF9hVlix3vgf6d4qUG2YvTeLAmsTmaQTbdstISuiXgaulrxhc)8RAjwF0TLb2zLSeD7IxMLpGV2sHeBaqTeD7IxMLb2bnYsSib0HBPUz0TFUWYbyjGcu1s(aimvTLEtNhCv8bm3gzefDuJrAxP2gminjs(bhbSeoE9whc)8R)4Db56UkbzbwKR6CcOvHZk1VTlEzvc4WCseCWWs441B7Ixwx4GgvLGGjB5QwI1hDBjbEjOBlvNbL0ZsNlZxFwkDKLOulaQz5dSeZdC1w6nDEWvXhWCBKru0rngPDLABWG0Ki5hCeheIZ7QZGs6vVTeBkrG(PplSyeLHS6CcOvHZk1VTlEzvc4WCsGS6CcOvWaDRN68seRsahMtcBP305bxfFaZTrgrregZ1iMRKT0wUQLOk5CDBjM)px8YaNTCvlxHtCieZsSsNnomNSLEtNhC1tjNR7EtCiWWzJdZj5bEiH42IUUz0TFUqEmCUeHO9px8Ya1B7Ixwx4GgvBBNbLUooZB68aNxmcSRi9cAlx1sSshm32sjaNUZszKLoJS0HFj1s9TS5qS8bwgyh0ilBBNbLUQLRaa81wkBtalxPbiSeRtEjaDNLZzPd)sQL6Bjtcy5lPvBP305bx9uY56U3ehYikcdhm3w(bhHCXWzJdZP6TfDDZOB)CXI2hc)Di)a0Rki8PnAXyVqqWs44v8bi6YiVeGURYOqFahsW2wUQLiL)5wI)mlr3U4LfsCHLiBj62fVStztjYsjaNUZszKLoJS0HFj1s9TS5qS8bwgyh0ilBBNbLUQLRaa81wkBtalxPbiSeRtEjaDNLZzPd)sQL6Bjtcy5lPvBP305bx9uY56U3ehYikcY)8oJUxI1i5XFwhqbQIaB5PavzE3dFjGIOWfYw6nDEWvpLCUU7nXHmIIUTlEzHexi)GJGaed66Iru4cTGaed66QGWN2OfJa7cTqUy4SXH5u92IUUz0TFUyr7dH)oKFa6vfe(0gTySxiiyjC8k(aeDzKxcq3vzuOpGdjyBlx1smhPyjJqAsdJcjGgiSmWoOrw6QL8xMLyosXs41wkiCxIRvBP305bx9uY56U3ehYikcdNnomNKh4HeIBl6Tpe(7q(bON8y4Cjcr7dH)oKFa6vfe(0gTyef2wUQLyosXsgH0KggfsanqyzGDqJS8b81wct4pJSeFaZTj2z5GBPmYYTJbzPhcXs15eqplDGWsiS5zJU2s2RUopOAl9Mop4QNsox39M4qgrry4SXH5K8apKqCBrV9HWFhYpa9KhdNlriAFi83H8dqVQGWN2Oibb2ixwb6faXgLQ6M64d70UWbnQsahMtc5hCey4SXH5uv6Ooe28Srx3zV668GfyrDob0kyGU1tDEjIvjGdZjrWbRoNaAv4Ss9B7IxwLaomNeyYwUQLy9r3wgyNvYs0TlEzw(a(AldSdAKLY2eWYGgOBfM7cYszdNB5P(AlLGuTmqEKLcj2aGAj66q4NFw(mlD4hdYsDZOB)Cr1w6nDEWvpLCUU7nXHmIIUTlEzDHdAK8docmC24WCQEBrV9HWFhYpa9wGf5QoNaAv4Ss9B7IxwLaomNebhS41kyGUvyUlOkJc9bCfJOGiRoNaA9KGvIHlbLQeWH5KatlWcgoBCyovVTORBgD7NlcoyyjC86Toe(5x)X7cY1DLrH(aUIrGDTSGd(GqCExDgusV6TLytjc0p9zHfJOWlA)ZfVmq9whc)8R)4Db56UYOqFaxXyximzlx1YYLyalzuOpGba1Ya7GgDwct4pJSu3KLQZGsQLIHolhClr)aBPShScQwctwYixS2YbyPoHu1w6nDEWvpLCUU7nXHmIIUTlEzDHdAK8docmC24WCQEBrV9HWFhYpa9wOti11VlgcjT)5IxgOERdHF(1F8UGCDxzuOpGBHCz(i6egeqRUqCvji2sBPTCvlrvY56MewIvF115b2YvTCLHBjQsox3fHHdMBBPZilLGiVLshzj62fVStztjYs9TeMae(OwIZ(ql1nzje)UbdYs4hiDw6aHLR0aewI1jVeGUtEljmiGLdULYilDgzPRwg6bQLyosXsSGZ(ql1nzjeg1(qyxTCLJhymvTLEtNhC1tjNRBsG42U4LDkBkrYp4iWI6CcOv8bi6YiVeGURsahMtIGd(GqCExDgusV6TLytjc0p9zHiroyAbwGLWXRNsox3vjibhmSeoEfdhm3Ukbbt2YvTCLgWCBlD1YcJSLyosXszJUFj1YaJkVLfezlLn62YaJkVLoqy5kAPSr3wgyulDCLywIv6G52w(mldytwUsd7uldSdAKLoqyj4TmWoRKLOBx8YSezlbVLOsWkXWLGs2sVPZdU6PKZ1njqgrrnNZ7EtNh05ZPYd8qcb(aMBl)GJO9HWFhYpa9QccFAJIeeyJzyrDob0QGiieRFkZvhkfwjGdZjXcSalHJxXWbZTRsqcoyVai2Ouv3uhFyN2foOrvc4WCsSqUQZjGwfoRu)2U4LvjGdZjXc5QoNaA9KGvIHlbLQeWH5KatyYwUQLbYJSePo))qyUlilFmiMLOBx8YoLnLilDGWsu9zHwkB0TLLHSLifIH)mxjlD1YYS8zwYP7SuDgusVQT0B68GREk5CDtcKrueu()HWCxqYp4i8cGyJsvied)zUsvMdkvmIYwCqioVRodkPx92sSPeb6N(SqKGOmB5QwI1ullZs1zqj9Su2OBlrPgJuldGABWG0KillreelLGy5knaHLyDYlbO7SeETLT1n(aGAj62fVStztjQAl9Mop4QNsox3KazefDBx8YoLnLi5BRBCQRodkPhcSLFWrOoNaA9OgJ0UsTnyqAsuLaomNeluNtaTIparxg5La0Dvc4WCsSqqWs44v8bi6YiVeGURYOqFahsWEXbH48U6mOKE1BlXMseOF6Zcru2cDcPU(DXqygJc9bCfVI2YvTeRp6(LuldmrqiMLOkZvhkfAPdewkhlXQoO0z5JBz5Cxqwoal1nzj62fVSZYrTColL9mDBP0naOwIUDXl7u2uIS8bwkhlvNbL0RAl9Mop4QNsox3KazefDBx8YoLnLi5hCeYvDob0QGiieRFkZvhkfwjGdZjXcVai2OufM7cQpGUUP(TDXl7QmhucHCwCqioVRodkPx92sSPeb6N(SqeYXwUQLR0ZSecBE2ORTK9QRZdK3sPJSeD7Ix2PSPez5JbXSevFwOLyJjlLn62sS(k3shQpGtTucIL6BzHTuDgusp5TSmmz5GB5kH1TColzsaWaGA5JJBjwEGLoyTLE4lbulFClvNbL0dtYB5ZSuoyYs9Tm0d0jCkaYs0pWwsbQsGBEGLYgDB5kdqymQdp8rxB5dSuowQodkPNLyPWwkB0TLLpkkMQ2sVPZdU6PKZ1njqgrr32fVStztjs(bhbgoBCyovLoQdHnpB01D2RUopybwuNtaTIparxg5La0Dvc4WCsSqqWs44v8bi6YiVeGURYOqFahsWo4GvNtaTkJCipi0pLyvc4WCsS4GqCExDgusV6TLytjc0p9zHibrHdoyVai2OuDaegJ6WdF01vc4WCsSawchVERdHF(1F8UGCDxLGS4GqCExDgusV6TLytjc0p9zHibHCq2laInkvH5UG6dORBQFBx8YUkbCyojWKT0B68GREk5CDtcKru0TLytjc0p9zHYp4ioieN3vNbL0RyeYXw6nDEWvpLCUUjbYik62U4LDkBkrrnQXi]] )


end
