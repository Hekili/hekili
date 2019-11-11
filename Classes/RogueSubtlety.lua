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


    spec:RegisterPack( "Subtlety", 20191111, [[daLgLbqiiIhbr1MKK(KkcXOGQYPGOSkve1RqvmluvUffI2LO(LKIHHQuhdQYYuH8muLmnjL6AsISnve8nisQXbrsohfsSoveQ5PI09uP2NKW)GiLQdQIiTqvOEiuv1eLe1fHiLSris1hPqs1iHiLItcrkwPkQxsHKYmPqsCtke0orv1pPqsAOqKyPuiLNcLPsH6Qui0wvreFLcP6SqKsP9sP)kYGL6WuTyi9yjMmHlJSzq(megnOoTIvRIq61QGzt0TPODRQFR0WvjhNcbwokphy6KUoQSDOIVtbJhQQCEjvRxsjZhQ0(f2IN1ylMWvYY)r8gpJcE4HhEz8oQs8IxivwmT(fzXU8YbhbzXE3KSyyCOQK06wSlVUCDH1ylgy5yfYIbR6f4extnigfMdnxwZAaJjN01z)cZH0AaJzPglgk3ivKM3IAXeUsw(pI34zuWdp8WlJ3rvIx8YI5Ck8YSyyJj(BXGhHGElQftqGIfd5rJXHQssRhTrBrWrXzKhnSQxGtCn1Gyuyo0CznRbmMCsxN9lmhsRbmMLAIZipA(xCituIfnE4Xx0hXB8mkX54mYJg)H9hbboXXzKhTrg9jviir0g1MYHO1nAbb5CsnAVOZ(rlhGMJZipAJmAJgzU4qIOvNHG00afDzFXOZ(rVF0gHo7ajIgAzrxzYv4CCg5rBKrFsfcseTreqrJ0OKjiBXKdqbwJTyaLCPctcRXw(XZASfJEhvsc7XwScBuInUfdFrRUKEndnVizG8dpbaz6DujjIgxCJgCrszsDgcsbzamhBoqFcOlZm6tJMxrJSORgn(IgLdckduYLkCM7kACXnAuoiOmo(pa4m3v0iZI5fD23IbGDXAaOS5azvl)hzn2IrVJkjH9ylwHnkXg3IHYbbLbWCS5a9jDzVl2m3v0vJUSMOB6ANxbzbbnLrJ(07OpYI5fD23IvCPm5fD2pjhGAXKdqtVBswmO5haSvT8ZlRXwm6DujjShBXkSrj24wmWfjLj1ziifKbWCS5a9jGUmZOVJU2rxn6YAIUPRDEfeDf3rxBlMx0zFlwXLYKx0z)KCaQftoan9UjzXGMFaWw1YFTTgBXO3rLKWESfRWgLyJBXkRj6MU25vqwqqtz0Op9oA8I2iJgFrRUKEnli6IyjGYC1rqMz6DujjIUA04lAuoiOmo(pa4m3v04IB0ETi2OuwHPe0WaAs4FHY07OsseD1Ors0QlPxZcNDibGDXAitVJkjr0vJgjrRUKEnd4qvIbXHGY07OsseD1ObxKuMuNHGuqgaZXMd0Na6YmJ(0O5v0ilAKzX8Io7BXkUuM8Io7NKdqTyYbOP3njlg08da2Qw(RK1ylg9oQKe2JTyf2OeBClMxlInkLVig0YCLYm)peDf3rFu0vJgCrszsDgcsbzamhBoqFcOlZm6tVJ(ilMx0zFlgc5UMOsxqw1Y)jyn2IrVJkjH9ylMx0zFlga2fRbGYMdKfRWgLyJBXuxsVMbuHrAsPc8pgbCuMEhvsIORgT6s61m08IKbYp8eaKP3rLKi6QrliuoiOm08IKbYp8eaKzKPppi6tJgVORgn4IKYK6meKcYayo2CG(eqxMz03rFu0vJwhtkPBsmu0gz0mY0NheDfrFcwSs9IKsQZqqkWYpEw1YpsT1ylg9oQKe2JTyf2OeBClgsIwDj9Awq0fXsaL5QJGmZ07OsseD1O9ArSrPmQ0fuA(KctjaSlwdGmZ)drFhnVIUA0GlsktQZqqkidG5yZb6taDzMrFhnVSyErN9TyayxSgakBoqw1YpsL1ylg9oQKe2JTyf2OeBClgooBCujL5au6InlB06j2QUo7hD1OXx0QlPxZqZlsgi)WtaqMEhvsIORgTGq5GGYqZlsgi)WtaqMrM(8GOpnA8IgxCJwDj9A2a5x7B6aLyz6DujjIUA0GlsktQZqqkidG5yZb6taDzMrF6D01oACXnAVweBukppHZOo6ihTEMEhvsIORgnkheugu3eDLG0cLeKRWzURORgn4IKYK6meKcYayo2CG(eqxMz0NEhnVIMNO9ArSrPmQ0fuA(KctjaSlwdGm9oQKerJmlMx0zFlga2fRbGYMdKvT8BuSgBXO3rLKWESfRWgLyJBXaxKuMuNHGuq0vChnVSyErN9Tyayo2CG(eqxMPvT8JhVTgBX8Io7BXaWUynau2CGSy07Ossyp2Qw1Iraa9fcyn2YpEwJTy07Ossyp2IvyJsSXTy0tme1Z6ysjDtMo(fDfrJx0vJgjrJYbbLb1nrxjiTqjb5kCM7k6QrJVOrs0IvZL9l0Rmxjrcs6MucLJ9zDkhMhr0vJgjr7fD2px2VqVYCLejiPBs55tqYbbSgnU4gneNuMyub2ziOKoMu0NgnIIiB64x0iZI5fD23Iv2VqVYCLejiPBsw1Y)rwJTy07Ossyp2IvyJsSXTyij6YUsXA4ZayxSgsOsxqGm3v0vJUSRuSg(mOUj6kbPfkjixHZCxrJlUrRJjL0njgk6tVJgpEBX8Io7BXqL7kslusHPe9KzDRA5NxwJTyErN9Tyi4CMy8pTqjVweBvylg9oQKe2JTQL)ABn2IrVJkjH9ylwHnkXg3IHVObxKuMuNHGuqgaZXMd0Na6YmJUI7OpkACXnAMpIeHd9A2fcqE(ORi6tG3rJSORgnsIUSRuSg(mOUj6kbPfkjixHZCxrxnAKenkheugu3eDLG0cLeKRWzURORgn9edr9SGGMYOrxXD08I3wmVOZ(wmOTWbirYRfXgLsOKBAvl)vYASfJEhvsc7XwScBuInUfdCrszsDgcsbzamhBoqFcOlZm6kUJ(OOXf3Oz(iseo0Rzxia55JUIOpbEBX8Io7BXU4ydu95rKqLoqTQL)tWASfJEhvsc7XwScBuInUfdLdckZOYbjbajOLvOm3v04IB0OCqqzgvoijaibTScLkl3RelduVCi6tJgpEBX8Io7BXuykX9Ol3lsqlRqw1YpsT1ylMx0zFlgBUUKuA(e4YlKfJEhvsc7Xw1YpsL1ylg9oQKe2JTyf2OeBClgkheuwoqeQCxrgOE5q0NgnVSyErN9TygwMuGdnFIrG99Vqw1YVrXASfJEhvsc7XwScBuInUfJEIHOE0NgDT5D0vJgLdckdQBIUsqAHscYv4m3LfZl6SVfZKmxw90cLKCLrKemYnbw1Qwmbb5Cs1ASLF8SgBXO3rLKWESfRWgLyJBXqs0aLCPctImBrWrwmVOZ(wSdt5GvT8FK1ylMx0zFlgqjxQWwm6DujjShBvl)8YASfJEhvsc7XwmVOZ(wSIlLjVOZ(j5aulMCaA6DtYIveaRA5V2wJTy07Ossyp2IvyJsSXTyaLCPctISlLwmVOZ(wmg3N8Io7NKdqTyYbOP3njlgqjxQWKWQw(RK1ylg9oQKe2JTyf2OeBClMoMus3KyOORi6ti6QrZitFEq0NgnIIiB64x0vJUSMOB6ANxbrxXD01oAJmA8fToMu0NgnE8oAKf9jh9rwmVOZ(wSFqaROsxqw1Y)jyn2IrVJkjH9yl2EzXaKAX8Io7BXWXzJJkjlgoUKJSyxSzzJwpXw11z)ORgn4IKYK6meKcYayo2CG(eqxMz0vCh9rwmCCw6DtYIXbO0fBw2O1tSvDD23Qw(rQTgBXO3rLKWESfRWgLyJBXWXzJJkPmhGsxSzzJwpXw11zFlMx0zFlwXLYKx0z)KCaQftoan9UjzXak5sfoveaRA5hPYASfJEhvsc7XwS9YIbi1I5fD23IHJZghvswmCCjhzXoQsrZt0QlPxZ4miwwMEhvsIOp5O5vLIMNOvxsVMnDGsS0cLaWUynaY07Osse9jh9rvkAEIwDj9Aga7I1qcAlCGm9oQKerFYrFeVJMNOvxsVMDPxyJwptVJkjr0NC04X7O5jA8Qu0NC04lAWfjLj1ziifKbWCS5a9jGUmZOR4oAEfnYSy44S07MKfdOKlv4KcZia8kfw1YVrXASfJEhvsc7XwScBuInUfJEIHOEwqqtz0Op9oACC24OskduYLkCsHzeaELclMx0zFlwXLYKx0z)KCaQftoan9UjzXak5sfoveaRA5hpEBn2IrVJkjH9ylwHnkXg3I51IyJs5FqaRGeo0JG8Vqz6DujjIUA0ijAuoiO8piGvqch6rq(xOm3v0vJUSMOB6ANxbzbbnLrJUIOXl6QrJVObxKuMuNHGuqgaZXMd0Na6YmJ(0OpkACXnACC24OskZbO0fBw2O1tSvDD2pAKfD1OXx0LDLI1WNb1nrxjiTqjb5kCMrM(8GOp9oAEfnU4gn(I2RfXgLY)GawbjCOhb5FHYm)peDf3rFu0vJgLdckdQBIUsqAHscYv4mJm95brxr08k6QrJKObk5sfMezxkJUA0LDLI1WNbWUynKe(xOCb2ziiqcI5fD23LrxXD08oBuIgzrJmlMx0zFl2piGvuPliRA5hp8SgBXO3rLKWESfRWgLyJBXkRj6MU25vqwqqtz0Op9oA8IgxCJwhtkPBsmu0NEhnErxn6YAIUPRDEfeDf3rZllMx0zFlwXLYKx0z)KCaQftoan9UjzXGMFaWw1YpEhzn2IrVJkjH9ylwHnkXg3IbUiPmPodbPGmaMJnhOpb0Lzg9D01o6Qrxwt0nDTZRGOR4o6ABX8Io7BXkUuM8Io7NKdqTyYbOP3njlg08da2Qw(XJxwJTy07Ossyp2IvyJsSXTy0tme1ZccAkJg9P3rJJZghvszGsUuHtkmJaWRuyX8Io7BXkUuM8Io7NKdqTyYbOP3njlgk3ifw1YpE12ASfJEhvsc7XwScBuInUfJEIHOEwqqtz0OR4oA8Qu08en9edr9mJqqVfZl6SVfZzf)PKUmg9QvT8JxLSgBX8Io7BXCwXFkDXjbKfJEhvsc7Xw1YpENG1ylMx0zFlMCqaRG0jkNaHj9QfJEhvsc7Xw1QwSlgvwtuxTgB5hpRXwmVOZ(wmGsUuHTy07Ossyp2Qw(pYASfJEhvsc7XwmVOZ(wmtNDGejOLLeKRWwSlgvwtuxtaQSVayXWRsw1YpVSgBX8Io7BXUwD23IrVJkjH9yRA5V2wJTy07Ossyp2I9UjzX8AbGDMdsq7RPfkDTgiMfZl6SVfZRfa2zoibTVMwO01AGyw1QwmO5haS1yl)4zn2IrVJkjH9ylg0YspHFQLF8SyErN9Tyx7ktmcSCSczvl)hzn2IrVJkjH9ylwHnkXg3IHYbbL)bbScs4qpcY)cL5USyErN9TyeodOqmxjRA5NxwJTy07Ossyp2IvyJsSXTy4lAKeT6s61SWzhsayxSgY07OssenU4gnsIgLdckdGDXAij8VqzUROrw0vJwhtkPBsmu0gz0mY0NheDfrFcrxnAgz6ZdI(0O1PCiPJjf9jh9rwmVOZ(wSFqaROsxqw1YFTTgBXO3rLKWESfZl6SVf7heWkQ0fKfRWgLyJBXqs044SXrLuMdqPl2SSrRNyR66SF0vJgCrszsDgcsbzamhBoqFcOlZm6kUJ(OORgn(I2RfXgLY)GawbjCOhb5FHY07OssenU4gnsI2RfXgLYm6sofxNhrca7I1aitVJkjr04IB0GlsktQZqqkidG5yZb6taDzMrBKr7fDWHsIvZ)GawrLUGIUI7OpkAKfD1Ors0OCqqzaSlwdjH)fkZDfD1O1XKs6MedfDf3rJVORu08en(I(OOp5OlRj6MU25vq0ilAKfD1OzeeJaWoQKSyL6fjLuNHGuGLF8SQL)kzn2IrVJkjH9ylwHnkXg3IXitFEq0NgDzxPyn8zqDt0vcslusqUcNzKPppiAEIgpEhD1Ol7kfRHpdQBIUsqAHscYv4mJm95brF6D0vk6QrRJjL0njgkAJmAgz6ZdIUIOl7kfRHpdQBIUsqAHscYv4mJm95brZt0vYI5fD23I9dcyfv6cYQw(pbRXwmVOZ(wmavyKMuQa)JrahzXO3rLKWESvT8JuBn2I5fD23Ir4mGcXCLSy07Ossyp2Qw1IveaRXw(XZASfJEhvsc7XwScBuInUfdjrJYbbLbWUynKe(xOm3v0vJgLdckdG5yZb6t6YExSzURORgnkheugaZXMd0N0L9UyZmY0Nhe9P3rZRCLSyErN9TyayxSgsc)lKfJdqPfckHOiSy4zvl)hzn2IrVJkjH9ylwHnkXg3IHYbbLbWCS5a9jDzVl2m3v0vJgLdckdG5yZb6t6YExSzgz6ZdI(07O5vUswmVOZ(wmqDt0vcslusqUcBX4auAHGsikclgEw1YpVSgBXO3rLKWESfRWgLyJBXqs0aLCPctISlLrxnAXQ5FqaROsxqzDkhMhHfZl6SVfR4szYl6SFsoa1IjhGME3KSyeaqFHaw1YFTTgBXO3rLKWESfZl6SVf7AxzIrGLJvilwHnkXg3IHKOvxsVMbWUynKG2chitVJkjHfdAzPNWp1YpEw1YFLSgBXO3rLKWESfRWgLyJBXONyiQhDf3rFc8o6Qrlwn)dcyfv6ckRt5W8iIUA0LDLI1WNb1nrxjiTqjb5kCM7k6Qrx2vkwdFga7I1qs4FHYfyNHGarxXD04zX8Io7BXaWCS5a9jDzVlwRA5)eSgBXO3rLKWESfRWgLyJBXeRM)bbSIkDbL1PCyEerxnAKeDzxPyn8zaSlwdjuPliqM7k6QrJVOrs0QlPxZayo2CG(KUS3fBMEhvsIOXf3OvxsVMbWUynKG2chitVJkjr04IB0LDLI1WNbWCS5a9jDzVl2mJm95brxr0hfnYIUA04lAKenba0xOmQCxrAHskmLONmRNn9t0LfnU4gDzxPyn8zu5UI0cLuykrpzwpZitFEq0ve9rrJSORgn(I2RfXgLY)GawbjCOhb5FHYm)pe9PrFu04IB0OCqq5FqaRGeo0JG8VqzUROrMfZl6SVfdu3eDLG0cLeKRWw1YpsT1ylg9oQKe2JTyErN9TyMo7ajsqlljixHTyf2OeBClgZhrIWHEn7cbiZDfD1OXx0QZqqAwhtkPBsmu0NgDznr301oVcYccAkJgnU4gnsIgOKlvysKDPm6Qrxwt0nDTZRGSGGMYOrxXD0LRKPJFjWf9IOrMfRuViPK6meKcS8JNvT8Juzn2IrVJkjH9ylwHnkXg3IX8rKiCOxZUqaYZhDfrZlEhTrgnZhrIWHEn7cbil4yUo7hD1Ors0aLCPctISlLrxn6YAIUPRDEfKfe0ugn6kUJUCLmD8lbUOxyX8Io7BXmD2bsKGwwsqUcBvl)gfRXwm6DujjShBXkSrj24wmKenqjxQWKi7sz0vJwSA(heWkQ0fuwNYH5reD1OlRj6MU25vqwqqtz0OR4o6JSyErN9TyayxSgsOsxqaRA5hpEBn2IrVJkjH9ylwHnkXg3IPUKEndGDXAibTfoqMEhvsIORgTy18piGvuPlOSoLdZJi6QrJYbbLb1nrxjiTqjb5kCM7YI5fD23IbG5yZb6t6YExSw1YpE4zn2IrVJkjH9ylwHnkXg3IHKOr5GGYayxSgsc)luM7k6QrRJjL0njgk6tVJUsrZt0QlPxZaouLyqCiOm9oQKerxnAKenZhrIWHEn7cbiZDzX8Io7BXaWUynKe(xiRA5hVJSgBXO3rLKWESfRWgLyJBXq5GGYOYDfsoGMzKx0OXf3Or5GGYG6MOReKwOKGCfoZDfD1OXx0OCqqzaSlwdjuPliqM7kACXn6YUsXA4ZayxSgsOsxqGmJm95brF6D04X7OrMfZl6SVf7A1zFRA5hpEzn2IrVJkjH9ylwHnkXg3IHYbbLb1nrxjiTqjb5kCM7YI5fD23IHk3vKG4y1TQLF8QT1ylg9oQKe2JTyf2OeBClgkheugu3eDLG0cLeKRWzUllMx0zFlgkXae7W8iSQLF8QK1ylg9oQKe2JTyf2OeBClgkheugu3eDLG0cLeKRWzUllMx0zFlg0Wiu5UcRA5hVtWASfJEhvsc7XwScBuInUfdLdckdQBIUsqAHscYv4m3LfZl6SVfZ)cbuMltfxkTQLF8qQTgBXO3rLKWESfZl6SVfRuVixLT)usOshOwScBuInUfdjrduYLkmjYUugD1OfRM)bbSIkDbL1PCyEerxnAKenkheugu3eDLG0cLeKRWzURORgn9edr9SGGMYOrxXD08I3wmccIkA6DtYIvQxKRY2FkjuPduRA5hpKkRXwm6DujjShBX8Io7BX8AbGDMdsq7RPfkDTgiMfRWgLyJBXqs0OCqqzaSlwdjH)fkZDfD1Ol7kfRHpdQBIUsqAHscYv4mJm95brFA04XBl27MKfZRfa2zoibTVMwO01AGyw1YpEgfRXwm6DujjShBX8Io7BXCamo(tGeZR1YsLL5slwHnkXg3IjiuoiOmZR1YsLL5YKGq5GGYI1WhnU4gTGq5GGYL9fCfDWHsZFijiuoiOm3v0vJwDgcsZWKlv48vrJ(0O5fErJlUrJKOfekheuUSVGROdouA(djbHYbbL5UIUA04lAbHYbbLzETwwQSmxMeekheugOE5q0vCh9rvkAJmA84D0NC0ccLdckJk3vKwOKctj6jZ6zUROXf3O1XKs6Medf9PrxBEhnYIUA0OCqqzqDt0vcslusqUcNzKPppi6kIgPYI9UjzXCamo(tGeZR1YsLL5sRA5)iEBn2IrVJkjH9yl27MKfZSUWbj1LdW0FlMx0zFlMzDHdsQlhGP)w1Y)r4zn2IrVJkjH9ylwHnkXg3IHYbbLb1nrxjiTqjb5kCM7kACXnADmPKUjXqrFA0hXBlMx0zFlghGsJsMaRAvlgqjxQWPIayn2YpEwJTy07Ossyp2ITxwmaPwmVOZ(wmCC24OsYIHJl5ilwzxPyn8zaSlwdjH)fkxGDgccKGyErN9Dz0vChnEzK6kzXWXzP3njlgawKuygbGxPWQw(pYASfJEhvsc7XwScBuInUfdjrJJZghvszaSiPWmcaVsr0vJUSMOB6ANxbzbbnLrJUIOXl6QrliuoiOm08IKbYp8eaKzKPppi6tJgVORgDzxPyn8zqDt0vcslusqUcNzKPppi6kUJMxwmVOZ(wmC8FaWw1YpVSgBXO3rLKWESfZl6SVf7AxzIrGLJvilgHFkZtU5Y9QfR282IbTS0t4NA5hpRA5V2wJTy07Ossyp2IvyJsSXTy0tme1JUI7ORnVJUA00tme1ZccAkJgDf3rJhVJUA0ijACC24OskdGfjfMra4vkIUA0L1eDtx78kiliOPmA0venErxnAbHYbbLHMxKmq(HNaGmJm95brFA04zX8Io7BXaWUynyssHvT8xjRXwm6DujjShBX2llgGulMx0zFlgooBCujzXWXLCKfRSMOB6ANxbzbbnLrJUI7ORTfdhNLE3KSyayrQSMOB6ANxbw1Y)jyn2IrVJkjH9yl2EzXaKAX8Io7BXWXzJJkjlgoUKJSyL1eDtx78kiliOPmA0NEhnErZt0hf9jhTxlInkLvykbnmGMe(xOm9oQKewScBuInUfdhNnoQKYCakDXMLnA9eBvxN9JUA04lA1L0R5FqaRa1LhiwMEhvsIOXf3OvxsVMfo7qca7I1qMEhvsIOrMfdhNLE3KSyayrQSMOB6ANxbw1YpsT1ylg9oQKe2JTyf2OeBClgooBCujLbWIuznr301oVcIUA04lAKeT6s61SWzhsayxSgY07OssenU4gTy18piGvuPlOmJm95brxXD0vkAEIwDj9AgWHQedIdbLP3rLKiAKfD1OXx044SXrLugalskmJaWRuenU4gnkheugu3eDLG0cLeKRWzgz6ZdIUI7OXlFu04IB0GlsktQZqqkidG5yZb6taDzMrxXD01o6Qrx2vkwdFgu3eDLG0cLeKRWzgz6ZdIUIOXJ3rJSORgn(I2RfXgLY)GawbjCOhb5FHYm)pe9PrFu04IB0OCqq5FqaRGeo0JG8VqzUROrMfZl6SVfda7I1qs4FHSQLFKkRXwm6DujjShBXkSrj24wmCC24OskdGfPYAIUPRDEfeD1O1XKs6Medf9Prx2vkwdFgu3eDLG0cLeKRWzgz6ZdIUA0ijAMpIeHd9A2fcqM7YI5fD23IbGDXAij8Vqw1QwmuUrkSgB5hpRXwm6DujjShBXkSrj24wmWfjLj1ziifeDf3rFu08en(IwDj9AgHCxtuPlOm9oQKerxnAVweBukFrmOL5kLz(Fi6kUJ(OOrMfZl6SVfdaZXMd0Na6YmTQL)JSgBX8Io7BXqi31ev6cYIrVJkjH9yRA5NxwJTyErN9TyOE5aqDulg9oQKe2JTQvTQfdhIbM9T8FeVXZOWBJYrvYIzWz)8iawmKgZRLPKiAKQO9Io7hTCakihNTyGlQy5)Otapl2fBHgjzXqE0yCOQK06rB0weCuCg5rdR6f4extnigfMdnxwZAaJjN01z)cZH0AaJzPM4mYJM)fhYeLyrJhE8f9r8gpJsCooJ8OXFy)rqGtCCg5rBKrFsfcseTrTPCiADJwqqoNuJ2l6SF0YbO54mYJ2iJ2OrMloKiA1ziinnqrx2xm6SF07hTrOZoqIOHww0vMCfohNrE0gz0NuHGerBebu0inkzcYX54mYJgPf(rfoLerJsqlJIUSMOUgnkHyEqo6tAPqxki6FFJe2zMqCYO9Io7dIEFz9CCg5r7fD2hKVyuznrD9gs6GdXzKhTx0zFq(IrL1e1vEURX5qysV66SFCg5r7fD2hKVyuznrDLN7AG2veNrE0yVFbGxnAMpIOr5GGir0a1vq0Oe0YOOlRjQRrJsiMheT)IOVyKrETQopIOhq0I9PCCg5r7fD2hKVyuznrDLN7AaVFbGxnbuxbXzVOZ(G8fJkRjQR8CxdqjxQWXzVOZ(G8fJkRjQR8CxJPZoqIe0YscYvy(UyuznrDnbOY(cWnEvko7fD2hKVyuznrDLN7AUwD2po7fD2hKVyuznrDLN7A4auAuYKV3nPBVwayN5Ge0(AAHsxRbIfNJZipAKw4hv4usenHdXQhToMu0kmfTx0Lf9aI2XXhPJkPCCg5rB0iGsUuHJEGI(AbGbvsrJVFJgho5tmhvsrtpzoei65JUSMOUIS4Sx0zFW9HPCGVb6gjaLCPctImBrWrXzVOZ(aEURbOKlv44mYJg)HPYHOX)kdI21OHggqJZErN9b8CxtXLYKx0z)KCakFVBs3fbioJ8OnACF0qCsz9ObggTatGO1nAfMIgtjxQWKiAJ2QUo7hn(qRhTyNhr0GLVOhnAOLviq0x7kNhr0du0)QWZJi6beTJJpshvsilhN9Io7d45Ugg3N8Io7NKdq57Dt6gOKlvysW3aDduYLkmjYUugNrE0N0Rlz9O5FqaROsxqr7A0hXt04psjAbhBEerRWu0qddOrJhVJgqL9fa(I2HuIfTc7A01MNOXFKs0du0JgnHFxdJarByu45JwHPOFc)0OnQJ)vo6Lf9aI(xnAUR4Sx0zFap318dcyfv6cIVb6whtkPBsmufNqvgz6ZdofrrKnD8RAznr301oVcQ4U2gj(0XKofpEJSt(O4mYJ2O6lRhDb2Feu0SvDD2p6bkAdu0Woou0xSzzJwpXw11z)ObKgT)IOn5K6CjPOvNHGuq0Cx54Sx0zFap31GJZghvs89UjDZbO0fBw2O1tSvDD2NpCCjhDFXMLnA9eBvxN9RcUiPmPodbPGmaMJnhOpb0LzwX9rXzKhnsHnlB06rB0w11zFK2J2OcPNiGOrm4qr7rxy(v0o6YPrtpXqupAOLfTctrduYLkC04FLbrJpuUrkiw0aDKYOze4IkA0JISC0iTL7IVOhn6I)rJsrRWUgnymVKuoo7fD2hWZDnfxktErN9tYbO89UjDduYLkCQia8nq344SXrLuMdqPl2SSrRNyR66SFCg5rBebKiADJwqqZtrBaM(O1nAoafnqjxQWrJ)vge9YIgLBKcIbIZErN9b8CxdooBCujX37M0nqjxQWjfMra4vk4dhxYr3hvjEuxsVMXzqSSm9oQKeNmVQepQlPxZMoqjwAHsayxSgaz6Dujjo5JQepQlPxZayxSgsqBHdKP3rLK4KpI38OUKEn7sVWgTEMEhvsItgpEZdEv6KXh4IKYK6meKcYayo2CG(eqxMzf38czXzKhn(VpyeelAoW8iI2JgtjxQWrJ)voAdW0hnJ8c88iIwHPOPNyiQhTcZia8kfXzVOZ(aEURP4szYl6SFsoaLV3nPBGsUuHtfbGVb6MEIHOEwqqtz0tVXXzJJkPmqjxQWjfMra4vkIZipA(heW6jci6tc9ii)l0joA(heWkQ0fu0Oe0YOOXQBIUsq0UgTCnen(JuIw3OlRj68u0KZK1JMrqmcahTHrHJgbP68iIwHPOr5GGIM7kh9jvc2OLRHOXFKs0co28iIgRUj6kbrJsQbI(ORS)fceTHrHJ(iEIM)tsoo7fD2hWZDn)GawrLUG4BGU9ArSrP8piGvqch6rq(xOm9oQKevrckheu(heWkiHd9ii)luM7QAznr301oVcYccAkJwbEvXh4IKYK6meKcYayo2CG(eqxM5PhHlU44SXrLuMdqPl2SSrRNyR66SpYQIVYUsXA4ZG6MOReKwOKGCfoZitFEWP38cxCXNxlInkL)bbScs4qpcY)cLz(FOI7JQIYbbLb1nrxjiTqjb5kCMrM(8Gk4vvKauYLkmjYUuwTSRuSg(ma2fRHKW)cLlWodbbsqmVOZ(USIBENnkidzXzKhnsF(bahTRrxBEI2WOWlNgDLX4l6kXt0ggfo6kJfn(wofmckAGsUuHrwC2l6SpGN7AkUuM8Io7NKdq57Dt6gA(baZ3aDxwt0nDTZRGSGGMYONEJhU4QJjL0njg60B8Qwwt0nDTZRGkU5vCg5rB0hfo6kJfTlbB0qZpa4ODn6AZt0ocFEGgnHFErL1JU2rRodbPGOX3YPGrqrduYLkmYIZErN9b8CxtXLYKx0z)KCakFVBs3qZpay(gOBWfjLj1ziifKbWCS5a9jGUmZ7AxTSMOB6ANxbvCx74mYJ2icOO9Or5gPGyrBaM(OzKxGNhr0kmfn9edr9OvygbGxPio7fD2hWZDnfxktErN9tYbO89UjDJYnsbFd0n9edr9SGGMYONEJJZghvszGsUuHtkmJaWRueNrE0gvwdeqJ(InlB06rpF0Uug9cfTctrFsrkgvIgLkohGIE0OlohGar7rBuh)RCC2l6SpGN7ACwXFkPlJrVY3aDtpXqupliOPmAf34vjEONyiQNzec6JZErN9b8CxJZk(tPlojGIZErN9b8CxJCqaRG0jkNaHj9ACooJ8OpMBKcIbIZErN9bzuUrkUbWCS5a9jGUmt(gOBWfjLj1ziifuX9r8Gp1L0RzeYDnrLUGY07Ossu1RfXgLYxedAzUszM)hQ4(iKfN9Io7dYOCJuWZDniK7AIkDbfN9Io7dYOCJuWZDnOE5aqD04CCg5rJ)7kfRHheNrE0grafDL9VqrVqqgjIIiAucAzu0kmfn0WaA0yWCS5a9rJPlZmAi2AgTXl7DXgDznjq0ZNJZErN9b5IaCdGDXAij8Vq8XbO0cbLque34X3aDJeuoiOma2fRHKW)cL5UQIYbbLbWCS5a9jDzVl2m3vvuoiOmaMJnhOpPl7DXMzKPpp40BELRuCg5rJpJ4ljaiAxYixupAUROrPIZbOOnqrR7EiAmyxSgIgPVfoaYIMdqrJv3eDLGOxiiJerrenkbTmkAfMIgAyanAmyo2CG(OX0LzgneBnJ24L9UyJUSMei65ZXzVOZ(GCra45UgqDt0vcslusqUcZhhGsleucrrCJhFd0nkheugaZXMd0N0L9UyZCxvr5GGYayo2CG(KUS3fBMrM(8GtV5vUsXzVOZ(GCra45UMIlLjVOZ(j5au(E3KUjaG(cb4BGUrcqjxQWKi7szvXQ5FqaROsxqzDkhMhrCg5rJu2vgn0YI24L9UyJ(Irgj2w5OnmkC0yWvoAg5I6rBaM(O)vJMX9)8iIgdPNJZErN9b5IaWZDnx7ktmcSCScXh0YspHF6nE8nq3irDj9Aga7I1qcAlCGm9oQKeXzKhTreqrB8YExSrFXOOX2khTby6J2afnSJdfTctrtpXqupAdWKctSOHyRz0x7kNhr0ggfE50OXq6rVSOpr5aA0iONyUuwphN9Io7dYfbGN7AaWCS5a9jDzVlw(gOB6jgI6vCFc8UQy18piGvuPlOSoLdZJOAzxPyn8zqDt0vcslusqUcN5UQw2vkwdFga7I1qs4FHYfyNHGavCJxCg5rBebu0y1nrxji69JUSRuSg(OXNdPelAOHb0O5FqaROsxqilAUxsaq0gOODgfnIDEerRB0x7v0gVS3fB0(lIwSr)RgnSJdfngSlwdrJ03chihN9Io7dYfbGN7Aa1nrxjiTqjb5kmFd0Ty18piGvuPlOSoLdZJOksk7kfRHpdGDXAiHkDbbYCxvXhsuxsVMbWCS5a9jDzVl2m9oQKe4IR6s61ma2fRHe0w4az6DujjWf3YUsXA4Zayo2CG(KUS3fBMrM(8GkoczvXhsiaG(cLrL7kslusHPe9Kz9SPFIUmCXTSRuSg(mQCxrAHskmLONmRNzKPppOIJqwv851IyJs5FqaRGeo0JG8VqzM)ho9iCXfLdck)dcyfKWHEeK)fkZDHS4mYJgPbkAxiar7mkAUl(Ig8ZffTctrVpfTHrHJwUgiGgTXgx5C0grafTby6JwuFEerd5aLyrRW(hn(JuIwqqtz0Oxw0)QrduYLkmjI2WOWlNgT)1Jg)rk54Sx0zFqUia8CxJPZoqIe0YscYvy(k1lskPodbPGB84BGUz(iseo0RzxiazURQ4tDgcsZ6ysjDtIHoTSMOB6ANxbzbbnLrXfxKauYLkmjYUuwTSMOB6ANxbzbbnLrR4UCLmD8lbUOxGS4mYJgPbk6FJ2fcq0ggPmAXqrByu45JwHPOFc)0O5fVb8fnhGI2ieQYrVF0OlaeTHrHxonA)Rhn(JuI2Fr0)gnqjxQW54Sx0zFqUia8CxJPZoqIe0YscYvy(gOBMpIeHd9A2fcqE(k4fVnsMpIeHd9A2fcqwWXCD2Vksak5sfMezxkRwwt0nDTZRGSGGMYOvCxUsMo(Lax0lIZErN9b5IaWZDnayxSgsOsxqa(gOBKauYLkmjYUuwvSA(heWkQ0fuwNYH5ruTSMOB6ANxbzbbnLrR4(O4mYJ2OpkC0yiD(IEGI(xnAxYixupAX(eFrZbOOnEzVl2OnmkC0yBLJM7khN9Io7dYfbGN7AaWCS5a9jDzVlw(gOB1L0RzaSlwdjOTWbY07OssuvSA(heWkQ0fuwNYH5rufLdckdQBIUsqAHscYv4m3vC2l6SpixeaEURba7I1qs4FH4BGUrckheuga7I1qs4FHYCxv1XKs6MedD6DL4rDj9AgWHQedIdbLP3rLKOksy(iseo0RzxiazUR4Sx0zFqUia8CxZ1QZ(8nq3OCqqzu5UcjhqZmYlkU4IYbbLb1nrxjiTqjb5kCM7Qk(q5GGYayxSgsOsxqGm3fU4w2vkwdFga7I1qcv6ccKzKPpp40B84nYIZErN9b5IaWZDnOYDfjiowD(gOBuoiOmOUj6kbPfkjixHZCxXzVOZ(GCra45UguIbi2H5rW3aDJYbbLb1nrxjiTqjb5kCM7ko7fD2hKlcap31anmcvURGVb6gLdckdQBIUsqAHscYv4m3vC2l6SpixeaEURX)cbuMltfxk5BGUr5GGYG6MOReKwOKGCfoZDfN9Io7dYfbGN7A4auAuYKpccIkA6Dt6UuVixLT)usOshO8nq3ibOKlvysKDPSQy18piGvuPlOSoLdZJOksq5GGYG6MOReKwOKGCfoZDvLEIHOEwqqtz0kU5fVJZErN9b5IaWZDnCaknkzY37M0TxlaSZCqcAFnTqPR1aX4BGUrckheuga7I1qs4FHYCxvl7kfRHpdQBIUsqAHscYv4mJm95bNIhVJZip6tcXQhnB5qalRhnJtsrVqrRWCMOd0qIOnDfgenkjxdN4OnIakAOLfnsZF4AfrxyJYx0RctmddGI2WOWrJTvoAxJ(OkXt0a1lharVSOXRs8eTHrHJ2LGn6JL7kIM7khN9Io7dYfbGN7A4auAuYKV3nPBhaJJ)eiX8ATSuzzUKVb6wqOCqqzMxRLLklZLjbHYbbLfRHhxCfekheuUSVGROdouA(djbHYbbL5UQQodbPzyYLkC(QONYl8WfxKiiuoiOCzFbxrhCO08hsccLdckZDvfFccLdckZ8ATSuzzUmjiuoiOmq9YHkUpQsgjE8(KfekheugvURiTqjfMs0tM1ZCx4IRoMus3KyOtRnVrwvuoiOmOUj6kbPfkjixHZmY0NhubsvC2l6SpixeaEURHdqPrjt(E3KUnRlCqsD5am9poJ8ORmb5CsnAixkr9YHOHww0CahvsrpkzcoXrBebu0ggfoAS6MORee9cfDLjxHZXzVOZ(GCra45UgoaLgLmb8nq3OCqqzqDt0vcslusqUcN5UWfxDmPKUjXqNEeVJZXzKhnslaG(cbIZErN9bzcaOVqG7Y(f6vMRKibjDtIVb6MEIHOEwhtkPBY0XVkWRksq5GGYG6MOReKwOKGCfoZDvfFirSAUSFHEL5kjsqs3KsOCSpRt5W8iQIeVOZ(5Y(f6vMRKibjDtkpFcsoiGvCXfItktmQa7meusht6uefr20XpKfN9Io7dYeaqFHa8CxdQCxrAHskmLONmRZ3aDJKYUsXA4ZayxSgsOsxqGm3v1YUsXA4ZG6MOReKwOKGCfoZDHlU6ysjDtIHo9gpEhN9Io7dYeaqFHa8CxdcoNjg)tluYRfXwfoo7fD2hKjaG(cb45UgOTWbirYRfXgLsOKBY3aDJpWfjLj1ziifKbWCS5a9jGUmZkUpcxCz(iseo0Rzxia55R4e4nYQIKYUsXA4ZG6MOReKwOKGCfoZDvfjOCqqzqDt0vcslusqUcN5UQspXqupliOPmAf38I3XzVOZ(Gmba0xiap31CXXgO6ZJiHkDGY3aDdUiPmPodbPGmaMJnhOpb0LzwX9r4IlZhrIWHEn7cbipFfNaVJZErN9bzcaOVqaEURrHPe3JUCVibTScX3aDJYbbLzu5GKaGe0YkuM7cxCr5GGYmQCqsaqcAzfkvwUxjwgOE5WP4X74Sx0zFqMaa6leGN7AyZ1LKsZNaxEHIZErN9bzcaOVqaEURXWYKcCO5tmcSV)fIVb6gLdcklhicvURiduVC4uEfN9Io7dYeaqFHa8CxJjzUS6Pfkj5kJijyKBc4BGUPNyiQFAT5DvuoiOmOUj6kbPfkjixHZCxX54mYJgPp)aGjgio7fD2hKHMFaW3x7ktmcSCScXh0YspHF6nEXzKhnslCgqHyUsrd7GOHheWeqJ(InlB06rByu4O5FqaRNiGOpj0JG8VqrZDLJZErN9bzO5hamp31q4mGcXCL4BGUr5GGY)GawbjCOhb5FHYCxXzKhTrnIUIM7kA(heWkQ0fu0du0Jg9aI2rxonADJMX9rVCAo6kVr)RgnhGIM)JJwWXMhr0v2)cXx0du0QlPxjr0ZRB0v2zhIgd2fRHCC2l6Spidn)aG55UMFqaROsxq8nq34djQlPxZcNDibGDXAitVJkjbU4IeuoiOma2fRHKW)cL5UqwvDmPKUjXqgjJm95bvCcvzKPpp4uDkhs6ysN8rXzKhTriNuhXQ68iIE5uWiOORS)fk69JwDgcsbrRWUgTHrkJwo4qrdTSOvykAbhZ1z)OxOO5FqaROsxq8fnJGyeaoAbhBEerF5VGmNsoAJqoPoIvJ2brl3hr0oi6J4jA1ziifeTyJ(xnAyhhkA(heWkQ0fu0CxrByu4OnA0LCkUopIOXGDXAaen(4EjbarxF5Ig2XHIM)bbSEIaI(KqpcY)cfTUlYYXzVOZ(Gm08daMN7A(bbSIkDbXxPErsj1ziifCJhFd0nsWXzJJkPmhGsxSzzJwpXw11z)QGlsktQZqqkidG5yZb6taDzMvCFuv851IyJs5FqaRGeo0JG8Vqz6DujjWfxK41IyJszgDjNIRZJibGDXAaKP3rLKaxCbxKuMuNHGuqgaZXMd0Na6YmnsVOdousSA(heWkQ0fuf3hHSQibLdckdGDXAij8VqzURQ6ysjDtIHQ4gFvIh8D0jxwt0nDTZRaKHSQmcIrayhvsXzKhTrJGyeaoA(heWkQ0fu0KZK1JEGIE0Onmsz0e(DnmkAbhBEerJv3eDLGC0vEJwHDnAgbXiaC0du0yBLJgbPGOzKlQh98rRWu0pHFA0vcKJZErN9bzO5hamp318dcyfv6cIVb6MrM(8Gtl7kfRHpdQBIUsqAHscYv4mJm95b8GhVRw2vkwdFgu3eDLG0cLeKRWzgz6Zdo9Usv1XKs6MedzKmY0NhurzxPyn8zqDt0vcslusqUcNzKPppGNkfN9Io7dYqZpayEURbqfgPjLkW)yeWrXzVOZ(Gm08daMN7AiCgqHyUsX54mYJgtjxQWrJ)7kfRHheNrE0iTHKxel6tIZghvsXzVOZ(GmqjxQWPIaCJJZghvs89UjDdGfjfMra4vk4dhxYr3LDLI1WNbWUynKe(xOCb2ziiqcI5fD23LvCJxgPUsXzKh9jX)bahn3ljaiAdu0oJI2rxonADJU4xrVF0v2)cfDb2ziiqoAJQVSE0gGPpAK(8IOn6KF4jai6beTJUCA06gnJ7JE50CC2l6SpiduYLkCQia8Cxdo(pay(gOBKGJZghvszaSiPWmcaVsr1YAIUPRDEfKfe0ugTc8QkiuoiOm08IKbYp8eaKzKPpp4u8Qw2vkwdFgu3eDLG0cLeKRWzgz6ZdQ4MxXzKhnszxz0qllAmyxSgmjPiAEIgd2fRbGYMdu0CVKaGOnqr7mkAhD50O1n6IFf9(rxz)lu0fyNHGa5OnQ(Y6rBaM(Or6ZlI2Ot(HNaGOhq0o6YPrRB0mUp6LtZXzVOZ(GmqjxQWPIaWZDnx7ktmcSCScXh0YspHF6nE8r4NY8KBUCVExBEhN9Io7dYaLCPcNkcap31aGDXAWKKc(gOB6jgI6vCxBExLEIHOEwqqtz0kUXJ3vrcooBCujLbWIKcZia8kfvlRj6MU25vqwqqtz0kWRQGq5GGYqZlsgi)WtaqMrM(8GtXloJ8OXFKs0mYiGByKj96jo6k7FHI21OLRHOXFKs0O1JwqqoNuZXzVOZ(GmqjxQWPIaWZDn44SXrLeFVBs3ayrQSMOB6ANxb8HJl5O7YAIUPRDEfKfe0ugTI7AhNrE04psjAgzeWnmYKE9ehDL9VqrVVSE0Oe0YOOHMFaWede9afTbkAyhhkA38kA1L0RGO9xe9fBw2O1JMTQRZ(54Sx0zFqgOKlv4ura45UgCC24OsIV3nPBaSivwt0nDTZRa(WXLC0Dznr301oVcYccAkJE6nE8C0j71IyJszfMsqddOjH)fktVJkjbFd0nooBCujL5au6InlB06j2QUo7xfFQlPxZ)GawbQlpqSm9oQKe4IR6s61SWzhsayxSgY07OssGS4mYJ2OpkC0v2zhIgd2fRHO3xwp6k7FHI2am9rZ)GawrLUGI2WiLrduVE0Cx5OnIakAbhBEerJv3eDLGOxw0o6IdfTcZia8kf5On6(OrdTSO5)Kenkheu0ggfo6J4H)tsoo7fD2hKbk5sfoveaEURba7I1qs4FH4BGUXXzJJkPmawKkRj6MU25vqv8He1L0RzHZoKaWUynKP3rLKaxCfRM)bbSIkDbLzKPppOI7kXJ6s61mGdvjgehcktVJkjbYQIpCC24OskdGfjfMra4vkWfxuoiOmOUj6kbPfkjixHZmY0NhuXnE5JWfxWfjLj1ziifKbWCS5a9jGUmZkURD1YUsXA4ZG6MOReKwOKGCfoZitFEqf4XBKvfFETi2Ou(heWkiHd9ii)luM5)HtpcxCr5GGY)GawbjCOhb5FHYCxiloJ8OpMJ9rZitF(5reDL9VqGOrjOLrrRWu0QZqqA0IHarpqrJTvoAd7FIOrJsrZixup65JwhtkhN9Io7dYaLCPcNkcap31aGDXAij8Vq8nq344SXrLugalsL1eDtx78kOQoMus3KyOtl7kfRHpdQBIUsqAHscYv4mJm95bvrcZhrIWHEn7cbiZDfNJZipAmLCPctIOnAR66SFCg5rJ0afnMsUuHRbh)haC0oJIM7IVO5au0yWUynau2CGIw3OrPNGgnAi2AgTctrF5aWGdfn6(CGO9xensFEr0gDYp8eaWx0eo0h9afTbkANrr7A0Mo(fn(JuIgFqS1mAfMI(IrL1e11OncHQmYYXzVOZ(GmqjxQWK4ga7I1aqzZbIVb6gFQlPxZqZlsgi)WtaqMEhvscCXfCrszsDgcsbzamhBoqFcOlZ8uEHSQ4dLdckduYLkCM7cxCr5GGY44)aGZCxiloJ8Or6Zpa4ODnAEXt04psjAdJcVCA0vgl6AIU28eTHrHJUYyrByu4OXG5yZb6J24L9UyJgLdckAURO1nAhNDerdwtkA8hPeTbhOu0Gr5CD2hKJZErN9bzGsUuHjbp31uCPm5fD2pjhGY37M0n08daMVb6gLdckdG5yZb6t6YExSzURQL1eDtx78kiliOPm6P3hfNrE0NujyJg4qu06gn08daoAxJU28en(JuI2WOWrt4Nxuz9ORD0QZqqkihn(WCtkAhe9YPGrqrduYLkCgzXzVOZ(GmqjxQWKGN7AkUuM8Io7NKdq57Dt6gA(baZ3aDdUiPmPodbPGmaMJnhOpb0LzEx7QL1eDtx78kOI7AhNrE0i95haC0UgDT5jA8hPeTHrHxon6kJXx0vINOnmkC0vgJVO9xe9jeTHrHJUYyr7qkXI(K4)aGJEzrBmmfnsFyan6k7FHI2Fr0)gDLD2HOXGDXAiAEI(3OX4qvIbXHGIZErN9bzGsUuHjbp31uCPm5fD2pjhGY37M0n08daMVb6USMOB6ANxbzbbnLrp9gpJeFQlPxZcIUiwcOmxDeKzMEhvsIQ4dLdckJJ)daoZDHlUETi2OuwHPe0WaAs4FHY07OssufjQlPxZcNDibGDXAitVJkjrvKOUKEnd4qvIbXHGY07OssufCrszsDgcsbzamhBoqFcOlZ8uEHmKfNrE0grafTrD5UMOsxqrV4qSOXGDXAaOS5afT)IOX0LzgTHrHJ(iEIgPqmOL5kfTRrFu0llAjbarRodbPGCC2l6SpiduYLkmj45UgeYDnrLUG4BGU9ArSrP8fXGwMRuM5)HkUpQk4IKYK6meKcYayo2CG(eqxM5P3hfNrE0Nun6JIwDgcsbrByu4OXOcJ0OnMkW)yeWrrFGORO5UIgPpViAJo5hEcaIgTE0L6f58iIgd2fRbGYMduoo7fD2hKbk5sfMe8Cxda2fRbGYMdeFL6fjLuNHGuWnE8nq3QlPxZaQWinPub(hJaoktVJkjrv1L0RzO5fjdKF4jaitVJkjrvbHYbbLHMxKmq(HNaGmJm95bNIxvWfjLj1ziifKbWCS5a9jGUmZ7JQQJjL0njgYizKPppOItioJ8On6JcVCA0vMOlIfnMYC1rqMr7ViAEfTrZ)dGOxOOpw6ck65JwHPOXGDXAae9OrpGOnSmfoAoW8iIgd2fRbGYMdu07hnVIwDgcsb54Sx0zFqgOKlvysWZDnayxSgakBoq8nq3irDj9Awq0fXsaL5QJGmZ07Ossu1RfXgLYOsxqP5tkmLaWUynaYm)pCZRQGlsktQZqqkidG5yZb6taDzM38koJ8Or6ll6l2SSrRhnBvxN95lAoafngSlwdaLnhOOxCiw0y6YmJgpKfTHrHJ2OBegTJWNhOrZDfTUrx7OvNHGuaFrFeYIEGIgPB0JEarZ4(FEerVqqrJV9J2)6r7Ml3RrVqrRodbPaKXx0llAEHSO1nAth)gZPwu0yBLJMWpLEWSF0ggfoAKMNWzuhDKJwp69JMxrRodbPGOXxTJ2WOWrF8OyilhN9Io7dYaLCPctcEURba7I1aqzZbIVb6ghNnoQKYCakDXMLnA9eBvxN9RIp1L0RzO5fjdKF4jaitVJkjrvbHYbbLHMxKmq(HNaGmJm95bNIhU4QUKEnBG8R9nDGsSm9oQKevbxKuMuNHGuqgaZXMd0Na6Ymp9U24IRxlInkLNNWzuhDKJwptVJkjrvuoiOmOUj6kbPfkjixHZCxvbxKuMuNHGuqgaZXMd0Na6Ymp9Mx841IyJszuPlO08jfMsayxSgaz6DujjqwC2l6SpiduYLkmj45UgamhBoqFcOlZKVb6gCrszsDgcsbvCZR4Sx0zFqgOKlvysWZDnayxSgakBoqw1Qwl]] )


end
