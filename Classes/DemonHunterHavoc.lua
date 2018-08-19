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


    spec:RegisterPack( "Havoc", 20180719.1735, [[dyu91aqiLWIOsapIkHYMuI(eeuIrbP6ueIvbbvEfvuZIuPBrLG2ff)IuYWiL6yqOLrQWZiv00GGCncfBJqP(gHsgheOoheiwheu18GaUhKSpcPdcbs1cPI8qQeQMivcPlsLazJqqPgjeuCsiqYkHi3ecKYojuTuQeINQutfIARqqj9vQeO2lO)svdMKdJAXk6XszYiUSQntWNjfJMu1PfEnvsZMOBlv7w0Vbgovy5i9CknDjxxbBxH(ovQXtLOZdPmFL0(HAiIqKHBcxhkUo0greS2IfIiigeflDQTyqWWDHMJd3o4MRSMd3j3pCJWWJGgC7Grtcycez42cgOTd36RYHfHxlT0eL(HPPb6AzJ(GKRaKnkluAzJEtRPem1AkWUqYh1YbfieYB1c54uDGOwiRde9UOVdspcZqwN6ry4rqZyJEdUNdHSqqLWjCt46qX1H2iIG1wSqebXGOyPdDGiccCBD8guCXiwIfCtUTb3iRpSyvyXkgRCWnxznhRacyf3QaKyLmSLfReauScH5UgYWGrcJKlyMMrQbHhRWkK1FSYf9DqIvojzYTyvXYNfw1zxVfRO3cgOTJvAEEkxbiXQH0b9KOv8uEDXkojyvP)0laOhRO3oillwfjwnEkAyvdK2th5kgpwrFd07pjCfG0QlwjdxpwnyJudwHW(sSYfzWQhReauSIWDwZXk36FIvL(tpclwSkbL(i1GvZx1PyvbWkcWGrcJKlUEo1Clcpgjenyfw5IgwEkpbRqy9PMlmiXkxKx0ZfwXjbRqyFjw5Imy1JvU1)eRsqHvd2tWQcGvCRIrUowHGgO)Sg6gms6WGvyLlUEo1Ccw5c0aajb4oDbWQcGvUaCRcqAoA3pp3nnaqsaUtxaSYT(tpwXoCiJgpL3GrsNgScRqqLyL9JNYsSYHKB3IvU1F6XQD0DXXk3GbjbRA6FZvSsaqXkkheS6JpllwrVKRtWQcGvDW47plScqXkMqS6IviOWkMqobR4eRycjQaKSeRAGKevasSQayfjS8uESQ0FSQP)nxXk0Tr2owv6dlwXeciXkc4wSkbfw5GEs0kSIjeSYHE2ElwbOyvhm((ZsedCldBzHid3jG2zjezO4icrgUFYt5jqNG7gnQtdgUlw(SmDq)zn0np5P8eSAjwnheemoO3btpXqaUt4MBvas4E8PMlmi90x0ZfSGIRdiYW9tEkpb6eC3OrDAWWn6y1itdEkVXnhvKA8caQVd6pRHowTUIvflFwgHl9D2wNIM5jpLNGvIGvlXk0XQMEMQ5wScfwPdSADfRqhRqhRwGvuoi(p(SmDW47plZDzyllwTUIvuoi(p(SmDW47pltKyLOyfIAJvIGvlXk0XQfyfLdI)JpldtiwZDzyllwTUIvuoi(p(SmmHynrIvIIviQnwjcwjcwjcCZTkajClCPNoy1dlO46eImC)KNYtGob3nAuNgmCVaRgzAWt5nU5OIuJxaq9Dq)zn0XQLyf6yf3Qy8(NVh3IvIIviIvRRyfLdI)JpldtiwtKyLOyLo1gRebU5wfGeUfU0pzkL1CybfhHGid3CRcqc3rVdKCfG0ZdugUFYt5jqNGfuCXargUFYt5jqNG7gnQtdgU5wfJ3)894wSsuScrSAjwHowTaROCq8F8zzycXAUldBzXQ1vSIYbX)XNLHjeRzWbwjcwTeRwGvJmn4P8g3CurQXlaO(oO)Sg6Wn3QaKW9r7(55oSGIl2qKH7N8uEc0j4UrJ60GH7rMg8uEZuYK7jC2oCZTkajCtox69w3)oGfuCXcImC)KNYtGob3nAuNgmCpY0GNYBMsMCpHZ2HBUvbiH7PKj3t4SDybfhbdrgUFYt5jqNG7gnQtdgUfgOOzixiArHvIIcRqiTHBUvbiHBHlNsMCybfhbbImC)KNYtGob3nAuNgmCVaRkw(SmtzKeVWafnZtEkpbRwIvlWQrMg8uEJBoQi14faupHPU6Ts2QhRwIvOJvlWkkhe)hFwgMqSM7YWwwSADfROCq8F8zzycXAIeRefR4wfG0C0UFEUBAaGKaCNyLiWn3QaKW9r7(55oSGIJO2qKH7N8uEc0j4UrJ60GHB0XQILpld5Dq6NsMCR5jpLNGvRRy1cSAKPbpL34MJksnEba13b9N1qhRwxXkHbkAgYfIwuyfcGv6uBSADfRMdccM(lUdOo0dSH1qFNJ0IviawjgSseSAjwTaRgzAWt5noaazKA8caQFkzY9eoBhRwIvlWQrMg8uEJBoQi14faupHPU6Ts2QhU5wfGeU5md9HKRaKWckoIicrgUFYt5jqNG7gnQtdgUrhRkw(SmK3bPFkzYTMN8uEcwTUIvlWQrMg8uEJBoQi14fauFh0FwdDSADfRegOOzixiArHviawPtTXkrWQLy1cSAKPbpL34aaKrQXlaO((lgRwIvlWQrMg8uEJdaqgPgVaG6NsMCpHZ2XQLy1cSAKPbpL34MJksnEba1tyQRERKT6HBUvbiH7MEgy92IgUEybfhrDargUFYt5jqNG7gnQtdgUlw(SmtzKeVWafnZtEkpbRwIvOJvlWkkhe)hFwgMqSM7YWwwSADfROCq8F8zzycXAIeRefR4wfG0C0UFEUBAaGKaCNyLiWn3QaKW9r7(55oSGIJOoHid3CRcqc3K3bP1pJ6W9tEkpb6eSGIJicbrgUFYt5jqNG7gnQtdgUxGvflFwMoO)Sg6MN8uEcwTeRqhRwGvuoi(p(SmDW47plZDzyllwTUIvuoi(p(SmDW47pltKyLOyvtpt1ClwHWHviQnwjcwTeRkw(SmK3bPFkzYTMN8uEcCZTkajClCPNoy1dlO4ikgiYW9tEkpb6eC3OrDAWWDXunVmKWwC2owjkwHOyWQ1vSAbwvmvZltKEkNAoCZTkajClC5uYKdlO4ik2qKH7N8uEcCc3nAuNgmCxmvZldjSfNTJvIIvikgSADfRqhRwGvft18YePNYPMJvlXQfyvXYNLPd6pRHU5jpLNGvIa3CRcqc3cx6Pdw9WckoIIfez4(jpLNaNWDJg1Pbd3ft18YqcBXz7yLOyfIIbU5wfGeUhFQ5cdsp9f9CblO4iIGHid3p5P8eOtWDJg1Pbd3flFwgY7G0pLm5wZtEkpbU5wfGeUl9uGBVgjhJhwWcUjxGhKfezO4icrgU5wfGeU5Hc45Q4MRW9tEkpb6eSGIRdiYW9ilhoCxS8zzecQT8tjaqmp5P8eSADfRSV8tqoynvCQo02JqoAyLOyL2y16kwzDCP0xmvZlRzkzY9eoBhrSsuuyf6yLoXkxiwvS8zzkkhspqWthI0q50vSse4(jpLNaDcU5wfGeUhzAWt5H7rM6tUF4EkzY9eoBhwqX1jez4EKLdhUxGvOJvlWQILplt((TH18KNYtWQ1vSQbascWDAY3VnSg6zcAy16kw1aajb4on573gwd9DoslwjkwvmvZltf97lGNehRwxXQgaija3PjF)2WAOVZrAXkrXkXwBSse4(jpLNaDcU5wfGeUhzAWt5H7rM6tUF42nhvKA8caQpF)2WclO4ieez4EKLdhUxGvflFwgY7GmAMN8uEcwTeRAaGKaCNM(lUdOo0dSH1qFNJ0Iviawj2y1sSsyGIMHCHOffwjkwPtTXQLyf6y1cSAKPbpL34MJksnEba1NVFByXQ1vSQbascWDAY3VnSg67CKwScbWke1gRebUFYt5jqNGBUvbiH7rMg8uE4EKP(K7hUDaaYi14fauF)fdlO4IbImCpYYHd3Jmn4P8MPKj3t4SDSAjwHowjmqrdRqaSsSedw5cXQILplJqqTLFkbaIHYPRyfchwPdTXkrG7N8uEc0j4MBvas4EKPbpLhUhzQp5(HBhaGmsnEba1pLm5EcNTdlO4Inez4EKLdhUlw(SmeM6Q3kzREZtEkpbRwIvlWQrMg8uEJdaqgPgVaG6NsMCpHZ2XQLy1cSAKPbpL34aaKrQXlaO((lgRwIvnaqsaUtdHPU6Ts2Q3m4aUFYt5jqNGBUvbiH7rMg8uE4EKP(K7hUDZrfPgVaG6jm1vVvYw9WckUybrgUhz5WH7ILplth0FwdDZtEkpbRwIvlWQ5GGGPd6pRHUzWbC)KNYtGob3CRcqc3Jmn4P8W9it9j3pC7MJksnEba13b9N1qhwqXrWqKHBUvbiHBsyPdok4(jpLNaDcwqXrqGid3p5P8eOtWn3QaKWDJLsp3QaKEzyl4UrJ60GH7gaija3PrJemzPVbascWDAOVZrAXkuyL2WTmSLp5(H7gaija3jSGIJO2qKH7N8uEc0j4UrJ60GHBHbkAgYfIwuyLOOWkDkg4MBvas42r0C1p4Wlqzn9NfSGIJiIqKH7N8uEc0j4MBvas4UXsPNBvasVmSfC3OrDAWWDXYNLHWux9wjB1BEYt5jy1sScDSAKPbpL34MJksnEba1tyQRERKT6XQ1vSI85GGGHWux9wjB1BgCGvIa3YWw(K7hUjm1vVvYw9WckoI6aImC)KNYtGob3CRcqc30H0ZTkaPxg2cUB0Oony4Uy5ZYqEhKrZ8KNYtGBzylFY9d3K3bz0GfuCe1jez4(jpLNaDcU5wfGeUPdPNBvasVmSfCldB5tUF4ob0olHfSGBh03a9jxqKHIJiez4(jpLNaDcwqX1bez4(jpLNaDcwqX1jez4(jpLNaDcwqXriiYW9tEkpb6eSGIlgiYWn3QaKWTdqfGeUFYt5jqNGfuCXgImCZTkajC3FXDa1HEGnSW9tEkpb6eSGfCtEhKrdImuCeHid3p5P8eOtWDJg1Pbd3CRIX7F(EClwjkwHiwTUIvOJvlWkkhe)hFwgMqSM7YWwwSADfROCq8F8zzycXAIeRefR0P2yLiWn3QaKWTWL(jtPSMdlO46aImC)KNYtGob3nAuNgmCpY0GNYBMsMCpHZ2HBUvbiHBY5sV36(3bSGIRtiYW9tEkpb6eC3OrDAWW9itdEkVzkzY9eoBhRwIvnaqsaUtZr7(55UH(ohPfRefRedwTeRwGvnaqsaUtt)f3buh6b2WAONjOb3CRcqc3tjtUNWz7WckocbrgU5wfGeUJEhi5kaPNhOmC)KNYtGoblO4IbImC)KNYtGob3nAuNgmClmqrdRqaScH0gRwxXk0XQ5GGGP)I7aQd9aByneG7eRwIvcdu0mKleTOWkrrHviK2yLiWn3QaKWTWLtjtoSGIl2qKH7N8uEc0j4UrJ60GHB0XQfyvXYNLzkJK4fgOOzEYt5jy16kwjmqrZqUq0IcReffwjwAJvIGvlXk0XQfy1CqqW0FXDa1HEGnSM7Y6j5e)enp5DqgnSADfRqhRSV8tqoynvCQoq0JqoAyLOyL2y1sSAoiiy6V4oG6qpWgwd9DoslwjkwHOyJvIGvIa3CRcqc3hT7NN7WckUybrgUFYt5jqNG7gnQtdgUrhRkw(SmtzKeVWafnZtEkpbRwxXkHbkAgYfIwuyfcGv6uBSADfRMdccM(lUdOo0dSH1qFNJ0IviawjgSseSAjwTaRgzAWt5noaazKA8caQFkzY9eoBhU5wfGeU5md9HKRaKWckocgImC)KNYtGob3nAuNgmCJowvS8zzMYijEHbkAMN8uEcwTUIvcdu0mKleTOWkeaR0P2yLiy1sSAbwnY0GNYBCaaYi14fauF)fJvlXQfy1itdEkVXbaiJuJxaq9tjtUNWz7Wn3QaKWDtpdSEBrdxpSGIJGargUFYt5jqNG7gnQtdgUlw(SmK3bPFkzYTMN8uEcwTeRwGvnaqsaUtZr7(55UHEMGgwTeRqhRA6zQMBXkuyLoWQ1vScDScDSAbwr5G4)4ZY0bJV)Sm3LHTSy16kwr5G4)4ZY0bJV)SmrIvIIviQnwjcwTeRqhRwGvuoi(p(SmmHyn3LHTSy16kwr5G4)4ZYWeI1ejwjkwHO2yLiyLiyLiWn3QaKWTWLE6GvpSGIJO2qKHBUvbiHBY7G06NrD4(jpLNaDcwqXreriYW9tEkpb6eC3OrDAWW9cSQyQMxMi9uo1C4MBvas4U0tbU9AKCmEybfhrDargUFYt5jWjC3OrDAWWDXunVmKWwC2owjkwHOyWQ1vSAbwvmvZltKEkNAoCZTkajClCPNoy1dlO4iQtiYW9tEkpboH7gnQtdgUlMQ5LHe2IZ2XkrXkefdCZTkajCp(uZfgKE6l65cwqXreHGid3p5P8eOtWDJg1Pbd3flFwgY7G0pLm5wZtEkpbU5wfGeUl9uGBVgjhJhwWcUBaGKaCNqKHIJiez4(jpLNaDcUB0Oony4EbwHowvS8zziVdYOzEYt5jy16kwnY0GNYBCaaYi14fauF)fJvRRy1itdEkVXnhvKA8caQpF)2WIvIGvRRyvXunVmv0VVaEsCScbWkDig4MBvas4U)I7aQd9aByHfuCDargUFYt5jqNG7gnQtdgUlw(SmK3bz0mp5P8eSAjwnheem9xChqDOhydRzWbCZTkajC3FXDa1HEGnSWckUoHid3p5P8eOtWDJg1Pbd3uoi(p(SmmHyn3LHTSy1sSI85GGGjF)2WAia3jwTeRqhR4wfJ3)894wSsuScrSADfROCq8F8zzycXAIeRefReBTXkrGBUvbiH789BdlCxmvZlFia3ft18Yur)(c4jXHfuCecImC)KNYtGob3nAuNgmCVaROCq8F8zzycXAUldBzHBUvbiH789BdlSGIlgiYW9tEkpb6eC3OrDAWW9CqqW0FXDa1HEGnSg67CKwSsuSshIbRwxXQIPAEzQOFFb8K4yfcGvIT2Wn3QaKWTdqfGewWcUjm1vVvYw9qKHIJiez4(jpLNaDcUB0Oony4wyGIgwjkkScbRnwTeRqhRwGvJmn4P8MPKj3t4SDSADfRwGvnaqsaUtZuYK7jC2UHEMGgwjcCZTkajCtyQRERKT6HfuCDargUFYt5jqNG7gnQtdgUjFoiiyim1vVvYw9MbhWn3QaKWnNzOpKCfGewqX1jez4(jpLNaDcUB0Oony4M85GGGHWux9wjB1BgCa3CRcqc3n9mW6TfnC9WcwWcUhp1gGekUo0greS2IfIILbresBeHB3mnJuJfUHBEO0dOWncZDnKbC7Gcec5HBxmSYfKlFBOobRMxaqpw1a9jxy18AI0AWke0BT7OSyvcsxOEM2fgKyf3QaKwScKs0myK4wfG0ACqFd0NCHsqYwxXiXTkaP14G(gOp5YzuAXdA6plUcqIrIBvasRXb9nqFYLZO0saaiyKCXWQDYoS6bfwr5GGvZbbHtWkBXLfRMxaqpw1a9jxy18AI0IvCsWkh07cDaQksnyvyXkciVbJe3QaKwJd6BG(KlNrPLnzhw9GYBlUSyK4wfG0ACqFd0NC5mkTCaQaKyK4wfG0ACqFd0NC5mkT6V4oG6qpWgwmsyKCXWkxqU8TH6eS6JNIgwvr)yvP)yf3kafRclwXJCi5P8gmsCRcqArXdfWZvXnxXiXTkaP1zuAnY0GNYRBY9JAkzY9eoBx3rwoCuflFwgHGAl)ucaeZtEkpzD1(Ypb5G1uXP6qBpc5OTUADCP0xmvZlRzkzY9eoBhrrrHUoDHflFwMIYH0de80Hinp5P8erWiXTkaP1zuAnY0GNYRBY9JYnhvKA8caQpF)2WQ7ilhoQfOVOy5ZYKVFBynp5P8K11gaija3PjF)2WAONjOTU2aajb4on573gwd9DosROft18Yur)(c4jXxxBaGKaCNM89BdRH(ohPvuXwBrWiXTkaP1zuAnY0GNYRBY9JYbaiJuJxaq99xSUJSC4OwuS8zziVdYOzEYt5jlBaGKaCNM(lUdOo0dSH1qFNJ0IaI9sHbkAgYfIwuIQtTxI(IrMg8uEJBoQi14fauF((THDDTbascWDAY3VnSg67CKwearTfbJe3QaKwNrP1itdEkVUj3pkhaGmsnEba1pLm5EcNTR7ilhoQrMg8uEZuYK7jC2(s0fgOOHaILyCHflFwgHGAl)ucaeZtEkpbHthAlcgjUvbiToJsRrMg8uEDtUFuU5OIuJxaq9eM6Q3kzREDhz5WrvS8zzim1vVvYw9MN8uEYYfJmn4P8ghaGmsnEba1pLm5EcNTVCXitdEkVXbaiJuJxaq99x8Ygaija3PHWux9wjB1BgCGrIBvasRZO0AKPbpLx3K7hLBoQi14fauFh0FwdDDhz5WrvS8zz6G(ZAOBEYt5jlxmheemDq)zn0ndoWiXTkaP1zuArclDWrHrIBvasRZO0QXsPNBvasVmSLUj3pQgaija3PUHaknnIH(ohPfL2yK4wfG06mkTCenx9do8cuwt)zPBiGsyGIMHCHOfLOO0PyWiXTkaP1zuA1yP0ZTkaPxg2s3K7hfHPU6Ts2Qx3qavXYNLHWux9wjB1BEYt5jlrFKPbpL34MJksnEba1tyQRERKT6xxjFoiiyim1vVvYw9MbhIGrIBvasRZO0IoKEUvbi9YWw6MC)OiVdYOPBiGQy5ZYqEhKrZ8KNYtWiXTkaP1zuArhsp3QaKEzylDtUFujG2zjgjmsCRcqAnnaqsaUtu9xChqDOhydRUHaQfOxS8zziVdYOzEYt5jRRJmn4P8ghaGmsnEba13FXRRJmn4P8g3CurQXlaO(89BdRiRRft18Yur)(c4jXraDigmsCRcqAnnaqsaUtNrPv)f3buh6b2WQBiGQy5ZYqEhKrZ8KNYtwoheem9xChqDOhydRzWbgjUvbiTMgaija3PZO0kF)2WQBXunV8HaQEKi8ft18Yur)(c4jX1neqr5G4)4ZYWeI1Cxg2YUK85GGGjF)2WAia35s05wfJ3)894wrj3g0t8ft18YUUs5G4)4ZYWeI1ePOIT2IGrIBvasRPbascWD6mkTY3VnS6gcOwq5G4)4ZYWeI1Cxg2YIrIBvasRPbascWD6mkTCaQaK6gcOMdccM(lUdOo0dSH1qFNJ0kQoeZ6AXunVmv0VVaEsCeqS1gJegjUvbiTgctD1BLSvpkctD1BLSvVUHakHbkAIIcbR9s0xmY0GNYBMsMCpHZ2xxx0aajb4ontjtUNWz7g6zcAIGrIBvasRHWux9wjB17mkT4md9HKRaK6gcOiFoiiyim1vVvYw9MbhyK4wfG0Aim1vVvYw9oJsRMEgy92IgUEDdbuKpheemeM6Q3kzREZGdmsyK4wfG0AiVdYOHs4s)KPuwZ1neqXTkgV)57XTIsUnON4lMQ5LDDf9fuoi(p(SmmHyn3LHTSRRuoi(p(SmmHynrkQo1wemsCRcqAnK3bz0CgLwKZLEV19VdDdbuJmn4P8MPKj3t4SDmsCRcqAnK3bz0CgLwtjtUNWz76gcOgzAWt5ntjtUNWz7lBaGKaCNMJ29ZZDd9DosROIz5Igaija3PP)I7aQd9aByn0Ze0WiXTkaP1qEhKrZzuAf9oqYvasppqzmsCRcqAnK3bz0CgLwcxoLm56gcOegOOHaiK2RROpheem9xChqDOhydRHaCNlfgOOzixiArjkkesBrWiXTkaP1qEhKrZzuAD0UFEURBiGc9fflFwMPmsIxyGIM5jpLNSUkmqrZqUq0IsuuIL2ISe9fZbbbt)f3buh6b2WAUlRNKt8t08K3bz0wxr3(Ypb5G1uXP6arpc5OTCoiiy6V4oG6qpWgwd9DosROik2IicgjUvbiTgY7GmAoJsloZqFi5kaPUHak0lw(SmtzKeVWafnZtEkpzDvyGIMHCHOffcOtTxxNdccM(lUdOo0dSH1qFNJ0IaIrKLlgzAWt5noaazKA8caQFkzY9eoBhJe3QaKwd5DqgnNrPvtpdSEBrdxVUHak0lw(SmtzKeVWafnZtEkpzDvyGIMHCHOffcOtTfz5IrMg8uEJdaqgPgVaG67V4LlgzAWt5noaazKA8caQFkzY9eoBhJe3QaKwd5DqgnNrPLWLE6GvVUHaQILpld5Dq6NsMCR5jpLNSCrdaKeG70C0UFEUBONjOTe9MEMQ5wu6yDfD0xq5G4)4ZY0bJV)Sm3LHTSRRuoi(p(SmDW47pltKIIO2ISe9fuoi(p(SmmHyn3LHTSRRuoi(p(SmmHynrkkIAlIiIGrIBvasRH8oiJMZO0I8oiT(zuhJe3QaKwd5DqgnNrPvPNcC71i5y86gcOMdccgWq5bcEkNAUzWbgjUvbiTgY7GmAoJslHl90bREDdbuDW47pldjSfNTlkIIzDDoiiyadLhi4PCQ5MbhyK4wfG0AiVdYO5mkTgFQ5cdsp9f9CPBiGQdgF)zziHT4SDrrumyK4wfG0AiVdYO5mkTk9uGBVgjhJx3qavXYNLH8oi9tjtU18KNYtWiHrIBvasRjb0olrn(uZfgKE6l65s3qavXYNLPd6pRHU5jpLNSCoiiyCqVdMEIHaCNyK4wfG0AsaTZsNrPLWLE6GvVUHak0hzAWt5nU5OIuJxaq9Dq)zn0xxlw(Smcx67STofnZtEkprKLO30Zun3IshRROJ(ckhe)hFwMoy89NL5UmSLDDLYbX)XNLPdgF)zzIuue1wKLOVGYbX)XNLHjeR5UmSLDDLYbX)XNLHjeRjsrruBreremsCRcqAnjG2zPZO0s4s)KPuwZ1neqTyKPbpL34MJksnEba13b9N1qFj6CRIX7F(ECROKBd6j(IPAEzxxPCq8F8zzycXAIuuDQTiyK4wfG0AsaTZsNrPv07ajxbi98aLXiXTkaP1KaANLoJsRJ29ZZDDdbuCRIX7F(ECROiUe9fuoi(p(SmmHyn3LHTSRRuoi(p(SmmHyndoez5IrMg8uEJBoQi14fauFh0FwdDmsCRcqAnjG2zPZO0ICU07TU)DOBiGAKPbpL3mLm5EcNTJrIBvasRjb0olDgLwtjtUNWz76gcOgzAWt5ntjtUNWz7yK4wfG0AsaTZsNrPLWLtjtUUHakHbkAgYfIwuIIcH0gJe3QaKwtcODw6mkToA3pp31neqTOy5ZYmLrs8cdu0mp5P8KLlgzAWt5nU5OIuJxaq9eM6Q3kzR(LOVGYbX)XNLHjeR5UmSLDDLYbX)XNLHjeRjsr5wfG0C0UFEUBAaGKaCNIGrIBvasRjb0olDgLwCMH(qYvasDdbuOxS8zziVds)uYKBnp5P8K11fJmn4P8g3CurQXlaO(oO)Sg6RRcdu0mKleTOqaDQ966CqqW0FXDa1HEGnSg67CKweqmISCXitdEkVXbaiJuJxaq9tjtUNWz7lxmY0GNYBCZrfPgVaG6jm1vVvYw9yK4wfG0AsaTZsNrPvtpdSEBrdxVUHak0lw(SmK3bPFkzYTMN8uEY66IrMg8uEJBoQi14fauFh0Fwd91vHbkAgYfIwuiGo1wKLlgzAWt5noaazKA8caQV)IxUyKPbpL34aaKrQXlaO(PKj3t4S9LlgzAWt5nU5OIuJxaq9eM6Q3kzREmsCRcqAnjG2zPZO06OD)8Cx3qavXYNLzkJK4fgOOzEYt5jlrFbLdI)JpldtiwZDzyl76kLdI)JpldtiwtKIYTkaP5OD)8C30aajb4ofbJe3QaKwtcODw6mkTiVdsRFg1XiXTkaP1KaANLoJslHl90bREDdbulkw(SmDq)zn0np5P8KLOVGYbX)XNLPdgF)zzUldBzxxPCq8F8zz6GX3FwMifTPNPAUfHdrTfzzXYNLH8oi9tjtU18KNYtWiXTkaP1KaANLoJslHlNsMCDdbuDW47pldjSfNTlkIIzDDoiiyadLhi4PCQ5MbhyK4wfG0AsaTZsNrPLWLE6GvVUHaQoy89NLHe2IZ2ffrXSUI(CqqWagkpqWt5uZndowUOy5ZY0b9N1q38KNYtebJe3QaKwtcODw6mkTgFQ5cdsp9f9CPBiGQdgF)zziHT4SDrrumyK4wfG0AsaTZsNrPvPNcC71i5y86gcOkw(SmK3bPFkzYTMN8uEcSGfec ]] )


end
