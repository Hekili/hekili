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


    spec:RegisterPack( "Havoc", 20190629.1635, [[dWKo6aqisflcsvXJOkYMGGpbPQ0OOQQtPqzvufvEfrQzrkClivSlQ8li0WOQYXOkSmvk9msLmnQIY1GiTniv6BqeACKkLohPs16GiY7GufzEku19GK9rk6GqQQAHejpeIGMiPsrxesvuBuHk6JufvzKqQcNKuPWkPQmticu3esvLDcPSuivPNQOPcrDvfQWxHiGXcrGSxv9xjgmfhg1IvXJP0KrCzWMjQptknAsvNw0RvPy2iDBjTBHFR0WjIJtvuvlNWZjz6sDDfSDvY3viJxHkDEvQwpernFQs7hQFpEK)jHB4r7w)8q39dDVv3DEGU6cPifP)SVlb(Pe2EdRf(zWv4NOh81A)Pe(oDzYJ8pv7GWc)uF3suijeruB26hoo7wruL1bk35gwbl3iQYQfXFEgsARBe)5NeUHhTB9ZdD3p09wD35b6QlKIuK(tLeW(OHuKis8N6tcbI)8tcOS)0tyd6bFTwSr3eQBGnOhdrdcSppHn67wIcjHiIAZw)WXz3kIQSoq5o3Wky5grvwTiI95jSX3qayZT6UgyZT(5HUJnOd24HUqs6YdSpSppHnibyrKHwfsc7Ztyd6GnJdvgAXgDtOUb2ifLjGcBQ8nGcBQRQXMX5G4o2OfcqWDUb2izqa07yd6fnppSHiYliWgoiyZqiraK028HcAGnJ0Nw9yZOKsXMSkHTn206bSXZFGPzFhBwzSra2TwHGWDUHYH95jSbDWMXHkdTyd63wHOhQytQWMyBSra2TwHGae0tyZ4eOyd6DqPhBgLuk2CaSra2TwHGaeSHdc206bSrXYqFhBwzSzCcuSb9oO0JnwoITXMdGneObBdeS5ChByczdL7N0u1Qh5FgROY0h5hnpEK)je8HcKxQFAfzdIK)zZuiAxDRq0dvhe8HceSbbS5mil7KiajSaioYokWgeWMoRa2Oj24XpzBNB8Zli0cYd0IaAbW93pA3(i)ti4dfiVu)0kYgej)ZlwK8HcUrC2zOTiVIsDRq0dvSbbSXFSXQNfAbf2GcBUfB86fB8hBeCskWfeTRUxqfI2Lb2Oj24HFydcyJGtsbUGODmHOCzGnAInE4h2mg2m2pzBNB8tzGwedk9F)OPRh5FcbFOa5L6Nwr2Gi5FQd2CXIKpuWnIZodTf5vuQBfIEOIniGn(JnSTZlOabutqHnAIneqLcGuAwOfAf241l2i4KuGliAhtikxgyJMyJU8dBg7NSTZn(PmqlhwiyTW3pAE2J8pHGpuG8s9tRiBqK8pVyrYhk4ouMafchw4NSTZn(jb4wFrncajF)OH0h5FY2o34NzTUuUZnk8GG)je8HcKxQVF0q3h5FcbFOa5L6Nwr2Gi5FY2oVGceqnbf2Oj24b2Ga24p2Od2i4KuGliAhtikhmUPQvyJxVyJGtsbUGODmHOCdsWMXWgeWgDWMlwK8HcUrC2zOTiVIsDRq0d1FY2o34NWDOCaU(9Jgs8r(NqWhkqEP(PvKnis(NxSi5dfChktGcHdl8t225g)8qzcuiCyHVF00TpY)ec(qbYl1pTISbrY)uEqC3ra50Mn2OjkSXZ87NSTZn(PmqpuMaF)OP7pY)ec(qbYl1pTISbrY)uhSPzkeT7qZGuKhe3DqWhkqWgeWgDWMlwK8HcUrC2zOTiVIcHf3uuuwPhBqaBeCskWfeTJjeLldSrtSHTDUHdUdLdWvNDxkzhf)KTDUXpH7q5aC97hnp87r(NqWhkqEP(PvKnis(N(JnntHODeOUr5qzcOCqWhkqWgVEXgDWMlwK8HcUrC2zOTiVIsDRq0dvSXRxSrEqC3ra50Mn2mESrx(HnE9InNbzzxfAUUcj6xvQCcOYzOWMXJnifBgdBqaB0bBUyrYhk4KSlndTf5vuouMafchwaBqaB0bBUyrYhk4gXzNH2I8kkewCtrrzL(FY2o34NCeP(KYDUX3pAE4XJ8pHGpuG8s9tRiBqK8p9hBAMcr7iqDJYHYeq5GGpuGGnE9In6GnxSi5dfCJ4SZqBrEfL6wHOhQyJxVyJ8G4UJaYPnBSz8yJU8dBgdBqaB0bBUyrYhk4KSlndTf5vuQqZydcyJoyZfls(qbNKDPzOTiVIYHYeOq4WcydcyJoyZfls(qb3io7m0wKxrHWIBkkkR0)t225g)0QNxvr1I8g47hnpU9r(NqWhkqEP(PvKnis(NntHODhAgKI8G4Udc(qbc2Ga2i4KuGliAhtikxgyJMydB7CdhChkhGRo7UuYok(jB7CJFc3HYb463pAEORh5FY2o34NeOUHQCYg(je8HcKxQVF08WZEK)je8HcKxQFAfzdIK)zDVGkeTJKQMdlGnAInEGuSXRxS5mil72HUSYfbhAb3GKFY2o34NYa9qzc89JMhi9r(NqWhkqEP(PvKnis(NntHODeOUr5qzcOCqWhkq(jB7CJF26f7OIwkNxW3F)tqPGWcQh5hnpEK)jB7CJFA3Wcrl4gifzkxHFcbFOa5L67hTBFK)jB7CJFEO7skRCP1dfiG69FcbFOa5L67hnD9i)t225g)u7alijhLvUWizqST(FcbFOa5L67hnp7r(NSTZn(P8AhuaPWizqKnuoax)je8HcKxQVF0q6J8pzBNB8tjdIu(EgAlhkR6FcbFOa5L67hn09r(NSTZn(zRhkdXzhcsrEfw4NqWhkqEP((rdj(i)t225g)uKsKqHsgfLe2c)ec(qbYl13pA62h5FY2o34NJwbLCbzueGAdoSWpHGpuG8s99JMU)i)ti4dfiVu)0kYgej)t5bXDSz8yJN5h2Ga2CgKLDvO56kKOFvPYni5NSTZn(zfQR4EzLl0bBskebWv13F)tciZd0(r(rZJh5FY2o34NKujgK0)ec(qbYl13pA3(i)t225g)0UHAOcLkRnT)ec(qbYl13pA66r(NqWhkqEP(5k5NkO)jB7CJFEXIKpu4NxmDa(zZuiANCkuD5q3L4GGpuGGnE9InkjaLwAwOfAL7qzcuiCybpWgnrHn(Jn6cBqhSPzkeTRfCslRCrmKHdc(qbc2m2pVyrj4k8ZdLjqHWHf((rZZEK)je8HcKxQFUs(Pc6FY2o34NxSi5df(5fthGFQd24p2Od20mfI2fqfuPYbbFOabB86fBS7sj7OWfqfuPYjaMChB86fBS7sj7OWfqfuPYjGkNHcB0eB6ScLElKeWgVEXg7UuYokCbubvQCcOYzOWgnXg01pSzSFEXIsWv4NJ4SZqBrEfLaQGkvF)OH0h5FcbFOa5L6NRKFQG(NSTZn(5fls(qHFEX0b4N6GnntHODeOUrADqWhkqWgeWg7UuYokCvO56kKOFvPYjGkNHcBgp2GUydcyJ8G4UJaYPnBSrtSrx(HniGn(Jn6GnxSi5dfCJ4SZqBrEfLaQGkvyJxVyJDxkzhfUaQGkvobu5muyZ4Xgp8dBg7NxSOeCf(PKDPzOTiVIsfA(7hn09r(NqWhkqEP(5k5NkO)jB7CJFEXIKpu4NxmDa(5fls(qb3HYeOq4WcydcyJ)yJ8G4o2mESbjIuSbDWMMPq0o5uO6YHUlXbbFOabB8CyZT(HnJ9ZlwucUc)uYU0m0wKxr5qzcuiCyHVF0qIpY)ec(qbYl1pxj)ub9pzBNB8ZlwK8Hc)8IPdWpBMcr7iqDJ06GGpuGGniGn6GnntHODhAgKI8G4Udc(qbc2Ga2y3Ls2rHdUdLdWvNaQCgkSz8yJ)yJwlXv5XfB8CyZTyZyydcyJ8G4UJaYPnBSrtS5w)(5flkbxHFkzxAgAlYROa3HYb463pA62h5FcbFOa5L6NRKFQG(NSTZn(5fls(qHFEX0b4NntHODewCtrrzLEhe8HceSbbSrhS5IfjFOGtYU0m0wKxr5qzcuiCybSbbSrhS5IfjFOGtYU0m0wKxrPcnJniGn2DPKDu4iS4MIIYk9Ubj)8IfLGRWphXzNH2I8kkewCtrrzL(VF009h5FcbFOa5L6NRKFQG(NSTZn(5fls(qHFEX0b4NntHOD1TcrpuDqWhkqWgeWgDWMZGSSRUvi6HQBqYpVyrj4k8ZrC2zOTiVIsDRq0d1VF08WVh5FY2o34NKujgK0)ec(qbYl13pAE4XJ8pHGpuG8s9tRiBqK8p1Ajobu5muydkSXVFY2o34NwMslSTZnk0u1)KMQUeCf(PDxkzhfF)O5XTpY)ec(qbYl1pTISbrY)uEqC3ra50Mn2OjkSrxi9NSTZn(PK0EtzqsrwWARq0F)O5HUEK)je8HcKxQFAfzdIK)zZuiAhHf3uuuwP3bbFOabBqaB8hBUyrYhk4gXzNH2I8kkewCtrrzLESXRxSHaNbzzhHf3uuuwP3nibBg7NSTZn(PLP0cB7CJcnv9pPPQlbxHFsyXnffLv6)(rZdp7r(NqWhkqEP(PvKnis(NntHODeOUrADqWhkq(jB7CJFkgIcB7CJcnv9pPPQlbxHFsG6gP97hnpq6J8pHGpuG8s9t225g)umef225gfAQ6FstvxcUc)mwrLPF)9pLia7wpC)i)O5XJ8pHGpuG8s99J2TpY)ec(qbYl13pA66r(NqWhkqEP((rZZEK)je8HcKxQVF0q6J8pzBNB8tjBNB8ti4dfiVuF)OHUpY)ec(qbYl1pTISbrY)uhSHrYGiBWz1ZBN2sl4qjVIk35goi4dfi)KTDUXpRqZ1vir)Qs13F)tcu3iTpYpAE8i)ti4dfiVu)0kYgej)ZlwK8HcUdLjqHWHf(jB7CJFsaU1xuJaqY3pA3(i)ti4dfiVu)0kYgej)tbNKcCbr7ycr5gKGnE9Incojf4cI2XeIYLb2Oj2Cls)jB7CJFc3HYb463pA66r(NqWhkqEP(PvKnis(N(Jn(Jn6Gn2DPKDu4G7q5aC1nibB86fBodYYUk0CDfs0VQu5gKGnJHniGncojf4cI2XeIYLb2Oj2Ol)WMXWgVEXg225fuGaQjOWgnXgcOsbqknl0cT6NSTZn(PmqlhwiyTW3pAE2J8pHGpuG8s9tRiBqK8pVyrYhk4ouMafchwaBqaB0bBS7sj7OWvHMRRqI(vLkNayYDSbbSXFSXUlLSJchChkhGRobu5muyJMyJ)ydsXg0bByKmiYgCc4APxzOTCOmbuobh3GnEoSrxyZyyJxVyJ)yJGtsbUGODmHOCzGnAInSTZnChktGcHdl4S7sj7OaBqaBeCskWfeTJjeLldSz8yZTifBgdBg7NSTZn(5HYeOq4WcF)OH0h5FY2o34NzTUuUZnk8GG)je8HcKxQVF0q3h5FcbFOa5L6Nwr2Gi5FQd2CXIKpuWjzxAgAlYROCOmbkeoSWpzBNB8toIuFs5o347hnK4J8pHGpuG8s9tRiBqK8pLhe3DeqoTzJnAIcB8m)(jB7CJFkd0dLjW3pA62h5FcbFOa5L6Nwr2Gi5FQd2CXIKpuWjzxAgAlYROCOmbkeoSa2Ga2Od2CXIKpuWjzxAgAlYROa3HYb46pzBNB8tREEvfvlYBGVF009h5FY2o34NeOUHQCYg(je8HcKxQVF08WVh5FcbFOa5L6Nwr2Gi5FEgKLD7qxw5IGdTGBqYpzBNB8ZwVyhv0s58c((rZdpEK)je8HcKxQFAfzdIK)zZuiAhbQBuouMakhe8HcKFY2o34NTEXoQOLY5f893)0UlLSJIh5hnpEK)je8HcKxQFAfzdIK)PoyJ)ytZuiAhbQBKwhe8HceSXRxS5IfjFOGtYU0m0wKxrPcnJnE9InxSi5dfCJ4SZqBrEfLaQGkvyZyyJxVytNvO0BHKa2mES5wK(t225g)ScnxxHe9RkvF)OD7J8pHGpuG8s9tRiBqK8pBMcr7iqDJ06GGpuGGniGn(Jn6GnmsgezdoREE70wAbhk5vu5o3WbbFOabB86fB8hBS7sj7OWb3HYb4Qtavodf2Oj2CRFydcyJDxkzhfUdLjqHWHfCcOYzOWgnXgTwIRYJl2mg2m2pzBNB8Zk0CDfs0VQu99JMUEK)je8HcKxQFAfzdIK)PGtsbUGODmHOCW4MQwHniGne4mil7cOcQu5i7OaBqaB8hByBNxqbcOMGcB0eBiGkfaP0Sql0kSXRxSrWjPaxq0oMquUmWgnXg01pSzSFY2o34NbubvQ((rZZEK)je8HcKxQFAfzdIK)PoyJGtsbUGODmHOCW4MQw9t225g)mGkOs13pAi9r(NqWhkqEP(PvKnis(NNbzzxfAUUcj6xvQCcOYzOWgnXMBrk241l20zfk9wijGnJhBqx)(jB7CJFkz7CJVF0q3h5FcbFOa5L6NbxHFEXIKpuOKrdHk77fTPw(APDzv2Ks5odTfbW2Ef)KTDUXpVyrYhkuYOHqL99I2ulFT0USkBsPCNH2IayBVIVF0qIpY)KTDUXphuqjBOQ(je8HcKxQVF00TpY)ec(qbYl1pzBNB8tltPf225gfAQ6FstvxcUc)eukiSG67V)jHf3uuuwP)r(rZJh5FcbFOa5L6Nwr2Gi5FkpiUJnAIcB0T(HniGn(Jn6GnxSi5dfChktGcHdlGnE9In6Gn2DPKDu4ouMafchwWjaMChBg7NSTZn(jHf3uuuwP)7hTBFK)je8HcKxQFAfzdIK)jbodYYoclUPOOSsVBqYpzBNB8toIuFs5o347hnD9i)ti4dfiVu)0kYgej)tcCgKLDewCtrrzLE3GKFY2o34Nw98QkQwK3aF)93)8ceQCJhTB9ZdD3p09wK68t3VfP)CelIm0Q(jsa0F0lA6gO55HKWgSbz9a2KvjROXg5vGnOVeqMhOn6l2iap)HuaeSrTvaB4HERCdeSXQNdTGYH9HeCga24XTijSzCeQbjswrdeSHTDUb2G(kjT3ugKuKfS2ken6Rd7d7t3OkzfnqWgKi2W2o3aBOPQvoSVFYdT(v8ZzwhOCNBGeky5(NseRCsHF6jSb9GVwl2OBc1nWg0JHObb2NNWg9DlrHKqerTzRF44SBfrvwhOCNByfSCJOkRweX(8e24BiaS5wDxdS5w)8q3Xg0bB8qxijD5b2h2NNWgKaSiYqRcjH95jSbDWMXHkdTyJUju3aBKIYeqHnv(gqHn1v1yZ4CqChB0cbi4o3aBKmia6DSb9IMNh2qe5feydheSziKiasAB(qbnWMr6tRESzusPytwLW2gBA9a245pW0SVJnRm2ia7wRqq4o3q5W(8e2GoyZ4qLHwSb9BRq0dvSjvytSn2ia7wRqqac6jSzCcuSb9oO0JnJskfBoa2ia7wRqqac2WbbBA9a2OyzOVJnRm2mobk2GEhu6XglhX2yZbWgc0GTbc2CUJnmHSHYH9H95jSbjuphAbfsc7Ztyd6GnO)ecqWgKWnudvaBq)yTP1H95jSbDWg0lu3lGGnnl0cDjLXgREWEd2iVcSbnOcQuHn8jPzF3H95jSbDWg0lu3lGGn19cQq0ydFsA2jOWgzXwXgjICfzFhBgPhcSj2gBguabBKxb2G(Tvi6HQd7Ztyd6GnO)ecqWMXHcWgDJgQkSPxSbcc2SYyds4UuYokuydB7CdAQAh2NNWg0bBqc34cenqWg0h7UuYokqFWMEXg0h225goKGC2DPKDuG(GnJ0dcaByjsOPLpuWH9H95jSb984c2HgiyZbKxbGn2TE4gBoG2muoSb93AbjTcBInqh9SOkpqXg225gkSzd6Dh2hB7CdLtIaSB9WnkzkRUb7JTDUHYjra2TE4wAuiYdARq0CNBG9X2o3q5Kia7wpClnkeL3LG95jSzgSeL(TXgbNeS5mildeSr1CRWMdiVcaBSB9Wn2CaTzOWgoiyJebGos2UZql2KkSHSb4W(yBNBOCseGDRhULgfIQGLO0VDr1CRW(yBNBOCseGDRhULgfIs2o3a7JTDUHYjra2TE4wAuiwHMRRqI(vLknszu6WizqKn4S65TtBPfCOKxrL7Cdhe8HceSpSppHnONhxWo0abBGlqChB6ScytRhWg22RaBsf2WxCs5dfCyFSTZnuOiPsmiPX(yBNBOKgfI2nudvOuzTPf7JTDUHsAuiEXIKpuqJGRaQdLjqHWHf04IPdaQMPq0o5uO6YHUlXbbFOaXRxLeGslnl0cTYDOmbkeoSGhAIYFDHontHODTGtAzLlIHmCqWhkqgd7JTDUHsAuiEXIKpuqJGRaQrC2zOTiVIsavqLknUy6aGsh)1PzkeTlGkOsLdc(qbIxV2DPKDu4cOcQu5eatU71RDxkzhfUaQGkvobu5muA2zfk9wij41RDxkzhfUaQGkvobu5muAIU(ng2hB7CdL0Oq8IfjFOGgbxbus2LMH2I8kkvOznUy6aGsNMPq0ocu3iToi4dfiiy3Ls2rHRcnxxHe9Rkvobu5muJhDrqEqC3ra50MTM6Ype8xNlwK8HcUrC2zOTiVIsavqLkVET7sj7OWfqfuPYjGkNHA8E43yyFSTZnusJcXlwK8HcAeCfqjzxAgAlYROCOmbkeoSGgxmDaqDXIKpuWDOmbkeoSac(lpiUpEKisrNMPq0o5uO6YHUlXbbFOaXZDRFJH9X2o3qjnkeVyrYhkOrWvaLKDPzOTiVIcChkhGRACX0bavZuiAhbQBKwhe8Hcee0PzkeT7qZGuKhe3DqWhkqqWUlLSJchChkhGRobu5muJ3FTwIRYJRN72XqqEqC3ra50MTM36h2hB7CdL0Oq8IfjFOGgbxbuJ4SZqBrEffclUPOOSsVgxmDaq1mfI2ryXnffLv6DqWhkqqqNlwK8Hcoj7sZqBrEfLdLjqHWHfqqNlwK8Hcoj7sZqBrEfLk0mc2DPKDu4iS4MIIYk9UbjyFSTZnusJcXlwK8HcAeCfqnIZodTf5vuQBfIEOQXfthauntHOD1TcrpuDqWhkqqqNZGSSRUvi6HQBqc2hB7CdL0OqKKkXGKg7JTDUHsAuiAzkTW2o3OqtvRrWvaLDxkzhfAKYO0Ajobu5muO8d7JTDUHsAuikjT3ugKuKfS2keTgPmk5bXDhbKtB2AIsxif7JTDUHsAuiAzkTW2o3OqtvRrWvafHf3uuuwPxJugvZuiAhHf3uuuwP3bbFOabb)VyrYhk4gXzNH2I8kkewCtrrzLEVEjWzqw2ryXnffLv6Ddsgd7JTDUHsAuikgIcB7CJcnvTgbxbueOUrA1iLr1mfI2rG6gP1bbFOab7JTDUHsAuikgIcB7CJcnvTgbxbuXkQmf7d7JTDUHYbkfewqHYUHfIwWnqkYuUcyFSTZnuoqPGWckPrH4HUlPSYLwpuGaQ3X(yBNBOCGsbHfusJcrTdSGKCuw5cJKbX26X(yBNBOCGsbHfusJcr51oOasHrYGiBOCaUI9X2o3q5aLcclOKgfIsgeP89m0wouw1yFSTZnuoqPGWckPrHyRhkdXzhcsrEfwa7JTDUHYbkfewqjnkefPejuOKrrjHTa2hB7CdLdukiSGsAuioAfuYfKrraQn4WcyFSTZnuoqPGWckPrHyfQR4EzLl0bBskebWvLgPmk5bX9X7z(HWzqw2vHMRRqI(vLk3GeSpSp225gkNDxkzhfOQqZ1vir)QsLgPmkD8VzkeTJa1nsRdc(qbIxVxSi5dfCs2LMH2I8kkvOzVEVyrYhk4gXzNH2I8kkbubvQgZR3oRqP3cjHXFlsX(yBNBOC2DPKDuinkeRqZ1vir)QsLgPmQMPq0ocu3iToi4dfii4VomsgezdoREE70wAbhk5vu5o3WbbFOaXRx)T7sj7OWb3HYb4QtavodLM36hc2DPKDu4ouMafchwWjGkNHstTwIRYJ7yJH9X2o3q5S7sj7OqAuigqfuPsJugLGtsbUGODmHOCW4MQwHabodYYUaQGkvoYokqWF225fuGaQjO0KaQuaKsZcTqR86vWjPaxq0oMquUm0eD9BmSp225gkNDxkzhfsJcXaQGkvAKYO0rWjPaxq0oMquoyCtvRW(yBNBOC2DPKDuinkeLSDUHgPmQZGSSRcnxxHe9Rkvobu5muAEls96TZku6Tqsy8ORFyFSTZnuo7UuYokKgfIdkOKnu1i4kG6IfjFOqjJgcv23lAtT81s7YQSjLYDgAlcGT9kW(yBNBOC2DPKDuinkehuqjBOQW(yBNBOC2DPKDuinkeTmLwyBNBuOPQ1i4kGcukiSGc7d7JTDUHYryXnffLv6rryXnffLv61iLrjpiURjkDRFi4VoxSi5dfChktGcHdl41Ro2DPKDu4ouMafchwWjaMCFmSp225gkhHf3uuuwPxAuiYrK6tk35gAKYOiWzqw2ryXnffLv6DdsW(yBNBOCewCtrrzLEPrHOvpVQIQf5nGgPmkcCgKLDewCtrrzLE3GeSpSp225gkhbQBKwueGB9f1iaKOrkJ6IfjFOG7qzcuiCybSp225gkhbQBKwPrHiChkhGRAKYOeCskWfeTJjeLBqIxVcojf4cI2XeIYLHM3IuSp225gkhbQBKwPrHOmqlhwiyTGgPmk)9xh7UuYokCWDOCaU6gK417zqw2vHMRRqI(vLk3GKXqqWjPaxq0oMquUm0ux(nMxVSTZlOabutqPjbuPaiLMfAHwH9X2o3q5iqDJ0knkepuMafchwqJug1fls(qb3HYeOq4WciOJDxkzhfUk0CDfs0VQu5eatUJG)2DPKDu4G7q5aC1jGkNHst)rk6WizqKn4eW1sVYqB5qzcOCcoUXZPRX861FbNKcCbr7ycr5Yqt225gUdLjqHWHfC2DPKDuGGGtsbUGODmHOCzm(Br6yJH9X2o3q5iqDJ0knkeZADPCNBu4bbJ9X2o3q5iqDJ0knke5is9jL7Cdnszu6CXIKpuWjzxAgAlYROCOmbkeoSa2hB7CdLJa1nsR0OqugOhktanszuYdI7ociN2S1eLN5h2hB7CdLJa1nsR0Oq0QNxvr1I8gqJugLoxSi5dfCs2LMH2I8kkhktGcHdlGGoxSi5dfCs2LMH2I8kkWDOCaUI95jSHTDUHYrG6gPvAuikd0IyqPxJugvZuiAhbQBuouMakhe8Hcee0XUlLSJchChkhGRobWK7i4Vvpl0cku361R)cojf4cI2v3lOcr7Yqtp8dbbNKcCbr7ycr5Yqtp8BSXW(yBNBOCeOUrALgfIeOUHQCYgW(yBNBOCeOUrALgfITEXoQOLY5fOrkJ6mil72HUSYfbhAb3GeSppHnSTZnuocu3iTsJcrzGwedk9AKYOQ7fuHODKu1Cybn9aPE9EgKLD7qxw5IGdTGBqc2NNWg225gkhbQBKwPrH4feAb5bAraTa4wJugvDVGkeTJKQMdlOPhif7JTDUHYrG6gPvAui26f7OIwkNxGgPmQMPq0ocu3OCOmbuoi4dfiyFyFSTZnuUyfvMI6ccTG8aTiGwaCRrkJQzkeTRUvi6HQdc(qbccNbzzNebiHfaXr2rbcDwbn9a7JTDUHYfROYuPrHOmqlIbLEnszuxSi5dfCJ4SZqBrEfL6wHOhQi4Vvpl0cku361R)cojf4cI2v3lOcr7Yqtp8dbbNKcCbr7ycr5Yqtp8BSXW(8e2W2o3q5IvuzQ0OqugOfXGsVgPmQMPq0ozGwQSQbXDhe8Hcee83QNfAbfQB961FbNKcCbr7Q7fuHODzOPh(HGGtsbUGODmHOCzOPh(n2yyFSTZnuUyfvMknkeLbA5WcbRf0iLrPZfls(qb3io7m0wKxrPUvi6Hkc(Z2oVGceqnbLMeqLcGuAwOfALxVcojf4cI2XeIYLHM6YVXW(yBNBOCXkQmvAuisaU1xuJaqIgPmQlwK8HcUdLjqHWHfW(yBNBOCXkQmvAuiM16s5o3OWdcg7JTDUHYfROYuPrHiChkhGRAKYOyBNxqbcOMGstpqWFDeCskWfeTJjeLdg3u1kVEfCskWfeTJjeLBqYyiOZfls(qb3io7m0wKxrPUvi6Hk2hB7CdLlwrLPsJcXdLjqHWHf0iLrDXIKpuWDOmbkeoSa2hB7CdLlwrLPsJcrzGEOmb0iLrjpiU7iGCAZwtuEMFyFSTZnuUyfvMknkeH7q5aCvJugLontHODhAgKI8G4Udc(qbcc6CXIKpuWnIZodTf5vuiS4MIIYk9ii4KuGliAhtikxgAY2o3Wb3HYb4QZUlLSJcSp225gkxSIktLgfICeP(KYDUHgPmk)BMcr7iqDJYHYeq5GGpuG41RoxSi5dfCJ4SZqBrEfL6wHOhQE9kpiU7iGCAZE86YpVEpdYYUk0CDfs0VQu5eqLZqnEKogc6CXIKpuWjzxAgAlYROCOmbkeoSac6CXIKpuWnIZodTf5vuiS4MIIYk9yFSTZnuUyfvMknkeT65vvuTiVb0iLr5FZuiAhbQBuouMakhe8HceVE15IfjFOGBeNDgAlYROu3ke9q1Rx5bXDhbKtB2Jxx(ngc6CXIKpuWjzxAgAlYROuHMrqNlwK8Hcoj7sZqBrEfLdLjqHWHfqqNlwK8HcUrC2zOTiVIcHf3uuuwPh7JTDUHYfROYuPrHiChkhGRAKYOAMcr7o0mif5bXDhe8HceeeCskWfeTJjeLldnzBNB4G7q5aC1z3Ls2rb2hB7CdLlwrLPsJcrcu3qvozdyFEcByBNBOCXkQmvAuikd0IyqPxJugLontHOD1TcrpuDqWhkqqqWjPaxq0U6EbviAxgAA1ZcTGYZ5HFi0mfI2rG6gLdLjGYbbFOab7JTDUHYfROYuPrHOmqpuMaAKYOQ7fuHODKu1Cybn9aPE9EgKLD7qxw5IGdTGBqc2NNWg225gkxSIktLgfIYaTigu61iLrv3lOcr7iPQ5WcA6bs961)ZGSSBh6YkxeCOfCdsqqNMPq0U6wHOhQoi4dfiJH95jSHTDUHYfROYuPrH4feAb5bAraTa4wJugvDVGkeTJKQMdlOPhif7JTDUHYfROYuPrHyRxSJkAPCEbAKYOAMcr7iqDJYHYeq5GGpuG893)d]] )


end
