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


    spec:RegisterPack( "Blood", 20220306, [[d4KddbqiikpskvUKijPnPQQpbvfJIq5uesRcQQEfHQzrk1Tejv7su)skLHjs1XiOwMiLNbbMgeuUMQkTnvv03GOY4GQsDoOQK1brvyEeI7bv2hb5GQQqlKu4HqqYeLsvxeIQYhHGqJecI6KquvTsiYlHGaZuKu6MIKIDks8tiiOHkssTuvvWtHYujfDviQI(keunwrsI9I0FvLbR0HfwmKEmrtgXLrTzaFwvz0KQtRy1qqQxdHMTuDBrSBk)wLHlfhhcISCqpNKPl56aTDOkFNaJxKeNNuY6HOknFPK9t1uHPAsXirX0usl90slDeK(pZc)ZFrUFfMIvA1WuSMqIy8XumlsykMg97iuSMqR(feQMum1bcLmfdBsa7rnNHqbdGIIHco9c53OOumsumnL0spT0shbP)ZSW)8xK7xkMQHL0us730Py6dHWgfLIryLKIPr)oIVTNJs3xecS5tVCKsnbuQ77p1230spT0Oy9rvkQMumcdeG9IQjnfHPAsXylq7mHQbfJWkjCAQ5mkgYxQWsWIj(Y4XqT8TMe23sN9nK1b9Du(g4ftpq7CMIfYAoJILmg5bazg5LPfnL0OAsXylq7mHQbftcNIHtqXqbbaYONXpL(WDsgYjXykFfXxe4l(99tsYCQWsWI9TvlFfZxuqaGm6z8tPpCNKHCsmMYxrW5le04Cnj8RUhc8TvlFrbbaYONXpL(WDsgYjXykFfbNVI57NK4R4(kVRtobwgTFhHahdrgMHCq0Yx87BfD2QmA)ocbogImmZwG2zIV43308vuFB1YxuqaGm6z8tPpCNKvvir0xr89xFf13)(cbTr(AobmmtyGroLVcHZ30sNIfYAoJILeq4jaYgHw0uqavtkgBbANjunOys4umCckwfgIJ95BRw(oM8sg77rIK4JF)Q8viFtNIPk4ilAkctXcznNrXKrV)cznN96JQOy9rvplsykwYuZxuZz0IMccJQjfJTaTZeQgumjCkgobftExNCcSmjm5yFpiOXpbC0CwgYbrlF)7Ry(ImFL31jNalJ2VJqGJHidZqoiA5BRw(ImFROZwLr73riWXqKHz2c0ot8vukwiR5mkgA)oYdaeQfTOP8lvtkwiR5mkgkdvmeXX(OySfODMq1Gw0u(jvtkgBbANjunOys4umCckwiRbp(XgNmSYxHW5BA(2QLVqqJ9veFf23)(cbTr(AobmmtyGroLVc57ptNIfYAoJIfqzy8RbSRyArtb5OAsXylq7mHQbftcNIHtqXqbbaYGM(116PkiBFLEgSHIfYAoJI1Np9s9qObjFjSv0IMc(MQjflK1CgflmjRky0FYO3PySfODMq1Gw0uWxunPyHSMZOyadKr73rOySfODMq1Gw0ueoDQMuSqwZzum047DaVcosevum2c0otOAqlAkclmvtkgBbANjunOys4umCckgkiaqMeMCSVhe04NaoAold2qXiSscNMAoJIHnMK9T0zFBUAoZx5DDYjW8vpu(k1d7JjA7RagF6DFvAzsFfmLUVT)hq4uSqwZzuSMRMZOfnfHtJQjflK1CgfduXVP4effJTaTZeQg0IMIWiGQjflK1CgfdgJIFeoium2c0otOAqlAkcJWOAsXylq7mHQbftcNIHtqXqMVOGaazsyYX(EqqJFc4O5SmyJV)9vmFrMVYdp2cRY28PxpGG9TvlFrbbaYeokD1JaYziNeJP8viFroFfLIfYAoJIH2VJqGJHidPfnfH)LQjfJTaTZeQgumjCkgobftQhWpw5Rq48nnF)7Ry(kp8ylSkJOwWjmFB1YxuqaGmjm5yFpiOXpbC0CwgSXxrPyHSMZOyO97ip0B60IMIW)KQjfJTaTZeQgumjCkgobfdy(0RhKtIXu(kIViGIfYAoJIr4O0FQcoiY0IMIWihvtkgBbANjunOyHSMZOyYO3FHSMZE9rvuS(OQNfjmftE4XwyLIw0uegFt1KIXwG2zcvdkwiR5mkMm69xiR5SxFuffRpQ6zrctXuvyKasOfTOynqwEjOrr1KMIWunPySfODMq1GIfYAoJIfiVk9agQhWz17aEnNagsXiSscNMAoJIH8LkSeSyIVOmWbzFLxcAu(IYFJPY((Jsj3ukFTZsD9aMaa29nK1CMY3Z6ALPywKWuSa5vPhWq9aoREhWR5eWqArtjnQMum2c0otOAqXcznNrXKAj7xbpBKp0EOkkgdaWY6zrctXKAj7xbpBKp0EOkArtbbunPyHSMZOyaDwPlHbqrXylq7mHQbTOfflzQ5lQ5mQM0ueMQjfJTaTZeQgumjCkgobftNJEPNBKLVI47VP7BRw(kMViZ3p4b247FF15Ox65gz5Ri((ZF6ROuSqwZzum8IKMboYhA)ocTOPKgvtkgBbANjunOyHSMZOyeok9NQGdImfJWkjCAQ5mkgYVjVKX(8LejXh7lKriboqoHTY3r5BA)MQ67b4BsKk(QZrV09vD9tBF)n9uvFpaFtIuXxDo6LUVJ5B47h8aBYumjCkgobfBm5Lm23JejXh)qGYxHW5Roh9splbHq2kArtbbunPySfODMq1GIfYAoJIr4O0FQcoiYumcRKWPPMZOyT)m8P8TZLVH5lNkJQg7Zxn63r8ftF4oXxc8AYumjCkgobftf4Xp0(DKNsF4oX3)(oM8sg77rIK4JF)Q8viFt33)(IccaKr73rEk9H7KmyJV)9ffeaiJ2VJ8u6d3jziNeJP8veFfo)RV433pjHw0uqyunPySfODMq1GIjHtXWjOyvyio2NV)9ffeaidbn(vrtMCcmF)77yYlzSVhjsIp(HaLVc5Roh9spNePIV4330ZctXcznNrXGGg)QOHw0u(LQjfJTaTZeQgumjCkgobftNJEPNBKLVI47VP7BQ7Ry(Mw6(IFFrbbaYO97ipL(WDsgSXxrPyHSMZOyJKrpqJ8aoynfiHPfnLFs1KIXwG2zcvdkMeofdNGIPZrV0ZnYYxr8f5(13)(2Wv(t)a7ziNeJP8veF)LIfYAoJIPcjCag5e9xtilArlkMQcJeqcvtAkct1KIXwG2zcvdkMeofdNGIbbTr(AobmmtyGroLVIGZxHt33)(kMViZ3k6Svz0ZyvDWKmBbANj(2QLViZx5DDYjWYONXQ6GjziheT8TvlFrbbaYKWKJ99GGg)eWrZzzWgFfLIfYAoJIr4O0FQcoiY0IMsAunPySfODMq1GIjHtXWjOynCL)0pWEgYjXykFfX3pjXx87BAuSqwZzumviHdWiNO)AczrlAkiGQjfJTaTZeQguSqwZzum0(DKxfnumcRKWPPMZOyipvSVO97i(wrJV15BdKXJTY3dpgkJMMX(8vQhWpw57a4Ra2x9ap2xvtizFboOVHVqqJ9nmIVHVierOAVV15RQjGSV15lki08DkkMeofdNGIbbn2xrW5BA((3xiOX5As4xDpeMVc57NK47FFL6b8JvpayiR5SO7Rq48v4m(Mw0uqyunPySfODMq1GIfYAoJIrcto23dcA8tahnNrXiSscNMAoJIHq(6eFB)pGW9Da8va7BazFXJTsxlOVGwnDFXeeWKX(8n1mQs57O8nqpWY368vEjSVhaGVsIVHr8va7REGh7BZDDM4le0gPVnNag6BD(satA8DS68DkkMeofdNGIjMViZ3k6Svz0(DecCmezyMTaTZeFB1YxK5R8Uo5eyz0(DecCmezygYbrlFf13)(ImFfZx5HhBHvz8yR01c67FFL31jNalReeWKX(EjJQYqoiA57FFHG2iFnNag6Rq48vmFXxP7BQ7Ry(QA4E)vb8JlvwjiGjJ99sgv5l(9fb(kQVI6RO0IMYVunPySfODMq1GIjHtXWjOyOGaaz0Z4NsF4ojRQqIOVcHZxKZ3)(cbn2xHW5BAuSqwZzuS6sqv1zmTOP8tQMum2c0otOAqXcznNrXiCu6pvbhezkgHvs40uZzuS2ZrP7lwbhezFRZ3giJhBLVhEmugnnJ9L9T9NHpLVKZ3sFu(oa(gq2x8yR01c6ByeFvccyYyF(MmQY3r5BGEGLV15R8syFpaaFLeT99G(oa(IEgRQdM47O8TIoBft8nmIVb6bw(wNVYlH99aa8vs8vSGGqdQkM4BD(IG09faEj(ICPlAMIjHtXWjOyqqBKVMtadZegyKt5Ri48fbP77FFrMVI5BfD2Qm6zSQoysMTaTZeF)7R8Uo5eyz0ZyvDWKmKtIXu(kIVP5RO((3xK5Ry(kp8ylSkJhBLUwqF)7R8Uo5eyzLGaMm23lzuvgYjXykFfXxe4RO0IMcYr1KIXwG2zcvdkMeofdNGIHccaKrpJFk9H7KSQcjI(kIV)03)(cbTr(AobmmtyGroLVcHZxH)13)(kMViZx5HhBHvzB(0RhqW(2QLVOGaazchLU6ra5mKtIXu(kKV)6ROuSqwZzuSKacpbq2i0IMc(MQjfJTaTZeQgumjCkgobfdz(wrNTkJ2VJqGJHidZSfODM47FFjCu6VWipcldTYqojgt5Ri((RV)9fcAJ81CcyyMWaJCkFfbNVI5RW)6R4(IccaKjHjh77bbn(jGJMZYGn(IFF)1xX9v1W9(Rc4hxQSohW6Pk4Gi7l(9TIoBvwNdyHc5argMzlq7mXx87BA(kkflK1CgftNdy9ufCqKPfnf8fvtkgBbANjunOys4umCckMupGFS6badznNfDFfcNVcNX3((3xX8ffeaiRZjNQc1OYQkKi6Ri48vmF)13u3xvd37VkGFCPYO97ip0B6(kQVTA5RQH79xfWpUuz0(DKh6nDFfY308vukwiR5mkgA)oYd9MoTOPiC6unPySfODMq1GIfYAoJILeqeFhWdTFhHIryLeon1Cgfl1eqe99a8vJ(DeFjhR81UY3MWiCYitDovk2izkMeofdNGIryuqaGCsar8Dap0(DKm5ey((3xG5tVEqojgt5Rq(IC5FPfnfHfMQjfJTaTZeQgumjCkgobftmFrbbaYs4KOo7PKhi8JZGn((33k6Svzi3hL(BShA)osMTaTZeFf13)(cbTr(AobmmtyGroLVc5RWPtXcznNrXiCu6VWipcldTOfnfHtJQjfJTaTZeQgumjCkgobfdcAJ81CcyOVcHZxHtpDF)7Ry(ImFrbbaYKWKJ99GGg)eWrZzzWgFB1YxX8vE4Xwyvgp2kDTG((3xuqaGSsqatg77LmQkd24RO(kkflK1Cgfd9mwvhmHw0uegbunPySfODMq1GIjHtXWjOyqqBKVMtadZegyKt5Ri48vmFf(xFf3xuqaGmjm5yFpiOXpbC0CwgSXx877V(kUVQgU3Fva)4sL15awpvbhezFXVVv0zRY6CaluihiYWmBbANj(IFFtZxr9TvlFbMp96b5KymLVI4RWPtXcznNrXiCu6pvbhezArtryegvtkgBbANjunOys4umCckMQH79xfWpUuzchL(lmYJWYqlFfcNViGIfYAoJIr4O0FHrEewgArlAkc)lvtkgBbANjunOys4umCckgkiaqMeMCSVhe04NaoAold24BRw(cbnoxtc)Q7HW8veF)KekwiR5mkMohW6Pk4GitlAkc)tQMum2c0otOAqXKWPy4eumuqaGmjm5yFpiOXpbC0CwgSHIfYAoJIH2VJ8qVPtlAkcJCunPySfODMq1GIjHtXWjOyqqJZ1KWV6EiWxH89tsOyHSMZOyO97iVkAOfnfHX3unPySfODMq1GIjHtXWjOyOGaazjCsuN9uYde(XzWgFB1Y3k6Svzy0mKhHLxsZPMAolZwG2zIVTA5RQH79xfWpUuzchL(lmYJWYqlFfcNVPrXcznNrXiCu6VWipcldTOfnfHXxunPySfODMq1GIjHtXWjOyOGaaz0Z4NsF4ojd5KymLVc5lc8f)((jjuSqwZzum5zkWKMAoJw0uslDQMum2c0otOAqXKWPy4eumPEa)y1dagYAol6(keoFfolSV)9ffeaiJEg)u6d3jziNeJP8viFrGV433pjHIfYAoJIH2VJ8qVPtlAkPjmvtkgBbANjunOys4umCckge0yFfYxH99VVI5le04Cnj8RUhc8veF)KeFB1YxuqaGm6z8tPpCNKvvir0xH8f589VVOGaaz0Z4NsF4ojd5KymLVc5le04Cnj8RUhc8vCF)KeFfLIfYAoJIPZbSEQcoiY0IMsAPr1KIXwG2zcvdkMeofdNGIbbTr(AobmmtyGroLVc5BAPtXcznNrXcOmm(vheYwrlArXKhESfwPOAstryQMum2c0otOAqXcznNrXiCu6pvbhezkgHvs40uZzumnaHMV)qQ23bWxbSV6bESV1KW(IYLaMnFBF79fYaqwPZkFdJ4l6zSQoyIVJYWNYx5Lm2NVhaGVY76KtG5R6oltXKWPy4eum5HhBHvzB(0RhqW((3xuqaGmHJsx9iGCgYjXykFfY3F67FFHG2iFnNag6Rq(ICP77FFrMVI5BfD2Qm6zSQoysMTaTZeF)7R8Uo5eyz0ZyvDWKmKtIXu(kIVP5RO0IMsAunPySfODMq1GIfYAoJIPZbSEQcoiYumcRKWPPMZOyPMar2xfiK9va7RX4XqF7NI9T0JYxuqaakMeofdNGIjp8ylSkBZNE9ac23)(s4O0FHrEewgALRrI4yF((3xX8vmFrbbaYeokD1JaYzWgFB1YxuqaGmjm5yFpiOXpbC0CwgSXxr99VVOGaazchLU6ra5mKtIXu(kIV)0xrPfnfeq1KIXwG2zcvdkwiR5mkgHJsx9iGmfJWkjCAQ5mk2pAeFl9O8va7B0feAP8vgQY323EFdLV6ZNUVnW58vGoB(kG9nKfy07A5RXmX3POys4umCckgY8ffeait4O0vpciNbB8TvlFrbbaYeokD1JaYziNeJP8veFry(2QLVOGaazjCsuN9uYde(XzWgArtbHr1KIXwG2zcvdkwiR5mkMsqatg77LmQIIryLeon1CgflvFx33Fiv7lWb9vjiGjJ95ByeF1VoX3P8Da8Laf47O8nqpWY368vEjSVhaGVssMIjHtXWjOyI5R8Uo5eyzsyYX(EqqJFc4O5SmKtIXu(kKViW3)(kp8ylSkJhBLUwqF)7le0g5R5eWqFfcNVI5l(kDFtDFfZxvd37VkGFCPYkbbmzSVxYOkFXVViWxr9vuFfLw0u(LQjfJTaTZeQguSqwZzumviHdWiNO)AczrXiSscNMAoJI9JvXjnLV15RkKWbyKSVLo77N(b29Da8va7BdKjJSc0Uw(ky6DFTR8LC(Mak19DmFlD2xJdOVaGfiKPys4umCckMy(ImFLhESfwLT5tVEab7BRw(IccaKjCu6QhbKZqojgt5Rq((tFf13)(ImFrbbaYKWKJ99GGg)eWrZzzWgF)7Ry(2Wv(t)a7ziNeJP8veFfoDFB1Y3kGFCLRjHF19id7Ri((jj(kkTOP8tQMum2c0otOAqXcznNrXsci8eazJqXiSscNMAoJILQHCQ)JPwFtci8e47z(2a27(oMVhKWqFRZ3pWagwXSVNsbgqT8Lach7Z3sN9fyGQY32)diCkMeofdNGIjp8ylSkBSeE9ds89VVOGaaz0Z4NsF4ojRQqIOVIGZ30PfnfKJQjfJTaTZeQguSqwZzuSa9sglQ5SxFsqPyewjHttnNrX(rJ4Ra2xzOkF)XulftcNIHtqXqMVOGaazsyYX(EqqJFc4O5SmydTOPGVPAsXylq7mHQbflK1CgftPhse78R05hOj4GLUwumcRKWPPMZOyiC2xeAqv5l5m8P8vgQY3sFu(saHJ95B7)beoftcNIHtqXK31jNaltcto23dcA8tahnNLHCsmMYxr8fb(2QLViZxuqaGmjm5yFpiOXpbC0CwgSHw0uWxunPySfODMq1GIjHtXWjOyQdSJogj3aQkWo)yiytnNLzlq7mX3wT8vDGD0Xiz8UEutNFQRJhBvMTaTZek2yfdHGn1BaOyQdSJogjJ31JA68tDD8yROyJvmec2uVjjHjtumftykwiR5mkgqNv6syauuSXkgcbBQ3x)qJoftyArlArXWJHQ5mAkPLEAclSWPHakMGaAJ9POyi8F8hsb5pfeIip81xn1zFNKMdw(cCqFXh5HhBHvk8XxiJqcCGmXx1LW(gG1Left8vQh2hRYosP2XyFXxip8fH6m8yyXeFXh1b2rhJKtvWhFRZx8rDGD0Xi5uLmBbANj4JVIjCQiA2rk1og7l(c5HViuNHhdlM4l(OoWo6yKCQc(4BD(IpQdSJogjNQKzlq7mbF8nkFr(qim16RycNkIMDKCKq(tAoyXeF)13qwZz(2hvPYosuSaS0pifdBsqO8vCFriZio9HI1apGPZuS25Rg97i(2EokDFriWMp9YrQD(MAcOu33FQTVPLEAP5i5i1oFr(sfwcwmXxug4GSVYlbnkFr5VXuzF)rPKBkLV2zPUEataa7(gYAot57zDTYosHSMZu5gilVe0OWbQ43uCI2wKW4cKxLEad1d4S6DaVMtadDKcznNPYnqwEjOrjoU2av8BkorBgaGL1ZIegNulz)k4zJ8H2dv5ifYAotLBGS8sqJsCCTb0zLUegaLJKJu78f5lvyjyXeFz8yOw(wtc7BPZ(gY6G(okFd8IPhODo7ifYAotHlzmYdaYmYl7ifYAotjoU2sci8eazJO9aGdfeaiJEg)u6d3jziNeJPebb4)tsYCQWsWIB1smuqaGm6z8tPpCNKHCsmMseCqqJZ1KWV6EiOvluqaGm6z8tPpCNKHCsmMseCI9jjIlVRtobwgTFhHahdrgMHCq0c)v0zRYO97ie4yiYWmBbANj4pnrB1cfeaiJEg)u6d3jzvfsef5xr)dbTr(AobmmtyGroLq4slDhPqwZzkXX1Mm69xiR5SxFuL2wKW4sMA(IAotBvbhzHtyThaCvyio2xRwJjVKX(EKij(43VkHs3rkK1CMsCCTH2VJ8aaHAP9aGtExNCcSmjm5yFpiOXpbC0CwgYbrR)IHm5DDYjWYO97ie4yiYWmKdIwTAHSk6Svz0(DecCmezyMTaTZerDKcznNPehxBOmuXqeh7ZrkK1CMsCCTfqzy8RbSRyThaCHSg84hBCYWkHWLwRwqqJfr4)qqBKVMtadZegyKtj0pt3rkK1CMsCCT1Np9s9qObjFjSvApa4qbbaYGM(116PkiBFLEgSXrkK1CMsCCTfMKvfm6pz07osHSMZuIJRnGbYO97iosHSMZuIJRn047DaVcosevosTZxSXKSVLo7BZvZz(kVRtobMV6HYxPEyFmrBFfW4tV7Rslt6RGP09T9)ac3rkK1CMsCCT1C1CM2daouqaGmjm5yFpiOXpbC0CwgSXrkK1CMsCCTbQ43uCIYrkK1CMsCCTbJrXpchehPqwZzkXX1gA)ocbogImu7bahYqbbaYKWKJ99GGg)eWrZzzWM)IHm5HhBHvzB(0RhqWTAHccaKjCu6QhbKZqojgtjeYjQJuiR5mL44AdTFh5HEtx7baNupGFSsiCP9xm5HhBHvze1coH1QfkiaqMeMCSVhe04NaoAold2iQJuiR5mL44AJWrP)ufCqK1EaWbmF61dYjXykrqGJuiR5mL44Atg9(lK1C2RpQsBlsyCYdp2cRuosHSMZuIJRnz07VqwZzV(OkTTiHXPQWibK4i5i1oF1aeA((dPAFhaFfW(Qh4X(wtc7lkxcy28T9T3xidazLoR8nmIVONXQ6Gj(okdFkFLxYyF(Eaa(kVRtobMVQ7SSJuiR5mvwE4XwyLchHJs)Pk4GiR9aGtE4Xwyv2Mp96be8FuqaGmHJsx9iGCgYjXykH(5FiOnYxZjGHcHCP)hzIvrNTkJEgRQdMKzlq7m5V8Uo5eyz0ZyvDWKmKtIXuIKMOosTZ3utGi7RceY(kG91y8yOV9tX(w6r5lkiaGJuiR5mvwE4XwyLsCCTPZbSEQcoiYApa4KhESfwLT5tVEab)NWrP)cJ8iSm0kxJeXX((lMyOGaazchLU6ra5mytRwOGaazsyYX(EqqJFc4O5SmyJO)rbbaYeokD1JaYziNeJPe5NI6i1oF)rJ4BPhLVcyFJUGqlLVYqv(2(27BO8vF(09TboNVc0zZxbSVHSaJExlFnMj(oLJuiR5mvwE4XwyLsCCTr4O0vpciR9aGdzOGaazchLU6ra5mytRwOGaazchLU6ra5mKtIXuIGWA1cfeailHtI6SNsEGWpod24i1oFt13199hs1(cCqFvccyYyF(ggXx9Rt8DkFhaFjqb(okFd0dS8ToFLxc77ba4RKKDKcznNPYYdp2cRuIJRnLGaMm23lzuL2daoXK31jNaltcto23dcA8tahnNLHCsmMsie8xE4Xwyvgp2kDTG)HG2iFnNagkeoXWxPN6IPA4E)vb8JlvwjiGjJ99sgvHFeiQOI6i1oF)XQ4KMY368vfs4ams23sN99t)a7(oa(kG9TbYKrwbAxlFfm9UV2v(soFtaL6(oMVLo7RXb0xaWceYosHSMZuz5HhBHvkXX1MkKWbyKt0FnHS0EaWjgYKhESfwLT5tVEab3QfkiaqMWrPREeqod5KymLq)u0)idfeaitcto23dcA8tahnNLbB(lwdx5p9dSNHCsmMseHtVvRkGFCLRjHF19idlYNKiQJu78nvd5u)htT(Meq4jW3Z8TbS39DmFpiHH(wNVFGbmSIzFpLcmGA5lbeo2NVLo7lWavLVT)hq4osHSMZuz5HhBHvkXX1wsaHNaiBeThaCYdp2cRYglHx)GK)OGaaz0Z4NsF4ojRQqIOi4s3rQD((JgXxbSVYqv((JPwhPqwZzQS8WJTWkL44AlqVKXIAo71NeuThaCidfeaitcto23dcA8tahnNLbBCKANViC2xeAqv5l5m8P8vgQY3sFu(saHJ95B7)beUJuiR5mvwE4XwyLsCCTP0djID(v68d0eCWsxlThaCY76KtGLjHjh77bbn(jGJMZYqojgtjccA1czOGaazsyYX(EqqJFc4O5SmyJJuiR5mvwE4XwyLsCCTb0zLUegaL2dao1b2rhJKBavfyNFmeSPMZA1sDGD0Xiz8UEutNFQRJhBL2Jvmec2uVjjHjtumoH1ESIHqWM691p0OJtyThRyieSPEdao1b2rhJKX76rnD(PUoESvososHSMZu5KPMVOMZWHxK0mWr(q73r0EaWPZrV0ZnYsKFtVvlXq2h8aB(RZrV0ZnYsKF(trDKANVi)M8sg7ZxsKeFSVqgHe4a5e2kFhLVP9BQQVhGVjrQ4Roh9s3x11pT9930tv99a8njsfF15Ox6(oMVHVFWdSj7ifYAotLtMA(IAotCCTr4O0FQcoiYApa4gtEjJ99irs8XpeOecNoh9splbHq2khP25B7pdFkF7C5By(YPYOQX(8vJ(DeFX0hUt8LaVMSJuiR5mvozQ5lQ5mXX1gHJs)Pk4GiR9aGtf4Xp0(DKNsF4o5)yYlzSVhjsIp(9RsO0)JccaKr73rEk9H7KmyZFuqaGmA)oYtPpCNKHCsmMseHZ)I)pjXrkK1CMkNm18f1CM44AdcA8RIgThaCvyio23FuqaGme04xfnzYjW(pM8sg77rIK4JFiqjKoh9spNePc(tplSJuiR5mvozQ5lQ5mXX12iz0d0ipGdwtbsyThaC6C0l9CJSe530tDXslD8JccaKr73rEk9H7KmyJOosHSMZu5KPMVOMZehxBQqchGror)1eYs7baNoh9sp3ilrqUF)3Wv(t)a7ziNeJPe5xhjhPqwZzQSQcJeqcochL(tvWbrw7bahe0g5R5eWWmHbg5uIGt40)lgYQOZwLrpJv1btYSfODM0QfYK31jNalJEgRQdMKHCq0QvluqaGmjm5yFpiOXpbC0CwgSruhPqwZzQSQcJeqI44Atfs4amYj6VMqwApa4A4k)PFG9mKtIXuI8jj4pnhjhP21oFdznNPYQkmsajIJRn0(DecCmezO2daoKHccaKjHjh77bbn(jGJMZYGnosTRD(2EWM(iJIj(QZq2xuwgGk23sN9nzQ5lQ5mF7JQ8fY9Hv(EMVvyio2xBvG4yF(sIK4JZosTRD(gYAotLvvyKasehxBjbeEcGSr0EaWHccaKrpJFk9H7KmKtIXuIGa8)jjzovyjyXTAjgkiaqg9m(P0hUtYqojgtjcoiOX5As4xDpe0Qfkiaqg9m(P0hUtYqojgtjcoX(KeXL31jNalJ2VJqGJHidZqoiAH)k6Svz0(DecCmezyMTaTZe8NMOTAHccaKrpJFk9H7KSQcjIIGar)dbTr(AobmmtyGroLq4slDhjhP25lYtf7lA)oIVv04BD(2az8yR89WJHYOPzSpFL6b8Jv(oa(kG9vpWJ9v1es2xGd6B4le0yFdJ4B4lcreQ27BD(QAci7BD(IccnFNYrkK1CMkRQWibKGdTFh5vrJ2daoiOXIGlT)qqJZ1KWV6EimH(KK)s9a(XQhamK1Cw0fcNWz8TJu78fH81j(2(FaH77a4Ra23aY(IhBLUwqFbTA6(IjiGjJ95BQzuLY3r5BGEGLV15R8syFpaaFLeFdJ4Ra2x9ap23M76mXxiOnsFBobm0368LaM047y157uosHSMZuzvfgjGeXX1gjm5yFpiOXpbC0CM2daoXqwfD2QmA)ocbogImmZwG2zsRwitExNCcSmA)ocbogImmd5GOLO)rMyYdp2cRY4XwPRf8V8Uo5eyzLGaMm23lzuvgYbrR)qqBKVMtadfcNy4R0tDXunCV)Qa(XLkReeWKX(EjJQWpcevurDKcznNPYQkmsajIJRT6sqv1zS2daouqaGm6z8tPpCNKvviruiCi3FiOXcHlnhP21oFdznNPYQkmsajIJRTKacpbq2iApa4edzYdp2cRYglHx)GKwTqbbaYb6LmwuZzV(KGMbBe9VyOGaaz0Z4NsF4ojd5KymLi4GGgNRjHF19qqRwOGaaz0Z4NsF4ojd5KymLi4e7tsexExNCcSmA)ocbogImmd5GOf(ROZwLr73riWXqKHz2c0otWFAI2Qfkiaqg9m(P0hUtYQkKikYVI(hcAJ81CcyyMWaJCkHWLw6osTZ32ZrP7lwbhezFRZ3giJhBLVhEmugnnJ9L9T9NHpLVKZ3sFu(oa(gq2x8yR01c6ByeFvccyYyF(MmQY3r5BGEGLV15R8syFpaaFLeT99G(oa(IEgRQdM47O8TIoBft8nmIVb6bw(wNVYlH99aa8vs8vSGGqdQkM4BD(IG09faEj(ICPlA2rkK1CMkRQWibKioU2iCu6pvbhezThaCqqBKVMtadZegyKtjcoeK(FKjwfD2Qm6zSQoysMTaTZK)Y76KtGLrpJv1btYqojgtjsAI(hzIjp8ylSkJhBLUwW)Y76KtGLvccyYyFVKrvziNeJPebbI6ifYAotLvvyKasehxBjbeEcGSr0EaWHccaKrpJFk9H7KSQcjII8Z)qqBKVMtadZegyKtjeoH)9VyitE4Xwyv2Mp96beCRwOGaazchLU6ra5mKtIXuc9ROosHSMZuzvfgjGeXX1MohW6Pk4GiR9aGdzv0zRYO97ie4yiYWmBbANj)jCu6VWipcldTYqojgtjYV)HG2iFnNagMjmWiNseCIj8VIJccaKjHjh77bbn(jGJMZYGn4)xXvnCV)Qa(XLkRZbSEQcoiY4VIoBvwNdyHc5argMzlq7mb)PjQJuiR5mvwvHrcirCCTH2VJ8qVPR9aGtQhWpw9aGHSMZIUq4eoJV)lgkiaqwNtovfQrLvvirueCI9BQRA4E)vb8JlvgTFh5HEtx0wTunCV)Qa(XLkJ2VJ8qVPluAI6i1oFtnberFpaF1OFhXxYXkFTR8TjmcNmYuNtLIns2rkK1CMkRQWibKioU2sciIVd4H2VJO9aGJWOGaa5KaI47aEO97izYjW(dmF61dYjXykHqU8VosHSMZuzvfgjGeXX1gHJs)fg5ryzOL2daoXqbbaYs4KOo7PKhi8JZGn)ROZwLHCFu6VXEO97iz2c0ote9pe0g5R5eWWmHbg5ucjC6osHSMZuzvfgjGeXX1g6zSQoyI2daoiOnYxZjGHcHt40t)Vyidfeaitcto23dcA8tahnNLbBA1sm5HhBHvz8yR01c(hfeaiReeWKX(EjJQYGnIkQJuiR5mvwvHrcirCCTr4O0FQcoiYApa4GG2iFnNagMjmWiNseCIj8VIJccaKjHjh77bbn(jGJMZYGn4)xXvnCV)Qa(XLkRZbSEQcoiY4VIoBvwNdyHc5argMzlq7mb)PjARwaZNE9GCsmMseHt3rkK1CMkRQWibKioU2iCu6VWipcldT0EaWPA4E)vb8JlvMWrP)cJ8iSm0siCiWrkK1CMkRQWibKioU205awpvbhezThaCOGaazsyYX(EqqJFc4O5SmytRwqqJZ1KWV6Eimr(KehPqwZzQSQcJeqI44AdTFh5HEtx7bahkiaqMeMCSVhe04NaoAold24ifYAotLvvyKasehxBO97iVkA0EaWbbnoxtc)Q7HaH(KehPqwZzQSQcJeqI44AJWrP)cJ8iSm0s7bahkiaqwcNe1zpL8aHFCgSPvRk6Svzy0mKhHLxsZPMAolZwG2zsRwQgU3Fva)4sLjCu6VWipcldTecxAosHSMZuzvfgjGeXX1M8mfystnNP9aGdfeaiJEg)u6d3jziNeJPecb4)tsCKcznNPYQkmsajIJRn0(DKh6nDThaCs9a(XQhamK1Cw0fcNWzH)JccaKrpJFk9H7KmKtIXucHa8)jjosHSMZuzvfgjGeXX1MohW6Pk4GiR9aGdcASqc)xmiOX5As4xDpeiYNK0Qfkiaqg9m(P0hUtYQkKikeY9hfeaiJEg)u6d3jziNeJPeccACUMe(v3dbI)jjI6ifYAotLvvyKasehxBbugg)QdczR0EaWbbTr(AobmmtyGroLqPLoTOfLc]] )

end