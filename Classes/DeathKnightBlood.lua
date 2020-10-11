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


    spec:RegisterPack( "Blood", 20201011, [[dKeRWaqivr9icuUeKiPnrj1NGejgfLGtrj0QufQxbjnliv3csu2Lu9lcyyeuhtvXYOK8mcKPPkKRrPQTPkOVrPsnoirCocu16ufaVtvaQ5rj6EkY(iihKavSqvvEOQazIQcuxesuXivfGCscuPvku9sirL2PQQ(jKOkhfsKYtvyQQk9virvTxL(lrdwWHjTyapgXKH6YO2mqFwvA0kQtlz1qIu9AiLzlLBlKDt1Vvz4e64QcOLd65umDrxhITdj8DkLXtPsoVQiRNsfZxOSFKE)SF3bwtE)BLWwj8hH)8P)rybz3ccLSJ8jrEhIkbn9L3HRr8o(1UdVdr9P2P497omhcKW7yurinnRZFqqfm3bas1sbxFb2bwtE)BLWwj8hH)8P)rybz3c6H7WiYK9Vv2l8oMlmM9fyhy2q2HGrd)A3HPHhmR5mnGY1R35KgxWObuEK8ayin85d60GvcBLW0404cgn8GMv)Lnpa04cgnGYObuAifbnAqDmnGly(enGiI1KPHdKg(bk4qd5rdJzfF2AQJn9D0ktA2V7Gng2jSz)U))SF3b7kqJX7VDqGvYWs3b(Yo5Cc7jutglbBAelbqGEhYrA5gAWsAWkAWAA4zAaabeSJvNu(ReI4S0gRIN3re3HsY68DqoNWEc1KXsWMgXBU)TA)Ud2vGgJ3F7GaRKHLUdaeqWok0iXcwejq7oChrKgSMgSana1clzuWE2vm20z7QmPHgIfJgGAHLmkyp7kgB6LtdcrdFSNgS4ouswNVd1RivEGsmR58M7FbTF3b7kqJX7VDqGvYWs3beX5EwrSmp5hAqiA4LGPbRPbiIxeP4zJH0GL0WJeEhkjRZ3rehDWNKhOSHqkSedznYS5()r73DOKSoFh2oydJcUCjKnNRoH3b7kqJX7Vn3)2VF3b7kqJX7VDqGvYWs3XZ0aaciyhRoP8xjeXzPnwfpVJiUdLK157awIInwwU0iQeEZ9)d3V7GDfOX493oiWkzyP7iv4lN9zwB5SuKK0Gqt0akryAiwmAiv4lN9zwB5SuKK0GLt0GvctdXIrdG17CkHCKwUHgSKgEK97qjzD(oGSkw(ReSPrSzZn3bMbvKwUF3)F2V7qjzD(oIkhlbHmBhEhSRangV)2C)B1(DhSRangV)2bbwjdlDhK7A4ZM3XQtk)vcrCwAJvXZ7qwXprdwtdwGgEMgi31WNnVd0UdJHLJgd7qwXprdXIrdptdP2yp7aT7Wyy5OXWo7kqJX0Gf3HsY68Da0UdlbrGpT5(xq73DOKSoFham0Wq0k)DhSRangV)2C))O97oyxbAmE)TdcSsgw6ouswOGLSZrfBObHMObROHyXObiIZ0GL0WhAWAAaI4frkE2yyhZGfPsAqiA4HcVdLK157qHe1zPisZWBU)TF)Ud2vGgJ3F7GaRKHLUdaeqWoIpFTNKMeY(Bo3re3HsY68D0Q350irPJGFJyp3C))W97ouswNVd1jSjHAts0wBhSRangV)2C)B373DOKSoFhGfKbA3H3b7kqJX7Vn3)OK97ouswNVda9vEGYewe0m7GDfOX493M7Fb)(DhSRangV)2bbwjdlDhK7A4ZM3XQtk)vcrCwAJvXZ7qosl3qdcrdcEH3HsY68DGyyzLCKzZ9)hH3V7GDfOX493oCnI3buTdgXrZibQxjKXsaKmpFhkjRZ3buTdgXrZibQxjKXsaKmpFZ9)Np73DWUc0y8(BhkjRZ3b5js7s45frc0utUdcSsgw6oi31WNnVJvNu(ReI4S0gRIN3HCKwUHgSMgEMgaqab7y1jL)kHiolTXQ45DerAWAAaI4CpRiwMN8r0Gq0arnPmRiEhmiitsPRr8oiprAxcpVisGMAYn3)FSA)Ud2vGgJ3F7qjzD(ou7yMvOAKGNNYdukE2y4oiWkzyP7Wc0a5Ug(S5DS6KYFLqeNL2yv88oKJ0Yn0GL0G90G10qQWxo7zfXY8K4IPbHOHp2tdwKgIfJgSanKk8LZEwrSmpjUyAWsAqqpIgS4oCnI3HAhZScvJe88uEGsXZgd3C))rq73DWUc0y8(BhkjRZ3redz0Yz1ibv)DheyLmS0DybAGCxdF28owDs5VsiIZsBSkEEhYrA5gAWAA4zAaabeSJvNu(ReI4S0gRIN3rePbRPbiIZ9SIyzEYhrdcrdcIgSinynn8mna1clzuWE2vm20z7QmPHgIfJgGAHLmkyp7kgB6LtdcrdFSFhUgX7iIHmA5SAKGQ)U5()ZJ2V7GDfOX493ouswNVd1mJc1zJeQ25GsYb12oiWkzyP7aZaiGGDOANdkjhuBsmdGac2XNnFhUgX7qnZOqD2iHQDoOKCqTT5()J973DWUc0y8(BhkjRZ3HAMrH6Srcv7Cqj5GABheyLmS0DKk8LZ(mRTCUlssAWsAqqFObRPb(bIuIImUJHfaqR8xz5OjE4D4AeVd1mJc1zJeQ25GsYb12M7)ppC)Ud2vGgJ3F7qjzD(ouZmkuNnsOANdkjhuB7GaRKHLUdaeqWowDs5VsiIZsBSkEEhrKgSMgWmaciyhQ25GsYb1MeZaiGGDerAWAA4zAGFGiLOiJ7yyba0k)vwoAIhEhUgX7qnZOqD2iHQDoOKCqTT5()JDVF3b7kqJX7VDqGvYWs3baciyhRoP8xjeXzPnwfpVJiUdLK157q8Y68n3)Fqj73DWUc0y8(BheyLmS0DarC20ZkIL5j)qdcrdVe8ouswNVdG2DyzQIBU))i43V7GDfOX493oiWkzyP7aI4frkE2yyhZGfPsAqiA4H0WJPbLKfkyj7CuXMDOKSoFhgBkmQ8xzuzYn3)wj8(DhSRangV)2bbwjdlDhptdIC21wHcEhkjRZ3buldlXSI3C)B1N97ouswNVdf4IkxZ6CzRIa2b7kqJX7Vn3)wz1(DhSRangV)2bbwjdlDhptdP2yp7aT7Wyy5OXWo7kqJX0qSy0WZ0a5Ug(S5DG2DymSC0yyhYk(PDOKSoFhy1jL)kHiolTXQ45BU)Tsq73DWUc0y8(BheyLmS0DaGac2boNLM5IB4UjvcA0Gqt0GDVdLK157iViatEoV5(3QhTF3b7kqJX7VDqGvYWs3r5KlQ8xjwJ0xwAVHgeIgeEhkjRZ3brBnPsY6CzRm5oALjLUgX7iQY6vZ68n3)wz)(DhSRangV)2HsY68Dq0wtQKSox2ktUJwzsPRr8oyJHDcB2C)B1d3V7GDfOX493ouswNVdI2AsLK15YwzYD0ktkDnI3HjvhRq8MBUdritUian3V7)p73DWUc0y8(BZ9Vv73DWUc0y8(BZ9VG2V7GDfOX493M7)hTF3b7kqJX7Vn3)2VF3HsY68DiEzD(oyxbAmE)T5()H73DWUc0y8(BhUgX7qTJzwHQrcEEkpqP4zJH7qjzD(ou7yMvOAKGNNYdukE2y4M7F7E)Ud2vGgJ3F7qjzD(oiprAxcpVisGMAYDWGGmjLUgX7G8ePDj88IibAQj3CZDevz9QzD((D))z)Ud2vGgJ3F7GaRKHLUJzwB5CxKK0GL0G9ctdXIrdwGgEMgEHhIinynnmZAlN7IKKgSKgE4dPblUdLK157afAKyblIeODhEZ9Vv73DWUc0y8(BheyLmS0Duo5Ik)vI1i9LLcYqdcnrdZS2Y5obbczp3HsY68DGznNLMewOXBU)f0(DhSRangV)2bbwjdlDhgffSeODhwAMlUHPbRPHYjxu5VsSgPVS0EdnienimnynnaGac2bA3HLM5IB4oIinynnaGac2bA3HLM5IB4oKJ0Yn0GL0WNU90WJPHxcEhkjRZ3bM1CwAsyHgV5()r73DWUc0y8(BheyLmS0DmZAlN7IKKgSKgSxyAaLrdwGgSsyA4X0aaciyhODhwAMlUH7iI0Gf3HsY68Dueg4qCSe8GzLiyEZ9V973DWUc0y8(BheyLmS0DmZAlN7IKKgSKgSB7PbRPbro7VZhsRd5iTCdnyjny)ouswNVdJsGfyrkTjfvsU5M7WKQJviE)U))SF3b7kqJX7VDqGvYWs3beXlIu8SXWoMblsL0GLt0WhHPbRPblqdptdP2yp7aNZM8GrD2vGgJPHyXOHNPbYDn8zZ7aNZM8GrDiR4NOHyXObaeqWowDs5VsiIZsBSkEEhrKgS4ouswNVdmR5S0KWcnEZ9Vv73DWUc0y8(BheyLmS0DiYz)D(qADihPLBOblPHxcMgEmny1ouswNVdJsGfyrkTjfvsU5(xq73DWUc0y8(BheyLmS0D8mnaGac2XQtk)vcrCwAJvXZ7iI7qjzD(oaA3HXWYrJHBU)F0(DhSRangV)2bbwjdlDhaiGGDGZzPzU4gUd5iTCdnyjn8PBpn8yA4LG7SDXeKKPHyXOblqdaiGGDGZzPzU4gUd5iTCdny5enarCUNvelZtkiAiwmAaabeSdColnZf3WDihPLBOblNOblqdVemnGknqURHpBEhODhgdlhng2HSIFIgEmnKAJ9Sd0UdJHLJgd7SRangtdpMgSIgSinelgnaGac2boNLM5IB4UjvcA0GL0GGOblsdwtdqeVisXZgd7ygSivsdcnrdwj8ouswNVJifcpBq2XBU)TF)Ud2vGgJ3F7GaRKHLUdidczZSc04DOKSoFhMzLGwJL5mlrCBhmNFAZ9)d3V7GDfOX493oiWkzyP74zAaabeSJvNu(ReI4S0gRIN3re3HsY68DmZkmLSXWoH3C)B373DWUc0y8(BheyLmS0DqMv4lBKGqLK15AJgeAIg(0rj0G10GfObaeqW(mhDMunLPBsLGgny5enybAWEAaLrdgrU1KPcF500bA3HLax1OblsdXIrdgrU1KPcF500bA3HLax1ObHObROblUdLK157aODhwcCvBZ9pkz)Ud2vGgJ3F7GaRKHLUdaeqWoW5S0mxCd3nPsqJgSCIgEinynnar8IifpBmSJzWIujni0en8X(DOKSoFhrkeE2GSJ3C)l43V7GDfOX493oiWkzyP7aI4frkE2yini0en8ryHPbRPHNPbaeqWowDs5VsiIZsBSkEEhrChkjRZ3bW5Sjpy0M7)pcVF3b7kqJX7VDqGvYWs3beXlIu8SXWoMblsL0GLt0GfOHp2tdOsdaiGGDS6KYFLqeNL2yv88oIin8yAWEAavAWiYTMmv4lNM(mRWuAsyHgtdpMgsTXE2NzfMaqwrJHD2vGgJPHhtdwrdwKgIfJgYkIL5jXftdwsdFeEhkjRZ3bM1CwAsyHgV5()ZN97oyxbAmE)TdcSsgw6omICRjtf(YPPJznNLQJLyMOprdcnrdcAhkjRZ3bM1CwQowIzI(0M7)pwTF3b7kqJX7VDqGvYWs3HrKBnzQWxonDmR5SrIryAqOjAqq7qjzD(oWSMZgjgH3C))rq73DWUc0y8(BheyLmS0DaGac2XQtk)vcrCwAJvXZ7iI0qSy0aeX5EwrSmp5JOblPHxcEhkjRZ3XmRWuAsyHgV5()ZJ2V7GDfOX493oiWkzyP7aabeSJvNu(ReI4S0gRIN3re3HsY68Da0UdlbUQT5()J973DWUc0y8(BheyLmS0DaGac2jWkYCU0qoe4l3rePHyXOHuBSNDOkwyjMjxK4zQSoVZUc0ymnelgnye5wtMk8LtthZAolvhlXmrFIgeAIgSAhkjRZ3bM1CwQowIzI(0M7)ppC)Ud2vGgJ3F7GaRKHLUdaeqWobwrMZLgYHaF5oIinelgnKAJ9SdvXclXm5IeptL15D2vGgJPHyXObJi3AYuHVCA6ywZzJeJW0Gqt0Gv7qjzD(oWSMZgjgH3C))XU3V7qjzD(oiNBqIeZ68DWUc0y8(BZ9)huY(DhkjRZ3bq7oSe4Q2oyxbAmE)T5()JGF)Ud2vGgJ3F7GaRKHLUdiIZ9SIyzEsbrdwsdVemnelgnaGac2boNLM5IB4UjvcA0Gq0Wd3HsY68DmZkmLMewOXBU)Ts497oyxbAmE)TdcSsgw6oGiErKINng2XmyrQKgeIgSs4DOKSoFhkKOolZdczp3CZn3bkyOPoF)BLWwj8hH)8zh2uOx(RzhcUrIhmzmnypnOKSoNgALjnDA8DicpWQX7qWOHFT7W0WdM1CMgq5617CsJly0akpsEamKg(8bDAWkHTsyACACbJgEqZQ)YMhaACbJgqz0aknKIGgnOoMgWfmFIgqeXAY0Wbsd)afCOH8OHXSIpBn1XMononUGrdOCSlMGKmMgayWdY0a5Ia0Kga43YnDAqWHqyX0qd(5OSzfgbI0ObLK15gA482tDACLK15MUiKjxeGMtGn1GgnUsY6CtxeYKlcqtuNea8omnUsY6CtxeYKlcqtuNeqrEJyp1SoNgxWOHHRIM5lPbOwyAaabeKX0Gj10qdam4bzAGCraAsda8B5gAqDmniczuM4Lz5V0qzOb85CNgxjzDUPlczYfbOjQtcyCv0mFP0KAAOXvswNB6IqMCraAI6KaIxwNtJRKSo30fHm5Ia0e1jbqmSSsocDxJ4j1oMzfQgj45P8aLINngsJRKSo30fHm5Ia0e1jbqmSSsocDgeKjP01iEI8ePDj88IibAQjPXPXfmAaLJDXeKKX0aJcg(enKvetd5mtdkjpinugAqrHwnfOXDACLK15MPOYXsqiZ2HPXvswNBqDsaG2Dyjic8j0lWjYDn8zZ7y1jL)kHiolTXQ45DiR4NS2cptURHpBEhODhgdlhng2HSIFkwSNtTXE2bA3HXWYrJHD2vGgJTinUsY6CdQtcaWqddrR8xACLK15guNeqHe1zPisZWOxGtkjluWs25OIncnzvSyqeNT8J1qeVisXZgd7ygSivk0dfMgxjzDUb1jbA17CAKO0rWVrSNOxGtaiGGDeF(ApjnjK93CUJisJRKSo3G6KaQtytc1MKOTgnUsY6CdQtcawqgODhMgxjzDUb1jba0x5bktyrqZqJRKSo3G6KaigwwjhzqVaNi31WNnVJvNu(ReI4S0gRIN3HCKwUribVW04kjRZnOojaIHLvYrO7Aepbv7GrC0msG6vczSeajZZPXvswNBqDsaedlRKJqNbbzskDnINiprAxcpVisGMAs0lWjYDn8zZ7y1jL)kHiolTXQ45DihPLBS(zaeqWowDs5VsiIZsBSkEEhr0AiIZ9SIyzEYhjernPmRiMgxjzDUb1jbqmSSsocDxJ4j1oMzfQgj45P8aLINngIEbozbYDn8zZ7y1jL)kHiolTXQ45DihPLBS0ERtf(YzpRiwMNexSqFS3IXIzHuHVC2ZkIL5jXfBPGEKfPXvswNBqDsaedlRKJq31iEkIHmA5SAKGQ)IEbozbYDn8zZ7y1jL)kHiolTXQ45DihPLBS(zaeqWowDs5VsiIZsBSkEEhr0AiIZ9SIyzEYhjKGSO1pd1clzuWE2vm20z7QmPjwmOwyjJc2ZUIXME5c9XEACLK15guNeaXWYk5i0DnINuZmkuNnsOANdkjhuBOxGtygabeSdv7Cqj5GAtIzaeqWo(S504kjRZnOojaIHLvYrO7AepPMzuOoBKq1ohusoO2qVaNsf(YzFM1wo3fjPLc6J18dePefzChdlaGw5VYYrt8W04kjRZnOojaIHLvYrO7AepPMzuOoBKq1ohusoO2qVaNaqab7y1jL)kHiolTXQ45DerRXmaciyhQ25GsYb1MeZaiGGDerRFMFGiLOiJ7yyba0k)vwoAIhMgxjzDUb1jbeVSoh9cCcabeSJvNu(ReI4S0gRIN3rePXvswNBqDsaG2DyzQIOxGtqeNn9SIyzEYpc9sW04kjRZnOojGXMcJk)vgvMe9cCcI4frkE2yyhZGfPsHE4JvswOGLSZrfBOXvswNBqDsaOwgwIzfJEbo9SiNDTvOGPXvswNBqDsaf4IkxZ6CzRIaOXvswNBqDsaS6KYFLqeNL2yv8C0lWPNtTXE2bA3HXWYrJHD2vGgJJf7zYDn8zZ7aT7Wyy5OXWoKv8t04kjRZnOojqEraM8Cg9cCcabeSdColnZf3WDtQe0eAYUPXvswNBqDsaI2AsLK15Ywzs0DnINIQSE1Soh9cCQCYfv(ReRr6llT3iKW04kjRZnOojarBnPsY6CzRmj6UgXtSXWoHn04kjRZnOojarBnPsY6CzRmj6UgXtMuDScX0404kjRZnD2yyNWMjY5e2tOMmwc20ig9cCcFzNCoH9eQjJLGnnILaiqVd5iTCJLwz9ZaiGGDS6KYFLqeNL2yv88oIinUsY6CtNng2jSb1jbuVIu5bkXSMZOxGtaiGGDuOrIfSisG2D4oIO1waQfwYOG9SRySPZ2vzstSyqTWsgfSNDfJn9Yf6J9wKgxjzDUPZgd7e2G6KarC0bFsEGYgcPWsmK1id6f4eeX5EwrSmp5hHEjyRHiErKINngA5JeMgxjzDUPZgd7e2G6Ka2oydJcUCjKnNRoHPXvswNB6SXWoHnOojaSefBSSCPrujm6f40ZaiGGDS6KYFLqeNL2yv88oIinUsY6CtNng2jSb1jbGSkw(ReSPrSb9cCkv4lN9zwB5SuKKcnHseowSuHVC2NzTLZsrsA5Kvchlgy9oNsihPLBS8r2tJtJRKSo30JQSE1SoFcfAKyblIeODhg9cCAM1wo3fjPL2lCSyw45x4HiA9mRTCUlsslF4dTinonUGrdcUo5Ik)LgWAK(Y0aKFGifKJypPHYqdwzpkvA4aPHi1UOHzwB5mnyU2HonyVWOuPHdKgIu7IgMzTLZ0q50GsdVWdrStJRKSo30JQSE1Soh1jbWSMZstcl0y0lWPYjxu5VsSgPVSuqgHMMzTLZDcceYEsJtJly0Wd(Cukjn04KguNgy7Qmz5V0WV2DyAymxCdtdy4j2PXvswNB6rvwVAwNJ6KaywZzPjHfAm6f4KrrblbA3HLM5IByRlNCrL)kXAK(Ys7ncjS1aiGGDG2DyPzU4gUJiAnaciyhODhwAMlUH7qosl3y5NU9p(LGPXPXvswNB6rvwVAwNJ6KafHboehlbpywjcMrVaNMzTLZDrsAP9cJYSGvc)yaeqWoq7oS0mxCd3reTinonUsY6CtpQY6vZ6CuNeWOeybwKsBsrLKOxGtZS2Y5UijT0UT3Aro7VZhsRd5iTCJL2tJtJRKSo30nP6yfINWSMZstcl0y0lWjiIxeP4zJHDmdwKkTC6JWwBHNtTXE2boNn5bJ6SRanghl2ZK7A4ZM3boNn5bJ6qwXpflgaciyhRoP8xjeXzPnwfpVJiArACLK15MUjvhRqmQtcyucSalsPnPOss0lWjro7VZhsRd5iTCJLVe8JTIgxjzDUPBs1XkeJ6KaaT7Wyy5OXq0lWPNbqab7y1jL)kHiolTXQ45DerACLK15MUjvhRqmQtcePq4zdYog9cCcabeSdColnZf3WDihPLBS8t3(h)sWD2UycsYXIzbaeqWoW5S0mxCd3HCKwUXYjiIZ9SIyzEsbflgaciyh4CwAMlUH7qosl3y5KfEjyuj31WNnVd0UdJHLJgd7qwXp94uBSNDG2DymSC0yyNDfOX4hBLfJfdabeSdColnZf3WDtQe0Suqw0AiIxeP4zJHDmdwKkfAYkHPXvswNB6MuDScXOojGzwjO1yzoZse32bZ5NqVaNGmiKnZkqJPXvswNB6MuDScXOojWmRWuYgd7eg9cC6zaeqWowDs5VsiIZsBSkEEhrKgxjzDUPBs1XkeJ6KaaT7WsGRAOxGtKzf(YgjiujzDU2eA6thLyTfaqab7ZC0zs1uMUjvcAwozb7rzgrU1KPcF500bA3HLax1SySygrU1KPcF500bA3HLax1eYklsJRKSo30nP6yfIrDsGifcpBq2XOxGtaiGGDGZzPzU4gUBsLGMLtp0AiIxeP4zJHDmdwKkfA6J904kjRZnDtQowHyuNea4C2Khmc9cCcI4frkE2yOqtFewyRFgabeSJvNu(ReI4S0gRIN3rePXvswNB6MuDScXOojaM1CwAsyHgJEbobr8IifpBmSJzWIuPLtw4J9OcGac2XQtk)vcrCwAJvXZ7iIp2EunICRjtf(YPPpZkmLMewOXpo1g7zFMvycazfng2zxbAm(XwzXyXYkIL5jXfB5hHPXvswNB6MuDScXOojaM1CwQowIzI(e6f4KrKBnzQWxonDmR5SuDSeZe9jHMeenUGrdO81KmtdJk6brdvKyJJyp1SoNgG8dan8GznNrPyOHhmc)aMgmmtdfinKZ8t0q5KgcMPbGlNPbfOAvwSHgoinuG0aM1CwQowIzI(enaI4KSo3qdGhKgaUCUtJRKSo30nP6yfIrDsamR5SrIry0lWjJi3AYuHVCA6ywZzJeJWcnjiACLK15MUjvhRqmQtcmZkmLMewOXOxGtaiGGDS6KYFLqeNL2yv88oIySyqeN7zfXY8KpYYxcMgxjzDUPBs1XkeJ6KaaT7WsGRAOxGtaiGGDS6KYFLqeNL2yv88oIinUsY6Ct3KQJvig1jbWSMZs1Xsmt0NqVaNaqab7eyfzoxAihc8L7iIXILAJ9SdvXclXm5IeptL15D2vGgJJfZiYTMmv4lNMoM1CwQowIzI(KqtwrJRKSo30nP6yfIrDsamR5SrIry0lWjaeqWobwrMZLgYHaF5oIySyP2yp7qvSWsmtUiXZuzDENDfOX4yXmICRjtf(YPPJznNnsmcl0Kv04kjRZnDtQowHyuNeGCUbjsmRZPXvswNB6MuDScXOojaq7oSe4QgnUsY6Ct3KQJvig1jbMzfMstcl0y0lWjiIZ9SIyzEsbz5lbhlgaciyh4CwAMlUH7MujOj0dPXvswNB6MuDScXOojGcjQZY8Gq2t0lWjiIxeP4zJHDmdwKkfYkH3HIKZhChJk6brdOsdpGy0QwT5M7ca]] )

end