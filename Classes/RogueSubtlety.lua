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


    spec:RegisterPack( "Subtlety", 20190712.2313, [[davmAbqiufEKsQ2KsYNePkmkOIofOsRsKQ6vqLMfQs3cQs2LO(Li0WOe1XGQAzIOEgufttjfxtKkBteKVHQOACqfuNdQGSorqzEGkUhOSprK)bvPeDqrQsluKYdrvKjkcCrrQI2iub(iQIsgjuLs6KkPKwPs0lrvuQzIQOWnHQuStuv(jQIIgQsk1sPerpfstfvvxLse2QskXxHQuDwOkLWEP4Vs1GLCyQwmepwktMWLr2mu(Ssz0GCAfRgQsPETiz2eDBk1Uv1VbgUs1XfbvlhLNRY0jDDuz7GQ(oL04PePZRewpuHMpLW(f2GVHFdQWvYWxYwgFCilZZXp5CY4b)0HFYguDXozq39wkFJmOVBtguuoevs6cd6UVqcCHHFd6b4ynYGcP6(LWsmXTrH4qYnGDI3yZjDDaFJ5yAI3y3s0GIWnsDT(gedQWvYWxYwgFCilZZXp5CY4b)1Ko8nOoNcbygu0XMNmOqJqqVbXGkORzqxpkuoevs6IOSKGnokwUEuqQUFjSetCBuioKCdyN4n2CsxhW3yoMM4n2TeJLRh1so5IOWpzEJkzlJpouu4vujJNeg(4jwglxpkEcY)n6syXY1JcVIk9keKikE2tlvukikbH5CsnkVPd4JsoNMJLRhfEfLLKSbWtIOuNTrAFWIQbEXOd4Jc8rH34SuKikmalQeqUcLJLRhfEfv6viiruwIJIATQK9LnOY50ZWVb9uYLkejm8B4dFd)gu6DejjmPzqBSrj24guCgL6s61m28IUvYt90Dz6DejjIYclI62jPSRoBJ0lFqCSjf99tbm7OGtu4jk4g1QOWzuiCyy5tjxQqzU9OSWIOq4WWYW7)CqzU9OGRb1B6aEd6b5cG1tztkYOg(s2WVbLEhrsctAg0gBuInUbTbSra9DW86Lfe20gnk4alk8JcVIcNrPUKEnliANy9tzU6BKDMEhrsIOwffoJcHddldV)ZbL52JYclIYXrInkLviQJnSt7c)BuMEhrsIOwffpIsDj9Aw4Su9dYfaRz6DejjIAvu8ik1L0R5Jdrjgg3gLP3rKKiQvrD7Ku2vNTr6Lpio2KI((PaMDuWjk8efCJcUguVPd4nOnxk7EthW3LZPgu5CA)DBYGIn)Cqg1WhEm8BqP3rKKWKMbTXgLyJBqDCKyJs5DIHbyUszM)PIkjyrLCuRI62jPSRoBJ0lFqCSjf99tbm7OGdSOs2G6nDaVbDtca2isxqg1W3Am8BqP3rKKWKMb1B6aEd6b5cG1tztkYG2yJsSXnOQlPxZh1yK2vQb9tcNJY07isse1QOuxsVMXMx0TsEQNUltVJijruRIsqiCyyzS5fDRKN6P7YmY2N)IcorHFuRI62jPSRoBJ0lFqCSjf99tbm7OGfvYrTkkDSPUc6IHIcVIIr2(8xujfvczqBlAsQRoBJ0ZWh(g1Wx6m8BqP3rKKWKMbTXgLyJBq5ruQlPxZcI2jw)uMR(gzNP3rKKiQvr54iXgLYisxq957ke1pixaSEzM)PIcwu4jQvrD7Ku2vNTr6Lpio2KI((PaMDuWIcpguVPd4nOhKlawpLnPiJA4lHm8BqP3rKKWKMbTXgLyJBqH3zJJiPm3r9D2ayJUOZaQRd4JAvu4mk1L0RzS5fDRKN6P7Y07isse1QOeechgwgBEr3k5PE6UmJS95VOGtu4hLfweL6s61SvY3bVTFkXY07isse1QOUDsk7QZ2i9YhehBsrF)uaZok4alQ1eLfweLJJeBukppb)OoYihDrMEhrsIOwffchgw(wyJaKxhG1fKRqzU9Owf1TtszxD2gPx(G4ytk67Ncy2rbhyrHNOWnkhhj2Ougr6cQpFxHO(b5cG1ltVJijruW1G6nDaVb9GCbW6PSjfzudF8Cd)gu6DejjmPzqBSrj24g0BNKYU6SnsVOscwu4XG6nDaVb9G4ytk67Ncy2g1WhoSHFdQ30b8g0dYfaRNYMuKbLEhrsctAg1Ogu6o6B0z43Wh(g(nOEthWBqBGVrVYCLeDmPBtgu6DejjmPzudFjB43G6nDaVbfrcaIoaRRquNEYEHbLEhrsctAg1WhEm8Bq9MoG3GUX5mX4FhG1DCKyafYGsVJijHjnJA4Bng(nO07issysZG2yJsSXnO4mQBNKYU6SnsV8bXXMu03pfWSJkjyrLCuwyrumFeDcE61SlexE(OskQeYYrb3OwffpIQbasbW6NVf2ia51byDb5kuMBpQvrXJOq4WWY3cBeG86aSUGCfkZTh1QOONyBlYccBAJgvsWIcpw2G6nDaVbfd04os0DCKyJsDeYTnQHV0z43GsVJijHjndAJnkXg3GE7Ku2vNTr6Lpio2KI((PaMDujblQKJYclII5JOtWtVMDH4YZhvsrLqw2G6nDaVbDNJnylMFRJi9tnQHVeYWVb1B6aEdQcrDUhbW9IogG1idk9oIKeM0mQHpEUHFdQ30b8gu2SVlP(89B3BKbLEhrsctAg1WhoSHFdk9oIKeM0mOn2OeBCdkchgwwoyeIeae5t9wQOGtu4XG6nDaVb1kGjfWtZ3z0bE)BKrn8Hdz43GsVJijHjndAJnkXg3GspX2wefCIAnwoQvrHWHHLVf2ia51byDb5kuMB3G6nDaVb1MSbSfDawxY1grxWi3(mQrnOccZ5KQHFdF4B43GsVJijHjndAJnkXg3GYJOoLCPcrImdSXrguVPd4nOPMwkJA4lzd)guVPd4nONsUuHmO07issysZOg(WJHFdk9oIKeM0mOEthWBqBUu29MoGVlNtnOY50(72KbTjoJA4Bng(nO07issysZG2yJsSXnONsUuHir2LsdQ30b8gug339MoGVlNtnOY50(72Kb9uYLkejmQHV0z43GsVJijHjndAJnkXg3GQJn1vqxmuujfvcf1QOyKTp)ffCIARjY2ULg1QOAaBeqFhmVErLeSOwtu4vu4mkDSPOGtu4B5OGBuPFujBq9MoG3G(ZgKIiDbzudFjKHFdk9oIKeM0mOGDd6rQb1B6aEdk8oBCejzqH3LCKbDNna2Ol6mG66a(Owf1TtszxD2gPx(G4ytk67Ncy2rLeSOs2GcVZ6VBtguUJ67SbWgDrNbuxhWBudF8Cd)gu6DejjmPzqBSrj24gu4D24iskZDuFNna2Ol6mG66aEdQ30b8g0MlLDVPd47Y5udQCoT)UnzqpLCPc1BIZOg(WHn8BqP3rKKWKMbfSBqpsnOEthWBqH3zJJijdk8UKJmOjNUOWnk1L0Rz4NnaltVJijruPFu4jDrHBuQlPxZ2(PeRdW6hKlawVm9oIKerL(rLC6Ic3OuxsVMpixaS2XanUltVJijruPFujB5OWnk1L0Rzx6n2OlY07issev6hf(wokCJc)0fv6hfoJ62jPSRoBJ0lFqCSjf99tbm7Oscwu4jk4AqH3z93Tjd6PKlvOUcXOdcifg1WhoKHFdk9oIKeM0mOn2OeBCdk9eBBrwqytB0OGdSOG3zJJiP8PKlvOUcXOdcifguVPd4nOnxk7EthW3LZPgu5CA)DBYGEk5sfQ3eNrn8HVLn8BqP3rKKWKMbTXgLyJBqDCKyJs5F2G0Rdp9BK)nktVJijruRI62jPSRoBJ0lFqCSjf99tbm7OGtujh1QOWzunaqkaw)8TWgbiVoaRlixHYmY2N)IcoWIcprzHfrHZOq4WWY3cBeG86aSUGCfkZTh1QO4ruNsUuHir2LYOwfLJJeBuk)ZgKED4PFJ8VrzM)PIkjyrHNOGBuWnQvrXJOq4WWY)SbPxhE63i)BuMBpQvr1a2iG(oyE9IkjyrLSb1B6aEd6pBqkI0fKrn8Hp(g(nO07issysZG2yJsSXnOnGncOVdMxVSGWM2OrbhyrHFuwyru6ytDf0fdffCGff(rTkQgWgb03bZRxujblk8yq9MoG3G2CPS7nDaFxoNAqLZP93Tjdk28ZbzudF4NSHFdk9oIKeM0mOn2OeBCd6TtszxD2gPx(G4ytk67Ncy2rblQ1e1QOAaBeqFhmVErLeSOwJb1B6aEdAZLYU30b8D5CQbvoN2F3MmOyZphKrn8HpEm8BqP3rKKWKMbTXgLyJBqPNyBlYccBAJgfCGff8oBCejLpLCPc1vigDqaPWG6nDaVbT5sz3B6a(UCo1GkNt7VBtgueUrkmQHp8xJHFdk9oIKeM0mOn2OeBCdk9eBBrwqytB0Oscwu4NUOWnk6j22ImJ2O3G6nDaVb1zn)PUcym6vJA4d)0z43G6nDaVb1zn)P(oN8idk9oIKeM0mQHp8tid)guVPd4nOYzdsVoEBoXMn9QbLEhrsctAg1Og0Dg1a2iUA43Wh(g(nOEthWBqpLCPczqP3rKKWKMrn8LSHFdk9oIKeM0mOEthWBqTDwks0XaSUGCfYGUZOgWgX1(rnWlodk(PZOg(WJHFdk9oIKeM0mOEthWBqpixaS2rKUGod6oJAaBex7h1aV4mO4BudFRXWVb1B6aEd6oqhWBqP3rKKWKMrnQbfB(5Gm8B4dFd)gu6DejjmPzqBSrj24gueomS8pBq61HN(nY)gL52nOEthWBqj4NRrmxjJA4lzd)gu6DejjmPzqBSrj24guCgfpIsDj9Aw4Su9dYfaRz6DejjIYclIIhrHWHHLpixaS2f(3Om3EuWnQvrPJn1vqxmuu4vumY2N)IkPOsOOwffJS95VOGtu60s11XMIk9JkzdQ30b8g0F2GuePliJA4dpg(nO07issysZG6nDaVb9Nnifr6cYG2yJsSXnO8ik4D24iskZDuFNna2Ol6mG66a(Owf1TtszxD2gPx(G4ytk67Ncy2rLeSOsoQvrHZOCCKyJs5F2G0Rdp9BK)nktVJijruwyru8ikhhj2OuMr7YP568B9dYfaRxMEhrsIOSWIOUDsk7QZ2i9YhehBsrF)uaZok8kkVPd8uxa08pBqkI0fuujblQKJcUrTkkEefchgw(GCbWAx4FJYC7rTkkDSPUc6IHIkjyrHZOsxu4gfoJk5Os)OAaBeqFhmVErb3OGBuRIIrym6GCejzqBlAsQRoBJ0ZWh(g1W3Am8BqP3rKKWKMbTXgLyJBqzKTp)ffCIQbasbW6NVf2ia51byDb5kuMr2(8xu4gf(woQvr1aaPay9Z3cBeG86aSUGCfkZiBF(lk4alQ0f1QO0XM6kOlgkk8kkgz7ZFrLuunaqkaw)8TWgbiVoaRlixHYmY2N)Ic3OsNb1B6aEd6pBqkI0fKrn8Lod)gu6DejjmPzqBSrj24gueomS8TWgbiVoaRlixHYC7rTkkCgfpIsDj9Aw4Su9dYfaRz6DejjIYclIcHddlFqUayTl8VrzU9OGRb1B6aEd6rngPDLAq)KW5iJA4lHm8BqP3rKKWKMbTXgLyJBqVDsk7QZ2i9YhehBsrF)uaZoQKGfvYrHBuQlPxZcNLQFqUayntVJijru4gL6s618pBq6PUmfXY07issyq9MoG3GEuJrAxPg0pjCoYOg(45g(nOEthWBqj4NRrmxjdk9oIKeM0mQrnOnXz43Wh(g(nO07issysZG2yJsSXnO8ikeomS8b5cG1UW)gL52JAvuiCyy5dIJnPOVRa27cqMBpQvrHWHHLpio2KI(UcyVlazgz7ZFrbhyrHNC6mOEthWBqpixaS2f(3idk3rDagwFRjmO4BudFjB43GsVJijHjndAJnkXg3GIWHHLpio2KI(UcyVlazU9Owffchgw(G4ytk67kG9UaKzKTp)ffCGffEYPZG6nDaVb9wyJaKxhG1fKRqguUJ6amS(wtyqX3Og(WJHFdk9oIKeM0mOn2OeBCdkpI6uYLkejYUug1QOean)ZgKIiDbL1PLA(ndQ30b8g0MlLDVPd47Y5udQCoT)UnzqP7OVrNrn8Tgd)gu6DejjmPzq9MoG3GUdaYoJoahRrg0gBuInUbLhrPUKEnFqUayTJbACxMEhrscdkgG1FYsvdF4BudFPZWVbLEhrsctAg0gBuInUbLEITTiQKGfvcz5OwfLaO5F2GuePlOSoTuZVf1QOAaGuaS(5BHncqEDawxqUcL52JAvunaqkaw)8b5cG1UW)gLBqoBJUOscwu4Bq9MoG3GEqCSjf9DfWExamQHVeYWVbLEhrsctAg0gBuInUbva08pBqkI0fuwNwQ53IAvu4mkEeL6s618bXXMu03va7DbitVJijruwyruQlPxZhKlaw7yGg3LP3rKKiklSiQgaifaRF(G4ytk67kG9UaKzKTp)fvsrLCuW1G6nDaVb9wyJaKxhG1fKRqg1Whp3WVbLEhrsctAguVPd4nO2olfj6yawxqUczqBSrj24guMpIobp9A2fIlZTh1QOWzuQZ2inRJn1vqxmuuWjQgWgb03bZRxwqytB0OSWIO4ruNsUuHir2LYOwfvdyJa67G51lliSPnAujblQ2E32T0(TtVik4AqBlAsQRoBJ0ZWh(g1WhoSHFdk9oIKeM0mOn2OeBCdkZhrNGNEn7cXLNpQKIcpwok8kkMpIobp9A2fIll4yUoGpQvrXJOoLCPcrISlLrTkQgWgb03bZRxwqytB0OscwuT9UTBP9BNEHb1B6aEdQTZsrIogG1fKRqg1WhoKHFdk9oIKeM0mOn2OeBCdAdyJa67G51lliSPnAujblQKJc3OoLCPcrISlLguVPd4nOhKlaw7isxqNrn8HVLn8BqP3rKKWKMbTXgLyJBqvxsVMpixaS2XanUltVJijruRIsa08pBqkI0fuwNwQ53IAvuiCyy5BHncqEDawxqUcL52nOEthWBqpio2KI(UcyVlag1Wh(4B43GsVJijHjndAJnkXg3GYJOq4WWYhKlaw7c)BuMBpQvrPJn1vqxmuuWbwuPlkCJsDj9A(4quIHXTrz6DejjIAvu8ikMpIobp9A2fIlZTBq9MoG3GEqUayTl8Vrg1Wh(jB43GsVJijHjndAJnkXg3GIWHHLrKaGqYDAMrEtJYclIcHddlFlSraYRdW6cYvOm3EuRIcNrHWHHLpixaS2rKUGUm3Euwyrunaqkaw)8b5cG1oI0f0LzKTp)ffCGff(wok4Aq9MoG3GUd0b8g1Wh(4XWVbLEhrsctAguVPd4nOW7SXrKuFEL(B0f9TzZHhi1o4AJu668BDg5nfWmOn2OeBCdkchgw(wyJaKxhG1fKRqzU9OSWIO0XM6kOlgkk4evYw2G(UnzqH3zJJiP(8k93Ol6BZMdpqQDW1gP01536mYBkGzudF4Vgd)gu6DejjmPzqBSrj24gueomS8TWgbiVoaRlixHYC7guVPd4nOCh1hLSpJA4d)0z43GsVJijHjndAJnkXg3GIWHHLVf2ia51byDb5kuMB3G6nDaVbfrcaIoghBHrn8HFcz43GsVJijHjndAJnkXg3GIWHHLVf2ia51byDb5kuMB3G6nDaVbfHyhXsn)Mrn8Hpp3WVbLEhrsctAg0gBuInUbfHddlFlSraYRdW6cYvOm3Ub1B6aEdk2WiejaimQHp8XHn8BqP3rKKWKMbTXgLyJBqr4WWY3cBeG86aSUGCfkZTBq9MoG3G6FJoL5YEZLsJAud6PKlvOEtCg(n8HVHFdk9oIKeM0mOGDd6rQb1B6aEdk8oBCejzqH3LCKbTbasbW6NpixaS2f(3OCdYzB01XyEthW7YOscwu4N55PZGcVZ6VBtg0ds0vigDqaPWOg(s2WVbLEhrsctAg0gBuInUbLhrbVZghrs5ds0vigDqaPiQvr1a2iG(oyE9YccBAJgvsrHFuRIsqiCyyzS5fDRKN6P7YmY2N)IcorHVb1B6aEdk8(phKrn8Hhd)gu6DejjmPzq9MoG3GUdaYoJoahRrguYsvM3DBa3Rg01yzdkgG1FYsvdF4BudFRXWVbLEhrsctAg0gBuInUbLEITTiQKGf1ASCuRIIEITTiliSPnAujblk8TCuRIIhrbVZghrs5ds0vigDqaPiQvr1a2iG(oyE9YccBAJgvsrHFuRIsqiCyyzS5fDRKN6P7YmY2N)IcorHVb1B6aEd6b5cGvBskmQHV0z43GsVJijHjndky3GEKAq9MoG3GcVZghrsgu4DjhzqBaBeqFhmVEzbHnTrJkjyrTgdk8oR)UnzqpirVbSra9DW86zudFjKHFdk9oIKeM0mOGDd6rQb1B6aEdk8oBCejzqH3LCKbTbSra9DW86Lfe20gnk4alk8Jc3OsoQ0pkhhj2OuwHOo2WoTl8Vrz6DejjmOn2OeBCdk8oBCejL5oQVZgaB0fDgqDDaFuRIcNrPUKEn)ZgKEQltrSm9oIKerzHfrPUKEnlCwQ(b5cG1m9oIKerbxdk8oR)UnzqpirVbSra9DW86zudF8Cd)gu6DejjmPzqBSrj24gu4D24iskFqIEdyJa67G51lQvrHZO4ruQlPxZcNLQFqUayntVJijruwyrucGM)zdsrKUGYmY2N)IkjyrLUOWnk1L0R5Jdrjgg3gLP3rKKik4g1QOWzuW7SXrKu(GeDfIrheqkIYclIcHddlFlSraYRdW6cYvOmJS95VOscwu4NtoklSiQBNKYU6SnsV8bXXMu03pfWSJkjyrTMOwfvdaKcG1pFlSraYRdW6cYvOmJS95VOskk8TCuWnQvrHZOCCKyJs5F2G0Rdp9BK)nkZ8pvuWjk8eLfwefchgw(Nni96Wt)g5FJYC7rbxdQ30b8g0dYfaRDH)nYOg(WHn8BqP3rKKWKMbTXgLyJBqH3zJJiP8bj6nGncOVdMxVOwfLo2uxbDXqrbNOAaGuaS(5BHncqEDawxqUcLzKTp)f1QO4rumFeDcE61SlexMB3G6nDaVb9GCbWAx4FJmQrnOiCJuy43Wh(g(nO07issysZG2yJsSXnO3ojLD1zBKErLeSOsokCJcNrPUKEnVjbaBePlOm9oIKerTkkhhj2OuENyyaMRuM5FQOscwujhfCnOEthWBqpio2KI((PaMTrn8LSHFdQ30b8g0njayJiDbzqP3rKKWKMrn8Hhd)guVPd4nOiEl1PoIbLEhrsctAg1Og1GcpXUb8g(s2Y4JdzzEo(jNTSLxJb1QZ(53od6A1EhWusefoCuEthWhLCo9YXsd6TtndFjNq4Bq3zaSrsg01JcLdrLKUikljyJJILRhfKQ7xclXe3gfIdj3a2jEJnN01b8nMJPjEJDlXy56rTKtUik8tM3Os2Y4JdffEfvY4jHHpEILXY1JING8FJUewSC9OWROsVcbjIIN90sfLcIsqyoNuJYB6a(OKZP5y56rHxrzjjBa8Kik1zBK2hSOAGxm6a(OaFu4nolfjIcdWIkbKRq5y56rHxrLEfcseLL4OOwRkzF5yzSC9OspTuQXPKikecdWOOAaBexJcH2M)YrLEBnAxVOEWJxqoZgJtgL30b8xuGxUihlxpkVPd4V8oJAaBexHHj9lvSC9O8MoG)Y7mQbSrCfxyj6CB20RUoGpwUEuEthWF5Dg1a2iUIlSeXaarSC9OqFF)GaAumFerHWHHrIOo11lkecdWOOAaBexJcH2M)IYFru7mcV2bQo)wuZfLa8uowUEuEthWF5Dg1a2iUIlSeV33piG2p11lw6nDa)L3zudyJ4kUWs8uYLkuS0B6a(lVZOgWgXvCHLOTZsrIogG1fKRq8UZOgWgX1(rnWloy4NUyP30b8xENrnGnIR4clXdYfaRDePlOJ3Dg1a2iU2pQbEXbd)yP30b8xENrnGnIR4clXDGoGpwglxpQ0tlLACkjIIGNylIshBkkfIIYBkGf1Cr5W7J0rKuowUEuws6uYLkuudwu7G7gejffoFquWZjFI5iskk6j7HUOMpQgWgXv4gl9MoG)WfwIPMwkEhmy84uYLkejYmWghfl9MoG)GDk5sfkwUEu8ee1sffpLGlkxJcByNgl9MoG)WfwInxk7EthW3LZP8(UnbRjUy56rzj5(OW4KYfrDwhTbrxukikfIIcvjxQqKikljqDDaFu4ezrucW8BrDaEJA0OWaSgDrTdaY53IAWI6bk08Brnxuo8(iDejb3CS0B6a(dxyjY4(U30b8D5CkVVBtWoLCPcrcEhmyNsUuHir2LYy56rLE33LlIIVzdsrKUGIY1Osg3O4P1okbhB(TOuikkSHDAu4B5OoQbEXXBuoMsSOuixJAn4gfpT2rnyrnAuKLUpm6IY6OqZhLcrr9KLQrXZINsquawuZf1d0O42JLEthWF4clXF2GuePliEhmy6ytDf0fdLucTIr2(8hC2AISTBPRAaBeqFhmVEjbBn4fo1XMGd(wgUPFYXY1JIN5lxevdY)nkkgqDDaFudwuwPOGC4PO2zdGn6IodOUoGpQJ0O8xeLnNuNDjfL6SnsVO42ZXsVPd4pCHLi8oBCejX772emUJ67SbWgDrNbuxhWZl8UKJGTZgaB0fDgqDDa)QBNKYU6SnsV8bXXMu03pfWStcwYXY1JATzdGn6IOSKa11b84TmkEgKMECrTnWtr5r1y(EuocGtJIEITTikmalkfII6uYLkuu8ucUOWjc3ifelQthPmkgD7utJAu4MJcVfC78g1Or18pkekkfY1OUXExs5yP30b8hUWsS5sz3B6a(UCoL33TjyNsUuH6nXX7GbdENnoIKYCh13zdGn6IodOUoGpwUEuwIJerPGOee28uuwHOpkfef3rrDk5sfkkEkbxuawuiCJuqSlw6nDa)HlSeH3zJJijEF3MGDk5sfQRqm6GasbVW7socwYPdx1L0Rz4NnaltVJijr6JN0HR6s61STFkX6aS(b5cG1ltVJijr6NC6WvDj9A(GCbWAhd04Um9oIKePFYwgx1L0Rzx6n2OlY07issK(4BzCXpDPpoVDsk7QZ2i9YhehBsrF)uaZojy4bUXY1JINa)ncIff3n)wuEuOk5sfkkEkbrzfI(OyK3GMFlkfIIIEITTikfIrheqkILEthWF4clXMlLDVPd47Y5uEF3MGDk5sfQ3ehVdgm6j22ISGWM2OWbg8oBCejLpLCPc1vigDqaPiwUEu8nBqA6Xf1AH(nY)gLWIIVzdsrKUGIcHWamkk0f2ia5fLRrjbwJINw7OuqunGnY8uuKZKlIIrym6GIY6OqrTrQo)wukeffchgwuC75OsVYdeLeynkEATJsWXMFlk0f2ia5ffGtVrqrLa)Buuwhfkk8efFRLCS0B6a(dxyj(ZgKIiDbX7GbZXrInkL)zdsVo80Vr(3Om9oIKeRUDsk7QZ2i9YhehBsrF)uaZgojVcNnaqkaw)8TWgbiVoaRlixHYmY2N)Gdm8yHf4eHddlFlSraYRdW6cYvOm3(kECk5sfIezxkx54iXgLY)SbPxhE63i)BuM5FQKGHh4c3v8aHddl)ZgKED4PFJ8VrzU9vnGncOVdMxVKGLCSC9OWbZphuuUg1AWnkRJcb40OsakVrLoCJY6OqrLa0OWjGtVrqrDk5sfcUXsVPd4pCHLyZLYU30b8D5CkVVBtWWMFoiEhmynGncOVdMxVSGWM2OWbg(wyHo2uxbDXqWbg(RAaBeqFhmVEjbdpXY1JcVpkuujankxEGOWMFoOOCnQ1GBu(Mp)PrrwQ3u5IOwtuQZ2i9IcNao9gbf1PKlvi4gl9MoG)WfwInxk7EthW3LZP8(UnbdB(5G4DWGD7Ku2vNTr6Lpio2KI((PaMnS1SQbSra9DW86LeS1elxpklXrr5rHWnsbXIYke9rXiVbn)wukeff9eBBrukeJoiGuel9MoG)WfwInxk7EthW3LZP8(UnbdHBKcEhmy0tSTfzbHnTrHdm4D24iskFk5sfQRqm6GasrSC9O4zaSsNg1oBaSrxe18r5szuaSOuikQ07AZZikeQ5Chf1Or1CUJUO8O4zXtjiw6nDa)HlSeDwZFQRagJEL3bdg9eBBrwqytB0KGHF6WLEITTiZOn6JLEthWF4clrN18N67CYJILEthWF4clr5SbPxhVnNyZMEnwglxpQ04gPGyxS0B6a(lJWnsbSdIJnPOVFkGzZ7Gb72jPSRoBJ0ljyjJlovxsVM3KaGnI0fuMEhrsIvoosSrP8oXWamxPmZ)ujblz4gl9MoG)YiCJuGlSe3KaGnI0fuS0B6a(lJWnsbUWseXBPo1rILXY1JINaaPay9Vy56rzjokQe4FJIcGHHxBnruiegGrrPquuyd70OqH4ytk6Jcvbm7OWya7O4hWExaIQbSPlQ5ZXsVPd4VCtCWoixaS2f(3iE5oQdWW6Bnbm85DWGXdeomS8b5cG1UW)gL52xHWHHLpio2KI(UcyVlazU9viCyy5dIJnPOVRa27cqMr2(8hCGHNC6ILRhfoTeVKUlkxYixSikU9OqOMZDuuwPOuaivuOqUaynkCaOXDWnkUJIcDHncqErbWWWRTMikecdWOOuikkSHDAuOqCSjf9rHQaMDuymGDu8dyVlar1a20f185yP30b8xUjoCHL4TWgbiVoaRlixH4L7OoadRV1eWWN3bdgchgw(G4ytk67kG9UaK52xHWHHLpio2KI(UcyVlazgz7ZFWbgEYPlw6nDa)LBIdxyj2CPS7nDaFxoNY772em6o6B0X7GbJhNsUuHir2LYvcGM)zdsrKUGY60sn)wSC9OwBaqgfgGff)a27cqu7mcVqbjikRJcffkucIIrUyruwHOpQhOrX4(F(TOqXb5yP30b8xUjoCHL4oai7m6aCSgXlgG1FYsvy4Z7GbJhQlPxZhKlaw7yGg3LP3rKKiwUEuwIJIIFa7DbiQDgffkibrzfI(OSsrb5WtrPquu0tSTfrzfIuiIffgdyh1oaiNFlkRJcb40OqXbrbyrH3M70O2ONyUuUihl9MoG)YnXHlSepio2KI(UcyVla8oyWONyBlscwcz5vcGM)zdsrKUGY60sn)2QgaifaRF(wyJaKxhG1fKRqzU9vnaqkaw)8b5cG1UW)gLBqoBJUKGHFSC9OSehff6cBeG8Ic8r1aaPay9JcNoMsSOWg2PrX3SbPisxqWnkUxs3fLvkkNrrTbMFlkfe1oypk(bS3fGO8xeLae1d0OGC4POqHCbWAu4aqJ7YXsVPd4VCtC4clXBHncqEDawxqUcX7Gbta08pBqkI0fuwNwQ53wHtEOUKEnFqCSjf9DfWExaY07issyHfQlPxZhKlaw7yGg3LP3rKKWclAaGuaS(5dIJnPOVRa27cqMr2(8xsjd3y56rTwXIYfIlkNrrXTZBu3p7uukeff4POSokuusGv60O4N)eKJYsCuuwHOpkXI53IcZpLyrPq(hfpT2rjiSPnAuawupqJ6uYLkejIY6Oqaonk)xefpT25yP30b8xUjoCHLOTZsrIogG1fKRq82w0KuxD2gPhm85DWGX8r0j4PxZUqCzU9v4uD2gPzDSPUc6IHGtdyJa67G51lliSPnQfwWJtjxQqKi7s5QgWgb03bZRxwqytB0KG1272UL2VD6fWnwUEuRvSOEquUqCrzDKYOedfL1rHMpkfII6jlvJcpw(4nkUJIcVblbrb(Oqa3fL1rHaCAu(VikEATJYFrupiQtjxQq5yP30b8xUjoCHLOTZsrIogG1fKRq8oyWy(i6e80RzxiU88jHhlJxmFeDcE61SlexwWXCDa)kECk5sfIezxkx1a2iG(oyE9YccBAJMeS2E32T0(TtViw6nDa)LBIdxyjEqUayTJiDbD8oyWAaBeqFhmVEzbHnTrtcwY4Ek5sfIezxkJLRhfEFuOOqXb8g1Gf1d0OCjJCXIOeGN4nkUJIIFa7DbikRJcffkibrXTNJLEthWF5M4WfwIhehBsrFxbS3faEhmyQlPxZhKlaw7yGg3LP3rKKyLaO5F2GuePlOSoTuZVTcHddlFlSraYRdW6cYvOm3ES0B6a(l3ehUWs8GCbWAx4FJ4DWGXdeomS8b5cG1UW)gL52xPJn1vqxmeCGLoCvxsVMpoeLyyCBuMEhrsIv8G5JOtWtVMDH4YC7XsVPd4VCtC4clXDGoGN3bdgchgwgrcacj3Pzg5n1clq4WWY3cBeG86aSUGCfkZTVcNiCyy5dYfaRDePlOlZTBHfnaqkaw)8b5cG1oI0f0LzKTp)bhy4Bz4glxpkCGlLZVffI3sfLcIsqyoNuJAuYokUZ3OewuwIJIY6OqrHUWgbiVOayrLaYvOCS0B6a(l3ehUWsK7O(OKnVVBtWG3zJJiP(8k93Ol6BZMdpqQDW1gP01536mYBkGX7GbdHddlFlSraYRdW6cYvOm3UfwOJn1vqxmeCs2YXsVPd4VCtC4clrUJ6Js2hVdgmeomS8TWgbiVoaRlixHYC7XsVPd4VCtC4clrejai6yCSf8oyWq4WWY3cBeG86aSUGCfkZThl9MoG)YnXHlSeri2rSuZVX7GbdHddlFlSraYRdW6cYvOm3ES0B6a(l3ehUWseByeIeae8oyWq4WWY3cBeG86aSUGCfkZThl9MoG)YnXHlSe9VrNYCzV5sjVdgmeomS8TWgbiVoaRlixHYC7XYy56rLEEh9n6ILEthWFz6o6B0bRb(g9kZvs0XKUnfl9MoG)Y0D03OdxyjIibarhG1viQtpzViw6nDa)LP7OVrhUWsCJZzIX)oaR74iXakuS0B6a(lt3rFJoCHLigOXDKO74iXgL6iKBZ7GbdN3ojLD1zBKE5dIJnPOVFkGzNeSKTWcMpIobp9A2fIlpFsjKLH7kE0aaPay9Z3cBeG86aSUGCfkZTVIhiCyy5BHncqEDawxqUcL52xrpX2wKfe20gnjy4XYXsVPd4VmDh9n6WfwI7CSbBX8BDePFkVdgSBNKYU6SnsV8bXXMu03pfWStcwYwybZhrNGNEn7cXLNpPeYYXsVPd4VmDh9n6WfwIke15Eea3l6yawJILEthWFz6o6B0HlSezZ(UK6Z3VDVrXsVPd4VmDh9n6WfwIwbmPaEA(oJoW7FJ4DWGHWHHLLdgHibar(uVLco4jw6nDa)LP7OVrhUWs0MSbSfDawxY1grxWi3(4DWGrpX2waN1y5viCyy5BHncqEDawxqUcL52JLXY1Jchm)Cqe7ILRhv6j8Z1iMRuuq(ff0SbrNg1oBaSrxeL1rHIIVzdstpUOwl0Vr(3OO42ZXsVPd4Vm28ZbbJGFUgXCL4DWGHWHHL)zdsVo80Vr(3Om3ESC9O4zt0EuC7rX3SbPisxqrnyrnAuZfLJa40OuqumUpkaNMJkbGOEGgf3rrXxArj4yZVfvc8Vr8g1GfL6s6vse18kiQe4SurHc5cG1CS0B6a(lJn)Cq4clXF2GuePliEhmy4KhQlPxZcNLQFqUayntVJijHfwWdeomS8b5cG1UW)gL52H7kDSPUc6IHWlgz7ZFjLqRyKTp)bhDAP66ytPFYXY1JcVHtQJaO68Brb40BeuujW)gff4JsD2gPxukKRrzDKYOKd8uuyawukefLGJ56a(OayrX3SbPisxq8gfJWy0bfLGJn)wu7(li7PLJcVHtQJaOr5xusWVfLFrLmUrPoBJ0lkbiQhOrb5WtrX3SbPisxqrXThL1rHIYss7YP568BrHc5cG1lkCY9s6UOwa4IcYHNIIVzdstpUOwl0Vr(3OOuaaU5yP30b8xgB(5GWfwI)SbPisxq82w0KuxD2gPhm85DWGXd4D24iskZDuFNna2Ol6mG66a(v3ojLD1zBKE5dIJnPOVFkGzNeSKxHthhj2Ou(Nni96Wt)g5FJY07issyHf8WXrInkLz0UCAUo)w)GCbW6LP3rKKWclUDsk7QZ2i9YhehBsrF)uaZgV8MoWtDbqZ)SbPisxqjblz4UIhiCyy5dYfaRDH)nkZTVshBQRGUyOKGHZ0Hloto9BaBeqFhmVEWfURyegJoihrsXY1JYssym6GIIVzdsrKUGIICMCrudwuJgL1rkJIS09Hrrj4yZVff6cBeG8YrLaqukKRrXimgDqrnyrHcsquBKErXixSiQ5JsHOOEYs1Os3LJLEthWFzS5Ndcxyj(ZgKIiDbX7GbJr2(8hCAaGuaS(5BHncqEDawxqUcLzKTp)Hl(wEvdaKcG1pFlSraYRdW6cYvOmJS95p4alDR0XM6kOlgcVyKTp)LudaKcG1pFlSraYRdW6cYvOmJS95pCtxSC9OqPgJ0O4NAq)KW5OOeCS53IcDHncqE5OW7JcfvcCwQOqHCbWAuGxUikbhB(TOqHCbWAujW)gffo5EDKrPqm6GasruZh1twQgLCEcU5yP30b8xgB(5GWfwIh1yK2vQb9tcNJ4DWGHWHHLVf2ia51byDb5kuMBFfo5H6s61SWzP6hKlawZ07issyHfiCyy5dYfaRDH)nkZTd3y56rH3hfkk6bCBqrPoBJ0lkxA1xCrXDuuOuJFQff4JINsqow6nDa)LXMFoiCHL4rngPDLAq)KW5iEhmy3ojLD1zBKE5dIJnPOVFkGzNeSKXvDj9Aw4Su9dYfaRz6DejjWvDj9A(Nni9uxMIyz6DejjILEthWFzS5NdcxyjsWpxJyUsXYy56rHQKlvOO4jaqkaw)lwUEu4TsYDIf1AXzJJiPyP30b8x(uYLkuVjoyW7SXrKeVVBtWoirxHy0bbKcEH3LCeSgaifaRF(GCbWAx4FJYniNTrxhJ5nDaVltcg(zEE6ILRh1AX)5GII7L0DrzLIYzuuocGtJsbr189OaFujW)gfvdYzB0LJIN5lxeLvi6JchmVik8o5PE6UOMlkhbWPrPGOyCFuaonhl9MoG)YNsUuH6nXHlSeH3)5G4DWGXd4D24iskFqIUcXOdcifRAaBeqFhmVEzbHnTrtc)vccHddlJnVOBL8upDxMr2(8hCWpwUEuRnaiJcdWIcfYfaR2KuefUrHc5cG1tztkkkUxs3fLvkkNrr5iaonkfevZ3Jc8rLa)BuuniNTrxokEMVCruwHOpkCW8IOW7KN6P7IAUOCeaNgLcIIX9rb40CS0B6a(lFk5sfQ3ehUWsChaKDgDaowJ4fdW6pzPkm85LSuL5D3gW9kS1y5yP30b8x(uYLkuVjoCHL4b5cGvBsk4DWGrpX2wKeS1y5v0tSTfzbHnTrtcg(wEfpG3zJJiP8bj6keJoiGuSQbSra9DW86Lfe20gnj8xjieomSm28IUvYt90Dzgz7ZFWb)y56rXtRDumkHZnmYMEnHfvc8Vrr5AusG1O4P1okKfrjimNtQ5yP30b8x(uYLkuVjoCHLi8oBCejX772eSds0BaBeqFhmVE8cVl5iynGncOVdMxVSGWM2OjbBnXY1JINw7OyucNByKn9AclQe4FJIc8YfrHqyagff28ZbrSlQblkRuuqo8uuU9EuQlPxVO8xe1oBaSrxefdOUoGphl9MoG)YNsUuH6nXHlSeH3zJJijEF3MGDqIEdyJa67G51Jx4DjhbRbSra9DW86Lfe20gfoWWh3KtFhhj2OuwHOo2WoTl8Vrz6Dejj4DWGbVZghrszUJ67SbWgDrNbuxhWVcNQlPxZ)SbPN6YueltVJijHfwOUKEnlCwQ(b5cG1m9oIKeWnwUEu49rHIkbolvuOqUaynkWlxevc8VrrzfI(O4B2GuePlOOSoszuN6lIIBphLL4OOeCS53IcDHncqErbyr5ia4POuigDqaPihfE3hnkmalk(wlrHWHHfL1rHIcp8TwYXsVPd4V8PKlvOEtC4clXdYfaRDH)nI3bdg8oBCejLpirVbSra9DW86TcN8qDj9Aw4Su9dYfaRz6DejjSWcbqZ)SbPisxqzgz7ZFjblD4QUKEnFCikXW42Om9oIKeWDfoH3zJJiP8bj6keJoiGuyHfiCyy5BHncqEDawxqUcLzKTp)Lem8ZjBHf3ojLD1zBKE5dIJnPOVFkGzNeS1SQbasbW6NVf2ia51byDb5kuMr2(8xs4Bz4UcNoosSrP8pBq61HN(nY)gLz(Nco4Xclq4WWY)SbPxhE63i)BuMBhUXY1Jkno2hfJS95NFlQe4FJUOqimaJIsHOOuNTrAuIHUOgSOqbjikRGp9qJcHIIrUyruZhLo2uow6nDa)LpLCPc1BIdxyjEqUayTl8Vr8oyWG3zJJiP8bj6nGncOVdMxVv6ytDf0fdbNgaifaRF(wyJaKxhG1fKRqzgz7ZFR4bZhrNGNEn7cXL52JLXY1JcvjxQqKikljqDDaFSC9OwRyrHQKlvOeH3)5GIYzuuC78gf3rrHc5cG1tztkkkfefc9e2OrHXa2rPquu7(Dd8uuiGN7IYFru4G5frH3jp1t3XBue80h1GfLvkkNrr5Au2ULgfpT2rHtmgWokfIIANrnGnIRrH3GLa4MJLEthWF5tjxQqKa2b5cG1tztkI3bdgovxsVMXMx0TsEQNUltVJijHfwC7Ku2vNTr6Lpio2KI((PaMnCWdCxHteomS8PKlvOm3UfwGWHHLH3)5GYC7WnwUEu4G5NdkkxJAn4gfpT2rzDuiaNgvcq5nQ0HBuwhfkQeGYBu(lIkHIY6OqrLa0OCmLyrTw8FoOOaSO4hIIchmStJkb(3OO8xe1dIkbolvuOqUaynkCJ6brHYHOedJBJILEthWF5tjxQqKaxyj2CPS7nDaFxoNY772emS5NdI3bdwdyJa67G51lliSPnkCGHpEHt1L0Rzbr7eRFkZvFJSZ07issScNiCyyz49FoOm3Ufw44iXgLYke1Xg2PDH)nktVJijXkEOUKEnlCwQ(b5cG1m9oIKeR4H6s618XHOedJBJY07issS62jPSRoBJ0lFqCSjf99tbmB4Gh4c3y56rzjokkEwsaWgr6ckka8elkuixaSEkBsrr5VikufWSJY6OqrLmUrT2eddWCLIY1OsokalkjDxuQZ2i9YXsVPd4V8PKlvisGlSe3KaGnI0feVdgmhhj2OuENyyaMRuM5FQKGL8QBNKYU6SnsV8bXXMu03pfWSHdSKJLRhv6vJk5OuNTr6fL1rHIcLAmsJIFQb9tcNJIkfr7rXThfoyEru4DYt90DrHSiQ2IMC(TOqHCbW6PSjfLJLEthWF5tjxQqKaxyjEqUay9u2KI4TTOjPU6Snspy4Z7GbtDj9A(OgJ0UsnOFs4CuMEhrsIvQlPxZyZl6wjp1t3LP3rKKyLGq4WWYyZl6wjp1t3LzKTp)bh8xD7Ku2vNTr6Lpio2KI((PaMnSKxPJn1vqxmeEXiBF(lPekwUEu49rHaCAujGODIffQYC13i7O8xefEIYs6FQlkawuPjDbf18rPquuOqUay9IA0OMlkRaMcff3n)wuOqUay9u2KIIc8rHNOuNTr6LJLEthWF5tjxQqKaxyjEqUay9u2KI4DWGXd1L0Rzbr7eRFkZvFJSZ07issSYXrInkLrKUG6Z3viQFqUay9Ym)tbdpRUDsk7QZ2i9YhehBsrF)uaZggEILRhfoaWIANna2OlIIbuxhWZBuChffkKlawpLnPOOaWtSOqvaZok8HBuwhfkk8oEtu(Mp)PrXThLcIAnrPoBJ0J3OsgUrnyrHdW7rnxumU)NFlkagwu4e8r5)IOCBa3RrbWIsD2gPhC5nkalk8a3Ouqu2ULo2dosrHcsquKLQ0Fd4JY6OqrTwFc(rDKro6IOaFu4jk1zBKErHZ1eL1rHIkTrrHBow6nDa)LpLCPcrcCHL4b5cG1tztkI3bdg8oBCejL5oQVZgaB0fDgqDDa)kCQUKEnJnVOBL8upDxMEhrsIvccHddlJnVOBL8upDxMr2(8hCW3cluxsVMTs(o4T9tjwMEhrsIv3ojLD1zBKE5dIJnPOVFkGzdhyRXclCCKyJs55j4h1rg5OlY07issScHddlFlSraYRdW6cYvOm3(QBNKYU6SnsV8bXXMu03pfWSHdm8GRJJeBukJiDb1NVRqu)GCbW6LP3rKKaUXsVPd4V8PKlvisGlSepio2KI((PaMnVdgSBNKYU6SnsVKGHNyP30b8x(uYLkejWfwIhKlawpLnPiJAuJba]] )


end
