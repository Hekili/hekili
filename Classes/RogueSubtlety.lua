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


    spec:RegisterPack( "Subtlety", 20190728, [[daflKbqiOk9iirBsj6tkjvmkiPofKKvPKKEfuXSqv5wOkPDjPFjImmOkogQILjs5zOQY0er5AIOABIuX3eHIXjsLoNiuzDOQQAEqc3tPAFIG)HQeLoOiu1cvs8quLYefHCrLKkTruLWhrvvPgjQsu0jvsQALkPEjQQkmtuvvYnrvIStkj)evjQgQsszPIqPNcLPsj1vrvvSvLKWxrvv6SOkrH9sXFLyWsDyQwmepwutMWLr2mO(mKA0GCAfRgvvf9ArYSj62uQDd8BvgUs54kjrlhLNRQPt66OY2Hk9DkX4rvQoVsy9Iu18HQA)cB4XyTbt4kzSkn8WtIdpjM0s3kpPBA4bpPRbtxSrgSnpNYrtgmGBtgmmoevs6cd2MVqEUWyTb7powMmyqQU98)Ksc9OqCi18zN0p2CsxNdKzoSM0p25KmyiCJux9adIbt4kzSkn8WtIdpjM0s3kpPBA4bpjZG5Ck0XmyyJnVzWGgHGagedMG(SbdLrJXHOssxeDI9qZrXAugnKQBp)pPKqpkehsnF2j9JnN015azMdRj9JDoPynkJEnNCr0PLU8fDA4HNex08A08KU8FEs3yDSgLrZBqoan98)ynkJMxJoXleKiA(htov06fTGGDoPgTN15arlNxRXAugnVgDILSpCjr0QZqtAzGJoFaXOZbI(arZl5SuKiA4JfDIixHQXAugnVgDIxiir08NNIE1RK9xnyY513yTb7vYLkejmwBSIhJ1gmc4issywXGLzJsSXnyOoA1LeqRWdquSqEka9FLaoIKerJp(r)BKuwuNHM0V(qCSjfbkVEm7Orr08lAuf9YOrD0iCWW1xjxQqvUTOXh)Or4GHR46G5HQCBrJkdMN15agShYfNLxztkYOgRsZyTbJaoIKeMvmyz2OeBCdgchmC9H4ytkcu0JbCXv52IEz05Zg5kB3a0Vki4jpA0Oyp60myEwNdyWYUuw8SohOiNxnyY51cWTjdg8aMhYOgR4NXAdgbCejjmRyWYSrj24gSFJKYI6m0K(1hIJnPiq51Jzh9E0jl6LrNpBKRSDdq)Otyp6KzW8SohWGLDPS4zDoqroVAWKZRfGBtgm4bmpKrnwLmJ1gmc4issywXGLzJsSXny5Zg5kB3a0Vki4jpA0OypAEIMxJg1rRUKaAvq0gXkVYC1rt2vc4isse9YOrD0iCWWvCDW8qvUTOXh)O90tSrPQcrf4H9Ar4GmvjGJijr0lJgVrRUKaAv4SuLhYfNLkbCejjIEz04nA1LeqRphIsmyo0uLaoIKerVm6FJKYI6m0K(1hIJnPiq51JzhnkIMFrJQOrLbZZ6Cadw2LYIN15af58QbtoVwaUnzWGhW8qg1yvYnwBWiGJijHzfdwMnkXg3G5PNyJs1nIbFmxPkZbPIoH9Otl6Lr)BKuwuNHM0V(qCSjfbkVEm7OrXE0PzW8SohWGHwENnI0fKrnwLogRnyeWrKKWSIbZZ6Cad2d5IZYRSjfzWYSrj24gm1LeqRpLzKwukdbMvjhvjGJijr0lJwDjb0k8aeflKNcq)xjGJijr0lJwqiCWWv4bikwipfG(VYiBFaF0OiAEIEz0)gjLf1zOj9RpehBsrGYRhZo69Otl6LrRJnv0RigkAEnAgz7d4JoHOthdwErwsf1zOj9nwXJrnwLymwBWiGJijHzfdwMnkXg3GH3OvxsaTkiAJyLxzU6Oj7kbCejjIEz0E6j2Oufr6cQmGIcrLhYfNLVYCqQO3JMFrVm6FJKYI6m0K(1hIJnPiq51Jzh9E08ZG5zDoGb7HCXz5v2KImQXQ01yTbJaoIKeMvmyz2OeBCdgUoBCejv5EQSXMJn6Ic7uxNde9YOrD0QljGwHhGOyH8ua6)kbCejjIEz0ccHdgUcparXc5Pa0)vgz7d4JgfrZt04JF0QljGwTq(2bS9xjwLaoIKerVm6FJKYI6m0K(1hIJnPiq51Jzhnk2JozrJp(r7PNyJs1bq4oQJmYrxujGJijr0lJgHdgU(lSro5xo4IGCfQYTf9YO)nsklQZqt6xFio2KIaLxpMD0OypA(fnor7PNyJsvePlOYakkevEixCw(kbCejjIgvgmpRZbmypKlolVYMuKrnwL4mwBWiGJijHzfdwMnkXg3G9BKuwuNHM0p6e2JMFgmpRZbmypehBsrGYRhZ2OgR4bpgRnyEwNdyWEixCwELnPidgbCejjmRyuJAWO)jqMEJ1gR4XyTbZZ6Cadw(azcOmxjrbw62KbJaoIKeMvmQXQ0mwBW8SohWGHiVtuo4Icrfcq2lmyeWrKKWSIrnwXpJ1gmpRZbmyO5CMyCq5GlE6j2Pqgmc4issywXOgRsMXAdgbCejjmRyWYSrj24gmuh9VrszrDgAs)6dXXMueO86XSJoH9OtlA8XpAMpIcHlb0QleFDarNq0PdEIgvrVmA8gD(oP4SaQ)cBKt(LdUiixHQCBrVmA8gnchmC9xyJCYVCWfb5kuLBl6LrtaIHErvqWtE0OtypA(HhdMN15agm4lZ9KO4PNyJsfeYTnQXQKBS2GrahrscZkgSmBuInUb73iPSOodnPF9H4ytkcuE9y2rNWE0Pfn(4hnZhrHWLaA1fIVoGOti60bpgmpRZbmyBCSbEXaqxqK(Rg1yv6yS2GrahrscZkgSmBuInUbdHdgUYOCkj9Fb(yzQYTfn(4hnchmCLr5us6)c8XYujFCaLy1x9CQOrr08GhdMN15agmfIkCaKJdikWhltg1yvIXyTbZZ6CadgB22KuzaLFZZKbJaoIKeMvmQXQ01yTbJaoIKeMvmyz2OeBCdgchmCvoWeI8or9vpNkAuen)myEwNdyWSCmPaxAafg9hWbzYOgRsCgRnyeWrKKWSIblZgLyJBWiaXqViAueDYWt0lJgHdgU(lSro5xo4IGCfQYTzW8SohWGzt2hBr5GlsU8ikcg52VrnQbtqWoNunwBSIhJ1gmc4issywXGLzJsSXny4n6xjxQqKOYo0CKbZZ6CadwQjNYOgRsZyTbZZ6Cad2RKlvidgbCejjmRyuJv8ZyTbJaoIKeMvmyEwNdyWYUuw8SohOiNxnyY51cWTjdww8g1yvYmwBWiGJijHzfdwMnkXg3G9k5sfIevxknyEwNdyWyCGIN15af58QbtoVwaUnzWELCPcrcJASk5gRnyeWrKKWSIblZgLyJBW0XMk6vedfDcrNorVmAgz7d4JgfrJolQ2oVh9YOZNnYv2UbOF0jShDYIMxJg1rRJnfnkIMh8enQIEvJondMN15agmWGgsrKUGmQXQ0XyTbJaoIKeMvmy3Mb7j1G5zDoGbdxNnoIKmy46soYGTXMJn6Ic7uxNde9YO)nsklQZqt6xFio2KIaLxpMD0jShDAgmCDwb42KbJ7PYgBo2OlkStDDoGrnwLymwBWiGJijHzfdwMnkXg3GHRZghrsvUNkBS5yJUOWo115agmpRZbmyzxklEwNduKZRgm58Ab42Kb7vYLkujlEJASkDnwBWiGJijHzfd2TzWEsnyEwNdyWW1zJJijdgUUKJmyPL8OXjA1LeqR4oOpwLaoIKerVQrZVKhnorRUKaA12FLyLdU8qU4S8vc4isse9QgDAjpACIwDjb06d5IZsb(YCFLaoIKerVQrNgEIgNOvxsaT6spZgDrLaoIKerVQrZdEIgNO5j5rVQrJ6O)nsklQZqt6xFio2KIaLxpMD0jShn)IgvgmCDwb42Kb7vYLkurHy0dDsHrnwL4mwBWiGJijHzfdwMnkXg3GraIHErvqWtE0OrXE046SXrKu9vYLkurHy0dDsHbZZ6Cadw2LYIN15af58QbtoVwaUnzWELCPcvYI3OgR4bpgRnyeWrKKWSIblZgLyJBW80tSrPkyqdPFbxcGMCqMQeWrKKi6LrJ3Or4GHRGbnK(fCjaAYbzQYTf9YOZNnYv2UbOF0jShDArVmAuh9VrszrDgAs)6dXXMueO86XSJgfrNw04JF046SXrKuL7PYgBo2OlkStDDoq0Ok6LrJ6OZ3jfNfq9xyJCYVCWfb5kuLr2(a(OrXE08lA8XpAuhTNEInkvbdAi9l4sa0KdYuL5GurNWE0Pf9YOr4GHR)cBKt(LdUiixHQmY2hWhDcrZVOxgnEJ(vYLkejQUug9YOZ3jfNfq9HCXzPiCqMQziNHM(cmZZ6CaxgDc7rJNAIlAufnQmyEwNdyWadAifr6cYOgR4HhJ1gmc4issywXGLzJsSXny5Zg5kB3a0Vki4jpA0OypAEIgF8JwhBQOxrmu0OypAEIEz05Zg5kB3a0p6e2JMFgmpRZbmyzxklEwNduKZRgm58Ab42KbdEaZdzuJv8KMXAdgbCejjmRyWYSrj24gSFJKYI6m0K(1hIJnPiq51Jzh9E0jl6LrNpBKRSDdq)Otyp6KzW8SohWGLDPS4zDoqroVAWKZRfGBtgm4bmpKrnwXd)mwBWiGJijHzfdwMnkXg3GraIHErvqWtE0OrXE046SXrKu9vYLkurHy0dDsHbZZ6Cadw2LYIN15af58QbtoVwaUnzWq4gPWOgR4jzgRnyeWrKKWSIblZgLyJBWiaXqVOki4jpA0jShnpjpACIMaed9IkJqtadMN15agmNLDav0JXiGAuJv8KCJ1gmpRZbmyol7aQSXjFYGrahrscZkg1yfpPJXAdMN15agm5Ggs)c)tobABcOgmc4issywXOg1GTXO8zJ4QXAJv8yS2G5zDoGb7vYLkKbJaoIKeMvmQXQ0mwBWiGJijHzfdMN15agmBNLIef4JveKRqgSngLpBexlpLpG4ny8KCJASIFgRnyeWrKKWSIbZZ6Cad2d5IZsbr6c6nyBmkF2iUwEkFaXBW4XOgRsMXAdMN15agSTtNdyWiGJijHzfJASk5gRnyeWrKKWSIbd42KbZt)d5m)lWhqlhCz7SqmdMN15agmp9pKZ8VaFaTCWLTZcXmQrnyiCJuyS2yfpgRnyeWrKKWSIblZgLyJBW(nsklQZqt6hDc7rNw04enQJwDjb0kA5D2isxqvc4isse9YO90tSrP6gXGpMRuL5GurNWE0PfnQmyEwNdyWEio2KIaLxpMTrnwLMXAdMN15agm0Y7SrKUGmyeWrKKWSIrnwXpJ1gmpRZbmyiEo1RoIbJaoIKeMvmQrnyzXBS2yfpgRnyeWrKKWSIblZgLyJBWWB0iCWW1hYfNLIWbzQYTf9YOr4GHRpehBsrGIEmGlUk3w0lJgHdgU(qCSjfbk6XaU4QmY2hWhnk2JMF1KBW8SohWG9qU4SueoitgmUNkhmCbDwyW4XOgRsZyTbJaoIKeMvmyz2OeBCdgchmC9H4ytkcu0JbCXv52IEz0iCWW1hIJnPiqrpgWfxLr2(a(OrXE08RMCdMN15agSFHnYj)YbxeKRqgmUNkhmCbDwyW4XOgR4NXAdgbCejjmRyWYSrj24gm8g9RKlvisuDPm6LrloTcg0qkI0fuvNCQbG2G5zDoGbl7szXZ6CGICE1GjNxla3Mmy0)eitVrnwLmJ1gmc4issywXG5zDoGbB7ozHr)XXYKblZgLyJBWWB0QljGwFixCwkWxM7ReWrKKWGbFScG4D1yfpg1yvYnwBWiGJijHzfdwMnkXg3GraIHEr0jShD6GNOxgT40kyqdPisxqvDYPga6OxgD(oP4SaQ)cBKt(LdUiixHQCBrVm68DsXzbuFixCwkchKPAgYzOPp6e2JMhdMN15agShIJnPiqrpgWfNrnwLogRnyeWrKKWSIblZgLyJBWeNwbdAifr6cQQto1aqh9YOrD04nA1LeqRpehBsrGIEmGlUkbCejjIgF8JwDjb06d5IZsb(YCFLaoIKerJp(rNVtkolG6dXXMueOOhd4IRYiBFaF0jeDArJkdMN15agSFHnYj)YbxeKRqg1yvIXyTbJaoIKeMvmyEwNdyWSDwksuGpwrqUczWYSrj24gmMpIcHlb0QleFLBl6LrJ6OvNHM0Qo2urVIyOOrr05Zg5kB3a0Vki4jpA04JF04n6xjxQqKO6sz0lJoF2ixz7gG(vbbp5rJoH9OZBfBN3l)gberJkdwErwsf1zOj9nwXJrnwLUgRnyeWrKKWSIblZgLyJBWy(ikeUeqRUq81beDcrZp8enVgnZhrHWLaA1fIVk4yUohi6LrJ3OFLCPcrIQlLrVm68zJCLTBa6xfe8Khn6e2JoVvSDEV8BeqyW8SohWGz7SuKOaFSIGCfYOgRsCgRnyeWrKKWSIblZgLyJBWYNnYv2UbOFvqWtE0Otyp60IgNOFLCPcrIQlLgmpRZbmypKlolfePlO3OgR4bpgRnyeWrKKWSIblZgLyJBWuxsaT(qU4SuGVm3xjGJijr0lJwCAfmOHuePlOQo5udaD0lJgHdgU(lSro5xo4IGCfQYTzW8SohWG9qCSjfbk6XaU4mQXkE4XyTbJaoIKeMvmyz2OeBCdgEJgHdgU(qU4SueoitvUTOxgTo2urVIyOOrXE0jpACIwDjb06ZHOedMdnvjGJijr0lJgVrZ8ruiCjGwDH4RCBgmpRZbmypKlolfHdYKrnwXtAgRnyeWrKKWSIblZgLyJBWq4GHRiY7esUxRmYZA04JF0iCWW1FHnYj)YbxeKRqvUTOxgnQJgHdgU(qU4SuqKUG(k3w04JF057KIZcO(qU4SuqKUG(kJS9b8rJI9O5bprJkdMN15agSTtNdyuJv8WpJ1gmc4issywXGLzJsSXnyiCWW1FHnYj)YbxeKRqvUndMN15agme5DIcmhBHrnwXtYmwBWiGJijHzfdwMnkXg3GHWbdx)f2iN8lhCrqUcv52myEwNdyWqi2tSudaTrnwXtYnwBWiGJijHzfdwMnkXg3GHWbdx)f2iN8lhCrqUcv52myEwNdyWGhgHiVtyuJv8KogRnyeWrKKWSIblZgLyJBWq4GHR)cBKt(LdUiixHQCBgmpRZbmyoitVYCzj7sPrnwXtIXyTbJaoIKeMvmyEwNdyW2UCks)j9KOKp7no115afbH7KjdwMnkXg3GH3OFLCPcrIQlLrVmAXPvWGgsrKUGQ6Ktna0rVmA8gnchmC9xyJCYVCWfb5kuLBl6LrtaIHErvqWtE0OtypA(HhdgbdtzTaCBYGLxKLNYoWKlis)vJASIN01yTbJaoIKeMvmyEwNdyW80)qoZ)c8b0Ybx2oleZGLzJsSXny4nAeoy46d5IZsr4Gmv52IEz057KIZcO(lSro5xo4IGCfQYiBFaF0OiAEWJbd42KbZt)d5m)lWhqlhCz7SqmJASINeNXAdgbCejjmRyW8SohWG5peUoG(cZt)Xk5J5sdwMnkXg3Gjieoy4kZt)Xk5J5YIGq4GHRIZciA8XpAbHWbdxZhqWL1bxQmGufbHWbdx52IEz0QZqtAfICPcv3YA0OiA(Xt04JF04nAbHWbdxZhqWL1bxQmGufbHWbdx52IEz0OoAbHWbdxzE6pwjFmxweechmC9vpNk6e2JoTKhnVgnp4j6vnAbHWbdxrK3jkhCrHOcbi7fvUTOXh)OvNHM0Qo2urVIyOOrr0jdprJQOxgnchmC9xyJCYVCWfb5kuLr2(a(Oti601GbCBYG5peUoG(cZt)Xk5J5sJASkn8yS2GrahrscZkgmGBtgm7fc)lQlN32bgmpRZbmy2le(xuxoVTdmQXQ04XyTbJaoIKeMvmyz2OeBCdgchmC9xyJCYVCWfb5kuLBlA8XpADSPIEfXqrJIOtdpgmpRZbmyCpvgLSFJAud2RKlvOsw8gRnwXJXAdgbCejjmRyWUnd2tQbZZ6CadgUoBCejzWW1LCKblFNuCwa1hYfNLIWbzQMHCgA6lWmpRZbCz0jShnp1etYny46ScWTjd2djkkeJEOtkmQXQ0mwBWiGJijHzfdwMnkXg3GH3OX1zJJiP6djkkeJEOtkIEz05Zg5kB3a0Vki4jpA0jenprVmAbHWbdxHhGOyH8ua6)kJS9b8rJIO5XG5zDoGbdxhmpKrnwXpJ1gmc4issywXG5zDoGbB7ozHr)XXYKbJ4DL5f3(4aQblz4XGbFScG4D1yfpg1yvYmwBWiGJijHzfdwMnkXg3GraIHEr0jShDYWt0lJMaed9IQGGN8OrNWE08GNOxgnEJgxNnoIKQpKOOqm6HoPi6LrNpBKRSDdq)QGGN8OrNq08e9YOfechmCfEaIIfYtbO)RmY2hWhnkIMhdMN15agShYfNfBskmQXQKBS2GrahrscZkgSBZG9KAW8SohWGHRZghrsgmCDjhzWYNnYv2UbOFvqWtE0Otyp6KzWW1zfGBtgShsuYNnYv2UbOVrnwLogRnyeWrKKWSIb72mypPgmpRZbmy46SXrKKbdxxYrgS8zJCLTBa6xfe8KhnAuShnprJt0Pf9QgTNEInkvviQapSxlchKPkbCejjmyz2OeBCdgUoBCejv5EQSXMJn6Ic7uxNde9YOrD0QljGwbdAi9vxMIyvc4issen(4hT6scOvHZsvEixCwQeWrKKiAuzWW1zfGBtgShsuYNnYv2UbOVrnwLymwBWiGJijHzfdwMnkXg3GHRZghrs1hsuYNnYv2UbOF0lJg1rJ3OvxsaTkCwQYd5IZsLaoIKerJp(rloTcg0qkI0fuLr2(a(Otyp6KhnorRUKaA95quIbZHMQeWrKKiAuf9YOrD046SXrKu9HeffIrp0jfrJp(rJWbdx)f2iN8lhCrqUcvzKTpGp6e2JMNAArJp(r)BKuwuNHM0V(qCSjfbkVEm7Otyp6Kf9YOZ3jfNfq9xyJCYVCWfb5kuLr2(a(OtiAEWt0Ok6LrJ6O90tSrPkyqdPFbxcGMCqMQmhKkAuen)IgF8JgHdgUcg0q6xWLaOjhKPk3w0OYG5zDoGb7HCXzPiCqMmQXQ01yTbJaoIKeMvmyz2OeBCdgUoBCejvFirjF2ixz7gG(rVmADSPIEfXqrJIOZ3jfNfq9xyJCYVCWfb5kuLr2(a(OxgnEJM5JOq4saT6cXx52myEwNdyWEixCwkchKjJAudg8aMhYyTXkEmwBWiGJijHzfdg8XkaI3vJv8yW8SohWGTDNSWO)4yzYOgRsZyTbJaoIKeMvmyz2OeBCdgchmCfmOH0VGlbqtoitvUndMN15agmc35ZeZvYOgR4NXAdgbCejjmRyWYSrj24gmuhnEJwDjb0QWzPkpKlolvc4issen(4hnEJgHdgU(qU4SueoitvUTOrv0lJwhBQOxrmu08A0mY2hWhDcrNorVmAgz7d4JgfrRtovrhBk6vn60myEwNdyWadAifr6cYOgRsMXAdgbCejjmRyW8SohWGbg0qkI0fKblZgLyJBWWB046SXrKuL7PYgBo2OlkStDDoq0lJ(3iPSOodnPF9H4ytkcuE9y2rNWE0Pf9YOrD0E6j2OufmOH0VGlbqtoitvc4issen(4hnEJ2tpXgLQmAtozxha6Yd5IZYxjGJijr04JF0)gjLf1zOj9RpehBsrGYRhZoAEnApRdUurCAfmOHuePlOOtyp60IgvrVmA8gnchmC9HCXzPiCqMQCBrVmADSPIEfXqrNWE0Oo6KhnorJ6Otl6vn68zJCLTBa6hnQIgvrVmAgbZOhYrKKblVilPI6m0K(gR4XOgRsUXAdgbCejjmRyWYSrj24gmgz7d4JgfrNVtkolG6VWg5KF5GlcYvOkJS9b8rJt08GNOxgD(oP4SaQ)cBKt(LdUiixHQmY2hWhnk2Jo5rVmADSPIEfXqrZRrZiBFaF0jeD(oP4SaQ)cBKt(LdUiixHQmY2hWhnorNCdMN15agmWGgsrKUGmQXQ0XyTbJaoIKeMvmyz2OeBCdgchmC9xyJCYVCWfb5kuLBl6LrJ6OXB0QljGwfolv5HCXzPsahrsIOXh)Or4GHRpKlolfHdYuLBlAuzW8SohWG9uMrArPmeywLCKrnwLymwBWiGJijHzfdwMnkXg3G9BKuwuNHM0V(qCSjfbkVEm7Otyp60IgNOvxsaTkCwQYd5IZsLaoIKerJt0QljGwbdAi9vxMIyvc4issyW8SohWG9uMrArPmeywLCKrnwLUgRnyEwNdyWiCNptmxjdgbCejjmRyuJAudgUe7NdySkn8WtIdpjM04XGzXzGbG(nyRE7TJPKi60nApRZbIwoV(1yTbBJDWJKmyOmAmoevs6IOtShAokwJYOHuD75)jLe6rH4qQ5ZoPFS5KUohiZCynPFSZjfRrz0R5KlIoT0LVOtdp8K4IMxJMN0L)Zt6gRJ1OmAEdYbOPN)hRrz08A0jEHGerZ)yYPIwVOfeSZj1O9SohiA58AnwJYO51OtSK9HljIwDgAsldC05digDoq0hiAEjNLIerdFSOte5kunwJYO51Ot8cbjIM)8u0RELS)ASowJYOxD5DkZPKiAec(yu05ZgX1Ori0d4RrN4ZzAt)ObhGxHCMnmNmApRZb(OpGCrnwJYO9Soh4RBmkF2iUUdl9pvSgLr7zDoWx3yu(SrCfN9KCo02eqDDoqSgLr7zDoWx3yu(SrCfN9KGVteRrz0yaF7HonAMpIOr4GHjr0V66hncbFmk68zJ4A0ie6b8r7ar0BmIx3ovha6ONpAXbOASgLr7zDoWx3yu(SrCfN9KEGV9qNwE11pw7zDoWx3yu(SrCfN9KELCPcfR9Soh4RBmkF2iUIZEs2olfjkWhRiixH4BJr5ZgX1Yt5di(DEsES2Z6CGVUXO8zJ4ko7j9qU4SuqKUGE(2yu(SrCT8u(aIFNNyTN15aFDJr5ZgXvC2tA705aXApRZb(6gJYNnIR4SNe3tLrjB(aUnT7P)HCM)f4dOLdUSDwiwSowJYOxD5DkZPKiAcxITiADSPOvikApRhl65J2X1hPJiPASgLrNyPxjxQqrpWrVD)piskAudUOXLtciMJiPOjazp0h9aIoF2iUIQyTN15apo7jLAYP4BG3X7RKlvisuzhAokw7zDoWV)k5sfkwJYO5nikNkAElrF0Ugn8WEnw7zDoWJZEszxklEwNduKZR8bCBApl(ynkJoXYbIgMtkxe9Bz0me9rRx0kefnMsUuHir0j2tDDoq0Ogzr0IBaOJ(p(IE0OHpwM(O3Utoa0rpWrdofAaOJE(ODC9r6iscv1yTN15apo7jX4afpRZbkY5v(aUnT)k5sfIe8nW7VsUuHir1LYynkJoXVTjxeTvdAifr6ckAxJonCIM3wTOfCSbGoAfIIgEyVgnp4j6NYhq88fTdRelAfY1OtgorZBRw0dC0JgnX7BdJ(OTmk0aIwHOObeVRrZ)M3su0hl65JgCA0CBXApRZbEC2tcmOHuePli(g4DDSPIEfXqjKolzKTpGhfOZIQTZ7lZNnYv2UbOFc7jJxrTo2ek4bpOAvtlwJYO5LdKlIod5a0u0StDDoq0dC0wOOHCCPO3yZXgDrHDQRZbI(jnAhiI2MtQZMKIwDgAs)O52QXApRZbEC2tcxNnoIK4d420o3tLn2CSrxuyN66Ca(W1LC0(gBo2OlkStDDoWYFJKYI6m0K(1hIJnPiq51JzNWEAXAug9QXMJn6IOtSN66CaEzJM)fPRoF0OhCPO9OZmFlAh540OjaXqViA4JfTcrr)k5sfkAElrF0OgHBKcIf9RJugnJ(nkRrpkQQrZldUn(IE0OZoiAekAfY1O)XEts1yTN15apo7jLDPS4zDoqroVYhWTP9xjxQqLS45BG3X1zJJiPk3tLn2CSrxuyN66CGynkJM)8KiA9IwqWdGI2cebIwVO5Ek6xjxQqrZBj6J(yrJWnsbX(yTN15apo7jHRZghrs8bCBA)vYLkurHy0dDsbF46soApTKJJ6scOvCh0hRsahrsIvLFjhh1LeqR2(ReRCWLhYfNLVsahrsIvnTKJJ6scO1hYfNLc8L5(kbCejjw10WdoQljGwDPNzJUOsahrsIvLh8GdpjFvr9VrszrDgAs)6dXXMueO86XStyNFOkwJYO5Td8JGyrZ9daD0E0yk5sfkAElrrBbIarZipdna0rRqu0eGyOxeTcXOh6KIyTN15apo7jLDPS4zDoqroVYhWTP9xjxQqLS45BG3jaXqVOki4jpkk2X1zJJiP6RKlvOIcXOh6KIynkJ2QbnKU68rVkiaAYbzI)hTvdAifr6ckAec(yu0ylSro5hTRrlplrZBRw06fD(Srgafn5m5IOzemJEOOTmku0Ojvha6OvikAeoy4O52QrN4L)fT8SenVTArl4ydaD0ylSro5hncPwiceDICqM(OTmku0PHt0wTkQXApRZbEC2tcmOHuePli(g4Dp9eBuQcg0q6xWLaOjhKPkbCejjwIxeoy4kyqdPFbxcGMCqMQCBlZNnYv2UbOFc7PTe1)gjLf1zOj9RpehBsrGYRhZgfPHp(46SXrKuL7PYgBo2OlkStDDoaQwI68DsXzbu)f2iN8lhCrqUcvzKTpGhf78dF8rTNEInkvbdAi9l4sa0KdYuL5GujSN2seoy46VWg5KF5GlcYvOkJS9b8jWVL49vYLkejQUuUmFNuCwa1hYfNLIWbzQMHCgA6lWmpRZbCzc74PM4qfQI1OmAEXaMhkAxJoz4eTLrHoon6eHXx0jhNOTmku0jclAuFC6pck6xjxQqOkw7zDoWJZEszxklEwNduKZR8bCBAhEaZdX3aVNpBKRSDdq)QGGN8OOyNh8XxhBQOxrmek25zz(SrUY2na9tyNFXAugn)DuOOtew0U8VOHhW8qr7A0jdNOD0(aEnAI39SkxeDYIwDgAs)Or9XP)iOOFLCPcHQyTN15apo7jLDPS4zDoqroVYhWTPD4bmpeFd8(VrszrDgAs)6dXXMueO86XS3t2Y8zJCLTBa6NWEYI1OmA(Ztr7rJWnsbXI2cebIMrEgAaOJwHOOjaXqViAfIrp0jfXApRZbEC2tk7szXZ6CGICELpGBt7iCJuW3aVtaIHErvqWtEuuSJRZghrs1xjxQqffIrp0jfXAugn)RZc9A0BS5yJUi6beTlLrFWrRqu0j(vJ)v0iu25Ek6rJo7Cp9r7rZ)M3suS2Z6CGhN9KCw2burpgJakFd8obig6fvbbp5rtyNNKJdbig6fvgHMaXApRZbEC2tYzzhqLno5tXApRZbEC2tsoOH0VW)KtG2MaASowJYOxHBKcI9XApRZb(kc3if7pehBsrGYRhZMVbE)3iPSOodnPFc7PHdQvxsaTIwENnI0fuLaoIKel90tSrP6gXGpMRuL5GujSNgQI1EwNd8veUrkWzpj0Y7SrKUGI1EwNd8veUrkWzpjepN6vhjwhRrz082DsXzb8XAugn)5POtKdYu0hmmVIolIgHGpgfTcrrdpSxJgdIJnPiq0y6XSJgMD2rB9XaU4IoF20h9aQXApRZb(Aw87pKlolfHdYeFCpvoy4c6SyNh(g4D8IWbdxFixCwkchKPk32seoy46dXXMueOOhd4IRYTTeHdgU(qCSjfbk6XaU4QmY2hWJID(vtESgLrJA(dqs)hTlzKlwen3w0iu25EkAlu06DPIgdYfNLO5fxM7rv0Cpfn2cBKt(rFWW8k6SiAec(yu0kefn8WEnAmio2KIarJPhZoAy2zhT1hd4Il68ztF0dOgR9Soh4RzXJZEs)cBKt(LdUiixH4J7PYbdxqNf78W3aVJWbdxFio2KIaf9yaxCvUTLiCWW1hIJnPiqrpgWfxLr2(aEuSZVAYJ1EwNd81S4XzpPSlLfpRZbkY5v(aUnTt)tGm98nW749vYLkejQUuUuCAfmOHuePlOQo5udaDSgLrVA3jJg(yrB9XaU4IEJr8k2LOOTmku0yqjkAg5IfrBbIardonAghama0rJXlQXApRZb(Aw84SN02DYcJ(JJLj(Gpwbq8UUZdFd8oEvxsaT(qU4SuGVm3xjGJijrSgLrZFEkARpgWfx0BmkASlrrBbIarBHIgYXLIwHOOjaXqViAlqKcrSOHzND0B3jha6OTmk0XPrJXlI(yrZ)K71OrtaI5s5IAS2Z6CGVMfpo7j9qCSjfbk6XaU44BG3jaXqViH90bplfNwbdAifr6cQQto1aqVmFNuCwa1FHnYj)YbxeKRqvUTL57KIZcO(qU4Sueoit1mKZqtFc78eRrz08NNIgBHnYj)Opq057KIZciAu7WkXIgEyVgTvdAifr6ccvrZbK0)rBHI2zu0OVbGoA9IE72I26JbCXfTderlUObNgnKJlfngKlolrZlUm3xJ1EwNd81S4XzpPFHnYj)YbxeKRq8nW7ItRGbnKIiDbv1jNAaOxIA8QUKaA9H4ytkcu0JbCXvjGJijb(4RUKaA9HCXzPaFzUVsahrsc8XpFNuCwa1hIJnPiqrpgWfxLr2(a(esdvXAug9QhoAxi(ODgfn3gFr)GzJIwHOOpafTLrHIwEwOxJ2ARtunA(ZtrBbIarlwma0rd7VsSOvihenVTArli4jpA0hlAWPr)k5sfIerBzuOJtJ2blIM3wTAS2Z6CGVMfpo7jz7SuKOaFSIGCfIV8ISKkQZqt6VZdFd8oZhrHWLaA1fIVYTTe1QZqtAvhBQOxrmekYNnYv2UbOFvqWtEu8XhVVsUuHir1LYL5Zg5kB3a0Vki4jpAc75TITZ7LFJacufRrz0RE4Obx0Uq8rBzKYOfdfTLrHgq0kefnG4DnA(HNNVO5EkAEj4ef9bIg5(pAlJcDCA0oyr082QfTderdUOFLCPcvJ1EwNd81S4XzpjBNLIef4JveKRq8nW7mFefcxcOvxi(6asGF4Hxz(ikeUeqRUq8vbhZ15alX7RKlvisuDPCz(SrUY2na9RccEYJMWEERy78E53iGiw7zDoWxZIhN9KEixCwkisxqpFd8E(SrUY2na9RccEYJMWEA48k5sfIevxkJ1OmA(7OqrJXl4l6boAWPr7sg5IfrloaXx0CpfT1hd4IlAlJcfn2LOO52QXApRZb(Aw84SN0dXXMueOOhd4IJVbExDjb06d5IZsb(YCFLaoIKelfNwbdAifr6cQQto1aqVeHdgU(lSro5xo4IGCfQYTfR9Soh4RzXJZEspKlolfHdYeFd8oEr4GHRpKlolfHdYuLBBPo2urVIyiuSNCCuxsaT(CikXG5qtvc4issSeVmFefcxcOvxi(k3wS2Z6CGVMfpo7jTD6Ca(g4Deoy4kI8oHK71kJ8SIp(iCWW1FHnYj)YbxeKRqvUTLOgHdgU(qU4SuqKUG(k3g(4NVtkolG6d5IZsbr6c6RmY2hWJIDEWdQI1EwNd81S4Xzpje5DIcmhBbFd8ochmC9xyJCYVCWfb5kuLBlw7zDoWxZIhN9Kqi2tSudanFd8ochmC9xyJCYVCWfb5kuLBlw7zDoWxZIhN9KGhgHiVtW3aVJWbdx)f2iN8lhCrqUcv52I1EwNd81S4XzpjhKPxzUSKDPKVbEhHdgU(lSro5xo4IGCfQYTfR9Soh4RzXJZEsCpvgLS5JGHPSwaUnTNxKLNYoWKlis)v(g4D8(k5sfIevxkxkoTcg0qkI0fuvNCQbGEjEr4GHR)cBKt(LdUiixHQCBljaXqVOki4jpAc78dpXApRZb(Aw84SNe3tLrjB(aUnT7P)HCM)f4dOLdUSDwigFd8oEr4GHRpKlolfHdYuLBBz(oP4SaQ)cBKt(LdUiixHQmY2hWJcEWtSgLrVki2IOzhhAi5IOzCsk6doAfIZgzGhseTTRqF0iK8SW)JM)8u0Whl6vpi12jIoZgLVOpfIywMNI2YOqrJDjkAxJoTKJt0V65uF0hlAEsoorBzuOOD5FrVI8or0CB1yTN15aFnlEC2tI7PYOKnFa3M29hcxhqFH5P)yL8XCjFd8UGq4GHRmp9hRKpMllccHdgUkola8XxqiCWW18beCzDWLkdivrqiCWWvUTLQZqtAfICPcv3Ykk4hp4JpEfechmCnFabxwhCPYasveechmCLBBjQfechmCL5P)yL8XCzrqiCWW1x9CQe2tl58kp4zvfechmCfrENOCWffIkeGSxu52WhF1zOjTQJnv0RigcfjdpOAjchmC9xyJCYVCWfb5kuLr2(a(es3yTN15aFnlEC2tI7PYOKnFa3M2Txi8VOUCEBheRrz0jIGDoPgnSlLiEov0WhlAU3rKu0Js2p)pA(ZtrBzuOOXwyJCYp6do6erUcvJ1EwNd81S4XzpjUNkJs2pFd8ochmC9xyJCYVCWfb5kuLBdF81XMk6vedHI0WtSowJYOxD)Naz6J1EwNd8v6FcKPFpFGmbuMRKOalDBkw7zDoWxP)jqMEC2tcrENOCWffIkeGSxeR9Soh4R0)eitpo7jHMZzIXbLdU4PNyNcfR9Soh4R0)eitpo7jbFzUNefp9eBuQGqUnFd8oQ)nsklQZqt6xFio2KIaLxpMDc7PHp(mFefcxcOvxi(6asiDWdQwI38DsXzbu)f2iN8lhCrqUcv52wIxeoy46VWg5KF5GlcYvOk32scqm0lQccEYJMWo)WtS2Z6CGVs)tGm94SN0ghBGxma0feP)kFd8(VrszrDgAs)6dXXMueO86XStypn8XN5JOq4saT6cXxhqcPdEI1EwNd8v6FcKPhN9KuiQWbqooGOaFSmX3aVJWbdxzuoLK(VaFSmv52WhFeoy4kJYPK0)f4JLPs(4akXQV65uOGh8eR9Soh4R0)eitpo7jXMTnjvgq538mfR9Soh4R0)eitpo7jz5ysbU0akm6pGdYeFd8ochmCvoWeI8or9vpNcf8lw7zDoWxP)jqMEC2tYMSp2IYbxKC5ruemYTF(g4Dcqm0lqrYWZseoy46VWg5KF5GlcYvOk3wSowJYO5fdyEiI9XApRZb(k8aMhAF7ozHr)XXYeFWhRaiEx35jwJYOxDXD(mXCLIgY)OHg0q0RrVXMJn6IOTmku0wnOH0vNp6vbbqtoitrZTvJ1EwNd8v4bmpeo7jr4oFMyUs8nW7iCWWvWGgs)cUean5Gmv52I1OmA(heTfn3w0wnOHuePlOOh4Ohn65J2roonA9IMXbI(40A0j6IgCA0CpfTvReTGJna0rNihKj(IEGJwDjbuse9a0l6e5SurJb5IZsnw7zDoWxHhW8q4SNeyqdPisxq8nW7OgVQljGwfolv5HCXzPsahrsc8XhViCWW1hYfNLIWbzQYTHQL6ytf9kIH4vgz7d4tiDwYiBFapk0jNQOJnTQPfRrz08sCsDeNQdaD0hN(JGIoroitrFGOvNHM0pAfY1OTmsz0YbxkA4JfTcrrl4yUohi6doARg0qkI0feFrZiyg9qrl4ydaD0Boqq2tUgnVeNuhXPr7F0YdGoA)JonCIwDgAs)Ofx0GtJgYXLI2QbnKIiDbfn3w0wgfk6elTjNSRdaD0yqU4S8rJAoGK(p6fhx0qoUu0wnOH0vNp6vbbqtoitrR3HQAS2Z6CGVcpG5HWzpjWGgsrKUG4lVilPI6m0K(78W3aVJxCD24isQY9uzJnhB0ff2PUohy5VrszrDgAs)6dXXMueO86XStypTLO2tpXgLQGbnK(fCjaAYbzQsahrsc8XhVE6j2OuLrBYj76aqxEixCw(kbCejjWh)FJKYI6m0K(1hIJnPiq51JzZREwhCPI40kyqdPisxqjSNgQwIxeoy46d5IZsr4Gmv52wQJnv0RigkHDuNCCqDARA(SrUY2na9rfQwYiyg9qoIKI1Om6elbZOhkARg0qkI0fu0KZKlIEGJE0OTmsz0eVVnmkAbhBaOJgBHnYj)A0j6IwHCnAgbZOhk6boASlrrJM0pAg5IfrpGOvikAaX7A0j)RXApRZb(k8aMhcN9KadAifr6cIVbENr2(aEuKVtkolG6VWg5KF5GlcYvOkJS9b84WdEwMVtkolG6VWg5KF5GlcYvOkJS9b8Oyp5l1XMk6vedXRmY2hWNq(oP4SaQ)cBKt(LdUiixHQmY2hWJtYJ1OmAmkZinARPmeywLCu0co2aqhn2cBKt(1O5VJcfDICwQOXGCXzj6dixeTGJna0rJb5IZs0jYbzkAuZb0rgTcXOh6KIOhq0aI31OLdGqvnw7zDoWxHhW8q4SN0tzgPfLYqGzvYr8nW7iCWW1FHnYj)YbxeKRqvUTLOgVQljGwfolv5HCXzPsahrsc8XhHdgU(qU4SueoitvUnufRrz083rHIMahhAOOvNHM0pAxAXx8rZ9u0yu2Akh9bIM3sunw7zDoWxHhW8q4SN0tzgPfLYqGzvYr8nW7)gjLf1zOj9RpehBsrGYRhZoH90WrDjb0QWzPkpKlolvc4issGJ6scOvWGgsF1LPiwLaoIKeXApRZb(k8aMhcN9KiCNptmxPyDSgLrJPKlvOO5T7KIZc4J1OmAEzsYnIf9QWzJJiPyTN15aF9vYLkujl(DCD24isIpGBt7pKOOqm6HoPGpCDjhTNVtkolG6d5IZsr4GmvZqodn9fyMN15aUmHDEQjMKhRrz0Rchmpu0Caj9F0wOODgfTJCCA06fD23I(arNihKPOZqodn91O5LdKlI2cebIMxmar08xYtbO)JE(ODKJtJwVOzCGOpoTgR9Soh4RVsUuHkzXJZEs46G5H4BG3XlUoBCejvFirrHy0dDsXY8zJCLTBa6xfe8KhnbEwkieoy4k8aeflKNcq)xzKTpGhf8eRrz0R2DYOHpw0yqU4Sytsr04engKlolVYMuu0Caj9F0wOODgfTJCCA06fD23I(arNihKPOZqodn91O5LdKlI2cebIMxmar08xYtbO)JE(ODKJtJwVOzCGOpoTgR9Soh4RVsUuHkzXJZEsB3jlm6powM4d(yfaX76op8r8UY8IBFCaDpz4jw7zDoWxFLCPcvYIhN9KEixCwSjPGVbENaed9Ie2tgEwsaIHErvqWtE0e25bplXlUoBCejvFirrHy0dDsXY8zJCLTBa6xfe8KhnbEwkieoy4k8aeflKNcq)xzKTpGhf8eRrz082QfnJwLCdJSjGY)Joroitr7A0YZs082QfnYIOfeSZj1AS2Z6CGV(k5sfQKfpo7jHRZghrs8bCBA)HeL8zJCLTBa6ZhUUKJ2ZNnYv2UbOFvqWtE0e2twSgLrZBRw0mAvYnmYMak)p6e5Gmf9bKlIgHGpgfn8aMhIyF0dC0wOOHCCPOD7TOvxsa9J2bIO3yZXgDr0StDDoqnw7zDoWxFLCPcvYIhN9KW1zJJij(aUnT)qIs(SrUY2na95dxxYr75Zg5kB3a0Vki4jpkk25bN0wvp9eBuQQqubEyVweoitvc4issW3aVJRZghrsvUNkBS5yJUOWo115alrT6scOvWGgsF1LPiwLaoIKe4JV6scOvHZsvEixCwQeWrKKavXAugn)DuOOtKZsfngKlolrFa5IOtKdYu0wGiq0wnOHuePlOOTmsz0V6lIMBRgn)5POfCSbGoASf2iN8J(yr7ihUu0keJEOtkQrZF9rJg(yrB1QiAeoy4OTmku08ZQvrnw7zDoWxFLCPcvYIhN9KEixCwkchKj(g4DCD24isQ(qIs(SrUY2na9xIA8QUKaAv4SuLhYfNLkbCejjWhFXPvWGgsrKUGQmY2hWNWEYXrDjb06ZHOedMdnvjGJijbQwIACD24isQ(qIIcXOh6Kc8XhHdgU(lSro5xo4IGCfQYiBFaFc78utdF8)nsklQZqt6xFio2KIaLxpMDc7jBz(oP4SaQ)cBKt(LdUiixHQmY2hWNap4bvlrTNEInkvbdAi9l4sa0KdYuL5GuOGF4JpchmCfmOH0VGlbqtoitvUnufRrz0RWXarZiBFadaD0jYbz6JgHGpgfTcrrRodnPrlg6JEGJg7su0woWQJgncfnJCXIOhq06yt1yTN15aF9vYLkujlEC2t6HCXzPiCqM4BG3X1zJJiP6djk5Zg5kB3a0FPo2urVIyiuKVtkolG6VWg5KF5GlcYvOkJS9b8lXlZhrHWLaA1fIVYTfRJ1OmAmLCPcrIOtSN66CGynkJE1dhnMsUuHscxhmpu0oJIMBJVO5EkAmixCwELnPOO1lAecqWJgnm7SJwHOO38)hCPOroa3hTderZlgGiA(l5Pa0)8fnHlbIEGJ2cfTZOODnABN3JM3wTOrnm7SJwHOO3yu(SrCnAEj4eHQAS2Z6CGV(k5sfIe7pKlolVYMueFd8oQvxsaTcparXc5Pa0)vc4issGp()gjLf1zOj9RpehBsrGYRhZgf8dvlrnchmC9vYLkuLBdF8r4GHR46G5HQCBOkwJYO5fdyEOODnA(Ht082QfTLrHoon6eHfDsrNmCI2YOqrNiSOTmku0yqCSjfbI26JbCXfnchmC0CBrRx0oU3iI(pBkAEB1I2I)kf9pkNRZb(AS2Z6CGV(k5sfIe4SNu2LYIN15af58kFa3M2HhW8q8nW7iCWW1hIJnPiqrpgWfxLBBz(SrUY2na9RccEYJII90I1Om6eV8VOFhMIwVOHhW8qr7A0jdNO5TvlAlJcfnX7EwLlIozrRodnPFnAuJ52u0(h9XP)iOOFLCPcvrvS2Z6CGV(k5sfIe4SNu2LYIN15af58kFa3M2HhW8q8nW7)gjLf1zOj9RpehBsrGYRhZEpzlZNnYv2UbOFc7jlwJYO5fdyEOODn6KHt082QfTLrHoon6eHXx0jhNOTmku0jcJVODGi60jAlJcfDIWI2HvIf9QWbZdf9XI2AikAEXWEn6e5GmfTderdUOtKZsfngKlolrJt0GlAmoeLyWCOPyTN15aF9vYLkejWzpPSlLfpRZbkY5v(aUnTdpG5H4BG3ZNnYv2UbOFvqWtEuuSZdVIA1LeqRcI2iw5vMRoAYUsahrsILOgHdgUIRdMhQYTHp(E6j2OuvHOc8WETiCqMQeWrKKyjEvxsaTkCwQYd5IZsLaoIKelXR6scO1NdrjgmhAQsahrsIL)gjLf1zOj9RpehBsrGYRhZgf8dvOkwJYO5ppfn)B5D2isxqrF4sSOXGCXz5v2KII2bIOX0JzhTLrHIonCIE1ig8XCLI21Otl6JfTK(pA1zOj9RXApRZb(6RKlvisGZEsOL3zJiDbX3aV7PNyJs1nIbFmxPkZbPsypTL)gjLf1zOj9RpehBsrGYRhZgf7PfRrz0jEn60IwDgAs)OTmku0yuMrA0wtziWSk5OOtr0w0CBrZlgGiA(l5Pa0)rJSi68ISCaOJgdYfNLxztkQgR9Soh4RVsUuHibo7j9qU4S8kBsr8LxKLurDgAs)DE4BG3vxsaT(uMrArPmeywLCuLaoIKelvxsaTcparXc5Pa0)vc4issSuqiCWWv4bikwipfG(VYiBFapk4z5VrszrDgAs)6dXXMueO86XS3tBPo2urVIyiELr2(a(esNynkJM)ok0XPrNiI2iw0ykZvhnzhTderZVOtSoi1h9bh9ksxqrpGOvikAmixCw(Ohn65J2YXuOO5(bGoAmixCwELnPOOpq08lA1zOj9RXApRZb(6RKlvisGZEspKlolVYMueFd8oEvxsaTkiAJyLxzU6Oj7kbCejjw6PNyJsvePlOYakkevEixCw(kZbP253YFJKYI6m0K(1hIJnPiq51JzVZVynkJMxCSO3yZXgDr0StDDoaFrZ9u0yqU4S8kBsrrF4sSOX0JzhnpOkAlJcfn)LxkAhTpGxJMBlA9IozrRodnPpFrNgQIEGJMxWFJE(OzCaWaqh9bdhnQpq0oyr0U9Xb0Op4OvNHM0hv8f9XIMFOkA9I2259XEspfn2LOOjExjWphiAlJcf9Qhq4oQJmYrxe9bIMFrRodnPF0OozrBzuOOxzumuvJ1EwNd81xjxQqKaN9KEixCwELnPi(g4DCD24isQY9uzJnhB0ff2PUohyjQvxsaTcparXc5Pa0)vc4issSuqiCWWv4bikwipfG(VYiBFapk4bF8vxsaTAH8Tdy7VsSkbCejjw(BKuwuNHM0V(qCSjfbkVEmBuSNm8X3tpXgLQdGWDuhzKJUOsahrsILiCWW1FHnYj)YbxeKRqvUTL)gjLf1zOj9RpehBsrGYRhZgf78dhp9eBuQIiDbvgqrHOYd5IZYxjGJijbQI1EwNd81xjxQqKaN9KEio2KIaLxpMnFd8(VrszrDgAs)e25xS2Z6CGV(k5sfIe4SN0d5IZYRSjfzW(nkBSkT0HhJAuJba]] )


end
