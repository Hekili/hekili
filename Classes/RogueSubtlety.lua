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


    spec:RegisterPack( "Subtlety", 20190810, [[da1iNbqiOcpcIYMubFsskLrbr1PGiTkic9kOQMfQk3cvvSlr9ljjddQOJHQyzQqEgQsnnjP6AsIABQqLVbreJdvvX5KKswhQQQMNks3dc7ts4FOQsuhuskSqvepevjnrjrUiQQe2ier9ruvv0irvLiDsiI0kvr9suvvYmrvvPUjQQK2jfYprvvHHcrWsLKIEkuMkfQRIQk1wvHQ8vuvLolQQeXEP0FfzWsDyQwmKESetMWLr2mO(Sk1Ob50kwTKuQETKYSj62u0Uv1VvA4QKJRcv1Yr55atN01rLTdv57uW4rvIZlPA9Qqz(qL2VWwESgBXeUswJocN8uTWj)HhCMpINkx9QBX06xKf7Yl18BYI9UjzXW4qvjP1TyxED56cRXwmWYXkKfds1la)VQQUhfIdnxwZQaJjN01z)cZH1QaJzPklgk3ivK03IAXeUswJocN8uTWj)HhCMpINkxDEZBlMZPqlZIHnM8QfdAec6TOwmbbkwmKfnghQkjTE0vZ9MJIZilAivVa8)QQ6Euio0CznRcmMCsxN9lmhwRcmMLQIZil6Qb3nhqJMhCYx0hHtEQwrZprFeo5)8UYX54mYIMxH8)Ma8)4mYIMFIUAieKiA(xtPw06gTGGDoPgTx0z)OLdqZXzKfn)eD1Kmx8ir0QZUjnnWrx2xm6SF07hn)QZQrIOHxw0vICfkhNrw08t0vdHGerZVbu0iPkzcYwm5auG1ylgqjxQqKWAS1iESgBXO3rLKWEIfRWgLyJBXqE0QlPxZWZlsgiV2taqMEhvsIOXf3ObxKuMuNDtkidG4ytn6taDzMrFA08oAKg9HOrE0OCWWzGsUuHYCxrJlUrJYbdNXZ)baL5UIgPwmVOZ(wmaKlwdaLn1iRAn6iRXwm6DujjSNyXkSrj24wmuoy4maIJn1OpPl7DXM5UI(q0L1eDtx78kili4PmA0NIi6JSyErN9TyfxktErN9tYbOwm5a007MKfdE(bazvRr82ASfJEhvsc7jwScBuInUfdCrszsD2nPGmaIJn1Opb0LzgnIORE0hIUSMOB6ANxbrxbIORUfZl6SVfR4szYl6SFsoa1IjhGME3KSyWZpaiRAnQ6wJTy07OssypXIvyJsSXTyL1eDtx78kili4PmA0NIiAEIMFIg5rRUKEnli6IyjGYC1VjZm9oQKerFiAKhnkhmCgp)hauM7kACXnA)yeBukRqucEyanj8Vqz6DujjI(q04iA1L0RzHZQLaqUynKP3rLKi6drJJOvxsVMbCOkXG5UPm9oQKerFiAWfjLj1z3KcYaio2uJ(eqxMz0NgnVJgPrJulMx0zFlwXLYKx0z)KCaQftoan9UjzXGNFaqw1AuLTgBXO3rLKWEIfRWgLyJBX8JrSrP8fXGxMRuM5FTORar0hf9HObxKuMuNDtkidG4ytn6taDzMrFkIOpYI5fD23IDl31ev6cYQwJooRXwm6DujjSNyX8Io7BXaqUynau2uJSyf2OeBClM6s61mGkmstkvG(54Zrz6DujjI(q0QlPxZWZlsgiV2taqMEhvsIOpeTGq5GHZWZlsgiV2taqMrM(8GOpnAEI(q0GlsktQZUjfKbqCSPg9jGUmZOre9rrFiADmPKUjXqrZprZitFEq0ve9XzXk1lskPo7MuG1iESQ1iKeRXwm6DujjSNyXkSrj24wmCeT6s61SGOlILakZv)MmZ07Osse9HO9JrSrPmQ0fuA(KcrjaKlwdGmZ)ArJiAEh9HObxKuMuNDtkidG4ytn6taDzMrJiAEBX8Io7BXaqUynau2uJSQ1i(J1ylg9oQKe2tSyf2OeBClgEoBCujL5au6InlB06j2QUo7h9HOrE0QlPxZWZlsgiV2taqMEhvsIOpeTGq5GHZWZlsgiV2taqMrM(8GOpnAEIgxCJwDj9A2a5x7B6aLyz6DujjI(q0GlsktQZUjfKbqCSPg9jGUmZOpfr0vpACXnA)yeBukppH3Oo6ihTEMEhvsIOpenkhmCgu3eDLG0cNeKRqzUROpen4IKYK6SBsbzaehBQrFcOlZm6trenVJg)O9JrSrPmQ0fuA(KcrjaKlwdGm9oQKerJulMx0zFlgaYfRbGYMAKvTgvTSgBXO3rLKWEIfRWgLyJBXaxKuMuNDtki6kqenVTyErN9Tyaio2uJ(eqxMPvTgXdoTgBX8Io7BXaqUynau2uJSy07OssypXQw1Iraa9fcyn2AepwJTy07OssypXIvyJsSXTy0tS76zDmPKUjtNxIUIO5j6drJJOr5GHZG6MOReKw4KGCfkZDf9HOrE04iAXQ5Y(f6vMRKiblDtkHYX(SoLAZFh9HOXr0ErN9ZL9l0Rmxjrcw6MuE(eSCUH0OXf3OH5KYeJkqo7Ms6ysrFA03fr205LOrQfZl6SVfRSFHEL5kjsWs3KSQ1OJSgBXO3rLKWEIfRWgLyJBXk7kfRHpdQBIUsqAHtcYvOm3v04IB06ysjDtIHI(uerZdoTyErN9TyOYDfPfoPquIEYSUvTgXBRXwmVOZ(wSBoNjg)tlCYpgXwfYIrVJkjH9eRAnQ6wJTy07OssypXIvyJsSXTyipAWfjLj1z3KcYaio2uJ(eqxMz0vGi6JIgxCJM5Jir4rVMDHaKNp6kI(4Wz0in6drJJOl7kfRHpdQBIUsqAHtcYvOm3v0hIghrJYbdNb1nrxjiTWjb5kuM7k6drtpXURNfe8ugn6kqenVXPfZl6SVfdElCasK8JrSrPek5Mw1AuLTgBXO3rLKWEIfRWgLyJBXaxKuMuNDtkidG4ytn6taDzMrxbIOpkACXnAMpIeHh9A2fcqE(ORi6JdNwmVOZ(wSlo2axF(7eQ0bQvTgDCwJTy07OssypXIvyJsSXTyOCWWzgvQjjaibVScL5UIgxCJgLdgoZOsnjbaj4LvOuz5ELyzG6LArFA08GtlMx0zFlMcrjUhD5ErcEzfYQwJqsSgBX8Io7BXyZ1LKsZNaxEHSy07OssypXQwJ4pwJTy07OssypXIvyJsSXTyOCWWz5atOYDfzG6LArFA082I5fD23IzyzsbE08jgb23)czvRrvlRXwm6DujjSNyXkSrj24wm6j2D9Opn6QJZOpenkhmCgu3eDLG0cNeKRqzUllMx0zFlMjzUS6Pfoj5kJijyKBcSQvTycc25KQ1yRr8yn2IrVJkjH9elwHnkXg3IHJObk5sfIez2EZrwmVOZ(wSAtPMvTgDK1ylMx0zFlgqjxQqwm6DujjSNyvRr82ASfJEhvsc7jwmVOZ(wSIlLjVOZ(j5aulMCaA6DtYIveaRAnQ6wJTy07OssypXIvyJsSXTyaLCPcrISlLwmVOZ(wmg3N8Io7NKdqTyYbOP3njlgqjxQqKWQwJQS1ylg9oQKe2tSyf2OeBClMoMus3KyOORi6Jl6drZitFEq0Ng9DrKnDEj6drxwt0nDTZRGORar0vpA(jAKhToMu0Ngnp4mAKgnsm6JSyErN9Ty)CdPOsxqw1A0Xzn2IrVJkjH9el2EzXaKAX8Io7BXWZzJJkjlgEUKJSyxSzzJwpXw11z)Open4IKYK6SBsbzaehBQrFcOlZm6kqe9rwm8Cw6DtYIXbO0fBw2O1tSvDD23QwJqsSgBXO3rLKWEIfRWgLyJBXWZzJJkPmhGsxSzzJwpXw11zFlMx0zFlwXLYKx0z)KCaQftoan9UjzXak5sfkveaRAnI)yn2IrVJkjH9el2EzXaKAX8Io7BXWZzJJkjlgEUKJSyhv5OXpA1L0Rz8M7LLP3rLKiAKy08UYrJF0QlPxZMoqjwAHtaixSgaz6DujjIgjg9rvoA8JwDj9Aga5I1qcElCGm9oQKerJeJ(iCgn(rRUKEn7sVWgTEMEhvsIOrIrZdoJg)O5PYrJeJg5rdUiPmPo7MuqgaXXMA0Na6YmJUcerZ7OrQfdpNLE3KSyaLCPcLuigbGwPWQwJQwwJTy07OssypXIvyJsSXTy0tS76zbbpLrJ(uerJNZghvszGsUuHskeJaqRuyX8Io7BXkUuM8Io7NKdqTyYbOP3njlgqjxQqPIayvRr8GtRXwm6DujjSNyXkSrj24wm)yeBuk)ZnKcs4r)n5FHY07Osse9HOXr0OCWW5FUHuqcp6Vj)luM7k6drxwt0nDTZRGSGGNYOrxr08e9HOrE0GlsktQZUjfKbqCSPg9jGUmZOpn6JIgxCJgpNnoQKYCakDXMLnA9eBvxN9JgPrFiAKhDzxPyn8zqDt0vcslCsqUcLzKPppi6trenVJgxCJg5r7hJyJs5FUHuqcp6Vj)luM5FTORar0hf9HOr5GHZG6MOReKw4KGCfkZitFEq0venVJ(q04iAGsUuHir2LYOpeDzxPyn8zaKlwdjH)fkxGC2nbsWmVOZ(Um6kqenoZvROrA0i1I5fD23I9ZnKIkDbzvRr8WJ1ylg9oQKe2tSyf2OeBClwznr301oVcYccEkJg9PiIMNOXf3O1XKs6Medf9PiIMNOpeDznr301oVcIUcerZBlMx0zFlwXLYKx0z)KCaQftoan9UjzXGNFaqw1Aephzn2IrVJkjH9elwHnkXg3IbUiPmPo7MuqgaXXMA0Na6YmJgr0vp6drxwt0nDTZRGORar0v3I5fD23IvCPm5fD2pjhGAXKdqtVBswm45haKvTgXdVTgBXO3rLKWEIfRWgLyJBXONy31ZccEkJg9PiIgpNnoQKYaLCPcLuigbGwPWI5fD23IvCPm5fD2pjhGAXKdqtVBswmuUrkSQ1iEQU1ylg9oQKe2tSyf2OeBClg9e7UEwqWtz0ORar08u5OXpA6j2D9mJUP3I5fD23I5SI)usxgJE1QwJ4PYwJTyErN9TyoR4pLU4KaYIrVJkjH9eRAnINJZASfZl6SVfto3qkivTZjUnPxTy07OssypXQw1IDXOYAI6Q1yRr8yn2I5fD23IbuYLkKfJEhvsc7jw1A0rwJTy07OssypXI5fD23Iz6SAKibVSKGCfYIDXOYAI6AcqL9falgpv2QwJ4T1ylg9oQKe2tSyErN9TyaixSgsOsxqal2fJkRjQRjav2xaSy8yvRrv3ASfZl6SVf7A1zFlg9oQKe2tSQ1OkBn2IrVJkjH9el27MKfZpgaYzoibVVMw401AGywmVOZ(wm)yaiN5Ge8(AAHtxRbIzvRAXq5gPWAS1iESgBXO3rLKWEIfRWgLyJBXaxKuMuNDtki6kqe9rrJF0ipA1L0R5B5UMOsxqz6DujjI(q0(Xi2Ou(IyWlZvkZ8Vw0vGi6JIgPwmVOZ(wmaehBQrFcOlZ0QwJoYASfZl6SVf7wURjQ0fKfJEhvsc7jw1AeVTgBX8Io7BXq9snG6Owm6DujjSNyvRAXkcG1yRr8yn2IrVJkjH9elwHnkXg3IHJOr5GHZaixSgsc)luM7k6drJYbdNbqCSPg9jDzVl2m3v0hIgLdgodG4ytn6t6YExSzgz6ZdI(uerZ7CLTyErN9TyaixSgsc)lKfJdqPfgoDxewmESQ1OJSgBXO3rLKWEIfRWgLyJBXq5GHZaio2uJ(KUS3fBM7k6drJYbdNbqCSPg9jDzVl2mJm95brFkIO5DUYwmVOZ(wmqDt0vcslCsqUczX4auAHHt3fHfJhRAnI3wJTy07OssypXIvyJsSXTy4iAGsUuHir2LYOpeTy18p3qkQ0fuwNsT5VTyErN9TyfxktErN9tYbOwm5a007MKfJaa6leWQwJQU1ylg9oQKe2tSyErN9Tyx7ktmcSCSczXkSrj24wmCeT6s61maYfRHe8w4az6DujjSyWll9eVOwJ4XQwJQS1ylg9oQKe2tSyf2OeBClg9e7UE0vGi6JdNrFiAXQ5FUHuuPlOSoLAZFh9HOl7kfRHpdQBIUsqAHtcYvOm3v0hIUSRuSg(maYfRHKW)cLlqo7MarxbIO5XI5fD23IbG4ytn6t6YExSw1A0Xzn2IrVJkjH9elwHnkXg3Ijwn)ZnKIkDbL1PuB(7OpenYJghrRUKEndG4ytn6t6YExSz6DujjIgxCJwDj9Aga5I1qcElCGm9oQKerJlUrx2vkwdFgaXXMA0N0L9UyZmY0NheDfrFu0in6drJ8OXr0eaqFHYOYDfPfoPquIEYSE20R2xw04IB0LDLI1WNrL7kslCsHOe9Kz9mJm95brxr0hfnsJ(q0ipA)yeBuk)ZnKcs4r)n5FHYm)Rf9PrFu04IB0OCWW5FUHuqcp6Vj)luM7kAKAX8Io7BXa1nrxjiTWjb5kKvTgHKyn2IrVJkjH9elMx0zFlMPZQrIe8YscYvilwHnkXg3IX8rKi8OxZUqaYCxrFiAKhT6SBsZ6ysjDtIHI(0OlRj6MU25vqwqWtz0OXf3OXr0aLCPcrISlLrFi6YAIUPRDEfKfe8ugn6kqeD5kz68scCrViAKAXk1lskPo7MuG1iESQ1i(J1ylg9oQKe2tSyf2OeBClgZhrIWJEn7cbipF0venVXz08t0mFejcp61SleGSGJ56SF0hIghrduYLkejYUug9HOlRj6MU25vqwqWtz0ORar0LRKPZljWf9clMx0zFlMPZQrIe8YscYviRAnQAzn2IrVJkjH9elwHnkXg3Ivwt0nDTZRGSGGNYOrxbIOpkA8JgOKlvisKDP0I5fD23IbGCXAiHkDbbSQ1iEWP1ylg9oQKe2tSyf2OeBClM6s61maYfRHe8w4az6DujjI(q0IvZ)CdPOsxqzDk1M)o6drJYbdNb1nrxjiTWjb5kuM7YI5fD23IbG4ytn6t6YExSw1Aep8yn2IrVJkjH9elwHnkXg3IHJOr5GHZaixSgsc)luM7k6drRJjL0njgk6treDLJg)OvxsVMbCOkXG5UPm9oQKerFiACenZhrIWJEn7cbiZDzX8Io7BXaqUynKe(xiRAnINJSgBXO3rLKWEIfRWgLyJBXq5GHZOYDfsoGMzKx0OXf3Or5GHZG6MOReKw4KGCfkZDf9HOrE0OCWWzaKlwdjuPliqM7kACXn6YUsXA4ZaixSgsOsxqGmJm95brFkIO5bNrJulMx0zFl21QZ(w1Aep82ASfJEhvsc7jwScBuInUfdLdgodQBIUsqAHtcYvOm3LfZl6SVfdvURibZXQBvRr8uDRXwm6DujjSNyXkSrj24wmuoy4mOUj6kbPfojixHYCxwmVOZ(wmuIbiwT5VTQ1iEQS1ylg9oQKe2tSyf2OeBClgkhmCgu3eDLG0cNeKRqzUllMx0zFlg8Wiu5UcRAnINJZASfJEhvsc7jwScBuInUfdLdgodQBIUsqAHtcYvOm3LfZl6SVfZ)cbuMltfxkTQ1iEqsSgBXO3rLKWEIfZl6SVfRuVixLT)usOshOwScBuInUfdhrduYLkejYUug9HOfRM)5gsrLUGY6uQn)D0hIghrJYbdNb1nrxjiTWjb5kuM7k6drtpXURNfe8ugn6kqenVXPfJGHPIME3KSyL6f5QS9Nscv6a1QwJ4H)yn2IrVJkjH9elMx0zFlMFmaKZCqcEFnTWPR1aXSyf2OeBClgoIgLdgodGCXAij8VqzUROpeDzxPyn8zqDt0vcslCsqUcLzKPppi6tJMhCAXE3KSy(XaqoZbj4910cNUwdeZQwJ4PAzn2IrVJkjH9elMx0zFlMdGWZFcKy(XwwQSmxAXkSrj24wmbHYbdNz(XwwQSmxMeekhmCwSg(OXf3OfekhmCUSVGROdEuA(AjbHYbdN5UI(q0QZUjndrUuHYxfn6tJM38enU4gnoIwqOCWW5Y(cUIo4rP5RLeekhmCM7k6drJ8OfekhmCM5hBzPYYCzsqOCWWzG6LArxbIOpQYrZprZdoJgjgTGq5GHZOYDfPfoPquIEYSEM7kACXnADmPKUjXqrFA0vhNrJ0OpenkhmCgu3eDLG0cNeKRqzgz6ZdIUIO5pwS3njlMdGWZFcKy(XwwQSmxAvRrhHtRXwm6DujjSNyXE3KSyM1foiPUCaM(BX8Io7BXmRlCqsD5am93QwJoIhRXwm6DujjSNyXkSrj24wmuoy4mOUj6kbPfojixHYCxrJlUrRJjL0njgk6tJ(iCAX8Io7BX4auAuYeyvRAXak5sfkveaRXwJ4XASfJEhvsc7jwS9YIbi1I5fD23IHNZghvswm8CjhzXk7kfRHpdGCXAij8Vq5cKZUjqcM5fD23LrxbIO5jJKuzlgEol9UjzXaqIKcXia0kfw1A0rwJTy07OssypXIvyJsSXTy4iA8C24OskdGejfIraOvkI(q0L1eDtx78kili4PmA0venprFiAbHYbdNHNxKmqETNaGmJm95brFA08yX8Io7BXWZ)bazvRr82ASfJEhvsc7jwmVOZ(wSRDLjgbwowHSyeVOmp5Ml3RwSQJtlg8YspXlQ1iESQ1OQBn2IrVJkjH9elwHnkXg3IrpXURhDfiIU64m6drtpXURNfe8ugn6kqenp4m6drJJOXZzJJkPmasKuigbGwPi6drxwt0nDTZRGSGGNYOrxr08e9HOfekhmCgEErYa51EcaYmY0Nhe9PrZJfZl6SVfda5I1Gjjfw1AuLTgBXO3rLKWEIfBVSyasTyErN9Ty45SXrLKfdpxYrwSYAIUPRDEfKfe8ugn6kqeD1Ty45S07MKfdajsL1eDtx78kWQwJooRXwm6DujjSNyX2llgGulMx0zFlgEoBCujzXWZLCKfRSMOB6ANxbzbbpLrJ(uerZt04h9rrJeJ2pgXgLYkeLGhgqtc)luMEhvsclwHnkXg3IHNZghvszoaLUyZYgTEITQRZ(rFiAKhT6s618p3qkqDznILP3rLKiACXnA1L0RzHZQLaqUynKP3rLKiAKAXWZzP3njlgasKkRj6MU25vGvTgHKyn2IrVJkjH9elwHnkXg3IHNZghvszaKivwt0nDTZRGOpenYJghrRUKEnlCwTeaYfRHm9oQKerJlUrlwn)ZnKIkDbLzKPppi6kqeDLJg)OvxsVMbCOkXG5UPm9oQKerJ0OpenYJgpNnoQKYairsHyeaALIOXf3Or5GHZG6MOReKw4KGCfkZitFEq0vGiAEYhfnU4gn4IKYK6SBsbzaehBQrFcOlZm6kqeD1J(q0LDLI1WNb1nrxjiTWjb5kuMrM(8GORiAEWz0in6drJ8O9JrSrP8p3qkiHh93K)fkZ8Vw0Ng9rrJlUrJYbdN)5gsbj8O)M8VqzUROrQfZl6SVfda5I1qs4FHSQ1i(J1ylg9oQKe2tSyf2OeBClgEoBCujLbqIuznr301oVcI(q06ysjDtIHI(0Ol7kfRHpdQBIUsqAHtcYvOmJm95brFiACenZhrIWJEn7cbiZDzX8Io7BXaqUynKe(xiRAvlg88daYAS1iESgBXO3rLKWEIfdEzPN4f1AepwmVOZ(wSRDLjgbwowHSQ1OJSgBXO3rLKWEIfRWgLyJBXq5GHZ)CdPGeE0Ft(xOm3LfZl6SVfJWBafI5kzvRr82ASfJEhvsc7jwScBuInUfd5rJJOvxsVMfoRwca5I1qMEhvsIOXf3OXr0OCWWzaKlwdjH)fkZDfnsJ(q06ysjDtIHIMFIMrM(8GORi6Jl6drZitFEq0NgToLAjDmPOrIrFKfZl6SVf7NBifv6cYQwJQU1ylg9oQKe2tSyErN9Ty)CdPOsxqwScBuInUfdhrJNZghvszoaLUyZYgTEITQRZ(rFiAWfjLj1z3KcYaio2uJ(eqxMz0vGi6JI(q0ipA)yeBuk)ZnKcs4r)n5FHY07OssenU4gnoI2pgXgLYm6sofxN)obGCXAaKP3rLKiACXnAWfjLj1z3KcYaio2uJ(eqxMz08t0Erh8OKy18p3qkQ0fu0vGi6JIgPrFiACenkhmCga5I1qs4FHYCxrFiADmPKUjXqrxbIOrE0voA8Jg5rFu0iXOlRj6MU25vq0inAKg9HOzemJaqoQKSyL6fjLuNDtkWAepw1AuLTgBXO3rLKWEIfRWgLyJBXyKPppi6tJUSRuSg(mOUj6kbPfojixHYmY0Nhen(rZdoJ(q0LDLI1WNb1nrxjiTWjb5kuMrM(8GOpfr0vo6drRJjL0njgkA(jAgz6ZdIUIOl7kfRHpdQBIUsqAHtcYvOmJm95brJF0v2I5fD23I9ZnKIkDbzvRrhN1ylg9oQKe2tSyf2OeBClgkhmCgu3eDLG0cNeKRqzUROpenYJghrRUKEnlCwTeaYfRHm9oQKerJlUrJYbdNbqUynKe(xOm3v0i1I5fD23IbOcJ0KsfOFo(CKvTgHKyn2IrVJkjH9elwHnkXg3IbUiPmPo7MuqgaXXMA0Na6YmJUcerFu04hT6s61SWz1saixSgY07Ossen(rRUKEn)ZnKcuxwJyz6DujjSyErN9TyaQWinPub6NJphzvRr8hRXwmVOZ(wmcVbuiMRKfJEhvsc7jw1Qw1IHhXaZ(wJocN8uTWj)bN82IzWz)83algsQ51Yusen)jAVOZ(rlhGcYXzl2fBHhjzXqw0yCOQK06rxn3BokoJSOHu9cW)RQQ7rH4qZL1SkWyYjDD2VWCyTkWywQkoJSORgC3CanAEWjFrFeo5PAfn)e9r4K)Z7khNJZilAEfY)BcW)JZilA(j6QHqqIO5FnLArRB0cc25KA0ErN9JwoanhNrw08t0vtYCXJerRo7M00ahDzFXOZ(rVF08RoRgjIgEzrxjYvOCCgzrZprxnecsen)gqrJKQKjihNJZilA(f8cv4usenkbVmk6YAI6A0O098GC0vJsHUuq0)(8dKZmH5Kr7fD2he9(Y654mYI2l6SpiFXOYAI6kcyPdQfNrw0ErN9b5lgvwtuxXhrvo3Tj9QRZ(XzKfTx0zFq(IrL1e1v8ruf8UI4mYIg79la0QrZ8renkhmmjIgOUcIgLGxgfDznrDnAu6EEq0(lI(Ir8Z1Q683rpGOf7t54mYI2l6SpiFXOYAI6k(iQc8(faA1eqDfeN9Io7dYxmQSMOUIpIQak5sfko7fD2hKVyuznrDfFevz6SAKibVSKGCfIVlgvwtuxtaQSVaGGNkhN9Io7dYxmQSMOUIpIQaqUynKqLUGa8DXOYAI6AcqL9fae8eN9Io7dYxmQSMOUIpIQUwD2po7fD2hKVyuznrDfFevXbO0OKjFVBsi8JbGCMdsW7RPfoDTgiwCooJSO5xWluHtjr0eEeRE06ysrRqu0Erxw0diAhpFKoQKYXzKfD1Kak5sfk6bo6RfagujfnY)nA84KpXCujfn9K5qGONp6YAI6ksJZErN9biQnLA8nWiWbqjxQqKiZ2Boko7fD2hGpIQak5sfkoJSO5viQulAETsGODnA4Hb04Sx0zFa(iQQ4szYl6SFsoaLV3njefbioJSORMCF0WCsz9ObggTarGO1nAfIIgtjxQqKi6Q5QUo7hnYrRhTyN)oAWYx0Jgn8Ykei6RDLZFh9ah9Vk083rpGOD88r6OscP54Sx0zFa(iQIX9jVOZ(j5au(E3KqauYLkej4BGrauYLkejYUugNrw0vJRlz9OnAUHuuPlOODn6JWpAEfjeTGJn)D0kefn8WaA08GZObuzFbGVODyLyrRqUgD1XpAEfje9ah9Ort8Y1Wiq0ggfA(Ovik6N4fnA(N8ALIEzrpGO)vJM7ko7fD2hGpIQ(5gsrLUG4BGrOJjL0njgQIJ7aJm95bNExeztNxouwt0nDTZRGkquD(b56ysNYdorks8O4mYIM)XlRhDbY)BkA2QUo7h9ahTbkAihpk6l2SSrRNyR66SF0asJ2Fr0MCsDUKu0QZUjfen3voo7fD2hGpIQWZzJJkj(E3KqWbO0fBw2O1tSvDD2Np8CjhH4InlB06j2QUo7FaCrszsD2nPGmaIJn1Opb0LzwbIJIZilAKaBw2O1JUAUQRZ(8lhn)BsR2arFp4rr7rxy(v0o6YPrtpXURhn8YIwHOObk5sfkAETsGOrok3ifelAGosz0mcCrfn6rrAoA(LWDXx0JgDX)OrPOvixJgmMxskhN9Io7dWhrvfxktErN9tYbO89UjHaOKlvOura4BGrGNZghvszoaLUyZYgTEITQRZ(XzKfn)gqIO1nAbbppfTbi6Jw3O5au0aLCPcfnVwjq0llAuUrkigio7fD2hGpIQWZzJJkj(E3KqauYLkusHyeaALc(WZLCeIJQm(QlPxZ4n3lltVJkjbsK3vgF1L0RzthOelTWjaKlwdGm9oQKeiXJQm(QlPxZaixSgsWBHdKP3rLKajEeoXxDj9A2LEHnA9m9oQKeirEWj(8uzKiYbxKuMuNDtkidG4ytn6taDzMvGG3inoJSO519bJGyrZbM)oApAmLCPcfnVwPOnarF0mYlqZFhTcrrtpXURhTcXia0kfXzVOZ(a8ruvXLYKx0z)KCakFVBsiak5sfkvea(gye0tS76zbbpLrpfbEoBCujLbk5sfkPqmcaTsrCgzrB0CdPvBGOpE0Ft(xi(F0gn3qkQ0fu0Oe8YOOXQBIUsq0UgTCnenVIeIw3OlRj68u0KZK1JMrWmcafTHrHI(MuD(7OvikAuoy4O5UYrxnKGnA5AiAEfjeTGJn)D0y1nrxjiAusnq0hDL8VqGOnmku0hHF0gD8YXzVOZ(a8ru1p3qkQ0feFdmc)yeBuk)ZnKcs4r)n5FHY07OssCahOCWW5FUHuqcp6Vj)luM76qznr301oVcYccEkJwbphqo4IKYK6SBsbzaehBQrFcOlZ80JWfx8C24OskZbO0fBw2O1tSvDD2hPhqEzxPyn8zqDt0vcslCsqUcLzKPpp4ue8gxCrUFmInkL)5gsbj8O)M8VqzM)1QaXrhq5GHZG6MOReKw4KGCfkZitFEqf8(aoak5sfIezxkpu2vkwdFga5I1qs4FHYfiNDtGemZl6SVlRaboZvlKI04mYIgjp)aGI21ORo(rByuOLtJUsy8fDLXpAdJcfDLWIg5lNcgbfnqjxQqino7fD2hGpIQkUuM8Io7NKdq57Dtcb88daIVbgrznr301oVcYccEkJEkcEWfxDmPKUjXqNIGNdL1eDtx78kOce8ooJSO5VJcfDLWI2LGnA45hau0UgD1XpA)2NhOrt8Ixuz9ORE0QZUjfenYxofmckAGsUuHqAC2l6SpaFevvCPm5fD2pjhGY37Mec45haeFdmcWfjLj1z3KcYaio2uJ(eqxMjIQFOSMOB6ANxbvGO6XzKfn)gqr7rJYnsbXI2ae9rZiVan)D0kefn9e7UE0keJaqRueN9Io7dWhrvfxktErN9tYbO89UjHaLBKc(gye0tS76zbbpLrpfbEoBCujLbk5sfkPqmcaTsrCgzrZ)Enqan6l2SSrRh98r7sz0lC0kefD1ajW)oAuQ4Cak6rJU4CaceThn)tETsXzVOZ(a8ruLZk(tjDzm6v(gye0tS76zbbpLrRabpvgF6j2D9mJUPpo7fD2hGpIQCwXFkDXjbuC2l6SpaFevjNBifKQ25e3M0RX54mYI(eUrkigio7fD2hKr5gPabaIJn1Opb0LzY3aJaCrszsD2nPGkqCe(ixDj9A(wURjQ0fuMEhvsId(Xi2Ou(IyWlZvkZ8VwfiocPXzVOZ(Gmk3if4JOQB5UMOsxqXzVOZ(Gmk3if4JOkuVudOoACooJSO51DLI1WdIZilA(nGIUs(xOOxyy(5UiIgLGxgfTcrrdpmGgngehBQrF0y6YmJgMTMrB8YExSrxwtce9854Sx0zFqUiaiaqUynKe(xi(4auAHHt3fbcE4BGrGduoy4maYfRHKW)cL5UoGYbdNbqCSPg9jDzVl2m31buoy4maIJn1OpPl7DXMzKPpp4ue8ox54mYIg587xsaq0UKrUOE0CxrJsfNdqrBGIw3Tw0yqUynensElCaKgnhGIgRUj6kbrVWW8ZDrenkbVmkAfIIgEyanAmio2uJ(OX0LzgnmBnJ24L9UyJUSMei65ZXzVOZ(GCraWhrvG6MOReKw4KGCfIpoaLwy40DrGGh(gyeOCWWzaehBQrFsx27InZDDaLdgodG4ytn6t6YExSzgz6ZdofbVZvoo7fD2hKlca(iQQ4szYl6SFsoaLV3njeeaqFHa8nWiWbqjxQqKi7s5bXQ5FUHuuPlOSoLAZFhNrw0iHDLrdVSOnEzVl2OVye)GTvkAdJcfnguLIMrUOE0gGOp6F1OzC)p)D0yi5CC2l6Spixea8ru11UYeJalhRq8bVS0t8IIGh(gye4qDj9Aga5I1qcElCGm9oQKeXzKfn)gqrB8YExSrFXOOX2kfTbi6J2afnKJhfTcrrtpXURhTbisHiw0WS1m6RDLZFhTHrHwonAmKC0ll6QDoGg9n9eZLY654Sx0zFqUia4JOkaehBQrFsx27ILVbgb9e7UEfiooCEqSA(NBifv6ckRtP283hk7kfRHpdQBIUsqAHtcYvOm31HYUsXA4ZaixSgsc)luUa5SBcubcEIZilA(nGIgRUj6kbrVF0LDLI1WhnYDyLyrdpmGgTrZnKIkDbH0O5EjbarBGI2zu03783rRB0x7v0gVS3fB0(lIwSr)RgnKJhfngKlwdrJK3chihN9Io7dYfbaFevbQBIUsqAHtcYvi(gyeIvZ)CdPOsxqzDk1M)(aYXH6s61maIJn1OpPl7DXMP3rLKaxCvxsVMbqUynKG3chitVJkjbU4w2vkwdFgaXXMA0N0L9UyZmY0NhuXri9aYXbba0xOmQCxrAHtkeLONmRNn9Q9LHlULDLI1WNrL7kslCsHOe9Kz9mJm95bvCespGC)yeBuk)ZnKcs4r)n5FHYm)RD6r4IlkhmC(NBifKWJ(BY)cL5UqACgzrJKchTleGODgfn3fFrd(5IIwHOO3NI2WOqrlxdeqJ2yJRuoA(nGI2ae9rlQp)D0Woqjw0kK)rZRiHOfe8ugn6Lf9VA0aLCPcrIOnmk0YPr7F9O5vKqoo7fD2hKlca(iQY0z1ircEzjb5keFL6fjLuNDtkabp8nWiy(iseE0RzxiazURdixD2nPzDmPKUjXqNwwt0nDTZRGSGGNYO4Iloak5sfIezxkpuwt0nDTZRGSGGNYOvGOCLmDEjbUOxG04mYIgjfo6FJ2fcq0ggPmAXqrByuO5JwHOOFIx0O5nob8fnhGIMFfUsrVF0OlaeTHrHwonA)RhnVIeI2Fr0)gnqjxQq54Sx0zFqUia4JOktNvJej4LLeKRq8nWiy(iseE0Rzxia55RG34KFy(iseE0RzxiazbhZ1z)d4aOKlvisKDP8qznr301oVcYccEkJwbIYvY05Le4IErC2l6Spixea8rufaYfRHeQ0feGVbgrznr301oVcYccEkJwbIJWhOKlvisKDPmoJSO5VJcfngsMVOh4O)vJ2LmYf1JwSpXx0CakAJx27InAdJcfn2wPO5UYXzVOZ(GCraWhrvaio2uJ(KUS3flFdmc1L0RzaKlwdj4TWbY07OssCqSA(NBifv6ckRtP283hq5GHZG6MOReKw4KGCfkZDfN9Io7dYfbaFevbGCXAij8Vq8nWiWbkhmCga5I1qs4FHYCxh0XKs6MedDkIkJV6s61mGdvjgm3nLP3rLK4aoy(iseE0RzxiazUR4Sx0zFqUia4JOQRvN95BGrGYbdNrL7kKCanZiVO4IlkhmCgu3eDLG0cNeKRqzURdihLdgodGCXAiHkDbbYCx4IBzxPyn8zaKlwdjuPliqMrM(8GtrWdorAC2l6Spixea8rufQCxrcMJvNVbgbkhmCgu3eDLG0cNeKRqzUR4Sx0zFqUia4JOkuIbiwT5V5BGrGYbdNb1nrxjiTWjb5kuM7ko7fD2hKlca(iQcEyeQCxbFdmcuoy4mOUj6kbPfojixHYCxXzVOZ(GCraWhrv(xiGYCzQ4sjFdmcuoy4mOUj6kbPfojixHYCxXzVOZ(GCraWhrvCaknkzYhbdtfn9UjHOuVixLT)usOshO8nWiWbqjxQqKi7s5bXQ5FUHuuPlOSoLAZFFahOCWWzqDt0vcslCsqUcL5UoqpXURNfe8ugTce8gNXzVOZ(GCraWhrvCaknkzY37Mec)yaiN5Ge8(AAHtxRbIX3aJahOCWWzaKlwdjH)fkZDDOSRuSg(mOUj6kbPfojixHYmY0NhCkp4moJSOpEeRE0SL7gswpAgNKIEHJwH4mrh4HerB6keiAusUg4)rZVbu0WllAK0V21kIUWgLVOxfIyggafTHrHIgBRu0Ug9rvg)ObQxQbIEzrZtLXpAdJcfTlbB0Ni3ven3voo7fD2hKlca(iQIdqPrjt(E3Kq4ai88NajMFSLLklZL8nWieekhmCM5hBzPYYCzsqOCWWzXA4XfxbHYbdNl7l4k6GhLMVwsqOCWWzURdQZUjndrUuHYxf9uEZdU4IdbHYbdNl7l4k6GhLMVwsqOCWWzURdixqOCWWzMFSLLklZLjbHYbdNbQxQvbIJQm)WdorIccLdgoJk3vKw4Kcrj6jZ6zUlCXvhtkPBsm0PvhNi9akhmCgu3eDLG0cNeKRqzgz6ZdQG)eN9Io7dYfbaFevXbO0OKjFVBsimRlCqsD5am9poJSOReb7CsnAyxkr9sTOHxw0Cahvsrpkzc4)rZVbu0ggfkAS6MORee9chDLixHYXzVOZ(GCraWhrvCaknkzc4BGrGYbdNb1nrxjiTWjb5kuM7cxC1XKs6MedD6r4mohNrw08laa6leio7fD2hKjaG(cbqu2VqVYCLejyPBs8nWiONy31Z6ysjDtMoVubphWbkhmCgu3eDLG0cNeKRqzURdihhIvZL9l0Rmxjrcw6MucLJ9zDk1M)(ao8Io7Nl7xOxzUsIeS0nP88jy5CdP4IlmNuMyubYz3usht607IiB68csJZErN9bzcaOVqa8rufQCxrAHtkeLONmRZ3aJOSRuSg(mOUj6kbPfojixHYCx4IRoMus3KyOtrWdoJZErN9bzcaOVqa8ru1nNZeJ)Pfo5hJyRcfN9Io7dYeaqFHa4JOk4TWbirYpgXgLsOKBY3aJa5GlsktQZUjfKbqCSPg9jGUmZkqCeU4Y8rKi8OxZUqaYZxXXHtKEahLDLI1WNb1nrxjiTWjb5kuM76aoq5GHZG6MOReKw4KGCfkZDDGEIDxpli4PmAfi4noJZErN9bzcaOVqa8ru1fhBGRp)Dcv6aLVbgb4IKYK6SBsbzaehBQrFcOlZScehHlUmFejcp61SleG88vCC4mo7fD2hKjaG(cbWhrvkeL4E0L7fj4Lvi(gyeOCWWzgvQjjaibVScL5UWfxuoy4mJk1KeaKGxwHsLL7vILbQxQDkp4mo7fD2hKjaG(cbWhrvS56ssP5tGlVqXzVOZ(Gmba0xia(iQYWYKc8O5tmcSV)fIVbgbkhmCwoWeQCxrgOEP2P8oo7fD2hKjaG(cbWhrvMK5YQNw4KKRmIKGrUjGVbgb9e7U(PvhNhq5GHZG6MOReKw4KGCfkZDfNJZilAK88daIyG4Sx0zFqgE(baH4AxzIrGLJvi(Gxw6jErrWtCgzrZVaVbuiMRu0qoiAO5gIaA0xSzzJwpAdJcfTrZnKwTbI(4r)n5FHIM7khN9Io7dYWZpai8rufH3akeZvIVbgbkhmC(NBifKWJ(BY)cL5UIZilA(xeDfn3v0gn3qkQ0fu0dC0Jg9aI2rxonADJMX9rVCAo6kTr)RgnhGI2OtIwWXM)o6k5FH4l6boA1L0RKi651n6k5SArJb5I1qoo7fD2hKHNFaq4JOQFUHuuPli(gyeihhQlPxZcNvlbGCXAitVJkjbU4Iduoy4maYfRHKW)cL5Uq6bDmPKUjXq8dJm95bvCChyKPpp4uDk1s6ysiXJIZilA(voPoIv15VJE5uWiOORK)fk69JwD2nPGOvixJ2WiLrlh8OOHxw0kefTGJ56SF0lC0gn3qkQ0feFrZiygbGIwWXM)o6l)fK5uYrZVYj1rSA0oiA5(3r7GOpc)OvNDtkiAXg9VA0qoEu0gn3qkQ0fu0CxrByuOORM0LCkUo)D0yqUynaIg5CVKaGORVCrd54rrB0CdPvBGOpE0Ft(xOO1DrAoo7fD2hKHNFaq4JOQFUHuuPli(k1lskPo7MuacE4BGrGd8C24OskZbO0fBw2O1tSvDD2)a4IKYK6SBsbzaehBQrFcOlZScehDa5(Xi2Ou(NBifKWJ(BY)cLP3rLKaxCXHFmInkLz0LCkUo)Dca5I1aitVJkjbU4cUiPmPo7MuqgaXXMA0Na6Ym5hVOdEusSA(NBifv6cQcehH0d4aLdgodGCXAij8VqzURd6ysjDtIHQabYRm(i)iKyznr301oVcqkspWiygbGCujfNrw0vtcMraOOnAUHuuPlOOjNjRh9ah9OrByKYOjE5Ayu0co283rJv3eDLGC0vAJwHCnAgbZiau0dC0yBLI(Muq0mYf1JE(Ovik6N4fn6kdYXzVOZ(Gm88dacFev9ZnKIkDbX3aJGrM(8Gtl7kfRHpdQBIUsqAHtcYvOmJm95b4Zdopu2vkwdFgu3eDLG0cNeKRqzgz6ZdofrLpOJjL0njgIFyKPppOIYUsXA4ZG6MOReKw4KGCfkZitFEa(vooJSOXOcJ0OnMkq)C85OOfCS5VJgRUj6kb5O5VJcfDLCwTOXGCXAi69L1JwWXM)oAmixSgIUs(xOOro3RJmAfIraOvkIE(OFIx0OLZtinhN9Io7dYWZpai8rufGkmstkvG(54Zr8nWiq5GHZG6MOReKw4KGCfkZDDa54qDj9Aw4SAjaKlwdz6DujjWfxuoy4maYfRHKW)cL5UqACgzrZFhfkA6xUBOOvNDtkiAxAWRdIMdqrJrfJPs07hnVwPCC2l6Spidp)aGWhrvaQWinPub6NJphX3aJaCrszsD2nPGmaIJn1Opb0LzwbIJWxDj9Aw4SAjaKlwdz6DujjWxDj9A(NBifOUSgXY07OsseN9Io7dYWZpai8rufH3akeZvkohNrw0yk5sfkAEDxPyn8G4mYIMFPK8IyrF8C24Osko7fD2hKbk5sfkveae45SXrLeFVBsiaqIKcXia0kf8HNl5ieLDLI1WNbqUynKe(xOCbYz3eibZ8Io77YkqWtgjPYXzKf9XZ)bafn3ljaiAdu0oJI2rxonADJU4xrVF0vY)cfDbYz3eihn)JxwpAdq0hnsEEr08xYR9eae9aI2rxonADJMX9rVCAoo7fD2hKbk5sfkvea8rufE(pai(gye4apNnoQKYairsHyeaALIdL1eDtx78kili4PmAf8CqqOCWWz45fjdKx7jaiZitFEWP8eNrw0iHDLrdVSOXGCXAWKKIOXpAmixSgakBQrrZ9scaI2afTZOOD0LtJw3Ol(v07hDL8VqrxGC2nbYrZ)4L1J2ae9rJKNxen)L8ApbarpGOD0LtJw3OzCF0lNMJZErN9bzGsUuHsfbaFevDTRmXiWYXkeFWll9eVOi4HpIxuMNCZL7vevhNXzVOZ(GmqjxQqPIaGpIQaqUynyssbFdmc6j2D9kquDCEGEIDxpli4PmAfi4bNhWbEoBCujLbqIKcXia0kfhkRj6MU25vqwqWtz0k45GGq5GHZWZlsgiV2taqMrM(8Gt5joJSO5vKq0m64ZnmYKEL)hDL8Vqr7A0Y1q08ksiA06rliyNtQ54Sx0zFqgOKlvOuraWhrv45SXrLeFVBsiaqIuznr301oVc4dpxYrikRj6MU25vqwqWtz0kqu94mYIMxrcrZOJp3Wit6v(F0vY)cf9(Y6rJsWlJIgE(barmq0dC0gOOHC8OODZROvxsVcI2Fr0xSzzJwpA2QUo7NJZErN9bzGsUuHsfbaFevHNZghvs89UjHaajsL1eDtx78kGp8CjhHOSMOB6ANxbzbbpLrpfbp4Fes0pgXgLYkeLGhgqtc)luMEhvsc(gye45SXrLuMdqPl2SSrRNyR66S)bKRUKEn)ZnKcuxwJyz6DujjWfx1L0RzHZQLaqUynKP3rLKaPXzKfn)DuOORKZQfngKlwdrVVSE0vY)cfTbi6J2O5gsrLUGI2WiLrduVE0Cx5O53akAbhB(7OXQBIUsq0llAhDXJIwHyeaALIC08xF0OHxw0gD8IgLdgoAdJcf9r4B0XlhN9Io7dYaLCPcLkca(iQca5I1qs4FH4BGrGNZghvszaKivwt0nDTZRGdihhQlPxZcNvlbGCXAitVJkjbU4kwn)ZnKIkDbLzKPppOcevgF1L0RzahQsmyUBktVJkjbspGC8C24OskdGejfIraOvkWfxuoy4mOUj6kbPfojixHYmY0NhubcEYhHlUGlsktQZUjfKbqCSPg9jGUmZkqu9dLDLI1WNb1nrxjiTWjb5kuMrM(8Gk4bNi9aY9JrSrP8p3qkiHh93K)fkZ8V2PhHlUOCWW5FUHuqcp6Vj)luM7cPXzKf9jCSpAgz6Zp)D0vY)cbIgLGxgfTcrrRo7M0OfdbIEGJgBRu0g2VAtJgLIMrUOE0ZhToMuoo7fD2hKbk5sfkvea8rufaYfRHKW)cX3aJapNnoQKYairQSMOB6ANxbh0XKs6MedDAzxPyn8zqDt0vcslCsqUcLzKPpp4aoy(iseE0RzxiazUR4CCgzrJPKlviseD1CvxN9JZilAKu4OXuYLkuv45)aGI2zu0Cx8fnhGIgdYfRbGYMAu06gnk9e8OrdZwZOvik6lhag8OOr3NdeT)IOrYZlIM)sETNaa(IMWJ(Oh4Onqr7mkAxJ205LO5vKq0ihMTMrRqu0xmQSMOUgn)kCLqAoo7fD2hKbk5sfIeiaqUynau2uJ4BGrGC1L0Rz45fjdKx7jaitVJkjbU4cUiPmPo7MuqgaXXMA0Na6YmpL3i9aYr5GHZaLCPcL5UWfxuoy4mE(paOm3fsJZilAK88dakAxJM34hnVIeI2WOqlNgDLWIUQORo(rByuOORew0ggfkAmio2uJ(OnEzVl2Or5GHJM7kADJ2XBhr0G1KIMxrcrBWbkfnyuoxN9b54Sx0zFqgOKlvisGpIQkUuM8Io7NKdq57Dtcb88daIVbgbkhmCgaXXMA0N0L9UyZCxhkRj6MU25vqwqWtz0trCuCgzrxnKGnAGdtrRB0WZpaOODn6QJF08ksiAdJcfnXlErL1JU6rRo7MuqoAKJ5Mu0oi6LtbJGIgOKlvOmsJZErN9bzGsUuHib(iQQ4szYl6SFsoaLV3njeWZpai(gyeGlsktQZUjfKbqCSPg9jGUmtev)qznr301oVcQar1JZilAK88dakAxJU64hnVIeI2WOqlNgDLW4l6kJF0ggfk6kHXx0(lI(4I2WOqrxjSODyLyrF88FaqrVSOngIIgjpmGgDL8Vqr7Vi6FJUsoRw0yqUynen(r)B0yCOkXG5UP4Sx0zFqgOKlvisGpIQkUuM8Io7NKdq57Dtcb88daIVbgrznr301oVcYccEkJEkcE4hKRUKEnli6IyjGYC1VjZm9oQKehqokhmCgp)hauM7cxC9JrSrPScrj4Hb0KW)cLP3rLK4aouxsVMfoRwca5I1qMEhvsId4qDj9AgWHQedM7MY07OssCaCrszsD2nPGmaIJn1Opb0LzEkVrksJZilA(nGIM)PCxtuPlOOx8iw0yqUynau2uJI2Fr0y6YmJ2WOqrFe(rJeig8YCLI21Opk6LfTKaGOvNDtkihN9Io7dYaLCPcrc8ru1TCxtuPli(gye(Xi2Ou(IyWlZvkZ8Vwfio6a4IKYK6SBsbzaehBQrFcOlZ8uehfNrw0vdn6JIwD2nPGOnmku0yuHrA0gtfOFo(Cu01i6kAUROrYZlIM)sETNaGOrRhDPEro)D0yqUynau2uJYXzVOZ(GmqjxQqKaFevbGCXAaOSPgXxPErsj1z3KcqWdFdmc1L0RzavyKMuQa9ZXNJY07OssCqDj9AgEErYa51EcaY07OssCqqOCWWz45fjdKx7jaiZitFEWP8CaCrszsD2nPGmaIJn1Opb0LzI4Od6ysjDtIH4hgz6ZdQ44IZilA(7OqlNgDLi6IyrJPmx9BYmA)frZ7ORM(xde9ch9jsxqrpF0kefngKlwdGOhn6beTHLPqrZbM)oAmixSgakBQrrVF08oA1z3KcYXzVOZ(GmqjxQqKaFevbGCXAaOSPgX3aJahQlPxZcIUiwcOmx9BYmtVJkjXb)yeBukJkDbLMpPquca5I1aiZ8VgcEFaCrszsD2nPGmaIJn1Opb0LzIG3XzKfnsEzrFXMLnA9OzR66SpFrZbOOXGCXAaOSPgf9IhXIgtxMz08G0Onmku08x(1O9BFEGgn3v06gD1JwD2nPa(I(iKg9ahnsM)g9aIMX9)83rVWWrJ89J2)6r7Ml3RrVWrRo7Muas5l6LfnVrA06gTPZlJ5CmkASTsrt8Ispy2pAdJcfns6t4nQJoYrRh9(rZ7OvNDtkiAKx9Onmku0NmkgsZXzVOZ(GmqjxQqKaFevbGCXAaOSPgX3aJapNnoQKYCakDXMLnA9eBvxN9pGC1L0Rz45fjdKx7jaitVJkjXbbHYbdNHNxKmqETNaGmJm95bNYdU4QUKEnBG8R9nDGsSm9oQKehaxKuMuNDtkidG4ytn6taDzMNIO64IRFmInkLNNWBuhDKJwptVJkjXbuoy4mOUj6kbPfojixHYCxhaxKuMuNDtkidG4ytn6taDzMNIG347hJyJszuPlO08jfIsaixSgaz6DujjqAC2l6SpiduYLkejWhrvaio2uJ(eqxMjFdmcWfjLj1z3KcQabVJZErN9bzGsUuHib(iQca5I1aqztnYIbUOI1OJooESQvTwa]] )


end
