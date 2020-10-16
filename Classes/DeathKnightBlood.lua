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

            noOverride = 324128,

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


    spec:RegisterPack( "Blood", 20201016, [[dOKoWaqivr9iIcUKQQISjIQ(KQQcnkIIofrfRsveVcszwqQULQQQ2Lu9lIOHrK6yQkwgrYZiQ00ufPRrPQTrPsFtOsnovvvohrHADcveVtOIK5ru6EkY(ichKOqAHQQ8qHkPjkujUOQQszKcvK6KefIvQk8svvLQBQQQG2jK0pvvvuhvvvj9ufMQQsFvvvb2Rk)LWGfCyslgWJrzYqDzKnd0NvLgTI60swTQQs8AiXSLYTfYUP63knCk54cvulh0ZPy6IUoeBxvv(oLY4fQW5fQA9uQy(cL9JQVp33BG1KouLsAPK(J0FSB)J0s)5JDVrgVfDdlLHI(s3W1i6g)A7IVHLgFBv899gMfbYOBmQiKMM16XvOcM3aaPAPmIFa3aRjDOkL0sj9hP)y3BySi2HQu2l9nMlmM8d4gyYWUHmWd)A7I5H4cP5mp8V717CYFid8W)mlxacYdFSl68GuslL08h8hYapexNv)LmXj8hYap8)8W)ksXqHhuhZd4cMXZdiwynjEyb5HFGYO8qU8WywXRTM6yt)gTYKM77niJHCgzUVhQFUV3GCfOr473nyWkjyP3aVzNToJ8eQjHfGnnIeaiqVdPiTCdpilpifpipp8mpaGac2XQZk)varCsyJuR17iw3qzzT(nyRZipHAsybytJOlpuL6(EdYvGgHVF3GbRKGLEdaeqW(FAKvblMaOTlUJyXdYZdYKhGAHf0FKNDfJnDkoktA4HyX4bOwyb9h5zxXytVCEqcE4J98GCUHYYA9BOEfPIfuGjnNV8qvU33BqUc0i897gmyLeS0BarCQNvejYv8HhKGhEzyEqEEaI4ftyT2iipilp8uPVHYYA9BerrlmEXckAiSclWqsJmxEO(077nuwwRFdBlSH)JkxajZ6QZOBqUc0i897Ydv7VV3GCfOr473nyWkjyP34zEaabeSJvNv(RaI4KWgPwR3rSUHYYA9BallRgjkxySugD5HQDVV3GCfOr473nyWkjyP3iv4lL9zsB5SWIL8Get8W)jnpelgpKk8LY(mPTCwyXsEq2jEqkP5HyX4bW6Dofqksl3WdYYdp1(BOSSw)gqsTk)va20iYC5L3atGkslVVhQFUV3qzzT(nIkhlaHezh6gKRancF)U8qvQ77nixbAe((DdgSscw6ny72WRnVJvNv(RaI4KWgPwR3HKIJNhKNhKjp8mpW2THxBEhOTlgdlhfc2HKIJNhIfJhEMhsTrE2bA7IXWYrHGDYvGgH5b5CdLL163aOTlwaIaJ)Ydv5EFVHYYA9BaqqdbrP83BqUc0i897Yd1NEFVb5kqJW3VBWGvsWsVHYY6psqofvKHhKyIhKIhIfJhGioXdYYdF4b55biIxmH1AJGDmbwSk5bj4b7k9nuwwRFdfYuNewindD5HQ933BqUc0i897gmyLeS0BaGac2r85TfVWKqYFZ5oI1nuwwRFJw9oNgX)cc(nI88Ydv7EFVHYYA9BOoJmjuBcM2A3GCfOr473LhQX999gklR1VbybjG2U4BqUc0i897Yd1)7(EdLL163aqFflOiHfdfZnixbAe((D5HQm((EdYvGgHVF3GbRKGLEd2Un8AZ7y1zL)kGiojSrQ16DifPLB4bj4bzS03qzzT(nqmKOskYC5H6hPVV3GCfOr473nCnIUbuTdgXrXiaQxbKWcaKmx)gklR1VbuTdgXrXiaQxbKWcaKmx)Yd1pFUV3GCfOr473nuwwRFdw8S2MW1lMaOPM8gmyLeS0BW2THxBEhRoR8xbeXjHnsTwVdPiTCdpipp8mpaGac2XQZk)varCsyJuR17iw8G88aeXPEwrKixXt5bj4bMAsrwr0niqqILcxJOBWIN12eUEXean1KxEO(rQ77nixbAe((DdgSscw6nKjpW2THxBEhRoR8xbeXjHnsTwVdPiTCdpilpyppippKk8LYEwrKixbUiEqcE4J98GC4HyX4bzYdPcFPSNvejYvGlIhKLhK7t5b5CdxJOBO2XmRq1iaxpflOWATrWBOSSw)gQDmZkuncW1tXckSwBe8Yd1pY9(EdYvGgHVF3GbRKGLEdzYdSDB41M3XQZk)varCsyJuR17qksl3WdYZdpZdaiGGDS6SYFfqeNe2i1A9oIfpipparCQNvejYv8uEqcEqU8GC4b55HN5bOwyb9h5zxXytNIJYKgEiwmEaQfwq)rE2vm20lNhKGh(y)nCnIUrebjuYz1iav)9gklR1VrebjuYz1iav)9Yd1pp9(EdYvGgHVF3GbRKGLEdmbGac2HQDwOGTqTjWeaciyhV28B4AeDd1m)N6Krav7SqbBHA7gklR1VHAM)tDYiGQDwOGTqTD5H6h7VV3GCfOr473nyWkjyP3iv4lL9zsB5C3IL8GS8GC)WdYZduCgPSSiChdlaGw5VIYrXAX3W1i6gQz(p1jJaQ2zHc2c12nuwwRFd1m)N6Krav7SqbBHA7Yd1p29(EdYvGgHVF3GbRKGLEdaeqWowDw5VciItcBKATEhXIhKNhWeaciyhQ2zHc2c1MataiGGDelEqEE4zEGIZiLLfH7yyba0k)vuokwl(gUgr3qnZ)Pozeq1oluWwO2UHYYA9BOM5)uNmcOANfkyluBxEO(jUVV3GCfOr473nyWkjyP3aabeSJvNv(RaI4KWgPwR3rSUHYYA9ByTzT(LhQF(V77nixbAe((DdgSscw6nGioz6zfrICfF4bj4Hxg(gklR1VbqBxSivRlpu)iJVV3GCfOr473nyWkjyP3aI4ftyT2iyhtGfRsEqcEWU8Wt4bLL1FKGCkQiZnuwwRFdJnfgv(RiQm5LhQsj999gKRancF)Ubdwjbl9gpZdwu21w9hDdLL163aQLHeysXxEOk1N77nuwwRFdfyJkxZADrRIaUb5kqJW3VlpuLsQ77nixbAe((DdgSscw6nEMhsTrE2bA7IXWYrHGDYvGgH5HyX4HN5b2Un8AZ7aTDXyy5OqWoKuC83qzzT(nWQZk)varCsyJuR1V8qvk5EFVb5kqJW3VBWGvsWsVbaciyhyDsyMlQH7MuzOWdsmXdX9nuwwRFJCJam560LhQs9077nixbAe((DdgSscw6nkNTrL)kWAK(sc7n8Ge8G03qzzT(nyARjuwwRlALjVrRmPW1i6grvwVAwRF5HQu2FFVb5kqJW3VBOSSw)gmT1eklR1fTYK3OvMu4AeDdYyiNrMlpuLYU33BqUc0i897gklR1VbtBnHYYADrRm5nALjfUgr3WKQJvi(YlVHfKyBeGM33d1p33BqUc0i897gUgr3qTJzwHQraUEkwqH1AJG3qzzT(nu7yMvOAeGRNIfuyT2i4LhQsDFVb5kqJW3VBOSSw)gS4zTnHRxmbqtn5niqqILcxJOBWIN12eUEXean1KxE5nIQSE1Sw)(EO(5(EdYvGgHVF3GbRKGLEJzsB5C3IL8GS8G9sZdXIXdYKhEMhEHlIfpippmtAlN7wSKhKLhSRD5b5CdLL1634pnYQGfta02fF5HQu33BqUc0i897gmyLeS0BuoBJk)vG1i9LeY1WdsmXdZK2Y5odbcjpVHYYA9BGjnNfMewOqxEOk377nixbAe((DdgSscw6nm6FKaOTlwyMlQH5b55HYzBu5VcSgPVKWEdpibpinpippaGac2bA7IfM5IA4oIfpippaGac2bA7IfM5IA4oKI0Yn8GS8WNU98Wt4Hxg(gklR1VbM0CwysyHcD5H6tVV3GCfOr473nyWkjyP3yM0wo3TyjpilpyV08W)ZdYKhKsAE4j8aaciyhOTlwyMlQH7iw8GCUHYYA9BumcyrCSaCHzLiy6Ydv7VV3GCfOr473nyWkjyP3yM0wo3Tyjpilpe32ZdYZdwu2FNxKwhsrA5gEqwEW(BOSSw)ggLblWIvAtyPS8YlVHjvhRq899q9Z99gKRancF)Ubdwjbl9gqeVycR1gb7ycSyvYdYoXdFKMhKNhKjp8mpKAJ8SdSozYfg1jxbAeMhIfJhEMhy72WRnVdSozYfg1HKIJNhIfJhaqab7y1zL)kGiojSrQ16DelEqo3qzzT(nWKMZctcluOlpuL6(EdYvGgHVF3GbRKGLEdlk7VZlsRdPiTCdpilp8YW8Wt4bPUHYYA9ByugSalwPnHLYYlpuL799gKRancF)Ubdwjbl9gpZdaiGGDS6SYFfqeNe2i1A9oI1nuwwRFdG2UymSCui4LhQp9(EdYvGgHVF3GbRKGLEdaeqWoW6KWmxud3HuKwUHhKLh(0TNhEcp8YWDkoigss8qSy8Gm5baeqWoW6KWmxud3HuKwUHhKDIhGio1ZkIe5kKlpelgpaGac2bwNeM5IA4oKI0Yn8GSt8Gm5HxgMhqJhy72WRnVd02fJHLJcb7qsXXZdpHhsTrE2bA7IXWYrHGDYvGgH5HNWdsXdYHhIfJhaqab7aRtcZCrnC3KkdfEqwEqU8GC4b55biIxmH1AJGDmbwSk5bjM4bPK(gklR1VrKcHRni54lpuT)(EdYvGgHVF3GbRKGLEdibcjZSc0OBOSSw)gMzLHsJe5mjqCBlmNJ)Ydv7EFVb5kqJW3VBWGvsWsVXZ8aaciyhRoR8xbeXjHnsTwVJyDdLL163yMuykiJHCgD5HACFFVb5kqJW3VBWGvsWsVbBwHVKracvwwRRnEqIjE4t))4b55bzYdaiGG9zkAnPAkt3KkdfEq2jEqM8G98W)ZdglQ1ePcFP00bA7IfaB14b5WdXIXdglQ1ePcFP00bA7IfaB14bj4bP4b5CdLL163aOTlwaSv7Yd1)7(EdYvGgHVF3GbRKGLEdaeqWoW6KWmxud3nPYqHhKDIhSlpippar8IjSwBeSJjWIvjpiXep8X(BOSSw)grkeU2GKJV8qvgFFVb5kqJW3VBWGvsWsVbMaqab7rkefXckaA7I741MZdYZdPcFPSNvejYvGlIhKGhI7U93qzzT(nIuikIfua02fF5H6hPVV3GCfOr473nyWkjyP3aI4ftyT2iipiXep8rAP5b55HN5baeqWowDw5VciItcBKATEhX6gklR1VbW6Kjxy0LhQF(CFVb5kqJW3VBWGvsWsVbeXlMWATrWoMalwL8GSt8Gm5Hp2ZdOXdaiGGDS6SYFfqeNe2i1A9oIfp8eEWEEanEWyrTMiv4lLM(mPWuysyHcXdpHhsTrE2NjfMaqsrHGDYvGgH5HNWdsXdYHhIfJhYkIe5kWfXdYYdFK(gklR1VbM0CwysyHcD5H6hPUV3GCfOr473nyWkjyP3WyrTMiv4lLMoM0CwOowGjMgppiXepi3BOSSw)gysZzH6ybMyA8xEO(rU33BqUc0i897gmyLeS0BySOwtKk8LsthtAoBeyeIhKyIhK7nuwwRFdmP5SrGrOlpu)8077nixbAe((DdgSscw6naqab7y1zL)kGiojSrQ16DelEiwmEaI4upRisKR4P8GS8WldFdLL163yMuykmjSqHU8q9J933BqUc0i897gmyLeS0BaGac2XQZk)varCsyJuR17iw3qzzT(naA7IfaB1U8q9JDVV3GCfOr473nyWkjyP3aabeSZGvKzDHHTiWxQJyXdXIXdP2ip7q1QWcmX2iR1uzTENCfOryEiwmEWyrTMiv4lLMoM0CwOowGjMgppiXepi1nuwwRFdmP5SqDSatmn(lpu)e333BqUc0i897gmyLeS0BaGac2zWkYSUWWwe4l1rS4HyX4HuBKNDOAvybMyBK1AQSwVtUc0impelgpySOwtKk8LsthtAoBeyeIhKyIhK6gklR1VbM0C2iWi0LhQF(V77nuwwRFd26gKiRSw)gKRancF)U8q9Jm((EdLL163aOTlwaSv7gKRancF)U8qvkPVV3GCfOr473nyWkjyP3aI4upRisKRqU8GS8WldZdXIXdaiGGDG1jHzUOgUBsLHcpibpy3BOSSw)gZKctHjHfk0LhQs95(EdYvGgHVF3GbRKGLEdiIxmH1AJGDmbwSk5bj4bPK(gklR1VHczQtICHqYZlV8YB8hbn16hQsjTus)r6p29g2uOx(R5gYirwlmjmpyppOSSwNhALjnD(JBybxWQr3qg4HFTDX8qCH0CMh(396Do5pKbE4FMLlab5Hp2fDEqkPLsA(d(dzGhIRZQ)sM4e(dzGh(FE4FfPyOWdQJ5bCbZ45belSMepSG8WpqzuEixEymR41wtDSPZFWFid8W)wCqmKKW8aabUqIhyBeGM8aa9wUPZdYOmgzLgEWx))NvyeisJhuwwRB4H1BX35puwwRB6wqITraAoHyirLue6UgrtQDmZkuncW1tXckSwBeK)qzzTUPBbj2gbOjAtsIyirLue6eiiXsHRr0elEwBt46fta0utYFWFid8W)wCqmKKW8a9hbJNhYkI4HCM4bLLlKhkdpO)PvtbAuN)qzzTUzkQCSaesKDi(dLL16g0MKeOTlwaIaJh9cCITBdV28owDw5VciItcBKATEhskoE5L5ZSDB41M3bA7IXWYrHGDiP44Jf75uBKNDG2UymSCuiyNCfOry5WFOSSw3G2KKae0qquk)L)qzzTUbTjjvitDsyH0me6f4KYY6psqofvKrIjPIfdI4KSFKhI4ftyT2iyhtGfRsjSR08hklR1nOnjzRENtJ4Fbb)grEIEbobGac2r85TfVWKqYFZ5oIf)HYYADdAtsQoJmjuBcM2A8hklR1nOnjjybjG2Uy(dLL16g0MKeqFflOiHfdfd)HYYADdAtsIyirLuKb9cCITBdV28owDw5VciItcBKATEhsrA5gjKXsZFOSSw3G2KKigsujfHURr0euTdgXrXiaQxbKWcaKmxN)qzzTUbTjjrmKOskcDceKyPW1iAIfpRTjC9IjaAQjrVaNy72WRnVJvNv(RaI4KWgPwR3HuKwUr(Nbqab7y1zL)kGiojSrQ16Del5Hio1ZkIe5kEQem1KISIi(dLL16g0MKeXqIkPi0DnIMu7yMvOAeGRNIfuyT2ii6f4Kmz72WRnVJvNv(RaI4KWgPwR3HuKwUrw7Lpv4lL9SIirUcCrs8XE5elMmtf(szpRisKRaxKSY9PYH)qzzTUbTjjrmKOskcDxJOPicsOKZQraQ(l6f4Kmz72WRnVJvNv(RaI4KWgPwR3HuKwUr(Nbqab7y1zL)kGiojSrQ16Del5Hio1ZkIe5kEQeYvoY)mulSG(J8SRySPtXrzstSyqTWc6pYZUIXME5s8XE(dLL16g0MKeXqIkPi0DnIMuZ8FQtgbuTZcfSfQn0lWjmbGac2HQDwOGTqTjWeaciyhV2C(dLL16g0MKeXqIkPi0DnIMuZ8FQtgbuTZcfSfQn0lWPuHVu2NjTLZDlwkRC)ipfNrkllc3XWcaOv(ROCuSwm)HYYADdAtsIyirLue6UgrtQz(p1jJaQ2zHc2c1g6f4eaciyhRoR8xbeXjHnsTwVJyjpMaqab7q1oluWwO2eycabeSJyj)ZuCgPSSiChdlaGw5VIYrXAX8hklR1nOnjP1M16OxGtaiGGDS6SYFfqeNe2i1A9oIf)HYYADdAtsc02fls1c9cCcI4KPNvejYv8rIxgM)qzzTUbTjjn2uyu5VIOYKOxGtqeVycR1gb7ycSyvkHDFIYY6psqofvKH)qzzTUbTjjHAzibMum6f40Zwu21w9hXFOSSw3G2KKkWgvUM16IwfbWFOSSw3G2KKy1zL)kGiojSrQ16OxGtpNAJ8Sd02fJHLJcb7KRanchl2ZSDB41M3bA7IXWYrHGDiP445puwwRBqBsYCJam56e6f4eaciyhyDsyMlQH7MuzOiXuCZFOSSw3G2KKmT1eklR1fTYKO7Aenfvz9QzTo6f4u5SnQ8xbwJ0xsyVrcP5puwwRBqBssM2AcLL16Iwzs0DnIMiJHCgz4puwwRBqBssM2AcLL16Iwzs0DnIMmP6yfI5p4puwwRB6KXqoJmtS1zKNqnjSaSPre6f4eEZoBDg5jutclaBAejaqGEhsrA5gzLs(Nbqab7y1zL)kGiojSrQ16Del(dLL16MozmKZidAtsQEfPIfuGjnNrVaNaqab7)PrwfSycG2U4oIL8YeQfwq)rE2vm20P4OmPjwmOwyb9h5zxXytVCj(yVC4puwwRB6KXqoJmOnjzefTW4flOOHWkSadjnYGEbobrCQNvejYv8rIxgwEiIxmH1AJGY(uP5puwwRB6KXqoJmOnjPTf2W)rLlGKzD1ze)HYYADtNmgYzKbTjjHLLvJeLlmwkJqVaNEgabeSJvNv(RaI4KWgPwR3rS4puwwRB6KXqoJmOnjjKuRYFfGnnImOxGtPcFPSptAlNfwSuIP)t6yXsf(szFM0wolSyPStsjDSyG17CkGuKwUr2NAp)b)HYYADtpQY6vZA9P)0iRcwmbqBxm6f40mPTCUBXszTx6yXK5ZVWfXs(zsB5C3ILYAx7kh(dzGhKrC2gv(lpG1i9L4bifNrkifrEYdLHhKY()jEyb5Hino4HzsB5mpy22IopyV0)t8WcYdrACWdZK2YzEOCEq5Hx4Iy15puwwRB6rvwVAwRJ2KKysZzHjHfke6f4u5SnQ8xbwJ0xsixJetZK2Y5odbcjp5pKbEiUS()yYdnk5b15bkoktw(lp8RTlMhgZf1W8agUwD(dLL16MEuL1RM16OnjjM0CwysyHcHEboz0)ibqBxSWmxudlF5SnQ8xbwJ0xsyVrcPLhabeSd02flmZf1WDel5bqab7aTDXcZCrnChsrA5gz)0T)jVmm)HYYADtpQY6vZAD0MKSyeWI4yb4cZkrWe6f40mPTCUBXszTx6)xMsj9taqab7aTDXcZCrnChXso8hklR1n9OkRxnR1rBssJYGfyXkTjSuwIEbontAlN7wSu242E5TOS)oViToKI0YnYAp)b)HYYADt3KQJviEctAolmjSqHqVaNGiEXewRnc2XeyXQu2PpslVmFo1g5zhyDYKlmQtUc0iCSypZ2THxBEhyDYKlmQdjfhFSyaiGGDS6SYFfqeNe2i1A9oILC4puwwRB6MuDScXOnjPrzWcSyL2ewklrVaNSOS)oViToKI0YnY(YWprk(dLL16MUjvhRqmAtsc02fJHLJcbrVaNEgabeSJvNv(RaI4KWgPwR3rS4puwwRB6MuDScXOnjzKcHRni5y0lWjaeqWoW6KWmxud3HuKwUr2pD7FYld3P4GyijflMmbqab7aRtcZCrnChsrA5gzNGio1ZkIe5kKBSyaiGGDG1jHzUOgUdPiTCJStY8LHrJTBdV28oqBxmgwokeSdjfh)tsTrE2bA7IXWYrHGDYvGgHFIuYjwmaeqWoW6KWmxud3nPYqrw5kh5HiEXewRnc2XeyXQuIjPKM)qzzTUPBs1XkeJ2KKMzLHsJe5mjqCBlmNJh9cCcsGqYmRanI)qzzTUPBs1XkeJ2KKZKctbzmKZi0lWPNbqab7y1zL)kGiojSrQ16Del(dLL16MUjvhRqmAtsc02fla2QHEboXMv4lzeGqLL16AtIPp9)tEzcGac2NPO1KQPmDtQmuKDsM2))glQ1ePcFP00bA7IfaB1KtSyglQ1ePcFP00bA7IfaB1Kqk5WFOSSw30nP6yfIrBsYifcxBqYXOxGtaiGGDG1jHzUOgUBsLHISt2vEiIxmH1AJGDmbwSkLy6J98hYap8puHOWdlip8RTlMhWlz4bFtEWsDmfvS)NIJKCCN)qzzTUPBs1XkeJ2KKrkefXckaA7IrVaNWeaciypsHOiwqbqBxChV2C5tf(szpRisKRaxKeXD3E(dLL16MUjvhRqmAtscSozYfgHEbobr8IjSwBeuIPpslT8pdGac2XQZk)varCsyJuR17iw8hklR1nDtQowHy0MKetAolmjSqHqVaNGiEXewRnc2XeyXQu2jz(XE0aqab7y1zL)kGiojSrQ16DeRNypAglQ1ePcFP00NjfMctcluONKAJ8SptkmbGKIcb7KRanc)ePKtSyzfrICf4IK9J08hklR1nDtQowHy0MKetAoluhlWetJh9cCYyrTMiv4lLMoM0CwOowGjMgVetYL)qg4H)bAYM5Hrffx5HkYQrrKNAwRZdqkoHhIlKMZ)JgEiUGqXP4bdr8qbYd5mfppuoRHGjEayZzEqbQwLfz4HfYdfipGjnNfQJfyIPXZdGiolR1n8a4c5bGnN78hklR1nDtQowHy0MKetAoBeyec9cCYyrTMiv4lLMoM0C2iWiKetYL)qzzTUPBs1XkeJ2KKZKctHjHfke6f4eaciyhRoR8xbeXjHnsTwVJyflgeXPEwrKixXtL9LH5puwwRB6MuDScXOnjjqBxSayRg6f4eaciyhRoR8xbeXjHnsTwVJyXFOSSw30nP6yfIrBssmP5SqDSatmnE0lWjaeqWodwrM1fg2IaFPoIvSyP2ip7q1QWcmX2iR1uzTENCfOr4yXmwuRjsf(sPPJjnNfQJfyIPXlXKu8hklR1nDtQowHy0MKetAoBeyec9cCcabeSZGvKzDHHTiWxQJyflwQnYZouTkSatSnYAnvwR3jxbAeowmJf1AIuHVuA6ysZzJaJqsmjf)HYYADt3KQJvigTjjzRBqISYAD(dLL16MUjvhRqmAtsc02fla2QXFOSSw30nP6yfIrBsYzsHPWKWcfc9cCcI4upRisKRqUY(YWXIbGac2bwNeM5IA4Ujvgksyx(dLL16MUjvhRqmAtsQqM6KixiK8e9cCcI4ftyT2iyhtGfRsjKs6BOi58cVXOIIR8aA8qCAcLQvxE5D]] )

end