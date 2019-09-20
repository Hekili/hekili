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

        potion = "unbridled_fury",

        package = "Windwalker",

        strict = false
    } )

    spec:RegisterSetting( "optimize_reverse_harm", false, {
        name = "Optimize |T627486:0|t Reverse Harm",
        desc = "If checked, the |T627486:0|t Reverse Harm's caption will show the recommended target's name.",
        type = "toggle",
        width = 1.5
    } ) 
    
    spec:RegisterPack( "Windwalker", 20190920.1025, [[d0u(kbqiKuEefP2KkPprrsnkuHtHk6vueZcj5wQuSlr9lKOHbuCmk0YqL8mPOMMuextkOTHKk(MuKQXHKQCovk16uPK5rbUNi2hQuhejvAHuqpejv1ePijQlsrsAJaLOpkfjAKaLeNeOewjvPxcusAMsrs3uksODcu9tksImuPiblvkqpfWurcxLIKWxbkPgRuKYEH8xugmOdRyXuvpwvtwfxMyZOQptLgnvCAsRwkGxdKzlv3gP2Ts)gQHlLooqPwoINtPPlCDrA7QeFxLQXlf68uuRNIeZNQy)sgzerbc4mHGaNlWy82G52CbMSrWWvdBcxiGWCRGaANh04kiGDOfeayTUN7thKqqaTJ5oEoikqawCk5feGteT2BrjLUA4K6NFmnLwLoTpHI3Nm8bLwL(Peb4NQ9aSyr(iGZeccCUaJXBdMBZfyYgbdxnSjiaBR8iW5I6CBeGJEoYI8rahX(iatxqWADp3NoiHuWMI4fu510f0jIw7TOKsxnCs9ZpMMsRsN2NqX7tg(GsRs)uwEnDbbK2qO9fsb5cmuvqUaJXBxElVMUGuFNzDf7TkVMUG3uWguOXxKcc0kdPGGvM9uqGGOGKc(49ekETfKdNzpD5uqFZfCoh8YzU8A6cEtbBqHgFrkiyjay1csKhttl7zcfVfKJ7AVxqF5X0sbNc2seEoZLxtxWBki13zwxPGXqCLGP8fmWf8n)DHfdXvcBU8A6cEtbBqHgFrkOScX1Cb)PTGVJ8GkipMuqWs1g2cI5liyzkXCb5WQ0f8O88cr2xkOAl4kUD1v97cvf0pnkyBFmxWJYZlezFPGQTGw1DvE9Nn4mxEnDbVPGu3Zrof0uHvkiyri02cYrq0fKewQkOeFMZmcOR2WIOabe4dIce4gruGaKD87Ybzic4jAieDqacyNQTTYj)M)ooi4vFMFFSrbVwWyiUsKdLwybMDuPGCxWBxWRf8X4(bFFZV5VJdcE1N53hBKjc9ORTGgKuqUqaZhkErabo9DyyE2rMWbfiW5crbcq2XVlhKHiGNOHq0bbqTckGDQ22kN8B(74GGx9z(9Xgf8AbfWovBBLt(quF)UUUmDb1Ipf8AbdLwybMDuPGCxWBxWRfKJcgdXvICO0clWS2pyndMcYDsbn2mykOhpfmgIRe5qPfwGzTFWAgmf0Gcs9kiNiG5dfViGaN(ommp7it4Gce4nJOabi743LdYqeWt0qi6GaOwbfWovBBLt(n)DCqWR(m)(yJcETGuRGcyNQTTYjFiQVFxxxMUGAXNcETGHslSaZoQuqUl4TraZhkErabo9DyyE2rMWbfOabqSG6I1IOabUrefiG5dfViG7okPRRl7qgx8YAt33bbi743LdYquGaNlefiG5dfViaE1gwgMNXNsmJaKD87YbzikqG3mIceGSJFxoidraZhkErae1QRlZMUmq6dcb8eneIoia)uE(SnWeAMmKWHn7HXRejN2wqpEk4JX9d((MV7OKUUUSdzCXlRnDFNmrOhDTf0Gc2eeqmexjykpcafiWBcIceGSJFxoidraprdHOdcWpLNptsTo66YAG5iS76EYh89TGxl48HEryYk0Qyli3f0icy(qXlcGKAD01L1aZry319Gce4nerbcq2XVlhKHiGNOHq0bb8oAMEASG3uW3rli3jfKleW8HIxearUieRWCgcnkqGtDquGaKD87Ybzic4jAieDqaVJwqdskixiG5dfViaE1gmmplCe2DhnewOUcbfiWB6ikqaYo(D5Gmeb8eneIoiG3rlObjfS5cETGYkexZf0Gc2qWGaMpu8IaKviUQPORlt6AJkbfiWPEikqaYo(D5Gmeb8eneIoiaQvWwICH5(NSXSTv3vxx2tMvyG0hubVwq)uE(8z2xyyE27OnGMtBraZhkEra2wDxDDzpzwHbsFqOab(TruGaKD87Ybzicy(qXlcWVppiCAWaPpieWt0qi6GaOwbBjYfM7FYgZ(95bHtdgi9bvWRfKJc(yC)GVVzE1gwgMNXNsmNjc9ORTGCxWMuqpEk47OfK7Kc2Kc6Xtb5OGVJwWKcYvbVwWwICH5(NSXCOUcH1oD6cYzb5ebedXvcMYJaqbcCJGbrbcy(qXlc4Du295IGaKD87YbzikqGB0iIceGSJFxoidraprdHOdc4D0m90ybVPGVJwqUtkOXcETGZh6fHjRqRITGjf0yb94PGVJMPNgl4nf8D0cYDsb5cbmFO4fb8okZpLyduGa3ixikqaYo(D5GmebmFO4fbW3nRRlZkKwzdgi9bHaEIgcrheqlrUWC)t2y2VppiCAWaPpOcETGVJwqUlyZiaDdHqsBdeGruGa3yZikqaYo(D5GmebmFO4fbquRUUmB6YaPpieWt0qi6GaEhntpnwWBk47Of0GcYfcigIRemLhbGce4gBcIceGSJFxoidraZhkEraH6kew70PraprdHOdcGAfSLixyU)jBmhQRqyTtNUGxl47Oz6PXcEtbFhTGCNuqUqaXqCLGP8iauGa3ydruGaKD87Ybzic4jAieDqaiG5dfViaIA11Lztxgi9bHcuGa(dIce4gruGaMpu8Ia09cgKWAmvweGSJFxoidrbcCUquGaMpu8IasTctdH2IaKD87YbzikqG3mIceGSJFxoidra7qliGldrh)UW0nK1QHzMR6oxW9GHTV27tORlJiZhyccy(qXlc4Yq0XVlmDdzTAyM5QUZfCpyy7R9(e66YiY8bMGce4nbrbcy(qXlcWVJXhgFkXmcq2XVlhKHOabEdruGaMpu8Ia8fIviG01fbi743LdYquGaN6GOabi743LdYqeWt0qi6GaEhntpnwWBk47OfK7KcASGxlOScX1CouAHfyg90yb5oPGGj3qeW8HIxeWq(zfwGjezduGaVPJOabmFO4fb0vxNWYAG0JlTSbcq2XVlhKHOabo1drbcy(qXlcGxjIFhJpiazh)UCqgIce43grbcy(qXlcy2xSbz6SF6DeGSJFxoidrbcCJGbrbcq2XVlhKHiG5dfViGF6D28HIxwxTbcOR2GTdTGac8bfiWnAerbcq2XVlhKHiGNOHq0bb8yC)GVVzBGj0mziHdB2dJxjs(DgIRylysb5QGE8uqok4JX9d((M5vByzyEgFkXCMi0JU2cAqsbVDbVwW3rli3jfS5cETGpg3p47B(UJs666YoKXfVS209DYeHE01wqdskOXMuWRf8X4(bFFZbo9DyyE2rMWjte6rxBb5oPG3gmfKZc6XtbdLwybMDuPGgKuqJnSGE8uWdoYbo9DyyE2rMWjte6rxlcy(qXlcWgycntgs4WM9W4vIGce4g5crbcq2XVlhKHiGNOHq0bbCWr(X7lBqMqom((qlm)uYMjc9ORTGgKuqUqaZhkErapEFzdYeYHX3hAbfiWn2mIceW8HIxeGFhJpmmplCeMScTzeGSJFxoidrbcCJnbrbcy(qXlciCew66Jt3dJhtEbbi743LdYquGa3ydruGaMpu8IaAtjkVzDDz(9Xgiazh)UCqgIce4gPoikqaZhkEra84p1kh2ykcrdH5ldncq2XVlhKHOabUXMoIceGSJFxoidraZhkEraT4hKew1uKd7X0TPXekEzh5I(cc4jAieDqahCKdC67WW8SJmHtMi0JUweWo0ccOf)GKWQMICypMUnnMqXl7ix0xqbcCJupefiazh)UCqgIaMpu8IagRZLzflJmMcMWEmz6iGNOHq0bbWrb5OGcyNQTTYj)M)ooi4vFMFFSrbVwWhJ7h89n)M)ooi4vFMFFSrMi0JU2cYDsb5cmfKZc6XtbPwbfWovBBLt(n)DCqWR(m)(yJcYzbVwqok4r8t55ZKXuWe2JjtNDe)uE(8bFFlOhpfKJcsTckGDQ22kN8HO((DDDz6cQfFkOhpfmgIRe5qPfwGzTFWAgmf0Gcs9kiNf8Ab9t55Z2atOzYqch2ShgVsKmrOhDTfK7cAS5c6XtbdLwybMDuPGguqUmwqora7qliGX6CzwXYiJPGjShtMokqGB82ikqaYo(D5Gmeb8eneIoiGhJ7h89ntuRUUmB6YaPpOmrOhDTf0GKcYvb94PGHslSaZoQuqdskOrUqaZhkErawHiRgMrbcCUadIceGSJFxoidraprdHOdcqwH4AUGguWMaMcETG(P88zBGj0mziHdB2dJxjsoTfbmFO4fbql0yIzgMN1tF9WoezOTOaboxgruGaMpu8IaiABBxy6YSTZliazh)UCqgIce4CXfIceGSJFxoidraprdHOdcGJckGDQ22kN8B(74GGx9z(9Xgf8AbFmUFW338B(74GGx9z(9XgzIqp6AlObjfKlWuqolOhpfKAfua7uTTvo5383XbbV6Z87JnqaZhkEraPwHPHqBrbkqaTe5X0(tGOabUrefiG5dfViGwCO4fbi743LdYquGaNlefiazh)UCqgIaEIgcrheahfKAfmMUSr2kez1WCw2XVlNc6XtbPwbJPlBK5vBWW8SWry3D0qyH6kKSSJFxofKteW8HIxeW7Om)uInqbc8MruGaMpu8IaEhLDFUiiazh)UCqgIcuGagSGOabUrefiazh)UCqgIaMpu8IaiQvxxMnDzG0hec4jAieDqaCuWy6Yg57okPRRl7qgx8YAt33jl743LtbVwWhJ7h89nF3rjDDDzhY4IxwB6(ozIqp6AlObfSHfKZcETGpg3p47BMxTHLH5z8PeZzIqp6Ali3fSzeWB(7clgIRewe4grbcCUquGaMpu8IaU7OKUUUSdzCXlRnDFheGSJFxoidrbc8MruGaKD87Ybzic4jAieDqauRGTe5cZ9pzJ5qDfcRD60f8AbFhTGgKuqJf8AbLviUMlObfSHGbbmFO4fbiRqCvtrxxM01gvckqG3eefiG5dfViaE1gwgMNXNsmJaKD87YbzikqG3qefiazh)UCqgIaEIgcrheGFkpFMKAD01L1aZry319Kp47lcy(qXlcGKAD01L1aZry319Gce4uhefiazh)UCqgIaEIgcrhea1kylrUWC)t2y22Q7QRl7jZkmq6dQGxlihfKJcYrbFhTGCxWMlOhpf8X4(bFFZ8QnSmmpJpLyote6rxBb5UGuNcYzbVwqok47OfK7Kc2Wc6XtbFmUFW33mVAdldZZ4tjMZeHE01wqUlixfKZcYzb94PGYkexZ5qPfwGz0tJf0GKc2Cb5ebmFO4fbyB1D11L9Kzfgi9bHce4nDefiazh)UCqgIaEIgcrheW7Oz6PXcEtbFhTGCNuqUqaZhkErae5IqScZzi0Oabo1drbcq2XVlhKHiGNOHq0bb8oAbniPGnJaMpu8IaEhL5NsSbkqGFBefiazh)UCqgIaEIgcrheW7Oz6PXcEtbFhTGCNuWMraZhkEra8QnyyEw4iS7oAiSqDfckqGBemikqaYo(D5GmebmFO4fbeQRqyTtNgb8eneIoiG3rZ0tJf8Mc(oAb5oPGCvWRfKJcsTcgtx2i7Ob7X0(4SSJFxof0JNcsTc2sKlm3)KnMd1viS2PtxqoraV5VlSyiUsyrGBefiWnAerbcy(qXlc4Du295IGaKD87YbzikqGBKlefiazh)UCqgIaMpu8Ia87ZdcNgmq6dcb8eneIoiaQvWwICH5(NSXSFFEq40GbsFqf8Ab5OG(P88zFmiwlb)502c6Xtb5OGX0LnYoAWEmTpol743LtbVwWwICH5(NSXCOUcH1oD6cETGVJwqdkytkiNfKteWB(7clgIRewe4grbkqawHiRgMruGa3iIceGSJFxoidraZhkErae1QRlZMUmq6dcb8eneIoiG5d9IWKvOvXwqdkyZf0JNc2sKlm3)KnMTT6U66YEYScdK(GqaV5VlSyiUsyrGBefiW5crbcq2XVlhKHiGNOHq0bbWrb9t55Z(Dm(0tTroTTGxlylrUWC)t2yMOwDDz20LbsFqfKZc6Xtb9t55ZwHiRgMZeHE01wqdkOXc6Xtb5OGZh6fHjRqRITGCxqJf8AbNp0lctwHwfBbnOGnSGCIaMpu8Ia4vByzyEgFkXmkqG3mIceGSJFxoidraprdHOdcGAfSLixyU)jBmBB1D11L9Kzfgi9bvWRfKJcoFOxeMScTk2cYDsbBUGE8uqok48HEryYk0Qylysb5QGxlylrUWC)t2y2VppiCAWaPpOcYzb5ebmFO4fbyB1D11L9Kzfgi9bHce4nbrbcq2XVlhKHiG5dfVia)(8GWPbdK(GqaV5VlSyiUsyrGBefOabydefiWnIOabmFO4fbC3rjDDDzhY4IxwB6(oiazh)UCqgIce4CHOabi743LdYqeW8HIxearT66YSPldK(GqaprdHOdc4D0cYDsbBic4n)DHfdXvclcCJOabEZikqaZhkEra8QnSmmpJpLygbi743LdYquGaVjikqaYo(D5GmebmFO4fbquRUUmB6YaPpieWB(7clgIRewe4grbc8gIOabi743LdYqeWt0qi6Ga8t55ZKuRJUUSgyoc7UUN8bFFl41coFOxeMScTk2cYDbnIaMpu8IaiPwhDDznWCe2DDpOabo1brbcq2XVlhKHiGNOHq0bb8oAMEASG3uW3rli3jfKleW8HIxearUieRWCgcnkqG30ruGaKD87Ybzic4jAieDqaVJwqdskixiG5dfViaE1gmmplCe2DhnewOUcbfiWPEikqaYo(D5Gmeb8eneIoiG3rlObjfS5cETGYkexZf0Gc2qWGaMpu8IaKviUQPORlt6AJkbfiWVnIceGSJFxoidraprdHOdcGAfSLixyU)jBmBB1D11L9Kzfgi9bvWRf0pLNpFM9fgMN9oAdO50weW8HIxeGTv3vxx2tMvyG0hekqGBemikqaYo(D5GmebmFO4fb43NheonyG0hec4jAieDqauRGTe5cZ9pzJz)(8GWPbdK(Gk41cYrbFmUFW33mrT66YSPldK(GYeHE01wqUlyZf0JNc(oAb5oPGnxqol41cYrbFmUFW33mVAdldZZ4tjMZeHE01wqUlytkOhpf8D0cYDsbBsb94PGCuW3rlysb5QGxlylrUWC)t2youxHWANoDb5SGCIaIH4kbt5raOabUrJikqaZhkEraVJYUpxeeGSJFxoidrbcCJCHOabi743LdYqeWt0qi6GaEhntpnwWBk47OfK7KcASGxl48HEryYk0QylysbnwqpEk47Oz6PXcEtbFhTGCNuqUqaZhkEraVJY8tj2afiWn2mIceGSJFxoidraZhkEraH6kew70PraprdHOdcGAfSLixyU)jBmhQRqyTtNUGxl47Oz6PXcEtbFhTGCNuqUqaV5VlSyiUsyrGBefOabCe(jThikqGBerbcy(qXlcW2kdH5m7HzdIcsqaYo(D5GmefiW5crbcq3qixMoc42Gbb0(bZrME4GaatUHiG5dfViGaN(ommpd0qOheGSJFxoidrbc8MruGaKD87Ybzic4jAieDqa(P88zRqKvdZ502c6Xtb9t55Z2atOzYqch2ShgVsKCABb94PGCuqQvWy6YgzRqKvdZzzh)UCk41cgeDbjrULG)84QDnmNjY8rb5SGE8uq)uE(SFhJp9uBKjY8rb94PGXqCLihkTWcm7OsbniPGuhWGaMpu8IaAXHIxuGaVjikqaYo(D5Gmeb8eneIoia)uE(SviYQH5CAlcy(qXlc4NENnFO4L1vBGa6Qny7qliaRqKvdZOabEdruGaKD87Ybzic4jAieDqaCuqzfIR5CO0clWm6PXcAqbnwqpEkihfmMUSr2kez1WCw2XVlNcETGpg3p47B2kez1WCMi0JU2cAqb5QGCwqol41c(oAMEASG3uW3rli3jfKleW8HIxearUieRWCgcnkqGtDquGaKD87Ybzic4jAieDqaCuqzfIR5CO0clWm6PXcAqbnwqpEkihfmMUSr2kez1WCw2XVlNcETGpg3p47B2kez1WCMi0JU2cAqb5QGCwqpEkihfuwH4AohkTWcmJEASGguWMuWRf8X4(bFFZ8QnSmmpJpLyote6rxBbnOGgZnSGCwqol41c(oAMEASG3uW3rli3jfSzeW8HIxeaVAdgMNfoc7UJgcluxHGce4nDefiazh)UCqgIaMpu8Iac1viS2PtJaEIgcrheahfuwH4AohkTWcmJEASGguqJf0JNcYrbJPlBKTcrwnmNLD87YPGxl4JX9d((MTcrwnmNjc9ORTGguqUkiNf0JNcYrbLviUMZHslSaZONglObfSjf8AbFmUFW33mVAdldZZ4tjMZeHE01wqdkOXCdliNfKZcETGVJMPNgl4nf8D0cYDsb5QGxli1kylrUWC)t2youxHWANoncigIRemLhbGce4upefiazh)UCqgIaMpu8Ia(P3zZhkEzD1giGUAd2o0cc4pOab(TruGaKD87Ybzic4jAieDqaZh6fHjRqRITGguWMl41coMIq0qY4wzzTtNMzdIcsSzzh)UCk41csTcoMIq0qYUDmXmdZZchHDM7Bw2XVlheW8HIxeWp9oB(qXlRR2ab0vBW2HwqaelOUyTOabUrWGOabi743LdYqeWt0qi6GaMp0lctwHwfBbnOGnJaMpu8Ia(P3zZhkEzD1giGUAd2o0ccWgOabUrJikqaYo(D5Gmeb8eneIoiG5d9IWKvOvXwqUtkyZiG5dfViGF6D28HIxwxTbcOR2GTdTGagSGcuGceWfHyv8IaNlWy82G52CbgeW9HS66AraG1u3geCWcWBkVvblifosbv6wmjkipMuqtnXcQlwRPUGebStvICkOftlfCsdm9eYPGVZSUInxEBQ6kfS5BvWguOXxKtbP19wnTc(oYdQGCS4OGZLr7JFxkOUfuOt7tO4LZcEZnfKdJnYzU82u1vk4TVvbBqHgFrofKw3B10k47ipOcYXIJcoxgTp(DPG6wqHoTpHIxol4n3uqom2iN5YBtvxPGgB(wfSbfA8f5uqADVvtRGVJ8Gkihlok4Cz0(43LcQBbf60(ekE5SG3Ctb5WyJCMlVnvDLcASj3QGnOqJViNcsR7TAAf8DKhub5yXrbNlJ2h)UuqDlOqN2NqXlNf8MBkihgBKZC5TPQRuqJn8wfSbfA8f5uqADVvtRGVJ8Gkihlok4Cz0(43LcQBbf60(ekE5SG3Ctb5WyJCMlVLxWAQBdcoyb4nL3QGfKchPGkDlMefKhtkOP(i8tApm1fKiGDQsKtbTyAPGtAGPNqof8DM1vS5YBtvxPGn9BvWguOXxKtbP19wnTc(oYdQGCS4OGZLr7JFxkOUfuOt7tO4LZcEZnfKdJnYzU8wEbRPUni4GfG3uERcwqkCKcQ0TysuqEmPGMAByQlira7uLiNcAX0sbN0atpHCk47mRRyZL3MQUsbncMBvWguOXxKtbP19wnTc(oYdQGCS4OGZLr7JFxkOUfuOt7tO4LZcEZnfKdJnYzU8wEblOBXKqofK6vW5dfVfSR2WMlViGwcMx7ccW0feSw3Z9PdsifSPiEbvEnDbDIO1ElkP0vdNu)8JPP0Q0P9ju8(KHpO0Q0pLLxtxqaPneAFHuqUadvfKlWy82L3YRPli13zwxXERYRPl4nfSbfA8fPGaTYqkiyLzpfeiikiPGpEpHIxBb5Wz2txof03CbNZbVCMlVMUG3uWguOXxKccwcawTGe5X00YEMqXBb54U27f0xEmTuWPGTeHNZC510f8Mcs9DM1vkymexjykFbdCbFZFxyXqCLWMlVMUG3uWguOXxKckRqCnxWFAl47ipOcYJjfeSuTHTGy(ccwMsmxqoSkDbpkpVqK9LcQ2cUIBxDv)Uqvb9tJc22hZf8O88cr2xkOAlOvDxLx)zdoZLxtxWBki19CKtbnvyLccwecTTGCeeDbjHLQckXN5mxElVMUGMQnkFAiNc6l8yIuWht7prb9fxDT5csD)xAdBbx8EJZqO5t7fC(qXRTG4TBoxEnDbNpu8AZTe5X0(tKW3hlOYRPl48HIxBULipM2FctsOKhJpLxtxW5dfV2ClrEmT)eMKq5K6slBmHI3YRPliWoTwhCuqYONc6NYZlNcAJjSf0x4XePGpM2FIc6lU6Al4SNc2sKBAXrORBbvBbp4vYLxtxW5dfV2ClrEmT)eMKqPDNwRdoy2ycB5D(qXRn3sKht7pHjju2IdfVL35dfV2ClrEmT)eMKq57Om)uInOs5t4GAX0LnYwHiRgMZYo(D54Xd1IPlBK5vBWW8SWry3D0qyH6kKSSJFxoCwENpu8AZTe5X0(tyscLVJYUpxKYB510f0uTr5td5uq5IqmxWqPLcgosbNpWKcQ2coxgTp(DjxEnDbNpu8AtM0aZMiMhu5D(qXR1KekTTYqyoZEy2GOGKY78HIxRjjug403HH5zGgc9qLUHqUm9KBdgQA)G5itpCsatUHLxtxWMc4qXBbv(cciez1WCbXKcceycnvf0uDiHdvfC2tbblvIuWHifmTTGysbnJtl4qKcss3vx3cAfISAyUGZEk4uq6r3cAJjkyq0fKefSLGFlvfetkOzCAbhIuW09iKcgosbfEE5JcI5lOFhJp9uBqvbXKcgdXvIcgkTuWaxWJkfuTf0LitiKcIjfua70PxWaxqQdykVZhkETMKqzlou8sLYN4NYZNTcrwnmNtB94XpLNpBdmHMjdjCyZEy8krYPTE8Wb1IPlBKTcrwnmNLD87Y5Aq0fKe5wc(ZJR21WCMiZhC6XJFkpF2VJXNEQnYez(WJNyiUsKdLwybMDuXGeQdykVZhkETMKq5p9oB(qXlRR2GQDOLeRqKvdZuP8j(P88zRqKvdZ502Y78HIxRjjusKlcXkmNHqtLYNWHScX1CouAHfyg90Obg94HJy6YgzRqKvdZzzh)UCU(yC)GVVzRqKvdZzIqp6AnGlo5867Oz6PXBEhL7eUkVZhkETMKqjVAdgMNfoc7UJgcluxHqLYNWHScX1CouAHfyg90Obg94HJy6YgzRqKvdZzzh)UCU(yC)GVVzRqKvdZzIqp6AnGlo94HdzfIR5CO0clWm6PrdAY1hJ7h89nZR2WYW8m(uI5mrOhDTgym3qo5867Oz6PXBEhL7KMlVZhkETMKqzOUcH1oDAQIH4kbt5tO19whXpLNptpeqmmplCe2tMvYeHE01sLYNWHScX1CouAHfyg90Obg94HJy6YgzRqKvdZzzh)UCU(yC)GVVzRqKvdZzIqp6AnGlo94HdzfIR5CO0clWm6PrdAY1hJ7h89nZR2WYW8m(uI5mrOhDTgym3qo5867Oz6PXBEhL7eUUsTwICH5(NSXCOUcH1oD6Y78HIxRjju(tVZMpu8Y6QnOAhAj5pLxtxqQ)07fmCKc2GaGvBQI1wW5dfVfSR2OGkFbnvQv2c2uy60feiikiXAQlOAlOSJFxouvWzpfSPSJjMliMVGHJuqtLN70MABbjZcQGQTGlokOSJFxoL35dfVwtsO8NENnFO4L1vBq1o0scXcQlwlvkFY8HEryYk0QynO5RJPienKmUvww70Pz2GOGeBw2XVlNRuBmfHOHKD7yIzgMNfoc7m33SSJFxoLxtxqQ)07fmCKccqrbNpu8wWUAJcQ8fmCeIuWHifKRcIjfSlwBbLvOvXwENpu8AnjHYF6D28HIxwxTbv7qlj2GkLpz(qVimzfAvSg0C510fK6p9EbdhPGuxSPAbNpu8wWUAJcQ8fmCeIuWHifS5cIjfKgtKckRqRIT8oFO41AscL)07S5dfVSUAdQ2HwsgSqLYNmFOxeMScTkwUtAU8wEnDbPUFO41MPUyt1cQ2cQBi7rofKhtkyQvk4DnCkiyf5d9zu3ZHr97YCrk4SNc(PeISr3Cbxro2cg4c6lfe3gkTAkYP8oFO41MhSKquRUUmB6YaPpiQEZFxyXqCLWMyKkLpHJy6Yg57okPRRl7qgx8YAt33jl743LZ1hJ7h89nF3rjDDDzhY4IxwB6(ozIqp6AnOHCE9X4(bFFZ8QnSmmpJpLyote6rxl3nxENpu8AZdwmjHY7okPRRl7qgx8YAt33P8oFO41MhSyscLYkex1u01LjDTrLqLYNqTwICH5(NSXCOUcH1oD6RVJAqIXRYkexZg0qWuENpu8AZdwmjHsE1gwgMNXNsmxENpu8AZdwmjHssQ1rxxwdmhHDx3dvkFIFkpFMKAD01L1aZry319Kp47B5D(qXRnpyXKekTT6U66YEYScdK(GOs5tOwlrUWC)t2y22Q7QRl7jZkmq6d6khCWX7OC3Shppg3p47BMxTHLH5z8PeZzIqp6A5M6W5voEhL7Kg6XZJX9d((M5vByzyEgFkXCMi0JUwU5Ito94rwH4AohkTWcmJEA0GKM5S8oFO41MhSyscLe5IqScZzi0uP8jVJMPNgV5DuUt4Q8oFO41MhSyscLVJY8tj2GkLp5DudsAU8oFO41MhSyscL8QnyyEw4iS7oAiSqDfcvkFY7Oz6PXBEhL7KMlVZhkET5blMKqzOUcH1oDAQEZFxyXqCLWMyKkLp5D0m904nVJYDcxx5GAX0LnYoAWEmTpol743LJhpuRLixyU)jBmhQRqyTtNMZY78HIxBEWIjju(ok7(CrkVMUGZhkET5blMKqjF3SUUmRqALnyG0hevkFIFkpF2hdI1sWF(GVVuPBiesABKyS8oFO41MhSyscL(95bHtdgi9br1B(7clgIRe2eJuP8juRLixyU)jBm73NheonyG0h0vo8t55Z(yqSwc(ZPTE8WrmDzJSJgSht7JZYo(D5CTLixyU)jBmhQRqyTtN(67Og0eo5S8wEnDbP(yC)GVV2Y78HIxB(pj6EbdsynMkllCe2DhnewOUcP8oFO41M)JjjuMAfMgcTT8oFO41M)JjjuMAfMgcnv7qljxgIo(DHPBiRvdZmx1DUG7bdBFT3NqxxgrMpWKY78HIxB(pMKqPFhJpm(uI5Y78HIxB(pMKqPVqScbKUULxtxqtfwPGuxYpRuqkWeISrbv(cAgNwWHifKwTwDDl4efSlJnkOXcs9D0co7PG3XRPok4pTfuwH4AUG31Wr3ccMCdlOvE8ESL35dfV28FmjHYH8ZkSatiYguP8jVJMPNgV5DuUtmEvwH4AohkTWcmJEAK7eWKBy5D(qXRn)htsOSRUoHL1aPhxAzJY78HIxB(pMKqjVse)ogFkVZhkET5)yscLZ(InitN9tVxENpu8AZ)XKek)P3zZhkEzD1guTdTKe4t5D(qXRn)htsO0gycntgs4WM9W4vIqLYN8yC)GVVzBGj0mziHdB2dJxjs(DgIRyt4YJhoEmUFW33mVAdldZZ4tjMZeHE01AqYTV(ok3jnF9X4(bFFZ3Dusxxx2HmU4L1MUVtMi0JUwdsm2KRpg3p47BoWPVddZZoYeozIqp6A5o52GHtpEcLwybMDuXGeJn0JNdoYbo9DyyE2rMWjte6rxB5D(qXRn)htsO8X7lBqMqom((qluP8jhCKF8(YgKjKdJVp0cZpLSzIqp6AniHRY78HIxB(pMKqPFhJpmmplCeMScT5Y78HIxB(pMKqz4iS01hNUhgpM8s5D(qXRn)htsOSnLO8M11L53hBuENpu8AZ)XKek5XFQvoSXueIgcZxg6Y78HIxB(pMKqzQvyAi0uTdTK0IFqsyvtroSht3MgtO4LDKl6luP8jhCKdC67WW8SJmHtMi0JU2Y78HIxB(pMKqzQvyAi0uTdTKmwNlZkwgzmfmH9yY0Ps5t4GdbSt12w5KFZFhhe8QpZVp246JX9d((MFZFhhe8QpZVp2ite6rxl3jCbgo94HAcyNQTTYj)M)ooi4vFMFFSbNx54i(P88zYykyc7XKPZoIFkpF(GVVE8Wb1eWovBBLt(quF)UUUmDb1IpE8edXvICO0clWS2pyndgdOECE1pLNpBdmHMjdjCyZEy8krYeHE01YTXM94juAHfy2rfd4YiNL35dfV28FmjHsRqKvdZuP8jpg3p47BMOwDDz20LbsFqzIqp6AniHlpEcLwybMDuXGeJCvENpu8AZ)XKekPfAmXmdZZ6PVEyhIm0wQu(ezfIRzdAcyU6NYZNTbMqZKHeoSzpmELi502Y78HIxB(pMKqjrBB7ctxMTDEP8oFO41M)JjjuMAfMgcTLkLpHdbSt12w5KFZFhhe8QpZVp246JX9d((MFZFhhe8QpZVp2ite6rxRbjCbgo94HAcyNQTTYj)M)ooi4vFMFFSr5T8oFO41MjwqDXAtU7OKUUUSdzCXlRnDFNY78HIxBMyb1fR1Kek5vByzyEgFkXC5D(qXRntSG6I1AscLe1QRlZMUmq6dIQyiUsWu(eADV1r8t55Z0dbedZZchH9KzLmrOhDTuP8j(P88zBGj0mziHdB2dJxjsoT1JNhJ7h89nF3rjDDDzhY4IxwB6(ozIqp6AnOjL35dfV2mXcQlwRjjussTo66YAG5iS76EOs5t8t55ZKuRJUUSgyoc7UUN8bFFVoFOxeMScTkwUnwENpu8AZelOUyTMKqjrUieRWCgcnvkFY7Oz6PXBEhL7eUkVZhkETzIfuxSwtsOKxTbdZZchHD3rdHfQRqOs5tEh1GeUkVZhkETzIfuxSwtsOuwH4QMIUUmPRnQeQu(K3rniP5RYkexZg0qWuENpu8AZelOUyTMKqPTv3vxx2tMvyG0hevkFc1AjYfM7FYgZ2wDxDDzpzwHbsFqx9t55ZNzFHH5zVJ2aAoTT8oFO41MjwqDXAnjHs)(8GWPbdK(GOkgIRemLpHw3BDe)uE(m9qaXW8SWrypzwjte6rxlvkFc1AjYfM7FYgZ(95bHtdgi9bDLJhJ7h89nZR2WYW8m(uI5mrOhDTC3epEEhL7KM4XdhVJMW11wICH5(NSXCOUcH1oDAo5S8oFO41MjwqDXAnjHY3rz3Nls5D(qXRntSG6I1AscLVJY8tj2GkLp5D0m904nVJYDIXRZh6fHjRqRInXOhpVJMPNgV5DuUt4Q8oFO41MjwqDXAnjHs(UzDDzwH0kBWaPpiQu(KwICH5(NSXSFFEq40GbsFqxFhL7MPs3qiK02iXy5D(qXRntSG6I1AscLe1QRlZMUmq6dIQyiUsWu(eADV1r8t55Z0dbedZZchH9KzLmrOhDTuP8jVJMPNgV5Dud4Q8oFO41MjwqDXAnjHYqDfcRD60ufdXvcMYNqR7ToIFkpFMEiGyyEw4iSNmRKjc9ORLkLpHATe5cZ9pzJ5qDfcRD60xFhntpnEZ7OCNWv5D(qXRntSG6I1AscLe1QRlZMUmq6dIQyiUsWu(eADV1r8t55Z0dbedZZchH9KzLmrOhDTL3YRPliGqKvdZfSLOyIgMlVZhkETzRqKvdZje1QRlZMUmq6dIQ383fwmexjSjgPs5tMp0lctwHwfRbn7XtlrUWC)t2y22Q7QRl7jZkmq6dQ8oFO41MTcrwnmBscL8QnSmmpJpLyMkLpHd)uE(SFhJp9uBKtBV2sKlm3)KnMjQvxxMnDzG0heNE84NYZNTcrwnmNjc9OR1aJE8WX8HEryYk0Qy52415d9IWKvOvXAqd5S8oFO41MTcrwnmBscL2wDxDDzpzwHbsFquP8juRLixyU)jBmBB1D11L9Kzfgi9bDLJ5d9IWKvOvXYDsZE8WX8HEryYk0Qyt46AlrUWC)t2y2VppiCAWaPpio5S8oFO41MTcrwnmBscL(95bHtdgi9br1B(7clgIRe2eJL3Y78HIxB2gj3Dusxxx2HmU4L1MUVt5D(qXRnBdtsOKOwDDz20LbsFqu9M)UWIH4kHnXivkFY7OCN0WY78HIxB2gMKqjVAdldZZ4tjMlVZhkETzByscLe1QRlZMUmq6dIQ383fwmexjSjglVZhkETzByscLKuRJUUSgyoc7UUhQu(e)uE(mj16ORlRbMJWUR7jFW33RZh6fHjRqRILBJL35dfV2SnmjHsICriwH5meAQu(K3rZ0tJ38ok3jCvENpu8AZ2WKek5vBWW8SWry3D0qyH6keQu(K3rniHRY78HIxB2gMKqPScXvnfDDzsxBujuP8jVJAqsZxLviUMnOHGP8oFO41MTHjjuAB1D11L9Kzfgi9brLYNqTwICH5(NSXSTv3vxx2tMvyG0h0v)uE(8z2xyyE27OnGMtBlVZhkETzByscL(95bHtdgi9brvmexjykFcTU36i(P88z6HaIH5zHJWEYSsMi0JUwQu(eQ1sKlm3)KnM97ZdcNgmq6d6khpg3p47BMOwDDz20LbsFqzIqp6A5UzpEEhL7KM58khpg3p47BMxTHLH5z8PeZzIqp6A5UjE88ok3jnXJhoEhnHRRTe5cZ9pzJ5qDfcRD60CYz5D(qXRnBdtsO8Du295IuENpu8AZ2WKekFhL5NsSbvkFY7Oz6PXBEhL7eJxNp0lctwHwfBIrpEEhntpnEZ7OCNWv5D(qXRnBdtsOmuxHWANonvV5VlSyiUsytmsLYNqTwICH5(NSXCOUcH1oD6RVJMPNgV5DuUt4Q8A6coFO41MTHjjuY3nRRlZkKwzdgi9brLYN0sKlm3)KnM97ZdcNgmq6d667OC3mv6gcHK2gjglVL35dfV2CGpjbo9DyyE2rMWHkLpra7uTTvo5383XbbV6Z87JnUgdXvICO0clWSJkCF7Rpg3p47B(n)DCqWR(m)(yJmrOhDTgKWv5D(qXRnh4Jjjug403HH5zhzchQu(eQjGDQ22kN8B(74GGx9z(9XgxfWovBBLt(quF)UUUmDb1IpxdLwybMDuH7BFLJyiUsKdLwybM1(bRzWWDIXMbJhpXqCLihkTWcmR9dwZGXaQhNL35dfV2CGpMKqzGtFhgMNDKjCOs5tOMa2PABRCYV5VJdcE1N53hBCLAcyNQTTYjFiQVFxxxMUGAXNRHslSaZoQW9TratA4GjiaaLM6JcuGq]] )

end