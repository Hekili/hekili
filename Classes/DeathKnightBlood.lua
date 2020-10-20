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
                    stat.haste = stat.haste + 0.08
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
                    stat.haste = stat.haste + ( state.spec.blood and 0.08 or 0.15 )
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


    spec:RegisterPack( "Blood", 20201017, [[dOehXaqivP6rer5sQQkLnru8jvvL0Oik1POuyvcv8kiLzbP6wQQQAxs5xePggrLJPQyzejpJiY0eQ01OuABcv13ikX4uvvCoIsY6ikP6DcvHmpIQUNIAFeHdkufSqvvEOqvQjkuLCrvvvYifQc1jjkPSsvjVuvvL6MQQkr7es6NQQkvhvvvf9ufMQQsFvvvjSxv(lHbl4WKwmGhJYKH6YiBgOpRkgTICAjRwvvfEnKy2s1TfYUP63knCk54cvrlh0ZPy6IUoeBxvv(oLQXtevNxvkRNsrZxOSFu995(EdSM0HQuYjLCFK7JS0KsQ4ARKKv3iFZIUHLYqrFOB4AeDJF9DX3WsFRVk((EdZIaz0ngvesxZA94nubZBaGu9uwZpGBG1KouLsoPK7JCFKLMusfxBL0)CdJfXouLYw5UXuHXKFa3atg2nKmE4xFxmpeVinN4H)BVEMs(ljJh(3z5cqqE4JSGopiLCsjh)f)LKXdX7j1FiJSo)LKXd)pp8FIumu4b1X8aUG5B8aIfwtIhwqE4hy8apKlpmMu8AVRo20UrVmP5(EdYyiNrM77H6N77nixb6e((DdgSscw6nWB2yRZipHAsybyxJibac0Bqksl3WdYZdsXdYWdVZdaiGGnS6SYFeqeNe2j1A9gI1nuwwRFd26mYtOMewa21i6YdvPUV3GCfOt473nyWkjyP3aabeS9NgzvWIja67IBiw8Gm8GS5bOwyb9h5ztXytJK8YKgEiwmEaQfwq)rE2um20kNhKGh(ylpyJBOSSw)gQxrQybfysZPlpuL099gKRaDcF)Ubdwjbl9gqeNAzfrICfF4bj4HhgMhKHhGiEXewRDcYdYZdXvUBOSSw)gru0cFtSGIocRWcmK0iZLhQX9(EdLL163W(c74)OYfqYSU6m6gKRaDcF)U8q1277nixb6e((DdgSscw6nENhaqabBy1zL)iGiojStQ16neRBOSSw)gWYYQtIYfglLrxEOg)77nixb6e((DdgSscw6nsf(qzBI0EojSyjpiXmp8pYXdXIXdPcFOSnrApNewSKhKFMhKsoEiwmEaSEMsbKI0Yn8G88qCT9gklR1VbKuRYFeGDnImxE5nWeOI0Z77H6N77nuwwRFJOYXcqir2KUb5kqNW3VlpuL6(EdYvGoHVF3GbRKGLEd2UD8A3By1zL)iGiojStQ16niP434bz4bzZdVZdSD741U3a67IXWYrHGniP434HyX4H35Hu7KNnG(UymSCuiyJCfOtyEWg3qzzT(na67IfGiW3U8qvs33BOSSw)gae0qquk)5gKRaDcF)U8qnU33BqUc0j897gmyLeS0BOSS(JeKtrfz4bjM5bP4HyX4biIt8G88WhEqgEaI4ftyT2jydtGfRsEqcEi(YDdLL163qHm1jHfs3qxEOA799gKRaDcF)Ubdwjbl9gaiGGneFA7VjmjK8NCQHyDdLL163OxptPr8FGGFIipV8qn(33BOSSw)gQZitc1UGP9(nixb6e((D5HQSCFVHYYA9BawqcOVl(gKRaDcF)U8q9FUV3qzzT(na0hXcksyXqXCdYvGoHVFxEOkRUV3GCfOt473nyWkjyP3GTBhV29gwDw5pciItc7KATEdsrA5gEqcEqwj3nuwwRFdedjQKImxEO(rU77nixb6e((DdxJOBavBIrCumcG6rajSaajZ1VHYYA9BavBIrCumcG6rajSaajZ1V8q9ZN77nixb6e((DdLL163G9gRVjC9Ija6QjVbdwjbl9gSD741U3WQZk)rarCsyNuR1Bqksl3WdYWdVZdaiGGnS6SYFeqeNe2j1A9gIfpidparCQLvejYvexEqcEGPMuKveDdceKyPW1i6gS3y9nHRxmbqxn5LhQFK6(EdYvGoHVF3qzzT(nuBAMuOAeGRNIfuyT2j4nyWkjyP3q28aB3oET7nS6SYFeqeNe2j1A9gKI0Yn8G88GT8Gm8qQWhkBzfrICf4I4bj4Hp2Yd2GhIfJhKnpKk8HYwwrKixbUiEqEEqsXLhSXnCnIUHAtZKcvJaC9uSGcR1obV8q9JKUV3GCfOt473nuwwRFJicsOKtQraQ(ZnyWkjyP3q28aB3oET7nS6SYFeqeNe2j1A9gKI0Yn8Gm8W78aaciydRoR8hbeXjHDsTwVHyXdYWdqeNAzfrICfXLhKGhKepydEqgE4DEaQfwq)rE2um20ijVmPHhIfJhGAHf0FKNnfJnTY5bj4Hp2EdxJOBerqcLCsncq1FU8q9tCVV3GCfOt473nuwwRFd1m9N6KravBUqbBHA)gmyLeS0BGjaeqWguT5cfSfQDbMaqabB41UFdxJOBOMP)uNmcOAZfkylu7xEO(X277nixb6e((DdLL163qnt)Pozeq1MluWwO2Vbdwjbl9gPcFOSnrApNAwSKhKNhK0hEqgEGINiLLfHByyba0l)ruokwl(gUgr3qnt)Pozeq1MluWwO2V8q9t8VV3GCfOt473nuwwRFd1m9N6KravBUqbBHA)gmyLeS0BaGac2WQZk)rarCsyNuR1Biw8Gm8aMaqabBq1MluWwO2fycabeSHyXdYWdVZdu8ePSSiCddlaGE5pIYrXAX3W1i6gQz6p1jJaQ2CHc2c1(LhQFKL77nixb6e((DdgSscw6naqabBy1zL)iGiojStQ16neRBOSSw)gwBwRF5H6N)5(EdYvGoHVF3GbRKGLEdiItMwwrKixXhEqcE4HHVHYYA9Ba03fls16Yd1pYQ77nixb6e((DdgSscw6nGiEXewRDc2WeyXQKhKGhIppehEqzz9hjiNIkYCdLL163WyxHrL)iIktE5HQuYDFVb5kqNW3VBWGvsWsVX78GfLnTx)r3qzzT(nGAzibMu8LhQs95(EdLL163qb2OY1Swx0RiGBqUc0j897YdvPK6(EdYvGoHVF3GbRKGLEJ35Hu7KNnG(UymSCuiyJCfOtyEiwmE4DEGTBhV29gqFxmgwokeSbjf)2nuwwRFdS6SYFeqeNe2j1A9lpuLss33BqUc0j897gmyLeS0BaGac2awNeMPI64Mjvgk8GeZ8GSCdLL163i3iatUoD5HQuX9(EdYvGoHVF3GbRKGLEJYzBu5pcSgPpKWwdpibpi3nuwwRFdM27cLL16IEzYB0ltkCnIUruL1JM16xEOkLT33BqUc0j897gklR1Vbt7DHYYADrVm5n6LjfUgr3GmgYzK5YdvPI)99gKRaDcF)UHYYA9BW0ExOSSwx0ltEJEzsHRr0nmP6yfIV8YBybj2gbO599q9Z99gKRaDcF)UHRr0nuBAMuOAeGRNIfuyT2j4nuwwRFd1MMjfQgb46PybfwRDcE5HQu33BqUc0j897gklR1Vb7nwFt46fta0vtEdceKyPW1i6gS3y9nHRxmbqxn5LxEJOkRhnR1VVhQFUV3GCfOt473nyWkjyP3yI0Eo1SyjpippyRC8qSy8GS5H35Hh4IyXdYWdtK2ZPMfl5b55H4hFEWg3qzzT(n(tJSkyXea9DXxEOk199gKRaDcF)Ubdwjbl9gLZ2OYFeynsFiHKm8GeZ8WeP9CQXqGqYZBOSSw)gysZjHjHfk0LhQs6(EdYvGoHVF3GbRKGLEdJ(hja67IfMPI6yEqgEOC2gv(JaRr6djS1WdsWdYXdYWdaiGGnG(UyHzQOoUHyXdYWdaiGGnG(UyHzQOoUbPiTCdpipp8PzlpehE4HHVHYYA9BGjnNeMewOqxEOg377nixb6e((DdgSscw6ns1rP8hEqgEaabeSbrCsKQvdV2DEqgEOC2gv(JaRr6djKKHhKGhMiTNtTivY5H4WdY1(CdLL163aI4KivRlpuT9(EdYvGoHVF3GbRKGLEJjs75uZIL8G88GTYXd)ppiBEqk54H4WdaiGGnG(UyHzQOoUHyXd24gklR1VrXiGfXXcWfMvIGPlpuJ)99gKRaDcF)Ubdwjbl9gtK2ZPMfl5b55bzXwEqgEWIY2Z0I0Bqksl3WdYZd2EdLL163WOmybwSs7clLLxE5nmP6yfIVVhQFUV3GCfOt473nyWkjyP3aI4ftyT2jydtGfRsEq(zE4JC8Gm8GS5H35Hu7KNnG1jtUWOg5kqNW8qSy8W78aB3oET7nG1jtUWOgKu8B8qSy8aaciydRoR8hbeXjHDsTwVHyXd24gklR1VbM0CsysyHcD5HQu33BqUc0j897gmyLeS0Byrz7zAr6nifPLB4b55HhgMhIdpi1nuwwRFdJYGfyXkTlSuwE5HQKUV3GCfOt473nyWkjyP34DEaabeSHvNv(JaI4KWoPwR3qSUHYYA9Ba03fJHLJcbV8qnU33BqUc0j897gmyLeS0BaGac2awNeMPI64gKI0Yn8G88WNMT8qC4HhgUrsoXqsIhIfJhKnpaGac2awNeMPI64gKI0Yn8G8Z8aeXPwwrKixHK4HyX4baeqWgW6KWmvuh3GuKwUHhKFMhKnp8WW8aA8aB3oET7nG(UymSCuiydsk(nEio8qQDYZgqFxmgwokeSrUc0jmpehEqkEWg8qSy8aaciydyDsyMkQJBMuzOWdYZdsIhSbpidpar8IjSw7eSHjWIvjpiXmpiLC3qzzT(nIuiCTdjhF5HQT33BqUc0j897gmyLeS0BajqizMuGoDdLL163WmPmu6KiNibIBFH50BxEOg)77nixb6e((DdgSscw6nENhaqabBy1zL)iGiojStQ16neRBOSSw)gtKctbzmKZOlpuLL77nixb6e((DdgSscw6nytk8HmcqOYYADTZdsmZdFA)dpidpiBEaabeSnrrRjvtzAMuzOWdYpZdYMhSLh(FEWyr9Uiv4dLMgqFxSayRopydEiwmEWyr9Uiv4dLMgqFxSayRopibpifpyJBOSSw)ga9DXcGT6xEO(p33BqUc0j897gmyLeS0BaGac2awNeMPI64Mjvgk8G8Z8q85bz4biIxmH1ANGnmbwSk5bjM5Hp2EdLL163isHW1oKC8LhQYQ77nixb6e((DdgSscw6nWeaciylsHOiwqbqFxCdV2DEqgEiv4dLTSIirUcCr8Ge8GS0S9gklR1VrKcrrSGcG(U4lpu)i399gKRaDcF)Ubdwjbl9gqeVycR1ob5bjM5HpYjhpidp8opaGac2WQZk)rarCsyNuR1Biw3qzzT(nawNm5cJU8q9ZN77nixb6e((DdgSscw6nGiEXewRDc2WeyXQKhKFMhKnp8XwEanEaabeSHvNv(JaI4KWoPwR3qS4H4Wd2YdOXdglQ3fPcFO00MifMctcluiEio8qQDYZ2ePWeaskkeSrUc0jmpehEqkEWg8qSy8qwrKixbUiEqEE4JC3qzzT(nWKMtctcluOlpu)i199gKRaDcF)Ubdwjbl9gglQ3fPcFO00WKMtc1XcmX034bjM5bjDdLL163atAojuhlWetF7Yd1ps6(EdYvGoHVF3GbRKGLEdJf17IuHpuAAysZjJaJq8GeZ8GKUHYYA9BGjnNmcmcD5H6N4EFVb5kqNW3VBWGvsWsVbaciydRoR8hbeXjHDsTwVHyXdXIXdqeNAzfrICfXLhKNhEy4BOSSw)gtKctHjHfk0LhQFS9(EdYvGoHVF3GbRKGLEdaeqWgwDw5pciItc7KATEdX6gklR1VbqFxSayR(LhQFI)99gKRaDcF)Ubdwjbl9gaiGGngSImRlmSfb(qnelEiwmEi1o5zdQwfwGj2gzTMkR1BKRaDcZdXIXdglQ3fPcFO00WKMtc1XcmX034bjM5bPUHYYA9BGjnNeQJfyIPVD5H6hz5(EdYvGoHVF3GbRKGLEdaeqWgdwrM1fg2IaFOgIfpelgpKAN8SbvRclWeBJSwtL16nYvGoH5HyX4bJf17IuHpuAAysZjJaJq8GeZ8Gu3qzzT(nWKMtgbgHU8q9Z)CFVHYYA9BWw3GezL163GCfOt473LhQFKv33BOSSw)ga9DXcGT63GCfOt473LhQsj399gKRaDcF)Ubdwjbl9gqeNAzfrICfsIhKNhEyyEiwmEaabeSbSojmtf1XntQmu4bj4H4FdLL163yIuykmjSqHU8qvQp33BqUc0j897gmyLeS0Bar8IjSw7eSHjWIvjpibpiLC3qzzT(nuitDsKlesEE5LxEJ)iOPw)qvk5KsUpY9j(3WUc9YFm3qwlYAHjH5bB5bLL168qVmPPXFDdl4cwD6gsgp8RVlMhIxKMt8W)Txptj)LKXd)7SCbiip8rwqNhKsoPKJ)I)sY4H49K6pKrwN)sY4H)Nh(prkgk8G6yEaxW8nEaXcRjXdlip8dmEGhYLhgtkET3vhBA8x8xsgp8Fj5edjjmpaqGlK4b2gbOjpaqpLBA8q8aJrwPHh81))jfgbI05bLL16gEy9(Bn(lLL16MMfKyBeGMZigsujfHURr0SAtZKcvJaC9uSGcR1ob5VuwwRBAwqITraAI2S0igsujfHobcsSu4AenZEJ13eUEXeaD1K8x8xsgp8Fj5edjjmpq)rW34HSIiEiNiEqz5c5HYWd6FA1vGo14VuwwRBMJkhlaHeztI)szzTUbTzPb67IfGiW3qVaNz72XRDVHvNv(JaI4KWoPwR3GKIFtgz)oB3oET7nG(UymSCuiydsk(TyXEp1o5zdOVlgdlhfc2ixb6e2g8xklR1nOnlnabneeLYF4VuwwRBqBwAfYuNewiDdHEboRSS(JeKtrfzKywQyXGioj)hzGiEXewRDc2WeyXQuI4lh)LYYADdAZs3RNP0i(pqWprKNOxGZaiGGneFA7VjmjK8NCQHyXFPSSw3G2S0QZitc1UGP9o)LYYADdAZsdwqcOVlM)szzTUbTzPb0hXcksyXqXWFPSSw3G2S0igsujfzqVaNz72XRDVHvNv(JaI4KWoPwR3GuKwUrczLC8xklR1nOnlnIHevsrO7AendvBIrCumcG6rajSaajZ15VuwwRBqBwAedjQKIqNabjwkCnIMzVX6BcxVycGUAs0lWz2UD8A3By1zL)iGiojStQ16nifPLBK5DaeqWgwDw5pciItc7KATEdXsgiItTSIirUI4kbtnPiRiI)szzTUbTzPrmKOskcDxJOz1MMjfQgb46PybfwRDcIEbolB2UD8A3By1zL)iGiojStQ16nifPLBK3wzsf(qzlRisKRaxKeFS1gXIj7uHpu2YkIe5kWfjVKIRn4VuwwRBqBwAedjQKIq31iAoIGek5KAeGQ)GEbolB2UD8A3By1zL)iGiojStQ16nifPLBK5DaeqWgwDw5pciItc7KATEdXsgiItTSIirUI4kHKSHmVd1clO)ipBkgBAKKxM0elgulSG(J8SPySPvUeFSL)szzTUbTzPrmKOskcDxJOz1m9N6KravBUqbBHAh9cCgtaiGGnOAZfkylu7cmbGac2WRDN)szzTUbTzPrmKOskcDxJOz1m9N6KravBUqbBHAh9cCov4dLTjs75uZILYlPpYqXtKYYIWnmSaa6L)ikhfRfZFPSSw3G2S0igsujfHURr0SAM(tDYiGQnxOGTqTJEbodGac2WQZk)rarCsyNuR1BiwYGjaeqWguT5cfSfQDbMaqabBiwY8ofprkllc3WWcaOx(JOCuSwm)LYYADdAZsBTzTo6f4maciydRoR8hbeXjHDsTwVHyXFPSSw3G2S0a9DXIuTqVaNHiozAzfrICfFK4HH5VuwwRBqBwAJDfgv(JiQmj6f4meXlMWATtWgMalwLse)4OSS(JeKtrfz4VuwwRBqBwAOwgsGjfJEbo)UfLnTx)r8xklR1nOnlTcSrLRzTUOxra8xklR1nOnlnwDw5pciItc7KATo6f487P2jpBa9DXyy5OqWg5kqNWXI9oB3oET7nG(UymSCuiydsk(n(lLL16g0MLo3iatUoHEbodGac2awNeMPI64Mjvgksmll8xklR1nOnlnt7DHYYADrVmj6UgrZrvwpAwRJEboxoBJk)rG1i9He2AKqo(lLL16g0MLMP9UqzzTUOxMeDxJOzYyiNrg(lLL16g0MLMP9UqzzTUOxMeDxJOztQowHy(l(lLL16MgzmKZiZmBDg5jutcla7AeHEboJ3SXwNrEc1KWcWUgrcaeO3GuKwUrEPK5DaeqWgwDw5pciItc7KATEdXI)szzTUPrgd5mYG2S0QxrQybfysZj0lWzaeqW2FAKvblMaOVlUHyjJSHAHf0FKNnfJnnsYltAIfdQfwq)rE2um20kxIp2Ad(lLL16MgzmKZidAZshrrl8nXck6iSclWqsJmOxGZqeNAzfrICfFK4HHLbI4ftyT2jO8Xvo(lLL16MgzmKZidAZsBFHD8Fu5cizwxDgXFPSSw30iJHCgzqBwAyzz1jr5cJLYi0lW53bqabBy1zL)iGiojStQ16nel(lLL16MgzmKZidAZsdj1Q8hbyxJid6f4CQWhkBtK2ZjHflLy(FKlwSuHpu2MiTNtclwk)SuYflgy9mLcifPLBKpU2YFXFPSSw30IQSE0SwF(pnYQGfta03fJEboprApNAwSuEBLlwmz)(dCrSKzI0Eo1SyP8Xp(2G)sY4bznNTrL)WdynsFiEasXtKcsrKN8qz4bPS9FJhwqEisLCEyI0EoXdMTVOZd2k3)gpSG8qKk58WeP9CIhkNhuE4bUiwn(lLL16MwuL1JM16OnlnM0CsysyHcHEboxoBJk)rG1i9HesYiX8eP9CQXqGqYt(ljJhIxR)VM8qNsEqDEGK8YKL)Wd)67I5HXurDmpGHRvJ)szzTUPfvz9OzToAZsJjnNeMewOqOxGZg9psa03flmtf1XYuoBJk)rG1i9He2AKqozaqabBa9DXcZurDCdXsgaeqWgqFxSWmvuh3GuKwUr(pnBJZddZFPSSw30IQSE0SwhTzPHiojs1c9cCovhLYFKbabeSbrCsKQvdV2DzkNTrL)iWAK(qcjzKyI0Eo1IujpoY1(WFPSSw30IQSE0SwhTzPlgbSiowaUWSsemHEboprApNAwSuEBL7)LTuYfhaeqWgqFxSWmvuh3qSSb)LYYADtlQY6rZAD0ML2OmybwSs7clLLOxGZtK2ZPMflLxwSvglkBptlsVbPiTCJ82YFXFPSSw30mP6yfINXKMtctclui0lWziIxmH1ANGnmbwSkLF(JCYi73tTtE2awNm5cJAKRaDchl27SD741U3awNm5cJAqsXVflgaciydRoR8hbeXjHDsTwVHyzd(lLL16MMjvhRqmAZsBugSalwPDHLYs0lWzlkBptlsVbPiTCJ8pmCCKI)szzTUPzs1XkeJ2S0a9DXyy5Oqq0lW53bqabBy1zL)iGiojStQ16nel(lLL16MMjvhRqmAZshPq4Ahsog9cCgabeSbSojmtf1XnifPLBK)tZ248WWnsYjgssXIjBaeqWgW6KWmvuh3GuKwUr(ziItTSIirUcjflgaciydyDsyMkQJBqksl3i)SSFyy0y72XRDVb03fJHLJcbBqsXVfNu7KNnG(UymSCuiyJCfOt44iLnIfdabeSbSojmtf1XntQmuKxs2qgiIxmH1ANGnmbwSkLywk54VuwwRBAMuDScXOnlTzszO0jrorce3(cZP3qVaNHeiKmtkqN4VuwwRBAMuDScXOnl9ePWuqgd5mc9cC(DaeqWgwDw5pciItc7KATEdXI)szzTUPzs1XkeJ2S0a9DXcGT6OxGZSjf(qgbiuzzTU2Ly(t7FKr2aiGGTjkAnPAktZKkdf5NLTT)VXI6DrQWhknnG(UybWwDBelMXI6DrQWhknnG(UybWwDjKYg8xklR1nntQowHy0MLosHW1oKCm6f4maciydyDsyMkQJBMuzOi)C8LbI4ftyT2jydtGfRsjM)yl)LKXd)lvik8WcYd)67I5b8sgEW3KhSuhtrf7)jjpjh34VuwwRBAMuDScXOnlDKcrrSGcG(Uy0lWzmbGac2IuikIfua03f3WRDxMuHpu2YkIe5kWfjHS0SL)szzTUPzs1XkeJ2S0aRtMCHrOxGZqeVycR1obLy(JCYjZ7aiGGnS6SYFeqeNe2j1A9gIf)LYYADtZKQJvigTzPXKMtctclui0lWziIxmH1ANGnmbwSkLFw2FSfnaeqWgwDw5pciItc7KATEdXko2IMXI6DrQWhknTjsHPWKWcfkoP2jpBtKctaiPOqWg5kqNWXrkBelwwrKixbUi5)ih)LYYADtZKQJvigTzPXKMtc1XcmX03qVaNnwuVlsf(qPPHjnNeQJfyIPVjXSK4VKmE4FHMSjEyurXBEOIS6ue5PM168aKK15H4fP50)QHhIxiu8iEWqepuG8qorVXdLZ6iyIha2CIhuGQxzrgEyH8qbYdysZjH6ybMy6B8aiIZYADdpaUqEayZPg)LYYADtZKQJvigTzPXKMtgbgHqVaNnwuVlsf(qPPHjnNmcmcjXSK4VuwwRBAMuDScXOnl9ePWuysyHcHEbodGac2WQZk)rarCsyNuR1BiwXIbrCQLvejYvex5Fyy(lLL16MMjvhRqmAZsd03fla2QJEbodGac2WQZk)rarCsyNuR1Biw8xklR1nntQowHy0MLgtAojuhlWetFd9cCgabeSXGvKzDHHTiWhQHyflwQDYZguTkSatSnYAnvwR3ixb6eowmJf17IuHpuAAysZjH6ybMy6Bsmlf)LYYADtZKQJvigTzPXKMtgbgHqVaNbqabBmyfzwxyylc8HAiwXILAN8SbvRclWeBJSwtL16nYvGoHJfZyr9Uiv4dLMgM0CYiWiKeZsXFPSSw30mP6yfIrBwA26gKiRSwN)szzTUPzs1XkeJ2S0a9DXcGT68xklR1nntQowHy0MLEIuykmjSqHqVaNHio1YkIe5kKK8pmCSyaiGGnG1jHzQOoUzsLHIeXN)szzTUPzs1XkeJ2S0kKPojYfcjprVaNHiEXewRDc2WeyXQucPK7gksoTWBmQO4npGgpepMqP61LxEha]] )

end