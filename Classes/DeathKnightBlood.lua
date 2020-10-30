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

            bind = { "defile", "any_dnd" },
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


    spec:RegisterPack( "Blood", 20201030, [[dOu50aqiikpIGOlrau2eHQpraKgfbPtrvHvra9kiPzrGUfbO2Li)IqzyeshdsSmcQNrvvttfvUgvL2MkQ6BuvuJJaW5OQiwhvvsEhvvszEeI7Pc7ds1bPQizHqKhsvLQjsvL4IeGKrsvLuDsQksTsvKxsasDtcGODcP8tcq0rjaQEQIMke6ReaH9QQ)s0Gj1HPSyv6XOAYqDzKnd4Zk0OvWPLSAcq41qWSf1TPIDl8BLgov54uvPSCqpNKPl11bA7qu9DQKXtq48QOSEQQy(uP2pk)O8i(tS10JMWIkSOOiQ)IMqryue2xFYp7Z8OF6zCeSr6NH5q)eP8U4F6zNLxd)i(t1cc50pNLdy26Ad)o0a6FEbRC7th)9NyRPhnHfvyrrru)fnHIWOiSVcGFQ8i(JMW(k6phkmMI)(tmP4)uizAKY7IzA)cz9atlGoQXHMDsizAbK8EVeKP9xubzAHfvyrzNyNesM2VpyXiP8RyNesMwaZ0cWblocmTfyMgxW(mMg0dBnX0latJeGpft3ltphm86kBbwL(zUuT6r8NKsrbNupIpAO8i(tkSBMWps)KdRMGL9t82j(gCkAO1ewcKnhsEbHrcsowfkMweMwyMwCMgzm9feaiHTGxXOecgK0fzEBKa9(PX7AJFY3GtrdTMWsGS5qF)Oj8J4pPWUzc)i9toSAcw2pVGaajKBoEfS4YBExCc0JPfNPfktdTcljKtrNmmwLiHOuTIPD7MPHwHLeYPOtggRsvW0OZ0O4lt7JFA8U24NwuoMCbKyY6HVF08)r8Nuy3mHFK(jhwnbl7NqWGsD5qYELOW0OZ0JCmtlotdbJIl9wxeKPfHPpNO)04DTXpDiNfEMCbKzqEHLyizoQVF0o3J4pnExB8txlmJrovHesQnSGt)Kc7Mj8J03pA((i(tkSBMWps)KdRMGL9tKX0xqaGe2cEfJsiyqsxK5Trc07NgVRn(jS88YKScPYZ403pAN)r8Nuy3mHFK(jhwnbl7NTbhPonqwUhKE8MPr)GPfaIY0UDZ0TbhPonqwUhKE8MPf5GPfwuM2TBMgOghAjKCSkumTim9589NgVRn(jKmVkgLazZHuF)9pXeGbM7hXhnuEe)PX7AJF6ubwcajYp0pPWUzc)i99JMWpI)Kc7Mj8J0p5WQjyz)STaHkgzA3Uz6k4RtfJsS5yJK0xftJotl6pnExB8tULZsJ31gYCP6FMlvldZH(Pt11O11gF)O5)J4pPWUzc)i9toSAcw2p57MXRRiHTGxXOecgK0fzEBKGKHpJPfNPfktJmMMVBgVUI0nVlgdRabcMGKHpJPD7MPrgt3wMIoDZ7IXWkqGGjkSBMWmTp(PX7AJFEZ7ILaGWZ((r7CpI)04DTXpVeurqeQy8Nuy3mHFK((rZ3hXFsHDZe(r6NCy1eSSFA8UqojPGCksX0OFW0cZ0UDZ0qWGyAryAuyAXzAiyuCP36IGjmbu8QzA0z6Zl6pnExB8tdYTGKEGzf99J25Fe)jf2nt4hPFYHvtWY(5feaibgdB(mPQHum2djqVFA8U24N5ACOvsbeG4rhk6VF085hXFA8U24NwWjvdTSKB58pPWUzc)i99JMa4r8NgVRn(jqbPBEx8pPWUzc)i99JMp5r8Nuy3mHFK(jhwnbl7N8DZ41vKWwWRyucbds6ImVnsqYXQqX0OZ0(er)PX7AJFcQiz1KJ67hnue9r8Nuy3mHFK(zyo0pHMFWGbck5TgLqclVGDVXpnExB8tO5hmyGGsERrjKWYly3B89JgkO8i(tkSBMWps)04DTXp5NXZBd3O4YB2u9p5WQjyz)KVBgVUIe2cEfJsiyqsxK5TrcsowfkMwCMgzm9feaiHTGxXOecgK0fzEBKa9yAXzAiyqPUCizVYZX0OZ0Ct1YUCOFsaaeVLH5q)KFgpVnCJIlVzt1F)OHIWpI)Kc7Mj8J0pnExB8tZpQbdAkjWgTCbKERlc(toSAcw2pfktZ3nJxxrcBbVIrjemiPlY82ibjhRcftlct7ltlot3gCK6uxoKSxjUiMgDMgfFzAFW0UDZ0cLPBdosDQlhs2Rexetlct7)5yAF8ZWCOFA(rnyqtjb2OLlG0BDrWVF0qX)hXFsHDZe(r6NgVRn(Pdbje6btjbSy8NCy1eSSFkuMMVBgVUIe2cEfJsiyqsxK5TrcsowfkMwCMgzm9feaiHTGxXOecgK0fzEBKa9yAXzAiyqPUCizVYZX0OZ0(Z0(GPfNPrgtdTcljKtrNmmwLiHOuTIPD7MPHwHLeYPOtggRsvW0OZ0O47pdZH(Pdbje6btjbSy87hnuo3J4pPWUzc)i9tJ31g)0udi3csjHMFwOKVql)toSAcw2pX0feaibn)SqjFHwwIPliaqcVUIFgMd9ttnGCliLeA(zHs(cT83pAO47J4pPWUzc)i9tJ31g)0udi3csjHMFwOKVql)toSAcw2pBdosDAGSCpK84ntlct7pkmT4mn53alppcNWW6EZvmkRabVf)ZWCOFAQbKBbPKqZpluYxOL)(rdLZ)i(tkSBMWps)04DTXpn1aYTGusO5Nfk5l0Y)KdRMGL9ZliaqcBbVIrjemiPlY82ib6X0IZ0y6ccaKGMFwOKVqllX0feaib6X0IZ0iJPj)gy55r4egw3BUIrzfi4T4FgMd9ttnGCliLeA(zHs(cT83pAO4ZpI)Kc7Mj8J0p5WQjyz)8ccaKWwWRyucbds6ImVnsGE)04DTXp92U247hnueapI)Kc7Mj8J0p5WQjyz)ecgKk1Ldj7vIctJotpYX)04DTXpV5DXY28((rdfFYJ4pPWUzc)i9toSAcw2prgt7rDYYfYPFA8U24NqRuKetg(7hnHf9r8Nuy3mHFK(jhwnbl7NiJPBltrNU5DXyyfiqWef2ntyM2TBMgzmnF3mEDfPBExmgwbcembjdF2pnExB8tSf8kgLqWGKUiZBJVF0egLhXFsHDZe(r6NCy1eSSFEbbas3niPAOOmoPAJJatJ(bt7Z)04DTXp715Q6nOVF0ew4hXFsHDZe(r6NCy1eSSFcbJIl9wxemHjGIxntJotFEMwGmTX7c5KKcYPi1pnExB8tLld6uXO0Pu93pAc7)J4pnExB8t7UovyDTHmxo3FsHDZe(r67hnHp3J4pPWUzc)i9tJ31g)KB5S04DTHmxQ(N5s1YWCOFskffCs99JMW((i(tJ31g)8AJYfq2WIJG6Nuy3mHFK((rt4Z)i(tkSBMWps)04DTXp5wolnExBiZLQ)zUuTmmh6NQ2cSbXF)9p9GeFDUw)i(OHYJ4pPWUzc)i9ZWCOFA(rnyqtjb2OLlG0BDrWFA8U24NMFudg0usGnA5ci9wxe87hnHFe)jf2nt4hPFA8U24N8Z45THBuC5nBQ(NeaaXBzyo0p5NXZBd3O4YB2u93F)tNQRrRRnEeF0q5r8Nuy3mHFK(jhwnbl7NdKL7HKhVzAryAFfLPD7MPfktJmMEeUGEmT4m9az5Ei5XBMweM(8NNP9XpnExB8tKBoEfS4YBEx83pAc)i(tkSBMWps)KdRMGL9Zk4RtfJsS5yJK0FftJ(btpqwUhsCqiKI(NgVRn(jMSEqQAyHa99JM)pI)Kc7Mj8J0p5WQjyz)uziNK38UyPAOOmMPfNPRGVovmkXMJnssFvmn6mTOmT4m9feaiDZ7ILQHIY4eOhtlotFbbas38UyPAOOmobjhRcftlctJsYxMwGm9ih)tJ31g)etwpivnSqG((r7CpI)Kc7Mj8J0p5WQjyz)8ccaKUBqs1qrzCcsowfkMweM2FMwGm9ihNiHG4GnX0UDZ0cLPVGaaP7gKunuugNGKJvHIPf5GPHGbL6YHK9k9NPD7MPVGaaP7gKunuugNGKJvHIPf5GPfktpYXmnQmnF3mEDfPBExmgwbcembjdFgtlqMUTmfD6M3fJHvGabtuy3mHzAbY0cZ0(GPD7MPVGaaP7gKunuugNuTXrGPfHP9NP9btlotdbJIl9wxemHjGIxntJ(btlSO)04DTXpDmiCDbPa)9JMVpI)Kc7Mj8J0p5WQjyz)STaHkgzAXz6liaqccgKSnVeEDfmT4mDf81PIrj2CSrs6VIPrNPhil3djhtiyAbY0IMq5NgVRn(jemizBEF)OD(hXFsHDZe(r6NCy1eSSFoqwUhsE8MPfHP9vuMwaZ0cLPfwuMwGm9feaiDZ7ILQHIY4eOht7JFA8U24NfNUlyGLalSRgetF)O5ZpI)Kc7Mj8J0p5WQjyz)CGSCpK84ntlct7Z(Y0IZ0EuNghwWCcsowfkMweM23FA8U24NkJdlGIxww6z8(7V)PQTaBq8J4JgkpI)Kc7Mj8J0p5WQjyz)ecgfx6TUiyctafVAMwKdMgfrzAXzAHY0iJPBltrNUBqQEHojkSBMWmTB3mnYyA(Uz86ks3nivVqNeKm8zmTB3m9feaiHTGxXOecgK0fzEBKa9yAF8tJ31g)etwpivnSqG((rt4hXFsHDZe(r6NCy1eSSF6rDACybZji5yvOyAry6roMPfitl8pnExB8tLXHfqXlll9mE)9JM)pI)Kc7Mj8J0p5WQjyz)ezm9feaiHTGxXOecgK0fzEBKa9(PX7AJFEZ7IXWkqGGF)ODUhXFsHDZe(r6NCy1eSSFEbbas3niPAOOmobjhRcftlct7ptlqMEKJtKqqCWMyA3UzAHY0xqaG0DdsQgkkJtqYXQqX0ICW0qWGsD5qYEL(Z0UDZ0xqaG0DdsQgkkJtqYXQqX0ICW0cLPh5yMgvMMVBgVUI0nVlgdRabcMGKHpJPfit3wMIoDZ7IXWkqGGjkSBMWmTazAHzAFW0UDZ0xqaG0DdsQgkkJtQ24iW0IW0(Z0(GPfNPHGrXLERlcMWeqXRMPr)GPfw0FA8U24NogeUUGuG)(rZ3hXFsHDZe(r6NCy1eSSFcjaiPgSBM(PX7AJFQgmoczs2dKemCTWE4SVF0o)J4pPWUzc)i9toSAcw2prgtFbbasyl4vmkHGbjDrM3gjqVFA8U24NdKbBjPuuWPVF085hXFsHDZe(r6NCy1eSSFYhm4iPKaqJ31gwMPr)GPrjjayAXzAHY0xqaG0a5SQ2uLkPAJJatlYbtluM2xMwaZ0kpkNLTbhPwLU5DXY7wzM2hmTB3mTYJYzzBWrQvPBExS8UvMPrNPfMP9XpnExB8ZBExS8Uv(7hnbWJ4pPWUzc)i9toSAcw2pVGaaP7gKunuugNuTXrGPf5GPpptlotdbJIl9wxemHjGIxntJ(btJIV)04DTXpDmiCDbPa)9JMp5r8Nuy3mHFK(jhwnbl7Ny6ccaKCmicYfqEZ7It41vW0IZ0TbhPo1Ldj7vIlIPrNP95KV)04DTXpDmicYfqEZ7I)(rdfrFe)jf2nt4hPFYHvtWY(jemkU0BDrqMg9dMgfrfLPfNPrgtFbbasyl4vmkHGbjDrM3gjqVFA8U24N3nivVqNVF0qbLhXFsHDZe(r6NCy1eSSFcbJIl9wxemHjGIxntlYbtluMgfFzAuz6liaqcBbVIrjemiPlY82ib6X0cKP9LPrLPvEuolBdosTknqgSLQgwiqmTaz62Yu0PbYG9fsgcemrHDZeMPfitlmt7dM2TBMUlhs2RexetlctJIO)04DTXpXK1dsvdleOVF0qr4hXFsHDZe(r6NCy1eSSFQ8OCw2gCKAvctwpiTalXe3oJPr)GP9)NgVRn(jMSEqAbwIjUD23pAO4)J4pPWUzc)i9toSAcw2pvEuolBdosTkHjRhusmiX0OFW0()tJ31g)etwpOKyq67hnuo3J4pPWUzc)i9toSAcw2pVGaajSf8kgLqWGKUiZBJeOht72ntdbdk1Ldj7vEoMweMEKJ)PX7AJFoqgSLQgwiqF)OHIVpI)Kc7Mj8J0p5WQjyz)8ccaKWwWRyucbds6ImVnsGE)04DTXpV5DXY7w5VF0q58pI)Kc7Mj8J0p5WQjyz)8ccaK4WYrTHuXxq4iLa9yA3Uz62Yu0jO5vyjM4RJ3QQU2irHDZeMPD7MPvEuolBdosTkHjRhKwGLyIBNX0OFW0c)tJ31g)etwpiTalXe3o77hnu85hXFsHDZe(r6NCy1eSSFEbbasCy5O2qQ4liCKsGEmTB3mDBzk6e08kSet81XBvvxBKOWUzcZ0UDZ0kpkNLTbhPwLWK1dkjgKyA0pyAH)PX7AJFIjRhusmi99JgkcGhXFsHDZe(r6NCy1eSSFEbbas3niPAOOmobjhRcftJot7ptlqMEKJ)PX7AJFY3qb6411gF)OHIp5r8Nuy3mHFK(jhwnbl7NxqaG0DdsQgkkJtqYXQqX0OZ0(Z0cKPh54FA8U24N38Uy5DR83pAcl6J4pPWUzc)i9toSAcw2pHGbL6YHK9k9NPfHPh5yM2TBM(ccaKUBqs1qrzCs1ghbMgDM(8mT4m9feaiD3GKQHIY4eKCSkumn6mnemOuxoKSxP)mnQm9ih)tJ31g)CGmylvnSqG((rtyuEe)jf2nt4hPFYHvtWY(jemkU0BDrWeMakE1mn6mTWI(tJ31g)0GClizVqif93F)9probv1gpAclQWIIIOO4Z)0LbJkgv)0N2XBHnHzAFzAJ31gmDUuTkXo9tdShw4pNLJFNPrLP9Rtiu56NEWfOY0pfsMgP8UyM2VqwpW0cOJACOzNesMwajV3lbzA)fvqMwyrfwu2j2jHKP97dwmsk)k2jHKPfWmTaCWIJatBbMPXfSpJPb9Wwtm9cW0ib4tX09Y0ZbdVUYwGvj2j2jHKPfqjeehSjmtFjGfsmnFDUwZ0xAScvIP9P4CYRvmDSHaEWGoaGzM24DTHIP3iFwIDY4DTHk5bj(6CT(aurYQjhbdZHom)OgmOPKaB0Yfq6TUii7KX7AdvYds815AnQhIbQiz1KJGeaaXBzyo0b)mEEB4gfxEZMQzNyNesMwaLqqCWMWmnHCcEgt3LdX09aX0gVxitxkM2qUvz7MPe7KX7Ad1HtfyjaKi)qStgVRnuOEig3YzPX7AdzUuTGH5qhovxJwxBiybC0wGqfJUDxbFDQyuInhBKK(Qqxu2jJ31gkupe7M3flbaHNjybCW3nJxxrcBbVIrjemiPlY82ibjdFM4cfz8DZ41vKU5DXyyfiqWeKm8zUDJS2Yu0PBExmgwbcemrHDZe2hStgVRnuOEi2LGkcIqfJStgVRnuOEiMb5wqspWSIeSaomExiNKuqofPq)qy3UHGbjckIdbJIl9wxemHjGIxn6Nxu2jJ31gkupelxJdTskGaep6qrlybCCbbasGXWMptQAifJ9qc0JDY4DTHc1dXSGtQgAzj3Yz2jJ31gkupedOG0nVlMDY4DTHc1dXavKSAYrjybCW3nJxxrcBbVIrjemiPlY82ibjhRcf6(erzNmExBOq9qmqfjRMCemmh6aA(bdgiOK3AucjS8c29gStgVRnuOEigOIKvtocsaaeVLH5qh8Z45THBuC5nBQwWc4GVBgVUIe2cEfJsiyqsxK5TrcsowfkXr2feaiHTGxXOecgK0fzEBKa9ehcguQlhs2R8COZnvl7YHyNmExBOq9qmqfjRMCemmh6W8JAWGMscSrlxaP36IGcwahcLVBgVUIe2cEfJsiyqsxK5Trcsowfkr8v82GJuN6YHK9kXfHok(6d3UfABWrQtD5qYEL4IeX)Z5d2jJ31gkupedurYQjhbdZHoCiiHqpykjGfJcwahcLVBgVUIe2cEfJsiyqsxK5TrcsowfkXr2feaiHTGxXOecgK0fzEBKa9ehcguQlhs2R8CO7VpehzqRWsc5u0jdJvjsikvRC7gAfwsiNIozySkvb6O4l7KX7AdfQhIbQiz1KJGH5qhMAa5wqkj08ZcL8fAzblGdmDbbasqZpluYxOLLy6ccaKWRRGDY4DTHc1dXavKSAYrWWCOdtnGCliLeA(zHs(cTSGfWrBWrQtdKL7HKhVfXFueN8BGLNhHtyyDV5kgLvGG3IzNmExBOq9qmqfjRMCemmh6Wudi3csjHMFwOKVqllybCCbbasyl4vmkHGbjDrM3gjqpXX0feaibn)SqjFHwwIPliaqc0tCKr(nWYZJWjmSU3CfJYkqWBXStgVRnuOEiM321gcwahxqaGe2cEfJsiyqsxK5Trc0JDY4DTHc1dXU5DXY28eSaoGGbPsD5qYELOG(ihZoz8U2qH6HyqRuKetgwWc4azEuNSCHCIDY4DTHc1dXWwWRyucbds6ImVneSaoqwBzk60nVlgdRabcMOWUzc72nY47MXRRiDZ7IXWkqGGjiz4ZyNmExBOq9qSEDUQEdsWc44ccaKUBqs1qrzCs1ghb0p8z2jJ31gkupet5YGovmkDkvlybCabJIl9wxemHjGIxn6NxGgVlKtskiNIuStgVRnuOEiMDxNkSU2qMlNl7KX7AdfQhIXTCwA8U2qMlvlyyo0bPuuWjf7KX7AdfQhIDTr5ciByXrqXoz8U2qH6HyClNLgVRnK5s1cgMdDOAlWgeZoXoz8U2qLiLIcoPo4BWPOHwtyjq2CiblGd82j(gCkAO1ewcKnhsEbHrcsowfkrewCKDbbasyl4vmkHGbjDrM3gjqp2jJ31gQePuuWjfQhIzr5yYfqIjRheSaoUGaajKBoEfS4YBExCc0tCHcTcljKtrNmmwLiHOuTYTBOvyjHCk6KHXQufOJIV(GDY4DTHkrkffCsH6HyoKZcptUaYmiVWsmKmhLGfWbemOuxoKSxjkOpYXIdbJIl9wxeuKZjk7KX7AdvIukk4Kc1dXCTWmg5ufsiP2WcoXoz8U2qLiLIcoPq9qmy55LjzfsLNXjblGdKDbbasyl4vmkHGbjDrM3gjqp2jJ31gQePuuWjfQhIbjZRIrjq2CiLGfWrBWrQtdKL7bPhVr)qaiQB3TbhPonqwUhKE8wKdHf1TBGACOLqYXQqjY58LDIDY4DTHk5uDnADTXbYnhVcwC5nVlwWc4yGSCpK84Ti(kQB3cfzJWf0t8bYY9qYJ3IC(Z7d2jHKP9Pd(6uXitJnhBKyAi53ali5qrZ0LIPf2xbym9cW0oMqW0dKL7bMwT5vqM2xrfGX0lat7ycbtpqwUhy6kyAJPhHlOxIDY4DTHk5uDnADTbQhIHjRhKQgwiqcwahvWxNkgLyZXgjP)k0pgil3djoiesrZojKmTFzdbOntNPMPTGPjHOuDfJmns5DXm9COOmMPXW1lXoz8U2qLCQUgTU2a1dXWK1dsvdleiblGdLHCsEZ7ILQHIYyXRGVovmkXMJnssFvOlQ4xqaG0nVlwQgkkJtGEIFbbas38UyPAOOmobjhRcLiOK8vGJCm7KX7AdvYP6A06AdupeZXGW1fKcSGfWXfeaiD3GKQHIY4eKCSkuI4Vah54ejeehSj3Uf6feaiD3GKQHIY4eKCSkuICabdk1Ldj7v6VB3xqaG0DdsQgkkJtqYXQqjYHqh5yu57MXRRiDZ7IXWkqGGjiz4ZeyBzk60nVlgdRabcMOWUzclqH9HB3xqaG0DdsQgkkJtQ24iiI)(qCiyuCP36IGjmbu8Qr)qyrzNmExBOsovxJwxBG6HyqWGKT5jybC0wGqfJIFbbasqWGKT5LWRRq8k4RtfJsS5yJK0Ff6dKL7HKJjecu0ekStgVRnujNQRrRRnq9qSIt3fmWsGf2vdIjblGJbYY9qYJ3I4ROcyHkSOc8ccaKU5DXs1qrzCc0ZhStgVRnujNQRrRRnq9qmLXHfqXlll9mElybCmqwUhsE8weF2xX9OonoSG5eKCSkuI4l7e7KX7Advs1wGni(atwpivnSqGeSaoGGrXLERlcMWeqXRwKduevCHIS2Yu0P7gKQxOtIc7MjSB3iJVBgVUI0Dds1l0jbjdFMB3xqaGe2cEfJsiyqsxK5Trc0ZhStgVRnujvBb2GyupetzCybu8YYspJ3cwahEuNghwWCcsowfkrg5ybkm7KX7Advs1wGnig1dXU5DXyyfiqqblGdKDbbasyl4vmkHGbjDrM3gjqp2jHKP9lGE5IBnHz6bcsm9L4gOIy6EGyANQRrRRny6CPAMgs5Ium9gmDBbcvmkwBiuXitJnhBKsStgVRnujvBb2GyupeZXGW1fKcSGfWXfeaiD3GKQHIY4eKCSkuI4Vah54ejeehSj3Uf6feaiD3GKQHIY4eKCSkuICabdk1Ldj7v6VB3xqaG0DdsQgkkJtqYXQqjYHqh5yu57MXRRiDZ7IXWkqGGjiz4ZeyBzk60nVlgdRabcMOWUzclqH9HB3xqaG0DdsQgkkJtQ24iiI)(qCiyuCP36IGjmbu8Qr)qyrzNmExBOsQ2cSbXOEiMAW4iKjzpqsWW1c7HZeSaoGeaKud2ntStgVRnujvBb2GyupeBGmyljLIcojybCGSliaqcBbVIrjemiPlY82ib6Xoz8U2qLuTfydIr9qSBExS8UvwWc4GpyWrsjbGgVRnSm6hOKeaIl0liaqAGCwvBQsLuTXrqKdH6Raw5r5SSn4i1Q0nVlwE3k7d3UvEuolBdosTkDZ7IL3TYOlSpyNmExBOsQ2cSbXOEiMJbHRlifyblGJliaq6UbjvdfLXjvBCee548IdbJIl9wxemHjGIxn6hO4l7KqY0cqAqey6fGPrkVlMPXlPy6yBM2Zcm5uCbmjenf4e7KX7Advs1wGnig1dXCmicYfqEZ7IfSaoW0feai5yqeKlG8M3fNWRRq82GJuN6YHK9kXfHUpN8LDY4DTHkPAlWgeJ6Hy3nivVqhblGdiyuCP36IGOFGIOIkoYUGaajSf8kgLqWGKUiZBJeOh7KX7Advs1wGnig1dXWK1dsvdleiblGdiyuCP36IGjmbu8Qf5qOO4lQxqaGe2cEfJsiyqsxK5Trc0tG(IQYJYzzBWrQvPbYGTu1WcbsGTLPOtdKb7lKmeiyIc7MjSaf2hUD3Ldj7vIlseueLDY4DTHkPAlWgeJ6HyyY6bPfyjM42zcwahkpkNLTbhPwLWK1dslWsmXTZq)WF2jHKPfGWA(atplh)otxoEzYHI26AdMgs(vmTFHSEqaQIP9lGKFnMwretxamDpqNX0vWZGyIPVBpW02TYvxKIPxitxamnMSEqAbwIjUDgtdag8U2qX0alKPVBpKyNmExBOsQ2cSbXOEigMSEqjXGKGfWHYJYzzBWrQvjmz9GsIbj0p8NDY4DTHkPAlWgeJ6HydKbBPQHfcKGfWXfeaiHTGxXOecgK0fzEBKa9C7gcguQlhs2R8CImYXStgVRnujvBb2Gyupe7M3flVBLfSaoUGaajSf8kgLqWGKUiZBJeOh7KX7Advs1wGnig1dXWK1dslWsmXTZeSaoUGaajoSCuBiv8feosjqp3UBltrNGMxHLyIVoERQ6AJef2nty3UvEuolBdosTkHjRhKwGLyIBNH(HWStgVRnujvBb2GyupedtwpOKyqsWc44ccaK4WYrTHuXxq4iLa9C7UTmfDcAEfwIj(64TQQRnsuy3mHD7w5r5SSn4i1QeMSEqjXGe6hcZoz8U2qLuTfydIr9qm(gkqhVU2qWc44ccaKUBqs1qrzCcsowfk09xGJCm7KX7Advs1wGnig1dXU5DXY7wzblGJliaq6UbjvdfLXji5yvOq3FboYXStgVRnujvBb2GyupeBGmylvnSqGeSaoGGbL6YHK9k9xKro2T7liaq6UbjvdfLXjvBCeq)8IFbbas3niPAOOmobjhRcf6qWGsD5qYEL(J6ihZoz8U2qLuTfydIr9qmdYTGK9cHu0cwahqWO4sV1fbtycO4vJUWI(93)d]] )

end