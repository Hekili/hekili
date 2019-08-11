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
        name = "Recommend Movement",
        desc = "If checked, the addon will recommend |T1247261:0|t Fel Rush / |T1348401:0|t Vengeful Retreat when it is a potential DPS gain.\n\n" ..
            "These abilities are critical for DPS when using the Momentum talent.\n\n" ..
            "If not using Momentum, you may want to leave this disabled to avoid unnecessary movement in combat.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Havoc", 20190810, [[dOedebqisulIkkLhPKOnPsAukrDkLiRsjbEfvKzrcUfvuSlk9liPHHs6yKqltLONrsX0ujORrfvBdLiFtLaJtLqohkr16usqVJkkjZJKs3dsTpuQoikrXcjP6HOeLMikb5IurjSruc4JurjAKOeOtQKq1kvsDtQOuTtsKLQKqEQkMkkLRIsq9vLekgRscL2RQ(RGbtXHjwSs9yQAYiDzWMH4ZuHrtsoTKxRK0Sr1TfA3I(TIHJchNkkPwoINtQPl11PsBxL67kHXRsOopKy9OeA(OO9d1VIpB)Hkn8kDjRkYYz9IuKv7LQrnxKZzP)0OWa(ddXVQ4a(tkr4pSGY94)ddbf(i0NT)OhxIh(JQUzOxHOIQJQv5UT(jIQUIUCPRj9ebPrvxrpQ)z7w8Efp)9FOsdVsxYQISCwVifz1EPAuZf5Cf)JMb4FLC(fCb)rvrPq(7)qbT)pReBybL7XJnSqqCsSHf0nBGGxVsSrv3m0Rqur1r1QC3w)ervxrxU01KEIG0OQROhv86vInSmUoC1n2CbkGnxYQISCSXzWMlzDfQgwXRXRxj2SIrizLo0Rq86vInod2WcRR0b2WcbXjXg15cf0ytuwf0ytC0n2Wc4sqbBCajqKUMeBy4saokyZksjNLydLu3qInssXg3KbbOLVLnhuaBwOQ8QWMffNJnvKH4BSPvbyJZAxHxnkyZGGneWpXiKuPRj1w86vInod2WcRR0b24SpriB3i2uASjNgBiGFIriPa1zf2WcaCSzf5QvHnlkohB2a2qa)eJqsbk2ijfBAva2OfeOrbBgeSHfa4yZkYvRcB8sMtJnBaBOqd(gOyZgfSrO0j12)WlDRF2(toKOWF2ELu8z7pqkBoqF1)JNunqk5pTWHSTXjcz7gTqkBoqXMRyZ2fbXYGamecqT0zrInxXMUIa2Wo2O4FeFxt(NBiDaiU8abAci93Vsx(S9hiLnhOV6)XtQgiL8NLXMBHuYMd2fs1v6iGmKqCIq2UrSHjtSPfoKTfb4HOOBGGIfszZbk2Se2CfBwgB8QeIdqJnOXMlXgMmXMLXgIu0aCdzBJZneHSTvInSJnkYk2CfBisrdWnKTvOuTTsSHDSrrwXMLWML(J47AY)Ga8aXvR67xj18S9hiLnhOV6)XtQgiL8hLXMBHuYMd2fs1v6iGmKqCIq2UrS5k2Sm2i(UUHaKqSan2Wo2qbDraAOfIdO1ydtMydrkAaUHSTcLQTvInSJnQHvSzP)i(UM8piapSfcrCaF)kDHpB)bszZb6R(F8KQbsj)5wiLS5GDZfkeOs6H)i(UM8puqAvb9cay89RKZF2(J47AY)uX4WLUMmiUe5pqkBoqF1)(vILE2(dKYMd0x9)4jvdKs(J476gcqcXc0yd7yJIyZvSzzSrzSHifna3q2wHs1w4IlDRXgMmXgIu0aCdzBfkvBDzGnlHnxXgLXMBHuYMd2fs1v6iGmKqCIq2UX)i(UM8pakqyds87xPl4z7pqkBoqF1)JNunqk5p3cPKnhSBUqHavsp8hX31K)zZfkeOs6HVFLUONT)aPS5a9v)pEs1aPK)G4sqXsbKYxn2WoAS5cz9pIVRj)dcW3CHcF)kXYF2(dKYMd0x9)4jvdKs(JYytlCiB7MxjnG4sqXcPS5afBUInkJn3cPKnhSlKQR0razibQqwnO5Iwf2CfBisrdWnKTvOuTTsSHDSr8DnPfqbcBqIw)mC6Si)J47AY)aOaHniXVFLuK1NT)aPS5a9v)pEs1aPK)Sm20chY2sH4KHnxOG2cPS5afByYeBugBUfsjBoyxivxPJaYqcXjcz7gXgMmXgexckwkGu(QXg1InQHvSHjtSz7IGyJqlXHWq1OlTLarPsn2OwSX5yZsyZvSrzS5wiLS5GLXm8kDeqgsyZfkeOs6bS5k2Om2ClKs2CWUqQUshbKHeOcz1GMlAv)r8Dn5FKmlvfx6AYVFLuuXNT)aPS5a9v)pEs1aPK)Sm20chY2sH4KHnxOG2cPS5afByYeBugBUfsjBoyxivxPJaYqcXjcz7gXgMmXgexckwkGu(QXg1InQHvSzjS5k2Om2ClKs2CWYygELocidjeHwWMRyJYyZTqkzZblJz4v6iGmKWMluiqL0dyZvSrzS5wiLS5GDHuDLocidjqfYQbnx0Q(J47AY)4vjJoOBsTk89RKIx(S9hiLnhOV6)XtQgiL8Nw4q22nVsAaXLGIfszZbk2CfBisrdWnKTvOuTTsSHDSr8DnPfqbcBqIw)mC6Si)J47AY)aOaHniXVFLuunpB)r8Dn5FOqCsDyxn8hiLnhOV6F)kP4f(S9hiLnhOV6)XtQgiL8hLXMw4q224eHSDJwiLnhOyZvSHifna3q224CdriBBLyd7yJxLqCaASzfGnkYk2CfBAHdzBPqCYWMluqBHu2CG(hX31K)bb4bIRw13Vsk68NT)aPS5a9v)pEs1aPK)eNBiczBPLUL0dyd7yJIohByYeB2Uii2XTddsGiPdW6Y4pIVRj)dcW3CHcF)kPil9S9hiLnhOV6)XtQgiL8N4CdriBlT0TKEaByhBu05ydtMyZYyZ2fbXoUDyqcejDawxgyZvSrzSPfoKTnoriB3OfszZbk2S0FeFxt(heGhiUAvF)kP4f8S9hiLnhOV6)XtQgiL8N4CdriBlT0TKEaByhBu05)r8Dn5FUH0bG4YdeOjG0F)kP4f9S9hiLnhOV6)XtQgiL8Nw4q2wkeNmS5cf0wiLnhO)r8Dn5FAvKzrWbxQB47V)dO1q6b9Z2RKIpB)r8Dn5F8t6HSjsd0acxIWFGu2CG(Q)9R0LpB)bszZb6R(F8KQbsj)z7IGyJqlXHWq1OlT1Lb2WKj20vec9eOfGnQfn2OiR)r8Dn5F28zOHbj0QGaKqeLVFLuZZ2FGu2CG(Q)hpPAGuYF2Uii2i0sCimun6sBDzGnmzInDfHqpbAbyJArJnQH1)i(UM8poCfcTKmmibHfbY0Q((v6cF2(dKYMd0x9)4jvdKs(JMbW5HwioGwB3CHcbQKEqrSHD0yZLydtMydrkAaUHSTcLQTvInSJnSeR)r8Dn5FqgVRgObHfbs1qyds87xjN)S9hiLnhOV6)XtQgiL8hndGZdTqCaT2U5cfcuj9GIyd7OXMlXgMmXgIu0aCdzBfkvBReByhByjw)J47AY)WWLuiOuPJWMl6(7xjw6z7pqkBoqF1)JNunqk5pBxeelb8RYbToGmepyDzGnmzInBxeelb8RYbToGmepe8JB2aXQBXVk2OwSrrw)J47AY)0QGGBUh3KgqgIh((v6cE2(J47AY)qkgm4qOYGMH4H)aPS5a9v)7xPl6z7pqkBoqF1)JNunqk5pBxeelVqGnFgQv3IFvSrTyJA(J47AY)SyiC6nuzGa6jL0dF)kXYF2(dKYMd0x9)4jvdKs(dIlbfSrTyZfYk2CfB2Uii2i0sCimun6sBDz8hX31K)jcXHGsyqcCxFrducir93F)hkGiU8(z7vsXNT)aPS5a9v)pdJ)OH(pIVRj)ZTqkzZH)ClCx4pTWHSTifr3HnFgQfszZbk2WKj2OzaCEOfIdO12nxOqGkPhueByhn2Sm2OgSXzWMw4q22MifpmibIBLwiLnhOyZs)5wiHuIWF2CHcbQKE47xPlF2(dKYMd0x9)mm(Jg6)i(UM8p3cPKnh(ZTWDH)Om2Sm2Om20chY2Mqe0L2cPS5afByYeB8ZWPZI0Mqe0L2saHIc2WKj24NHtNfPnHiOlTLarPsn2Wo20cXb02UIqONaTaSHjtSXpdNolsBcrqxAlbIsLASHDSHLyfBw6p3cjKse(ZcP6kDeqgsiHiOl93VsQ5z7pqkBoqF1)ZW4pAO)J47AY)ClKs2C4p3c3f(JYytlCiBlfItwElKYMduS5k24NHtNfPncTehcdvJU0wceLk1yJAXgwcBUIniUeuSuaP8vJnSJnQHvS5k2Sm2Om2ClKs2CWUqQUshbKHesic6sJnmzIn(z40zrAtic6sBjquQuJnQfBuKvSzP)ClKqkr4pmMHxPJaYqcrOLVFLUWNT)aPS5a9v)pdJ)OH(pIVRj)ZTqkzZH)ClCx4p3cPKnhSBUqHavspGnxXMLXgexckyJAXMlW5yJZGnTWHSTifr3HnFgQfszZbk2ScWMlzfBw6p3cjKse(dJz4v6iGmKWMluiqL0dF)k58NT)aPS5a9v)pdJ)OH(pIVRj)ZTqkzZH)ClCx4pTWHSTuioz5TqkBoqXMRyJYytlCiB7MxjnG4sqXcPS5afBUIn(z40zrAbuGWgKOLarPsn2OwSzzSXHNAJYfJnRaS5sSzjS5k2G4sqXsbKYxn2Wo2CjR)5wiHuIWFymdVshbKHeauGWgK43VsS0Z2FGu2CG(Q)NHXF0q)hX31K)5wiLS5WFUfUl8Nw4q2wQqwnO5IwLfszZbk2CfBugBUfsjBoyzmdVshbKHe2CHcbQKEaBUInkJn3cPKnhSmMHxPJaYqcrOfS5k24NHtNfPLkKvdAUOvzDz8NBHesjc)zHuDLocidjqfYQbnx0Q((v6cE2(dKYMd0x9)mm(Jg6)i(UM8p3cPKnh(ZTWDH)0chY2gNiKTB0cPS5afBUInkJnBxeeBCIq2UrRlJ)ClKqkr4plKQR0raziH4eHSDJF)kDrpB)r8Dn5FOLM4YO)dKYMd0x9VFLy5pB)r8Dn5F8tQDJqikok)FGu2CG(Q)9RKIS(S9hiLnhOV6)XtQgiL8hhEQLarPsn2GgBy9pIVRj)Jx48G47AYaV09F4LUdPeH)4NHtNf53VskQ4Z2FGu2CG(Q)hpPAGuYFAHdzBPcz1GMlAvwiLnhOyZvSzzS5wiLS5GDHuDLocidjqfYQbnx0QWgMmXgkSDrqSuHSAqZfTkRldSzP)i(UM8pEHZdIVRjd8s3)Hx6oKse(dviRg0CrR67xjfV8z7pqkBoqF1)JNunqk5pTWHSTuioz5TqkBoq)J47AY)qCZG47AYaV09F4LUdPeH)qH4KL)7xjfvZZ2FGu2CG(Q)hX31K)H4MbX31KbEP7)WlDhsjc)jhsu4F)9Fyqa)e3s)S9kP4Z2FGu2CG(Q)NuIWFewuRsiIoGmzhgKaJzbq(J47AY)iSOwLqeDazYomibgZcG89R0LpB)r8Dn5FymDn5FGu2CG(Q)9RKAE2(dKYMd0x9)4jvdKs(JYyJWIaPAW6vjtx(qtKuJmKO01KwiLnhO)r8Dn5FIqlXHWq1Ol93F)hkeNS8pBVsk(S9hiLnhOV6)XtQgiL8NBHuYMd2nxOqGkPh(J47AY)qbPvf0laGX3Vsx(S9hiLnhOV6)XtQgiL8hIu0aCdzBfkvBDzGnmzInePOb4gY2kuQ2wj2Wo2CPZ)J47AY)aOaHniXVFLuZZ2FGu2CG(Q)hpPAGuYFwgBwgBugB8ZWPZI0cOaHnirRldSHjtSz7IGyJqlXHWq1OlT1Lb2Se2CfBisrdWnKTvOuTTsSHDSrnSInlHnmzInIVRBiajelqJnSJnuqxeGgAH4aA9FeFxt(heGh2cHioGVFLUWNT)aPS5a9v)pEs1aPK)ClKs2CWU5cfcuj9a2CfBugB8ZWPZI0gHwIdHHQrxAlbekkyZvSzzSXpdNolslGce2GeTeikvQXg2XMLXgNJnod2iSiqQgSe4E43v6iS5cf0wIKRInRaSrnyZsydtMyZYydrkAaUHSTcLQTvInSJnIVRjTBUqHavspy9ZWPZIeBUInePOb4gY2kuQ2wj2OwS5sNJnlHnl9hX31K)zZfkeOs6HVFLC(Z2FeFxt(NkghU01KbXLi)bszZb6R(3VsS0Z2FGu2CG(Q)hpPAGuYFugBUfsjBoyzmdVshbKHe2CHcbQKE4pIVRj)JKzPQ4sxt(9R0f8S9hiLnhOV6)XtQgiL8hexckwkGu(QXg2rJnxiR)r8Dn5Fqa(Mlu47xPl6z7pqkBoqF1)JNunqk5pkJn3cPKnhSmMHxPJaYqcBUqHavspGnxXgLXMBHuYMdwgZWR0razibafiSbj(hX31K)XRsgDq3KAv47xjw(Z2FGu2CG(Q)hpPAGuYFAHdzBPqCYWMluqBHu2CGInxXgLXg)mC6SiTakqyds0saHIc2CfBwgB8QeIdqJnOXMlXgMmXMLXgIu0aCdzBJZneHSTvInSJnkYk2CfBisrdWnKTvOuTTsSHDSrrwXMLWML(J47AY)Ga8aXvR67xjfz9z7pIVRj)dfItQd7QH)aPS5a9v)7xjfv8z7pqkBoqF1)JNunqk5pBxee742HbjqK0byDz8hX31K)PvrMfbhCPUHVFLu8YNT)aPS5a9v)pEs1aPK)eNBiczBPLUL0dyd7yJIohByYeB2Uii2XTddsGiPdW6Y4pIVRj)dcWdexTQVFLuunpB)bszZb6R(F8KQbsj)jo3qeY2slDlPhWg2XgfD(FeFxt(NBiDaiU8abAci93VskEHpB)bszZb6R(F8KQbsj)PfoKTLcXjdBUqbTfszZb6FeFxt(NwfzweCWL6g((7)4NHtNf5Z2RKIpB)bszZb6R(F8KQbsj)rzSzzSPfoKTLcXjlVfszZbk2WKj2ClKs2CWYygELocidjeHwWgMmXMBHuYMd2fs1v6iGmKqcrqxASzjSHjtSPRie6jqlaBul2CPZ)J47AY)eHwIdHHQrx6VFLU8z7pqkBoqF1)JNunqk5pTWHSTuioz5TqkBoqXMRyZYyJYyJWIaPAW6vjtx(qtKuJmKO01KwiLnhOydtMyZYyJFgoDwKwafiSbjAjquQuJnSJnxYk2CfBwgBugBUfsjBoy3CHcbQKEaByYeB8ZWPZI0U5cfcuj9GLarPsn2Wo24WtTr5IXMLWMLWML(J47AY)eHwIdHHQrx6VFLuZZ2FGu2CG(Q)hpPAGuYFisrdWnKTvOuTfU4s3AS5k2qHTlcInHiOlTLolsS5k2Sm2i(UUHaKqSan2Wo2qbDraAOfIdO1ydtMydrkAaUHSTcLQTvInSJnSeRyZs)r8Dn5Fsic6s)9R0f(S9hiLnhOV6)XtQgiL8hLXgIu0aCdzBfkvBHlU0T(pIVRj)tcrqx6VFLC(Z2FGu2CG(Q)hpPAGuYF2Uii2i0sCimun6sBjquQuJnSJnx6CSHjtSPRie6jqlaBul2WsS(hX31K)HX01KF)kXspB)bszZb6R(FeFxt(hhch8cNdeDypt(hpPAGuYFugBAHdzBraEyleI4aSqkBoqXgMmXg)mC6SiTiapSfcrCawciuu(tkr4poeo4fohi6WEM87xPl4z7pqkBoqF1)J47AY)4rXZNMmz5dBUO7)4jvdKs(Z2fbXgHwIdHHQrxARldS5k2SDrqSrioeucdsG76lAGsajQT0zrInxXMLXgLXMBHuYMd2nxOqGkPhWgMmXgLXg)mC6SiTBUqHavspyjGqrbBw6pacc47qkr4pEu88Pjtw(WMl6(7xPl6z7pqkBoqF1)J47AY)iAv3sc6aryXHe8dr4)XtQgiL8hkSDrqSeHfhsWpeHhOW2fbXsNfj2WKj2Sm2qHTlcI1pj1131neQC1af2UiiwxgydtMyZ2fbXgHwIdHHQrxAlbIsLASHDS5swXMLWMRytlehqBvbcVvzz4BSrTyJAueByYeB6kcHEc0cWg1InxY6Fsjc)r0QULe0bIWIdj4hIW)(vIL)S9hiLnhOV6)r8Dn5FewuRsiIoGmzhgKaJzbq(JNunqk5p(z40zrAJqlXHWq1OlTLarPsn2OwSrrwXgMmXg)mC6SiTrOL4qyOA0L2sGOuPgByhByjw)tkr4pclQvjerhqMSddsGXSaiF)kPiRpB)bszZb6R(F8KQbsj)z7IGyJqlXHWq1OlT1LXFeFxt(hxneQgI6VFLuuXNT)aPS5a9v)pIVRj)Jx48G47AYaV09F4LUdPeH)aAnKEq)93)HkKvdAUOv9S9kP4Z2FGu2CG(Q)hpPAGuYFqCjOGnSJgBUiwXMRyZYyJYyZTqkzZb7MluiqL0dydtMyJYyJFgoDwK2nxOqGkPhSeqOOGnl9hX31K)HkKvdAUOv99R0LpB)bszZb6R(F8KQbsj)HcBxeelviRg0CrRY6Y4pIVRj)JKzPQ4sxt(9RKAE2(dKYMd0x9)4jvdKs(df2UiiwQqwnO5IwL1LXFeFxt(hVkz0bDtQvHV)(7)CdeDn5R0LSQilN1lIv18NfcjR0H(pR4rgdPbk2CbyJ47AsSHx6wBXR)J42QgYFov0LlDnjllrq6)WGmifh(ZkXgwq5E8ydleeNeBybDZgi41ReBu1nd9kevuDuTk3T1pru1v0LlDnPNiinQ6k6rfVELydlJRdxDJnxGcyZLSQilhBCgS5swxHQHv8A86vInRyeswPd9keVELyJZGnSW6kDGnSqqCsSrDUqbn2eLvbn2ehDJnSaUeuWghqcePRjXggUeGJc2SIuYzj2qj1nKyJKuSXnzqaA5BzZbfWMfQkVkSzrX5ytfzi(gBAva24S2v4vJc2miydb8tmcjv6AsTfVELyJZGnSW6kDGno7teY2nInLgBYPXgc4NyeskqDwHnSaahBwrUAvyZIIZXMnGneWpXiKuGInssXMwfGnAbbAuWMbbBybao2SIC1QWgVK50yZgWgk0GVbk2SrbBekDsTfVgVELydlRkjDa6viE9kXgNbByzOuGInSStQDJa24SlokVfVELyJZGnRiio3afBAH4a6qHGnEvGFvSbziyJsqe0LgBKDXRgflE9kXgNbBwrqCUbk2eNBiczJnYU4vxGgBqiteByqQHunkyZcvqIn50yJRgOydYqWgN9jcz7gT41ReBCgSHLHsbk2WcRbSzfVHOgB6bBGKIndc2WYodNolsn2i(UMKx62IxVsSXzWgw2jVbsduSXzZpdNolsNnSPhSXzt8DnPDfR1pdNolsNnSzHkGayJWGbV8YMdw8A86vInolUyW72afB2aYqaSXpXT0yZgCuP2InSmEpWO1ytoPZOsirexo2i(UMuJntYrXIxVsSr8DnP2YGa(jULgncx0RIxVsSr8DnP2YGa(jUL2j0OkUoIq2sxtIxVsSr8DnP2YGa(jUL2j0OImdfVELyZjfgAvtJnePOyZ2fbbOyJULwJnBazia24N4wASzdoQuJnssXggeWzymDxPdSP0ydDsWIxVsSr8DnP2YGa(jUL2j0OQtHHw10bDlTgVw8DnP2YGa(jUL2j0O6QHq1quHuIaAHf1QeIOdit2HbjWywae8AX31KAldc4N4wANqJkJPRjXRfFxtQTmiGFIBPDcnQrOL4qyOA0LwHcbTYclcKQbRxLmD5dnrsnYqIsxtAHu2CGIxJxVsSXzXfdE3gOydCdeuWMUIa20QaSr89qWMsJnYTuCzZblET47AsTtOr9wiLS5GcPeb0BUqHavspOWTWDb0TWHSTifr3HnFgQfszZbktMAgaNhAH4aATDZfkeOs6bfzh9YQXzAHdzBBIu8WGeiUvAHu2CGUeET47AsTtOr9wiLS5GcPeb0lKQR0raziHeIGU0kClCxaTYlRClCiBBcrqxAlKYMduMm9ZWPZI0Mqe0L2saHIctM(z40zrAtic6sBjquQuZElehqB7kcHEc0cyY0pdNolsBcrqxAlbIsLA2zjwxcVw8DnP2j0OElKs2CqHuIaAgZWR0raziHi0Ic3c3fqRClCiBlfItwElKYMd0R(z40zrAJqlXHWq1OlTLarPsTAzPRiUeuSuaP8vZUAy96YkFlKs2CWUqQUshbKHesic6sZKPFgoDwK2eIGU0wceLk1QvrwxcVw8DnP2j0OElKs2CqHuIaAgZWR0raziHnxOqGkPhu4w4Ua6BHuYMd2nxOqGkPhUUmIlbf1Ebo3zAHdzBrkIUdB(mulKYMd0vWLSUeET47AsTtOr9wiLS5GcPeb0mMHxPJaYqcakqydsuHBH7cOBHdzBPqCYYBHu2CGEv5w4q22nVsAaXLGIfszZb6v)mC6SiTakqyds0sGOuPwTl7WtTr5IxbxU0vexckwkGu(Qz)swXRfFxtQDcnQ3cPKnhuiLiGEHuDLocidjqfYQbnx0Qu4w4Ua6w4q2wQqwnO5IwLfszZb6vLVfsjBoyzmdVshbKHe2CHcbQKE4QY3cPKnhSmMHxPJaYqcrOLR(z40zrAPcz1GMlAvwxg41IVRj1oHg1BHuYMdkKseqVqQUshbKHeIteY2nQWTWDb0TWHSTXjcz7gTqkBoqVQ82fbXgNiKTB06YaVw8DnP2j0OslnXLrJxl(UMu7eAu9tQDJqikokpET47AsTtOr1lCEq8DnzGx6wHuIaA)mC6SivOqq7WtTeikvQrZkE9kXgX31KANqJkJYVAWLraHioIq2kuiOrCjOyPas5RMD0QX541IVRj1oHgvVW5bX31KbEPBfsjcOPcz1GMlAvkuiOBHdzBPcz1GMlAvwiLnhOxx(wiLS5GDHuDLocidjqfYQbnx0QyYKcBxeelviRg0CrRY6Yyj8AX31KANqJkXndIVRjd8s3kKseqtH4KLxHcbDlCiBlfItwElKYMdu8AX31KANqJkXndIVRjd8s3kKseqNdjkC8A8AX31KARFgoDwKOJqlXHWq1OlTcfcALxUfoKTLcXjlVfszZbktM3cPKnhSmMHxPJaYqcrOfMmVfsjBoyxivxPJaYqcjebDPxIjZUIqONaTa1EPZXRfFxtQT(z40zr6eAuJqlXHWq1OlTcfc6w4q2wkeNS8wiLnhOxxwzHfbs1G1RsMU8HMiPgzirPRjTqkBoqzYCz)mC6SiTakqyds0sGOuPM9lz96YkFlKs2CWU5cfcuj9atM(z40zrA3CHcbQKEWsGOuPMDhEQnkx8slTeET47AsT1pdNolsNqJAcrqxAfke0ePOb4gY2kuQ2cxCPB9vkSDrqSjebDPT0zrEDzX31neGeIfOzNc6Ia0qlehqRzYKifna3q2wHs12kzNLyDj8AX31KARFgoDwKoHg1eIGU0kuiOvMifna3q2wHs1w4IlDRXRfFxtQT(z40zr6eAuzmDnPcfc6TlcIncTehcdvJU0wceLk1SFPZzYSRie6jqlqTSeR41IVRj1w)mC6SiDcnQUAiuneviLiG2HWbVW5arh2ZKkuiOvUfoKTfb4HTqiIdWcPS5aLjt)mC6SiTiapSfcrCawciuuWRfFxtQT(z40zr6eAuD1qOAiQaGGa(oKseq7rXZNMmz5dBUOBfke0BxeeBeAjoegQgDPTUmUUDrqSrioeucdsG76lAGsajQT0zrEDzLVfsjBoy3CHcbQKEGjtL9ZWPZI0U5cfcuj9GLacfLLWRfFxtQT(z40zr6eAuD1qOAiQqkraTOvDljOdeHfhsWpeHRqHGMcBxeelryXHe8dr4bkSDrqS0zrYK5Yuy7IGy9tsD9DDdHkxnqHTlcI1LbtMBxeeBeAjoegQgDPTeikvQz)swx6AlehqBvbcVvzz4B1QgfzYSRie6jqlqTxYkET47AsT1pdNolsNqJQRgcvdrfsjcOfwuRsiIoGmzhgKaJzbquOqq7NHtNfPncTehcdvJU0wceLk1QvrwzY0pdNolsBeAjoegQgDPTeikvQzNLyfVELydleGiU8gBqeoFl(vXgKHGnUAzZbSPAiQT41IVRj1w)mC6SiDcnQUAiune1kuiO3Uii2i0sCimun6sBDzGxl(UMuB9ZWPZI0j0O6fopi(UMmWlDRqkranO1q6bnEnET47AsTLkKvdAUOvHMkKvdAUOvPqHGgXLGc7OViwVUSY3cPKnhSBUqHavspWKPY(z40zrA3CHcbQKEWsaHIYs41IVRj1wQqwnO5IwLtOrvYSuvCPRjvOqqtHTlcILkKvdAUOvzDzGxl(UMuBPcz1GMlAvoHgvVkz0bDtQvbfke0uy7IGyPcz1GMlAvwxg4141IVRj1wkeNS8OPG0Qc6faWqHcb9TqkzZb7MluiqL0d41IVRj1wkeNS8oHgvafiSbjQqHGMifna3q2wHs1wxgmzsKIgGBiBRqPABLSFPZXRfFxtQTuioz5DcnQiapSfcrCakuiOxEzL9ZWPZI0cOaHnirRldMm3Uii2i0sCimun6sBDzS0vIu0aCdzBfkvBRKD1W6smzk(UUHaKqSan7uqxeGgAH4aAnET47AsTLcXjlVtOrDZfkeOs6bfke03cPKnhSBUqHavspCvz)mC6SiTrOL4qyOA0L2saHIY1L9ZWPZI0cOaHnirlbIsLA2x25oJWIaPAWsG7HFxPJWMluqBjsU6kqnlXK5YePOb4gY2kuQ2wj7IVRjTBUqHavspy9ZWPZI8krkAaUHSTcLQTvQ2lD(slHxl(UMuBPqCYY7eAuRyC4sxtgexIGxl(UMuBPqCYY7eAuLmlvfx6Asfke0kFlKs2CWYygELocidjS5cfcuj9aET47AsTLcXjlVtOrfb4BUqbfke0iUeuSuaP8vZo6lKv8AX31KAlfItwENqJQxLm6GUj1QGcfcALVfsjBoyzmdVshbKHe2CHcbQKE4QY3cPKnhSmMHxPJaYqcakqydseVw8DnP2sH4KL3j0OIa8aXvRsHcbDlCiBlfItg2CHcAlKYMd0Rk7NHtNfPfqbcBqIwciuuUUSxLqCaA0xYK5YePOb4gY2gNBiczBRKDfz9krkAaUHSTcLQTvYUISU0s41IVRj1wkeNS8oHgvkeNuh2vd41IVRj1wkeNS8oHg1wfzweCWL6guOqqVDrqSJBhgKarshG1LbET47AsTLcXjlVtOrfb4bIRwLcfc64CdriBlT0TKEGDfDotMBxee742HbjqK0byDzGxl(UMuBPqCYY7eAuVH0bG4YdeOjG0kuiOJZneHST0s3s6b2v0541IVRj1wkeNS8oHg1wfzweCWL6guOqq3chY2sH4KHnxOG2cPS5afVgVw8DnP2cAnKEqJ2pPhYMinqdiCjc41IVRj1wqRH0dANqJ6MpdnmiHwfeGeIOOqHGE7IGyJqlXHWq1OlT1LbtMDfHqpbAbQfTISIxl(UMuBbTgspODcnQoCfcTKmmibHfbY0QuOqqVDrqSrOL4qyOA0L26YGjZUIqONaTa1IwnSIxl(UMuBbTgspODcnQiJ3vd0GWIaPAiSbjQqHGwZa48qlehqRTBUqHavspOi7OVKjtIu0aCdzBfkvBRKDwIv8AX31KAlO1q6bTtOrLHlPqqPshHnx0TcfcAndGZdTqCaT2U5cfcuj9GISJ(sMmjsrdWnKTvOuTTs2zjwXRfFxtQTGwdPh0oHg1wfeCZ94M0aYq8Gcfc6TlcILa(v5GwhqgIhSUmyYC7IGyjGFvoO1bKH4HGFCZgiwDl(vvRISIxl(UMuBbTgspODcnQKIbdoeQmOziEaVw8DnP2cAnKEq7eAuxmeo9gQmqa9Ks6bfke0BxeelVqGnFgQv3IFv1Qg8AX31KAlO1q6bTtOrncXHGsyqcCxFrducirTcfcAexckQ9cz962fbXgHwIdHHQrxARld8A8AX31KABoKOWrFdPdaXLhiqtaPvOqq3chY2gNiKTB0cPS5a962fbXYGamecqT0zrETRiWUI41IVRj12CirH7eAuraEG4QvPqHGE5BHuYMd2fs1v6iGmKqCIq2UrMmBHdzBraEik6giOyHu2CGU01L9QeIdqJ(sMmxMifna3q224CdriBBLSRiRxjsrdWnKTvOuTTs2vK1LwcVw8DnP2MdjkCNqJkcWdBHqehGcfcALVfsjBoyxivxPJaYqcXjcz7gVUS476gcqcXc0StbDraAOfIdO1mzsKIgGBiBRqPABLSRgwxcVw8DnP2MdjkCNqJkfKwvqVaagkuiOVfsjBoy3CHcbQKEaVw8DnP2MdjkCNqJAfJdx6AYG4se8AX31KABoKOWDcnQakqydsuHcbT476gcqcXc0SR41LvMifna3q2wHs1w4IlDRzYKifna3q2wHs1wxglDv5BHuYMd2fs1v6iGmKqCIq2Ur8AX31KABoKOWDcnQBUqHavspOqHG(wiLS5GDZfkeOs6b8AX31KABoKOWDcnQiaFZfkOqHGgXLGILciLVA2rFHSIxl(UMuBZHefUtOrfqbcBqIkuiOvUfoKTDZRKgqCjOyHu2CGEv5BHuYMd2fs1v6iGmKaviRg0CrR6krkAaUHSTcLQTvYU47AslGce2GeT(z40zrIxl(UMuBZHefUtOrvYSuvCPRjvOqqVClCiBlfItg2CHcAlKYMduMmv(wiLS5GDHuDLocidjeNiKTBKjtexckwkGu(QvRAyLjZTlcIncTehcdvJU0wceLk1Q15lDv5BHuYMdwgZWR0raziHnxOqGkPhUQ8TqkzZb7cP6kDeqgsGkKvdAUOvHxl(UMuBZHefUtOr1RsgDq3KAvqHcb9YTWHSTuiozyZfkOTqkBoqzYu5BHuYMd2fs1v6iGmKqCIq2UrMmrCjOyPas5RwTQH1LUQ8TqkzZblJz4v6iGmKqeA5QY3cPKnhSmMHxPJaYqcBUqHavspCv5BHuYMd2fs1v6iGmKaviRg0CrRcVw8DnP2MdjkCNqJkGce2GevOqq3chY2U5vsdiUeuSqkBoqVsKIgGBiBRqPABLSl(UM0cOaHnirRFgoDwK41IVRj12CirH7eAuPqCsDyxnGxl(UMuBZHefUtOrfb4bIRwLcfcALBHdzBJteY2nAHu2CGELifna3q224CdriBBLS7vjehGEfOiRxBHdzBPqCYWMluqBHu2CGIxl(UMuBZHefUtOrfb4BUqbfke0X5gIq2wAPBj9a7k6CMm3Uii2XTddsGiPdW6YaVw8DnP2MdjkCNqJkcWdexTkfke0X5gIq2wAPBj9a7k6CMmxE7IGyh3omibIKoaRlJRk3chY2gNiKTB0cPS5aDj8AX31KABoKOWDcnQ3q6aqC5bc0eqAfke0X5gIq2wAPBj9a7k6C8AX31KABoKOWDcnQTkYSi4Gl1nOqHGUfoKTLcXjdBUqbTfszZb63F)pa]] )


end
