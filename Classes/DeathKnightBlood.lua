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
                    stat.haste = stat.haste + ( state.spec.blood and 0.1 or 0.15 )
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

        potion = "potion_of_phantom_fire",

        package = "Blood",        
    } )


    spec:RegisterSetting( "save_blood_shield", true, {
        name = "Save |T237517:0|t Blood Shield",
        desc = "If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r) will try to avoid letting your |T237517:0|t Blood Shield fall off during lulls in damage.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Blood", 20201206, [[dS042aqiaPhjfXLGekTja1NOqjgLIuNsrYQGe9kiLzrHClkuXUO0VKcggrPJreTmIuptrvtJcvDnaX2KI03uuPXbjOZbjqZds6EaSpivhKcvAHejpKcLYePqXfHek(OIkunsfvOCsfviRur5LqcvMjKqv3esi1ojkgkfkvlvrf8uiMkr4Qqcj9vibSxe)vObd1HjTyL6XeMmsxg1MvYNLQgnfDArRMcL0RveZwHBlL2nv)wvdxQCCiHelh0ZfmDjxhOTlf13jQgVIk68sHwpKqmFky)QmrsIeeeQwmrgPLvAzLuAzBQvAjLvY5LMGun2XeKovmr7zcIRTmbrQX)ucsN244vkrccs4bHcMGGKTGdTY3n2G6QiiBWCuZroztqOAXezKwwPLvsPLTPwPLuwjLgfsqcDSGiJ0arwcIzsPSt2eekheeKMCyPg)tpSXWAzEyuCE2Bw3SMCyJHfC7MHhUPgDyPLvAzjiJmubIeeekVuWrrKGiJKejiiQOY3jiTPtJliZOimbHDDpykrksrKrAIeee219GPePiicywmmvcsP(K07pSbdhoDX3MEFKQTAphbs4WOFyzjiQOY3jicDmIQOY3JJmueKrgQORTmbPnRSxR8DsrKzEIeee219GPePiicywmmvcI4)b9L7wQ6I07JqqNJYzT7DlKvAJhg4dp9Hb6Hf)pOVC3Uh)tPW0NWqlKvAJh2GHdd0dx6G9YUh)tPW0NWql76EW0dpfbrfv(obzp(NgxGWgjfrgJNibbrfv(obzZWadNKEpbHDDpykrksrKbiejiiSR7btjsrqeWSyyQeevuzZCKDUn5WHrhWHL(WgmCyiOZhg1dl5Hb(WqqpfXUxodTuELISom6hUPYsqurLVtquOqDo2bocmPiY0uIeee219GPePiicywmmvcYgCTSGU5pAmgki79LPfSJGOIkFNGmYEZkenwbP9TSxKIiZCjsqqurLVtquxWHcQJOqhdcc76EWuIuKIidkKibbrfv(obzLqEp(Nsqyx3dMsKIuezqbjsqqurLVtq2AF8xXcMIjbcc76EWuIuKIiJKYsKGGWUUhmLifbraZIHPsq2GRLLQUi9(ie05OCw7E3c2rqurLVtq6(kFNuezKusIeeevu57eeWahZIBdee219GPePifrgjLMibbrfv(obbQzGJuwPee219GPePifrgjNNibbHDDpykrkcIaMfdtLGa0dVbxllvDr69riOZr5S29UfS7WaF4PpmqpS4BMD1lRN9MvCP8Hny4WBW1YszTmdrkiBHCRME4WOF45E4PiiQOY3ji7X)ukm9jmKuezK04jsqqyx3dMsKIGiGzXWujictf2ZHdJoGdl9Hb(WtFyX3m7Qx2jnct1pSbdhEdUwwQ6I07JqqNJYzT7Dly3HNIGOIkFNGSh)tJ7phKIiJKaHibbrfv(obbQzGJuwPee219GPePifrgjBkrccc76EWuIueebmlgMkbzL9MveYTA6HdJ6HNNGOIkFNGqzTmJHcMtysrKrY5sKGGWUUhmLifbrfv(obrOJrufv(ECKHIGmYqfDTLjiIVz2vVcKIiJKOqIeee219GPePiiQOY3jicDmIQOY3JJmueKrgQORTmbjuQtviLuKIG0bzX3U1Iibrgjjsqqyx3dMsKIG4AltquuKGPc1qC9Ef)vS7LZqcIkQ8DcIIIemvOgIR3R4VIDVCgskImstKGGWUUhmLifbrfv(obr0Oy8f89ue3dnueeETyrfDTLjiIgfJVGVNI4EOHIuKIGek1PkKsKGiJKejiiSR7btjsrqeWSyyQeeiONIy3lNHwkVsrwhgvahwszpmWhE6dd0dx6G9YUFNd1dBTSR7btpSbdhgOhw8)G(YD7(DoupS1czL24Hny4WBW1YsvxKEFec6CuoRDVBb7o8ueevu57eekRLzmuWCctkImstKGGWUUhmLifbraZIHPsq64Y2B(GdlKB10dhg1d3lOhgLhwAcIkQ8DcsqfWCLIuhXovuKIiZ8ejiiSR7btjsrqeWSyyQeeiOZhgvahw6dd8HHGoBRSLJ1hn(dJ(H7f0dd8HfMkSNdXfufv(Uoom6aoSKwuibrfv(obzp(NglTJuezmEIeee219GPePiicywmmvccqpCPd2l7E8pLctFcdTSR7btpSbdhgOhw8)G(YD7E8pLctFcdTqwPnsqurLVtqOQlsVpcbDokN1U3jfrgGqKGGWUUhmLifbraZIHPsq2GRLD)ohdMjpO2qPIjhgDahEUhg4ddbD(WOd4WstqurLVtqQVDhQ3zsrKPPejiiSR7btjsrqeWSyyQeKPpmqpS4BMD1lRZc4pEi9WgmC4n4Az193MUw57Xr2UTGDhEQdd8HN(WBW1YUFNJbZKhulKB10dhgvahgc6STYwowFC(dBWWH3GRLD)ohdMjpOwi3QPhomQao80hUxqpmAhw8)G(YD7E8pLctFcdTqwPnEyuE4shSx294FkfM(egAzx3dMEyuEyPp8uh2GHdVbxl7(DogmtEqTHsftomQhE(dp1Hb(WqqpfXUxodTuELISom6aoS0YsqurLVtqAvi8LdzNskImZLibbHDDpykrkcIaMfdtLGSbxl7(DogmtEqTHsftomQhUPhg4ddb9ue7E5m0s5vkY6WOd4WscKdd8HN(Wa9WIVz2vVSE2BwXLYh2GHdVbxllL1YmePGSfYTA6HdJ(HbYHNIGOIkFNG0Qq4lhYoLuezqHejiiSR7btjsrqeWSyyQeeGE4shSx294FkfM(egAzx3dMEyGpmL1YmQonszH2OfYTA6HdJ6HbYHb(WqqpfXUxodTuELISomQao80hwsGCy0o8gCTSu1fP3hHGohLZA37wWUdJYddKdJ2HdD8yelf2ZvWAYkSIHcMt4dJYdx6G9YAYkS2qwNWql76EW0dJYdl9HNIGOIkFNGyYkSIHcMtysrKbfKibbHDDpykrkcIaMfdtLGimvyphIlOkQ8DDCy0bCyjTOWdd8HN(WBW1YAYTFO0qgSHsftomQao80hgih24C4qhpgXsH9CfS7X)04(ZXHN6WgmC4qhpgXsH9CfS7X)04(ZXHr)WsF4PiiQOY3ji7X)04(ZbPiYiPSejiiSR7btjsrqeWSyyQeekVbxlBRcNe)vCp(NAPVC)WaF4v2Bwri3QPhom6hEUwGqqurLVtqAv4K4VI7X)usrKrsjjsqqyx3dMsKIGiGzXWujitF4n4AzfWSn8EmiEqypBb7omWhU0b7LfYJmygtpUh)tTSR7btp8uhg4ddb9ue7E5m0s5vkY6WOFyjLLGOIkFNGqzTmJQtJuwOnskImsknrccc76EWuIueebmlgMkbbc6Pi29Yz4HrhWHLuwzpmWhgOhEdUwwQ6I07JqqNJYzT7Dlyhbrfv(obz)ohQh2skImsoprccc76EWuIueebmlgMkbbc6Pi29YzOLYRuK1HrfWHN(WscKdJ2H3GRLLQUi9(ie05OCw7E3c2DyuEyGCy0oCOJhJyPWEUcwtwHvmuWCcFyuE4shSxwtwH1gY6egAzx3dMEyuEyPp8uh2GHdVYEZkc5wn9WHr9Wsklbrfv(obHYAzgdfmNWKIiJKgprccc76EWuIueebmlgMkbj0XJrSuypxblL1YmQonszH24HrhWHNNGOIkFNGqzTmJQtJuwOnskImsceIeee219GPePiicywmmvcYgCTSu1fP3hHGohLZA37wWUdBWWHHGoBRSLJ1hn(dJ6H7fucIkQ8DcIjRWkgkyoHjfrgjBkrccc76EWuIueebmlgMkbzdUwwQ6I07JqqNJYzT7Dlyhbrfv(obzp(Ng3FoifrgjNlrccc76EWuIueebmlgMkbbc6STYwowFC(dJ(H7fucIkQ8DcYE8pnwAhPiYijkKibbHDDpykrkcIaMfdtLGSbxlRaMTH3JbXdc7zly3Hny4WLoyVSqTlPrkl(2UpKv(ULDDpy6Hny4WHoEmILc75kyPSwMr1Prkl0gpm6aoS0eevu57eekRLzuDAKYcTrsrKrsuqIeee219GPePiicywmmvcYgCTS735yWm5b1c5wn9WHr)WZFyuE4EbLGOIkFNGiEpa22v57KIiJ0YsKGGWUUhmLifbraZIHPsqeMkSNdXfufv(Uoom6aoSKwjpmWhEdUw297CmyM8GAHCRME4WOF45pmkpCVGsqurLVtq2J)PX9NdsrKrAjjsqqyx3dMsKIGiGzXWujiqqNTv2YX6JZFyupCVGEydgo8gCTS735yWm5b1gkvm5WOF45EyGp8gCTS735yWm5b1c5wn9WHr)WqqNTv2YX6JZFy0oCVGsqurLVtqmzfwXqbZjmPiYiT0ejiiSR7btjsrqeWSyyQeeiONIy3lNHwkVsrwhg9dlTSeevu57eefkuNJ1dHSxKIueK2SYETY3jsqKrsIeee219GPePiicywmmvcIjRJY02jQdJ6HbISh2GHdp9Hb6H7Hpy3Hb(WMSoktBNOomQhUPn9WtrqurLVtqAwB7sykI7X)usrKrAIeee219GPePiicywmmvcs6IVn9(ivB1EooF4WOd4WMSoktRaeczViiQOY3jiuwlZyOG5eMuezMNibbHDDpykrkcIaMfdtLGe0M54E8pngmtEqpmWhoDX3MEFKQTAphbs4WOFyzpmWhEdUw294FAmyM8GAb7omWhEdUw294FAmyM8GAHCRME4WOEyjTa5WO8W9ckbrfv(obHYAzgdfmNWKIiJXtKGGWUUhmLifbraZIHPsq2GRLD)ohdMjpOwi3QPhomQhE(dJYd3lOwEozbyXh2GHdp9H3GRLD)ohdMjpOwi3QPhomQaome0zBLTCS(48h2GHdVbxl7(DogmtEqTqUvtpCyubC4PpCVGEy0oS4)b9L7294FkfM(egAHSsB8WO8WLoyVS7X)ukm9jm0YUUhm9WO8WsF4PoSbdhEdUw297CmyM8GAdLkMCyup88hEQdd8HHGEkIDVCgAP8kfzDy0bCyPLLGOIkFNG0Qq4lhYoLuezacrccc76EWuIueebmlgMkbPuFs69hg4dVbxlle05yPDw6l3pmWhoDX3MEFKQTAphNpCy0pSjRJY02QZ5Hr5HL1kjbrfv(obbc6CS0osrKPPejiiSR7btjsrqeWSyyQeetwhLPTtuhg1ddezpSX5WtFyPL9WO8WBW1YUh)tJbZKhuly3HNIGOIkFNGKcE)GonUEyLfiLjfrM5sKGGWUUhmLifbraZIHPsqmzDuM2orDyup8CbYHb(WDCz7nFWHfYTA6HdJ6Hbcbrfv(objOcyUsrQJyNkksrkcI4BMD1RarcImssKGGWUUhmLifbraZIHPsqeFZSREz9S3SIlLpmWhEdUwwkRLzisbzlKB10dhg9d30dd8HHGEkIDVCgEy0p8CLLGOIkFNGqzTmJHcMtysrKrAIeee219GPePiicywmmvcI4BMD1lRN9MvCP8Hb(WuwlZO60iLfAJ2kftsV)WaF4Pp80hEdUwwkRLzisbzly3Hny4WBW1YsvxKEFec6CuoRDVBb7o8uhg4dVbxllL1YmePGSfYTA6HdJ6HB6HNIGOIkFNGyYkSIHcMtysrKzEIeee219GPePiicywmmvccqp8gCTSuwlZqKcYwWUdBWWH3GRLLYAzgIuq2c5wn9WHr9Wg)Hny4WBW1YkGzB49yq8GWE2c2rqurLVtqOSwMHifKjfrgJNibbHDDpykrkcIaMfdtLGm9Hb6HfFZSREz9S3SIlLpSbdhEdUwwkRLzisbzlKB10dhg9d30dp1Hb(Wa9WBW1YsvxKEFec6CuoRDVBb7omWhE6d3XLT38bhwi3QPhomQhwszpSbdhUuypx2kB5y9rAYhg1d3lOhEkcIkQ8DcsqfWCLIuhXovuKIidqisqqyx3dMsKIGiGzXWujiIVz2vVSnZEz2i8WaFyiONIy3lNHhg9dpxzpmWhw8)G(YDBqUcBtVp2MHYc5wn9WHr9WZtqurLVtqOSwMXqbZjmPiY0uIeee219GPePiicywmmvccqp8gCTSu1fP3hHGohLZA37wWocIkQ8DcsqUcBtVp2MHIuezMlrccc76EWuIueebmlgMkbr8nZU6L1zb8hpKEyGp8gCTS735yWm5b1gkvm5WOc4WYsqurLVtqAvi8LdzNskImOqIeee219GPePiicywmmvccqp8gCTSu1fP3hHGohLZA37wWocIkQ8DcIU)201kFpoY2nPiYGcsKGGWUUhmLifbraZIHPsqe)pOVC3svxKEFec6CuoRDVBHCRME4WOE45pSbdhgOhEdUwwQ6I07JqqNJYzT7Dlyhbrfv(objyQIjdowMCe0L)WYSrsrksrqAMHH8DImslR0YkPKsJcsqKRqp9(abzoQT7HftpmqoSkQ89dpYqfS3mcIcwMpKGGKTgBhgTdphJNKJKG0b)voycstoSuJ)Ph2yyTmpmkop7nRBwtoSXWcUDZWd3uJoS0YkTS3SBwtomkM5KfGftp8MxpKpS4B3AD4n3NEWEyJRqWDv4W(7ghtf2Uahhwfv(E4WVpA0EZurLVhSDqw8TBTaag4ywCRrU2YauuKGPc1qC9Ef)vS7LZWBMkQ89GTdYIVDRfAaAamWXS4wJ41Ifv01wgGOrX4l47PiUhAOUz3SMCyumZjlalMEyUzg24HRSLpCzYhwf1dpCgoS2SMdDpy7ntfv(EaqB604cYmkcFZurLVhqdqdcDmIQOY3JJmug5AldOnRSxR8DJYfGs9jP3BWq6IVn9(ivB1EocKa6YEZurLVhqdqd7X)04ce2Or5cG4)b9L7wQ6I07JqqNJYzT7DlKvAJapnqf)pOVC3Uh)tPW0NWqlKvAJgma0shSx294FkfM(egAzx3dMo1ntfv(EananSzyGHtsV)MPIkFpGgGguOqDo2bocSr5cGkQSzoYo3MCaDasBWae0zuLeyiONIy3lNHwkVsrwO3uzVzQOY3dObOHr2BwHOXkiTVL9YOCbydUwwq38hngdfK9(Y0c2DZurLVhqdqdQl4qb1ruOJXntfv(EananSsiVh)tVzQOY3dObOHT2h)vSGPys4M1KdJKUGpCzYhU7R89dl(FqF5(Hn1WHfMQ3ZuJoSC2yzmoCOrxCy5zzEyJzoGcCZurLVhqdqdDFLVBuUaSbxllvDr69riOZr5S29UfS7MPIkFpGgGgadCmlUnCZurLVhqdqdqndCKYk9MPIkFpGgGg2J)Puy6tyOr5caq3GRLLQUi9(ie05OCw7E3c2b80av8nZU6L1ZEZkUu2GHn4AzPSwMHifKTqUvtpG(CN6MPIkFpGgGg2J)PX9NdJYfaHPc75a6aKg4PfFZSREzN0imv3GHn4AzPQlsVpcbDokN1U3TGDtDZurLVhqdqdqndCKYk9MPIkFpGgGgOSwMXqbZjSr5cWk7nRiKB10dOo)ntfv(Eanani0XiQIkFpoYqzKRTmaX3m7QxHBMkQ89aAaAqOJrufv(ECKHYixBzaHsDQcP3SBwtoSuGq)WZbJ9dNRdlNpSP2mF4kB5dV5soZ(HngJ5WqEb5GjhUzQOY3dwX3m7QxbauwlZyOG5e2OCbq8nZU6L1ZEZkUug4n4AzPSwMHifKTqUvtpGEtbgc6Pi29Yzi6Zv2BwtomkADcF4aiKpSC(Wo3mdp84d8HltTo8gCTUzQOY3dwX3m7Qxb0a0GjRWkgkyoHnkxaeFZSREz9S3SIlLbMYAzgvNgPSqB0wPys69ap90BW1YszTmdrkiBb7myydUwwQ6I07JqqNJYzT7Dly3uaVbxllL1YmePGSfYTA6buB6u3SMCyJRtpCzQ1HLZhwhY1gdhwOH6WgJXCynCyZS38WDW8pSCt2pSC(WQOa1XOXd7mtpCw3mvu57bR4BMD1RaAaAGYAzgIuq2OCbaOBW1YszTmdrkiBb7myydUwwkRLzisbzlKB10dOA8gmSbxlRaMTH3JbXdc7zly3nRjh24wf32vhU(dhubmxPGpCzYhU38bhhoxhwoF4oittrP7rJhwEogh2)6W0)WTGcZdN(Hlt(WoRWdValqiFZurLVhSIVz2vVcObOHGkG5kfPoIDQOmkxaMgOIVz2vVSE2BwXLYgmSbxllL1YmePGSfYTA6b0B6uad0n4AzPQlsVpcbDokN1U3TGDapDhx2EZhCyHCRMEavjL1GHsH9CzRSLJ1hPjJAVGo1nRjhwkqOF45GX(H)16WgRGH6WBE9q(Wb5kSn9(dl(woC4TkMC4FToSXMXCZurLVhSIVz2vVcObObkRLzmuWCcBuUai(Mzx9Y2m7LzJqGHGEkIDVCgI(CLfyX)d6l3Tb5kSn9(yBgklKB10dOo)nRjh2460dhKRW207pSgo849(dRHdlNnwG8H9VomQhE(WH)16WgZCaf4MPIkFpyfFZSREfqdqdb5kSn9(yBgkJYfaGUbxllvDr69riOZr5S29UfS7M1KdBSdzJJXff)HBvi8LF43pCh4yC40p8dPm8W1F4EqfQEX8H)qauHnEykim9(dxM8Hxjmuh2yMdOa3mvu57bR4BMD1RaAaAOvHWxoKDQr5cG4BMD1lRZc4pEif4n4Az3VZXGzYdQnuQycQaK9M1KdBCD6HLZhwOH6Wgxu83mvu57bR4BMD1RaAaAq3FB6ALVhhz72OCbaOBW1YsvxKEFec6CuoRDVBb7Uzn5WOa8Hnwbd1HPVBSuhwOH6WLzgomfeME)HnM5akWntfv(EWk(Mzx9kGgGgcMQyYGJLjhbD5pSmB0OCbq8)G(YDlvDr69riOZr5S29UfYTA6buN3GbGUbxllvDr69riOZr5S29UfS7MDZurLVhSTzL9ALVdOzTTlHPiUh)tnkxamzDuM2orHkqK1GHPbAp8b7a2K1rzA7efQnTPtDZAYHNJCX3ME)HPAR2ZhgYOOaMqUL96Wz4WsdeuSh(xhUvNZdBY6OmpC4hVrhgiYII9W)6WT6CEytwhL5Ht)W6H7HpyN9MPIkFpyBZk71kFhnanqzTmJHcMtyJYfG0fFB69rQ2Q9CC(a6amzDuMwbieYEDZAYHnM3nwQdp46WQFyEoZqLE)HLA8p9WiMjpOhMc)o7ntfv(EW2Mv2Rv(oAaAGYAzgdfmNWgLlabTzoUh)tJbZKhuGtx8TP3hPAR2ZrGeqxwG3GRLDp(NgdMjpOwWoG3GRLDp(NgdMjpOwi3QPhqvslqqzVGEZurLVhSTzL9ALVJgGgAvi8LdzNAuUaSbxl7(DogmtEqTqUvtpG68OSxqT8CYcWInyy6n4Az3VZXGzYdQfYTA6bubabD2wzlhRpoVbdBW1YUFNJbZKhulKB10dOcy6EbfnX)d6l3T7X)ukm9jm0czL2iklDWEz3J)Puy6tyOLDDpykkLEkdg2GRLD)ohdMjpO2qPIjOo)uadb9ue7E5m0s5vkYcDasl7ntfv(EW2Mv2Rv(oAaAac6CS0oJYfGs9jP3d8gCTSqqNJL2zPVCh40fFB69rQ2Q9CC(a6MSoktBRoNOuwRK3mvu57bBBwzVw57ObOHuW7h0PX1dRSaPSr5cGjRJY02jkubISgNPLwwuUbxl7E8pngmtEqTGDtDZurLVhSTzL9ALVJgGgcQaMRuK6i2PIYOCbWK1rzA7efQZfia3XLT38bhwi3QPhqfi3SBMkQ89GnuQtvifaL1YmgkyoHnkxaGGEkIDVCgAP8kfzHkajLf4PbAPd2l7(DoupS1YUUhm1GbGk(FqF5UD)ohQh2AHSsB0GHn4AzPQlsVpcbDokN1U3TGDtDZurLVhSHsDQcPObOHGkG5kfPoIDQOmkxa64Y2B(GdlKB10dO2lOOu6B2nRjhwfv(EWgk1PkKIgGg2J)Puy6tyOr5caq3GRLLQUi9(ie05OCw7E3c2DZAYHngWUrk0IPh2KH8H3Sqbd8Hlt(WTzL9ALVF4rgQdd5rYHd)(Hl1NKEFdLoj9(dt1wTNT3SMCyvu57bBOuNQqkAaAOvHWxoKDQr5cWgCTS735yWm5b1c5wn9aQZJYEb1YZjlal2GHP3GRLD)ohdMjpOwi3QPhqfae0zBLTCS(48gmSbxl7(DogmtEqTqUvtpGkGP7fu0e)pOVC3Uh)tPW0NWqlKvAJOS0b7LDp(NsHPpHHw219GPOu6PmyydUw297CmyM8GAdLkMG68tbme0trS7LZqlLxPil0biTS3SBwtomkQb(W7X)0dxA3HR)WDqUz2Rd)nZqH21LE)HfMkSNdhoxhwoFytTz(WHovWhE9WdRhgc68HvNEy9WZXn2mMdx)HdDkKpC9hEdc9dN1ntfv(EWgk1PkKcyp(NglTZOCbac6mQaKgyiOZ2kB5y9rJh9EbfyHPc75qCbvrLVRd0biPffEZurLVhSHsDQcPObObQ6I07JqqNJYzT7DJYfaGw6G9YUh)tPW0NWql76EWudgaQ4)b9L7294FkfM(egAHSsB8MPIkFpydL6ufsrdqd13Ud17Sr5cWgCTS735yWm5b1gkvmbDaZfyiOZOdq6BMkQ89GnuQtvifnan0Qq4lhYo1OCbyAGk(Mzx9Y6Sa(JhsnyydUwwD)TPRv(ECKTBly3uap9gCTS735yWm5b1c5wn9aQaGGoBRSLJ1hN3GHn4Az3VZXGzYdQfYTA6bubmDVGIM4)b9L7294FkfM(egAHSsBeLLoyVS7X)ukm9jm0YUUhmfLspLbdBW1YUFNJbZKhuBOuXeuNFkGHGEkIDVCgAP8kfzHoaPL9M1KdRIkFpydL6ufsrdqduwlZyOG5e2OCbac6Pi29YzOLYRuKfQaMRS3mvu57bBOuNQqkAaAOvHWxoKDQr5cWgCTS735yWm5b1gkvmb1Mcme0trS7LZqlLxPil0bijqaEAGk(Mzx9Y6zVzfxkBWWgCTSuwlZqKcYwi3QPhqhitDZurLVhSHsDQcPObObtwHvmuWCcBuUaa0shSx294FkfM(egAzx3dMcmL1YmQonszH2OfYTA6bubcWqqpfXUxodTuELISqfW0sce02GRLLQUi9(ie05OCw7E3c2HsGGwOJhJyPWEUcwtwHvmuWCcJYshSxwtwH1gY6egAzx3dMIsPN6MPIkFpydL6ufsrdqd7X)04(ZHr5cGWuH9CiUGQOY31b6aK0IcbE6n4Azn52puAid2qPIjOcyAGyCcD8yelf2ZvWUh)tJ7phtzWqOJhJyPWEUc294FAC)5aDPN6M1KdJIwHto8VoSuJ)PhM(C4W(xhUtDk3McJdpNf7u7ntfv(EWgk1PkKIgGgAv4K4VI7X)uJYfakVbxlBRcNe)vCp(NAPVCh4v2Bwri3QPhqFUwGCZurLVhSHsDQcPObObkRLzuDAKYcTrJYfGP3GRLvaZ2W7XG4bH9SfSd4shSxwipYGzm94E8p1YUUhmDkGHGEkIDVCgAP8kfzHUKYEZurLVhSHsDQcPObOH97COEyRr5cae0trS7LZq0biPSYcmq3GRLLQUi9(ie05OCw7E3c2DZurLVhSHsDQcPObObkRLzmuWCcBuUaab9ue7E5m0s5vkYcvatljqqBdUwwQ6I07JqqNJYzT7DlyhkbcAHoEmILc75kynzfwXqbZjmklDWEznzfwBiRtyOLDDpykkLEkdgwzVzfHCRMEavjL9MPIkFpydL6ufsrdqduwlZO60iLfAJgLlaHoEmILc75kyPSwMr1Prkl0grhW83mvu57bBOuNQqkAaAWKvyfdfmNWgLlaBW1YsvxKEFec6CuoRDVBb7myac6STYwowF04rTxqVzQOY3d2qPovHu0a0WE8pnU)CyuUaSbxllvDr69riOZr5S29UfS7MPIkFpydL6ufsrdqd7X)0yPDgLlaqqNTv2YX6JZJEVGEZurLVhSHsDQcPObObkRLzuDAKYcTrJYfGn4AzfWSn8EmiEqypBb7myO0b7LfQDjnszX329HSY3TSR7btnyi0XJrSuypxblL1YmQonszH2i6aK(MPIkFpydL6ufsrdqdI3dGTDv(Ur5cWgCTS735yWm5b1c5wn9a6ZJYEb9MPIkFpydL6ufsrdqd7X)04(ZHr5cGWuH9CiUGQOY31b6aK0kjWBW1YUFNJbZKhulKB10dOppk7f0BMkQ89GnuQtvifnanyYkSIHcMtyJYfaiOZ2kB5y9X5rTxqnyydUw297CmyM8GAdLkMG(CbEdUw297CmyM8GAHCRMEaDiOZ2kB5y9X5rRxqVzQOY3d2qPovHu0a0GcfQZX6Hq2lJYfaiONIy3lNHwkVsrwOlTSKIueca]] )

end