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
                    local appliedBuffer = ( now - t.applied ) % 1
                    return min( 40, t.count + floor( offset + delay + appliedBuffer ) )
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
        if this_action == "nemesis" and Hekili:GetNumTTDsWithin( target.time_to_die ) > 1 then return "cycle" end
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

            start = function ()
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

        potion = "potion_of_unbridled_fury",

        package = "Havoc",
    } )


    spec:RegisterSetting( "recommend_movement", false, {
        name = "Recommend Movement",
        desc = "If checked, the addon will recommend |T1247261:0|t Fel Rush / |T1348401:0|t Vengeful Retreat when it is a potential DPS gain.\n\n" ..
            "These abilities are critical for DPS when using the Momentum talent.\n\n" ..
            "If not using Momentum, you may want to leave this disabled to avoid unnecessary movement in combat.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Havoc", 20200123, [[dOeaibqisklsLaEKseBcszukjoLsuRsjs1ROk1SirUfsjTlk9lsWWGuDmsOLPK0ZOkPPPsqxJQqBJQaFdPenoKsvNtjszDQeO3PejY8OkX9qs7dP4GiLqlKQOhsvqnrKsfxujsOnQsO8rLibJePuPtQej1kvsDtvcv7KKQLsvqEQkMkjQRIuc(QsKOgRsKe7fQ)kyWK6WelwPEmvMmkxgSzi(mjz0ivNwYRvjA2O62cTBr)wXWHKJRejPLJ45umDPUov12vP(Usy8QeY5vjTEKsz(iX(v1yfXkJpmPbS6RI(QOJUIR6vl6lnp6r0veF6ROa8bL4Uuub4tkraFODL7XHpOKR8ryyLXhZ4tCa(qVBuMlOckOQA6(BRBIkyQOpx6AshrqAfmv0Pa(S9lEVuN4n(WKgWQVk6RIo6kUQxTOV084f6XvXhdkWHv3J0sAj(qVymiXB8Hbgh(SKxt7k3J710oqCYxt76Nnq(1l5107gL5cQGcQQMU)26MOcMk6ZLUM0reKwbtfDk8RxYRxlPVqU(6vvuPxVk6RI(V(xVKxVuwizLQmxWF9sEnT(AAbtLQEnTdeN81EYfgyEDuUemVooM(1xmFY1xRcsGiDn5Rr5ta(1x7HuFPWRzK6gYxlj71(jkcWkxlBoO0RxqVC0F9IIZFDfrjU(1nD41lv9fE1xF9G8Ac4MyesM01Kg7VEjVMwFnTGPsvV(IpriB)4RlZRZPFnbCtmcjdylLE9fd4V2d5BO)6ffN)6n8Ac4MyesgWETKSx30HxBeeOV(6b51xmG)ApKVH(RDsMt)6n8Ag0GRb2R3xFTWytAS)6F9sEThMUKQaZf8xVKxtRVMwKXa2R9WtA8JWRV4IQYz)1l5106R9qqCUb2RBHOc6qH8AhDWD5RrgYRvhIGPmVw2fV6R2F9sEnT(ApeeNBG964Cdri7xl7IxDbMxJqM4RrrQHu91xVGoKVoN(1(gG9AKH86l(eHS9J2F9sEnT(AArgdyVMwWaVEPUHO5198AizVEqEThEgoBwKMxlUUMKxM2(RxYRP1x7HN8ginWE9fWndNnlYlWR751xaX11K2Lkw3mC2SiVaVEbDGaVwqHIxozZbl(WltBWkJp5qIchRmwDfXkJpqkBoWWEIpos1aPe8PfoKTnoriB)OfszZb2Rr71BFeelkcGsiaZYMf5Rr71DfHxtZRveFexxtIp3qQcq85bc0eqACJvFvSY4dKYMdmSN4JJunqkbFw513cPKnhSlKQRuvaziH4eHS9JVMcLx3chY2Ia8qumnqUAHu2CG96LFnAVELx7OlevG51uF9QVMcLxVYRjsXcWnKTno3qeY2w5RP51kI(Rr71ePyb4gY2kmMXw5RP51kI(Rx(1lJpIRRjXheGhi(g64gRUxXkJpqkBoWWEIpos1aPe8rTxFlKs2CWUqQUsvbKHeIteY2p(A0E9kVwCDDdbiHybMxtZRzGPial0crf0MxtHYRjsXcWnKTvymJTYxtZR9k6VEz8rCDnj(Ga8WwierfGBS6xiwz8bszZbg2t8XrQgiLGp3cPKnhSBUWGatshGpIRRjXhgin9GzbaOWnwDpIvgFexxtIpvmoCPRjdIprWhiLnhyypXnwDpaRm(aPS5ad7j(4ivdKsWhX11neGeIfyEnnVwXxJ2Rx51Q9AIuSaCdzBfgZyHlQmT51uO8AIuSaCdzBfgZy9r96LFnAVwTxFlKs2CWUqQUsvbKHeIteY2pIpIRRjXh4ke2GeXnwDAjwz8bszZbg2t8XrQgiLGp3cPKnhSBUWGatshGpIRRjXNnxyqGjPdWnwDApwz8bszZbg2t8XrQgiLGpi(KRwgGuUQFnnuF9fIo(iUUMeFqa(Mlma3y1xAyLXhiLnhyypXhhPAGuc(O2RBHdzB38kzbeFYvlKYMdSxJ2Rv713cPKnhSlKQRuvazibMqUmy4IH(Rr71ePyb4gY2kmMXw5RP51IRRjTWviSbjADZWzZIeFexxtIpWviSbjIBS6kIowz8bszZbg2t8XrQgiLGpR86w4q2wgeNmS5cdmwiLnhyVMcLxR2RVfsjBoyxivxPQaYqcXjcz7hFnfkVgXNC1YaKYv9R9YR9k6VMcLxV9rqSrOL4qqrFmLXsGOuP51E51E81l)A0ETAV(wiLS5Gf1m8kvfqgsyZfgeys6GxJ2Rv713cPKnhSlKQRuvazibMqUmy4IHo(iUUMeFKml6fx6AsCJvxrfXkJpqkBoWWEIpos1aPe8zLx3chY2YG4KHnxyGXcPS5a71uO8A1E9TqkzZb7cP6kvfqgsioriB)4RPq51i(KRwgGuUQFTxETxr)1l)A0ETAV(wiLS5Gf1m8kvfqgsicT8A0ETAV(wiLS5Gf1m8kvfqgsyZfgeys6GxJ2Rv713cPKnhSlKQRuvazibMqUmy4IHo(iUUMeFC0LXemnPUeWnwDfxfRm(aPS5ad7j(4ivdKsWNw4q22nVswaXNC1cPS5a71O9AIuSaCdzBfgZyR8108AX11Kw4ke2GeTUz4SzrIpIRRjXh4ke2GeXnwDf9kwz8rCDnj(WG4KMWUAaFGu2CGH9e3y1v8cXkJpqkBoWWEIpos1aPe8rTx3chY2gNiKTF0cPS5a71O9AIuSaCdzBJZneHSTv(AAETJUqubMxV0FTIO)A0EDlCiBldItg2CHbglKYMdm8rCDnj(Ga8aX3qh3y1v0JyLXhiLnhyypXhhPAGuc(eNBiczBzLPL0bVMMxROhFnfkVE7JGyh)omibIKQaRpk8rCDnj(Ga8nxyaUXQROhGvgFGu2CGH9eFCKQbsj4tCUHiKTLvMwsh8AAETIE81uO86vE92hbXo(DyqcejvbwFuVgTxR2RBHdzBJteY2pAHu2CG96LXhX11K4dcWdeFdDCJvxrAjwz8bszZbg2t8XrQgiLGpX5gIq2wwzAjDWRP51k6r8rCDnj(CdPkaXNhiqtaPXnwDfP9yLXhiLnhyypXhhPAGuc(0chY2YG4KHnxyGXcPS5adFexxtIpnDYSiOIl1nGBCJpGXaPdmyLXQRiwz8bszZbg2t8XrQgiLGpR8A1EnBARBshKnrAGfq4secBFsA7YDzLQEnAVwTxlUUM06M0bztKgybeUebBLbeEPIE)AkuEnIpNhiGJUqubHUIWR9YRv5y2OCrVEz8rCDnj(4M0bztKgybeUebCJvFvSY4dKYMdmSN4JJunqkbF2(ii2i0sCiOOpMYy9r9AkuEDxri0tGvWR9c1xRi64J46As8zZNHfgKqthcqcXR4gRUxXkJpqkBoWWEIpos1aPe8zLxV9rqSrOL4qqrFmLX6J61O9A3mC2SiTrOL4qqrFmLXsaHD91l)AkuE92hbXgHwIdbf9XuglbIsLMxtZRx1JVMcLx3crf02UIqONaRGx7fQV2ROJpIRRjXhv(cHvsggKGqBazA64gR(fIvgFGu2CGH9eFCKQbsj4JbfW5HwiQG2y3CHbbMKoqXxtd1xV6RPq51ePyb4gY2kmMXw5RP51Ea64J46As8bzC(gGfeAdivdHnirCJv3JyLXhiLnhyypXhhPAGuc(yqbCEOfIkOn2nxyqGjPdu810q91R(AkuEnrkwaUHSTcJzSv(AAEThGo(iUUMeFq5tkKRvQkS5IPXnwDpaRm(aPS5ad7j(4ivdKsWNTpcILaUl5GXeqgIdS(OEnfkVE7JGyjG7soymbKH4GGB8ZgiwtlUlFTxETIOJpIRRjXNMoe8Z94NSaYqCaUXQtlXkJpIRRjXhsHcfhcvgmOehGpqkBoWWEIBS60ESY4dKYMdmSN4JJunqkbF2(ii2i0sCiOOpMYy9rHpIRRjXNfdHZUHkdeWmPKoa3y1xAyLXhiLnhyypXhhPAGuc(G4tU(AV86le9xJ2R3(ii2i0sCiOOpMYy9rHpIRRjXNiehY1WGe4(UIfyeqIgCJvxr0XkJpqkBoWWEIpos1aPe8PfIkOT0bH30TOC9RP510E0FnfkVUfIkOT0bH30TOC9R9c1xVk6VMcLx3crf02UIqONakxhwf9xtZR9k64J46As8HacQkvfq4sem4g34ddqeFEJvgRUIyLXhiLnhyypXNbf(yGgFexxtIp3cPKnhWNBH7d4tlCiBlsrmDyZNHzHu2CG9AkuETbfW5HwiQG2y3CHbbMKoqXxtd1xVYR96RP1x3chY22eP4Hbjq8R0cPS5a71lJp3cjKseWNnxyqGjPdWnw9vXkJpqkBoWWEIpdk8Xan(iUUMeFUfsjBoGp3c3hWh1E9kVwTx3chY2MqemLXcPS5a71uO8A3mC2SiTjebtzSeqyxFnfkV2ndNnlsBcrWuglbIsLMxtZRBHOcABxri0tGvWRPq51Uz4SzrAticMYyjquQ08AAEThG(RxgFUfsiLiGplKQRuvaziHeIGPm4gRUxXkJpqkBoWWEIpdk8Xan(iUUMeFUfsjBoGp3c3hWh1EDlCiBldItwolKYMdSxJ2RDZWzZI0gHwIdbf9XuglbIsLMx7Lx7bVgTxJ4tUAzas5Q(108AVI(Rr71R8A1E9TqkzZb7cP6kvfqgsiHiykZRPq51Uz4SzrAticMYyjquQ08AV8Afr)1lJp3cjKseWhuZWRuvaziHi0cUXQFHyLXhiLnhyypXNbf(yGgFexxtIp3cPKnhWNBH7d4ZTqkzZb7MlmiWK0bVgTxVYRr8jxFTxEnT0JVMwFDlCiBlsrmDyZNHzHu2CG96L(Rxf9xVm(ClKqkraFqndVsvbKHe2CHbbMKoa3y19iwz8bszZbg2t8zqHpgOXhX11K4ZTqkzZb85w4(a(0chY2YG4KLZcPS5a71O9A1EDlCiB7MxjlG4tUAHu2CG9A0ETBgoBwKw4ke2GeTeikvAETxE9kVwLJzJYf96L(Rx91l)A0EnIp5QLbiLR6xtZRxfD85wiHuIa(GAgELQcidjaxHWgKiUXQ7byLXhiLnhyypXNbf(yGgFexxtIp3cPKnhWNBH7d4tlCiBltixgmCXq3cPS5a71O9A1E9TqkzZblQz4vQkGmKWMlmiWK0bVgTxR2RVfsjBoyrndVsvbKHeIqlVgTx7MHZMfPLjKldgUyOB9rHp3cjKseWNfs1vQkGmKatixgmCXqh3y1PLyLXhiLnhyypXNbf(yGgFexxtIp3cPKnhWNBH7d4tlCiBBCIq2(rlKYMdSxJ2Rv71BFeeBCIq2(rRpk85wiHuIa(SqQUsvbKHeIteY2pIBS60ESY4J46As8HvgIpQgFGu2CGH9e3y1xAyLXhX11K4JBsJFecrrv5WhiLnhyypXnwDfrhRm(aPS5ad7j(4ivdKsWhvoMLarPsZRP(A0XhX11K4Jt48G46AYaVmn(Wlthsjc4JBgoBwK4gRUIkIvgFGu2CGH9eFCKQbsj4tlCiBltixgmCXq3cPS5a71O96vE9TqkzZb7cP6kvfqgsGjKldgUyO)AkuEnd2(iiwMqUmy4IHU1h1RxgFexxtIpoHZdIRRjd8Y04dVmDiLiGpmHCzWWfdDCJvxXvXkJpqkBoWWEIpos1aPe8PfoKTLbXjlNfszZbg(iUUMeFi(zqCDnzGxMgF4LPdPeb8HbXjlhUXQROxXkJpqkBoWWEIpIRRjXhIFgexxtg4LPXhEz6qkraFYHefoUXn(GIaUjULgRmwDfXkJpqkBoWWEIpPeb8rOndDHiMaYKDyqcOMfabFexxtIpcTzOleXeqMSddsa1Sai4gR(QyLXhX11K4dQPRjXhiLnhyypXnwDVIvgFGu2CGH9eFCKQbsj4JAVwOnGunyD0LPlxOjsAqgsu6AslKYMdm8rCDnj(eHwIdbf9XugCJB8HjKldgUyOJvgRUIyLXhiLnhyypXhhPAGuc(G4tU(AAO(AAp6VgTxVYRv713cPKnhSBUWGatsh8AkuETAV2ndNnls7MlmiWK0bwciSRVEz8rCDnj(WeYLbdxm0Xnw9vXkJpqkBoWWEIpos1aPe8HbBFeeltixgmCXq36JcFexxtIpsMf9IlDnjUXQ7vSY4dKYMdmSN4JJunqkbFyW2hbXYeYLbdxm0T(OWhX11K4JJUmMGPj1LaUXn(4MHZMfjwzS6kIvgFGu2CGH9eFCKQbsj4JAVELx3chY2YG4KLZcPS5a71uO86BHuYMdwuZWRuvaziHi0YRPq513cPKnhSlKQRuvaziHeIGPmVE5xtHYR7kcHEcScETxE9QEeFexxtIprOL4qqrFmLb3y1xfRm(aPS5ad7j(4ivdKsWNw4q2wgeNSCwiLnhyVgTxVYRv71cTbKQbRJUmD5cnrsdYqIsxtAHu2CG9AkuE9kV2ndNnlslCfcBqIwceLknVMMxVk6VgTxVYRv713cPKnhSBUWGatsh8AkuETBgoBwK2nxyqGjPdSeikvAEnnVwLJzJYf96LF9YVEz8rCDnj(eHwIdbf9XugCJv3RyLXhiLnhyypXhhPAGuc(qKIfGBiBRWyglCrLPnVgTxZGTpcInHiykJLnlYxJ2Rx51IRRBiajelW8AAEndmfbyHwiQG28AkuEnrkwaUHSTcJzSv(AAEThG(RxgFexxtIpjebtzWnw9leRm(aPS5ad7j(4ivdKsWh1EnrkwaUHSTcJzSWfvM2GpIRRjXNeIGPm4gRUhXkJpqkBoWWEIpos1aPe8z7JGyJqlXHGI(ykJLarPsZRP51R6XxtHYR7kcHEcScETxEThGo(iUUMeFqnDnjUXQ7byLXhiLnhyypXhX11K4JkHdoHZbIjSNjXhhPAGuc(O2RBHdzBraEyleIOcSqkBoWEnfkV2ndNnlslcWdBHqevGLac7k(KseWhvchCcNdetyptIBS60sSY4dKYMdmSN4J46As8XD1XNMmz5cBUyA8XrQgiLGpBFeeBeAjoeu0htzS(OEnAVE7JGyJqCixddsG77kwGrajASSzr(A0E9kVwTxFlKs2CWU5cdcmjDWRPq51Q9A3mC2SiTBUWGatshyjGWU(6LXhabbCDiLiGpURo(0KjlxyZftJBS60ESY4dKYMdmSN4J46As8rm0VLembIqBdj4gIWXhhPAGuc(WGTpcILi02qcUHi8ad2(iiw2SiFnfkVELxZGTpcI1njZ311neQ8Yad2(iiwFuVMcLxV9rqSrOL4qqrFmLXsGOuP51086vr)1l)A0EDlevqBPdcVPBr56x7Lx7vfFnfkVURie6jWk41E51RIo(KseWhXq)wsWeicTnKGBich3y1xAyLXhiLnhyypXhX11K4JqBg6crmbKj7WGeqnlac(4ivdKsWh3mC2SiTrOL4qqrFmLXsGOuP51E51kI(RPq51Uz4SzrAJqlXHGI(ykJLarPsZRP51Ea64tkraFeAZqxiIjGmzhgKaQzbqWnwDfrhRm(aPS5ad7j(4ivdKsWNTpcIncTehck6JPmwFu4J46As8X3aHQHOb3y1vurSY4dKYMdmSN4J46As8XjCEqCDnzGxMgF4LPdPeb8bmgiDGb34gFyqCYYHvgRUIyLXhiLnhyypXhhPAGuc(ClKs2CWU5cdcmjDa(iUUMeFyG00dMfaGc3y1xfRm(aPS5ad7j(4ivdKsWhIuSaCdzBfgZy9r9AkuEnrkwaUHSTcJzSv(AAE9QEeFexxtIpWviSbjIBS6EfRm(aPS5ad7j(4ivdKsWNvE9kVwTx7MHZMfPfUcHnirRpQxtHYR3(ii2i0sCiOOpMYy9r96LFnAVMifla3q2wHXm2kFnnV2RO)6LFnfkVwCDDdbiHybMxtZRzGPial0crf0g8rCDnj(Ga8WwierfGBS6xiwz8bszZbg2t8XrQgiLGp3cPKnhSBUWGatsh8A0ETAV2ndNnlsBeAjoeu0htzSeqyxFnAVELx7MHZMfPfUcHnirlbIsLMxtZRx51E8106RfAdivdwcCp87kvf2CHbglrYlF9s)1E91l)AkuE9kVMifla3q2wHXm2kFnnVwCDnPDZfgeys6aRBgoBwKVgTxtKIfGBiBRWygBLV2lVEvp(6LF9Y4J46As8zZfgeys6aCJv3JyLXhX11K4tfJdx6AYG4te8bszZbg2tCJv3dWkJpqkBoWWEIpos1aPe8rTxFlKs2CWIAgELQcidjS5cdcmjDa(iUUMeFKml6fx6AsCJvNwIvgFGu2CGH9eFCKQbsj4dIp5QLbiLR6xtd1xFHOJpIRRjXheGV5cdWnwDApwz8bszZbg2t8XrQgiLGpQ96BHuYMdwuZWRuvaziHnxyqGjPdEnAVwTxFlKs2CWIAgELQcidjaxHWgKi(iUUMeFC0LXemnPUeWnw9Lgwz8bszZbg2t8XrQgiLGpTWHSTmiozyZfgySqkBoWEnAVwTx7MHZMfPfUcHnirlbe21xJ2Rx51o6crfyEn1xV6RPq51R8AIuSaCdzBJZneHSTv(AAETIO)A0EnrkwaUHSTcJzSv(AAETIO)6LF9Y4J46As8bb4bIVHoUXQRi6yLXhX11K4ddItAc7Qb8bszZbg2tCJvxrfXkJpqkBoWWEIpos1aPe8z7JGyh)omibIKQaRpk8rCDnj(00jZIGkUu3aUXQR4QyLXhiLnhyypXhhPAGuc(eNBiczBzLPL0bVMMxROhFnfkVE7JGyh)omibIKQaRpk8rCDnj(Ga8aX3qh3y1v0RyLXhiLnhyypXhhPAGuc(eNBiczBzLPL0bVMMxROhXhX11K4ZnKQaeFEGanbKg3y1v8cXkJpqkBoWWEIpos1aPe8PfoKTLbXjdBUWaJfszZbg(iUUMeFA6KzrqfxQBa34g34Znqm1Ky1xfDfxAkQOIkIpleswPkd(SuhrnKgyVMw(AX11KVMxM2y)14dkYGuCaFwYRPDL7X9AAhio5RPD9Zgi)6L8A6DJYCbvqbvvt3FBDtubtf95sxt6icsRGPIof(1l51RL0xixF9QkQ0Rxf9vr)x)RxYRxklKSsvMl4VEjVMwFnTGPsvVM2bIt(Ap5cdmVokxcMxhht)6lMp56RvbjqKUM81O8ja)6R9qQVu41msDd5RLK9A)efbyLRLnhu61lOxo6VErX5VUIOex)6Mo86LQ(cV6RVEqEnbCtmcjt6AsJ9xVKxtRVMwWuPQxFXNiKTF81L5150VMaUjgHKbSLsV(Ib8x7H8n0F9IIZF9gEnbCtmcjdyVws2RB6WRncc0xF9G86lgWFThY3q)1ojZPF9gEndAW1a717RVwySjn2F9VEjV2dtxsvG5c(RxYRP1xtlYya71E4jn(r41xCrv5S)6L8AA91Eiio3a71TqubDOqETJo4U81id51QdrWuMxl7Ix9v7VEjVMwFThcIZnWEDCUHiK9RLDXRUaZRrit81Oi1qQ(6RxqhYxNt)AFdWEnYqE9fFIq2(r7VEjVMwFnTiJbSxtlyGxVu3q086EEnKSxpiV2dpdNnlsZRfxxtYltB)1l5106R9WtEdKgyV(c4MHZMf5f41986lG46As7sfRBgoBwKxGxVGoqGxlOqXlNS5G9x)RxYRxkErGZVb2R3aYqGx7M4w6xVbvvASVMw05auT515K0kDHer85VwCDnP51tYVA)1l51IRRjnwueWnXT0ur4I5YF9sET46AsJffbCtClT3uvq8vfHSLUM8xVKxlUUM0yrra3e3s7nvfqMH9RxYRpPGYqF6xtKI96TpccWETPL286nGme41UjUL(1BqvLMxlj71OiaTIA6UsvVUmVMnjy)1l51IRRjnwueWnXT0EtvbtkOm0NoyAPn)AX11Kglkc4M4wAVPQGVbcvdrLsjcufAZqxiIjGmzhgKaQzbq(1IRRjnwueWnXT0Etvbutxt(RfxxtASOiGBIBP9MQcrOL4qqrFmLrPcHQAcTbKQbRJUmD5cnrsdYqIsxtAHu2CG9R)1l51lfViW53a71WnqU(6UIWRB6WRfxpKxxMxl3sXLnhS)AX11KgVPQWTqkzZbLsjcu3CHbbMKoqPBH7duBHdzBrkIPdB(mmlKYMdmkumOaop0crf0g7MlmiWK0bksd1v8kT2chY22eP4Hbjq8R0cPS5aB5FT46AsJ3uv4wiLS5GsPebQlKQRuvaziHeIGPmkDlCFGQAROwlCiBBcrWuglKYMdmkuCZWzZI0MqemLXsaHDLcf3mC2SiTjebtzSeikvAOPfIkOTDfHqpbwbuO4MHZMfPnHiykJLarPsdnEa6l)RfxxtA8MQc3cPKnhukLiqf1m8kvfqgsicTO0TW9bQQ1chY2YG4KLZcPS5adn3mC2SiTrOL4qqrFmLXsGOuPXlEaAi(KRwgGuUQPXROJ2kQDlKs2CWUqQUsvbKHesicMYqHIBgoBwK2eIGPmwceLknErr0x(xlUUM04nvfUfsjBoOukrGkQz4vQkGmKWMlmiWK0bkDlCFG6TqkzZb7MlmiWK0bOTcIp5QxOLEKwBHdzBrkIPdB(mmlKYMdSL(QOV8VwCDnPXBQkClKs2CqPuIavuZWRuvazib4ke2Gev6w4(a1w4q2wgeNSCwiLnhyOPwlCiB7MxjlG4tUAHu2CGHMBgoBwKw4ke2GeTeikvA8YkQCmBuUOL(QlJgIp5QLbiLRAAwf9FT46AsJ3uv4wiLS5GsPebQlKQRuvazibMqUmy4IHUs3c3hO2chY2YeYLbdxm0TqkBoWqtTBHuYMdwuZWRuvaziHnxyqGjPdqtTBHuYMdwuZWRuvaziHi0cAUz4SzrAzc5YGHlg6wFu)AX11KgVPQWTqkzZbLsjcuxivxPQaYqcXjcz7hv6w4(a1w4q224eHS9JwiLnhyOP22hbXgNiKTF06J6xlUUM04nvfyLH4JQ)1IRRjnEtvb3Kg)ieIIQY9RfxxtA8MQcoHZdIRRjd8Y0kLseO6MHZMfPsfcvvoMLarPsdv0)1l51IRRjnEtvbuL7YGpQacrufHSvQqOI4tUAzas5QMgQE1JOTIAcTbKQblCfmHbjqevGfszZbgfkUz4SzrAHRqyds0sGOuPHgfTx4Y)AX11KgVPQGt48G46AYaVmTsPebQmHCzWWfdDLkeQTWHSTmHCzWWfdDlKYMdm0w5wiLS5GDHuDLQcidjWeYLbdxm0PqHbBFeeltixgmCXq36JA5FT46AsJ3uvG4NbX11KbEzALsjcuzqCYYPuHqTfoKTLbXjlNfszZb2VwCDnPXBQkq8ZG46AYaVmTsPebQ5qIc)x)RfxxtASUz4SzrsncTehck6JPmkviuvBLw4q2wgeNSCwiLnhyuOClKs2CWIAgELQcidjeHwOq5wiLS5GDHuDLQcidjKqemLzzku6kcHEcSc8YQE8xlUUM0yDZWzZI0BQkeHwIdbf9XugLkeQTWHSTmioz5SqkBoWqBf1eAdivdwhDz6YfAIKgKHeLUM0cPS5aJcLvCZWzZI0cxHWgKOLarPsdnRIoARO2TqkzZb7MlmiWK0buO4MHZMfPDZfgeys6albIsLgAu5y2OCrlV8Y)AX11KgRBgoBwKEtvHeIGPmkviujsXcWnKTvymJfUOY0g0yW2hbXMqemLXYMfjARiUUUHaKqSadnmWueGfAHOcAdfkePyb4gY2kmMXwjnEa6l)RfxxtASUz4Szr6nvfsicMYOuHqvnIuSaCdzBfgZyHlQmT5xlUUM0yDZWzZI0BQkGA6AsLkeQBFeeBeAjoeu0htzSeikvAOzvpsHsxri0tGvGx8a0)1IRRjnw3mC2Si9MQc(giunevkLiqvLWbNW5aXe2ZKkviuvRfoKTfb4HTqiIkWcPS5aJcf3mC2SiTiapSfcrubwciSR)AX11KgRBgoBwKEtvbFdeQgIkbiiGRdPebQURo(0KjlxyZftRuHqD7JGyJqlXHGI(ykJ1hfABFeeBeId5AyqcCFxXcmcirJLnls0wrTBHuYMd2nxyqGjPdOqrn3mC2SiTBUWGatshyjGWUU8VwCDnPX6MHZMfP3uvW3aHQHOsPebQIH(TKGjqeABib3qeUsfcvgS9rqSeH2gsWneHhyW2hbXYMfjfkRWGTpcI1njZ311neQ8Yad2(iiwFuuOS9rqSrOL4qqrFmLXsGOuPHMvrFz0AHOcAlDq4nDlkx7fVQifkDfHqpbwbEzv0)1IRRjnw3mC2Si9MQc(giunevkLiqvOndDHiMaYKDyqcOMfarPcHQBgoBwK2i0sCiOOpMYyjquQ04ffrNcf3mC2SiTrOL4qqrFmLXsGOuPHgpa9F9sEnTdGi(8(1icNVf3LVgziV23iBo86QHOX(RfxxtASUz4Szr6nvf8nqOAiAuQqOU9rqSrOL4qqrFmLX6J6xlUUM0yDZWzZI0BQk4eopiUUMmWltRukrGkymq6aZV(xlUUM0yzc5YGHlg6uzc5YGHlg6kviur8jxPHkThD0wrTBHuYMd2nxyqGjPdOqrn3mC2SiTBUWGatshyjGWUU8VwCDnPXYeYLbdxm09MQcsMf9IlDnPsfcvgS9rqSmHCzWWfdDRpQFT46AsJLjKldgUyO7nvfC0LXemnPUeuQqOYGTpcILjKldgUyOB9r9R)1IRRjnwgeNSCuzG00dMfaGsPcH6TqkzZb7MlmiWK0b)AX11KgldItwoVPQaCfcBqIkviujsXcWnKTvymJ1hffkePyb4gY2kmMXwjnR6XFT46AsJLbXjlN3uvab4HTqiIkqPcH6kROMBgoBwKw4ke2GeT(OOqz7JGyJqlXHGI(ykJ1h1YOrKIfGBiBRWygBL04v0xMcfX11neGeIfyOHbMIaSqlevqB(1IRRjnwgeNSCEtvHnxyqGjPduQqOElKs2CWU5cdcmjDaAQ5MHZMfPncTehck6JPmwciSROTIBgoBwKw4ke2GeTeikvAOzfpsRcTbKQblbUh(DLQcBUWaJLi5LlDVUmfkRqKIfGBiBRWygBL0iUUM0U5cdcmjDG1ndNnls0isXcWnKTvymJTsVSQhxE5FT46AsJLbXjlN3uvOIXHlDnzq8jYVwCDnPXYG4KLZBQkizw0lU01Kkviuv7wiLS5Gf1m8kvfqgsyZfgeys6GFT46AsJLbXjlN3uvab4BUWaLkeQi(KRwgGuUQPH6fI(VwCDnPXYG4KLZBQk4OlJjyAsDjOuHqvTBHuYMdwuZWRuvaziHnxyqGjPdqtTBHuYMdwuZWRuvazib4ke2Ge)1IRRjnwgeNSCEtvbeGhi(g6kviuBHdzBzqCYWMlmWyHu2CGHMAUz4SzrAHRqyds0saHDfTvC0fIkWqDvkuwHifla3q224CdriBBL0Oi6OrKIfGBiBRWygBL0Oi6lV8VwCDnPXYG4KLZBQkWG4KMWUA4xlUUM0yzqCYY5nvfA6KzrqfxQBqPcH62hbXo(DyqcejvbwFu)AX11KgldItwoVPQacWdeFdDLkeQX5gIq2wwzAjDank6rku2(ii2XVddsGiPkW6J6xlUUM0yzqCYY5nvfUHufG4ZdeOjG0kviuJZneHSTSY0s6aAu0J)AX11KgldItwoVPQqtNmlcQ4sDdkviuBHdzBzqCYWMlmWyHu2CG9R)1IRRjnwWyG0bgQUjDq2ePbwaHlrqPcH6kQXM26M0bztKgybeUeHW2NK2UCxwPk0utCDnP1nPdYMinWciCjc2kdi8sf9McfeFopqahDHOccDfbVOYXSr5Iw(xlUUM0ybJbshy8MQcB(mSWGeA6qasiEvPcH62hbXgHwIdbf9XugRpkku6kcHEcSc8cvfr)xlUUM0ybJbshy8MQcQ8fcRKmmibH2aY00vQqOUY2hbXgHwIdbf9XugRpk0CZWzZI0gHwIdbf9Xuglbe21LPqz7JGyJqlXHGI(ykJLarPsdnR6rkuAHOcABxri0tGvGxO6v0)1IRRjnwWyG0bgVPQaY48nali0gqQgcBqIkviunOaop0crf0g7MlmiWK0bksd1vPqHifla3q2wHXm2kPXdq)xlUUM0ybJbshy8MQcO8jfY1kvf2CX0kviunOaop0crf0g7MlmiWK0bksd1vPqHifla3q2wHXm2kPXdq)xlUUM0ybJbshy8MQcnDi4N7XpzbKH4aLkeQBFeelbCxYbJjGmehy9rrHY2hbXsa3LCWycidXbb34NnqSMwCx6ffr)xlUUM0ybJbshy8MQcKcfkoeQmyqjo4xlUUM0ybJbshy8MQclgcNDdvgiGzsjDGsfc1TpcIncTehck6JPmwFu)AX11Kglymq6aJ3uvicXHCnmibUVRybgbKOrPcHkIp5QxUq0rB7JGyJqlXHGI(ykJ1h1VwCDnPXcgdKoW4nvfiGGQsvbeUebJsfc1wiQG2sheEt3IY10q7rNcLwiQG2sheEt3IY1EH6QOtHslevqB7kcHEcOCDyv0PXRO)R)1IRRjn2CirHt9gsvaIppqGMasRuHqTfoKTnoriB)OfszZbgABFeelkcGsiaZYMfjADfbAu8xlUUM0yZHefU3uvab4bIVHUsfc1vUfsjBoyxivxPQaYqcXjcz7hPqPfoKTfb4HOyAGC1cPS5aBz0wXrxiQad1vPqzfIuSaCdzBJZneHSTvsJIOJgrkwaUHSTcJzSvsJIOV8Y)AX11KgBoKOW9MQciapSfcrubkviuv7wiLS5GDHuDLQcidjeNiKTFeTvexx3qasiwGHggykcWcTqubTHcfIuSaCdzBfgZyRKgVI(Y)AX11KgBoKOW9MQcmqA6bZcaqPuHq9wiLS5GDZfgeys6GFT46AsJnhsu4EtvHkghU01KbXNi)AX11KgBoKOW9MQcWviSbjQuHqvCDDdbiHybgAueTvuJifla3q2wHXmw4IktBOqHifla3q2wHXmwFulJMA3cPKnhSlKQRuvaziH4eHS9J)AX11KgBoKOW9MQcBUWGatshOuHq9wiLS5GDZfgeys6GFT46AsJnhsu4EtvbeGV5cduQqOI4tUAzas5QMgQxi6)AX11KgBoKOW9MQcWviSbjQuHqvTw4q22nVswaXNC1cPS5adn1UfsjBoyxivxPQaYqcmHCzWWfdD0isXcWnKTvymJTsAexxtAHRqyds06MHZMf5VwCDnPXMdjkCVPQGKzrV4sxtQuHqDLw4q2wgeNmS5cdmwiLnhyuOO2TqkzZb7cP6kvfqgsioriB)ifki(KRwgGuUQ9IxrNcLTpcIncTehck6JPmwceLknEXJlJMA3cPKnhSOMHxPQaYqcBUWGatshGMA3cPKnhSlKQRuvazibMqUmy4IH(VwCDnPXMdjkCVPQGJUmMGPj1LGsfc1vAHdzBzqCYWMlmWyHu2CGrHIA3cPKnhSlKQRuvaziH4eHS9JuOG4tUAzas5Q2lEf9LrtTBHuYMdwuZWRuvaziHi0cAQDlKs2CWIAgELQcidjS5cdcmjDaAQDlKs2CWUqQUsvbKHeyc5YGHlg6)AX11KgBoKOW9MQcWviSbjQuHqTfoKTDZRKfq8jxTqkBoWqJifla3q2wHXm2kPrCDnPfUcHnirRBgoBwK)AX11KgBoKOW9MQcmioPjSRg(1IRRjn2CirH7nvfqaEG4BORuHqvTw4q224eHS9JwiLnhyOrKIfGBiBBCUHiKTTsAC0fIkWS0veD0AHdzBzqCYWMlmWyHu2CG9RfxxtAS5qIc3BQkGa8nxyGsfc14CdriBlRmTKoGgf9ifkBFee743HbjqKufy9r9RfxxtAS5qIc3BQkGa8aX3qxPcHACUHiKTLvMwshqJIEKcLv2(ii2XVddsGiPkW6Jcn1AHdzBJteY2pAHu2CGT8VwCDnPXMdjkCVPQWnKQaeFEGanbKwPcHACUHiKTLvMwshqJIE8xlUUM0yZHefU3uvOPtMfbvCPUbLkeQTWHSTmiozyZfgySqkBoWWhXVPpe85urFU01KEyIG04g3ym]] )


end
