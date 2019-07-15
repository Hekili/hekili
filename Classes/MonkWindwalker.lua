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

        recently_challenged = {
            id = 290512,
            duration = 30,
            max_stack = 1
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

    local reverse_harm_target

    spec:RegisterHook( "reset_precast", function ()
        chiSpent = 0
        if prev_gcd[1].tiger_palm and ( class.abilities.tiger_palm.lastCast == 0 or combat == 0 or class.abilities.tiger_palm.lastCast < combat - 0.05 ) then
            prev_gcd.override = "none"
            prev.override = "none"
        end

        if buff.rushing_jade_wind.up then setCooldown( "rushing_jade_wind", 0 ) end

        spinning_crane_kick.count = nil
        virtual_combo = nil
        reverse_harm_target = nil
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
        elseif debuff.recently_challenged.down then
            return true
        elseif cycle then return
            active_dot.recently_challenged < active_enemies
        end
        return false
    end )

    spec:RegisterStateExpr( "alpha_tiger_ready_in", function ()
        if not pvptalent.alpha_tiger.enabled then return 3600 end
        if active_dot.recently_challenged < active_enemies then return 0 end
        return debuff.recently_challenged.remains
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

            pvptalent = function ()
                if essence.conflict_and_strife.major then return end
                return "reverse_harm"
            end,

            startsCombat = true,
            texture = 627486,

            indicator = function ()
                local caption = class.abilities.reverse_harm.caption
                if caption and caption ~= UnitName( "player" ) then return "cycle" end
            end,

            caption = function ()
                if not group or not settings.optimize_reverse_harm then return end
                if reverse_harm_target then return reverse_harm_target end

                local targetName, dmg = UnitName( "player "), -1

                if raid then
                    for i = 1, 5 do                        
                        local unit = "raid" .. i

                        if UnitExists( unit ) and UnitIsFriend( "player", unit ) then
                            local h, m = UnitHealth( unit ), UnitHealthMax( unit )
                            local deficit = min( m - h, m * 0.08 )

                            if deficit > dmg then
                                targetName = i < 5 and UnitName( "target" ) or nil
                                dmg = deficit
                            end
                        end
                    end

                elseif group then
                    for i = 1, 5 do                        
                        local unit = i < 5 and ( "party" .. i ) or "player"

                        if UnitExists( unit ) and UnitIsFriend( "player", unit ) then
                            local h, m = UnitHealth( unit ), UnitHealthMax( unit )
                            local deficit = min( m - h, m * 0.08 )

                            if deficit > dmg then
                                targetName = not UnitIsUnit( "player", unit ) and UnitName( unit ) or nil
                                dmg = deficit
                            end
                        end
                    end

                end

                -- Consider using LibGetFrame to highlight a raid frame.

                reverse_harm_target = targetName
                return reverse_harm_target
            end,

            usable = function ()
                if not group and health.deficit / health.max < 0.02 then return false, "solo and health deficit is too low" end
                return true
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

                if pvptalent.alpha_tiger.enabled and debuff.recently_challenged.down then
                    if buff.alpha_tiger.down then stat.haste = stat.haste + 0.10 end
                    applyBuff( "alpha_tiger" )
                    applyDebuff( "target", "recently_challenged" )
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

    spec:RegisterSetting( "optimize_reverse_harm", false, {
        name = "Optimize |T627486:0|t Reverse Harm Target",
        desc = "If checked, the |T627486:0|t Reverse Harm's caption will show the recommended target's name.",
        type = "toggle",
        width = 1.5
    } ) 
    
    spec:RegisterPack( "Windwalker", 20190710.0905, [[dO0qYaqisv5riP6sKQk0Mqs(KsrsnksvofPsVcPywGQULQQAxQYVuknmLchJKAzujEMQsMgskDnKsTnKs8nLIyCkfPoNQQyDiLuZJkP7rvTpsfhejfwiOYdvkkxuPOYgrkjFuPijJKuvjNuvvkRKK8svvP6MKQkANkvgQsrILIKIEQOMQsvxLuvP(Qsrv7vL)s0GHCyjlwepgyYGCzuBMeFMugnv50uwnPQQxJeZwj3Mk2Tu)gQHdkhNuvblhXZjmDHRlsBxvX3vvz8Qk15rQwVQQK5tLA)k(uF7Vmuf8TZLnu)Nn2e1B824pBqlU4YLd6W4ldRaukn(YD5WxEZBn0VArHjxgwrFHlOB)Lf4ucGVSxeWe06TB1SWln5bWoBfMt6Qcd3asPeBfMdyBYcNSnrP(hI)SfgbRylwSDtHWuZYGeB3uOMs9tCtrU5Tg6xTOWKNWCaxoj1wXFRVKldvbF7Czd1)zJnr9gVn(Zg0IAAFzbmgC7CHw(ZL9miiUVKldXcWLP(G28wd9RwuyYG0pXnLrf1hKxeWe06TB1SWln5bWoBfMt6Qcd3asPeBfMdy7OI6dsv6I(GuVb8dYLnu)Nb9)G24p06nO9OAur9bTzEvRXcA9OI6d6)brnzh8hEqzyCrgK(v1qdkheJcpiaUHcd3IbPNx1qlgAqj0hubbHBDFJkQpO)he1KDWF4brRY)9brya2XHBOkmCpi9(zR1Gsya2Hhuniyewr33OI6d6)bTzEvRXdkkIghstzqbEqa6GflJIOXH4nQO(G(Fqut2b)Hhe3mrJ(GafSbb8yaLbPGjdIwzIqmiSYGOvPe6dspH5miitrHjCd4bzIb1S2Y0SKfd)GssJbbBv0heKPOWeUb8GmXGeMwBkgO6q33OI6d6)brnGGyObPFl4b93c2rmi9cI1u4qa)G4a809D5LjcXT)YSqWnGf3(BN6B)Llqy4(YaCd4oivWqsLv5WxM7kzXqhCxC7C52F5cegUVCYcJHKyfz4XsUzh6xM7kzXqhCxC7(62F5cegUVSwArGSQLyfz9xmbhExM7kzXqhCxC7O2B)Llqy4(YkyqQGHK1FXelyzcxoxM7kzXqhCxC7O9T)YfimCFzyPetHU1AYKvjIlZDLSyOdUlUD0YT)YfimCF5WJLPDcoTHKkycGVm3vYIHo4U42Tj3(lxGWW9LjgmylwATuaRa8L5Uswm0b3f3Un9T)YfimCF5FyYc6dBTKWcCxnGVm3vYIHo4U429NB)L5Uswm0b3LbelyIvxMBMOrFqUoiQDJbr1GssvuEIatCKCrcpz1qsfJWVuyxUaHH7l7WoycDjwrUsbgKeIWLJ4IlUma62F7uF7VCbcd3x26pykS87uUVm3vYIHo4U425YT)YCxjlg6G7YD5Wx(trSkzXsRdUfwqxQzA1h8kKybWwRkSwts4ceyYLlqy4(YFkIvjlwADWTWc6sntR(GxHela2AvH1AscxGatU4291T)YfimCF5ublTGDexM7kzXqhCxC7O2B)Llqy4(YjlmgsQKsOFzURKfdDWDXTJ23(lxGWW9LtyIGjuSw7YCxjlg6G7IBhTC7Vm3vYIHo4UmGybtS6Yap75uFpO)heWZgKo(ds9GOAqCZen6VWCyzGLo13dsh)bTXJ2xUaHH7lxeq1SmWec3Xf3Un52F5cegUV8Y08cHu)tH0C4oUm3vYIHo4U42TPV9xUaHH7lRyeozHXqxM7kzXqhCxC7(ZT)YfimCF5QbSii1scQ16YCxjlg6G7IBN6nU9xM7kzXqhCxgqSGjwD5OiAC8cZHLbwcz8G0zq)5YfimCF5aNc8KyfjexH3f3o1QV9xM7kzXqhCxgqSGjwDzagVGW)6NiWehjxKWtwnKuXi8d4venwmi)b5YGC7Eq6niagVGW)6NIjcHeRivsj0Fe2PSwmix9heTmiQgeWZgKo(d6Rbr1Gay8cc)RFetyTMuK2skgGYJWoL1Ib5Q)GupiDhKB3dkkIghVWCyzGLqgpix9hKAAF5cegUVSiWehjxKWtwnKuXi8f3o1UC7Vm3vYIHo4UmGybtS6YamEbH)1pIjSwtksBjfdq5ryNYAXGC1FqUmi3UhuuenoEH5WYalHmEqU6pi1UC5cegUVSGjCBb9lUDQ)62FzURKfdDWD5cegUVmOwlzbcd3YLjIlVmri7YHVmleCdyXfxCzyegGDsQ42F7uF7Vm3vYIHo4U425YT)YCxjlg6G7IB3x3(lZDLSyOdUlUDu7T)YCxjlg6G7IBhTV9xUaHH7lddhgUVm3vYIHo4U42rl3(lZDLSyOdUldiwWeRUSEdsFdkQf3XtWeUTG(J7kzXqdYT7bPVbf1I74PyIqIvKHhl)5zbldtJjpURKfdniDVCbcd3xg4zYKuIiU42Tj3(lxGWW9LbEM8x9HVm3vYIHo4U4Illyc3wq)2F7uF7Vm3vYIHo4UCbcd3xMycR1KI0wsXauUmGybtS6YfiSpSKB2XyXGCDqFni3Uhemc)rQbGEQFcyw3wRjbKQzjfdq5Ya6GflJIOXH42P(IBNl3(lZDLSyOdUldiwWeRUSEdkjvr5LSWyOvQiEPWgevdcgH)i1aqp1pIjSwtksBjfdqzq6oi3UhusQIYtWeUTG(JWoL1Ib56Gupi3UhKEdQaH9HLCZoglgKods9GOAqfiSpSKB2XyXGCDq0Eq6E5cegUVSIjcHeRivsj0V4291T)YCxjlg6G7YaIfmXQlRVbbJWFKAaON6NaM1T1AsaPAwsXaugevdsVbvGW(WsUzhJfdsh)b91GC7Eq6nOce2hwYn7ySyq(dYLbr1GGr4psna0t9lzvak40qsXaugKUds3lxGWW9LfWSUTwtcivZskgGYf3oQ92FzURKfdDWD5cegUVCYQauWPHKIbOCzaDWILrr04qC7uFXfxgIvQ0vC7VDQV9xUaHH7llGXfr6vnKueeJcFzURKfdDWDXTZLB)LToyYNAD5)SXLHbcPhxRW7YB8O9Llqy4(Ybof4jXkskfXPUm3vYIHo4U4291T)YCxjlg6G7YaIfmXQlNKQO8emHBlO)sHni3UhusQIYteyIJKls4jRgsQye(LcBqUDpi9gK(guulUJNGjCBb9h3vYIHgevdkiwtHJhmcg8knBzb9hHlqmiDhKB3dkjvr5LSWyOvQiEeUaXGC7Eqrr044fMdldSeY4b5Q)GOLnUCbcd3xggomCFXTJAV9xM7kzXqhCxgqSGjwD5KufLNGjCBb9xkSlxGWW9Lb1Ajlqy4wUmrC5Ljczxo8LfmHBlOFXTJ23(lZDLSyOdUldiwWeRUSEdIBMOr)fMdldS0P(EqUoi1dYT7bP3GIAXD8emHBlO)4Uswm0GOAqamEbH)1pbt42c6pc7uwlgKRdYLbP7G0DquniGN9CQVh0)dc4zdsh)b91Llqy4(YkMiKyfz4XYFEwWYW0yYf3oA52FzURKfdDWD5cegUVCyAmrcRwoxgqSGjwDz9ge3mrJ(lmhwgyPt99GCDqQhKB3dsVbf1I74jyc3wq)XDLSyObr1Gay8cc)RFcMWTf0Fe2PSwmixhKlds3bP7GOAqap75uFpO)heWZgKo(dYLbr1G03GGr4psna0t9lmnMiHvlNldOdwSmkIghIBN6lUDBYT)YCxjlg6G7YfimCFzqTwYcegULltexEzIq2LdFza0f3Un9T)YCxjlg6G7YaIfmXQlxGW(WsUzhJfdY1b91Llqy4(YGATKfimClxMiU8YeHSlh(YI4IB3FU9xM7kzXqhCxgqSGjwD5ce2hwYn7ySyq64pOVUCbcd3xguRLSaHHB5YeXLxMiKD5WxUW8fxCzrC7VDQV9xUaHH7l)ZZilR1KqKsd3syPnW7YCxjlg6G7IBNl3(lZDLSyOdUlxGWW9LjMWAnPiTLumaLldiwWeRUmWZgKo(dI2xgqhSyzuenoe3o1xC7(62F5cegUVSIjcHeRivsj0Vm3vYIHo4U42rT3(lZDLSyOdUlxGWW9LjMWAnPiTLumaLldOdwSmkIghIBN6lUD0(2FzURKfdDWDzaXcMy1L13GGr4psna0t9taZ62AnjGunlPyakdIQbLKQO8GQgWsSIe4z6V9sHD5cegUVSaM1T1AsaPAwsXauU42rl3(lZDLSyOdUldiwWeRUCsQIYJKk8SwtQ)fel)zn0dc)RhevdQaH9HLCZoglgKods9Llqy4(YKuHN1As9VGy5pRHU42Tj3(lZDLSyOdUldiwWeRUmWZEo13d6)bb8SbPJ)GC5YfimCFzc)Hjcw6veNlUDB6B)L5Uswm0b3LbelyIvxg4zdYv)b5YLlqy4(YkMiKyfz4XYFEwWYW0yYf3U)C7Vm3vYIHo4UmGybtS6YapBqU6pOVgevdIBMOrFqUoiAVXLlqy4(YCZen7VSwtYl7BJCXTt9g3(lZDLSyOdUlxGWW9LtwfGconKumaLldiwWeRUS(gemc)rQbGEQFjRcqbNgskgGYGOAq6niagVGW)6hXewRjfPTKIbO8iStzTyq6mOVgKB3dc4zdsh)b91G0Dquni9geaJxq4F9tXeHqIvKkPe6pc7uwlgKodIAhKB3dc4zdsh)brTdYT7bP3GaE2G8hKldIQbbJWFKAaON6xyAmrcRwods3bP7Lb0blwgfrJdXTt9f3o1QV9xUaHH7ld8m5V6dFzURKfdDWDXTtTl3(lZDLSyOdUldiwWeRUmWZEo13d6)bb8SbPJ)GupiQgubc7dl5MDmwmi)bPEqUDpiGN9CQVh0)dc4zdsh)b5YLlqy4(YaptMKseXf3o1FD7Vm3vYIHo4UCbcd3xomnMiHvlNldiwWeRUS(gemc)rQbGEQFHPXejSA5miQgeWZEo13d6)bb8SbPJ)GC5Ya6GflJIOXH42P(IlUCH5B)Tt9T)YCxjlg6G7YfimCFzIjSwtksBjfdq5YaIfmXQlR3GIAXD8(5zKL1AsisPHBjS0g494Uswm0GOAqamEbH)1VFEgzzTMeIuA4wclTbEpc7uwlgKRdI2ds3br1Gay8cc)RFkMiesSIujLq)ryNYAXG0zqFDzaDWILrr04qC7uFXTZLB)Llqy4(Y)8mYYAnjeP0WTewAd8Um3vYIHo4U4291T)YCxjlg6G7YaIfmXQlRVbbJWFKAaON6xyAmrcRwodIQbb8Sb5Q)GupiQge3mrJ(GCDq0EJlxGWW9L5MjA2FzTMKx23g5IBh1E7VCbcd3xwXeHqIvKkPe6xM7kzXqhCxC7O9T)YCxjlg6G7YaIfmXQlNKQO8iPcpR1K6FbXYFwd9GW)6lxGWW9LjPcpR1K6FbXYFwdDXTJwU9xM7kzXqhCxgqSGjwDz9niye(Juda9u)eWSUTwtcivZskgGYGOAq6ni9gKEdc4zdsNb91GC7EqamEbH)1pftecjwrQKsO)iStzTyq6miAzq6oiQgKEdc4zdsh)br7b529Gay8cc)RFkMiesSIujLq)ryNYAXG0zqUmiDhKUdYT7bXnt0O)cZHLbw6uFpix9h0xds3lxGWW9LfWSUTwtcivZskgGYf3Un52FzURKfdDWDzaXcMy1LbE2ZP(Eq)piGNniD8hKlxUaHH7lt4pmrWsVI4CXTBtF7Vm3vYIHo4UmGybtS6YapBqU6pOVUCbcd3xg4zYKuIiU429NB)L5Uswm0b3LbelyIvxg4zpN67b9)GaE2G0XFqFD5cegUVSIjcjwrgES8NNfSmmnMCXTt9g3(lZDLSyOdUlxGWW9LdtJjsy1Y5YaIfmXQld8SNt99G(FqapBq64pixgevdsVbPVbf1I745zHeGDsWpURKfdni3UhK(gemc)rQbGEQFHPXejSA5miDVmGoyXYOiACiUDQV42Pw9T)YfimCFzGNj)vF4lZDLSyOdUlUDQD52FzURKfdDWD5cegUVCYQauWPHKIbOCzaXcMy1L13GGr4psna0t9lzvak40qsXaugevdsVbLKQO8sWuKWiyWlf2GC7Eq6nOOwChpplKaStc(XDLSyObr1GGr4psna0t9lmnMiHvlNbr1GaE2GCDqu7G0Dq6EzaDWILrr04qC7uFXfxC5pmry4(25YgQ)ZgBYgBYZLV(IAV8VI0wRjU8FZbgMem0G2KbvGWW9GwMieVr1LHrWk2IVm1h0M3AOF1IctgK(jUPmQO(G8IaMGwVDRMfEPjpa2zRWCsxvy4gqkLyRWCaBhvuFqQsx0hK6nGFqUSH6)mO)h0g)HwVbThvJkQpOnZRAnwqRhvuFq)piQj7G)WdkdJlYG0VQgAq5Gyu4bbWnuy4wmi98QgAXqdkH(GkiiCR7Bur9b9)GOMSd(dpiAv(VpicdWooCdvHH7bP3pBTgucdWo8GQbbJWk6(gvuFq)pOnZRAnEqrr04qAkdkWdcqhSyzuenoeVrf1h0)dIAYo4p8G4MjA0heOGniGhdOmifmzq0kteIbHvgeTkLqFq6jmNbbzkkmHBapitmOM1wMMLSy4husAmiyRI(GGmffMWnGhKjgKW0AtXavh6(gvuFq)piQbeedni9BbpO)wWoIbPxqSMchc4hehGNUVr1OI6dAZ9ndsdgAqjScMWdcGDsQyqjSM1I3GOgaadledQX9)EfXrjDnOcegUfdc3l6Vrvbcd3IhmcdWojv4RSkbLrvbcd3IhmcdWojvqJ)wfmgAuvGWWT4bJWaStsf04VTs1C4oQWW9OI6dk3fmHhogePmObLKQOWqdsevigucRGj8GayNKkgucRzTyqvdniye(Fy4iSwBqMyqq4MFJQcegUfpyegGDsQGg)TIUGj8WHuevigvfimClEWima7Kubn(BHHdd3JQcegUfpyegGDsQGg)TaptMKseb8MIVE6lQf3XtWeUTG(J7kzXqUDRVOwChpftesSIm8y5pplyzyAm5XDLSyiDhvfimClEWima7Kubn(BbEM8x9HhvJkQpOn33minyObXFyc9bfMdpOWJhubcmzqMyq1NYwvYIFJkQpOcegUf(vAGLvefGYOQaHHBbn(BfW4Ii9QgskcIrHhvuFq7XPaVbHvg0FVio1GW9Gay8cc)RHFqMYG2uHXqd6VxeNAqMyqCxjlgAqS(H0AnOapi1BSH(XbHvgKt9T5K6mipUwH3OQaHHBbn(BdCkWtIvKukItbV1bt(ul))Sb8WaH0JRv45VXJ2JkQpOnfCy4EqMYGYmHBlOpimzq5atCGFqBUIeEWpOQHgeTYi8GkcpOuydctgeDC6GkcpisA3wRnibt42c6dQAObvdYPSEqIOIbfeRPWXGGrWab8dctgeDC6GkcpO0gIjdk84bXkkmigewzqjlmgALkc4heMmOOiACmOWC4bf4bbz8GmXG0iCfmzqyYGy9dP1AqbEq0YgJQcegUf04VfgomCdVP4NKQO8emHBlO)sH52DsQIYteyIJKls4jRgsQye(LcZTB90xulUJNGjCBb9h3vYIHOkiwtHJhmcg8knBzb9hHlqORB3jPkkVKfgdTsfXJWfiC7okIghVWCyzGLqg7QpTSXOQaHHBbn(Bb1Ajlqy4wUmraFxoSVGjCBbD4nf)KufLNGjCBb9xkSrvbcd3cA83QyIqIvKHhl)5zbldtJjWBk(6Xnt0O)cZHLbw6uF7QA3U1lQf3XtWeUTG(J7kzXqubW4fe(x)emHBlO)iStzTWvx0vxQaE2ZP((FGNPJ)xJQcegUf04VnmnMiHvlh4b0blwgfrJdHVA4nfF94MjA0FH5WYalDQVDvTB36f1I74jyc3wq)XDLSyiQay8cc)RFcMWTf0Fe2PSw4Ql6Qlvap75uF)pWZ0X3fQ0hmc)rQbGEQFHPXejSA5mQkqy4wqJ)wqTwYcegULlteW3Ld7dGgvuFqBwTwdk84bL3pOcegUh0YeXGmLbfEmHhur4b5YGWKbTyHyqCZoglgvfimClOXFlOwlzbcd3YLjc47YH9fb8MIFbc7dl5MDmw46xJkQpOnRwRbfE8GOg4n3Gkqy4EqltedYugu4XeEqfHh0xdctgKdMWdIB2XyXOQaHHBbn(Bb1Ajlqy4wUmraFxoSFHz4nf)ce2hwYn7ySqh)VgvJkQpiQbimClEud8MBqMyqwhCdXqdsbtguQGh0pl8gK(fdcdiPgqqYnBX1hEqvdniqkHWDSOpOMziXGc8Gs4bHHfMJ9xm0OQaHHBXRWSpXewRjfPTKIbOapGoyXYOiACi8vdVP4RxulUJ3ppJSSwtcrknClHL2aVh3vYIHOcGXli8V(9ZZilR1KqKsd3syPnW7ryNYAHR0wxQay8cc)RFkMiesSIujLq)ryNYAHoFnQkqy4w8kmtJ)2FEgzzTMeIuA4wclTbEJQcegUfVcZ04VLBMOz)L1AsEzFBe4nfF9bJWFKAaON6xyAmrcRwoub8mx9vtf3mrJUR0EJrvbcd3IxHzA83QyIqiXksLuc9rvbcd3IxHzA83ssfEwRj1)cIL)SgcEtXpjvr5rsfEwRj1)cIL)Sg6bH)1JQcegUfVcZ04VvaZ62AnjGunlPyakWBk(6dgH)i1aqp1pbmRBR1Kas1SKIbOqLE6PhWZ05l3Uby8cc)RFkMiesSIujLq)ryNYAHo0IUuPhWZ0XN2UDdW4fe(x)umriKyfPskH(JWoL1cDCrxDD7MBMOr)fMdldS0P(2v)V0DuvGWWT4vyMg)Te(dteS0RioWBk(ap75uF)pWZ0X3Lrvbcd3IxHzA83c8mzskreWBk(apZv)VgvfimClEfMPXFRIjcjwrgES8NNfSmmnMaVP4d8SNt99)apth)VgvfimClEfMPXFByAmrcRwoWdOdwSmkIghcF1WBk(ap75uF)pWZ0X3fQ0tFrT4oEEwibyNe8J7kzXqUDRpye(Juda9u)ctJjsy1Yr3rvbcd3IxHzA83c8m5V6dpQO(Gkqy4w8kmtJ)wLfDR1KcMaJ7qsXauG3u8tsvuEjyksyem4bH)1WBDWeskSWx9OQaHHBXRWmn(BtwfGconKumaf4b0blwgfrJdHVA4nfF9bJWFKAaON6xYQauWPHKIbOqLEjPkkVemfjmcg8sH52TErT4oEEwibyNe8J7kzXqubJWFKAaON6xyAmrcRwoub8mxPwD1DunQO(G2mmEbH)1Irvbcd3IhaY36pykS87uULHhl)5zbldtJjJQcegUfpaen(BtfS0c2b(UCy)pfXQKflTo4wybDPMPvFWRqIfaBTQWAnjHlqGjJQcegUfpaen(BtfS0c2rmQkqy4w8aq04VnzHXqsLuc9rvbcd3IhaIg)TjmrWekwRnQO(G0Vf8GOgeq18G2JjeUJbzkdIooDqfHhKJjewRnOkg0Ilrmi1dAZ8Sbvn0G(H7n1XGafSbXnt0OpOFw4z9G24r7bjyaUHeJQcegUfpaen(BlcOAwgycH7aEtXh4zpN67)bEMo(QPIBMOr)fMdldS0P(wh)nE0EuvGWWT4bGOXF7Y08cHu)tH0C4ogvfimClEaiA83QyeozHXqJQcegUfpaen(BRgWIGuljOwRrvbcd3IhaIg)Tbof4jXksiUcp4nf)OiAC8cZHLbwczSo)zuvGWWT4bGOXFRiWehjxKWtwnKuXim8MIpaJxq4F9teyIJKls4jRgsQye(b8kIgl8DXTB9ay8cc)RFkMiesSIujLq)ryNYAHR(0cvapth)VOcGXli8V(rmH1AsrAlPyakpc7uwlC1xTUUDhfrJJxyoSmWsiJD1xnThvfimClEaiA83kyc3wqhEtXhGXli8V(rmH1AsrAlPyakpc7uwlC13f3UJIOXXlmhwgyjKXU6R2Lrvbcd3IhaIg)TGATKfimClxMiGVlh2NfcUbSyunQkqy4w8yHGBal8b4gWDqQGHKkRYHhvfimClESqWnGf04VnzHXqsSIm8yj3Sd9rvbcd3IhleCdybn(B1slcKvTeRiR)Ij4WBuvGWWT4Xcb3awqJ)wfmivWqY6VyIfSmHlNrvbcd3IhleCdybn(BHLsmf6wRjtwLigvfimClESqWnGf04Vn8yzANGtBiPcMa4rvbcd3IhleCdybn(BjgmylwATuaRa8OQaHHBXJfcUbSGg)T)WKf0h2AjHf4UAapQkqy4w8yHGBalOXFRd7Gj0Lyf5kfyqsicxoc4nfFUzIgDxP2nOkjvr5jcmXrYfj8Kvdjvmc)sHnQgvuFqzMWTf0hemIHjwqFuvGWWT4jyc3wq3NycR1KI0wsXauGhqhSyzuenoe(QH3u8lqyFyj3SJXcx)YTBye(Juda9u)eWSUTwtcivZskgGYOQaHHBXtWeUTGon(BvmriKyfPskHo8MIVEjPkkVKfgdTsfXlfgvWi8hPga6P(rmH1AsrAlPyak662DsQIYtWeUTG(JWoL1cxv72TEfiSpSKB2XyHoQPQaH9HLCZoglCL26oQkqy4w8emHBlOtJ)wbmRBR1Kas1SKIbOaVP4Rpye(Juda9u)eWSUTwtcivZskgGcv6vGW(WsUzhJf64)LB36vGW(WsUzhJf(Uqfmc)rQbGEQFjRcqbNgskgGIU6oQkqy4w8emHBlOtJ)2KvbOGtdjfdqbEaDWILrr04q4REunQkqy4w8eH)ppJSSwtcrknClHL2aVrvbcd3INiOXFlXewRjfPTKIbOapGoyXYOiACi8vdVP4d8mD8P9OQaHHBXte04VvXeHqIvKkPe6JQcegUfprqJ)wIjSwtksBjfdqbEaDWILrr04q4REuvGWWT4jcA83kGzDBTMeqQMLumaf4nfF9bJWFKAaON6NaM1T1AsaPAwsXauOkjvr5bvnGLyfjWZ0F7LcBuvGWWT4jcA83ssfEwRj1)cIL)SgcEtXpjvr5rsfEwRj1)cIL)Sg6bH)1uvGW(WsUzhJf6OEuvGWWT4jcA83s4pmrWsVI4aVP4d8SNt99)apthFxgvfimClEIGg)TkMiKyfz4XYFEwWYW0yc8MIpWZC13Lrvbcd3INiOXFl3mrZ(lR1K8Y(2iWBk(apZv)VOIBMOr3vAVXOQaHHBXte04Vnzvak40qsXauGhqhSyzuenoe(QH3u81hmc)rQbGEQFjRcqbNgskgGcv6bW4fe(x)iMWAnPiTLumaLhHDkRf68LB3apth)V0Lk9ay8cc)RFkMiesSIujLq)ryNYAHouRB3apthFQ1TB9aEMVlubJWFKAaON6xyAmrcRwo6Q7OQaHHBXte04Vf4zYF1hEuvGWWT4jcA83c8mzskreWBk(ap75uF)pWZ0XxnvfiSpSKB2XyHVA3UbE2ZP((FGNPJVlJQcegUfprqJ)2W0yIewTCGhqhSyzuenoe(QH3u81hmc)rQbGEQFHPXejSA5qfWZEo13)d8mD8D5YvA4HjxoBoB2fxCha]] )

end