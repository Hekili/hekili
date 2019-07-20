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


    spec:RegisterPack( "Havoc", 201907020.1915, [[dOecbbqisrlIkQ0JuiztQKgLcvNsHYQOIkEfPsZcLQBPsu7Is)ckzyuroguPLbf5zkKAAkeCnsH2gvu8nQOQXbfvoNcHwhPa9oOOQmpfIUhu1(ivCqOOkleLYdjfWePIs5IurjzJQerFKkkHrcffDsQOuTsf0nHIc7eQyPqrPNQIPcL6QQeHVsfLOXcfvv7vv)vKbtYHjwSIEmvnzexgSzu8zsPrtQ60sETkHzJ0Tf1Uf(TsdhLCCQOKA5O65umDPUovA7QuFxbgVkr68qH1tkO5tf2pKFCFS)drA4XbtoH7i6KZJjNS4oI4I5Wf3)0yWc(dlXFHOf(tiz4pyMY96)dlbd6kKh7)ywxUh(J(Uzz0GyHL2Q17oT(nJLPYUuPRn8CHPXYuzpw)z6w02zp(5FisdpoyYjChrNCEm5Kf3rexnIjm3FmSa)JJgDEN)p6lcbIF(hcy8)zuifMPCVEKYzdYBGuyMUrdC0WrHu67MLrdIfwARwV7063mwMk7sLU2WZfMgltL9yHgokKAOlfdKctoXosHjNWDerQlJu4oIAqC1iAiA4OqkNLcpQqRrdIgokK6Yi1LWuHwKYzdYBGuSrfcyqQSCbyqQ8AAK6s6YXaP0cbWLU2aPy5YbkgifMfhNfifHx3qGusqqk3GfhiLVLjfyhPgOV86rQbfLIuvML4BKQ1diLZAxHwngi1YGuCWV5meePRnmw0WrHuxgPUeMk0IuygBgI2nJuLbPITrko43CgccqW8HuxsGIuywxJEKAqrPi1eqko43CgccqqkjiivRhqkJWangi1YGuxsGIuywxJEKYlrSnsnbKIan4BGGutmqkHq2WyrdrdhfsPb0lHwWObrdhfsDzKcZJqacsPb2W4MbKcZq0wElA4OqQlJuywiV3abPAHRf6uXGuE9G)cKIz5ifoqgmLbPKzrRgdlA4OqQlJuywiV3abPY7nKHOrkzw0QlWGum8nJuS41YRgdKAGEiqQyBKY1aeKIz5ifMXMHODZw0WrHuxgPW8ieGGuxcdGuo7nKnivVifeeKAzqknWUuYoimiL47AdAzAlA4OqQlJuAGnUbEdeKY563Ls2bHZfP6fPCUIVRnSy(T(DPKDq4CrQb6boGuclw0Yltky)dTmT5X(pXYZc9X(Xb3h7)aHmPa5z7pEE1aVK)0cfI2M3meTB2cHmPabPUIutxgglloWs4aXs2bbsDfP6kdiLoifU)r8DTXFUHqlW4stCO5G0F)4GPh7)aHmPa5z7pEE1aVK)mosDl8sMuWoqQUcTjMLNYBgI2nJuoCGuTqHOTmanLftdCmSqitkqqQXqQRi14iLxVW1cgKcpsHjKYHdKACKIlfjb3q028EdziABfiLoifUoHuxrkUuKeCdrBfcXyRaP0bPW1jKAmKAS)i(U24pmanXDn6)(Xz0p2)bczsbYZ2F88QbEj)rtK6w4LmPGDGuDfAtmlpL3meTBgPUIuJJuIVRBibbKlWGu6GueWuCGKAHRfAds5WbsXLIKGBiARqigBfiLoi1ODcPg7pIVRn(ddqttHZfTW3poJWJ9FGqMuG8S9hpVAGxYFUfEjtkyNuHajIeE4pIVRn(dbKwFYmaawF)4OXh7)i(U24pvoVuPRnsIlx(deYKcKNTVFCCMh7)aHmPa5z7pEE1aVK)i(UUHeeqUadsPdsHlsDfPghP0eP4srsWneTvieJfU0Y0gKYHdKIlfjb3q0wHqmwxwi1yi1vKstK6w4LmPGDGuDfAtmlpL3meTB(pIVRn(dGbKMGK)(XX5FS)deYKcKNT)45vd8s(ZTWlzsb7KkeirKWd)r8DTXFMuHajIeE47hhm3J9FGqMuG8S9hpVAGxYFyC5yyjat5RgP0bpsnco9hX31g)HbOtQqGVFCgXh7)aHmPa5z7pEE1aVK)Ojs1cfI2oPvqsmUCmSqitkqqQRiLMi1TWlzsb7aP6k0MywEIi8lsgQy0JuxrkUuKeCdrBfcXyRaP0bPeFxBybmG0eKS1VlLSdI)i(U24pagqAcs(7hhCD6X(pqitkqE2(JNxnWl5pJJuTqHOTeiVrAsfcySqitkqqkhoqknrQBHxYKc2bs1vOnXS8uEZq0UzKYHdKIXLJHLamLVAKAKi1ODcPC4aPMUmm2m0sE5S0VMYy5qwQWGuJeP0isngsDfP0ePUfEjtkyzTlTcTjMLNMuHajIeEaPUIuAIu3cVKjfSdKQRqBIz5jIWVizOIr)FeFxB8hjIsFrLU247hhCX9X(pqitkqE2(JNxnWl5pJJuTqHOTeiVrAsfcySqitkqqkhoqknrQBHxYKc2bs1vOnXS8uEZq0UzKYHdKIXLJHLamLVAKAKi1ODcPgdPUIuAIu3cVKjfSS2LwH2eZYtzOfK6ksPjsDl8sMuWYAxAfAtmlpnPcbsej8asDfP0ePUfEjtkyhivxH2eZYteHFrYqfJ()i(U24pE9YAsMMxxaF)4GlMES)deYKcKNT)45vd8s(tluiA7KwbjX4YXWcHmPabPUIuCPij4gI2keIXwbsPdsj(U2WcyaPjizRFxkzhe)r8DTXFamG0eK83po4o6h7)i(U24peiVHjnRg(deYKcKNTVFCWDeES)deYKcKNT)45vd8s(JMivluiABEZq0UzleYKceK6ksXLIKGBiABEVHmeTTcKshKYRx4Abds5CqkCDcPUIuTqHOTeiVrAsfcySqitkq(J47AJ)Wa0e31O)7hhC14J9FGqMuG8S9hpVAGxYFY7nKHOTKY0s4bKshKcxnIuoCGutxgg762PLjXLqlyDz9hX31g)HbOtQqGVFCW1zES)deYKcKNT)45vd8s(tEVHmeTLuMwcpGu6Gu4QrKYHdKACKA6YWyx3oTmjUeAbRllK6ksPjs1cfI2M3meTB2cHmPabPg7pIVRn(ddqtCxJ(VFCW15FS)deYKcKNT)45vd8s(tEVHmeTLuMwcpGu6Gu4QX)i(U24p3qOfyCPjo0Cq6VFCWfZ9y)hiKjfipB)XZRg4L8NwOq0wcK3inPcbmwiKjfi)r8DTXFA98DqslvQB47V)dymq4bZJ9JdUp2)r8DTXF8B4HO5sdKedvYWFGqMuG8S99JdMES)J47AJ)mP7ssltQ1djiGmg)bczsbYZ23poJ(X(pIVRn(JwxHtkjslts0qGVT()aHmPa5z77hNr4X(pIVRn(dZ6DnajjAiWRgstqY)bczsbYZ23poA8X(pIVRn(dlxEXGrfAttQy6)aHmPa5z77hhN5X(pIVRn(tRhsUXCDdsIz5E4pqitkqE2((XX5FS)J47AJ)WlwSOqQIKHL4H)aHmPa5z77hhm3J9FeFxB8NblNsUHksCWSHeE4pqitkqE2((XzeFS)deYKcKNT)45vd8s(dJlhdKAKi1i4esDfPMUmm2m0sE5S0VMYyDz9hX31g)jd5LJrAzsuxFrseoizZ3F)hcWiU0(X(Xb3h7)aHmPa5z7plR)yG(pIVRn(ZTWlzsH)Clux4pTqHOTmf30PjDxIfczsbcs5WbszybuAQfUwOn2jviqIiHhWfP0bpsnosnAK6YivluiABZLIMwMe3TcleYKceKAS)Cl8uiz4ptQqGercp89JdMES)deYKcKNT)SS(Jb6)i(U24p3cVKjf(ZTqDH)OjsnosPjs1cfI2gqgmLXcHmPabPC4aP87sj7GWgqgmLXYbHGbs5Wbs53Ls2bHnGmykJLdzPcdsPds1cxl02UYqQ3ePaKYHdKYVlLSdcBazWuglhYsfgKshKYzCcPg7p3cpfsg(ZaP6k0MywEkGmykZ3poJ(X(pqitkqE2(ZY6pgO)J47AJ)Cl8sMu4p3c1f(JMivluiAlbYBuEleYKceK6ks53Ls2bHndTKxol9RPmwoKLkmi1irkNbPUIumUCmSeGP8vJu6GuJ2jK6ksnosPjsDl8sMuWoqQUcTjMLNcidMYGuoCGu(DPKDqydidMYy5qwQWGuJePW1jKAS)Cl8uiz4pS2LwH2eZYtzOLVFCgHh7)aHmPa5z7plR)yG(pIVRn(ZTWlzsH)Clux4p3cVKjfStQqGercpGuxrQXrkgxogi1irkNxJi1LrQwOq0wMIB60KUlXcHmPabPCoifMCcPg7p3cpfsg(dRDPvOnXS80KkeirKWdF)4OXh7)aHmPa5z7plR)yG(pIVRn(ZTWlzsH)Clux4pTqHOTeiVr5TqitkqqQRiLMivluiA7KwbjX4YXWcHmPabPUIu(DPKDqybmG0eKSLdzPcdsnsKACKsRNyZYLIuohKcti1yi1vKIXLJHLamLVAKshKcto9NBHNcjd)H1U0k0MywEcWastqYF)44mp2)bczsbYZ2Fww)Xa9FeFxB8NBHxYKc)5wOUWFAHcrBjc)IKHkg9wiKjfii1vKstK6w4LmPGL1U0k0MywEAsfcKis4bK6ksPjsDl8sMuWYAxAfAtmlpLHwqQRiLFxkzhewIWVizOIrV1L1FUfEkKm8Nbs1vOnXS8er4xKmuXO)7hhN)X(pqitkqE2(ZY6pgO)J47AJ)Cl8sMu4p3c1f(tluiABEZq0UzleYKceK6ksPjsnDzyS5ndr7MTUS(ZTWtHKH)mqQUcTjMLNYBgI2n)9JdM7X(pIVRn(dPmCxw9FGqMuG8S99JZi(y)hX31g)XVHXndPSOT8)bczsbYZ23po460J9FGqMuG8S9hX31g)XluAs8DTrIwM(pEE1aVK)O1tSCilvyqk8iLt)HwMofsg(JFxkzheF)4GlUp2)bczsbYZ2FeFxB8hVqPjX31gjAz6)45vd8s(tluiAlr4xKmuXO3cHmPabPUIuJJu3cVKjfSdKQRqBIz5jIWVizOIrps5WbsrGPldJLi8lsgQy0BDzHuJ9hAz6uiz4peHFrYqfJ(VFCWftp2)bczsbYZ2FeFxB8hUBKeFxBKOLP)JNxnWl5pTqHOTeiVr5Tqitkq(dTmDkKm8hcK3O8F)4G7OFS)deYKcKNT)i(U24pC3ij(U2irlt)hAz6uiz4pXYZc97V)dlo438u6h7hhCFS)deYKcKNTVFCW0J9FGqMuG8S99JZOFS)deYKcKNTVFCgHh7)aHmPa5z77hhn(y)hX31g)H121g)bczsbYZ23pooZJ9FGqMuG8S9hpVAGxYF0ePene4vdwVEz7YNAUegMLNLU2WcHmPa5pIVRn(tgAjVCw6xtz((7)qe(fjdvm6FSFCW9X(pqitkqE2(JNxnWl5pmUCmqkDWJuyoNqQRi14iLMi1TWlzsb7KkeirKWdiLdhiLMiLFxkzhe2jviqIiHhSCqiyGuJ9hX31g)Hi8lsgQy0)9JdMES)deYKcKNT)45vd8s(dbMUmmwIWVizOIrV1L1FeFxB8hjIsFrLU247hNr)y)hiKjfipB)XZRg4L8hcmDzySeHFrYqfJERlR)i(U24pE9YAsMMxxaF)9F87sj7G4X(Xb3h7)aHmPa5z7pEE1aVK)Ojsnos1cfI2sG8gL3cHmPabPC4aPUfEjtkyzTlTcTjMLNYqliLdhi1TWlzsb7aP6k0MywEkGmykdsngs5Wbs1vgs9MifGuJePWKg)J47AJ)KHwYlNL(1uMVFCW0J9FGqMuG8S9hpVAGxYFAHcrBjqEJYBHqMuGGuxrQXrknrkrdbE1G1Rx2U8PMlHHz5zPRnSqitkqqkhoqQXrk)UuYoiSagqAcs2YHSuHbP0bPWKti1vKYVlLSdc7KkeirKWdwoKLkmiLoiLwpXMLlfPgdPg7pIVRn(tgAjVCw6xtz((Xz0p2)bczsbYZ2F88QbEj)Hlfjb3q0wHqmw4sltBqQRifbMUmm2aYGPmwYoiqQRi14iL476gsqa5cmiLoifbmfhiPw4AH2GuoCGuCPij4gI2keIXwbsPds5moHuJ9hX31g)jGmykZ3poJWJ9FGqMuG8S9hpVAGxYF0eP4srsWneTvieJfU0Y0M)i(U24pbKbtz((XrJp2)bczsbYZ2F88QbEj)z6YWyZql5LZs)AkJLdzPcdsPdsHjnIuoCGuTW1cTTRmK6nrkaPgjs5mo9hX31g)H121gF)44mp2)bczsbYZ2Fcjd)rRqbVqPa3KM7g)r8DTXF0kuWlukWnP5UXFmye()Wa00u4Crl89JJZ)y)hiKjfipB)jKm8hTcf8cLcCtAUB8hX31g)rRqbVqPa3KM7g)XZRg4L8hnrQwOq0wgGMMcNlAbleYKcKVFCWCp2)bczsbYZ2Fcjd)H16VaAtPHaj53ml3w6AJebUlp8hX31g)H16VaAtPHaj53ml3w6AJebUlp8hpVAGxYFMUmm2m0sE5S0VMYyj7GaPUIutxggBgYlhJ0YKOU(IKiCqYglzhei1vKACKstKQfkeTLa5nstQqaJfczsbcs5WbsX4YXaPgjs5moHuJ99JZi(y)hiKjfipB)jKm8hXO)wcWK4IgU8KF5c9pIVRn(Jy0FlbysCrdxEYVCH(hpVAGxYFiW0LHXYfnC5j)YfAIatxgglzheiLdhi14ifbMUmmw)gexFx3qQIlsey6YWyDzHuoCGutxggBgAjVCw6xtzSCilvyqkDqkm5esngsDfPAHRfAREqOTEllFJuJePgnUiLdhivxzi1BIuasnsKcto99JdUo9y)hX31g)X1aPQHS5pqitkqE2((XbxCFS)deYKcKNT)i(U24pEHstIVRns0Y0)HwMofsg(dymq4bZ3F)hcK3O8p2po4(y)hiKjfipB)XZRg4L8NBHxYKc2jviqIiHh(J47AJ)qaP1NmdaG13poy6X(pqitkqE2(JNxnWl5pCPij4gI2keIX6YcPC4aP4srsWneTvieJTcKshKctA8pIVRn(dGbKMGK)(Xz0p2)bczsbYZ2F88QbEj)zCKACKstKYVlLSdclGbKMGKTUSqkhoqQPldJndTKxol9RPmwxwi1yi1vKIlfjb3q0wHqm2kqkDqQr7esngs5Wbsj(UUHeeqUadsPdsratXbsQfUwOn)r8DTXFyaAAkCUOf((XzeES)deYKcKNT)45vd8s(ZTWlzsb7KkeirKWdi1vKstKYVlLSdcBgAjVCw6xtzSCqiyGuxrQXrk)UuYoiSagqAcs2YHSuHbP0bPghP0isDzKs0qGxny5W9sVRqBAsfcySCjUaPCoi1OrQXqkhoqQXrkUuKeCdrBfcXyRaP0bPeFxByNuHajIeEW63Ls2bbsDfP4srsWneTvieJTcKAKifM0isngsn2FeFxB8NjviqIiHh((XrJp2)r8DTXFQCEPsxBKexU8hiKjfipBF)44mp2)bczsbYZ2F88QbEj)rtK6w4LmPGL1U0k0MywEAsfcKis4H)i(U24pseL(IkDTX3poo)J9FGqMuG8S9hpVAGxYFyC5yyjat5RgP0bpsnco9hX31g)HbOtQqGVFCWCp2)bczsbYZ2F88QbEj)rtK6w4LmPGL1U0k0MywEAsfcKis4bK6ksPjsDl8sMuWYAxAfAtmlpbyaPji5)i(U24pE9YAsMMxxaF)4mIp2)bczsbYZ2F88QbEj)PfkeTLa5nstQqaJfczsbcsDfP0eP87sj7GWcyaPjizlhecgi1vKACKYRx4AbdsHhPWes5WbsnosXLIKGBiABEVHmeTTcKshKcxNqQRifxkscUHOTcHySvGu6Gu46esngsn2FeFxB8hgGM4Ug9F)4GRtp2)r8DTXFiqEdtAwn8hiKjfipBF)4GlUp2)bczsbYZ2F88QbEj)z6YWyx3oTmjUeAbRlR)i(U24pTE(oiPLk1n89JdUy6X(pqitkqE2(JNxnWl5p59gYq0wszAj8asPdsHRgrkhoqQPldJDD70YK4sOfSUS(J47AJ)Wa0e31O)7hhCh9J9FGqMuG8S9hpVAGxYFY7nKHOTKY0s4bKshKcxn(hX31g)5gcTaJlnXHMds)9JdUJWJ9FGqMuG8S9hpVAGxYFAHcrBjqEJ0KkeWyHqMuG8hX31g)P1Z3bjTuPUHV)(7)CdCtTXJdMCc3r0jN3jN3IPr7eM(ZaHhvO18hN9mRL3abPCEKs8DTbsrltBSOH)HfFzkk8NrHuyMY96rkNniVbsHz6gnWrdhfsPVBwgniwyPTA9UtRFZyzQSlv6AdpxyASmv2JfA4OqQHUumqkm5e7ifMCc3rePUmsH7iQbXvJOHOHJcPCwk8OcTgniA4OqQlJuxctfArkNniVbsXgviGbPYYfGbPYRPrQlPlhdKsleax6AdKILlhOyGuywCCwGueEDdbsjbbPCdwCGu(wMuGDKAG(YRhPguuksvzwIVrQwpGuoRDfA1yGuldsXb)MZqqKU2WyrdhfsDzK6syQqlsHzSziA3msvgKk2gP4GFZziiabZhsDjbksHzDn6rQbfLIutaP4GFZziiabPKGGuTEaPmcd0yGuldsDjbksHzDn6rkVeX2i1eqkc0GVbcsnXaPeczdJfnenCuiLgqVeAbJgenCui1LrkmpcbiiLgydJBgqkmdrB5TOHJcPUmsHzH8EdeKQfUwOtfds51d(lqkMLJu4azWugKsMfTAmSOHJcPUmsHzH8EdeKkV3qgIgPKzrRUadsXW3msXIxlVAmqQb6HaPITrkxdqqkMLJuygBgI2nBrdhfsDzKcZJqacsDjmas5S3q2Gu9IuqqqQLbP0a7sj7GWGuIVRnOLPTOHJcPUmsPb24g4nqqkNRFxkzheoxKQxKY5k(U2WI5363Ls2bHZfPgOh4asjSyrlVmPGfnenCuiLZQlf8UnqqQjWSCaP8BEknsnbTvySifMN3dSAdsfBCz9cpZ4srkX31ggKAdkgw0qX31ggllo438uA8muXCbAO47AdJLfh8BEkTU4XsC1MHOLU2anu8DTHXYId(npLwx8yXSlbnCui1jewg9BJuCPii10LHbiiLPL2GutGz5as538uAKAcARWGusqqkwC4YS2URqlsvgKISbyrdfFxBySS4GFZtP1fpwMqyz0VDY0sBqdfFxBySS4GFZtP1fpwS2U2anu8DTHXYId(npLwx8yLHwYlNL(1ug2lg8AkAiWRgSE9Y2Lp1CjmmlplDTHfczsbcAiA4OqkNvxk4DBGGuWnWXaP6kdivRhqkX3lhPkdsj3srLjfSOHIVRnm6IhRBHxYKcShsgWpPcbsej8a73c1fW3cfI2YuCtNM0DjwiKjfioCyybuAQfUwOn2jviqIiHhWvh8Jp6l3cfI22CPOPLjXDRWcHmPazm0qX31ggDXJ1TWlzsb2djd4hivxH2eZYtbKbtzy)wOUaEnhxZwOq02aYGPmwiKjfioC43Ls2bHnGmykJLdcbdho87sj7GWgqgmLXYHSuHrNw4AH22vgs9Mif4WHFxkzhe2aYGPmwoKLkm64mongAO47AdJU4X6w4LmPa7HKb8S2LwH2eZYtzOf2VfQlGxZwOq0wcK3O8wiKjfix97sj7GWMHwYlNL(1uglhYsfMr6mxzC5yyjat5RwNr701X18w4LmPGDGuDfAtmlpfqgmLXHd)UuYoiSbKbtzSCilvygjUongAO47AdJU4X6w4LmPa7HKb8S2LwH2eZYttQqGercpW(TqDb83cVKjfStQqGercpCDCgxogJ0514LBHcrBzkUPtt6UeleYKceNdMCAm0qX31ggDXJ1TWlzsb2djd4zTlTcTjMLNamG0eKm73c1fW3cfI2sG8gL3cHmPa5QMTqHOTtAfKeJlhdleYKcKR(DPKDqybmG0eKSLdzPcZihxRNyZYL6CW0yxzC5yyjat5Rwhm5eAO47AdJU4X6w4LmPa7HKb8dKQRqBIz5jIWVizOIrp73c1fW3cfI2se(fjdvm6TqitkqUQ5TWlzsblRDPvOnXS80KkeirKWdx18w4LmPGL1U0k0MywEkdTC1VlLSdclr4xKmuXO36Ycnu8DTHrx8yDl8sMuG9qYa(bs1vOnXS8uEZq0Uz2VfQlGVfkeTnVziA3SfczsbYvnNUmm28MHODZwxwOHIVRnm6Ihlsz4USA0qX31ggDXJLFdJBgszrB5rdfFxBy0fpwEHstIVRns0Y0ShsgW73Ls2bb7fdETEILdzPcdENqdhfsj(U2WOlESyv(lsUSsmCrBgIM9IbpJlhdlbykF16GF0Aenu8DTHrx8y5fknj(U2irltZEizapr4xKmuXON9IbFluiAlr4xKmuXO3cHmPa5643cVKjfSdKQRqBIz5jIWVizOIrVdhey6YWyjc)IKHkg9wxwJHgk(U2WOlES4Urs8DTrIwMM9qYaEcK3O8Sxm4BHcrBjqEJYBHqMuGGgk(U2WOlES4Urs8DTrIwMM9qYa(y5zHIgIgk(U2Wy97sj7GaFgAjVCw6xtzyVyWR54TqHOTeiVr5TqitkqC44w4LmPGL1U0k0MywEkdT4WXTWlzsb7aP6k0MywEkGmykZyoC0vgs9MifmsmPr0qX31ggRFxkzhe6IhRm0sE5S0VMYWEXGVfkeTLa5nkVfczsbY1X1u0qGxny96LTlFQ5syywEw6AdleYKcehog3VlLSdclGbKMGKTCilvy0btoD1VlLSdc7KkeirKWdwoKLkm6O1tSz5shBm0qX31ggRFxkzhe6IhRaYGPmSxm45srsWneTvieJfU0Y0MRey6YWydidMYyj7G464IVRBibbKlWOdbmfhiPw4AH24WbxkscUHOTcHySvOJZ40yOHIVRnmw)UuYoi0fpwbKbtzyVyWRjxkscUHOTcHySWLwM2Ggk(U2Wy97sj7Gqx8yXA7Ad2lg8txggBgAjVCw6xtzSCilvy0btA0HJw4AH22vgs9MifmsNXj0qX31ggRFxkzhe6IhlxdKQgYShsgWRvOGxOuGBsZDd2nyeE8mannfox0cOHIVRnmw)UuYoi0fpwUgivnKzpKmGxRqbVqPa3KM7gSxm41SfkeTLbOPPW5IwWcHmPabnu8DTHX63Ls2bHU4XY1aPQHm7HKb8Sw)fqBkneij)Mz52sxBKiWD5b2lg8txggBgAjVCw6xtzSKDqCD6YWyZqE5yKwMe11xKeHds2yj7G464A2cfI2sG8gPjviGXcHmPaXHdgxogJ0zCAm0qX31ggRFxkzhe6IhlxdKQgYShsgWlg93saMex0WLN8lxOSxm4jW0LHXYfnC5j)YfAIatxgglzheoCmobMUmmw)gexFx3qQIlsey6YWyDz5WX0LHXMHwYlNL(1uglhYsfgDWKtJDTfUwOT6bH26TS89ihnUoC0vgs9Mifmsm5eAO47AdJ1VlLSdcDXJLRbsvdzdAO47AdJ1VlLSdcDXJLxO0K47AJeTmn7HKb8GXaHhmOHOHIVRnmwIWVizOIrpEIWVizOIrp7fdEgxog6GhZ501X18w4LmPGDsfcKis4bho00VlLSdc7KkeirKWdwoiemgdnu8DTHXse(fjdvm61fpwseL(IkDTb7fdEcmDzySeHFrYqfJERll0qX31gglr4xKmuXOxx8y51lRjzAEDbWEXGNatxgglr4xKmuXO36Ycnenu8DTHXsG8gLhpbKwFYmaawSxm4VfEjtkyNuHajIeEanu8DTHXsG8gLxx8ybyaPjiz2lg8CPij4gI2keIX6YYHdUuKeCdrBfcXyRqhmPr0qX31gglbYBuEDXJfdqttHZfTa7fd(Xhxt)UuYoiSagqAcs26YYHJPldJndTKxol9RPmwxwJDLlfjb3q0wHqm2k0z0onMdhIVRBibbKlWOdbmfhiPw4AH2Ggk(U2WyjqEJYRlESMuHajIeEG9Ib)TWlzsb7KkeirKWdx10VlLSdcBgAjVCw6xtzSCqiyCDC)UuYoiSagqAcs2YHSuHrNX14Lfne4vdwoCV07k0MMuHaglxIlCoJEmhogNlfjb3q0wHqm2k0r8DTHDsfcKis4bRFxkzhex5srsWneTvieJTIrIjno2yOHIVRnmwcK3O86IhRkNxQ01gjXLlOHIVRnmwcK3O86IhljIsFrLU2G9IbVM3cVKjfSS2LwH2eZYttQqGercpGgk(U2WyjqEJYRlESya6KkeG9IbpJlhdlbykF16GFeCcnu8DTHXsG8gLxx8y51lRjzAEDbWEXGxZBHxYKcww7sRqBIz5PjviqIiHhUQ5TWlzsblRDPvOnXS8eGbKMGKrdfFxBySeiVr51fpwmanXDn6zVyW3cfI2sG8gPjviGXcHmPa5QM(DPKDqybmG0eKSLdcbJRJ71lCTGbpMC4yCUuKeCdrBZ7nKHOTvOdUoDLlfjb3q0wHqm2k0bxNgBm0qX31gglbYBuEDXJfbYBysZQb0qX31gglbYBuEDXJvRNVdsAPsDdSxm4NUmm21TtltIlHwW6Ycnu8DTHXsG8gLxx8yXa0e31ON9IbFEVHmeTLuMwcpOdUA0HJPldJDD70YK4sOfSUSqdfFxBySeiVr51fpw3qOfyCPjo0CqA2lg859gYq0wszAj8Go4Qr0qX31gglbYBuEDXJvRNVdsAPsDdSxm4BHcrBjqEJ0KkeWyHqMuGGgIgk(U2WybJbcpyW73WdrZLgijgQKb0qX31gglymq4bJU4XAs3LKwMuRhsqazmqdfFxBySGXaHhm6IhlTUcNusKwMKOHaFB9OHIVRnmwWyGWdgDXJfZ6DnajjAiWRgstqYOHIVRnmwWyGWdgDXJflxEXGrfAttQyA0qX31gglymq4bJU4XQ1dj3yUUbjXSCpGgk(U2WybJbcpy0fpw8IflkKQizyjEanu8DTHXcgdeEWOlESgSCk5gQiXbZgs4b0qX31gglymq4bJU4Xkd5LJrAzsuxFrseoizd7fdEgxogJCeC660LHXMHwYlNL(1ugRll0q0qX31ggBS8SqXFdHwGXLM4qZbPzVyW3cfI2M3meTB2cHmPa560LHXYIdSeoqSKDqCTRmOdUOHIVRnm2y5zHQlESyaAI7A0ZEXGF8BHxYKc2bs1vOnXS8uEZq0UzhoAHcrBzaAklMg4yyHqMuGm21X96fUwWGhtoCmoxkscUHOT59gYq02k0bxNUYLIKGBiARqigBf6GRtJngAO47AdJnwEwO6IhlgGMMcNlAb2lg8AEl8sMuWoqQUcTjMLNYBgI2nFDCX31nKGaYfy0HaMIdKulCTqBC4Glfjb3q0wHqm2k0z0ongAO47AdJnwEwO6IhlciT(KzaaSyVyWFl8sMuWoPcbsej8aAO47AdJnwEwO6IhRkNxQ01gjXLlOHIVRnm2y5zHQlESamG0eKm7fdEX31nKGaYfy0b3RJRjxkscUHOTcHySWLwM24WbxkscUHOTcHySUSg7QM3cVKjfSdKQRqBIz5P8MHODZOHIVRnm2y5zHQlESMuHajIeEG9Ib)TWlzsb7KkeirKWdOHIVRnm2y5zHQlESya6KkeG9IbpJlhdlbykF16GFeCcnu8DTHXglpluDXJfGbKMGKzVyWRzluiA7KwbjX4YXWcHmPa5QM3cVKjfSdKQRqBIz5jIWVizOIr)vUuKeCdrBfcXyRqhX31gwadinbjB97sj7Ganu8DTHXglpluDXJLerPVOsxBWEXGF8wOq0wcK3inPcbmwiKjfioCO5TWlzsb7aP6k0MywEkVziA3SdhmUCmSeGP8vpYr7KdhtxggBgAjVCw6xtzSCilvygPgh7QM3cVKjfSS2LwH2eZYttQqGercpCvZBHxYKc2bs1vOnXS8er4xKmuXOhnu8DTHXglpluDXJLxVSMKP51fa7fd(XBHcrBjqEJ0KkeWyHqMuG4WHM3cVKjfSdKQRqBIz5P8MHODZoCW4YXWsaMYx9ihTtJDvZBHxYKcww7sRqBIz5Pm0YvnVfEjtkyzTlTcTjMLNMuHajIeE4QM3cVKjfSdKQRqBIz5jIWVizOIrpAO47AdJnwEwO6IhladinbjZEXGVfkeTDsRGKyC5yyHqMuGCLlfjb3q0wHqm2k0r8DTHfWastqYw)UuYoiqdfFxBySXYZcvx8yrG8gM0SAanu8DTHXglpluDXJfdqtCxJE2lg8A2cfI2M3meTB2cHmPa5kxkscUHOT59gYq02k0XRx4AbJZbxNU2cfI2sG8gPjviGXcHmPabnu8DTHXglpluDXJfdqNuHaSxm4Z7nKHOTKY0s4bDWvJoCmDzySRBNwMexcTG1LfAO47AdJnwEwO6IhlgGM4Ug9Sxm4Z7nKHOTKY0s4bDWvJoCm(0LHXUUDAzsCj0cwxwx1SfkeTnVziA3SfczsbYyOHIVRnm2y5zHQlESUHqlW4stCO5G0Sxm4Z7nKHOTKY0s4bDWvJOHIVRnm2y5zHQlESA98DqslvQBG9IbFluiAlbYBKMuHagleYKcK)iUT(L)NtLDPsxBOb4ct)93)da]] )


end
