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


    spec:RegisterPack( "Subtlety", 20200124, [[dafOMbqiikpcIQnjQ8jvGkJckQtbfzvqK4vqPMfQs3Icu7ss)suQHbrCmufltu0ZOGmnvaxJcQTPcKVPIOmorj4CIsuRtfrAEQiDpiSpku)dIukDqvevluf0dPaAIIs6IqKs2ieP6JIsigjePuCsisXkvr9srjKMPOek3Kce2jfYpfLq1qHiPLkkrEkunvrHRsbsBvfr8vvGYzHiLQ9sP)kYGL6WuTyi9yjMmHlJSzq9zvQrdYPvSAvGQETk0Sj62u0Uv1VvA4QKJtbIwokphy6KUoQSDOKVJQA8uaoVOQ1RIW8Hc7xylp2mS4cxjRrzIKmrcs4jZdursw2WgoZSSfxZFrw8lVC0Vjl(7MKfhNdvLKM3IF55LRlSzyXblhRqwCivVaN0SZ(Euio0AznZgmMCsxN9lmhwZgmMLST4OCJurAElQfx4kznktKKjsqcpzEGksYYg2WzEqwCNtHwMfhFmnqlo0ie0BrT4ccuS4ipACouvsA(OZs7nhfNrE0qQEboPzN99OqCO1YAMnym5KUo7xyoSMnymlzhNrE0N9NZz5JotE4n6mrsMijohNrE0giK)3e4KgNrE0gC0NCHGerNfDkhJw3OfeSZj1O9Io7hTCaAnoJ8On4OZsK5IfjIwD2nPPbo6Y(IrN9JE)OniC2rsen8YIoRKRq14mYJ2GJ(KleKiAdkGIgPrjtq1IlhGcSzyXbk5sfIe2mSgXJndlo9oQKe2dT4f2OeBCloMJwDj9AfEErIp5hFcaQ07Ossengyen4IKYK6SBsbvaehBosFcOlZm6tJ2qrJPOZfnMJgLdgUcuYLkuL7kAmWiAuoy4kw(paOk3v0yYI7fD23IdGCXYhOS5izvRrzAZWItVJkjH9qlEHnkXg3IJYbdxbqCS5i9jDzVl2k3v05IUSMOB6ANxbvbbpLrJ(uerNPf3l6SVfV4szYl6SFsoa1IlhGME3KS4WZpaiRAnYq2mS407Ossyp0IxyJsSXT4GlsktQZUjfubqCS5i9jGUmZOre9bIox0L1eDtx78kiAJre9bS4ErN9T4fxktErN9tYbOwC5a007MKfhE(bazvRrhWMHfNEhvsc7Hw8cBuInUfVSMOB6ANxbvbbpLrJ(uerZt0gC0yoA1L0RvbrxelbuMR(nzwP3rLKi6CrJ5Or5GHRy5)aGQCxrJbgr7NGyJsvfIsWddOjH)fQsVJkjr05IgzrRUKETkC2XeaYfl)k9oQKerNlAKfT6s61kGdvjgm3nvP3rLKi6CrdUiPmPo7MuqfaXXMJ0Na6YmJ(0Onu0ykAmzX9Io7BXlUuM8Io7NKdqT4YbOP3njlo88daYQwJmSndlo9oQKe2dT4f2OeBClUFcInkvVig8YCLQm)pgTXiIoZOZfn4IKYK6SBsbvaehBosFcOlZm6treDMwCVOZ(w8B5UMOsxqw1A0bzZWItVJkjH9qlUx0zFloaYflFGYMJKfVWgLyJBXvxsVwbuHrAsPc0pgKCuLEhvsIOZfT6s61k88IeFYp(eauP3rLKi6Crliuoy4k88IeFYp(eauzKPppi6tJMNOZfn4IKYK6SBsbvaehBosFcOlZmAerNz05IwhtkPBsmu0gC0mY0NheTXrFqw8s(IKsQZUjfynIhRAn6KzZWItVJkjH9qlEHnkXg3IJSOvxsVwfeDrSeqzU63KzLEhvsIOZfTFcInkvrLUGsZNuikbGCXYhuz(FmAerBOOZfn4IKYK6SBsbvaehBosFcOlZmAerBilUx0zFloaYflFGYMJKvTgLfSzyXP3rLKWEOfVWgLyJBXXYzJJkPkhGsxSzzJMpXw11z)OZfnMJwDj9AfEErIp5hFcaQ07OsseDUOfekhmCfEErIp5hFcaQmY0Nhe9PrZt0yGr0QlPxR8j)AFthOeRsVJkjr05IgCrszsD2nPGkaIJnhPpb0Lzg9PiI(arJbgr7NGyJs15jSg1rh5O5R07OsseDUOr5GHRG8MOReKw4KGCfQYDfDUObxKuMuNDtkOcG4yZr6taDzMrFkIOnu0yhTFcInkvrLUGsZNuikbGCXYhuP3rLKiAmzX9Io7BXbqUy5du2CKSQ1OSSndlo9oQKe2dT4f2OeBClo4IKYK6SBsbrBmIOnKf3l6SVfhaXXMJ0Na6YmTQ1iEqIndlUx0zFloaYflFGYMJKfNEhvsc7Hw1QwCcaOVqaBgwJ4XMHfNEhvsc7Hw8cBuInUfNEIDNVQJjL0nz6gq0ghnprNlAKfnkhmCfK3eDLG0cNeKRqvUROZfnMJgzrlwTw2VqVYCLejyPBsjuo2x1PCC(7OZfnYI2l6SFTSFHEL5kjsWs3KQZNGLZnKgngyenmNuMyubYz3ushtk6tJ(UiQMUbenMS4ErN9T4L9l0Rmxjrcw6MKvTgLPndlo9oQKe2dT4f2OeBCloYIUSRuS8)kaYfl)eQ0feOYDfDUOl7kfl)VcYBIUsqAHtcYvOk3v0yGr06ysjDtIHI(uerZdsS4ErN9T4OYDfPfoPquIEYmVvTgziBgwCVOZ(w8BoNjg)tlCYpbXwfYItVJkjH9qRAn6a2mS407Ossyp0IxyJsSXT4yoAWfjLj1z3KcQaio2CK(eqxMz0gJi6mJgdmIM5JiryrVwDHauNpAJJ(Gqs0yk6CrJSOl7kfl)VcYBIUsqAHtcYvOk3v05IgzrJYbdxb5nrxjiTWjb5kuL7k6CrtpXUZxfe8ugnAJreTHqIf3l6SVfhElCasK8tqSrPek5Mw1AKHTzyXP3rLKWEOfVWgLyJBXbxKuMuNDtkOcG4yZr6taDzMrBmIOZmAmWiAMpIeHf9A1fcqD(Ono6dcjwCVOZ(w8lo2aNF(7eQ0bQvTgDq2mS407Ossyp0IxyJsSXT4OCWWvgvokjaibVScv5UIgdmIgLdgUYOYrjbaj4LvOuz5ELyvG6LJrFA08GelUx0zFlUcrjUhD5ErcEzfYQwJoz2mS4ErN9T4S56ssP5tGlVqwC6DujjShAvRrzbBgwC6DujjShAXlSrj24w8YUsXY)RG8MOReKw4KGCfQYitFEq0NgTHJgdmIwhtkPBsmu0NgnpzblUx0zFlo)LjfyrZNyeyF)lKvTgLLTzyXP3rLKWEOfVWgLyJBXPNy35J(0OpasIox0OCWWvqEt0vcslCsqUcv5US4ErN9T4MK5YYNw4KKRmIKGrUjWQwJ4bj2mS407Ossyp0IxyJsSXT4QZUjTcrUuHQxfnAJJolGKOXaJOvNDtAfICPcvVkA0NIi6mrs0yGr0QZUjTQJjL0nDv0uMijAJJ2qiXI7fD23IZi)A(7eS0njGvTQfxqWoNuTzynIhBgwC6DujjShAXlSrj24wCKfnqjxQqKOY2BoYI7fD23IFCkhTQ1OmTzyX9Io7BXbk5sfYItVJkjH9qRAnYq2mS407Ossyp0I7fD23IxCPm5fD2pjhGAXLdqtVBsw8IayvRrhWMHfNEhvsc7Hw8cBuInUfhOKlvisuDP0I7fD23IZ4(Kx0z)KCaQfxoan9UjzXbk5sfIew1AKHTzyXP3rLKWEOfVWgLyJBX1XKs6MedfTXrFqrNlAgz6ZdI(0OVlIQPBarNl6YAIUPRDEfeTXiI(arBWrJ5O1XKI(0O5bjrJPOrkrNPf3l6SVf)NBifv6cYQwJoiBgwC6DujjShAX3lloGulUx0zFlowoBCujzXXYLCKf)InlB08j2QUo7hDUObxKuMuNDtkOcG4yZr6taDzMrBmIOZ0IJLZsVBswCoaLUyZYgnFITQRZ(w1A0jZMHfNEhvsc7Hw8cBuInUfhlNnoQKQCakDXMLnA(eBvxN9T4ErN9T4fxktErN9tYbOwC5a007MKfhOKlvOuraSQ1OSGndlo9oQKe2dT47LfhqQf3l6SVfhlNnoQKS4y5soYINPHJg7OvxsVwXAUxwLEhvsIOrkrBidhn2rRUKETA6aLyPfobGCXYhuP3rLKiAKs0zA4OXoA1L0RvaKlw(j4TWbQ07Ossensj6mrs0yhT6s61Ql9cB08v6DujjIgPenpijASJMhdhnsjAmhn4IKYK6SBsbvaehBosFcOlZmAJreTHIgtwCSCw6DtYIduYLkusHyeaALcRAnklBZWItVJkjH9qlEHnkXg3ItpXUZxfe8ugn6trenwoBCujvbk5sfkPqmcaTsHf3l6SVfV4szYl6SFsoa1IlhGME3KS4aLCPcLkcGvTgXdsSzyXP3rLKWEOfVWgLyJBX9tqSrP6p3qkiHf93K)fQsVJkjr05IgzrJYbdx)5gsbjSO)M8VqvUROZfDznr301oVcQccEkJgTXrZt05IgZrdUiPmPo7MuqfaXXMJ0Na6YmJ(0OZmAmWiASC24OsQYbO0fBw2O5tSvDD2pAmfDUOXC0LDLIL)xb5nrxjiTWjb5kuLrM(8GOpfr0gkAmWiAmhTFcInkv)5gsbjSO)M8VqvM)hJ2yerNz05IgLdgUcYBIUsqAHtcYvOkJm95brBC0gk6CrJSObk5sfIevxkJox0LDLIL)xbqUy5Ne(xOAbYz3eibZ8Io77YOngr0iPMLJgtrJjlUx0zFl(p3qkQ0fKvTgXdp2mS407Ossyp0IxyJsSXT4L1eDtx78kOki4PmA0NIiAEIgdmIwhtkPBsmu0NIiAEIox0L1eDtx78kiAJreTHS4ErN9T4fxktErN9tYbOwC5a007MKfhE(bazvRr8KPndlo9oQKe2dT4f2OeBClo4IKYK6SBsbvaehBosFcOlZmAerFGOZfDznr301oVcI2yerFalUx0zFlEXLYKx0z)KCaQfxoan9UjzXHNFaqw1AepgYMHfNEhvsc7Hw8cBuInUfNEIDNVki4PmA0NIiASC24OsQcuYLkusHyeaALclUx0zFlEXLYKx0z)KCaQfxoan9UjzXr5gPWQwJ45a2mS407Ossyp0IxyJsSXT40tS78vbbpLrJ2yerZJHJg7OPNy35Rm6MElUx0zFlUZk(tjDzm6vRAnIhdBZWI7fD23I7SI)u6Itcilo9oQKe2dTQ1iEoiBgwCVOZ(wC5CdPG0bpN42KE1ItVJkjH9qRAnINtMndlUx0zFloQFNw4KYMYrGfNEhvsc7Hw1Qw8lgvwtuxTzynIhBgwCVOZ(wCGsUuHS407Ossyp0QwJY0MHfNEhvsc7HwCVOZ(wCtNDKej4LLeKRqw8lgvwtuxtaQSVayX5XWw1AKHSzyXP3rLKWEOf)DtYI7Naa5mhKG3xtlC6A5tmlUx0zFlUFcaKZCqcEFnTWPRLpXSQ1OdyZWI7fD23IFT6SVfNEhvsc7Hw1QwCuUrkSzynIhBgwC6DujjShAXlSrj24wCWfjLj1z3KcI2yerNz0yhnMJwDj9A9wURjQ0fuLEhvsIOZfTFcInkvVig8YCLQm)pgTXiIoZOXKf3l6SVfhaXXMJ0Na6YmTQ1OmTzyX9Io7BXVL7AIkDbzXP3rLKWEOvTgziBgwCVOZ(wCuVCeOoQfNEhvsc7Hw1Qw8IayZWAep2mS407Ossyp0IxyJsSXT4ilAuoy4kaYfl)KW)cv5UIox0OCWWvaehBosFsx27ITYDfDUOr5GHRaio2CK(KUS3fBLrM(8GOpfr0gQAylUx0zFloaYfl)KW)czX5auAHHt3fHfNhRAnktBgwC6DujjShAXlSrj24wCuoy4kaIJnhPpPl7DXw5UIox0OCWWvaehBosFsx27ITYitFEq0NIiAdvnSf3l6SVfhK3eDLG0cNeKRqwCoaLwy40DryX5XQwJmKndlo9oQKe2dT4f2OeBCloYIgOKlvisuDPm6CrlwT(ZnKIkDbv1PCC(BlUx0zFlEXLYKx0z)KCaQfxoan9UjzXjaG(cbSQ1OdyZWItVJkjH9qlUx0zFl(1UYeJalhRqw8cBuInUfhzrRUKETcGCXYpbVfoqLEhvsclo8YspzaQ1iESQ1idBZWItVJkjH9qlEHnkXg3ItpXUZhTXiI(Gqs05IwSA9NBifv6cQQt5483rNl6YUsXY)RG8MOReKw4KGCfQYDfDUOl7kfl)VcGCXYpj8Vq1cKZUjq0gJiAES4ErN9T4aio2CK(KUS3fRvTgDq2mS407Ossyp0IxyJsSXT4IvR)CdPOsxqvDkhN)o6CrJSOl7kfl)VcGCXYpHkDbbQCxrNlAmhnYIwDj9AfaXXMJ0N0L9UyR07OssengyeT6s61kaYfl)e8w4av6DujjIgdmIUSRuS8)kaIJnhPpPl7DXwzKPppiAJJoZOXu05IgZrJSOjaG(cvrL7kslCsHOe9Kz(QPFWVSOXaJOl7kfl)VIk3vKw4Kcrj6jZ8vgz6ZdI24OZmAmfDUOXC0(ji2Ou9NBifKWI(BY)cvz(Fm6tJoZOXaJOr5GHR)CdPGew0Ft(xOk3v0yYI7fD23IdYBIUsqAHtcYviRAn6KzZWItVJkjH9qlUx0zFlUPZosIe8YscYvilEHnkXg3IZ8rKiSOxRUqaQCxrNlAmhT6SBsR6ysjDtIHI(0OlRj6MU25vqvqWtz0OXaJOrw0aLCPcrIQlLrNl6YAIUPRDEfufe8ugnAJreD5kz6gqcCrViAmzXl5lskPo7MuG1iESQ1OSGndlo9oQKe2dT4f2OeBCloZhrIWIET6cbOoF0ghTHqs0gC0mFejcl61QleGQGJ56SF05IgzrduYLkejQUugDUOlRj6MU25vqvqWtz0Ongr0LRKPBajWf9clUx0zFlUPZosIe8YscYviRAnklBZWItVJkjH9qlEHnkXg3IJSObk5sfIevxkJox0IvR)CdPOsxqvDkhN)o6Crxwt0nDTZRGQGGNYOrBmIOZ0I7fD23IdGCXYpHkDbbSQ1iEqIndlo9oQKe2dT4f2OeBClU6s61kaYfl)e8w4av6DujjIox0IvR)CdPOsxqvDkhN)o6CrJYbdxb5nrxjiTWjb5kuL7YI7fD23IdG4yZr6t6YExSw1Aep8yZWItVJkjH9qlEHnkXg3IJSOr5GHRaixS8tc)luL7k6CrRJjL0njgk6treTHJg7OvxsVwbCOkXG5UPk9oQKerNlAKfnZhrIWIET6cbOYDzX9Io7BXbqUy5Ne(xiRAnINmTzyXP3rLKWEOfVWgLyJBXr5GHROYDfsoGwzKx0OXaJOr5GHRG8MOReKw4KGCfQYDfDUOXC0OCWWvaKlw(juPliqL7kAmWi6YUsXY)RaixS8tOsxqGkJm95brFkIO5bjrJjlUx0zFl(1QZ(w1AepgYMHfNEhvsc7Hw8cBuInUfhLdgUcYBIUsqAHtcYvOk3Lf3l6SVfhvURibZXYBvRr8CaBgwC6DujjShAXlSrj24wCuoy4kiVj6kbPfojixHQCxwCVOZ(wCuIbi2X5VTQ1iEmSndlo9oQKe2dT4f2OeBClokhmCfK3eDLG0cNeKRqvUllUx0zFlo8Wiu5UcRAnINdYMHfNEhvsc7Hw8cBuInUfhLdgUcYBIUsqAHtcYvOk3Lf3l6SVf3)cbuMltfxkTQ1iEoz2mS407Ossyp0I7fD23IxYxKRY2FkjuPdulEHnkXg3IJSObk5sfIevxkJox0IvR)CdPOsxqvDkhN)o6CrJSOr5GHRG8MOReKw4KGCfQYDfDUOPNy35RccEkJgTXiI2qiXItWWurtVBsw8s(ICv2(tjHkDGAvRr8KfSzyXP3rLKWEOf3l6SVf3pbaYzoibVVMw401YNyw8cBuInUfhzrJYbdxbqUy5Ne(xOk3v05IUSRuS8)kiVj6kbPfojixHQmY0Nhe9PrZdsS4VBswC)eaiN5Ge8(AAHtxlFIzvRr8KLTzyXP3rLKWEOf3l6SVf3bqy5pbsm)ellvwMlT4f2OeBClUGq5GHRm)ellvwMltccLdgUkw(F0yGr0ccLdgUw2xWv0blkn)XKGq5GHRCxrNlA1z3Kw1XKs6MUkAYqij6tJ2WrJbgrJSOfekhmCTSVGROdwuA(JjbHYbdx5UIox0yoAbHYbdxz(jwwQSmxMeekhmCfOE5y0gJi6mnC0gC08GKOrkrliuoy4kQCxrAHtkeLONmZx5UIgdmIwhtkPBsmu0Ng9bqs0yk6CrJYbdxb5nrxjiTWjb5kuLrM(8GOno6SGf)DtYI7aiS8NajMFILLklZLw1AuMiXMHfNEhvsc7Hw83njlUzEHdsQlhGP)wCVOZ(wCZ8chKuxoat)TQ1Om5XMHfNEhvsc7Hw8cBuInUfhLdgUcYBIUsqAHtcYvOk3v0yGr06ysjDtIHI(0OZejwCVOZ(wCoaLgLmbw1QwCGsUuHsfbWMH1iESzyXP3rLKWEOfFVS4asT4ErN9T4y5SXrLKfhlxYrw8YUsXY)RaixS8tc)luTa5SBcKGzErN9Dz0gJiAEQNmdBXXYzP3njloasKuigbGwPWQwJY0MHfNEhvsc7Hw8cBuInUfhzrJLZghvsvaKiPqmcaTsr05IUSMOB6ANxbvbbpLrJ24O5j6Crliuoy4k88IeFYp(eauzKPppi6tJMNOZfDzxPy5)vqEt0vcslCsqUcvzKPppiAJreTHS4ErN9T4y5)aGSQ1idzZWItVJkjH9qlUx0zFl(1UYeJalhRqwCYauMNCZL7vl(bqIfhEzPNma1Aepw1A0bSzyXP3rLKWEOfVWgLyJBXPNy35J2yerFaKeDUOPNy35RccEkJgTXiIMhKeDUOrw0y5SXrLufajskeJaqRueDUOlRj6MU25vqvqWtz0OnoAEIox0ccLdgUcpViXN8Jpbavgz6ZdI(0O5XI7fD23IdGCXY3KKcRAnYW2mS407Ossyp0IVxwCaPwCVOZ(wCSC24OsYIJLl5ilEznr301oVcQccEkJgTXiI(awCSCw6DtYIdGePYAIUPRDEfyvRrhKndlo9oQKe2dT47LfhqQf3l6SVfhlNnoQKS4y5soYIxwt0nDTZRGQGGNYOrFkIO5jASJoZOrkr7NGyJsvfIsWddOjH)fQsVJkjHfVWgLyJBXXYzJJkPkhGsxSzzJMpXw11z)OZfnMJwDj9A9NBifOU8iXQ07OssengyeT6s61QWzhtaixS8R07OssenMS4y5S07MKfhajsL1eDtx78kWQwJoz2mS407Ossyp0IxyJsSXT4y5SXrLufajsL1eDtx78ki6CrJ5Orw0QlPxRcNDmbGCXYVsVJkjr0yGr0IvR)CdPOsxqvgz6ZdI2yerB4OXoA1L0RvahQsmyUBQsVJkjr0yk6CrJ5OXYzJJkPkasKuigbGwPiAmWiAuoy4kiVj6kbPfojixHQmY0NheTXiIMNAMrJbgrdUiPmPo7MuqfaXXMJ0Na6YmJ2yerFGOZfDzxPy5)vqEt0vcslCsqUcvzKPppiAJJMhKenMIox0yoA)eeBuQ(ZnKcsyr)n5FHQm)pg9PrNz0yGr0OCWW1FUHuqcl6Vj)luL7kAmzX9Io7BXbqUy5Ne(xiRAnklyZWItVJkjH9qlEHnkXg3IJLZghvsvaKivwt0nDTZRGOZfToMus3KyOOpn6YUsXY)RG8MOReKw4KGCfQYitFEq05IgzrZ8rKiSOxRUqaQCxwCVOZ(wCaKlw(jH)fYQw1Idp)aGSzynIhBgwC6DujjShAXHxw6jdqTgXJf3l6SVf)AxzIrGLJviRAnktBgwC6DujjShAXlSrj24wCuoy46p3qkiHf93K)fQYDzX9Io7BXjSgqHyUsw1AKHSzyXP3rLKWEOfVWgLyJBXXC0ilA1L0RvHZoMaqUy5xP3rLKiAmWiAKfnkhmCfa5ILFs4FHQCxrJPOZfToMus3KyOOn4OzKPppiAJJ(GIox0mY0Nhe9PrRt5yshtkAKs0zAX9Io7BX)5gsrLUGSQ1OdyZWItVJkjH9qlUx0zFl(p3qkQ0fKfVWgLyJBXrw0y5SXrLuLdqPl2SSrZNyR66SF05IgCrszsD2nPGkaIJnhPpb0LzgTXiIoZOZfnMJ2pbXgLQ)CdPGew0Ft(xOk9oQKerJbgrJSO9tqSrPkJUKtX15VtaixS8bv6DujjIgdmIgCrszsD2nPGkaIJnhPpb0LzgTbhTx0blkjwT(ZnKIkDbfTXiIoZOXu05IgzrJYbdxbqUy5Ne(xOk3v05IwhtkPBsmu0gJiAmhTHJg7OXC0zgnsj6YAIUPRDEfenMIgtrNlAgbZiaKJkjlEjFrsj1z3KcSgXJvTgzyBgwC6DujjShAXlSrj24wCgz6ZdI(0Ol7kfl)VcYBIUsqAHtcYvOkJm95brJD08GKOZfDzxPy5)vqEt0vcslCsqUcvzKPppi6treTHJox06ysjDtIHI2GJMrM(8GOno6YUsXY)RG8MOReKw4KGCfQYitFEq0yhTHT4ErN9T4)CdPOsxqw1A0bzZWI7fD23IdOcJ0KsfOFmi5ilo9oQKe2dTQ1OtMndlUx0zFloH1akeZvYItVJkjH9qRAvRAXXIyGzFRrzIeEYY8Wdp8yX57SF(BGfhPX8AzkjIoleTx0z)OLdqb14Sf)ITWJKS4ipACouvsA(OZs7nhfNrE0qQEboPzN99OqCO1YAMnym5KUo7xyoSMnymlzhNrE0N9NZz5JotE4n6mrsMijohNrE0giK)3e4KgNrE0gC0NCHGerNfDkhJw3OfeSZj1O9Io7hTCaAnoJ8On4OZsK5IfjIwD2nPPbo6Y(IrN9JE)OniC2rsen8YIoRKRq14mYJ2GJ(KleKiAdkGIgPrjtqnohNrE0iTmaQWPKiAucEzu0L1e11OrP75b1Op5LcDPGO)9nyiNzcZjJ2l6Spi69L5RXzKhTx0zFq9IrL1e1veWshCmoJ8O9Io7dQxmQSMOUInISDUBt6vxN9JZipAVOZ(G6fJkRjQRyJiB4DfXzKhn(7xaOvJM5JiAuoyysenqDfenkbVmk6YAI6A0O098GO9xe9fJm4Rv15VJEarl2NQXzKhTx0zFq9IrL1e1vSrKn49la0QjG6kio7fD2huVyuznrDfBezduYLkuC2l6SpOEXOYAI6k2iY20zhjrcEzjb5keVxmQSMOUMauzFbabpgoo7fD2huVyuznrDfBezZbO0OKjVVBsi8taGCMdsW7RPfoDT8jwC2l6SpOEXOYAI6k2iY(A1z)4CCg5rJ0YaOcNsIOjSiw(O1XKIwHOO9IUSOhq0ow(iDujvJZip6SebuYLku0dC0xlamOskAm)B0yXjFI5OskA6jZHarpF0L1e1vmfN9Io7dqCCkh5DGrGmGsUuHirLT3CuC2l6SpaBezduYLkuCg5rBGqu5y0gywbr7A0WddOXzVOZ(aSrKDXLYKx0z)KCakVVBsikcqCg5rNL4(OH5KY8rd4pAbIarRB0kefnUsUuHir0zPvDD2pAmJMpAXo)D0GL3OhnA4Lviq0x7kN)o6bo6FvO5VJEar7y5J0rLeMQXzVOZ(aSrKnJ7tErN9tYbO8(UjHaOKlvisW7aJaOKlvisuDPmoJ8Op5xxY8rB0CdPOsxqr7A0zID0gisnAbhB(7OvikA4Hb0O5bjrdOY(caVr7WkXIwHCn6dGD0gisn6bo6rJMmGRHrGO5pk08rRqu0pzaA0zrmWSg9YIEar)Rgn3vC2l6SpaBez)ZnKIkDbX7aJqhtkPBsmKXhuogz6Zdo9UiQMUbKRSMOB6ANxbgJ4agmM1XKoLhKGjKsMXzKhDw8xMp6cK)3u0SvDD2p6boA(u0qowu0xSzzJMpXw11z)ObKgT)IOn5K6CjPOvNDtkiAURAC2l6SpaBezJLZghvs8(UjHGdqPl2SSrZNyR66SpVy5socXfBw2O5tSvDD2ph4IKYK6SBsbvaehBosFcOlZ0yezgNrE0iv2SSrZhDwAvxN9rAB0zXi9Gde99GffThDH5xr7OlNgn9e7oF0WllAfIIgOKlvOOnWScIgZOCJuqSOb6iLrZiWfv0Ohft1OrAN7I3Ohn6I)rJsrRqUgnymVKuno7fD2hGnISlUuM8Io7NKdq59DtcbqjxQqPIaW7aJalNnoQKQCakDXMLnA(eBvxN9JZipAdkGerRB0ccEEkA(q0hTUrZbOObk5sfkAdmRGOxw0OCJuqmqC2l6SpaBezJLZghvs8(UjHaOKlvOKcXia0kf8ILl5iezAySvxsVwXAUxwLEhvscKIHmm2QlPxRMoqjwAHtaixS8bv6DujjqkzAySvxsVwbqUy5NG3chOsVJkjbsjtKGT6s61Ql9cB08v6Dujjqk8GeS5XWifmdUiPmPo7MuqfaXXMJ0Na6YmngHHWuCg5rBG7dgbXIMdm)D0E04k5sfkAdmRrZhI(OzKxGM)oAfIIMEIDNpAfIraOvkIZErN9byJi7IlLjVOZ(j5auEF3KqauYLkuQia8oWiONy35RccEkJEkcSC24OsQcuYLkusHyeaALI4mYJ2O5gsp4arFsO)M8VqN0OnAUHuuPlOOrj4LrrJN3eDLGODnA5YpAdePgTUrxwt05POjNjZhnJGzeakA(Jcf9nP683rRqu0OCWWrZDvJ(KlbB0YLF0gisnAbhB(7OXZBIUsq0OKYNOp6S6FHarZFuOOZe7On6KuJZErN9byJi7FUHuuPliEhye(ji2Ou9NBifKWI(BY)cvP3rLKihYq5GHR)CdPGew0Ft(xOk3vUYAIUPRDEfufe8ug1yEYHzWfjLj1z3KcQaio2CK(eqxM5PzIbgy5SXrLuLdqPl2SSrZNyR66SpMYH5YUsXY)RG8MOReKw4KGCfQYitFEWPimegyGz)eeBuQ(ZnKcsyr)n5FHQm)pAmImZHYbdxb5nrxjiTWjb5kuLrM(8aJnuoKbuYLkejQUuMRSRuS8)kaYfl)KW)cvlqo7MajyMx0zFxAmcKuZYyctXzKhnsF(bafTRrFaSJM)OqlNgDwX5nAdJD08hfk6SIhnMxofmckAGsUuHWuC2l6SpaBezxCPm5fD2pjhGY77Mec45haeVdmIYAIUPRDEfufe8ug9ue8Gbg6ysjDtIHofbp5kRj6MU25vGXimuCg5rFWgfk6SIhTlbB0WZpaOODn6dGD0(TppqJMmaVOY8rFGOvNDtkiAmVCkyeu0aLCPcHP4Sx0zFa2iYU4szYl6SFsoaL33njeWZpaiEhyeGlsktQZUjfubqCS5i9jGUmtehixznr301oVcmgXbIZipAdkGI2JgLBKcIfnFi6JMrEbA(7OvikA6j2D(OvigbGwPio7fD2hGnISlUuM8Io7NKdq59Dtcbk3if8oWiONy35RccEkJEkcSC24OsQcuYLkusHyeaALI4mYJol2YNaA0xSzzJMp65J2LYOx4Ovik6tosnlw0OuX5au0JgDX5aeiAp6SigywJZErN9byJiBNv8Ns6Yy0R8oWiONy35RccEkJAmcEmm20tS78vgDtFC2l6SpaBez7SI)u6ItcO4Sx0zFa2iYwo3qkiDWZjUnPxJZErN9byJiBu)oTWjLnLJG4CCg5rFi3ifedeN9Io7dQOCJuGaaXXMJ0Na6Ym5DGraUiPmPo7MuGXiYeBmRUKETEl31ev6cQsVJkjro)eeBuQErm4L5kvz(F0yezIP4Sx0zFqfLBKcSrK9TCxtuPlO4Sx0zFqfLBKcSrKnQxocuhnohNrE0g4UsXY)bXzKhTbfqrNv)lu0lmSbFxerJsWlJIwHOOHhgqJghIJnhPpACDzMrdZwZOZyzVl2OlRjbIE(AC2l6SpOweaeaixS8tc)leVCakTWWP7Iabp8oWiqgkhmCfa5ILFs4FHQCx5q5GHRaio2CK(KUS3fBL7khkhmCfaXXMJ0N0L9UyRmY0NhCkcdvnCCg5rJzd6ljaiAxYixKpAUROrPIZbOO5trR7EmACixS8JgPVfoaMIMdqrJN3eDLGOxyyd(UiIgLGxgfTcrrdpmGgnoehBosF046YmJgMTMrNXYExSrxwtce9814Sx0zFqTiayJiBqEt0vcslCsqUcXlhGslmC6UiqWdVdmcuoy4kaIJnhPpPl7DXw5UYHYbdxbqCS5i9jDzVl2kJm95bNIWqvdhN9Io7dQfbaBezxCPm5fD2pjhGY77MeccaOVqaEhyeidOKlvisuDPmNy16p3qkQ0fuvNYX5VJZipAK6UYOHxw0zSS3fB0xmYGX3Sgn)rHIghkRrZixKpA(q0h9VA0mU)N)oACKEno7fD2hulca2iY(AxzIrGLJviEHxw6jdqrWdVdmcKPUKETcGCXYpbVfoqLEhvsI4mYJ2GcOOZyzVl2OVyu04BwJMpe9rZNIgYXIIwHOOPNy35JMpePqelAy2Ag91UY5VJM)OqlNgnosp6Lf9bphqJ(MEI5sz(AC2l6SpOweaSrKnaIJnhPpPl7DXY7aJGEIDN3yehesYjwT(ZnKIkDbv1PCC(7CLDLIL)xb5nrxjiTWjb5kuL7kxzxPy5)vaKlw(jH)fQwGC2nbmgbpXzKhTbfqrJN3eDLGO3p6YUsXY)JgZoSsSOHhgqJ2O5gsrLUGWu0CVKaGO5tr7mk67D(7O1n6R9k6mw27InA)frl2O)vJgYXIIghYfl)Or6BHduJZErN9b1IaGnISb5nrxjiTWjb5keVdmcXQ1FUHuuPlOQoLJZFNdzLDLIL)xbqUy5NqLUGavURCygzQlPxRaio2CK(KUS3fBLEhvscmWqDj9Afa5ILFcElCGk9oQKeyGrzxPy5)vaehBosFsx27ITYitFEGXzIPCygzeaqFHQOYDfPfoPquIEYmF10p4xggyu2vkw(FfvURiTWjfIs0tM5RmY0NhyCMykhM9tqSrP6p3qkiHf93K)fQY8)4PzIbgOCWW1FUHuqcl6Vj)luL7ctXzKhnsdC0UqaI2zu0Cx8gn4NlkAfIIEFkA(JcfTC5tan6mYiR1OnOakA(q0hTi)83rd7aLyrRq(hTbIuJwqWtz0Oxw0)QrduYLkejIM)OqlNgT)5J2arQ14Sx0zFqTiayJiBtNDKej4LLeKRq8wYxKusD2nPae8W7aJG5JiryrVwDHau5UYHz1z3Kw1XKs6MedDAznr301oVcQccEkJIbgidOKlvisuDPmxznr301oVcQccEkJAmIYvY0nGe4IEbMIZipAKg4O)nAxiarZFKYOfdfn)rHMpAfII(jdqJ2qibWB0CakAdc4Sg9(rJUaq08hfA50O9pF0gisnA)fr)B0aLCPcvJZErN9b1IaGnISnD2rsKGxwsqUcX7aJG5JiryrVwDHauN3ydHedM5JiryrVwDHaufCmxN9ZHmGsUuHir1LYCL1eDtx78kOki4PmQXikxjt3asGl6fXzVOZ(GAraWgr2aixS8tOsxqaEhyeidOKlvisuDPmNy16p3qkQ0fuvNYX5VZvwt0nDTZRGQGGNYOgJiZ4mYJ(Gnku04iDEJEGJ(xnAxYixKpAX(eVrZbOOZyzVl2O5pku04BwJM7QgN9Io7dQfbaBezdG4yZr6t6YExS8oWiuxsVwbqUy5NG3chOsVJkjroXQ1FUHuuPlOQoLJZFNdLdgUcYBIUsqAHtcYvOk3vC2l6SpOweaSrKnaYfl)KW)cX7aJazOCWWvaKlw(jH)fQYDLthtkPBsm0Pimm2QlPxRaouLyWC3uLEhvsICiJ5JiryrVwDHau5UIZErN9b1IaGnISVwD2N3bgbkhmCfvURqYb0kJ8IIbgOCWWvqEt0vcslCsqUcv5UYHzuoy4kaYfl)eQ0feOYDHbgLDLIL)xbqUy5NqLUGavgz6ZdofbpibtXzVOZ(GAraWgr2OYDfjyowEEhyeOCWWvqEt0vcslCsqUcv5UIZErN9b1IaGnISrjgGyhN)M3bgbkhmCfK3eDLG0cNeKRqvUR4Sx0zFqTiayJiB4HrOYDf8oWiq5GHRG8MOReKw4KGCfQYDfN9Io7dQfbaBez7FHakZLPIlL8oWiq5GHRG8MOReKw4KGCfQYDfN9Io7dQfbaBezZbO0OKjVemmv007MeIs(ICv2(tjHkDGY7aJazaLCPcrIQlL5eRw)5gsrLUGQ6uoo)DoKHYbdxb5nrxjiTWjb5kuL7kh9e7oFvqWtzuJryiKeN9Io7dQfbaBezZbO0OKjVVBsi8taGCMdsW7RPfoDT8jgVdmcKHYbdxbqUy5Ne(xOk3vUYUsXY)RG8MOReKw4KGCfQYitFEWP8GK4mYJ(KqS8rZwUBiz(OzCsk6foAfIZeDGhseTPRqGOrj5Y)KgTbfqrdVSOrA(JxRi6cBuEJEviIXFau08hfkA8nRr7A0zAySJgOE5ii6Lfnpgg7O5pku0UeSrFOCxr0Cx14Sx0zFqTiayJiBoaLgLm59DtcHdGWYFcKy(jwwQSmxY7aJqqOCWWvMFILLklZLjbHYbdxfl)hdmeekhmCTSVGROdwuA(JjbHYbdx5UYPo7M0QoMus30vrtgcjNAymWazccLdgUw2xWv0blkn)XKGq5GHRCx5WSGq5GHRm)ellvwMltccLdgUcuVC0yezAydMhKGueekhmCfvURiTWjfIs0tM5RCxyGHoMus3KyOtpasWuouoy4kiVj6kbPfojixHQmY0NhyCwio7fD2hulca2iYMdqPrjtEF3KqyMx4GK6Yby6FCg5rNvc25KA0WUuI6LJrdVSO5aoQKIEuYeCsJ2GcOO5pku045nrxji6fo6SsUcvJZErN9b1IaGnIS5auAuYeW7aJaLdgUcYBIUsqAHtcYvOk3fgyOJjL0njg60mrsCooJ8OrAba0xiqC2l6SpOsaa9fcGOSFHEL5kjsWs3K4DGrqpXUZx1XKs6MmDdWyEYHmuoy4kiVj6kbPfojixHQCx5WmYeRwl7xOxzUsIeS0nPekh7R6uoo)DoK5fD2Vw2VqVYCLejyPBs15tWY5gsXadyoPmXOcKZUPKoM0P3fr10namfN9Io7dQeaqFHayJiBu5UI0cNuikrpzMN3bgbYk7kfl)VcGCXYpHkDbbQCx5k7kfl)VcYBIUsqAHtcYvOk3fgyOJjL0njg6ue8GK4Sx0zFqLaa6leaBezFZ5mX4FAHt(ji2QqXzVOZ(Gkba0xia2iYgElCasK8tqSrPek5M8oWiWm4IKYK6SBsbvaehBosFcOlZ0yezIbgmFejcl61QleG68gFqibt5qwzxPy5)vqEt0vcslCsqUcv5UYHmuoy4kiVj6kbPfojixHQCx5ONy35RccEkJAmcdHK4Sx0zFqLaa6leaBezFXXg48ZFNqLoq5DGraUiPmPo7MuqfaXXMJ0Na6YmngrMyGbZhrIWIET6cbOoVXhesIZErN9bvcaOVqaSrKTcrjUhD5ErcEzfI3bgbkhmCLrLJscasWlRqvUlmWaLdgUYOYrjbaj4LvOuz5ELyvG6LJNYdsIZErN9bvcaOVqaSrKnBUUKuA(e4YluC2l6SpOsaa9fcGnIS5VmPalA(eJa77FH4DGru2vkw(FfK3eDLG0cNeKRqvgz6Zdo1WyGHoMus3KyOt5jleN9Io7dQeaqFHayJiBtYCz5tlCsYvgrsWi3eW7aJGEIDN)0dGKCOCWWvqEt0vcslCsqUcv5UIZErN9bvcaOVqaSrKnJ8R5VtWs3Ka8oWiuNDtAfICPcvVkQXzbKGbgQZUjTcrUuHQxf9uezIemWqD2nPvDmPKUPRIMYejgBiKeNJZipAK(8daIyG4Sx0zFqfE(baH4AxzIrGLJviEHxw6jdqrWtCg5rJ0cRbuiMRu0qoiAO5gIaA0xSzzJMpA(JcfTrZnKEWbI(Kq)n5FHIM7QgN9Io7dQWZpaiSrKnH1akeZvI3bgbkhmC9NBifKWI(BY)cv5UIZip6SOeDfn3v0gn3qkQ0fu0dC0Jg9aI2rxonADJMX9rVCAn6SUr)RgnhGI2OdJwWXM)o6S6FH4n6boA1L0RKi651n6S6SJrJd5ILFno7fD2huHNFaqyJi7FUHuuPliEhyeygzQlPxRcNDmbGCXYVsVJkjbgyGmuoy4kaYfl)KW)cv5UWuoDmPKUjXqgmJm95bgFq5yKPpp4uDkht6ysiLmJZipAdcoPoIv15VJE5uWiOOZQ)fk69JwD2nPGOvixJM)iLrlhSOOHxw0kefTGJ56SF0lC0gn3qkQ0feVrZiygbGIwWXM)o6l)fK5uQrBqWj1rSA0oiA5(3r7GOZe7OvNDtkiAXg9VA0qowu0gn3qkQ0fu0CxrZFuOOZs0LCkUo)D04qUy5dIgZCVKaGOZVCrd5yrrB0CdPhCGOpj0Ft(xOO1DXuno7fD2huHNFaqyJi7FUHuuPliEl5lskPo7MuacE4DGrGmSC24OsQYbO0fBw2O5tSvDD2ph4IKYK6SBsbvaehBosFcOlZ0yezMdZ(ji2Ou9NBifKWI(BY)cvP3rLKadmqMFcInkvz0LCkUo)Dca5ILpOsVJkjbgyaUiPmPo7MuqfaXXMJ0Na6YmnyVOdwusSA9NBifv6cYyezIPCidLdgUcGCXYpj8VqvURC6ysjDtIHmgbMnm2yotKsznr301oVcWeMYXiygbGCujfNrE0zjcMraOOnAUHuuPlOOjNjZh9ah9OrZFKYOjd4Ayu0co283rJN3eDLGA0zDJwHCnAgbZiau0dC04BwJ(Muq0mYf5JE(Ovik6NmanAddQXzVOZ(Gk88dacBez)ZnKIkDbX7aJGrM(8Gtl7kfl)VcYBIUsqAHtcYvOkJm95byZdsYv2vkw(FfK3eDLG0cNeKRqvgz6ZdofHHZPJjL0njgYGzKPppW4YUsXY)RG8MOReKw4KGCfQYitFEa2goo7fD2huHNFaqyJiBavyKMuQa9JbjhfN9Io7dQWZpaiSrKnH1akeZvkohNrE04k5sfkAdCxPy5)G4mYJgPnK8IyrFsC24Osko7fD2hubk5sfkveaey5SXrLeVVBsiaqIKcXia0kf8ILl5ieLDLIL)xbqUy5Ne(xOAbYz3eibZ8Io77sJrWt9Kz44mYJ(K4)aGIM7LeaenFkANrr7OlNgTUrx8RO3p6S6FHIUa5SBcuJol(lZhnFi6JgPpVi6dg5hFcaIEar7OlNgTUrZ4(OxoTgN9Io7dQaLCPcLkca2iYgl)haeVdmcKHLZghvsvaKiPqmcaTsrUYAIUPRDEfufe8ug1yEYjiuoy4k88IeFYp(eauzKPpp4uEYv2vkw(FfK3eDLG0cNeKRqvgz6ZdmgHHIZipAK6UYOHxw04qUy5Bssr0yhnoKlw(aLnhPO5EjbarZNI2zu0o6YPrRB0f)k69JoR(xOOlqo7Ma1OZI)Y8rZhI(Or6ZlI(Gr(XNaGOhq0o6YPrRB0mUp6LtRXzVOZ(GkqjxQqPIaGnISV2vMyey5yfIx4LLEYaue8WlzakZtU5Y9kIdGK4Sx0zFqfOKlvOuraWgr2aixS8njPG3bgb9e7oVXioasYrpXUZxfe8ug1ye8GKCidlNnoQKQairsHyeaALICL1eDtx78kOki4PmQX8KtqOCWWv45fj(KF8jaOYitFEWP8eNrE0gisnAgzqYnmYKE9KgDw9Vqr7A0YLF0gisnA08rliyNtQ14Sx0zFqfOKlvOuraWgr2y5SXrLeVVBsiaqIuznr301oVc4flxYrikRj6MU25vqvqWtzuJrCG4mYJ2arQrZidsUHrM0RN0OZQ)fk69L5JgLGxgfn88daIyGOh4O5trd5yrr7MxrRUKEfeT)IOVyZYgnF0SvDD2VgN9Io7dQaLCPcLkca2iYglNnoQK49DtcbasKkRj6MU25vaVy5socrznr301oVcQccEkJEkcEWotKIFcInkvvikbpmGMe(xOk9oQKe8oWiWYzJJkPkhGsxSzzJMpXw11z)CywDj9A9NBifOU8iXQ07OssGbgQlPxRcNDmbGCXYVsVJkjbMIZip6d2OqrNvNDmACixS8JEFz(OZQ)fkA(q0hTrZnKIkDbfn)rkJgOE(O5UQrBqbu0co283rJN3eDLGOxw0o6IffTcXia0kf1Opy(OrdVSOn6KenkhmC08hfk6mX2Otsno7fD2hubk5sfkveaSrKnaYfl)KW)cX7aJalNnoQKQairQSMOB6ANxb5WmYuxsVwfo7yca5ILFLEhvscmWqSA9NBifv6cQYitFEGXimm2QlPxRaouLyWC3uLEhvscmLdZy5SXrLufajskeJaqRuGbgOCWWvqEt0vcslCsqUcvzKPppWye8uZedmaxKuMuNDtkOcG4yZr6taDzMgJ4a5k7kfl)VcYBIUsqAHtcYvOkJm95bgZdsWuom7NGyJs1FUHuqcl6Vj)luL5)XtZedmq5GHR)CdPGew0Ft(xOk3fMIZip6d5yF0mY0NF(7OZQ)fcenkbVmkAfIIwD2nPrlgce9ahn(M1O5V)bNgnkfnJCr(ONpADmPAC2l6SpOcuYLkuQiayJiBaKlw(jH)fI3bgbwoBCujvbqIuznr301oVcYPJjL0njg60YUsXY)RG8MOReKw4KGCfQYitFEqoKX8rKiSOxRUqaQCxX54mYJgxjxQqKi6S0QUo7hNrE0inWrJRKlvOSXY)bafTZOO5U4nAoafnoKlw(aLnhPO1nAu6j4rJgMTMrRqu0xoamyrrJUphiA)frJ0Nxe9bJ8Jpba8gnHf9rpWrZNI2zu0UgTPBarBGi1OXmmBnJwHOOVyuznrDnAdc4SIPAC2l6SpOcuYLkejqaGCXYhOS5iX7aJaZQlPxRWZls8j)4taqLEhvscmWaCrszsD2nPGkaIJnhPpb0LzEQHWuomJYbdxbk5sfQYDHbgOCWWvS8FaqvUlmfNrE0i95hau0UgTHWoAdePgn)rHwon6SIhD2rFaSJM)OqrNv8O5pku04qCS5i9rNXYExSrJYbdhn3v06gTJ1oIObRjfTbIuJMVdukAWOCUo7dQXzVOZ(GkqjxQqKaBezxCPm5fD2pjhGY77Mec45haeVdmcuoy4kaIJnhPpPl7DXw5UYvwt0nDTZRGQGGNYONIiZ4mYJ(KlbB0ahMIw3OHNFaqr7A0ha7OnqKA08hfkAYa8IkZh9bIwD2nPGA0yg3nPODq0lNcgbfnqjxQqvmfN9Io7dQaLCPcrcSrKDXLYKx0z)KCakVVBsiGNFaq8oWiaxKuMuNDtkOcG4yZr6taDzMioqUYAIUPRDEfymIdeNrE0i95hau0Ug9bWoAdePgn)rHwon6SIZB0gg7O5pku0zfN3O9xe9bfn)rHIoR4r7WkXI(K4)aGIEzrNbefnsFyan6S6FHI2Fr0)gDwD2XOXHCXYpASJ(3OX5qvIbZDtXzVOZ(GkqjxQqKaBezxCPm5fD2pjhGY77Mec45haeVdmIYAIUPRDEfufe8ug9ue8yWywDj9Avq0fXsaL5QFtMv6DujjYHzuoy4kw(paOk3fgy4NGyJsvfIsWddOjH)fQsVJkjroKPUKETkC2XeaYfl)k9oQKe5qM6s61kGdvjgm3nvP3rLKih4IKYK6SBsbvaehBosFcOlZ8udHjmfNrE0guafDwe5UMOsxqrVyrSOXHCXYhOS5ifT)IOX1Lzgn)rHIotSJgPsm4L5kfTRrNz0llAjbarRo7Muqno7fD2hubk5sfIeyJi7B5UMOsxq8oWi8tqSrP6fXGxMRuL5)rJrKzoWfjLj1z3KcQaio2CK(eqxM5PiYmoJ8Op5A0zgT6SBsbrZFuOOXPcJ0OZGkq)yqYrrFKORO5UIgPpVi6dg5hFcaIgnF0L8f583rJd5ILpqzZrQgN9Io7dQaLCPcrcSrKnaYflFGYMJeVL8fjLuNDtkabp8oWiuxsVwbuHrAsPc0pgKCuLEhvsICQlPxRWZls8j)4taqLEhvsICccLdgUcpViXN8Jpbavgz6ZdoLNCGlsktQZUjfubqCS5i9jGUmtezMthtkPBsmKbZitFEGXhuCg5rFWgfA50OZkrxelACL5QFtMr7ViAdfDwY)JGOx4Opu6ck65JwHOOXHCXYhe9OrpGO5VmfkAoW83rJd5ILpqzZrk69J2qrRo7Muqno7fD2hubk5sfIeyJiBaKlw(aLnhjEhyeitDj9Avq0fXsaL5QFtMv6DujjY5NGyJsvuPlO08jfIsaixS8bvM)hryOCGlsktQZUjfubqCS5i9jGUmtegkoJ8Or6ll6l2SSrZhnBvxN95nAoafnoKlw(aLnhPOxSiw046YmJMhmfn)rHI(GzqeTF7Zd0O5UIw3Opq0QZUjfWB0zIPOh4Or6hSOhq0mU)N)o6fgoAmVF0(NpA3C5En6foA1z3KcWeVrVSOneMIw3OnDdymNtqrJVznAYau6bZ(rZFuOOrAEcRrD0roA(O3pAdfT6SBsbrJ5den)rHI(WrXXuno7fD2hubk5sfIeyJiBaKlw(aLnhjEhyey5SXrLuLdqPl2SSrZNyR66SFomRUKETcpViXN8Jpbav6DujjYjiuoy4k88IeFYp(eauzKPpp4uEWad1L0Rv(KFTVPduIvP3rLKih4IKYK6SBsbvaehBosFcOlZ8uehadm8tqSrP68ewJ6OJC08v6DujjYHYbdxb5nrxjiTWjb5kuL7kh4IKYK6SBsbvaehBosFcOlZ8uegcB)eeBuQIkDbLMpPquca5ILpOsVJkjbMIZErN9bvGsUuHib2iYgaXXMJ0Na6Ym5DGraUiPmPo7MuGXimuC2l6SpOcuYLkejWgr2aixS8bkBoswCWfvSgL5bXJvTQ1c]] )


end
