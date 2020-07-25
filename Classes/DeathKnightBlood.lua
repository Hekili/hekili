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

            state.gain( amount * 10, "runic_power" )

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
            duration = 12,
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


    spec:RegisterHook( "reset_precast", function ()
        local control_expires = action.control_undead.lastCast + 300
        if control_expires > now and pet.up then
            summonPet( "controlled_undead", control_expires - now )
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

                if level < 116 and equipped.skullflowers_haemostasis then
                    applyBuff( "haemostasis" )
                end

                if level < 116 and set_bonus.tier20_2pc == 1 then
                    applyBuff( "gravewarden" )
                end

                if legendary.superstrain.enabled then
                    applyDebuff( "target", "frost_fever" )
                    active_Dot.frost_fever = active_enemies

                    applyDebuff( "target", "virulent_plague" )
                    active_dot.virulent_plague = active_enemies
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
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136133,

            usable = function () return pet.alive, "requires an undead pet" end,
            
            handler = function ()
                gain( 0.25 * health.max, "health" )                
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


        -- Venthyr
        swarming_mist = {
            id = 311648,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 3565716,
            
            handler = function ()
                applyBuff( "swarming_mist" )
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
                if legendary.tombstone.enabled and cooldown.dancing_rune_weapon.remains > 0 then
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
        width = 1.5
    } )   


    spec:RegisterPack( "Blood", 20200725, [[dyKYIaqiaXJue1LeOqBsr4tcuGrbP4uqkTkiPEfqzwes3sGQ2LO(fqmmvPogq1YGu9mcLMgKexdsSnfr(gKKmobk15GKuRtGknpcv3trTpcXbbKQwOQKhkqfteqkDrbkPrcifDsaPYkjfVuGsSta1rfOOEQctvrAVQ8xHgmrhMYIvvpgPjd1LrTzc(SQy0aCAjRgqk8AG0Sf52cA3u9BLgoP64cuqlhXZjz6sDDi2oHIVlGXdi58cK1lqrMpP0(b9b(n9gyR5dy0FJ(73Ok0rjd(B0FlwuUrhKoFdDJcQ9W3WTq(gVs7IVHUfuAn8n9gQfHq5BmQqKK116bhIj034JuPgOZV)nWwZhWO)g93VrvOJsg83GJQrrS3qPZ0dy0r59nauym73)gywrVXKHYxPDXqjqlBnaOmyXRhanuZKHsaDRRcUGaYt1aq(z6gcIQcrswxRtjMqdIQcPqntgk1GKcckrhfrHs0FJ(BOgOMjdLbhaM)WQGluZKHYGhkdMrkkOqP5yOexKoiOerhBndLRau(saOhk7fkham8gizowLVrQuT6MEdwPyNYQB6bm430BWU9tm(EDdkPAMu2nWBNPRtzVjwZ4OqYc54hH4zchALRGsXHs0HYjGsGaLFebHm2CA5prcIZXaSPVEgr)ggTR1VbDDk7nXAghfswiF9bm630BWU9tm(EDdkPAMu2n(icczXyH6fPOXFAxCgrhkNakrdusSchzXWENnmwLzGQuTck1QfkjwHJSyyVZggRYLdLIaLGJcuI2By0Uw)gMxHwCfIy2AaxFal2B6ny3(jgFVUbLuntk7geeNZDfYXEJGdLIaLpumuobusq8Ig13ambkfhkrL33WODT(nc5WLeuCfIjeAHJycBHQRpGrLB6nmAxRFJaljHfdxEKWQ1nNY3GD7Ny8966dyuUP3GD7Ny896gus1mPSBaeO8JiiKXMtl)jsqCogGn91Zi63WODT(niLUEIJLhv6gLV(6BGzbdj130dyWVP3WODT(nclhhfimhmX3GD7Ny8966dy0VP3GD7Ny896gus1mPSBq3nH3aEgBoT8NibX5ya20xptydheuobuIgOeiqjD3eEd45FAxmMuoOmjtydheuQvluceOSTe7D(N2fJjLdktYSB)eJHs0EdJ21634N2fhfqibD9bSyVP3WODT(n(mrXeql)5gSB)eJVxxFaJk30BWU9tm(EDdkPAMu2nmAxIHJSZHfRGsrMHs0HsTAHscIZqP4qj4q5eqjbXlAuFdWKmMfkA1qPiq5KEFdJ2163WiuZ5OossXxFaJYn9gSB)eJVx3GsQMjLDJpIGqgXbSPGIQMW(tdiJOFdJ2163ivpaAveObc(jK9(6d4jDtVHr7A9ByoLvnXsrQLs3GD7Ny8966dyu1n9ggTR1VHqr4FAx8ny3(jgFVU(aoyFtVHr7A9B8TN4keBsrbvDd2TFIX3RRpGr130BWU9tm(EDdkPAMu2nO7MWBapJnNw(tKG4CmaB6RNjCOvUckfbkr1VVHr7A9BGO4y1CO66dyWFFtVb72pX471nOKQzsz34JiiKXMtl)jsqCogGn91Zi63WODT(n03Uw)6dyWb)MEd2TFIX3RBqjvZKYUbqGY2sS35FAxmMuoOmjZU9tmgk1Qfkbcus3nH3aE(N2fJjLdktYe2WbDdJ2163aBoT8NibX5ya20x)6dyWr)MEd2TFIX3RBqjvZKYUXhrqi)xNJkafNWzvBuqHsrMHsu1nmAxRFJEd)QED(6dyWf7n9gSB)eJVx3GsQMjLDdcIx0O(gGjzmlu0QHsrGYjbLOgknAxIHJSZHfRUHr7A9BOcyKWYFIHLQV(agCu5MEd2TFIX3RBqjvZKYUr50nS8Ni2cThoIIckfbkFFdJ2163GAPu0ODTEmvQ(gPs1r3c5BewD9yDT(1hWGJYn9gSB)eJVx3WODT(nOwkfnAxRhtLQVrQuD0Tq(gSsXoLvxFad(KUP3GD7Ny896ggTR1Vb1sPOr7A9yQu9nsLQJUfY3q1MJnc(6RVHoHPB436B6bm430BWU9tm(ED9bm630BWU9tm(ED9bSyVP3GD7Ny8966dyu5MEd2TFIX3RRpGr5MEdJ2163qF7A9BWU9tm(ED913iS66X6A9B6bm430BWU9tm(EDdkPAMu2naWwQbK1PnukouIYBOuRwOenqjqGYhYIOdLtaLayl1aY60gkfhkN0KGs0EdJ2163qmwOErkA8N2fF9bm630BWU9tm(EDdkPAMu2nkNUHL)eXwO9WruuqPiZq57mkqjQHsaSLAa5qdOGsTAHs0aLabkFilIouobuwoDdl)jITq7HJOOGsrMHY3z0rbkrnucGTudihAafuI2By0Uw)gy2Aarvtkq5RpGf7n9gSB)eJVx3GsQMjLDdLjgo(t7IJkafNWq5eqz50nS8Ni2cThoIIckfbkFdLtaLFebH8pTloQauCcNr0HYjGYpIGq(N2fhvakoHZeo0kxbLIdLGNrbkrnu(qX3WODT(nWS1aIQMuGYxFaJk30BWU9tm(EDdkPAMu2naWwQbK1PnukouIYBOm4Hs0aLO)gkrnu(reeY)0U4OcqXjCgrhkr7nmAxRFJIY)fXXrHL0vJG5RV(gQ2CSrW30dyWVP3GD7Ny896gus1mPSBqq8Ig13amjJzHIwnuk(muc(BOCcOenqjqGY2sS35)6SQxsyMD7NymuQvluceOKUBcVb88FDw1ljmtydheuQvlu(reeYyZPL)ejiohdWM(6zeDOeT3WODT(nWS1aIQMuGYxFaJ(n9gSB)eJVx3GsQMjLDdGaLFebHm2CA5prcIZXaSPVEgr)ggTR1VXpTlgtkhuMC9bSyVP3GD7Ny896gus1mPSB8reeY)15OcqXjCMWHw5kOuCOe8mkqjQHYhkoZaftrAgk1Qfkrdu(reeY)15OcqXjCMWHw5kOu8zOKG4CURqo2BuSqPwTq5hrqi)xNJkafNWzchALRGsXNHs0aLpumucgus3nH3aE(N2fJjLdktYe2WbbLOgkBlXEN)PDXys5GYKm72pXyOe1qj6qjAHsTAHYpIGq(VohvakoHZQ2OGcLIdLIfkrluobusq8Ig13amjJzHIwnukYmuI(7By0Uw)gHgHSbiSJV(agvUP3GD7Ny896gus1mPSBaeO8JiiKXMtl)jsqCogGn91Zi63WODT(naWgPJSsXoLV(agLB6ny3(jgFVUbLuntk7guag5HvrbIr7ADlbLImdLGNd2q5eqjAGYpIGqgahUQ2uLkRAJckuk(muIgOefOm4HsLoNsX2ipCRY)0U44FReuIwOuRwOuPZPuSnYd3Q8pTlo(3kbLIaLOdLO9ggTR1VXpTlo(3kD9b8KUP3GD7Ny896gus1mPSB8reeY)15OcqXjCw1gfuOu8zOCsq5eqzBj278QuigjOm72pXyOCcOKG4fnQVbysgZcfTAOuKzOeCuUHr7A9BeAeYgGWo(6dyu1n9gSB)eJVx3GsQMjLDdcIx0O(gGjqPiZqj4VFdLtaLabk)icczS50YFIeeNJbytF9mI(nmAxRFJ)6SQxs41hWb7B6ny3(jgFVUbLuntk7geeVOr9natYywOOvdLIpdLObkbhfOemO8JiiKXMtl)jsqCogGn91Zi6qjQHsuGsWGsLoNsX2ipCRYayJ0rvtkqzOe1qzBj27ma2i9NWgOmjZU9tmgkrnuIouIwOuRwOSRqo2Bexmukouc(7By0Uw)gy2Aarvtkq5RpGr130BWU9tm(EDdkPAMu2nu6CkfBJ8WTkJzRbenhhXm1cckfzgkf7nmAxRFdmBnGO54iMPwqxFad(7B6ny3(jgFVUbLuntk7gFebHm2CA5prcIZXaSPVEgrhk1QfkjioN7kKJ9grfOuCO8HIVHr7A9BaGnshvnPaLV(agCWVP3GD7Ny896gus1mPSB8reeYyZPL)ejiohdWM(6ze9By0Uw)g)0U44FR01hWGJ(n9gSB)eJVx3GsQMjLDJpIGqMsQq16rfDripCgrhk1QfkBlXENjMEHJyMUH6RQ6A9m72pXyOuRwOuPZPuSnYd3QmMTgq0CCeZuliOuKzOe9By0Uw)gy2AarZXrmtTGU(agCXEtVHr7A9BqxxHeQ3163GD7Ny8966dyWrLB6nmAxRFJFAxC8Vv6gSB)eJVxxFadok30BWU9tm(EDdkPAMu2niioN7kKJ9gflukou(qXqPwTq5hrqi)xNJkafNWzvBuqHsrGYjDdJ2163aaBKoQAsbkF9bm4t6MEd2TFIX3RBqjvZKYUbbXlAuFdWKmMfkA1qPiqj6VVHr7A9ByeQ5CSxcH9(6RV(gIHjQA9dy0FJ(73OaoQCJagXl)rDdGUq9L0mgkrbknAxRdLPs1QmuZn0jRqL4BmzO8vAxmuc0Ywdakdw86bqd1mzOeq36QGliG8unaKFMUHGOQqKK116uIj0GOQqkuZKHsniPGGs0rruOe93O)gQbQzYqzWbG5pSk4c1mzOm4HYGzKIckuAogkXfPdckr0XwZq5kaLVea6HYEHYbadVbsMJvzOgOMjdLbRaftrAgdLFwyjmus3WV1q5NFkxLHsGEkL1Bfu6Rh8amsOascknAxRRGY1tbLHAmAxRRY6eMUHFRNfsMcuOgJ216QSoHPB43AWMbryxmuJr7ADvwNW0n8BnyZGyipHS3wxRd1mzOC4MUcW2qjXkmu(reeymuQARvq5NfwcdL0n8Bnu(5NYvqP5yOuNWbV(2D5pqzPGs86CgQXODTUkRty6g(TgSzquUPRaSDu1wRGAmAxRRY6eMUHFRbBge9TR1HAGAMmugScumfPzmuYIHjbbLDfYqzdGHsJ2lbklfuAIXQK9tCgQXODTUAoSCCuGWCWed1y0Uwxb2mi)0U4OacjirlHz6Uj8gWZyZPL)ejiohdWM(6zcB4GManaHUBcVb88pTlgtkhuMKjSHdsRwG0wI9o)t7IXKYbLjz2TFIXOfQXODTUcSzq(mrXeql)bQXODTUcSzqmc1CoQJKuSOLWSr7smCKDoSyLiZORvlbXzXbFccIx0O(gGjzmlu0QfzsVHAmAxRRaBgKu9aOvrGgi4Nq2BrlH5pIGqgXbSPGIQMW(tdiJOd1y0Uwxb2miMtzvtSuKAPeuJr7ADfyZGiue(N2fd1y0Uwxb2miF7jUcXMuuqvqngTR1vGndcIIJvZHkrlHz6Uj8gWZyZPL)ejiohdWM(6zchALRebv)gQXODTUcSzq03Uwx0sy(JiiKXMtl)jsqCogGn91Zi6qngTR1vGndc2CA5prcIZXaSPVUOLWmqAlXEN)PDXys5GYKm72pXyTAbcD3eEd45FAxmMuoOmjtydheuJr7ADfyZG0B4x1RZIwcZFebH8FDoQauCcNvTrbvKzufuJr7ADfyZGOcyKWYFIHLQfTeMjiErJ6BaMKXSqrRwKjHAJ2Ly4i7CyXkOgJ216kWMbHAPu0ODTEmvQwu3c55WQRhRR1fTeMlNUHL)eXwO9WruuI8gQXODTUcSzqOwkfnAxRhtLQf1TqEMvk2PScQXODTUcSzqOwkfnAxRhtLQf1TqEw1MJncgQbQXODTUkZkf7uwntxNYEtSMXrHKfYIwcZ4TZ01PS3eRzCuizHC8Jq8mHdTYvIJ(ea5JiiKXMtl)jsqCogGn91Zi6qngTR1vzwPyNYkWMbX8k0IRqeZwdq0sy(JiiKfJfQxKIg)PDXze9jqdXkCKfd7D2WyvMbQs1kTAjwHJSyyVZggRYLlc4OGwOgJ216QmRuStzfyZGeYHljO4keti0chXe2cvIwcZeeNZDfYXEJGlYdfpbbXlAuFdWeXrL3qngTR1vzwPyNYkWMbjWssyXWLhjSADZPmuJr7ADvMvk2PScSzqiLUEIJLhv6gLfTeMbYhrqiJnNw(tKG4CmaB6RNr0HAGAmAxRRYHvxpwxRplgluVifn(t7IfTeMbWwQbK1PT4O8wRw0aKhYIOpba2snGSoTfFstcTqnqntgkb6C6gw(duITq7HHschmePiCi7nuwkOeDucgHYvakdnGckbWwQbaLQnTIcLO8oyekxbOm0akOeaBPgauwouAq5dzr0ZqngTR1v5WQRhRR1bBgemBnGOQjfOSOLWC50nS8Ni2cThoIIsK53zuqna2snGCObuA1IgG8qwe9jkNUHL)eXwO9WruuIm)oJokOgaBPgqo0ak0c1a1mzOeOD9GbnuM4gknhkzGQuD5pq5R0UyOCaO4egkXKvpd1y0UwxLdRUESUwhSzqWS1aIQMuGYIwcZktmC8N2fhvakoHNOC6gw(teBH2dhrrjY7j(icc5FAxCubO4eoJOpXhrqi)t7IJkafNWzchALReh8mkO(HIHAGAmAxRRYHvxpwxRd2mifL)lIJJclPRgbZIwcZayl1aY60wCuEh8Ob93O(JiiK)PDXrfGIt4mIoAHAGAmAxRRYQ2CSrWZy2AarvtkqzrlHzcIx0O(gGjzmlu0QfFg83tGgG0wI9o)xNv9scZSB)eJ1Qfi0Dt4nGN)RZQEjHzcB4G0Q9JiiKXMtl)jsqCogGn91Zi6OfQXODTUkRAZXgbd2mi)0UymPCqzIOLWmq(icczS50YFIeeNJbytF9mIouJr7ADvw1MJncgSzqcnczdqyhlAjm)reeY)15OcqXjCMWHw5kXbpJcQFO4mdumfPzTArZhrqi)xNJkafNWzchALReFMG4CURqo2BuSA1(reeY)15OcqXjCMWHw5kXNrZdfdgD3eEd45FAxmMuoOmjtydheQBlXEN)PDXys5GYKm72pXyuJoA1Q9JiiK)RZrfGIt4SQnkOIlw0obbXlAuFdWKmMfkA1ImJ(BOgJ216QSQnhBemyZGaGnshzLIDklAjmdKpIGqgBoT8NibX5ya20xpJOd1y0UwxLvT5yJGbBgKFAxC8Vvs0syMcWipSkkqmAxRBjrMbphSNanFebHmaoCvTPkvw1gfuXNrdkbVsNtPyBKhUv5FAxC8VvcTA1Q05uk2g5HBv(N2fh)BLebD0c1y0UwxLvT5yJGbBgKqJq2ae2XIwcZFebH8FDoQauCcNvTrbv85jnrBj278QuigjOm72pX4jiiErJ6BaMKXSqrRwKzWrbQXODTUkRAZXgbd2mi)1zvVKqrlHzcIx0O(gGjImd(73taKpIGqgBoT8NibX5ya20xpJOd1y0UwxLvT5yJGbBgemBnGOQjfOSOLWmbXlAuFdWKmMfkA1IpJgWrbSpIGqgBoT8NibX5ya20xpJOJAuatPZPuSnYd3Qma2iDu1Kcug1TLyVZayJ0FcBGYKm72pXyuJoA1QTRqo2BexS4G)gQXODTUkRAZXgbd2miy2AarZXrmtTGeTeMv6CkfBJ8WTkJzRbenhhXm1csKzXc1y0UwxLvT5yJGbBgeaSr6OQjfOSOLW8hrqiJnNw(tKG4CmaB6RNr01QLG4CURqo2Beve)HIHAmAxRRYQ2CSrWGndYpTlo(3kjAjm)reeYyZPL)ejiohdWM(6zeDOgJ216QSQnhBemyZGGzRbenhhXm1cs0sy(JiiKPKkuTEurxeYdNr01QTTe7DMy6foIz6gQVQQR1ZSB)eJ1QvPZPuSnYd3QmMTgq0CCeZulirMrhQXODTUkRAZXgbd2mi01viH6DTouJr7ADvw1MJncgSzq(PDXX)wjOgJ216QSQnhBemyZGaGnshvnPaLfTeMjioN7kKJ9gfR4puSwTFebH8FDoQauCcNvTrbvKjb1y0UwxLvT5yJGbBgeJqnNJ9siS3IwcZeeVOr9natYywOOvlc6VVHH0awYngvyWbkbdkbAYGwP66RVda]] )

end