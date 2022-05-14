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

            if state.buff.dancing_rune_weapon.up and state.azerite.eternal_rune_weapon.enabled then
                if state.buff.dancing_rune_weapon.expires - state.buff.dancing_rune_weapon.applied < state.buff.dancing_rune_weapon.duration + 5 then
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

            max_targets = function () return buff.death_and_decay.up and 5 or 2 end,

            handler = function ()
                applyDebuff( "target", "heart_strike" )
                local targets = min( active_enemies, buff.death_and_decay.up and 5 or 2 )
                active_dot.heart_strike = targets

                if pvptalent.blood_for_blood.enabled then
                    spend( 0.03 * health.max, "health" )
                end

                if azerite.deep_cuts.enabled then applyDebuff( "target", "deep_cuts" ) end

                if legendary.gorefiends_domination.enabled and cooldown.vampiric_blood.remains > 0 then
                    gainChargeTime( "vampiric_blood", 2 )
                end

                if buff.dancing_rune_weapon.up and set_bonus.tier28_2pc > 0 then
                    buff.dancing_rune_weapon.expires = buff.dancing_rune_weapon.expires + ( set_bonus.tier28_4pc > 0 and 0.5 or 1 )
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
                applyBuff( "bone_shield", 30, buff.bone_shield.stack + ( buff.dancing_rune_weapon.up and ( set_bonus.tier28_4pc > 0 and 9 or 6 ) or 3 ) )
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


    spec:RegisterSetting( "blood_boil_drw", false, {
        name = "With Tier 28, use |T237513:0|t Blood Boil in AOE during |T135277:0|t Dancing Rune Weapon (Tier)",
        desc = "If checked, when you have Tier 28 4-piece, the addon will recommend more |T237513:0|t Blood Boil in AOE while |T135277:0|t Dancing Rune Weapon is active.\n\n" ..
            "This can help with AOE threat and damage, but can reduce your self-healing, absorbs, and potentially your Dancing Rune Weapon uptime.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Blood", 20220514, [[dWKphbqiOepIQI6skcuBIQQpbizuiHtHeTkOKEfPOzHu6was1UO4xkidJQshdjzziPEgGyAuv4AkI2gsbFdPiJJQI4CasX6OQinpOO7bW(GsDqfH0crQ6HkcQjQiixePq1hrkKmsKcPCsfHyLaQxQiantKcLBQiG2jPWprkKQLQiuEkitfPYxveQglGuAVi(lLgmKdlSyGEmrtMWLrTzO6ZkQrtvoTuRwra8AfPztLBtQ2TKFRYWvOJJuiwUQEojtx01b12HcFNuA8if15vqTEfbY8vG9R0eQi0rGerYenO2xQP23jPYhgQOjFqTpMKaLdpYeOXqonMzcuf6mbIE3Dcc0ymS7cbHocK6GFjtGGADyxK9vt4pWtceiC7YjsrajqIizIgu7l1u77Ku5ddv0KpO2haHaPgzjrdQN0xcKxleCrajqcwjjq07UtSOjehP3IMaw9SxUapbgdViQ8bTlIAFPM6f4f4jSxuZSYNUad0xee84495IWVFr07UtSi6V2TOUw0eAInXxKIZSRzdbY1QurOJajETw4rcDenOIqhbIRa0Xcc9ei53j)DqGaHXXnGxXwLxZoHrLHC6IWErtUi)l6HlErydyruVi)l6HRwAhpT8BemEl7CrydyraX3f5FrpCX43pZg536QRSpCXwTCmELHRa0XccuiZ(kcuE6GQ8kMKenOMqhbIRa0Xcc9ei53j)DqGOyrGW44gWRyRYRzNW8SE0LArycyrpCXMS1zBEwGSObdweimoUb8k2Q8A2jmpRhDPweMaweflAwkwKMlsENtCAldO7oH47Ak)MNdXWlcRlkdhxPb0DNq8DnLFdxbOJflcRlYhlIYfnyWIOyrGW44gWRyRYRzNWOYqoDryUiQxK)frXIWYIKhgCfvAkw(N7EXIgmyrGW44Ma807kY(kRR1bnWJlIYfr5IOCr(x0dxT0oEA53iy8w25IWEru7lbkKzFfbsp()0(CjijrdGqOJaXva6ybHEcK87K)oiquSikwK0l(zwTiSbSiQxK)f9WfVimbSiQweLlAWGfjU0a6UtyhDXmmBEwp6sTimbSiQxeLlAWGfrXIuJSZzZ4N5uzaD3jSGx7we2lAYf5FrsV4NzLf)dz2xfUfHnGfrLHQfr5I8ViSSikwK8WGROsdgCLEd)lY)IaHXXnkTXR31SvVvPbECrusGcz2xrGaD3jSGx7ijrdFqOJaXva6ybHEc0nsGuCsGcz2xrGWi(oaDmbcJWbZeikwe1tUinxKAKDoBg)mNkJhhFAv53t5fH1fLHJR04XXNGpht53Wva6yXIW6IOErusGWiEBf6mbYJJpTQ87PS9hTIxljjAmjHocexbOJfe6jqHm7RiqcospRk)EktGKFN83bbcegh3a6UtyvEn7eMN1JUulcZfnlflAWGf9WvlTJNw(ncgVLDUimbSimIVdqhB844tRk)EkB)rR41Ui)lcllIIfLHJR0aEfRY71nCfGowSi)lsENtCAld4vSkVx38SE0LAryUiQxeLeixxSvkiq(aREHkzss0Ggi0rG4kaDSGqpbs(DYFheikwKAKDoBg)mNkJGJ0ZgLWkyzm8IaSiGSi)lcegh3i)wxDLvjp4FMnWJlIYfnyWIuJSZzZ4N5uzeCKE2OewblJHxe2awKpiqHm7RiqcospBucRGLXWKKObnrOJaXva6ybHEcK87K)oiqpC1s74PL)fHnGfrLV(Ui)lcegh3WLWXkL9Hl2QnC5eKrLHC6IWEr(yr(xewweflsEyWvuPbdUsVH)f5FrY7CItBzuAJxVRzRERsZZ6rxQfH5IaYIOKafYSVIabEfRY71jjrdFcHocexbOJfe6jqHm7RiqGU7ewWRDei53j)DqGuCMDnRmGU7ewWRDwXRDr(xKAKDoBg)mNkdO7oHf8A3IWErutGCDXwPGa5dS6fQKjjrdGgcDeiUcqhli0tGKFN83bb6Hl2KToBZZs9IWCrZsbbkKzFfbYJJpTQ87PmjjAqLVe6iqCfGowqONaj)o5Vdc0dxT0oEA53iy8w25IWeWIWi(oaDSXJJpTQ87PS9hTIx7I8ViSSikwugoUsd4vSkVx3Wva6yXI8Vi5DoXPTmGxXQ8EDZZ6rxQfH5IOErusGcz2xrGeCKEwv(9uMKenOIkcDeOqM9vei5vky9XSVIaXva6ybHEssscK8WGROsfHoIgurOJaXva6ybHEcK87K)oiqyzrGW44gbhPNYkGzd84IgmyrGW44gbhPNYkGzZZ6rxQfH5I8XIgmyrGW44g536QRSk5b)ZSbEKafYSVIaj4i9uwbmtsIgutOJaXva6ybHEcK87K)oiqY7CItBzerj7A2(WfB1YX4vMN1JUulc7fbKf5FrpC1s74PL)fHnGfrXIaA8Dra9frXIuJSZzZ4N5uzuAJxVRzRERYfH1fbKfr5IOKafYSVIaP0gVExZw9wLKKObqi0rGcz2xrGcWtVRi7RSUwhKaXva6ybHEss0Whe6iqCfGowqONaj)o5VdcK6GDGDjmJWQe2Xw(HhZ(kdxbOJflAWGfPoyhyxcdgNlY2Xw15WGR0Wva6yXI8ViSSiqyCCdgNlY2Xw15WGR06bRh11cd8ibQRK)hEmTnobsDWoWUegmoxKTJTQZHbxjbQRK)hEmTTUol6izceveOqM9veiChR8KFGNeOUs(F4X0o7oWWrGOIKenMKqhbIRa0Xcc9ei53j)DqGE4IxeMlcilY)IE4QL2Xtl)lcZfrLV(sGcz2xrGuEHCQJTPhBHlT3NEdtsssGgFwE6GrsOJObve6iqCfGowqONajyL87XSVIarJtZSeozXIaz875fjpDWixeip3LYSOjQuYJPAr1vaDV41XHDlkKzFLArx5g2qGcz2xrGWDSYt(bEssssG07SNJSVIqhrdQi0rG4kaDSGqpbs(DYFheipoCPNzuMlcZfnPVlAWGfrXIWYIM)dECr(xKhhU0ZmkZfH5IObAyrusGcz2xrGWi0h7VLwq3Dcss0GAcDeiUcqhli0tGcz2xrGeCKEwv(9uMajyL87XSVIanrk5P318IeHEmZl6zAe4(zDUYf1Qfr9KtWl6WxKEqZlYJdx6Ti15oAx0K(obVOdFr6bnVipoCP3I6ArXIM)dE0qGKFN83bbQl5P31Sve6XmBbIArydyrEC4spJe(FUsss0aie6iqCfGowqONafYSVIaj4i9SQ87PmbsWk53JzFfbAcDfqLlYX5IIArmn3QSR5frV7oXIG8A2jwK4Vrdbs(DYFheivGbBbD3jSkVMDIf5FrDjp9UMTIqpMz7KQfH9I8Dr(xeimoUb0DNWQ8A2jmWJlY)IaHXXnGU7ewLxZoH5z9Ol1IWCruzMCryDrZsbjjA4dcDeiUcqhli0tGKFN83bbkJAAxZlY)IaHXXnpCX2mgnItBTi)lQl5P31Sve6XmBbIAryVipoCPNrpO5fH1f5RHkcuiZ(kc0dxSnJrss0yscDeiUcqhli0tGKFN83bbYJdx6zgL5IWCrt67Ia6lIIfrTVlcRlcegh3a6UtyvEn7eg4XfrjbkKzFfbQLm4bxcl(9zNWcMKenObcDeiUcqhli0tGKFN83bbYJdx6zgL5IWCr00KlY)Ig50m7DWoZZ6rxQfH5IMKafYSVIaPc534TSdNDmKjjjjbsLrjIxqOJObve6iqCfGowqONaj)o5Vdc0dxT0oEA53iy8w25IWeWIOY3f5FruSiSSOmCCLgWRyvEVUHRa0XIfnyWIWYIK35eN2YaEfRY71nphIHx0Gblcegh3iIs21S9Hl2QLJXRmWJlIscuiZ(kcKGJ0ZQYVNYKKOb1e6iqCfGowqONaj)o5Vdc0iNMzVd2zEwp6sTimx0SuSiSUiQjqHm7RiqQq(nEl7WzhdzssIgaHqhbIRa0Xcc9ei53j)DqGaHXXnGxXwLxZoH5z9Ol1IWCrazryDrZsHHPzwcN8IgmyruSiqyCCd4vSv51StyEwp6sTimbSOhUyt26Snplqw0Gblcegh3aEfBvEn7eMN1JUulctalIIfnlflsZfjVZjoTLb0DNq8DnLFZZHy4fH1fLHJR0a6Uti(UMYVHRa0XIfH1fr9IOCrdgSiqyCCd4vSv51StyuziNUimx0KlIYf5FrpC1s74PLFJGXBzNlcBalIAFjqHm7Riq6X)N2NlbjjA4dcDeiUcqhli0tGKFN83bbsEyWvuPP6zV0Ih8I8VibhPNnkHvWYyyt2YPDnVi)lIIfbcJJBeCKEkRaMnWJlY)IaHXXncospLvaZMN1JUulcZfrdlIscuiZ(kcKhhFAv53tzss0yscDeiUcqhli0tGKFN83bbsEyWvuPP6zV0Ih8I8VibhPNnkHvWYyyt2YPDnVi)lIIfbcJJBeCKEkRaMnWJlY)IaHXXncospLvaZMN1JUulcZfrdlIscuiZ(kcKhhFAv53tzss0Ggi0rG4kaDSGqpbs(DYFheiqyCCd4vSv51StyuziNUiSx0KlY)IE4Ixe2awe1lY)IE4QL2Xtl)gbJ3Yoxe2aweq8Dr(xewweflsEyWvuPbdUsVH)f5FrY7CItBzuAJxVRzRERsZZ6rxQfH5IaYIOKafYSVIaLNoOkVIjjrdAIqhbIRa0Xcc9ei53j)DqGOyrGW44gWRyRYRzNW8SE0LArycyrpCXMS1zBEwGSObdweimoUb8k2Q8A2jmpRhDPweMaweflAwkwKMlsENtCAldO7oH47Ak)MNdXWlcRlkdhxPb0DNq8DnLFdxbOJflcRlYhlIYfnyWIaHXXnGxXwLxZoHrLHC6IWCr0WIgmyruSikwewwK8WGROst1ZEPfp4fnyWIaHXXncospLvaZMN1JUulc7fn5IOCr(xeimoUb8k2Q8A2jmpRhDPweMlIMweLlIYf5FrpC1s74PLFJGXBzNlc7frTVlY)IWYIOyrpCX43pZg536QRSpCXwTCmELHRa0XIf5FrY7CItBzerj7A2(WfB1YX4vMN1JUulcZfbcJJBaVITkVMDcZZ6rxQfrjbkKzFfbsp()0(CjijrdFcHocexbOJfe6jqYVt(7Ga9WvlTJNw(ncgVLDUimbSimIVdqhBeCKEwv(9u2kG1hTH(bx5I8ViSSikwugoUsd4vSkVx3Wva6yXI8Vi5DoXPTmGxXQ8EDZZ6rxQfH5IOEruUi)lcllIIfjpm4kQ0GbxP3W)I8Vi5DoXPTmkTXR31SvVvP5z9Ol1IWCrazrusGcz2xrGeCKEwv(9uMKenaAi0rG4kaDSGqpbs(DYFheiPx8ZSYI)Hm7Rc3IWgWIOY4twK)frXIaHXXnES(PYq1kJkd50fHjGfrXIMCra9fPgzNZMXpZPYa6UtybV2Tikx0GblsnYoNnJFMtLb0DNWcETBryViQxeLeOqM9veiq3Dcl41oss0GkFj0rG4kaDSGqpbkKzFfbsp(P2d3c6UtqGeSs(9y2xrGMaJF6Io8frV7oXIehRwuD5IgJsW6TeOZ0CYLWqGKFN83bbsWGW44g94NApClO7oHrCARf5Fr49SxAFwp6sTiSxenzMKKenOIkcDeiUcqhli0tGKFN83bbcegh3i)wxDLvjp4FMnWJlY)IYWXvAE21kpBxwq3DcdxbOJflY)IE4QL2Xtl)gbJ3Yoxe2lIkFjqHm7RiqcospBucRGLXWKKObvutOJaXva6ybHEcK87K)oiqpC1s74PL)fHnGfrLV(Ui)lcllIIfjpm4kQ0GbxP3W)I8Vi5DoXPTmkTXR31SvVvP5z9Ol1IWCrazrusGcz2xrGaVIv596KKObvaHqhbIRa0Xcc9eOBKaP4SXjqHm7RiqyeFhGoMaHr82k0zcKhhFAv53tz7psGKFN83bbsEyWvuPP6zV0Ih8I8VibhPNnkHvWYyyt2YPDntGWiCWSLDkMarXIOAYfP5IuJSZzZ4N5uz844tRk)EkViSUOmCCLgpo(e85yk)gUcqhlwewxe1lIYfH1frLHAcegHdMjquSiQMCrAUi1i7C2m(zovgpo(0QYVNYlcRlkdhxPXJJpbFoMYVHRa0XIfH1fr9IOKKenOYhe6iqCfGowqONaj)o5Vdcefl6HRwAhpT8BemEl7CrycyryeFhGo24XXNwv(9u2(JlIYfnyWIY4N50KToBZZkAEryUiQ8LafYSVIaj4i9SQ87PmjjAq1Ke6iqCfGowqONaj)o5VdcKAKDoBg)mNkJGJ0ZgLWkyzm8IWgWIacbkKzFfbsWr6zJsyfSmgMKenOIgi0rG4kaDSGqpbs(DYFheOhUyt26SnpRpweMlAwkiqHm7RiqEC8PvLFpLjjrdQOjcDeiUcqhli0tGKFN83bbcegh3i)wxDLvjp4FMnWJlAWGfLHJR08XylScwE6JNQZ(kdxbOJfeOqM9veibhPNnkHvWYyyss0GkFcHocexbOJfe6jqYVt(7GabcJJBaVITkVMDcZZ6rxQfH9IaYIW6IMLccuiZ(kcK8kfS(y2xrsIgub0qOJaXva6ybHEcK87K)oiqsV4NzLf)dz2xfUfHnGfrLHQf5FrGW44gWRyRYRzNW8SE0LAryViGSiSUOzPGafYSVIab6UtybV2rsIgu7lHocexbOJfe6jqYVt(7Ga9WfViSxevlY)IOyrpCXMS1zBEwGSimx0SuSObdweimoUb8k2Q8A2jmQmKtxe2lIMwK)fbcJJBaVITkVMDcZZ6rxQfH9IE4InzRZ28SazrAUOzPyrusGcz2xrG844tRk)EktsIgutfHocexbOJfe6jqYVt(7Ga9WvlTJNw(ncgVLDUiSxe1(sGcz2xrGIxgfBZ7FUssssc0hYoCkcDenOIqhbIRa0Xcc9ei53j)DqGK35eN2YiIs21S9Hl2QLJXRmphIHxK)frXIWYIK35eN2Ya6Uti(UMYV55qm8Igmyryzrz44knGU7eIVRP8B4kaDSyrusGcz2xrGaD3jS4W)WKKOb1e6iqHm7RiqG8R4FAxZeiUcqhli0tsIgaHqhbIRa0Xcc9ei53j)DqGcz2yWwUy9MvlcBalI6fnyWIE4IxeMlIQf5FrpC1s74PLFJGXBzNlc7frd(sGcz2xrGIxgfBhHDkMKen8bHocexbOJfe6jqYVt(7GabcJJBGlVZnSvLpxZPNbEKafYSVIa56zVuzNaalM15kjjrJjj0rGcz2xrGIsYQ8dNvgohbIRa0Xcc9KKObnqOJafYSVIaH3pd6UtqG4kaDSGqpjjAqte6iqHm7RiqGXS9WT53YPkcexbOJfe6jjrdFcHocexbOJfe6jqYVt(7Ga9WvlTJNw(ncgVLDUiSxe1(sGcz2xrGIxgfBZ7FUsssscKGXdyxsOJObve6iqCfGowqONajyL87XSVIarJtZSeozXIym4F4fLToVO0JxuiZ7xuRwuGr0Ua0XgcuiZ(kcKExcl(Z8eetsIgutOJaXva6ybHEc0nsGuC24eOqM9veimIVdqhtGWiEBf6mbsWr6zv53tzRawF0g6hCLei53j)DqGWYIKhgCfvAQE2lT4btGWiCWSLDkMan5KeimchmtGOjFjjrdGqOJaXva6ybHEcK87K)oiqzut7AErdgSOUKNExZwrOhZSDs1IWEr(sGu53YKObveOqM9veiz4C2qM9vwxRscKRvPTcDMaP3zphzFfjjA4dcDeiUcqhli0tGKFN83bbcegh3iIs21S9Hl2QLJXRmWJeibRKFpM9veiOUK8IspErJx2xTi5DoXPTwKxOwK0lQzwq7I0YaLZTi1WLCrA70BrtOj2eNafYSVIanEzFfjjAmjHocuiZ(kceSITDY6kcexbOJfe6jjrdAGqhbIRa0Xcc9eOk0zc0CGb7ShUn9ylE)Q0gpyN8tGcz2xrGMdmyN9WTPhBX7xL24b7KFss0GMi0rGcz2xrG(OvSvWHGaXva6ybHEss0WNqOJaXva6ybHEcK87K)oiqyzrGW44gruYUMTpCXwTCmELbECr(xeflcllsEyWvuPP6zV0Ih8IgmyrGW44gbhPNYkGzZZ6rxQfH9IOPfrjbkKzFfbc0DNq8DnLFss0aOHqhbIRa0Xcc9eOqM9veiz4C2qM9vwxRscKRvPTcDMa9HSdNIKenOYxcDeiUcqhli0tGcz2xrGuH8B8w2HZogYKajyL87XSVIanrZK1hZfL3IuH8B8wYlk94fn7DWUf14lslVOXNfTmdq3WlsB7ClQUCrIBr6WsVf11IspErfh)IWHt4NjqYVt(7GarXIWYIKhgCfvAQE2lT4bVObdweimoUrWr6PScy28SE0LAryViAyruUi)lcegh3iIs21S9Hl2QLJXRmpRhDPwe2lYhlY)IOyrJCAM9oyN5z9Ol1IWCruVObdwug)mNMS1zBEwrZlcZfnlflIsss0GkQi0rG4kaDSGqpbkKzFfbsgoNnKzFL11QKa5AvARqNjqYddUIkvKKObvutOJaXva6ybHEcK87K)oiquSOhU4fHjGfr9I8VOhUyt26SnpRpwe2lAwkwK)fj9IFMvw8pKzFv4we2awevgFYIOCrdgSOhUyt26Snplqwe2lAwkiqHm7RiqGU7e2mgjjrdQacHocexbOJfe6jqYVt(7GaHLfbcJJBerj7A2(WfB1YX4vg4rcuiZ(kcKikzxZ2hUyRwogVIKenOYhe6iqCfGowqONaj)o5VdceimoUreLSRz7dxSvlhJxzGhjqHm7RiqpCzdz2xzDTkjqUwL2k0zcK41AHhjjrdQMKqhbIRa0Xcc9eOqM9veiz4C2qM9vwxRscKRvPTcDMaPYOeXlijjjjbcd(v9venO2xQP2xFqfnqG0gF11SIanXNOtmnMiAqJYNUOfrNhVOwF8(Cr43ViGs8ATWJa1IEMgbUFwSi1PZlkGZtpswSiPxuZSYSatJ1fViQ8PlAcFfg8NSyra1dxm(9ZSbOfOwuElcOE4IXVFMnaTgUcqhlaQff5IOXPrNgBruqfntPzbMgRlEr0GpDrt47FwMSyrmncC46C4fj9y50fH)N(IakaaaQfL3Iakaa1IOGkAMsZc8c8eFIoX0yIObnkF6IweDE8IA9X7ZfHF)IakvgLiEbqTONPrG7NflsD68Ic480JKfls6f1mRmlW0yDXlIM8PlAcFfg8NSyra1dxm(9ZSbOfOwuElcOE4IXVFMnaTgUcqhlaQfrbv0mLMf4f4j(eDIPXerdAu(0fTi684f16J3Nlc)(fbuYddUIkva1IEMgbUFwSi1PZlkGZtpswSiPxuZSYSatJ1fViF4tx0e(km4pzXIak1b7a7syaAbQfL3Iak1b7a7syaAnCfGowaulIcQPzknlWlWte9X7twSiAArHm7RwKRvPYSatGc407EceuRpHxKMlIgnEA7Ac04F4TJjq(SpVi6D3jw0eIJ0BrtaRE2lxG9zFErtGXWlIkFq7IO2xQPEbEb2N95fnH9IAMv(0fyF2NxeqFrqWJJ3Nlc)(frV7oXIO)A3I6ArtOj2eFrkoZUMnlWlW(8IOXPzwcNSyrGm(98IKNoyKlcKN7szw0evk5XuTO6kGUx864WUffYSVsTORCdBwGdz2xPmJplpDWi1eWq4ow5j)apxGxG95frJtZSeozXIym4F4fLToVO0JxuiZ7xuRwuGr0Ua0XMf4qM9vka6DjS4pZtq8cCiZ(kLMagcJ47a0X0wHodqWr6zv53tzRawF0g6hCL0EJauC240kVs0zFfaSipm4kQ0u9SxAXdMwmchmdGM8LwmchmBzNIbm5KlWHm7RuAcyiz4C2qM9vwxRsARqNbO3zphzFfTQ8BzcGkABCazut7AEWGUKNExZwrOhZSDsf2(Ua7ZlcQljVO0Jx04L9vlsENtCARf5fQfj9IAMf0UiTmq5ClsnCjxK2o9w0eAInXxGdz2xP0eWqJx2xrBJdaegh3iIs21S9Hl2QLJXRmWJlWHm7RuAcyiyfB7K1vlWHm7RuAcyiyfB7K1PTcDgWCGb7ShUn9ylE)Q0gpyN8VahYSVsPjGH(OvSvWHyboKzFLstadb6Uti(UMYpTnoaSacJJBerj7A2(WfB1YX4vg4r)uGf5HbxrLMQN9slEWdgacJJBeCKEkRaMnpRhDPWMMOCboKzFLstadjdNZgYSVY6AvsBf6mGpKD4ulW(8IMOzY6J5IYBrQq(nEl5fLE8IM9oy3IA8fPLx04ZIwMbOB4fPTDUfvxUiXTiDyP3I6ArPhVOIJFr4Wj8ZlWHm7RuAcyivi)gVLD4SJHmPTXbqbwKhgCfvAQE2lT4bpyaimoUrWr6PScy28SE0LcBAGs)GW44gruYUMTpCXwTCmEL5z9Olf2(WpfJCAM9oyN5z9OlfMupyqg)mNMS1zBEwrZyolfuUahYSVsPjGHKHZzdz2xzDTkPTcDgG8WGROs1cCiZ(kLMagc0DNWMXiTnoakE4IXea1(F4InzRZ28S(a7zPWV0l(zwzX)qM9vHdBauz8juoyWdxSjBD2MNfiyplflWHm7RuAcyiruYUMTpCXwTCmEfTnoaSacJJBerj7A2(WfB1YX4vg4Xf4qM9vknbm0dx2qM9vwxRsARqNbiETw4rABCaGW44gruYUMTpCXwTCmELbECboKzFLstadjdNZgYSVY6AvsBf6mavgLiEXc8cCiZ(kLrEyWvuPcGGJ0tzfWmTnoaSacJJBeCKEkRaMnWJdgacJJBeCKEkRaMnpRhDPW0hdgacJJBKFRRUYQKh8pZg4Xf4qM9vkJ8WGROsLMagsPnE9UMT6TkPTXbiVZjoTLreLSRz7dxSvlhJxzEwp6sHnq8)WvlTJNw(Xgafan(c0PqnYoNnJFMtLrPnE9UMT6TkXkqOKYf4qM9vkJ8WGROsLMagkap9UISVY6ADWf4qM9vkJ8WGROsLMagc3Xkp5h4jTnoa1b7a7sygHvjSJT8dpM9vdgOoyhyxcdgNlY2Xw15WGR0pwaHXXnyCUiBhBvNddUsRhSEuxlmWJ02vY)dpM2wxNfDKmaQOTRK)hEmTZUdmCaOI2Us(F4X024auhSdSlHbJZfz7yR6CyWvUahYSVszKhgCfvQ0eWqkVqo1X20JTWL27tVHPTXb8WfJjq8)WvlTJNw(XKkF9DbEboKzFLYiETw4ra5PdQYRyABCaGW44gWRyRYRzNWOYqof7j9)WfJnaQ9)WvlTJNw(ncgVLDInaG4R)hUy87NzJ8BD1v2hUyRwogVAboKzFLYiETw4rnbmKE8)P95sqBJdGcqyCCd4vSv51StyEwp6sHjGhUyt26Snplqgmaegh3aEfBvEn7eMN1JUuycGIzPqt5DoXPTmGU7eIVRP8BEoedJ1mCCLgq3DcX31u(nCfGowGvFq5GbuacJJBaVITkVMDcJkd5umP2pfyrEyWvuPPy5FU7fdgacJJBcWtVRi7RSUwh0apsjLu6)HRwAhpT8BemEl7eBQ9DboKzFLYiETw4rnbmeO7oHf8AhTnoakOq6f)mRWga1(F4IXeavuoyG4sdO7oHD0fZWS5z9OlfMaOMYbdOqnYoNnJFMtLb0DNWcETd7j9l9IFMvw8pKzFv4WgavgQO0pwOqEyWvuPbdUsVHF)GW44gL2417A2Q3Q0aps5cCiZ(kLr8ATWJAcyimIVdqhtBf6mapo(0QYVNY2F0kET0Ir4Gzauq9KAQgzNZMXpZPY4XXNwv(9ugRz44knEC8j4ZXu(nCfGowGvQPCboKzFLYiETw4rnbmKGJ0ZQYVNY066ITsbaFGvVqLmTnoaqyCCdO7oHv51StyEwp6sH5SumyWdxT0oEA53iy8w2jMaWi(oaDSXJJpTQ87PS9hTIxRFSqrgoUsd4vSkVx3Wva6yHF5DoXPTmGxXQ8EDZZ6rxkmPMYf4qM9vkJ41AHh1eWqcospBucRGLXW024aOqnYoNnJFMtLrWr6zJsyfSmggaaG4hegh3i)wxDLvjp4FMnWJuoyGAKDoBg)mNkJGJ0ZgLWkyzmm2a8XcCiZ(kLr8ATWJAcyiWRyvEVoTnoGhUAPD80Yp2aOYxF9dcJJB4s4yLY(WfB1gUCcYOYqofBF4hluipm4kQ0GbxP3WVF5DoXPTmkTXR31SvVvP5z9OlfMaHYf4qM9vkJ41AHh1eWqGU7ewWRD066ITsbaFGvVqLmTnoafNzxZkdO7oHf8ANv8A9RgzNZMXpZPYa6UtybV2Hn1lWHm7RugXR1cpQjGH844tRk)EktBJd4Hl2KToBZZsnMZsXcCiZ(kLr8ATWJAcyibhPNvLFpLPTXb8WvlTJNw(ncgVLDIjamIVdqhB844tRk)EkB)rR416hluKHJR0aEfRY71nCfGow4xENtCAld4vSkVx38SE0LctQPCboKzFLYiETw4rnbmK8kfS(y2xTaVahYSVsz07SNJSVcagH(y)T0c6UtqBJdWJdx6zgLjMt67GbuGL5)Gh97XHl9mJYetAGgOCb2Nx0ePKNExZlse6XmVONPrG7N15kxuRwe1tobVOdFr6bnVipoCP3IuN7ODrt67e8Io8fPh08I84WLElQRfflA(p4rZcCiZ(kLrVZEoY(knbmKGJ0ZQYVNY024a6sE6DnBfHEmZwGOWgGhhU0ZiH)NRCb2Nx0e6kGkxKJZff1IyAUvzxZlIE3DIfb51StSiXFJMf4qM9vkJEN9CK9vAcyibhPNvLFpLPTXbOcmylO7oHv51St4Vl5P31Sve6XmBNuHTV(bHXXnGU7ewLxZoHbE0pimoUb0DNWQ8A2jmpRhDPWKkZKyDwkwGdz2xPm6D2Zr2xPjGHE4ITzmsBJdiJAAxZ(bHXXnpCX2mgnItB5Vl5P31Sve6XmBbIcBpoCPNrpOzS6RHQf4qM9vkJEN9CK9vAcyOwYGhCjS43NDclyABCaEC4spZOmXCsFb6uqTVyfegh3a6UtyvEn7eg4rkxGdz2xPm6D2Zr2xPjGHuH8B8w2HZogYK2ghGhhU0ZmktmPPj9pYPz27GDMN1JUuyo5c8cCiZ(kL5dzhofaq3Dclo8pmTnoa5DoXPTmIOKDnBF4ITA5y8kZZHyy)uGf5DoXPTmGU7eIVRP8BEoedpyawYWXvAaD3jeFxt53Wva6ybLlWHm7RuMpKD4uAcyiq(v8pTR5f4qM9vkZhYoCknbmu8YOy7iStX024acz2yWwUy9MvydG6bdE4IXKk)pC1s74PLFJGXBzNytd(UahYSVsz(q2HtPjGHC9SxQStaGfZ6CL024aaHXXnWL35g2QYNR50ZapUahYSVsz(q2HtPjGHIsYQ8dNvgo3cCiZ(kL5dzhoLMagcVFg0DNyboKzFLY8HSdNstadbgZ2d3MFlNQwGdz2xPmFi7WP0eWqXlJIT59pxjTnoGhUAPD80YVrW4TStSP23f4f4qM9vkJkJseVaGGJ0ZQYVNY024aE4QL2Xtl)gbJ3YoXeav(6NcSKHJR0aEfRY71nCfGowmyawK35eN2YaEfRY71nphIHhmaegh3iIs21S9Hl2QLJXRmWJuUahYSVszuzuI4fAcyivi)gVLD4SJHmPTXbmYPz27GDMN1JUuyolfyL6fyF2NxuiZ(kLrLrjIxOjGHaD3jeFxt5N2ghawaHXXnIOKDnBF4ITA5y8kd84cCiZ(kLrLrjIxOjGH0J)pTpxcABCaGW44gWRyRYRzNW8SE0LctGG1zPWW0mlHtEWakaHXXnGxXwLxZoH5z9OlfMaE4InzRZ28SazWaqyCCd4vSv51StyEwp6sHjakMLcnL35eN2Ya6Uti(UMYV55qmmwZWXvAaD3jeFxt53Wva6ybwPMYbdaHXXnGxXwLxZoHrLHCkMtsP)hUAPD80YVrW4TStSbqTVlWHm7RugvgLiEHMagYJJpTQ87PmTnoa5HbxrLMQN9slEW(fCKE2OewblJHnzlN21SFkaHXXncospLvaZg4r)GW44gbhPNYkGzZZ6rxkmPbkxGdz2xPmQmkr8caEC8PvLFpLPTXbipm4kQ0u9SxAXd2VGJ0ZgLWkyzmSjB50UM9tbimoUrWr6PScy2ap6hegh3i4i9uwbmBEwp6sHjnq5cCiZ(kLrLrjIxOjGHYthuLxX024aaHXXnGxXwLxZoHrLHCk2t6)HlgBau7)HRwAhpT8BemEl7eBaaXx)yHc5HbxrLgm4k9g(9lVZjoTLrPnE9UMT6TknpRhDPWeiuUahYSVszuzuI4fAcyi94)t7ZLG2ghafGW44gWRyRYRzNW8SE0LctapCXMS1zBEwGmyaimoUb8k2Q8A2jmpRhDPWeafZsHMY7CItBzaD3jeFxt538CiggRz44knGU7eIVRP8B4kaDSaR(GYbdaHXXnGxXwLxZoHrLHCkM0WGbuqbwKhgCfvAQE2lT4bpyaimoUrWr6PScy28SE0Lc7jP0pimoUb8k2Q8A2jmpRhDPWKMOKs)pC1s74PLFJGXBzNytTV(XcfpCX43pZg536QRSpCXwTCmELF5DoXPTmIOKDnBF4ITA5y8kZZ6rxkmbHXXnGxXwLxZoH5z9OlfLlWHm7RugvgLiEHMagsWr6zv53tzABCapC1s74PLFJGXBzNycaJ47a0XgbhPNvLFpLTcy9rBOFWv6hluKHJR0aEfRY71nCfGow4xENtCAld4vSkVx38SE0LctQP0pwOqEyWvuPbdUsVHF)Y7CItBzuAJxVRzRERsZZ6rxkmbcLlWHm7RugvgLiEHMagc0DNWcETJ2ghG0l(zwzX)qM9vHdBauz8j(Paegh34X6NkdvRmQmKtXeaftc0vJSZzZ4N5uzaD3jSGx7OCWa1i7C2m(zovgq3Dcl41oSPMYfyFErtGXpDrh(IO3DNyrIJvlQUCrJrjy9wc0zAo5sywGdz2xPmQmkr8cnbmKE8tThUf0DNG2ghGGbHXXn6Xp1E4wq3DcJ40w(X7zV0(SE0LcBAYm5cCiZ(kLrLrjIxOjGHeCKE2OewblJHPTXbacJJBKFRRUYQKh8pZg4r)z44knp7ALNTllO7oHHRa0Xc)pC1s74PLFJGXBzNytLVlWHm7RugvgLiEHMagc8kwL3RtBJd4HRwAhpT8JnaQ81x)yHc5HbxrLgm4k9g(9lVZjoTLrPnE9UMT6TknpRhDPWeiuUahYSVszuzuI4fAcyimIVdqhtBf6mapo(0QYVNY2FKwmchmdGcQMut1i7C2m(zovgpo(0QYVNYyndhxPXJJpbFoMYVHRa0XcSsnL0EJauC240kVs0zFfa5HbxrLMQN9slEW(fCKE2OewblJHnzlN21mTyeoy2YofdGcQMut1i7C2m(zovgpo(0QYVNYyndhxPXJJpbFoMYVHRa0XcSsnLyLkd1lWHm7RugvgLiEHMagsWr6zv53tzABCau8WvlTJNw(ncgVLDIjamIVdqhB844tRk)EkB)rkhmiJFMtt26SnpROzmPY3f4qM9vkJkJseVqtadj4i9SrjScwgdtBJdqnYoNnJFMtLrWr6zJsyfSmggBaazboKzFLYOYOeXl0eWqEC8PvLFpLPTXb8WfBYwNT5z9bMZsXcCiZ(kLrLrjIxOjGHeCKE2OewblJHPTXbacJJBKFRRUYQKh8pZg4XbdYWXvA(ySfwblp9Xt1zFLHRa0XIf4qM9vkJkJseVqtadjVsbRpM9v024aaHXXnGxXwLxZoH5z9Olf2abRZsXcCiZ(kLrLrjIxOjGHaD3jSGx7OTXbi9IFMvw8pKzFv4WgavgQ8dcJJBaVITkVMDcZZ6rxkSbcwNLIf4qM9vkJkJseVqtad5XXNwv(9uM2ghWdxm2u5NIhUyt26SnplqWCwkgmaegh3aEfBvEn7egvgYPytt(bHXXnGxXwLxZoH5z9Olf2pCXMS1zBEwGO5Suq5cCiZ(kLrLrjIxOjGHIxgfBZ7FUsABCapC1s74PLFJGXBzNytTVKKKeca]] )

end