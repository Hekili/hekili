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
    
    spec:RegisterPack( "Windwalker", 20190722, "dOenZaqiQK8ivQ6sQKGAtqkFIkPqJIe1PifEfsXSqc3sLk7sP(LkyyQiDmsyziLEMkPMgKQ6AKISnsr13ujPgNkj05GuL1rkkMhvI7rvTpsKdcPsTqKOhQsIUOkjXgjfL(OkjiJKkPKtcPISssPxQss6MujLANQOgkvsrlfsL8uLmvvIRQsc8vivu7vv)LObd6WIwSu8yGjdXLrTzs6ZuXOPkNMYQPsQEnsA2s1Tjv7wYVrmCi54ujfSCOEoHPlCDP02vH(UkLXRI48ivRhsfMpvQ9R4xXF5xizW)zApvb6D6vtlT7tvCQc0xt)kOJI)fQeqnD4FvPo)l0zRqULDQm(xOs6DsI8x(LG0Ib8V8IaLqZC4GJfETnBar)GW0B7zyKcGt14GW0bhA6KMdnQ5Di8XdOWevRZIdUMygDLgI4GRj6s6AtkQs0zRqULDQmElmDWVAATEGovFZVqYG)Z0EQc070RMwA3NQ4ufOVIFjqXG)mTAo69lpdbHRV5xiSa8R7hi6Svi3YovgpqxBsrD0E)a9IaLqZC4GJfETnBar)GW0B7zyKcGt14GW0bhgT3pqTTD6dKwfumqApvb6nW7giTk0mA60r7O9(bELEz5WcnZO9(bE3arxSo5ipWfkoXd01klKbUcSrLhiGuiHrkXav2llKoJmWg6dmrqiLg7r79d8UbIUyDYrEGA21vDGygq015cjdJudu5BwVpWggq05bMdefMv1ypAVFG3nWR0llhEGrID4qAQdmideqh0zzKyhoe7r79d8UbIUyDYrEGCXyh6deKOgiWJbuhOkbpqnRjcXajQduZ2IPpqLfM(armvvgZfGhOjgyXoDZXA6mfdSPngiQEsFGiMQkJ5cWd0eduyoLPAGScn2J27h4DdeDJGWid8kqWdeDkyDXavoWwrLdbfdKdWwJ9V6Mie)LFXcbxaw8x(Zk(l)kbHrQFbifGRaNbJiv7Po)lUYMoJ8u(XFM2)YVsqyK6xnDcbrsuLHhl5I1P)lUYMoJ8u(XF(6)YVsqyK6xoTjgXYssuLj6GXKW7xCLnDg5P8J)m6)x(vccJu)sLaAfmImrhm2cw2WP(V4kB6mYt5h)zn9x(vccJu)cvl2uPBLJSPNI4xCLnDg5P8J)SM)x(vccJu)k8yzB1qAlePkbd4FXv20zKNYp(Zx9F5xjims9lSHcvNLwjfOsa)lUYMoJ8u(XF(k(x(vccJu)6gb3roYwjXSGuzb4FXv20zKNYp(ZO3F5xCLnDg5P8xaSfm2YFXfJDOpqxgi6F6arBGnTQQBrqW6soXHNmlePQH5DlQFLGWi1V0zDcMUKOk7TadrIG5ux8Xh)cG8x(Zk(l)kbHrQFz1rcvwEslx)IRSPZipLF8NP9V8lUYMoJ8u(Rk15FDmXw20zPvbxclOlDmN8iPhsIay9Egw5iXCccc(xjims9RJj2YMolTk4sybDPJ5Khj9qseaR3ZWkhjMtqqWF8NV(V8ReegP(vRGLwW6IFXv20zKNYp(ZO)F5xjims9RMoHGivBX0)fxztNrEk)4pRP)YVsqyK6xnmwWyQw58lUYMoJ8u(XFwZ)l)IRSPZipL)cGTGXw(lGNT1Ztg4Dde4zduj)bQyGOnqUySd9Dy6Smis98KbQK)apDRPFLGWi1VsmilwgemMR4J)8v)x(vccJu)QBoEHq66Tio6Cf)IRSPZipLF8NVI)LFLGWi1Vunm30jeKFXv20zKNYp(ZO3F5xjims9RSaSiWzxcYE)xCLnDg5P8J)SIt)l)IRSPZipL)cGTGXw(RiXoCSdtNLbrIy8avAGO3VsqyK6xbPf4jjQseodVp(Zku8x(fxztNrEk)faBbJT8xacPJqUvBrqW6soXHNmlePQH5nWlXoSyG(dK2b629avEGacPJqUvBvtecjrvQ2IPVXSEALyGU4pqnFGOnqGNnqL8h41deTbciKoc5wTXMWkhPOTKuna1nM1tRed0f)bQyGAmq3UhyKyho2HPZYGirmEGU4pqfA6xjims9lrqW6soXHNmlePQH5p(ZkO9V8lUYMoJ8u(la2cgB5VaeshHCR2ytyLJu0wsQgG6gZ6PvIb6I)aPDGUDpWiXoCSdtNLbrIy8aDXFGkO9xjims9lbJ5Yc6F8NvC9F5xCLnDg5P8xjims9lq27YeegPKDte)QBIqwPo)lwi4cWIp(4xOWmGO3KXF5pR4V8ReegP(fksyK6xCLnDg5P8J)mT)LFXv20zKNYFbWwWyl)LYd0vdmYoxXwWyUSG(MRSPZid0T7b6QbgzNRyRAIqsuLHhlV5zbldZHXBUYMoJmqn(vccJu)c4zYMwSi(4pF9F5xjims9lGNjVLh5FXv20zKNYp(4xcgZLf0)l)zf)LFXv20zKNYFLGWi1VWMWkhPOTKuna1FbWwWyl)vcc7il5I1nwmqxg41d0T7bIcZhLoaKTITaLvLvosaolws1au)fGoOZYiXoCi(Zk(4pt7F5xCLnDg5P8xaSfm2YFP8aBAvv3nDcbP3kIDlQbI2arH5JshaYwXgBcRCKI2ss1auhOgd0T7b20QQUfmMllOVXSEALyGUmqfd0T7bQ8atqyhzjxSUXIbQ0avmq0gycc7il5I1nwmqxgOMgOg)kbHrQFPAIqijQs1wm9p(Zx)x(fxztNrEk)faBbJT8xUAGOW8rPdazRylqzvzLJeGZILuna1bI2avEGjiSJSKlw3yXavYFGxpq3UhOYdmbHDKLCX6glgO)aPDGOnquy(O0bGSvSB6jGkPnKuna1bQXa14xjims9lbkRkRCKaCwSKQbO(XFg9)l)IRSPZipL)kbHrQF10tavsBiPAaQ)cqh0zzKyhoe)zfF8XVsc)x(Zk(l)IRSPZipL)kbHrQFHnHvosrBjPAaQ)cGTGXw(lLhyKDUI9npd3TYrIGthsjr1waVnxztNrgiAdeqiDeYTAFZZWDRCKi40HusuTfWBJz90kXaDzGAAGAmq0giGq6iKB1w1eHqsuLQTy6BmRNwjgOsd86FbOd6SmsSdhI)SIp(Z0(x(vccJu)6MNH7w5irWPdPKOAlG3V4kB6mYt5h)5R)l)IRSPZipL)cGTGXw(lxnquy(O0bGSvSdZHXsuzxFGOnqGNnqx8hOIbI2a5IXo0hOldutN(ReegP(fxm2Xqhw5i5UDIH)4pJ()LFLGWi1VunriKevPAlM(V4kB6mYt5h)zn9x(fxztNrEk)faBbJT8xnTQQBCRWZkhPRNiS8MviBeYT6xjims9lCRWZkhPRNiS8MviF8N18)YV4kB6mYt5VaylySL)YvdefMpkDaiBfBbkRkRCKaCwSKQbOoq0gOYdu5bQ8abE2avAGxpq3UhiGq6iKB1w1eHqsuLQTy6BmRNwjgOsduZhOgdeTbQ8abE2avYFGAAGUDpqaH0ri3QTQjcHKOkvBX03ywpTsmqLgiTduJbQXaD7EGCXyh67W0zzqK65jd0f)bE9a14xjims9lbkRkRCKaCwSKQbO(XF(Q)l)IRSPZipL)cGTGXw(lGNT1Ztg4Dde4zduj)bs7VsqyK6xy(iJfS0lX6F8NVI)LFXv20zKNYFbWwWyl)fWZgOl(d86FLGWi1VaEMSPflIp(ZO3F5xCLnDg5P8xaSfm2YFb8STEEYaVBGapBGk5pWR)vccJu)s1eHKOkdpwEZZcwgMdJ)4pR40)YV4kB6mYt5VsqyK6xH5WyjQSR)la2cgB5VaE2wppzG3nqGNnqL8hiTdeTbQ8aD1aJSZvS9Sqci6nKnxztNrgOB3d0vdefMpkDaiBf7WCySev21hOg)cqh0zzKyhoe)zfF8NvO4V8ReegP(fWZK3YJ8V4kB6mYt5h)zf0(x(fxztNrEk)vccJu)QPNaQK2qs1au)faBbJT8xUAGOW8rPdazRy30tavsBiPAaQdeTbQ8aBAvv3neQsuycy3IAGUDpqLhyKDUITNfsarVHS5kB6mYarBGOW8rPdazRyhMdJLOYU(arBGapBGUmq0FGAmqn(fGoOZYiXoCi(Zk(4JFjI)YFwXF5xjims9RBEgUBLJebNoKsIQTaE)IRSPZipLF8NP9V8lUYMoJ8u(ReegP(f2ew5ifTLKQbO(la2cgB5VaE2avYFGA6xa6GolJe7WH4pR4J)81)LFLGWi1VunriKevPAlM(V4kB6mYt5h)z0)V8lUYMoJ8u(ReegP(f2ew5ifTLKQbO(laDqNLrID4q8Nv8XFwt)LFXv20zKNYFbWwWyl)vtRQ6g3k8SYr66jclVzfYgHCRgiAdmbHDKLCX6glgOsduXVsqyK6x4wHNvosxpry5nRq(4pR5)LFXv20zKNYFbWwWyl)fWZ265jd8Ubc8SbQK)aP9xjims9lmFKXcw6Ly9p(Zx9F5xCLnDg5P8xaSfm2YFb8Sb6I)aP9xjims9lvtesIQm8y5nplyzyom(J)8v8V8lUYMoJ8u(la2cgB5VaE2aDXFGxpq0gixm2H(aDzGA60FLGWi1V4IXog6Wkhj3Ttm8h)z07V8lUYMoJ8u(la2cgB5VC1arH5JshaYwXwGYQYkhjaNflPAaQdeTb20QQUrYcWsIQe4zUUTBr9ReegP(LaLvLvosaolws1au)4pR40)YV4kB6mYt5VsqyK6xn9eqL0gsQgG6VaylySL)YvdefMpkDaiBf7MEcOsAdjvdqDGOnqLhiGq6iKB1gBcRCKI2ss1au3ywpTsmqLg41d0T7bc8SbQK)aVEGAmq0gOYdeqiDeYTARAIqijQs1wm9nM1tReduPbI(d0T7bc8SbQK)ar)b629avEGapBG(dK2bI2arH5JshaYwXomhglrLD9bQXa14xa6GolJe7WH4pR4J)Scf)LFLGWi1VaEM8wEK)fxztNrEk)4pRG2)YV4kB6mYt5VaylySL)c4zB98KbE3abE2avYFGkgiAdmbHDKLCX6glgO)avmq3UhiWZ265jd8Ubc8SbQK)aP9xjims9lGNjBAXI4J)SIR)l)IRSPZipL)kbHrQFfMdJLOYU(VaylySL)YvdefMpkDaiBf7WCySev21hiAde4zB98KbE3abE2avYFG0(laDqNLrID4q8Nv8Xh)cHvZ2E8x(Zk(l)kbHrQFjqXjw6LfIueyJk)lUYMoJ8u(XFM2)YVSky8XS)l070FHcespo7H3VoDRPFLGWi1VcslWtsuLutSE(lUYMoJ8u(XF(6)YV4kB6mYt5VaylySL)QPvvDlymxwqF3IAGUDpWMwv1TiiyDjN4WtMfIu1W8Uf1aD7EGkpqxnWi7CfBbJ5Yc6BUYMoJmq0gyGTIkhBuycyNow3c6BmNGyGAmq3UhytRQ6UPtii9wrSXCcIb629aJe7WXomDwgejIXd0f)bQ5N(ReegP(fksyK6J)m6)x(fxztNrEk)faBbJT8xnTQQBbJ5Yc67wu)kbHrQFbYExMGWiLSBI4xDteYk15Fjymxwq)J)SM(l)IRSPZipL)cGTGXw(lLhixm2H(omDwgePEEYaDzGkgOB3du5bgzNRylymxwqFZv20zKbI2abeshHCR2cgZLf03ywpTsmqxgiTduJbQXarBGapBRNNmW7giWZgOs(dK2FLGWi1VW8rglyPxI1)4pR5)LFXv20zKNYFbWwWyl)LYdKlg7qFhMoldIuppzGUmqfd0T7bQ8aJSZvSfmMllOV5kB6mYarBGacPJqUvBbJ5Yc6BmRNwjgOldK2bQXa1yGOnqGNT1Ztg4Dde4zduj)bE9VsqyK6xQMiKevz4XYBEwWYWCy8h)5R(V8lUYMoJ8u(ReegP(vyomwIk76)cGTGXw(lLhixm2H(omDwgePEEYaDzGkgOB3du5bgzNRylymxwqFZv20zKbI2abeshHCR2cgZLf03ywpTsmqxgiTduJbQXarBGapBRNNmW7giWZgOs(dK2bI2aD1arH5JshaYwXomhglrLD9FbOd6SmsSdhI)SIp(ZxX)YV4kB6mYt5VsqyK6xGS3Ljimsj7Mi(v3eHSsD(xaKp(ZO3F5xCLnDg5P8xaSfm2YFLGWoYsUyDJfd0LbE9VsqyK6xGS3Ljimsj7Mi(v3eHSsD(xI4J)SIt)l)IRSPZipL)cGTGXw(Ree2rwYfRBSyGk5pWR)vccJu)cK9UmbHrkz3eXV6MiKvQZ)kj8hF8XVoYyHrQ)mTNQa9o9QvC6(u07un9RBjUSYr8l0jDueCWid8QhyccJudSBIqShT)kBdpc(xlt)k)fkmr168VUFGOZwHCl7uz8aDTjf1r79d0lcucnZHdow412Sbe9dctVTNHrkaovJdcthCy0E)a122PpqAvqXaP9ufO3aVBG0QqZOPthTJ27h4v6LLdl0mJ27h4DdeDX6KJ8axO4epqxRSqg4kWgvEGasHegPeduzVSq6mYaBOpWebHuAShT3pW7gi6I1jh5bQzxx1bIzarxNlKmmsnqLVz9(aByarNhyoquywvJ9O9(bE3aVsVSC4bgj2HdPPoWGmqaDqNLrID4qShT3pW7gi6I1jh5bYfJDOpqqIAGapgqDGQe8a1SMiedKOoqnBlM(avwy6deXuvzmxaEGMyGf70nhRPZumWM2yGO6j9bIyQQmMlapqtmqH5uMQbYk0ypAVFG3nq0nccJmWRabpq0PG1fdu5aBfvoeumqoaBn2J2r79d8QCcdAdgzGnSkbZdeq0BYyGnSJvI9ar3aaJkedSi1DEjwxTTpWeegPedKuD67r79dmbHrkXgfMbe9Mm8v7PG6O9(bMGWiLyJcZaIEtg04FqLqqgT3pWeegPeBuygq0BYGg)dzRJoxrggPgT3pWvLOeEKyG40qgytRQkJmqrKHyGnSkbZdeq0BYyGnSJvIbMfYarH57qrIWkNbAIbIqkEpAVFGjimsj2OWmGO3Kbn(hevIs4rcPiYqmAtqyKsSrHzarVjdA8pGIegPgTjimsj2OWmGO3Kbn(haEMSPflckmvFLDvKDUITGXCzb9nxztNrC72vr25k2QMiKevz4XYBEwWYWCy8MRSPZiAmAtqyKsSrHzarVjdA8pa8m5T8ipAhT3pWRYjmOnyKbYhzm9bgMopWWJhycccEGMyG5X06ztN3J27hyccJuc)SniYmIeqD0MGWiLGg)dcuCILEzHifb2OYJ27h4fslWBGe1bEvtSEoqsnqaH0ri3kkgOPoWRqecYaVQjwphOjgixztNrgi7AOn7dmiduXPNEfEGe1bQNNy6T6d0JZE4nAtqyKsqJ)HG0c8Kevj1eRNuyvW4Jz3h9oLcuGq6Xzp88pDRPr79d01KegPgOPoWfJ5Yc6dKGh4kiyDkg4vjXHhfdmlKbQznmpWeZdSf1aj4bsN0oWeZde3wLvoduWyUSG(aZczG5a1tRgOiYyGb2kQCmquycqqXaj4bsN0oWeZdSTqy8adpEGSQkdIbsuhytNqq6TIGIbsWdmsSdhdmmDEGbzGigpqtmqhmNbJhibpq21qB2hyqgOMF6OnbHrkbn(hqrcJuuyQ(nTQQBbJ5Yc67wuUD30QQUfbbRl5ehEYSqKQgM3TOC7wzxfzNRylymxwqFZv20ze0cSvu5yJcta70X6wqFJ5eeA42DtRQ6UPtii9wrSXCcc3UJe7WXomDwgejIXU4R5NoAtqyKsqJ)bq27YeegPKDteuuPo7lymxwqNct1VPvvDlymxwqF3IA0MGWiLGg)dy(iJfS0lX6uyQ(kZfJDOVdtNLbrQNN4Ic3UvoYoxXwWyUSG(MRSPZiObiKoc5wTfmMllOVXSEALWfA1qd0aE2wpp5oGNPKpTJ2eegPe04Fq1eHKOkdpwEZZcwgMdJPWu9vMlg7qFhMoldIuppXffUDRCKDUITGXCzb9nxztNrqdqiDeYTAlymxwqFJz90kHl0QHgOb8STEEYDaptj)RhTjimsjOX)qyomwIk76uaOd6SmsSdhcFfuyQ(kZfJDOVdtNLbrQNN4Ic3UvoYoxXwWyUSG(MRSPZiObiKoc5wTfmMllOVXSEALWfA1qd0aE2wpp5oGNPKpTO5kuy(O0bGSvSdZHXsuzxF0MGWiLGg)dGS3Ljimsj7MiOOsD2hGmAVFGxz27dm84bUUmWeegPgy3eXan1bgEmMhyI5bs7aj4b2zHyGCX6glgTjimsjOX)ai7DzccJuYUjckQuN9fbfMQFcc7il5I1nw4Y1J27h4vM9(adpEGOBYvzGjimsnWUjIbAQdm8ympWeZd86bsWduNG5bYfRBSy0MGWiLGg)dGS3Ljimsj7MiOOsD2pjmfMQFcc7il5I1nwOK)1J2r79deDdcJuIn6MCvgOjgOvbximYavj4b2k4bEZcVb6AXGWas0ncI8k7CEKhywide0IXCfD6dSygrmWGmWgEGeuHPBOdgz0MGWiLyNe2hBcRCKI2ss1auPaqh0zzKyhoe(kOWu9voYoxX(MNH7w5irWPdPKOAlG3MRSPZiObiKoc5wTV5z4UvoseC6qkjQ2c4TXSEALWfnPbAacPJqUvBvtecjrvQ2IPVXSEALqPRhTjimsj2jHPX)Wnpd3TYrIGthsjr1waVrBccJuIDsyA8pWfJDm0HvosUBNyykmvFxHcZhLoaKTIDyomwIk76Ob8mx8vGgxm2HUlA60rBccJuIDsyA8pOAIqijQs1wm9rBccJuIDsyA8pGBfEw5iD9eHL3ScHct1VPvvDJBfEw5iD9eHL3SczJqUvJ2eegPe7KW04FqGYQYkhjaNflPAaQuyQ(UcfMpkDaiBfBbkRkRCKaCwSKQbOIMYkRmWZu6A3UbeshHCR2QMiesIQuTftFJz90kHsAUgOPmWZuYxtUDdiKoc5wTvnriKevPAlM(gZ6PvcLOvdnC7Mlg7qFhMoldIuppXf)R1y0MGWiLyNeMg)dy(iJfS0lX6uyQ(apBRNNChWZuYN2rBccJuIDsyA8pa8mztlweuyQ(apZf)RhTjimsj2jHPX)GQjcjrvgES8MNfSmmhgtHP6d8STEEYDaptj)RhTjimsj2jHPX)qyomwIk76uaOd6SmsSdhcFfuyQ(apBRNNChWZuYNw0u2vr25k2Ewibe9gYMRSPZiUD7kuy(O0bGSvSdZHXsuzxxJrBccJuIDsyA8pa8m5T8ipAVFGjimsj2jHPX)GANUvosbJrXviPAaQuyQ(nTQQ7gcvjkmbSri3kkSkymUfv4Ry0MGWiLyNeMg)dn9eqL0gsQgGkfa6GolJe7WHWxbfMQVRqH5JshaYwXUPNaQK2qs1aurt5Mwv1DdHQefMa2TOC7w5i7CfBplKaIEdzZv20ze0qH5JshaYwXomhglrLDD0aEMlOVgAmAhT3pWRKq6iKBLy0MGWiLydq8T6iHklpPLlz4XYBEwWYWCy8OnbHrkXgGqJ)HwblTG1POsD2)yITSPZsRcUewqx6yo5rspKebW69mSYrI5eee8OnbHrkXgGqJ)HwblTG1fJ2eegPeBacn(hA6ecIuTftF0MGWiLydqOX)qdJfmMQvoJ27h4vGGhi6gdYIh4fcgZvmqtDG0jTdmX8a1nHWkNbMXa7CkIbQyGxPNnWSqg4ns5AmgiirnqUySd9bEZcpRg4PBnnqbdifIy0MGWiLydqOX)qIbzXYGGXCfuyQ(apBRNNChWZuYxbACXyh67W0zzqK65jk5F6wtJ2eegPeBacn(h6MJxiKUElIJoxXOnbHrkXgGqJ)bvdZnDcbz0MGWiLydqOX)qwawe4SlbzVpAtqyKsSbi04FiiTapjrvIWz4rHP6hj2HJDy6SmiseJvc9gTjimsj2aeA8piccwxYjo8KzHivnmtHP6diKoc5wTfbbRl5ehEYSqKQgM3aVe7WcFAD7wzaH0ri3QTQjcHKOkvBX03ywpTs4IVMJgWZuY)A0aeshHCR2ytyLJu0wsQgG6gZ6Pvcx8vOHB3rID4yhMoldIeXyx8vOPrBccJuInaHg)dcgZLf0PWu9beshHCR2ytyLJu0wsQgG6gZ6Pvcx8P1T7iXoCSdtNLbrIySl(kOD0MGWiLydqOX)ai7DzccJuYUjckQuN9zHGlalgTJ2eegPeBwi4cWcFaPaCf4myePAp15rBccJuInleCbybn(hA6ecIKOkdpwYfRtF0MGWiLyZcbxawqJ)bN2eJyzjjQYeDWys4nAtqyKsSzHGlalOX)Gkb0kyezIoySfSSHt9rBccJuInleCbybn(hq1Inv6w5iB6PigTjimsj2SqWfGf04Fi8yzB1qAlePkbd4rBccJuInleCbybn(hWgkuDwALuGkb8OnbHrkXMfcUaSGg)d3i4oYr2kjMfKklapAtqyKsSzHGlalOX)GoRtW0LevzVfyisemN6ckmvFUySdDxq)trRPvvDlccwxYjo8KzHivnmVBrnAhT3pWfJ5Yc6def2iylOpAtqyKsSfmMllO7JnHvosrBjPAaQuaOd6SmsSdhcFfuyQ(jiSJSKlw3yHlx72nkmFu6aq2k2cuwvw5ib4SyjvdqD0MGWiLylymxwqNg)dQMiesIQuTftNct1x5Mwv1DtNqq6TIy3Icnuy(O0bGSvSXMWkhPOTKunavnC7UPvvDlymxwqFJz90kHlkC7w5ee2rwYfRBSqjfOLGWoYsUyDJfUOjngTjimsj2cgZLf0PX)GaLvLvosaolws1auPWu9DfkmFu6aq2k2cuwvw5ib4SyjvdqfnLtqyhzjxSUXcL8V2TBLtqyhzjxSUXcFArdfMpkDaiBf7MEcOsAdjvdqvdngTjimsj2cgZLf0PX)qtpbujTHKQbOsbGoOZYiXoCi8vmAhTjimsj2IW)MNH7w5irWPdPKOAlG3OnbHrkXwe04FaBcRCKI2ss1auPaqh0zzKyhoe(kOWu9bEMs(AA0MGWiLylcA8pOAIqijQs1wm9rBccJuITiOX)a2ew5ifTLKQbOsbGoOZYiXoCi8vmAtqyKsSfbn(hWTcpRCKUEIWYBwHqHP630QQUXTcpRCKUEIWYBwHSri3k0sqyhzjxSUXcLumAtqyKsSfbn(hW8rglyPxI1PWu9bE2wpp5oGNPKpTJ2eegPeBrqJ)bvtesIQm8y5nplyzyomMct1h4zU4t7OnbHrkXwe04FGlg7yOdRCKC3oXWuyQ(apZf)RrJlg7q3fnD6OnbHrkXwe04FqGYQYkhjaNflPAaQuyQ(UcfMpkDaiBfBbkRkRCKaCwSKQbOIwtRQ6gjlaljQsGN562Uf1OnbHrkXwe04FOPNaQK2qs1auPaqh0zzKyhoe(kOWu9DfkmFu6aq2k2n9eqL0gsQgGkAkdiKoc5wTXMWkhPOTKuna1nM1tRekDTB3aptj)R1anLbeshHCR2QMiesIQuTftFJz90kHsOVB3aptjF03TBLbEMpTOHcZhLoaKTIDyomwIk76AOXOnbHrkXwe04Fa4zYB5rE0MGWiLylcA8pa8mztlweuyQ(apBRNNChWZuYxbAjiSJSKlw3yHVc3UbE2wpp5oGNPKpTJ2eegPeBrqJ)HWCySev21Paqh0zzKyhoe(kOWu9DfkmFu6aq2k2H5WyjQSRJgWZ265j3b8mL8P9Jp(ha" )

end