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


    spec:RegisterPack( "Blood", 20201123.1, [[d0u3fbqiiHhjsPljsbztkv9jrQqJsjXPusAvev1RisMfrPBPujTlH(frLHjs6yqslJO4zkrMMivDnLk2MsL6BevX4uQeNJOkP1jsHAEqQUNszFqkhesKwir4HqIOjksLUOiveFKOkrgPivKojrvcRuj8srkOMPifYnfPaTtIudvKkQJksbSuir4PanvIORsuLO(krvk7fQ)sQbJ4WuwmepMWKr6YO2SI(SOA0IYPLSArQGxRKA2kCBbTBQ(TkdxehNOkvlh0Zjz6sDDaBxK47cy8Iu05vIA9qIA(c0(v1yuXsIbPwZyPLjvzsfvuLzPiQ7KA6t)UGb7LtymyIjwB5mg0TqgdkX4okgmXwECgfljguDaqbJbbRqGH115OKqB2yqeGA0YlCmcgKAnJLwMuLjvurvMLIOUtQPp97gdQsybwAz2jvmywrPSJrWGuwjWGP9jsmUJ(K0LTo7jPH9kpR)fP9jsFPWHim8jYSKSprMuLj1FXViTpbLmZ8CwLg)ls7t21NKgaOeRFI50NqlyV8tasOwZp5MprIjk9j99eWmJEbgMtvXFrAFYU(ePVMtJFYtsJylLYZFs5prDH8tKyIsFs1COsowPyxWQNa4DnEIbpaN(euLdv5KjvzqnIbhLQvyjXGSsXUGvyjXsJkwsmi7gYGPyjWGcy1mSmmi96O4Cb7n0AMQNdlK1iaqpc5qRC1tq)jY8K9pbfpbbyoJuZfLNRHaoRdWwY5rGemOj66CmO4Cb7n0AMQNdlKXnwAzWsIbz3qgmflbguaRMHLHbraMZykwysblHgzChncK8K9pzLNaTIQ5uyVJgLQICAwQw9KGbFc0kQMtH9oAuQkw(tq7jOUZtwfdAIUohdAEfA6BQPS1z4gl9syjXGSBidMILadkGvZWYWGqaNJDfY6(0O(e0EsUG(K9pbc4LqNCby4tq)jPpvmOj66CmyihEWL13upaefvtHSfQWnw60JLedAIUohdg4GdAkC5AiRo3CbJbz3qgmflbUXsVdwsmi7gYGPyjWGcy1mSmmikEccWCgPMlkpxdbCwhGTKZJajyqt015yqyLKmyD5AvIjyCJLE3yjXGSBidMILadkGvZWYWGTbZ5oMX2OZ0jI(jOT9KDj1Nem4tAdMZDmJTrNPte9tqF7jYK6tcg8jZkpR1qo0kx9e0Fs63bdAIUohdczlP8C9CyHSc3yPLhSKyq2nKbtXsGbfWQzyzyqu8eeG5msnxuEUgc4SoaBjNhbsWGMORZXGzSbBnRuSlyCJBmiLNgWOXsILgvSKyqt015yWWYP6jKzuMXGSBidMILa3yPLbljgKDdzWuSeyqbSAgwggSnFD55pjyWNuU4clpxtTqlN17OEcApjvmOj66CmOWgdTj66C9OungCuQw7wiJbdRUYTUoh3yPxcljgKDdzWuSeyqbSAgwgguC3GEb8i1Cr55AiGZ6aSLCEeYgD5NS)jR8eu8eXDd6fWJiJ7Ouy5RzyeYgD5Nem4tqXtABWEhrg3rPWYxZWi7gYGPpzvmOj66CmiY4oQEcaxg3yPtpwsmOj66CmicdvmCD55yq2nKbtXsGBS07GLedYUHmykwcmOawndlddAIUsH1SZHfREcABprMNem4tGao)e0FcQpz)tGaEj0jxaggP8Sev)e0EYUtfdAIUohdAqH5SobyOyCJLE3yjXGSBidMILadkGvZWYWGiaZzeWZUXYAvdzpVZIajyqt015yWrLN1kD6aanpK9g3yPLhSKyqt015yqZfSQH2qlSXadYUHmykwcCJLExWsIbnrxNJbNfKrg3rXGSBidMILa3yPLxXsIbnrxNJbrSC9n1nSeRvyq2nKbtXsGBS0OMkwsmi7gYGPyjWGUfYyqOHYuaFTsJu5Ait1iaDFog0eDDogeAOmfWxR0ivUgYuncq3NJBS0OIkwsmi7gYGPyjWGMORZXGILfJRHNxcnYWunguaRMHLHbf3nOxapsnxuEUgc4SoaBjNhHCOvU6j7FckEccWCgPMlkpxdbCwhGTKZJajpz)tGaoh7kK19Pt)tq7jct16UczmipNSO1UfYyqXYIX1WZlHgzyQg3yPrvgSKyq2nKbtXsGbnrxNJbnuwLzqtPNN36BQtUamedkGvZWYWGR8eXDd6fWJuZfLNRHaoRdWwY5rihALREc6pzNNS)jZkpR1qo0kx9e0EcQ78KvFsWGpzLNmR8Swd5qRC1tq)jlL(NSkg0TqgdAOSkZGMsppV13uNCbyiUXsJ6syjXGSBidMILadAIUohdgYqEDNzk908CmOawndlddUYte3nOxapsnxuEUgc4SoaBjNhHCOvU6j7FckEccWCgPMlkpxdbCwhGTKZJajpz)tGaoh7kK19Pt)tq7jl9KvFY(NGINaTIQ5uyVJgLQICAwQw9KGbFc0kQMtH9oAuQkw(tq7jOUdg0TqgdgYqEDNzk908CCJLg10JLedYUHmykwcmOj66CmOPYsXCwPHgkFqT4G2adkGvZWYWGugbyoJqdLpOwCqBOPmcWCgPxahd6wiJbnvwkMZkn0q5dQfh0g4glnQ7GLedYUHmykwcmOj66CmOPYsXCwPHgkFqT4G2adkGvZWYWGTbZ5oMX2OZIjI(jO)KLq9j7FclVdujjmnsHfcYO8CD5Rtokg0TqgdAQSumNvAOHYhuloOnWnwAu3nwsmi7gYGPyjWGMORZXGMklfZzLgAO8b1IdAdmOawndlddIamNrQ5IYZ1qaN1byl58iqYt2)ekJamNrOHYhuloOn0ugbyoJajpz)tqXty5DGkjHPrkSqqgLNRlFDYrXGUfYyqtLLI5Ssdnu(GAXbTbUXsJQ8GLedYUHmykwcmOawndlddIamNrQ5IYZ1qaN1byl58iqcg0eDDogm566CCJLg1Dbljg0eDDogeqX6Q5qfgKDdzWuSe4glnQYRyjXGMORZXGqRuSMYgfdYUHmykwcCJLwMuXsIbz3qgmflbguaRMHLHbrXtqaMZi1Cr55AiGZ6aSLCEei5j7FYkpbfprCPWU5D0R8Swpn(jbd(eeG5mszRZuAkahHCOvU6jO9e55jRIbnrxNJbrg3rPWYxZqCJLwguXsIbz3qgmflbguaRMHLHbfzgmNvpbTTNiZt2)KvEI4sHDZ746LHL5pjyWNGamNrQ5IYZ1qaN1byl58iqYtwfdAIUohdImUJQrUAGBS0Yidwsmi7gYGPyjWGcy1mSmm4SYZAnKdTYvpb9NSeg0eDDogKYwNPvnSwZ4glTmlHLedYUHmykwcmOj66CmOWgdTj66C9OungCuQw7wiJbfxkSBERWnwAzspwsmi7gYGPyjWGMORZXGcBm0MORZ1Js1yWrPATBHmgKvk2fSc3yPLzhSKyq2nKbtXsGbnrxNJbf2yOnrxNRhLQXGJs1A3czmOQnNAqkUXngmbYIleXASKyPrfljgKDdzWuSeyq3czmOHYQmdAk988wFtDYfGHyqt015yqdLvzg0u655T(M6KladXnwAzWsIbz3qgmflbg0eDDoguSSyCn88sOrgMQXG8CYIw7wiJbfllgxdpVeAKHPACJBmyy1vU115yjXsJkwsmi7gYGPyjWGcy1mSmmygBJolMi6NG(t2j1Nem4tw5jO4j5Wdi5j7FsgBJolMi6NG(t29UFYQyqt015yWuSWKcwcnY4okUXsldwsmi7gYGPyjWGcy1mSmmy5IlS8Cn1cTCwVK6jOT9Km2gDwuaaHS3yqt015yqkBDMw1WAnJBS0lHLedYUHmykwcmOawndlddQSuynY4oQwLv8G(K9pPCXfwEUMAHwoR3r9e0EsQpz)tqaMZiY4oQwLv8GgbsEY(NGamNrKXDuTkR4bnc5qRC1tq)jOg35jY)j5ckg0eDDogKYwNPvnSwZ4glD6XsIbz3qgmflbguaRMHLHbraMZiY5SwLv8GgHCOvU6jO)KLEI8FsUGg50Kfan)KGbFYkpbbyoJiNZAvwXdAeYHw5QNG(2tGaoh7kK19Px6jbd(eeG5mICoRvzfpOrihALREc6BpzLNKlOprQNiUBqVaEezChLclFndJq2Ol)e5)K2gS3rKXDukS81mmYUHmy6tK)tK5jR(KGbFccWCgroN1QSIh0OQnX6NG(tw6jR(K9pbc4LqNCbyyKYZsu9tqB7jYKkg0eDDogm0GWlaKDkUXsVdwsmi7gYGPyjWGcy1mSmmyB(6YZFY(NGamNriGZ62sI0lG)K9pPCXfwEUMAHwoRxs9e0EsgBJolgAP5tK)tsnIkg0eDDogec4SUTeCJLE3yjXGSBidMILadkGvZWYWGzSn6SyIOFc6pzNuFYU(KvEImP(e5)eeG5mImUJQvzfpOrGKNSkg0eDDogSemYb4u98GD1aug3yPLhSKyq2nKbtXsGbfWQzyzyWm2gDwmr0pb9Nip78K9pjH7yE2bmIqo0kx9e0FYoyqt015yqLjG1SeLn0jMOXnUXGIlf2nVvyjXsJkwsmi7gYGPyjWGcy1mSmmO4sHDZ7Ox5zTEA8t2)eeG5mszRZuAkahHCOvU6jO9KD)K9pbc4LqNCby4tq7jYtQyqt015yqkBDMw1WAnJBS0YGLedYUHmykwcmOawndlddkUuy38o6vEwRNg)K9pHYwNPnNQPSWwo2LyD55pz)tw5jR8eeG5mszRZuAkahbsEsWGpbbyoJuZfLNRHaoRdWwY5rGKNS6t2)eeG5mszRZuAkahHCOvU6jO)KD)KvXGMORZXGzSbBTQH1Ag3yPxcljgKDdzWuSeyqbSAgwggefpbbyoJu26mLMcWrGKNem4tqaMZiLTotPPaCeYHw5QNG(ts)tcg8jiaZzuaRq15AL4aG5CeibdAIUohdszRZuAkaJBS0PhljgKDdzWuSeyqbSAgwggCLNGINiUuy38o6vEwRNg)KGbFccWCgPS1zknfGJqo0kx9e0EYUFYQpz)tqXtqaMZi1Cr55AiGZ6aSLCEei5j7FYkpjH7yE2bmIqo0kx9e0FcQP(KGbFYSYZAnKdTYvpb9NKlOpzvmOj66CmOYeWAwIYg6et04gl9oyjXGSBidMILadkGvZWYWGIlf2nVJPWENTm8j7FceWlHo5cWWNG2tKNuFY(NiUBqVaEufWGHLNRdlvhHCOvU6jO)KLWGMORZXGu26mTQH1Ag3yP3nwsmi7gYGPyjWGcy1mSmmikEccWCgPMlkpxdbCwhGTKZJajyqt015yqvadgwEUoSunUXslpyjXGSBidMILadkGvZWYWGIlf2nVJolG34G0NS)jiaZze5CwRYkEqJQ2eRFc6BpjvmOj66CmyObHxai7uCJLExWsIbz3qgmflbguaRMHLHbrXtqaMZi1Cr55AiGZ6aSLCEeibdAIUohdAixy5wxNRhvicUXslVILedYUHmykwcmOawndlddkUBqVaEKAUO8CneWzDa2sopc5qRC1tq)jl9KGbFckEccWCgPMlkpxdbCwhGTKZJajyqt015yqvMjwpyDNXAapWb7SLXnUXGQ2CQbPyjXsJkwsmi7gYGPyjWGcy1mSmmieWlHo5cWWiLNLO6NG(2tqn1NS)jR8eu8K2gS3rKZzvFWWi7gYGPpjyWNGINiUBqVaEe5Cw1hmmczJU8tcg8jiaZzKAUO8CneWzDa2sopcK8KvXGMORZXGu26mTQH1Ag3yPLbljgKDdzWuSeyqbSAgwggmH7yE2bmIqo0kx9e0FsUG(e5)ezWGMORZXGktaRzjkBOtmrJBS0lHLedYUHmykwcmOawndlddcbC(jOV9ezEY(NabCo2viR7tN(NG2tYf0NS)jImdMZk9eAIUo3gpbTTNGACxWGMORZXGiJ7O62sWnw60JLedYUHmykwcmOawndlddIIN02G9oImUJsHLVMHr2nKbtFsWGpbfprC3GEb8iY4okfw(AggHSrxgdAIUohdsnxuEUgc4SoaBjNJBS07GLedYUHmykwcmOawndlddIamNrKZzTkR4bnQAtS(jOT9e55j7FceW5NG22tKbdAIUohd2xiIQpNXnw6DJLedYUHmykwcmOawndlddUYtqXtexkSBEhDwaVXbPpjyWNGamNrd5cl366C9OcrIajpz1NS)jR8eeG5mICoRvzfpOrihALREc6Bpbc4CSRqw3NEPNem4tqaMZiY5SwLv8GgHCOvU6jOV9KvEsUG(ePEI4Ub9c4rKXDukS81mmczJU8tK)tABWEhrg3rPWYxZWi7gYGPpr(prMNS6tcg8jiaZze5CwRYkEqJQ2eRFc6pzPNS6t2)eiGxcDYfGHrkplr1pbTTNitQyqt015yWqdcVaq2P4glT8GLedYUHmykwcmOawndlddcb8sOtUamms5zjQ(jOV9e5jvmOj66CmiLTotRAyTMXnw6DbljgKDdzWuSeyqbSAgwggebyoJiNZAvwXdAu1My9tq)j7(j7FceWlHo5cWWiLNLO6NG22tqDNNS)jR8eu8eXLc7M3rVYZA904Nem4tqaMZiLTotPPaCeYHw5QNG2t25jRIbnrxNJbdni8cazNIBS0YRyjXGSBidMILadkGvZWYWGImdMZk9eAIUo3gpbTTNGACxEY(NSYtqaMZyghEQ2uLkQAtS(jOV9KvEYopzxFIkHhdDBWCUvrKXDunYvJNS6tcg8jQeEm0TbZ5wfrg3r1ixnEcAprMNSkg0eDDogmJnyRvnSwZ4glnQPILedYUHmykwcmOawndlddkYmyoR0tOj66CB8e02EcQXD5j7FYkpbbyoJzC4PAtvQOQnX6NG(2tw5j78KD9jQeEm0TbZ5wfrg3r1ixnEYQpjyWNOs4Xq3gmNBvezChvJC14jO9ezEYQyqt015yqKXDunYvdCJLgvuXsIbz3qgmflbguaRMHLHbPmcWCgdn4A9n1iJ7Or6fWFY(NmR8Swd5qRC1tq7jYtChmOj66CmyObxRVPgzChf3yPrvgSKyq2nKbtXsGbfWQzyzyWvEccWCgfWkuDUwjoayohbsEY(N02G9oc5rPY0LRrg3rJSBidM(KvFY(Nab8sOtUamms5zjQ(jO9eutfdAIUohdszRZ0Mt1uwylJBS0OUewsmi7gYGPyjWGcy1mSmmieWlHo5cWWNG22tqn1uFY(NGINGamNrQ5IYZ1qaN1byl58iqcg0eDDoge5Cw1hme3yPrn9yjXGSBidMILadkGvZWYWGqaVe6KladJuEwIQFc6BpzLNG6oprQNGamNrQ5IYZ1qaN1byl58iqYtK)t25js9evcpg62G5CRIzSbBTQH1A(jY)jTnyVJzSbBeiBRzyKDdzW0Ni)NiZtw9jbd(KUczDFAAXpb9NGAQyqt015yqkBDMw1WAnJBS0OUdwsmi7gYGPyjWGcy1mSmmOkHhdDBWCUvrkBDM2CQMYcB5NG22twcdAIUohdszRZ0Mt1uwylJBS0OUBSKyq2nKbtXsGbfWQzyzyqeG5msnxuEUgc4SoaBjNhbsEsWGpbc4CSRqw3No9pb9NKlOyqt015yWm2GTw1WAnJBS0OkpyjXGSBidMILadkGvZWYWGiaZzKAUO8CneWzDa2sopcKGbnrxNJbrg3r1ixnWnwAu3fSKyq2nKbtXsGbfWQzyzyqiGZXUczDF6LEcApjxqXGMORZXGiJ7O62sWnwAuLxXsIbz3qgmflbguaRMHLHbraMZOawHQZ1kXbaZ5iqYtcg8jTnyVJqlPOAklUWKtvDDEKDdzW0Nem4tuj8yOBdMZTkszRZ0Mt1uwyl)e02EImyqt015yqkBDM2CQMYcBzCJLwMuXsIbz3qgmflbguaRMHLHbraMZiY5SwLv8GgHCOvU6jO9KLEI8FsUGIbnrxNJbfNRact66CCJLwguXsIbz3qgmflbguaRMHLHbfzgmNv6j0eDDUnEcABpb1iQpz)tqaMZiY5SwLv8GgHCOvU6jO9KLEI8FsUGIbnrxNJbrg3r1ixnWnwAzKbljgKDdzWuSeyqbSAgwggec4CSRqw3NEPNG(tYf0Nem4tqaMZiY5SwLv8GgvTjw)e0EYUFY(NGamNrKZzTkR4bnc5qRC1tq7jqaNJDfY6(0l9ePEsUGIbnrxNJbZyd2AvdR1mUXslZsyjXGSBidMILadkGvZWYWGqaVe6KladJuEwIQFcAprMuXGMORZXGguyoR7dczVXnUXngmfgQQZXsltQYKkQOkZsyWag0lpxHbLxeMCWMPpz3pXeDD(tgLQvXFbgmbEZAWyW0(ejg3rFs6YwN9K0WELN1)I0(ePVu4qeg(ezws2NitQYK6V4xK2NGsMzEoRsJ)fP9j76tsdauI1pXC6tOfSx(jajuR5NCZNiXeL(K(EcyMrVadZPQ4ViTpzxFI0xZPXp5jPrSLs55pP8NOUq(jsmrPpPAoujhRuSly1ta8UgpXGhGtFcQYHQCYKQmOg)f)I0(K0jPjlaAM(eeEEq(jIleX6NGW5LRIpbLkeCsREIF(UMzWWjW4jMORZvp58XYXFHj66CvmbYIleX6nafRRMdL1TqEZqzvMbnLEEERVPo5cWWFHj66CvmbYIleXAP2KdqX6Q5qz55KfT2TqEtSSyCn88sOrgMQ)f)I0(K0jPjlaAM(eofgU8t6kKFsNXpXe9bFsPEILIvddzWXFHj66C1wy5u9eYmkZ)ct015kP2KtyJH2eDDUEuQww3c5TWQRCRRZLTMBT5RlppyWYfxy55AQfA5SEhfAP(lmrxNRKAtoKXDu9eaUSS1CtC3GEb8i1Cr55AiGZ6aSLCEeYgD59RGcXDd6fWJiJ7Ouy5RzyeYgD5GbrrBd27iY4okfw(Aggz3qgmD1FHj66CLuBYHWqfdxxE(VWeDDUsQn5mOWCwNamuSS1CZeDLcRzNdlwH2MmbdcbCgDu3db8sOtUamms5zjQgTDN6VWeDDUsQn5gvEwR0Pda08q2BzR5gcWCgb8SBSSw1q2Z7SiqYVWeDDUsQn5mxWQgAdTWgJFHj66CLuBYnliJmUJ(lmrxNRKAtoelxFtDdlXA1ViTprYmwXprIjk9jnS81CREsFpbHFcK7cY0NyWdWPpbv5qvozsvguJ)ct015kP2KdqX6Q5qzDlK3Ggktb81knsLRHmvJa095)ct015kP2KdqX6Q5qz55KfT2TqEtSSyCn88sOrgMQLTMBI7g0lGhPMlkpxdbCwhGTKZJqo0kxThfiaZzKAUO8CneWzDa2sopcKShc4CSRqw3No9OjmvR7kK)fMORZvsTjhGI1vZHY6wiVzOSkZGMsppV13uNCbyOS1CBfXDd6fWJuZfLNRHaoRdWwY5rihALRqFN9ZkpR1qo0kxHgQ7SAWGRmR8Swd5qRCf6lL(v)fMORZvsTjhGI1vZHY6wiVfYqEDNzk908CzR52kI7g0lGhPMlkpxdbCwhGTKZJqo0kxThfiaZzKAUO8CneWzDa2sopcKShc4CSRqw3No9OT0Q7rb0kQMtH9oAuQkYPzPAvWGqROAof27OrPQy5OH6o)ct015kP2KdqX6Q5qzDlK3mvwkMZkn0q5dQfh0gYwZnkJamNrOHYhuloOn0ugbyoJ0lG)lmrxNRKAtoafRRMdL1TqEZuzPyoR0qdLpOwCqBiBn3AdMZDmJTrNften6lH6EwEhOssyAKcleKr556YxNC0FHj66CLuBYbOyD1COSUfYBMklfZzLgAO8b1IdAdzR5gcWCgPMlkpxdbCwhGTKZJaj7PmcWCgHgkFqT4G2qtzeG5mcKShfS8oqLKW0ifwiiJYZ1LVo5O)I0(eWYf8t6m(jjxxN)eXDd6fWFsMPEIiZ8CMk7tcWPJJXtul7INeO6SNKUOeYB)ct015kP2Kl566CzR5gcWCgPMlkpxdbCwhGTKZJaj)ct015kP2KdqX6Q5q1VWeDDUsQn5GwPynLn6VWeDDUsQn5qg3rPWYxZqzR5gkqaMZi1Cr55AiGZ6aSLCEeiz)kOqCPWU5D0R8SwpnoyqeG5mszRZuAkahHCOvUcn5z1FHj66CLuBYHmUJQrUAiBn3ezgmNvOTjZ(vexkSBEhxVmSmpyqeG5msnxuEUgc4SoaBjNhbsw9xyIUoxj1MCu26mTQH1Aw2AUnR8Swd5qRCf6l9lmrxNRKAtoHngAt0156rPAzDlK3exkSBER(fMORZvsTjNWgdTj66C9OuTSUfYBSsXUGv)ct015kP2KtyJH2eDDUEuQww3c5nvBo1G0FXViTprcaO)euI05NuZNeGFsMLc)KUc5NGWDaM9NKUP7tG8eYQmw9lmrxNRIIlf2nVvBu26mTQH1Aw2AUjUuy38o6vEwRNgVhbyoJu26mLMcWrihALRqB37HaEj0jxagIM8K6ViTpjnOTMFIcaYpja)eNtHHpzCk(jDM1pbbyo)fMORZvrXLc7M3kP2KlJnyRvnSwZYwZnXLc7M3rVYZA9049u26mT5unLf2YXUeRlpF)kRGamNrkBDMstb4iqsWGiaZzKAUO8CneWzDa2sopcKS6EeG5mszRZuAkahHCOvUc9DV6ViTpbL60N0zw)Ka8tSraBz1teMQFs6MUpXupjRYZEscSUNeiJ9NeGFIjAaBmw(joZ0Nu9VWeDDUkkUuy38wj1MCu26mLMcWYwZnuGamNrkBDMstb4iqsWGiaZzKYwNP0uaoc5qRCf6PpyqeG5mkGvO6CTsCaWCocK8ls7tqPDZHj9t67jktaRzj4N0z8tYZoGXtQ5tcWpjbY0s0gYy5NeOgJN4x)e69Kqar2tk)jDg)eNn4tManaK)fMORZvrXLc7M3kP2KtzcynlrzdDIjAzR52kOqCPWU5D0R8SwpnoyqeG5mszRZuAkahHCOvUcTDV6EuGamNrQ5IYZ1qaN1byl58iqY(vs4oMNDaJiKdTYvOJAQbdoR8Swd5qRCf65c6Q)I0(ejaG(tqjsNFYnNpjDaq1pbHNhKFIkGbdlp)jIlKvpbXeRFYnNpbLmD)fMORZvrXLc7M3kP2KJYwNPvnSwZYwZnXLc7M3XuyVZwgUhc4LqNCbyiAYtQ7f3nOxapQcyWWYZ1HLQJqo0kxH(s)I0(euQtFIkGbdlp)jM6jJZZFIPEsaoDeYpXV(jO)KLup5MZNKUOeYB)ct015QO4sHDZBLuBYPcyWWYZ1HLQLTMBOabyoJuZfLNRHaoRdWwY5rGKFrAFs6mK3vuAA0tcni8c8KZFscWy8KYFYbPm8j99KCadAEZ8toLcWGl)ekaS88N0z8tMfu1pjDrjK3(fMORZvrXLc7M3kP2Kl0GWlaKDQS1CtCPWU5D0zb8ghKUhbyoJiNZAvwXdAu1Myn6BP(ls7tqPo9jb4Nimv)euAA0VWeDDUkkUuy38wj1MCgYfwU1156rfIiBn3qbcWCgPMlkpxdbCwhGTKZJaj)I0(e5n(jPdaQ(j0Zth7Nimv)KoRupHcalp)jPlkH82VWeDDUkkUuy38wj1MCQmtSEW6oJ1aEGd2zllBn3e3nOxapsnxuEUgc4SoaBjNhHCOvUc9LcgefiaZzKAUO8CneWzDa2sopcK8l(fMORZvrwPyxWQnX5c2BO1mvphwilBn3OxhfNlyVHwZu9CyHSgba6rihALRqxM9OabyoJuZfLNRHaoRdWwY5rGKFHj66CvKvk2fSsQn5mVcn9n1u26mzR5gcWCgtXctkyj0iJ7OrGK9RaTIQ5uyVJgLQICAwQwfmi0kQMtH9oAuQkwoAOUZQ)ct015QiRuSlyLuBYfYHhCz9n1darr1uiBHkzR5geW5yxHSUpnQOLlO7HaEj0jxagIE6t9xyIUoxfzLIDbRKAtUahCqtHlxdz15Ml4FHj66CvKvk2fSsQn5GvsYG1LRvjMGLTMBOabyoJuZfLNRHaoRdWwY5rGKFHj66CvKvk2fSsQn5GSLuEUEoSqwjBn3AdMZDmJTrNPtenAB7sQbd2gmN7ygBJotNiA03Kj1GbNvEwRHCOvUc90VZVWeDDUkYkf7cwj1MCzSbBnRuSlyzR5gkqaMZi1Cr55AiGZ6aSLCEei5x8lmrxNRIHvx5wxNVLIfMuWsOrg3rLTMBzSn6SyIOrFNudgCfuKdpGK9zSn6SyIOrF37E1FrAFI8cxCHLN)eQfA58tGS8oqb5q27NuQNiZoPHEYnFsOLMpjJTrN9e1nozFYoPMg6j38jHwA(Km2gD2tk)j2tYHhqs8xyIUoxfdRUYTUoxQn5OS1zAvdR1SS1CRCXfwEUMAHwoRxsH2wgBJolkaGq27FrAFs6EE6y)Kb3pX8NWPzP6YZFIeJ7OpbmR4b9ju4Le)fMORZvXWQRCRRZLAtokBDMw1WAnlBn3uwkSgzChvRYkEq3xU4clpxtTqlN17Oql19iaZzezChvRYkEqJaj7raMZiY4oQwLv8GgHCOvUcDuJ7i)Cb9xyIUoxfdRUYTUoxQn5cni8cazNkBn3qaMZiY5SwLv8GgHCOvUc9LKFUGg50Kfanhm4kiaZze5CwRYkEqJqo0kxH(geW5yxHSUp9sbdIamNrKZzTkR4bnc5qRCf6BRKlOsjUBqVaEezChLclFndJq2Oll)2gS3rKXDukS81mmYUHmyQ8Lz1GbraMZiY5SwLv8GgvTjwJ(sRUhc4LqNCbyyKYZsunABYK6VWeDDUkgwDLBDDUuBYbbCw3wIS1CRnFD557raMZieWzDBjr6fW3xU4clpxtTqlN1lPqlJTrNfdT0u(Pgr9xyIUoxfdRUYTUoxQn5kbJCaovppyxnaLLTMBzSn6SyIOrFNu31vKjv5JamNrKXDuTkR4bncKS6VWeDDUkgwDLBDDUuBYPmbSMLOSHoXeTS1ClJTrNften6YZo7t4oMNDaJiKdTYvOVZV4xyIUoxfvT5uds3OS1zAvdR1SS1Cdc4LqNCbyyKYZsun6BOM6(vqrBd27iY5SQpyyKDdzW0GbrH4Ub9c4rKZzvFWWiKn6YbdIamNrQ5IYZ1qaN1byl58iqYQ)ct015QOQnNAqQuBYPmbSMLOSHoXeTS1ClH7yE2bmIqo0kxHEUGkFz(f)I0(et015QOQnNAqQuBYHmUJsHLVMHYwZnuGamNrQ5IYZ1qaN1byl58iqYViTpjDbsgLWAM(KmgYpbHfgGIFsNXpjS6k3668Nmkv)eipkw9KZFsB(6YZLRT1LN)eQfA5C8xK2NyIUoxfvT5udsLAtUqdcVaq2PYwZneG5mICoRvzfpOrihALRqFj5NlOronzbqZbdUccWCgroN1QSIh0iKdTYvOVbbCo2viR7tVuWGiaZze5CwRYkEqJqo0kxH(2k5cQuI7g0lGhrg3rPWYxZWiKn6YYVTb7DezChLclFndJSBidMkFzwnyqeG5mICoRvzfpOrvBI1OV0Q7HaEj0jxaggP8SevJ2MmP(l(fP9jYlR4NGmUJ(K2sEsFpjbYPWE)KlfgkSKKYZFIiZG5S6j18jb4NKzPWprLyc(jZd(e7jqaNFI50NyprEjuY09j99evIb5N03tqaG(tQ(xyIUoxfvT5uds3qg3r1TLiBn3GaoJ(Mm7Haoh7kK19PtpA5c6ErMbZzLEcnrxNBd02qnUl)ct015QOQnNAqQuBYrnxuEUgc4SoaBjNlBn3qrBd27iY4okfw(Aggz3qgmnyquiUBqVaEezChLclFndJq2Ol)lmrxNRIQ2CQbPsTjxFHiQ(Cw2AUHamNrKZzTkR4bnQAtSgTn5zpeWz02K5xyIUoxfvT5udsLAtUqdcVaq2PYwZTvqH4sHDZ7OZc4noinyqeG5mAixy5wxNRhviseiz19RGamNrKZzTkR4bnc5qRCf6BqaNJDfY6(0lfmicWCgroN1QSIh0iKdTYvOVTsUGkL4Ub9c4rKXDukS81mmczJUS8BBWEhrg3rPWYxZWi7gYGPYxMvdgebyoJiNZAvwXdAu1Myn6lT6EiGxcDYfGHrkplr1OTjtQ)ct015QOQnNAqQuBYrzRZ0QgwRzzR5geWlHo5cWWiLNLOA03KNu)fMORZvrvBo1GuP2Kl0GWlaKDQS1CdbyoJiNZAvwXdAu1Myn67EpeWlHo5cWWiLNLOA02qDN9RGcXLc7M3rVYZA904GbraMZiLTotPPaCeYHw5k02z1FHj66Cvu1MtnivQn5Yyd2AvdR1SS1CdfTnyVJiJ7Ouy5RzyKDdzW09u26mT5unLf2YrihALRqFN9qaVe6KladJuEwIQrFBfu3rkeG5msnxuEUgc4SoaBjNhbsK)osPs4Xq3gmNBvmJnyRvnSwZYVTb7DmJnyJazBndJSBidMkFzmrxNRIQ2CQbPsTjhY4oQg5QHS1CtKzWCwPNqt0152aTnuJ7Y(vqaMZyghEQ2uLkQAtSg9Tv2zxvj8yOBdMZTkImUJQrUASAWGQeEm0TbZ5wfrg3r1ixnqtMv)fMORZvrvBo1GuP2KdzChvJC1q2AUjYmyoR0tOj66CBG2gQXDz)kiaZzmJdpvBQsfvTjwJ(2k7SRQeEm0TbZ5wfrg3r1ixnwnyqvcpg62G5CRIiJ7OAKRgOjZQ)I0(K0GgC9tU5tKyCh9j0JvpXV(jjMt5WsSRCA2StJ)ct015QOQnNAqQuBYfAW16BQrg3rLTMBugbyoJHgCT(MAKXD0i9c47NvEwRHCOvUcn5jUZVWeDDUkQAZPgKk1MCu26mT5unLf2YYwZTvqaMZOawHQZ1kXbaZ5iqY(2gS3ripkvMUCnY4oAKDdzW0v3db8sOtUamms5zjQgnut9xyIUoxfvT5udsLAtoKZzvFWqzR5geWlHo5cWq02qn1u3JceG5msnxuEUgc4SoaBjNhbs(fMORZvrvBo1GuP2KJYwNPvnSwZYwZniGxcDYfGHrkplr1OVTcQ7ifcWCgPMlkpxdbCwhGTKZJajYFhPuj8yOBdMZTkMXgS1QgwRz532G9oMXgSrGSTMHr2nKbtLVmRgmyxHSUpnTy0rn1FHj66Cvu1MtnivQn5OS1zAZPAklSLLTMBQeEm0TbZ5wfPS1zAZPAklSLrBBPFHj66Cvu1MtnivQn5Yyd2AvdR1SS1CdbyoJuZfLNRHaoRdWwY5rGKGbHaoh7kK19Ptp65c6VWeDDUkQAZPgKk1MCiJ7OAKRgYwZneG5msnxuEUgc4SoaBjNhbs(fMORZvrvBo1GuP2KdzChv3wIS1Cdc4CSRqw3NEj0Yf0FHj66Cvu1MtnivQn5OS1zAZPAklSLLTMBiaZzuaRq15AL4aG5CeijyW2gS3rOLuunLfxyYPQUopYUHmyAWGQeEm0TbZ5wfPS1zAZPAklSLrBtMFHj66Cvu1MtnivQn5eNRact66CzR5gcWCgroN1QSIh0iKdTYvOTK8Zf0FHj66Cvu1MtnivQn5qg3r1ixnKTMBImdMZk9eAIUo3gOTHAe19iaZze5CwRYkEqJqo0kxH2sYpxq)fMORZvrvBo1GuP2KlJnyRvnSwZYwZniGZXUczDF6LqpxqdgebyoJiNZAvwXdAu1MynA7EpcWCgroN1QSIh0iKdTYvObbCo2viR7tVKu5c6VWeDDUkQAZPgKk1MCguyoR7dczVLTMBqaVe6KladJuEwIQrtMuXGgqNDqmiyfIs(ePEs6uEDnkCJBmga]] )

end