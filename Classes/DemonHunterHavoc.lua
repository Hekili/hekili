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
                    return talent.demonic.enabled and ( buff.metamorphosis.up and buff.metamorphosis.duration % 15 > 0 and buff.metamorphosis.duration > ( action.eye_beam.cast + 8 ) )
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


    spec:RegisterPack( "Havoc", 20181211.1748, [[dOuh2aqisIhrfLnbbFccvzuuP6uuPSkie6vurMfQs3sIk7Is)sQ0WOsCmiQLHQONrsQPbHY1qvyBKK4BqizCsuvNJKKSojQY8OsY9GK9rs5GujLwijvpKkQyIqOYfHqqBKKKkFKkQuJKkP6KqiQvkrMjjjvDtssk7eszOujflLkQ6PQ0uHuDvie5RurLSxO(lvnysDyIfRIhlLjJ4YGnJkFgv1OPcNw41suMnk3ws7w0VvA4KWXHqGLJ0ZPy6kUUe2Uu13LkgpesDEiY6HqvnFs0(v1yKXOJVezamA80fKlFK5jYiBrgrHyLppvv47GKcaFviTYe(a(MsfWxxx63g(QqqITcbJo(A2cAdWxhZOWuED7YpghfhBBRDnrTGjtSzJkCtxtuBDpS909WjLJa9DvqxUGbMUUgk48sqmDDnoVhXb1n9UEroa176s)2SMO2W3trWge5eFWxImagnE6cYLpY8ezKTiJOqmEOAedFnkGggnEGOqu4RJGqGeFWxcyA4RZETRl9B71ioOU5RD9ICa6xYzV2XmkmLx3U8JXrXX22AxtulyYeB2Oc301e1w3dBpDpCs5iqFxf0LlyGPRRHcoVeetxxJZ7rCqDtVRxKdq9UU0VnRjQTVKZEnIdAq9a0xJmY8(AE6cYL)Rl3Rrwvkpetv9L(so71oxcnJKVP8(so71L71isMi5)Aehu381QZecyEDvkdmVUUM51Q6kOi9A(qcuzInFTIckWq61opAo3VMqJEiFTKKxxKkOajAJCyaVVUJJO541Dcg71rvH0MxpoGxJiOqyXG0RxUxtH2wRqsKj20y)sFjN9ANJdj5dMY7l5SxxUx7AjeG8ANZMMIk8AvnHF0SFjN96Y9ANhQBpqE9iu(W4dUx3CaTYEn3sFnAqfmH51YjyXGK9l5SxxUx78qD7bYRRBpuHCETCcwmbyEnhDRVwbnwAmi96ooG815oVUWaKxZT0xRQTviNIQ9l5SxxUx7AjeG8Aejd8Ae5bQMxp7RHK86L71oNDzKTtAET0Mytwygl(YcZyWOJV5sRcdJognKXOJVqkhgqWQJVnAmane8DegKJTUviNIQfs5WaYRr41NcooRckOqOaXs2o5Rr41tuHxR2RrgFL2eBIV9qYh4kyEkmuqg8GrJNy0XxiLddiy1X3gngGgc(6(R7fAihgy7iXejFp3s91Tc5uuFTsLVEegKJLdy(QygGIKfs5WaYRD71i8A3FDZHq5dMxJ61881kv(A3FnvcIh6HCS1ThQqo2iFTAVgzxEncVMkbXd9qowHqm2iFTAVgzxETBV2n8vAtSj(YbmpTW4apy0ungD8fs5WacwD8TrJbOHGVQ86EHgYHb2osmrY3ZTuFDRqof1xJWRD)1sBIEWdjudW8A1Enbmbfi(rO8HX8ALkFnvcIh6HCScHySr(A1ETQD51UHVsBInXxoG5pcLk8b8GrdXWOJVqkhgqWQJVnAmane8TxOHCyG9Wec4js2a8vAtSj(sazC4nDaqbEWOXdm64R0Myt8nQ1LjtSPxkOc(cPCyabRoEWOPky0XxiLddiy1X3gngGgc(kTj6bpKqnaZRv71i)AeET7VwLxtLG4HEihRqiglGOdZyETsLVMkbXd9qowHqm2cfV2TxJWRv519cnKddSDKyIKVNBP(6wHCkQ4R0Myt8fqc8hqQ4bJgIcJo(cPCyabRo(2OXa0qW3EHgYHb2dtiGNizdWxPnXM47HjeWtKSb4bJw5JrhFHuomGGvhFB0yaAi4lxbfjlb4IwmVwnuVgXCbFL2eBIVCa7WecGhmAQkm64lKYHbeS64BJgdqdbFv51JWGCShwKepxbfjlKYHbKxJWRv519cnKddSDKyIKVNBPEIqlZByIXXRr41ujiEOhYXkeIXg5Rv71sBInTasG)as122Lr2oj(kTj2eFbKa)bKkEWOHSly0XxiLddiy1X3gngGgc(6(RhHb5yjqDt)HjeWyHuomG8ALkFTkVUxOHCyGTJetK89Cl1x3kKtr91kv(AUckswcWfTyETRETQD51kv(6tbhNTcJuxQchRjmwkuLinV2vVMhV2TxJWRv519cnKddSk2LfjFp3s9hMqaprYg8AeETkVUxOHCyGTJetK89Cl1teAzEdtmoWxPnXM4RKz4iyYeBIhmAiJmgD8fs5WacwD8TrJbOHGVU)6ryqowcu30FycbmwiLddiVwPYxRYR7fAihgy7iXejFp3s91Tc5uuFTsLVMRGIKLaCrlMx7QxRAxETBVgHxRYR7fAihgyvSlls(EUL6RWiVgHxRYR7fAihgyvSlls(EUL6pmHaEIKn41i8AvEDVqd5WaBhjMi575wQNi0Y8gMyCGVsBInX3MdznEZqJYa8GrdzEIrhFHuomGGvhFB0yaAi47imih7HfjXZvqrYcPCya51i8AQeep0d5yfcXyJ81Q9APnXMwajWFaPAB7YiBNeFL2eBIVasG)asfpy0qw1y0XxPnXM4lbQBA8Nya8fs5WacwD8GrdzedJo(cPCyabRo(2OXa0qW362dvihljmJKn41Q9AK5XRvQ81Ncoo7wm(LZtLKpyluGVsBInXxoGDycbWdgnK5bgD8fs5WacwD8TrJbOHGVJWGCSeOUP)WecySqkhgqWxPnXM474GUD88zs0d4bp4lb4Kc2GrhJgYy0XxPnXM4ljm0cfd(cPCyabRoEWOXtm64R0Myt8TTPPOc(QWpA4lKYHbeS64bJMQXOJVqkhgqWQJV9cRaW3ryqowUGAg)HTlXcPCya51kv(AJcGX8Jq5dJXEycb8ejBaYVwnuV29xR6xxUxpcdYXoujy(LZtlI0cPCya51UHVsBInX3EHgYHb4BVq9Pub89Wec4js2a8GrdXWOJVqkhgqWQJV9cRaWxvET7VwLxpcdYXMqfmHXcPCya51kv(62UmY2jTjubtySuqii9ALkFDBxgz7K2eQGjmwkuLinVwTxpcLpm2jQGFwpjGxRu5RB7YiBN0MqfmHXsHQeP51Q9AvXLx7g(kTj2eF7fAihgGV9c1NsfW3osmrY3ZTuFcvWeg8GrJhy0XxiLddiy1X3EHva4RkVEegKJLa1nJMfs5WaYRr41TDzKTtARWi1LQWXAcJLcvjsZRD1RvLxJWR5kOizjax0I51Q9Av7YRr41U)AvEDVqd5WaBhjMi575wQpHkycZRvQ81TDzKTtAtOcMWyPqvI08Ax9AKD51UHVsBInX3EHgYHb4BVq9Pub8vXUSi575wQVcJGhmAQcgD8fs5WacwD8Txyfa(2l0qomWEycb8ejBWRr41U)AUcksV2vVgrXJxxUxpcdYXYfuZ4pSDjwiLddiVgr8180Lx7g(kTj2eF7fAihgGV9c1NsfWxf7YIKVNBP(dtiGNizdWdgnefgD8fs5WacwD8Txyfa(ocdYXseAzEdtmoSqkhgqEncVwLx3l0qomWQyxwK89Cl1Fycb8ejBWRr41Q86EHgYHbwf7YIKVNBP(kmYRr41TDzKTtAjcTmVHjgh2cf4R0Myt8TxOHCya(2luFkvaF7iXejFp3s9eHwM3WeJd8GrR8XOJVqkhgqWQJV9cRaW3ryqo26wHCkQwiLddiVgHxRYRpfCC26wHCkQ2cf4R0Myt8TxOHCya(2luFkvaF7iXejFp3s91Tc5uuXdgnvfgD8vAtSj(scdTqXGVqkhgqWQJhmAi7cgD8fs5WacwD8TrJbOHGV8BelfQsKMxJ61UGVsBInX3MWyEPnXMEwyg8LfMXNsfW32UmY2jXdgnKrgJo(cPCyabRo(2OXa0qWxUckswcWfTyETAOETQ5b(kTj2eFveTY8fk8CuHFfYbpy0qMNy0XxiLddiy1X3gngGgc(ocdYXseAzEdtmoSqkhgqEncV29x3l0qomW2rIjs(EUL6jcTmVHjghVwPYxtGtbhNLi0Y8gMyCylu8A3WxPnXM4BtymV0Mytplmd(YcZ4tPc4lrOL5nmX4apy0qw1y0XxiLddiy1X3gngGgc(ocdYXsG6MrZcPCyabFL2eBIV0I0lTj20ZcZGVSWm(uQa(sG6Mrdpy0qgXWOJVqkhgqWQJVsBInXxAr6L2eB6zHzWxwygFkvaFZLwfgEWd(QGcTTEKbJognKXOJVqkhgqWQJhmA8eJo(cPCyabRoEWOPAm64lKYHbeS64bJgIHrhFHuomGGvhpy04bgD8vAtSj(QyNyt8fs5WacwD8GrtvWOJVqkhgqWQJVnAmane8vLxli(angW2Ci7en)qL0WT0QmXMwiLddi4R0Myt8TcJuxQchRjm4bp4lbQBgnm6y0qgJo(cPCyabRo(2OXa0qWxPnrp4HeQbyETAVMaMGce)iu(WyETsLVMkbXd9qowHqm2iFTAVw1UGVsBInXxoG5pcLk8b8GrJNy0XxiLddiy1X3gngGgc(2l0qomWEycb8ejBa(kTj2eFjGmo8MoaOapy0ungD8fs5WacwD8TrJbOHGVQ86tbhNTcJuxQchRjmwarpqsaI)GKNa1nJ2Rr41U)AQeep0d5yfcXylu8ALkFnvcIh6HCScHySr(A1Enp5XRDdFL2eBIVasG)asfpy0qmm64lKYHbeS64BJgdqdbF7fAihgypmHaEIKn41i8AvEDBxgz7K2kmsDPkCSMWyPGqq61i8A3FDBxgz7KwajWFaPAPqvI08A1ET7VMhVUCVwq8bAmGLc9lRps((dtiGXsLSSxJi(Av)A3ETsLV29xtLG4HEihRqigBKVwTxlTj20Eycb8ejBGTTlJSDYxJWRPsq8qpKJvieJnYx7QxZtE8A3ETB4R0Myt89Wec4js2a8GrJhy0XxPnXM4BuRltMytVuqf8fs5WacwD8GrtvWOJVqkhgqWQJVnAmane8LRGI0RD1RrmxETsLV29xFk44SvyK6sv4ynHXs2o5Rr41CfuKSeGlAX8A1q9AeZLx7g(kTj2eF5a2Hjeapy0quy0XxiLddiy1X3gngGgc(6(RhHb5ypSijEUckswiLddiVwPYxZvqrYsaUOfZRD1RvTlVwPYxFk44SvyK6sv4ynHXsHQeP51U61841U9AeETkVUxOHCyGvXUSi575wQ)Wec4js2a8vAtSj(kzgocMmXM4bJw5JrhFHuomGGvhFB0yaAi4R7VEegKJ9WIK45kOizHuomG8ALkFnxbfjlb4IwmV2vVw1U8A3EncVwLx3l0qomWQyxwK89Cl1xHrEncVwLx3l0qomWQyxwK89Cl1Fycb8ejBa(kTj2eFBoK14ndnkdWdgnvfgD8fs5WacwD8TrJbOHGVJWGCSeOUP)WecySqkhgqEncVwLx32Lr2oPfqc8hqQwkieKEncV29x3Ciu(G51OEnpFTsLV29xtLG4HEihBD7HkKJnYxR2Rr2LxJWRPsq8qpKJvieJnYxR2Rr2Lx72RDdFL2eBIVCaZtlmoWdgnKDbJo(kTj2eFjqDtJ)edGVqkhgqWQJhmAiJmgD8fs5WacwD8TrJbOHGVNcoo7wm(LZtLKpyluGVsBInX3XbD745ZKOhWdgnK5jgD8fs5WacwD8TrJbOHGVJWGCSeOUP)WecySqkhgqWxPnXM474GUD88zs0d4bp4BBxgz7Ky0XOHmgD8fs5WacwD8TrJbOHGVQ8A3F9imihlbQBgnlKYHbKxRu5R7fAihgyvSlls(EUL6RWiVwPYx3l0qomW2rIjs(EUL6tOcMW8A3ETsLVEekFyStub)SEsaV2vVMN8aFL2eBIVvyK6sv4ynHbpy04jgD8fs5WacwD8TrJbOHGVJWGCSeOUz0SqkhgqEncV(uWXzRWi1LQWXAcJTqb(kTj2eFRWi1LQWXAcdEWOPAm64lKYHbeS64BJgdqdbFPsq8qpKJvieJfq0HzmVgHxtGtbhNnHkycJLSDYxJWRD)1sBIEWdjudW8A1Enbmbfi(rO8HX8ALkFnvcIh6HCScHySr(A1ETQ4YRDdFL2eBIVjubtyWdgnedJo(cPCyabRo(2OXa0qWxvEnvcIh6HCScHySaIomJbFL2eBIVjubtyWdgnEGrhFHuomGGvhFB0yaAi47PGJZwHrQlvHJ1eglfQsKMxR2R5jpETsLVEekFyStub)SEsaV2vVwvCbFL2eBIVk2j2epy0ufm64lKYHbeS64BkvaF5lmOjmgqn(ZUj(kTj2eF5lmOjmgqn(ZUjEWOHOWOJVqkhgqWQJVPub8Lvyg6wy88xgbsVcwrv4d4R0Myt8Lvyg6wy88xgbsVcwrv4d4bp4lrOL5nmX4aJognKXOJVqkhgqWQJVnAmane8LRGI0Rvd1RlFxEncV29xRYR7fAihgypmHaEIKn41kv(AvEDBxgz7K2dtiGNizdSuqii9A3WxPnXM4lrOL5nmX4apy04jgD8fs5WacwD8TrJbOHGVe4uWXzjcTmVHjgh2cf4R0Myt8vYmCemzInXdgnvJrhFHuomGGvhFB0yaAi4lbofCCwIqlZByIXHTqb(kTj2eFBoK14ndnkdWdEWd(2dutSjgnE6cYLVlQkEQQS80fEOA8TJqZi5BWxNlxRZJgImAo3L3RFn6oGxhvflDEn3sFnIhb4Kc2G49AkGiOiOa51MTcVwkMTkdqEDZHK8bJ9lPQps41iJC59AeP0uOqXshG8APnXMVgXtr0kZxOWZrf(vihep7x6lHixvS0biVwvET0MyZxZcZySFj8vkghlfFVrTGjtSPZHkCd(QGUCbdWxN9Axx632RrCqDZx76f5a0VKZETJzuykVUD5hJJIJTT1UMOwWKj2SrfUPRjQTUh2E6E4KYrG(UkOlxWatxxdfCEjiMUUgN3J4G6MExVihG6DDPFBwtuBFjN9Aeh0G6bOVgzK59180fKl)xxUxJSQuEiMQ6l9LC2RDUeAgjFt59LC2Rl3RrKmrY)1ioOU5RvNjeW86QugyEDDnZRv1vqr618HeOYeB(AffuGH0RDE0CUFnHg9q(AjjVUivqbs0g5WaEFDhhrZXR7em2RJQcPnVECaVgrqHWIbPxVCVMcTTwHKitSPX(L(so71ohhsYhmL3xYzVUCV21sia51oNnnfv41QAc)Oz)so71L71opu3EG86rO8HXhCVU5aAL9AUL(A0GkycZRLtWIbj7xYzVUCV25H62dKxx3EOc58A5eSycW8Ao6wFTcAS0yq61DCa5RZDEDHbiVMBPVwvBRqofv7xYzVUCV21sia51isg41iYdunVE2xdj51l3RDo7YiBN08APnXMSWm2V0xYzVgriIgAfdqE9b4wk862wpY86dWpsJ91U2wdumMxNBwohcTYvWET0MytZR3KHK9ljTj20yvqH2wpYGIJjMY(ssBInnwfuOT1JmoHQRuWVc5itS5xsAtSPXQGcTTEKXjuD52L8LC2RVPOW4yNxtLG86tbhhqETzKX86dWTu41TTEK51hGFKMxlj51kOq5uSZej)xhMxt2eSFjPnXMgRck026rgNq11KIcJJD8MrgZxsAtSPXQGcTTEKXjuDvStS5xsAtSPXQGcTTEKXjuDRWi1LQWXAcdVbhkveeFGgdyBoKDIMFOsA4wAvMytlKYHbKV0xYzVgriIgAfdqEn0duKE9ev41Jd41sBw6RdZRLEjyYHb2VK0MytdksyOfkMVK0MytJtO6220uubFv4hTVK0MytJtO62l0qomG3uQaQdtiGNizd4TxyfaQryqowUGAg)HTlXcPCyarPsJcGX8Jq5dJXEycb8ejBaYQHYDvxUryqo2HkbZVCEArKwiLddiU9LK2eBACcv3EHgYHb8Msfq1rIjs(EUL6tOcMWWBVWkauQ4UkJWGCSjubtySqkhgquQSTlJSDsBcvWeglfecskv22Lr2oPnHkycJLcvjsJAJq5dJDIk4N1tcqPY2UmY2jTjubtySuOkrAutvCXTVK0MytJtO62l0qomG3uQakf7YIKVNBP(kmcV9cRaqPYimihlbQBgnlKYHbeeA7YiBN0wHrQlvHJ1eglfQsKgxPkiWvqrYsaUOfJAQ2feCxLEHgYHb2osmrY3ZTuFcvWegLkB7YiBN0MqfmHXsHQePXvi7IBFjPnXMgNq1TxOHCyaVPubuk2LfjFp3s9hMqaprYgWBVWkau9cnKddShMqaprYgGG7CfuKCfIIhLBegKJLlOMXFy7sSqkhgqqe5PlU9LK2eBACcv3EHgYHb8Msfq1rIjs(EUL6jcTmVHjgh82lSca1imihlrOL5nmX4WcPCyabbv6fAihgyvSlls(EUL6pmHaEIKnabv6fAihgyvSlls(EUL6RWii02Lr2oPLi0Y8gMyCylu8LK2eBACcv3EHgYHb8Msfq1rIjs(EUL6RBfYPOYBVWkauJWGCS1Tc5uuTqkhgqqqLtbhNTUviNIQTqXxsAtSPXjuDjHHwOy(ssBInnoHQBtymV0MytplmdVPubuTDzKTtYBWHIFJyPqvI0GYLVK0MytJtO6QiAL5lu45Oc)kKdVbhkUckswcWfTyudLQ5XxsAtSPXjuDBcJ5L2eB6zHz4nLkGIi0Y8gMyCWBWHAegKJLi0Y8gMyCyHuomGGG79cnKddSDKyIKVNBPEIqlZByIXHsLe4uWXzjcTmVHjgh2cfU9LK2eBACcvxAr6L2eB6zHz4nLkGIa1nJgVbhQryqowcu3mAwiLddiFjPnXMgNq1LwKEPnXMEwygEtPcOYLwf2x6ljTj20yB7YiBNevfgPUufowty4n4qPI7JWGCSeOUz0SqkhgquQSxOHCyGvXUSi575wQVcJOuzVqd5WaBhjMi575wQpHkycJBkvocLpm2jQGFwpjaxXtE8LK2eBASTDzKTt6eQUvyK6sv4ynHH3Gd1imihlbQBgnlKYHbeeofCC2kmsDPkCSMWylu8LK2eBASTDzKTt6eQUjubty4n4qrLG4HEihRqiglGOdZyqGaNcooBcvWeglz7Ki4U0MOh8qc1amQratqbIFekFymkvsLG4HEihRqigBKQPkU42xsAtSPX22Lr2oPtO6MqfmHH3GdLkujiEOhYXkeIXci6WmMVK0MytJTTlJSDsNq1vXoXM8gCOofCC2kmsDPkCSMWyPqvI0Ogp5HsLJq5dJDIk4N1tcWvQIlFjPnXMgBBxgz7KoHQBHb8XavEtPcO4lmOjmgqn(ZU5xsAtSPX22Lr2oPtO6wyaFmqL3uQakwHzOBHXZFzei9kyfvHp8L(ssBInnwIqlZByIXbkIqlZByIXbVbhkUcksQHQ8Dbb3vPxOHCyG9Wec4js2aLkvPTlJSDs7HjeWtKSbwkieKC7ljTj20yjcTmVHjghoHQRKz4iyYeBYBWHIaNcoolrOL5nmX4WwO4ljTj20yjcTmVHjghoHQBZHSgVzOrzaVbhkcCk44SeHwM3WeJdBHIV0xsAtSPXsG6MrdfhW8hHsf(aVbhkPnrp4HeQbyuJaMGce)iu(WyuQKkbXd9qowHqm2ivt1U8LK2eBASeOUz0CcvxciJdVPdak4n4q1l0qomWEycb8ejBWxsAtSPXsG6MrZjuDbKa)bKkVbhkvofCC2kmsDPkCSMWybe9ajbi(dsEcu3mAi4ovcIh6HCScHySfkuQKkbXd9qowHqm2ivJN8WTVK0MytJLa1nJMtO6Eycb8ejBaVbhQEHgYHb2dtiGNizdqqL2UmY2jTvyK6sv4ynHXsbHGecU32Lr2oPfqc8hqQwkuLinQ5opkNG4d0yalf6xwFK89hMqaJLkzziIQ2nLkDNkbXd9qowHqm2ivtAtSP9Wec4js2aBBxgz7KiqLG4HEihRqigBKUIN8Wn3(ssBInnwcu3mAoHQBuRltMytVuqLVK0MytJLa1nJMtO6YbSdtiaVbhkUcksUcXCrPs3pfCC2kmsDPkCSMWyjBNebUckswcWfTyudfI5IBFjPnXMglbQBgnNq1vYmCemzIn5n4q5(imih7HfjXZvqrYcPCyarPsUckswcWfTyCLQDrPYtbhNTcJuxQchRjmwkuLinUIhUHGk9cnKddSk2LfjFp3s9hMqaprYg8LK2eBASeOUz0Ccv3MdznEZqJYaEdouUpcdYXEyrs8CfuKSqkhgquQKRGIKLaCrlgxPAxCdbv6fAihgyvSlls(EUL6RWiiOsVqd5WaRIDzrY3ZTu)HjeWtKSbFjPnXMglbQBgnNq1LdyEAHXbVbhQryqowcu30FycbmwiLddiiOsBxgz7KwajWFaPAPGqqcb3BoekFWGINkv6ovcIh6HCS1ThQqo2ivdzxqGkbXd9qowHqm2ivdzxCZTVK0MytJLa1nJMtO6sG6Mg)jg4ljTj20yjqDZO5eQUJd62XZNjrpWBWH6uWXz3IXVCEQK8bBHIVKZET0MytJLa1nJMtO6YbmpTW4G3GdvD7HkKJLeMrYgOgY8qPYtbhNDlg)Y5PsYhSfk(so71sBInnwcu3mAoHQBpK8bUcMNcdfKH3GdvD7HkKJLeMrYgOgY84ljTj20yjqDZO5eQUJd62XZNjrpWBWHAegKJLa1n9hMqaJfs5WaYx6ljTj20yZLwfgQEi5dCfmpfgkidVbhQryqo26wHCkQwiLddiiCk44SkOGcHcelz7Kimrfud5VK0MytJnxAvyoHQlhW80cJdEdouU3l0qomW2rIjs(EUL6RBfYPOQu5imihlhW8vXmafjlKYHbe3qW9MdHYhmO4PsLUtLG4HEihBD7HkKJns1q2feOsq8qpKJvieJns1q2f3C7ljTj20yZLwfMtO6Ybm)rOuHpWBWHsLEHgYHb2osmrY3ZTuFDRqofveCxAt0dEiHAag1iGjOaXpcLpmgLkPsq8qpKJvieJns1uTlU9LK2eBAS5sRcZjuDjGmo8MoaOG3GdvVqd5Wa7HjeWtKSbFjPnXMgBU0QWCcv3OwxMmXMEPGkFjPnXMgBU0QWCcvxajWFaPYBWHsAt0dEiHAag1qgb3vHkbXd9qowHqmwarhMXOujvcIh6HCScHySfkCdbv6fAihgy7iXejFp3s91Tc5uu)ssBInn2CPvH5eQUhMqaprYgWBWHQxOHCyG9Wec4js2GVK0MytJnxAvyoHQlhWomHa8gCO4kOizjax0IrnuiMlFjPnXMgBU0QWCcvxajWFaPYBWHsLryqo2dlsINRGIKfs5WaccQ0l0qomW2rIjs(EUL6jcTmVHjghiqLG4HEihRqigBKQjTj20cib(divBBxgz7KFjPnXMgBU0QWCcvxjZWrWKj2K3GdL7JWGCSeOUP)WecySqkhgquQuLEHgYHb2osmrY3ZTuFDRqofvLk5kOizjax0IXvQ2fLkpfCC2kmsDPkCSMWyPqvI04kE4gcQ0l0qomWQyxwK89Cl1Fycb8ejBacQ0l0qomW2rIjs(EUL6jcTmVHjghFjPnXMgBU0QWCcv3MdznEZqJYaEdouUpcdYXsG6M(dtiGXcPCyarPsv6fAihgy7iXejFp3s91Tc5uuvQKRGIKLaCrlgxPAxCdbv6fAihgyvSlls(EUL6RWiiOsVqd5WaRIDzrY3ZTu)HjeWtKSbiOsVqd5WaBhjMi575wQNi0Y8gMyC8LK2eBAS5sRcZjuDbKa)bKkVbhQryqo2dlsINRGIKfs5WaccujiEOhYXkeIXgPAsBInTasG)as122Lr2o5xsAtSPXMlTkmNq1La1nn(tmWxYzVwAtSPXMlTkmNq1LdyEAHXbVbhkvgHb5yRBfYPOAHuomGGavcIh6HCS1ThQqo2ivR5qO8bdIiYUGWimihlbQB6pmHaglKYHbKVK0MytJnxAvyoHQlhWomHa8gCOQBpuHCSKWms2a1qMhkvEk44SBX4xopvs(GTqXxYzVwAtSPXMlTkmNq1LdyEAHXbVbhQ62dvihljmJKnqnK5HsLUFk44SBX4xopvs(GTqbcQmcdYXw3kKtr1cPCyaXTVKZET0MytJnxAvyoHQBpK8bUcMNcdfKH3GdvD7HkKJLeMrYgOgY84ljTj20yZLwfMtO6ooOBhpFMe9aVbhQryqowcu30FycbmwiLddi4bpym]] )


end
