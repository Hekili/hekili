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
                local app = state.debuff.swarming_mist.applied
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
        blood_for_blood = 607, -- 233411
        dark_simulacrum = 3511, -- 77606
        death_chain = 609, -- 203173
        decomposing_aura = 3441, -- 199720
        dome_of_ancient_shadow = 5368, -- 328718
        last_dance = 608, -- 233412
        murderous_intent = 841, -- 207018
        necrotic_aura = 3436, -- 199642
        strangulate = 206, -- 47476
        unholy_command = 204, -- 202727
        walking_dead = 205, -- 202731
    } )


    -- Auras
    spec:RegisterAuras( {
        abomination_limb = {
            id = 315443,
            duration = 12,
            max_stack = 1,
        },
        antimagic_shell = {
            id = 48707,
            duration = function () return ( legendary.deaths_embrace.enabled and 2 or 1 ) * ( ( azerite.runic_barrier.enabled and 1 or 0 ) + ( talent.antimagic_barrier.enabled and 7 or 5 ) ) + ( conduit.reinforced_shell.mod * 0.001 ) end,
            max_stack = 1,
        },
        antimagic_zone = {
            id = 145629,
            duration = 10,
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
            duration = function () return pvptalent.last_dance.enabled and 4 or 8 end,
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
        deaths_due_buff = {
            id = 324165,
            duration = 10,
            max_stack = 15,
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
        wraith_walk = {
            id = 212552,
            duration = 4,
            max_stack = 1,
        },
        vampiric_blood = {
            id = 55233,
            duration = function () return level > 55 and 12 or 10 end,
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
        antimagic_zone = {
            id = 145629,
            duration = 10,
            max_stack = 1,
        },

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

        necrotic_aura = {
            id = 214968,
            duration = 3600,
            max_stack = 1,
        },


        -- Legendaries
        -- TODO:  Model +/- rune regen when applied/removed.
        crimson_rune_weapon = {
            id = 334526,
            duration = 10,
            max_stack = 1
        },

        grip_of_the_everlasting = {
            id = 334722,
            duration = 3,
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
        --[[ local control_expires = action.control_undead.lastCast + 300
        if control_expires > now and pet.up then
            summonPet( "controlled_undead", control_expires - now )
        end ]]
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
            cooldown = 120,
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


        blood_for_blood = {
            id = 233411,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.15,
            spendType = "health",

            startsCombat = false,
            texture = 1035037,

            pvptalent = "blood_for_blood",

            handler = function ()
                applyBuff( "blood_for_blood" )
            end,
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
            gcd = "spell",

            spend = function () return buff.crimson_scourge.up and 0 or 1 end,
            spendType = "runes",

            startsCombat = true,
            texture = 136144,

            noOverride = "deaths_due",

            handler = function ()
                removeBuff( "crimson_scourge" )

                if legendary.phearomones.enabled and buff.death_and_decay.down then
                    stat.haste = stat.haste + 0.1
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
            charges = function () return pvptalent.unholy_command.enabled and 2 or nil end,
            cooldown = 15,
            recharge = function () return pvptalent.unholy_command.enabled and 15 or nil end,
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

                removeBuff( "blood_for_blood" )

                if azerite.deep_cuts.enabled then applyDebuff( "target", "deep_cuts" ) end

                if legendary.gorefiends_domination.enabled and cooldown.vampiric_blood.remains > 0 then
                    cooldown.vampiric_blood.expires = cooldown.vampiric_blood.expires - 2
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
            gcd = "spell",

            startsCombat = false,

            toggle = "cooldowns",

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
            gcd = "spell",

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
            end,
        },

        -- Death Knight - Night Fae - 324128 - deaths_due           (Death's Due)
        deaths_due = {
            id = 324128,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = function () return buff.crimson_scourge.up and 0 or 1 end,
            spendType = "runes",

            startsCombat = true,
            texture = 3636837,

            notalent = "defile",

            handler = function ()
                removeBuff( "crimson_scourge" )

                if legendary.phearomones.enabled and buff.death_and_decay.down then
                    stat.haste = stat.haste + 0.1
                end

                applyBuff( "death_and_decay" )
                setCooldown( "death_and_decay", 15 )

                applyBuff( "deaths_due_buff" )
                applyDebuff( "target", "deaths_due_debuff" )
                -- Note:  Debuff is actually a buff on the target...
            end,
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
            end,

            auras = {
                -- Conduit
                impenetrable_gloom = {
                    id = 338629,
                    duration = 4,
                    max_stack = 1
                }
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

        potion = "potion_of_unbridled_fury",

        package = "Blood",        
    } )


    spec:RegisterSetting( "save_blood_shield", true, {
        name = "Save |T237517:0|t Blood Shield",
        desc = "If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r) will try to avoid letting your |T237517:0|t Blood Shield fall off during lulls in damage.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Blood", 20201013, [[dKKVVaqifv9iIk5sqIK2ervFcsKyueHofrfRsrfVcsAwqk3csuTlP6xePggrPJPQYYiIEgrW0uu4AuQSnfv6BuQQghKiohrLQ1POi8offrnpII7Pk2hrYbjQuSqvLEOIIYevuuDrirHrQOiYjjQuALcvVesu0ovv1pHeLCuirkpvHPQQ4RqIsTxL(lHbl4WKwmGhJYKH6YiBgIpRknAf50swnKivVgs1SLYTfYUP63QmCk54kkslh0ZPy6IUoqBhs47ukJNsv58kkTEkvz(cL9JQ3F7NDG1K2)skRKY(t2FsOllkXojmd7Fh5Sw0oSug66lTdxJOD8TDhEhw6STtX7NDyoqiJ2XOIaBAwNpZGksUdaWQLYT(cSdSM0(xszLu2FY(tYUK)K0(LeLSdJfX2)sANS7yQWyYxGDGjdBhYfp8TDhMhM5KMt8aktVENsEC5IhqzXYdGG8WpjGgpiPSsklpopUCXdZSj1FjZmbpUCXdOCEaLgyXqNhuhZd4cMZYdGwynjE4q4HViYn8qE8WysXNTM6ytFhTYKM9ZoiJHCgz2p7)F7NDqUc0i8(DhmyLeS0DGVSZoNrEc1KWcKMgrcaqO3HuKwUHhKHhKKhKNhMNhaarq6y1zL)kGGojSrQ15DqRDOSSoFhSZzKNqnjSaPPr0M7Fj3p7GCfOr497oyWkjyP7aaebPJcnYQGfta0Ud3bT4b55bjYdqTWccfKNDfJnDY(ktA4HyX4bOwybHcYZUIXME58Gu8Wp74b5SdLL157q9ksfhIatAoT5(xc7NDqUc0i8(DhmyLeS0DabDQNvejYt8JhKIhEzyEqEEac6ftyD2iipidpmdz3HYY68DerrhCwXHiAGSclWqsJmBU)NX(zhklRZ3HTd2WOGkxajZ5QZODqUc0i8(DZ9VD7NDqUc0i8(DhmyLeS0DmppaaIG0XQZk)vabDsyJuRZ7Gw7qzzD(oGLLvJeLlmwkJ2C)p39ZoixbAeE)UdgSscw6osf(szFI0wojSyjpi1dpGsKLhIfJhsf(szFI0wojSyjpiZdpiPS8qSy8as9oLcifPLB4bz4Hzy3ouwwNVdiPwL)kqAAez2CZDGjefSL7N9)V9ZouwwNVJOYXceir2J2b5kqJW73n3)sUF2b5kqJW73DWGvsWs3b7Ug(S5DS6SYFfqqNe2i168oKu8S8G88Ge5H55b2Dn8zZ7aT7Wyy5OtWoKu8S8qSy8W88qQnYZoq7omgwo6eStUc0impiNDOSSoFhaT7Wceq4SBU)LW(zhklRZ3babnee9YF3b5kqJW73n3)Zy)SdYvGgH3V7GbRKGLUdLLfkib5uurgEqQhEqsEiwmEac6epidp8JhKNhGGEXewNnc2XesXQKhKIhMRS7qzzD(ouitDsyb2m0M7F72p7GCfOr497oyWkjyP7aaebPd6txBwHjHK)MtDqRDOSSoFhT6Dkncu6G43iYZn3)ZD)SdLL157qDgzsO2emT12b5kqJW73n3)2)(zhklRZ3bsbjG2D4DqUc0i8(DZ9pkz)SdLL157aqFfhIiHfdDZoixbAeE)U5(xUVF2b5kqJW73DWGvsWs3b7Ug(S5DS6SYFfqqNe2i168oKI0Yn8Gu8GCx2DOSSoFhGgsujfz2C))t29ZoixbAeE)UdxJODav7HbD0ncG6vajSaamZZ3HYY68Dav7HbD0ncG6vajSaamZZ3C))73(zhKRancVF3bdwjblDhS7A4ZM3XQZk)vabDsyJuRZ7qksl3WdYZdZZdaGiiDS6SYFfqqNe2i168oOfpippabDQNvejYtmdEqkEGPMuKveTdLL157GnlRDj88IjaAQj3bHGqSu4AeTd2SS2LWZlMaOPMCZ9)pj3p7GCfOr497ouwwNVd1EMjfQgbY5P4qewNncUdgSscw6oKipWURHpBEhRoR8xbe0jHnsToVdPiTCdpidpyhpippKk8LYEwrKipbUiEqkE4ND8GC4HyX4bjYdPcFPSNvejYtGlIhKHhKWm4b5SdxJODO2ZmPq1iqopfhIW6SrWn3))KW(zhKRancVF3HYY68Derqc9Csnce1F3bdwjblDhsKhy31WNnVJvNv(Rac6KWgPwN3HuKwUHhKNhMNhaarq6y1zL)kGGojSrQ15DqlEqEEac6upRisKNyg8Gu8Ge4b5WdYZdZZdqTWccfKNDfJnDY(ktA4HyX4bOwybHcYZUIXME58Gu8Wp72HRr0oIiiHEoPgbI6VBU))nJ9ZoixbAeE)UdLL157qntOqDYiGQ9oOGDqTTdgSscw6oWeaicshQ27Gc2b1MataGiiD8zZ3HRr0ouZekuNmcOAVdkyhuBBU))z3(zhKRancVF3HYY68DOMjuOozeq1EhuWoO22bdwjblDhPcFPSprAlN6wSKhKHhKWpEqEEGMPGLLfH7yyba0k)vuo6whEhUgr7qntOqDYiGQ9oOGDqTT5()3C3p7GCfOr497ouwwNVd1mHc1jJaQ27Gc2b12oyWkjyP7aaebPJvNv(Rac6KWgPwN3bT4b55bmbaIG0HQ9oOGDqTjWeaicsh0IhKNhMNhOzkyzzr4ogwaaTYFfLJU1H3HRr0ouZekuNmcOAVdkyhuBBU))z)7NDqUc0i8(DhmyLeS0DaaIG0XQZk)vabDsyJuRZ7Gw7qzzD(oSUSoFZ9)puY(zhKRancVF3bdwjblDhqqNm9SIirEIF8Gu8WldVdLL157aODhwKQ1M7)FY99ZoixbAeE)UdgSscw6oGGEXewNnc2XesXQKhKIhMlpmhEqzzHcsqofvKzhklRZ3HXMcJk)vevMCZ9VKYUF2b5kqJW73DWGvsWs3X88GfLDTvOG2HYY68Da1YqcmP4n3)s(B)SdLL157qbUOY1Sox0QiGDqUc0i8(DZ9VKsUF2b5kqJW73DWGvsWs3X88qQnYZoq7omgwo6eStUc0impelgpmppWURHpBEhODhgdlhDc2HKINDhklRZ3bwDw5VciOtcBKAD(M7FjLW(zhKRancVF3bdwjblDhaGiiDGZjHzQOgUBsLHopi1dpy)7qzzD(oYlcWKNtBU)LCg7NDqUc0i8(DhklRZ3btBnHYY6CrRm5oyWkjyP7OC2fv(RaRr6ljSZWdsXdYUJwzsHRr0oIQSE1SoFZ9VK2TF2b5kqJW73DOSSoFhmT1eklRZfTYK7OvMu4AeTdYyiNrMn3)so39ZoixbAeE)UdLL157GPTMqzzDUOvMChTYKcxJODys1XkeV5M7WcsSlcqZ9Z()3(zhKRancVF3C)l5(zhKRancVF3C)lH9ZoixbAeE)U5(Fg7NDqUc0i8(DZ9VD7NDOSSoFhwxwNVdYvGgH3VBU)N7(zhKRancVF3HRr0ou7zMuOAeiNNIdryD2i4ouwwNVd1EMjfQgbY5P4qewNncU5(3(3p7GCfOr497ouwwNVd2SS2LWZlMaOPMCheccXsHRr0oyZYAxcpVycGMAYn3ChrvwVAwNVF2))2p7GCfOr497oyWkjyP7yI0wo1TyjpidpyNS8qSy8Ge5H55Hx4bAXdYZdtK2YPUfl5bz4H5oxEqo7qzzD(oqHgzvWIjaA3H3C)l5(zhKRancVF3bdwjblDhLZUOYFfynsFjHem8Gup8WePTCQZaHqYZDOSSoFhysZjHjHf60M7FjSF2b5kqJW73DWGvsWs3HrrbjaA3HfMPIAyEqEEOC2fv(RaRr6ljSZWdsXdYYdYZdaGiiDG2DyHzQOgUdAXdYZdaGiiDG2DyHzQOgUdPiTCdpidp8RBhpmhE4LH3HYY68DGjnNeMewOtBU)NX(zhKRancVF3bdwjblDhtK2YPUfl5bz4b7KLhq58Ge5bjLLhMdpaaIG0bA3HfMPIA4oOfpiNDOSSoFhfJaoqhlqoywjiM2C)B3(zhKRancVF3bdwjblDhtK2YPUfl5bz4b73oEqEEWIY(70b26qksl3WdYWd2TdLL157WOmyHuSsBclLLBU5omP6yfI3p7)F7NDqUc0i8(DhmyLeS0Dab9IjSoBeSJjKIvjpiZdp8twEqEEqI8W88qQnYZoW5KjpyuNCfOryEiwmEyEEGDxdF28oW5KjpyuhskEwEiwmEaaebPJvNv(Rac6KWgPwN3bT4b5SdLL157atAojmjSqN2C)l5(zhKRancVF3bdwjblDhwu2FNoWwhsrA5gEqgE4LH5H5WdsUdLL157WOmyHuSsBclLLBU)LW(zhKRancVF3bdwjblDhZZdaGiiDS6SYFfqqNe2i168oO1ouwwNVdG2DymSC0j4M7)zSF2b5kqJW73DWGvsWs3baicsh4CsyMkQH7qksl3WdYWd)62XdZHhEz4ozFedmjEiwmEqI8aaicsh4CsyMkQH7qksl3WdY8WdqqN6zfrI8esGhIfJhaarq6aNtcZurnChsrA5gEqMhEqI8WldZdOYdS7A4ZM3bA3HXWYrNGDiP4z5H5WdP2ip7aT7Wyy5OtWo5kqJW8WC4bj5b5WdXIXdaGiiDGZjHzQOgUBsLHopidpibEqo8G88ae0lMW6SrWoMqkwL8Gup8GKYUdLL157isHWZgKC8M7F72p7GCfOr497oyWkjyP7asiqYmPanAhklRZ3HzszO3irorcq32bZPz3C)p39ZoixbAeE)UdgSscw6oMNhaarq6y1zL)kGGojSrQ15DqRDOSSoFhtKctbzmKZOn3)2)(zhKRancVF3bdwjblDhSjf(sgbcuzzDU24bPE4HFDucpippirEaaebPprrNjvtz6MuzOZdY8WdsKhSJhq58GXIAnrQWxknDG2DybWvnEqo8qSy8GXIAnrQWxknDG2DybWvnEqkEqsEqo7qzzD(oaA3Hfax12C)Js2p7GCfOr497oyWkjyP7aaebPdCojmtf1WDtQm05bzE4H5YdYZdqqVycRZgb7ycPyvYds9Wd)SBhklRZ3rKcHNni54n3)Y99ZoixbAeE)UdgSscw6oGGEXewNncYds9Wd)KvwEqEEyEEaaebPJvNv(Rac6KWgPwN3bT2HYY68DaCozYdgT5()NS7NDqUc0i8(DhmyLeS0Dab9IjSoBeSJjKIvjpiZdpirE4ND8aQ8aaicshRoR8xbe0jHnsToVdAXdZHhSJhqLhmwuRjsf(sPPprkmfMewOt8WC4HuBKN9jsHjaKu0jyNCfOryEyo8GK8GC4HyX4HSIirEcCr8Gm8Wpz3HYY68DGjnNeMewOtBU))9B)SdYvGgH3V7GbRKGLUdJf1AIuHVuA6ysZjH6ybMy6S8Gup8Ge2HYY68DGjnNeQJfyIPZU5()NK7NDqUc0i8(DhmyLeS0DySOwtKk8LsthtAozeyqIhK6HhKWouwwNVdmP5KrGbPn3))KW(zhKRancVF3bdwjblDhaGiiDS6SYFfqqNe2i168oOfpelgpabDQNvejYtmdEqgE4LH3HYY68DmrkmfMewOtBU))nJ9ZoixbAeE)UdgSscw6oaarq6y1zL)kGGojSrQ15DqRDOSSoFhaT7WcGRABU))z3(zhKRancVF3bdwjblDhaGiiDgSImNlmSde(sDqlEiwmEi1g5zhQwfwGj2fzDMkRZ7KRancZdXIXdglQ1ePcFP00XKMtc1XcmX0z5bPE4bj3HYY68DGjnNeQJfyIPZU5()3C3p7GCfOr497oyWkjyP7aaebPZGvK5CHHDGWxQdAXdXIXdP2ip7q1QWcmXUiRZuzDENCfOryEiwmEWyrTMiv4lLMoM0CYiWGepi1dpi5ouwwNVdmP5KrGbPn3))S)9ZouwwNVd25gWiRSoFhKRancVF3C))dLSF2HYY68Da0UdlaUQTdYvGgH3VBU))j33p7GCfOr497oyWkjyP7ac6upRisKNqc8Gm8WldZdXIXdaGiiDGZjHzQOgUBsLHopifpm3DOSSoFhtKctHjHf60M7FjLD)SdYvGgH3V7GbRKGLUdiOxmH1zJGDmHuSk5bP4bjLDhklRZ3HczQtI8GqYZn3CZDGccAQZ3)skRKY(t2F)2Hnf6L)A2HCBK1btcZd2XdklRZ5HwzstNhFhkyoDWDmQOzgpGkpmtIqVA1oSGhs1ODix8W32DyEyMtAoXdOm96Dk5XLlEaLflpacYd)KaA8GKYkPS8484YfpmZMu)LmZe84YfpGY5buAGfdDEqDmpGlyolpaAH1K4HdHh(Ii3Wd5XdJjfF2AQJnDECEC5IhqzyFedmjmpaqihK4b2fbOjpaqVLB68GCdJrwPHh8Zr5tkmcbSXdklRZn8W5Tz784klRZnDliXUianFanKOskcnxJOh1EMjfQgbY5P4qewNncYJRSSo30TGe7Ia0e1hPbnKOskcncbHyPW1i6HnlRDj88IjaAQj5X5XLlEaLH9rmWKW8aHccolpKveXd5eXdklpipugEqrHwnfOrDECLL15MNOYXceir2J4XvwwNBq9rAG2DybciCw0kKh2Dn8zZ7y1zL)kGGojSrQ15DiP4zLxIZZURHpBEhODhgdlhDc2HKINnwS5tTrE2bA3HXWYrNGDYvGgHLdpUYY6CdQpsdqqdbrV8xECLL15guFKwHm1jHfyZqOvipklluqcYPOIms9izSyqqNK5N8qqVycRZgb7ycPyvk1CLLhxzzDUb1hPB17uAeO0bXVrKNOvipaGiiDqF6AZkmjK83CQdAXJRSSo3G6J0QZitc1MGPTgpUYY6CdQpsJuqcODhMhxzzDUb1hPb0xXHisyXq3WJRSSo3G6J0GgsujfzqRqEy31WNnVJvNv(Rac6KWgPwN3HuKwUrk5US84klRZnO(inOHevsrO5Ae9av7HbD0ncG6vajSaamZZ5XvwwNBq9rAqdjQKIqJqqiwkCnIEyZYAxcpVycGMAs0kKh2Dn8zZ7y1zL)kGGojSrQ15DifPLBKFEaqeKowDw5VciOtcBKADEh0sEiOt9SIirEIziftnPiRiIhxzzDUb1hPbnKOskcnxJOh1EMjfQgbY5P4qewNncIwH8ir2Dn8zZ7y1zL)kGGojSrQ15DifPLBKXo5tf(szpRisKNaxKu)StoXIjXuHVu2ZkIe5jWfjJeMHC4XvwwNBq9rAqdjQKIqZ1i6jIGe65KAeiQ)IwH8ir2Dn8zZ7y1zL)kGGojSrQ15DifPLBKFEaqeKowDw5VciOtcBKADEh0sEiOt9SIirEIziLeKJ8Zd1cliuqE2vm20j7RmPjwmOwybHcYZUIXME5s9ZoECLL15guFKg0qIkPi0CnIEuZekuNmcOAVdkyhuBOvipycaebPdv7Dqb7GAtGjaqeKo(S584klRZnO(inOHevsrO5Ae9OMjuOozeq1EhuWoO2qRqEsf(szFI0wo1TyPms4N80mfSSSiChdlaGw5VIYr36W84klRZnO(inOHevsrO5Ae9OMjuOozeq1EhuWoO2qRqEaarq6y1zL)kGGojSrQ15Dql5XeaicshQ27Gc2b1MataGiiDql5NNMPGLLfH7yyba0k)vuo6whMhxzzDUb1hPTUSohTc5baebPJvNv(Rac6KWgPwN3bT4XvwwNBq9rAG2DyrQwOvipqqNm9SIirEIFs9YW84klRZnO(iTXMcJk)vevMeTc5bc6ftyD2iyhtifRsPM7CuwwOGeKtrfz4XvwwNBq9rAOwgsGjfJwH8mVfLDTvOG4XvwwNBq9rAf4IkxZ6CrRIa4XvwwNBq9rAS6SYFfqqNe2i16C0kKN5tTrE2bA3HXWYrNGDYvGgHJfBE2Dn8zZ7aT7Wyy5OtWoKu8S84klRZnO(iDEraM8CcTc5baebPdCojmtf1WDtQm0L6X(5XvwwNBq9rAM2AcLL15Iwzs0CnIEIQSE1SohTc5PC2fv(RaRr6ljSZiLS84klRZnO(intBnHYY6CrRmjAUgrpKXqoJm84klRZnO(intBnHYY6CrRmjAUgrpMuDScX8484klRZnDYyiNrMh25mYtOMewG00icTc5bFzNDoJ8eQjHfinnIeaGqVdPiTCJmsk)8aGiiDS6SYFfqqNe2i168oOfpUYY6CtNmgYzKb1hPvVIuXHiWKMtOvipaGiiDuOrwfSycG2D4oOL8seQfwqOG8SRySPt2xzstSyqTWccfKNDfJn9YL6NDYHhxzzDUPtgd5mYG6J0ru0bNvCiIgiRWcmK0idAfYde0PEwrKipXpPEzy5HGEXewNnckZmKLhxzzDUPtgd5mYG6J02oydJcQCbKmNRoJ4XvwwNB6KXqoJmO(inSSSAKOCHXszeAfYZ8aGiiDS6SYFfqqNe2i168oOfpUYY6CtNmgYzKb1hPHKAv(RaPPrKbTc5jv4lL9jsB5KWILs9GsKnwSuHVu2NiTLtclwkZJKYglgs9oLcifPLBKzg2XJZJRSSo30JQSE1So)bfAKvblMaODhgTc5zI0wo1TyPm2jBSysC(x4bAj)ePTCQBXszM7CLdpopUCXdYTo7Ik)LhWAK(s8aKMPGfKIip5HYWdsAhkvE4q4Hi1(4HjsB5epyU2HgpyNSOu5HdHhIu7JhMiTLt8q58GYdVWd0QZJRSSo30JQSE1Soh1hPXKMtctcl0j0kKNYzxu5VcSgPVKqcgPEMiTLtDgiesEYJZJlx8Wm)Cukjp0OKhuNhi7Rmz5V8W32DyEymvudZdy4z15XvwwNB6rvwVAwNJ6J0ysZjHjHf6eAfYJrrbjaA3HfMPIAy5lNDrL)kWAK(sc7msjR8aGiiDG2DyHzQOgUdAjpaicshODhwyMkQH7qksl3iZVUDZ5LH5X5XvwwNB6rvwVAwNJ6J0fJaoqhlqoywjiMqRqEMiTLtDlwkJDYIYLOKYohaqeKoq7oSWmvud3bTKdpopUYY6CtpQY6vZ6CuFK2OmyHuSsBclLLOviptK2YPUflLX(TtElk7VthyRdPiTCJm2XJZJRSSo30nP6yfIFWKMtctcl0j0kKhiOxmH1zJGDmHuSkL55NSYlX5tTrE2boNm5bJ6KRanchl28S7A4ZM3boNm5bJ6qsXZglgaicshRoR8xbe0jHnsToVdAjhECLL15MUjvhRqmQpsBugSqkwPnHLYs0kKhlk7VthyRdPiTCJmVm8CKKhxzzDUPBs1XkeJ6J0aT7Wyy5Otq0kKN5barq6y1zL)kGGojSrQ15DqlECLL15MUjvhRqmQpshPq4zdsogTc5baebPdCojmtf1WDifPLBK5x3U58YWDY(igysXIjraqeKoW5KWmvud3HuKwUrMhiOt9SIirEcjelgaicsh4CsyMkQH7qksl3iZJeFzyuz31WNnVd0UdJHLJob7qsXZoNuBKNDG2DymSC0jyNCfOr45iPCIfdaebPdCojmtf1WDtQm0LrcYrEiOxmH1zJGDmHuSkL6rsz5XvwwNB6MuDScXO(iTzszO3irorcq32bZPzrRqEGecKmtkqJ4XvwwNB6MuDScXO(i9ePWuqgd5mcTc5zEaqeKowDw5VciOtcBKADEh0IhxzzDUPBs1XkeJ6J0aT7WcGRAOvipSjf(sgbcuzzDU2K65xhLiVebarq6tu0zs1uMUjvg6Y8ir7q5glQ1ePcFP00bA3Hfax1KtSyglQ1ePcFP00bA3Hfax1Kss5WJRSSo30nP6yfIr9r6ifcpBqYXOvipaGiiDGZjHzQOgUBsLHUmpZvEiOxmH1zJGDmHuSkL65ND84klRZnDtQowHyuFKg4CYKhmcTc5bc6ftyD2iOup)Kvw5NhaebPJvNv(Rac6KWgPwN3bT4XvwwNB6MuDScXO(inM0CsysyHoHwH8ab9IjSoBeSJjKIvPmps8NDOcaIG0XQZk)vabDsyJuRZ7GwZXounwuRjsf(sPPprkmfMewOtZj1g5zFIuycajfDc2jxbAeEoskNyXYkIe5jWfjZpz5XvwwNB6MuDScXO(inM0CsOowGjMolAfYJXIAnrQWxknDmP5KqDSatmDwPEKapUCXdOS1KnXdJkAMXdvKvJIip1SoNhG0mbpmZjnNqPy4HzointMhmeXdfcpKt0S8q5SgiM4bGlN4bfOAvwKHhoipui8aM0CsOowGjMolpGa6SSo3WdihKhaUCQZJRSSo30nP6yfIr9rAmP5KrGbj0kKhJf1AIuHVuA6ysZjJadss9ibECLL15MUjvhRqmQpsprkmfMewOtOvipaGiiDS6SYFfqqNe2i168oOvSyqqN6zfrI8eZqMxgMhxzzDUPBs1XkeJ6J0aT7WcGRAOvipaGiiDS6SYFfqqNe2i168oOfpUYY6Ct3KQJvig1hPXKMtc1XcmX0zrRqEaarq6myfzoxyyhi8L6GwXILAJ8SdvRclWe7ISotL15DYvGgHJfZyrTMiv4lLMoM0CsOowGjMoRupsYJRSSo30nP6yfIr9rAmP5KrGbj0kKhaqeKodwrMZfg2bcFPoOvSyP2ip7q1QWcmXUiRZuzDENCfOr4yXmwuRjsf(sPPJjnNmcmij1JK84klRZnDtQowHyuFKMDUbmYkRZ5XvwwNB6MuDScXO(inq7oSa4QgpUYY6Ct3KQJvig1hPNifMctcl0j0kKhiOt9SIirEcjiZldhlgaicsh4CsyMkQH7MuzOl1C5XvwwNB6MuDScXO(iTczQtI8GqYt0kKhiOxmH1zJGDmHuSkLssz3CZDb]] )

end