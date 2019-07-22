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

        potion = "potion_of_focused_resolve",

        package = "Havoc",
    } )


    spec:RegisterSetting( "recommend_movement", false, {
        name = "Recommend |T1247261:0|t Fel Rush / |T1348401:0|t Vengeful Retreat",
        desc = "If checked, the addon will recommend |T1247261:0|t Fel Rush / |T1348401:0|t Vengeful Retreat when it is a potential DPS gain.\n\n" ..
            "These abilities are critical for DPS when using the Momentum talent.\n\n" ..
            "If not using Momentum, you may want to leave this disabled to avoid unnecessary movement in combat.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Havoc", 201907022.0000, [[dOeKcbqisklsbu8ivISjvsJsb1PuqwLcaVIkYSqP6wOGAxu6xqOHHICmuultLWZOIY0ua6AKu12qb8nfqgNcGoNkrzDurvEhvurnpsQCpiAFOuoOcOQfsI6HOavtKkQKlsfvKnIceFubuYirbsNubuzLku3KkQu7KezPurv9uvmvuORIcu(kvubJvbuQ9QQ)kYGP4WelwrpMQMmIld2mK(mjz0uHtl51kqZgv3wu7w43knCuYXPIk0Yr65KA6sDDQ02vP(Ucz8QevNhcwpkiZNe2pu)m)m(hI0WR0fmX8LX0aDXfwMy6Ilt9o7pncSG)Ws8dkQG)esg(ddQCV()WsqGVc5z8p61L6H)4OBwANhIiQQAhUtRFZiQRSlx6AdpvqBe1v2J4FMUfVh4IF(hI0WR0fmX8LX0aDXfwMy6IlBaV4pAwG)vs9d0a9hhfHaXp)db0()CjSHbvUxp24Cb5nWggu3ObkE8LWghDZs78qervv7WDA9BgrDLD5sxB4PcAJOUYEeXJVe2m2LJa2CbZSJnxWeZxg2WWyZfm58CgdGhJhFjSX5GqJkuPDE4XxcByySHbtxHkSX5cYBGnkZfcOXMSmiOXM8QBSHbXLIa2OccGkDTb2WYLcCeWgNVsdSWgcTUHaBKGGnUblkqkFltoWo2mYr5DGnJkohBQmlX3yt7aWgNJUcVAeWMffBOGFZziisxBOT4XxcByySHbtxHkSX5EZq0UzSP0ytSn2qb)MZqqaIZzSHbb4yJZ3v7aBgvCo2mbSHc(nNHGaeSrcc20oaSrlOqJa2SOyddcWXgNVR2b24Li2gBMa2qGg8nqWMjcyJqiBOT)Hx6w)m(NyPzH)m(kX8Z4FGqMCG8k)hpTAGwYFAHdrBZBgI2nBHqMCGGnxXMPlkQLffyjuGyj7OaBUInDLbSHnSH5)i(U24p3qOcqD5jk0uq6VFLU4z8pqitoqEL)JNwnql5pdJn3cTKjhSJKQRqvcDPP8MHODZyJcfytlCiAlkWtzr3afbleYKdeSziS5k2mm24DiuvGgBqInxGnkuGndJnuPij4gI2M3BidrBRaBydByMjS5k2qLIKGBiARqiABfydBydZmHndHnd9hX31g)bf4jQR2X3Vso7z8pqitoqEL)JNwnql5pQHn3cTKjhSJKQRqvcDPP8MHODZyZvSzySr8DDdjiGCbASHnSHa6IcKuluvqRXgfkWgQuKeCdrBfcrBRaBydBCgtyZq)r8DTXFqbEAkuQOc((vAaFg)deYKdKx5)4Pvd0s(ZTqlzYb7KleirKWd)r8DTXFiG0os6raW67xj1)m(hX31g)PY5LlDTrsCPYFGqMCG8k)9Red8m(hiKjhiVY)XtRgOL8hX31nKGaYfOXg2WgMXMRyZWyJAydvkscUHOTcHOTWLx6wJnkuGnuPij4gI2keI26YcBgcBUInQHn3cTKjhSJKQRqvcDPP8MHODZ)r8DTXFaeG0eK83Vsd0Z4FGqMCG8k)hpTAGwYFUfAjtoyNCHajIeE4pIVRn(ZKleirKWdF)knaFg)deYKdKx5)4Pvd0s(dQlfblbqlF1ydBiXMbKP)i(U24pOaFYfc89R0L9m(hiKjhiVY)XtRgOL8h1WMw4q02jVcsc1LIGfczYbc2CfBudBUfAjtoyhjvxHQe6steHoysZfTdS5k2qLIKGBiARqiABfydByJ47AdlGaKMGKT(D5KDu8hX31g)bqastqYF)kXmtpJ)bczYbYR8F80QbAj)zySPfoeTLa5nstUqaTfczYbc2Oqb2Og2Cl0sMCWosQUcvj0LMYBgI2nJnkuGnOUueSeaT8vJnQdBCgtyJcfyZ0ff1MHwYlLLJvxAlfYsfASrDyJ6XMHWMRyJAyZTqlzYblRD5vOkHU00KleirKWdyZvSrnS5wOLm5GDKuDfQsOlnre6Gjnx0o(J47AJ)iruokU01gF)kXmZpJ)bczYbYR8F80QbAj)zySPfoeTLa5nstUqaTfczYbc2Oqb2Og2Cl0sMCWosQUcvj0LMYBgI2nJnkuGnOUueSeaT8vJnQdBCgtyZqyZvSrnS5wOLm5GL1U8kuLqxAkdTGnxXg1WMBHwYKdww7YRqvcDPPjxiqIiHhWMRyJAyZTqlzYb7iP6kuLqxAIi0btAUOD8hX31g)X7qwDs30Aq47xjMV4z8pqitoqEL)JNwnql5pTWHOTtEfKeQlfbleYKdeS5k2qLIKGBiARqiABfydByJ47AdlGaKMGKT(D5KDu8hX31g)bqastqYF)kXSZEg)J47AJ)qG8g60SA4pqitoqEL)(vI5b8z8pqitoqEL)JNwnql5pQHnTWHOT5ndr7MTqitoqWMRydvkscUHOT59gYq02kWg2WgVdHQc0yZaaByMjS5k20chI2sG8gPjxiG2cHm5a5pIVRn(dkWtuxTJVFLyw9pJ)bczYbYR8F80QbAj)jV3qgI2skDlHhWg2WgMvp2Oqb2mDrrTRBNw0evcvG1L1FeFxB8huGp5cb((vIzg4z8pqitoqEL)JNwnql5p59gYq0wsPBj8a2Wg2WS6XgfkWMHXMPlkQDD70IMOsOcSUSWMRyJAytlCiABEZq0UzleYKdeSzO)i(U24pOaprD1o((vI5b6z8pqitoqEL)JNwnql5p59gYq0wsPBj8a2Wg2WS6)J47AJ)CdHka1LNOqtbP)(vI5b4Z4FGqMCG8k)hpTAGwYFAHdrBjqEJ0KleqBHqMCG8hX31g)PDq3rjvCPUHV)(pGwdHh0pJVsm)m(hX31g)XVHhIMknqsOCjd)bczYbYR83Vsx8m(hiKjhiVY)XtRgOL8NPlkQndTKxklhRU0wxwyJcfytxzi1BIua2OoKydZm9hX31g)zY3LKw0u7asqaze((vYzpJ)r8DTXFu5kusjrArtcdb0TD8hiKjhiVYF)knGpJ)bczYbYR8F80QbAj)z6IIAZql5LYYXQlT1Lf2Oqb20cvf02UYqQ3ePaSrDiXgNX0FeFxB8hvUcLusKw0KWqaDBhF)kP(NX)aHm5a5v(pEA1aTK)OzbCEQfQkO12jxiqIiHhygBydj2Cb2Oqb2qLIKGBiARqiABfydByddW0FeFxB8h017QbssyiGwnKMGK)(vIbEg)deYKdKx5)4Pvd0s(JMfW5PwOQGwBNCHajIeEGzSHnKyZfyJcfydvkscUHOTcHOTvGnSHnmat)r8DTXFy5slueQqvAYfD)9R0a9m(hiKjhiVY)XtRgOL8NPlkQLc(b5GwNqxQhSUSWgfkWMPlkQLc(b5GwNqxQhs(1nAGA1T4heBuh2Wmt)r8DTXFAhqYnMRBqsOl1dF)knaFg)J47AJ)qlwS4qQIKML4H)aHm5a5v(7xPl7z8pqitoqEL)JNwnql5ptxuulVqHjFxIv3IFqSrDyJZ(J47AJ)mAPCYnurIc6nKWdF)kXmtpJ)bczYbYR8F80QbAj)b1LIa2OoSzazcBUIntxuuBgAjVuwowDPTUS(J47AJ)KH8sriTOjURVijcfKS(7V)dbqfxE)m(kX8Z4FGqMCG8k)NL1F0q)hX31g)5wOLm5WFUfUl8Nw4q0w0IQ70KVlXcHm5abBuOaB0Saop1cvf0A7KleirKWdmJnSHeBggBCg2WWytlCiABtLINw0e1TcleYKdeSzO)Cl0uiz4ptUqGercp89R0fpJ)bczYbYR8Fww)rd9FeFxB8NBHwYKd)5w4UWFudBggBudBAHdrBdid6sBHqMCGGnkuGn(D5KDuydid6sBPGqqaBuOaB87Yj7OWgqg0L2sHSuHgBydBAHQcABxzi1BIua2Oqb243Lt2rHnGmOlTLczPcn2Wg2WamHnd9NBHMcjd)zKuDfQsOlnfqg0L(7xjN9m(hiKjhiVY)zz9hn0)r8DTXFUfAjto8NBH7c)rnSPfoeTLa5nkVfczYbc2CfB87Yj7OWMHwYlLLJvxAlfYsfASrDyddGnxXguxkcwcGw(QXg2WgNXe2CfBggBudBUfAjtoyhjvxHQe6stbKbDPXgfkWg)UCYokSbKbDPTuilvOXg1HnmZe2m0FUfAkKm8hw7YRqvcDPPm0Y3Vsd4Z4FGqMCG8k)NL1F0q)hX31g)5wOLm5WFUfUl8NBHwYKd2jxiqIiHhWMRyZWydQlfbSrDyZaPESHHXMw4q0w0IQ70KVlXcHm5abBgayZfmHnd9NBHMcjd)H1U8kuLqxAAYfcKis4HVFLu)Z4FGqMCG8k)NL1F0q)hX31g)5wOLm5WFUfUl8Nw4q0wcK3O8wiKjhiyZvSrnSPfoeTDYRGKqDPiyHqMCGGnxXg)UCYokSacqAcs2sHSuHgBuh2mm2OYtSz5YXMba2Cb2me2CfBqDPiyjaA5RgBydBUGP)Cl0uiz4pS2LxHQe6stacqAcs(7xjg4z8pqitoqEL)ZY6pAO)J47AJ)Cl0sMC4p3c3f(tlCiAlrOdM0Cr7WcHm5abBUInQHn3cTKjhSS2LxHQe6sttUqGercpGnxXg1WMBHwYKdww7YRqvcDPPm0c2CfB87Yj7OWse6Gjnx0oSUS(ZTqtHKH)msQUcvj0LMicDWKMlAhF)knqpJ)bczYbYR8Fww)rd9FeFxB8NBHwYKd)5w4UWFAHdrBZBgI2nBHqMCGGnxXg1WMPlkQnVziA3S1L1FUfAkKm8Nrs1vOkHU0uEZq0U5VFLgGpJ)r8DTXFiLM6YQ)deYKdKx5VFLUSNX)i(U24p(n0UziLfvL)pqitoqEL)(vIzMEg)deYKdKx5)4Pvd0s(JkpXsHSuHgBqInm9hX31g)XlCEs8DTrIx6(p8s3PqYWF87Yj7O47xjMz(z8pqitoqEL)JNwnql5pTWHOTeHoysZfTdleYKdeS5k2mm2Cl0sMCWosQUcvj0LMicDWKMlAhyJcfydbMUOOwIqhmP5I2H1Lf2m0FeFxB8hVW5jX31gjEP7)WlDNcjd)Hi0btAUOD89ReZx8m(hiKjhiVY)XtRgOL8Nw4q0wcK3O8wiKjhi)r8DTXFOUrs8DTrIx6(p8s3PqYWFiqEJY)9ReZo7z8pqitoqEL)J47AJ)qDJK47AJeV09F4LUtHKH)elnl8V)(pSOGFZtPFgFLy(z8pIVRn(dRTRn(deYKdKx5VFLU4z8pqitoqEL)JNwnql5pQHncdb0QbR3HSD5tnvcn6sZsxByHqMCG8hX31g)jdTKxklhRU0F)9FiqEJY)m(kX8Z4FGqMCG8k)hpTAGwYFUfAjtoyNCHajIeE4pIVRn(dbK2rspcawF)kDXZ4FGqMCG8k)hpTAGwYFOsrsWneTvieT1Lf2Oqb2qLIKGBiARqiABfydByZfQ)pIVRn(dGaKMGK)(vYzpJ)bczYbYR8F80QbAj)zySzySrnSXVlNSJclGaKMGKTUSWgfkWMPlkQndTKxklhRU0wxwyZqyZvSHkfjb3q0wHq02kWg2WgNXe2me2Oqb2i(UUHeeqUan2Wg2qaDrbsQfQkO1)r8DTXFqbEAkuQOc((vAaFg)deYKdKx5)4Pvd0s(ZTqlzYb7KleirKWdyZvSrnSXVlNSJcBgAjVuwowDPTuqiiGnxXMHXg)UCYokSacqAcs2sHSuHgBydBggBup2WWyJWqaTAWsH7LFxHQ0KleqBPsmi2maWgNHndHnkuGndJnuPij4gI2keI2wb2Wg2i(U2Wo5cbsej8G1VlNSJcS5k2qLIKGBiARqiABfyJ6WMlup2me2m0FeFxB8NjxiqIiHh((vs9pJ)r8DTXFQCE5sxBKexQ8hiKjhiVYF)kXapJ)bczYbYR8F80QbAj)rnS5wOLm5GL1U8kuLqxAAYfcKis4H)i(U24pseLJIlDTX3Vsd0Z4FGqMCG8k)hpTAGwYFqDPiyjaA5RgBydj2mGm9hX31g)bf4tUqGVFLgGpJ)bczYbYR8F80QbAj)rnS5wOLm5GL1U8kuLqxAAYfcKis4bS5k2Og2Cl0sMCWYAxEfQsOlnbiaPji5)i(U24pEhYQt6MwdcF)kDzpJ)bczYbYR8F80QbAj)PfoeTLa5nstUqaTfczYbc2CfBudB87Yj7OWciaPjizlfeccyZvSzySX7qOQan2GeBUaBuOaBggBOsrsWneTnV3qgI2wb2Wg2WmtyZvSHkfjb3q0wHq02kWg2WgMzcBgcBg6pIVRn(dkWtuxTJVFLyMPNX)i(U24peiVHonRg(deYKdKx5VFLyM5NX)aHm5a5v(pEA1aTK)mDrrTRBNw0evcvG1L1FeFxB8N2bDhLuXL6g((vI5lEg)deYKdKx5)4Pvd0s(tEVHmeTLu6wcpGnSHnmRESrHcSz6IIAx3oTOjQeQaRlR)i(U24pOaprD1o((vIzN9m(hiKjhiVY)XtRgOL8N8EdziAlP0TeEaBydByw9)r8DTXFUHqfG6YtuOPG0F)kX8a(m(hiKjhiVY)XtRgOL8Nw4q0wcK3in5cb0wiKjhi)r8DTXFAh0DusfxQB47V)JFxozhfpJVsm)m(hiKjhiVY)XtRgOL8h1WMHXMw4q0wcK3O8wiKjhiyJcfyZTqlzYblRD5vOkHU0ugAbBuOaBUfAjtoyhjvxHQe6stbKbDPXMHWgfkWMUYqQ3ePaSrDyZfQ)pIVRn(tgAjVuwowDP)(v6INX)aHm5a5v(pEA1aTK)0chI2sG8gL3cHm5abBUIndJnQHncdb0QbR3HSD5tnvcn6sZsxByHqMCGGnkuGndJn(D5KDuybeG0eKSLczPcn2Wg2CbtyZvSXVlNSJc7KleirKWdwkKLk0ydByJkpXMLlhBgcBg6pIVRn(tgAjVuwowDP)(vYzpJ)bczYbYR8F80QbAj)Hkfjb3q0wHq0w4YlDRXMRydbMUOO2aYGU0wYokWMRyZWyJ476gsqa5c0ydBydb0ffiPwOQGwJnkuGnuPij4gI2keI2wb2Wg2WamHnd9hX31g)jGmOl93Vsd4Z4FGqMCG8k)hpTAGwYFudBOsrsWneTvieTfU8s36)i(U24pbKbDP)(vs9pJ)bczYbYR8F80QbAj)z6IIAZql5LYYXQlTLczPcn2Wg2CH6XgfkWMwOQG22vgs9MifGnQdByaM(J47AJ)WA7AJVFLyGNX)aHm5a5v(pIVRn(JkHdEHZbQon3n(JgHW)huGNMcLkQG)esg(JkHdEHZbQon3n((vAGEg)deYKdKx5)i(U24pQeo4fohO60C34pEA1aTK)Og20chI2Ic80uOurfyHqMCG8NqYWFujCWlCoq1P5UX3VsdWNX)aHm5a5v(pIVRn(dR1pi06IHasYVzwUT01gjcCxE4pEA1aTK)mDrrTzOL8sz5y1L2s2rb2CfBMUOO2mKxkcPfnXD9fjrOGK1wYokWMRyZWyJAytlCiAlbYBKMCHaAleYKdeSrHcSb1LIa2OoSHbycBg6pHKH)WA9dcTUyiGK8BMLBlDTrIa3Lh((v6YEg)deYKdKx5)i(U24pI2XTeGorfgAPj)sf(F80QbAj)HatxuulvyOLM8lv4jcmDrrTKDuGnkuGndJney6IIA9BqC9DDdPkgmrGPlkQ1Lf2Oqb2mDrrTzOL8sz5y1L2sHSuHgBydBUGjSziS5k20cvf0whGWBhww(gBuh24mMXgfkWMUYqQ3ePaSrDyZfm9NqYWFeTJBjaDIkm0st(Lk8VFLyMPNX)i(U24pUAivnK1)bczYbYR83VsmZ8Z4FGqMCG8k)hX31g)XlCEs8DTrIx6(p8s3PqYWFaTgcpO)(7)qe6Gjnx0oEgFLy(z8pqitoqEL)JNwnql5pOUueWg2qIndqMWMRyZWyJAyZTqlzYb7KleirKWdyJcfyJAyJFxozhf2jxiqIiHhSuqiiGnd9hX31g)Hi0btAUOD89R0fpJ)bczYbYR8F80QbAj)HatxuulrOdM0Cr7W6Y6pIVRn(Jer5O4sxB89RKZEg)deYKdKx5)4Pvd0s(dbMUOOwIqhmP5I2H1L1FeFxB8hVdz1jDtRbHV)(7)CduDTXR0fmX8LX0aX0fmzz(Yyw9)zKqJkuP)ZaxM1sBGGnde2i(U2aB4LU1w84)iUTJL(NtLD5sxBWGtf0(pSOlAXH)CjSHbvUxp24Cb5nWggu3ObkE8LWghDZs78qervv7WDA9BgrDLD5sxB4PcAJOUYEeXJVe2m2LJa2CbZSJnxWeZxg2WWyZfm58CgdGhJhFjSX5GqJkuPDE4XxcByySHbtxHkSX5cYBGnkZfcOXMSmiOXM8QBSHbXLIa2OccGkDTb2WYLcCeWgNVsdSWgcTUHaBKGGnUblkqkFltoWo2mYr5DGnJkohBQmlX3yt7aWgNJUcVAeWMffBOGFZziisxBOT4XxcByySHbtxHkSX5EZq0UzSP0ytSn2qb)MZqqaIZzSHbb4yJZ3v7aBgvCo2mbSHc(nNHGaeSrcc20oaSrlOqJa2SOyddcWXgNVR2b24Li2gBMa2qGg8nqWMjcyJqiBOT4X4XxcByWDiHkq78WJVe2WWyZapHaeSHbFdTBgWgNBrv5T4XxcByySX5d59giytluvqNkuSX7a8dInOlfBucYGU0yJmlE1iyXJVe2WWyJZhY7nqWM8EdziASrMfV6c0ydkDZydlAT0QraBg5acSj2gBC1abBqxk24CVziA3Sfp(syddJnd8ecqWggmnGndCnK1ytVydeeSzrXgg8D5KDuOXgX31g8s3w84lHnmm2WGVXnqBGGndm(D5KDumWGn9IndmIVRnSdST(D5KDumWGnJCauaBewS4LxMCWIhJhFjSX50LdE3giyZeqxkGn(npLgBMGQk0wSzG37bwTgBInyyhcnJ6YXgX31gASzdocw84lHnIVRn0wwuWV5P0ir5IEq84lHnIVRn0wwuWV5P0oHerXvvgIw6Ad84lHnIVRn0wwuWV5P0oHer0Dj4XxcBoHWs7yBSHkfbBMUOOabB0T0ASzcOlfWg)MNsJntqvfASrcc2WIcmmRT7kuHnLgBiBaw84lHnIVRn0wwuWV5P0oHerDiS0o2oPBP14XIVRn0wwuWV5P0oHerwBxBGhl(U2qBzrb)MNs7eseZql5LYYXQln7fks1egcOvdwVdz7YNAQeA0LMLU2WcHm5abpgp(syJZPlh8UnqWg4gOiGnDLbSPDayJ47LInLgBKBP4YKdw8yX31gANqI4TqlzYb2djdiNCHajIeEG9BH7ciBHdrBrlQUtt(UeleYKdefk0Saop1cvf0A7KleirKWdmZgYHDgd3chI22uP4PfnrDRWcHm5azi8yX31gANqI4TqlzYb2djdihjvxHQe6stbKbDPz)w4Uas1gwTw4q02aYGU0wiKjhiku43Lt2rHnGmOlTLccbbfk87Yj7OWgqg0L2sHSuHMTwOQG22vgs9MifOqHFxozhf2aYGU0wkKLk0SXamneES47AdTtir8wOLm5a7HKbKS2LxHQe6stzOf2VfUlGuTw4q0wcK3O8wiKjhix97Yj7OWMHwYlLLJvxAlfYsfA1XaxrDPiyjaA5RMnNX01Hv7wOLm5GDKuDfQsOlnfqg0LwHc)UCYokSbKbDPTuilvOvhZmneES47AdTtir8wOLm5a7HKbKS2LxHQe6sttUqGercpW(TWDbK3cTKjhStUqGercpCDyuxkcQBGupd3chI2IwuDNM8DjwiKjhidGlyAi8yX31gANqI4TqlzYb2djdizTlVcvj0LMaeG0eKm73c3fq2chI2sG8gL3cHm5a5QATWHOTtEfKeQlfbleYKdKR(D5KDuybeG0eKSLczPcT6gwLNyZYLpaUyOROUueSeaT8vZ2fmHhl(U2q7eseVfAjtoWEiza5iP6kuLqxAIi0btAUODW(TWDbKTWHOTeHoysZfTdleYKdKRQDl0sMCWYAxEfQsOlnn5cbsej8Wv1UfAjtoyzTlVcvj0LMYqlx97Yj7OWse6Gjnx0oSUSWJfFxBODcjI3cTKjhypKmGCKuDfQsOlnL3meTBM9BH7ciBHdrBZBgI2nBHqMCGCvTPlkQnVziA3S1LfES47AdTtirKuAQlRgpw8DTH2jKi63q7MHuwuvE8yX31gANqIOx48K47AJeV0n7HKbK(D5KDuWEHIuLNyPqwQqJKj84lHnIVRn0oHerwLFWKlRekvuLHOzVqrI6srWsa0YxnBiDM6XJfFxBODcjIEHZtIVRns8s3Shsgqse6Gjnx0oyVqr2chI2se6Gjnx0oSqitoqUo8TqlzYb7iP6kuLqxAIi0btAUODOqbbMUOOwIqhmP5I2H1L1q4XIVRn0oHerQBKeFxBK4LUzpKmGKa5nkp7fkYw4q0wcK3O8wiKjhi4XIVRn0oHerQBKeFxBK4LUzpKmGmwAw44X4XIVRn0w)UCYokqMHwYlLLJvxA2luKQnClCiAlbYBuEleYKdefkUfAjtoyzTlVcvj0LMYqlkuCl0sMCWosQUcvj0LMcid6spKcfDLHuVjsbQ7c1Jhl(U2qB97Yj7OWjKiMHwYlLLJvxA2luKTWHOTeiVr5TqitoqUoSAcdb0QbR3HSD5tnvcn6sZsxByHqMCGOqXW(D5KDuybeG0eKSLczPcnBxW0v)UCYokStUqGercpyPqwQqZMkpXMLlFOHWJfFxBOT(D5KDu4esedid6sZEHIKkfjb3q0wHq0w4YlDRVsGPlkQnGmOlTLSJIRdl(UUHeeqUanBeqxuGKAHQcATcfuPij4gI2keI2wbBmatdHhl(U2qB97Yj7OWjKigqg0LM9cfPAuPij4gI2keI2cxEPBnES47AdT1VlNSJcNqIiRTRnyVqroDrrTzOL8sz5y1L2sHSuHMTluVcfTqvbTTRmK6nrkqDmat4XIVRn0w)UCYokCcjIUAivnKzpKmGuLWbVW5avNM7gSRri8irbEAkuQOcWJfFxBOT(D5KDu4eseD1qQAiZEizaPkHdEHZbQon3nyVqrQwlCiAlkWttHsfvGfczYbcES47AdT1VlNSJcNqIORgsvdz2djdizT(bHwxmeqs(nZYTLU2irG7YdSxOiNUOO2m0sEPSCS6sBj7O460ff1MH8sriTOjURVijcfKS2s2rX1HvRfoeTLa5nstUqaTfczYbIcfOUueuhdW0q4XIVRn0w)UCYokCcjIUAivnKzpKmGu0oULa0jQWqln5xQWzVqrsGPlkQLkm0st(Lk8ebMUOOwYokuOyycmDrrT(niU(UUHufdMiW0ff16YsHIPlkQndTKxklhRU0wkKLk0SDbtdDTfQkOToaH3oSS8T6CgZku0vgs9MifOUlycpw8DTH263Lt2rHtir0vdPQHSgpw8DTH263Lt2rHtir0lCEs8DTrIx6M9qYasqRHWdA8y8yX31gAlrOdM0Cr7ajrOdM0Cr7G9cfjQlfb2qoaz66WQDl0sMCWo5cbsej8GcfQ53Lt2rHDYfcKis4blfeccdHhl(U2qBjcDWKMlAhoHerjIYrXLU2G9cfjbMUOOwIqhmP5I2H1LfES47AdTLi0btAUOD4ese9oKvN0nTgeyVqrsGPlkQLi0btAUODyDzHhJhl(U2qBjqEJYJKas7iPhbal2luK3cTKjhStUqGercpGhl(U2qBjqEJY7esebeG0eKm7fksQuKeCdrBfcrBDzPqbvkscUHOTcHOTvW2fQhpw8DTH2sG8gL3jKiIc80uOurfWEHIC4HvZVlNSJclGaKMGKTUSuOy6IIAZql5LYYXQlT1L1qxPsrsWneTvieTTc2CgtdPqH476gsqa5c0SraDrbsQfQkO14XIVRn0wcK3O8oHeXjxiqIiHhyVqrEl0sMCWo5cbsej8Wv187Yj7OWMHwYlLLJvxAlfeccxh2VlNSJclGaKMGKTuilvOzBy1ZWcdb0QblfUx(DfQstUqaTLkXGdaNnKcfdtLIKGBiARqiABfSj(U2Wo5cbsej8G1VlNSJIRuPij4gI2keI2wH6Uq9dneES47AdTLa5nkVtirSY5LlDTrsCPcES47AdTLa5nkVtiruIOCuCPRnyVqrQ2TqlzYblRD5vOkHU00KleirKWd4XIVRn0wcK3O8oHeruGp5cbyVqrI6srWsa0YxnBihqMWJfFxBOTeiVr5DcjIEhYQt6MwdcSxOiv7wOLm5GL1U8kuLqxAAYfcKis4HRQDl0sMCWYAxEfQsOlnbiaPjiz8yX31gAlbYBuENqIikWtuxTd2luKTWHOTeiVrAYfcOTqitoqUQMFxozhfwabinbjBPGqq46WEhcvfOrEHcfdtLIKGBiABEVHmeTTc2yMPRuPij4gI2keI2wbBmZ0qdHhl(U2qBjqEJY7esejqEdDAwnGhl(U2qBjqEJY7eseBh0DusfxQBG9cf50ff1UUDArtujubwxw4XIVRn0wcK3O8oHeruGNOUAhSxOiZ7nKHOTKs3s4b2yw9kumDrrTRBNw0evcvG1LfES47AdTLa5nkVtir8gcvaQlprHMcsZEHImV3qgI2skDlHhyJz1Jhl(U2qBjqEJY7eseBh0DusfxQBG9cfzlCiAlbYBKMCHaAleYKde8y8yX31gAlO1q4bns)gEiAQ0ajHYLmGhl(U2qBbTgcpODcjIt(UK0IMAhqcciJa7fkYPlkQndTKxklhRU0wxwku0vgs9MifOoKmZeES47AdTf0Ai8G2jKiQYvOKsI0IMegcOB7apw8DTH2cAneEq7esev5kusjrArtcdb0TDWEHIC6IIAZql5LYYXQlT1LLcfTqvbTTRmK6nrkqDiDgt4XIVRn0wqRHWdANqIi66D1ajjmeqRgstqYSxOi1Saop1cvf0A7KleirKWdmZgYluOGkfjb3q0wHq02kyJbycpw8DTH2cAneEq7esez5slueQqvAYfDZEHIuZc48uluvqRTtUqGercpWmBiVqHcQuKeCdrBfcrBRGngGj8yX31gAlO1q4bTtirSDaj3yUUbjHUupWEHIC6IIAPGFqoO1j0L6bRllfkMUOOwk4hKdADcDPEi5x3ObQv3IFq1Xmt4XIVRn0wqRHWdANqIiTyXIdPksAwIhWJfFxBOTGwdHh0oHeXrlLtUHksuqVHeEG9cf50ff1YluyY3Ly1T4huDodpw8DTH2cAneEq7eseZqEPiKw0e31xKeHcswZEHIe1LIG6gqMUoDrrTzOL8sz5y1L26Ycpgpw8DTH2glnlCK3qOcqD5jk0uqA2luKTWHOT5ndr7MTqitoqUoDrrTSOalHcelzhfx7kdSXmES47AdTnwAw4oHeruGNOUAhSxOih(wOLm5GDKuDfQsOlnL3meTBwHIw4q0wuGNYIUbkcwiKjhidDDyVdHQc0iVqHIHPsrsWneTnV3qgI2wbBmZ0vQuKeCdrBfcrBRGnMzAOHWJfFxBOTXsZc3jKiIc80uOurfWEHIuTBHwYKd2rs1vOkHU0uEZq0U5Rdl(UUHeeqUanBeqxuGKAHQcATcfuPij4gI2keI2wbBoJPHWJfFxBOTXsZc3jKisaPDK0JaGf7fkYBHwYKd2jxiqIiHhWJfFxBOTXsZc3jKiw58YLU2ijUubpw8DTH2glnlCNqIiGaKMGKzVqrk(UUHeeqUanBmFDy1OsrsWneTvieTfU8s3AfkOsrsWneTvieT1L1qxv7wOLm5GDKuDfQsOlnL3meTBgpw8DTH2glnlCNqI4KleirKWdSxOiVfAjtoyNCHajIeEapw8DTH2glnlCNqIikWNCHaSxOirDPiyjaA5RMnKdit4XIVRn02yPzH7esebeG0eKm7fks1AHdrBN8kijuxkcwiKjhixv7wOLm5GDKuDfQsOlnre6Gjnx0oUsLIKGBiARqiABfSj(U2WciaPjizRFxozhf4XIVRn02yPzH7eseLikhfx6Ad2luKd3chI2sG8gPjxiG2cHm5arHc1UfAjtoyhjvxHQe6st5ndr7MvOa1LIGLaOLVA15mMuOy6IIAZql5LYYXQlTLczPcT6u)qxv7wOLm5GL1U8kuLqxAAYfcKis4HRQDl0sMCWosQUcvj0LMicDWKMlAh4XIVRn02yPzH7ese9oKvN0nTgeyVqroClCiAlbYBKMCHaAleYKdefku7wOLm5GDKuDfQsOlnL3meTBwHcuxkcwcGw(QvNZyAORQDl0sMCWYAxEfQsOlnLHwUQ2TqlzYblRD5vOkHU00KleirKWdxv7wOLm5GDKuDfQsOlnre6Gjnx0oWJfFxBOTXsZc3jKiciaPjiz2luKTWHOTtEfKeQlfbleYKdKRuPij4gI2keI2wbBIVRnSacqAcs263Lt2rbES47AdTnwAw4oHercK3qNMvd4XIVRn02yPzH7eserbEI6QDWEHIuTw4q028MHODZwiKjhixPsrsWneTnV3qgI2wbBEhcvfOhamZ01w4q0wcK3in5cb0wiKjhi4XIVRn02yPzH7eserb(KleG9cfzEVHmeTLu6wcpWgZQxHIPlkQDD70IMOsOcSUSWJfFxBOTXsZc3jKiIc8e1v7G9cfzEVHmeTLu6wcpWgZQxHIHNUOO21TtlAIkHkW6Y6QATWHOT5ndr7MTqitoqgcpw8DTH2glnlCNqI4neQauxEIcnfKM9cfzEVHmeTLu6wcpWgZQhpw8DTH2glnlCNqIy7GUJsQ4sDdSxOiBHdrBjqEJ0KleqBHqMCG893)d]] )


end
