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

        -- Azerite Powers
        sharpened_blades = {
            id = 272916,
            duration = 20,
            max_stack = 30,
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
            
            cycle = "nightblade",

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

            cycle = function () return talent.find_weakness.enabled and "find_weakness" or nil end,
            
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
                gain( active_enemies + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
                removeBuff( "sharpened_blades" )
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


    spec:RegisterPack( "Subtlety", 20180902.2341, [[d00L(aqikv1JaeBcHmkKOofsHvjsvEfc1SqQ6wsLQDjLFHKmmaPJrrAzsL8mkIMgsrxJsHTHePVrPinoKi6CuQsRJsrmpaL7bW(Ou6GuQIwiLkpeqvtuKkxejcSrkc8rkcsJuKQIojseALsfVuKQsZKIG4MIuvTtKk)ejcAOueAPukQNc0urkDvPsrBLIG6RuQc7Lu)vPgSKdt1Ir0Jf1Kr1LH2mf(Su1OvYPvz1Iuv41IKzJYTfXUv1VbnCeCCPsPLtYZvmDIRtjBxKY3POgpGkNhjSEPsH5JKA)cRnvtRgK7cQPRlGAkLeO2lq7Q1LjPPPAqHccOgKGNt59Og89eudcArkmuOqdsWPGbDUMwn4aTuzudUeHWytOIQ(twwKTmmHQ5sSyUCWpRCdHQ5sYurYGKurA4DNJPrfbf04y4qLjQqB2p(qLjAZBBg2BHBqlsHHcfT5sYAqsRJjuIVMudYDb101fqnLscu7fOD16YKM0E7QlnOBjlOsdcEjaVgKJtwdcKOaTifgkueLnd7TWOdqIAjcHXMqfv9NSSiBzycvZLyXC5GFw5gcvZLKPIKbjPI0W7ohtJkckOXXWHktuH2SF8Hkt0M32mS3c3GwKcdfkAZLKJoajkqKGGjKOkQUOpQUaQPuYO6EuMAQnXKanktm9hDIoajkGF5Fpo2KOdqIQ7rzp5CKhv67LtfLaJIJgUftIYZYb)Oy3inni7gz00QbhbDMSqUMwnDMQPvdIVtYqU2onywDcQoxdsAzy0gbDMSAwe0GEwo4RbNLZHMhrDPqTOPRlnTAq8DsgY12PbZQtq15AWmmHeUjaVxMghnU8jrbmarzAuDpkkhL4m8LghrcOApIYfVhtA47KmKhfrrrAzy0sZ)BwnlcrrdnONLd(AWSZyBplh83SBeni7gz)EcQbnU)MLw00zsnTAq8DsgY12PbZQtq15AqsldJ2SCfb8r(MK5CCAJ45urzlGO6YE1GEwo4RbNLL6sH)wGZOfnD0utRgeFNKHCTDAqplh81GZY5qZJOUuOgmRobvNRbfNHV0gmRqzlyE9x3AHn8DsgYJIOOeNHV0mUNVnJEQhNPHVtYqEueffhjTmmAg3Z3Mrp1JZ0uyIF)efWIY0OikQHaYyBXv9OmTzzPUu4VhbQsIcquDffrrjUQhLMCj4wGB(Hr19OuyIF)eLTrrPAWmfzgUfx1JYOPZuTOPZgAA1G47KmKRTtdMvNGQZ1G2pkXz4lnoIeq1EeLlEpM0W3jzipkIIY7gO6eSrYCoUVFllCplNdnpnL)PIcquMmkIIAiGm2wCvpktBwwQlf(7rGQKOaeLj1GEwo4RbNLZHMhrDPqTOPJs10QbX3jzixBNgmRobvNRbhciJTfx1JYeLTaIYKAqplh81GZYsDPWFpcuLOfnD2unTAqplh81GZY5qZJOUuOgeFNKHCTDArlAqoA4wmrtRMot10Qb9SCWxdM6YP0G47KmKRTtlA66stRgeFNKHCTDAqplh81GzNX2Ewo4Vz3iAq2nY(9eudM5Jw00zsnTAq8DsgY12PbZQtq15AWrqNjlK3Cgtd6z5GVguz9Bplh83SBeni7gz)EcQbhbDMSqUw00rtnTAq8DsgY12PbZQtq15AqXv9O0Klb3cCZpmkBJIsJIOOuyIF)efWIQpZBjoWffrrLHjKWnb49YeLTaIIMr19OOCuYLGrbSOmfOrrJOsVO6sd6z5GVg8V(LqYCoQfnD2qtRgeFNKHCTDAWS6euDUgeFu1trJJgx(KOagGOsZvNtYW2iOZK1wwkCwqgpkIIkdtiHBcW7LPXrJlFsu2cikAQb9SCWxdMDgB7z5G)MDJObz3i73tqn4iOZK1oZhTOPJs10QbX3jzixBNgmRobvNRbZWes4Ma8EzIYwarrZOiokXz4lnoIeq1EeLlEpM0W3jzipkQPokXv9O0Klb3cCZpmkGbiktJIOOYWes4Ma8EzIYwarzsnONLd(AWSZyBplh83SBeni7gz)EcQbnU)MLw00zt10QbX3jzixBNgmRobvNRbhciJTfx1JY0MLL6sH)EeOkjkarrZOikQmmHeUjaVxMOSfqu0ud6z5GVgm7m22ZYb)n7grdYUr2VNGAqJ7VzPfnDusnTAq8DsgY12PbZQtq15Aq8rvpfnoAC5tIcyaIknxDojdBJGotwBzPWzbz8O6Eu0eOrLErz)OOCuIZWxAoZZQtOOHVtYqEuutDuIZWxAZY5qZBdy2AA47KmKhf1uhL4m8LwIpcQ2qJ9SCo080W3jzipkAOb9SCWxdMDgB7z5G)MDJObz3i73tqniP1X4ArtN9QPvdIVtYqU2onywDcQoxdIpQ6POXrJlFsu2ciktTruehf(OQNIMc7Xxd6z5GVg0vz)XTavk8fTOPZuGQPvd6z5GVg0vz)Xnbl2GAq8DsgY12PfnDMAQMwnONLd(Aq21VKzN(WI3NGVObX3jzixBNw0IgKGcZWesx00QPZunTAq8DsgY12PfnDDPPvdIVtYqU2oTOPZKAA1G47KmKRTtlA6OPMwni(ojd5A70IMoBOPvdIVtYqU2onyAoZc1GukqJI4OeNHV0s76HQg(ojd5rLErzsBefXrjodFPL4JGQn0yplNdnpn8DsgYJk9IYuGQb9SCWxdMMRoNKHAW0C1(9eudoc6mzTLLcNfKX1IMokvtRg0ZYbFn4iOZKLgeFNKHCTDArtNnvtRgeFNKHCTDAqplh81GjUkfY3gq1MJUS0GeuygMq6YEWm85Jg0uBOfnDusnTAq8DsgY12Pb9SCWxdolNdnVjzohhnibfMHjKUShmdF(ObnvlA6SxnTAqplh81GeGYbFni(ojd5A70Iw0Gg3FZstRMot10QbX3jzixBNgmRobvNRbfNHV0MLZHM3gWS10W3jzipkIIAiGm2wCvpktBwwQlf(7rGQKOSfqu2ikIII0YWO9x)sMDA43J(NXMfbnONLd(AqmTBYOYfulA66stRgeFNKHCTDAWS6euDUgKYrz)OeNHV04Uk1EwohAUHVtYqEuutDu2pksldJ2SCo08M7FgBweIIgrruuIR6rPjxcUf4MFyuDpkfM43przBuuAuefLct87NOawuYLtTLlbJk9IQROikkkh1qazST4QEuM2SSuxk83JavjrbSOOzuutDu2pksldJ2qrcjKnBOXMJUSAweIIgAqplh81G)1VesMZrTOPZKAA1G47KmKRTtd6z5GVg8V(LqYCoQbZQtq15AWHaYyBXv9OmTzzPUu4VhbQsIYwar1vueffLJsCg(sBWScLTG51FDRf2W3jzipkQPokVBGQtW2F9lz2PHFp6FgB47KmKhf1uh1qazST4QEuM2SSuxk83JavjrbmarzJOOruefL9JI0YWOnlNdnV5(NXMfHOikkXv9O0Klb3cCZpmkBbefLJYgrrCuuoQUIk9IkdtiHBcW7LjkAefnIIOOuOHcNLtYqnyMImd3IR6rz00zQw00rtnTAq8DsgY12PbZQtq15AqfM43prbSOYqiJdn)THIesiB2qJnhDz1uyIF)efXrzkqJIOOYqiJdn)THIesiB2qJnhDz1uyIF)efWaeLnIIOOex1JstUeClWn)WO6EukmXVFIY2OYqiJdn)THIesiB2qJnhDz1uyIF)efXrzdnONLd(AW)6xcjZ5Ow00zdnTAq8DsgY12PbZQtq15AqsldJ2qrcjKnBOXMJUSAweIIOOOCu2pkXz4lnURsTNLZHMB47KmKhf1uh1qazST4QEuM2SSuxk83JavjrbSO6kkQPoksldJ2SCo08M7FgBweIIgAqplh81GdMvOSfmV(RBTqTOPJs10QbX3jzixBNgmRobvNRbhciJTfx1JY0MLL6sH)EeOkjkBbevxrrCuIZWxACxLAplNdn3W3jzipkIJsCg(s7V(LmIZsHQg(ojd5Aqplh81GdMvOSfmV(RBTqTOPZMQPvd6z5GVget7MmQCb1G47KmKRTtlArdM5JMwnDMQPvdIVtYqU2onywDcQoxdsAzy0izqiNznstHEwIIAQJsCvpkn5sWTa38dJcyaIIsbAuutDuuoksldJwA(FZQzrikIIIYrrAzy0MLZHM3KmNJtZIquutDuziKXHM)2SCo08MK5CCAkmXVFIcyaIYKankAefn0GEwo4RbjaLd(ArtxxAA1G47KmKRTtd6z5GVgS3zy2zmunBsi81Gz1jO6Cn4iOZKfYBkyVfgf1uhL4QEuAYLGBbU5hgfWIQlGQbFpb1G9odZoJHQztcHVw00zsnTAq8DsgY12PbZQtq15AWrqNjlK3uWElud6z5GVgKKbH8THLIcTOPJMAA1G47KmKRTtdMvNGQZ1GJGotwiVPG9wOg0ZYbFnijQguL6(ETOPZgAA1G47KmKRTtdMvNGQZ1GJGotwiVPG9wOg0ZYbFnOXPqsgeY1IMokvtRgeFNKHCTDAWS6euDUgCe0zYc5nfS3c1GEwo4Rb9pJJOC2o7mMw00zt10QbX3jzixBNgmRobvNRb5qP9x)sizohBYLtDFVg0ZYbFn4qrcjKnBOXMJUS0IMokPMwni(ojd5A70Gz1jO6CnOYp(gtdFP5C(0Siefrrr5Oex1JstUeClWn)WOawuzycjCtaEVmnoAC5tIIAQJY(rnc6mzH8MZyrruuzycjCtaEVmnoAC5tIYwarLjStCGBpeWNhfn0GEwo4RbtCvkKVnGQnhDzPfnD2RMwni(ojd5A70Gz1jO6CnOYp(gtdFP5C(0UpkBJYKanQUhLYp(gtdFP5C(04wkxo4hfrrz)OgbDMSqEZzSOikQmmHeUjaVxMghnU8jrzlGOYe2joWThc4Z1GEwo4RbtCvkKVnGQnhDzPfnDMcunTAq8DsgY12PbZQtq15AWmmHeUjaVxMghnU8jrzlGO6kkIJAe0zYc5nNX0GEwo4RbNLZHM3KmNJJw00zQPAA1G47KmKRTtdMvNGQZ1GdbKX2IR6rzIYwarzYOikkouA)1VesMZXMC5u33hfrrrAzy0gksiHSzdn2C0LvZIqueffPLHrBwohAEZ9pJnlcAqplh81GZYsDPWFlq17COw00zAxAA1G47KmKRTtdMvNGQZ1G2pksldJ2SCo08M7FgBweIIOOex1JstUeClWn)WOagGOSruehL4m8L2yrkOYWQhB47KmKRb9SCWxdolNdnV5(NrTOfn4iOZK1oZhnTA6mvtRgeFNKHCTDAW0CMfQbZqiJdn)Tz5CO5n3)m2Ylx1JZ2q5z5GVZIYwarzAZMAdnONLd(AW0C15KmudMMR2VNGAWzX3YsHZcY4ArtxxAA1G47KmKRTtdMvNGQZ1G2pQ0C15KmSnl(wwkCwqgpkIIIJKwggnJ75BZON6XzAkmXVFIcyrzQg0ZYbFnyA(FZslA6mPMwni(ojd5A70GEwo4RbjaHSTchOLkJAqe4eLV9eO1lAqAcunObuTFe4enDMQfnD0utRgeFNKHCTDAWS6euDUgeFu1tru2cikAc0Oikk8rvpfnoAC5tIYwarzkqJIOOSFuP5QZjzyBw8TSu4SGmEueffhjTmmAg3Z3Mrp1JZ0uyIF)efWIYunONLd(AWz5CO5eKX1IMoBOPvdIVtYqU2onywDcQoxds5OSFuIZWxACxLAplNdn3W3jzipkQPokouA)1VesMZXMct87NOSfqu2ikIJsCg(sBSifuzy1Jn8DsgYJIgrruuuoQ0C15KmSnl(wwkCwqgpkQPoksldJ2qrcjKnBOXMJUSAkmXVFIYwarzARROOM6OgciJTfx1JY0MLL6sH)EeOkjkBbefnJIOOYqiJdn)THIesiB2qJnhDz1uyIF)eLTrzkqJIgAqplh81GZY5qZBU)zulA6OunTAq8DsgY12PbZQtq15AqXv9O0Klb3cCZpmkGfvgczCO5VnuKqczZgAS5OlRMct87hnONLd(AWz5CO5n3)mQfTObjTogxtRMot10QbX3jzixBNgmRobvNRbTFuIZWxA)1VKrCwku1W3jzipkIIIYrz)OeNHV04Uk1EwohAUHVtYqEuutDuziKXHM)2qrcjKnBOXMJUSAkmXVFIY2OmfOrrJOikksldJ2SCfb8r(MK5CCAJ45urzlGO6YEJIOOgciJTfx1JY0MLL6sH)EeOkjkGbikkhLjJk9IY7gO6eSnlxraFKVjzohNMY)urrdnONLd(AWzzPUu4Vf4mArtxxAA1G47KmKRTtdMvNGQZ1GdbKX2IR6rzIYwar1vuutDuKwggnzHBUcDodQ4ZMJz8K2iEovu2ciQUSxnONLd(AWzzPUu4VhbQs0IMotQPvd6z5GVgSNbHjKmNJAq8DsgY12PfnD0utRg0ZYbFniPNtnItQbX3jzixBNw0Iw0GPHQ5GVMUUaQPusGsjn1EBMsttTHg0SR(77hniLycbOsqEu20O8SCWpk2nY0IoAWHaM101fLAQgKGcACmudcKOaTifgkueLnd7TWOdqIAjcHXMqfv9NSSiBzycvZLyXC5GFw5gcvZLKPIKbjPI0W7ohtJkckOXXWHktuH2SF8Hkt0M32mS3c3GwKcdfkAZLKJoajkqKGGjKOkQUOpQUaQPuYO6EuMAQnXKanktm9hDIoajkGF5Fpo2KOdqIQ7rzp5CKhv67LtfLaJIJgUftIYZYb)Oy3iTOt0birrja4WSLG8OirdOcJkdtiDjksS)(PfL9mNrcYe1d)UVCvIHflkplh8NOGpJIw0XZYb)PrqHzycPlamy(Kk64z5G)0iOWmmH0fIbqLB1NGV4Yb)OJNLd(tJGcZWesxigavgqip6aKOaFNWSGsuk)4rrAzyG8OgXLjks0aQWOYWesxIIe7VFIYFEueuy3jaf5((OUjko8Xw0XZYb)PrqHzycPledGQ5DcZck7rCzIoajQU5G8OeyuC04EmkZl8JsGrznyuJGotwrb8PBIcQII06yCunrhplh8NgbfMHjKUqmaQsZvNtYq6Fpbbmc6mzTLLcNfKXPpnNzHaOuGsS4m8LwAxpu1W3jzip9mPniwCg(slXhbvBOXEwohAEA47KmKNEMc0OJNLd(tJGcZWesxigavJGotwrhplh8NgbfMHjKUqmaQsCvkKVnGQnhDzrpbfMHjKUShmdF(aWuBeD8SCWFAeuygMq6cXaOAwohAEtYCoo0tqHzycPl7bZWNpamn64z5G)0iOWmmH0fIbqfbOCWp6eDasuucaomBjipkmnurruYLGrjlmkplqvu3eLNMFmNKHTOJNLd(dGuxov0birb8lmNkkGpDtuUeLXPgj64z5G)qmaQYoJT9SCWFZUrO)9eeqMprhGeLnB9rzyXyue1y(K8cNOeyuYcJcuqNjlKhLndfxo4hfLjPiko8((Ogi9rDsugqvgNOiaHS77J6mI6HY6((OUjkpn)yojdPrl64z5G)qmaQuw)2ZYb)n7gH(3tqaJGotwiN(ZaWiOZKfYBoJfDasu2tceyuefDx)sizohJYLO6I4OaEtmkUL6((OKfgLXPgjktbAudMHpFOpk3qqvuYYLOOjXrb8MyuNruNefcCeoforz(K19rjlmQhbojktOaF6IcQI6MOEOeLfHOJNLd(dXaO6V(LqYCos)zaqCvpkn5sWTa38dTLsjsHj(9dW6Z8wIdCeLHjKWnb49YylaA2DklxccmtbknsVUIoajkGh(ZXrvuwZ99r5rbkOZKvuaF6IY8c)OuONx33hLSWOWhv9ueLSu4SGmEu(ZJA5PDFFudbpJrzavr5sum0hjkAgfWBIrhplh8hIbqv2zSTNLd(B2nc9VNGagbDMS2z(q)zaaFu1trJJgx(eGbinxDojdBJGotwBzPWzbzCIYWes4Ma8EzAC04YNylaAgDasuMG7VzfLlrrtIJY8jlOLev6aPpkBqCuMpzfv6aJIYqlzoog1iOZKfnIoEwo4pedGQSZyBplh83SBe6FpbbyC)nl6pdazycjCtaEVm2cGMelodFPXrKaQ2JOCX7XKg(ojd5utT4QEuAYLGBbU5hcmaMsugMqc3eG3lJTamz0birzpozfv6aJYzdmkJ7VzfLlrrtIJY797hjke48SWOikAgL4QEuMOOm0sMJJrnc6mzrJOJNLd(dXaOk7m22ZYb)n7gH(3tqag3FZI(ZaWqazST4QEuM2SSuxk83JavjaOjrzycjCtaEVm2cGMrhGev3CWO8OiToghvrzEHFuk0ZR77Jswyu4JQEkIswkCwqgpkkNCV1efnbAuNrup8XOGgrzpzEwDcf0hf4Y5qZrzcGzRH(O8Nhv63hbvrbnIcC5CO5jQBIAqgMfKtJOJNLd(dXaOk7m22ZYb)n7gH(3tqaKwhJt)zaaFu1trJJgx(eGbinxDojdBJGotwBzPWzbz8UttGME2NYIZWxAoZZQtOOHVtYqo1ulodFPnlNdnVnGzRPHVtYqo1ulodFPL4JGQn0yplNdnpn8DsgYPr0birzcbAghjkcQdQoHIOUpkNXIcAeLSWOSNMOjKOiXSBnyuNev2TgCIYJYekWNUOJNLd(dXaOYvz)XTavk8f6pda4JQEkAC04YNylatTbX4JQEkAkSh)OJNLd(dXaOYvz)Xnbl2Grhplh8hIbqf76xYStFyX7tWxIorhGeLDwhJJQj6aKOaxwQlf(rrlCMOCjQUSxIJcC5kc4J8OSJ5CCIAepNAAr1njeLaJYKrjUQhLjkcOkkL)PArb6PHrzavrnc6mzf1zeL1CFFu0D9lzeNLcvrbvrLoxLkkWLZHMJY8c)OiaN5izyl64z5G)0iToghWSSuxk83cCg6pda2xCg(s7V(LmIZsHQg(ojd5erz7lodFPXDvQ9SCo0CdFNKHCQPodHmo083gksiHSzdn2C0LvtHj(9JTMcuAqePLHrBwUIa(iFtYCooTr8CkBb0L9s0qazST4QEuM2SSuxk83JavjadaLnz65DduDc2MLRiGpY3KmNJtt5FkAeD8SCWFAKwhJtmaQMLL6sH)EeOkH(ZaWqazST4QEugBb0f1utAzy0KfU5k05mOIpBoMXtAJ45u2cOl7n64z5G)0iTogNyau1ZGWesMZXOJNLd(tJ06yCIbqfPNtnItgDIoajkGhczCO5FIoEwo4pTmFaqakh8P)maqAzy0izqiNznstHEwOMAXv9O0Klb3cCZpeyaOuGsn1uM0YWOLM)3SAweiIYKwggTz5CO5njZ540Siqn1ziKXHM)2SCo08MK5CCAkmXVFagatcuAqJOdqIYe4m299rr65urjWO4OHBXKOobtIYA8E0Mev3CWOmVWpQrqNjlKhD8SCWFAz(qmaQSgCFcMq)7jiGENHzNXq1SjHWN(ZaWiOZKfYBkyVfsn1IR6rPjxcUf4MFiW6cOrhplh8NwMpedGksgeY3gwkkO)mamc6mzH8Mc2BHrhplh8NwMpedGksunOk1990FgagbDMSqEtb7TWOJNLd(tlZhIbqLXPqsgeYP)mamc6mzH8Mc2BHrhplh8NwMpedGk)Z4ikNTZoJr)zaye0zYc5nfS3cJoEwo4pTmFigavdfjKq2SHgBo6YI(ZaahkT)6xcjZ5ytUCQ77JoajkkrJOCoFIYvyuweOpQ5pcyuYcJc(yuMpzffdAghjkAPnDTO6MdgL5f(rXP4((Om8rqvuYY)OaEtmkoAC5tIcQI6HsuJGotwipkZNSGwsu(truaVj2IoEwo4pTmFigavjUkfY3gq1MJUSO)maO8JVX0WxAoNpnlcerzXv9O0Klb3cCZpeyzycjCtaEVmnoAC5tOMA7pc6mzH8MZyeLHjKWnb49Y04OXLpXwazc7eh42db850i6aKOOenI6Hr5C(eL5JXIIFyuMpzDFuYcJ6rGtIYKaDOpkRbJk9BKUOGFuKWzIY8jlOLeL)uefWBIr5ppQhg1iOZKvl64z5G)0Y8HyauL4QuiFBavBo6YI(ZaGYp(gtdFP5C(0U3wtc0UR8JVX0WxAoNpnULYLd(ez)rqNjlK3CgJOmmHeUjaVxMghnU8j2cityN4a3EiGpp64z5G)0Y8HyaunlNdnVjzohh6pdazycjCtaEVmnoAC5tSfqxepc6mzH8MZyrhplh8NwMpedGQzzPUu4VfO6DoK(ZaWqazST4QEugBbysI4qP9x)sizohBYLtDFprKwggTHIesiB2qJnhDz1SiqePLHrBwohAEZ9pJnlcrhplh8NwMpedGQz5CO5n3)ms)zaW(KwggTz5CO5n3)m2SiqK4QEuAYLGBbU5hcma2GyXz4lTXIuqLHvp2W3jzip6eDasuMG7VzHQj6aKOOeK2nzu5cgvpktuRRFHJefb1bvNqruUeLniokXv9Omrz(KvuGlNdnhLjaMTMO8NhfDx)sMOmHXVh9pJrzri64z5G)0mU)MfamTBYOYfK(ZaG4m8L2SCo082aMTMg(ojd5eneqgBlUQhLPnll1Lc)9iqvITaSbrKwggT)6xYStd)E0)m2SieDasuPVisiklcrr31VesMZXOoJOojQBIYjHwsucmkL1hf0sArLoyupuIYAWOOZUO4wQ77JkD(Nr6J6mIsCg(cYJ6Ebgv6CvQOaxohAUfD8SCWFAg3FZIyau9x)sizohP)maqz7lodFPXDvQ9SCo0CdFNKHCQP2(KwggTz5CO5n3)m2SiqdIex1JstUeClWn)WURWe)(XwkLifM43patUCQTCjy61fruEiGm2wCvpktBwwQlf(7rGQeGrtQP2(KwggTHIesiB2qJnhDz1SiqJOdqIk9BXKJdf5((OGwYCCmQ05FgJc(rjUQhLjkz5suMpglk2LggLbufLSWO4wkxo4hf0ik6U(LqYCogL5twrPqdfoRO4wQ77JIG)Cm5YrDgrrb0kQLNggfdNjkz5FuuAuIR6rzIcQIIaZPikZNSIceZkuIIwmV(RBTWw0XZYb)PzC)nlIbq1F9lHK5CK(mfzgUfx1JYaWu6pdadbKX2IR6rzAZYsDPWFpcuLylGUiIYIZWxAdMvOSfmV(RBTWg(ojd5utT3nq1jy7V(Lm70WVh9pJn8DsgYPM6HaYyBXv9OmTzzPUu4VhbQsagaBqdISpPLHrBwohAEZ9pJnlcejUQhLMCj4wGB(H2cGY2Gyk3v6LHjKWnb49YqdAqKcnu4SCsggDasu2mAOWzffDx)sizohJcDfJIOoJOojkZhJffcCeofgf3sDFFuGuKqcztlQ0bJswUeLcnu4SI6mIceMUO6rzIsHoNIOUpkzHr9iWjrzJPfD8SCWFAg3FZIyau9x)sizohP)maOWe)(byziKXHM)2qrcjKnBOXMJUSAkmXVFi2uGsugczCO5VnuKqczZgAS5OlRMct87hGbWgejUQhLMCj4wGB(HDxHj(9JTziKXHM)2qrcjKnBOXMJUSAkmXVFi2grhGefiMvOefTyE9x3AHrXTu33hfifjKq20IYECYkQ05QurbUCo0Cu(ZJkXIjhbggL4QEuMOC2aJc(mkIIBPUVpkWLZHMJkD(NXOOS1lhlkzPWzbz8OUpQhbojk29inArhplh8NMX93SigavdMvOSfmV(RBTq6pdaKwggTHIesiB2qJnhDz1SiqeLTV4m8Lg3vP2ZY5qZn8DsgYPM6HaYyBXv9OmTzzPUu4VhbQsawxutnPLHrBwohAEZ9pJnlc0i6aKOShNSIcFOv)kkXv9Omr5mZoftuwdgfiMPfZrb)Oa(01IoEwo4pnJ7VzrmaQgmRqzlyE9x3AH0FgagciJTfx1JY0MLL6sH)EeOkXwaDrS4m8Lg3vP2ZY5qZn8DsgYjwCg(s7V(LmIZsHQg(ojd5rhplh8NMX93SigavyA3KrLly0j6aKOaf0zYkkGhczCO5FIoajQ0NiJaQIYe2vNtYWOJNLd(tBe0zYAN5dG0C15KmK(3tqaZIVLLcNfKXPpnNzHaYqiJdn)Tz5CO5n3)m2Ylx1JZ2q5z5GVZSfGPnBQnIoajkty)VzfL1ZWzIYmgLRWOCsOLeLaJk7eIc(rLo)Zyu5LR6XPffLWNrruMx4hLj4EEu2d0t94mrDtuoj0sIsGrPS(OGwsl64z5G)0gbDMS2z(qmaQsZ)Bw0FgaSFAU6Csg2MfFllfoliJtehjTmmAg3Z3Mrp1JZ0uyIF)amtJoajkteczrzavrbUCo0CcY4rrCuGlNdnpI6sHrz9mCMOmJr5kmkNeAjrjWOYoHOGFuPZ)mgvE5QECArrj8zueL5f(rzcUNhL9a9upotu3eLtcTKOeyukRpkOL0IoEwo4pTrqNjRDMpedGkcqiBRWbAPYi9gq1(rGtayk9iWjkF7jqRxaqtGgD8SCWFAJGotw7mFigavZY5qZjiJt)zaaFu1tHTaOjqjcFu1trJJgx(eBbykqjY(P5QZjzyBw8TSu4SGmorCK0YWOzCpFBg9upottHj(9dWmn6aKOShNSIkDUkvuGlNdnhf8zuev68pJrzEHFu0D9lHK5CmkZhJf1iofrzrOfv3CWO4wQ77JcKIesiBIcQIYjHPHrjlfoliJ3IoEwo4pTrqNjRDMpedGQz5CO5n3)ms)zaGY2xCg(sJ7Qu7z5CO5g(ojd5utnhkT)6xcjZ5ytHj(9JTaSbXIZWxAJfPGkdRESHVtYqoniIYP5QZjzyBw8TSu4SGmo1utAzy0gksiHSzdn2C0LvtHj(9JTamT1f1upeqgBlUQhLPnll1Lc)9iqvITaOjrziKXHM)2qrcjKnBOXMJUSAkmXVFS1uGsJOJNLd(tBe0zYAN5dXaOAwohAEZ9pJ0Fgaex1JstUeClWn)qGLHqghA(BdfjKq2SHgBo6YQPWe)(j6eDasuGc6mzH8OSzO4Yb)OdqIIs0iQrqNjROUjklc0hLzmkf6mgfrz2FjkbgL1GrbUCo08iQlfgLaJIeF04KjkdfmjkzHrrWN5sdJIe(wd9rHPHFuNruMXOCfgLlrL4axuzcrrzdfmjkzHrrqHzycPlrL(nshnArhplh8N2iOZKfYbmlNdnpI6sH0FgaiTmmAJGotwnlcrhGeLj4(Bwr5su0K4OaEtmkZNSGwsuPdK(OSbXrz(KvuPdK(O8NhfLgL5twrLoWOCdbvrzc7)nROJNLd(tBe0zYc5edGQSZyBplh83SBe6FpbbyC)nl6pdazycjCtaEVmnoAC5tagat7oLfNHV04isav7ruU49ysdFNKHCIiTmmAP5)nRMfbAeDasuGll1Lc)OOfotuUevx2lXrbUCfb8rEu2XCoornINtnrDFuGc6mzfLbuff3t8Emks4Bn40IoEwo4pTrqNjlKtmaQMLL6sH)wGZq)zaG0YWOnlxraFKVjzohN2iEoLTa6YEJoajk7PevxrjUQhLjkZNSIceZkuIIwmV(RBTWOsHiHOSieLj4EEu2d0t94mrrsruzkYS77JcC5CO5ruxkSfD8SCWFAJGotwiNyaunlNdnpI6sH0NPiZWT4QEugaMs)zaqCg(sBWScLTG51FDRf2W3jziNiXz4lnJ75BZON6XzA47KmKtehjTmmAg3Z3Mrp1JZ0uyIF)amtjAiGm2wCvpktBwwQlf(7rGQeaDrK4QEuAYLGBbU5h2DfM43p2sPrhGeL94Kf0sIkDisavrbkkx8Emjk)5rzYOSz)tnrbnIYoMZXOUpkzHrbUCo08e1jrDtuMHkzfL1CFFuGlNdnpI6sHrb)OmzuIR6rzArhplh8N2iOZKfYjgavZY5qZJOUui9Nba7lodFPXrKaQ2JOCX7XKg(ojd5e5DduDc2izoh33VLfUNLZHMNMY)uamjrdbKX2IR6rzAZYsDPWFpcuLaWKrhplh8N2iOZKfYjgavZYsDPWFpcuLq)zayiGm2wCvpkJTamz0XZYb)Pnc6mzHCIbq1SCo08iQlfQfTO1a]] )

end
