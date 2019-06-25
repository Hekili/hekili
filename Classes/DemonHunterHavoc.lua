-- DemonHunterHavoc.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'DEMONHUNTER' then
    local spec = Hekili:NewSpecialization( 577 )

    spec:RegisterResource( Enum.PowerType.Fury, {
        prepared = {
            talent = "momentum",
            aura   = "prepared",

            last = function ()
                local app = state.buff.prepared.applied
                local t = state.query_time

                local step = 0.1

                return app + floor( t - app )
            end,

            interval = 1,
            value = 8
        },

        immolation_aura = {
            talent  = "immolation_aura",
            aura    = "immolation_aura",

            last = function ()
                local app = state.buff.immolation_aura.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 7
        },

        blind_fury = {
            talent = "blind_fury",
            aura = "eye_beam",

            last = function ()
                local app = state.buff.eye_beam.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 40,
        }
    } )

    -- Talents
    spec:RegisterTalents( {
        blind_fury = 21854, -- 203550
        demonic_appetite = 22493, -- 206478
        felblade = 22416, -- 232893

        insatiable_hunger = 21857, -- 258876
        demon_blades = 22765, -- 203555
        immolation_aura = 22799, -- 258920

        trail_of_ruin = 22909, -- 258881
        fel_mastery = 22494, -- 192939
        fel_barrage = 21862, -- 258925

        soul_rending = 21863, -- 204909
        desperate_instincts = 21864, -- 205411
        netherwalk = 21865, -- 196555

        cycle_of_hatred = 21866, -- 258887
        first_blood = 21867, -- 206416
        dark_slash = 21868, -- 258860

        unleashed_power = 21869, -- 206477
        master_of_the_glaive = 21870, -- 203556
        fel_eruption = 22767, -- 211881

        demonic = 21900, -- 213410
        momentum = 21901, -- 206476
        nemesis = 22547, -- 206491
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3426, -- 208683
        relentless = 3427, -- 196029
        adaptation = 3428, -- 214027

        cover_of_darkness = 1206, -- 227635
        demonic_origins = 810, -- 235893
        detainment = 812, -- 205596
        eye_of_leotheras = 807, -- 206649
        glimpse = 1204, -- 203468
        mana_break = 813, -- 203704
        mana_rift = 809, -- 235903
        rain_from_above = 811, -- 206803
        reverse_magic = 806, -- 205604
        solitude = 805, -- 211509
        unending_hatred = 1218, -- 213480
    } )


    -- Auras
    spec:RegisterAuras( {
        blade_dance = {
            id = 188499,
            duration = 1,
            max_stack = 1,
        },
        blur = {
            id = 212800,
            duration = 10,
            max_stack = 1,
        },
        chaos_brand = {
            id = 1490,
            duration = 60,
            max_stack = 1,
        },
        chaos_nova = {
            id = 179057,
            duration = 2,
            type = "Magic",
            max_stack = 1,
        },
        dark_slash = {
            id = 258860,
            duration = 8,
            max_stack = 1,
        },
        darkness = {
            id = 196718,
            duration = 7.917,
            max_stack = 1,
        },
        death_sweep = {
            id = 210152,
        },
        demon_blades = {
            id = 203555,
        },
        demonic_wards = {
            id = 278386,
        },
        double_jump = {
            id = 196055,
        },
        eye_beam = {
            id = 198013,
        },
        fel_barrage = {
            id = 258925,
        },
        fel_eruption = {
            id = 211881,
            duration = 4,
            max_stack = 1,
        },
        glide = {
            id = 131347,
            duration = 3600,
            max_stack = 1,
        },
        immolation_aura = {
            id = 258920,
            duration = 10,
            max_stack = 1,
        },
        master_of_the_glaive = {
            id = 213405,
            duration = 6,
            max_stack = 1,
        },
        metamorphosis = {
            id = 162264,
            duration = function () return pvptalent.demonic_origins.enabled and 15 or 30 end,
            max_stack = 1,
            meta = {
                extended_by_demonic = function ()
                    return false -- disabled in 8.0:  talent.demonic.enabled and ( buff.metamorphosis.up and buff.metamorphosis.duration % 15 > 0 and buff.metamorphosis.duration > ( action.eye_beam.cast + 8 ) )
                end,
            },
        },
        momentum = {
            id = 208628,
            duration = 6,
            max_stack = 1,
        },
        nemesis = {
            id = 206491,
            duration = 60,
            max_stack = 1,
        },
        netherwalk = {
            id = 196555,
            duration = 5,
            max_stack = 1,
        },
        prepared = {
            id = 203650,
            duration = 10,
            max_stack = 1,
        },
        shattered_souls = {
            id = 178940,
        },
        spectral_sight = {
            id = 188501,
            duration = 10,
            max_stack = 1,
        },
        torment = {
            id = 281854,
            duration = 3,
            max_stack = 1,
        },
        trail_of_ruin = {
            id = 258883,
            duration = 4,
            max_stack = 1,
        },
        vengeful_retreat = {
            id = 198793,
            duration = 3,
            max_stack = 1,
        },

        -- PvP Talents
        eye_of_leotheras = {
            id = 206649,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },

        mana_break = {
            id = 203704,
            duration = 10,
            max_stack = 1,
        },

        rain_from_above_launch = {
            id = 206803,
            duration = 1,
            max_stack = 1,
        },

        rain_from_above = {
            id = 206804,
            duration = 10,
            max_stack = 1,
        },

        solitude = {
            id = 211510,
            duration = 3600,
            max_stack = 1
        },

        -- Azerite
        thirsting_blades = {
            id = 278736,
            duration = 30,
            max_stack = 40,
            meta = {
                stack = function ( t )
                    if t.down then return 0 end
                    return min( 40, t.count + floor( query_time - t.applied ) )
                end,
            }
        }
    } )


    local last_darkness = 0
    local last_metamorphosis = 0
    local last_eye_beam = 0

    spec:RegisterStateExpr( "darkness_applied", function ()
        return max( class.abilities.darkness.lastCast, last_darkness )
    end )

    spec:RegisterStateExpr( "metamorphosis_applied", function ()
        return max( class.abilities.darkness.lastCast, last_metamorphosis )
    end )

    spec:RegisterStateExpr( "eye_beam_applied", function ()
        return max( class.abilities.eye_beam.lastCast, last_eye_beam )
    end )

    spec:RegisterStateExpr( "extended_by_demonic", function ()
        return buff.metamorphosis.up and buff.metamorphosis.extended_by_demonic
    end )


    spec:RegisterStateExpr( "meta_cd_multiplier", function ()
        return 1
    end )

    spec:RegisterHook( "reset_precast", function ()
        last_darkness = 0
        last_metamorphosis = 0
        last_eye_beam = 0

        local rps = 0

        if equipped.convergence_of_fates then
            rps = rps + ( 3 / ( 60 / 4.35 ) )
        end

        if equipped.delusions_of_grandeur then
            -- From SimC model, 1/13/2018.
            local fps = 10.2 + ( talent.demonic.enabled and 1.2 or 0 ) + ( ( level < 116 and equipped.anger_of_the_halfgiants ) and 1.8 or 0 )

            if level < 116 and set_bonus.tier19_2pc > 0 then fps = fps * 1.1 end

            -- SimC uses base haste, we'll use current since we recalc each time.
            fps = fps / haste

            -- Chaos Strike accounts for most Fury expenditure.
            fps = fps + ( ( fps * 0.9 ) * 0.5 * ( 40 / 100 ) )

            rps = rps + ( fps / 30 ) * ( 1 )
        end

        meta_cd_multiplier = 1 / ( 1 + rps )
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if level < 116 and equipped.delusions_of_grandeur and resource == 'fury' then
            -- revisit this if really needed... 
            cooldown.metamorphosis.expires = cooldown.metamorphosis.expires - ( amt / 30 )
        end
    end )

    spec:RegisterCycle( function ()
        if active_enemies == 1 then return end

        -- For Nemesis, we want to cast it on the lowest health enemy.
        if this_action == "nemesis" and Hekili:GetNumTTDsWithin( tagret.time_to_die ) > 1 then return "cycle" end
    end )


    -- Gear Sets
    spec:RegisterGear( 'tier19', 138375, 138376, 138377, 138378, 138379, 138380 )
    spec:RegisterGear( 'tier20', 147130, 147132, 147128, 147127, 147129, 147131 )
    spec:RegisterGear( 'tier21', 152121, 152123, 152119, 152118, 152120, 152122 )
        spec:RegisterAura( 'havoc_t21_4pc', {
            id = 252165,
            duration = 8 
        } )

    spec:RegisterGear( 'class', 139715, 139716, 139717, 139718, 139719, 139720, 139721, 139722 )

    spec:RegisterGear( 'convergence_of_fates', 140806 )

    spec:RegisterGear( 'achor_the_eternal_hunger', 137014 )
    spec:RegisterGear( 'anger_of_the_halfgiants', 137038 )
    spec:RegisterGear( 'cinidaria_the_symbiote', 133976 )
    spec:RegisterGear( 'delusions_of_grandeur', 144279 )
    spec:RegisterGear( 'kiljaedens_burning_wish', 144259 )
    spec:RegisterGear( 'loramus_thalipedes_sacrifice', 137022 )
    spec:RegisterGear( 'moarg_bionic_stabilizers', 137090 )
    spec:RegisterGear( 'prydaz_xavarics_magnum_opus', 132444 )
    spec:RegisterGear( 'raddons_cascading_eyes', 137061 )
    spec:RegisterGear( 'sephuzs_secret', 132452 )
    spec:RegisterGear( 'the_sentinels_eternal_refuge', 146669 )

    spec:RegisterGear( "soul_of_the_slayer", 151639 )
    spec:RegisterGear( "chaos_theory", 151798 )
    spec:RegisterGear( "oblivions_embrace", 151799 )



    -- Abilities
    spec:RegisterAbilities( {
        annihilation = {
            id = 201427,
            known = 162794,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 40 - buff.thirsting_blades.stack end,
            spendType = "fury",

            startsCombat = true,
            texture = 1303275,

            bind = "chaos_strike",
            buff = "metamorphosis",

            handler = function ()
                removeBuff( "thirsting_blades" )
                if azerite.thirsting_blades.enabled then applyBuff( "thirsting_blades", nil, 0 ) end
            end,
        },


        blade_dance = {
            id = 188499,
            cast = 0,
            cooldown = 9,
            hasteCD = true,
            gcd = "spell",

            spend = function () return 35 - ( talent.first_blood.enabled and 20 or 0 ) end,
            spendType = "fury",

            startsCombat = true,
            texture = 1305149,

            bind = "death_sweep",
            nobuff = "metamorphosis",

            handler = function ()
                applyBuff( "blade_dance" )
                setCooldown( "death_sweep", 9 * haste )
                if level < 116 and set_bonus.tier20_2pc == 1 and target.within8 then gain( buff.solitude.up and 22 or 20, 'fury' ) end
            end,
        },


        blur = {
            id = 198589,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            toggle = "defensives",

            startsCombat = false,
            texture = 1305150,

            handler = function ()
                applyBuff( "blur" )
            end,
        },


        chaos_nova = {
            id = 179057,
            cast = 0,
            cooldown = function () return talent.unleashed_power.enabled and 40 or 60 end,
            gcd = "spell",

            spend = function () return talent.unleashed_power.enabled and 0 or 30 end,
            spendType = "fury",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135795,

            handler = function ()
                applyDebuff( "target", "chaos_nova" )
            end,
        },


        chaos_strike = {
            id = 162794,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 40 - buff.thirsting_blades.stack end,
            spendType = "fury",

            startsCombat = true,
            texture = 1305152,

            bind = "annihilation",
            nobuff = "metamorphosis",

            handler = function ()
                removeBuff( "thirsting_blades" )
                if azerite.thirsting_blades.enabled then applyBuff( "thirsting_blades", nil, 0 ) end
            end,
        },


        consume_magic = {
            id = 278326,
            cast = 0,
            cooldown = 10,
            gcd = "off",

            startsCombat = true,
            texture = 828455,

            usable = function () return buff.dispellable_magic.up end,
            handler = function ()
                removeBuff( "dispellable_magic" )
                gain( buff.solitude.up and 22 or 20, "fury" )
            end,
        },


        dark_slash = {
            id = 258860,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            startsCombat = true,
            texture = 136189,

            talent = "dark_slash",

            handler = function ()
                applyDebuff( "target", "dark_slash" )
            end,
        },


        darkness = {
            id = 196718,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = true,
            texture = 1305154,

            handler = function ()
                last_darkness = query_time
                applyBuff( "darkness" )
            end,
        },


        death_sweep = {
            id = 210152,
            known = 188499,
            cast = 0,
            cooldown = 9,
            hasteCD = true,
            gcd = "spell",

            spend = function () return 35 - ( talent.first_blood.enabled and 20 or 0 ) end,
            spendType = "fury",

            startsCombat = true,
            texture = 1309099,

            bind = "blade_dance",
            buff = "metamorphosis",

            handler = function ()
                applyBuff( "death_sweep" )
                setCooldown( "blade_dance", 9 * haste )
                if level < 116 and set_bonus.tier20_2pc == 1 and target.within8 then gain( buff.solitude.up and 22 or 20, "fury" ) end
            end,
        },


        demons_bite = {
            id = 162243,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.solitude.up and -22 or -20 end,
            spendType = "fury",

            startsCombat = true,
            texture = 135561,

            notalent = "demon_blades",

            handler = function ()
                if level < 116 and equipped.anger_of_the_halfgiants then gain( 1, "fury" ) end
            end,
        },


        disrupt = {
            id = 183752,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            startsCombat = true,
            texture = 1305153,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
                gain( buff.solitude.up and 33 or 30, "fury" )
            end,
        },


        eye_beam = {
            id = 198013,
            cast = function () return 2 + ( talent.blind_fury.enabled and 1 or 0 ) end,
            cooldown = function ()
                if level < 116 and equipped.raddons_cascading_eyes then return 30 - active_enemies end
                return 30
            end,
            channeled = true,
            gcd = "spell",

            spend = 30,
            spendType = "fury",

            startsCombat = true,
            texture = 1305156,

            handler = function ()
                -- not sure if we need to model blind_fury gains.
                -- if talent.blind_fury.enabled then gain( 120, "fury" ) end

                last_eye_beam = query_time

                if talent.demonic.enabled then
                    if buff.metamorphosis.up then
                        buff.metamorphosis.duration = buff.metamorphosis.remains + 8
                        buff.metamorphosis.expires = buff.metamorphosis.expires + 8
                    else
                        applyBuff( "metamorphosis", action.eye_beam.cast + 8 )
                        buff.metamorphosis.duration = action.eye_beam.cast + 8
                        stat.haste = stat.haste + 25
                    end
                end
            end,
        },


        eye_of_leotheras = {
            id = 206649,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "eye_of_leotheras",

            startsCombat = true,
            texture = 1380366,

            handler = function ()
                applyDebuff( "target", "eye_of_leotheras" )
            end,
        },


        fel_barrage = {
            id = 258925,
            cast = 2,
            cooldown = 60,
            channeled = true,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 2065580,

            talent = "fel_barrage",

            handler = function ()
                applyBuff( "fel_barrage", 2 )
            end,
        },


        fel_eruption = {
            id = 211881,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 10,
            spendType = "fury",

            startsCombat = true,
            texture = 1118739,

            talent = "fel_eruption",

            handler = function ()
                applyDebuff( "target", "fel_eruption" )
            end,
        },


        fel_rush = {
            id = 195072,
            cast = 0,
            charges = 2,
            cooldown = 10,
            recharge = 10,
            gcd = "spell",

            startsCombat = true,
            texture = 1247261,

            usable = function ()
                if settings.recommend_movement ~= true then return false, "fel_rush movement is disabled" end
                return not prev_gcd[1].fel_rush
            end,            
            handler = function ()
                if talent.momentum.enabled then applyBuff( "momentum" ) end
                if cooldown.vengeful_retreat.remains < 1 then setCooldown( 'vengeful_retreat', 1 ) end
                setDistance( 5 )
                setCooldown( "global_cooldown", 0.25 )
            end,
        },


        felblade = {
            id = 232893,
            cast = 0,
            cooldown = 15,
            hasteCD = true,
            gcd = "spell",

            spend = function () return buff.solitude.up and -44 or -40 end,
            spendType = "fury",

            startsCombat = true,
            texture = 1344646,

            -- usable = function () return target.within15 end,        
            handler = function ()
                setDistance( 5 )
            end,
        },


        fel_lance = {
            id = 206966,
            cast = 1,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "rain_from_above",
            buff = "rain_from_above",

            startsCombat = true,
        },


        --[[ glide = {
            id = 131347,
            cast = 0,
            cooldown = 1.5,
            gcd = "spell",

            startsCombat = true,
            texture = 1305157,

            handler = function ()
            end,
        }, ]]


        immolation_aura = {
            id = 258920,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 1344649,

            talent = "immolation_aura",

            handler = function ()
                applyBuff( "immolation_aura" )
                gain( buff.solitude.up and 11 or 10, "fury" )
            end,
        },


        imprison = {
            id = 217832,
            cast = 0,
            cooldown = function () return pvptalent.detainment.enabled and 60 or 45 end,
            gcd = "spell",

            startsCombat = false,
            texture = 1380368,

            handler = function ()
                applyDebuff( "target", "imprison" )
            end,
        },


        mana_break = {
            id = 203704,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 50,
            spendType = "fury",

            pvptalent = "mana_break",

            startsCombat = true,
            texture = 1380369,

            handler = function ()
                applyDebuff( "target", "mana_break" )
            end,
        },


        mana_rift = {
            id = 235903,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 50,
            spendType = "fury",

            pvptalent = "mana_rift",

            startsCombat = true,
            texture = 1033912,

            handler = function ()
            end,
        },


        metamorphosis = {
            id = 191427,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( pvptalent.demonic_origins.up and 120 or 240 ) end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 1247262,

            handler = function ()
                applyBuff( "metamorphosis" )
                last_metamorphosis = query_time
                stat.haste = stat.haste + 25
                setDistance( 5 )

                if azerite.chaotic_transformation.enabled then
                    setCooldown( "eye_beam", 0 )
                    setCooldown( "blade_dance", 0 )
                    setCooldown( "death_sweep", 0 )
                end
            end,

            meta = {
                adjusted_remains = function ()
                    if level < 116 and ( equipped.delusions_of_grandeur or equipped.convergeance_of_fates ) then
                        return cooldown.metamorphosis.remains * meta_cd_multiplier
                    end

                    return cooldown.metamorphosis.remains
                end
            }
        },


        nemesis = {
            id = 206491,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 236299,

            talent = "nemesis",

            handler = function ()
                applyDebuff( "target", "nemesis" )
            end,
        },


        netherwalk = {
            id = 196555,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = true,
            texture = 463284,

            talent = "netherwalk",

            handler = function ()
                applyBuff( "netherwalk" )
                setCooldown( "global_cooldown", 5 )
            end,
        },


        rain_from_above = {
            id = 206803,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            pvptalent = "rain_from_above",

            startsCombat = false,
            texture = 1380371,

            handler = function ()
                applyBuff( "rain_from_above" )
            end,
        },


        reverse_magic = {
            id = 205604,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            -- toggle = "cooldowns",
            pvptalent = "reverse_magic",

            startsCombat = false,
            texture = 1380372,

            handler = function ()
                if debuff.reversible_magic.up then removeDebuff( "player", "reversible_magic" ) end
            end,
        },


        --[[ spectral_sight = {
            id = 188501,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 1247266,

            handler = function ()
                -- applies spectral_sight (188501)
            end,
        }, ]]


        throw_glaive = {
            id = 185123,
            cast = 0,
            charges = function () return talent.master_of_the_glaive.enabled and 2 or nil end,
            cooldown = 9,
            recharge = 9,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 1305159,

            handler = function ()
                if talent.master_of_the_glaive.enabled then applyDebuff( "target", "master_of_the_glaive" ) end
            end,
        },


        torment = {
            id = 281854,
            cast = 0,
            cooldown = 8,
            gcd = "off",

            startsCombat = true,
            texture = 1344654,

            handler = function ()
                applyDebuff( "target", "torment" )
            end,
        },


        vengeful_retreat = {
            id = 198793,
            cast = 0,
            cooldown = function () return talent.momentum.enabled and 20 or 25 end,
            gcd = "spell",

            startsCombat = true,
            texture = 1348401,

            usable = function ()
                if settings.recommend_movement ~= true then return false, "vengeful_retreat movement is disabled" end
                return true
            end,

            handler = function ()
                if target.within8 then
                    applyDebuff( "target", "vengeful_retreat" )
                    if talent.momentum.enabled then applyBuff( "prepared" ) end
                end

                if pvptalent.glimpse.enabled then applyBuff( "blur", 3 ) end
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 7,

        damage = true,
        damageExpiration = 8,

        potion = "battle_potion_of_agility",

        package = "Havoc",
    } )


    spec:RegisterSetting( "recommend_movement", false, {
        name = "Recommend |T1247261:0|t Fel Rush / |T1348401:0|t Vengeful Retreat",
        desc = "If checked, the addon will recommend |T1247261:0|t Fel Rush / |T1348401:0|t Vengeful Retreat when it is a potential DPS gain.\n\n" ..
            "These abilities are critical for DPS when using the Momentum talent.\n\n" ..
            "If not using Momentum, you may want to leave this disabled to avoid unnecessary movement in combat.",
        type = "toggle",
        width = 1.5
    } )


    -- 587c02a72bd50631ec7949f7b257a3fab1d7100f
    spec:RegisterPack( "Havoc", 20190625.0925, [[dWep6aqisflcsvXJivQnbbFcsvPrPq5uuv1QivIEfrQzrkClis2fv(feAyufogvrltr4zuvPPrQKUgKkBdsv(McvmoQQiNJQkSoiI6DqKsMheH7bj7Ju0bHuv1cjsEOcvvtKuj0fHiLAJkujFKQkkJeIuCssLGvsvzMkuvQBcPQYoHuwkeP6PQyQquxvHk1xvOQySkuvYEv1FLyWuCyulwLEmLMmIld2mr9zsPrtQ60IETIOzJ0TL0Uf(TsdNioovvuTCcpNKPl11vW2vuFxHmEfQY5vKwperMpvP9d1VNpY)HWn8OnHhE6hEGEtGoNh(XeJZe(9p9ujWFKW2jzTWFcUc)bPHNx7FKWtPltEK)JAhew4p67wIcjJiIAZw)W1z3kIQSoq5o3Wky5grvwTi(N7qsBDH4V)HWn8OnHhE6hEGEtGoNh(XeJJN(XFusa7Jg6gNX5p6tcbI)(hcOS)r3ydsdpVwSrxeQBGnindrdcSpDJn67wIcjJiIAZw)W1z3kIQSoq5o3Wky5grvwTiI9PBSX3qayZeOtdSzcp80pWgKcB8WpqYtGoSpSpDJnJpSiYqRcjJ9PBSbPWMXTkdTyJUiu3aBKIYeqHnvEsqHn1v1yZ4AqmfB0cbi4o3aBKmia6uSbPJMFg2qe5meydheSziKiasAB(sbnWMr6tRESzusPytwLW2gBA9a24NpW0SNInRm2ia7wRqq4o3q5W(0n2GuyZ4wLHwSb9BRq0dvSjvytSn2ia7wRqqacslSzCbuSbPpO0JnJskfBUa2ia7wRqqac2WbbBA9a2OyzONInRm2mUak2G0hu6XglhX2yZfWgc0GTbc2CNInmHSHY9hAQA1J8FIvuz6J8JMNpY)bc(sbYl1FSISbrY)PzkeTRUvi6HQdc(sbc2Ga2ChKLDseGewaehzhfydcytNvaB0eB88pSTZn(ZmeAb5bAraTa4(7hTjEK)de8LcKxQ)yfzdIK)Zmls(sb3io7m0wKxrPUvi6Hk2Ga2mg2y1ZcTGcBqHntGnE9InJHncojfygI2v3zOcr7YaB0eB80dSbbSrWjPaZq0oMquUmWgnXgp9aB8hB8)pSTZn(JmqlIbL(VF087J8FGGVuG8s9hRiBqK8F0bBMzrYxk4gXzNH2I8kk1TcrpuXgeWMXWg225muGaQjOWgnXgcOsbqknl0cTcB86fBeCskWmeTJjeLldSrtSXVEGn()h225g)rgOLlleSw47hnD9r(pqWxkqEP(JvKnis(pZSi5lfCxktGcHdl8h225g)HaCRVOgbGKVF0q3J8FyBNB8NSwxk35gfEqW)bc(sbYl13pAO3J8FGGVuG8s9hRiBqK8FyBNZqbcOMGcB0eB8eBqaBgdB0bBeCskWmeTJjeLdgVu1kSXRxSrWjPaZq0oMquUbjyJ)ydcyJoyZmls(sb3io7m0wKxrPUvi6H6FyBNB8hykuUax)(rBCEK)de8LcKxQ)yfzdIK)Zmls(sb3LYeOq4Wc)HTDUXFUuMafchw47hn)0J8FGGVuG8s9hRiBqK8FKhetDeqoTzJnAIcB0vp(dB7CJ)id0lLjW3pA(XJ8FGGVuG8s9hRiBqK8F0bBAMcr7U0mif5bXuhe8LceSbbSrhSzMfjFPGBeNDgAlYROqyXKffLv6XgeWgbNKcmdr7ycr5YaB0eByBNB4GPq5cC1z3Ls2rXFyBNB8hykuUax)(rZtpEK)de8LcKxQ)yfzdIK)ZyytZuiAhbQBuUuMakhe8LceSXRxSrhSzMfjFPGBeNDgAlYROu3ke9qfB86fBKhetDeqoTzJnib24xpWgVEXM7GSSRcnxxHe9Rkvobu5muydsGnOdB8hBqaB0bBMzrYxk4KSlndTf5vuUuMafchwaBqaB0bBMzrYxk4gXzNH2I8kkewmzrrzL()W2o34pCeP(KYDUX3pAE65J8FGGVuG8s9hRiBqK8FgdBAMcr7iqDJYLYeq5GGVuGGnE9In6GnZSi5lfCJ4SZqBrEfL6wHOhQyJxVyJ8GyQJaYPnBSbjWg)6b24p2Ga2Od2mZIKVuWjzxAgAlYROuHMXgeWgDWMzwK8Lcoj7sZqBrEfLlLjqHWHfWgeWgDWMzwK8LcUrC2zOTiVIcHftwuuwP)pSTZn(JvpVQIQf5KW3pAEoXJ8FGGVuG8s9hRiBqK8FAMcr7U0mif5bXuhe8LceSbbSrWjPaZq0oMquUmWgnXg225goykuUaxD2DPKDu8h225g)bMcLlW1VF080VpY)HTDUXFiqDdv5Mn8hi4lfiVuF)O5PU(i)hi4lfiVu)XkYgej)N6odviAhjvnhwaB0eB8eDyJxVyZDqw2TdDzLlco0cUbj)HTDUXFKb6LYe47hnpr3J8FGGVuG8s9hRiBqK8FAMcr7iqDJYLYeq5GGVuG8h225g)P1l2rfTuoNHV)(pGsbHfupYpAE(i)h225g)XUHfIwWnqkYuUc)bc(sbYl13pAt8i)h225g)5s3Luw5sRhkqa1P)bc(sbYl13pA(9r(pSTZn(J2bwqsokRCHrsGyB9)bc(sbYl13pA66J8FyBNB8h51oOasHrsGiBOCbU(hi4lfiVuF)OHUh5)W2o34psgeP80m0wUuw1)bc(sbYl13pAO3J8FyBNB8NwpugI7oeKI8kSWFGGVuG8s99J248i)h225g)rKsKqHsgfLe2c)bc(sbYl13pA(Ph5)W2o34pJwbLmdzueGAdoSWFGGVuG8s99JMF8i)hi4lfiVu)XkYgej)h5bXuSbjWgD1dSbbS5oil7QqZ1vir)QsLBqYFyBNB8NkuxX0YkxOd2KuicGRQV)(peqMhO9J8JMNpY)HTDUXFiPsmiP)de8LcKxQVF0M4r(pSTZn(JDd1qfkvwBA)de8LcKxQVF087J8FGGVuG8s9NvYFuq)h225g)zMfjFPWFMz6a8NMPq0o5uO6YLUlXbbFPabB86fBusakT0Sql0k3LYeOq4WcEInAIcBgdB8l2GuytZuiAxl4Kww5Iyidhe8LceSX))mZIsWv4pxktGcHdl89JMU(i)hi4lfiVu)zL8hf0)HTDUXFMzrYxk8NzMoa)rhSzmSrhSPzkeTlGkOsLdc(sbc241l2y3Ls2rHlGkOsLtamzk241l2y3Ls2rHlGkOsLtavodf2Oj20zfk9wijGnE9In2DPKDu4cOcQu5eqLZqHnAInONhyJ))zMfLGRWFgXzNH2I8kkbubvQ((rdDpY)bc(sbYl1Fwj)rb9FyBNB8NzwK8Lc)zMPdWF0bBAMcr7iqDJ06GGVuGGniGn2DPKDu4QqZ1vir)QsLtavodf2Geyd6HniGnYdIPociN2SXgnXg)6b2Ga2mg2Od2mZIKVuWnIZodTf5vucOcQuHnE9In2DPKDu4cOcQu5eqLZqHnib24PhyJ))zMfLGRWFKSlndTf5vuQqZF)OHEpY)bc(sbYl1Fwj)rb9FyBNB8NzwK8Lc)zMPdWFMzrYxk4UuMafchwaBqaBgdBKhetXgKaBgh0Hnif20mfI2jNcvxU0Djoi4lfiyJUeBMWdSX))mZIsWv4ps2LMH2I8kkxktGcHdl89J248i)hi4lfiVu)zL8hf0)HTDUXFMzrYxk8NzMoa)PzkeTJa1nsRdc(sbc2Ga2Od20mfI2DPzqkYdIPoi4lfiydcyJDxkzhfoykuUaxDcOYzOWgKaBgdB0AjUkpEyJUeBMaB8hBqaBKhetDeqoTzJnAInt4XFMzrj4k8hj7sZqBrEffykuUax)(rZp9i)hi4lfiVu)zL8hf0)HTDUXFMzrYxk8NzMoa)PzkeTJWIjlkkR07GGVuGGniGn6GnZSi5lfCs2LMH2I8kkxktGcHdlGniGn6GnZSi5lfCs2LMH2I8kkvOzSbbSXUlLSJchHftwuuwP3ni5pZSOeCf(Zio7m0wKxrHWIjlkkR0)9JMF8i)hi4lfiVu)zL8hf0)HTDUXFMzrYxk8NzMoa)PzkeTRUvi6HQdc(sbc2Ga2Od2ChKLD1TcrpuDds(ZmlkbxH)mIZodTf5vuQBfIEO(9JMNE8i)h225g)HKkXGK(pqWxkqEP((rZtpFK)de8LcKxQ)yfzdIK)JwlXjGkNHcBqHnE8h225g)XYuAHTDUrHMQ(p0u1LGRWFS7sj7O47hnpN4r(pqWxkqEP(JvKnis(pYdIPociN2SXgnrHn(fD)HTDUXFKK2jldskYcwBfI(7hnp97J8FGGVuG8s9hRiBqK8FAMcr7iSyYIIYk9oi4lfiydcyZyyZmls(sb3io7m0wKxrHWIjlkkR0JnE9Ine4oil7iSyYIIYk9UbjyJ))HTDUXFSmLwyBNBuOPQ)dnvDj4k8hclMSOOSs)3pAEQRpY)bc(sbYl1FSISbrY)PzkeTJa1nsRdc(sbYFyBNB8hXquyBNBuOPQ)dnvDj4k8hcu3iTF)O5j6EK)de8LcKxQ)W2o34pIHOW2o3Oqtv)hAQ6sWv4pXkQm97V)Jeby36L7h5hnpFK)de8LcKxQVF0M4r(pqWxkqEP((rZVpY)bc(sbYl13pA66J8FGGVuG8s99Jg6EK)dB7CJ)iz7CJ)abFPa5L67hn07r(pqWxkqEP(JvKnis(p6GnmscezdoREE70wAbhk5vu5o3WbbFPa5pSTZn(tfAUUcj6xvQ((7)qyXKffLv6FKF088r(pqWxkqEP(JvKnis(pYdIPyJMOWg)KhydcyZyyJoyZmls(sb3LYeOq4WcyJxVyJoyJDxkzhfUlLjqHWHfCcGjtXg))dB7CJ)qyXKffLv6)(rBIh5)abFPa5L6pwr2Gi5)qG7GSSJWIjlkkR07gK8h225g)HJi1NuUZn((rZVpY)bc(sbYl1FSISbrY)Ha3bzzhHftwuuwP3ni5pSTZn(JvpVQIQf5KW3F)h7UuYokEKF088r(pqWxkqEP(JvKnis(p6GnJHnntHODeOUrADqWxkqWgVEXMzwK8Lcoj7sZqBrEfLk0m241l2mZIKVuWnIZodTf5vucOcQuHn(JnE9InDwHsVfscydsGntGU)W2o34pvO56kKOFvP67hTjEK)de8LcKxQ)yfzdIK)tZuiAhbQBKwhe8LceSbbSzmSrhSHrsGiBWz1ZBN2sl4qjVIk35goi4lfiyJxVyZyyJDxkzhfoykuUaxDcOYzOWgnXMj8aBqaBS7sj7OWDPmbkeoSGtavodf2Oj2O1sCvE8Wg)Xg))dB7CJ)uHMRRqI(vLQVF087J8FGGVuG8s9hRiBqK8FeCskWmeTJjeLdgVu1kSbbSHa3bzzxavqLkhzhfydcyZyydB7Cgkqa1euyJMydbuPaiLMfAHwHnE9IncojfygI2XeIYLb2Oj2GEEGn()h225g)jGkOs13pA66J8FGGVuG8s9hRiBqK8F0bBeCskWmeTJjeLdgVu1Q)W2o34pbubvQ((rdDpY)bc(sbYl1FSISbrY)5oil7QqZ1vir)QsLtavodf2Oj2mb6WgVEXMoRqP3cjbSbjWg0ZJ)W2o34ps2o347hn07r(pqWxkqEP(tWv4pZSi5lfkz0qOYEArBQLNxAxwLnPuUZqBraSTxXFyBNB8NzwK8LcLmAiuzpTOn1YZlTlRYMuk3zOTia22R47hTX5r(pSTZn(ZGckzdv1FGGVuG8s99JMF6r(pqWxkqEP(dB7CJ)yzkTW2o3Oqtv)hAQ6sWv4pGsbHfuF)9FiqDJ0(i)O55J8FGGVuG8s9hRiBqK8FMzrYxk4UuMafchw4pSTZn(db4wFrncajF)OnXJ8FGGVuG8s9hRiBqK8FeCskWmeTJjeLBqc241l2i4KuGziAhtikxgyJMyZeO7pSTZn(dmfkxGRF)O53h5)abFPa5L6pwr2Gi5)mg2mg2Od2y3Ls2rHdMcLlWv3GeSXRxS5oil7QqZ1vir)QsLBqc24p2Ga2i4KuGziAhtikxgyJMyJF9aB8hB86fByBNZqbcOMGcB0eBiGkfaP0Sql0Q)W2o34pYaTCzHG1cF)OPRpY)bc(sbYl1FSISbrY)zMfjFPG7szcuiCybSbbSrhSXUlLSJcxfAUUcj6xvQCcGjtXgeWMXWg7UuYokCWuOCbU6eqLZqHnAInJHnOdBqkSHrsGiBWjG5LoNH2YLYeq5eCmj2OlXg)In(JnE9InJHncojfygI2XeIYLb2Oj2W2o3WDPmbkeoSGZUlLSJcSbbSrWjPaZq0oMquUmWgKaBMaDyJ)yJ))HTDUXFUuMafchw47hn09i)h225g)jR1LYDUrHhe8FGGVuG8s99Jg69i)hi4lfiVu)XkYgej)hDWMzwK8Lcoj7sZqBrEfLlLjqHWHf(dB7CJ)WrK6tk35gF)OnopY)bc(sbYl1FSISbrY)rEqm1ra50Mn2OjkSrx94pSTZn(JmqVuMaF)O5NEK)de8LcKxQ)yfzdIK)JoyZmls(sbNKDPzOTiVIYLYeOq4WcydcyJoyZmls(sbNKDPzOTiVIcmfkxGR)HTDUXFS65vvuTiNe((rZpEK)dB7CJ)qG6gQYnB4pqWxkqEP((rZtpEK)de8LcKxQ)yfzdIK)ZDqw2TdDzLlco0cUbj)HTDUXFA9IDurlLZz47hnp98r(pqWxkqEP(JvKnis(pntHODeOUr5szcOCqWxkq(dB7CJ)06f7OIwkNZW3F)9FMbHk34rBcp80p8yIjqp3e(vxhN)mIfrgAv)z8b9hPJMUaA(zizSbBqwpGnzvYkASrEfyd6lbK5bAJ(IncWpFifabBuBfWgEO3k3abBS65qlOCyFJVZaWgpNajJnJ7qnirYkAGGnSTZnWg0xjPDYYGKISG1wHOrFDyFyF6cvjRObc2moydB7CdSHMQw5W((JeXkNu4p6gBqA451In6IqDdSbPziAqG9PBSrF3suizeruB26hUo7wruL1bk35gwbl3iQYQfrSpDJn(gcaBMaDAGnt4HN(b2GuyJh(bsEc0H9H9PBSz8HfrgAvizSpDJnif2mUvzOfB0fH6gyJuuMakSPYtckSPUQgBgxdIPyJwiab35gyJKbbqNIniD08ZWgIiNHaB4GGndHebqsBZxkOb2msFA1JnJskfBYQe22ytRhWg)8bMM9uSzLXgby3Afcc35gkh2NUXgKcBg3Qm0InOFBfIEOInPcBITXgby3AfccqqAHnJlGIni9bLESzusPyZfWgby3AfccqWgoiytRhWgfld9uSzLXMXfqXgK(Gsp2y5i2gBUa2qGgSnqWM7uSHjKnuoSpSpDJnJF9COfuizSpDJnif2G(tiabBg)BOgQa2G(XAtRd7t3ydsHniDOUZabBAwOf6skJnw9GDsSrEfydAqfuPcB4BsZEQd7t3ydsHniDOUZabBQ7muHOXg(M0StqHnYITInse5kYEk2mspeytSn2mOac2iVcSb9BRq0dvh2NUXgKcBq)jeGGnJBfGn6cnuvytVydeeSzLXMX)UuYokuydB7CdAQAh2NUXgKcBg)BmdIgiyd6JDxkzhfOpytVyd6dB7Cd34lNDxkzhfOpyZi9GaWgwIeAA5lfCyFyF6gBqApEGDObc2Cb5vayJDRxUXMlOndLdBq)TwqsRWMydKsplQYduSHTDUHcB2Go1H9X2o3q5Kia7wVCJsMYQjX(yBNBOCseGDRxULgfI8G2ken35gyFSTZnuojcWU1l3sJcr5DjyF6gBoblrPFBSrWjbBUdYYabBun3kS5cYRaWg7wVCJnxqBgkSHdc2iraiLKT7m0InPcBiBaoSp225gkNeby36LBPrHOkyjk9Bxun3kSp225gkNeby36LBPrHOKTZnW(yBNBOCseGDRxULgfIvO56kKOFvPsJugLomscezdoREE70wAbhk5vu5o3WbbFPab7d7t3yds7XdSdnqWgygetXMoRa206bSHT9kWMuHn8mNu(sbh2hB7CdfksQedsASp225gkPrHODd1qfkvwBAX(yBNBOKgfIZSi5lf0i4kG6szcuiCybnMz6aGQzkeTtofQUCP7sCqWxkq86vjbO0sZcTqRCxktGcHdl4PMOgZVivZuiAxl4Kww5Iyidhe8Lce)X(yBNBOKgfIZSi5lf0i4kGAeNDgAlYROeqfuPsJzMoaO0zmDAMcr7cOcQu5GGVuG41RDxkzhfUaQGkvobWKPE9A3Ls2rHlGkOsLtavodLMDwHsVfscE9A3Ls2rHlGkOsLtavodLMONh(J9X2o3qjnkeNzrYxkOrWvaLKDPzOTiVIsfAwJzMoaO0PzkeTJa1nsRdc(sbcc2DPKDu4QqZ1vir)QsLtavodfsGEiipiM6iGCAZwt)6bcJPZmls(sb3io7m0wKxrjGkOsLxV2DPKDu4cOcQu5eqLZqHeE6H)yFSTZnusJcXzwK8LcAeCfqjzxAgAlYROCPmbkeoSGgZmDaqnZIKVuWDPmbkeoSacJjpiMIeJd6qQMPq0o5uO6YLUlXbbFParxoHh(J9X2o3qjnkeNzrYxkOrWvaLKDPzOTiVIcmfkxGRAmZ0bavZuiAhbQBKwhe8Lcee0PzkeT7sZGuKhetDqWxkqqWUlLSJchmfkxGRobu5muiXyATexLhpD5e(JG8GyQJaYPnBnNWdSp225gkPrH4mls(sbncUcOgXzNH2I8kkewmzrrzLEnMz6aGQzkeTJWIjlkkR07GGVuGGGoZSi5lfCs2LMH2I8kkxktGcHdlGGoZSi5lfCs2LMH2I8kkvOzeS7sj7OWryXKffLv6DdsW(yBNBOKgfIZSi5lf0i4kGAeNDgAlYROu3ke9qvJzMoaOAMcr7QBfIEO6GGVuGGGo3bzzxDRq0dv3GeSp225gkPrHijvIbjn2hB7CdL0Oq0YuAHTDUrHMQwJGRak7UuYok0iLrP1sCcOYzOq5b2hB7CdL0OqusANSmiPilyTviAnszuYdIPociN2S1eLFrh2hB7CdL0Oq0YuAHTDUrHMQwJGRakclMSOOSsVgPmQMPq0oclMSOOSsVdc(sbccJnZIKVuWnIZodTf5vuiSyYIIYk9E9sG7GSSJWIjlkkR07gK4p2hB7CdL0Oqumef225gfAQAncUcOiqDJ0QrkJQzkeTJa1nsRdc(sbc2hB7CdL0Oqumef225gfAQAncUcOIvuzk2h2hB7CdLdukiSGsAuiA3Wcrl4gifzkxbSp225gkhOuqybL0Oq8s3Luw5sRhkqa1PyFSTZnuoqPGWckPrHO2bwqsokRCHrsGyB9yFSTZnuoqPGWckPrHO8AhuaPWijqKnuUaxX(yBNBOCGsbHfusJcrjdIuEAgAlxkRASp225gkhOuqybL0OqS1dLH4UdbPiVclG9X2o3q5aLcclOKgfIIuIekuYOOKWwa7JTDUHYbkfewqjnkehTckzgYOia1gCybSp225gkhOuqybL0OqSc1vmTSYf6GnjfIa4QsJugL8GyksOREGWDqw2vHMRRqI(vLk3GeSpSp225gkNDxkzhfOQqZ1vir)QsLgPmkDgRzkeTJa1nsRdc(sbIxVZSi5lfCs2LMH2I8kkvOzVENzrYxk4gXzNH2I8kkbubvQ83R3oRqP3cjbKyc0H9X2o3q5S7sj7OqAuiwHMRRqI(vLknszuntHODeOUrADqWxkqqymDyKeiYgCw982PT0couYROYDUHdc(sbIxVJz3Ls2rHdMcLlWvNaQCgknNWdeS7sj7OWDPmbkeoSGtavodLMATexLhp)9h7JTDUHYz3Ls2rH0OqmGkOsLgPmkbNKcmdr7ycr5GXlvTcbcChKLDbubvQCKDuGWySTZzOabutqPjbuPaiLMfAHw51RGtsbMHODmHOCzOj65H)yFSTZnuo7UuYokKgfIbubvQ0iLrPJGtsbMHODmHOCW4LQwH9X2o3q5S7sj7OqAuikz7Cdnszu3bzzxfAUUcj6xvQCcOYzO0Cc051BNvO0BHKasGEEG9X2o3q5S7sj7OqAuioOGs2qvJGRaQzwK8LcLmAiuzpTOn1YZlTlRYMuk3zOTia22Ra7JTDUHYz3Ls2rH0OqCqbLSHQc7JTDUHYz3Ls2rH0Oq0YuAHTDUrHMQwJGRakqPGWckSpSp225gkhHftwuuwPhfHftwuuwPxJugL8GyQMO8tEGWy6mZIKVuWDPmbkeoSGxV6y3Ls2rH7szcuiCybNayYu)X(yBNBOCewmzrrzLEPrHihrQpPCNBOrkJIa3bzzhHftwuuwP3nib7JTDUHYryXKffLv6LgfIw98QkQwKtcAKYOiWDqw2ryXKffLv6DdsW(W(yBNBOCeOUrArraU1xuJaqIgPmQzwK8LcUlLjqHWHfW(yBNBOCeOUrALgfIWuOCbUQrkJsWjPaZq0oMquUbjE9k4KuGziAhtikxgAob6W(yBNBOCeOUrALgfIYaTCzHG1cAKYOgBmDS7sj7OWbtHYf4QBqIxV3bzzxfAUUcj6xvQCds8hbbNKcmdr7ycr5Yqt)6H)E9Y2oNHceqnbLMeqLcGuAwOfAf2hB7CdLJa1nsR0Oq8szcuiCybnszuZSi5lfCxktGcHdlGGo2DPKDu4QqZ1vir)QsLtamzkcJz3Ls2rHdMcLlWvNaQCgknhdDifJKar2GtaZlDodTLlLjGYj4ysDPF93R3XeCskWmeTJjeLldnzBNB4UuMafchwWz3Ls2rbccojfygI2XeIYLbsmb683FSp225gkhbQBKwPrHywRlL7CJcpiySp225gkhbQBKwPrHihrQpPCNBOrkJsNzwK8Lcoj7sZqBrEfLlLjqHWHfW(yBNBOCeOUrALgfIYa9szcOrkJsEqm1ra50MTMO0vpW(yBNBOCeOUrALgfIw98QkQwKtcAKYO0zMfjFPGtYU0m0wKxr5szcuiCybe0zMfjFPGtYU0m0wKxrbMcLlWvSpDJnSTZnuocu3iTsJcrzGwedk9AKYOAMcr7iqDJYLYeq5GGVuGGGo2DPKDu4GPq5cC1jaMmfHXS6zHwqHAcVEhtWjPaZq0U6odviAxgA6Phii4KuGziAhtikxgA6Ph(7p2hB7CdLJa1nsR0OqKa1nuLB2a2hB7CdLJa1nsR0OqS1l2rfTuoNbnszu3bzz3o0LvUi4ql4gKG9PBSHTDUHYrG6gPvAuikd0IyqPxJugvDNHkeTJKQMdlOPNOZR37GSSBh6YkxeCOfCdsW(0n2W2o3q5iqDJ0knkeNHqlipqlcOfa3AKYOQ7muHODKu1Cybn9eDyFSTZnuocu3iTsJcXwVyhv0s5Cg0iLr1mfI2rG6gLlLjGYbbFPab7d7JTDUHYfROYuuZqOfKhOfb0cGBnszuntHOD1TcrpuDqWxkqq4oil7KiajSaioYokqOZkOPNyFSTZnuUyfvMknkeLbArmO0RrkJAMfjFPGBeNDgAlYROu3ke9qfHXS6zHwqHAcVEhtWjPaZq0U6odviAxgA6Phii4KuGziAhtikxgA6Ph(7p2NUXg225gkxSIktLgfIYaTigu61iLr1mfI2jd0sLvniM6GGVuGGWyw9SqlOqnHxVJj4KuGziAxDNHkeTldn90deeCskWmeTJjeLldn90d)9h7JTDUHYfROYuPrHOmqlxwiyTGgPmkDMzrYxk4gXzNH2I8kk1Tcrpurym225muGaQjO0KaQuaKsZcTqR86vWjPaZq0oMquUm00VE4p2hB7CdLlwrLPsJcrcWT(IAeas0iLrnZIKVuWDPmbkeoSa2hB7CdLlwrLPsJcXSwxk35gfEqWyFSTZnuUyfvMknkeHPq5cCvJugfB7Cgkqa1euA6jcJPJGtsbMHODmHOCW4LQw51RGtsbMHODmHOCds8hbDMzrYxk4gXzNH2I8kk1TcrpuX(yBNBOCXkQmvAuiEPmbkeoSGgPmQzwK8LcUlLjqHWHfW(yBNBOCXkQmvAuikd0lLjGgPmk5bXuhbKtB2AIsx9a7JTDUHYfROYuPrHimfkxGRAKYO0PzkeT7sZGuKhetDqWxkqqqNzwK8LcUrC2zOTiVIcHftwuuwPhbbNKcmdr7ycr5Yqt225goykuUaxD2DPKDuG9X2o3q5IvuzQ0OqKJi1NuUZn0iLrnwZuiAhbQBuUuMakhe8LceVE1zMfjFPGBeNDgAlYROu3ke9q1Rx5bXuhbKtB2iHF9WR37GSSRcnxxHe9Rkvobu5muib68hbDMzrYxk4KSlndTf5vuUuMafchwabDMzrYxk4gXzNH2I8kkewmzrrzLESp225gkxSIktLgfIw98QkQwKtcAKYOgRzkeTJa1nkxktaLdc(sbIxV6mZIKVuWnIZodTf5vuQBfIEO61R8GyQJaYPnBKWVE4pc6mZIKVuWjzxAgAlYROuHMrqNzwK8Lcoj7sZqBrEfLlLjqHWHfqqNzwK8LcUrC2zOTiVIcHftwuuwPh7JTDUHYfROYuPrHimfkxGRAKYOAMcr7U0mif5bXuhe8LceeeCskWmeTJjeLldnzBNB4GPq5cC1z3Ls2rb2hB7CdLlwrLPsJcrcu3qvUzdyF6gByBNBOCXkQmvAuikd0IyqPxJugLontHOD1TcrpuDqWxkqqqWjPaZq0U6odviAxgAA1ZcTGsx6Phi0mfI2rG6gLlLjGYbbFPab7JTDUHYfROYuPrHOmqVuMaAKYOQ7muHODKu1Cybn9eDE9EhKLD7qxw5IGdTGBqc2NUXg225gkxSIktLgfIYaTigu61iLrv3zOcr7iPQ5WcA6j686DS7GSSBh6YkxeCOfCdsqqNMPq0U6wHOhQoi4lfi(J9PBSHTDUHYfROYuPrH4meAb5bAraTa4wJugvDNHkeTJKQMdlOPNOd7JTDUHYfROYuPrHyRxSJkAPCodAKYOAMcr7iqDJYLYeq5GGVuG8hEO1VI)CY6aL7CJXVGL7V)(Fa]] )


end
