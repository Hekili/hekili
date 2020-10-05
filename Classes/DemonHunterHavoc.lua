-- DemonHunterHavoc.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [-] dancing_with_fate
-- [-] relentless_onslaught
-- [-] growing_inferno
-- [x] serrated_glaive

-- Covenant
-- [-] repeat_decree
-- [x] increased_scrutiny
-- [x] brooding_pool
-- [-] unnatural_malice

-- Endurance
-- [x] fel_defender
-- [-] shattered_restoration
-- [-] viscous_ink

-- Finesse
-- [-] demonic_parole
-- [x] felfire_haste
-- [-] lost_in_darkness
-- [-] ravenous_consumption


if UnitClassBase( "player" ) == "DEMONHUNTER" then
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

        -- Immolation Aura now grants 20 up front, 60 over 12 seconds (5 fps).
        immolation_aura = {
            talent  = "burning_hatred",
            aura    = "immolation_aura",

            last = function ()
                local app = state.buff.immolation_aura.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 5
        },

        eye_beam = {
            talent = "blind_fury",
            aura   = "eye_beam",

            last = function ()
                local app = state.buff.eye_beam.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = function () return 1 * state.haste end,
            value = 40,
        },
    } )


    -- Talents
    spec:RegisterTalents( {
        blind_fury = 21854, -- 203550
        demonic_appetite = 22493, -- 206478
        felblade = 22416, -- 232893

        insatiable_hunger = 21857, -- 258876
        burning_hatred = 22765, -- 320374
        demon_blades = 22799, -- 203555

        trail_of_ruin = 22909, -- 258881
        unbound_chaos = 22494, -- 275144
        glaive_tempest = 21862, -- 342817

        soul_rending = 21863, -- 204909
        desperate_instincts = 21864, -- 205411
        netherwalk = 21865, -- 196555

        cycle_of_hatred = 21866, -- 258887
        first_blood = 21867, -- 206416
        essence_break = 21868, -- 258860

        unleashed_power = 21869, -- 206477
        master_of_the_glaive = 21870, -- 203556
        fel_eruption = 22767, -- 211881

        demonic = 21900, -- 213410
        momentum = 21901, -- 206476
        fel_barrage = 22547, -- 258925
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        cleansed_by_flame = 805, -- 205625
        cover_of_darkness = 1206, -- 227635
        demonic_origins = 810, -- 235893
        detainment = 812, -- 205596
        eye_of_leotheras = 807, -- 206649
        mana_break = 813, -- 203704
        mana_rift = 809, -- 235903
        mortal_rush = 1204, -- 328725
        rain_from_above = 811, -- 206803
        reverse_magic = 806, -- 205604
        unending_hatred = 1218, -- 213480
    } )

    -- Auras
    spec:RegisterAuras( {
        halfgiant_empowerment = {
            id = 337532,
            duration = 3600,
            max_stack = 1,
            -- TODO: Requires
        },
        blade_dance = {
            id = 188499,
            duration = 1,
            max_stack = 1
        },
        blur = {
            id = 212800,
            duration = 10,
            max_stack = 1,
        },
        chaos_brand = {
            id = 1490,
            duration = 3600,
            max_stack = 1,
        },
        chaos_nova = {
            id = 179057,
            duration = 2,
            type = "Magic",
            max_stack = 1,
        },
        chaotic_blades = {
            id = 337567,
            duration = 8,
            max_stack = 1,
        },
        darkness = {
            id = 196718,
            duration = 8,
            max_stack = 1,
        },
        death_sweep = {
            id = 210152,
            duration = 1,
            max_stack = 1,
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
        essence_break = {
            id = 320338,
            duration = 8,
            max_stack = 1,
        },
        eye_beam = {
            id = 198013,
            duration = function () return ( talent.blind_fury.enabled and 3 or 2 ) * haste end,
            max_stack = 1,
            generate = function( t )
                if buff.casting.up and buff.casting.v1 == 198013 then
                    t.applied  = buff.casting.applied
                    t.duration = buff.casting.duration
                    t.expires  = buff.casting.expires
                    t.stack    = 1
                    t.caster   = "player"
                    forecastResources( "fury" )
                    return
                end

                t.applied  = 0
                t.duration = class.auras.eye_beam.duration
                t.expires  = 0
                t.stack    = 0
                t.caster   = "nobody"
            end,
        },
        fel_barrage = {
            id = 258925,
        },
        fel_eruption = {
            id = 211881,
            duration = 4,
            max_stack = 1,
        },
        -- Legendary
        fel_bombardment = {
            id = 337849,
            duration = 3600,
            max_stack = 5,
        },
        -- Legendary
        fel_devastation = {
            id = 333105,
            duration = 2,
            max_stack = 1,
        },
        glide = {
            id = 131347,
        },
        immolation_aura = {
            id = 258920,
            duration = 12,
            max_stack = 1,
        },
        inner_demon = {
            id = 337313,
            duration = 3600,
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
            id = 185245,
            duration = 3,
            max_stack = 1,
        },
        trail_of_ruin = {
            id = 258883,
            duration = 4,
            max_stack = 1,
        },
        unrestrained_fury = {
            id = 320770,
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
        },


        -- Conduit
        essence_break = {
            id = 320338,
            duration = 8,
            max_stack = 1
        },

        exposed_wound = {
            id = 339229,
            duration = 10,
            max_stack = 1,
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
            local fps = 10.2 + ( talent.demonic.enabled and 1.2 or 0 )

            -- SimC uses base haste, we'll use current since we recalc each time.
            fps = fps / haste

            -- Chaos Strike accounts for most Fury expenditure.
            fps = fps + ( ( fps * 0.9 ) * 0.5 * ( 40 / 100 ) )

            rps = rps + ( fps / 30 ) * ( 1 )
        end

        meta_cd_multiplier = 1 / ( 1 + rps )
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        --[[ if level < 116 and equipped.delusions_of_grandeur and resource == "fury" then
            -- revisit this if really needed... 
            cooldown.metamorphosis.expires = cooldown.metamorphosis.expires - ( amt / 30 )
        end ]]
    end )

    spec:RegisterCycle( function ()
        if active_enemies == 1 then return end

        -- For Nemesis, we want to cast it on the lowest health enemy.
        if this_action == "nemesis" and Hekili:GetNumTTDsWithin( target.time_to_die ) > 1 then return "cycle" end
    end )


    -- Gear Sets
    spec:RegisterGear( "tier19", 138375, 138376, 138377, 138378, 138379, 138380 )
    spec:RegisterGear( "tier20", 147130, 147132, 147128, 147127, 147129, 147131 )
    spec:RegisterGear( "tier21", 152121, 152123, 152119, 152118, 152120, 152122 )
        spec:RegisterAura( "havoc_t21_4pc", {
            id = 252165,
            duration = 8 
        } )

    spec:RegisterGear( "class", 139715, 139716, 139717, 139718, 139719, 139720, 139721, 139722 )

    spec:RegisterGear( "convergence_of_fates", 140806 )

    spec:RegisterGear( "achor_the_eternal_hunger", 137014 )
    spec:RegisterGear( "anger_of_the_halfgiants", 137038 )
    spec:RegisterGear( "cinidaria_the_symbiote", 133976 )
    spec:RegisterGear( "delusions_of_grandeur", 144279 )
    spec:RegisterGear( "kiljaedens_burning_wish", 144259 )
    spec:RegisterGear( "loramus_thalipedes_sacrifice", 137022 )
    spec:RegisterGear( "moarg_bionic_stabilizers", 137090 )
    spec:RegisterGear( "prydaz_xavarics_magnum_opus", 132444 )
    spec:RegisterGear( "raddons_cascading_eyes", 137061 )
    spec:RegisterGear( "sephuzs_secret", 132452 )
    spec:RegisterGear( "the_sentinels_eternal_refuge", 146669 )

    spec:RegisterGear( "soul_of_the_slayer", 151639 )
    spec:RegisterGear( "chaos_theory", 151798 )
    spec:RegisterGear( "oblivions_embrace", 151799 )


    do
        local wasWarned = false

        spec:RegisterEvent( "PLAYER_REGEN_DISABLED", function ()
            if state.talent.demon_blades.enabled and not state.settings.demon_blades_acknowledged and not wasWarned then
                Hekili:Notify( "|cFFFF0000WARNING!|r  Demon Blades cannot be forecasted.\nSee /hekili > Havoc for more information." )
                wasWarned = true
            end
        end )
    end


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

                if buff.chaotic_blades.up then gain( 20, "fury" ) end -- legendary
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
            end,
        },
        

        blur = {
            id = 198589,
            cast = 0,
            cooldown = function () return 60 + ( conduit.fel_defender.mod * 0.001 ) end,
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

                if buff.chaotic_blades.up then gain( 20, "fury" ) end -- legendary
            end,
        },
        

        consume_magic = {
            id = 278326,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            startsCombat = true,
            texture = 828455,

            usable = function () return buff.dispellable_magic.up end,
            handler = function ()
                removeBuff( "dispellable_magic" )
                gain( buff.solitude.up and 22 or 20, "fury" )
            end,
        },
        

        darkness = {
            id = 196718,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
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

            spend = function () return talent.first_blood.enabled and 15 or 35 end,
            spendType = "fury",

            startsCombat = true,
            texture = 1309099,

            bind = "blade_dance",
            buff = "metamorphosis",

            handler = function ()
                applyBuff( "death_sweep" )
                setCooldown( "blade_dance", 9 * haste )
            end,
        },
        

        demons_bite = {
            id = 162243,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return talent.insatiable_hunger.enabled and -25 or -20 end,
            spendType = "fury",

            startsCombat = true,
            texture = 135561,

            notalent = "demon_blades",

            handler = function ()
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
        

        essence_break = {
            id = 258860,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136189,
            
            handler = function ()
                applyDebuff( "target", "essence_break" )
                active_dot.essence_break = max( 1, active_enemies )
            end,
        },
        

        eye_beam = {
            id = 198013,
            cast = function () return ( talent.blind_fury.enabled and 3 or 2 ) * haste end,
            cooldown = 30,
            channeled = true,
            gcd = "spell",

            spend = 30,
            spendType = "fury",

            startsCombat = true,
            texture = 1305156,

            start = function ()
                last_eye_beam = query_time
                
                applyBuff( "eye_beam" )

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

            start = function ()
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
            cooldown = function () return legendary.erratic_fel_core.enabled and 7 or 10 end,
            recharge = function () return legendary.erratic_fel_core.enabled and 7 or 10 end,
            gcd = "spell",

            startsCombat = true,
            texture = 1247261,

            usable = function ()
                if settings.recommend_movement ~= true then return false, "fel_rush movement is disabled" end
                return not prev_gcd[1].fel_rush
            end,
            handler = function ()
                if talent.momentum.enabled then applyBuff( "momentum" ) end
                if cooldown.vengeful_retreat.remains < 1 then setCooldown( "vengeful_retreat", 1 ) end
                setDistance( 5 )
                setCooldown( "global_cooldown", 0.25 )
                if conduit.felfire_haste.enabled then applyBuff( "felfire_haste" ) end
            end,

            auras = {
                -- Conduit
                felfire_haste = {
                    id = 338804,
                    duration = 8,
                    max_stack = 1
                }
            }
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
        

        fel_lance = {
            id = 206966,
            cast = 1,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "rain_from_above",
            buff = "rain_from_above",

            startsCombat = true,
        },
        
        
        glaive_tempest = {
            id = 342817,
            cast = 0,
            cooldown = 20,
            hasteCD = true,
            gcd = "spell",
            
            spend = 30,
            spendType = "fury",
            
            startsCombat = true,
            texture = 1455916,
            
            handler = function ()
            end,
        },


        immolation_aura = {
            id = 258920,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = -20,
            spendType = "fury",

            startsCombat = true,
            texture = 1344649,

            handler = function ()
                applyBuff( "immolation_aura" )
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

            auras = {
                -- Conduit
                demonic_parole = {
                    id = 339051,
                    duration = 12,
                    max_stack = 1
                }
            }
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
            cooldown = function () return ( level > 47 and 240 or 120 ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( pvptalent.demonic_origins.up and 0.5 or 1 ) end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 1247262,

            handler = function ()
                applyBuff( "metamorphosis" )
                last_metamorphosis = query_time
                
                setDistance( 5 )

                if IsSpellKnownOrOverridesKnown( 317009 ) then
                    applyDebuff( "target", "sinful_brand" )
                    active_dot.sinful_brand = active_enemies
                end

                if level > 19 then stat.haste = stat.haste + 25 end
                
                if level > 53 or azerite.chaotic_transformation.enabled then
                    setCooldown( "eye_beam", 0 )
                    setCooldown( "blade_dance", 0 )
                    setCooldown( "death_sweep", 0 )
                end
            end,

            meta = {
                adjusted_remains = function ()
                    --[[ if level < 116 and ( equipped.delusions_of_grandeur or equipped.convergeance_of_fates ) then
                        return cooldown.metamorphosis.remains * meta_cd_multiplier
                    end ]]

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
            cooldown = 180,
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

            debuff = "reversible_magic",

            handler = function ()
                if debuff.reversible_magic.up then removeDebuff( "player", "reversible_magic" ) end
            end,
        },
        
        
        spectral_sight = {
            id = 188501,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1247266,
            
            handler = function ()
            end,
        },
        

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
                removeBuff( "fel_bombardment" ) -- legendary
                if talent.master_of_the_glaive.enabled then applyDebuff( "target", "master_of_the_glaive" ) end
                if conduit.serrated_glaive.enabled then applyDebuff( "target", "exposed_wound" ) end
            end,

            auras = {
                -- Conduit: serrated_glaive
                exposed_wound = {
                    id = 339229,
                    duration = 10,
                    max_stack = 1
                }
            }
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


        -- Demon Hunter - Kyrian    - 306830 - elysian_decree       (Elysian Decree)
        elysian_decree = {
            id = 306830,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 3565443,

            handler = function ()
                create_sigil( "elysian_decree" )
            end,
        },

        
        -- Demon Hunter - Necrolord - 329554 - fodder_to_the_flame  (Fodder to the Flame)
        fodder_to_the_flame = {
            id = 329554,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 3591588,

            handler = function ()
                applyDebuff( "player", "fodder_to_the_flame_chase" )
                applyDebuff( "player", "fodder_to_the_flame_cooldown" )
            end,

            auras = {
                -- The buff from standing in the pool.
                fodder_to_the_flame = {
                    id = 330910,
                    duration = function () return 30 + ( conduit.brooding_pool.mod * 0.001 ) end,
                    max_stack = 1,
                },

                -- The demon is linked to you.
                fodder_to_the_flame_chase = {
                    id = 328605,
                    duration = 3600,
                    max_stack = 1,
                },

                -- This is essentially the countdown before the demon despawns (you can Imprison it for a long time).
                fodder_to_the_flame_cooldown = {
                    id = 342357,
                    duration = 120,
                    max_stack = 1,
                },                
            }
        },

        -- Demon Hunter - Night Fae - 323639 - the_hunt             (The Hunt)
        the_hunt = {
            id = 323639,
            cast = 1,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 3636838,
            
            handler = function ()
                applyDebuff( "target", "the_hunt" )
                applyDebuff( "target", "the_hunt_dot" )
                applyDebuff( "target", "the_hunt_root" )
                setDistance( 5 )
            end,

            auras = {
                the_hunt_root = {
                    id = 323996,
                    duration = 1.5,
                    max_stack = 1,
                },
                the_hunt_dot = {
                    id = 345335,
                    duration = 6,
                    max_stack = 1,
                },
                the_hunt = {
                    id = 323802,
                    duration = 30,
                    max_stack = 1,
                },
            }
        },

        -- Demon Hunter - Venthyr   - 317009 - sinful_brand         (Sinful Brand)
        sinful_brand = {
            id = 317009,
            cast = 0,
            cooldown = function () return 60 + ( conduit.sinful_brand.mod * 0.001 ) end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 3565717,

            handler = function ()
                applyDebuff( "target", "sinful_brand" )
            end,

            auras = {
                sinful_brand = {
                    id = 317009,
                    duration = 8,
                    max_stack = 1,
                }
            }
        }
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 7,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_unbridled_fury",

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

    spec:RegisterSetting( "demon_blades_head", nil, {
        name = "Demon Blades",
        type = "header",        
    } )

    spec:RegisterSetting( "demon_blades_text", nil, {
        name = "|cFFFF0000WARNING!|r  If using the |T237507:0|t Demon Blades talent, the addon will not be able to predict Fury gains from your auto-attacks.  This will result " ..
            "in recommendations that jump forward in your display(s).",
        type = "description",
        width = "full"
    } )

    spec:RegisterSetting( "demon_blades_acknowledged", false, {
        name = "I understand that Demon Blades is unpredictable; don't warn me.",
        desc = "If checked, the addon will not provide a warning about Demon Blades when entering combat.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Havoc", 20200926, [[deuLOaqikHhjusBsOAuukDkkfRsvb6vcXSiPULQcyxe(fLQHbihJsYYOK6zQk00qHY1OezBOG8nHsyCOGQZPQGMhLOUhj2NQshefuAHOqEikuvtefQYfrbf2OqjQrIcvoPqjYkrr7efyPOGIEQQQPQQO9c0FPyWG4WilwspMutMOlRSzj(maJMKCArVwOy2O62c2nv)wQHRkwouphY0v56O02vL(UqA8cLQZdOwVqPmFqA)GAqRa)e8xs3azG1aznqa9HwZqcG(qg7JwYsG)hWpd8)H0Xqag4VtHb(Z4O3wd()qaZBsc(j4pQzX6b()NbwoDz7m(yQCG)v2KFXsoyf8xs3azG1aznqa9HwZqG)ONPbzGLIfXcWFvPuohSc(lhsd(hRWqy8wODyimow)gggcJJEBnmZyfgY)EUfQdddXAgsnmeRbYAGa)FWDj5d8pwHHW4Tq7WqyCS(nmmegh92AyMXkmK)9CluhggI1mKAyiwdK1abZeMzScd53PhKQ(GHGPucdPYwktcdbD0HGHuxPXdgIUdv6GHuhG0rWqixcd5bVpWtFx6aGHKiyiY2NaMjPVSDK4bpDhQ0frXoYPhKQ(mOJoemtsFz7iXdE6ouPlII9N(Y2Hzs6lBhjEWt3HkDruSZIMjVfu7uykuSHuryczkTFMUyE6OddZeMzScdHHrSpn7njmK9omWWqUmmyiNQbdH0xJHHKiyi0lLCQYNaMjPVSDKImry2NdMjPVSDuef762rSHzceGudZK0x2okII9xcNuLp1ofMsLtYzKKRN6xIZoLJ4ZprjXOZu5DlfZPkFsOqrpJZnhHbSdjQCsoJKC9S6RITF8dCeF(jomLCtxmy20fZPkFsBGzs6lBhfrX(lHtQYNANct5PBE6amLgBc7i1VeNDkwCeF(jKl0EQfZPkFY46U5YoQlc7OqJFu1OejWlqPJSmdfVWIbwixj1599JabZK0x2okII9xcNuLp1ofMYt380bykn2u5KCgj56P(L4St5LWjv5tu5KCgj56f32clgylhlS0h4i(8tusm6mvE3sXCQYN8dAnq2aZK0x2okII9xcNuLp1ofMYt380bykn2mGNPokO(L4St5i(8tixO9ulMtv(KXT4i(8tu5PlnfwmWI5uLpzCD3Czh1fd4zQJcc8cu6ilBlaTueOy)dATnXlSyGfYvsDEFTgiyMK(Y2rruS)s4KQ8P2PWuIs5LoatPXMHqZ1ZuXJIr9lXzNYr85Nyi0C9mv8OyeZPkFY4w8s4KQ8jE6MNoatPXMkNKZijxV4w8s4KQ8jE6MNoatPXMWokUUBUSJ6IHqZ1ZuXJIrW(aZK0x2okII9xcNuLp1ofMsukV0bykn2e6W8JnO(L4St5i(8te6W8JniMtv(KXTOYwkIqhMFSbb7dmtsFz7Oik2LjcZ(CWmj9LTJIOyxtCUH0x2UHNOtTtHPO7Ml7OU6SOaqlf4fO0rkabZK0x2okII9NuhJH9XuWeGW8tDwuKl0Ub1SCtbtacZp0xGGzs6lBhfrX(tQJXW(ykycqy(PolkfwmWc5kPoVVkF0sXT1ck2goVjgWdz6IbtaMyov5tcfQUBUSJ6Ib8m1rbbEbkD0xRemMnWmj9LTJIOy)uH7OgaCkFN6SOuzlfrzCtTdvcldZpb6iDmkwkUTv2srKHqZPlB3qSysW(afQfv2sre2rHg)OQrjsW(ydmtsFz7Oik21eNBi9LTB4j6u7uykdHMRNPIhfJ6SOCeF(jgcnxptfpkgXCQYNmUTVeoPkFIOuEPdWuASzi0C9mv8OyGcvUkBPigcnxptfpkgb7JnWmj9LTJIOyhZ6gsFz7gEIo1ofMICH2tT6SOCeF(jKl0EQfZPkFsyMK(Y2rruSJzDdPVSDdprNANctXBCG4WmHzs6lBhj0DZLDuxjSJcn(rvJsK6SOyHThXNFc5cTNAXCQYNek0xcNuLpXt380bykn2e2r2afAjbO6m4fO0rw2AlbZK0x2osO7Ml7OEef7HDuOXpQAuIuNfLJ4ZpHCH2tTyov5tg3wlOyB48MqRI6l1MdtoQ04aDz7I5uLpjuO2Q7Ml7OUyaptDuqGxGsh91AGIBRfVeoPkFIkNKZijxpOq1DZLDuxu5KCgj56jWlqPJ(cqlfbk2TXgBGzs6lBhj0DZLDupIIDu6fwUPIjxQolkwi7tGsVWYnvm5sXL6yshamtsFz7iHUBUSJ6ruSFQMrfRFWmj9LTJe6U5YoQhrXEPLYHnxBovZu4uyWmj9LTJe6U5YoQhrX(4aJsYnYPXBWmj9LTJe6U5YoQhrX(tFz7QZIsLTueHDuOXpQAuIe4fO0rFT2sqHwsaQodEbkDKLziGGzs6lBhj0DZLDupIIDw0m5TGANctbaXNM48HrMA3U6SOyXr85NOmUPsymbyI5uLpjuO6U5YoQlkJBQegtaMapscmmtsFz7iHUBUSJ6ruSZIMjVfuVsz6Z4uykAG18(WTNAtLtOtDwuQSLIiSJcn(rvJsKG9jELTueHfAmWMUy4S6uAK4rbKq2r942AXlHtQYNOYj5msY1dkul0DZLDuxu5KCgj56jWJKaBdmtsFz7iHUBUSJ6ruSZIMjVfu7uykes1l5dzWuS1yJUXexDwuKRYwkcmfBn2OBmXnYvzlfHSJ6qHARCv2srOBxYQV8DM0JXixLTueSpqHwzlfryhfA8JQgLibEbkD0xRbYM4hHbStOAe)ujE0NL)OvqHwsaQodEbkDKLTgiyMK(Y2rcD3Czh1JOyNfntElO2PWuOydPIWeYuA)mDX80rhwDwu0DZLDuxe2rHg)OQrjsGxGshzzRackuD3Czh1fHDuOXpQAuIe4fO0rFziGGzgRWqy8wHy5hmKcX5vshdmKsJHHWIOkFWqYBbKaMjPVSDKq3nx2r9ik2zrZK3ci1zrPYwkIWok04hvnkrc2hyMK(Y2rcD3Czh1JOyxtCUH0x2UHNOtTtHPmeAUEiyMWmj9LTJeYfAp1kLXnywKk1zrX2J4ZpbRxBwxA0QOgjMtv(KXRSLIG1RnRlnAvuJeSp2e3wTkcdyifRHc1wmLsZENFIq)UW8tK(xRakoMsPzVZpbjLir6FTciBSbMjPVSDKqUq7PoIID5OtLbfD7rDwuEjCsv(evojNrsUEWmj9LTJeYfAp1ruSdGt57m3cpdDQZIcPV8DM5lKd9vouIN0CegWoeuOykLM9o)eKuIeP)1kGGzs6lBhjKl0EQJOy)uH7OgaCkFN6SOOBxYMNanmMUjna4u(oXCQYNmUUBUSJ6Ib8m1rbbEbkDKLzO4wuzlfryhfA8JQgLib7tClKRYwkIf7pnAst0M1Lc2hyMK(Y2rc5cTN6ik2hWZuhfuNffmLsZENFcskrc2hOqXukn7D(jiPejs)R1wcMjPVSDKqUq7PoII9kNKZijxp1zr5LWjv5tu5KCgj56f3cD3Czh1fHDuOXpQAuIe4rsGJBRUBUSJ6Ib8m1rbbEbkD0xBT0hGITHZBc8EB(B6amvojhsGjpMp4hTbkuBXukn7D(jiPejs)RUBUSJ6XXukn7D(jiPejs3YwBjBSbMjPVSDKqUq7PoII9meAoDz7gIftWmj9LTJeYfAp1ruStUNQsoDz7QZIIfVeoPkFINU5PdWuASPYj5msY1dMjPVSDKqUq7PoII9Y4vojN6SOuyXalKRK68(QWyabZK0x2osixO9uhrXUwf1id6WzmtDwuS4LWjv5t80npDaMsJnvojNrsUEXT4LWjv5t80npDaMsJnd4zQJcWmj9LTJeYfAp1ruSxg3GzrQuNfLJ4ZpHCH2nvojhsmNQ8jJBHUBUSJ6Ib8m1rbbEKe442QvryadPynuO2IPuA278te63fMFI0)AfqXXukn7D(jiPejs)RvazJnWmj9LTJeYfAp1ruSlxODKPM3Gzs6lBhjKl0EQJOy)uH7OgaCkFN6SOuzlfrZEMUyWKdyc2hyMK(Y2rc5cTN6ik2lJBWSivQZIsOFxy(jKj6ixVVwzjOqRSLIOzptxmyYbmb7dmtsFz7iHCH2tDef7VZbScl3G3HhDQZIsOFxy(jKj6ixVVwzjyMK(Y2rc5cTN6ik2pv4oQbaNY3PolkhXNFc5cTBQCsoKyov5tcZeMjPVSDKyi0C9mv8Oyugcnxptfpkg1zrPWIb(RcdhO42Q7Ml7OUOYj5msY1tGhjbgkulEjCsv(evojNrsUE2aZK0x2osmeAUEMkEumruSlhDQmOOBpQZIYlHtQYNOYj5msY1lUCv2srmeAUEMkEumc2hyMK(Y2rIHqZ1ZuXJIjII9kNKZijxp1zr5LWjv5tu5KCgj56fxUkBPigcnxptfpkgb7dmtsFz7iXqO56zQ4rXerXo5EQk50LTRolkYvzlfXqO56zQ4rXiyFGzs6lBhjgcnxptfpkMik21QOgzqhoJzQZIICv2srmeAUEMkEumc2hyMWmj9LTJedHMRhs5LWjv5tTtHPug3ujmMamdcyxRolkhXNFIY4MkHXeGjMtv(KQFjo7u0DZLDuxug3ujmMambEKe442ARTwCeF(jKl0EQfZPkFsOqRSLIiSJcn(rvJsKG9XM4w8s4KQ8jIs5LoatPXMqhMFSH4ykLM9o)eKuIeP)9JazduOK(Y3zMVqo0x5qjEsZrya7q2aZK0x2osmeAUEOik21TRNFy6M0u4uyQZIITwi7tOBxp)W0nPPWPWmvwSlUuht6aIBbPVSDHUD98dt3KMcNctKUPWtaQoOqlSCUbpTkcdyMldZYa0srGIDBGzgRWqyyVBHNdgY1Wqqa7AyirZtfmKy5XHHWicJjadgsJHHWW2mmGHKfyi5bdjAY5WqQdgclAsyirZtv6WqovdgIVy)GHWywcgcA62Li1Wq6t1Wrt0GHWIgmejloDaWq8ghiomKklgDWqKuGambmtsFz7iXqO56HIOyVY7wA6I5unZ8fawDwuS1IJ4ZprzCtLWycWeZPkFsOq1DZLDuxug3ujmMambEbkD0xgZs2e3IxcNuLprukV0bykn2e6W8Jne3wBT4i(8tixO9ulMtv(KqHwzlfryhfA8JQgLib7tCl0DZLDuxu5KCgj56jWJKaBduOLeGQZGxGshzzfRaYgyMK(Y2rIHqZ1dfrXEL3T00fZPAM5laS6SOCeF(jkJBQegtaMyov5tg)LWjv5tug3ujmMamdcyxdZK0x2osmeAUEOik2bWsyzsUPlgk2gUpvQZIITv2sre2rHg)OQrjsW(ex3nx2rDryhfA8JQgLibEKeyBGcTYwkIWok04hvnkrc8cu6OVwBjOqljavNbVaLoYYkFeiyMK(Y2rIHqZ1dfrXEP1SOjnuSnCEZuhfuNff0Z4CZrya7qIkNKZijxpR(QynuOykLM9o)eKuIeP)LHacMjPVSDKyi0C9qruS)WIZcWPdWu5e6uNff0Z4CZrya7qIkNKZijxpR(QynuOykLM9o)eKuIeP)LHacMjPVSDKyi0C9qruSFQMH1RnRlnLgRN6SOuzlfbE6y4dHmLgRNG9bk0kBPiWthdFiKP0y9m6M1VHfOJ0XyzRacMjPVSDKyi0C9qruSJZNh(mPBqpKEWmj9LTJedHMRhkII9OnMlFx6g8qTtUEQZIsLTueHDuOXpQAuIeSpqH(s4KQ8jkJBQegtaMbbSRHzs6lBhjgcnxpuef7HfAmWMUy4S6uAK4rbK6SOuyXaBzgdO4v2sre2rHg)OQrjsW(aZmwHHW4AUegcdZrpPdagsSmNcdbdP0yyil2NM9gmem5agmKgddjMKZHHuzlfKAyizbgYtJqzLpbmegwEucyemKddmmKRHHayhmKt1GHW7OdDWq0DZLDuhgsLqtcdPDyi0lLCQYhmK5lKdjGzs6lBhjgcnxpuef74rpPdWu4uyi1zr5imGDIldZCTrMZYwjSeuO2A7rya7eQgXpvIh99LHdeuOhHbStOAe)ujE0NLvSgiBIBlPV8DM5lKdPyfuOLeGQZGxGsh916p0gBGc12JWa2jUmmZ1Mh9zSgOVFeO42s6lFNz(c5qkwbfAjbO6m4fO0rFzmgZgBGzcZK0x2os4noqCL35awHLBW7WJo1zr5i(8te6W8JniMtv(KXRSLI4bVhcpPq2r94xg2xRGzs6lBhj8ghiEef7LXnywKk1zrX2xcNuLprukV0bykn2e6W8Jnaf6r85NG1RnRlnAvuJeZPkFY4v2srW61M1LgTkQrc2hBIBRwfHbmKI1qHAlMsPzVZprOFxy(js)RvafhtP0S35NGKsKi9VwbKn2aZK0x2os4noq8ik2lJBQegtaM6SOq6lFNz(c5qFLdL4jnhHbSdbfkMsPzVZpbjLir6F)iqWmj9LTJeEJdepIID5OtLbfD7rDwuEjCsv(evojNrsUEWmj9LTJeEJdepII9meAoDz7gIftWmj9LTJeEJdepIIDaCkFN5w4zOtDwuS4LWjv5teLYlDaMsJnHom)ydXTL0x(oZ8fYH(khkXtAocdyhckumLsZENFcskrI0)Afq2aZK0x2os4noq8ik2pv4oQbaNY3Polk62LS5jqdJPBsdaoLVtmNQ8jJR7Ml7OUyaptDuqGxGshzzgkUfv2sre2rHg)OQrjsW(e3c5QSLIyX(tJM0eTzDPG9bMjPVSDKWBCG4ruSpGNPokOolkK(Y3zMVqo0xRIBRfykLM9o)eKuIel2t0HGcftP0S35NGKsKG9XM4w8s4KQ8jIs5LoatPXMqhMFSbyMK(Y2rcVXbIhrXELtYzKKRN6SO8s4KQ8jQCsoJKC9Gzs6lBhj8ghiEef7LXRCso1zrPWIbwixj159vHXacMjPVSDKWBCG4ruSpGNPokOolkwCeF(jQ80LMclgyXCQYNmUfVeoPkFIOuEPdWuASzi0C9mv8OyIJPuA278tqsjsK(xD3Czh1Hzs6lBhj8ghiEef7K7PQKtx2U6SOy7r85NqUq7MkNKdjMtv(KqHAXlHtQYNikLx6amLgBcDy(XgGcTWIbwixj15z5pceuOv2sre2rHg)OQrjsGxGshzzlztClEjCsv(epDZthGP0ytLtYzKKRxClEjCsv(erP8shGP0yZqO56zQ4rXaZK0x2os4noq8ik21QOgzqhoJzQZIIThXNFc5cTBQCsoKyov5tcfQfVeoPkFIOuEPdWuASj0H5hBak0clgyHCLuNNL)iq2e3IxcNuLpXt380bykn2e2rXT4LWjv5t80npDaMsJnvojNrsUEXT4LWjv5teLYlDaMsJndHMRNPIhfdmtsFz7iH34aXJOyFaptDuqDwuoIp)evE6stHfdSyov5tghtP0S35NGKsKi9V6U5YoQdZK0x2os4noq8ik2Ll0oYuZBWmj9LTJeEJdepII9Y4gmlsL6SOyXr85Ni0H5hBqmNQ8jJJPuA278te63fMFI0)Qvryad9bTcO4hXNFc5cTBQCsoKyov5tcZK0x2os4noq8ik2lJx5KCQZIsOFxy(jKj6ixVVwzjOqRSLIOzptxmyYbmb7dmtsFz7iH34aXJOyVmUbZIuPolkH(DH5NqMOJC9(ALLGc12kBPiA2Z0fdMCatW(e3IJ4ZprOdZp2Gyov5tAdmtsFz7iH34aXJOy)DoGvy5g8o8OtDwuc97cZpHmrh5691klbZK0x2os4noq8ik2pv4oQbaNY3PolkhXNFc5cTBQCsoKyov5tc()omkBhKbwdK1ab0hAndb(hLWE6aqG)XsHNgFtcdXAyiK(Y2HHWt0HeWmb)j2tvJb))ZaJp4pprhc8tWF5kel)a)eKbwb(j4pPVSDWFzIWSph4)CQYNeKrGhidSg8tWFsFz7G)62rSHzceGud(pNQ8jbze4bYGpc(j4pPVSDWF8EhgntGaKAW)5uLpjiJapqgWyGFc(pNQ8jbze4VgN3Wjb(FeF(jcDy(XgeZPkFsyiXHHuzlfrOdZp2Gq2rDWFsFz7G)LXnywKkWdKbwc8tW)5uLpjiJa)148gojW)J4ZprOdZp2Gyov5tcdjomKJWa2jIMNQ0z4WqIddPWIbwixj15bd5lmegoqG)K(Y2b)FNdyfwUbVdp6apqgWqGFc(t6lBh8)unJkw)a)Ntv(KGmc8azqSa8tW)5uLpjiJa)148gojWFsF57mZxihcgYxyiwb(t6lBh8haNY3zUfEg6apqgWWb)e8N0x2o4FPLYHnxBovZu4uyG)ZPkFsqgbEGm4db)e8N0x2o4FyhfA8JQgLiW)5uLpjiJapqgyfqGFc(t6lBh8FaptDua8Fov5tcYiWdKbwzf4NG)K(Y2b)ZqO50LTBiwmb(pNQ8jbze4bYaRSg8tWFsFz7G)dHMRNPIhfd4)CQYNeKrGhidS6JGFc(pNQ8jbze4VgN3Wjb(FeF(jkjgDMkVBPyov5tcdbkuyiK(Y3zMVqoemKVWqSg8N0x2o4FLtYzKKRh4bYaRymWpb)Ntv(KGmc8xJZB4Ka)pIp)eLeJotL3TumNQ8jHHafkmesF57mZxihcgYxyiwd(t6lBh8xo6uzqr3EapqgyLLa)e8Fov5tcYiWFnoVHtc8N0x(oZ8fYHGH8fgIvG)K(Y2b)hhyusUronEd8azGvme4NG)K(Y2b)rPxy5MkMCj4)CQYNeKrGhidSkwa(j4)CQYNeKrG)ACEdNe4FHfdSqUsQZdgYxyimgqG)K(Y2b)lJx5KCGhidSIHd(j4pPVSDW)Y4MkHXeGb(pNQ8jbze4bYaR(qWpb)Ntv(KGmc8xJZB4Ka)RSLIOmUP2HkHLH5NG9b8N0x2o4)Pc3rna4u(oWdKbwde4NG)K(Y2b)1QOgzqhoJzG)ZPkFsqgbEGmWARa)e8N0x2o4p5EQk50LTd(pNQ8jbze4bYaRTg8tWFsFz7G)YfAhzQ5nW)5uLpjiJapWd8)bpDhQ0b(jidSc8tWFsFz7G)Lwkh2CT5untHtHb(pNQ8jbze4bEGh4bEGG]] )
end
