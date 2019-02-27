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

            usable = function () return debuff.dispellable_magic.up end,
            handler = function ()
                removeDebuff( "dispellable_magic" )
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
            cooldown = function () return pvptalent.demonic_origins.up and 120 or 240 end,
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
                    setCooldown( "annihilation", 0 )
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


    spec:RegisterPack( "Havoc", 20190226.2347, [[d0eE5aqiIulIuH8isbBsL0NivGgLuuNsQWQOcrVIkywej3Iku7Is)sLyyujDmQeltkYZifAAuH01iv02uPkFtQu14KkkoNkvY6KkvEhPcO5Psf3ds2hPOdkvkSqsLEOkvQjsQqDrsfGnsQG(OuruJuQu6KsLIwjvQzkve0nLkkTtIWqLksTuvQQNcXujIUkvi8vPIqJvQiWEr6VsmysomQfRIhtvtgXLbBMO(mKA0KQoTOxlvYSH62sA3c)wPHtkDCPIilNWZPy6kUUuA7svFxkmEPIQZRsz9sfjZNkA)QAQlujPieEaQen5Ql3LRn109SnPrhT7BYfkYCtlqr0Y(Uy0afj4kqr6wUF9ueT8n8YeQKueZ2k8afr)mAnD3LlOZrF7X636ftwBX8KB4fS8CXKv)LdEpxoYSJjq)fTIvoXG5sNwa3NtI5sN((fDmu3O0TTXaIs3Y9R3AYQNICAt80nd6HIq4bOs0KRUCxU2ut3Z2KgBYrD1rPigTGNkHo7(UNIOpjeiOhkcbmEkIgEv3Y9R)v6yOUXR622yaX7wdVs)mAnD3LlOZrF7X636ftwBX8KB4fS8CXKv)LdEpxoYSJjq)fTIvoXG5sNwa3NtI5sN((fDmu3O0TTXaIs3Y9R3AYQ)DRHxPdHJOLf3Evt3tQx1KRUCxVYXVQjn2DnPX397wdVQtKfrgOnD37wdVYXVYryYa9R0XqDJxPlMjG5vvUlW8Q6AMxPdBf3EfAiabp5gVsBRaW3E19LOt(ver2dXR4G8Q2qRaiPF4dgK6vn0NE9VQrIXVkRAz)8Qrp8QoPwgNZTxTYVsa(TwHGWtUHX(U1WRC8RCeMmq)Qo7wHyARVknVk25vcWV1keeGOd8v6qa)Q73A0)Qgjg)Qd8kb43AfccqEfhKxn6HxzyzyU9Qv(v6qa)Q73A0)kphXoV6aVIad4hG8QZTxXeYgg77(DRHxD365any6U3TgELJFv3GqaYRU7nmTv4vDwgD6TVBn8kh)Q7d1ThiVAybAykP8R86bFxVsEfVscOcM08k(K4CUzF3A4vo(v3hQBpqEvD7HkeZR4tIZjbZRKfB9vAf5kY52RAOhIxf78QwdqEL8kEvNDRqmTv77wdVYXVQBqia5vocd8QU5avZRM9vqqE1k)Q7ExmzBeMxX(j3aNMX(U1WRC8RU7n6bXaKxPJ87IjBJqh9QzFLoI9tUHTtG1VlMSncD0RAOheWRyTAXPNpyWsrWPzmujPiXkQmMkjvcxOssrGGpyGq1LI4f5aIKPidJHyS1TcX0wTqWhmqE11xDALLTAfGwwaelzBeV66RMScVsZx5cfH9tUbfPhc0GClUiGra8qhQenrLKIabFWaHQlfXlYbejtr6zrYhmyBW5Kb6I8kk1TcX0wF11x18R86zbAW8kuVQPx505RA(vcojfOhIXw3EOcXyZ4vA(kxC9vxFLGtsb6HySmHySz8knFLlU(QoEvhue2p5guezaxeTg90HkHgPssrGGpyGq1LI4f5aIKPis)QEwK8bd2gCozGUiVIsDRqmT1xD9vn)k2pzpuGaQjyELMVIaMuaKYWc0WyELtNVsWjPa9qmwMqm2mELMVsJU(QoOiSFYnOiYaUCyHGrd0HkHJsLKIabFWaHQlfXlYbejtr6zrYhmypyMafchEGIW(j3GIqaE0xmnaqlDOsOtQKue2p5guKSwxmp5gfUvWuei4dgiuDPdvI7rLKIabFWaHQlfXlYbejtry)K9qbcOMG5vA(kxE11x18RK(vcojfOhIXYeIXcDEAgZRC68vcojfOhIXYeIX2Q9vD8QRVs6x1ZIKpyW2GZjd0f5vuQBfIPTsry)KBqrGBq5aCLouj6EQKuei4dgiuDPiEroGizkspls(Gb7bZeOq4Wdue2p5guKdMjqHWHhOdvIodvskce8bdeQUueVihqKmfrUvCZsa50NZR0e1RCuxPiSFYnOiYa(GzcqhQe3fvskce8bdeQUueVihqKmfr6xnmgIXEWzqkYTIBwi4dgiV66RK(v9Si5dgSn4CYaDrEffcl6QyWSr)RU(kbNKc0dXyzcXyZ4vA(k2p5gw4guoaxT(DXKTrqry)KBqrGBq5aCLoujCXvQKuei4dgiuDPiEroGizksZVAymeJLa1nkhmtaJfc(GbYRC68vs)QEwK8bd2gCozGUiVIsDRqmT1x505RKBf3Seqo958Q78kn66RC68vNwzzBfgUUcT6xtAScOYzyE1DELoFvhV66RK(v9Si5dgSA3fNb6I8kkhmtGcHdp8QRVs6x1ZIKpyW2GZjd0f5vuiSORIbZg9ue2p5gueoIuFI5j3GoujCXfQKuei4dgiuDPiEroGizksZVAymeJLa1nkhmtaJfc(GbYRC68vs)QEwK8bd2gCozGUiVIsDRqmT1x505RKBf3Seqo958Q78kn66R64vxFL0VQNfjFWGv7U4mqxKxrPcd)QRVs6x1ZIKpyWQDxCgOlYROCWmbkeo8WRU(kPFvpls(GbBdoNmqxKxrHWIUkgmB0try)KBqr8651umJi7cOdvcxAIkjfbc(GbcvxkIxKdisMImmgIXEWzqkYTIBwi4dgiV66ReCskqpeJLjeJnJxP5Ry)KByHBq5aC163ft2gbfH9tUbfbUbLdWv6qLWfnsLKIW(j3GIqG6gMYjhGIabFWaHQlDOs4IJsLKIabFWaHQlfXlYbejtrQBpuHySK0mC4HxP5RCrNVYPZxDALLTB7uw5IGd0GTvlfH9tUbfrgWhmta6qLWfDsLKIabFWaHQlfXlYbejtrggdXyjqDJYbZeWyHGpyGqry)KBqrg9ITrbnMZEGo0HIqazUfpujPs4cvskc7NCdkcjnIwTdfbc(Gbcvx6qLOjQKue2p5gue)gM2kuQm60trGGpyGq1Louj0ivskspJBbkYWyigRCkmt5G3LyHGpyG8kNoFLrlGXLHfOHXypyMafchEWLxPjQx18R04RC8RggdXyhbN4YkxeTzyHGpyG8QoOiqWhmqO6sry)KBqr6zrYhmqr6zrj4kqroyMafchEGoujCuQKuKEg3cuePFvZVs6xnmgIXgqfmPXcbFWa5voD(k)UyY2iSbubtAScGj3ELtNVYVlMSncBavWKgRaQCgMxP5RMScLzlKeELtNVYVlMSncBavWKgRaQCgMxP5RUNRVQdkce8bdeQUue2p5guKEwK8bduKEwucUcuKgCozGUiVIsavWKg6qLqNujPi9mUfOis)QHXqmwcu3i9wi4dgiV66R87IjBJWwHHRRqR(1KgRaQCgMxDNxDVxD9vYTIBwciN(CELMVsJU(QRVQ5xj9R6zrYhmyBW5Kb6I8kkbubtAELtNVYVlMSncBavWKgRaQCgMxDNx5IRVQdkce8bdeQUue2p5guKEwK8bduKEwucUcueT7IZaDrEfLkmmDOsCpQKuKEg3cuKEwK8bd2dMjqHWHhE11x18RKBf3E1DEv3RZx54xnmgIXkNcZuo4Djwi4dgiVYr(QMC9vDqrGGpyGq1LIW(j3GI0ZIKpyGI0ZIsWvGIODxCgOlYROCWmbkeo8aDOs09ujPi9mUfOidJHySeOUr6TqWhmqE11xj9RggdXyp4mif5wXnle8bdKxD9v(DXKTryHBq5aC1kGkNH5v35vn)k0EITYD(RCKVQPx1XRU(k5wXnlbKtFoVsZx1KRuei4dgiuDPiSFYnOi9Si5dgOi9SOeCfOiA3fNb6I8kkWnOCaUshQeDgQKuKEg3cuKHXqmwcl6QyWSrVfc(GbYRU(kPFvpls(GbR2DXzGUiVIYbZeOq4WdV66RK(v9Si5dgSA3fNb6I8kkvy4xD9v(DXKTryjSORIbZg92wTuei4dgiuDPiSFYnOi9Si5dgOi9SOeCfOin4CYaDrEffcl6QyWSrpDOsCxujPi9mUfOidJHyS1TcX0wTqWhmqE11xj9RoTYY26wHyAR2wTuei4dgiuDPiSFYnOi9Si5dgOi9SOeCfOin4CYaDrEfL6wHyAR0HkHlUsLKIW(j3GIqsJOv7qrGGpyGq1LoujCXfQKuei4dgiuDPiSFYnOiEgJlSFYnk40mueVihqKmfbTNyfqLZW8kuVYvkcontj4kqr87IjBJGoujCPjQKuei4dgiuDPiEroGizkICR4MLaYPpNxPjQxPrDsry)KBqr0M(UkTAlYcgDfIHoujCrJujPiqWhmqO6sry)KBqr8mgxy)KBuWPzOiEroGizkYWyiglHfDvmy2O3cbFWa5vxFvZVQNfjFWGTbNtgOlYROqyrxfdMn6FLtNVIaNwzzlHfDvmy2O32Q9vDqrWPzkbxbkcHfDvmy2ONoujCXrPssrGGpyGq1LIW(j3GIiAJc7NCJcondfXlYbejtrggdXyjqDJ0BHGpyGqrWPzkbxbkcbQBKE6qLWfDsLKIabFWaHQlfH9tUbfr0gf2p5gfCAgkcontj4kqrIvuzmDOdfrRa8B9WdvsQeUqLKIabFWaHQlDOs0evskce8bdeQU0HkHgPssrGGpyGq1LoujCuQKuei4dgiuDPdvcDsLKIW(j3GIODNCdkce8bdeQU0HkX9OssrGGpyGq1LI4f5aIKPis)kUtbICaRxpVt6lJGdJ8kQ8KByHGpyGqry)KBqrQWW1vOv)AsdDOdfHa1nspvsQeUqLKIabFWaHQlfXlYbejtr6zrYhmypyMafchEGIW(j3GIqaE0xmnaqlDOs0evskce8bdeQUueVihqKmfrWjPa9qmwMqm2wTVYPZxj4KuGEigltigBgVsZx1KoPiSFYnOiWnOCaUshQeAKkjfbc(GbcvxkIxKdisMI08RA(vs)k)UyY2iSWnOCaUAB1(kNoF1Pvw2wHHRRqR(1KgBR2x1XRU(kbNKc0dXyzcXyZ4vA(kn66R64voD(k2pzpuGaQjyELMVIaMuaKYWc0WyOiSFYnOiYaUCyHGrd0HkHJsLKIabFWaHQlfXlYbejtr6zrYhmypyMafchE4vxFL0VYVlMSncBfgUUcT6xtAScGj3E11x18R87IjBJWc3GYb4QvavodZR08vn)kD(kh)kUtbICaRa6xCFgOlhmtaJvWrxVYr(kn(QoELtNVQ5xj4KuGEigltigBgVsZxX(j3WEWmbkeo8G1VlMSnIxD9vcojfOhIXYeIXMXRUZRAsNVQJx1bfH9tUbf5GzcuiC4b6qLqNujPiSFYnOizTUyEYnkCRGPiqWhmqO6shQe3Jkjfbc(GbcvxkIxKdisMIi9R6zrYhmy1Ulod0f5vuoyMafchEGIW(j3GIWrK6tmp5g0Hkr3tLKIabFWaHQlfXlYbejtrKBf3Seqo958knr9kh1vkc7NCdkImGpyMa0HkrNHkjfbc(GbcvxkIxKdisMIi9R6zrYhmy1Ulod0f5vuoyMafchE4vxFL0VQNfjFWGv7U4mqxKxrbUbLdWvkc7NCdkIxpVMIzezxaDOsCxujPiSFYnOieOUHPCYbOiqWhmqO6shQeU4kvskce8bdeQUueVihqKmf50klB32PSYfbhObBRwkc7NCdkYOxSnkOXC2d0HkHlUqLKIabFWaHQlfXlYbejtrggdXyjqDJYbZeWyHGpyGqry)KBqrg9ITrbnMZEGo0HI43ft2gbvsQeUqLKIabFWaHQlfXlYbejtrK(vn)QHXqmwcu3i9wi4dgiVYPZx1ZIKpyWQDxCgOlYROuHHFLtNVQNfjFWGTbNtgOlYROeqfmP5vD8kNoF1KvOmBHKWRUZRAsNue2p5guKkmCDfA1VM0qhQenrLKIabFWaHQlfXlYbejtrggdXyjqDJ0BHGpyG8QRVQ5xj9R4ofiYbSE98oPVmcomYROYtUHfc(GbYRC68vn)k)UyY2iSWnOCaUAfqLZW8knFvtU(QRVYVlMSnc7bZeOq4Wdwbu5mmVsZxH2tSvUZFvhVQdkc7NCdksfgUUcT6xtAOdvcnsLKIabFWaHQlfXlYbejtreCskqpeJLjeJf680mMxD9ve40klBdOcM0yjBJ4vxFvZVI9t2dfiGAcMxP5RiGjfaPmSanmMx505ReCskqpeJLjeJnJxP5RUNRVQdkc7NCdksavWKg6qLWrPssrGGpyGq1LI4f5aIKPis)kbNKc0dXyzcXyHopnJHIW(j3GIeqfmPHouj0jvskce8bdeQUueVihqKmf50klBRWW1vOv)AsJvavodZR08vnPZx505RMScLzlKeE1DE19CLIW(j3GIODNCd6qL4EujPiqWhmqO6srcUcuKEwK8bdLmgim5CRGorZ9lEkRXNympzGUia2pRGIW(j3GI0ZIKpyOKXaHjNBf0jAUFXtzn(eJ5jd0fbW(zf0Hkr3tLKIabFWaHQlfXCl8uezaxoSqWObksWvGIGMXGNXyqykNDdkc7NCdkcAgdEgJbHPC2nOdvIodvskce8bdeQUueVihqKmfr6xnmgIXkd4YHfcgnyHGpyGqrcUcue0mg8mgdct5SBqry)KBqrqZyWZymimLZUbDOsCxujPiSFYnOiTgOKdunuei4dgiuDPdDOiew0vXGzJEQKujCHkjfbc(GbcvxkIxKdisMIi3kU9knr9QoJRV66RA(vs)QEwK8bd2dMjqHWHhELtNVs6x53ft2gH9GzcuiC4bRayYTx1bfH9tUbfHWIUkgmB0thQenrLKIabFWaHQlfXlYbejtriWPvw2syrxfdMn6TTAPiSFYnOiCeP(eZtUbDOsOrQKuei4dgiuDPiEroGizkcboTYYwcl6QyWSrVTvlfH9tUbfXRNxtXmISlGo0HouKEqyYnOs0KRUCxU2KRUyBsJAuNuKgSiYaTHI0j2nUVeDtj6K7Ux9kj1dVkRAxX8k5v8kDqciZT4rh8vcOtQnfa5vMTcVIBNTYdqELxphObJ9D3jmd4vU0u39khryA1QDfdqEf7NCJxPdQn9DvA1wKfm6keJoO9D)U7MvTRyaYRU3Ry)KB8kCAgJ9Dtr42r)kOiizTfZtUXDly5HIOvSYjgOiA4vDl3V(xPJH6gVQBBJbeVBn8k9ZO10DxUGoh9ThRFRxmzTfZtUHxWYZftw9xo49C5iZoMa9x0kw5edMlDAbCFojMlD67x0XqDJs32gdikDl3VERjR(3TgELoeoIwwC7vnDpPEvtU6YD9kh)QM0y31KgF3VBn8QorwezG20DVBn8kh)khHjd0Vshd1nELUyMaMxv5UaZRQRzELoSvC7vOHae8KB8kTTcaF7v3xIo5xrezpeVIdYRAdTcGK(HpyqQx1qF61)Qgjg)QSQL9ZRg9WR6KAzCo3E1k)kb43Afccp5gg77wdVYXVYryYa9R6SBfIPT(Q08QyNxja)wRqqaIoWxPdb8RUFRr)RAKy8RoWReGFRviia5vCqE1OhELHLH52Rw5xPdb8RUFRr)R8Ce78Qd8kcmGFaYRo3EftiBySV73TgE1DRNd0GP7E3A4vo(vDdcbiV6U3W0wHx1zz0P3(U1WRC8RUpu3EG8QHfOHPKYVYRh8D9k5v8kjGkysZR4tIZ5M9DRHx54xDFOU9a5v1ThQqmVIpjoNemVswS1xPvKRiNBVQHEiEvSZRAna5vYR4vD2TcX0wTVBn8kh)QUbHaKx5imWR6MdunVA2xbb5vR8RU7DXKTryEf7NCdCAg77wdVYXV6U3OhedqELoYVlMSncD0RM9v6i2p5g2obw)UyY2i0rVQHEqaVI1QfNE(Gb77(DRHxPdOZbF7aKxDa5vaVYV1dpV6aOZWyFv3W7bTJ5vXgowplQYT4xX(j3W8QnW3SVB2p5ggRwb436HhuYy2017M9tUHXQva(TE4Xbux4w0vigEYnE3SFYnmwTcWV1dpoG6I8UK3TgEfsWAn635vcojV60kldKxzgEmV6aYRaELFRhEE1bqNH5vCqELwb4yT7mzG(vP5vKna77M9tUHXQva(TE4XbuxmbR1OFNIz4X8Uz)KBySAfGFRhECa1fT7KB8Uz)KBySAfGFRhECa1LkmCDfA1VM0ivkJsAUtbICaRxpVt6lJGdJ8kQ8KByHGpyG8UF3A4v6a6CW3oa5vqpiU9QjRWRg9WRy)SIxLMxX9CI5dgSVB2p5gguK0iA1oVB2p5gghqDXVHPTcLkJo9VB2p5gghqDPNfjFWGubxbuhmtGcHdpivpJBbudJHySYPWmLdExIfc(GbItNgTagxgwGggJ9GzcuiC4bx0evZA0XdJHySJGtCzLlI2mSqWhmq64DZ(j3W4aQl9Si5dgKk4kGQbNtgOlYROeqfmPrQEg3cOKUzPhgdXydOcM0yHGpyG40PFxmzBe2aQGjnwbWKBoD63ft2gHnGkysJvavodJMtwHYSfscoD63ft2gHnGkysJvavodJM3Z1oE3SFYnmoG6spls(GbPcUcO0Ulod0f5vuQWWs1Z4waL0dJHySeOUr6TqWhmqU63ft2gHTcdxxHw9Rjnwbu5mm35ExLBf3Seqo95OPgD9AZs3ZIKpyW2GZjd0f5vucOcM040PFxmzBe2aQGjnwbu5mm3Xfx74DZ(j3W4aQl9Si5dgKk4kGs7U4mqxKxr5GzcuiC4bP6zClGQNfjFWG9GzcuiC4HRnl3kUDNUxNoEymeJvofMPCW7sSqWhmqCKn5AhVB2p5gghqDPNfjFWGubxbuA3fNb6I8kkWnOCaUkvpJBbudJHySeOUr6TqWhmqUk9Wyig7bNbPi3kUzHGpyGC1VlMSnclCdkhGRwbu5mm3Pz0EITYDUJSPoUk3kUzjGC6ZrZMC9DZ(j3W4aQl9Si5dgKk4kGQbNtgOlYROqyrxfdMn6LQNXTaQHXqmwcl6QyWSrVfc(GbYvP7zrYhmy1Ulod0f5vuoyMafchE4Q09Si5dgSA3fNb6I8kkvy4R(DXKTryjSORIbZg92wTVB2p5gghqDPNfjFWGubxbun4CYaDrEfL6wHyARs1Z4wa1WyigBDRqmTvle8bdKRsFALLT1TcX0wTTAF3SFYnmoG6cjnIwTZ7M9tUHXbux8mgxy)KBuWPzKk4kGYVlMSncPszuO9eRaQCgguU(Uz)KByCa1fTPVRsR2ISGrxHyKkLrj3kUzjGC6ZrtuAuNVB2p5gghqDXZyCH9tUrbNMrQGRakcl6QyWSrVuPmQHXqmwcl6QyWSrVfc(GbY1M7zrYhmyBW5Kb6I8kkew0vXGzJENojWPvw2syrxfdMn6TTA74DZ(j3W4aQlI2OW(j3OGtZivWvafbQBKEPszudJHySeOUr6TqWhmqE3SFYnmoG6IOnkSFYnk40msfCfqfROY4397M9tUHX63ft2gbQkmCDfA1VM0ivkJs6MhgdXyjqDJ0BHGpyG40zpls(GbR2DXzGUiVIsfg2PZEwK8bd2gCozGUiVIsavWKMoC6CYkuMTqs4onPZ3n7NCdJ1VlMSnchqDPcdxxHw9RjnsLYOggdXyjqDJ0BHGpyGCTzP5ofiYbSE98oPVmcomYROYtUHfc(GbItNn73ft2gHfUbLdWvRaQCggnBY1R(DXKTrypyMafchEWkGkNHrt0EITYDEhD8Uz)KByS(DXKTr4aQlbubtAKkLrj4KuGEigltigl05PzmxjWPvw2gqfmPXs2gX1Mz)K9qbcOMGrtcysbqkdlqdJXPtbNKc0dXyzcXyZqZ75AhVB2p5ggRFxmzBeoG6savWKgPszusl4KuGEigltigl05PzmVB2p5ggRFxmzBeoG6I2DYnKkLrDALLTvy46k0QFnPXkGkNHrZM0PtNtwHYSfsc35EU(Uz)KByS(DXKTr4aQlTgOKduLk4kGQNfjFWqjJbcto3kOt0C)INYA8jgZtgOlcG9ZkE3SFYnmw)UyY2iCa1LwduYbQsfCfqHMXGNXyqykNDdPm3cpkzaxoSqWOH3n7NCdJ1VlMSnchqDP1aLCGQubxbuOzm4zmgeMYz3qQugL0dJHySYaUCyHGrdwi4dgiVB2p5ggRFxmzBeoG6sRbk5avZ7(DZ(j3WyjSORIbZg9OiSORIbZg9sLYOKBf30evNX1RnlDpls(Gb7bZeOq4WdoDkTFxmzBe2dMjqHWHhScGj364DZ(j3WyjSORIbZg9oG6chrQpX8KBivkJIaNwzzlHfDvmy2O32Q9DZ(j3WyjSORIbZg9oG6IxpVMIzezxGuPmkcCALLTew0vXGzJEBR2397M9tUHXsG6gPhfb4rFX0aaTsLYO6zrYhmypyMafchE4DZ(j3WyjqDJ07aQlWnOCaUkvkJsWjPa9qmwMqm2wToDk4KuGEigltigBgA2KoF3SFYnmwcu3i9oG6ImGlhwiy0GuPmQMBwA)UyY2iSWnOCaUAB1605Pvw2wHHRRqR(1KgBR2oUk4KuGEigltigBgAQrx7WPt2pzpuGaQjy0KaMuaKYWc0WyE3SFYnmwcu3i9oG6YbZeOq4WdsLYO6zrYhmypyMafchE4Q0(DXKTryRWW1vOv)AsJvam521M97IjBJWc3GYb4QvavodJMnRthZDkqKdyfq)I7ZaD5GzcySco6YrQXoC6SzbNKc0dXyzcXyZqt2p5g2dMjqHWHhS(DXKTrCvWjPa9qmwMqm2mUtt6SJoE3SFYnmwcu3i9oG6swRlMNCJc3k43n7NCdJLa1nsVdOUWrK6tmp5gsLYOKUNfjFWGv7U4mqxKxr5GzcuiC4H3n7NCdJLa1nsVdOUid4dMjGuPmk5wXnlbKtFoAIYrD9DZ(j3WyjqDJ07aQlE98AkMrKDbsLYOKUNfjFWGv7U4mqxKxr5GzcuiC4HRs3ZIKpyWQDxCgOlYROa3GYb467wdVI9tUHXsG6gP3buxKbCr0A0lvkJAymeJLa1nkhmtaJfc(GbYvP97IjBJWc3GYb4Qvam521M96zbAWGQjNoBwWjPa9qm262dvigBgA6IRxfCskqpeJLjeJndnDX1o64DZ(j3WyjqDJ07aQleOUHPCYbE3SFYnmwcu3i9oG6YOxSnkOXC2dsLYOoTYY2TDkRCrWbAW2Q9DRHxX(j3WyjqDJ07aQlYaUiAn6LkLrv3EOcXyjPz4WdA6IoD680klB32PSYfbhObBR23TgEf7NCdJLa1nsVdOU0dbAqUfxeWiaEKkLrv3EOcXyjPz4WdA6IoF3SFYnmwcu3i9oG6YOxSnkOXC2dsLYOggdXyjqDJYbZeWyHGpyG8UF3SFYnm2yfvgJQhc0GClUiGra8ivkJAymeJTUviM2Qfc(GbY1tRSSvRa0YcGyjBJ46KvqtxE3SFYnm2yfvg7aQlYaUiAn6LkLr1ZIKpyW2GZjd0f5vuQBfIPTETzVEwGgmOAYPZMfCskqpeJTU9qfIXMHMU46vbNKc0dXyzcXyZqtxCTJoE3A4vSFYnm2yfvg7aQlYaUiAn6LkLrnmgIXkd4sLndiUzHGpyGCTzVEwGgmOAYPZMfCskqpeJTU9qfIXMHMU46vbNKc0dXyzcXyZqtxCTJoE3SFYnm2yfvg7aQlYaUCyHGrdsLYOKUNfjFWGTbNtgOlYROu3ketB9AZSFYEOabutWOjbmPaiLHfOHX40PGtsb6HySmHySzOPgDTJ3n7NCdJnwrLXoG6cb4rFX0aaTsLYO6zrYhmypyMafchE4DZ(j3WyJvuzSdOUK16I5j3OWTc(DZ(j3WyJvuzSdOUa3GYb4QuPmk2pzpuGaQjy00LRnlTGtsb6HySmHySqNNMX40PGtsb6HySmHySTA74Q09Si5dgSn4CYaDrEfL6wHyARVB2p5ggBSIkJDa1LdMjqHWHhKkLr1ZIKpyWEWmbkeo8W7M9tUHXgROYyhqDrgWhmtaPszuYTIBwciN(C0eLJ667M9tUHXgROYyhqDbUbLdWvPszuspmgIXEWzqkYTIBwi4dgixLUNfjFWGTbNtgOlYROqyrxfdMn6Vk4KuGEigltigBgAY(j3Wc3GYb4Q1VlMSnI3n7NCdJnwrLXoG6chrQpX8KBivkJQ5HXqmwcu3OCWmbmwi4dgioDkDpls(GbBdoNmqxKxrPUviM2QtNYTIBwciN(CUJgD1PZtRSSTcdxxHw9Rjnwbu5mm3rNDCv6EwK8bdwT7IZaDrEfLdMjqHWHhUkDpls(GbBdoNmqxKxrHWIUkgmB0)Uz)KBySXkQm2bux8651umJi7cKkLr18WyiglbQBuoyMagle8bdeNoLUNfjFWGTbNtgOlYROu3ketB1Pt5wXnlbKtFo3rJU2XvP7zrYhmy1Ulod0f5vuQWWxLUNfjFWGv7U4mqxKxr5GzcuiC4HRs3ZIKpyW2GZjd0f5vuiSORIbZg9VB2p5ggBSIkJDa1f4guoaxLkLrnmgIXEWzqkYTIBwi4dgixfCskqpeJLjeJndnz)KByHBq5aC163ft2gX7M9tUHXgROYyhqDHa1nmLtoW7wdVI9tUHXgROYyhqDrgWfrRrVuPmkPhgdXyRBfIPTAHGpyGCvWjPa9qm262dvigBgA61Zc0GXr6IRxhgdXyjqDJYbZeWyHGpyG8Uz)KBySXkQm2buxKb8bZeqQugvD7HkeJLKMHdpOPl60PZtRSSDBNYkxeCGgSTAF3A4vSFYnm2yfvg7aQlYaUiAn6LkLrv3EOcXyjPz4WdA6IoD6S5tRSSDBNYkxeCGgSTAVk9WyigBDRqmTvle8bdKoE3A4vSFYnm2yfvg7aQl9qGgKBXfbmcGhPszu1ThQqmwsAgo8GMUOZ3n7NCdJnwrLXoG6YOxSnkOXC2dsLYOggdXyjqDJYbZeWyHGpyGqh6qPa]] )


end
