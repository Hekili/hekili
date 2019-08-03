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
        name = "Optimize |T627486:0|t Reverse Harm Target",
        desc = "If checked, the |T627486:0|t Reverse Harm's caption will show the recommended target's name.",
        type = "toggle",
        width = 1.5
    } ) 
    
    spec:RegisterPack( "Windwalker", 20190803, "dO0(YaqiQK8ivQ6sQKKYMGu(KkjjnksOtrQ4virZcs1TuPYUuQFPImmvsDms0YqQ6zQatdPsUgPsTnsL03qQunosLW5qQW6qQuMhvI7rvTpsWbvjHfIeEOkj6IQKeBKuj6JQKKyKujfojsfLvsQ6LivKUjsfHDQIAOQKKQLsLu6Ps1uvjUkvsrFfPIQ9QQ)s0GbDyjlwkEmWKH4YO2mj9zsz0uLttz1ujvVgjnBLCBQy3I(nIHdjhhPIOLd1ZjmDHRlL2Uk03vPmEvqNhPSEvsQ5tLA)k(v(x(osf8FM(RvshxRlU(GTsDt)10FW3dAO4VJQauln(7z5WFNo3sKB1IkJ)oQI2Iui)LVliTya)DViqjOBNoPzHxBZgqCojmN2vfgjb4snojmhWPV30ARGol)MVJub)NP)AL0X16IRpyRu30FTs667cum4ptVUshF3Zqq48B(oclaF)(bsNBjYTArLXdKobjPo6VFGErGsq3oDsZcV2MnG4CsyoTRkmscWLACsyoGtJ(7h4v0Q1kIbEa6dK(Rvshd8UbQ8A6210XOF0F)aVsVk1ybDB0F)aVBGUw2HCKhyhfx4b6AujYa7b2OYdeqsKWiPyGk6vjYIrgydTbwiiKuN9O)(bE3aDTSd5ipqDzNoDGygqCC4ePcJKduXB2AnWggqC4bwdefMv1zp6VFG3nWR0RsnEGrH14qAQdmideqdSyzuynoe7r)9d8Ub6AzhYrEGCYynAdeuOgiWJbuhOkbpqDPjcXajQdux2IPnqffMZarmvvgZjGhOjgyYAltZAwm6dSPngiQvrBGiMQkJ5eWd0eduyAPPAGkdD2J(7h4Dd8kqqyKb6Ak4bsNfSJyGkgylPYHa9bYbyRZ(7lteI)Y3zHGtal(l)zL)LVxGWi53bKeWzGRGrKQRYH)oNvZIrEk(4pt)F57fims(9MfHGijQYWJLCYo0(oNvZIrEk(4pFWF57fims(DT2cJyvkjQY6Qzmj8(oNvZIrEk(4ptx)LVxGWi53vjGwbJiRRMXwWYgUC(oNvZIrEk(4pR7)Y3lqyK87OAXMknl1KnRseFNZQzXipfF8N11)Y3lqyK87HhlBZgsBIivjya)DoRMfJ8u8XFMU)x(EbcJKFhBOqTyPLsbQcWFNZQzXipfF8N1f)LVxGWi53VrWlKJSLsmlizLa(7Cwnlg5P4J)mD8x(oNvZIrEk(oaBbJT67CYynAd0Lbsxxpq0gytRQ6weeSJKlC4jRerQAyE3I67fims(Dh2HGPjjQYvlWqKiyUCeF8X3bi)L)SY)Y3lqyK87wEKqLLh2Y535SAwmYtXh)z6)lFVaHrYV3kyPfSJ47Cwnlg5P4J)8b)LVZz1SyKNIVNLd)9Jf2QMflTm4uybnPMPvhjRqseaBTQWsnjMlqqWFVaHrYVFSWw1SyPLbNclOj1mT6izfsIayRvfwQjXCbcc(J)mD9x(EbcJKFVzriis1wmTVZz1SyKNIp(Z6(V89cegj)EdJfmMQLAFNZQzXipfF8N11)Y35SAwmYtX3bylySvFh4zBN6WbE3abE2avWFGkhiAdKtgRrBhMdldI0PoCGk4pWR36(7fims(9cdQKLbbJ5m(4pt3)lFVaHrYVVmnVqiD9wenhoJVZz1SyKNIp(Z6I)Y3lqyK87QgMBwecY35SAwmYtXh)z64V89cegj)ELawe4Ajb1A9DoRMfJ8u8XFw51)LVZz1SyKNIVdWwWyR(Euyno2H5WYGirmEGkmq647fims(9G0c8KevjcxH3h)zLk)lFNZQzXipfFhGTGXw9DaHSqi3YTiiyhjx4WtwjIu1W8g4vynwmq)bs)aD7EGkoqaHSqi3YTQjcHKOkvBX02y2PSumqx8hOUoq0giWZgOc(d8GbI2abeYcHCl3ytyPMu0MsQgG6gZoLLIb6I)avoqDgOB3dmkSgh7WCyzqKigpqx8hOsD)9cegj)Uiiyhjx4WtwjIu1W8h)zL0)x(oNvZIrEk(oaBbJT67aczHqULBSjSutkAtjvdqDJzNYsXaDXFG0pq3Uhyuyno2H5WYGirmEGU4pqL0)9cegj)UGXCAbTp(Zkp4V8DoRMfJ8u89cegj)oOwlzbcJKYLjIVVmriZYH)oleCcyXhF8DuygqCAQ4V8Nv(x(EbcJKFhfjms(DoRMfJ8u8XFM()Y35SAwmYtX3bylySvFxXb6Qbg1IZylymNwqBZz1SyKb629aD1aJAXzSvnrijQYWJL38SGLHPX4nNvZIrgOoFVaHrYVd8mztlweF8Np4V89cegj)oWZK3QJ835SAwmYtXhF8DbJ50cA)L)SY)Y35SAwmYtX3lqyK87ytyPMu0MsQgG63bylySvFVaHDKLCYoglgOld8Gb629arH5JsnaYw5wGYY0snjaxjlPAaQFhqdSyzuynoe)zLF8NP)V8DoRMfJ8u8Da2cgB13vCGnTQQ7MfHGSAfXUf1arBGOW8rPgazRCJnHLAsrBkPAaQduNb629aBAvv3cgZPf02y2PSumqxgOYb629avCGfiSJSKt2XyXavyGkhiAdSaHDKLCYoglgOldu3duNVxGWi53vnriKevPAlM2h)5d(lFNZQzXipfFhGTGXw9Dxnquy(OudGSvUfOSmTutcWvYsQgG6arBGkoWce2rwYj7ySyGk4pWdgOB3duXbwGWoYsozhJfd0FG0pq0gikmFuQbq2k3nRcqL0gsQgG6a1zG689cegj)UaLLPLAsaUsws1au)4ptx)LVZz1SyKNIVxGWi53BwfGkPnKuna1VdObwSmkSghI)SYp(47iSA1UI)YFw5F57fims(DbkUWsVkrKIaBu5VZz1SyKNIp(Z0)x(ULbJpwRVthx)DuGq6X1k8((1BD)9cegj)EqAbEsIQKAHDQVZz1SyKNIp(Zh8x(oNvZIrEk(oaBbJT67nTQQBbJ50cA7wud0T7b20QQUfbb7i5chEYkrKQgM3TOgOB3duXb6Qbg1IZylymNwqBZz1SyKbI2adSLu5yJcta7sZwwqBJ5ceduNb629aBAvv3nlcbz1kInMlqmq3Uhyuyno2H5WYGirmEGU4pqD96VxGWi53rrcJKF8NPR)Y35SAwmYtX3bylySvFVPvvDlymNwqB3I67fims(DqTwYcegjLlteFFzIqMLd)DbJ50cAF8N19F57Cwnlg5P47aSfm2QVR4a5KXA02H5WYGiDQdhOldu5aD7EGkoWOwCgBbJ50cABoRMfJmq0giGqwiKB5wWyoTG2gZoLLIb6YaPFG6mqDgiAde4zBN6WbE3abE2avWFG0)9cegj)oMpYybl9kSZh)zD9V8DoRMfJ8u8Da2cgB13vCGCYynA7WCyzqKo1Hd0LbQCGUDpqfhyuloJTGXCAbTnNvZIrgiAdeqileYTClymNwqBJzNYsXaDzG0pqDgOodeTbc8STtD4aVBGapBGk4pWd(EbcJKFx1eHKOkdpwEZZcwgMgJ)4pt3)lFNZQzXipfFVaHrYVhMgJLOQLZ3bylySvFxXbYjJ1OTdZHLbr6uhoqxgOYb629avCGrT4m2cgZPf02CwnlgzGOnqaHSqi3YTGXCAbTnMDklfd0Lbs)a1zG6mq0giWZ2o1Hd8Ubc8SbQG)aPFGOnqxnquy(OudGSvUdtJXsu1Y57aAGflJcRXH4pR8J)SU4V8DoRMfJ8u89cegj)oOwlzbcJKYLjIVVmriZYH)oa5J)mD8x(oNvZIrEk(oaBbJT67fiSJSKt2XyXaDzGh89cegj)oOwlzbcJKYLjIVVmriZYH)Ui(4pR86)Y35SAwmYtX3bylySvFVaHDKLCYoglgOc(d8GVxGWi53b1AjlqyKuUmr89Ljczwo83lc)XhFxe)L)SY)Y3lqyK8738m8YsnjcU0iPevBc8(oNvZIrEk(4pt)F57Cwnlg5P47fims(DSjSutkAtjvdq97aSfm2QVd8SbQG)a193b0alwgfwJdXFw5h)5d(lFVaHrYVRAIqijQs1wmTVZz1SyKNIp(Z01F57Cwnlg5P47fims(DSjSutkAtjvdq97aAGflJcRXH4pR8J)SU)lFNZQzXipfFhGTGXw99Mwv1nUv4zPM01lewEZsKnc5woq0gybc7il5KDmwmqfgOYVxGWi53XTcpl1KUEHWYBwI8XFwx)lFNZQzXipfFhGTGXw9DGNTDQdh4Dde4zdub)bs)3lqyK87y(iJfS0RWoF8NP7)LVZz1SyKNIVdWwWyR(oWZgOl(dK(VxGWi53vnrijQYWJL38SGLHPX4p(Z6I)Y35SAwmYtX3bylySvFh4zd0f)bEWarBGCYynAd0LbQ7R)EbcJKFNtgRzxTLAsEzhA4p(Z0XF57Cwnlg5P47aSfm2QV7QbIcZhLAaKTYTaLLPLAsaUsws1auhiAdSPvvDJujGLevjWZCDB3I67fims(Dbkltl1KaCLSKQbO(XFw51)LVZz1SyKNIVxGWi53BwfGkPnKuna1VdWwWyR(URgikmFuQbq2k3nRcqL0gsQgG6arBGkoqaHSqi3Yn2ewQjfTPKQbOUXStzPyGkmWdgOB3de4zdub)bEWa1zGOnqfhiGqwiKB5w1eHqsuLQTyABm7uwkgOcdKUgOB3de4zdub)bsxd0T7bQ4abE2a9hi9deTbIcZhLAaKTYDyAmwIQwoduNbQZ3b0alwgfwJdXFw5h)zLk)lFVaHrYVd8m5T6i)DoRMfJ8u8XFwj9)LVZz1SyKNIVdWwWyR(oWZ2o1Hd8Ubc8SbQG)avoq0gybc7il5KDmwmq)bQCGUDpqGNTDQdh4Dde4zdub)bs)3lqyK87apt20IfXh)zLh8x(oNvZIrEk(EbcJKFpmnglrvlNVdWwWyR(URgikmFuQbq2k3HPXyjQA5mq0giWZ2o1Hd8Ubc8SbQG)aP)7aAGflJcRXH4pR8Jp(Er4)YFw5F57Cwnlg5P47fims(DSjSutkAtjvdq97aSfm2QVR4aJAXzSV5z4LLAseCPrsjQ2e4T5SAwmYarBGaczHqUL7BEgEzPMebxAKuIQnbEBm7uwkgOldu3duNbI2abeYcHCl3QMiesIQuTftBJzNYsXavyGh8DanWILrH14q8Nv(XFM()Y3lqyK8738m8YsnjcU0iPevBc8(oNvZIrEk(4pFWF57Cwnlg5P47aSfm2QV7QbIcZhLAaKTYDyAmwIQwodeTbc8Sb6I)avoq0giNmwJ2aDzG6(6VxGWi535KXA2vBPMKx2Hg(J)mD9x(EbcJKFx1eHqsuLQTyAFNZQzXipfF8N19F57Cwnlg5P47aSfm2QV30QQUXTcpl1KUEHWYBwISri3YVxGWi53XTcpl1KUEHWYBwI8XFwx)lFNZQzXipfFhGTGXw9Dxnquy(OudGSvUfOSmTutcWvYsQgG6arBGkoqfhOIde4zduHbEWaD7EGaczHqULBvtecjrvQ2IPTXStzPyGkmqDDG6mq0gOIde4zdub)bQ7b629abeYcHCl3QMiesIQuTftBJzNYsXavyG0pqDgOod0T7bYjJ1OTdZHLbr6uhoqx8h4bduNVxGWi53fOSmTutcWvYsQgG6h)z6(F57Cwnlg5P47aSfm2QVd8STtD4aVBGapBGk4pq6)EbcJKFhZhzSGLEf25J)SU4V8DoRMfJ8u8Da2cgB13bE2aDXFGh89cegj)oWZKnTyr8XFMo(lFNZQzXipfFhGTGXw9DGNTDQdh4Dde4zdub)bEW3lqyK87QMiKevz4XYBEwWYW0y8h)zLx)x(oNvZIrEk(EbcJKFpmnglrvlNVdWwWyR(oWZ2o1Hd8Ubc8SbQG)aPFGOnqfhORgyuloJTNfsaXPHS5SAwmYaD7EGUAGOW8rPgazRChMgJLOQLZa157aAGflJcRXH4pR8J)SsL)LVxGWi53bEM8wDK)oNvZIrEk(4pRK()Y35SAwmYtX3lqyK87nRcqL0gsQgG63bylySvF3vdefMpk1aiBL7MvbOsAdjvdqDGOnqfhytRQ6UHqvIcta7wud0T7bQ4aJAXzS9SqcionKnNvZIrgiAdefMpk1aiBL7W0ySevTCgiAde4zd0LbsxduNbQZ3b0alwgfwJdXFw5hF8X3pYyHrY)m9xRKoUMUtp9F)wHtl1eFNoZbfbhmYaP7dSaHrYbUmri2J(VJctuTf)97hiDULi3Qfvgpq6eKK6O)(b6fbkbD70jnl8AB2aIZjH50UQWijaxQXjH5aon6VFGxrRwRig4bOpq6VwjDmW7gOYRPBxthJ(r)9d8k9QuJf0Tr)9d8Ub6AzhYrEGDuCHhORrLidShyJkpqajrcJKIbQOxLilgzGn0gyHGqsD2J(7h4Dd01YoKJ8a1LD60bIzaXXHtKkmsoqfVzR1aByaXHhynquywvN9O)(bE3aVsVk14bgfwJdPPoWGmqanWILrH14qSh93pW7gORLDih5bYjJ1OnqqHAGapgqDGQe8a1LMiedKOoqDzlM2avuyodeXuvzmNaEGMyGjRTmnRzXOpWM2yGOwfTbIyQQmMtapqtmqHPLMQbQm0zp6VFG3nWRabHrgORPGhiDwWoIbQyGTKkhc0hihGTo7r)O)(bEvoKbTbJmWgwLG5bcionvmWgwZsXEGxbaWOcXatsENxHDuBxdSaHrsXaj5I2E0F)alqyKuSrHzaXPPcF1vjOo6VFGfimsk2OWmG40ubL(NujeKr)9dSaHrsXgfMbeNMkO0)u1Q5WzuHrYr)9dSNfkHhjgiUmKb20QQYiduevigydRsW8abeNMkgydRzPyGvImquy(ouKiSuBGMyGiKK3J(7hybcJKInkmdionvqP)jrwOeEKqkIkeJ(cegjfBuygqCAQGs)tOiHrYrFbcJKInkmdionvqP)jGNjBAXIaDt1xrxf1IZylymNwqBZz1Sye3UDvuloJTQjcjrvgES8MNfSmmngV5SAwmIoJ(cegjfBuygqCAQGs)taptERoYJ(r)9d8QCidAdgzG8rgtBGH5Wdm84bwGGGhOjgyDSSv1S49O)(bwGWiPWVAdISIOauh9fimskO0)KafxyPxLisrGnQ8O)(bEH0c8girDG0Pf2PgijhiGqwiKBj6d0uh4vfcbzG0Pf2PgOjgiNvZIrgitNSTwdmidu51xFvBGe1b6uhAoTod0JRv4n6lqyKuqP)PG0c8Kevj1c7uOBzW4J1YNoUgDuGq6X1k88VER7r)9d8QojmsoqtDGDgZPf0gibpWEqWoOpWRsHdp0hyLiduxAyEGfMhylQbsWdKgPDGfMhiUntl1gOGXCAbTbwjYaRb6uwoqruXadSLu5yGOWeGa9bsWdKgPDGfMhyBIW4bgE8azvvgedKOoWMfHGSAfb6dKGhyuynogyyo8adYarmEGMyGAyUcgpqcEGmDY2AnWGmqD96rFbcJKck9pHIegjr3u9BAvv3cgZPf02TOC7UPvvDlcc2rYfo8KvIivnmVBr52TIUkQfNXwWyoTG2MZQzXiOfylPYXgfMa2LMTSG2gZfi0XT7Mwv1DZIqqwTIyJ5ceUDhfwJJDyoSmiseJDXxxVE0xGWiPGs)tGATKfimskxMiqplh2xWyoTGg6MQFtRQ6wWyoTG2Uf1OVaHrsbL(NW8rglyPxHDq3u9vKtgRrBhMdldI0Po0fLUDRyuloJTGXCAbTnNvZIrqdqileYTClymNwqBJzNYsHl0RJoOb8STtD4DaptbF6h9fimskO0)KQjcjrvgES8MNfSmmngJUP6RiNmwJ2omhwgePtDOlkD7wXOwCgBbJ50cABoRMfJGgGqwiKB5wWyoTG2gZoLLcxOxhDqd4zBN6W7aEMc(hm6lqyKuqP)PW0ySevTCqhqdSyzuynoe(kr3u9vKtgRrBhMdldI0Po0fLUDRyuloJTGXCAbTnNvZIrqdqileYTClymNwqBJzNYsHl0RJoOb8STtD4DaptbF6rZvOW8rPgazRChMgJLOQLZOVaHrsbL(Na1AjlqyKuUmrGEwoSpaz0F)aVYATgy4XdSFzGfimsoWLjIbAQdm8ympWcZdK(bsWdCXcXa5KDmwm6lqyKuqP)jqTwYcegjLlteONLd7lc0nv)ce2rwYj7ySWLdg93pWRSwRbgE8aVcYvzGfimsoWLjIbAQdm8ympWcZd8GbsWd0HG5bYj7ySy0xGWiPGs)tGATKfimskxMiqplh2Vim6MQFbc7il5KDmwOG)bJ(r)9d8kaHrsX(kixLbAIbAzWjcJmqvcEGTcEG3SWBGUgmimG8kqqKx5IRJ8aRezGGwmMZyrBGjZiIbgKb2WdKGkmh7QzKrFbcJKIDryFSjSutkAtjvdqfDanWILrH14q4ReDt1xXOwCg7BEgEzPMebxAKuIQnbEBoRMfJGgGqwiKB5(MNHxwQjrWLgjLOAtG3gZoLLcx0ToObiKfc5wUvnriKevPAlM2gZoLLcfoy0xGWiPyxeMs)t38m8YsnjcU0iPevBc8g9fimsk2fHP0)eNmwZUAl1K8Yo0WOBQ(UcfMpk1aiBL7W0ySevTCqd4zU4RenozSgnx091J(cegjf7IWu6Fs1eHqsuLQTyAJ(cegjf7IWu6Fc3k8Sut66fclVzjc6MQFtRQ6g3k8Sut66fclVzjYgHClh9fimsk2fHP0)KaLLPLAsaUsws1aur3u9DfkmFuQbq2k3cuwMwQjb4kzjvdqfnfvurGNPWbUDdiKfc5wUvnriKevPAlM2gZoLLcf0vDqtrGNPGVUD7gqileYTCRAIqijQs1wmTnMDklfkqVo642nNmwJ2omhwgePtDOl(hOZOVaHrsXUimL(NW8rglyPxHDq3u9bE22Po8oGNPGp9J(cegjf7IWu6Fc4zYMwSiq3u9bEMl(hm6lqyKuSlctP)jvtesIQm8y5nplyzyAmgDt1h4zBN6W7aEMc(hm6lqyKuSlctP)PW0ySevTCqhqdSyzuynoe(kr3u9bE22Po8oGNPGp9OPORIAXzS9SqcionKnNvZIrC72vOW8rPgazRChMgJLOQLJoJ(cegjf7IWu6Fc4zYB1rE0F)alqyKuSlctP)j1fnl1KcgJIZqs1aur3u9BAvv3neQsuycyJqULOBzWyClQWx5OVaHrsXUimL(NAwfGkPnKunav0b0alwgfwJdHVs0nvFxHcZhLAaKTYDZQaujTHKQbOIMInTQQ7gcvjkmbSBr52TIrT4m2EwibeNgYMZQzXiOHcZhLAaKTYDyAmwIQwoOb8mxOlD0z0p6VFGxjHSqi3sXOVaHrsXgG4B5rcvwEylNYWJL38SGLHPX4rFbcJKInaHs)tTcwAb7ig9fimsk2aek9p1kyPfSd6z5W(hlSvnlwAzWPWcAsntRoswHKia2AvHLAsmxGGGh9fimsk2aek9p1SieePAlM2OVaHrsXgGqP)Pgglymvl1g93pqxtbpWRadQKh4fcgZzmqtDG0iTdSW8aDmHWsTbwXaxCjIbQCGxPNnWkrg4nsEvngiOqnqozSgTbEZcplh41BDpqbdijIy0xGWiPydqO0)uHbvYYGGXCgOBQ(apB7uhEhWZuWxjACYynA7WCyzqKo1Hk4F9w3J(cegjfBacL(NwMMxiKUElIMdNXOVaHrsXgGqP)jvdZnlcbz0xGWiPydqO0)uLawe4Ajb1An6lqyKuSbiu6FkiTapjrvIWv4HUP6hfwJJDyoSmiseJvGog9fimsk2aek9pjcc2rYfo8KvIivnmJUP6diKfc5wUfbb7i5chEYkrKQgM3aVcRXcF6D7wraHSqi3YTQjcHKOkvBX02y2PSu4IVUIgWZuW)a0aeYcHCl3ytyPMu0MsQgG6gZoLLcx8vQJB3rH14yhMdldIeXyx8vQ7rFbcJKInaHs)tcgZPf0q3u9beYcHCl3ytyPMu0MsQgG6gZoLLcx8P3T7OWACSdZHLbrIySl(kPF0xGWiPydqO0)eOwlzbcJKYLjc0ZYH9zHGtalg9J(cegjfBwi4eWcFajbCg4kyeP6QC4rFbcJKInleCcybL(NAwecIKOkdpwYj7qB0xGWiPyZcbNawqP)jT2cJyvkjQY6Qzmj8g9fimsk2SqWjGfu6FsLaAfmISUAgBblB4Yz0xGWiPyZcbNawqP)juTytLMLAYMvjIrFbcJKInleCcybL(Ncpw2MnK2erQsWaE0xGWiPyZcbNawqP)jSHc1ILwkfOkap6lqyKuSzHGtalO0)0ncEHCKTuIzbjReWJ(cegjfBwi4eWck9p5WoemnjrvUAbgIebZLJaDt1NtgRrZf66A0AAvv3IGGDKCHdpzLisvdZ7wuJ(r)9dSZyoTG2arHnc2cAJ(cegjfBbJ50cA(ytyPMu0MsQgGk6aAGflJcRXHWxj6MQFbc7il5KDmw4YbUDJcZhLAaKTYTaLLPLAsaUsws1auh9fimsk2cgZPf0O0)KQjcHKOkvBX0q3u9vSPvvD3SieKvRi2TOqdfMpk1aiBLBSjSutkAtjvdqvh3UBAvv3cgZPf02y2PSu4Is3UvSaHDKLCYogluqjAfiSJSKt2XyHl6wNrFbcJKITGXCAbnk9pjqzzAPMeGRKLunav0nvFxHcZhLAaKTYTaLLPLAsaUsws1aurtXce2rwYj7ySqb)dC7wXce2rwYj7ySWNE0qH5JsnaYw5UzvaQK2qs1au1rNrFbcJKITGXCAbnk9p1SkavsBiPAaQOdObwSmkSghcFLJ(rFbcJKITi8V5z4LLAseCPrsjQ2e4n6lqyKuSfbL(NWMWsnPOnLunav0b0alwgfwJdHVs0nvFGNPGVUh9fimsk2IGs)tQMiesIQuTftB0xGWiPylck9pHnHLAsrBkPAaQOdObwSmkSghcFLJ(cegjfBrqP)jCRWZsnPRxiS8MLiOBQ(nTQQBCRWZsnPRxiS8MLiBeYTeTce2rwYj7ySqbLJ(cegjfBrqP)jmFKXcw6vyh0nvFGNTDQdVd4zk4t)OVaHrsXweu6Fs1eHKOkdpwEZZcwgMgJr3u9bEMl(0p6lqyKuSfbL(N4KXA2vBPMKx2HggDt1h4zU4FaACYynAUO7Rh9fimsk2IGs)tcuwMwQjb4kzjvdqfDt13vOW8rPgazRClqzzAPMeGRKLunav0AAvv3ivcyjrvc8mx32TOg9fimsk2IGs)tnRcqL0gsQgGk6aAGflJcRXHWxj6MQVRqH5JsnaYw5UzvaQK2qs1aurtraHSqi3Yn2ewQjfTPKQbOUXStzPqHdC7g4zk4FGoOPiGqwiKB5w1eHqsuLQTyABm7uwkuGUC7g4zk4txUDRiWZ8Phnuy(OudGSvUdtJXsu1YrhDg9fimsk2IGs)taptERoYJ(cegjfBrqP)jGNjBAXIaDt1h4zBN6W7aEMc(krRaHDKLCYogl8v62nWZ2o1H3b8mf8PF0xGWiPylck9pfMgJLOQLd6aAGflJcRXHWxj6MQVRqH5JsnaYw5omnglrvlh0aE22Po8oGNPGp9FVAdpc(7DZ5k)4J)ba" )

end