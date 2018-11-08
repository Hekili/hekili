-- DemonHunterHavoc.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


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
            value = 8
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

        mana_break = 813, -- 203704
        detainment = 812, -- 205596
        rain_from_above = 811, -- 206803
        demonic_origins = 810, -- 235893
        mana_rift = 809, -- 235903
        eye_of_leotheras = 807, -- 206649
        glimpse = 1204, -- 203468
        cover_of_darkness = 1206, -- 227635
        reverse_magic = 806, -- 205604
        unending_hatred = 1218, -- 213480
        solitude = 805, -- 211509
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
        -- Demonic Origins PvP Talent.
        demonic_origins = {
            id = 235894,
            duration = 3600,
            max_stack = 1,
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
            duration = function () return buff.demonic_origins.up and 15 or 30 end,
            max_stack = 1,
            meta = {
                extended_by_demonic = function ()
                    return talent.demonic.enabled and ( buff.metamorphosis.up and buff.metamorphosis.duration % 15 > 0 and buff.metamorphosis.duration > ( action.eye_beam.cast + 8 ) )
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
                if level < 116 and set_bonus.tier20_2pc == 1 and target.within8 then gain( 20, 'fury' ) end
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

            usable = function () return debuff.dispellable_magic.up end,
            handler = function ()
                removeDebuff( "dispellable_magic" )
                gain( 20, "fury" )
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
                if level < 116 and set_bonus.tier20_2pc == 1 and target.within8 then gain( 20, "fury" ) end
            end,
        },
        

        demons_bite = {
            id = 162243,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -20,
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

            usable = function () return target.casting end,
            handler = function ()
                interrupt()
                gain( 30, "fury" )
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
            
            usable = function () return not prev_gcd[1].fel_rush end,            
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

            spend = -40,
            spendType = "fury",
            
            startsCombat = true,
            texture = 1344646,

            -- usable = function () return target.within15 end,        
            handler = function ()
                setDistance( 5 )
            end,
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
                gain( 8, "fury" )
            end,
        },
        

        --[[ imprison = {
            id = 217832,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1380368,
            
            handler = function ()
            end,
        }, ]]
        

        metamorphosis = {
            id = 191427,
            cast = 0,
            cooldown = function () return buff.demonic_origins.up and 120 or 240 end,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 1247262,
            
            handler = function ()
                applyBuff( "metamorphosis" )
                last_metamorphosis = query_time
                stat.haste = stat.haste + 25
                setDistance( 5 )
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
            
            handler = function ()
                if target.within8 then
                    applyDebuff( "target", "vengeful_retreat" )
                    if talent.momentum.enabled then applyBuff( "prepared" ) end
                end
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


    spec:RegisterPack( "Havoc", 20180929.2053, [[dO0c3aqiivpIQGnPi9jQssJIQkNIQuRsLQKxrf1SiLClvsSlk9lvIHHQ0XivSmvs9mQinnQi6AQuzBur4BQuvghvvPZrvvzDuvvnpQsCpizFKsDqQQIwiPspKQqAIufIlQsvkBuLKsFKQKOrQssoPkjvRKQYmvPkv3KQQWoHugQkvvlLQq9uiMkQIRsvs1xvjPyVi(RedMKdtSyv8yfMmuxgSzu5ZuHrtQ60IEnvrZgLBlPDl8BLgoQQJtvsy5i9CkMUuxNkTDf13veJxLQ48QuwpvjL5tk2VQMOdHhccwAGG218QJ)YR)DT)zVM37UpE1HG034dee(YWtXbqqcPceKRsM3bbHVCJTcMWdbXSU0bqq03nFJ)F5IJS17ESJTEXKvxM05gdQW1xmzDC5W2ZLdNCfmmFHpD5sgyUC)uWJLeBUC)ECXJa1nkxLB0aTCvY8oSMSoiih3K1x9GCiiyPbcAxZRo(lV(31(N9AEVthcIHpmiOD39DFee9jgdb5qqWGzqq8WRUkzEhVYJa1nE1v5gnqFFE4v67MVX)VCXr26Dp2XwVyYQlt6CJbv46lMSoUCy75YHtUcgMVWNUCjdmxUFk4XsInxUFpU4rG6gLRYnAGwUkzEhwtwhVpp8keGFd1dqF11(NwV6AE1XFF1vEL)6)35FV6(9hVV3NhE1vJqJmCy8)3NhE1vELx3KHJx5rG6gVsxMGbZRQING5v110V6Q1LE7voGaOsNB8k(UuGD7vEmAELVctZziELe4x5g8PaohTCyGwVAI(CO)vtsg7vzLVm6x16Hx5v4kSSV9QL7vuyS1keyPZnm2337ZdVYJQxchGX)FFE4vx5v(tmgWVYJUHXTcVYFioYH995HxDLx5XqDNb8RAH6a6sY9QHEy45R4w6RqdQGjnVsojl7B23NhE1vELhd1DgWVQUZqfI(vYjzzNG5vC0T(k(0CPzF7vt0dXRITFLRbWVIBPVYFSviA3Q995HxDLx5pXya)kVUbE1vVHQ5v9(kiWVA5ELhDxgENeMxjJo3GLM2sqyPPneEiiXsRcJWdbnDi8qqGqomat0LGmOzd0uiiTWGOT1Tcr7wTqihgGF10xDC54S8PaFHcylENeVA6R6ScVs7xPdbrgDUbbzgchaNlRqHMcstAcAxt4HGaHCyaMOlbzqZgOPqq87vZcnLddStKSZWrHBPL6wHODRVsJMx1cdI2YbSsvmnqVzHqoma)kVF10x53Rg6fQdW8kuV66xPrZR87vujXfygI2w3zOcrBZ4vA)kD49vtFfvsCbMHOTcgBSz8kTFLo8(kVFL3eez05geeoGvOUg9KMGMtj8qqGqomat0LGmOzd0uiiO)QzHMYHb2js2z4OWT0sDRq0U1xn9v(9kz05muGaQjyEL2VcdMKc4sluhqBELgnVIkjUaZq0wbJn2mEL2VYP8(kVjiYOZniiCaRCekvCaKMGMts4HGaHCyaMOlbzqZgOPqqMfAkhgypmbdfSedGGiJo3GGGbP1xmtaGpPjODhHhcIm6CdcswRlt6CJI4sfcceYHbyIUKMGMtq4HGaHCyaMOlbzqZgOPqqKrNZqbcOMG5vA)kDE10x53Rq)vujXfygI2kySXc3tAAZR0O5vujXfygI2kySX6Y)vE)QPVc9xnl0uomWorYodhfULwQBfI2TsqKrNBqqGBq5asL0e0UpcpeeiKddWeDjidA2anfcYSqt5Wa7HjyOGLyaeez05geKdtWqblXainbn)LWdbbc5WamrxcYGMnqtHGG(RAHbrBRBfI2TAHqoma)QPVc9x1cdI2IH6gLdtWGXcHCya(vtFL41aA2G1noRBGld9YASqihgGjiYOZniiCaRqDn6jnbn)JWdbbc5WamrxcYGMnqtHGW5sVzXaxoY(vAJ6vojVeez05geeoGDycginbnD4LWdbbc5WamrxcYGMnqtHGG(RAHbrBpSmWfox6nleYHb4xn9vO)QzHMYHb2js2z4OWT0cwOEwmmXO)vtFfvsCbMHOTcgBSz8kTF1yxgENeeez05gee4guoGujnbnD0HWdbbc5WamrxcYGMnqtHG43RAHbrBXqDJYHjyWyHqoma)knAEf6VAwOPCyGDIKDgokClTu3keTB9vA08kox6nlg4Yr2VYlVYP8(knAE1XLJZwHwQlLV(1KglfQsgMx5LxD3R8(vtFf6VAwOPCyGL)USmCu4wA5WemuWsmGxn9vO)QzHMYHb2js2z4OWT0cwOEwmmXONGiJo3GGirK6tM05gKMGMoxt4HGaHCyaMOlbzqZgOPqq87vTWGOTyOUr5WemySqihgGFLgnVc9xnl0uomWorYodhfULwQBfI2T(knAEfNl9MfdC5i7x5Lx5uEFL3VA6Rq)vZcnLddS83LLHJc3slvOLxn9vO)QzHMYHbw(7YYWrHBPLdtWqblXaE10xH(RMfAkhgyNizNHJc3slyH6zXWeJEcIm6CdcYqVSMIPPPNaPjOPJtj8qqGqomat0LGmOzd0uiiTWGOThwg4cNl9Mfc5Wa8RM(kQK4cmdrBfm2yZ4vA)QXUm8ojiiYOZniiWnOCaPsAcA64KeEiiYOZniiyOUHPCYgiiqihgGj6sAcA6ChHhcceYHbyIUeKbnBGMcbPUZqfI2IttlXaEL2VsN7ELgnV64YXzx3USCfQeoaRlFcIm6CdcchWombdKMGMoobHhcceYHbyIUeKbnBGMcbPfgeTfd1nkhMGbJfc5WambrgDUbbP1t3jfhmjNbstAccg4exwt4HGMoeEiiYOZniiIBVfPBz4jbbc5Wamrxstq7AcpeKzHwcPceKdtWqblXaiiqihgGj6sqKrNBqqMfAkhgqqMfMlqqAHbrB5sQPlh2UyleYHb4xPrZRmqxoB4ASDc0R5T4K8hVsJMxz4dmwPfQdOn2dtWqblXa05vAJ6v(9kN(QR8Qwyq02MkjRSCfQBgwiKddWVYBstqZPeEiiZcTesfiitKSZWrHBPLaQGjneeiKddWeDjiYOZniiZcnLddiiZcZfiiO)k)Ef6VQfgeTnGkysJfc5Wa8R0O5vJDz4DsydOcM0yPGGV9knAE1yxgENe2aQGjnwkuLmmVs7x1c1b02oRqP3coHxPrZRg7YW7KWgqfmPXsHQKH5vA)kNG3x5nPjO5KeEiiZcTesfii83LLHJc3slvOfcceYHbyIUeez05geKzHMYHbeKzH5cee0FvlmiAlgQBKdleYHb4xn9vJDz4DsyRql1LYx)AsJLcvjdZR8YRCIxn9vCU0BwmWLJSFL2VYP8(QPVYVxH(RMfAkhgyNizNHJc3slbubtAELgnVASldVtcBavWKglfQsgMx5LxPdVVYBstq7ocpeKzHwcPcee(7YYWrHBPLdtWqblXaiiqihgGj6sqKrNBqqMfAkhgqqMfMlqqMfAkhgypmbdfSed4vtFLFVIZLE7vE5v33DV6kVQfgeTLlPMUCy7ITqihgGF196vxZ7R8M0e0CccpeKzHwcPceKjs2z4OWT0cwOEwmmXONGaHCyaMOlbrgDUbbzwOPCyabzwyUabPfgeTfluplgMy0BHqoma)QPVc9xnl0uomWYFxwgokClTCycgkyjgWRM(k0F1Sqt5Wal)Dzz4OWT0sfA5vtF1yxgENewSq9SyyIrV1LpPjODFeEiiZcTesfiitKSZWrHBPL6wHODReeiKddWeDjiYOZniiZcnLddiiZcZfiiTWGOT1Tcr7wTqihgGF10xH(RoUCC26wHODRwx(KMGM)s4HGiJo3GGGtd1LFtqGqomat0L0e08pcpeez05geKXgg3kuQIJCqqGqomat0L0e00HxcpeeiKddWeDjidA2anfcIJb2sHQKH5vOEfVeez05geKHWyfz05gfwAAcclnDjKkqqg7YW7KG0e00rhcpeeiKddWeDjidA2anfccNl9MfdC5i7xPnQx507iiYOZnii8ZHNfx(foQ4OcrtAcA6CnHhcceYHbyIUeKbnBGMcbPfgeTfluplgMy0BHqoma)QPVYVxnl0uomWorYodhfULwWc1ZIHjg9VsJMxHHJlhNfluplgMy0BD5)kVjiYOZniidHXkYOZnkS00eewA6sivGGGfQNfdtm6jnbnDCkHhcceYHbyIUeKbnBGMcbPfgeTfd1nYHfc5WambrgDUbbH6gfz05gfwAAcclnDjKkqqWqDJCqAcA64KeEiiqihgGj6sqKrNBqqOUrrgDUrHLMMGWstxcPceKyPvHrAstq4tHXwpst4HGMoeEiiqihgGj6sAcAxt4HGaHCyaMOlPjO5ucpeeiKddWeDjnbnNKWdbbc5Wamrxstq7ocpeez05gee(BNBqqGqomat0L0e0Cccpeez05geKk0sDP81VM0qqGqomat0L0KMGGH6g5GWdbnDi8qqGqomat0LGmOzd0uiiYOZzOabutW8kTFfgmjfWLwOoG28knAEfvsCbMHOTcgBSz8kTFLt5LGiJo3GGWbSYrOuXbqAcAxt4HGaHCyaMOlbzqZgOPqqMfAkhgypmbdfSedGGiJo3GGGbP1xmtaGpPjO5ucpeeiKddWeDjidA2anfcc6V64YXzRql1LYx)AsJfUNgcmGlNBfmu3ihVA6R87vujXfygI2kySX6Y)vA08kQK4cmdrBfm2yZ4vA)QRV7vEtqKrNBqqGBq5asL0e0CscpeeiKddWeDjidA2anfcYSqt5Wa7HjyOGLyaVA6Rq)vJDz4DsyRql1LYx)AsJLcc(2RM(k)E1yxgENew4guoGuTuOkzyEL2VYVxD3RUYReVgqZgSuyEzZz4OCycgmwQeE(Q71RC6R8(vA08k)EfvsCbMHOTcgBSz8kTF1yxgENeVA6ROsIlWmeTvWyJnJx5LxD9DVY7x5nbrgDUbb5WemuWsmastq7ocpeez05geKSwxM05gfXLkeeiKddWeDjnbnNGWdbbc5WamrxcYGMnqtHGW5sV9kV8kNK3xPrZR87vhxooBfAPUu(6xtAS4Ds8QPVIZLEZIbUCK9R0g1RCsEFL3eez05geeoGDycginbT7JWdbbc5WamrxcYGMnqtHG43RAHbrBpSmWfox6nleYHb4xPrZR4CP3SyGlhz)kV8kNY7R0O5vhxooBfAPUu(6xtASuOkzyELxE1DVY7xn9vO)QzHMYHbw(7YYWrHBPLdtWqblXaiiYOZniiseP(KjDUbPjO5VeEiiqihgGj6sqg0SbAkee)EvlmiA7HLbUW5sVzHqoma)knAEfNl9MfdC5i7x5Lx5uEFL3VA6Rq)vZcnLddS83LLHJc3slvOLxn9vO)QzHMYHbw(7YYWrHBPLdtWqblXaiiYOZniid9YAkMMMEcKMGM)r4HGaHCyaMOlbzqZgOPqqAHbrBXqDJYHjyWyHqoma)QPVc9xn2LH3jHfUbLdivlfe8Txn9v(9QHEH6amVc1RU(vA08k)EfvsCbMHOT1DgQq02mEL2VshEF10xrLexGziARGXgBgVs7xPdVVY7x5nbrgDUbbHdyfQRrpPjOPdVeEiiqihgGj6sqg0SbAkee0FvlmiAlgQBuombdgleYHb4xn9vO)QXUm8ojSWnOCaPAPGGV9QPVs8AanBW6gN1nWLHEznwQeE(kTFfVeez05geeoGvOUg9KMGMo6q4HGiJo3GGGH6gMYjBGGaHCyaMOlPjOPZ1eEiiqihgGj6sqg0SbAkeKJlhNDD7YYvOs4aSU8jiYOZniiTE6oP4Gj5mqAcA64ucpeeiKddWeDjidA2anfcslmiAlgQBuombdgleYHbycIm6CdcsRNUtkoysodKM0eKXUm8oji8qqthcpeeiKddWeDjidA2anfcc6VYVx1cdI2IH6g5WcHCya(vA08QzHMYHbw(7YYWrHBPLk0YR0O5vZcnLddStKSZWrHBPLaQGjnVY7xPrZRAH6aABNvO0BbNWR8YRU(ocIm6CdcsfAPUu(6xtAinbTRj8qqGqomat0LGmOzd0uiiTWGOTyOUroSqihgGF10xDC54SvOL6s5RFnPX6YNGiJo3GGuHwQlLV(1KgstqZPeEiiqihgGj6sqg0SbAkeeQK4cmdrBfm2yH7jnT5vtFfgoUCC2aQGjnw8ojE10x53RKrNZqbcOMG5vA)kmyskGlTqDaT5vA08kQK4cmdrBfm2yZ4vA)kNG3x5nbrgDUbbjGkysdPjO5KeEiiqihgGj6sqg0SbAkee0FfvsCbMHOTcgBSW9KM2qqKrNBqqcOcM0qAcA3r4HGaHCyaMOlbzqZgOPqqoUCC2k0sDP81VM0yPqvYW8kTF1139knAEvluhqB7ScLEl4eELxELtWlbrgDUbbH)25gKMGMtq4HGiJo3GG4AGs2q1qqGqomat0L0KMGGfQNfdtm6j8qqthcpeeiKddWeDjidA2anfccNl92R0g1R8xEF10x53Rq)vZcnLddShMGHcwIb8knAEf6VASldVtc7HjyOGLyawki4BVYBcIm6CdccwOEwmmXON0e0UMWdbbc5WamrxcYGMnqtHGGHJlhNfluplgMy0BD5tqKrNBqqKis9jt6CdstqZPeEiiqihgGj6sqg0SbAkeemCC54SyH6zXWeJERlFcIm6CdcYqVSMIPPPNaPjnPjiZa1KBqq7AE1XF51)U2)SxZ7D6qqMi0idhgcYvJ)0Jr7QJMxP))QxXJE4vzL)s7xXT0x5vXaN4YAV6ROGxHBsb8RmBfEL42BvAa)QHEjCag777Epd4v64)VYRhgx(8xAd4xjJo34vEvXT3I0Tm80RAFF37zaVshD8)x51dJlF(lTb8RKrNB8kVk)C4zXLFHJkoQq0Ev7779D1R8xAd4x5eVsgDUXRyPPn23hbrCB9lLGGKvxM05gEuQW1ee(0LlzabXdV6QK5D8kpcu34vxLB0a995HxPVB(g))YfhzR39yhB9IjRUmPZnguHRVyY64YHTNlho5kyy(cF6YLmWC5(PGhlj2C5(94IhbQBuUk3ObA5QK5DynzD8(8WRqa(nupa9vx7FA9QR5vh)9vx5v(R)FNoV6(9hVV3NhE1vJqJmCy8)3NhE1vELx3KHJx5rG6gVsxMGbZRQING5v110V6Q1LE7voGaOsNB8k(UuGD7vEmAELVctZziELe4x5g8PaohTCyGwVAI(CO)vtsg7vzLVm6x16Hx5v4kSSV9QL7vuyS1keyPZnm2337ZdVYJQxchGX)FFE4vx5v(tmgWVYJUHXTcVYFioYH995HxDLx5XqDNb8RAH6a6sY9QHEy45R4w6RqdQGjnVsojl7B23NhE1vELhd1DgWVQUZqfI(vYjzzNG5vC0T(k(0CPzF7vt0dXRITFLRbWVIBPVYFSviA3Q995HxDLx5pXya)kVUbE1vVHQ5v9(kiWVA5ELhDxgENeMxjJo3GLM2((EFE4v3B3dmCBa)QdWTu4vJTEK(vhWrgg7R8NJbWVnVk24k6fALZL9kz05gMxTb7M99jJo3Wy5tHXwpsJIJjgpFFYOZnmw(uyS1J0oJ6I46OcrlDUX7tgDUHXYNcJTEK2zux42f)(8WRqcHVr)2VIkj(vhxooa)ktlT5vhGBPWRgB9i9RoGJmmVsc8R4tHRWF7odhVknVcVbyFFYOZnmw(uyS1J0oJ6Ije(g9BxmT0M3Nm6CdJLpfgB9iTZOUWF7CJ3Nm6CdJLpfgB9iTZOUuHwQlLV(1KM337ZdV6E7EGHBd4xbZa92R6ScVQ1dVsg9sFvAELmljtomW((KrNByqjU9wKULHNVpz05ggNrDzwOPCyGwHubuhMGHcwIbO1SWCbuTWGOTCj10LdBxSfc5WaSgngOlNnCn2ob618wCs(dnAm8bgR0c1b0g7HjyOGLya6Onk)C6vAHbrBBQKSYYvOUzyHqoma797tgDUHXzuxMfAkhgOviva1ej7mCu4wAjGkysJwZcZfqHUFO3cdI2gqfmPXcHCyawJMXUm8ojSbubtASuqW30OzSldVtcBavWKglfQsggTBH6aABNvO0BbNGgnJDz4DsydOcM0yPqvYWOTtWR3Vpz05ggNrDzwOPCyGwHubu83LLHJc3slvOfTMfMlGc9wyq0wmu3ihwiKddWth7YW7KWwHwQlLV(1KglfQsggV4et5CP3SyGlhzRTt5DQFOpl0uomWorYodhfULwcOcM0OrZyxgENe2aQGjnwkuLmmErhE9(9jJo3W4mQlZcnLdd0kKkGI)USmCu4wA5WemuWsmaTMfMlGAwOPCyG9WemuWsmGP(X5sV5L77UR0cdI2YLutxoSDXwiKddW3RR5173Nm6CdJZOUml0uomqRqQaQjs2z4OWT0cwOEwmmXOxRzH5cOAHbrBXc1ZIHjg9wiKddWtrFwOPCyGL)USmCu4wA5WemuWsmGPOpl0uomWYFxwgokClTuHwMo2LH3jHfluplgMy0BD5)(KrNByCg1LzHMYHbAfsfqnrYodhfULwQBfI2TQ1SWCbuTWGOT1Tcr7wTqihgGNI(XLJZw3keTB16Y)9jJo3W4mQl40qD53Vpz05ggNrDzSHXTcLQ4ihVpz05ggNrDzimwrgDUrHLMwRqQaQXUm8oj0k5q5yGTuOkzyqX77tgDUHXzux4NdplU8lCuXrfIwRKdfNl9MfdC5iBTr507EFYOZnmoJ6YqySIm6CJclnTwHubuyH6zXWeJETsouTWGOTyH6zXWeJEleYHb4P(nl0uomWorYodhfULwWc1ZIHjg9A0GHJlhNfluplgMy0BD5797tgDUHXzuxOUrrgDUrHLMwRqQakmu3ihALCOAHbrBXqDJCyHqoma)(KrNByCg1fQBuKrNBuyPP1kKkGkwAvyVV3Nm6CdJDSldVtcuvOL6s5RFnPrRKdf6(1cdI2IH6g5WcHCyawJMzHMYHbw(7YYWrHBPLk0IgnZcnLddStKSZWrHBPLaQGjnERrtluhqB7ScLEl4e8Y139(KrNBySJDz4Ds4mQlvOL6s5RFnPrRKdvlmiAlgQBKdleYHb4PhxooBfAPUu(6xtASU8FFYOZnm2XUm8ojCg1LaQGjnALCOOsIlWmeTvWyJfUN00MPy44YXzdOcM0yX7KyQFYOZzOabutWOngmjfWLwOoG2OrdvsCbMHOTcgBSzOTtWR3Vpz05gg7yxgENeoJ6savWKgTsouOtLexGziARGXglCpPPnVpz05gg7yxgENeoJ6c)TZn0k5qDC54SvOL6s5RFnPXsHQKHr7RVtJMwOoG22zfk9wWj4fNG33Nm6CdJDSldVtcNrDX1aLSHQ599(KrNBySyH6zXWeJEuyH6zXWeJETsouCU0BAJYF5DQFOpl0uomWEycgkyjgGgnOp2LH3jH9WemuWsmalfe8nVFFYOZnmwSq9SyyIrVZOUirK6tM05gALCOWWXLJZIfQNfdtm6TU8FFYOZnmwSq9SyyIrVZOUm0lRPyAA6jOvYHcdhxoolwOEwmmXO36Y)99(KrNBySyOUroqXbSYrOuXbOvYHsgDodfiGAcgTXGjPaU0c1b0gnAOsIlWmeTvWyJndTDkVVpz05gglgQBKdNrDbdsRVyMaaFTsouZcnLddShMGHcwIb8(KrNBySyOUroCg1f4guoGu1k5qH(XLJZwHwQlLV(1KglCpneyaxo3kyOUroM6hvsCbMHOTcgBSU81OHkjUaZq0wbJn2m0(678(9jJo3WyXqDJC4mQlhMGHcwIbOvYHAwOPCyG9WemuWsmGPOp2LH3jHTcTuxkF9Rjnwki4Bt9BSldVtclCdkhqQwkuLmmA73Dxr8AanBWsH5LnNHJYHjyWyPs459YPERrJFujXfygI2kySXMH2JDz4DsmLkjUaZq0wbJn2m8Y135T3Vpz05gglgQBKdNrDjR1LjDUrrCPY7tgDUHXIH6g5Wzux4a2HjyqRKdfNl9MxCsE1OXVJlhNTcTuxkF9Rjnw8ojMY5sVzXaxoYwBuojVE)(KrNBySyOUroCg1fjIuFYKo3qRKdLFTWGOThwg4cNl9Mfc5WaSgnCU0BwmWLJS9It5vJMJlhNTcTuxkF9RjnwkuLmmE5oVNI(Sqt5Wal)Dzz4OWT0YHjyOGLyaVpz05gglgQBKdNrDzOxwtX000tqRKdLFTWGOThwg4cNl9Mfc5WaSgnCU0BwmWLJS9It517POpl0uomWYFxwgokClTuHwMI(Sqt5Wal)Dzz4OWT0YHjyOGLyaVpz05gglgQBKdNrDHdyfQRrVwjhQwyq0wmu3OCycgmwiKddWtrFSldVtclCdkhqQwki4Bt9BOxOoadQR1OXpQK4cmdrBR7muHOTzOTo8oLkjUaZq0wbJn2m0whE9273Nm6CdJfd1nYHZOUWbSc11OxRKdf6TWGOTyOUr5WemySqihgGNI(yxgENew4guoGuTuqW3MkEnGMnyDJZ6g4YqVSglvcp1M33Nm6CdJfd1nYHZOUGH6gMYjB49jJo3WyXqDJC4mQlTE6oP4Gj5mOvYH64YXzx3USCfQeoaRl)3NhELm6CdJfd1nYHZOUWbSc11OxRKdvDNHkeTfNMwIbOTo3PrZXLJZUUDz5kujCawx(Vpp8kz05gglgQBKdNrDzgchaNlRqHMcsRvYHQUZqfI2IttlXa0wN7EFYOZnmwmu3ihoJ6sRNUtkoysodALCOAHbrBXqDJYHjyWyHqoma)(EFYOZnm2yPvHHAgchaNlRqHMcsRvYHQfgeTTUviA3Qfc5Wa80JlhNLpf4luaBX7KyANvqBDEFYOZnm2yPvH5mQlCaRqDn61k5q53Sqt5Wa7ej7mCu4wAPUviA3QgnTWGOTCaRuftd0BwiKddWEp1VHEH6amOUwJg)OsIlWmeTTUZqfI2MH26W7uQK4cmdrBfm2yZqBD41BVFFYOZnm2yPvH5mQlCaRCekvCaALCOqFwOPCyGDIKDgokClTu3keTBDQFYOZzOabutWOngmjfWLwOoG2OrdvsCbMHOTcgBSzOTt5173Nm6CdJnwAvyoJ6cgKwFXmba(ALCOMfAkhgypmbdfSed49jJo3WyJLwfMZOUK16YKo3OiUu59jJo3WyJLwfMZOUa3GYbKQwjhkz05muGaQjy0wNP(HovsCbMHOTcgBSW9KM2OrdvsCbMHOTcgBSU89Ek6ZcnLddStKSZWrHBPL6wHODRVpz05ggBS0QWCg1LdtWqblXa0k5qnl0uomWEycgkyjgW7tgDUHXglTkmNrDHdyfQRrVwjhk0BHbrBRBfI2TAHqomapf9wyq0wmu3OCycgmwiKddWtfVgqZgSUXzDdCzOxwJfc5Wa87tgDUHXglTkmNrDHdyhMGbTsouCU0BwmWLJS1gLtY77tgDUHXglTkmNrDbUbLdivTsouO3cdI2EyzGlCU0BwiKddWtrFwOPCyGDIKDgokClTGfQNfdtm6NsLexGziARGXgBgAp2LH3jX7tgDUHXglTkmNrDrIi1NmPZn0k5q5xlmiAlgQBuombdgleYHbynAqFwOPCyGDIKDgokClTu3keTBvJgox6nlg4Yr2EXP8QrZXLJZwHwQlLV(1KglfQsggVCN3trFwOPCyGL)USmCu4wA5WemuWsmGPOpl0uomWorYodhfULwWc1ZIHjg9Vpz05ggBS0QWCg1LHEznftttpbTsou(1cdI2IH6gLdtWGXcHCyawJg0NfAkhgyNizNHJc3sl1Tcr7w1OHZLEZIbUCKTxCkVEpf9zHMYHbw(7YYWrHBPLk0Yu0NfAkhgy5VlldhfULwombdfSedyk6ZcnLddStKSZWrHBPfSq9SyyIr)7tgDUHXglTkmNrDbUbLdivTsouTWGOThwg4cNl9Mfc5Wa8uQK4cmdrBfm2yZq7XUm8ojEFYOZnm2yPvH5mQlyOUHPCYgEFE4vYOZnm2yPvH5mQlCaRqDn61k5qHElmiABDRq0UvleYHb4PujXfygI2w3zOcrBZq7HEH6am3lD4DAlmiAlgQBuombdgleYHb43Nm6CdJnwAvyoJ6chWombdALCOQ7muHOT400smaT15onAoUCC21TllxHkHdW6Y)95HxjJo3WyJLwfMZOUWbSc11OxRKdvDNHkeTfNMwIbOTo3PrJFhxoo762LLRqLWbyD5pf9wyq026wHODRwiKddWE)(8WRKrNBySXsRcZzuxMHWbW5YkuOPG0ALCOQ7muHOT400smaT15U3Nm6CdJnwAvyoJ6sRNUtkoysodALCOAHbrBXqDJYHjyWyHqomatAstia]] )


end
