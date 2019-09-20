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


    spec:RegisterPack( "Havoc", 20190920, [[dOumfbqisWIuiipciytaPrPGCkfuRsHaVIQKzHs6wuLk7Is)cuAyOuDmsKLbe9mQszAke5AufABOuY3qPiJdLs15ui06acP3HsPK5rvW9av7dL4GaHOfsv0drPOAIOuuUOcbLncekFKQufgjqO6KaHWkvOUjvPkTtsulLQuvpfWujHUkkLIVIsPuJvHGQ9c5VcgmfhMyXk6XuzYiDzvBgKptsnAsYPL8AfsZgv3wODl63knCu44uLQOLJ45KA6sDDQQTduFxbgVcrDEqX6rPW8rr7hQrkHuebqL(iLbj7knISpIGKDl7JOhbP38icOHHXrame3OI6JasjEeaiUaEDiagcm8vOifra61N4ocqv3m0GOWcR6Qv5pTUncRUI(CPRnDebQHvxrhSiGPFXBqejAIaOsFKYGKDLgr2hrqYUL9r0JG0BEdbOzChszpYMytiavfL(enra0RDiaqaBaXfWRdByZECtSbe3p7tWJbbSrv3m0GOWcR6Qv5pTUncRUI(CPRnDebQHvxrhS4XGa2aCg9JZtWgqYoRydizxPrepgpgeWg22cjRuTgefpgeWgVdByB0vQgByZECtSXtUqVgBIYOxJnXv3ydiMpbgSr9ZtKU2eBy4tohgSX7RS3dSHskWpXgjPyJFYGCA5AzYpRyZavLtf2mO4CSPImexJnTQJnEp9fE1WGnle2qUBJXNuPRn1w8yqaB8oSHTrxPASX7DJpB)i2uASj3gBi3TX4t6PSTWgqSZXgVVVwf2mO4CSzESHC3gJpPNInssXMw1XgTa9ggSzHWgqSZXgVVVwf24Km3gBMhBOVVRpfBMWGncLUP2Ia4LU1ifra5sIchPiszLqkIaEkt(Pipraos1NuccOf(Z2g34Z2pAFkt(PydOyZ0hcYYGCgc5ulDhKydOytxXJnSGnkHaexxBIaa)u9H85bYBYLg1iLbjsreWtzYpf5jcWrQ(KsqadHnGfsjt(TdKQRuDaAjH4gF2(rSHjtSPf(Z2cDEik6(eySpLj)uSzySbuSziSXPsiQVgBGJnGeByYeBgcBisrdh8Z2gxWp(STvInSGnkXo2ak2qKIgo4NTvOuTTsSHfSrj2XMHXMHraIRRnraqNhi(AvOgPS3qkIaEkt(Pipraos1NuccqbSbSqkzYVDGuDLQdqlje34Z2pInGIndHnIRlWp88X6ASHfSHEDron0cr9Bn2WKj2qKIgo4NTvOuTTsSHfSXBSJndJaexxBIaGopmfcruFuJuEKqkIaEkt(Pipraos1NuccaSqkzYVDYf6dujDhbiUU2ebqV0Qc6b)mqnszpIuebiUU2ebuX4YLU2mi(ebb8uM8trEIAKYSfsreWtzYpf5jcWrQ(KsqaIRlWp88X6ASHfSrjSbuSziSrbSHifnCWpBRqPA7h5s3ASHjtSHifnCWpBRqPARpdSzySbuSrbSbSqkzYVDGuDLQdqlje34Z2pIaexxBIaompmVernsz2esreWtzYpf5jcWrQ(KsqaGfsjt(TtUqFGkP7iaX11MiGjxOpqL0DuJuMTJueb8uM8trEIaCKQpPeeaKpbgl9qLRASHf4yZiXocqCDTjca68jxOh1iLhrKIiGNYKFkYteGJu9jLGauaBAH)STtEL0aKpbg7tzYpfBafBuaBalKsM8BhivxP6a0scuHmAqZfTkSbuSHifnCWpBRqPABLydlyJ46At7H5H5LO1TlNUdseG46AteWH5H5LiQrkRe7ifrapLj)uKNiahP6tkbbme20c)zBPpUzyYf612NYKFk2WKj2Oa2awiLm53oqQUs1bOLeIB8z7hXgMmXgiFcmw6Hkx1yJhWgVXo2WKj2m9HGSX3sCjmuT6sBjpkvQXgpGnEeBggBafBuaBalKsM8BzSlVs1bOLeMCH(avs3XgqXgfWgWcPKj)2bs1vQoaTKaviJg0CrRcbiUU2ebizwQkU01MOgPSskHueb8uM8trEIaCKQpPeeWqytl8NTL(4MHjxOxBFkt(PydtMyJcydyHuYKF7aP6kvhGwsiUXNTFeByYeBG8jWyPhQCvJnEaB8g7yZWydOyJcydyHuYKFlJD5vQoaTKq8TGnGInkGnGfsjt(Tm2LxP6a0sctUqFGkP7ydOyJcydyHuYKF7aP6kvhGwsGkKrdAUOvHaexxBIaCQKvh0nPg9OgPSsGePic4Pm5NI8eb4ivFsjiGw4pB7Kxjna5tGX(uM8tXgqXgIu0Wb)STcLQTvInSGnIRRnThMhMxIw3UC6oiraIRRnrahMhMxIOgPSsEdPicqCDTjcG(4M6WS6JaEkt(PiprnszLgjKIiGNYKFkYteGJu9jLGauaBAH)STXn(S9J2NYKFk2ak2qKIgo4NTnUGF8zBReBybBCQeI6RXMra2Oe7ydOytl8NTL(4MHjxOxBFkt(PiaX11MiaOZdeFTkuJuwjpIueb8uM8trEIaCKQpPeeqCb)4Z2slDlP7ydlyJsEeByYeBM(qq21VdluGiP6B9zGaexxBIaGoFYf6rnszLylKIiGNYKFkYteGJu9jLGaIl4hF2wAPBjDhBybBuYJydtMyZqyZ0hcYU(DyHcejvFRpdSbuSrbSPf(Z2g34Z2pAFkt(PyZWiaX11MiaOZdeFTkuJuwj2esreWtzYpf5jcWrQ(KsqaXf8JpBlT0TKUJnSGnk5reG46Atea4NQpKppqEtU0OgPSsSDKIiGNYKFkYteGJu9jLGaAH)ST0h3mm5c9A7tzYpfbiUU2eb0Qi7GGAUuGpQrnc4A9t31ifrkResreWtzYpf5jcWrQ(KsqadHnkGn0TTUnDpBI0NgG4s8HPpjTD5gTs1ydOyJcyJ46AtRBt3ZMi9PbiUeVTYaeVuRQXgMmXgiFopqUtLqu)qxXJnEaBu7O2OmYyZWiaX11Mia3MUNnr6tdqCjEuJugKifrapLj)uKNiahP6tkbbm9HGSX3sCjmuT6sB9zGnmzInDfFO3aTo24b4yJsSJaexxBIaM8DPHfk0QE45JWGAKYEdPic4Pm5NI8eb4ivFsjiGPpeKn(wIlHHQvxARpdSHjtSPR4d9gO1XgpahB8g7iaX11Mia1(cHwsgwOGWgNSTkuJuEKqkIaEkt(Pipraos1NuccqZ4CEOfI63A7Kl0hOs6UsydlWXgqInmzInePOHd(zBfkvBReBybByl2raIRRnraqRZxFAqyJtQ(H5LiQrk7rKIiGNYKFkYteGJu9jLGa0moNhAHO(T2o5c9bQKURe2WcCSbKydtMydrkA4GF2wHs12kXgwWg2IDeG46AteadFsbbtLQdtUOBuJuMTqkIaEkt(Pipraos1Nuccy6dbzj3nk)ADaAjUB9zGnmzIntFiil5Ur5xRdqlX9GB9Z(eRUf3OyJhWgLyhbiUU2eb0QEWpNRFsdqlXDuJuMnHuebiUU2ebqkgm4puzqZqChb8uM8trEIAKYSDKIiGNYKFkYteGJu9jLGaM(qqwEb9jFxQv3IBuSXdyJ3qaIRRnradwcNc(vgixVPKUJAKYJisreWtzYpf5jcWrQ(Ksqaq(eyWgpGnJe7ydOyZ0hcYgFlXLWq1QlT1NbcqCDTjci(4sGjSqbUVRObk5suJAuJaOhs85nsrKYkHueb8uM8trEIawgia9BeG46AteayHuYKFeayH7Feql8NTfQi6om57sTpLj)uSHjtSrZ4CEOfI63A7Kl0hOs6UsydlWXMHWgVHnEh20c)zBBIu8Wcfi(vAFkt(PyZWiaWcjKs8iGjxOpqL0DuJugKifrapLj)uKNiGLbcq)gbiUU2ebawiLm5hbaw4(hbOa2me2Oa20c)zBZhVU02NYKFk2WKj242Lt3bPnF86sBjxOWGnmzInUD50DqAZhVU0wYJsLASHfSPfI632UIp0BGwhByYeBC7YP7G0MpEDPTKhLk1ydlydBXo2mmcaSqcPepcyGuDLQdqljKpEDPrnszVHueb8uM8trEIawgia9BeG46AteayHuYKFeayH7FeGcytl8NTL(4MLZ(uM8tXgqXg3UC6oiTX3sCjmuT6sBjpkvQXgpGnSf2ak2a5tGXspu5QgBybB8g7ydOyZqyJcydyHuYKF7aP6kvhGwsiF86sJnmzInUD50DqAZhVU0wYJsLASXdyJsSJndJaalKqkXJaySlVs1bOLeIVfuJuEKqkIaEkt(PipraldeG(ncqCDTjcaSqkzYpcaSW9pcaSqkzYVDYf6dujDhBafBgcBG8jWGnEaBytEeB8oSPf(Z2cveDhM8DP2NYKFk2mcWgqYo2mmcaSqcPepcGXU8kvhGwsyYf6dujDh1iL9isreWtzYpf5jcyzGa0VraIRRnraGfsjt(raGfU)raTWF2w6JBwo7tzYpfBafBuaBAH)STtEL0aKpbg7tzYpfBafBC7YP7G0EyEyEjAjpkvQXgpGndHnQDuBugzSzeGnGeBggBafBG8jWyPhQCvJnSGnGKDeayHesjEeaJD5vQoaTKWH5H5LiQrkZwifrapLj)uKNiGLbcq)gbiUU2ebawiLm5hbaw4(hb0c)zBPcz0GMlAv2NYKFk2ak2Oa2awiLm53YyxELQdqljm5c9bQKUJnGInkGnGfsjt(Tm2LxP6a0scX3c2ak242Lt3bPLkKrdAUOvz9zGaalKqkXJagivxP6a0scuHmAqZfTkuJuMnHueb8uM8trEIawgia9BeG46AteayHuYKFeayH7Feql8NTnUXNTF0(uM8tXgqXgfWMPpeKnUXNTF06ZabawiHuIhbmqQUs1bOLeIB8z7hrnsz2osreG46AteaT0eFgnc4Pm5NI8e1iLhrKIiaX11Mia3MA)4drrD5qapLj)uKNOgPSsSJueb8uM8trEIaCKQpPeeGAh1sEuQuJnWXg2raIRRnraoHZdIRRnd8s3iaEP7qkXJaC7YP7Ge1iLvsjKIiGNYKFkYteGJu9jLGaAH)STuHmAqZfTk7tzYpfBafBgcBalKsM8BhivxP6a0scuHmAqZfTkSHjtSH(PpeKLkKrdAUOvz9zGndJaexxBIaCcNhexxBg4LUra8s3HuIhbqfYObnx0QqnszLajsreWtzYpf5jcWrQ(KsqaTWF2w6JBwo7tzYpfbiUU2ebq8ZG46AZaV0ncGx6oKs8ia6JBwouJuwjVHueb8uM8trEIaexxBIai(zqCDTzGx6gbWlDhsjEeqUKOWrnQrami3TXP0ifrkResreWtzYpf5jciL4racBOvjerhG2SdluGXo4eeG46AteGWgAvcr0bOn7WcfySdob1iLbjsreG46AteaJTRnrapLj)uKNOgPS3qkIaEkt(Pipraos1NuccqbSryJtQ(wNkz7YfAIKAOLeLU20(uM8traIRRnraX3sCjmuT6sJAuJaOpUz5qkIuwjKIiGNYKFkYteGJu9jLGaalKsM8BNCH(avs3raIRRnra0lTQGEWpduJugKifrapLj)uKNiahP6tkbbqKIgo4NTvOuT1Nb2WKj2qKIgo4NTvOuTTsSHfSbKEebiUU2ebCyEyEjIAKYEdPic4Pm5NI8eb4ivFsjiGHWMHWgfWg3UC6oiThMhMxIwFgydtMyZ0hcYgFlXLWq1QlT1Nb2mm2ak2qKIgo4NTvOuTTsSHfSXBSJndJnmzInIRlWp88X6ASHfSHEDron0cr9BncqCDTjca68Wuier9rns5rcPic4Pm5NI8eb4ivFsjiaWcPKj)2jxOpqL0DSbuSrbSXTlNUdsB8TexcdvRU0wYfkmydOyZqyJBxoDhK2dZdZlrl5rPsn2Wc2me24rSX7WgHnoP6Bjh8YbxP6WKl0RTejhfBgbyJ3WMHXgMmXMHWgIu0Wb)STcLQTvInSGnIRRnTtUqFGkP7w3UC6oiXgqXgIu0Wb)STcLQTvInEaBaPhXMHXMHraIRRnratUqFGkP7OgPShrkIaexxBIaQyC5sxBgeFIGaEkt(Piprnsz2cPic4Pm5NI8eb4ivFsjiafWgWcPKj)wg7YRuDaAjHjxOpqL0DeG46AteGKzPQ4sxBIAKYSjKIiGNYKFkYteGJu9jLGaG8jWyPhQCvJnSahBgj2raIRRnraqNp5c9OgPmBhPic4Pm5NI8eb4ivFsjiafWgWcPKj)wg7YRuDaAjHjxOpqL0DSbuSrbSbSqkzYVLXU8kvhGws4W8W8sebiUU2eb4ujRoOBsn6rns5rePic4Pm5NI8eb4ivFsjiGw4pBl9XndtUqV2(uM8tXgqXgfWg3UC6oiThMhMxIwYfkmydOyZqyJtLquFn2ahBaj2WKj2me2qKIgo4NTnUGF8zBReBybBuIDSbuSHifnCWpBRqPABLydlyJsSJndJndJaexxBIaGopq81QqnszLyhPicqCDTjcG(4M6WS6JaEkt(PiprnszLucPic4Pm5NI8eb4ivFsjiGPpeKD97WcfisQ(wFgiaX11MiGwfzheuZLc8rnszLajsreWtzYpf5jcWrQ(KsqaXf8JpBlT0TKUJnSGnk5rSHjtSz6dbzx)oSqbIKQV1NbcqCDTjca68aXxRc1iLvYBifrapLj)uKNiahP6tkbbexWp(ST0s3s6o2Wc2OKhraIRRnraGFQ(q(8a5n5sJAKYknsifrapLj)uKNiahP6tkbb0c)zBPpUzyYf612NYKFkcqCDTjcOvr2bb1CPaFuJAeGBxoDhKifrkResreWtzYpf5jcWrQ(KsqakGndHnTWF2w6JBwo7tzYpfByYeBalKsM8BzSlVs1bOLeIVfSHjtSbSqkzYVDGuDLQdqljKpEDPXMHXgMmXMUIp0BGwhB8a2aspIaexxBIaIVL4syOA1Lg1iLbjsreWtzYpf5jcWrQ(KsqaTWF2w6JBwo7tzYpfBafBgcBuaBe24KQV1Ps2UCHMiPgAjrPRnTpLj)uSHjtSziSXTlNUds7H5H5LOL8OuPgBybBaj7ydOyZqyJcydyHuYKF7Kl0hOs6o2WKj242Lt3bPDYf6dujD3sEuQuJnSGnQDuBugzSzySzySzyeG46Ateq8TexcdvRU0OgPS3qkIaEkt(Pipraos1NuccGifnCWpBRqPA7h5s3ASbuSH(PpeKnF86sBP7GeBafBgcBexxGF45J11ydlyd96ICAOfI63ASHjtSHifnCWpBRqPABLydlydBXo2mmcqCDTjciF86sJAKYJesreWtzYpf5jcWrQ(KsqakGnePOHd(zBfkvB)ix6wJaexxBIaYhVU0OgPShrkIaEkt(Pipraos1Nuccy6dbzJVL4syOA1L2sEuQuJnSGnG0JydtMytxXh6nqRJnEaByl2raIRRnram2U2e1iLzlKIiGNYKFkYteG46AteGAHFNW5NOdZDteGJu9jLGauaBAH)STqNhMcHiQV9Pm5NInmzInUD50DqAHopmfcruFl5cfgeqkXJaul87eo)eDyUBIAKYSjKIiGNYKFkYteG46AteGdghFBYMLlm5IUraos1Nuccy6dbzJVL4syOA1L26ZaBafBM(qq24JlbMWcf4(UIgOKlrTLUdsSbuSziSrbSbSqkzYVDYf6dujDhByYeBuaBC7YP7G0o5c9bQKUBjxOWGndJaoe0DDiL4raoyC8TjBwUWKl6g1iLz7ifrapLj)uKNiaX11MiarRcSKxhicBSKGBjchb4ivFsjia6N(qqwIWglj4wIWd0p9HGS0DqInmzIndHn0p9HGSUnP(UUa)qLJgOF6dbz9zGnmzIntFiiB8TexcdvRU0wYJsLASHfSbKSJndJnGInTqu)2Q6cVvzz4ASXdyJ3ucByYeB6k(qVbADSXdydizhbKs8iarRcSKxhicBSKGBjch1iLhrKIiGNYKFkYteG46AteGWgAvcr0bOn7WcfySdobb4ivFsjia3UC6oiTX3sCjmuT6sBjpkvQXgpGnkXo2WKj242Lt3bPn(wIlHHQvxAl5rPsn2Wc2WwSJasjEeGWgAvcr0bOn7WcfySdob1iLvIDKIiGNYKFkYteGJu9jLGaM(qq24BjUegQwDPT(mqaIRRnra(6hQ(rnQrkRKsifrapLj)uKNiaX11MiaNW5bX11MbEPBeaV0DiL4raxRF6Ug1OgbqfYObnx0QqkIuwjKIiGNYKFkYteGJu9jLGaG8jWGnSahBy7SJnGIndHnkGnGfsjt(TtUqFGkP7ydtMyJcyJBxoDhK2jxOpqL0Dl5cfgSzyeG46AteaviJg0CrRc1iLbjsreWtzYpf5jcWrQ(Ksqa0p9HGSuHmAqZfTkRpdeG46AteGKzPQ4sxBIAKYEdPic4Pm5NI8eb4ivFsjia6N(qqwQqgnO5IwL1NbcqCDTjcWPswDq3KA0JAuJAea4t01MiLbj7knISZ2vIDeWaHKvQwJaarezSK(uSHnHnIRRnXgEPBTfpgbi(TQLGaaQOpx6At2CIa1iagKfQ4hbacydiUaEDydB2JBInG4(zFcEmiGnQ6MHgefwyvxTk)P1Try1v0NlDTPJiqnS6k6GfpgeWgGZOFCEc2as2zfBaj7knI4X4XGa2W2wizLQ1GO4XGa24DydBJUs1ydB2JBInEYf61ytug9ASjU6gBaX8jWGnQFEI01MyddFY5WGnEFL9EGnusb(j2ijfB8tgKtlxlt(zfBgOQCQWMbfNJnvKH4ASPvDSX7PVWRggSzHWgYDBm(KkDTP2IhdcyJ3HnSn6kvJnEVB8z7hXMsJn52yd5UngFspLTf2aIDo24991QWMbfNJnZJnK72y8j9uSrsk20Qo2OfO3WGnle2aIDo24991QWgNK52yZ8yd99D9PyZegSrO0n1w8y8yqaByZvjP6RbrXJbbSX7WgqKu6PydB(MA)4XgVxrD5S4XGa24DyJ3)Xf8Pytle1Vdfe24uD3Oyd0sWgLF86sJnYS4vdJfpgeWgVdB8(pUGpfBIl4hF2yJmlE111ydezJyddsTKQHbBgO6j2KBJn(6tXgOLGnEVB8z7hT4XGa24Dydisk9uSHTrFSber)OgB6fBEsXMfcByZ3Lt3bPgBexxBYlDBXJbbSX7Wg28nbFsFk2mc52Lt3b5ie20l2mcjUU20oc362Lt3b5ie2mq1jhBegm4LtM8BXJXJbbSze2iFNFFk2mp0so2424uASzE1vQTydisN7mAn2KB6DQeseYNJnIRRn1yZMCyS4XGa2iUU2uBzqUBJtPHdXf9O4XGa2iUU2uBzqUBJtP9coSIV64Zw6At8yqaBexxBQTmi3TXP0EbhwODP4XGa2aKcdTQTXgIuuSz6dbDk2OBP1yZ8ql5yJBJtPXM5vxPgBKKInmi37ySDxPASP0ydDZBXJbbSrCDTP2YGC3gNs7fCy1PWqRA7GULwJhlUU2uBzqUBJtP9coS(6hQ(rwtjE4cBOvjerhG2SdluGXo4e8yX11MAldYDBCkTxWHLX21M4XIRRn1wgK724uAVGdB8TexcdvRU0SwqWvqyJtQ(wNkz7YfAIKAOLeLU20(uM8tXJXJbbSze2iFNFFk2CWNad20v8ytR6yJ46LGnLgBeWsXLj)w8yX11MAVGdlyHuYKFwtjE4tUqFGkP7Scw4(hEl8NTfQi6om57sTpLj)uMm1moNhAHO(T2o5c9bQKURelWhYBExl8NTTjsXdluG4xP9Pm5NomES46AtTxWHfSqkzYpRPep8bs1vQoaTKq(41LMvWc3)WvyifAH)ST5JxxA7tzYpLjt3UC6oiT5JxxAl5cfgMmD7YP7G0MpEDPTKhLk1S0cr9BBxXh6nqRZKPBxoDhK28XRlTL8OuPMf2I9HXJfxxBQ9coSGfsjt(znL4HZyxELQdqljeFlScw4(hUcTWF2w6JBwo7tzYpfu3UC6oiTX3sCjmuT6sBjpkvQ9aBbkKpbgl9qLRAw8g7GoKcGfsjt(TdKQRuDaAjH8XRlntMUD50DqAZhVU0wYJsLApOe7dJhlUU2u7fCyblKsM8ZAkXdNXU8kvhGwsyYf6dujDNvWc3)WblKsM8BNCH(avs3bDiiFcmEGn5rVRf(Z2cveDhM8DP2NYKF6iaKSpmES46AtTxWHfSqkzYpRPepCg7YRuDaAjHdZdZlrwblC)dVf(Z2sFCZYzFkt(PGQql8NTDYRKgG8jWyFkt(PG62Lt3bP9W8W8s0sEuQu7HHu7O2OmYJaqomOq(eyS0dvUQzbKSJhlUU2u7fCyblKsM8ZAkXdFGuDLQdqljqfYObnx0QyfSW9p8w4pBlviJg0CrRY(uM8tbvbWcPKj)wg7YRuDaAjHjxOpqL0DqvaSqkzYVLXU8kvhGwsi(wa1TlNUdslviJg0CrRY6ZapwCDTP2l4WcwiLm5N1uIh(aP6kvhGwsiUXNTFKvWc3)WBH)STXn(S9J2NYKFkOkm9HGSXn(S9JwFg4XIRRn1EbhwAPj(mA8yX11MAVGdRBtTF8HOOUC4XIRRn1EbhwNW5bX11MbEPBwtjE4UD50DqYAbbxTJAjpkvQHZoEmiGnIRRn1EbhwgLB0GpJaeruhF2SwqWH8jWyPhQCvZcCV5rqhsbHnoP6BpmxhwOaruF7tzYpLjt3UC6oiThMhMxIwYJsLAwuYosdJhlUU2u7fCyDcNhexxBg4LUznL4HtfYObnx0QyTGG3c)zBPcz0GMlAv2NYKFkOdbwiLm53oqQUs1bOLeOcz0GMlAvmzs)0hcYsfYObnx0QS(mggpwCDTP2l4Ws8ZG46AZaV0nRPepC6JBwowli4TWF2w6JBwo7tzYpfpwCDTP2l4Ws8ZG46AZaV0nRPep8CjrHJhJhlUU2uBD7YP7GeE8TexcdvRU0SwqWvyOw4pBl9XnlN9Pm5NYKjyHuYKFlJD5vQoaTKq8TWKjyHuYKF7aP6kvhGwsiF86spmtMDfFO3aTUhaPhXJfxxBQTUD50Dq6fCyJVL4syOA1LM1ccEl8NTL(4MLZ(uM8tbDife24KQV1Ps2UCHMiPgAjrPRnTpLj)uMmhYTlNUds7H5H5LOL8OuPMfqYoOdPayHuYKF7Kl0hOs6otMUD50DqANCH(avs3TKhLk1SO2rTrzKhE4HXJfxxBQTUD50Dq6fCyZhVU0SwqWjsrdh8Z2kuQ2(rU0Tgu6N(qq28XRlTLUdsqhsCDb(HNpwxZc96ICAOfI63AMmjsrdh8Z2kuQ2wjlSf7dJhlUU2uBD7YP7G0l4WMpEDPzTGGRarkA4GF2wHs12pYLU14XIRRn1w3UC6oi9coSm2U2K1cc(0hcYgFlXLWq1QlTL8OuPMfq6rMm7k(qVbADpWwSJhlUU2uBD7YP7G0l4W6RFO6hznL4HRw43jC(j6WC3K1ccUcTWF2wOZdtHqe13(uM8tzY0TlNUdsl05HPqiI6BjxOWGhlUU2uBD7YP7G0l4W6RFO6hz9qq31HuIhUdghFBYMLlm5IUzTGGp9HGSX3sCjmuT6sB9za60hcYgFCjWewOa33v0aLCjQT0Dqc6qkawiLm53o5c9bQKUZKPcUD50DqANCH(avs3TKluyggpwCDTP262Lt3bPxWH1x)q1pYAkXdx0Qal51bIWglj4wIWzTGGt)0hcYse2yjb3seEG(PpeKLUdsMmhI(PpeK1Tj131f4hQC0a9tFiiRpdMmN(qq24BjUegQwDPTKhLk1Sas2hg0wiQFBvDH3QSmCTh8Msmz2v8HEd06EaKSJhlUU2uBD7YP7G0l4W6RFO6hznL4HlSHwLqeDaAZoSqbg7GtyTGG72Lt3bPn(wIlHHQvxAl5rPsThuIDMmD7YP7G0gFlXLWq1QlTL8OuPMf2ID8yqaByZoK4ZBSbs48P4gfBGwc24RLj)yt1pQT4XIRRn1w3UC6oi9coS(6hQ(rnRfe8PpeKn(wIlHHQvxARpd8yX11MARBxoDhKEbhwNW5bX11MbEPBwtjE4xRF6UgpgpwCDTP2sfYObnx0QGtfYObnx0QyTGGd5tGHf4SD2bDifalKsM8BNCH(avs3zYub3UC6oiTtUqFGkP7wYfkmdJhlUU2uBPcz0GMlAvEbhwjZsvXLU2K1cco9tFiilviJg0CrRY6ZapwCDTP2sfYObnx0Q8coSovYQd6MuJEwli40p9HGSuHmAqZfTkRpd8y8yX11MAl9XnlhC6Lwvqp4NbRfeCWcPKj)2jxOpqL0D8yX11MAl9XnlNxWH9W8W8sK1ccorkA4GF2wHs1wFgmzsKIgo4NTvOuTTswaPhXJfxxBQT0h3SCEbhwOZdtHqe1N1cc(qdPGBxoDhK2dZdZlrRpdMmN(qq24BjUegQwDPT(mgguIu0Wb)STcLQTvYI3yFyMmfxxGF45J11SqVUiNgAHO(TgpwCDTP2sFCZY5fCyNCH(avs3zTGGdwiLm53o5c9bQKUdQcUD50DqAJVL4syOA1L2sUqHb0HC7YP7G0EyEyEjAjpkvQzzip6DcBCs13so4LdUs1HjxOxBjso6iWBdZK5qePOHd(zBfkvBRKfX11M2jxOpqL0DRBxoDhKGsKIgo4NTvOuTTspaspo8W4XIRRn1w6JBwoVGdBfJlx6AZG4te8yX11MAl9XnlNxWHvYSuvCPRnzTGGRayHuYKFlJD5vQoaTKWKl0hOs6oES46AtTL(4MLZl4WcD(Kl0ZAbbhYNaJLEOYvnlWhj2XJfxxBQT0h3SCEbhwNkz1bDtQrpRfeCfalKsM8BzSlVs1bOLeMCH(avs3bvbWcPKj)wg7YRuDaAjHdZdZlr8yX11MAl9XnlNxWHf68aXxRI1ccEl8NTL(4MHjxOxBFkt(PGQGBxoDhK2dZdZlrl5cfgqhYPsiQVgoizYCiIu0Wb)STXf8JpBBLSOe7GsKIgo4NTvOuTTswuI9HhgpwCDTP2sFCZY5fCyPpUPomR(4XIRRn1w6JBwoVGdBRISdcQ5sb(SwqWN(qq21VdluGiP6B9zGhlUU2uBPpUz58coSqNhi(AvSwqWJl4hF2wAPBjDNfL8itMtFii763HfkqKu9T(mWJfxxBQT0h3SCEbhwWpvFiFEG8MCPzTGGhxWp(ST0s3s6olk5r8yX11MAl9XnlNxWHTvr2bb1CPaFwli4TWF2w6JBgMCHET9Pm5NIhJhlUU2uBVw)0DnC3MUNnr6tdqCjEwli4dPaDBRBt3ZMi9PbiUeFy6tsBxUrRunOkiUU206209SjsFAaIlXBRmaXl1QAMmH858a5ovcr9dDfVhu7O2OmYdJhlUU2uBVw)0DTxWHDY3LgwOqR6HNpcdRfe8PpeKn(wIlHHQvxARpdMm7k(qVbADpaxj2XJfxxBQTxRF6U2l4WQ2xi0sYWcfe24KTvXAbbF6dbzJVL4syOA1L26ZGjZUIp0BGw3dW9g74XIRRn12R1pDx7fCyHwNV(0GWgNu9dZlrwli4AgNZdTqu)wBNCH(avs3vIf4GKjtIu0Wb)STcLQTvYcBXoES46AtT9A9t31Ebhwg(KccMkvhMCr3SwqW1moNhAHO(T2o5c9bQKURelWbjtMePOHd(zBfkvBRKf2ID8yX11MA716NUR9coSTQh8Z56N0a0sCN1cc(0hcYsUBu(16a0sC36ZGjZPpeKLC3O8R1bOL4EWT(zFIv3IBupOe74XIRRn12R1pDx7fCyjfdg8hQmOziUJhlUU2uBVw)0DTxWHDWs4uWVYa56nL0Dwli4tFiilVG(KVl1QBXnQh8gES46AtT9A9t31Ebh24JlbMWcf4(UIgOKlrnRfeCiFcmEyKyh0PpeKn(wIlHHQvxARpd8y8yX11MABUKOWHd(P6d5ZdK3KlnRfe8w4pBBCJpB)O9Pm5Nc60hcYYGCgc5ulDhKG2v8SOeES46AtTnxsu4EbhwOZdeFTkwli4dbwiLm53oqQUs1bOLeIB8z7hzYSf(Z2cDEik6(eySpLj)0HbDiNkHO(A4GKjZHisrdh8Z2gxWp(STvYIsSdkrkA4GF2wHs12kzrj2hEy8yX11MABUKOW9coSqNhMcHiQpRfeCfalKsM8BhivxP6a0scXn(S9JGoK46c8dpFSUMf61f50qle1V1mzsKIgo4NTvOuTTsw8g7dJhlUU2uBZLefUxWHLEPvf0d(zWAbbhSqkzYVDYf6dujDhpwCDTP2MljkCVGdBfJlx6AZG4te8yX11MABUKOW9coShMhMxISwqWfxxGF45J11SOeOdParkA4GF2wHs12pYLU1mzsKIgo4NTvOuT1NXWGQayHuYKF7aP6kvhGwsiUXNTFepwCDTP2MljkCVGd7Kl0hOs6oRfeCWcPKj)2jxOpqL0D8yX11MABUKOW9coSqNp5c9SwqWH8jWyPhQCvZc8rID8yX11MABUKOW9coShMhMxISwqWvOf(Z2o5vsdq(eySpLj)uqvaSqkzYVDGuDLQdqljqfYObnx0QaLifnCWpBRqPABLSiUU20EyEyEjAD7YP7GepwCDTP2MljkCVGdRKzPQ4sxBYAbbFOw4pBl9XndtUqV2(uM8tzYubWcPKj)2bs1vQoaTKqCJpB)itMq(eyS0dvUQ9G3yNjZPpeKn(wIlHHQvxAl5rPsTh84WGQayHuYKFlJD5vQoaTKWKl0hOs6oOkawiLm53oqQUs1bOLeOcz0GMlAv4XIRRn12CjrH7fCyDQKvh0nPg9SwqWhQf(Z2sFCZWKl0RTpLj)uMmvaSqkzYVDGuDLQdqlje34Z2pYKjKpbgl9qLRAp4n2hgufalKsM8BzSlVs1bOLeIVfqvaSqkzYVLXU8kvhGwsyYf6dujDhufalKsM8BhivxP6a0scuHmAqZfTk8yX11MABUKOW9coShMhMxISwqWBH)STtEL0aKpbg7tzYpfuIu0Wb)STcLQTvYI46At7H5H5LO1TlNUds8yX11MABUKOW9coS0h3uhMvF8yX11MABUKOW9coSqNhi(AvSwqWvOf(Z2g34Z2pAFkt(PGsKIgo4NTnUGF8zBRKfNkHO(6rGsSdAl8NTL(4MHjxOxBFkt(P4XIRRn12CjrH7fCyHoFYf6zTGGhxWp(ST0s3s6olk5rMmN(qq21VdluGiP6B9zGhlUU2uBZLefUxWHf68aXxRI1ccECb)4Z2slDlP7SOKhzYCOPpeKD97WcfisQ(wFgGQql8NTnUXNTF0(uM8thgpwCDTP2MljkCVGdl4NQpKppqEtU0SwqWJl4hF2wAPBjDNfL8iES46AtTnxsu4Ebh2wfzheuZLc8zTGG3c)zBPpUzyYf612NYKFkQrncba]] )


end
