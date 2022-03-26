-- DeathKnightBlood.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR
local FindUnitDebuffByID = ns.FindUnitDebuffByID


-- Conduits
-- [-] Withering Plague
-- [x] Debilitating Malady

-- [-] Kyrian: Proliferation
-- [x] Venthyr: Impenetrable Gloom
-- [-] Necrolord: Brutal Grasp
-- [-] Night Fae: Withering Ground

-- Endurance
-- [x] hardened_bones
-- [-] insatiable_appetite
-- [x] reinforced_shell

-- Finesse
-- [x] chilled_resilience
-- [x] fleeting_wind
-- [x] spirit_drain
-- [x] unending_grip


if UnitClassBase( "player" ) == "DEATHKNIGHT" then
    local spec = Hekili:NewSpecialization( 250 )

    spec:RegisterResource( Enum.PowerType.Runes, {
        rune_regen = {
            last = function ()
                return state.query_time
            end,

            interval = function( time, val )
                local r = state.runes

                if val == 6 then return -1 end
                return r.expiry[ val + 1 ] - time
            end,

            stop = function( x )
                return x == 6
            end,

            value = 1
        },
    }, setmetatable( {
        expiry = { 0, 0, 0, 0, 0, 0 },
        cooldown = 10,
        regen = 0,
        max = 6,
        forecast = {},
        fcount = 0,
        times = {},
        values = {},
        resource = "runes",

        reset = function()
            local t = state.runes

            for i = 1, 6 do
                local start, duration, ready = GetRuneCooldown( i )

                start = start or 0
                duration = duration or ( 10 * state.haste )

                t.expiry[ i ] = ready and 0 or start + duration
                t.cooldown = duration
            end

            table.sort( t.expiry )

            t.actual = nil
        end,

        gain = function( amount )
            local t = state.runes

            for i = 1, amount do
                t.expiry[ 7 - i ] = 0
            end
            table.sort( t.expiry )

            t.actual = nil
        end,

        spend = function( amount )
            local t = state.runes

            for i = 1, amount do
                t.expiry[ 1 ] = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
                table.sort( t.expiry )
            end

            -- TODO:  Rampant Transference
            state.gain( amount * 10 * ( state.buff.rune_of_hysteria.up and 1.2 or 1 ), "runic_power" )

            if state.talent.rune_strike.enabled then state.gainChargeTime( "rune_strike", amount ) end

            if state.azerite.eternal_rune_weapon.enabled and state.buff.dancing_rune_weapon.up then
                if state.buff.dancing_rune_weapon.expires - state.buff.dancing_rune_weapon.applied < state.buff.dancing_rune_weapon.duration + 5 then
                    state.buff.dancing_rune_weapon.expires = min( state.buff.dancing_rune_weapon.applied + state.buff.dancing_rune_weapon.duration + 5, state.buff.dancing_rune_weapon.expires + ( 0.5 * amount ) )
                    state.buff.eternal_rune_weapon.expires = min( state.buff.dancing_rune_weapon.applied + state.buff.dancing_rune_weapon.duration + 5, state.buff.dancing_rune_weapon.expires + ( 0.5 * amount ) )
                end
            end

            t.actual = nil
        end,

        timeTo = function( x )
            return state:TimeToResource( state.runes, x )
        end,
    }, {
        __index = function( t, k, v )
            if k == "actual" then
                local amount = 0

                for i = 1, 6 do
                    if t.expiry[ i ] <= state.query_time then
                        amount = amount + 1
                    end
                end

                return amount

            elseif k == "current" then
                -- If this is a modeled resource, use our lookup system.
                if t.forecast and t.fcount > 0 then
                    local q = state.query_time
                    local index, slice

                    if t.values[ q ] then return t.values[ q ] end

                    for i = 1, t.fcount do
                        local v = t.forecast[ i ]
                        if v.t <= q then
                            index = i
                            slice = v
                        else
                            break
                        end
                    end

                    -- We have a slice.
                    if index and slice then
                        t.values[ q ] = max( 0, min( t.max, slice.v ) )
                        return t.values[ q ]
                    end
                end

                return t.actual

            elseif k == "deficit" then
                return t.max - t.current

            elseif k == "time_to_next" then
                return t[ "time_to_" .. t.current + 1 ]

            elseif k == "time_to_max" then
                return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

            elseif k == "add" then
                return t.gain

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.RunicPower, {
        swarming_mist = {
            aura = "swarming_mist",

            last = function ()
                local app = state.buff.swarming_mist.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.swarming_mist.tick_time ) * class.auras.swarming_mist.tick_time
            end,

            interval = function () return class.auras.swarming_mist.tick_time end,
            value = function () return min( 15, state.true_active_enemies * 3 ) end,
        },
    } )

    local spendHook = function( amt, resource )
        if amt > 0 and resource == "runic_power" and talent.red_thirst.enabled then
            cooldown.vampiric_blood.expires = max( 0, cooldown.vampiric_blood.expires - amt / 10 )
        elseif resource == "rune" and amt > 0 and active_dot.shackle_the_unworthy > 0 then
            reduceCooldown( "shackle_the_unworthy", 4 * amt )
        end
    end

    spec:RegisterHook( "spend", spendHook )


    -- Talents
    spec:RegisterTalents( {
        heartbreaker = 19165, -- 221536
        blooddrinker = 19166, -- 206931
        tombstone = 23454, -- 219809

        rapid_decomposition = 19218, -- 194662
        hemostasis = 19219, -- 273946
        consumption = 19220, -- 274156

        foul_bulwark = 19221, -- 206974
        relish_in_blood = 22134, -- 317610
        blood_tap = 22135, -- 221699

        will_of_the_necropolis = 22013, -- 206967
        antimagic_barrier = 22014, -- 205727
        mark_of_blood = 22015, -- 206940

        grip_of_the_dead = 19227, -- 273952
        tightening_grasp = 19226, -- 206970
        wraith_walk = 19228, -- 212552

        voracious = 19230, -- 273953
        death_pact = 19231, -- 48743
        bloodworms = 19232, -- 195679

        purgatory = 21207, -- 114556
        red_thirst = 21208, -- 205723
        bonestorm = 21209, -- 194844
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( {
        blood_for_blood = 607, -- 356456
        dark_simulacrum = 3511, -- 77606
        death_chain = 609, -- 203173
        deaths_echo = 5426, -- 356367
        decomposing_aura = 3441, -- 199720
        dome_of_ancient_shadow = 5368, -- 328718
        last_dance = 608, -- 233412
        murderous_intent = 841, -- 207018
        rot_and_wither = 204, -- 202727
        spellwarden = 5425, -- 356332
        strangulate = 206, -- 47476
        walking_dead = 205, -- 202731
    } )


    -- Auras
    spec:RegisterAuras( {
        abomination_limb = {
            id = 315443,
            duration = function () return legendary.abominations_frenzy.enabled and 16 or 12 end,
            max_stack = 1,
        },
        antimagic_shell = {
            id = 48707,
            duration = function () return ( legendary.deaths_embrace.enabled and 2 or 1 ) * ( ( azerite.runic_barrier.enabled and 1 or 0 ) + ( talent.antimagic_barrier.enabled and 7 or 5 ) ) + ( conduit.reinforced_shell.mod * 0.001 ) end,
            max_stack = 1,
        },
        antimagic_zone = {
            id = 145629,
            duration = 8,
            max_stack = 1,
        },
        asphyxiate = {
            id = 221562,
            duration = 5,
            max_stack = 1,
        },
        blood_plague = {
            id = 55078,
            duration = 24,
            type = "Disease",
            max_stack = 1,
        },
        blood_shield = {
            id = 77535,
            duration = 10,
            max_stack = 1,
        },
        blooddrinker = {
            id = 206931,
            duration = 3,
            max_stack = 1,
        },
        bone_shield = {
            id = 195181,
            duration = 30,
            max_stack = 10,
        },
        bonestorm = {
            id = 194844,
            duration = 10,
            max_stack = 1,
        },
        control_undead = {
            id = 111673,
            duration = 300,
            max_stack = 1
        },
        crimson_scourge = {
            id = 81141,
            duration = 15,
            max_stack = 1,
        },
        dark_command = {
            id = 56222,
            duration = 3,
            max_stack = 1,
        },
        dancing_rune_weapon = {
            id = 81256,
            duration = function () return pvptalent.last_dance.enabled and 6 or 8 end,
            max_stack = 1,
        },
        death_and_decay = {
            id = 188290,
            duration = 10,
            max_stack = 1,
        },
        death_grip = {
            id = 51399,
            duration = 3,
        },
        deaths_advance = {
            id = 48265,
            duration = 8,
            max_stack = 1,
        },
        gnaw = {
            id = 91800,
            duration = 1,
            max_stack = 1,
        },
        grip_of_the_dead = {
            id = 273977,
            duration = 3600,
            max_stack = 1,
        },
        --[[ ?? grip_of_the_dead = {
            id = 273984,
            duration = 10,
            max_stack = 10,
        }, ]]
        heart_strike = {
            id = 206930,
            duration = 8,
            max_stack = 1,
        },
        hemostasis = {
            id = 273947,
            duration = 15,
            max_stack = 5,
            copy = "haemostasis"
        },
        icebound_fortitude = {
            id = 48792,
            duration = 8,
            max_stack = 1,
        },
        lichborne = {
            id = 49039,
            duration = 10,
            max_stack = 1,
        },
        mark_of_blood = {
            id = 206940,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        on_a_pale_horse = {
            id = 51986,
        },
        ossuary = {
            id = 219788,
            duration = 3600,
            max_stack = 1,
        },
        path_of_frost = {
            id = 3714,
            duration = 600,
            max_stack = 1,
        },
        perdition = {
            id = 123981,
            duration = 240,
            max_stack = 1,
        },
        rune_of_hysteria = {
            id = 326918,
            duration = 8,
            max_stack = 1,
        },
        rune_tap = {
            id = 194679,
            duration = 4,
            max_stack = 1,
        },
        shackle_the_unworthy = {
            id = 312202,
            duration = 14,
            max_stack = 1,
        },
        shroud_of_purgatory = {
            id = 116888,
            duration = 3,
            max_stack = 1,
        },
        strangulate = {
            id = 47476,
            duration = 5,
            max_stack = 1,
        },
        swarming_mist = { -- Venthyr
            id = 311648,
            duration = 8,
            tick_time = 1,
            max_stack = 1,
        },
        tombstone = {
            id = 219809,
            duration = 8,
            max_stack = 1,
        },
        unholy_strength = {
            id = 53365,
            duration = 15,
            max_stack = 1,
        },
        vampiric_blood = {
            id = 55233,
            duration = function () return ( level > 55 and 12 or 10 ) + ( legendary.vampiric_aura.enabled and 3 or 0 ) end,
            max_stack = 1,
        },
        veteran_of_the_third_war = {
            id = 48263,
        },
        voracious = {
            id = 274009,
            duration = 6,
            max_stack = 1,
        },
        wraith_walk = {
            id = 212552,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers
        bloody_runeblade = {
            id = 289349,
            duration = 5,
            max_stack = 1
        },

        bones_of_the_damned = {
            id = 279503,
            duration = 30,
            max_stack = 1,
        },

        cold_hearted = {
            id = 288426,
            duration = 8,
            max_stack = 1
        },

        deep_cuts = {
            id = 272685,
            duration = 15,
            max_stack = 1,
        },

        eternal_rune_weapon = {
            id = 278543,
            duration = 5,
            max_stack = 1,
        },

        march_of_the_damned = {
            id = 280149,
            duration = 15,
            max_stack = 1,
        },


        -- PvP Talents
        blood_for_blood = {
            id = 233411,
            duration = 12,
            max_stack = 1,
        },

        dark_simulacrum = {
            id = 77606,
            duration = 12,
            max_stack = 1,
        },

        death_chain = {
            id = 203173,
            duration = 10,
            max_stack = 1
        },

        decomposing_aura = {
            id = 228581,
            duration = 3600,
            max_stack = 1,
        },

        focused_assault = {
            id = 206891,
            duration = 6,
            max_stack = 1,
        },

        heartstop_aura = {
            id = 228579,
            duration = 3600,
            max_stack = 1,
        },


        -- Legendaries
        abominations_frenzy = {
            id = 353546,
            duration = 12,
            max_stack = 1,
        },

        -- TODO:  Model +/- rune regen when applied/removed.
        crimson_rune_weapon = {
            id = 334526,
            duration = 10,
            max_stack = 1
        },

        final_sentence = {
            id = 353823,
            duration = 18,
            max_stack = 5,
        },

        grip_of_the_everlasting = {
            id = 334722,
            duration = 3,
            max_stack = 1
        }
    } )

    -- Tier 28
    spec:RegisterGear( "tier28", 188868, 188867, 188866, 188864, 188863 )
    spec:RegisterSetBonuses( "tier28_2pc", 364399, "tier28_4pc", 363590 )
    -- 2-Set - Endless Rune Waltz  Heart Strike increases your Strength by 1% andWhile your Dancing Rune Weapon is active Heart Strike extends the duration of Dancing Rune Weapon by 0.5 seconds and increases your Strength by 1%, persisting for 10 seconds after Dancing Rune Weapon ends.
    -- 4-Set - Endless Rune Waltz - Parrying an attack causes your weaponWhen you take damage, you have a chance equal to 100% of your Parry chance to lash out, Heart Striking your attacker. Dancing Rune Weapon now summons 2 Rune Weapons.

        spec:RegisterAuras( {
            endless_rune_waltz = {
                id = 366008,
                duration = 30,
                max_stack = 1
            }
        } )

    spec:RegisterGear( "tier19", 138355, 138361, 138364, 138349, 138352, 138358 )
    spec:RegisterGear( "tier20", 147124, 147126, 147122, 147121, 147123, 147125 )
        spec:RegisterAura( "gravewarden", {
            id = 242010,
            duration = 10,
            max_stack = 0
        } )

    spec:RegisterGear( "tier21", 152115, 152117, 152113, 152112, 152114, 152116 )

    spec:RegisterGear( "acherus_drapes", 132376 )
    spec:RegisterGear( "cold_heart", 151796 ) -- chilled_heart stacks NYI
    spec:RegisterGear( "consorts_cold_core", 144293 )
    spec:RegisterGear( "death_march", 144280 )
    -- spec:RegisterGear( "death_screamers", 151797 )
    spec:RegisterGear( "draugr_girdle_of_the_everlasting_king", 132441 )
    spec:RegisterGear( "koltiras_newfound_will", 132366 )
    spec:RegisterGear( "lanathels_lament", 133974 )
    spec:RegisterGear( "perseverance_of_the_ebon_martyr", 132459 )
    spec:RegisterGear( "rethus_incessant_courage", 146667 )
    spec:RegisterGear( "seal_of_necrofantasia", 137223 )
    spec:RegisterGear( "service_of_gorefiend", 132367 )
    spec:RegisterGear( "shackles_of_bryndaor", 132365 ) -- NYI (Death Strike heals refund RP...)
    spec:RegisterGear( "skullflowers_haemostasis", 144281 )
        spec:RegisterAura( "haemostasis", {
            id = 235559,
            duration = 3600,
            max_stack = 5
        } )

    spec:RegisterGear( "soul_of_the_deathlord", 151740 )
    spec:RegisterGear( "soulflayers_corruption", 151795 )
    spec:RegisterGear( "the_instructors_fourth_lesson", 132448 )
    spec:RegisterGear( "toravons_whiteout_bindings", 132458 )
    spec:RegisterGear( "uvanimor_the_unbeautiful", 137037 )


    spec:RegisterTotem( "ghoul", 1100170 ) -- Texture ID


    local any_dnd_set = false

    spec:RegisterHook( "reset_precast", function ()
        if UnitExists( "pet" ) then
            for i = 1, 40 do
                local expires, _, _, _, id = select( 6, UnitDebuff( "pet", i ) )

                if not expires then break end

                if id == 111673 then
                    summonPet( "controlled_undead", expires - now )
                    break
                end
            end
        end

        if state:IsKnown( "deaths_due" ) then
            class.abilities.any_dnd = class.abilities.deaths_due
            cooldown.any_dnd = cooldown.deaths_due
            setCooldown( "death_and_decay", cooldown.deaths_due.remains )
        elseif state:IsKnown( "defile" ) then
            class.abilities.any_dnd = class.abilities.defile
            cooldown.any_dnd = cooldown.defile
            setCooldown( "death_and_decay", cooldown.defile.remains )
        else
            class.abilities.any_dnd = class.abilities.death_and_decay
            cooldown.any_dnd = cooldown.death_and_decay
        end

        if not any_dnd_set then
            class.abilityList.any_dnd = "|T136144:0|t |cff00ccff[Any]|r " .. class.abilities.death_and_decay.name
            any_dnd_set = true
        end

        -- Reset CDs on any Rune abilities that do not have an actual cooldown.
        for action in pairs( class.abilityList ) do
            local data = class.abilities[ action ]
            if data.cooldown == 0 and data.spendType == "runes" then
                setCooldown( action, 0 )
            end
        end

        if set_bonus.tier28_2pc > 0 and buff.dancing_rune_weapon.up then
            if buff.endless_rune_waltz.up then buff.endless_rune_waltz.expires = buff.dancing_rune_weapon.expires + 10
            else applyBuff( "endless_rune_waltz", buff.dancing_rune_weapon.remains + 10 ) end
        end
    end )


    spec:RegisterStateExpr( "save_blood_shield", function ()
        return settings.save_blood_shield
    end )


    -- Abilities
    spec:RegisterAbilities( {
        antimagic_shell = {
            id = 48707,
            cast = 0,
            cooldown = function () return talent.antimagic_barrier.enabled and 40 or 60 end,
            gcd = "off",

            toggle = "defensives",

            startsCombat = false,
            texture = 136120,

            handler = function ()
                applyBuff( "antimagic_shell" )
            end,
        },


        antimagic_zone = {
            id = 51052,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 237510,

            handler = function ()
                applyBuff( "antimagic_zone" )
            end,
        },


        asphyxiate = {
            id = 221562,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 538558,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
                applyDebuff( "target", "asphyxiate" )
            end,
        },


        blood_boil = {
            id = 50842,
            cast = 0,
            charges = 2,
            cooldown = 7.5,
            recharge = 7.5,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 237513,

            handler = function ()
                applyDebuff( "target", "blood_plague" )
                active_dot.blood_plague = active_enemies

                if talent.hemostasis.enabled then
                    applyBuff( "hemostasis", 15, min( 5, active_enemies) )
                end

                if legendary.superstrain.enabled then
                    applyDebuff( "target", "frost_fever" )
                    active_dot.frost_fever = active_enemies

                    applyDebuff( "target", "virulent_plague" )
                    active_dot.virulent_plague = active_enemies
                end

                if conduit.debilitating_malady.enabled then
                    addStack( "debilitating_malady", nil, 1 )
                end
            end,

            auras = {
                -- Conduit
                debilitating_malady = {
                    id = 338523,
                    duration = 6,
                    max_stack = 3
                }
            }
        },


        blood_tap = {
            id = 221699,
            cast = 0,
            charges = 2,
            cooldown = 60,
            recharge = 60,
            gcd = "off",

            spend = -1,
            spendType = "runes",

            startsCombat = false,

            talent = "blood_tap",

            handler = function ()
                gain( 1, "runes" )
            end
        },


        blooddrinker = {
            id = 206931,
            cast = 3,
            cooldown = 30,
            channeled = true,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 838812,

            talent = "blooddrinker",

            start = function ()
                applyDebuff( "target", "blooddrinker" )
            end,
        },


        bonestorm = {
            id = 194844,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0,
            spendType = "runic_power",

            startsCombat = true,
            texture = 342917,

            talent = "bonestorm",

            handler = function ()
                local cost = min( runic_power.current, 100 )
                spend( cost, "runic_power" )
                applyBuff( "bonestorm", cost / 10 )
            end,
        },


        chains_of_ice = {
            id = 45524,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 135834,

            handler = function ()
                applyDebuff( "target", "chains_of_ice" )
            end,
        },


        consumption = {
            id = 274156,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 1121487,

            talent = "consumption",

            handler = function ()
            end,
        },


        control_undead = {
            id = 111673,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 237273,

            usable = function () return target.is_undead, "requires undead target" end,

            handler = function ()
                summonPet( "controlled_undead" )
            end,
        },


        dancing_rune_weapon = {
            id = 49028,
            cast = 0,
            cooldown = function () return pvptalent.last_dance.enabled and 60 or 120 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135277,

            handler = function ()
                applyBuff( "dancing_rune_weapon" )
                if azerite.eternal_rune_weapon.enabled then applyBuff( "dancing_rune_weapon" ) end
            end,
        },


        dark_command = {
            id = 56222,
            cast = 0,
            cooldown = 8,
            gcd = "off",

            startsCombat = true,
            texture = 136088,

            nopvptalent = "murderous_intent",

            handler = function ()
                applyDebuff( "target", "dark_command" )
            end,
        },


        dark_simulacrum = {
            id = 77606,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = 0,
            spendType = "runic_power",

            startsCombat = true,
            texture = 135888,

            pvptalent = "dark_simulacrum",

            usable = function ()
                if not target.is_player then return false, "target is not a player" end
                return true
            end,

            handler = function ()
                applyDebuff( "target", "dark_simulacrum" )
            end,
        },


        death_and_decay = {
            id = 43265,
            cast = 0,
            cooldown = 15,
            recharge = function ()
                if pvptalent.deaths_echo.enabled then return end
                return 15
            end,
            charges = function ()
                if pvptalent.deaths_echo.enabled then return end
                return 2
            end,
            gcd = "spell",

            spend = function () return buff.crimson_scourge.up and 0 or 1 end,
            spendType = "runes",

            startsCombat = true,
            texture = 136144,

            noOverride = 324128,

            handler = function ()
                removeBuff( "crimson_scourge" )

                if legendary.phearomones.enabled and buff.death_and_decay.down then
                    stat.haste = stat.haste + ( state.spec.blood and 0.1 or 0.15 )
                end

                applyBuff( "death_and_decay" )
            end,
        },


        death_chain = {
            id = 203173,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 1390941,

            pvptalent = "death_chain",

            handler = function ()
                applyDebuff( "target", "death_chain" )
                active_dot.death_chain = min( 3, active_enemies )
            end,
        },


        death_grip = {
            id = 49576,
            cast = 0,
            charges = function ()
                if not pvptalent.deaths_echo.enabled then return end
                return 2
            end,
            cooldown = 15,
            recharge = function ()
                if not pvptalent.deaths_echo.enabled then return end
                return 15
            end,
            gcd = "spell",

            startsCombat = true,
            texture = 237532,

            handler = function ()
                applyDebuff( "target", "death_grip" )
                setDistance( 5 )

                if legendary.grip_of_the_everlasting.enabled and buff.grip_of_the_everlasting.down then
                    applyBuff( "grip_of_the_everlasting" )
                else
                    removeBuff( "grip_of_the_everlasting" )
                end

                if conduit.unending_grip.enabled then applyDebuff( "target", "unending_grip" ) end
            end,

            auras = {
                unending_grip = {
                    id = 338311,
                    duration = 5,
                    max_stack = 1
                }
            }
        },


        death_strike = {
            id = 49998,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( level > 57 and buff.bone_shield.stack >= 5 ) and 40 or 45 end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 237517,

            handler = function ()
                applyBuff( "blood_shield" ) -- gain absorb shield
                gain( 0.075 * health.max * ( 1.2 * buff.haemostasis.stack ) * ( 1.08 * buff.hemostasis.stack ), "health" )
                removeBuff( "haemostasis" )
                removeBuff( "hemostasis" )

                -- TODO: Calculate real health gain from Death Strike to trigger Bryndaor's Might legendary.

                if talent.voracious.enabled then applyBuff( "voracious" ) end
            end,
        },


        deaths_advance = {
            id = 48265,
            cast = 0,
            cooldown = function () return azerite.march_of_the_damned.enabled and 40 or 45 end,
            recharge = function ()
                if pvptalent.deaths_echo.enabled then return end
                return azerite.march_of_the_damned.enabled and 40 or 45
            end,
            charges = function ()
                if pvptalent.deaths_echo.enabled then return end
                return 2
            end,
            gcd = "spell",

            startsCombat = false,
            texture = 237561,

            handler = function ()
                applyBuff( "deaths_advance" )
                if conduit.fleeting_wind.enabled then applyBuff( "fleeting_wind" ) end
            end,

            auras = {
                -- Conduit
                fleeting_wind = {
                    id = 338093,
                    duration = 3,
                    max_stack = 1
                }
            }
        },


        deaths_caress = {
            id = 195292,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 1376743,

            handler = function ()
                applyDebuff( "target", "blood_plague" )
            end,
        },


        gorefiends_grasp = {
            id = 108199,
            cast = 0,
            cooldown = function () return talent.tightening_grasp.enabled and 90 or 120 end,
            gcd = "spell",

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 538767,

            handler = function ()
            end,
        },


        heart_strike = {
            id = 206930,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 135675,

            handler = function ()
                applyDebuff( "target", "heart_strike" )
                local targets = min( active_enemies, buff.death_and_decay.up and 5 or 2 )

                if pvptalent.blood_for_blood.enabled then
                    spend( 0.03 * health.max, "health" )
                end

                if azerite.deep_cuts.enabled then applyDebuff( "target", "deep_cuts" ) end

                if legendary.gorefiends_domination.enabled and cooldown.vampiric_blood.remains > 0 then
                    gainChargeTime( "vampiric_blood", 2 )
                end

                if buff.dancing_rune_weapon.up and set_bonus.tier28_2pc > 0 then
                    buff.dancing_rune_weapon.expires = buff.dancing_rune_weapon.expires + 0.5
                    addStack( "endless_rune_waltz", nil, 1 )
                    buff.endless_rune_waltz.expires = buff.dancing_rune_weapon.expires + 10
                end
            end,
        },


        icebound_fortitude = {
            id = 48792,
            cast = 0,
            cooldown = function () return 180 - ( azerite.cold_hearted.enabled and 15 or 0 ) + ( conduit.chilled_resilience.mod * 0.001 ) end,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 237525,

            handler = function ()
                applyBuff( "icebound_fortitude" )
            end,
        },


        lichborne = {
            id = 49039,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136187,

            handler = function ()
                applyBuff( "lichborne" )
                if conduit.hardened_bones.enabled then applyBuff( "hardened_bones" ) end
            end,

            auras = {
                -- Conduit
                hardened_bones = {
                    id = 337973,
                    duration = 10,
                    max_stack = 1
                }
            }
        },


        mark_of_blood = {
            id = 206940,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = true,
            texture = 132205,

            talent = "mark_of_blood",

            handler = function ()
                applyDebuff( "target", "mark_of_blood" )
            end,
        },


        marrowrend = {
            id = 195182,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 2,
            spendType = "runes",

            startsCombat = true,
            texture = 1376745,

            handler = function ()
                applyBuff( "bone_shield", 30, buff.bone_shield.stack + ( buff.dancing_rune_weapon.up and 6 or 3 ) )
                if azerite.bones_of_the_damned.enabled then applyBuff( "bones_of_the_damned" ) end
            end,
        },


        mind_freeze = {
            id = 47528,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 237527,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                if conduit.spirit_drain.enabled then gain( conduit.spirit_drain.mod * 0.1, "runic_power" ) end
                interrupt()
            end,
        },


        murderous_intent = {
            id = 207018,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            startsCombat = true,
            texture = 136088,

            pvptalent = "murderous_intent",

            handler = function ()
                applyDebuff( "target", "focused_assault" )
            end,
        },


        path_of_frost = {
            id = 3714,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 237528,

            handler = function ()
                applyBuff( "path_of_frost" )
            end,
        },


        raise_dead = {
            id = 46585,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            startsCombat = false,

            toggle = "cooldowns",
            usable = function () return not pet.alive, "cannot have an active pet" end,

            handler = function()
                summonPet( "ghoul" )
            end,
        },


        rune_tap = {
            id = 194679,
            cast = 0,
            charges = function () return level > 43 and 2 or nil end,
            cooldown = 25,
            recharge = function () return level > 43 and 25 or nil end,
            gcd = "off",

            toggle = "defensives",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 237529,

            handler = function ()
                applyBuff( "rune_tap" )
            end,
        },


        --[[ runeforging = {
            id = 53428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 237523,

            handler = function ()
            end,
        }, ]]


        sacrificial_pact = {
            id = 327574,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 20,
            spendType = "runic_power",

            toggle = "defensives",

            startsCombat = true,
            texture = 136133,

            usable = function () return pet.ghoul.alive, "requires an undead pet" end,

            handler = function ()
                gain( 0.25 * health.max, "health" )
                pet.ghoul.expires = query_time - 0.01
            end,
        },


        strangulate = {
            id = 47476,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0,
            spendType = "runes",

            toggle = "interrupts",
            pvptalent = "strangulate",
            interrupt = true,

            startsCombat = true,
            texture = 136214,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
                applyDebuff( "target", "strangulate" )
            end,
        },


        tombstone = {
            id = 219809,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132151,

            talent = "tombstone",
            buff = "bone_shield",

            handler = function ()
                local bs = min( 5, buff.bone_shield.stack )

                removeStack( "bone_shield", bs )
                gain( 6 * bs, "runic_power" )

                -- This is the only predictable Bone Shield consumption that I have noted.
                if cooldown.dancing_rune_weapon.remains > 0 then
                    cooldown.dancing_rune_weapon.expires = cooldown.dancing_rune_weapon.expires - ( 3 * bs )
                end

                if cooldown.blood_tap.charges_fractional < cooldown.blood_tap.max_charges then
                    gainChargeTime( "blood_tap", 2 * bs )
                end

                if set_bonus.tier21_2pc == 1 then
                    cooldown.dancing_rune_weapon.expires = max( 0, cooldown.dancing_rune_weapon.expires - ( 3 * bs ) )
                end

                applyBuff( "tombstone" )
            end,
        },


        vampiric_blood = {
            id = 55233,
            cast = 0,
            cooldown = function () return 90 * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) end,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 136168,

            handler = function ()
                applyBuff( "vampiric_blood" )
                if legendary.gorefiends_domination.enabled then gain( 45, "runic_power" ) end
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


        wraith_walk = {
            id = 212552,
            cast = 4,
            fixedCast = true,
            channeled = true,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 1100041,

            start = function ()
                applyBuff( "wraith_walk" )
            end,
        },


        -- Death Knight - Kyrian    - 312202 - shackle_the_unworthy (Shackle the Unworthy)
        shackle_the_unworthy = {
            id = 312202,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 3565442,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "shackle_the_unworthy" )
            end,

            auras = {
                final_sentence = {
                    id = 353823,
                    duration = 10,
                    max_stack = 5,
                },
            }
        },

        -- Death Knight - Necrolord - 315443 - abomination_limb     (Abomination Limb)
        abomination_limb = {
            id = 315443,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = true,
            texture = 3578196,

            toggle = "essences",

            handler = function ()
                applyBuff( "abomination_limb" )
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
            end,

            auras = {
                abominations_frenzy = {
                    id = 353546,
                    duration = 12,
                    max_stack = 1,
                }
            }
        },

        -- Death Knight - Night Fae - 324128 - deaths_due           (Death's Due)
        deaths_due = {
            id = 324128,
            cast = 0,
            charges = function ()
                if not pvptalent.deaths_echo.enabled then return end
                return 2
            end,
            cooldown = 15,
            recharge = function ()
                if not pvptalent.deaths_echo.enabled then return end
                return 15
            end,
            gcd = "spell",

            spend = function () return buff.crimson_scourge.up and 0 or 1 end,
            spendType = "runes",

            startsCombat = true,
            texture = 3636837,

            notalent = "defile",

            handler = function ()
                removeBuff( "crimson_scourge" )

                if legendary.phearomones.enabled and buff.death_and_decay.down then
                    stat.haste = stat.haste + ( state.spec.blood and 0.1 or 0.15 )
                end

                applyBuff( "death_and_decay" )
                setCooldown( "death_and_decay", 15 )

                applyBuff( "deaths_due_buff" )
                -- TODO:  Model increase RP income within Death's Due.
                applyDebuff( "target", "deaths_due_debuff" )
                -- Note:  Debuff is actually a buff on the target...
            end,

            bind = { "defile", "any_dnd" },

            auras = {
                deaths_due_buff = {
                    id = 324165,
                    duration = function () return legendary.rampant_transference.enabled and 12 or 10 end,
                    max_stack = 15,
                    copy = "deaths_due"
                },
                deaths_due_debuff = {
                    id = 324164,
                    duration = 15,
                    max_stack = 15,
                    generate = function( t, auraType )
                        local name, icon, count, debuffType, duration, expirationTime, caster, stealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = FindUnitDebuffByID( "target", 324164, "PLAYER" )

                        if name and expirationTime > query_time then
                            t.name = name
                            t.count = count > 0 and count or 1
                            t.expires = expirationTime
                            t.applied = expirationTime - duration
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.expires = 0
                        t.applied = 0
                        t.caster = "nobody"
                    end
                },
            }
        },

        -- Death Knight - Venthyr   - 311648 - swarming_mist        (Swarming Mist)
        swarming_mist = {
            id = 311648,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            toggle = "essences",

            startsCombat = true,
            texture = 3565716,

            handler = function ()
                applyBuff( "swarming_mist" )
                if conduit.impenetrable_gloom.enabled then applyBuff( "impenetrable_gloom" ) end
                if legendary.insatiable_hunger.enabled then applyBuff( "insatiable_hunger" ) end
            end,

            auras = {
                -- Conduit
                impenetrable_gloom = {
                    id = 338629,
                    duration = 4,
                    max_stack = 1
                },
                insatiable_hunger = {
                    id = 353729,
                    duration = 8,
                    max_stack = 1,
                },
            }
        },


    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_phantom_fire",

        package = "Blood",
    } )


    spec:RegisterSetting( "save_blood_shield", true, {
        name = "Save |T237517:0|t Blood Shield",
        desc = "If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r) will try to avoid letting your |T237517:0|t Blood Shield fall off during lulls in damage.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Blood", 20220326, [[dW0nabqisbpsHqxIuiSjfvFsHGrjiofPOvPsXRiiZIaDlcbTlk9lbPHrOCmivlJaEMcPPPOuxtrX2uuY3iezCeIY5uiQwhPqvZds5EkY(GehuHOSqcvpKuOYeviIlsiqFKquLrsiG6KkePvQs1ljevmtcb4MKcf7Kq6NecilLuO0tvXujO(kPqQXskKSxO(lfdgXHPAXa9yIMmsxg1MH4ZQKrlWPLSAcrLETc1Sf62KQDl1Vv1WvWXjfIwUspNKPl66a2oK03jLgpHqNxLsRNquvZxqTFqJrhlm(q9KXIkGyciGyJkWSSOlMyZg9zHp5Tdm(m4YX(fJpTRZ4J4X)P4ZGFB8Dkwy8r9aRKXNtPde9S(wJBDKeFabQyosBmi(q9KXIkGyciGyJkWSSOlMyZwSzHpQbwIfvGzedFckkLBmi(qzLeFep(pfsgjSNbqIiNUUcs4DngFLbqIaZiiKiGycia(elvQWcJp0vRbyalmwu0XcJpC7GrMIfhFKBL8wo(acGGyb)MnQGIJuRkD5yibLjizgizoKSandjOmbjcajZHKfOlPz41YRLYiLSsibLjizuXGK5qYc0mYVxSvULU6BZc0Srl7dFB52bJmfFCzwFJp5RdQYVzCIfvaSW4d3oyKPyXXh5wjVLJpHajGaiiwWVzJkO4i1USUxTcsqBcswGMTzPZM8nJcjHddjGaiiwWVzJkO4i1USUxTcsqBcscbsUKuiriir(FK(ABly8FkDREmV2LD6TqYnqs6rUtly8FkDREmVwUDWitHKBGKzdjAcjHddjHajGaiiwWVzJkO4i1QsxogsqdseasMdjHajAasKpQC7DABwUF8xkKeomKacGGyDWxVApRVnXsh0cmajAcjAcjAcjZHKfOlPz41YRLYiLSsibfiraXWhxM134JUV7RD5MItSOJIfgF42bJmflo(i3k5TC8rg47fRGeuMGebGK5qYc0mKG2eKGo(4YS(gFaJ)tnGFfXjw0zJfgF42bJmflo(8d4JIt8XLz9n(GQVLdgz8bvpcW4tiqc6ZajcbjGaiiwQ3YQVmlqZgTSp8TfyasUbsqxmiriirnWXOj99ItLnG9nnQCRXmKCdKKEK70gW(MGl7J51YTdgzkKCdKiaKOj(GQVM21z8jG9nnQCRXSzhm0vloXIodwy8HBhmYuS44JCRK3YXNfOlPz41YRLYiLSsibTjibvFlhmY2a230OYTgZMDWqxTqYCirdqsiqs6rUtl43Sk)v3YTdgzkKmhsK)hPV22c(nRYF1TlR7vRGe0GebGenXhxM134dL9mWOYTgZ4el6SWcJpC7GrMIfhFKBL8wo(SaDjndVwEHeuMGe0ftm8XLz9n(a(nRYF1Xjwurclm(WTdgzkwC8rUvYB54Zc0SnlD2KVraibni5ssHKWHHKfOlPz41YRLYiLSsibLjibvFlhmY2a230OYTgZMDWqxT4JlZ6B8jG9nnQCRXmoXIkYWcJpC7GrMIfhFKBL8wo(Og4y0K(EXPYszpdmEtnuw63cjOmbjJIpUmRVXhk7zGXBQHYs)wCIt8r(OYT3Pclmwu0XcJpC7GrMIfhFKBL8wo(ObibeabXszpdugkaBbgGKWHHeqaeelL9mqzOaSDzDVAfKGgKmBijCyibeabXk3sx9TrjFG9ITad4JlZ6B8HYEgOmuagNyrfalm(WTdgzkwC8rUvYB54J8)i912wQ3YQVmlqZgTSp8TDzDVAfKGcKmkKmhswGUKMHxlVqcktqsiqYixmirecjHajQbognPVxCQSkT(Qx9LrVujKCdKmkKOjKOj(4YS(gFuA9vV6lJEPsCIfDuSW4d3oyKPyXXh5wjVLJpAasabqqSuVLvFzwGMnAzF4BlWa(4YS(gFCWxVApRVnXsheNyrNnwy8HBhmYuS44JCRK3YXh1debRMAhaujqKn8cmK13wUDWitHKWHHe1debRMAr9JEwr2O(iQCNwUDWitHK5qIgGeqaeelQF0ZkYg1hrL70eaO79xulWa(uDY7cmKMcbFupqeSAQf1p6zfzJ6JOYDIpvN8UadPP01zA5jJpOJpUmRVXhKiRcKRJK4t1jVlWqAUIpOhXh0Xjw0zWcJpC7GrMIfhFKBL8wo(SandjObjJcjZHKfOlPz41YlKGgKGUyIHpUmRVXhvGlhhztgWgGw7VzWT4eN4ZWYYxh0tSWyrrhlm(WTdgzkwC8HYk5wdz9n(ickISeizkKaYi)YqI81b9esa5RQvwizKjL8qQGK(BryGV6iariXLz9Tcs(oERfFCzwFJpirwfixhjXjoXh9kRlpRVXcJffDSW4d3oyKPyXXh5wjVLJpbShZa7GmHe0GKzedschgscbs0aKCTpWaKmhscypMb2bzcjObjZAwqIM4JlZ6B8bvxFO2sAaJ)tXjwubWcJpC7GrMIfhFCzwFJpu2ZaJk3AmJpuwj3AiRVXNrAlF9QVGeQR7xmKSSgjqTSo3jKukirGz0iGKhbs0DrescypMbqI6JVGqYmIPrajpcKO7IiKeWEmdGKQHehsU2hyWIpYTsElhFQw(6vFzOUUFXMrvqcktqsa7XmWkb2L7eNyrhflm(WTdgzkwC8XLz9n(qzpdmQCRXm(qzLCRHS(gFgjFpcjKe5es8gsyrSuz1xqI4X)PqYjO4ifsO7pyXh5wjVLJpkhv2ag)NAubfhPqYCiPA5Rx9LH66(fBMrbjOajIbjZHeqaeely8FQrfuCKAbgGK5qciacIfm(p1OckosTlR7vRGe0Ge0TZaj3ajxskoXIoBSW4d3oyKPyXXh5wjVLJpP3JR(csMdjGaii2fOzt6dw6RTHK5qs1YxV6ld119l2mQcsqbscypMbwDxeHKBGeXSOJpUmRVXNfOzt6d4el6myHXhUDWitXIJpYTsElhFcypMb2bzcjObjZigKicHKqGebedsUbsabqqSGX)PgvqXrQfyas0eFCzwFJpLKbFGMAq(nReGY4el6SWcJpC7GrMIfhFKBL8wo(eWEmdSdYesqdsePzGK5qYaN2RGhiAxw3RwbjObjZGpUmRVXhLl3cPKLhndUmXjoXhkJ4aXelmwu0XcJpC7GrMIfhFOSsU1qwFJpIGIilbsMcjmQ8ElKKLodjzadjUm)fskfK4O6v0bJSfFCzwFJp6vtnilZI8zCIfvaSW4d3oyKPyXXNFaFuCwi4JlZ6B8bvFlhmY4dQ(AAxNXhk7zGrLBnMnua9bJR)aDIpYTsElhFKpQC7DA76kiniodjZHeqaeelL9mqzOaSDzDVAfKGcKml8bvpcWgoQy8zMzWhu9iaJpIKy4el6OyHXhUDWitXIJpYTsElhFabqqSGFZgvqXrQDzDVAfKGgKmkKCdKCjPwwezjqYqs4WqsiqciacIf8B2OckosTlR7vRGe0MGKfOzBw6SjFZOqs4WqciacIf8B2OckosTlR7vRGe0MGKqGKljfsecsK)hPV22cg)Ns3QhZRDzNElKCdKKEK70cg)Ns3QhZRLBhmYui5girairtijCyibeabXc(nBubfhPwv6YXqcAqYmqIMqYCizb6sAgET8APmsjResqzcseqm8XLz9n(O77(AxUP4el6SXcJpC7GrMIfhFKBL8wo(KEpU6lijCyiPA5Rx9LH66(fBMrbjOajIHpQClzIffD8XLz9n(i9y04YS(2elvIpXsLM21z8rVY6YZ6BCIfDgSW4d3oyKPyXXh5wjVLJpGaiiwQ3YQVmlqZgTSp8TfyaFOSsU1qwFJpNQLmKKbmKm8z9nKi)psFTnKe4kirg49ftfes0YJqmcjQBBjKOTYaizKOXQrJpUmRVXNHpRVXjw0zHfgFCzwFJpak2ujRRWhUDWitXIJtSOIewy8HBhmYuS44t76m(C5OYrZJyYa2GuRkn(cwjV4JlZ6B85YrLJMhXKbSbPwvA8fSsEXjwurgwy8XLz9n(SEPydLDk(WTdgzkwCCIfDKJfgF42bJmflo(i3k5TC8rdqciacIL6TS6lZc0Srl7dFBbgGK5qsiqIgGe5Jk3EN2UUcsdIZqs4WqciacILYEgOmua2USUxTcsqbsejirt8XLz9n(ag)Ns3QhZloXIIUyyHXhUDWitXIJpUmRVXhPhJgxM13MyPs8jwQ00UoJpRllpQWjwu0rhlm(WTdgzkwC8XLz9n(OC5wiLS8OzWLj(qzLCRHS(gFgzzY6djKKpKOC5wiLKHKmGHKRGhicjfcKOLHKHLPLmDW4TqI2kgHK(tiH(qIoGmasQgsYagsA2xibbibwgFKBL8wo(ecKObir(OYT3PTRRG0G4mKeomKacGGyPSNbkdfGTlR7vRGeuGKzbjAcjZHeqaeel1Bz1xMfOzJw2h(2USUxTcsqbsMnKmhscbsg40Ef8ar7Y6E1kibniraijCyij99ItBw6SjFdTyibni5ssHenXjwu0falm(WTdgzkwC8XLz9n(i9y04YS(2elvIpXsLM21z8r(OYT3PcNyrrFuSW4d3oyKPyXXh5wjVLJpHajlqZqcAtqIaqYCizbA2MLoBY3mBibfi5ssHK5qImW3lwzqwxM13Eesqzcsq3kYGenHKWHHKfOzBw6SjFZOqckqYLKIpUmRVXhW4)ut6d4elk6Zglm(WTdgzkwC8rUvYB54JgGeqaeel1Bz1xMfOzJw2h(2cmGpUmRVXhQ3YQVmlqZgTSp8noXII(myHXhUDWitXIJpYTsElhFabqqSuVLvFzwGMnAzF4BlWa(4YS(gFwG24YS(2elvIpXsLM21z8HUAnad4elk6Zclm(WTdgzkwC8XLz9n(i9y04YS(2elvIpXsLM21z8rLEt9LItCIpRllpQWcJffDSW4d3oyKPyXXh5wjVLJpY)J0xBBPElR(YSanB0Y(W32LD6TqYCijeirdqI8)i912wW4)u6w9yETl70BHKWHHenajPh5oTGX)P0T6X8A52bJmfs0eFCzwFJpGX)PgeG9wCIfvaSW4JlZ6B8bKxfVJR(cF42bJmflooXIokwy8HBhmYuS44JCRK3YXhxMfQSHBwVyfKGYeKiaKeomKSandjObjOdjZHKfOlPz41YRLYiLSsibfizwIHpUmRVXhFLEZMbGOIXjw0zJfgF42bJmflo(i3k5TC8beabXc0bF8wJkxUVYalWa(4YS(gFI1vqQmICbOx6CN4el6myHXhxM134J3swLRhnspgXhUDWitXIJtSOZclm(4YS(gFqQLbJ)tXhUDWitXIJtSOIewy8XLz9n(a6xMhXKBjhRWhUDWitXIJtSOImSW4d3oyKPyXXh5wjVLJplqxsZWRLxlLrkzLqckqIaIHpUmRVXhFLEZM83L7eN4eFuP3uFPyHXIIowy8HBhmYuS44JCRK3YXNfOlPz41YRLYiLSsibTjibDXGK5qsiqIgGK0JCNwWVzv(RULBhmYuijCyirdqI8)i912wWVzv(RUDzNElKeomKacGGyPElR(YSanB0Y(W3wGbirt8XLz9n(qzpdmQCRXmoXIkawy8HBhmYuS44JCRK3YXNboTxbpq0USUxTcsqdsUKui5gira8XLz9n(OC5wiLS8OzWLjoXIokwy8HBhmYuS44JCRK3YXh5Jk3EN2UUcsdIZqYCiHYEgy8MAOS0V1MLCC1xqYCijeibeabXszpdugkaBbgGK5qciacILYEgOmua2USUxTcsqdsMfKOj(4YS(gFcyFtJk3AmJtSOZglm(WTdgzkwC8rUvYB54diacIf8B2OckosTQ0LJHeuMGKzGK5qYc0mKGYeKiaKmhswGUKMHxlVwkJuYkHeuMGKrfdFCzwFJp5RdQYVzCIfDgSW4d3oyKPyXXh5wjVLJpHajGaiiwWVzJkO4i1USUxTcsqBcswGMTzPZM8nJcjHddjGaiiwWVzJkO4i1USUxTcsqBcscbsUKuiriir(FK(ABly8FkDREmV2LD6TqYnqs6rUtly8FkDREmVwUDWitHKBGKzdjAcjHddjGaiiwWVzJkO4i1QsxogsqdsMfKeomKecKecKObir(OYT3PTRRG0G4mKeomKacGGyPSNbkdfGTlR7vRGeuGKzGenHK5qciacIf8B2OckosTlR7vRGe0Gercs0es0esMdjlqxsZWRLxlLrkzLqckqIaIHpUmRVXhDF3x7YnfNyrNfwy8HBhmYuS44JCRK3YXNfOlPz41YRLYiLSsibTjibvFlhmYwk7zGrLBnMnua9bJR)aDcjZHenajHajPh5oTGFZQ8xDl3oyKPqYCir(FK(ABl43Sk)v3USUxTcsqdseas0esMdjAascbsKpQC7DArL7m42fsMdjY)J0xBBvA9vV6lJEPs7Y6E1kibnizuirt8XLz9n(qzpdmQCRXmoXIksyHXhUDWitXIJpYTsElhFKb(EXkdY6YS(2Jqcktqc6wrgKmhscbsabqqSbS(RsxvkRkD5yibTjijeizgirecjQbognPVxCQSGX)PgWVIqIMqs4WqIAGJrt67fNkly8FQb8RiKGcKiaKOj(4YS(gFaJ)tnGFfXjwurgwy8HBhmYuS44JlZ6B8r33XMhXag)NIpuwj3AiRVXhngFhdjpcKiE8FkKqFwbj9NqYG3uwVKIqwetUPw8rUvYB54dLbbqqS6(o28igW4)ul912qYCibPUcsZY6E1kibfirKSZGtSOJCSW4d3oyKPyXXh5wjVLJpGaiiw5w6QVnk5dSxSfyasMdjPh5oTlhlvGPAdy8FQLBhmYuizoKSaDjndVwETugPKvcjOajOlg(4YS(gFOSNbgVPgkl9BXjwu0fdlm(WTdgzkwC8rUvYB54Zc0L0m8A5fsqzcsqxmXWhxM134d43Sk)vhNyrrhDSW4d3oyKPyXXNFaFuCwi4JlZ6B8bvFlhmY4dQ(AAxNXNa230OYTgZMDaFKBL8wo(iFu527021vqAqCgsMdju2ZaJ3udLL(T2SKJR(cFq1JaSHJkgFcbsqFgiriirnWXOj99ItLnG9nnQCRXmKCdKKEK70gW(MGl7J51YTdgzkKCdKiaKOjKCdKGUva8bvpcW4tiqc6ZajcbjQbognPVxCQSbSVPrLBnMHKBGK0JCN2a23eCzFmVwUDWitHKBGebGenXjwu0falm(WTdgzkwC8rUvYB54tiqYc0L0m8A51szKswjKG2eKGQVLdgzBa7BAu5wJzZoajAcjHddjPVxCAZsNn5BOfdjObjOlg(4YS(gFOSNbgvU1ygNyrrFuSW4d3oyKPyXXh5wjVLJpQbognPVxCQSu2ZaJ3udLL(TqcktqYO4JlZ6B8HYEgy8MAOS0VfNyrrF2yHXhUDWitXIJpYTsElhFwGMTzPZM8nZgsqdsUKu8XLz9n(eW(MgvU1ygNyrrFgSW4d3oyKPyXXh5wjVLJpGaiiw5w6QVnk5dSxSfyaschgsspYDAxFOOgklF9Hxvz9TLBhmYu8XLz9n(qzpdmEtnuw63ItSOOplSW4d3oyKPyXXh5wjVLJpGaiiwWVzJkO4i1USUxTcsqbsgfsUbsUKu8XLz9n(i)wbOpK134elk6Iewy8HBhmYuS44JCRK3YXhzGVxSYGSUmRV9iKGYeKGUfDizoKacGGyb)MnQGIJu7Y6E1kibfizui5gi5ssXhxM134dy8FQb8RioXIIUidlm(WTdgzkwC8rUvYB54Zc0mKGcKGoKmhscbswGMTzPZM8nJcjObjxskKeomKacGGyb)MnQGIJuRkD5yibfirKGK5qciacIf8B2OckosTlR7vRGeuGKfOzBw6SjFZOqIqqYLKcjAIpUmRVXNa230OYTgZ4elk6JCSW4d3oyKPyXXh5wjVLJplqxsZWRLxlLrkzLqckqIaIHpUmRVXhFLEZM83L7eN4eN4dQ8QQVXIkGyciGyJI(ihF06Bx9LcF0OhzASIosfvKNgpKajchWqsPp8Bcji)cjJaD1AaggbizznsGAzkKOEDgsCG819KPqImW7lwzH3fbundjORXdjACFJkVjtHKrybAg53l2Qrncqs(qYiSanJ87fB1OSC7GrMocqINqIiOiqIaGKqqxe10cVdVRrpY0yfDKkQipnEibseoGHKsF43esq(fsgb5Jk3ENQraswwJeOwMcjQxNHehiFDpzkKid8(Ivw4DravZqYS14HenUVrL3KPqYiOEGiy1uRg1iaj5djJG6bIGvtTAuwUDWithbijebernTW7W7Ju9HFtMcjIeK4YS(gsILkvw4D8zyFKkY4ZicjIh)NcjJe2ZairKtxxbj8(icjAm(kdGebMrqiraXeqa4D49resebfrwcKmfsazKFzir(6GEcjG8v1klKmYKsEivqs)TimWxDeGiK4YS(wbjFhV1cV7YS(wzhww(6GEk0uOirwfixhjH3H3hrireuezjqYuiHrL3BHKS0zijdyiXL5VqsPGehvVIoyKTW7UmRVvt6vtnilZI8z4DxM13kHMcfvFlhmYc2UoprzpdmQCRXSHcOpyC9hOtbr1Ja8KijMG)WKIZcrq530kRVNKpQC7DA76kiniopheabXszpdugkaBxw3RwHYSeevpcWgoQ4PzMbE3Lz9TsOPq19DFTl3ublKjqaeel43SrfuCKAxw3RwH2O3CjPwwezjqYHdhciacIf8B2OckosTlR7vRqBAbA2MLoBY3mA4WGaiiwWVzJkO4i1USUxTcTPqUKuHK)hPV22cg)Ns3QhZRDzNE7nPh5oTGX)P0T6X8A52bJm9gb0mCyqaeel43SrfuCKAvPlhJ2mAoFb6sAgET8APmsjReLjbedE3Lz9TsOPqLEmACzwFBILkfSDDEsVY6YZ6Bbv5wYCcDblKP07XvFfoC1YxV6ld119l2mJcfXG3hri5uTKHKmGHKHpRVHe5)r6RTHKaxbjYaVVyQGqIwEeIrirDBlHeTvgajJenwnA4DxM13kHMcD4Z6BblKjqaeel1Bz1xMfOzJw2h(2cmaV7YS(wj0uOak2ujRRG3DzwFReAkuafBQK1fSDDE6YrLJMhXKbSbPwvA8fSsEH3DzwFReAk01lfBOStH3DzwFReAkuW4)u6w9yEfSqM0aiacIL6TS6lZc0Srl7dFBbgMhIgKpQC7DA76kiniohomiacILYEgOmua2USUxTcfrst4DxM13kHMcv6XOXLz9TjwQuW215P1LLhvW7JiKmYYK1hsijFir5YTqkjdjzadjxbpqeskeirldjdltlz6GXBHeTvmcj9Nqc9HeDazaKunKKbmK0SVqccqcSm8UlZ6BLqtHQC5wiLS8OzWLPGfYuiAq(OYT3PTRRG0G4C4WGaiiwk7zGYqby7Y6E1kuMLMZbbqqSuVLvFzwGMnAzF4B7Y6E1kuM98qg40Ef8ar7Y6E1k0eiC403loTzPZM8n0Ir7ss1eE3Lz9TsOPqLEmACzwFBILkfSDDEs(OYT3PcE3Lz9TsOPqbJ)tnPpiyHmfYc0mAtcmFbA2MLoBY3mBuUK05YaFVyLbzDzwF7ruMq3kY0mC4fOzBw6SjFZOOCjPW7UmRVvcnfk1Bz1xMfOzJw2h(wWczsdGaiiwQ3YQVmlqZgTSp8TfyaE3Lz9TsOPqxG24YS(2elvky768eD1AageSqMabqqSuVLvFzwGMnAzF4BlWa8UlZ6BLqtHk9y04YS(2elvky768Kk9M6lfEhE3Lz9TYkFu527unrzpdugkalyHmPbqaeelL9mqzOaSfyiCyqaeelL9mqzOaSDzDVAfAZoCyqaeeRClD13gL8b2l2cmaV7YS(wzLpQC7DQeAkuLwF1R(YOxQuWczs(FK(ABl1Bz1xMfOzJw2h(2USUxTcLrNVaDjndVwErzkKrUyIWqudCmAsFV4uzvA9vV6lJEPYBgvtnH3DzwFRSYhvU9ovcnfQd(6v7z9Tjw6GcwitAaeabXs9ww9LzbA2OL9HVTadW7UmRVvw5Jk3ENkHMcfjYQa56iPGfYK6bIGvtTdaQeiYgEbgY67WHvpqeSAQf1p6zfzJ6JOYDoxdGaiiwu)ONvKnQpIk3Pjaq37VOwGbbRo5DbgstPRZ0YtEcDbRo5DbgsZv8b94e6cwDY7cmKMczs9arWQPwu)ONvKnQpIk3j8UlZ6BLv(OYT3PsOPqvbUCCKnzaBaAT)Mb3kyHmTanJ2OZxGUKMHxlVOHUyIbVdV7YS(wzPRwdWWu(6GQ8BwWczceabXc(nBubfhPwv6YXOmnZ8fOzuMey(c0L0m8A51szKswjktJk28fOzKFVyRClD13MfOzJw2h(gE3Lz9TYsxTgGbHMcv3391UCtfSqMcbeabXc(nBubfhP2L19QvOnTanBZsNn5BgnCyqaeel43SrfuCKAxw3RwH2uixsQqY)J0xBBbJ)tPB1J51UStV9M0JCNwW4)u6w9yETC7GrMEZS1mC4qabqqSGFZgvqXrQvLUCmAcmpeniFu52702SC)4V0WHbbqqSo4RxTN13MyPdAbg0utnNVaDjndVwETugPKvIIaIbV7YS(wzPRwdWGqtHcg)NAa)kkyHmjd89IvOmjW8fOz0MqhE3Lz9TYsxTgGbHMcfvFlhmYc2UopfW(MgvU1y2Sdg6Qvqu9iapfc6ZieiacIL6TS6lZc0Srl7dFBbgUbDXesnWXOj99ItLnG9nnQCRX8nPh5oTbSVj4Y(yETC7GrMEJaAcV7YS(wzPRwdWGqtHszpdmQCRXSGfY0c0L0m8A51szKswjAtO6B5Gr2gW(MgvU1y2Sdg6QDUgcj9i3Pf8BwL)QB52bJmDU8)i912wWVzv(RUDzDVAfAcOj8UlZ6BLLUAnadcnfk43Sk)vxWczAb6sAgET8IYe6Ijg8UlZ6BLLUAnadcnfAa7BAu5wJzblKPfOzBw6SjFJaODjPHdVaDjndVwETugPKvIYeQ(woyKTbSVPrLBnMn7GHUAH3DzwFRS0vRbyqOPqPSNbgVPgkl9BfSqMudCmAsFV4uzPSNbgVPgkl9BrzAu4D4DxM13kREL1LN13tO66d1wsdy8FQGfYua7XmWoit0MrSWHdrdx7dmmpG9ygyhKjAZAwAcVpIqYiTLVE1xqc119lgswwJeOwwN7eskfKiWmAeqYJaj6UicjbShZair9XxqizgX0iGKhbs0DrescypMbqs1qIdjx7dmyH3DzwFRS6vwxEwFl0uOu2ZaJk3AmlyHmvT81R(YqDD)InJQqzkG9ygyLa7YDcVpIqYi57riHKiNqI3qclILkR(csep(pfsobfhPqcD)bl8UlZ6BLvVY6YZ6BHMcLYEgyu5wJzblKjLJkBaJ)tnQGIJ05vlF9QVmux3VyZmkueBoiacIfm(p1OckosTadZbbqqSGX)PgvqXrQDzDVAfAOBN5MljfE3Lz9TYQxzD5z9TqtHUanBsFqWczk9EC1xZbbqqSlqZM0hS0xBpVA5Rx9LH66(fBgvHsa7XmWQ7I4nIzrhE3Lz9TYQxzD5z9TqtHwsg8bAQb53SsaklyHmfWEmdSdYeTzetegIaIDdiacIfm(p1OckosTadAcV7YS(wz1RSU8S(wOPqvUClKswE0m4YuWczkG9ygyhKjAI0mZh40Ef8ar7Y6E1k0MbEhE3Lz9TYUUS8OAcm(p1GaS3kyHmj)psFTTL6TS6lZc0Srl7dFBx2P3openi)psFTTfm(pLUvpMx7Yo92WH1q6rUtly8FkDREmVwUDWit1eE3Lz9TYUUS8OsOPqb5vX74QVG3DzwFRSRllpQeAkuFLEZMbGOIfSqMCzwOYgUz9IvOmjq4WlqZOH(8fOlPz41YRLYiLSsuMLyW7UmRVv21LLhvcnfASUcsLrKla9sN7uWczceabXc0bF8wJkxUVYalWa8UlZ6BLDDz5rLqtH6TKv56rJ0Jr4DxM13k76YYJkHMcfPwgm(pfE3Lz9TYUUS8OsOPqb9lZJyYTKJvW7UmRVv21LLhvcnfQVsVzt(7YDkyHmTaDjndVwETugPKvIIaIbVdV7YS(wzvP3uFPtu2ZaJk3AmlyHmTaDjndVwETugPKvI2e6InpenKEK70c(nRYF1TC7GrMgoSgK)hPV22c(nRYF1Tl70BdhgeabXs9ww9LzbA2OL9HVTadAcV7YS(wzvP3uFPcnfQYLBHuYYJMbxMcwitdCAVcEGODzDVAfAxs6ncaVpIJiK4YS(wzvP3uFPcnfky8FkDREmVcwitAaeabXs9ww9LzbA2OL9HVTadW7J4icjJeGHyj9KPqsaVmKaYshqXqsgWqIEL1LN13qsSujKSCSyfK8nKKEpU6RqtFC1xqc119l2cVpIJiK4YS(wzvP3uFPcnfQUV7RD5MkyHmbcGGyb)MnQGIJu7Y6E1k0g9Mlj1YIilbsoC4qabqqSGFZgvqXrQDzDVAfAtlqZ2S0zt(MrdhgeabXc(nBubfhP2L19QvOnfYLKkK8)i912wW4)u6w9yETl70BVj9i3Pfm(pLUvpMxl3oyKP3iGMHddcGGyb)MnQGIJuRkD5y0gvZ5lqxsZWRLxlLrkzLOmjGyW7UmRVvwv6n1x6ua7BAu5wJzblKj5Jk3EN2UUcsdIZZPSNbgVPgkl9BTzjhx918qabqqSu2ZaLHcWwGH5Gaiiwk7zGYqby7Y6E1k0MLMW7UmRVvwv6n1xQqtHMVoOk)MfSqMabqqSGFZgvqXrQvLUCmktZmFbAgLjbMVaDjndVwETugPKvIY0OIbV7YS(wzvP3uFPcnfQUV7RD5MkyHmfciacIf8B2OckosTlR7vRqBAbA2MLoBY3mA4WGaiiwWVzJkO4i1USUxTcTPqUKuHK)hPV22cg)Ns3QhZRDzNE7nPh5oTGX)P0T6X8A52bJm9MzRz4WGaiiwWVzJkO4i1QsxogTzfoCiHOb5Jk3EN2UUcsdIZHddcGGyPSNbkdfGTlR7vRqzgnNdcGGyb)MnQGIJu7Y6E1k0ejn1C(c0L0m8A51szKswjkcig8UlZ6BLvLEt9Lk0uOu2ZaJk3AmlyHmTaDjndVwETugPKvI2eQ(woyKTu2ZaJk3AmBOa6dgx)b6CUgcj9i3Pf8BwL)QB52bJmDU8)i912wWVzv(RUDzDVAfAcO5CneI8rLBVtlQCNb3UZL)hPV22Q06RE1xg9sL2L19QvOnQMW7UmRVvwv6n1xQqtHcg)NAa)kkyHmjd89IvgK1Lz9ThrzcDRiBEiGaii2aw)vPRkLvLUCmAtHmJiunWXOj99ItLfm(p1a(vuZWHvdCmAsFV4uzbJ)tnGFfrranH3hrirJX3XqYJajIh)Ncj0Nvqs)jKm4nL1lPiKfXKBQfE3Lz9TYQsVP(sfAkuDFhBEedy8FQGfYeLbbqqS6(o28igW4)ul912ZrQRG0SSUxTcfrYod8UlZ6BLvLEt9Lk0uOu2ZaJ3udLL(TcwitGaiiw5w6QVnk5dSxSfyyE6rUt7YXsfyQ2ag)NA52bJmD(c0L0m8A51szKswjkOlg8UlZ6BLvLEt9Lk0uOGFZQ8xDblKPfOlPz41YlktOlMyW7UmRVvwv6n1xQqtHIQVLdgzbBxNNcyFtJk3AmB2bbr1Ja8uiOpJqQbognPVxCQSbSVPrLBnMVj9i3PnG9nbx2hZRLBhmY0Beqtb)HjfNfIGYVPvwFpjFu527021vqAqCEoL9mW4n1qzPFRnl54QVeevpcWgoQ4PqqFgHudCmAsFV4uzdyFtJk3AmFt6rUtBa7BcUSpMxl3oyKP3iGM3GUva4DxM13kRk9M6lvOPqPSNbgvU1ywWczkKfOlPz41YRLYiLSs0Mq13YbJSnG9nnQCRXSzh0mC403loTzPZM8n0IrdDXG3DzwFRSQ0BQVuHMcLYEgy8MAOS0VvWczsnWXOj99ItLLYEgy8MAOS0VfLPrH3DzwFRSQ0BQVuHMcnG9nnQCRXSGfY0c0SnlD2KVz2ODjPW7UmRVvwv6n1xQqtHszpdmEtnuw63kyHmbcGGyLBPR(2OKpWEXwGHWHtpYDAxFOOgklF9Hxvz9TLBhmYu4DxM13kRk9M6lvOPqLFRa0hY6BblKjqaeel43SrfuCKAxw3RwHYO3CjPW7UmRVvwv6n1xQqtHcg)NAa)kkyHmjd89IvgK1Lz9ThrzcDl6ZbbqqSGFZgvqXrQDzDVAfkJEZLKcV7YS(wzvP3uFPcnfAa7BAu5wJzblKPfOzuqFEilqZ2S0zt(Mrr7ssdhgeabXc(nBubfhPwv6YXOisZbbqqSGFZgvqXrQDzDVAfklqZ2S0zt(Mrf6ss1eE3Lz9TYQsVP(sfAkuFLEZM83L7uWczAb6sAgET8APmsjRefbedFCGm4x85u6ACqIqqIiW84kw4eNym]] )

end