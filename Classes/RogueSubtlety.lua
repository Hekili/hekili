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
        shuriken_combo = not PTR and {
            id = 245640,
            duration = 15,
            max_stack = 4,
        } or nil,
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

        sharpened_blades = not PTR and {
            id = 272916,
            duration = 20,
            max_stack = 30,
        } or nil,

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
            
            usable = function () return target.casting end,
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
            cooldown = 180,
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
            
            spend = function () return ( ( PTR and azerite.blade_in_the_shadows.enabled ) and 38 or 40 ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
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
            	if not PTR then addStack( "shuriken_combo", 15, active_enemies - 1 ) end
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
                if not PTR then removeBuff( "sharpened_blades" ) end
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
            
            usable = function () return boss end,
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


    spec:RegisterPack( "Subtlety", 20181119.2126, [[da1rrbqifQEeOInPaFssvrnkOkDkOkwffv5vGQMfrv3cuP2Le)IcmmjL6yqLwMcLNrbzAsQY1iQyBuuvFtsjzCGkHZbvKwNKsQ5bv4EG0(Ku8pkOqDqkO0cLu5HevYePOYfbvISrOI4JsQkYiLuvOtcQKSsf0lPGcMjOsu3KckANui)usvjdvsv1sPGQNcPPcv1vHkQ2QKQs9vOIYzPGczVu6Vs1GfDyHfdXJLYKr1Lr2mu(mOmAfDAvwTKQcEnfz2OCBjz3a)wvdhehxsjwoHNR00jDDISDkuFNOmEIk15viRhuj18POSFQ2IRfFlkpuYA0y1gx4cCXfxCAzmChZ8XfNAr1rqilkKOzkGrwuqurwuujeLr6ilkKye7dUfFl6(sIgzrNQczR1gyaStNsiL2xzWEvsSqVh0ebMAWEvndqypIbiybCZjJnaI4XogTgu)cYWJJVgu)gE3WFysuhvcrzKoQSxvZIIiDmfUcyrSO8qjRrJvBCHlWfxCXPLXQD9mFChZIgs68fwu0RsUSOZJZjGfXIYPTzrHJNOsikJ0rEA4pmjYhchpNQczR1gyaStNsiL2xzWEvsSqVh0ebMAWEvndqypIbiybCZjJnaI4XogTgu)cYWJJVgu)gE3WFysuhvcrzKoQSxvZhchpn6nMQqiHN4ItL3ZXQnUWfEc3EowTR11to(qFiC8uUMbagT1AFiC8eU90WY5e3tddxZKN67jNWcjM6z007bEYUvl(q44jC7PHtvVXe3tneWiTFyE2Ea)07bE(apnmdHjI7j2l80CuOZIpeoEc3EAy5CI7joFjpHRuQAlwu2T6AX3IUkfmDsCl(wJW1IVfLabcJ426SOnXPK4clkIegwzvky6SibXIgn9EGfDNb)LTQ4mrw1A0yw8TOeiqye3wNfTjoLexyrBFfY3H8hq3cNWU2PEIdOEIRNWTN41tnyeqlCIGqI(QIqdyuvHabcJ4EoWtejmSIXb42zrcIN4XIgn9EGfTfmwpA69Go7w1IYUv7GOISOyh42PvTgzil(wuceimIBRZI2eNsIlSOisyyLDgcieG4DewWPTSA0m5znq9CmCQNd8eVEoUNAWiGwWoaVlJctaA3cbcegX90mZ8KtisyyfSdW7YOWeG2TibXt8yrJMEpWIUtjXzIaD931QwJQNfFlkbcegXT1zrJMEpWIUZG)YwvCMilAtCkjUWIQbJaAzPMG0UsTj4QfjQqGaHrCph4PgmcOfSdW7YOWeG2TqGaHrCph4jNqKWWkyhG3LrHjaTBrqvXbwpXHN465apxieJ11qaJ0TStjXzIa9vFrLNq9Cmph4PgcyKw0RI6635h5jC7PGQIdSEwJNMVfTnQXOUgcyKUwJW1QwJKJfFlkbcegXT1zrBItjXfw0X9udgb0cNiiKOVQi0agvviqGWiUNd8mGRjXPubHfCQFGUoP(od(lBlIayYtOEAiph45cHySUgcyKULDkjoteOV6lQ8eQNgYIgn9EGfDNb)LTQ4mrw1AK5BX3IsGaHrCBDw0M4usCHfDHqmwxdbmsxpRbQNgYIgn9EGfDNsIZeb6R(IkRAnQwzX3Ign9EGfDNb)LTQ4mrwuceimIBRZQw1IYjSqIPw8TgHRfFlA007bw0vPGPtlkbcegXT1zvRrJzX3IsGaHrCBDw0M4usCHfDCpxLcMojEjymlA007bwutxZKvTgzil(wuceimIBRZIgn9EGfTfmwpA69Go7w1IYUv7GOISOn(AvRr1ZIVfLabcJ426SOnXPK4cl6QuW0jXlbJzrJMEpWIkKa9OP3d6SBvlk7wTdIkYIUkfmDsCRAnsow8TOeiqye3wNfTjoLexyr1qaJ0IEvux)o)ipRXtZ3ZbEkOQ4aRN4WtynEPkKBph4z7Rq(oK)a66znq9SEEc3EIxp1RI8ehEIBT9epEAEEoMfnA69alk4GnvewWjRAnY8T4BrjqGWiUTolQXbtISOqe3loDux8AO3d8CGNleIX6AiGr6w2PK4mrG(QVOYZAG65yw0OP3dSOghIlqyKf14q0brfzrLwQdrCV40rDXRHEpWQwJQvw8TOeiqye3wNfTjoLexyrnoexGWOI0sDiI7fNoQlEn07bw0OP3dSOTGX6rtVh0z3Qwu2TAhevKfDvky6S34RvTgbxyX3IsGaHrCBDwuJdMezrhtoEcVNAWiGwm(G9IcbcegX90880qYXt49udgb0svSkj6pwFNb)LTfceimI7P555yYXt49udgb0Yod(lRJ9nPTqGaHrCpnpphR2EcVNAWiGwcw0eNoQqGaHrCpnppXT2EcVN4khpnppXRNleIX6AiGr6w2PK4mrG(QVOYZAG6PH8epw0OP3dSOghIlqyKf14q0brfzrxLcMo76uq78zCRAncNAX3IsGaHrCBDw0M4usCHfLaKa2OcNWU2PEIdOEACiUaHrLvPGPZUof0oFg3ZbE2(kKVd5pGUfoHDTt9SgOEwplA007bw0wWy9OP3d6SBvlk7wTdIkYIUkfmD2B81QwJWT2w8TOeiqye3wNfTjoLexyrjajGnQWjSRDQN4aQNghIlqyuzvky6SRtbTZNX9CGNAWiGw4HWuFNb)LviqGWiUNd8udgb0YsnbPDLAtWvlsuHabcJ4EoWZ2)m(lduwQjiTRuBcUArIksqSOrtVhyrBbJ1JMEpOZUvTOSB1oiQil6QuW0zVXxRAncxCT4BrjqGWiUTolAtCkjUWIsasaBuHtyx7upXbupnoexGWOYQuW0zxNcANpJ75ap1GraTWdHP(od(lRqGaHrCph45cHySUgcyKULDkjoteOV6lQ8SgOEoMNd8eVEoUNAWiGw2PK4mrGU(cqW)cbcegX90mZ8CCpB)Z4VmqzNsIZeb66lab)lsq8epw0OP3dSOTGX6rtVh0z3Qwu2TAhevKfDvky6S34RvTgH7yw8TOeiqye3wNfTjoLexyrBFfY3H8hq3cNWU2PEIdOEIRNMzMNAiGrArVkQRFNFKN4aQN465apBFfY3H8hqxpRbQNgYIgn9EGfTfmwpA69Go7w1IYUv7GOISOyh42PvTgHRHS4BrjqGWiUTolAtCkjUWIUqigRRHagPBzNsIZeb6R(IkpH6z98CGNTVc57q(dORN1a1Z6zrJMEpWI2cgRhn9EqNDRArz3QDqurwuSdC70QwJWTEw8TOeiqye3wNfTjoLexyrjajGnQWjSRDQN4aQNghIlqyuzvky6SRtbTZNXTOrtVhyrBbJ1JMEpOZUvTOSB1oiQilkI0X4w1AeUYXIVfLabcJ426SOnXPK4clkbibSrfoHDTt9SgOEIRC8eEpjajGnQiiyeWIgn9EGfneTaqD9fccOw1AeUMVfFlA007bw0q0ca1HiXwYIsGaHrCBDw1AeU1kl(w0OP3dSOSd2u3E9bjoSkcOwuceimIBRZQw1IcrqTVcjul(wJW1IVfLabcJ426SQ1OXS4BrjqGWiUToRAnYqw8TOeiqye3wNvTgvpl(wuceimIBRZQwJKJfFlA007bw0vPGPtlkbcegXT1zvRrMVfFlkbcegXT1zrJMEpWIwfcteVJ9IoNcDArHiO2xHeAFP2d4Rffx5yvRr1kl(wuceimIBRZIgn9EGfDNb)L1rybNwlkeb1(kKq7l1EaFTO4AvRrWfw8TOrtVhyrH869alkbcegXT1zvRArXoWTtl(wJW1IVfLabcJ426SOnXPK4clQgmcOLDg8xwh7BsBHabcJ4EoWtejmSc4Gn1TBmbGrbOrfjiEoWZfcXyDneWiDl7usCMiqF1xu5znq9CmpH3td5P55PgmcOLLAcs7k1MGRwKOcbcegXTOrtVhyrjJVTrIqjRAnAml(wuceimIBRZI2eNsIlSO41ZX9udgb0cpeM67m4VScbcegX90mZ8CCprKWWk7m4VSopanQibXt845ap1qaJ0IEvux)o)ipHBpfuvCG1ZA8089CGNcQkoW6jo8uVMPUEvKNMNNJ55apXRNleIX6AiGr6w2PK4mrG(QVOYtC4z980mZ8CCprKWWk7OkKNT9hRZPqNfjiEIhlA007bwuWbBQiSGtw1AKHS4BrjqGWiUTolA007bwuWbBQiSGtw0M4usCHfDCpnoexGWOI0sDiI7fNoQlEn07bEoWZfcXyDneWiDl7usCMiqF1xu5znq9Cmph4jE9udgb0YsnbPDLAtWvlsuHabcJ4EAMzEgW1K4uQaoytD7gtayuaAuHabcJ4EAMzEUqigRRHagPBzNsIZeb6R(IkpXbupLJN4XZbEoUNisyyLDg8xwNhGgvKG45ap1qaJ0IEvux)o)ipRbQN41t54j8EIxphZtZZZ2xH8Di)b01t84jE8CGNcctq7mqyKfTnQXOUgcyKUwJW1QwJQNfFlkbcegXT1zrBItjXfwubvfhy9ehE2(NXFzGYoQc5zB)X6Ck0zrqvXbwpH3tCRTNd8S9pJ)YaLDufYZ2(J15uOZIGQIdSEIdOEkhph4PgcyKw0RI6635h5jC7PGQIdSEwJNT)z8xgOSJQqE22FSoNcDweuvCG1t49uow0OP3dSOGd2urybNSQ1i5yX3IsGaHrCBDw0M4usCHffrcdRSJQqE22FSoNcDwKG45apXRNJ7PgmcOfEim13zWFzfceimI7PzM5jIegwzNb)L15bOrfjiEIhlA007bw0LAcs7k1MGRwKiRAnY8T4BrjqGWiUTolAtCkjUWIUqigRRHagPBzNsIZeb6R(IkpRbQNJ5j8EQbJaAHhct9Dg8xwHabcJ4EcVNAWiGwahSPUAWmrIcbcegXTOrtVhyrxQjiTRuBcUArISQ1OALfFlA007bwuY4BBKiuYIsGaHrCBDw1Qw0gFT4Bncxl(wuceimIBRZI2eNsIlSOisyyfe2)CM0Qfbfn1tZmZtejmSYoQc5zB)X6Ck0zrcINd8eVEIiHHv2zWFzDewWPTibXtZmZZ2)m(ldu2zWFzDewWPTiOQ4aRN4aQN4wBpXJfnA69alkKxVhyvRrJzX3IsGaHrCBDwuqurwuybJAbJrITJ8pWIgn9EGffwWOwWyKy7i)dSOnXPK4cl64EUkfmDs8I4HjrEoWtejmSYoQc5zB)X6Ck0zrcIvTgzil(wuceimIBRZI2eNsIlSOJ75QuW0jXlIhMe55aprKWWk7OkKNT9hRZPqNfjiw0OP3dSOsl1pLQwRAnQEw8TOeiqye3wNfTjoLexyrrKWWk7OkKNT9hRZPqNfjiw0OP3dSOiS)5DmjXiRAnsow8TOeiqye3wNfTjoLexyrrKWWk7OkKNT9hRZPqNfjiw0OP3dSOiKyjHPdaZQwJmFl(wuceimIBRZI2eNsIlSOisyyLDufYZ2(J15uOZIeelA007bwuStqiS)5w1AuTYIVfLabcJ426SOnXPK4clkIegwzhvH8ST)yDof6SibXIgn9EGfnanAvrW6TGXSQ1i4cl(wuceimIBRZI2eNsIlSOJ7jIegwzNb)L15bOrfjiEoWtejmSYoLeNjc01xac(xKG45aprKWWk7usCMiqxFbi4FrqvXbwpXbupnurow0OP3dSO7m4VSopanYIkTu)XW6WAClkUw1Aeo1IVfLabcJ426SOnXPK4clkIegwzNsIZeb66lab)lsq8CGNisyyLDkjoteORVae8ViOQ4aRN4aQNgQihlA007bw0DufYZ2(J15uOtlQ0s9hdRdRXTO4AvRr4wBl(wuceimIBRZI2eNsIlSO8xlGd2urybNk61mDayEoWt8654EQbJaAzNsIZeb66lab)leiqye3tZmZtnyeql7m4VSo23K2cbcegX90mZ8CHqmwxdbms3YoLeNjc0x9fvEIdpnKNMzMNJ7z7Fg)Lbk7usCMiqxFbi4FrcIN4XIgn9EGfDhvH8ST)yDof60QwJWfxl(wuceimIBRZI2eNsIlSOI44DYycOLGZ3Ieeph4jE9udbmsl6vrD978J8ehE2(kKVd5pGUfoHDTt90mZ8CCpxLcMojEjymph4z7Rq(oK)a6w4e21o1ZAG6zdsVkK7(cHaCpXJfnA69alAvimr8o2l6Ck0PvTgH7yw8TOeiqye3wNfTjoLexyrfXX7KXeqlbNVLd4znEAOA7jC7PioENmMaAj48TWLeHEpWZbEoUNRsbtNeVemMNd8S9viFhYFaDlCc7AN6znq9SbPxfYDFHqaUfnA69alAvimr8o2l6Ck0PvTgHRHS4BrjqGWiUTolAtCkjUWI2(kKVd5pGUfoHDTt9SgOEoMNW75QuW0jXlbJzrJMEpWIUZG)Y6iSGtRvTgHB9S4BrjqGWiUTolAtCkjUWIUqigRRHagPRN1a1td55aph3tnyeql7m4VSo23K2cbcegX9CGN8xlGd2urybNk61mDayEoWZX9Cvky6K4LGX8CGNT)z8xgOSJQqE22FSoNcDwKG45apB)Z4VmqzNb)L15bOrL2meWO1ZAG6jUw0OP3dSO7usCMiqxFbi4VvTgHRCS4BrjqGWiUTolAtCkjUWIUqigRRHagPRN1a1td55ap1GraTSZG)Y6yFtAleiqye3ZbEYFTaoytfHfCQOxZ0bG55aprKWWk7OkKNT9hRZPqNfjiw0OP3dSO7usCMiqxFbi4VvTgHR5BX3IsGaHrCBDw0M4usCHfDCprKWWk7m4VSopanQibXZbEQHagPf9QOU(D(rEIdOEkhpH3tnyeqlReIscmjyuHabcJ4EoWZX9uehVtgtaTeC(wKGyrJMEpWIUZG)Y68a0iRAvl6QuW0zVXxl(wJW1IVfLabcJ426SOghmjYI2(NXFzGYod(lRZdqJkTziGrBhten9EqW8SgOEIBPwjhlA007bwuJdXfimYIACi6GOISO7K31PG25Z4w1A0yw8TOeiqye3wNfTjoLexyrh3tJdXfimQStExNcANpJ75ap5eIegwb7a8UmkmbODlcQkoW6jo8exph4z7Rq(oK)a6w4e21o1ZA8exlA007bwuJdWTtRAnYqw8TOeiqye3wNff7fDaj3Q1iCTOrtVhyrH8pRlO9LenYIsYTkIEu9sa1IwVABvRr1ZIVfLabcJ426SOnXPK4clkbibSrEwdupRxT9CGNeGeWgv4e21o1ZAG6jU12ZbEoUNghIlqyuzN8Uof0oFg3ZbEYjejmSc2b4Dzuycq7weuvCG1tC4jUEoWZ2xH8Di)b0TWjSRDQN14jUw0OP3dSO7m4VSkIXTQ1i5yX3IsGaHrCBDw0M4usCHffVEoUNAWiGw4HWuFNb)LviqGWiUNMzMN8xlGd2urybNkcQkoW6znq9uoEcVNAWiGwwjeLeysWOcbcegX9epEoWt8654EQbJaAbCWM6QbZejkeiqye3ZbEoUNAWiGw4HWuFNb)LviqGWiUNMzMNJ7PXH4cegvKwQdrCV40rDXRHEpWtZmZZ2xH8Di)b0TWjSRDQN4aQN46jE8CGN41tJdXfimQStExNcANpJ7PzM5jIegwzhvH8ST)yDof6SiOQ4aRN1a1tClJ5PzM55cHySUgcyKULDkjoteOV6lQ8SgOEwpph4z7Fg)Lbk7OkKNT9hRZPqNfbvfhy9SgpXT2EIhlA007bw0Dg8xwNhGgzvRrMVfFlkbcegXT1zrBItjXfwuneWiTOxf11VZpYtC4z7Fg)Lbk7OkKNT9hRZPqNfbvfhy9CGNJ7PioENmMaAj48TibXIgn9EGfDNb)L15bOrw1QwuePJXT4Bncxl(wuceimIBRZI2eNsIlSOJ7PgmcOfWbBQRgmtKOqGaHrCph4jE9CCp1GraTWdHP(od(lRqGaHrCpnZmpB)Z4VmqzhvH8ST)yDof6SiOQ4aRN14jU12t845aprKWWk7meqiaX7iSGtBz1OzYZAG65y4uph45cHySUgcyKULDkjoteOV6lQ8ehq9eVEAipnppd4AsCkv2ziGqaI3rybN2IiaM8epw0OP3dSO7usCMiqx)DTQ1OXS4BrjqGWiUTolAtCkjUWIUqigRRHagPRN1a1ZXSOrtVhyr3PK4mrG(QVOYQwJmKfFlA007bwuyS)RqybNSOeiqye3wNvTgvpl(w0OP3dSOirZ0QbIfLabcJ426SQvTQf1ysS3dSgnwTXfUa3Ap2yLXWT2YXIkleGdaBTOWvvqEHsCpRvEgn9EGNSB1T4dTOleQznAmZhxlkeXJDmYIchprLqugPJ80WFysKpeoEovfYwRnWayNoLqkTVYG9QKyHEpOjcm1G9QAgGWEedqWc4MtgBaeXJDmAnO(fKHhhFnO(n8UH)WKOoQeIYiDuzVQMpeoEA0BmvHqcpXfNkVNJvBCHl8eU9CSAxRRNC8H(q44PCndamAR1(q44jC7PHLZjUNggUMjp13toHfsm1ZOP3d8KDRw8HWXt42tdNQEJjUNAiGrA)W8S9a(P3d88bEAygcte3tSx4P5OqNfFiC8eU90WY5e3tC(sEcxPu1w8H(q44jCj5MAskX9eHWEb5z7Rqc1tec2b2INg2wJGORNGha3ZquHjX8mA69G1ZhWgv8HrtVhSficQ9viHcfJfRjFy007bBbIGAFfsOWd1Gqcwfb0qVh4dJMEpylqeu7RqcfEOgG9p3hchprbbKD(QNI44EIiHHrCpxn01tec7fKNTVcjupriyhy9maCpHii4gYR6bG55TEYFav8HrtVhSficQ9viHcpudwqazNV2xn01hgn9EWwGiO2xHek8qnyvky60hgn9EWwGiO2xHek8qnOkeMiEh7fDof6uEicQ9viH2xQ9a(cfx54dJMEpylqeu7RqcfEOgSZG)Y6iSGtR8qeu7RqcTVu7b8fkU(WOP3d2ceb1(kKqHhQbqE9EGp0hchpHlj3utsjUNKXKyKN6vrEQtYZOPVWZB9mmoowGWOIpeoEA40QuW0PNhMNq(Dpeg5jEbVNglXaKiqyKNeGQoA98aE2(kKqXJpmA69Gf6QuW0PpmA69GfEOMUMj5pmOJVkfmDs8sWy(q44PCnPMjpLlZTEgQNyNyvFy007bl8qnOfmwpA69Go7wvEqurqB81hchpnCjGNysm2ipxzN2M06P(EQtYtuLcMojUNg(RHEpWt8ImYt(FayEUV8EEQNyVOrRNq(NDayEEyEcEDEayEERNHXXXcegHNIpmA69GfEOgiKa9OP3d6SBv5brfbDvky6K4YFyqxLcMojEjymFiC80WcbcBKNgDWMkcl4KNH65yW7PCv)EYLehaMN6K8e7eR6jU12ZLApGVY7zGPKWtDgQN1dEpLR63ZdZZt9KKBiNGwpLD68aEQtYtaj3QN1NKlZ55l88wpbV6PeeFy007bl8qnaCWMkcl4K8hguneWiTOxf11VZpQgZFGGQIdS4awJxQc5Eq7Rq(oK)a6wd06b34vVkch4wB8yEJ5dHJN1xa2ipBZaaJ8u8AO3d88W8ug55mmM8eI4EXPJ6Ixd9EGNlPEgaUNvsm9GWip1qaJ01tjifFy007bl8qnW4qCbcJKheveuPL6qe3loDux8AO3dK34GjrqHiUxC6OU41qVhmyHqmwxdbms3YoLeNjc0x9fv1aDmFiC8S(f3loDKNg(RHEpWWypHltA951tyNXKNHNnraXZa5LupjajGnYtSx4PojpxLcMo9uUm36jErKogNeEU6XyEkOfc1uppfpfpnmscI8EEQNTa4jc5Pod1Z9QGWOIpmA69GfEOg0cgRhn9EqNDRkpiQiORsbtN9gFL)WGACiUaHrfPL6qe3loDux8AO3d8HWXtC(sCp13toHDaYtztc4P(EkTKNRsbtNEkxMB98fEIiDmojwFy007bl8qnW4qCbcJKheve0vPGPZUof0oFgxEJdMebDm5aVgmcOfJpyVOqGaHrCZZqYbEnyeqlvXQKO)y9Dg8x2wiqGWiU5nMCGxdgb0Yod(lRJ9nPTqGaHrCZBSAdVgmcOLGfnXPJkeiqye38WT2WJRCmp8UqigRRHagPBzNsIZeb6R(IQAGAi84dHJNY1d2JtcpL2daZZWtuLcMo9uUmNNYMeWtbfT5bG5PojpjajGnYtDkOD(mUNbG75mm(aW8CHenYtSx4zOEYOyvpRNNYv97dJMEpyHhQbTGX6rtVh0z3QYdIkc6QuW0zVXx5pmOeGeWgv4e21ofhqnoexGWOYQuW0zxNcANpJpO9viFhYFaDlCc7ANwd065dHJN4StNEAUqyYt0zWFzY7zW23tPL8m8evPGPtpLlZ5PSjb8uqrBEayEQtYtcqcyJ8uNcANpJ7za4EIsnbPEIp1MGRwKipV1tbf8rfFy007bl8qnOfmwpA69Go7wvEqurqxLcMo7n(k)HbLaKa2OcNWU2P4aQXH4cegvwLcMo76uq78z8bAWiGw4HWuFNb)LviqGWi(anyeqll1eK2vQnbxTirfceimIpO9pJ)YaLLAcs7k1MGRwKOIeeFiC8eND60tZfctEIod(lZZawCGv9SsIPheg5PgcyKUY7PmYZhWg5zleKNbYlPEsasaBuXt4sYDJGO3dQ1EI)lab)98wpfuWhv8HrtVhSWd1GwWy9OP3d6SBv5brfbDvky6S34R8hgucqcyJkCc7ANIdOghIlqyuzvky6SRtbTZNXhObJaAHhct9Dg8xwHabcJ4dwieJ11qaJ0TStjXzIa9vFrvnqhBaEhxdgb0YoLeNjc01xac(xiqGWiUzMnE7Fg)Lbk7usCMiqxFbi4FrccE8HWXtCYbUD6zOEwp49u2PZxs90COY7PCG3tzNo90COEI3xs3JtEUkfmDIhFy007bl8qnOfmwpA69Go7wvEqurqXoWTt5pmOTVc57q(dOBHtyx7uCafxZmtdbmsl6vrD978JWbuCh0(kKVd5pGU1a1q(q44jo70PNMd1ZGTVNyh42PNH6z9G3ZawCGv9KK7OPSrEwpp1qaJ01t8(s6ECYZvPGPt84dJMEpyHhQbTGX6rtVh0z3QYdIkck2bUDk)HbDHqmwxdbms3YoLeNjc0x9fvqR3G2xH8Di)b0TgO1ZhchpX5l5z4jI0X4KWtztc4PGI28aW8uNKNeGeWg5Pof0oFg3hgn9EWcpudAbJ1JMEpOZUvLheveuePJXL)WGsasaBuHtyx7uCa14qCbcJkRsbtNDDkOD(mUpeoEcx(LrR6jeX9Ith55b8mympFmp1j5PHT(Hl7jc1cPL88upBH0sRNHN1NKlZ5dJMEpyHhQbHOfaQRVqqav(ddkbibSrfoHDTtRbkUYbEcqcyJkccgb8HrtVhSWd1Gq0ca1HiXwYhgn9EWcpudyhSPU96dsCyveq9H(q44zDshJtI1hchprNsIZeb8e)Fxpd1ZXWPW7j6meqiaX9SowWP1ZvJMPT4johIN67PH8udbmsxpHqcpfbWuXt0WyYtSx45QuW0PNhMNs7bG5PrhSPUAWmrcpFHNMleM8eDg8xMNYMeWti)UhcJk(WOP3d2cI0X4q3PK4mrGU(7k)HbDCnyeqlGd2uxnyMirHabcJ4dW74AWiGw4HWuFNb)LviqGWiUzM1(NXFzGYoQc5zB)X6Ck0zrqvXb2AWT24zaIegwzNHacbiEhHfCAlRgnt1aDmC6GfcXyDneWiDl7usCMiqF1xuHdO41qMxaxtItPYodbecq8ocl40webWeE8HrtVhSfePJXHhQb7usCMiqF1xuj)HbDHqmwxdbms3AGoMpmA69GTGiDmo8qnag7)kewWjFy007bBbr6yC4HAas0mTAG4d9HWXt56Fg)LbwFy007bBPXxOqE9EG8hguejmScc7FotA1IGIMAMzisyyLDufYZ2(J15uOZIeKb4frcdRSZG)Y6iSGtBrcIzM1(NXFzGYod(lRJWcoTfbvfhyXbuCRnE8HWXtCsWyhaMNirZKN67jNWcjM65PuLNsBaJQ1EIZxYtzNo9eDufYZwpFmpnhf6S4dJMEpyln(cpudKwQFkvjpiQiOWcg1cgJeBh5FG8hg0XxLcMojEr8WKObisyyLDufYZ2(J15uOZIeeFy007bBPXx4HAG0s9tPQv(dd64RsbtNeViEys0aejmSYoQc5zB)X6Ck0zrcIpmA69GT04l8qnaH9pVJjjgj)HbfrcdRSJQqE22FSoNcDwKG4dJMEpyln(cpudqiXscthaM8hguejmSYoQc5zB)X6Ck0zrcIpmA69GT04l8qna7eec7FU8hguejmSYoQc5zB)X6Ck0zrcIpmA69GT04l8qnianAvrW6TGXK)WGIiHHv2rvipB7pwNtHolsq8HWXtC(sEAUa0ipFmm4gwJ7jcH9cYtDsEIDIv9eDkjoteWtu9fvEIj(kpX)fGG)E2(kA98afFy007bBPXx4HAWod(lRZdqJKxAP(JH1H14qXv(dd64isyyLDg8xwNhGgvKGmarcdRStjXzIaD9fGG)fjidqKWWk7usCMiqxFbi4FrqvXbwCa1qf54dHJN4fNdy0UEgmbf8rEkbXteQfsl5PmYt9FtEIod(lZtCY3Kw84P0sEIoQc5zRNpggCdRX9eHWEb5PojpXoXQEIoLeNjc4jQ(IkpXeFLN4)cqWFpBFfTEEGIpmA69GT04l8qnyhvH8ST)yDof6uEPL6pgwhwJdfx5pmOisyyLDkjoteORVae8VibzaIegwzNsIZeb66lab)lcQkoWIdOgQihFiC8eNVKNOJQqE265d8S9pJ)YaEI3atjHNyNyvpn6GnvewWj84PeGr76PmYZqqEc7pamp13tipepX)fGG)EgaUN83tWREodJjprNb)L5jo5BsBXhgn9EWwA8fEOgSJQqE22FSoNcDk)HbL)AbCWMkcl4urVMPdaBaEhxdgb0YoLeNjc01xac(xiqGWiUzMPbJaAzNb)L1X(M0wiqGWiUzMTqigRRHagPBzNsIZeb6R(IkCyiZmB82)m(ldu2PK4mrGU(cqW)Iee84dHJNWvyEgC(6ziipLGiVNl4GqEQtYZhqEk70PNSxgTQN4JV5kEIZxYtztc4jF0bG5jwSkj8uNbWt5Q(9Ktyx7upFHNGx9Cvky6K4Ek705lPEgGrEkx1FXhgn9EWwA8fEOgufcteVJ9IoNcDk)HbvehVtgtaTeC(wKGmaVAiGrArVkQRFNFeoAFfY3H8hq3cNWU2PMz24RsbtNeVem2G2xH8Di)b0TWjSRDAnqBq6vHC3xieGJhFiC8eUcZtW7zW5RNYogZt(rEk705b8uNKNasUvpnuTx59uAjpnmXmNNpWtKFxpLD68LupdWipLR63ZaW9e8EUkfmDw8HrtVhSLgFHhQbvHWeX7yVOZPqNYFyqfXX7KXeqlbNVLduJHQnClIJ3jJjGwcoFlCjrO3dgm(QuW0jXlbJnO9viFhYFaDlCc7ANwd0gKEvi39fcb4(WOP3d2sJVWd1GDg8xwhHfCAL)WG2(kKVd5pGUfoHDTtRb6yWVkfmDs8sWy(q44PHv90qW7PStNVK6j6m4VmpXjFtA9uAjpX)fGG)Ek70PNOV58maCpnxaAKNck4JkEIZipLDmMNqEiEQZFjpriSxqEQtYtStSQNR(IkpBFfTEEGIpmA69GT04l8qnyNsIZeb66lab)L)WGUqigRRHagPBnqn0GX1GraTSZG)Y6yFtAleiqyeFa)1c4GnvewWPIEntha2GXxLcMojEjySbT)z8xgOSJQqE22FSoNcDwKGmO9pJ)YaLDg8xwNhGgvAZqaJ2AGIRpeoEAyvpne8Ek70PNOZG)Y8eN8nP1tPL8e)xac(7PStNEI(MZZGjOGpYtjifFy007bBPXx4HAWoLeNjc01xac(l)HbDHqmwxdbms3AGAObAWiGw2zWFzDSVjTfceimIpG)AbCWMkcl4urVMPdaBaIegwzhvH8ST)yDof6SibXhgn9EWwA8fEOgSZG)Y68a0i5pmOJJiHHv2zWFzDEaAurcYaneWiTOxf11VZpchqLd8AWiGwwjeLeysWOcbcegXhmUioENmMaAj48TibXh6dHJN4KdC7KeRpeoEcxY4BBKiuYZ5bBsR6jeX9Ith5zOEog8EQHagPRNYoD6j6m4VmpXjFtA9eVYbEpLD60tuQji1t8P2eC1Ie55b8m48tVhGhpda3tJoytT(86z9nbGrbOrEkbP4dJMEpylyh42juY4BBKius(ddQgmcOLDg8xwh7BsBHabcJ4dqKWWkGd2u3UXeagfGgvKGmyHqmwxdbms3YoLeNjc0x9fv1aDm4nK5PbJaAzPMG0UsTj4QfjQqGaHrCFiC80Warq8ucINgDWMkcl4KNhMNN65TEgiVK6P(EkKaE(sAXtZ9EcE1tPL80O68KljoampnxaAK8EEyEQbJakX98a67P5cHjprNb)Lv8HrtVhSfSdC7eEOgaoytfHfCs(ddkEhxdgb0cpeM67m4VScbcegXnZSXrKWWk7m4VSopanQibbpd0qaJ0IEvux)o)i4wqvXb2Am)bcQkoWId9AM66vrM3ydW7cHySUgcyKULDkjoteOV6lQWr9mZSXrKWWk7OkKNT9hRZPqNfji4XhchpnmLy6XFvpampFjDpo5P5cqJ88bEQHagPRN6mupLDmMNSZyYtSx4Pojp5sIqVh45J5PrhSPIWco5PStNEkimbTtp5sIdaZtibGtvxZZdZZrVKNZWyYtgTRN6maEA(EQHagPRNVWtiSyKNYoD6jk1eK6j(uBcUArIk(WOP3d2c2bUDcpudahSPIWcojFBuJrDneWiDHIR8hg0XnoexGWOI0sDiI7fNoQlEn07bdwieJ11qaJ0TStjXzIa9vFrvnqhBaE1GraTSutqAxP2eC1IeviqGWiUzMfW1K4uQaoytD7gtayuaAuHabcJ4Mz2cHySUgcyKULDkjoteOV6lQWbu5GNbJJiHHv2zWFzDEaAurcYaneWiTOxf11VZpQgO4voWJ3XmV2xH8Di)b0fp4zGGWe0odeg5dHJNgoHjOD6PrhSPIWco5jfc2ippmpp1tzhJ5jj3qob5jxsCayEIoQc5zBXtZ9EQZq9uqycANEEyEI(MZtyKUEkOGpYZd4PojpbKCREkNT4dJMEpylyh42j8qnaCWMkcl4K8hgubvfhyXr7Fg)Lbk7OkKNT9hRZPqNfbvfhyHh3ApO9pJ)YaLDufYZ2(J15uOZIGQIdS4aQCgOHagPf9QOU(D(rWTGQIdS10(NXFzGYoQc5zB)X6Ck0zrqvXbw4LJpeoEIsnbPEIp1MGRwKip5sIdaZt0rvipBlEIZoD6P5cHjprNb)L55dyJ8KljoamprNb)L5P5cqJ8eVsa9yEQtbTZNX98aEci5w9KDacpfFy007bBb7a3oHhQbl1eK2vQnbxTirYFyqrKWWk7OkKNT9hRZPqNfjidW74AWiGw4HWuFNb)LviqGWiUzMHiHHv2zWFzDEaAurccE8HWXtC2PtpjWlbB6PgcyKUEgmzXO1tPL8eLA4tnpFGNYL5k(WOP3d2c2bUDcpudwQjiTRuBcUArIK)WGUqigRRHagPBzNsIZeb6R(IQAGog8AWiGw4HWuFNb)LviqGWio8AWiGwahSPUAWmrIcbcegX9HrtVhSfSdC7eEOgqgFBJeHs(qFiC8evPGPtpLR)z8xgy9HWXZ6Jedcj8S(oexGWiFy007bBzvky6S34luJdXfimsEqurq3jVRtbTZNXL34GjrqB)Z4VmqzNb)L15bOrL2meWOTJjIMEpiy1af3sTso(q44z9DaUD6PeGr76PmYZqqEgiVK6P(E2ciE(apnxaAKNTziGrBXZ6laBKNYMeWtCYb4EIZOWeG21ZB9mqEj1t99uib88L0IpmA69GTSkfmD2B8fEOgyCaUDk)HbDCJdXfimQStExNcANpJpGtisyyfSdW7YOWeG2TiOQ4aloWDq7Rq(oK)a6w4e21oTgC9HWXZ6)FMNyVWt0zWFzveJ7j8EIod(lBvXzI8ucWOD9ug5ziipdKxs9uFpBbepFGNMlanYZ2meWOT4z9fGnYtztc4jo5aCpXzuycq765TEgiVK6P(EkKaE(sAXhgn9EWwwLcMo7n(cpudG8pRlO9LensESx0bKCRqXvEsUvr0JQxcOqRxT9HrtVhSLvPGPZEJVWd1GDg8xwfX4YFyqjajGnQgO1R2diajGnQWjSRDAnqXT2dg34qCbcJk7K31PG25Z4d4eIegwb7a8UmkmbODlcQkoWIdCh0(kKVd5pGUfoHDTtRbxFiC8eND60tZfctEIod(lZZhWg5P5cqJ8u2KaEA0bBQiSGtEk7ympxng5PeKIN48L8KljoamprhvH8S1Zx4zG8gtEQtbTZNXlEwFbyJ8eHWEb5j2bUDsI1ZdZtzKNZWyYZOcINAWiGUEgaUNqe3loDKNIxd9EqXhgn9EWwwLcMo7n(cpud2zWFzDEaAK8hgu8oUgmcOfEim13zWFzfceimIBMz8xlGd2urybNkcQkoWwdu5aVgmcOLvcrjbMemQqGaHrC8maVJRbJaAbCWM6QbZejkeiqyeFW4AWiGw4HWuFNb)LviqGWiUzMnUXH4cegvKwQdrCV40rDXRHEpWmZAFfY3H8hq3cNWU2P4akU4zaEnoexGWOYo5DDkOD(mUzMHiHHv2rvipB7pwNtHolcQkoWwduClJzMzleIX6AiGr6w2PK4mrG(QVOQgO1Bq7Fg)Lbk7OkKNT9hRZPqNfbvfhyRb3AJhFy007bBzvky6S34l8qnyNb)L15bOrYFyq1qaJ0IEvux)o)iC0(NXFzGYoQc5zB)X6Ck0zrqvXb2bJlIJ3jJjGwcoFlsq8H(q44jQsbtNe3td)1qVh4dHJNWvyEUkfmD65TEkbrEpLrEkOGXg5PSaOEQVNsl5j6m4VSvfNjYt99eHae2PRNyIVYtDsEcj29mM8e5bsR8EsgtappmpLrEgcYZq9SkKBpBq8eVyIVYtDsEcrqTVcjupnmXmhEk(WOP3d2YQuW0jXHUZG)YwvCMi5pmOisyyLvPGPZIeeFiC8eNCGBNEgQN1dEpLR63tzNoFj1tZHkVNYbEpLD60tZHkVNbG7P57PStNEAoupdmLeEwFhGBN(WOP3d2YQuW0jXHhQbTGX6rtVh0z3QYdIkck2bUDk)HbT9viFhYFaDlCc7ANIdO4c34vdgb0cNiiKOVQi0agvviqGWi(aejmSIXb42zrccE8HWXt0PK4mrapX)31Zq9CmCk8EIodbecqCpRJfCA9C1OzA98aEIQuW0PNyVWtEufWiprEG0sBXZ6JpJ7j2l8eNCaUN4mkmbOD98W8eYV7HWOIpmA69GTSkfmDsC4HAWoLeNjc01Fx5pmOisyyLDgcieG4DewWPTSA0mvd0XWPdW74AWiGwWoaVlJctaA3cbcegXnZmoHiHHvWoaVlJctaA3Iee84dHJNgw1ZX8udbmsxpLD60tuQji1t8P2eC1Ie5PjIG4PeepXjhG7joJctaAxprg5zBuJDayEIod(lBvXzIk(WOP3d2YQuW0jXHhQb7m4VSvfNjs(2OgJ6AiGr6cfx5pmOAWiGwwQjiTRuBcUArIkeiqyeFGgmcOfSdW7YOWeG2TqGaHr8bCcrcdRGDaExgfMa0UfbvfhyXbUdwieJ11qaJ0TStjXzIa9vFrf0XgOHagPf9QOU(D(rWTGQIdS1y((q44jo705lPEAoIGqcprvrObmQYZaW90qEA4bW065J5zDSGtEEap1j5j6m4VS1Zt98wpL9cD6P0EayEIod(lBvXzI88bEAip1qaJ0T4dJMEpylRsbtNehEOgSZG)YwvCMi5pmOJRbJaAHtees0xveAaJQkeiqyeFqaxtItPccl4u)aDDs9Dg8x2webWeudnyHqmwxdbms3YoLeNjc0x9fvqnKpmA69GTSkfmDsC4HAWoLeNjc0x9fvYFyqxieJ11qaJ0TgOgYhgn9EWwwLcMojo8qnyNb)LTQ4mrw1Qwla]] )
    

end
