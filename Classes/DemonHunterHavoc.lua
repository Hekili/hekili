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


    spec:RegisterPack( "Havoc", 20190728, [[dOuycbqisulIkkXJujYMujnkfWPuGwfvuQxrfzwKGBHQu2fL(feAyKihdvLLPs4zur10uq01ijSnuL03uqY4ujQohQs06uqW7qvQI5rs09GO9HQQdQGu1cjj9quLkMOcsXfrvQkBevj4JOkvPrIQe6KkivwPc1nPIsANKqlvbHEQkMkQIRIQuPVQGuYyvqk1Ev1FfzWuCyIfROhtvtgXLbBgsFMKA0uHtl51kOMns3wu7w43knCuXXrvQQwokpNutxQRtL2Uk13viJxLOCEiy9urX8rL2pu)8988hI0WR4fkXhVuPH6Il3EbFQyivY5)PrGd8hoIFyrn8NqYWF4fL71)hocc0vipp)rVUmp8hhDZrpeqer1v7WDA9BgrDLDPsxB4zcAJOUYEe)Z0TO9qx8Z)qKgEfVqj(4LknuxC52l4tfoxf8Y)O5a(xrvmud1FCuece)8peq7)ZLWgEr5E9yZqdK3aB4fDJgy4XxcBC0nh9qarevxTd3P1Vze1v2LkDTHNjOnI6k7rep(syZyxkcyZfxUcyZfkXhVeB4nS5c(gcQW54X4XxcBgAjSOc16HaE8LWgEdB4D1vOgBgAG8gyJQuHaASjlddASjV6gB4fCziGnQHaysxBGnCCzafbSziQiVxSHWQBiWgjiyJBWHbKY3YKckGnJCuEhyZOIsXMkZr8n20oaSH3VRqRgbSzrXgg43CgcI01gAlE8LWgEdB4D1vOgBCw3meTBgBkn2eBJnmWV5meeGW7bB4fak2meD1oWMrfLIntaByGFZziiabBKGGnTdaB0ck0iGnlk2WlauSzi6QDGnEjITXMjGneObFdeSzIa2ieYgA7FOLU1pp)jwwwOppVI8988hiKjfiVQ)XZQgyL8NwOq028MHODZwiKjfiyZvSz6IIA5WaocdiwYokWMRytxzaB4hB47pIVRn(ZneQbuxAIbndK(7xXlEE(deYKcKx1)4zvdSs(ZayZTWkzsb7iP6kuNqxwkVziA3m2WLl20cfI2Ic0uw0nWqWcHmPabBgeBUIndGnEhctnOXgKyZfydxUyZaydtkscUHOT59gYq02kWg(Xg(ucBUInmPij4gI2keI2wb2Wp2WNsyZGyZG)r8DTXFqbAI5QD89ROZFE(deYKcKx1)4zvdSs(JYyZTWkzsb7iP6kuNqxwkVziA3m2CfBgaBeFx3qccixGgB4hBiGUyaj1ctn0ASHlxSHjfjb3q0wHq02kWg(XgNRe2m4FeFxB8huGMMcJjQHVFfhYNN)aHmPa5v9pEw1aRK)ClSsMuWoPcbsej8WFeFxB8hciTJKEeaC((vufpp)r8DTXFQCEPsxBKexM8hiKjfiVQF)kYRpp)bczsbYR6F8SQbwj)r8DDdjiGCbASHFSHpS5k2ma2Om2WKIKGBiARqiAlCzLU1ydxUydtkscUHOTcHOTUCWMbXMRyJYyZTWkzsb7iP6kuNqxwkVziA38FeFxB8habinbj)9R4q988hiKjfiVQ)XZQgyL8NBHvYKc2jviqIiHh(J47AJ)mPcbsej8W3VIx(ZZFGqMuG8Q(hpRAGvYFqDziyjaA5RgB4hj2mKk9hX31g)bfOtQqGVFf5Lpp)bczsbYR6F8SQbwj)rzSPfkeTDsRGKqDziyHqMuGGnxXgLXMBHvYKc2rs1vOoHUSerydN0ur7aBUInmPij4gI2keI2wb2Wp2i(U2WciaPjizRFxkzhf)r8DTXFaeG0eK83VI8P0ZZFGqMuG8Q(hpRAGvYFgaBAHcrBjqEJ0KkeqBHqMuGGnC5InkJn3cRKjfSJKQRqDcDzP8MHODZydxUydQldblbqlF1yJkXgNRe2WLl2mDrrTzOL8Y44y1L2YGSuHgBuj2OcSzqS5k2Om2ClSsMuWYzxAfQtOllnPcbsej8a2CfBugBUfwjtkyhjvxH6e6YseHnCstfTJ)i(U24pseLJIkDTX3VI8X3ZZFGqMuG8Q(hpRAGvYFgaBAHcrBjqEJ0KkeqBHqMuGGnC5InkJn3cRKjfSJKQRqDcDzP8MHODZydxUydQldblbqlF1yJkXgNRe2mi2CfBugBUfwjtky5SlTc1j0LLYqlyZvSrzS5wyLmPGLZU0kuNqxwAsfcKis4bS5k2Om2ClSsMuWosQUc1j0LLicB4KMkAh)r8DTXF8oKvN0nRgg((vKVlEE(deYKcKx1)4zvdSs(tluiA7KwbjH6YqWcHmPabBUInmPij4gI2keI2wb2Wp2i(U2WciaPjizRFxkzhf)r8DTXFaeG0eK83VI858NN)i(U24peiVHonRg(deYKcKx1VFf5BiFE(deYKcKx1)4zvdSs(JYytluiABEZq0UzleYKceS5k2WKIKGBiABEVHmeTTcSHFSX7qyQbn24SXg(ucBUInTqHOTeiVrAsfcOTqitkq(J47AJ)Gc0eZv747xr(uXZZFGqMuG8Q(hpRAGvYFY7nKHOTKs3s4bSHFSHpvGnC5Intxuu762PfnXKqnyD58hX31g)bfOtQqGVFf5JxFE(deYKcKx1)4zvdSs(tEVHmeTLu6wcpGn8Jn8PcSHlxSzaSz6IIAx3oTOjMeQbRlhS5k2Om20cfI2M3meTB2cHmPabBg8pIVRn(dkqtmxTJVFf5BOEE(deYKcKx1)4zvdSs(tEVHmeTLu6wcpGn8Jn8PI)i(U24p3qOgqDPjg0mq6VFf57YFE(deYKcKx1)4zvdSs(tluiAlbYBKMuHaAleYKcK)i(U24pTd2okPMk1n893)b0Ai8G(55vKVNN)i(U24p(n8q0mPbscLkz4pqitkqEv)(v8INN)aHmPa5v9pEw1aRK)mDrrTzOL8Y44y1L26YbB4YfB6kdPEtKcWgvIeB4tP)i(U24pt6UK0IMAhqcciJW3VIo)55pqitkqEv)JNvnWk5ptxuuBgAjVmoowDPTUCWgUCXMUYqQ3ePaSrLiXgNR0FeFxB8h1UcJusKw0K4maBBhF)koKpp)bczsbYR6F8SQbwj)rZbO0ulm1qRTtQqGercpWh2WpsS5cSHlxSHjfjb3q0wHq02kWg(XgEvP)i(U24pOR3vdKK4maRAinbj)9ROkEE(deYKcKx1)4zvdSs(JMdqPPwyQHwBNuHajIeEGpSHFKyZfydxUydtkscUHOTcHOTvGn8Jn8Qs)r8DTXF44YkueQqDAsfD)9RiV(88hiKjfiVQ)XZQgyL8NPlkQLb(HPGwNqxMhSUCWgUCXMPlkQLb(HPGwNqxMhs(1nAGz1T4hgBuj2WNs)r8DTXFAhqYnMRBqsOlZdF)koupp)r8DTXFyfhouivrsZr8WFGqMuG8Q(9R4L)88hiKjfiVQ)XZQgyL8NPlkQLwOWKUlXQBXpm2OsSX5)r8DTXFgTmk5gQiXa9gs4HVFf5Lpp)bczsbYR6F8SQbwj)b1LHa2OsSzivcBUIntxuuBgAjVmoowDPTUC(J47AJ)KH8YqiTOjQRVijcdKS(7V)dbqfxA)88kY3ZZFGqMuG8Q(NLZF0q)hX31g)5wyLmPWFUfQl8NwOq0w0IP70KUlXcHmPabB4YfB0Cakn1ctn0A7KkeirKWd8Hn8JeBgaBCo2WBytluiABZKIMw0eZTcleYKceSzW)ClSuiz4ptQqGercp89R4fpp)bczsbYR6Fwo)rd9FeFxB8NBHvYKc)5wOUWFugBgaBugBAHcrBdid6sBHqMuGGnC5In(DPKDuydid6sBzGqqaB4YfB87sj7OWgqg0L2YGSuHgB4hBAHPgABxzi1BIua2WLl243Ls2rHnGmOlTLbzPcn2Wp2WRkHnd(NBHLcjd)zKuDfQtOllfqg0L(7xrN)88hiKjfiVQ)z58hn0)r8DTXFUfwjtk8NBH6c)rzSPfkeTLa5nkVfczsbc2CfB87sj7OWMHwYlJJJvxAldYsfASrLydVInxXguxgcwcGw(QXg(XgNRe2CfBgaBugBUfwjtkyhjvxH6e6YsbKbDPXgUCXg)UuYokSbKbDPTmilvOXgvIn8Pe2m4FUfwkKm8ho7sRqDcDzPm0Y3VId5ZZFGqMuG8Q(NLZF0q)hX31g)5wyLmPWFUfQl8NBHvYKc2jviqIiHhWMRyZaydQldbSrLyZqPcSH3WMwOq0w0IP70KUlXcHmPabBC2yZfkHnd(NBHLcjd)HZU0kuNqxwAsfcKis4HVFfvXZZFGqMuG8Q(NLZF0q)hX31g)5wyLmPWFUfQl8NwOq0wcK3O8wiKjfiyZvSrzSPfkeTDsRGKqDziyHqMuGGnxXg)UuYokSacqAcs2YGSuHgBuj2ma2O2tSz5YWgNn2Cb2mi2CfBqDziyjaA5RgB4hBUqP)ClSuiz4pC2LwH6e6YsacqAcs(7xrE955pqitkqEv)ZY5pAO)J47AJ)ClSsMu4p3c1f(tluiAlrydN0ur7WcHmPabBUInkJn3cRKjfSC2LwH6e6YstQqGercpGnxXgLXMBHvYKcwo7sRqDcDzPm0c2CfB87sj7OWse2Wjnv0oSUC(ZTWsHKH)msQUc1j0LLicB4KMkAhF)koupp)bczsbYR6Fwo)rd9FeFxB8NBHvYKc)5wOUWFAHcrBZBgI2nBHqMuGGnxXgLXMPlkQnVziA3S1LZFUfwkKm8Nrs1vOoHUSuEZq0U5VFfV8NN)i(U24pKsZC50)bczsbYR63VI8YNN)i(U24p(n0UziLf1L)pqitkqEv)(vKpLEE(deYKcKx1)4zvdSs(JApXYGSuHgBqInk9hX31g)XluAs8DTrIw6(p0s3PqYWF87sj7O47xr(4755pqitkqEv)JNvnWk5pTqHOTeHnCstfTdleYKceS5k2ma2ClSsMuWosQUc1j0LLicB4KMkAhydxUydbMUOOwIWgoPPI2H1Ld2m4FeFxB8hVqPjX31gjAP7)qlDNcjd)HiSHtAQOD89RiFx888hiKjfiVQ)XZQgyL8NwOq0wcK3O8wiKjfi)r8DTXFyUrs8DTrIw6(p0s3PqYWFiqEJY)9RiFo)55pqitkqEv)J47AJ)WCJK47AJeT09FOLUtHKH)elll0V)(pCyGFZtPFEEf5755pIVRn(dNTRn(deYKcKx1VFfV455pqitkqEv)JNvnWk5pkJnIZaSQbR3HSD5tntcn6YYsxByHqMuG8hX31g)jdTKxghhRU0F)9FicB4KMkAhppVI8988hiKjfiVQ)XZQgyL8huxgcyd)iXMlxjS5k2ma2Om2ClSsMuWoPcbsej8a2WLl2Om243Ls2rHDsfcKis4bldeccyZG)r8DTXFicB4KMkAhF)kEXZZFGqMuG8Q(hpRAGvYFiW0ff1se2Wjnv0oSUC(J47AJ)iruokQ01gF)k68NN)aHmPa5v9pEw1aRK)qGPlkQLiSHtAQODyD58hX31g)X7qwDs3SAy47V)JFxkzhfppVI8988hiKjfiVQ)XZQgyL8hLXMbWMwOq0wcK3O8wiKjfiydxUyZTWkzsblNDPvOoHUSugAbB4YfBUfwjtkyhjvxH6e6YsbKbDPXMbXgUCXMUYqQ3ePaSrLyZfQ4pIVRn(tgAjVmoowDP)(v8INN)aHmPa5v9pEw1aRK)0cfI2sG8gL3cHmPabBUIndGnkJnIZaSQbR3HSD5tntcn6YYsxByHqMuGGnC5IndGn(DPKDuybeG0eKSLbzPcn2Wp2CHsyZvSzaSrzS5wyLmPGDsfcKis4bSHlxSXVlLSJc7KkeirKWdwgKLk0yd)yJApXMLldBgeBgeBg8pIVRn(tgAjVmoowDP)(v05pp)bczsbYR6F8SQbwj)Hjfjb3q0wHq0w4YkDRXMRydbMUOO2aYGU0wYokWMRyZayJ476gsqa5c0yd)ydb0fdiPwyQHwJnC5InmPij4gI2keI2wb2Wp2WRkHnd(hX31g)jGmOl93VId5ZZFGqMuG8Q(hpRAGvYFugBysrsWneTvieTfUSs36)i(U24pbKbDP)(vufpp)bczsbYR6F8SQbwj)z6IIAZql5LXXXQlTLbzPcn2Wp2CHkWgUCXMwyQH22vgs9MifGnQeB4vL(J47AJ)Wz7AJVFf51NN)aHmPa5v9pIVRn(JAHcEHsbMon3n(JgHW)huGMMcJjQH)esg(JAHcEHsbMon3n((vCOEE(deYKcKx1)i(U24pQfk4fkfy60C34pEw1aRK)Om20cfI2Ic00uymrnyHqMuG8NqYWFuluWlukW0P5UX3VIx(ZZFGqMuG8Q(hX31g)HZ6hgAD5maj53mh3w6AJebUlp8hpRAGvYFMUOO2m0sEzCCS6sBj7OaBUIntxuuBgYldH0IMOU(IKimqYAlzhfyZvSzaSrzSPfkeTLa5nstQqaTfczsbc2WLl2G6YqaBuj2WRkHnd(NqYWF4S(HHwxodqs(nZXTLU2irG7YdF)kYlFE(deYKcKx1)i(U24pI2XTeGoXeNzzj)Ye6F8SQbwj)HatxuultCMLL8ltOjcmDrrTKDuGnC5IndGney6IIA9BqC9DDdPkgorGPlkQ1Ld2WLl2mDrrTzOL8Y44y1L2YGSuHgB4hBUqjSzqS5k20ctn0whGqBhwo(gBuj24C(WgUCXMUYqQ3ePaSrLyZfk9NqYWFeTJBjaDIjoZYs(Lj0VFf5tPNN)i(U24pUAivnK1)bczsbYR63VI8X3ZZFGqMuG8Q(hX31g)XluAs8DTrIw6(p0s3PqYWFaTgcpO)(7)qG8gL)55vKVNN)aHmPa5v9pEw1aRK)ClSsMuWoPcbsej8WFeFxB8hciTJKEeaC((v8INN)aHmPa5v9pEw1aRK)WKIKGBiARqiARlhSHlxSHjfjb3q0wHq02kWg(XMluXFeFxB8habinbj)9ROZFE(deYKcKx1)4zvdSs(ZayZayJYyJFxkzhfwabinbjBD5GnC5IntxuuBgAjVmoowDPTUCWMbXMRydtkscUHOTcHOTvGn8JnoxjSzqSHlxSr8DDdjiGCbASHFSHa6IbKulm1qR)J47AJ)Gc00uymrn89R4q(88hiKjfiVQ)XZQgyL8NBHvYKc2jviqIiHhWMRyJYyJFxkzhf2m0sEzCCS6sBzGqqaBUIndGn(DPKDuybeG0eKSLbzPcn2Wp2ma2OcSH3WgXzaw1GLb3l9Uc1PjviG2YKyySXzJnohBgeB4YfBgaBysrsWneTvieTTcSHFSr8DTHDsfcKis4bRFxkzhfyZvSHjfjb3q0wHq02kWgvInxOcSzqSzW)i(U24ptQqGercp89ROkEE(J47AJ)u58sLU2ijUm5pqitkqEv)(vKxFE(deYKcKx1)4zvdSs(JYyZTWkzsblNDPvOoHUS0KkeirKWd)r8DTXFKikhfv6AJVFfhQNN)aHmPa5v9pEw1aRK)G6YqWsa0Yxn2WpsSziv6pIVRn(dkqNuHaF)kE5pp)bczsbYR6F8SQbwj)rzS5wyLmPGLZU0kuNqxwAsfcKis4bS5k2Om2ClSsMuWYzxAfQtOllbiaPji5)i(U24pEhYQt6MvddF)kYlFE(deYKcKx1)4zvdSs(tluiAlbYBKMuHaAleYKceS5k2Om243Ls2rHfqastqYwgieeWMRyZayJ3HWudASbj2Cb2WLl2ma2WKIKGBiABEVHmeTTcSHFSHpLWMRydtkscUHOTcHOTvGn8Jn8Pe2mi2m4FeFxB8huGMyUAhF)kYNspp)r8DTXFiqEdDAwn8hiKjfiVQF)kYhFpp)bczsbYR6F8SQbwj)z6IIAx3oTOjMeQbRlN)i(U24pTd2okPMk1n89RiFx888hiKjfiVQ)XZQgyL8N8EdziAlP0TeEaB4hB4tfydxUyZ0ff1UUDArtmjudwxo)r8DTXFqbAI5QD89RiFo)55pqitkqEv)JNvnWk5p59gYq0wsPBj8a2Wp2WNk(J47AJ)CdHAa1LMyqZaP)(vKVH855pqitkqEv)JNvnWk5pTqHOTeiVrAsfcOTqitkq(J47AJ)0oy7OKAQu3W3F)9FUbMU24v8cL4JxQ0qP0fx8NrclQqT(pdDzolRbc2muyJ47AdSHw6wBXJ)dh2Iwu4pxcB4fL71JndnqEdSHx0nAGHhFjSXr3C0dberuD1oCNw)MruxzxQ01gEMG2iQRShr84lHnJDPiGnxC5kGnxOeF8sSH3WMl4BiOcNJhJhFjSzOLWIkuRhc4XxcB4nSH3vxHASzObYBGnQsfcOXMSmmOXM8QBSHxWLHa2OgcGjDTb2WXLbueWMHOI8EXgcRUHaBKGGnUbhgqkFltkOa2mYr5DGnJkkfBQmhX3yt7aWgE)UcTAeWMffByGFZziisxBOT4XxcB4nSH3vxHASXzDZq0UzSP0ytSn2Wa)MZqqacVhSHxaOyZq0v7aBgvuk2mbSHb(nNHGaeSrcc20oaSrlOqJa2SOydVaqXMHOR2b24Li2gBMa2qGg8nqWMjcyJqiBOT4X4XxcB4DCiHAqpeWJVe2WByZqpHaeSH3zdTBgWgNvrD5T4XxcB4nSzic59giytlm1qNkuSX7a8dJnOldBueYGU0yJmlA1iyXJVe2WByZqeY7nqWM8EdziASrMfT6c0ydkBZydhwTSQraBg5acSj2gBC1abBqxg24SUziA3Sfp(sydVHnd9ecqWgExnGndDnK1ytVydeeSzrXgENDPKDuOXgX31g0s3w84lHn8g2W7SXnWAGGnol(DPKDu4SGn9InolIVRnSdTT(DPKDu4SGnJCamaBeoCOLxMuWIhJhFjSH33LbE3giyZeqxgGn(npLgBMG6k0wSzO37boTgBIn4nhclJ6sXgX31gASzdkcw84lHnIVRn0womWV5P0irPIEy84lHnIVRn0womWV5P0oHerXvDgIw6Ad84lHnIVRn0womWV5P0oHer0Dj4XxcBoHWr7yBSHjfbBMUOOabB0T0ASzcOldWg)MNsJntqDfASrcc2WHb8gNT7kuJnLgBiBaw84lHnIVRn0womWV5P0oHerDiC0o2oPBP14XIVRn0womWV5P0oHeroBxBGhl(U2qB5Wa)MNs7eseZql5LXXXQlTcfksLfNbyvdwVdz7YNAMeA0LLLU2WcHmPabpgp(sydVVld8UnqWg4gyiGnDLbSPDayJ47LHnLgBKBPOYKcw8yX31gANqI4TWkzsbfcjdiNuHajIeEqHBH6ciBHcrBrlMUtt6UeleYKceUC1Cakn1ctn0A7KkeirKWd8XpYbCoV1cfI22mPOPfnXCRWcHmPazq8yX31gANqI4TWkzsbfcjdihjvxH6e6YsbKbDPv4wOUasLhq5wOq02aYGU0wiKjfiC563Ls2rHnGmOlTLbcbbUC97sj7OWgqg0L2YGSuHM)wyQH22vgs9MifWLRFxkzhf2aYGU0wgKLk08ZRkniES47AdTtir8wyLmPGcHKbKC2LwH6e6YszOffUfQlGu5wOq0wcK3O8wiKjfix97sj7OWMHwYlJJJvxAldYsfAvYRxrDziyjaA5RMFNR01bu(wyLmPGDKuDfQtOllfqg0LMlx)UuYokSbKbDPTmilvOvjFkniES47AdTtir8wyLmPGcHKbKC2LwH6e6YstQqGercpOWTqDbK3cRKjfStQqGercpCDauxgcQCOubV1cfI2IwmDNM0DjwiKjfio7luAq8yX31gANqI4TWkzsbfcjdi5SlTc1j0LLaeG0eKSc3c1fq2cfI2sG8gL3cHmPa5QYTqHOTtAfKeQldbleYKcKR(DPKDuybeG0eKSLbzPcTkhqTNyZYL5SVyWROUmeSeaT8vZ)fkHhl(U2q7eseVfwjtkOqiza5iP6kuNqxwIiSHtAQODOWTqDbKTqHOTeHnCstfTdleYKcKRkFlSsMuWYzxAfQtOllnPcbsej8WvLVfwjtky5SlTc1j0LLYqlx97sj7OWse2Wjnv0oSUCWJfFxBODcjI3cRKjfuiKmGCKuDfQtOllL3meTBwHBH6ciBHcrBZBgI2nBHqMuGCv5PlkQnVziA3S1LdES47AdTtirKuAMlNgpw8DTH2jKi63q7MHuwuxE8yX31gANqIOxO0K47AJeT0TcHKbK(DPKDuOqHIuTNyzqwQqJuj84lHnIVRn0oHeroLF4KlNektuNHOvOqrI6YqWsa0Yxn)iDUkWJfFxBODcjIEHstIVRns0s3kesgqse2Wjnv0ouOqr2cfI2se2Wjnv0oSqitkqUoWTWkzsb7iP6kuNqxwIiSHtAQODWLlbMUOOwIWgoPPI2H1LZG4XIVRn0oHerMBKeFxBKOLUviKmGKa5nkVcfkYwOq0wcK3O8wiKjfi4XIVRn0oHerMBKeFxBKOLUviKmGmwwwO4X4XIVRn0w)UuYokqMHwYlJJJvxAfkuKkpqluiAlbYBuEleYKceUCVfwjtky5SlTc1j0LLYqlC5ElSsMuWosQUc1j0LLcid6spixUDLHuVjsbQ8cvGhl(U2qB97sj7OWjKiMHwYlJJJvxAfkuKTqHOTeiVr5TqitkqUoGYIZaSQbR3HSD5tntcn6YYsxByHqMuGWL7a(DPKDuybeG0eKSLbzPcn)xO01bu(wyLmPGDsfcKis4bUC97sj7OWoPcbsej8GLbzPcn)Q9eBwUSbhCq8yX31gARFxkzhfoHeXaYGU0kuOizsrsWneTvieTfUSs36Rey6IIAdid6sBj7O46aIVRBibbKlqZpb0fdiPwyQHwZLltkscUHOTcHOTvWpVQ0G4XIVRn0w)UuYokCcjIbKbDPvOqrQmtkscUHOTcHOTWLv6wJhl(U2qB97sj7OWjKiYz7AdfkuKtxuuBgAjVmoowDPTmilvO5)cvWLBlm1qB7kdPEtKcujVQeES47AdT1VlLSJcNqIORgsvdzfcjdivluWlukW0P5UHcAecpsuGMMcJjQb8yX31gARFxkzhfoHerxnKQgYkesgqQwOGxOuGPtZDdfkuKk3cfI2Ic00uymrnyHqMuGGhl(U2qB97sj7OWjKi6QHu1qwHqYasoRFyO1LZaKKFZCCBPRnse4U8GcfkYPlkQndTKxghhRU0wYokUoDrrTziVmeslAI66lsIWajRTKDuCDaLBHcrBjqEJ0KkeqBHqMuGWLlQldbvYRkniES47AdT1VlLSJcNqIORgsvdzfcjdifTJBjaDIjoZYs(LjufkuKey6IIAzIZSSKFzcnrGPlkQLSJcUChGatxuuRFdIRVRBivXWjcmDrrTUC4YD6IIAZql5LXXXQlTLbzPcn)xO0GxBHPgARdqOTdlhFRsNZhxUDLHuVjsbQ8cLWJfFxBOT(DPKDu4eseD1qQAiRXJfFxBOT(DPKDu4ese9cLMeFxBKOLUviKmGe0Ai8Ggpgpw8DTH2se2Wjnv0oqse2Wjnv0ouOqrI6YqGFKxUsxhq5BHvYKc2jviqIiHh4Yvz)UuYokStQqGercpyzGqqyq8yX31gAlrydN0ur7WjKikruokQ01gkuOijW0ff1se2Wjnv0oSUCWJfFxBOTeHnCstfTdNqIO3HS6KUz1WGcfkscmDrrTeHnCstfTdRlh8y8yX31gAlbYBuEKeqAhj9ia4OqHI8wyLmPGDsfcKis4b8yX31gAlbYBuENqIiGaKMGKvOqrYKIKGBiARqiARlhUCzsrsWneTvieTTc(Vqf4XIVRn0wcK3O8oHeruGMMcJjQbfkuKdmGY(DPKDuybeG0eKS1LdxUtxuuBgAjVmoowDPTUCg8ktkscUHOTcHOTvWVZvAqUCfFx3qccixGMFcOlgqsTWudTgpw8DTH2sG8gL3jKioPcbsej8GcfkYBHvYKc2jviqIiHhUQSFxkzhf2m0sEzCCS6sBzGqq46a(DPKDuybeG0eKSLbzPcn)dOcEtCgGvnyzW9sVRqDAsfcOTmjg2z78b5YDaMuKeCdrBfcrBRGFX31g2jviqIiHhS(DPKDuCLjfjb3q0wHq02ku5fQyWbXJfFxBOTeiVr5DcjIvoVuPRnsIltWJfFxBOTeiVr5DcjIseLJIkDTHcfksLVfwjtky5SlTc1j0LLMuHajIeEapw8DTH2sG8gL3jKiIc0jviGcfksuxgcwcGw(Q5h5qQeES47AdTLa5nkVtir07qwDs3SAyqHcfPY3cRKjfSC2LwH6e6YstQqGercpCv5BHvYKcwo7sRqDcDzjabinbjJhl(U2qBjqEJY7eserbAI5QDOqHISfkeTLa5nstQqaTfczsbYvL97sj7OWciaPjizldeccxhW7qyQbnYl4YDaMuKeCdrBZ7nKHOTvWpFkDLjfjb3q0wHq02k4NpLgCq8yX31gAlbYBuENqIibYBOtZQb8yX31gAlbYBuENqIy7GTJsQPsDdkuOiNUOO21TtlAIjHAW6Ybpw8DTH2sG8gL3jKiIc0eZv7qHcfzEVHmeTLu6wcpWpFQGl3PlkQDD70IMysOgSUCWJfFxBOTeiVr5DcjI3qOgqDPjg0mqAfkuK59gYq0wsPBj8a)8Pc8yX31gAlbYBuENqIy7GTJsQPsDdkuOiBHcrBjqEJ0KkeqBHqMuGGhJhl(U2qBbTgcpOr63WdrZKgijuQKb8yX31gAlO1q4bTtirCs3LKw0u7asqazeuOqroDrrTzOL8Y44y1L26YHl3UYqQ3ePavIKpLWJfFxBOTGwdHh0oHer1UcJusKw0K4maBBhkuOiNUOO2m0sEzCCS6sBD5WLBxzi1BIuGkr6CLWJfFxBOTGwdHh0oHer017QbssCgGvnKMGKvOqrQ5auAQfMAO12jviqIiHh4JFKxWLltkscUHOTcHOTvWpVQeES47AdTf0Ai8G2jKiYXLvOiuH60Kk6wHcfPMdqPPwyQHwBNuHajIeEGp(rEbxUmPij4gI2keI2wb)8Qs4XIVRn0wqRHWdANqIy7asUXCDdscDzEqHcf50ff1Ya)WuqRtOlZdwxoC5oDrrTmWpmf06e6Y8qYVUrdmRUf)WQKpLWJfFxBOTGwdHh0oHerwXHdfsvK0CepGhl(U2qBbTgcpODcjIJwgLCdvKyGEdj8GcfkYPlkQLwOWKUlXQBXpSkDoES47AdTf0Ai8G2jKiMH8YqiTOjQRVijcdKSwHcfjQldbvoKkDD6IIAZql5LXXXQlT1LdEmES47AdTnwwwOiVHqnG6stmOzG0kuOiBHcrBZBgI2nBHqMuGCD6IIA5WaocdiwYokU2vg4Np8yX31gABSSSqDcjIOanXC1ouOqroWTWkzsb7iP6kuNqxwkVziA3mxUTqHOTOanLfDdmeSqitkqg86aEhctnOrEbxUdWKIKGBiABEVHmeTTc(5tPRmPij4gI2keI2wb)8P0GdIhl(U2qBJLLfQtirefOPPWyIAqHcfPY3cRKjfSJKQRqDcDzP8MHODZxhq8DDdjiGCbA(jGUyaj1ctn0AUCzsrsWneTvieTTc(DUsdIhl(U2qBJLLfQtirKas7iPhbahfkuK3cRKjfStQqGercpGhl(U2qBJLLfQtirSY5LkDTrsCzcES47AdTnwwwOoHerabinbjRqHIu8DDdjiGCbA(576akZKIKGBiARqiAlCzLU1C5YKIKGBiARqiARlNbVQ8TWkzsb7iP6kuNqxwkVziA3mES47AdTnwwwOoHeXjviqIiHhuOqrElSsMuWoPcbsej8aES47AdTnwwwOoHeruGoPcbuOqrI6YqWsa0Yxn)ihsLWJfFxBOTXYYc1jKiciaPjizfkuKk3cfI2oPvqsOUmeSqitkqUQ8TWkzsb7iP6kuNqxwIiSHtAQODCLjfjb3q0wHq02k4x8DTHfqastqYw)UuYokWJfFxBOTXYYc1jKikruokQ01gkuOihOfkeTLa5nstQqaTfczsbcxUkFlSsMuWosQUc1j0LLYBgI2nZLlQldblbqlF1Q05kXL70ff1MHwYlJJJvxAldYsfAvQIbVQ8TWkzsblNDPvOoHUS0KkeirKWdxv(wyLmPGDKuDfQtOllre2Wjnv0oWJfFxBOTXYYc1jKi6DiRoPBwnmOqHICGwOq0wcK3inPcb0wiKjfiC5Q8TWkzsb7iP6kuNqxwkVziA3mxUOUmeSeaT8vRsNR0Gxv(wyLmPGLZU0kuNqxwkdTCv5BHvYKcwo7sRqDcDzPjviqIiHhUQ8TWkzsb7iP6kuNqxwIiSHtAQODGhl(U2qBJLLfQtireqastqYkuOiBHcrBN0kijuxgcwiKjfixzsrsWneTvieTTc(fFxBybeG0eKS1VlLSJc8yX31gABSSSqDcjIeiVHonRgWJfFxBOTXYYc1jKiIc0eZv7qHcfPYTqHOT5ndr7MTqitkqUYKIKGBiABEVHmeTTc(9oeMAq7S5tPRTqHOTeiVrAsfcOTqitkqWJfFxBOTXYYc1jKiIc0jviGcfkY8EdziAlP0TeEGF(ubxUtxuu762PfnXKqnyD5Ghl(U2qBJLLfQtirefOjMR2HcfkY8EdziAlP0TeEGF(ubxUdmDrrTRBNw0etc1G1LZvLBHcrBZBgI2nBHqMuGmiES47AdTnwwwOoHeXBiudOU0edAgiTcfkY8EdziAlP0TeEGF(ubES47AdTnwwwOoHeX2bBhLutL6guOqr2cfI2sG8gPjviG2cHmPa5pIB7yz)5uzxQ01g8ombT)(7)b]] )


end
