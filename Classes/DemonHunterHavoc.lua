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
        demonic_origins = not PTR and {
            id = 235894,
            duration = 3600,
            max_stack = 1,
        } or nil,

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

            usable = function () return target.casting end,
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


    spec:RegisterPack( "Havoc", 20181213.0934, [[dWuG3aqiiLfPsv1JOIytsL(KkvfJIkvNIkLvPsf8kQOMfPs3sQGDrPFPsmmQehJu0Yiv0Zuj10uPkxJuHTrfjFtLkACsfQZrfPSovsyEuj5EqY(iv1bLkelKuLhQsLmrvQuxKksfBuLkKpsLuXivjrNuLKyLsKzsfPs3uLQs7KuyOsfslLkP8uiMkKQRQss6RurQASQuHAVi(RKgmjhMyXQ4Xu1KH6YGnJkFMuA0uHtl61sfnBuUTu2TWVvA4OQoovsLwospNIPR46sy7svFxIA8QKuNxLY6PsQA(Ok7xvt0KGobbldq0qNUOzhRPo18ARloTRV31ofbzUXhii8fFNIwGGesdiixP0VEccF5gBfmbDcIzlOEGG4yg(MR4YfT54O4y9B7IjBfmzYn8uHBUyYM)YHTNlhoPdyO)cF6YLmWCPJsbxtsS5sh11Q3n02OELfXa06vk9R3AYMNGCks2CvcYHGGLbiAOtx0SJ1uNAET1fN2137ADqqm8bprdDCN3jbXrIXqqoeemy8eeN8QRu6x)RUBOTXRUYIya6xYjVYXm8nxXLlAZXrXX632ft2kyYKB4Pc3CXKn)LdBpxoCshWq)f(0LlzG5shLcUMKyZLoQRvVBOTr9klIbO1Ru6xV1Kn)xYjV6Ubp0oa9vAETUVsNUOzh)Qo8kN2vC99(sFjN8kNEHgzO1CfFjN8Qo8QRQjdTV6UH2gVspMGbZRAsNG5vT1mV6oQGE7vAHaOYKB8k(fuGD7vUMgUoVctZEiELe4xve8Pao9JCyGUVQSJ074vLtg7vzJV4NxnoGx56wiSCU9QL7vuWVTgeyzYnm2V0xYjV6UCiHwWCfFjN8Qo8Qocgd4xDxBykAWRUVI20B)so5vD4vUg02Ea)QrOAHPMCVY7a8D(kUL(knGgysZRKtYY5M9l5Kx1Hx5AqB7b8RABp0GyELCswojyEfhDBVIpnxAo3Evzhq8QyNxvya8R4w6RUVBdIPOz)so5vD4vDemgWV6QAGxDvgOzE1SVcc8RwUxDx7YWB5W8kXp5gS0m2VKtEvhE1DTrpqha)Q73VldVLJ7)vZ(Q7x8tUH9o263LH3YX9)QYoak8kHpFw6LddSeewAgdbDcsS0MWiOt0qtc6eeiKddWe9iiEAoanfcYimigBBBqmfnleYHb4x19vNcoolFkWxOa2I3YXR6(QjBWR0)vAsqe)KBqq6HqlWvWQuyOGmKHOHojOtqGqomat0JG4P5a0uiiU)QEHMYHb2YsozOTYT0ABBqmfTxXJ3RgHbXy5awTjMbO3SqihgGFLBVQ7RC)vEhcvlyEfQxPZxXJ3RC)vujXvOhIX22EObXyZ4v6)knD5vDFfvsCf6HyScgBSz8k9FLMU8k3ELBeeXp5geeoGvPfghKHOX1e0jiqihgGj6rq80CaAkee0EvVqt5WaBzjNm0w5wATTniMI2R6(k3FL4NShQqaTemVs)xHbtsbCDeQwymVIhVxrLexHEigRGXgBgVs)xDTlVYncI4NCdcchWQhHsfTaziACpc6eeiKddWe9iiEAoanfcsVqt5Wa7HjyOILWdeeXp5geemiJJQPma8jdrdDqqNGi(j3GGKT2YKj3OkfuHGaHCyaMOhziA4ue0jiqihgGj6rq80CaAkeeXpzpuHaAjyEL(VsZx19vU)k0EfvsCf6HyScgBSWvNMX8kE8EfvsCf6HyScgBSf8FLBVQ7Rq7v9cnLddSLLCYqBLBP122GykAeeXp5gee4gupG0idrJ7KGobbc5WamrpcINMdqtHG0l0uomWEycgQyj8abr8tUbb5WemuXs4bYq0OJjOtqGqomat0JG4P5a0uiiCf0BwmWL(CEL(OE19CHGi(j3GGWbSdtWaziA40iOtqGqomat0JG4P5a0uiiO9Qryqm2dldCLRGEZcHCya(vDFfAVQxOPCyGTSKtgARClTIfANvdtmoEv3xrLexHEigRGXgBgVs)xj(j3Wc3G6bKM1VldVLdcI4NCdccCdQhqAKHOHMUqqNGaHCyaMOhbXtZbOPqqC)vJWGySyOTr9WemySqihgGFfpEVcTx1l0uomWwwYjdTvULwBBdIPO9kE8Efxb9MfdCPpNx5QxDTlVIhVxDk44SnyK2s57ynPXsHMKH5vU6v64vU9QUVcTx1l0uomWYFxwgARClTEycgQyj8WR6(k0EvVqt5WaBzjNm0w5wAfl0oRgMyCqqe)KBqqKishjtMCdYq0qtnjOtqGqomat0JG4P5a0uiiU)Qryqmwm02OEycgmwiKddWVIhVxH2R6fAkhgyll5KH2k3sRTTbXu0EfpEVIRGEZIbU0NZRC1RU2Lx52R6(k0EvVqt5Wal)DzzOTYT0Adg5vDFfAVQxOPCyGL)USm0w5wA9WemuXs4Hx19vO9QEHMYHb2YsozOTYT0kwODwnmX4GGi(j3GG4DiRPAgA2jqgIgAQtc6eeiKddWe9iiEAoanfcYimig7HLbUYvqVzHqoma)QUVIkjUc9qmwbJn2mEL(Vs8tUHfUb1dinRFxgElheeXp5gee4gupG0idrdnVMGobr8tUbbbdTnm1toabbc5WamrpYq0qZ7rqNGaHCyaMOhbXtZbOPqqABp0GyS40ms4HxP)R0uhVIhVxDk44SBXuxUkvcTGTGpbr8tUbbHdyhMGbYq0qtDqqNGaHCyaMOhbXtZbOPqqgHbXyXqBJ6HjyWyHqomatqe)KBqqgh0TCvltYEGmKHGGboPGne0jAOjbDcI4NCdccon0c(dbbc5WamrpYq0qNe0jiIFYnii(nmfnO2eTPNGaHCyaMOhziACnbDcceYHbyIEeKEHvaeKryqmwUKAM6HTl2cHCya(v849kdFGXQJq1cJXEycgQyj8GMVsFuVY9xD9R6WRgHbXyhQKS6YvPfzyHqoma)k3iiIFYnii9cnLddii9cTgsdiihMGHkwcpqgIg3JGobbc5WamrpcsVWkaccAVY9xH2RgHbXydObM0yHqoma)kE8ELFxgElh2aAGjnwki4BVIhVx53LH3YHnGgysJLcnjdZR0)vJq1cJDYguNTIt4v849k)Um8woSb0atASuOjzyEL(VYPC5vUrqe)KBqq6fAkhgqq6fAnKgqqkl5KH2k3sRb0atAidrdDqqNGaHCyaMOhbPxyfabbTxncdIXIH2gP3cHCya(vDFLFxgElh2gmsBP8DSM0yPqtYW8kx9kN6vDFfxb9MfdCPpNxP)RU2Lx19vU)k0EvVqt5WaBzjNm0w5wAnGgysZR4X7v(Dz4TCydObM0yPqtYW8kx9knD5vUrqe)KBqq6fAkhgqq6fAnKgqq4VlldTvULwBWiKHOHtrqNGaHCyaMOhbPxyfabPxOPCyG9WemuXs4Hx19vU)kUc6Tx5QxDN64vD4vJWGySCj1m1dBxSfc5Wa8RUdVsNU8k3iiIFYnii9cnLddii9cTgsdii83LLH2k3sRhMGHkwcpqgIg3jbDcceYHbyIEeKEHvaeKryqmwSq7SAyIXHfc5Wa8R6(k0EvVqt5Wal)DzzOTYT06HjyOILWdVQ7Rq7v9cnLddS83LLH2k3sRnyKx19v(Dz4TCyXcTZQHjgh2c(eeXp5geKEHMYHbeKEHwdPbeKYsozOTYT0kwODwnmX4Gmen6yc6eeiKddWe9ii9cRaiiJWGySTTbXu0SqihgGFv3xH2RofCC222GykA2c(eeXp5geKEHMYHbeKEHwdPbeKYsozOTYT0ABBqmfnYq0WPrqNGi(j3GGGtdTG)qqGqomat0Jmen00fc6eeiKddWe9iiEAoanfcIwp2sHMKH5vOELleeXp5geeVWyvXp5gvwAgcclntnKgqq87YWB5Gmen0utc6eeiKddWe9iiEAoanfccxb9MfdCPpNxPpQxDToiiIFYnii8tFN1c(voQOTbXqgIgAQtc6eeiKddWe9iiEAoanfcYimiglwODwnmX4WcHCya(vDFL7VQxOPCyGTSKtgARClTIfANvdtmoEfpEVcdNcoolwODwnmX4WwW)vUrqe)KBqq8cJvf)KBuzPziiS0m1qAabbl0oRgMyCqgIgAEnbDcceYHbyIEeepnhGMcbzegeJfdTnsVfc5Wambr8tUbbHwevXp5gvwAgcclntnKgqqWqBJ0tgIgAEpc6eeiKddWe9iiIFYnii0IOk(j3OYsZqqyPzQH0acsS0MWidzii8PGFBhziOt0qtc6eeiKddWe9idrdDsqNGaHCyaMOhziACnbDcceYHbyIEKHOX9iOtqGqomat0Jmen0bbDcI4NCdcc)DYniiqihgGj6rgIgofbDcceYHbyIEeepnhGMcbbTxjUEGMdy9oKDsFDOsy4wAtMCdleYHbycI4NCdcsdgPTu(owtAidziiyH2z1WeJdc6en0KGobbc5WamrpcINMdqtHGWvqV9k9r9Qo2Lx19vU)k0EvVqt5Wa7HjyOILWdVIhVxH2R87YWB5WEycgQyj8GLcc(2RCJGi(j3GGGfANvdtmoidrdDsqNGaHCyaMOhbXtZbOPqqWWPGJZIfANvdtmoSf8jiIFYniisePJKjtUbziACnbDcceYHbyIEeepnhGMcbbdNcoolwODwnmX4WwWNGi(j3GG4DiRPAgA2jqgYqq87YWB5GGordnjOtqGqomat0JG4P5a0uiiO9k3F1imiglgABKEleYHb4xXJ3R6fAkhgy5VlldTvULwBWiVIhVx1l0uomWwwYjdTvULwdObM08k3EfpEVAeQwySt2G6SvCcVYvVsN6GGi(j3GG0GrAlLVJ1KgYq0qNe0jiqihgGj6rq80CaAkeKryqmwm02i9wiKddWVQ7RofCC2gmsBP8DSM0yl4)QUVY9xH2RexpqZbSEhYoPVoujmClTjtUHfc5Wa8R4X7vO9QEHMYHb2dtWqflHhEfpEVcTx53LH3YH9WemuXs4blfe8Tx5gbr8tUbbPbJ0wkFhRjnKHOX1e0jiqihgGj6rq80CaAkeeQK4k0dXyfm2yHRonJ5vDFfgofCC2aAGjnw8woEv3x5(Re)K9qfcOLG5v6)kmyskGRJq1cJ5v849kQK4k0dXyfm2yZ4v6)kNYLx5gbr8tUbbjGgysdziACpc6eeiKddWe9iiEAoanfccAVIkjUc9qmwbJnw4QtZyiiIFYniib0atAidrdDqqNGaHCyaMOhbXtZbOPqqofCC2gmsBP8DSM0yPqtYW8k9FLo1XR4X7vJq1cJDYguNTIt4vU6voLleeXp5gee(7KBqgIgofbDcceYHbyIEeKqAabrRWaVWya1up7geeXp5geeTcd8cJbut9SBqgIg3jbDcceYHbyIEeKqAabHvyg6wyQAxggIkFwrt0ceeXp5geewHzOBHPQDzyiQ8zfnrlqgYqqWqBJ0tqNOHMe0jiqihgGj6rq80CaAkeeXpzpuHaAjyEL(VcdMKc46iuTWyEfpEVIkjUc9qmwbJn2mEL(V6AxiiIFYniiCaREekv0cKHOHojOtqGqomat0JG4P5a0uii9cnLddShMGHkwcpqqe)KBqqWGmoQMYaWNmenUMGobbc5WamrpcINMdqtHGG2RofCC2gmsBP8DSM0yHREGad465wfdTns)R6(k3FfvsCf6HyScgBSf8FfpEVIkjUc9qmwbJn2mEL(VsN64vUrqe)KBqqGBq9asJmenUhbDcceYHbyIEeepnhGMcbPxOPCyG9WemuXs4Hx19vO9k)Um8woSnyK2s57ynPXsbbF7vDFL7VYVldVLdlCdQhqAwk0KmmVs)x5(R0XR6WRexpqZbSuOFz9zOTEycgmwQeD(Q7WRU(vU9kE8EL7VIkjUc9qmwbJn2mEL(Vs8tUH9WemuXs4bRFxgElhVQ7ROsIRqpeJvWyJnJx5QxPtD8k3ELBeeXp5geKdtWqflHhidrdDqqNGi(j3GGKT2YKj3OkfuHGaHCyaMOhziA4ue0jiqihgGj6rq80CaAkeeUc6Tx5QxDpxEfpEVY9xDk44SnyK2s57ynPXI3YXR6(kUc6nlg4sFoVsFuV6EU8k3iiIFYniiCa7WemqgIg3jbDcceYHbyIEeepnhGMcbX9xncdIXEyzGRCf0BwiKddWVIhVxXvqVzXax6Z5vU6vx7YR4X7vNcooBdgPTu(owtASuOjzyELRELoELBVQ7Rq7v9cnLddS83LLH2k3sRhMGHkwcpqqe)KBqqKishjtMCdYq0OJjOtqGqomat0JG4P5a0uiiU)Qryqm2dldCLRGEZcHCya(v849kUc6nlg4sFoVYvV6AxELBVQ7Rq7v9cnLddS83LLH2k3sRnyKx19vO9QEHMYHbw(7YYqBLBP1dtWqflHhiiIFYniiEhYAQMHMDcKHOHtJGobbc5WamrpcINMdqtHGmcdIXIH2g1dtWGXcHCya(vDFfAVYVldVLdlCdQhqAwki4BVQ7RC)vEhcvlyEfQxPZxXJ3RC)vujXvOhIX22EObXyZ4v6)knD5vDFfvsCf6HyScgBSz8k9FLMU8k3ELBeeXp5geeoGvPfghKHOHMUqqNGi(j3GGGH2gM6jhGGaHCyaMOhziAOPMe0jiqihgGj6rq80CaAkeKtbhNDlM6YvPsOfSf8jiIFYniiJd6wUQLjzpqgIgAQtc6eeiKddWe9iiEAoanfcYimiglgABupmbdgleYHbycI4NCdcY4GULRAzs2dKHmKHG0dutUbrdD6IMDSM6utnTAEN3RJjiLfAKHwdbXPVJ4AACv0W15kE1Rq3b8QSXFPZR4w6RUpyGtkyZ95vuW1TiPa(vMTbVskMTjdGFL3HeAbJ9l50nd4vAQ5v8QRAyk4ZFPdGFL4NCJxDF4N(oRf8RCurBdI5(y)sFPRsJ)sha)kN6vIFYnEflnJX(Lii8PlxYacItE1vk9R)v3n024vxzrma9l5Kx5yg(MR4YfT54O4y9B7IjBfmzYn8uHBUyYM)YHTNlhoPdyO)cF6YLmWCPJsbxtsS5sh11Q3n02OELfXa06vk9R3AYM)l5KxD3GhAhG(knVw3xPtx0SJFvhELt7kU(EFPVKtELtVqJm0AUIVKtEvhE1v1KH2xD3qBJxPhtWG5vnPtW8Q2AMxDhvqV9kTqauzYnEf)ckWU9kxtdxNxHPzpeVsc8Rkc(uaN(romq3xv2r6D8QYjJ9QSXx8ZRghWRCDlewo3E1Y9kk43wdcSm5gg7x6l5KxDxoKqlyUIVKtEvhEvhbJb8RURnmfn4v3xrB6TFjN8Qo8kxdABpGF1iuTWutUx5Da(oFf3sFLgqdmP5vYjz5CZ(LCYR6WRCnOT9a(vTThAqmVsojlNemVIJUTxXNMlnNBVQSdiEvSZRkma(vCl9v33TbXu0SFjN8Qo8Qocgd4xDvnWRUkd0mVA2xbb(vl3RURDz4TCyEL4NCdwAg7xYjVQdV6U2OhOdGF1973LH3YX9)QzF19l(j3WEhB97YWB54(FvzhafELWNpl9YHb2V0xYjVYPZvd(IbWV6aClfELFBhzE1b0MHX(QoI3d8hZRIn6GdH24kyVs8tUH5vBWUz)sIFYnmw(uWVTJmO4yIPZVK4NCdJLpf8B7iJZOUifABqmYKB8Le)KByS8PGFBhzCg1fUDXFjN8kKq4BCSZROsIF1PGJdWVYmYyE1b4wk8k)2oY8QdOndZRKa)k(uOd83zYq7RsZRWBa2VK4NCdJLpf8B7iJZOUycHVXXovZiJ5lj(j3Wy5tb)2oY4mQl83j34lj(j3Wy5tb)2oY4mQlnyK2s57ynPr3KdfAIRhO5awVdzN0xhQegUL2Kj3WcHCya(l9LCYRC6C1GVya8RGEGE7vt2GxnoGxj(zPVknVs6LKjhgy)sIFYnmOWPHwWF(sIFYnmoJ6IFdtrdQnrB6)sIFYnmoJ6sVqt5WaDdPbOombdvSeEq3EHvaOgHbXy5sQzQh2UyleYHbyE8m8bgRocvlmg7HjyOILWdAQpk3VUdJWGySdvswD5Q0ImSqihgGD7lj(j3W4mQl9cnLdd0nKgGQSKtgARClTgqdmPr3EHvaOqZD0gHbXydObM0yHqomaZJNFxgElh2aAGjnwki4B8453LH3YHnGgysJLcnjdJ(Jq1cJDYguNTItGhp)Um8woSb0atASuOjzy03PCXTVK4NCdJZOU0l0uomq3qAak(7YYqBLBP1gmIU9cRaqH2imiglgABKEleYHb4U(Dz4TCyBWiTLY3XAsJLcnjdJRCQUCf0BwmWL(C0)Ax66oA9cnLddSLLCYqBLBP1aAGjn8453LH3YHnGgysJLcnjdJR00f3(sIFYnmoJ6sVqt5WaDdPbO4VlldTvULwpmbdvSeEq3EHvaO6fAkhgypmbdvSeEOR7Cf0BU6o1rhgHbXy5sQzQh2UyleYHb47GoDXTVK4NCdJZOU0l0uomq3qAaQYsozOTYT0kwODwnmX4q3EHvaOgHbXyXcTZQHjghwiKddWDrRxOPCyGL)USm0w5wA9WemuXs4HUO1l0uomWYFxwgARClT2Gr663LH3YHfl0oRgMyCyl4)Le)KByCg1LEHMYHb6gsdqvwYjdTvULwBBdIPOPBVWkauJWGySTTbXu0SqihgG7I2PGJZ22getrZwW)lj(j3W4mQl40ql4pFjXp5ggNrDXlmwv8tUrLLMr3qAak)Um8wo0n5qP1JTuOjzyq5Yxs8tUHXzux4N(oRf8RCurBdIr3Kdfxb9MfdCPph9rDTo(sIFYnmoJ6IxySQ4NCJklnJUH0auyH2z1WeJdDtouJWGySyH2z1WeJdleYHb4UU3l0uomWwwYjdTvULwXcTZQHjgh84HHtbhNfl0oRgMyCyl472xs8tUHXzuxOfrv8tUrLLMr3qAakm02i96MCOgHbXyXqBJ0BHqoma)Le)KByCg1fAruf)KBuzPz0nKgGkwAtyFPVK4NCdJ1VldVLdunyK2s57ynPr3KdfAUpcdIXIH2gP3cHCyaMhVEHMYHbw(7YYqBLBP1gmcpE9cnLddSLLCYqBLBP1aAGjnUXJ3iuTWyNSb1zR4eCLo1Xxs8tUHX63LH3YHZOU0GrAlLVJ1KgDtouJWGySyOTr6TqihgG7Ek44SnyK2s57ynPXwWVR7OjUEGMdy9oKDsFDOsy4wAtMCdleYHbyE8qRxOPCyG9WemuXs4bE8qZVldVLd7HjyOILWdwki4BU9Le)KByS(Dz4TC4mQlb0atA0n5qrLexHEigRGXglC1PzmDXWPGJZgqdmPXI3Yrx3f)K9qfcOLGrFmyskGRJq1cJHhpQK4k0dXyfm2yZqFNYf3(sIFYnmw)Um8woCg1LaAGjn6MCOqJkjUc9qmwbJnw4QtZy(sIFYnmw)Um8woCg1f(7KBOBYH6uWXzBWiTLY3XAsJLcnjdJ(6uh84ncvlm2jBqD2kobx5uU8Le)KByS(Dz4TC4mQlfgOMd00nKgGsRWaVWya1up7gFjXp5ggRFxgElhoJ6sHbQ5anDdPbOyfMHUfMQ2LHHOYNv0eTWx6lj(j3WyXcTZQHjghOWcTZQHjgh6MCO4kO30hvh7sx3rRxOPCyG9WemuXs4bE8qZVldVLd7HjyOILWdwki4BU9Le)KBySyH2z1WeJdNrDrIiDKmzYn0n5qHHtbhNfl0oRgMyCyl4)Le)KBySyH2z1WeJdNrDX7qwt1m0Stq3KdfgofCCwSq7SAyIXHTG)x6lj(j3WyXqBJ0JIdy1JqPIwq3KdL4NShQqaTem6JbtsbCDeQwym84rLexHEigRGXgBg6FTlFjXp5gglgABKENrDbdY4OAkdaFDtou9cnLddShMGHkwcp8Le)KBySyOTr6Dg1f4gupG00n5qH2PGJZ2GrAlLVJ1KglC1deyaxp3QyOTr676ovsCf6HyScgBSf85XJkjUc9qmwbJn2m0xN6WTVK4NCdJfdTnsVZOUCycgQyj8GUjhQEHMYHb2dtWqflHh6IMFxgElh2gmsBP8DSM0yPGGV11D)Um8woSWnOEaPzPqtYWOV76OdIRhO5awk0VS(m0wpmbdglvIoVdx7gpEUtLexHEigRGXgBg6l(j3WEycgQyj8G1VldVLJUujXvOhIXkySXMHR0PoCZTVK4NCdJfdTnsVZOUKT2YKj3Okfu5lj(j3WyXqBJ07mQlCa7WemOBYHIRGEZv3ZfE8C)uWXzBWiTLY3XAsJfVLJUCf0BwmWL(C0h19CXTVK4NCdJfdTnsVZOUirKosMm5g6MCOCFegeJ9WYax5kO3SqihgG5XJRGEZIbU0NJRU2fE8ofCC2gmsBP8DSM0yPqtYW4kD4wx06fAkhgy5VlldTvULwpmbdvSeE4lj(j3WyXqBJ07mQlEhYAQMHMDc6MCOCFegeJ9WYax5kO3SqihgG5XJRGEZIbU0NJRU2f36IwVqt5Wal)DzzOTYT0AdgPlA9cnLddS83LLH2k3sRhMGHkwcp8Le)KBySyOTr6Dg1foGvPfgh6MCOgHbXyXqBJ6HjyWyHqoma3fn)Um8woSWnOEaPzPGGV11DVdHQfmO0jpEUtLexHEigBB7HgeJnd910LUujXvOhIXkySXMH(A6IBU9Le)KBySyOTr6Dg1fm02Wup5aFjXp5gglgABKENrDzCq3YvTmj7bDtouNcoo7wm1LRsLqlyl4)LCYRe)KBySyOTr6Dg1foGvPfgh6MCOABp0GyS40ms4b91uh84Dk44SBXuxUkvcTGTG)xYjVs8tUHXIH2gP3zux6HqlWvWQuyOGm6MCOABp0GyS40ms4b91uhFjXp5gglgABKENrDzCq3YvTmj7bDtouJWGySyOTr9WemySqihgG)sFjXp5ggBS0MWq1dHwGRGvPWqbz0n5qncdIX22getrZcHCyaU7PGJZYNc8fkGT4TC0DYgOVMFjXp5ggBS0MWCg1foGvPfgh6MCOCVxOPCyGTSKtgARClT22getrJhVryqmwoGvBIza6nleYHby366U3Hq1cgu6Khp3PsIRqpeJTT9qdIXMH(A6sxQK4k0dXyfm2yZqFnDXn3(sIFYnm2yPnH5mQlCaREekv0c6MCOqRxOPCyGTSKtgARClT22getrRR7IFYEOcb0sWOpgmjfW1rOAHXWJhvsCf6HyScgBSzO)1U42xs8tUHXglTjmNrDbdY4OAkdaFDtou9cnLddShMGHkwcp8Le)KBySXsBcZzuxYwBzYKBuLcQ8Le)KBySXsBcZzuxGBq9ast3KdL4NShQqaTem6Rzx3rJkjUc9qmwbJnw4QtZy4XJkjUc9qmwbJn2c(U1fTEHMYHb2YsozOTYT0ABBqmfTVK4NCdJnwAtyoJ6YHjyOILWd6MCO6fAkhgypmbdvSeE4lj(j3WyJL2eMZOUWbSdtWGUjhkUc6nlg4sFo6J6EU8Le)KBySXsBcZzuxGBq9ast3KdfAJWGyShwg4kxb9Mfc5WaCx06fAkhgyll5KH2k3sRyH2z1WeJJUujXvOhIXkySXMH(IFYnSWnOEaPz97YWB54lj(j3WyJL2eMZOUirKosMm5g6MCOCFegeJfdTnQhMGbJfc5WampEO1l0uomWwwYjdTvULwBBdIPOXJhxb9MfdCPphxDTl84Dk44SnyK2s57ynPXsHMKHXv6WTUO1l0uomWYFxwgARClTEycgQyj8qx06fAkhgyll5KH2k3sRyH2z1WeJJVK4NCdJnwAtyoJ6I3HSMQzOzNGUjhk3hHbXyXqBJ6HjyWyHqomaZJhA9cnLddSLLCYqBLBP122GykA84XvqVzXax6ZXvx7IBDrRxOPCyGL)USm0w5wATbJ0fTEHMYHbw(7YYqBLBP1dtWqflHh6IwVqt5WaBzjNm0w5wAfl0oRgMyC8Le)KBySXsBcZzuxGBq9ast3Kd1imig7HLbUYvqVzHqoma3LkjUc9qmwbJn2m0x8tUHfUb1dinRFxgElhFjXp5ggBS0MWCg1fm02Wup5aFjN8kXp5ggBS0MWCg1foGvPfgh6MCOqBegeJTTniMIMfc5WaCxQK4k0dXyBBp0GySzOV3Hq1cM7GMU0DegeJfdTnQhMGbJfc5Wa8xs8tUHXglTjmNrDHdyhMGbDtouTThAqmwCAgj8G(AQdE8ofCC2TyQlxLkHwWwW)l5Kxj(j3WyJL2eMZOUWbSkTW4q3KdvB7HgeJfNMrcpOVM6Ghp3pfCC2TyQlxLkHwWwWVlAJWGySTTbXu0SqihgGD7l5Kxj(j3WyJL2eMZOU0dHwGRGvPWqbz0n5q12EObXyXPzKWd6RPo(sIFYnm2yPnH5mQlJd6wUQLjzpOBYHAegeJfdTnQhMGbJfc5WambrkghlLGGKTcMm5g3fv4gYqgcb]] )


end
