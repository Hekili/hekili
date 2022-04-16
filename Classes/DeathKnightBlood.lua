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
                    buff.dancing_rune_weapon.expires = buff.dancing_rune_weapon.expires + ( set_bonus.tier28_4pc > 0 and 1 or 0.5 )
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


    spec:RegisterPack( "Blood", 20220415, [[dWKjcbqicfpcskxIQsuBsf5tuvsJIQItrHAvkuEfb1SiGBbjj7Ik)sHyyuihJGSmc0ZuinnQk11uOABqs8ncLACekX5uHKwNkezEqQUNISpiXbvHGfsi9qviQjsOKUiKKYhPQeyKqsQ4KQqQwPkQxsvjuZufc1nPQeYoju9tijvAPQqkpfKPsi(QkKySQqi7fXFj1GH6WclwLEmrtgPlJAZq8zf1OPOtlA1qsQ61QGztPBtv2Tu)wPHRGJtvjYYv1Zjz6sUoO2oKY3PGXdjvNxfQ1tvjO5tv1(bMierecenkMiUGgjOGg5BHqfNrgzKq(EucuD8atGgc5HyMjqD4XeirT7sjqdXX2nOeriqQf(Lmbck9GTrLBFK)aPiqx40wh9MCjq0OyI4cAKGcAKVfACNGJoUVhvqcKAGLeXfCCJiqMjLYn5sGOSssGe1UlfGfRCuMaSV4oNnlW5JWWNwawOXfaGf0ibfeCgC(iBg9mRosGZOkagcEyy)cGr2hGf1UlfGfDtlaNnalwpAhfawXvL9SJaztvPiIqGOVbn8areI4creHaXDCTmLikbs(zXFgeOlmcI7UnRvMjBPovfYdamkta84a8ja(HBgGrzcGfeGpbWpCNs9WAGFhLrszwamkta8OgbWNa4hUzK9NzN8tp126hUzTbog22XDCTmLafYk3MavR3vvBZKIiUGeriqChxltjIsGKFw8NbbYha(cJG4UBZALzYwQ7zViBfaJ(ea)Wn7Q0J11QhfG97hGVWiiU72SwzMSL6E2lYwbWOpbW(aWZskalmal31sxdT7A3Ls)SpWV75GEmapgaxHL7YDT7sPF2h43XDCTmfGhdG9naBma73pa7daFHrqC3TzTYmzl1PQqEaGrhGfeGpbW(aWIbGLlAChD5Aw(RDFka73paFHrqCXD9YoQCBTn9Uo4ba2ya2ya2ya(ea)WDk1dRb(DugjLzbWOaWcAebkKvUnbYl(Fn8Ctjfr8rjIqG4oUwMseLaj)S4pdcK0m(zwbWOmbWccWNa4hUzag9jawiawyawXvL9SYDT7s13nTA6BGafYk3MaDT7s13nTKIiUVjIqG4oUwMseLaTdeifxeOqw52ei0IpJRLjqOfwyMa5dal04aSWa8fgbXrJwM9S(HBwBGJHTDWda8yaSqgbWcdWQb2A1v8ZCPCMC8LwvFEGb4Xa4kSCxoto(6(CCGFh3X1YuaEmawqa2yceAXR7WJjqMC8LwvFEG1)GM(gifr8XjIqG4oUwMseLafYk3Mar5Om1Q6Zdmbs(zXFgeOhUtPEynWVJYiPmlag9jagT4Z4AzNjhFPv1Nhy9pOPVba(ealga2haUcl3L7UnRQ99CChxltb4taSCxlDn0U72SQ23Z9SxKTcGrhGfeGnMazZM1skbY3JzgQIhtXvL9SYDT7s13nTA6BGueXrfIieiUJRLPerjqYpl(ZGa9WDk1dRb(byuMayHmYicuiRCBc0DBwv77rkI4Inrece3X1YuIOeOqw52eORDxQ(UPLaj)S4pdcKAGTwDf)mxk31UlvF30cWOaWcsGSzZAjLa57XmdvXKIiUyHicbI74AzkrucK8ZI)miqpCZUk9yDTAbby0b4zjfG97hGfdaR4QYEw5U2DP67Mwn9naWNa4hUtPEynWVJYiPmlagLjagT4Z4AzNjhFPv1Nhy9pOPVbcuiRCBcKjhFPv1Nhysre)OseHaXDCTmLikbs(zXFgei1aBT6k(zUuokhLPoAQMYY4yagLjaEucuiRCBceLJYuhnvtzzCmPifbsUOXD0LIicrCHiIqG4oUwMseLaj)S4pdcKya4lmcIJYrzQ0uy2bpaW(9dWxyeehLJYuPPWS7zViBfaJoa7Ba2VFa(cJG4KF6P2wRKl8pZo4bcuiRCBceLJYuPPWmPiIlirece3X1YuIOei5Nf)zqGK7APRH2rJwM9S(HBwBGJHTDp7fzRayua4rb4ta8d3PupSg4hGrzcG9bGpQgbWOka2hawnWwRUIFMlLtziEVSN1EPQa4Xa4rbyJbyJjqHSYTjqkdX7L9S2lvfPiIpkrece3X1YuIOei5Nf)zqGedaFHrqC0OLzpRF4M1g4yyBh8abkKvUnbkURx2rLBRTP3LueX9nrece3X1YuIOei5Nf)zqGulS9Mn1naRkylR5hEOYTDChxltby)(by1cBVztDOT2OslRvRfnUlh3X1Yua(ealga(cJG4qBTrLwwRwlACxAtyVO3K6Ghiqzx8)WdLoriqQf2EZM6qBTrLwwRwlACxeOSl(F4HsNEEmnJIjqcrGczLBtGqSSYu(bsrGYU4)Hhk9SDVHLajePiIporece3X1YuIOei5Nf)zqGE4Mby0b4rb4ta8d3PupSg4hGrhGfYiJiqHSYTjqkZqEWY6YK1WTH9lZJjfPiqdplxVBueriIlerece3X1YuIOeikRKFou52eiunuNLWftb4lJSpdWY17gfaF55Svoa(iiL8qPa4EBuLz8EiWwaoKvUTcG32ESJafYk3MaHyzLP8dKIuKIa5LvohvUnreI4creHaXDCTmLikbs(zXFgeitoSLPBqwam6a84gbW(9dW(aWIbGN)fEaGpbWMCylt3GSay0byubvayJjqHSYTjqOfEd5Ns91UlLueXfKicbI74AzkrucuiRCBceLJYuRQppWeikRKFou52eOJElxVSNbyA4fZma)SVeC(Sh3faNkawWX9Lb4fbG9cuhGn5WwMaSATRaa84g5ldWlca7fOoaBYHTmb4Sb4aGN)fEWrGKFw8NbbkB56L9SMgEXmRhvbWOmbWMCyltNe(FUlsreFuIieiUJRLPerjqHSYTjquoktTQ(8atGOSs(5qLBtGeRB7RfaB5cGJgGzupvv2ZaSO2DPamKzYwkat)DWrGKFw8NbbsfOX6RDxQwzMSLcWNa4SLRx2ZAA4fZSECfaJcaBeaFcGVWiiURDxQwzMSL6Gha4ta8fgbXDT7s1kZKTu3ZEr2kagDawi34a8ya8SKskI4(MicbI74AzkrucK8ZI)miqv0hYEgGpbWxyee3d3SUIbhDn0a8jaoB56L9SMgEXmRhvbWOaWMCyltNxG6a8yaSroHiqHSYTjqpCZ6kgifr8XjIqG4oUwMseLaj)S4pdcKjh2Y0nilagDaECJayufa7dalOra8ya8fgbXDT7s1kZKTuh8aaBmbkKvUnbkL8DHBQgz)klyktkI4Ocrece3X1YuIOei5Nf)zqGm5WwMUbzbWOdWI94a8jaEGl3S5cBDp7fzRay0b4XjqHSYTjqQq(jskZWQhczrksrGOmsaBlIieXfIicbI74AzkruceLvYphQCBceQgQZs4IPamJg)hdWv6XaCzYaCiR9b4ubWbArAJRLDeOqw52eiVSPAKNzFHmPiIlirece3X1YuIOeODGaP4kriqHSYTjqOfFgxltGqlEDhEmbIYrzQv1Nhynf2BqhElCxei5Nf)zqGKlAChD56C2S0ibdWNa4lmcIJYrzQ0uy29SxKTcGrbGrfceAHfM1SvXeOXhNaHwyHzcKyBePiIpkrece3X1YuIOei5Nf)zqGUWiiU72SwzMSL6E2lYwbWOdWJcWJbWZsQJrDwcxma73pa7daFHrqC3TzTYmzl19SxKTcGrFcGF4MDv6X6A1JcW(9dWxyee3DBwRmt2sDp7fzRay0NayFa4zjfGfgGL7APRH2DT7sPF2h439CqpgGhdGRWYD5U2DP0p7d874oUwMcWJbWccWgdW(9dWxyee3DBwRmt2sDQkKhay0b4XbyJb4ta8d3PupSg43rzKuMfaJYealOreOqw52eiV4)1WZnLueX9nrece3X1YuIOei5Nf)zqGQOpK9ma73paNTC9YEwtdVyM1JRayuayJiqQ6tzrexicuiRCBcKmSwDiRCBTnvfbYMQs3HhtG8YkNJk3MueXhNicbI74AzkrucK8ZI)miqxyeehnAz2Z6hUzTbog22bpqGOSs(5qLBtGGYwYaCzYa8Ww52aSCxlDn0aSzOayPz0Zmvaa2a7RwlaRoULaSHSmbyX6r7OqGczLBtGg2k3MueXrfIieOqw52eiyfRZI9ueiUJRLPerjfrCXMicbI74AzkrucuhEmbAoqJT6frxMSgjFvPJ)Mf)eOqw52eO5an2QxeDzYAK8vLo(Bw8tkI4IfIieOqw52eOpsfRPCqjqChxltjIskI4hvIieiUJRLPerjqYpl(ZGajga(cJG4OrlZEw)WnRnWXW2o4ba(ea7dalgawUOXD0LRZzZsJema73paFHrqCuoktLMcZUN9ISvamkaSydWgtGczLBtGU2DP0p7d8tkI4czerece3X1YuIOeOqw52eizyT6qw52ABQkcKnvLUdpMa9HmdRIueXfsiIieiUJRLPerjqHSYTjqQq(jskZWQhczrGOSs(5qLBtGocvXEdfaxlaRc5NiPKb4YKb4zZf2cWjcaBGb4HNPPSIR9ya2qATaCVfatxa2dwAcWzdWLjdWnhpaJaxWptGKFw8NbbYhawmaSCrJ7OlxNZMLgjya2VFa(cJG4OCuMknfMDp7fzRayuayubGngGpbWxyeehnAz2Z6hUzTbog229SxKTcGrbG9naFcG9bGh4YnBUWw3ZEr2kagDawqa2VFaUIFMlxLESUwnnzagDaEwsbyJjfrCHeKicbI74AzkrucuiRCBcKmSwDiRCBTnvfbYMQs3HhtGKlAChDPifrCHgLicbI74AzkrucK8ZI)miq(aWpCZam6taSGa8ja(HB2vPhRRv7BagfaEwsb4taS0m(zwPr(qw52HfGrzcGfYjwayJby)(b4hUzxLESUw9Oamka8SKsGczLBtGU2DP6kgifrCH8nrece3X1YuIOei5Nf)zqGedaFHrqC0OLzpRF4M1g4yyBh8abkKvUnbIgTm7z9d3S2ahdBtkI4cnorece3X1YuIOei5Nf)zqGUWiioA0YSN1pCZAdCmSTdEGafYk3Ma9WToKvUT2MQIaztvP7WJjq03GgEGueXfcviIqG4oUwMseLafYk3MajdRvhYk3wBtvrGSPQ0D4XeivfnnEkPifb6dzgwfreI4creHaXDCTmLikbs(zXFgei5Uw6AOD0OLzpRF4M1g4yyB3Zb9ya(ea7dalgawURLUgA31UlL(zFGF3Zb9ya2VFawmaCfwUl31UlL(zFGFh3X1Yua2ycuiRCBc01UlvJa)htkI4cseHafYk3MaD5xX)HSNjqChxltjIskI4JseHaXDCTmLikbs(zXFgeOqwjASMB2lzfaJYealia73pa)WndWOdWcbWNa4hUtPEynWVJYiPmlagfagvmIafYk3MafVmAwpaBvmPiI7BIieiUJRLPerjqYpl(ZGaDHrqCWT5ApwRQN75Y0bpqGczLBtGS5SzP0O6HPZECxKIi(4eriqHSYTjqrlzv9HvldRLaXDCTmLikPiIJkeriqHSYTjqi5Zx7Uuce3X1YuIOKIiUyteHafYk3MaDJz9IORpLhueiUJRLPerjfrCXcrece3X1YuIOei5Nf)zqGE4oL6H1a)okJKYSayuaybnIafYk3MafVmAwx7)CxKIueivfnnEkreI4creHaXDCTmLikbs(zXFgeOhUtPEynWVJYiPmlag9jawiJa4taSpaSya4kSCxU72SQ23ZXDCTmfG97hGfdal31sxdT7UnRQ99Cph0Jby)(b4lmcIJgTm7z9d3S2ahdB7GhayJjqHSYTjquoktTQ(8atkI4cseHaXDCTmLikbs(zXFgeObUCZMlS19SxKTcGrhGNLuaEmawqcuiRCBcKkKFIKYmS6HqwKIi(OeriqChxltjIsGKFw8NbbsUOXD0LRZzZsJemaFcGPCuM6OPAklJJDvkpK9maFcG9bGVWiiokhLPstHzh8aaFcGVWiiokhLPstHz3ZEr2kagDagvayJjqHSYTjqMC8LwvFEGjfrCFteHaXDCTmLikbs(zXFgeOlmcI7UnRvMjBPovfYdamkta84a8ja(HBgGrzcGfeGpbWpCNs9WAGFhLrszwamkta8OgrGczLBtGQ17QQTzsreFCIieiUJRLPerjqYpl(ZGa5daFHrqC3TzTYmzl19SxKTcGrFcGF4MDv6X6A1JcW(9dWxyee3DBwRmt2sDp7fzRay0NayFa4zjfGfgGL7APRH2DT7sPF2h439CqpgGhdGRWYD5U2DP0p7d874oUwMcWJbW(gGngG97hGVWiiU72SwzMSL6uvipaWOdWOca73pa7da7dalgawUOXD0LRZzZsJema73paFHrqCuoktLMcZUN9ISvamka84aSXa8ja(cJG4UBZALzYwQ7zViBfaJoal2aSXaSXa8ja(H7uQhwd87OmskZcGrbGf0icuiRCBcKx8)A45MskI4Ocrece3X1YuIOei5Nf)zqGE4oL6H1a)okJKYSay0Nay0IpJRLDuoktTQ(8aRPWEd6WBH7cGpbWIbG9bGRWYD5UBZQAFph3X1Yua(eal31sxdT7UnRQ99Cp7fzRay0bybbyJb4taSyayFay5Ig3rxo04Ump(b4taSCxlDn0oLH49YEw7LQY9SxKTcGrhGhfGnMafYk3Mar5Om1Q6ZdmPiIl2eriqChxltjIsGKFw8NbbsAg)mR0iFiRC7WcWOmbWc5ela8ja2ha(cJG4mzVvvHkvovfYdam6taSpa84amQcGvdS1QR4N5s5U2DP67Mwa2ya2VFawnWwRUIFMlL7A3LQVBAbyuaybbyJjqHSYTjqx7Uu9DtlPiIlwiIqG4oUwMseLafYk3Ma5f)b9IOV2DPeikRKFou52eiFrXFaGxeawu7UuaMUScG7Ta4HOPSxkrvmQxCtDei5Nf)zqGO8fgbX5f)b9IOV2DPo6AOb4tamsoBw6N9ISvamkaSy7gNueXpQeriqChxltjIsGKFw8Nbb6cJG4KF6P2wRKl8pZo4ba(eaxHL7Y9SnvM6S1x7Uuh3X1Yua(ea)WDk1dRb(DugjLzbWOaWczebkKvUnbIYrzQJMQPSmoMueXfYiIieiUJRLPerjqYpl(ZGa9WDk1dRb(byuMayHmYicuiRCBc0DBwv77rkI4cjerece3X1YuIOeODGaP4kriqHSYTjqOfFgxltGqlEDhEmbYKJV0Q6ZdS(hiqYpl(ZGajx04o6Y15SzPrcgGpbWuoktD0unLLXXUkLhYEMaHwyHznBvmbYhawOXbyHby1aBT6k(zUuoto(sRQppWa8yaCfwUlNjhFDFooWVJ74AzkapgaliaBmapgalKtqceAHfMjq(aWcnoalmaRgyRvxXpZLYzYXxAv95bgGhdGRWYD5m54R7ZXb(DChxltb4XaybbyJjfrCHeKicbI74AzkrucK8ZI)miq(aWpCNs9WAGFhLrszwam6tamAXNX1Yoto(sRQppW6FaGngG97hGR4N5YvPhRRvttgGrhGfYicuiRCBceLJYuRQppWKIiUqJseHaXDCTmLikbs(zXFgei1aBT6k(zUuokhLPoAQMYY4yagLjaEucuiRCBceLJYuhnvtzzCmPiIlKVjIqG4oUwMseLaj)S4pdc0d3SRspwxR23am6a8SKsGczLBtGm54lTQ(8atkI4cnorece3X1YuIOei5Nf)zqGUWiio5NEQT1k5c)ZSdEaG97hGRWYD5(yiPAklxVHvLvUTJ74AzkbkKvUnbIYrzQJMQPSmoMueXfcviIqG4oUwMseLaj)S4pdc0fgbXD3M1kZKTu3ZEr2kagfaEuaEmaEwsjqHSYTjqYTvWEdvUnPiIlKyteHaXDCTmLikbs(zXFgeiPz8ZSsJ8HSYTdlaJYealKtia(eaFHrqC3TzTYmzl19SxKTcGrbGhfGhdGNLucuiRCBc01UlvF30skI4cjwiIqG4oUwMseLaj)S4pdc0d3maJcaleaFcG9bGF4MDv6X6A1JcWOdWZska73paFHrqC3TzTYmzl1PQqEaGrbGfBa(eaFHrqC3TzTYmzl19SxKTcGrbGF4MDv6X6A1JcWcdWZskaBmbkKvUnbYKJV0Q6ZdmPiIl0rLicbI74AzkrucK8ZI)miqpCNs9WAGFhLrszwamkaSGgrGczLBtGIxgnRR9FUlsrksrGqJFvUnrCbnsqbnAubrfcKH47SNveOJYr4Oj(rxCFbhjagGfXKb40By)cGr2hG9v6Bqdp4Ra8Z(sW5ZuawTEmahW16fftbyPz0ZSYboFeNndWcDKa4J82OXFXua2xF4Mr2FMDhr(kaxla7RpCZi7pZUJih3X1YuFfGJcGr1q19igG9riu3yh4m48r5iC0e)OlUVGJeadWIyYaC6nSFbWi7dW(QCrJ7OlLVcWp7lbNptby16XaCaxRxumfGLMrpZkh48rC2ma77JeaFK3gn(lMcW(QAHT3SPUJiFfGRfG9v1cBVztDhroUJRLP(ka7JGOUXoWzW5JU3W(ftbyXgGdzLBdW2uvkh4mbA4xK0Yeiud1ayrT7sbyXkhLja7lUZzZcCg1qna(im8PfGfACbaybnsqbbNbNrnudGpYMrpZQJe4mQHAamQcGHGhg2VayK9byrT7sbyr30cWzdWI1J2rbGvCvzp7aNbNrnagvd1zjCXua(Yi7ZaSC9UrbWxEoBLdGpcsjpukaU3gvzgVhcSfGdzLBRa4TTh7aNdzLBRCdplxVBucpncILvMYpqkWzWzudGr1qDwcxmfGz04)yaUspgGltgGdzTpaNkaoqlsBCTSdCoKvUTAYlBQg5z2xidohYk3wj80iOfFgxllqhE8eLJYuRQppWAkS3Go8w4UeaTWcZtITrcSdtkUsebKBtZk3EsUOXD0LRZzZsJe8PlmcIJYrzQ0uy29SxKTcfura0clmRzRINgFCW5qw52kHNgXl(Fn8CtfirMUWiiU72SwzMSL6E2lYwH(OJnlPog1zjCX(97ZfgbXD3M1kZKTu3ZEr2k0NE4MDv6X6A1J63)fgbXD3M1kZKTu3ZEr2k0N8zwsfwURLUgA31UlL(zFGF3Zb94XQWYD5U2DP0p7d874oUwMoMGg73)fgbXD3M1kZKTuNQc5b0h34tpCNs9WAGFhLrszwOmjOrGZHSYTvcpnImSwDiRCBTnvLaD4XtEzLZrLBlGQ(uwtcjqImvrFi7z)(ZwUEzpRPHxmZ6XvOye4mQbWqzlzaUmzaEyRCBawURLUgAa2muaS0m6zMkaaBG9vRfGvh3sa2qwMaSy9ODuaNdzLBReEAKHTYTfirMUWiioA0YSN1pCZAdCmSTdEaCoKvUTs4PrGvSol2tbohYk3wj80iWkwNf7jqhE80CGgB1lIUmzns(Qsh)nl(bNdzLBReEAKpsfRPCqbNdzLBReEAKRDxk9Z(a)cKitI5cJG4OrlZEw)WnRnWXW2o4Ht(ig5Ig3rxUoNnlnsW(9FHrqCuoktLMcZUN9ISvOi2gdohYk3wj80iYWA1HSYT12uvc0Hhp9HmdRcCg1a4JqvS3qbW1cWQq(jskzaUmzaE2CHTaCIaWgyaE4zAkR4ApgGnKwla3BbW0fG9GLMaC2aCzYaCZXdWiWf8ZGZHSYTvcpnIkKFIKYmS6HqwcKit(ig5Ig3rxUoNnlnsW(9FHrqCuoktLMcZUN9ISvOGkgF6cJG4OrlZEw)WnRnWXW2UN9ISvO47t(mWLB2CHTUN9ISvOlOF)v8ZC5Q0J11QPjJ(SKAm4CiRCBLWtJidRvhYk3wBtvjqhE8KCrJ7Olf4CiRCBLWtJCT7s1vmiqIm5Zd3m6tcE6HB2vPhRRv7BuML0tsZ4NzLg5dzLBhwuMeYjwm2V)hUzxLESUw9OOmlPGZHSYTvcpncnAz2Z6hUzTbog2wGezsmxyeehnAz2Z6hUzTbog22bpaohYk3wj80ipCRdzLBRTPQeOdpEI(g0WdcKitxyeehnAz2Z6hUzTbog22bpaohYk3wj80iYWA1HSYT12uvc0HhpPQOPXtbNbNdzLBRCYfnUJUutuoktLMcZcKitI5cJG4OCuMknfMDWd(9FHrqCuoktLMcZUN9ISvO7B)(VWiio5NEQT1k5c)ZSdEaCoKvUTYjx04o6sj80ikdX7L9S2lvLajYKCxlDn0oA0YSN1pCZAdCmST7zViBfkJE6H7uQhwd8JYKphvJqv(OgyRvxXpZLYPmeVx2ZAVuvJnQXgdohYk3w5KlAChDPeEAK4UEzhvUT2MExbsKjXCHrqC0OLzpRF4M1g4yyBh8a4CiRCBLtUOXD0Ls4PrqSSYu(bsjqImPwy7nBQBawvWwwZp8qLB73VAHT3SPo0wBuPL1Q1Ig31jXCHrqCOT2OslRvRfnUlTjSx0BsDWdcKDX)dpu60ZJPzu8KqcKDX)dpu6z7Ed7KqcKDX)dpu6ezsTW2B2uhARnQ0YA1ArJ7cCoKvUTYjx04o6sj80ikZqEWY6YK1WTH9lZJfirME4MrF0tpCNs9WAGF0fYiJaNbNdzLBRC03GgEyQwVRQ2MfirMUWiiU72SwzMSL6uvipGY04NE4MrzsWtpCNs9WAGFhLrszwOmnQrNE4Mr2FMDYp9uBRF4M1g4yyBW5qw52kh9nOHheEAeV4)1WZnvGezYNlmcI7UnRvMjBPUN9ISvOp9Wn7Q0J11Qh1V)lmcI7UnRvMjBPUN9ISvOp5ZSKkSCxlDn0URDxk9Z(a)UNd6XJvHL7YDT7sPF2h43XDCTmDmFBSF)(CHrqC3TzTYmzl1PQqEaDbp5JyKlAChD5Aw(RDFQF)xyeexCxVSJk3wBtVRdEWyJn(0d3PupSg43rzKuMfkcAe4CiRCBLJ(g0WdcpnY1UlvF30kqImjnJFMvOmj4PhUz0Nesyfxv2Zk31UlvF30QPVbW5qw52kh9nOHheEAe0IpJRLfOdpEYKJV0Q6ZdS(h003GaOfwyEYhHgx4lmcIJgTm7z9d3S2ahdB7GhgtiJewnWwRUIFMlLZKJV0Q6Zd8yvy5UCMC81954a)oUJRLPJjOXGZHSYTvo6Bqdpi80iuoktTQ(8alGnBwlPt(EmZqv8ykUQSNvURDxQ(UPvtFdcKitpCNs9WAGFhLrszwOpHw8zCTSZKJV0Q6ZdS(h003WjX4tfwUl3DBwv7754oUwMEsURLUgA3DBwv775E2lYwHUGgdohYk3w5OVbn8GWtJC3Mv1(EcKitpCNs9WAGFuMeYiJaNdzLBRC03GgEq4PrU2DP67MwbSzZAjDY3JzgQIfirMudS1QR4N5s5U2DP67MwueeCoKvUTYrFdA4bHNgXKJV0Q6ZdSajY0d3SRspwxRwq0NLu)(fJIRk7zL7A3LQVBA103WPhUtPEynWVJYiPmluMql(mUw2zYXxAv95bw)dA6BaCoKvUTYrFdA4bHNgHYrzQJMQPSmowGezsnWwRUIFMlLJYrzQJMQPSmogLPrbNbNdzLBRCEzLZrLBpHw4nKFk1x7UubsKjtoSLPBqwOpUr(97JyM)fE4Kjh2Y0nil0rfuXyWzudGp6TC9YEgGPHxmZa8Z(sW5ZECxaCQaybh3xgGxea2lqDa2KdBzcWQ1UcaWJBKVmaViaSxG6aSjh2YeGZgGdaE(x4bh4CiRCBLZlRCoQCBHNgHYrzQv1NhybsKPSLRx2ZAA4fZSEufktMCyltNe(FUlWzudGfRB7RfaB5cGJgGzupvv2ZaSO2DPamKzYwkat)DWbohYk3w58YkNJk3w4PrOCuMAv95bwGezsfOX6RDxQwzMSLEkB56L9SMgEXmRhxHIrNUWiiURDxQwzMSL6GhoDHrqCx7UuTYmzl19SxKTcDHCJp2SKcohYk3w58YkNJk3w4PrE4M1vmiqImvrFi75txyee3d3SUIbhDn0NYwUEzpRPHxmZ6rvOyYHTmDEbQpMroHaNdzLBRCEzLZrLBl80iPKVlCt1i7xzbtzbsKjtoSLPBqwOpUrOkFe0OXUWiiURDxQwzMSL6GhmgCoKvUTY5LvohvUTWtJOc5NiPmdREiKLajYKjh2Y0nil0f7XpnWLB2CHTUN9ISvOpo4m4CiRCBL7dzgw101UlvJa)hlqImj31sxdTJgTm7z9d3S2ahdB7EoOhFYhXi31sxdT7A3Ls)SpWV75GESF)IPcl3L7A3Ls)SpWVJ74AzQXGZHSYTvUpKzyvcpnYLFf)hYEgCoKvUTY9HmdRs4PrIxgnRhGTkwGezkKvIgR5M9swHYKG(9)WnJUqNE4oL6H1a)okJKYSqbvmcCoKvUTY9HmdRs4PrS5SzP0O6HPZECxcKitxyeehCBU2J1Q65EUmDWdGZHSYTvUpKzyvcpns0swvFy1YWAbNdzLBRCFiZWQeEAeK85RDxk4CiRCBL7dzgwLWtJCJz9IORpLhuGZHSYTvUpKzyvcpns8YOzDT)ZDjqIm9WDk1dRb(DugjLzHIGgbodohYk3w5uv004PtuoktTQ(8alqIm9WDk1dRb(DugjLzH(KqgDYhXuHL7YD3Mv1(EoUJRLP(9lg5Uw6AOD3TzvTVN75GESF)xyeehnAz2Z6hUzTbog22bpym4CiRCBLtvrtJNk80iQq(jskZWQhczjqImnWLB2CHTUN9ISvOplPJji4mQHAaCiRCBLtvrtJNk80ix7Uu6N9b(firMeZfgbXrJwM9S(HBwBGJHTDWdGZOgQbWIv4bBkJIPaSj)maFzzaRyaUmza2lRCoQCBa2MQcGF2MScG3gGROpK98ivCi7zaMgEXm7aNrnudGdzLBRCQkAA8uHNgXl(Fn8CtfirMUWiiU72SwzMSL6E2lYwH(OJnlPog1zjCX(97ZfgbXD3M1kZKTu3ZEr2k0NE4MDv6X6A1J63)fgbXD3M1kZKTu3ZEr2k0N8zwsfwURLUgA31UlL(zFGF3Zb94XQWYD5U2DP0p7d874oUwMoMGg73)fgbXD3M1kZKTuNQc5b0h14tpCNs9WAGFhLrszwOmjOrGZHSYTvovfnnE6KjhFPv1NhybsKj5Ig3rxUoNnlnsWNOCuM6OPAklJJDvkpK98jFUWiiokhLPstHzh8WPlmcIJYrzQ0uy29SxKTcDuXyW5qw52kNQIMgpv4PrQ17QQTzbsKPlmcI7UnRvMjBPovfYdOmn(PhUzuMe80d3PupSg43rzKuMfktJAe4CiRCBLtvrtJNk80iEX)RHNBQajYKpxyee3DBwRmt2sDp7fzRqF6HB2vPhRRvpQF)xyee3DBwRmt2sDp7fzRqFYNzjvy5Uw6AODx7Uu6N9b(Dph0JhRcl3L7A3Ls)SpWVJ74Az6y(2y)(VWiiU72SwzMSL6uvipGoQ43Vp(ig5Ig3rxUoNnlnsW(9FHrqCuoktLMcZUN9ISvOmUXNUWiiU72SwzMSL6E2lYwHUyBSXNE4oL6H1a)okJKYSqrqJaNdzLBRCQkAA8uHNgHYrzQv1NhybsKPhUtPEynWVJYiPml0Nql(mUw2r5Om1Q6ZdSMc7nOdVfURtIXNkSCxU72SQ23ZXDCTm9KCxlDn0U72SQ23Z9SxKTcDbn(Ky8rUOXD0LdnUlZJ)tYDT01q7ugI3l7zTxQk3ZEr2k0h1yW5qw52kNQIMgpv4PrU2DP67MwbsKjPz8ZSsJ8HSYTdlktc5elN85cJG4mzVvvHkvovfYdOp5Z4Ok1aBT6k(zUuURDxQ(UP1y)(vdS1QR4N5s5U2DP67Mwue0yWzudG9ff)baErayrT7sby6YkaU3cGhIMYEPevXOEXn1bohYk3w5uv004PcpnIx8h0lI(A3LkqImr5lmcIZl(d6frFT7sD01qFcjNnl9ZEr2kueB34GZHSYTvovfnnEQWtJq5Om1rt1uwghlqImDHrqCYp9uBRvYf(Nzh8WPkSCxUNTPYuNT(A3L64oUwME6H7uQhwd87OmskZcfHmcCoKvUTYPQOPXtfEAK72SQ23tGez6H7uQhwd8JYKqgze4CiRCBLtvrtJNk80iOfFgxllqhE8KjhFPv1Nhy9piaAHfMN8rOXfwnWwRUIFMlLZKJV0Q6Zd8yvy5UCMC81954a)oUJRLPJjOXcSdtkUsebKBtZk3EsUOXD0LRZzZsJe8jkhLPoAQMYY4yxLYdzplaAHfM1SvXt(i04cRgyRvxXpZLYzYXxAv95bESkSCxoto(6(CCGFh3X1Y0Xe04XeYji4CiRCBLtvrtJNk80iuoktTQ(8alqIm5Zd3PupSg43rzKuMf6tOfFgxl7m54lTQ(8aR)bJ97VIFMlxLESUwnnz0fYiW5qw52kNQIMgpv4PrOCuM6OPAklJJfirMudS1QR4N5s5OCuM6OPAklJJrzAuW5qw52kNQIMgpv4Prm54lTQ(8alqIm9Wn7Q0J11Q9n6Zsk4CiRCBLtvrtJNk80iuoktD0unLLXXcKitxyeeN8tp12ALCH)z2bp43FfwUl3hdjvtz56nSQSYTDChxltbNdzLBRCQkAA8uHNgrUTc2BOYTfirMUWiiU72SwzMSL6E2lYwHYOJnlPGZHSYTvovfnnEQWtJCT7s13nTcKitsZ4NzLg5dzLBhwuMeYj0PlmcI7UnRvMjBPUN9ISvOm6yZsk4CiRCBLtvrtJNk80iMC8LwvFEGfirME4MrrOt(8Wn7Q0J11Qhf9zj1V)lmcI7UnRvMjBPovfYdOi2NUWiiU72SwzMSL6E2lYwHYd3SRspwxREuHNLuJbNdzLBRCQkAA8uHNgjEz0SU2)5UeirME4oL6H1a)okJKYSqrqJiqbCzUpbck9oYaSWamQo8H0MKIueca]] )

end