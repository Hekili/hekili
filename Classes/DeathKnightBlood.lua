-- DeathKnightBlood.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR
local FindUnitDebuffByID = ns.FindUnitDebuffByID


if UnitClassBase( 'player' ) == 'DEATHKNIGHT' then
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
            if k == 'actual' then
                local amount = 0

                for i = 1, 6 do
                    if t.expiry[ i ] <= state.query_time then
                        amount = amount + 1
                    end
                end

                return amount

            elseif k == 'current' then
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
            
            elseif k == 'deficit' then
                return t.max - t.current            

            elseif k == 'time_to_next' then
                return t[ 'time_to_' .. t.current + 1 ]

            elseif k == 'time_to_max' then
                return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

            elseif k == 'add' then
                return t.gain

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.RunicPower )

    local spendHook = function( amt, resource )
        if amt > 0 and resource == "runic_power" and talent.red_thirst.enabled then
            cooldown.vampiric_blood.expires = max( 0, cooldown.vampiric_blood.expires - amt / 10 )
        elseif resource == "rune" and amt > 0 and active_dot.shackle_the_unworthy > 0 then
            reduceCooldown( "shackle_the_unworthy", 4 )
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
        ossuary = 22134, -- 219786
        relish_in_blood = 22135, -- 317610

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
            duration = function () return ( legendary.deaths_embrace.enabled and 2 or 1 ) * ( ( azerite.runic_barrier.enabled and 1 or 0 ) + ( talent.antimagic_barrier.enabled and 7 or 5 ) ) end,
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
        wraith_walk = {
            id = 212552,
            duration = 4,
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
        --[[ local control_expires = action.control_undead.lastCast + 300
        if control_expires > now and pet.up then
            summonPet( "controlled_undead", control_expires - now )
        end ]]
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
                    active_Dot.frost_fever = active_enemies

                    applyDebuff( "target", "virulent_plague" )
                    active_dot.virulent_plague = active_enemies
                end
            end,
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

            handler = function () end
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

            noOverride = "deaths_due",

            handler = function ()
                removeBuff( "crimson_scourge" )

                if legendary.phearomones.enabled and buff.death_and_decay.down then
                    stat.haste = stat.haste + 0.1
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
            charges = function () return pvptalent.unholy_command.enabled and 2 or 1 end,
            cooldown = 15,
            recharge = 15,
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
            end,
        },


        death_strike = {
            id = 49998,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( talent.ossuary.enabled and buff.bone_shield.stack >= 5 ) and 40 or 45 end,
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
            end,
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
            cooldown = function ()
                if azerite.cold_hearted.enabled then return 165 end
                return 180
            end,
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
            end,
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

            spend = 0,
            spendType = "runic_power",

            startsCombat = true,
            texture = 237527,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
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
            charges = 2,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 237529,

            talent = "rune_tap",

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
                    stat.haste = stat.haste + 0.1
                end

                applyBuff( "death_and_decay" )
                setCooldown( "death_and_decay", 15 )

                applyBuff( "deaths_due_buff" )
                applyDebuff( "target", "deaths_due_debuff" )
                -- Note:  Debuff is actually a buff on the target...
            end,
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
            end,
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


    spec:RegisterPack( "Blood", 20200826.1, [[dG0gNaqiaPhbi6skcfBsr0NOur1OiuCkcPwfHsVcqnlcQBbiyxs5xqPggbCmOWYGIEgLknncKUgHQTrG6BkcACkc5CacToce6DeiQMhH4EkQ9rqoiLkyHQsEiLk0ePurUibcAKeikNKarwjLYlveQANQsDufHkpvHPQi9vkvuSxL(lvnykomPfRQEmstg0LrTzO6ZamAvXPLSAce41qjZMk3wQA3I(TkdNsooLkkTCipNOPlCDG2oHKVlvA8kcCEkvTEfHsZxQy)iEXyNUdOg8(gtbWuabMimfCtaGO4yI5eUJWElEhwkflfaVJu75D8YDhChwQ9UtH70DipqeL3XO6bDAuxAhrkESJpy5cbPC)7aQbVVXuamfqGjctb3eaikoMyk4DiTy6(gtXfyhpfeY5(3bKL0DaKeZl3DqIXoXA8qmt8zb4ji2asIXoacaugedMcwyIbtbWuaInInGKySJpAcGLcIeBajXaeiMjoWIIfXOjKyGfkSNyaTGAWeZHtmVWTdetCeZ4rHxxNMqzBhUsgYD6oyPKtkl3P7Bm2P7Gt97y4(AhuufmQ0DaVOrVKYzG0GHECN2Z(pikBiUxRusmIqmysmtsmaLy(G44nOM0kb4rGj77YQ1LnqRDO0OUCh0lPCginyOh3P98g7Bm3P7Gt97y4(AhuufmQ0D8bXXBIs7Tkur9F3DWgOfXmjXigIbPf0ZIIZOPqOSXtqjdjX0PdXG0c6zrXz0uiu2QKyeIyWqCIr07qPrD5o0S6v)H7HSgpBSVT7oDhCQFhd3x7GIQGrLUdeyYTO6zFCEmigHigauiXmjXGaZI6TUUmIyeHyeub2HsJ6YD0Z9hYE)H7DG0c6Hiw7LBSVf0D6ouAuxUJUhYbffxPhXYl1KY7Gt97y4(AJ9T470DWP(DmCFTdkQcgv6oakX8bXXBqnPvcWJat23LvRlBGw7qPrD5oqLLLJ9v6LwkL3yJDazCf0f709ng70DO0OUCh9vc94iMNy5DWP(DmCFTX(gZD6o4u)ogUV2bfvbJkDh07CWRB2GAsReGhbMSVlRwx2qScTNyMKyedXauIHENdEDZ23DheIQelg1qScTNy60HyakXeQJZO9D3bHOkXIrno1VJHeJO3HsJ6YD8D3b94Gi73yFB3D6ouAuxUJpJKmcRkbSdo1VJH7Rn23c6oDhCQFhd3x7GIQGrLUdLgLOypNCFXsIrOzIbtIPthIbbMmXicXGbXmjXGaZI6TUUmQbz8IwbXieXiyb2HsJ6YDOiQMS3c0j5n23IVt3bN63XW91oOOkyuP74dIJ3aZNZzVxgiobepnqRDO0OUChUcWti9ccaHa65m2yFl4D6ouAuxUdnPSmqQZtvNBhCQFhd3xBSVNWD6ouAuxUd8cXF3DWDWP(DmCFTX(EI2P7qPrD5o(ka)H7durXsUdo1VJH7Rn23aXD6o4u)ogUV2bfvbJkDh07CWRB2GAsReGhbMSVlRwx2qCVwPKyeIyaIcSdLg1L7auY(k4E5g7BmeyNUdo1VJH7RDqrvWOs3XhehVb1KwjapcmzFxwTUSbATdLg1L7W6I6Yn23yGXoDhCQFhd3x7GIQGrLUdeyYYwu9SpopgeJqedakChknQl3X3Dh0hQ1g7BmWCNUdo1VJH7RDqrvWOs3XhehV9VK9YNIDWMmukweJqZeZeUdLg1L7iU(VmUK3yFJHD3P7Gt97y4(AhuufmQ0DGaZI6TUUmQbz8IwbXieXiyIrSeJsJsuSNtUVy5ouAuxUdzxf1xjaFFjJn23yiO70DWP(DmCFTdkQcgv6oakXyXrtDLO4DO0OUChiTKShYkCJ9ngIVt3bN63XW91oOOkyuP7aOetOooJ23DheIQelg14u)ogsmD6qmaLyO35Gx3S9D3bHOkXIrneRq73HsJ6YDa1KwjapcmzFxwTUCJ9ngcENUdLg1L7q)xFLAux6Dv)FhCQFhd3xBSVXyc3P7Gt97y4(AhuufmQ0Duj96ReGhQ9ka2lUKyeIyeyhknQl3bvDoVsJ6sVRKXoCLm8P2Z7OVIcGg1LBSVXyI2P7Gt97y4(AhknQl3bvDoVsJ6sVRKXoCLm8P2Z7GLsoPSCJ9ngaXD6o4u)ogUV2HsJ6YDqvNZR0OU07kzSdxjdFQ98oKHMqfb3yJDyHy61)1yNUVXyNUdo1VJH7Rn23yUt3bN63XW91g7B7Ut3bN63XW91g7BbDNUdo1VJH7Rn23IVt3HsJ6YDyDrD5o4u)ogUV2yJD0xrbqJ6YD6(gJD6o4u)ogUV2bfvbJkDhpS6INMfnigrigXfGy60HyedXauIba6aTiMjjMhwDXtZIgeJieJGfmXi6DO0OUChIs7Tkur9F3DWn23yUt3bN63XW91oOOkyuP7Os61xjapu7vaS3UsIrOzI5Hvx80OGieNXouAuxUdiRXJxgOclEJ9TD3P7Gt97y4(AhuufmQ0DivrX(V7oOx(uSdsmtsmvsV(kb4HAVcG9IljgHigbiMjjMpioE77Ud6Lpf7GnqlIzsI5dIJ3(U7GE5tXoydX9ALsIreIbJM4eJyjgau4ouAuxUdiRXJxgOclEJ9TGUt3bN63XW91oOOkyuP74Hvx80SObXicXiUaedqGyedXGPaeJyjMpioE77Ud6Lpf7GnqlIr07qPrD5okk)pWe6XpuubiK3yFl(oDhCQFhd3x7GIQGrLUJhwDXtZIgeJieZekoXmjXyXrdWZb6AiUxRusmIqmIVdLg1L7qQuuHx0sDElLgBSXoKHMqfb3P7Bm2P7Gt97y4(AhuufmQ0DGaZI6TUUmQbz8IwbXiYmXGHaeZKeJyigGsmH64mA)lzzCO(gN63XqIPthIbOed9oh86MT)LSmouFdXk0EIPthI5dIJ3GAsReGhbMSVlRwx2aTigrVdLg1L7aYA84LbQWI3yFJ5oDhCQFhd3x7GIQGrLUdloAaEoqxdX9ALsIreIbafsmILyWChknQl3HuPOcVOL68wkn2yFB3D6o4u)ogUV2bfvbJkDhaLy(G44nOM0kb4rGj77YQ1LnqRDO0OUChF3DqiQsSy0g7BbDNUdo1VJH7RDqrvWOs3XhehV9VK9YNIDWgI71kLeJiedgnXjgXsmaOWgpbmfmyIPthIrmeZhehV9VK9YNIDWgI71kLeJiZedcm5wu9SpoVDjMoDiMpioE7Fj7Lpf7Gne3RvkjgrMjgXqmaOqIbyIHENdEDZ23DheIQelg1qScTNyelXeQJZO9D3bHOkXIrno1VJHeJyjgmjgrtmD6qmFqC82)s2lFk2bBYqPyrmIqm2LyenXmjXGaZI6TUUmQbz8IwbXi0mXGPa7qPrD5o6ve66I4eUX(w8D6o4u)ogUV2bfvbJkDhighXYh974DO0OUChYhLILJ9Xd7bZUhkESFJ9TG3P7Gt97y4(AhuufmQ0DauI5dIJ3GAsReGhbMSVlRwx2aT2HsJ6YD8Wkk8SuYjL3yFpH70DWP(DmCFTdkQcgv6oOpkcal94iLg1LQJyeAMyWOnreZKeJyiMpioE7H7pzOYs2KHsXIyezMyedXioXaeigPf7C(qra4q2(U7G()voIr0etNoeJ0IDoFOiaCiBF3Dq))khXieXGjXi6DO0OUChF3Dq))k3g77jANUdo1VJH7RDqrvWOs3XhehV9VK9YNIDWMmukweJiZeJGjMjjMqDCgTtkbvK9no1VJHeZKedcmlQ366YOgKXlAfeJqZedgIVdLg1L7OxrORlIt4g7BG4oDhCQFhd3x7GIQGrLUdeywuV11LreJqZedgciaXmjXauI5dIJ3GAsReGhbMSVlRwx2aT2HsJ6YD8VKLXH63yFJHa70DWP(DmCFTdkQcgv6oqGzr9wxxg1GmErRGyezMyedXGH4edWeZhehVb1KwjapcmzFxwTUSbArmILyeNyaMyKwSZ5dfbGdz7Hvu4LbQWIjgXsmH64mApSIIpIvSyuJt97yiXiwIbtIr0etNoetu9SpopSyIreIbdb2HsJ6YDaznE8YavyXBSVXaJD6o4u)ogUV2bfvbJkDhsl258HIaWHSbznE8Ac9qMQ2tmcntm2DhknQl3bK14XRj0dzQA)g7BmWCNUdo1VJH7RDqrvWOs3H0IDoFOiaCiBqwJhPhcYeJqZeJD3HsJ6YDaznEKEiiVX(gd7Ut3bN63XW91oOOkyuP74dIJ3GAsReGhbMSVlRwx2aTiMoDigeyYTO6zFCEbLyeHyaqH7qPrD5oEyffEzGkS4n23yiO70DWP(DmCFTdkQcgv6o(G44nOM0kb4rGj77YQ1LnqRDO0OUChF3Dq))k3g7BmeFNUdo1VJH7RDqrvWOs3XhehVrrvV8sVKEGiaCd0Iy60Hyc1Xz0qQvb9qME9wNSI6YgN63XqIPthIrAXoNpueaoKniRXJxtOhYu1EIrOzIbZDO0OUChqwJhVMqpKPQ9BSVXqW70DWP(DmCFTdkQcgv6o(G44nkQ6Lx6L0debGBGwetNoetOooJgsTkOhY0R36Kvux24u)ogsmD6qmsl258HIaWHSbznEKEiitmcntmyUdLg1L7aYA8i9qqEJ9ngt4oDhknQl3b9sjyVvuxUdo1VJH7Rn23ymr70DO0OUChF3Dq))k3o4u)ogUV2yFJbqCNUdo1VJH7RDqrvWOs3bcm5wu9SpoVDjgrigauiX0PdX8bXXB)lzV8PyhSjdLIfXieXi4DO0OUChpSIcVmqfw8g7BmfyNUdo1VJH7RDqrvWOs3bcmlQ366YOgKXlAfeJqedMcSdLg1L7qrunzFCieNXgBSXoefJK1L7BmfatbeyIWuW7ORIYkbi3HGuV1HcgsmItmknQljgxjdzJyBhwOdVC8oasI5L7oiXyNynEiMj(Sa8eeBajXyhabakdIbtblmXGPaykaXgXgqsm2XhnbWsbrInGKyaceZehyrXIy0esmWcf2tmGwqnyI5WjMx42bIjoIz8OWRRttOSrSrSbKeJGWjGPGbdjMpJFiMyOx)xdI5ZaQu2ig7aLYwHKyYlbcpkQhh0rmknQlLeZLo7BeBknQlLnletV(VgZ4ovIfXMsJ6szZcX0R)RbWZyJFhKytPrDPSzHy61)1a4zSvqa9CgAuxsSbKeZivl5ZfedsliX8bXXziXidnKeZNXpetm0R)RbX8zavkjgnHeJfIbcwxevcGykjXaVKBeBknQlLnletV(VgapJTmvl5ZfEzOHKytPrDPSzHy61)1a4zSTUOUKyJydijgbHtatbdgsmSOyK9etu9mXepmXO04qetjjgvuA50VJBeBknQlLZ9vc94iMNyzInLg1LsGNX(7Ud6Xbr2lCHptVZbVUzdQjTsaEeyY(USADzdXk0(jfdqP35Gx3S9D3bHOkXIrneRq770bOH64mAF3DqiQsSyuJt97yOOj2uAuxkbEg7pJKmcRkbqSP0OUuc8m2kIQj7TaDsw4cFwPrjk2Zj3xSuOzm70bbMSiymjcmlQ366YOgKXlAfcjybi2uAuxkbEgBxb4jKEbbGqa9Cgcx4ZFqC8gy(Co79YaXjG4PbArSP0OUuc8m2AszzGuNNQohXMsJ6sjWZyJxi(7UdsSP0OUuc8m2FfG)W9bQOyjj2uAuxkbEgBqj7RG7Lcx4Z07CWRB2GAsReGhbMSVlRwx2qCVwPuiGOaeBknQlLapJT1f1Lcx4ZFqC8gutALa8iWK9Dz16YgOfXMsJ6sjWZy)D3b9HAjCHpJatw2IQN9X5XqiauiXMsJ6sjWZyhx)xgxYcx4ZFqC82)s2lFk2bBYqPyj08esSP0OUuc8m2YUkQVsa((sgcx4ZiWSOERRlJAqgVOviKGfRsJsuSNtUVyjXMsJ6sjWZyJ0sYEiRqHl8zGAXrtDLOyInLg1LsGNXgQjTsaEeyY(USADPWf(mqd1Xz0(U7GquLyXOgN63XWoDak9oh86MTV7oievjwmQHyfApXMsJ6sjWZyR)RVsnQl9UQ)tSP0OUuc8m2u158knQl9UsgcNApp3xrbqJ6sHl85kPxFLa8qTxbWEXLcjaXMsJ6sjWZytvNZR0OU07kziCQ98mlLCszjXMsJ6sjWZytvNZR0OU07kziCQ98Sm0eQiiXgXMsJ6szJLsoPSCMEjLZaPbd94oTNfUWNHx0Oxs5mqAWqpUt7z)heLne3RvkfbZjb6hehVb1KwjapcmzFxwTUSbArSP0OUu2yPKtklbEgBnRE1F4EiRXJWf(8hehVjkT3Qqf1)D3bBGwtkgKwqplkoJMcHYgpbLmKD6G0c6zrXz0uiu2Quimex0eBknQlLnwk5KYsGNXUN7pK9(d37aPf0drS2lfUWNrGj3IQN9X5Xqiau4KiWSOERRlJerqfGytPrDPSXsjNuwc8m2DpKdkkUspILxQjLj2uAuxkBSuYjLLapJnQSSCSVsV0sPSWf(mq)G44nOM0kb4rGj77YQ1LnqlInInLg1LYwFffanQlNfL2BvOI6)U7Gcx4ZpS6INMfnerCb60rmafa6aTM8Hvx80SOHicwWIMyJydijgbPKE9vcGyGAVcGjgeBNfSqCpNbXusIbtXNyiMdNy61jGyEy1fpeJ8CNWeJ4cmXqmhoX0RtaX8WQlEiMkjgLyaGoqRgXMsJ6szRVIcGg1LapJnK14XlduHflCHpxj96ReGhQ9ka2BxPqZpS6INgfeH4mi2i2asIXoDPDEqmooignjgEckzujaI5L7oiXmEk2bjgi6SAeBknQlLT(kkaAuxc8m2qwJhVmqfwSWf(Suff7)U7GE5tXo4KvsV(kb4HAVcG9IlfsGj)G44TV7oOx(uSd2aTM8dIJ3(U7GE5tXoydX9ALsrWOjUybqHeBeBknQlLT(kkaAuxc8m2fL)hyc94hkQaeYcx4ZpS6INMfnerCbacIbtbe7hehV9D3b9YNIDWgOLOj2i2uAuxkB9vua0OUe4zSLkfv4fTuN3sPHWf(8dRU4PzrdrMqXN0IJgGNd01qCVwPueXj2i2uAuxkBYqtOIGZqwJhVmqfwSWf(mcmlQ366YOgKXlAfImJHatkgGgQJZO9VKLXH6BCQFhd70bO07CWRB2(xYY4q9neRq7705dIJ3GAsReGhbMSVlRwx2aTenXMsJ6sztgAcvee4zSLkfv4fTuN3sPHWf(SfhnaphORH4ETsPiaOqXIjXMsJ6sztgAcvee4zS)U7GquLyXiHl8zG(bXXBqnPvcWJat23LvRlBGweBknQlLnzOjurqGNXUxrORlItOWf(8hehV9VK9YNIDWgI71kLIGrtCXcGcB8eWuWG70rmFqC82)s2lFk2bBiUxRukYmcm5wu9SpoVD705dIJ3(xYE5tXoydX9ALsrMfdakey6Do41nBF3DqiQsSyudXk0EXgQJZO9D3bHOkXIrno1VJHIftr3PZhehV9VK9YNIDWMmukwIyxrpjcmlQ366YOgKXlAfcnJPaeBknQlLnzOjurqGNXw(OuSCSpEypy29qXJ9cx4ZighXYh97yInLg1LYMm0eQiiWZy)Wkk8SuYjLfUWNb6hehVb1KwjapcmzFxwTUSbArSP0OUu2KHMqfbbEg7V7oO)FLt4cFM(OiaS0JJuAuxQoHMXOnrtkMpioE7H7pzOYs2KHsXsKzXioqqAXoNpueaoKTV7oO)FLt0D6iTyNZhkcahY23Dh0)VYjeMIMytPrDPSjdnHkcc8m29kcDDrCcfUWN)G44T)LSx(uSd2KHsXsKzbpzOooJ2jLGkY(gN63XWjrGzr9wxxg1GmErRqOzmeNytPrDPSjdnHkcc8m2)lzzCOEHl8zeywuV11LrcnJHacmjq)G44nOM0kb4rGj77YQ1LnqlInLg1LYMm0eQiiWZydznE8YavyXcx4ZiWSOERRlJAqgVOviYSyWqCG)G44nOM0kb4rGj77YQ1LnqlXkoWsl258HIaWHS9Wkk8YavyXInuhNr7Hvu8rSIfJACQFhdflMIUtNO6zFCEyXIGHaeBknQlLnzOjurqGNXgYA841e6HmvTx4cFwAXoNpueaoKniRXJxtOhYu1EHMTlXgqsm2z0G(qmJQ3osmvVLJ75m0OUKyqSGiXyNynESZLeJDcKfKtmsMjMcNyIh2EIPsQdeYeZ)IhIr)LRIILeZHiMcNyGSgpEnHEitv7jgCWKg1LsIb)qeZ)INgXMsJ6sztgAcvee4zSHSgpspeKfUWNLwSZ5dfbGdzdYA8i9qqwOz7sSP0OUu2KHMqfbbEg7hwrHxgOclw4cF(dIJ3GAsReGhbMSVlRwx2aT60bbMClQE2hNxqfbafsSP0OUu2KHMqfbbEg7V7oO)FLt4cF(dIJ3GAsReGhbMSVlRwx2aTi2uAuxkBYqtOIGapJnK14XRj0dzQAVWf(8hehVrrvV8sVKEGiaCd0QtNqDCgnKAvqpKPxV1jROUSXP(DmSthPf7C(qra4q2GSgpEnHEitv7fAgtInLg1LYMm0eQiiWZydznEKEiilCHp)bXXBuu1lV0lPhica3aT60juhNrdPwf0dz61BDYkQlBCQFhd70rAXoNpueaoKniRXJ0dbzHMXKytPrDPSjdnHkcc8m20lLG9wrDjXMsJ6sztgAcvee4zS)U7G()voInLg1LYMm0eQiiWZy)Wkk8YavyXcx4ZiWKBr1Z(482veauyNoFqC82)s2lFk2bBYqPyjKGj2uAuxkBYqtOIGapJTIOAY(4qiodHl8zeywuV11LrniJx0kectb2HcgphAhJQ3osmatmcYySkxTXg7c]] )

end