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
        width = "full"
    } )


    spec:RegisterPack( "Blood", 20200726, [[dyeDKaqiGKhPiQlrsP0Mue(ejLcJIqYPiuzves9ka1SiOUfqk2Lu(fGmmc4yaXYaQEgjftJaPRri2gHQ(gbIXbKQoNIi16uerZJGCpf1(iuoiqk1cvfEOIizIaPIlQicnsGusNeivALKKxQic2PQOJssPQNQWuvK2Rs)vObtQdtzXQQhJ0KbDzuBgQ(SQ0Ob40IwnqkXRbkZwWTLQ2nv)wLHtIJtsPOLd55enDjxhkBNa13LkgpjLCEsQwpjLkZxQ0(r8cYoDhqR49j4caUaciiGl(giGiaiQr87OuxH3HIrbZE5D4wpVJhH7G7qXupCgCNUd5HHO8ogzpwWQ88jfYWRD8XYqb667FhqR49j4caUaciiGlsd8Divy6(eCreyhasiK99VdilP7yYe9JWDqIg0HTcarpj45lGIOAYenGQuKtsGa6nlay)g96bsM9ybRYZPidVasM9uIQjt0QWcQt0GlIWen4caUaevevtMONuam)LLtsIQjt0GgIwThlPGr0MdjAyIk1jAmfOvmrF4e9dCqBIUoIEaWGxNG5qzBhHuwYD6oyPKDkl3P7tq2P7GD7hy4(yhuuwmkTDaVQrpNYEHSIHr8G1ZXpgYBiU3sxs0cr0Gt0tq0GIO)y44nO500FJimNJDyt58gMYomALNVd65u2lKvmmIhSEER9j470DWU9dmCFSdkklgL2o(y44nbB9kjkPXF4oydtHONGOffrJSegzbZE1miu2y1kLLKO72LOrwcJSGzVAgekBPt0Ir0GicrlUDy0kpFhMN9w8WJq2kaBTpvZoDhSB)ad3h7GIYIrPTdeMZTk75yDrqiAXi6xkKONGOryEsJkxhgr0cr0cQa7WOvE(o65(dPE8WJbmAcJqeB9YT2Nc6oDhgTYZ3rNdfGcMtpIy55Mt5DWU9dmCFS1(uKD6oy3(bgUp2bfLfJsBhGIO)y44nO500FJimNJDyt58gMYomALNVduQOe4y6rPIr5T2Ahqg3Wc1oDFcYoDhgTYZ3rF6WioIz1oEhSB)ad3hBTpbFNUd2TFGH7JDqrzXO02b9Ua864nO500FJimNJDyt58gInO6e9eeTOiAqr007cWRJ3(H7Gqu6GXOgInO6eD3UenOi6YcSxTF4oieLoymQXU9dmKOf3omALNVJF4oyehdP(w7t1St3HrR88D8zKKrGL(7oy3(bgUp2AFkO70DWU9dmCFSdkklgL2omALcMJSZ9jljAXMjAWj6UDjAeMZeTqenie9eencZtAu56WOgKXtAweTyeT4fyhgTYZ3HHOMZrfSGK3AFkYoDhSB)ad3h7GIYIrPTJpgoEdZbCb1JYcX(BbOHPSdJw557iKVakze0cg8TN9AR9P43P7WOvE(omNYYczHi1cHDWU9dmCFS1(uq2P7WOvE(oWte)d3b3b72pWW9Xw7tq)oDhgTYZ3X3EJhESqjfm5oy3(bgUp2AFoP3P7GD7hy4(yhuuwmkTDqVlaVoEdAon93icZ5yh2uoVH4ElDjrlgrpPfyhgTYZ3bMKJzX9YT2NGiWoDhSB)ad3h7GIYIrPTJpgoEdAon93icZ5yh2uoVHPSdJw557q5Q88T2NGaYoDhSB)ad3h7GIYIrPTdeMZYwL9CSUiieTye9lfUdJw5574hUdgltzR9jiGVt3b72pWW9XoOOSyuA74JHJ3(NZrjGKdWMSmkyeTyZeTGSdJw557OU(VSoN3AFcIA2P7GD7hy4(yhuuwmkTDGW8KgvUomQbz8KMfrlgrlEIw0eTrRuWCKDUpz5omALNVdzhd1N(BSpL1w7tqe0D6oy3(bgUp2bfLfJsBhGIOv4QzHuW8omALNVdKLsoczdU1(eer2P7GD7hy4(yhuuwmkTDakIUSa7v7hUdcrPdgJASB)adj6UDjAqr007cWRJ3(H7Gqu6GXOgInO67WOvE(oGMtt)nIWCo2HnLZ3AFcI43P7GD7hy4(yhuuwmkTDKo96t)ncTE7LJIijAXiAb2HrR88DqTqiA0kppgszTJqkROB98o6ZkFTkpFR9jicYoDhSB)ad3h7WOvE(oOwienALNhdPS2riLv0TEEhSuYoLLBTpbb0Vt3b72pWW9XomALNVdQfcrJw55XqkRDeszfDRN3HSmhAi4wBTdfetV(Vv709ji70DWU9dmCFS1(e8D6oy3(bgUp2AFQMD6oy3(bgUp2AFkO70DWU9dmCFS1(uKD6omALNVdLRYZ3b72pWW9XwBTJ(SYxRYZ3P7tq2P7GD7hy4(yhuuwmkTDaGTqbOPqlIwiIwebi6UDjArr0GIOFrhMcrpbrdGTqbOPqlIwiIw8INOf3omALNVdbB9kjkPXF4o4w7tW3P7GD7hy4(yhuuwmkTDKo96t)ncTE7LJQrs0Int0ayluaAumeI9AhgTYZ3bKTcquwOemER9PA2P7GD7hy4(yhuuwmkTDinbZXF4oyuci5aKONGOtNE9P)gHwV9YrrKeTyeTae9ee9hdhV9d3bJsajhGnmfIEcI(JHJ3(H7GrjGKdWgI7T0LeTqeninriArt0Vu4omALNVdiBfGOSqjy8w7tbDNUd2TFGH7JDqrzXO02ba2cfGMcTiAHiAreGObneTOiAWfGOfnr)XWXB)WDWOeqYbydtHOf3omALNVJKY)dZHr8dvzHb5T2NISt3b72pWW9XoOOSyuA7aaBHcqtHweTqeTGicrpbrRWv7fWHfAiU3sxs0cr0ISdJw557qAuuIN00crfJwBT1oKL5qdb3P7tq2P7GD7hy4(yhuuwmkTDGW8KgvUomQbz8KMfrl0mrdIae9eeTOiAqr0LfyVA)ZzzDO(g72pWqIUBxIguen9Ua864T)5SSouFdXguDIUBxI(JHJ3GMtt)nIWCo2HnLZBykeT42HrR88DazRaeLfkbJ3AFc(oDhSB)ad3h7GIYIrPTdfUAVaoSqdX9w6sIwiI(LcjArt0GVdJw557qAuuIN00crfJwBTpvZoDhSB)ad3h7GIYIrPTdqr0FmC8g0CA6VreMZXoSPCEdtzhgTYZ3XpCheIshmgT1(uq3P7GD7hy4(yhuuwmkTD8XWXB)Z5OeqYbydX9w6sIwiIgKMieTOj6xkSXQftXkMO72LOffr)XWXB)Z5OeqYbydX9w6sIwOzIgH5CRYEowxuneD3Ue9hdhV9pNJsajhGne3BPljAHMjArr0VuirdmrtVlaVoE7hUdcrPdgJAi2GQt0IMOllWE1(H7Gqu6GXOg72pWqIw0en4eT4i6UDj6pgoE7FohLasoaBYYOGr0cr0QHOfhrpbrJW8KgvUomQbz8KMfrl2mrdUa7WOvE(o6ne66GyhU1(uKD6oy3(bgUp2bfLfJsBhGIO)y44nO500FJimNJDyt58gMYomALNVdaSHQilLSt5T2NIFNUd2TFGH7JDqrzXO02bfGHEzzehz0kp3ceTyZeninqprpbrlkI(JHJ3aW9NSmzkBYYOGr0cnt0IIOfHObneTuHdHyzOxUKTF4oy8FzGOfhr3Tlrlv4qiwg6Llz7hUdg)xgiAXiAWjAXTdJw5574hUdg)xg2AFki70DWU9dmCFSdkklgL2o(y44T)5Cuci5aSjlJcgrl0mrlEIEcIUSa7v7KsmdPEJD7hyirpbrJW8KgvUomQbz8KMfrl2mrdIi7WOvE(o6ne66GyhU1(e0Vt3b72pWW9XoOOSyuA7aH5jnQCDyerl2mrdIacq0tq0GIO)y44nO500FJimNJDyt58gMYomALNVJ)5SSou)w7Zj9oDhSB)ad3h7GIYIrPTdeMN0OY1HrniJN0SiAHMjArr0Gicrdmr)XWXBqZPP)gryoh7WMY5nmfIw0eTienWeTuHdHyzOxUKnaSHQOSqjymrlAIUSa7vdaBO6Jydmg1y3(bgs0IMObNOfhr3TlrxzphRlctMOfIObrGDy0kpFhq2karzHsW4T2NGiWoDhSB)ad3h7GIYIrPTdPchcXYqVCjBq2karZHritn1jAXMjA1SdJw557aYwbiAomczQP(w7tqazNUd2TFGH7JDqrzXO02XhdhVbnNM(BeH5CSdBkN3Wui6UDjAeMZTk75yDrbLOfIOFPWDy0kpFhaydvrzHsW4T2NGa(oDhSB)ad3h7GIYIrPTJpgoEdAon93icZ5yh2uoVHPSdJw5574hUdg)xg2AFcIA2P7GD7hy4(yhuuwmkTD8XWXBuu2lppkPhg6LBykeD3UeDzb2RgYusyeY0Rx5KzLN3y3(bgs0D7s0sfoeILHE5s2GSvaIMdJqMAQt0Int0GVdJw557aYwbiAomczQP(w7tqe0D6omALNVd65sSELkpFhSB)ad3hBTpbrKD6omALNVJF4oy8FzyhSB)ad3hBTpbr870DWU9dmCFSdkklgL2oqyo3QSNJ1fvdrler)sHeD3Ue9hdhV9pNJsajhGnzzuWiAXiAXVdJw557aaBOkklucgV1(eebzNUd2TFGH7JDqrzXO02bcZtAu56WOgKXtAweTyen4cSdJw557WquZ5yDie71wBT1oemJK557tWfaCbeqqaxKg47OJH80FL7a0Tx5qfdjAriAJw55eDiLLSruTddRaCODmY(jfrdmrdALbld5ouqhEg4DmzI(r4oird6WwbGONe88fqrunzIgqvkYjjqa9MfaSFJE9ajZESGv55uKHxajZEkr1KjAvyb1jAWfryIgCbaxaIkIQjt0tkaM)YYjjr1KjAqdrR2JLuWiAZHenmrL6enMc0kMOpCI(boOnrxhrpayWRtWCOSrurunzIEsuTykwXqI(Z4hIjA61)TIO)8B6YgrdAtPSsjjA)Cqdad1JJfiAJw55sI(8G6nIkJw55YMcIPx)3Qz8GjbJOYOvEUSPGy61)Tc4zGWVdsuz0kpx2uqm96)wb8mqg2Bp7Lv55evtMOhUPibCfrJSes0FmCCgs0YYkjr)z8dXen96)wr0F(nDjrBoKOvqmOr5Qk9xIoLen8CUruz0kpx2uqm96)wb8mqs3uKaUkklRKevgTYZLnfetV(VvapdKYv55evevtMONevlMIvmKOzbZi1j6k7zIUaWeTrRdr0PKOnbBzW(bUruz0kpxo3NomIJywTJjQmALNlbEgOF4oyehdPUWj(m9Ua864nO500FJimNJDyt58gInO6tikqrVlaVoE7hUdcrPdgJAi2GQ3TlOklWE1(H7Gqu6GXOg72pWqXruz0kpxc8mqFgjzeyP)suz0kpxc8mqgIAohvWcsw4eF2OvkyoYo3NSuSzW72fH5SqGmbcZtAu56WOgKXtAwIjEbiQmALNlbEgOq(cOKrqlyW3E2lHt85pgoEdZbCb1JYcX(BbOHPquz0kpxc8mqMtzzHSqKAHarLrR8CjWZaHNi(hUdsuz0kpxc8mqF7nE4XcLuWKevgTYZLapdeMKJzX9sHt8z6Db41XBqZPP)gryoh7WMY5ne3BPlfBslarLrR8CjWZaPCvEUWj(8hdhVbnNM(BeH5CSdBkN3WuiQmALNlbEgOF4oySmfHt8zeMZYwL9CSUiiI9sHevgTYZLapduD9FzDolCIp)XWXB)Z5OeqYbytwgfmXMfeIkJw55sGNbs2Xq9P)g7tzjCIpJW8KgvUomQbz8KMLyIx0gTsbZr25(KLevgTYZLapdeYsjhHSbfoXNbLcxnlKcMjQmALNlbEgiO500FJimNJDyt5CHt8zqvwG9Q9d3bHO0bJrn2TFGHD7ck6Db41XB)WDqikDWyudXguDIkJw55sGNbIAHq0OvEEmKYsy3655(SYxRYZfoXNtNE9P)gHwV9YrrKIjarLrR8CjWZarTqiA0kppgszjSB98mlLStzjrLrR8CjWZarTqiA0kppgszjSB98SSmhAiirfrLrR8CzJLs2PSCMEoL9czfdJ4bRNfoXNHx1ONtzVqwXWiEW654hd5ne3BPlfc8ja1hdhVbnNM(BeH5CSdBkN3WuiQmALNlBSuYoLLapdK5zVfp8iKTcGWj(8hdhVjyRxjrjn(d3bByktikKLWily2RMbHYgRwPSKD7ISegzbZE1miu2sxmqerCevgTYZLnwkzNYsGNbQN7pK6XdpgWOjmcrS1lfoXNryo3QSNJ1fbrSxkCceMN0OY1HrcjOcquz0kpx2yPKDklbEgOohkafmNEeXYZnNYevgTYZLnwkzNYsGNbcLkkboMEuQyuw4eFguFmC8g0CA6VreMZXoSPCEdtHOIOYOvEUS1Nv(AvE(SGTELeL04pChu4eFgaBHcqtHwcjIaD7kkq9IomLjaWwOa0uOLqIx8IJOIOAYenORtV(0FjAO1BVmrJy1MyjI7zVi6us0GlIAlrF4eDVPwena2cfaIwEHtyIwebuBj6dNO7n1IObWwOaq0Pt0gr)IomLgrLrR8CzRpR81Q8CGNbcYwbiklucglCIpNo96t)ncTE7LJQrk2ma2cfGgfdHyViQiQMmrd6CUAJIOdCr0Mt0SALYk9xI(r4oirpaKCas0q0P0iQmALNlB9zLVwLNd8mqq2karzHsWyHt8zPjyo(d3bJsajhGtKo96t)ncTE7LJIiftGj(y44TF4oyuci5aSHPmXhdhV9d3bJsajhGne3BPlfcKMiI(LcjQiQmALNlB9zLVwLNd8mqjL)hMdJ4hQYcdYcN4ZayluaAk0sirea0ikWfq0FmC82pChmkbKCa2WuehrfrLrR8CzRpR81Q8CGNbsAuuIN00crfJwcN4ZayluaAk0sibrKju4Q9c4Wcne3BPlfseIkIkJw55YMSmhAi4mKTcquwOemw4eFgH5jnQCDyudY4jnlHMbrGjefOklWE1(NZY6q9n2TFGHD7ck6Db41XB)ZzzDO(gInO6D7(XWXBqZPP)gryoh7WMY5nmfXruz0kpx2KL5qdbbEgiPrrjEstlevmAjCIpRWv7fWHfAiU3sxk0lfkAWjQmALNlBYYCOHGapd0pCheIshmgjCIpdQpgoEdAon93icZ5yh2uoVHPquz0kpx2KL5qdbbEgOEdHUoi2HcN4ZFmC82)CokbKCa2qCVLUuiqAIi6xkSXQftXkUBxr9XWXB)Z5OeqYbydX9w6sHMryo3QSNJ1fvt3UFmC82)CokbKCa2qCVLUuOzr9sHatVlaVoE7hUdcrPdgJAi2GQl6YcSxTF4oieLoymQXU9dmu0GlUUD)y44T)5Cuci5aSjlJcMqQrCtGW8KgvUomQbz8KMLyZGlarLrR8CztwMdnee4zGaWgQISuYoLfoXNb1hdhVbnNM(BeH5CSdBkN3WuiQmALNlBYYCOHGapd0pChm(VmiCIptbyOxwgXrgTYZTGyZG0a9tiQpgoEda3FYYKPSjlJcMqZIseqJuHdHyzOxUKTF4oy8FzqCD7kv4qiwg6Llz7hUdg)xgedCXruz0kpx2KL5qdbbEgOEdHUoi2HcN4ZFmC82)CokbKCa2KLrbtOzXprzb2R2jLygs9g72pWWjqyEsJkxhg1GmEsZsSzqeHOYOvEUSjlZHgcc8mq)ZzzDOEHt8zeMN0OY1HrIndIacmbO(y44nO500FJimNJDyt58gMcrLrR8CztwMdnee4zGGSvaIYcLGXcN4ZimpPrLRdJAqgpPzj0SOareG)y44nO500FJimNJDyt58gMIOfbyPchcXYqVCjBaydvrzHsWyrxwG9QbGnu9rSbgJASB)adfn4IRB3k75yDryYcbIaevgTYZLnzzo0qqGNbcYwbiAomczQPUWj(SuHdHyzOxUKniBfGO5WiKPM6InRgIkJw55YMSmhAiiWZabGnufLfkbJfoXN)y44nO500FJimNJDyt58gMs3UimNBv2ZX6IcQqVuirLrR8CztwMdnee4zG(H7GX)LbHt85pgoEdAon93icZ5yh2uoVHPquz0kpx2KL5qdbbEgiiBfGO5WiKPM6cN4ZFmC8gfL9YZJs6HHE5gMs3ULfyVAitjHritVELtMvEEJD7hyy3UsfoeILHE5s2GSvaIMdJqMAQl2m4evgTYZLnzzo0qqGNbIEUeRxPYZjQmALNlBYYCOHGapd0pChm(Vmquz0kpx2KL5qdbbEgiaSHQOSqjySWj(mcZ5wL9CSUOAe6Lc729JHJ3(NZrjGKdWMSmkyIjEIkJw55YMSmhAiiWZaziQ5CSoeI9s4eFgH5jnQCDyudY4jnlXaxGT2Axa]] )

end