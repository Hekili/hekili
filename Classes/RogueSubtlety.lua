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


    spec:RegisterPack( "Subtlety", 20180930.2017, [[d40Cabqirk9ivLSjvfFsKQunkOOofuKvbfYRufnlkf3svPAxs5xKGHPc1XGswMiPNrIyAIuCnOuTnOu6BukjJJsj15ePQwNivX8GcUNkAFKKoOQsPwOiXdHc1efPYfvvkyJKiPpsIuXifPkLtsIewPk4LQkfAMKirUjjsv7KK4NKirnukLQLsPuEkOMkj0vvvkzRIuL8vsKYEj1FLQbl5WuTyqESOMmkxgzZq1NvvnAv60kTAsKk9AkvZgv3we7g43qgUQ0XPuILtXZvmDIRtjBxfY3jPgpukoVQW6vvkA(KO2VWAS0kQHzUqAvs9ySS1hN(k54wQhJf2QeSRHLhVKg(1Z29Fsdd8esddBbjCsEOHF9hCKZ0kQHhKLjtA4RiVt6rbf(x5Ab1YOefMnXI7YIazJJlkmBswbiocsbiC)7m6ifEni8LtJc2UHSnFzJc2UT1Tn0Vf1HTGeojpAZMK1WqwlxukaAinmZfsRsQhJLT(40xjh3s9ySW2uXsd7wYfz0WWBcgRHVlJranKgMrtwd)vuWwqcNKhrzBOFlko8vuxrEN0Jck8VY1cQLrjkmBIf3LfbYghxuy2KScqCeKcq4(3z0rk8Aq4lNgfSDdzB(YgfSDBRBBOFlQdBbjCsE0Mnjhh(kky6vOeiYeLso2MOs9ySS1r99Os940dwypoeh(kkm(6GFAspXHVI67r9TzmIf134MThLGIIr4UfxIYZYIarX3rAAy(oYOvudpc5C5smTIAvWsROgMaoeNy6u0WzZkKzDnmKfoEBeY5YTz9QH9SSiGgEUodPEeZAN0IwLu1kQHjGdXjMofnC2SczwxdNrjqO(lAbY0ye(MxjkmCgfwr99OWCuIZjG0ye9sM(igx8FkPrahItSO(efKfoE7ihSZTz9gfM0WEwweqdNDoV7zzrGoFhrdZ3r6apH0W4lyNRw0QOeTIAyc4qCIPtrdNnRqM11Wqw44T56MxcqSoe3z00gXZ2Js1ZOsn9J6tuyoQ0gL4Ccin8fW6Qj3oGMPrahItSOuw5OyeKfoEdFbSUAYTdOzAwVrHjnSNLfb0WZ1YS2jqxqZOfTkPrROgMaoeNy6u0WEwweqdpxNHupIzTtA4SzfYSUgwCobK2qzdjDHYxWAlwuJaoeNyr9jkX5eqA4lG1vtUDantJaoeNyr9jkgbzHJ3WxaRRMC7aAMMHs8fmrHHOWkQprnVeN3f38tY0MRLzTtG(iitsuNrLAuFIsCZpjnztOUG6SLI67rzOeFbtuQgf2QHZpYCQlU5NKrRcwArRc21kQHjGdXjMofnC2SczwxdN2OeNtaPXi6Lm9rmU4)usJaoeNyr9jk)BsMvOge3zuFbD5s956mK6PzCG9OoJsjr9jQ5L48U4MFsM2CTmRDc0hbzsI6mkLOH9SSiGgEUodPEeZAN0IwfSvROgMaoeNy6u0WzZkKzDn88sCExCZpjtuQEgLs0WEwweqdpxlZANa9rqMeTOvXwPvud7zzran8CDgs9iM1oPHjGdXjMofTOfnmJWDlUOvuRcwAf1WEwweqdBFZ21WeWH4etNIw0QKQwrnmbCioX0POH9SSiGgo7CE3ZYIaD(oIgMVJ0bEcPHZSrlAvuIwrnmbCioX0POHZMviZ6A4riNlxI1Coxd7zzranSXc09SSiqNVJOH57iDGNqA4riNlxIPfTkPrROgMaoeNy6u0WzZkKzDnS4MFsAYMqDb1zlfLQrHTr9jkdL4lyIcdr9NzTehBI6tuzuceQ)IwGmrP6zuPjQVhfMJs2ekkmefwhhfMIcJIkvnSNLfb0WG9)kqCNrArRc21kQHjGdXjMofn8ro3I0WPI9OEgL4CciTJ2FKPrahItSOWOOuc2J6zuIZjG0s8rithH3NRZqQNgbCioXIcJIkvSh1ZOeNtaPnxNHu3XrzRPrahItSOWOOs94OEgL4CcinN7zZkpAeWH4elkmkkSooQNrHf2JcJIcZrnVeN3f38tY0MRLzTtG(iitsuQEgLsIctAypllcOHpYnRdXjn8rUPd8esdpc5C52LRHMlIZ0IwfSvROgMaoeNy6u0WzZkKzDnmbiZ)JgJW38krHHZOoYnRdXP2iKZLBxUgAUiolQprH5OeNtaPXCJ9(CDgsDJaoeNyr9jQmcXzi1G2qzdjDHYxWAlwuZ6nkLvoQmkbc1FrlqMgJW38krP6zuPjkmPH9SSiGgo7CE3ZYIaD(oIgMVJ0bEcPHhHCUC7z2OfTk2kTIAyc4qCIPtrdNnRqM11WzuceQ)IwGmngHV5vIcdNrHvukRCuIB(jPjBc1fuNTuuy4mkSI6tuzuceQ)IwGmrP6zukrd7zzranC258UNLfb68DenmFhPd8esdJVGDUArRITwROgMaoeNy6u0WzZkKzDn88sCExCZpjtBUwM1ob6JGmjrDgvAI6tuzuceQ)IwGmrP6zuPrd7zzranC258UNLfb68DenmFhPd8esdJVGDUArRs6RvudtahItmDkA4SzfYSUgMaK5)rJr4BELOWWzuh5M1H4uBeY5YTlxdnxeNPH9SSiGgo7CE3ZYIaD(oIgMVJ0bEcPHHSwotlAvW6yTIAyc4qCIPtrdNnRqM11WeGm)pAmcFZReLQNrHf2J6zueGm)pAg6NaAypllcOHDt2buxqgdbeTOvblS0kQH9SSiGg2nzhq9xl(qAyc4qCIPtrlAvWkvTIAypllcOH57)vMUsxl2FcbenmbCioX0POfTOHFnugLa5IwrTkyPvudtahItmDkArRsQAf1WeWH4etNIw0QOeTIAyc4qCIPtrlAvsJwrnmbCioX0POfTkyxROg2ZYIaA4riNlxnmbCioX0POfTkyRwrnmbCioX0POH9SSiGgoXn2jwhhz6mYLRg(1qzucKl9HYiaB0WyHDTOvXwPvudtahItmDkAypllcOHNRZqQ7qCNrJg(1qzucKl9HYiaB0WyPfTk2ATIAypllcOHFrYIaAyc4qCIPtrlArdJVGDUAf1QGLwrnmbCioX0POHZMviZ6AyX5eqAZ1zi1DCu2AAeWH4elQprbzHJ3a7)vM(re4NCqMAwVr9jQ5L48U4MFsM2CTmRDc0hbzsIs1ZOsnQNrPKOWOOeNtaPnu2qsxO8fS2If1iGdXjMg2ZYIaAy6ODYKXfslAvsvROgMaoeNy6u0WzZkKzDnmMJkTrjoNasJ5g7956mK6gbCioXIszLJkTrbzHJ3MRZqQ7mhKPM1BuykQprjU5NKMSjuxqD2sr99OmuIVGjkvJcBJ6tugkXxWefgIs2S9USjuuyuuPg1NOWCuZlX5DXn)KmT5Azw7eOpcYKefgIknrPSYrL2OGSWXBZJeieF6i8oJC52SEJctAypllcOHb7)vG4oJ0IwfLOvudtahItmDkAypllcOHb7)vG4oJ0WzZkKzDn88sCExCZpjtBUwM1ob6JGmjrP6zuPg1NOWCuIZjG0gkBiPlu(cwBXIAeWH4elkLvok)BsMvOgy)VY0pIa)KdYuJaoeNyrPSYrnVeN3f38tY0MRLzTtG(iitsuy4mkShfMI6tuPnkilC82CDgsDN5Gm1SEJ6tuIB(jPjBc1fuNTuuQEgfMJc7r9mkmhvQrHrrLrjqO(lAbYefMIctr9jkdHBO56qCsdNFK5uxCZpjJwfS0IwL0OvudtahItmDkA4SzfYSUg2qj(cMOWquzeIZqQbT5rceIpDeENrUCBgkXxWe1ZOW64O(evgH4mKAqBEKaH4thH3zKl3MHs8fmrHHZOWEuFIsCZpjnztOUG6SLI67rzOeFbtuQgvgH4mKAqBEKaH4thH3zKl3MHs8fmr9mkSRH9SSiGggS)xbI7mslAvWUwrnmbCioX0POHZMviZ6AyilC828ibcXNocVZixUnR3O(efMJkTrjoNasJ5g7956mK6gbCioXIszLJcYchVnxNHu3zoitnR3OWKg2ZYIaA4HYgs6cLVG1wSiTOvbB1kQHjGdXjMofnC2SczwxdpVeN3f38tY0MRLzTtG(iitsuQEgvQr9mkX5eqAm3yVpxNHu3iGdXjwupJsCobKgy)VYio3ozAeWH4etd7zzran8qzdjDHYxWAlwKw0QyR0kQH9SSiGgMoANmzCH0WeWH4etNIw0IgoZgTIAvWsROgMaoeNy6u0WzZkKzDnmKfoEdIJqmU1ind5zjkLvokXn)K0KnH6cQZwkkmCgf2ECukRCuqw44T5rceIpDeENrUCBwVr9jkmhfKfoEBUodPUdXDgnnR3Ouw5OYieNHudAZ1zi1DiUZOPzOeFbtuy4mkSookmPH9SSiGg(fjlcOfTkPQvudtahItmDkAyGNqA4KhmF6IZ3jXbAypllcOHtEW8PloFNehOfTkkrROgMaoeNy6u0WzZkKzDnmKfoEBEKaH4thH3zKl3M1BukRCuIB(jPjBc1fuNTuuyiQupwd7zzranS1q9vOKrlAvsJwrnmbCioX0POHZMviZ6AyilC828ibcXNocVZixUnRxnSNLfb0WqCeI1XTmp0IwfSRvudtahItmDkA4SzfYSUggYchVnpsGq8PJW7mYLBZ6vd7zzranmezgYyFb)ArRc2QvudtahItmDkA4SzfYSUggYchVnpsGq8PJW7mYLBZ6vd7zzranm(AiiocX0IwfBLwrnmbCioX0POHZMviZ6AyilC828ibcXNocVZixUnRxnSNLfb0WoitJyCEp7CUw0QyR1kQHjGdXjMofnC2SczwxdZqsdS)xbI7mQjB2(c(1WEwweqdppsGq8PJW7mYLRw0QK(Af1WeWH4etNIgoBwHmRRHn(Y60reqAoJnnR3O(efMJsCZpjnztOUG6SLIcdrLrjqO(lAbY0ye(MxjkLvoQ0g1iKZLlXAoNh1NOYOeiu)fTazAmcFZReLQNrLF7jo20NxcWIctAypllcOHtCJDI1XrMoJC5QfTkyDSwrnmbCioX0POHZMviZ6AyJVSoDebKMZytBbrPAuk54O(EugFzD6icinNXMgZY4YIar9jQ0g1iKZLlXAoNh1NOYOeiu)fTazAmcFZReLQNrLF7jo20NxcW0WEwweqdN4g7eRJJmDg5YvlAvWclTIAyc4qCIPtrdNnRqM11WzuceQ)IwGmngHV5vIs1ZOsnQNrnc5C5sSMZ5AypllcOHNRZqQ7qCNrJw0QGvQAf1WeWH4etNIgoBwHmRRHNxIZ7IB(jzIs1ZOusuFIIHKgy)Vce3zut2S9f8h1NOGSWXBZJeieF6i8oJC52SEJ6tuqw44T56mK6oZbzQz9QH9SSiGgEUwM1ob6cYaCgslAvWsjAf1WeWH4etNIgoBwHmRRHtBuJqoxUeR5CEuFIsCZpjnztOUG6SLIcdNrH9OEgL4CciTXcsidU1p1iGdXjMg2ZYIaA456mK6oZbzslArdpc5C52ZSrROwfS0kQHjGdXjMofn8ro3I0WzeIZqQbT56mK6oZbzQLVU5NMoUXZYIaopkvpJcRMTc7AypllcOHpYnRdXjn8rUPd8esdpxwxUgAUiotlAvsvROgMaoeNy6u0WzZkKzDnCAJ6i3SoeNAZL1LRHMlIZI6tumcYchVHVawxn52b0mndL4lyIcdrHvuFIkJsGq9x0cKPXi8nVsuQgfwAypllcOHpYb7C1IwfLOvudtahItmDkAypllcOHFriE3qdYYKjnmHnIX7EcYciA40CSgghz6acBeTkyPfTkPrROgMaoeNy6u0WzZkKzDnmbiZ)JOu9mQ0CCuFIIaK5)rJr4BELOu9mkSooQprL2OoYnRdXP2CzD5AO5I4SO(efJGSWXB4lG1vtUDantZqj(cMOWquyf1NOYOeiu)fTazAmcFZReLQrHLg2ZYIaA456mK6eIZ0IwfSRvudtahItmDkA4SzfYSUggZrL2OeNtaPXCJ9(CDgsDJaoeNyrPSYrXqsdS)xbI7mQzOeFbtuQEgf2J6zuIZjG0gliHm4w)uJaoeNyrHPO(efMJ6i3SoeNAZL1LRHMlIZIszLJcYchVnpsGq8PJW7mYLBZqj(cMOu9mkSAPgLYkh18sCExCZpjtBUwM1ob6JGmjrP6zuPjQprLriodPg0Mhjqi(0r4Dg5YTzOeFbtuQgfwhhfM0WEwweqdpxNHu3zoitArRc2QvudtahItmDkA4SzfYSUgwCZpjnztOUG6SLIcdrLriodPg0Mhjqi(0r4Dg5YTzOeFbJg2ZYIaA456mK6oZbzslArddzTCMwrTkyPvudtahItmDkA4SzfYSUgoTrjoNasdS)xzeNBNmnc4qCIf1NOWCuPnkX5eqAm3yVpxNHu3iGdXjwukRCuzeIZqQbT5rceIpDeENrUCBgkXxWeLQrH1XrHPO(efKfoEBUU5LaeRdXDgnTr8S9Ou9mQut)O(e18sCExCZpjtBUwM1ob6JGmjrHHZOWCukjkmkk)BsMvO2CDZlbiwhI7mAAghypkmPH9SSiGgEUwM1ob6cAgTOvjvTIAyc4qCIPtrdNnRqM11WZlX5DXn)KmrP6zuPgLYkhfKfoEtUuNziNXrg20zuMwPnINThLQNrLA6RH9SSiGgEUwM1ob6JGmjArRIs0kQH9SSiGg(NJqjqCNrAyc4qCIPtrlAvsJwrnSNLfb0WqE2(ioKgMaoeNy6u0Iw0Ig(iYmlcOvj1JXYwFC6FCQTuvsAWsdR2nGf8pAyLIKxKriwu2QO8SSiqu8DKPfh0WZlL1QKk2ILg(1GWxoPH)kkyliHtYJOSn0Vffh(kQRiVt6rbf(x5Ab1YOefMnXI7YIazJJlkmBswbiocsbiC)7m6ifEni8LtJc2UHSnFzJc2UT1Tn0Vf1HTGeojpAZMKJdFffm9kucezIkvBIk1JXYwh13JclSspk54OSDL(4qC4ROW4Rd(Pj9eh(kQVh13MXiwuFJB2EuckkgH7wCjkpllcefFhPfhIdFf13a2qzlHyrbr4idfvgLa5suq0)cMwuF7CMELjkac89RBsWT4r5zzrGjkeG)Ofh8SSiW0EnugLa5Yjo3h7XbpllcmTxdLrjqU88ub36pHaIllceh8SSiW0EnugLa5YZtfWriwC4ROGb(7CrsugFzrbzHJtSOgXLjkichzOOYOeixIcI(xWeLdyr9AOV)Iezb)rTtumeGAXbpllcmTxdLrjqU88uHb4VZfj9rCzIdEwweyAVgkJsGC55PcJqoxUXbpllcmTxdLrjqU88uHe3yNyDCKPZixU28AOmkbYL(qzeGnNyH94GNLfbM2RHYOeixEEQWCDgsDhI7mAS51qzucKl9HYiaBoXko4zzrGP9AOmkbYLNNk8IKfbIdXHVI6BaBOSLqSOOJiZJOKnHIsUuuEwqMO2jk)iF5oeNAXbpllcmN23S94WxrHXxkBpkmoDtuUef(Agjo4zzrG55PczNZ7EwweOZ3rSb4j0zMnXHVIY2SarHBX5pIAuVs(stuckk5srblKZLlXIY2qIllcefMHEefdTG)OgKnrTsu4itMMOEri(c(JAXJcGK7c(JANO8J8L7qCctT4GNLfbMNNkySaDpllc057i2a8e6CeY5YLy2S4NJqoxUeR5CEC4RO(2VV8hrPY(FfiUZOOCjQuFgfgB7rXSml4pk5srHVMrIcRJJAOmcWgBIYXfYeLCDjQ08mkm22JAXJALOiS5Dn0eL6vUlik5srbiSrIsPdgNUOqMO2jkasIY6no4zzrG55PcG9)kqCNr2S4NIB(jPjBc1fuNTKQy7hdL4lyWWFM1sCS5tgLaH6VOfiJQNP57yw2ecdyDmMWOuJdFf13AiwuckkgHVakk1xceLGIYAOOgHCUCJcJt3efYefK1YzKzIdEwweyEEQWrUzDiozdWtOZriNl3UCn0CrCMnh5Cl6mvS)uCobK2r7pY0iGdXjggPeS)uCobKwIpcz6i8(CDgs90iGdXjggLk2FkoNasBUodPUJJYwtJaoeNyyuQh)uCobKMZ9SzLhnc4qCIHryD8tSWogH55L48U4MFsM2CTmRDc0hbzsu9ujyko8vuymcmlJmrznl4pkpkyHCUCJcJtxuQVeikd557c(JsUuueGm)pIsUgAUiolkhWI66hTG)OMxptrHJmr5suCYhjQ0efgB7rHmrbtzdjrPiLVG1wSOOmKZEeh8SSiW88uHSZ5Dpllc057i2a8e6CeY5YTNzJnl(jbiZ)JgJW38ky48i3SoeNAJqoxUD5AO5I4SpywCobKgZn27Z1zi1nc4qCI9jJqCgsnOnu2qsxO8fS2If1SEvw5mkbc1FrlqMgJW38kQEMgmfh(kkL6c25gLlrLMNrPELlYsIkDW2ef2FgL6vUrLo4OWmYsMLrrnc5C5IP4GNLfbMNNkKDoV7zzrGoFhXgGNqN4lyNRnl(zgLaH6VOfitJr4BEfmCILYklU5NKMSjuxqD2sy4eRpzuceQ)IwGmQEQK4WxrP0w5gv6GJY5dkk8fSZnkxIknpJY)9fmsue24zH)iQ0eL4MFsMOWmYsMLrrnc5C5IP4GNLfbMNNkKDoV7zzrGoFhXgGNqN4lyNRnl(58sCExCZpjtBUwM1ob6JGmjNP5tgLaH6VOfiJQNPjo8vuFRHIYJcYA5mYeL6lbIYqE(UG)OKlffbiZ)JOKRHMlIZIdEwweyEEQq258UNLfb68DeBaEcDczTCMnl(jbiZ)JgJW38ky48i3SoeNAJqoxUD5AO5I4S4WxrPucPMgjQxZImR8iQfeLZ5rHWJsUuuFBBxPuuqu2TgkQvIk7wdnr5rP0bJtxCWZYIaZZtfCt2buxqgdbeBw8tcqM)hngHV5vu9elS)KaK5)rZq)eio4zzrG55PcUj7aQ)AXhko4zzrG55Pc89)ktxPRf7pHasCio8vuPyTCgzM4WxrbFTmRDceLIOzIYLOsn9Fgf81nVeGyrLc3z0e1iE2(0I6B9gLGIsjrjU5NKjQxYeLXb2Brb7hrrHJmrnc5C5g1IhL1SG)Ouz)VYio3ozIczIkDUXEuWxNHuhL6lbI6fnZcXPwCWZYIatdYA5SZ5Azw7eOlOzSzXptR4CcinW(FLrCUDY0iGdXj2hmNwX5eqAm3yVpxNHu3iGdXjMYkNriodPg0Mhjqi(0r4Dg5YTzOeFbJQyDmM(azHJ3MRBEjaX6qCNrtBepBx1Zut)pZlX5DXn)KmT5Azw7eOpcYKGHtmRemY)MKzfQnx38saI1H4oJMMXb2XuCWZYIatdYA5SNNkmxlZANa9rqMeBw8Z5L48U4MFsgvptvzLHSWXBYL6md5moYWMoJY0kTr8SDvptn9JdEwweyAqwlN98uHFocLaXDgfh8SSiW0GSwo75PcqE2(iouCio8vuymcXzi1Gjo4zzrGPLzZ5lsweWMf)eYchVbXrig3AKMH8SOSYIB(jPjBc1fuNTegoX2JvwzilC828ibcXNocVZixUnR3pygYchVnxNHu3H4oJMM1RYkNriodPg0MRZqQ7qCNrtZqj(cgmCI1Xyko4zzrGPLzZZtfSgQVcLydWtOZKhmF6IZ3jXbXHVIsP6C(c(JcYZ2JsqrXiC3IlrTcLeL14)u6jQV1qrPELBuWpsGq8jkeEuPJC52IdEwweyAz288ubRH6RqjJnl(jKfoEBEKaH4thH3zKl3M1RYklU5NKMSjuxqD2syi1JJdEwweyAz288ubiocX64wMh2S4Nqw44T5rceIpDeENrUCBwVXbpllcmTmBEEQaezgYyFb)2S4Nqw44T5rceIpDeENrUCBwVXbpllcmTmBEEQa(AiiocXSzXpHSWXBZJeieF6i8oJC52SEJdEwweyAz288ubhKPrmoVNDo3Mf)eYchVnpsGq8PJW7mYLBZ6no4zzrGPLzZZtfMhjqi(0r4Dg5Y1Mf)KHKgy)Vce3zut2S9f8hh(kkLc8OCgBIYnuuwV2e1a2xkk5srHauuQx5gfhPMgjkfvmDTO(wdfL6lbII9yb)rH7JqMOKRdIcJT9Oye(MxjkKjkasIAeY5YLyrPELlYsIYbpIcJT9wCWZYIatlZMNNkK4g7eRJJmDg5Y1Mf)04lRthraP5m20SE)GzXn)K0KnH6cQZwcdzuceQ)IwGmngHV5vuw50oc5C5sSMZ5FYOeiu)fTazAmcFZRO6z(TN4ytFEjadtXHVIsPapkakkNXMOuVCEuSLIs9k3feLCPOae2irPKJhBIYAOOu6XtxuiquqOzIs9kxKLeLdEefgB7r5awuauuJqoxUT4GNLfbMwMnppviXn2jwhhz6mYLRnl(PXxwNoIasZzSPTavvYXF34lRthraP5m20ywgxwe4tAhHCUCjwZ58pzuceQ)IwGmngHV5vu9m)2tCSPpVeGfh8SSiW0YS55PcZ1zi1DiUZOXMf)mJsGq9x0cKPXi8nVIQNP(CeY5YLynNZJdEwweyAz288uH5Azw7eOlidWziBw8Z5L48U4MFsgvpvYhgsAG9)kqCNrnzZ2xW)hilC828ibcXNocVZixUnR3pqw44T56mK6oZbzQz9gh8SSiW0YS55PcZ1zi1DMdYKnl(zAhHCUCjwZ58pIB(jPjBc1fuNTegoX(tX5eqAJfKqgCRFQrahItS4qC4ROuQlyNlzM4Wxr9nC0ozY4cf1D)V0ir9AwKzLhr5suP(mkXn)KmrPELBuWxNHuhLsfLTMOWm2FgL6vUrbtzdjrPiLVG1wSOOwquoJTYIaykkhWIsL9)kP3NOsViWp5GmfL1Blo4zzrGPHVGDUN0r7KjJlKnl(P4CciT56mK6ookBnnc4qCI9bYchVb2)Rm9JiWp5Gm1SE)mVeN3f38tY0MRLzTtG(iitIQNP(ujyK4CciTHYgs6cLVG1wSOgbCioXIdFf13irVrz9gLk7)vG4oJIAXJALO2jkhczjrjOOmwGOqwslQ0HIcGKOSgkkvsjkMLzb)rLohKjBIAXJsCobeIf1ceuuPZn2Jc(6mK6wCWZYIatdFb7CFEQay)Vce3zKnl(jMtR4CcinMBS3NRZqQBeWH4etzLtlKfoEBUodPUZCqMAwVy6J4MFsAYMqDb1zl9DdL4lyufB)yOeFbdgKnBVlBcHrP(bZZlX5DXn)KmT5Azw7eOpcYKGH0OSYPfYchVnpsGq8PJW7mYLBZ6ftXHVIsP3IlldjYc(JczjZYOOsNdYuuiquIB(jzIsUUeL6LZJIVhrrHJmrjxkkMLXLfbIcHhLk7)vG4oJIs9k3OmeUHMBumlZc(J61bmkzZrT4r9azf11pIIItZeLCDquyBuIB(jzIczI6L7pIs9k3OGPSHKOuKYxWAlwulo4zzrGPHVGDUppvaS)xbI7mYM8JmN6IB(jzoXYMf)CEjoVlU5NKPnxlZANa9rqMevpt9dMfNtaPnu2qsxO8fS2If1iGdXjMYk7FtYSc1a7)vM(re4NCqMAeWH4etzLNxIZ7IB(jzAZ1YS2jqFeKjbdNyhtFslKfoEBUodPUZCqMAwVFe38tst2eQlOoBjvpXm2FI5uXOmkbc1FrlqgmHPpgc3qZ1H4uC4ROSnc3qZnkv2)RaXDgff5g(JOw8Owjk1lNhfHnVRHIIzzwWFuWpsGq8Pfv6qrjxxIYq4gAUrT4rbJsxu)KmrziN9iQfeLCPOae2irH9Pfh8SSiW0WxWo3NNka2)RaXDgzZIFAOeFbdgYieNHudAZJeieF6i8oJC52muIVG5jwh)jJqCgsnOnpsGq8PJW7mYLBZqj(cgmCI9pIB(jPjBc1fuNT03nuIVGr1mcXzi1G28ibcXNocVZixUndL4lyEI94WxrbtzdjrPiLVG1wSOOywMf8hf8JeieFArP0w5gv6CJ9OGVodPokeG)ikMLzb)rbFDgsDuPZbzkkmBbKLhLCn0CrCwulikaHnsu8fqyQfh8SSiW0WxWo3NNkmu2qsxO8fS2IfzZIFczHJ3Mhjqi(0r4Dg5YTz9(bZPvCobKgZn27Z1zi1nc4qCIPSYqw44T56mK6oZbzQz9IP4WxrP0w5gfbqw)3Oe38tYeLZv7pMOSgkkykRiLJcbIcJtxlo4zzrGPHVGDUppvyOSHKUq5lyTflYMf)CEjoVlU5NKPnxlZANa9rqMevpt9P4CcinMBS3NRZqQBeWH4e7P4CcinW(FLrCUDY0iGdXjwCWZYIatdFb7CFEQaD0ozY4cfhIdFffSqoxUrHXieNHudM4WxrLEJ4VKjQ0l3SoeNIdEwweyAJqoxU9mBopYnRdXjBaEcDoxwxUgAUioZMJCUfDMriodPg0MRZqQ7mhKPw(6MFA64gpllc4CvpXQzRWEC4ROsVCWo3OSaCAMOutr5gkkhczjrjOOY(BuiquPZbzkQ81n)00IsPmG)ik1xceLsDbSOuAKBhqZe1or5qiljkbfLXcefYsAXbpllcmTriNl3EMnppv4ihSZ1Mf)mTh5M1H4uBUSUCn0CrC2hgbzHJ3WxaRRMC7aAMMHs8fmyaRpzuceQ)IwGmngHV5vufR4Wxrz7iepkCKjk4RZqQtiolQNrbFDgs9iM1ofLfGtZeLAkk3qr5qiljkbfv2FJcbIkDoitrLVU5NMwukLb8hrP(sGOuQlGfLsJC7aAMO2jkhczjrjOOmwGOqwslo4zzrGPnc5C52ZS55PcVieVBObzzYKn4ithqyJCILne2igV7jilGCMMJJdEwweyAJqoxU9mBEEQWCDgsDcXz2S4NeGm)pu9mnh)HaK5)rJr4BEfvpX64pP9i3SoeNAZL1LRHMlIZ(WiilC8g(cyD1KBhqZ0muIVGbdy9jJsGq9x0cKPXi8nVIQyfh(kkL2k3OsNBShf81zi1rHa8hrLohKPOuFjquQS)xbI7mkk1lNh1i(JOSEBr9TgkkMLzb)rb)ibcXNOqMOCi0ruuY1qZfXzT4GNLfbM2iKZLBpZMNNkmxNHu3zoit2S4NyoTIZjG0yUXEFUodPUrahItmLvMHKgy)Vce3zuZqj(cgvpX(tX5eqAJfKqgCRFQrahItmm9bZh5M1H4uBUSUCn0CrCMYkdzHJ3Mhjqi(0r4Dg5YTzOeFbJQNy1svzLNxIZ7IB(jzAZ1YS2jqFeKjr1Z08jJqCgsnOnpsGq8PJW7mYLBZqj(cgvX6ymfh8SSiW0gHCUC7z288uH56mK6oZbzYMf)uCZpjnztOUG6SLWqgH4mKAqBEKaH4thH3zKl3MHs8fmXH4WxrblKZLlXIY2qIllceh(kkLc8OgHCUCJANOSETjk1uugY58hrP2bsuckkRHIc(6mK6rmRDkkbffebi8vMOWnOKOKlf1RpZEeffecyn2efDebIAXJsnfLBOOCjQehBIk)gfMXnOKOKlf1RHYOeixIsPhpDyQfh8SSiW0gHCUCj25CDgs9iM1ozZIFczHJ3gHCUCBwVXHVIsPUGDUr5suP5zuySThL6vUiljQ0bBtuy)zuQx5gv6GTjkhWIcBJs9k3OshCuoUqMOsVCWo34GNLfbM2iKZLlXEEQq258UNLfb68DeBaEcDIVGDU2S4NzuceQ)IwGmngHV5vWWjwFhZIZjG0ye9sM(igx8FkPrahItSpqw44TJCWo3M1lMIdFff81YS2jqukIMjkxIk10)zuWx38saIfvkCNrtuJ4z7tulikyHCUCJchzII5j(pffecyn00Ik9gIZIchzIsPUawuknYTdOzIAXJ6fnZcXPwCWZYIatBeY5YLyppvyUwM1ob6cAgBw8tilC82CDZlbiwhI7mAAJ4z7QEMA6)bZPvCobKg(cyD1KBhqZ0iGdXjMYkZiilC8g(cyD1KBhqZ0SEXuC4RO(2suPgL4MFsMOuVYnkykBijkfP8fS2IffLDIEJY6nkL6cyrP0i3oGMjkOhrLFK5l4pk4RZqQhXS2PwCWZYIatBeY5YLyppvyUodPEeZANSj)iZPU4MFsMtSSzXpfNtaPnu2qsxO8fS2If1iGdXj2hX5eqA4lG1vtUDantJaoeNyFyeKfoEdFbSUAYTdOzAgkXxWGbS(mVeN3f38tY0MRLzTtG(iitYzQFe38tst2eQlOoBPVBOeFbJQyBC4ROuARCrwsuPJOxYefSyCX)PKOCalkLeLT5a7tui8OsH7mkQfeLCPOGVodPEIALO2jk1iJCJYAwWFuWxNHupIzTtrHarPKOe38tY0IdEwweyAJqoxUe75PcZ1zi1Jyw7Knl(zAfNtaPXi6Lm9rmU4)usJaoeNyF8VjzwHAqCNr9f0Ll1NRZqQNMXb2pvYN5L48U4MFsM2CTmRDc0hbzsovsCWZYIatBeY5YLyppvyUwM1ob6JGmj2S4NZlX5DXn)KmQEQK4GNLfbM2iKZLlXEEQWCDgs9iM1oPfTO1a]] )

end
