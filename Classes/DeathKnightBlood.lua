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


    spec:RegisterPack( "Blood", 20220319, [[dSKPobqiiv9ifs1LaQq2KI0NuirJIuXPiuTkfHxraZcs5wavXUO4xkIgMcXXiqlJq6zaLMgqLUgqX2GuX3aQQXbPsohqvADkKsAEqI7PO2hH4GavKfsQQhcur1evifxeOc6JkKsyKkKs0jviHwjK0lbQantGkk3esLYojvAPqQu9uatLq5RkKGXcubSxu(ljdgQdt1IvPht0Kr1Lr2meFgiJMuoTuRwHukVwHA2cDBb2TOFRQHRGJduHA5k9CknDjxxfBxq(obnEfs68KQSEfsPA(cQ9dAMGmXyaCViMUIoIOIocyfe8AeDebhbmOlgqP3aXagC5yheXaspGya6h)NZagC9IVZzIXaS)zLedaOdorV6pbNVosXaUNowJIj7Ya4ErmDfDerfDeWki41i6icocyaFgGDGKmDffmJWa0AoNs2LbWjRKbOF8FoepAiV0GyWbZgKwbrfDZxPgeli4fniw0revugqSTLLjgdiORgKx9NmXy6kitmgaL(nsCM(ma52fTTZa0ipwAMbzbXOaXGzeioCyiwhig9qmO9pdq8uiwJ8yPzgKfeJceJoOdelodWLv)jdiKhm0Blv34)CwX0vuMymak9BK4m9zaUS6pzaCYlnLT2EmXa4KvU9q1FYagft5h0jiiM7boicIxcC8PxkGYcIBlelkyahbXpceh4JkeRrES0Gy7hF0GyWmc4ii(rG4aFuHynYJLge3je7qmO9pdggGC7I22zaDk)GobP4EGdIuG1cXImdXAKhlnJ8SlLfRy6cwMymak9BK4m9zaUS6pzaCYlnLT2EmXa4KvU9q1FYagnFokliosfe7jetJABRobbX6h)NdXaAnf5qmF)bddqUDrB7maRhIu34)CLvRPihINcXDk)GobP4EGdIuGXcXIaXJaXtH47bbXCJ)ZvwTMICZzaINcX3dcI5g)NRSAnf5MLc8oTqmkqSGgWaXtaXGKCwX0fCzIXaO0VrIZ0Nbi3UOTDgq554obbXtH47bbXSNKuLpy4VWeINcXDk)GobP4EGdIuG1cXIaXAKhlntGpQq8eq8igbzaUS6pza7jjv5dSIPlyyIXaO0VrIZ0Nbi3UOTDgGg5XsZmiligfigmJaXGhiwhiw0rG4jG47bbXCJ)ZvwTMICZzaIfNb4YQ)Kb0s6(NKRq(T66WjwX0fDyIXaO0VrIZ0Nbi3UOTDgGg5XsZmiligfig8bdepfIhOYas7prZsbENwigfigmmaxw9NmaRl3gPLThvdUSyfRya8vO6mWeJPRGmXyau63iXz6Za(bgGLQgHb4YQ)KbeY32VrIbeYxv6bedqJ8Tu2A7XKAhu8vidqUDrB7ma5hIsplt2G0kfItq8uiMtEPP8KR4K01ZuTCCNGyaH84Huu0smaDGybbdelaeFpiigUNYobP2tskHKp8P5maXtaXcocelaeBhOyuv(cIkRrJ8Tu2A7XeepbexEKYYOr(w3L8X0AO0VrIdXtaXIcXIdXtaXcAeLbeYJhIbOdeliyGybG47bbXW9u2ji1EssjK8HpnNbiEciwWrGybGy7afJQYxquznAKVLYwBpMG4jG4YJuwgnY36UKpMwdL(nsCiEciwuiwCwX0vuMymak9BK4m9zaYTlABNbOdeJEiw(HO0ZYKKC)4VCioCyi(Eqqm(9d60R(tvSdUMZaeloepfI1bIVheeZ9tsz1AkYnlf4DAHyuMH49KKP6asvVcSqC4Wq89GGyUFskRwtrUzPaVtleJYmeRdedsYHybGy5)r(lmn34)C(25yAnl5C9G4jG4YJuwMB8FoF7CmTgk9BK4q8eqm4cXIdXHddX3dcI5(jPSAnf5gB5YXqmkqmyHyXH4Pq8EYwQgEH0A4esl7cIfbIfDegGlR(tgqGV7lCPKZkMUGLjgdGs)gjotFgGC7I22zasnFbrwiwKziwugGlR(tgWn(pxD)oYkMUGltmgaL(nsCM(ma52fTTZa0bI3t2s1WlKwdNqAzxqmkZqCiFB)gjdN8stzRThtk(jyq5b)jliEkeJEiwhi(EqqmCpLDcsTNKucjF4tZsbENwigLziwuiEkexEKYYC)KS1Vbgk9BK4q8uiw(FK)ctZ9tYw)gywkW70cXOaXIcXIdXIdXHddX7jBPA4fsRHtiTSligLzioKVTFJKrJ8Tu2A7XKAhu8vidWLv)jdGtEPPS12JjwX0fmmXyau63iXz6Za(bgGLkgGlR(tgqiFB)gjgqipEigG8drPNLjBqALcXjiEkeZjV0uEYvCs66zQwoUtqq8uiwhi(EqqmCYlnRIFiZzaINcX3dcIHtEPzv8dzwkW70cXOaXOdelodiKVQ0digaN8sZQ4hsDpiikPgjhZkMUOdtmgaL(nsCM(ma52fTTZac5B73iz4KxAwf)qQ7bbrj1i5yioCyiEpjzQoGu1RaxigfigKKdXHddX7jBPA4fsRHtiTSliweioKVTFJKrJ8Tu2A7XKAhu8vidWLv)jdqJ8Tu2A7XeRyfdq(HO0ZYYeJPRGmXyau63iXz6ZaKBx02oda9q89GGy4KxAwf)qMZaehomeFpiigo5LMvXpKzPaVtleJcedUqC4Wq89GGyKBhy)uzL)zbrMZadWLv)jdGtEPzv8dXkMUIYeJbqPFJeNPpdqUDrB7ma5)r(lmnCpLDcsTNKucjF4tZsbENwiweigSq8uiEpzlvdVqAHyrMHyDGyW7iqm4bI1bITdumQkFbrL1yf6BqNGubTTG4jGyWcXIdXIZaCz1FYaSc9nOtqQG2wSIPlyzIXaO0VrIZ0Nbi3UOTDga6H47bbXW9u2ji1EssjK8HpnNbgGlR(tgGF)Go9Q)uf7GlRy6cUmXyau63iXz6ZaKBx02odW(N4TtUz4yRtKu0EgQ(tdL(nsCioCyi2(N4TtUj0h9QJKY(Xquwgk9BK4q8uig9q89GGyc9rV6iPSFmeLLs7e453CZzGb0zr7EgkvJWaS)jE7KBc9rV6iPSFmeLfdOZI29muQoiG4TxedqqgGlR(tgasKSAY1rkgqNfT7zOuGI)1JmabzftxWWeJbqPFJeNPpdqUDrB7ma5)r(lmnCpLDcsTNKucjF4tZsbENwigfigSqC4Wqm6H47bbXW9u2ji1EssjK8HpnNbgGlR(tgGvZLJJKQ0i1jf(BPPhRyfdyyj5hC9IjgtxbzIXaO0VrIZ0NbWjRC7HQ)KbaoCuj5PioeFjKFjiw(bxVG4lbQtRbIbNKsAOSqC(j4rZ3aKteIDz1FAH4pJ6zyaUS6pzairYQjxhPyfRya2YtUVCMymDfKjgdGs)gjotFgGC7I22za7jBPA4fsRHtiTSligLziwWrG4PqSoqm6H4YJuwM7NKT(nWqPFJehIdhgIrpel)pYFHP5(jzRFdml5C9G4WHH47bbXW9u2ji1EssjK8HpnNbiwCgGlR(tgaN8stzRThtSIPROmXyau63iXz6ZaKBx02odyGkdiT)enlf4DAHyuGyqsoepbelkdWLv)jdW6YTrAz7r1GllwX0fSmXyau63iXz6ZaKBx02odq(HO0ZYKniTsH4eepfI5KxAkp5kojD9mvlh3jiiEkeRdeFpiigo5LMvXpK5maXtH47bbXWjV0Sk(Hmlf4DAHyuGy0bIfNb4YQ)KbOr(wkBT9yIvmDbxMymak9BK4m9zaYTlABNbCpiiM7NKYQ1uKBSLlhdXImdXGpepfI3tsqSiZqSOq8uig9qS8drPNLjeLLMEldWLv)jdO(GRT(KyftxWWeJbqPFJeNPpdqUDrB7maDG47bbXC)KuwTMICZsbENwigLziEpjzQoGu1RalehomeFpiiM7NKYQ1uKBwkW70cXOmdX6aXGKCiwaiw(FK)ctZn(pNVDoMwZsoxpiEciU8iLL5g)NZ3ohtRHs)gjoepbedUqS4qC4Wq89GGyUFskRwtrUXwUCmeJceJoqC4WqSoqSoqm6Hy5hIsplt2G0kfItqC4Wq89GGy4KxAwf)qMLc8oTqSiqmyGyXH4Pq89GGyUFskRwtrUzPaVtleJced(qS4qS4q8uiEpzlvdVqAnCcPLDbXImdXccggGlR(tgqGV7lCPKZkMUOdtmgaL(nsCM(ma52fTTZa2t2s1WlKwdNqAzxqmkZqCiFB)gjdN8stzRThtk(jyq5b)jliEkeJEiwhiU8iLL5(jzRFdmu63iXH4PqS8)i)fMM7NKT(nWSuG3PfIrbIffIfhINcXOhI1bILFik9SmHOS00BH4PqS8)i)fMgRqFd6eKkOTLzPaVtleJcedwiwCgGlR(tgaN8stzRThtSIPl4ZeJbqPFJeNPpdqUDrB7maPMVGiRczDz1F6riwKziwqd6cINcX6aX3dcIrJcEB522ASLlhdXOmdX6aXGbIbpqSDGIrv5liQSMB8FU6(DeIfhIdhgITdumQkFbrL1CJ)Zv3VJqSiqSOqS4maxw9NmGB8FU6(DKvmDrxmXyau63iXz6ZaCz1FYac8DS6ru34)CgaNSYThQ(tga6MVJH4hbI1p(phI5pzH48liEWtof0sWdnQfLCddqUDrB7maoDpiiMaFhREe1n(p3WFHjepfIrAqALAPaVtlelced(gWWkMUGxMymak9BK4m9zaYTlABNbCpiig52b2pvw5FwqK5maXtH4YJuwMLITvt1P6g)NBO0VrIdXtH49KTun8cP1WjKw2felcel4imaxw9Nmao5LMYtUItsxpwX0vWryIXaO0VrIZ0Nbi3UOTDgWEYwQgEH0cXImdXcoYiq8uig9qS8drPNLjeLLMEldWLv)jd4(jzRFdyftxbfKjgdGs)gjotFgWpWaSu1imaxw9NmGq(2(nsmGq(QspGyaAKVLYwBpMu7adqUDrB7ma5hIsplt2G0kfItq8uiMtEPP8KR4K01ZuTCCNGyaH84Huu0smaDGybbdelaeBhOyuv(cIkRrJ8Tu2A7XeepbexEKYYOr(w3L8X0AO0VrIdXtaXIcXIdXtaXcAeLbeYJhIbOdeliyGybGy7afJQYxquznAKVLYwBpMG4jG4YJuwgnY36UKpMwdL(nsCiEciwuiwCwX0vqrzIXaO0VrIZ0Nbi3UOTDgGoq8EYwQgEH0A4esl7cIrzgId5B73iz0iFlLT2EmP2biwCioCyiU8fevMQdiv9kEtqmkqSGJWaCz1FYa4KxAkBT9yIvmDfeSmXyau63iXz6ZaKBx02odWoqXOQ8fevwdN8st5jxXjPRhelYmedwgGlR(tgaN8st5jxXjPRhRy6ki4YeJbqPFJeNPpdqUDrB7mG9KKP6asvVcCHyuGyqsodWLv)jdqJ8Tu2A7XeRy6kiyyIXaO0VrIZ0Nbi3UOTDgW9GGyKBhy)uzL)zbrMZaehomexEKYYS(qZvCs(bdVTR(tdL(nsCgGlR(tgaN8st5jxXjPRhRy6ki6WeJbqPFJeNPpdqUDrB7mG7bbXC)KuwTMICZsbENwiweigSq8eqmijNb4YQ)Kbi)0EcgQ(twX0vqWNjgdGs)gjotFgGC7I22zasnFbrwfY6YQ)0JqSiZqSGgbH4Pq89GGyUFskRwtrUzPaVtlelcedwiEcigKKZaCz1FYaUX)5Q73rwX0vq0ftmgaL(nsCM(ma52fTTZa2tsqSiqSGq8uiwhiEpjzQoGu1RaleJcedsYH4WHH47bbXC)KuwTMICJTC5yiweig8H4Pq89GGyUFskRwtrUzPaVtlelceVNKmvhqQ6vGfIfaIbj5qS4maxw9NmanY3szRThtSIPRGGxMymak9BK4m9zaYTlABNbSNSLQHxiTgoH0YUGyrGyrhHb4YQ)Kb4R0tsv)UuwSIvmG1LThTmXy6kitmgaL(nsCM(ma52fTTZaK)h5VW0W9u2ji1EssjK8Hpnl5C9G4PqSoqm6Hy5)r(lmn34)C(25yAnl5C9G4WHHy0dXLhPSm34)C(25yAnu63iXHyXzaUS6pza34)CfYz1JvmDfLjgdWLv)jd4sRL2XDcIbqPFJeNPpRy6cwMymak9BK4m9zaYTlABNb4YQdrkkPGMSqSiZqSOqC4Wq8EscIrbIfeINcX7jBPA4fsRHtiTSliweigDgHb4YQ)Kb4R0tsnCIwIvmDbxMymak9BK4m9zaYTlABNbCpiiMtQ9r9u2APeuPzodmaxw9NmGydsRSQrBhoOaklwX0fmmXyaUS6pzaEkjBTEuj9yKbqPFJeNPpRy6IomXyaUS6pzai9s34)CgaL(nsCM(SIPl4ZeJb4YQ)KbCDqQhrvBlhBzau63iXz6ZkMUOlMymak9BK4m9zaYTlABNbSNSLQHxiTgoH0YUGyrGyrhHb4YQ)Kb4R0tsv)UuwSIvma(kuDguHOS00BzIX0vqMymak9BK4m9za)adWsvJWaCz1FYac5B73iXac5Rk9aIbuFW1wFsQ7NKs(NSyaYTlABNbCpiigUNYobP2tskHKp8P5mWac5XdPOOLyaGHbeYJhIba(SIPROmXyau63iXz6ZaKBx02od4Eqqm3pjLvRPi3ylxogIfzgId5B73izQp4ARpj19tsj)twq8uiEpjbXImdXIcXtH49KTun8cP1WjKw2felced2ryaUS6pza1hCT1NeRy6cwMymak9BK4m9zaYTlABNbOdeFpiiM7NKYQ1uKBwkW70cXOmdX7jjt1bKQEfyH4WHH47bbXC)KuwTMICZsbENwigLziwhigKKdXcaXY)J8xyAUX)58TZX0AwY56bXtaXLhPSm34)C(25yAnu63iXH4jGyWfIdhgIVheeZ9tsz1AkYn2YLJHyuGyWaXIdXIdXtH49KTun8cP1WjKw2felcel6imaxw9NmGaF3x4sjNvmDbxMymak9BK4m9zaYTlABNbi18fezHyrMHyrzaUS6pza34)C197iRy6cgMymak9BK4m9zaYTlABNbSNSLQHxiTgoH0YUGyuMH4q(2(nsgo5LMYwBpMu8tWGYd(twq8uig9qSoqC5rklZ9tYw)gyO0VrIdXtHy5)r(lmn3pjB9BGzPaVtleJcelkelodWLv)jdGtEPPS12JjwX0fDyIXaO0VrIZ0Nbi3UOTDgWEYwQgEH0cXImdXcoYiq8ui(EqqmwH(g0jivqBlZzGb4YQ)KbC)KS1VbSIPl4ZeJbqPFJeNPpd4hyawQyaUS6pzaH8T9BKyaH84Hya6aXccgiwai(EqqmCpLDcsTNKucjF4tZzaINaIfCeiwai2oqXOQ8fevwJg5BPS12JjiEciU8iLLrJ8TUl5JP1qPFJehINaIffIfNbeYxv6bedqJ8Tu2A7XKAhu8vOkeLLMElRy6IUyIXaO0VrIZ0Nbi3UOTDgWEsYuDaPQxbUqmkqmijhIdhgI3t2s1WlKwdNqAzxqSiZqCiFB)gjJg5BPS12Jj1oO4Rqvikln9wgGlR(tgGg5BPS12JjwXkgaNq8tSyIX0vqMymak9BK4m9zaCYk3EO6pzaGdhvsEkIdXuiA1dIRoGG4sJGyxw)cXTfI9qEh9BKmmaxw9NmGGo5kKLOr7eRy6kktmgaL(nsCM(mGFGbyPQryaUS6pzaH8T9BKyaH8vLEaXa4KxAkBT9ysXpbdkp4pzXaKBx02odq(HO0ZYKniTsH4eepfIVheedN8sZQ4hYSuG3PfIfbIrhgqipEiffTedamGHbeYJhIba(JWkMUGLjgdGs)gjotFgGC7I22za3dcI5(jPSAnf5MLc8oTqmkqmyH4jGyqsUHgvsEkcIdhgI1bIVheeZ9tsz1AkYnlf4DAHyuMH49KKP6asvVcSqC4Wq89GGyUFskRwtrUzPaVtleJYmeRdedsYHybGy5)r(lmn34)C(25yAnl5C9G4jG4YJuwMB8FoF7CmTgk9BK4q8eqSOqS4qC4Wq89GGyUFskRwtrUXwUCmeJcedgiwCiEkeVNSLQHxiTgoH0YUGyrMHyrhHb4YQ)Kbe47(cxk5SIPl4YeJbqPFJeNPpdqUDrB7mGYZXDccIdhgI7u(bDcsX9ahePaJfIfbIhHbyRTLftxbzaUS6pzaspgvUS6pvX2wmGyBlv6bediORgKx9NSIPlyyIXaO0VrIZ0Nbi3UOTDgW9GGy4Ek7eKApjPes(WNMZadGtw52dv)jdaOtjbXLgbXdF1FcXY)J8xycXAUfILAEcI4ObXcPrzmcXw9sjelSlniE0GUpkWaCz1FYag(Q)KvmDrhMymaxw9NmGJLuDrbwgaL(nsCM(SIPl4ZeJbqPFJeNPpdi9aIbaYdrr1JOknsH0RTu(E7IwgGlR(tgaipefvpIQ0ifsV2s57TlAzftx0ftmgGlR(tgW6TLuCY5mak9BK4m9zftxWltmgaL(nsCM(ma52fTTZaqpeFpiigUNYobP2tskHKp8P5maXtHyDGy0dXYpeLEwMSbPvkeNG4WHH47bbXWjV0Sk(Hmlf4DAHyrGyWhIfNb4YQ)KbCJ)Z5BNJPLvmDfCeMymak9BK4m9zaUS6pzab(UVWLsodGtw52dv)jdaDZ39fUuYH4pH4HtmcXnceRlj3p(lhI7eI)Ltlexped64RNfrq8BThF1dI5NTtqqCPrqmsV2cIhnO7JcqSWU0GyWjWzma52fTTZaKFik9Smjj3p(lhINcX3dcI5(jPSAnf5gB5YXqmkZq8iSIPRGcYeJbqPFJeNPpdWLv)jdq6XOYLv)Pk22IbeBBPspGyaRlBpAzftxbfLjgdGs)gjotFgGlR(tgG1LBJ0Y2JQbxwmaozLBpu9NmaWPQOGHcIRhITUCBKwsqCPrqmiT)eH4gbIfsq8Ws8ww(nQhelSJrio)cI5pehCKAqCNqCPrqCs(cXiN6SedqUDrB7maDGy0dXYpeLEwMSbPvkeNG4WHH47bbXWjV0Sk(Hmlf4DAHyrGy0bIfhINcXOhIVheed3tzNGu7jjLqYh(0CgG4PqSoq8avgqA)jAwkW70cXOaXIcXHddXLVGOYuDaPQxXBcIrbIbj5qS4SIPRGGLjgdGs)gjotFgGlR(tgG0JrLlR(tvSTfdi22sLEaXaKFik9SSSIPRGGltmgaL(nsCM(ma52fTTZa0bI3tsqmkZqSOq8uiEpjzQoGu1RaxiweigKKdXtHyPMVGiRczDz1F6riwKziwqd6cIfhIdhgI3tsMQdiv9kWcXIaXGKCgGlR(tgWn(pxv(aRy6kiyyIXaO0VrIZ0Nbi3UOTDga6Hy5hIspltikln9wgGlR(tga3tzNGu7jjLqYh(KvmDfeDyIXaO0VrIZ0Nbi3UOTDgW9GGy4Ek7eKApjPes(WNMZaepfIrpel)qu6zzcrzPP3YaCz1FYa2tQCz1FQITTyaX2wQ0digaFfQodSIPRGGptmgaL(nsCM(ma52fTTZaKFik9SmHOS00BH4PqS8)i)fMgRqFd6eKkOTLzjNRhepfI3t2s1WlKwiwKziwhig8ocedEGyDGy7afJQYxquznwH(g0jivqBliEcigSqS4qS4maxw9NmaUNYobP2tskHKp8jRy6ki6IjgdGs)gjotFgGC7I22zaYpeLEwMquwA6Tq8uiwhi(EqqmCpLDcsTNKucjF4tZzaIdhgIVheeJvOVbDcsf02YCgGyXzaUS6pza7jvUS6pvX2wmGyBlv6bedGVcvNbvikln9wwX0vqWltmgaL(nsCM(maxw9NmaPhJkxw9NQyBlgqSTLk9aIbylp5(YzfRyfdieT2(tMUIoIOIocyfe8zac9n7eKLbmkaoHUR7OOUJwmAfIHyX0iiUdg(TGyKFH4rP8drPNLDucXlbo(0lXHy7hqqSFQpWlIdXsnpbrwdevWzDsqm4oAfIbN)ziAlIdXJs7FI3o5gWbgLqC9q8O0(N4TtUbCadL(ns8rjeRJOJQ4giQquhfdg(TioeJUGyxw9NqCSTL1arLb4Ns7xgaqhaohIfaIhTKg3XMbmSpshjgWOdX6h)NdXJgYlnigCWSbPvquhDigDZxPgeli4fniw0revuiQquhDigC4OsYtrCi(si)sqS8dUEbXxcuNwdedojL0qzH48tWJMVbiNie7YQ)0cXFg1Zar1Lv)P1mSK8dUEjW8KirYQjxhPGOcrD0HyWHJkjpfXHykeT6bXvhqqCPrqSlRFH42cXEiVJ(nsgiQUS6pTZbDYvilrJ2jiQUS6pTcmpziFB)gj0spGM5KxAkBT9ysXpbdkp4pzHwipEOzWFe0(HzlvncAYp5D1Fol)qu6zzYgKwPqCA69GGy4KxAwf)qMLc8oTIGoOfYJhsrrlndgWar1Lv)PvG5jd8DFHlLC0AK57bbXC)KuwTMICZsbENwua7eGKCdnQK8uu4W6CpiiM7NKYQ1uKBwkW70IY8EsYuDaPQxb2WHVheeZ9tsz1AkYnlf4DArzwhqsUaY)J8xyAUX)58TZX0AwY56nr5rklZn(pNVDoMwdL(ns8jev8WHVheeZ9tsz1AkYn2YLJrbmIpDpzlvdVqAnCcPLDjYSOJar1Lv)PvG5jLEmQCz1FQITTql9aAoORgKx9NOzRTL1SGO1iZLNJ7eu4WDk)GobP4EGdIuGXkYiquhDigOtjbXLgbXdF1FcXY)J8xycXAUfILAEcI4ObXcPrzmcXw9sjelSlniE0GUpkar1Lv)PvG5jh(Q)eTgz(EqqmCpLDcsTNKucjF4tZzaIQlR(tRaZtESKQlkWcr1Lv)PvG5jpws1ffGw6b0mipefvpIQ0ifsV2s57TlAHO6YQ)0kW8KR3wsXjNdr1Lv)PvG5jVX)58TZX0IwJmJ(7bbXW9u2ji1EssjK8HpnNHP6GE5hIsplt2G0kfItHdFpiigo5LMvXpKzPaVtRiGV4quhDigDZ39fUuYH4pH4HtmcXnceRlj3p(lhI7eI)Ltlexped64RNfrq8BThF1dI5NTtqqCPrqmsV2cIhnO7JcqSWU0GyWjWzquDz1FAfyEYaF3x4sjhTgzw(HO0ZYKKC)4V8P3dcI5(jPSAnf5gB5YXOmpcevxw9NwbMNu6XOYLv)Pk22cT0dO51LThTquhDigCQkkyOG46HyRl3gPLeexAeeds7priUrGyHeepSeVLLFJ6bXc7yeIZVGy(dXbhPge3jexAeeNKVqmYPolbr1Lv)PvG5jTUCBKw2Eun4YcTgzwh0l)qu6zzYgKwPqCkC47bbXWjV0Sk(Hmlf4DAfbDeFk6Vheed3tzNGu7jjLqYh(0CgMQZavgqA)jAwkW70IIOHdx(cIkt1bKQEfVjuaj5Idr1Lv)PvG5jLEmQCz1FQITTql9aAw(HO0ZYcr1Lv)PvG5jVX)5QYhqRrM1zpjHYSOt3tsMQdiv9kWveqs(uPMVGiRczDz1F6rrMf0GUepC49KKP6asvVcSIasYHO6YQ)0kW8KCpLDcsTNKucjF4t0AKz0l)qu6zzcrzPP3cr1Lv)PvG5j3tQCz1FQITTql9aAMVcvNb0AK57bbXW9u2ji1EssjK8HpnNHPOx(HO0ZYeIYstVfIQlR(tRaZtY9u2ji1EssjK8HprRrMLFik9SmHOS00BNk)pYFHPXk03GobPcABzwY56nDpzlvdVqAfzwhW7iGhDSdumQkFbrL1yf6BqNGubTTMaSIloevxw9NwbMNCpPYLv)Pk22cT0dOz(kuDguHOS00BrRrMLFik9SmHOS00BNQZ9GGy4Ek7eKApjPes(WNMZq4W3dcIXk03GobPcABzodIdr1Lv)PvG5jLEmQCz1FQITTql9aA2wEY9LdrfIQlR(tRr(HO0ZYoZjV0Sk(HqRrMr)9GGy4KxAwf)qMZq4W3dcIHtEPzv8dzwkW70Ic4go89GGyKBhy)uzL)zbrMZaevxw9NwJ8drPNLvG5jTc9nOtqQG2wO1iZY)J8xyA4Ek7eKApjPes(WNMLc8oTIa2P7jBPA4fsRiZ6aEhb8OJDGIrv5liQSgRqFd6eKkOT1eGvCXHO6YQ)0AKFik9SScmpPF)Go9Q)uf7GlAnYm6Vheed3tzNGu7jjLqYh(0CgGO6YQ)0AKFik9SScmpjsKSAY1rk0AKz7FI3o5MHJTorsr7zO6pdh2(N4TtUj0h9QJKY(Xquwtr)9GGyc9rV6iPSFmeLLs7e453CZzaTolA3ZqP6GaI3ErZcIwNfT7zOuGI)1JZcIwNfT7zOunYS9pXBNCtOp6vhjL9JHOSGO6YQ)0AKFik9SScmpPvZLJJKQ0i1jf(BPPhAnYS8)i)fMgUNYobP2tskHKp8PzPaVtlkGnCy0FpiigUNYobP2tskHKp8P5marfIQlR(tRHVcvNH5q(2(nsOLEanRr(wkBT9ysTdk(keTqE8qZ6iiye4EqqmCpLDcsTNKucjF4tZzycbhra7afJQYxquznAKVLYwBpMMO8iLLrJ8TUl5JP1qPFJeFcrfhTFy2svJGM8tEx9NZYpeLEwMSbPvkeNMYjV0uEYvCs66zQwoUtqOfYJhsrrlnRJGGrG7bbXW9u2ji1EssjK8HpnNHjeCebSdumQkFbrL1Or(wkBT9yAIYJuwgnY36UKpMwdL(ns8jev8je0ikevxw9NwdFfQodcmpzGV7lCPKJwJmRd6LFik9Smjj3p(lpC47bbX43pOtV6pvXo4AodIpvN7bbXC)KuwTMICZsbENwuM3tsMQdiv9kWgo89GGyUFskRwtrUzPaVtlkZ6asYfq(FK)ctZn(pNVDoMwZsoxVjkpszzUX)58TZX0AO0VrIpb4kE4W3dcI5(jPSAnf5gB5YXOawXNUNSLQHxiTgoH0YUer0rGO6YQ)0A4Rq1zqG5jVX)5Q73r0AKzPMVGiRiZIcr1Lv)P1WxHQZGaZtYjV0u2A7XeAnYSo7jBPA4fsRHtiTSluMd5B73iz4KxAkBT9ysXpbdkp4pznf96CpiigUNYobP2tskHKp8PzPaVtlkZIoT8iLL5(jzRFdmu63iXNk)pYFHP5(jzRFdmlf4DArruXfpC49KTun8cP1WjKw2fkZH8T9BKmAKVLYwBpMu7GIVcHO6YQ)0A4Rq1zqG5jd5B73iHw6b0mN8sZQ4hsDpiikPgjhJwipEOz5hIsplt2G0kfItt5KxAkp5kojD9mvlh3jOP6Cpiigo5LMvXpK5mm9EqqmCYlnRIFiZsbENwuqhXHO6YQ)0A4Rq1zqG5j1iFlLT2EmHwJmhY32VrYWjV0Sk(Hu3dcIsQrYXHdVNKmvhqQ6vGlkGK8WH3t2s1WlKwdNqAzxIeY32VrYOr(wkBT9ysTdk(keIkevxw9NwdFfQodQquwA6TZH8T9BKql9aAU(GRT(Ku3pjL8pzHwipEOzWhTFy2svJGM8tEx9NZ3dcIH7PStqQ9KKsi5dFAodOfYJhsrrlndgiQUS6pTg(kuDguHOS00BfyEY6dU26tcTgz(Eqqm3pjLvRPi3ylxowK5q(2(nsM6dU26tsD)KuY)K109KKiZIoDpzlvdVqAnCcPLDjcyhbIQlR(tRHVcvNbvikln9wbMNmW39fUuYrRrM15Eqqm3pjLvRPi3SuG3PfL59KKP6asvVcSHdFpiiM7NKYQ1uKBwkW70IYSoGKCbK)h5VW0CJ)Z5BNJP1SKZ1BIYJuwMB8FoF7CmTgk9BK4taUHdFpiiM7NKYQ1uKBSLlhJcyex8P7jBPA4fsRHtiTSlreDeiQUS6pTg(kuDguHOS00BfyEYB8FU6(DeTgzwQ5liYkYSOquDz1FAn8vO6mOcrzPP3kW8KCYlnLT2EmHwJmVNSLQHxiTgoH0YUqzoKVTFJKHtEPPS12Jjf)emO8G)K1u0Rt5rklZ9tYw)gyO0VrIpv(FK)ctZ9tYw)gywkW70IIOIdr1Lv)P1WxHQZGkeLLMERaZtE)KS1VbO1iZ7jBPA4fsRiZcoYitVheeJvOVbDcsf02YCgGO6YQ)0A4Rq1zqfIYstVvG5jd5B73iHw6b0Sg5BPS12Jj1oO4Rqvikln9w0c5XdnRJGGrG7bbXW9u2ji1EssjK8HpnNHjeCebSdumQkFbrL1Or(wkBT9yAIYJuwgnY36UKpMwdL(ns8jevCiQUS6pTg(kuDguHOS00BfyEsnY3szRThtO1iZ7jjt1bKQEf4IcijpC49KTun8cP1WjKw2LiZH8T9BKmAKVLYwBpMu7GIVcvHOS00BHOcr1Lv)P1e0vdYR(Z5qEWqVTuDJ)ZrRrM1ipwAMbzHcygjCyDqpO9pdt1ipwAMbzHc6GoIdrD0H4rXu(bDccI5EGdIG4LahF6LcOSG42cXIcgWrq8JaXb(OcXAKhlni2(XhnigmJaocIFeioWhviwJ8yPbXDcXoedA)ZGbIQlR(tRjORgKx9NcmpjN8stzRThtO1iZDk)GobP4EGdIuG1kYSg5XsZip7szbrD0H4rZNJYcIJubXEcX0O22QtqqS(X)5qmGwtroeZ3FWar1Lv)P1e0vdYR(tbMNKtEPPS12Jj0AKzRhIu34)CLvRPiFANYpOtqkUh4GifySImY07bbXCJ)ZvwTMICZzy69GGyUX)5kRwtrUzPaVtlkcAaZeGKCiQUS6pTMGUAqE1FkW8K7jjv5dO1iZLNJ7e007bbXSNKuLpy4VWCANYpOtqkUh4GifyTIOrES0mb(OoXigbHO6YQ)0Ac6Qb5v)PaZt2s6(NKRq(T66Wj0AKznYJLMzqwOaMrap6i6itCpiiMB8FUYQ1uKBodIdr1Lv)P1e0vdYR(tbMN06YTrAz7r1Gll0AKznYJLMzqwOa(Gz6avgqA)jAwkW70IcyGOcr1Lv)P1SUS9OD(g)NRqoREO1iZY)J8xyA4Ek7eKApjPes(WNMLCUEt1b9Y)J8xyAUX)58TZX0AwY56fom6lpszzUX)58TZX0AO0VrIloevxw9NwZ6Y2JwbMN8sRL2XDccIQlR(tRzDz7rRaZt6R0tsnCIwcTgz2LvhIuusbnzfzw0WH3tsOi409KTun8cP1WjKw2LiOZiquDz1FAnRlBpAfyEYydsRSQrBhoOakl0AK57bbXCsTpQNYwlLGknZzaIQlR(tRzDz7rRaZt6PKS16rL0JriQUS6pTM1LThTcmpjsV0n(phIQlR(tRzDz7rRaZtEDqQhrvBlhBHO6YQ)0Awx2E0kW8K(k9Ku1VlLfAnY8EYwQgEH0A4esl7serhbIkevxw9NwJT8K7lFMtEPPS12Jj0AK59KTun8cP1WjKw2fkZcoYuDqF5rklZ9tYw)gyO0VrIhom6L)h5VW0C)KS1VbMLCUEHdFpiigUNYobP2tskHKp8P5mioevxw9NwJT8K7lxG5jTUCBKw2Eun4YcTgzEGkdiT)enlf4DArbKKpHOquh9rhIDz1FAn2YtUVCbMN8g)NZ3ohtlAnYm6Vheed3tzNGu7jjLqYh(0CgGOo6JoepAodXw6fXHynAji(ss)yjiU0iioORgKx9NqCSTfeVuSjle)jexEoUtqtw(4obbXCpWbrgiQJ(OdXUS6pTgB5j3xUaZtg47(cxk5O1iZ3dcI5(jPSAnf5MLc8oTOa2jaj5gAuj5POWH15Eqqm3pjLvRPi3SuG3PfL59KKP6asvVcSHdFpiiM7NKYQ1uKBwkW70IYSoGKCbK)h5VW0CJ)Z5BNJP1SKZ1BIYJuwMB8FoF7CmTgk9BK4tiQ4HdFpiiM7NKYQ1uKBSLlhJcyfF6EYwQgEH0A4esl7sKzrhbIQlR(tRXwEY9LpRr(wkBT9ycTgzw(HO0ZYKniTsH40uo5LMYtUItsxpt1YXDcAQo3dcIHtEPzv8dzodtVheedN8sZQ4hYSuG3Pff0rCiQUS6pTgB5j3xUaZtwFW1wFsO1iZ3dcI5(jPSAnf5gB5YXImd(t3tsIml6u0l)qu6zzcrzPP3cr1Lv)P1ylp5(YfyEYaF3x4sjhTgzwN7bbXC)KuwTMICZsbENwuM3tsMQdiv9kWgo89GGyUFskRwtrUzPaVtlkZ6asYfq(FK)ctZn(pNVDoMwZsoxVjkpszzUX)58TZX0AO0VrIpb4kE4W3dcI5(jPSAnf5gB5YXOGoHdRJoOx(HO0ZYKniTsH4u4W3dcIHtEPzv8dzwkW70kcyeF69GGyUFskRwtrUzPaVtlkGV4IpDpzlvdVqAnCcPLDjYSGGbIQlR(tRXwEY9LlW8KCYlnLT2EmHwJmVNSLQHxiTgoH0YUqzoKVTFJKHtEPPS12Jjf)emO8G)K1u0Rt5rklZ9tYw)gyO0VrIpv(FK)ctZ9tYw)gywkW70IIOIpf96i)qu6zzcrzPP3ov(FK)ctJvOVbDcsf02YSuG3PffWkoevxw9NwJT8K7lxG5jVX)5Q73r0AKzPMVGiRczDz1F6rrMf0GUMQZ9GGy0OG3wUTTgB5YXOmRdyap2bkgvLVGOYAUX)5Q73rXdh2oqXOQ8fevwZn(pxD)okIOIdrD0Hy0nFhdXpceRF8FoeZFYcX5xq8GNCkOLGhAulk5giQUS6pTgB5j3xUaZtg47y1JOUX)5O1iZC6Eqqmb(ow9iQB8FUH)cZPiniTsTuG3PveW3agiQUS6pTgB5j3xUaZtYjV0uEYvCs66HwJmFpiig52b2pvw5FwqK5mmT8iLLzPyB1uDQUX)5gk9BK4t3t2s1WlKwdNqAzxIi4iquDz1FAn2YtUVCbMN8(jzRFdqRrM3t2s1WlKwrMfCKrMIE5hIspltikln9wiQUS6pTgB5j3xUaZtgY32VrcT0dOznY3szRThtQDaTqE8qZ6iiyeWoqXOQ8fevwJg5BPS12JPjkpszz0iFR7s(yAnu63iXNquXr7hMTu1iOj)K3v)5S8drPNLjBqALcXPPCYlnLNCfNKUEMQLJ7eeAH84Huu0sZ6iiyeWoqXOQ8fevwJg5BPS12JPjkpszz0iFR7s(yAnu63iXNquXNqqJOquDz1FAn2YtUVCbMNKtEPPS12Jj0AKzD2t2s1WlKwdNqAzxOmhY32VrYOr(wkBT9ysTdIhoC5liQmvhqQ6v8MqrWrGO6YQ)0ASLNCF5cmpjN8st5jxXjPRhAnYSDGIrv5liQSgo5LMYtUItsxprMblevxw9NwJT8K7lxG5j1iFlLT2EmHwJmVNKmvhqQ6vGlkGKCiQUS6pTgB5j3xUaZtYjV0uEYvCs66HwJmFpiig52b2pvw5FwqK5meoC5rklZ6dnxXj5hm82U6pnu63iXHO6YQ)0ASLNCF5cmpP8t7jyO6prRrMVheeZ9tsz1AkYnlf4DAfbStasYHO6YQ)0ASLNCF5cmp5n(pxD)oIwJml18fezviRlR(tpkYSGgbNEpiiM7NKYQ1uKBwkW70kcyNaKKdr1Lv)P1ylp5(YfyEsnY3szRThtO1iZ7jjreCQo7jjt1bKQEfyrbKKho89GGyUFskRwtrUXwUCSiG)07bbXC)KuwTMICZsbENwr2tsMQdiv9kWkaijxCiQUS6pTgB5j3xUaZt6R0tsv)UuwO1iZ7jBPA4fsRHtiTSlreDewXkgd]] )

end