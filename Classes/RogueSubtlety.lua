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

        potion = "battle_potion_of_agility",

        package = "Subtlety",
    } )


    spec:RegisterPack( "Subtlety", 20190712.0040, [[dav9zbqiOQ6rkPAtkjFsevYOGk6uGkTkLuYRGknluLUfuLSlr9lrOHbvXXqvSmLqpdQkttjfxteLTjcY3qvrnoOkfNtevSorqzEGkUhOSprK)bvPeoOiQYcvcEiQkmrrGlkIk1gHkWhHQuQrcvPeDsOcYkvIEjQkcZevfPUjub1orv1prvrYqvsPwkQkXtH0uPeUkQkPTkIQ6RqvQoluLsAVu8xPAWsomvlgIhlLjt4YiBgkFwPA0GCAfRgvfrVwKmBIUnLA3Q63adxPCCrq1Yr55QmDsxhv2oOQVtjnEuvQZlsTEOcnFkr7xydpglmOcxjd)lIhEso4HpZZIz8GN1Gh8KCmOA6nYGU5Tu(ozqF3MmOOCiQK00g0npTe4cJfg0dWXAKbfs1TlHLyI7JcXHKBa7eVXMt66a(gZX0eVXULObfHBKko0BqmOcxjd)lIhEso4HpZZIz8GN1Gh8GpdQZPqaMbfDS5ddk0ie0BqmOc6Ag01JcLdrLKMok(cyNJILRhfKQBxclXe3hfIdj3a2jEJnN01b8nMJPjEJDlXy56rTKtMokEwK3Owep8KCIcVIcp4jHHVKflJLRhfFa5)oDjSy56rHxrL8ecsefFIPLkkfeLGWCoPgL30b8rjNtZXY1JcVIIVq2a4jruQZ2jTpyr1aVy0b8rb(OWHDwksefgGfvcixHYXY1JcVIk5jeKik(6rrHdPK9LnOY50ZyHb9uYLkejmwy4NhJfgu6DejjmlyqBSrj24guCgL6s61m28IUvYt90Dz6DejjIYslJ62iPSRoBN0lFqCSjf99tbm7OGtu4lk4g1QOWzuiCyy5tjxQqzUTOS0YOq4WWYW7)CqzUTOGRb1B6aEd6b5cG1tztkYOg(x0yHbLEhrscZcg0gBuInUbTbSra9nW86Lfe20gnk4alkEIcVIcNrPUKEnliAJy9tzU67KDMEhrsIOwffoJcHddldV)ZbL52IYslJYXrInkLviQJnSt7c)BuMEhrsIOwff(JsDj9Aw4Su9dYfaRz6DejjIAvu4pk1L0R5Jdrjgg3oLP3rKKiQvrDBKu2vNTt6Lpio2KI((PaMDuWjk8ffCJcUguVPd4nOnxk7EthW3LZPgu5CA)DBYGIn)Cqg1Wp(mwyqP3rKKWSGbTXgLyJBqDCKyJs5nIHbyUszM)PIkjyrTyuRI62iPSRoBN0lFqCSjf99tbm7OGdSOw0G6nDaVbDxca2isxqg1W)AmwyqP3rKKWSGb1B6aEd6b5cG1tztkYG2yJsSXnOQlPxZh1yK2vQb9tcNJY07isse1QOuxsVMXMx0TsEQNUltVJijruRIsqiCyyzS5fDRKN6P7YmY2N)IcorXtuRI62iPSRoBN0lFqCSjf99tbm7OGf1IrTkkDSPUc6IHIcVIIr2(8xujfvczqBPBsQRoBN0ZWppg1WFYmwyqP3rKKWSGbTXgLyJBqXFuQlPxZcI2iw)uMR(ozNP3rKKiQvr54iXgLYisxq957ke1pixaSEzM)PIcwu4lQvrDBKu2vNTt6Lpio2KI((PaMDuWIcFguVPd4nOhKlawpLnPiJA4pHmwyqP3rKKWSGbTXgLyJBqH3zJJiPm3r9n2ayJMUZaQRd4JAvu4mk1L0RzS5fDRKN6P7Y07isse1QOeechgwgBEr3k5PE6UmJS95VOGtu8eLLwgL6s61SvY3aVTFkXY07isse1QOUnsk7QZ2j9YhehBsrF)uaZok4alQ1eLLwgLJJeBukppb)OoYihnDMEhrsIOwffchgw(sBJaKxhG1fKRqzUTOwf1TrszxD2oPx(G4ytk67Ncy2rbhyrHVOWnkhhj2Ougr6cQpFxHO(b5cG1ltVJijruW1G6nDaVb9GCbW6PSjfzud)8zJfgu6DejjmlyqBSrj24g0BJKYU6SDsVOscwu4ZG6nDaVb9G4ytk67Ncy2g1WpEJXcdQ30b8g0dYfaRNYMuKbLEhrscZcg1Ogu6o6B0zSWWppglmOEthWBqBGVrVYCLeDmPBtgu6Dejjmlyud)lASWG6nDaVbfrcaIoaRRquNEYoTbLEhrscZcg1Wp(mwyq9MoG3GUZ5mX4FhG1DCKyafYGsVJijHzbJA4FnglmO07issywWG2yJsSXnO4mQBJKYU6SDsV8bXXMu03pfWSJkjyrTyuwAzumFeDcE61SlexE(OskQecprb3Owff(JQbasbW6NV02ia51byDb5kuMBlQvrH)Oq4WWYxABeG86aSUGCfkZTzq9MoG3GIbAChj6oosSrPoc52g1WFYmwyqP3rKKWSGbTXgLyJBqVnsk7QZ2j9YhehBsrF)uaZoQKGf1IrzPLrX8r0j4PxZUqC55JkPOsi8yq9MoG3GUXXgS0ZV3rK(Pg1WFczSWG6nDaVbvHOo3Ja4ErhdWAKbLEhrscZcg1WpF2yHb1B6aEdkB22KuF((T5nYGsVJijHzbJA4hVXyHbLEhrscZcg0gBuInUbfHddllhmcrcaI8PElvuWjk8zq9MoG3GAfWKc4P57m6aV)nYOg(toglmO07issywWG2yJsSXnO0tS90rbNOwdEIAvuiCyy5lTncqEDawxqUcL52mOEthWBqTjBalDhG1LCTr0fmYTpJAudQGWCoPASWWppglmO07issywWG2yJsSXnO4pQtjxQqKiZa7CKb1B6aEdAQPLYOg(x0yHb1B6aEd6PKlvidk9oIKeMfmQHF8zSWGsVJijHzbdQ30b8g0MlLDVPd47Y5udQCoT)UnzqBIZOg(xJXcdk9oIKeMfmOn2OeBCd6PKlvisKDP0G6nDaVbLX9DVPd47Y5udQCoT)UnzqpLCPcrcJA4pzglmO07issywWG2yJsSXnO6ytDf0fdfvsrLqrTkkgz7ZFrbNO2BISTZ3rTkQgWgb03aZRxujblQ1efEffoJshBkk4efp4jk4g1Af1IguVPd4nO)SdPisxqg1WFczSWGsVJijHzbdkyZGEKAq9MoG3GcVZghrsgu4Djhzq3ydGnA6odOUoGpQvrDBKu2vNTt6Lpio2KI((PaMDujblQfnOW7S(72KbL7O(gBaSrt3za11b8g1WpF2yHbLEhrscZcg0gBuInUbfENnoIKYCh13ydGnA6odOUoG3G6nDaVbT5sz3B6a(UCo1GkNt7VBtg0tjxQq9M4mQHF8gJfgu6DejjmlyqbBg0JudQ30b8gu4D24isYGcVl5id6IjlkCJsDj9Ag(zhWY07isse1Aff(swu4gL6s61STFkX6aS(b5cG1ltVJijruRvulMSOWnk1L0R5dYfaRDmqJ7Y07isse1Af1I4jkCJsDj9A2LEJnA6m9oIKerTwrXdEIc3O4jzrTwrHZOUnsk7QZ2j9YhehBsrF)uaZoQKGff(IcUgu4Dw)DBYGEk5sfQRqm6GasHrn8NCmwyqP3rKKWSGbTXgLyJBqPNy7PZccBAJgfCGff8oBCejLpLCPc1vigDqaPWG6nDaVbT5sz3B6a(UCo1GkNt7VBtg0tjxQq9M4mQHFEWJXcdk9oIKeMfmOn2OeBCdQJJeBuk)ZoKED4PFN8Vrz6DejjIAvu3gjLD1z7KE5dIJnPOVFkGzhfCIAXOwffoJQbasbW6NV02ia51byDb5kuMr2(8xuWbwu4lklTmkCgfchgw(sBJaKxhG1fKRqzUTOwff(J6uYLkejYUug1QOCCKyJs5F2H0Rdp97K)nkZ8pvujblk8ffCJcUrTkk8hfchgw(NDi96Wt)o5FJYCBrTkQgWgb03aZRxujblQfnOEthWBq)zhsrKUGmQHFE4XyHbLEhrscZcg0gBuInUbTbSra9nW86Lfe20gnk4alkEIYslJshBQRGUyOOGdSO4jQvr1a2iG(gyE9IkjyrHpdQ30b8g0MlLDVPd47Y5udQCoT)UnzqXMFoiJA4NNfnwyqP3rKKWSGbTXgLyJBqVnsk7QZ2j9YhehBsrF)uaZokyrTMOwfvdyJa6BG51lQKGf1AmOEthWBqBUu29MoGVlNtnOY50(72KbfB(5GmQHFEWNXcdk9oIKeMfmOn2OeBCdk9eBpDwqytB0OGdSOG3zJJiP8PKlvOUcXOdcifguVPd4nOnxk7EthW3LZPgu5CA)DBYGIWnsHrn8ZZAmwyqP3rKKWSGbTXgLyJBqPNy7PZccBAJgvsWIINKffUrrpX2tNz0o9guVPd4nOoR5p1vaJrVAud)8KmJfguVPd4nOoR5p134KhzqP3rKKWSGrn8ZtczSWG6nDaVbvo7q615tYj2TPxnO07issywWOg1GUXOgWgXvJfg(5XyHb1B6aEd6PKlvidk9oIKeMfmQH)fnwyqP3rKKWSGb1B6aEdQTZsrIogG1fKRqg0ng1a2iU2pQbEXzq5jzg1Wp(mwyqP3rKKWSGb1B6aEd6b5cG1oI0f0zq3yudyJ4A)Og4fNbLhJA4FnglmOEthWBq3a6aEdk9oIKeMfmQrnOyZphKXcd)8ySWGsVJijHzbdAJnkXg3GIWHHL)zhsVo80Vt(3Om3Mb1B6aEdkb)CnI5kzud)lASWGsVJijHzbdAJnkXg3GIZOWFuQlPxZcNLQFqUayntVJijruwAzu4pkeomS8b5cG1UW)gL52IcUrTkkDSPUc6IHIcVIIr2(8xujfvcf1QOyKTp)ffCIsNwQUo2uuRvulAq9MoG3G(ZoKIiDbzud)4ZyHbLEhrscZcguVPd4nO)SdPisxqg0gBuInUbf)rbVZghrszUJ6BSbWgnDNbuxhWh1QOUnsk7QZ2j9YhehBsrF)uaZoQKGf1IrTkkCgLJJeBuk)ZoKED4PFN8Vrz6DejjIYslJc)r54iXgLYmAtonxNFVFqUay9Y07isseLLwg1TrszxD2oPx(G4ytk67Ncy2rHxr5nDGN6cGM)zhsrKUGIkjyrTyuWnQvrH)Oq4WWYhKlaw7c)BuMBlQvrPJn1vqxmuujblkCgvYIc3OWzulg1AfvdyJa6BG51lk4gfCJAvumcJrhKJijdAlDtsD1z7KEg(5XOg(xJXcdk9oIKeMfmOn2OeBCdkJS95VOGtunaqkaw)8L2gbiVoaRlixHYmY2N)Ic3O4bprTkQgaifaRF(sBJaKxhG1fKRqzgz7ZFrbhyrLSOwfLo2uxbDXqrHxrXiBF(lQKIQbasbW6NV02ia51byDb5kuMr2(8xu4gvYmOEthWBq)zhsrKUGmQH)KzSWGsVJijHzbdAJnkXg3GIWHHLV02ia51byDb5kuMBlQvrHZOWFuQlPxZcNLQFqUayntVJijruwAzuiCyy5dYfaRDH)nkZTffCnOEthWBqpQXiTRud6Neohzud)jKXcdk9oIKeMfmOn2OeBCd6TrszxD2oPx(G4ytk67Ncy2rLeSOwmkCJsDj9Aw4Su9dYfaRz6DejjIc3OuxsVM)zhsp1LPiwMEhrscdQ30b8g0JAms7k1G(jHZrg1WpF2yHb1B6aEdkb)CnI5kzqP3rKKWSGrnQbTjoJfg(5XyHbLEhrscZcg0gBuInUbfHddlJibaHK70mJ8MgLLwgfchgw(sBJaKxhG1fKRqzUTOwffoJcHddlFqUayTJiDbDzUTOS0YOAaGuaS(5dYfaRDePlOlZiBF(lk4alkEWtuW1G6nDaVbDdOd4nQH)fnwyqP3rKKWSGb1B6aEdk8oBCej1NxP)gnDFF2D4bsTdU2iLUo)ENrEtbmdAJnkXg3GIWHHLV02ia51byDb5kuMBlklTmkDSPUc6IHIcorTiEmOVBtgu4D24isQpVs)nA6((S7WdKAhCTrkDD(9oJ8Mcyg1Wp(mwyqP3rKKWSGbTXgLyJBqr4WWYxABeG86aSUGCfkZTzq9MoG3GYDuFuY(mQH)1ySWGsVJijHzbdAJnkXg3GIWHHLV02ia51byDb5kuMBZG6nDaVbfrcaIoghlTrn8NmJfgu6DejjmlyqBSrj24gueomS8L2gbiVoaRlixHYCBguVPd4nOie7iwQ53nQH)eYyHbLEhrscZcg0gBuInUbfHddlFPTraYRdW6cYvOm3Mb1B6aEdk2WiejaimQHF(SXcdk9oIKeMfmOn2OeBCdkchgw(sBJaKxhG1fKRqzUndQ30b8gu)B0Pmx2BUuAud)4nglmO07issywWG2yJsSXnO4pkeomS8b5cG1UW)gL52IAvuiCyy5dIJnPOVRa27cqMBlQvrHWHHLpio2KI(UcyVlazgz7ZFrbhyrHVCYmOEthWBqpixaS2f(3idk3rDagwFVjmO8yud)jhJfgu6DejjmlyqBSrj24gueomS8bXXMu03va7DbiZTf1QOq4WWYhehBsrFxbS3fGmJS95VOGdSOWxozguVPd4nOxABeG86aSUGCfYGYDuhGH13Bcdkpg1Wpp4XyHbLEhrscZcg0gBuInUbf)rDk5sfIezxkJAvucGM)zhsrKUGY60sn)Ub1B6aEdAZLYU30b8D5CQbvoN2F3MmO0D03OZOg(5HhJfgu6Dejjmlyq9MoG3GUbaYoJoahRrg0gBuInUbf)rPUKEnFqUayTJbACxMEhrscdkgG1FIVvd)8yud)8SOXcdk9oIKeMfmOn2OeBCdk9eBpDujblQecprTkkbqZ)SdPisxqzDAPMFpQvr1aaPay9ZxABeG86aSUGCfkZTf1QOAaGuaS(5dYfaRDH)nk3GC2oDrLeSO4XG6nDaVb9G4ytk67kG9Uayud)8GpJfgu6DejjmlyqBSrj24gubqZ)SdPisxqzDAPMFpQvrHZOWFuQlPxZhehBsrFxbS3fGm9oIKerzPLrPUKEnFqUayTJbACxMEhrsIOS0YOAaGuaS(5dIJnPOVRa27cqMr2(8xujf1IrbxdQ30b8g0lTncqEDawxqUczud)8SgJfgu6Dejjmlyq9MoG3GA7SuKOJbyDb5kKbTXgLyJBqz(i6e80RzxiUm3wuRIcNrPJn1vqxmuuWjQgWgb03aZRxwqytB0OS0YOWFuNsUuHir2LYOwfvdyJa6BG51lliSPnAujblQ2w3257(TrVik4AqBPBsQRoBN0ZWppg1WppjZyHbLEhrscZcg0gBuInUbL5JOtWtVMDH4YZhvsrHp8efEffZhrNGNEn7cXLfCmxhWh1QOWFuNsUuHir2LYOwfvdyJa6BG51lliSPnAujblQ2w3257(TrVWG6nDaVb12zPirhdW6cYviJA4NNeYyHbLEhrscZcg0gBuInUbTbSra9nW86Lfe20gnQKGf1IrHBuNsUuHir2LsdQ30b8g0dYfaRDePlOZOg(5HpBSWGsVJijHzbdAJnkXg3GQUKEnFqUayTJbACxMEhrsIOwfLaO5F2HuePlOSoTuZVh1QOq4WWYxABeG86aSUGCfkZTzq9MoG3GEqCSjf9DfWExamQHFEWBmwyqP3rKKWSGbTXgLyJBqXFuiCyy5dYfaRDH)nkZTf1QO0XM6kOlgkk4alQKffUrPUKEnFCikXW42Pm9oIKerTkk8hfZhrNGNEn7cXL52mOEthWBqpixaS2f(3iJAud6PKlvOEtCglm8ZJXcdk9oIKeMfmOGnd6rQb1B6aEdk8oBCejzqH3LCKbTbasbW6NpixaS2f(3OCdYz701XyEthW7YOscwu8K5ZjZGcVZ6VBtg0ds0vigDqaPWOg(x0yHbLEhrscZcg0gBuInUbf)rbVZghrs5ds0vigDqaPiQvr1a2iG(gyE9YccBAJgvsrXtuRIsqiCyyzS5fDRKN6P7YmY2N)IcorXJb1B6aEdk8(phKrn8JpJfgu6Dejjmlyq9MoG3GUbaYoJoahRrguIVvM3DBa3Rg01GhdkgG1FIVvd)8yud)RXyHbLEhrscZcg0gBuInUbLEITNoQKGf1AWtuRIIEITNoliSPnAujblkEWtuRIc)rbVZghrs5ds0vigDqaPiQvr1a2iG(gyE9YccBAJgvsrXtuRIsqiCyyzS5fDRKN6P7YmY2N)IcorXJb1B6aEd6b5cGvBskmQH)KzSWGsVJijHzbdkyZGEKAq9MoG3GcVZghrsgu4DjhzqBaBeqFdmVEzbHnTrJkjyrTgdk8oR)UnzqpirVbSra9nW86zud)jKXcdk9oIKeMfmOGnd6rQb1B6aEdk8oBCejzqH3LCKbTbSra9nW86Lfe20gnk4alkEIc3OwmQ1kkhhj2OuwHOo2WoTl8Vrz6DejjmOn2OeBCdk8oBCejL5oQVXgaB00DgqDDaFuRIcNrPUKEn)ZoKEQltrSm9oIKerzPLrPUKEnlCwQ(b5cG1m9oIKerbxdk8oR)UnzqpirVbSra9nW86zud)8zJfgu6DejjmlyqBSrj24gu4D24iskFqIEdyJa6BG51lQvrHZOWFuQlPxZcNLQFqUayntVJijruwAzucGM)zhsrKUGYmY2N)IkjyrLSOWnk1L0R5Jdrjgg3oLP3rKKik4g1QOWzuW7SXrKu(GeDfIrheqkIYslJcHddlFPTraYRdW6cYvOmJS95VOscwu8KxmklTmQBJKYU6SDsV8bXXMu03pfWSJkjyrTMOwfvdaKcG1pFPTraYRdW6cYvOmJS95VOskkEWtuWnQvrHZOCCKyJs5F2H0Rdp97K)nkZ8pvuWjk8fLLwgfchgw(NDi96Wt)o5FJYCBrbxdQ30b8g0dYfaRDH)nYOg(XBmwyqP3rKKWSGbTXgLyJBqH3zJJiP8bj6nGncOVbMxVOwfLo2uxbDXqrbNOAaGuaS(5lTncqEDawxqUcLzKTp)f1QOWFumFeDcE61SlexMBZG6nDaVb9GCbWAx4FJmQrnOiCJuySWWppglmO07issywWG2yJsSXnO3gjLD1z7KErLeSOwmkCJcNrPUKEnVlbaBePlOm9oIKerTkkhhj2OuEJyyaMRuM5FQOscwulgfCnOEthWBqpio2KI((PaMTrn8VOXcdQ30b8g0DjayJiDbzqP3rKKWSGrn8JpJfguVPd4nOiEl1PoIbLEhrscZcg1Og1GcpXUb8g(xep8KCWdFgpjNmpRbFguRo7NF)mO4q2BaMsIOWBIYB6a(OKZPxowAqVnQz4FXeIhd6gdGnsYGUEuOCiQK00rXxa7CuSC9OGuD7syjM4(OqCi5gWoXBS5KUoGVXCmnXBSBjglxpQLCY0rXZI8g1I4HNKtu4vu4bpjm8LSyzSC9O4di)3PlHflxpk8kQKNqqIO4tmTurPGOeeMZj1O8MoGpk5CAowUEu4vu8fYgapjIsD2oP9blQg4fJoGpkWhfoSZsrIOWaSOsa5kuowUEu4vujpHGerXxpkkCiLSVCSmwUEuj38n14usefcHbyuunGnIRrHq7ZF5OsETgTPxup4XliNzJXjJYB6a(lkWltNJLRhL30b8xEJrnGnIRWWK(LkwUEuEthWF5ng1a2iUIlSeDUDB6vxhWhlxpkVPd4V8gJAaBexXfwIyaGiwUEuOVVDqankMpIOq4WWiruN66ffcHbyuunGnIRrHq7ZFr5ViQngHxBavNFpQ5IsaEkhlxpkVPd4V8gJAaBexXfwI37Bheq7N66fl9MoG)YBmQbSrCfxyjEk5sfkw6nDa)L3yudyJ4kUWs02zPirhdW6cYviE3yudyJ4A)Og4fhmEswS0B6a(lVXOgWgXvCHL4b5cG1oI0f0X7gJAaBex7h1aV4GXtS0B6a(lVXOgWgXvCHL4gqhWhlJLRhvYnFtnoLerrWtS0rPJnfLcrr5nfWIAUOC49r6iskhlxpk(cDk5sfkQblQnWDdIKIcNpik45KpXCejff9K9qxuZhvdyJ4kCJLEthWF4clXutlfVdgm8Fk5sfIezgyNJILEthWFWoLCPcflxpk(aIAPIIpsWfLRrHnStJLEthWF4clXMlLDVPd47Y5uEF3MG1exSC9O4lCFuyCsz6OoRJ2GOlkfeLcrrHQKlvisefFbOUoGpkCIKokby(9OoaVrnAuyawJUO2aa587rnyr9afA(9OMlkhEFKoIKGBow6nDa)HlSezCF3B6a(UCoL33TjyNsUuHibVdgStjxQqKi7szSC9OsEBBY0rX)SdPisxqr5AulIBu8XAhLGJn)Eukeff2WonkEWtuh1aV44nkhtjwukKRrTgCJIpw7OgSOgnkIV3ggDrzDuO5JsHOOEIV1OWBZhjikalQ5I6bAuCBXsVPd4pCHL4p7qkI0feVdgmDSPUc6IHskHwXiBF(do7nr2257vnGncOVbMxVKGTg8cN6ytWHh8a31AXy56rXN6LPJQb5)offdOUoGpQblkRuuqo8uuBSbWgnDNbuxhWh1rAu(lIYMtQZMKIsD2oPxuCB5yP30b8hUWseENnoIK49DBcg3r9n2ayJMUZaQRd45fExYrW2ydGnA6odOUoGF1TrszxD2oPx(G4ytk67Ncy2jbBXy56rT2SbWgnDu8fG66aE8wefFAstUUO2h4PO8OAmFlkhbWPrrpX2thfgGfLcrrDk5sfkk(ibxu4eHBKcIf1PJugfJUnQPrnkCZrH3k3gVrnAun)JcHIsHCnQBS3Kuow6nDa)HlSeBUu29MoGVlNt59DBc2PKlvOEtC8oyWG3zJJiPm3r9n2ayJMUZaQRd4JLRhfF9irukikbHnpfLvi6JsbrXDuuNsUuHIIpsWffGffc3ife7ILEthWF4clr4D24isI33TjyNsUuH6keJoiGuWl8UKJGTyYWvDj9Ag(zhWY07issSw4lz4QUKEnB7NsSoaRFqUay9Y07issSwlMmCvxsVMpixaS2XanUltVJijXATiEWvDj9A2LEJnA6m9oIKeRfp4bxEs2AHZBJKYU6SDsV8bXXMu03pfWStcg(GBSC9O4dWFJGyrXDZVhLhfQsUuHIIpsquwHOpkg5nO53JsHOOONy7PJsHy0bbKIyP30b8hUWsS5sz3B6a(UCoL33TjyNsUuH6nXX7GbJEITNoliSPnkCGbVZghrs5tjxQqDfIrheqkILRhf)ZoKMCDrL8PFN8VrjSO4F2HuePlOOqimaJIcnTncqEr5AusG1O4J1okfevdyJmpff5mz6OyegJoOOSokuu7KQZVhLcrrHWHHff3woQKN8arjbwJIpw7OeCS53JcnTncqErb40BeuujW)gfL1rHIcFrXFYphl9MoG)WfwI)SdPisxq8oyWCCKyJs5F2H0Rdp97K)nktVJijXQBJKYU6SDsV8bXXMu03pfWSHZIRWzdaKcG1pFPTraYRdW6cYvOmJS95p4adFwAjor4WWYxABeG86aSUGCfkZTTc)NsUuHir2LYvoosSrP8p7q61HN(DY)gLz(Nkjy4dUWDf(r4WWY)SdPxhE63j)BuMBBvdyJa6BG51ljylglxpkCW8ZbfLRrTgCJY6OqaonQeGYBujd3OSokuujankCc40BeuuNsUuHGBS0B6a(dxyj2CPS7nDaFxoNY772emS5NdI3bdwdyJa6BG51lliSPnkCGXJLwQJn1vqxmeCGXZQgWgb03aZRxsWWxSC9OW7JcfvcqJYLhikS5NdkkxJAn4gLV7ZFAueF7nvMoQ1eL6SDsVOWjGtVrqrDk5sfcUXsVPd4pCHLyZLYU30b8D5CkVVBtWWMFoiEhmy3gjLD1z7KE5dIJnPOVFkGzdBnRAaBeqFdmVEjbBnXY1JIVEuuEuiCJuqSOScrFumYBqZVhLcrrrpX2thLcXOdcifXsVPd4pCHLyZLYU30b8D5CkVVBtWq4gPG3bdg9eBpDwqytBu4adENnoIKYNsUuH6keJoiGuelxpk(0aR0PrTXgaB00rnFuUugfalkfIIk5T28PJcHAo3rrnAunN7Olkpk828rcILEthWF4clrN18N6kGXOx5DWGrpX2tNfe20gnjy8KmCPNy7PZmAN(yP30b8hUWs0zn)P(gN8OyP30b8hUWsuo7q615tYj2TPxJLXY1JAbUrki2fl9MoG)YiCJua7G4ytk67Ncy28oyWUnsk7QZ2j9sc2I4It1L0R5DjayJiDbLP3rKKyLJJeBukVrmmaZvkZ8pvsWweUXsVPd4Vmc3if4clXDjayJiDbfl9MoG)YiCJuGlSer8wQtDKyzSC9O4daqkaw)lw6nDa)LBId2gqhWZ7GbdHddlJibaHK70mJ8MAPLiCyy5lTncqEDawxqUcL52wHteomS8b5cG1oI0f0L52S0YgaifaRF(GCbWAhr6c6YmY2N)GdmEWdCJLRhfoWLY53JcXBPIsbrjimNtQrnkzhf357uclk(6rrzDuOOqtBJaKxuaSOsa5kuow6nDa)LBIdxyjYDuFuYM33TjyW7SXrKuFEL(B0099z3Hhi1o4AJu6687Dg5nfW4DWGHWHHLV02ia51byDb5kuMBZsl1XM6kOlgcolINyP30b8xUjoCHLi3r9rj7J3bdgchgw(sBJaKxhG1fKRqzUTyP30b8xUjoCHLiIeaeDmowAEhmyiCyy5lTncqEDawxqUcL52ILEthWF5M4WfwIie7iwQ535DWGHWHHLV02ia51byDb5kuMBlw6nDa)LBIdxyjInmcrcacEhmyiCyy5lTncqEDawxqUcL52ILEthWF5M4WfwI(3OtzUS3CPK3bdgchgw(sBJaKxhG1fKRqzUTy56rXxpkQe4FJIcGHHx7nruiegGrrPquuyd70OqH4ytk6Jcvbm7OWya7OSaWExaIQbSPlQ5ZXsVPd4VCtC4clXdYfaRDH)nIxUJ6amS(EtaJhEhmy4hHddlFqUayTl8VrzUTviCyy5dIJnPOVRa27cqMBBfchgw(G4ytk67kG9UaKzKTp)bhy4lNSy56rHt(6lP7IYLmYfPJIBlkeQ5ChfLvkkfasffkKlawJchaAChCJI7OOqtBJaKxuamm8AVjIcHWamkkfIIcByNgfkehBsrFuOkGzhfgdyhLfa27cqunGnDrnFow6nDa)LBIdxyjEPTraYRdW6cYviE5oQdWW67nbmE4DWGHWHHLpio2KI(UcyVlazUTviCyy5dIJnPOVRa27cqMr2(8hCGHVCYILEthWF5M4WfwInxk7EthW3LZP8(UnbJUJ(gD8oyWW)PKlvisKDPCLaO5F2HuePlOSoTuZVhlxpQ1gaKrHbyrzbG9Uae1gJWluqcIY6OqrHcLGOyKlshLvi6J6bAumU)NFpkuCqow6nDa)LBIdxyjUbaYoJoahRr8Iby9N4Bfgp8oyWWV6s618b5cG1ogOXDz6DejjILRhfF9OOSaWExaIAJrrHcsquwHOpkRuuqo8uukeff9eBpDuwHifIyrHXa2rTbaY53JY6OqaonkuCquawu8j5onQD6jMlLPZXsVPd4VCtC4clXdIJnPOVRa27caVdgm6j2E6KGLq4zLaO5F2HuePlOSoTuZVVQbasbW6NV02ia51byDb5kuMBBvdaKcG1pFqUayTl8Vr5gKZ2Pljy8elxpk(6rrHM2gbiVOaFunaqkaw)OWPJPelkSHDAu8p7qkI0feCJI7L0DrzLIYzuu7G53JsbrTb2IYca7Dbik)frjar9ankihEkkuixaSgfoa04UCS0B6a(l3ehUWs8sBJaKxhG1fKRq8oyWean)ZoKIiDbL1PLA(9v4e)QlPxZhehBsrFxbS3fGm9oIKewAP6s618b5cG1ogOXDz6DejjS0YgaifaRF(G4ytk67kG9UaKzKTp)L0IWnwUEu4qyr5cXfLZOO424nQ7NnkkfIIc8uuwhfkkjWkDAuwyrcYrXxpkkRq0hLi987rH5NsSOui)JIpw7Oee20gnkalQhOrDk5sfIerzDuiaNgL)PJIpw7CS0B6a(l3ehUWs02zPirhdW6cYviEBPBsQRoBN0dgp8oyWy(i6e80RzxiUm32kCQJn1vqxmeCAaBeqFdmVEzbHnTrT0s8Fk5sfIezxkx1a2iG(gyE9YccBAJMeS2w3257(TrVaUXY1JchclQheLlexuwhPmkXqrzDuO5JsHOOEIV1OWhEoEJI7OOWHXsquGpkeWDrzDuiaNgL)PJIpw7O8xe1dI6uYLkuow6nDa)LBIdxyjA7SuKOJbyDb5keVdgmMpIobp9A2fIlpFs4dp4fZhrNGNEn7cXLfCmxhWVc)NsUuHir2LYvnGncOVbMxVSGWM2OjbRT1TD(UFB0lILEthWF5M4WfwIhKlaw7isxqhVdgSgWgb03aZRxwqytB0KGTiUNsUuHir2LYy56rH3hfkkuCaVrnyr9ankxYixKokb4jEJI7OOSaWExaIY6OqrHcsquCB5yP30b8xUjoCHL4bXXMu03va7DbG3bdM6s618b5cG1ogOXDz6DejjwjaA(NDifr6ckRtl187Rq4WWYxABeG86aSUGCfkZTfl9MoG)YnXHlSepixaS2f(3iEhmy4hHddlFqUayTl8VrzUTv6ytDf0fdbhyjdx1L0R5Jdrjgg3oLP3rKKyf(z(i6e80RzxiUm3wSmwUEuj33rFJUyP30b8xMUJ(gDWAGVrVYCLeDmPBtXsVPd4VmDh9n6WfwIisaq0byDfI60t2PJLEthWFz6o6B0HlSe35CMy8VdW6oosmGcfl9MoG)Y0D03OdxyjIbAChj6oosSrPoc528oyWW5TrszxD2oPx(G4ytk67Ncy2jbBrlTK5JOtWtVMDH4YZNucHh4Uc)naqkaw)8L2gbiVoaRlixHYCBRWpchgw(sBJaKxhG1fKRqzUTyP30b8xMUJ(gD4clXno2GLE(9oI0pL3bd2TrszxD2oPx(G4ytk67Ncy2jbBrlTK5JOtWtVMDH4YZNucHNyP30b8xMUJ(gD4clrfI6CpcG7fDmaRrXsVPd4VmDh9n6WfwISzBts9573M3OyP30b8xMUJ(gD4clrRaMuapnFNrh49Vr8oyWq4WWYYbJqKaGiFQ3sbh8fl9MoG)Y0D03OdxyjAt2aw6oaRl5AJOlyKBF8oyWONy7PHZAWZkeomS8L2gbiVoaRlixHYCBXYy56rHdMFoiIDXY1Jk5g(5AeZvkki)IcA2HOtJAJna2OPJY6OqrX)SdPjxxujF63j)BuuCB5yP30b8xgB(5GGrWpxJyUs8oyWq4WWY)SdPxhE63j)BuMBlwUEu8jiAlkUTO4F2HuePlOOgSOgnQ5IYraCAukikg3hfGtZrLaqupqJI7OO4FHOeCS53Jkb(3iEJAWIsDj9kjIAEfevcCwQOqHCbWAow6nDa)LXMFoiCHL4p7qkI0feVdgmCIF1L0RzHZs1pixaSMP3rKKWslXpchgw(GCbWAx4FJYCBWDLo2uxbDXq4fJS95VKsOvmY2N)GJoTuDDSP1AXy56rHdZj1rauD(9OaC6nckQe4FJIc8rPoBN0lkfY1OSoszuYbEkkmalkfIIsWXCDaFuaSO4F2HuePliEJIrym6GIsWXMFpQn)fK90YrHdZj1ra0O8lkj43JYVOwe3OuNTt6fLae1d0OGC4PO4F2HuePlOO42IY6OqrXxOn50CD(9OqHCbW6ffo5EjDxuPbCrb5WtrX)SdPjxxujF63j)Buukaa3CS0B6a(lJn)Cq4clXF2HuePliEBPBsQRoBN0dgp8oyWWp8oBCejL5oQVXgaB00DgqDDa)QBJKYU6SDsV8bXXMu03pfWStc2IRWPJJeBuk)ZoKED4PFN8Vrz6DejjS0s874iXgLYmAtonxNFVFqUay9Y07issyPL3gjLD1z7KE5dIJnPOVFkGzJxEth4PUaO5F2HuePlOKGTiCxHFeomS8b5cG1UW)gL52wPJn1vqxmusWWzYWfNlUwnGncOVbMxp4c3vmcJrhKJiPy56rXximgDqrX)SdPisxqrrotMoQblQrJY6iLrr892WOOeCS53JcnTncqE5OsaikfY1OyegJoOOgSOqbjiQDsVOyKlsh18rPquupX3Auj7YXsVPd4Vm28ZbHlSe)zhsrKUG4DWGXiBF(donaqkaw)8L2gbiVoaRlixHYmY2N)WLh8SQbasbW6NV02ia51byDb5kuMr2(8hCGLSv6ytDf0fdHxmY2N)sQbasbW6NV02ia51byDb5kuMr2(8hUjlwUEuOuJrAuwqnOFs4Cuuco287rHM2gbiVCu49rHIkbolvuOqUaynkWlthLGJn)EuOqUaynQe4FJIcNCVoYOuigDqaPiQ5J6j(wJsopb3CS0B6a(lJn)Cq4clXJAms7k1G(jHZr8oyWq4WWYxABeG86aSUGCfkZTTcN4xDj9Aw4Su9dYfaRz6DejjS0seomS8b5cG1UW)gL52GBSC9OW7Jcff9aUDOOuNTt6fLlT6PVO4okkuQzb1Ic8rXhjihl9MoG)YyZpheUWs8OgJ0UsnOFs4CeVdgSBJKYU6SDsV8bXXMu03pfWStc2I4QUKEnlCwQ(b5cG1m9oIKe4QUKEn)ZoKEQltrSm9oIKeXsVPd4Vm28ZbHlSej4NRrmxPyzSC9OqvYLkuu8baifaR)flxpk8wsYnIfvY3zJJiPyP30b8x(uYLkuVjoyW7SXrKeVVBtWoirxHy0bbKcEH3LCeSgaifaRF(GCbWAx4FJYniNTtxhJ5nDaVltcgpz(CYILRhvY3)5GII7L0DrzLIYzuuocGtJsbr18TOaFujW)gfvdYz70LJIp1lthLvi6JchmVik8o5PE6UOMlkhbWPrPGOyCFuaonhl9MoG)YNsUuH6nXHlSeH3)5G4DWGHF4D24iskFqIUcXOdcifRAaBeqFdmVEzbHnTrtINvccHddlJnVOBL8upDxMr2(8hC4jwUEuRnaiJcdWIcfYfaR2KuefUrHc5cG1tztkkkUxs3fLvkkNrr5iaonkfevZ3Ic8rLa)BuuniNTtxok(uVmDuwHOpkCW8IOW7KN6P7IAUOCeaNgLcIIX9rb40CS0B6a(lFk5sfQ3ehUWsCdaKDgDaowJ4fdW6pX3kmE4L4BL5D3gW9kS1GNyP30b8x(uYLkuVjoCHL4b5cGvBsk4DWGrpX2tNeS1GNv0tS90zbHnTrtcgp4zf(H3zJJiP8bj6keJoiGuSQbSra9nW86Lfe20gnjEwjieomSm28IUvYt90Dzgz7ZFWHNy56rXhRDumkHZnmYMEnHfvc8Vrr5AusG1O4J1okK0rjimNtQ5yP30b8x(uYLkuVjoCHLi8oBCejX772eSds0BaBeqFdmVE8cVl5iynGncOVbMxVSGWM2OjbBnXY1JIpw7OyucNByKn9AclQe4FJIc8Y0rHqyagff28ZbrSlQblkRuuqo8uuU9wuQlPxVO8xe1gBaSrthfdOUoGphl9MoG)YNsUuH6nXHlSeH3zJJijEF3MGDqIEdyJa6BG51Jx4DjhbRbSra9nW86Lfe20gfoW4b3fxlhhj2OuwHOo2WoTl8Vrz6Dejj4DWGbVZghrszUJ6BSbWgnDNbuxhWVcNQlPxZ)SdPN6YueltVJijHLwQUKEnlCwQ(b5cG1m9oIKeWnwUEu49rHIkbolvuOqUaynkWlthvc8VrrzfI(O4F2HuePlOOSoszuN6PJIBlhfF9OOeCS53JcnTncqErbyr5ia4POuigDqaPihfE3hnkmalk(t(rHWHHfL1rHIcF8N8ZXsVPd4V8PKlvOEtC4clXdYfaRDH)nI3bdg8oBCejLpirVbSra9nW86TcN4xDj9Aw4Su9dYfaRz6DejjS0sbqZ)SdPisxqzgz7ZFjblz4QUKEnFCikXW42Pm9oIKeWDfoH3zJJiP8bj6keJoiGuyPLiCyy5lTncqEDawxqUcLzKTp)LemEYlAPL3gjLD1z7KE5dIJnPOVFkGzNeS1SQbasbW6NV02ia51byDb5kuMr2(8xs8Gh4UcNoosSrP8p7q61HN(DY)gLz(Nco4Zslr4WWY)SdPxhE63j)BuMBdUXY1JAbo2hfJS95NFpQe4FJUOqimaJIsHOOuNTtAuIHUOgSOqbjikRGp5sJcHIIrUiDuZhLo2uow6nDa)LpLCPc1BIdxyjEqUayTl8Vr8oyWG3zJJiP8bj6nGncOVbMxVv6ytDf0fdbNgaifaRF(sBJaKxhG1fKRqzgz7ZFRWpZhrNGNEn7cXL52ILXY1JcvjxQqKik(cqDDaFSC9OWHWIcvjxQqjcV)ZbfLZOO424nkUJIcfYfaRNYMuuukike6jSrJcJbSJsHOO287g4POqap3fL)IOWbZlIcVtEQNUJ3Oi4PpQblkRuuoJIY1OSD(ok(yTJcNymGDukef1gJAaBexJchglbWnhl9MoG)YNsUuHibSdYfaRNYMueVdgmCQUKEnJnVOBL8upDxMEhrsclT82iPSRoBN0lFqCSjf99tbmB4Gp4UcNiCyy5tjxQqzUnlTeHddldV)ZbL52GBSC9OWbZphuuUg1AWnk(yTJY6OqaonQeGYBujd3OSokuujaL3O8xevcfL1rHIkbOr5ykXIk57)CqrbyrzbeffoyyNgvc8Vrr5ViQhevcCwQOqHCbWAu4g1dIcLdrjgg3ofl9MoG)YNsUuHibUWsS5sz3B6a(UCoL33TjyyZpheVdgSgWgb03aZRxwqytBu4aJh8cNQlPxZcI2iw)uMR(ozNP3rKKyfor4WWYW7)CqzUnlT0XrInkLviQJnSt7c)BuMEhrsIv4xDj9Aw4Su9dYfaRz6DejjwHF1L0R5Jdrjgg3oLP3rKKy1TrszxD2oPx(G4ytk67Ncy2WbFWfUXY1JIVEuu4TLaGnI0fuua4jwuOqUay9u2KIIYFruOkGzhL1rHIArCJATjggG5kfLRrTyuawus6UOuNTt6LJLEthWF5tjxQqKaxyjUlbaBePliEhmyoosSrP8gXWamxPmZ)ujbBXv3gjLD1z7KE5dIJnPOVFkGzdhylglxpQKNg1IrPoBN0lkRJcffk1yKgLfud6NeohfvkI2IIBlkCW8IOW7KN6P7IcjDuT0n587rHc5cG1tztkkhl9MoG)YNsUuHibUWs8GCbW6PSjfXBlDtsD1z7KEW4H3bdM6s618rngPDLAq)KW5Om9oIKeRuxsVMXMx0TsEQNUltVJijXkbHWHHLXMx0TsEQNUlZiBF(do8S62iPSRoBN0lFqCSjf99tbmBylUshBQRGUyi8Ir2(8xsjuSC9OW7Jcb40OsarBelkuL5QVt2r5Vik8ffFX)uxuaSOwq6ckQ5JsHOOqHCbW6f1OrnxuwbmfkkUB(9OqHCbW6PSjfff4JcFrPoBN0lhl9MoG)YNsUuHibUWs8GCbW6PSjfX7Gbd)QlPxZcI2iw)uMR(ozNP3rKKyLJJeBukJiDb1NVRqu)GCbW6Lz(Ncg(wDBKu2vNTt6Lpio2KI((PaMnm8flxpkCaGf1gBaSrthfdOUoGN3O4okkuixaSEkBsrrbGNyrHQaMDu8a3OSokuu4DC4O8DF(tJIBlkfe1AIsD2oPhVrTiCJAWIchG3JAUOyC)p)EuamSOWj4JY)0r52aUxJcGfL6SDsp4YBuawu4dUrPGOSD(EShCKIcfKGOi(wP)gWhL1rHIch6j4h1rg5OPJc8rHVOuNTt6ffoxtuwhfkQfgffU5yP30b8x(uYLkejWfwIhKlawpLnPiEhmyW7SXrKuM7O(gBaSrt3za11b8RWP6s61m28IUvYt90Dz6DejjwjieomSm28IUvYt90Dzgz7ZFWHhlTuDj9A2k5BG32pLyz6DejjwDBKu2vNTt6Lpio2KI((PaMnCGTglT0XrInkLNNGFuhzKJMotVJijXkeomS8L2gbiVoaRlixHYCBRUnsk7QZ2j9YhehBsrF)uaZgoWWhUoosSrPmI0fuF(Ucr9dYfaRxMEhrsc4gl9MoG)YNsUuHibUWs8G4ytk67Ncy28oyWUnsk7QZ2j9scg(ILEthWF5tjxQqKaxyjEqUay9u2KImQrng]] )


end
