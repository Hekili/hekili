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


    spec:RegisterPack( "Havoc", 20190201.2335, [[d0eh4aqisrlIeu9isGnPs6tKGOrjf5usrTksfvVIk0SifUfvI2fL(LkXWOs6yKkTmPQ8mvQAAuj01ivyBuj4BKG04KQkCosqzDsvLEhjiyEQuX9GK9rcDqPkIfsf8qPQQMiPI0fLQaSrsfXhLQansPQkNuQQOvsLAMsvaDtPks7eszOsvOwQkv6PqmvivxLur5RsvqnwsqO9I4VsmyIomQfRIhtvtgQld2mj9zs0OjvDArVwQsZgPBlPDl8BLgoP0XLQGSCcpNIPR46sPTlv(Uuy8svuNxLY6LQqMpv0(v1eDjOtqW8ae06ZvDvyU2NR6A77(71rF9rqMBAbcIw23lReiibxbcs)XDRNGOLVrxgtqNGy2wHhii6NrRPFVCrzo6Bpw)wVyYAlLNCdVGvNlMS6VCO75YrLDjg6UOvSQjfmx6Xc4UCInx6X3TOtH6gL(Rngqu6pUB9wtw9eKtBsN(zqoeempabT(CvxfMR95QU2(U)EDORUeeJwWtqthkufkbrFIXqqoeemy8eef8Y(J7w)l1PqDJx2FTXaI3TcEP(z0A63lxuMJ(2J1V1lMS2s5j3Wly15IjR(lh6EUCuzxIHUlAfRAsbZLESaUlNyZLE8Dl6uOUrP)AJbeL(J7wV1Kv)7wbVuNahrllU9sD14L95QUkSx6Yx239979U47(DRGx2dZIidLM(9DRGx6YxQZmzO8L6uOUXlDGYyW8Yk3lyEzDnZl1jTIBVujeGGNCJxQTva0BV8UO1d(sSi7G4LCGFzBOva40p8HcA8Yg6tV(x2iP0xMvTSFE5OhEzpultZ52lx1xka)wRqG5j3WyF3k4LU8L6mtgkFzpDRqmT1xMMxg78sb43AfcmGvi8sDcqF5DBn6FzJKsF5bEPa8BTcbgWVKd8lh9WlnSkm3E5Q(sDcqF5DBn6FPNJyNxEGxIHb8dGF552lzmEdJ9D)UvWl7F9COem977wbV0LVSNGXa(L9)gM2k8YEkRm923TcEPlF5DH62b4xoSqjmLu9LE9GV3xQUIxIgubtAEjFsAo3SVBf8sx(Y7c1TdWVSUDqfI5L8jP5KG5LQIT(sTICf5C7Ln0dXlJDEzRbWVuDfVSNUviM2Q9DRGx6Yx2tWya)sDMbEz)CGQ5LZ(siWVCvFz)VlfVncZlz)KBqtZyF3k4LU8L9)gDGya8lv4(DP4TrOWF5SVuHZ(j3WQq063LI3gHc)Ln0dc4LSwT00Zhkyji00mgc6eKyfvMsqNGMUe0jiqWhkGjoqq8ICarYeKHPqm26wHyARwi4dfWV86lpTQQwTcqllaSfVnIxE9LtwHxQ4l1LGW(j3GG0bHsqTLweWiaEidbT(iOtqGGpuatCGG4f5aIKjiDSi5dfSn4CYqzrDfL6wHyARV86lB6LE9SqjyEjQx23lD68Ln9sbN4c0bXyRBhuHySz8sfFPUU(YRVuWjUaDqmwgJn2mEPIVuxxFzZVSzcc7NCdcIkqlIwJEYqq7Ec6eei4dfWehiiEroGizcIMVSJfjFOGTbNtgklQROu3ketB9LxFztVK9t2bfiGAcMxQ4lXGjfaUmSqjmMx605lfCIlqheJLXyJnJxQ4lV31x2mbH9tUbbrfOLdleSsGme0Crc6eei4dfWehiiEroGizcshls(qb7HYyOG5Wdee2p5geemWJ(IPbaAjdbnDqqNGW(j3GGK16s5j3OWTcMGabFOaM4aziO5ce0jiqWhkGjoqq8ICarYee2pzhuGaQjyEPIVu3xE9Ln9snFPGtCb6GySmgBSqpNMX8sNoFPGtCb6GySmgBSTAFzZV86l18LDSi5dfSn4CYqzrDfL6wHyARee2p5gee4guoaxjdbnfkbDcce8HcyIdeeVihqKmbPJfjFOG9qzmuWC4bcc7NCdcYHYyOG5WdKHGw)GGobbc(qbmXbcIxKdisMGO2kUzXGA6Z5LkI6LUORee2p5geevGEOmgidbnfgbDcce8HcyIdeeVihqKmbrZxomfIXEOzGlQTIBwi4dfWV86l18LDSi5dfSn4CYqzrDffml6TyOSr)lV(sbN4c0bXyzm2yZ4Lk(s2p5gw4guoaxT(DP4Trqqy)KBqqGBq5aCLme001vc6eei4dfWehiiEroGizcstVCykeJfd1nkhkJbJfc(qb8lD68LA(YowK8Hc2gCozOSOUIsDRqmT1x605lvBf3Syqn958Y78Y7D9LoD(YtRQQTcdxxHw9Rjnwbu5mmV8oVuhVS5xE9LA(YowK8HcwT7sZqzrDfLdLXqbZHhE51xQ5l7yrYhkyBW5KHYI6kkyw0BXqzJEcc7NCdcchrQpP8KBqgcA6QlbDcce8HcyIdeeVihqKmbPPxomfIXIH6gLdLXGXcbFOa(LoD(snFzhls(qbBdoNmuwuxrPUviM26lD68LQTIBwmOM(CE5DE59U(YMF51xQ5l7yrYhky1UlndLf1vuQWWV86l18LDSi5dfSA3LMHYI6kkhkJHcMdp8YRVuZx2XIKpuW2GZjdLf1vuWSO3IHYg9ee2p5geeVEEnfZiYEbYqqt3(iOtqGGpuatCGG4f5aIKjidtHyShAg4IAR4Mfc(qb8lV(sbN4c0bXyzm2yZ4Lk(s2p5gw4guoaxT(DP4Trqqy)KBqqGBq5aCLme009Ec6ee2p5geemu3Wuo5aeei4dfWehidbnDDrc6eei4dfWehiiEroGizcsD7GkeJfNMHdp8sfFPU64LoD(YtRQQDBNYQweCOeSTAjiSFYniiQa9qzmqgcA6Qdc6eei4dfWehiiEroGizcYWuiglgQBuougdgle8Hcycc7NCdcYOxSnkkPC2bKHmeemOYT0HGobnDjOtqy)KBqqWPr0QDiiqWhkGjoqgcA9rqNGW(j3GG43W0wHsLvMEcce8HcyIdKHG29e0jiqWhkGjoqq6yAlqqgMcXyvtHzkh6Uyle8Hc4x605lnAbkTmSqjmg7HYyOG5Wd6(sfr9YME59V0LVCykeJDeCslRAr0MHfc(qb8lBMGW(j3GG0XIKpuGG0XIsWvGGCOmgkyo8aziO5Ie0jiqWhkGjoqq6yAlqq08Ln9snF5WuigBavWKgle8Hc4x605l97sXBJWgqfmPXkagF7LoD(s)Uu82iSbubtAScOYzyEPIVCYkuMTGt4LoD(s)Uu82iSbubtAScOYzyEPIV0fC9Lntqy)KBqq6yrYhkqq6yrj4kqqAW5KHYI6kkbubtAidbnDqqNGabFOaM4abPJPTabrZxomfIXIH6gP3cbFOa(LxFPFxkEBe2kmCDfA1VM0yfqLZW8Y78sx4LxFPAR4MfdQPpNxQ4lV31xE9Ln9snFzhls(qbBdoNmuwuxrjGkysZlD68L(DP4TrydOcM0yfqLZW8Y78sDD9Lntqy)KBqq6yrYhkqq6yrj4kqq0UlndLf1vuQWWKHGMlqqNGabFOaM4abPJPTabPJfjFOG9qzmuWC4HxE9Ln9s1wXTxENxQq1XlD5lhMcXyvtHzkh6Uyle8Hc4xQZFzFU(YMjiSFYniiDSi5dfiiDSOeCfiiA3LMHYI6kkhkJHcMdpqgcAkuc6eei4dfWehiiDmTfiidtHySyOUr6TqWhkGF51xQ5lhMcXyp0mWf1wXnle8Hc4xE9L(DP4TryHBq5aC1kGkNH5L35Ln9sLESTY98l15VSVx28lV(s1wXnlgutFoVuXx2NRee2p5geKowK8HceKowucUceeT7sZqzrDff4guoaxjdbT(bbDcce8HcyIdeKoM2ceKHPqmwml6TyOSrVfc(qb8lV(snFzhls(qbR2DPzOSOUIYHYyOG5WdV86l18LDSi5dfSA3LMHYI6kkvy4xE9L(DP4TryXSO3IHYg92wTee2p5geKowK8HceKowucUceKgCozOSOUIcMf9wmu2ONme0uye0jiqWhkGjoqq6yAlqqgMcXyRBfIPTAHGpua)YRVuZxEAvvT1TcX0wTTAjiSFYniiDSi5dfiiDSOeCfiin4CYqzrDfL6wHyARKHGMUUsqNGW(j3GGGtJOv7qqGGpuatCGme00vxc6eei4dfWehiiEroGizcIsp2kGkNH5LOEPRee2p5geeptPf2p5gfAAgccnntj4kqq87sXBJGme00Tpc6eei4dfWehiiEroGizcIAR4MfdQPpNxQiQxEVoiiSFYniiAtFVLwTfvbRScXqgcA6EpbDcce8HcyIdeeVihqKmbzykeJfZIElgkB0BHGpua)YRVSPx2XIKpuW2GZjdLf1vuWSO3IHYg9V0PZxIHtRQQfZIElgkB0BB1(YMjiSFYniiEMslSFYnk00meeAAMsWvGGGzrVfdLn6jdbnDDrc6eei4dfWehiiEroGizcYWuiglgQBKEle8Hcycc7NCdcIOnkSFYnk00meeAAMsWvGGGH6gPNme00vhe0jiqWhkGjoqqy)KBqqeTrH9tUrHMMHGqtZucUceKyfvMsgYqq0ka)wp8qqNGMUe0jiqWhkGjoqgcA9rqNGabFOaM4aziODpbDcce8HcyIdKHGMlsqNGabFOaM4aziOPdc6ee2p5geeT7KBqqGGpuatCGme0Cbc6eei4dfWehiiEroGizcIMVK7rGihW61Z7K(Yi4WOUIkp5gwi4dfWee2p5geKkmCDfA1VM0qgYqqWSO3IHYg9e0jOPlbDcce8HcyIdeeVihqKmbrTvC7LkI6L9dxF51x20l18LDSi5dfShkJHcMdp8sNoFPMV0VlfVnc7HYyOG5WdwbW4BVSzcc7NCdccMf9wmu2ONme06JGobbc(qbmXbcIxKdisMGGHtRQQfZIElgkB0BB1sqy)KBqq4is9jLNCdYqq7Ec6eei4dfWehiiEroGizccgoTQQwml6TyOSrVTvlbH9tUbbXRNxtXmISxGmKHG43LI3gbbDcA6sqNGabFOaM4abXlYbejtq08Ln9YHPqmwmu3i9wi4dfWV0PZx2XIKpuWQDxAgklQROuHHFPtNVSJfjFOGTbNtgklQROeqfmP5Ln)sNoF5KvOmBbNWlVZl7thee2p5geKkmCDfA1VM0qgcA9rqNGabFOaM4abXlYbejtqgMcXyXqDJ0BHGpua)YRVSPxQ5l5EeiYbSE98oPVmcomQROYtUHfc(qb8lD68Ln9s)Uu82iSWnOCaUAfqLZW8sfFzFU(YRV0VlfVnc7HYyOG5Wdwbu5mmVuXxQ0JTvUNFzZVSzcc7NCdcsfgUUcT6xtAidbT7jOtqGGpuatCGG4f5aIKjicoXfOdIXYySXc9CAgZlV(smCAvvTbubtAS4Tr8YRVSPxY(j7GceqnbZlv8LyWKcaxgwOegZlD68LcoXfOdIXYySXMXlv8LUGRVSzcc7NCdcsavWKgYqqZfjOtqGGpuatCGG4f5aIKjiA(sbN4c0bXyzm2yHEonJHGW(j3GGeqfmPHme00bbDcce8HcyIdeeVihqKmb50QQARWW1vOv)AsJvavodZlv8L9PJx605lNScLzl4eE5DEPl4kbH9tUbbr7o5gKHGMlqqNGabFOaM4abj4kqq6yrYhkuYyGWKZTIYuj3T0PSgFsP8KHYIay)Sccc7NCdcshls(qHsgdeMCUvuMk5ULoL14tkLNmuwea7NvqgcAkuc6ee2p5geKwduYbQgcce8HcyIdKHmeemu3i9e0jOPlbDcce8HcyIdeeVihqKmbPJfjFOG9qzmuWC4bcc7NCdccg4rFX0aaTKHGwFe0jiqWhkGjoqq8ICarYeebN4c0bXyzm2yB1(sNoFPGtCb6GySmgBSz8sfFzF6GGW(j3GGa3GYb4kziODpbDcce8HcyIdeeVihqKmbPPx20l18L(DP4TryHBq5aC12Q9LoD(YtRQQTcdxxHw9Rjn2wTVS5xE9LcoXfOdIXYySXMXlv8L376lB(LoD(s2pzhuGaQjyEPIVedMua4YWcLWyiiSFYniiQaTCyHGvcKHGMlsqNGabFOaM4abXlYbejtq6yrYhkypugdfmhE4LxFPMV0VlfVncBfgUUcT6xtAScGX3E51x20l97sXBJWc3GYb4QvavodZlv8Ln9sD8sx(sUhbICaRa6wAxgklhkJbJvWrVVuN)Y7FzZV0PZx20lfCIlqheJLXyJnJxQ4lz)KBypugdfmhEW63LI3gXlV(sbN4c0bXyzm2yZ4L35L9PJx28lBMGW(j3GGCOmgkyo8aziOPdc6ee2p5geKSwxkp5gfUvWeei4dfWehidbnxGGobbc(qbmXbcIxKdisMGO5l7yrYhky1UlndLf1vuougdfmhEGGW(j3GGWrK6tkp5gKHGMcLGobbc(qbmXbcIxKdisMGO2kUzXGA6Z5LkI6LUORee2p5geevGEOmgidbT(bbDcce8HcyIdeeVihqKmbrZx2XIKpuWQDxAgklQROCOmgkyo8WlV(snFzhls(qbR2DPzOSOUIcCdkhGRee2p5geeVEEnfZiYEbYqqtHrqNGW(j3GGGH6gMYjhGGabFOaM4aziOPRRe0jiqWhkGjoqq8ICarYeKtRQQDBNYQweCOeSTAjiSFYniiJEX2OOKYzhqgcA6QlbDcce8HcyIdeeVihqKmbzykeJfd1nkhkJbJfc(qbmbH9tUbbz0l2gfLuo7aYqgYqq6aHj3GGwFUQB)q3(09ERRkS7DrcsdwezO0qq6H7j3fT(jA9G97lFj66HxMvTRyEP6kEPcjgu5w6Oq(sb0d1Mca)sZwHxYTZw5bWV0RNdLGX(U7bMb8sD7RFFPolmTA1UIbWVK9tUXlvi1M(ElTAlQcwzfIrH0(UF39ZQ2vma(LUWlz)KB8sAAgJ9Dtq0kw1Kceef8Y(J7w)l1PqDJx2FTXaI3TcEP(z0A63lxuMJ(2J1V1lMS2s5j3Wly15IjR(lh6EUCuzxIHUlAfRAsbZLESaUlNyZLE8Dl6uOUrP)AJbeL(J7wV1Kv)7wbVuNahrllU9sD14L95QUkSx6Yx239979U47(DRGx2dZIidLM(9DRGx6YxQZmzO8L6uOUXlDGYyW8Yk3lyEzDnZl1jTIBVujeGGNCJxQTva0BV8UO1d(sSi7G4LCGFzBOva40p8HcA8Yg6tV(x2iP0xMvTSFE5OhEzpultZ52lx1xka)wRqG5j3WyF3k4LU8L6mtgkFzpDRqmT1xMMxg78sb43AfcmGvi8sDcqF5DBn6FzJKsF5bEPa8BTcbgWVKd8lh9WlnSkm3E5Q(sDcqF5DBn6FPNJyNxEGxIHb8dGF552lzmEdJ9D)UvWl7F9COem977wbV0LVSNGXa(L9)gM2k8YEkRm923TcEPlF5DH62b4xoSqjmLu9LE9GV3xQUIxIgubtAEjFsAo3SVBf8sx(Y7c1TdWVSUDqfI5L8jP5KG5LQIT(sTICf5C7Ln0dXlJDEzRbWVuDfVSNUviM2Q9DRGx6Yx2tWya)sDMbEz)CGQ5LZ(siWVCvFz)VlfVncZlz)KBqtZyF3k4LU8L9)gDGya8lv4(DP4TrOWF5SVuHZ(j3WQq063LI3gHc)Ln0dc4LSwT00ZhkyF3VBf8YEa9m4Bha)YdOUc4L(TE45Lhqzgg7l7jEpODmVm2WL6zrvTL(s2p5gMxUb9M9DZ(j3Wy1ka)wp8GsLYMEF3SFYnmwTcWV1dpoI6c3QScXWtUX7M9tUHXQva(TE4Xruxu3f)UvWlrcwRr)oVuWj(LNwvva)sZWJ5LhqDfWl9B9WZlpGYmmVKd8l1kaxQDNjdLVmnVeVbyF3SFYnmwTcWV1dpoI6IjyTg97umdpM3n7NCdJvRa8B9WJJOUODNCJ3n7NCdJvRa8B9WJJOUuHHRRqR(1KgnsvuAY9iqKdy965DsFzeCyuxrLNCdle8Hc4397wbVShqpd(2bWVe6aXTxozfE5OhEj7Nv8Y08sUJtkFOG9DZ(j3WGcNgrR25DZ(j3W4iQl(nmTvOuzLP)DZ(j3W4iQlDSi5df0i4kG6qzmuWC4bn6yAlGAykeJvnfMPCO7ITqWhkGD60OfO0YWcLWyShkJHcMdpORIOA6ExomfIXocoPLvTiAZWcbFOaU53n7NCdJJOU0XIKpuqJGRaQgCozOSOUIsavWKgn6yAlGsZM0CykeJnGkysJfc(qbStN(DP4TrydOcM0yfaJV50PFxkEBe2aQGjnwbu5mmkozfkZwWj40PFxkEBe2aQGjnwbu5mmk6cU287M9tUHXrux6yrYhkOrWvaL2DPzOSOUIsfgwJoM2cO0CykeJfd1nsVfc(qb8v)Uu82iSvy46k0QFnPXkGkNH5oUWv1wXnlgutFokEVRxBsZowK8Hc2gCozOSOUIsavWKgNo97sXBJWgqfmPXkGkNH5o66AZVB2p5gghrDPJfjFOGgbxbuA3LMHYI6kkhkJHcMdpOrhtBbuDSi5dfShkJHcMdpCTj1wXT7Oq1HlhMcXyvtHzkh6Uyle8HcyDEFU287M9tUHXrux6yrYhkOrWvaL2DPzOSOUIcCdkhGRA0X0wa1WuiglgQBKEle8Hc4RAomfIXEOzGlQTIBwi4dfWx97sXBJWc3GYb4QvavodZDAsPhBRCpRZ7R5RQTIBwmOM(CuSpxF3SFYnmoI6shls(qbncUcOAW5KHYI6kkyw0BXqzJEn6yAlGAykeJfZIElgkB0BHGpuaFvZowK8HcwT7sZqzrDfLdLXqbZHhUQzhls(qbR2DPzOSOUIsfg(QFxkEBewml6TyOSrVTv77M9tUHXrux6yrYhkOrWvavdoNmuwuxrPUviM2QgDmTfqnmfIXw3ketB1cbFOa(QMNwvvBDRqmTvBR23n7NCdJJOUGtJOv78Uz)KByCe1fptPf2p5gfAAgncUcO87sXBJqJufLsp2kGkNHbLRVB2p5gghrDrB67T0QTOkyLvignsvuQTIBwmOM(Cue1964DZ(j3W4iQlEMslSFYnk00mAeCfqHzrVfdLn61ivrnmfIXIzrVfdLn6TqWhkGV2uhls(qbBdoNmuwuxrbZIElgkB070jgoTQQwml6TyOSrVTvBZVB2p5gghrDr0gf2p5gfAAgncUcOWqDJ0RrQIAykeJfd1nsVfc(qb87M9tUHXruxeTrH9tUrHMMrJGRaQyfvM(UF3SFYnmw)Uu82iqvHHRRqR(1KgnsvuA20WuiglgQBKEle8HcyNo7yrYhky1UlndLf1vuQWWoD2XIKpuW2GZjdLf1vucOcM00StNtwHYSfCc3PpD8Uz)KByS(DP4Tr4iQlvy46k0QFnPrJuf1WuiglgQBKEle8Hc4RnPj3JaroG1RN3j9LrWHrDfvEYnSqWhkGD6Sj)Uu82iSWnOCaUAfqLZWOyFUE1VlfVnc7HYyOG5Wdwbu5mmkQ0JTvUNBU53n7NCdJ1VlfVnchrDjGkysJgPkkbN4c0bXyzm2yHEonJ5kgoTQQ2aQGjnw82iU2e7NSdkqa1emkIbtkaCzyHsymoDk4exGoiglJXgBgk6cU287M9tUHX63LI3gHJOUeqfmPrJufLMcoXfOdIXYySXc9CAgZ7M9tUHX63LI3gHJOUODNCdnsvuNwvvBfgUUcT6xtAScOYzyuSpD405KvOmBbNWDCbxF3SFYnmw)Uu82iCe1LwduYbQAeCfq1XIKpuOKXaHjNBfLPsUBPtzn(Ks5jdLfbW(zfVB2p5ggRFxkEBeoI6sRbk5avZ7(DZ(j3WyXSO3IHYg9OWSO3IHYg9AKQOuBf3uev)W1RnPzhls(qb7HYyOG5WdoDQPFxkEBe2dLXqbZHhScGX3A(DZ(j3WyXSO3IHYg9oI6chrQpP8KBOrQIcdNwvvlMf9wmu2O32Q9DZ(j3WyXSO3IHYg9oI6IxpVMIzezVGgPkkmCAvvTyw0BXqzJEBR2397M9tUHXIH6gPhfg4rFX0aaTAKQO6yrYhkypugdfmhE4DZ(j3WyXqDJ07iQlWnOCaUQrQIsWjUaDqmwgJn2wToDk4exGoiglJXgBgk2NoE3SFYnmwmu3i9oI6IkqlhwiyLGgPkQMAst)Uu82iSWnOCaUAB1605Pvv1wHHRRqR(1KgBR2MVk4exGoiglJXgBgkEVRn70j7NSdkqa1emkIbtkaCzyHsymVB2p5gglgQBKEhrD5qzmuWC4bnsvuDSi5dfShkJHcMdpCvt)Uu82iSvy46k0QFnPXkagF7At(DP4TryHBq5aC1kGkNHrXM0Hl5EeiYbScOBPDzOSCOmgmwbh9QZVVzNoBsWjUaDqmwgJn2muK9tUH9qzmuWC4bRFxkEBexfCIlqheJLXyJnJ70NoAU53n7NCdJfd1nsVJOUK16s5j3OWTc(DZ(j3WyXqDJ07iQlCeP(KYtUHgPkkn7yrYhky1UlndLf1vuougdfmhE4DZ(j3WyXqDJ07iQlQa9qzmOrQIsTvCZIb10NJIOCrxF3SFYnmwmu3i9oI6IxpVMIzezVGgPkkn7yrYhky1UlndLf1vuougdfmhE4QMDSi5dfSA3LMHYI6kkWnOCaU(UvWlz)KBySyOUr6De1fvGweTg9AKQOgMcXyXqDJYHYyWyHGpuaFvt)Uu82iSWnOCaUAfaJVDTjVEwOemO6ZPZMeCIlqheJTUDqfIXMHI666vbN4c0bXyzm2yZqrDDT5MF3SFYnmwmu3i9oI6cgQBykNCG3n7NCdJfd1nsVJOUm6fBJIskNDGgPkQtRQQDBNYQweCOeSTAF3k4LSFYnmwmu3i9oI6IkqlIwJEnsvu1TdQqmwCAgo8GI6QdNopTQQ2TDkRArWHsW2Q9DRGxY(j3WyXqDJ07iQlDqOeuBPfbmcGhnsvu1TdQqmwCAgo8GI6QJ3n7NCdJfd1nsVJOUm6fBJIskNDGgPkQHPqmwmu3OCOmgmwi4dfWV73n7NCdJnwrLPO6GqjO2slcyeapAKQOgMcXyRBfIPTAHGpuaF90QQA1kaTSaWw82iUozfuu33n7NCdJnwrLPoI6IkqlIwJEnsvuDSi5dfSn4CYqzrDfL6wHyARxBYRNfkbdQ(C6SjbN4c0bXyRBhuHySzOOUUEvWjUaDqmwgJn2muuxxBU53TcEj7NCdJnwrLPoI6IkqlIwJEnsvudtHySQaTuzZaIBwi4dfWxBYRNfkbdQ(C6SjbN4c0bXyRBhuHySzOOUUEvWjUaDqmwgJn2muuxxBU53n7NCdJnwrLPoI6IkqlhwiyLGgPkkn7yrYhkyBW5KHYI6kk1TcX0wV2e7NSdkqa1emkIbtkaCzyHsymoDk4exGoiglJXgBgkEVRn)Uz)KBySXkQm1ruxWap6lMgaOvJufvhls(qb7HYyOG5WdVB2p5ggBSIktDe1LSwxkp5gfUvWVB2p5ggBSIktDe1f4guoax1ivrX(j7GceqnbJI6ETjnfCIlqheJLXyJf650mgNofCIlqheJLXyJTvBZx1SJfjFOGTbNtgklQROu3ketB9DZ(j3WyJvuzQJOUCOmgkyo8GgPkQowK8Hc2dLXqbZHhE3SFYnm2yfvM6iQlQa9qzmOrQIsTvCZIb10NJIOCrxF3SFYnm2yfvM6iQlWnOCaUQrQIsZHPqm2dndCrTvCZcbFOa(QMDSi5dfSn4CYqzrDffml6TyOSr)vbN4c0bXyzm2yZqr2p5gw4guoaxT(DP4Tr8Uz)KBySXkQm1rux4is9jLNCdnsvunnmfIXIH6gLdLXGXcbFOa2Ptn7yrYhkyBW5KHYI6kk1TcX0wD6uTvCZIb10NZDU3vNopTQQ2kmCDfA1VM0yfqLZWChD08vn7yrYhky1UlndLf1vuougdfmhE4QMDSi5dfSn4CYqzrDffml6TyOSr)7M9tUHXgROYuhrDXRNxtXmISxqJufvtdtHySyOUr5qzmySqWhkGD6uZowK8Hc2gCozOSOUIsDRqmTvNovBf3Syqn95CN7DT5RA2XIKpuWQDxAgklQROuHHVQzhls(qbR2DPzOSOUIYHYyOG5Wdx1SJfjFOGTbNtgklQROGzrVfdLn6F3SFYnm2yfvM6iQlWnOCaUQrQIAykeJ9qZaxuBf3SqWhkGVk4exGoiglJXgBgkY(j3Wc3GYb4Q1VlfVnI3n7NCdJnwrLPoI6cgQBykNCG3TcEj7NCdJnwrLPoI6IkqlIwJEnsvuAomfIXw3ketB1cbFOa(QGtCb6GyS1TdQqm2mu0RNfkbJoxxxVomfIXIH6gLdLXGXcbFOa(DZ(j3WyJvuzQJOUOc0dLXGgPkQ62bviglondhEqrD1HtNNwvv72oLvTi4qjyB1(UvWlz)KBySXkQm1ruxubAr0A0RrQIQUDqfIXItZWHhuuxD40ztNwvv72oLvTi4qjyB1EvZHPqm26wHyARwi4dfWn)UvWlz)KBySXkQm1rux6GqjO2slcyeapAKQOQBhuHyS40mC4bf1vhVB2p5ggBSIktDe1LrVyBuus5Sd0ivrnmfIXIH6gLdLXGXcbFOaMGWTJ(vqqqYAlLNCJ(xWQdzidHa]] )


end
