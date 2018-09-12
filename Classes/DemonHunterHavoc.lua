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
                    return talent.demonic.enabled and ( buff.metamorphosis.duration ~= 30 and buff.metamorphosis.duration > ( action.eye_beam.cast + 8 ) )
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
                    if buff.metamorphosis.up then
                        buff.metamorphosis.duration = buff.metamorphosis.remains + 8
                        buff.metamorphosis.expires = buff.metamorphosis.expires + 8
                    else
                        applyBuff( "metamorphosis", action.eye_beam.cast + 8 )
                        buff.metamorphosis.duration = action.eye_beam.cast + 8
                    end
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
    
        potion = "battle_potion_of_agility",
    
        package = "Havoc",
    } )


    spec:RegisterPack( "Havoc", 20180911.2122, [[dOeq3aqiufpsc0MueFscPAusuoLeQvbrqVIsQzrsCljQAxu5xqWWijDmi0YqvYZqvQPbrY1OKyBusY3GiQXjb4CqeX6KOI5jH4EqY(iP6GuskwijLhcrknrkjvxeIi1gHis(iLKsJuIkDsjKWkLiZeIaDtjK0oHugkePAPsa9uvAQqQUkeP4Rsir7fQ)svdMuhMyXQ4XkmzexgSzu5ZKWOPeNw0RLGMns3ws7w43knCuvhhIawokpNIPl11PuBxr9DfPXdrOZdrTEjKY8jr7xvJreJo(sKgWOXlvrSaufjbreD8I38crKQaW3gz(a(Yxgfkka8nKkGVLRmVd8LVGmDfcgD81S2SbGVw6MVPCqabfzBX(4gBfbtwTPsNBmycxJGjRdeo09GWHtkpbMrGpB5skyqaPZGcusIbbKEb6T6qDdF5AhnW8LRmVdNjRd89yN0UOiWh8LinGrJxQIybOkscIi64fVvTaqejJVg(WaJMvqYiz8LaMb(wWxxUY8oETvhQB86Y1oAG9Lk4RT0nFt5GackY2I9Xn2kcMSAtLo3yWeUgbtwhiCO7bHdNuEcmJaF2YLuWGasNbfOKedci9c0B1H6g(Y1oAG5lxzEhotwhFPc(6lWVH6byVgrev518svelGxx(xJiILJQi1Rr6f1V0xQGVUOuyrgkmLZxQGVU8VgPXKHIxB1H6gVwnQqaZRRsHG51110VgjLnd5xRacGjDUXR5BZakYVUarZQ91ewodXRLG8A7Gpdi5OLdfu51tTKdlVEAsPVoR8Lr)62c8AKa2cnBKF9Y9Agm2AfcI05gg3x6lvWxJ0ArcfGPC(sf81L)1wnecqEns7gg7k86IQOihUVubFD5FDbc1DgiVUfMcO9j3RhwGrHVMBzVgnOcM08A5K0Sr29Lk4Rl)RlqOUZa511DgQq0Vwojn7emVMJT1xZNLllBKF9ulq86y7xBBaYR5w2RlQBfI2U6WxAAAdgD8nwwvOy0XOHigD8fc5qbcwn8DWYgyPGVTqHOD1TcrBxDqihkqE9KxFS54C8zaFHbehzNgVEYR7ScVw9xJi(kJo3aFNHqbWzt9mOzG04gJgVWOJVqihkqWQHVdw2alf8TSxplSuouWnvYodfEUL5RBfI2U(ALkFDluiAhhq9vX0adzheYHcKxx8RN86YE9WIWuaMxJ61861kv(6YEntsIhMHOD1DgQq0UmET6VgrvF9KxZKK4HziANqigxgVw9xJOQVU4xxm(kJo3aF5aQNzBSGBmA8gJo(cHCOabRg(oyzdSuWxEE9SWs5qb3uj7mu45wMVUviA76RN86YETm6Cg8qa1emVw9xtatYaIVfMcOnVwPYxZKK4HziANqigxgVw9xZBvFDX4Rm6Cd8LdO(JWyIca3y0qkm64leYHceSA47GLnWsbFNfwkhk4ouHaEIedaFLrNBGVeqAlEZua4JBmAwbJo(kJo3aFZADPsNB4fBMGVqihkqWQHBmAwfgD8fc5qbcwn8DWYgyPGVYOZzWdbutW8A1FnIVEYRl7188AMKepmdr7ecX4aKyAAZRvQ81mjjEygI2jeIXzZ)1f)6jVMNxplSuouWnvYodfEUL5RBfI2UIVYOZnWxazWFaPIBmAizm64leYHceSA47GLnWsbFNfwkhk4ouHaEIedaFLrNBGVhQqaprIbGBmAfagD8fc5qbcwn8DWYgyPGV886wOq0U6wHOTRoiKdfiVEYR551TqHODeOUH)qfcyCqihkqE9KxlfnGLn4SJZAhe)WISgheYHce8vgDUb(YbupZ2yb3y0qsWOJVqihkqWQHVdw2alf8LZMHSJaC5i7xRoQxJuQIVYOZnWxoGEOcbWngnevfJo(cHCOabRg(oyzdSuWxEEDluiA3HMbXZzZq2bHCOa51tEnpVEwyPCOGBQKDgk8ClZtewHEdvmwE9KxZKK4HziANqigxgVw9xp2Ls2Pb(kJo3aFbKb)bKkUXOHiIy0XxiKdfiy1W3blBGLc(w2RBHcr7iqDd)HkeW4GqouG8ALkFnpVEwyPCOGBQKDgk8ClZx3keTD91kv(AoBgYocWLJSFDrEnVv91kv(6JnhNRcTuxgFlRjnoguLmmVUiV2kVU4xp51886zHLYHco(7sZqHNBz(dviGNiXaE9KxZZRNfwkhk4MkzNHcp3Y8eHvO3qfJf8vgDUb(krKwsQ05g4gJgI8cJo(cHCOabRg(oyzdSuW3YEDluiAhbQB4puHagheYHcKxRu5R551ZclLdfCtLSZqHNBz(6wHOTRVwPYxZzZq2raUCK9RlYR5TQVU4xp51886zHLYHco(7sZqHNBz(k0YRN8AEE9SWs5qbh)DPzOWZTm)HkeWtKyaVEYR551ZclLdfCtLSZqHNBzEIWk0BOIXc(kJo3aFhwK14nnlleWngne5ngD8fc5qbcwn8DWYgyPGVTqHODhAgepNndzheYHcKxp51mjjEygI2jeIXLXRv)1JDPKDAGVYOZnWxazWFaPIBmAiIuy0Xxz05g4lbQBy8NSb8fc5qbcwnCJrdrRGrhFHqouGGvdFhSSbwk4BDNHkeTJKMwIb8A1FnIw51kv(6JnhNBTB)Y5zsOaC28Xxz05g4lhqpuHa4gJgIwfgD8fc5qbcwn8DWYgyPGVTqHODeOUH)qfcyCqihkqWxz05g4BBHTt9kOsod4g34lb4eBAJrhJgIy0Xxz05g4Ry3Rx6wgfIVqihkqWQHBmA8cJo(cHCOabRg(oluBaFBHcr74sMP9h6UeheYHcKxRu5Rnq7pByBCDcmEPQhP4pETsLV2WhOuFlmfqBChQqaprIbG4Rvh1Rl718(1L)1TqHODntsQF58m7mCqihkqEDX4Rm6Cd8DwyPCOa(olmFivaFpuHaEIeda3y04ngD8fc5qbcwn8DwO2a(YZRl71886wOq0UaQGjnoiKdfiVwPYxp2Ls2PHlGkysJJbcb5xRu5Rh7sj70WfqfmPXXGQKH51Q)6wykG21zf896jj8ALkF9yxkzNgUaQGjnoguLmmVw9xBvQ(6IXxz05g47SWs5qb8Dwy(qQa(ovYodfEUL5dOcM0GBmAifgD8fc5qbcwn8DwO2a(YZRBHcr7iqDJC4GqouG86jVESlLStdxfAPUm(wwtACmOkzyEDrETv96jVMZMHSJaC5i7xR(R5TQVEYRl71886zHLYHcUPs2zOWZTmFavWKMxRu5Rh7sj70WfqfmPXXGQKH51f51iQ6RlgFLrNBGVZclLdfW3zH5dPc4l)DPzOWZTmFfAb3y0ScgD8fc5qbcwn8DwO2a(olSuouWDOcb8ejgWRN86YEnNnd5xxKxJKTYRl)RBHcr74sMP9h6UeheYHcKxJe(AEP6RlgFLrNBGVZclLdfW3zH5dPc4l)DPzOWZTm)HkeWtKya4gJMvHrhFHqouGGvdFNfQnGVTqHODeHvO3qfJfheYHcKxp51886zHLYHco(7sZqHNBz(dviGNiXaE9KxZZRNfwkhk44VlndfEUL5RqlVEYRh7sj70WrewHEdvmwC28Xxz05g47SWs5qb8Dwy(qQa(ovYodfEUL5jcRqVHkgl4gJgsgJo(cHCOabRg(oluBaFBHcr7QBfI2U6GqouG86jVMNxFS54C1TcrBxD28Xxz05g47SWs5qb8Dwy(qQa(ovYodfEUL5RBfI2UIBmAfagD8vgDUb(ssdZMFJVqihkqWQHBmAijy0Xxz05g47ydJDf8vrroWxiKdfiy1WngnevfJo(cHCOabRg(oyzdSuWxfdIJbvjdZRr9AvXxz05g47qOuVm6Cdpnnn(stt7dPc47yxkzNg4gJgIiIrhFHqouGGvdFhSSbwk4lNndzhb4Yr2VwDuVM3wbFLrNBGV8ZrHEB(EoMOOcrJBmAiYlm64leYHceSA47GLnWsbFBHcr7icRqVHkgloiKdfiVEYRl71ZclLdfCtLSZqHNBzEIWk0BOIXYRvQ81e4yZX5icRqVHkgloB(VUy8vgDUb(oek1lJo3WtttJV000(qQa(sewHEdvmwWngne5ngD8fc5qbcwn8DWYgyPGVTqHODeOUroCqihkqWxz05g4lZo8YOZn80004lnnTpKkGVeOUroWngnerkm64leYHceSA4Rm6Cd8LzhEz05gEAAA8LMM2hsfW3yzvHIBCJV8zWyRhPXOJrdrm64leYHceSA4gJgVWOJVqihkqWQHBmA8gJo(cHCOabRgUXOHuy0XxiKdfiy1WngnRGrhFLrNBGV83o3aFHqouGGvd3y0Skm64Rm6Cd8TcTuxgFlRjn4leYHceSA4g34lryf6nuXybJogneXOJVqihkqWQHVdw2alf8LZMH8Rvh1RlavF9Kxx2R551ZclLdfChQqaprIb8ALkFnpVESlLStd3HkeWtKyaogieKFDX4Rm6Cd8LiSc9gQySGBmA8cJo(cHCOabRg(oyzdSuWxcCS54CeHvO3qfJfNnF8vgDUb(krKwsQ05g4gJgVXOJVqihkqWQHVdw2alf8LahBoohryf6nuXyXzZhFLrNBGVdlYA8MMLfc4g347yxkzNgy0XOHigD8fc5qbcwn8DWYgyPGV886YEDluiAhbQBKdheYHcKxRu5RNfwkhk44VlndfEUL5RqlVwPYxplSuouWnvYodfEUL5dOcM086IFTsLVUfMcODDwbFVEscVUiVMxwbFLrNBGVvOL6Y4BznPb3y04fgD8fc5qbcwn8DWYgyPGVTqHODeOUroCqihkqE9KxFS54CvOL6Y4BznPXzZhFLrNBGVvOL6Y4BznPb3y04ngD8fc5qbcwn8DWYgyPGVmjjEygI2jeIXbiX00Mxp51e4yZX5cOcM04i7041tEDzVwgDodEiGAcMxR(RjGjzaX3ctb0MxRu5Rzss8WmeTtieJlJxR(RTkvFDX4Rm6Cd8nGkysdUXOHuy0XxiKdfiy1W3blBGLc(YZRzss8WmeTtieJdqIPPn4Rm6Cd8nGkysdUXOzfm64leYHceSA47GLnWsbFp2CCUk0sDz8TSM04yqvYW8A1FnVSYRvQ81TWuaTRZk471ts41f51wLQ4Rm6Cd8L)25g4gJMvHrhFHqouGGvdFdPc4RcHcdHsbMXF2nWxz05g4RcHcdHsbMXF2nWngnKmgD8fc5qbcwn8nKkGVuBtZwBJxXsjq45tTRIcaFLrNBGVuBtZwBJxXsjq45tTRIca34gFjqDJCGrhJgIy0XxiKdfiy1W3blBGLc(kJoNbpeqnbZRv)1eWKmG4BHPaAZRvQ81mjjEygI2jeIXLXRv)18wv8vgDUb(Ybu)rymrbGBmA8cJo(cHCOabRg(oyzdSuW3zHLYHcUdviGNiXaWxz05g4lbK2I3mfa(4gJgVXOJVqihkqWQHVdw2alf8LNxFS54CvOL6Y4BznPXbiXgccq8hK9eOUroE9Kxx2Rzss8WmeTtieJZM)RvQ81mjjEygI2jeIXLXRv)18YkVUy8vgDUb(cid(divCJrdPWOJVqihkqWQHVdw2alf8DwyPCOG7qfc4jsmGxp51886XUuYonCvOL6Y4BznPXXaHG8RN86YE9yxkzNgoazWFaP6yqvYW8A1FDzV2kVU8VwkAalBWXG5LoNHc)HkeW4ysu4RrcFnVFDXVwPYxx2Rzss8WmeTtieJlJxR(Rh7sj7041tEntsIhMHODcHyCz86I8AEzLxx8RlgFLrNBGVhQqaprIbGBmAwbJo(kJo3aFZADPsNB4fBMGVqihkqWQHBmAwfgD8fc5qbcwn8DWYgyPGVC2mKFDrEnsP6RvQ81L96JnhNRcTuxgFlRjnoYonE9KxZzZq2raUCK9Rvh1RrkvFDX4Rm6Cd8LdOhQqaCJrdjJrhFHqouGGvdFhSSbwk4BzVUfkeT7qZG45Szi7GqouG8ALkFnNndzhb4Yr2VUiVM3Q(ALkF9XMJZvHwQlJVL1KghdQsgMxxKxBLxx8RN8AEE9SWs5qbh)DPzOWZTm)HkeWtKya4Rm6Cd8vIiTKuPZnWngTcaJo(cHCOabRg(oyzdSuW3YEDluiA3HMbXZzZq2bHCOa51kv(AoBgYocWLJSFDrEnVv91f)6jVMNxplSuouWXFxAgk8ClZxHwE9KxZZRNfwkhk44VlndfEUL5puHaEIedaFLrNBGVdlYA8MMLfc4gJgscgD8fc5qbcwn8DWYgyPGVTqHODeOUH)qfcyCqihkqE9KxZZRh7sj70Wbid(divhdecYVEYRl71dlctbyEnQxZRxRu5Rl71mjjEygI2v3zOcr7Y41Q)Aev91tEntsIhMHODcHyCz8A1FnIQ(6IFDX4Rm6Cd8LdOEMTXcUXOHOQy0XxiKdfiy1W3blBGLc(YZRBHcr7iqDd)HkeW4GqouG86jVMNxp2Ls2PHdqg8hqQogieKF9KxlfnGLn4SJZAhe)WISghtIcFT6Vwv8vgDUb(YbupZ2yb3y0qerm64Rm6Cd8La1nm(t2a(cHCOabRgUXOHiVWOJVqihkqWQHVdw2alf89yZX5w72VCEMekaNnF8vgDUb(2wy7uVcQKZaUXOHiVXOJVqihkqWQHVdw2alf8TfkeTJa1n8hQqaJdc5qbc(kJo3aFBlSDQxbvYza34g347mWm5gy04LQiwaQwa8wvhVqeXcaFNkSidfg8TO0QParROanR2Y51VgDlWRZk)L1VMBzVUOtaoXM2f9xZaKa2jdiV2Sv41IDVvPbYRhwKqbyCFjKGzaVgXY51inHXMp)L1a51YOZnEDrxS71lDlJcl6UVesWmGxJiILZRrAcJnF(lRbYRLrNB86Io)CuO3MVNJjkQq0fD3x6lvuu5VSgiV2QETm6CJxtttBCFj8LpB5skGVf81LRmVJxB1H6gVUCTJgyFPc(AlDZ3uoiGGISTyFCJTIGjR2uPZngmHRrWK1bch6Eq4WjLNaZiWNTCjfmiG0zqbkjXGasVa9wDOUHVCTJgy(YvM3HZK1XxQGV(c8BOEa2RrervEnVufXc41L)1iIy5Oks9AKEr9l9Lk4RlkfwKHct58Lk4Rl)RrAmzO41wDOUXRvJkeW86QuiyEDDn9RrszZq(1kGaysNB8A(2mGI8Rlq0SAFnHLZq8AjiV2o4ZasoA5qbvE9ul5WYRNMu6RZkFz0VUTaVgjGTqZg5xVCVMbJTwHGiDUHX9L(sf81iTwKqbykNVubFD5FTvdHaKxJ0UHXUcVUOkkYH7lvWxx(xxGqDNbYRBHPaAFY96Hfyu4R5w2RrdQGjnVwojnBKDFPc(6Y)6ceQ7mqEDDNHke9RLtsZobZR5yB918z5YYg5xp1ceVo2(12gG8AUL96I6wHOTRUV0xQGVgjnseg2nqE9b4wg86Xwps)6dOidJ71wnJbWVnVo2O8wewLZM(Az05gMxVbfz3xsgDUHXXNbJTEKgfhvmf(LKrNByC8zWyRhPTgfcITIkeT05gFjz05gghFgm26rARrHa3UKVubF9ne(glB)AMKKxFS54aYRnT0MxFaULbVES1J0V(akYW8AjiVMpdkp)T7mu8608AYgG7ljJo3W44ZGXwpsBnkemHW3yzBVPL28LKrNByC8zWyRhPTgfc83o34ljJo3W44ZGXwpsBnkeQql1LX3YAsZx6lvWxJKgjcd7giVgMbgYVUZk862c8Az0l71P51YSKu5qb3xsgDUHbLy3Rx6wgf(LKrNBySgfcZclLdfujKkG6qfc4jsmavMfQnGQfkeTJlzM2FO7sCqihkquQ0aT)SHTX1jW4LQEKI)qPsdFGs9TWuaTXDOcb8ejgaIQJQmEx(wOq0UMjj1VCEMDgoiKdfif)LKrNBySgfcZclLdfujKkGAQKDgk8ClZhqfmPrLzHAdO4PmEAHcr7cOcM04GqouGOu5yxkzNgUaQGjnogieKvQCSlLStdxavWKghdQsgg1BHPaAxNvW3RNKGsLJDPKDA4cOcM04yqvYWOUvPAXFjz05ggRrHWSWs5qbvcPcO4VlndfEUL5RqlQmluBafpTqHODeOUroCqihkqMm2Ls2PHRcTuxgFlRjnoguLmmfXQMWzZq2raUCKT68w1jLXZSWs5qb3uj7mu45wMpGkysJsLJDPKDA4cOcM04yqvYWueevT4VKm6CdJ1OqywyPCOGkHubu83LMHcp3Y8hQqaprIbOYSqTbuZclLdfChQqaprIbmPmoBgYfbjBLY3cfI2XLmt7p0DjoiKdfiiH8s1I)sYOZnmwJcHzHLYHcQesfqnvYodfEUL5jcRqVHkglQmluBavluiAhryf6nuXyXbHCOazcpZclLdfC83LMHcp3Y8hQqaprIbmHNzHLYHco(7sZqHNBz(k0YKXUuYonCeHvO3qfJfNn)VKm6CdJ1OqywyPCOGkHubutLSZqHNBz(6wHOTRQmluBavluiAxDRq02vheYHcKj8CS54C1TcrBxD28)sYOZnmwJcbsAy287VKm6CdJ1OqySHXUc(QOihFjz05ggRrHWqOuVm6CdpnnTkHubuJDPKDAOsYHsXG4yqvYWGs1VKm6CdJ1OqGFok0BZ3ZXefviAvsouC2mKDeGlhzRokEBLVKm6CdJ1OqyiuQxgDUHNMMwLqQakIWk0BOIXIkjhQwOq0oIWk0BOIXIdc5qbYKYMfwkhk4MkzNHcp3Y8eHvO3qfJfLkjWXMJZrewHEdvmwC28l(ljJo3Wynkey2HxgDUHNMMwLqQakcu3ihQKCOAHcr7iqDJC4GqouG8LKrNBySgfcm7WlJo3WtttRsivavSSQq)sFjz05gg3yxkzNgOQql1LX3YAsJkjhkEkRfkeTJa1nYHdc5qbIsLZclLdfC83LMHcp3Y8vOfLkNfwkhk4MkzNHcp3Y8bubtAkwPYwykG21zf896jjueEzLVKm6CdJBSlLStdRrHqfAPUm(wwtAuj5q1cfI2rG6g5WbHCOazYXMJZvHwQlJVL1KgNn)VKm6CdJBSlLStdRrHqavWKgvsoumjjEygI2jeIXbiX00Mje4yZX5cOcM04i70yszYOZzWdbutWOobmjdi(wykG2OujtsIhMHODcHyCzOUvPAXFjz05gg3yxkzNgwJcHaQGjnQKCO4HjjXdZq0oHqmoajMM28LKrNByCJDPKDAynke4VDUHkjhQJnhNRcTuxgFlRjnoguLmmQZlROuzlmfq76Sc(E9KekIvP6xsgDUHXn2Ls2PH1OqW2a(SHQkHubukekmekfyg)z34ljJo3W4g7sj70WAuiyBaF2qvLqQakQTPzRTXRyPei88P2vrb8L(sYOZnmoIWk0BOIXckIWk0BOIXIkjhkoBgYQJQauDsz8mlSuouWDOcb8ejgGsL8m2Ls2PH7qfc4jsmahdecYf)LKrNByCeHvO3qfJfRrHGerAjPsNBOsYHIahBoohryf6nuXyXzZ)ljJo3W4icRqVHkglwJcHHfznEtZYcbvsoue4yZX5icRqVHkgloB(FPVKm6CdJJa1nYbkoG6pcJjkavsouYOZzWdbutWOobmjdi(wykG2OujtsIhMHODcHyCzOoVv9ljJo3W4iqDJCynkeiG0w8MPaWxLKd1SWs5qb3HkeWtKyaFjz05gghbQBKdRrHaGm4pGuvj5qXZXMJZvHwQlJVL1KghGeBiiaXFq2tG6g5yszmjjEygI2jeIXzZxPsMKepmdr7ecX4YqDEzLI)sYOZnmocu3ihwJcHdviGNiXauj5qnlSuouWDOcb8ejgWeEg7sj70WvHwQlJVL1KghdecYtkBSlLStdhGm4pGuDmOkzyuVmRuEPObSSbhdMx6Cgk8hQqaJJjrHiH8UyLklJjjXdZq0oHqmUmuFSlLStJjmjjEygI2jeIXLrr4LvkU4VKm6CdJJa1nYH1OqiR1LkDUHxSzYxsgDUHXrG6g5WAuiWb0dviGkjhkoBgYfbPuvPYYo2CCUk0sDz8TSM04i70ycNndzhb4Yr2QJcPuT4VKm6CdJJa1nYH1OqqIiTKuPZnuj5qvwluiA3HMbXZzZq2bHCOarPsoBgYocWLJSlcVvvPYJnhNRcTuxgFlRjnoguLmmfXkfpHNzHLYHco(7sZqHNBz(dviGNiXa(sYOZnmocu3ihwJcHHfznEtZYcbvsouL1cfI2DOzq8C2mKDqihkquQKZMHSJaC5i7IWBvlEcpZclLdfC83LMHcp3Y8vOLj8mlSuouWXFxAgk8ClZFOcb8ejgWxsgDUHXrG6g5WAuiWbupZ2yrLKdvluiAhbQB4puHagheYHcKj8m2Ls2PHdqg8hqQogieKNu2WIWuagu8sPYYyss8WmeTRUZqfI2LH6iQ6eMKepmdr7ecX4YqDevT4I)sYOZnmocu3ihwJcboG6z2glQKCO4PfkeTJa1n8hQqaJdc5qbYeEg7sj70Wbid(divhdecYtKIgWYgC2XzTdIFyrwJJjrHQR6xsgDUHXrG6g5WAuiqG6gg)jB4ljJo3W4iqDJCynkeAlSDQxbvYzqLKd1XMJZT2TF58mjuaoB(FPc(Az05gghbQBKdRrHahq9mBJfvsou1DgQq0osAAjgG6iAfLkp2CCU1U9lNNjHcWzZ)lvWxlJo3W4iqDJCynkeMHqbWzt9mOzG0QKCOQ7muHODK00sma1r0kFjz05gghbQBKdRrHqBHTt9kOsodQKCOAHcr7iqDd)HkeW4GqouG8L(sYOZnmUyzvHIAgcfaNn1ZGMbsRsYHQfkeTRUviA7Qdc5qbYKJnhNJpd4lmG4i70ysNvqDe)sYOZnmUyzvHAnke4aQNzBSOsYHQSzHLYHcUPs2zOWZTmFDRq02vLkBHcr74aQVkMgyi7GqouGu8KYgweMcWGIxkvwgtsIhMHOD1DgQq0UmuhrvNWKK4HziANqigxgQJOQfx8xsgDUHXflRkuRrHahq9hHXefGkjhkEMfwkhk4MkzNHcp3Y81TcrBxNuMm6Cg8qa1emQtatYaIVfMcOnkvYKK4HziANqigxgQZBvl(ljJo3W4ILvfQ1OqGasBXBMcaFvsouZclLdfChQqaprIb8LKrNByCXYQc1AuiK16sLo3Wl2m5ljJo3W4ILvfQ1Oqaqg8hqQQKCOKrNZGhcOMGrDeNugpmjjEygI2jeIXbiX00gLkzss8WmeTtieJZMFXt4zwyPCOGBQKDgk8ClZx3keTD9ljJo3W4ILvfQ1Oq4qfc4jsmavsouZclLdfChQqaprIb8LKrNByCXYQc1AuiWbupZ2yrLKdfpTqHOD1TcrBxDqihkqMWtluiAhbQB4puHagheYHcKjsrdyzdo74S2bXpSiRXbHCOa5ljJo3W4ILvfQ1OqGdOhQqavsouC2mKDeGlhzRokKs1VKm6CdJlwwvOwJcbazWFaPQsYHINwOq0UdndINZMHSdc5qbYeEMfwkhk4MkzNHcp3Y8eHvO3qfJLjmjjEygI2jeIXLH6JDPKDA8LKrNByCXYQc1AuiirKwsQ05gQKCOkRfkeTJa1n8hQqaJdc5qbIsL8mlSuouWnvYodfEUL5RBfI2UQujNndzhb4Yr2fH3QQu5XMJZvHwQlJVL1KghdQsgMIyLINWZSWs5qbh)DPzOWZTm)HkeWtKyat4zwyPCOGBQKDgk8ClZtewHEdvmw(sYOZnmUyzvHAnkegwK14nnlleuj5qvwluiAhbQB4puHagheYHceLk5zwyPCOGBQKDgk8ClZx3keTDvPsoBgYocWLJSlcVvT4j8mlSuouWXFxAgk8ClZxHwMWZSWs5qbh)DPzOWZTm)HkeWtKyat4zwyPCOGBQKDgk8ClZtewHEdvmw(sYOZnmUyzvHAnkeaKb)bKQkjhQwOq0UdndINZMHSdc5qbYeMKepmdr7ecX4Yq9XUuYon(sYOZnmUyzvHAnkeiqDdJ)Kn8Lk4RLrNByCXYQc1AuiWbupZ2yrLKdfpTqHOD1TcrBxDqihkqMWKK4HziAxDNHkeTld1hweMcWGeIOQtAHcr7iqDd)HkeW4GqouG8LKrNByCXYQc1AuiWb0dviGkjhQ6odviAhjnTedqDeTIsLhBoo3A3(LZZKqb4S5)Lk4RLrNByCXYQc1AuiWbupZ2yrLKdvDNHkeTJKMwIbOoIwrPYYo2CCU1U9lNNjHcWzZFcpTqHOD1TcrBxDqihkqk(lvWxlJo3W4ILvfQ1OqygcfaNn1ZGMbsRsYHQUZqfI2rstlXauhrR8LKrNByCXYQc1Aui0wy7uVcQKZGkjhQwOq0ocu3WFOcbmoiKdfi4Ry3wwg(wUqHjnXnUXy]] )


end
