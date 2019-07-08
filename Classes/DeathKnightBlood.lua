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


    spec:RegisterPack( "Blood", 20190707.2240, [[dmK2zaqijkEesQ2KsjJsPOtPuyvqP6vaXSqsULsPSlQ6xkvnmLKJPKAzqHNbLY0KO01qI2guI(MevnoKu6CqjSojQyEef3tH2hs4Gqjvlek6HqjPjcLeUOevkBekjAKsuP6KkLQALevVuPuLBcLu2jq6PkAQkv2Rk)LsdMIdtAXaEmHjd5YO2ms9zjmAG60s9AI0SL0TvWUf(TQgUsSCqpNktx01HQTRuQ8DjY4LOsoprP1JKI5te7hX36B3nrAYhOySAnwSQ8RkVhdmk7QYIXntzx4BUOcPAbFZqh4BIz9F0nxuzRVIUD3094qbFZzpGx1S)aRcv68Ma4Dn3(XbCtKM8bkgRwJfRk)QY7XaJYUQS30TWIdumOC1nb3iehhWnrStCtQtmyw)hrmyfSMGjMTx0fGtICQtmGZCXvo73x0jyCaV4h276b8QM9hcOsN7D9GGiN6eJC8QSet5PIyWy1ASGy2gXGbgLtzxrKtKtDIbRcwJc2voe5uNy2gXG1rigrmyToqedwjKzQH9e5uNy2gXG1rigrmyTo7cn7piMA7s)nRTlD3UBo0zxOz)XT7aD9T7MCOavgDyEtbStg26nbZAnb7xejXidXSjXuaF8fIzlIHYveJejedwILeZg3ufz)Xn3oDyPHTWcu)hD5bkg3UBYHcuz0H5nfWozyR3SdXp0rHfPdAbBP0rmumsmBsmfWhFHy2Iyw5PKyKiHyw5XGsIzdIb7edywRjy)GwUigjsiMoe)qhfwKoOfSLshXqbXSIy2IyaWPP9a1)rwh4MRipKh0oCeJmeZApLed2jMcb6MQi7pUjI1eS1LWwkF5bk2UD3KdfOYOdZBkGDYWwVjywRjy)IijgzigkxrmBJy2KyWyfXGDIbaNM2du)hzDGBUI84leZg3ufz)XnBbd84bYs)WStCeF5L30LAGui62DGU(2DtouGkJomVPa2jdB9Mq8Of2LVed9iMUfDsmYmsmRxDtvK9h3eXAc26sylLV8afJB3n5qbQm6W8McyNmS1BwgIbaNM2J0q0rHfIhSTeRlF4XxUPkY(JBcu)hHGDiLHxEGITB3n5qbQm6W8McyNmS1BUjXaGtt7b(GToWnxrEipOD4igzgjgiEW(ShyB(wSrmsKqma400EGpyRdCZvKhYdAhoIrMrIztIPqGigqigX)v0xk8a1)riyhszOhYkswIb7etQvospq9Fec2Hug65qbQmIyWoXGbXSbXircXaGtt7b(GToWnxrExQcPeJmed2iMniMTigiE0c7YxIHEet3IojgkgjgmwDtvK9h3CqHWVeKd0LhOL92DtouGkJomVPa2jdB9McWkSGDwAOkY(dTsmumsmR9ulXSfXSjXaGtt7bZdVlvx78UufsjgzgjMnjgkjMTrmUfUwTPcl405bQ)JSaFxjMnigjsig3cxR2uHfC68a1)rwGVRedfedgeZg3ufz)XnbQ)JSaFxV8aLYB3n5qbQm6W8McyNmS1BcGtt7b(GToWnxrExQcPeJmedLeZwetQvos)7C4kuwphkqLreZwedepAHD5lXqpIPBrNedfJeZAkVPkY(JBoOq4xcYb6YduS82DtouGkJomVPa2jdB9Mq8Of2LVedjgkgjM1RwrmBrmLHyaWPP9ineDuyH4bBlX6YhE8LBQIS)4MaFWU8HdxEGw(B3n5qbQm6W8McyNmS1BcXJwyx(sm0Jy6w0jXiZiXSjXSMsIbeIbaNM2J0q0rHfIhSTeRlF4XxigStmusmGqmUfUwTPcl405bZkmTUe2szIb7etQvospywHjaKvPm0ZHcuzeXGDIbdIzdIrIeIjvybN(1(ShyB(wuZeJmeZ6v3ufz)XnrSMGTUe2s5lpqP2B3n5qbQm6W8McyNmS1B6w4A1MkSGtNhXAc2QbYIyHklXqXiXGTBQIS)4MiwtWwnqweluzV8aflUD3KdfOYOdZBkGDYWwV5MeJaSclyNLgQIS)qRedfJeZAp1smsKqma400EKgIokSq8GTLyD5dp(cXSbXSfXaXd2N9aBZ3InIHIrIPqGUPkY(JBcXd26sylLV8aD9QB3n5qbQm6W8McyNmS1BcGtt7rAi6OWcXd2wI1Lp84leJejedepyF2dSnFBzjgziMcb6MQi7pUjywHP1LWwkF5b6613UBYHcuz0H5nfWozyR3eaNM2J0q0rHfIhSTeRlF4XxUPkY(JBcu)hzb(UE5b6AmUD3KdfOYOdZBkGDYWwVjaonTxa7b3hwN4XHfShFHyKiHysTYr6H6sJSiw8dlVRZ(dphkqLreJejeJBHRvBQWcoDEeRjyRgilIfQSedfJedg3ufz)XnrSMGTAGSiwOYE5b6ASD7UPkY(JBk(WHpSK9h3KdfOYOdZlpqxx2B3nvr2FCtG6)ilW31BYHcuz0H5LhORP82DtouGkJomVPa2jdB9Mq8G9zpW28TyJyKHykeiIrIeIbaNM2d8bBDGBUI8UufsjgkigS8MQi7pUjywHP1LWwkF5b6AS82DtouGkJomVzOd8nlGFu4SlWEqRwOwW3ufz)XnlGFu4SlWEqRwOwWxEGUU83UBQIS)4Mq8GTUe2s5BYHcuz0H5LhORP2B3n5qbQm6W8McyNmS1BcXJwyx(sm0Jy6w0jXqbXGXQBQIS)4MkuObBZhc5iV8YBIyAfVM3Ud013UBQIS)4MdDGS0qMPg(MCOavgDyE5bkg3UBYHcuz0H5nfWozyR3u8Ff9LcpsdrhfwiEW2sSU8HhYkswIzlIztIPmeJ4)k6lfEG6)ieSdPm0dzfjlXircXugIj1khPhO(pcb7qkd9COavgrmBCtvK9h3eO(pYsJdL9YduSD7UPkY(JBcWqhdL2rXn5qbQm6W8Yd0YE7UjhkqLrhM3ua7KHTEtX)v0xk8ineDuyH4bBlX6YhEipOD4igkigSy1nvr2FCtChB7KhCxEGs5T7MCOavgDyEZqh4BcvQbHhsDwGUWczKfapZpUPkY(JBcvQbHhsDwGUWczKfapZpU8aflVD3KdfOYOdZBg6aFZbgYstWQZsRrXnvr2FCZbgYstWQZsRrXLhOL)2DtouGkJomVPa2jdB9Ma400EKgIokSq8GTLyD5dp(Ynvr2FCZLp7pU8aLAVD3KdfOYOdZBkGDYWwVzziMuRCKEG6)ieSdPm0ZHcuzeXircXugIr8Ff9Lcpq9Fec2Hug6HSIK9MQi7pUjsdrhfwiEW2sSU8XLhOyXT7MCOavgDyEtbStg26nbWPP9aFWwh4MRiVlvHuIHIrIP83ufz)XnZFaWLFWxEGUE1T7MCOavgDyEtbStg26n7q8dDuyr6GwWwkDedfeZQBQIS)4McTwTQi7pS12L3S2U0g6aFZHo7cn7pU8aD96B3n5qbQm6W8MQi7pUPqRvRkY(dBTD5nRTlTHoW30LAGui6YlV5cKf)aGM3UlV8MBhdD9hhOySAnwSIY1L1Jb2wt5nlPWOJc3n3(dlpmzeXGnIrfz)bXuBx68e53Cb(0DLVj1jgmR)JigScwtWeZ2l6cWjro1jgWzU4kN97l6emoGx8d7D9aEvZ(dbuPZ9UEqqKtDIroEvwIP8urmySAnwqmBJyWaJYPSRiYjYPoXGvbRrb7khICQtmBJyW6ieJigSwhiIbReYm1WEICQtmBJyW6ieJigSwNDHM9hetTDPNiNiN6et5w5If4jJigE7yOSet2dmXKGzIrf5djM2rm62PDvbQSNixfz)HBCOdKLgYm1We5Qi7pCGmUhO(pYsJdLLQMEu8Ff9LcpsdrhfwiEW2sSU8HhYks2T2SmI)ROVu4bQ)JqWoKYqpKvKSsKuMuRCKEG6)ieSdPm0ZHcuz0ge5Qi7pCGmUhGHogkTJcICvK9hoqg3J7yBN8GJQMEu8Ff9LcpsdrhfwiEW2sSU8HhYdAhokWIve5Qi7pCGmUh3X2o5bQcDGhHk1GWdPolqxyHmYcGN5he5Qi7pCGmUh3X2o5bQcDGhhyilnbRolTgfe5Qi7pCGmUF5Z(dQA6raCAApsdrhfwiEW2sSU8HhFHixfz)HdKX9ineDuyH4bBlX6Yhu10JLj1khPhO(pcb7qkd9COavgjrsze)xrFPWdu)hHGDiLHEiRizjYvr2F4azCF(daU8dMQMEeaNM2d8bBDGBUI8UufsPyS8e5Qi7pCGmUxO1Qvfz)HT2UKQqh4XHo7cn7pOQPh7q8dDuyr6GwWwkDuSIixfz)HdKX9cTwTQi7pS12Luf6ap6snqkerKtKRIS)W5h6Sl0S)yC70HLg2clq9Fevn9iywRjy)IiLzZc4JVSfLRKiblXYniYvr2F48dD2fA2FaY4EeRjyRlHTuMQMESdXp0rHfPdAbBP0rX4MfWhFzRvEkLizLhdk3a7GzTMG9dA5sIKoe)qhfwKoOfSLshfR2caNM2du)hzDGBUI8qEq7WjZApLyVqGiYvr2F48dD2fA2FaY4(wWapEGS0pm7ehXu10JGzTMG9lIugkxTTnXyf2bWPP9a1)rwh4MRip(Yge5e5Qi7pCExQbsHOreRjyRlHTuMQMEeIhTWU8LyOhX0TOtzgxVIixfz)HZ7snqkebY4EG6)ieSdPmKQMESma400EKgIokSq8GTLyD5dp(crUkY(dN3LAGuicKX9dke(LGCGOQPh3eaNM2d8bBDGBUI8qEq7WjZiepyF2dSnFl2KibaNM2d8bBDGBUI8qEq7WjZ4MfceiI)ROVu4bQ)JqWoKYqpKvKSyp1khPhO(pcb7qkd9COavgHDm2qIeaCAApWhS1bU5kY7svivgSTXwq8Of2LVed9iMUfDsXigRiYvr2F48UudKcrGmUhO(pYc8DLQMEuawHfSZsdvr2FOvkgx7P2T2eaNM2dMhExQU25DPkKkZ4MuUn3cxR2uHfC68a1)rwGVRBirIBHRvBQWcoDEG6)ilW3vkWydICvK9hoVl1aPqeiJ7hui8lb5arvtpcGtt7b(GToWnxrExQcPYq5wPw5i9VZHRqz9COavgTfepAHD5lXqpIPBrNumUMsICvK9hoVl1aPqeiJ7b(GD5dhOQPhH4rlSlFjgsX46vR2Qma400EKgIokSq8GTLyD5dp(crUkY(dN3LAGuicKX9iwtWwxcBPmvn9iepAHD5lXqpIPBrNYmU5AkbbaNM2J0q0rHfIhSTeRlF4XxWoLG4w4A1MkSGtNhmRW06sylLXEQvospywHjaKvPm0ZHcuze2XydjssfwWPFTp7b2MVf1SmRxrKRIS)W5DPgifIazCpI1eSvdKfXcvwQA6r3cxR2uHfC68iwtWwnqweluzPyeBe5Qi7pCExQbsHiqg3dXd26sylLPQPh3uawHfSZsdvr2FOvkgx7PwjsaWPP9ineDuyH4bBlX6YhE8Ln2cIhSp7b2MVfBumwiqe5Qi7pCExQbsHiqg3dMvyADjSLYu10Ja400EKgIokSq8GTLyD5dp(Iejq8G9zpW28TLvMcbIixfz)HZ7snqkebY4EG6)ilW3vQA6raCAApsdrhfwiEW2sSU8HhFHixfz)HZ7snqkebY4EeRjyRgilIfQSu10Ja400EbShCFyDIhhwWE8fjssTYr6H6sJSiw8dlVRZ(dphkqLrsK4w4A1MkSGtNhXAc2QbYIyHklfJyqKRIS)W5DPgifIazCV4dh(Ws2FqKRIS)W5DPgifIazCpq9FKf47krUkY(dN3LAGuicKX9GzfMwxcBPmvn9iepyF2dSnFl2KPqGKibaNM2d8bBDGBUI8UufsPaljYvr2F48UudKcrGmUh3X2o5bQcDGhlGFu4SlWEqRwOwWe5Qi7pCExQbsHiqg3dXd26sylLjYvr2F48UudKcrGmUxHcnyB(qihjvn9iepAHD5lXqpIPBrNuGXQBQ4j4hEZzpGvjgqiMYDwAx7lV8oa]] )
end
