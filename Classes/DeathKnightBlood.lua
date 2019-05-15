-- DeathKnightBlood.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


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

        reset = function()
            local t = state.runes

            for i = 1, 6 do
                local start, duration, ready = GetRuneCooldown( i )
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

            t.actual = nil
        end,
    }, {
        __index = function( t, k, v )
            if k == 'actual' then
                local amount = 0

                for i = 1, 6 do
                    amount = amount + ( t.expiry[ i ] <= state.query_time and 1 or 0 )
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

            elseif k == 'time_to_next' then
                return t[ 'time_to_' .. t.current + 1 ]

            elseif k == 'time_to_max' then
                return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.RunicPower )

    local spendHook = function( amt, resource )
        if amt > 0 then
            if resource == "runes" then
                gain( amt * 10, "runic_power" )

                if talent.rune_strike.enabled then gainChargeTime( "rune_strike", amt ) end

                if azerite.eternal_rune_weapon.enabled and buff.dancing_rune_weapon.up then
                    if buff.dancing_rune_weapon.expires - buff.dancing_rune_weapon.applied < buff.dancing_rune_weapon.duration + 5 then
                        buff.dancing_rune_weapon.expires = min( buff.dancing_rune_weapon.applied + buff.dancing_rune_weapon.duration + 5, buff.dancing_rune_weapon.expires + ( 0.5 * amt ) )
                        buff.eternal_rune_weapon.expires = min( buff.dancing_rune_weapon.applied + buff.dancing_rune_weapon.duration + 5, buff.dancing_rune_weapon.expires + ( 0.5 * amt ) )
                    end
                end

            elseif resource == "runic_power" then
                local rp = runic_power

                if talent.red_thirst.enabled then cooldown.vampiric_blood.expires = max( 0, cooldown.vampiric_blood.expires - amt / 10 ) end
            end
        end
    end

    spec:RegisterHook( "spend", spendHook )


    -- Talents
    spec:RegisterTalents( {
        heartbreaker = 19165, -- 221536
        blooddrinker = 19166, -- 206931
        rune_strike = 19217, -- 210764

        rapid_decomposition = 19218, -- 194662
        hemostasis = 19219, -- 273946
        consumption = 19220, -- 274156

        foul_bulwark = 19221, -- 206974
        ossuary = 22134, -- 219786
        tombstone = 22135, -- 219809

        will_of_the_necropolis = 22013, -- 206967
        antimagic_barrier = 22014, -- 205727
        rune_tap = 22015, -- 194679

        grip_of_the_dead = 19227, -- 273952
        tightening_grasp = 19226, -- 206970
        wraith_walk = 19228, -- 212552

        voracious = 19230, -- 273953
        bloodworms = 19231, -- 195679
        mark_of_blood = 19232, -- 206940

        purgatory = 21207, -- 114556
        red_thirst = 21208, -- 205723
        bonestorm = 21209, -- 194844
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3468, -- 214027
        gladiators_medallion = 3467, -- 208683
        relentless = 3466, -- 196029

        antimagic_zone = 3434, -- 51052
        blood_for_blood = 607, -- 233411
        dark_simulacrum = 3511, -- 77606
        death_chain = 609, -- 203173
        decomposing_aura = 3441, -- 199720
        heartstop_aura = 3438, -- 199719
        last_dance = 608, -- 233412
        murderous_intent = 841, -- 207018
        necrotic_aura = 3436, -- 199642
        strangulate = 206, -- 47476
        unholy_command = 204, -- 202727
        walking_dead = 205, -- 202731
    } )


    -- Auras
    spec:RegisterAuras( {
        antimagic_shell = {
            id = 48707,
            duration = function () return ( azerite.runic_barrier.enabled and 1 or 0 ) + ( talent.antimagic_barrier.enabled and 6.5 or 5 ) * ( ( level < 116 and equipped.acherus_drapes ) and 2 or 1 ) end,
            max_stack = 1,
        },
        asphyxiate = {
            id = 108194,
            duration = 4,
            max_stack = 1,
        },
        blooddrinker = {
            id = 206931,
            duration = 3,
            max_stack = 1,
        },        
        blood_plague = {
            id = 55078,
            duration = 24, -- duration is capable of going to 32s if its reapplied before the first wears off
            type = "Disease",
            max_stack = 1,
        },
        blood_shield = {
            id = 77535,
            duration = 10,
            max_stack = 1,
        },
        bone_shield = {
            id = 195181,
            duration = 30,
            max_stack = 10,
        },
        bonestorm = {
            id = 194844,
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
            duration = 8,
            max_stack = 1,
        },
        death_and_decay = {
            id = 43265,
            duration = 10,
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
        grip_of_the_dead = {
            id = 273984,
            duration = 10,
            max_stack = 10,
        },
        heart_strike = {
            id = 206930, -- slow debuff heart strike applies
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
        mark_of_blood = {
            id = 206940,
            duration = 15,
            max_stack = 1,
        },
        on_a_pale_horse = {
            id = 51986,
        },
        ossuary = {
            id = 219788,
            duration = 0, -- duration is persistent when boneshield stacks => 5
            max_stack = 1,
        },
        path_of_frost = {
            id = 3714,
            duration = 600,
            max_stack = 1,
        },
        perdition = { -- debuff from purgatory getting procced
            id = 123981,
            duration = 240,
            max_stack = 1,
        },
        rune_tap = {
            id = 194679,
            duration = 4,
            max_stack = 1,
        },
        shroud_of_purgatory = {
            id = 116888,
            duration = 3,
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
            duration = 10,
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

        strangulate = {
            id = 47476,
            duration = 5,
            max_stack = 1,                
        }, 
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


    spec:RegisterHook( "reset_precast", function ()
        local control_expires = action.control_undead.lastCast + 300
        if control_expires > now and pet.up then
            summonPet( "controlled_undead", control_expires - now )
        end
    end )    


    -- Abilities
    spec:RegisterAbilities( {
        antimagic_shell = {
            id = 48707,
            cast = 0,
            cooldown = function () return talent.antimagic_barrier.enabled and 45 or 60 end,
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

            pvptalent = "antimagic_zone",

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

            usable = function () return target.casting end,
            readyTime = function () return debuff.casting.up and ( debuff.casting.remains - 0.5 ) or 3600 end,
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
            gcd = "spell",

            startsCombat = true,
            texture = 237513,

            handler = function ()
                applyDebuff( "target", "blood_plague" )
                active_dot.blood_plague = active_enemies

                if talent.hemostasis.enabled then
                    applyBuff( "hemostasis", 15, min( 5, active_enemies) )
                end

                if level < 116 and equipped.skullflowers_haemostasis then
                    applyBuff( "haemostasis" )
                end

                if level < 116 and set_bonus.tier20_2pc == 1 then
                    applyBuff( "gravewarden" )
                end
            end,
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

            handler = function ()
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

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 342917,

            talent = "bonestorm",

            handler = function ()
                local cost = min( runic_power.current, 100 )
                spend( cost, "runic_power" )
                applyBuff( "bonestorm", cost / 10 )
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

            handler = function ()
            end,
        },


        dancing_rune_weapon = {
            id = 49028,
            cast = 0,
            cooldown = function () return pvptalent.last_dance.enabled and 60 or 120 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
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

            handler = function ()
                applyBuff( "death_and_decay" )
                removeBuff( "crimson_scourge" )
            end,
        },


        --[[ death_gate = {
            id = 50977,
            cast = 4,
            cooldown = 60,
            gcd = "spell",

            spend = -10,
            spendType = "runic_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135766,

            handler = function ()
            end,
        }, ]]


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

                if level < 116 and equipped.service_of_gorefiend then cooldown.vampiric_blood.expires = max( 0, cooldown.vampiric_blood.expires - 2 ) end
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


        mark_of_blood = {
            id = 206940,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = 30,
            spendType = "runic_power",

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


        --[[ raise_ally = {
            id = 61999,
            cast = 0,
            cooldown = 600,
            gcd = "spell",

            spend = 30,
            spendType = "runic_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136143,

            handler = function ()
            end,
        }, ]]


        rune_strike = {
            id = 210764,
            cast = 0,
            charges = 2,
            cooldown = 60,
            recharge = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 237518,

            talent = "rune_strike",

            handler = function ()
                gain( 1, "runes" )
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

                if set_bonus.tier21_2pc == 1 then
                    cooldown.dancing_rune_weapon.expires = max( 0, cooldown.dancing_rune_weapon.expires - ( 3 * bs ) )
                end

                applyBuff( "tombstone" )
            end,
        },


        vampiric_blood = {
            id = 55233,
            cast = 0,
            cooldown = 90,
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

            handler = function ()
                applyBuff( "wraith_walk" )
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

        potion = "battle_potion_of_strength",

        package = "Blood",        
    } )


    spec:RegisterPack( "Blood", 20190514.2230, [[dmKKCaqifP8isr2KKIrbaNcaTkesVcOmlsHBPiXUe8lGyyiWXueldb9mektJujxdP02qi8neQACKIQZPiP1rQunpsf3tb7dP4GiezHavpeHknrsrjxeHOAJiurJKuuQtIqfwjP0lrik3urQStG0tvYubO9QQ)k0Gj6WuwSs9yctg0LrTzK8zfA0a60s9AsvZwIBRO2TOFRYWLKLd55KmDQUoI2UIu13LunEsrX5LuA9KkL5JuTFO(N8a(lO58dkHemzQeq7eDfiKqcNkTt(LxBf)RktO3g5FL2m)lWl3b)vLvB5m4d4VuhjsW)A1ZKfZ7ljUiJY)1MSloXr(7FbnNFqjKGjtLaDnHyHjeHUiuxe7xQkw8GsiTe8lGneY5V)fKvIFPjSe8YDqSuZInhiwsKL9iqhRvtyjq3Ru6oiGm2oqYDqCZGO6zYI59LcKr5GO6zbwRMWYPZQflNOlnWscjyYuXYPGLesOUt4uXAXA1ewsCbA5iR0DSwnHLtbljsqidXYPRtiwsCIyw34awRMWYPGLejiKHy501EpAEFjwwALh(vPvU6b8xZT3JM3x(a(Go5b8xCA7cdFW)La1oJA7xiYSfXQRoJWsAgWst49LbiBoWOYrTEoioLJL1GLazR4advchl1blbawoIoYkSSgSKwcWs60XsIGiWsa(lt49L)A6T5Qg1I4UCh89hucFa)fN2UWWh8FjqTZO2(vNIBUZXi0MTrosRclPzalbawoIoYkSSgSKGaTyjD6yjbbcPflbiwsuSeiBfhyy20myjD6yzNIBUZXi0MTrosRclPbljalRbl3KuuHD5oyubS5cmG4zRtfwQdwojqlwsuSCua)Lj8(YFbzZbgvoQ1ZV)GsShWFXPTlm8b)xcu7mQTFbKTIdmujCSuhSKwcWYPGLaaljKaSKOy5MKIkSl3bJkGnxGbYkSeG)YeEF5VAbVpYegPoK3ojKF)9FPClHgc(a(Go5b8xCA7cdFW)La1oJA7xiYSfXQRoJWsAgWYjeqawwdwonSCtsrfGwk6CmIitowNTQldKv)YeEF5V2xYk)qZV)Gs4d4V402fg(G)lbQDg12VqKzlIvxDgfGmvlAhl1zalNqawsNowcaSCtsrf2L7GrfWMlWazfwwdwUjPOc7YDWOcyZfyaXZwNkSuhSCuaXsIILtc0ILa8xMW7l)fKnhyu5Owp)(dkXEa)fN2UWWh8FjqTZO2(10WYnjfvaAPOZXiIm5yD2QUmqw9lt49L)AxUdcrDQNrV)GQRhWFXPTlm8b)xcu7mQTF5gAK9aSvULcglPbljESSgSeEEyxUdgRk2ijhqmfIvaTDH)Lj8(YFbzZbQIcdXk17pO0(a(loTDHHp4)sGANrT9laGLBskQW(soQa2Cbgq8S1Pcl1zalrKjh8EMJ(fjgwsNowUjPOc7l5OcyZfyaXZwNkSuNbSeay5OaILGHLI7kWREg2L7GquN6zuaXgSwSKOyPBfo9WUCheI6upJcCA7cdXsIILeILaelPthl3KuuH9LCubS5cmOCtOhl1bljgwcqSSgSerMTiwD1zuaYuTODSKMbSKqc(Lj8(YFnBi0vhXj89huI4b8xCA7cdFW)La1oJA7xcGgAKvrkKj8(sRGL0mGLtcAowwdwcaSCtsrfaYZNYnvRck3e6XsDgWsaGL0ILtblvvCPeDdnYUkSl3bJ7RlyjaXs60Xsvfxkr3qJSRc7YDW4(6cwsdwsiwcWFzcVV8x7YDW4(6Y7pOe)d4V402fg(G)lbQDg12V2KuuH9LCubS5cmOCtOhl1blPflRblDRWPhoLI0q1g402fgIL1GLiYSfXQRoJcqMQfTJL0mGLtO9xMW7l)1SHqxDeNW3Fq18hWFXPTlm8b)xcu7mQTFHiZweRU6mkazQw0owQZawcaSCcTyjyy5MKIkaTu05yerMCSoBvxgiRWsIIL0ILGHLQkUuIUHgzxfaYgYJkh16zSKOyPBfo9aq2q(gXMEgf402fgILefljelbiwsNow6gAK9G3ZC0ViSzSuhSCcb)YeEF5VGS5aJkh1653FqN6d4V402fg(G)lbQDg12VuvCPeDdnYUkazZbgTegHSWQflPzalj2VmH3x(liBoWOLWiKfwTV)GoHGhWFXPTlm8b)xcu7mQTFbaSua0qJSksHmH3xAfSKMbSCsqZXs60XYnjfvaAPOZXiIm5yD2QUmqwHLaelRblrKjh8EMJ(fjgwsZawokG)YeEF5VqKjhvoQ1ZV)GozYd4V402fg(G)lbQDg12V2KuubOLIohJiYKJ1zR6YazfwsNowIito49mh9lQlSuhSCua)Lj8(YFbKnKhvoQ1ZV)GoHWhWFXPTlm8b)xcu7mQTFTjPOcqlfDogrKjhRZw1LbYQFzcVV8x7YDW4(6Y7pOti2d4V402fg(G)lbQDg12V2KuubbQNvxgvIJenYbYkSKoDS0TcNEazvnmczXnxDQ27ldCA7cdXs60Xsvfxkr3qJSRcq2CGrlHrilSAXsAgWsc)Lj8(YFbzZbgTegHSWQ99h0j66b8xMW7l)L4sf5CL3x(loTDHHp4V)GoH2hWFzcVV8x7YDW4(6YV402fg(G)(d6eI4b8xCA7cdFW)La1oJA7xiYKdEpZr)Iedl1blhfqSKoDSCtsrf2xYrfWMlWGYnHESKgSKi(Lj8(YFbKnKhvoQ1ZV)GoH4Fa)Lj8(YFHitoQCuRN)fN2UWWh83FqNO5pG)ItBxy4d(VeO2zuB)crMTiwD1zuaYuTODSKgSKqc(Lj8(YFziHLC0peIt)93)fKPmYI)a(Go5b8xMW7l)1CNWifIzDJ)fN2UWWh83Fqj8b8xCA7cdFW)La1oJA7xI7kWREgGwk6CmIitowNTQldi2G1IL1GLaalNgwkURaV6zyxUdcrDQNrbeBWAXs60XYPHLUv40d7YDqiQt9mkWPTlmelb4VmH3x(RD5oyKIev77pOe7b8xMW7l)1MrkgPVZXFXPTlm8b)9huD9a(loTDHHp4)sGANrT9lXDf4vpdqlfDogrKjhRZw1LbepBDQWsAWYPsWVmH3x(lsfhBNNvV)Gs7d4V402fg(G)R0M5FHmDdsM6vXDpgrmmUjD)YFzcVV8xit3GKPEvC3JredJBs3V89huI4b8xCA7cdFW)vAZ8VMzeR3bAQiLLJ)YeEF5VMzeR3bAQiLLJV)Gs8pG)ItBxy4d(VeO2zuB)AtsrfGwk6CmIitowNTQldKv)YeEF5VQoVV89hun)b8xCA7cdFW)La1oJA7xtdlDRWPh2L7GquN6zuGtBxyiwsNowonSuCxbE1ZWUCheI6upJci2G1(lt49L)cAPOZXiIm5yD2QU89h0P(a(loTDHHp4)sGANrT9RnjfvyFjhvaBUadk3e6XsAgWsI)xMW7l)LFZBLFj)(d6ecEa)fN2UWWh8FzcVV8xcRuIMW7lJLw5)Q0kpM2m)R527rZ7lF)bDYKhWFXPTlm8b)xMW7l)LWkLOj8(YyPv(VkTYJPnZ)s5wcne893)vfIf3828hWh0jpG)ItBxy4d(7pOe(a(loTDHHp4V)GsShWFXPTlm8b)9huD9a(loTDHHp4V)Gs7d4VmH3x(RQZ7l)fN2UWWh83F)9Fn9ms1x(GsibtMkbeBcXhiKaDr7VQBOSZr1VioMRoKZqSuxyPj8(sSS0kxfWA)Lr6ap0Vw9mXflbdl1Sz9DP)vf6O6c)lnHLGxUdILAwS5aXsISShb6yTAclb6ELs3bbKX2bsUdIBgevptwmVVuGmkhevplWA1ewoDwTy5eDPbwsibtMkwofSKqc1DcNkwlwRMWsIlqlhzLUJ1QjSCkyjrccziwoDDcXsIteZ6ghWA1ewofSKibHmelNU27rZ7lXYsR8awlwRMWsICndliDgILBM6qmwkU5T5y5Mh7ufWsIKqWvUclZlNcqdntrwWst49LkS8YsTbSwt49LQqfIf3828bQIP0J1AcVVufQqS4M3Md2aiu3bXAnH3xQcviwCZBZbBaeJCCMt38(sSwnHLR0QuaphlrwdXYnjffdXsLBUcl3m1HySuCZBZXYnp2PclTeILviEkvN7DoILTclHxYbSwt49LQqfIf382CWgarLwLc45rLBUcR1eEFPkuHyXnVnhSbqQoVVeRfRvtyjrUMHfKodXsE6zuTyP3Zmw6azS0e(HWYwHL20BDX2foG1AcVVunm3jmsHyw3ySwt49LkWgazxUdgPir1QrtniURaV6zaAPOZXiIm5yD2QUmGydwBnayAI7kWREg2L7GquN6zuaXgSw60NMBfo9WUCheI6upJcCA7cdbiwRj8(sfydGSzKIr67CeR1eEFPcSbqivCSDEwPrtniURaV6zaAPOZXiIm5yD2QUmG4zRtfntLaSwt49LkWgaHuXX25znsBMhqMUbjt9Q4UhJigg3KUFjwRj8(sfydGqQ4y78SgPnZdZmI17anvKYYrSwt49LkWgaP68(snAQHnjfvaAPOZXiIm5yD2QUmqwH1AcVVub2aiqlfDogrKjhRZw1LA0udtZTcNEyxUdcrDQNrboTDHH0PpnXDf4vpd7YDqiQt9mkGydwlwRj8(sfydG438w5xYA0udBskQW(soQa2CbguUj0tZaXJ1AcVVub2aicRuIMW7lJLw5AK2mpm3EpAEFjwRj8(sfydGiSsjAcVVmwALRrAZ8GYTeAiiwlwRj8(svyU9E08(YHP3MRAulI7YDqnAQbez2Iy1vNr0mycVVmazZbgvoQ1ZbXP8AaYwXbgQeUoayeDKv1qlb0PteebaXAnH3xQcZT3JM3xc2aiq2CGrLJA9Sgn1qNIBUZXi0MTrosRIMbamIoYQAiiqlD6eeiKwasuGSvCGHztZqNENIBUZXi0MTrosRIgcQztsrf2L7GrfWMlWaINTov6mjqlrhfqSwt49LQWC79O59LGnasl49rMWi1H82jHSgn1aq2koWqLW1HwcMcaiKaIUjPOc7YDWOcyZfyGScGyTyTMW7lvbLBj0qWH9LSYp0Sgn1aImBrS6QZiAgMqab1mTnjfvaAPOZXiIm5yD2QUmqwH1AcVVufuULqdbbBaeiBoWOYrTEwJMAarMTiwD1zuaYuTODDgMqaD6aytsrf2L7GrfWMlWazvnBskQWUChmQa2Cbgq8S1PsNrbKOtc0cqSwt49LQGYTeAiiydGSl3bHOo1ZinAQHPTjPOcqlfDogrKjhRZw1LbYkSwt49LQGYTeAiiydGazZbQIcdXkLgn1GBOr2dWw5wkyAi(AGNh2L7GXQInsYbetHyfqBxySwt49LQGYTeAiiydGmBi0vhXjuJMAaaBskQW(soQa2Cbgq8S1PsNbezYbVN5OFrIrN(MKIkSVKJkGnxGbepBDQ0zaaJciyI7kWREg2L7GquN6zuaXgSwI6wHtpSl3bHOo1ZOaN2UWqIsiaPtFtsrf2xYrfWMlWGYnHEDigaRbrMTiwD1zuaYuTODAgiKaSwt49LQGYTeAiiydGSl3bJ7RlA0udcGgAKvrkKj8(sRqZWKGMxda2KuubG88PCt1QGYnHEDgaaTtrvXLs0n0i7QWUChmUVUaq60vvCPeDdnYUkSl3bJ7Rl0qiaXAnH3xQck3sOHGGnaYSHqxDeNqnAQHnjfvyFjhvaBUadk3e61H2ACRWPhoLI0q1g402fgwdImBrS6QZOaKPAr70mmHwSwt49LQGYTeAiiydGazZbgvoQ1ZA0udiYSfXQRoJcqMQfTRZaaMqlyBskQa0srNJrezYX6SvDzGSIO0cMQIlLOBOr2vbGSH8OYrTEMOUv40dazd5BeB6zuGtBxyirjeG0P7gAK9G3ZC0ViSzDMqawRj8(svq5wcneeSbqGS5aJwcJqwy1QrtnOQ4sj6gAKDvaYMdmAjmczHvlndedR1eEFPkOClHgcc2aiiYKJkh16znAQbaiaAOrwfPqMW7lTcndtcAoD6BskQa0srNJrezYX6SvDzGScG1Gito49mh9lsmAggfqSwt49LQGYTeAiiydGaKnKhvoQ1ZA0udBskQa0srNJrezYX6SvDzGSIoDezYbVN5OFrDPZOaI1AcVVufuULqdbbBaKD5oyCFDrJMAytsrfGwk6CmIitowNTQldKvyTMW7lvbLBj0qqWgabYMdmAjmczHvRgn1WMKIkiq9S6YOsCKOroqwrNUBfo9aYQAyeYIBU6uT3xg402fgsNUQIlLOBOr2vbiBoWOLWiKfwT0mqiwRj8(svq5wcneeSbqexQiNR8(sSwt49LQGYTeAiiydGSl3bJ7RlyTMW7lvbLBj0qqWgabiBipQCuRN1OPgqKjh8EMJ(fjMoJciD6BskQW(soQa2CbguUj0tdrG1AcVpvguULqdbbBaesfhBNN1iTzEyeD5OkwH6zRer2iJ1AcVVufuULqdbbBaeezYrLJA9mwRj8(svq5wcneeSbqmKWso6hcXPRrtnGiZweRU6mkazQw0onesW7V)p]] )
end
