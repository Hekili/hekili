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


    spec:RegisterPack( "Subtlety", 20190925, [[dav5KbqiOsEeePnjr9jvekJcIQtbrzvqe8kOQMfQk3cvPAxs6xsiddQuhdvXYKq9mkkMMkGRjbzBQi4BqeQXrrPCouLuRtfrmpvKUNk1(Ka)dIivheIqwOkOhIQuMOeuxeIizJqe1hPOK0iHisPtcreRuf1lPOKYmPOKQBIQK0orv1pPOKyOQiQLsrP6PqzQuuDvkkXwvrK(Qkc5SqePyVu6VImyPomvlgspwutMWLr2miFgcJguNwXQvrO61QqZMOBtHDd8BLgUk54OkjwokpxvtN01rLTdv8DkY4rvIZlrwVkqZhQY(f2YJ1ClMWvYYFX4MhEnU51fFGkpMTcH7Il2IPLUil2LNp6iilgWnilgghQkjTKf7Yljxxyn3I9lhltwmyvV(tsrfHyuyo0AEnk6hdoPRZcYmhsl6hJCrwmuUrQijalQft4kz5VyCZdVg386IpqLhZwHWDX8yXCofEzwmSXG3SyWJqqalQftqF2IH0OX4qvjPLI2SVi4O4msJgw1R)KuurigfMdTMxJI(XGt66SGmZH0I(XixuCgPrJrxkzGsSOlUq8fDX4MhEDCooJ0O5nyhGG(tsCgPrZ7rJejeKiAZAt(y06gTGGCoPgTN1zbrlNxRXzKgnVhTzNmwCir0QZqqAAGIoVaXOZcIEbrZR6SJKiAOLfDHjxHRXzKgnVhnsKqqIOnlpfnsIsgF1IjNxFR5wSxjxQWKWAULFESMBXiGJkjH9qlwMnkXg3IH8OvxsaTcnarYe5hb0)vc4OssenE4f9FrszsDgcs)6dZXMJei96YmI(0Ont0il6YrJ8Or5GGQVsUuHRCxrJhErJYbbvXXbZdx5UIgzwmpRZcSypSlwtVYMJKvT8xS1ClgbCujjShAXYSrj24wmuoiO6dZXMJeiPld4ITYDfD5OZRb6MU2bOFvqqtE0Op9o6ITyEwNfyXYUuM8SolijNxTyY51eWnilg0aMh2Qw(nJ1ClgbCujjShAXYSrj24wS)IKYK6meK(1hMJnhjq61Lze9D0hi6YrNxd0nDTdq)Ol4o6dyX8SolWILDPm5zDwqsoVAXKZRjGBqwmObmpSvT8FaR5wmc4Ossyp0ILzJsSXTy51aDtx7a0VkiOjpA0NEhnprZ7rJ8OvxsaTki6IyPxzU6iiJkbCujjIUC0ipAuoiOkooyE4k3v04Hx0(bj2OuvHPe0WEnjCqMQeWrLKi6YrJROvxsaTkC2X0d7I1uLaoQKerxoACfT6scO1NdvjgehcQsahvsIOlh9FrszsDgcs)6dZXMJei96YmI(0Ont0ilAKzX8SolWILDPm5zDwqsoVAXKZRjGBqwmObmpSvT8xiR5wmc4Ossyp0ILzJsSXTy(bj2Ou9IyqlZvQYCWXOl4o6IJUC0)fjLj1zii9RpmhBosG0RlZi6tVJUylMN1zbwmeYDnqLUGSQL)tWAUfJaoQKe2dTyEwNfyXEyxSMELnhjlwMnkXg3IPUKaA9PmJ0KszyWWRWrvc4OsseD5OvxsaTcnarYe5hb0)vc4OsseD5OfekheufAaIKjYpcO)RmYWhWh9PrZt0LJ(ViPmPodbPF9H5yZrcKEDzgrFhDXrxoADmOKUjXqrZ7rZidFaF0fe9jyXYLYskPodbPVLFESQLFKyR5wmc4Ossyp0ILzJsSXTy4kA1LeqRcIUiw6vMRocYOsahvsIOlhTFqInkvrLUGsdiPWu6HDXA6RmhCm67Ont0LJ(ViPmPodbPF9H5yZrcKEDzgrFhTzSyEwNfyXEyxSMELnhjRA53Szn3Irahvsc7HwSmBuInUfdhNnoQKQCpLUyZYgTuITQRZcIUC0ipA1LeqRqdqKmr(ra9FLaoQKerxoAbHYbbvHgGizI8Ja6)kJm8b8rFA08enE4fT6scOvtKFTad)vIvjGJkjr0LJ(ViPmPodbPF9H5yZrcKEDzgrF6D0hiA8WlA)GeBuQoacNrD0roAPkbCujjIUC0OCqq1VKb6k)0cLeKRWvUROlh9FrszsDgcs)6dZXMJei96YmI(07Ont04hTFqInkvrLUGsdiPWu6HDXA6ReWrLKiAKzX8SolWI9WUyn9kBosw1YpV2AUfJaoQKe2dTyz2OeBCl2FrszsDgcs)Ol4oAZyX8SolWI9WCS5ibsVUmdRA5NhCBn3I5zDwGf7HDXA6v2CKSyeWrLKWEOvTQfJ(Naz6TMB5NhR5wmc4Ossyp0ILzJsSXTyeGyikv1XGs6MmCEj6cIMNOlhnUIgLdcQ(Lmqx5NwOKGCfUYDfD5OrE04kAXQ18cYeqzUsIeK0nOekhdu1jFCaiIUC04kApRZcQ5fKjGYCLejiPBq1bKGKdcynA8WlAioPmXOmSZqqjDmOOpnAezr1W5LOrMfZZ6SalwEbzcOmxjrcs6gKvT8xS1ClgbCujjShAXYSrj24wS8UsXAcu)sgOR8tlusqUcx5UIgp8IwhdkPBsmu0NEhnp42I5zDwGfdvURiTqjfMseGmkzvl)MXAUfZZ6SalgcoNjghKwOKFqITkSfJaoQKe2dTQL)dyn3Irahvsc7HwSmBuInUfd5r)xKuMuNHG0V(WCS5ibsVUmJOl4o6IJgp8IM5Jir4qaT6cXxhq0fe9jG7Orw0LJgxrN3vkwtG6xYaDLFAHscYv4k3v0LJgxrJYbbv)sgOR8tlusqUcx5UIUC0eGyikvfe0Khn6cUJ2m42I5zDwGfdAZCpjs(bj2OucLCdRA5VqwZTyeWrLKWEOflZgLyJBX(lsktQZqq6xFyo2CKaPxxMr0fChDXrJhErZ8rKiCiGwDH4Rdi6cI(eWTfZZ6Sal2fhBGknaejuP)QvT8FcwZTyeWrLKWEOflZgLyJBXq5GGQmkFus)NGwwMQCxrJhErJYbbvzu(OK(pbTSmLYlhqjw9vpFm6tJMhCBX8SolWIPWuIdGUCarcAzzYQw(rITMBX8SolWIXMRljLgq6V8mzXiGJkjH9qRA53Szn3Irahvsc7HwSmBuInUfdLdcQkhicvURO(QNpg9PrBglMN1zbwmtltkWHgqIr)cCqMSQLFET1ClgbCujjShAXYSrj24wmcqmeLI(0OpaUJUC0OCqq1VKb6k)0cLeKRWvUllMN1zbwmdYyzLslusYLhrsWi34TQvTyccY5KQ1Cl)8yn3Irahvsc7HwSmBuInUfdxr)k5sfMev2IGJSyEwNfyXoo5Jw1YFXwZTyEwNfyXELCPcBXiGJkjH9qRA53mwZTyeWrLKWEOfZZ6Salw2LYKN1zbj58QftoVMaUbzXYI3Qw(pG1ClgbCujjShAXYSrj24wSxjxQWKO6sPfZZ6SalgJdK8SolijNxTyY51eWnil2RKlvysyvl)fYAUfJaoQKe2dTyz2OeBClMogus3KyOOli6ti6YrZidFaF0NgnISOA48s0LJoVgOB6AhG(rxWD0hiAEpAKhTogu0Ngnp4oAKfnsi6ITyEwNfyXadcyfv6cYQw(pbR5wmc4Ossyp0ITxwSNulMN1zbwmCC24OsYIHJl5il2fBw2OLsSvDDwq0LJ(ViPmPodbPF9H5yZrcKEDzgrxWD0fBXWXzjGBqwmUNsxSzzJwkXw11zbw1YpsS1ClgbCujjShAXYSrj24wmCC24OsQY9u6InlB0sj2QUolWI5zDwGfl7szYZ6SGKCE1IjNxta3GSyVsUuHtzXBvl)MnR5wmc4Ossyp0ITxwSNulMN1zbwmCC24OsYIHJl5ilwXfkA8JwDjb0kodILvjGJkjr0iHOntHIg)OvxsaTA4VsS0cLEyxSM(kbCujjIgjeDXfkA8JwDjb06d7I1ucAZCFLaoQKerJeIUyChn(rRUKaA1LEMnAPkbCujjIgjenp4oA8JMNcfnsiAKh9FrszsDgcs)6dZXMJei96YmIUG7Ont0iZIHJZsa3GSyVsUuHtkmJE4vkSQLFET1ClgbCujjShAXYSrj24wmcqmeLQccAYJg9P3rJJZghvs1xjxQWjfMrp8kfwmpRZcSyzxktEwNfKKZRwm58Ac4gKf7vYLkCklERA5NhCBn3Irahvsc7HwSmBuInUfZpiXgLQGbbS(jCiacYbzQsahvsIOlhnUIgLdcQcgeW6NWHaiihKPk3v0LJoVgOB6AhG(vbbn5rJUGO5j6YrJ8O)lsktQZqq6xFyo2CKaPxxMr0NgDXrJhErJJZghvsvUNsxSzzJwkXw11zbrJSOlhnYJoVRuSMa1VKb6k)0cLeKRWvgz4d4J(07Ont04Hx0ipA)GeBuQcgeW6NWHaiihKPkZbhJUG7Olo6YrJYbbv)sgOR8tlusqUcxzKHpGp6cI2mrxoACf9RKlvysuDPm6YrN3vkwtG6d7I1us4GmvZWodb9jiMN1zbUm6cUJg3vED0ilAKzX8SolWIbgeWkQ0fKvT8ZdpwZTyeWrLKWEOflZgLyJBXYRb6MU2bOFvqqtE0Op9oAEIgp8IwhdkPBsmu0NEhnprxo68AGUPRDa6hDb3rBglMN1zbwSSlLjpRZcsY5vlMCEnbCdYIbnG5HTQLFEk2AUfJaoQKe2dTyz2OeBCl2FrszsDgcs)6dZXMJei96YmI(o6deD5OZRb6MU2bOF0fCh9bSyEwNfyXYUuM8SolijNxTyY51eWnilg0aMh2Qw(5XmwZTyeWrLKWEOflZgLyJBXiaXquQkiOjpA0NEhnooBCujvFLCPcNuyg9WRuyX8SolWILDPm5zDwqsoVAXKZRjGBqwmuUrkSQLFEoG1ClgbCujjShAXYSrj24wmcqmeLQccAYJgDb3rZtHIg)OjaXquQYieeWI5zDwGfZzzhqjDzmcOw1YppfYAUfZZ6SalMZYoGsxCYNSyeWrLKWEOvT8ZZjyn3I5zDwGftoiG1pDIZjqyqa1Irahvsc7Hw1QwSlgLxduxTMB5NhR5wmpRZcSyVsUuHTyeWrLKWEOvT8xS1ClgbCujjShAX8SolWIz4SJKibTSKGCf2IDXO8AG6A6P8ceVfJNczvl)MXAUfJaoQKe2dTyEwNfyXEyxSMsOsxqVf7Ir51a110t5fiElgpw1Y)bSMBX8SolWIDT6SalgbCujjShAvl)fYAUfJaoQKe2dTya3GSy(bFyN5FcAbAAHsxRjIzX8SolWI5h8HDM)jOfOPfkDTMiMvTQfdAaZdBn3YppwZTyeWrLKWEOfdAzjaXlQLFESyEwNfyXU2vMy0VCSmzvl)fBn3Irahvsc7HwSmBuInUfdLdcQcgeW6NWHaiihKPk3LfZZ6SalgHZ8zI5kzvl)MXAUfJaoQKe2dTyz2OeBClgYJgxrRUKaAv4SJPh2fRPkbCujjIgp8IgxrJYbbvFyxSMschKPk3v0il6YrRJbL0njgkAEpAgz4d4JUGOpHOlhnJm8b8rFA06KpM0XGIgjeDXwmpRZcSyGbbSIkDbzvl)hWAUfJaoQKe2dTyEwNfyXadcyfv6cYILzJsSXTy4kACC24OsQY9u6InlB0sj2QUoli6Yr)xKuMuNHG0V(WCS5ibsVUmJOl4o6IJUC0ipA)GeBuQcgeW6NWHaiihKPkbCujjIgp8Igxr7hKyJsvgDjNSRdar6HDXA6ReWrLKiA8Wl6)IKYK6meK(1hMJnhjq61LzenVhTN1bhkjwTcgeWkQ0fu0fChDXrJSOlhnUIgLdcQ(WUynLeoitvUROlhTogus3KyOOl4oAKhDHIg)OrE0fhnsi68AGUPRDa6hnYIgzrxoAgbXOh2rLKflxklPK6meK(w(5XQw(lK1ClgbCujjShAXYSrj24wmgz4d4J(0OZ7kfRjq9lzGUYpTqjb5kCLrg(a(OXpAEWD0LJoVRuSMa1VKb6k)0cLeKRWvgz4d4J(07Olu0LJwhdkPBsmu08E0mYWhWhDbrN3vkwtG6xYaDLFAHscYv4kJm8b8rJF0fYI5zDwGfdmiGvuPliRA5)eSMBX8SolWI9uMrAsPmmy4v4ilgbCujjShAvl)iXwZTyEwNfyXiCMptmxjlgbCujjShAvRAXYI3AULFESMBXiGJkjH9qlwMnkXg3IHROr5GGQpSlwtjHdYuL7k6YrJYbbvFyo2CKajDzaxSvUROlhnkheu9H5yZrcK0LbCXwzKHpGp6tVJ2m1czX8SolWI9WUynLeoitwmUNsleucrwyX4XQw(l2AUfJaoQKe2dTyz2OeBClgkheu9H5yZrcK0LbCXw5UIUC0OCqq1hMJnhjqsxgWfBLrg(a(Op9oAZulKfZZ6Sal2xYaDLFAHscYvylg3tPfckHilSy8yvl)MXAUfJaoQKe2dTyz2OeBClgUI(vYLkmjQUugD5OfRwbdcyfv6cQQt(4aqyX8SolWILDPm5zDwqsoVAXKZRjGBqwm6FcKP3Qw(pG1ClgbCujjShAX8SolWIDTRmXOF5yzYILzJsSXTy4kA1LeqRpSlwtjOnZ9vc4OssyXGwwcq8IA5NhRA5VqwZTyeWrLKWEOflZgLyJBXiaXquk6cUJ(eWD0LJwSAfmiGvuPlOQo5Jdar0LJoVRuSMa1VKb6k)0cLeKRWvUROlhDExPynbQpSlwtjHdYund7me0hDb3rZJfZZ6Sal2dZXMJeiPld4I1Qw(pbR5wmc4Ossyp0ILzJsSXTyIvRGbbSIkDbv1jFCaiIUC0ipACfT6scO1hMJnhjqsxgWfBLaoQKerJhErRUKaA9HDXAkbTzUVsahvsIOXdVOZ7kfRjq9H5yZrcK0LbCXwzKHpGp6cIU4Orw0LJg5rJROP)jqMQOYDfPfkPWuIaKrPQHFIVSOXdVOZ7kfRjqfvURiTqjfMseGmkvzKHpGp6cIU4Orw0LJg5r7hKyJsvWGaw)eoeab5Gmvzo4y0NgDXrJhErJYbbvbdcy9t4qaeKdYuL7kAKzX8SolWI9Lmqx5NwOKGCf2Qw(rITMBXiGJkjH9qlMN1zbwmdNDKejOLLeKRWwSmBuInUfJ5Jir4qaT6cXx5UIUC0ipA1ziiTQJbL0njgk6tJoVgOB6AhG(vbbn5rJgp8Igxr)k5sfMevxkJUC051aDtx7a0VkiOjpA0fChD(kz48s6ViGiAKzXYLYskPodbPVLFESQLFZM1ClgbCujjShAXYSrj24wmMpIeHdb0QleFDarxq0Mb3rZ7rZ8rKiCiGwDH4RcoMRZcIUC04k6xjxQWKO6sz0LJoVgOB6AhG(vbbn5rJUG7OZxjdNxs)fbewmpRZcSygo7ijsqlljixHTQLFET1ClgbCujjShAXYSrj24wS8AGUPRDa6xfe0Khn6cUJU4OXp6xjxQWKO6sPfZZ6Sal2d7I1ucv6c6TQLFEWT1ClgbCujjShAXYSrj24wm1LeqRpSlwtjOnZ9vc4OsseD5OfRwbdcyfv6cQQt(4aqeD5Or5GGQFjd0v(PfkjixHRCxwmpRZcSypmhBosGKUmGlwRA5NhESMBXiGJkjH9qlwMnkXg3IHROr5GGQpSlwtjHdYuL7k6YrRJbL0njgk6tVJUqrJF0QljGwFouLyqCiOkbCujjIUC04kAMpIeHdb0QleFL7YI5zDwGf7HDXAkjCqMSQLFEk2AUfJaoQKe2dTyz2OeBClgkheufvURqY9ALrEwJgp8IgLdcQ(Lmqx5NwOKGCfUYDfD5OrE0OCqq1h2fRPeQ0f0x5UIgp8IoVRuSMa1h2fRPeQ0f0xzKHpGp6tVJMhChnYSyEwNfyXUwDwGvT8ZJzSMBXiGJkjH9qlwMnkXg3IHYbbv)sgOR8tlusqUcx5USyEwNfyXqL7ksqCSsw1YpphWAUfJaoQKe2dTyz2OeBClgkheu9lzGUYpTqjb5kCL7YI5zDwGfdLypXooaew1YppfYAUfJaoQKe2dTyz2OeBClgkheu9lzGUYpTqjb5kCL7YI5zDwGfdAyeQCxHvT8ZZjyn3Irahvsc7HwSmBuInUfdLdcQ(Lmqx5NwOKGCfUYDzX8SolWI5Gm9kZLPSlLw1YppiXwZTyeWrLKWEOfZZ6SalwUuwUkBbtoHk9xTyz2OeBClgUI(vYLkmjQUugD5OfRwbdcyfv6cQQt(4aqeD5OXv0OCqq1VKb6k)0cLeKRWvUROlhnbigIsvbbn5rJUG7OndUTyeeeL1eWnilwUuwUkBbtoHk9xTQLFEmBwZTyeWrLKWEOfZZ6SalMFWh2z(NGwGMwO01AIywSmBuInUfdxrJYbbvFyxSMschKPk3v0LJoVRuSMa1VKb6k)0cLeKRWvgz4d4J(0O5b3wmGBqwm)GpSZ8pbTanTqPR1eXSQLFE41wZTyeWrLKWEOfZZ6SalM)W44a6tm)GllLxMlTyz2OeBClMGq5GGQm)GllLxMltccLdcQkwtGOXdVOfekheunVabxwhCO0aoMeekheuL7k6YrRodbPvyYLkC9kRrFA0MHNOXdVOXv0ccLdcQMxGGlRdouAahtccLdcQYDfD5OrE0ccLdcQY8dUSuEzUmjiuoiO6RE(y0fChDXfkAEpAEWD0iHOfekheufvURiTqjfMseGmkv5UIgp8IwhdkPBsmu0Ng9bWD0il6YrJYbbv)sgOR8tlusqUcxzKHpGp6cI2SzXaUbzX8hghhqFI5hCzP8YCPvT8xmUTMBXiGJkjH9qlgWnilMrjH)j1LZB4alMN1zbwmJsc)tQlN3Wbw1YFX8yn3Irahvsc7HwSmBuInUfdLdcQ(Lmqx5NwOKGCfUYDfnE4fTogus3KyOOpn6IXTfZZ6Salg3tPrjJ3Qw1I9k5sfoLfV1Cl)8yn3Irahvsc7HwS9YI9KAX8SolWIHJZghvswmCCjhzXY7kfRjq9HDXAkjCqMQzyNHG(eeZZ6SaxgDb3rZtfjUqwmCCwc4gKf7HfjfMrp8kfw1YFXwZTyeWrLKWEOflZgLyJBXWv044SXrLu9HfjfMrp8kfrxo68AGUPRDa6xfe0Khn6cIMNOlhTGq5GGQqdqKmr(ra9FLrg(a(OpnAEIUC05DLI1eO(Lmqx5NwOKGCfUYidFaF0fChTzSyEwNfyXWXbZdBvl)MXAUfJaoQKe2dTyEwNfyXU2vMy0VCSmzXiErzEYnwoGAXoaUTyqllbiErT8ZJvT8FaR5wmc4Ossyp0ILzJsSXTyeGyikfDb3rFaChD5OjaXquQkiOjpA0fChnp4o6YrJROXXzJJkP6dlskmJE4vkIUC051aDtx7a0VkiOjpA0fenprxoAbHYbbvHgGizI8Ja6)kJm8b8rFA08yX8SolWI9WUynzqsHvT8xiR5wmc4Ossyp0ITxwSNulMN1zbwmCC24OsYIHJl5ilwEnq301oa9RccAYJgDb3rFalgoolbCdYI9WIuEnq301oa9TQL)tWAUfJaoQKe2dTy7Lf7j1I5zDwGfdhNnoQKSy44soYILxd0nDTdq)QGGM8OrF6D08en(rxC0iHO9dsSrPQctjOH9As4GmvjGJkjHflZgLyJBXWXzJJkPk3tPl2SSrlLyR66SGOlhnYJwDjb0kyqaRV6YJeRsahvsIOXdVOvxsaTkC2X0d7I1uLaoQKerJmlgoolbCdYI9WIuEnq301oa9TQLFKyR5wmc4Ossyp0ILzJsSXTy44SXrLu9HfP8AGUPRDa6hD5OrE04kA1LeqRcNDm9WUynvjGJkjr04Hx0IvRGbbSIkDbvzKHpGp6cUJUqrJF0QljGwFouLyqCiOkbCujjIgzrxoAKhnooBCujvFyrsHz0dVsr04Hx0OCqq1VKb6k)0cLeKRWvgz4d4JUG7O5PwC04Hx0)fjLj1zii9RpmhBosG0RlZi6cUJ(arxo68UsXAcu)sgOR8tlusqUcxzKHpGp6cIMhChnYIUC0ipA)GeBuQcgeW6NWHaiihKPkZbhJ(0OloA8WlAuoiOkyqaRFchcGGCqMQCxrJmlMN1zbwSh2fRPKWbzYQw(nBwZTyeWrLKWEOflZgLyJBXWXzJJkP6dls51aDtx7a0p6YrRJbL0njgk6tJoVRuSMa1VKb6k)0cLeKRWvgz4d4JUC04kAMpIeHdb0QleFL7YI5zDwGf7HDXAkjCqMSQvTyOCJuyn3YppwZTyeWrLKWEOflZgLyJBX(lsktQZqq6hDb3rxC04hnYJwDjb0kc5UgOsxqvc4OsseD5O9dsSrP6fXGwMRuL5GJrxWD0fhnYSyEwNfyXEyo2CKaPxxMHvT8xS1ClMN1zbwmeYDnqLUGSyeWrLKWEOvT8BgR5wmpRZcSyOE(4RoQfJaoQKe2dTQvTQfdhI9ZcS8xmU5HxJBZgp42IzYzGbG4Tyijgxltjr0MTO9SoliA586xJZwS)IYw(l(e4XIDXwOrswmKgnghQkjTu0M9fbhfNrA0WQE9NKIkcXOWCO18Au0pgCsxNfKzoKw0pg5IIZinAm6sjduIfDXfIVOlg38WRJZXzKgnVb7ae0FsIZinAEpAKiHGerBwBYhJw3OfeKZj1O9SoliA58AnoJ0O59On7KXIdjIwDgcstdu05figDwq0liAEvNDKerdTSOlm5kCnoJ0O59OrIecseTz5POrsuY4RX54msJgjfVqzoLerJsqlJIoVgOUgnkHyaFnAKOCMU0pAWc4DyNzaXjJ2Z6SGp6filvJZinApRZc(6fJYRbQR3qs)pgNrA0EwNf81lgLxduxX)UiNdHbbuxNfeNrA0EwNf81lgLxduxX)UiODfXzKgngWVE4vJM5JiAuoiise9RU(rJsqlJIoVgOUgnkHyaF0oqe9fJ49Rv1bGi65JwSaQgNrA0EwNf81lgLxduxX)UOh4xp8QPxD9JZEwNf81lgLxduxX)UOxjxQWXzpRZc(6fJYRbQR4FxKHZosIe0YscYvy(UyuEnqDn9uEbI)MNcfN9Sol4RxmkVgOUI)DrpSlwtjuPlONVlgLxduxtpLxG4V5jo7zDwWxVyuEnqDf)7IUwDwqC2Z6SGVEXO8AG6k(3fX9uAuYGpGBq3(bFyN5FcAbAAHsxRjIfNJZinAKu8cL5usenHdXkfTogu0kmfTN1Lf98r744J0rLunoJ0On70RKlv4OhOOV2)hujfnYbB04WjbeZrLu0eGmg6JEarNxduxrwC2Z6SG)(4KpY3aDJRxjxQWKOYweCuC2Z6SGh)7IELCPchNrA08gmLpgnVv4pAxJgAyVgN9Sol4X)UOSlLjpRZcsY5v(aUbDNfFCgPrB25ardXjLLI(nnAgM(O1nAfMIgtjxQWKiAZ(QUoliAKJwkAXoaer)lFrpA0qlltF0x7khaIOhOObRcpaerpF0oo(iDujHSAC2Z6SGh)7IyCGKN1zbj58kFa3GUFLCPctc(gO7xjxQWKO6szCgPrJeDDjlfn)dcyfv6ckAxJUy8JM3o5OfCSbGiAfMIgAyVgnp4o6NYlq88fTdPelAf21Opa(rZBNC0du0JgnXlxdJ(Onnk8aIwHPObeVOrBwL3kC0ll65JgSA0CxXzpRZcE8VlcmiGvuPli(gOBDmOKUjXqfCcLzKHpG)uezr1W5LY51aDtx7a0VG7dW7ixhd6uEWnYqcfhNrA0MvaYsrNHDackA2QUoli6bkAtu0Woou0xSzzJwkXw11zbr)KgTderBWj15ssrRodbPF0Cx14SN1zbp(3fHJZghvs8bCd6M7P0fBw2OLsSvDDwaF44so6(InlB0sj2QUolO8FrszsDgcs)6dZXMJei96Ymk4U44msJ(KzZYgTu0M9vDDwas6rBwN0tSpAedou0E0zMFfTJUCA0eGyikfn0YIwHPOFLCPchnVv4pAKJYnsbXI(1rkJMr)fL1Ohfz1Orsd3fFrpA0zhenkfTc7A0)yCjPAC2Z6SGh)7IYUuM8SolijNx5d4g09RKlv4uw88nq344SXrLuL7P0fBw2OLsSvDDwqCgPrBwEseTUrliObqrBcMarRB0Cpf9RKlv4O5Tc)rVSOr5gPGyFC2Z6SGh)7IWXzJJkj(aUbD)k5sfoPWm6HxPGpCCjhDxCHWxDjb0kodILvjGJkjbsWmfcF1LeqRg(RelTqPh2fRPVsahvscKqXfcF1LeqRpSlwtjOnZ9vc4OssGekg34RUKaA1LEMnAPkbCujjqc8GB85PqibK)xKuMuNHG0V(WCS5ibsVUmJcUndYIZinAEBb)iiw0C)aqeThnMsUuHJM3kC0MGjq0mYZWdar0kmfnbigIsrRWm6HxPio7zDwWJ)DrzxktEwNfKKZR8bCd6(vYLkCklE(gOBcqmeLQccAYJE6nooBCujvFLCPcNuyg9WRueNrA08piG1tSp6tkbqqoitNKO5FqaROsxqrJsqlJIgRKb6k)ODnA5AkAE7KJw3OZRb6aOOjNjlfnJGy0dhTPrHJgbP6aqeTctrJYbbfn3vnAKi5VrlxtrZBNC0co2aqenwjd0v(rJsQjIarxyhKPpAtJchDX4hn)N0AC2Z6SGh)7Iadcyfv6cIVb62piXgLQGbbS(jCiacYbzQsahvsIY4cLdcQcgeW6NWHaiihKPk3v58AGUPRDa6xfe0KhTaEkJ8)IKYK6meK(1hMJnhjq61LzCAX4HhooBCujv5EkDXMLnAPeBvxNfGSYipVRuSMa1VKb6k)0cLeKRWvgz4d4p92m4HhY9dsSrPkyqaRFchcGGCqMQmhCSG7IlJYbbv)sgOR8tlusqUcxzKHpGVaZugxVsUuHjr1LYY5DLI1eO(WUynLeoit1mSZqqFcI5zDwGll4g3vEnYqwCgPrJKhW8Wr7A0ha)Onnk8YPrxym(IUq4hTPrHJUWyrJ8Lt)rqr)k5sfgzXzpRZcE8Vlk7szYZ6SGKCELpGBq3qdyEy(gO78AGUPRDa6xfe0Kh90BEWdpDmOKUjXqNEZt58AGUPRDa6xWTzIZin6t0OWrxySOD5VrdnG5HJ21Opa(r7i8b8A0eV4zvwk6deT6meK(rJ8Lt)rqr)k5sfgzXzpRZcE8Vlk7szYZ6SGKCELpGBq3qdyEy(gO7)IKYK6meK(1hMJnhjq61LzCFGY51aDtx7a0VG7deNrA0MLNI2JgLBKcIfTjycenJ8m8aqeTctrtaIHOu0kmJE4vkIZEwNf84Fxu2LYKN1zbj58kFa3GUr5gPGVb6MaedrPQGGM8ONEJJZghvs1xjxQWjfMrp8kfXzKgTz91e9A0xSzzJwk6beTlLrVqrRWu0irNSz9OrPSZ9u0JgD25E6J2J2SkVv44SN1zbp(3f5SSdOKUmgbu(gOBcqmeLQccAYJwWnpfcFcqmeLQmcbbIZEwNf84FxKZYoGsxCYNIZEwNf84FxKCqaRF6eNtGWGaACooJ0OpKBKcI9XzpRZc(kk3if3pmhBosG0RlZGVb6(ViPmPodbPFb3fJpYvxsaTIqURbQ0fuLaoQKeL9dsSrP6fXGwMRuL5GJfCxmYIZEwNf8vuUrkW)UieYDnqLUGIZEwNf8vuUrkW)UiupF8vhnohNrA082UsXAc8XzKgTz5POlSdYu0leeVJilIgLGwgfTctrdnSxJgdMJnhjq0y6YmIgITgrB(YaUyJoVg0h9aQXzpRZc(Aw83pSlwtjHdYeFCpLwiOeIS4Mh(gOBCHYbbvFyxSMschKPk3vzuoiO6dZXMJeiPld4ITYDvgLdcQ(WCS5ibs6YaUyRmYWhWF6TzQfkoJ0OrUzbiP)J2LmYfLIM7kAuk7CpfTjkAD3JrJb7I1u0i5nZ9ilAUNIgRKb6k)OxiiEhrwenkbTmkAfMIgAyVgngmhBosGOX0LzeneBnI28LbCXgDEnOp6buJZEwNf81S4X)UOVKb6k)0cLeKRW8X9uAHGsiYIBE4BGUr5GGQpmhBosGKUmGl2k3vzuoiO6dZXMJeiPld4ITYidFa)P3MPwO4SN1zbFnlE8Vlk7szYZ6SGKCELpGBq30)eitpFd0nUELCPctIQlLLfRwbdcyfv6cQQt(4aqeNrA0N8UYOHww0MVmGl2OVyeVJTfoAtJchngCHJMrUOu0MGjq0GvJMXbadar0yi5AC2Z6SGVMfp(3fDTRmXOF5yzIpOLLaeVO38W3aDJl1LeqRpSlwtjOnZ9vc4OsseNrA0MLNI28LbCXg9fJIgBlC0MGjq0MOOHDCOOvykAcqmeLI2emPWelAi2Ae91UYbGiAtJcVCA0yi5Oxw0N4CVgnccqmxklvJZEwNf81S4X)UOhMJnhjqsxgWflFd0nbigIsfCFc4USy1kyqaROsxqvDYhhaIY5DLI1eO(Lmqx5NwOKGCfUYDvoVRuSMa1h2fRPKWbzQMHDgc6l4MN4msJ2S8u0yLmqx5h9cIoVRuSMarJChsjw0qd71O5FqaROsxqilAoGK(pAtu0oJIgXoaerRB0x7v0MVmGl2ODGiAXgny1OHDCOOXGDXAkAK8M5(AC2Z6SGVMfp(3f9Lmqx5NwOKGCfMVb6wSAfmiGvuPlOQo5JdarzKJl1LeqRpmhBosGKUmGl2kbCujjWdp1LeqRpSlwtjOnZ9vc4OssGhE5DLI1eO(WCS5ibs6YaUyRmYWhWxqXiRmYXf9pbYufvURiTqjfMseGmkvn8t8LHhE5DLI1eOIk3vKwOKctjcqgLQmYWhWxqXiRmY9dsSrPkyqaRFchcGGCqMQmhC80IXdpuoiOkyqaRFchcGGCqMQCxiloJ0OrsGI2fIpANrrZDXx0pyUOOvyk6fqrBAu4OLRj61On38cxJ2S8u0MGjq0Isdar0q(RelAf2brZBNC0ccAYJg9YIgSA0VsUuHjr0MgfE50ODqPO5TtUgN9Sol4RzXJ)Drgo7ijsqlljixH5lxklPK6meK(38W3aDZ8rKiCiGwDH4RCxLrU6meKw1XGs6MedDAEnq301oa9RccAYJIhE46vYLkmjQUuwoVgOB6AhG(vbbn5rl4oFLmCEj9xeqGS4msJgjbkAWgTleF0MgPmAXqrBAu4beTctrdiErJ2m4(5lAUNIMxfQWrVGOr3)J20OWlNgTdkfnVDYr7ar0Gn6xjxQW14SN1zbFnlE8VlYWzhjrcAzjb5kmFd0nZhrIWHaA1fIVoGcmdU5DMpIeHdb0QleFvWXCDwqzC9k5sfMevxklNxd0nDTdq)QGGM8OfCNVsgoVK(lciIZEwNf81S4X)UOh2fRPeQ0f0Z3aDNxd0nDTdq)QGGM8OfCxm(VsUuHjr1LY4msJ(enkC0yiz(IEGIgSA0UKrUOu0Ifq8fn3trB(YaUyJ20OWrJTfoAURAC2Z6SGVMfp(3f9WCS5ibs6YaUy5BGUvxsaT(WUynLG2m3xjGJkjrzXQvWGawrLUGQ6KpoaeLr5GGQFjd0v(PfkjixHRCxXzpRZc(Aw84Fx0d7I1us4GmX3aDJluoiO6d7I1us4Gmv5UkRJbL0njg607cHV6scO1NdvjgehcQsahvsIY4I5Jir4qaT6cXx5UIZEwNf81S4X)UORvNfW3aDJYbbvrL7kKCVwzKNv8WdLdcQ(Lmqx5NwOKGCfUYDvg5OCqq1h2fRPeQ0f0x5UWdV8UsXAcuFyxSMsOsxqFLrg(a(tV5b3ilo7zDwWxZIh)7IqL7ksqCSs8nq3OCqq1VKb6k)0cLeKRWvUR4SN1zbFnlE8VlcLypXooae8nq3OCqq1VKb6k)0cLeKRWvUR4SN1zbFnlE8VlcAyeQCxbFd0nkheu9lzGUYpTqjb5kCL7ko7zDwWxZIh)7ICqMEL5Yu2Ls(gOBuoiO6xYaDLFAHscYv4k3vC2Z6SGVMfp(3fX9uAuYGpccIYAc4g0DUuwUkBbtoHk9x5BGUX1RKlvysuDPSSy1kyqaROsxqvDYhhaIY4cLdcQ(Lmqx5NwOKGCfUYDvMaedrPQGGM8OfCBgChN9Sol4RzXJ)DrCpLgLm4d4g0TFWh2z(NGwGMwO01AIy8nq34cLdcQ(WUynLeoitvURY5DLI1eO(Lmqx5NwOKGCfUYidFa)P8G74msJ(KsSsrZwoeWYsrZ4Ku0lu0kmNb6anKiAdxH)Orj5A6KeTz5POHww0ijGJxRi6mBu(IEvyIzAEkAtJchn2w4ODn6Ile(r)QNp(rVSO5Pq4hTPrHJ2L)g9HYDfrZDvJZEwNf81S4X)UiUNsJsg8bCd62FyCCa9jMFWLLYlZL8nq3ccLdcQY8dUSuEzUmjiuoiOQynbWdpbHYbbvZlqWL1bhknGJjbHYbbv5UkRodbPvyYLkC9kRNAgEWdpCjiuoiOAEbcUSo4qPbCmjiuoiOk3vzKliuoiOkZp4Ys5L5YKGq5GGQV65JfCxCH4DEWnsqqOCqqvu5UI0cLuykraYOuL7cp80XGs6MedD6bWnYkJYbbv)sgOR8tlusqUcxzKHpGVaZwC2Z6SGVMfp(3fX9uAuYGpGBq3gLe(NuxoVHdIZin6ctqoNuJgYLsupFmAOLfn37Osk6rjJ)KeTz5POnnkC0yLmqx5h9cfDHjxHRXzpRZc(Aw84Fxe3tPrjJNVb6gLdcQ(Lmqx5NwOKGCfUYDHhE6yqjDtIHoTyChNJZinAKu)tGm9XzpRZc(k9pbY0FNxqMakZvsKGKUbX3aDtaIHOuvhdkPBYW5Lc4PmUq5GGQFjd0v(PfkjixHRCxLroUeRwZlitaL5kjsqs3GsOCmqvN8XbGOmU8SolOMxqMakZvsKGKUbvhqcsoiGv8WdItktmkd7meushd6uezr1W5fKfN9Sol4R0)eitp(3fHk3vKwOKctjcqgL4BGUZ7kfRjq9lzGUYpTqjb5kCL7cp80XGs6MedD6np4oo7zDwWxP)jqME8VlcbNZeJdsluYpiXwfoo7zDwWxP)jqME8VlcAZCpjs(bj2OucLCd(gOBK)xKuMuNHG0V(WCS5ibsVUmJcUlgp8y(iseoeqRUq81buWjGBKvgx5DLI1eO(Lmqx5NwOKGCfUYDvgxOCqq1VKb6k)0cLeKRWvURYeGyikvfe0KhTGBZG74SN1zbFL(Naz6X)UOlo2avAaisOs)v(gO7)IKYK6meK(1hMJnhjq61LzuWDX4HhZhrIWHaA1fIVoGcobChN9Sol4R0)eitp(3fPWuIdGUCarcAzzIVb6gLdcQYO8rj9FcAzzQYDHhEOCqqvgLpkP)tqlltP8YbuIvF1ZhpLhChN9Sol4R0)eitp(3fXMRljLgq6V8mfN9Sol4R0)eitp(3fzAzsbo0asm6xGdYeFd0nkheuvoqeQCxr9vpF8uZeN9Sol4R0)eitp(3fzqglRuAHssU8iscg5gpFd0nbigIsNEaCxgLdcQ(Lmqx5NwOKGCfUYDfNJZinAK8aMhMyFC2Z6SGVcnG5HVV2vMy0VCSmXh0YsaIx0BEIZinAKu4mFMyUsrd7F0Wdcy61OVyZYgTu0MgfoA(heW6j2h9jLaiihKPO5UQXzpRZc(k0aMhg)7IiCMptmxj(gOBuoiOkyqaRFchcGGCqMQCxXzKgTznIUIM7kA(heWkQ0fu0du0Jg98r7OlNgTUrZ4arVCAn6cVrdwnAUNIM)dJwWXgaIOlSdYeFrpqrRUKakjIEa6gDHD2XOXGDXAQgN9Sol4RqdyEy8VlcmiGvuPli(gOBKJl1LeqRcNDm9WUynvjGJkjbE4HluoiO6d7I1us4Gmv5UqwzDmOKUjXq8oJm8b8fCcLzKHpG)uDYht6yqiHIJZinAEvoPoIv1bGi6Lt)rqrxyhKPOxq0QZqq6hTc7A0MgPmA5Gdfn0YIwHPOfCmxNfe9cfn)dcyfv6cIVOzeeJE4OfCSbGi6lhiiJjxJMxLtQJy1O9pA5cqeT)rxm(rRodbPF0InAWQrd74qrZ)GawrLUGIM7kAtJchTzNUKt21bGiAmyxSM(Orohqs)hDPLlAyhhkA(heW6j2h9jLaiihKPO1Drwno7zDwWxHgW8W4FxeyqaROsxq8LlLLusDgcs)BE4BGUXfooBCujv5EkDXMLnAPeBvxNfu(ViPmPodbPF9H5yZrcKEDzgfCxCzK7hKyJsvWGaw)eoeab5GmvjGJkjbE4Hl)GeBuQYOl5KDDaispSlwtFLaoQKe4H3FrszsDgcs)6dZXMJei96Ym4DpRdousSAfmiGvuPlOcUlgzLXfkheu9HDXAkjCqMQCxL1XGs6MedvWnYle(iVyKqEnq301oa9rgYkZiig9WoQKIZinAZobXOhoA(heWkQ0fu0KZKLIEGIE0Onnsz0eVCnmkAbhBaiIgRKb6k)A0fEJwHDnAgbXOho6bkASTWrJG0pAg5IsrpGOvykAaXlA0f6RXzpRZc(k0aMhg)7Iadcyfv6cIVb6Mrg(a(tZ7kfRjq9lzGUYpTqjb5kCLrg(aE85b3LZ7kfRjq9lzGUYpTqjb5kCLrg(a(tVluzDmOKUjXq8oJm8b8fK3vkwtG6xYaDLFAHscYv4kJm8b84xO4SN1zbFfAaZdJ)DrpLzKMukddgEfoko7zDwWxHgW8W4FxeHZ8zI5kfNJZinAmLCPchnVTRuSMaFCgPrJKwsErSOpPoBCujfN9Sol4RVsUuHtzXFJJZghvs8bCd6(HfjfMrp8kf8HJl5O78UsXAcuFyxSMschKPAg2ziOpbX8SolWLfCZtfjUqXzKg9j1bZdhnhqs)hTjkANrr7OlNgTUrN9ROxq0f2bzk6mSZqqFnAZkazPOnbtGOrYdqe9jI8Ja6)ONpAhD50O1nAghi6LtRXzpRZc(6RKlv4uw84FxeooyEy(gOBCHJZghvs1hwKuyg9WRuuoVgOB6AhG(vbbn5rlGNYccLdcQcnarYe5hb0)vgz4d4pLNY5DLI1eO(Lmqx5NwOKGCfUYidFaFb3MjoJ0Op5DLrdTSOXGDXAYGKIOXpAmyxSMELnhPO5as6)Onrr7mkAhD50O1n6SFf9cIUWoitrNHDgc6RrBwbilfTjycensEaIOprKFeq)h98r7OlNgTUrZ4arVCAno7zDwWxFLCPcNYIh)7IU2vMy0VCSmXh0YsaIx0BE4J4fL5j3y5a69bWDC2Z6SGV(k5sfoLfp(3f9WUynzqsbFd0nbigIsfCFaCxMaedrPQGGM8OfCZdUlJlCC24OsQ(WIKcZOhELIY51aDtx7a0VkiOjpAb8uwqOCqqvObisMi)iG(VYidFa)P8eNrA082jhnJ4v4ggzqa9KeDHDqMI21OLRPO5TtoA0srliiNtQ14SN1zbF9vYLkCklE8VlchNnoQK4d4g09dls51aDtx7a0NpCCjhDNxd0nDTdq)QGGM8OfCFG4msJM3o5OzeVc3WidcONKOlSdYu0lqwkAucAzu0qdyEyI9rpqrBIIg2XHI2nUIwDjb0pAhiI(InlB0srZw11zb14SN1zbF9vYLkCklE8VlchNnoQK4d4g09dls51aDtx7a0NpCCjhDNxd0nDTdq)QGGM8ONEZd(fJe8dsSrPQctjOH9As4GmvjGJkjbFd0nooBCujv5EkDXMLnAPeBvxNfug5QljGwbdcy9vxEKyvc4OssGhEQljGwfo7y6HDXAQsahvscKfNrA0NOrHJUWo7y0yWUynf9cKLIUWoitrBcMarZ)GawrLUGI20iLr)QxkAURA0MLNIwWXgaIOXkzGUYp6LfTJU4qrRWm6HxPOg9jYhnAOLfn)N0Or5GGI20OWrxm(8FsRXzpRZc(6RKlv4uw84Fx0d7I1us4GmX3aDJJZghvs1hwKYRb6MU2bOFzKJl1LeqRcNDm9WUynvjGJkjbE4jwTcgeWkQ0fuLrg(a(cUle(QljGwFouLyqCiOkbCujjqwzKJJZghvs1hwKuyg9WRuGhEOCqq1VKb6k)0cLeKRWvgz4d4l4MNAX4H3FrszsDgcs)6dZXMJei96Ymk4(aLZ7kfRjq9lzGUYpTqjb5kCLrg(a(c4b3iRmY9dsSrPkyqaRFchcGGCqMQmhC80IXdpuoiOkyqaRFchcGGCqMQCxiloJ0OpKJbIMrg(agaIOlSdY0hnkbTmkAfMIwDgcsJwm0h9afn2w4OnTGtmnAukAg5IsrpGO1XGQXzpRZc(6RKlv4uw84Fx0d7I1us4GmX3aDJJZghvs1hwKYRb6MU2bOFzDmOKUjXqNM3vkwtG6xYaDLFAHscYv4kJm8b8LXfZhrIWHaA1fIVYDfNJZinAmLCPctIOn7R66SG4msJgjbkAmLCPcxeooyE4ODgfn3fFrZ9u0yWUyn9kBosrRB0OeGGgnAi2AeTctrF5)p4qrJUaUpAhiIgjpar0NiYpcO)5lAchce9afTjkANrr7A0goVenVDYrJCi2AeTctrFXO8AG6A08Qqfgz14SN1zbF9vYLkmjUFyxSMELnhj(gOBKRUKaAfAaIKjYpcO)ReWrLKap8(lsktQZqq6xFyo2CKaPxxMXPMbzLrokheu9vYLkCL7cp8q5GGQ44G5HRCxiloJ0OrYdyE4ODnAZGF082jhTPrHxon6cJfDrrFa8J20OWrxySOnnkC0yWCS5ibI28LbCXgnkheu0CxrRB0oo7iI(xdkAE7KJ2K)kf9pkNRZc(AC2Z6SGV(k5sfMe4Fxu2LYKN1zbj58kFa3GUHgW8W8nq3OCqq1hMJnhjqsxgWfBL7QCEnq301oa9RccAYJE6DXXzKgnsK83OFhIIw3OHgW8Wr7A0ha)O5TtoAtJchnXlEwLLI(arRodbPFnAKJ5gu0(h9YP)iOOFLCPcxrwC2Z6SGV(k5sfMe4Fxu2LYKN1zbj58kFa3GUHgW8W8nq3)fjLj1zii9RpmhBosG0RlZ4(aLZRb6MU2bOFb3hioJ0OrYdyE4ODn6dGF082jhTPrHxon6cJXx0fc)OnnkC0fgJVODGi6tiAtJchDHXI2HuIf9j1bZdh9YI2CykAK8WEn6c7GmfTderd2OlSZogngSlwtrJF0GnAmouLyqCiO4SN1zbF9vYLkmjW)UOSlLjpRZcsY5v(aUbDdnG5H5BGUZRb6MU2bOFvqqtE0tV5H3rU6scOvbrxel9kZvhbzujGJkjrzKJYbbvXXbZdx5UWdp)GeBuQQWucAyVMeoitvc4OssugxQljGwfo7y6HDXAQsahvsIY4sDjb06ZHQedIdbvjGJkjr5)IKYK6meK(1hMJnhjq61LzCQzqgYIZinAZYtrBwvURbQ0fu0loelAmyxSMELnhPODGiAmDzgrBAu4Olg)OpzIbTmxPODn6IJEzrlP)JwDgcs)AC2Z6SGV(k5sfMe4Fxec5UgOsxq8nq3(bj2Ou9IyqlZvQYCWXcUlU8FrszsDgcs)6dZXMJei96Ymo9U44msJgjsJU4OvNHG0pAtJchngLzKgT5uggm8kCu0hj6kAUROrYdqe9jI8Ja6)OrlfDUuwoaerJb7I10RS5ivJZEwNf81xjxQWKa)7IEyxSMELnhj(YLYskPodbP)np8nq3QljGwFkZinPuggm8kCuLaoQKeLvxsaTcnarYe5hb0)vc4OssuwqOCqqvObisMi)iG(VYidFa)P8u(ViPmPodbPF9H5yZrcKEDzg3fxwhdkPBsmeVZidFaFbNqCgPrFIgfE50OlmrxelAmL5QJGmI2bIOnt0MDhC8JEHI(qPlOOhq0kmfngSlwtF0Jg98rBAzkC0C)aqengSlwtVYMJu0liAZeT6meK(14SN1zbF9vYLkmjW)UOh2fRPxzZrIVb6gxQljGwfeDrS0RmxDeKrLaoQKeL9dsSrPkQ0fuAajfMspSlwtFL5GJ3MP8FrszsDgcs)6dZXMJei96YmUntCgPrJKxw0xSzzJwkA2QUolGVO5EkAmyxSMELnhPOxCiw0y6YmIMhKfTPrHJ(eXRgTJWhWRrZDfTUrFGOvNHG0NVOlgzrpqrJKprrpF0moayaiIEHGIg5liAhukA3y5aA0lu0QZqq6Jm(IEzrBgKfTUrB48YymhKIgBlC0eVOe4NfeTPrHJgjbq4mQJoYrlf9cI2mrRodbPF0i)arBAu4OpCumKvJZEwNf81xjxQWKa)7IEyxSMELnhj(gOBCC24OsQY9u6InlB0sj2QUolOmYvxsaTcnarYe5hb0)vc4OssuwqOCqqvObisMi)iG(VYidFa)P8GhEQljGwnr(1cm8xjwLaoQKeL)lsktQZqq6xFyo2CKaPxxMXP3hap88dsSrP6aiCg1rh5OLQeWrLKOmkheu9lzGUYpTqjb5kCL7Q8FrszsDgcs)6dZXMJei96Ymo92m47hKyJsvuPlO0askmLEyxSM(kbCujjqwC2Z6SGV(k5sfMe4Fx0dZXMJei96Ym4BGU)lsktQZqq6xWTzIZEwNf81xjxQWKa)7IEyxSMELnhjRAvRfa]] )


end
