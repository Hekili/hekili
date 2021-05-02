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
        unbound_chaos = 22494, -- 347461
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
            copy = "chaos_theory" -- simc.
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
            copy = "dark_slash" -- Just in case.
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
            duration = 40,
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
        unbound_chaos = {
            id = 347462,
            duration = 20,
            max_stack = 1
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

    -- SimC documentation reflects that there are still the following expressions, which appear unused:
    -- greater_soul_fragments, lesser_soul_fragments, blade_dance_worth_using, death_sweep_worth_using
    -- They are not implemented becuase that documentation is from mid-2016.

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

            cycle = function () return legendary.burning_wound.enabled and "burning_wound" or nil end,

            handler = function ()
                removeBuff( "thirsting_blades" )
                if azerite.thirsting_blades.enabled then applyBuff( "thirsting_blades", nil, 0 ) end
                if legendary.burning_wound.enabled then applyDebuff( "target", "burning_wound" ) end
                if buff.chaotic_blades.up then gain( 20, "fury" ) end -- legendary
            end,

            auras = {
                burning_wound = {
                    id = 346278,
                    duration = 15,
                    max_stack = 1
                }
            }
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

            copy = "dark_slash"
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
            
            finish = function ()
                if level > 58 then applyBuff( "furious_gaze" ) end
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
                removeBuff( "unbound_chaos" )
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
            id = 232893,cast = 0,
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
                if talent.unbound_chaos.enabled then applyBuff( "unbound_chaos" ) end
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

            toggle = "essences",

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
            
            toggle = "essences",

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

            toggle = "essences",

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

        potion = "phantom_fire",

        package = "Havoc",
    } )


    spec:RegisterSetting( "recommend_movement", true, {
        name = "Recommend Movement",
        desc = "If checked, the addon will recommend |T1247261:0|t Fel Rush / |T1348401:0|t Vengeful Retreat when it is a potential DPS gain.\n\n" ..
            "These abilities are critical for DPS when using the Momentum or Unbound Chaos talents.\n\n" ..
            "If not using Momentum or Unbound Chaos, you may want to disable this to avoid unnecessary movement in combat.",
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


    spec:RegisterPack( "Havoc", 20210502, [[da1SrbqiKQwKuIupsavxskrYMKs9jbQrHGofsyvivOELGyweHBHaPDrYVukmmLIoMGAziPEMusMMucxdPsBdbIVHa04qQqoNuIkRdbQ5ji5EeL9He9pPevDqbuyHcWdranrbexuaL2icaFukryKcivNebqRuP0mrQOBkLOyNcKFkGumuPerwQasEkIMkr0vLsu6RivWyfKAVK6Vs1Gv1HPSyiESsMmQUmyZO4Zi0OjsNwXQLse1RrsMnHBdPDt1Vvz4evhxafTCOEUqtx01rPTRu9DPOXlLuNxkSEbKsZhPSFjRdRLutYTe0br9MuhEt6Uj1QW0TfeWw0knz2qoOjLBlQmIGM0nuqtgOB73stk3AioJRLutgpw8c0KKdkRWY5CceBmPMeHDejbORr0KClbDquVj1H3KUBsTkmDBrlc3knzuoS0brxcibutkD4CW1iAsoexAYabqpV(aDwpbC9b62(TQTTmwJ6PwI6PEtQdxBRTeOuZjcrcU2sqRVLbsd9WYLEXjwV586BjD5CE9SrJiuFlncWCyOEMHO0SEW5Xw66fhXzvVXBjZgtGxFE1BYLlAu)5Ig1Nx9ixmwpZquAgvAs54JzeGMmWd86dea986d0z9eW1hOB73Q2g4bE9TmwJ6PwI6PEtQdxBRTbEGxpbk1CIqKGRTbEGxpbT(wgin0dlx6fNy9MZRVL0LZ51ZgnIq9T0iaZHH6zgIsZ6bNhBPRxCeNv9gVLmBmbE95vVjxUOr9NlAuFE1JCXy9mdrPzuvBRT2kNZJk5yyDOiwkd5Yua8oJWAa8MJtSNxRhV2ARCopQKJH1HIyziY2y3WJHiajCdfKL4XPcYESHV6rXLsSBcwqwyjggzjECQGufwj1I9yAPY8gDU8yBcPpXJtfKkQvsTypMwQmVrNlpsJwIhNkivHvR7e8RPR4SylNZPuwIhNkivuRw3j4xtxXzXwoNtrT1w5CEujhdRdfXYqKTXUHhdras4gkilXJtfK9ydF1JIlLy3eSGmQLyyKL4XPcsf1kPwShtlvM3OZLhBti9jECQGufwj1I9yAPY8gDU8inAjECQGurTADNGFnDfNfB5CoLjECQGufwTUtWVMUIZITCoNIABGxFlBeQpW2aQpaWqR3Y6fxZ6jayXnQV5KsRpaX486jayXnQFDOiJd86BoP06HjLc46dedtfrHHH6pC9bcGEE9bimoeRT2kNZJk5yyDOiwgISn2n8yicqc3qbzSrOdnGocyODgwCJ(6C(KZ5sSBcwqwAcWtfIyCENHf3qbUHiaEBcXSoWCyIGIByQikmm0rbUjeZ50OLMa8uXb0Z7icJdrf4gIa4uuBRT12apWRpW2AyXMaVEyhWnQphuO(ukuVTYdx)eR32TryicqvBTvoNhLXNiMvEwBTvoNhdr2gRZJSOqh1ioRABGh41thG65NhCwp)QpLoX6tdteY6Jnn5YhNy95vVjxUOr9bWI9XjwpD4yDETnWd86TvoNhdr2gyinmri7gBEDltBrLeIXH(IllSePHjczFyKHoobZbewggfcl2hNyV5X6CfgqTXJsmmYWSoWCyIGcHf7JtS38yDE70eGNkoGEEhryCiQa3qeaV2g41thMu6XM1tGsTlwVKsHd3O(dxFGyyQikmmir9bimouFGy(cQV5KsRNayWXS(ae3XR)W1Bz9TkK6jK6qQV5KsRxsSnI6pM6duSJtr9PHjczS2ARCopgISn2n8yicqc3qbzicJdDU5lqIHrg9ywhyomrqTKAxSNsHd3On9ywhyomrqXnmvefgg6Oa3eI5Cj2nblilnb4PIzWXSJiUJRa3qeaNgTOCqi6PHjczuHimo05MVGWukJWwrqttaEQsSnI(X0XSJRa3qeaNIABGxpDysP1tGsTlwVKsHd3qI6dqyCO(aX8fuFtPGxFkfQhHLHP(jwp)A6suFZjLwpbWGJz9biUJxVL1tDi1ty4qQV5KsRxsSnI6pM6duSJtr9hU(MtkT(aBmc(cQpamyuvVL13IqQNWwfs9nNuA9sITru)XuFGIDCkQpnmriJ1wBLZ5XqKTXUHhdras4gkidryCOZnFbsmmYWSoWCyIGAj1UypLchUHe7MGfKHWYWOwsTl2tPWHBO4xtNgT0eGNkMbhZoI4oUcCdra82r5Gq0tdteYOcryCOZnFbHPugHutqttaEQsSnI(X0XSJRa3qeaNcA0Opnb4PA1yjG(X0LAjg4kWnebWBhLdcrpnmriJkeHXHo38feMsze2ccAAcWtvITr0pMoMDCf4gIa4uuBd86PdtkT(aXWuruyyqI6dqyCO(aX8fuVL17hg1e1NgMiK1VowpRVPuWRhHLHb41J0OER(iSoNB4g1dmmWkLO(dxVjAAnI1Bz9TqYqQN5W17Ntqdea98zvBTvoNhdr2g7gEmebiHBOGmeHXHo38fiXWidZ6aZHjckUHPIOWWqhf4MqmNlXUjybzPjapvmdoMDeXDCf4gIa40OricldJcfsd9WYLEXjQyLtJwAcWtvITr0pMoMDCf4gIa40OXbewggfeJGVGocgmQuSYPODuoie90WeHmQqegh6CZxqykLryRiOPjapvj2gr)y6y2XvGBicGtbnA0NMa8uXb0ZNLcCdra82r5Gq0tdteYOcryCOZnFbHPuwlQTbE9TSrO(aBmc(cQpamyuvpcWCyO(aeghQpqmFb1pm1pz9tSEB3gHHiG6nNx)XWu)6ob)A61wBLZ5XqKTXUHhdras4gkidryCOZnFbsCYLHHiKsmmYstaEQGye8f0rWGrLcCdra82R7e8RPRGye8f0rWGrLcdgVrT1w5CEmezBSB4XqeGeUHcYKFNyCIDMd3rH0Ky3eSGm6ttaEQ4a65ZsbUHiaE71Dc(10vOqAOhwU0lorfgqTXJHIG0MHf3qXbMznjLTAZARTY58yiY2y3WJHiajCdfKj)oX4e7mhUJimo05MVaj2nbliB3WJHiafIW4qNB(cAtidlUrOiG0LGMMa8uXm4y2re3XvGBicGtht9MuuBTvoNhdr2g7gEmebiHBOGm53jgNyN5WDOb0radvIDtWcYstaEQ4a65ZsbUHiaEB6ttaEQqeJZ7mS4gkWnebWBVUtWVMUcAaDeWqvya1gpgkcjU4kuR10XutrBgwCdfhyM1Kus9M1wBLZ5XqKTXUHhdras4gkiRPn54e7mhUJEOGNSOsSBcwqwAcWtf6HcEYIQa3qeaVn9iSmmk0df8KfvXkV2ARCopgISnwMq0TvoN3ftmLWnuq26ob)A61wBLZ5XqKTrkfFn7ef2SdsmmYqyzyumGOJCOigMJcEQIPTOsgDBticldJAqrpHLZ5DJfBkw50OrpcldJcfsd9WYLEXjQyLtrT1w5CEmezBGz9UTY58UyIPeUHcY4a65ZsIyINvklSedJS0eGNkoGE(SuGBicGxBTvoNhdr2gywVBRCoVlMykHBOGm)WOMO2wBTvoNhvR7e8RPldfsd9WYLEXjkXWiJ(0eGNkoGE(SuGBicG3EDNGFnDf0a6iGHQWaQnEKsQ3SnH0VUDWnpv7GNsBGvGBicGtJg98lvXXzyfDeS5CvolQgNif0OXmeLMDmGAJhdf10T2ARCopQw3j4xtpezBGcPHEy5sV4eLyyKLMa8uXb0ZNLcCdra82eUUtWVMUcAaDeWqvya1gpsj1B2Mq63n8yicqHimo05MVaA0w3j4xtxHimo05MVafgqTXJusCXvOwRPGI2es)62b38uTdEkTbwbUHiaonA0ZVufhNHv0rWMZv5SOACIuqJgZquA2XaQnEmuut3ARTY58OADNGFn9qKTH8lNZLyyKHWYWOqH0qpSCPxCIkmGAJhPKA6sJgYfJTzgIsZogqTXJHIGSzTnWRpqagJvK1ZgH6NeqRxCeNvT1w5CEuTUtWVMEiY2Gnc9jb0OerXLrzjECQGmSedJSDdpgIaujECQGShB4REuCPSWTjeHLHrHcPHEy5sV4evSYPrJq6ttaEQ4a65ZsbUHiaE71Dc(10vOqAOhwU0lorfgqTXJusiZquA2XaQnEKYw(epovqQcRw3j4xtxXzXwoN3srnfuqJgZquA2XaQnEmuYOEtkOrJWDdpgIaujECQGShB4REuCPmQBtFIhNkivuRw3j4xtxHbJ3GcA0OF3WJHiavIhNki7Xg(QhfxwBTvoNhvR7e8RPhISnyJqFsankruCzuwIhNkiPwIHr2UHhdraQepovq2Jn8vpkUug1TjeHLHrHcPHEy5sV4evSYPrJq6ttaEQ4a65ZsbUHiaE71Dc(10vOqAOhwU0lorfgqTXJusiZquA2XaQnEKYw(epovqQOwTUtWVMUIZITCoVLIAkOGgnMHO0SJbuB8yOKr9MuqJgH7gEmebOs84ubzp2Wx9O4szHBtFIhNkivHvR7e8RPRWGXBqbnA0VB4XqeGkXJtfK9ydF1JIlRT2kNZJQ1Dc(10dr2gXXzyfDeS5Cjggz0ZVufhNHv0rWMZv5SOACI1wBLZ5r16ob)A6HiBJuk0LY6PedJm6ttaEQ4a65ZsbUHiaEB63n8yicq10MCCIDMd3rpuWtw020VB4XqeGs(DIXj2zoChfsJgnewggfdlEo2yNOfOfuSYRT2kNZJQ1Dc(10dr2gGOrCmVZHfgajggzeARC2Ho4a6ark5qCWaVNgMiKrA0W2W7Wo4PY48OACkB1MuuBRT2kNZJkoGE(SKXaIoMnkvIHrwAcWtfRJCSoVVKAxubUHiaEBewggfRJCSoVVKAxuXkVnHlPgMieLrnnAeITH3HDWtf6TdOGNQXPm8MTX2W7Wo4PY48OACkdVjfuuBTvoNhvCa98zfISn4GLs7XMaixIHr2UHhdrakeHXHo38fuBTvoNhvCa98zfISnikSzh6jGkhIPedJmBLZo0bhqhisjhIdg490WeHmsJg2gEh2bpvgNhvJtz4nRT2kNZJkoGE(Scr2gPu81StuyZoiXWiBDoNDsveWylbENOWMDqbUHiaE71Dc(10vqdOJagQcdO24XqrqAtpcldJcfsd9WYLEXjQyL3MEoGWYWOGwl)IaV38yDUIvET1w5CEuXb0ZNviY2aAaDeWqLyyKzRC2Ho4a6ark5qCWaVNgMiKrA0W2W7Wo4PY48OACkPMUTjK(DdpgIauSrOdnGocyODgwCJ(6C(KZ50OfLdcrpnmriJugMgngwCJqra3KIARTY58OIdONpRqKTbIW4qNB(cKyyKTB4XqeGcryCOZnFbTPFDNGFnDfkKg6HLl9ItuHbJ3OnHR7e8RPRGgqhbmufgqTXJusxA0ieBdVd7GNkJZJQXPCDNGFn92yB4Dyh8uzCEunEOOMUuqrT1w5CEuXb0ZNviY2yqrpHLZ5DJfB1wBLZ5rfhqpFwHiBdZ9r6iSCoxIHrg97gEmebOKFNyCIDMd3regh6CZxqT1w5CEuXb0ZNviY2GbeicJdsmmYyyXnuCGzwtsPSwSzT1w5CEuXb0ZNviY2aIrWxqhbdgv1wBLZ5rfhqpFwHiBJLu7I9yIhQajggz0VB4XqeGs(DIXj2zoChryCOZnFbTPF3WJHiaL87eJtSZC4o0a6iGHwBTvoNhvCa98zfISn4a65XoYKGeRglb0tdteYOSWsmmYWSoWCyIGcHf7JtS38yDEBoGWYWOqyX(4e7npwNRWaQnEmuTO2ARCopQ4a65ZkezBWaIoMnkvIHrg9PjapvCa98oIW4qubUHiaE7OCqi6PHjczKYWTjCj1WeHOmQPrJqSn8oSdEQqVDaf8unoLH3Sn2gEh2bpvgNhvJtz4nPGIARTY58OIdONpRqKTbhqpp2rMeQT2kNZJkoGE(Scr2gPu81StuyZoiXWidHLHrDSz)y6yZjckw51wBLZ5rfhqpFwHiBdgq0XSrPsmmYqVDaf8uXNyA(cOmmDPrdHLHrDSz)y6yZjckw51wBLZ5rfhqpFwHiBJDWjcmSIogsmyPedJm0Bhqbpv8jMMVakdt3ARTY58OIdONpRqKTrkfFn7ef2SdsmmYstaEQ4a65DeHXHOcCdra8ABT1w5CEu5hg1eY2bNiWWk6yiXGLsmmYstaEQqpuWtwuf4gIa4TryzyuYXGCddCf)A6TZbfOmCT1w5CEu5hg1eHiBdgq0XSrPsmmYieHLHrX6ihRZ7lP2fvSYPrB3WJHiavtBYXj2zoCh9qbpzrBti9PjapvSoYX68(sQDrf4gIa40Or)6ob)A6Qbf9ewoN3nwSPWGXBqbfTjCj1WeHOmQPrJqSn8oSdEQqVDaf8unoLH3Sn2gEh2bpvgNhvJtz4nPGIARTY58OYpmQjcr2gmGOJyySreKyyKzRC2Ho4a6ark5qCWaVNgMiKrA0W2W7Wo4PY48OACkB1M1wBLZ5rLFyuteISn4GLs7XMaixIHr2UHhdrakeHXHo38fuBTvoNhv(HrnriY2yqrpHLZ5DJfB1wBLZ5rLFyuteISnikSzh6jGkhIPedJm63n8yicq10MCCIDMd3rpuWtw02eARC2Ho4a6ark5qCWaVNgMiKrA0W2W7Wo4PY48OACkdVjf1wBLZ5rLFyuteISnsP4RzNOWMDqIHr26Co7KQiGXwc8orHn7GcCdra82R7e8RPRGgqhbmufgqTXJHIG0MEewggfkKg6HLl9ItuXkVn9CaHLHrbTw(fbEV5X6CfR8ARTY58OYpmQjcr2gqdOJagQedJm63n8yicq10MCCIDMd3rpuWtw02eARC2Ho4a6ark5qCWaVNgMiKrA0W2W7Wo4PY48OACkdt32es)UHhdrak2i0Hgqhbm0odlUrFDoFY5CA0IYbHONgMiKrkdtJgdlUrOiGBsbf1wBLZ5rLFyuteISnqegh6CZxGedJSDdpgIauicJdDU5lO2ARCopQ8dJAIqKTbdiqeghKyyKXWIBO4aZSMKszTyZARTY58OYpmQjcr2gqmc(c6iyWOQ2ARCopQ8dJAIqKTH5(iDewoNlXWiJW0eGNkoGEEhryCiQa3qeaNgn63n8yicq10MCCIDMd3rpuWtwuA0yyXnuCGzwtgQwTjnAiSmmkuin0dlx6fNOcdO24XqrxkAt)UHhdrak53jgNyN5WDeHXHo38fuBTvoNhv(HrnriY2yj1UypM4HkqIHrgHPjapvCa98oIW4qubUHiaonA0VB4XqeGQPn54e7mhUJEOGNSO0OXWIBO4aZSMmuTAtkAt)UHhdrak53jgNyN5WDuiT20VB4XqeGs(DIXj2zoChryCOZnFb1wBLZ5rLFyuteISnGgqhbmujggzPjapviIX5DgwCdf4gIa4TX2W7Wo4PY48OACkx3j4xtV2ARCopQ8dJAIqKTbhqpp2rMeKy1yjGEAyIqgLfwIHrgM1bMdteuiSyFCI9MhRZBZbewggfcl2hNyV5X6CfgqTXJHQf1wBLZ5rLFyuteISn4a65XoYKqT1w5CEu5hg1eHiBdgq0XSrPsmmYOpnb4Pc9qbpzrvGBicG3gBdVd7GNk0BhqbpvJt5sQHjcr64WB2onb4PIdON3reghIkWnebWRT2kNZJk)WOMiezBWaceHXbjggzO3oGcEQ4tmnFbugMU0OHWYWOo2SFmDS5ebfR8ARTY58OYpmQjcr2gmGOJzJsLyyKHE7ak4PIpX08fqzy6sJgHiSmmQJn7hthBorqXkVn9PjapvOhk4jlQcCdraCkQT2kNZJk)WOMiezBSdorGHv0XqIblLyyKHE7ak4PIpX08fqzy6wBTvoNhv(HrnriY2iLIVMDIcB2bjggzPjapvCa98oIW4qubUHiaUMChWX5CDquVj1H3SfB2knztd7JtmQjPdbgbQGiadQLGGRVEjLc1pOYpCwpZHRpy)WOMi46XqGj7GbE9XdfQ3yZd1sGx)sQ5eHOQ2sNJd1hMUeC9e457aobE9bJzDG5WebvOdU(8QpymRdmhMiOcTcCdra8GRNWWTMcvTT2shcmcubragulbbxF9skfQFqLF4SEMdxFWCGXyfzW1JHat2bd86JhkuVXMhQLaV(LuZjcrvTLohhQVveC9e457aobE9bJzDG5WebvOdU(8QpymRdmhMiOcTcCdra8GRNWWTMcvTLohhQVveC9e457aobE9bJzDG5WebvOdU(8QpymRdmhMiOcTcCdra8GR3Y6dSbAOZ6jmCRPqvBPZXH6BbbxpbE(oGtGxFWywhyomrqf6GRpV6dgZ6aZHjcQqRa3qeap46TS(aBGg6SEcd3Aku1w6CCOE6sW1tGNVd4e41hmM1bMdteuHo46ZR(GXSoWCyIGk0kWnebWdUElRpWgOHoRNWWTMcvTT2shcmcubragulbbxF9skfQFqLF4SEMdxFWYXW6qrSm46XqGj7GbE9XdfQ3yZd1sGx)sQ5eHOQ2sNJd1tnbxpbE(oGtGxFWjECQGufwf6GRpV6doXJtfKQmSk0bxpHu3Aku1w6CCOEQj46jWZ3bCc86doXJtfKkQvHo46ZR(Gt84ubPkPwf6GRNqQBnfQAlDoouFRi46jWZ3bCc86doXJtfKQWQqhC95vFWjECQGuLHvHo46jK6wtHQ2sNJd13kcUEc88DaNaV(Gt84ubPIAvOdU(8Qp4epovqQsQvHo46jK6wtHQ2sNJd13ccUEc88DaNaV(GXSoWCyIGk0bxFE1hmM1bMdteuHwbUHiaEW1ty4wtHQ2wBPdbgbQGiadQLGGRVEjLc1pOYpCwpZHRp41Dc(10dUEmeyYoyGxF8qH6n28qTe41VKAoriQQT054q9Hj46jWZ3bCc86dED7GBEQcTcCdra8GRpV6dED7GBEQcDW1ty4wtHQ2sNJd1tnbxpbE(oGtGxFWRBhCZtvOvGBicGhC95vFWRBhCZtvOdUEcd3Aku1w6CCO(wqW1tGNVd4e41toOey9XgEATU(wQ6ZRE6K1QNp7tCoV(toGT8W1t4guupHHBnfQAlDoouFli46jWZ3bCc86doXJtfKQWQqhC95vFWjECQGuLHvHo46jmCRPqvBPZXH6BbbxpbE(oGtGxFWjECQGurTk0bxFE1hCIhNkivj1QqhC9egU1uOQT054q90LGRNapFhWjWRNCqjW6Jn80AD9Tu1Nx90jRvpF2N4CE9NCaB5HRNWnOOEcd3Aku1w6CCOE6sW1tGNVd4e41hCIhNkivHvHo46ZR(Gt84ubPkdRcDW1ty4wtHQ2sNJd1txcUEc88DaNaV(Gt84ubPIAvOdU(8Qp4epovqQsQvHo46jmCRPqvBRT0HaJavqeGb1sqW1xVKsH6hu5hoRN5W1hmhqpFwbxpgcmzhmWRpEOq9gBEOwc86xsnNiev1w6CCO(WutW1tGNVd4e41hmM1bMdteuHo46ZR(GXSoWCyIGk0kWnebWdUEcd3Aku12AlbiQ8dNaVE6wVTY586ftmJQARM0ytPhwtsoOeOMumXmQLut6hg1eAj1bfwlPMeCdraCDaAYfEsapMMmnb4Pc9qbpzrvGBicGxF76ryzyuYXGCddCf)A613U(CqH6PS(WAsBLZ5AYDWjcmSIogsmyPo1brTwsnj4gIa46a0Kl8KaEmnjH1JWYWOyDKJ159Lu7Ikw51tJw97gEmebOAAtooXoZH7Ohk4jlA9TRNW6PV(0eGNkwh5yDEFj1UOcCdra86PrRE6RFDNGFnD1GIEclNZ7gl2uyW4nQNI6PO(21ty9lPgMieRxw9uxpnA1ty9yB4Dyh8uHE7ak4PA86PS(WBwF76X2W7Wo4PY48OA86PS(WBwpf1tHM0w5CUMKbeDmBuQo1b1kTKAsWnebW1bOjx4jb8yAsBLZo0bhqhiwpL1ZH4GbEpnmriJ1tJw9yB4Dyh8uzCEunE9uwFR2utARCoxtYaIoIHXgrqN6GAHwsnj4gIa46a0Kl8KaEmn5UHhdrakeHXHo38fOjTvoNRj5GLs7XMaixN6GORwsnPTY5Cn5GIEclNZ7gl20KGBicGRdqN6GiiAj1KGBicGRdqtUWtc4X0K0x)UHhdraQM2KJtSZC4o6HcEYIwF76jSEBLZo0bhqhiwpL1ZH4GbEpnmriJ1tJw9yB4Dyh8uzCEunE9uwF4nRNcnPTY5CnjrHn7qpbu5qm1PoicOwsnj4gIa46a0Kl8KaEmn56Co7KQiGXwc8orHn7GcCdra86Bx)6ob)A6kOb0radvHbuB8y9HQEcs9TRN(6ryzyuOqAOhwU0lorfR86Bxp91Zbewggf0A5xe49MhRZvSY1K2kNZ1KPu81StuyZoOtDq0rAj1KGBicGRdqtUWtc4X0K0x)UHhdraQM2KJtSZC4o6HcEYIwF76jSEBLZo0bhqhiwpL1ZH4GbEpnmriJ1tJw9yB4Dyh8uzCEunE9uwFy6wF76jSE6RF3WJHiafBe6qdOJagANHf3OVoNp5CE90OvFuoie90WeHmwpL1hUEA0QNHf3O(qvpbCZ6POEk0K2kNZ1KqdOJagQo1b1YPLutcUHiaUoan5cpjGhttUB4XqeGcryCOZnFbAsBLZ5AseHXHo38fOtDqH3ulPMeCdraCDaAYfEsapMMKHf3qXbMznz9ukR(wSPM0w5CUMKbeicJd6uhu4WAj1K2kNZ1Kqmc(c6iyWOstcUHiaUoaDQdkm1Aj1KGBicGRdqtUWtc4X0KewFAcWtfhqpVJimoevGBicGxpnA1tF97gEmebOAAtooXoZH7Ohk4jlA90OvpdlUHIdmZAY6dv9TAZ6PrREewggfkKg6HLl9ItuHbuB8y9HQE6wpf13UE6RF3WJHiaL87eJtSZC4oIW4qNB(c0K2kNZ1KM7J0ry5CUo1bfUvAj1KGBicGRdqtUWtc4X0KewFAcWtfhqpVJimoevGBicGxpnA1tF97gEmebOAAtooXoZH7Ohk4jlA90OvpdlUHIdmZAY6dv9TAZ6PO(21tF97gEmebOKFNyCIDMd3rH0QVD90x)UHhdrak53jgNyN5WDeHXHo38fOjTvoNRjxsTl2JjEOc0PoOWTqlPMeCdraCDaAYfEsapMMmnb4PcrmoVZWIBOa3qeaV(21JTH3HDWtLX5r141tz92kNZ7R7e8RPRjTvoNRjHgqhbmuDQdkmD1sQjb3qeaxhGM0w5CUMKdONh7itcAYfEsapMMeZ6aZHjckewSpoXEZJ15kWnebWRVD9CaHLHrHWI9Xj2BESoxHbuB8y9HQ(wOjxnwcONgMiKrDqH1PoOWeeTKAsBLZ5AsoGEESJmjOjb3qeaxhGo1bfMaQLutcUHiaUoan5cpjGhttsF9PjapvOhk4jlQcCdra86Bxp2gEh2bpvO3oGcEQgVEkRFj1WeHy90X1hEZ6BxFAcWtfhqpVJimoevGBicGRjTvoNRjzarhZgLQtDqHPJ0sQjb3qeaxhGMCHNeWJPjrVDaf8uXNyA(cQNY6dt36PrREewgg1XM9JPJnNiOyLRjTvoNRjzabIW4Go1bfULtlPMeCdraCDaAYfEsapMMe92buWtfFIP5lOEkRpmDRNgT6jSEewgg1XM9JPJnNiOyLxF76PV(0eGNk0df8KfvbUHiaE9uOjTvoNRjzarhZgLQtDquVPwsnj4gIa46a0Kl8KaEmnj6TdOGNk(etZxq9uwFy6QjTvoNRj3bNiWWk6yiXGL6uhe1H1sQjb3qeaxhGMCHNeWJPjttaEQ4a65DeHXHOcCdraCnPTY5CnzkfFn7ef2Sd6uNAsoWySIulPoOWAj1K2kNZ1K8jIzLNAsWnebW1bOtDquRLutARCoxtUopYIcDuJ4S0KGBicGRdqN6GALwsnj4gIa46a0KNCnzesnPTY5Cn5UHhdraAYDd3Ddf0KicJdDU5lqtUWtc4X0K0xpM1bMdteulP2f7Pu4WnuGBicGxF76PVEmRdmhMiO4gMkIcddDuGBcXCUcCdraCnjhIl8ipNZ1K0HjLESz9eOu7I1lPu4WnQ)W1higMkIcddsuFacJd1hiMVG6BoP06jagCmRpaXD86pC9wwFRcPEcPoK6BoP06LeBJO(JP(af74uuFAyIqg1K7MGf0KPjapvmdoMDeXDCf4gIa41tJw9r5Gq0tdteYOcryCOZnFbHRNsz1ty9TQEcA9Pjapvj2gr)y6y2XvGBicGxpf6uhul0sQjb3qeaxhGM8KRjJqQjTvoNRj3n8yicqtUB4UBOGMeryCOZnFbAYfEsapMMeZ6aZHjcQLu7I9ukC4gkWnebW1KCiUWJ8CoxtshMuA9eOu7I1lPu4WnKO(aeghQpqmFb13uk41NsH6ryzyQFI1ZVMUe13CsP1tam4ywFaI741Bz9uhs9egoK6BoP06LeBJO(JP(af74uu)HRV5KsRpWgJGVG6dadgv1Bz9TiK6jSvHuFZjLwVKyBe1Fm1hOyhNI6tdteYOMC3eSGMeHLHrTKAxSNsHd3qXVME90OvFAcWtfZGJzhrChxbUHiaE9TRpkheIEAyIqgvicJdDU5liC9ukREcRN66jO1NMa8uLyBe9JPJzhxbUHiaE9uupnA1tF9PjapvRglb0pMUulXaxbUHiaE9TRpkheIEAyIqgvicJdDU5liC9ukREcRVf1tqRpnb4PkX2i6hthZoUcCdra86PqN6GORwsnj4gIa46a0KNCnzesnPTY5Cn5UHhdraAYDd3Ddf0KicJdDU5lqtUWtc4X0KywhyomrqXnmvefgg6Oa3eI5Cf4gIa4Asoex4rEoNRjPdtkT(aXWuruyyqI6dqyCO(aX8fuVL17hg1e1NgMiK1VowpRVPuWRhHLHb41J0OER(iSoNB4g1dmmWkLO(dxVjAAnI1Bz9TqYqQN5W17Ntqdea98zPj3nblOjttaEQygCm7iI74kWnebWRNgT6jSEewggfkKg6HLl9ItuXkVEA0Qpnb4PkX2i6hthZoUcCdra86PrREoGWYWOGye8f0rWGrLIvE9uuF76JYbHONgMiKrfIW4qNB(ccxpLYQNW6Bv9e06ttaEQsSnI(X0XSJRa3qeaVEkQNgT6PV(0eGNkoGE(SuGBicGxF76JYbHONgMiKrfIW4qNB(ccxpLYQVf6uhebrlPMeCdraCDaAYtUMedri1K2kNZ1K7gEmebOj3nC3nuqtIimo05MVan5cpjGhttMMa8ubXi4lOJGbJkf4gIa413U(1Dc(10vqmc(c6iyWOsHbJ3qtYH4cpYZ5CnzlBeQpWgJGVG6dadgv1JamhgQpaHXH6deZxq9dt9tw)eR32TryicOEZ51Fmm1VUtWVMUo1bra1sQjb3qeaxhGM8KRjJqQjTvoNRj3n8yicqtUBcwqtsF9PjapvCa98zPa3qeaV(21VUtWVMUcfsd9WYLEXjQWaQnES(qvpbP(21ZWIBO4aZSMSEkRVvBQj3nC3nuqtk)oX4e7mhUJcPPtDq0rAj1KGBicGRdqtEY1Kri1K2kNZ1K7gEmebOj3nblOj3n8yicqHimo05MVG6BxpH1ZWIBuFOQNas36jO1NMa8uXm4y2re3XvGBicGxpDC9uVz9uOj3nC3nuqtk)oX4e7mhUJimo05MVaDQdQLtlPMeCdraCDaAYtUMmcPM0w5CUMC3WJHian5UjybnzAcWtfhqpFwkWnebWRVD90xFAcWtfIyCENHf3qbUHiaE9TRFDNGFnDf0a6iGHQWaQnES(qvpH1tCXvOwRRNoUEQRNI6BxpdlUHIdmZAY6PSEQ3utUB4UBOGMu(DIXj2zoChAaDeWq1PoOWBQLutcUHiaUoan5jxtgHutARCoxtUB4XqeGMC3eSGMmnb4Pc9qbpzrvGBicGxF76PVEewggf6HcEYIQyLRj3nC3nuqt20MCCIDMd3rpuWtwuDQdkCyTKAsWnebW1bOjTvoNRjxMq0TvoN3ftm1KIjMD3qbn56ob)A66uhuyQ1sQjb3qeaxhGMCHNeWJPjryzyumGOJCOigMJcEQIPTOQEz1t36BxpH1JWYWOgu0ty5CE3yXMIvE90Ovp91JWYWOqH0qpSCPxCIkw51tHM0w5CUMmLIVMDIcB2bDQdkCR0sQjb3qeaxhGMCHNeWJPjttaEQ4a65ZsbUHiaUMmM4zL6GcRjTvoNRjXSE3w5CExmXutkMy2Ddf0KCa98zPtDqHBHwsnj4gIa46a0K2kNZ1KywVBRCoVlMyQjftm7UHcAs)WOMqN6utYb0ZNLwsDqH1sQjb3qeaxhGMCHNeWJPjttaEQyDKJ159Lu7IkWnebWRVD9iSmmkwh5yDEFj1UOIvE9TRNW6xsnmriwVS6PUEA0QNW6X2W7Wo4Pc92buWt141tz9H3S(21JTH3HDWtLX5r141tz9H3SEkQNcnPTY5Cnjdi6y2OuDQdIATKAsWnebW1bOjx4jb8yAYDdpgIauicJdDU5lqtARCoxtYblL2JnbqUo1b1kTKAsWnebW1bOjx4jb8yAsBLZo0bhqhiwpL1ZH4GbEpnmriJ1tJw9yB4Dyh8uzCEunE9uwF4n1K2kNZ1Kef2Sd9eqLdXuN6GAHwsnj4gIa46a0Kl8KaEmn56Co7KQiGXwc8orHn7GcCdra86Bx)6ob)A6kOb0radvHbuB8y9HQEcs9TRN(6ryzyuOqAOhwU0lorfR86Bxp91Zbewggf0A5xe49MhRZvSY1K2kNZ1KPu81StuyZoOtDq0vlPMeCdraCDaAYfEsapMM0w5SdDWb0bI1tz9CioyG3tdteYy90Ovp2gEh2bpvgNhvJxpL1tnDRVD9ewp91VB4XqeGIncDOb0radTZWIB0xNZNCoVEA0QpkheIEAyIqgRNY6dxpnA1ZWIBuFOQNaUz9uOjTvoNRjHgqhbmuDQdIGOLutcUHiaUoan5cpjGhttUB4XqeGcryCOZnFb13UE6RFDNGFnDfkKg6HLl9ItuHbJ3O(21ty9R7e8RPRGgqhbmufgqTXJ1tz90TEA0QNW6X2W7Wo4PY48OA86PSEBLZ591Dc(10RVD9yB4Dyh8uzCEunE9HQEQPB9uupfAsBLZ5AseHXHo38fOtDqeqTKAsBLZ5AYbf9ewoN3nwSPjb3qeaxhGo1brhPLutcUHiaUoan5cpjGhttsF97gEmebOKFNyCIDMd3regh6CZxGM0w5CUM0CFKoclNZ1PoOwoTKAsWnebW1bOjx4jb8yAsgwCdfhyM1K1tPS6BXMAsBLZ5AsgqGimoOtDqH3ulPM0w5CUMeIrWxqhbdgvAsWnebW1bOtDqHdRLutcUHiaUoan5cpjGhttsF97gEmebOKFNyCIDMd3regh6CZxq9TRN(63n8yicqj)oX4e7mhUdnGocyOAsBLZ5AYLu7I9yIhQaDQdkm1Aj1KGBicGRdqtARCoxtYb0ZJDKjbn5cpjGhttIzDG5Webfcl2hNyV5X6Cf4gIa413UEoGWYWOqyX(4e7npwNRWaQnES(qvFl0KRglb0tdteYOoOW6uhu4wPLutcUHiaUoan5cpjGhttsF9PjapvCa98oIW4qubUHiaE9TRpkheIEAyIqgRNY6dxF76jS(LudteI1lREQRNgT6jSESn8oSdEQqVDaf8unE9uwF4nRVD9yB4Dyh8uzCEunE9uwF4nRNI6PqtARCoxtYaIoMnkvN6Gc3cTKAsBLZ5AsoGEESJmjOjb3qeaxhGo1bfMUAj1KGBicGRdqtUWtc4X0KiSmmQJn7hthBorqXkxtARCoxtMsXxZorHn7Go1bfMGOLutcUHiaUoan5cpjGhttIE7ak4PIpX08fupL1hMU1tJw9iSmmQJn7hthBorqXkxtARCoxtYaIoMnkvN6Gcta1sQjb3qeaxhGMCHNeWJPjrVDaf8uXNyA(cQNY6dtxnPTY5Cn5o4ebgwrhdjgSuN6GcthPLutcUHiaUoan5cpjGhttMMa8uXb0Z7icJdrf4gIa4AsBLZ5AYuk(A2jkSzh0Po1KR7e8RPRLuhuyTKAsWnebW1bOjx4jb8yAs6Rpnb4PIdONplf4gIa413U(1Dc(10vqdOJagQcdO24X6PSEQ3S(21ty90x)62b38uTdEkTbUEA0QN(65xQIJZWk6iyZ5QCwunoX6POEA0QNzikn7ya1gpwFOQNA6QjTvoNRjrH0qpSCPxCI6uhe1Aj1KGBicGRdqtUWtc4X0KPjapvCa98zPa3qeaV(21ty9R7e8RPRGgqhbmufgqTXJ1tz9uVz9TRNW6PV(DdpgIauicJdDU5lOEA0QFDNGFnDfIW4qNB(cuya1gpwpL1tCXvOwRRNI6PO(21ty90x)62b38uTdEkTbUEA0QN(65xQIJZWk6iyZ5QCwunoX6POEA0QNzikn7ya1gpwFOQNA6QjTvoNRjrH0qpSCPxCI6uhuR0sQjb3qeaxhGMCHNeWJPjryzyuOqAOhwU0lorfgqTXJ1tz9ut36PrREKlgRVD9mdrPzhdO24X6dv9eKn1K2kNZ1KYVCoxN6GAHwsnj4gIa46a0KCiUWJ8CoxtgiaJXkY6zJq9tcO1loIZstUWtc4X0K7gEmebOs84ubzp2Wx9O4Y6LvF46BxpH1JWYWOqH0qpSCPxCIkw51tJw9ewp91NMa8uXb0ZNLcCdra86Bx)6ob)A6kuin0dlx6fNOcdO24X6PSEcRNzikn7ya1gpwpLT81N4XPcsvgwTUtWVMUIZITCoV(nQN66POEkQNgT6zgIsZogqTXJ1hkz1t9M1tr90OvpH1VB4XqeGkXJtfK9ydF1JIlRxw9uxF76PV(epovqQsQvR7e8RPRWGXBupf1tJw90x)UHhdraQepovq2Jn8vpkUutgfxg1KjECQGmSM0w5CUMKnc9jb0Oo1brxTKAsWnebW1bOjTvoNRjzJqFsanQjx4jb8yAYDdpgIaujECQGShB4REuCz9YQN66BxpH1JWYWOqH0qpSCPxCIkw51tJw9ewp91NMa8uXb0ZNLcCdra86Bx)6ob)A6kuin0dlx6fNOcdO24X6PSEcRNzikn7ya1gpwpLT81N4XPcsvsTADNGFnDfNfB5CE9Bup11tr9uupnA1ZmeLMDmGAJhRpuYQN6nRNI6PrREcRF3WJHiavIhNki7Xg(QhfxwVS6dxF76PV(epovqQYWQ1Dc(10vyW4nQNI6PrRE6RF3WJHiavIhNki7Xg(QhfxQjJIlJAYepovqsTo1brq0sQjb3qeaxhGMCHNeWJPjPVE(LQ44mSIoc2CUkNfvJtutARCoxtghNHv0rWMZ1PoicOwsnj4gIa46a0Kl8KaEmnj91NMa8uXb0ZNLcCdra86Bxp91VB4XqeGQPn54e7mhUJEOGNSO13UE6RF3WJHiaL87eJtSZC4okKw90OvpcldJIHfphBSt0c0ckw5AsBLZ5AYuk0LY6Po1brhPLutcUHiaUoan5cpjGhttsy92kNDOdoGoqSEkRNdXbd8EAyIqgRNgT6X2W7Wo4PY48OA86PS(wTz9uOjTvoNRjbrJ4yENdlma6uNAs5yyDOiwQLuhuyTKAsBLZ5AsKltbW7mcRbWBooXEETECnj4gIa46a0PoiQ1sQjb3qeaxhGM8KRjJqQjTvoNRj3n8yicqtUBcwqtgwtUWtc4X0KjECQGuLHvsTypMwQmVrNlpwF76jSE6RpXJtfKQKALul2JPLkZB05YJ1tJw9jECQGuLHvR7e8RPR4SylNZRNsz1N4XPcsvsTADNGFnDfNfB5CE9uOj3nC3nuqtM4XPcYESHV6rXL6uhuR0sQjb3qeaxhGM8KRjJqQjTvoNRj3n8yicqtUBcwqtsTMCHNeWJPjt84ubPkPwj1I9yAPY8gDU8y9TRNW6PV(epovqQYWkPwShtlvM3OZLhRNgT6t84ubPkPwTUtWVMUIZITCoVEkRpXJtfKQmSADNGFnDfNfB5CE9uOj3nC3nuqtM4XPcYESHV6rXL6uhul0sQjb3qeaxhGM8KRjJqQjTvoNRj3n8yicqtUBcwqtMMa8uHigN3zyXnuGBicGxF76jSEmRdmhMiO4gMkIcddDuGBcXCUcCdra86PrR(0eGNkoGEEhryCiQa3qeaVEk0KCiUWJ8Coxt2YgH6dSnG6dam06TSEX1SEcawCJ6BoP06dqmoVEcawCJ6xhkY4aV(MtkTEysPaU(aXWuruyyO(dxFGaONxFacJdrn5UH7UHcAs2i0Hgqhbm0odlUrFDoFY5CDQtDQtDQ1]] )


end
