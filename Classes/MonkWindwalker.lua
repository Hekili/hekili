-- MonkWindwalker.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'MONK' then
    local spec = Hekili:NewSpecialization( 269 )

    spec:RegisterResource( Enum.PowerType.Energy, {
        crackling_jade_lightning = {
            aura = 'crackling_jade_lightning',
            debuff = true,

            last = function ()
                local app = state.buff.crackling_jade_lightning.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x )
                return x < class.abilities.crackling_jade_lightning.spendPerSec
            end,

            interval = function () return state.haste end,
            value = function () return class.abilities.crackling_jade_lightning.spendPerSec end,
        },
    } )

    spec:RegisterResource( Enum.PowerType.Chi )

    spec:RegisterResource( Enum.PowerType.Mana )


    -- Talents
    spec:RegisterTalents( {
        eye_of_the_tiger = 23106, -- 196607
        chi_wave = 19820, -- 115098
        chi_burst = 20185, -- 123986

        celerity = 19304, -- 115173
        chi_torpedo = 19818, -- 115008
        tigers_lust = 19302, -- 116841

        ascension = 22098, -- 115396
        fist_of_the_white_tiger = 19771, -- 261947
        energizing_elixir = 22096, -- 115288

        tiger_tail_sweep = 19993, -- 264348
        good_karma = 23364, -- 280195
        ring_of_peace = 19995, -- 116844

        inner_strength = 23258, -- 261767
        diffuse_magic = 20173, -- 122783
        dampen_harm = 20175, -- 122278

        hit_combo = 22093, -- 196740
        rushing_jade_wind = 23122, -- 261715
        invoke_xuen = 22102, -- 123904

        spiritual_focus = 22107, -- 280197
        whirling_dragon_punch = 22105, -- 152175
        serenity = 21191, -- 152173
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3572, -- 214027
        relentless = 3573, -- 196029
        gladiators_medallion = 3574, -- 208683

        disabling_reach = 3050, -- 201769
        grapple_weapon = 3052, -- 233759
        tigereye_brew = 675, -- 247483
        turbo_fists = 3745, -- 287681
        pressure_points = 3744, -- 287599
        reverse_harm = 852, -- 287771
        wind_waker = 3737, -- 287506
        alpha_tiger = 3734, -- 287503
        ride_the_wind = 77, -- 201372
        fortifying_brew = 73, -- 201318
    } )

    -- Auras
    spec:RegisterAuras( {
        bok_proc = {
            id = 116768,
            duration = 15,
        },
        chi_torpedo = {
            id = 119085,
            duration = 10,
            max_stack = 2,
        },
        dampen_harm = {
            id = 122278,
            duration = 10
        },
        diffuse_magic = {
            id = 122783,
            duration = 6
        },
        disable = {
            id = 116095,
            duration = 15,
        },
        disable_root = {
            id = 116706,
            duration = 8,
        },
        exit_strategy = {
            id = 289324,
            duration = 2,
            max_stack = 1
        },
        eye_of_the_tiger = {
            id = 196608,
            duration = 8
        },        
        fists_of_fury = {
            id = 113656,
            duration = function () return 4 * haste end,
        },        
        flying_serpent_kick = {
            name = "Flying Serpent Kick",
            duration = 2,
            generate = function ()
                local cast = rawget( class.abilities.flying_serpent_kick, "lastCast" ) or 0
                local up = cast + 2 > query_time

                local fsk = buff.flying_serpent_kick
                fsk.name = "Flying Serpent Kick"

                if up then
                    fsk.count = 1
                    fsk.expires = cast + 2
                    fsk.applied = cast
                    fsk.caster = "player"
                    return
                end
                fsk.count = 0
                fsk.expires = 0
                fsk.applied = 0
                fsk.caster = "nobody"
            end,
        },        
        hit_combo = {
            id = 196741,
            duration = 10,
            max_stack = 6,
        },
        leg_sweep = {
            id = 119381,
            duration = 3,
        },
        mark_of_the_crane = {
            id = 228287,
            duration = 15,
        },
        mystic_touch = {
            id = 113746,
            duration = 60,
        },
        paralysis = {
            id = 115078,
            duration = 15,
        },
        power_strikes = {
            id = 129914,
            duration = 3600,
        },
        pressure_point = {
            id = 247255,
            duration = 5,
        },
        provoke = {
            id = 115546,
            duration = 8,
        },
        ring_of_peace = {
            id = 116844,
            duration = 5
        },
        rising_sun_kick = {
            id = 107428,
            duration = 10,
        },
        rushing_jade_wind = {
            id = 116847,
            duration = function () return 9 * haste end,
            max_stack = 1,
            dot = "buff",
        },
        serenity = {
            id = 152173,
            duration = 12,
        },
        spinning_crane_kick = {
            id = 101546,
            duration = function () return 1.5 * haste end,
        },
        storm_earth_and_fire = {
            id = 137639,
            duration = 15,
        },
        the_emperors_capacitor = {
            id = 235054,
            duration = 3600,
            max_stack = 20,
        },
        tigers_lust = {
            id = 116841,
            duration = 6,
        },
        touch_of_death = {
            id = 115080,
            duration = 8
        },
        touch_of_karma = {
            id = 125174,
            duration = 10,
        },
        touch_of_karma_debuff = {
            id = 122470,
            duration = 10,
        },
        transcendence = {
            id = 101643,
            duration = 900,
        },
        whirling_dragon_punch = {
            id = 152175,
            duration = 1,
        },
        windwalking = {
            id = 157411,
            duration = 3600,
            max_stack = 1,
        },

        -- PvP Talents
        alpha_tiger = {
            id = 287504,
            duration = 8,
            max_stack = 1,
        },

        fortifying_brew = {
            id = 201318,
            duration = 15,
            max_stack = 1,
        },

        grapple_weapon = {
            id = 233759,
            duration = 6,
            max_stack = 1,
        },

        heavyhanded_strikes = {
            id = 201787,
            duration = 2,
            max_stack = 1,
        },

        ride_the_wind = {
            id = 201447,
            duration = 3600,
            max_stack = 1,
        },

        tigereye_brew_stack = {
            id = 248646,
            duration = 120,
            max_stack = 20,
        },

        tigereye_brew = {
            id = 247483,
            duration = 20,
            max_stack = 1
        },

        wind_waker = {
            id = 290500,
            duration = 4,
            max_stack = 1,
        },


        -- Azerite Powers
        dance_of_chiji = {
            id = 286587,
            duration = 15,
            max_stack = 1
        },

        fury_of_xuen = {
            id = 287062,
            duration = 20,
            max_stack = 67,
        },

        fury_of_xuen_haste = {
            id = 287063,
            duration = 8,
            max_stack = 1,
        },

        sunrise_technique = {
            id = 273298,
            duration = 15,
            max_stack = 1
        },
    } )


    spec:RegisterGear( 'tier19', 138325, 138328, 138331, 138334, 138337, 138367 )
    spec:RegisterGear( 'tier20', 147154, 147156, 147152, 147151, 147153, 147155 )
    spec:RegisterGear( 'tier21', 152145, 152147, 152143, 152142, 152144, 152146 )
    spec:RegisterGear( 'class', 139731, 139732, 139733, 139734, 139735, 139736, 139737, 139738 )

    spec:RegisterGear( 'cenedril_reflector_of_hatred', 137019 )
    spec:RegisterGear( 'cinidaria_the_symbiote', 133976 )
    spec:RegisterGear( 'drinking_horn_cover', 137097 )
    spec:RegisterGear( 'firestone_walkers', 137027 )
    spec:RegisterGear( 'fundamental_observation', 137063 )
    spec:RegisterGear( 'gai_plins_soothing_sash', 137079 )
    spec:RegisterGear( 'hidden_masters_forbidden_touch', 137057 )
    spec:RegisterGear( 'jewel_of_the_lost_abbey', 137044 )
    spec:RegisterGear( 'katsuos_eclipse', 137029 )
    spec:RegisterGear( 'march_of_the_legion', 137220 )
    spec:RegisterGear( 'prydaz_xavarics_magnum_opus', 132444 )
    spec:RegisterGear( 'salsalabims_lost_tunic', 137016 )
    spec:RegisterGear( 'sephuzs_secret', 132452 )
    spec:RegisterGear( 'the_emperors_capacitor', 144239 )

    spec:RegisterGear( 'soul_of_the_grandmaster', 151643 )
    spec:RegisterGear( 'stormstouts_last_gasp', 151788 )
    spec:RegisterGear( 'the_wind_blows', 151811 )


    spec:RegisterStateTable( "combos", {
        blackout_kick = true,
        chi_burst = true,
        chi_wave = true,
        crackling_jade_lightning = true,
        fist_of_the_white_tiger = true,
        fists_of_fury = true,
        flying_serpent_kick = true,
        rising_sun_kick = true,
        spinning_crane_kick = true,
        tiger_palm = true,
        touch_of_death = true,
        whirling_dragon_punch = true
    } )

    local prev_combo, actual_combo, virtual_combo

    spec:RegisterStateExpr( "last_combo", function () return virtual_combo or actual_combo end )


    local tigers_palmed = {}
    local tigers_palmed_v = {}


    -- If a Tiger Palm missed, pretend we never cast it.
    -- Use RegisterEvent since we're looking outside the state table.
    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event )
        local _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID then
            local ability = class.abilities[ spellID ] and class.abilities[ spellID ].key
            if not ability then return end

            if ability == "tiger_palm" and subtype == "SPELL_MISSED" and not state.talent.hit_combo.enabled then
                if ns.castsAll[1] == "tiger_palm" then ns.castsAll[1] = "none" end
                if ns.castsAll[2] == "tiger_palm" then ns.castsAll[2] = "none" end
                if ns.castsOn[1] == "tiger_palm" then ns.castsOn[1] = "none" end
                actual_combo = "none"

                Hekili:ForceUpdate( "WW_MISSED" )

            elseif subtype == "SPELL_CAST_SUCCESS" and state.combos[ ability ] then
                prev_combo = actual_combo
                actual_combo = ability

                -- For Alpha Tiger.
                if ability == "tiger_palm" and not tigers_palmed[ destGUID ] then tigers_palmed[ destGUID ] = GetTime() end

            elseif subtype == "SPELL_DAMAGE" and spellID == 148187 then
                -- track the last tick.
                state.buff.rushing_jade_wind.last_tick = GetTime()

            end
        end
    end )


    spec:RegisterHook( "runHandler", function( key, noStart )
        if combos[ key ] then
            if last_combo == key then removeBuff( "hit_combo" )
            else
                if talent.hit_combo.enabled then addStack( "hit_combo", 10, 1 ) end
                if azerite.fury_of_xuen.enabled then addStack( "fury_of_xuen", nil, 1 ) end                
            end
            virtual_combo = key
        end
    end )


    local chiSpent = 0

    spec:RegisterHook( "spend", function( amt, resource )
        if talent.spiritual_focus.enabled then
            chiSpent = chiSpent + amt           
            cooldown.storm_earth_and_fire.expires = max( 0, cooldown.storm_earth_and_fire.expires - floor( chiSpent / 2 ) )
            chiSpent = chiSpent % 2
        end

        if level < 116 then
            if equipped.the_emperors_capacitor and resource == 'chi' then
                addStack( "the_emperors_capacitor", 30, 1 )
            end
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        chiSpent = 0
        if prev_gcd[1].tiger_palm and ( class.abilities.tiger_palm.lastCast == 0 or combat == 0 or class.abilities.tiger_palm.lastCast < combat - 0.05 ) then
            prev_gcd.override = "none"
            prev.override = "none"
        end

        if buff.rushing_jade_wind.up then setCooldown( "rushing_jade_wind", 0 ) end

        table.wipe( tigers_palmed_v )
        for k, v in pairs( tigers_palmed ) do
            if now - v > 30 then tigers_palmed[ k ] = nil
            else tigers_palmed_v[ k ] = v end
        end

        spinning_crane_kick.count = nil
        virtual_combo = nil
    end )


    spec:RegisterHook( "IsUsable", function( spell )
        -- Allow repeats to happen if your chi has decayed to 0.
        if talent.hit_combo.enabled and buff.hit_combo.up and ( spell ~= "tiger_palm" or chi.current > 0 ) and last_combo == spell then
            return false, "would break hit_combo"
        end
    end )


    spec:RegisterStateTable( "spinning_crane_kick", setmetatable( { onReset = function( self ) self.count = nil end },
        { __index = function( t, k )
                if k == 'count' then
                    t[ k ] = max( GetSpellCount( action.spinning_crane_kick.id ), active_dot.mark_of_the_crane )
                    return t[ k ]
                end
        end } ) )

    spec:RegisterStateExpr( "alpha_tiger_ready", function ()
        if not pvptalent.alpha_tiger.enabled then
            return false
        elseif not tigers_palmed_v[ target.unit ] or query_time - tigers_palmed_v[ target.unit ] > 30 then
            return true
        elseif cycle then
            local count = 0
            for k, v in pairs( tigers_palmed_v ) do
                if query_time - v < 30 then count = count + 1 end
            end
            return count < active_enemies
        end
        return false
    end )

    spec:RegisterStateExpr( "alpha_tiger_ready_in", function ()
        if not pvptalent.alpha_tiger.enabled then return 3600 end
        if not tigers_palmed_v[ target.unit ] then return 0 end
        if query_time - tigers_palmed_v[ target.unit ] > 30 then return 0 end
        return 30 - tigers_palmed_v[ target.unit ] - query_time
    end )


    -- Abilities
    spec:RegisterAbilities( {
        blackout_kick = {
            id = 100784,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.serenity.up or buff.bok_proc.up then return 0 end
                return 1
            end,
            spendType = "chi",

            startsCombat = true,
            texture = 574575,

            cycle = 'mark_of_the_crane',

            handler = function ()
                if buff.bok_proc.up and buff.serenity.down then
                    removeBuff( "bok_proc" )
                    if set_bonus.tier21_4pc > 0 then gain( 1, "chi" ) end
                end

                cooldown.rising_sun_kick.expires = max( 0, cooldown.rising_sun_kick.expires - 1 )
                cooldown.fists_of_fury.expires = max( 0, cooldown.fists_of_fury.expires - 1 )

                if talent.eye_of_the_tiger.enabled then applyDebuff( "target", "eye_of_the_tiger" ) end
                applyDebuff( "target", "mark_of_the_crane", 15 )
            end,
        },


        chi_burst = {
            id = 123986,
            cast = function () return 1 * haste end,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 135734,

            talent = "chi_burst",

            handler = function ()
                gain( min( 2, active_enemies ), "chi" )
            end,
        },


        chi_torpedo = {
            id = 115008,
            cast = 0,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            startsCombat = false,
            texture = 607849,

            talent = "chi_torpedo",            

            handler = function ()
                applyBuff( "chi_torpedo" )
            end,
        },


        chi_wave = {
            id = 115098,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 606541,

            talent = "chi_wave",

            handler = function ()
            end,
        },


        crackling_jade_lightning = {
            id = 117952,
            cast = 4,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",

            spend = 20,
            spendPerSec = 20,
            spendType = "energy",

            startsCombat = true,
            texture = 606542,

            handler = function ()
                applyDebuff( "target", "crackling_jade_lightning" )
                removeBuff( "the_emperors_capacitor" )   
            end,
        },


        dampen_harm = {
            id = 122278,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 620827,

            talent = "dampen_harm",
            handler = function ()
                applyBuff( "dampen_harm" )
            end,
        },


        detox = {
            id = 218164,
            cast = 0,
            charges = 1,
            cooldown = 8,
            recharge = 8,
            gcd = "spell",

            spend = 20,
            spendType = "energy",

            startsCombat = false,
            texture = 460692,

            handler = function ()
            end,
        },


        diffuse_magic = {
            id = 122783,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 775460,

            handler = function ()
            end,
        },


        disable = {
            id = 116095,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0,
            spendType = "energy",

            startsCombat = true,
            texture = 132316,

            handler = function ()
                if not debuff.disable.up then applyDebuff( "target", "disable" )
                else applyDebuff( "target", "disable_root" ) end
            end,
        },


        energizing_elixir = {
            id = 115288,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 608938,

            talent = "energizing_elixir",

            handler = function ()
                gain( energy.max, "energy" )
                gain( 2, "chi" )
            end,
        },


        fist_of_the_white_tiger = {
            id = 261947,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 2065583,

            talent = "fist_of_the_white_tiger",

            handler = function ()
                gain( 3, "chi" )
            end,
        },


        fists_of_fury = {
            id = 113656,
            cast = 4,
            channeled = true,
            cooldown = function ()
                local x = 24 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            gcd = "spell",

            spend = function ()
                if buff.serenity.up then return 0 end
                if level < 116 and equipped.katsuos_eclipse then return 2 end
                return 3
            end,
            spendType = "chi",

            startsCombat = true,
            texture = 627606,

            handler = function ()
                if level < 116 and set_bonus.tier20_4pc == 1 then applyBuff( "pressure_point", 5 + action.fists_of_fury.cast ) end
                if buff.fury_of_xuen.stack >= 50 then
                    applyBuff( "fury_of_xuen_haste" )
                    summonPet( "xuen", 8 )
                    removeBuff( "fury_of_xuen" )
                end
                if pvptalent.turbo_fists.enabled then
                    applyDebuff( "target", "heavyhanded_strikes", action.fists_of_fury.cast_time + 2 )
                end
            end,
        },


        fortifying_brew = {
            id = 201318,
            cast = 0,
            cooldown = 90,
            gcd = "off",

            toggle = "defensives",
            pvptalent = "fortifying_brew",

            startsCombat = false,
            texture = 1616072,

            handler = function ()
                applyBuff( "fortifying_brew" )
            end,
        },


        flying_serpent_kick = {
            id = 101545,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 606545,

            handler = function ()
                if buff.flying_serpent_kick.up then
                    removeBuff( "flying_serpent_kick" )
                else
                    applyBuff( "flying_serpent_kick" )
                    setCooldown( "global_cooldown", 2 )
                end
            end,
        },


        grapple_weapon = {
            id = 233759,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "grapple_weapon",

            startsCombat = true,
            texture = 132343,

            handler = function ()
                applyDebuff( "target", "grapple_weapon" )
            end,
        },


        invoke_xuen = {
            id = 123904,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 620832,

            talent = "invoke_xuen",

            handler = function ()
                summonPet( "xuen", 45 )
            end,

            copy = "invoke_xuen_the_white_tiger"
        },


        leg_sweep = {
            id = 119381,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 642414,

            handler = function ()
                applyDebuff( "target", "leg_sweep" )
                active_dot.leg_sweep = active_enemies
            end,
        },


        paralysis = {
            id = 115078,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0,
            spendType = "energy",

            startsCombat = false,
            texture = 629534,

            handler = function ()
                applyDebuff( "target", "paralysis", 60 )
            end,
        },


        provoke = {
            id = 115546,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            startsCombat = true,
            texture = 620830,

            handler = function ()
                applyDebuff( "target", "provoke", 8 )
            end,
        },


        resuscitate = {
            id = 115178,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 132132,

            handler = function ()
            end,
        },


        reverse_harm = {
            id = 287771,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            pvptalent = "reverse_harm",

            startsCombat = true,
            texture = 627486,

            indicator = function ()
                if health.current > 0.92 * health.max then return "cycle" end
            end,

            usable = function ()
                if health.current < 0.92 * health.max then return true end

                if not group then return false, "solo and player health_pct > 92" end

                if UnitExists( "focus" ) and UnitIsFriend( "player", "focus" ) and UnitHealth( "focus" ) < UnitHealthMax( "focus" ) * 0.92 then return true end
                if UnitExists( "targettarget" ) and UnitIsFriend( "player", "targettarget" ) and UnitHealth( "targettarget" ) < UnitHealthMax( "targettarget" ) * 0.92 then return true end

                -- Try party members.
                for i = 1, 4 do
                    local unit = "party" .. i                        
                    if UnitExists( unit ) and UnitHealth( unit ) < UnitHealthMax( unit ) * 0.92 then return true end
                end

                return false, "grouped but no ally's health_pct < 92"
            end,

            handler = function ()
                health.actual = min( health.max, health.current + 0.08 * health.max )
                gain( 2, "chi" )
            end,
        },


        ring_of_peace = {
            id = 116844,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 839107,

            talent = "ring_of_peace",

            handler = function ()
            end,
        },


        rising_sun_kick = {
            id = 107428,
            cast = 0,
            cooldown = function ()
                local x = 10 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            gcd = "spell",

            spend = function ()
                if buff.serenity.up then return 0 end
                return 2
            end,
            spendType = "chi",

            startsCombat = true,
            texture = 642415,

            cycle = "mark_of_the_crane",

            handler = function ()
                applyDebuff( 'target', 'mark_of_the_crane' )
                removeBuff( 'pressure_point' )

                if azerite.sunrise_technique.enabled then applyDebuff( "target", "sunrise_technique" ) end
            end,
        },


        roll = {
            id = 109132,
            cast = 0,
            charges = function () return talent.celerity.enabled and 2 or nil end,
            cooldown = function () return talent.celerity.enabled and 15 or 20 end,
            recharge = function () return talent.celerity.eanbled and 15 or 20 end,
            gcd = "spell",

            startsCombat = true,
            texture = 574574,

            notalent = "chi_torpedo",

            handler = function ()
                if azerite.exit_strategy.enabled then applyBuff( "exit_strategy" ) end
            end,
        },


        rushing_jade_wind = {
            id = 116847,
            cast = 0,
            cooldown = function ()
                local x = 6 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            hasteCD = true,
            gcd = "spell",

            spend = 1,
            spendType = "chi",

            talent = "rushing_jade_wind",

            startsCombat = false,
            texture = 606549,

            handler = function ()
                applyBuff( "rushing_jade_wind" )
            end,
        },


        serenity = {
            id = 152173,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 90 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 988197,

            talent = "serenity",

            handler = function ()
                applyBuff( "serenity" )
                setCooldown( "fist_of_the_white_tiger", cooldown.fist_of_the_white_tiger.remains - ( cooldown.fist_of_the_white_tiger.remains / 2 ) )
                setCooldown( "fists_of_fury", cooldown.fists_of_fury.remains - ( cooldown.fists_of_fury.remains / 2 ) )
                setCooldown( "rising_sun_kick", cooldown.rising_sun_kick.remains - ( cooldown.rising_sun_kick.remains / 2 ) )
                setCooldown( "rushing_jade_wind", cooldown.rushing_jade_wind.remains - ( cooldown.rushing_jade_wind.remains / 2 ) )
            end,
        },


        spear_hand_strike = {
            id = 116705,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 608940,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        spinning_crane_kick = {
            id = 101546,
            cast = 1.5,
            channeled = true,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.dance_of_chiji.up and 0 or 2 end,
            spendType = "chi",

            startsCombat = true,
            texture = 606543,

            handler = function ()
                removeBuff( "dance_of_chiji" )
            end,
        },


        storm_earth_and_fire = {
            id = function () return buff.storm_earth_and_fire.up and 221771 or 137639 end,
            cast = 0,
            charges = 2,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136038,

            notalent = "serenity",
            nobuff = "storm_earth_and_fire",

            handler = function ()
                applyBuff( "storm_earth_and_fire" )
            end,

            copy = { 137639, 221771 }
        },


        tiger_palm = {
            id = 100780,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 50,
            spendType = "energy",

            startsCombat = true,
            texture = 606551,

            cycle = "mark_of_the_crane",

            buff = function () return prev_gcd[1].tiger_palm and buff.hit_combo.up and "hit_combo" or nil end,

            handler = function ()
                if talent.eye_of_the_tiger.enabled then
                    applyDebuff( "target", "eye_of_the_tiger" )
                    applyBuff( "eye_of_the_tiger" )
                end

                if pvptalent.alpha_tiger.enabled and ( not tigers_palmed_v[ target.unit ] or ( query_time - tigers_palmed_v[ target.unit ] ) > 30 ) then
                    if buff.alpha_tiger.down then stat.haste = stat.haste + 0.10 end
                    applyBuff( "alpha_tiger" )
                    tigers_palmed_v[ target.unit ] = query_time
                end

                applyDebuff( "target", "mark_of_the_crane" )

                gain( buff.power_strikes.up and 3 or 2, "chi" )
                removeBuff( "power_strikes" )
            end,
        },


        tigereye_brew = {
            id = 247483,
            cast = 0,
            cooldown = 1,
            gcd = "spell",

            startsCombat = false,
            texture = 613399,

            buff = "tigereye_brew_stack",
            pvptalent = "tigereye_brew",

            handler = function ()
                applyBuff( "tigereye_brew", 2 * min( 10, buff.tigereye_brew_stack.stack ) )
                removeStack( "tigereye_brew_stack", min( 10, buff.tigereye_brew_stack.stack ) )
            end,
        },


        tigers_lust = {
            id = 116841,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 651727,

            talent = "tigers_lust",

            handler = function ()
                applyBuff( "tigers_lust" )
            end,
        },


        touch_of_death = {
            id = 115080,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 606552,

            cycle = "touch_of_death",

            handler = function ()
                if level < 116 and equipped.hidden_masters_forbidden_touch and buff.hidden_masters_forbidden_touch.down then
                    applyBuff( "hidden_masters_forbidden_touch" )
                end
                applyDebuff( "target", "touch_of_death" )
            end,
        },


        touch_of_karma = {
            id = 122470,
            cast = 0,
            cooldown = 90,
            gcd = "off",

            startsCombat = true,
            texture = 651728,

            usable = function ()
                return incoming_damage_3s >= health.max * 0.2
            end,
            handler = function ()
                applyBuff( "touch_of_karma" )
                applyDebuff( "target", "touch_of_karma_debuff" )
            end,
        },


        transcendence = {
            id = 101643,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            startsCombat = false,
            texture = 627608,

            handler = function ()
            end,
        },


        transcendence_transfer = {
            id = 119996,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = false,
            texture = 237585,

            handler = function ()
            end,
        },


        vivify = {
            id = 116670,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = false,
            texture = 1360980,

            handler = function ()
            end,
        },


        whirling_dragon_punch = {
            id = 152175,
            cast = 0,
            cooldown = 24,
            gcd = "spell",

            startsCombat = true,
            texture = 988194,

            talent = "whirling_dragon_punch",

            usable = function () return ( index > 1 or IsUsableSpell( 152175 ) ) and cooldown.fists_of_fury.remains > 0 and cooldown.rising_sun_kick.remains > 0 end,

            handler = function ()
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
        cycle = true,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_bursting_blood",

        package = "Windwalker",

        strict = false
    } )

    spec:RegisterPack( "Windwalker", 20190707.2334, [[dO0BTaqiskEeKQUesfsBcj8jskvzueItHu1RiKMfs0TGuzxk1VKunmKKogHAzKepJKQPHurxdPsBdjHVjrIXjrsDoKeToKkyEse3JQAFKKoiKszHiPEOePCrjsLncPu9rskv1ijPu6KqkrRKk8siLWnrQqTtvIHssPYsHuspvftvL0vjPu8vjsv7f0FjAWQ6WkwSeEmWKH4YO2mj(mbJMQCAkRMKsEnKmBLCBQ0UL63igUk1XrQqSCOEoPMUW1LKTlr9DjLXdP48iL1lrsMpv0(fnum8k8GmbdVOcvftLuTuOAPSvrD1vNoHNG2ndp3da1iWWtpUm8u6TgP2SqXy45EOTidc8k8OjvyadpErCRPd1RlyHxvXgqCRRn3Q1egPb4rjQRnxq9IfPOEHYGoeUC9BmrXwSUUAhMrRJHORR2HwL0XKgLS0BnsTzHIXBT5cGNIkBfOLnSaEqMGHxuHQIPsQwkuTu2QOU6QRovcp6BgaVOcvqLWJNHGWnSaEqynaEqF(LERrQnlumoF6ysJkDG(89I4wthQxxWcVQInG4wxBUvRjmsdWJsuxBUG6Pd0NVJQfT8lfkZxfQkMkZhD5RI60bvOB6iDG(8lnVPfynDiDG(8rx(Ov2LuMZ)CZdoF12PrY)eydfNpG0iHrAD(I4nnYIrYVGw(dccPPFNoqF(OlF0k7skZ5J2pOf5JzaX1LBKjmsNVi1S1k)cgqC58N8VXSc970b6ZhD5xAEtlW5hdwGdPPKFqYhqdSyzmybo070b6ZhD5JwzxszoFUzSaT8bZD(apgGkFfcoF0UPdD(eL8r7vyA5lI2CZhXuuym3aoFtNFZcltWkwmL5xuf5FVgA5JykkmMBaNVPZxBcTPyGPd63Pd0Np6YhTHGWi5R2O58rld2vNVib2AuCOPmFoaB63WZY0HgEfEaiWRWlIHxHNbegPHhRltqXs0uXn8W9uSyei1WaErf4v4H7PyXiqQHNECz4P8GTPyXsRdU1wqtkyctzYkKenWwRjSwqI5beem8mGWin8uEW2uSyP1b3AlOjfmHPmzfsIgyR1ewliX8accggWlQdVcpdimsdpvAwAb7QHhUNIfJaPggWl0j8k8mGWin8uSieePsfMg8W9uSyei1WaEHUWRWZacJ0WtbJ1mgL1cWd3tXIrGudd4fQaEfE4EkwmcKA4bGTGX2apapB7oOjF0LpWZYxv)8fNpf5ZnJfOTdZLLbr6oOjFv9ZNQB6cpdimsdpdgmnldcgZDad4LsbEfEgqyKgEwMGxOLQvfIGl3b8W9uSyei1WaEPudVcpdimsdpkgMlwecc8W9uSyei1WaEHkHxHNbegPHNPbSoWZscM1cE4EkwmcKAyaViMQWRWd3tXIrGudpaSfm2g4jgSah7WCzzqKigNVQ5tLWZacJ0WtqQaEsIIeHNWdgWlIfdVcpCpflgbsn8aWwWyBGhaHSqi16Toiyxjp4WtonIuXW8g4nybwNVF(QKVtN5ls(aczHqQ1BfthAjrrQuHPTXS7yTo)s8ZNkYNI8bEw(Q6NV65tr(aczHqQ1BSPTwqQRAjkdGAJz3XAD(L4NV48PpFNoZpgSah7WCzzqKigNFj(5lMUWZacJ0WJoiyxjp4WtonIuXWmmGxeRc8k8W9uSyei1WdaBbJTbEaeYcHuR3ytBTGux1suga1gZUJ168lXpFvY3PZ8JblWXomxwgejIX5xIF(IvbEgqyKgE0mMBlObdyap3ygqClMaEfErm8k8W9uSyei1WaErf4v4H7PyXiqQHb8I6WRWd3tXIrGudd4f6eEfE4EkwmcKAyaVqx4v4zaHrA45MegPHhUNIfJaPggWlub8k8W9uSyei1WdaBbJTbEejF1KFmlUJTMXCBbTn3tXIrY3PZ8vt(XS4o2kMoKefz4XYAEwWYWey8M7PyXi5tp8mGWin8a8mzrfwhWaEPuGxHNbegPHhGNjRnLz4H7PyXiqQHbmGNHWWRWlIHxHhUNIfJaPgEgqyKgEWM2AbPUQLOmak4bGTGX2apIKFmlUJDnpdVSwqIGhbslVRAG3M7PyXi5tr(aczHqQ17AEgEzTGebpcKwEx1aVnMDhR15xs(0nF6ZNI8beYcHuR3kMo0sIIuPctBJz3XAD(QMV6WdGgyXYyWcCOHxedd4fvGxHNbegPHNAEgEzTGebpcKwEx1ap4H7PyXiqQHb8I6WRWd3tXIrGudpaSfm2g4rn5FJ5YsbaYw8ombglVNLB(uKpWZYVe)8fNpf5ZnJfOLFj5txQcpdimsdpCZybRuzTGKxgAmmmGxOt4v4zaHrA4rX0HwsuKkvyAWd3tXIrGudd4f6cVcpCpflgbsn8aWwWyBGNIkfLnUs7zTGuTgewwZAKncPwdpdimsdp4kTN1cs1AqyznRrGb8cvaVcpCpflgbsn8aWwWyBGh1K)nMllfaiBXB9T1T1csaEAwIYaOYNI8fjFrYxK8bEw(QMV6570z(aczHqQ1BfthAjrrQuHPTXS7yToFvZNkYN(8PiFrYh4z5RQF(0nFNoZhqilesTERy6qljksLkmTnMDhR15RA(QKp95tF(oDMp3mwG2omxwgeP7GM8lXpF1ZNE4zaHrA4rFBDBTGeGNMLOmakyaVukWRWd3tXIrGudpaSfm2g4b4z5xIF(QdpdimsdpaptwuH1bmGxk1WRWd3tXIrGudpaSfm2g4b4zB3bn5JU8bEw(Q6NV6WZacJ0WJIPdjrrgESSMNfSmmbgdd4fQeEfE4EkwmcKA4zaHrA4jmbglVNLl8aWwWyBGhGNTDh0Kp6Yh4z5RQF(QKpf5ls(Qj)ywChBplKaIBbzZ9uSyK8D6mF1K)nMllfaiBX7WeyS8EwU5tp8aObwSmgSahA4fXWaErmvHxHNbegPHhGNjRnLz4H7PyXiqQHb8IyXWRWd3tXIrGudpdimsdpfRbGIufsugaf8aWwWyBGh1K)nMllfaiBX7I1aqrQcjkdGkFkYxK8lQuu2feuYBmbSRUZ3PZ8fj)ywChBplKaIBbzZ9uSyK8Pi)Bmxwkaq2I3HjWy59SCZNI8bEw(LKpDMp95tp8aObwSmgSahA4fXWagWJMXCBbn4v4fXWRWd3tXIrGudpdimsdpytBTGux1sugaf8aWwWyBGNbewzwYn7ASo)sYx98D6m)Bmxwkaq2I36BRBRfKa80SeLbqbpaAGflJblWHgErmmGxubEfE4EkwmcKA4bGTGX2apIKFrLIYUyriiRkDSRUZNI8VXCzPaazlEJnT1csDvlrzau5tF(oDMFrLIYwZyUTG2gZUJ168ljFX570z(IK)acRml5MDnwNVQ5loFkYFaHvMLCZUgRZVK8PB(0dpdimsdpkMo0sIIuPctdgWlQdVcpCpflgbsn8aWwWyBGh1K)nMllfaiBXB9T1T1csaEAwIYaOYNI8fj)bewzwYn7ASoFv9Zx98D6mFrYFaHvMLCZUgRZ3pFvYNI8VXCzPaazlExSgaksvirzau5tF(0dpdimsdp6BRBRfKa80SeLbqbd4f6eEfE4EkwmcKA4zaHrA4PynauKQqIYaOGhanWILXGf4qdViggWaE0b8k8Iy4v4zaHrA4PMNHxwlirWJaPL3vnWdE4EkwmcKAyaVOc8k8W9uSyei1WZacJ0Wd20wli1vTeLbqbpaSfm2g4b4z5RQF(0fEa0alwgdwGdn8IyyaVOo8k8mGWin8Oy6qljksLkmn4H7PyXiqQHb8cDcVcpCpflgbsn8mGWin8GnT1csDvlrzauWdGgyXYyWcCOHxedd4f6cVcpCpflgbsn8aWwWyBGh1K)nMllfaiBXB9T1T1csaEAwIYaOYNI8lQuu2itdyjrrc8m1Y2v3WZacJ0WJ(262AbjapnlrzauWaEHkGxHhUNIfJaPgEaylySnWtrLIYgxP9SwqQwdclRznYgHuRZNI8hqyLzj3SRX68vnFXWZacJ0WdUs7zTGuTgewwZAeyaVukWRWd3tXIrGudpaSfm2g4b4z5xIF(QapdimsdpkMoKefz4XYAEwWYWeymmGxk1WRWd3tXIrGudpaSfm2g4b4z5xIF(QNpf5ZnJfOLFj5txQcpdimsdpCZybRuzTGKxgAmmmGxOs4v4H7PyXiqQHNbegPHNI1aqrQcjkdGcEaylySnWJAY)gZLLcaKT4DXAaOivHeLbqLpf5ls(aczHqQ1BSPTwqQRAjkdGAJz3XAD(QMV6570z(aplFv9Zx98PpFkYxK8beYcHuR3kMo0sIIuPctBJz3XAD(QMpDMVtN5d8S8v1pF6mFNoZxK8bEw((5Rs(uK)nMllfaiBX7WeyS8EwU5tF(0dpaAGflJblWHgErmmGxetv4v4zaHrA4b4zYAtzgE4EkwmcKAyaViwm8k8W9uSyei1WdaBbJTbEaE22Dqt(OlFGNLVQ(5loFkYFaHvMLCZUgRZ3pFX570z(apB7oOjF0LpWZYxv)8vbEgqyKgEaEMSOcRdyaViwf4v4H7PyXiqQHNbegPHNWeyS8EwUWdaBbJTbEut(3yUSuaGSfVdtGXY7z5Mpf5d8ST7GM8rx(aplFv9Zxf4bqdSyzmybo0WlIHbmGhewzQwb8k8Iy4v4zaHrA4rFZdw6nnIuhydfdpCpflgbsnmGxubEfESoyC5zbpujvHNBqi94zfEWdv30fEgqyKgEcsfWtsuKOgS7apCpflgbsnmGxuhEfE4EkwmcKA4bGTGX2apfvkkBnJ52cA7Q78D6m)IkfLToiyxjp4WtonIuXW8U6oFNoZxK8vt(XS4o2AgZTf02CpflgjFkYpWwJIJ9nMa2JGTSG2gZdiYN(8D6m)IkfLDXIqqwv6yJ5be570z(XGf4yhMlldIeX48lXpFQGQWZacJ0WZnjmsdd4f6eEfE4EkwmcKA4bGTGX2apfvkkBnJ52cA7QB4zaHrA4bmRLCaHrA5Y0b8SmDi7XLHhnJ52cAWaEHUWRWd3tXIrGudpaSfm2g4rK85MXc02H5YYGiDh0KFj5loFNoZxK8JzXDS1mMBlOT5Ekwms(uKpGqwiKA9wZyUTG2gZUJ168ljFvYN(8PpFkYh4zB3bn5JU8bEw(Q6NV6WZacJ0WJIPdjrrgESSMNfSmmbgdd4fQaEfE4EkwmcKA4zaHrA4jmbglVNLl8aWwWyBGhrYNBglqBhMlldI0Dqt(LKV48D6mFrYpMf3XwZyUTG2M7PyXi5tr(aczHqQ1BnJ52cABm7owRZVK8vjF6ZN(8PiFGNTDh0Kp6Yh4z5RQF(QKpf5RM8VXCzPaazlEhMaJL3ZYfEa0alwgdwGdn8IyyaVukWRWd3tXIrGudpdimsdpGzTKdimslxMoGNLPdzpUm8aqGb8sPgEfE4EkwmcKA4bGTGX2apdiSYSKB21yD(LKV6WZacJ0Wdywl5acJ0YLPd4zz6q2Jldp6agWluj8k8W9uSyei1WdaBbJTbEgqyLzj3SRX68v1pF1HNbegPHhWSwYbegPLlthWZY0HShxgEgcddyad4PmJ1gPHxuHQIl1IvrSkBvuxS6WtTb3wlOHh0s3BcoyK8PI8hqyKo)LPd9oDaptv4rWWZXCln45gtuSfdpOp)sV1i1MfkgNpDmPrLoqF(ErCRPd1RlyHxvXgqCRRn3Q1egPb4rjQRnxq90b6Z3r1Iw(LcL5RcvftL5JU8vrD6Gk0nDKoqF(LM30cSMoKoqF(OlF0k7skZ5FU5bNVA70i5FcSHIZhqAKWiToFr8MgzXi5xql)bbH00VthOpF0LpALDjL58r7h0I8XmG46YnYegPZxKA2ALFbdiUC(t(3ywH(D6a95JU8lnVPf48JblWH0uYpi5dObwSmgSah6D6a95JU8rRSlPmNp3mwGw(G5oFGhdqLVcbNpA30HoFIs(O9kmT8frBU5JykkmMBaNVPZVzHLjyflMY8lQI8VxdT8rmffgZnGZ305RnH2umW0b970b6ZhD5J2qqyK8vB0C(OLb7QZxKaBnko0uMphGn970r6a95x6qddQcgj)cwHG58be3IjYVGfSwVZhTba8DOZVjn68gSRs1k)begP15t6fTD6yaHrA9(gZaIBXe(kRrJkDmGWiTEFJzaXTycr9RRqiiPJbegP17BmdiUftiQF9PsWL7ycJ0Pd0N)PNBThjYhpgs(fvkkms(6ycD(fScbZ5diUftKFblyTo)PrY)gZO7MeH1c5B68rinVthdimsR33ygqClMqu)66EU1EKqQJj0PJbegP17BmdiUftiQF9BsyKoDmGWiTEFJzaXTycr9Rd8mzrfwhuAk(IOMywChBnJ52cABUNIfJ40PAIzXDSvmDijkYWJL18SGLHjW4n3tXIrOpDmGWiTEFJzaXTycr9Rd8mzTPmNoshOp)shAyqvWi5ZLzmT8dZLZp848hqqW5B68NYJTMIfVthOp)begP1(tvqKtedav6yaHrATO(1138GLEtJi1b2qXPd0N)vsfWlFIs(Ofd2DYN05diKfcPwtz(Ms(Q9jeK8rlgS7KVPZN7PyXi5Z0rQMv(bjFXuLQ0rZNOKV7GgZTYnFpEwHx6yaHrATO(1dsfWtsuKOgS7qP1bJlplFQKQuEdcPhpRWZNQB6MoqF(QDKWiD(Ms(hgZTf0YNGZ)eeSlL5x6gC4rz(tJKpA3WC(dMZV6oFcoFAKQ8hmNpUQBRfYxZyUTGw(tJK)KV7yD(6yI8dS1O4i)BmbOPmFcoFAKQ8hmNFvJW48dpoFwrHbr(eL8lwecYQshuMpbNFmyboYpmxo)GKpIX5B68fW8emoFcoFMos1SYpi5tfunDmGWiTwu)63KWinLMIFrLIYwZyUTG2U62PZIkfLToiyxjp4WtonIuXW8U62PtrutmlUJTMXCBbTn3tXIrOiWwJIJ9nMa2JGTSG2gZdiO3PZIkfLDXIqqwv6yJ5beoDgdwGJDyUSmiseJlXNkOA6yaHrATO(1bZAjhqyKwUmDqzpUSVMXCBbnknf)IkfLTMXCBbTD1D6yaHrATO(1vmDijkYWJL18SGLHjWyknfFr4MXc02H5YYGiDh0uIyNofjMf3XwZyUTG2M7PyXiuaiKfcPwV1mMBlOTXS7yTUevONEkaE22Dqd6aEMQ(QNogqyKwlQF9WeyS8EwUucObwSmgSahAFXuAk(IWnJfOTdZLLbr6oOPeXoDksmlUJTMXCBbTn3tXIrOaqilesTERzm3wqBJz3XADjQqp9ua8ST7Gg0b8mv9vHc1CJ5YsbaYw8ombglVNLB6yaHrATO(1bZAjhqyKwUmDqzpUSpajDG(8lTzTYp848pxZFaHr68xMoY3uYp8ymN)G58vjFco)fR15Zn7ASoDmGWiTwu)6GzTKdimslxMoOShx2xhuAk(diSYSKB21yDjQNoqF(L2Sw5hEC(OnsPl)begPZFz6iFtj)WJXC(dMZx98j48DjyoFUzxJ1PJbegP1I6xhmRLCaHrA5Y0bL94Y(dHP0u8hqyLzj3SRXAv9vpDKoqF(OnqyKwVrBKsx(MoFRdUryK8vi48R0C(1SWlF1wgegqI2qqKL2INYC(tJKpOcJ5ow0YVzgrNFqYVGZNChMRvQyK0XacJ069qyFSPTwqQRAjkdGIsanWILXGf4q7lMstXxKywCh7AEgEzTGebpcKwEx1aVn3tXIrOaqilesTExZZWlRfKi4rG0Y7Qg4TXS7yTUe6spfaczHqQ1BfthAjrrQuHPTXS7yTwv1thdimsR3dHf1VEnpdVSwqIGhbslVRAGx6yaHrA9EiSO(15MXcwPYAbjVm0yyknfF1CJ5YsbaYw8ombglVNLlfapReFXuWnJfOvcDPA6yaHrA9EiSO(1vmDOLefPsfMw6yaHrA9EiSO(1XvApRfKQ1GWYAwJqPP4xuPOSXvApRfKQ1GWYAwJSri160XacJ069qyr9RRVTUTwqcWtZsugafLMIVAUXCzPaazlERVTUTwqcWtZsugaffIiIiaptv1D6eqilesTERy6qljksLkmTnMDhR1Qsf0tHiaptvF660jGqwiKA9wX0HwsuKkvyABm7owRvvf6P3PtUzSaTDyUSmis3bnL4Ro9PJbegP17HWI6xh4zYIkSoO0u8bEwj(QNogqyKwVhclQFDfthsIIm8yznplyzycmMstXh4zB3bnOd4zQ6RE6yaHrA9EiSO(1dtGXY7z5sjGgyXYyWcCO9ftPP4d8ST7Gg0b8mv9vHcrutmlUJTNfsaXTGS5EkwmItNQ5gZLLcaKT4DycmwEplx6thdimsR3dHf1VoWZK1MYC6a95pGWiTEpewu)6klAwli1m(M7qIYaOO0u8lQuu2feuYBmbSri1AkToymU6o8fNogqyKwVhclQF9I1aqrQcjkdGIsanWILXGf4q7lMstXxn3yUSuaGSfVlwdafPkKOmakkePOsrzxqqjVXeWU62PtrIzXDS9SqciUfKn3tXIrO4gZLLcaKT4DycmwEplxkaEwj0j90NoshOp)sJqwiKAToDmGWiTEdq8TUmbflrtf3YWJL18SGLHjW40XacJ06naru)6vAwAb7szpUSF5bBtXILwhCRTGMuWeMYKvijAGTwtyTGeZdii40XacJ06naru)6vAwAb7QthdimsR3aer9RxSieePsfMw6yaHrA9gGiQF9cgRzmkRfshOpF1gnNpAddMMZ)kbJ5oY3uYNgPk)bZ57AAT1c5pr(lE0r(IZV08S8Ngj)AKwTxKpyUZNBglql)Aw4zD(uDt381mG0i60XacJ06naru)6dgmnldcgZDqPP4d8ST7Gg0b8mv9ftb3mwG2omxwgeP7Ggv9P6MUPJbegP1BaIO(1xMGxOLQvfIGl3r6yaHrA9gGiQFDfdZflcbjDmGWiTEdqe1V(0awh4zjbZALogqyKwVbiI6xpivapjrrIWt4rPP4hdwGJDyUSmiseJvLkthdimsR3aer9RRdc2vYdo8KtJivmmtPP4diKfcPwV1bb7k5bhEYPrKkgM3aVblWAFvC6ueaHSqi16TIPdTKOivQW02y2DSwxIpvqbWZu1xDkaeYcHuR3ytBTGux1suga1gZUJ16s8ftVtNXGf4yhMlldIeX4s8ft30XacJ06naru)6AgZTf0O0u8beYcHuR3ytBTGux1suga1gZUJ16s8vXPZyWcCSdZLLbrIyCj(IvjDKoqF(hgZTf0Y)gBeSf0shdimsR3AgZTf08XM2AbPUQLOmakkb0alwgdwGdTVyknf)bewzwYn7ASUe1D68gZLLcaKT4T(262AbjapnlrzauPJbegP1BnJ52cAI6xxX0HwsuKkvyAuAk(IuuPOSlwecYQsh7QBkUXCzPaazlEJnT1csDvlrzau070zrLIYwZyUTG2gZUJ16se70PidiSYSKB21yTQIPyaHvMLCZUgRlHU0NogqyKwV1mMBlOjQFD9T1T1csaEAwIYaOO0u8vZnMllfaiBXB9T1T1csaEAwIYaOOqKbewzwYn7ASwvF1D6uKbewzwYn7AS2xfkUXCzPaazlExSgaksvirzau0tF6yaHrA9wZyUTGMO(1lwdafPkKOmakkb0alwgdwGdTV40r6yaHrA9wh(18m8YAbjcEeiT8UQbEPJbegP1BDiQFDSPTwqQRAjkdGIsanWILXGf4q7lMstXh4zQ6t30XacJ06Toe1VUIPdTKOivQW0shdimsR36qu)6ytBTGux1sugafLaAGflJblWH2xC6yaHrA9whI6xxFBDBTGeGNMLOmakknfF1CJ5YsbaYw8wFBDBTGeGNMLOmakkkQuu2itdyjrrc8m1Y2v3PJbegP1BDiQFDCL2ZAbPAniSSM1iuAk(fvkkBCL2ZAbPAniSSM1iBesTMIbewzwYn7ASwvXPJbegP1BDiQFDfthsIIm8yznplyzycmMstXh4zL4Rs6yaHrA9whI6xNBglyLkRfK8YqJHP0u8bEwj(Qtb3mwGwj0LQPJbegP1BDiQF9I1aqrQcjkdGIsanWILXGf4q7lMstXxn3yUSuaGSfVlwdafPkKOmakkebqilesTEJnT1csDvlrzauBm7owRvvDNobEMQ(QtpfIaiKfcPwVvmDOLefPsfM2gZUJ1AvPtNobEMQ(0PtNIa8mFvO4gZLLcaKT4DycmwEplx6PpDmGWiTERdr9Rd8mzTPmNogqyKwV1HO(1bEMSOcRdknfFGNTDh0GoGNPQVykgqyLzj3SRXAFXoDc8ST7Gg0b8mv9vjDmGWiTERdr9RhMaJL3ZYLsanWILXGf4q7lMstXxn3yUSuaGSfVdtGXY7z5sbWZ2UdAqhWZu1xfyadie]] )
end