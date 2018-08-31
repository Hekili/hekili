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
            charges = function () return talent.master_of_the_glaive.enabled and 2 or nil end,
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


    spec:RegisterPack( "Havoc", 20180830.2118, [[dOep2aqieYJKeSjvKpjPGgLKQoLKkRssb8kkuZcr6wQsyxu5xQqdtvQJrsAzKe9mscttvsUgfsBtvs9njLQXrHOZjPqTojfzEsk5EiyFKuDqjfYcjP8qke0eLeIlkPuQnQkrPpkPansjf1jLesTsjPzQkrXnLuk2jIyOui0sLeQNQstfH6QQsu9vjHK9c5Vu1GP0HjwSIESctgvxgSzv1NjrJMcoTOxljA2iDBj2TWVvA4iQJlPuYYr55KA6sDDkA7QIVRcgVQe58QOwpfcmFsy)qnsveXOlxAarIkFRQr(2ivXBNkvv1A3OQIU9zYa6swgvkkb0nKcGU1S8Sd0LSCMUchrm6Qxt2aqxdDtwxthpQmBdMt3ylh1zXKkDUXGj)(OolJJt6opo)Yl4WZrYS9NuqF0iYGkwsU(OrSI9veOSHVMnJgy(AwE2HtNLb6ontAxrhOj6YLgqKOY3QAKVnsv82PsvFxJvHrIUAYWarIrR9AhD5GEGUvaBRz5zhyBfbkBGT1Sz0adxTcyRHUjRRPJhvMTbZPBSLJ6SysLo3yWKFFuNLXXjDNhNF5fC45iz2(tkOpAezqfljxF0iwX(kcu2WxZMrdmFnlp7WPZYaxTcyBnYuPPUXwv8MuSvLVv1iX2xGT14A69BS1iwBWvXvRa2wrjSidL6AcxTcy7lW2xUodLyBfbkBGTQrfoOX2IujOX2YQBS9L1KDgBvcbWKo3aBjBYa6zSTIjPgeB5S8bcSvco2AgKzaphTmPaPy7bd5Wa2EiPuSnlKLrJTTbaBRTmfA2NX29JTmySLceCPZn0oCvC1kGTgHgKqjORjC1kGTVaBRrCoWXwJWn0MfaBRnIYC4WvRa2(cSTIHY(aCSTfMsO95hBhgGrLy7Fzyljqb0PgBLzsZ(SdxTcy7lW2kgk7dWX2Y(afiASvMjn7e0y7NTfSLmlxw2NX2dgGaBJTXwtnWX2)YW2AZwGOnlo0LM6wJigDJLvekIyejQIigDHqMuGJudDhSSbwkOBluiAxzlq0MfheYKcCS9e2on)Fhzgqwya3X3db6kJo3aDFGqj8nPEg0mqAuJirLiIrxiKjf4i1q3blBGLc6wp2(iSuMuWDqYodL()Y8LTarBwWwfkW2wOq0Upq9fr3a7Sdczsbo2wh2EcBRhBhgeMsqJTeWwvITkuGT1JTmj5E4bI2v2hOar7YaBvhBv9n2EcBzsY9WdeTt4CTldSvDSv13yBDyBDORm6Cd09dupZuBa1isubIy0fczsbosn0DWYgyPGUeHTpclLjfChKSZqP)VmFzlq0MfS9e2wp2kJoFapeqjbn2Qo2YbDYaUVfMsO1yRcfyltsUhEGODcNRDzGTQJTQ4n2wh6kJo3aD)a1pfgtucOgrYRqeJUYOZnq3SuwQ05gEXKjOleYKcCKAOgrIrreJUqitkWrQHUdw2alf0vgD(aEiGscASvDSvvS9e2wp2se2YKK7HhiANW5Ah8sPU1yRcfyltsUhEGODcNRDMKX26W2tylry7JWszsb3bj7mu6)lZx2ceTzbDLrNBGUWzWpbPGAejVgrm6cHmPahPg6oyzdSuq3hHLYKcUjv4GNlXaqxz05gOlhK2GxFaaYOgrsTJigDHqMuGJudDhSSbwkO7JWszsb3KkCWZLyaORm6Cd0Dsfo45smauJiXireJUqitkWrQHUdw2alf0LiSTfkeTRSfiAZIdczsbo2EcBjcBBHcr74qzd)KkCq7GqMuGJTNWwXiayzdoZyUMb3pmiR2XKOsSvDS9n6kJo3aD)a1Zm1gqnIKAmIy0fczsbosn0DWYgyPGUFt2zhh(5iBSvDcy7REJUYOZnq3pqNuHdOgrIQVreJUqitkWrQHUdw2alf0LiSTfkeTBsZG7)MSZoiKjf4y7jSLiS9ryPmPG7GKDgk9)L55cRsVMkAdy7jSLjj3dpq0oHZ1UmWw1Xwz05go4m4NGuCJDP89qGUYOZnqx4m4NGuqnIevvfrm6cHmPahPg6oyzdSuq36X2wOq0oou2WpPch0oiKjf4yRcfylry7JWszsb3bj7mu6)lZx2ceTzbBvOaB)MSZoo8Zr2yBTWwv8gBvOaBNM)VRaTuwgzdRo1oguKm0yBTWwJIT1HTNWwIW2hHLYKcoY7sZqP)Vm)KkCWZLyay7jSLiS9ryPmPG7GKDgk9)L55cRsVMkAdORm6Cd0vIinKuPZnqnIevvjIy0fczsbosn0DWYgyPGU1JTTqHODCOSHFsfoODqitkWXwfkWwIW2hHLYKcUds2zO0)xMVSfiAZc2Qqb2(nzNDC4NJSX2AHTQ4n2wh2EcBjcBFewktk4iVlndL()Y8fOfS9e2se2(iSuMuWrExAgk9)L5NuHdEUedaBpHTeHTpclLjfChKSZqP)Vmpxyv61urBaDLrNBGUddYQ96MLvcOgrIQQarm6cHmPahPg6oyzdSuq3wOq0UjndU)BYo7GqMuGJTNWwMKCp8ar7eox7YaBvhBLrNB4GZGFcsXn2LY3db6kJo3aDHZGFcsb1isu9viIrxz05gOlhkBO9ZSb0fczsbosnuJirvJIigDHqMuGJudDhSSbwkOBzFGceTJN6wIbGTQJTQAuSvHcSDA()U1S973ZKqj4mjJUYOZnq3pqNuHdOgrIQVgrm6cHmPahPg6oyzdSuq3wOq0oou2WpPch0oiKjf4ORm6Cd0TnW2dELujFauJA0LdFXK2iIrKOkIy0vgDUb6kM96LULrLOleYKcCKAOgrIkreJUpc1eq3wOq0UFY0TFs3L7GqMuGJTkuGTAO9Znm1UobMkF7Ff5b2Qqb2QjduQVfMsO1Ujv4GNlXaufBvNa2wp2QcS9fyBluiAxZKK63VNzMHdczsbo2wh6cHmPahPg6kJo3aDFewktkGUpcZhsbq3jv4GNlXaqnIevGigDFeQjGUeHT1JTeHTTqHODbuaDQDqitkWXwfkW2XUu(EiCbuaDQDmq4NXwfkW2XUu(EiCbuaDQDmOizOXw1X2wykH21zb8965jGTkuGTJDP89q4cOa6u7yqrYqJTQJTV(n2wh6cHmPahPg6kJo3aDFewktkGUpcZhsbq3ds2zO0)xMpGcOtnQrK8keXO7Jqnb0LiSTfkeTJdLnYHdczsbo2EcBh7s57HWvGwklJSHvNAhdksgASTwy7RX2ty73KD2XHFoYgBvhBvXBS9e2wp2se2(iSuMuWDqYodL()Y8buaDQXwfkW2XUu(EiCbuaDQDmOizOX2AHTQ(gBRdDHqMuGJudDLrNBGUpclLjfq3hH5dPaOl5DPzO0)xMVaTGAejgfrm6(iutaDFewktk4MuHdEUedaBpHT1JTFt2zSTwyBTBuS9fyBluiA3pz62pP7YDqitkWX2AaSvLVX26qxiKjf4i1qxz05gO7JWszsb09ry(qka6sExAgk9)L5NuHdEUeda1isEnIy09rOMa62cfI2XfwLEnv0gCqitkWX2tylry7JWszsbh5DPzO0)xMFsfo45smaS9e2se2(iSuMuWrExAgk9)L5lqly7jSDSlLVhchxyv61urBWzsgDHqMuGJudDLrNBGUpclLjfq3hH5dPaO7bj7mu6)lZZfwLEnv0gqnIKAhrm6(iutaDBHcr7kBbI2S4GqMuGJTNWwIW2P5)7kBbI2S4mjJUqitkWrQHUYOZnq3hHLYKcO7JW8Hua09GKDgk9)L5lBbI2SGAejgjIy0vgDUb6YtnZKCJUqitkWrQHAej1yeXORm6Cd0DSH2Sa(IOmhOleYKcCKAOgrIQVreJUqitkWrQHUYOZnq3HqPEz05gEAQB0DWYgyPGUkhChdksgASLa2(gDPPU9Hua0DSlLVhcuJirvvreJUqitkWrQHUdw2alf09BYo74WphzJTQtaBvHrrxz05gOl5CuP3KS)ZeLfiAuJirvvIigDHqMuGJudDLrNBGUdHs9YOZn80u3O7GLnWsbDBHcr74cRsVMkAdoiKjf4y7jSTES9ryPmPG7GKDgk9)L55cRsVMkAdyRcfylhMM)VJlSk9AQOn4mjJT1HU0u3(qka6YfwLEnv0gqnIevvbIy0fczsbosn0vgDUb6YmdVm6Cdpn1n6oyzdSuq3wOq0oou2ihoiKjf4Oln1TpKcGUCOSroqnIevFfIy0fczsbosn0vgDUb6YmdVm6Cdpn1n6stD7dPaOBSSIqrnQrxYmySLP0iIrKOkIy0fczsbosnuJirLiIrxiKjf4i1qnIevGigDHqMuGJud1isEfIy0fczsbosnuJiXOiIrxz05gOl5TZnqxiKjf4i1qnIKxJigDLrNBGUfOLYYiBy1PgDHqMuGJud1OgD5cRsVMkAdiIrKOkIy0fczsbosn0DWYgyPGUFt2zSvDcyRr(gBpHT1JTeHTpclLjfCtQWbpxIbGTkuGTeHTJDP89q4MuHdEUedWXaHFgBRdDLrNBGUCHvPxtfTbuJirLiIrxiKjf4i1q3blBGLc6YHP5)74cRsVMkAdotYORm6Cd0vIinKuPZnqnIevGigDHqMuGJudDhSSbwkOlhMM)VJlSk9AQOn4mjJUYOZnq3Hbz1EDZYkbuJA0DSlLVhceXisufrm6cHmPahPg6oyzdSuqxIW26X2wOq0oou2ihoiKjf4yRcfy7JWszsbh5DPzO0)xMVaTGTkuGTpclLjfChKSZqP)VmFafqNASToSvHcSTfMsODDwaFVEEcyBTWwvAu0vgDUb6wGwklJSHvNAuJirLiIrxiKjf4i1q3blBGLc62cfI2XHYg5WbHmPahBpHTtZ)3vGwklJSHvNANjz0vgDUb6wGwklJSHvNAuJirfiIrxiKjf4i1q3blBGLc6YKK7HhiANW5Ah8sPU1y7jSLdtZ)3fqb0P2X3db2EcBRhBLrNpGhcOKGgBvhB5Goza33ctj0ASvHcSLjj3dpq0oHZ1UmWw1X2x)gBRdDLrNBGUbuaDQrnIKxHigDHqMuGJudDhSSbwkOlryltsUhEGODcNRDWlL6wJUYOZnq3akGo1OgrIrreJUqitkWrQHUdw2alf0DA()Uc0szzKnS6u7yqrYqJTQJTQ0OyRcfyBlmLq76Sa(E98eW2AHTV(n6kJo3aDjVDUbQrK8AeXOleYKcCKAOBifaDvkuyiukW0(5Ub6kJo3aDn1GpBOGAej1oIy0fczsbosn0nKcGUutDZwtTx5s5q4jtnlIsaDLrNBGUMAWNnuqnQrxou2ihiIrKOkIy0fczsbosn0DWYgyPGUYOZhWdbusqJTQJTCqNmG7BHPeAn2Qqb2YKK7HhiANW5AxgyR6yRkEJUYOZnq3pq9tHXeLaQrKOseXOleYKcCKAO7GLnWsbDFewktk4MuHdEUedaDLrNBGUCqAdE9baiJAejQarm6cHmPahPg6oyzdSuq3hHLYKcUjv4GNlXaW2ty7yxkFpeo4m4NGuCmOizOXw1XwJITNWwIW2XUu(EiCfOLYYiBy1P2XaHFgDLrNBGUtQWbpxIbGAejVcrm6kJo3aDZszPsNB4ftMGUqitkWrQHAejgfrm6cHmPahPg6oyzdSuq3Vj7m2wlS9vVXwfkW26X2P5)7kqlLLr2WQtTJVhcS9e2(nzNDC4NJSXw1jGTV6n2wh6kJo3aD)aDsfoGAejVgrm6cHmPahPg6oyzdSuq36XwIW2wOq0UjndU)BYo7GqMuGJTkuGTFt2zhh(5iBSvDcyBT)gBRdBpHT1JTeHTtZ)3vGwklJSHvNAh8sneCG7NN9COSroWwfkW26Xwn0(5gMAxNatLQ6Ff5b2EcBNM)VRaTuwgzdRo1oguKm0yR6yRQVgBRdBRdDLrNBGUWzWpbPGAej1oIy0fczsbosn0DWYgyPGU1JTTqHODtAgC)3KD2bHmPahBvOaB)MSZoo8Zr2yBTWwv8gBvOaBNM)VRaTuwgzdRo1oguKm0yBTWwJIT1HTNWwIW2hHLYKcoY7sZqP)Vm)KkCWZLyaORm6Cd0vIinKuPZnqnIeJerm6cHmPahPg6oyzdSuq36X2wOq0UjndU)BYo7GqMuGJTkuGTFt2zhh(5iBSTwyRkEJT1HTNWwIW2hHLYKcoY7sZqP)VmFbAbBpHTeHTpclLjfCK3LMHs)Fz(jv4GNlXaqxz05gO7WGSAVUzzLaQrKuJreJUqitkWrQHUdw2alf0LiSTfkeTJdLn8tQWbTdczsbo2EcBjcBh7s57HWbNb)eKIJbc)m2EcBfJaGLn4mJ5AgC)WGSAhtIkXw1X23ORm6Cd09dupZuBa1isu9nIy0vgDUb6YHYgA)mBaDHqMuGJud1isuvveXOleYKcCKAO7GLnWsbDNM)VBnB)(9mjucotYORm6Cd0TnW2dELujFauJirvvIigDHqMuGJudDhSSbwkOBluiAhhkB4NuHdAheYKcC0vgDUb62gy7bVsQKpaQrnQr3hGPZnqKOY3QAKVnsv(2PY3Qqv09GWImuQr3kQAuftsfnj1G1e2ITeBaW2SqEzn2(xg2wd5WxmPDneBzqTLzYao2Q3cGTIzVfPbo2omiHsq7WvFzYaWwvRjS9LhAtYKxwdCSvgDUb2wdfZE9s3YOYAOdx9LjdaBvv1AcBF5H2Km5L1ahBLrNBGT1qY5OsVjz)Njklq01qhUkUAfDH8YAGJTVgBLrNBGT0u3AhUk6sMT)KcOBfW2AwE2b2wrGYgyBnBgnWWvRa2AOBY6A64rLzBWC6gB5OolMuPZngm53h1zzCCs35X5xEbhEosMT)Kc6JgrguXsY1hnIvSVIaLn81Sz0aZxZYZoC6SmWvRa2wJmvAQBSvfVjfBv5BvnsS9fyBnUME)gBnI1gCvC1kGTvuclYqPUMWvRa2(cS9LRZqj2wrGYgyRAuHdASTivcASTS6gBFznzNXwLqamPZnWwYMmGEgBRysQbXwolFGaBLGJTMbzgWZrltkqk2EWqomGThskfBZczz0yBBaW2AltHM9zSD)yldgBPabx6CdTdxfxTcyRrObjuc6AcxTcy7lW2AeNdCS1iCdTzbW2AJOmhoC1kGTVaBRyOSpahBBHPeAF(X2Hbyuj2(xg2scuaDQXwzM0Sp7WvRa2(cSTIHY(aCSTSpqbIgBLzsZobn2(zBbBjZYLL9zS9GbiW2yBS1udCS9VmST2SfiAZIdxfxTcyBT9lbdZg4y7e(ldW2XwMsJTtqzgAh2wJgdGCRX2yJxyqyLVjfBLrNBOX2nOND4QYOZn0oYmySLP0e(urxjUQm6CdTJmdgBzkTXeokMklq0sNBGRkJo3q7iZGXwMsBmHJ)D54QvaBVHqwByBSLjjhBNM)pWXwDlTgBNWFza2o2YuASDckZqJTsWXwYm4fK3UZqj2MASLVb4WvLrNBODKzWyltPnMWrDiK1g22RBP14QYOZn0oYmySLP0gt4i5TZnWvLrNBODKzWyltPnMWXc0szzKnS6uJRIRwbST2(LGHzdCSfEa2zSTZcGTTbaBLrVmSn1yR8ijvMuWHRkJo3qtqm71lDlJkXvLrNBOnMWXhHLYKcKgsbimPch8CjgaPpc1ei0cfI29tMU9t6UCheYKcCfk0q7NByQDDcmv(2)kYdfk0Kbk13ctj0A3KkCWZLyaQQoH6vXlAHcr7AMKu)(9mZmCqitkWRdxvgDUH2ychFewktkqAifGWbj7mu6)lZhqb0PM0hHAceiQEIAHcr7cOa6u7GqMuGRqXyxkFpeUakGo1ogi8Zkum2LY3dHlGcOtTJbfjdT6TWucTRZc471ZtqHIXUu(EiCbuaDQDmOizOv)1VRdxvgDUH2ychFewktkqAifGa5DPzO0)xMVaTq6Jqnbce1cfI2XHYg5WbHmPa)0yxkFpeUc0szzKnS6u7yqrYqxRxF6BYo74WphzRUkEFQEIEewktk4oizNHs)Fz(akGo1kum2LY3dHlGcOtTJbfjdDTu9DD4QYOZn0gt44JWszsbsdPaeiVlndL()Y8tQWbpxIbq6JqnbcpclLjfCtQWbpxIbCQ(Vj7CTQDJ(IwOq0UFY0TFs3L7GqMuGxdOY31HRkJo3qBmHJpclLjfinKcq4GKDgk9)L55cRsVMkAdK(iutGqluiAhxyv61urBWbHmPa)erpclLjfCK3LMHs)Fz(jv4GNlXaor0JWszsbh5DPzO0)xMVaTCASlLVhchxyv61urBWzsgxvgDUH2ychFewktkqAifGWbj7mu6)lZx2ceTzH0hHAceAHcr7kBbI2S4GqMuGFIOP5)7kBbI2S4mjJRkJo3qBmHJ8uZmj34QYOZn0gt44ydTzb8frzoWvLrNBOnMWXHqPEz05gEAQBsdPaeg7s57HG08tq5G7yqrYqt4nUQm6CdTXeosohv6nj7)mrzbIM08t4BYo74WphzRobvyuCvz05gAJjCCiuQxgDUHNM6M0qkabUWQ0RPI2aP5NqluiAhxyv61urBWbHmPa)u9pclLjfChKSZqP)Vmpxyv61urBqHcomn)Fhxyv61urBWzsUoCvz05gAJjCKzgEz05gEAQBsdPae4qzJCqA(j0cfI2XHYg5WbHmPahxvgDUH2ychzMHxgDUHNM6M0qkaHyzfHIRIRkJo3q7g7s57HGqbAPSmYgwDQjn)eiQ(wOq0oou2ihoiKjf4ku8iSuMuWrExAgk9)L5lqlku8iSuMuWDqYodL()Y8buaDQRtHIwykH21zb8965julvAuCvz05gA3yxkFpegt4ybAPSmYgwDQjn)eAHcr74qzJC4GqMuGFAA()Uc0szzKnS6u7mjJRkJo3q7g7s57HWychdOa6utA(jWKK7HhiANW5Ah8sPU1N4W08)DbuaDQD89qCQEz05d4HakjOvNd6KbCFlmLqRvOGjj3dpq0oHZ1Umu)1VRdxvgDUH2n2LY3dHXeogqb0PM08tGiMKCp8ar7eox7Gxk1TgxvgDUH2n2LY3dHXeosE7CdsZpHP5)7kqlLLr2WQtTJbfjdT6Q0Oku0ctj0UolGVxppHA9634QYOZn0UXUu(EimMWrtn4ZgkKgsbiOuOWqOuGP9ZDdCvz05gA3yxkFpegt4OPg8zdfsdPaeOM6MTMAVYLYHWtMAweLaUkUQm6CdTJlSk9AQOnqGlSk9AQOnqA(j8nzNvNGr((u9e9iSuMuWnPch8CjgGcfen2LY3dHBsfo45smahde(56WvLrNBODCHvPxtfTbJjCuIinKuPZnin)e4W08)DCHvPxtfTbNjzCvz05gAhxyv61urBWychhgKv71nlRein)e4W08)DCHvPxtfTbNjzCvCvz05gAhhkBKdcFG6NcJjkbsZpbz05d4HakjOvNd6KbCFlmLqRvOGjj3dpq0oHZ1UmuxfVXvLrNBODCOSromMWroiTbV(aaKjn)eEewktk4MuHdEUedaxvgDUH2XHYg5WychNuHdEUedG08t4ryPmPGBsfo45smGtJDP89q4GZGFcsXXGIKHwDJEIOXUu(EiCfOLYYiBy1P2XaHFgxvgDUH2XHYg5WychZszPsNB4ftMGRkJo3q74qzJCymHJFGoPchin)e(MSZ16vVvOO(P5)7kqlLLr2WQtTJVhItFt2zhh(5iB1j8Q31HRkJo3q74qzJCymHJWzWpbPqA(juprTqHODtAgC)3KD2bHmPaxHIVj7SJd)CKT6eQ931DQEIMM)VRaTuwgzdRo1o4LAi4a3pp75qzJCOqr9AO9Znm1UobMkv1)kYJttZ)3vGwklJSHvNAhdksgA1v911vhUQm6CdTJdLnYHXeokrKgsQ05gKMFc13cfI2nPzW9Ft2zheYKcCfk(MSZoo8Zr21sfVvOyA()Uc0szzKnS6u7yqrYqxlJw3jIEewktk4iVlndL()Y8tQWbpxIbGRkJo3q74qzJCymHJddYQ96MLvcKMFc13cfI2nPzW9Ft2zheYKcCfk(MSZoo8Zr21sfVR7erpclLjfCK3LMHs)Fz(c0YjIEewktk4iVlndL()Y8tQWbpxIbGRwbSvgDUH2XHYg5Wych)a1Zm1gin)eAHcr74qzd)KkCq7GqMuGFIOXUu(EiCWzWpbP4yGWpFQ(HbHPe0euPcf1ZKK7HhiAxzFGceTld1v99jMKCp8ar7eox7YqDvFxxD4QYOZn0oou2ihgt44hOEMP2aP5NarTqHODCOSHFsfoODqitkWpr0yxkFpeo4m4NGuCmq4NpjgbalBWzgZ1m4(Hbz1oMevQ(BCvz05gAhhkBKdJjCKdLn0(z2aUQm6CdTJdLnYHXeo2gy7bVsQKpaP5NW08)DRz73VNjHsWzsgxTcyRm6CdTJdLnYHXeo(bQNzQnqA(ju2hOar74PULyaQRQrvOyA()U1S973ZKqj4mjJRwbSvgDUH2XHYg5WychFGqj8nPEg0mqAsZpHY(afiAhp1TedqDvnkUQm6CdTJdLnYHXeo2gy7bVsQKpaP5NqluiAhhkB4NuHdAheYKcCCvCvz05gAxSSIqj8aHs4Bs9mOzG0KMFcTqHODLTarBwCqitkWpnn)Fhzgqwya3X3dbUQm6CdTlwwrOgt44hOEMP2aP5Nq9pclLjfChKSZqP)VmFzlq0MffkAHcr7(a1xeDdSZoiKjf41DQ(HbHPe0euPcf1ZKK7HhiAxzFGceTld1v99jMKCp8ar7eox7YqDvFxxD4QYOZn0UyzfHAmHJFG6NcJjkbsZpbIEewktk4oizNHs)Fz(YwGOnlNQxgD(aEiGscA15Goza33ctj0AfkysY9WdeTt4CTld1vX76WvLrNBODXYkc1ychZszPsNB4ftMGRkJo3q7ILveQXeocNb)eKcP5NGm68b8qaLe0QR6P6jIjj3dpq0oHZ1o4LsDRvOGjj3dpq0oHZ1otY1DIOhHLYKcUds2zO0)xMVSfiAZcUQm6CdTlwwrOgt4ihK2GxFaaYKMFcpclLjfCtQWbpxIbGRkJo3q7ILveQXeooPch8CjgaP5NWJWszsb3KkCWZLya4QYOZn0UyzfHAmHJFG6zMAdKMFce1cfI2v2ceTzXbHmPa)erTqHODCOSHFsfoODqitkWpjgbalBWzgZ1m4(Hbz1oMevQ(BCvz05gAxSSIqnMWXpqNuHdKMFcFt2zhh(5iB1j8Q34QYOZn0UyzfHAmHJWzWpbPqA(jquluiA3KMb3)nzNDqitkWpr0JWszsb3bj7mu6)lZZfwLEnv0goXKK7HhiANW5AxgQlJo3WbNb)eKIBSlLVhcCvz05gAxSSIqnMWrjI0qsLo3G08tO(wOq0oou2WpPch0oiKjf4kuq0JWszsb3bj7mu6)lZx2ceTzrHIVj7SJd)CKDTuXBfkMM)VRaTuwgzdRo1oguKm01YO1DIOhHLYKcoY7sZqP)Vm)KkCWZLyaNi6ryPmPG7GKDgk9)L55cRsVMkAd4QYOZn0UyzfHAmHJddYQ96MLvcKMFc13cfI2XHYg(jv4G2bHmPaxHcIEewktk4oizNHs)Fz(YwGOnlku8nzNDC4NJSRLkEx3jIEewktk4iVlndL()Y8fOLte9iSuMuWrExAgk9)L5NuHdEUed4erpclLjfChKSZqP)Vmpxyv61urBaxvgDUH2flRiuJjCeod(jifsZpHwOq0UjndU)BYo7GqMuGFIjj3dpq0oHZ1UmuxgDUHdod(jif3yxkFpe4QYOZn0UyzfHAmHJCOSH2pZgWvRa2kJo3q7ILveQXeo(bQNzQnqA(jquluiAxzlq0MfheYKc8tmj5E4bI2v2hOar7Yq9HbHPe01aQ((uluiAhhkB4NuHdAheYKcCCvz05gAxSSIqnMWXpqNuHdKMFcL9bkq0oEQBjgG6QAufkMM)VBnB)(9mjucotY4QvaBLrNBODXYkc1ych)a1Zm1gin)ek7duGOD8u3sma1v1Okuu)08)DRz73VNjHsWzs(erTqHODLTarBwCqitkWRdxTcyRm6CdTlwwrOgt44dekHVj1ZGMbstA(ju2hOar74PULyaQRQrXvLrNBODXYkc1ychBdS9GxjvYhG08tOfkeTJdLn8tQWbTdczsbo6kMTHLHU1muzstuJAec]] )


end
