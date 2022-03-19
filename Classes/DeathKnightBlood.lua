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
                local app = state.buff.swarming_mist.applied
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

    -- Tier 28
    spec:RegisterGear( "tier28", 188868, 188867, 188866, 188864, 188863 )
    spec:RegisterSetBonuses( "tier28_2pc", 364399, "tier28_4pc", 363590 )
    -- 2-Set - Endless Rune Waltz  Heart Strike increases your Strength by 1% andWhile your Dancing Rune Weapon is active Heart Strike extends the duration of Dancing Rune Weapon by 0.5 seconds and increases your Strength by 1%, persisting for 10 seconds after Dancing Rune Weapon ends.
    -- 4-Set - Endless Rune Waltz - Parrying an attack causes your weaponWhen you take damage, you have a chance equal to 100% of your Parry chance to lash out, Heart Striking your attacker. Dancing Rune Weapon now summons 2 Rune Weapons.

        spec:RegisterAuras( {
            endless_rune_waltz = {
                id = 366008,
                duration = 30,
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

        if set_bonus.tier28_2pc > 0 and buff.dancing_rune_weapon.up then
            if buff.endless_rune_waltz.up then buff.endless_rune_waltz.expires = buff.dancing_rune_weapon.expires + 10
            else applyBuff( "endless_rune_waltz", buff.dancing_rune_weapon.remains + 10 ) end
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
                    gainChargeTime( "vampiric_blood", 2 )
                end

                if buff.dancing_rune_weapon.up and set_bonus.tier28_2pc > 0 then
                    buff.dancing_rune_weapon.expires = buff.dancing_rune_weapon.expires + 0.5
                    addStack( "endless_rune_waltz", nil, 1 )
                    buff.endless_rune_waltz.expires = buff.dancing_rune_weapon.expires + 10
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
            gcd = "off",

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
            gcd = "off",

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


    spec:RegisterPack( "Blood", 20220317, [[dSegobqiivEKcP6sacYMuK(KcjmksHtrOSkfHxrqMfKYTauv7IIFPiAykehJGAzespdqzAaIUgG02GuLVbOY4auLZPqkwNcPKMhK4EkQ9rioiGqwiPupeqOAIkKOlciqFuHucJuHuIojKQQwjK0lbeqZeqOCtivf7KuYsHuv6PanvcvFfsvLXcia7fL)sYGH6WuTyv6XenzuDzKndXNby0KQtl1QviLYRvOMTq3wGDl63QA4k44acQLR0ZP00LCDvSDb57ey8kK05jfTEfsPA(cQ9dAMWmXzGCViMwIoIOIocWeg4mJmAasGNWmWsZbIbo4YXoaIbMEaXa1o(pNbo4AgFNZeNbA)ZkjgiyhCIE1FceFDKIbEpDSq)t2LbY9IyAj6iIk6iatyGZmYObibEJaCmq7ajzAjkqhHbQ3CoLSldKtwjdu74)CiEusEPdXabMna9cIk6JVsDiwyGdniw0revugySTLLjodmORgGx9NmXzAjmtCgiL(nsCM2mq52fTTZa1jpw6MbzbXOaXaDeioCyiwdigDqmG9pdq8uiwN8yPBgKfeJceJEOhelgd0Lv)jdmKhm0Blv34)CwX0suM4mqk9BK4mTzGUS6pzGCYlDLT2EmXa5KvU9q1FYar)t5h0jaiM7boacIxci8PxkGYcIBlelkqbcbXpceh4JkeRtES0Hy7hF0GyGocqii(rG4aFuHyDYJLoe3je7qmG9pdggOC7I22zGDk)GobO4EGdGuaZcXImdX6KhlDJ8SlLfRyAbmM4mqk9BK4mTzGUS6pzGCYlDLT2EmXa5KvU9q1FYahLFokkiosfe7jetJABRobaXAh)NdXG6nf5qmF)bdduUDrB7mqRhIu34)CLvVPihINcXDk)GobO4EGdGua1cXIaXJaXtH47bbXCJ)Zvw9MICZzaINcX3dcI5g)NRS6nf5MLc8oTqmkqSWgGcXtaXaKCwX0cizIZaP0VrIZ0Mbk3UOTDgy554obaXtH47bbXSNKuLpy4VGeINcXDk)GobO4EGdGuaZcXIaX6KhlDtGpQq8eq8igHzGUS6pzG7jjv5dSIPfqzIZaP0VrIZ0Mbk3UOTDgOo5Xs3miligfigOJaXaFiwdiw0rG4jG47bbXCJ)Zvw9MICZzaIfJb6YQ)Kb2s6(NKRq(T66WjwX0c9yIZaP0VrIZ0Mbk3UOTDgOo5Xs3miligfig4akepfIhOYaq)prZsbENwigfigOmqxw9NmqRl3gPLThvdUSyfRyG8vG6mWeNPLWmXzGu63iXzAZa)bgOLQgHb6YQ)KbgY32VrIbgYxv6beduN8Tu2A7XKAhu8vaduUDrB7mq5hIsplt2a0lfItq8uiMtEPR8KR4K010uTCCNayGH84Huu0smqnGyHbkeleeFpiigUNYobO2tskbKp8P5maXtaXcpceleeBhOyuv(cGkRrN8Tu2A7XeepbexEKYYOt(w3L8X0AO0VrIdXtaXIcXIbXtaXcBeLbgYJhIbQbelmqHyHG47bbXW9u2ja1EssjG8HpnNbiEciw4rGyHGy7afJQYxauzn6KVLYwBpMG4jG4YJuwgDY36UKpMwdL(nsCiEciwuiwmwX0suM4mqk9BK4mTzGYTlABNbQbeJoiw(HO0ZYKKC)4VCioCyi(Eqqm(9d60R(tvSdUMZaelgepfI1aIVheeZ9tsz1BkYnlf4DAHyuMH49KKP6asvVcyqC4Wq89GGyUFskREtrUzPaVtleJYmeRbedqYHyHGy5)r(lin34)C(25yAnl5CnH4jG4YJuwMB8FoF7CmTgk9BK4q8eqmqcXIbXHddX3dcI5(jPS6nf5gB5YXqmkqmWGyXG4Pq8EYwQgEb0A4esl7cIfbIfDegOlR(tgyGV7lyPKZkMwaJjodKs)gjotBgOC7I22zGsDFbqwiwKziwugOlR(tg4n(pxD)oYkMwajtCgiL(nsCM2mq52fTTZa1aI3t2s1WlGwdNqAzxqmkZqCiFB)gjdN8sxzRThtk(jyq5b)jliEkeJoiwdi(EqqmCpLDcqTNKuciF4tZsbENwigLziwuiEkexEKYYC)KS1Vbgk9BK4q8uiw(FK)csZ9tYw)gywkW70cXOaXIcXIbXIbXHddX7jBPA4fqRHtiTSligLzioKVTFJKrN8Tu2A7XKAhu8vad0Lv)jdKtEPRS12JjwX0cOmXzGu63iXzAZa)bgOLkgOlR(tgyiFB)gjgyipEigO8drPNLjBa6LcXjiEkeZjV0vEYvCs6AAQwoUtaq8uiwdi(EqqmCYlDRIFiZzaINcX3dcIHtEPBv8dzwkW70cXOaXOhelgdmKVQ0digiN8s3Q4hsDpiikPojhZkMwOhtCgiL(nsCM2mq52fTTZad5B73iz4Kx6wf)qQ7bbrj1j5yioCyiEpjzQoGu1RasigfigGKdXHddX7jBPA4fqRHtiTSliweioKVTFJKrN8Tu2A7XKAhu8vad0Lv)jduN8Tu2A7XeRyfdu(HO0ZYYeNPLWmXzGu63iXzAZaLBx02odeDq89GGy4Kx6wf)qMZaehomeFpiigo5LUvXpKzPaVtleJcedKqC4Wq89GGyKBhy)uzL)zbqMZad0Lv)jdKtEPBv8dXkMwIYeNbsPFJeNPnduUDrB7mq5)r(linCpLDcqTNKuciF4tZsbENwiweigyq8uiEpzlvdVaAHyrMHynG4rZiqmWhI1aITdumQkFbqL1yf4BqNaubTTG4jGyGbXIbXIXaDz1FYaTc8nOtaQG2wSIPfWyIZaP0VrIZ0Mbk3UOTDgi6G47bbXW9u2ja1EssjG8HpnNbgOlR(tgOF)Go9Q)uf7GlRyAbKmXzGu63iXzAZaLBx02od0(N4TtUz4yRtKu0EgQ(tdL(nsCioCyi2(N4TtUj0h9QJKY(Xquwgk9BK4q8uigDq89GGyc9rV6iPSFmeLLs)e453CZzGb2zr7EgkvJWaT)jE7KBc9rV6iPSFmeLfdSZI29muQoiG4TxeduygOlR(tgisKS6Y1rkgyNfT7zOuaI)1JmqHzftlGYeNbsPFJeNPnduUDrB7mq5)r(linCpLDcqTNKuciF4tZsbENwigfigyqC4Wqm6G47bbXW9u2ja1EssjG8HpnNbgOlR(tgOv3LJJKQ0j1jf8BPRjRyfdCyj5hC9IjotlHzIZaP0VrIZ0MbYjRC7HQ)KbceCuj5PioeFjKFjiw(bxVG4lbOtRbIbIKsAOSqC(jWx33aKteIDz1FAH4pJAAyGUS6pzGirYQlxhPyfRyG2YtUVCM4mTeMjodKs)gjotBgOC7I22zG7jBPA4fqRHtiTSligLziw4rG4PqSgqm6G4YJuwM7NKT(nWqPFJehIdhgIrhel)pYFbP5(jzRFdml5CnH4WHH47bbXW9u2ja1EssjG8HpnNbiwmgOlR(tgiN8sxzRThtSIPLOmXzGu63iXzAZaLBx02odCGkda9)enlf4DAHyuGyasoepbelkd0Lv)jd06YTrAz7r1GllwX0cymXzGu63iXzAZaLBx02odu(HO0ZYKna9sH4eepfI5Kx6kp5kojDnnvlh3jaiEkeRbeFpiigo5LUvXpK5maXtH47bbXWjV0Tk(Hmlf4DAHyuGy0dIfJb6YQ)KbQt(wkBT9yIvmTasM4mqk9BK4mTzGYTlABNbEpiiM7NKYQ3uKBSLlhdXImdXahepfI3tsqSiZqSOq8uigDqS8drPNLjeLLUMld0Lv)jdS(GRT(KyftlGYeNbsPFJeNPnduUDrB7mqnG47bbXC)Kuw9MICZsbENwigLziEpjzQoGu1RagehomeFpiiM7NKYQ3uKBwkW70cXOmdXAaXaKCiwiiw(FK)csZn(pNVDoMwZsoxtiEciU8iLL5g)NZ3ohtRHs)gjoepbedKqSyqC4Wq89GGyUFskREtrUXwUCmeJceJEqC4WqSgqSgqm6Gy5hIsplt2a0lfItqC4Wq89GGy4Kx6wf)qMLc8oTqSiqmqHyXG4Pq89GGyUFskREtrUzPaVtleJcedCqSyqSyq8uiEpzlvdVaAnCcPLDbXImdXcdugOlR(tgyGV7lyPKZkMwOhtCgiL(nsCM2mq52fTTZa3t2s1WlGwdNqAzxqmkZqCiFB)gjdN8sxzRThtk(jyq5b)jliEkeJoiwdiU8iLL5(jzRFdmu63iXH4PqS8)i)fKM7NKT(nWSuG3PfIrbIffIfdINcXOdI1aILFik9SmHOS01CH4PqS8)i)fKgRaFd6eGkOTLzPaVtleJcedmiwmgOlR(tgiN8sxzRThtSIPfWXeNbsPFJeNPnduUDrB7mqPUVaiRczDz1F6riwKziwydWdINcXAaX3dcIrNcEB522ASLlhdXOmdXAaXafIb(qSDGIrv5laQSMB8FU6(DeIfdIdhgITdumQkFbqL1CJ)Zv3VJqSiqSOqSymqxw9NmWB8FU6(DKvmTaEmXzGu63iXzAZaDz1FYad8DS6ru34)CgiNSYThQ(tgi6JVJH4hbI1o(phI5pzH48liEWtof0sGpnQfLCdduUDrB7mqoDpiiMaFhREe1n(p3WFbjepfIrAa6LAPaVtlelcedCgGYkMwJgM4mqk9BK4mTzGYTlABNbEpiig52b2pvw5FwaK5maXtH4YJuwMLITvx1P6g)NBO0VrIdXtH49KTun8cO1WjKw2felcel8imqxw9Nmqo5LUYtUItsxtwX0s4ryIZaP0VrIZ0Mbk3UOTDg4EYwQgEb0cXImdXcpYiq8uigDqS8drPNLjeLLUMld0Lv)jd8(jzRFdyftlHfMjodKs)gjotBg4pWaTu1imqxw9NmWq(2(nsmWq(QspGyG6KVLYwBpMu7aduUDrB7mq5hIsplt2a0lfItq8uiMtEPR8KR4K010uTCCNayGH84Huu0smqnGyHbkeleeBhOyuv(cGkRrN8Tu2A7XeepbexEKYYOt(w3L8X0AO0VrIdXtaXIcXIbXtaXcBeLbgYJhIbQbelmqHyHGy7afJQYxauzn6KVLYwBpMG4jG4YJuwgDY36UKpMwdL(nsCiEciwuiwmwX0syrzIZaP0VrIZ0Mbk3UOTDgOgq8EYwQgEb0A4esl7cIrzgId5B73iz0jFlLT2EmP2biwmioCyiU8favMQdiv9kEtqmkqSWJWaDz1FYa5Kx6kBT9yIvmTegymXzGu63iXzAZaLBx02od0oqXOQ8favwdN8sx5jxXjPRjelYmedmgOlR(tgiN8sx5jxXjPRjRyAjmqYeNbsPFJeNPnduUDrB7mW9KKP6asvVciHyuGyasod0Lv)jduN8Tu2A7XeRyAjmqzIZaP0VrIZ0Mbk3UOTDg49GGyKBhy)uzL)zbqMZaehomexEKYYS(qZvCs(bdVTR(tdL(nsCgOlR(tgiN8sx5jxXjPRjRyAjm6XeNbsPFJeNPnduUDrB7mW7bbXC)Kuw9MICZsbENwiweigyq8eqmajNb6YQ)Kbk)0EcgQ(twX0syGJjodKs)gjotBgOC7I22zGsDFbqwfY6YQ)0JqSiZqSWgHH4Pq89GGyUFskREtrUzPaVtlelcedmiEcigGKZaDz1FYaVX)5Q73rwX0syGhtCgiL(nsCM2mq52fTTZa3tsqSiqSWq8uiwdiEpjzQoGu1RageJcedqYH4WHH47bbXC)Kuw9MICJTC5yiweig4G4Pq89GGyUFskREtrUzPaVtlelceVNKmvhqQ6vadIfcIbi5qSymqxw9NmqDY3szRThtSIPLWJgM4mqk9BK4mTzGYTlABNbUNSLQHxaTgoH0YUGyrGyrhHb6YQ)Kb6R0tsv)UuwSIvmW1LThTmXzAjmtCgiL(nsCM2mq52fTTZaL)h5VG0W9u2ja1EssjG8Hpnl5CnH4PqSgqm6Gy5)r(lin34)C(25yAnl5CnH4WHHy0bXLhPSm34)C(25yAnu63iXHyXyGUS6pzG34)CfYz1KvmTeLjod0Lv)jd8sRL2XDcGbsPFJeNPnRyAbmM4mqk9BK4mTzGYTlABNb6YQdrkkPGMSqSiZqSOqC4Wq8EscIrbIfgINcX7jBPA4fqRHtiTSliweig9gHb6YQ)Kb6R0tsnCIwIvmTasM4mqk9BK4mTzGYTlABNbEpiiMtQ)rnv2APeqPBodmqxw9NmWydqVSQrBhoGaklwX0cOmXzGUS6pzGEkjBTEuj9yKbsPFJeNPnRyAHEmXzGUS6pzGi9s34)CgiL(nsCM2SIPfWXeNb6YQ)KbEDaQhrvBlhBzGu63iXzAZkMwapM4mqk9BK4mTzGYTlABNbUNSLQHxaTgoH0YUGyrGyrhHb6YQ)Kb6R0tsv)UuwSIvmq(kqDguHOS01CzIZ0syM4mqk9BK4mTzG)ad0svJWaDz1FYad5B73iXad5Rk9aIbwFW1wFsQ7NKs(NSyGYTlABNbEpiigUNYobO2tskbKp8P5mWad5XdPOOLyGaLbgYJhIbcCSIPLOmXzGu63iXzAZaLBx02od8Eqqm3pjLvVPi3ylxogIfzgId5B73izQp4ARpj19tsj)twq8uiEpjbXImdXIcXtH49KTun8cO1WjKw2felcedSryGUS6pzG1hCT1NeRyAbmM4mqk9BK4mTzGYTlABNbQbeFpiiM7NKYQ3uKBwkW70cXOmdX7jjt1bKQEfWG4WHH47bbXC)Kuw9MICZsbENwigLziwdigGKdXcbXY)J8xqAUX)58TZX0AwY5AcXtaXLhPSm34)C(25yAnu63iXH4jGyGeIdhgIVheeZ9tsz1BkYn2YLJHyuGyGcXIbXIbXtH49KTun8cO1WjKw2felcel6imqxw9NmWaF3xWsjNvmTasM4mqk9BK4mTzGYTlABNbk19fazHyrMHyrzGUS6pzG34)C197iRyAbuM4mqk9BK4mTzGYTlABNbUNSLQHxaTgoH0YUGyuMH4q(2(nsgo5LUYwBpMu8tWGYd(twq8uigDqSgqC5rklZ9tYw)gyO0VrIdXtHy5)r(lin3pjB9BGzPaVtleJcelkelgd0Lv)jdKtEPRS12JjwX0c9yIZaP0VrIZ0Mbk3UOTDg4EYwQgEb0cXImdXcpYiq8ui(Eqqmwb(g0javqBlZzGb6YQ)KbE)KS1VbSIPfWXeNbsPFJeNPnd8hyGwQyGUS6pzGH8T9BKyGH84HyGAaXcduiwii(EqqmCpLDcqTNKuciF4tZzaINaIfEeiwii2oqXOQ8favwJo5BPS12JjiEciU8iLLrN8TUl5JP1qPFJehINaIffIfJbgYxv6beduN8Tu2A7XKAhu8vGkeLLUMlRyAb8yIZaP0VrIZ0Mbk3UOTDg4EsYuDaPQxbKqmkqmajhIdhgI3t2s1WlGwdNqAzxqSiZqCiFB)gjJo5BPS12Jj1oO4RaviklDnxgOlR(tgOo5BPS12JjwXkgiNq8tSyIZ0syM4mqk9BK4mTzGCYk3EO6pzGabhvsEkIdXuiA1eIRoGG4sNGyxw)cXTfI9qEh9BKmmqxw9NmWGo5kKLOr7eRyAjktCgiL(nsCM2mWFGbAPQryGUS6pzGH8T9BKyGH8vLEaXa5Kx6kBT9ysXpbdkp4pzXaLBx02odu(HO0ZYKna9sH4eepfIVheedN8s3Q4hYSuG3PfIfbIrpgyipEiffTedeOaLbgYJhIbcCJWkMwaJjodKs)gjotBgOC7I22zG3dcI5(jPS6nf5MLc8oTqmkqmWG4jGyasUHgvsEkcIdhgI1aIVheeZ9tsz1BkYnlf4DAHyuMH49KKP6asvVcyqC4Wq89GGyUFskREtrUzPaVtleJYmeRbedqYHyHGy5)r(lin34)C(25yAnl5CnH4jG4YJuwMB8FoF7CmTgk9BK4q8eqSOqSyqC4Wq89GGyUFskREtrUXwUCmeJceduiwmiEkeVNSLQHxaTgoH0YUGyrMHyrhHb6YQ)Kbg47(cwk5SIPfqYeNbsPFJeNPnduUDrB7mWYZXDcaIdhgI7u(bDcqX9ahaPaQfIfbIhHbARTLftlHzGUS6pzGspgvUS6pvX2wmWyBlv6bedmORgGx9NSIPfqzIZaP0VrIZ0Mbk3UOTDg49GGy4Ek7eGApjPeq(WNMZadKtw52dv)jdeStjbXLobXdF1FcXY)J8xqcX6UfIL6EcG4ObXcOrrmcXwntjelOlDiEuI(I(XaDz1FYah(Q)KvmTqpM4mqxw9NmWJLuDrbwgiL(nsCM2SIPfWXeNb6YQ)KbUEBjfNCodKs)gjotBwX0c4XeNbsPFJeNPnduUDrB7mq0bX3dcIH7PStaQ9KKsa5dFAodq8uiwdigDqS8drPNLjBa6LcXjioCyi(EqqmCYlDRIFiZsbENwiweig4GyXyGUS6pzG34)C(25yAzftRrdtCgiL(nsCM2mqxw9NmWaF3xWsjNbYjRC7HQ)KbI(47(cwk5q8Nq8WjgH4gbI1IK7h)LdXDcX)YPfIRhIbC81ZIii(T2JVAcX8Z2jaiU0jigPxBbXJs0x0piwqx6qmqeqmgOC7I22zGYpeLEwMKK7h)LdXtH47bbXC)Kuw9MICJTC5yigLziEewX0s4ryIZaP0VrIZ0Mb6YQ)Kbk9yu5YQ)ufBBXaJTTuPhqmW1LThTSIPLWcZeNbsPFJeNPnd0Lv)jd06YTrAz7r1GllgiNSYThQ(tgiquvuWqbX1dXwxUnsljiU0jigG(FIqCJaXciiEyjEll)g1eIf0XieNFbX8hIdosDiUtiU0jiojFHyKtDwIbk3UOTDgOgqm6Gy5hIsplt2a0lfItqC4Wq89GGy4Kx6wf)qMLc8oTqSiqm6bXIbXtHy0bX3dcIH7PStaQ9KKsa5dFAodq8uiwdiEGkda9)enlf4DAHyuGyrH4WHH4YxauzQoGu1R4nbXOaXaKCiwmwX0syrzIZaP0VrIZ0Mb6YQ)Kbk9yu5YQ)ufBBXaJTTuPhqmq5hIspllRyAjmWyIZaP0VrIZ0Mbk3UOTDgOgq8EscIrzgIffINcX7jjt1bKQEfqcXIaXaKCiEkel19fazviRlR(tpcXImdXcBaEqSyqC4Wq8EsYuDaPQxbmiweigGKZaDz1FYaVX)5QYhyftlHbsM4mqk9BK4mTzGYTlABNbIoiw(HO0ZYeIYsxZLb6YQ)KbY9u2ja1EssjG8HpzftlHbktCgiL(nsCM2mq52fTTZaVheed3tzNau7jjLaYh(0CgG4Pqm6Gy5hIspltiklDnxgOlR(tg4EsLlR(tvSTfdm22sLEaXa5Ra1zGvmTeg9yIZaP0VrIZ0Mbk3UOTDgO8drPNLjeLLUMlepfIL)h5VG0yf4BqNaubTTml5CnH4Pq8EYwQgEb0cXImdXAaXJMrGyGpeRbeBhOyuv(cGkRXkW3GobOcABbXtaXadIfdIfJb6YQ)KbY9u2ja1EssjG8HpzftlHboM4mqk9BK4mTzGYTlABNbk)qu6zzcrzPR5cXtHynG47bbXW9u2ja1EssjG8HpnNbioCyi(Eqqmwb(g0javqBlZzaIfJb6YQ)KbUNu5YQ)ufBBXaJTTuPhqmq(kqDguHOS01CzftlHbEmXzGu63iXzAZaDz1FYaLEmQCz1FQITTyGX2wQ0digOT8K7lNvSIvmWq0A7pzAj6iIk6iaBe0JbkW3Stawgi6hqe6RwO)AnAXOvigIfxNG4oy43cIr(fIhfYpeLEw2rbeVeq4tVehITFabX(P(aVioel19eaznqubI1jbXa5Ovigi(NHOTioepkS)jE7KBacyuaX1dXJc7FI3o5gGamu63iXhfqSgIoQIzGOcrf9py43I4qmWdIDz1FcXX2wwdevgOFk9FzGGDaqCiwiiE0sAChBg4W(iDKyGJoeRD8FoepkjV0HyGaZgGEbrD0Hy0hFL6qSWahAqSOJiQOquHOo6qmqWrLKNI4q8Lq(LGy5hC9cIVeGoTgigiskPHYcX5NaFDFdqori2Lv)PfI)mQPbIQlR(tRzyj5hC9sO5jrIKvxUosbrfI6OdXabhvsEkIdXuiA1eIRoGG4sNGyxw)cXTfI9qEh9BKmquDz1FANd6KRqwIgTtquDz1FAfAEYq(2(nsOLEanZjV0v2A7XKIFcguEWFYcTqE8qZa3iO9dZwQAe0KFY7Q)Cw(HO0ZYKna9sH4007bbXWjV0Tk(Hmlf4DAfb9qlKhpKIIwAgOafIQlR(tRqZtg47(cwk5O1iZ3dcI5(jPS6nf5MLc8oTOaSjai5gAuj5POWH14Eqqm3pjLvVPi3SuG3PfL59KKP6asvVcyHdFpiiM7NKYQ3uKBwkW70IYSgaKCHK)h5VG0CJ)Z5BNJP1SKZ1CIYJuwMB8FoF7CmTgk9BK4tiQyHdFpiiM7NKYQ3uKBSLlhJcqfB6EYwQgEb0A4esl7sKzrhbIQlR(tRqZtk9yu5YQ)ufBBHw6b0CqxnaV6prZwBlRzHrRrMlph3jGWH7u(bDcqX9ahaPaQvKrGOo6qmyNscIlDcIh(Q)eIL)h5VGeI1Dlel19eaXrdIfqJIyeITAMsiwqx6q8Oe9f9dIQlR(tRqZto8v)jAnY89GGy4Ek7eGApjPeq(WNMZaevxw9NwHMN8yjvxuGfIQlR(tRqZtUEBjfNCoevxw9NwHMN8g)NZ3ohtlAnYm6Uheed3tzNau7jjLaYh(0CgMQb6KFik9SmzdqVuiofo89GGy4Kx6wf)qMLc8oTIaCIbrD0Hy0hF3xWsjhI)eIhoXie3iqSwKC)4VCiUti(xoTqC9qmGJVEwebXV1E8vtiMF2obaXLobXi9AliEuI(I(bXc6shIbIaIbr1Lv)PvO5jd8DFblLC0AKz5hIspltsY9J)YNEpiiM7NKYQ3uKBSLlhJY8iquDz1FAfAEsPhJkxw9NQyBl0spGMxx2E0crD0HyGOQOGHcIRhITUCBKwsqCPtqma9)eH4gbIfqq8Ws8ww(nQjelOJrio)cI5pehCK6qCNqCPtqCs(cXiN6Seevxw9NwHMN06YTrAz7r1Gll0AKznqN8drPNLjBa6LcXPWHVheedN8s3Q4hYSuG3Pve0tSPO7EqqmCpLDcqTNKuciF4tZzyQgduzaO)NOzPaVtlkIgoC5laQmvhqQ6v8MqbGKlgevxw9NwHMNu6XOYLv)Pk22cT0dOz5hIspllevxw9NwHMN8g)NRkFaTgzwJ9KekZIoDpjzQoGu1Rasrai5tL6(cGSkK1Lv)PhfzwydWtSWH3tsMQdiv9kGjcajhIQlR(tRqZtY9u2ja1EssjG8HprRrMrN8drPNLjeLLUMlevxw9NwHMNCpPYLv)Pk22cT0dOz(kqDgqRrMVheed3tzNau7jjLaYh(0CgMIo5hIspltiklDnxiQUS6pTcnpj3tzNau7jjLaYh(eTgzw(HO0ZYeIYsxZDQ8)i)fKgRaFd6eGkOTLzjNR509KTun8cOvKzngnJa81WoqXOQ8favwJvGVbDcqf02AcGjMyquDz1FAfAEY9Kkxw9NQyBl0spGM5Ra1zqfIYsxZfTgzw(HO0ZYeIYsxZDQg3dcIH7PStaQ9KKsa5dFAodHdFpiigRaFd6eGkOTL5migevxw9NwHMNu6XOYLv)Pk22cT0dOzB5j3xoeviQUS6pTg5hIspl7mN8s3Q4hcTgzgD3dcIHtEPBv8dzodHdFpiigo5LUvXpKzPaVtlkaz4W3dcIrUDG9tLv(NfazodquDz1FAnYpeLEwwHMN0kW3GobOcABHwJml)pYFbPH7PStaQ9KKsa5dFAwkW70kcWMUNSLQHxaTImRXOzeGVg2bkgvLVaOYASc8nOtaQG2wtamXedIQlR(tRr(HO0ZYk08K(9d60R(tvSdUO1iZO7EqqmCpLDcqTNKuciF4tZzaIQlR(tRr(HO0ZYk08KirYQlxhPqRrMT)jE7KBgo26ejfTNHQ)mCy7FI3o5MqF0Rosk7hdrznfD3dcIj0h9QJKY(Xquwk9tGNFZnNb06SODpdLQdciE7fnlmADw0UNHsbi(xpolmADw0UNHs1iZ2)eVDYnH(OxDKu2pgIYcIQlR(tRr(HO0ZYk08KwDxoosQsNuNuWVLUMO1iZY)J8xqA4Ek7eGApjPeq(WNMLc8oTOaSWHr39GGy4Ek7eGApjPeq(WNMZaeviQUS6pTg(kqDgMd5B73iHw6b0So5BPS12Jj1oO4Ra0c5XdnRHWavO7bbXW9u2ja1EssjG8HpnNHjeEeHSdumQkFbqL1Ot(wkBT9yAIYJuwgDY36UKpMwdL(ns8jevm0(HzlvncAYp5D1Fol)qu6zzYgGEPqCAkN8sx5jxXjPRPPA54obGwipEiffT0SgcduHUheed3tzNau7jjLaYh(0CgMq4reYoqXOQ8favwJo5BPS12JPjkpszz0jFR7s(yAnu63iXNquXMqyJOquDz1FAn8vG6mi08Kb(UVGLsoAnYSgOt(HO0ZYKKC)4V8WHVheeJF)Go9Q)uf7GR5mi2unUheeZ9tsz1BkYnlf4DArzEpjzQoGu1Raw4W3dcI5(jPS6nf5MLc8oTOmRbajxi5)r(lin34)C(25yAnl5CnNO8iLL5g)NZ3ohtRHs)gj(eaPyHdFpiiM7NKYQ3uKBSLlhJcWeB6EYwQgEb0A4esl7serhbIQlR(tRHVcuNbHMN8g)NRUFhrRrML6(cGSImlkevxw9NwdFfOodcnpjN8sxzRThtO1iZASNSLQHxaTgoH0YUqzoKVTFJKHtEPRS12Jjf)emO8G)K1u0PX9GGy4Ek7eGApjPeq(WNMLc8oTOml60YJuwM7NKT(nWqPFJeFQ8)i)fKM7NKT(nWSuG3PffrftSWH3t2s1WlGwdNqAzxOmhY32VrYOt(wkBT9ysTdk(kaIQlR(tRHVcuNbHMNmKVTFJeAPhqZCYlDRIFi19GGOK6KCmAH84HMLFik9SmzdqVuionLtEPR8KR4K010uTCCNaMQX9GGy4Kx6wf)qMZW07bbXWjV0Tk(Hmlf4DArb9edIQlR(tRHVcuNbHMNuN8Tu2A7XeAnYCiFB)gjdN8s3Q4hsDpiikPojhho8EsYuDaPQxbKOaqYdhEpzlvdVaAnCcPLDjsiFB)gjJo5BPS12Jj1oO4RaiQquDz1FAn8vG6mOcrzPR5ohY32VrcT0dO56dU26tsD)KuY)KfAH84HMbo0(HzlvncAYp5D1FoFpiigUNYobO2tskbKp8P5mGwipEiffT0mqHO6YQ)0A4Ra1zqfIYsxZvO5jRp4ARpj0AK57bbXC)Kuw9MICJTC5yrMd5B73izQp4ARpj19tsj)twt3tsIml609KTun8cO1WjKw2LiaBeiQUS6pTg(kqDguHOS01CfAEYaF3xWsjhTgzwJ7bbXC)Kuw9MICZsbENwuM3tsMQdiv9kGfo89GGyUFskREtrUzPaVtlkZAaqYfs(FK)csZn(pNVDoMwZsoxZjkpszzUX)58TZX0AO0VrIpbqgo89GGyUFskREtrUXwUCmkavmXMUNSLQHxaTgoH0YUer0rGO6YQ)0A4Ra1zqfIYsxZvO5jVX)5Q73r0AKzPUVaiRiZIcr1Lv)P1WxbQZGkeLLUMRqZtYjV0v2A7XeAnY8EYwQgEb0A4esl7cL5q(2(nsgo5LUYwBpMu8tWGYd(twtrNgLhPSm3pjB9BGHs)gj(u5)r(lin3pjB9BGzPaVtlkIkgevxw9NwdFfOodQquw6AUcnp59tYw)gGwJmVNSLQHxaTIml8iJm9Eqqmwb(g0javqBlZzaIQlR(tRHVcuNbviklDnxHMNmKVTFJeAPhqZ6KVLYwBpMu7GIVcuHOS01CrlKhp0SgcduHUheed3tzNau7jjLaYh(0CgMq4reYoqXOQ8favwJo5BPS12JPjkpszz0jFR7s(yAnu63iXNquXGO6YQ)0A4Ra1zqfIYsxZvO5j1jFlLT2EmHwJmVNKmvhqQ6vajkaK8WH3t2s1WlGwdNqAzxImhY32VrYOt(wkBT9ysTdk(kqfIYsxZfIkevxw9NwtqxnaV6pNd5bd92s1n(phTgzwN8yPBgKfkaDKWH1aDa2)mmvN8yPBgKfkOh6jge1rhIr)t5h0jaiM7boacIxci8PxkGYcIBlelkqbcbXpceh4JkeRtES0Hy7hF0GyGocqii(rG4aFuHyDYJLoe3je7qmG9pdgiQUS6pTMGUAaE1Fk08KCYlDLT2EmHwJm3P8d6eGI7boasbmRiZ6KhlDJ8SlLfe1rhIhLFokkiosfe7jetJABRobaXAh)NdXG6nf5qmF)bdevxw9NwtqxnaV6pfAEso5LUYwBpMqRrMTEisDJ)Zvw9MI8PDk)GobO4EGdGua1kYitVheeZn(pxz1BkYnNHP3dcI5g)NRS6nf5MLc8oTOiSbOtaqYHO6YQ)0Ac6Qb4v)PqZtUNKuLpGwJmxEoUtatVheeZEssv(GH)cYPDk)GobO4EGdGuaZkIo5Xs3e4J6eJyegIQlR(tRjORgGx9NcnpzlP7FsUc53QRdNqRrM1jpw6MbzHcqhb4RHOJmX9GGyUX)5kREtrU5migevxw9NwtqxnaV6pfAEsRl3gPLThvdUSqRrM1jpw6MbzHcWb0PduzaO)NOzPaVtlkafIkevxw9NwZ6Y2J25B8FUc5SAIwJml)pYFbPH7PStaQ9KKsa5dFAwY5Aovd0j)pYFbP5g)NZ3ohtRzjNRz4WOR8iLL5g)NZ3ohtRHs)gjUyquDz1FAnRlBpAfAEYlTwAh3jaiQUS6pTM1LThTcnpPVspj1WjAj0AKzxwDisrjf0KvKzrdhEpjHIWt3t2s1WlGwdNqAzxIGEJar1Lv)P1SUS9OvO5jJna9YQgTD4acOSqRrMVheeZj1)OMkBTucO0nNbiQUS6pTM1LThTcnpPNsYwRhvspgHO6YQ)0Awx2E0k08Ki9s34)CiQUS6pTM1LThTcnp51bOEevTTCSfIQlR(tRzDz7rRqZt6R0tsv)UuwO1iZ7jBPA4fqRHtiTSlreDeiQquDz1FAn2YtUV8zo5LUYwBpMqRrM3t2s1WlGwdNqAzxOml8it1aDLhPSm3pjB9BGHs)gjE4WOt(FK)csZ9tYw)gywY5Ago89GGy4Ek7eGApjPeq(WNMZGyquDz1FAn2YtUVCHMN06YTrAz7r1Gll0AK5bQma0)t0SuG3Pffas(eIcrD0hDi2Lv)P1ylp5(YfAEYB8FoF7CmTO1iZO7EqqmCpLDcqTNKuciF4tZzaI6Op6q8O8meBPxehI1PLG4lj9JLG4sNG4GUAaE1FcXX2wq8sXMSq8NqC554obmz5J7eaeZ9ahazGOo6Joe7YQ)0ASLNCF5cnpzGV7lyPKJwJmFpiiM7NKYQ3uKBwkW70IcWMaGKBOrLKNIchwJ7bbXC)Kuw9MICZsbENwuM3tsMQdiv9kGfo89GGyUFskREtrUzPaVtlkZAaqYfs(FK)csZn(pNVDoMwZsoxZjkpszzUX)58TZX0AO0VrIpHOIfo89GGyUFskREtrUXwUCmkatSP7jBPA4fqRHtiTSlrMfDeiQUS6pTgB5j3x(So5BPS12Jj0AKz5hIsplt2a0lfItt5Kx6kp5kojDnnvlh3jGPACpiigo5LUvXpK5mm9EqqmCYlDRIFiZsbENwuqpXGO6YQ)0ASLNCF5cnpz9bxB9jHwJmFpiiM7NKYQ3uKBSLlhlYmWnDpjjYSOtrN8drPNLjeLLUMlevxw9NwJT8K7lxO5jd8DFblLC0AKznUheeZ9tsz1BkYnlf4DArzEpjzQoGu1Raw4W3dcI5(jPS6nf5MLc8oTOmRbajxi5)r(lin34)C(25yAnl5CnNO8iLL5g)NZ3ohtRHs)gj(eaPyHdFpiiM7NKYQ3uKBSLlhJc6foSgAGo5hIsplt2a0lfItHdFpiigo5LUvXpKzPaVtRiavSP3dcI5(jPS6nf5MLc8oTOaCIj209KTun8cO1WjKw2LiZcduiQUS6pTgB5j3xUqZtYjV0v2A7XeAnY8EYwQgEb0A4esl7cL5q(2(nsgo5LUYwBpMu8tWGYd(twtrNgLhPSm3pjB9BGHs)gj(u5)r(lin3pjB9BGzPaVtlkIk2u0PH8drPNLjeLLUM7u5)r(linwb(g0javqBlZsbENwuaMyquDz1FAn2YtUVCHMN8g)NRUFhrRrML6(cGSkK1Lv)PhfzwydWBQg3dcIrNcEB522ASLlhJYSgaf4BhOyuv(cGkR5g)NRUFhflCy7afJQYxauzn34)C197OiIkge1rhIrF8Dme)iqS2X)5qm)jleNFbXdEYPGwc8PrTOKBGO6YQ)0ASLNCF5cnpzGVJvpI6g)NJwJmZP7bbXe47y1JOUX)5g(liNI0a0l1sbENwraodqHO6YQ)0ASLNCF5cnpjN8sx5jxXjPRjAnY89GGyKBhy)uzL)zbqMZW0YJuwMLITvx1P6g)NBO0VrIpDpzlvdVaAnCcPLDjIWJar1Lv)P1ylp5(YfAEY7NKT(naTgzEpzlvdVaAfzw4rgzk6KFik9SmHOS01CHO6YQ)0ASLNCF5cnpziFB)gj0spGM1jFlLT2EmP2b0c5XdnRHWavi7afJQYxauzn6KVLYwBpMMO8iLLrN8TUl5JP1qPFJeFcrfdTFy2svJGM8tEx9NZYpeLEwMSbOxkeNMYjV0vEYvCs6AAQwoUtaOfYJhsrrlnRHWavi7afJQYxauzn6KVLYwBpMMO8iLLrN8TUl5JP1qPFJeFcrfBcHnIcr1Lv)P1ylp5(YfAEso5LUYwBpMqRrM1ypzlvdVaAnCcPLDHYCiFB)gjJo5BPS12Jj1oiw4WLVaOYuDaPQxXBcfHhbIQlR(tRXwEY9Ll08KCYlDLNCfNKUMO1iZ2bkgvLVaOYA4Kx6kp5kojDnfzgyquDz1FAn2YtUVCHMNuN8Tu2A7XeAnY8EsYuDaPQxbKOaqYHO6YQ)0ASLNCF5cnpjN8sx5jxXjPRjAnY89GGyKBhy)uzL)zbqMZq4WLhPSmRp0CfNKFWWB7Q)0qPFJehIQlR(tRXwEY9Ll08KYpTNGHQ)eTgz(Eqqm3pjLvVPi3SuG3PveGnbajhIQlR(tRXwEY9Ll08K34)C197iAnYSu3xaKvHSUS6p9OiZcBeE69GGyUFskREtrUzPaVtRiaBcasoevxw9NwJT8K7lxO5j1jFlLT2EmHwJmVNKer4PASNKmvhqQ6vadfasE4W3dcI5(jPS6nf5gB5YXIaCtVheeZ9tsz1BkYnlf4DAfzpjzQoGu1RaMqaKCXGO6YQ)0ASLNCF5cnpPVspjv97szHwJmVNSLQHxaTgoH0YUer0ryfRym]] )

end