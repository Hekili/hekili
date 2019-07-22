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


    spec:RegisterPack( "Subtlety", 20190721.0000, [[daLRIbqiufEeOOnPe9jqbYOaL6uGswfOGEfuPzHQYTqvL2LK(LOOHbvPJHQ0Yev1ZGQyAIQ4AIQ02qvv(MOqmoLuIZHQOSorHQ5PKQ7PuTprj)dvrv6GkPKwOOupevrMOOGlckqTrqH6JOkQQrIQOk6KGcPvQK8suvvvZevvv5MOkQStkHFIQQkgQsk1sffspfktLs0vffkBfui(kQQkNfvrvyVu8xjgSuhMQfdPhlYKjCzKndXNbvJgKtRy1OQQsVwuz2eDBk1Ub(TQgUs54Gcy5O8CvMoPRJkBhQ47usJhvvCELW6vsX8HQA)cB41yPbt4kzSiF8YlpdVzK8ZVIx8Mp)L38yW0fBKbBZt5C4Kbd42KbdJdvLKUWGT5lKVlmwAWUNJLidgKQBxgpZmHpkehAn92zEJnN015bjMJOzEJDktdgk3ivyuGb1GjCLmwKpE5LNH3ms(5xXlEZN)YlVgmNtHEMbdBS5jdg0ieeWGAWe0LmyWmAmouvs6IOZOpCokwbZOHuD7Y4zMj8rH4qRP3oZBS5KUopiXCenZBStzgRGz0R4KlIoFE5l68XlV8SO53O5LNLXXZAjwfRGz08eKdGtxgpwbZO53OxRcbjIM))KYfT(rlieNtQr7jDEq0Y50AScMrZVrNrj7hhseT6m4KwgKOtpqm68GOFq08ColhjIg5zrNbYvOAScMrZVrVwfcseDg7OOHrvY(Qgm5C6zS0GDk5sfIeglnwWRXsdgbCujjmzBWsSrj24gmyhT6scOvKbikwjphGURsahvsIOXh)OVnsklQZGt6vpio2KJaLtFMD0RhnEIgwrVmAyhnkhcs9uYLkuLBlA8XpAuoeKkooyoOk3w0WYG5jDEGb7GCXB9u2KJmQXI8nwAWiGJkjHjBdwInkXg3GHYHGupio2KJaf9zax8vUTOxgD6Tr)Y2pa9QcczsJg967rNVbZt68adwYLYIN05bf5CQbtoNwaUnzWqgWCqg1ybEmwAWiGJkjHjBdwInkXg3GDBKuwuNbN0REqCSjhbkN(m7O3JoprVm60BJ(LTFa6fDw7rNhdMN05bgSKlLfpPZdkY5udMCoTaCBYGHmG5GmQXI8yS0Grahvsct2gSeBuInUbl92OFz7hGEvbHmPrJE99O5nA(nAyhT6scOvbrBeRCkZvhozxjGJkjr0lJg2rJYHGuXXbZbv52IgF8J2xdXgLQkevqg2PfHdsuLaoQKerVmAEeT6scOvHZYvoix8wReWrLKi6LrZJOvxsaTECOkXq4Gtvc4Osse9YOVnsklQZGt6vpio2KJaLtFMD0RhnEIgwrdldMN05bgSKlLfpPZdkY5udMCoTaCBYGHmG5GmQXI8AS0Grahvsct2gSeBuInUbZxdXgLQBed5zUsvMdYfDw7rNF0lJ(2iPSOodoPx9G4ytocuo9z2rV(E05BW8KopWGbx(VnQ0fKrnwWFglnyeWrLKWKTbZt68ad2b5I36PSjhzWsSrj24gm1LeqRhLyKwukbbgyaoQsahvsIOxgT6scOvKbikwjphGURsahvsIOxgTGq5qqQidquSsEoaDxLr2(aUOxpAEJEz03gjLf1zWj9QhehBYrGYPpZo69OZp6LrRJnv0VigkA(nAgz7d4IoRO5pdwArssf1zWj9mwWRrnwKrmwAWiGJkjHjBdwInkXg3GXJOvxsaTkiAJyLtzU6Wj7kbCujjIEz0(Ai2Oufv6cQmGIcrLdYfV1RYCqUO3JgprVm6BJKYI6m4KE1dIJn5iq50Nzh9E04XG5jDEGb7GCXB9u2KJmQXI1IXsdgbCujjmzBWsSrj24gmCC24OsQYDuzJnpB0ff2RUopi6Lrd7OvxsaTImarXk55a0Dvc4Osse9YOfekhcsfzaIIvYZbO7QmY2hWf96rZB04JF0QljGwTs(2dS9tjwLaoQKerVm6BJKYI6m4KE1dIJn5iq50Nzh967rNNOXh)O91qSrP6aiCg1rh5OlQeWrLKi6LrJYHGuVf2OV8kpsrqUcv52IEz03gjLf1zWj9QhehBYrGYPpZo613JgprJB0(Ai2Oufv6cQmGIcrLdYfV1RsahvsIOHLbZt68ad2b5I36PSjhzuJf8mJLgmc4OssyY2GLyJsSXny3gjLf1zWj9IoR9OXJbZt68ad2bXXMCeOC6ZSnQXcEXRXsdMN05bgSdYfV1tztoYGrahvsct2g1Ogm6ocKOZyPXcEnwAW8KopWGLEqIakZvsuqKUnzWiGJkjHjBJASiFJLgmpPZdmyOY)fLhPOquHaK9cdgbCujjmzBuJf4XyPbZt68adgCoNjghuEKIVgI9kKbJaoQKeMSnQXI8yS0Grahvsct2gSeBuInUbd2rFBKuwuNbN0REqCSjhbkN(m7OZAp68JgF8JM5JOq4qaT6cXvhq0zfn)H3OHv0lJMhrN(xkERG6TWg9Lx5rkcYvOk3w0lJMhrJYHGuVf2OV8kpsrqUcv52IEz0eGyWxufeYKgn6S2Jgp41G5jDEGbd5tChjk(Ai2OubLCBJASiVglnyeWrLKWKTblXgLyJBWUnsklQZGt6vpio2KJaLtFMD0zThD(rJp(rZ8ruiCiGwDH4Qdi6SIM)WRbZt68ad2ghBqwma4fuPFQrnwWFglnyeWrLKWKTblXgLyJBWq5qqQmkLts3vqEwIQCBrJp(rJYHGuzukNKURG8Sevsphqjw9upLl61JMx8AW8KopWGPquHdG(Carb5zjYOglYiglnyEsNhyWyZ2MKkdOCBEImyeWrLKWKTrnwSwmwAWiGJkjHjBdwInkXg3GHYHGuLdcHk)xup1t5IE9OXJbZt68adM1Njf4qdOWO7boirg1ybpZyPbJaoQKeMSnyj2OeBCdgbig8frVE05bVrVmAuoeK6TWg9Lx5rkcYvOk3MbZt68adMnz)SfLhPi5sJOiyKBFg1OgmbH4Cs1yPXcEnwAWiGJkjHjBdwInkXg3GXJOpLCPcrIk7HZrgmpPZdmy5MuoJASiFJLgmpPZdmyNsUuHmyeWrLKWKTrnwGhJLgmc4OssyY2G5jDEGbl5szXt68GICo1GjNtla3MmyjXzuJf5XyPbJaoQKeMSnyj2OeBCd2PKlvisuDP0G5jDEGbJXbkEsNhuKZPgm5CAb42Kb7uYLkejmQXI8AS0Grahvsct2gSeBuInUbthBQOFrmu0zfn)f9YOzKTpGl61JgEsuTD(j6LrNEB0VS9dqVOZAp68en)gnSJwhBk61JMx8gnSIgggD(gmpPZdmyGboKIkDbzuJf8NXsdgbCujjmzBW(nd2rQbZt68adgooBCujzWWXLCKbBJnpB0ff2RUopi6LrFBKuwuNbN0REqCSjhbkN(m7OZAp68ny44ScWTjdg3rLn28SrxuyV668aJASiJyS0Grahvsct2gSeBuInUbdhNnoQKQChv2yZZgDrH9QRZdmyEsNhyWsUuw8KopOiNtnyY50cWTjd2PKlvOssCg1yXAXyPbJaoQKeMSny)Mb7i1G5jDEGbdhNnoQKmy44soYGLFEJg3OvxsaTIZa)zvc4OssenmmA8K3OXnA1LeqR2(PeR8iLdYfV1RsahvsIOHHrNFEJg3OvxsaTEqU4Twq(e3vjGJkjr0WWOZhVrJB0QljGwDPNyJUOsahvsIOHHrZlEJg3O5nVrddJg2rFBKuwuNbN0REqCSjhbkN(m7OZApA8enSmy44ScWTjd2PKlvOIcXOd6LcJASGNzS0Grahvsct2gSeBuInUbJaed(IQGqM0OrV(E044SXrLu9uYLkurHy0b9sHbZt68adwYLYIN05bf5CQbtoNwaUnzWoLCPcvsIZOgl4fVglnyeWrLKWKTblXgLyJBW81qSrPkyGdPxbhcaNCqIQeWrLKi6LrZJOr5qqQGboKEfCiaCYbjQYTf9YOtVn6x2(bOx0zThD(rVmAyh9TrszrDgCsV6bXXMCeOC6ZSJE9OZpA8XpACC24OsQYDuzJnpB0ff2RUopiAyf9YOHD0P)LI3kOElSrF5vEKIGCfQYiBFax0RVhnEIgF8Jg2r7RHyJsvWahsVcoeao5Gevzoix0zThnEIEz0OCii1BHn6lVYJueKRqvgz7d4IoROXt0lJMhrFk5sfIevxkJEz0P)LI3kOEqU4Tweoir1eKZGtxbH5jDEGlJoR9OXBLNfnSIgwgmpPZdmyGboKIkDbzuJf8YRXsdgbCujjmzBWsSrj24gS0BJ(LTFa6vfeYKgn613JM3OXh)O1XMk6xedf967rZB0lJo92OFz7hGErN1E04XG5jDEGbl5szXt68GICo1GjNtla3MmyidyoiJASG38nwAWiGJkjHjBdwInkXg3GDBKuwuNbN0REqCSjhbkN(m7O3JoprVm60BJ(LTFa6fDw7rNhdMN05bgSKlLfpPZdkY5udMCoTaCBYGHmG5GmQXcEXJXsdgbCujjmzBWsSrj24gmcqm4lQcczsJg967rJJZghvs1tjxQqffIrh0lfgmpPZdmyjxklEsNhuKZPgm5CAb42KbdLBKcJASG38yS0Grahvsct2gSeBuInUbJaed(IQGqM0OrN1E08M3OXnAcqm4lQmcobmyEsNhyWCwYburFgJaQrnwWBEnwAW8KopWG5SKdOYgN8idgbCujjmzBuJf8YFglnyEsNhyWKdCi9k8F5eWTjGAWiGJkjHjBJAud2gJsVnQRglnwWRXsdMN05bgStjxQqgmc4OssyY2OglY3yPbJaoQKeMSnyEsNhyWSDwosuqEwrqUczW2yu6TrDTCu6bIZGXBEnQXc8yS0Grahvsct2gmpPZdmyhKlERfuPlOZGTXO0BJ6A5O0deNbJxJASipglnyEsNhyW2EDEGbJaoQKeMSnQXI8AS0Grahvsct2gmGBtgmFnhKZ8RG8aT8iLT3kXmyEsNhyW81CqoZVcYd0YJu2EReZOg1GHYnsHXsJf8AS0Grahvsct2gSeBuInUb72iPSOodoPx0zThD(rJB0WoA1LeqRWL)BJkDbvjGJkjr0lJ2xdXgLQBed5zUsvMdYfDw7rNF0WYG5jDEGb7G4ytocuo9z2g1yr(glnyEsNhyWGl)3gv6cYGrahvsct2g1ybEmwAW8KopWGH6PCN6Ogmc4OssyY2Og1GLeNXsJf8AS0Grahvsct2gSeBuInUbJhrJYHGupix8wlchKOk3w0lJgLdbPEqCSjhbk6ZaU4RCBrVmAuoeK6bXXMCeOOpd4IVYiBFax0RVhnEQ51G5jDEGb7GCXBTiCqImyChvEeKc8KWGXRrnwKVXsdgbCujjmzBWsSrj24gmuoeK6bXXMCeOOpd4IVYTf9YOr5qqQhehBYrGI(mGl(kJS9bCrV(E04PMxdMN05bgSBHn6lVYJueKRqgmUJkpcsbEsyW41OglWJXsdgbCujjmzBWsSrj24gmEe9PKlvisuDPm6LrlETcg4qkQ0fuvNuUba3G5jDEGbl5szXt68GICo1GjNtla3Mmy0DeirNrnwKhJLgmc4OssyY2G5jDEGbB7FzHr3ZXsKblXgLyJBW4r0QljGwpix8wliFI7QeWrLKWGH8ScG4h1ybVg1yrEnwAWiGJkjHjBdwInkXg3GraIbFr0zThn)H3OxgT41kyGdPOsxqvDs5ga8OxgD6FP4TcQ3cB0xELhPiixHQCBrVm60)sXBfupix8wlchKOAcYzWPl6S2JMxdMN05bgSdIJn5iqrFgWfVrnwWFglnyeWrLKWKTblXgLyJBWeVwbdCifv6cQQtk3aGh9YOHD08iA1LeqRhehBYrGI(mGl(kbCujjIgF8JwDjb06b5I3Ab5tCxLaoQKerJp(rN(xkERG6bXXMCeOOpd4IVYiBFax0zfD(rdldMN05bgSBHn6lVYJueKRqg1yrgXyPbJaoQKeMSnyEsNhyWSDwosuqEwrqUczWsSrj24gmMpIcHdb0QlexLBl6Lrd7OvNbN0Qo2ur)IyOOxp60BJ(LTFa6vfeYKgnA8XpAEe9PKlvisuDPm6LrNEB0VS9dqVQGqM0OrN1E0PTITZpLBJaIOHLblTijPI6m4KEgl41OglwlglnyeWrLKWKTblXgLyJBWy(ikeoeqRUqC1beDwrJh8gn)gnZhrHWHaA1fIRk4yUopi6LrZJOpLCPcrIQlLrVm60BJ(LTFa6vfeYKgn6S2JoTvSD(PCBeqyW8KopWGz7SCKOG8SIGCfYOgl4zglnyeWrLKWKTblXgLyJBWsVn6x2(bOxvqitA0OZAp68Jg3OpLCPcrIQlLgmpPZdmyhKlERfuPlOZOgl4fVglnyeWrLKWKTblXgLyJBWuxsaTEqU4Twq(e3vjGJkjr0lJw8AfmWHuuPlOQoPCdaE0lJgLdbPElSrF5vEKIGCfQYTzW8KopWGDqCSjhbk6ZaU4nQXcE51yPbJaoQKeMSnyj2OeBCdgpIgLdbPEqU4TweoirvUTOxgTo2ur)IyOOxFp68gnUrRUKaA94qvIHWbNQeWrLKi6LrZJOz(ikeoeqRUqCvUndMN05bgSdYfV1IWbjYOgl4nFJLgmc4OssyY2GLyJsSXnyOCiivu5)cj3Pvg5jnA8XpAuoeK6TWg9Lx5rkcYvOk3w0lJg2rJYHGupix8wlOsxqxLBlA8Xp60)sXBfupix8wlOsxqxLr2(aUOxFpAEXB0WYG5jDEGbB715bg1ybV4XyPbJaoQKeMSnyj2OeBCdgkhcs9wyJ(YR8ifb5kuLBZG5jDEGbdv(VOGWXwyuJf8MhJLgmc4OssyY2GLyJsSXnyOCii1BHn6lVYJueKRqvUndMN05bgmuIDel3aGBuJf8MxJLgmc4OssyY2GLyJsSXnyOCii1BHn6lVYJueKRqvUndMN05bgmKHrOY)fg1ybV8NXsdgbCujjmzBWsSrj24gmuoeK6TWg9Lx5rkcYvOk3MbZt68adMds0PmxwsUuAuJf8MrmwAWiGJkjHjBdMN05bgSTpLJ0BwdjkP3EJtDDEqrq4mjYGLyJsSXny8i6tjxQqKO6sz0lJw8AfmWHuuPlOQoPCdaE0lJMhrJYHGuVf2OV8kpsrqUcv52IEz0eGyWxufeYKgn6S2Jgp41Griiusla3MmyPfj5RShmPcQ0p1Ogl4DTyS0Grahvsct2gmpPZdmy(AoiN5xb5bA5rkBVvIzWsSrj24gmEenkhcs9GCXBTiCqIQCBrVm60)sXBfuVf2OV8kpsrqUcvzKTpGl61JMx8AWaUnzW81CqoZVcYd0YJu2EReZOgl4LNzS0Grahvsct2gmpPZdmy(bHJdORW818Ss6zU0GLyJsSXnyccLdbPY818Ss6zUSiiuoeKQ4TcIgF8Jg2rJYHGuVf2OV8kpsrqUcv52IgF8JwqOCii10deCjDWHkdixrqOCiivUTOHv0lJg2rRodoPviYLkuDlPrVE04H3OXh)OvNbN0Qo2ur)IyOOxpA(dVrdldgWTjdMFq44a6kmFnpRKEMlnQXI8XRXsdgbCujjmzBWaUnzWSxi8ROUCoBhyW8KopWGzVq4xrD5C2oWOglYNxJLgmc4OssyY2GLyJsSXnyOCii1BHn6lVYJueKRqvUTOXh)O1XMk6xedf96rNpEnyEsNhyW4oQmkzFg1OgStjxQqLK4mwASGxJLgmc4OssyY2G9BgSJudMN05bgmCC24OsYGHJl5idw6FP4TcQhKlERfHdsunb5m40vqyEsNh4YOZApAERzK8AWWXzfGBtgSdsuuigDqVuyuJf5BS0Grahvsct2gSeBuInUbJhrJJZghvs1dsuuigDqVue9YOtVn6x2(bOxvqitA0OZkAEJEz0ccLdbPImarXk55a0Dvgz7d4IE9O51G5jDEGbdhhmhKrnwGhJLgmc4OssyY2G5jDEGbB7FzHr3ZXsKbJ4hL5f3(5aQblp41GH8ScG4h1ybVg1yrEmwAWiGJkjHjBdwInkXg3GraIbFr0zThDEWB0lJMaed(IQGqM0OrN1E08I3OxgnpIghNnoQKQhKOOqm6GEPi6LrNEB0VS9dqVQGqM0OrNv08g9YOfekhcsfzaIIvYZbO7QmY2hWf96rZRbZt68ad2b5I3Qnjfg1yrEnwAWiGJkjHjBd2VzWosnyEsNhyWWXzJJkjdgoUKJmyP3g9lB)a0RkiKjnA0zThDEmy44ScWTjd2bjkP3g9lB)a0ZOgl4pJLgmc4OssyY2G9BgSJudMN05bgmCC24OsYGHJl5idw6Tr)Y2pa9QcczsJg967rZB04gD(rddJ2xdXgLQkevqg2PfHdsuLaoQKegSeBuInUbdhNnoQKQChv2yZZgDrH9QRZdIEz0WoA1LeqRGboKEQlZrSkbCujjIgF8JwDjb0QWz5khKlERvc4OssenSmy44ScWTjd2bjkP3g9lB)a0ZOglYiglnyeWrLKWKTblXgLyJBWWXzJJkP6bjkP3g9lB)a0l6Lrd7O5r0QljGwfolx5GCXBTsahvsIOXh)OfVwbdCifv6cQYiBFax0zThDEJg3OvxsaTECOkXq4Gtvc4OssenSIEz0WoACC24OsQEqIIcXOd6LIOXh)Or5qqQ3cB0xELhPiixHQmY2hWfDw7rZBn)OXh)OVnsklQZGt6vpio2KJaLtFMD0zThDEIEz0P)LI3kOElSrF5vEKIGCfQYiBFax0zfnV4nAyf9YOHD0(Ai2OufmWH0RGdbGtoirvMdYf96rJNOXh)Or5qqQGboKEfCiaCYbjQYTfnSmyEsNhyWoix8wlchKiJASyTyS0Grahvsct2gSeBuInUbdhNnoQKQhKOKEB0VS9dqVOxgTo2ur)IyOOxp60)sXBfuVf2OV8kpsrqUcvzKTpGl6LrZJOz(ikeoeqRUqCvUndMN05bgSdYfV1IWbjYOg1GHmG5GmwASGxJLgmc4OssyY2GH8ScG4h1ybVgmpPZdmyB)llm6EowImQXI8nwAWiGJkjHjBdwInkXg3GHYHGubdCi9k4qa4KdsuLBZG5jDEGbJWzUeXCLmQXc8yS0Grahvsct2gSeBuInUbd2rZJOvxsaTkCwUYb5I3ALaoQKerJp(rZJOr5qqQhKlERfHdsuLBlAyf9YO1XMk6xedfn)gnJS9bCrNv08x0lJMr2(aUOxpADs5k6ytrddJoFdMN05bgmWahsrLUGmQXI8yS0Grahvsct2gmpPZdmyGboKIkDbzWsSrj24gmEenooBCujv5oQSXMNn6Ic7vxNhe9YOVnsklQZGt6vpio2KJaLtFMD0zThD(rVmAyhTVgInkvbdCi9k4qa4KdsuLaoQKerJp(rZJO91qSrPkJ2KtY1baVCqU4TEvc4Ossen(4h9TrszrDgCsV6bXXMCeOC6ZSJMFJ2t6GdveVwbdCifv6ck6S2Jo)OHv0lJMhrJYHGupix8wlchKOk3w0lJwhBQOFrmu0zThnSJoVrJB0Wo68JgggD6Tr)Y2pa9IgwrdROxgnJqy0b5OsYGLwKKurDgCspJf8AuJf51yPbJaoQKeMSnyj2OeBCdgJS9bCrVE0P)LI3kOElSrF5vEKIGCfQYiBFax04gnV4n6LrN(xkERG6TWg9Lx5rkcYvOkJS9bCrV(E05n6LrRJnv0VigkA(nAgz7d4IoROt)lfVvq9wyJ(YR8ifb5kuLr2(aUOXn68AW8KopWGbg4qkQ0fKrnwWFglnyeWrLKWKTblXgLyJBWq5qqQ3cB0xELhPiixHQCBrVmAyhnpIwDjb0QWz5khKlERvc4Ossen(4hnkhcs9GCXBTiCqIQCBrdldMN05bgSJsmslkLGadmahzuJfzeJLgmc4OssyY2GLyJsSXny3gjLf1zWj9QhehBYrGYPpZo6S2Jo)OXnA1LeqRcNLRCqU4TwjGJkjr04gT6scOvWahsp1L5iwLaoQKegmpPZdmyhLyKwukbbgyaoYOglwlglnyEsNhyWiCMlrmxjdgbCujjmzBuJAudgoe7MhySiF8YlpdVzeEZVMpE4fpgmRodma4Nbdg1E7zkjIETeTN05brlNtVASYGTXEKrsgmygnghQkjDr0z0hohfRGz0qQUDz8mZe(OqCO10BN5n2CsxNhKyoIM5n2PmJvWm6vCYfrNpV8fD(4LxEw08B08YZY44zTeRIvWmAEcYbWPlJhRGz08B0RvHGerZ)Fs5Iw)OfeIZj1O9KopiA5CAnwbZO53OZOK9JdjIwDgCslds0PhigDEq0piAEoNLJerJ8SOZa5kunwbZO53OxRcbjIoJDu0WOkzF1yvScMrddMFOeNsIOrjKNrrNEBuxJgLGpGRg9AnLOn9Ig8a(fYz2iCYO9Kop4I(bYf1yfmJ2t68GRUXO0BJ66oI0VCXkygTN05bxDJrP3g1vC3Z05GBta115bXkygTN05bxDJrP3g1vC3Ze5FrScMrJb8Td61Oz(iIgLdbHerFQRx0OeYZOOtVnQRrJsWhWfTderVXi(D7vDaWJEUOfpGQXkygTN05bxDJrP3g1vC3Z8a(2b9A5uxVyLN05bxDJrP3g1vC3Z8uYLkuSYt68GRUXO0BJ6kU7zA7SCKOG8SIGCfIVngLEBuxlhLEG425nVXkpPZdU6gJsVnQR4UN5b5I3Abv6c64BJrP3g11YrPhiUDEJvEsNhC1ngLEBuxXDpZTxNheR8Kop4QBmk92OUI7EMChvgLS5d420UVMdYz(vqEGwEKY2BLyXQyfmJggm)qjoLert4qSfrRJnfTcrr7j9zrpx0oo(iDujvJvWm6mkDk5sfk6bj6T)UbvsrdBWhnoCsaXCujfnbi7HUOhq0P3g1vyfR8Kop4WDpZCtkhFdYopoLCPcrIk7HZrXkpPZdU9tjxQqXkygnpbrPCrZtz4I21Org2PXkpPZdoC3Zm5szXt68GICoLpGBt7jXfRGz0zuoq0iCs5IOpRJMGOlA9JwHOOXuYLkejIoJ(QRZdIg2OlIw8daE03Zx0JgnYZs0f92)Ybap6bjAWRqdaE0ZfTJJpshvsWQgR8Kop4WDptghO4jDEqroNYhWTP9tjxQqKGVbz)uYLkejQUugRGz0R1Tn5IOTyGdPOsxqr7A05JB080AhTGJna4rRqu0id70O5fVrFu6bIJVODeLyrRqUgDEWnAEATJEqIE0Oj(zBy0fT1rHgq0kefnG4hnAE(8ugI(zrpx0GxJMBlw5jDEWH7EMGboKIkDbX3GSRJnv0Vigkl(BjJS9bCRdpjQ2o)Sm92OFz7hGEzTNh(f26ytRZlEHfmm)yfmJM)dqUi6eKdGtrZE115brpirBLIgYXHIEJnpB0ff2RUopi6J0ODGiABoPoBskA1zWj9IMBRgR8Kop4WDptCC24OsIpGBt7Chv2yZZgDrH9QRZd4dhxYr7BS5zJUOWE115blVnsklQZGt6vpio2KJaLtFMDw75hRGz0RnBE2OlIoJ(QRZd45nA(FKcd6Ig(GdfThDI5Br7OpNgnbig8frJ8SOvik6tjxQqrZtz4Ig2OCJuqSOpDKYOz0Trjn6rHvnAEEWTXx0JgDYbrJsrRqUg9n2BsQgR8Kop4WDpZKlLfpPZdkY5u(aUnTFk5sfQKehFdYoooBCujv5oQSXMNn6Ic7vxNheRGz0zSJerRF0cczau0wHiq06hn3rrFk5sfkAEkdx0plAuUrki2fR8Kop4WDptCC24OsIpGBt7NsUuHkkeJoOxk4dhxYr75NxCvxsaTIZa)zvc4OssadXtEXvDjb0QTFkXkps5GCXB9QeWrLKagMFEXvDjb06b5I3Ab5tCxLaoQKeWW8XlUQljGwDPNyJUOsahvscyiV4fxEZlme23gjLf1zWj9QhehBYrGYPpZoRD8aRyfmJMNEWncIfn3na4r7rJPKlvOO5PmeTvicenJ8e0aGhTcrrtaIbFr0keJoOxkIvEsNhC4UNzYLYIN05bf5CkFa3M2pLCPcvsIJVbzNaed(IQGqM0ORVJJZghvs1tjxQqffIrh0lfXkygTfdCifg0fnmcbGtoirz8OTyGdPOsxqrJsipJIgBHn6lVODnA5BnAEATJw)OtVn6aOOjNjxenJqy0bfT1rHIgoP6aGhTcrrJYHGen3wn61Q8(OLV1O5P1oAbhBaWJgBHn6lVOrj1krGOZGds0fT1rHIgprBbmsnw5jDEWH7EMGboKIkDbX3GS7RHyJsvWahsVcoeao5GevjGJkjXsEGYHGubdCi9k4qa4KdsuLBBz6Tr)Y2pa9YAp)LW(2iPSOodoPx9G4ytocuo9z2RNp(4JJZghvsvUJkBS5zJUOWE115bWAjSt)lfVvq9wyJ(YR8ifb5kuLr2(aU13Xd(4dBFneBuQcg4q6vWHaWjhKOkZb5YAhplr5qqQ3cB0xELhPiixHQmY2hWLfEwYJtjxQqKO6s5Y0)sXBfupix8wlchKOAcYzWPRGW8KopWLzTJ3kpdwWkwbZOHXdyoOODn68GB0whf650OZagFrNxCJ26OqrNbSOH9ZP3iOOpLCPcbRyLN05bhU7zMCPS4jDEqroNYhWTPDKbmheFdYE6Tr)Y2pa9QcczsJU(oV4JVo2ur)IyO135Dz6Tr)Y2pa9YAhpXkygn)BuOOZaw0U8(OrgWCqr7A05b3OD4(aonAIF8KkxeDEIwDgCsVOH9ZP3iOOpLCPcbRyLN05bhU7zMCPS4jDEqroNYhWTPDKbmheFdY(TrszrDgCsV6bXXMCeOC6ZS3ZZY0BJ(LTFa6L1EEIvWm6m2rr7rJYnsbXI2kebIMrEcAaWJwHOOjaXGViAfIrh0lfXkpPZdoC3Zm5szXt68GICoLpGBt7OCJuW3GStaIbFrvqitA013XXzJJkP6PKlvOIcXOd6LIyfmJM)3BLon6n28Srxe9aI2LYOFKOvik616AZ)lAuk5Chf9OrNCUJUO9O55Ztziw5jDEWH7EMol5aQOpJraLVbzNaed(IQGqM0OzTZBEXLaed(IkJGtGyLN05bhU7z6SKdOYgN8OyLN05bhU7zkh4q6v4)YjGBtanwfRGz0zZnsbXUyLN05bxfLBKI9dIJn5iq50NzZ3GSFBKuwuNbN0lR98Xf2QljGwHl)3gv6cQsahvsIL(Ai2OuDJyipZvQYCqUS2ZhwXkpPZdUkk3if4UNjC5)2OsxqXkpPZdUkk3if4UNjQNYDQJgRIvWmAE6FP4TcUyfmJoJDu0zWbjk6hbHFHNerJsipJIwHOOrg2PrJbXXMCeiAm9z2rJWE7OT8zax8rNEB6IEa1yLN05bxnjU9dYfV1IWbjIpUJkpcsbEsSZlFdYopq5qqQhKlERfHdsuLBBjkhcs9G4ytocu0NbCXx52wIYHGupio2KJaf9zax8vgz7d4wFhp18gRGz0WoJbK0Dr7sg5IfrZTfnkLCUJI2kfT(FUOXGCXBnAy8N4oyfn3rrJTWg9Lx0pcc)cpjIgLqEgfTcrrJmStJgdIJn5iq0y6ZSJgH92rB5ZaU4Jo920f9aQXkpPZdUAsC4UN5TWg9Lx5rkcYvi(4oQ8iif4jXoV8ni7OCii1dIJn5iqrFgWfFLBBjkhcs9G4ytocu0NbCXxzKTpGB9D8uZBSYt68GRMehU7zMCPS4jDEqroNYhWTPD6ocKOJVbzNhNsUuHir1LYLIxRGboKIkDbv1jLBaWJvWm61(Fz0iplAlFgWfF0BmIFX(meT1rHIgdkdrZixSiARqeiAWRrZ4aGbapAmyCnw5jDEWvtId39m3(xwy09CSeXhYZkaIF0DE5Bq25H6scO1dYfV1cYN4UkbCujjIvWm6m2rrB5ZaU4JEJrrJ9ziARqeiARu0qoou0kefnbig8frBfIuiIfnc7TJE7F5aGhT1rHEonAmyC0plA(VCNgnCcqmxkxuJvEsNhC1K4WDpZdIJn5iqrFgWfpFdYobig8fzTZF4DP41kyGdPOsxqvDs5ga8LP)LI3kOElSrF5vEKIGCfQYTTm9Vu8wb1dYfV1IWbjQMGCgC6YAN3yfmJoJDu0ylSrF5f9dIo9Vu8wbrdBhrjw0id70OTyGdPOsxqWkAoGKUlARu0oJIg(pa4rRF0B)w0w(mGl(ODGiAXhn41OHCCOOXGCXBnAy8N4UASYt68GRMehU7zElSrF5vEKIGCfIVbzx8AfmWHuuPlOQoPCda(syZd1LeqRhehBYrGI(mGl(kbCujjWhF1LeqRhKlERfKpXDvc4OssGp(P)LI3kOEqCSjhbk6ZaU4RmY2hWLv(WkwbZOHrrI2fIlANrrZTXx0hy2OOvik6hqrBDuOOLVv60OT0YmuJoJDu0wHiq0IfdaE0i(PelAfYbrZtRD0cczsJg9ZIg8A0NsUuHir0whf650ODWIO5P1UgR8Kop4QjXH7EM2olhjkipRiixH4lTijPI6m4KE78Y3GSZ8ruiCiGwDH4QCBlHT6m4Kw1XMk6xedTE6Tr)Y2pa9QcczsJIp(84uYLkejQUuUm92OFz7hGEvbHmPrZApTvSD(PCBeqaRyfmJggfjAWhTlex0whPmAXqrBDuObeTcrrdi(rJgp494lAUJIMNdjdr)GOr)7I26OqpNgTdwenpT2r7ar0Gp6tjxQq1yLN05bxnjoC3Z02z5irb5zfb5keFdYoZhrHWHaA1fIRoGSWdE5xMpIcHdb0QlexvWXCDEWsECk5sfIevxkxMEB0VS9dqVQGqM0OzTN2k2o)uUnciIvEsNhC1K4WDpZdYfV1cQ0f0X3GSNEB0VS9dqVQGqM0OzTNpUNsUuHir1LYyfmJM)nku0yWy(IEqIg8A0UKrUyr0Ihq8fn3rrB5ZaU4J26OqrJ9ziAUTASYt68GRMehU7zEqCSjhbk6ZaU45Bq2vxsaTEqU4Twq(e3vjGJkjXsXRvWahsrLUGQ6KYna4lr5qqQ3cB0xELhPiixHQCBXkpPZdUAsC4UN5b5I3Ar4GeX3GSZduoeK6b5I3Ar4Gev52wQJnv0VigA998IR6scO1JdvjgchCQsahvsIL8G5JOq4qaT6cXv52IvEsNhC1K4WDpZTxNhW3GSJYHGurL)lKCNwzKNu8XhLdbPElSrF5vEKIGCfQYTTe2OCii1dYfV1cQ0f0v52Wh)0)sXBfupix8wlOsxqxLr2(aU135fVWkw5jDEWvtId39mrL)lkiCSf8ni7OCii1BHn6lVYJueKRqvUTyLN05bxnjoC3ZeLyhXYna48ni7OCii1BHn6lVYJueKRqvUTyLN05bxnjoC3ZezyeQ8FbFdYokhcs9wyJ(YR8ifb5kuLBlw5jDEWvtId39mDqIoL5YsYLs(gKDuoeK6TWg9Lx5rkcYvOk3wSYt68GRMehU7zYDuzuYMpcbHsAb420EArs(k7btQGk9t5Bq25XPKlvisuDPCP41kyGdPOsxqvDs5ga8L8aLdbPElSrF5vEKIGCfQYTTKaed(IQGqM0OzTJh8gR8Kop4QjXH7EMChvgLS5d420UVMdYz(vqEGwEKY2BLy8ni78aLdbPEqU4TweoirvUTLP)LI3kOElSrF5vEKIGCfQYiBFa368I3yLN05bxnjoC3ZK7OYOKnFa3M29dchhqxH5R5zL0ZCjFdYUGq5qqQmFnpRKEMllccLdbPkERa8Xh2OCii1BHn6lVYJueKRqvUn8XxqOCii10deCjDWHkdixrqOCiivUnyTe2QZGtAfICPcv3s664Hx8XxDgCsR6ytf9lIHwN)WlSIvEsNhC1K4WDptUJkJs28bCBA3EHWVI6Y5SDqScMrNbcX5KA0iUuI6PCrJ8SO5ohvsrpkzFz8OZyhfT1rHIgBHn6lVOFKOZa5kunw5jDEWvtId39m5oQmkzF8ni7OCii1BHn6lVYJueKRqvUn8XxhBQOFrm065J3yvScMrdd(ocKOlw5jDEWvP7iqIU90dseqzUsIcI0TPyLN05bxLUJaj6WDptu5)IYJuuiQqaYErSYt68GRs3rGeD4UNjCoNjghuEKIVgI9kuSYt68GRs3rGeD4UNjYN4osu81qSrPck528ni7W(2iPSOodoPx9G4ytocuo9z2zTNp(4Z8ruiCiGwDH4Qdil(dVWAjps)lfVvq9wyJ(YR8ifb5kuLBBjpq5qqQ3cB0xELhPiixHQCBljaXGVOkiKjnAw74bVXkpPZdUkDhbs0H7EMBCSbzXaGxqL(P8ni73gjLf1zWj9QhehBYrGYPpZoR98XhFMpIcHdb0QlexDazXF4nw5jDEWvP7iqIoC3ZuHOcha95aIcYZseFdYokhcsLrPCs6UcYZsuLBdF8r5qqQmkLts3vqEwIkPNdOeREQNYToV4nw5jDEWvP7iqIoC3ZKnBBsQmGYT5jkw5jDEWvP7iqIoC3Z06ZKcCObuy09ahKi(gKDuoeKQCqiu5)I6PEk364jw5jDEWvP7iqIoC3Z0MSF2IYJuKCPruemYTp(gKDcqm4lwpp4Djkhcs9wyJ(YR8ifb5kuLBlwfRGz0W4bmheXUyLN05bxfzaZbTV9VSWO75yjIpKNvae)O78gRGz0WGXzUeXCLIgYVOHg4q0PrVXMNn6IOToku0wmWHuyqx0Wieao5Gefn3wnw5jDEWvrgWCq4UNjHZCjI5kX3GSJYHGubdCi9k4qa4KdsuLBlwbZO5)t0w0CBrBXahsrLUGIEqIE0ONlAh950O1pAghi6NtRrNHpAWRrZDu0wKD0co2aGhDgCqI4l6bjA1Leqjr0dq)OZGZYfngKlER1yLN05bxfzaZbH7EMGboKIkDbX3GSdBEOUKaAv4SCLdYfV1kbCujjWhFEGYHGupix8wlchKOk3gSwQJnv0VigIFzKTpGll(BjJS9bCRRtkxrhBcgMFScMrZZXj1r8Qoa4r)C6nck6m4Gef9dIwDgCsVOvixJ26iLrlhCOOrEw0kefTGJ568GOFKOTyGdPOsxq8fnJqy0bfTGJna4rV5abzpPA08CCsDeVgTFrlFa8O9l68XnA1zWj9Iw8rdEnAihhkAlg4qkQ0fu0CBrBDuOOZO0MCsUoa4rJb5I36fnS5as6UOx8Crd54qrBXahsHbDrdJqa4Kdsu06)WQgR8Kop4QidyoiC3ZemWHuuPli(slssQOodoP3oV8ni78ahNnoQKQChv2yZZgDrH9QRZdwEBKuwuNbN0REqCSjhbkN(m7S2ZFjS91qSrPkyGdPxbhcaNCqIQeWrLKaF85HVgInkvz0MCsUoa4LdYfV1Rsahvsc8X)2iPSOodoPx9G4ytocuo9z28RN0bhQiETcg4qkQ0fuw75dRL8aLdbPEqU4TweoirvUTL6ytf9lIHYAh25fxyNpmm92OFz7hGEWcwlzecJoihvsXkygDgLqy0bfTfdCifv6ckAYzYfrpirpA0whPmAIF2ggfTGJna4rJTWg9Lxn6m8rRqUgnJqy0bf9Gen2NHOHt6fnJCXIOhq0kefnG4hn68E1yLN05bxfzaZbH7EMGboKIkDbX3GSZiBFa36P)LI3kOElSrF5vEKIGCfQYiBFahU8I3LP)LI3kOElSrF5vEKIGCfQYiBFa3675DPo2ur)Iyi(Lr2(aUSs)lfVvq9wyJ(YR8ifb5kuLr2(aoCZBScMrJrjgPrBjLGadmahfTGJna4rJTWg9LxnA(3OqrNbNLlAmix8wJ(bYfrl4ydaE0yqU4TgDgCqIIg2CaDKrRqm6GEPi6benG4hnA5aiyvJvEsNhCvKbmheU7zEuIrArPeeyGb4i(gKDuoeK6TWg9Lx5rkcYvOk32syZd1LeqRcNLRCqU4TwjGJkjb(4JYHGupix8wlchKOk3gSIvWmA(3OqrtGNdou0QZGt6fTlT6lUO5okAmkzjLI(brZtzOgR8Kop4QidyoiC3Z8OeJ0IsjiWadWr8ni73gjLf1zWj9QhehBYrGYPpZoR98XvDjb0QWz5khKlERvc4OssGR6scOvWahsp1L5iwLaoQKeXkpPZdUkYaMdc39mjCMlrmxPyvScMrJPKlvOO5P)LI3k4IvWmAEEsYnIfnmIZghvsXkpPZdU6PKlvOssC744SXrLeFa3M2pirrHy0b9sbF44soAp9Vu8wb1dYfV1IWbjQMGCgC6kimpPZdCzw78wZi5nwbZOHrCWCqrZbK0DrBLI2zu0o6ZPrRF0jFl6heDgCqIIob5m40vJM)dqUiARqeiAy8aerZ)iphGUl65I2rFonA9JMXbI(50ASYt68GREk5sfQKehU7zIJdMdIVbzNh44SXrLu9GeffIrh0lfltVn6x2(bOxvqitA0S4DPGq5qqQidquSsEoaDxLr2(aU15nwbZOx7)LrJ8SOXGCXB1MKIOXnAmix8wpLn5OO5as6UOTsr7mkAh950O1p6KVf9dIodoirrNGCgC6QrZ)bixeTvicenmEaIO5FKNdq3f9Cr7OpNgT(rZ4ar)CAnw5jDEWvpLCPcvsId39m3(xwy09CSeXhYZkaIF0DE5J4hL5f3(5a6EEWBSYt68GREk5sfQKehU7zEqU4TAtsbFdYobig8fzTNh8UKaed(IQGqM0OzTZlExYdCC24OsQEqIIcXOd6LILP3g9lB)a0RkiKjnAw8UuqOCiivKbikwjphGURYiBFa368gRGz080AhnJGb4ggztanJhDgCqII21OLV1O5P1oA0frlieNtQ1yLN05bx9uYLkujjoC3ZehNnoQK4d420(bjkP3g9lB)a0JpCCjhTNEB0VS9dqVQGqM0OzTNNyfmJMNw7Ozema3WiBcOz8OZGdsu0pqUiAuc5zu0idyoiIDrpirBLIgYXHI2T3IwDjb0lAhiIEJnpB0frZE115b1yLN05bx9uYLkujjoC3ZehNnoQK4d420(bjkP3g9lB)a0JpCCjhTNEB0VS9dqVQGqM0ORVZlU5dd91qSrPQcrfKHDAr4GevjGJkjbFdYoooBCujv5oQSXMNn6Ic7vxNhSe2QljGwbdCi9uxMJyvc4OssGp(QljGwfolx5GCXBTsahvscyfRGz08VrHIodolx0yqU4Tg9dKlIodoirrBfIarBXahsrLUGI26iLrFQViAUTA0zSJIwWXga8OXwyJ(Yl6NfTJ(4qrRqm6GEPOgn)ZhnAKNfTfWirJYHGeT1rHIgpwaJuJvEsNhC1tjxQqLK4WDpZdYfV1IWbjIVbzhhNnoQKQhKOKEB0VS9dqVLWMhQljGwfolx5GCXBTsahvsc8Xx8AfmWHuuPlOkJS9bCzTNxCvxsaTECOkXq4Gtvc4OssaRLWghNnoQKQhKOOqm6GEPaF8r5qqQ3cB0xELhPiixHQmY2hWL1oV18Xh)BJKYI6m4KE1dIJn5iq50NzN1EEwM(xkERG6TWg9Lx5rkcYvOkJS9bCzXlEH1sy7RHyJsvWahsVcoeao5Gevzoi364bF8r5qqQGboKEfCiaCYbjQYTbRyfmJoBogiAgz7dyaWJodoirx0OeYZOOvikA1zWjnAXqx0ds0yFgI26dGbPrJsrZixSi6beTo2unw5jDEWvpLCPcvsId39mpix8wlchKi(gKDCC24OsQEqIs6Tr)Y2pa9wQJnv0VigA90)sXBfuVf2OV8kpsrqUcvzKTpGBjpy(ikeoeqRUqCvUTyvScMrJPKlviseDg9vxNheRGz0WOirJPKlvOmXXbZbfTZOO524lAUJIgdYfV1tztokA9JgLaeYOrJWE7Ovik6n)UbhkA0hWDr7ar0W4biIM)rEoaDhFrt4qGOhKOTsr7mkAxJ225NO5P1oAyJWE7Ovik6ngLEBuxJMNdjdWQgR8Kop4QNsUuHiX(b5I36PSjhX3GSdB1LeqRidquSsEoaDxLaoQKe4J)TrszrDgCsV6bXXMCeOC6ZSxhpWAjSr5qqQNsUuHQCB4JpkhcsfhhmhuLBdwXkygnmEaZbfTRrJhCJMNw7OTok0ZPrNbSOZm68GB0whfk6mGfT1rHIgdIJn5iq0w(mGl(Or5qqIMBlA9J2X5hr03BtrZtRD0w9tPOVr5CDEWvJvEsNhC1tjxQqKa39mtUuw8KopOiNt5d420oYaMdIVbzhLdbPEqCSjhbk6ZaU4RCBltVn6x2(bOxvqitA013ZpwbZOxRY7J(CekA9JgzaZbfTRrNhCJMNw7OToku0e)4jvUi68eT6m4KE1OHnMBtr7x0pNEJGI(uYLkufwXkpPZdU6PKlvisG7EMjxklEsNhuKZP8bCBAhzaZbX3GSFBKuwuNbN0REqCSjhbkN(m798Sm92OFz7hGEzTNNyfmJggpG5GI21OZdUrZtRD0whf650OZagFrNxCJ26OqrNbm(I2bIO5VOToku0zalAhrjw0WioyoOOFw0wcrrdJh2PrNbhKOODGiAWhDgCwUOXGCXBnACJg8rJXHQedHdofR8Kop4QNsUuHibU7zMCPS4jDEqroNYhWTPDKbmheFdYE6Tr)Y2pa9QcczsJU(oV8lSvxsaTkiAJyLtzU6Wj7kbCujjwcBuoeKkooyoOk3g(47RHyJsvfIkid70IWbjQsahvsIL8qDjb0QWz5khKlERvc4OssSKhQljGwpouLyiCWPkbCujjwEBKuwuNbN0REqCSjhbkN(m71XdSGvScMrNXokAE(Y)TrLUGI(XHyrJb5I36PSjhfTderJPpZoARJcfD(4g9AtmKN5kfTRrNF0plAjDx0QZGt6vJvEsNhC1tjxQqKa39mHl)3gv6cIVbz3xdXgLQBed5zUsvMdYL1E(lVnsklQZGt6vpio2KJaLtFM9675hRGz0Rvn68JwDgCsVOToku0yuIrA0wsjiWadWrrNJOTO52Iggpar08pYZbO7IgDr0Pfj5aGhngKlERNYMCunw5jDEWvpLCPcrcC3Z8GCXB9u2KJ4lTijPI6m4KE78Y3GSRUKaA9OeJ0IsjiWadWrvc4OssSuDjb0kYaefRKNdq3vjGJkjXsbHYHGurgGOyL8Ca6UkJS9bCRZ7YBJKYI6m4KE1dIJn5iq50NzVN)sDSPI(fXq8lJS9bCzXFXkygn)BuONtJodeTrSOXuMRoCYoAhiIgprNrDqUl6hj6SLUGIEarRqu0yqU4TErpA0ZfT1NPqrZDdaE0yqU4TEkBYrr)GOXt0QZGt6vJvEsNhC1tjxQqKa39mpix8wpLn5i(gKDEOUKaAvq0gXkNYC1Ht2vc4OssS0xdXgLQOsxqLbuuiQCqU4TEvMdYTJNL3gjLf1zWj9QhehBYrGYPpZEhpXkygnm(zrVXMNn6IOzV668a(IM7OOXGCXB9u2KJI(XHyrJPpZoAEHv0whfkA(hpx0oCFaNgn3w06hDEIwDgCsp(IoFyf9GenmM)f9CrZ4aGbap6hbjAy)GODWIOD7NdOr)irRodoPhS4l6NfnEGv06hTTZpJ9SgkASpdrt8JsGBEq0whfkAyuaHZOo6ihDr0piA8eT6m4KErd78eT1rHIo7rXGvnw5jDEWvpLCPcrcC3Z8GCXB9u2KJ4Bq2XXzJJkPk3rLn28SrxuyV668GLWwDjb0kYaefRKNdq3vjGJkjXsbHYHGurgGOyL8Ca6UkJS9bCRZl(4RUKaA1k5BpW2pLyvc4OssS82iPSOodoPx9G4ytocuo9z2RVNh8X3xdXgLQdGWzuhDKJUOsahvsILOCii1BHn6lVYJueKRqvUTL3gjLf1zWj9QhehBYrGYPpZE9D8GRVgInkvrLUGkdOOqu5GCXB9QeWrLKawXkpPZdU6PKlvisG7EMhehBYrGYPpZMVbz)2iPSOodoPxw74jw5jDEWvpLCPcrcC3Z8GCXB9u2KJmy3gLmwKp)XRrnQXaa]] )


end
