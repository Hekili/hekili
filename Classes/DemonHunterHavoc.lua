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
            duration = 30,
            max_stack = 1,
            meta = {
                extended_by_demonic = function ()
                    return talent.demonic.enabled and buff.metamorphosis.up and eye_beam_applied > metamorphosis_applied
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
            
            spend = 40,
            spendType = "fury",
            
            startsCombat = true,
            texture = 1303275,

            bind = "chaos_strike",
            buff = "metamorphosis",
            handler = function ()
            end,
        },
        

        blade_dance = {
            id = 188499,
            cast = 0,
            cooldown = 9,
            gcd = "spell",
            
            spend = function () return 35 - ( talent.first_blood.enabled and 20 or 0 ) end,
            spendType = "fury",
            
            startsCombat = true,
            texture = 1305149,

            bind = "death_sweep",
            nobuff = "metamorphosis",
            
            handler = function ()
                applyBuff( "blade_dance" )
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
            
            spend = 40,
            spendType = "fury",
            
            startsCombat = true,
            texture = 1305152,

            bind = "annihilation",
            nobuff = "metamorphosis",
            
            handler = function ()
            end,
        },
        

        consume_magic = {
            id = 278326,
            cast = 0,
            cooldown = 10,
            gcd = "off",
            
            startsCombat = true,
            texture = 828455,

            -- toggle = "interrupts",
            
            -- usable = function () return target.casting end,
            handler = function ()
                -- no longer an interrupt.
                -- interrupt()
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
            gcd = "spell",
            
            spend = function () return 35 - ( talent.first_blood.enabled and 20 or 0 ) end,
            spendType = "fury",
            
            startsCombat = true,
            texture = 1309099,

            bind = "blade_dance",
            buff = "metamorphosis",
            
            handler = function ()
                applyBuff( "death_sweep" )
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
                    if buff.metamorphosis.up then buff.metamorphosis.expires = buff.metamorphosis.expires + 8
                    else applyBuff( "metamorphosis", action.eye_beam.cast + 8 ) end
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
            gcd = "spell",

            spend = -40,
            spendType = "fury",
            
            startsCombat = true,
            texture = 1344646,

            usable = function () return target.within15 end,        
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
            cooldown = 240,
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
            charges = function () return talent.master_of_the_glaive.enabled and 2 or 1 end,
            cooldown = 9,
            recharge = 9,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1305159,
            
            handler = function ()
                applyDebuff( "target", "master_of_the_glaive" )
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
    
        package = "Havoc",
    } )


    spec:RegisterPack( "Havoc", 20180714.1855, [[dWuSabqiOklsIa8iufAtsOpjruXOGsofuQvrkuVIu0SKa3ckiTlc)IuvdJuYXGkTmjspJuQMguGRbfABOk4BsezCKc5CseI1rkGAEOk6EiX(GQ6GKc0cjv5HKcYeLikxuIqAJseQpskGmsOG4KseiRekAMqbv3ekOStjOHskalvIG6Pi1urv6QseO2Qeb0Ej5VqmyvDyklwrpwHjt0LbBgsFgv1OrsNwPvlru1RjLYSr52u1Uf9BvgUK64sevA5iEovMUW1rLTtQ8DjQXtkOopuX6LiiZxs2VuRWvXRIwAbOkSuTWvJ0QKWfde4QryeJySufDGtnOORTH2m(GIonpOOXqmD3qrxB4WotQ4vr7ooYau0uJO2PbwF95VbvUPyCE9DRNJzXE5GyOH(U1p0FYUP(mG)EjgQe0PFn5qxg40N3fiLIR(8wkUiLmWFjcgcxgabbdX0DdHB9df9KBzrjOunv0slavHLQfUAKwLeUyGaxncJAhxfTRggQcXyjvskAj4gkAEPUU(xx)w)12qBgFO)dTFBe7L9Zwx46h9i9JHaABzROXSXKxQRR)11)KBzr)OKZ3Fqf6hdh4Vx2VgudadVFlL9tGsUClbC9B9ZUO)dTFuosqfi9hGl2KF)OhP)Row)wczXEPOXSXSeFK(30fwoGc6VKzeT1pnZCu7FD9Nx0FTrIDWXmcdN(V6y9BjeifnMnM8Amidx)bvl63iq)8Ve6VmqG(jG)0bY(Xsdr1ox)6Xmj4kOF9y3jzqGTOXSXKxQRR)YlJ1pB1gWWP)j0pbQz2aK9xMkK9B9poFndcOFnOgagE)RRFtNTmBYG(rps)0RNJzXEPgIyOHqrZwx4u8QOZJ4nMIxvH4Q4vrdPnzGuPNIEq2aiRPOXQ)WyqgIAcuBeqkG0Mmq2Fvv)HXGme(ZdzW5fqAtgi7h7(l2)KdfvutGAJasH8kN9xS)jhkQWFEidoVqELtfTnI9sfToi5dOCmeceeWcvOkSufVkAiTjdKk9u0dYgaznfnw9hgdYq4ppKbNxaPnzGS)QQ(dJbziqbgI3CbqWraPnzGSFS7Vy)y1pE9hgdYq4ppKbNxaPnzGS)QQ(XQ)bvJWhC9tP)s7VQQ)XDm5vof6GKpGYXqiqqaleeWBB66h)(XG(XU)I9p5qrf(ZdzW5fYRC2p29xSFS6hV(dJbziqbgI3CbqWraPnzGS)QQ(r5i4iKa6o2OF8P0FPySFS7Vy)y1)GQr4dU(P0FP9xv1pw9tSvIa6Gme(th4HmeB2p(9JRw9xSFITseqhKHWKsNyZ(XVFC1QFS7hBfTnI9sfnkWqiCoQQqvO2v8QOH0MmqQ0trpiBaK1u0y1)Kdfv4ppKbNxWv3Fvv)41FymidH)8qgCEbK2KbY(XU)I9Jv)2iwDacKGFbx)43pU9xv1pXwjcOdYqysPtSz)43V21QFSv02i2lv0OadzAeIXhuHQqmqXRIgsBYaPspf9GSbqwtrJYrWPFE2pUyS)I9Jv)J7yYRCkKGfurCLbOwqaVTPRFE2FP9RX9ZFi7VQQ)XDm5voftMjbePLdqqaVTPRFE2FP9RX9ZFi7hBfTnI9sfnkWMmtcQqvigv8QOH0MmqQ0trpiBaK1u06mYAtgiMmtcislhGI2gXEPIwcwqfXvgGAvOkKhu8QOH0MmqQ0trpiBaK1u0dQgHp46Ns)L2FX(XR)Wyqgc)5Hm48ciTjdK9xSF86pmgKHafyiEZfabhbK2KbY(l2pE9p5qrfEim)rQPEU1j4Q7Vy)HXGmesWFjYKzsWjG0MmqQOTrSxQOrbgcHZrvfQcljfVkABe7LkAuGHaeU6yVurdPnzGuPNkufQrkEv0qAtgiv6POhKnaYAkADgzTjdetMjbePLdqrBJyVurpzMeqKwoavOkSerXRIgsBYaPspf9GSbqwtrJYrWrib0DSr)4tPFTRv)A2)KdfvutGAJasXIWv3Vg3VgPOTrSxQOrb2KzsqfQcXvlfVkAiTjdKk9u0dYgaznfTRgymKWi8HWjaCaKjyEKyhARF87h3(RQ6FYHIkOA6UbsukUiyq9qqaVTPRFE2FP9xSFS6hV(dJbziMSnLiOCeCeqAtgi7VQQFuococjGUJn6hFk9xsA1p29xSFS6hR(D1aJHegHpeobGdGmbZJe7qB9JpL(1E)f7NyReb0bzimP0j2SF87FChtELZ(XU)QQ(dJbziMSnLiOCeCeqAtgi7VQQFheiZl5CIybsP4IuA9OF87xR(XwrBJyVurd4aitW8QqviU4Q4vrdPnzGuPNIEq2aiRPOXQ)Wyqgcj4VezYmj4eqAtgi7VQQF86pmgKHWFEidoVasBYaz)vv9p5qrf(ZdzW5fC19xv1pkhbhHeq3Xg9ZZ(1Uw9Rz)touurnbQnciflcxD)AC)Au)vv9p5qrfEim)rQPEU1jiG3201pp7hJ9JD)f7hV(1zK1MmquFhBt(iOhbzYmjGiTCakABe7LkAlZL6YSyVufQcXTufVkAiTjdKk9u0dYgaznf9Kdfv4HW8hPM65wNqELZ(l2VRgymKWi8HW1p(u6x7kABe7Lk6Gk5kJWNzRoqfQcXv7kEv02i2lv0sJOnehZCuv0qAtgiv6PcvH4IbkEv0qAtgiv6POhKnaYAkAS6pmgKHqc(lrMmtcobK2KbY(RQ6hV(dJbzi8NhYGZlG0Mmq2Fvv)touuH)8qgCEbxD)vv9JYrWrib0DSr)8SFTRv)A2)KdfvutGAJasXIWv3Vg3Vg1p29xSF86xNrwBYar9DSn5JGEeKbv7CiUGSAd6Vy)41VoJS2KbI67yBYhb9iiEiS(l2pE9RZiRnzGO(o2M8rqpcYKzsarA5au02i2lv0dQ25qCbz1gOcvH4IrfVkAiTjdKk9u0dYgaznfnE9hgdYq4ppKbNxaPnzGS)I9tSvIa6Gme(th4HmeB2p(9pOAe(GRFnUFC1Q)I9hgdYqib)LitMjbNasBYaPI2gXEPIgfyieohvvOkexEqXRI2gXEPIwc(lDiZnafnK2KbsLEQqviULKIxfnK2KbsLEk6bzdGSMIomcFieY1fwoG(XVFCXy)vv9Jx)Hr4dHyteIL8bfTnI9sfnkWMmtcQqviUAKIxfnK2KbsLEk6bzdGSMIomcFieY1fwoG(XVFCXy)vv9Jv)41Fye(qi2eHyjFO)I9Jx)HXGme(ZdzW5fqAtgi7hBfTnI9sfnkWqiCoQQqviULikEv0qAtgiv6POhKnaYAk6Wyqgcj4VezYmj4eqAtgiv02i2lv0bvYvgHpZwDGkuHIwcOghlu8QkexfVkABe7LkAJloelcBOnfnK2KbsLEQqvyPkEv0qAtgiv6PO1zmoqrJx)y1pE9hgdYqKGhCRtaPnzGS)QQ(h3XKx5uKGhCRtqatIt)vv9pUJjVYPibp4wNGaEBtx)43Fye(qiI1diXHixO)QQ(h3XKx5uKGhCRtqaVTPRF87Nh0QFSv02i2lv06mYAtgOO1zeK08GIUSTXM8rqpcscEWTovOku7kEv0qAtgiv6PO1zmoqrJAmhOOTrSxQO1zK1MmqrRZiiP5bfDzBJn5JGEeKbv7CitMjbNkufIbkEv0qAtgiv6PO1zmoqrJx)HXGmesWF5oeqAtgi7Vy)J7yYRCk8qy(Jut9CRtqaVTPRFE2pp0FX(r5i4iKa6o2OF87x7A1FX(XQF86xNrwBYarzBJn5JGEeKe8GBD9xv1)4oM8kNIe8GBDcc4TnD9ZZ(XvR(XU)I9Jv)41VoJS2KbIY2gBYhb9iidQ25qMmtcU(XwrBJyVurRZiRnzGIwNrqsZdk667yBYhb9iiEimvOkeJkEv0qAtgiv6PO1zmoqrhgdYqGUexGmz3jfqAtgi7VQQFheiZl5CIybsPAHGb1J(XVFT6VQQFxnWyiHr4dHtmzMeqKwoG(XNs)AxrBJyVurRZiRnzGIwNrqsZdk6jZKaI0YbOcvH8GIxfnK2KbsLEkADgJdu06mYAtgiMmtcislhq)f7hR(r5i40pp7VKWy)yO9hgdYqGUexGmz3jflcK2KbY(14(lvR(XwrBJyVurRZiRnzGIwNrqsZdk667yBYhb9iitMjbePLdqfQcljfVkAiTjdKk9u06mghOOrnMdu02i2lv06mYAtgOO1zeK08GIU(o2M8rqpcYGQDoexqwTbQqvOgP4vrBJyVurlxhHRou0qAtgiv6PcvHLikEv0qAtgiv6POhKnaYAk6XDm5vof8z30yiJ7yYRCkiG3201pL(1srBJyVurpmgdXgXEjcBDHIMTUajnpOOh3XKx5ufQcXvlfVkAiTjdKk9u0dYgaznfnkhbhHeq3Xg9JpL(1og7Vy)y1pw9pUJjVYPaWbqMG5feWBB66h)(Xy)vv9Jx)HXGmet2MseuocociTjdK9xSF863bbY8soNiwGukUiyq9OF87xR(XU)QQ(XQ)jhkQWdH5psn1ZTobxD)f7hV(DqGmVKZjIfiLIlcgup6h)(1QFS7hBfTnI9sfD9o0gcxnckX47HmuHQqCXvXRIgsBYaPspf9GSbqwtrhgdYqib)L7qaPnzGurBJyVurt4seBe7LiS1fkA26cK08GIwc(l3HkufIBPkEv0qAtgiv6POTrSxQOjCjInI9se26cfnBDbsAEqrNhXBmvOcfDnbgNFAHIxvH4Q4vrdPnzGuPNkufwQIxfnK2KbsLEQqvO2v8QOH0MmqQ0tfQcXafVkAiTjdKk9uHQqmQ4vrBJyVurxFXEPIgsBYaPspvOkKhu8QOH0MmqQ0trpiBaK1u041pw9hgdYqib)LieyEKuaPnzGS)I9Jv)HXGmesWF5oeqAtgi7VQQFheiZl5CIybsP4IGb1J(XVFT6h7(XwrBJyVur7HW8hPM65wNkuHIEChtELtfVQcXvXRIgsBYaPspf9GSbqwtrJx)HXGmesWF5oeqAtgi7Vy)OCeCesaDhB0p(u6hxmQOTrSxQOnYWsajocbYqfQclvXRIgsBYaPspf9GSbqwtrhgdYqib)L7qaPnzGS)I9JYrWrib0DSr)4tPFCXy)f7FYHIk8qy(Jut9CRtWvROTrSxQOnYWsajocbYqfQc1UIxfnK2KbsLEk6bzdGSMIgV(XQ)Wyqgcj4VChciTjdK9xv1VoJS2KbI67yBYhb9iiEiS(RQ6xNrwBYarzBJn5JGEeKe8GBD9xv1VoJS2KbIY2gBYhb9iidQ25qMmtcU(XU)QQ(dJWhcrSEajoe5c9ZZ(lfJkABe7LkApeM)i1up36uHQqmqXRIgsBYaPspf9GSbqwtrhgdYqib)L7qaPnzGS)I9p5qrfEim)rQPEU1j4Qv02i2lv0Eim)rQPEU1PcvHyuXRIgsBYaPspfTnI9sfDcEWTof9GSbqwtrtSvIa6GmeMu6eGgEDHR)I9lHjhkQibp4wNqELZ(l2pw9BJy1biqc(fC9JF)42Fvv)eBLiGoidHjLoXM9JF)8Gw9JTIomcFiqwufDye(qiI1diXHixqfQc5bfVkAiTjdKk9u0dYgaznfnE9tSvIa6GmeMu6eGgEDHR)I9Jv)touuHhcZFKAQNBDcU6(RQ6FChtELtHhcZFKAQNBDctwYZ5cqIqaVTPRFE2FPA1Fvv)Hr4dHiwpGehICH(5jL(5bT6hBfTnI9sfDcEWTovOkSKu8QOH0MmqQ0trpiBaK1u0touuHhcZFKAQNBDcc4TnD9JF)LIX(RQ6pmcFieX6bK4qKl0pp7Nh0srBJyVurxFXEPkuHIwc(l3HIxvH4Q4vrdPnzGuPNIEq2aiRPOXQ)WyqgIAcuBeqkG0Mmq2Fvv)HXGme(ZdzW5fqAtgi7h7(l2)KdfvutGAJasH8kN9xS)jhkQWFEidoVqELtfTnI9sfToi5dOCmeceeWcvOkSufVkAiTjdKk9u0dYgaznfnw9hgdYq4ppKbNxaPnzGS)QQ(dJbziqbgI3CbqWraPnzGSFS7Vy)y1pE9hgdYq4ppKbNxaPnzGS)QQ(XQ)bvJWhC9tP)s7VQQ)XDm5vof6GKpGYXqiqqaleeWBB66h)(XG(XU)I9p5qrf(ZdzW5fYRC2p29xSFS6Fq1i8bx)u6V0(RQ6hR(j2kraDqgc)Pd8qgIn7h)(XvR(l2pXwjcOdYqysPtSz)43pUA1p29JTI2gXEPIgfyieohvvOku7kEv0qAtgiv6POhKnaYAkADgzTjdetMjbePLdqrBJyVurlblOI4kdqTkufIbkEv02i2lv0OadbiC1XEPIgsBYaPspvOkeJkEv0qAtgiv6POhKnaYAkADgzTjdetMjbePLdO)I9pUJjVYPaWbqMG5feWBB66h)(Xy)f7hV(h3XKx5u4HW8hPM65wNGaMehfTnI9sf9KzsarA5auHQqEqXRIgsBYaPspf9GSbqwtrJYrWrib0DSr)4tPFTRv)f7hR(r5i40pp7hd0Q)QQ(NCOOcpeM)i1up36eYRC2p2kABe7LkAuGnzMeuHQWssXRIgsBYaPspf9GSbqwtr7QbgdjmcFiCcahazcMhj2H26h)(XT)QQ(XQF86pmgKHyY2uIGYrWraPnzGS)QQ(r5i4iKa6o2OF8P0FjPv)y3FX(XQF86FYHIk8qy(Jut9CRtaA4asjirM4Gib)L7O)QQ(XQFheiZl5CIybsP4IGb1J(XVFT6Vy)touuHhcZFKAQNBDcc4TnD9JF)4Yd9JD)yROTrSxQObCaKjyEvOkuJu8QOH0MmqQ0trpiBaK1u0y1pE9hgdYq4ppKbNxaPnzGS)QQ(NCOOc)5Hm48cU6(RQ6hLJGJqcO7yJ(5z)AxR(1S)jhkQOMa1gbKIfHRUFnUFnQ)QQ(NCOOcpeM)i1up36eeWBB66NN9JX(XU)I9Jx)6mYAtgiQVJTjFe0JGmzMeqKwoafTnI9sfTL5sDzwSxQcvHLikEv02i2lv0sJOnehZCuv0qAtgiv6PcvH4QLIxfnK2KbsLEk6bzdGSMIgR(XR)Wyqgc)5Hm48ciTjdK9xv1)Kdfv4ppKbNxWv3Fvv)OCeCesaDhB0pp7x7A1VM9p5qrf1eO2iGuSiC19RX9Rr9JD)f7hV(1zK1MmquFhBt(iOhbzq1ohIliR2G(l2pE9RZiRnzGO(o2M8rqpcIhcR)I9Jx)6mYAtgiQVJTjFe0JGmzMeqKwoafTnI9sf9GQDoexqwTbQqviU4Q4vrdPnzGuPNIEq2aiRPOXR)Wyqgc)5Hm48ciTjdK9xS)Wyqgcj4VezYmj4eqAtgi7Vy)41)4oM8kNcahazcMxqatIt)f7hR(huncFW1pL(lT)QQ(XQFITseqhKHWF6apKHyZ(XVFC1Q)I9tSvIa6GmeMu6eB2p(9JRw9JD)yROTrSxQOrbgcHZrvfQcXTufVkABe7LkAj4V0Hm3au0qAtgiv6PcvH4QDfVkAiTjdKk9u0dYgaznfnE9hgHpeInriwYhu02i2lv0bvYvgHpZwDGkufIlgO4vrdPnzGuPNIEq2aiRPOdJWhcHCDHLdOF87hxm2Fvv)y1pE9hgHpeInriwYh6Vy)41FymidH)8qgCEbK2KbY(XwrBJyVurJcmecNJQkuHku0LnsUjFNIwrBCb1JOOXqaTTSTFS8NCrxq2pk589tVEne2k6AYHUmqrZJ9xIQHHbxaY(Na6rG(hNFAr)tG)Mor)AWXaQdx)5LyOunIhLJ1VnI9sx)xYWr0yAJyV0jQjW48tlOGYmN2AmTrSx6e1eyC(PfAsrFJJVhYWI9YgtBe7LornbgNFAHMu0h9ozJjp2pDA1oQx0pXwz)touuq2VlSW1)eqpc0)48tl6Fc8301VLY(RjagA9fXM87FD9lVeenM2i2lDIAcmo)0cnPOVlTAh1lqCHfUgtBe7LornbgNFAHMu0V(I9YgtBe7LornbgNFAHMu03dH5psn1ZTUcwuk4HvymidHe8xIqG5rsbK2KbYIyfgdYqib)L7qaPnzGSQYbbY8soNiwGukUiyq9aBSBmBm5X(lr1WWGlaz)GoGGt)X6H(dQq)2ios)RRFtNTmBYarJPnI9shfJloelcBOTgtBe7LonPOVoJS2KbfKMhOu22yt(iOhbjbp4wxb6mghqbpSWlmgKHibp4wNasBYazv14oM8kNIe8GBDccysCQQg3XKx5uKGhCRtqaVTPd)Wi8HqeRhqIdrUqv14oM8kNIe8GBDcc4TnD4ZdAHDJPnI9sNMu0xNrwBYGcsZdukBBSjFe0JGmOANdzYmj4kqNX4akOgZbnM8y)La0abrSj)(jGjXP)46NZb97HWkb0)4s5g7LUc6pOUU(xx)Coq2)M9B9JcL7VMzdWjAmTrSx60KI(6mYAtguqAEGs9DSn5JGEeepewb6mghqbVWyqgcj4VChciTjdKfh3XKx5u4HW8hPM65wNGaEBthp5HIOCeCesaDhBGV21Qiw4PZiRnzGOSTXM8rqpcscEWTUQQXDm5vofj4b36eeWBB64jUAHDrSWtNrwBYarzBJn5JGEeKbv7CitMjbh2nM8y)6Xmj0FjZYb0)4s5g7Lor)Aqwzdhx)lA)L4L4I(1JDNS)11Fymidq2)r6pOc9ZBPA1pgup63br)Zl5Cf0)fubs51b9Br)8GM9hgHpeU(lVb1(1quTZ1VgIbMoO)J0V21S)Wi8HW1F5nOECHOX0gXEPttk6RZiRnzqbP5bktMjbePLdOaDgJdOegdYqGUexGmz3jfqAtgiRQCqGmVKZjIfiLQfcgupQQC1aJHegHpeoXKzsarA5aWNI2Bm5X(1JzsO)sMLdO)67yBYV)XLYn2llOF31FzOF5LLCI(D1qk7pURFp3GA)OCeC6)Y(1quTZ1pDqwTb9xMkK9xg6pbq2)g97UlfnM2i2lDAsrFDgzTjdkinpqP(o2M8rqpcYKzsarA5akqNX4ak6mYAtgiMmtcislhqrSq5i4WZscJyOHXGmeOlXfit2DsbK2KbsnUuTWUXKh7xdr1ox)0bz1g0F9DSn53)4s5g7Lf0V76Vm0V8Ysor)UAiL9h31VNBqTFuoco9xMkK9xg6pbq2)g9JEK(1quTZ1VgIbMoOFn4vI2yAJyV0Pjf91zK1MmOG08aL67yBYhb9iidQ25qCbz1guGoJXbuqnMdAmTrSx60KI(Y1r4QJgtBe7LonPO)WymeBe7LiS1ffKMhOmUJjVYzblkf(dPGaEBthfTAmTrSx60KI(17qBiC1iOeJVhYOGfLckhbhHeq3Xg4tr7ySiwynUJjVYPaWbqMG5feWBB6WhJvv4fgdYqmzBkrq5i4iG0MmqwepheiZl5CIybsP4IGb1dSRQWAYHIk8qy(Jut9CRtWvxepheiZl5CIybsP4IGb1dSXUX0gXEPttk6t4seBe7LiS1ffKMhOib)L7OGfLsymidHe8xUdbK2KbYgtBe7LonPOpHlrSrSxIWwxuqAEGsEeVXAmBmTrSx6eJ7yYRCsXidlbK4ieiJcwuk4fgdYqib)L7qaPnzGSikhbhHeq3Xg4tbxm2yAJyV0jg3XKx5utk6BKHLasCecKrblkLWyqgcj4VChciTjdKfr5i4iKa6o2aFk4IXItouuHhcZFKAQNBDcU6gtES)sWoOFmmim)rQPEU11FzQq2FzOFJa9lVe6V(o2M87VeZrWPFlL9xMkK9xg63iq)5f9x22yt(9JEK(VGkq6FChtELtx)X1VdNCiAmTrSx6eJ7yYRCQjf99qy(Jut9CRRGfLcEyfgdYqib)L7qaPnzGSQsNrwBYar9DSn5JGEeepewvLoJS2KbIY2gBYhb9iij4b36QQ0zK1Mmqu22yt(iOhbzq1ohYKzsWHDvvye(qiI1diXHixGNLIXgtBe7LoX4oM8kNAsrFpeM)i1up36kyrPegdYqib)L7qaPnzGS4Kdfv4HW8hPM65wNGRUXKh7VeeA)Mu663iq)1eWbzuq)CoO)cbp4wx)x2Fqf6NDLbx0pgIgq)Mu2)M9Fejq6pU(5dr)bvO)cbp4wx)tou0(rps)AWReTX0gXEPtmUJjVYPMu0pbp4wxbHr4dbYIsXVPg4Wi8HqeRhqIdrUqblkfITseqhKHWKsNa0WRlCfLWKdfvKGhCRtiVYzrSSrS6aeib)co8LGBjGejmcFiCvveBLiGoidHjLoXM4ZdAHDJPnI9sNyChtELtnPOFcEWTUcwuk4rSvIa6GmeMu6eGgEDHRiwtouuHhcZFKAQNBDcU6QQXDm5vofEim)rQPEU1jmzjpNlajcb82MoEwQwvvHr4dHiwpGehICbEsHh0c7gtE0gXEPtmUJjVYPMu0Fq1ohYKzsWvWIszYHIk8qy(Jut9CRtWvxvnUJjVYPWdH5psn1ZToHjl55CbiriG320HppOvvvye(qiI1diXHixGNuKCel2lBmTrSx6eJ7yYRCQjf9RVyVSGfLYKdfv4HW8hPM65wNGaEBth(LIXQQWi8HqeRhqIdrUap5bTAmBm5X(PRHXIUJ(1GAay49JEK(dQq)6X2u2FjMJGJMLmWF5o6xdwxdXgGMLmWF5o6FYTmzJjp2Fjqi5dOCS(lHHGaw0)0gARSrKU(dQKJJp1(dQq)Hr4dr)X1VFZ1VLqq)YRCgRhenM2i2lDcj4VChu0bjFaLJHqGGawuWIsbRWyqgIAcuBeqkG0MmqwvfgdYq4ppKbNxaPnzGe7ItouurnbQncifYRCwCYHIk8NhYGZlKx5SXKh7VedS(lH5Cu7h9i9JHDEidoVOX0gXEPtib)L7qtk6JcmecNJAblkfScJbzi8NhYGZlG0MmqwvfgdYqGcmeV5cGGJasBYaj2fXcVWyqgc)5Hm48ciTjdKvvynOAe(GJsPvvJ7yYRCk0bjFaLJHqGGawiiG320HpgGDXjhkQWFEidoVqELtSlI1GQr4dokLwvHfXwjcOdYq4pDGhYqSj(4QvrITseqhKHWKsNyt8XvlSXUX0gXEPtib)L7qtk6lblOI4kdqDblkfDgzTjdetMjbePLdOX0gXEPtib)L7qtk6JcmeGWvh7LnM2i2lDcj4VChAsr)jZKaI0YbuWIsrNrwBYaXKzsarA5akoUJjVYPaWbqMG5feWBB6WhJfXBChtELtHhcZFKAQNBDccysCAmTrSx6esWF5o0KI(OaBYmjuWIsbLJGJqcO7yd8PODTkIfkhbhEIbAvvn5qrfEim)rQPEU1jKx5e7gtBe7LoHe8xUdnPOpGdGmbZxWIsXvdmgsye(q4eaoaYempsSdTHVeClbKiHr4dHRQcl8cJbziMSnLiOCeCeqAtgiRQq5i4iKa6o2aFkLKwyxel8MCOOcpeM)i1up36eGgoGucsKjoisWF5oQQWYbbY8soNiwGukUiyq9O4Kdfv4HW8hPM65wNGaEBth(4YdyJDJPnI9sNqc(l3HMu03YCPUml2llyrPGfEHXGme(ZdzW5fqAtgiRQMCOOc)5Hm48cU6QkuococjGUJn4P21sZjhkQOMa1gbKcUAnwJQQMCOOcpeM)i1up36eeWBB64jgXUiE6mYAtgiQVJTjFe0JGmzMeqKwoGgtBe7LoHe8xUdnPOV0iAdXXmh1gtBe7LoHe8xUdnPO)GQDoexqwTbfSOuWcVWyqgc)5Hm48ciTjdKvvtouuH)8qgCEbxDvfkhbhHeq3Xg8u7AP5KdfvutGAJasbxTgRryxepDgzTjde13X2Kpc6rqguTZH4cYQnOiE6mYAtgiQVJTjFe0JG4HWkINoJS2KbI67yBYhb9iitMjbePLdOX0gXEPtib)L7qtk6JcmecNJAblkf8cJbzi8NhYGZlG0MmqwmmgKHqc(lrMmtcobK2KbYI4nUJjVYPaWbqMG5feWK4ueRbvJWhCukTQclITseqhKHWF6apKHyt8XvRIeBLiGoidHjLoXM4JRwyJDJPnI9sNqc(l3HMu0xc(lDiZnGgtBe7LoHe8xUdnPOFqLCLr4ZSvhuWIszYHIkoUa5qriwYheC1nM2i2lDcj4VChAsrFuGHq4CulyrP4pDGhYqixxy5aWhxmwvH1KdfvCCbYHIqSKpi4QlIxymidH)8qgCEbK2KbsSBm5rBe7LoHe8xUdnPOVoi5dOCmeceeWIcwuk(th4HmeY1fwoa8XfJnMnM8y)AGGeigRFnOgagE)OhP)cVedTKb(l3r)6XTmPRXKh7VeiK8buow)LWqqal6FAdTv2isx)bvYXXNA)bvO)Wi8HO)463V563siOF5voJ1dIgtBe7LorEeVXOOds(akhdHabbSOGfLcwHXGme1eO2iGuaPnzGSQkmgKHWFEidoVasBYaj2fNCOOIAcuBeqkKx5S4Kdfv4ppKbNxiVYzJjp2Fjgy9xcZ5O2p6r6hd78qgC((Tu2p6r6hLJGt)OKZ3Fjgy9JHzUai4iAmTrSx6e5r8gttk6JcmecNJAblkfScJbzi8NhYGZlG0MmqwvfgdYqGcmeV5cGGJasBYaj2fXcVWyqgc)5Hm48ciTjdKvvynOAe(GJsPvvJ7yYRCk0bjFaLJHqGGawiiG320HpgGDXjhkQWFEidoVqELtSlIfEHXGmeOadXBUai4iG0MmqwvHYrWrib0DSb(ukfJyxeRbvJWhCukTQclITseqhKHWF6apKHyt8XvRIeBLiGoidHjLoXM4JRwyJDJjp2Fjyh0Fjgy9RNrigFOFl63BA4(huncFWvq)ot3M87FJ(rps)yyNhYGZ3VLY(nP01)I2F95C7KbIgtBe7LorEeVX0KI(OadzAeIXhkyrPG1Kdfv4ppKbNxWvxvHxymidH)8qgCEbK2KbsSlILnIvhGaj4xWHVeClbKiHr4dHRQIyReb0bzimP0j2eFTRf2nM2i2lDI8iEJPjf9rb2KzsOGfLckhbhEIlglI14oM8kNcjybvexzaQfeWBB64zPAm)HSQAChtELtXKzsarA5aeeWBB64zPAm)He7gtBe7LorEeVX0KI(sWcQiUYauxWIsrNrwBYaXKzsarA5aAmTrSx6e5r8gttk6JcmecNJAblkLbvJWhCukTiEHXGme(ZdzW5fqAtgilIxymidbkWq8MlacociTjdKfXBYHIk8qy(Jut9CRtWvxmmgKHqc(lrMmtcobK2KbYgtBe7LorEeVX0KI(OadbiC1XEzJPnI9sNipI3yAsr)jZKaI0YbuWIsrNrwBYaXKzsarA5aAmTrSx6e5r8gttk6JcSjZKqblkfuococjGUJnWNI21sZjhkQOMa1gbKcUAnwJAmTrSx6e5r8gttk6d4aitW8fSOuC1aJHegHpeobGdGmbZJe7qB4lb3sajsye(q4QQMCOOcQMUBGeLIlcgupeeWBB64zPfXcVWyqgIjBtjckhbhbK2KbYQkuococjGUJnWNsjPf2fXclxnWyiHr4dHta4aitW8iXo0g(u0ErITseqhKHWKsNyt8h3XKx5e7QQWyqgIjBtjckhbhbK2KbYQkheiZl5CIybsP4IuA9a7gtBe7LorEeVX0KI(wMl1LzXEzblkfScJbziKG)sKjZKGtaPnzGSQcVWyqgc)5Hm48ciTjdKvvtouuH)8qgCEbxDvfkhbhHeq3Xg8u7AP5KdfvutGAJasbxTgRrvvtouuHhcZFKAQNBDcc4TnD8eJyxepDgzTjde13X2Kpc6rqMmtcislhqJPnI9sNipI3yAsr)Gk5kJWNzRoOGfLYKdfv4HW8hPM65wNqELZIUAGXqcJWhch(u0EJPnI9sNipI3yAsrFPr0gIJzoQnM2i2lDI8iEJPjf9huTZH4cYQnOGfLcwHXGmesWFjYKzsWjG0MmqwvHxymidH)8qgCEbK2KbYQQjhkQWFEidoVGRUQcLJGJqcO7ydEQDT0CYHIkQjqTraPGRwJ1iSlINoJS2KbI67yBYhb9iidQ25qCbz1guepDgzTjde13X2Kpc6rq8qyfXtNrwBYar9DSn5JGEeKjZKaI0Yb0yAJyV0jYJ4nMMu0hfyieoh1cwuk4fgdYq4ppKbNxaPnzGSiXwjcOdYq4pDGhYqSj(dQgHp40yC1QyymidHe8xImzMeCciTjdKnM2i2lDI8iEJPjf9LG)shYCdOX0gXEPtKhXBmnPOpkWMmtcfSOu8NoWdziKRlSCa4JlgRQMCOOIJlqoueIL8bbxDJPnI9sNipI3yAsrFuGHq4CulyrP4pDGhYqixxy5aWhxmwvH1KdfvCCbYHIqSKpi4QlIxymidH)8qgCEbK2KbsSBm5rBe7LorEeVX0KI(6GKpGYXqiqqalkyrP4pDGhYqixxy5aWhxm2yAJyV0jYJ4nMMu0pOsUYi8z2QdkyrPegdYqib)LitMjbNasBYaPkuHsb]] )


end
