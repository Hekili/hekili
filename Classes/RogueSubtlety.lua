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
    spec:RegisterPack( "Subtlety", 20190625.0935, [[dav2wbqikrEKQuTjvrFsvkjJckXPGISkkv0RavMfLKBbQQ2Lu(fLIHrPshJsyzIu9mOOMMQuCnII2gLu8nkvW4uLsCoIc16OevMhOk3du2NiL)PkLuDqkvOfsPQhcLutKsQUiussBuvk1hHsszKuIsLtcQkSsrYlPeLYmHssCtqvr7KO0pHss1qbvLwkrH8uinvOuxLsu1wPeL8vkrXzPeLQ2lf)vQgSKdt1IH4XIAYO6YiBgQ(SQQrdYPvSAvPKYRvfMnHBlIDRYVbgUQYXHsILJYZvA6KUor2ou47evJNskDEvjRNOG5tP0(f2yHbBdk3vYiB621czSDTM0LzZUYym)wEJ1yq1xFKb9ZZp8FYGEEczqrLqubPVmOF(lbW5gSnOlqILjdkKQFRLZgB(hfscPLbj2StIKW1bCzMJR2Sts2gdkI0iu4JZGyq5Usgzt3UwiJTR1KUmB2vgJzR5nVfdQlPqaMbfDsWAdk0W50zqmOCAZg03JcvcrfK(kkze4xIIuVhfKQFRLZgB(hfscPLbj2StIKW1bCzMJR2Sts2Mi17rLs6OOsxMwfv621czCuWFu2vgB5WSmJurQ3JcRH87NwlxK69OG)OSJCoXJYY2KFeLcIIt4UKqJYZ6aUOeZQTi17rb)rjJOeagepk1z)K2h8OYGJp6aUOaxuWNo7bXJchWIY6KRqTi17rb)rzh5CIhLLFPOGpukzBguXS6AW2GUk5cfI4gSnYAHbBdkDoIG4g7nOz2OeBCdkwIsDbDAdFoExo5poA3gDoIG4rzRTrTFKq0vN9t62wij28GU(QawsuWlkmhfMI6zuyjkejC82QKluOM0xu2ABuis44nm8BwOM0xuyYG6zDaNbDHCoq(QS5bzuJSPBW2GsNJiiUXEdAMnkXg3GMbjiG(hyoDBCcFYJgf8GfLfrb)rHLOuxqN24e9rS(Qmx9FkPrNJiiEupJclrHiHJ3WWVzHAsFrzRTr5YaXgLAke1Xh2QDUFzQrNJiiEupJYsrPUGoTXD2J(c5CG8gDoIG4r9mklfL6c602kHOedx6NA05icIhfMIctgupRd4mOzxi6EwhW1fZQguXSA)8eYGIp3Sqg1ilMnyBqPZree3yVbnZgLyJBqDzGyJsTpIHdyUsnMFpIknyrLEupJA)iHORo7N0TTqsS5bD9vbSKOGhSOs3G6zDaNb9xaajicNtg1i7BmyBqPZree3yVb1Z6aod6c5CG8vzZdYGMzJsSXnOQlOtBlLzK2vkdDdwrIA05icIh1ZOuxqN2WNJ3Lt(JJ2TrNJiiEupJItis44n854D5K)4ODBmkXNBJcErzrupJA)iHORo7N0TTqsS5bD9vbSKOGfv6r9mkDsOUc68HIc(JIrj(CBuPfL1yqZVYcQRo7N01iRfg1iRmnyBqPZree3yVbnZgLyJBqTuuQlOtBCI(iwFvMR(pL0OZreepQNr5YaXgLAicNt956ke1xiNdKVnMFpIcwuyoQNrTFKq0vN9t62wij28GU(QawsuWIcZgupRd4mOlKZbYxLnpiJAK1AmyBqPZree3yVbnZgLyJBqXWzJJiOM0s9p2ayJ(QZaQRd4I6zuyjk1f0Pn854D5K)4ODB05icIh1ZO4eIeoEdFoExo5poA3gJs852OGxuweLT2gL6c60MCY)axIVkXA05icIh1ZO2psi6QZ(jDBlKeBEqxFvaljk4blQ3eLT2gLldeBuQnhHXOoYig9vJohrq8OEgfIeoEBFLGaeBhG35KRqnPVOEg1(rcrxD2pPBBHKyZd66RcyjrbpyrH5OGlkxgi2Oudr4CQpxxHO(c5CG8TrNJiiEuyYG6zDaNbDHCoq(QS5bzuJS2bd2gu6CebXn2BqZSrj24g09JeIU6SFs3Osdwuy2G6zDaNbDHKyZd66Rcyjg1i7BXGTb1Z6aod6c5CG8vzZdYGsNJiiUXEJAudkTlDzAnyBK1cd2gupRd4mOzWLPtzUs8oUWtidkDoIG4g7nQr20nyBq9SoGZGIiaaEhG3viQthL8YGsNJiiUXEJAKfZgSnOEwhWzq)LCgF8RdW7UmqmGczqPZree3yVrnY(gd2gupRd4mO4GS0s8UldeBuQJqEIbLohrqCJ9g1iRmnyBq9SoGZG(jXg8xZ93re(Qgu6CebXn2BuJSwJbBdQN1bCgufI6shcq64DCaltgu6CebXn2BuJS2bd2gupRd4mOS57tq9567NNjdkDoIG4g7nQr23IbBdQN1bCgu5aMGJbnxNrl48ltgu6CebXn2BuJSYyd2gu6CebXn2BqZSrj24gu6i2)ROGxuVXUgupRd4mOjucG9QdW7cP8W7Cg5jRrnQbLt4UKqnyBK1cd2gupRd4mORsUqHmO05icIBS3Ogzt3GTb1Z6aod6Jj)WGsNJiiUXEJAKfZgSnO05icIBS3G6zDaNbn7cr3Z6aUUyw1GkMv7NNqg0mFnQr23yW2GsNJiiUXEdAMnkXg3GUk5cfI4nximOEwhWzqzsx3Z6aUUyw1GkMv7NNqg0vjxOqe3OgzLPbBdkDoIG4g7nOz2OeBCdQ6SFsB6KqDf05dfvArznr9mkgL4ZTrbVO(Z8wIBTr9mQmibb0)aZPBuPblQ3ef8hfwIsNekk4fLf2nkmfLDgv6gupRd4mO38dPicNtg1iR1yW2GsNJiiUXEdk4ZGUKAq9SoGZGIHZghrqgumCHezq)ydGn6RodOUoGlQNrTFKq0vN9t62wij28GU(QawsuPblQ0nOy4S(5jKbvAP(hBaSrF1za11bCg1iRDWGTbLohrqCJ9g0mBuInUbfdNnoIGAsl1)ydGn6RodOUoGZG6zDaNbn7cr3Z6aUUyw1GkMv7NNqg0vjxOq9mFnQr23IbBdkDoIG4g7nOGpd6sQb1Z6aodkgoBCebzqXWfsKbnDzgfCrPUGoTHX8dyn6CebXJYoJcZYmk4IsDbDAlXxLyDaEFHCoq(2OZreepk7mQ0LzuWfL6c602c5CG8ooilTn6CebXJYoJkD7gfCrPUGoT5cpZg9vJohrq8OSZOSWUrbxuwiZOSZOWsu7hjeD1z)KUTfsInpORVkGLevAWIcZrHjdkgoRFEczqxLCHc1vigTqab3OgzLXgSnO05icIBS3GMzJsSXnO0rS)xnoHp5rJcEWIcdNnoIGARsUqH6keJwiGGBq9SoGZGMDHO7zDaxxmRAqfZQ9Ztid6QKluOEMVg1iRf21GTbLohrqCJ9g0mBuInUb1LbInk1U5hs3og09t(LPgDoIG4r9mQ9JeIU6SFs32cjXMh01xfWsIcErLEupJkdacoq(12xjiaX2b4Do5kuJrj(CBuWdwuyoQNrzPOqKWXB38dPBhd6(j)Yut6lQNrLbjiG(hyoDJknyrLUb1Z6aod6n)qkIW5KrnYAHfgSnO05icIBS3GMzJsSXnOzqccO)bMt3gNWN8Orbpyrzru2ABu6KqDf05dff8GfLfr9mQmibb0)aZPBuPblkmBq9SoGZGMDHO7zDaxxmRAqfZQ9Ztidk(CZczuJSwKUbBdkDoIG4g7nOz2OeBCd6(rcrxD2pPBBHKyZd66RcyjrblQ3e1ZOYGeeq)dmNUrLgSOEJb1Z6aodA2fIUN1bCDXSQbvmR2ppHmO4ZnlKrnYAbMnyBqPZree3yVbnZgLyJBqPJy)VACcFYJgf8GffgoBCeb1wLCHc1vigTqab3G6zDaNbn7cr3Z6aUUyw1GkMv7NNqguePrWnQrwlEJbBdkDoIG4g7nOz2OeBCdkDe7)vJt4tE0OsdwuwiZOGlk6i2)RgJ(PZG6zDaNb1zz)OUcym6uJAK1czAW2G6zDaNb1zz)O(NKyjdkDoIG4g7nQrwlSgd2gupRd4mOI5hs3(Bnj(FcDQbLohrqCJ9g1Og0pgLbjiUAW2iRfgSnO05icIBS3Ogzt3GTbLohrqCJ9g1ilMnyBqPZree3yVrnY(gd2gu6CebXn2BuJSY0GTb1Z6aod6QKluidkDoIG4g7nQrwRXGTbLohrqCJ9gupRd4mOjo7bX74awNtUczq)yugKG4AFPm44Rb1czAuJS2bd2gu6CebXn2Bq9SoGZGUqohiVJiCoTg0pgLbjiU2xkdo(AqTWOgzFlgSnOEwhWzq)a6aodkDoIG4g7nQrnOisJGBW2iRfgSnO05icIBS3GMzJsSXnO7hjeD1z)KUrLgSOspk4IclrPUGoT9laGeeHZPgDoIG4r9mkxgi2Ou7Jy4aMRuJ53JOsdwuPhfMmOEwhWzqxij28GU(QawIrnYMUbBdQN1bCg0FbaKGiCozqPZree3yVrnYIzd2gupRd4mOiE(XQoIbLohrqCJ9g1Og0mFnyBK1cd2gu6CebXn2BqZSrj24guejC8gIaa4cPvBmYZAu2ABuis44T9vccqSDaENtUc1K(I6zuyjkejC82c5CG8oIW502K(IYwBJkdacoq(1wiNdK3reoN2gJs852OGhSOSWUrHjdQN1bCg0pGoGZOgzt3GTbLohrqCJ9gupRd4mOy4SXreuFoLUD0x9)53Xai0oyZJq46C)Dg5zfWmOz2OeBCdkIeoEBFLGaeBhG35KRqnPVOS12O0jH6kOZhkk4fv621GEEczqXWzJJiO(CkD7OV6)ZVJbqODWMhHW15(7mYZkGzuJSy2GTbLohrqCJ9g0mBuInUbfrchVTVsqaITdW7CYvOM0Nb1Z6aodQ0s9rPK1OgzFJbBdkDoIG4g7nOz2OeBCdkIeoEBFLGaeBhG35KRqnPpdQN1bCguebaW74sSxg1iRmnyBqPZree3yVbnZgLyJBqrKWXB7ReeGy7a8oNCfQj9zq9SoGZGIqSLypM73OgzTgd2gu6CebXn2BqZSrj24guejC82(kbbi2oaVZjxHAsFgupRd4mO4dJqeaa3OgzTdgSnO05icIBS3GMzJsSXnOis44T9vccqSDaENtUc1K(mOEwhWzq9ltRYCrp7cHrnY(wmyBqPZree3yVbnZgLyJBqTuuis44TfY5a5DUFzQj9f1ZOqKWXBlKeBEqxxbSZ5GM0xupJcrchVTqsS5bDDfWoNdAmkXNBJcEWIcZnzAq9SoGZGUqohiVZ9ltguPL6aC8(FMBqTWOgzLXgSnO05icIBS3GMzJsSXnOis44TfsInpORRa25Cqt6lQNrHiHJ3wij28GUUcyNZbngL4ZTrbpyrH5MmnOEwhWzq3xjiaX2b4Do5kKbvAPoahV)N5gulmQrwlSRbBdkDoIG4g7nOz2OeBCdkhOTB(HueHZPMo5hZ9h1ZOWsuwkk1f0PTfsInpORRa25CqJohrq8OS12OuxqN2wiNdK3XbzPTrNJiiEu2ABu7hjeD1z)KUTfsInpORVkGLef8IcZrzRTrzPOYaGGdKFTfsInpORRa25Cqt6lkmzq9SoGZGUVsqaITdW7CYviJAK1clmyBqPZree3yVbnZgLyJBqz(W7eg0PnNZ3M0xupJclrPo7N0MojuxbD(qrbVOYGeeq)dmNUnoHp5rJYwBJYsrTk5cfI4nxiI6zuzqccO)bMt3gNWN8OrLgSOYF9e3A77hD8OWKb1Z6aodAIZEq8ooG15KRqg1iRfPBW2GsNJiiUXEdAMnkXg3GY8H3jmOtBoNVT5IkTOWSDJc(JI5dVtyqN2CoFBCjMRd4I6zuwkQvjxOqeV5crupJkdsqa9pWC624e(KhnQ0Gfv(RN4wBF)OJBq9SoGZGM4SheVJdyDo5kKrnYAbMnyBqPZree3yVbnZgLyJBqZGeeq)dmNUnoHp5rJknyrLEuWf1QKluiI3CHWG6zDaNbDHCoqEhr4CAnQrwlEJbBdkDoIG4g7nOz2OeBCd6(rcrxD2pPBuPblkmh1ZOSuuQlOtBlKZbY74GS02OZreepQNrXbA7MFifr4CQPt(XC)r9mklf1QKluiI3CHiQNrLbabhi)A7ReeGy7a8oNCfQj9f1ZOYaGGdKFTfY5a5DUFzQLHC2pTrLgSOSWG6zDaNbDHKyZd66kGDohyuJSwitd2gu6CebXn2BqZSrj24g09JeIU6SFs3OsdwuyoQNrPUGoTTqohiVJdYsBJohrq8OEgfhOTB(HueHZPMo5hZ9h1ZOqKWXB7ReeGy7a8oNCfQj9zq9SoGZGUqsS5bDDfWoNdmQrwlSgd2gu6CebXn2BqZSrj24gulffIeoEBHCoqEN7xMAsFr9mkDsOUc68HIcEWIsMrbxuQlOtBReIsmCPFQrNJiiEupJYsrX8H3jmOtBoNVnPpdQN1bCg0fY5a5DUFzYOgzTWoyW2GsNJiiUXEdQN1bCg0SleDpRd46IzvdQywTFEczqPDPltRrnQbDvYfkupZxd2gzTWGTbLohrqCJ9guWNbDj1G6zDaNbfdNnoIGmOy4cjYGMbabhi)AlKZbY7C)Yuld5SFA74mpRd4CruPblklA2bzAqXWz9Ztid6cX7keJwiGGBuJSPBW2GsNJiiUXEdAMnkXg3GAPOWWzJJiO2cX7keJwiGGh1ZOYGeeq)dmNUnoHp5rJkTOSiQNrXjejC8g(C8UCYFC0UngL4ZTrbVOSWG6zDaNbfd)MfYOgzXSbBdkDoIG4g7nOEwhWzq)aarNrlqILjdkzTkZ7Ecq6ud6BSRbfhW6hzTQrwlmQr23yW2GsNJiiUXEdAMnkXg3GshX(FfvAWI6n2nQNrrhX(F14e(KhnQ0GfLf2nQNrzPOWWzJJiO2cX7keJwiGGh1ZOYGeeq)dmNUnoHp5rJkTOSiQNrXjejC8g(C8UCYFC0UngL4ZTrbVOSWG6zDaNbDHCoqEcj4g1iRmnyBqPZree3yVbf8zqxsnOEwhWzqXWzJJiidkgUqImOzqccO)bMt3gNWN8OrLgSOEJbfdN1ppHmOleVNbjiG(hyoDnQrwRXGTbLohrqCJ9guWNbDj1G6zDaNbfdNnoIGmOy4cjYGMbjiG(hyoDBCcFYJgf8GfLfrbxuPhLDgLldeBuQPquhFyR25(LPgDoIG4g0mBuInUbfdNnoIGAsl1)ydGn6RodOUoGlQNrHLOuxqN2U5hsx1fpiwJohrq8OS12OuxqN24o7rFHCoqEJohrq8OWKbfdN1ppHmOleVNbjiG(hyoDnQrw7GbBdkDoIG4g7nOz2OeBCdkgoBCeb1wiEpdsqa9pWC6g1ZOWsuwkk1f0PnUZE0xiNdK3OZreepkBTnkoqB38dPicNtngL4ZTrLgSOKzuWfL6c602kHOedx6NA05icIhfMI6zuyjkmC24icQTq8UcXOfci4rzRTrHiHJ32xjiaX2b4Do5kuJrj(CBuPblklAPhLT2g1(rcrxD2pPBBHKyZd66RcyjrLgSOEtupJkdacoq(12xjiaX2b4Do5kuJrj(CBuPfLf2nkmzq9SoGZGUqohiVZ9ltg1i7BXGTbLohrqCJ9g0mBuInUbfdNnoIGAleVNbjiG(hyoDJ6zu6KqDf05dff8Ikdacoq(12xjiaX2b4Do5kuJrj(CBupJYsrX8H3jmOtBoNVnPpdQN1bCg0fY5a5DUFzYOg1GIp3SqgSnYAHbBdkDoIG4g7nOz2OeBCdQ6c602c5CG8ooilTn6CebXJ6zuis44TB(H0TJbD)KFzQj9f1ZO2psi6QZ(jDBlKeBEqxFvaljQ0Gfv6rbxuyok7mk1f0PTLYms7kLHUbRirn6CebXnOEwhWzqjmMntmxjJAKnDd2gu6CebXn2BqZSrj24guSeLLIsDbDAJ7Sh9fY5a5n6CebXJYwBJYsrHiHJ3wiNdK35(LPM0xuykQNrPo7N0MojuxbD(qrb)rXOeFUnQ0IYAI6zumkXNBJcErPt(rxNekk7mQ0nOEwhWzqV5hsreoNmQrwmBW2GsNJiiUXEdQN1bCg0B(HueHZjdAMnkXg3GAPOWWzJJiOM0s9p2ayJ(QZaQRd4I6zu7hjeD1z)KUTfsInpORVkGLevAWIk9OEgfwIYLbInk1U5hs3og09t(LPgDoIG4rzRTrzPOCzGyJsng9jMSRZ93xiNdKVn6CebXJYwBJA)iHORo7N0TTqsS5bD9vbSKOG)O8SoyqDoqB38dPicNtrLgSOspkmf1ZOSuuis44TfY5a5DUFzQj9f1ZO0jH6kOZhkQ0GffwIsMrbxuyjQ0JYoJkdsqa9pWC6gfMIctr9mkgHZOfYreKbn)klOU6SFsxJSwyuJSVXGTbLohrqCJ9g0mBuInUbLrj(CBuWlQmai4a5xBFLGaeBhG35KRqngL4ZTrbxuwy3OEgvgaeCG8RTVsqaITdW7CYvOgJs852OGhSOKzupJsD2pPnDsOUc68HIc(JIrj(CBuPfvgaeCG8RTVsqaITdW7CYvOgJs852OGlkzAq9SoGZGEZpKIiCozuJSY0GTbLohrqCJ9g0mBuInUbfrchVTVsqaITdW7CYvOM0xupJclrzPOuxqN24o7rFHCoqEJohrq8OS12OqKWXBlKZbY7C)Yut6lkmzq9SoGZGUuMrAxPm0nyfjYOgzTgd2gu6CebXn2BqZSrj24g09JeIU6SFs32cjXMh01xfWsIknyrLEuWfL6c60g3zp6lKZbYB05icIhfCrPUGoTDZpKUQlEqSgDoIG4gupRd4mOlLzK2vkdDdwrImQrw7GbBdQN1bCgucJzZeZvYGsNJiiUXEJAuJAqXGy7aoJSPBxlKX29nwyhAPNUfwJbvUZU5(xdk8rYhGPepQ3suEwhWfLywDBrkd6hdGpcYG(EuOsiQG0xrjJa)suK69OGu9BTC2yZ)OqsiTmiXMDsKeUoGlZCC1MDsY2ePEpQushfv6Y0QOs3UwiJJc(JYUYylhMLzKks9EuynKF)0A5IuVhf8hLDKZjEuw2M8JOuquCc3LeAuEwhWfLywTfPEpk4pkzeLaWG4rPo7N0(GhvgC8rhWff4Ic(0zpiEu4awuwNCfQfPEpk4pk7iNt8OS8lff8HsjBlsfPEpkSQwlLLuIhfcHdyuuzqcIRrHq)ZTTOSJ5m9PBuh4GFiNLGljIYZ6aUnkWjE1IuEwhWTTpgLbjiUcdx47JiLN1bCB7JrzqcIRWbZgx6pHo11bCrkpRd422hJYGeexHdMn4aaps9EuON)TqankMp8OqKWXjEuR66gfcHdyuuzqcIRrHq)ZTr5hpQpgb)FavN7pQzJIdoQfP8SoGBBFmkdsqCfoy2SN)TqaTVQRBKYZ6aUT9XOmibXv4GzZQKluOiLN1bCB7JrzqcIRWbZMeN9G4DCaRZjxHS6JrzqcIR9LYGJVWSqMrkpRd422hJYGeexHdMnlKZbY7icNtRvFmkdsqCTVugC8fMfrkpRd422hJYGeexHdMnFaDaxKks9EuyvTwklPepkcdI9kkDsOOuikkpRawuZgLJHpchrqTi17rjJOvjxOqrn4r9b2Dqeuuy5arHHK4iMJiOOOJsgAJAUOYGeexXuKYZ6aUf2QKluOiLN1bClCWS5XKFePEpkSgIYpIcRT(gLRrHpSvJuEwhWTWbZMSleDpRd46IzvRopHGL5BK69OKrsxu4scXROw5JMHOnkfeLcrrHQKluiIhLmcOUoGlkSG8kkoyU)OwGvrnAu4awM2O(aaXC)rn4rDafAU)OMnkhdFeoIGWuls5zDa3chmBysx3Z6aUUyw1QZtiyRsUqHiUvdoSvjxOqeV5crK69OSJFFIxrj78dPicNtr5AuPdxuyn8nkUeBU)Ouikk8HTAuwy3Owkdo(AvuoUsSOuixJ6nWffwdFJAWJA0OiR9By0gL8rHMlkfII6iRvJcRgwB9OaSOMnQdOrj9fP8SoGBHdMn38dPicNtwn4WuN9tAtNeQRGoFO0SMNmkXNBH3FM3sCR9zgKGa6FG50nnyVb(XIoje8SWUyYotps9Euy1pXROYq(9trXaQRd4IAWJsoffKJbf1hBaSrF1za11bCrTKgLF8OsKe68jOOuN9t6gL0xls5zDa3chmBWWzJJiiRopHGjTu)Jna2OV6mG66aoRWWfseSp2ayJ(QZaQRd4EUFKq0vN9t62wij28GU(QawsAWsps9EuWx2ayJ(kkzeqDDa3B9OWQq6B1g1)GbfLhvM5Fr5iajnk6i2)ROWbSOuikQvjxOqrH1wFJclisJGtSOwDeIOy0(rznQrXulkl7L(SkQrJk7xuiuukKRrTtYNGArkpRd4w4Gzt2fIUN1bCDXSQvNNqWwLCHc1Z81QbhggoBCeb1KwQ)XgaB0xDgqDDaxK69OS8lXJsbrXj85OOKdrxukikPLIAvYfkuuyT13OaSOqKgbNyBKYZ6aUfoy2GHZghrqwDEcbBvYfkuxHy0cbeCRWWfseS0LjCQlOtBym)awJohrqC7eZYeo1f0PTeFvI1b49fY5a5BJohrqC7mDzcN6c602c5CG8ooilTn6CebXTZ0TlCQlOtBUWZSrF1OZree3oTWUWzHmTtSSFKq0vN9t62wij28GU(QawsAWWmMIuVhfwdUD4elkPDU)O8OqvYfkuuyT1JsoeDrXipdn3FukeffDe7)vukeJwiGGhP8SoGBHdMnzxi6EwhW1fZQwDEcbBvYfkupZxRgCy0rS)xnoHp5rHhmmC24icQTk5cfQRqmAHacEK69OKD(H03Qnkll6(j)YKLlkzNFifr4CkkechWOOqFLGaeBuUgLaipkSg(gLcIkdsqMJIICM4vumcNrluuYhfkQFs15(JsHOOqKWXJs6RfP8SoGBHdMn38dPicNtwn4WCzGyJsTB(H0TJbD)KFzQrNJii(Z9JeIU6SFs32cjXMh01xfWsGx6pZaGGdKFT9vccqSDaENtUc1yuIp3cpyy(PLqKWXB38dPBhd6(j)Yut67zgKGa6FG50nnyPhPEpQ3EUzHIY1OEdCrjFuiGKgL1rTkkzcxuYhfkkRJgfwas6oCkQvjxOqyks5zDa3chmBYUq09SoGRlMvT68ecg(CZcz1Gdldsqa9pWC624e(KhfEWSWwB1jH6kOZhcEWS4zgKGa6FG50nnyyos9EuwMrHIY6Or5Ifef(CZcfLRr9g4IY)95wnkYA9SkEf1BIsD2pPBuybiP7WPOwLCHcHPiLN1bClCWSj7cr3Z6aUUyw1QZtiy4ZnlKvdoS9JeIU6SFs32cjXMh01xfWsG9MNzqccO)bMt30G9Mi17rz5xkkpkePrWjwuYHOlkg5zO5(JsHOOOJy)VIsHy0cbe8iLN1bClCWSj7cr3Z6aUUyw1QZtiyisJGB1GdJoI9)QXj8jpk8GHHZghrqTvjxOqDfIrleqWJuVhfwfGCA1O(ydGn6ROMlkxiIcGhLcrrzhHVyvIcHYU0srnAuzxAPnkpkSAyT1JuEwhWTWbZgNL9J6kGXOtTAWHrhX(F14e(Khnnywit4OJy)VAm6NUiLN1bClCWSXzz)O(NKyPiLN1bClCWSrm)q62FRjX)tOtJurQ3JYEPrWj2gP8SoGBBisJGdBHKyZd66Rcyjwn4W2psi6QZ(jDtdw6WHf1f0PTFbaKGiCo1OZree)PldeBuQ9rmCaZvQX87rAWshtrkpRd42gI0i4WbZMFbaKGiCofP8SoGBBisJGdhmBq88JvDKivK69OWAaqWbYVns5zDa32Y8f2hqhWz1GddrchVHiaaUqA1gJ8SARTis44T9vccqSDaENtUc1K(EIfejC82c5CG8oIW502K(S12mai4a5xBHCoqEhr4CABmkXNBHhmlSlMIuVh1B7cXC)rH45hrPGO4eUlj0OgLsIsA9FYYfLLFPOKpkuuOVsqaInkaEuwNCfQfP8SoGBBz(chmBKwQpkLy15jemmC24icQpNs3o6R()87yaeAhS5riCDU)oJ8Scywn4WqKWXB7ReeGy7a8oNCfQj9zRT6KqDf05dbV0TBKYZ6aUTL5lCWSrAP(OuYA1GddrchVTVsqaITdW7CYvOM0xKYZ6aUTL5lCWSbraa8oUe7LvdomejC82(kbbi2oaVZjxHAsFrkpRd42wMVWbZgeITe7XC)wn4WqKWXB7ReeGy7a8oNCfQj9fP8SoGBBz(chmBWhgHiaaUvdomejC82(kbbi2oaVZjxHAsFrkpRd42wMVWbZg)Y0Qmx0ZUqy1GddrchVTVsqaITdW7CYvOM0xK69OS8lfL19ltrbWXH))mpkechWOOuikk8HTAuOqsS5bDrHQawsu4mqsuydyNZbrLbj0g1CTiLN1bCBlZx4GzZc5CG8o3VmzL0sDaoE)pZHzHvdomlHiHJ3wiNdK35(LPM03tejC82cjXMh01va7CoOj99erchVTqsS5bDDfWoNdAmkXNBHhmm3KzK69OWIL)e0Ur5cg58xrj9ffcLDPLIsofLcapIcfY5a5r92GS0IPOKwkk0xjiaXgfahh()Z8OqiCaJIsHOOWh2QrHcjXMh0ffQcyjrHZajrHnGDohevgKqBuZ1IuEwhWTTmFHdMn7ReeGy7a8oNCfYkPL6aC8(FMdZcRgCyis44TfsInpORRa25Cqt67jIeoEBHKyZd66kGDoh0yuIp3cpyyUjZi17rz5xkk0xjiaXgf4Ikdacoq(ffwCCLyrHpSvJs25hsreoNWuusNG2nk5uuoJI6hm3FukiQpWxuydyNZbr5hpkoiQdOrb5yqrHc5CG8OEBqwABrkpRd42wMVWbZM9vccqSDaENtUcz1GdJd02n)qkIW5utN8J5(FIflPUGoTTqsS5bDDfWoNdA05icIBRTQlOtBlKZbY74GS02OZree3wB3psi6QZ(jDBlKeBEqxFvalbEy2wBTugaeCG8RTqsS5bDDfWoNdAsFyks9EuWh4r5C(gLZOOK(SkQ9MpkkfIIcCuuYhfkkbqoTAuyJT1Brz5xkk5q0ff)1C)rH7RsSOui)IcRHVrXj8jpAuawuhqJAvYfkeXJs(Oqajnk)EffwdFBrkpRd42wMVWbZMeN9G4DCaRZjxHSAWHX8H3jmOtBoNVnPVNyrD2pPnDsOUc68HGxgKGa6FG50TXj8jpQT2APvjxOqeV5cXZmibb0)aZPBJt4tE00GL)6jU123p64yks9EuWh4rDGOCoFJs(ierXhkk5Jcnxukef1rwRgfMT7Avuslff8jU1JcCrHa2nk5JcbK0O87vuyn8nk)4rDGOwLCHc1IuEwhWTTmFHdMnjo7bX74awNtUcz1GdJ5dVtyqN2CoFBZLgMTl8Z8H3jmOtBoNVnUeZ1bCpT0QKluiI3CH4zgKGa6FG50TXj8jpAAWYF9e3A77hD8iLN1bCBlZx4GzZc5CG8oIW50A1Gdldsqa9pWC624e(KhnnyPd3QKluiI3CHis9Eu2rnkmdxuYhfciPrHc5CG8OEBqwAJsAPOWgWoNdIs(OqrHcSEu(XJY6(LPOyKZF1IYYqrjFeIO(aFrPqGLIcHWbmkkfIIcFyRg1QawsuzqcTrnxls5zDa32Y8foy2SqsS5bDDfWoNdSAWHTFKq0vN9t6Mgmm)0sQlOtBlKZbY74GS02OZree)jhOTB(HueHZPMo5hZ9)0sRsUqHiEZfINzaqWbYV2(kbbi2oaVZjxHAsFpZaGGdKFTfY5a5DUFzQLHC2pTPbZIi17rzh1OWmCrjFuOOqHCoqEuVnilTrjTuuydyNZbrjFuOOqbwpkxWiN)kkPVwKYZ6aUTL5lCWSzHKyZd66kGDohy1GdB)iHORo7N0nnyy(P6c602c5CG8ooilTn6CebXFYbA7MFifr4CQPt(XC)prKWXB7ReeGy7a8oNCfQj9fP8SoGBBz(chmBwiNdK35(LjRgCywcrchVTqohiVZ9ltnPVN6KqDf05dbpyYeo1f0PTvcrjgU0p1OZree)PLy(W7eg0PnNZ3M0xKYZ6aUTL5lCWSj7cr3Z6aUUyw1QZtiy0U0LPnsfP8SoGBB0U0LPfoy2KbxMoL5kX74cpHIuEwhWTnAx6Y0chmBqeaaVdW7ke1PJsEfP8SoGBB0U0LPfoy28l5m(4xhG3DzGyafks5zDa32ODPltlCWSbhKLwI3DzGyJsDeYtIuEwhWTnAx6Y0chmB(Kyd(R5(7icF1iLN1bCBJ2LUmTWbZgfI6shcq64DCaltrkpRd42gTlDzAHdMnS57tq9567NNPiLN1bCBJ2LUmTWbZg5aMGJbnxNrl48ltrkpRd42gTlDzAHdMnjucG9QdW7cP8W7Cg5jRvdom6i2)l49g7gPIuVh1Bp3SqeBJuVhfwvmMntmxPOGMFiA1O(ydGn6ROCnQ0Hlk1z)KUrjFuOOqHCoqEuVnilTrHfzcxuYhfkkukZinkSPm0nyfjkQ5IY58rhWHPO8JhLSZpK(wTrzzr3p5xMIs6RfP8SoGBB4ZnlemcJzZeZvYQbhM6c602c5CG8ooilTn6CebXFIiHJ3U5hs3og09t(LPM03Z9JeIU6SFs32cjXMh01xfWssdw6WHz7uDbDABPmJ0UszOBWksuJohrq8i17rzzJOVOK(Is25hsreoNIAWJA0OMnkhbiPrPGOysxuajTfL1brDankPLIsw7JIlXM7pkR7xMSkQbpk1f0PepQ5uquw3zpIcfY5a5TiLN1bCBdFUzHGdMn38dPicNtwn4WWILuxqN24o7rFHCoqEJohrqCBT1sis44TfY5a5DUFzQj9HPNQZ(jTPtc1vqNpe8ZOeFUnnR5jJs85w4Pt(rxNeYotps9EuWNscD4avN7pkGKUdNIY6(LPOaxuQZ(jDJsHCnk5JqeLyWGIchWIsHOO4smxhWffapkzNFifr4CYQOyeoJwOO4sS5(J6ZpoLm5wuWNscD4ankFJsaU)O8nQ0Hlk1z)KUrXbrDankihdkkzNFifr4CkkPVOKpkuuYi6tmzxN7pkuiNdKVrHfPtq7g1lGuuqoguuYo)q6B1gLLfD)KFzkkfaWuls5zDa32WNBwi4GzZn)qkIW5Kv5xzb1vN9t6cZcRgCywcdNnoIGAsl1)ydGn6RodOUoG75(rcrxD2pPBBHKyZd66RcyjPbl9NyXLbInk1U5hs3og09t(LPgDoIG42ARLCzGyJsng9jMSRZ93xiNdKVn6CebXT129JeIU6SFs32cjXMh01xfWsGFpRdguNd02n)qkIW5uAWshtpTeIeoEBHCoqEN7xMAsFp1jH6kOZhknyyrMWHL0TZmibb0)aZPlMW0tgHZOfYreuK69OKreoJwOOKD(HueHZPOiNjEf1Gh1OrjFeIOiR9ByuuCj2C)rH(kbbi2wuwheLc5AumcNrluudEuOaRh1pPBumY5VIAUOuikQJSwnkzUTiLN1bCBdFUzHGdMn38dPicNtwn4WyuIp3cVmai4a5xBFLGaeBhG35KRqngL4ZTWzHDFMbabhi)A7ReeGy7a8oNCfQXOeFUfEWK5t1z)K20jH6kOZhc(zuIp3MwgaeCG8RTVsqaITdW7CYvOgJs85w4KzK69OqPmJ0OWMYq3GvKOO4sS5(Jc9vccqSTOSmJcfL1D2JOqHCoqEuGt8kkUeBU)OqHCoqEuw3VmffwKoDerPqmAHacEuZf1rwRgLyoctTiLN1bCBdFUzHGdMnlLzK2vkdDdwrISAWHHiHJ32xjiaX2b4Do5kut67jwSK6c60g3zp6lKZbYB05icIBRTis44TfY5a5DUFzQj9HPi17rzzgfkk6as)qrPo7N0nkxi3FTrjTuuOugBkhf4IcRTEls5zDa32WNBwi4GzZszgPDLYq3GvKiRgCy7hjeD1z)KUTfsInpORVkGLKgS0HtDbDAJ7Sh9fY5a5n6CebXHtDbDA7MFiDvx8Gyn6CebXJuEwhWTn85Mfcoy2qymBMyUsrQi17rHQKluOOWAaqWbYVns9Euw2rIpIfLLLZghrqrkpRd422QKluOEMVWWWzJJiiRopHGTq8UcXOfci4wHHlKiyzaqWbYV2c5CG8o3Vm1Yqo7N2ooZZ6aoxKgmlA2bzgPEpkll)MfkkPtq7gLCkkNrr5iajnkfev2)IcCrzD)YuuziN9tBlkS6N4vuYHOlQ3EoEuwgYFC0UrnBuocqsJsbrXKUOasAls5zDa32wLCHc1Z8foy2GHFZcz1GdZsy4SXreuBH4DfIrleqWFMbjiG(hyoDBCcFYJMMfp5eIeoEdFoExo5poA3gJs85w4zrK69OGVaGikCalkuiNdKNqcEuWffkKZbYxLnpOOKobTBuYPOCgfLJaK0Ouquz)lkWfL19ltrLHC2pTTOWQFIxrjhIUOE754rzzi)Xr7g1Sr5iajnkfeft6IciPTiLN1bCBBvYfkupZx4GzZhai6mAbsSmzfoG1pYAvywyfzTkZ7Ecq6uyVXUrkpRd422QKluOEMVWbZMfY5a5jKGB1GdJoI9)knyVXUpPJy)VACcFYJMgmlS7tlHHZghrqTfI3vigTqab)zgKGa6FG50TXj8jpAAw8Ktis44n854D5K)4ODBmkXNBHNfrQ3JcRHVrXiSI0WOe6ulxuw3VmfLRrjaYJcRHVrH8kkoH7scTfP8SoGBBRsUqH6z(chmBWWzJJiiRopHGTq8EgKGa6FG501kmCHebldsqa9pWC624e(KhnnyVjs9Euyn8nkgHvKggLqNA5IY6(LPOaN4vuieoGrrHp3SqeBJAWJsoffKJbfLN8fL6c60nk)4r9XgaB0xrXaQRd4ArkpRd422QKluOEMVWbZgmC24icYQZtiyleVNbjiG(hyoDTcdxirWYGeeq)dmNUnoHp5rHhmlGlD70LbInk1uiQJpSv7C)YuJohrqCRgCyy4SXreutAP(hBaSrF1za11bCpXI6c602n)q6QU4bXA05icIBRTQlOtBCN9OVqohiVrNJiioMIuVhLLzuOOSUZEefkKZbYJcCIxrzD)YuuYHOlkzNFifr4Ckk5Jqe1Q(ROK(Arz5xkkUeBU)OqFLGaeBuawuocadkkfIrleqWBrkpRd422QKluOEMVWbZMfY5a5DUFzYQbhggoBCeb1wiEpdsqa9pWC6(elwsDbDAJ7Sh9fY5a5n6CebXT1woqB38dPicNtngL4ZTPbtMWPUGoTTsikXWL(PgDoIG4y6jwWWzJJiO2cX7keJwiGGBRTis44T9vccqSDaENtUc1yuIp3MgmlAPBRT7hjeD1z)KUTfsInpORVkGLKgS38mdacoq(12xjiaX2b4Do5kuJrj(CBAwyxmfPEpk7LyxumkXNBU)OSUFzAJcHWbmkkfIIsD2pPrXhAJAWJcfy9OKdU3knkekkg58xrnxu6KqTiLN1bCBBvYfkupZx4GzZc5CG8o3Vmz1GdddNnoIGAleVNbjiG(hyoDFQtc1vqNpe8YaGGdKFT9vccqSDaENtUc1yuIp3(0smF4Dcd60MZ5Bt6lsfPIuVhfQsUqHiEuYiG66aUi17rbFGhfQsUqHSbd)MfkkNrrj9zvuslffkKZbYxLnpOOuqui0r4JgfodKeLcrr957oyqrHaoPnk)4r92ZXJYYq(JJ21QOimOlQbpk5uuoJIY1OsCRnkSg(gfwWzGKOuikQpgLbjiUgf8jU1Xuls5zDa32wLCHcrCylKZbYxLnpiRgCyyrDbDAdFoExo5poA3gDoIG42A7(rcrxD2pPBBHKyZd66RcyjWdZy6jwqKWXBRsUqHAsF2AlIeoEdd)MfQj9HPi17r92ZnluuUg1BGlkSg(gL8rHasAuwh1QOKjCrjFuOOSoQvr5hpkRjk5JcfL1rJYXvIfLLLFZcffGff2quuV9WwnkR7xMIYpEuhikR7ShrHc5CG8OGlQdefQeIsmCPFks5zDa32wLCHcrC4Gzt2fIUN1bCDXSQvNNqWWNBwiRgCyzqccO)bMt3gNWN8OWdMfWpwuxqN24e9rS(Qmx9FkPrNJii(tSGiHJ3WWVzHAsF2ARldeBuQPquhFyR25(LPgDoIG4pTK6c60g3zp6lKZbYB05icI)0sQlOtBReIsmCPFQrNJiioMWuK69OS8lffwnbaKGiCoffadIffkKZbYxLnpOO8JhfQcyjrjFuOOshUOGVedhWCLIY1OspkalkbTBuQZ(jDBrkpRd422QKluiIdhmB(faqcIW5Kvdomxgi2Ou7Jy4aMRuJ53J0GL(Z9JeIU6SFs32cjXMh01xfWsGhS0JuVhLDuJk9OuN9t6gL8rHIcLYmsJcBkdDdwrII6brFrj9f1Bphpkld5poA3OqEfv(vwm3FuOqohiFv28GArkpRd422QKluiIdhmBwiNdKVkBEqwLFLfuxD2pPlmlSAWHPUGoTTuMrAxPm0nyfjQrNJii(t1f0Pn854D5K)4ODB05icI)Ktis44n854D5K)4ODBmkXNBHNfp3psi6QZ(jDBlKeBEqxFvalbw6p1jH6kOZhc(zuIp3MM1ePEpklZOqajnkRt0hXIcvzU6)usu(XJcZrjJ87Xgfapk7foNIAUOuikkuiNdKVrnAuZgLCatHIsAN7pkuiNdKVkBEqrbUOWCuQZ(jDBrkpRd422QKluiIdhmBwiNdKVkBEqwn4WSK6c60gNOpI1xL5Q)tjn6CebXF6YaXgLAicNt956ke1xiNdKVnMFpGH5N7hjeD1z)KUTfsInpORVkGLadZrQ3J6TbSO(ydGn6ROya11bCwfL0srHc5CG8vzZdkkagelkufWsIYcmfL8rHIYYaFgL)7ZTAusFrPGOEtuQZ(jDTkQ0XuudEuVTLjQzJIjD3C)rbWXJclGlk)EfLNaKonkaEuQZ(jDXKvrbyrHzmfLcIkXT2jzKbkkuG1JISwLUDaxuYhfkk4JJWyuhzeJ(kkWffMJsD2pPBuy5nrjFuOOSFuum1IuEwhWTTvjxOqehoy2SqohiFv28GSAWHHHZghrqnPL6FSbWg9vNbuxhW9elQlOtB4ZX7Yj)Xr72OZree)jNqKWXB4ZX7Yj)Xr72yuIp3cplS1w1f0Pn5K)bUeFvI1OZree)5(rcrxD2pPBBHKyZd66RcyjWd2BS1wxgi2OuBocJrDKrm6RgDoIG4prKWXB7ReeGy7a8oNCfQj99C)iHORo7N0TTqsS5bD9vbSe4bdZW5YaXgLAicNt956ke1xiNdKVn6CebXXuKYZ6aUTTk5cfI4WbZMfsInpORVkGLy1GdB)iHORo7N0nnyyos5zDa32wLCHcrC4GzZc5CG8vzZdYGUFu2iB6wJfg1Ogd]] )


end
