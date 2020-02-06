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


    spec:RegisterPack( "Subtlety", 20200206, [[davtNbqiOGhbfAtsKpPcOmkOOofuKvbcPxbLAwOQClkeTlj9ljuddeCmuLwMe0Zqv00ur4Asi2gfs(MkIY4qviNdvHY6urKMNks3dK2hfQ)bcvLoOkIQfQc6HuimrjKUiiuLnccLpsHuXibHQItccvwPkQxsHuPzsHuLBIQq1orv1pPqQQHccXsvbWtHQPkbUkfszRQiIVQciNfeQQ2lL(RidwQdt1IH0Jf1KjCzKndXNvPgnOoTIvRcO61QqZMOBtr7wv)wPHRsoUkaTCuEoW0jDDuz7qjFNcgpQcoVe16vbA(GO9lSLxBbwCHRKL)cHqHqacfcbJQYBrGap5zHwCT8fzXV88r)MS4VBswCCouvsAzl(LxwUUWwGfhSCSmzXHv9cCslU47rH5qR51SyWyYjDD2pZCeTyWyMl2IJYnsfI7TOwCHRKL)cHqHqacfcbJQYBrGaplKhzXDofEzwC8X0iS4WJqqVf1Iliq2IJXOX5qvjPLJ(aS3CuCgJrdR6f4KwCX3JcZHwZRzXGXKt66SFM5iAXGXmxCCgJrdXiugNZkhTrXx0fcHcHqCooJXOncy)VjWjnoJXOnYOp5cbjI2O7KpgTUrlieNtQr7zD2pA5a0ACgJrBKrFaiZflseT6SBstds059fJo7h9(rZJ7SJKiAKLfDrjxHRXzmgTrg9jxiir0gnafneNsMGQfxoafylWIduYLkmjSfy5NxBbwC6DujjShAXZSrj24wCmhT6s61kY8IKbYp(eauP3rLKiAiHmAWfjLj1z3KcQayo2CK(eqxMz0NgnpJgtrxkAmhnkhcsfOKlv4k3v0qcz0OCiivS8FaWvUROXKf3Z6SVfha7I1aqzZrYQw(l0wGfNEhvsc7Hw8mBuInUfhLdbPcG5yZr6t6YExSvUROlfDEnr301oVcQcczYJg9PqJUqlUN1zFlE2LYKN1z)KCaQfxoan9UjzXrMFaWw1YppTfyXP3rLKWEOfpZgLyJBXbxKuMuNDtkOcG5yZr6taDzMrdn6teDPOZRj6MU25vq0gdn6tyX9So7BXZUuM8So7NKdqT4YbOP3njloY8da2Qw(pHTalo9oQKe2dT4z2OeBClEEnr301oVcQcczYJg9PqJM3OnYOXC0QlPxRcIUiwcOmx9BYSsVJkjr0LIgZrJYHGuXY)bax5UIgsiJ2piXgLQkmLqggqtc)ZuLEhvsIOlfngIwDj9Av4SJjaSlwdv6DujjIUu0yiA1L0RvahQsmeUBQsVJkjr0LIgCrszsD2nPGkaMJnhPpb0Lzg9PrZZOXu0yYI7zD23INDPm5zD2pjhGAXLdqtVBswCK5haSvT8xeBbwC6DujjShAXZSrj24wC)GeBuQErmKL5kvz(FmAJHgDHrxkAWfjLj1z3KcQayo2CK(eqxMz0Ncn6cT4EwN9T43YDnrLUGSQLFJYwGfNEhvsc7HwCpRZ(wCaSlwdaLnhjlEMnkXg3IRUKETcOmJ0Ksz4FoGCuLEhvsIOlfT6s61kY8IKbYp(eauP3rLKi6srliuoeKkY8IKbYp(eauzKPppi6tJM3Olfn4IKYK6SBsbvamhBosFcOlZmAOrxy0LIwhtkPBsmu0gz0mY0NheTXrBuw8C5SKsQZUjfy5NxRA5)KzlWItVJkjH9qlEMnkXg3IJHOvxsVwfeDrSeqzU63KzLEhvsIOlfTFqInkvrLUGsZNuykbGDXAauz(FmAOrZZOlfn4IKYK6SBsbvamhBosFcOlZmAOrZtlUN1zFloa2fRbGYMJKvT8ZJSfyXP3rLKWEOfpZgLyJBXXYzJJkPkhGsxSzzJwoXw11z)OlfnMJwDj9AfzErYa5hFcaQ07OsseDPOfekhcsfzErYa5hFcaQmY0Nhe9PrZB0qcz0QlPxRgi)AFthOeRsVJkjr0LIgCrszsD2nPGkaMJnhPpb0Lzg9PqJ(erdjKr7hKyJs15jSg1rh5OLR07OsseDPOr5qqQGYMOReKwKKGCfUYDfDPObxKuMuNDtkOcG5yZr6taDzMrFk0O5z0yhTFqInkvrLUGsZNuykbGDXAauP3rLKiAmzX9So7BXbWUynau2CKSQLFEmBbwC6DujjShAXZSrj24wCWfjLj1z3KcI2yOrZtlUN1zFloaMJnhPpb0LzAvl)8cbBbwCpRZ(wCaSlwdaLnhjlo9oQKe2dTQvT4eaqFMa2cS8ZRTalo9oQKe2dT4z2OeBClo9e7UCvhtkPBY05HOnoAEJUu0yiAuoeKkOSj6kbPfjjixHRCxrxkAmhngIwSAnVFMEL5kjsis3KsOCSVQt(483rxkAmeTN1z)AE)m9kZvsKqKUjvNpHiNBynAiHmAeoPmXOmSZUPKoMu0Ng9DwunDEiAmzX9So7BXZ7NPxzUsIeI0njRA5VqBbwC6DujjShAXZSrj24wCmeDExPyn8vaSlwdjuPliqL7k6srN3vkwdFfu2eDLG0IKeKRWvUROHeYO1XKs6Medf9PqJMxiyX9So7BXrL7kslssHPe9KzzRA5NN2cS4EwN9T43Cotm(NwKKFqITkSfNEhvsc7Hw1Y)jSfyXP3rLKWEOfpZgLyJBXXC0GlsktQZUjfubWCS5i9jGUmZOngA0fgnKqgnZhrIWIET6cbOoF0ghTrbHOXu0LIgdrN3vkwdFfu2eDLG0IKeKRWvUROlfngIgLdbPckBIUsqArscYv4k3v0LIMEIDxUkiKjpA0gdnAEcblUN1zFloYM5aKi5hKyJsjuYnTQL)IylWItVJkjH9qlEMnkXg3IdUiPmPo7MuqfaZXMJ0Na6YmJ2yOrxy0qcz0mFejcl61QleG68rBC0gfeS4EwN9T4xCSbP883juPduRA53OSfyXP3rLKWEOfpZgLyJBXr5qqQmkFusaqczzzQYDfnKqgnkhcsLr5JscasilltP8Y9kXQa1ZhJ(0O5fcwCpRZ(wCfMsCp6Y9IeYYYKvT8FYSfyX9So7BXzZ1LKsZNaxEMS407Ossyp0Qw(5r2cS407Ossyp0INzJsSXT45DLI1WxbLnrxjiTijb5kCLrM(8GOpn6IenKqgToMus3KyOOpnAE5rwCpRZ(wCdltkWIMpXiW((NjRA5NhZwGfNEhvsc7Hw8mBuInUfNEIDxo6tJ(eqi6srJYHGubLnrxjiTijb5kCL7YI7zD23IBsMlRCArssU8iscg5MaRA5NxiylWItVJkjH9qlEMnkXg3IRo7M0km5sfUEL1OnoAEeeIgsiJwD2nPvyYLkC9kRrFk0OlecrdjKrRo7M0QoMus30vwtfcHOnoAEcblUN1zFloJ8R5Vtis3Kaw1QwCbH4Cs1wGLFETfyXP3rLKWEOfpZgLyJBXXq0aLCPctIkBV5ilUN1zFl(XjF0Qw(l0wGf3Z6SVfhOKlvylo9oQKe2dTQLFEAlWItVJkjH9qlUN1zFlE2LYKN1z)KCaQfxoan9UjzXZcGvT8FcBbwC6DujjShAXZSrj24wCGsUuHjr1LslUN1zFloJ7tEwN9tYbOwC5a007MKfhOKlvysyvl)fXwGfNEhvsc7Hw8mBuInUfxhtkPBsmu0ghTrfDPOzKPppi6tJ(olQMopeDPOZRj6MU25vq0gdn6teTrgnMJwhtk6tJMxienMIgIgDHwCpRZ(w8FUHvuPliRA53OSfyXP3rLKWEOfFVS4asT4EwN9T4y5SXrLKfhlxYrw8l2SSrlNyR66SF0LIgCrszsD2nPGkaMJnhPpb0LzgTXqJUqlowol9UjzX5au6InlB0Yj2QUo7Bvl)NmBbwC6DujjShAXZSrj24wCSC24OsQYbO0fBw2OLtSvDD23I7zD23INDPm5zD2pjhGAXLdqtVBswCGsUuHtzbWQw(5r2cS407Ossyp0IVxwCaPwCpRZ(wCSC24OsYIJLl5ilEHfjASJwDj9AfR5Ezv6DujjIgIgnpls0yhT6s61QPduILwKea2fRbqLEhvsIOHOrxyrIg7OvxsVwbWUynKq2mhOsVJkjr0q0OlecrJD0QlPxRU0ZSrlxP3rLKiAiA08cHOXoAEls0q0OXC0GlsktQZUjfubWCS5i9jGUmZOngA08mAmzXXYzP3njloqjxQWjfMra4vkSQLFEmBbwC6DujjShAXZSrj24wC6j2D5QGqM8OrFk0OXYzJJkPkqjxQWjfMra4vkS4EwN9T4zxktEwN9tYbOwC5a007MKfhOKlv4uwaSQLFEHGTalo9oQKe2dT4z2OeBClUFqInkv)5gwbjSO)M8ptv6DujjIUu0yiAuoeK6p3WkiHf93K)zQYDfDPOZRj6MU25vqvqitE0OnoAEJUu0yoAWfjLj1z3KcQayo2CK(eqxMz0NgDHrdjKrJLZghvsvoaLUyZYgTCITQRZ(rJPOlfnMJoVRuSg(kOSj6kbPfjjixHRmY0Nhe9PqJMNrdjKrJ5O9dsSrP6p3WkiHf93K)zQY8)y0gdn6cJUu0OCiivqzt0vcslssqUcxzKPppiAJJMNrxkAmenqjxQWKO6sz0LIoVRuSg(ka2fRHKW)mvZWo7MajeMN1zFxgTXqJgcvESOXu0yYI7zD23I)ZnSIkDbzvl)8YRTalo9oQKe2dT4z2OeBClEEnr301oVcQcczYJg9PqJM3OHeYO1XKs6Medf9PqJM3OlfDEnr301oVcI2yOrZtlUN1zFlE2LYKN1z)KCaQfxoan9UjzXrMFaWw1YpVfAlWItVJkjH9qlEMnkXg3IdUiPmPo7MuqfaZXMJ0Na6YmJgA0Ni6srNxt0nDTZRGOngA0NWI7zD23INDPm5zD2pjhGAXLdqtVBswCK5haSvT8ZlpTfyXP3rLKWEOfpZgLyJBXPNy3LRcczYJg9PqJglNnoQKQaLCPcNuygbGxPWI7zD23INDPm5zD2pjhGAXLdqtVBswCuUrkSQLFEpHTalo9oQKe2dT4z2OeBClo9e7UCvqitE0OngA08wKOXoA6j2D5kJUP3I7zD23I7SS)usxgJE1Qw(5Ti2cS4EwN9T4ol7pLU4KaYItVJkjH9qRA5NxJYwGf3Z6SVfxo3WkiDGZjUnPxT407Ossyp0Qw(59KzlWI7zD23IJ63PfjPSjFeyXP3rLKWEOvT8ZlpYwGfNEhvsc7Hw8mBuInUfNoGCZ1fjQugEN)oH1oIOHeYOPdi3CDrIkLH35VtyTJiTWwCpRZ(wCbPuwN9TQvT4xmkVMOUAlWYpV2cS4EwN9T4aLCPcBXP3rLKWEOvT8xOTalo9oQKe2dT4EwN9T4Mo7ijsilljixHT4xmkVMOUMauEFbWIZBrSQLFEAlWItVJkjH9ql(7MKf3pia2zoiHSVMwK01AGywCpRZ(wC)GayN5GeY(AArsxRbIzvl)NWwGf3Z6SVf)A1zFlo9oQKe2dTQvT4iZpayBbw(51wGfNEhvsc7HwCKLLEIhul)8AX9So7BXV2vMyey5yzYQw(l0wGfNEhvsc7Hw8mBuInUfhLdbP(ZnScsyr)n5FMQCxwCpRZ(wCcRbKjMRKvT8ZtBbwC6DujjShAXZSrj24wCmhngIwDj9Av4SJjaSlwdv6DujjIgsiJgdrJYHGubWUynKe(NPk3v0yk6srRJjL0njgkAJmAgz6ZdI24OnQOlfnJm95brFA06KpM0XKIgIgDHwCpRZ(w8FUHvuPliRA5)e2cS407Ossyp0I7zD23I)ZnSIkDbzXZSrj24wCmenwoBCujv5au6InlB0Yj2QUo7hDPObxKuMuNDtkOcG5yZr6taDzMrBm0Olm6srJ5O9dsSrP6p3WkiHf93K)zQsVJkjr0qcz0yiA)GeBuQYOl5KDD(7ea2fRbqLEhvsIOHeYObxKuMuNDtkOcG5yZr6taDzMrBKr7zDWIsIvR)CdROsxqrBm0OlmAmfDPOXq0OCiivaSlwdjH)zQYDfDPO1XKs6MedfTXqJgZrxKOXoAmhDHrdrJoVMOB6ANxbrJPOXu0LIMrimca7OsYINlNLusD2nPal)8Avl)fXwGfNEhvsc7Hw8mBuInUfNrM(8GOpn68UsXA4RGYMOReKwKKGCfUYitFEq0yhnVqi6srN3vkwdFfu2eDLG0IKeKRWvgz6ZdI(uOrxKOlfToMus3KyOOnYOzKPppiAJJoVRuSg(kOSj6kbPfjjixHRmY0Nhen2rxelUN1zFl(p3WkQ0fKvT8Bu2cS4EwN9T4akZinPug(NdihzXP3rLKWEOvT8FYSfyX9So7BXjSgqMyUswC6DujjShAvRAXZcGTal)8AlWItVJkjH9qlEMnkXg3IJHOr5qqQayxSgsc)ZuL7k6srJYHGubWCS5i9jDzVl2k3v0LIgLdbPcG5yZr6t6YExSvgz6ZdI(uOrZZArS4EwN9T4ayxSgsc)ZKfNdqPfbjDNfw(51Qw(l0wGfNEhvsc7Hw8mBuInUfhLdbPcG5yZr6t6YExSvUROlfnkhcsfaZXMJ0N0L9UyRmY0Nhe9PqJMN1IyX9So7BXbLnrxjiTijb5kSfNdqPfbjDNfw(51Qw(5PTalo9oQKe2dT4z2OeBClogIgOKlvysuDPm6srlwT(ZnSIkDbv1jFC(BlUN1zFlE2LYKN1z)KCaQfxoan9UjzXjaG(mbSQL)tylWItVJkjH9qlUN1zFl(1UYeJalhltw8mBuInUfhdrRUKETcGDXAiHSzoqLEhvscloYYspXdQLFETQL)IylWItVJkjH9qlEMnkXg3ItpXUlhTXqJ2OGq0LIwSA9NByfv6cQQt(483rxk68UsXA4RGYMOReKwKKGCfUYDfDPOZ7kfRHVcGDXAij8pt1mSZUjq0gdnAET4EwN9T4ayo2CK(KUS3fRvT8Bu2cS407Ossyp0INzJsSXT4IvR)CdROsxqvDYhN)o6srJHOZ7kfRHVcGDXAiHkDbbQCxrxkAmhngIwDj9AfaZXMJ0N0L9UyR07OssenKqgT6s61ka2fRHeYM5av6DujjIgsiJoVRuSg(kaMJnhPpPl7DXwzKPppiAJJUWOXu0LIgZrJHOjaG(mvrL7kslssHPe9Kz5QPFGVSOHeYOZ7kfRHVIk3vKwKKctj6jZYvgz6ZdI24OlmAmfDPOXC0(bj2Ou9NByfKWI(BY)mvz(Fm6tJUWOHeYOr5qqQ)CdRGew0Ft(NPk3v0yYI7zD23IdkBIUsqArscYvyRA5)KzlWItVJkjH9qlUN1zFlUPZosIeYYscYvylEMnkXg3IZ8rKiSOxRUqaQCxrxkAmhT6SBsR6ysjDtIHI(0OZRj6MU25vqvqitE0OHeYOXq0aLCPctIQlLrxk68AIUPRDEfufeYKhnAJHgD(kz68qcCrViAmzXZLZskPo7MuGLFETQLFEKTalo9oQKe2dT4z2OeBCloZhrIWIET6cbOoF0ghnpHq0gz0mFejcl61QleGQGJ56SF0LIgdrduYLkmjQUugDPOZRj6MU25vqvqitE0OngA05RKPZdjWf9clUN1zFlUPZosIeYYscYvyRA5NhZwGfNEhvsc7Hw8mBuInUfhdrduYLkmjQUugDPOfRw)5gwrLUGQ6Kpo)D0LIoVMOB6ANxbvbHm5rJ2yOrxOf3Z6SVfha7I1qcv6ccyvl)8cbBbwC6DujjShAXZSrj24wC1L0RvaSlwdjKnZbQ07OsseDPOfRw)5gwrLUGQ6Kpo)D0LIgLdbPckBIUsqArscYv4k3Lf3Z6SVfhaZXMJ0N0L9UyTQLFE51wGfNEhvsc7Hw8mBuInUfhdrJYHGubWUynKe(NPk3v0LIwhtkPBsmu0Ncn6Ien2rRUKETc4qvIHWDtv6DujjIUu0yiAMpIeHf9A1fcqL7YI7zD23IdGDXAij8ptw1YpVfAlWItVJkjH9qlEMnkXg3IJYHGurL7kKCaTYipRrdjKrJYHGubLnrxjiTijb5kCL7k6srJ5Or5qqQayxSgsOsxqGk3v0qcz05DLI1WxbWUynKqLUGavgz6ZdI(uOrZleIgtwCpRZ(w8RvN9TQLFE5PTalo9oQKe2dT4z2OeBClokhcsfu2eDLG0IKeKRWvUllUN1zFloQCxrcHJv2Qw(59e2cS407Ossyp0INzJsSXT4OCiivqzt0vcslssqUcx5US4EwN9T4OedqSJZFBvl)8weBbwC6DujjShAXZSrj24wCuoeKkOSj6kbPfjjixHRCxwCpRZ(wCKHrOYDfw1YpVgLTalo9oQKe2dT4z2OeBClokhcsfu2eDLG0IKeKRWvUllUN1zFlU)zcOmxMYUuAvl)8EYSfyXP3rLKWEOf3Z6SVfpxolxLT)KtOshOw8mBuInUfhdrduYLkmjQUugDPOfRw)5gwrLUGQ6Kpo)D0LIgdrJYHGubLnrxjiTijb5kCL7k6srtpXUlxfeYKhnAJHgnpHGfNqqOSME3KS45Yz5QS9NCcv6a1Qw(5LhzlWItVJkjH9qlUN1zFlUFqaSZCqczFnTiPR1aXS4z2OeBClogIgLdbPcGDXAij8ptvUROlfDExPyn8vqzt0vcslssqUcxzKPppi6tJMxiyXF3KS4(bbWoZbjK910IKUwdeZQw(5LhZwGfNEhvsc7HwCpRZ(wChaJL)eiX8dUSuEzU0INzJsSXT4ccLdbPY8dUSuEzUmjiuoeKQyn8rdjKrliuoeKAEFbxwhSO08htccLdbPYDfDPOvNDtAvhtkPB6kRjEcHOpn6IenKqgngIwqOCii18(cUSoyrP5pMeekhcsL7k6srJ5OfekhcsL5hCzP8YCzsqOCiivG65JrBm0OlSirBKrZleIgIgTGq5qqQOYDfPfjPWuIEYSCL7kAiHmADmPKUjXqrFA0NacrJPOlfnkhcsfu2eDLG0IKeKRWvgz6ZdI24O5rw83njlUdGXYFcKy(bxwkVmxAvl)fcbBbwC6DujjShAXF3KS4MLfoiPUCaM(BX9So7BXnllCqsD5am93Qw(lKxBbwC6DujjShAXZSrj24wCuoeKkOSj6kbPfjjixHRCxrdjKrRJjL0njgk6tJUqiyX9So7BX5auAuYeyvRAXbk5sfoLfaBbw(51wGfNEhvsc7Hw89YIdi1I7zD23IJLZghvswCSCjhzXZ7kfRHVcGDXAij8pt1mSZUjqcH5zD23LrBm0O5TEYkIfhlNLE3KS4ayrsHzeaELcRA5VqBbwC6DujjShAXZSrj24wCmenwoBCujvbWIKcZia8kfrxk68AIUPRDEfufeYKhnAJJM3OlfTGq5qqQiZlsgi)4taqLrM(8GOpnAEJUu05DLI1WxbLnrxjiTijb5kCLrM(8GOngA080I7zD23IJL)da2Qw(5PTalo9oQKe2dT4EwN9T4x7ktmcSCSmzXjEqzEYnxUxT4NacwCKLLEIhul)8Avl)NWwGfNEhvsc7Hw8mBuInUfNEIDxoAJHg9jGq0LIMEIDxUkiKjpA0gdnAEHq0LIgdrJLZghvsvaSiPWmcaVsr0LIoVMOB6ANxbvbHm5rJ24O5n6srliuoeKkY8IKbYp(eauzKPppi6tJMxlUN1zFloa2fRbtskSQL)IylWItVJkjH9ql(EzXbKAX9So7BXXYzJJkjlowUKJS451eDtx78kOkiKjpA0gdn6tyXXYzP3njloawKYRj6MU25vGvT8Bu2cS407Ossyp0IVxwCaPwCpRZ(wCSC24OsYIJLl5ilEEnr301oVcQcczYJg9PqJM3OXo6cJgIgTFqInkvvykHmmGMe(NPk9oQKew8mBuInUfhlNnoQKQCakDXMLnA5eBvxN9JUu0yoA1L0R1FUHvG6YJeRsVJkjr0qcz0QlPxRcNDmbGDXAOsVJkjr0yYIJLZsVBswCaSiLxt0nDTZRaRA5)KzlWItVJkjH9qlEMnkXg3IJLZghvsvaSiLxt0nDTZRGOlfnMJgdrRUKETkC2Xea2fRHk9oQKerdjKrlwT(ZnSIkDbvzKPppiAJHgDrIg7OvxsVwbCOkXq4UPk9oQKerJPOlfnMJglNnoQKQayrsHzeaELIOHeYOr5qqQGYMOReKwKKGCfUYitFEq0gdnAERfgnKqgn4IKYK6SBsbvamhBosFcOlZmAJHg9jIUu05DLI1WxbLnrxjiTijb5kCLrM(8GOnoAEHq0yk6srJ5O9dsSrP6p3WkiHf93K)zQY8)y0NgDHrdjKrJYHGu)5gwbjSO)M8ptvUROXKf3Z6SVfha7I1qs4FMSQLFEKTalo9oQKe2dT4z2OeBClowoBCujvbWIuEnr301oVcIUu06ysjDtIHI(0OZ7kfRHVckBIUsqArscYv4kJm95brxkAmenZhrIWIET6cbOYDzX9So7BXbWUynKe(NjRAvlok3if2cS8ZRTalo9oQKe2dT4z2OeBClo4IKYK6SBsbrBm0OlmASJgZrRUKETEl31ev6cQsVJkjr0LI2piXgLQxedzzUsvM)hJ2yOrxy0yYI7zD23IdG5yZr6taDzMw1YFH2cS4EwN9T43YDnrLUGS407Ossyp0Qw(5PTalUN1zFloQNpcuh1ItVJkjH9qRAvRAXXIyGzFl)fcHcHae4TWtyXn4SF(BGfhIZ8AzkjIMhfTN1z)OLdqb14SfhCrzl)fAu8AXVylYijlogJgNdvLKwo6dWEZrXzmgnSQxGtAXfFpkmhAnVMfdgtoPRZ(zMJOfdgZCXXzmgneJqzCoRC0gfFrxiekecX54mgJ2iG9)MaN04mgJ2iJ(KleKiAJUt(y06gTGqCoPgTN1z)OLdqRXzmgTrg9bGmxSir0QZUjnnirN3xm6SF07hnpUZosIOrww0fLCfUgNXy0gz0NCHGerB0au0qCkzcQX54mgJgIhpqzoLerJsilJIoVMOUgnkDppOg9jpNPlfe9VVrc7mteoz0EwN9brVVSCnoJXO9So7dQxmkVMOUcfr6GJXzmgTN1zFq9Ir51e1vSHwSZDBsV66SFCgJr7zD2huVyuEnrDfBOfJSRioJXOXF)caVA0mFerJYHGqIObQRGOrjKLrrNxtuxJgLUNheT)IOVyKrETQo)D0diAX(unoJXO9So7dQxmkVMOUIn0IbVFbGxnbuxbXzpRZ(G6fJYRjQRydTyGsUuHJZEwN9b1lgLxtuxXgAXMo7ijsilljixH57Ir51e11eGY7laq5TiXzpRZ(G6fJYRjQRydTyoaLgLm57DtcQFqaSZCqczFnTiPR1aXIZEwN9b1lgLxtuxXgAXxRo7hNJZymAiE8aL5usenHfXkhToMu0kmfTN1Lf9aI2XYhPJkPACgJrFaiGsUuHJEqI(AbGbvsrJ5FJglo5tmhvsrtpzoei65JoVMOUIP4SN1zFa0Jt(iFdcumauYLkmjQS9MJIZEwN9bydTyGsUuHJZymAJaMYhJ2ikkiAxJgzyano7zD2hGn0IZUuM8So7NKdq57DtcAwaIZym6da3hncNuwoAGHrZWeiADJwHPOXvYLkmjI(aSQRZ(rJz0Yrl25VJgS8f9OrJSSmbI(Ax583rpir)Rcp)D0diAhlFKoQKWuno7zD2hGn0IzCFYZ6SFsoaLV3njOaLCPctc(geOaLCPctIQlLXzmg9j)6swoA(NByfv6ckAxJUqSJ2iGirl4yZFhTctrJmmGgnVqiAaL3xa4lAhrjw0kSRrFcSJ2iGirpirpA0epCnmceTHrHNpAfMI(jEqJ2OJru0Oxw0di6F1O5UIZEwN9bydT4FUHvuPli(geO6ysjDtIHm2OkXitFEWP3zr105Hs51eDtx78kWyONWiXSoM0P8cbmbrlmoJXOn6)YYrNH9)MIMTQRZ(rpirBGIg2XII(InlB0Yj2QUo7hnG0O9xeTjNuNljfT6SBsbrZDvJZEwN9bydTySC24OsIV3njOCakDXMLnA5eBvxN95dlxYrqVyZYgTCITQRZ(LaxKuMuNDtkOcG5yZr6taDzMgdTW4mgJgIWMLnA5OpaR66SpeFJ2OhPhyGOVhSOO9OZm)kAhD50OPNy3LJgzzrRWu0aLCPchTruuq0ygLBKcIfnqhPmAgbUOSg9OyQgne)Cx8f9OrN9pAukAf21ObJ5LKQXzpRZ(aSHwC2LYKN1z)KCakFVBsqbk5sfoLfa(geOy5SXrLuLdqPl2SSrlNyR66SFCgJrB0aKiADJwqiZtrBaM(O1nAoafnqjxQWrBeffe9YIgLBKcIbIZEwN9bydTySC24OsIV3njOaLCPcNuygbGxPGpSCjhbTWIGT6s61kwZ9YQ07Ossar5zrWwDj9A10bkXslsca7I1aOsVJkjbeTWIGT6s61ka2fRHeYM5av6DujjGOfcbSvxsVwDPNzJwUsVJkjbeLxiGnVfbIIzWfjLj1z3KcQayo2CK(eqxMPXq5jMIZymAJyFWiiw0CG5VJ2JgxjxQWrBefnAdW0hnJ8m883rRWu00tS7YrRWmcaVsrC2Z6SpaBOfNDPm5zD2pjhGY37MeuGsUuHtzbGVbbk9e7UCvqitE0tHILZghvsvGsUuHtkmJaWRueNXy08p3W6bgi6tc93K)z6Kgn)ZnSIkDbfnkHSmkA8YMOReeTRrlxdrBeqKO1n68AIopfn5mz5OzecJaWrByu4OVjvN)oAfMIgLdbjAURA0NCjyJwUgI2iGirl4yZFhnEzt0vcIgLude9rxu)ZeiAdJchDHyhn)NKAC2Z6SpaBOf)ZnSIkDbX3Ga1piXgLQ)CdRGew0Ft(NPk9oQKeLWakhcs9NByfKWI(BY)mv5UkLxt0nDTZRGQGqM8OgZBjmdUiPmPo7MuqfaZXMJ0Na6YmpTqiHelNnoQKQCakDXMLnA5eBvxN9XujmN3vkwdFfu2eDLG0IKeKRWvgz6ZdofkpHesm7hKyJs1FUHvqcl6Vj)ZuL5)rJHwyjuoeKkOSj6kbPfjjixHRmY0NhymplHbGsUuHjr1LYs5DLI1WxbWUynKe(NPAg2z3eiHW8So77sJHcHkpgMWuCgJrdXMFaWr7A0Na7Onmk8YPrxuC(IUiyhTHrHJUO4rJ5LtbJGIgOKlvymfN9So7dWgAXzxktEwN9tYbO89Ujbfz(baZ3GanVMOB6ANxbvbHm5rpfkVqcPoMus3KyOtHYBP8AIUPRDEfymuEgNXy0hOrHJUO4r7sWgnY8daoAxJ(eyhTF7Zd0OjEWZQSC0NiA1z3KcIgZlNcgbfnqjxQWyko7zD2hGn0IZUuM8So7NKdq57DtckY8daMVbbk4IKYK6SBsbvamhBosFcOlZe6jkLxt0nDTZRaJHEI4mgJ2ObOO9Or5gPGyrBaM(OzKNHN)oAfMIMEIDxoAfMra4vkIZEwN9bydT4SlLjpRZ(j5au(E3KGIYnsbFdcu6j2D5QGqM8ONcflNnoQKQaLCPcNuygbGxPioJXOn6TgiGg9fBw2OLJE(ODPm6fjAfMI(Kdrm6fnkLDoaf9OrNDoabI2J2OJru04SN1zFa2ql2zz)PKUmg9kFdcu6j2D5QGqM8OgdL3IGn9e7UCLr30hN9So7dWgAXol7pLU4Kako7zD2hGn0ILZnScsh4CIBt614SN1zFa2qlg1Vtlsszt(iio7zD2hGn0IfKszD2NVbbkDa5MRlsuPm8o)DcRDeqcjDa5MRlsuPm8o)DcRDePfoohNXy0hYnsbXaXzpRZ(Gkk3ifqbWCS5i9jGUmt(geOGlsktQZUjfym0cXgZQlPxR3YDnrLUGQ07OssuYpiXgLQxedzzUsvM)hngAHyko7zD2hur5gPaBOfFl31ev6cko7zD2hur5gPaBOfJ65Ja1rJZXzmgTrSRuSgEqCgJrB0au0f1)mf9IGyK3zr0OeYYOOvykAKHb0OXH5yZr6JgxxMz0iS1m6cw27In68AsGONVgN9So7dQzbaka2fRHKW)mXhhGslcs6olGYlFdcumGYHGubWUynKe(NPk3vjuoeKkaMJnhPpPl7DXw5UkHYHGubWCS5i9jDzVl2kJm95bNcLN1IeNXy0y2O9scaI2LmYfLJM7kAuk7CakAdu06UhJgh2fRHOHyBMdGPO5au04Lnrxji6fbXiVZIOrjKLrrRWu0iddOrJdZXMJ0hnUUmZOryRz0fSS3fB051KarpFno7zD2huZca2qlgu2eDLG0IKeKRW8XbO0IGKUZcO8Y3GafLdbPcG5yZr6t6YExSvURsOCiivamhBosFsx27ITYitFEWPq5zTiXzpRZ(GAwaWgAXzxktEwN9tYbO89UjbLaa6ZeGVbbkgak5sfMevxkljwT(ZnSIkDbv1jFC(74mgJgISRmAKLfDbl7DXg9fJms8TOrByu4OXHlA0mYfLJ2am9r)RgnJ7)5VJghIvJZEwN9b1SaGn0IV2vMyey5yzIpKLLEIhuO8Y3GafdQlPxRayxSgsiBMduP3rLKioJXOnAak6cw27In6lgfn(w0OnatF0gOOHDSOOvykA6j2D5OnatkmXIgHTMrFTRC(7Onmk8YPrJdXIEzrFGZb0OVPNyUuwUgN9So7dQzbaBOfdG5yZr6t6YExS8niqPNy3LngQrbHsIvR)CdROsxqvDYhN)UuExPyn8vqzt0vcslssqUcx5UkL3vkwdFfa7I1qs4FMQzyNDtaJHYBCgJrB0au04Lnrxji69JoVRuSg(OXSJOelAKHb0O5FUHvuPlimfn3ljaiAdu0oJI(EN)oADJ(AVIUGL9UyJ2Fr0In6F1OHDSOOXHDXAiAi2M5a14SN1zFqnlaydTyqzt0vcslssqUcZ3GavSA9NByfv6cQQt(483LWqExPyn8vaSlwdjuPliqL7QeMXG6s61kaMJnhPpPl7DXwP3rLKasivxsVwbWUynKq2mhOsVJkjbKqM3vkwdFfaZXMJ0N0L9UyRmY0NhyCHyQeMXaba0NPkQCxrArskmLONmlxn9d8LbjK5DLI1WxrL7kslssHPe9Kz5kJm95bgxiMkHz)GeBuQ(ZnScsyr)n5FMQm)pEAHqcjkhcs9NByfKWI(BY)mv5UWuCgJrdXHeTleGODgfn3fFrd(5IIwHPO3NI2WOWrlxdeqJUGckAnAJgGI2am9rlkp)D0ioqjw0kS)rBeqKOfeYKhn6Lf9VA0aLCPctIOnmk8YPr7F5Oncisno7zD2huZca2ql20zhjrczzjb5kmF5YzjLuNDtkakV8niqz(isew0RvxiavURsywD2nPvDmPKUjXqNMxt0nDTZRGQGqM8Oqcjgak5sfMevxklLxt0nDTZRGQGqM8OgdnFLmDEibUOxGP4mgJgIdj6FJ2fcq0ggPmAXqrByu45JwHPOFIh0O5jea8fnhGIMhhPOrVF0OlaeTHrHxonA)lhTrarI2Fr0)gnqjxQW14SN1zFqnlaydTytNDKejKLLeKRW8niqz(isew0Rvxia15nMNqWiz(isew0RvxiavbhZ1z)syaOKlvysuDPSuEnr301oVcQcczYJAm08vY05He4IErC2Z6SpOMfaSHwma2fRHeQ0feGVbbkgak5sfMevxkljwT(ZnSIkDbv1jFC(7s51eDtx78kOkiKjpQXqlmoJXOpqJchnoeJVOhKO)vJ2LmYfLJwSpXx0Cak6cw27InAdJchn(w0O5UQXzpRZ(GAwaWgAXayo2CK(KUS3flFdcu1L0RvaSlwdjKnZbQ07OssusSA9NByfv6cQQt(483Lq5qqQGYMOReKwKKGCfUYDfN9So7dQzbaBOfdGDXAij8pt8niqXakhcsfa7I1qs4FMQCxL0XKs6MedDk0IGT6s61kGdvjgc3nvP3rLKOegy(isew0RvxiavUR4SN1zFqnlaydT4RvN95BqGIYHGurL7kKCaTYipRqcjkhcsfu2eDLG0IKeKRWvURsygLdbPcGDXAiHkDbbQCxqczExPyn8vaSlwdjuPliqLrM(8GtHYleWuC2Z6SpOMfaSHwmQCxrcHJvMVbbkkhcsfu2eDLG0IKeKRWvUR4SN1zFqnlaydTyuIbi2X5V5BqGIYHGubLnrxjiTijb5kCL7ko7zD2huZca2qlgzyeQCxbFdcuuoeKkOSj6kbPfjjixHRCxXzpRZ(GAwaWgAX(NjGYCzk7sjFdcuuoeKkOSj6kbPfjjixHRCxXzpRZ(GAwaWgAXCaknkzYhHGqzn9UjbnxolxLT)KtOshO8niqXaqjxQWKO6szjXQ1FUHvuPlOQo5JZFxcdOCiivqzt0vcslssqUcx5UkrpXUlxfeYKh1yO8ecXzpRZ(GAwaWgAXCaknkzY37Meu)GayN5GeY(AArsxRbIX3GafdOCiivaSlwdjH)zQYDvkVRuSg(kOSj6kbPfjjixHRmY0NhCkVqioJXOpjeRC0SL7gwwoAgNKIErIwH5mrhKHerB6kmiAusUgoPrB0au0illAiU)41kIoZgLVOxfMyggafTHrHJgFlA0UgDHfb7ObQNpcIEzrZBrWoAdJchTlbB0hk3ven3vno7zD2huZca2qlMdqPrjt(E3KG6ayS8NajMFWLLYlZL8niqfekhcsL5hCzP8YCzsqOCiivXA4HesbHYHGuZ7l4Y6GfLM)ysqOCiivURsQZUjTQJjL0nDL1epHWPfbsiXGGq5qqQ59fCzDWIsZFmjiuoeKk3vjmliuoeKkZp4Ys5L5YKGq5qqQa1ZhngAHfXi5fcqubHYHGurL7kslssHPe9Kz5k3fKqQJjL0njg60tabmvcLdbPckBIUsqArscYv4kJm95bgZJIZEwN9b1SaGn0I5auAuYKV3njOMLfoiPUCaM(hNXy0fLqCoPgnIlLOE(y0illAoGJkPOhLmbN0OnAakAdJchnEzt0vcIErIUOKRW14SN1zFqnlaydTyoaLgLmb8niqr5qqQGYMOReKwKKGCfUYDbjK6ysjDtIHoTqieNJZymAiEaa9zceN9So7dQeaqFMaqZ7NPxzUsIeI0nj(geO0tS7YvDmPKUjtNhmM3syaLdbPckBIUsqArscYv4k3vjmJbXQ18(z6vMRKiHiDtkHYX(Qo5JZFxcdEwN9R59Z0Rmxjrcr6MuD(eICUHviHeHtktmkd7SBkPJjD6DwunDEatXzpRZ(Gkba0Nja2qlgvURiTijfMs0tML5BqGIH8UsXA4RayxSgsOsxqGk3vP8UsXA4RGYMOReKwKKGCfUYDbjK6ysjDtIHofkVqio7zD2hujaG(mbWgAX3Cotm(NwKKFqITkCC2Z6SpOsaa9zcGn0Ir2mhGej)GeBukHsUjFdcumdUiPmPo7MuqfaZXMJ0Na6YmngAHqcjZhrIWIET6cbOoVXgfeWujmK3vkwdFfu2eDLG0IKeKRWvURsyaLdbPckBIUsqArscYv4k3vj6j2D5QGqM8OgdLNqio7zD2hujaG(mbWgAXxCSbP883juPdu(geOGlsktQZUjfubWCS5i9jGUmtJHwiKqY8rKiSOxRUqaQZBSrbH4SN1zFqLaa6ZeaBOfRWuI7rxUxKqwwM4BqGIYHGuzu(OKaGeYYYuL7csir5qqQmkFusaqczzzkLxUxjwfOE(4P8cH4SN1zFqLaa6ZeaBOfZMRljLMpbU8mfN9So7dQeaqFMaydTydltkWIMpXiW((Nj(geO5DLI1WxbLnrxjiTijb5kCLrM(8GtlcKqQJjL0njg6uE5rXzpRZ(Gkba0Nja2ql2Kmxw50IKKC5rKemYnb8niqPNy3Lp9eqOekhcsfu2eDLG0IKeKRWvUR4SN1zFqLaa6ZeaBOfZi)A(7eI0njaFdcu1z3KwHjxQW1RSAmpccqcP6SBsRWKlv46vwpfAHqasivNDtAvhtkPB6kRPcHGX8ecX54mgJgIn)aGjgio7zD2hurMFaWqV2vMyey5yzIpKLLEIhuO8gNXy0q8WAazI5kfnSdIgEUHjGg9fBw2OLJ2WOWrZ)CdRhyGOpj0Ft(NPO5UQXzpRZ(GkY8dagBOftynGmXCL4BqGIYHGu)5gwbjSO)M8ptvUR4mgJ2OlrxrZDfn)ZnSIkDbf9Ge9OrpGOD0LtJw3OzCF0lNwJUOB0)QrZbOO5)WOfCS5VJUO(Nj(IEqIwDj9kjIEEDJUOo7y04WUynuJZEwN9bvK5ham2ql(NByfv6cIVbbkMXG6s61QWzhtayxSgQ07OssajKyaLdbPcGDXAij8ptvUlmvshtkPBsmKrYitFEGXgvjgz6ZdovN8XKoMeeTW4mgJMhNtQJyvD(7Oxofmck6I6FMIE)OvNDtkiAf21Onmsz0YblkAKLfTctrl4yUo7h9Ien)ZnSIkDbXx0mcHra4OfCS5VJ(YFbzo5A084CsDeRgTdIwU)D0oi6cXoA1z3KcIwSr)RgnSJffn)ZnSIkDbfn3v0ggfo6daDjNSRZFhnoSlwdGOXm3ljai6Ylx0Wowu08p3W6bgi6tc93K)zkADxmvJZEwN9bvK5ham2ql(NByfv6cIVC5SKsQZUjfaLx(geOyalNnoQKQCakDXMLnA5eBvxN9lbUiPmPo7MuqfaZXMJ0Na6YmngAHLWSFqInkv)5gwbjSO)M8ptv6DujjGesm4hKyJsvgDjNSRZFNaWUynaQ07OssajKGlsktQZUjfubWCS5i9jGUmtJ0Z6GfLeRw)5gwrLUGmgAHyQegq5qqQayxSgsc)ZuL7QKoMus3KyiJHI5IGnMleIMxt0nDTZRamHPsmcHrayhvsXzmg9bGqyeaoA(NByfv6ckAYzYYrpirpA0ggPmAIhUggfTGJn)D04LnrxjOgDr3OvyxJMrimcah9Gen(w0OVjfenJCr5ONpAfMI(jEqJUiGAC2Z6SpOIm)aGXgAX)CdROsxq8niqzKPpp408UsXA4RGYMOReKwKKGCfUYitFEa28cHs5DLI1WxbLnrxjiTijb5kCLrM(8GtHwKs6ysjDtIHmsgz6ZdmoVRuSg(kOSj6kbPfjjixHRmY0NhGDrIZEwN9bvK5ham2qlgqzgPjLYW)Ca5O4SN1zFqfz(baJn0IjSgqMyUsX54mgJgxjxQWrBe7kfRHheNXy0q8HKxel6tIZghvsXzpRZ(GkqjxQWPSaaflNnoQK47DtckawKuygbGxPGpSCjhbnVRuSg(ka2fRHKW)mvZWo7MajeMN1zFxAmuERNSIeNXy0Ne)haC0CVKaGOnqr7mkAhD50O1n6SFf9(rxu)Zu0zyNDtGA0g9Fz5OnatF0qS5frFGi)4taq0diAhD50O1nAg3h9YP14SN1zFqfOKlv4uwaWgAXy5)aG5BqGIbSC24OsQcGfjfMra4vkkLxt0nDTZRGQGqM8OgZBjbHYHGurMxKmq(XNaGkJm95bNYBP8UsXA4RGYMOReKwKKGCfUYitFEGXq5zCgJrdr2vgnYYIgh2fRbtskIg7OXHDXAaOS5ifn3ljaiAdu0oJI2rxonADJo7xrVF0f1)mfDg2z3eOgTr)xwoAdW0hneBEr0hiYp(eae9aI2rxonADJMX9rVCAno7zD2hubk5sfoLfaSHw81UYeJalhlt8HSS0t8GcLx(iEqzEYnxUxHEcieN9So7dQaLCPcNYca2qlga7I1Gjjf8niqPNy3Lng6jGqj6j2D5QGqM8OgdLxiucdy5SXrLufalskmJaWRuukVMOB6ANxbvbHm5rnM3sccLdbPImVizG8Jpbavgz6ZdoL34mgJ2iGirZOdi3Wit61tA0f1)mfTRrlxdrBeqKOrlhTGqCoPwJZEwN9bvGsUuHtzbaBOfJLZghvs89Ujbfals51eDtx78kGpSCjhbnVMOB6ANxbvbHm5rng6jIZymAJaIenJoGCdJmPxpPrxu)Zu07llhnkHSmkAK5hamXarpirBGIg2XII2nVIwDj9kiA)frFXMLnA5OzR66SFno7zD2hubk5sfoLfaSHwmwoBCujX37MeuaSiLxt0nDTZRa(WYLCe08AIUPRDEfufeYKh9uO8IDHqu)GeBuQQWuczyanj8ptv6Dujj4BqGILZghvsvoaLUyZYgTCITQRZ(LWS6s616p3WkqD5rIvP3rLKasivxsVwfo7yca7I1qLEhvscmfNXy0hOrHJUOo7y04WUyne9(YYrxu)Zu0gGPpA(NByfv6ckAdJugnq9YrZDvJ2ObOOfCS5VJgVSj6kbrVSOD0flkAfMra4vkQrFG8rJgzzrZ)jjAuoeKOnmkC0fIn)NKAC2Z6SpOcuYLkCklaydTyaSlwdjH)zIVbbkwoBCujvbWIuEnr301oVckHzmOUKETkC2Xea2fRHk9oQKeqcPy16p3WkQ0fuLrM(8aJHweSvxsVwbCOkXq4UPk9oQKeyQeMXYzJJkPkawKuygbGxPasir5qqQGYMOReKwKKGCfUYitFEGXq5TwiKqcUiPmPo7MuqfaZXMJ0Na6Ymng6jkL3vkwdFfu2eDLG0IKeKRWvgz6ZdmMxiGPsy2piXgLQ)CdRGew0Ft(NPkZ)JNwiKqIYHGu)5gwbjSO)M8ptvUlmfNXy0hYX(OzKPp)83rxu)ZeiAuczzu0kmfT6SBsJwmei6bjA8TOrBy)dmnAukAg5IYrpF06ys14SN1zFqfOKlv4uwaWgAXayxSgsc)ZeFdcuSC24OsQcGfP8AIUPRDEfushtkPBsm0P5DLI1WxbLnrxjiTijb5kCLrM(8GsyG5JiryrVwDHau5UIZXzmgnUsUuHjr0hGvDD2poJXOH4qIgxjxQWfJL)daoANrrZDXx0CakACyxSgakBosrRB0O0tiJgncBnJwHPOVCayWIIgDFoq0(lIgInVi6de5hFca4lAcl6JEqI2afTZOODnAtNhI2iGirJze2AgTctrFXO8AI6A084ifft14SN1zFqfOKlvysafa7I1aqzZrIVbbkMvxsVwrMxKmq(XNaGk9oQKeqcj4IKYK6SBsbvamhBosFcOlZ8uEIPsygLdbPcuYLkCL7csir5qqQy5)aGRCxykoJXOHyZpa4ODnAEID0gbejAdJcVCA0ffp6IJ(eyhTHrHJUO4rByu4OXH5yZr6JUGL9UyJgLdbjAURO1nAhRDerdwtkAJaIeTbhOu0Gr5CD2huJZEwN9bvGsUuHjb2qlo7szYZ6SFsoaLV3njOiZpay(geOOCiivamhBosFsx27ITYDvkVMOB6ANxbvbHm5rpfAHXzmg9jxc2ObocfTUrJm)aGJ21Opb2rBeqKOnmkC0ep4zvwo6teT6SBsb1OXmUBsr7GOxofmckAGsUuHRyko7zD2hubk5sfMeydT4SlLjpRZ(j5au(E3KGIm)aG5BqGcUiPmPo7MuqfaZXMJ0Na6YmHEIs51eDtx78kWyONioJXOHyZpa4ODn6tGD0gbejAdJcVCA0ffNVOlc2rByu4OlkoFr7ViAJkAdJchDrXJ2ruIf9jX)bah9YIUaykAi2WaA0f1)mfT)IO)n6I6SJrJd7I1q0yh9VrJZHQedH7MIZEwN9bvGsUuHjb2qlo7szYZ6SFsoaLV3njOiZpay(geO51eDtx78kOkiKjp6Pq51iXS6s61QGOlILakZv)MmR07OssucZOCiivS8FaWvUliH0piXgLQkmLqggqtc)ZuLEhvsIsyqDj9Av4SJjaSlwdv6DujjkHb1L0RvahQsmeUBQsVJkjrjWfjLj1z3KcQayo2CK(eqxM5P8etykoJXOnAakAJoYDnrLUGIEXIyrJd7I1aqzZrkA)frJRlZmAdJchDHyhneHyilZvkAxJUWOxw0scaIwD2nPGAC2Z6SpOcuYLkmjWgAX3YDnrLUG4BqG6hKyJs1lIHSmxPkZ)JgdTWsGlsktQZUjfubWCS5i9jGUmZtHwyCgJrFY1OlmA1z3KcI2WOWrJtzgPrxaLH)5aYrrFKORO5UIgInVi6de5hFcaIgTC05Yz583rJd7I1aqzZrQgN9So7dQaLCPctcSHwma2fRbGYMJeF5YzjLuNDtkakV8niqvxsVwbuMrAsPm8phqoQsVJkjrj1L0RvK5fjdKF8jaOsVJkjrjbHYHGurMxKmq(XNaGkJm95bNYBjWfjLj1z3KcQayo2CK(eqxMj0clPJjL0njgYizKPppWyJkoJXOpqJcVCA0fLOlIfnUYC1VjZO9xenpJ(a4)rq0ls0hkDbf98rRWu04WUynaIE0Ohq0gwMchnhy(7OXHDXAaOS5if9(rZZOvNDtkOgN9So7dQaLCPctcSHwma2fRbGYMJeFdcumOUKETki6IyjGYC1VjZk9oQKeL8dsSrPkQ0fuA(KctjaSlwdGkZ)Jq5zjWfjLj1z3KcQayo2CK(eqxMjuEgNXy0qSLf9fBw2OLJMTQRZ(8fnhGIgh2fRbGYMJu0lwelACDzMrZlMI2WOWrFG4XJ2V95bA0CxrRB0NiA1z3Kc4l6cXu0ds0qSdu0diAg3)ZFh9IGenM3pA)lhTBUCVg9IeT6SBsbyIVOxw08etrRB0MopmMZbPOX3IgnXdk9Gz)OnmkC0qCpH1Oo6ihTC07hnpJwD2nPGOX8jI2WOWrF4O4yQgN9So7dQaLCPctcSHwma2fRbGYMJeFdcuSC24OsQYbO0fBw2OLtSvDD2VeMvxsVwrMxKmq(XNaGk9oQKeLeekhcsfzErYa5hFcaQmY0NhCkVqcP6s61QbYV230bkXQ07OssucCrszsD2nPGkaMJnhPpb0LzEk0tajK(bj2OuDEcRrD0roA5k9oQKeLq5qqQGYMOReKwKKGCfUYDvcCrszsD2nPGkaMJnhPpb0LzEkuEITFqInkvrLUGsZNuykbGDXAauP3rLKatXzpRZ(GkqjxQWKaBOfdG5yZr6taDzM8niqbxKuMuNDtkWyO8mo7zD2hubk5sfMeydTyaSlwdaLnhjRAvRfa]] )


end
