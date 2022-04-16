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


    spec:RegisterPack( "Blood", 20220416, [[dW0NcbqicvEeKuUKqjQnPO6tcL0OifDksHvPO0RiOMfb6wQuj7Is)sHyycfhJGSmiLNPsvttOuxtrX2ui13iuvJtLk15uijRtLk08Ge3tr2hKQdQqclKq6HkKutKqv6IeQcFuOeyKeQI4KQurTsvkVuOeQzQqI6McLq2jHYpjufPLQsf5PQyQeIVQsfmwfsK9I4VcgmuhMQfdYJjAYiDzuBgIpRsgTqoTOvtOkQxRqnBkUnPA3s9BLgUcoUqjYYv1Zjz6sUoO2ob8DsPXdjvNhsY6fkbnFHQ9dmriIiKd1lMigAXGgAXeBHgTvO7gn0MHCkunWKZGlh7xm50UotoIA2LsodoQmRtjIqoQf(Lm5CsDyJx52J63rkYbcon1DUjqKd1lMigAXGgAXeBHgTvO7gn0I9OICudSKigAZed5eLuk3eiYHYkj5iQzxkalEzVIa4yXDEfvGBJIHpnaSqJwqagTyqdnWnWTrDK3xS6ocUDxa8bEyy)cGr2hGf1SlfGfDtdaNnalEVt3bawXvL9LLCmPQuerih6RnapqeHiMqerihUDidtjIsoYpl(tNCGGrqSqBZbvuYgQvvUCmaJ(eapdaphGF4Mby0Nay0a45a8d3PmmSA53szKuMfaJ(eaFFma8Ca(HBgz)l2k)uxTD4HBoOL9HTTC7qgMsoUSYTjNA1Hu12mPiIHgreYHBhYWuIOKJ8ZI)0jhnbyiyeel02CqfLSHAFw3ZwbWOmbWpCZ2k15qTH7b44Xbyiyeel02CqfLSHAFw3ZwbWOmbWAcWxskalmal31qxTTfYSlL(zpMF7Zofva8SaC5gUllKzxk9ZEm)wUDidtb4zb4ydWAaWXJdWAcWqWiiwOT5Gkkzd1QkxogGrbGrdGNdWAcWIdGLRaC7DzBw(RzFkahpoadbJGyDOvpBVYTdMuhYcpaWAaWAaWAaWZb4hUtzyy1YVLYiPmlagDagTyihxw52KJU))Q95MskIy3teHC42HmmLik5i)S4pDYrg5)fRay0Nay0a45a8d3maJcaJg54Yk3MCGm7sdqBAifrSyteHC42HmmLik5SdKJIlYXLvUn5iG)PdzyYra3aZKJMaSqZaWcdWqWiiwQ3YSVcpCZbTSpSTfEaGNfGfkgawyawnWgtO8)IlLnI9VcQ6ZXmaplaxUH7YgX(xqp7J53YTdzykaplaJgaRb5iG)H21zYjI9VcQ6ZXC4hc0xlPiIndreYHBhYWuIOKJlRCBYHYEffu1NJzYr(zXF6KdemcIfYSlnOIs2qTpR7zRayua4ljfGJhhGF4oLHHvl)wkJKYSayuMayb8pDidBJy)RGQ(Cmh(Ha91cWZbyXbWAcWLB4USqBZQAFDl3oKHPa8CawURHUABl02SQ2x3(SUNTcGrbGrdG1GCmzZbjLCI9SrUQysreB0erihUDidtjIsoYpl(tNCE4oLHHvl)am6taSqXed54Yk3MCG2Mv1(6KIiM4teHC42HmmLik54Yk3MCGm7sdqBAih5Nf)PtoQb2ycL)xCPSqMDPbOnnam6amAKJjBoiPKtSNnYvftkIy3nreYHBhYWuIOKJ8ZI)0jNhUzBL6CO2aAamka8LKsoUSYTjNi2)kOQphZKIi2OIic5WTdzykruYr(zXF6KZd3PmmSA53szKuMfaJYealG)PdzyBe7Ffu1NJ5WpeOVwaEoaloawtaUCd3LfABwv7RB52HmmfGNdWYDn0vBBH2Mv1(62N19SvamkamAaSgKJlRCBYHYEffu1NJzsretOyiIqoC7qgMseLCKFw8No5OgyJju(FXLYszVIcEtduw6OcGrhGrJCCzLBtou2ROG30aLLoQifPih5ka3ExkIieXeIic5WTdzykruYr(zXF6KJ4ayiyeelL9ksfOWSfEaGJhhGHGrqSu2RivGcZ2N19SvamkaCSb44XbyiyeeR8tD12bLCH)l2cpqoUSYTjhk7vKkqHzsrednIiKd3oKHPerjh5Nf)PtoYDn0vBBPElZ(k8Wnh0Y(W22N19Svam6a89a8Ca(H7uggwT8dWOpbWAcWJQya47cG1eGvdSXek)V4szvA9xp7RGEQkaEwa(EawdawdYXLvUn5O06VE2xb9uvKIi29erihUDidtjIsoYpl(tNCehadbJGyPElZ(k8Wnh0Y(W2w4bYXLvUn54qRE2ELBhmPoePiIfBIiKd3oKHPerjh5Nf)PtoQf2aLn1oaRkydh4hEOYTTC7qgMcWXJdWQf2aLn1kWA8knCqTgb4USC7qgMcWZbyXbWqWiiwbwJxPHdQ1ia3vicw37nPw4bYj7I)hEOcjc5Owydu2uRaRXR0Wb1AeG7ICYU4)HhQqQRZ00lMCeICCzLBtoigwfjFhPiNSl(F4HkCzwi3qocrkIyZqeHC42HmmLik5i)S4pDY5HBgGrbGVhGNdWpCNYWWQLFagfawOyIHCCzLBtoQixo2WHkIdWT29RiurksrodplxDiViIqetiIiKd3oKHPerjhkRKFou52KJ4bQZs4IPameJSpdWYvhYlagIVYwzb4rHuYdLcG7TVRi)1rGnaSlRCBfaVTbvwYXLvUn5GyyvK8DKIuKIC0ZkV8k3MicrmHiIqoC7qgMseLCKFw8No5eXUPISdYcGrbGNjgaoECawtawCa81VWda8CaoIDtfzhKfaJcap6rdWAqoUSYTjhbC9H8tzaYSlLueXqJic5WTdzykruYXLvUn5qzVIcQ6ZXm5qzL8ZHk3MCUZTC1Z(cGPUUFXa8ZXsW5Z6CxaCQay0MjwgGxeaw3rDaoIDtfbWQ1SccWZetSmaViaSUJ6aCe7MkcGZgGDa(6x4bl5i)S4pDYjB5QN9vG66(fhUxbWOpbWrSBQiRe(FUlsre7EIiKd3oKHPerjhxw52KdL9kkOQphZKdLvYphQCBYr8UDSwaSHla2BaMr9uvzFbWIA2LcWNOKnuaM(7GLCKFw8No5OCb4aKzxAqfLSHcWZb4SLRE2xbQR7xCygfaJoahdaphGHGrqSqMDPbvuYgQfEaGNdWqWiiwiZU0Gkkzd1(SUNTcGrbGfYodaplaFjPKIiwSjIqoC7qgMseLCKFw8No5uEpo7laEoadbJGyF4MdLpyPR2gGNdWzlx9SVcux3V4W9kagDaoIDtfz1DuhGNfGJXke54Yk3MCE4MdLpqkIyZqeHC42HmmLik5i)S4pDYjIDtfzhKfaJcaptma8DbWAcWOfdapladbJGyHm7sdQOKnul8aaRb54Yk3MCsjdTWnnGSFLfmLjfrSrteHC42HmmLik5i)S4pDYjIDtfzhKfaJcal(ZaWZb4bUSxrlSX(SUNTcGrbGNHCCzLBtokx(jskt3egCzrksrougXHnfreIycreHC42HmmLik5qzL8ZHk3MCepqDwcxmfGzb4hvaCL6maxrma7YAFaovaSlGNghYWwYXLvUn5ONnnG8mhlKjfrm0iIqoC7qgMseLC2bYrXvIqoUSYTjhb8pDidtoc4FODDMCOSxrbv95yoqH1hcU(c3f5i)S4pDYrUcWT3LTZROkG4maphGHGrqSu2RivGcZ2N19Svam6a8OjhbCdmhyJIjNzMHCeWnWm5i(XqkIy3teHC42HmmLik5i)S4pDYbcgbXcTnhurjBO2N19Svamka89a8Sa8LKAzuNLWfdWXJdWAcWqWiiwOT5Gkkzd1(SUNTcGrzcGF4MTvQZHAd3dWXJdWqWiiwOT5Gkkzd1(SUNTcGrzcG1eGVKuawyawURHUABlKzxk9ZEm)2NDkQa4zb4YnCxwiZUu6N9y(TC7qgMcWZcWObWAaWXJdWqWiiwOT5Gkkzd1QkxogGrbGNbG1aGNdWpCNYWWQLFlLrszwam6tamAXqoUSYTjhD))v7ZnLueXInreYHBhYWuIOKJ8ZI)0jNY7XzFbWXJdWzlx9SVcux3V4WmkagDaogYrvFklIycroUSYTjhPBmbxw52btQkYXKQk0Uoto6zLxELBtkIyZqeHC42HmmLik5i)S4pDYbcgbXs9wM9v4HBoOL9HTTWdKdLvYphQCBY5KTKb4kIb4HTYTby5Ug6QTb4ixbWYiVVyQGaSwowngawHQwcWAZkcGfV3P7a54Yk3MCg2k3MueXgnreYXLvUn5aR4qwSUIC42HmmLikPiIj(erihUDidtjIsoTRZKZLlaBclsOI4as(Qk4puw8toUSYTjNlxa2ewKqfXbK8vvWFOS4NueXUBIiKJlRCBY59uXbk7uYHBhYWuIOKIi2OIic5WTdzykruYr(zXF6KJ4ayiyeel1Bz2xHhU5Gw2h22cpaWZbynbyXbWYvaU9USDEfvbeNb44XbyiyeelL9ksfOWS9zDpBfaJoal(aSgKJlRCBYbYSlL(zpMFsretOyiIqoC7qgMseLCCzLBtos3ycUSYTdMuvKJjvvODDMCExMUrrkIycjereYHBhYWuIOKJlRCBYr5Yprsz6MWGllYHYk5NdvUn5mkQI1hkaUwaw5YprsjdWvedWxrlSbGteawldWdpttz5qgubWAtJbG7Tay6cW6WYiaoBaUIyaUz)bye4c(zYr(zXF6KJMaS4ay5ka3Ex2oVIQaIZaC84amemcILYEfPcuy2(SUNTcGrhGhnaRbaphGHGrqSuVLzFfE4MdAzFyB7Z6E2kagDao2a8CawtaEGl7v0cBSpR7zRayuay0a44Xb4Y)lUSvQZHAd0Kbyua4ljfG1GueXecnIiKd3oKHPerjhxw52KJ0nMGlRC7Gjvf5ysvfAxNjh5ka3ExksretO7jIqoC7qgMseLCKFw8No5Oja)WndWOmbWObWZb4hUzBL6CO2qSby0b4ljfGNdWYi)Vyva5DzLB7gag9jawi7DdWAaWXJdWpCZ2k15qTH7by0b4ljLCCzLBtoqMDPHYhifrmHInreYHBhYWuIOKJ8ZI)0jhXbWqWiiwQ3YSVcpCZbTSpSTfEGCCzLBtouVLzFfE4MdAzFyBsretOziIqoC7qgMseLCKFw8No5abJGyPElZ(k8Wnh0Y(W2w4bYXLvUn58WDWLvUDWKQICmPQcTRZKd91gGhifrmHgnreYHBhYWuIOKJlRCBYr6gtWLvUDWKQICmPQcTRZKJQ8M6pLuKICExMUrreHiMqerihUDidtjIsoYpl(tNCK7AOR22s9wM9v4HBoOL9HTTp7uubWZbynbyXbWYDn0vBBHm7sPF2J53(StrfahpoaloaUCd3LfYSlL(zpMFl3oKHPaSgKJlRCBYbYSlnGa)OIueXqJic54Yk3MCG4xX)4SVihUDidtjIskIy3teHC42HmmLik5i)S4pDYXLvkah4M1twbWOpbWObWXJdWpCZamkaSqa8Ca(H7uggwT8BPmskZcGrhGhDmKJlRCBYXFP3Cya2Oysrel2erihUDidtjIsoYpl(tNCGGrqSWD0Aqvqvp3xvKfEGCCzLBtoM8kQubXZW0lDUlsreBgIiKJlRCBYXBjRQ3nbPBmKd3oKHPerjfrSrteHCCzLBtoi5ZqMDPKd3oKHPerjfrmXNic54Yk3MCG8RWIeQpLJvKd3oKHPerjfrS7Mic5WTdzykruYr(zXF6KZd3PmmSA53szKuMfaJoaJwmKJlRCBYXFP3CO2)5UifPihv5n1FkreIycreHC42HmmLik5i)S4pDY5H7uggwT8BPmskZcGrzcGfkgaEoaRjaloaUCd3LfABwv7RB52HmmfGJhhGfhal31qxTTfABwv7RBF2POcGJhhGHGrqSuVLzFfE4MdAzFyBl8aaRb54Yk3MCOSxrbv95yMueXqJic5WTdzykruYr(zXF6KZax2ROf2yFw3ZwbWOaWxskaplaJg54Yk3MCuU8tKuMUjm4YIueXUNic5WTdzykruYr(zXF6KJCfGBVlBNxrvaXzaEoatzVIcEtduw6OYwPCC2xa8CawtagcgbXszVIubkmBHha45amemcILYEfPcuy2(SUNTcGrbGhnaRb54Yk3MCIy)RGQ(CmtkIyXMic5WTdzykruYr(zXF6KdemcIfABoOIs2qTQYLJby0Na4za45a8d3maJ(eaJgaphGF4oLHHvl)wkJKYSay0Na47JHCCzLBto1QdPQTzsreBgIiKd3oKHPerjh5Nf)PtoAcWqWiiwOT5Gkkzd1(SUNTcGrzcGF4MTvQZHAd3dWXJdWqWiiwOT5Gkkzd1(SUNTcGrzcG1eGVKuawyawURHUABlKzxk9ZEm)2NDkQa4zb4YnCxwiZUu6N9y(TC7qgMcWZcWXgG1aGJhhGHGrqSqBZbvuYgQvvUCmaJcapAaoECawtawtawCaSCfGBVlBNxrvaXzaoECagcgbXszVIubkmBFw3ZwbWOdWZaWAaWZbyiyeel02CqfLSHAFw3ZwbWOaWIpaRbaRbaphGF4oLHHvl)wkJKYSay0by0IHCCzLBto6()R2NBkPiInAIiKd3oKHPerjh5Nf)PtopCNYWWQLFlLrszwamktaSa(NoKHTu2ROGQ(CmhOW6dbxFH7cGNdWIdG1eGl3WDzH2Mv1(6wUDidtb45aSCxdD12wOTzvTVU9zDpBfaJcaJgaRbaphGfhaRjalxb427Yka3veQEaEoal31qxTTvP1F9SVc6PQSpR7zRayua47bynihxw52KdL9kkOQphZKIiM4teHC42HmmLik5i)S4pDYrg5)fRciVlRCB3aWOpbWczVBaEoaRjadbJGyJy9vvUkvwv5YXamktaSMa8ma8DbWQb2ycL)xCPSqMDPbOnnaSgaC84aSAGnMq5)fxklKzxAaAtdaJoaJgaRb54Yk3MCGm7sdqBAifrS7Mic5WTdzykruYXLvUn5O7)4WIeGm7sjhkRKFou52KtSi)hdWlcalQzxkatxwbW9wa8G3uwpL3fJ6f3ul5i)S4pDYHYqWiiwD)hhwKaKzxQLUABaEoaJKxrv4zDpBfaJoal(2zifrSrfreYHBhYWuIOKJ8ZI)0jhiyeeR8tD12bLCH)l2cpaWZb4YnCx2NnPkkKDaYSl1YTdzykaphGF4oLHHvl)wkJKYSay0byHIHCCzLBtou2ROG30aLLoQifrmHIHic5WTdzykruYr(zXF6KZd3PmmSA5hGrFcGfkMyihxw52Kd02SQ2xNueXesiIiKd3oKHPerjNDGCuCLiKJlRCBYra)thYWKJa(hAxNjNi2)kOQphZHFGCKFw8No5ixb427Y25vufqCgGNdWu2ROG30aLLoQSvkhN9f5iGBG5aBum5Ojal0maSWaSAGnMq5)fxkBe7Ffu1NJzaEwaUCd3LnI9VGE2hZVLBhYWuaEwagnawdaEwawilAKJaUbMjhnbyHMbGfgGvdSXek)V4szJy)RGQ(CmdWZcWLB4USrS)f0Z(y(TC7qgMcWZcWObWAqkIycHgreYHBhYWuIOKJ8ZI)0jhnb4hUtzyy1YVLYiPmlagLjawa)thYW2i2)kOQphZHFaG1aGJhhGl)V4YwPohQnqtgGrbGfkgYXLvUn5qzVIcQ6ZXmPiIj09erihUDidtjIsoYpl(tNCudSXek)V4szPSxrbVPbklDubWOpbW3toUSYTjhk7vuWBAGYshvKIiMqXMic5WTdzykruYr(zXF6KZd3STsDouBi2amka8LKsoUSYTjNi2)kOQphZKIiMqZqeHC42HmmLik5i)S4pDYbcgbXk)uxTDqjx4)ITWdaC84aC5gUl77djnqz5QpSQSYTTC7qgMsoUSYTjhk7vuWBAGYshvKIiMqJMic5WTdzykruYr(zXF6KdemcIfABoOIs2qTpR7zRay0b47b4zb4ljLCCzLBtoYTvW6dvUnPiIjK4teHC42HmmLik5i)S4pDYrg5)fRciVlRCB3aWOpbWczfcGNdWqWiiwOT5Gkkzd1(SUNTcGrhGVhGNfGVKuYXLvUn5az2LgG20qkIycD3erihUDidtjIsoYpl(tNCE4Mby0byHa45aSMa8d3STsDouB4Eagfa(ssb44Xbyiyeel02CqfLSHAvLlhdWOdWIpaphGHGrqSqBZbvuYgQ9zDpBfaJoa)WnBRuNd1gUhGfgGVKuawdYXLvUn5eX(xbv95yMueXeAureHC42HmmLik5i)S4pDY5H7uggwT8BPmskZcGrhGrlgYXLvUn54V0Bou7)CxKIuKICeGFvUnrm0Ibn0Ij2cnd5O1)o7lf5Chgf3jXUZIfl4ocWaSirmaN6d7xamY(aCSsFTb4HyfGFowcoFMcWQvNbyhUwDVykalJ8(IvwWTr5SzawO7iapQ3wa(lMcWX6d3mY(xSDukwb4Ab4y9HBgz)l2okz52HmmnwbyVayXdXthLbynfc11WcUbUDhgf3jXUZIfl4ocWaSirmaN6d7xamY(aCSkxb427sfRa8ZXsW5ZuawT6ma7W1Q7ftbyzK3xSYcUnkNndWX(ocWJ6TfG)IPaCSQwydu2u7OuScW1cWXQAHnqztTJswUDidtJvawt0qDnSGBGB3z9H9lMcWIpa7Yk3gGnPQuwWnYz4xK0WKdQHAaSOMDPaS4L9kcGJf35vubUHAOgapkg(0aWcnAbby0Ibn0a3a3qnudGh1rEFXQ7i4gQHAa8DbWh4HH9lagzFawuZUuaw0nnaC2aS49oDhayfxv2xwWnWnudGfpqDwcxmfGHyK9zawU6qEbWq8v2klapkKsEOuaCV9Df5VocSbGDzLBRa4TnOYcU5Yk3wzhEwU6qEj80iigwfjFhPa3a3qnaw8a1zjCXuaMfGFubWvQZaCfXaSlR9b4ubWUaEACidBb3CzLBRM0ZMgqEMJfYGBUSYTvcpnIa(NoKHfSDDEIYEffu1NJ5afwFi46lCxckGBG5jXpgb3HjfxjIGYTPzLBpjxb427Y25vufqCEoemcILYEfPcuy2(SUNTc9rlOaUbMdSrXtZmd4MlRCBLWtJO7)VAFUPcMitqWiiwOT5Gkkzd1(SUNTcL7N9ssTmQZs4IJhxtiyeel02CqfLSHAFw3ZwHY0d3STsDouB4(4XHGrqSqBZbvuYgQ9zDpBfktAEjPcl31qxTTfYSlL(zpMF7ZofvZwUH7Ycz2Ls)ShZVLBhYW0zrtJ4XHGrqSqBZbvuYgQvvUCmkZOX8hUtzyy1YVLYiPml0NqlgWnxw52kHNgr6gtWLvUDWKQsW215j9SYlVYTfuvFkRjHemrMkVhN9v84zlx9SVcux3V4Wmk0JbCd1a4t2sgGRigGh2k3gGL7AOR2gGJCfalJ8(IPccWA5y1yayfQAjaRnRiaw8ENUdGBUSYTvcpnYWw52cMitqWiiwQ3YSVcpCZbTSpSTfEaCZLvUTs4PrGvCilwxbU5Yk3wj80iWkoKfRly7680LlaBclsOI4as(Qk4puw8dU5Yk3wj80iVNkoqzNcU5Yk3wj80iqMDP0p7X8lyImjoiyeel1Bz2xHhU5Gw2h22cpmxtXjxb427Y25vufqCoECiyeelL9ksfOWS9zDpBf6IVgGBUSYTvcpnI0nMGlRC7GjvLGTRZtVlt3Oa3qnaEuufRpuaCTaSYLFIKsgGRigGVIwydaNiaSwgGhEMMYYHmOcG1Mgda3BbW0fG1HLraC2aCfXaCZ(dWiWf8ZGBUSYTvcpnIYLFIKY0nHbxwcMitAko5ka3Ex2oVIQaIZXJdbJGyPSxrQafMTpR7zRqF0AmhcgbXs9wM9v4HBoOL9HTTpR7zRqp2Z1CGl7v0cBSpR7zRqbT4Xl)V4YwPohQnqtgLljvdWnxw52kHNgr6gtWLvUDWKQsW215j5ka3ExkWnxw52kHNgbYSlnu(GGjYKMpCZOmH28hUzBL6CO2qSr)ssNlJ8)IvbK3LvUTBqFsi7DRr84pCZ2k15qTH7r)ssb3CzLBReEAeQ3YSVcpCZbTSpSTGjYK4GGrqSuVLzFfE4MdAzFyBl8a4MlRCBLWtJ8WDWLvUDWKQsW215j6RnapiyImbbJGyPElZ(k8Wnh0Y(W2w4bWnxw52kHNgr6gtWLvUDWKQsW215jv5n1Fk4g4MlRCBLvUcWT3LAIYEfPcuywWezsCqWiiwk7vKkqHzl8q84qWiiwk7vKkqHz7Z6E2kuID84qWiiw5N6QTdk5c)xSfEaCZLvUTYkxb427sj80ikT(RN9vqpvLGjYKCxdD12wQ3YSVcpCZbTSpST9zDpBf63p)H7uggwT8J(KMJQyUlnvdSXek)V4szvA9xp7RGEQQzVxdna3CzLBRSYvaU9UucpnIdT6z7vUDWK6qcMitIdcgbXs9wM9v4HBoOL9HTTWdGBUSYTvw5ka3ExkHNgbXWQi57iLGjYKAHnqztTdWQc2Wb(HhQC74XvlSbkBQvG14vA4GAncWDnxCqWiiwbwJxPHdQ1ia3vicw37nPw4bbZU4)HhQqQRZ00lEsibZU4)HhQWLzHCZKqcMDX)dpuHezsTWgOSPwbwJxPHdQ1ia3f4MlRCBLvUcWT3Ls4PrurUCSHdvehGBT7xrOsWez6HBgL7N)WDkddRw(rrOyIbCdCZLvUTYsFTb4HPA1Hu12SGjYeemcIfABoOIs2qTQYLJrFAM5pCZOpH28hUtzyy1YVLYiPml0NUpM5pCZi7FXw5N6QTdpCZbTSpSn4MlRCBLL(AdWdcpnIU))Q95MkyImPjemcIfABoOIs2qTpR7zRqz6HB2wPohQnCF84qWiiwOT5Gkkzd1(SUNTcLjnVKuHL7AOR22cz2Ls)ShZV9zNIQzl3WDzHm7sPF2J53YTdzy6SXwJ4X1ecgbXcTnhurjBOwv5YXOG2CnfNCfGBVlBZYFn7tJhhcgbX6qRE2ELBhmPoKfEqdn0y(d3PmmSA53szKuMf6Ofd4MlRCBLL(AdWdcpncKzxAaAtJGjYKmY)lwH(eAZF4MrbnWnxw52kl91gGheEAeb8pDidly768ue7Ffu1NJ5WpeOVwbfWnW8KMcnJWqWiiwQ3YSVcpCZbTSpSTfEywHIry1aBmHY)lUu2i2)kOQphZZwUH7YgX(xqp7J53YTdzy6SOPb4MlRCBLL(AdWdcpncL9kkOQphZcAYMds6uSNnYvflyImbbJGyHm7sdQOKnu7Z6E2kuUK04XF4oLHHvl)wkJKYSqzsa)thYW2i2)kOQphZHFiqFTZfNMLB4USqBZQAFDl3oKHPZL7AOR22cTnRQ91TpR7zRqbnna3CzLBRS0xBaEq4PrG2Mv1(6cMitpCNYWWQLF0NekMya3CzLBRS0xBaEq4PrGm7sdqBAe0KnhK0PypBKRkwWezsnWgtO8)IlLfYSlnaTPbD0a3CzLBRS0xBaEq4PrIy)RGQ(CmlyIm9WnBRuNd1gqdLljfCZLvUTYsFTb4bHNgHYEffu1NJzbtKPhUtzyy1YVLYiPmluMeW)0HmSnI9VcQ6ZXC4hc0x7CXPz5gUll02SQ2x3YTdzy6C5Ug6QTTqBZQAFD7Z6E2kuqtdWnxw52kl91gGheEAek7vuWBAGYshvcMitQb2ycL)xCPSu2ROG30aLLoQqhnWnWnxw52kREw5Lx52tc46d5NYaKzxQGjYue7MkYoiluMjM4X1uCx)cpmpIDtfzhKfkJE0AaUHAa8DULRE2xam119lgGFowcoFwN7cGtfaJ2mXYa8IaW6oQdWrSBQiawTMvqaEMyILb4fbG1DuhGJy3uraC2aSdWx)cpyb3CzLBRS6zLxELBl80iu2ROGQ(CmlyImLTC1Z(kqDD)Id3RqFkIDtfzLW)ZDbUHAaS4D7yTaydxaS3amJ6PQY(cGf1SlfGprjBOam93bl4MlRCBLvpR8YRCBHNgHYEffu1NJzbtKjLlahGm7sdQOKn05zlx9SVcux3V4Wmk0JzoemcIfYSlnOIs2qTWdZHGrqSqMDPbvuYgQ9zDpBfkczNz2ljfCZLvUTYQNvE5vUTWtJ8WnhkFqWezQ8EC2xZHGrqSpCZHYhS0vBppB5QN9vG66(fhUxHEe7MkYQ7O(SXyfcCZLvUTYQNvE5vUTWtJKsgAHBAaz)klyklyImfXUPISdYcLzI5U0eTyMfcgbXcz2LgurjBOw4bna3CzLBRS6zLxELBl80ikx(jskt3egCzjyImfXUPISdYcfXFM5dCzVIwyJ9zDpBfkZaUbU5Yk3wzFxMUrnbz2LgqGFujyImj31qxTTL6Tm7RWd3Cql7dBBF2POAUMItURHUABlKzxk9ZEm)2NDkQIhxCLB4USqMDP0p7X8B52HmmvdWnxw52k77Y0nkHNgbIFf)JZ(cCZLvUTY(UmDJs4Pr8x6nhgGnkwWezYLvkah4M1twH(eAXJ)WnJIqZF4oLHHvl)wkJKYSqF0XaU5Yk3wzFxMUrj80iM8kQubXZW0lDUlbtKjiyeelChTgufu1Z9vfzHha3CzLBRSVlt3OeEAeVLSQE3eKUXaU5Yk3wzFxMUrj80ii5ZqMDPGBUSYTv23LPBucpncKFfwKq9PCScCZLvUTY(UmDJs4Pr8x6nhQ9FUlbtKPhUtzyy1YVLYiPml0rlgWnWnxw52kRQ8M6pDIYEffu1NJzbtKPhUtzyy1YVLYiPmluMekM5AkUYnCxwOTzvTVULBhYW04XfNCxdD12wOTzvTVU9zNIQ4XHGrqSuVLzFfE4MdAzFyBl8GgGBUSYTvwv5n1FQWtJOC5NiPmDtyWLLGjY0ax2ROf2yFw3ZwHYLKolAGBOgQbWUSYTvwv5n1FQWtJaz2Ls)ShZVGjYK4GGrqSuVLzFfE4MdAzFyBl8a4gQHAaS4fEWKsVykahXpdWqS0HvmaxrmaRNvE5vUnaBsvbWpBswbWBdWL3JZ(AKYhN9fatDD)ITGBOgQbWUSYTvwv5n1FQWtJO7)VAFUPcMitqWiiwOT5Gkkzd1(SUNTcL7N9ssTmQZs4IJhxtiyeel02CqfLSHAFw3ZwHY0d3STsDouB4(4XHGrqSqBZbvuYgQ9zDpBfktAEjPcl31qxTTfYSlL(zpMF7ZofvZwUH7Ycz2Ls)ShZVLBhYW0zrtJ4XHGrqSqBZbvuYgQvvUCmk3RX8hUtzyy1YVLYiPml0NqlgWnxw52kRQ8M6pDkI9VcQ6ZXSGjYKCfGBVlBNxrvaX55u2ROG30aLLoQSvkhN91CnHGrqSu2RivGcZw4H5qWiiwk7vKkqHz7Z6E2kugTgGBUSYTvwv5n1FQWtJuRoKQ2MfmrMGGrqSqBZbvuYgQvvUCm6tZm)HBg9j0M)WDkddRw(TugjLzH(09XaU5Yk3wzvL3u)PcpnIU))Q95MkyImPjemcIfABoOIs2qTpR7zRqz6HB2wPohQnCF84qWiiwOT5Gkkzd1(SUNTcLjnVKuHL7AOR22cz2Ls)ShZV9zNIQzl3WDzHm7sPF2J53YTdzy6SXwJ4XHGrqSqBZbvuYgQvvUCmkJoECn1uCYvaU9USDEfvbeNJhhcgbXszVIubkmBFw3ZwH(mAmhcgbXcTnhurjBO2N19SvOi(AOX8hUtzyy1YVLYiPml0rlgWnxw52kRQ8M6pv4PrOSxrbv95ywWez6H7uggwT8BPmskZcLjb8pDidBPSxrbv95yoqH1hcU(c31CXPz5gUll02SQ2x3YTdzy6C5Ug6QTTqBZQAFD7Z6E2kuqtJ5Itt5ka3Exwb4UIq1pxURHUABRsR)6zFf0tvzFw3ZwHY9AaU5Yk3wzvL3u)PcpncKzxAaAtJGjYKmY)lwfqExw52Ub9jHS39CnHGrqSrS(QkxLkRQC5yuM0CM7snWgtO8)IlLfYSlnaTPrJ4XvdSXek)V4szHm7sdqBAqhnna3qnaowK)Jb4fbGf1SlfGPlRa4ElaEWBkRNY7Ir9IBQfCZLvUTYQkVP(tfEAeD)hhwKaKzxQGjYeLHGrqS6(poSibiZUulD12ZrYROk8SUNTcDX3od4MlRCBLvvEt9Nk80iu2ROG30aLLoQemrMGGrqSYp1vBhuYf(Vyl8W8YnCx2NnPkkKDaYSl1YTdzy68hUtzyy1YVLYiPml0fkgWnxw52kRQ8M6pv4PrG2Mv1(6cMitpCNYWWQLF0NekMya3CzLBRSQYBQ)uHNgra)thYWc2UopfX(xbv95yo8dckGBG5jnfAgHvdSXek)V4szJy)RGQ(CmpB5gUlBe7Fb9SpMFl3oKHPZIMgcUdtkUsebLBtZk3EsUcWT3LTZROkG48Ck7vuWBAGYshv2kLJZ(sqbCdmhyJIN0uOzewnWgtO8)IlLnI9VcQ6ZX8SLB4USrS)f0Z(y(TC7qgMolAAmRqw0a3CzLBRSQYBQ)uHNgHYEffu1NJzbtKjnF4oLHHvl)wkJKYSqzsa)thYW2i2)kOQphZHFqJ4Xl)V4YwPohQnqtgfHIbCZLvUTYQkVP(tfEAek7vuWBAGYshvcMitQb2ycL)xCPSu2ROG30aLLoQqF6EWnxw52kRQ8M6pv4PrIy)RGQ(CmlyIm9WnBRuNd1gInkxsk4MlRCBLvvEt9Nk80iu2ROG30aLLoQemrMGGrqSYp1vBhuYf(Vyl8q84LB4USVpK0aLLR(WQYk32YTdzyk4MlRCBLvvEt9Nk80iYTvW6dvUTGjYeemcIfABoOIs2qTpR7zRq)(zVKuWnxw52kRQ8M6pv4PrGm7sdqBAemrMKr(FXQaY7Yk32nOpjKvO5qWiiwOT5Gkkzd1(SUNTc97N9ssb3CzLBRSQYBQ)uHNgjI9VcQ6ZXSGjY0d3m6cnxZhUzBL6CO2W9OCjPXJdbJGyH2MdQOKnuRQC5y0f)5qWiiwOT5Gkkzd1(SUNTc9hUzBL6CO2W9cFjPAaU5Yk3wzvL3u)PcpnI)sV5qT)ZDjyIm9WDkddRw(TugjLzHoAXqooCfTp5Cs9rnalmalEcponjPifHa]] )

end