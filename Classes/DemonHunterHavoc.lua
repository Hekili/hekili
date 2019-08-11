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


    spec:RegisterPack( "Havoc", 20190803, [[dOKgebqisulIkQKhPG0MujnkfuNsHyvurv9kQiZIeClskSlk9liPHrcDmusltLONPGyAKu01OIY2qjQVPsqJtLqDouI06OIQ8oQOImpskDpi1(qP6GOerlKKQhIseMikb5IurfSruc4JurfAKOeOtQsGALku3KkQu7KezPQeWtvXurPCvucQVQsGySQeiTxv9xbdMIdtSyf9yQAYiDzWMH4ZuHrtsoTKxRqA2O62cTBr)wPHJchNkQOwoINtQPl11PsBxL67kW4vjKZdjwpkHMpkA)q9Z6Z2FOsdVsxQiRSufVyfvtlRotXlhYL)PrHb8hgIFuXb8NuIWFybL71)hgck8vOpB)rVUep8hvDZq78qfvhvRYDA9BevDfD5sxB6jcsJQUIEu)Z0T49fC(Z)qLgELUurwzPkEXkQMwwDMIxE5f)hndW)k5Sl8c)JQIsH8N)HcA)Fgk2Wck3RhByHG4MydlOB2abpEOyJQUzODEOIQJQv5oT(nIQUIUCPRn9ebPrvxrpQ4XdfByjDD4QBSrnvaBUurwzPyJAGnSQMopNPiEmE8qXMlicjR0H25HhpuSrnWgwyDLoWgwiiUj2OoxOGgBIYOGgBIRUXgwaxckyJdibI01MyddxcWrbBUak5CeBOK6gsSrsk24MmiaT8Tm5GcyZavLxf2mO4CSPImeFJnTkaBCo7k8QrbBweSHa(ngHKkDTP2IhpuSrnWgwyDLoWgN7ncz7gXMsJn52ydb8BmcjfOoNWgwaGJnxaxTkSzqX5yZeWgc43yeskqXgjPytRcWgTGankyZIGnSaahBUaUAvyJxYCBSzcydfAW3afBMOGncLUP2(hEPB9Z2FYLef(Z2ReRpB)bszYb6R(F8KQbsj)PfoKTnUriB3OfszYbk2CfBMUiiwgeGHqaQLUdsS5k20veWg2Xgw)J47AZ)CdPdaXLhiqtaP)(v6YNT)aPm5a9v)pEs1aPK)mm2ClKsMCWoqQUshbKLeIBeY2nInmzInTWHSTiapefDdeuSqktoqXMrWMRyZWyJxLqCaASbn2Cj2WKj2mm2qKIgGBiBBCVHiKTTsSHDSHvfXMRydrkAaUHSTcLQTvInSJnSQi2mc2mYFeFxB(heGhiUAvF)knKNT)aPm5a9v)pEs1aPK)Om2ClKsMCWoqQUshbKLeIBeY2nInxXMHXgX31neGeIfOXg2XgkOlcqdTqCaTgByYeBisrdWnKTvOuTTsSHDSzikInJ8hX31M)bb4HPqiId47xj18z7pqktoqF1)JNunqk5p3cPKjhStUqHavsp8hX31M)HcsRkOhaaJVFLC2Z2FeFxB(NkgxU01MbXLi)bszYb6R(3VsS8Z2FGuMCG(Q)hpPAGuYFeFx3qasiwGgByhByfBUIndJnkJnePOb4gY2kuQ2cxuPBn2WKj2qKIgGBiBRqPARldSzeS5k2Om2ClKsMCWoqQUshbKLeIBeY2n(hX31M)bqbctqIF)kDHpB)bszYb6R(F8KQbsj)5wiLm5GDYfkeOs6H)i(U28ptUqHavsp89R0f)S9hiLjhOV6)XtQgiL8hexckwkGu(QXg2rJnQPI)r8DT5Fqa(Klu47xjw6Z2FGuMCG(Q)hpPAGuYFugBAHdzBN8kPbexckwiLjhOyZvSrzS5wiLm5GDGuDLociljqfYObnx0QWMRydrkAaUHSTcLQTvInSJnIVRnTakqycs063Lt3b5FeFxB(hafimbj(9ReRk(S9hiLjhOV6)XtQgiL8NHXMw4q2wke3mm5cf0wiLjhOydtMyJYyZTqkzYb7aP6kDeqwsiUriB3i2WKj2G4sqXsbKYxn2OwSzikInmzIntxeeBeAjUegQwDPTeikvQXg1InodBgbBUInkJn3cPKjhSm2LxPJaYsctUqHavspGnxXgLXMBHuYKd2bs1v6iGSKaviJg0CrR6pIVRn)JKzPQ4sxB(9ReRS(S9hiLjhOV6)XtQgiL8NHXMw4q2wke3mm5cf0wiLjhOydtMyJYyZTqkzYb7aP6kDeqwsiUriB3i2WKj2G4sqXsbKYxn2OwSzikInJGnxXgLXMBHuYKdwg7YR0razjHi0c2CfBugBUfsjtoyzSlVshbKLeMCHcbQKEaBUInkJn3cPKjhSdKQR0razjbQqgnO5Iw1FeFxB(hVkz1bDtQrHVFLy9YNT)aPm5a9v)pEs1aPK)0chY2o5vsdiUeuSqktoqXMRydrkAaUHSTcLQTvInSJnIVRnTakqycs063Lt3b5FeFxB(hafimbj(9ReRd5z7pIVRn)dfIBQdZQH)aPm5a9v)7xjwvZNT)aPm5a9v)pEs1aPK)Om20chY2g3iKTB0cPm5afBUInePOb4gY2g3BiczBReByhB8QeIdqJnoFSHvfXMRytlCiBlfIBgMCHcAlKYKd0)i(U28piapqC1Q((vIvN9S9hiLjhOV6)XtQgiL8N4EdriBlT0TKEaByhBy1zydtMyZ0fbXUUDyrcejDawxg)r8DT5Fqa(Klu47xjwz5NT)aPm5a9v)pEs1aPK)e3BiczBPLUL0dyd7ydRodByYeBggBMUii21TdlsGiPdW6YaBUInkJnTWHSTXncz7gTqktoqXMr(J47AZ)Ga8aXvR67xjwVWNT)aPm5a9v)pEs1aPK)e3BiczBPLUL0dyd7ydRo7pIVRn)ZnKoaexEGanbK(7xjwV4NT)aPm5a9v)pEs1aPK)0chY2sH4MHjxOG2cPm5a9pIVRn)tRISdco4sDdF)9FaTgspOF2ELy9z7pIVRn)JFtpKnrAGgq4se(dKYKd0x9VFLU8z7pqktoqF1)JNunqk5ptxeeBeAjUegQwDPTUmWgMmXMUIqO3aTaSrTOXgwv8pIVRn)ZKVlnSiHwfeGeIO89R0qE2(dKYKd0x9)4jvdKs(Z0fbXgHwIlHHQvxARldSHjtSPRie6nqlaBulASzik(hX31M)XHRqOLKHfjiSiq2w13VsQ5Z2FGuMCG(Q)hpPAGuYF0maop0cXb0A7KluiqL0dSInSJgBUeByYeBisrdWnKTvOuTTsSHDSHLv8pIVRn)dY6D1aniSiqQgctqIF)k5SNT)aPm5a9v)pEs1aPK)OzaCEOfIdO12jxOqGkPhyfByhn2Cj2WKj2qKIgGBiBRqPABLyd7ydlR4FeFxB(hgUKcbLkDeMCr3F)kXYpB)bszYb6R(F8KQbsj)z6IGyjGFuoO1bKL4bRldSHjtSz6IGyjGFuoO1bKL4HGFDZgiwDl(rXg1InSQ4FeFxB(NwfeCZ56M0aYs8W3Vsx4Z2FeFxB(hsXGbhcvg0mep8hiLjhOV6F)kDXpB)bszYb6R(F8KQbsj)z6IGy5fcm57sT6w8JInQfBgYFeFxB(NblHtVHkdeqVPKE47xjw6Z2FGuMCG(Q)hpPAGuYFqCjOGnQfButfXMRyZ0fbXgHwIlHHQvxARlJ)i(U28priUeuclsG76lAGsajQ)(7)qbeXL3pBVsS(S9hiLjhOV6)zz8hn0)r8DT5FUfsjto8NBH7c)PfoKTfPi6om57sTqktoqXgMmXgndGZdTqCaT2o5cfcuj9aRyd7OXMHXMHGnQb20chY22eP4HfjqCR0cPm5afBg5p3cjKse(ZKluiqL0dF)kD5Z2FGuMCG(Q)NLXF0q)hX31M)5wiLm5WFUfUl8hLXMHXgLXMw4q22eIGU0wiLjhOydtMyJFxoDhK2eIGU0wciuuWgMmXg)UC6oiTjebDPTeikvQXg2XMwioG22vec9gOfGnmzIn(D50DqAtic6sBjquQuJnSJnSSIyZi)5wiHuIWFgivxPJaYscjebDP)(vAipB)bszYb6R(Fwg)rd9FeFxB(NBHuYKd)5w4UWFugBAHdzBPqCZYBHuMCGInxXg)UC6oiTrOL4syOA1L2sGOuPgBul2WYyZvSbXLGILciLVASHDSzikInxXMHXgLXMBHuYKd2bs1v6iGSKqcrqxASHjtSXVlNUdsBcrqxAlbIsLASrTydRkInJ8NBHesjc)HXU8kDeqwsicT89RKA(S9hiLjhOV6)zz8hn0)r8DT5FUfsjto8NBH7c)5wiLm5GDYfkeOs6bS5k2mm2G4sqbBul2CHodBudSPfoKTfPi6om57sTqktoqXgNp2CPIyZi)5wiHuIWFySlVshbKLeMCHcbQKE47xjN9S9hiLjhOV6)zz8hn0)r8DT5FUfsjto8NBH7c)PfoKTLcXnlVfszYbk2CfBugBAHdzBN8kPbexckwiLjhOyZvSXVlNUdslGceMGeTeikvQXg1IndJno8uBuUiSX5JnxInJGnxXgexckwkGu(QXg2XMlv8p3cjKse(dJD5v6iGSKaGceMGe)(vILF2(dKYKd0x9)Sm(Jg6)i(U28p3cPKjh(ZTWDH)0chY2sfYObnx0QSqktoqXMRyJYyZTqkzYblJD5v6iGSKWKluiqL0dyZvSrzS5wiLm5GLXU8kDeqwsicTGnxXg)UC6oiTuHmAqZfTkRlJ)ClKqkr4pdKQR0razjbQqgnO5Iw13Vsx4Z2FGuMCG(Q)NLXF0q)hX31M)5wiLm5WFUfUl8Nw4q224gHSDJwiLjhOyZvSrzSz6IGyJBeY2nADz8NBHesjc)zGuDLocilje3iKTB87xPl(z7pIVRn)dT0exg9FGuMCG(Q)9Rel9z7pIVRn)JFtTBecrXr5)dKYKd0x9VFLyvXNT)aPm5a9v)pEs1aPK)4WtTeikvQXg0yJI)r8DT5F8cNheFxBg4LU)dV0DiLi8h)UC6oi)(vIvwF2(dKYKd0x9)4jvdKs(tlCiBlviJg0CrRYcPm5afBUIndJn3cPKjhSdKQR0razjbQqgnO5Iwf2WKj2qHPlcILkKrdAUOvzDzGnJ8hX31M)XlCEq8DTzGx6(p8s3HuIWFOcz0GMlAvF)kX6LpB)bszYb6R(F8KQbsj)PfoKTLcXnlVfszYb6FeFxB(hIBgeFxBg4LU)dV0DiLi8hke3S8F)kX6qE2(dKYKd0x9)i(U28pe3mi(U2mWlD)hEP7qkr4p5sIc)7V)ddc434u6NTxjwF2(dKYKd0x9)Kse(JWIAvcr0bKn7WIeySdaYFeFxB(hHf1QeIOdiB2HfjWyhaKVFLU8z7pIVRn)dJTRn)dKYKd0x9VFLgYZ2FGuMCG(Q)hpPAGuYFugBeweivdwVkz7YhAIKAKLeLU20cPm5a9pIVRn)teAjUegQwDP)(7)qH4ML)z7vI1NT)aPm5a9v)pEs1aPK)ClKsMCWo5cfcuj9WFeFxB(hkiTQGEaam((v6YNT)aPm5a9v)pEs1aPK)qKIgGBiBRqPARldSHjtSHifna3q2wHs12kXg2XMlD2FeFxB(hafimbj(9R0qE2(dKYKd0x9)4jvdKs(ZWyZWyJYyJFxoDhKwafimbjADzGnmzIntxeeBeAjUegQwDPTUmWMrWMRydrkAaUHSTcLQTvInSJndrrSzeSHjtSr8DDdbiHybASHDSHc6Ia0qlehqR)J47AZ)Ga8WuieXb89RKA(S9hiLjhOV6)XtQgiL8NBHuYKd2jxOqGkPhWMRyJYyJFxoDhK2i0sCjmuT6sBjGqrbBUIndJn(D50DqAbuGWeKOLarPsn2Wo2mm24mSrnWgHfbs1GLa3l)UshHjxOG2sKCuSX5JndbBgbByYeBggBisrdWnKTvOuTTsSHDSr8DTPDYfkeOs6bRFxoDhKyZvSHifna3q2wHs12kXg1Inx6mSzeSzK)i(U28ptUqHavsp89RKZE2(J47AZ)uX4YLU2miUe5pqktoqF1)(vILF2(dKYKd0x9)4jvdKs(JYyZTqkzYblJD5v6iGSKWKluiqL0d)r8DT5FKmlvfx6AZVFLUWNT)aPm5a9v)pEs1aPK)G4sqXsbKYxn2WoASrnv8pIVRn)dcWNCHcF)kDXpB)bszYb6R(F8KQbsj)rzS5wiLm5GLXU8kDeqwsyYfkeOs6bS5k2Om2ClKsMCWYyxELociljaOaHjiX)i(U28pEvYQd6MuJcF)kXsF2(dKYKd0x9)4jvdKs(tlCiBlfIBgMCHcAlKYKduS5k2Om243Lt3bPfqbctqIwciuuWMRyZWyJxLqCaASbn2Cj2WKj2mm2qKIgGBiBBCVHiKTTsSHDSHvfXMRydrkAaUHSTcLQTvInSJnSQi2mc2mYFeFxB(heGhiUAvF)kXQIpB)r8DT5FOqCtDywn8hiLjhOV6F)kXkRpB)bszYb6R(F8KQbsj)z6IGyx3oSibIKoaRlJ)i(U28pTkYoi4Gl1n89ReRx(S9hiLjhOV6)XtQgiL8N4EdriBlT0TKEaByhBy1zydtMyZ0fbXUUDyrcejDawxg)r8DT5FqaEG4Qv99ReRd5z7pqktoqF1)JNunqk5pX9gIq2wAPBj9a2Wo2WQZ(J47AZ)CdPdaXLhiqtaP)(vIv18z7pqktoqF1)JNunqk5pTWHSTuiUzyYfkOTqktoq)J47AZ)0Qi7GGdUu3W3F)h)UC6oiF2ELy9z7pqktoqF1)JNunqk5pkJndJnTWHSTuiUz5TqktoqXgMmXMBHuYKdwg7YR0razjHi0c2WKj2ClKsMCWoqQUshbKLesic6sJnJGnmzInDfHqVbAbyJAXMlD2FeFxB(Ni0sCjmuT6s)9R0LpB)bszYb6R(F8KQbsj)PfoKTLcXnlVfszYbk2CfBggBugBeweivdwVkz7YhAIKAKLeLU20cPm5afByYeBggB87YP7G0cOaHjirlbIsLASHDS5sfXMRyZWyJYyZTqkzYb7KluiqL0dydtMyJFxoDhK2jxOqGkPhSeikvQXg2XghEQnkxe2mc2mc2mYFeFxB(Ni0sCjmuT6s)9R0qE2(dKYKd0x9)4jvdKs(drkAaUHSTcLQTWfv6wJnxXgkmDrqSjebDPT0DqInxXMHXgX31neGeIfOXg2XgkOlcqdTqCaTgByYeBisrdWnKTvOuTTsSHDSHLveBg5pIVRn)tcrqx6VFLuZNT)aPm5a9v)pEs1aPK)Om2qKIgGBiBRqPAlCrLU1)r8DT5Fsic6s)9RKZE2(dKYKd0x9)4jvdKs(Z0fbXgHwIlHHQvxAlbIsLASHDS5sNHnmzInTqCaTTRie6nqlaBul2WYk(hX31M)HX21MF)kXYpB)bszYb6R(FeFxB(hhch8cNdeDyUB(hpPAGuYFugBAHdzBraEykeI4aSqktoqXgMmXg)UC6oiTiapmfcrCawciuu(tkr4poeo4fohi6WC387xPl8z7pqktoqF1)J47AZ)4rXZ3MSz5dtUO7)4jvdKs(Z0fbXgHwIlHHQvxARldS5k2mDrqSriUeuclsG76lAGsajQT0DqInxXMHXgLXMBHuYKd2jxOqGkPhWgMmXgLXg)UC6oiTtUqHavspyjGqrbBg5pacc47qkr4pEu88TjBw(WKl6(7xPl(z7pqktoqF1)J47AZ)iAv3sc6aryXLe8lr4)XtQgiL8hkmDrqSeHfxsWVeHhOW0fbXs3bj2WKj2mm2qHPlcI1Vj1131neQC0afMUiiwxgydtMyZ0fbXgHwIlHHQvxAlbIsLASHDS5sfXMrWMRytlehqBvbcVvzz4BSrTyZqyfByYeB6kcHEd0cWg1InxQ4Fsjc)r0QULe0bIWIlj4xIW)(vIL(S9hiLjhOV6)r8DT5FewuRsiIoGSzhwKaJDaq(JNunqk5p(D50DqAJqlXLWq1QlTLarPsn2OwSHvfXgMmXg)UC6oiTrOL4syOA1L2sGOuPgByhByzf)tkr4pclQvjerhq2SdlsGXoaiF)kXQIpB)bszYb6R(F8KQbsj)z6IGyJqlXLWq1QlT1LXFeFxB(hxneQgI6VFLyL1NT)aPm5a9v)pIVRn)Jx48G47AZaV09F4LUdPeH)aAnKEq)93)HkKrdAUOv9S9kX6Z2FGuMCG(Q)hpPAGuYFqCjOGnSJgBUyfXMRyZWyJYyZTqkzYb7KluiqL0dydtMyJYyJFxoDhK2jxOqGkPhSeqOOGnJ8hX31M)HkKrdAUOv99R0LpB)bszYb6R(F8KQbsj)HctxeelviJg0CrRY6Y4pIVRn)JKzPQ4sxB(9R0qE2(dKYKd0x9)4jvdKs(dfMUiiwQqgnO5IwL1LXFeFxB(hVkz1bDtQrHV)(7)CdeDT5R0LkYklvXl8Yl(pdeswPd9FUGJmwsduS5cXgX31MydV0T2Ih)hXTvTK)CQOlx6AtwcIG0)Hbzrko8NHInSGY96XgwiiUj2Wc6MnqWJhk2OQBgANhQO6OAvUtRFJOQROlx6AtprqAu1v0JkE8qXgwsxhU6gButfWMlvKvwk2OgydRQPZZzkIhJhpuS5cIqYkDODE4XdfBudSHfwxPdSHfcIBInQZfkOXMOmkOXM4QBSHfWLGc24asGiDTj2WWLaCuWMlGsohXgkPUHeBKKInUjdcqlFltoOa2mqv5vHndkohBQidX3ytRcWgNZUcVAuWMfbBiGFJriPsxBQT4XdfBudSHfwxPdSX5EJq2UrSP0ytUn2qa)gJqsbQZjSHfa4yZfWvRcBguCo2mbSHa(ngHKcuSrsk20QaSrliqJc2SiydlaWXMlGRwf24Lm3gBMa2qHg8nqXMjkyJqPBQT4X4XdfByjujPdq78WJhk2OgydljLcuSHLytTBeWgNBXr5T4XdfBudS5caX9gOytlehqhkeSXRc8JInilbBucIGU0yJmlE1OyXJhk2OgyZfaI7nqXM4EdriBSrMfV6c0ydczJyddsTKQrbBgOcsSj3gBC1afBqwc24CVriB3OfpEOyJAGnSKukqXgwynGnxWne1ytVydKuSzrWgwID50DqQXgX31M8s3w84HInQb2WsS5nqAGInox(D50Dq6CHn9InoxIVRnTxqT(D50Dq6CHndubeaBegm4LxMCWIhJhpuSX5WfbE3gOyZeqwcGn(noLgBMGJk1wSHL07bgTgBYnvdvcjI4YXgX31MASztokw84HInIVRn1wgeWVXP0Or4IEu84HInIVRn1wgeWVXP0oHgvX1reYw6At84HInIVRn1wgeWVXP0oHgvKDP4XdfBoPWqRABSHiffBMUiiafB0T0ASzcilbWg)gNsJntWrLASrsk2WGaQbJT7kDGnLgBOBcw84HInIVRn1wgeWVXP0oHgvDkm0Q2oOBP14XIVRn1wgeWVXP0oHgvxneQgIkKseqlSOwLqeDazZoSibg7aGGhl(U2uBzqa)gNs7eAuzSDTjES47AtTLbb8BCkTtOrncTexcdvRU0kuiOvwyrGuny9QKTlFOjsQrwsu6AtlKYKdu8y84HInohUiW72afBGBGGc20veWMwfGnIVxc2uASrULIltoyXJfFxBQDcnQ3cPKjhuiLiGEYfkeOs6bfUfUlGUfoKTfPi6om57sTqktoqzYuZa48qlehqRTtUqHavspWk7OhEiQrlCiBBtKIhwKaXTslKYKd0rWJfFxBQDcnQ3cPKjhuiLiGEGuDLociljKqe0LwHBH7cOvEyLBHdzBtic6sBHuMCGYKPFxoDhK2eIGU0wciuuyY0VlNUdsBcrqxAlbIsLA2BH4aABxri0BGwatM(D50DqAtic6sBjquQuZolR4i4XIVRn1oHg1BHuYKdkKseqZyxELociljeHwu4w4UaALBHdzBPqCZYBHuMCGE1VlNUdsBeAjUegQwDPTeikvQvllFfXLGILciLVA2hIIxhw5BHuYKd2bs1v6iGSKqcrqxAMm97YP7G0Mqe0L2sGOuPwTSQ4i4XIVRn1oHg1BHuYKdkKseqZyxELociljm5cfcuj9Gc3c3fqFlKsMCWo5cfcuj9W1HrCjOO2l0zQrlCiBlsr0DyY3LAHuMCG68VuXrWJfFxBQDcnQ3cPKjhuiLiGMXU8kDeqwsaqbctqIkClCxaDlCiBlfIBwElKYKd0Rk3chY2o5vsdiUeuSqktoqV63Lt3bPfqbctqIwceLk1QDyhEQnkxKZ)YrUI4sqXsbKYxn7xQiES47AtTtOr9wiLm5GcPeb0dKQR0razjbQqgnO5IwLc3c3fq3chY2sfYObnx0QSqktoqVQ8TqkzYblJD5v6iGSKWKluiqL0dxv(wiLm5GLXU8kDeqwsicTC1VlNUdslviJg0CrRY6Yapw8DTP2j0OElKsMCqHuIa6bs1v6iGSKqCJq2UrfUfUlGUfoKTnUriB3OfszYb6vLNUii24gHSDJwxg4XIVRn1oHgvAPjUmA8yX31MANqJQFtTBecrXr5XJfFxBQDcnQEHZdIVRnd8s3kKseq73Lt3bPcfcAhEQLarPsnAfXJhk2i(U2u7eAuzu(rdUmcieXreYwHcbnIlbflfqkF1SJEiodpw8DTP2j0O6fopi(U2mWlDRqkranviJg0CrRsHcbDlCiBlviJg0CrRYcPm5a96W3cPKjhSdKQR0razjbQqgnO5IwftMuy6IGyPcz0GMlAvwxgJGhl(U2u7eAujUzq8DTzGx6wHuIaAke3S8kuiOBHdzBPqCZYBHuMCGIhl(U2u7eAujUzq8DTzGx6wHuIa6CjrHJhJhl(U2uB97YP7GeDeAjUegQwDPvOqqR8WTWHSTuiUz5TqktoqzY8wiLm5GLXU8kDeqwsicTWK5TqkzYb7aP6kDeqwsiHiOl9imz2vec9gOfO2lDgES47AtT1VlNUdsNqJAeAjUegQwDPvOqq3chY2sH4ML3cPm5a96WklSiqQgSEvY2Lp0ej1iljkDTPfszYbktMd73Lt3bPfqbctqIwceLk1SFPIxhw5BHuYKd2jxOqGkPhyY0VlNUds7KluiqL0dwceLk1S7WtTr5IgzKrWJfFxBQT(D50Dq6eAutic6sRqHGMifna3q2wHs1w4IkDRVsHPlcInHiOlTLUdYRdl(UUHaKqSan7uqxeGgAH4aAntMePOb4gY2kuQ2wj7SSIJGhl(U2uB97YP7G0j0OMqe0LwHcbTYePOb4gY2kuQ2cxuPBnES47AtT1VlNUdsNqJkJTRnvOqqpDrqSrOL4syOA1L2sGOuPM9lDgtMTqCaTTRie6nqlqTSSI4XIVRn1w)UC6oiDcnQUAiuneviLiG2HWbVW5arhM7MkuiOvUfoKTfb4HPqiIdWcPm5aLjt)UC6oiTiapmfcrCawciuuWJfFxBQT(D50Dq6eAuD1qOAiQaGGa(oKseq7rXZ3MSz5dtUOBfke0txeeBeAjUegQwDPTUmUoDrqSriUeuclsG76lAGsajQT0DqEDyLVfsjtoyNCHcbQKEGjtL97YP7G0o5cfcuj9GLacfLrWJfFxBQT(D50Dq6eAuD1qOAiQqkraTOvDljOdeHfxsWVeHRqHGMctxeelryXLe8lr4bkmDrqS0DqYK5Wuy6IGy9BsD9DDdHkhnqHPlcI1LbtMtxeeBeAjUegQwDPTeikvQz)sfh5AlehqBvbcVvzz4B1oewzYSRie6nqlqTxQiES47AtT1VlNUdsNqJQRgcvdrfsjcOfwuRsiIoGSzhwKaJDaquOqq73Lt3bPncTexcdvRU0wceLk1QLvfzY0VlNUdsBeAjUegQwDPTeikvQzNLvepEOydleGiU8gBqeoFk(rXgKLGnUAzYbSPAiQT4XIVRn1w)UC6oiDcnQUAiune1kuiONUii2i0sCjmuT6sBDzGhl(U2uB97YP7G0j0O6fopi(U2mWlDRqkranO1q6bnEmES47AtTLkKrdAUOvHMkKrdAUOvPqHGgXLGc7OVyfVoSY3cPKjhStUqHavspWKPY(D50DqANCHcbQKEWsaHIYi4XIVRn1wQqgnO5IwLtOrvYSuvCPRnvOqqtHPlcILkKrdAUOvzDzGhl(U2uBPcz0GMlAvoHgvVkz1bDtQrbfke0uy6IGyPcz0GMlAvwxg4X4XIVRn1wke3S8OPG0Qc6baWqHcb9TqkzYb7KluiqL0d4XIVRn1wke3S8oHgvafimbjQqHGMifna3q2wHs1wxgmzsKIgGBiBRqPABLSFPZWJfFxBQTuiUz5DcnQiapmfcrCakuiOhEyL97YP7G0cOaHjirRldMmNUii2i0sCjmuT6sBDzmYvIu0aCdzBfkvBRK9HO4imzk(UUHaKqSan7uqxeGgAH4aAnES47AtTLcXnlVtOrDYfkeOs6bfke03cPKjhStUqHavspCvz)UC6oiTrOL4syOA1L2saHIY1H97YP7G0cOaHjirlbIsLA2h2zQHWIaPAWsG7LFxPJWKluqBjsoQZFiJWK5WePOb4gY2kuQ2wj7IVRnTtUqHavspy97YP7G8krkAaUHSTcLQTvQ2lD2iJGhl(U2uBPqCZY7eAuRyC5sxBgexIGhl(U2uBPqCZY7eAuLmlvfx6Atfke0kFlKsMCWYyxELociljm5cfcuj9aES47AtTLcXnlVtOrfb4tUqbfke0iUeuSuaP8vZoA1ur8yX31MAlfIBwENqJQxLS6GUj1OGcfcALVfsjtoyzSlVshbKLeMCHcbQKE4QY3cPKjhSm2LxPJaYscakqycsepw8DTP2sH4ML3j0OIa8aXvRsHcbDlCiBlfIBgMCHcAlKYKd0Rk73Lt3bPfqbctqIwciuuUoSxLqCaA0xYK5WePOb4gY2g3BiczBRKDwv8krkAaUHSTcLQTvYoRkoYi4XIVRn1wke3S8oHgvke3uhMvd4XIVRn1wke3S8oHg1wfzheCWL6guOqqpDrqSRBhwKarshG1LbES47AtTLcXnlVtOrfb4bIRwLcfc64EdriBlT0TKEGDwDgtMtxee762HfjqK0byDzGhl(U2uBPqCZY7eAuVH0bG4YdeOjG0kuiOJ7neHST0s3s6b2z1z4XIVRn1wke3S8oHg1wfzheCWL6guOqq3chY2sH4MHjxOG2cPm5afpgpw8DTP2cAnKEqJ2VPhYMinqdiCjc4XIVRn1wqRH0dANqJ6KVlnSiHwfeGeIOOqHGE6IGyJqlXLWq1QlT1LbtMDfHqVbAbQfnRkIhl(U2uBbTgspODcnQoCfcTKmSibHfbY2QuOqqpDrqSrOL4syOA1L26YGjZUIqO3aTa1IEikIhl(U2uBbTgspODcnQiR3vd0GWIaPAimbjQqHGwZa48qlehqRTtUqHavspWk7OVKjtIu0aCdzBfkvBRKDwwr8yX31MAlO1q6bTtOrLHlPqqPshHjx0TcfcAndGZdTqCaT2o5cfcuj9aRSJ(sMmjsrdWnKTvOuTTs2zzfXJfFxBQTGwdPh0oHg1wfeCZ56M0aYs8Gcfc6PlcILa(r5GwhqwIhSUmyYC6IGyjGFuoO1bKL4HGFDZgiwDl(rvlRkIhl(U2uBbTgspODcnQKIbdoeQmOziEapw8DTP2cAnKEq7eAuhSeo9gQmqa9Ms6bfke0txeelVqGjFxQv3IFu1oe8yX31MAlO1q6bTtOrncXLGsyrcCxFrducirTcfcAexckQvnv860fbXgHwIlHHQvxARld8y8yX31MABUKOWrFdPdaXLhiqtaPvOqq3chY2g3iKTB0cPm5a960fbXYGamecqT0DqETRiWoR4XIVRn12CjrH7eAuraEG4QvPqHGE4BHuYKd2bs1v6iGSKqCJq2UrMmBHdzBraEik6giOyHuMCGoY1H9QeIdqJ(sMmhMifna3q224EdriBBLSZQIxjsrdWnKTvOuTTs2zvXrgbpw8DTP2MljkCNqJkcWdtHqehGcfcALVfsjtoyhivxPJaYscXncz7gVoS476gcqcXc0StbDraAOfIdO1mzsKIgGBiBRqPABLSpefhbpw8DTP2MljkCNqJkfKwvqpaagkuiOVfsjtoyNCHcbQKEapw8DTP2MljkCNqJAfJlx6AZG4se8yX31MABUKOWDcnQakqycsuHcbT476gcqcXc0SZ61HvMifna3q2wHs1w4IkDRzYKifna3q2wHs1wxgJCv5BHuYKd2bs1v6iGSKqCJq2Ur8yX31MABUKOWDcnQtUqHavspOqHG(wiLm5GDYfkeOs6b8yX31MABUKOWDcnQiaFYfkOqHGgXLGILciLVA2rRMkIhl(U2uBZLefUtOrfqbctqIkuiOvUfoKTDYRKgqCjOyHuMCGEv5BHuYKd2bs1v6iGSKaviJg0CrR6krkAaUHSTcLQTvYU47AtlGceMGeT(D50DqIhl(U2uBZLefUtOrvYSuvCPRnvOqqpClCiBlfIBgMCHcAlKYKduMmv(wiLm5GDGuDLocilje3iKTBKjtexckwkGu(Qv7quKjZPlcIncTexcdvRU0wceLk1Q1zJCv5BHuYKdwg7YR0razjHjxOqGkPhUQ8TqkzYb7aP6kDeqwsGkKrdAUOvHhl(U2uBZLefUtOr1RswDq3KAuqHcb9WTWHSTuiUzyYfkOTqktoqzYu5BHuYKd2bs1v6iGSKqCJq2UrMmrCjOyPas5RwTdrXrUQ8TqkzYblJD5v6iGSKqeA5QY3cPKjhSm2LxPJaYsctUqHavspCv5BHuYKd2bs1v6iGSKaviJg0CrRcpw8DTP2MljkCNqJkGceMGevOqq3chY2o5vsdiUeuSqktoqVsKIgGBiBRqPABLSl(U20cOaHjirRFxoDhK4XIVRn12CjrH7eAuPqCtDywnGhl(U2uBZLefUtOrfb4bIRwLcfcALBHdzBJBeY2nAHuMCGELifna3q224EdriBBLS7vjehG25ZQIxBHdzBPqCZWKluqBHuMCGIhl(U2uBZLefUtOrfb4tUqbfke0X9gIq2wAPBj9a7S6mMmNUii21TdlsGiPdW6Yapw8DTP2MljkCNqJkcWdexTkfke0X9gIq2wAPBj9a7S6mMmhE6IGyx3oSibIKoaRlJRk3chY2g3iKTB0cPm5aDe8yX31MABUKOWDcnQ3q6aqC5bc0eqAfke0X9gIq2wAPBj9a7S6m8yX31MABUKOWDcnQTkYoi4Gl1nOqHGUfoKTLcXndtUqbTfszYb63F)p]] )


end
