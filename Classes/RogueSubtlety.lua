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
            
            recheck = function () return apl_build( energy[ "time_to_" .. ceil( energy.max - ( variable.stealth_threshold or 0 ) - 40 * ( not ( talent.alacrity.enabled or talent.shadow_focus.enabled or talent.master_of_shadows.enabled ) and 1 or 0 ) ) ] ) end,
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
            
            recheck = apl_build,
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


    spec:RegisterPack( "Subtlety", 20180728.1559, [[dW0eYaqirP6rKsAtqHrbLYPGIAvIsXRuLmlsPUfuQSlP8lrHHbj5yKIwMsjptPqtJuIRbfzBkLY3ukvnoiP05ukvSoiPOMNsr3tPAFKQCqLcQfkk6Hqs1ejvvxKuvsBKuv0hHKcnsiPiNKuvWkfvEPsPsntLsLCtrPu2juYpfLs1qjvLAPkfKNQQMkK4QKQcTvsvj(QOuYEr5Vs1GLCyQwmepwKjJQlJSzO6ZQIrRKtRy1qsbVwu1Sj52uYUb(nOHdPoUsbwofpxLPtCDk12fL8DsLXdLQoVQuZNuy)cZ0KHc7ZDHyyTfQ0e1IQTFluBttmHjn1cMyF5nAI9r7P8(dX(a3Iy)VnIOi5n7J2FRGoNHc7FqBtIy)LiOpuZzKXZilBKwcALXnw2kxgiizCCjJBSszGOGizGG7yhNYkd0gi(OOldugYSLMzGYwA23qWhBQ)TrefjVB3yLyFe7rj6dagc7ZDHyyTfQ0e1IQTFluBttTSXTFJAY(UTSGg2)pwOo7ZPlX(OSMlQ5IYJcTNY7puuq8O8KmqquQ5KlkCOjkutu(rnrH4hXJccIswuu)XYw5YabOUXXLOgl0qJ0ICro9HOCoN4rTDpP8rjWOKffLarhfepkzrrXjC3wjr5jzGGOuZjTixKdLfzOOMlQtgLkQdArrLfu5YOg5DuiKOJiquynplbr5CkkhWJsFnR5sKXfkkz5su6drPZbsucmkdDqvwuu42gzrMg7RMtogkS)jKRKfXzOWWstgkSpbCefXzzY(jZiKzC2hXghVDc5kz1SrZ(EsgiG9VLZH6oXm5jMWWAlgkSpbCefXzzY(jZiKzC2pbTqGD0WbixJt4tAKO2CpknJc7IcBrjUIasJteAY0pX4I)qwnc4ikIhfgrHyJJ3YYbZTA2OJcZSVNKbcy)KRuDpjde0vZjSVAoPdClI9XhWClMWWAJmuyFc4ikIZYK99Kmqa7FlNd1DIzYtSFYmczgN9fxraPDuYqsxO0cmBGn1iGJOiEuyeL4kcin8bW76ippGURrahrr8OWikoHyJJ3WhaVRJ88a6UMHS8bCrTzuAgfgrDOjLQlU5HKRDlBZKNa9tGgRO2JAROWikXnpK0KXI6cSZhkkSlkdz5d4IsVO2g7NENuuxCZdjhdlnzcdlTWqH9jGJOiolt2pzgHmJZ(hAsP6IBEi5A3Y2m5jq)eOXkk92JAJSVNKbcy)BzBM8eOFc0yXegwyIHc77jzGa2)wohQ7eZKNyFc4ikIZYKjmH95eUBRegkmS0KHc77jzGa2p)KYZ(eWrueNLjtyyTfdf2NaoII4SmzFpjdeW(jxP6EsgiORMtyF1Csh4we7N4htyyTrgkSpbCefXzzY(jZiKzC2)eYvYI4nxPyFpjdeW(gBq3tYabD1Cc7RMt6a3Iy)tixjlIZegwAHHc7tahrrCwMSFYmczgN9f38qstglQlWoFOO0lQTffgrzilFaxuBg1tIhfgrLGwiWoA4aKlk92JslrHDrHTOKXIIAZO0evrH5OYMO2I99Kmqa7dMNLGOCoXegwyIHc7tahrrCwMSFYmczgN9jazEE34e(KgjQn3Jkl3moIIANqUswDzzOBbv8OWiQe0cb2rdhGCnoHpPrIsV9O0c77jzGa2p5kv3tYabD1Cc7RMt6a3Iy)tixjREIFmHH12yOW(eWrueNLj7NmJqMXz)e0cb2rdhGCrP3EuAjQxrjUIasJteAY0pX4I)qwnc4ikIhLgAeL4MhsAYyrDb25df1M7rPzuyevcAHa7OHdqUO0BpQnY(EsgiG9tUs19KmqqxnNW(Q5KoWTi2hFaZTycdRTNHc7tahrrCwMSFYmczgN9jazEE34e(KgjQn3Jkl3moIIANqUswDzzOBbv8OWUO0cQIkBIk7rHTOexraP5kpzg5DJaoII4rPHgrjUIas7wohQRJdt2xJaoII4rPHgrjUIasZYpHmDiE)wohQ7AeWruepkmZ(EsgiG9tUs19KmqqxnNW(Q5KoWTi2hXEuCMWWc1YqH9jGJOiolt2pzgHmJZ(eGmpVBCcFsJeLE7rPjMI6vueGmpVBg6HaSVNKbcyF3KCa1fOXqaHjmS2omuyFpjdeW(Uj5aQJ2wDe7tahrrCwMmHHLMOIHc77jzGa2xnpl56OgS5pweqyFc4ikIZYKjmH9rBOe0cXfgkmS0KHc7tahrrCwMmHH1wmuyFc4ikIZYKjmS2idf2NaoII4SmzcdlTWqH9jGJOioltMWWctmuyFc4ikIZYK9ZYv2e7Vnuf1ROexraPL18annc4ikIhv2e1gXuuVIsCfbKMLFcz6q8(TCou31iGJOiEuztuAIk23tYabSFwUzCefX(z5MoWTi2)eYvYQlldDlOIZegwBJHc77jzGa2)eYvYI9jGJOioltMWWA7zOW(eWrueNLj77jzGa23Yn5jEhhA6CYLf7J2qjOfIl9Jsqa)yFnXetyyHAzOW(eWrueNLj77jzGa2)wohQRJOCoDSpAdLGwiU0pkbb8J91KjmS2omuyFpjdeW(OHYabSpbCefXzzYeMW(i2JIZqHHLMmuyFc4ikIZYK9tMriZ4S)HMuQU4MhsU2TSntEc0pbASIsV9O2kkn0ikeBC8MSOo3qoxbn8RZPens7epLpk92JARTd77jzGa2)w2Mjpb6NanwmHH1wmuyFpjdeW(pki0cr5CI9jGJOioltMWWAJmuyFpjdeW(iEk)joc7tahrrCwMmHjSFIFmuyyPjdf2NaoII4Smz)KzeYmo7JyJJ3quqixzFsZqEsIsdnIsCZdjnzSOUa78HIAZ9O2gQIsdnIcBrHyJJ3YYbZTA2OJcJOWwui244TB5COUoIY501SrhLgAevccvCOoq7wohQRJOCoDndz5d4IAZ9O2iQIcZrHz23tYabSpAOmqatyyTfdf2NaoII4Smz)KzeYmo7Fc5kzr8Mb(ytSVNKbcyFefeY742M3mHH1gzOW(eWrueNLj7NmJqMXz)tixjlI3mWhBI99Kmqa7JqMJm5hWdtyyPfgkSpbCefXzzY(jZiKzC2NdLgyEwcIY5utMu(b8W(EsgiG9V3wiq11H4Do5YIjmSWedf2NaoII4SmzFpjdeW(wUjpX74qtNtUSy)KzeYmo7lU5HKMmwuxGD(qrTzujOfcSJgoa5ACcFsJW(IBEiPp4SV4MhsAYyrDb25dXegwBJHc7tahrrCwMSFYmczgN9n(W7uweqAoNFTbeLErTruffgrL9OoHCLSiEZvQOWiQe0cb2rdhGCnoHpPrIsV9OsO7wo23p0eGZ(EsgiG9TCtEI3XHMoNCzXegwBpdf2NaoII4Smz)KzeYmo7NGwiWoA4aKRXj8jnsu6Th1wr9kQtixjlI3CLI99Kmqa7FlNd11ruoNoMWWc1YqH9jGJOiolt2pzgHmJZ(hAsP6IBEi5IsV9O2yuyefhknW8SeeLZPMmP8d4jkmIcXghVDVTqGQRdX7CYLvZgDuyefInoE7wohQRZDqIA2OzFpjdeW(3Y2m5jqxGgGZHmHH12HHc7tahrrCwMSFYmczgN9ZEui244TB5COUo3bjQzJokmIsCZdjnzSOUa78HIAZ9OWuuVIsCfbK2zJiKb3(HAeWrueN99Kmqa7FlNd115oirmHjS)jKRKvpXpgkmS0KHc7tahrrCwMSFwUYMy)eeQ4qDG2TCouxN7Ge1sl38qxh34jzGaxfLE7rPzB7Xe77jzGa2pl3moIIy)SCth4we7FlExwg6wqfNjmS2IHc7tahrrCwMSFYmczgN9ZEuz5MXruu7w8USm0TGkEuyefNqSXXB4dG31rEEaDxZqw(aUO2mknzFpjdeW(z5G5wmHH1gzOW(eWrueNLj7JdnDaH9cdlnzFpjdeW(OHqv3qh02Ki2NWEX4D3cAde2xlOIjmS0cdf2NaoII4Smz)KzeYmo7taY88ok92JslOkkmIIaK55DJt4tAKO0Bpknrvuyev2Jkl3moIIA3I3LLHUfuXJcJO4eInoEdFa8UoYZdO7AgYYhWf1MrPj77jzGa2)wohQZIuCMWWctmuyFc4ikIZYK9tMriZ4Sp2Ik7rjUIasJ7M89B5COUgbCefXJsdnIIdLgyEwcIY5uZqw(aUO0Bpkmf1ROexraPD2iczWTFOgbCefXJcZrHruylQSCZ4ikQDlExwg6wqfpkn0ikeBC8292cbQUoeVZjxwndz5d4IsV9O0STvuAOruhAsP6IBEi5IsV9O0suyevccvCOoq7EBHavxhI35KlRMHS8bCrPxuAIQOWm77jzGa2)wohQRZDqIycdRTXqH9jGJOiolt2pzgHmJZ(IBEiPjJf1fyNpuuBgvccvCOoq7EBHavxhI35KlRMHS8bCSVNKbcy)B5COUo3bjIjmH9XhWClgkmS0KHc7tahrrCwMSFYmczgN9XwuzpkXveqAC3KVFlNd11iGJOiEuAOruzpkeBC82TCouxN7Ge1SrhfMJcJOe38qstglQlWoFOOWUOmKLpGlk9IABrHrugYYhWf1MrjtkFxglkQSjQTIcJOWwuhAsP6IBEi5A3Y2m5jq)eOXkQnJslrPHgrL9OqSXXB3BleO66q8oNCz1SrhfMzFpjdeW(G5zjikNtmHH1wmuyFc4ikIZYK99Kmqa7dMNLGOCoX(jZiKzC2)qtkvxCZdjx7w2Mjpb6NanwrP3EuBffgrHTOo0Ks1f38qY1ULTzYtG(jqJvuBUhfMIsdnIsCfbK2rjdjDHslWSb2uJaoII4rH5OWiQShfInoE7wohQRZDqIA2OJcJOe38qstglQlWoFOO0BpkSffMI6vuylQTIkBIkbTqGD0WbixuyokmhfgrziCdDlhrrSF6DsrDXnpKCmS0KjmS2idf2NaoII4Smz)KzeYmo7BilFaxuBgvccvCOoq7EBHavxhI35KlRMHS8bCr9kknrvuyevccvCOoq7EBHavxhI35KlRMHS8bCrT5EuykkmIsCZdjnzSOUa78HIc7IYqw(aUO0lQeeQ4qDG292cbQUoeVZjxwndz5d4I6vuyI99Kmqa7dMNLGOCoXegwAHHc7tahrrCwMSFYmczgN9rSXXB3BleO66q8oNCz1SrhfgrHTOYEuIRiG04UjF)wohQRrahrr8O0qJOo0Ks1f38qY1ULTzYtG(jqJvuBg1wrPHgrHyJJ3ULZH66ChKOMn6OWm77jzGa2)OKHKUqPfy2aBIjmSWedf2NaoII4Smz)KzeYmo7FOjLQlU5HKRDlBZKNa9tGgRO0BpQTI6vuIRiG04UjF)wohQRrahrr8OEfL4kcinW8SKtCvEY0iGJOio77jzGa2)OKHKUqPfy2aBIjmS2gdf23tYabSpL1CjY4cX(eWrueNLjtycty)SiZnqadRTqLMOwuT9AUT2wAY(6Cdyaph7Z(Onq8rrSVwJsFf7PKTq8OqiCOHIkbTqCjke6zaxlQnCkrOLlkaeGDl3yHBRIYtYabxuqG6DlY5jzGGRH2qjOfIl74k)Yh58KmqW1qBOe0cXLx7z42pweqCzGGiNNKbcUgAdLGwiU8ApdCiKh50AuFGJ(wqjkJp8OqSXXjEuN4YffcHdnuujOfIlrHqpd4IYb8OqBiSdnuKb8e1CrXHaQf58KmqW1qBOe0cXLx7zCah9TGs)exUiNwJsF8iEucmkoHpakkDlceLaJY(OOoHCLSIc11)ff0efI9O4K5ICEsgi4AOnucAH4YR9mYYnJJOiTbUfTFc5kz1LLHUfuX1olxzt7BdvVexraPL18annc4ikINnBetVexraPz5NqMoeVFlNd1Dnc4ikINnAIQiNNKbcUgAdLGwiU8ApJtixjRiNNKbcUgAdLGwiU8Apdl3KN4DCOPZjxwAJ2qjOfIl9Jsqa)21etropjdeCn0gkbTqC51Eg3Y5qDDeLZPtB0gkbTqCPFucc43UMropjdeCn0gkbTqC51EgOHYabrUiNwJsFf7PKTq8OOSiZ7OKXIIswuuEsGMOMlkplFuoIIAropjdeC75Nu(iNwJc1xukFuOU(VOCjk8XCsKZtYab3R9msUs19KmqqxnNOnWTO9e)ICAnQnKnikCBL6DuNUrsl6IsGrjlkQVqUswepQneuCzGGOWgY7O4Wb8e1b1oQrIchAs0ffAiunGNOg8OaqznGNOMlkplFuoIIWClY5jzGG71EggBq3tYabD1CI2a3I2pHCLSiU2d((jKRKfXBUsf50AuBy0OvVJcR5zjikNtr5suB9kkuxFhf32mGNOKfff(yojknrvuhLGa(PDuoUqMOKLlrPLxrH667Og8Ogjkc7rpg6Is3iRbeLSOOae2lrHAe11FuqtuZffakrzJoY5jzGG71EgG5zjikNtAp47IBEiPjJf1fyNpKEBdddz5d428jXBwo2JrcAHa7OHdqo921c2HnzSOn1evyoB2kYP1OqDi4gozIY(gWtuEuFHCLSIc11Fu6weikd5P1aEIswuueGmpVJswg6wqfpkhWJA5znGNOo0EIIchAIYLOuKFsuAjkuxFh58KmqW9ApJKRuDpjde0vZjAdClA)eYvYQN4N2d(obiZZ7gNWN0iBUNLBghrrTtixjRUSm0TGkogjOfcSJgoa5ACcFsJO3UwICAnk95aMBfLlrPLxrPBKf0wIs)FTJctVIs3iRO0)pkSbTLB4uuNqUswyoY5jzGG71EgjxP6EsgiORMt0g4w0o(aMBP9GVNGwiWoA4aKtVDT8sCfbKgNi0KPFIXf)HSAeWruexdne38qstglQlWoFOn31eJe0cb2rdhGC6TVXiNwJsF8OO8OqShfNmrPBrGOmKNwd4jkzrrraY88okzzOBbv8OWM1aSVO0cQIAWJcabuuq8O2Wkpzg5T2r9xohQlk9jmzFAhLd4rLT5NqMOG4r9xohQ7IAUOosrjH4yoY5jzGG71EgjxP6EsgiORMt0g4w0oI9O4Ap47eGmpVBCcFsJS5EwUzCef1oHCLS6YYq3cQ4yNwqv2KDSjUIasZvEYmY7gbCefX1qdXveqA3Y5qDDCyY(AeWruexdnexraPz5NqMoeVFlNd1Dnc4ikIJ5iNwJA7cQJojk0MbAg5DudikxPIcIhLSOO2W67TROqOKBFuuJevYTp6IYJc1iQR)iNNKbcUx7z4MKdOUangciAp47eGmpVBCcFsJO3UMy6fbiZZ7MHEiqKZtYab3R9mCtYbuhTT6OiNNKbcUx7zOMNLCDud28hlcirUiNwJkt7rXjZf58KmqW1qShfF)w2Mjpb6NanwAp47hAsP6IBEi5A3Y2m5jq)eOXsV9T0qdeBC8MSOo3qoxbn8RZPens7epLxV9T2oropjdeCne7rXFTNXJccTquoNICEsgi4Ai2JI)ApdepL)ehjYf50AuOoeQ4qDGlY5jzGGRL43oAOmqG2d(oInoEdrbHCL9jnd5jrdne38qstglQlWoFOn33gQ0qdSHyJJ3YYbZTA2OXaBi244TB5COUoIY501SrRHgjiuXH6aTB5COUoIY501mKLpGBZ9nIkmJ5iNNKbcUwIFV2ZarbH8oUT5T2d((jKRKfXBg4Jnf58KmqW1s871EgiK5it(b8O9GVFc5kzr8Mb(ytropjdeCTe)ETNX92cbQUoeVZjxwAp47CO0aZZsquoNAYKYpGNiNNKbcUwIFV2ZWYn5jEhhA6CYLL2IBEiPp47wda1S4MhsAYyrDb25dP9GVlU5HKMmwuxGD(qBMGwiWoA4aKRXj8jnsKZtYabxlXVx7zy5M8eVJdnDo5Ys7bF34dVtzraP5C(1gGEBevyK9tixjlI3CLcJe0cb2rdhGCnoHpPr0BpHUB5yF)qtaEKZtYabxlXVx7zClNd11ruoNoTh89e0cb2rdhGCnoHpPr0BFRxNqUsweV5kvKZtYabxlXVx7zClBZKNaDbAaohQ9GVFOjLQlU5HKtV9nIbhknW8SeeLZPMmP8d4bdeBC8292cbQUoeVZjxwnB0yGyJJ3ULZH66ChKOMn6iNNKbcUwIFV2Z4wohQRZDqI0EW3ZoInoE7wohQRZDqIA2OXqCZdjnzSOUa78H2ChtVexraPD2iczWTFOgbCefXJCroTgL(CaZTiZf50AuB3eHokB0rH18SeeLZPOg8OgjQ5IYrG2sucmkJnikOT0Is)WOaqjk7JIcRmJIBBgWtu63bjs7Og8OexraH4rnabgL(Dt(O(lNd11ICEsgi4A4dyU1oyEwcIY5K2d(o2YU4kcinUBY3VLZH6AeWruexdnYoInoE7wohQRZDqIA2OXmgIBEiPjJf1fyNpe2zilFaNEBdddz5d42uMu(Umwu2Sfgy7qtkvxCZdjx7w2Mjpb6NanwBQfn0i7i244T7TfcuDDiENtUSA2OXCKtRrLTzRKHdfzaprbTLB4uu63bjkkiikXnpKCrjlxIs3OurPMSOOWHMOKfff324YabrbXJcR5zjikNtrPBKvugc3q3kkUTzaprH2bCYAsrn4r9gAh1YZIIsr3fLSCquBlkXnpKCrbnrHw5VJs3iRO(uYqsuOqPfy2aBQf58KmqW1WhWCRx7zaMNLGOCoPD6DsrDXnpKC7AQ9GVFOjLQlU5HKRDlBZKNa9tGgl923cdSDOjLQlU5HKRDlBZKNa9tGgRn3XKgAiUIas7OKHKUqPfy2aBQrahrrCmJr2rSXXB3Y5qDDUdsuZgngIBEiPjJf1fyNpKE7ydtVW2wztcAHa7OHdqomJzmmeUHULJOOiNwJAdr4g6wrH18SeeLZPOi3OEh1Gh1irPBuQOiSh9yOO42Mb8e1)TfcuDTO0pmkz5sugc3q3kQbpQpu)r9qYfLHC(7OgquYIIcqyVefMUwKZtYabxdFaZTETNbyEwcIY5K2d(UHS8bCBMGqfhQd0U3wiq11H4Do5YQzilFa3lnrfgjiuXH6aT7TfcuDDiENtUSAgYYhWT5oMWqCZdjnzSOUa78HWodz5d40lbHkouhODVTqGQRdX7CYLvZqw(aUxykYP1O(uYqsuOqPfy2aBkkUTzapr9FBHavxlQS1iRO0VBYh1F5COUOCapklBLmOvuuIBEi5IYvhmkiq9okUTzapr9xohQlk97Geff2SbYOIswg6wqfpQbefGWEjk1aim3ICEsgi4A4dyU1R9mokziPluAbMnWM0EW3rSXXB3BleO66q8oNCz1SrJb2YU4kcinUBY3VLZH6AeWruexdno0Ks1f38qY1ULTzYtG(jqJ1MBPHgi244TB5COUo3bjQzJgZroTgv2AKvueaA)SIsCZdjxuUsN)(IY(OO(ucfkffeefQR)wKZtYabxdFaZTETNXrjdjDHslWSb2K2d((HMuQU4MhsU2TSntEc0pbAS0BFRxIRiG04UjF)wohQRrahrr8xIRiG0aZZsoXv5jtJaoII4ropjdeCn8bm361EguwZLiJluKlYP1O(c5kzffQdHkouh4ICAnkutKcnzIsFXnJJOOiNNKbcU2jKRKvpXV9SCZ4iksBGBr73I3LLHUfuX1olxzt7jiuXH6aTB5COUo3bjQLwU5HUoUXtYabUsVDnBBpMICAnk9fhm3kkBGIUlkDuuUHIYrG2sucmQKJokiik97GefvA5Mh6ArLTduVJs3IarPphapQSf55b0Drnxuoc0wIsGrzSbrbTLwKZtYabx7eYvYQN43R9mYYbZT0EW3ZEwUzCef1UfVlldDlOIJbNqSXXB4dG31rEEaDxZqw(aUn1mYP1O03qOkkCOjQ)Y5qDwKIh1RO(lNd1DIzYtrzdu0DrPJIYnuuoc0wIsGrLC0rbbrPFhKOOsl38qxlQSDG6Du6weik95a4rLTippGUlQ5IYrG2sucmkJnikOT0ICEsgi4ANqUsw9e)ETNbAiu1n0bTnjsBCOPdiSx21uBc7fJ3DlOnq21cQICEsgi4ANqUsw9e)ETNXTCouNfP4Ap47eGmpV1BxlOcdcqMN3noHpPr0BxtuHr2ZYnJJOO2T4DzzOBbvCm4eInoEdFa8UoYZdO7AgYYhWTPMroTgv2AKvu63n5J6VCouxuqG6Du63bjkkDlcefwZZsquoNIs3OurDI)okB0TO0hpkkUTzapr9FBHavxuqtuocmlkkzzOBbv8wKZtYabx7eYvYQN43R9mULZH66ChKiTh8DSLDXveqAC3KVFlNd11iGJOiUgAWHsdmplbr5CQzilFaNE7y6L4kciTZgridU9d1iGJOioMXaBz5MXruu7w8USm0TGkUgAGyJJ3U3wiq11H4Do5YQzilFaNE7A22sdno0Ks1f38qYP3UwWibHkouhODVTqGQRdX7CYLvZqw(ao90evyoY5jzGGRDc5kz1t871Eg3Y5qDDUdsK2d(U4MhsAYyrDb25dTzccvCOoq7EBHavxhI35KlRMHS8bCrUiNwJ6lKRKfXJAdbfxgiiYP1O0hWJ6eYvYkQ5IYgT2rPJIYqUs9okDoqIsGrzFuu)LZH6oXm5POeyuieGWh5Ic3aTIswuuO97MSOOqGa7t7OOSiqudEu6OOCdfLlrz5yFuj0rHnCd0kkzrrH2qjOfIlrLTHRFm3ICEsgi4ANqUsweF)wohQ7eZKN0EW3rSXXBNqUswnB0roTgL(CaZTIYLO0YROqD9Du6gzbTLO0)x7OW0RO0nYkk9)1okhWJABrPBKvu6)hLJlKjk9fhm3kY5jzGGRDc5kzr8x7zKCLQ7jzGGUAorBGBr74dyUL2d(EcAHa7OHdqUgNWN0iBURj2HnXveqACIqtM(jgx8hYQrahrrCmqSXXBz5G5wnB0yoYP1O2WsuBfL4MhsUO0nYkQpLmKefkuAbMnWMIkprOJYgDu6ZbWJkBrEEaDxuiVJk9oPgWtu)LZH6oXm5PwKZtYabx7eYvYI4V2Z4wohQ7eZKN0o9oPOU4MhsUDn1EW3fxraPDuYqsxO0cmBGn1iGJOiogIRiG0WhaVRJ88a6UgbCefXXGti244n8bW76ippGURzilFa3MAIXHMuQU4MhsU2TSntEc0pbAS23cdXnpK0KXI6cSZhc7mKLpGtVTf58KmqW1oHCLSi(R9mULTzYtG(jqJL2d((HMuQU4MhsU2TSntEc0pbAS0BFJropjdeCTtixjlI)ApJB5COUtmtEI9p0uIH1wBttMWegda]] )

end
