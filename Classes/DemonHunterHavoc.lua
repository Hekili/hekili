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


    spec:RegisterPack( "Havoc", 20191111, [[dOedhbqisjlsjI6ruLQnPsAukrDkLeRsjI8kQsMfkv3cLq7Is)cL0WOkCmiPLPs0ZujyAkrY1OkLTrQeFdLOmoLiLZHsG1PeP6DkrqnpsL6EOO9Hs5GOevwivrpKuj1erjOUOseInQsO8rLiiJeLOQtQeHALkPUPkHQDsk1sjvsEQkMkPIRIsq(QseWyvIaTxO(RGbtYHjwSs9yQmzKUmyZq8zsvJMuCAjVwjPzJQBl0Uf9BfdhsDCLiKwoINtX0L66uvBxL67kHXRsiNhsSEuImFuy)QAmQyDWhQ0aw7l9avwaQOIkQwuV0JLcvDbFAuqd4dAXTQOhWNuIa(WYl3JdFqlOWhHI1bFmJpXb4JMUrBw6SYQ(Q14VTUjYQPI(CPRjDebPz1urhR4Z2V49sCI34dvAaR9LEGklavurfvlQx6Xs5blaFmObhwBVXYyz4JMIsHeVXhkyC4J3FflVCpUxXcdXjFflVF2a5x79xPPB0MLoRSQVAn(BRBISAQOpx6AshrqAwnv0X6V27Vs75gIBG8kurL9xDPhOYc(1)AV)QLacjRuVzP)R9(RyXxXczQu)RyHH4KVYtUqbZRIYQG5vXX0V6I5tq5v6Heisxt(k0(eGJYR0vAVe6vusDd5RKK(k)enbOLRLnhy)vl0uonVArX5VQIOfx)Qwd8QLO(cVAuE1G8kc4MyesQ01Kg7V27VIfFflKPs9V6IpriB)4RkZRYPFfbCtmcjfOlHF1fd4Vsx5B08QffN)Qn8kc4MyeskqFLK0x1AGxzeeOr5vdYRUya)v6kFJMx5KmN(vB4vuObxd0xTr5vcLoPX(R)1E)v6AnsQhml9FT3Ffl(kwokfOVsxpPXpcV6Il6lN9x79xXIVsxbX5gOVQfIEOdfYRCAa3QVcziVsBicMY8kzx8QrX(R9(RyXxPRG4Cd0xfNBicz)kzx8QlW8keYeFfAsnKQr5vl0a5RYPFLVbOVcziV6IpriB)O9x79xXIVILJsb6RyHmWRwIBiAEvpVcs6RgKxPRNHtNfP5vIRRj5LPT)AV)kw8v66jVbsd0xTKDZWPZICj)QEE1swCDnPDjO1ndNolYL8RwObiWRe0O5Lt2CWIp8Y0gSo4toKOWX6G1gvSo4dKYMduSN4JJunqkbFAHdzBJteY2pAHu2CG(QRVA7JGyrta0cbOw6SiF11x1veEfBVcv8rCDnj(CdPEaXNhiqtaPXnw7lX6GpqkBoqXEIpos1aPe8z5xDlKs2CWUqQUs9bKHeIteY2p(kgmEvlCiBlcWdrX0abflKYMd0xTYRU(QLFLtJq0dMxX8vx(kgmE1YVIifna3q224CdriBBLVITxHQhV66RisrdWnKTvOuJTYxX2Rq1JxTYRwbFexxtIpiapq8nAWnw7lG1bFGu2CGI9eFCKQbsj4JwV6wiLS5GDHuDL6didjeNiKTF8vxF1YVsCDDdbiHybMxX2ROGPian0crp0MxXGXRisrdWnKTvOuJTYxX2RUGhVAf8rCDnj(Ga8WwierpGBS2lfwh8bszZbk2t8XrQgiLGp3cPKnhSBUqHavshGpIRRjXhkiTMGzbaOXnwBVH1bFexxtIpvmoCPRjdIprWhiLnhOypXnwBDbRd(aPS5af7j(4ivdKsWhX11neGeIfyEfBVc1xD9vl)kTEfrkAaUHSTcLASWfvM28kgmEfrkAaUHSTcLAS(OF1kV66R06v3cPKnhSlKQRuFaziH4eHS9J4J46As8bqbcBqI4gRnldRd(aPS5af7j(4ivdKsWNBHuYMd2nxOqGkPdWhX11K4ZMluiqL0b4gR9sdRd(aPS5af7j(4ivdKsWheFckwkGuUQFfBmF1s5b(iUUMeFqa(Mlua3yTzbyDWhiLnhOypXhhPAGuc(O1RAHdzB38kPbeFckwiLnhOV66R06v3cPKnhSlKQRuFazibQqwny4IrZRU(kIu0aCdzBfk1yR8vS9kX11KwafiSbjADZWPZIeFexxtIpakqydse3yTr1dSo4dKYMduSN4JJunqkbFw(vTWHSTuiozyZfkySqkBoqFfdgVsRxDlKs2CWUqQUs9bKHeIteY2p(kgmEfIpbflfqkx1Vs3V6cE8kgmE12hbXgHwIdbTMXuglbIsLMxP7x5TxTYRU(kTE1TqkzZbl6z4vQpGmKWMluiqL0bV66R06v3cPKnhSlKQRuFazibQqwny4Ird(iUUMeFKmlnfx6AsCJ1gvuX6GpqkBoqXEIpos1aPe8z5x1chY2sH4KHnxOGXcPS5a9vmy8kTE1TqkzZb7cP6k1hqgsioriB)4RyW4vi(euSuaPCv)kD)Ql4XRw5vxFLwV6wiLS5Gf9m8k1hqgsicT8QRVsRxDlKs2CWIEgEL6didjS5cfcujDWRU(kTE1TqkzZb7cP6k1hqgsGkKvdgUy0GpIRRjXhNgzmbttQvbCJ1g1lX6GpqkBoqXEIpos1aPe8PfoKTDZRKgq8jOyHu2CG(QRVIifna3q2wHsn2kFfBVsCDnPfqbcBqIw3mC6SiXhX11K4dGce2GeXnwBuVawh8rCDnj(qH4KMWUAaFGu2CGI9e3yTrDPW6GpqkBoqXEIpos1aPe8rRx1chY2gNiKTF0cPS5a9vxFfrkAaUHSTX5gIq22kFfBVYPri6bZRwsVcvpE11x1chY2sH4KHnxOGXcPS5afFexxtIpiapq8nAWnwBu9gwh8bszZbk2t8XrQgiLGpX5gIq2wAzAjDWRy7vO6TxXGXR2(ii2XVddsGiPEW6JgFexxtIpiaFZfkGBS2OQlyDWhiLnhOypXhhPAGuc(eNBiczBPLPL0bVITxHQ3EfdgVA5xT9rqSJFhgKars9G1h9RU(kTEvlCiBBCIq2(rlKYMd0xTc(iUUMeFqaEG4B0GBS2OYYW6GpqkBoqXEIpos1aPe8jo3qeY2sltlPdEfBVcvVHpIRRjXNBi1di(8abAcinUXAJ6sdRd(aPS5af7j(4ivdKsWNw4q2wkeNmS5cfmwiLnhO4J46As8P1qMfb9CPUbCJB8bmgiDGbRdwBuX6GpqkBoqXEIpos1aPe8z5xP1ROtBDt6GSjsd0acxIqy7tsBxUvRu)RU(kTEL46AsRBshKnrAGgq4seSvgq4LEn9RyW4vi(CEGaoncrpe6kcVs3VsVJAJYf9QvWhX11K4JBshKnrAGgq4seWnw7lX6GpqkBoqXEIpos1aPe8z7JGyJqlXHGwZykJ1h9RyW4vDfHqpbAbVs3mFfQEGpIRRjXNnFgAyqcTgiajerb3yTVawh8bszZbk2t8XrQgiLGpl)QTpcIncTehcAnJPmwF0V66RCZWPZI0gHwIdbTMXuglbekkVALxXGXR2(ii2i0sCiO1mMYyjquQ08k2E1LE7vmy8Qwi6H22vec9eOf8kDZ8vxWd8rCDnj(O3xi0sYWGeewcitRb3yTxkSo4dKYMduSN4JJunqkbFmObop0crp0g7MluiqL0bO(k2y(QlFfdgVIifna3q2wHsn2kFfBVsx8aFexxtIpiJZ3a0GWsaPAiSbjIBS2EdRd(aPS5af7j(4ivdKsWhdAGZdTq0dTXU5cfcujDaQVInMV6YxXGXRisrdWnKTvOuJTYxX2R0fpWhX11K4dAFsHGsL6dBUyACJ1wxW6GpqkBoqXEIpos1aPe8z7JGyjGBvoymbKH4aRp6xXGXR2(iiwc4wLdgtazioi4g)SbI10IB1xP7xHQh4J46As8P1ab)Cp(jnGmehGBS2SmSo4J46As8HuOrZHqLbdAXb4dKYMduSN4gR9sdRd(aPS5af7j(4ivdKsWNTpcILxiWMpd1AAXT6R09RUa(iUUMeFwmeo9gQmqaZKs6aCJ1MfG1bFGu2CGI9eFCKQbsj4dIpbLxP7xTuE8QRVA7JGyJqlXHGwZykJ1hn(iUUMeFIqCiOegKa33v0aLas0GBCJpuar85nwhS2OI1bFGu2CGI9eFg04JbA8rCDnj(ClKs2CaFUfUpGpTWHSTifX0HnFgQfszZb6RyW4vg0aNhAHOhAJDZfkeOs6auFfBmF1YV6cVIfFvlCiBBtKIhgKaXVslKYMd0xTc(ClKqkraF2CHcbQKoa3yTVeRd(aPS5af7j(mOXhd04J46As85wiLS5a(ClCFaF06vl)kTEvlCiBBcrWuglKYMd0xXGXRCZWPZI0MqemLXsaHIYRyW4vUz40zrAticMYyjquQ08k2Evle9qB7kcHEc0cEfdgVYndNolsBcrWuglbIsLMxX2R0fpE1k4ZTqcPeb8zHuDL6didjKqemLb3yTVawh8bszZbk2t8zqJpgOXhX11K4ZTqkzZb85w4(a(O1RAHdzBPqCYYzHu2CG(QRVYndNolsBeAjoe0AgtzSeikvAELUFLU8QRVcXNGILciLR6xX2RUGhV66Rw(vA9QBHuYMd2fs1vQpGmKqcrWuMxXGXRCZWPZI0MqemLXsGOuP5v6(vO6XRwbFUfsiLiGpONHxP(aYqcrOfCJ1EPW6GpqkBoqXEIpdA8Xan(iUUMeFUfsjBoGp3c3hWNBHuYMd2nxOqGkPdE11xT8Rq8jO8kD)kwM3Efl(Qw4q2wKIy6WMpd1cPS5a9vlPxDPhVAf85wiHuIa(GEgEL6didjS5cfcujDaUXA7nSo4dKYMduSN4ZGgFmqJpIRRjXNBHuYMd4ZTW9b8PfoKTLcXjlNfszZb6RU(kTEvlCiB7MxjnG4tqXcPS5a9vxFLBgoDwKwafiSbjAjquQ08kD)QLFLEh1gLl6vlPxD5Rw5vxFfIpbflfqkx1VITxDPh4ZTqcPeb8b9m8k1hqgsaqbcBqI4gRTUG1bFGu2CGI9eFg04JbA8rCDnj(ClKs2CaFUfUpGpTWHSTuHSAWWfJglKYMd0xD9vA9QBHuYMdw0ZWRuFaziHnxOqGkPdE11xP1RUfsjBoyrpdVs9bKHeIqlV66RCZWPZI0sfYQbdxmAS(OXNBHesjc4ZcP6k1hqgsGkKvdgUy0GBS2SmSo4dKYMduSN4ZGgFmqJpIRRjXNBHuYMd4ZTW9b8PfoKTnoriB)OfszZb6RU(kTE12hbXgNiKTF06JgFUfsiLiGplKQRuFaziH4eHS9J4gR9sdRd(iUUMeFOLH4JUXhiLnhOypXnwBwawh8rCDnj(4M04hHqu0xo8bszZbk2tCJ1gvpW6GpqkBoqXEIpos1aPe8rVJAjquQ08kMVYd8rCDnj(4eopiUUMmWltJp8Y0HuIa(4MHtNfjUXAJkQyDWhiLnhOypXhhPAGuc(0chY2sfYQbdxmASqkBoqF11xT8RUfsjBoyxivxP(aYqcuHSAWWfJMxXGXROW2hbXsfYQbdxmAS(OF1k4J46As8XjCEqCDnzGxMgF4LPdPeb8HkKvdgUy0GBS2OEjwh8bszZbk2t8XrQgiLGpTWHSTuioz5SqkBoqXhX11K4dXpdIRRjd8Y04dVmDiLiGpuioz5WnwBuVawh8bszZbk2t8rCDnj(q8ZG46AYaVmn(Wlthsjc4toKOWXnUXh0eWnXT0yDWAJkwh8bszZbk2t8jLiGpclz0ieXeqMSddsa9Sai4J46As8ryjJgHiMaYKDyqcONfab3yTVeRd(iUUMeFqpDnj(aPS5af7jUXAFbSo4dKYMduSN4JJunqkbF06vclbKQbRtJmD5cnrsdYqIsxtAHu2CGIpIRRjXNi0sCiO1mMYGBCJpuioz5W6G1gvSo4dKYMduSN4JJunqkbFUfsjBoy3CHcbQKoaFexxtIpuqAnbZcaqJBS2xI1bFGu2CGI9eFCKQbsj4drkAaUHSTcLAS(OFfdgVIifna3q2wHsn2kFfBV6sVHpIRRjXhafiSbjIBS2xaRd(aPS5af7j(4ivdKsWNLF1YVsRx5MHtNfPfqbcBqIwF0VIbJxT9rqSrOL4qqRzmLX6J(vR8QRVIifna3q2wHsn2kFfBV6cE8QvEfdgVsCDDdbiHybMxX2ROGPian0crp0g8rCDnj(Ga8WwierpGBS2lfwh8bszZbk2t8XrQgiLGp3cPKnhSBUqHavsh8QRVsRx5MHtNfPncTehcAnJPmwciuuE11xT8RCZWPZI0cOaHnirlbIsLMxX2Rw(vE7vS4RewcivdwcCp87k1h2CHcglrYvF1s6vx4vR8kgmE1YVIifna3q2wHsn2kFfBVsCDnPDZfkeOs6aRBgoDwKV66RisrdWnKTvOuJTYxP7xDP3E1kVAf8rCDnj(S5cfcujDaUXA7nSo4J46As8PIXHlDnzq8jc(aPS5af7jUXARlyDWhiLnhOypXhhPAGuc(O1RUfsjBoyrpdVs9bKHe2CHcbQKoaFexxtIpsMLMIlDnjUXAZYW6GpqkBoqXEIpos1aPe8bXNGILciLR6xXgZxTuEGpIRRjXheGV5cfWnw7Lgwh8bszZbk2t8XrQgiLGpA9QBHuYMdw0ZWRuFaziHnxOqGkPdE11xP1RUfsjBoyrpdVs9bKHeauGWgKi(iUUMeFCAKXemnPwfWnwBwawh8bszZbk2t8XrQgiLGpTWHSTuiozyZfkySqkBoqF11xP1RCZWPZI0cOaHnirlbekkV66Rw(voncrpyEfZxD5RyW4vl)kIu0aCdzBJZneHSTv(k2EfQE8QRVIifna3q2wHsn2kFfBVcvpE1kVAf8rCDnj(Ga8aX3Ob3yTr1dSo4J46As8HcXjnHD1a(aPS5af7jUXAJkQyDWhiLnhOypXhhPAGuc(S9rqSJFhgKars9G1hn(iUUMeFAnKzrqpxQBa3yTr9sSo4dKYMduSN4JJunqkbFIZneHST0Y0s6GxX2Rq1BVIbJxT9rqSJFhgKars9G1hn(iUUMeFqaEG4B0GBS2OEbSo4dKYMduSN4JJunqkbFIZneHST0Y0s6GxX2Rq1B4J46As85gs9aIppqGMasJBS2OUuyDWhiLnhOypXhhPAGuc(0chY2sH4KHnxOGXcPS5afFexxtIpTgYSiONl1nGBCJpUz40zrI1bRnQyDWhiLnhOypXhhPAGuc(O1Rw(vTWHSTuioz5SqkBoqFfdgV6wiLS5Gf9m8k1hqgsicT8kgmE1TqkzZb7cP6k1hqgsiHiykZRw5vmy8QUIqONaTGxP7xDP3WhX11K4teAjoe0AgtzWnw7lX6GpqkBoqXEIpos1aPe8PfoKTLcXjlNfszZb6RU(QLFLwVsyjGunyDAKPlxOjsAqgsu6AslKYMd0xXGXRw(vUz40zrAbuGWgKOLarPsZRy7vx6XRU(QLFLwV6wiLS5GDZfkeOs6GxXGXRCZWPZI0U5cfcujDGLarPsZRy7v6DuBuUOxTYRw5vRGpIRRjXNi0sCiO1mMYGBS2xaRd(aPS5af7j(4ivdKsWhIu0aCdzBfk1yHlQmT5vxFff2(ii2eIGPmw6SiF11xT8Rexx3qasiwG5vS9kkykcqdTq0dT5vmy8kIu0aCdzBfk1yR8vS9kDXJxTc(iUUMeFsicMYGBS2lfwh8bszZbk2t8XrQgiLGpA9kIu0aCdzBfk1yHlQmTbFexxtIpjebtzWnwBVH1bFGu2CGI9eFCKQbsj4Z2hbXgHwIdbTMXuglbIsLMxX2RU0BVIbJx1vec9eOf8kD)kDXd8rCDnj(GE6AsCJ1wxW6GpqkBoqXEIpIRRjXh9chCcNdetyptIpos1aPe8rRx1chY2Ia8WwierpyHu2CG(kgmELBgoDwKweGh2cHi6blbekk4tkraF0lCWjCoqmH9mjUXAZYW6GpqkBoqXEIpIRRjXhhko(0KjlxyZftJpos1aPe8z7JGyJqlXHGwZykJ1h9RU(QTpcIncXHGsyqcCFxrducirJLolYxD9vl)kTE1TqkzZb7MluiqL0bVIbJxP1RCZWPZI0U5cfcujDGLacfLxTc(aiiGRdPeb8XHIJpnzYYf2CX04gR9sdRd(aPS5af7j(iUUMeFeJMBjbtGiS0qcUHiC8XrQgiLGpuy7JGyjclnKGBicpqHTpcILolYxXGXRw(vuy7JGyDts9DDDdHkxnqHTpcI1h9RyW4vBFeeBeAjoe0AgtzSeikvAEfBV6spE1kV66RAHOhARgq4TglAx)kD)QlG6RyW4vDfHqpbAbVs3V6spWNuIa(ign3scMaryPHeCdr44gRnlaRd(aPS5af7j(iUUMeFewYOriIjGmzhgKa6zbqWhhPAGuc(4MHtNfPncTehcAnJPmwceLknVs3VcvpEfdgVYndNolsBeAjoe0AgtzSeikvAEfBVsx8aFsjc4JWsgncrmbKj7WGeqplacUXAJQhyDWhiLnhOypXhhPAGuc(S9rqSrOL4qqRzmLX6JgFexxtIp(giunen4gRnQOI1bFGu2CGI9eFexxtIpoHZdIRRjd8Y04dVmDiLiGpGXaPdm4g34dviRgmCXObRdwBuX6GpqkBoqXEIpos1aPe8bXNGYRyJ5RwAE8QRVA5xP1RUfsjBoy3CHcbQKo4vmy8kTELBgoDwK2nxOqGkPdSeqOO8QvWhX11K4dviRgmCXOb3yTVeRd(aPS5af7j(4ivdKsWhkS9rqSuHSAWWfJgRpA8rCDnj(izwAkU01K4gR9fW6GpqkBoqXEIpos1aPe8HcBFeelviRgmCXOX6JgFexxtIponYycMMuRc4g34gFUbIPMeR9LEGklWdwWLEGpleswPEd(SehrpKgOVIL9kX11KVIxM2y)14J43Agc(CQOpx6AsDnrqA8bnzqkoGpE)vS8Y94EflmeN8vS8(zdKFT3FLMUrBw6SYQ(Q14VTUjYQPI(CPRjDebPz1urhR)AV)kTNBiUbYRqfv2F1LEGkl4x)R9(RwciKSs9ML(V27VIfFflKPs9VIfgIt(kp5cfmVkkRcMxfht)QlMpbLxPhsGiDn5Rq7taokVsxP9sOxrj1nKVss6R8t0eGwUw2CG9xTqt508QffN)QkIwC9RAnWRwI6l8Qr5vdYRiGBIriPsxtAS)AV)kw8vSqMk1)Ql(eHS9JVQmVkN(veWnXiKuGUe(vxmG)kDLVrZRwuC(R2WRiGBIriPa9vssFvRbELrqGgLxniV6Ib8xPR8nAELtYC6xTHxrHgCnqF1gLxju6Kg7V(x79xPR1iPEWS0)1E)vS4Ry5OuG(kD9Kg)i8QlUOVC2FT3Ffl(kDfeNBG(Qwi6HouiVYPbCR(kKH8kTHiykZRKDXRgf7V27VIfFLUcIZnqFvCUHiK9RKDXRUaZRqit8vOj1qQgLxTqdKVkN(v(gG(kKH8Ql(eHS9J2FT3Ffl(kwokfOVIfYaVAjUHO5v98kiPVAqELUEgoDwKMxjUUMKxM2(R9(RyXxPRN8ginqF1s2ndNolYL8R65vlzX11K2LGw3mC6SixYVAHgGaVsqJMxozZb7V(x79xTe5IaNFd0xTbKHaVYnXT0VAd6R0yFflNZbOBZRYjzrncjI4ZFL46AsZRMKJI9x79xjUUM0yrta3e3sZeHlMv)1E)vIRRjnw0eWnXT0EXKvXxFeYw6AYFT3FL46AsJfnbCtClTxmzfzg6V27V6KcAJMPFfrk6R2(iia9vMwAZR2aYqGx5M4w6xTb9vAELK0xHMaSi6P7k1)QY8k6KG9x79xjUUM0yrta3e3s7ftwnPG2Oz6GPL28RfxxtASOjGBIBP9IjR(giunezpLiWuyjJgHiMaYKDyqcONfa5xlUUM0yrta3e3s7ftwrpDn5VwCDnPXIMaUjUL2lMSgHwIdbTMXug2leMAjSeqQgSonY0Ll0ejnidjkDnPfszZb6V(x79xTe5IaNFd0xb3abLx1veEvRbEL46H8QY8k5wkUS5G9xlUUM04ftwVfsjBoWEkrG5MluiqL0bSFlCFGzlCiBlsrmDyZNHAHu2CGYGHbnW5Hwi6H2y3CHcbQKoav2yU8fyXw4q22MifpmibIFLwiLnhOR8RfxxtA8IjR3cPKnhypLiWCHuDL6didjKqemLH9BH7dm1AzTAHdzBticMYyHu2CGYGHBgoDwK2eIGPmwciuuyWWndNolsBcrWuglbIsLg2AHOhABxri0tGwadgUz40zrAticMYyjquQ0WMU4Xk)AX11KgVyY6TqkzZb2tjcmrpdVs9bKHeIqlSFlCFGPwTWHSTuioz5SqkBoqV6MHtNfPncTehcAnJPmwceLkn6wxUI4tqXsbKYvnBxWJRlR1TqkzZb7cP6k1hqgsiHiykddgUz40zrAticMYyjquQ0OBu9yLFT46AsJxmz9wiLS5a7PebMONHxP(aYqcBUqHavshW(TW9bM3cPKnhSBUqHavshCDzeFck6ML5nwSfoKTfPiMoS5ZqTqkBoqxsx6Xk)AX11KgVyY6TqkzZb2tjcmrpdVs9bKHeauGWgKi73c3hy2chY2sH4KLZcPS5a9QwTWHSTBEL0aIpbflKYMd0RUz40zrAbuGWgKOLarPsJUxwVJAJYfTKUCLRi(euSuaPCvZ2LE8RfxxtA8IjR3cPKnhypLiWCHuDL6didjqfYQbdxmAy)w4(aZw4q2wQqwny4IrJfszZb6vTUfsjBoyrpdVs9bKHe2CHcbQKo4Qw3cPKnhSONHxP(aYqcrOLRUz40zrAPcz1GHlgnwF0)AX11KgVyY6TqkzZb2tjcmxivxP(aYqcXjcz7hz)w4(aZw4q224eHS9JwiLnhOx1A7JGyJteY2pA9r)RfxxtA8IjR0Yq8r3)AX11KgVyYQBsJFecrrF5(1IRRjnEXKvNW5bX11KbEzA2tjcmDZWPZIK9cHPEh1sGOuPHPh)AV)kX11KgVyYk6YTAWhDaHi6Jq2Sximr8jOyPas5QMnMxWBxxwlHLas1GfqbmHbjqe9GfszZbkdgUz40zrAbuGWgKOLarPsdBOAxQv(1IRRjnEXKvNW5bX11KbEzA2tjcmPcz1GHlgnSximBHdzBPcz1GHlgnwiLnhOxx(wiLS5GDHuDL6didjqfYQbdxmAyWGcBFeelviRgmCXOX6JELFT46AsJxmzL4NbX11KbEzA2tjcmPqCYYXEHWSfoKTLcXjlNfszZb6VwCDnPXlMSs8ZG46AYaVmn7PebM5qIc)x)RfxxtASUz40zrYmcTehcAnJPmSxim1A5w4q2wkeNSCwiLnhOmyClKs2CWIEgEL6didjeHwyW4wiLS5GDHuDL6didjKqemLzfgm6kcHEc0c09LE7xlUUM0yDZWPZI0lMSgHwIdbTMXug2leMTWHSTuioz5SqkBoqVUSwclbKQbRtJmD5cnrsdYqIsxtAHu2CGYGXYUz40zrAbuGWgKOLarPsdBx6X1L16wiLS5GDZfkeOs6agmCZWPZI0U5cfcujDGLarPsdB6DuBuUOvwzLFT46AsJ1ndNolsVyYAcrWug2leMePOb4gY2kuQXcxuzAZvkS9rqSjebtzS0zrEDzX11neGeIfyyJcMIa0qle9qByWGifna3q2wHsn2kztx8yLFT46AsJ1ndNolsVyYAcrWug2leMArKIgGBiBRqPglCrLPn)AX11KgRBgoDwKEXKv0txtYEHWC7JGyJqlXHGwZykJLarPsdBx6ngm6kcHEc0c0TU4XVwCDnPX6MHtNfPxmz13aHQHi7PebM6fo4eohiMWEMK9cHPwTWHSTiapSfcr0dwiLnhOmy4MHtNfPfb4HTqiIEWsaHIYVwCDnPX6MHtNfPxmz13aHQHi7acc46qkrGPdfhFAYKLlS5IPzVqyU9rqSrOL4qqRzmLX6J(62hbXgH4qqjmibUVRObkbKOXsNf51L16wiLS5GDZfkeOs6agm0YndNols7MluiqL0bwciuuw5xlUUM0yDZWPZI0lMS6BGq1qK9uIatXO5wsWeiclnKGBicN9cHjf2(iiwIWsdj4gIWduy7JGyPZIKbJLPW2hbX6MK6766gcvUAGcBFeeRpAgm2(ii2i0sCiO1mMYyjquQ0W2LESY1wi6H2QbeERXI216(cOYGrxri0tGwGUV0JFT46AsJ1ndNolsVyYQVbcvdr2tjcmfwYOriIjGmzhgKa6zbqyVqy6MHtNfPncTehcAnJPmwceLkn6gvpyWWndNolsBeAjoe0AgtzSeikvAytx84x79xXcdiIpVFfIW5BXT6RqgYR8nYMdVQAiAS)AX11KgRBgoDwKEXKvFdeQgIg2leMBFeeBeAjoe0AgtzS(O)1IRRjnw3mC6Si9IjRoHZdIRRjd8Y0SNseycgdKoW8R)1IRRjnwQqwny4IrdtQqwny4Ird7fcteFckSXCP5X1L16wiLS5GDZfkeOs6agm0YndNols7MluiqL0bwciuuw5xlUUM0yPcz1GHlgnEXKvjZstXLUMK9cHjf2(iiwQqwny4IrJ1h9VwCDnPXsfYQbdxmA8IjRonYycMMuRcSximPW2hbXsfYQbdxmAS(O)1)AX11KglfItwoMuqAnbZcaqZEHW8wiLS5GDZfkeOs6GFT46AsJLcXjlNxmzfqbcBqISximjsrdWnKTvOuJ1hndgePOb4gY2kuQXwjBx6TFT46AsJLcXjlNxmzfb4HTqiIEG9cH5YlRLBgoDwKwafiSbjA9rZGX2hbXgHwIdbTMXugRp6vUsKIgGBiBRqPgBLSDbpwHbdX11neGeIfyyJcMIa0qle9qB(1IRRjnwkeNSCEXK1nxOqGkPdyVqyElKs2CWU5cfcujDWvTCZWPZI0gHwIdbTMXuglbekkxx2ndNolslGce2GeTeikvAyBzVXIclbKQblbUh(DL6dBUqbJLi5QlPlScdgltKIgGBiBRqPgBLSjUUM0U5cfcujDG1ndNolYRePOb4gY2kuQXwPUV0BRSYVwCDnPXsH4KLZlMSwX4WLUMmi(e5xlUUM0yPqCYY5ftwLmlnfx6As2leMADlKs2CWIEgEL6didjS5cfcujDWVwCDnPXsH4KLZlMSIa8nxOa7fcteFckwkGuUQzJ5s5XVwCDnPXsH4KLZlMS60iJjyAsTkWEHWuRBHuYMdw0ZWRuFaziHnxOqGkPdUQ1TqkzZbl6z4vQpGmKaGce2Ge)1IRRjnwkeNSCEXKveGhi(gnSximBHdzBPqCYWMluWyHu2CGEvl3mC6SiTakqyds0saHIY1LDAeIEWW8sgmwMifna3q224CdriBBLSHQhxjsrdWnKTvOuJTs2q1Jvw5xlUUM0yPqCYY5ftwPqCstyxn8RfxxtASuioz58IjRTgYSiONl1nWEHWC7JGyh)omibIK6bRp6FT46AsJLcXjlNxmzfb4bIVrd7fcZ4CdriBlTmTKoGnu9gdgBFee743HbjqKupy9r)RfxxtASuioz58IjR3qQhq85bc0eqA2leMX5gIq2wAzAjDaBO6TFT46AsJLcXjlNxmzT1qMfb9CPUb2leMTWHSTuiozyZfkySqkBoq)1)AX11Kglymq6adt3KoiBI0anGWLiWEHWCzTOtBDt6GSjsd0acxIqy7tsBxUvRu)vTexxtADt6GSjsd0acxIGTYacV0RPzWaXNZdeWPri6Hqxrq36DuBuUOv(1IRRjnwWyG0bgVyY6MpdnmiHwdeGeIOWEHWC7JGyJqlXHGwZykJ1hndgDfHqpbAb6MjQE8RfxxtASGXaPdmEXKv9(cHwsggKGWsazAnSximxE7JGyJqlXHGwZykJ1h9v3mC6SiTrOL4qqRzmLXsaHIYkmyS9rqSrOL4qqRzmLXsGOuPHTl9gdgTq0dTTRie6jqlq3mVGh)AX11Kglymq6aJxmzfzC(gGgewcivdHnir2leMg0aNhAHOhAJDZfkeOs6auzJ5LmyqKIgGBiBRqPgBLSPlE8RfxxtASGXaPdmEXKv0(KcbLk1h2CX0SximnObop0crp0g7MluiqL0bOYgZlzWGifna3q2wHsn2kztx84xlUUM0ybJbshy8IjRTgi4N7XpPbKH4a2leMBFeelbCRYbJjGmehy9rZGX2hbXsa3QCWycidXbb34NnqSMwCRQBu94xlUUM0ybJbshy8IjRKcnAoeQmyqlo4xlUUM0ybJbshy8IjRlgcNEdvgiGzsjDa7fcZTpcILxiWMpd1AAXTQUVWVwCDnPXcgdKoW4ftwJqCiOegKa33v0aLas0WEHWeXNGIUxkpUU9rqSrOL4qqRzmLX6J(x)RfxxtAS5qIcN5nK6beFEGanbKM9cHzlCiBBCIq2(rlKYMd0RBFeelAcGwia1sNf51UIaBO(RfxxtAS5qIc3lMSIa8aX3OH9cH5Y3cPKnhSlKQRuFaziH4eHS9Jmy0chY2Ia8qumnqqXcPS5aDLRl70ie9GH5LmySmrkAaUHSTX5gIq22kzdvpUsKIgGBiBRqPgBLSHQhRSYVwCDnPXMdjkCVyYkcWdBHqe9a7fctTUfsjBoyxivxP(aYqcXjcz7hVUS466gcqcXcmSrbtraAOfIEOnmyqKIgGBiBRqPgBLSDbpw5xlUUM0yZHefUxmzLcsRjywaaA2leM3cPKnhSBUqHavsh8RfxxtAS5qIc3lMSwX4WLUMmi(e5xlUUM0yZHefUxmzfqbcBqISximfxx3qasiwGHnuVUSwePOb4gY2kuQXcxuzAddgePOb4gY2kuQX6JELRADlKs2CWUqQUs9bKHeIteY2p(RfxxtAS5qIc3lMSU5cfcujDa7fcZBHuYMd2nxOqGkPd(1IRRjn2CirH7ftwra(MluG9cHjIpbflfqkx1SXCP84xlUUM0yZHefUxmzfqbcBqISxim1QfoKTDZRKgq8jOyHu2CGEvRBHuYMd2fs1vQpGmKaviRgmCXO5krkAaUHSTcLASvYM46AslGce2GeTUz40zr(RfxxtAS5qIc3lMSkzwAkU01KSximxUfoKTLcXjdBUqbJfszZbkdgADlKs2CWUqQUs9bKHeIteY2pYGbIpbflfqkx16(cEWGX2hbXgHwIdbTMXuglbIsLgD7TvUQ1TqkzZbl6z4vQpGmKWMluiqL0bx16wiLS5GDHuDL6didjqfYQbdxmA(1IRRjn2CirH7ftwDAKXemnPwfyVqyUClCiBlfItg2CHcglKYMdugm06wiLS5GDHuDL6didjeNiKTFKbdeFckwkGuUQ19f8yLRADlKs2CWIEgEL6didjeHwUQ1TqkzZbl6z4vQpGmKWMluiqL0bx16wiLS5GDHuDL6didjqfYQbdxmA(1IRRjn2CirH7ftwbuGWgKi7fcZw4q22nVsAaXNGIfszZb6vIu0aCdzBfk1yRKnX11KwafiSbjADZWPZI8xlUUM0yZHefUxmzLcXjnHD1WVwCDnPXMdjkCVyYkcWdeFJg2leMA1chY2gNiKTF0cPS5a9krkAaUHSTX5gIq22kzZPri6bZscvpU2chY2sH4KHnxOGXcPS5a9xlUUM0yZHefUxmzfb4BUqb2leMX5gIq2wAzAjDaBO6ngm2(ii2XVddsGiPEW6J(xlUUM0yZHefUxmzfb4bIVrd7fcZ4CdriBlTmTKoGnu9gdglV9rqSJFhgKars9G1h9vTAHdzBJteY2pAHu2CGUYVwCDnPXMdjkCVyY6nK6beFEGanbKM9cHzCUHiKTLwMwshWgQE7xlUUM0yZHefUxmzT1qMfb9CPUb2leMTWHSTuiozyZfkySqkBoqXnUXya]] )


end
