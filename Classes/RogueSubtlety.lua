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


    spec:RegisterPack( "Subtlety", 20181022.2105, [[d4exnbqiOIEKIsBsr6tGkqnkOsDkOswffsEfOQzrH6wGkAxI6xuqdJq4yqvwMukpJq00KsvxJqY2OqQVrHiJtkvQZbQqRJIQQ5bQ09aX(KsCqke1cLs6Hes1ePOYfLsL0gHkOpsrvjJKIQsDsOcyLkIxsrvHzcQa5MGkODsr5NGkGHkLkwkfv5PqAQqvDvOc1wLsL4RqfYEP0FLQbl5WclgIhlYKr5YiBgkFgKgTcNwLvtrvrVMImBuDBPy3Q63adhuooHuworpxPPt66eSDffFNqnEkeoVIQ1dvGMpfy)uTfpl(wuwOK1S2ebETB8erBTLBdpry04zKSO6CyKffwKmfqjl6hnKffvar5Ko3IclMZbbZIVfDbcYezrhQcBn)gAi0thci5eOXW9Ae4HEGpjdm1W9AsgIWbigIGfWjJMXqysa2XP1W2rsMxCS1W2X86MhaQa1rfquoPZZ71KSOichxXbElIfLfkznRnrGx7gpr0wB52WtegTiGJw0qqhaPff9AeDl64ym6TiwugTjl6SEHkGOCsN7L5bGkq(Kz9AOkS18BOHqpDiGKtGgd3RrGh6b(KmWud3RjzichGyicwaNmAgdHjbyhNwdBhjzEXXwdBhZRBEaOcuhvar5KopVxtYNmRxWbskaHKE1wBg7vBIaV2TxWPxWrZVieLxTdCOpXNmRxI(iEO0A(9jZ6fC6LrMXiMxMpUKjVuGxmcle4QxrspW7f)wn7tM1l40lZJAaZqmV0qcL0(H5vc8StpW7f49comKMiMxyaPxMJcDK9jZ6fC6LrMXiMx44L8chqPMnBr53QRfFl6QuW1bXS4Bndpl(wu6deoXSTArtYtj5fwuebmS8QuW1rwaMfns6bEl6ocgq8QYZezvRzTzX3IsFGWjMTvlAsEkjVWIManiGomW96Mze2Lo1l4cXl88co9c3EPbNEnZicgj7RkdnGsnz6deoX8AQxicyy5zI)2rwaMx4YIgj9aVfnfCEps6b(o)w1IYVv7F0qwuS7VDyvRzI0IVfL(aHtmBRw0K8usEHffradlVJqcJEI1r4bJ28QrYKxTaXR2GJEn1lC7fo9sdo9Ag7EwxmfMEA3m9bcNyEzGbEXiebmSm29SUykm90UzbyEHllAK0d8w0Diipt03vWUw1Aw7T4BrPpq4eZ2Qfns6bEl6ocgq8QYZezrtYtj5fwun40R5Lsss7kLg)jAcuM(aHtmVM6LgC61m29SUykm90Uz6deoX8AQxmcradlJDpRlMctpTBwsnX9RxW1l88AQxlmIZ7AiHs6M3HG8mrFFvGSXliE1Mxt9sdjusZ61qDf0zh5fC6LKAI7xVAXlJ2IMMN4uxdjusxRz4zvRzIYIVfL(aHtmBRw0K8usEHffNEPbNEnZicgj7RkdnGsnz6deoX8AQxboijpLYi8Gr9776G67iyaXBwgVjVG4Li9AQxlmIZ7AiHs6M3HG8mrFFvGSXliEjslAK0d8w0DemG4vLNjYQwZmAl(wu6deoXSTArtYtj5fw0fgX5DnKqjD9QfiEjslAK0d8w0Diipt03xfiBSQ1mJKfFlAK0d8w0DemG4vLNjYIsFGWjMTvRAvlkJWcbUAX3AgEw8TOrspWBrxLcUoSO0hiCIzB1QwZAZIVfns6bElQPlzYIsFGWjMTvRAntKw8TO0hiCIzB1Igj9aVfnfCEps6b(o)w1IYVv7F0qw0eBTQ1S2BX3IsFGWjMTvlAsEkjVWIUkfCDqSCW5w0iPh4TOsHVhj9aFNFRAr53Q9pAil6QuW1bXSQ1mrzX3IsFGWjMTvlAsEkjVWIQHekPz9AOUc6SJ8QfVmAVM6LKAI7xVGRxqtSCtyeEn1ReObb0HbUxxVAbIxT3l40lC7LEnKxW1l8eHx4YlJYR2SOrspWBr)d6qr4bJSQ1mJ2IVfL(aHtmBRw0zcUazrBtuEbVxAWPxZZCqbYm9bcNyEzuEjsr5f8EPbNEn3eRsYoaRVJGbeVz6deoX8YO8Qnr5f8EPbNEnVJGbe3XajHntFGWjMxgLxTjcVG3ln40R5Ghj5PZZ0hiCI5Lr5fEIWl49cpr5Lr5fU9AHrCExdjus38oeKNj67RcKnE1ceVePx4YIgj9aVfDMqEbcNSOZeY(hnKfDvk46ORdjTdaNzvRzgjl(wu6deoXSTArtYtj5fwu6jj05zgHDPt9cUq8AMqEbcNYRsbxhDDiPDa4mVM6vc0Ga6Wa3RBMryx6uVAbIxT3Igj9aVfnfCEps6b(o)w1IYVv7F0qw0vPGRJEITw1Aw72IVfL(aHtmBRw0K8usEHfLEscDEMryx6uVGleVMjKxGWP8QuW1rxhsAhaoZRPEPbNEnZcPP(ocgqCM(aHtmVM6LgC618sjjPDLsJ)enbktFGWjMxt9kbaCgq8NxkjjTRuA8NOjqzbyw0iPh4TOPGZ7rspW353Qwu(TA)JgYIUkfCD0tS1QwZGJw8TO0hiCIzB1IMKNsYlSO0tsOZZmc7sN6fCH41mH8ceoLxLcUo66qs7aWzEn1ln40Rzwin13rWaIZ0hiCI51uVWPxAWPxZlLKK2vkn(t0eOm9bcNyEn1RfgX5DnKqjDZ7qqEMOVVkq24vlq8QnVM6fU9cNEPbNEnVdb5zI(UcKFWaz6deoX8Yad8cNELaaodi(Z7qqEMOVRa5hmqwaMx4YIgj9aVfnfCEps6b(o)w1IYVv7F0qw0vPGRJEITw1AgEIWIVfL(aHtmBRw0K8usEHfnbAqaDyG71nZiSlDQxWfIx45Lbg4LgsOKM1RH6kOZoYl4cXl88AQxjqdcOddCVUE1ceVePfns6bElAk48EK0d8D(TQfLFR2)OHSOy3F7WQwZWdpl(wu6deoXSTArtYtj5fw0fgX5DnKqjDZ7qqEMOVVkq24feVAVxt9kbAqaDyG711RwG4v7TOrspWBrtbN3JKEGVZVvTO8B1(hnKff7(Bhw1AgETzX3IsFGWjMTvlAsEkjVWIspjHopZiSlDQxWfIxZeYlq4uEvk46ORdjTdaNzrJKEG3IMcoVhj9aFNFRAr53Q9pAilkIWXzw1AgEI0IVfL(aHtmBRw0K8usEHfLEscDEMryx6uVAbIx4jkVG3l6jj05zjbLElAK0d8w0qMIN6kqkPxTQ1m8AVfFlAK0d8w0qMIN6We4lzrPpq4eZ2QvTMHNOS4BrJKEG3IYpOdD7MpfyqBOxTO0hiCIzB1Qw1IctsjqdsOw8TMHNfFlk9bcNy2wTQ1S2S4BrPpq4eZ2QvTMjsl(wu6deoXSTAvRzT3IVfL(aHtmBRw1AMOS4BrJKEG3IUkfCDyrPpq4eZ2QvTMz0w8TO0hiCIzB1Igj9aVfTjKMiwhdi7mk0HffMKsGgKq7lLapBTO4jkRAnZizX3IsFGWjMTvlAK0d8w0DemG4ocpy0ArHjPeObj0(sjWZwlkEw1Aw72IVfns6bElkmGEG3IsFGWjMTvRAvlkIWXzw8TMHNfFlk9bcNy2wTOj5PK8clko9sdo9A(pOdD1GBIKz6deoX8AQx42lC6LgC61mlKM67iyaXz6deoX8Yad8kbaCgq8N35nia(2byDgf6ilPM4(1Rw8cpr4fU8AQxicyy5Desy0tSocpy0MxnsM8QfiE1gC0RPETWioVRHekPBEhcYZe99vbYgVGleVWTxI0lJYRahKKNs5Desy0tSocpy0MLXBYlCzrJKEG3IUdb5zI(Uc21QwZAZIVfL(aHtmBRw0K8usEHfDHrCExdjusxVAbIxT5Lbg4fIagwwhuNjPGXbs22zuIonVAKm5vlq8Qn4Ofns6bEl6oeKNj67RcKnw1AMiT4BrJKEG3IcLdani8Grwu6deoXSTAvRzT3IVfns6bElksKmTAGyrPpq4eZ2QvTQfnXwl(wZWZIVfL(aHtmBRw0K8usEHffradlJWbagxy1SKIK6Lbg4LgsOKM1RH6kOZoYl4cXlJweEzGbEHiGHL35nia(2byDgf6ilaZRPEHBVqeWWY7iyaXDeEWOnlaZldmWReaWzaXFEhbdiUJWdgTzj1e3VEbxiEHNi8cxw0iPh4TOWa6bERAnRnl(wu6deoXSTArJKEG3Icn4uk4CsUDea4TOj5PK8clkIagwEN3Ga4BhG1zuOJSamVmWaV0qcL0SEnuxbD2rEbxVAtew0pAilk0GtPGZj52raG3QwZePfFlk9bcNy2wTOj5PK8clkIagwEN3Ga4BhG1zuOJSamlAK0d8wuHL6NsnRvTM1El(wu6deoXSTArtYtj5fwuebmS8oVbbW3oaRZOqhzbyw0iPh4TOiCaG1XeKZTQ1mrzX3IsFGWjMTvlAsEkjVWIIiGHL35nia(2byDgf6ilaZIgj9aVffHKljnDpuRAnZOT4BrPpq4eZ2QfnjpLKxyrreWWY78geaF7aSoJcDKfGzrJKEG3IIDscHdamRAnZizX3IsFGWjMTvlAsEkjVWIIiGHL35nia(2byDgf6ilaZIgj9aVfn(eTQm49uW5w1Aw72IVfL(aHtmBRw0K8usEHffNEHiGHL3rWaI7S4tuwaMxt9cradlVdb5zI(UcKFWazbyEn1lebmS8oeKNj67kq(bdKLutC)6fCH4LiZIYIgj9aVfDhbdiUZIprwuHL6amSo0eZIINvTMbhT4BrPpq4eZ2QfnjpLKxyrreWWY7qqEMOVRa5hmqwaMxt9cradlVdb5zI(UcKFWazj1e3VEbxiEjYSOSOrspWBr35nia(2byDgf6WIkSuhGH1HMywu8SQ1m8eHfFlk9bcNy2wTOj5PK8clkdO5)GoueEWOSEjt3d1RPEHBVWPxAWPxZ7qqEMOVRa5hmqM(aHtmVmWaV0GtVM3rWaI7yGKWMPpq4eZldmWRfgX5DnKqjDZ7qqEMOVVkq24fC9sKEzGbEHtVsaaNbe)5Diipt03vG8dgilaZlCzrJKEG3IUZBqa8TdW6mk0HvTMHhEw8TO0hiCIzB1IMKNsYlSOY4yDAg61CWyBwaMxt9c3EPHekPz9AOUc6SJ8cUELaniGomW96Mze2Lo1ldmWlC61QuW1bXYbN71uVsGgeqhg4EDZmc7sN6vlq8kbR3egrFHrpZlCzrJKEG3I2esteRJbKDgf6WQwZWRnl(wu6deoXSTArtYtj5fwuzCSond9AoySnFVxT4LifHxWPxY4yDAg61CWyBMjid9aVxt9cNETkfCDqSCW5En1ReObb0HbUx3mJWU0PE1ceVsW6nHr0xy0ZSOrspWBrBcPjI1XaYoJcDyvRz4jsl(wu6deoXSTArtYtj5fw0eObb0HbUx3mJWU0PE1ceVAZl49Avk46Gy5GZTOrspWBr3rWaI7i8GrRvTMHx7T4BrPpq4eZ2QfnjpLKxyrxyeN31qcL01RwG4Li9AQx40ln40R5DemG4ogijSz6deoX8AQxmGM)d6qr4bJY6LmDpuVM6fo9Avk46Gy5GZ9AQxjaGZaI)8oVbbW3oaRZOqhzbyEn1ReaWzaXFEhbdiUZIpr50iKqP1RwG4fEw0iPh4TO7qqEMOVRa5hmGvTMHNOS4BrPpq4eZ2QfnjpLKxyrxyeN31qcL01RwG4Li9AQxAWPxZ7iyaXDmqsyZ0hiCI51uVyan)h0HIWdgL1lz6EOEn1lebmS8oVbbW3oaRZOqhzbyw0iPh4TO7qqEMOVRa5hmGvTMHNrBX3IsFGWjMTvlAsEkjVWIItVwLcUoiwo4CVM6LgsOKM1RH6kOZoYl4cXlr5f8EPbNEnVcikjXeGsz6deoXSOrspWBr3rWaI7S4tKvTQfDvk46ONyRfFRz4zX3IsFGWjMTvl6mbxGSOjaGZaI)8ocgqCNfFIYPriHsBhtgj9aFW9QfiEHx2ijklAK0d8w0zc5fiCYIoti7F0qw0DW66qs7aWzw1AwBw8TO0hiCIzB1IMKNsYlSO40Rzc5fiCkVdwxhsAhaoZRPEXiebmSm29SUykm90Uzj1e3VEbxVWZRPELaniGomW96Mze2Lo1Rw8cplAK0d8w0zI)2HvTMjsl(wu6deoXSTArJKEG3Icda4DjTabzISOKrOYOhnaHxTOTxewumGS)KrOwZWZQwZAVfFlk9bcNy2wTOj5PK8clk9Ke6CVAbIxTxeEn1l6jj05zgHDPt9QfiEHNi8AQx40Rzc5fiCkVdwxhsAhaoZRPEXiebmSm29SUykm90Uzj1e3VEbxVWZRPELaniGomW96Mze2Lo1Rw8cplAK0d8w0DemG4gIZSQ1mrzX3IsFGWjMTvlAsEkjVWIIBVWPxAWPxZSqAQVJGbeNPpq4eZldmWlgqZ)bDOi8Grzj1e3VE1ceVeLxW7LgC618kGOKetakLPpq4eZlC51uVWTxZeYlq4uEhSUoK0oaCMxgyGxicyy5DEdcGVDawNrHoYsQjUF9QfiEHxUnVmWaVwyeN31qcL0nVdb5zI((QazJxTaXR271uVsaaNbe)5DEdcGVDawNrHoYsQjUF9QfVWteEHllAK0d8w0DemG4ol(ezvRzgTfFlk9bcNy2wTOj5PK8clQgsOKM1RH6kOZoYl46vca4mG4pVZBqa8TdW6mk0rwsnX9Rfns6bEl6ocgqCNfFISQvTOy3F7WIV1m8S4BrPpq4eZ2QfnjpLKxyr1GtVM3rWaI7yGKWMPpq4eZRPEHiGHL)d6q3(m0dLIprzbyEn1RfgX5DnKqjDZ7qqEMOVVkq24vlq8QnVG3lr6Lr5LgC618sjjPDLsJ)enbktFGWjMfns6bElknZTjsgkzvRzTzX3IsFGWjMTvlAsEkjVWIIBVWPxAWPxZSqAQVJGbeNPpq4eZldmWlC6fIagwEhbdiUZIprzbyEHlVM6LgsOKM1RH6kOZoYl40lj1e3VE1IxgTxt9ssnX9RxW1l9sM661qEzuE1Mxt9c3ETWioVRHekPBEhcYZe99vbYgVGRxT3ldmWlC6fIagwEN3Ga4BhG1zuOJSamVWLfns6bEl6FqhkcpyKvTMjsl(wu6deoXSTArJKEG3I(h0HIWdgzrtYtj5fw0fgX5DnKqjDZ7qqEMOVVkq24vlq8QnVM6fU9sdo9AEPKK0UsPXFIMaLPpq4eZldmWRahKKNs5)Go0Tpd9qP4tuM(aHtmVmWaVwyeN31qcL0nVdb5zI((QazJxWfIxIYlC51uVWPxicyy5DemG4ol(eLfG51uV0qcL0SEnuxbD2rE1ceVWTxIYl49c3E1MxgLxjqdcOddCVUEHlVWLxt9ssysAhbcNSOP5jo11qcL01AgEw1Aw7T4BrPpq4eZ2QfnjpLKxyrLutC)6fC9kbaCgq8N35nia(2byDgf6ilPM4(1l49cpr41uVsaaNbe)5DEdcGVDawNrHoYsQjUF9cUq8suEn1lnKqjnRxd1vqNDKxWPxsQjUF9QfVsaaNbe)5DEdcGVDawNrHoYsQjUF9cEVeLfns6bEl6FqhkcpyKvTMjkl(wu6deoXSTArtYtj5fwuebmS8oVbbW3oaRZOqhzbyEn1lC7fo9sdo9AMfst9DemG4m9bcNyEzGbEHiGHL3rWaI7S4tuwaMx4YIgj9aVfDPKK0UsPXFIMazvRzgTfFlk9bcNy2wTOj5PK8cl6cJ48UgsOKU5Diipt03xfiB8QfiE1MxW7LgC61mlKM67iyaXz6deoX8cEV0GtVM)d6qxn4MizM(aHtmlAK0d8w0Lsss7kLg)jAcKvTMzKS4BrJKEG3IsZCBIKHswu6deoXSTAvRAvl6mKCpWBnRnrGx7weWrrkICBIapJKfvCi)7HUwuCGgyaPsmVmsEfj9aVx8B1n7tSOWKaSJtw0z9cvar5Ko3lZdavG8jZ61qvyR53qdHE6qajNangUxJap0d8jzGPgUxtYqeoaXqeSaoz0mgctcWooTg2osY8IJTg2oMx38aqfOoQaIYjDEEVMKpzwVGdKuacj9QT2m2R2ebETBVGtVGJMFrikVAh4qFIpzwVe9r8qP187tM1l40lJmJrmVmFCjtEPaVyewiWvVIKEG3l(TA2NmRxWPxMh1aMHyEPHekP9dZRe4zNEG3lW7fCyinrmVWasVmhf6i7tM1l40lJmJrmVWXl5foGsnB2N4tM1R2vJGsckX8cHWasYReObjuVqiO3VzVmYPebtxVEWdNJq2GjW9ks6b(1lWZNN9jrspWVzyskbAqcfcgpwt(KiPh43mmjLaniHcpeddbOn0RHEG3Nej9a)MHjPeObju4HyigaW8jZ6f6hW2bq9sghZlebmmI51QHUEHqyaj5vc0GeQxie07xVIN5fmjbNWaQEpuVU1lg4PSpjs6b(ndtsjqdsOWdXW9dy7aO9vdD9jrspWVzyskbAqcfEigUkfCD4tIKEGFZWKuc0Gek8qmSjKMiwhdi7mk0HXWKuc0GeAFPe4zle8eLpjs6b(ndtsjqdsOWdXWDemG4ocpy0AmmjLaniH2xkbE2cbpFsK0d8BgMKsGgKqHhIHWa6bEFIpzwVAxnckjOeZlAgso3l9AiV0b5vKuG0RB9kMjoEGWPSpzwVmpAvk46WRdZlyGDpeo5fUFGxZiWFsgiCYl6PMJwVU3ReObjuC5tIKEGFHSkfCD4tIKEGFHhIHMUKjFYSEj6dkzYlr3CRxH6f2jx1Nej9a)cpedtbN3JKEGVZVvn(JgcsIT(Kz9Y8eEVWe485ETIpnnO1lf4LoiVqvk46GyEzEan0d8EHBK5EXa3d1RfySxN6fgqMO1lyaa)EOEDyE9aDCpuVU1RyM44bcNWv2Nej9a)cpedLcFps6b(o)w14pAiiRsbxheZ4ddYQuW1bXYbN7tM1lJmmy85Ez2bDOi8GrEfQxTbVxIE74ftqEpuV0b5f2jx1l8eHxlLapBn2RatjPx6iuVAp8Ej6TJxhMxN6fzeWojTEj(0X9EPdYRNmc1lZxIU58ci96wVEG6LamFsK0d8l8qm8pOdfHhmY4ddIgsOKM1RH6kOZoQfJEQKAI7x4cnXYnHrmnbAqaDyG71TfiThoXTEneCXte4YOAZNmRx44LyEPaVye29KxIh07Lc8syjVwLcUo8s0n36fq6fIWXzKC9jrspWVWdXWzc5fiCY4pAiiRsbxhDDiPDa4mJNj4ceK2ef8AWPxZZCqbYm9bcNygLiff8AWPxZnXQKSdW67iyaXBM(aHtmJQnrbVgC618ocgqChdKe2m9bcNygvBIaEn40R5Ghj5PZZ0hiCIzu4jc4XtugfUxyeN31qcL0nVdb5zI((QaztlqejU8jZ6LOd(9yK0lH9EOEfEHQuW1HxIU58s8GEVKuKg3d1lDqErpjHo3lDiPDa4mVIN51iM5EOETWIe5fgq6vOEXPyvVAVxIE74tIKEGFHhIHPGZ7rspW353Qg)rdbzvk46ONyRXhge6jj05zgHDPtHlKzc5fiCkVkfCD01HK2bGZMManiGomW96Mze2LoTfiT3NmRx4OthEzUqAYl0rWaIn2RGVaVewYRWluLcUo8s0nNxIh07LKI04EOEPdYl6jj05EPdjTdaN5v8mVqPKKuVWNsJ)enbYRB9ssbBE2Nej9a)cpedtbN3JKEGVZVvn(JgcYQuW1rpXwJpmi0tsOZZmc7sNcxiZeYlq4uEvk46ORdjTdaNnvdo9AMfst9DemG4m9bcNyt1GtVMxkjjTRuA8NOjqz6deoXMMaaodi(ZlLKK2vkn(t0eOSamFYSEHJoD4L5cPjVqhbdi2R4zE9a1ln40ReZR7vGxOussQx4tPXFIMazSxIjVapFUxPqsEfiab1l6jj05EfqJ7x1RgbUEW4KxAiHs6M9QD1isem9aV53l8bYpyaVU1ljfS5zFsK0d8l8qmmfCEps6b(o)w14pAiiRsbxh9eBn(WGqpjHopZiSlDkCHmtiVaHt5vPGRJUoK0oaC2un40Rzwin13rWaIZ0hiCInfNAWPxZlLKK2vkn(t0eOm9bcNytxyeN31qcL0nVdb5zI((QaztlqABkUXPgC618oeKNj67kq(bdKPpq4eZadWzca4mG4pVdb5zI(UcKFWazby4YNmRx4W7VD4vOE1E49s8PdGG6L5qn2lrbVxIpD4L5q9c3abDpg51QuW1bU8jrspWVWdXWuW59iPh478BvJ)OHGGD)TdJpmijqdcOddCVUzgHDPtHle8mWanKqjnRxd1vqNDeCHG30eObb0HbUx3wGisFYSEHJoD4L5q9k4lWlS7VD4vOE1E49kGg3VQxKrejLp3R27LgsOKUEHBGGUhJ8Avk46ax(KiPh4x4Hyyk48EK0d8D(TQXF0qqWU)2HXhgKfgX5DnKqjDZ7qqEMOVVkq2aP9ttGgeqhg4EDBbs79jZ6foEjVcVqeooJKEjEqVxsksJ7H6LoiVONKqN7LoK0oaCMpjs6b(fEigMcoVhj9aFNFRA8hneeeHJZm(WGqpjHopZiSlDkCHmtiVaHt5vPGRJUoK0oaCMpzwVGdciMw1lyYdipDUx37vW5EbW8shKxg52boiVqOuiSKxN6vkewA9k8Y8LOBoFsK0d8l8qmmKP4PUcKs6vJpmi0tsOZZmc7sN2ce8ef80tsOZZsck9(KiPh4x4HyyitXtDyc8L8jrspWVWdXq(bDOB38PadAd9QpXNmRxTkCCgjxFYSEHoeKNj69cFWUEfQxTbhH3l0riHrpX8QvEWO1RvJKPn7fogMxkWlr6LgsOKUEbJKEjJ3u2l0ygYlmG0RvPGRdVomVe27H6Lzh0HUAWnrsVasVmxin5f6iyaXEjEqVxWa7EiCk7tIKEGFZichNbzhcYZe9DfSRXhgeCQbNEn)h0HUAWnrYm9bcNytXno1GtVMzH0uFhbdiotFGWjMbgKaaodi(Z78geaF7aSoJcDKLutC)2cEIaxtreWWY7iKWONyDeEWOnVAKm1cK2GJtxyeN31qcL0nVdb5zI((QazdCHGBrAuboijpLY7iKWONyDeEWOnlJ3eU8jrspWVzeHJZGhIH7qqEMOVVkq2y8HbzHrCExdjus3wG0MbgGiGHL1b1zskyCGKTDgLOtZRgjtTaPn4Opjs6b(nJiCCg8qmekhaAq4bJ8jrspWVzeHJZGhIHirY0QbIpXNmRxIoaWzaX)6tIKEGFZj2cbgqpWB8HbbradlJWbagxy1SKIKAGbAiHsAwVgQRGo7i4cXOfHbgGiGHL35nia(2byDgf6ilaBkUreWWY7iyaXDeEWOnlaZadsaaNbe)5DemG4ocpy0MLutC)cxi4jcC5tM1lCyW53d1lKizYlf4fJWcbU61PuJxcBaLm)EHJxYlXNo8cDEdcGVEbW8YCuOJSpjs6b(nNyl8qmuyP(PuJXF0qqGgCkfCoj3oca8gFyqqeWWY78geaF7aSoJcDKfGzGbAiHsAwVgQRGo7i42Mi8jrspWV5eBHhIHcl1pLAwJpmiicyy5DEdcGVDawNrHoYcW8jrspWV5eBHhIHiCaG1XeKZn(WGGiGHL35nia(2byDgf6ilaZNej9a)MtSfEigIqYLKMUhQXhgeebmS8oVbbW3oaRZOqhzby(KiPh43CITWdXqStsiCaGz8HbbradlVZBqa8TdW6mk0rwaMpjs6b(nNyl8qmm(eTQm49uW5gFyqqeWWY78geaF7aSoJcDKfG5tM1lC8sEzU4tKxamm4eAI5fcHbKKx6G8c7KR6f6qqEMO3lufiB8ctcA8cFG8dgWReOHwVUp7tIKEGFZj2cped3rWaI7S4tKXcl1byyDOjge8m(WGGtebmS8ocgqCNfFIYcWMIiGHL3HG8mrFxbYpyGSaSPicyy5Diipt03vG8dgilPM4(fUqezwu(Kz9c344Nt76vWLuWM7LamVqOuiSKxIjVuaWKxOJGbe7foeKewC5LWsEHoVbbWxVayyWj0eZlecdijV0b5f2jx1l0HG8mrVxOkq24fMe04f(a5hmGxjqdTEDF2Nej9a)MtSfEigUZBqa8TdW6mk0HXcl1byyDOjge8m(WGGiGHL3HG8mrFxbYpyGSaSPicyy5Diipt03vG8dgilPM4(fUqezwu(Kz9chVKxOZBqa81lW7vca4mG43lChykj9c7KR6Lzh0HIWdgHlVeEoTRxIjVcj5fuW9q9sbEbdaZl8bYpyaVIN5fd41duVgXmKxOJGbe7foeKe2Spjs6b(nNyl8qmCN3Ga4BhG1zuOdJpmimGM)d6qr4bJY6LmDp0P4gNAWPxZ7qqEMOVRa5hmqM(aHtmdmqdo9AEhbdiUJbscBM(aHtmdmyHrCExdjus38oeKNj67RcKnWvKgyaotaaNbe)5Diipt03vG8dgiladx(Kz9chaZRGXwVcj5LamJ9A)dg5LoiVap5L4thEXbIPv9cF8nx2lC8sEjEqVxS53d1lSyvs6LoI3lrVD8Iryx6uVasVEG61QuW1bX8s8PdGG6v8Z9s0BNSpjs6b(nNyl8qmSjKMiwhdi7mk0HXhgezCSond9AoySnlaBkU1qcL0SEnuxbD2rWnbAqaDyG71nZiSlDQbgGZvPGRdILdoFAc0Ga6Wa3RBMryx60wGKG1BcJOVWONHlFYSEHdG51d8kyS1lXhN7f7iVeF64EV0b51tgH6LifXASxcl5fCiM58c8EHa21lXNoacQxXp3lrVD8kEMxpWRvPGRJSpjs6b(nNyl8qmSjKMiwhdi7mk0HXhgezCSond9AoySnFFlIueWPmowNMHEnhm2MzcYqpWpfNRsbxhelhC(0eObb0HbUx3mJWU0PTajbR3egrFHrpZNej9a)MtSfEigUJGbe3r4bJwJpmijqdcOddCVUzgHDPtBbsBWVkfCDqSCW5(Kz9YiREjs49s8PdGG6f6iyaXEHdbjH1lHL8cFG8dgWlXNo8cfyoVIN5L5IprEjPGnp7foI8s8X5EbdaZlDawYlecdijV0b5f2jx1RvbYgVsGgA96(Spjs6b(nNyl8qmChcYZe9Dfi)Gbm(WGSWioVRHekPBlqe5uCQbNEnVJGbe3XajHntFGWj2ugqZ)bDOi8Grz9sMUh6uCUkfCDqSCW5ttaaNbe)5DEdcGVDawNrHoYcWMMaaodi(Z7iyaXDw8jkNgHekTTabpFYSEzKvVej8Ej(0HxOJGbe7foeKewVewYl8bYpyaVeF6WluG58k4skyZ9saw2Nej9a)MtSfEigUdb5zI(UcKFWagFyqwyeN31qcL0TfiICQgC618ocgqChdKe2m9bcNytzan)h0HIWdgL1lz6EOtreWWY78geaF7aSoJcDKfG5tIKEGFZj2cped3rWaI7S4tKXhgeCUkfCDqSCW5t1qcL0SEnuxbD2rWfIOGxdo9AEfqusIjaLY0hiCI5t8jZ6fo8(BhKC9jZ6v76m3MizOKxJd6Gw1lyYdipDUxH6vBW7LgsOKUEj(0HxOJGbe7foeKewVWTOG3lXNo8cLsss9cFkn(t0eiVU3RGXo9apU8kEMxMDqhkCWRxTl0dLIprEjal7tIKEGFZy3F7acnZTjsgkz8Hbrdo9AEhbdiUJbscBM(aHtSPicyy5)Go0Tpd9qP4tuwa20fgX5DnKqjDZ7qqEMOVVkq20cK2GxKgLgC618sjjPDLsJ)enbktFGWjMpzwVmFqemVeG5Lzh0HIWdg51H51PEDRxbcqq9sbEjfEVacA2lZb86bQxcl5LzT6ftqEpuVmx8jYyVomV0GtVsmVUxbEzUqAYl0rWaIZ(KiPh43m293oGhIH)bDOi8GrgFyqWno1GtVMzH0uFhbdiotFGWjMbgGtebmS8ocgqCNfFIYcWW1unKqjnRxd1vqNDeCkPM4(TfJEQKAI7x4QxYuxVgYOABkUxyeN31qcL0nVdb5zI((QazdCBVbgGtebmS8oVbbW3oaRZOqhzby4YNmRxWHcC9yavVhQxabDpg5L5IprEbEV0qcL01lDeQxIpo3l(nd5fgq6LoiVycYqpW7faZlZoOdfHhmYlXNo8ssysAhEXeK3d1lyXZOMl51H51CGGxJygYloTRx6iEVmAV0qcL01lG0ly8yUxIpD4fkLKK6f(uA8NOjqzFsK0d8Bg7(BhWdXW)GoueEWiJtZtCQRHekPle8m(WGSWioVRHekPBEhcYZe99vbYMwG02uCRbNEnVussAxP04prtGY0hiCIzGbboijpLY)bDOBFg6HsXNOm9bcNygyWcJ48UgsOKU5Diipt03xfiBGlerHRP4eradlVJGbe3zXNOSaSPAiHsAwVgQRGo7OwGGBrbpUBZOsGgeqhg4EDXfUMkjmjTJaHt(Kz9Y8imjTdVm7GoueEWiVOqYN71H51PEj(4CViJa2jjVycY7H6f68geaFZEzoGx6iuVKeMK2HxhMxOaZ5fusxVKuWM719EPdYRNmc1lrTzFsK0d8Bg7(BhWdXW)GoueEWiJpmisQjUFHBca4mG4pVZBqa8TdW6mk0rwsnX9l84jIPjaGZaI)8oVbbW3oaRZOqhzj1e3VWfIOMQHekPz9AOUc6SJGtj1e3VTKaaodi(Z78geaF7aSoJcDKLutC)cVO8jZ6fkLKK6f(uA8NOjqEXeK3d1l05nia(M9chD6WlZfstEHocgqSxGNp3lMG8EOEHocgqSxMl(e5fUfE94EPdjTdaN519E9KrOEXVNWv2Nej9a)MXU)2b8qmCPKK0UsPXFIMaz8HbbradlVZBqa8TdW6mk0rwa2uCJtn40Rzwin13rWaIZ0hiCIzGbicyy5DemG4ol(eLfGHlFYSEHJoD4f9abOdV0qcL01RGloMVEjSKxOucFk5f49s0nx2Nej9a)MXU)2b8qmCPKK0UsPXFIMaz8HbzHrCExdjus38oeKNj67RcKnTaPn41GtVMzH0uFhbdiotFGWjg8AWPxZ)bDORgCtKmtFGWjMpjs6b(nJD)Td4HyinZTjsgk5t8jZ6fQsbxhEj6aaNbe)RpzwVmFtCyK0R2LqEbcN8jrspWV5vPGRJEITqMjKxGWjJ)OHGSdwxhsAhaoZ4zcUabjbaCgq8N3rWaI7S4tuoncjuA7yYiPh4dElqWlBKeLpzwVAxI)2HxcpN21lXKxHK8kqacQxkWRuaZlW7L5IprELgHekTzVGd885EjEqVx4W7zEHJOW0t761TEfiab1lf4Lu49ciOzFsK0d8BEvk46ONyl8qmCM4VDy8HbbNZeYlq4uEhSUoK0oaC2ugHiGHLXUN1ftHPN2nlPM4(fU4nnbAqaDyG71nZiSlDAl45tM1R2ba4EHbKEHocgqCdXzEbVxOJGbeVQ8mrEj8CAxVetEfsYRabiOEPaVsbmVaVxMl(e5vAesO0M9coWZN7L4b9EHdVN5foIctpTRx36vGaeuVuGxsH3lGGM9jrspWV5vPGRJEITWdXqyaaVlPfiitKXyaz)jJqHGNXKrOYOhnaHxH0Er4tIKEGFZRsbxh9eBHhIH7iyaXneNz8HbHEscDElqAViMspjHopZiSlDAlqWtetX5mH8ceoL3bRRdjTdaNnLricyyzS7zDXuy6PDZsQjUFHlEttGgeqhg4EDZmc7sN2cE(Kz9chD6WlZfstEHocgqSxGNp3lZfFI8s8GEVm7GoueEWiVeFCUxRgZ9saw2lC8sEXeK3d1l05nia(6fq6vGaMH8shsAhaol7tIKEGFZRsbxh9eBHhIH7iyaXDw8jY4ddcUXPgC61mlKM67iyaXz6deoXmWagqZ)bDOi8Grzj1e3VTaruWRbNEnVcikjXeGsz6deoXW1uCptiVaHt5DW66qs7aWzgyaIagwEN3Ga4BhG1zuOJSKAI73wGGxUndmyHrCExdjus38oeKNj67RcKnTaP9ttaaNbe)5DEdcGVDawNrHoYsQjUFBbprGlFsK0d8BEvk46ONyl8qmChbdiUZIprgFyq0qcL0SEnuxbD2rWnbaCgq8N35nia(2byDgf6ilPM4(1N4tM1luLcUoiMxMhqd9aVpzwVWbW8Avk46WRB9saMXEjM8ssbNp3lXXREPaVewYl0rWaIxvEMiVuGxi0tyNUEHjbnEPdYlyXU3mKxiGxyn2lAg696W8sm5vijVc1RMWi8kbZlCJjbnEPdYlyskbAqc1l4qmZHRSpjs6b(nVkfCDqmi7iyaXRkptKXhgeebmS8QuW1rwaMpzwVWH3F7WRq9Q9W7LO3oEj(0bqq9YCOg7LOG3lXNo8YCOg7v8mVmAVeF6WlZH6vGPK0R2L4VD4tIKEGFZRsbxhedEigMcoVhj9aFNFRA8hneeS7VDy8HbjbAqaDyG71nZiSlDkCHGhCIBn40RzgrWizFvzObuQjtFGWj2uebmS8mXF7iladx(Kz9cDiipt07f(GD9kuVAdocVxOJqcJEI5vR8GrRxRgjtRx37fQsbxhEHbKEXIMak5fc4fwAZEz(gWzEHbKEHdVN5foIctpTRxhMxWa7EiCk7tIKEGFZRsbxhedEigUdb5zI(Uc214ddcIagwEhHeg9eRJWdgT5vJKPwG0gCCkUXPgC61m29SUykm90Uz6deoXmWagHiGHLXUN1ftHPN2nladx(Kz9YiRE1MxAiHs66L4thEHsjjPEHpLg)jAcKxMicMxcW8chEpZlCefMEAxVqM7vAEIFpuVqhbdiEv5zIY(KiPh438QuW1bXGhIH7iyaXRkptKXP5jo11qcL0fcEgFyq0GtVMxkjjTRuA8NOjqz6deoXMQbNEnJDpRlMctpTBM(aHtSPmcradlJDpRlMctpTBwsnX9lCXB6cJ48UgsOKU5Diipt03xfiBG02unKqjnRxd1vqNDeCkPM4(TfJ2NmRx4Othab1lZrems6fQkdnGsnEfpZlr6L5fVP1laMxTYdg519EPdYl0rWaIxVo1RB9smqQdVe27H6f6iyaXRkptKxG3lr6LgsOKUzFsK0d8BEvk46GyWdXWDemG4vLNjY4ddco1GtVMzebJK9vLHgqPMm9bcNytdCqsEkLr4bJ6331b13rWaI3SmEtqe50fgX5DnKqjDZ7qqEMOVVkq2arK(KiPh438QuW1bXGhIH7qqEMOVVkq2y8HbzHrCExdjus3wGisFsK0d8BEvk46GyWdXWDemG4vLNjYIUWOK1S2mA8SQvTw]] )
    

end
