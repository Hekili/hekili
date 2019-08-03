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


    spec:RegisterPack( "Subtlety", 20190803, [[da1nLbqiOkEeePnPc9jiIWOGO6uquwfebVcQywOuUfkjTlj9ljKHbvPJHsSmjkpdLuttcvxtcLTPIiFtcQACOufNdLk16KGI5PI09uP2Ne4FOujQdkbLwOevpeLetucYfHiI2ier9ruQQ0irPsKojerALQOEjkvvzMOuvv3eLkPDsH8tuQQyOqeAPsqLNcLPsH6QOuL2QkIQVIsv5SOujI9sP)kYGL6WuTyi9yrnzcxgzZG6Zqy0GCAfRgLkHxlrMnr3MI2nWVvA4QKJRIOSCu9CvnDsxhfBhQ03PGXJsfNxfSEveMpuv7xyllwJTycxjRrLHxwy34L9GxwxzPmwkJf2TftpCrwSlpxYrqwmGBswmmguvs6bl2LFqUUWASf7xgEMSyqQE9fMIkcXOqmO18Aw0pMmsxNfK5oSw0pM5ISyOmJursbwulMWvYAuz4Lf2nEl8LXESyoJcTClg2yYkwmOriiGf1IjOpBXqA0ymOQK0drx4wemuCgPrdP61xykQieJcXGwZRzr)yYiDDwqM7WAr)yMlkoJ0OlSmiyEnAwZw0LHxwy3rZQrZcElmSML4CCgPrZkqoab9fM4msJMvJUWkeKiA2FtUu06gTGGDgPgTN1zbrlNxRXzKgnRgDHJmxCjr0QZrqAAGJoVaXOZcIEbrZU68sKiA4LhDHixHQXzKgnRgDHviir0S3NIgjvjZVAXKZRV1yl2RKlvisyn2AelwJTyeWrLKWwUflZhL4JBXqE0QljGwHhGizG8sa6)kbCujjIgF8J(ViPmPohbPF9Hy4tjcKED5MrFA0SoAKf9XOrE0OmWW1xjxQqvMROXh)OrzGHR46G5HQmxrJmlMN1zbwShYfRHx5tjYQwJkZASfJaoQKe2YTyz(OeFClgkdmC9Hy4tjcK0LdCXwzUI(y051eDtx7a0Vki4jpA0NEhDzwmpRZcSyzxktEwNfKKZRwm58Ac4MKfdEaZdzvRrS2ASfJaoQKe2YTyz(OeFCl2FrszsDocs)6dXWNsei96YnJ(o6Ih9XOZRj6MU2bOF0fChDXTyEwNfyXYUuM8SolijNxTyY51eWnjlg8aMhYQwJkU1ylgbCujjSLBXY8rj(4wS8AIUPRDa6xfe8Khn6tVJMLOz1OrE0QljGwfeDr80RCxDeKzLaoQKerFmAKhnkdmCfxhmpuL5kA8XpA)eeFuQQqucE4VMeoitvc4Osse9XOXt0QljGwfoVu6HCXAOsahvsIOpgnEIwDjb06ZGQehMbbvjGJkjr0hJ(ViPmPohbPF9Hy4tjcKED5MrFA0SoAKfnYSyEwNfyXYUuM8SolijNxTyY51eWnjlg8aMhYQwJkM1ylgbCujjSLBXY8rj(4wm)eeFuQErC4L7kv5oOu0fChDzrFm6)IKYK6CeK(1hIHpLiq61LBg9P3rxMfZZ6Salgc5UMOsxqw1A0jzn2IrahvscB5wmpRZcSypKlwdVYNsKflZhL4JBXuxsaT(uMtAsPmeyozmuLaoQKerFmA1LeqRWdqKmqEja9FLaoQKerFmAbHYadxHhGizG8sa6)kNm9b8rFA0Se9XO)lsktQZrq6xFig(uIaPxxUz03rxw0hJwhtkPBsmu0SA0CY0hWhDbrFswS8HSKsQZrq6BnIfRAnQWBn2IrahvscB5wSmFuIpUfdprRUKaAvq0fXtVYD1rqMvc4Osse9XO9tq8rPkQ0fuAajfIspKlwdFL7GsrFhnRJ(y0)fjLj15ii9RpedFkrG0Rl3m67OzTfZZ6Sal2d5I1WR8PezvRrShRXwmc4Ossyl3IL5Js8XTy468XrLuL5P0fFw(Ohs8vDDwq0hJg5rRUKaAfEaIKbYlbO)ReWrLKi6Jrliugy4k8aejdKxcq)x5KPpGp6tJMLOXh)OvxsaTAG8Rfy6Vs8kbCujjI(y0)fjLj15ii9RpedFkrG0Rl3m6tVJU4rJp(r7NG4Js1bq4oQJoYrpujGJkjr0hJgLbgU(hmrx5Nw4KGCfQYCf9XO)lsktQZrq6xFig(uIaPxxUz0NEhnRJgNO9tq8rPkQ0fuAajfIspKlwdFLaoQKerJmlMN1zbwShYfRHx5tjYQwJy3wJTyeWrLKWwUflZhL4JBX(lsktQZrq6hDb3rZAlMN1zbwShIHpLiq61LBAvRrSGxRXwmpRZcSypKlwdVYNsKfJaoQKe2YTQvTy0)eitV1yRrSyn2I5zDwGflVGmbuURKiblDtYIrahvscB5w1AuzwJTyEwNfyXqL7kslCsHOebiZdwmc4Ossyl3QwJyT1ylMN1zbwmemoxmoiTWj)eeFvilgbCujjSLBvRrf3ASfJaoQKe2YTyz(OeFClgYJ(ViPmPohbPF9Hy4tjcKED5MrxWD0Lfn(4hn3hrIWLaA1fIVoGOli6tcVrJSOpgnEIoVRuSga1)Gj6k)0cNeKRqvMROpgnEIgLbgU(hmrx5Nw4KGCfQYCf9XOjaXrCOki4jpA0fChnRXRfZZ6Salg8MzEsK8tq8rPek5Mw1AuXSgBXiGJkjHTClwMpkXh3I9xKuMuNJG0V(qm8PebsVUCZOl4o6YIgF8JM7Jir4saT6cXxhq0fe9jHxlMN1zbwSlg(aFyaisOs)vRAn6KSgBXiGJkjHTClwMpkXh3IHYadx5uUKK(pbV8mvzUIgF8JgLbgUYPCjj9FcE5zkLxgGs86REUu0Ngnl41I5zDwGftHOedaDzaIe8YZKvTgv4TgBX8SolWIXNRljLgq6V8mzXiGJkjHTCRAnI9yn2IrahvscB5wSmFuIpUfdLbgUkhycvURO(QNlf9PrZAlMN1zbwmdlxkWLgqIt)cCqMSQ1i2T1ylgbCujjSLBXY8rj(4wmcqCehI(0OloEJ(y0OmWW1)Gj6k)0cNeKRqvMllMN1zbwmtYC5hslCsYKhrsWj38TQvTycc2zKQ1yRrSyn2IrahvscB5wSmFuIpUfdpr)k5sfIev(IGHSyEwNfyXkn5sw1AuzwJTyEwNfyXELCPczXiGJkjHTCRAnI1wJTyeWrLKWwUfZZ6Salw2LYKN1zbj58QftoVMaUjzXYI3QwJkU1ylgbCujjSLBXY8rj(4wSxjxQqKO6sPfZZ6SalgNbK8SolijNxTyY51eWnjl2RKlvisyvRrfZASfJaoQKe2YTyz(OeFClMoMus3KyOOli6tk6JrZjtFaF0NgnISOA6St0hJoVMOB6AhG(rxWD0fpAwnAKhToMu0Ngnl4nAKfnsi6YSyEwNfyXadcifv6cYQwJojRXwmc4Ossyl3ITxwSNulMN1zbwmCD(4OsYIHRlzil2fFw(Ohs8vDDwq0hJ(ViPmPohbPF9Hy4tjcKED5MrxWD0LzXW15jGBswmMNsx8z5JEiXx11zbw1AuH3ASfJaoQKe2YTyz(OeFClgUoFCujvzEkDXNLp6HeFvxNfyX8SolWILDPm5zDwqsoVAXKZRjGBswSxjxQqPS4TQ1i2J1ylgbCujjSLBX2ll2tQfZZ6SalgUoFCujzXW1LmKfRSIfnorRUKaAf3bXYReWrLKiAKq0SUyrJt0QljGwn9xjEAHtpKlwdFLaoQKerJeIUSIfnorRUKaA9HCXAibVzMVsahvsIOrcrxgEJgNOvxsaT6spZh9qLaoQKerJeIMf8gnorZsXIgjenYJ(ViPmPohbPF9Hy4tjcKED5MrxWD0SoAKzXW15jGBswSxjxQqjfItp0kfw1Ae72ASfJaoQKe2YTyz(OeFClgbioIdvbbp5rJ(07OX15JJkP6RKlvOKcXPhALclMN1zbwSSlLjpRZcsY5vlMCEnbCtYI9k5sfkLfVvTgXcETgBXiGJkjHTClwMpkXh3I5NG4JsvWGas)eUeab5GmvjGJkjr0hJgprJYadxbdci9t4saeKdYuL5k6JrNxt0nDTdq)Ol4o6YI(y0ip6)IKYK6CeK(1hIHpLiq61LBg9Prxw04JF0468XrLuL5P0fFw(Ohs8vDDwq0il6JrJ8OZ7kfRbq9pyIUYpTWjb5kuLtM(a(Op9oAwhn(4hnYJ2pbXhLQGbbK(jCjacYbzQYDqPOl4o6YI(y0OmWW1)Gj6k)0cNeKRqvoz6d4JUGOzD0hJgpr)k5sfIevxkJ(y05DLI1aO(qUynKeoit1mKZrqFcM7zDwGlJUG7OXBLDhnYIgzwmpRZcSyGbbKIkDbzvRrSWI1ylgbCujjSLBXY8rj(4wS8AIUPRDa6xfe8Khn6tVJMLOXh)O1XKs6Medf9P3rZs0hJoVMOB6AhG(rxWD0S2I5zDwGfl7szYZ6SGKCE1IjNxta3KSyWdyEiRAnILYSgBXiGJkjHTClwMpkXh3I9xKuMuNJG0V(qm8PebsVUCZOVJU4rFm68AIUPRDa6hDb3rxClMN1zbwSSlLjpRZcsY5vlMCEnbCtYIbpG5HSQ1iwyT1ylgbCujjSLBXY8rj(4wmcqCehQccEYJg9P3rJRZhhvs1xjxQqjfItp0kfwmpRZcSyzxktEwNfKKZRwm58Ac4MKfdLzKcRAnILIBn2IrahvscB5wSmFuIpUfJaehXHQGGN8OrxWD0SuSOXjAcqCehQCcbbSyEwNfyXCE2busxoNaQvTgXsXSgBX8SolWI58SdO0fJ8jlgbCujjSLBvRrSCswJTyEwNfyXKdci9tSlyeimjGAXiGJkjHTCRAvl2fNYRjQRwJTgXI1ylMN1zbwSxjxQqwmc4Ossyl3QwJkZASfJaoQKe2YTyEwNfyXmDEjsKGxEsqUczXU4uEnrDn9uEbI3IXsXSQ1iwBn2IrahvscB5wmpRZcSypKlwdjuPlO3IDXP8AI6A6P8ceVfJfRAnQ4wJTyEwNfyXUwDwGfJaoQKe2YTQ1OIzn2IrahvscB5wmGBswm)epKZ9pbVanTWPR1aXTyEwNfyX8t8qo3)e8c00cNUwde3Qw1IHYmsH1yRrSyn2IrahvscB5wSmFuIpUf7ViPmPohbPF0fChDzrJt0ipA1LeqRiK7AIkDbvjGJkjr0hJ2pbXhLQxehE5UsvUdkfDb3rxw0iZI5zDwGf7Hy4tjcKED5Mw1AuzwJTyEwNfyXqi31ev6cYIrahvscB5w1AeRTgBX8SolWIH65sV6Owmc4Ossyl3Qw1ILfV1yRrSyn2IX8uAHHtiYclglwSmFuIpUfdprJYadxFixSgschKPkZv0hJgLbgU(qm8Pebs6YbUyRmxrFmAugy46dXWNseiPlh4ITYjtFaF0NEhnRRfZI5zDwGf7HCXAijCqMSyeWrLKWwUvTgvM1ylgZtPfgoHilSySyXY8rj(4wmugy46dXWNseiPlh4ITYCf9XOrzGHRpedFkrGKUCGl2kNm9b8rF6D0SUwmlMN1zbwS)Gj6k)0cNeKRqwmc4Ossyl3QwJyT1ylgbCujjSLBXY8rj(4wm8e9RKlvisuDPm6JrlwTcgeqkQ0fuvNCPbGWI5zDwGfl7szYZ6SGKCE1IjNxta3KSy0)eitVvTgvCRXwmc4Ossyl3I5zDwGf7AxzIt)YWZKflZhL4JBXWt0QljGwFixSgsWBM5ReWrLKWIbV8eGyh1Aelw1AuXSgBXiGJkjHTClwMpkXh3IraIJ4q0fCh9jH3OpgTy1kyqaPOsxqvDYLgaIOpgDExPynaQ)bt0v(PfojixHQmxrFm68UsXAauFixSgschKPAgY5iOp6cUJMflMN1zbwShIHpLiqsxoWfRvTgDswJTyeWrLKWwUflZhL4JBXeRwbdcifv6cQQtU0aqe9XOrE04jA1LeqRpedFkrGKUCGl2kbCujjIgF8JwDjb06d5I1qcEZmFLaoQKerJp(rN3vkwdG6dXWNseiPlh4ITYjtFaF0feDzrJmlMN1zbwS)Gj6k)0cNeKRqw1AuH3ASfJaoQKe2YTyEwNfyXmDEjsKGxEsqUczXY8rj(4wmUpIeHlb0QleFL5k6JrJ8OvNJG0QoMus3KyOOpn68AIUPRDa6xfe8KhnA8XpA8e9RKlvisuDPm6JrNxt0nDTdq)QGGN8OrxWD05RKPZoP)IaIOrMflFilPK6CeK(wJyXQwJypwJTyeWrLKWwUflZhL4JBX4(iseUeqRUq81beDbrZA8gnRgn3hrIWLaA1fIVky4Uoli6JrJNOFLCPcrIQlLrFm68AIUPRDa6xfe8Khn6cUJoFLmD2j9xeqyX8SolWIz68sKibV8KGCfYQwJy3wJTyeWrLKWwUflZhL4JBXYRj6MU2bOFvqWtE0Ol4o6YIgNOFLCPcrIQlLwmpRZcSypKlwdjuPlO3QwJybVwJTyeWrLKWwUflZhL4JBXuxsaT(qUynKG3mZxjGJkjr0hJwSAfmiGuuPlOQo5sdar0hJgLbgU(hmrx5Nw4KGCfQYCzX8SolWI9qm8Pebs6YbUyTQ1iwyXASfJaoQKe2YTyz(OeFClgEIgLbgU(qUynKeoitvMROpgToMus3KyOOp9o6IfnorRUKaA9zqvIdZGGQeWrLKi6JrJNO5(iseUeqRUq8vMllMN1zbwShYfRHKWbzYQwJyPmRXwmc4Ossyl3IL5Js8XTyOmWWvu5UcjZRvo5znA8XpAugy46FWeDLFAHtcYvOkZv0hJg5rJYadxFixSgsOsxqFL5kA8Xp68UsXAauFixSgsOsxqFLtM(a(Op9oAwWB0iZI5zDwGf7A1zbw1AelS2ASfJaoQKe2YTyz(OeFClgkdmC9pyIUYpTWjb5kuL5YI5zDwGfdvURibZWpyvRrSuCRXwmc4Ossyl3IL5Js8XTyOmWW1)Gj6k)0cNeKRqvMllMN1zbwmuI)eV0aqyvRrSumRXwmc4Ossyl3IL5Js8XTyOmWW1)Gj6k)0cNeKRqvMllMN1zbwm4HtOYDfw1AelNK1ylgbCujjSLBXY8rj(4wmugy46FWeDLFAHtcYvOkZLfZZ6SalMdY0RCxMYUuAvRrSu4TgBXiGJkjHTClMN1zbwSRnxI0Fobjs518IrDDwqsq4ozYIL5Js8XTy4j6xjxQqKO6sz0hJwSAfmiGuuPlOQo5sdar0hJgprJYadx)dMOR8tlCsqUcvzUI(y0eG4ioufe8Khn6cUJM141IrWWuwta3KSy5dz5Q8fm5eQ0F1QwJyH9yn2IrahvscB5wmpRZcSy(jEiN7FcEbAAHtxRbIBXY8rj(4wm8enkdmC9HCXAijCqMQmxrFm68UsXAau)dMOR8tlCsqUcv5KPpGp6tJMf8AXaUjzX8t8qo3)e8c00cNUwde3QwJyHDBn2IrahvscB5wmpRZcSy(dHRdOpX9tS8uE5U0IL5Js8XTyccLbgUY9tS8uE5Umjiugy4QynaIgF8JwqOmWW18cemzDWLsdOusqOmWWvMROpgT6CeKwHixQq1RSg9PrZAwIgF8Jgprliugy4AEbcMSo4sPbukjiugy4kZv0hJg5rliugy4k3pXYt5L7YKGqzGHRV65srxWD0LvSOz1OzbVrJeIwqOmWWvu5UI0cNuikraY8qL5kA8XpA15iiTQJjL0njgk6tJU44nAKf9XOrzGHR)bt0v(PfojixHQCY0hWhDbrZESya3KSy(dHRdOpX9tS8uE5U0QwJkdVwJTyeWrLKWwUfd4MKfZ8GW)K6Y5nDGfZZ6SalM5bH)j1LZB6aRAnQmwSgBXiGJkjHTClwMpkXh3IHYadx)dMOR8tlCsqUcvzUIgF8JwhtkPBsmu0NgDz41I5zDwGfJ5P0OK5BvRAXELCPcLYI3AS1iwSgBXiGJkjHTCl2EzXEsTyEwNfyXW15JJkjlgUUKHSy5DLI1aO(qUynKeoit1mKZrqFcM7zDwGlJUG7OzPw4lMfdxNNaUjzXEirsH40dTsHvTgvM1ylgbCujjSLBXY8rj(4wm8enUoFCujvFirsH40dTsr0hJoVMOB6AhG(vbbp5rJUGOzj6Jrliugy4k8aejdKxcq)x5KPpGp6tJMflMN1zbwmCDW8qw1AeRTgBXiGJkjHTClMN1zbwSRDLjo9ldptwmIDuUNCZLbOwSIJxlg8YtaIDuRrSyvRrf3ASfJaoQKe2YTyz(OeFClgbioIdrxWD0fhVrFmAcqCehQccEYJgDb3rZcEJ(y04jACD(4OsQ(qIKcXPhALIOpgDEnr301oa9RccEYJgDbrZs0hJwqOmWWv4bisgiVeG(VYjtFaF0NgnlwmpRZcSypKlwdMKuyvRrfZASfJaoQKe2YTy7Lf7j1I5zDwGfdxNpoQKSy46sgYILxt0nDTdq)QGGN8OrxWD0f3IHRZta3KSypKiLxt0nDTdqFRAn6KSgBXiGJkjHTCl2EzXEsTyEwNfyXW15JJkjlgUUKHSy51eDtx7a0Vki4jpA0NEhnlrJt0LfnsiA)eeFuQQqucE4VMeoitvc4OssyXY8rj(4wmCD(4OsQY8u6IplF0dj(QUoli6JrJ8OvxsaTcgeq6RUSeXReWrLKiA8XpA1LeqRcNxk9qUynujGJkjr0iZIHRZta3KSypKiLxt0nDTdqFRAnQWBn2IrahvscB5wSmFuIpUfdxNpoQKQpKiLxt0nDTdq)OpgnYJgprRUKaAv48sPhYfRHkbCujjIgF8JwSAfmiGuuPlOkNm9b8rxWD0flACIwDjb06ZGQehMbbvjGJkjr0il6JrJ8OX15JJkP6djskeNEOvkIgF8JgLbgU(hmrx5Nw4KGCfQYjtFaF0fChnl1YIgF8J(ViPmPohbPF9Hy4tjcKED5MrxWD0fp6JrN3vkwdG6FWeDLFAHtcYvOkNm9b8rxq0SG3Orw0hJg5r7NG4JsvWGas)eUeab5Gmv5oOu0NgnRJgF8JgLbgUcgeq6NWLaiihKPkZv0iZI5zDwGf7HCXAijCqMSQ1i2J1ylgbCujjSLBXY8rj(4wmCD(4OsQ(qIuEnr301oa9J(y06ysjDtIHI(0OZ7kfRbq9pyIUYpTWjb5kuLtM(a(OpgnEIM7Jir4saT6cXxzUSyEwNfyXEixSgschKjRAvlg8aMhYAS1iwSgBXiGJkjHTClg8YtaIDuRrSyX8SolWIDTRmXPFz4zYQwJkZASfJaoQKe2YTyz(OeFClgkdmCfmiG0pHlbqqoitvMllMN1zbwmc35Ze3vYQwJyT1ylgbCujjSLBXY8rj(4wmKhnEIwDjb0QW5LspKlwdvc4Ossen(4hnEIgLbgU(qUynKeoitvMROrw0hJwhtkPBsmu0SA0CY0hWhDbrFsrFmAoz6d4J(0O1jxkPJjfnsi6YSyEwNfyXadcifv6cYQwJkU1ylgbCujjSLBX8SolWIbgeqkQ0fKflZhL4JBXWt0468XrLuL5P0fFw(Ohs8vDDwq0hJ(ViPmPohbPF9Hy4tjcKED5MrxWD0Lf9XOrE0(ji(OufmiG0pHlbqqoitvc4Ossen(4hnEI2pbXhLQC6sozxhaI0d5I1WxjGJkjr04JF0)fjLj15ii9RpedFkrG0Rl3mAwnApRdUusSAfmiGuuPlOOl4o6YIgzrFmA8enkdmC9HCXAijCqMQmxrFmADmPKUjXqrxWD0ip6IfnorJ8OllAKq051eDtx7a0pAKfnYI(y0CcMtpKJkjlw(qwsj15ii9TgXIvTgvmRXwmc4Ossyl3IL5Js8XTyCY0hWh9PrN3vkwdG6FWeDLFAHtcYvOkNm9b8rJt0SG3OpgDExPynaQ)bt0v(PfojixHQCY0hWh9P3rxSOpgToMus3KyOOz1O5KPpGp6cIoVRuSga1)Gj6k)0cNeKRqvoz6d4JgNOlMfZZ6SalgyqaPOsxqw1A0jzn2IrahvscB5wSmFuIpUfdLbgU(hmrx5Nw4KGCfQYCf9XOrE04jA1LeqRcNxk9qUynujGJkjr04JF0OmWW1hYfRHKWbzQYCfnYSyEwNfyXEkZjnPugcmNmgYQwJk8wJTyeWrLKWwUflZhL4JBX(lsktQZrq6xFig(uIaPxxUz0fChDzrJt0QljGwfoVu6HCXAOsahvsIOXjA1LeqRGbbK(Qllr8kbCujjSyEwNfyXEkZjnPugcmNmgYQwJypwJTyEwNfyXiCNptCxjlgbCujjSLBvRAvlgUe)NfynQm8Yc7gVf(YypwmdohmaeVfdj18A5kjIM9eTN1zbrlNx)AC2IDXx4rswmKgngdQkj9q0fUfbdfNrA0qQE9fMIkcXOqmO18Aw0pMmsxNfK5oSw0pM5IIZin6cldcMxJM1SfDz4Lf2D0SA0SG3cdRzjohNrA0ScKdqqFHjoJ0Oz1OlScbjIM93KlfTUrliyNrQr7zDwq0Y51ACgPrZQrx4iZfxseT6CeKMg4OZlqm6SGOxq0SRoVejIgE5rxiYvOACgPrZQrxyfcsen79POrsvY8RX54msJgjj7qzgLerJsWlNIoVMOUgnkHyaFn6cBotx6hnybSkKZnHzKr7zDwWh9cKhQXzKgTN1zbF9It51e11ByP)LIZinApRZc(6fNYRjQR4CxKZGWKaQRZcIZinApRZc(6fNYRjQR4Cxe8UI4msJgd4xp0QrZ9renkdmmjI(vx)Orj4LtrNxtuxJgLqmGpAhiI(ItS61Q6aqe98rlwavJZinApRZc(6fNYRjQR4Cx0d8RhA10RU(XzpRZc(6fNYRjQR4Cx0RKlvO4SN1zbF9It51e1vCUlY05LircE5jb5keBxCkVMOUMEkVaXFZsXIZEwNf81loLxtuxX5UOhYfRHeQ0f0Z2fNYRjQRPNYlq83SeN9Sol4RxCkVMOUIZDrxRolio7zDwWxV4uEnrDfN7IyEknkzYgWnPB)epKZ9pbVanTWPR1aXJZXzKgnss2HYmkjIMWL4hIwhtkAfII2Z6YJE(ODC9r6OsQgNrA0fo6vYLku0dC0x7)dQKIg5GnACzKaI7OskAcqMd9rpGOZRjQRilo7zDwWJZDrLMCj2g4B88k5sfIev(IGHIZEwNf83VsUuHIZinAwbIYLIMvk0hTRrdp8xJZEwNf84Cxu2LYKN1zbj58kBa3KUZIpoJ0OlCmGOHzKYdr)ggndrF06gTcrrJPKlviseDHBvxNfenYrpeTyhaIO)LTOhnA4LNPp6RDLdar0dC0GvHgaIONpAhxFKoQKqwno7zDwWJZDrCgqYZ6SGKCELnGBs3VsUuHibBd89RKlvisuDPmoJ0OlSxxYdrB0GasrLUGI21OldNOzfKy0cg(aqeTcrrdp8xJMf8g9t5fiE2I2HvIhTc5A0fhNOzfKy0dC0JgnXoxdN(Onmk0aIwHOObe7OrZ(Lvku0lp65JgSA0mxXzpRZcECUlcmiGuuPli2g4BDmPKUjXqfCsh5KPpG)uezr10zNJ51eDtx7a0VG7IZQixht6uwWlYqcLfNrA0SFaYdrNHCackA(QUoli6boAdu0qoUu0x8z5JEiXx11zbr)KgTderBYi15ssrRohbPF0mx14SN1zbpo3fHRZhhvsSbCt6M5P0fFw(Ohs8vDDwaB46sg6(IplF0dj(QUol44FrszsDocs)6dXWNsei96Ynl4US4msJgjYNLp6HOlCR66Sa2LJM9pPij(Orm4sr7rN5(v0o6YOrtaIJ4q0WlpAfII(vYLku0SsH(OrokZifep6xhPmAo9xuwJEuKvJMDjmxSf9OrNDq0Ou0kKRr)J5LKQXzpRZcECUlk7szYZ6SGKCELnGBs3VsUuHszXZ2aFJRZhhvsvMNsx8z5JEiXx11zbXzKgn79jr06gTGGhafTbiceTUrZ8u0VsUuHIMvk0h9YJgLzKcI)XzpRZcECUlcxNpoQKyd4M09RKlvOKcXPhALc2W1Lm0Dzfdh1LeqR4oiwELaoQKeibwxmCuxsaTA6Vs80cNEixSg(kbCujjqcLvmCuxsaT(qUynKG3mZxjGJkjbsOm8IJ6scOvx6z(OhQeWrLKajWcEXHLIHeq(FrszsDocs)6dXWNsei96Ynl4M1iloJ0OzLf8JG4rZ8dar0E0yk5sfkAwPqrBaIarZjpdnaerRqu0eG4ioeTcXPhALI4SN1zbpo3fLDPm5zDwqsoVYgWnP7xjxQqPS4zBGVjaXrCOki4jp6P3468XrLu9vYLkusH40dTsrCgPrB0Gasrs8rFYjacYbzQWeTrdcifv6ckAucE5u0yhmrx5hTRrlxdrZkiXO1n68AIoakAY5YdrZjyo9qrByuOOrqQoaerRqu0OmWWrZCvJUWk)nA5AiAwbjgTGHpaerJDWeDLF0OKAGiq0fYbz6J2WOqrxgorB0jVgN9Sol4X5UiWGasrLUGyBGV9tq8rPkyqaPFcxcGGCqMQeWrLK4iEqzGHRGbbK(jCjacYbzQYCDmVMOB6AhG(fCx2rK)xKuMuNJG0V(qm8PebsVUCZtldF8X15JJkPkZtPl(S8rpK4R66SaKDe55DLI1aO(hmrx5Nw4KGCfQYjtFa)P3SgF8rUFcIpkvbdci9t4saeKdYuL7GsfCx2rugy46FWeDLFAHtcYvOkNm9b8fW6J45vYLkejQUuEmVRuSga1hYfRHKWbzQMHCoc6tWCpRZcCzb34TYUrgYIZinAK8aMhkAxJU44eTHrHwgn6cHXw0fdNOnmku0fclAKVm6pck6xjxQqilo7zDwWJZDrzxktEwNfKKZRSbCt6gEaZdX2aFNxt0nDTdq)QGGN8ONEZc(4RJjL0njg60BwoMxt0nDTdq)cUzDCgPrZ(gfk6cHfTl)nA4bmpu0UgDXXjAhHpGxJMyhpRYdrx8OvNJG0pAKVm6pck6xjxQqilo7zDwWJZDrzxktEwNfKKZRSbCt6gEaZdX2aF)xKuMuNJG0V(qm8PebsVUCZ7IFmVMOB6AhG(fCx84msJM9(u0E0OmJuq8OnarGO5KNHgaIOvikAcqCehIwH40dTsrC2Z6SGhN7IYUuM8SolijNxzd4M0nkZifSnW3eG4ioufe8Kh90BCD(4OsQ(k5sfkPqC6HwPioJ0Oz)VgOxJ(IplF0drpGODPm6foAfIIUWIez)hnkLDMNIE0OZoZtF0E0SFzLcfN9Sol4X5UiNNDaL0LZjGY2aFtaIJ4qvqWtE0cUzPy4qaIJ4qLtiiqC2Z6SGhN7ICE2bu6Ir(uC2Z6SGhN7IKdci9tSlyeimjGgNJZin6YzgPG4FC2Z6SGVIYmsX9dXWNsei96YnzBGV)lsktQZrq6xWDz4GC1LeqRiK7AIkDbvjGJkjXr)eeFuQErC4L7kv5oOub3LHS4SN1zbFfLzKcCUlcHCxtuPlO4SN1zbFfLzKcCUlc1ZLE1rJZXzKgnRSRuSgaFCgPrZEFk6c5Gmf9cdZQiYIOrj4LtrRqu0Wd)1OXGy4tjcenMUCZOH5Rz0gVCGl2OZRj9rpGAC2Z6SGVMf)9d5I1qs4GmXgZtPfgoHilUzHTb(gpOmWW1hYfRHKWbzQYCDeLbgU(qm8Pebs6YbUyRmxhrzGHRpedFkrGKUCGl2kNm9b8NEZ6AXIZinAKZEbs6)ODjNCXHOzUIgLYoZtrBGIw3Tu0yqUynensEZmpYIM5POXoyIUYp6fgMvrKfrJsWlNIwHOOHh(RrJbXWNseiAmD5MrdZxZOnE5axSrNxt6JEa14SN1zbFnlECUl6pyIUYpTWjb5keBmpLwy4eIS4Mf2g4Bugy46dXWNseiPlh4ITYCDeLbgU(qm8Pebs6YbUyRCY0hWF6nRRflo7zDwWxZIhN7IYUuM8SolijNxzd4M0n9pbY0Z2aFJNxjxQqKO6s5rXQvWGasrLUGQ6KlnaeXzKgnsCxz0WlpAJxoWfB0xCIvX2cfTHrHIgdQqrZjxCiAdqeiAWQrZzaGbGiAmKCno7zDwWxZIhN7IU2vM40Vm8mXg8YtaID0BwyBGVXJ6scO1hYfRHe8Mz(kbCujjIZinA27trB8YbUyJ(ItrJTfkAdqeiAdu0qoUu0kefnbioIdrBaIuiIhnmFnJ(Ax5aqeTHrHwgnAmKC0lpA2fmVgnccqCxkpuJZEwNf81S4X5UOhIHpLiqsxoWflBd8nbioIdfCFs49Oy1kyqaPOsxqvDYLgaIJ5DLI1aO(hmrx5Nw4KGCfQYCDmVRuSga1hYfRHKWbzQMHCoc6l4ML4msJM9(u0yhmrx5h9cIoVRuSgarJChwjE0Wd)1OnAqaPOsxqilAgGK(pAdu0oNIgXoaerRB0x7v0gVCGl2ODGiAXgny1OHCCPOXGCXAiAK8Mz(AC2Z6SGVMfpo3f9hmrx5Nw4KGCfITb(wSAfmiGuuPlOQo5sdaXrKJh1LeqRpedFkrGKUCGl2kbCujjWhF1LeqRpKlwdj4nZ8vc4OssGp(5DLI1aO(qm8Pebs6YbUyRCY0hWxqzi7iYXd9pbYufvURiTWjfIseGmpunD2flhF8Z7kfRbqfvURiTWjfIseGmpu5KPpGVGYqwCgPrJKchTleF0oNIM5ITOFWCrrRqu0lGI2WOqrlxd0RrBSXfQgn79POnarGOfhgaIOH9xjE0kKdIMvqIrli4jpA0lpAWQr)k5sfIerByuOLrJ2bhIMvqI14SN1zbFnlECUlY05LircE5jb5keB5dzjLuNJG0)Mf2g4BUpIeHlb0QleFL56iYvNJG0QoMus3KyOtZRj6MU2bOFvqWtEu8XhpVsUuHir1LYJ51eDtx7a0Vki4jpAb35RKPZoP)IacKfNrA0iPWrd2ODH4J2WiLrlgkAdJcnGOvikAaXoA0SgVpBrZ8u0SRWfk6fen6(F0ggfAz0ODWHOzfKy0oqenyJ(vYLkuno7zDwWxZIhN7ImDEjsKGxEsqUcX2aFZ9rKiCjGwDH4RdOawJxwL7Jir4saT6cXxfmCxNfCepVsUuHir1LYJ51eDtx7a0Vki4jpAb35RKPZoP)IaI4SN1zbFnlECUl6HCXAiHkDb9SnW351eDtx7a0Vki4jpAb3LHZRKlvisuDPmoJ0OzFJcfngsMTOh4ObRgTl5KloeTybeBrZ8u0gVCGl2Onmku0yBHIM5QgN9Sol4RzXJZDrpedFkrGKUCGlw2g4B1LeqRpKlwdj4nZ8vc4OssCuSAfmiGuuPlOQo5sdaXrugy46FWeDLFAHtcYvOkZvC2Z6SGVMfpo3f9qUynKeoitSnW34bLbgU(qUynKeoitvMRJ6ysjDtIHo9Uy4OUKaA9zqvIdZGGQeWrLK4iE4(iseUeqRUq8vMR4SN1zbFnlECUl6A1zbSnW3OmWWvu5UcjZRvo5zfF8rzGHR)bt0v(PfojixHQmxhrokdmC9HCXAiHkDb9vMl8XpVRuSga1hYfRHeQ0f0x5KPpG)0BwWlYIZEwNf81S4X5Uiu5UIemd)aBd8nkdmC9pyIUYpTWjb5kuL5ko7zDwWxZIhN7Iqj(t8sdabBd8nkdmC9pyIUYpTWjb5kuL5ko7zDwWxZIhN7IGhoHk3vW2aFJYadx)dMOR8tlCsqUcvzUIZEwNf81S4X5UihKPx5UmLDPKTb(gLbgU(hmrx5Nw4KGCfQYCfN9Sol4RzXJZDrmpLgLmzJGHPSMaUjDNpKLRYxWKtOs)v2g4B88k5sfIevxkpkwTcgeqkQ0fuvNCPbG4iEqzGHR)bt0v(PfojixHQmxhjaXrCOki4jpAb3SgVXzpRZc(Aw84CxeZtPrjt2aUjD7N4HCU)j4fOPfoDTgioBd8nEqzGHRpKlwdjHdYuL56yExPynaQ)bt0v(PfojixHQCY0hWFkl4noJ0Op5e)q08LbbK8q0Cgjf9chTcXyIoWdjI20vOpAusUgkmrZEFkA4LhnskO01kIoZhLTOxfI4gMNI2WOqrJTfkAxJUSIHt0V65sF0lpAwkgorByuOOD5VrxUCxr0mx14SN1zbFnlECUlI5P0OKjBa3KU9hcxhqFI7Ny5P8YDjBd8TGqzGHRC)elpLxUltccLbgUkwda8XxqOmWW18cemzDWLsdOusqOmWWvMRJQZrqAfICPcvVY6PSMf8XhpccLbgUMxGGjRdUuAaLsccLbgUYCDe5ccLbgUY9tS8uE5Umjiugy46REUub3LvmwLf8IeeekdmCfvURiTWjfIseGmpuzUWhFDmPKUjXqNwC8ISJOmWW1)Gj6k)0cNeKRqvoz6d4lG9eN9Sol4RzXJZDrmpLgLmzd4M0T5bH)j1LZB6G4msJUqeSZi1OHDPe1ZLIgE5rZ8oQKIEuY8lmrZEFkAdJcfn2bt0v(rVWrxiYvOAC2Z6SGVMfpo3fX8uAuY8zBGVrzGHR)bt0v(PfojixHQmx4JVoMus3KyOtldVX54msJgj5)eitFC2Z6SGVs)tGm935fKjGYDLejyPBsSnW3eG4iou1XKs6MmD2PawoIhugy46FWeDLFAHtcYvOkZ1rKJhXQ18cYeq5UsIeS0nPekdhu1jxAaioIhpRZcQ5fKjGYDLejyPBs1bKGLdcifF8HzKYeNYqohbL0XKofrwunD2bzXzpRZc(k9pbY0JZDrOYDfPfoPquIaK5b2g478UsXAau)dMOR8tlCsqUcvzUWhFDmPKUjXqNEZcEJZEwNf8v6FcKPhN7IqW4CX4G0cN8tq8vHIZEwNf8v6FcKPhN7IG3mZtIKFcIpkLqj3KTb(g5)fjLj15ii9RpedFkrG0Rl3SG7YWhFUpIeHlb0QleFDafCs4fzhXtExPynaQ)bt0v(PfojixHQmxhXdkdmC9pyIUYpTWjb5kuL56ibioIdvbbp5rl4M14no7zDwWxP)jqMECUl6IHpWhgaIeQ0FLTb((ViPmPohbPF9Hy4tjcKED5MfCxg(4Z9rKiCjGwDH4RdOGtcVXzpRZc(k9pbY0JZDrkeLyaOldqKGxEMyBGVrzGHRCkxss)NGxEMQmx4JpkdmCLt5ss6)e8YZukVmaL41x9CPtzbVXzpRZc(k9pbY0JZDr856ssPbK(lptXzpRZc(k9pbY0JZDrgwUuGlnGeN(f4GmX2aFJYadxLdmHk3vuF1ZLoL1XzpRZc(k9pbY0JZDrMK5YpKw4KKjpIKGtU5Z2aFtaIJ4WPfhVhrzGHR)bt0v(PfojixHQmxX54msJgjpG5Hi(hN9Sol4RWdyEO7RDLjo9ldptSbV8eGyh9ML4msJgjjUZNjURu0q(hn0GaIEn6l(S8rpeTHrHI2ObbKIK4J(KtaeKdYu0mx14SN1zbFfEaZdHZDreUZNjUReBd8nkdmCfmiG0pHlbqqoitvMR4msJM9hrxrZCfTrdcifv6ck6bo6rJE(OD0LrJw3O5mGOxgTgDH2ObRgnZtrBu5rly4dar0fYbzITOh4OvxsaLerpaDJUqoVu0yqUynuJZEwNf8v4bmpeo3fbgeqkQ0feBd8nYXJ6scOvHZlLEixSgQeWrLKaF8XdkdmC9HCXAijCqMQmxi7OoMus3KyiwLtM(a(coPJCY0hWFQo5sjDmjKqzXzKgn7kJuhXQ6aqe9YO)iOOlKdYu0liA15ii9JwHCnAdJugTCWLIgE5rRqu0cgURZcIEHJ2ObbKIkDbXw0CcMtpu0cg(aqe9LdeK5KRrZUYi1rSA0(hTCbiI2)OldNOvNJG0pAXgny1OHCCPOnAqaPOsxqrZCfTHrHIUWrxYj76aqengKlwdF0iNbiP)J(WYenKJlfTrdcifjXh9jNaiihKPO1Drwno7zDwWxHhW8q4CxeyqaPOsxqSLpKLusDocs)BwyBGVXdUoFCujvzEkDXNLp6HeFvxNfC8ViPmPohbPF9Hy4tjcKED5MfCx2rK7NG4JsvWGas)eUeab5GmvjGJkjb(4Jh)eeFuQYPl5KDDaispKlwdFLaoQKe4J)FrszsDocs)6dXWNsei96YnzvpRdUusSAfmiGuuPlOcUldzhXdkdmC9HCXAijCqMQmxh1XKs6MedvWnYlgoiVmKqEnr301oa9rgYoYjyo9qoQKIZin6chbZPhkAJgeqkQ0fu0KZLhIEGJE0Onmsz0e7CnCkAbdFaiIg7Gj6k)A0fAJwHCnAobZPhk6boASTqrJG0pAo5IdrpGOvikAaXoA0f7RXzpRZc(k8aMhcN7Iadcifv6cITb(MtM(a(tZ7kfRbq9pyIUYpTWjb5kuLtM(aECybVhZ7kfRbq9pyIUYpTWjb5kuLtM(a(tVl2rDmPKUjXqSkNm9b8fK3vkwdG6FWeDLFAHtcYvOkNm9b84uS4msJgJYCsJ2ykdbMtgdfTGHpaerJDWeDLFnA23OqrxiNxkAmixSgIEbYdrly4dar0yqUyneDHCqMIg5maDKrRqC6HwPi6benGyhnA5aiKvJZEwNf8v4bmpeo3f9uMtAsPmeyozmeBd8nkdmC9pyIUYpTWjb5kuL56iYXJ6scOvHZlLEixSgQeWrLKaF8rzGHRpKlwdjHdYuL5czXzKgn7BuOOjWYGakA15ii9J2Lg8dF0mpfngLnMYrVGOzLcvJZEwNf8v4bmpeo3f9uMtAsPmeyozmeBd89FrszsDocs)6dXWNsei96Ynl4UmCuxsaTkCEP0d5I1qLaoQKe4OUKaAfmiG0xDzjIxjGJkjrC2Z6SGVcpG5HW5Uic35Ze3vkohNrA0yk5sfkAwzxPyna(4msJMDPK8I4rFYD(4Osko7zDwWxFLCPcLYI)gxNpoQKyd4M09djskeNEOvkydxxYq35DLI1aO(qUynKeoit1mKZrqFcM7zDwGll4MLAHVyXzKg9j3bZdfndqs)hTbkANtr7OlJgTUrN9ROxq0fYbzk6mKZrqFnA2pa5HOnarGOrYdqen7J8sa6)ONpAhDz0O1nAodi6LrRXzpRZc(6RKlvOuw84CxeUoyEi2g4B8GRZhhvs1hsKuio9qRuCmVMOB6AhG(vbbp5rlGLJccLbgUcparYa5La0)voz6d4pLL4msJgjURmA4LhngKlwdMKuenorJb5I1WR8Pefndqs)hTbkANtr7OlJgTUrN9ROxq0fYbzk6mKZrqFnA2pa5HOnarGOrYdqen7J8sa6)ONpAhDz0O1nAodi6LrRXzpRZc(6RKlvOuw84Cx01UYeN(LHNj2GxEcqSJEZcBe7OCp5MldqVloEJZEwNf81xjxQqPS4X5UOhYfRbtskyBGVjaXrCOG7IJ3JeG4ioufe8KhTGBwW7r8GRZhhvs1hsKuio9qRuCmVMOB6AhG(vbbp5rlGLJccLbgUcparYa5La0)voz6d4pLL4msJMvqIrZPtgZWjtcOfMOlKdYu0UgTCnenRGeJg9q0cc2zKAno7zDwWxFLCPcLYIhN7IW15JJkj2aUjD)qIuEnr301oa9zdxxYq351eDtx7a0Vki4jpAb3fpoJ0OzfKy0C6KXmCYKaAHj6c5Gmf9cKhIgLGxofn8aMhI4F0dC0gOOHCCPODZROvxsa9J2bIOV4ZYh9q08vDDwqno7zDwWxFLCPcLYIhN7IW15JJkj2aUjD)qIuEnr301oa9zdxxYq351eDtx7a0Vki4jp6P3SGtzib)eeFuQQqucE4VMeoitvc4OssW2aFJRZhhvsvMNsx8z5JEiXx11zbhrU6scOvWGasF1LLiELaoQKe4JV6scOvHZlLEixSgQeWrLKazXzKgn7BuOOlKZlfngKlwdrVa5HOlKdYu0gGiq0gniGuuPlOOnmsz0V6hIM5Qgn79POfm8bGiASdMOR8JE5r7OlUu0keNEOvkQrZ(8rJgE5rB0jpAugy4Onmku0LHJrN8AC2Z6SGV(k5sfkLfpo3f9qUynKeoitSnW3468XrLu9HeP8AIUPRDa6Fe54rDjb0QW5LspKlwdvc4OssGp(IvRGbbKIkDbv5KPpGVG7IHJ6scO1NbvjomdcQsahvscKDe5468XrLu9HejfItp0kf4JpkdmC9pyIUYpTWjb5kuLtM(a(cUzPwg(4)xKuMuNJG0V(qm8PebsVUCZcUl(X8UsXAau)dMOR8tlCsqUcv5KPpGVawWlYoIC)eeFuQcgeq6NWLaiihKPk3bLoTm8XhLbgUcgeq6NWLaiihKPkZfYIZin6Yz4GO5KPpGbGi6c5Gm9rJsWlNIwHOOvNJG0Ofd9rpWrJTfkAdlajHgnkfnNCXHOhq06ys14SN1zbF9vYLkuklECUl6HCXAijCqMyBGVX15JJkP6djs51eDtx7a0)OoMus3KyOtZ7kfRbq9pyIUYpTWjb5kuLtM(a(J4H7Jir4saT6cXxzUIZXzKgnMsUuHir0fUvDDwqCgPrJKchnMsUuHkcxhmpu0oNIM5ITOzEkAmixSgELpLOO1nAucqWJgnmFnJwHOOV8)hCPOrxaZhTderJKhGiA2h5La0)SfnHlbIEGJ2afTZPODnAtNDIMvqIrJCy(AgTcrrFXP8AI6A0SRWfcz14SN1zbF9vYLkejUFixSgELpLi2g4BKRUKaAfEaIKbYlbO)ReWrLKaF8)lsktQZrq6xFig(uIaPxxU5PSgzhrokdmC9vYLkuL5cF8rzGHR46G5HQmxiloJ0OrYdyEOODnAwJt0ScsmAdJcTmA0fcl6IIU44eTHrHIUqyrByuOOXGy4tjceTXlh4InAugy4OzUIw3ODC3re9VMu0ScsmAd(Ru0)OmUol4RXzpRZc(6RKlvisGZDrzxktEwNfKKZRSbCt6gEaZdX2aFJYadxFig(uIajD5axSvMRJ51eDtx7a0Vki4jp6P3LfNrA0fw5Vr)omfTUrdpG5HI21OloorZkiXOnmku0e74zvEi6IhT6CeK(1OroMBsr7F0lJ(JGI(vYLkufzXzpRZc(6RKlvisGZDrzxktEwNfKKZRSbCt6gEaZdX2aF)xKuMuNJG0V(qm8PebsVUCZ7IFmVMOB6AhG(fCx84msJgjpG5HI21OloorZkiXOnmk0YOrxim2IUy4eTHrHIUqySfTderFsrByuOOlew0oSs8Op5oyEOOxE0gdrrJKh(RrxihKPODGiAWgDHCEPOXGCXAiACIgSrJXGQehMbbfN9Sol4RVsUuHibo3fLDPm5zDwqsoVYgWnPB4bmpeBd8DEnr301oa9RccEYJE6nlSkYvxsaTki6I4Px5U6iiZkbCujjoICugy4kUoyEOkZf(47NG4JsvfIsWd)1KWbzQsahvsIJ4rDjb0QW5LspKlwdvc4OssCepQljGwFguL4WmiOkbCujjo(xKuMuNJG0V(qm8PebsVUCZtznYqwCgPrZEFkA2VYDnrLUGIEXL4rJb5I1WR8PefTderJPl3mAdJcfDz4ensK4Wl3vkAxJUSOxE0s6)OvNJG0VgN9Sol4RVsUuHibo3fHqURjQ0feBd8TFcIpkvVio8YDLQChuQG7Yo(xKuMuNJG0V(qm8PebsVUCZtVlloJ0OlSA0LfT6CeK(rByuOOXOmN0OnMYqG5KXqrxIOROzUIgjpar0SpYlbO)Jg9q05dz5aqengKlwdVYNsuno7zDwWxFLCPcrcCUl6HCXA4v(uIylFilPK6CeK(3SW2aFRUKaA9PmN0KsziWCYyOkbCujjoQUKaAfEaIKbYlbO)ReWrLK4OGqzGHRWdqKmqEja9FLtM(a(tz54FrszsDocs)6dXWNsei96YnVl7OoMus3KyiwLtM(a(coP4msJM9nk0YOrxiIUiE0yk3vhbzgTderZ6OlCoO0h9chD5sxqrpGOvikAmixSg(Ohn65J2WYvOOz(bGiAmixSgELpLOOxq0SoA15ii9RXzpRZc(6RKlvisGZDrpKlwdVYNseBd8nEuxsaTki6I4Px5U6iiZkbCujjo6NG4JsvuPlO0askeLEixSg(k3bLUz9X)IKYK6CeK(1hIHpLiq61LBEZ64msJgjV8OV4ZYh9q08vDDwaBrZ8u0yqUyn8kFkrrV4s8OX0LBgnlilAdJcfn7JDnAhHpGxJM5kADJU4rRohbPpBrxgYIEGJgjZ(IE(O5maWaqe9cdhnYxq0o4q0U5Ya0Ox4OvNJG0hzSf9YJM1ilADJ20zNXCobfn2wOOj2rjWpliAdJcfnskGWDuhDKJEi6fenRJwDocs)OrEXJ2WOqrx(OyiRgN9Sol4RVsUuHibo3f9qUyn8kFkrSnW3468XrLuL5P0fFw(Ohs8vDDwWrKRUKaAfEaIKbYlbO)ReWrLK4OGqzGHRWdqKmqEja9FLtM(a(tzbF8vxsaTAG8Rfy6Vs8kbCujjo(xKuMuNJG0V(qm8PebsVUCZtVlo(47NG4Js1bq4oQJoYrpujGJkjXrugy46FWeDLFAHtcYvOkZ1X)IKYK6CeK(1hIHpLiq61LBE6nRXXpbXhLQOsxqPbKuik9qUyn8vc4OssGS4SN1zbF9vYLkejW5UOhIHpLiq61LBY2aF)xKuMuNJG0VGBwhN9Sol4RVsUuHibo3f9qUyn8kFkrwS)IYwJk7KyXQw1Ab]] )


end
