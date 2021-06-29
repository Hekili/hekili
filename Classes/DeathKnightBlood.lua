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
            duration = 10,
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


    spec:RegisterPack( "Blood", 20210628, [[dSeA8aqiOsEeOexIOIYMGk(erL0OafoLsLwfuPEfuvZIu0TaLk7sOFrk1WiLCmIslJOQNPu00ukORbkABkv03aLY4ukW5aLuMhuL7bQ2hr4GevQfse9qLkOjQuOlsur1hjQiAKGss6KevIwPsvVeusQzsur6Mevc7KuyOGsILQuHEkitLO4QGss8vqPQ9I4VszWQCyklgkpMWKr6YO2mGplvnAs1PfTALkWRvknBLCBPYUP63QA4c64evewoKNtY0LCDG2Ua13jsJNOcNxGSEqjvZxa7xXezjYqGOwXenKxl5LvRDk)geLFtT2u2nGavbfYeOqtS16zcKBDmbsY1)ucuOf06nkrgcK6brcMabLDGlRY33HidOiqyG5QKlDcgbIAft0qETKxwT2P8Bqu(n1Atz3qcKkKfenKhMArG0tkLDcgbIYkbbsY1)052iBL(CWQ9SxVM97bDEo53anNtETKxlc0kvLIidbIYag4QiYq0qwImei2nSftjssGOSsGYWkFNajNlhSaSy6CCWmkO5QSJNR055mr9O5s1CwWwUmSfhjqMOY3jqDPtBaiMH1zsr0qEImei2nSftjssGeOSyuAeimqaGi27CtPN8IgrCNLUAo8MBZ5W9C9cAKLdwaw8CbcmhmMddeaiI9o3u6jVOre3zPRMdp4ZHaDowzh3QVT5Cbcmhgiaqe7DUP0tErJiUZsxnhEWNdgZ1lOZH)CI)x0xQhXw)tPO03YOiInAqZH75kBXEfXw)tPO03YOi7g2IPZH75KFUDNlqG5WabaIyVZnLEYlAuvMy7C4n3MZT7C4mhc0trl8LYOiLbsrwZjb85KxlcKjQ8DcuNHqVue7usr0ytImei2nSftjssGeOSyuAeOY8TP3pxGaZLU47sVVrToRNBWunNeZPfbYev(obsyRvZev(EBLQIaTsv1CRJjqDzL9wLVtkIgBirgce7g2IPejjqcuwmkncK4)f9L6rQ5I07BiqNBszl89iInAqZHZCWyoCnN4)f9L6rS1)ukk9TmkIyJg0CbcmhUMRSf7veB9pLIsFlJISBylMo3Ueitu57eiS1)0gaikisr0aMeziqMOY3jqymsXOTP3tGy3WwmLijPiAStImei2nSftjssGeOSyuAeituzWCJDUlz1CsaFo5NlqG5qGophEZj7C4mhc0trl8LYOiLbsrwZjXC7ulcKjQ8DcKHeMZTqWLIjfrdyJidbIDdBXuIKeibklgLgbcdeaic66)kOMQqS3x6rWqcKjQ8Dc0k71lvBhas77yVifrJnGidbYev(obYCbRkKTAcBTiqSBylMsKKuenG1iYqGmrLVtGaseJT(NsGy3WwmLijPiAiRweziqMOY3jqywF7bAfkfBvei2nSftjsskIgYklrgce7g2IPejjqcuwmkncegiaqKAUi9(gc05Mu2cFpcgsGOSsGYWkFNabLUGNR055c)kFFoX)l6l1Nt3uZj0nVNPAoNuwUUwZPcYfZjnl9524oc7jqMOY3jqHFLVtkIgYkprgcKjQ8DceOIBzXDkce7g2IPejjfrdz3KidbYev(obczPIBu2Oei2nSftjsskIgYUHeziqSBylMsKKajqzXO0iq4AomqaGi1Cr69neOZnPSf(EemCoCMdgZHR5eFWSBEf9SxVAagpxGaZHbcaePSv6QgfKJiUZsxnNeZbBZTlbYev(obcB9pLIsFlJifrdzHjrgce7g2IPejjqcuwmkncKq3q9SAojGpN8ZHZCWyoXhm7MxXTbHsZNlqG5WabaIuZfP33qGo3KYw47rWW52LazIkFNaHT(N2W(CrkIgYUtImeitu57eiKLkUrzJsGy3WwmLijPiAilSrKHaXUHTykrscKaLfJsJabK96vdXDw6Q5WBUnjqMOY3jqu2k9MQq5wMuenKDdiYqGy3WwmLijbYev(obsyRvZev(EBLQIaTsv1CRJjqIpy2nVuKIOHSWAeziqSBylMsKKazIkFNajS1QzIkFVTsvrGwPQAU1Xeivzo1qusrkcuiIfFhMveziAilrgce7g2IPejjqMOY3jqgSUs3qMQb8E1EGw4lLreikReOmSY3jqY5YblalMohgd8iEoX3Hz1CyCF6Q4CYTqWHLAo)DyNUH6aaxZzIkFxn37RGIei36ycKbRR0nKPAaVxThOf(szePiAiprgce7g2IPejjqMOY3jqIGeRVqVNIg2YufbIbayr1CRJjqIGeRVqVNIg2YufPiASjrgcKjQ8DceWIv6cKbuei2nSftjssksrG6Yk7TkFNidrdzjYqGy3WwmLijbsGYIrPrG0zBv6XqrnhEZbtTMlqG5GXC4AUE0dgohoZPZ2Q0JHIAo8MBN7CUDjqMOY3jqbBDHjkfnS1)usr0qEImei2nSftjssGmrLVtGOSv6nvHYTmbIYkbkdR8DcKCPl(U07NJADwpphILtaMiUJ9AUunN8WuoBUhyUotoMtNTvPpN6xVMZbtTKZM7bMRZKJ50zBv6ZL(C2C9OhmmsGeOSyuAeO0fFx69nQ1z9CBt1CsaFoD2wLEuaIqSxKIOXMeziqSBylMsKKazIkFNarzR0BQcLBzceLvcugw57eOn(UCTMBX1CMphlhPQsVFojx)tNdsp5fDok6dJeibklgLgbszbZnS1)0Msp5fDoCMlDX3LEFJADwp3GPAojMtR5WzomqaGi26FAtPN8IgbdNdN5WabaIyR)PnLEYlAeXDw6Q5WBozJWCoCpxVGskIgBirgce7g2IPejjqcuwmkncuz(207NdN5WabaIiqNBLfgPVuFoCMlDX3LEFJADwp32unNeZPZ2Q0JDMCmhUNtROSeitu57eieOZTYcjfrdysKHaXUHTykrscKaLfJsJaPZ2Q0JHIAo8MdMAnhSBoymN8AnhUNddeaiIT(N2u6jVOrWW52LazIkFNaLcg7bDAd4rvwGuMuen2jrgce7g2IPejjqcuwmkncKoBRspgkQ5WBoydMZHZCHCf71FWveXDw6Q5WBoysGmrLVtGuMaLaPiTvl0efPifbsvMtneLidrdzjYqGy3WwmLijbsGYIrPrGqGEkAHVugfPmqkYAo8GpNSAnhoZbJ5W1CLTyVIyVZQ6rDr2nSftNlqG5W1CI)x0xQhXENv1J6Ii2ObnxGaZHbcaePMlsVVHaDUjLTW3JGHZTlbYev(obIYwP3ufk3YKIOH8eziqSBylMsKKajqzXO0iqHCf71FWveXDw6Q5WBUEbDoCpN8eitu57eiLjqjqksB1cnrrkIgBsKHaXUHTykrscKjQ8Dce26FARSqceLvcugw57eiyvu8CyR)PZvw4C1pxiIdM9AUpygjSWW07NtOBOEwnxcmNuEoDlyEovOj45aE0C2CiqNNZC6C2CYj3HBCU6NtfAiEU6Ndde5ZLfbsGYIrPrGqGophEWNt(5WzoeOZXk74w9TnCojMRxqNdN5e6gQNvnaKjQ8DBnNeWNt24gqkIgBirgce7g2IPejjqcuwmknceUMRSf7veB9pLIsFlJISBylMoxGaZHR5e)VOVupIT(NsrPVLrreB0GiqMOY3jquZfP33qGo3KYw47KIObmjYqGy3WwmLijbsGYIrPrGWabaIyVZnLEYlAuvMy7CsaFoyBoCMdb68CsaFo5jqMOY3jq13HPQ3zsr0yNeziqSBylMsKKajqzXO0iqWyoCnN4dMDZROZc0VEeDUabMddeaiAyFx6wLV3wzhwemCUDNdN5GXCyGaarS35Msp5fnI4olD1C4bFoeOZXk74w9TnNlqG5WabaIyVZnLEYlAeXDw6Q5Wd(CWyUEbDo8Nt8)I(s9i26FkfL(wgfrSrdAoCpxzl2Ri26FkfL(wgfz3WwmDoCpN8ZT7Cbcmhgiaqe7DUP0tErJQYeBNdV52CUDNdN5qGEkAHVugfPmqkYAojGpN8ArGmrLVtG6me6LIyNskIgWgrgce7g2IPejjqMOY3jqDgc9srStjquwjqzyLVtGmrLVRIQYCQHO4dxBkBLEtvOClRzcahb6POf(szuKYaPil8GdBArGeOSyuAeimqaGi27CtPN8IgvLj2ohEZTZ5WzoeONIw4lLrrkdKISMtc4ZjlmNdN5GXC4AoXhm7Mxrp71RgGXZfiWCyGaarkBLUQrb5iI7S0vZjXCWCUDjfrJnGidbIDdBXuIKeibklgLgbcxZv2I9kIT(NsrPVLrr2nSftNdN5OSv6nZPnklSGIiUZsxnhEZbZ5WzoeONIw4lLrrkdKISMdp4ZbJ5KfMZH)CyGaarQ5I07BiqNBszl89iy4C4Eoyoh(ZPc51QvgQNlvuNnu1ufk3YZH75kBXEf1zdvyi22YOi7g2IPZH75KFUDjqMOY3jq6SHQMQq5wMuenG1iYqGy3WwmLijbsGYIrPrGe6gQNvnaKjQ8DBnNeWNt24gmhoZbJ5WabaI6C3RktLQOQmX25Wd(CWyoyohSBoviVwTYq9CPIyR)PnSpxZT7CbcmNkKxRwzOEUurS1)0g2NR5Kyo5NBxcKjQ8Dce26FAd7ZfPiAiRweziqSBylMsKKazIkFNa1zOTThOHT(NsGOSsGYWkFNajxyOTZ9aZj56F6C0NvZ5FnxO5uUlfWowok2PrcKaLfJsJarzmqaGyNH22EGg26FAK(s95WzoGSxVAiUZsxnNeZbBryskIgYklrgce7g2IPejjqcuwmkncemMddeaikqzN69Ms8GOEocgohoZv2I9kI4vQ0BP3Ww)tJSBylMo3UZHZCiqpfTWxkJIugifznNeZjRweitu57eikBLEZCAJYclisr0qw5jYqGy3WwmLijbsGYIrPrGqGEkAHVugnNeWNtwT0AoCMdxZHbcaePMlsVVHaDUjLTW3JGHeitu57eiS3zv9Oosr0q2njYqGy3WwmLijbsGYIrPrGqGEkAHVugfPmqkYAo8GphmMtwyoh(ZHbcaePMlsVVHaDUjLTW3JGHZH75G5C4pNkKxRwzOEUurD2qvtvOClphUNRSf7vuNnuHHyBlJISBylMohUNt(52DUabMdi71RgI7S0vZH3CYQfbYev(obIYwP3ufk3YKIOHSBirgce7g2IPejjqcuwmkncKkKxRwzOEUurkBLEZCAJYclO5Ka(CBsGmrLVtGOSv6nZPnklSGifrdzHjrgce7g2IPejjqcuwmkncegiaqKAUi9(gc05Mu2cFpcgoxGaZHaDowzh3QVTHZH3C9ckbYev(obsNnu1ufk3YKIOHS7KidbIDdBXuIKeibklgLgbcdeaisnxKEFdb6CtkBHVhbdjqMOY3jqyR)PnSpxKIOHSWgrgce7g2IPejjqcuwmkncec05yLDCR(2MZjXC9ckbYev(obcB9pTvwiPiAi7gqKHaXUHTykrscKaLfJsJaHbcaefOSt9EtjEquphbdNlqG5kBXEfrwysBuw8DHVkR89i7g2IPZfiWCQqETALH65sfPSv6nZPnklSGMtc4ZjpbYev(obIYwP3mN2OSWcIuenKfwJidbIDdBXuIKeibklgLgbcdeaiI9o3u6jVOre3zPRMtI52CoCpxVGsGmrLVtGeVRa7cR8Dsr0qETiYqGy3WwmLijbsGYIrPrGe6gQNvnaKjQ8DBnNeWNt2OSZHZCyGaarS35Msp5fnI4olD1Csm3MZH756fucKjQ8Dce26FAd7ZfPiAiVSeziqSBylMsKKajqzXO0iqiqNNtI5KDoCMdgZHaDowzh3QVT5C4nxVGoxGaZHbcaeXENBk9Kx0OQmX25KyoyBoCMddeaiI9o3u6jVOre3zPRMtI5qGohRSJB132Co8NRxqNBxcKjQ8DcKoBOQPkuULjfrd5LNidbIDdBXuIKeibklgLgbcb6POf(szuKYaPiR5Kyo51IazIkFNaziH5CREeI9IuKIaj(Gz38srKHOHSeziqSBylMsKKazIkFNarzR0BQcLBzceLvcugw57eijbr(C7iSYCjWCs550TG55QSJNdJlPm7ZTXnohIbqSsNveibklgLgbs8bZU5v0ZE9Qby8C4mhgiaqKYwPRAuqoI4olD1Csm3oNdN5qGEkAHVugnNeZbBArkIgYtKHaXUHTykrscKjQ8DcKoBOQPkuULjquwjqzyLVtGKlST8CkqepNuEoNdMrZTEfpxPB1CyGaaeibklgLgbs8bZU5v0ZE9Qby8C4mhLTsVzoTrzHfuSsX207NdN5GXCWyomqaGiLTsx1OGCemCUabMddeaisnxKEFdb6CtkBHVhbdNB35WzomqaGiLTsx1OGCeXDw6Q5WBUDo3UKIOXMeziqSBylMsKKazIkFNarzR0vnkitGOSsGYWkFNaj3oDUs3Q5KYZzlPwqQ5eMQMBJBCotnNE2Rpxik)5KQZ(Cs55mrbARvqZ5mtNllcKaLfJsJaHR5WabaIu2kDvJcYrWW5ceyomqaGiLTsx1OGCeXDw6Q5WBUnCUabMddeaikqzN69Ms8GOEocgskIgBirgce7g2IPejjqMOY3jqktGsGuK2QfAIIarzLaLHv(obsURI7cR5QFoLjqjqk45kDEUE9hCnxcmNuEUqettrzyRGMtAUwZ5Fnh9NRduOpx6Zv68CoBO5aalqetGeOSyuAeiymhUMt8bZU5v0ZE9Qby8CbcmhgiaqKYwPRAuqoI4olD1Csm3oNB35WzoCnhgiaqKAUi9(gc05Mu2cFpcgohoZbJ5c5k2R)GRiI7S0vZH3CYQ1CbcmxzOEUIv2XT6B0KNdV56f052LuenGjrgce7g2IPejjqMOY3jqu2k9MQq5wMarzLaLHv(obssqKp3ocRm3dam3oauvZHXapINtj1qDP3pN47y1CyMy7CpaWC7WnsGeOSyuAeiXhm7MxXGzV0dcnhoZHa9u0cFPmAojMd20AoCMt8)I(s9OsQH6sVV1LQkI4olD1C4n3MKIOXojYqGy3WwmLijbYev(obsj1qDP336svrGOSsGYWkFNaj3oDoLud1LE)CMAU179ZzQ5KYYvepN)1C4n3MQ5EaG524oc7jqcuwmknceUMddeaisnxKEFdb6CtkBHVhbdjfrdyJidbIDdBXuIKeitu57eOodHEPi2PeikReOmSY3jqWkig2j3YPZ1zi0lDU3NleCTMl95EeLrZv)C9GgY8I55ELc0qbnhfeLE)CLophqIu1CBChH9eibklgLgbs8bZU5v0zb6xpIohoZHbcaeXENBk9Kx0OQmX25Wd(CArkIgBargce7g2IPejjqMOY3jqg23LUv57Tv2HrGOSsGYWkFNaj3oDoP8CctvZj3YPeibklgLgbcxZHbcaePMlsVVHaDUjLTW3JGHKIObSgrgce7g2IPejjqMOY3jqkDtSDXTsNBGU0hv6brGOSsGYWkFNab7552bGQAo67Y1AoHPQ5k9unhfeLE)CBChH9eibklgLgbs8)I(s9i1Cr69neOZnPSf(EeXDw6Q5WBUnNlqG5W1CyGaarQ5I07BiqNBszl89iyiPifPiqbZiv(ord51sETKvET2jbsQH807vei5YUWhvmDoyoNjQ895wPQuXzpbYal9hrGGYUD4C4phSQ82CLeOq0dKlMablZj56F6CBKTsFoy1E2RxZEyzU9GopN8BGMZjVwYR1SF2dlZjNlhSaSy6CymWJ45eFhMvZHX9PRIZj3cbhwQ583HD6gQdaCnNjQ8D1CVVcko7nrLVRIHiw8DywbhuXTS4onDRJHBW6kDdzQgW7v7bAHVugn7nrLVRIHiw8DywHpCTbvCllUttgaGfvZTogUiiX6l07POHTmvn7nrLVRIHiw8DywHpCTbwSsxGmGA2p7HL5KZLdwawmDooygf0Cv2XZv68CMOE0CPAolylxg2IJZEtu57k4DPtBaiMH15zVjQ8Df(W1UZqOxkIDQMjaCmqaGi27CtPN8IgrCNLUcVnXDVGgz5GfGfhiamWabaIyVZnLEYlAeXDw6k8GJaDowzh3QVTzGayGaarS35Msp5fnI4olDfEWHrVGIV4)f9L6rS1)ukk9TmkIyJgeUlBXEfXw)tPO03YOi7g2IP4w(DdeadeaiI9o3u6jVOrvzIT4T5U4Ga9u0cFPmkszGuKLeWLxRzVjQ8Df(W1wyRvZev(EBLQst36y4DzL9wLVRzcaVmFB69bcKU47sVVrToRNBWujHwZEtu57k8HRn26FAdaefKMjaCX)l6l1JuZfP33qGo3KYw47reB0GWbg4s8)I(s9i26FkfL(wgfrSrdkqaCv2I9kIT(NsrPVLrr2nSft3D2BIkFxHpCTXyKIrBtVF2BIkFxHpCTnKWCUfcUuSMjaCtuzWCJDUlzLeWLpqaeOZ4jloiqpfTWxkJIugifzjXo1A2BIkFxHpCTxzVEPA7aqAFh7LMjaCmqaGiOR)RGAQcXEFPhbdN9MOY3v4dxBZfSQq2QjS1A2BIkFxHpCTbseJT(No7nrLVRWhU2ywF7bAfkfBvZEyzoO0f8CLopx4x57Zj(FrFP(C6MAoHU59mvZ5KYY11AovqUyoPzPp3g3ry)S3ev(UcF4Ah(v(UMjaCmqaGi1Cr69neOZnPSf(EemC2BIkFxHpCTbvCllUtn7nrLVRWhU2ilvCJYgD2BIkFxHpCTXw)tPO03Yinta44cdeaisnxKEFdb6CtkBHVhbdXbg4s8bZU5v0ZE9QbyCGayGaarkBLUQrb5iI7S0vsaB7o7nrLVRWhU2yR)PnSpxAMaWf6gQNvsaxECGH4dMDZR42GqP5bcGbcaePMlsVVHaDUjLTW3JGH7o7nrLVRWhU2ilvCJYgD2BIkFxHpCTPSv6nvHYTSMjaCGSxVAiUZsxH3MZEtu57k8HRTWwRMjQ892kvLMU1XWfFWSBEPM9MOY3v4dxBHTwntu57TvQknDRJHRkZPgIo7N9WYCscI852ryL5sG5KYZPBbZZvzhphgxsz2NBJBCoedGyLoRM9MOY3vrXhm7Mxk4u2k9MQq5wwZeaU4dMDZRON96vdWyCWabaIu2kDvJcYre3zPRKyN4Ga9u0cFPmscytRzpSmNCHTLNtbI45KYZ5CWmAU1R45kDRMddeay2BIkFxffFWSBEPWhU26SHQMQq5wwZeaU4dMDZRON96vdWyCOSv6nZPnklSGIvk2MEpoWagyGaarkBLUQrb5iyyGayGaarQ5I07BiqNBszl89iy4U4GbcaePSv6QgfKJiUZsxH3o3D2dlZj3oDUs3Q5KYZzlPwqQ5eMQMBJBCotnNE2Rpxik)5KQZ(Cs55mrbARvqZ5mtNlRzVjQ8Dvu8bZU5LcF4AtzR0vnkiRzcahxyGaarkBLUQrb5iyyGayGaarkBLUQrb5iI7S0v4THbcGbcaefOSt9EtjEquphbdN9WYCYDvCxynx9ZPmbkbsbpxPZZ1R)GR5sG5KYZfIyAkkdBf0CsZ1Ao)R5O)CDGc95sFUsNNZzdnhaybI4zVjQ8Dvu8bZU5LcF4ARmbkbsrARwOjknta4WaxIpy2nVIE2RxnaJdeadeaiszR0vnkihrCNLUsIDUlo4cdeaisnxKEFdb6CtkBHVhbdXbgHCf71FWveXDw6k8KvRabkd1ZvSYoUvFJMmE9c6UZEyzojbr(C7iSYCpaWC7aqvnhgd8iEoLud1LE)CIVJvZHzITZ9aaZTd34S3ev(Ukk(Gz38sHpCTPSv6nvHYTSMjaCXhm7MxXGzV0dcHdc0trl8LYijGnTWr8)I(s9OsQH6sVV1LQkI4olDfEBo7HL5KBNoNsQH6sVFotn369(5m1Csz5kINZ)Ao8MBt1CpaWCBChH9ZEtu57QO4dMDZlf(W1wj1qDP336svPzcahxyGaarQ5I07BiqNBszl89iy4ShwMdwbXWo5woDUodHEPZ9(CHGR1CPp3JOmAU6NRh0qMxmp3RuGgkO5OGO07NR055asKQMBJ7iSF2BIkFxffFWSBEPWhU2Dgc9srSt1mbGl(Gz38k6Sa9RhrXbdeaiI9o3u6jVOrvzIT4bxRzpSmNC705KYZjmvnNClNo7nrLVRIIpy2nVu4dxBd77s3Q892k7W0mbGJlmqaGi1Cr69neOZnPSf(EemC2dlZb7552bGQAo67Y1AoHPQ5k9unhfeLE)CBChH9ZEtu57QO4dMDZlf(W1wPBITlUv6Cd0L(Ospinta4I)x0xQhPMlsVVHaDUjLTW3JiUZsxH3MbcGlmqaGi1Cr69neOZnPSf(EemC2p7nrLVRIDzL9wLVdpyRlmrPOHT(NQzcaxNTvPhdffEWuRabGbU6rpyio6STk9yOOWBN7C3zpSmNCPl(U07NJADwpphILtaMiUJ9AUunN8WuoBUhyUotoMtNTvPpN6xVMZbtTKZM7bMRZKJ50zBv6ZL(C2C9Ohmmo7nrLVRIDzL9wLVJpCTPSv6nvHYTSMja80fFx69nQ1z9CBtLeW1zBv6rbicXEn7HL5247Y1AUfxZz(CSCKQk9(5KC9pDoi9Kx05OOpmo7nrLVRIDzL9wLVJpCTPSv6nvHYTSMjaCLfm3Ww)tBk9KxuCsx8DP33OwN1ZnyQKqlCWabaIyR)PnLEYlAemehmqaGi26FAtPN8IgrCNLUcpzJWe39c6S3ev(Uk2Lv2Bv(o(W1gb6CRSqnta4L5BtVhhmqaGic05wzHr6l1XjDX3LEFJADwp32ujHoBRsp2zYbU1kk7S3ev(Uk2Lv2Bv(o(W1ofm2d60gWJQSaPSMjaCD2wLEmuu4btTGDWqETWngiaqeB9pTP0tErJGH7o7nrLVRIDzL9wLVJpCTvMaLaPiTvl0eLMjaCD2wLEmuu4bBWeNqUI96p4kI4olDfEWC2p7nrLVRIQYCQHOWPSv6nvHYTSMjaCeONIw4lLrrkdKISWdUSAHdmWvzl2Ri27SQEuxKDdBX0abWL4)f9L6rS3zv9OUiInAqbcGbcaePMlsVVHaDUjLTW3JGH7o7nrLVRIQYCQHO4dxBLjqjqksB1cnrPzcapKRyV(dUIiUZsxHxVGIB5N9ZEyzotu57QOQmNAik(W1gB9pLIsFlJ0mbGJlmqaGi1Cr69neOZnPSf(EemC2dlZTrWWvkSIPZPZiEomwyGkEUsNNRlRS3Q895wPQMdXRKvZ9(CL5BtVx7Y2ME)CuRZ654ShwMZev(UkQkZPgIIpCT7me6LIyNQzcahdeaiI9o3u6jVOre3zPRWBtC3lOrwoybyXbcadmqaGi27CtPN8IgrCNLUcp4iqNJv2XT6BBgiagiaqe7DUP0tErJiUZsxHhCy0lO4l(FrFPEeB9pLIsFlJIi2ObH7YwSxrS1)ukk9TmkYUHTykULF3abWabaIyVZnLEYlAuvMylEBUloiqpfTWxkJIugifzjbC51A2p7HL5GvrXZHT(NoxzHZv)CHioy2R5(GzKWcdtVFoHUH6z1CjWCs550TG55uHMGNd4rZzZHaDEoZPZzZjNChUX5QFovOH45QFomqKpxwZEtu57QOQmNAikCS1)0wzHAMaWrGoJhC5Xbb6CSYoUvFBdLOxqXrOBOEw1aqMOY3TLeWLnUbZEtu57QOQmNAik(W1MAUi9(gc05Mu2cFxZeaoUkBXEfXw)tPO03YOi7g2IPbcGlX)l6l1JyR)Puu6BzueXgnOzVjQ8DvuvMtnefF4AxFhMQEN1mbGJbcaeXENBk9Kx0OQmXwjGdB4GaDwc4Yp7nrLVRIQYCQHO4dx7odHEPi2PAMaWHbUeFWSBEfDwG(1JObcGbcaenSVlDRY3BRSdlcgUloWadeaiI9o3u6jVOre3zPRWdoc05yLDCR(2MbcGbcaeXENBk9Kx0iI7S0v4bhg9ck(I)x0xQhXw)tPO03YOiInAq4USf7veB9pLIsFlJISBylMIB53nqamqaGi27CtPN8IgvLj2I3M7Idc0trl8LYOiLbsrwsaxETM9WYCMOY3vrvzo1qu8HRnLTsVPkuUL1mbGJa9u0cFPmkszGuKfEWHnTM9MOY3vrvzo1qu8HRDNHqVue7unta4yGaarS35Msp5fnQktSfVDIdc0trl8LYOiLbsrwsaxwyIdmWL4dMDZRON96vdW4abWabaIu2kDvJcYre3zPRKaM7o7nrLVRIQYCQHO4dxBD2qvtvOClRzcahxLTyVIyR)Puu6BzuKDdBXuCOSv6nZPnklSGIiUZsxHhmXbb6POf(szuKYaPil8GddzHj(yGaarQ5I07BiqNBszl89iyiUHj(QqETALH65sf1zdvnvHYTmUlBXEf1zdvyi22YOi7g2IP4w(DN9MOY3vrvzo1qu8HRn26FAd7ZLMjaCHUH6zvdazIkF3wsax24gGdmWabaI6C3RktLQOQmXw8Gddyc7uH8A1kd1ZLkIT(N2W(CTBGaQqETALH65sfXw)tByFUKq(DN9WYCYfgA7CpWCsU(Noh9z1C(xZfAoL7sbSJLJIDAC2BIkFxfvL5udrXhU2DgAB7bAyR)PAMaWPmgiaqSZqBBpqdB9pnsFPooazVE1qCNLUscylcZzVjQ8DvuvMtnefF4AtzR0BMtBuwybPzcahgyGaarbk7uV3uIhe1ZrWqCkBXEfr8kv6T0ByR)Pr2nSft3fheONIw4lLrrkdKISKqwTM9MOY3vrvzo1qu8HRn27SQEuNMjaCeONIw4lLrsaxwT0chCHbcaePMlsVVHaDUjLTW3JGHZEtu57QOQmNAik(W1MYwP3ufk3YAMaWrGEkAHVugfPmqkYcp4WqwyIpgiaqKAUi9(gc05Mu2cFpcgIByIVkKxRwzOEUurD2qvtvOClJ7YwSxrD2qfgITTmkYUHTykULF3abaYE9QH4olDfEYQ1S3ev(UkQkZPgIIpCTPSv6nZPnklSG0mbGRc51QvgQNlvKYwP3mN2OSWcsc4Bo7nrLVRIQYCQHO4dxBD2qvtvOClRzcahdeaisnxKEFdb6CtkBHVhbddeab6CSYoUvFBdXRxqN9MOY3vrvzo1qu8HRn26FAd7ZLMjaCmqaGi1Cr69neOZnPSf(EemC2BIkFxfvL5udrXhU2yR)PTYc1mbGJaDowzh3QVTPe9c6S3ev(UkQkZPgIIpCTPSv6nZPnklSG0mbGJbcaefOSt9EtjEquphbddeOSf7vezHjTrzX3f(QSY3JSBylMgiGkKxRwzOEUurkBLEZCAJYclijGl)S3ev(UkQkZPgIIpCTfVRa7cR8Dnta4yGaarS35Msp5fnI4olDLeBI7EbD2BIkFxfvL5udrXhU2yR)PnSpxAMaWf6gQNvnaKjQ8DBjbCzJYIdgiaqe7DUP0tErJiUZsxjXM4UxqN9MOY3vrvzo1qu8HRToBOQPkuUL1mbGJaDwczXbgiqNJv2XT6BBIxVGgiagiaqe7DUP0tErJQYeBLa2WbdeaiI9o3u6jVOre3zPRKab6CSYoUvFBt87f0DN9MOY3vrvzo1qu8HRTHeMZT6ri2lnta4iqpfTWxkJIugifzjH8Arksria]] )

end