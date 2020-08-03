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


    spec:RegisterPack( "Subtlety", 20200802, [[daLCSbqiOipckQnjH(euOWOus1PusAvqH0RqvmluLUfff2LO(LePHbfCmuvwMe4zqPAAseDnjcBtjqFtjr14GsrNdkfSoLeL5Pe6EG0(qv1)GcfPdsrjwOskpKIIMOsqxujaTrOq1hvcGgjuOOojuO0kbrVKIsQMPsa4Muus2jfv)KIskdfkelLIs5Pq1uLGUkfLQTQKi(QsI0zHcfXEP0FfzWsDyHfdPhlPjt0Lr2meFwPmAqDAfRgkf61krZMWTPWUb(TkdxP64kb0Yr55QA6KUoQSDOKVtrgpukDEjQ1RKW8bH9t1w(SfAXLHswZladfGbmGnXqb5c4d7LOey3IRL3jl(EuxgBKfhegKfhNdvfKw2IVhLfxiTfAX)JJvjloSQ7)kR0s3gfMdnxpJs)XGte6CGklq0s)XOwQfhLBekglWIAXLHswZladfGbmGnXqb5c4d7LOefyXdof(ywC8XWmT4WJusalQfxsF1IJzVX5qvbPL92SDBCKdjM9gw19FLvAPBJcZHMRNrP)yWjcDoqLfiAP)yul1HeZEBw424E17c417cWqbyWH0HeZEBMWbyJ(vMdjM92m82SiLK0BZ6tDP365TKqcoH6Du15aElMxZoKy2BZWBZgzCyrsV1GTrAAq8UEa5OZb8(aEBwfSLK0BKJ59cPqHZoKy2BZWBZIussVn7p5ngRsgF2IlMxFBHw8xPqOWK0wO1C(SfAXjqGkiPDnlELnkXMWIVU3AiiGMrgGmzIILa6)mbcubj9gci8(3jHiPbBJ0p)WCSzjbsVEmdVx0BS79QEx0719gLdbj)kfcfoZT7neq4nkhcsgRampCMB37vT4rvNdyXF4qEMELnljRAnVaBHwCceOcsAxZIxzJsSjS4OCii5hMJnljqspgiKxMB37IExpd0lTFdq)SKqM6OEViuVlWIhvDoGfVgcrkQ6CGKyE1IlMxtGWGS4idyEyRAnh72cT4eiqfK0UMfVYgLytyX)DsisAW2i9ZpmhBwsG0RhZWBOExsVl6D9mqV0(na99MFOExslEu15aw8AiePOQZbsI5vlUyEnbcdYIJmG5HTQ18sAl0ItGavqs7Aw8kBuInHfVEgOxA)gG(zjHm1r9ErOEZN3MH3R7TgccOzjr7el9kl0yJmYeiqfK07IEVU3OCiizScW8WzUDVHacVJvqSrPSctjKH9AsgGkLjqGkiP3f9(3jHiPbBJ0p)WCSzjbsVEmdVx0BS7DrVr5qqYGzdw)eweyJcqLYC7EVQ3RAXJQohWIxdHifvDoqsmVAXfZRjqyqwCKbmpSvTMxcBHwCceOcsAxZIxzJsSjS4Xki2OuENyihlukZcWsV5hQ3f4DrV)DsisAW2i9ZpmhBwsG0RhZW7fH6Dbw8OQZbS4BI7mqfHKSQ18f0wOfNabQGK21S4rvNdyXF4qEMELnljlELnkXMWIRHGaA(PkJ0KsvyWSa5Ombcubj9UO3AiiGMrgGmzIILa6)mbcubj9UO3scLdbjJmazYeflb0)zgzed49ErV5Z7IE)7KqK0GTr6NFyo2SKaPxpMH3q9UaVl6TogusVKCiVndVzKrmG3B(9EbT41YvbL0GTr6BnNpRAnFLBl0ItGavqs7Aw8kBuInHfhtERHGaAws0oXsVYcn2iJmbcubj9UO3Xki2OugvesknGKctPhoKNPpZcWsVH6n29UO3)ojejnyBK(5hMJnljq61Jz4nuVXUfpQ6Cal(dhYZ0RSzjzvR5ytBHwCceOcsAxZIxzJsSjS4yfSjqfuM7P0oBo2OLtStdDoG3f9EDV1qqanJmazYeflb0)zceOcs6DrVLekhcsgzaYKjkwcO)ZmYigW79IEZN3qaH3AiiGMnrX(bmIxjwMabQGKEx07FNeIKgSns)8dZXMLei96Xm8ErOExsVHacVJvqSrP8aiSgnqhXOLZeiqfK07IEJYHGK)YgON4thsssHcN529UO3)ojejnyBK(5hMJnljq61Jz49Iq9g7EZJ3Xki2OugvesknGKctPhoKNPptGavqsVx1IhvDoGf)Hd5z6v2SKSQ1CSbBHwCceOcsAxZIxzJsSjS4)ojejnyBK(EZpuVXUfpQ6Cal(dZXMLei96XmSQ1C(WGTqlEu15aw8hoKNPxzZsYItGavqs7Aw1QwC6FcuP3wO1C(SfAXjqGkiPDnlELnkXMWItaITvoRJbL0lzeyR387nFEx0Bm5nkhcs(lBGEIpDijjfkCMB37IEVU3yYB5P56bQeqzHsYeIimOekhdK1PUCaBEx0Bm5Du15a56bQeqzHsYeIimO8asiIzdw9gci8gHtismQchSnkPJb59IEVvLzJaB9EvlEu15aw86bQeqzHsYeIimiRAnVaBHwCceOcsAxZIxzJsSjS4yY76Dc5zcKF4qEMsOIqsFMB37IExVtiptG8x2a9eF6qssku4m3U3qaH3iZgSMyKrmG37fH6nFyWIhvDoGfhvCNmDijfMseGmkBvR5y3wOfpQ6Cal(gxWKtashskwbXof2ItGavqs7Aw1AEjTfAXjqGkiPDnlELnkXMWIVU3)ojejnyBK(5hMJnljq61Jz4n)q9UaVHacVzXiteweqZHu(5b4n)EVGyW7v9UO3yY76Dc5zcK)YgON4thsssHcN529UO3yYBuoeK8x2a9eF6qssku4m3U3f9MaeBRCwsitDuV5hQ3yhdw8OQZbS4ixL7jzkwbXgLsOuyyvR5LWwOfNabQGK21S4v2OeBcl(Vtcrsd2gPF(H5yZscKE9ygEZpuVlWBiGWBwmYeHfb0CiLFEaEZV3ligS4rvNdyX35yds5bSLqfXRw1A(cAl0ItGavqs7Aw8kBuInHfhLdbjZO6sb9Fc5yvkZT7neq4nkhcsMr1Lc6)eYXQuQECaLy5xJ6sVx0B(WGfpQ6CalUctjoa6XbKjKJvjRAnFLBl0IhvDoGfNn77cknG0VhvYItGavqs7Aw1Ao20wOfNabQGK21S4v2OeBclE9oH8mbYFzd0t8PdjjPqHZmYigW79IExcVHacVrMnynXiJyaV3l6nFytlEu15awCthtiXIgqIr)bcqLSQ1CSbBHwCceOcsAxZIxzJsSjS4eGyBL9ErVljg8UO3OCii5VSb6j(0HKKuOWzUDlEu15awCdY4yLthssWvhzsYOW4TQ1C(WGTqlobcubjTRzXRSrj2ewCnyBKM1XGs6LKd59IEZxUeEdbeEVU3R7TgSnsZWuiu48Ev9MFVXMyWBiGWBnyBKMHPqOW59Q69Iq9Uam49QEx0719oQ6GfLiazm07nuV5ZBiGWBnyBKM1XGs6LKd5n)Exa2G3R69QEdbeEVU3AW2inRJbL0lTx1ubyWB(9g7yW7IEVU3rvhSOebiJHEVH6nFEdbeERbBJ0SogusVKCiV537swsVx17vT4rvNdyXzuSpGTeIimO3Qw1IljKGtO2cTMZNTqlobcubjTRzXRSrj2ewCm59RuiuysMz3ghzXJQohWIVCQlTQ18cSfAXJQohWI)kfcf2ItGavqs7Aw1Ao2TfAXjqGkiPDnlEu15aw8AiePOQZbsI5vlUyEnbcdYIxLVvTMxsBHwCceOcsAxZIxzJsSjS4VsHqHjzoeclEu15awCghifvDoqsmVAXfZRjqyqw8xPqOWK0QwZlHTqlobcubjTRzXRSrj2ewCDmOKEj5qEZV3lO3f9MrgXaEVx07TQmBeyR3f9UEgOxA)gG(EZpuVlP3MH3R7TogK3l6nFyW7v9gJ6Dbw8OQZbS4GzdwrfHKSQ18f0wOfNabQGK21S43Uf)j1IhvDoGfhRGnbQGS4yfcoYIVZMJnA5e70qNd4DrV)DsisAW2i9ZpmhBwsG0RhZWB(H6DbwCScwcegKfN7P0oBo2OLtStdDoGvTMVYTfAXjqGkiPDnlELnkXMWIJvWMavqzUNs7S5yJwoXon05aw8OQZbS41qisrvNdKeZRwCX8AcegKf)vkekCQkFRAnhBAl0ItGavqs7Aw8B3I)KAXJQohWIJvWMavqwCScbhzXlOeEZJ3AiiGMXA2owMabQGKEJr9g7LWBE8wdbb0Sr8kXshs6Hd5z6ZeiqfK0BmQ3fucV5XBneeqZpCiptjKRY9zceOcs6ng17cWG384TgccO5qev2OLZeiqfK0BmQ38HbV5XB(kH3yuVx37FNeIKgSns)8dZXMLei96Xm8MFOEJDVx1IJvWsGWGS4VsHqHtkmJE4tiTQ1CSbBHwCceOcsAxZIxzJsSjS4eGyBLZsczQJ69Iq9gRGnbQGYVsHqHtkmJE4tiT4rvNdyXRHqKIQohijMxT4I51eimil(Ruiu4uv(w1AoFyWwOfNabQGK21S4v2OeBclEScInkLbZgS(jSiWgfGkLjqGkiP3f9gtEJYHGKbZgS(jSiWgfGkL529UO31Za9s73a0pljKPoQ387nFEx0719(3jHiPbBJ0p)WCSzjbsVEmdVx07c8gci8gRGnbQGYCpL2zZXgTCIDAOZb8EvVl696ExVtiptG8x2a9eF6qssku4mJmIb8EViuVXU3qaH3R7DScInkLbZgS(jSiWgfGkLzbyP38d17c8UO3OCii5VSb6j(0HKKuOWzgzed49MFVXU3f9gtE)kfcfMK5qi8UO317eYZei)WH8mLKbOs5kCW2OpHWIQohieEZpuVXqgBW7v9EvlEu15awCWSbROIqsw1AoF8zl0ItGavqs7Aw8kBuInHfVEgOxA)gG(zjHm1r9ErOEZN3qaH36yqj9sYH8ErOEZN3f9UEgOxA)gG(EZpuVXUfpQ6CalEneIuu15ajX8QfxmVMaHbzXrgW8Ww1AoFfyl0ItGavqs7Aw8kBuInHf)3jHiPbBJ0p)WCSzjbsVEmdVH6Dj9UO31Za9s73a03B(H6DjT4rvNdyXRHqKIQohijMxT4I51eimiloYaMh2QwZ5d72cT4eiqfK0UMfVYgLytyXjaX2kNLeYuh17fH6nwbBcubLFLcHcNuyg9WNqAXJQohWIxdHifvDoqsmVAXfZRjqyqwCuUriTQ1C(kPTqlobcubjTRzXRSrj2ewCcqSTYzjHm1r9MFOEZxj8MhVjaX2kNz0gbS4rvNdyXdwnauspgJaQvTMZxjSfAXJQohWIhSAaO0oN4jlobcubjTRzvR58TG2cT4rvNdyXfZgS(jSro5MbbulobcubjTRzvR58TYTfAXJQohWIJgBPdjPSPU8T4eiqfK0UMvTQfFNr1ZanuBHwZ5ZwOfpQ6Cal(RuiuylobcubjTRzvR5fyl0ItGavqs7Aw8OQZbS4gbBjjtihljPqHT47mQEgOHMEQEa5BX5Rew1Ao2TfAXjqGkiPDnloimilESIhoyXNqoGMoK0(zIyw8OQZbS4XkE4GfFc5aA6qs7NjIzvR5L0wOfpQ6Cal((PZbS4eiqfK0UMvTQfhzaZdBl0AoF2cT4eiqfK0UMfh5yjaHTQ1C(S4rvNdyX3VtKy0FCSkzvR5fyl0ItGavqs7Aw8kBuInHfhLdbjdMny9tyrGnkavkZT7DrVx37FNeIKgSns)8dZXMLei96Xm8ErVlWBiGWBSc2eOckZ9uANnhB0Yj2PHohWBiGWBm5TgccO5NQmstkvHbZcKJYeiqfK0BiGWBm5D9oH8mbYpvzKMuQcdMfihL529EvlEu15awCcR5ReluYQwZXUTqlobcubjTRzXRSrj2ew819gtERHGaAwgSLPhoKNPmbcubj9gci8gtEJYHGKF4qEMsYauPm3U3R6DrV1XGs6LKd5Tz4nJmIb8EZV3lO3f9MrgXaEVx0BDQlt6yqEJr9UalEu15awCWSbROIqsw1AEjTfAXjqGkiPDnlEu15awCWSbROIqsw8kBuInHfhtEJvWMavqzUNs7S5yJwoXon05aEx07FNeIKgSns)8dZXMLei96Xm8MFOExG3f9EDVJvqSrPmy2G1pHfb2OauPmbcubj9gci8gtEhRGyJszgTlMAOdyl9WH8m9zceOcs6neq49Vtcrsd2gPF(H5yZscKE9ygEBgEhvDWIsYtZGzdwrfHK8MFOExG3R6DrVXK3OCii5hoKNPKmavkZT7DrV1XGs6LKd5n)q9EDVlH38496ExG3yuVRNb6L2VbOV3R69QEx0BgHWOhoqfKfVwUkOKgSnsFR58zvR5LWwOfNabQGK21S4v2OeBcloJmIb8EVO317eYZei)LnqpXNoKKKcfoZiJyaV384nFyW7IExVtiptG8x2a9eF6qssku4mJmIb8EViuVlH3f9whdkPxsoK3MH3mYigW7n)ExVtiptG8x2a9eF6qssku4mJmIb8EZJ3LWIhvDoGfhmBWkQiKKvTMVG2cT4rvNdyXFQYinPufgmlqoYItGavqs7Aw1A(k3wOfpQ6CaloH18vIfkzXjqGkiPDnRAvlEv(2cTMZNTqlobcubjTRzXRSrj2ewCm5nkhcs(Hd5zkjdqLYC7Ex0BuoeK8dZXMLeiPhdeYlZT7DrVr5qqYpmhBwsGKEmqiVmJmIb8EViuVXEUew8OQZbS4pCiptjzaQKfN7P0HGK2QsR58zvR5fyl0ItGavqs7Aw8kBuInHfhLdbj)WCSzjbs6XaH8YC7Ex0BuoeK8dZXMLeiPhdeYlZiJyaV3lc1BSNlHfpQ6Cal(x2a9eF6qsskuylo3tPdbjTvLwZ5ZQwZXUTqlobcubjTRzXRSrj2ewCm59RuiuysMdHW7IElpndMnyfveskRtD5a28gci8M(NavkJYOqHthssHPKS8a2Ygb24X8UO36yqEZpuVlWIhvDoGfVgcrkQ6CGKyE1IlMxtGWGS40)eOsVvTMxsBHwCceOcsAxZIhvDoGfF)orIr)XXQKfVYgLytyXXK3AiiGMF4qEMsixL7ZeiqfK0IJCSeGWw1AoFw1AEjSfAXjqGkiPDnlELnkXMWItaITv2B(H69cIbVl6T80my2GvuriPSo1LdyZ7IExVtiptG8x2a9eF6qssku4m3U3f9UENqEMa5hoKNPKmavkxHd2g9EZpuV5ZIhvDoGf)H5yZscK0Jbc5zvR5lOTqlobcubjTRzXRSrj2ewC5PzWSbROIqszDQlhWM3f9gtExVtiptG8dhYZucves6ZC7Ex0719gtERHGaA(H5yZscK0Jbc5LjqGkiP3qaH3AiiGMF4qEMsixL7ZeiqfK0BiGW76Dc5zcKFyo2SKaj9yGqEzgzed49MFVlW7v9UO3R7nM8M(NavkJkUtMoKKctjcqgLZgb24X8gci8UENqEMazuXDY0HKuykraYOCMrgXaEV537c8EvVl696EhRGyJszWSbRFclcSrbOszwaw69IExG3qaH3OCiizWSbRFclcSrbOszUDVx1IhvDoGf)lBGEIpDijjfkSvTMVYTfAXjqGkiPDnlEu15awCJGTKKjKJLKuOWw8kBuInHfNfJmryranhs5N529UO3R7TgSnsZ6yqj9sYH8ErVRNb6L2VbOFwsitDuVHacVXK3VsHqHjzoecVl6D9mqV0(na9ZsczQJ6n)q9UUNmcSn97eq69Qw8A5QGsAW2i9TMZNvTMJnTfAXjqGkiPDnlELnkXMWIZIrMiSiGMdP8ZdWB(9g7yWBZWBwmYeHfb0CiLFwYXcDoG3f9gtE)kfcfMK5qi8UO31Za9s73a0pljKPoQ38d176EYiW20VtaPfpQ6CalUrWwsYeYXsskuyRAnhBWwOfNabQGK21S4v2OeBcloM8(vkekmjZHq4DrVLNMbZgSIkcjL1PUCaBEx076zGEP9Ba6NLeYuh1B(H6Dbw8OQZbS4pCiptjuriP3QwZ5dd2cT4eiqfK0UMfVYgLytyX1qqan)WH8mLqUk3NjqGkiP3f9wEAgmBWkQiKuwN6YbS5DrVr5qqYFzd0t8PdjjPqHZC7w8OQZbS4pmhBwsGKEmqipRAnNp(SfAXjqGkiPDnlELnkXMWIJjVr5qqYpCiptjzaQuMB37IERJbL0ljhY7fH6Dj8MhV1qqan)COkXq42Ombcubj9UO3yYBwmYeHfb0CiLFMB3IhvDoGf)Hd5zkjdqLSQ1C(kWwOfNabQGK21S4v2OeBclokhcsgvCNuW9AMrrv9gci8gLdbj)LnqpXNoKKKcfoZT7DrVx3BuoeK8dhYZucves6ZC7EdbeExVtiptG8dhYZucves6ZmYigW79Iq9Mpm49Qw8OQZbS47NohWQwZ5d72cT4eiqfK0UMfVYgLytyXr5qqYFzd0t8PdjjPqHZC7w8OQZbS4OI7KjeowzRAnNVsAl0ItGavqs7Aw8kBuInHfhLdbj)LnqpXNoKKKcfoZTBXJQohWIJsSNylhWMvTMZxjSfAXjqGkiPDnlELnkXMWIJYHGK)YgON4thsssHcN52T4rvNdyXrggHkUtAvR58TG2cT4eiqfK0UMfVYgLytyXr5qqYFzd0t8PdjjPqHZC7w8OQZbS4bOsVYcrQgcHvTMZ3k3wOfNabQGK21S4rvNdyXRLRItzhyQjur8QfVYgLytyXXK3VsHqHjzoecVl6T80my2GvuriPSo1LdyZ7IEJjVr5qqYFzd0t8PdjjPqHZC7Ex0BcqSTYzjHm1r9MFOEJDmyXjeeQQjqyqw8A5Q4u2bMAcveVAvR58HnTfAXjqGkiPDnlEu15aw8yfpCWIpHCanDiP9ZeXS4v2OeBcloM8gLdbj)WH8mLKbOszUDVl6D9oH8mbYFzd0t8PdjjPqHZmYigW79IEZhgS4GWGS4XkE4GfFc5aA6qs7NjIzvR58Hnyl0ItGavqs7Aw8OQZbS4XdJvaOpXIvCSu9yHWIxzJsSjS4scLdbjZIvCSu9yHijjuoeKS8mb8gci8wsOCii56bKCvDWIsdyzssOCiizUDVl6TgSnsZWuiu48Ev9ErVXEbEx0BnyBKMHPqOW59Q6n)q9g7yWBiGWBm5TKq5qqY1di5Q6GfLgWYKKq5qqYC7Ex0719wsOCiizwSIJLQhlejjHYHGKFnQl9MFOExqj82m8Mpm4ng1BjHYHGKrf3jthssHPebiJYzUDVHacVrMnynXiJyaV3l6DjXG3R6DrVr5qqYFzd0t8PdjjPqHZmYigW7n)EJnT4GWGS4XdJvaOpXIvCSu9yHWQwZlad2cT4eiqfK0UMfhegKf3OSm(KgI5ncGfpQ6CalUrzz8jneZBeaRAnVa(SfAXjqGkiPDnlELnkXMWIJYHGK)YgON4thsssHcN529gci8gz2G1eJmIb8EVO3fGblEu15awCUNsJsgVvTQf)vkekCQkFBHwZ5ZwOfNabQGK21S43Uf)j1IhvDoGfhRGnbQGS4yfcoYIxVtiptG8dhYZusgGkLRWbBJ(eclQ6CGq4n)q9MV8kVewCScwcegKf)HLjfMrp8jKw1AEb2cT4eiqfK0UMfVYgLytyXXK3yfSjqfu(HLjfMrp8jKEx076zGEP9Ba6NLeYuh1B(9MpVl6TKq5qqYidqMmrXsa9FMrgXaEVx0B(8UO317eYZei)LnqpXNoKKKcfoZiJyaV38d1BSBXJQohWIJvaMh2QwZXUTqlobcubjTRzXJQohWIVFNiXO)4yvYItyRYIuyCCa1IxsmyXrowcqyRAnNpRAnVK2cT4eiqfK0UMfVYgLytyXjaX2k7n)q9UKyW7IEtaITvoljKPoQ38d1B(WG3f9gtEJvWMavq5hwMuyg9WNq6DrVRNb6L2VbOFwsitDuV53B(8UO3scLdbjJmazYeflb0)zgzed49ErV5ZIhvDoGf)Hd5zYGesRAnVe2cT4eiqfK0UMf)2T4pPw8OQZbS4yfSjqfKfhRqWrw86zGEP9Ba6NLeYuh1B(H6Dj92m8EDV1qqanljANyPxzHgBKrMabQGKEx0719owbXgLYkmLqg2RjzaQuMabQGKEx0Bm5TgccOzzWwME4qEMYeiqfK07IEJjV1qqan)COkXq42Ombcubj9UO3)ojejnyBK(5hMJnljq61Jz49IEJDVx17vT4yfSeimil(dlt1Za9s73a03QwZxqBHwCceOcsAxZIF7w8NulEu15awCSc2eOcYIJvi4ilE9mqV0(na9ZsczQJ69Iq9MpV5X7c8gJ6DScInkLvykHmSxtYauPmbcubjT4v2OeBclowbBcubL5EkTZMJnA5e70qNd4DrVx3BneeqZGzdwFneljwMabQGKEdbeERHGaAwgSLPhoKNPmbcubj9EvlowblbcdYI)WYu9mqV0(na9TQ18vUTqlobcubjTRzXRSrj2ewCSc2eOck)WYu9mqV0(na99UO3R7nM8wdbb0SmyltpCiptzceOcs6neq4T80my2GvuriPmJmIb8EZpuVlH384TgccO5Ndvjgc3gLjqGkiP3R6DrVx3BSc2eOck)WYKcZOh(esVHacVr5qqYFzd0t8PdjjPqHZmYigW7n)q9MVCbEdbeE)7KqK0GTr6NFyo2SKaPxpMH38d17s6DrVR3jKNjq(lBGEIpDijjfkCMrgXaEV53B(WG3R6DrVx37yfeBukdMny9tyrGnkavkZcWsVx07c8gci8gLdbjdMny9tyrGnkavkZT79Qw8OQZbS4pCiptjzaQKvTMJnTfAXjqGkiPDnlELnkXMWIJvWMavq5hwMQNb6L2VbOV3f9whdkPxsoK3l6D9oH8mbYFzd0t8PdjjPqHZmYigW7DrVXK3SyKjclcO5qk)m3UfpQ6Cal(dhYZusgGkzvRAXr5gH0wO1C(SfAXjqGkiPDnlELnkXMWI)7KqK0GTr67n)q9UaV5X719wdbb08M4oduriPmbcubj9UO3Xki2OuENyihlukZcWsV5hQ3f49Qw8OQZbS4pmhBwsG0RhZWQwZlWwOfpQ6Cal(M4odurijlobcubjTRzvR5y3wOfpQ6CaloAux(AGAXjqGkiPDnRAvRAXXIy)CaR5fGHcWagwq(kPf3uWady7T4ySg7htjP3ytVJQohWBX86NDiT4)ovTMxWcYNfFNDiJGS4y2BCouvqAzVnB3gh5qIzVHvD)xzLw62OWCO56zu6pgCIqNduzbIw6pg1sDiXS3MfUnUx9UaE9UamuagCiDiXS3MjCa2OFL5qIzVndVnlsjj92S(ux6TEEljKGtOEhvDoG3I51SdjM92m82SrghwK0BnyBKMgeVRhqo6CaVpG3MvbBjj9g5yEVqku4SdjM92m82SiLK0BZ(tEJXQKXNDiDiXS3lGylv5us6nkHCmY76zGgQ3O02a(S3MLAL213BWbmd4GzGWj8oQ6CG37dikNDiXS3rvNd85Dgvpd0qHIiIFPdjM9oQ6CGpVZO6zGgkpqln42miGg6Cahsm7Du15aFENr1ZanuEGwkYDshsm7noi2F4t9MfJ0Buoees69RH(EJsihJ8UEgOH6nkTnG37ai9ENrMX(P6a28EEVLhGYoKy27OQZb(8oJQNbAO8aT0he7p8PPxd9DiJQoh4Z7mQEgOHYd0sFLcHc7qgvDoWN3zu9mqdLhOLAeSLKmHCSKKcfM3Dgvpd0qtpvpG8HYxjCiJQoh4Z7mQEgOHYd0s5EknkzWlimiOXkE4GfFc5aA6qs7NjI5qgvDoWN3zu9mqdLhOLUF6Cahshsm79ci2svoLKEtyrSYERJb5TctEhv9yEpV3bwXicubLDiXS3Mn6vkekS3dI373)dQG8EDW5nwCcaXcub5nbiJHEVhG31Zan0vDiJQoh4HUCQl5DqGIPxPqOWKmZUnoYHmQ6CGNhOL(kfcf2HeZEBMWuDP3M5cFVd1BKH9Qdzu15appqlTgcrkQ6CGKyELxqyqqRY3HeZEB24aEJWjeL9(nnAfMEV1ZBfM8gxPqOWK0BZ2PHohW71rl7T8gWM3)XR3J6nYXQ079(DIbS59G4n4u4bS598EhyfJiqf0QzhYOQZbEEGwkJdKIQohijMx5fege0xPqOWKK3bb6RuiuysMdHWHeZEBw23fL928zdwrfHK8ouVlGhVntmI3so2a28wHjVrg2REZhg8(P6bKpVEhikX8wHd17sYJ3MjgX7bX7r9MW29HrV3MgfEaERWK3acBvVxaAMl07J598Edo1BUDhYOQZbEEGwky2GvurijEheO6yqj9sYH4FblYiJya)IBvz2iW2I1Za9s73a0NFOL0mwxhdAr(WWQy0cCiXS3M1aIYExHdWg5n70qNd49G4TjYB4alY7D2CSrlNyNg6CaVFs9oasVn4e6SliV1GTr67n3E2HmQ6CGNhOLIvWMavq8ccdck3tPD2CSrlNyNg6CaEXkeCe0D2CSrlNyNg6CGI)ojejnyBK(5hMJnljq61JzWp0cCiXS3ye2CSrl7Tz70qNdGXuVxaqkgJ37TblY7W7kl29oqpo1BcqSTYEJCmVvyY7xPqOWEBMl89EDuUrijM3VocH3m63PQ69ORM9gJjC7869OExdG3OK3kCOE)JXUGYoKrvNd88aT0AiePOQZbsI5vEbHbb9vkekCQkFEheOyfSjqfuM7P0oBo2OLtStdDoGdjM92S)K0B98wsidG82emb8wpV5EY7xPqOWEBMl89(yEJYncjXEhYOQZbEEGwkwbBcubXlimiOVsHqHtkmJE4ti5fRqWrqlOe8OHGaAgRz7yzceOcsIrXEj4rdbb0Sr8kXshs6Hd5z6ZeiqfKeJwqj4rdbb08dhYZuc5QCFMabQGKy0cWapAiiGMdruzJwotGavqsmkFyGh(kbgD9FNeIKgSns)8dZXMLei96Xm4hk2x1HeZEBMh4hjX8M7hWM3H34kfcf2BZCHEBcMaEZOOcpGnVvyYBcqSTYERWm6HpH0HmQ6CGNhOLwdHifvDoqsmVYlimiOVsHqHtv5Z7GaLaeBRCwsitD0fHIvWMavq5xPqOWjfMrp8jKoKy2BZNnyfJX79kHaBuaQ0kZBZNnyfvesYBuc5yK34LnqpX7DOElotEBMyeV1Z76zGoaYBkyIYEZieg9WEBAuyV3ivhWM3km5nkhcI3C7zVnlI)8wCM82mXiEl5ydyZB8YgON49gLuteb8EHbOsV3Mgf27c4XBZxjzhYOQZbEEGwky2GvurijEheOXki2OugmBW6NWIaBuaQuMabQGKfXekhcsgmBW6NWIaBuaQuMBVy9mqV0(na9ZsczQJYpFfx)3jHiPbBJ0p)WCSzjbsVEmJflaciWkytGkOm3tPD2CSrlNyNg6CGvlUE9oH8mbYFzd0t8PdjjPqHZmYigWViuSdbeRhRGyJszWSbRFclcSrbOszwawYp0ckIYHGK)YgON4thsssHcNzKrmGNFSxetVsHqHjzoeII17eYZei)WH8mLKbOs5kCW2OpHWIQohie8dfdzSHvx1HeZEJXhW8WEhQ3LKhVnnk8XPEVqCE9Ue84TPrH9EH4EV(XP)ijVFLcHcVQdzu15appqlTgcrkQ6CGKyELxqyqqrgW8W8oiqRNb6L2VbOFwsitD0fHYheqOJbL0ljhArO8vSEgOxA)gG(8df7oKy27v6OWEVqCVdXFEJmG5H9ouVljpEhBXaE1BcBJQkk7Dj9wd2gPV3RFC6psY7xPqOWR6qgvDoWZd0sRHqKIQohijMx5fegeuKbmpmVdc0FNeIKgSns)8dZXMLei96XmGwYI1Za9s73a0NFOL0HeZEB2FY7WBuUrijM3MGjG3mkQWdyZBfM8MaeBRS3kmJE4tiDiJQoh45bAP1qisrvNdKeZR8ccdckk3iK8oiqjaX2kNLeYuhDrOyfSjqfu(vkekCsHz0dFcPdjM9EbWzIE17D2CSrl79a8oecVpeVvyYBZcgzbG3Oun4EY7r9UgCp9EhEVa0mxOdzu15appqlny1aqj9ymcO8oiqjaX2kNLeYuhLFO8vcEiaX2kNz0gbCiJQoh45bAPbRgakTZjEYHmQ6CGNhOLkMny9tyJCYndcOoKrvNd88aTu0ylDijLn1LVdPdjM9EnUrij27qgvDoWNr5gHe6dZXMLei96Xm4DqG(7KqK0GTr6Zp0c4zDneeqZBI7mqfHKYeiqfKSyScInkL3jgYXcLYSaSKFOfSQdzu15aFgLBesEGw6M4odurijhYOQZb(mk3iK8aTu0OU81a1H0HeZEBM3jKNjW7qIzVn7p59cdqL8(qqmJTQ0Buc5yK3km5nYWE1BCyo2SKaEJRhZWBe2z4DHhdeYZ76zqV3di7qgvDoWNRYh6dhYZusgGkXl3tPdbjTvLq5J3bbkMq5qqYpCiptjzaQuMBVikhcs(H5yZscK0Jbc5L52lIYHGKFyo2SKaj9yGqEzgzed4xek2ZLWHeZEVUzhiO)9oemkKL9MB3BuQgCp5TjYB9ULEJdhYZK3y8RY9R6n3tEJx2a9eV3hcIzSvLEJsihJ8wHjVrg2REJdZXMLeWBC9ygEJWodVl8yGqEExpd69EazhYOQZb(Cv(8aT0VSb6j(0HKKuOW8Y9u6qqsBvju(4DqGIYHGKFyo2SKaj9yGqEzU9IOCii5hMJnljqspgiKxMrgXa(fHI9CjCiJQoh4Zv5Zd0sRHqKIQohijMx5fegeu6FcuPN3bbkMELcHctYCiefLNMbZgSIkcjL1PUCaBqab9pbQugLrHcNoKKctjz5bSLncSXJvuhdIFOf4qIzVXi3j8g5yEx4XaH88ENrMb(TqVnnkS34Wl0BgfYYEBcMaEdo1BghamGnVXX4zhYOQZb(Cv(8aT097ejg9hhRs8ICSeGWwfkF8oiqXKgccO5hoKNPeYv5(mbcubjDiXS3M9N8UWJbc559oJ8g)wO3MGjG3MiVHdSiVvyYBcqSTYEBcMuyI5nc7m8E)oXa2820OWhN6nog37J5n2i3REVraIfcr5Sdzu15aFUkFEGw6dZXMLeiPhdeYJ3bbkbi2wz(HUGyOO80my2GvuriPSo1LdyRy9oH8mbYFzd0t8PdjjPqHZC7fR3jKNjq(Hd5zkjdqLYv4GTrp)q5ZHeZEB2FYB8YgON49(aExVtiptaVxpquI5nYWE1BZNnyfvesAvV5ac6FVnrEhmY7TBaBERN373U3fEmqipVdG0B55n4uVHdSiVXHd5zYBm(v5(Sdzu15aFUkFEGw6x2a9eF6qsskuyEheOYtZGzdwrfHKY6uxoGTIyQENqEMa5hoKNPeQiK0N52lUoM0qqan)WCSzjbs6XaH8YeiqfKeci0qqan)WH8mLqUk3NjqGkijequVtiptG8dZXMLeiPhdeYlZiJyap)fSAX1Xe9pbQugvCNmDijfMseGmkNncSXJbbe17eYZeiJkUtMoKKctjcqgLZmYigWZFbRwC9yfeBukdMny9tyrGnkavkZcWYflaciq5qqYGzdw)eweyJcqLYC7R6qIzVXyr8oKY37GrEZTZR3py2jVvyY7dqEBAuyVfNj6vVlSWfM92S)K3MGjG3YYdyZBK4vI5TchaVntmI3sczQJ69X8gCQ3VsHqHjP3Mgf(4uVdqzVntms2HmQ6CGpxLppql1iyljzc5yjjfkmV1YvbL0GTr6dLpEheOSyKjclcO5qk)m3EX11GTrAwhdkPxso0I1Za9s73a0pljKPokeqGPxPqOWKmhcrX6zGEP9Ba6NLeYuhLFO19KrGTPFNaYvDiXS3ySiEdoVdP8920ieElhYBtJcpaVvyYBaHTQ3yhdpVEZ9K3Mvil07d4n69V3Mgf(4uVdqzVntmI3bq6n48(vkekC2HmQ6CGpxLppql1iyljzc5yjjfkmVdcuwmYeHfb0CiLFEa8JDmygSyKjclcO5qk)SKJf6CGIy6vkekmjZHquSEgOxA)gG(zjHm1r5hADpzeyB63jG0HmQ6CGpxLppql9Hd5zkHkcj98oiqX0RuiuysMdHOO80my2GvuriPSo1LdyRy9mqV0(na9ZsczQJYp0cCiXS3R0rH9ghJZR3dI3Gt9oemkKL9wEaIxV5EY7cpgiKN3Mgf2B8BHEZTNDiJQoh4Zv5Zd0sFyo2SKaj9yGqE8oiq1qqan)WH8mLqUk3NjqGkizr5PzWSbROIqszDQlhWwruoeK8x2a9eF6qssku4m3Udzu15aFUkFEGw6dhYZusgGkX7GaftOCii5hoKNPKmavkZTxuhdkPxso0IqlbpAiiGMFouLyiCBuMabQGKfXelgzIWIaAoKYpZT7qgvDoWNRYNhOLUF6CaEheOOCiizuXDsb3Rzgfvfciq5qqYFzd0t8PdjjPqHZC7fxhLdbj)WH8mLqfHK(m3oequVtiptG8dhYZucves6ZmYigWViu(WWQoKrvNd85Q85bAPOI7KjeowzEheOOCii5VSb6j(0HKKuOWzUDhYOQZb(Cv(8aTuuI9eB5a24DqGIYHGK)YgON4thsssHcN52DiJQoh4Zv5Zd0srggHkUtY7GafLdbj)LnqpXNoKKKcfoZT7qgvDoWNRYNhOLgGk9klePAie8oiqr5qqYFzd0t8PdjjPqHZC7oKrvNd85Q85bAPCpLgLm4LqqOQMaHbbTwUkoLDGPMqfXR8oiqX0RuiuysMdHOO80my2GvuriPSo1LdyRiMq5qqYFzd0t8PdjjPqHZC7fjaX2kNLeYuhLFOyhdoKrvNd85Q85bAPCpLgLm4fege0yfpCWIpHCanDiP9ZeX4DqGIjuoeK8dhYZusgGkL52lwVtiptG8x2a9eF6qssku4mJmIb8lYhgCiXS3ReIv2B2XTblk7nJtqEFiERWCgOdYqsVncf(9gLeNPvM3M9N8g5yEJXcwUFsVRSr517tHjMP5jVnnkS343c9ouVlOe849RrD579X8MVsWJ3Mgf27q8N3RjUt6n3E2HmQ6CGpxLppqlL7P0OKbVGWGGgpmwbG(elwXXs1JfcEheOscLdbjZIvCSu9yHijjuoeKS8mbGacjHYHGKRhqYv1blknGLjjHYHGK52lQbBJ0mmfcfoVx1fXEbf1GTrAgMcHcN3Rk)qXogGacmjjuoeKC9asUQoyrPbSmjjuoeKm3EX1LekhcsMfR4yP6XcrssOCii5xJ6s(Hwqjmd(WagvsOCiizuXDY0HKuykraYOCMBhciqMnynXiJya)ILedRweLdbj)LnqpXNoKKKcfoZiJyap)ythYOQZb(Cv(8aTuUNsJsg8ccdcQrzz8jneZBeahsm79cjKGtOEJecbAux6nYX8M7dub59OKXVY82S)K3Mgf2B8YgON49(q8EHuOWzhYOQZb(Cv(8aTuUNsJsgpVdcuuoeK8x2a9eF6qssku4m3oeqGmBWAIrgXa(fladoKoKy27fW)jqLEhYOQZb(m9pbQ0dTEGkbuwOKmHicdI3bbkbi2w5SogusVKrGT8ZxrmHYHGK)YgON4thsssHcN52lUoMKNMRhOsaLfkjtiIWGsOCmqwN6YbSvetrvNdKRhOsaLfkjtiIWGYdiHiMnyfciq4eIeJQWbBJs6yqlUvLzJaBx1HmQ6CGpt)tGk98aTuuXDY0HKuykraYOmVdcumvVtiptG8dhYZucves6ZC7fR3jKNjq(lBGEIpDijjfkCMBhciqMnynXiJya)Iq5ddoKrvNd8z6FcuPNhOLUXfm5eG0HKIvqStHDiJQoh4Z0)eOsppqlf5QCpjtXki2OucLcdEheOR)7KqK0GTr6NFyo2SKaPxpMb)qlaciyXiteweqZHu(5bW)cIHvlIP6Dc5zcK)YgON4thsssHcN52lIjuoeK8x2a9eF6qssku4m3ErcqSTYzjHm1r5hk2XGdzu15aFM(Nav65bAP7CSbP8a2sOI4vEheO)ojejnyBK(5hMJnljq61JzWp0cGacwmYeHfb0CiLFEa8VGyWHmQ6CGpt)tGk98aTufMsCa0JditihRs8oiqr5qqYmQUuq)NqowLYC7qabkhcsMr1Lc6)eYXQuQECaLy5xJ6Yf5ddoKrvNd8z6FcuPNhOLYM9DbLgq63Jk5qgvDoWNP)jqLEEGwQPJjKyrdiXO)abOs8oiqR3jKNjq(lBGEIpDijjfkCMrgXa(flbeqGmBWAIrgXa(f5dB6qgvDoWNP)jqLEEGwQbzCSYPdjj4QJmjzuy88oiqjaX2kVyjXqruoeK8x2a9eF6qssku4m3UdjM9gJ5ti92SrX(a28gJlcd69g5yEtylv5uYBwa2iVpM3lhHWBuoeKNxVheV3V)hubL92SimfLFVvwzV1Z7ns9wHjVfNj6vVR3jKNjG3OXtsVpG3bwXicub5nbiJH(SdjM9oQ6CGpt)tGk98aTuSc2eOcIxqyqqzuSpGTKKerzEXkeCeunyBKM1XGs6LKd5qIzVJQoh4Z0)eOsppqlTwUkgWwcRGnbQG4fegeugf7dyljjruM3BhQXa4DqGs)tGkLrzuOWPdjPWuswEaBzJaB8y8Ivi4iOAW2inRJbL0ljhYHmQ6CGpt)tGk98aTugf7dylHicd65DqGQbBJ0SogusVKCOf5lxciGy911GTrAgMcHcN3Rk)ytmabeAW2indtHqHZ7vDrOfGHvlUEu1blkraYyOhkFqaHgSnsZ6yqj9sYH4VaSHvxfciwxd2gPzDmOKEP9QMkad8JDmuC9OQdwuIaKXqpu(GacnyBKM1XGs6LKdXFjl5QR6q6qIzVX4dyEyI9oKrvNd8zKbmpm097ejg9hhRs8ICSeGWwfkFoKy27fqSMVsSqjVHJ3B4zdME17D2CSrl7TPrH928zdwXy8EVsiWgfGk5n3E2BVxaX2kTRZb8EEVnl3cO3YWi2iVnbtaVXPAHu1759MrHSC2HmQ6CGpJmG5H5bAPewZxjwOeVdcuuoeKmy2G1pHfb2OauPm3EX1)DsisAW2i9ZpmhBwsG0RhZyXcGacSc2eOckZ9uANnhB0Yj2PHohaciWKgccO5NQmstkvHbZcKJYeiqfKeciWu9oH8mbYpvzKMuQcdMfihL52x1HeZEBwNODV52928zdwrfHK8Eq8EuVN37a94uV1ZBghW7JtZEVWZBWPEZ9K3MVM3so2a28EHbOs869G4TgccOK07bON3lmyl9ghoKNPSdzu15aFgzaZdZd0sbZgSIkcjX7GaDDmPHGaAwgSLPhoKNPmbcubjHacmHYHGKF4qEMsYauPm3(Qf1XGs6LKdzgmYigWZ)cwKrgXa(f1PUmPJbHrlWHeZEBwXj0rEQoGnVpo9hj59cdqL8(aERbBJ03BfouVnncH3IblYBKJ5TctEl5yHohW7dXBZNnyfvesIxVzecJEyVLCSbS59EaKKXuZEBwXj0rEQ3X7T4aBEhV3fWJ3AW2i99wEEdo1B4alYBZNnyfvesYBUDVnnkS3MnAxm1qhWM34WH8m9EVohqq)7D5JZB4alYBZNnyfJX79kHaBuaQK36DRMDiJQoh4ZidyEyEGwky2GvurijERLRckPbBJ0hkF8oiqXewbBcubL5EkTZMJnA5e70qNdu83jHiPbBJ0p)WCSzjbsVEmd(HwqX1JvqSrPmy2G1pHfb2OauPmbcubjHacmfRGyJszgTlMAOdyl9WH8m9zceOcscbe)ojejnyBK(5hMJnljq61JzygrvhSOK80my2Gvurij(HwWQfXekhcs(Hd5zkjdqLYC7f1XGs6LKdXp01lbpRxagTEgOxA)gG(RUArgHWOhoqfKdjM92Srim6H928zdwrfHK8McMOS3dI3J6TPri8MW29HrEl5ydyZB8YgON4ZEVWZBfouVzecJEyVheVXVf69gPV3mkKL9EaERWK3acBvVlXNDiJQoh4ZidyEyEGwky2GvurijEheOmYigWVy9oH8mbYFzd0t8PdjjPqHZmYigWZdFyOy9oH8mbYFzd0t8PdjjPqHZmYigWVi0suuhdkPxsoKzWiJyap)17eYZei)LnqpXNoKKKcfoZiJyappLWHmQ6CGpJmG5H5bAPpvzKMuQcdMfih5qgvDoWNrgW8W8aTucR5ReluYH0HeZEJRuiuyVnZ7eYZe4DiXS3ymtIDI59kjytGkihYOQZb(8Ruiu4uv(qXkytGkiEbHbb9HLjfMrp8jK8Ivi4iO17eYZei)WH8mLKbOs5kCW2OpHWIQohie8dLV8kVeoKy27vsaMh2BoGG(3BtK3bJ8oqpo1B98Ug7EFaVxyaQK3v4GTrF2BZAarzVnbtaVX4dq69kLILa6FVN37a94uV1ZBghW7JtZoKrvNd85xPqOWPQ85bAPyfG5H5DqGIjSc2eOck)WYKcZOh(eYI1Za9s73a0pljKPok)8vusOCiizKbitMOyjG(pZiJya)I8vSENqEMa5VSb6j(0HKKuOWzgzed45hk2DiXS3yK7eEJCmVXHd5zYGesV5XBC4qEMELnljV5ac6FVnrEhmY7a94uV1Z7AS79b8EHbOsExHd2g9zVnRbeL92emb8gJpaP3RukwcO)9EEVd0Jt9wpVzCaVpon7qgvDoWNFLcHcNQYNhOLUFNiXO)4yvIxKJLae2Qq5JxcBvwKcJJdOqljgCiJQoh4ZVsHqHtv5Zd0sF4qEMmiHK3bbkbi2wz(HwsmuKaeBRCwsitDu(HYhgkIjSc2eOck)WYKcZOh(eYI1Za9s73a0pljKPok)8vusOCiizKbitMOyjG(pZiJya)I85qIzVntmI3mAbYnmYGa6kZ7fgGk5DOElotEBMyeVrl7TKqcoHM9EDCouLfvDoG3Z7D4D92l7nc7m8wHjVFLcbmj9gzaZdtmVRHq4nYX8Uqm(c9goasXa2YR6qgvDoWNFLcHcNQYNhOLIvWMavq8ccdc6dlt1Za9s73a0NxScbhbTEgOxA)gG(zjHm1r5hAjnJ11qqanljANyPxzHgBKrMabQGKfxpwbXgLYkmLqg2RjzaQuMabQGKfXKgccOzzWwME4qEMYeiqfKSiM0qqan)COkXq42Ombcubjl(7KqK0GTr6NFyo2SKaPxpMXIyF1vDiXS3MjgXBgTa5ggzqaDL59cdqL8(aIYEJsihJ8gzaZdtS37bXBtK3WbwK3HXU3AiiG(EhaP37S5yJw2B2PHohi7qgvDoWNFLcHcNQYNhOLIvWMavq8ccdc6dlt1Za9s73a0NxScbhbTEgOxA)gG(zjHm1rxekF8uagnwbXgLYkmLqg2RjzaQuMabQGK8oiqXkytGkOm3tPD2CSrlNyNg6CGIRRHGaAgmBW6RHyjXYeiqfKeci0qqanld2Y0dhYZuMabQGKR6qIzVxPJc79cd2sVXHd5zY7dik79cdqL82emb828zdwrfHK820ieE)Au2BU9S3M9N8wYXgWM34LnqpX79X8oqpSiVvyg9WNqM9ELgJ6nYX828vI3OCiiEBAuyVlGhZxjzhYOQZb(8Ruiu4uv(8aT0hoKNPKmavI3bbkwbBcubLFyzQEgOxA)gG(fxhtAiiGMLbBz6Hd5zktGavqsiGqEAgmBWkQiKuMrgXaE(HwcE0qqan)COkXq42OmbcubjxT46yfSjqfu(HLjfMrp8jKqabkhcs(lBGEIpDijjfkCMrgXaE(HYxUaiG43jHiPbBJ0p)WCSzjbsVEmd(HwYI17eYZei)LnqpXNoKKKcfoZiJyap)8HHvlUEScInkLbZgS(jSiWgfGkLzby5IfabeOCiizWSbRFclcSrbOszU9vDiXS3RXXaEZiJyadyZ7fgGk9EJsihJ8wHjV1GTrQ3YHEVheVXVf6TPdGXq9gL8MrHSS3dWBDmOSdzu15aF(vkekCQkFEGw6dhYZusgGkX7GafRGnbQGYpSmvpd0lTFdq)I6yqj9sYHwSENqEMa5VSb6j(0HKKuOWzgzed4lIjwmYeHfb0CiLFMB3H0HeZEJRuiuys6Tz70qNd4qIzVXyr8gxPqOWLIvaMh27GrEZTZR3Cp5noCiptVYMLK365nkbiKr9gHDgERWK37X)dwK3OhG79oasVX4dq69kLILa6FE9MWIaEpiEBI8oyK3H6TrGTEBMyeVxhHDgERWK37mQEgOH6TzfYcxn7qgvDoWNFLcHctsOpCiptVYMLeVdc011qqanJmazYeflb0)zceOcscbe)ojejnyBK(5hMJnljq61JzSi2xT46OCii5xPqOWzUDiGaLdbjJvaMhoZTVQdjM9gJpG5H9ouVXopEBMyeVnnk8XPEVqCVl17sYJ3Mgf27fI7TPrH9ghMJnljG3fEmqipVr5qq8MB3B98oW6gP3)zqEBMyeVnfVsE)JYf6CGp7qgvDoWNFLcHctsEGwAneIuu15ajX8kVGWGGImG5H5DqGIYHGKFyo2SKaj9yGqEzU9I1Za9s73a0pljKPo6IqlWHeZEBwe)59hiK365nYaMh27q9UK84TzIr820OWEtyBuvrzVlP3AW2i9ZEVoEyqEhV3hN(JK8(vkekCEvhYOQZb(8RuiuysYd0sRHqKIQohijMx5fegeuKbmpmVdc0FNeIKgSns)8dZXMLei96XmGwYI1Za9s73a0NFOL0HeZEJXhW8WEhQ3LKhVntmI3Mgf(4uVxioVExcE820OWEVqCE9oasVxqVnnkS3le37arjM3RKampS3hZ7cHjVX4d7vVxyaQK384T5ZgS(EVsOnkavYHmQ6CGp)kfcfMK8aT0AiePOQZbsI5vEbHbbfzaZdZ7GaTEgOxA)gG(zjHm1rxekFMX6AiiGMLeTtS0RSqJnYitGavqYIRJYHGKXkaZdN52HaIyfeBukRWuczyVMKbOszceOcsw83jHiPbBJ0p)WCSzjbsVEmJfXEruoeKmy2G1pHfb2OauPm3(QR6qIzVn7p59cqXDgOIqsEFyrmVXHd5z6v2SK8oasVX1Jz4TPrH9UaE8gJqmKJfk5DOExG3hZBb9V3AW2i9ZoKrvNd85xPqOWKKhOLUjUZavesI3bbAScInkL3jgYXcLYSaSKFOfu83jHiPbBJ0p)WCSzjbsVEmJfHwGdjM92SOExG3AW2i9920OWEJtvgPExivHbZcKJ8Ejr7EZT7ngFasVxPuSeq)7nAzVRLRIbS5noCiptVYMLu2HmQ6CGp)kfcfMK8aT0hoKNPxzZsI3A5QGsAW2i9HYhVdcuneeqZpvzKMuQcdMfihLjqGkizrneeqZidqMmrXsa9FMabQGKfLekhcsgzaYKjkwcO)ZmYigWViFf)DsisAW2i9ZpmhBwsG0RhZaAbf1XGs6LKdzgmYigWZ)c6qIzVxPJcFCQ3lKODI5nUYcn2idVdG0BS7TzlalFVpeVxtesY7b4TctEJdhYZ079OEpV3MoMc7n3pGnVXHd5z6v2SK8(aEJDV1GTr6NDiJQoh4ZVsHqHjjpql9Hd5z6v2SK4DqGIjneeqZsI2jw6vwOXgzKjqGkizXyfeBukJkcjLgqsHP0dhYZ0NzbyjuSx83jHiPbBJ0p)WCSzjbsVEmdOy3HeZEJXpM37S5yJw2B2PHohGxV5EYBC4qEMELnljVpSiM346Xm8MVv920OWEVsnR8o2Ib8Q3C7ERN3L0BnyBK(86DbR69G4ngFL698EZ4aGbS59HG496hW7au27W44aQ3hI3AW2i9xLxVpM3yFvV1ZBJaBhJzfK343c9MWwLa)CaVnnkS3ySacRrd0rmAzVpG3y3BnyBK(EVEj920OWEV2O4RMDiJQoh4ZVsHqHjjpql9Hd5z6v2SK4DqGIvWMavqzUNs7S5yJwoXon05afxxdbb0mYaKjtuSeq)NjqGkizrjHYHGKrgGmzIILa6)mJmIb8lYheqOHGaA2ef7hWiELyzceOcsw83jHiPbBJ0p)WCSzjbsVEmJfHwsiGiwbXgLYdGWA0aDeJwotGavqYIOCii5VSb6j(0HKKuOWzU9I)ojejnyBK(5hMJnljq61JzSiuSZtScInkLrfHKsdiPWu6Hd5z6ZeiqfKCvhYOQZb(8RuiuysYd0sFyo2SKaPxpMbVdc0FNeIKgSnsF(HIDhYOQZb(8RuiuysYd0sF4qEMELnljRAvRf]] )


end
