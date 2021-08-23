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


    spec:RegisterPack( "Blood", 20210705, [[d40k9aqiOIEKssUePe0MGk9jOQ0OafofOOvbvvVIaMfPWTaLQ2Lq)sGmmsPoguLLPK4zqfMgPK6AkPSnqP8nqjghOKCoLuLwNssLMhb19av7JaDqsjzHeKhskrMOsQCrqjvFujPIrckPKtckvSsLkVKucyMKsu3KuczNeQ(jOKsnuLuflvjP8uqMkHYvjLa9vLuvJLuc1Er8xPAWahMYIHYJjAYiDzuBwv(Ssz0KQtlz1kjv9ALQMTuUTsSBQ(TkdxqhhusXYH8CsMUORRQ2oPOVtiJhQkoVa16bLknFbSFftWJigbIAjteFfTxbpTHfTxlQnSsRXdhWcbkdoKjqHMCVTXei3wycKqT7OeOql42zuIyei19rsMabvl)ML15AjK9sce2VAjSJtWiqulzI4RO9k4PnSO9ArTHvAnE4yfcKkKLeXxznTjq6fLYobJarzLKaju7o6awhBP(a0c41MEo729BbpG10yaRO9k4rGALkveXiqu(z)wseJioEeXiqSBynMseIarzLevHzDobcwhFy5pz6aynzuWdiRfEaPopatMhAaLAaMMw1mSghjqMmRZjqlLt7peZWUmjjIVcrmce7gwJPeHiqsuLmQmce2)9IyNZDLEXnAeXlw5Qbi8aWXaW)a2K0iJpS8N8aceyaWyay)3lIDo3v6f3OreVyLRgGWWha67CmRfUNxhhdiqGbG9FVi25CxPxCJgr8IvUAacdFaWyaBs6aeyaY7A0tKhXA3rPOY3ZOiInAWda)diTg7zeRDhLIkFpJISBynMoa8pGvgamhqGada7)ErSZ5UsV4gnQstUFacpG1gamhaUda99s2dprmks5xjRCaccFaROnbYKzDobAXqOteIDkjjIJdIyei2nSgtjcrGKOkzuzeO089LVnGabgq5YBP8To1wSnUVMAacoaTjqMmRZjqsR16MmRZ7TsLeOwPYUBlmbAPYAZY6CssexRjIrGy3WAmLiebsIQKrLrGK31ONipsnxw(wh9DUlITWZJi2ObpaChamgaohG8Ug9e5rS2DukQ89mkIyJg8aceya4CaP1ypJyT7Ouu57zuKDdRX0batcKjZ6Ccew7oA)9rbtsI4RreJazYSoNaHXifJ2x(gbIDdRXuIqKKioSreJaXUH1ykricKevjJkJazYS0K7SZlfRgGGWhWkdiqGbG(opaHhaEda3bG(Ej7HNigfP8RKvoabhaSPnbYKzDobYqsZ5E4VPyssehwiIrGy3WAmLiebsIQKrLrGW(Vx876xl4UkrSVL6XFibYKzDobQvB6PQV6)0Tf2tssehwreJazYSoNazUKvjYADP1Aei2nSgtjcrsI4RxIyeitM15eOxHyS2Duce7gwJPeHijrC80MigbYKzDobcZ263RNOsUxrGy3WAmLiejjIJhEeXiqSBynMseIajrvYOYiqy)3lsnxw(wh9DUlITWZJ)qceLvsufM15eiOYL8asDEaHxwNpa5Dn6jYhGUPgGu38nMQXaeX4BRnavWUCaIQuFaRB1wFcKjZ6Ccu4L15KKioERqeJazYSoNa9vCVsErrGy3WAmLiejjIJhoiIrGmzwNtGqwP4oLnkbIDdRXuIqKKioEAnrmce7gwJPeHiqsuLmQmceoha2)9IuZLLV1rFN7Iyl884pCa4oaymaCoa5Pj7MNrV20Z(Z4beiWaW(VxKYwQR60phr8IvUAacoayzaWKazYSoNaH1UJsrLVNrKKioERreJaXUH1ykricKevjJkJaj1n0gRgGGWhWkda3baJbipnz38mUpyuz(aceyay)3lsnxw(wh9DUlITWZJ)WbatcKjZ6Ccew7oAh7QgjjIJhSreJazYSoNaHSsXDkBuce7gwJPeHijrC8GfIyei2nSgtjcrGKOkzuzeOxTPNDeVyLRgGWdaheitM15eikBPExLOAptsI44bRiIrGy3WAmLiebYKzDobsATw3KzDEVvQKa1kv2DBHjqYtt2npvKKioERxIyei2nSgtjcrGmzwNtGKwR1nzwN3BLkjqTsLD3wycKknNAikjjjbkeXYBbZsIyeXXJigbIDdRXuIqeitM15eid2vPBit1FNN971dprmIarzLevHzDobcwhFy5pz6aW43H4biVfmlhagVvUkoaTsk5Wuna)CyVUHwE)2amzwNRgW5TGJei3wycKb7Q0nKP6VZZ(96HNigrsI4RqeJaXUH1ykricKjZ6CcKmyz7s05LSJ1mvsG43JLz3TfMajdw2UeDEj7yntLKKiooiIrGmzwNtGEnwPlr2ljqSBynMseIKKKaPsZPgIseJioEeXiqSBynMseIajrvYOYiqOVxYE4jIrrk)kzLdqy4dapThaUdagdaNdiTg7ze7CwLhAjYUH1y6aceya4CaY7A0tKhXoNv5HwIi2ObpGabga2)9IuZLLV1rFN7Iyl884pCaWKazYSoNarzl17Qev7zsseFfIyei2nSgtjcrGKOkzuzeOqoJB63Vfr8IvUAacpGnjDa4FaRqGmzwNtGuMevVswwRhAYKKeXXbrmce7gwJPeHiqMmRZjqyT7O90cjquwjrvywNtG0cQ4bG1UJoG0chqEdieXAYEoGttgjTWWY3gGu3qBSAa1BaI4bOBAYdqfAsEaVdnaBaOVZdWC6aSbS6OLw3aYBaQqdXdiVbG9r(aQKajrvYOYiqOVZdqy4dyLbG7aqFNJzTW986A9aeCaBs6aWDasDdTXQ(dzYSo3Adqq4daViSIKeX1AIyei2nSgtjcrGKOkzuzeiCoG0ASNrS2DukQ89mkYUH1y6aceya4CaY7A0tKhXA3rPOY3ZOiInAWeitM15eiQ5YY36OVZDrSfEojjIVgrmce7gwJPeHiqsuLmQmce2)9IyNZDLEXnAuLMC)aee(aGLbG7aqFNhGGWhWkeitM15eO8wWu55mjjIdBeXiqSBynMseIajrvYOYiqy)3lIDo3v6f3OrvAY9dq4baBda3bG(Ej7HNigfP8RKvoabHpa8wBa4oaymaCoa5Pj7MNrV20Z(Z4beiWaW(VxKYwQR60phr8IvUAacoG1gamjqMmRZjqlgcDIqStjjrCyHigbIDdRXuIqeijQsgvgbcNdiTg7zeRDhLIkFpJISBynMoaChaLTuVBoTtzPfCeXlw5Qbi8awBa4oa03lzp8eXOiLFLSYbim8baJbG3AdqGbG9FVi1Cz5BD035Ui2cpp(dha(hWAdqGbOc5wRNgAJtvuNnu2vjQ2Zda)diTg7zuNnuIHyBpJISBynMoa8pGvgamjqMmRZjq6SHYUkr1EMKeXHveXiqSBynMseIajrvYOYiqsDdTXQ(dzYSo3Adqq4daViSAa4oaymaS)7f15LtLMQurvAY9dqy4dagdyTba7hGkKBTEAOnovrS2D0o2vTbaZbeiWauHCR1tdTXPkI1UJ2XUQnabhWkdaMeitM15eiS2D0o2vnsseF9seJaXUH1ykricKjZ6Cc0IH23VxhRDhLarzLevHzDobslYq7hW9gGqT7OdGESAa(Ldi0CkVusypJpj70ibsIQKrLrGOm2)9IlgAF)EDS2D0i9e5da3b8Qn9SJ4fRC1aeCaWsCnssehpTjIrGy3WAmLiebsIQKrLrGGXaW(VxuIQf15DL8(Ono(dhaUdiTg7zeXTsP3lVJ1UJgz3WAmDaWCa4oa03lzp8eXOiLFLSYbi4aWtBcKjZ6CceLTuVBoTtzPfmjjIJhEeXiqSBynMseIajrvYOYiqOVxYE4jIrdqq4dapT1Ea4oaCoaS)7fPMllFRJ(o3fXw45XFibYKzDobc7CwLhAHKeXXBfIyei2nSgtjcrGKOkzuzei03lzp8eXOiLFLSYbim8baJbG3AdqGbG9FVi1Cz5BD035Ui2cpp(dha(hWAdqGbOc5wRNgAJtvuNnu2vjQ2Zda)diTg7zuNnuIHyBpJISBynMoa8pGvgamhqGad4vB6zhXlw5Qbi8aWtBcKjZ6CceLTuVRsuTNjjrC8Wbrmce7gwJPeHiqsuLmQmcKkKBTEAOnovrkBPE3CANYsl4bii8bGdcKjZ6CceLTuVBoTtzPfmjjIJNwteJaXUH1ykricKevjJkJaH9FVi1Cz5BD035Ui2cpp(dhqGada9DoM1c3ZRR1dq4bSjPeitM15eiD2qzxLOAptsI44Tgrmce7gwJPeHiqsuLmQmce2)9IuZLLV1rFN7Iyl884pKazYSoNaH1UJ2XUQrsI44bBeXiqSBynMseIajrvYOYiqOVZXSw4EEDCmabhWMKsGmzwNtGWA3r7PfssI44bleXiqSBynMseIajrvYOYiqy)3lkr1I68UsEF0gh)HdiqGbKwJ9mISWI2PS8wcpvL15r2nSgthqGadqfYTwpn0gNQiLTuVBoTtzPf8aee(awHazYSoNarzl17Mt7uwAbtsI44bRiIrGy3WAmLiebsIQKrLrGW(Vxe7CUR0lUrJiEXkxnabhaoga(hWMKsGmzwNtGKNR(lHzDojjIJ36LigbIDdRXuIqeijQsgvgbsQBOnw1FitM15wBaccFa4fXBa4oaS)7fXoN7k9IB0iIxSYvdqWbGJbG)bSjPeitM15eiS2D0o2vnsseFfTjIrGy3WAmLiebsIQKrLrGqFNhGGdaVbG7aGXaqFNJzTW9864yacpGnjDabcmaS)7fXoN7k9IB0Okn5(bi4aGLbG7aW(Vxe7CUR0lUrJiEXkxnabha67CmRfUNxhhdqGbSjPdaMeitM15eiD2qzxLOAptsI4RGhrmce7gwJPeHiqsuLmQmce67LShEIyuKYVsw5aeCaROnbYKzDobYqsZ5EEie7jjjjbsEAYU5PIigrC8iIrGy3WAmLiebYKzDobIYwQ3vjQ2ZeikRKOkmRZjqc9r(awT1ZaQ3aeXdq30Khqwl8aW4ueZ(aw36gaIFiwPZkcKevjJkJajpnz38m61ME2FgpaCha2)9Iu2sDvN(5iIxSYvdqWbaBda3bG(Ej7HNignabhaSOnjjIVcrmce7gwJPeHiqMmRZjq6SHYUkr1EMarzLevHzDobslY2Zdq9r8aeXdWznz0aANIhqQB5aW(VhbsIQKrLrGKNMSBEg9Atp7pJhaUdGYwQ3nN2PS0coMLCF5Bda3baJbaJbG9FViLTux1PFo(dhqGada7)ErQ5YY36OVZDrSfEE8hoayoaCha2)9Iu2sDvN(5iIxSYvdq4baBdaMKKiooiIrGy3WAmLiebYKzDobIYwQR60ptGOSsIQWSoNaPvoDaPULdqepaRjYcwnaPPYbSU1natna9AtFaHO6gGiD2hGiEaMm)wRf8aCMPdOscKevjJkJaHZbG9FViLTux1PFo(dhqGada7)ErkBPUQt)CeXlw5Qbi8a06beiWaW(VxuIQf15DL8(Ono(djjrCTMigbIDdRXuIqeitM15eiLjr1RKL16HMmjquwjrvywNtG0Qm5LWCa5naLjr1RK8asDEaB63VnG6nar8acrmTKPH1cEaIQwBa(LdGEdy5l1hq5di15b4SHgW7NFetGKOkzuzeiymaCoa5Pj7MNrV20Z(Z4beiWaW(VxKYwQR60phr8IvUAacoayBaWCa4oaCoaS)7fPMllFRJ(o3fXw45XF4aWDaWyaHCg30VFlI4fRC1aeEa4P9aceyaPH24mM1c3ZRtlEacpGnjDaWKKeXxJigbIDdRXuIqeitM15eikBPExLOAptGOSsIQWSoNaj0h5dy1wpd4EVbS6)QCay87q8auIm0s5BdqElSAayMC)aU3BaAP1rGKOkzuzei5Pj7MNrnzp1dgnaCha67LShEIy0aeCaWI2da3biVRrprEujYqlLV1xkvgr8IvUAacpaCqsI4Wgrmce7gwJPeHiqMmRZjqkrgAP8T(sPsceLvsufM15eiTYPdqjYqlLVnatnG25BdWudqeJViEa(Ldq4bGd1aU3BaRB1wFcKevjJkJaHZbG9FVi1Cz5BD035Ui2cpp(djjrCyHigbIDdRXuIqeitM15eOfdHori2PeikRKOkmRZjqRhed71kT8awme6enGZhq4V1gq5d4qugnG8gW23qMNmpGtP(gk4bq)OY3gqQZd4vivoG1TARpbsIQKrLrGKNMSBEgDwIU2HOda3bG9FVi25CxPxCJgvPj3paHHpaTjjrCyfrmce7gwJPeHiqMmRZjqg2TuUL159wTGrGOSsIQWSoNaPvoDaI4binvoaTsltGKOkzuzeiCoaS)7fPMllFRJ(o3fXw45XFijjIVEjIrGy3WAmLiebYKzDobsPBY9nUN6C)7IouQhmbIYkjQcZ6Cc06Zdy1)v5aONJV5aKMkhqQxQbq)OY3gW6wT1NajrvYOYiqY7A0tKhPMllFRJ(o3fXw45reVyLRgGWdahdiqGbGZbG9FVi1Cz5BD035Ui2cpp(djjrC80MigbIDdRXuIqeijQsgvgbsD)gw50y4xL)g3z0pmRZJSBynMoGabgG6(nSYPrnVMLvJ7QRPj7zKDdRXucu5jJq)WSxpcK6(nSYPrnVMLvJ7QRPj7jbQ8KrOFy2RLfMwwYei8iqMmRZjqVgR0Li7LeOYtgH(HzFRDywJaHhjjjbAPYAZY6CIyeXXJigbIDdRXuIqeijQsgvgbsNTwQhdL5aeEaRP9aceyaWya4CaBO7hoaChGoBTupgkZbi8aGnyBaWKazYSoNaPPTewOs2XA3rjjr8viIrGy3WAmLiebYKzDobIYwQ3vjQ2ZeikRKOkmRZjqWoU8wkFBauBX24bGyyn)cXlSNdOudyL10chW9gWIHpdqNTwQpa11ongWAARfoG7nGfdFgGoBTuFaLpaBaBO7hgjqsuLmQmcu5YBP8To1wSnUJd1aee(a0zRL6r5hHypjjrCCqeJaXUH1ykricKjZ6CceLTuVRsuTNjquwjrvywNtGw354BoGgNdW8bW4tPYY3gGqT7OdasV4gDau0fgjqsuLmQmcKY0K7yT7ODLEXn6aWDaLlVLY36uBX24(AQbi4a0Ea4oaS)7fXA3r7k9IB04pCa4oaS)7fXA3r7k9IB0iIxSYvdq4bGxCTbG)bSjPKKiUwteJaXUH1ykricKevjJkJaLMVV8TbG7aW(Vxe9DUNwyKEI8bG7akxElLV1P2ITXDCOgGGdqNTwQhxm8za4FaAhXJazYSoNaH(o3tlKKeXxJigbIDdRXuIqeijQsgvgbsNTwQhdL5aeEaRP9aG9dagdyfTha(ha2)9IyT7ODLEXnA8hoaysGmzwNtGkjJDFN2FhkR8tzsseh2iIrGy3WAmLiebsIQKrLrG0zRL6XqzoaHhaSS2aWDaHCg30VFlI4fRC1aeEaRrGmzwNtGuMevVswwRhAYKKKKKeinzKQoNi(kAVcEAdBRSEjqImKx(MIaT(A1QjoSJ4RoRUdyaIPZdOwcpuoG3Hga(kpnz38uHVdaXWA(fIPdqDl8aSFElwY0bi1nFJvXzNwUCEa4P9Q7a0sNRjJsMoa8vD)gw50Owm(oG8ga(QUFdRCAuloYUH1yk(oayGh(aZ4Stlxopa80E1DaAPZ1Krjtha(QUFdRCAulgFhqEdaFv3VHvonQfhz3WAmfFhGLdawhwBT8aGbE4dmJZUzhSZs4HsMoG1gGjZ68b0kvQIZocui6EvJjqRAac1UJoG1XwQpaTaETPNZUvnGD)wWdynngWkAVcEZUz3QgaSo(WYFY0bGXVdXdqElywoamERCvCaALuYHPAa(5WEDdT8(TbyYSoxnGZBbhNDMmRZvXqelVfmlH)vCVsErd3wy4gSRs3qMQ)op73RhEIy0SZKzDUkgIy5TGzPaWd6R4EL8Ig87XYS72cdxgSSDj68s2XAMkNDMmRZvXqelVfmlfaEqVgR0Li7LZUz3QgaSo(WYFY0bWAYOGhqwl8asDEaMmp0ak1amnTQzynoo7mzwNRGVuoT)qmd7YZotM15kbGh0IHqNie7unQhCS)7fXoN7k9IB0iIxSYvcJd8VjPrgFy5p5abGb2)9IyNZDLEXnAeXlw5kHHJ(ohZAH751XrGay)3lIDo3v6f3OreVyLRegom2KubK31ONipI1UJsrLVNrreB0GXFAn2Ziw7okfv(Egfz3WAmf)RaZabW(Vxe7CUR0lUrJQ0K7fEnyIl67LShEIyuKYVswPGWxr7zNjZ6CLaWdsATw3KzDEVvQud3wy4lvwBwwNRr9GNMVV8TabkxElLV1P2ITX91ucQ9SZKzDUsa4bH1UJ2FFuWAup4Y7A0tKhPMllFRJ(o3fXw45reB0GXfg4uExJEI8iw7okfv(EgfrSrdoqaCMwJ9mI1UJsrLVNrr2nSgtH5SZKzDUsa4bHXifJ2x(2SZKzDUsa4bziP5Cp83uSg1dUjZstUZoVuSsq4Reia67SW4Hl67LShEIyuKYVswPGWM2ZotM15kbGhuR20tvF1)PBlSNAup4y)3l(D9RfCxLi23s94pC2zYSoxja8GmxYQezTU0ATzNjZ6CLaWd6vigRDhD2zYSoxja8GWST(96jQK7vZUvnaOYL8asDEaHxwNpa5Dn6jYhGUPgGu38nMQXaeX4BRnavWUCaIQuFaRB1w)zNjZ6CLaWdk8Y6CnQhCS)7fPMllFRJ(o3fXw45XF4SZKzDUsa4b9vCVsErn7mzwNReaEqiRuCNYgD2zYSoxja8GWA3rPOY3ZinQhCCI9FVi1Cz5BD035Ui2cpp(dXfg4uEAYU5z0Rn9S)moqaS)7fPSL6Qo9ZreVyLReewG5SZKzDUsa4bH1UJ2XUQPr9Gl1n0gRee(k4cd5Pj7MNX9bJkZdea7)ErQ5YY36OVZDrSfEE8hcZzNjZ6CLaWdczLI7u2OZotM15kbGheLTuVRsuTN1OEWF1ME2r8IvUsyCm7mzwNReaEqsR16MmRZ7TsLA42cdxEAYU5PA2zYSoxja8GKwR1nzwN3BLk1WTfgUknNAi6SB2TQbi0h5dy1wpdOEdqepaDttEazTWdaJtrm7dyDRBai(HyLoRMDMmRZvr5Pj7MNk4u2s9Ukr1EwJ6bxEAYU5z0Rn9S)mgxS)7fPSL6Qo9ZreVyLRee2Wf99s2dprmsqyr7z3QgGwKTNhG6J4biIhGZAYOb0ofpGu3YbG9FVzNjZ6CvuEAYU5Psa4bPZgk7Qev7znQhC5Pj7MNrV20Z(ZyCPSL6DZPDklTGJzj3x(gUWagy)3lszl1vD6NJ)WabW(VxKAUS8To67CxeBHNh)HWexS)7fPSL6Qo9ZreVyLReg2G5SBvdqRC6asDlhGiEawtKfSAastLdyDRBaMAa61M(acr1nar6Spar8amz(Twl4b4mthqLZotM15QO80KDZtLaWdIYwQR60pRr9GJtS)7fPSL6Qo9ZXFyGay)3lszl1vD6NJiEXkxjSwhia2)9IsuTOoVRK3hTXXF4SBvdqRYKxcZbK3auMevVsYdi15bSPF)2aQ3aeXdieX0sMgwl4biQATb4xoa6nGLVuFaLpGuNhGZgAaVF(r8SZKzDUkkpnz38uja8GuMevVswwRhAYuJ6bhg4uEAYU5z0Rn9S)moqaS)7fPSL6Qo9ZreVyLRee2GjU4e7)ErQ5YY36OVZDrSfEE8hIlmc5mUPF)weXlw5kHXt7absdTXzmRfUNxNwSWBskmNDRAac9r(awT1ZaU3BaR(Vkhag)oepaLidTu(2aK3cRgaMj3pG79gGwADZotM15QO80KDZtLaWdIYwQ3vjQ2ZAup4Ytt2npJAYEQhmcx03lzp8eXibHfTXvExJEI8OsKHwkFRVuQmI4fRCLW4y2TQbOvoDakrgAP8TbyQb0oFBaMAaIy8fXdWVCacpaCOgW9EdyDR26p7mzwNRIYtt2npvcapiLidTu(wFPuPg1dooX(VxKAUS8To67CxeBHNh)HZUvnG1dIH9ALwEalgcDIgW5di83AdO8bCikJgqEdy7BiZtMhWPuFdf8aOFu5Bdi15b8kKkhW6wT1F2zYSoxfLNMSBEQeaEqlgcDIqSt1OEWLNMSBEgDwIU2HO4I9FVi25CxPxCJgvPj3lmCTNDRAaALthGiEastLdqR0YZotM15QO80KDZtLaWdYWULYTSoV3QfmnQhCCI9FVi1Cz5BD035Ui2cpp(dNDRAaRppGv)xLdGEo(MdqAQCaPEPga9JkFBaRB1w)zNjZ6CvuEAYU5Psa4bP0n5(g3tDU)Drhk1dwJ6bxExJEI8i1Cz5BD035Ui2cppI4fRCLW4iqaCI9FVi1Cz5BD035Ui2cpp(dNDMmRZvr5Pj7MNkbGh0RXkDjYEPg1dU6(nSYPXWVk)nUZOFywNhiG6(nSYPrnVMLvJ7QRPj7PgLNmc9dZETSW0YsgoEAuEYi0pm7BTdZAWXtJYtgH(HzVEWv3VHvonQ51SSACxDnnzpNDZotM15Q4sL1ML15W10wcluj7yT7OAup46S1s9yOmfEnTdeag4CdD)qC1zRL6XqzkmSbBWC2TQba74YBP8TbqTfBJhaIH18leVWEoGsnGvwtlCa3Balg(maD2AP(aux70yaRPTw4aU3awm8za6S1s9bu(aSbSHUFyC2zYSoxfxQS2SSoxa4brzl17Qev7znQh8YL3s5BDQTyBChhkbHRZwl1JYpcXEo7w1aw354BoGgNdW8bW4tPYY3gGqT7OdasV4gDau0fgNDMmRZvXLkRnlRZfaEqu2s9Ukr1EwJ6bxzAYDS2D0UsV4gf3YL3s5BDQTyBCFnLGAJl2)9IyT7ODLEXnA8hIl2)9IyT7ODLEXnAeXlw5kHXlUg(3K0zNjZ6CvCPYAZY6CbGhe67CpTqnQh8089LVHl2)9IOVZ90cJ0tKJB5YBP8To1wSnUJdLG6S1s94IHp4x7iEZotM15Q4sL1ML15capOsYy33P93HYk)uwJ6bxNTwQhdLPWRPnShgROn(X(VxeRDhTR0lUrJ)qyo7mzwNRIlvwBwwNla8GuMevVswwRhAYuJ6bxNTwQhdLPWWYA4gYzCt)(TiIxSYvcV2SB2zYSoxfvP5udrHtzl17Qev7znQhC03lzp8eXOiLFLSsHHJN24cdCMwJ9mIDoRYdTez3WAmnqaCkVRrprEe7CwLhAjIyJgCGay)3lsnxw(wh9DUlITWZJ)qyo7mzwNRIQ0CQHOcapiLjr1RKL16HMm1OEWd5mUPF)weXlw5kH3Ku8VYSB2TQvnatM15QOknNAiQaWdcRDhLIkFpJ0OEWXj2)9IuZLLV1rFN7Iyl884pC2TQvnG19dBL0sMoaDgXdaJL2xXdi15bSuzTzzD(aALkhaIBfRgW5dinFF5BbL2(Y3ga1wSnoo7w1QgGjZ6CvuLMtneva4bTyi0jcXovJ6bh7)ErSZ5UsV4gnI4fRCLW4a)BsAKXhw(toqayG9FVi25CxPxCJgr8IvUsy4OVZXSw4EEDCeia2)9IyNZDLEXnAeXlw5kHHdJnjva5Dn6jYJyT7Ouu57zueXgny8NwJ9mI1UJsrLVNrr2nSgtX)kWmqaS)7fXoN7k9IB0Okn5EHXbmXf99s2dprmks5xjRuq4RO9SB2TQbOfuXdaRDhDaPfoG8gqiI1K9CaNMmsAHHLVnaPUH2y1aQ3aeXdq30KhGk0K8aEhAa2aqFNhG50bydy1rlTUbK3auHgIhqEda7J8bu5SZKzDUkQsZPgIchRDhTNwOg1do67SWWxbx035ywlCpVUwl4MKIRu3qBSQ)qMmRZTMGWXlcRMDMmRZvrvAo1qubGhe1Cz5BD035Ui2cpxJ6bhNP1ypJyT7Ouu57zuKDdRX0abWP8Ug9e5rS2DukQ89mkIyJg8SZKzDUkQsZPgIka8GYBbtLNZAup4y)3lIDo3v6f3OrvAY9cchwWf9Dwq4Rm7w1QgGjZ6CvuLMtneva4bTyi0jcXovJ6bhg4uEAYU5z0zj6AhIgia2)9Ig2TuUL159wTGf)HWexyG9FVi25CxPxCJgr8IvUsy4OVZXSw4EEDCeia2)9IyNZDLEXnAeXlw5kHHdJnjva5Dn6jYJyT7Ouu57zueXgny8NwJ9mI1UJsrLVNrr2nSgtX)kWmqaS)7fXoN7k9IB0Okn5EHxdM4I(Ej7HNigfP8RKvki8v0E2TQvnatM15QOknNAiQaWdIYwQ3vjQ2ZAup4OVxYE4jIrrk)kzLcdhw0E2zYSoxfvP5udrfaEqlgcDIqSt1OEWX(Vxe7CUR0lUrJQ0K7fg2Wf99s2dprmks5xjRuq44TgUWaNYtt2npJETPN9NXbcG9FViLTux1PFoI4fRCLGRbZzNjZ6CvuLMtneva4bPZgk7Qev7znQhCCMwJ9mI1UJsrLVNrr2nSgtXLYwQ3nN2PS0coI4fRCLWRHl67LShEIyuKYVswPWWHbERja2)9IuZLLV1rFN7Iyl884pe)RjGkKBTEAOnovrD2qzxLOApJ)0ASNrD2qjgIT9mkYUH1yk(xbMZotM15QOknNAiQaWdcRDhTJDvtJ6bxQBOnw1FitM15wtq44fHv4cdS)7f15LtLMQurvAY9cdhgRb7vHCR1tdTXPkI1UJ2XUQbZabuHCR1tdTXPkI1UJ2XUQj4kWC2TQbOfzO9d4EdqO2D0bqpwna)YbeAoLxkjSNXNKDAC2zYSoxfvP5udrfaEqlgAF)EDS2DunQhCkJ9FV4IH23VxhRDhnsproUVAtp7iEXkxjiSexB2zYSoxfvP5udrfaEqu2s9U50oLLwWAup4Wa7)ErjQwuN3vY7J244pe30ASNre3kLEV8ow7oAKDdRXuyIl67LShEIyuKYVswPG4P9SZKzDUkQsZPgIka8GWoNv5Hw0OEWrFVK9WteJeeoEARnU4e7)ErQ5YY36OVZDrSfEE8ho7mzwNRIQ0CQHOcapikBPExLOApRr9GJ(Ej7HNigfP8RKvkmCyG3AcG9FVi1Cz5BD035Ui2cpp(dX)AcOc5wRNgAJtvuNnu2vjQ2Z4pTg7zuNnuIHyBpJISBynMI)vGzGaVAtp7iEXkxjmEAp7mzwNRIQ0CQHOcapikBPE3CANYslynQhCvi3A90qBCQIu2s9U50oLLwWcchhZotM15QOknNAiQaWdsNnu2vjQ2ZAup4y)3lsnxw(wh9DUlITWZJ)WabqFNJzTW986ATWBs6SZKzDUkQsZPgIka8GWA3r7yx10OEWX(VxKAUS8To67CxeBHNh)HZotM15QOknNAiQaWdcRDhTNwOg1do67CmRfUNxhhcUjPZotM15QOknNAiQaWdIYwQ3nN2PS0cwJ6bh7)ErjQwuN3vY7J244pmqG0ASNrKfw0oLL3s4PQSopYUH1yAGaQqU16PH24ufPSL6DZPDklTGfe(kZotM15QOknNAiQaWdsEU6VeM15Aup4y)3lIDo3v6f3OreVyLReeh4FtsNDMmRZvrvAo1qubGhew7oAh7QMg1dUu3qBSQ)qMmRZTMGWXlIhUy)3lIDo3v6f3OreVyLReeh4FtsNDMmRZvrvAo1qubGhKoBOSRsuTN1OEWrFNfepCHb67CmRfUNxhhcVjPbcG9FVi25CxPxCJgvPj3liSGl2)9IyNZDLEXnAeXlw5kbrFNJzTW9864qGnjfMZotM15QOknNAiQaWdYqsZ5EEie7Pg1do67LShEIyuKYVswPGROnbY(P(Hiqq1IwAacmayT49vRijjjea]] )

end