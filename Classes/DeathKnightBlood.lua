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


    spec:RegisterPack( "Blood", 20211123, [[d4us9aqiOk9iLKCjsjOnbv6tqvPrbk6uGcRcQQEfbmlsr3cQcTlH(fPudtq1XGkwMGYZaLmnsj5AkPSnOk6BGs14usvDoqPuRtjPsZJG6EGQ9rGoiPKAHeKhskrMOsQCrOkOpQKuXivsvQojufyLkv9ssjqZKuI6MKsO2jH4NkPkLHQKu1svskpfKPsiDvsjGVckfJLuczVi(RunyGdtzXq5XenzKUmQnRkFwPmAs1PLSALufVwPYSLYTvIDt1Vvz4cCCLuLSCipNKPl66QQTtk8Dc14HQIZRKy9GsjZxq2VIj4qeLarTKjIew4HHdo4egSIHHJwT(WchcuUsatGcm5oBJjqUTWeiHA3rjqb2kTZOerjqQ7JKmbcQw(nlRZ1si7LeiSF1s8aNGrGOwYercl8WWbhCcdwXWWrRw)W0kcKkGLercBTWjq6fLYobJarzLKaju7o6awhBP(a0c61MEo7f50GxWy0aWbwAoGWcpmCiqTsLkIOeik)SFljIsebhIOei2nSgtjcrGOSsIQGSoNaHhIpS8NmDaSgmALbK1cpGuNhGjZdnGsnatdRAgwJJeitM15eOLYP9hIzylMKercJikbIDdRXuIqeijQsgvgbc7)ErSZ5UsV4gnI4fRC1aeEaWAa4FaBsAKXhw(tEaHcnayoaS)7fXoN7k9IB0iIxSYvdqy4da9DoM1c3ZRdRbek0aW(Vxe7CUR0lUrJiEXkxnaHHpayoGnjDacma5Dn6j2JyT7Ouu57yueXgDLbG)bKwJ9mI1UJsrLVJrr2nSgtha(hqydagdiuObG9FVi25CxPxCJgvPj3naHhWAdagda3bG(Ej7bNygfP8RKvoabHpGWcNazYSoNaTyi0jgXoLKerGfruce7gwJPeHiqsuLmQmcuA(UY3gqOqdOC5Tu(wNAl2g3xtnabhq4eivIkzsebhcKjZ6CcK0ATUjZ68ERujbQvQS72ctGwQS2SSoNKer0kIOei2nSgtjcrGKOkzuzei5Dn6j2JuZLLV1rFN7Izl48iIn6kda3baZbG3biVRrpXEeRDhLIkFhJIi2ORmGqHgaEhqAn2Ziw7okfv(ogfz3WAmDaWGazYSoNaH1UJ2FF0kKKiYAerjqMmRZjqymsXODLVrGy3WAmLiejjIGNerjqSBynMseIajrvYOYiqMmln4o78sXQbii8be2acfAaOVZdq4bGZaWDaOVxYEWjMrrk)kzLdqWbGNHtGmzwNtGmK0CUh8BkMKerGDIOei2nSgtjcrGKOkzuzeiS)7f)U(1wPRse7BPE8hqGmzwNtGA1MEQ6RNpDBH9KKerwFIOeitM15eiZLSkrwRlTwJaXUH1ykrisseb2MikbYKzDob6vigRDhLaXUH1ykrissebNWjIsGmzwNtGWST(96jQK7uei2nSgtjcrsIi4Gdruce7gwJPeHiqsuLmQmce2)9IuZLLV1rFN7Izl484pGarzLevbzDobcQCjpGuNhqWL15dqExJEI9bOBQbi1nFJPAoaXm(2AdqTIlhG4k1hW6wnydbYKzDobk4Y6CssebNWiIsGmzwNtG(kUxjVOiqSBynMseIKerWbwerjqMmRZjqiRuCNYgLaXUH1ykrissebhTIikbIDdRXuIqeijQsgvgbcVda7)ErQ5YY36OVZDXSfCE8hmaChamhaEhG80GDZZOxB6z)z8acfAay)3lszl1vD6NJiEXkxnabhaSpayqGmzwNtGWA3rPOY3XissebN1iIsGy3WAmLiebsIQKrLrGK6gAJvdqq4diSbG7aG5aKNgSBEg3TcQmFaHcnaS)7fPMllFRJ(o3fZwW5XFWaGbbYKzDobcRDhTJDvJKerWbpjIsGmzwNtGqwP4oLnkbIDdRXuIqKKicoWoruce7gwJPeHiqsuLmQmc0R20ZoIxSYvdq4balcKjZ6CceLTuVRsuTJjjreCwFIOei2nSgtjcrGmzwNtGKwR1nzwN3BLkjqTsLD3wycK80GDZtfjjIGdSnruce7gwJPeHiqMmRZjqsR16MmRZ7TsLeOwPYUBlmbsLMtneLKKKafGy5TGzjruIi4qeLaXUH1ykricKjZ6CcKbBP0nKP6VZZ(96bNygrGOSsIQGSoNaHhIpS8NmDay87q8aK3cMLdaJ3kxfhGwlLCqQgGFoEu3qlVFBaMmRZvd482krcKBlmbYGTu6gYu935z)E9GtmJijrKWiIsGy3WAmLiebYKzDobsUISDj68s2XAMkjq87XYS72ctGKRiBxIoVKDSMPsssebwerjqMmRZjqVgR0Li7Lei2nSgtjcrsssGuP5udrjIsebhIOei2nSgtjcrGKOkzuzei03lzp4eZOiLFLSYbim8bGt4da3baZbG3bKwJ9mIDoRYdTez3WAmDaHcna8oa5Dn6j2JyNZQ8qlreB0vgqOqda7)ErQ5YY36OVZDXSfCE8hmayqGmzwNtGOSL6DvIQDmjjIegruce7gwJPeHiqsuLmQmcuaNXn973IiEXkxnaHhWMKoa8pGWiqMmRZjqktIQxjlR1dmzssIiWIikbIDdRXuIqeitM15eiS2D0EAbeikRKOkiRZjqAbu8aWA3rhqAbdiVbeGynyphWPbJKwqq5BdqQBOnwnG6naX8a0nn4bOcmjpG3HgGna035byoDa2awD0sRBa5navGH4bK3aW(iFavsGKOkzuzei035bim8be2aWDaOVZXSw4EEDTAacoGnjDa4oaPUH2yv)HmzwNBTbii8bGtC9jjreTIikbIDdRXuIqeijQsgvgbcVdiTg7zeRDhLIkFhJISBynMoGqHgaEhG8Ug9e7rS2DukQ8DmkIyJUcbYKzDobIAUS8To67CxmBbNtsIiRreLaXUH1ykricKevjJkJaH9FVi25CxPxCJgvPj3nabHpayFa4oa035bii8begbYKzDobkVfmvEotsIi4jruce7gwJPeHiqsuLmQmce2)9IyNZDLEXnAuLMC3aeEa45aWDaOVxYEWjMrrk)kzLdqq4daN1gaUdaMdaVdqEAWU5z0Rn9S)mEaHcnaS)7fPSL6Qo9ZreVyLRgGGdyTbadcKjZ6Cc0IHqNye7usseb2jIsGy3WAmLiebsIQKrLrGW7asRXEgXA3rPOY3XOi7gwJPda3bqzl17Mt7uwARer8IvUAacpG1gaUda99s2doXmks5xjRCacdFaWCa4S2aeyay)3lsnxw(wh9DUlMTGZJ)GbG)bS2aeyaQaU16PH24uf1zdLDvIQD8aW)asRXEg1zdLyi22XOi7gwJPda)diSbadcKjZ6CcKoBOSRsuTJjjrK1NikbIDdRXuIqeijQsgvgbsQBOnw1FitM15wBaccFa4ex)bG7aG5aW(VxuNxovAQsfvPj3naHHpayoG1gaECaQaU16PH24ufXA3r7yx1gamgqOqdqfWTwpn0gNQiw7oAh7Q2aeCaHnayqGmzwNtGWA3r7yx1ijreyBIOei2nSgtjcrGmzwNtGwm0U(96yT7OeikRKOkiRZjqAXgA3aU3aeQDhDa0JvdWVCabMt5LsIhz8jzNgjqsuLmQmceLX(VxCXq763RJ1UJgPNyFa4oGxTPNDeVyLRgGGda2JRrsIi4eoruce7gwJPeHiqsuLmQmcemha2)9IsuTOoVRK3hTXXFWaWDaP1ypJiUvk9E5DS2D0i7gwJPdagda3bG(Ej7bNygfP8RKvoabhaoHtGmzwNtGOSL6DZPDklTvijreCWHikbIDdRXuIqeijQsgvgbc99s2doXmAaccFa4eE4da3bG3bG9FVi1Cz5BD035Uy2cop(diqMmRZjqyNZQ8qlKKicoHreLaXUH1ykricKevjJkJaH(Ej7bNygfP8RKvoaHHpayoaCwBacmaS)7fPMllFRJ(o3fZwW5XFWaW)awBacmava3A90qBCQI6SHYUkr1oEa4FaP1ypJ6SHsmeB7yuKDdRX0bG)be2aGXacfAaVAtp7iEXkxnaHhaoHtGmzwNtGOSL6DvIQDmjjIGdSiIsGy3WAmLiebsIQKrLrGubCR1tdTXPkszl17Mt7uwARmabHpayrGmzwNtGOSL6DZPDklTvijreC0kIOei2nSgtjcrGKOkzuzeiS)7fPMllFRJ(o3fZwW5XFWacfAaOVZXSw4EEDTAacpGnjLazYSoNaPZgk7Qev7yssebN1iIsGy3WAmLiebsIQKrLrGW(VxKAUS8To67CxmBbNh)beitM15eiS2D0o2vnssebh8KikbIDdRXuIqeijQsgvgbc9DoM1c3ZRdRbi4a2KucKjZ6Ccew7oApTassebhyNikbIDdRXuIqeijQsgvgbc7)ErjQwuN3vY7J244pyaHcnG0ASNrKfu0oLL3sWPQSopYUH1y6acfAaQaU16PH24ufPSL6DZPDklTvgGGWhqyeitM15eikBPE3CANYsBfssebN1NikbIDdRXuIqeijQsgvgbc7)ErSZ5UsV4gnI4fRC1aeCaWAa4FaBskbYKzDobsEU6VeK15KKicoW2erjqSBynMseIajrvYOYiqsDdTXQ(dzYSo3Adqq4daNioda3bG9FVi25CxPxCJgr8IvUAacoayna8pGnjLazYSoNaH1UJ2XUQrsIiHforuce7gwJPeHiqsuLmQmce678aeCa4maChamha67CmRfUNxhwdq4bSjPdiuObG9FVi25CxPxCJgvPj3nabhaSpaCha2)9IyNZDLEXnAeXlw5Qbi4aqFNJzTW986WAacmGnjDaWGazYSoNaPZgk7Qev7yssejmCiIsGy3WAmLiebsIQKrLrGqFVK9GtmJIu(vYkhGGdiSWjqMmRZjqgsAo3ZdHypjjjjqlvwBwwNteLicoerjqSBynMseIajrvYOYiq6S1s9yGmhGWdyTWhqOqdaMdaVdydD)GbG7a0zRL6XazoaHhaEINdageitM15einSLGcvYow7okjjIegruce7gwJPeHiqMmRZjqu2s9Ukr1oMarzLevbzDobcpWL3s5BdGAl2gpaeVE9leVWEoGsnGWwtlCa3Balg(maD2AP(aux70CaRfUw4aU3awm8za6S1s9bu(aSbSHUFqKajrvYOYiqLlVLY36uBX24oSudqq4dqNTwQhLFeI9KKerGfruce7gwJPeHiqMmRZjqu2s9Ukr1oMarzLevbzDobADNJV5aACoaZhaJpLklFBac1UJoai9IB0bqrxqKajrvYOYiqktdUJ1UJ2v6f3Oda3buU8wkFRtTfBJ7RPgGGdi8bG7aW(VxeRDhTR0lUrJ)GbG7aW(VxeRDhTR0lUrJiEXkxnaHhaoX1ga(hWMKssIiAfruce7gwJPeHiqsuLmQmcuA(UY3gaUda7)Er035EAbr6j2haUdOC5Tu(wNAl2g3HLAacoaD2APECXWNbG)beEehcKjZ6Cce67CpTasseznIOei2nSgtjcrGKOkzuzeiD2APEmqMdq4bSw4dapoayoGWcFa4Fay)3lI1UJ2v6f3OXFWaGbbYKzDobQKm29DA)DOSYpLjjre8KikbIDdRXuIqeijQsgvgbsNTwQhdK5aeEaW(Ada3beWzCt)(TiIxSYvdq4bSgbYKzDobszsu9kzzTEGjtssscK80GDZtfruIi4qeLaXUH1ykricKjZ6CceLTuVRsuTJjquwjrvqwNtGe6J8bSAR(buVbiMhGUPbpGSw4bGXPyM9bSU1nae)qSsNveijQsgvgbsEAWU5z0Rn9S)mEa4oaS)7fPSL6Qo9ZreVyLRgGGdaphaUda99s2doXmAacoaypCssejmIOei2nSgtjcrGmzwNtG0zdLDvIQDmbIYkjQcY6CcKwSTJhG6J4biMhGZAWOb0ofpGu3YbG9FpcKevjJkJajpny38m61ME2FgpaChaLTuVBoTtzPTsml5UY3gaUdaMdaMda7)ErkBPUQt)C8hmGqHga2)9IuZLLV1rFN7Izl484pyaWya4oaS)7fPSL6Qo9ZreVyLRgGWdaphamijreyreLaXUH1ykricKjZ6CceLTux1PFMarzLevbzDobsRD6asDlhGyEawtSTIAastLdyDRBaMAa61M(acq1naX6SpaX8amz(TwBLb4mthqLeijQsgvgbcVda7)ErkBPUQt)C8hmGqHga2)9Iu2sDvN(5iIxSYvdq4bOvdiuObG9FVOevlQZ7k59rBC8hqsIiAfruce7gwJPeHiqMmRZjqktIQxjlR1dmzsGOSsIQGSoNaP1zYlb5aYBaktIQxj5bK68a20VFBa1BaI5beGyAjtdRTYaexT2a8lha9gWYxQpGYhqQZdWzdnG3p)iMajrvYOYiqWCa4DaYtd2npJETPN9NXdiuObG9FViLTux1PFoI4fRC1aeCa45aGXaWDa4Day)3lsnxw(wh9DUlMTGZJ)GbG7aG5ac4mUPF)weXlw5Qbi8aWj8bek0asdTXzmRfUNxNw8aeEaBs6aGbjjISgruce7gwJPeHiqMmRZjqu2s9Ukr1oMarzLevbzDobsOpYhWQT6hW9Edy98v5aW43H4bOeBOLY3gG8wy1aWm5UbCV3a0sRJajrvYOYiqYtd2npJAWEQVcAa4oa03lzp4eZObi4aG9WhaUdqExJEI9OsSHwkFRVuQmI4fRC1aeEaWIKerWtIOei2nSgtjcrGmzwNtGuIn0s5B9LsLeikRKOkiRZjqATthGsSHwkFBaMAaTZ3gGPgGygFr8a8lhGWdawQbCV3aw3QbBiqsuLmQmceEha2)9IuZLLV1rFN7Izl484pGKerGDIOei2nSgtjcrGmzwNtGwme6eJyNsGOSsIQGSoNaT6rmEuR1YdyXqOt8aoFab)wBaLpGdrz0aYBaBFdzEY8aoL6BOvga9JkFBaPopGxHu5aw3QbBiqsuLmQmcK80GDZZOZs01oeDa4oaS)7fXoN7k9IB0Okn5Ubim8beojjIS(erjqSBynMseIazYSoNazy3s5wwN3B1cgbIYkjQcY6CcKw70biMhG0u5a0ATmbsIQKrLrGW7aW(VxKAUS8To67CxmBbNh)bKKicSnruce7gwJPeHiqMmRZjqkDtURX9uN7Fx8Hs9viquwjrvqwNtGGn8awpFvoa654BoaPPYbK6LAa0pQ8TbSUvd2qGKOkzuzei5Dn6j2JuZLLV1rFN7Izl48iIxSYvdq4baRbek0aW7aW(VxKAUS8To67CxmBbNh)bKKicoHteLaXUH1ykricKevjJkJaPUFdRCAm4RYFJ7m6hK15r2nSgthqOqdqD)gw50OgxZYQXD110G9mYUH1ykbQ8KrOFq2RhbsD)gw50OgxZYQXD110G9KavEYi0pi71YctllzceoeitM15eOxJv6sK9scu5jJq)GSV1omRrGWHKKKKeinyKQoNisyHhgoHd7HVgbsSH8Y3ueiyJwVAIGhiYQZQ7agGO68aQLGdLd4DObGVYtd2npv47aq861VqmDaQBHhG9ZBXsMoaPU5BSko71YLZdaNWxDhGw6CnyuY0bGVQ73WkNg1IW3bK3aWx19ByLtJArr2nSgtX3batCWhyeN9A5Y5bGt4RUdqlDUgmkz6aWx19ByLtJAr47aYBa4R6(nSYPrTOi7gwJP47aSCa4HR30YdaM4GpWio7N94blbhkz6awBaMmRZhqRuPko7jq2p1pebcQw0sdqGbSEN3vTIafGUx1yc0QgGqT7OdyDSL6dqlOxB65SFvdqKtdEbJrdahyP5acl8WWz2p7x1aWdXhw(tMoam(DiEaYBbZYbGXBLRIdqRLsoivdWphpQBOL3VnatM15QbCEBL4S3KzDUkgGy5TGzj8VI7vYlA62cd3GTu6gYu935z)E9GtmJM9MmRZvXaelVfmlfaU2Ff3RKx0KFpwMD3wy4YvKTlrNxYowZu5S3KzDUkgGy5TGzPaW1(1yLUezVC2p7x1aWdXhw(tMoawdgTYaYAHhqQZdWK5HgqPgGPHvndRXXzVjZ6Cf8LYP9hIzylE2BYSoxjaCTxme6eJyNQz9GJ9FVi25CxPxCJgr8IvUsyyH)njnY4dl)jhkemX(Vxe7CUR0lUrJiEXkxjmC035ywlCpVoScfc7)ErSZ5UsV4gnI4fRCLWWH5MKkG8Ug9e7rS2DukQ8DmkIyJUc(tRXEgXA3rPOY3XOi7gwJP4pmyeke2)9IyNZDLEXnAuLMCNWRbdCrFVK9GtmJIu(vYkfeEyHp7nzwNReaU2sR16MmRZ7TsLA62cdFPYAZY6CnvjQKjCC0SEWtZ3v(wOqLlVLY36uBX24(AkbdF2BYSoxjaCTXA3r7VpAfnRhC5Dn6j2JuZLLV1rFN7Izl48iIn6k4ct8kVRrpXEeRDhLIkFhJIi2ORekeEtRXEgXA3rPOY3XOi7gwJPWy2BYSoxjaCTXyKIr7kFB2BYSoxjaCTnK0CUh8BkwZ6b3KzPb3zNxkwji8Wcfc9DwyCWf99s2doXmks5xjRuq8m8zVjZ6CLaW1UvB6PQVE(0Tf2tnRhCS)7f)U(1wPRse7BPE8hm7nzwNReaU2MlzvISwxAT2S3KzDUsa4A)keJ1UJo7nzwNReaU2y2w)E9evYDQz)Qgau5sEaPopGGlRZhG8Ug9e7dq3udqQB(gt1CaIz8T1gGAfxoaXvQpG1TAWMzVjZ6CLaW1o4Y6CnRhCS)7fPMllFRJ(o3fZwW5XFWS3KzDUsa4A)vCVsErn7nzwNReaU2iRuCNYgD2BYSoxjaCTXA3rPOY3XinRhC8I9FVi1Cz5BD035Uy2cop(dWfM4vEAWU5z0Rn9S)mouiS)7fPSL6Qo9ZreVyLRee2HXS3KzDUsa4AJ1UJ2XUQPz9Gl1n0gReeEy4ct5Pb7MNXDRGkZdfc7)ErQ5YY36OVZDXSfCE8haJzVjZ6CLaW1gzLI7u2OZEtM15kbGRnLTuVRsuTJ1SEWF1ME2r8IvUsyyn7nzwNReaU2sR16MmRZ7TsLA62cdxEAWU5PA2BYSoxjaCTLwR1nzwN3BLk10TfgUknNAi6SF2VQbi0h5dy1w9dOEdqmpaDtdEazTWdaJtXm7dyDRBai(HyLoRM9MmRZvr5Pb7MNk4u2s9Ukr1owZ6bxEAWU5z0Rn9S)mgxS)7fPSL6Qo9ZreVyLReepXf99s2doXmsqyp8z)QgGwSTJhG6J4biMhGZAWOb0ofpGu3YbG9FVzVjZ6CvuEAWU5Psa4ARZgk7Qev7ynRhC5Pb7MNrV20Z(ZyCPSL6DZPDklTvIzj3v(gUWeMy)3lszl1vD6NJ)GqHW(VxKAUS8To67CxmBbNh)bWaxS)7fPSL6Qo9ZreVyLRegpHXSFvdqRD6asDlhGyEawtSTIAastLdyDRBaMAa61M(acq1naX6SpaX8amz(TwBLb4mthqLZEtM15QO80GDZtLaW1MYwQR60pRz9GJxS)7fPSL6Qo9ZXFqOqy)3lszl1vD6NJiEXkxjSwfke2)9IsuTOoVRK3hTXXFWSFvdqRZKxcYbK3auMevVsYdi15bSPF)2aQ3aeZdiaX0sMgwBLbiUATb4xoa6nGLVuFaLpGuNhGZgAaVF(r8S3KzDUkkpny38ujaCTvMevVswwRhyYuZ6bhM4vEAWU5z0Rn9S)mouiS)7fPSL6Qo9ZreVyLReepHbU4f7)ErQ5YY36OVZDXSfCE8hGlmd4mUPF)weXlw5kHXj8qHsdTXzmRfUNxNwSWBskmM9RAac9r(awTv)aU3BaRNVkhag)oepaLydTu(2aK3cRgaMj3nG79gGwADZEtM15QO80GDZtLaW1MYwQ3vjQ2XAwp4Ytd2npJAWEQVccx03lzp4eZibH9WXvExJEI9OsSHwkFRVuQmI4fRCLWWA2VQbO1oDakXgAP8TbyQb0oFBaMAaIz8fXdWVCacpayPgW9EdyDRgSz2BYSoxfLNgSBEQeaU2kXgAP8T(sPsnRhC8I9FVi1Cz5BD035Uy2cop(dM9RAaREeJh1AT8awme6epGZhqWV1gq5d4qugnG8gW23qMNmpGtP(gALbq)OY3gqQZd4vivoG1TAWMzVjZ6CvuEAWU5Psa4AVyi0jgXovZ6bxEAWU5z0zj6AhIIl2)9IyNZDLEXnAuLMCNWWdF2VQbO1oDaI5binvoaTwlp7nzwNRIYtd2npvcaxBd7wk3Y68ERwW0SEWXl2)9IuZLLV1rFN7Izl484py2VQbaB4bSE(QCa0ZX3CastLdi1l1aOFu5BdyDRgSz2BYSoxfLNgSBEQeaU2kDtURX9uN7Fx8Hs9v0SEWL31ONypsnxw(wh9DUlMTGZJiEXkxjmScfcVy)3lsnxw(wh9DUlMTGZJ)GzVjZ6CvuEAWU5Psa4A)ASsxISxQz9GRUFdRCAm4RYFJ7m6hK15HcPUFdRCAuJRzz14U6AAWEQz5jJq)GSxllmTSKHJJMLNmc9dY(w7WSgCC0S8KrOFq2RhC19ByLtJACnlRg3vxtd2Zz)S3KzDUkUuzTzzDoCnSLGcvYow7oQM1dUoBTupgitHxl8qHGjE3q3paxD2APEmqMcJN4jmM9RAa4bU8wkFBauBX24bG41RFH4f2ZbuQbe2AAHd4EdyXWNbOZwl1hG6ANMdyTW1chW9gWIHpdqNTwQpGYhGnGn09dIZEtM15Q4sL1ML15caxBkBPExLOAhRz9GxU8wkFRtTfBJ7WsjiCD2APEu(ri2Zz)QgW6ohFZb04CaMpagFkvw(2aeQDhDaq6f3OdGIUG4S3KzDUkUuzTzzDUaW1MYwQ3vjQ2XAwp4ktdUJ1UJ2v6f3O4wU8wkFRtTfBJ7RPemCCX(VxeRDhTR0lUrJ)aCX(VxeRDhTR0lUrJiEXkxjmoX1W)MKo7nzwNRIlvwBwwNlaCTrFN7PfOz9GNMVR8nCX(Vxe9DUNwqKEIDClxElLV1P2ITXDyPeuNTwQhxm8b)HhXz2BYSoxfxQS2SSoxa4Axsg7(oT)ouw5NYAwp46S1s9yGmfETWXJWmSWXp2)9IyT7ODLEXnA8haJzVjZ6CvCPYAZY6CbGRTYKO6vYYA9atMAwp46S1s9yGmfg2xd3aoJB63Vfr8IvUs41M9ZEtM15QOknNAikCkBPExLOAhRz9GJ(Ej7bNygfP8RKvkmCCchxyI30ASNrSZzvEOLi7gwJPHcHx5Dn6j2JyNZQ8qlreB0vcfc7)ErQ5YY36OVZDXSfCE8haJzVjZ6CvuLMtneva4ARmjQELSSwpWKPM1dEaNXn973IiEXkxj8MKI)WM9Z(vTQbyYSoxfvP5udrfaU2yT7Ouu57yKM1doEX(VxKAUS8To67CxmBbNh)bZ(vTQbSUFqRKwY0bOZiEayS0(kEaPopGLkRnlRZhqRu5aqCRy1aoFaP57kFt702v(2aO2ITXXz)Qw1amzwNRIQ0CQHOcax7fdHoXi2PAwp4y)3lIDo3v6f3OreVyLRegw4FtsJm(WYFYHcbtS)7fXoN7k9IB0iIxSYvcdh9DoM1c3ZRdRqHW(Vxe7CUR0lUrJiEXkxjmCyUjPciVRrpXEeRDhLIkFhJIi2ORG)0ASNrS2DukQ8DmkYUH1yk(ddgHcH9FVi25CxPxCJgvPj3jmSGbUOVxYEWjMrrk)kzLccpSWN9Z(vnaTakEayT7OdiTGbK3acqSgSNd40GrsliO8Tbi1n0gRgq9gGyEa6Mg8aubMKhW7qdWga678amNoaBaRoAP1nG8gGkWq8aYBayFKpGkN9MmRZvrvAo1qu4yT7O90c0SEWrFNfgEy4I(ohZAH7511kb3KuCL6gAJv9hYKzDU1eeooX1F2BYSoxfvP5udrfaU2uZLLV1rFN7Izl4CnRhC8MwJ9mI1UJsrLVJrr2nSgtdfcVY7A0tShXA3rPOY3XOiIn6kZEtM15QOknNAiQaW1oVfmvEoRz9GJ9FVi25CxPxCJgvPj3jiCyhx03zbHh2SFvRAaMmRZvrvAo1qubGR9IHqNye7unRhCyIx5Pb7MNrNLORDiAOqy)3lAy3s5wwN3B1cw8hadCHj2)9IyNZDLEXnAeXlw5kHHJ(ohZAH751HvOqy)3lIDo3v6f3OreVyLRegom3KubK31ONypI1UJsrLVJrreB0vWFAn2Ziw7okfv(ogfz3WAmf)HbJqHW(Vxe7CUR0lUrJQ0K7eEnyGl67LShCIzuKYVswPGWdl8z)Qw1amzwNRIQ0CQHOcaxBkBPExLOAhRz9GJ(Ej7bNygfP8RKvkmCyp8zVjZ6CvuLMtneva4AVyi0jgXovZ6bh7)ErSZ5UsV4gnQstUty8ex03lzp4eZOiLFLSsbHJZA4ct8kpny38m61ME2Fghke2)9Iu2sDvN(5iIxSYvcUgmM9MmRZvrvAo1qubGRToBOSRsuTJ1SEWXBAn2Ziw7okfv(ogfz3WAmfxkBPE3CANYsBLiIxSYvcVgUOVxYEWjMrrk)kzLcdhM4SMay)3lsnxw(wh9DUlMTGZJ)a8VMaQaU16PH24uf1zdLDvIQDm(tRXEg1zdLyi22XOi7gwJP4pmym7nzwNRIQ0CQHOcaxBS2D0o2vnnRhCPUH2yv)HmzwNBnbHJtC9XfMy)3lQZlNknvPIQ0K7egomxdpQc4wRNgAJtveRDhTJDvdgHcPc4wRNgAJtveRDhTJDvtWWGXSFvdql2q7gW9gGqT7OdGESAa(LdiWCkVus8iJpj704S3KzDUkQsZPgIkaCTxm0U(96yT7OAwp4ug7)EXfdTRFVow7oAKEIDCF1ME2r8IvUsqypU2S3KzDUkQsZPgIkaCTPSL6DZPDklTv0SEWHj2)9IsuTOoVRK3hTXXFaUP1ypJiUvk9E5DS2D0i7gwJPWax03lzp4eZOiLFLSsbXj8zVjZ6CvuLMtneva4AJDoRYdTOz9GJ(Ej7bNygjiCCcpCCXl2)9IuZLLV1rFN7Izl484py2BYSoxfvP5udrfaU2u2s9Ukr1owZ6bh99s2doXmks5xjRuy4WeN1ea7)ErQ5YY36OVZDXSfCE8hG)1eqfWTwpn0gNQOoBOSRsuTJXFAn2ZOoBOedX2ogfz3WAmf)HbJqHE1ME2r8IvUsyCcF2BYSoxfvP5udrfaU2u2s9U50oLL2kAwp4QaU16PH24ufPSL6DZPDklTveeoSM9MmRZvrvAo1qubGRToBOSRsuTJ1SEWX(VxKAUS8To67CxmBbNh)bHcH(ohZAH7511kH3K0zVjZ6CvuLMtneva4AJ1UJ2XUQPz9GJ9FVi1Cz5BD035Uy2cop(dM9MmRZvrvAo1qubGRnw7oApTanRhC035ywlCpVoSeCtsN9MmRZvrvAo1qubGRnLTuVBoTtzPTIM1do2)9IsuTOoVRK3hTXXFqOqP1ypJilOODklVLGtvzDEKDdRX0qHubCR1tdTXPkszl17Mt7uwARii8WM9MmRZvrvAo1qubGRT8C1FjiRZ1SEWX(Vxe7CUR0lUrJiEXkxjiSW)MKo7nzwNRIQ0CQHOcaxBS2D0o2vnnRhCPUH2yv)HmzwNBnbHJtehCX(Vxe7CUR0lUrJiEXkxjiSW)MKo7nzwNRIQ0CQHOcaxBD2qzxLOAhRz9GJ(olio4ct035ywlCpVoSeEtsdfc7)ErSZ5UsV4gnQstUtqyhxS)7fXoN7k9IB0iIxSYvcI(ohZAH751HLaBskmM9MmRZvrvAo1qubGRTHKMZ98qi2tnRhC03lzp4eZOiLFLSsbdlCssscba]] )

end