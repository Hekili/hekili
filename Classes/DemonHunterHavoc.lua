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
        width = "full"
    } )


    spec:RegisterPack( "Havoc", 20190707.2302, [[dW0G8aqisulIQa8iOG2KkvFIQaAukOoLcLvrvq9kssZIK4wqf1UO0VGsnmQIogjYYGc9mQcnnfeUgujBdQu9nOImofe5Cqf06GkuVdQuK5bf4Eqv7Ji6GufKwir4HqfOjsvG6IqLIAJkiXhvqugjuPWjPkiwPcmtOcOUjvbYoHswkuP0tv0uHIUQcs6RqfGXcvazVQ6VsmysDyulwfpMktgXLbBMO(mrA0KuNw0RvOA2iDBjTBHFR0WjHJRGOA5eEoftxQRtvTDvY3viJxbPoVkL1dviZNQ0(H8R0J5pjCdpwy0tLWHEItEItwm6rLWDLu6N9nfWpvWUXzPWpdUc)e3GVw3pvW3OltEm)Pz9fo4NQ7wHbhJn2sZwT)X62k2MS6t5o3Wjy5gBtwDy)ZJFsBpK4p)KWn8yHrpvch6jo5jozXOh9e39io8NgfG7Xcx4eo9t1jHaXF(jbmUFIHinUbFToK2dgQBG04g(rdc0amePv3TcdogBSLMTA)J1TvSnz1NYDUHtWYn2MS6Wgnadr6b(0BinoPcsJrpvchI04msJrmIJXfUqdqdWqKghalImKAWXObyisJZi9q1KHuK2dgQBG0sqzcyq6kpoyq66AAKEO4lUH0sHaeCNBG0k8fa9gsJBXAidPjI8ccKMdcs7hkeajDnFOGki9i1PtnspkPuKoRkyxJ0TAaPhY9zA23q6vgPfGBRviiCNBySObyisJZi9q1KHuK2dARq0(vKoniDSnsla3wRqqacUjKEOauKg36BuJ0JskfPpasla3wRqqacsZbbPB1asByzOVH0RmspuaksJB9nQrAhhX2i9bqAc0GRbcsFUH0mHSHX(tAAAZJ5pJvuz6J5JLspM)ec(qbYlXpDISbrY)SzkeTTUviA)Qfc(qbcsFhPp(YYwfcqblaILSJcK(os3zfqAjrAL(j76CJFEbHuq2NweqlaU)(XcJpM)ec(qbYlXpDISbrY)CyK(IfjFOGDeNDgslYROu3keTFfP96fPBMcrBLbAPYMge3SqWhkqq6Xq67i9WiTtnlKcgKgpsJrK2RxKEyKwWjPaxq026EbviABgiTKiTsEI03rAbNKcCbrBzcXyZaPLePvYtKEmKESFYUo34NYaTi8nQ)(XYJpM)ec(qbYlXpDISbrY)uzK(IfjFOGDeNDgslYROu3keTFfPVJ0dJ0SRZlOabutWG0sI0eWKcGuAwifAds71lsl4KuGliAltigBgiTKiTh9ePh7NSRZn(PmqlhwiyPW3pwdXJ5pHGpuG8s8tNiBqK8pVyrYhkypuMafcho4NSRZn(jb4wDXmcafF)yHRhZFYUo34NzTUuUZnkSVG)je8HcKxIVFSW9hZFcbFOa5L4Nor2Gi5FYUoVGceqnbdsljsResFhPhgPvgPfCskWfeTLjeJfg600gK2RxKwWjPaxq0wMqmwFfi9yi9DKwzK(IfjFOGDeNDgslYROu3keTF9NSRZn(jCdkhGRF)yHtpM)ec(qbYlXpDISbrY)8IfjFOG9qzcuiC4GFYUo34NhktGcHdh89J1q6X8NqWhkqEj(PtKnis(NY(IBwciNUSrAjXJ0dHN)KDDUXpLb6HYe47hlC4J5pHGpuG8s8tNiBqK8pvgPBMcrBp0mifzFXnle8HceK(osRmsFXIKpuWoIZodPf5vuiSy8IHYg1i9DKwWjPaxq0wMqm2mqAjrA215gw4guoaxTUDPKDu8t215g)eUbLdW1VFSuYZhZFcbFOa5L4Nor2Gi5Foms3mfI2sG6gLdLjGXcbFOabP96fPvgPVyrYhkyhXzNH0I8kk1Tcr7xrAVErAzFXnlbKtx2ingG0E0tK2RxK(4llBRqZ1vOq9AsJvavoddsJbinUq6Xq67iTYi9fls(qbRIDPziTiVIYHYeOq4Wbi9DKwzK(IfjFOGDeNDgslYROqyX4fdLnQ)j76CJFYrKQtk35gF)yPKspM)ec(qbYlXpDISbrY)CyKUzkeTLa1nkhktaJfc(qbcs71lsRmsFXIKpuWoIZodPf5vuQBfI2VI0E9I0Y(IBwciNUSrAmaP9ONi9yi9DKwzK(IfjFOGvXU0mKwKxrPcnJ03rALr6lwK8Hcwf7sZqArEfLdLjqHWHdq67iTYi9fls(qb7io7mKwKxrHWIXlgkBu)t215g)0PMxtX0ICC47hlLW4J5pHGpuG8s8tNiBqK8pBMcrBp0mifzFXnle8HceK(osl4KuGliAltigBgiTKin76CdlCdkhGRw3UuYok(j76CJFc3GYb463pwk5XhZFYUo34NeOUHPCYg(je8HcKxIVFSuAiEm)je8HcKxIF6ezdIK)PYiDZuiABDRq0(vle8HceK(osl4KuGliABDVGkeTndKwsK2PMfsbds7HrAL8ePVJ0ntHOTeOUr5qzcySqWhkq(j76CJFkd0IW3O(7hlLW1J5pHGpuG8s8tNiBqK8pR7fuHOTK00C4aKwsKwjCH0E9I0hFzz763LvUi4qky9v8t215g)ugOhktGVFSuc3Fm)je8HcKxIF6ezdIK)zDVGkeTLKMMdhG0sI0kHlK2RxKEyK(4llBx)USYfbhsbRVcK(osRms3mfI2w3keTF1cbFOabPh7NSRZn(PmqlcFJ6VFSucNEm)je8HcKxIF6ezdIK)zDVGkeTLKMMdhG0sI0kHRFYUo34NxqifK9Pfb0cG7VFSuAi9y(ti4dfiVe)0jYgej)ZMPq0wcu3OCOmbmwi4dfi)KDDUXpB1IDurkLZl47V)jymq4aZJ5JLspM)KDDUXpDB4GOfCdKImLRWpHGpuG8s89JfgFm)j76CJFEO7skRCPvdfiG6TFcbFOa5L47hlp(y(t215g)uQplijhLvUW4iqST6FcbFOa5L47hRH4X8NSRZn(P868naPW4iqKnuoax)je8HcKxIVFSW1J5pzxNB8tf(Iu(wgslhkB6FcbFOa5L47hlC)X8NSRZn(zRgk(Xz9dsrEfo4NqWhkqEj((XcNEm)j76CJFksfkOqjJIrb7GFcbFOa5L47hRH0J5pzxNB8ZrRGsUGmkcWSbho4NqWhkqEj((Xch(y(ti4dfiVe)0jYgej)tzFXnKgdq6HWtK(osF8LLTvO56kuOEnPX6R4NSRZn(zfQR4wzLluFxskebWvZ3F)tciZ(0(X8XsPhZFcbFOa5L4NRIFAG(NSRZn(5fls(qHFEXuF4NntHOTYPW0LdDxIfc(qbcs71lsBuauAPzHuOn2dLjqHWHducPLepspms7rKgNr6MPq02wWjTSYfHFgwi4dfii9y)8IfLGRWppuMafcho47hlm(y(ti4dfiVe)Cv8td0)KDDUXpVyrYhk8ZlM6d)uzKEyKwzKUzkeTnGkysJfc(qbcs71ls72Ls2rHnGkysJvam5gs71ls72Ls2rHnGkysJvavoddsljs3Sqk02oRqP3cjbK2RxK2TlLSJcBavWKgRaQCggKwsKg39ePh7NxSOeCf(5io7mKwKxrjGkysZ3pwE8X8NqWhkqEj(5Q4NgO)j76CJFEXIKpu4Nxm1h(PYiDZuiAlbQBKole8HceK(os72Ls2rHTcnxxHc1Rjnwbu5mmingG04osFhPL9f3SeqoDzJ0sI0E0tK(ospmsRmsFXIKpuWoIZodPf5vucOcM0G0E9I0UDPKDuydOcM0yfqLZWG0yasRKNi9y)8IfLGRWpvSlndPf5vuQqZF)ynepM)ec(qbYlXpxf)0a9pzxNB8ZlwK8Hc)8IP(WpVyrYhkypuMafchoaPVJ0dJ0Y(IBingG04eUqACgPBMcrBLtHPlh6Uele8HceK2dJ0y0tKESFEXIsWv4Nk2LMH0I8kkhktGcHdh89JfUEm)je8HcKxIFUk(Pb6FYUo34NxSi5df(5ft9HF2mfI2sG6gPZcbFOabPVJ0kJ0ntHOThAgKISV4Mfc(qbcsFhPD7sj7OWc3GYb4QvavoddsJbi9WiTuhXw5HgP9Wingr6Xq67iTSV4MLaYPlBKwsKgJE(ZlwucUc)uXU0mKwKxrbUbLdW1VFSW9hZFcbFOa5L4NRIFAG(NSRZn(5fls(qHFEXuF4NntHOTewmEXqzJAle8HceK(osRmsFXIKpuWQyxAgslYROCOmbkeoCasFhPvgPVyrYhkyvSlndPf5vuQqZi9DK2TlLSJclHfJxmu2O26R4NxSOeCf(5io7mKwKxrHWIXlgkBu)9Jfo9y(ti4dfiVe)Cv8td0)KDDUXpVyrYhk8ZlM6d)SzkeTTUviA)Qfc(qbcsFhPvgPp(YY26wHO9RwFf)8IfLGRWphXzNH0I8kk1Tcr7x)(XAi9y(t215g)KKgHVI(NqWhkqEj((Xch(y(t215g)0THXVcLklnD)ec(qbYlX3pwk55J5pHGpuG8s8tNiBqK8pL6iwbu5mminEK2ZFYUo34NoMslSRZnk000)KMMUeCf(PBxkzhfF)yPKspM)ec(qbYlXpDISbrY)u2xCZsa50LnsljEK2J46NSRZn(PI0nEXxrrwWsRq0F)yPegFm)je8HcKxIF6ezdIK)zZuiAlHfJxmu2O2cbFOabPVJ0dJ0xSi5dfSJ4SZqArEffclgVyOSrns71lstGJVSSLWIXlgkBuB9vG0J9t215g)0XuAHDDUrHMM(N000LGRWpjSy8IHYg1F)yPKhFm)je8HcKxIF6ezdIK)zZuiAlbQBKole8HcKFYUo34Nc)OWUo3Oqtt)tAA6sWv4NeOUr6((XsPH4X8NqWhkqEj(j76CJFk8Jc76CJcnn9pPPPlbxHFgROY0V)(NkeGBRhUFmFSu6X8NqWhkqEj((XcJpM)ec(qbYlX3pwE8X8NqWhkqEj((XAiEm)je8HcKxIVFSW1J5pzxNB8tfBNB8ti4dfiVeF)yH7pM)ec(qbYlXpDISbrY)uzKMXrGiBW6uZBNUsl4WiVIk35gwi4dfi)KDDUXpRqZ1vOq9AsZ3F)tcu3iDpMpwk9y(ti4dfiVe)0jYgej)ZlwK8Hc2dLjqHWHd(j76CJFsaUvxmJaqX3pwy8X8NqWhkqEj(PtKnis(Ncojf4cI2YeIX6RaP96fPfCskWfeTLjeJndKwsKgJ46NSRZn(jCdkhGRF)y5XhZFcbFOa5L4Nor2Gi5FomspmsRms72Ls2rHfUbLdWvRVcK2RxK(4llBRqZ1vOq9AsJ1xbspgsFhPfCskWfeTLjeJndKwsK2JEI0JH0E9I0SRZlOabutWG0sI0eWKcGuAwifAZpzxNB8tzGwoSqWsHVFSgIhZFcbFOa5L4Nor2Gi5FEXIKpuWEOmbkeoCasFhPvgPD7sj7OWwHMRRqH61KgRayYnK(ospms72Ls2rHfUbLdWvRaQCggKwsKEyKgxinoJ0mocezdwbCT0RmKwouMagRGJXrApms7rKEmK2RxKEyKwWjPaxq0wMqm2mqAjrA215g2dLjqHWHdSUDPKDuG03rAbNKcCbrBzcXyZaPXaKgJ4cPhdPh7NSRZn(5HYeOq4WbF)yHRhZFYUo34NzTUuUZnkSVG)je8HcKxIVFSW9hZFcbFOa5L4Nor2Gi5FQmsFXIKpuWQyxAgslYROCOmbkeoCWpzxNB8toIuDs5o347hlC6X8NqWhkqEj(PtKnis(NY(IBwciNUSrAjXJ0dHN)KDDUXpLb6HYe47hRH0J5pHGpuG8s8tNiBqK8pvgPVyrYhkyvSlndPf5vuouMafchoaPVJ0kJ0xSi5dfSk2LMH0I8kkWnOCaU(t215g)0PMxtX0ICC47hlC4J5pHGpuG8s8tNiBqK8pBMcrBjqDJYHYeWyHGpuGG03rALrA3UuYokSWnOCaUAfatUH03r6HrANAwifminEKgJiTxVi9WiTGtsbUGOT19cQq02mqAjrAL8ePVJ0cojf4cI2YeIXMbsljsRKNi9yi9y)KDDUXpLbAr4Bu)9JLsE(y(t215g)Ka1nmLt2WpHGpuG8s89JLsk9y(ti4dfiVe)0jYgej)ZJVSSD97YkxeCifS(k(j76CJF2Qf7OIukNxW3pwkHXhZFcbFOa5L4Nor2Gi5Fw3lOcrBjPP5WbiTKiTs4cP96fPp(YY21VlRCrWHuW6R4NSRZn(PmqlcFJ6VFSuYJpM)ec(qbYlXpDISbrY)SUxqfI2sstZHdqAjrALW1pzxNB8ZliKcY(0IaAbW93pwknepM)ec(qbYlXpDISbrY)SzkeTLa1nkhktaJfc(qbYpzxNB8ZwTyhvKs58c((7F62Ls2rXJ5JLspM)ec(qbYlXpDISbrY)uzKEyKUzkeTLa1nsNfc(qbcs71lsFXIKpuWQyxAgslYROuHMrAVEr6lwK8Hc2rC2ziTiVIsavWKgKEmK2RxKUZku6TqsaPXaKgJ46NSRZn(zfAUUcfQxtA((XcJpM)ec(qbYlXpDISbrY)SzkeTLa1nsNfc(qbcsFhPhgPvgPzCeiYgSo182PR0comYROYDUHfc(qbcs71lspms72Ls2rHfUbLdWvRaQCggKwsKgJEI03rA3UuYokShktGcHdhyfqLZWG0sI0sDeBLhAKEmKESFYUo34NvO56kuOEnP57hlp(y(ti4dfiVe)0jYgej)tbNKcCbrBzcXyHHonTbPVJ0e44llBdOcM0yj7OaPVJ0dJ0SRZlOabutWG0sI0eWKcGuAwifAds71lsl4KuGliAltigBgiTKinU7jsp2pzxNB8ZaQGjnF)ynepM)ec(qbYlXpDISbrY)uzKwWjPaxq0wMqmwyOttB(j76CJFgqfmP57hlC9y(ti4dfiVe)0jYgej)ZJVSSTcnxxHc1Rjnwbu5mmiTKingXfs71ls3Sqk02oRqP3cjbKgdqAC3ZFYUo34Nk2o347hlC)X8NqWhkqEj(zWv4NxSi5dfkz0qyY(wrAkLVwAxwJlPuUZqAraSRxXpzxNB8ZlwK8HcLmAimzFRinLYxlTlRXLuk3ziTia21R47hlC6X8NqWhkqEj(j76CJF6ykTWUo3Oqtt)tAA6sWv4NGXaHdmF)9pjSy8IHYg1pMpwk9y(ti4dfiVe)0jYgej)tzFXnKws8i9qYtK(ospmsRmsFXIKpuWEOmbkeoCas71lsRms72Ls2rH9qzcuiC4aRayYnKESFYUo34NewmEXqzJ6VFSW4J5pHGpuG8s8tNiBqK8pjWXxw2syX4fdLnQT(k(j76CJFYrKQtk35gF)y5XhZFcbFOa5L4Nor2Gi5FsGJVSSLWIXlgkBuB9v8t215g)0PMxtX0ICC47V)(NxGWKB8yHrpvch6jo5jozXOh9uPFoIfrgsn)ehGhkUflpeSgYWXinsJPAaPZQIv0iT8kqApqciZ(02dePfWqUFkacsB2kG0SFVvUbcs7uZHuWyrdWbodaPvsjCmspudJVcfRObcsZUo3aP9avKUXl(kkYcwAfI2d0IgGg4HuvSIgiinoH0SRZnqAAAAJfn4NSFREf)CMvFk35g4GcwU)PcXkNu4NyisJBWxRdP9GH6ginUHF0GanadrA1DRWGJXgBPzR2)yDBfBtw9PCNB4eSCJTjRoSrdWqKEGp9gsJtQG0y0tLWHinoJ0yeJ4yCHl0a0amePXbWIidPgCmAagI04mspunzifP9GH6giTeuMagKUYJdgKUUMgPhk(IBiTuiab35giTcFbqVH04wSgYqAIiVGaP5GG0(HcbqsxZhkOcspsD6uJ0JskfPZQc21iDRgq6HCFMM9nKELrAb42Afcc35gglAagI04mspunzifP9G2keTFfPtdshBJ0cWT1keeGGBcPhkafPXT(g1i9OKsr6dG0cWT1keeGG0Cqq6wnG0gwg6Bi9kJ0dfGI04wFJAK2XrSnsFaKMan4AGG0NBintiBySObObyisJdQMdPGbhJgGHinoJ0EOecqqACWnm(vaP9GyPPZIgGHinoJ04wOUxabPBwif6skJ0o1GBCKwEfinwqfmPbP5tsZ(MfnadrACgPXTqDVacsx3lOcrJ08jPzNGbPLfBfPviYvK9nKEKAiq6yBK23aeKwEfiTh0wHO9Rw0amePXzK2dLqacspunas7H0q1G09I0qqq6vgPXb3Ls2rHbPzxNBqttBrdWqKgNrACWnUardeK2dWTlLSJcpaKUxK2dGDDUHfhiRBxkzhfEai9i1GaqAwHcA64dfSObObyisJBEObNFdeK(aYRaqA3wpCJ0hqAggls7H6CGI2G0Xg4SAwuL9Pin76CddsVb9MfnGDDUHXQqaUTE4gVmLnJJgWUo3Wyvia3wpCRkESzFPviAUZnqdyxNBySkeGBRhUvfp2Y7sqdWqKEgScJ6TrAbNeK(4lldeK20CBq6diVcaPDB9WnsFaPzyqAoiiTcbGZk2UZqksNgKMSbyrdyxNBySkeGBRhUvfp2MGvyuVDX0CBqdyxNBySkeGBRhUvfp2k2o3anGDDUHXQqaUTE4wv8yxHMRRqH61Kgvsz8kZ4iqKnyDQ5TtxPfCyKxrL7Cdle8Hce0a0amePXnp0GZVbcsdxG4gs3zfq6wnG0SRxbsNgKMV4KYhkyrdyxNByufp2xSi5dfuj4kG)qzcuiC4avUyQpGVzkeTvofMUCO7sSqWhkq861OaO0sZcPqBShktGcHdhOKK4h2J4CZuiABl4Kww5IWpdle8HcKXqdyxNByufp2xSi5dfuj4kGFeNDgslYROeqfmPrLlM6d4vEyLBMcrBdOcM0yHGpuG41RBxkzhf2aQGjnwbWKBE962Ls2rHnGkysJvavodJKnlKcTTZku6TqsWRx3UuYokSbubtAScOYzyKe39Cm0a215ggvXJ9fls(qbvcUc4vSlndPf5vuQqZQCXuFaVYntHOTeOUr6SqWhkqU72Ls2rHTcnxxHc1Rjnwbu5mmyaUFx2xCZsa50LTKE0Z7dR8fls(qb7io7mKwKxrjGkysJxVUDPKDuydOcM0yfqLZWGbk55yObSRZnmQIh7lwK8HcQeCfWRyxAgslYROCOmbkeoCGkxm1hWFXIKpuWEOmbkeoCW9HL9f3WaCcx4CZuiARCkmD5q3LyHGpuG4HXONJHgWUo3WOkESVyrYhkOsWvaVIDPziTiVIcCdkhGRQCXuFaFZuiAlbQBKole8HcK7k3mfI2EOzqkY(IBwi4dfi3D7sj7OWc3GYb4QvavoddgmSuhXw5H2dJXXUl7lUzjGC6Ywsm6jAa76CdJQ4X(IfjFOGkbxb8J4SZqArEffclgVyOSrTkxm1hW3mfI2syX4fdLnQTqWhkqUR8fls(qbRIDPziTiVIYHYeOq4Wb3v(IfjFOGvXU0mKwKxrPcnF3TlLSJclHfJxmu2O26RanGDDUHrv8yFXIKpuqLGRa(rC2ziTiVIsDRq0(vvUyQpGVzkeTTUviA)Qfc(qbYDLp(YY26wHO9RwFfObSRZnmQIhBsAe(kA0a215ggvXJTBdJFfkvwA6qdyxNByufp2oMslSRZnk000QeCfW72Ls2rHkPmEPoIvavoddEprdyxNByufp2ks34fFffzblTcrRskJx2xCZsa50LTK49iUqdyxNByufp2oMslSRZnk000QeCfWtyX4fdLnQvjLX3mfI2syX4fdLnQTqWhkqUp8fls(qb7io7mKwKxrHWIXlgkBu71lbo(YYwclgVyOSrT1xXyObSRZnmQIhBHFuyxNBuOPPvj4kGNa1nsNkPm(MPq0wcu3iDwi4dfiObSRZnmQIhBHFuyxNBuOPPvj4kGpwrLPObObSRZnmw3UuYokWxHMRRqH61Kgvsz8kpCZuiAlbQBKole8HceVEVyrYhkyvSlndPf5vuQqZE9EXIKpuWoIZodPf5vucOcM0mMxVDwHsVfscyagXfAa76CdJ1TlLSJcvXJDfAUUcfQxtAujLX3mfI2sG6gPZcbFOa5(WkZ4iqKnyDQ5TtxPfCyKxrL7Cdle8HceVEh2TlLSJclCdkhGRwbu5mmsIrpV72Ls2rH9qzcuiC4aRaQCggjL6i2kp0JngAa76CdJ1TlLSJcvXJDavWKgvsz8cojf4cI2YeIXcdDAAZDcC8LLTbubtASKDuCFy215fuGaQjyKKaMuaKsZcPqB86vWjPaxq0wMqm2mKe39Cm0a215ggRBxkzhfQIh7aQGjnQKY4vwWjPaxq0wMqmwyOttBqdyxNBySUDPKDuOkESvSDUHkPm(JVSSTcnxxHc1Rjnwbu5mmsIrC51BZcPqB7ScLElKeWaC3t0a215ggRBxkzhfQIhBFduYgQQeCfWFXIKpuOKrdHj7BfPPu(APDznUKs5odPfbWUEfObSRZnmw3UuYokufp2oMslSRZnk000QeCfWdgdeoWGgGgWUo3WyjSy8IHYg14jSy8IHYg1QKY4L9f3Ke)qYZ7dR8fls(qb7HYeOq4WbE9QSBxkzhf2dLjqHWHdScGj3gdnGDDUHXsyX4fdLnQvfp2CeP6KYDUHkPmEcC8LLTewmEXqzJARVc0a215gglHfJxmu2Owv8y7uZRPyArooOskJNahFzzlHfJxmu2O26RananGDDUHXsG6gPdpb4wDXmcafQKY4VyrYhkypuMafchoanGDDUHXsG6gPtv8yd3GYb4QkPmEbNKcCbrBzcXy9v41RGtsbUGOTmHySzijgXfAa76CdJLa1nsNQ4XwgOLdleSuqLug)WdRSBxkzhfw4guoaxT(k8694llBRqZ1vOq9AsJ1xXy3fCskWfeTLjeJndj9ONJ51l768ckqa1emssatkasPzHuOnObSRZnmwcu3iDQIh7dLjqHWHdujLXFXIKpuWEOmbkeoCWDLD7sj7OWwHMRRqH61KgRayYT7d72Ls2rHfUbLdWvRaQCggjhgx4mJJar2Gvaxl9kdPLdLjGXk4yCpShhZR3HfCskWfeTLjeJndjzxNBypuMafchoW62Ls2rXDbNKcCbrBzcXyZadWiUgBm0a215gglbQBKovXJDwRlL7CJc7ly0a215gglbQBKovXJnhrQoPCNBOskJx5lwK8Hcwf7sZqArEfLdLjqHWHdqdyxNBySeOUr6ufp2Ya9qzcOskJx2xCZsa50LTK4hcprdyxNBySeOUr6ufp2o18AkMwKJdQKY4v(IfjFOGvXU0mKwKxr5qzcuiC4G7kFXIKpuWQyxAgslYROa3GYb4kAa76CdJLa1nsNQ4XwgOfHVrTkPm(MPq0wcu3OCOmbmwi4dfi3v2TlLSJclCdkhGRwbWKB3h2PMfsbdEm617Wcojf4cI2w3lOcrBZqsL88UGtsbUGOTmHySziPsEo2yObSRZnmwcu3iDQIhBcu3WuozdObSRZnmwcu3iDQIh7wTyhvKs58cujLXF8LLTRFxw5IGdPG1xbAa76CdJLa1nsNQ4XwgOfHVrTkPm(6EbviAljnnhoqsLWLxVhFzz763LvUi4qky9vGgWUo3WyjqDJ0PkESVGqki7tlcOfa3QKY4R7fuHOTK00C4ajvcxObSRZnmwcu3iDQIh7wTyhvKs58cujLX3mfI2sG6gLdLjGXcbFOabnanGDDUHXcgdeoWG3THdIwWnqkYuUcObSRZnmwWyGWbgvXJ9HUlPSYLwnuGaQ3qdyxNBySGXaHdmQIhBP(SGKCuw5cJJaX2QrdyxNBySGXaHdmQIhB515BasHXrGiBOCaUIgWUo3WybJbchyufp2k8fP8TmKwou20ObSRZnmwWyGWbgvXJDRgk(Xz9dsrEfoanGDDUHXcgdeoWOkESfPcfuOKrXOGDaAa76CdJfmgiCGrv8ypAfuYfKrraMn4WbObSRZnmwWyGWbgvXJDfQR4wzLluFxskebWvJkPmEzFXnmyi88(Xxw2wHMRRqH61KgRVc0a0a215ggBSIktXFbHuq2NweqlaUvjLX3mfI2w3keTF1cbFOa5(Xxw2QqakybqSKDuCVZkiPsObSRZnm2yfvMQkESLbAr4BuRskJF4lwK8Hc2rC2ziTiVIsDRq0(vVEBMcrBLbAPYMge3SqWhkqg7(Wo1SqkyWJrVEhwWjPaxq026EbviABgsQKN3fCskWfeTLjeJndjvYZXgdnGDDUHXgROYuvXJTmqlhwiyPGkPmELVyrYhkyhXzNH0I8kk1Tcr7xVpm768ckqa1emssatkasPzHuOnE9k4KuGliAltigBgs6rphdnGDDUHXgROYuvXJnb4wDXmcafQKY4VyrYhkypuMafchoanGDDUHXgROYuvXJDwRlL7CJc7ly0a215ggBSIktvfp2WnOCaUQskJNDDEbfiGAcgjv6(Wkl4KuGliAltiglm0PPnE9k4KuGliAltigRVIXUR8fls(qb7io7mKwKxrPUviA)kAa76CdJnwrLPQIh7dLjqHWHdujLXFXIKpuWEOmbkeoCaAa76CdJnwrLPQIhBzGEOmbujLXl7lUzjGC6Yws8dHNObSRZnm2yfvMQkESHBq5aCvLugVYntHOThAgKISV4Mfc(qbYDLVyrYhkyhXzNH0I8kkewmEXqzJ67cojf4cI2YeIXMHKSRZnSWnOCaUAD7sj7OanGDDUHXgROYuvXJnhrQoPCNBOskJF4MPq0wcu3OCOmbmwi4dfiE9Q8fls(qb7io7mKwKxrPUviA)QxVY(IBwciNUSXap6PxVhFzzBfAUUcfQxtAScOYzyWaCn2DLVyrYhkyvSlndPf5vuouMafcho4UYxSi5dfSJ4SZqArEffclgVyOSrnAa76CdJnwrLPQIhBNAEnftlYXbvsz8d3mfI2sG6gLdLjGXcbFOaXRxLVyrYhkyhXzNH0I8kk1Tcr7x96v2xCZsa50Lng4rph7UYxSi5dfSk2LMH0I8kkvO57kFXIKpuWQyxAgslYROCOmbkeoCWDLVyrYhkyhXzNH0I8kkewmEXqzJA0a215ggBSIktvfp2WnOCaUQskJVzkeT9qZGuK9f3SqWhkqUl4KuGliAltigBgsYUo3Wc3GYb4Q1TlLSJc0a215ggBSIktvfp2eOUHPCYgqdyxNBySXkQmvv8yld0IW3OwLugVYntHOT1Tcr7xTqWhkqUl4KuGliABDVGkeTndjDQzHuW4HvYZ7ntHOTeOUr5qzcySqWhkqqdyxNBySXkQmvv8yld0dLjGkPm(6EbviAljnnhoqsLWLxVhFzz763LvUi4qky9vGgWUo3WyJvuzQQ4XwgOfHVrTkPm(6EbviAljnnhoqsLWLxVdF8LLTRFxw5IGdPG1xXDLBMcrBRBfI2VAHGpuGmgAa76CdJnwrLPQIh7liKcY(0IaAbWTkPm(6EbviAljnnhoqsLWfAa76CdJnwrLPQIh7wTyhvKs58cujLX3mfI2sG6gLdLjGXcbFOa57V)h]] )


end
