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


    spec:RegisterPack( "Blood", 20210629, [[d4uM9aqiOs9iquUerOQnbv8jbsgLsvoLsvTkIGxbvzwKkUfujzxc9lsvnmsLogr0Yiv5zGGPPOuDnqKTbc5BqLyCqLuNdevwhrOK5bv19aP9rK6GcewirYdfiQjQOKlsek(iiuYibHs1jbrvTsLkVKiuPzQOuCtbIyNev9tqOugkiuSubs9uqnvIkxLiuXxbHQXsek1Er8xfgSkhMYIHYJjmzKUmQnd4ZkLrtkNwYQvuk9AfvZwj3wr2nv)wvdxqhxGiTCipNKPl66aTDffFNOmEIqoVa16brvMVa2VutKKihbMAjtKxpD1tsDHi9GCrjLecqoDHebodoKjWHMyUTXey3MycSuR)Pe4ql41BuICey1dIembgUMaxwwVhKrgqsGXaRvc57emcm1sMiVE6QNK6cr6b5IskjeGC6kjbwfYcI86bjDjWAfLYobJatzLGal16FAFZITuRpjUETPL9UDGo3NEqoD6tpD1txc8QuPIihbMYag4kjYrKxsICey2nSftjsrGPSsGQWSENalXirSamzAF8mmk4(YAI7l14(mr(O(kvF2mwTmSfhjWMiR3jWtLthaiMH8yssKxpICey2nSftjsrGfOkzuzeymqaGi278qPv8Igr8KvUQp87dc9jH(2e0ilrSam5(ceOV96ddeaiI9opuAfVOrepzLR6dFO9HaDoM1epYFaH(ceOpmqaGi278qPv8Igr8KvUQp8H23E9TjO9HxFI)x0xMhXw)tPOYNZOiInAW9jH(sBXEgXw)tPOYNZOi7g2IP9jH(0RV97lqG(WabaIyVZdLwXlAuLMyEF43he6B)(WPpeOxIr4lJrrkduIk7tAO9PNUeytK17e4jdHEzi2PKKipeiYrGz3WwmLifbwGQKrLrGtZNx(wFbc0x5IFQ8Tb1MSnEajvFs3NUeytK17eyHTwdtK17JvPsc8Qu5WTjMapvzTzz9ojjYp7e5iWSBylMsKIalqvYOYiWI)x0xMhPMlkFBGaDEiJTW3Ji2Ob3ho9TxF4UpX)l6lZJyR)Puu5ZzueXgn4(ceOpC3xAl2Zi26Fkfv(Cgfz3WwmTV9jWMiR3jWyR)PdaquWKKipKiYrGnrwVtGXyKIrZlFJaZUHTykrkssKhIiYrGz3WwmLifbwGQKrLrGnrwZWd25PIv9jn0(0RVab6db6CF43NK9HtFiqVeJWxgJIugOev2N09br6sGnrwVtGnKWCEecUumjjYJle5iWSBylMsKIalqvYOYiWyGaarqx7xbpujI9TulcgsGnrwVtGx1MwQgZwq62e7jjjYJRjYrGnrwVtGnxWQezRHWwlcm7g2IPePijrEihrocSjY6DcmqHyS1)ucm7g2IPePijrEj1Lihb2ez9obgZ2gpWirLyUIaZUHTykrkssKxsjjYrGz3WwmLifbwGQKrLrGXabaIuZfLVnqGopKXw47rWqcmLvcufM17ey4YfCFPg3x4N179j(FrFzEFAMQpHM5BmvN(KXb1A1Nkyx0NSk16BwbneNaBISENah(z9ojjYlPEe5iWMiR3jWGkEujpPiWSBylMsKIKe5Lece5iWMiR3jWiRu8GYgLaZUHTykrkssKxYzNihbMDdBXuIueybQsgvgbg39HbcaePMlkFBGaDEiJTW3JGH9HtF71hU7t8ZWU5z0RnTCayCFbc0hgiaqKYwQPguqoI4jRCvFs3hU03(eytK17eyS1)ukQ85mIKe5Lese5iWSBylMsKIalqvYOYiWcndTXQ(KgAF61ho9TxFIFg2npJZdgvM3xGa9HbcaePMlkFBGaDEiJTW3JGH9Tpb2ez9obgB9pDG91IKe5LeIiYrGnrwVtGrwP4bLnkbMDdBXuIuKKiVK4crocm7g2IPePiWcuLmQmcmqTPLdepzLR6d)(Gab2ez9obMYwQnujQMZKKiVK4AICey2nSftjsrGnrwVtGf2AnmrwVpwLkjWRsLd3MycS4NHDZtfjjYljKJihbMDdBXuIueytK17eyHTwdtK17JvPsc8Qu5WTjMaRsZPgIssssGdrS4NWSKihrEjjYrGz3WwmLifb2ez9ob2G8uAgYudG3ZXdmcFzmIatzLavHz9obwIrIybyY0(WyGhX9j(jml7dJ3kxf7liecomv95VJR0m0ea4QptK17Q(EFfCKa72etGnipLMHm1a49C8aJWxgJijrE9iYrGz3WwmLifb2ez9obweSy9j69smWwMkjWmaalYHBtmbweSy9j69smWwMkjjrEiqKJaBISENadSyLMazajbMDdBXuIuKKKe4PkRnlR3jYrKxsICey2nSftjsrGfOkzuzeyn2wPwmuK9HFFqs3(ceOV96d39THEWW(WPpn2wPwmuK9HFFqee13(eytK17e4zSPWcvIb26FkjjYRhrocm7g2IPePiWMiR3jWu2sTHkr1CMatzLavHz9obgY3f)u5B9rTjBJ7dXbPGfINyp7Ru9PhKK477b6BYKO(0yBLA9P(1RtFqsxj((EG(MmjQpn2wPwFL3N13g6bdJeybQsgvgbUCXpv(2GAt2gpGGQpPH2NgBRulkari2tssKhce5iWSBylMsKIaBISENatzl1gQevZzcmLvcufM17e4z9EqL9T4SpZ7JLOsLLV1NuR)P9bRv8I2hf9HrcSavjJkJaRSz4b26F6qPv8I2ho9vU4NkFBqTjBJhqs1N09PBF40hgiaqeB9pDO0kErJGH9HtFyGaarS1)0HsR4fnI4jRCvF43NKri1Ne6Btqjjr(zNihbMDdBXuIueybQsgvgbonFE5B9HtFyGaareOZJ0cJ0xM3ho9vU4NkFBqTjBJhqq1N09PX2k1ItMe1Ne6t3OKeytK17eyeOZJ0cjjrEirKJaZUHTykrkcSavjJkJaRX2k1IHISp87ds62hUQV96tpD7tc9HbcaeXw)thkTIx0iyyF7tGnrwVtGlbJ9GoDa8OSsqktsI8qerocm7g2IPePiWcuLmQmcSgBRulgkY(WVpCbs9HtFHCg30EWveXtw5Q(WVpirGnrwVtGvMavaLOS1i0ejjjjbw8ZWU5PIihrEjjYrGz3WwmLifb2ez9obMYwQnujQMZeykReOkmR3jWsbI8(cAiM(kG(KX9PzZW9L1e3hgNYy27BwZQpedGyLgRiWcuLmQmcS4NHDZZOxBA5aW4(WPpmqaGiLTutnOGCeXtw5Q(KUpiQpC6db6Lye(YyuFs3hUOljjYRhrocm7g2IPePiWMiR3jWASHYHkr1CMatzLavHz9oboiXMZ9ParCFY4(CEgg136vCFPML9HbcaqGfOkzuzeyXpd7MNrV20YbGX9HtFu2sTH50bLfwWXSeZlFRpC6BV(2RpmqaGiLTutnOGCemSVab6ddeaisnxu(2ab68qgBHVhbd7B)(WPpmqaGiLTutnOGCeXtw5Q(WVpiQV9jjrEiqKJaZUHTykrkcSjY6DcmLTutnOGmbMYkbQcZ6DcCq40(snl7tg3NTKzbR6tyQSVznR(mvFA1MwFHO67tMg79jJ7ZejOTwb3NZmTVkjWcuLmQmcmU7ddeaiszl1udkihbd7lqG(WabaIu2sn1GcYrepzLR6d)(M9(ceOpmqaGOavtQ3hkXdI24iyijjYp7e5iWSBylMsKIaBISENaRmbQakrzRrOjscmLvcufM17e4GitEkm7l)(uMavaLG7l14(20EWvFfqFY4(crmTePHTcUpz1A1N)zF0VVjqHwFL3xQX95SH6dambrmbwGQKrLrG3RpC3N4NHDZZOxBA5aW4(ceOpmqaGiLTutnOGCeXtw5Q(KUpiQV97dN(WDFyGaarQ5IY3giqNhYyl89iyyF403E9fYzCt7bxrepzLR6d)(Ku3(ceOV0qBCgZAIh5pOf3h(9TjO9TpjjYdjICey2nSftjsrGnrwVtGPSLAdvIQ5mbMYkbQcZ6DcSuGiVVGgIPVhaOVzlOk7dJbEe3NsMHMkFRpXpXQ(WmX8(EaG(cYZIalqvYOYiWIFg2npJZWEQfmQpC6db6Lye(YyuFs3hUOBF40N4)f9L5rLmdnv(2yQuzeXtw5Q(WVpiqsI8qerocm7g2IPePiWMiR3jWkzgAQ8TXuPscmLvcufM17e4GWP9PKzOPY36Zu9TEFRpt1NmoOqCF(N9HFFqq13da03ScAiobwGQKrLrGXDFyGaarQ5IY3giqNhYyl89iyijjYJle5iWSBylMsKIaBISENapzi0ldXoLatzLavHz9obgIbX4QGy203KHqVS(EVVqW1QVY77rug1x(9TbAiZtM77vkqdfCFuqu5B9LACFafsL9nRGgItGfOkzuzeyXpd7MNrNfOF9iAF40hgiaqe7DEO0kErJQ0eZ7dFO9PljjYJRjYrGz3WwmLifb2ez9ob2W(PYTSEFSQjmcmLvcufM17e4GWP9jJ7tyQSVGy2qGfOkzuzeyC3hgiaqKAUO8Tbc05Hm2cFpcgssI8qoICey2nSftjsrGnrwVtGvAMy(IhPgpaDzpk1cMatzLavHz9obgIZ9nBbvzF03dQSpHPY(sTs1hfev(wFZkOH4eybQsgvgbw8)I(Y8i1Cr5BdeOZdzSf(EeXtw5Q(WVpi0xGa9H7(WabaIuZfLVnqGopKXw47rWqssKxsDjYrGz3WwmLifbwGQKrLrGvp4cRCAmeuLGlEWiWWSEpYUHTykb2ez9obgyXknbYasssscSknNAikroI8ssKJaZUHTykrkcSavjJkJaJa9smcFzmkszGsuzF4dTpj1TpC6BV(WDFPTypJyVZQ8rtr2nSft7lqG(WDFI)x0xMhXENv5JMIi2Ob3xGa9HbcaePMlkFBGaDEiJTW3JGH9Tpb2ez9obMYwQnujQMZKKiVEe5iWSBylMsKIalqvYOYiWHCg30EWveXtw5Q(WVVnbTpj0NEeytK17eyLjqfqjkBncnrssI8qGihbMDdBXuIueytK17eyS1)0rAHeykReOkmR3jWsCuCFyR)P9LwyF53xiINH9SVFggjSWWY36tOzOnw1xb0NmUpnBgUpvOj4(aEuFwFiqN7ZCAFwFqScYZQV87tfAiUV87dde59vjbwGQKrLrGrGo3h(q7tV(WPpeOZXSM4r(JzVpP7Btq7dN(eAgAJvdaKjY6DB1N0q7tYiUMKe5NDICey2nSftjsrGfOkzuzeyC3xAl2Zi26Fkfv(Cgfz3WwmTVab6d39j(FrFzEeB9pLIkFoJIi2ObtGnrwVtGPMlkFBGaDEiJTW3jjrEirKJaZUHTykrkcSavjJkJaJbcaeXENhkTIx0OknX8(KgAF4sF40hc05(KgAF6rGnrwVtGZFctLVZKKiperKJaZUHTykrkcSavjJkJaVxF4UpXpd7MNrNfOF9iAFbc0hgiaq0W(PYTSEFSQjSiyyF73ho9TxFyGaarS35HsR4fnI4jRCvF4dTpeOZXSM4r(di0xGa9HbcaeXENhkTIx0iINSYv9Hp0(2RVnbTp86t8)I(Y8i26Fkfv(CgfrSrdUpj0xAl2Zi26Fkfv(Cgfz3WwmTpj0NE9TFFbc0hgiaqe7DEO0kErJQ0eZ7d)(GqF73ho9Ha9smcFzmkszGsuzFsdTp90LaBISENapzi0ldXoLKe5XfICey2nSftjsrGnrwVtGNme6LHyNsGPSsGQWSENaBISExfvP5udrXdQ(u2sTHkr1CwNcakc0lXi8LXOiLbkrL4dfx0LalqvYOYiWyGaarS35HsR4fnQstmVp87dI6dN(qGEjgHVmgfPmqjQSpPH2NKqQpC6BV(WDFIFg2npJETPLdaJ7lqG(WabaIu2sn1GcYrepzLR6t6(GuF7tsI84AICey2nSftjsrGfOkzuzeyC3xAl2Zi26Fkfv(Cgfz3WwmTpC6JYwQnmNoOSWcoI4jRCvF43hK6dN(qGEjgHVmgfPmqjQSp8H23E9jjK6dV(WabaIuZfLVnqGopKXw47rWW(KqFqQp86tfYR1in0gNQOgBOCOsunN7tc9L2I9mQXgkXqSnNrr2nSft7tc9PxF7tGnrwVtG1ydLdvIQ5mjjYd5iYrGz3WwmLifbwGQKrLrGfAgAJvdaKjY6DB1N0q7tYiUUpC6BV(WabaIA80RstvQOknX8(WhAF71hK6dx1NkKxRrAOnovrS1)0b2xR(2VVab6tfYR1in0gNQi26F6a7RvFs3NE9Tpb2ez9obgB9pDG91IKe5LuxICey2nSftjsrGnrwVtGNm08XdmWw)tjWuwjqvywVtGdsm08(EG(KA9pTp6ZQ(8p7l0CkpvcCflrj70ibwGQKrLrGPmgiaqCYqZhpWaB9pnsFzEF40hqTPLdepzLR6t6(WLiKijrEjLKihbMDdBXuIueybQsgvgbEV(WabaIcunPEFOepiAJJGH9HtFPTypJiEvkTr5dS1)0i7g2IP9TFF40hc0lXi8LXOiLbkrL9jDFsQlb2ez9obMYwQnmNoOSWcMKe5LupICey2nSftjsrGfOkzuzeyeOxIr4lJr9jn0(KuxD7dN(WDFyGaarQ5IY3giqNhYyl89iyib2ez9obg7DwLpAIKe5Lece5iWSBylMsKIalqvYOYiWiqVeJWxgJIugOev2h(q7BV(Kes9HxFyGaarQ5IY3giqNhYyl89iyyFsOpi1hE9Pc51AKgAJtvuJnuoujQMZ9jH(sBXEg1ydLyi2MZOi7g2IP9jH(0RV97lqG(aQnTCG4jRCvF43NK6sGnrwVtGPSLAdvIQ5mjjYl5StKJaZUHTykrkcSavjJkJaRc51AKgAJtvKYwQnmNoOSWcUpPH2heiWMiR3jWu2sTH50bLfwWKKiVKqIihbMDdBXuIueybQsgvgbgdeaisnxu(2ab68qgBHVhbd7lqG(qGohZAIh5pM9(WVVnbLaBISENaRXgkhQevZzssKxsiIihbMDdBXuIueybQsgvgbgdeaisnxu(2ab68qgBHVhbdjWMiR3jWyR)PdSVwKKiVK4crocm7g2IPePiWcuLmQmcmc05ywt8i)be6t6(2eucSjY6Dcm26F6iTqssKxsCnrocm7g2IPePiWcuLmQmcmgiaquGQj17dL4brBCemSVab6lTf7zezHfDqzXpf(QkR3JSBylM2xGa9Pc51AKgAJtvKYwQnmNoOSWcUpPH2NEeytK17eykBP2WC6GYclyssKxsihrocm7g2IPePiWcuLmQmcmgiaqe7DEO0kErJiEYkx1N09bH(KqFBckb2ez9obw8UcCkmR3jjrE90LihbMDdBXuIueybQsgvgbwOzOnwnaqMiR3TvFsdTpjJs2ho9HbcaeXENhkTIx0iINSYv9jDFqOpj03MGsGnrwVtGXw)thyFTijrE9KKihbMDdBXuIueybQsgvgbgb6CFs3NK9HtF71hc05ywt8i)be6d)(2e0(ceOpmqaGi278qPv8IgvPjM3N09Hl9HtFyGaarS35HsR4fnI4jRCvFs3hc05ywt8i)be6dV(2e0(2NaBISENaRXgkhQevZzssKxp9iYrGz3WwmLifbwGQKrLrGrGEjgHVmgfPmqjQSpP7tpDjWMiR3jWgsyopYhHypjjjjjbEggPQ3jYRNU6jPUqKE4AcSmd5LVPiWq8GiOLhYxEiwsS6Rp504(QPWhL9b8O(ckXpd7MNQGQpehKcwiM2N6N4(mW8NSKP9j0mFJvXE3SPCUpj1vIvFb53NHrjt7lOup4cRCAuIDq1x(9fuQhCHvonkXoYUHTyAq1NL9jXaX2SPV9KuI2p276Dq(tHpkzAFqQptK179TkvQI9ocCi6bQftGHS(KA9pTVzXwQ1NexV20YEhK13oqN7tpiNo9PNU6PBVR3bz9jXirSamzAFymWJ4(e)eML9HXBLRI9fecbhMQ(83XvAgAcaC1NjY6DvFVVco27mrwVRIHiw8tywcfuXJk5jDCBIHAqEkndzQbW754bgHVmg17mrwVRIHiw8tywIhu9bv8OsEshgaGf5WTjgQiyX6t07LyGTmv27mrwVRIHiw8tywIhu9bwSstGmGS317GS(KyKiwaMmTpEggfCFznX9LACFMiFuFLQpBgRwg2IJ9otK17kOtLthaiMH84ENjY6DfEq1FYqOxgIDQofaumqaGi278qPv8Igr8KvUcFiiHnbnYselatoqG9WabaIyVZdLwXlAeXtw5k8HIaDoM1epYFaHabWabaIyVZdLwXlAeXtw5k8HU3MGIN4)f9L5rS1)ukQ85mkIyJgSesBXEgXw)tPOYNZOi7g2IPsqV9deadeaiI9opuAfVOrvAI54dH9Xbb6Lye(YyuKYaLOsPHQNU9otK17k8GQVWwRHjY69XQuPoUnXqNQS2SSExNcaAA(8Y3ceOCXpv(2GAt2gpGKsAD7DMiR3v4bvFS1)0baikyDkaOI)x0xMhPMlkFBGaDEiJTW3Ji2ObJZE4w8)I(Y8i26Fkfv(CgfrSrdoqaCN2I9mIT(NsrLpNrr2nSft3V3zISExHhu9XyKIrZlFR3zISExHhu9nKWCEecUuSofautK1m8GDEQyL0q1lqaeOZ4ljoiqVeJWxgJIugOevknePBVZez9UcpO6VQnTunMTG0Tj2tDkaOyGaarqx7xbpujI9Tulcg27mrwVRWdQ(MlyvIS1qyRvVZez9UcpO6duigB9pT3zISExHhu9XSTXdmsujMR6DqwFWLl4(snUVWpR37t8)I(Y8(0mvFcnZ3yQo9jJdQ1QpvWUOpzvQ13ScAiEVZez9UcpO6h(z9UofaumqaGi1Cr5BdeOZdzSf(EemS3zISExHhu9bv8OsEs17mrwVRWdQ(iRu8GYgT3zISExHhu9Xw)tPOYNZiDkaO4gdeaisnxu(2ab68qgBHVhbdXzpCl(zy38m61MwoamoqamqaGiLTutnOGCeXtw5kPXL97DMiR3v4bvFS1)0b2xlDkaOcndTXkPHQho7j(zy38mopyuzEGayGaarQ5IY3giqNhYyl89iy4(9otK17k8GQpYkfpOSr7DMiR3v4bvFkBP2qLOAoRtbafO20YbINSYv4dHENjY6DfEq1xyR1Wez9(yvQuh3MyOIFg2npv9otK17k8GQVWwRHjY69XQuPoUnXqvP5udr7D9oiRpParEFbnetFfqFY4(0Sz4(YAI7dJtzm79nRz1hIbqSsJv9otK17QO4NHDZtfukBP2qLOAoRtbav8ZWU5z0RnTCaymoyGaarkBPMAqb5iINSYvsdr4Ga9smcFzmsACr3EhK1xqInN7tbI4(KX958mmQV1R4(snl7ddeaO3zISExff)mSBEQWdQ(ASHYHkr1CwNcaQ4NHDZZOxBA5aWyCOSLAdZPdklSGJzjMx(go7ThgiaqKYwQPguqocggiagiaqKAUO8Tbc05Hm2cFpcgUpoyGaarkBPMAqb5iINSYv4dr737GS(ccN2xQzzFY4(SLmlyvFctL9nRz1NP6tR206levFFY0yVpzCFMibT1k4(CMP9vzVZez9Ukk(zy38uHhu9PSLAQbfK1PaGIBmqaGiLTutnOGCemmqamqaGiLTutnOGCeXtw5k8N9abWabaIcunPEFOepiAJJGH9oiRVGitEkm7l)(uMavaLG7l14(20EWvFfqFY4(crmTePHTcUpz1A1N)zF0VVjqHwFL3xQX95SH6dambrCVZez9Ukk(zy38uHhu9vMavaLOS1i0ePofa09WT4NHDZZOxBA5aW4abWabaIu2sn1GcYrepzLRKgI2hhCJbcaePMlkFBGaDEiJTW3JGH4SxiNXnThCfr8KvUcFj1nqG0qBCgZAIh5pOfJ)MGUFVdY6tkqK3xqdX03da03SfuL9HXapI7tjZqtLV1N4NyvFyMyEFpaqFb5z17mrwVRIIFg2npv4bvFkBP2qLOAoRtbav8ZWU5zCg2tTGr4Ga9smcFzmsACrxCe)VOVmpQKzOPY3gtLkJiEYkxHpe6DqwFbHt7tjZqtLV1NP6B9(wFMQpzCqH4(8p7d)(GGQVhaOVzf0q8ENjY6Dvu8ZWU5PcpO6RKzOPY3gtLk1PaGIBmqaGi1Cr5BdeOZdzSf(EemS3bz9bXGyCvqmB6BYqOxwFV3xi4A1x599ikJ6l)(2anK5jZ99kfOHcUpkiQ8T(snUpGcPY(MvqdX7DMiR3vrXpd7MNk8GQ)KHqVme7uDkaOIFg2npJolq)6ruCWabaIyVZdLwXlAuLMyo(q1T3bz9feoTpzCFctL9feZMENjY6Dvu8ZWU5PcpO6By)u5wwVpw1eMofauCJbcaePMlkFBGaDEiJTW3JGH9oiRpio33SfuL9rFpOY(eMk7l1kvFuqu5B9nRGgI37mrwVRIIFg2npv4bvFLMjMV4rQXdqx2JsTG1PaGk(FrFzEKAUO8Tbc05Hm2cFpI4jRCf(qiqaCJbcaePMlkFBGaDEiJTW3JGH9otK17QO4NHDZtfEq1hyXknbYasDkaOQhCHvongcQsWfpyeyywV376DMiR3vXPkRnlR3HoJnfwOsmWw)t1PaGQX2k1IHIeFiPBGa7H7n0dgIJgBRulgks8HiiA)EhK1hKVl(PY36JAt2g3hIdsblepXE2xP6tpijX33d03Kjr9PX2k16t9RxN(GKUs899a9nzsuFASTsT(kVpRVn0dgg7DMiR3vXPkRnlR3XdQ(u2sTHkr1CwNcaA5IFQ8Tb1MSnEabL0q1yBLArbicXE27GS(M17bv23IZ(mVpwIkvw(wFsT(N2hSwXlAFu0hg7DMiR3vXPkRnlR3XdQ(u2sTHkr1CwNcaQYMHhyR)PdLwXlkoLl(PY3guBY24bKusRloyGaarS1)0HsR4fncgIdgiaqeB9pDO0kErJiEYkxHVKrijHnbT3zISExfNQS2SSEhpO6JaDEKwOofa0085LVHdgiaqeb68iTWi9L54uU4NkFBqTjBJhqqjTgBRulozsKe0nkzVZez9UkovzTzz9oEq1Vem2d60bWJYkbPSofaun2wPwmuK4djDXv7PNUsadeaiIT(NouAfVOrWW97DMiR3vXPkRnlR3XdQ(ktGkGsu2AeAIuNcaQgBRulgks8XfiHtiNXnThCfr8KvUcFi176DMiR3vrvAo1quOu2sTHkr1CwNcakc0lXi8LXOiLbkrL4dvsDXzpCN2I9mI9oRYhnfz3WwmnqaCl(FrFzEe7DwLpAkIyJgCGayGaarQ5IY3giqNhYyl89iy4(9otK17QOknNAikEq1xzcubuIYwJqtK6uaqd5mUP9GRiINSYv4VjOsqVExVdY6Zez9UkQsZPgIIhu9Xw)tPOYNZiDkaO4gdeaisnxu(2ab68qgBHVhbd7DqwFZcmCvclzAFAmI7dJfgOI7l14(MQS2SSEVVvPY(q8QyvFV3xA(8Y30pT5LV1h1MSno27GS(mrwVRIQ0CQHO4bv)jdHEzi2P6uaqXabaIyVZdLwXlAeXtw5k8HGe2e0ilrSam5ab2ddeaiI9opuAfVOrepzLRWhkc05ywt8i)beceadeaiI9opuAfVOrepzLRWh6EBckEI)x0xMhXw)tPOYNZOiInAWsiTf7zeB9pLIkFoJISBylMkb92pqamqaGi278qPv8IgvPjMJpe2hheOxIr4lJrrkduIkLgQE6276DqwFsCuCFyR)P9LwyF53xiINH9SVFggjSWWY36tOzOnw1xb0NmUpnBgUpvOj4(aEuFwFiqN7ZCAFwFqScYZQV87tfAiUV87dde59vzVZez9UkQsZPgIcfB9pDKwOofaueOZ4dvpCqGohZAIh5pMDP3euCeAgAJvdaKjY6DBjnujJ46ENjY6DvuLMtnefpO6tnxu(2ab68qgBHVRtbaf3PTypJyR)Puu5ZzuKDdBX0abWT4)f9L5rS1)ukQ85mkIyJgCVZez9UkQsZPgIIhu9ZFctLVZ6uaqXabaIyVZdLwXlAuLMyU0qXfCqGolnu96DMiR3vrvAo1qu8GQ)KHqVme7uDkaO7HBXpd7MNrNfOF9iAGayGaard7Nk3Y69XQMWIGH7JZEyGaarS35HsR4fnI4jRCf(qrGohZAIh5pGqGayGaarS35HsR4fnI4jRCf(q3BtqXt8)I(Y8i26Fkfv(CgfrSrdwcPTypJyR)Puu5ZzuKDdBXujO3(bcGbcaeXENhkTIx0OknXC8HW(4Ga9smcFzmkszGsuP0q1t3EhK1NjY6DvuLMtnefpO6tzl1gQevZzDkaOiqVeJWxgJIugOevIpuCr3ENjY6DvuLMtnefpO6pzi0ldXovNcakgiaqe7DEO0kErJQ0eZXhIWbb6Lye(YyuKYaLOsPHkjKWzpCl(zy38m61MwoamoqamqaGiLTutnOGCeXtw5kPH0(9otK17QOknNAikEq1xJnuoujQMZ6uaqXDAl2Zi26Fkfv(Cgfz3WwmfhkBP2WC6GYcl4iINSYv4djCqGEjgHVmgfPmqjQeFO7jjKWddeaisnxu(2ab68qgBHVhbdLaKWtfYR1in0gNQOgBOCOsunNLqAl2ZOgBOedX2Cgfz3Wwmvc6TFVZez9UkQsZPgIIhu9Xw)thyFT0PaGk0m0gRgaitK172sAOsgX14ShgiaquJNEvAQsfvPjMJp09GeUsfYR1in0gNQi26F6a7R1(bcOc51AKgAJtveB9pDG91sA92V3bz9fKyO599a9j16FAF0Nv95F2xO5uEQe4kwIs2PXENjY6DvuLMtnefpO6pzO5JhyGT(NQtbaLYyGaaXjdnF8adS1)0i9L54auBA5aXtw5kPXLiK6DMiR3vrvAo1qu8GQpLTuByoDqzHfSofa09WabaIcunPEFOepiAJJGH4K2I9mI4vP0gLpWw)tJSBylMUpoiqVeJWxgJIugOevkTK627mrwVRIQ0CQHO4bvFS3zv(OjDkaOiqVeJWxgJKgQK6Qlo4gdeaisnxu(2ab68qgBHVhbd7DMiR3vrvAo1qu8GQpLTuBOsunN1PaGIa9smcFzmkszGsuj(q3tsiHhgiaqKAUO8Tbc05Hm2cFpcgkbiHNkKxRrAOnovrn2q5qLOAolH0wSNrn2qjgIT5mkYUHTyQe0B)abaQnTCG4jRCf(sQBVZez9UkQsZPgIIhu9PSLAdZPdklSG1PaGQc51AKgAJtvKYwQnmNoOSWcwAOqO3zISExfvP5udrXdQ(ASHYHkr1CwNcakgiaqKAUO8Tbc05Hm2cFpcggiac05ywt8i)XSJ)MG27mrwVRIQ0CQHO4bvFS1)0b2xlDkaOyGaarQ5IY3giqNhYyl89iyyVZez9UkQsZPgIIhu9Xw)thPfQtbafb6CmRjEK)acsVjO9otK17QOknNAikEq1NYwQnmNoOSWcwNcakgiaquGQj17dL4brBCemmqG0wSNrKfw0bLf)u4RQSEpYUHTyAGaQqETgPH24ufPSLAdZPdklSGLgQE9otK17QOknNAikEq1x8UcCkmR31PaGIbcaeXENhkTIx0iINSYvsdbjSjO9otK17QOknNAikEq1hB9pDG91sNcaQqZqBSAaGmrwVBlPHkzusCWabaIyVZdLwXlAeXtw5kPHGe2e0ENjY6DvuLMtnefpO6RXgkhQevZzDkaOiqNLwsC2db6CmRjEK)ac4VjObcGbcaeXENhkTIx0OknXCPXfCWabaIyVZdLwXlAeXtw5kPrGohZAIh5pGaEBc6(9otK17QOknNAikEq13qcZ5r(ie7PofaueOxIr4lJrrkduIkLwpDjWgyQ9icmCnfK7dV(GyNNxRIKKKqa]] )

end