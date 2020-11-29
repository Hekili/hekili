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


    spec:RegisterPack( "Blood", 20201129, [[d0eo3aqiOsEKiKlbiLAtaQpbvQQrPi5uksTkuuEfuvZIe5wkQODrLFjcggjQJHISmusptrvttrfUgGyBkQ03GkLXjcLZHIkwhuPsnpOk3dG9bvCqaPAHOGhkcvnruu1fHkv4JasjgjGKuNeqsSsfLxcvQIzcvQs3eQuj7eLyOOOsDuOsfTurOYtHYurHUkGusFfqk2lI)svdg0HPSyL6XOAYiDzInRKpRGrtsNwYQrrL8AfXSf1TfPDl8BvnCf64asswoKNtQPl11bA7IO(ojmEajoViY6bKuZhLA)QmHjcJemQ1cHfwvMvLzIjwzooLtmGWQYaHG1jnkeSrJpXgecwyPcbJH8)uc2OLu(nkHrcM(brCHGHvPGzRRps8iB1eSnyLBGkbztWOwlewyvzwvMjMyL54uoXaIYZNyem9OWjSWkquMGPwuQeKnbJkAoblrhKH8)0dY8I1Qhe3tudQ9nlrhKLpzjDlOdYkZrPdYQYSQ8n7MLOdM4vTyq04UVzj6GZ5bXDcw8jh0c6bPfQt6GGJuRLd(RdYWcOFW(piMQrFfzlOAhblx6wtyKGrLLbMBcJewyIWibZ4D9bblTcQFHebOwiysy7SqjmqAclSsyKGjHTZcLWabJJQwqLrWAlMuXWbzZ(GvW)0kg8ul1gepq0heNdQmbZ4D9bbJB5S34D9Hpx6MGLlD7dlviyPvxdwxFqAclZtyKGjHTZcLWabJJQwqLrW4)NPVIWrTGxXGhbgIxHyJF4qIrt6GaFWPoiUoi))m9veUD(FkfvXeb5qIrt6GSzFqCDW2Ys0UD(FkfvXeb5KW2zHEWPjygVRpiy78)u)ceLePjSmhegjygVRpiyBbPf0Kkgiysy7SqjmqAclaHWibtcBNfkHbcghvTGkJGz8Usw8siPLOpioaoiRhKn7dIad5G4DqMoiWhebgf3p(keKJkRIx9bX5GZvzcMX76dcMH4wi(rWSwinHL5syKGjHTZcLWabJJQwqLrW2GRLdmu)CsEDJKyOvDGJemJ31heSCnO2ApZfiDivIM0ewWncJemJ31heml4IUrw2ZTCMGjHTZcLWaPjSKyegjygVRpiyRcj78)ucMe2olucdKMWcZHWibZ4D9bbBBd(F5BuXNOjysy7SqjmqAclmPmHrcMe2olucdemoQAbvgbBdUwoQf8kg8iWq8keB8dh4ibZ4D9bbB876dstyHjMimsWmExFqWa1IVAjvtWKW2zHsyG0ewyIvcJemJ31hemKvAXtfJsWKW2zHsyG0ewyAEcJemjSDwOegiyCu1cQmcgUo4gCTCul4vm4rGH4vi24hoWXdc8bN6G46G8pzjSODrnO2(LjhKn7dUbxlhvSwv7PGIdjPwf6dIZbXTdonbZ4D9bbBN)NsrvmrqKMWctZbHrcMe2olucdemoQAbvgbJRAObrFqCaCqwpiWhCQdY)KLWI2njjuzXbzZ(GBW1YrTGxXGhbgIxHyJF4ahp40emJ31heSD(FQF)vM0ewyciegjysy7SqjmqW4OQfuzeSvnO2EKKAvOpiEhCEcMX76dcgvSw1RBunrinHfMMlHrcMe2olucdemJ31hemULZEJ31h(CPBcwU0TpSuHGX)KLWIwtAclmHBegjysy7SqjmqWmExFqW4wo7nExF4ZLUjy5s3(WsfcMUTGAikPjnbBej8pDBnHrclmryKGjHTZcLWablSuHGza1AvdzA)6J2)l)4RqqemJ31hemdOwRAit7xF0(F5hFfcI0ewyLWibtcBNfkHbcMX76dcgpjE(B0hf3VZMUjyYAj82hwQqW4jXZFJ(O4(D20nPjnbt3wqneLWiHfMimsWKW2zHsyGGXrvlOYiyiWO4(XxHGCuzv8QpiEaoitkFqGp4uhexhSTSeTB)HO7hL6KW2zHEq2SpiUoi))m9veU9hIUFuQdjgnPdYM9b3GRLJAbVIbpcmeVcXg)WboEWPjygVRpiyuXAvVUr1eH0ewyLWibtcBNfkHbcghvTGkJGnkTBq9bZoKKAvOpiEhCGtpiZoiRemJ31hemTXr1Q4LL9JgVjnHL5jmsWKW2zHsyGGXrvlOYiyiWqoiEaoiRhe4dIadX1vQ473phheNdoWPhe4dYvn0GO9lKX76dlFqCaCqMCjgbZ4D9bbBN)N6BBK0ewMdcJemjSDwOegiyCu1cQmcgUoyBzjA3o)pLIQyIGCsy7SqpiB2hexhK)FM(kc3o)pLIQyIGCiXOjrWmExFqWOwWRyWJadXRqSXpinHfGqyKGjHTZcLWabJJQwqLrW2GRLB)H41QLKPoDB8jhehahe3oiWhebgYbXbWbzLGz8U(GG1F6w3FiKMWYCjmsWKW2zHsyGGXrvlOYiytDqCDq(NSew0Uq4Op)i6bzZ(GBW1Yz7pTcRRp85kD7OVI4GtFqGp4uhCdUwU9hIxRwsM6qsQvH(G4b4GiWqCDLk((9ZFq2Sp4gCTC7peVwTKm1HKuRc9bXdWbN6GdC6bX)G8)Z0xr425)PuufteKdjgnPdYSd2wwI2TZ)tPOkMiiNe2ol0dYSdY6bN(GSzFWn4A52FiETAjzQt3gFYbX7GZFWPpiWhebgf3p(keKJkRIx9bXbWbzvzcMX76dcwQHqVcKeustyb3imsWKW2zHsyGGXrvlOYiyBW1YT)q8A1sYuNUn(KdI3bN7bb(GiWO4(XxHGCuzv8Qpioaoita5GaFWPoiUoi)twclAxudQTFzYbzZ(GBW1YrfRv1EkO4qsQvH(G4CqGCWPjygVRpiyPgc9kqsqjnHLeJWibtcBNfkHbcghvTGkJGXvn0GO9lKX76dlFqCaCqMCj2bb(GtDWn4A5uL0x3MU0oDB8jhepahCQdcKdoNhupk5SVn0G0A3o)p1V)kFWPpiB2hupk5SVn0G0A3o)p1V)kFqCoiRhCAcMX76dcMQyO2RBunrinHfMdHrcMe2olucdemoQAbvgbJRAObr7xiJ31hw(G4a4Gm5sSdc8bN6GBW1YPkPVUnDPD624toiEao4uheihCopOEuYzFBObP1UD(FQF)v(GtFq2SpOEuYzFBObP1UD(FQF)v(G4Cqwp40emJ31heSD(FQF)vM0ewyszcJemjSDwOegiyCu1cQmcgv2GRLl1qt8)YVZ)tD0xrCqGp4QguBpssTk0heNdIBoGqWmExFqWsn0e)V878)ustyHjMimsWKW2zHsyGGXrvlOYiytDWn4A54Okv)HxZFq0G4ahpiWhSTSeTdj5sR6RWVZ)tDsy7Sqp40he4dIaJI7hFfcYrLvXR(G4CqMuMGz8U(GGrfRv9wq9uHBjrAclmXkHrcMe2olucdemoQAbvgbdbgf3p(ke0bXbWbzszLpiWhexhCdUwoQf8kg8iWq8keB8dh4ibZ4D9bbB)HO7hLsAclmnpHrcMe2olucdemoQAbvgbdbgf3p(keKJkRIx9bXdWbN6GmbKdI)b3GRLJAbVIbpcmeVcXg)WboEqMDqGCq8pOEuYzFBObP1ovXqTx3OAICqMDW2Ys0ovXq9gj2eb5KW2zHEqMDqwp40hKn7d2vQ473tl5G4DqMuMGz8U(GGrfRv96gvtestyHP5GWibtcBNfkHbcghvTGkJGPhLC23gAqATJkwR6TG6Pc3s6G4a4GZtWmExFqWOI1QElOEQWTKinHfMacHrcMe2olucdemoQAbvgbBdUwoQf8kg8iWq8keB8dh44bzZ(GiWqCDLk((9ZXbX7GdCkbZ4D9bbtvmu71nQMiKMWctZLWibtcBNfkHbcghvTGkJGTbxlh1cEfdEeyiEfIn(HdCKGz8U(GGTZ)t97VYKMWct4gHrcMe2olucdemoQAbvgbdbgIRRuX3VF(dIZbh4ucMX76dc2o)p132iPjSWuIryKGjHTZcLWabJJQwqLrW2GRLJJQu9hEn)brdIdC8GSzFW2Ys0oKnwupv4F64RRU(WjHTZc9GSzFq9OKZ(2qdsRDuXAvVfupv4wshehahKvcMX76dcgvSw1Bb1tfULePjSWeZHWibtcBNfkHbcghvTGkJGTbxl3(dXRvljtDij1QqFqCo48hKzhCGtjygVRpiy8p0GPJD9bPjSWQYegjysy7SqjmqW4OQfuzemUQHgeTFHmExFy5dIdGdYKJPdc8b3GRLB)H41QLKPoKKAvOpiohC(dYSdoWPemJ31heSD(FQF)vM0ewyLjcJemjSDwOegiyCu1cQmcgcmexxPIVF)8heVdoWPhKn7dUbxl3(dXRvljtD624toiohCUhe4dUbxl3(dXRvljtDij1QqFqCoicmexxPIVF)8he)doWPemJ31hemvXqTx3OAIqAclSYkHrcMe2olucdemoQAbvgbdbgf3p(keKJkRIx9bX5GSQmbZ4D9bbZqCleF)iKenPjnbJ)jlHfTMWiHfMimsWKW2zHsyGGXrvlOYiy8pzjSODrnO2(Ljhe4dUbxlhvSwv7PGIdjPwf6dIZbN7bb(GiWO4(XxHGoiohe3uMGz8U(GGrfRv96gvtestyHvcJemjSDwOegiyCu1cQmcg)twclAxudQTFzYbb(GuXAvVfupv4wsUU4tQy4GaFWPo4uhCdUwoQyTQ2tbfh44bzZ(GBW1YrTGxXGhbgIxHyJF4ahp40he4dUbxlhvSwv7PGIdjPwf6dI3bN7bNMGz8U(GGPkgQ96gvtestyzEcJemjSDwOegiyCu1cQmcgUo4gCTCuXAvTNckoWXdYM9b3GRLJkwRQ9uqXHKuRc9bX7GZXbzZ(GBW1YXrvQ(dVM)GObXbosWmExFqWOI1QApfuinHL5GWibtcBNfkHbcghvTGkJGn1bX1b5FYsyr7IAqT9ltoiB2hCdUwoQyTQ2tbfhssTk0heNdo3do9bb(G46GBW1YrTGxXGhbgIxHyJF4ahpiWhCQdokTBq9bZoKKAvOpiEhKjLpiB2hCvdQThjPwf6dI3bh40donbZ4D9bbtBCuTkEzz)OXBstybiegjysy7SqjmqW4OQfuzem(NSew0UKLOvtcDqGpicmkUF8viOdIZbXnLpiWhK)FM(kcNwHHsRyWNw62HKuRc9bX7GZtWmExFqWOI1QEDJQjcPjSmxcJemjSDwOegiyCu1cQmcgUo4gCTCul4vm4rGH4vi24hoWrcMX76dcMwHHsRyWNw6M0ewWncJemjSDwOegiyCu1cQmcg)twclAxiC0NFe9GaFWn4A52FiETAjzQt3gFYbXdWbvMGz8U(GGLAi0RajbL0ewsmcJemjSDwOegiyCu1cQmcgUo4gCTCul4vm4rGH4vi24hoWrcMX76dcMT)0kSU(WNR0nPjSWCimsWKW2zHsyGGXrvlOYiy8)Z0xr4OwWRyWJadXRqSXpCij1QqFq8o48hKn7dIRdUbxlh1cEfdEeyiEfIn(HdCKGz8U(GGPvn(KS4BvXdgkEuRMePjnblT6AW66dcJewyIWibtcBNfkHbcghvTGkJGPkwUvDJ8(G4DqGO8bzZ(GtDqCDWb0doEqGpOQy5w1nY7dI3bN7Cp40emJ31heSKT0XcvC)o)pL0ewyLWibtcBNfkHbcghvTGkJGvb)tRyWtTuBq8ZRpioaoOQy5w1XbrijAcMX76dcgvSw1RBunrinHL5jmsWKW2zHsyGGXrvlOYiyAlzXVZ)t9A1sY0dc8bRG)Pvm4PwQniEGOpiohu5dc8b3GRLBN)N61QLKPoWXdc8b3GRLBN)N61QLKPoKKAvOpiEhKjhqoiZo4aNsWmExFqWOI1QEDJQjcPjSmhegjysy7SqjmqW4OQfuzeSn4A52FiETAjzQdjPwf6dI3bN)Gm7GdCQtakchSLdYM9bN6GBW1YT)q8A1sYuhssTk0hepahebgIRRuX3VF(dYM9b3GRLB)H41QLKPoKKAvOpiEao4uhCGtpi(hK)FM(kc3o)pLIQyIGCiXOjDqMDW2Ys0UD(FkfvXeb5KW2zHEqMDqwp40hKn7dUbxl3(dXRvljtD624toiEhC(do9bb(GiWO4(XxHGCuzv8QpioaoiRktWmExFqWsne6vGKGsAclaHWibtcBNfkHbcghvTGkJG1wmPIHdc8b3GRLdbgIVTrh9vehe4dwb)tRyWtTuBq8ZRpiohuvSCR6snGYbz2bv2XebZ4D9bbdbgIVTrstyzUegjysy7SqjmqW4OQfuzemvXYTQBK3heVdceLp4CEWPoiRkFqMDWn4A525)PETAjzQdC8GttWmExFqWkUSFWG6xpQRgKkKMWcUryKGjHTZcLWabJJQwqLrWufl3QUrEFq8oiUbKdc8bhL2nO(GzhssTk0heVdcecMX76dcM24OAv8YY(rJ3KM0KMGLSG01hewyvzwvMjMyDEhtemfgkQyqtWaQKo(OwOheih04D9XbZLU1UBgbBe9RkleSeDqgY)tpiZlwREqCprnO23SeDqw(KL0TGoiRmhLoiRkZQY3SBwIoyIx1IbrJ7(MLOdoNhe3jyXNCqlOhKwOoPdcosTwo4VoidlG(b7)GyQg9vKTGQD3SBwIoiUdGIWbBHEWTSEKCq(NUT(GBzOcT7GaDoxgB9bJpMtvdLUaZh04D9H(GFKtYDZmExFODJiH)PBRbaQfF1sQsHLkamGATQHmTF9r7)LF8viOBMX76dTBej8pDBn(asaul(QLuLK1s4TpSubapjE(B0hf3VZMUVz3SeDqChafHd2c9GsYckPd2vQCWwvoOX7hDWsFqlzRY2olUBMX76dnG0kO(fseGA5Mz8U(qJpGe4wo7nExF4ZLUvkSubqA11G11hkvlaTftQyGn7k4FAfdEQLAdIhiACu(Mz8U(qJpGe25)P(fikjLQfa()z6RiCul4vm4rGH4vi24hoKy0KaEkCX)ptFfHBN)NsrvmrqoKy0KyZgxTLLOD78)ukQIjcYjHTZcD6BMX76dn(asyliTGMuXWnZ4D9HgFajyiUfIFemRfLQfaJ3vYIxcjTenoayLnBeyi4XeWiWO4(XxHGCuzv8QXzUkFZmExFOXhqc5AqT1EMlq6qQeTs1cWgCTCGH6NtYRBKedTQdC8Mz8U(qJpGeSGl6gzzp3Y5BMX76dn(asyvizN)NEZmExFOXhqcBBW)lFJk(e9nlrheRcUCWwvo4431hhK)FM(kIdQA6dYvTyqOkDqfcUFoFqDsb)GkQw9GmFIdO5Mz8U(qJpGeg)U(qPAbydUwoQf8kg8iWq8keB8dh44nZ4D9HgFajaQfF1sQ(Mz8U(qJpGeqwPfpvm6nZ4D9HgFajSZ)tPOkMiiLQfaCTbxlh1cEfdEeyiEfIn(HdCe4PWf)twclAxudQTFzcB2BW1YrfRv1EkO4qsQvHghCB6BMX76dn(asyN)N63FLvQwa4QgAq04aGvGNI)jlHfTBssOYc2S3GRLJAbVIbpcmeVcXg)Wboo9nZ4D9HgFajqfRv96gvteLQfGvnO2EKKAvOXB(BMX76dn(asGB5S34D9Hpx6wPWsfa8pzjSO13mJ31hA8bKa3YzVX76dFU0TsHLka0TfudrVz3SeDqgarXbtCm3hSwhuHCqvlz5GDLkhClTcrIdY8m)brYcjAvrFZmExFOD8pzjSO1aOI1QEDJQjIs1ca)twclAxudQTFzcWBW1YrfRv1EkO4qsQvHgN5cmcmkUF8viiCWnLVzj6G4USjYb1Gi5GkKdgsYc6G5xlhSvT(GBW16Mz8U(q74FYsyrRXhqcQIHAVUr1erPAbG)jlHfTlQb12VmbyQyTQ3cQNkCljxx8jvma8utTbxlhvSwv7PGIdCKn7n4A5OwWRyWJadXRqSXpCGJtd8gCTCuXAvTNckoKKAvOXBUtFZs0bb6b9GTQ1huHCqlRWssFqUP7dY8m)bn9bvRb1doIQ)GkuL4GkKdA8g0Y5Koyic9GvFZmExFOD8pzjSO14dibQyTQ2tbfLQfaCTbxlhvSwv7PGIdCKn7n4A5OI1QApfuCij1QqJ3CWM9gCTCCuLQ)WR5piAqCGJ3SeDqGE3s6yFW(pO24OAvC5GTQCWb1hmFWADqfYbhrcT4TTZjDqfvoFW47ds)dMcYvpyfhSvLdgIHo4cSbrYnZ4D9H2X)KLWIwJpGe0ghvRIxw2pA8wPAbykCX)KLWI2f1GA7xMWM9gCTCuXAvTNckoKKAvOXzUtdmU2GRLJAbVIbpcmeVcXg)Wboc8uJs7guFWSdjPwfA8ysz2Sx1GA7rsQvHgVboD6BwIoidGO4GjoM7d(R1bzUa19b3Y6rYb1kmuAfdhK)PI(GBJp5G)ADWepZFZmExFOD8pzjSO14dibQyTQx3OAIOuTaW)KLWI2LSeTAsiGrGrX9JVcbHdUPmW8)Z0xr40kmuAfd(0s3oKKAvOXB(BwIoiqpOhuRWqPvmCqtFW8hdh00huHG7JKdgFFq8o486d(R1bz(ehqZnZ4D9H2X)KLWIwJpGe0kmuAfd(0s3kvla4AdUwoQf8kg8iWq8keB8dh44nlrhK5gjZjqh37btne6vCWpo4iyoFWko4JOc6G9FWbqdzrlYbFTg0qjDqkiQIHd2QYbxfs3hK5tCan3mJ31hAh)twclAn(asi1qOxbscQs1ca)twclAxiC0NFef4n4A52FiETAjzQt3gFcEau(MLOdc0d6bvihKB6(GaDCV3mJ31hAh)twclAn(asW2FAfwxF4Zv6wPAbaxBW1YrTGxXGhbgIxHyJF4ahVzj6GanYbzUa19bPFG73hKB6(GTAPpifevXWbz(ehqZnZ4D9H2X)KLWIwJpGe0QgFsw8TQ4bdfpQvtsPAbG)FM(kch1cEfdEeyiEfIn(HdjPwfA8MNnBCTbxlh1cEfdEeyiEfIn(HdC8MDZmExFODPvxdwxFaizlDSqf3VZ)tvQwaufl3QUrEJhquMn7PW1a6bhbwvSCR6g5nEZDUtFZs0bbQe8pTIHdsTuBqoisaQcSqsQe9bl9bzfiaTp4VoyQbuoOQy5w9G6p)kDqGOmq7d(RdMAaLdQkwUvpyfh0o4a6bhD3mJ31hAxA11G11h4dibQyTQx3OAIOuTaub)tRyWtTuBq8ZRXbGQy5w1Xbrij6BwIoiZ)bUFFWS0h0IdkaLs3vmCqgY)tpiMAjz6bPOF0DZmExFODPvxdwxFGpGeOI1QEDJQjIs1cG2sw878)uVwTKmf4k4FAfdEQLAdIhiACug4n4A525)PETAjzQdCe4n4A525)PETAjzQdjPwfA8yYbeMnWP3mJ31hAxA11G11h4diHudHEfijOkvlaBW1YT)q8A1sYuhssTk04npZg4uNaueoylSzp1gCTC7peVwTKm1HKuRcnEaqGH46kv897NNn7n4A52FiETAjzQdjPwfA8am1aNIp))m9veUD(FkfvXeb5qIrtIzTLLOD78)ukQIjcYjHTZcLzSonB2BW1YT)q8A1sYuNUn(e8MFAGrGrX9JVcb5OYQ4vJdawv(Mz8U(q7sRUgSU(aFajGadX32Os1cqBXKkgaEdUwoeyi(2gD0xraCf8pTIbp1sTbXpVghvXYTQl1akmtzht3mJ31hAxA11G11h4diHIl7hmO(1J6QbPIs1cGQy5w1nYB8aIYZ5uSQmZ2GRLBN)N61QLKPoWXPVzgVRp0U0QRbRRpWhqcAJJQvXll7hnERuTaOkwUvDJ8gpCdiapkTBq9bZoKKAvOXdi3SBMX76dTt3wqnefavSw1RBunruQwaqGrX9JVcb5OYQ4vJhaMug4PWvBzjA3(dr3pk1jHTZcLnBCX)ptFfHB)HO7hL6qIrtIn7n4A5OwWRyWJadXRqSXpCGJtFZmExFOD62cQHO4dibTXr1Q4LL9JgVvQwagL2nO(GzhssTk04nWPmJ1B2nlrh04D9H2PBlOgIIpGe25)PuufteKs1caU2GRLJAbVIbpcmeVcXg)WboEZs0bzEWXCXTwOhuvqYb3c3a1YbBv5GPvxdwxFCWCP7dIKCj6d(XbBlMuXqcTnPIHdsTuBqC3SeDqJ31hANUTGAik(asi1qOxbscQs1cWgCTC7peVwTKm1HKuRcnEZZSbo1jafHd2cB2tTbxl3(dXRvljtDij1QqJhaeyiUUsfF)(5zZEdUwU9hIxRwsM6qsQvHgpatnWP4Z)ptFfHBN)NsrvmrqoKy0KywBzjA3o)pLIQyIGCsy7SqzgRtZM9gCTC7peVwTKm1PBJpbV5NgyeyuC)4RqqoQSkE14aGvLVz3SeDqGw1Yb35)PhSTXd2)bhrsYs0h8twqCBCSIHdYvn0GOpyToOc5GQwYYb1Jgxo46rh0oicmKdAb9G2bbAjXZ8hS)dQhnKCW(p4gefhS6BMX76dTt3wqnefWo)p132Os1cacme8aWkWiWqCDLk((9ZbodCkWCvdniA)cz8U(WY4aGjxIDZmExFOD62cQHO4dibQf8kg8iWq8keB8dLQfaC1wwI2TZ)tPOkMiiNe2olu2SXf))m9veUD(FkfvXeb5qIrt6Mz8U(q70TfudrXhqc9NU19hIs1cWgCTC7peVwTKm1PBJpbha4gWiWqWbaR3mJ31hANUTGAik(asi1qOxbscQs1cWu4I)jlHfTleo6ZpIYM9gCTC2(tRW66dFUs3o6RiMg4P2GRLB)H41QLKPoKKAvOXdacmexxPIVF)8SzVbxl3(dXRvljtDij1QqJhGPg4u85)NPVIWTZ)tPOkMiihsmAsmRTSeTBN)NsrvmrqojSDwOmJ1PzZEdUwU9hIxRwsM60TXNG38tdmcmkUF8viihvwfVACaWQY3mJ31hANUTGAik(asi1qOxbscQs1cWgCTC7peVwTKm1PBJpbV5cmcmkUF8viihvwfVACaWeqaEkCX)KLWI2f1GA7xMWM9gCTCuXAvTNckoKKAvOXbitFZmExFOD62cQHO4dibvXqTx3OAIOuTaGR2Ys0UD(FkfvXeb5KW2zHcmvSw1Bb1tfULKdjPwfA8acWiWO4(XxHGCuzv8QXdWumbe83GRLJAbVIbpcmeVcXg)WboYmGGVEuYzFBObP1ovXqTx3OAIWS2Ys0ovXq9gj2eb5KW2zHYmwnExFOD62cQHO4diHD(FQF)vwPAbGRAObr7xiJ31hwgham5smGNAdUwovj91TPlTt3gFcEaMciZPEuYzFBObP1UD(FQF)vEA2S1Jso7BdniT2TZ)t97VY4W603mJ31hANUTGAik(asyN)N63FLvQwa4QgAq0(fY4D9HLXbatUed4P2GRLtvsFDB6s70TXNGhGPaYCQhLC23gAqATBN)N63FLNMnB9OKZ(2qdsRD78)u)(RmoSo9nlrhe3LHMCWFDqgY)tpi9f9bJVp4OfujT4ZPauAjOUBMX76dTt3wqnefFajKAOj(F535)PkvlauzdUwUudnX)l)o)p1rFfbWRAqT9ij1QqJdU5aYnZ4D9H2PBlOgIIpGeOI1QElOEQWTKuQwaMAdUwooQs1F418henioWrGBllr7qsU0Q(k878)uNe2ol0Pbgbgf3p(keKJkRIxnomP8nZ4D9H2PBlOgIIpGe2Fi6(rPkvlaiWO4(XxHGWbatkRmW4AdUwoQf8kg8iWq8keB8dh44nZ4D9H2PBlOgIIpGeOI1QEDJQjIs1cacmkUF8viihvwfVA8amftab)n4A5OwWRyWJadXRqSXpCGJmdi4RhLC23gAqATtvmu71nQMimRTSeTtvmuVrInrqojSDwOmJ1PzZURuX3VNwcEmP8nZ4D9H2PBlOgIIpGeOI1QElOEQWTKuQwa0Jso7BdniT2rfRv9wq9uHBjHdG5VzgVRp0oDBb1qu8bKGQyO2RBunruQwa2GRLJAbVIbpcmeVcXg)WboYMncmexxPIVF)CG3aNEZmExFOD62cQHO4diHD(FQF)vwPAbydUwoQf8kg8iWq8keB8dh44nZ4D9H2PBlOgIIpGe25)P(2gvQwaqGH46kv897NhNbo9Mz8U(q70TfudrXhqcuXAvVfupv4wskvlaBW1YXrvQ(dVM)GObXboYMDBzjAhYglQNk8pD81vxF4KW2zHYMTEuYzFBObP1oQyTQ3cQNkCljCaW6nZ4D9H2PBlOgIIpGe4FObth76dLQfGn4A52FiETAjzQdjPwfACMNzdC6nZ4D9H2PBlOgIIpGe25)P(9xzLQfaUQHgeTFHmExFyzCaWKJjG3GRLB)H41QLKPoKKAvOXzEMnWP3mJ31hANUTGAik(asqvmu71nQMikvlaiWqCDLk((9ZJ3aNYM9gCTC7peVwTKm1PBJpbN5c8gCTC7peVwTKm1HKuRcnoiWqCDLk((9ZJ)aNEZmExFOD62cQHO4dibdXTq89Jqs0kvlaiWO4(XxHGCuzv8QXHvLjygyR(icgwLM4pi(heOAzsLlstAcb]] )

end