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


    spec:RegisterPack( "Havoc", 20180717.1401, [[deeOXaqii0JOQeAtuv9jLQOYOOk1POQyvkvj9kskZIe5wkvP2fP(fuPHbv5ykvwgjvEguvnnQk11uQQTbvL(guvmoQkPZPufzDuvcmpsQ6Eq0(GsDqQkbTqsutuPkkUOsvIgjvLOtQuLWkHGDcvSuLQOQNQKPQqTvLQO0Ev1FPYGP0HrTyf9yPmzcxgSzi9zsy0ufNw41uLmBKUTuTBr)wLHtswoINtX0LCDfSDLY3viJxPkCEOK5df7NO)D)4Fj4cECuhE78v8WND4JENVXd)4Fp9RclvWVuXnVyfWVsUd)YxYBx7xQySOhl(X)YCdKg8lpvPY4laxCveLNHPUDDCnrFGYvCzJWOfUMO3WDsVjUtuEVfWgUQihAqbdUJdGOUD4owD7C7zG(LoF5qwaX5l5TRPnrV9R5qqR9I8N)sWf84Oo825R4Hp7Wh9o8VVVXBp9lJkO94Sp(Gp)saM2Vg7jmsByKwwAvXnVyfG0EOsl3Q4sPLgMYiTOhrA9LGxbn0seKim2diTxsXsAnHImqJgNL02prGgnUIlns7EH02zbiTJyJ0wN0kcdpPG0UNfsfa6avA3Zdfb4sAh5bsPDWacPf9isB)2GoK1EoJ0AyVaP9skw6Frdtz(X)kpsNP)4hND)4FbjpPG4v(xnsuaj4FvmfYs3VoK1qxdjpPGqA9lTZbuuTkcOIjGqlUr5V4wfx(RnivaOduhbkcW1xpoQ7h)li5jfeVY)QrIcib)lVL2nMe8Kc6rCurQWHEex)6qwdDPfdgPTykKLgfOUoBkGGLgsEsbH06J06xA9wABEyIcWiTiLw1jTyWiTElTeoeoydYs3VnOdzPJuAXwA3HN06xAjCiCWgKLMfcJosPfBPDhEsRpsRp)IBvC5VqbQJmy881Jd()X)csEsbXR8VAKOasW)crPDJjbpPGEehvKkCOhX1VoK1qxA9lTElTCRInWbj0dWiTylT7KwmyKwchchSbzPzHWOJuAXwAXpEsRp)IBvC5VqbQBYecRa(6XX3)4FXTkU8xrVFuUIlD8aH)fK8KcIx5VEC2)h)li5jfeVY)QrIcib)lUvXg4Ge6byKwSL2DsRFP1BPfrPLWHWbBqwAwimAypctzKwmyKwchchSbzPzHWOhujT(iT(LweL2nMe8Kc6rCurQWHEex)6qwd9FXTkU8xawGBcC)Rhh89h)li5jfeVY)QrIcib)RnMe8Kc6jLfGtWzd(f3Q4YFjaU84mJaq1xpo4Zp(xqYtkiEL)vJefqc(xBmj4jf0tklaNGZg8lUvXL)Aszb4eC2GVEC81F8VGKNuq8k)RgjkGe8VqhiyPfaA0IsAXgP06B8(f3Q4YFHc0jLfWxpo7PF8VGKNuq8k)RgjkGe8VquAlMczPN0ifo0bcwAi5jfesRFPfrPDJjbpPGEehvKkCOhXjyIxodLnEKw)slHdHd2GS0Sqy0rkTylTT7OIBu(lUvXL)cWcCtG7F94SdVF8VGKNuq8k)RgjkGe8V8wAlMczPfq)s3KYcWOHKNuqiTyWiTikTBmj4jf0J4OIuHd9iU(1HSg6slgmsl6ablTaqJwusR6Lw8JN0IbJ0ohqr1DO4(ru55mHrtGohPrAvV0UV06J06xAruA3ysWtkOvDhnsfo0J4MuwaobNnqA9lTikTBmj4jf0J4OIuHd9iobt8YzOSXZV4wfx(loZWtq5kU8RhND7(X)csEsbXR8VAKOasW)YBPTykKLwa9lDtklaJgsEsbH0IbJ0IO0UXKGNuqpIJksfo0J46xhYAOlTyWiTOdeS0canArjTQxAXpEsRpsRFPfrPDJjbpPGw1D0iv4qpIRdflT(LweL2nMe8KcAv3rJuHd9iUjLfGtWzdKw)slIs7gtcEsb9ioQiv4qpItWeVCgkB88lUvXL)Q5HpJZuKWl4RhNDQ7h)li5jfeVY)QrIcib)RIPqw6jnsHdDGGLgsEsbH06xAjCiCWgKLMfcJosPfBPTDhvCJsnGf4Ma31eOZrA(f3Q4YFbybUjW9VEC2H)F8V4wfx(lb0V04Mrb)csEsbXR8xpo789p(xqYtkiEL)vJefqc(xikTftHS09Rdzn01qYtkiKw)slHdHd2GS09Bd6qw6iLwSL2MhMOams7EvA3HN06xAlMczPfq)s3KYcWOHKNuq8lUvXL)cfOoYGXZxpo72)h)li5jfeVY)QrIcib)RIjkGslctXzdKwSL2D7lTyWiTikTftuaLoshHtfWV4wfx(luGoPSa(6Xzh((J)fK8KcIx5F1irbKG)vXefqPfHP4Sbsl2s7U9LwmyKwVLweL2IjkGshPJWPcqA9lTikTftHS09Rdzn01qYtkiKwF(f3Q4YFHcuhzW45RhND4Zp(xqYtki(5VAKOasW)QyIcO0IWuC2aPfBPD3()IBvC5V2GubGoqDeOiaxF94SZx)X)csEsbXR8VAKOasW)QykKLwa9lDtklaJgsEsbXV4wfx(RYd5g5uq5yd(6RFjauEGw)4hND)4FXTkU8x8qDoUkU51VGKNuq8k)1JJ6(X)csEsbXR8V2y6a8RIPqwA0Gyk3KENqdjpPGqAXGrAnq5Mxoy0vae1HNZ3QAsl2slEslgmsRrfqPUIjkGYONuwaobNnyN0InsP1BPf)s7ElTftHS0fHdQ7qDKHi1eo9sA95xCRIl)1gtcEsHFTXexYD4xtklaNGZg81Jd()X)csEsbXR8V2y6a8leLwVLweL2IPqw6e6GjmAi5jfeslgmsB7oQ4gL6e6GjmAcWcSKwmyK22DuXnk1j0bty0eOZrAKwSL2IjkGsxrhC15ebiTyWiTT7OIBuQtOdMWOjqNJ0iTylT4lEsRp)IBvC5V2ysWtk8RnM4sUd)AehvKkCOhXLqhmH5RhhF)J)fK8KcIx5FTX0b4xikTftHS0cOFz00qYtkiKw)sB7oQ4gL6ouC)iQ8CMWOjqNJ0iTQxAXxP1V0IoqWsla0OfL0IT0IF8Kw)sR3slIs7gtcEsb9ioQiv4qpIlHoycJ0IbJ02UJkUrPoHoycJMaDosJ0QEPDhEsRp)IBvC5V2ysWtk8RnM4sUd)s1D0iv4qpIRdf)1JZ()4FbjpPG4v(xBmDa(1gtcEsb9KYcWj4SbsRFP1BPfDGGL0QEPfF2xA3BPTykKLgniMYnP3j0eo9sA3RsR6WtA95xCRIl)1gtcEsHFTXexYD4xQUJgPch6rCtklaNGZg81Jd((J)fK8KcIx5FTX0b4xftHS0cM4LZqzJhnK8KccP1V0IO0UXKGNuqR6oAKkCOhXnPSaCcoBG06xAruA3ysWtkOvDhnsfo0J46qXsRFPTDhvCJsTGjE5mu24rpO6xCRIl)1gtcEsHFTXexYD4xJ4OIuHd9iobt8YzOSXZxpo4Zp(xqYtkiEL)1gthGFvmfYs3VoK1qxdjpPGqA9lTikTZbuuD)6qwdD9GQFXTkU8xBmj4jf(1gtCj3HFnIJksfo0J46xhYAO)1JJV(J)f3Q4YFjcdzqv9li5jfeVYF94SN(X)csEsbXR8VAKOasW)QDhvCJsTc6nzQRDhvCJsnb6CKgPfP0I3V4wfx(RgtPoUvXLoAyQFrdt5sUd)QDhvCJYVEC2H3p(xqYtkiEL)vJefqc(xOdeS0canArjTyJuAX)()IBvC5VufnVCdQCOewrhY6RhND7(X)csEsbXR8VAKOasW)QykKLwWeVCgkB8OHKNuqiT(LwVL2nMe8Kc6rCurQWHEeNGjE5mu24rAXGrAfWCafvlyIxodLnE0dQKwF(f3Q4YF1yk1XTkU0rdt9lAykxYD4xcM4LZqzJNVEC2PUF8VGKNuq8k)RgjkGe8VkMczPfq)YOPHKNuq8lUvXL)ImKoUvXLoAyQFrdt5sUd)sa9lJ2xpo7W)p(xqYtkiEL)f3Q4YFrgsh3Q4shnm1VOHPCj3HFLhPZ0V(6xQiq76tU(Xpo7(X)csEsbXR8xpoQ7h)li5jfeVYF94G)F8VGKNuq8k)1JJV)X)csEsbXR8xpo7)J)f3Q4YFP6Q4YFbjpPG4v(Rhh89h)lUvXL)Qdf3pIkpNjm)csEsbXR8xF9lb0VmA)4hND)4FbjpPG4v(xnsuaj4FXTk2ahKqpaJ0IT0UtAXGrAjCiCWgKLMfcJosPfBPf)49lUvXL)cfOUjtiSc4Rhh19J)fK8KcIx5F1irbKG)1gtcEsb9KYcWj4Sb)IBvC5VeaxECMraO6Rhh8)J)fK8KcIx5F1irbKG)1gtcEsb9KYcWj4SbsRFPTDhvCJsnGf4Ma31eOZrAKwSL29Lw)slIsB7oQ4gL6ouC)iQ8CMWOjalW6xCRIl)1KYcWj4SbF9447F8V4wfx(RO3pkxXLoEGW)csEsbXR8xpo7)J)fK8KcIx5F1irbKG)f6ablPv9sRVXtAXGrA9wANdOO6ouC)iQ8CMWOf3OuA9lTOdeS0canArjTyJuA9nEsRp)IBvC5Vqb6KYc4Rhh89h)li5jfeVY)QrIcib)lVLweL2IPqw6jnsHdDGGLgsEsbH0IbJ0IoqWsla0OfL0InsPfFWtA9rA9lTElTikTZbuuDhkUFevEoty0WEuqkaHBILta9lJM0IbJ06T0AGYnVCWORaiQBNZ3QAsl2slEsRFPDoGIQ7qX9JOYZzcJMaDosJ0IT0UdFLwFKwF(f3Q4YFbybUjW9VECWNF8VGKNuq8k)RgjkGe8V8wAlMczPN0ifo0bcwAi5jfeslgmsl6ablTaqJwusR6Lw8JN0IbJ0ohqr1DO4(ru55mHrtGohPrAvV0UV06J06xAruA3ysWtkOvDhnsfo0J4MuwaobNn4xCRIl)fNz4jOCfx(1JJV(J)fK8KcIx5F1irbKG)L3sBXuil9KgPWHoqWsdjpPGqAXGrArhiyPfaA0IsAvV0IF8KwFKw)slIs7gtcEsbTQ7OrQWHEexhkwA9lTikTBmj4jf0QUJgPch6rCtklaNGZg8lUvXL)Q5HpJZuKWl4RhN90p(xqYtkiEL)vJefqc(xftHS0cOFPBszby0qYtkiKw)slIsB7oQ4gLAalWnbURjalWsA9lTElTnpmrbyKwKsR6KwmyKwVLwchchSbzP73g0HS0rkTylT7WtA9lTeoeoydYsZcHrhP0IT0UdpP1hP1NFXTkU8xOa1rgmE(6XzhE)4FXTkU8xcOFPXnJc(fK8KcIx5VEC2T7h)li5jfeVY)QrIcib)leL2IjkGshPJWPc4xCRIl)v5HCJCkOCSbF94StD)4FbjpPG4v(xnsuaj4FvmrbuArykoBG0IT0UBFPfdgPfrPTyIcO0r6iCQa(f3Q4YFHcuhzW45RhND4)h)li5jfe)8xnsuaj4FvmrbuArykoBG0IT0UB)FXTkU8xBqQaqhOocueGRVEC257F8VGKNuq8k)RgjkGe8VkMczPfq)s3KYcWOHKNuq8lUvXL)Q8qUrofuo2GV(6xT7OIBu(JFC29J)fK8KcIx5F1irbKG)fIsR3sBXuilTa6xgnnK8KccPfdgPDJjbpPGw1D0iv4qpIRdflTyWiTBmj4jf0J4OIuHd9iUe6GjmsRpslgmsBXefqPROdU6CIaKw1lTQB)FXTkU8xDO4(ru55mH5Rhh19J)fK8KcIx5F1irbKG)vXuilTa6xgnnK8KccP1V0ohqr1DO4(ru55mHrpO6xCRIl)vhkUFevEoty(6Xb))4FbjpPG4v(xCRIl)vcDWeMF1irbKG)fHdHd2GS0Sqy0WEeMYiT(Lwbmhqr1j0bty0IBukT(LwVLwUvXg4Ge6byKwSL2DslgmslHdHd2GS0Sqy0rkTylT4lEsRp)QyIcOCb6VkMOakDfDWvNteWxpo((h)li5jfeVY)QrIcib)leLwchchSbzPzHWOH9imL5xCRIl)vcDWeMVEC2)h)li5jfeVY)QrIcib)R5akQUdf3pIkpNjmAc05insl2sR62xAXGrAlMOakDfDWvNteG0QEPfFX7xCRIl)LQRIl)6RFjyIxodLnE(Xpo7(X)csEsbXR8VAKOasW)cDGGL0InsP1xXtA9lTElTikTBmj4jf0tklaNGZgiTyWiTikTT7OIBuQNuwaobNnqtawGL06ZV4wfx(lbt8YzOSXZxpoQ7h)li5jfeVY)QrIcib)lbmhqr1cM4LZqzJh9GQFXTkU8xCMHNGYvC5xpo4)h)li5jfeVY)QrIcib)lbmhqr1cM4LZqzJh9GQFXTkU8xnp8zCMIeEbF91x)AdiM4Yhh1H3oFfp8zNV178193)xJysgPcZV(fpuEoYV8LGxbn(LkYHgu4x(Is7E5EaTHces7eqpciTTRp5sANGIinAP1xyRbQkJ0MxU3EyshDGkTCRIlns7LuS0se4wfxA0Qiq76tUqIszJxse4wfxA0Qiq76tUudjU8GIoKfxXLse4wfxA0Qiq76tUudjUO3jKi4lkTRKvz8CL0s4qiTZbuuqiTMIlJ0ob0JasB76tUK2jOisJ0YPqAvrG9w1vvKkK2WiTIlbTebUvXLgTkc0U(Kl1qIRjzvgpx5mfxgjcCRIlnAveOD9jxQHexvxfxkrGBvCPrRIaTRp5snK42HI7hrLNZegjcse8fL29Y9aAdfiKwydiyjTv0bPT8asl3QJiTHrA5noO8KcAjcCRIlni5H6CCvCZljcCRIlnQHe3nMe8KckLChqoPSaCcoBGsBmDaqwmfYsJget5M07eAi5jfeyWyGYnVCWORaiQdpNVv1WGXOcOuxXefqz0tklaNGZgSdBKEJ)9UykKLUiCqDhQJmePgsEsbHpse4wfxAudjUBmj4jfuk5oGCehvKkCOhXLqhmHrPnMoair0BelMczPtOdMWOHKNuqGbt7oQ4gL6e6GjmAcWcSWGPDhvCJsDcDWegnb6CKgSlMOakDfDWvNteagmT7OIBuQtOdMWOjqNJ0Gn(INpse4wfxAudjUBmj4jfuk5oGu1D0iv4qpIRdfR0gthaKiwmfYslG(LrtdjpPGWF7oQ4gL6ouC)iQ8CMWOjqNJ0OE81p6ablTaqJwuyJF887nIBmj4jf0J4OIuHd9iUe6GjmyW0UJkUrPoHoycJMaDosJ63HNpse4wfxAudjUBmj4jfuk5oGu1D0iv4qpIBszb4eC2aL2y6aGCJjbpPGEszb4eC2a)EJoqWs94Z(7DXuilnAqmLBsVtOHKNuqSxvhE(irGBvCPrnK4UXKGNuqPK7aYrCurQWHEeNGjE5mu24rPnMoailMczPfmXlNHYgpAi5jfe(rCJjbpPGw1D0iv4qpIBszb4eC2a)iUXKGNuqR6oAKkCOhX1HI93UJkUrPwWeVCgkB8OhujrGBvCPrnK4UXKGNuqPK7aYrCurQWHEex)6qwdDL2y6aGSykKLUFDiRHUgsEsbHFeNdOO6(1HSg66bvse4wfxAudjUIWqguvse4wfxAudjUnMsDCRIlD0WukLChq2UJkUrPsbksfnHMaDosds8KiWTkU0OgsCvfnVCdQCOewrhYsPafj6ablTaqJwuyJe)7lrGBvCPrnK42yk1XTkU0rdtPuYDaPGjE5mu24rPafzXuilTGjE5mu24rdjpPGWV3Bmj4jf0J4OIuHd9iobt8YzOSXdgmcyoGIQfmXlNHYgp6bv(irGBvCPrnK4sgsh3Q4shnmLsj3bKcOFz0ukqrwmfYslG(LrtdjpPGqIa3Q4sJAiXLmKoUvXLoAykLsUdiZJ0zQebjcCRIln62DuXnkr2HI7hrLNZegLcuKi6DXuilTa6xgnnK8Kccmy2ysWtkOvDhnsfo0J46qXyWSXKGNuqpIJksfo0J4sOdMW4dgmftuaLUIo4QZjcq9QBFjcCRIln62DuXnkvdjUDO4(ru55mHrPafzXuilTa6xgnnK8Kcc)ZbuuDhkUFevEoty0dQKiWTkU0OB3rf3OunK4MqhmHrPIjkGYfOi7r6lOyIcO0v0bxDorakfOijCiCWgKLMfcJg2JWug)cyoGIQtOdMWOf3O0V3CRInWbj0dWGTambbeUIjkGYGbdHdHd2GS0Sqy0rIn(INpse4wfxA0T7OIBuQgsCtOdMWOuGIerchchSbzPzHWOH9imLrIa3Q4sJUDhvCJs1qIRQRIlvkqrohqr1DO4(ru55mHrtGohPbB1TpgmftuaLUIo4QZjcq94lEseKiWTkU0OfmXlNHYgpifmXlNHYgpkfOirhiyHnsFfp)EJ4gtcEsb9KYcWj4SbyWGy7oQ4gL6jLfGtWzd0eGfy5JebUvXLgTGjE5mu24rnK4YzgEckxXLkfOifWCafvlyIxodLnE0dQKiWTkU0OfmXlNHYgpQHe3Mh(motrcVaLcuKcyoGIQfmXlNHYgp6bvseKiWTkU0Ofq)YOHefOUjtiScqPafj3QydCqc9amylatqaHRyIcOmyWq4q4GnilnlegDKyJF8KiWTkU0Ofq)YOPgsCfaxECMraOsPaf5gtcEsb9KYcWj4Sbse4wfxA0cOFz0udjUtklaNGZgOuGICJjbpPGEszb4eC2a)T7OIBuQbSa3e4UMaDosd277hX2DuXnk1DO4(ru55mHrtawGLebUvXLgTa6xgn1qIB07hLR4shpqyjcCRIlnAb0VmAQHexuGoPSaukqrIoqWs9(gpmy8EoGIQ7qX9JOYZzcJwCJs)OdeS0canArHnsFJNpse4wfxA0cOFz0udjUawGBcCxPafP3iwmfYspPrkCOdeS0qYtkiWGbDGGLwaOrlkSrIp45JFVrCoGIQ7qX9JOYZzcJg2JcsbiCtSCcOFz0WGXBduU5LdgDfarD7C(wvZ)Cafv3HI7hrLNZegnb6CKgS3HV(4JebUvXLgTa6xgn1qIlNz4jOCfxQuGI07IPqw6jnsHdDGGLgsEsbbgmOdeS0canArPE8JhgmZbuuDhkUFevEoty0eOZrAu)((4hXnMe8KcAv3rJuHd9iUjLfGtWzdKiWTkU0Ofq)YOPgsCBE4Z4mfj8cukqr6DXuil9KgPWHoqWsdjpPGadg0bcwAbGgTOup(XZh)iUXKGNuqR6oAKkCOhX1HI9J4gtcEsbTQ7OrQWHEe3KYcWj4Sbse4wfxA0cOFz0udjUOa1rgmEukqrwmfYslG(LUjLfGrdjpPGWpIT7OIBuQbSa3e4UMaSal)E38WefGbP6WGXBchchSbzP73g0HS0rI9o88t4q4GnilnlegDKyVdpF8rIa3Q4sJwa9lJMAiXva9lnUzuGebUvXLgTa6xgn1qIB5HCJCkOCSbkfOiNdOO6BOChQJWPcqpOsIa3Q4sJwa9lJMAiXffOoYGXJsbkY(TbDilTimfNna7D7JbZCafvFdL7qDeova6bvse4wfxA0cOFz0udjUBqQaqhOocueGlLcuK9Bd6qwArykoBa272xIa3Q4sJwa9lJMAiXT8qUrofuo2aLcuKftHS0cOFPBszby0qYtkiKiirGBvCPrNhPZuKBqQaqhOocueGlLcuKftHS09Rdzn01qYtki8phqr1QiGkMacT4gLse4wfxA05r6mvnK4IcuhzW4rPafP3Bmj4jf0J4OIuHd9iU(1HSg6yWumfYsJcuxNnfqWsdjpPGWh)E38WefGbP6WGXBchchSbzP73g0HS0rI9o88t4q4GnilnlegDKyVdpF8rIa3Q4sJopsNPQHexuG6MmHWkaLcuKiUXKGNuqpIJksfo0J46xhYAO73BUvXg4Ge6byWwaMGacxXefqzWGHWHWbBqwAwim6iXg)45JebUvXLgDEKotvdjUrVFuUIlD8aHLiWTkU0OZJ0zQAiXfWcCtG7kfOi5wfBGdsOhGb7D(9grchchSbzPzHWOH9imLbdgchchSbzPzHWOhu5JFe3ysWtkOhXrfPch6rC9Rdzn0LiWTkU0OZJ0zQAiXvaC5XzgbGkLcuKBmj4jf0tklaNGZgirGBvCPrNhPZu1qI7KYcWj4SbkfOi3ysWtkONuwaobNnqIa3Q4sJopsNPQHexuGoPSaukqrIoqWsla0Off2i9nEse4wfxA05r6mvnK4cybUjWDLcuKiwmfYspPrkCOdeS0qYtki8J4gtcEsb9ioQiv4qpItWeVCgkB84NWHWbBqwAwim6iXUDhvCJsjcCRIln68iDMQgsC5mdpbLR4sLcuKExmfYslG(LUjLfGrdjpPGadge3ysWtkOhXrfPch6rC9Rdzn0XGbDGGLwaOrlk1JF8WGzoGIQ7qX9JOYZzcJMaDosJ633h)iUXKGNuqR6oAKkCOhXnPSaCcoBGFe3ysWtkOhXrfPch6rCcM4LZqzJhjcCRIln68iDMQgsCBE4Z4mfj8cukqr6DXuilTa6x6MuwagnK8KccmyqCJjbpPGEehvKkCOhX1VoK1qhdg0bcwAbGgTOup(XZh)iUXKGNuqR6oAKkCOhX1HI9J4gtcEsbTQ7OrQWHEe3KYcWj4Sb(rCJjbpPGEehvKkCOhXjyIxodLnEKiWTkU0OZJ0zQAiXfWcCtG7kfOilMczPN0ifo0bcwAi5jfe(jCiCWgKLMfcJosSB3rf3OuIa3Q4sJopsNPQHexb0V04Mrbse4wfxA05r6mvnK4IcuhzW4rPafjIftHS09Rdzn01qYtki8t4q4GnilD)2GoKLosSBEyIcWSx3HN)IPqwAb0V0nPSamAi5jfese4wfxA05r6mvnK4Ic0jLfGsbkY(TbDilTimfNna7D7JbZCafvFdL7qDeova6bvse4wfxA05r6mvnK4IcuhzW4rPafz)2GoKLweMIZgG9U9XGX75akQ(gk3H6iCQa0dQ8JyXuilD)6qwdDnK8KccFKiWTkU0OZJ0zQAiXDdsfa6a1rGIaCPuGISFBqhYslctXzdWE3(se4wfxA05r6mvnK4wEi3iNckhBGsbkYIPqwAb0V0nPSamAi5jfeF91)]] )


end
