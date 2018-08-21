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
            
            startsCombat = true,
            texture = 1373907,

            usable = function () return combo_points.current > 0 end,
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
    
        package = "Subtlety",
    } )


    spec:RegisterPack( "Subtlety", 20180819.1415, [[d40u1aqiPI6rueTjOuFIsvQrbvQtbv0QGk0RuLmlOk3IIGDjLFrP0WGcDmOOLjvYZOuX0Gu6AqLSnif9nOcACqk4CsfP1rrinpPsDpPQ9rP4GuQswifPhcf0ePuvxKsLInsPs8rkvQAKqfiNKsvyLIuVeQa1mPuP0nPuj1oHs(jubyOuQIwkKc9uv1uvL6QuQuzRuQK8vkc1Er5VQ0GLCyQwmepwutgvxgzZu4ZQIrRItRy1qfqVwKmBc3we7g43GgoKCCPIy5e9CLMoPRtjBxQW3POgpuGZdPA9ueI5dv1(fMHj7n7ZDLyy1fgXenGr0aMDAdt0IjoK9v0rrSpkpNYFi2h4je7)TqubPOZ(OC0fqNZEZ(l0sMj2)OkQ1e1wBFg9yH0YWeB3jXs46abzPBO2Uts2webeXwed3e4uh2IscngbT2(EizxyA77UW8IgHpw09BHOcsrVTtsM9rSgHApame2N7kXWQlmIjAaJObm70gMOft7Gw7W(ULEGs2)pjyi7ZPnZ(VpZg1Sr5rHYZP8hkkOruEwhiikXS6gLbugfoik1iMOq8L4rbbrPhkQ)KyjCDGamu6gAutckOuBr6iT9ikNZjEu4GNCQOuyu6HIsHOIcAeLEOO4KHBj0O8SoqquIz1wKos)(qskQzJA1riIAHjuuDafUoIrrpkesnteikSMNJIiCofLd4rz30XSzs6kfLECnk7ruMDGgLcJsslu0bfLHLupKSX(Iz1L9M9xLCHEio7ndlmzVzFc4icIZmL9ZYrj54SpILHrBvYf6PzHI99Soqa7VhNdnVQCsrmLHvxS3SpbCebXzMY(z5OKCC2pdtqGxuWbOBJtgtE0O6UpkmJYeIc3rPUGaAJteksExv6Q)qjnc4icIhf2rHyzy06WbZEAwOIcNSVN1bcy)SlexpRdeCfZQSVyw9c8eI9ngWShMYWYoS3SpbCebXzMY(EwhiG93JZHMxvoPi2plhLKJZ(QliG2wklj9Qu(aMoXIAeWreepkSJsDbb0MXa4xZKNcq72iGJiiEuyhfNqSmmAgdGFntEkaTBtsj(a2O6okmJc7OwuKqCvx(q622JLCsrG7Qqzsu9r1vuyhL6YhsB6KqxfE5dfLjeLKs8bSrztuOj7NrplOR6YhsxgwyYugwOL9M9jGJiioZu2plhLKJZ(lksiUQlFiDB7XsoPiWDvOmjkB6JYoSVN1bcy)9yjNue4UkuMWugw4I9M99Soqa7VhNdnVQCsrSpbCebXzMYuMY(CYWTek7ndlmzVzFpRdeW(PMCk2NaoIG4mtzkdRUyVzFc4icIZmL99Soqa7NDH46zDGGRywL9fZQxGNqSFMVmLHLDyVzFc4icIZmL9ZYrj54S)QKl0dXBUqW(EwhiG9LwGRN1bcUIzv2xmREbEcX(RsUqpeNPmSql7n7tahrqCMPSFwokjhN9vx(qAtNe6QWlFOOSjk0mkSJssj(a2O6oQNmpkSJkdtqGxuWbOBu20hfAJYeIc3rPtcfv3rHjgJcNrHJr1f77zDGa2hmphfr4CIPmSWf7n7tahrqCMPSFwokjhN9jajFqVXjJjpAuD3hvhUCCeb1wLCHEU6rs7bk4rHDuzycc8IcoaDBCYyYJgLn9rHw23Z6abSF2fIRN1bcUIzv2xmREbEcX(RsUqp3mFzkdl0K9M9jGJiioZu2plhLKJZ(zycc8IcoaDJYM(OqBuVIsDbb0gNiuK8UQ0v)HsAeWreepk8Xpk1LpK20jHUk8YhkQU7JcZOWoQmmbbErbhGUrztFu2H99Soqa7NDH46zDGGRywL9fZQxGNqSVXaM9Wugw4q2B2NaoIG4mtz)SCusoo7tas(GEJtgtE0O6UpQoC54icQTk5c9C1JK2duWJYeIcTymkCmQohfUJsDbb0Ml8SCu0BeWreepk8Xpk1feqB7X5qZxdy2ABeWreepk8Xpk1feqBj(QK8cnU7X5qZBJaoIG4rHt23Z6abSF2fIRN1bcUIzv2xmREbEcX(iwJGZugwOb2B2NaoIG4mtz)SCusoo7tas(GEJtgtE0OSPpkmXvuVIIaK8b9MKEia77zDGa23LzhqxfkLeqzkdRoL9M99Soqa77YSdOlklXsSpbCebXzMYugwyIr2B23Z6abSVyEo6EXbAXFsiGY(eWreeNzktzk7JsszycIRS3mSWK9M9jGJiioZuMYWQl2B2NaoIG4mtzkdl7WEZ(eWreeNzktzyHw2B2NaoIG4mtzkdlCXEZ(eWreeNzk73HlSi2hnXyuVIsDbb0whZdu2iGJiiEu4yu2bxr9kk1feqBj(QK8cnU7X5qZBJaoIG4rHJrHjgzFpRdeW(D4YXree73HlVapHy)vjxONREK0EGcotzyHMS3SVN1bcy)vjxOh2NaoIG4mtzkdlCi7n7tahrqCMPSVN1bcy)exMI4xdO8YjxpSpkjLHjiUExkdb8L9XexmLHfAG9M9jGJiioZu23Z6abS)ECo08fr4CAzFuskdtqC9Uugc4l7Jjtzy1PS3SVN1bcyFuqDGa2NaoIG4mtzktzFeRrWzVzyHj7n7tahrqCMPSFwokjhN9rSmmA7XLOiaXVicNtBBvpNkkB6JQRonkSJArrcXvD5dPBBpwYjfbURcLjr1DFuyg1ROStu4yuUjcjhLA7XLOiaXVicNtBt6Gur1hvxr9kk0gfogLBIqYrP2ECjkcq8lIW502Koivu9rzh23Z6abS)ESKtkcCv4UmLHvxS3SpbCebXzMY(z5OKCC2FrrcXvD5dPBBpwYjfbURcLjrztFuDff(4hfILHrtp0LljNlGs(E5uMgTTQNtfLn9r1vNY(EwhiG93JLCsrG7Qqzctzyzh2B23Z6abS)JactqeoNyFc4icIZmLPmSql7n77zDGa2hXZPw1ryFc4icIZmLPmL9Z8L9MHfMS3SpbCebXzMY(z5OKCC2hXYWOHiGqUWA1MK8Sgf(4hL6YhsB6KqxfE5dfv39rHMymk8XpkChfILHrRdhm7PzHkkSJc3rHyzy02JZHMVicNtBZcvu4JFuziuWHMbT94CO5lIW502KuIpGnQU7JYoymkCgfozFpRdeW(OG6abmLHvxS3SpbCebXzMY(z5OKCC2FvYf6H4nj8XIyFpRdeW(iciKFnSKOZugw2H9M9jGJiioZu2plhLKJZ(RsUqpeVjHpwe77zDGa2hHKljtnGhMYWcTS3SpbCebXzMY(z5OKCC2FvYf6H4nj8XIyFpRdeW(gJKqeqiNPmSWf7n7tahrqCMPSFwokjhN9xLCHEiEtcFSi23Z6abSVdY0QsxCZUqWugwOj7n7tahrqCMPSFwokjhN95qTbMNJIiCo10jNAapSVN1bcy)f9eeOyVqJlNC9Wugw4q2B2NaoIG4mtz)SCusoo7RU8H0Moj0vHx(qr1Duzycc8IcoaDBCYyYJY(EwhiG9tCzkIFnGYlNC9WugwOb2B2NaoIG4mtz)SCusoo7l9HFPoiG2CoFBdikBIYoymkSJQZrTk5c9q8MlerHDuzycc8IcoaDBCYyYJgLn9rLrDtCm4UOiaN99Soqa7N4Yue)AaLxo56HPmS6u2B2NaoIG4mtz)SCusoo7NHjiWlk4a0TXjJjpAu20hvxr9kQvjxOhI3CHG99Soqa7VhNdnFreoNwMYWctmYEZ(eWreeNzk7NLJsYXz)ffjex1LpKUrztFu2jkSJId1gyEokIW5utNCQb8ef2rHyzy0w0tqGI9cnUCY1tZcvuyhfILHrBpohA(YDqMAwOyFpRdeW(7XsoPiWvHsGZHmLHfMyYEZ(eWreeNzk7NLJsYXz)ohfILHrBpohA(YDqMAwOIc7Oux(qAtNe6QWlFOO6UpkCf1ROuxqaTTwikjnSEOgbCebXzFpRdeW(7X5qZxUdYetzk7Vk5c9CZ8L9MHfMS3SpbCebXzMY(D4clI9ZqOGdndA7X5qZxUdYulFC5dTxdPN1bcCru20hfMnCiUyFpRdeW(D4YXree73HlVapHy)9WV6rs7bk4mLHvxS3SpbCebXzMY(z5OKCC2VZr1HlhhrqT9WV6rs7bk4rHDuCcXYWOzma(1m5Pa0UnjL4dyJQ7OWK99Soqa73HdM9Wugw2H9M9jGJiioZu23Z6abSpkiuCL0cTKzI9jmqL(1tGwaL9rlgzFdO8cimqzyHjtzyHw2B2NaoIG4mtz)SCusoo7tas(GEu20hfAXyuyhfbi5d6nozm5rJYM(OWeJrHDuDoQoC54icQTh(vpsApqbpkSJItiwggnJbWVMjpfG2TjPeFaBuDhfMSVN1bcy)94CO5esWzkdlCXEZ(eWreeNzk7NLJsYXzFChvNJsDbb0g3LPU7X5qZnc4icIhf(4hfhQnW8CueHZPMKs8bSrztFu4kQxrPUGaABTqusAy9qnc4icIhfoJc7OWDuD4YXreuBp8REK0EGcEu4JFuiwggTf9eeOyVqJlNC90KuIpGnkB6JcZwxrHp(rTOiH4QU8H0nkB6JcTrHDuziuWHMbTf9eeOyVqJlNC90KuIpGnkBIctmgfozFpRdeW(7X5qZxUdYetzyHMS3SpbCebXzMY(z5OKCC2xD5dPnDsORcV8HIQ7OYqOGdndAl6jiqXEHgxo56PjPeFal77zDGa2FpohA(YDqMyktzFJbm7H9MHfMS3SpbCebXzMY(z5OKCC2h3r15OuxqaTXDzQ7ECo0CJaoIG4rHp(r15OqSmmA7X5qZxUdYuZcvu4mkSJsD5dPnDsORcV8HIYeIssj(a2OSjk0mkSJssj(a2O6okDYPU6KqrHJr1vuyhfUJArrcXvD5dPBBpwYjfbURcLjr1DuOnk8XpQohfILHrBrpbbk2l04YjxpnlurHt23Z6abSpyEokIW5etzy1f7n7tahrqCMPSVN1bcyFW8CueHZj2plhLKJZ(lksiUQlFiDB7XsoPiWDvOmjkB6JQROWokCh1IIeIR6Yhs32ESKtkcCxfktIQ7(OWvu4JFuQliG2wklj9Qu(aMoXIAeWreepkCgf2r15OqSmmA7X5qZxUdYuZcvuyhL6YhsB6KqxfE5dfLn9rH7OWvuVIc3r1vu4yuzycc8IcoaDJcNrHZOWokjziP94icI9ZONf0vD5dPldlmzkdl7WEZ(eWreeNzk7NLJsYXzFjL4dyJQ7OYqOGdndAl6jiqXEHgxo56PjPeFaBuVIctmgf2rLHqbhAg0w0tqGI9cnUCY1ttsj(a2O6UpkCff2rPU8H0Moj0vHx(qrzcrjPeFaBu2evgcfCOzqBrpbbk2l04YjxpnjL4dyJ6vu4I99Soqa7dMNJIiCoXugwOL9M9jGJiioZu2plhLKJZ(iwggTf9eeOyVqJlNC90Sqff2rH7O6CuQliG24Um1DpohAUrahrq8OWh)OwuKqCvx(q622JLCsrG7QqzsuDhvxrHp(rHyzy02JZHMVChKPMfQOWj77zDGa2FPSK0Rs5dy6elIPmSWf7n7tahrqCMPSFwokjhN9xuKqCvx(q622JLCsrG7Qqzsu20hvxr9kk1feqBCxM6UhNdn3iGJiiEuVIsDbb0gyEo6QUifjBeWreeN99Soqa7Vuws6vP8bmDIfXugwOj7n77zDGa2N6y2mjDLyFc4icIZmLPmLPSFhKChiGHvxyet0agXHDHgAyIlC1PSVzxcgWZY(My7fAel7bw29MOrf17df1KGck1OmGYOS3CYWTeQ9okj1jwJK4rTWekk3sHjUs8OYhh8qBlsB3oakk0AIgfgcbDqsL4rzVFY8wIJb27Ouyu27Nm3EhfUXedWzlshPThjOGsL4rHdJYZ6abrjMv3wKM9rjHgJGyFtgLDdgqzlL4rHqgqjfvgMG4Aui0Za2wu2RCMqPBuaiWeoUmXWseLN1bc2OGab6TiTN1bc2gkjLHjiU2Bi8nvK2Z6abBdLKYWeexF1BRB9Kqa11bcI0EwhiyBOKugMG46REBnGqEK2Kr9boQ9a1OK(WJcXYWG4rTQRBuiKbusrLHjiUgfc9mGnkhWJcLKmbuqvhWtuZgfhcOwK2Z6abBdLKYWeexF1B7cCu7bQ3vDDJ0Mmk7UL4rPWO4KXaOOmFiqukmkRLIAvYf6jkm0(BuqzuiwJGtYns7zDGGTHsszycIRV6TTdxooIGWd4ju)QKl0ZvpsApqbhVoCHf1JMy8L6ccOToMhOSrahrqCC0o46L6ccOTeFvsEHg394CO5TrahrqCCetmgP9SoqW2qjPmmbX1x92Uk5c9eP9SoqW2qjPmmbX1x92M4Yue)AaLxo56bpuskdtqC9Uugc4BpM4ks7zDGGTHsszycIRV6TDpohA(IiCoT4HsszycIR3LYqaF7Xms7zDGGTHsszycIRV6TffuhiishPnzu2nyaLTuIhf1bjrpkDsOO0dfLNvOmQzJY7WhHJiOwK2Z6abBFQjNksBYOWWdLtffgA)nkxJYyKRgP9SoqW(Q32SlexpRdeCfZQ4b8eQpZ3iTjJcnAbIYWsiqpQ18O5dTrPWO0df1xjxOhIhfAeQUoqqu4gb9O4Wb8e1cXlQrJYakZ0gfkiumGNOgJOaq9mGNOMnkVdFeoIGWzls7zDGG9vVTslW1Z6abxXSkEapH6xLCHEioEJr)QKl0dXBUqePnzu2luOeOhfwZZrreoNIY1O66vuyO9mkULCaprPhkkJrUAuyIXOwkdb8fVOCdLKrPhxJcTVIcdTNrngrnAuegGAK0gL5rpdik9qrbimqJYUhdTFuqzuZgfaQrzHks7zDGG9vVTG55OicNt4ng9QlFiTPtcDv4LpKnOj2skXhW29tM3sCma7mmbbErbhGU20Jwta36KqDJjgXjo2vK2KrHHqWoCsgL1oGNO8O(k5c9efgA)OmFiqusYZNb8eLEOOiajFqpk9iP9af8OCapQJ3XaEIAr5zkkdOmkxJsq(QrH2OWq7zK2Z6ab7REBZUqC9SoqWvmRIhWtO(vjxONBMV4ng9eGKpO34KXKhT7(oC54icQTk5c9C1JK2duWXodtqGxuWbOBJtgtEuB6rBK2KrzxgWSNOCnk0(kkZJEGwAu2)Jxu46vuMh9eL9)rHBOLUdNIAvYf6bNrApRdeSV6Tn7cX1Z6abxXSkEapH6ngWSh8gJ(mmbbErbhGU20J2xQliG24eHIK3vLU6pusJaoIG44JV6YhsB6KqxfE5d1DpMyNHjiWlk4a01ME7ePnzu2DlfLhfI1i4KmkZhceLK88zaprPhkkcqYh0JspsApqbpkCNmaRnk0IXOgJOaqaff0ik7LWZYrrhVO(hNdnhLDbMTw8IYb8OSR9vjzuqJO(hNdnVrnBuljOSsCCgP9SoqW(Q32SlexpRdeCfZQ4b8eQhXAeC8gJEcqYh0BCYyYJ2DFhUCCeb1wLCHEU6rs7bk4MaAXio2zCRUGaAZfEwok6nc4icIJp(QliG22JZHMVgWS12iGJiio(4RUGaAlXxLKxOXDpohAEBeWreehNrAtgLDl0mTAuOKduok6rnGOCHikOru6HIYEzpTBJcHYU1srnAuz3APnkpk7Em0(rApRdeSV6T1LzhqxfkLeqXBm6jajFqVXjJjpQn9yIRxeGKpO3K0dbI0EwhiyF1BRlZoGUOSelfP9SoqW(Q3wX8C09Id0I)KqanshPnzuMAncoj3iTjJ6FSKtkce1B4Ur5AuD1PVI6FCjkcq8Omv4CAJAvpNABrH57OCnk0OdsffM4fLfQOuyuOnkxJcn6Gur1fErzHkkfgfUIY1OqJoivu2js7zDGGTHyncE)ESKtkcCv4U4ng9iwggT94sueG4xeHZPTTQNtztFxDk2lksiUQlFiDB7XsoPiWDvOmP7EmFzhC0nri5OuBpUefbi(fr4CABshKQVRxOfhDtesok12JlrraIFreoN2M0bP6TtK2Z6abBdXAe8x92Uhl5KIa3vHYe8gJ(ffjex1LpKUT9yjNue4UkuMytFx4JpILHrtp0LljNlGs(E5uMgTTQNtztFxDAK2Z6abBdXAe8x92(iGWeeHZPiTN1bc2gI1i4V6TfXZPw1rI0rAtgfgcHco0myJ0EwhiyBz(2JcQdeG3y0Jyzy0qeqixyTAtsEwXhF1LpK20jHUk8YhQ7E0eJ4JpUrSmmAD4GzpnluyJBeldJ2ECo08fr4CABwOWh)mek4qZG2ECo08fr4CABskXhW2DVDWioXzK2Z6abBlZ3x92IiGq(1WsIoEJr)QKl0dXBs4JffP9SoqW2Y89vVTiKCjzQb8G3y0Vk5c9q8Me(yrrApRdeSTmFF1BRXijebeYXBm6xLCHEiEtcFSOiTN1bc2wMVV6T1bzAvPlUzxiWBm6xLCHEiEtcFSOiTN1bc2wMVV6TDrpbbk2l04Yjxp4ng9CO2aZZrreoNA6KtnGNiTN1bc2wMVV6TnXLPi(1akVCY1dEJrV6YhsB6KqxfE5d1DgMGaVOGdq3gNmM8OrApRdeSTmFF1BBIltr8RbuE5KRh8gJEPp8l1bb0MZ5BBa2yhmIDNxLCHEiEZfcSZWee4ffCa624KXKh1M(mQBIJb3ffb4rApRdeSTmFF1B7ECo08fr4CAXBm6ZWee4ffCa624KXKh1M(UETk5c9q8MlerApRdeSTmFF1B7ESKtkcCvOe4CiEJr)IIeIR6YhsxB6Td2CO2aZZrreoNA6KtnGhSrSmmAl6jiqXEHgxo56PzHcBeldJ2ECo08L7Gm1SqfP9SoqW2Y89vVT7X5qZxUdYeEJrFNrSmmA7X5qZxUdYuZcf2QlFiTPtcDv4Lpu3946L6ccOT1crjPH1d1iGJiiEKosBYOSldy2dj3iTjJchmrOIYcvuynphfr4CkQXiQrJA2OCeOLgLcJsAbIcAPTOSpmkauJYAPOWY0O4wYb8eL9DqMWlQXik1feqjEudqHrzFxMkQ)X5qZTiTN1bc2MXaM90dMNJIiCoH3y0J7oRUGaAJ7Yu394CO5gbCebXXh)oJyzy02JZHMVChKPMfkCIT6YhsB6KqxfE5dzcskXhWAdAITKs8bSDRto1vNech7cBCVOiH4QU8H0TThl5KIa3vHYKUrl(43zeldJ2IEccuSxOXLtUEAwOWzK2KrzxBj0HdvDaprbT0D4uu23bzkkiik1LpKUrPhxJY8ierjMoOOmGYO0dff3s66abrbnIcR55OicNtrzE0tusYqs7jkULCaprHYbCkzYrngrHo0kQJ3bfLG2nk94GOqZOux(q6gfugfkHJEuMh9e1NYssJ6nLpGPtSOwK2Z6abBZyaZEE1BlyEokIW5eEz0Zc6QU8H0Tht8gJ(ffjex1LpKUT9yjNue4UkuMytFxyJ7ffjex1LpKUT9yjNue4UkuM0DpUWhF1feqBlLLKEvkFatNyrnc4icIJtS7mILHrBpohA(YDqMAwOWwD5dPnDsORcV8HSPh346fU7chZWee4ffCa6ItCITKmK0ECebfPnzuOrYqs7jkSMNJIiCoff5sb6rngrnAuMhHikcdqnskkULCapr9rpbbk2wu2hgLECnkjziP9e1ye1hA)OEiDJssoh9Ogqu6HIcqyGgfU2wK2Z6abBZyaZEE1BlyEokIW5eEJrVKs8bSDNHqbhAg0w0tqGI9cnUCY1ttsj(a2xyIrSZqOGdndAl6jiqXEHgxo56PjPeFaB394cB1LpK20jHUk8YhYeKuIpG1Mmek4qZG2IEccuSxOXLtUEAskXhW(cxrAtg1NYssJ6nLpGPtSOO4wYb8e1h9eeOyBrzIh9eL9DzQO(hNdnhLd4rLyj0bLGIsD5dPBuUyHrbbc0JIBjhWtu)JZHMJY(oitrHBlGoIO0JK2duWJAarbimqJsmacNTiTN1bc2MXaM98Q32LYssVkLpGPtSi8gJEeldJ2IEccuSxOXLtUEAwOWg3DwDbb0g3LPU7X5qZnc4icIJp(lksiUQlFiDB7XsoPiWDvOmP7UWhFeldJ2ECo08L7Gm1SqHZiTjJYep6jkcaTEorPU8H0nkxy2rFJYAPO(u(nLJccIcdTFls7zDGGTzmGzpV6TDPSK0Rs5dy6elcVXOFrrcXvD5dPBBpwYjfbURcLj2031l1feqBCxM6UhNdn3iGJii(l1feqBG55OR6IuKSrahrq8iTN1bc2MXaM98Q3wQJzZK0vkshPnzuFLCHEIcdHqbhAgSrAtgfoisGIKrzx5YXreuK2Z6abBBvYf65M5BFhUCCebHhWtO(9WV6rs7bk441HlSO(mek4qZG2ECo08L7Gm1Yhx(q71q6zDGaxytpMnCiUI0Mmk7khm7jklGG2nkZuuUKIYrGwAukmQSJkkiik77Gmfv(4YhABrHdaiqpkZhceLDza8OmXKNcq7g1Sr5iqlnkfgL0cef0sBrApRdeSTvjxONBMVV6TTdhm7bVXOVZD4YXreuBp8REK0EGco2CcXYWOzma(1m5Pa0UnjL4dy7gZiTjJYEcHIOmGYO(hNdnNqcEuVI6FCo08QYjffLfqq7gLzkkxsr5iqlnkfgv2rffeeL9DqMIkFC5dTTOWbaeOhL5dbIYUmaEuMyYtbODJA2OCeOLgLcJsAbIcAPTiTN1bc22QKl0ZnZ3x92IccfxjTqlzMWZakVacd0EmXJWav6xpbAb0E0IXiTN1bc22QKl0ZnZ3x92UhNdnNqcoEJrpbi5d620JwmInbi5d6nozm5rTPhtmIDN7WLJJiO2E4x9iP9afCS5eILHrZya8RzYtbODBskXhW2nMrAtgLjE0tu23LPI6FCo0CuqGa9OSVdYuuMpeikSMNJIiCofL5riIAvh9OSq1IYUBPO4wYb8e1h9eeOyJckJYrGDqrPhjThOG3I0EwhiyBRsUqp3mFF1B7ECo08L7GmH3y0J7oRUGaAJ7Yu394CO5gbCebXXhFouBG55OicNtnjL4dyTPhxVuxqaTTwikjnSEOgbCebXXj24UdxooIGA7HF1JK2duWXhFeldJ2IEccuSxOXLtUEAskXhWAtpMTUWh)ffjex1LpKU20JwSZqOGdndAl6jiqXEHgxo56PjPeFaRnyIrCgP9SoqW2wLCHEUz((Q3294CO5l3bzcVXOxD5dPnDsORcV8H6odHco0mOTONGaf7fAC5KRNMKs8bSr6iTjJ6RKl0dXJcncvxhiisBYOShgrTk5c9e1SrzHcVOmtrjjxiqpkZoqJsHrzTuu)JZHMxvoPOOuyuieGmgDJYqctIspuuO8DNoOOqGaRfVOOoiquJruMPOCjfLRrL4yquzurHBdjmjk9qrHsszycIRrzxByFC2I0EwhiyBRsUqpeVFpohAEv5KIWBm6rSmmARsUqpnlurAtgLDzaZEIY1Oq7ROWq7zuMh9aT0OS)hVOW1ROmp6jk7)XlkhWJcnJY8ONOS)pk3qjzu2voy2tK2Z6abBBvYf6H4V6Tn7cX1Z6abxXSkEapH6ngWSh8gJ(mmbbErbhGUnozm5r7Uhtta3QliG24eHIK3vLU6pusJaoIG4yJyzy06WbZEAwOWzK2KrzV0O6kk1LpKUrzE0tuFkljnQ3u(aMoXIIkfrOIYcvu2LbWJYetEkaTBuiOhvg9Syapr9pohAEv5KIArApRdeSTvjxOhI)Q3294CO5vLtkcVm6zbDvx(q62JjEJrV6ccOTLYssVkLpGPtSOgbCebXXwDbb0MXa4xZKNcq72iGJiio2CcXYWOzma(1m5Pa0UnjL4dy7gtSxuKqCvx(q622JLCsrG7QqzsFxyRU8H0Moj0vHx(qMGKs8bS2GMrApRdeSTvjxOhI)Q329yjNue4UkuMG3y0VOiH4QU8H0TThl5KIa3vHYeB6TtK2Z6abBBvYf6H4V6TDpohAEv5KIy)ffLzy1fAIjtzkJb]] )

end
