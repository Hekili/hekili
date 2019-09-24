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
    
    spec:RegisterPack( "Windwalker", 20190925, [[dWu2gbqiQk1JOQKnjf(KuQOgfjvNIKYRijMfOQBHeAxQYVavggsWXivTmKINjfzAuv01OQW2Ksv9nPuLgNuQ05KIQ1rsImpKk3JQSpKOdkffTqKQEijjmrPOaDrssuBukk1hLIcQrkfL0jLIsSsQQEPuQIMPuua3ukkKDcs(PuuqgQuuOwQuQWtLQPcsDvPur(QuQc7f4VOmyOoSKftfpwLjRQUmXMjLplIrtLonLvtsQEnOmBrDBsSBf)gYWbXXjjLLJ45OA6cxxK2osPVlLmEPuopsA9KK08jv2Vsd0dGg0)viaOOHc6BofAon(8PVD9PEF6dqpOcraDi1bRseqFkfb0BpS53QYWecOdPOMr1hanOZrPKtaD3iGWvLGdUelCtDEhsboUPKMRWqZrkTaoUPCWb6oPwoAwgGdO)Rqaqrdf03Ck0CA85tF76tk4ZMaDoe5aqrt73Cq31(FzaoG(x4hO7Rf3EyZVvLHjKf3mcnWw)(AXUraHRkbhCjw4M68oKcCCtjnxHHMJuAbCCt5GB97Rf3fiHO4iKftJpGFX0qb9nF9V(91IvfU1KiCvP1VVwmfxC7quq0klUdrkYIBwR5V4EqmyYIp08ddn8fRUBn)S8xSd1fx)pAu7T(91IP4IBhIcIwzXn7E75IjYHuuK5xHHMfREllNxSJCifzX1IHqen1ERFFTykUyvHBnjYIJIKibZ0wCGw8r9YclksIe8363xlMIlUDikiALflJqsOU4RGS4ZvoylwdrwCZ24bFXiTf3StjuxS6CtzXFtttiYCYIn(IhjjBjMtwGFXoPXIHKlQl(BAAcrMtwSXxm3sgtZUAc1ERFFTykU4M5)l)f3oXLf3SeIcFXQheBGjbh(flX9u7b6zJhCa0GEG(aObqPhanOlt5KLpGEq)iwieRaDr1sniqK)7OEzuqqJDmNCXJf3yXrrsK4fMIWce7BYIPCXnFXnw8Hq5pQ18oQxgfe0yhZjx84reLYg(IPZBX0a61fgAa9aLEUmKg7lv4ccau0aGg0LPCYYhqpOFeleIvGUVxSOAPgeiY)DuVmkiOXoMtU4XIBSyr1sniqK)7tmhNSnjmBGbb9xCJfhMIWce7BYIPCXnFXnwS6loksIeVWuewGyqUG1efwmLElwFtuyX60T4Oijs8ctrybIb5cwtuyX0T42DXQb61fgAa9aLEUmKg7lv4ccaunbGg0LPCYYhqpOFeleIvGUVxSOAPgeiY)DuVmkiOXoMtU4XIBSyFVyr1sniqK)7tmhNSnjmBGbb9xCJfhMIWce7BYIPCXnh0Rlm0a6bk9Czin2xQWfeGa0lKaGgaLEa0GUmLtw(a6b9JyHqSc0vFXrLLjETCns2Me2NujOHbjDo3NmLtw(lUXIpek)rTMxlxJKTjH9jvcAyqsNZ9reLYg(IPBX(yXQT4gl(qO8h1AEAgp4mKgtlLq9reLYg(IPCXnb61fgAaDIXTjHXthgm7Gb6h1llSOijsWbqPheaOObanOxxyOb0B5AKSnjSpPsqdds6CUGUmLtw(a6bbaQMaqd6Yuoz5dOh0pIfcXkq33lgcrOLLC)N(xyjcHbPYklUXIpxBX05Ty9lUXILrijuxmDl2hua0Rlm0a6YiKetvTjHjzRnJacau(eanOxxyOb01mEWzinMwkHkOlt5KLpGEqaGYhaObDzkNS8b0d6hXcHyfO7KQP9iPCxBsyQE9fwlB(VpQ1a61fgAaDsk31MeMQxFH1YMpiaq1(aObDzkNS8b0d6hXcHyfOFifheJhedMS4glw9fR(IvFXNRTykxCtlwNUfFiu(JAnpnJhCgsJPLsO(iIszdFXuU42FXQT4glw9fFU2IP0BX(yX60T4dHYFuR5Pz8GZqAmTuc1hrukB4lMYftZIvBXQTyD6wSmcjH6lmfHfiMs12IPZBXnTy1a96cdnGohInJnjSJuJWGzhmqaGQ9cGg0LPCYYhqpOFeleIvG(5ApLQTftXfFU2IP0BX0a61fgAaDIqRq4cZTikGaav7cGg0LPCYYhqpOFeleIvG(5AlMoVf3eOxxyOb0pxJ5Ks4biaq1Ca0GUmLtw(a6b9JyHqSc0px7PuTTykU4Z1wmLElUjqVUWqdORz8GH0yHRWA5AHWclriGaaLEkaGg0LPCYYhqpOFeleIvG(5ApLQTftXfFU2IP0BX0S4glw9f77fhvwM45Ab7qkoONmLtw(lwNUf77fFifheZHifSfRgOxxyOb0dlrimivwb0pQxwyrrsKGdGspiaqPxpaAqxMYjlFa9G(rSqiwb6(EXhsXbXCisbd0Rlm0a6NRXAv0kGaaLEAaqd6Yuoz5dOh0pIfcXkq)qkoigpigmzXnwS6l2jvt75GGXGqq3lfYI1PBXQV4OYYepxlyhsXb9KPCYYFXnwmeIqll5(p9VWsecdsLvwCJfFU2IPBX(CXQTy1a96cdnGUtUoyO0GbZoyG(r9YclksIeCau6bbia97dGgaLEa0GEDHHgq3gArWewBPYa6Yuoz5dOheaOObanOxxyOb0t5cZcrHd6Yuoz5dOheaOAcanOlt5KLpGEqFkfb0PTiw5KfMnHmClOYsSKIwuoyi(z5Cf2KWisDbIa61fgAaDAlIvozHztid3cQSelPOfLdgIFwoxHnjmIuxGiGaaLpbqd61fgAaDNmc9zAPeQGUmLtw(a6bbakFaGg0Rlm0a6ocHley2Ka6Yuoz5dOheaOAFa0GUmLtw(a6b9JyHqSc0px7PuTTykU4Z1wmLElw)IBSyzesc1xykclqmLQTftP3IPWZhGEDHHgqVixnclqeImbiaq1Ebqd61fgAa9SL4gCMQN(tuKjaDzkNS8b0dcauTlaAqVUWqdORzeXjJqFqxMYjlFa9GaavZbqd61fgAa9AoHhKkZUkNbDzkNS8b0dcau6PaaAqxMYjlFa9GEDHHgq)QCMvxyOHLnEa6zJhSPueqpqFqaGsVEa0GUmLtw(a6b9JyHqSc0pek)rTMhpqefMuKWLvZNPze5DUfjr4l2BX0SyD6wS6l(qO8h1AEAgp4mKgtlLq9reLYg(IPZBXnFXnw85AlMsVf30IBS4dHYFuR51Y1izBsyFsLGggK05CFerPSHVy68wSEFU4gl(qO8h1AEbk9Czin2xQW9reLYg(IP0BXnNclwTfRt3IdtrybI9nzX05Ty9(yX60T4pkEbk9Czin2xQW9reLYgoOxxyOb05bIOWKIeUSA(mnJiGaaLEAaqd6Yuoz5dOh0pIfcXkq)JI3HMtMGuH8zA5sryoPK5reLYg(IPZBX0a61fgAa9dnNmbPc5Z0YLIacau6BcanOxxyOb0DYi0NH0yHRWKruOc6Yuoz5dOheaO07ta0GEDHHgqpCfw64GsNptdrob0LPCYYhqpiaqP3haOb96cdnGoKuIPr1MeMtU4bOlt5KLpGEqaGsF7dGg0Rlm0a6AOlLlFwPQcXcH5iLcOlt5KLpGEqaGsF7fanOlt5KLpGEqFkfb0HGoysWnvv(SdPajnQWqd7l0ANa61fgAaDiOdMeCtvLp7qkqsJkm0W(cT2jG(rSqiwb6Fu8cu65YqASVuH7JikLnCqaGsF7cGg0LPCYYhqpOpLIa6f3L2AeoJuQkIWoePYGEDHHgqV4U0wJWzKsvre2Hivg0pIfcXkqx9fR(Ifvl1Gar(VJ6Lrbbn2XCYfpwCJfFiu(JAnVJ6Lrbbn2XCYfpEerPSHVyk9wmnuyXQTyD6wSVxSOAPgeiY)DuVmkiOXoMtU4XIvBXnwS6l(loPAApsPQic7qKkZ(ItQM27JAnlwNUfR(I99Ifvl1Gar(VpXCCY2KWSbge0FX60T4Oijs8ctrybIb5cwtuyX0T42DXQT4gl2jvt7XderHjfjCz18zAgrEerPSHVykxS(MwSoDlomfHfi23Kft3IPr)IvdeaO03Ca0GUmLtw(a6b9JyHqSc0pek)rTMhX42KW4PddMDWEerPSHVy68wmnlwNUfhMIWce7BYIPZBX6Pb0Rlm0a6CHiJfubbakAOaaAqxMYjlFa9G(rSqiwb6YiKeQlMUf7tkS4gl2jvt7XderHjfjCz18zAgrEPqa96cdnGUIOGiuzinwo9Sp7tKsHdcau0OhanOxxyOb0jgeizHzdJdPob0LPCYYhqpiaqrdnaObDzkNS8b0d6hXcHyfOR(Ifvl1Gar(VJ6Lrbbn2XCYfpwCJfFiu(JAnVJ6Lrbbn2XCYfpEerPSHVy68wmnuyXQTyD6wSVxSOAPgeiY)DuVmkiOXoMtU4bOxxyOb0t5cZcrHdcqa6qiYHuCQaanak9aOb96cdnGoeuyOb0LPCYYhqpiaqrdaAqxMYjlFa9G(rSqiwb6QVyFV4OYYepUqKXcQpzkNS8xSoDl23loQSmXtZ4bdPXcxH1Y1cHfwIqEYuoz5Vy1a96cdnG(5AmNucpabaQMaqd61fgAa9Z1yTkAfqxMYjlFa9GaeGoHdllCoaAau6bqd61fgAa9wUgjBtc7tQe0WGKoNlOlt5KLpGEqaGIga0GEDHHgqxZ4bNH0yAPeQGUmLtw(a6bbaQMaqd6Yuoz5dOh0pIfcXkq3jvt7XderHjfjCz18zAgrEPqwSoDl(qO8h1AETCns2Me2NujOHbjDo3hrukB4lMUf7tqVUWqdOtmUnjmE6WGzhmq)OEzHffjrcoak9GaaLpbqd6Yuoz5dOh0pIfcXkq3jvt7rs5U2KWu96lSw28FFuRzXnwCDHrRWKrumHVykxSEqVUWqdOts5U2KWu96lSw28bbakFaGg0LPCYYhqpOFeleIvG(5ApLQTftXfFU2IP0BX0a61fgAaDIqRq4cZTikGaav7dGg0LPCYYhqpOFeleIvG(5AlMoVftdOxxyOb01mEWqASWvyTCTqyHLieqaGQ9cGg0LPCYYhqpOFeleIvG(5AlMoVf30IBSyzesc1ft3I9bfa96cdnGUmcjXuvBsys2AZiGaav7cGg0LPCYYhqpOFeleIvG(HuCqmEqmyYIBSyNunT3VMtyin25AQU9isDbOxxyOb05qSzSjHDKAegm7GbcaunhanOlt5KLpGEq)iwieRa9dP4Gy8GyWKf3yXQV4dHYFuR5Pz8GZqAmTuc1hrukB4lMYf7ZfRt3IpxBXu6TyFUyD6wS6l(CTf7TyAwCJfdHi0YsU)t)lSeHWGuzLfR2Ivd0Rlm0a6o56GHsdgm7Gb6h1llSOijsWbqPheaO0tba0GEDHHgq)CnwRIwb0LPCYYhqpiaqPxpaAqxMYjlFa9G(rSqiwb6NR9uQ2wmfx85AlMsVfRFXnwCDHrRWKrumHVyVfRFX60T4Z1EkvBlMIl(CTftP3IPb0Rlm0a6NRXCsj8aeaO0tdaAq3MqiKuibORh0LPCYYhqpOxxyOb01YuTjHXfcezcgm7Gb6hXcHyfOdHi0YsU)t)ZjxhmuAWGzhSf3yXNRTykxCtGaaL(Maqd6Yuoz5dOh0pIfcXkq)CTNs12IP4IpxBX0TyAa96cdnGoX42KW4PddMDWa9J6LfwuKej4aO0dcau69jaAqxMYjlFa9G(rSqiwb6hsXbX4bXGjlUXIpx7PuTTykU4Z1wmLElMgqVUWqdOhwIqyqQScOFuVSWIIKibhaLEqaGsVpaqd6Yuoz5dOh0Rlm0a6eJBtcJNomy2bd0pQxwyrrsKGdGspiabOZfImwqfanak9aObDzkNS8b0d6hXcHyfOxxy0kmzeft4lMUf30I1PBXqicTSK7)0)4qSzSjHDKAegm7Gb61fgAaDIXTjHXthgm7Gb6h1llSOijsWbqPheaOObanOlt5KLpGEq)iwieRaD1xStQM2ZjJq)CkpEPqwCJfdHi0YsU)t)JyCBsy80HbZoylwTfRt3IDs10ECHiJfuFerPSHVy6wS(fRt3IvFX1fgTctgrXe(IPCX6xCJfxxy0kmzeft4lMUf7JfRgOxxyOb01mEWzinMwkHkiaq1eaAqxMYjlFa9G(rSqiwb6hsXbX4bXGjlUXIvFX1fgTctgrXe(IP0BXnTyD6wS6lUUWOvyYikMWxS3IPzXnwmeIqll5(p9pNCDWqPbdMDWwSAlwnqVUWqdOZHyZytc7i1imy2bdeaO8jaAqxMYjlFa9GEDHHgq3jxhmuAWGzhmq)OEzHffjrcoak9GaeGopaqdGspaAqVUWqdO3Y1izBsyFsLGggK05CbDzkNS8b0dcau0aGg0LPCYYhqpOFeleIvG(5AlMsVf7dqVUWqdOtmUnjmE6WGzhmq)OEzHffjrcoak9GaavtaOb96cdnGUMXdodPX0sjubDzkNS8b0dcau(eanOlt5KLpGEqVUWqdOtmUnjmE6WGzhmq)OEzHffjrcoak9GaaLpaqd6Yuoz5dOh0pIfcXkq3jvt7rs5U2KWu96lSw28FFuRzXnwCDHrRWKrumHVykxSEqVUWqdOts5U2KWu96lSw28bbaQ2hanOlt5KLpGEq)iwieRa9Z1EkvBlMIl(CTftP3IPb0Rlm0a6eHwHWfMBruabaQ2laAqxMYjlFa9G(rSqiwb6NRTy68wmnGEDHHgqxZ4bdPXcxH1Y1cHfwIqabaQ2fanOlt5KLpGEq)iwieRa9Z1wmDElUPf3yXYiKeQlMUf7dka61fgAaDzesIPQ2KWKS1MrabaQMdGg0LPCYYhqpOFeleIvG(HuCqmEqmyYIBSyNunT3VMtyin25AQU9isDbOxxyOb05qSzSjHDKAegm7Gbcau6PaaAqxMYjlFa9G(rSqiwb6hsXbX4bXGjlUXIvFXhcL)OwZJyCBsy80HbZoypIOu2WxmLlUPfRt3IpxBXu6T4MwSAlUXIvFXhcL)OwZtZ4bNH0yAPeQpIOu2WxmLl2NlwNUfFU2IP0BX(CX60Ty1x85Al2BX0S4glgcrOLLC)N(xyjcHbPYklwTfRgOxxyOb0DY1bdLgmy2bd0pQxwyrrsKGdGspiaqPxpaAqVUWqdOFUgRvrRa6Yuoz5dOheaO0tdaAqxMYjlFa9G(rSqiwb6NR9uQ2wmfx85AlMsVfRFXnwCDHrRWKrumHVyVfRFX60T4Z1EkvBlMIl(CTftP3IPb0Rlm0a6NRXCsj8aeaO03eaAqxMYjlFa9G(rSqiwb6hsXbX4bXGjlUXIpx7PuTTykU4Z1wmLElMgqVUWqdOhwIqyqQScOFuVSWIIKibhaLEqaGsVpbqd62ecHKcjaD9GUmLtw(a6b96cdnGUwMQnjmUqGitWGzhmq)iwieRaDieHwwY9F6Fo56GHsdgm7GT4gl(CTft5IBceGa0)IwLMda0aO0dGg0Rlm0a6CisryU18z8GyWeqxMYjlFa9GaafnaObDBcHqBLb9MtbqhYfmxPYHlOtHNpa96cdnGEGspxgsJbRikfOlt5KLpGEqaGQja0GUmLtw(a6b9JyHqSc0Ds10ECHiJfuFPqwSoDl2jvt7XderHjfjCz18zAgrEPqwSoDlw9f77fhvwM4XfImwq9jt5KL)IBS4GydmjEqiO7vjw2cQpIuxSy1wSoDl2jvt75KrOFoLhpIuxSyD6wCuKejEHPiSaX(MSy68wC7tbqVUWqdOdbfgAabakFcGg0LPCYYhqpOxxyOb0VkNz1fgAyzJhG(rSqiwb6oPAApUqKXcQVuiGE24bBkfb05crglOccau(aanOlt5KLpGEq)iwieRaD1xSmcjH6lmfHfiMs12IPBX6xSoDlw9fhvwM4XfImwq9jt5KL)IBS4dHYFuR5XfImwq9reLYg(IPBX0Sy1wSAlUXIpx7PuTTykU4Z1wmLElMgqVUWqdOteAfcxyUfrbeaOAFa0GUmLtw(a6b9JyHqSc0vFXYiKeQVWuewGykvBlMUfRFX60Ty1xCuzzIhxiYyb1NmLtw(lUXIpek)rTMhxiYyb1hrukB4lMUftZIvBX60Ty1xSmcjH6lmfHfiMs12IPBX(CXnw8Hq5pQ180mEWzinMwkH6JikLn8ft3I1)8XIvBXQT4gl(CTNs12IP4IpxBXu6T4Ma96cdnGUMXdgsJfUcRLRfclSeHacauTxa0GUmLtw(a6b9JyHqSc099IpKIdI5qKc2IBSy1xSmcjH6lmfHfiMs12IPBX6xSoDlw9fhvwM4XfImwq9jt5KL)IBS4dHYFuR5XfImwq9reLYg(IPBX0Sy1wSoDlw9flJqsO(ctrybIPuTTy6wSpxCJfFiu(JAnpnJhCgsJPLsO(iIszdFX0Ty9pFSy1wSAlUXIpx7PuTTykU4Z1wmLElMMf3yX(EXFu8cu65YqASVuH7JikLnCqVUWqdOhwIqyqQScOFuVSWIIKibhaLEqaGQDbqd6Yuoz5dOh0Rlm0a6xLZS6cdnSSXdqpB8GnLIa63heaOAoaAqxMYjlFa9GEDHHgq)QCMvxyOHLnEa6hXcHyfOxxy0kmzeft4lMUf30IBS4svfIfYdbrggKkRW4bXGj8NmLtw(lUXI99IlvviwiVKmIqLH0yHRW(vR5jt5KLpONnEWMsraDchww4CqaGspfaqd6Yuoz5dOh0Rlm0a6xLZS6cdnSSXdq)iwieRa96cJwHjJOycFX0T4Ma9SXd2ukcOZdqaGsVEa0GUmLtw(a6b96cdnG(v5mRUWqdlB8a0pIfcXkqVUWOvyYikMWxmLElUjqpB8GnLIa6fsabiabOtRq4gAaqrdf03Ck0CAOWtpfOXhGERIm2KWb9Mffiisi)f3UlUUWqZIZgp4V1pOxPHlIa6Dtrva6qiinllGUVwC7Hn)wvgMqwCZi0aB97Rf7gbeUQeCWLyHBQZ7qkWXnL0CfgAosPfWXnLdU1VVwCxGeIIJqwmn(a(ftdf0381)63xlwv4wtIWvLw)(AXuCXTdrbrRS4oePilUzTM)I7bXGjl(qZpm0WxS6U18ZYFXouxC9)OrT363xlMIlUDikiALf3S7TNlMihsrrMFfgAwS6TSCEXoYHuKfxlgcr0u7T(91IP4IvfU1KiloksIemtBXbAXh1llSOijsWFRFFTykU42HOGOvwSmcjH6IVcYIpx5GTynezXnBJh8fJ0wCZoLqDXQZnLf)nnnHiZjl24lEKKSLyozb(f7KglgsUOU4VPPjezozXgFXClzmn7Qju7T(91IP4IBM)V8xC7exwCZsik8fREqSbMeC4xSe3tT36F97RfRk3MCPH8xSJOHiYIpKItfl2rsSH)wCZ8obsWx8Ggk6wefT08IRlm0WxmAYuFRFFT46cdn8heICifNk80Yfh263xlUUWqd)bHihsXPcv8GtdH(RFFT46cdn8heICifNkuXdUknrrMOcdnRFFT4(uq4UOyXKY(l2jvtt(lMhvWxSJOHiYIpKItfl2rsSHV4A(lgcrOieue2KSyJV4pAK363xlUUWqd)bHihsXPcv8GJpfeUlky8Oc(6VUWqd)bHihsXPcv8Gdckm0S(Rlm0WFqiYHuCQqfp4oxJ5Ks4b8MMN6(oQSmXJlezSG6tMYjlFD68DuzzINMXdgsJfUcRLRfclSeH8KPCYYxT1FDHHg(dcroKItfQ4b35ASwfTY6F97RfRk3MCPH8xSqRqOU4WuKfhUYIRlqKfB8fx0wwUCYYB97RfxxyOH7vPbIvruhS1FDHHgUkEWXHifH5wZNXdIbtw)1fgA4Q4bxGspxgsJbRikf82ecH2k71CkapKlyUsLdxpk88X63xlUzmkm0SytBXDHiJfuxmIS4EGikWVyv5IeUWV4A(lUzBezXfrwCkKfJilMkkDXfrwmjDgBswmxiYyb1fxZFX1IvkBwmpQyXbXgysSyie0XHFXiYIPIsxCrKfNoFHS4WvwSOPjxSyK2IDYi0pNYd4xmIS4OijsS4WuKfhOf)nzXgFXjePcHSyezXIQLw5fhOf3(uy9xxyOHRIhCqqHHg4nnpNunThxiYyb1xkeD6Cs10E8aruysrcxwnFMMrKxkeD6u33rLLjECHiJfuFYuoz53ii2atIhec6EvILTG6Ji1fQPtNtQM2ZjJq)CkpEePUqNUOijs8ctrybI9nHoV2NcR)6cdnCv8G7QCMvxyOHLnEa)ukIhxiYybv4nnpNunThxiYyb1xkK1FDHHgUkEWreAfcxyUfrbEtZtDzesc1xykclqmLQn60RtN6rLLjECHiJfuFYuoz534qO8h1AECHiJfuFerPSHthnQPwJZ1EkvBu8Cnk9Oz9xxyOHRIhCAgpyinw4kSwUwiSWsec8MMN6YiKeQVWuewGykvB0PxNo1Jklt84crglO(KPCYYVXHq5pQ184crglO(iIszdNoAutNo1LrijuFHPiSaXuQ2OZNnoek)rTMNMXdodPX0sjuFerPSHtN(NputTgNR9uQ2O45Au6106VUWqdxfp4clrimivwb(J6LfwuKej4E6H30889HuCqmhIuWAOUmcjH6lmfHfiMs1gD61Pt9OYYepUqKXcQpzkNS8BCiu(JAnpUqKXcQpIOu2WPJg10PtDzesc1xykclqmLQn68zJdHYFuR5Pz8GZqAmTuc1hrukB40P)5d1uRX5ApLQnkEUgLE00W3Fu8cu65YqASVuH7JikLn81FDHHgUkEWDvoZQlm0WYgpGFkfX7(RFFTyvrLZloCLf3o6TNndiC(IRlm0S4SXJfBAlUziiYS4MXvwzX9GyWeE78In(ILPCYYh(fxZFXndNreQlgPT4WvwCZGvlL2z(Ij1aBXgFXdkwSmLtw(R)6cdnCv8G7QCMvxyOHLnEa)ukIhHdllCo8MMxDHrRWKrumHtxtnkvviwipeezyqQScJhedMWFYuoz53W3LQkelKxsgrOYqASWvy)Q18KPCYYF97RfRkQCEXHRS4o0lUUWqZIZgpwSPT4WviYIlISyAwmIS4SW5lwgrXe(6VUWqdxfp4UkNz1fgAyzJhWpLI4Xd4nnV6cJwHjJOycNUMw)(AXQIkNxC4klUzIuLxCDHHMfNnESytBXHRqKfxezXnTyezXkiISyzeft4R)6cdnCv8G7QCMvxyOHLnEa)ukIxHe4nnV6cJwHjJOycNsVMw)RFFT4M5fgA4VMjsvEXgFX2eY8L)I1qKfNYLf3Yc3f3SkxyhRz()mvrwkALfxZFXxkHitKPU4rKpFXbAXoYIrqctXuv5V(Rlm0WFfs8ig3MegpDyWSdg8h1llSOijsW90dVP5PEuzzIxlxJKTjH9jvcAyqsNZ9jt5KLFJdHYFuR51Y1izBsyFsLGggK05CFerPSHtNpuRXHq5pQ180mEWzinMwkH6JikLnCkBA9xxyOH)kKOIhCTCns2Me2NujOHbjDo31FDHHg(RqIkEWjJqsmv1MeMKT2mc8MMNVHqeAzj3)P)fwIqyqQSsJZ1OZtFdzescv68bfw)1fgA4VcjQ4bNMXdodPX0sjux)1fgA4VcjQ4bhjL7Atct1RVWAzZhEtZZjvt7rs5U2KWu96lSw28FFuRz9xxyOH)kKOIhCCi2m2KWosncdMDWG308oKIdIXdIbtAOU6QFUgLnPt3Hq5pQ180mEWzinMwkH6JikLnCkBF1AO(5Au65dD6oek)rTMNMXdodPX0sjuFerPSHtjnQPMoDYiKeQVWuewGykvB051KAR)6cdn8xHev8GJi0keUWClIc8MM35ApLQnkEUgLE0S(Rlm0WFfsuXdUZ1yoPeEaVP5DUgDEnT(Rlm0WFfsuXdonJhmKglCfwlxlewyjcbEtZ7CTNs1gfpxJsVMw)1fgA4VcjQ4bxyjcHbPYkWFuVSWIIKib3tp8MM35ApLQnkEUgLE00qDFhvwM45Ab7qkoONmLtw(6057dP4GyoePGP26VUWqd)virfp4oxJ1QOvG30889HuCqmhIuWw)(AX1fgA4VcjQ4bNwMQnjmUqGitWGzhm4nnpNunTNdcgdcbDVpQ1aVnHqiPqcp9R)6cdn8xHev8GZjxhmuAWGzhm4pQxwyrrsKG7PhEtZ7qkoigpigmPH6oPAAphemgec6EPq0Pt9OYYepxlyhsXb9KPCYYVbeIqll5(p9VWsecdsLvACUgD(un1w)RFFTyvbcL)OwdF9xxyOH)UVNn0IGjS2sLHfUcRLRfclSeHS(Rlm0WF3xfp4s5cZcrHV(Rlm0WF3xfp4s5cZcrb(PuepAlIvozHztid3cQSelPOfLdgIFwoxHnjmIuxGiR)6cdn839vXdoNmc9zAPeQR)6cdn839vXdohHWfcmBsw)(AXTtCzXntYvJSyOreImXInTftfLU4IilwX4CBswCflolfpwS(fRkCTfxZFXTqt7CS4RGSyzesc1f3YcxBwmfE(yXC5qZNV(Rlm0WF3xfp4kYvJWceHitaVP5DU2tPAJINRrPN(gYiKeQVWuewGykvBu6rHNpw)1fgA4V7RIhCzlXn4mvp9NOitS(Rlm0WF3xfp40mI4KrO)6VUWqd)DFv8GRMt4bPYSRY51FDHHg(7(Q4b3v5mRUWqdlB8a(PueVa9x)1fgA4V7RIhC8aruysrcxwnFMMre4nnVdHYFuR5XderHjfjCz18zAgrENBrseUhn60P(Hq5pQ180mEWzinMwkH6JikLnC68AEJZ1O0RPghcL)OwZRLRrY2KW(KkbnmiPZ5(iIszdNop9(SXHq5pQ18cu65YqASVuH7JikLnCk9AofutNUWuewGyFtOZtVp0P7JIxGspxgsJ9LkCFerPSHV(Rlm0WF3xfp4o0CYeKkKptlxkc8MM3hfVdnNmbPc5Z0YLIWCsjZJikLnC68Oz9xxyOH)UVkEW5KrOpdPXcxHjJOqD9xxyOH)UVkEWfUclDCqPZNPHiNS(Rlm0WF3xfp4GKsmnQ2KWCYfpw)1fgA4V7RIhCAOlLlFwPQcXcH5iLY6VUWqd)DFv8GlLlmlef4Nsr8GGoysWnvv(SdPajnQWqd7l0ANaVP59rXlqPNldPX(sfUpIOu2Wx)1fgA4V7RIhCPCHzHOa)ukIxXDPTgHZiLQIiSdrQm8MMN6QlQwQbbI8Fh1lJccASJ5KlE04qO8h1AEh1lJccASJ5KlE8iIszdNspAOGA605Br1sniqK)7OEzuqqJDmNCXd1AO(xCs10EKsvre2HivM9fNunT3h1A0PtDFlQwQbbI8FFI54KTjHzdmiOVoDrrsK4fMIWcedYfSMOaDTRAnCs10E8aruysrcxwnFMMrKhrukB4uQVjD6ctrybI9nHoA0R26VUWqd)DFv8GJlezSGk8MM3Hq5pQ18ig3MegpDyWSd2JikLnC68OrNUWuewGyFtOZtpnR)6cdn839vXdofrbrOYqASC6zF2NiLchEtZtgHKqLoFsHgoPAApEGikmPiHlRMptZiYlfY6VUWqd)DFv8GJyqGKfMnmoK6K1FDHHg(7(Q4bxkxywikC4nnp1fvl1Gar(VJ6Lrbbn2XCYfpACiu(JAnVJ6Lrbbn2XCYfpEerPSHtNhnuqnD68TOAPgeiY)DuVmkiOXoMtU4X6F9xxyOH)iCyzHZ9A5AKSnjSpPsqdds6CUR)6cdn8hHdllCUkEWPz8GZqAmTuc11FDHHg(JWHLfoxfp4ig3MegpDyWSdg8h1llSOijsW90dVP55KQP94bIOWKIeUSA(mnJiVui60Diu(JAnVwUgjBtc7tQe0WGKoN7JikLnC6856VUWqd)r4WYcNRIhCKuURnjmvV(cRLnF4nnpNunThjL7Atct1RVWAzZ)9rTMg1fgTctgrXeoL6x)1fgA4pchww4Cv8GJi0keUWClIc8MM35ApLQnkEUgLE0S(Rlm0WFeoSSW5Q4bNMXdgsJfUcRLRfclSeHaVP5DUgDE0S(Rlm0WFeoSSW5Q4bNmcjXuvBsys2AZiWBAENRrNxtnKrijuPZhuy9xxyOH)iCyzHZvXdooeBgBsyhPgHbZoyWBAEhsXbX4bXGjnCs10E)AoHH0yNRP62Ji1fR)6cdn8hHdllCUkEW5KRdgknyWSdg8h1llSOijsW90dVP5DifheJhedM0q9dHYFuR5Pz8GZqAmTuc1hrukB4u6tD6oxJspFQtN6NR5rtdieHwwY9F6FHLiegKkROMAR)6cdn8hHdllCUkEWDUgRvrRS(Rlm0WFeoSSW5Q4b35AmNucpG308ox7PuTrXZ1O0tFJ6cJwHjJOyc3tVoDNR9uQ2O45Au6rZ6VUWqd)r4WYcNRIhCAzQ2KW4cbImbdMDWG308GqeAzj3)P)5KRdgknyWSdwJZ1OSj4Tjecjfs4PF9xxyOH)iCyzHZvXdoIXTjHXthgm7Gb)r9YclksIeCp9WBAENR9uQ2O45A0rZ6VUWqd)r4WYcNRIhCHLiegKkRa)r9YclksIeCp9WBAEhsXbX4bXGjnox7PuTrXZ1O0JM1FDHHg(JWHLfoxfp4ig3MegpDyWSdg8h1llSOijsW90V(x)(AXDHiJfuxmeIHiwqD9xxyOH)4crglO6rmUnjmE6WGzhm4pQxwyrrsKG7PhEtZRUWOvyYikMWPRjD6GqeAzj3)P)XHyZytc7i1imy2bB9xxyOH)4crglOQIhCAgp4mKgtlLqfEtZtDNunTNtgH(5uE8sH0acrOLLC)N(hX42KW4PddMDWutNoNunThxiYyb1hrukB40PxNo1RlmAfMmIIjCk13OUWOvyYikMWPZhQT(Rlm0WFCHiJfuvXdooeBgBsyhPgHbZoyWBAEhsXbX4bXGjnuVUWOvyYikMWP0RjD6uVUWOvyYikMW9OPbeIqll5(p9pNCDWqPbdMDWutT1FDHHg(JlezSGQkEW5KRdgknyWSdg8h1llSOijsW90V(x)1fgA4pE41Y1izBsyFsLGggK05Cx)1fgA4pEOIhCeJBtcJNomy2bd(J6LfwuKej4E6H308oxJspFS(Rlm0WF8qfp40mEWzinMwkH66VUWqd)Xdv8GJyCBsy80HbZoyWFuVSWIIKib3t)6VUWqd)Xdv8GJKYDTjHP61xyTS5dVP55KQP9iPCxBsyQE9fwlB(VpQ10OUWOvyYikMWPu)6VUWqd)Xdv8GJi0keUWClIc8MM35ApLQnkEUgLE0S(Rlm0WF8qfp40mEWqASWvyTCTqyHLie4nnVZ1OZJM1FDHHg(JhQ4bNmcjXuvBsys2AZiWBAENRrNxtnKrijuPZhuy9xxyOH)4HkEWXHyZytc7i1imy2bdEtZ7qkoigpigmPHtQM27xZjmKg7Cnv3EePUy9xxyOH)4HkEW5KRdgknyWSdg8h1llSOijsW90dVP5DifheJhedM0q9dHYFuR5rmUnjmE6WGzhShrukB4u2KoDNRrPxtQ1q9dHYFuR5Pz8GZqAmTuc1hrukB4u6tD6oxJspFQtN6NR5rtdieHwwY9F6FHLiegKkROMAR)6cdn8hpuXdUZ1yTkAL1FDHHg(JhQ4b35AmNucpG308ox7PuTrXZ1O0tFJ6cJwHjJOyc3tVoDNR9uQ2O45Au6rZ6VUWqd)Xdv8GlSeHWGuzf4pQxwyrrsKG7PhEtZ7qkoigpigmPX5ApLQnkEUgLE0S(Rlm0WF8qfp40YuTjHXfcezcgm7GbVP5bHi0YsU)t)ZjxhmuAWGzhSgNRrztWBtieskKWt)6F9xxyOH)c03lqPNldPX(sfUWBAEIQLAqGi)3r9YOGGg7yo5IhnIIKiXlmfHfi23ekBEJdHYFuR5DuVmkiOXoMtU4XJikLnC68Oz9xxyOH)c0xfp4cu65YqASVuHl8MMNVfvl1Gar(VJ6Lrbbn2XCYfpAiQwQbbI8FFI54KTjHzdmiOFJWuewGyFtOS5nupksIeVWuewGyqUG1efO0tFtuqNUOijs8ctrybIb5cwtuGU2vT1FDHHg(lqFv8GlqPNldPX(sfUWBAE(wuTudce5)oQxgfe0yhZjx8OHVfvl1Gar(VpXCCY2KWSbge0VrykclqSVju2Cqacaa]] )

end