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
            hasteCD = true,
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
            hasteCD = true,
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


    spec:RegisterPack( "Havoc", 20180820.2031, [[dS0b0aqiuLweevvpIkOSjfYNuOunkfWPuGwfvq4vuHMfj4wubPDrPFHkmmufhJKyzquEgvGPbrLRrfX2uOQVPqHXPqjNJkiADkukZJks3dc7JK0bHOk1cjHEivqvtKkOYfHOkzJquv6JkuP0ivOsoPcf1kvrMjevHUjevb7ev0qHOkAPkuKNQstvf1vvOsXwvOsvFfIQI9QQ)svdMuhMyXk6XsmzKUmyZq6ZKOrtsDArVMkQzJ42sA3c)wPHJQ64kuPYYr55umDPUovA7QW3vqJxHkopez(Os7hQFv(Z)Lkn8CImEuzS4zSqgpwKXJd4bzi7Vns8H)YxkolkH)gsf(74so2YF5lirwH(N)RzDzf4VQ7MVzSXbhkZwT70w2khMS6sKo3OWe0MdtwlCmj7KJjQ4qPWbh8zlAsadhipzWyssQHdKNJjVdhu3WpUCJgy(XLCSfRjRL)oDtspMJF(xQ0WZjY4rLXINXcz8yrgpiJhEgR)A4dLNtNmgJXFPGP83ZQtdwNgSwWA(sXzrjG1lkwlLo3aRjPPnyn6YW6Xf4Cssl(e(eYhHfzOCSH1y9z1aw7Wb1nWAfjcfmyDleiASUkodgSMbM1LvaSwjeat6CdS2n4ZaAwAzsafWAjOyDRgya6YaSMbgxsBW6mW6dGHewx2WaSdPZdaRzqzRviOsNByuaRjPZaw7AYqjwJ8fiy9yY1OgRrxgwtLQOeW6HQHaRB1adg7gSo2wDgkX6j0nWW6EXA6AXNWNC4vlHsWm2WNuXI1yTdxAKjbOy94EiucOUeSEmbndKgRLGI1iFbcwpMCnQX6HQHaRJTXAxdqX6EXAP05H0awJ8WwHODRw8jKzXAS2HxTekbkwJ8x2Lq3HbYpw3lwJ8lLo3Wcib(jivBzxcDhgi)y9q1adWAHpFswKjbS4toWI1y9yoWAdCamHG18jsbmy9q1adW6BwD4X6HRlHI1f1qXzSgDzyntskwdhq0gSMbePbkw3lwx3dOcrJ1ldRfk1OawpMXAHsbkwlbwluA25gcbRlBqZo3aR7fRPPrMeaRB1awxudfNX6bmzuaSUvNgSwO0nWA6cgSo2gR5ZaAwASwOuSMVAXagSEzyDDpGke9G2)sstB(Z)nwwvi)5Ntv(Z)fczsa6R4FlSSbwk)TfceTTUviA3QfczsakwpcRNUOOw(mGVWaQLUdJ)kLo34VhqOeqDjEg0mq6VFor2F(VqitcqFf)BHLnWs5VdG1hclLjbSdLSZqPhDz(6wHODRynxUyDleiAlkq8vX0adjleYKauSEqSEewpawxulmLGbRrG1idR5YfRhaRzss9WbeTTUhqfI2MbwRkwRcpy9iSMjj1dhq0wHsn2mWAvXAv4bRheRh8VsPZn(lkq8mxJ6VFoDWF(VqitcqFf)BHLnWs5V8I1hclLjbSdLSZqPhDz(6wHODRy9iSEaSwkDEaEiGAcgSwvSMcMKbuFlmLqBWAUCXAMKupCarBfk1yZaRvfRDapy9G)vkDUXFrbIFkmMOe((5e5(Z)vkDUXFZADjsNB4fxM8xiKjbOVIF)C6K)8FHqMeG(k(3clBGLYFLsNhGhcOMGbRvfRvbRhH1dG18I1mjPE4aI2kuQXcJtAAdwZLlwZKK6HdiARqPgRlFSEqSEewZlwFiSuMeWouYodLE0L5RBfI2T(xP05g)fqc8tqQF)Co()8FHqMeG(k(3clBGLYFpewktcyNeHcEQef4VsPZn(lfKwT3mea(F)Cog)5)cHmja9v8Vfw2alL)EiSuMeWojcf8ujkWFLsNB83jrOGNkrb((5CS(Z)fczsa6R4FlSSbwk)f1LHKLcOzjBSwveynYXZFLsNB8xuGmjcf((50H8p)xiKjbOVI)TWYgyP8xEX6wiq02jjdQh1LHKfczsakwpcR5fRpewktcyhkzNHsp6Y8uH5S3qeJASEewZKK6HdiARqPgBgyTQyTu6CdlGe4NGuTLDj0Dy8xP05g)fqc8tqQF)CQcp)5)cHmja9v8Vfw2alL)oaw3cbI2sH6g(jrOGXcHmjafR5YfR5fRpewktcyhkzNHsp6Y81Tcr7wXAUCXAuxgswkGMLSXANI1oGhSMlxSE6IIARql1LXx9AsJLbvjddw7uS2jy9Gy9iSMxS(qyPmjGL)UKmu6rxMFsek4PsuaSEewZlwFiSuMeWouYodLE0L5PcZzVHig1)vkDUXFLis1jr6CJVFovrL)8FHqMeG(k(3clBGLYFhaRBHarBPqDd)KiuWyHqMeGI1C5I18I1hclLjbSdLSZqPhDz(6wHODRynxUynQldjlfqZs2yTtXAhWdwpiwpcR5fRpewktcy5VljdLE0L5Rqly9iSMxS(qyPmjGL)UKmu6rxMFsek4PsuaSEewZlwFiSuMeWouYodLE0L5PcZzVHig1)vkDUXFlQL14nnlDg((5ufK9N)leYKa0xX)wyzdSu(BleiA7KKb1J6YqYcHmjafRhH1mjPE4aI2kuQXMbwRkwlLo3Wcib(jivBzxcDhg)vkDUXFbKa)eK63pNQ4G)8FLsNB8xku3W4Nzd)fczsa6R43pNQGC)5)cHmja9v8Vfw2alL)Ylw3cbI2w3keTB1cHmjafRhH1mjPE4aI2w3dOcrBZaRvfRlQfMsWG1oeyTk8G1JW6wiq0wku3WpjcfmwiKjbO)vkDUXFrbIN5Au)9ZPko5p)xiKjbOVI)TWYgyP836EaviAlnnTefaRvfRvXjynxUy90ff1UUTFr9mjucwx()vkDUXFrbYKiu47Ntvg)F(VqitcqFf)BHLnWs5VTqGOTuOUHFsekySqitcq)Ru6CJ)2Qz7qVsIKhW3F)xkGkUK(p)CQYF(VsPZn(lnnmx(9FHqMeG(k(9ZjY(Z)vkDUXFlByCRGVkkZYFHqMeG(k(9ZPd(Z)fczsa6R4FpeIl83wiq0w0KzA)KSl1cHmjafR5YfRnq7NB4ASDcmKXJh54xWAUCXAdFGq8TWucTXojcf8ujkGkyTQiW6bWAhG1ouSUfceTTzss8lQN5MHfczsakwp4FLsNB83dHLYKa)9qy(qQWFNeHcEQef47NtK7p)xiKjbOVI)9qiUWF5fRhaR5fRBHarBdOcM0yHqMeGI1C5I1LDj0DyydOcM0yzGqrcR5YfRl7sO7WWgqfmPXYGQKHbRvfRBHPeABNvW3RNMawZLlwx2Lq3HHnGkysJLbvjddwRkwpEEW6b)Ru6CJ)EiSuMe4VhcZhsf(7qj7mu6rxMpGkysZ3pNo5p)xiKjbOVI)9qiUWF5fRBHarBPqDJSyHqMeGI1JW6YUe6omSvOL6Y4REnPXYGQKHbRDkwpESEewJ6YqYsb0SKnwRkw7aEW6ry9aynVy9HWszsa7qj7mu6rxMpGkysdwZLlwx2Lq3HHnGkysJLbvjddw7uSwfEW6b)Ru6CJ)EiSuMe4VhcZhsf(l)DjzO0JUmFfA57NZX)N)leYKa0xX)Eiex4VhclLjbStIqbpvIcG1JW6bWAuxgsyTtX6XWjyTdfRBHarBrtMP9tYUuleYKauS2HaRrgpy9G)vkDUXFpewktc83dH5dPc)L)UKmu6rxMFsek4PsuGVFohJ)8FHqMeG(k(3dH4c)TfceTLkmN9gIyuBHqMeGI1JWAEX6dHLYKaw(7sYqPhDz(jrOGNkrbW6rynVy9HWszsal)DjzO0JUmFfAbRhH1LDj0DyyPcZzVHig1wx()vkDUXFpewktc83dH5dPc)DOKDgk9OlZtfMZEdrmQ)(5CS(Z)fczsa6R4FpeIl83wiq026wHODRwiKjbOy9iSMxSE6IIARBfI2TAD5)xP05g)9qyPmjWFpeMpKk83Hs2zO0JUmFDRq0U1VFoDi)Z)vkDUXFPPH5YV)leYKa0xXVFovHN)8FHqMeG(k(3clBGLYFvwOwguLmmyncSMN)kLo34VfHq8sPZn8K00)LKM2hsf(BzxcDhgF)CQIk)5)cHmja9v8Vfw2alL)I6YqYsb0SKnwRkcS2bo5VsPZn(l)S4S3LVhLjkRq0F)CQcY(Z)fczsa6R4FlSSbwk)TfceTLkmN9gIyuBHqMeGI1JW6bW6dHLYKa2Hs2zO0JUmpvyo7neXOgR5YfRPW0ff1sfMZEdrmQTU8X6b)Ru6CJ)wecXlLo3Wtst)xsAAFiv4VuH5S3qeJ6VFovXb)5)cHmja9v8Vfw2alL)2cbI2sH6gzXcHmja9VsPZn(lZn8sPZn8K00)LKM2hsf(lfQBKLVFovb5(Z)fczsa6R4FLsNB8xMB4LsNB4jPP)ljnTpKk83yzvH893)LpdkBDk9F(5uL)8FHqMeG(k(9ZjY(Z)fczsa6R43pNo4p)xiKjbOVIF)CIC)5)cHmja9v87NtN8N)Ru6CJ)YF7CJ)cHmja9v87NZX)N)Ru6CJ)wHwQlJV61KM)cHmja9v87V)lfQBKL)8ZPk)5)cHmja9v8Vfw2alL)kLopapeqnbdwRkwtbtYaQVfMsOnynxUyntsQhoGOTcLASzG1QI1oGN)kLo34VOaXpfgtucF)CIS)8FHqMeG(k(3clBGLYFpewktcyNeHcEQef4VsPZn(lfKwT3mea(F)C6G)8FHqMeG(k(3clBGLYFpewktcyNeHcEQefaRhH1LDj0DyybKa)eKQLbvjddwRkw7eSEewZlwx2Lq3HHTcTuxgF1RjnwgiuK(Ru6CJ)ojcf8ujkW3pNi3F(VsPZn(BwRlr6CdV4YK)cHmja9v87NtN8N)leYKa0xX)wyzdSu(lQldjS2PynYXdwZLlwpawpDrrTvOL6Y4REnPXs3HbwpcRrDzizPaAwYgRvfbwJC8G1d(xP05g)ffitIqHVFoh)F(VqitcqFf)BHLnWs5VdG18I1TqGOTtsgupQldjleYKauSMlxSg1LHKLcOzjBSwvey9yWdwpiwpcRhaR5fRNUOO2k0sDz8vVM0yHXPHGcu)ejpfQBKfSMlxSEaS2aTFUHRX2jWqMkEKJFbRhH1txuuBfAPUm(QxtASmOkzyWAvXAvgpwpiwp4FLsNB8xajWpbP(9Z5y8N)leYKa0xX)wyzdSu(7ayDleiA7KKb1J6YqYcHmjafR5YfRrDzizPaAwYgRDkw7aEWAUCX6PlkQTcTuxgF1RjnwguLmmyTtXANG1dI1JWAEX6dHLYKaw(7sYqPhDz(jrOGNkrb(Ru6CJ)krKQtI05gF)Cow)5)cHmja9v8Vfw2alL)oaw3cbI2ojzq9OUmKSqitcqXAUCXAuxgswkGMLSXANI1oGhSEqSEewZlwFiSuMeWYFxsgk9OlZxHwW6rynVy9HWszsal)DjzO0JUm)KiuWtLOa)vkDUXFlQL14nnlDg((50H8p)xiKjbOVI)TWYgyP83wiq0wku3WpjcfmwiKjbOy9iSMxSUSlHUddlGe4NGuTmqOiH1JW6bW6IAHPemyncSgzynxUy9ayntsQhoGOT19aQq02mWAvXAv4bRhH1mjPE4aI2kuQXMbwRkwRcpy9Gy9G)vkDUXFrbIN5Au)9ZPk88N)Ru6CJ)sH6gg)mB4VqitcqFf)(5ufv(Z)fczsa6R4FlSSbwk)D6IIAx32VOEMekbRl))kLo34VTA2o0RKi5b89ZPki7p)xiKjbOVI)TWYgyP83wiq0wku3WpjcfmwiKjbO)vkDUXFB1SDOxjrYd47V)BzxcDhg)5Ntv(Z)fczsa6R4FlSSbwk)LxSEaSUfceTLc1nYIfczsakwZLlwFiSuMeWYFxsgk9OlZxHwWAUCX6dHLYKa2Hs2zO0JUmFavWKgSEqSMlxSUfMsOTDwbFVEAcyTtXAK5K)kLo34VvOL6Y4REnP57NtK9N)leYKa0xX)wyzdSu(BleiAlfQBKfleYKauSEewpDrrTvOL6Y4REnPX6Y)VsPZn(BfAPUm(QxtA((50b)5)cHmja9v8Vfw2alL)YKK6HdiARqPglmoPPny9iSMctxuuBavWKglDhgy9iSEaSwkDEaEiGAcgSwvSMcMKbuFlmLqBWAUCXAMKupCarBfk1yZaRvfRhppy9G)vkDUXFdOcM089ZjY9N)leYKa0xX)wyzdSu(lVyntsQhoGOTcLASW4KM28xP05g)nGkysZ3pNo5p)xiKjbOVI)TWYgyP83PlkQTcTuxgF1RjnwguLmmyTQynYCcwZLlw3ctj02oRGVxpnbS2Py9455VsPZn(l)TZn((5C8)5)cHmja9v8VHuH)QuiqrieGz8ZDJ)kLo34VUgWNnu)(5Cm(Z)fczsa6R4FdPc)L4AA26A8kxcfcpFIBvuc)vkDUXFDnGpBO(93)LkmN9gIyu)NFov5p)xiKjbOVI)TWYgyP8xuxgsyTQiW6XIhSEewpawZlwFiSuMeWojcf8ujkawZLlwZlwx2Lq3HHDsek4Psualdeksy9G)vkDUXFPcZzVHig1F)CIS)8FHqMeG(k(3clBGLYFPW0ff1sfMZEdrmQTU8)Ru6CJ)krKQtI05gF)C6G)8FHqMeG(k(3clBGLYFPW0ff1sfMZEdrmQTU8)Ru6CJ)wulRXBAw6m893F)3dGzYnEorgpQmw8mgQ4qAvzmCGt(7qHfzO08xKpiVhtCoM5CC7ydRX6ZQbSoR8xwJ1OldRh7uavCj9yhRzW4o3KbuS2SvaRf3ERsduSUOwcLGXIpH8ygawRIkJnSECtyC5ZFznqXAP05gy9yNFwC27Y3JYeLvi6XUfFcFAmx5VSgOy94XAP05gynjnTXIp9xXTvVS)oUaNts(x(SfnjWFDyynYRXbkUnqX6jGUmaRlBDknwpbLzySynY7sb43gSo2WHQwyvuxcwlLo3WG1BqqYIpjLo3Wy5ZGYwNsJaLigNXNKsNByS8zqzRtPDebhIRYkeT05g4tsPZnmw(mOS1P0oIGd0DP4tomS(gcFJ6TXAMKuSE6IIcuS20sBW6jGUmaRlBDknwpbLzyWAjOynFg4q5VDNHsSonynDdWIpjLo3Wy5ZGYwNs7icomHW3OEBVPL2GpjLo3Wy5ZGYwNs7ico4VDUb(Ku6CdJLpdkBDkTJi4OcTuxgF1Rjn4t4tomSg514af3gOynCamKW6oRaw3QbSwk9YW60G1YHKezsal(Ku6CddcAAyU8B8jP05gghrWrzdJBf8vrzwWNKsNByCebhhclLjbuiKkGysek4PsuafoeIlGOfceTfnzM2pj7sTqitcq5Y1aTFUHRX2jWqgpEKJFHlxdFGq8TWucTXojcf8ujkGkQIyah4qBHarBBMKe)I6zUzyHqMeGoi(Ku6CdJJi44qyPmjGcHubedLSZqPhDz(aQGjnkCiexabVdWBleiABavWKgleYKauUCl7sO7WWgqfmPXYaHIexULDj0DyydOcM0yzqvYWOAlmLqB7Sc(E90e4YTSlHUddBavWKgldQsggvhppdIpjLo3W4icooewktcOqivab)DjzO0JUmFfArHdH4ci4TfceTLc1nYIfczsa6OYUe6omSvOL6Y4REnPXYGQKHXPJFeQldjlfqZs2Q6aEgnaVhclLjbSdLSZqPhDz(aQGjnC5w2Lq3HHnGkysJLbvjdJtvHNbXNKsNByCebhhclLjbuiKkGG)UKmu6rxMFsek4PsuafoeIlG4qyPmjGDsek4PsuGrdG6YqYPJHtCOTqGOTOjZ0(jzxQfczsaQdbY4zq8jP05gghrWXHWszsafcPcigkzNHsp6Y8uH5S3qeJAfoeIlGOfceTLkmN9gIyuBHqMeGoI3dHLYKaw(7sYqPhDz(jrOGNkrbgX7HWszsal)DjzO0JUmFfAzuzxcDhgwQWC2BiIrT1Lp(Ku6CdJJi44qyPmjGcHubedLSZqPhDz(6wHODRkCiexarleiABDRq0UvleYKa0r8oDrrT1Tcr7wTU8XNKsNByCebh00WC534tsPZnmoIGJIqiEP05gEsAAfcPcik7sO7WqHefHYc1YGQKHbbp4tsPZnmoIGd(zXzVlFpktuwHOvirrG6YqYsb0SKTQiCGtWNKsNByCebhfHq8sPZn8K00kesfqqfMZEdrmQvirr0cbI2sfMZEdrmQTqitcqhnWHWszsa7qj7mu6rxMNkmN9gIyuZLlfMUOOwQWC2BiIrT1L)G4tsPZnmoIGdMB4LsNB4jPPviKkGGc1nYIcjkIwiq0wku3ilwiKjbO4tsPZnmoIGdMB4LsNB4jPPviKkGiwwvi4t4tsPZnm2YUe6omquHwQlJV61Kgfsue8oqleiAlfQBKfleYKauUCpewktcy5VljdLE0L5RqlC5EiSuMeWouYodLE0L5dOcM0mixUTWucTTZk471ttWPiZj4tsPZnm2YUe6omCebhvOL6Y4REnPrHefrleiAlfQBKfleYKa0rtxuuBfAPUm(QxtASU8XNKsNBySLDj0Dy4icocOcM0OqIIGjj1dhq0wHsnwyCstBgrHPlkQnGkysJLUdJrdiLopapeqnbJQuWKmG6BHPeAdxUmjPE4aI2kuQXMHQJNNbXNKsNBySLDj0Dy4icocOcM0OqIIGxMKupCarBfk1yHXjnTbFskDUHXw2Lq3HHJi4G)25gkKOiMUOO2k0sDz8vVM0yzqvYWOkYCcxUTWucTTZk471ttWPJNh8jP05ggBzxcDhgoIGdxd4ZgQkesfqOuiqrieGz8ZDd8jP05ggBzxcDhgoIGdxd4ZgQkesfqqCnnBDnELlHcHNpXTkkb8j8jP05gglvyo7neXOgbvyo7neXOwHefbQldjvrmw8mAaEpewktcyNeHcEQefGlxEl7sO7WWojcf8ujkGLbcfPbXNKsNBySuH5S3qeJAhrWHerQojsNBOqIIGctxuulvyo7neXO26YhFskDUHXsfMZEdrmQDebhf1YA8MMLodkKOiOW0ff1sfMZEdrmQTU8XNWNKsNBySuOUrwqGce)uymrjOqIIqkDEaEiGAcgvPGjza13ctj0gUCzss9WbeTvOuJndvDap4tsPZnmwku3iloIGdkiTAVzia8virrCiSuMeWojcf8ujka(Ku6CdJLc1nYIJi4ysek4PsuafsuehclLjbStIqbpvIcmQSlHUddlGe4NGuTmOkzyu1jJ4TSlHUddBfAPUm(QxtASmqOiHpjLo3WyPqDJS4icoYADjsNB4fxMGpjLo3WyPqDJS4icoqbYKiuqHefbQldjNIC8WL7atxuuBfAPUm(QxtAS0Dymc1LHKLcOzjBvrGC8mi(Ku6CdJLc1nYIJi4aqc8tqQkKOigG3wiq02jjdQh1LHKfczsakxUOUmKSuanlzRkIXGNbhnaVtxuuBfAPUm(QxtASW40qqbQFIKNc1nYcxUdyG2p3W1y7eyitfpYXVmA6IIARql1LXx9AsJLbvjdJQQm(bheFskDUHXsH6gzXreCirKQtI05gkKOigOfceTDsYG6rDzizHqMeGYLlQldjlfqZs2o1b8WL70ff1wHwQlJV61KgldQsggN6KbhX7HWszsal)DjzO0JUm)KiuWtLOa4tsPZnmwku3iloIGJIAznEtZsNbfsued0cbI2ojzq9OUmKSqitcq5Yf1LHKLcOzjBN6aEgCeVhclLjbS83LKHsp6Y8vOLr8EiSuMeWYFxsgk9OlZpjcf8ujka(Ku6CdJLc1nYIJi4afiEMRrTcjkIwiq0wku3WpjcfmwiKjbOJ4TSlHUddlGe4NGuTmqOinAGIAHPemiqgxUdWKK6HdiABDpGkeTndvvHNrmjPE4aI2kuQXMHQQWZGdIpjLo3WyPqDJS4icoOqDdJFMnGpjLo3WyPqDJS4icoA1SDOxjrYdqHefX0ff1UUTFr9mjucwx(4tomSwkDUHXsH6gzXreCGcepZ1OwHefrDpGkeTLMMwIcOQkoHl3PlkQDDB)I6zsOeSU8XNCyyTu6CdJLc1nYIJi44acLaQlXZGMbsRqIIOUhqfI2sttlrbuvfNGpjLo3WyPqDJS4icoA1SDOxjrYdqHefrleiAlfQB4NeHcgleYKau8j8jP05ggBSSQqqCaHsa1L4zqZaPvirr0cbI2w3keTB1cHmjaD00ff1YNb8fgqT0DyGpjLo3WyJLvfIJi4afiEMRrTcjkIboewktcyhkzNHsp6Y81Tcr7w5YTfceTffi(QyAGHKfczsa6GJgOOwykbdcKXL7amjPE4aI2w3dOcrBZqvv4zetsQhoGOTcLASzOQk8m4G4tsPZnm2yzvH4icoqbIFkmMOeuirrW7HWszsa7qj7mu6rxMVUviA36ObKsNhGhcOMGrvkysgq9TWucTHlxMKupCarBfk1yZqvhWZG4tsPZnm2yzvH4icoYADjsNB4fxMGpjLo3WyJLvfIJi4aqc8tqQkKOiKsNhGhcOMGrvvgnaVmjPE4aI2kuQXcJtAAdxUmjPE4aI2kuQX6YFWr8EiSuMeWouYodLE0L5RBfI2TIpjLo3WyJLvfIJi4GcsR2BgcaFfsuehclLjbStIqbpvIcGpjLo3WyJLvfIJi4ysek4PsuafsuehclLjbStIqbpvIcGpjLo3WyJLvfIJi4afitIqbfsueOUmKSuanlzRkcKJh8jP05ggBSSQqCebhasGFcsvHefbVTqGOTtsgupQldjleYKa0r8EiSuMeWouYodLE0L5PcZzVHig1Jyss9WbeTvOuJndvLsNBybKa)eKQTSlHUdd8jP05ggBSSQqCebhseP6KiDUHcjkIbAHarBPqDd)KiuWyHqMeGYLlVhclLjbSdLSZqPhDz(6wHODRC5I6YqYsb0SKTtDapC5oDrrTvOL6Y4REnPXYGQKHXPozWr8EiSuMeWYFxsgk9OlZpjcf8ujkWiEpewktcyhkzNHsp6Y8uH5S3qeJA8jP05ggBSSQqCebhf1YA8MMLodkKOigOfceTLc1n8tIqbJfczsakxU8EiSuMeWouYodLE0L5RBfI2TYLlQldjlfqZs2o1b8m4iEpewktcy5VljdLE0L5RqlJ49qyPmjGL)UKmu6rxMFsek4PsuGr8EiSuMeWouYodLE0L5PcZzVHig14tsPZnm2yzvH4icoaKa)eKQcjkIwiq02jjdQh1LHKfczsa6iMKupCarBfk1yZqvP05gwajWpbPAl7sO7WaFskDUHXglRkehrWbfQBy8ZSb8jP05ggBSSQqCebhOaXZCnQvirrWBleiABDRq0UvleYKa0rmjPE4aI2w3dOcrBZq1IAHPemoeQWZOwiq0wku3WpjcfmwiKjbO4tsPZnm2yzvH4icoqbYKiuqHefrDpGkeTLMMwIcOQkoHl3PlkQDDB)I6zsOeSU8XNCyyTu6CdJnwwvioIGduG4zUg1kKOiQ7buHOT000suavvXjC5oW0ff1UUTFr9mjucwx(J4TfceTTUviA3Qfczsa6G4tomSwkDUHXglRkehrWXbekbuxINbndKwHefrDpGkeTLMMwIcOQkobFskDUHXglRkehrWrRMTd9kjsEakKOiAHarBPqDd)KiuWyHqMeG(93)d]] )


end
