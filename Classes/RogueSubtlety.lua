-- RogueSubtlety.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State


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
        }
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
        shuriken_combo = {
            id = 245640,
            duration = 15,
            max_stack = 4,
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

    local stealth = {
        rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
        mantle  = { "stealth", "vanish" },
        all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld" }
    }

    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            local auras = stealth[ k ]
            if not auras then return false end

            for _, aura in pairs( auras ) do
                if buff[ aura ].up then return true end
            end

            return false
        end,
    } ) )

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


    -- Okay, so real-talk:  Subtlety exposes some weaknesses in the flow of the engine based on APLs.
    -- Rechecks are generally intended to be based on ability entries, but Sub has several small windows that are used to determine which action list to call.
    -- So the half-ass measure here is to include APL rechecks in the abilities found in different APLs.
    local apl_stealth_cds = setfenv( function (... ) return energy[ "time_to_" .. ( variable.stealth_threshold or "max" ) ], ... end, state )
    local apl_build = setfenv( function ( ... ) return energy[ "time_to_" .. ( ( variable.stealth_threshold - 40 * ( ( talent.alacrity.enabled or talent.shadow_focus.enabled or talent.master_of_shadows.enabled ) and 1 or 0 ) ) or "max" ) ], ... end, state )
    local apl_stealthed_finish = setfenv( function ( ... ) return combo_points[ "time_to_" .. ( ( combo_points.time_to_max - 1 - ( ( talent.deeper_stratagem.rank and buff.vanish.up ) and 1 or 0 ) ) ) ], target.time_to_die - 1, combo_points.time_to_3, combo_points.time_to_4, ... end, state )


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
            
            recheck = apl_build( energy[ "time_to_" .. ceil( energy.max - ( variable.stealth_threshold or 0 ) - 40 * ( not ( talent.alacrity.enabled or talent.shadow_focus.enabled or talent.master_of_shadows.enabled ) and 1 or 0 ) ) ] ),
            handler = function ()
            	applyDebuff( 'target', "shadows_grasp", 8 )
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
            	applyBuff( 'evasion', 10)
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
            recheck = apl_stealthed_finish,
            handler = function ()
            	if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end
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
                applyBuff( 'feint', 5)
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
            
            recheck = apl_build,
            handler = function ()
            applyDebuff( 'target', "shadows_grasp", 8 )
            	if buff.stealth.up then
            		removeBuff( "stealth" )
            	end
            	gain( buff.shadow_blades.up and 2 or 1, 'combo_points')
            end,
        },
        

        kick = {
            id = 1766,
            cast = 0,
            cooldown = 15,
            gcd = "off",
            
            toggle = 'interrupt', 

            startsCombat = true,
            texture = 132219,
            
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
            
            startsCombat = true,
            texture = 1373907,

            usable = function () return combo_points.current > 0 end,
            recheck = function () return apl_stealthed_finish( buff.shadow_dance.remains, remains - tick_time * 2, buff.symbols_of_death.remains, remains - ( duration * 0.3 ) ) end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end
                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )
                applyDebuff( "target", "nightblade", 8 + 2 * ( combo - 1 ) )

                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
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
            recheck = apl_stealthed_finish,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then addStack( "alacrity", 20, 1 ) end                
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },
        

        shadow_blades = {
            id = 121471,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 376022,
            
            handler = function ()
            	applyDebuff( 'shadow_blades', 20 )
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
            recheck = function () return apl_stealth_cds( remains, buff.subterfuge.remains, ( 1.75 - charges_fractional ) * recharge, target.time_to_die - cooldown.symbols_of_death.remains ) end,
            handler = function ()
                applyBuff( "shadow_dance" )
                if talent.shot_in_the_dark.enabled then applyBuff( "shot_in_the_dark" ) end
            	if talent.master_of_shadows.enabled then applyBuff( "master_of_shadows", 3 ) end
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
            
            spend = function () return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 1373912,
            
            usable = function () return stealthed.all end,
            handler = function ()
                gain( buff.shadow_blades.up and 3 or 2, 'combo_points' )
                
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
            
            recheck = apl_build,
            handler = function ()
            	gain( active_enemies + ( buff.shadow_blades.up and 1 or 0 ), 'combo_points')
            	addStack( "shuriken_combo", 15, active_enemies - 1 )
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
            	gain( buff.shadow_blades.up and (active_enemies + 1) or (active_enemies), 'combo_points')
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
            
            recheck = function () return apl_stealth_cds( debuff.find_weakness.remains - 1, debuff.find_weakness.remains ) end,
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

        usable = function () return boss and race.night_elf end,
        recheck = function () return apl_stealth_cds( energy.time_to_40, energy[ "time_to_" .. energy.max - 10 ], debuff.find_weakness.remains - 1, debuff.find_weakness.remains ) end,
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
    
        package = "Subtlety",
    } )


    spec:RegisterPack( "Subtlety", 20180716.2100, [[d0KuXaqiLcEeuvTji0NGiqgLsPoLQKwffL6vQsnlOk3cIKDjLFjcgMsrhdk1YuL4zkfAAqL6AqvzBIi9nkkyCuuIZrrrADqesZtPK7Pk2hfvheQeTqrOhcrQjkI4IqeInsrH(ieHYiHicNKIIYkfPEjebQzcrKUjffXoHk(jer0qHkHLcrqpvvnvOKRcraBLIIQVsrjTxu(RsgSKdt1IH0Jf1Kr1Lr2mf(Ss1OLQtRy1qeQETiz2eDBkz3a)g0WHIJdrulNWZvz6KUoLA7IO(ofz8qL05HG5drTFHzyZWI95UsmCEztSnlBAgWoPTxWEZKIpZu2xradX(y8CkFNyFGBrS)3gvLKIa7JXrqcDodl2)G2ImX(DvXCirtiH9r72OTm0kHBSSLUoqqw4gAc3yLtavcrta1WrkoLCcyeqJrsxcynK4fStaRxWEHec3TP13gvLKIq7gRm7JAps1mdWqzFURedNx2eBZYMMbStA7Ln3mP42SW(UT2Hc2)pwin7ZPlZ(y1NlQ5IYJcJNt57uuqJO8SoqquY50lkdOikKeuQroTiDKgR(CrzYVOqThPgLHaAf1FSSLUoqaslCdfjOlkCjUajnkiiQ02seIc7K2I0rAS6KGIYfuuh0IIASWafkjIAxoAUtxuA31O6EYuukmkukklhy7sjcrjim(iiElQOmZIIdJca1OeugAzraEuccPglmqHoG9O0(CrHlXfiPrngrHa0oklpfffXh9ASVCo9yyX(NsUu7eNHfdhSzyX(eWrLeNLi7NfJsIXzFuBdJ2PKl1EZgd77zDGa2)6ohA6uXKIykdNxyyX(eWrLeNLi7NfJsIXz)m0cfUWahGEnozm5rJARNOWokKkQTJA7OuxsaTXjcdjwNkC13jRgbCujXJcXOqTnmAj7G56nBmr9Auigf2rHmYrTzuVY(EwhiG9ZUuU8SoqWsoNY(Y50fWTi23yaZ1zkdNnYWI9jGJkjolr23Z6abS)1Do00PIjfX(zXOKyC2xDjb02rzbPlLYDWGKTPgbCujXJcXOuxsaTzma(Ye5Pa0Dnc4OsIhfIrXjuBdJMXa4ltKNcq31eKLpGlQTIc7OqmQddjLl1f7KETRBlMueyDkuyf1tuVefIrPUyN0Mow0sHl(qrHurjilFaxuMhvsz)mczjTuxSt6XWbBMYWb3mSyFc4OsIZsK9ZIrjX4S)HHKYL6IDsV21TftkcSofkSIY8NO2i77zDGa2)62IjfbwNcfwmLHd(yyX(EwhiG9VUZHMovmPi2NaoQK4SezktzFoz42sLHfdhSzyX(eWrLeNLi77zDGa2p7s5YZ6abl5Ck7lNtxa3Iy)m)ykdNxyyX(eWrLeNLi7NfJsIXz)tjxQDI3CPK99Soqa7lSblpRdeSKZPSVCoDbClI9pLCP2jotz4SrgwSpbCujXzjY(zXOKyC2xDXoPnDSOLcx8HIY8OsAuigLGS8bCrTvu7zEuigvgAHcxyGdqVOm)jkChfsf12rTDu6yrrTvuyVzuVgfIrHDuiJCuBg1Rrz2r9c77zDGa2hm7Dfv6CIPmCWndl2NaoQK4Sez)Syusmo7tasSJqJtgtE0O26jQKDX4OsQDk5sTV0UGUouYJcXOYqlu4cdCa614KXKhnkZFIc3SVN1bcy)SlLlpRdeSKZPSVCoDbClI9pLCP2xz(Xugo4JHf7tahvsCwISFwmkjgN9Zqlu4cdCa6fL5prH7OEhL6scOnoryiX6uHR(oz1eoivuiJCuQl2jTPJfTu4IpuuB9ef2rHyuzOfkCHboa9IY8NO2i77zDGa2p7s5YZ6abl5Ck7lNtxa3IyFJbmxNPmCskdl2NaoQK4Sez)Syusmo7tasSJqJtgtE0O26jQKDX4OsQDk5sTV0UGUouYJcPIc3BgLzh12rTHO2ok1LeqBU0ZIrrOrahvs8Oqg5OuxsaTDDNdnTmGz7Rrahvs8Oqg5OuxsaTz5NsIf0yDDNdnDnc4OsIh1RrHyuyhfYih1Mr9k77zDGa2p7s5YZ6abl5Ck7lNtxa3IyFu7rYzkdhZadl2NaoQK4Sez)Syusmo7tasSJqJtgtE0Om)jkSXxuVJIaKyhHMG2ja77zDGa23fzhqlfkeeqzkdhZcdl23Z6abSVlYoGwySLhX(eWrLeNLitzk7JrqzOfQRmSy4Gndl2NaoQK4SezkdNxyyX(eWrLeNLitz4SrgwSpbCujXzjYugo4MHf7tahvsCwImLHd(yyX(eWrLeNLi7NSlTj2pPBg17OuxsaTL8SdfnHdsfLzh1gXxuVJsDjb0MLFkjwqJ11Do001eoivuMDuyVj77zDGa2pzxmoQKy)KDXc4we7Fk5sTV0UGUouYzkdNKYWI99Soqa7Fk5sTZ(eWrLeNLitz4ygyyX(eWrLeNLi77zDGa23YfPi(YakwCY1o7JrqzOfQRRJYqa)yFSXhtz4ywyyX(eWrLeNLi77zDGa2)6ohAAHkDoDSpgbLHwOUUokdb8J9XMPmCmtzyX(EwhiG9Xa1bcyFc4OsIZsKPmL9ngWCDgwmCWMHf7tahvsCwISFwmkjgN93oQneL6scOnUlsTUUZHMAeWrLepkKroQnefQTHr76ohAAXDqMA2yI61Oqmk1f7K20XIwkCXhkkKkkbz5d4IY8OsAuigLGS8bCrTvu6KtT0XIIYSJ6LOqmQTJ6Wqs5sDXoPx762IjfbwNcfwrTvu4okKroQnefQTHr7qWcfkVf0yXjx7nBmr9k77zDGa2hm7Dfv6CIPmCEHHf7tahvsCwISVN1bcyFWS3vuPZj2plgLeJZ(hgskxQl2j9Ax3wmPiW6uOWkkZFI6LOqmQnefQTHr76ohAAXDqMA2yIcXOuxStAthlAPWfFOOm)jQTJcFr9oQTJ6LOm7OYqlu4cdCa6f1Rr9AuigLGme01DujX(zeYsAPUyN0JHd2mLHZgzyX(eWrLeNLi7NfJsIXzFbz5d4IAROYqOKdnbAhcwOq5TGglo5AVjilFaxuVJc7nJcXOYqOKdnbAhcwOq5TGglo5AVjilFaxuB9ef(IcXOuxStAthlAPWfFOOqQOeKLpGlkZJkdHso0eODiyHcL3cAS4KR9MGS8bCr9ok8X(EwhiG9bZExrLoNykdhCZWI9jGJkjolr2plgLeJZ(O2ggTdbluO8wqJfNCT3SXefIrTDuBik1LeqBCxKADDNdn1iGJkjEuiJCuhgskxQl2j9Ax3wmPiW6uOWkQTI6LOqg5OqTnmAx35qtlUdYuZgtuVY(EwhiG9pkliDPuUdgKSnXugo4JHf7tahvsCwISFwmkjgN9pmKuUuxSt61UUTysrG1PqHvuM)e1lr9ok1LeqBCxKADDNdn1eoivuVJsDjb0gy276PUmfjAchKI99Soqa7Fuwq6sPChmizBIPmCskdl23Z6abSpL8Czs4kX(eWrLeNLitzk7N5hdlgoyZWI9jGJkjolr2plgLeJZ(O2ggnujeYL2N2eKN1Oqg5OuxStAthlAPWfFOO26jQKUzuiJCuBhfQTHrlzhmxVzJjkeJA7OqTnmAx35qtluPZPRzJjkKroQmek5qtG21Do00cv6C6AcYYhWf1wprTXnJ61OEL99Soqa7JbQdeWugoVWWI9jGJkjolr2plgLeJZ(NsUu7eVjG72e77zDGa2hvcH8LHTabMYWzJmSyFc4OsIZsK9ZIrjX4S)PKl1oXBc4UnX(EwhiG9rjXrIudyNPmCWndl2NaoQK4Sez)Syusmo7Fk5sTt8MaUBtSVN1bcyF5S31BHe3MVBraLPmCWhdl2NaoQK4Sez)Syusmo7ZHAdm7Dfv6CQPto1a2zFpRdeW(hcwOq5TGglo5ANPmCskdl2NaoQK4SezFpRdeW(wUifXxgqXItU2z)Syusmo7RUyN0Mow0sHl(qrTvuzOfkCHboa9ACYyYJY(Ql2jDngSV6IDsB6yrlfU4dXugoMbgwSpbCujXzjY(zXOKyC2x4dFrjtaT5C(1gquMh1g3mkeJAdrDk5sTt8MlLrHyuzOfkCHboa9ACYyYJgL5prLXSSCCDDyiaN99Soqa7B5IueFzaflo5ANPmCmlmSyFc4OsIZsK9ZIrjX4SFgAHcxyGdqVgNmM8Orz(tuVe17O2oQtjxQDI3CPmkeJc7Oqg5O2mQxzFpRdeW(x35qtluPZPJPmCmtzyX(eWrLeNLi7NfJsIXz)ddjLl1f7KETRBlMueyPqbW5WOm)jQngfIrXHAdm7Dfv6CQPto1a2JcXOqTnmAhcwOq5TGglo5AVzJjkeJc12WODDNdnT4oitnBmSVN1bcy)RBlMueyPqbW5qMYWb7nzyX(eWrLeNLi7NfJsIXz)nefQTHr76ohAAXDqMA2yIcXOuxStAthlAPWfFOO26jk8f17OuxsaTD2OkjmS3PMWbPyFpRdeW(x35qtlUdYetzk7Fk5sTVY8JHfdhSzyX(eWrLeNLi7NSlTj2pdHso0eODDNdnT4oitTC3f70TmeEwhiWLrz(tuy3md4J99Soqa7NSlghvsSFYUybClI9VoFPDbDDOKZugoVWWI9jGJkjolr2plgLeJZ(BiQKDX4OsQDD(s7c66qjpkeJItO2ggnJbWxMipfGURjilFaxuBff2SVN1bcy)KDWCDMYWzJmSyFc4OsIZsK9nGIfGWvLHd2SVN1bcyFmqOCjOdAlYe7t4Qk8LBbTbk7J7nzkdhCZWI9jGJkjolr2plgLeJZ(eGe7ieL5prH7nJcXOiaj2rOXjJjpAuM)ef2BgfIrTHOs2fJJkP215lTlORdL8OqmkoHABy0mgaFzI8ua6UMGS8bCrTvuyZ(EwhiG9VUZHMSijNPmCWhdl2NaoQK4Sez)Syusmo7VDuBik1LeqBCxKADDNdn1iGJkjEuiJCuCO2aZExrLoNAcYYhWfL5prHVOEhL6scOTZgvjHH9o1eoivuVgfIrTDuj7IXrLu768L2f01HsEuiJCuO2ggTdbluO8wqJfNCT3eKLpGlkZFIc72lrHmYrDyiPCPUyN0RDDNdnT4oitrz(tu4okeJkdHso0eODiyHcL3cAS4KR9MGS8bCrzEuyVzuVY(EwhiG9VUZHMwChKjMYWjPmSyFc4OsIZsK9ZIrjX4SV6IDsB6yrlfU4df1wrLHqjhAc0oeSqHYBbnwCY1Etqw(ao23Z6abS)1Do00I7GmXuMY(O2JKZWIHd2mSyFc4OsIZsK9ZIrjX4S)HHKYL6IDsV21TftkcSofkSIY8NOEH99Soqa7FDBXKIaRtHclMYW5fgwSVN1bcy)DjeAHkDoX(eWrLeNLitz4SrgwSVN1bcyFupN6uhL9jGJkjolrMYuMY(MCbya7h7Z(hgkZW5LKIn7JrangjX(4pkKi4kLTvIhfkzafuuzOfQRrHs7d4ArHlZzcJErbGaKQ7cldBzuEwhi4IccKi0I0Ewhi4AyeugAH66JH0VurApRdeCnmckdTqD99tcU9Ufbuxhiis7zDGGRHrqzOfQRVFsWac5rA8h1h4yUouJs4dpkuBddIh1PUErHsgqbfvgAH6AuO0(aUOCapkmccPWavDa7rnxuCiGArApRdeCnmckdTqD99tchWXCDOUo11lsJ)OqcCepkfgfNmgafLPobIsHrzFuuNsUu7rH0j5IckIc1EKCsCrApRdeCnmckdTqD99tcj7IXrLeEa3IEoLCP2xAxqxhk54LSlTPNKU5B1LeqBjp7qrJaoQK4M9gX3B1LeqBw(PKybnwx35qtxJaoQK4Mn2BgP9SoqW1WiOm0c113pjCk5sThP9SoqW1WiOm0c113pjy5IueFzaflo5AhpmckdTqDDDugc43d24ls7zDGGRHrqzOfQRVFs46ohAAHkDoD4HrqzOfQRRJYqa)EWos7zDGGRHrqzOfQRVFsaduhiishPXFuirWvkBRepkkzsGqu6yrrPDkkpRqruZfLNSpshvsTin(JcP7uovuiDsUOCnkJrCAK2Z6ab3t2LYLN1bcwY5u8aUf9K5xKg)rHeAdIYWwkriQZ0O5oDrPWO0of1xjxQDIhfsiuDDGGO2gfHO4WbSh1bXlQrJYakY0ffgiuoG9OgJOaqTpG9OMlkpzFKoQKETfP9SoqW9(jbHny5zDGGLCofpGBrpNsUu7ehVX45uYLAN4nxkJ04pkCjgmseIcNzVROsNtr5AuV8okKgxef3wmG9O0ofLXionkS3mQJYqa)Wlk3qjruA31OW97OqACruJruJgfHRygbDrzA0(aIs7uuacx1OqIH0jjkOiQ5Ica1OSXeP9SoqW9(jbWS3vuPZj8gJh1f7K20XIwkCXhY8KIOGS8bCBTN5nlhxrmdTqHlmWbON5p4gP2EBDSOTWEZxreBKrEZxn7xI04pkKgcUHtIOSVbShLh1xjxQ9Oq6KeLPobIsqEUpG9O0offbiXocrPDbDDOKhLd4r19KhWEuhgptrzafr5AusYpnkChfsJlI0Ewhi4E)Kq2LYLN1bcwY5u8aUf9Ck5sTVY8dVX4HaKyhHgNmM8OB9KSlghvsTtjxQ9L2f01HsoIzOfkCHboa9ACYyYJA(dUJ04pkZ4aMRhLRrH73rzA0o0wJkjF8IcFVJY0O9OsYpQTH26nCkQtjxQ9xJ0Ewhi4E)Kq2LYLN1bcwY5u8aUf9ymG564ngpzOfkCHboa9m)b3VvxsaTXjcdjwNkC13jRgbCujXrgz1f7K20XIwkCXhARhSrmdTqHlmWbON5pBmsJ)OqcCuuEuO2JKtIOm1jqucYZ9bShL2POiaj2rikTlORdL8O22Aa2xu4EZOgJOaqaff0ikCP0ZIrraVO(DNdnfLzeMTp8IYb8Omt8tjruqJO(DNdnDrnxuhjPSs8xJ0Ewhi4E)Kq2LYLN1bcwY5u8aUf9GApsoEJXdbiXocnozm5r36jzxmoQKANsUu7lTlORdLCKc3BA2BVHTvxsaT5splgfHgbCujXrgz1LeqBx35qtldy2(AeWrLehzKvxsaTz5NsIf0yDDNdnDnc4OsI)kIyJmYB(AKg)rHKcnrNgfgXafJIqudikxkJcAeL2POWL4cK0OqPSBFuuJgv2Tp6IYJcjgsNKiTN1bcU3pj4ISdOLcfccO4ngpeGe7i04KXKh18hSX3BcqIDeAcANarApRdeCVFsWfzhqlm2YJI0rA8hvI2JKtIls7zDGGRHAps(Z1TftkcSofkSWBmEomKuUuxSt61UUTysrG1PqHL5pVeP9SoqW1qThj)9tc7si0cv6Cks7zDGGRHAps(7Neq9CQtD0iDKg)rH0qOKdnbUiTN1bcUwMFpyG6ab4ngpO2ggnujeYL2N2eKNvKrwDXoPnDSOLcx8H26jPBImYBJABy0s2bZ1B2yqCBuBdJ21Do00cv6C6A2yqg5mek5qtG21Do00cv6C6AcYYhWT1Zg381xJ0Ewhi4Az(9(jbujeYxg2ceWBmEoLCP2jEta3TPiTN1bcUwMFVFsaLehjsnGD8gJNtjxQDI3eWDBks7zDGGRL537NeKZExVfsCB(Ufbu8gJNtjxQDI3eWDBks7zDGGRL537NeoeSqHYBbnwCY1oEJXdhQnWS3vuPZPMo5udyps7zDGGRL537NeSCrkIVmGIfNCTJN6IDsxJXJ1aqIQUyN0Mow0sHl(q4ngpQl2jTPJfTu4Ip0wzOfkCHboa9ACYyYJgP9SoqW1Y879tcwUifXxgqXItU2XBmEe(WxuYeqBoNFTby(g3eXnCk5sTt8MlLiMHwOWfg4a0RXjJjpQ5pzmllhxxhgcWJ0Ewhi4Az(9(jHR7COPfQ050H3y8KHwOWfg4a0RXjJjpQ5pV8E7tjxQDI3CPerSrg5nFns7zDGGRL537NeUUTysrGLcfaNdXBmEomKuUuxSt61UUTysrGLcfaNdn)zJiYHAdm7Dfv6CQPto1a2re12WODiyHcL3cAS4KR9MngerTnmAx35qtlUdYuZgtK2Z6abxlZV3pjCDNdnT4oit4ngpBa12WODDNdnT4oitnBmiQUyN0Mow0sHl(qB9GV3QljG2oBuLeg27uJaoQK4r6in(JYmoG56K4I04pkKGjctu2yIcNzVROsNtrngrnAuZfLJcT1OuyucBquqBTfvsGrbGAu2hffojgf3wmG9OsIdYeErngrPUKakXJAakmQK4Iur97ohAQfP9SoqW1mgWC9hWS3vuPZj8gJNT3G6scOnUlsTUUZHMAeWrLehzK3aQTHr76ohAAXDqMA2yEfr1f7K20XIwkCXhcPeKLpGZ8KIOGS8bCBPto1shlYSFbXTpmKuUuxSt61UUTysrG1PqH1w4gzK3aQTHr7qWcfkVf0yXjx7nBmVgPXFuMj2sD4qvhWEuqB9gofvsCqMIccIsDXoPxuA31OmnszuYjzkkdOikTtrXTfUoqquqJOWz27kQ05uuMgThLGme01JIBlgWEuyCaNSMCls7zDGGRzmG56VFsam7Dfv6CcVmczjTuxSt69GnEJXZHHKYL6IDsV21TftkcSofkSm)5fe3aQTHr76ohAAXDqMA2yquDXoPnDSOLcx8Hm)zB89E7xm7m0cfUWahGEV(kIcYqqx3rLuKg)rHesgc66rHZS3vuPZPOixiriQXiQrJY0iLrr4kMrqrXTfdypQpcwOq51IkjWO0URrjidbD9OgJO(WKe1oPxucY5ie1aIs7uuacx1OW31I0Ewhi4AgdyU(7NeaZExrLoNWBmEeKLpGBRmek5qtG2HGfkuElOXItU2BcYYhW9g7nrmdHso0eODiyHcL3cAS4KR9MGS8bCB9GpevxStAthlAPWfFiKsqw(aoZZqOKdnbAhcwOq5TGglo5AVjilFa3B8fPXFuFklinkSOChmizBkkUTya7r9rWcfkVwuM1r7rLexKkQF35qtr5aEuw2sDWiPOuxSt6fLlpyuqGeHO42IbSh1V7COPOsIdYuuBBd0rgL2f01HsEudikaHRAuYbqV2I0Ewhi4AgdyU(7NeokliDPuUdgKSnH3y8GABy0oeSqHYBbnwCY1EZgdIBVb1LeqBCxKADDNdn1iGJkjoYiFyiPCPUyN0RDDBXKIaRtHcRTEbzKrTnmAx35qtlUdYuZgZRrA8hLzD0EueaAV3JsDXoPxuU0KJWfL9rr9PmwuokiikKojTiTN1bcUMXaMR)(jHJYcsxkL7GbjBt4ngphgskxQl2j9Ax3wmPiW6uOWY8NxERUKaAJ7IuRR7COPgbCujXFRUKaAdm7D9uxMIenc4OsIhP9SoqW1mgWC93pjqjpxMeUsr6in(J6RKl1Euinek5qtGlsJ)OqsqsmKikZCxmoQKI0Ewhi4ANsUu7Rm)Es2fJJkj8aUf9CD(s7c66qjhVKDPn9KHqjhAc0UUZHMwChKPwU7ID6wgcpRde4sZFWUzgWxKg)rzM7G56rzdK0DrzIIYfuuok0wJsHrLDmrbbrLehKPOYDxStxlkKKajcrzQtGOmJdGhLzL8ua6UOMlkhfARrPWOe2GOG2Als7zDGGRDk5sTVY879tcj7G564ngpBizxmoQKAxNV0UGUouYrKtO2ggnJbWxMipfGURjilFa3wyhPXFu4ciugLbue1V7COjlsYJ6Du)UZHMovmPOOSbs6UOmrr5ckkhfARrPWOYoMOGGOsIdYuu5Ul2PRffssGeHOm1jquMXbWJYSsEkaDxuZfLJcT1OuyucBquqBTfP9SoqW1oLCP2xz(9(jbmqOCjOdAlYeEgqXcq4Q(GnEeUQcF5wqBG(G7nJ0Ewhi4ANsUu7Rm)E)KW1Do0Kfj54ngpeGe7iy(dU3ercqIDeACYyYJA(d2BI4gs2fJJkP215lTlORdLCe5eQTHrZya8LjYtbO7AcYYhWTf2rA8hLzD0EujXfPI63Do0uuqGeHOsIdYuuM6eikCM9UIkDofLPrkJ6uhHOSX0IcjWrrXTfdypQpcwOq5ffueLJctMIs7c66qjVfP9SoqW1oLCP2xz(9(jHR7COPf3bzcVX4z7nOUKaAJ7IuRR7COPgbCujXrgzouBGzVROsNtnbz5d4m)bFVvxsaTD2OkjmS3PgbCujXFfXTt2fJJkP215lTlORdLCKrg12WODiyHcL3cAS4KR9MGS8bCM)GD7fKr(Wqs5sDXoPx76ohAAXDqMm)b3iMHqjhAc0oeSqHYBbnwCY1Etqw(aoZXEZxJ0Ewhi4ANsUu7Rm)E)KW1Do00I7GmH3y8OUyN0Mow0sHl(qBLHqjhAc0oeSqHYBbnwCY1Etqw(aUiDKg)r9vYLAN4rHecvxhiisJ)OmZmI6uYLApQ5IYgdErzIIsqUuIquMCGgLcJY(OO(DNdnDQysrrPWOqjazm6fLHaAfL2POW43njtrHcb2hErrjtGOgJOmrr5ckkxJYYX1OYyIABdb0kkTtrHrqzOfQRrzMyKKxBrApRdeCTtjxQDI)CDNdnDQysr4ngpO2ggTtjxQ9MnMin(JYmoG56r5Au4(DuinUiktJ2H2Auj5Jxu47DuMgThvs(4fLd4rL0OmnApQK8JYnuseLzUdMRhP9SoqW1oLCP2j(7NeYUuU8SoqWsoNIhWTOhJbmxhVX4jdTqHlmWbOxJtgtE0TEWgP2wDjb0gNimKyDQWvFNSAeWrLehruBdJwYoyUEZgZRrA8hfUuJ6LOuxSt6fLPr7r9PSG0OWIYDWGKTPOsreMOSXeLzCa8OmRKNcq3ffkcrLrilhWEu)UZHMovmPOwK2Z6abx7uYLAN4VFs46ohA6uXKIWlJqwsl1f7KEpyJ3y8OUKaA7OSG0Ls5oyqY2uJaoQK4iQUKaAZya8LjYtbO7AeWrLehroHABy0mgaFzI8ua6UMGS8bCBHnIhgskxQl2j9Ax3wmPiW6uOW65fevxStAthlAPWfFiKsqw(aoZtAK2Z6abx7uYLAN4VFs462IjfbwNcfw4ngphgskxQl2j9Ax3wmPiW6uOWY8NngP9SoqW1oLCP2j(7NeUUZHMovmPiMYugda]] )

end
