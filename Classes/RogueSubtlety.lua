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

            cycle = function ()
                if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
            end,

            usable = function ()
                if boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all or buff.subterfuge.up, "not stealthed"
            end,

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

            usable = function ()
                return settings.mfd_waste or combo_points.current == 0, "combo_point (" .. combo_points.current .. ") waste not allowed"
            end,

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

            disabled = function ()
                return not ( boss and group )
            end,

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


    spec:RegisterSetting( "mfd_waste", true, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If unchecked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
        width = "full"
    } )  


    spec:RegisterPack( "Subtlety", 20200614, [[daLXRbqiOqpckQnjH(euqyukP6ukPSkOa9kufZcvLBrrHDjQFPemmOihdk1YKGEgQsnnkkDnjI2Mej(MsIQXHQK6COkjwNsIY8ucDpqAFOQ6Fqbr6GsKKfQK0dPOOjkrQlkrOAJqb1hLiuAKqbrDsOG0kvQ6LseOMPeHIBkra7KIQFkrGmuOawQeb9uOAQsGRkriBvjr8vLePZcfeXEP0FfzWsDyHfdPhlPjt0Lr2meFwPmAqDAfRgvjPxRenBc3Mc7g43QmCqCCjsQLJYZv10jDDuz7qjFNImEuL48suRxjH5Ruz)uTfBBbwCzOK18cXuHyctLc2MnJDHyZRnBPyX1YqiloKOUm2iloimiloohQkiTSfhsuwCH0wGf)powLS4WQc5xzlSW2OWCO56zSWpgCIqNduzbIUWpg1fS4OCJqXqbwulUmuYAEHyQqmHPsbBZMXUqS51MfBlEWPWhZIJpgMPfhEKscyrT4s6RwCm7nohQkiTS3LWBJJ89y2ByvH8RSfwyBuyo0C9mw4hdorOZbQSarx4hJ6c(Em79Eoa5n2MLpVletfIjFVVhZEBMWbyJ(vMVhZEBgExQKss6Dj4PU0B98wsibNq9oQ6CaVfZRzFpM92m8UesghwK0BnyBKMgeVRhqo6CaVpG3LabBjj9g5yExAku4SVhZEBgExQKss6Dj6jVXqvY4ZwCX86BlWI)kfcfMK2cSMJTTalobcubjTRAXRSrj2ew819wdbb0mYaKjtuSeq)NjqGkiP37259dHeIKgSns)8dZXMLei96Xm8ErV5T3R5DrVx3BuoeK8Ruiu4mheV3TZBuoeKmwbyE4mheVxZIhvDoGf)Hd5z6v2SKSQ18cTfyXjqGkiPDvlELnkXMWIJYHGKFyo2SKaj9yGqEzoiEx076zGEji3a0pljKPoQ3lc17cT4rvNdyXRHqKIQohijMxT4I51eimiloYaMh2QwZ5TTalobcubjTRAXRSrj2ew8hcjejnyBK(5hMJnljq61Jz4nuVnR3f9UEgOxcYna99MFOEBwlEu15aw8AiePOQZbsI5vlUyEnbcdYIJmG5HTQ1CZAlWItGavqs7Qw8kBuInHfVEgOxcYna9ZsczQJ69Iq9gBVndVx3BneeqZsIGqS0RSqJnYitGavqsVl696EJYHGKXkaZdN5G49UDEhRGyJszfMsid71KmavktGavqsVl69dHeIKgSns)8dZXMLei96Xm8ErV5T3f9gLdbjdMny9tyrGnkavkZbX718EnlEu15aw8AiePOQZbsI5vlUyEnbcdYIJmG5HTQ18sAlWItGavqs7Qw8kBuInHfpwbXgLYqigYXcLYSaS0B(H6DHEx07hcjejnyBK(5hMJnljq61Jz49Iq9UqlEu15aw8nXDgOIqsw1AEPylWItGavqs7Qw8OQZbS4pCiptVYMLKfVYgLytyX1qqan)uLrAsPkmyk1CuMabQGKEx0BneeqZidqMmrXsa9FMabQGKEx0BjHYHGKrgGmzIILa6)mJmIb8EVO3y7DrVFiKqK0GTr6NFyo2SKaPxpMH3q9UqVl6TogusVKCiVndVzKrmG3B(9UuS41YvbL0GTr6BnhBRAnFLBlWItGavqs7Qw8kBuInHfhJERHGaAwseeILELfASrgzceOcs6DrVJvqSrPmQiKuAajfMspCiptFMfGLEd1BE7DrVFiKqK0GTr6NFyo2SKaPxpMH3q9M3w8OQZbS4pCiptVYMLKvTMZRTfyXjqGkiPDvlELnkXMWIJvWMavqzUNsqyZXgTCIDAOZb8UO3R7TgccOzKbitMOyjG(ptGavqsVl6TKq5qqYidqMmrXsa9FMrgXaEVx0BS9E3oV1qqanBIcihWiELyzceOcs6DrVFiKqK0GTr6NFyo2SKaPxpMH3lc1BZ69UDEhRGyJs5bqynAGoIrlNjqGkiP3f9gLdbj)LnqpXNoKKKcfoZbX7IE)qiHiPbBJ0p)WCSzjbsVEmdVxeQ382BE8owbXgLYOIqsPbKuyk9WH8m9zceOcs69Aw8OQZbS4pCiptVYMLKvTMZRylWItGavqs7Qw8kBuInHf)Hqcrsd2gPV38d1BEBXJQohWI)WCSzjbsVEmdRAnhBmzlWIhvDoGf)Hd5z6v2SKS4eiqfK0UQvTQfN(Nav6TfynhBBbwCceOcsAx1IxzJsSjS4eGyBLZ6yqj9sgbV4n)EJT3f9gJEJYHGK)YgON4thsssHcN5G4DrVx3Bm6T80C9avcOSqjzcregucLJbY6uxoGnVl6ng9oQ6CGC9avcOSqjzcreguEajeXSbREVBN3iCcrIrv4GTrjDmiVx07TQmBe8I3RzXJQohWIxpqLaklusMqeHbzvR5fAlWItGavqs7Qw8kBuInHfhJExVtiptG8dhYZucves6ZCq8UO317eYZei)LnqpXNoKKKcfoZbX7D78gz2G1eJmIb8EViuVXgtw8OQZbS4OI7KPdjPWuIaKrzRAnN32cS4rvNdyX34cMCcq6qsXki2PWwCceOcsAx1QwZnRTalobcubjTRAXRSrj2ew819(Hqcrsd2gPF(H5yZscKE9ygEZpuVl07D78MfJmryranhs5NhG387DPGjVxZ7IEJrVR3jKNjq(lBGEIpDijjfkCMdI3f9gJEJYHGK)YgON4thsssHcN5G4DrVjaX2kNLeYuh1B(H6nVXKfpQ6CaloYv5EsMIvqSrPekfgw1AEjTfyXjqGkiPDvlELnkXMWI)qiHiPbBJ0p)WCSzjbsVEmdV5hQ3f69UDEZIrMiSiGMdP8ZdWB(9UuWKfpQ6Caloeo2GuEaBjur8QvTMxk2cS4eiqfK0UQfVYgLytyXr5qqYmQUuq)NqowLYCq8E3oVr5qqYmQUuq)NqowLs1JdOel)Aux69IEJnMS4rvNdyXvykXbqpoGmHCSkzvR5RCBbw8OQZbS4SbcebLgq6HevYItGavqs7Qw1AoV2wGfNabQGK2vT4v2OeBclE9oH8mbYFzd0t8PdjjPqHZmYigW79IExsV3TZBKzdwtmYigW79IEJnV2IhvDoGf30XesSObKy0FGaujRAnNxXwGfNabQGK2vT4v2OeBclobi2wzVx0BZIjVl6nkhcs(lBGEIpDijjfkCMdIfpQ6CalUbzCSYPdjj4QJmjzuy8w1Ao2yYwGfNabQGK2vT4rvNdyXzuazaBjeryqVfVYgLytyX1GTrAwhdkPxsoK3l6n25s69UDEVU3R7TgSnsZWuiu4mKQ6n)EZRXK3725TgSnsZWuiu4mKQ69Iq9Uqm59AEx0719oQ6GfLiazm07nuVX27D78wd2gPzDmOKEj5qEZV3fYR49AEVM372596ERbBJ0SogusVeKQMketEZV38gtEx0719oQ6GfLiazm07nuVX27D78wd2gPzDmOKEj5qEZV3M1SEVM3RzXRLRckPbBJ03Ao2w1QwCjHeCc1wG1CSTfyXjqGkiPDvlELnkXMWIJrVFLcHctYm724ilEu15aw8LtDPvTMxOTalEu15aw8xPqOWwCceOcsAx1QwZ5TTalobcubjTRAXJQohWIxdHifvDoqsmVAXfZRjqyqw8Q8TQ1CZAlWItGavqs7Qw8kBuInHf)vkekmjZHqyXJQohWIZ4aPOQZbsI5vlUyEnbcdYI)kfcfMKw1AEjTfyXjqGkiPDvlELnkXMWIRJbL0ljhYB(9Uu8UO3mYigW79IEVvLzJGx8UO31Za9sqUbOV38d1BZ6Tz496ERJb59IEJnM8EnVXGExOfpQ6Caloy2GvurijRAnVuSfyXjqGkiPDvl(bXI)KAXJQohWIJvWMavqwCScbhzXHWMJnA5e70qNd4DrVFiKqK0GTr6NFyo2SKaPxpMH38d17cT4yfSeimilo3tjiS5yJwoXon05aw1A(k3wGfNabQGK2vT4v2OeBclowbBcubL5EkbHnhB0Yj2PHohWIhvDoGfVgcrkQ6CGKyE1IlMxtGWGS4VsHqHtv5BvR58ABbwCceOcsAx1IFqS4pPw8OQZbS4yfSjqfKfhRqWrw8clP384TgccOzSMTJLjqGkiP3yqV5Dj9MhV1qqanBeVsS0HKE4qEM(mbcubj9gd6DHL0BE8wdbb08dhYZuc5QCFMabQGKEJb9Uqm5npERHGaAoerLnA5mbcubj9gd6n2yYBE8g7s6ng0719(Hqcrsd2gPF(H5yZscKE9ygEZpuV5T3RzXXkyjqyqw8xPqOWjfMrp8jKw1AoVITalobcubjTRAXRSrj2ewCcqSTYzjHm1r9ErOEJvWMavq5xPqOWjfMrp8jKw8OQZbS41qisrvNdKeZRwCX8AcegKf)vkekCQkFRAnhBmzlWItGavqs7Qw8kBuInHfpwbXgLYGzdw)eweyJcqLYeiqfK07IEJrVr5qqYGzdw)eweyJcqLYCq8UO31Za9sqUbOFwsitDuV53BS9UO3R79dHeIKgSns)8dZXMLei96Xm8ErVl07D78gRGnbQGYCpLGWMJnA5e70qNd49AEx0719UENqEMa5VSb6j(0HKKuOWzgzed49ErOEZBV3TZ719owbXgLYGzdw)eweyJcqLYSaS0B(H6DHEx0BuoeK8x2a9eF6qssku4mJmIb8EZV3827IEJrVFLcHctYCieEx076Dc5zcKF4qEMsYauPCfoyB0NqyrvNdecV5hQ3ykZR49AEVMfpQ6Caloy2GvurijRAnhBSTfyXjqGkiPDvlELnkXMWIxpd0lb5gG(zjHm1r9ErOEJT3725TogusVKCiVxeQ3y7DrVRNb6LGCdqFV5hQ382IhvDoGfVgcrkQ6CGKyE1IlMxtGWGS4idyEyRAnh7cTfyXjqGkiPDvlELnkXMWI)qiHiPbBJ0p)WCSzjbsVEmdVH6Tz9UO31Za9sqUbOV38d1BZAXJQohWIxdHifvDoqsmVAXfZRjqyqwCKbmpSvTMJnVTfyXjqGkiPDvlELnkXMWItaITvoljKPoQ3lc1BSc2eOck)kfcfoPWm6HpH0IhvDoGfVgcrkQ6CGKyE1IlMxtGWGS4OCJqAvR5yBwBbwCceOcsAx1IxzJsSjS4eGyBLZsczQJ6n)q9g7s6npEtaITvoZOncyXJQohWIhSAaOKEmgbuRAnh7sAlWIhvDoGfpy1aqjiCINS4eiqfK0UQvTMJDPylWIhvDoGfxmBW6N4v5KBgeqT4eiqfK0UQvTMJ9k3wGfpQ6CaloASLoKKYM6Y3ItGavqs7Qw1QwCimQEgOHAlWAo22cS4rvNdyXFLcHcBXjqGkiPDvRAnVqBbwCceOcsAx1IhvDoGf3iyljzc5yjjfkSfhcJQNbAOPNQhq(wCSlPvTMZBBbwCceOcsAx1IdcdYIhR4Hdw8jKdOPdjb5mrmlEu15aw8yfpCWIpHCanDijiNjIzvR5M1wGfpQ6CaloKtNdyXjqGkiPDvRAvloYaMh2wG1CSTfyXjqGkiPDvloYXsaIxuR5yBXJQohWId5orIr)XXQKvTMxOTalobcubjTRAXRSrj2ewCuoeKmy2G1pHfb2OauPmheVl696E)qiHiPbBJ0p)WCSzjbsVEmdVx07c9E3oVXkytGkOm3tjiS5yJwoXon05aEVBN3y0BneeqZpvzKMuQcdMsnhLjqGkiP3725ng9UENqEMa5NQmstkvHbtPMJYCq8EnlEu15awCcR5ReluYQwZ5TTalobcubjTRAXRSrj2ew819gJERHGaAwgSLPhoKNPmbcubj9E3oVXO3OCii5hoKNPKmavkZbX718UO36yqj9sYH82m8MrgXaEV537sX7IEZiJyaV3l6To1LjDmiVXGExOfpQ6Caloy2GvurijRAn3S2cS4eiqfK0UQfpQ6Caloy2GvurijlELnkXMWIJrVXkytGkOm3tjiS5yJwoXon05aEx07hcjejnyBK(5hMJnljq61Jz4n)q9UqVl696EhRGyJszWSbRFclcSrbOszceOcs69UDEJrVJvqSrPmJGiMAOdyl9WH8m9zceOcs69UDE)qiHiPbBJ0p)WCSzjbsVEmdVndVJQoyrj5PzWSbROIqsEZpuVl0718UO3y0BuoeK8dhYZusgGkL5G4DrV1XGs6LKd5n)q9EDVlP38496ExO3yqVRNb6LGCdqFVxZ718UO3mcHrpCGkilETCvqjnyBK(wZX2QwZlPTalobcubjTRAXRSrj2ewCgzed49ErVR3jKNjq(lBGEIpDijjfkCMrgXaEV5XBSXK3f9UENqEMa5VSb6j(0HKKuOWzgzed49ErOExsVl6TogusVKCiVndVzKrmG3B(9UENqEMa5VSb6j(0HKKuOWzgzed49MhVlPfpQ6Caloy2GvurijRAnVuSfyXJQohWI)uLrAsPkmyk1CKfNabQGK2vTQ18vUTalEu15awCcR5ReluYItGavqs7Qw1Qw8Q8TfynhBBbwCceOcsAx1IxzJsSjS4y0BuoeK8dhYZusgGkL5G4DrVr5qqYpmhBwsGKEmqiVmheVl6nkhcs(H5yZscK0Jbc5LzKrmG37fH6nVZL0IhvDoGf)Hd5zkjdqLS4CpLoeK0wvAnhBRAnVqBbwCceOcsAx1IxzJsSjS4OCii5hMJnljqspgiKxMdI3f9gLdbj)WCSzjbs6XaH8YmYigW79Iq9M35sAXJQohWI)LnqpXNoKKKcf2IZ9u6qqsBvP1CSTQ1CEBlWItGavqs7Qw8kBuInHfhJE)kfcfMK5qi8UO3YtZGzdwrfHKY6uxoGnV3TZB6FcuPmkJcfoDijfMsYYdylBe8QhZ7IERJb5n)q9UqlEu15aw8AiePOQZbsI5vlUyEnbcdYIt)tGk9w1AUzTfyXjqGkiPDvlEu15awCi3jsm6powLS4v2OeBclog9wdbb08dhYZuc5QCFMabQGKwCKJLaeVOwZX2QwZlPTalobcubjTRAXRSrj2ewCcqSTYEZpuVlfm5DrVLNMbZgSIkcjL1PUCaBEx076Dc5zcK)YgON4thsssHcN5G4DrVR3jKNjq(Hd5zkjdqLYv4GTrV38d1BST4rvNdyXFyo2SKaj9yGqEw1AEPylWItGavqs7Qw8kBuInHfxEAgmBWkQiKuwN6YbS5DrVXO317eYZei)WH8mLqfHK(mheVl696EJrV1qqan)WCSzjbs6XaH8YeiqfK07D78wdbb08dhYZuc5QCFMabQGKEVBN317eYZei)WCSzjbs6XaH8YmYigW7n)ExO3R5DrVx3Bm6n9pbQugvCNmDijfMseGmkNncE1J59UDExVtiptGmQ4oz6qskmLiazuoZiJyaV387DHEVM3f9EDVJvqSrPmy2G1pHfb2OauPmlal9ErVl07D78gLdbjdMny9tyrGnkavkZbX71S4rvNdyX)YgON4thsssHcBvR5RCBbwCceOcsAx1IhvDoGf3iyljzc5yjjfkSfVYgLytyXzXiteweqZHu(zoiEx0719wd2gPzDmOKEj5qEVO31Za9sqUbOFwsitDuV3TZBm69RuiuysMdHW7IExpd0lb5gG(zjHm1r9MFOExHKmcEj9qiG071S41YvbL0GTr6BnhBRAnNxBlWItGavqs7Qw8kBuInHfNfJmryranhs5NhG387nVXK3MH3SyKjclcO5qk)SKJf6CaVl6ng9(vkekmjZHq4DrVRNb6LGCdq)SKqM6OEZpuVRqsgbVKEieqAXJQohWIBeSLKmHCSKKcf2QwZ5vSfyXjqGkiPDvlELnkXMWIJrVFLcHctYCieEx0B5PzWSbROIqszDQlhWM3f9UEgOxcYna9ZsczQJ6n)q9UqlEu15aw8hoKNPeQiK0BvR5yJjBbwCceOcsAx1IxzJsSjS4AiiGMF4qEMsixL7ZeiqfK07IElpndMnyfveskRtD5a28UO3OCii5VSb6j(0HKKuOWzoiw8OQZbS4pmhBwsGKEmqipRAnhBSTfyXjqGkiPDvlELnkXMWIJrVr5qqYpCiptjzaQuMdI3f9whdkPxsoK3lc17s6npERHGaA(5qvIHWTrzceOcs6DrVXO3SyKjclcO5qk)mhelEu15aw8hoKNPKmavYQwZXUqBbwCceOcsAx1IxzJsSjS4OCiizuXDsb3Rzgfv17D78gLdbj)LnqpXNoKKKcfoZbX7IEVU3OCii5hoKNPeQiK0N5G49UDExVtiptG8dhYZucves6ZmYigW79Iq9gBm59Aw8OQZbS4qoDoGvTMJnVTfyXjqGkiPDvlELnkXMWIJYHGK)YgON4thsssHcN5GyXJQohWIJkUtMq4yLTQ1CSnRTalobcubjTRAXRSrj2ewCuoeK8x2a9eF6qssku4mhelEu15awCuI9eB5a2SQ1CSlPTalobcubjTRAXRSrj2ewCuoeK8x2a9eF6qssku4mhelEu15awCKHrOI7Kw1Ao2LITalobcubjTRAXRSrj2ewCuoeK8x2a9eF6qssku4mhelEu15aw8auPxzHivdHWQwZXELBlWItGavqs7Qw8OQZbS41YvXPSdm1eQiE1IxzJsSjS4y07xPqOWKmhcH3f9wEAgmBWkQiKuwN6YbS5DrVXO3OCii5VSb6j(0HKKuOWzoiEx0BcqSTYzjHm1r9MFOEZBmzXjeeQQjqyqw8A5Q4u2bMAcveVAvR5yZRTfyXjqGkiPDvlEu15aw8yfpCWIpHCanDijiNjIzXRSrj2ewCm6nkhcs(Hd5zkjdqLYCq8UO317eYZei)LnqpXNoKKKcfoZiJyaV3l6n2yYIdcdYIhR4Hdw8jKdOPdjb5mrmRAnhBEfBbwCceOcsAx1IhvDoGfpEySca9jwSIJLQhlew8kBuInHfxsOCiizwSIJLQhlejjHYHGKLNjG3725TKq5qqY1di5Q6GfLgWYKKq5qqYCq8UO3AW2indtHqHZqQQ3l6nVl07IERbBJ0mmfcfodPQEZpuV5nM8E3oVXO3scLdbjxpGKRQdwuAaltscLdbjZbX7IEVU3scLdbjZIvCSu9yHijjuoeK8RrDP38d17clP3MH3yJjVXGEljuoeKmQ4oz6qskmLiazuoZbX7D78gz2G1eJmIb8EVO3MftEVM3f9gLdbj)LnqpXNoKKKcfoZiJyaV387nV2IdcdYIhpmwbG(elwXXs1JfcRAnVqmzlWItGavqs7QwCqyqwCJYY4tAiM3iaw8OQZbS4gLLXN0qmVraSQ18cX2wGfNabQGK2vT4v2OeBclokhcs(lBGEIpDijjfkCMdI3725nYSbRjgzed49ErVletw8OQZbS4CpLgLmERAvl(Ruiu4uv(2cSMJTTalobcubjTRAXpiw8NulEu15awCSc2eOcYIJvi4ilE9oH8mbYpCiptjzaQuUchSn6tiSOQZbcH38d1BSZR8sAXXkyjqyqw8hwMuyg9WNqAvR5fAlWItGavqs7Qw8kBuInHfhJEJvWMavq5hwMuyg9WNq6DrVRNb6LGCdq)SKqM6OEZV3y7DrVLekhcsgzaYKjkwcO)ZmYigW79IEJT3f9UENqEMa5VSb6j(0HKKuOWzgzed49MFOEZBlEu15awCScW8Ww1AoVTfyXjqGkiPDvlEu15awCi3jsm6powLS4eVOSifghhqT4MftwCKJLaeVOwZX2QwZnRTalobcubjTRAXRSrj2ewCcqSTYEZpuVnlM8UO3eGyBLZsczQJ6n)q9gBm5DrVXO3yfSjqfu(HLjfMrp8jKEx076zGEji3a0pljKPoQ387n2Ex0BjHYHGKrgGmzIILa6)mJmIb8EVO3yBXJQohWI)WH8mzqcPvTMxsBbwCceOcsAx1IFqS4pPw8OQZbS4yfSjqfKfhRqWrw86zGEji3a0pljKPoQ38d1BZ6Tz496ERHGaAwseeILELfASrgzceOcs6DrVx37yfeBukRWuczyVMKbOszceOcs6DrVXO3AiiGMLbBz6Hd5zktGavqsVl6ng9wdbb08ZHQedHBJYeiqfK07IE)qiHiPbBJ0p)WCSzjbsVEmdVx0BE79AEVMfhRGLaHbzXFyzQEgOxcYna9TQ18sXwGfNabQGK2vT4hel(tQfpQ6CalowbBcubzXXkeCKfVEgOxcYna9ZsczQJ69Iq9gBV5X7c9gd6DScInkLvykHmSxtYauPmbcubjT4v2OeBclowbBcubL5EkbHnhB0Yj2PHohW7IEVU3AiiGMbZgS(AiwsSmbcubj9E3oV1qqanld2Y0dhYZuMabQGKEVMfhRGLaHbzXFyzQEgOxcYna9TQ18vUTalobcubjTRAXRSrj2ewCSc2eOck)WYu9mqVeKBa67DrVx3Bm6TgccOzzWwME4qEMYeiqfK07D78wEAgmBWkQiKuMrgXaEV5hQ3L0BE8wdbb08ZHQedHBJYeiqfK0718UO3R7nwbBcubLFyzsHz0dFcP3725nkhcs(lBGEIpDijjfkCMrgXaEV5hQ3yNl07D78(Hqcrsd2gPF(H5yZscKE9ygEZpuVnR3f9UENqEMa5VSb6j(0HKKuOWzgzed49MFVXgtEVM3f9EDVJvqSrPmy2G1pHfb2OauPmlal9ErVl07D78gLdbjdMny9tyrGnkavkZbX71S4rvNdyXF4qEMsYaujRAnNxBlWItGavqs7Qw8kBuInHfhRGnbQGYpSmvpd0lb5gG(Ex0BDmOKEj5qEVO317eYZei)LnqpXNoKKKcfoZiJyaV3f9gJEZIrMiSiGMdP8ZCqS4rvNdyXF4qEMsYaujRAvlok3iK2cSMJTTalobcubjTRAXRSrj2ew8hcjejnyBK(EZpuVl0BE8EDV1qqanVjUZavesktGavqsVl6DScInkLHqmKJfkLzbyP38d17c9EnlEu15aw8hMJnljq61JzyvR5fAlWIhvDoGfFtCNbQiKKfNabQGK2vTQ1CEBlWIhvDoGfhnQlFnqT4eiqfK0UQvTQvT4yrSFoG18cXuHyctLSWsAXnfmWa2ElogQbKJPK0BET3rvNd4TyE9Z(El(dHQwZlSuW2IdHDiJGS4y2BCouvqAzVlH3gh57XS3WQc5xzlSW2OWCO56zSWpgCIqNduzbIUWpg1f89y279CaYBSnlFExiMket(EFpM92mHdWg9RmFpM92m8UujLK07sWtDP365TKqcoH6Du15aElMxZ(Em7Tz4DjKmoSiP3AW2inniExpGC05aEFaVlbc2ss6nYX8U0uOWzFpM92m8UujLK07s0tEJHQKXN99(Em7DjoVqvoLKEJsihJ8UEgOH6nkTnGp7DPQwji67n4aMbCWmq4eEhvDoW79beLZ(Em7Du15aFgcJQNbAOqreXV03JzVJQoh4Zqyu9mqdLhOleCBgeqdDoGVhZEhvDoWNHWO6zGgkpqxa5oPVhZEJdcip8PEZIr6nkhccj9(1qFVrjKJrExpd0q9gL2gW7DaKEdHrMbKt1bS598ElpaL99y27OQZb(megvpd0q5b6cpiG8WNMEn033hvDoWNHWO6zGgkpqx4vkekSVpQ6CGpdHr1ZanuEGUGrWwsYeYXsskuy(GWO6zGgA6P6bKpuSlPVpQ6CGpdHr1ZanuEGUa3tPrjd(aHbbnwXdhS4tihqthscYzIy((OQZb(megvpd0q5b6cqoDoGV33JzVlX5fQYPK0BclIv2BDmiVvyY7OQhZ759oWkgrGkOSVhZExcPxPqOWEpiEd5(FqfK3RdoVXItaiwGkiVjazm079a8UEgOHUMVpQ6CGh6YPUKVbbkgFLcHctYm724iFFu15appqx4vkekSVhZEBMWuDP3MzPFVd1BKH9QVpQ6CGNhOludHifvDoqsmVYhimiOv577XS3LqoG3iCcrzVFtJwHP3B98wHjVXvkekmj9UeEAOZb8ED0YElVbS59F859OEJCSk9Ed5oXa28Eq8gCk8a28EEVdSIreOcATSVpQ6CGNhOlW4aPOQZbsI5v(aHbb9vkekmj5BqG(kfcfMK5qi89y27sfeiIYEB(SbROIqsEhQ3fYJ3MjgWBjhBaBERWK3id7vVXgtE)u9aYNpVdeLyERWH6Tz5XBZed49G49OEt8cKHrV3MgfEaERWK3aIxuVlXAML27J598Edo1Boi((OQZbEEGUay2Gvurij(geO6yqj9sYH4VukYiJya)IBvz2i4LI1Za9sqUbOp)qnRzSUog0IyJP1WGf67XS3LGaIYExHdWg5n70qNd49G4TjYB4alYBiS5yJwoXon05aE)K6DaKEBWj0bIG8wd2gPV3CqY((OQZbEEGUawbBcubXhimiOCpLGWMJnA5e70qNdWhwHGJGcHnhB0Yj2PHohO4dHeIKgSns)8dZXMLei96Xm4hAH(Em7ngGnhB0YExcpn05ayi17smKIH49EBWI8o8UYciEhOhN6nbi2wzVroM3km59RuiuyVnZs)EVok3iKeZ7xhHWBg9qOQ69ORL9gdjCq4Z7r9UgaVrjVv4q9(hdick77JQoh45b6c1qisrvNdKeZR8bcdc6Ruiu4uv(8niqXkytGkOm3tjiS5yJwoXon05a(Em7Dj6jP365TKqga5Tjyc4TEEZ9K3VsHqH92ml979X8gLBesI9((OQZbEEGUawbBcubXhimiOVsHqHtkmJE4ti5dRqWrqlSK8OHGaAgRz7yzceOcsIb5Dj5rdbb0Sr8kXshs6Hd5z6ZeiqfKedwyj5rdbb08dhYZuc5QCFMabQGKyWcXepAiiGMdruzJwotGavqsmi2yIhSljgC9hcjejnyBK(5hMJnljq61JzWpuEVMVhZEBMh4hjX8M7hWM3H34kfcf2BZS0EBcMaEZOOcpGnVvyYBcqSTYERWm6HpH03hvDoWZd0fQHqKIQohijMx5dege0xPqOWPQ85BqGsaITvoljKPo6IqXkytGkO8Ruiu4KcZOh(esFpM928zdwXq8EVsiWgfGkTY828zdwrfHK8gLqog5nEzd0t8EhQ3IZK3MjgWB98UEgOdG8McMOS3mcHrpS3Mgf27ns1bS5TctEJYHG4nhKS3LkXFElotEBMyaVLCSbS5nEzd0t8EJsQjIaEx6auP3BtJc7DH84T5RKSVpQ6CGNhOlaMnyfvesIVbbAScInkLbZgS(jSiWgfGkLjqGkizrmIYHGKbZgS(jSiWgfGkL5GuSEgOxcYna9ZsczQJYp2fx)Hqcrsd2gPF(H5yZscKE9yglw4UDyfSjqfuM7Pee2CSrlNyNg6CG1kUE9oH8mbYFzd0t8PdjjPqHZmYigWViuEVB36Xki2OugmBW6NWIaBuaQuMfGL8dTWIOCii5VSb6j(0HKKuOWzgzed45N3fX4RuiuysMdHOy9oH8mbYpCiptjzaQuUchSn6tiSOQZbcb)qXuMxzT189y2Bm8aMh27q92S84TPrHpo17sJZN3LKhVnnkS3Lg371po9hj59Ruiu4189rvNd88aDHAiePOQZbsI5v(aHbbfzaZdZ3GaTEgOxcYna9ZsczQJUiuS3TthdkPxso0IqXUy9mqVeKBa6ZpuE77XS3R0rH9U04EhI)8gzaZd7DOEBwE8o2Ib8Q3eVevvu2BZ6TgSnsFVx)40FKK3VsHqHxZ3hvDoWZd0fQHqKIQohijMx5degeuKbmpmFdc0hcjejnyBK(5hMJnljq61Jza1SfRNb6LGCdqF(HAwFpM9Ue9K3H3OCJqsmVnbtaVzuuHhWM3km5nbi2wzVvyg9WNq67JQoh45b6c1qisrvNdKeZR8bcdckk3iK8niqjaX2kNLeYuhDrOyfSjqfu(vkekCsHz0dFcPVhZExI5mrV6ne2CSrl79a8oecVpeVvyY7sfgOeJ3Oun4EY7r9UgCp9EhExI1mlTVpQ6CGNhOleSAaOKEmgbu(geOeGyBLZsczQJYpuSljpeGyBLZmAJa((OQZbEEGUqWQbGsq4ep57JQoh45b6cIzdw)eVkNCZGaQVpQ6CGNhOlGgBPdjPSPU899(Em79QCJqsS33hvDoWNr5gHe6dZXMLei96Xm4BqG(qiHiPbBJ0NFOfYZ6AiiGM3e3zGkcjLjqGkizXyfeBukdHyihlukZcWs(Hw4A((OQZb(mk3iK8aDHnXDgOIqs((OQZb(mk3iK8aDb0OU81a1377XS3M5Dc5zc8(Em7Dj6jVlDaQK3hcIzSvLEJsihJ8wHjVrg2REJdZXMLeWBC9ygEJWodVl4yGqEExpd69EazFFu15aFUkFOpCiptjzaQeFCpLoeK0wvcfB(geOyeLdbj)WH8mLKbOszoifr5qqYpmhBwsGKEmqiVmhKIOCii5hMJnljqspgiKxMrgXa(fHY7Cj99y271lrab9V3HGrHSS3Cq8gLQb3tEBI8wVBP34WH8m5ng(QC)AEZ9K34LnqpX79HGygBvP3OeYXiVvyYBKH9Q34WCSzjb8gxpMH3iSZW7cogiKN31ZGEVhq23hvDoWNRYNhOl8LnqpXNoKKKcfMpUNshcsARkHInFdcuuoeK8dZXMLeiPhdeYlZbPikhcs(H5yZscK0Jbc5LzKrmGFrO8oxsFFu15aFUkFEGUqneIuu15ajX8kFGWGGs)tGk98niqX4RuiuysMdHOO80my2GvuriPSo1LdyB3o6FcuPmkJcfoDijfMsYYdylBe8QhROoge)ql03JzVXa3j8g5yExWXaH88gcJmd8R0EBAuyVXHlT3mkKL92emb8gCQ3moayaBEJJHZ((OQZb(Cv(8aDbi3jsm6powL4d5yjaXlkuS5BqGIrneeqZpCiptjKRY9zceOcs67XS3LON8UGJbc55neg5n(vAVnbtaVnrEdhyrERWK3eGyBL92emPWeZBe2z4nK7edyZBtJcFCQ34yyVpM38QCV69gbiwieLZ((OQZb(Cv(8aDHhMJnljqspgiKhFdcucqSTY8dTuWur5PzWSbROIqszDQlhWwX6Dc5zcK)YgON4thsssHcN5GuSENqEMa5hoKNPKmavkxHd2g98dfBFpM9Ue9K34LnqpX79b8UENqEMaEVEGOeZBKH9Q3MpBWkQiK0AEZbe0)EBI8oyK3B3a28wpVHCq8UGJbc55DaKElpVbN6nCGf5noCiptEJHVk3N99rvNd85Q85b6cFzd0t8PdjjPqH5BqGkpndMnyfveskRtD5a2kIX6Dc5zcKF4qEMsOIqsFMdsX1XOgccO5hMJnljqspgiKxMabQGK72PHGaA(Hd5zkHCvUptGavqYD7Q3jKNjq(H5yZscK0Jbc5LzKrmGN)cxR46yK(NavkJkUtMoKKctjcqgLZgbV6X2TRENqEMazuXDY0HKuykraYOCMrgXaE(lCTIRhRGyJszWSbRFclcSrbOszwawUyH72HYHGKbZgS(jSiWgfGkL5GSMVhZEJHI4DiLV3bJ8MdcFE)Gbc5TctEFaYBtJc7T4mrV6Dbfu6S3LON82emb8wwEaBEJeVsmVv4a4TzIb8wsitDuVpM3Gt9(vkekmj920OWhN6Dak7TzIbY((OQZb(Cv(8aDbJGTKKjKJLKuOW8vlxfusd2gPpuS5BqGYIrMiSiGMdP8ZCqkUUgSnsZ6yqj9sYHwSEgOxcYna9ZsczQJUBhgFLcHctYCiefRNb6LGCdq)SKqM6O8dTcjze8s6Hqa5A(Em7ngkI3GZ7qkFVnncH3YH820OWdWBfM8gq8I6nVX0ZN3Cp5DjasP9(aEJE)7TPrHpo17au2BZed4DaKEdoVFLcHcN99rvNd85Q85b6cgbBjjtihljPqH5BqGYIrMiSiGMdP8ZdGFEJjZGfJmryranhs5NLCSqNdueJVsHqHjzoeII1Za9sqUbOFwsitDu(HwHKmcEj9qiG03hvDoWNRYNhOl8WH8mLqfHKE(geOy8vkekmjZHquuEAgmBWkQiKuwN6YbSvSEgOxcYna9ZsczQJYp0c99y27v6OWEJJH5Z7bXBWPEhcgfYYElpaXN3Cp5DbhdeYZBtJc7n(vAV5GK99rvNd85Q85b6cpmhBwsGKEmqip(geOAiiGMF4qEMsixL7ZeiqfKSO80my2GvuriPSo1LdyRikhcs(lBGEIpDijjfkCMdIVpQ6CGpxLppqx4Hd5zkjdqL4BqGIruoeK8dhYZusgGkL5GuuhdkPxso0IqljpAiiGMFouLyiCBuMabQGKfXilgzIWIaAoKYpZbX3hvDoWNRYNhOla505a8niqr5qqYOI7KcUxZmkQ6UDOCii5VSb6j(0HKKuOWzoifxhLdbj)WH8mLqfHK(mhKD7Q3jKNjq(Hd5zkHkcj9zgzed4xek2yAnFFu15aFUkFEGUaQ4ozcHJvMVbbkkhcs(lBGEIpDijjfkCMdIVpQ6CGpxLppqxaLypXwoGn(geOOCii5VSb6j(0HKKuOWzoi((OQZb(Cv(8aDbKHrOI7K8niqr5qqYFzd0t8PdjjPqHZCq89rvNd85Q85b6cbOsVYcrQgcbFdcuuoeK8x2a9eF6qssku4mheFFu15aFUkFEGUa3tPrjd(ieeQQjqyqqRLRItzhyQjur8kFdcum(kfcfMK5qikkpndMnyfveskRtD5a2kIruoeK8x2a9eF6qssku4mhKIeGyBLZsczQJYpuEJjFFu15aFUkFEGUa3tPrjd(aHbbnwXdhS4tihqthscYzIy8niqXikhcs(Hd5zkjdqLYCqkwVtiptG8x2a9eF6qssku4mJmIb8lInM89y27vcXk7n742GfL9MXjiVpeVvyod0bziP3gHc)EJsIZ0kZ7s0tEJCmVXqblHCsVRSr5Z7tHjMP5jVnnkS34xP9ouVlSK849RrD579X8g7sYJ3Mgf27q8N3RkUt6nhKSVpQ6CGpxLppqxG7P0OKbFGWGGgpmwbG(elwXXs1Jfc(geOscLdbjZIvCSu9yHijjuoeKS8mb2TtsOCii56bKCvDWIsdyzssOCiizoif1GTrAgMcHcNHu1f5DHf1GTrAgMcHcNHuv(HYBmTBhgLekhcsUEajxvhSO0awMKekhcsMdsX1LekhcsMfR4yP6XcrssOCii5xJ6s(HwyjndSXegusOCiizuXDY0HKuykraYOCMdYUDiZgSMyKrmGFrZIP1kIYHGK)YgON4thsssHcNzKrmGNFETVpQ6CGpxLppqxG7P0OKbFGWGGAuwgFsdX8gbW3JzVlnHeCc1BKqiqJ6sVroM3CFGkiVhLm(vM3LON820OWEJx2a9eV3hI3LMcfo77JQoh4Zv5Zd0f4Eknkz88niqr5qqYFzd0t8PdjjPqHZCq2Tdz2G1eJmIb8lwiM89(Em7Dj()eOsVVpQ6CGpt)tGk9qRhOsaLfkjtiIWG4BqGsaITvoRJbL0lze8c)yxeJOCii5VSb6j(0HKKuOWzoifxhJYtZ1dujGYcLKjeryqjuogiRtD5a2kIXOQZbY1dujGYcLKjeryq5bKqeZgSUBhcNqKyufoyBushdAXTQmBe8YA((OQZb(m9pbQ0Zd0fqf3jthssHPebiJY8niqXy9oH8mbYpCiptjuriPpZbPy9oH8mbYFzd0t8PdjjPqHZCq2Tdz2G1eJmIb8lcfBm57JQoh4Z0)eOsppqxyJlyYjaPdjfRGyNc77JQoh4Z0)eOsppqxa5QCpjtXki2OucLcd(geOR)qiHiPbBJ0p)WCSzjbsVEmd(Hw4UDSyKjclcO5qk)8a4VuW0AfXy9oH8mbYFzd0t8PdjjPqHZCqkIruoeK8x2a9eF6qssku4mhKIeGyBLZsczQJYpuEJjFFu15aFM(Nav65b6cq4yds5bSLqfXR8niqFiKqK0GTr6NFyo2SKaPxpMb)qlC3owmYeHfb0CiLFEa8xkyY3hvDoWNP)jqLEEGUGctjoa6XbKjKJvj(geOOCiizgvxkO)tihRszoi72HYHGKzuDPG(pHCSkLQhhqjw(1OUCrSXKVpQ6CGpt)tGk98aDb2abIGsdi9qIk57JQoh4Z0)eOsppqxW0XesSObKy0FGauj(geO17eYZei)LnqpXNoKKKcfoZiJya)ILC3oKzdwtmYigWVi28AFFu15aFM(Nav65b6cgKXXkNoKKGRoYKKrHXZ3GaLaeBR8IMftfr5qqYFzd0t8PdjjPqHZCq89y2BmKpH07sifqgWM3yyryqV3ihZBIxOkNsEZcWg59X8E5ieEJYHG8859G4nK7)bvqzVlvctr53BLv2B98EJuVvyYBXzIE176Dc5zc4nA8K07d4DGvmIavqEtaYyOp77JQoh4Z0)eOsppqxGrbKbSLqeHb98vlxfusd2gPpuS5BqGQbBJ0SogusVKCOfXoxYD7wFDnyBKMHPqOWzivLFEnM2Ttd2gPzykekCgsvxeAHyATIRhvDWIseGmg6HI9UDAW2inRJbL0ljhI)c5vwBTD7wxd2gPzDmOKEjivnviM4N3yQ46rvhSOebiJHEOyVBNgSnsZ6yqj9sYH43SMDT189(Em7ngEaZdtS33hvDoWNrgW8WqHCNiXO)4yvIpKJLaeVOqX23JzVlXXA(kXcL8goEVHNny6vVHWMJnAzVnnkS3MpBWkgI37vcb2OaujV5GK927sCEPsq05aEpV3LQRe3BzyeBK3MGjG34uTaQ698EZOqwo77JQoh4ZidyEyEGUaH18vIfkX3GafLdbjdMny9tyrGnkavkZbP46pesisAW2i9ZpmhBwsG0RhZyXc3TdRGnbQGYCpLGWMJnA5e70qNdSBhg1qqan)uLrAsPkmyk1CuMabQGK72HX6Dc5zcKFQYinPufgmLAokZbznFpM9Uemrq8MdI3MpBWkQiKK3dI3J698EhOhN6TEEZ4aEFCA27sFEdo1BUN828v9wYXgWM3LoavIpVheV1qqaLKEpa98U0bBP34WH8mL99rvNd8zKbmpmpqxamBWkQiKeFdc01XOgccOzzWwME4qEMYeiqfKC3omIYHGKF4qEMsYauPmhK1kQJbL0ljhYmyKrmGN)sPiJmIb8lQtDzshdcdwOVhZExcWj0rEQoGnVpo9hj5DPdqL8(aERbBJ03BfouVnncH3IblYBKJ5TctEl5yHohW7dXBZNnyfvesIpVzecJEyVLCSbS5nKaijJPM9UeGtOJ8uVJ3BXb28oEVlKhV1GTr67T88gCQ3WbwK3MpBWkQiKK3Cq820OWExcjiIPg6a28ghoKNP3715ac6FVlFCEdhyrEB(SbRyiEVxjeyJcqL8wVBTSVpQ6CGpJmG5H5b6cGzdwrfHK4RwUkOKgSnsFOyZ3GafJyfSjqfuM7Pee2CSrlNyNg6CGIpesisAW2i9ZpmhBwsG0RhZGFOfwC9yfeBukdMny9tyrGnkavktGavqYD7WyScInkLzeeXudDaBPhoKNPptGavqYD7EiKqK0GTr6NFyo2SKaPxpMHzevDWIsYtZGzdwrfHK4hAHRveJOCii5hoKNPKmavkZbPOogusVKCi(HUEj5z9cXG1Za9sqUbO)ARvKrim6Hdub57XS3LqcHrpS3MpBWkQiKK3uWeL9Eq8EuVnncH3eVazyK3so2a28gVSb6j(S3L(8wHd1BgHWOh27bXB8R0EVr67nJczzVhG3km5nG4f17s(zFFu15aFgzaZdZd0faZgSIkcjX3GaLrgXa(fR3jKNjq(lBGEIpDijjfkCMrgXaEEWgtfR3jKNjq(lBGEIpDijjfkCMrgXa(fHwYI6yqj9sYHmdgzed45VENqEMa5VSb6j(0HKKuOWzgzed45PK((OQZb(mYaMhMhOl8uLrAsPkmyk1CKVpQ6CGpJmG5H5b6cewZxjwOKV33JzVXvkekS3M5Dc5zc8(Em7ngYKacX8ELeSjqfKVpQ6CGp)kfcfovLpuSc2eOcIpqyqqFyzsHz0dFcjFyfcocA9oH8mbYpCiptjzaQuUchSn6tiSOQZbcb)qXoVYlPVhZEVscW8WEZbe0)EBI8oyK3b6XPERN31aI3hW7shGk5DfoyB0N9Ueequ2BtWeWBm8aKEVsPyjG(3759oqpo1B98MXb8(40SVpQ6CGp)kfcfovLppqxaRampmFdcumIvWMavq5hwMuyg9WNqwSEgOxcYna9ZsczQJYp2fLekhcsgzaYKjkwcO)ZmYigWVi2fR3jKNjq(lBGEIpDijjfkCMrgXaE(HYBFpM9gdCNWBKJ5noCiptgKq6npEJdhYZ0RSzj5nhqq)7TjY7GrEhOhN6TEExdiEFaVlDaQK3v4GTrF27sqarzVnbtaVXWdq69kLILa6FVN37a94uV1ZBghW7JtZ((OQZb(8Ruiu4uv(8aDbi3jsm6powL4d5yjaXlkuS5J4fLfPW44akuZIjFFu15aF(vkekCQkFEGUWdhYZKbjK8niqjaX2kZpuZIPIeGyBLZsczQJYpuSXurmIvWMavq5hwMuyg9WNqwSEgOxcYna9ZsczQJYp2fLekhcsgzaYKjkwcO)ZmYigWVi2(Em7TzIb8MrLAUHrgeqxzEx6aujVd1BXzYBZed4nAzVLesWj0S3RJZHQSOQZb8EEVdVRhKYEJWodVvyY7xPqatsVrgW8WeZ7AieEJCmVladxAVHdGumGT8A((OQZb(8Ruiu4uv(8aDbSc2eOcIpqyqqFyzQEgOxcYna95dRqWrqRNb6LGCdq)SKqM6O8d1SMX6AiiGMLebHyPxzHgBKrMabQGKfxpwbXgLYkmLqg2RjzaQuMabQGKfXOgccOzzWwME4qEMYeiqfKSig1qqan)COkXq42Ombcubjl(qiHiPbBJ0p)WCSzjbsVEmJf59AR57XS3MjgWBgvQ5ggzqaDL5DPdqL8(aIYEJsihJ8gzaZdtS37bXBtK3WbwK3HbeV1qqa99oasVHWMJnAzVzNg6CGSVpQ6CGp)kfcfovLppqxaRGnbQG4dege0hwMQNb6LGCdqF(WkeCe06zGEji3a0pljKPo6IqXMNcXGXki2OuwHPeYWEnjdqLYeiqfKKVbbkwbBcubL5EkbHnhB0Yj2PHohO46AiiGMbZgS(AiwsSmbcubj3Ttdbb0SmyltpCiptzceOcsUMVhZEVshf27shSLEJdhYZK3hqu27shGk5Tjyc4T5ZgSIkcj5TPri8(1OS3CqYExIEYBjhBaBEJx2a9eV3hZ7a9WI8wHz0dFcz27vAmQ3ihZBZxjEJYHG4TPrH9UqEmFLK99rvNd85xPqOWPQ85b6cpCiptjzaQeFdcuSc2eOck)WYu9mqVeKBa6xCDmQHGaAwgSLPhoKNPmbcubj3TtEAgmBWkQiKuMrgXaE(HwsE0qqan)COkXq42OmbcubjxR46yfSjqfu(HLjfMrp8jK72HYHGK)YgON4thsssHcNzKrmGNFOyNlC3UhcjejnyBK(5hMJnljq61JzWpuZwSENqEMa5VSb6j(0HKKuOWzgzed45hBmTwX1JvqSrPmy2G1pHfb2OauPmlalxSWD7q5qqYGzdw)eweyJcqLYCqwZ3JzVxLJb8MrgXagWM3Loav69gLqog5TctERbBJuVLd9EpiEJFL2BthadH6nk5nJczzVhG36yqzFFu15aF(vkekCQkFEGUWdhYZusgGkX3GafRGnbQGYpSmvpd0lb5gG(f1XGs6LKdTy9oH8mbYFzd0t8PdjjPqHZmYigWxeJSyKjclcO5qk)mheFVVhZEJRuiuys6Dj80qNd47XS3yOiEJRuiu4fWkaZd7DWiV5GWN3Cp5noCiptVYMLK365nkbiKr9gHDgERWK3qI)hSiVrpa37DaKEJHhG07vkflb0)85nHfb8Eq82e5DWiVd1BJGx82mXaEVoc7m8wHjVHWO6zGgQ3LaiLETSVpQ6CGp)kfcfMKqF4qEMELnlj(geORRHGaAgzaYKjkwcO)ZeiqfKC3UhcjejnyBK(5hMJnljq61JzSiVxR46OCii5xPqOWzoi72HYHGKXkaZdN5GSMVhZEJHhW8WEhQ38MhVntmG3Mgf(4uVlnU3l4Tz5XBtJc7DPX920OWEJdZXMLeW7cogiKN3OCiiEZbXB98oW6gP3)zqEBMyaVnfVsE)JYf6CGp77JQoh4ZVsHqHjjpqxOgcrkQ6CGKyELpqyqqrgW8W8niqr5qqYpmhBwsGKEmqiVmhKI1Za9sqUbOFwsitD0fHwOVhZExQe)59hiK365nYaMh27q92S84TzIb820OWEt8suvrzVnR3AW2i9ZEVoEyqEhV3hN(JK8(vkekCEnFFu15aF(vkekmj5b6c1qisrvNdKeZR8bcdckYaMhMVbb6dHeIKgSns)8dZXMLei96XmGA2I1Za9sqUbOp)qnRVhZEJHhW8WEhQ3MLhVntmG3Mgf(4uVlnoFExsE820OWExAC(8oasVlfVnnkS3Lg37arjM3RKampS3hZ7cGjVXWd7vVlDaQK384T5ZgS(EVsOnkavY3hvDoWNFLcHctsEGUqneIuu15ajX8kFGWGGImG5H5BqGwpd0lb5gG(zjHm1rxek2MX6AiiGMLebHyPxzHgBKrMabQGKfxhLdbjJvaMhoZbz3UyfeBukRWuczyVMKbOszceOcsw8Hqcrsd2gPF(H5yZscKE9yglY7IOCiizWSbRFclcSrbOszoiRTMVhZExIEY7sSI7mqfHK8(WIyEJdhYZ0RSzj5DaKEJRhZWBtJc7DH84ngGyihluY7q9UqVpM3c6FV1GTr6N99rvNd85xPqOWKKhOlSjUZavesIVbbAScInkLHqmKJfkLzbyj)qlS4dHeIKgSns)8dZXMLei96XmweAH(Em7DPs9UqV1GTr67TPrH9gNQms9UaQcdMsnh59sIG4nheVXWdq69kLILa6FVrl7DTCvmGnVXHd5z6v2SKY((OQZb(8RuiuysYd0fE4qEMELnlj(QLRckPbBJ0hk28niq1qqan)uLrAsPkmyk1CuMabQGKf1qqanJmazYeflb0)zceOcswusOCiizKbitMOyjG(pZiJya)Iyx8Hqcrsd2gPF(H5yZscKE9ygqlSOogusVKCiZGrgXaE(lfFpM9ELok8XPExAIGqmVXvwOXgz4DaKEZBVlHby579H49QIqsEpaVvyYBC4qEMEVh175920XuyV5(bS5noCiptVYMLK3hWBE7TgSns)SVpQ6CGp)kfcfMK8aDHhoKNPxzZsIVbbkg1qqanljccXsVYcn2iJmbcubjlgRGyJszuriP0askmLE4qEM(mlalHY7IpesisAW2i9ZpmhBwsG0RhZakV99y2Bm8X8gcBo2OL9MDAOZb4ZBUN8ghoKNPxzZsY7dlI5nUEmdVXEnVnnkS3R0saVJTyaV6nheV1ZBZ6TgSnsF(8UW18Eq8gdVs9EEVzCaWa28(qq8E9d4Dak7DyCCa17dXBnyBK(RXN3hZBEVM365TrWlJXScYB8R0Et8IsGFoG3Mgf2BmuaH1Ob6igTS3hWBE7TgSnsFVx3SEBAuyVxDu81Y((OQZb(8RuiuysYd0fE4qEMELnlj(geOyfSjqfuM7Pee2CSrlNyNg6CGIRRHGaAgzaYKjkwcO)ZeiqfKSOKq5qqYidqMmrXsa9FMrgXa(fXE3oneeqZMOaYbmIxjwMabQGKfFiKqK0GTr6NFyo2SKaPxpMXIqn7UDXki2OuEaewJgOJy0YzceOcsweLdbj)LnqpXNoKKKcfoZbP4dHeIKgSns)8dZXMLei96XmwekV5jwbXgLYOIqsPbKuyk9WH8m9zceOcsUMVpQ6CGp)kfcfMK8aDHhMJnljq61JzW3Ga9Hqcrsd2gPp)q5TVpQ6CGp)kfcfMK8aDHhoKNPxzZsYQw1Ab]] )


end
