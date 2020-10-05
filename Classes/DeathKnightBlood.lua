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


    spec:RegisterPack( "Blood", 20200913, [[dGe8MaqiGkpsrPUeLsvTjvf(eLsLgfLcNIsjRIsrVciMfb1Tuus7sk)cOmmc4yQsTmcYZuv00aQQRjvyBkk8nff14uuIZrjQwhqv4DukvyEuc3tr2hb6GavrluvYdPeLMiLO4IkksnsGQuDsGQKvsj9sffHDQQ0rvuK8ufMQIQVsPur7vP)svdMIdtAXaEmstg0LrTzO6ZQQgTQ40swTIIOxdKMnvUTu1Uf9BvgoHooqvklhYZjA6cxhkBNsKVlvA8ukLZlv06PuQY8PuTFeVV357aQbVFfsaHeqal)9NT3F(PL)5oIof5DiQuq1FEhP2Z74L7o4oe1oDNc357qEyikVJr1J50OU0YIu8yhayLlaVYfyhqn49RqciKacy5V)S9(ZpTCHMLDifz6(vOoeyhpfeY5cSdilP7y2eZl3DqIXYWA8qmZez9)eeRZMygSyW9amIyE)PWeJqciKaeReRZMySSpA(ZsWdI1ztmZkXmtHvuqjgnHedSqrNedMiudMyoCI5fo4jXehXmEu411Pju22HRKHCNVdwk5KYYD((99oFhCQaogUV2bfvbJkDhWlA0lPCginyOh3P9ShadLne3RvkjgligHiMpigWrmay44nOM0k)9iSK9Dzv8YgM4ouAuxUd6LuodKgm0J70EEJ9Rq78DWPc4y4(AhuufmQ0DaGHJ3SK2lwOI6bC3bByIeZheJnigKwqpBjoJMcHYgBBLmKeJD7edslONTeNrtHqzRsIrqI5DheJT2HsJ6YDOz1R(d3dznE2y)(5oFhCQaogUV2bfvbJkDhiSKBr1Z(48VjgbjMFkKy(Gyqyzr9IxxgrmwqmGVa7qPrD5o65(d1P)W9omAb9qeR9Yn2VG)oFhknQl3r3d5GwIR0Jy5LAs5DWPc4y4(AJ9Bh78DWPc4y4(AhuufmQ0DaoIbadhVb1Kw5VhHLSVlRIx2We3HsJ6YDGkrrh7R0lfvkVXg7aY4kMl2573378DO0OUCh9vc94iMT94DWPc4y4(AJ9Rq78DWPc4y4(AhuufmQ0DqVZbVUzdQjTYFpclzFxwfVSHyf2jX8bXydIbCed9oh86Mna3DqiQsqzudXkStIXUDIbCetOooJgG7oievjOmQXPc4yiXyRDO0OUChaU7GECmuNBSF)CNVdLg1L7aGrsgbAL)7GtfWXW91g7xWFNVdovahd3x7GIQGrLUdLgLLypNCFXsIrWjIriIXUDIbHLmXybX8My(Gyqyzr9Ixxg1GmErRGyeKyMHa7qPrD5ouevt2lI5K8g73o257GtfWXW91oOOkyuP7aadhVHLpNRtVmqC(hpnmXDO0OUChU6)jK(zsm4FpNXg73zSZ3HsJ6YDOjLLbsDEQ6C7GtfWXW91g73zENVdLg1L7aVqmG7o4o4ubCmCFTX(Dw257qPrD5oa0F)H7durbvUdovahd3xBSFT8D(o4ubCmCFTdkQcgv6oO35Gx3Sb1Kw5VhHLSVlRIx2qCVwPKyeKySCb2HsJ6YDGjzFfCVCJ97Bb257GtfWXW91oOOkyuP7aadhVb1Kw5VhHLSVlRIx2We3HsJ6YDiErD5g733V357GtfWXW91oOOkyuP7aHLSSfvp7JZ)MyeKy(PWDO0OUChaU7G(qf3y)(wOD(o4ubCmCFTdkQcgv6oaWWXBaxYE5tXoytgkfuIrWjIzM3HsJ6YDexpGmUK3y)((ZD(o4ubCmCFTdkQcgv6oqyzr9Ixxg1GmErRGyeKyMbXytIrPrzj2Zj3xSChknQl3HSRI6R833xYyJ97BWFNVdovahd3x7GIQGrLUdWrmIC0uxzjEhknQl3bslj7HSc3y)(UJD(o4ubCmCFTdkQcgv6oahXeQJZOb4UdcrvckJACQaogsm2TtmGJyO35Gx3Sb4UdcrvckJAiwHDUdLg1L7aQjTYFpclzFxwfVCJ977zSZ3HsJ6YDOaxFLAux6DvpWo4ubCmCFTX(99mVZ3bNkGJH7RDqrvWOs3rL0RVYFpu71F23HKyeKyeyhknQl3bvDoVsJ6sVRKXoCLm8P2Z7OVI6xJ6Yn2VVNLD(o4ubCmCFTdLg1L7GQoNxPrDP3vYyhUsg(u75DWsjNuwUX(9TLVZ3bNkGJH7RDO0OUChu158knQl9Usg7WvYWNApVdzOjurWn2yhIiME9aASZ3VV357GtfWXW91g7xH257GtfWXW91g73p357GtfWXW91g7xWFNVdovahd3xBSF7yNVdLg1L7q8I6YDWPc4y4(AJn2rFf1Vg1L78977D(o4ubCmCFTdkQcgv6oEy1fpnrAqmwqmDiaXy3oXydIbCeZp6WejMpiMhwDXttKgeJfeZmMbXyRDO0OUChws7flur9aU7GBSFfANVdovahd3x7GIQGrLUJkPxFL)EO2R)S)tjXi4eX8WQlEAumeIZyhknQl3bK14XldubkVX(9ZD(o4ubCmCFTdkQcgv6oKQLypG7oOx(uSdsmFqmvsV(k)9qTx)zFhsIrqIraI5dIbadhVb4Ud6Lpf7GnmrI5dIbadhVb4Ud6Lpf7Gne3RvkjgliM3ToigBsm)u4ouAuxUdiRXJxgOcuEJ9l4VZ3bNkGJH7RDqrvWOs3XdRU4PjsdIXcIPdbiMzLySbXiKaeJnjgamC8gG7oOx(uSd2WejgBTdLg1L7OOmWHLqp(HIkWG8g73o257GtfWXW91oOOkyuP74Hvx80ePbXybXmZDqmFqmIC0(FomxdX9ALsIXcIPJDO0OUChsLIk8IwQZlQ0yJn2Hm0eQi4oF)(ENVdovahd3x7GIQGrLUdewwuV41LrniJx0kiglMiM3cqmFqm2GyahXeQJZObCjlJd134ubCmKySBNyahXqVZbVUzd4swghQVHyf2jXy3oXaGHJ3GAsR83JWs23LvXlByIeJT2HsJ6YDaznE8YavGYBSFfANVdovahd3x7GIQGrLUdroA)phMRH4ETsjXybX8tHeJnjgH2HsJ6YDivkQWlAPoVOsJn2VFUZ3bNkGJH7RDqrvWOs3b4igamC8gutAL)EewY(USkEzdtChknQl3bG7oievjOmAJ9l4VZ3bNkGJH7RDqrvWOs3bagoEd4s2lFk2bBiUxRusmwqmVBDqm2Ky(PWgBBmflyIXUDIXgedagoEd4s2lFk2bBiUxRusmwmrmiSKBr1Z(48Fsm2Ttmay44nGlzV8PyhSH4ETsjXyXeXydI5Ncjgqig6Do41nBaU7GquLGYOgIvyNeJnjMqDCgna3DqiQsqzuJtfWXqIXMeJqeJTig72jgamC8gWLSx(uSd2KHsbLySGy(KySfX8bXGWYI6fVUmQbz8IwbXi4eXiKa7qPrD5o6ve66I4eUX(TJD(o4ubCmCFTdkQcgv6oqmoILpkGJ3HsJ6YDiFukOo2hpShl7EO4PZn2VZyNVdovahd3x7GIQGrLUdWrmay44nOM0k)9iSK9Dzv8YgM4ouAuxUJhwrHNLsoP8g73zENVdovahd3x7GIQGrLUd6JI(zPhhP0OUuDeJGteZ72SqmFqm2GyaWWXBpC)jdvwYMmukOeJfteJniMoiMzLyKISZ5df9ZHSb4Ud6bUYrm2IySBNyKISZ5df9ZHSb4Ud6bUYrmcsmcrm2AhknQl3bG7oOh4k3g73zzNVdovahd3x7GIQGrLUdamC8gWLSx(uSd2KHsbLySyIyMbX8bXGWYI6fVUmQbz8IwbXi4eX8UJDO0OUCh9kcDDrCc3y)A578DWPc4y4(AhuufmQ0DGWYI6fVUmIyeCIyElGaeZhed4igamC8gutAL)EewY(USkEzdtChknQl3bWLSmou)g733cSZ3bNkGJH7RDqrvWOs3bcllQx86YOgKXlAfeJfteJniM3DqmGqmay44nOM0k)9iSK9Dzv8YgMiXytIPdIbeIrkYoNpu0phY2dROWldubktm2Kyc1Xz0EyffaiwbLrnovahdjgBsmcrm2IySBNyIQN9X5HftmwqmVfyhknQl3bK14XldubkVX(997D(o4ubCmCFTdkQcgv6oKISZ5df9ZHSbznE8Ac9qMQDsmcormFUdLg1L7aYA841e6Hmv7CJ97BH257GtfWXW91oOOkyuP7qkYoNpu0phYgK14r6HymXi4eX85ouAuxUdiRXJ0dX4n2VV)CNVdovahd3x7GIQGrLUdamC8gutAL)EewY(USkEzdtKySBNyqyj3IQN9X5bFIXcI5Nc3HsJ6YD8Wkk8YavGYBSFFd(78DWPc4y4(AhuufmQ0DaGHJ3GAsR83JWs23LvXlByI7qPrD5oaC3b9ax52y)(UJD(o4ubCmCFTdkQcgv6oaWWXBuu1lV0lPhg6NByIeJD7etOooJgsflOhY0Rx8Kvux24ubCmKySBNyKISZ5df9ZHSbznE8Ac9qMQDsmcormcTdLg1L7aYA841e6Hmv7CJ977zSZ3bNkGJH7RDqrvWOs3bagoEJIQE5LEj9Wq)CdtKySBNyc1Xz0qQyb9qME9INSI6YgNkGJHeJD7eJuKDoFOOFoKniRXJ0dXyIrWjIrODO0OUChqwJhPhIXBSFFpZ78DO0OUCh0lLy9IrD5o4ubCmCFTX(99SSZ3HsJ6YDa4Ud6bUYTdovahd3xBSFFB578DWPc4y4(AhuufmQ0DGWsUfvp7JZ)jXybX8tHeJD7edagoEd4s2lFk2bBYqPGsmcsmZyhknQl3XdROWldubkVX(vib257GtfWXW91oOOkyuP7aHLf1lEDzudY4fTcIrqIrib2HsJ6YDOiQMSpoeIZyJn2yhwIrY6Y9RqciKacmlcnJ27D0vrzL)YDaE1lEOGHetheJsJ6sIXvYq2iw3Hi6WlhVJztmVC3bjgldRXdXmtK1)tqSoBIzWIb3dWiI59NctmcjGqcqSsSoBIXY(O5plbpiwNnXmReZmfwrbLy0esmWcfDsmyIqnyI5WjMx4GNetCeZ4rHxxNMqzJyLyD2eZmTTXuSGHedaJFiMyOxpGgeda)xPSrmGNuklgsIjVCwFuupoMJyuAuxkjMlDD2iwvAuxkBIiME9aAmH7ujOeRknQlLnretVEanazcm87GeRknQlLnretVEanazcmf7VNZqJ6sI1ztmJufLpxqmiTGedagoodjgzOHKyay8dXed96b0Gya4)kLeJMqIreXZQ4frL)etjjg4LCJyvPrDPSjIy61dObitGjtvu(CHxgAijwvAuxkBIiME9aAaYeyIxuxsSsSoBIzM22ykwWqIHTeJ6KyIQNjM4HjgLghIykjXOwslNc44gXQsJ6s5uFLqpoIzBpMyvPrDPeKjWaC3b94yOofUWNO35Gx3Sb1Kw5VhHLSVlRIx2qSc78dBao6Do41nBaU7GquLGYOgIvyN2TdUqDCgna3DqiQsqzuJtfWXqBrSQ0OUucYeyamsYiqR8NyvPrDPeKjWuevt2lI5KSWf(KsJYsSNtUVyPGtcz3oclzlE)bcllQx86YOgKXlAfcodbiwvAuxkbzcmx9)es)mjg8VNZq4cFcadhVHLpNRtVmqC(hpnmrIvLg1LsqMattkldK68u15iwvAuxkbzcm8cXaU7GeRknQlLGmbgG(7pCFGkkOsIvLg1LsqMadtY(k4EPWf(e9oh86MnOM0k)9iSK9Dzv8YgI71kLcA5cqSQ0OUucYeyIxuxkCHpbGHJ3GAsR83JWs23LvXlByIeRknQlLGmbgG7oOpurHl8jewYYwu9Spo)Bb)PqIvLg1LsqMalUEazCjlCHpbGHJ3aUK9YNIDWMmukOconZeRknQlLGmbMSRI6R833xYq4cFcHLf1lEDzudY4fTcbNHnvAuwI9CY9fljwvAuxkbzcmKws2dzfkCHpboroAQRSetSQ0OUucYeyqnPv(7ryj77YQ4Lcx4tGluhNrdWDheIQeug14ubCm0UDWrVZbVUzdWDheIQeug1qSc7KyvPrDPeKjWuGRVsnQl9UQhGyvPrDPeKjWOQZ5vAux6DLmeo1EEQVI6xJ6sHl8PkPxFL)EO2R)SVdPGcqSQ0OUucYeyu158knQl9UsgcNAppXsjNuwsSQ0OUucYeyu158knQl9UsgcNAppjdnHkcsSsSQ0OUu2yPKtklNOxs5mqAWqpUt7zHl8j4fn6LuodKgm0J70E2dGHYgI71kLwi0hGdadhVb1Kw5VhHLSVlRIx2WejwvAuxkBSuYjLLGmbMMvV6pCpK14r4cFcadhVzjTxSqf1d4Ud2We)WgiTGE2sCgnfcLn22kziTBhPf0ZwIZOPqOSvPGV7WweRknQlLnwk5KYsqMaRN7puN(d37WOf0drS2lfUWNqyj3IQN9X5Fl4pf(bcllQx86YilaFbiwvAuxkBSuYjLLGmbw3d5GwIR0Jy5LAszIvLg1LYglLCszjitGHkrrh7R0lfvklCHpboamC8gutAL)EewY(USkEzdtKyLyvPrDPS1xr9RrD5KL0EXcvupG7oOWf(0dRU4Pjsdl6qa72Tb4(rhM4hpS6INMinSygZWweReRZMyaVs61x5pXa1E9NjgedEdRqCpNbXusIrOoS9jMdNy6vBJyEy1fpeJ8CNWethcy7tmhoX0R2gX8WQlEiMkjgLy(rhMyJyvPrDPS1xr9RrDjitGbznE8YavGYcx4tvsV(k)9qTx)z)NsbNEy1fpnkgcXzqSsSoBIXYCPTBqmooignjg22kzu5pX8YDhKygpf7GedeDInIvLg1LYwFf1Vg1LGmbgK14XldubklCHpjvlXEa3DqV8Pyh8JkPxFL)EO2R)SVdPGc8bagoEdWDh0lFk2bByIFaGHJ3aC3b9YNIDWgI71kLw8U1Hn)PqIvIvLg1LYwFf1Vg1LGmbwrzGdlHE8dfvGbzHl8PhwDXttKgw0HaZQnesaBcGHJ3aC3b9YNIDWgMOTiwjwvAuxkB9vu)AuxcYeysLIk8IwQZlQ0q4cF6Hvx80ePHfZChFiYr7)5WCne3RvkTOdIvIvLg1LYMm0eQi4eK14XldubklCHpHWYI6fVUmQbz8IwHftVf4dBaUqDCgnGlzzCO(gNkGJH2Tdo6Do41nBaxYY4q9neRWoTBhadhVb1Kw5VhHLSVlRIx2WeTfXQsJ6sztgAcveeKjWKkfv4fTuNxuPHWf(KihT)NdZ1qCVwP0IFk0McrSQ0OUu2KHMqfbbzcma3DqiQsqzKWf(e4aWWXBqnPv(7ryj77YQ4LnmrIvLg1LYMm0eQiiitG1Ri01fXju4cFcadhVbCj7Lpf7Gne3RvkT4DRdB(tHn22ykwW2TBdamC8gWLSx(uSd2qCVwP0IjewYTO6zFC(pTBhadhVbCj7Lpf7Gne3RvkTyYg)uii07CWRB2aC3bHOkbLrneRWoTzOooJgG7oievjOmQXPc4yOnfYw2TdGHJ3aUK9YNIDWMmukOw8PT(aHLf1lEDzudY4fTcbNesaIvLg1LYMm0eQiiitGjFukOo2hpShl7EO4PtHl8jeJJy5Jc4yIvLg1LYMm0eQiiitG9Wkk8SuYjLfUWNahagoEdQjTYFpclzFxwfVSHjsSQ0OUu2KHMqfbbzcma3DqpWvoHl8j6JI(zPhhP0OUuDco9UnlFydamC82d3FYqLLSjdLcQft2OJzvkYoNpu0phYgG7oOh4kNTSBxkYoNpu0phYgG7oOh4kNGczlIvLg1LYMm0eQiiitG1Ri01fXju4cFcadhVbCj7Lpf7GnzOuqTyAgFGWYI6fVUmQbz8IwHGtV7GyvPrDPSjdnHkccYeyaxYY4q9cx4tiSSOEXRlJeC6Tac8b4aWWXBqnPv(7ryj77YQ4LnmrIvLg1LYMm0eQiiitGbznE8YavGYcx4tiSSOEXRlJAqgVOvyXKnE3biay44nOM0k)9iSK9Dzv8YgMOn7aePi7C(qr)CiBpSIcVmqfOSnd1Xz0EyffaiwbLrnovahdTPq2YU9O6zFCEyXw8waIvLg1LYMm0eQiiitGbznE8Ac9qMQDkCHpjfzNZhk6NdzdYA841e6Hmv7uWPpjwNnXy7ud6dXmQEllXu9IoUNZqJ6sIbXGheJLH14X2vsmwgm22bXizMykCIjE4ojMkPomitmax8qmkq5QOyjXCiIPWjgiRXJxtOhYuTtIbhlPrDPKyWpeXaCXtJyvPrDPSjdnHkccYeyqwJhPhIXcx4tsr258HI(5q2GSgpspeJfC6tIvLg1LYMm0eQiiitG9Wkk8YavGYcx4tay44nOM0k)9iSK9Dzv8YgMOD7iSKBr1Z(48GVf)uiXQsJ6sztgAcveeKjWaC3b9ax5eUWNaWWXBqnPv(7ryj77YQ4LnmrIvLg1LYMm0eQiiitGbznE8Ac9qMQDkCHpbGHJ3OOQxEPxspm0p3WeTBpuhNrdPIf0dz61lEYkQlBCQaogA3UuKDoFOOFoKniRXJxtOhYuTtbNeIyvPrDPSjdnHkccYeyqwJhPhIXcx4tay44nkQ6Lx6L0dd9Znmr72d1Xz0qQyb9qME9INSI6YgNkGJH2TlfzNZhk6NdzdYA8i9qmwWjHiwvAuxkBYqtOIGGmbg9sjwVyuxsSQ0OUu2KHMqfbbzcma3DqpWvoIvLg1LYMm0eQiiitG9Wkk8YavGYcx4tiSKBr1Z(48FAXpfA3oagoEd4s2lFk2bBYqPGk4miwvAuxkBYqtOIGGmbMIOAY(4qiodHl8jewwuV41LrniJx0keuib2HIfphAhJQ3YsmGqmG3zqlxTXg7ca]] )

end