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


    -- 587c02a72bd50631ec7949f7b257a3fab1d7100f
    spec:RegisterPack( "Subtlety", 20190709.1430, [[davIAbqikrEKssBsj1NucrgfuuNckYQucPxbfMfH0Tavv7sk)IsLHrjQJriwMsINbL00OuY1OuQTrPqFtjeghuIY5GsH1rPGMhOk3du2hLQ(huIk6GkHIfQe8qOuAIuk6IkHO2OsO6JqPsAKqjQ0jbvLSsrQxcLkXmHsLYnbvLANek)ekrvdfuvSuOe5PqAQeQUkLcSvLqPVcLIoluIkSxk(RunyjhwyXq8yrnzuDzKndvFwPA0GCAfRgkvQETiz2eDBrSBv(nWWvkhhkvSCuEUQMoPRtW2bv(oL04HsvNxjA9qjmFkH9t1grmIBq5HsgXwXYIGnS8IWYyJMi2Ywy1w2YGQl3id6wKtf7Kb9IeYGIkGOssxAq3ILsqWnIBqFGaltguiv3EBOD2TpkKasldsS7NebzOd4YSaxT7NKSDgueHrQWxNbXGYdLmITILfbBy5fHLXgnrSLTWQTeXGgckeGzqrNeS1GcnCoDgedkN(SbDvVqfqujPl9clb2fip9QEbP62BdTZU9rHeqAzqID)KiidDaxMf4QD)KKTZtVQxPfKl9cBiQxRyzrWgEb)EjITSHy1YEAp9QEHTqXTtVn0tVQxWVxlgoN4EHDzYP8sbEXj8qqQEfzDaNxY51MNEvVGFVWsucaoI7LgSDs7dUxzWXhDaNxGZl47GLI4EHdyEztkuOMNEvVGFVwmCoX9Yg8KxWxkL8np9QEb)EHLOeaCKxBGF0bCDKiNQzqLZRVrCd6RuiviIBe3iMigXnO0fisIBwWGMzJsSjmOy2lnK0Pn854DRuK6O)B0fisI7Lfw41Vrszxd2oPF7Heytk66VcyjEbpVWQxyYR1EHzVqeWXBVsHuHAcBEzHfEHiGJ3GlU5HAcBEHjdAK1bCg0hk4aRVYMuKrnITIrCdkDbIK4MfmOz2OeBcdAgKGa6BG50VXj8jpQxWdMxI4f87fM9sdjDAJt0gX6VYcn2PKgDbIK4ET2lm7fIaoEdU4MhQjS5Lfw4vGfeBuQPquhFyV25XLPgDbIK4ET2ll5Lgs60gpyP6puWbwB0fisI71AVSKxAiPtBVaIsmCHDQrxGijUxR963iPSRbBN0V9qcSjfD9xbSeVGNxy1lm5fMmOrwhWzqZHu2JSoGRlNxnOY51(fjKbfFU5HmQrmSAe3GsxGijUzbdAMnkXMWGgybXgLABedhWcLAS4s5L9W8AfVw71Vrszxd2oPF7Heytk66VcyjEbpyETIbnY6aod6UeasqKbNmQrmBze3GsxGijUzbdAK1bCg0hk4aRVYMuKbnZgLytyq1qsN2EkZiTRug6gSJa1OlqKe3R1EPHKoTHphVBLIuh9FJUarsCVw7fNqeWXB4ZX7wPi1r)3yusm37f88seVw71Vrszxd2oPF7Heytk66VcyjEbZRv8ATx6KqDf05d5f87fJsI5EVS3lB0GMxMLuxd2oPVrmrmQrmBBe3GsxGijUzbdAMnkXMWGAjV0qsN24eTrS(RSqJDkPrxGijUxR9kWcInk1qKbN6Z1viQ)qbhy9BS4s5fmVWQxR963iPSRbBN0V9qcSjfD9xbSeVG5fwnOrwhWzqFOGdS(kBsrg1iMnAe3GsxGijUzbdAMnkXMWGcxWMarsnHN6BSbWgDzNb0qhW51AVWSxAiPtB4ZX7wPi1r)3OlqKe3R1EXjebC8g(C8UvksD0)ngLeZ9EbpVeXllSWlnK0PnRuSbUK4vI1OlqKe3R1E9BKu21GTt63Eib2KIU(RawIxWdMx2YllSWRali2OuBocUrdKro6YgDbIK4ET2lebC82Vmbbi)oaVZPqHAcBET2RFJKYUgSDs)2djWMu01FfWs8cEW8cREHHxbwqSrPgIm4uFUUcr9hk4aRFJUarsCVWKbnY6aod6dfCG1xztkYOgXwegXnO0fisIBwWGMzJsSjmO)gjLDny7K(EzpmVWQbnY6aod6djWMu01FfWsmQrmSmJ4g0iRd4mOpuWbwFLnPidkDbIK4MfmQrnO0)0LP3iUrmrmIBqJSoGZGMbxMoLfkX74YiHmO0fisIBwWOgXwXiUbnY6aodkIea4DaExHOoDuYsdkDbIK4MfmQrmSAe3GgzDaNbDxiy8jUoaVhybXakKbLUarsCZcg1iMTmIBqPlqKe3SGbnZgLytyq)nsk7AW2j9BpKaBsrx)valXl7H51kEzHfEXIH3j4OtBbN)T58YEVSrlBqJSoGZGIdYcpX7bwqSrPocfjg1iMTnIBqPlqKe3SGbnZgLytyq)nsk7AW2j9BpKaBsrx)valXl7H51kEzHfEXIH3j4OtBbN)T58YEVSrlBqJSoGZGUjWg8LZT3rKXRg1iMnAe3GgzDaNbvHOUWHaeoEhhWYKbLUarsCZcg1i2IWiUbnY6aodkB22KuFU(VfzYGsxGijUzbJAedlZiUbnY6aodQvatYHJMRZOhCXLjdkDbIK4MfmQrmSHrCdkDbIK4MfmOz2OeBcdkDeBFPxWZlBzzVw7fIaoE7xMGaKFhG35uOqnHndAK1bCg0ekbWw2b4DPqE4DoJIK3Og1GYj8qqQgXnIjIrCdkDbIK4MfmOz2OeBcdQL86vkKkeXBmWUazqJSoGZGMAYPmQrSvmIBqJSoGZG(kfsfYGsxGijUzbJAedRgXnO0fisIBwWGgzDaNbnhszpY6aUUCE1GkNx7xKqg0m)nQrmBze3GsxGijUzbdAMnkXMWG(kfsfI4TqknOrwhWzqzcxpY6aUUCE1GkNx7xKqg0xPqQqe3OgXSTrCdkDbIK4MfmOz2OeBcdQojuxbD(qEzVx2OxR9IrjXCVxWZR9mVLeyVxR9kdsqa9nWC67L9W8YwEb)EHzV0jH8cEEjIL9ctETOETIbnY6aod6n7qkIm4KrnIzJgXnO0fisIBwWGc2mOpPg0iRd4mOWfSjqKKbfUqkqg0n2ayJUSZaAOd48ATx)gjLDny7K(ThsGnPOR)kGL4L9W8AfdkCbRFrczqfEQVXgaB0LDgqdDaNrnITimIBqPlqKe3SGbnZgLytyqHlytGiPMWt9n2ayJUSZaAOd4mOrwhWzqZHu2JSoGRlNxnOY51(fjKb9vkKkupZFJAedlZiUbLUarsCZcguWMb9j1GgzDaNbfUGnbIKmOWfsbYGUIT9cdV0qsN2GB2bSgDbIK4ETOEHvB7fgEPHKoTLeVsSoaV)qbhy9B0fisI71I61k22lm8sdjDA7HcoWAhhKf(gDbIK4ETOETIL9cdV0qsN2czKzJUSrxGijUxlQxIyzVWWlrSTxlQxy2RFJKYUgSDs)2djWMu01FfWs8YEyEHvVWKbfUG1ViHmOVsHuH6keJEiGKBuJyydJ4gu6cejXnlyqZSrj2egu6i2(YgNWN8OEbpyEbxWMarsTxPqQqDfIrpeqYnOrwhWzqZHu2JSoGRlNxnOY51(fjKb9vkKkupZFJAetelBe3GsxGijUzbdAMnkXMWGgybXgLA3SdPFho62P4YuJUarsCVw71Vrszxd2oPF7Heytk66VcyjEbpVwXR1EHzVYaGKdSETFzccq(DaENtHc1yusm37f8G5fw9Ycl8cZEHiGJ3(Ljia53b4DofkutyZR1EzjVELcPcr8wiLET2Rali2Ou7MDi97Wr3ofxMAS4s5L9W8cREHjVWKxR9YsEHiGJ3Uzhs)oC0TtXLPMWMxR9kdsqa9nWC67L9W8AfdAK1bCg0B2HuezWjJAetermIBqPlqKe3SGbnZgLytyqZGeeqFdmN(noHp5r9cEW8seVSWcV0jH6kOZhYl4bZlr8ATxzqccOVbMtFVShMxy1GgzDaNbnhszpY6aUUCE1GkNx7xKqgu85MhYOgXezfJ4gu6cejXnlyqZSrj2eg0FJKYUgSDs)2djWMu01FfWs8cMx2YR1ELbjiG(gyo99YEyEzldAK1bCg0CiL9iRd46Y5vdQCETFrczqXNBEiJAeteSAe3GsxGijUzbdAMnkXMWGshX2x24e(Kh1l4bZl4c2eisQ9kfsfQRqm6HasUbnY6aodAoKYEK1bCD58QbvoV2ViHmOicJKBuJyIylJ4gu6cejXnlyqZSrj2egu6i2(YgNWN8OEzpmVeX2EHHx0rS9LngTtNbnY6aodAWYXrDfWy0Pg1iMi22iUbnY6aodAWYXr9nb5tgu6cejXnlyuJyIyJgXnOrwhWzqLZoK(DS7c89e6udkDbIK4MfmQrnOBmkdsqc1iUrmrmIBqJSoGZG(kfsfYGsxGijUzbJAeBfJ4gu6cejXnlyqJSoGZGMeSueVJdyDofkKbDJrzqcsO9NYGJ)gurSTrnIHvJ4gu6cejXnlyqJSoGZG(qbhyTJido9g0ngLbjiH2Fkdo(BqfXOgXSLrCdAK1bCg0nGoGZGsxGijUzbJAudk(CZdze3iMigXnO0fisIBwWGMzJsSjmOAiPtBpuWbw74GSW3OlqKe3R1EHiGJ3Uzhs)oC0TtXLPMWMxR963iPSRbBN0V9qcSjfD9xbSeVShMxR4fgEHvVwuV0qsN2EkZiTRug6gSJa1OlqKe3GgzDaNbLGB(mXcLmQrSvmIBqPlqKe3SGbnZgLytyqXSxwYlnK0PnEWs1FOGdS2OlqKe3llSWll5fIaoE7HcoWANhxMAcBEHjVw7LojuxbD(qEb)EXOKyU3l79Yg9ATxmkjM79cEEPtovxNeYRf1RvmOrwhWzqVzhsrKbNmQrmSAe3GsxGijUzbdAK1bCg0B2HuezWjdAMnkXMWGAjVGlytGiPMWt9n2ayJUSZaAOd48ATx)gjLDny7K(ThsGnPOR)kGL4L9W8AfVw7fM9kWcInk1Uzhs)oC0TtXLPgDbIK4EzHfEzjVcSGyJsngTjNCOZT3FOGdS(n6cejX9Ycl863iPSRbBN0V9qcSjfD9xbSeVGFVISoWrDoqB3SdPiYGtEzpmVwXlm51AVSKxic44Thk4aRDECzQjS51AV0jH6kOZhYl7H5fM9Y2EHHxy2Rv8Ar9kdsqa9nWC67fM8ctET2lgHZOhkqKKbnVmlPUgSDsFJyIyuJy2YiUbLUarsCZcg0mBuInHbLrjXCVxWZRmai5aRx7xMGaKFhG35uOqngLeZ9EHHxIyzVw7vgaKCG1R9ltqaYVdW7CkuOgJsI5EVGhmVSTxR9sNeQRGoFiVGFVyusm37L9ELbajhy9A)YeeG87a8oNcfQXOKyU3lm8Y2g0iRd4mO3SdPiYGtg1iMTnIBqPlqKe3SGbnZgLytyqreWXB)YeeG87a8oNcfQjS51AVWSxwYlnK0PnEWs1FOGdS2OlqKe3llSWlebC82dfCG1opUm1e28ctg0iRd4mOpLzK2vkdDd2rGmQrmB0iUbLUarsCZcg0mBuInHb93iPSRbBN0V9qcSjfD9xbSeVShMxR4fgEPHKoTXdwQ(dfCG1gDbIK4EHHxAiPtB3SdPVgYueRrxGijUbnY6aod6tzgPDLYq3GDeiJAeBrye3GgzDaNbLGB(mXcLmO0fisIBwWOg1GM5VrCJyIye3GsxGijUzbdAMnkXMWGIiGJ3qKaaxk8AJrrw9Ycl8crahV9ltqaYVdW7CkuOMWMxR9cZEHiGJ3EOGdS2rKbN(MWMxwyHxzaqYbwV2dfCG1oIm403yusm37f8G5Liw2lmzqJSoGZGUb0bCg1i2kgXnO0fisIBwWGgzDaNbfUGnbIK6ZP09JUSVp7bCaP2bFEKYqNBVZOiRaMbnZgLytyqreWXB)YeeG87a8oNcfQjS5Lfw4LojuxbD(qEbpVwXYg0lsidkCbBcej1NtP7hDzFF2d4asTd(8iLHo3ENrrwbmJAedRgXnO0fisIBwWGMzJsSjmOic44TFzccq(DaENtHc1e2mOrwhWzqfEQpkL8g1iMTmIBqPlqKe3SGbnZgLytyqreWXB)YeeG87a8oNcfQjSzqJSoGZGIibaEhxGT0OgXSTrCdkDbIK4MfmOz2OeBcdkIaoE7xMGaKFhG35uOqnHndAK1bCgueI9el1C7g1iMnAe3GsxGijUzbdAMnkXMWGIiGJ3(Ljia53b4DofkutyZGgzDaNbfFyeIea4g1i2IWiUbLUarsCZcg0mBuInHbfrahV9ltqaYVdW7CkuOMWMbnY6aodACz6vwi75qknQrmSmJ4gu6cejXnlyqZSrj2egul5fIaoE7HcoWANhxMAcBET2lebC82djWMu01va7coOjS51AVqeWXBpKaBsrxxbSl4GgJsI5EVGhmVWAZ2g0iRd4mOpuWbw784YKbv4PoahVVN5gurmQrmSHrCdkDbIK4MfmOz2OeBcdkIaoE7Heytk66kGDbh0e28ATxic44ThsGnPORRa2fCqJrjXCVxWdMxyTzBdAK1bCg0Fzccq(DaENtHczqfEQdWX77zUbveJAetelBe3GsxGijUzbdAMnkXMWGAjVELcPcr8wiLET2loqB3SdPiYGtnDYPMB3GgzDaNbnhszpY6aUUCE1GkNx7xKqgu6F6Y0BuJyIiIrCdkDbIK4MfmOrwhWzq3aazNrpqGLjdAMnkXMWGAjV0qsN2EOGdS2XbzHVrxGijUbfhW6hH9QrmrmQrmrwXiUbLUarsCZcg0mBuInHbLoITV0l7H5LnAzVw7fhOTB2HuezWPMo5uZT71AVYaGKdSETFzccq(DaENtHc1e28ATxzaqYbwV2dfCG1opUm1YqbBNEVShMxIyqJSoGZG(qcSjfDDfWUGdmQrmrWQrCdkDbIK4MfmOz2OeBcdkhOTB2HuezWPMo5uZT71AVWSxwYlnK0PThsGnPORRa2fCqJUarsCVSWcV0qsN2EOGdS2XbzHVrxGijUxwyHxzaqYbwV2djWMu01va7coOXOKyU3l79AfVWKbnY6aod6Vmbbi)oaVZPqHmQrmrSLrCdkDbIK4MfmOrwhWzqtcwkI3XbSoNcfYGMzJsSjmOSy4Dco60wW5FtyZR1EHzV0jH6kOZhYl45vgKGa6BG50VXj8jpQxwyHxwYRxPqQqeVfsPxR9kdsqa9nWC634e(Kh1l7H5vERNeyF)3OJ7fMmO5Lzj11GTt6BeteJAeteBBe3GsxGijUzbdAMnkXMWGYIH3j4OtBbN)T58YEVWQL9c(9IfdVtWrN2co)BCbwOd48ATxwYRxPqQqeVfsPxR9kdsqa9nWC634e(Kh1l7H5vERNeyF)3OJBqJSoGZGMeSueVJdyDofkKrnIjInAe3GsxGijUzbdAMnkXMWGMbjiG(gyo9BCcFYJ6L9W8AfVWWRxPqQqeVfsPbnY6aod6dfCG1oIm40BuJyISimIBqPlqKe3SGbnZgLytyq1qsN2EOGdS2XbzHVrxGijUxR9Id02n7qkIm4utNCQ529ATxic44TFzccq(DaENtHc1e2mOrwhWzqFib2KIUUcyxWbg1iMiyzgXnO0fisIBwWGMzJsSjmOwYlebC82dfCG1opUm1e28ATx6KqDf05d5f8G5LT9cdV0qsN2EbeLy4c7uJUarsCVw7LL8IfdVtWrN2co)BcBg0iRd4mOpuWbw784YKrnQb9vkKkupZFJ4gXeXiUbLUarsCZcguWMb9j1GgzDaNbfUGnbIKmOWfsbYGMbajhy9ApuWbw784YuldfSD674SiRd4cPx2dZlrAlcBBqHly9lsid6dX7keJEiGKBuJyRye3GsxGijUzbdAMnkXMWGAjVGlytGiP2dX7keJEiGK71AVYGeeqFdmN(noHp5r9YEVeXR1EXjebC8g(C8UvksD0)ngLeZ9EbpVeXGgzDaNbfU4MhYOgXWQrCdkDbIK4MfmOrwhWzq3aazNrpqGLjdkH9kl6rcq4udQTSSbfhW6hH9QrmrmQrmBze3GsxGijUzbdAMnkXMWGshX2x6L9W8Yww2R1ErhX2x24e(Kh1l7H5Liw2R1EzjVGlytGiP2dX7keJEiGK71AVYGeeqFdmN(noHp5r9YEVeXR1EXjebC8g(C8UvksD0)ngLeZ9EbpVeXGgzDaNb9HcoWAcj5g1iMTnIBqPlqKe3SGbfSzqFsnOrwhWzqHlytGijdkCHuGmOzqccOVbMt)gNWN8OEzpmVSLbfUG1ViHmOpeVNbjiG(gyo9nQrmB0iUbLUarsCZcguWMb9j1GgzDaNbfUGnbIKmOWfsbYGMbjiG(gyo9BCcFYJ6f8G5LiEHHxR41I6vGfeBuQPquhFyV25XLPgDbIK4g0mBuInHbfUGnbIKAcp13ydGn6YodOHoGZR1EHzV0qsN2UzhsFnKPiwJUarsCVSWcV0qsN24blv)HcoWAJUarsCVWKbfUG1ViHmOpeVNbjiG(gyo9nQrSfHrCdkDbIK4MfmOz2OeBcdkCbBcej1EiEpdsqa9nWC671AVWSxwYlnK0PnEWs1FOGdS2OlqKe3llSWloqB3SdPiYGtngLeZ9EzpmVSTxy4Lgs602lGOedxyNA0fisI7fM8ATxy2l4c2eisQ9q8UcXOhci5EzHfEHiGJ3(Ljia53b4DofkuJrjXCVx2dZlrAR4Lfw41Vrszxd2oPF7Heytk66VcyjEzpmVSLxR9kdasoW61(Ljia53b4DofkuJrjXCVx27Liw2lm51AVWSxbwqSrP2n7q63HJUDkUm1yXLYl45fw9Ycl8crahVDZoK(D4OBNIltnHnVWKbnY6aod6dfCG1opUmzuJyyzgXnO0fisIBwWGMzJsSjmOWfSjqKu7H49mibb03aZPVxR9sNeQRGoFiVGNxzaqYbwV2Vmbbi)oaVZPqHAmkjM79ATxwYlwm8obhDAl48VjSzqJSoGZG(qbhyTZJltg1OgueHrYnIBeteJ4gu6cejXnlyqZSrj2eg0FJKYUgSDsFVShMxR4fgEHzV0qsN22LaqcIm4uJUarsCVw7vGfeBuQTrmCaluQXIlLx2dZRv8ctg0iRd4mOpKaBsrx)valXOgXwXiUbnY6aod6UeasqKbNmO0fisIBwWOgXWQrCdAK1bCguKiN61aXGsxGijUzbJAuJAqHJy)aoJyRyzrWgw2gxX2nlJnWQTnOwd2n3(BqHVs2amL4EHL5vK1bCEjNx)MN2G(Bu2i2k2Oig0ngaFKKbDvVqfqujPl9clb2fip9QEbP62BdTZU9rHeqAzqID)KiidDaxMf4QD)KKTZtVQxPfKl9cBiQxRyzrWgEb)EjITSHy1YEAp9QEHTqXTtVn0tVQxWVxlgoN4EHDzYP8sbEXj8qqQEfzDaNxY51MNEvVGFVWsucaoI7LgSDs7dUxzWXhDaNxGZl47GLI4EHdyEztkuOMNEvVGFVwmCoX9Yg8KxWxkL8np9QEb)EHLOeaCKxBGF0bCDKiNQ5P90R61Im2tzbL4EHq4ag5vgKGeQxi0(CFZRftotB671bo4hkyj4csVISoG79cCYLnp9QEfzDa332yugKGekmCz8P80R6vK1bCFBJrzqcsOyaZUqypHon0bCE6v9kY6aUVTXOmibjumGzhoaW90R6f6fBpeq9Ifd3lebCCI71RH(EHq4ag5vgKGeQxi0(CVxXX9AJrW)gq1529AEV4GJAE6v9kY6aUVTXOmibjumGz3FX2db0(RH(E6iRd4(2gJYGeKqXaMDVsHuH80rwhW9TngLbjiHIbm7scwkI3XbSoNcfs0ngLbjiH2Fkdo(dteB7PJSoG7BBmkdsqcfdy29qbhyTJido9IUXOmibj0(tzWXFyI4PJSoG7BBmkdsqcfdy2Tb0bCEAp9QETiJ9uwqjUxeCeBPx6KqEPqKxrwbmVM3RaUyKbIKAE6v9clrVsHuH8AW9Ad8)GijVW8b8cob5rSarsErhLm071CELbjiHIjpDK1bCpgWSl1Ktj6GdZsVsHuHiEJb2fipDK1bCpSxPqQqE6v9cBHOCkVWwB(EfQx4d7vpDK1bCpgWSlhszpY6aUUCEv0lsiyz(7Px1lSKW5fUGuU0R36Ozi69sbEPqKxOkfsfI4EHLaAOd48cZil9IdMB3RhiQxJ6foGLP3Rnaqo3UxdUxhqHMB3R59kGlgzGijm180rwhW9yaZoMW1JSoGRlNxf9Iec2RuiviIl6Gd7vkKkeXBHu6Px1RfZ2MCPxIn7qkIm4KxH61ky4f2cF8IlWMB3lfI8cFyV6Liw2RNYGJ)I6vGReZlfkuVSfgEHTWhVgCVg1lc73gg9EzDuO58sHiVoc7vVWUIT20laZR596aQxcBE6iRd4EmGz3n7qkIm4KOdomDsOUc68HS3gxZOKyUhE7zEljW(1zqccOVbMtF7Hzl4hZ6KqWtelJPfDfp9QEHL)Kl9kdf3o5fdOHoGZRb3lRKxqbCKxBSbWgDzNb0qhW51tQxXX9krqQZMK8sd2oPVxcBnpDK1bCpgWSdUGnbIKe9IecMWt9n2ayJUSZaAOd4efUqkqW2ydGn6YodOHoGB9Vrszxd2oPF7Heytk66Vcyj2dBfp9QEbFydGn6sVWsan0bCy50lSBKUi9ETpWrEfELzXMxbcqq9IoITV0lCaZlfI86vkKkKxyRnFVWmIWi5eZRxhP0lg9Buw9Aum18clhcBI61OELJZleYlfkuV(jztsnpDK1bCpgWSlhszpY6aUUCEv0lsiyVsHuH6z(l6GddUGnbIKAcp13ydGn6YodOHoGZtVQx2GN4EPaV4e(CKxwHOZlf4LWtE9kfsfYlS1MVxaMxicJKtS3thzDa3Jbm7GlytGijrViHG9kfsfQRqm6HasUOWfsbc2k2gdnK0Pn4MDaRrxGij(IIvBJHgs60ws8kX6a8(dfCG1VrxGij(IUITXqdjDA7HcoWAhhKf(gDbIK4l6kwgdnK0PTqgz2OlB0fisIVOIyzmeX2lkM)nsk7AW2j9BpKaBsrx)valXEyyftE6v9cBb3pCI5LWp3UxHxOkfsfYlS1MEzfIoVyuKHMB3lfI8IoITV0lfIrpeqY90rwhW9yaZUCiL9iRd46Y5vrViHG9kfsfQN5VOdom6i2(YgNWN8OWdgCbBcej1ELcPc1vig9qaj3tVQxIn7q6I071ILUDkUmzd9sSzhsrKbN8cHWbmYl0Ljia57vOEjbw9cBHpEPaVYGeK5iVOGjx6fJWz0d5L1rH8ANuDUDVuiYlebCCVe2AETyKpWljWQxyl8XlUaBUDVqxMGaKVxab9ho5LnJltEzDuiVWQxITyBE6iRd4EmGz3n7qkIm4KOdoSali2Ou7MDi97Wr3ofxMA0fisIV(3iPSRbBN0V9qcSjfD9xbSe4TYAmNbajhy9A)YeeG87a8oNcfQXOKyUhEWWQfwGzebC82Vmbbi)oaVZPqHAcBRT0RuiviI3cPCDGfeBuQDZoK(D4OBNIltnwCPShgwXeMwBjebC82n7q63HJUDkUm1e2wNbjiG(gyo9Th2kE6v9AXNBEiVc1lBHHxwhfciOEztur9Y2y4L1rH8YMOEHzGG(dN86vkKkeM80rwhW9yaZUCiL9iRd46Y5vrViHGHp38qIo4WYGeeqFdmN(noHp5rHhmrSWcDsOUc68HGhmrwNbjiG(gyo9Thgw90R6f2CuiVSjQxH8bEHp38qEfQx2cdVI9yUx9IW(iRYLEzlV0GTt67fMbc6pCYRxPqQqyYthzDa3Jbm7YHu2JSoGRlNxf9Iecg(CZdj6Gd73iPSRbBN0V9qcSjfD9xbSey2ADgKGa6BG503Ey2YtVQx2GN8k8cryKCI5Lvi68IrrgAUDVuiYl6i2(sVuig9qaj3thzDa3Jbm7YHu2JSoGRlNxf9IecgIWi5Io4WOJy7lBCcFYJcpyWfSjqKu7vkKkuxHy0dbKCp9QEHDdyLE1Rn2ayJU0R58kKsVa4EPqKxlg4d2nVqOCi8KxJ6voeE69k8c7k2AtpDK1bCpgWSly54OUcym6urhCy0rS9LnoHp5rThMi2gd6i2(YgJ2PZthzDa3Jbm7cwooQVjiFYthzDa3Jbm7KZoK(DS7c89e6upTNEvVwqyKCI9E6iRd4(gIWi5WEib2KIU(RawIOdoSFJKYUgSDsF7HTcgywdjDABxcajiYGtn6cejXxhybXgLABedhWcLAS4szpSvWKNoY6aUVHimsogWSBxcajiYGtE6iRd4(gIWi5yaZoKiN61aXt7Px1lSfaKCG1790rwhW9Tm)HTb0bCIo4WqeWXBisaGlfETXOiRwybIaoE7xMGaKFhG35uOqnHT1ygrahV9qbhyTJido9nHnlSidasoW61EOGdS2rKbN(gJsI5E4btelJjp9QET4Huo3UxiroLxkWloHhcs1RrPeVe(yNSHEzdEYlRJc5f6YeeG89cG7LnPqHAE6iRd4(wM)yaZoHN6JsjIErcbdUGnbIK6ZP09JUSVp7bCaP2bFEKYqNBVZOiRaMOdomebC82Vmbbi)oaVZPqHAcBwyHojuxbD(qWBfl7PJSoG7Bz(Jbm7eEQpkL8Io4WqeWXB)YeeG87a8oNcfQjS5PJSoG7Bz(Jbm7qKaaVJlWwk6GddrahV9ltqaYVdW7CkuOMWMNoY6aUVL5pgWSdHypXsn3UOdomebC82Vmbbi)oaVZPqHAcBE6iRd4(wM)yaZo8HrisaGl6GddrahV9ltqaYVdW7CkuOMWMNoY6aUVL5pgWSlUm9klK9CiLIo4WqeWXB)YeeG87a8oNcfQjS5Px1lBWtEzZ4YKxaCC4FpZ9cHWbmYlfI8cFyV6fkKaBsrNxOkGL4fodK4L4a2fCGxzqc9EnxZthzDa33Y8hdy29qbhyTZJltIk8uhGJ33ZCyIi6GdZsic44Thk4aRDECzQjSTgrahV9qcSjfDDfWUGdAcBRreWXBpKaBsrxxbSl4GgJsI5E4bdRnB7Px1lmBdoj9VxHKrbFPxcBEHq5q4jVSsEPaqkVqHcoWQxloil8yYlHN8cDzccq(EbWXH)9m3lechWiVuiYl8H9QxOqcSjfDEHQawIx4mqIxIdyxWbELbj071CnpDK1bCFlZFmGz3Vmbbi)oaVZPqHev4PoahVVN5Wer0bhgIaoE7Heytk66kGDbh0e2wJiGJ3Eib2KIUUcyxWbngLeZ9WdgwB22thzDa33Y8hdy2LdPShzDaxxoVk6fjem6F6Y0l6GdZsVsHuHiElKY1CG2UzhsrKbNA6Ktn3UNEvVGpaG0lCaZlXbSl4aV2ye8JcSPxwhfYluiB6fJc(sVScrNxhq9IjC3C7EHU4npDK1bCFlZFmGz3gai7m6bcSmjkoG1pc7vyIi6GdZsAiPtBpuWbw74GSW3OlqKe3tVQx2GN8sCa7coWRng5fkWMEzfIoVSsEbfWrEPqKx0rS9LEzfIuiI5fodK41gaiNB3lRJcbeuVqxCVamVWUl8Qx70rSqkx280rwhW9Tm)XaMDpKaBsrxxbSl4arhCy0rS9L2dZgT8AoqB3SdPiYGtnDYPMBFDgaKCG1R9ltqaYVdW7CkuOMW26mai5aRx7HcoWANhxMAzOGTtV9WeXtVQx2GN8cDzccq(EboVYaGKdSEEH5axjMx4d7vVeB2HuezWjm5LWjP)9Yk5vWiV2bZT7Lc8AdS5L4a2fCGxXX9Id86aQxqbCKxOqbhy1RfhKf(MNoY6aUVL5pgWS7xMGaKFhG35uOqIo4W4aTDZoKIido10jNAU91y2sAiPtBpKaBsrxxbSl4GgDbIK4wyHgs602dfCG1ooil8n6cejXTWImai5aRx7Heytk66kGDbh0yusm3B)kyYtVQxWx4EfC(7vWiVe2e1R)MnYlfI8cCKxwhfYljWk9QxIlUnBEzdEYlRq05fF5C7EHhVsmVuO48cBHpEXj8jpQxaMxhq96vkKkeX9Y6Oqab1R4w6f2cFAE6iRd4(wM)yaZUKGLI4DCaRZPqHenVmlPUgSDsFyIi6GdJfdVtWrN2co)BcBRXSojuxbD(qWldsqa9nWC634e(Kh1clS0RuiviI3cPCDgKGa6BG50VXj8jpQ9WYB9Ka77)gDCm5Px1l4lCVoGxbN)EzDKsV4d5L1rHMZlfI86iSx9cRw(f1lHN8c(g3MEboVqa)7L1rHacQxXT0lSf(4vCCVoGxVsHuHAE6iRd4(wM)yaZUKGLI4DCaRZPqHeDWHXIH3j4OtBbN)T5ShRwg(zXW7eC0PTGZ)gxGf6aU1w6vkKkeXBHuUodsqa9nWC634e(Kh1Ey5TEsG99FJoUNoY6aUVL5pgWS7HcoWAhrgC6fDWHLbjiG(gyo9BCcFYJApSvW4vkKkeXBHu6Px1lS5OqEHU4I61G71buVcjJc(sV4GJe1lHN8sCa7coWlRJc5fkWMEjS180rwhW9Tm)XaMDpKaBsrxxbSl4arhCyAiPtBpuWbw74GSW3OlqKeFnhOTB2HuezWPMo5uZTVgrahV9ltqaYVdW7CkuOMWMNoY6aUVL5pgWS7HcoWANhxMeDWHzjebC82dfCG1opUm1e2wRtc1vqNpe8GzBm0qsN2EbeLy4c7uJUars81wIfdVtWrN2co)BcBEAp9QETi)pDz690rwhW9n6F6Y0dldUmDkluI3XLrc5PJSoG7B0)0LPhdy2HibaEhG3viQthLS0thzDa33O)PltpgWSBxiy8jUoaVhybXakKNoY6aUVr)txMEmGzhoil8eVhybXgL6iuKi6Gd73iPSRbBN0V9qcSjfD9xbSe7HTIfwWIH3j4OtBbN)T5S3gTSNoY6aUVr)txMEmGz3MaBWxo3EhrgVk6Gd73iPSRbBN0V9qcSjfD9xbSe7HTIfwWIH3j4OtBbN)T5S3gTSNoY6aUVr)txMEmGzNcrDHdbiC8ooGLjpDK1bCFJ(NUm9yaZo2STjP(C9FlYKNoY6aUVr)txMEmGzNvatYHJMRZOhCXLjpDK1bCFJ(NUm9yaZUekbWw2b4DPqE4DoJIKx0bhgDeBFj8SLLxJiGJ3(Ljia53b4DofkutyZt7Px1RfFU5Hi27Px1Rfz4MptSqjVGMDi6vV2ydGn6sVc1RvWWlny7K(EzDuiVqHcoWQxloil8EHzBJHxwhfYlukZi1lXPm0nyhbYR58k48rhWHjVIJ7LyZoKUi9ETyPBNIltEjS180rwhW9n85Mhcgb38zIfkj6GdtdjDA7HcoWAhhKf(gDbIK4RreWXB3SdPFho62P4YutyB9Vrszxd2oPF7Heytk66Vcyj2dBfmW6IQHKoT9uMrAxPm0nyhbQrxGijUNEvVWUq0MxcBEj2SdPiYGtEn4EnQxZ7vGaeuVuGxmHZlGG28YMaVoG6LWtEj2cEXfyZT7LnJltI61G7Lgs6uI71CkWlBgSuEHcfCG1MNoY6aUVHp38qyaZUB2HuezWjrhCyy2sAiPtB8GLQ)qbhyTrxGijUfwyjebC82dfCG1opUm1e2W0ADsOUc68HGFgLeZ92BJRzusm3dpDYP66Kql6kE6v9c(wqQdhO6C7Ebe0F4Kx2mUm5f48sd2oPVxkuOEzDKsVKdCKx4aMxke5fxGf6aoVa4Ej2SdPiYGtI6fJWz0d5fxGn3UxBXXPKj38c(wqQdhOEfVxsWT7v8ETcgEPbBN03loWRdOEbfWrEj2SdPiYGtEjS5L1rH8clrBYjh6C7EHcfCG13lmlCs6FVwce8ckGJ8sSzhsxKEVwS0TtXLjVuaatnpDK1bCFdFU5HWaMD3SdPiYGtIMxMLuxd2oPpmreDWHzj4c2eisQj8uFJna2Ol7mGg6aU1)gjLDny7K(ThsGnPOR)kGLypSvwJ5ali2Ou7MDi97Wr3ofxMA0fisIBHfwkWcInk1y0MCYHo3E)HcoW63OlqKe3cl(nsk7AW2j9BpKaBsrx)valb(JSoWrDoqB3SdPiYGt2dBfmT2sic44Thk4aRDECzQjSTwNeQRGoFi7HHzBJbMxzrZGeeqFdmN(yctRzeoJEOarsE6v9clr4m6H8sSzhsrKbN8IcMCPxdUxJ6L1rk9IW(THrEXfyZT7f6YeeG8BEztGxkuOEXiCg9qEn4EHcSPx7K(EXOGV0R58sHiVoc7vVS9380rwhW9n85Mhcdy2DZoKIidoj6GdJrjXCp8YaGKdSETFzccq(DaENtHc1yusm3JHiwEDgaKCG1R9ltqaYVdW7CkuOgJsI5E4bZ2R1jH6kOZhc(zusm3BFgaKCG1R9ltqaYVdW7CkuOgJsI5EmSTNEvVqPmJuVeNYq3GDeiV4cS529cDzccq(nVWMJc5LndwkVqHcoWQxGtU0lUaBUDVqHcoWQx2mUm5fMfoDKEPqm6HasUxZ51ryV6LCoctnpDK1bCFdFU5HWaMDpLzK2vkdDd2rGeDWHHiGJ3(Ljia53b4DofkutyBnMTKgs60gpyP6puWbwB0fisIBHfic44Thk4aRDECzQjSHjp9QEHnhfYl6ac7qEPbBN03RqAnw(Ej8KxOuwCk7f48cBTzZthzDa33WNBEimGz3tzgPDLYq3GDeirhCy)gjLDny7K(ThsGnPOR)kGLypSvWqdjDAJhSu9hk4aRn6cejXXqdjDA7MDi91qMIyn6cejX90rwhW9n85Mhcdy2rWnFMyHsEAp9QEHQuiviVWwaqYbwV3tVQxy5sYnI51InytGijpDK1bCF7vkKkupZFyWfSjqKKOxKqWEiExHy0dbKCrHlKceSmai5aRx7HcoWANhxMAzOGTtFhNfzDaxiThMiTfHT90R61InU5H8s4K0)EzL8kyKxbcqq9sbELJnVaNx2mUm5vgky7038cl)jx6Lvi68AXNJ7f2KIuh9VxZ7vGaeuVuGxmHZlGG280rwhW9TxPqQq9m)XaMDWf38qIo4WSeCbBcej1EiExHy0dbK81zqccOVbMt)gNWN8O2lYAoHiGJ3WNJ3TsrQJ(VXOKyUhEI4Px1l4dai9chW8cfk4aRjKK7fgEHcfCG1xztkYlHts)7LvYRGrEfiab1lf4vo28cCEzZ4YKxzOGTtFZlS8NCPxwHOZRfFoUxytksD0)EnVxbcqq9sbEXeoVacAZthzDa33ELcPc1Z8hdy2TbaYoJEGaltIIdy9JWEfMiIsyVYIEKaeofMTSSNoY6aUV9kfsfQN5pgWS7HcoWAcj5Io4WOJy7lThMTS8A6i2(YgNWN8O2dtelV2sWfSjqKu7H4DfIrpeqYxNbjiG(gyo9BCcFYJAViR5eIaoEdFoE3kfPo6)gJsI5E4jINEvVWw4Jxmc7immkHo1g6LnJltEfQxsGvVWw4Jxil9It4HGuBE6iRd4(2RuivOEM)yaZo4c2eiss0lsiypeVNbjiG(gyo9ffUqkqWYGeeqFdmN(noHp5rThMT80R6f2cF8IryhHHrj0P2qVSzCzYlWjx6fcHdyKx4ZnpeXEVgCVSsEbfWrEfjBEPHKo99koUxBSbWgDPxmGg6aUMNoY6aUV9kfsfQN5pgWSdUGnbIKe9Iec2dX7zqccOVbMtFrHlKceSmibb03aZPFJt4tEu4btemwzrdSGyJsnfI64d71opUm1OlqKex0bhgCbBcej1eEQVXgaB0LDgqdDa3AmRHKoTDZoK(AitrSgDbIK4wyHgs60gpyP6puWbwB0fisIJjp9QEHnhfYlBgSuEHcfCGvVaNCPx2mUm5Lvi68sSzhsrKbN8Y6iLE9AS0lHTMx2GN8IlWMB3l0Ljia57fG5vGaGJ8sHy0dbK8MxyZyuVWbmVeBX6fIaoUxwhfYlSk2IT5PJSoG7BVsHuH6z(Jbm7EOGdS25XLjrhCyWfSjqKu7H49mibb03aZP)AmBjnK0PnEWs1FOGdS2OlqKe3cl4aTDZoKIido1yusm3BpmBJHgs602lGOedxyNA0fisIJP1ygUGnbIKApeVRqm6HasUfwGiGJ3(Ljia53b4DofkuJrjXCV9WePTIfw8BKu21GTt63Eib2KIU(RawI9WS16mai5aRx7xMGaKFhG35uOqngLeZ92lILX0AmhybXgLA3SdPFho62P4YuJfxk4HvlSarahVDZoK(D4OBNIltnHnm5Px1RfeyNxmkjMBUDVSzCz69cHWbmYlfI8sd2oPEXh69AW9cfytVScUfj1leYlgf8LEnNx6KqnpDK1bCF7vkKkupZFmGz3dfCG1opUmj6GddUGnbIKApeVNbjiG(gyo9xRtc1vqNpe8YaGKdSETFzccq(DaENtHc1yusm3V2sSy4Dco60wW5FtyZt7Px1luLcPcrCVWsan0bCE6v9c(c3luLcPczhCXnpKxbJ8sytuVeEYluOGdS(kBsrEPaVqOJWh1lCgiXlfI8Al(FGJ8cbCcVxXX9AXNJ7f2KIuh9VOErWrNxdUxwjVcg5vOELeyVxyl8XlmJZajEPqKxBmkdsqc1l4BCBIPMNoY6aUV9kfsfI4WEOGdS(kBsrIo4WWSgs60g(C8UvksD0)n6cejXTWIFJKYUgSDs)2djWMu01FfWsGhwX0AmJiGJ3ELcPc1e2SWcebC8gCXnputydtE6v9AXNBEiVc1lBHHxyl8XlRJcbeuVSjQOEzBm8Y6OqEztur9koUx2OxwhfYlBI6vGReZRfBCZd5fG5L4qKxl(WE1lBgxM8koUxhWlBgSuEHcfCGvVWWRd4fQaIsmCHDYthzDa33ELcPcrCmGzxoKYEK1bCD58QOxKqWWNBEirhCyzqccOVbMt)gNWN8OWdMiWpM1qsN24eTrS(RSqJDkPrxGij(AmJiGJ3GlU5HAcBwyrGfeBuQPquhFyV25XLPgDbIK4RTKgs60gpyP6puWbwB0fisIV2sAiPtBVaIsmCHDQrxGij(6FJKYUgSDs)2djWMu01FfWsGhwXeM80R6Ln4jVWUkbGeezWjVaWrmVqHcoW6RSjf5vCCVqvalXlRJc51ky4f8Hy4awOKxH61kEbyEjP)9sd2oPFZthzDa33ELcPcrCmGz3UeasqKbNeDWHfybXgLABedhWcLAS4szpSvw)BKu21GTt63Eib2KIU(Rawc8GTINEvVwmQxR4LgSDsFVSokKxOuMrQxItzOBWocKxPiAZlHnVw854EHnPi1r)7fYsVYlZY529cfk4aRVYMuuZthzDa33ELcPcrCmGz3dfCG1xztks08YSK6AW2j9HjIOdomnK0PTNYms7kLHUb7iqn6cejXxRHKoTHphVBLIuh9FJUars81CcrahVHphVBLIuh9FJrjXCp8ez9Vrszxd2oPF7Heytk66VcyjWwzTojuxbD(qWpJsI5E7Trp9QEHnhfciOEztI2iMxOkl0yNs8koUxy1lSuCPEVa4ETGm4KxZ5LcrEHcfCG13Rr9AEVScykKxc)C7EHcfCG1xztkYlW5fw9sd2oPFZthzDa33ELcPcrCmGz3dfCG1xztks0bhML0qsN24eTrS(RSqJDkPrxGij(6ali2OudrgCQpxxHO(dfCG1VXIlfmSU(3iPSRbBN0V9qcSjfD9xbSeyy1tVQxloG51gBaSrx6fdOHoGtuVeEYluOGdS(kBsrEbGJyEHQawIxIGjVSokKxyt4BVI9yUx9syZlf4LT8sd2oPVOETcM8AW9AXXMEnVxmH7MB3laoUxygCEf3sVIeGWPEbW9sd2oPpMe1laZlSIjVuGxjb2pjdwqEHcSPxe2R09d48Y6OqEbFDeCJgiJC0LEboVWQxAW2j99cZ2YlRJc51cJIIPMNoY6aUV9kfsfI4yaZUhk4aRVYMuKOdom4c2eisQj8uFJna2Ol7mGg6aU1ywdjDAdFoE3kfPo6)gDbIK4R5eIaoEdFoE3kfPo6)gJsI5E4jIfwOHKoTzLInWLeVsSgDbIK4R)nsk7AW2j9BpKaBsrx)valbEWSLfweybXgLAZrWnAGmYrx2OlqKeFnIaoE7xMGaKFhG35uOqnHT1)gjLDny7K(ThsGnPOR)kGLapyyfJali2OudrgCQpxxHO(dfCG1VrxGijoM80rwhW9TxPqQqehdy29qcSjfD9xbSerhCy)gjLDny7K(2ddRE6iRd4(2RuiviIJbm7EOGdS(kBsrg1Ogd]] )


end
