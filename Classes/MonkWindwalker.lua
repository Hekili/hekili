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

    spec:RegisterStateExpr( "combo_break", function () return this_action == virtual_combo and combos[ virtual_combo ] end )

    spec:RegisterStateExpr( "combo_strike", function () return not combos[ this_action ] or this_action ~= virtual_combo end )


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
        virtual_combo = actual_combo or "no_action"
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

            start = function ()
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

            cycle = "mark_of_the_crane",
            aura = "mark_of_the_crane",

            start = function ()
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
            gcd = "off",

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

            start = function ()
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

    spec:RegisterSetting( "allow_fsk", true, {
        name = "Use |T606545:0|t Flying Serpent Kick",
        desc = "If unchecked, |T606545:0|t Flying Serpent Kick will not be recommended (this is the same as disabling the ability via Windwalker > Abilities > Flying Serpent Kick > Disable).",
        type = "toggle",
        width = 1.5,
        get = function () return not Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled end,
        set = function ( _, val )
            local a = Hekili.DB.profile.specs[ 269 ].abilities
            Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled = not val end,
    } ) 
    
    spec:RegisterSetting( "optimize_reverse_harm", false, {
        name = "Optimize |T627486:0|t Reverse Harm",
        desc = "If checked, |T627486:0|t Reverse Harm's caption will show the recommended target's name.",
        type = "toggle",
        width = 1.5
    } ) 
    
    spec:RegisterPack( "Windwalker", 20200330, [[d40n6bqiIkEKkk2Kk0NiQKgLKOtjj8kvqZcs6wQOYUK4xevnmIshtfzzeHNPcmnibxds02qPQ8nvuIXjjLoNKuSovuvnpGY9qj7dLYbHeYcLK8qvuLjsujUOKufBusQ8ruQQQrkjvPtkjvvRei9svusZeLQQ0nvrvXojk(jkvvrdvfvLwkrLQNsWujIUkrLYwrPQk8vjPQmwuQQSxs9xOgSIdR0IfYJr1KfCzKndXNby0e60uTAiH61aXSvPBJIDRQFl1WjshxfLA5GEojtNY1fQTdu9Di14rPY5b06rPkZxsTFrRpPLulewJ0YiHSsiRShCGSfjK9GQ5GQrlyaLsAbPlhKfaPf(LH0cvF(hqVxqiOwq6c82BqlPwq1XqoPfentQ68lV8aCtmoQWBg5vot8DnVFoCrm5vodxETquSFTQ)xhPfcRrAzKqwjKv2doq2IeYEGSOulOKsCTmsW(QgTGOhc0RJ0cbsX1cNjNQp)dO3liemNZN(bjb9m5iAMu15xE5b4MyCuH3mYRCM47AE)C4IyYRCgU8jONjNZNfYfZ5azrnhjKvcztqtqptoNN4(ai15pb9m5CUCK7etdoLJGuAH5u9UFihbd6Gq5W7pyE)QCQuC)WLc5ebmNne6VIsc6zY5C5i3jMgCkNQt4SMdK4ndd9H18(ZPs0(9MteXBgkNnhPqcPIsc6zY5C5CEI7dGYXwiaYWosowNdhi)syBHaitvsqptoNlh5oX0Gt5qpbbamh(knhUiXbjhKgMt15ktLtJKt1fdbMtLkNjNGJGqq65uoUkNNaCDaE0LqnNOylhP3fyobhbHG0ZPCCvokhW7ioFFRIsc6zY5C5GIcbkKJCtr5u9BeJkNknO)GqMc1CiJxQOOfUUYuAj1c8awriAj1YCslPwG(n6sbDvAbo0nc6RwikgbPOii9UbSeA0Fo115yodHTghCkhWYrcuQfwU59Rf8h8gecZUy61Mwgj0sQfOFJUuqxLwGdDJG(QfmNHWwJdoLdB5CQArzo115iNCaFH(gDPIyFdyRd5CmhE33qJ(lwhZfXncoqRjwGeZ6VkhWyLZjuiN66CmNHWwJdoLdy5Cak1cl38(1caIxyW3h3i4L9iyBIAtlZbAj1c0VrxkORslWHUrqF1c8UVHg9xSoMlIBeCGwtSajM1FvoSLdkR2CQRZH39n0O)I1XCrCJGd0AIfiXS(RYbSCKiN66CaFH(gDPIyFdyRd5uxNJ5me2ACWPCalhjKvlSCZ7xlGUH3a4K)yiP6FFoPnTmOGwsTa9B0Lc6Q0cCOBe0xTax0lml7Y5C5Wf9CyJvoNY5yo0tqaalMZqyRXml7YHnw5iBbLAHLBE)AHfY3NWwdH0BAtldk1sQfOFJUuqxLwGdDJG(QfKtoGVqFJUurSVbS1HCoMtL5iNCOZo2LkLcfoq(Tny)ohhDxLLtDDo8UVHg9x4a532G97CC0DvwbsmR)QCaJvoNYPICoMtL5Wf9CylNt5uxNd9eeaWCalhuq2CQqlSCZ7xlyDmxe3i4aTMO20YW(0sQfOFJUuqxLwGdDJG(Qf4DFdn6VOSgYGPfAI49dyehsfU4cbqQCyLJe5uxNtOTI1XCrCJGd0AIfiXS(RYPUohZziS14Gt5awosiBo115uzorXiif0n8gaN8hdjv)7ZPcKyw)v5WwoNKnN66C4DFdn6VGUH3a4K)yiP6FFovGeZ6Vkh2YH39n0O)IYAidMwOjI3pGrCivqIVxmK4IleaHnNHYPUoh5KdPu0ZPc6gEdGt(JHKQ)95uHzrXnmNkY5yovMdV7BOr)fRJ5I4gbhO1elqIz9xLdB5W7(gA0FrznKbtl0eX7hWioKkiX3lgsCXfcGWMZq5uxNd4l03Olve7BaBDiNJ5iNCOZo2LkLcLa0JIU(da7pis7qovKZXC4DFdn6VG4ktHBemsmeybsmR)QCaJvovtohZHl65WgRCoiNJ5W7(gA0FbTOdV(dahGlG(XsJFUybsmR)QCaJvoNoqlSCZ7xlOSgYGPfAI49dyehsAtlZzrlPwG(n6sbDvAbo0nc6RwG39n0O)I1XCrCJGd0AIfiXS(RYHTCqbuMtDDoGVqFJUurSVbS1HCoMdV7BOr)fexzkCJGrIHalqIz9xLdy5iro115yodHTghCkhWY5Ke5uxNJ5me2ACWPCylNtYkBohZXCgcBno4uoGLZPtYMZXCQmhE33qJ(liUYu4gbJedbwGeZ6VkhWY5GCQRZH39n0O)cArhE9haoaxa9JLg)CXcKyw)v5awoOmN66C4DFdn6VaDL)aWQ4hdIZbPajM1FvoGLdkZPcTWYnVFTq0T7aUrWMiHPNyaQnTmvRwsTa9B0Lc6Q0cCOBe0xTGCYj0wH3pNEdUgfWi3LHWrXWVajM1FvohZPYCQmhE33qJ(l8(50BW1Oag5UmubsmR)QCaJvo8UVHg9xSoMlIBeCGwtSajM1FvohMZPCQRZb8f6B0LkI9nGToKtf5CmNkZro5y7LERGw0Hx)bGdWfq)yPXpxSq)gDPqo115W7(gA0FbTOdV(dahGlG(XsJFUybsmR)QCQiNJ5W7(gA0Fb6k)bGvXpgeNdsbsmR)QCoMdV7BOr)fexzkCJGrIHalqIz9xLZXCIIrqkkRHmyAHMiE)agXHuj0O)CQRZj0wX6yUiUrWbAnXcKyw)v5uro115yodHTghCkhWYPA1cl38(1c8(50BW1Oag5UmK20YunAj1c0VrxkORslWHUrqF1c8UVHg9xSoMlIBeCGwtSajM1FvoSLZbYMtDDoGVqFJUurSVbS1HCQRZXCgcBno4uoGLJeYQfwU59RfIUDhWiXqGAtlZjz1sQfOFJUuqxLwGdDJG(Qf4DFdn6VyDmxe3i4aTMybsmR)QCylNdKnN66CaFH(gDPIyFdyRd5uxNJ5me2ACWPCalNtOulSCZ7xlerqfbbXFaAtlZPtAj1cl38(1cxhGOPWO44aag6nTa9B0Lc6Q0MwMtsOLulq)gDPGUkTah6gb9vlW7(gA0FX6yUiUrWbAnXcKyw)v5WwohiBo115a(c9n6sfX(gWwhYPUohZziS14Gt5awoNKvlSCZ7xlG4qk62DqBAzoDGwsTa9B0Lc6Q0cCOBe0xTaV7BOr)fRJ5I4gbhO1elqIz9xLdB5CGS5uxNd4l03Olve7BaBDiN66CmNHWwJdoLdy5iHSAHLBE)AH95KYG7fZ37vBAzoHcAj1cl38(1crlaCJGnOZbrPfOFJUuqxL20YCcLAj1c0VrxkORslSCZ7xlSkrW3Nuy4YEneZB4E1cCOBe0xTa4l03OlvSoG7hhRiSb9heYY5yovMdV7BOr)fRJ5I4gbhO1elqIz9xLdB5iXPCQRZb8f6B0LkI9nGToKtf5CmNkZjqrXiif4YEneZB4EXbkkgbPeA0Fo115efJGuuwdzW0cnr8(bmIdPcKyw)v5WwoNoiN66CmNHWwJdoLZ5YH39n0O)I1XCrCJGd0AIfiXS(RYbSCqbzZ5yo8UVHg9xSoMlIBeCGwtSajM1FvoGLJeOmN66CmNHWwJdoLdy5ibkZPcTWVmKwyvIGVpPWWL9AiM3W9QnTmNyFAj1c0VrxkORslSCZ7xlSkrW3Nuy4YEneZB4E1cCOBe0xTGCYb8f6B0LkwhW9JJve2G(dcz5CmNkZjqrXiif4YEneZB4EXbkkgbPeA0Fo115uzoYjh6SJDPsPqja9OOR)aW(dI0oKtDDo2cbqwXCgcBnwk3WhiBoGLt1Mtf5CmNkZj0wX6yUiUrWbAnXcKyw)v5uxNdV7BOr)fRJ5I4gbhO1elqIz9xLZH5un5WwoMZqyRXbNYPICoMtumcsrznKbtl0eX7hWioKkXsZPUohZziS14Gt5awosGYCQql8ldPfwLi47tkmCzVgI5nCVAtlZPZIwsTWYnVFTGjs44pQJ)agPHCslq)gDPGUkTPL5u1QLulSCZ7xling6ia9hao6Uktlq)gDPGUkTPL5u1OLulq)gDPGUkTWYnVFTaKwP(daJCxgsPf4q3iOVAbBHaiRyodHTghCkhWY5ubL5uxNtL5uzo2cbqwrK2RjwKYTCylNQv2CQRZXwiaYkI0EnXIuULdySYrczZPICoMtL5SCZbNW0tmoPYHvoNYPUohBHaiRyodHTghCkh2YrIQjNkYPICQRZPYCSfcGSI5me2ASuUHLq2CylNdKnNJ5uzol3CWjm9eJtQCyLZPCQRZXwiaYkMZqyRXbNYHTCqbuiNkYPcTahi)syBHaitPL5K20YiHSAj1cl38(1cinpwrb8YEe0nchrlJwG(n6sbDvAtlJeN0sQfOFJUuqxLwGdDJG(QfONGaaMdy5GcYQfwU59RfyiMgce3i4Bm3d4aKwgL20YiHeAj1cl38(1cqxQ0lH9hRKUCslq)gDPGUkTPLrId0sQfwU59RfIwa4gbBqNdIslq)gDPGUkTPnTqGq24RPLulZjTKAHLBE)AbLuAHyX9dyLbDqiTa9B0Lc6Q0Mwgj0sQf83ii47vlunYQfKYnSiTxtuliBbLAHLBE)AbRJ5I4gbdYczwTa9B0Lc6Q0MwMd0sQfOFJUuqxLwGdDJG(QfIIrqkkcsVBalXsZPUoNOyeKIYAidMwOjI3pGrCivILMZXCcTvSoMlIBeCGwtSajM1Fvo115yodHTghCkhWyLd7twTWYnVFTG028(1MwguqlPwG(n6sbDvAbo0nc6RwGl6fMLD5CUC4IEoSXkhjY5yovMJTx6TIIG07gWc9B0Lc5uxNJCYj0wX6yUiUrWbAnXcKyw)v5urohZjkgbPOii9UbSeA0FohZPYCONGaawmNHWwJzw2Ldy5CkN66CS9sVvueKE3awOFJUuiNJ5W7(gA0Frrq6DdybsmR)QCalhjYPUoh5KJTx6TIIG07gWc9B0Lc5CmhE33qJ(lwhZfXncoqRjwGeZ6VkhWY5GCoMJCYb8f6B0LkI9nGToKtDDo0tqaalMZqyRXml7YbSCqHCoMdV7BOr)fexzkCJGrIHalqIz9xLdy5CQGYCQqlSCZ7xlajWjOIWIlKrBAzqPwsTa9B0Lc6Q0cl38(1ciUYWnc2ejmAr3iS5aiOwGdDJG(Qf4IEHzzxoNlhUONdBSY5GCoMtumcsrrq6Ddyj0O)CoMtumcsrrKj6pamCbqLqJ(Z5yovMd9eeaWI5me2AmZYUCalNt5uxNJTx6TIIG07gWc9B0Lc5CmhE33qJ(lkcsVBalqIz9xLdy5iro115iNCS9sVvueKE3awOFJUuiNJ5W7(gA0FX6yUiUrWbAnXcKyw)v5awohKZXCKtoGVqFJUurSVbS1HCQRZHEccayXCgcBnMzzxoGLdkKZXC4DFdn6VG4ktHBemsmeybsmR)QCalNtfuMtfAboq(LW2cbqMslZjTPLH9PLulq)gDPGUkTWYnVFTG5aiiw6Ez0cCOBe0xTGCYH3mrnocsli5CmhUOxyw2LZ5YHl65WgRCKiNJ5uzo2EP3kkcsVBal0VrxkKtDDoYjNqBfRJ5I4gbhO1elqIz9xLtf5CmNOyeKIIit0Fay4cGkHg9NZXCIIrqkkcsVBalHg9NZXCQmh6jiaGfZziS1yMLD5awoNYPUohBV0BffbP3nGf63OlfY5yo8UVHg9xueKE3awGeZ6VkhWYrICQRZro5y7LEROii9UbSq)gDPqohZH39n0O)I1XCrCJGd0AIfiXS(RYbSCoiNJ5iNCaFH(gDPIyFdyRd5uxNd9eeaWI5me2AmZYUCalhuiNJ5W7(gA0FbXvMc3iyKyiWcKyw)v5awoNkOmNk0cCG8lHTfcGmLwMtAtlZzrlPwG(n6sbDvAbo0nc6Rwqo5y7LERG4kd3iytKWOfDJWMdGGf63OlfY5yosHe4ya8q5uXCaeelDVm5CmhZzOCaJvohOfwU59Rf4Iog9coPnTmvRwsTa9B0Lc6Q0cl38(1c89EXl38(XxxzAbLbDUPL5KwGdDJG(QfS9sVvueKE3awOFJUuqlCDLH)LH0c8awrq6DdO20YunAj1c0VrxkORslSCZ7xlW37fVCZ7hFDLPfug05MwMtAbo0nc6Rwqo5y7LEROii9UbSq)gDPGw46kd)ldPf4bSIq0MwMtYQLulq)gDPGUkTah6gb9vlefJGuueKE3awILQfwU59Rf479IxU59JVUY0cxxz4FziTGIG07gqTPL50jTKAb63Olf0vPf4q3iOVAHLBo4eMEIXjvoGLZbAHLBE)Ab(EV4LBE)4RRmTW1vg(xgslOmTPL5KeAj1c0VrxkORslWHUrqF1cl3CWjm9eJtQCyJvohOfwU59Rf479IxU59JVUY0cxxz4FziTW2K20MwqkK4nt0AAj1YCslPwy5M3VwqABE)Ab63Olf0vPnTmsOLulq)gDPGUkTqlvlOitlSCZ7xla(c9n6sAbW3BmPfOZo2LkLcfoq(Tny)ohhDxLLtDDo0zh7sLsHYnwzWowHb03a9yP3yMfaLtDDo0zh7sLsHcG7g81AOchTbauo115qNDSlvkfkaUBWxRHkmdf2717pN66COZo2LkLcfiX0gHbe7H95eoqG7Csla(cX)YqAbRd4(XXkcBq)bHmTPL5aTKAb63Olf0vPfAPAbfzAHLBE)AbWxOVrxsla(EJjTaV7BOr)fRJ5I4gbhO1elqIz9xLZH5un5Wwo2cbqwXCgcBno4uo115iNCS9sVvueKE3awOFJUuiNJ5iNCaFH(gDPI1bC)4yfHnO)GqwohZHo7yxQukucqpk66paS)GiTd5CmhBHaiRyodHTglLB4dKnhWY50bYMZXCSfcGSI5me2ASuUHpq2CylNQnN66CmNHWwJdoLdy5C6azZ5yoMZqyRXbNYHTC4DFdn6VOii9UbSajM1FvohZH39n0O)IIG07gWcKyw)v5WwosKtDDorXiiffbP3nGLyP5CmhBHaiRyodHTghCkh2Y50jTa4le)ldPfe7BaBDqBAzqbTKAb63Olf0vPfAPAbfzAHLBE)AbWxOVrxsla(EJjTWPQrlWHUrqF1cYjhBV0BffbP3nGf63OlfY5yovMd4l03OlvSoG7hhRiSb9heYYPUoh6SJDPsPqzvIGVpPWWL9AiM3W9MtfAbWxi(xgslG0VHBeS0gnbXsHeVzIwdZf3)PR20YGsTKAb63Olf0vPf(LH0cl7Pex4QWi9B4gblTrtqTWYnVFTWYEkXfUkms)gUrWsB0euBAzyFAj1c0VrxkORslWHUrqF1cYjhBV0BffbP3nGf63OlfYPUoh5KJTx6TcIRmCJGnrcJw0ncBoacwOFJUuqlSCZ7xlWfDCumuzAtlZzrlPwG(n6sbDvAbo0nc6RwW2l9wbXvgUrWMiHrl6gHnhabl0VrxkKtDDoKsrpNk8(rUo3W7hWkd6iuHzrXnulSCZ7xlWfDm6fCsBAzQwTKAHLBE)Ab)bVbHWSlMETa9B0Lc6Q0MwMQrlPwy5M3Vwaq8cd((4gbVShbBtulq)gDPGUkTPnTW2KwsTmN0sQfOFJUuqxLwy5M3Vwa6k)bGvXpgeNdIwGdDJG(QfQmhBV0Bf0Io86paCaUa6hln(5If63OlfY5yo8UVHg9xql6WR)aWb4cOFS04NlwGeZ6VkhWYbL5urohZH39n0O)cIRmfUrWiXqGfiXS(RYHTCoqlWbYVe2wiaYuAzoPnTmsOLulSCZ7xlGw0Hx)bGdWfq)yPXpxulq)gDPGUkTPL5aTKAb63Olf0vPf4q3iOVAb5KJuibogapuovmhabXs3ltohZHl65agRCoLZXCONGaaMdy5Gsz1cl38(1c0tqao75pamDD25qTPLbf0sQfOFJUuqxLwy5M3VwaXvMc3iyKyiqTah6gb9vlWf9cZYUCoxoCrph2yLZbAboq(LW2cbqMslZjTPLbLAj1c0VrxkORslWHUrqF1crXiifySs0Fayu8gimA)dLqJ(1cl38(1cWyLO)aWO4nqy0(h0Mwg2NwsTa9B0Lc6Q0cCOBe0xTaVzIASYGoiuohZPYCQmNkZHl65WwohKtDDo8UVHg9xqCLPWncgjgcSajM1FvoSLd7lNkY5yovMdx0ZHnw5GYCQRZH39n0O)cIRmfUrWiXqGfiXS(RYHTCKiNkYPICQRZHEccayXCgcBnMzzxoGXkNdYPcTWYnVFTGsQ)V)aWC4(egeNdI20YCw0sQfOFJUuqxLwGdDJG(Qf4IEHzzxoNlhUONdBSYrcTWYnVFTaKaNGkclUqgTPLPA1sQfOFJUuqxLwGdDJG(Qf4IEoGXkNd0cl38(1cCrhhfdvM20YunAj1c0VrxkORslWHUrqF1cCrVWSSlNZLdx0ZHnw5CGwy5M3VwaXvgUrWMiHrl6gHnhab1MwMtYQLulq)gDPGUkTWYnVFTG5aiiw6Ez0cCOBe0xTax0lml7Y5C5Wf9CyJvosKZXCQmh5KJTx6TIOByEZe1f63OlfYPUoh5KdVzIACeKwqYPcTahi)syBHaitPL5K20YC6KwsTa9B0Lc6Q0cCOBe0xTGCYH3mrnocsliAHLBE)AbUOJrVGtAtlZjj0sQfOFJUuqxLwy5M3Vwi6UCq6yddIZbrlWHUrqF1c8MjQXkd6Gq5CmNkZjkgbPe1GGLcBEjwAo115uzo2EP3kIUH5ntuxOFJUuiNJ5ifsGJbWdLtfZbqqS09YKZXC4IEoGLdkKtf5uHwGdKFjSTqaKP0YCsBAtlWdyfbP3nGAj1YCslPwG(n6sbDvAbo0nc6RwikgbPOii9UbSeA0Fo115yodHTghCkhWYrcuQfwU59Rf8h8gecZUy61Mwgj0sQfOFJUuqxLwGdDJG(QfIIrqkkcsVBalHg9NZXCQmhZziS14Gt5WwoNQwuMtDDo8UVHg9xueKE3awGeZ6VkhWyLZzjNkYPUohZziS14Gt5awohGsTWYnVFTaG4fg89XncEzpc2MO20YCGwsTa9B0Lc6Q0cCOBe0xTaV7BOr)ffbP3nGfiXS(RYHTCKq2CQRZXCgcBno4uoGLJeYQfwU59RfIUDhWiXqGAtldkOLulq)gDPGUkTah6gb9vlW7(gA0Frrq6DdybsmR)QCylhjKnN66CmNHWwJdoLdy5CcLAHLBE)AHicQiii(dqBAzqPwsTa9B0Lc6Q0cCOBe0xTqumcsrrq6Ddyj0O)CoMdx0lml7Y5C5Wf9CyJvoNY5yo0tqaalMZqyRXml7YHnw5iBbLAHLBE)AHfY3NWwdH0BAtld7tlPwy5M3Vw46aenfgfhhaWqVPfOFJUuqxL20YCw0sQfOFJUuqxLwGdDJG(Qf4DFdn6VOii9UbSajM1FvoSLJeYMtDDoMZqyRXbNYbSCojRwy5M3VwaXHu0T7G20YuTAj1c0VrxkORslWHUrqF1c8UVHg9xueKE3awGeZ6Vkh2YrczZPUohZziS14Gt5awosiRwy5M3VwyFoPm4EX89E1MwMQrlPwy5M3VwiAbGBeSbDoikTa9B0Lc6Q0MwMtYQLulq)gDPGUkTah6gb9vliNCaFH(gDPIyFdyRdAHLBE)AbRJ5I4gbhO1e1MwMtN0sQfOFJUuqxLwGdDJG(QfIIrqkkcsVBalHg9NZXCQmhE33qJ(lkcsVBalqIz9xLdB5iHS5uxNdV7BOr)ffbP3nGfiXS(RYbSCKiNkYPUohZziS14Gt5awoNqPwy5M3Vwi62Da3iytKW0tma1MwMtsOLulq)gDPGUkTWYnVFTWQebFFsHHl71qmVH7vlWHUrqF1cbkkgbPax2RHyEd3loqrXiiLqJ(ZPUoNOyeKIIG07gWcKyw)v5Wwovto115yodHTghCkhWYrcuQf(LH0cRse89jfgUSxdX8gUxTPL50bAj1c0VrxkORslWHUrqF1crXiiffbP3nGLqJ(Z5yovMdV7BOr)ffbP3nGfiXS(RYHTCoHYCQRZH39n0O)IIG07gWcKyw)v5awosKtf5uxNJ5me2ACWPCalhjKvlSCZ7xlGUH3a4K)yiP6FFoPnTmNqbTKAb63Olf0vPf4q3iOVAHOyeKIIG07gWsOr)5CmNkZH39n0O)IIG07gWcKyw)v5uxNdV7BOr)fE)C6n4AuaJCxgQWfxiasLdRCKiNkY5yoYjNqBfE)C6n4AuaJCxgchfd)cKyw)v5CmNkZH39n0O)c0v(daRIFmiohKcKyw)v5CmhE33qJ(liUYu4gbJedbwGeZ6VkN66CmNHWwJdoLdy5uT5uHwy5M3VwG3pNEdUgfWi3LH0MwMtOulPwy5M3Vwqrq6DdOwG(n6sbDvAtlZj2NwsTa9B0Lc6Q0cCOBe0xTqumcsrrq6Ddyj0OFTWYnVFTGjs44pQJ)agPHCsBAzoDw0sQfOFJUuqxLwGdDJG(QfIIrqkkcsVBalHg9RfwU59RfKgdDeG(dahDxLPnTmNQwTKAb63Olf0vPfwU59RfG0k1FayK7YqkTah6gb9vlefJGuueKE3awcn6pNJ5uzo2cbqwXCgcBno4uoGLZPckZPUoNkZPYCSfcGSIiTxtSiLB5WwovRS5uxNJTqaKveP9AIfPClhWyLJeYMtf5CmNkZz5MdoHPNyCsLdRCoLtDDo2cbqwXCgcBno4uoSLJevtovKtf5uxNtL5yleazfZziS1yPCdlHS5WwohiBohZPYCwU5Gty6jgNu5WkNt5uxNJTqaKvmNHWwJdoLdB5GcOqovKtf5uHwGdKFjSTqaKP0YCsBAzovnAj1c0VrxkORslWHUrqF1crXiiffbP3nGLqJ(1cl38(1cinpwrb8YEe0nchrlJ20YiHSAj1c0VrxkORslWHUrqF1crXiiffbP3nGLqJ(Z5yo0tqaaZbSCqbz1cl38(1cmetdbIBe8nM7bCaslJsBAzK4KwsTa9B0Lc6Q0cCOBe0xTqumcsrrq6Ddyj0OFTWYnVFTa0Lk9sy)XkPlN0MwgjKqlPwG(n6sbDvAbo0nc6RwikgbPOii9UbSeA0Vwy5M3VwiAbGBeSbDoikTPnTGY0sQL5KwsTWYnVFTaArhE9haoaxa9JLg)CrTa9B0Lc6Q0Mwgj0sQfOFJUuqxLwGdDJG(QfS9sVvueKE3awOFJUuiN66C4DFdn6VyDmxe3i4aTMybsmR)QCylh2xo115a(c9n6sfX(gWwh0cl38(1ciUYu4gbJedbQnTmhOLulq)gDPGUkTWYnVFTa0v(daRIFmioheTah6gb9vlW7(gA0FX6yUiUrWbAnXcKyw)v5WwosKtDDoGVqFJUurSVbS1bTahi)syBHaitPL5K20YGcAj1c0VrxkORslWHUrqF1crXiifySs0Fayu8gimA)dLqJ(Z5yol3CWjm9eJtQCylNtAHLBE)AbySs0Fayu8gimA)dAtldk1sQfOFJUuqxLwGdDJG(Qf4IEHzzxoNlhUONdB5CslSCZ7xlajWjOIWIlKrBAzyFAj1c0VrxkORslSCZ7xlG4kd3iytKWOfDJWMdGGAbo0nc6RwGl65awohOf4a5xcBleazkTmN0MwMZIwsTa9B0Lc6Q0cCOBe0xTax0Zbmw5CqohZHEccayoGLdkLvlSCZ7xlqpbb4SN)aW01zNd1MwMQvlPwG(n6sbDvAbo0nc6RwGl6fMLD5CUC4IEoSLJS5CmNLBo4eMEIXjvoSY5uo115Wf9cZYUCoxoCrph2Y5Kwy5M3VwGl64OyOY0MwMQrlPwG(n6sbDvAHLBE)AbZbqqS09YOf4q3iOVAbEZe1yLbDqOCoMdx0lml7Y5C5Wf9CylNdY5yoYjNqBfRJ5I4gbhO1elqIz9xLZXCIIrqkkRHmyAHMiE)agXHuj0OFTahi)syBHaitPL5K20YCswTKAHLBE)AbUOJrVGtAb63Olf0vPnTmNoPLulq)gDPGUkTah6gb9vlWBMOgRmOdcLZXCIIrqkH95eUrWCrhf7fiTCtlSCZ7xlOK6)7pamhUpHbX5GOnTmNKqlPwG(n6sbDvAHLBE)AHO7YbPJnmioheTah6gb9vlWBMOgRmOdcLZXCQmNkZH39n0O)I1XCrCJGd0AIfiXS(RYHTCKiN66CaFH(gDPIyFdyRd5urohZPYC4DFdn6VaDL)aWQ4hdIZbPajM1FvoSLJe5CmhE33qJ(liUYu4gbJedbwGeZ6Vkh2YrICQRZH39n0O)c0v(daRIFmiohKcKyw)v5awohKZXC4DFdn6VG4ktHBemsmeybsmR)QCylNdY5yoCrph2YrICQRZH39n0O)c0v(daRIFmiohKcKyw)v5WwohKZXC4DFdn6VG4ktHBemsmeybsmR)QCalNdY5yoCrph2YbfYPUohUONdB5GYCQiN66CIIrqkrniyPWMxILMtfAboq(LW2cbqMslZjTPL50bAj1c0VrxkORslSCZ7xlyoacILUxgTah6gb9vlWBMOgRmOdcLZXC4IEHzzxoNlhUONdB5CslWbYVe2wiaYuAzoPnTmNqbTKAb)nccJLAAHtAHLBE)AbKlq)bGveuk9ggeNdIwG(n6sbDvAtlZjuQLulq)gDPGUkTWYnVFTq0D5G0XggeNdIwGdDJG(QfQmhE33qJ(liUYu4gbJedbwGeZ6VkhWY5GCoMdx0ZHvosKtDDo0tqaalMZqyRXml7YbSCoLtf5CmNkZrkKahdGhkNkMdGGyP7LjN66C4IEHzzxoNlhUONdy5irovOf4a5xcBleazkTmN0M20ckcsVBa1sQL5KwsTa9B0Lc6Q0cCOBe0xTqumcsrrq6DdybsmR)QCalNt5uxNZYnhCctpX4Kkh2Y5Kwy5M3VwaXvMc3iyKyiqTPLrcTKAb63Olf0vPf4q3iOVAbEZe1yLbDqOCoMtL5SCZbNW0tmoPYHTCKiN66CwU5Gty6jgNu5WwoNY5yoYjhE33qJ(lqx5paSk(XG4CqkXsZPcTWYnVFTGsQ)V)aWC4(egeNdI20YCGwsTa9B0Lc6Q0cl38(1cqx5paSk(XG4Cq0cCOBe0xTaVzIASYGoiKwGdKFjSTqaKP0YCsBAzqbTKAb)nccJLAyhrlaGhkqIz9xXswTWYnVFTaIRmfUrWiXqGAb63Olf0vPnTmOulPwG(n6sbDvAHLBE)Abexz4gbBIegTOBe2CaeulWHUrqF1cCrphWY5aTahi)syBHaitPL5K20YW(0sQfOFJUuqxLwGdDJG(Qf4IEHzzxoNlhUONdB5CkNJ5qpbbaSyodHTgZSSlhWY5Kwy5M3VwasGtqfHfxiJ20YCw0sQfOFJUuqxLwy5M3Vwi6UCq6yddIZbrlWHUrqF1c8MjQXkd6Gq5uxNJCYX2l9wr0nmVzI6c9B0LcAboq(LW2cbqMslZjTPLPA1sQfwU59Rfus9)9haMd3NWG4Cq0c0VrxkORsBAtBAbWjOY7xlJeYkHSYEWbYQfqVW3FakTq1hksUlt1VmS)p)5KJKIuooJ0gA5G0WCKR8awriY1CG0zh7qkKJQzOC2yRzwJc5Wf3haPkjOS)6pLZj235pNZRFWjOrHCKRMZqyRXs5gM9J9RajM1FLCnhRZrUAodHTglLBy2p2p5AovEIDvusqtqR(qrYDzQ(LH9)5pNCKuKYXzK2qlhKgMJCvkK4nt0AY1CG0zh7qkKJQzOC2yRzwJc5Wf3haPkjOS)6pLZbN)CoV(bNGgfYrUAodHTglLBy2p2VcKyw)vY1CSoh5Q5me2ASuUHz)y)KR5uPeSRIscAcA1pJ0gAuiNZsol38(Z56ktvsq1cBSj2qTGGZCEAbPWgXVKw4m5u95Fa9EbHG5C(0pijONjhrZKQo)Ylpa3eJJk8MrELZeFxZ7NdxetELZWLpb9m5C(SqUyohilQ5iHSsiBcAc6zY58e3haPo)jONjNZLJCNyAWPCeKslmNQ39d5iyqhekhE)bZ7xLtLI7hUuiNiG5SHq)vusqptoNlh5oX0Gt5uDcN1CGeVzyOpSM3FovI2V3CIiEZq5S5ifsivusqptoNlNZtCFauo2cbqg2rYX6C4a5xcBleazQsc6zY5C5i3jMgCkh6jiaG5WxP5Wfjoi5G0WCQoxzQCAKCQUyiWCQu5m5eCeecspNYXv58eGRdWJUeQ5efB5i9UaZj4iieKEoLJRYr5aEhX57BvusqptoNlhuuiqHCKBkkNQFJyu5uPb9heYuOMdz8sfLe0e0ZKt1d7iESrHCIiKgs5WBMO1YjIa4VQKdkIZjPMkNV)ZjUqgK4Bol38(v50)fyjb9m5SCZ7xvKcjEZeTglK7Qajb9m5SCZ7xvKcjEZeT2HSKhP7qc6zYz5M3VQifs8MjATdzj)gdGHEBnV)e0ZKJWVsvITLdC9qorXiiuihLTMkNicPHuo8MjATCIia(RYz)qosH05K2M5pGCCvoH(Psc6zYz5M3VQifs8MjATdzjV6xPkX2WkBnvc6YnVFvrkK4nt0AhYsEPT59NGEMCoprIdIkhhjhGDCoIl4uoBog0Fqilh6SJDPsPqoM4A5GEFtLJ15er5eROqowdGmrcMdA3eZrYwUKGUCZ7xvKcjEZeT2HSKh8f6B0Lq9xgIL1bC)4yfHnO)GqgQTuwkYqf89gtSOZo2LkLcfoq(Tny)ohhDxLvxtNDSlvkfk3yLb7yfgqFd0JLEJzwauDnD2XUuPuOa4UbFTgQWrBaavxtNDSlvkfkaUBWxRHkmdf2717VUMo7yxQukuGetBegqSh2Nt4abUZPe0ZKd7pwOVrxkhtCTCq73BogDV5aSJZXrYbyhNdA)EZ5jkKJ15GEDlhRZHVklhjB5I8HoNVTCqVVLJ15WxLLJB5Swo79MZ(azAiLGUCZ7xvKcjEZeT2HSKh8f6B0Lq9xgILyFdyRdO2szPidvW3BmXI39n0O)I1XCrCJGd0AIfiXS(RoSAyZwiaYkMZqyRXbNQRLJTx6TIIG07gWc9B0LchLd4l03OlvSoG7hhRiSb9heYosNDSlvkfkbOhfD9ha2FqK2HJ2cbqwXCgcBnwk3WhiBbsmR)kWoDGShTfcGSI5me2ASuUHpq2cKyw)vSvT11MZqyRXbNa70bYE0CgcBno4eB8UVHg9xueKE3awGeZ6V6iV7BOr)ffbP3nGfiXS(RytI66OyeKIIG07gWsS0J2cbqwXCgcBno4eBNoLGUCZ7xvKcjEZeT2HSKh8f6B0Lq9xgIfs)gUrWsB0eelfs8MjAnmxC)NUO2szPidvW3BmX6u1GQJWso2EP3kkcsVBal0VrxkCSsWxOVrxQyDa3powryd6piKvxtNDSlvkfkRse89jfgUSxdX8gU3ksqxU59RksHeVzIw7qwYhRiSBedQ)YqSw2tjUWvHr63WncwAJMGjOl38(vfPqI3mrRDil55IookgQmuDewYX2l9wrrq6DdyH(n6sH6A5y7LERG4kd3iytKWOfDJWMdGGf63OlfsqxU59RksHeVzIw7qwYZfDm6fCcvhHLTx6TcIRmCJGnrcJw0ncBoacwOFJUuOUMuk65uH3pY15gE)awzqhHkmlkUHjOl38(vfPqI3mrRDil59h8gecZUy6XMiHrl6gHnhabtqxU59RksHeVzIw7qwYdiEHbFFCJGx2JGTjMGMGEMCQEyhXJnkKdbobbMJ5muoMiLZYTgMJRYzbF97gDPsc6YnVFflLuAHyX9dyLbDqOe0LBE)QdzjV1XCrCJGbzHmlQ(Bee89YQAKfvPCdls71ezjBbLjONjh5MIYrABE)54i5iqq6DdyoUkNyPOMtdZjQnXCeQEQUC2pKJKTCjNfs5elf1CAyoMiLJTqaKLdA)EZj4uoODt0)CyFYMJI49hujOl38(vhYsEPT59JQJWkkgbPOii9UbSelTUokgbPOSgYGPfAI49dyehsLyPhdTvSoMlIBeCGwtSajM1FvDT5me2ACWjWyX(KnbD5M3V6qwYdjWjOIWIlKbvhHfx0lml7ohx0zJLehR02l9wrrq6DdyH(n6sH6A5eARyDmxe3i4aTMybsmR)QkogfJGuueKE3awcn6)yL0tqaalMZqyRXml7a7uDTTx6TIIG07gWc9B0Lch5DFdn6VOii9UbSajM1FfysuxlhBV0BffbP3nGf63OlfoY7(gA0FX6yUiUrWbAnXcKyw)vGDWr5a(c9n6sfX(gWwhQRPNGaawmNHWwJzw2bgkCK39n0O)cIRmfUrWiXqGfiXS(Ra7ubLvKGEMCKBkkNQRTQpjZXrYjhGDColKYHXvk)bKZA5CPvz5CqoCrh1CqrFiNCueKE3aIAoOOpKtov1w1tolKY5BlNyPOMdksg5soa74Ci3ejyolKYzJ6ylhRZHVsZHEccaiQ50WCueKE3aMJRYzJ6ylhRZH3muoXsrnNgMJKTCjhxLZg1XwowNdVzOCILIAonmNQRRUCCvo8MXFa5elnN9d5aSJZbTFV5WxP5qpbbamhv3Fc6YnVF1HSKhXvgUrWMiHrl6gHnhabrLdKFjSTqaKPyDcvhHfx0lml7ohx0zJ1bhJIrqkkcsVBalHg9FmkgbPOiYe9hagUaOsOr)hRKEccayXCgcBnMzzhyNQRT9sVvueKE3awOFJUu4iV7BOr)ffbP3nGfiXS(RatI6A5y7LEROii9UbSq)gDPWrE33qJ(lwhZfXncoqRjwGeZ6VcSdokhWxOVrxQi23a26qDn9eeaWI5me2AmZYoWqHJ8UVHg9xqCLPWncgjgcSajM1FfyNkOSIe0ZKJCtr5i55BoosoULd6(TCIG0csomRYiiquZbfjJCjNfs5W4kL)aYzTCU0QSCKihUOJAoOizKl5e5aYH39n0OFvolKY5BlNyPOMdksg5soa74Ci3ejyolKYzJ6ylhRZHVsZHEccaiQ50WCueKE3aMJRYzJ6ylhRZH3muoXsrnNgMJKTCjhxLdVz8hqoXsrnNgMt11vxoUkhEZ4pGCILMZ(HCa2X5G2V3C4R0CONGaaMJQ7pbD5M3V6qwYBoacILUxgu5a5xcBleazkwNq1ryjhEZe14iiTGCKl6fMLDNJl6SXsIJvA7LEROii9UbSq)gDPqDTCcTvSoMlIBeCGwtSajM1FvfhJIrqkkImr)bGHlaQeA0)XOyeKIIG07gWsOr)hRKEccayXCgcBnMzzhyNQRT9sVvueKE3awOFJUu4iV7BOr)ffbP3nGfiXS(RatI6A5y7LEROii9UbSq)gDPWrE33qJ(lwhZfXncoqRjwGeZ6VcSdokhWxOVrxQi23a26qDn9eeaWI5me2AmZYoWqHJ8UVHg9xqCLPWncgjgcSajM1FfyNkOSIe0LBE)Qdzjpx0XOxWjuDewYX2l9wbXvgUrWMiHrl6gHnhabl0VrxkCukKahdGhkNkMdGGyP7L5O5meySoibD5M3V6qwYZ37fVCZ7hFDLH6VmelEaRii9UbevhHLTx6TIIG07gWc9B0LcjOl38(vhYsE(EV4LBE)4RRmu)LHyXdyfHGQJWso2EP3kkcsVBal0VrxkKGEMCoV9EZXePCeii9UbmNLBE)5CDLLJJKJabP3nG54QC4Xqi92fyoXstqxU59RoKL889EXl38(XxxzO(ldXsrq6DdiQocROyeKIIG07gWsS0e0ZKZ5T3BoMiLJGK5SCZ7pNRRSCCKCmrcs5SqkhjYPH5CjLkh6jgNujOl38(vhYsE(EV4LBE)4RRmu)LHyPmuDewl3CWjm9eJtkWoib9m5CE79MJjs5GI6QNCwU59NZ1vwoosoMibPCwiLZb50WCyAiLd9eJtQe0LBE)QdzjpFVx8YnVF81vgQ)YqS2Mq1ryTCZbNW0tmoPyJ1bjOjONjhue38(vfuux9KJRYXFJ(afYbPH5eROCq7MyovVe3Cogffc4Z7sl4uo7hYHhdH0BxG58efu5yDoruoTuZzC2JcjOl38(vLTjwqx5paSk(XG4CqqLdKFjSTqaKPyDcvhHvL2EP3kOfD41Fa4aCb0pwA8Zfl0VrxkCK39n0O)cArhE9haoaxa9JLg)CXcKyw)vGHYkoY7(gA0FbXvMc3iyKyiWcKyw)vSDqc6YnVFvzB6qwYJw0Hx)bGdWfq)yPXpxmbD5M3VQSnDil5PNGaC2ZFay66SZHO6iSKJuibogapuovmhabXs3lZrUOdgRthPNGaacgkLnbD5M3VQSnDil5rCLPWncgjgcevoq(LW2cbqMI1juDewCrVWSS7CCrNnwhKGUCZ7xv2MoKL8WyLO)aWO4nqy0(hq1ryffJGuGXkr)bGrXBGWO9pucn6pbD5M3VQSnDil5vs9)9haMd3NWG4Cqq1ryXBMOgRmOdcDSYkRKl6SDqDnV7BOr)fexzkCJGrIHalqIz9xXg7RIJvYfD2yHY6AE33qJ(liUYu4gbJedbwGeZ6VInjQOI6A6jiaGfZziS1yMLDGX6GksqxU59RkBthYsEibobvewCHmO6iS4IEHzz354IoBSKibD5M3VQSnDil55IookgQmuDewCrhmwhKGUCZ7xv2MoKL8iUYWnc2ejmAr3iS5aiiQoclUOxyw2DoUOZgRdsqxU59RkBthYsEZbqqS09YGkhi)syBHaitX6eQoclUOxyw2DoUOZgljowPCS9sVveDdZBMOUq)gDPqDTC4ntuJJG0csfjOl38(vLTPdzjpx0XOxWjuDewYH3mrnocslijONjNLBE)QY20HSKh5c0FayfbLsVHbX5GGQJWkkgbPe1GGLcBEj0OFu93iimwQX6uc6YnVFvzB6qwYhDxoiDSHbX5GGkhi)syBHaitX6eQoclEZe1yLbDqOJvgfJGuIAqWsHnVelTUUsBV0Bfr3W8MjQl0VrxkCukKahdGhkNkMdGGyP7L5ix0bdfQOIe0e0ZKZ519n0OFvc6YnVFvHhWkcHL)G3Gqy2ftp2ejmAr3iS5aiiQocROyeKIIG07gWsOr)11MZqyRXbNatcuMGUCZ7xv4bSIqoKL8aIxyW3h3i4L9iyBIO6iSmNHWwJdoX2PQfL11Yb8f6B0LkI9nGToCK39n0O)I1XCrCJGd0AIfiXS(RaJ1juOU2CgcBno4eyhGYe0LBE)QcpGveYHSKhDdVbWj)Xqs1)(CcvhHfV7BOr)fRJ5I4gbhO1elqIz9xXgkR26AE33qJ(lwhZfXncoqRjwGeZ6VcmjQRbFH(gDPIyFdyRd11MZqyRXbNatcztqptoYnfLdkcY3NYrYgcP3YXrYbyhNZcPCyCLYFa5SwoxAvwoNY58e9C2pKd6(LRwo8vAo0tqaaZbTBI(NJSfuMJI49hujOl38(vfEaRiKdzj)c57tyRHq6nuDewCrVWSS7CCrNnwNospbbaSyodHTgZSSJnwYwqzc6YnVFvHhWkc5qwYBDmxe3i4aTMiQocl5a(c9n6sfX(gWwhowPCOZo2LkLcfoq(Tny)ohhDxLvxZ7(gA0FHdKFBd2VZXr3vzfiXS(RaJ1Pkowjx0z7uDn9eeaqWqbzRibD5M3VQWdyfHCil5vwdzW0cnr8(bmIdjur1ryX7(gA0FrznKbtl0eX7hWioKkCXfcGuSKOUo0wX6yUiUrWbAnXcKyw)v11MZqyRXbNatczRRRmkgbPGUH3a4K)yiP6FFovGeZ6VITtYwxZ7(gA0FbDdVbWj)Xqs1)(CQajM1FfB8UVHg9xuwdzW0cnr8(bmIdPcs89IHexCHaiS5muDTCiLIEovq3WBaCYFmKu9VpNkmlkUHvCSsE33qJ(lwhZfXncoqRjwGeZ6VInE33qJ(lkRHmyAHMiE)agXHubj(EXqIlUqae2CgQUg8f6B0LkI9nGToCuo0zh7sLsHsa6rrx)bG9hePDOIJ8UVHg9xqCLPWncgjgcSajM1FfySQMJCrNnwhCK39n0O)cArhE9haoaxa9JLg)CXcKyw)vGX60bjOl38(vfEaRiKdzjF0T7aUrWMiHPNyaIQJWI39n0O)I1XCrCJGd0AIfiXS(RydfqzDn4l03Olve7BaBD4iV7BOr)fexzkCJGrIHalqIz9xbMe11MZqyRXbNa7Ke11MZqyRXbNy7KSYE0CgcBno4eyNoj7Xk5DFdn6VG4ktHBemsmeybsmR)kWoOUM39n0O)cArhE9haoaxa9JLg)CXcKyw)vGHY6AE33qJ(lqx5paSk(XG4CqkqIz9xbgkRibD5M3VQWdyfHCil559ZP3GRrbmYDziuDewYj0wH3pNEdUgfWi3LHWrXWVajM1F1XkRK39n0O)cVFo9gCnkGrUldvGeZ6Vcmw8UVHg9xSoMlIBeCGwtSajM1F1HNQRbFH(gDPIyFdyRdvCSs5y7LERGw0Hx)bGdWfq)yPXpxSq)gDPqDnV7BOr)f0Io86paCaUa6hln(5IfiXS(RQ4iV7BOr)fOR8hawf)yqCoifiXS(RoY7(gA0FbXvMc3iyKyiWcKyw)vhJIrqkkRHmyAHMiE)agXHuj0O)66qBfRJ5I4gbhO1elqIz9xvrDT5me2ACWjWQ2e0ZKJCtr5u1T7qovxmeyoosos2XCXCAKCKl0AIYvvo8UVHg9NJRYbaKwJG5yI7NZbYMtLMORYXF(noqQCql6xkhjB5soUkhEmesVDbMZYnhCQcuZPH50ii5W7(gA0FoOfPphGDColKYrSVb)bKt)wNJKTCb1CAyoOfPphtKYXwiaYYXv5SrDSLJ15eCkbD5M3VQWdyfHCil5JUDhWiXqGO6iS4DFdn6VyDmxe3i4aTMybsmR)k2oq26AWxOVrxQi23a26qDT5me2ACWjWKq2e0LBE)QcpGveYHSKpIGkccI)aq1ryX7(gA0FX6yUiUrWbAnXcKyw)vSDGS11GVqFJUurSVbS1H6AZziS14GtGDcLjOl38(vfEaRiKdzj)1biAkmkooaGHElbD5M3VQWdyfHCil5rCifD7oGQJWI39n0O)I1XCrCJGd0AIfiXS(Ry7azRRbFH(gDPIyFdyRd11MZqyRXbNa7KSjOl38(vfEaRiKdzj)(CszW9I579IQJWI39n0O)I1XCrCJGd0AIfiXS(Ry7azRRbFH(gDPIyFdyRd11MZqyRXbNatcztqxU59Rk8awrihYs(OfaUrWg05GOsqxU59Rk8awrihYs(yfHDJyq9xgI1QebFFsHHl71qmVH7fvhHf4l03OlvSoG7hhRiSb9heYowjV7BOr)fRJ5I4gbhO1elqIz9xXMeNQRbFH(gDPIyFdyRdvCSYaffJGuGl71qmVH7fhOOyeKsOr)11rXiifL1qgmTqteVFaJ4qQajM1FfBNoOU2CgcBno4054DFdn6VyDmxe3i4aTMybsmR)kWqbzpY7(gA0FX6yUiUrWbAnXcKyw)vGjbkRRnNHWwJdobMeOSIe0LBE)QcpGveYHSKpwry3igu)LHyTkrW3Nuy4YEneZB4Er1ryjhWxOVrxQyDa3powryd6piKDSYaffJGuGl71qmVH7fhOOyeKsOr)11vkh6SJDPsPqja9OOR)aW(dI0ouxBleazfZziS1yPCdFGSfiXS(RaRAR4yLH2kwhZfXncoqRjwGeZ6VQUM39n0O)I1XCrCJGd0AIfiXS(RoSAyZCgcBno4ufhJIrqkkRHmyAHMiE)agXHujwADT5me2ACWjWKaLvKGUCZ7xv4bSIqoKL8MiHJ)Oo(dyKgYPe0LBE)QcpGveYHSKxAm0ra6paC0Dvwc6zYP6TVHCK70k1Fa5uD3LHu5G0WCi2r8yJYbUpakNgMdi(9MtumcIc1CCKCK2kLhDPsoOOl6fOkhdcmhRZbaz5yIuo3gnPSC4DFdn6pNOvrHC6pNf81VB0LYHEIXjvjbD5M3VQWdyfHCil5H0k1FayK7Yqku5a5xcBleazkwNq1ryzleazfZziS14GtGDQGY66kR0wiaYkI0EnXIuUXw1kBDTTqaKveP9AIfPCdmwsiBfhRC5MdoHPNyCsX6uDTTqaKvmNHWwJdoXMevtfvuxxPTqaKvmNHWwJLYnSeYY2bYESYLBo4eMEIXjfRt112cbqwXCgcBno4eBOakurfjOl38(vfEaRiKdzjpsZJvuaVShbDJWr0YKGUCZ7xv4bSIqoKL8metdbIBe8nM7bCaslJcvhHf9eeaqWqbztqxU59Rk8awrihYsEOlv6LW(JvsxoLGUCZ7xv4bSIqoKL8rlaCJGnOZbrLGMGEMCoVUVHg9RsqxU59Rk8awrq6Ddil)bVbHWSlMESjsy0IUryZbqquDewrXiiffbP3nGLqJ(RRnNHWwJdobMeOmbD5M3VQWdyfbP3nGhYsEaXlm47JBe8YEeSnruDewrXiiffbP3nGLqJ(pwP5me2ACWj2ovTOSUM39n0O)IIG07gWcKyw)vGX6SurDT5me2ACWjWoaLjOl38(vfEaRii9Ub8qwYhD7oGrIHar1ryX7(gA0Frrq6DdybsmR)k2Kq26AZziS14GtGjHSjOl38(vfEaRii9Ub8qwYhrqfbbXFaO6iS4DFdn6VOii9UbSajM1FfBsiBDT5me2ACWjWoHYe0ZKJCtr5GIG89PCKSHq6TCCKCeii9UbmhxLZ3woXsrnN9d5aSJZzHuomUs5pGCwlNlTklNt5CEIoQ5SFih09lxTC4R0CONGaaMdA3e9phzlOmhfX7pOsqxU59Rk8awrq6Dd4HSKFH89jS1qi9gQocROyeKIIG07gWsOr)h5IEHzz354IoBSoDKEccayXCgcBnMzzhBSKTGYe0LBE)QcpGveKE3aEil5VoartHrXXbam0BjOl38(vfEaRii9Ub8qwYJ4qk62DavhHfV7BOr)ffbP3nGfiXS(RytczRRnNHWwJdob2jztqxU59Rk8awrq6Dd4HSKFFoPm4EX89Er1ryX7(gA0Frrq6DdybsmR)k2Kq26AZziS14GtGjHSjOl38(vfEaRii9Ub8qwYhTaWnc2Gohevc6YnVFvHhWkcsVBapKL8whZfXncoqRjIQJWsoGVqFJUurSVbS1He0LBE)QcpGveKE3aEil5JUDhWnc2ejm9edquDewrXiiffbP3nGLqJ(pwjV7BOr)ffbP3nGfiXS(RytczRR5DFdn6VOii9UbSajM1FfysurDT5me2ACWjWoHYe0LBE)QcpGveKE3aEil5Jve2nIb1FziwRse89jfgUSxdX8gUxuDewbkkgbPax2RHyEd3loqrXiiLqJ(RRJIrqkkcsVBalqIz9xXw1uxBodHTghCcmjqzc6YnVFvHhWkcsVBapKL8OB4nao5pgsQ(3NtO6iSIIrqkkcsVBalHg9FSsE33qJ(lkcsVBalqIz9xX2juwxZ7(gA0Frrq6DdybsmR)kWKOI6AZziS14GtGjHSjOl38(vfEaRii9Ub8qwYZ7NtVbxJcyK7YqO6iSIIrqkkcsVBalHg9FSsE33qJ(lkcsVBalqIz9xvxZ7(gA0FH3pNEdUgfWi3LHkCXfcGuSKOIJYj0wH3pNEdUgfWi3LHWrXWVajM1F1Xk5DFdn6VaDL)aWQ4hdIZbPajM1F1rE33qJ(liUYu4gbJedbwGeZ6VQU2CgcBno4eyvBfjOl38(vfEaRii9Ub8qwYRii9UbmbD5M3VQWdyfbP3nGhYsEtKWXFuh)bmsd5eQocROyeKIIG07gWsOr)jOl38(vfEaRii9Ub8qwYlng6ia9hao6UkdvhHvumcsrrq6Ddyj0O)e0ZKt1BFd5i3PvQ)aYP6UldPYbPH5qSJ4XgLdCFauonmhq87nNOyeefQ54i5iTvkp6sLCqrx0lqvogeyowNdaYYXePCUnAsz5W7(gA0ForRIc50Fol4RF3OlLd9eJtQsc6YnVFvHhWkcsVBapKL8qAL6pamYDzifQCG8lHTfcGmfRtO6iSIIrqkkcsVBalHg9FSsBHaiRyodHTghCcStfuwxxzL2cbqwrK2RjwKYn2QwzRRTfcGSIiTxtSiLBGXsczR4yLl3CWjm9eJtkwNQRTfcGSI5me2ACWj2KOAQOI66kTfcGSI5me2ASuUHLqw2oq2JvUCZbNW0tmoPyDQU2wiaYkMZqyRXbNydfqHkQOIe0LBE)QcpGveKE3aEil5rAESIc4L9iOBeoIwguDewrXiiffbP3nGLqJ(tqxU59Rk8awrq6Dd4HSKNHyAiqCJGVXCpGdqAzuO6iSIIrqkkcsVBalHg9FKEccaiyOGSjOl38(vfEaRii9Ub8qwYdDPsVe2FSs6YjuDewrXiiffbP3nGLqJ(tqxU59Rk8awrq6Dd4HSKpAbGBeSbDoikuDewrXiiffbP3nGLqJ(tqtqptoNVqVHUbmh0I(LYrrq6DdyoUkNyPjOl38(vffbP3nGSqCLPWncgjgcevhHvumcsrrq6DdybsmR)kWovxVCZbNW0tmoPy7uc6YnVFvrrq6Dd4HSKxj1)3FayoCFcdIZbbvhHfVzIASYGoi0XkxU5Gty6jgNuSjrD9YnhCctpX4KITthLdV7BOr)fOR8hawf)yqCoiLyPvKGUCZ7xvueKE3aEil5HUYFayv8JbX5GGkhi)syBHaitX6eQoclEZe1yLbDqOe0ZKJKIUkh0(9MdFvwovxxD5SFih)nccJLA5yIuoCX9F6MJJKJjs5W()8Kl54QCG0gaMZ(HCundzI(dihrhGibZP)CmrkhPqVHUbmNRRSCQuUlCwRihxLZc(63n6sLe0LBE)QIIG07gWdzjpIRmfUrWiXqGO6VrqySud7iSaWdfiXS(RyjBc6YnVFvrrq6Dd4HSKhXvgUrWMiHrl6gHnhabrLdKFjSTqaKPyDcvhHfx0b7Ge0LBE)QIIG07gWdzjpKaNGkclUqguDewCrVWSS7CCrNTthPNGaawmNHWwJzw2b2Pe0ZKJCtr5uvFwrnh3YbTFV50)fyorqAbjhMvzeeyoosovVULZ51mrDoUkhzy)PK5y7LEJcjOl38(vffbP3nGhYs(O7YbPJnmioheu5a5xcBleazkwNq1ryXBMOgRmOdcvxlhBV0Bfr3W8MjQl0VrxkKGUCZ7xvueKE3aEil5vs9)9haMd3NWG4CqsqtqxU59RkkJfArhE9haoaxa9JLg)CXe0LBE)QIYoKL8iUYu4gbJedbIQJWY2l9wrrq6DdyH(n6sH6AE33qJ(lwhZfXncoqRjwGeZ6VIn2xDn4l03Olve7BaBDib9m5i3uuoYDHZAo9NJTqaKPYbTBIDSLZ5ZcbjNgjhtKY58G7t5eOOyeeuZXrYrARuE0LqnN9d54i5izlxYXv5SwoxAvwosKJI49hu5SOxGjOl38(vfLDil5HUYFayv8JbX5GGkhi)syBHaitX6eQoclE33qJ(lwhZfXncoqRjwGeZ6VInjQRbFH(gDPIyFdyRdjOl38(vfLDil5HXkr)bGrXBGWO9pGQJWkkgbPaJvI(daJI3aHr7FOeA0)XLBo4eMEIXjfBNsqxU59Rkk7qwYdjWjOIWIlKbvhHfx0lml7ohx0z7uc6YnVFvrzhYsEexz4gbBIegTOBe2Caeevoq(LW2cbqMI1juDewCrhSdsqxU59Rkk7qwYtpbb4SN)aW01zNdr1ryXfDWyDWr6jiaGGHsztqptoYnfLZ5vvoosoa74CwiLdtdPCmX9Zr2CoprpNf9cmheyZKdZYUC2pKJ4coLZPCONyaIAonmNfs5W0qkhtC)CoLZ5j65SOxG5GaBMCyw2LGUCZ7xvu2HSKNl64OyOYq1ryXf9cZYUZXfD2K94YnhCctpX4KI1P6AUOxyw2DoUOZ2Pe0ZKJCtr5i55Boosoa74CwiLdkKtdZHPHuoCrpNf9cmheyZKdZYUC2pKJKTCjN9d5iu9uD5SqkNO2eZ5BlNyPjOl38(vfLDil5nhabXs3ldQCG8lHTfcGmfRtO6iS4ntuJvg0bHoYf9cZYUZXfD2o4OCcTvSoMlIBeCGwtSajM1F1XOyeKIYAidMwOjI3pGrCivcn6pbD5M3VQOSdzjpx0XOxWPe0LBE)QIYoKL8kP()(daZH7tyqCoiO6iS4ntuJvg0bHogfJGuc7ZjCJG5Iok2lqA5wc6zYrUPOCQQpR54i5e1MyovxxD5SFih5UWznNfs58TLd)2kc1CAyoYDHZAoUkh(Tvuo7hYP66QlhxLZ3wo8BROC2pKdWoohXfCkhMgs5yI7NJe5WfDuZPH5uDD1LJRYHFBfLJCx4SMJRY5Blh(Tvuo7hYbyhNJ4coLdtdPCmX9Z5GC4IoQ50WCa2X5iUGt5W0qkhtC)CqzoCrh1CAyoosoa74CaqwoBosHnpbD5M3VQOSdzjF0D5G0XggeNdcQCG8lHTfcGmfRtO6iS4ntuJvg0bHowzL8UVHg9xSoMlIBeCGwtSajM1FfBsuxd(c9n6sfX(gWwhQ4yL8UVHg9xGUYFayv8JbX5GuGeZ6VInjoY7(gA0FbXvMc3iyKyiWcKyw)vSjrDnV7BOr)fOR8hawf)yqCoifiXS(Ra7GJ8UVHg9xqCLPWncgjgcSajM1FfBhCKl6SjrDnV7BOr)fOR8hawf)yqCoifiXS(Ry7GJ8UVHg9xqCLPWncgjgcSajM1FfyhCKl6SHc11CrNnuwrDDumcsjQbblf28sS0ksqxU59Rkk7qwYBoacILUxgu5a5xcBleazkwNq1ryXBMOgRmOdcDKl6fMLDNJl6SDkb9m5i3uuovNWznN9d54VrqySulh3YrzW1biA5SOxGjOl38(vfLDil5rUa9hawrqP0ByqCoiO6VrqySuJ1Pe0ZKJCtr5uvFwZXrYP66QlhxLd)2kkN9d5aSJZrCbNYrIC4IEo7hYbyhdZ5Uklha3oAV5GEv5i55lQ50WCCKCa2X5SqkNnQJTCSoh(knh6jiaG5SFihYnrcMdWogMZDvwoa4HCqVQCK88nNgMJJKdWooNfs5CjLkhtC)CKihUONZIEbMdcSzYHVsL6pGe0LBE)QIYoKL8r3LdshByqCoiOYbYVe2wiaYuSoHQJWQsE33qJ(liUYu4gbJedbwGeZ6VcSdoYfDwsuxtpbbaSyodHTgZSSdStvCSsPqcCmaEOCQyoacILUxM6AUOxyw2DoUOdMevOnTP1a]] )

end