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


    spec:RegisterPack( "Havoc", 20210308, [[d0upcbqicLfrPe1JOukBse9jrGrrj1POuSkiuYROKmlKOBrqu7IIFjsmmrshdcwMIONjcAAqO6AeK2MiK(gesnoccoNieADqizEqiUhb2hb1bfHGfsO6HIq1efHIlsPeSrkLQ8rkLQAKqOuNuekTsfPzkcr3KsPIDIK6NukrAOukHSucI8uatfj8vccnwiuSxe)vudgLdtAXk8yHMmQUSQndPpdrJMqoTKvtPeQxRimBIUnq7MQFR0WPehNsPslhQNly6sDDKA7kQVlsnEkL05rswpLseZNs1(bnbbcfeaU2Nq9KPojcPMWufcMjrqOjmHiAcqtLLtaSOXjuKNa4k4jai268gjawuQKRYjuqaclnoEcaqbsl1UwpXXkAtag0LStSozqa4AFc1tM6KiKActviyMebHMWeMqcqWYJeQfkIgrtaevC(DYGaWFisasmhCDidXM27JHmeBDEJWP2okokcYecucztM6KiaNcNM4Iuh5dik4uHmKz78wbxSfrBOcqM6CiZw0216qgDqrEiZwEC0fFidTqkQHS78GTmKjxKveYuUTy6qFoK1lKPwSiPcYwxsfK1lKn2qaYqlKI6GHaybVOL8eaBZ2GSeZbxhYqSP9(yidXwN3iCQTzBqMTJIJIGmHaLq2KPojcWPWP2MTbzjUi1r(aIco12Snitidz2oVvWfBr0gQaKPohYSfTDToKrhuKhYSLhhDXhYqlKIAi7opyldzYfzfHmLBlMo0Ndz9czQflsQGS1Lubz9czJneGm0cPOoyGtHt1yxRhmwWpUGdTfm2ULNNrLkvNNUCK5ET1YHtHtTnBdYSfS1hP7ZHSpFmvqwxGhYArhY0yVyiRcqMoRLuhYBGt1yxRheWRaM2sdNQXUwpyLGuIRhObFgurwr4uBZ2GmH4Hm(6jOHm(czTOkazTIr(gYcPvlwkhjK1lKPwSiPcYeNg7LJeYeIlTZHtTnBdY0yxRhSsqk43kg57Ss3Bw7wJtqPS8NJCbiqzRyKVZfQaWYru8pOrrndASxoYC6L25g8b1YduwOcW0(rxmYBg0yVCK50lTZt2Q8EB4hC98qQ8hm31H8C4uBdYeIvlAPBilXfPBaYOq0xmvuczIlv(HSeJ6XdzPRweKz7v4qdzIl3LdzlgY0gYsOvqM1tAfKLUArqgfyTKq2Iczcj6YTbYAfJ8DaovJDTEWkbPmR4shYtPRGxWqQ8N5QhpLfQaXW0(rxmYBII0nKBrFXur5SkPVGwL3BdAHdDEi3LBURd552ThSCPm3kg57Gziv(ZC1JhbHfyDcfYTkV3MgRLmVOzmD5M76qEUnWP2gKjeRweKL4I0nazui6lMkkHmXLk)qwIr94HS0IUdzTOdzdAuuiRcqgFt7uczPRweKz7v4qdzIl3LdzAdztAfKzncwbzPRweKrbwljKTOqMqIUCBGSfdzPRweKzlec3JhYehFDcitBidXTcYSoHwbzPRweKrbwljKTOqMqIUCBGSwXiFhGt1yxRhSsqkZkU0H8u6k4fmKk)zU6XtzHkat7hDXiVjks3qUf9ftfLZQK(cg0OOMOiDd5w0xmvg(M2TBVv592Gw4qNhYD5M76qEEYGLlL5wXiFhmdPYFMRE8iiSaRNui3Q8EBASwY8IMX0LBURd552y3UyTkV3Mivr5ZlAwK24Zn31H88KblxkZTIr(oygsL)mx94rqybwJ4c5wL3BtJ1sMx0mMUCZDDip3g4un216bReKYSIlDipLUcEbw2vwoYm6IZGVvkNvj9fiwRY7THFW1RO5UoKNNmURKVPDd4BfCXweTHkyWhulpGijAsuAmvg(rRy1cNWuHt1yxRhSsqkZkU0H8u6k4fyzxz5iZOlopKk)zU6Xt5SkPVGzfx6qEZqQ8N5QhFsRrPXuHiiAHkKBvEVnOfo05HCxU5UoKNJynzQ2aNQXUwpyLGuMvCPd5P0vWlWYUYYrMrxC(u984kiLZQK(cAvEVn8dUEfn31H88KI1Q8EBgYY5zuAmvM76qEEY4Us(M2nNQNhxbn4dQLhqeRrg5gq1wrSM0MKO0yQm8JwXQfEYuHt1yxRhSsqkZkU0H8u6k4fKwRUCKz0fNFiCp(8aFDckNvj9f0Q8EBEiCp(8aFDcZDDippPyZkU0H8gl7klhzgDX5Hu5pZvp(KInR4shYBSSRSCKz0fNbFRjJ7k5BA38q4E85b(6egAlWPASR1dwjiLzfx6qEkDf8csRvxoYm6IZGl49MgKYzvsFbTkV3gWf8EtdAURd55jfBqJIAaxW7nnOH2cCQg7A9GvcsjQszwJDTEwwHMsxbVG4Us(M2Ht1yxRhSsqkTi8MoJuQ18PSqfmOrrnOxMhl4qXCW7Tj0ACcbcnP1dAuutbcUsTR1Zknwn0wSBxSbnkQb8TcUylI2qfm0wSbovJDTEWkbPevPmRXUwplRqtPRGxWdH7XNh4RtqzOXvSfGaLfQGwL3BZdH7XNh4RtyURd55jTEwXLoK3KwRUCKz0fNFiCp(8aFDc725FqJIAEiCp(8aFDcdTfBGt1yxRhSsqkyApRXUwplRqtPRGxa)GRxrkdnUITaeOSqf0Q8EB4hC9kAURd55WPASR1dwjifmTN1yxRNLvOP0vWlWxmOkHtHt1yxRhmXDL8nTla8TcUylI2qfOSqfiM1TkV3g(bxVIM76qEUD7ZkU0H8gl7klhzgDXzW3QnjJ7k5BA3CQEECf0GpOwEq4jtnP1If357Q3M57TiQWM76qEUD7IX32ekhLwMhy15MUItuosBSBFSHqs0cPOoJpOwEarMuOWPASR1dM4Us(M2TsqkGVvWfBr0gQaLfQGwL3Bd)GRxrZDDippP1XDL8nTBovppUcAWhulpi8KPM0AXMvCPd5ndPYFMRE82Th3vY30Uziv(ZC1J3GpOwEqyKrUbuTvBSjP1If357Q3M57TiQWM76qEUD7IX32ekhLwMhy15MUItuosBGt1yxRhmXDL8nTBLGucLJslZdS6CklubIX32ekhLwMhy15MUItuos4un216btCxjFt7wjiLw0ZIO9MYcvGyTkV3g(bxVIM76qEEsXMvCPd5nP1QlhzgDXzWf8EtdA3(Ggf1GsJRLoKrQ2sUH2cCQg7A9GjURKVPDReKYLufk1Z8hX)uwOcSwJDn)89dwpim)HcFEUvmY3b72XAXZF(EBuopykx4eMQnWPASR1dM4Us(M2Tsqkw2UwNYcvWGgf1a(wbxSfrBOcg8b1YdcpPqTBFSHqs0cPOoJpOwEars0uHtTnilXCuLw2qgQkLdnobKHUyiJoOd5HSQpyWaNQXUwpyI7k5BA3kbPqhEU6dgOSqfmOrrnGVvWfBr0gQGH2cCkCQg7A9GHFW1ROa0lZy6Giklubw3Q8EBO9Xs78CuKUbZDDipp5Ggf1q7JL255OiDdgAl2K06OifJ8bbtA3U1yT45pFVnG78bV3MYfgHutI1IN)892OCEWuUWiKQn2aNQXUwpy4hC9kALGu4xBr5q6FluwOcMvCPd5ndPYFMRE8WPASR1dg(bxVIwjifKsTMFUpOLhAklubASR5NVFW6bH5pu4ZZTIr(oy3owlE(Z3BJY5bt5cJqQWPASR1dg(bxVIwjiLweEtNrk1A(uwOcIRZPR2eogR95zKsTMV5UoKNNmURKVPDZP65Xvqd(GA5bejrtk2Ggf1a(wbxSfrBOcgAljfJ)bnkQ52QLnCEo9s7CdTf4un216bd)GRxrReKYP65XvqklubyT45pFVnkNhm0wSBhRfp)57Tr58GPCHNuOWPASR1dg(bxVIwjiLHu5pZvpEklubZkU0H8MHu5pZvp(KIf3vY30Ub8TcUylI2qfm4RCQsADCxjFt7Mt1ZJRGg8b1Ydclu72TgRfp)57Tr58GPCHJ7k5BApjwlE(Z3BJY5bt5iYKc1gBGt1yxRhm8dUEfTsqkfi4k1UwpR0yfovJDTEWWp46v0kbPOUxIkP216uwOceBwXLoK3yzxz5iZOlopKk)zU6XdNQXUwpy4hC9kALGuqVCiv(PSqfGsJPYWpAfRwybiEQWPASR1dg(bxVIwjiLOiDd5qJRjoLfQaXMvCPd5nw2vwoYm6IZdPYFMRE8jfBwXLoK3yzxz5iZOloFQEECfeovJDTEWWp46v0kbPGEzgtherzHkOv592Wp465Hu5pyURd55jflURKVPDZP65Xvqd(kNQKwhfPyKpiys72TgRfp)57TbCNp492uUWiKAsSw88NV3gLZdMYfgHuTXg4un216bd)GRxrReKc)GRhYJQpLrQIYNBfJ8DqacuwOcW0(rxmYBg0yVCK50lTZtY)Ggf1mOXE5iZPxANBWhulpGiioCQg7A9GHFW1ROvcsHFW1d5r1hovJDTEWWp46v0kbP0IWB6msPwZNYcvWGgf1S0DErZy1rEdTf4un216bd)GRxrReKc6LzmDqeLfQaWD(G3BdVcT6Xlmcc1U9bnkQzP78IMXQJ8gAlWPASR1dg(bxVIwjiL57ipkTmJFJV2uwOca35dEVn8k0QhVWiiu4un216bd)GRxrReKslcVPZiLAnFklubTkV3g(bxppKk)bZDDiphofovJDTEW8q4E85b(6ecEiCp(8aFDcklubO0yQewGqi1Kwh3vY30Uziv(ZC1J3GVYPYUDXMvCPd5ndPYFMRE82aNQXUwpyEiCp(8aFDcReKc)Alkhs)BHYcvWSIlDiVziv(ZC1Jpj)dAuuZdH7XNh4RtyOTaNQXUwpyEiCp(8aFDcReKYqQ8N5QhpLfQGzfx6qEZqQ8N5QhFs(h0OOMhc3JppWxNWqBbovJDTEW8q4E85b(6ewjif19suj1UwNYcva)dAuuZdH7XNh4RtyOTaNQXUwpyEiCp(8aFDcReKsuKUHCOX1eNYcva)dAuuZdH7XNh4RtyOTaNcNQXUwpy8fdQsbZ3rEuAzg)gFTPSqf0Q8EBaxW7nnO5UoKNNCqJIASGVffFUHVP9KDbEHraovJDTEW4lguLwjif0lZy6GiklubwpR4shYBsRvxoYm6IZGl49Mg0U9wL3BdTpwANNJI0nyURd55jh0OOgAFS0ophfPBWqBXMKwhfPyKpiys72TgRfp)57TbCNp492uUWiKAsSw88NV3gLZdMYfgHuTXg4un216bJVyqvALGuqVmpumwrEklubASR5NVFW6bH5pu4ZZTIr(oy3owlE(Z3BJY5bt5cNWuHt1yxRhm(IbvPvcsHFTfLdP)TqzHkywXLoK3mKk)zU6XdNQXUwpy8fdQsReKsbcUsTR1ZknwHt1yxRhm(IbvPvcsbPuR5N7dA5HMYcvGyZkU0H8M0A1LJmJU4m4cEVPbtATg7A(57hSEqy(df(8CRyKVd2TJ1IN)892OCEWuUWiKQnWPASR1dgFXGQ0kbP0IWB6msPwZNYcvqCDoD1MWXyTppJuQ18n31H88KXDL8nTBovppUcAWhulpGijAsXg0OOgW3k4ITiAdvWqBjPy8pOrrn3wTSHZZPxANBOTaNQXUwpy8fdQsReKYP65XvqklubInR4shYBsRvxoYm6IZGl49MgmP1ASR5NVFW6bH5pu4ZZTIr(oy3owlE(Z3BJY5bt5cJGqTbovJDTEW4lguLwjiLHu5pZvpEklubZkU0H8MHu5pZvpE4un216bJVyqvALGuqVCiv(PSqfGsJPYWpAfRwybiEQWPASR1dgFXGQ0kbPOUxIkP216uwOcSUv592Wp465Hu5pyURd552Tl2SIlDiVjTwD5iZOlodUG3BAq72rPXuz4hTIvJijmv72h0OOgW3k4ITiAdvWGpOwEareQnjfBwXLoK3yzxz5iZOlopKk)zU6XNuSzfx6qEtAT6YrMrxC(HW94Zd81jGt1yxRhm(IbvPvcsjks3qo04AItzHkW6wL3Bd)GRNhsL)G5UoKNB3UyZkU0H8M0A1LJmJU4m4cEVPbTBhLgtLHF0kwnIKWuTjPyZkU0H8gl7klhzgDXzW3AsXMvCPd5nw2vwoYm6IZdPYFMRE8jfBwXLoK3KwRUCKz0fNFiCp(8aFDc4un216bJVyqvALGuovppUcszHkOv592mKLZZO0yQm31H88KyT45pFVnkNhmLlCCxjFt7WPASR1dgFXGQ0kbPWp46H8O6tzKQO85wXiFheGaLfQamTF0fJ8Mbn2lhzo9s78K8pOrrndASxoYC6L25g8b1YdicIdNQXUwpy8fdQsReKc)GRhYJQpCQg7A9GXxmOkTsqkOxMX0bruwOceRv592aUG3BAqZDDippjwlE(Z3Bd4oFW7TPCHJIumYhqSqi1KTkV3g(bxppKk)bZDDiphovJDTEW4lguLwjif0lhsLFklubG78bV3gEfA1JxyeeQD7dAuuZs35fnJvh5n0wGt1yxRhm(IbvPvcsb9YmMoiIYcva4oFW7THxHw94fgbHA3U1dAuuZs35fnJvh5n0wskwRY7TbCbV30GM76qEUnWPASR1dgFXGQ0kbPmFh5rPLz8B81MYcva4oFW7THxHw94fgbHcNQXUwpy8fdQsReKslcVPZiLAnFklubTkV3g(bxppKk)bZDDipNamFCOwNq9KPojcPMWur0eG0k2lhzGaieteesuNyP22hrbzqgfIoKvGwwCdzOlgYsGVyqvMaidFBx6cFoKfwWdzkDVGAFoKffPoYhmWPjYYpKHaIJOGSeF95J7ZHSeGP9JUyK3GysaK1lKLamTF0fJ8geJ5UoKNNaiZAeSvBmWPWPcXebHe1jwQT9ruqgKrHOdzfOLf3qg6IHSeWpQsl7eaz4B7sx4ZHSWcEitP7fu7ZHSOi1r(Gbonrw(HSeIOGSeF95J7ZHSeGP9JUyK3GysaK1lKLamTF0fJ8geJ5UoKNNaitBiZwWwAIeYSgbB1gdCAIS8dzioIcYs81NpUphYsaM2p6IrEdIjbqwVqwcW0(rxmYBqmM76qEEcGmTHmBbBPjsiZAeSvBmWPWPcXebHe1jwQT9ruqgKrHOdzfOLf3qg6IHSee3vY30EcGm8TDPl85qwybpKP09cQ95qwuK6iFWaNMil)qgcikilXxF(4(CilbXD(U6TbXyURd55jaY6fYsqCNVREBqmjaYSgbB1gdCAIS8dztIOGSeF95J7ZHSee357Q3geJ5UoKNNaiRxilbXD(U6TbXKaiZAeSvBmWPWPcXebHe1jwQT9ruqgKrHOdzfOLf3qg6IHSeWp46vmbqg(2U0f(CilSGhYu6Eb1(CilksDKpyGttKLFidHjruqwIV(8X95qwcW0(rxmYBqmjaY6fYsaM2p6IrEdIXCxhYZtaKznc2Qng4u40elOLf3NdzjkKPXUwhYKvOdg4ucGs3IwmbaOatCcGScDGqbbWxmOkjuqOgbcfeG76qEorCcqex9XLsaAvEVnGl49Mg0CxhYZHSKq2Ggf1ybFlk(CdFt7qwsiRlWdzcdziqa0yxRtaMVJ8O0Ym(n(AtAc1tsOGaCxhYZjItaI4QpUucG1q2SIlDiVjTwD5iZOlodUG3BAqiZUDiRv592q7JL255OiDdM76qEoKLeYg0OOgAFS0ophfPBWqBbYSbYsczwdzrrkg5dqMaiBsiZUDiZAidRfp)57TbCNp492uoKjmKHqQqwsidRfp)57Tr58GPCityidHuHmBGmBiaASR1jaOxMX0brKMqDcjuqaURd55eXjarC1hxkbqJDn)89dwpazcdz8hk855wXiFhGm72HmSw88NV3gLZdMYHmHHSeMkbqJDToba9Y8qXyf5jnHAeNqbb4UoKNteNaeXvFCPeGzfx6qEZqQ8N5QhpbqJDTobGFTfLdP)TqAc1cLqbbqJDTobOabxP216zLgReG76qEorCstOorjuqaURd55eXjarC1hxkbqmiBwXLoK3KwRUCKz0fNbxW7nniKLeYSgY0yxZpF)G1dqMWqg)HcFEUvmY3biZUDidRfp)57Tr58GPCityidHuHmBiaASR1jaiLAn)CFqlp0KMqnIMqbb4UoKNteNaeXvFCPeG46C6QnHJXAFEgPuR5BURd55qwsilURKVPDZP65Xvqd(GA5bidrGSefYsczIbzdAuud4BfCXweTHkyOTazjHmXGm(h0OOMBRw2W550lTZn0wiaASR1jaTi8MoJuQ18jnHAHaHccWDDipNiobiIR(4sjaIbzZkU0H8M0A1LJmJU4m4cEVPbHSKqM1qMg7A(57hSEaYegY4pu4ZZTIr(oaz2TdzyT45pFVnkNhmLdzcdziiuiZgcGg7ADcWP65XvqstOorKqbb4UoKNteNaeXvFCPeGzfx6qEZqQ8N5QhpbqJDTobyiv(ZC1JN0eQrivcfeG76qEorCcqex9XLsaqPXuz4hTIvdzclaYq8ujaASR1jaOxoKk)KMqnciqOGaCxhYZjItaI4QpUucG1qwRY7THFW1ZdPYFWCxhYZHm72HmXGSzfx6qEtAT6YrMrxCgCbV30GqMD7qgknMkd)OvSAidrGSeMkKz3oKnOrrnGVvWfBr0gQGbFqT8aKHiqMqHmBGSKqMyq2SIlDiVXYUYYrMrxCEiv(ZC1JhYsczIbzZkU0H8M0A1LJmJU48dH7XNh4Rtqa0yxRtau3lrLu7ADstOgHjjuqaURd55eXjarC1hxkbWAiRv592Wp465Hu5pyURd55qMD7qMyq2SIlDiVjTwD5iZOlodUG3BAqiZUDidLgtLHF0kwnKHiqwctfYSbYsczIbzZkU0H8gl7klhzgDXzW3kKLeYedYMvCPd5nw2vwoYm6IZdPYFMRE8qwsitmiBwXLoK3KwRUCKz0fNFiCp(8aFDccGg7ADcquKUHCOX1eN0eQriHekia31H8CI4eGiU6JlLa0Q8EBgYY5zuAmvM76qEoKLeYWAXZF(EBuopykhYegY0yxRNJ7k5BANaOXUwNaCQEECfK0eQraXjuqaURd55eXjaASR1ja8dUEipQ(eGiU6JlLaGP9JUyK3mOXE5iZPxANBURd55qwsiJ)bnkQzqJ9YrMtV0o3GpOwEaYqeidXjarQIYNBfJ8DGqncKMqnccLqbbqJDTobGFW1d5r1NaCxhYZjItAc1iKOekia31H8CI4eGiU6JlLaigK1Q8EBaxW7nnO5UoKNdzjHmSw88NV3gWD(G3Bt5qMWqwuKIr(aKHybziKkKLeYAvEVn8dUEEiv(dM76qEobqJDToba9YmMoiI0eQrartOGaCxhYZjItaI4QpUuca4oFW7THxHw94HmHHmeekKz3oKnOrrnlDNx0mwDK3qBHaOXUwNaGE5qQ8tAc1iieiuqaURd55eXjarC1hxkbaCNp492WRqRE8qMWqgccfYSBhYSgYg0OOMLUZlAgRoYBOTazjHmXGSwL3Bd4cEVPbn31H8CiZgcGg7ADca6LzmDqePjuJqIiHccWDDipNiobiIR(4sjaG78bV3gEfA1JhYegYqqOean216eG57ipkTmJFJV2KMq9KPsOGaCxhYZjItaI4QpUucqRY7THFW1ZdPYFWCxhYZjaASR1jaTi8MoJuQ18jnPja8JQ0YMqbHAeiuqa0yxRta4vatBPja31H8CI4KMq9KekiaASR1jaX1d0GpdQiRib4UoKNteN0eQtiHccWDDipNiobyTqacVjaASR1jaZkU0H8eGzfNDf8eGHu5pZvpEcqex9XLsaedYW0(rxmYBII0nKBrFXuzURd55ea(drCzPR1jacXQfT0nKL4I0nazui6lMkkHmXLk)qwIr94HS0vlcYS9kCOHmXL7YHSfdzAdzj0kiZ6jTcYsxTiiJcSwsiBrHmHeD52azTIr(oqaMvj9jaTkV3g0ch68qUl3CxhYZHm72HSGLlL5wXiFhmdPYFMRE8iazclaYSgYsiKjKHSwL3BtJ1sMx0mMUCZDDiphYSH0eQrCcfeG76qEorCcWAHaeEta0yxRtaMvCPd5jaZko7k4jadPYFMRE8eGiU6JlLaGP9JUyK3efPBi3I(IPYCxhYZja8hI4YsxRtaeIvlcYsCr6gGmke9ftfLqM4sLFilXOE8qwAr3HSw0HSbnkkKvbiJVPDkHS0vlcYS9kCOHmXL7YHmTHSjTcYSgbRGS0vlcYOaRLeYwuitirxUnq2IHS0vlcYSfcH7XdzIJVobKPnKH4wbzwNqRGS0vlcYOaRLeYwuitirxUnqwRyKVdeGzvsFcWGgf1efPBi3I(IPYW30oKz3oK1Q8EBqlCOZd5UCZDDiphYsczblxkZTIr(oygsL)mx94raYewaKznKnjKjKHSwL3BtJ1sMx0mMUCZDDiphYSbYSBhYedYAvEVnrQIYNx0SiTXNBURd55qwsily5szUvmY3bZqQ8N5QhpcqMWcGmRHmehYeYqwRY7TPXAjZlAgtxU5UoKNdz2qAc1cLqbb4UoKNteNaSwiaH3ean216eGzfx6qEcWSkPpbqmiRv592Wp46v0CxhYZHSKqwCxjFt7gW3k4ITiAdvWGpOwEaYqeilrHSKqgknMkd)OvSAityilHPsaMvC2vWtaSSRSCKz0fNbFRKMqDIsOGaCxhYZjItawleGWBcGg7ADcWSIlDipbywL0NamR4shYBgsL)mx94HSKqM1qgknMkidrGmeTqHmHmK1Q8EBqlCOZd5UCZDDiphYqSGSjtfYSHamR4SRGNayzxz5iZOlopKk)zU6XtAc1iAcfeG76qEorCcWAHaeEta0yxRtaMvCPd5jaZQK(eGwL3Bd)GRxrZDDiphYsczIbzTkV3MHSCEgLgtL5UoKNdzjHS4Us(M2nNQNhxbn4dQLhGmebYSgYqg5gq1wHmeliBsiZgiljKHsJPYWpAfRgYegYMmvcWSIZUcEcGLDLLJmJU48P65XvqstOwiqOGaCxhYZjItawleGWBcGg7ADcWSIlDipbywL0Na0Q8EBEiCp(8aFDcZDDiphYsczIbzZkU0H8gl7klhzgDX5Hu5pZvpEiljKjgKnR4shYBSSRSCKz0fNbFRqwsilURKVPDZdH7XNh4RtyOTqaMvC2vWtasRvxoYm6IZpeUhFEGVobPjuNisOGaCxhYZjItawleGWBcGg7ADcWSIlDipbywL0Na0Q8EBaxW7nnO5UoKNdzjHmXGSbnkQbCbV30GgAleGzfNDf8eG0A1LJmJU4m4cEVPbjnHAesLqbb4UoKNteNaOXUwNaevPmRXUwplRqtaKvOZUcEcqCxjFt7KMqnciqOGaCxhYZjItaI4QpUucWGgf1GEzESGdfZbV3MqRXjGmbqMqHSKqM1q2Ggf1uGGRu7A9SsJvdTfiZUDitmiBqJIAaFRGl2IOnubdTfiZgcGg7ADcqlcVPZiLAnFstOgHjjuqaURd55eXjarC1hxkbOv5928q4E85b(6eM76qEoKLeYSgYMvCPd5nP1QlhzgDX5hc3JppWxNaYSBhY4FqJIAEiCp(8aFDcdTfiZgcqOXvSjuJabqJDTobiQszwJDTEwwHMaiRqNDf8eGhc3JppWxNG0eQriHekia31H8CI4eGiU6JlLa0Q8EB4hC9kAURd55eGqJRytOgbcGg7ADcaM2ZASR1ZYk0eazf6SRGNaWp46vK0eQraXjuqaURd55eXjaASR1jayApRXUwplRqtaKvOZUcEcGVyqvsAsta4hC9ksOGqncekia31H8CI4eGiU6JlLaynK1Q8EBO9Xs78CuKUbZDDiphYsczdAuudTpwANNJI0nyOTaz2azjHmRHSOifJ8bitaKnjKz3oKznKH1IN)892aUZh8EBkhYegYqiviljKH1IN)892OCEWuoKjmKHqQqMnqMnean216ea0lZy6GistOEscfeG76qEorCcqex9XLsaMvCPd5ndPYFMRE8ean216ea(1wuoK(3cPjuNqcfeG76qEorCcqex9XLsa0yxZpF)G1dqMWqg)HcFEUvmY3biZUDidRfp)57Tr58GPCityidHujaASR1jaiLAn)CFqlp0KMqnItOGaCxhYZjItaI4QpUucqCDoD1MWXyTppJuQ18n31H8CiljKf3vY30U5u984kObFqT8aKHiqwIczjHmXGSbnkQb8TcUylI2qfm0wGSKqMyqg)dAuuZTvlB48C6L25gAlean216eGweEtNrk1A(KMqTqjuqaURd55eXjarC1hxkbaRfp)57Tr58GH2cKz3oKH1IN)892OCEWuoKjmKnPqjaASR1jaNQNhxbjnH6eLqbb4UoKNteNaeXvFCPeGzfx6qEZqQ8N5QhpKLeYedYI7k5BA3a(wbxSfrBOcg8vovqwsiZAilURKVPDZP65Xvqd(GA5bityitOqMD7qM1qgwlE(Z3BJY5bt5qMWqMg7A9CCxjFt7qwsidRfp)57Tr58GPCidrGSjfkKzdKzdbqJDTobyiv(ZC1JN0eQr0ekiaASR1jafi4k1UwpR0yLaCxhYZjItAc1cbcfeG76qEorCcqex9XLsaedYMvCPd5nw2vwoYm6IZdPYFMRE8ean216ea19suj1UwN0eQtejuqaURd55eXjarC1hxkbaLgtLHF0kwnKjSaidXtLaOXUwNaGE5qQ8tAc1iKkHccWDDipNiobiIR(4sjaIbzZkU0H8gl7klhzgDX5Hu5pZvpEiljKjgKnR4shYBSSRSCKz0fNpvppUcsa0yxRtaII0nKdnUM4KMqnciqOGaCxhYZjItaI4QpUucqRY7THFW1ZdPYFWCxhYZHSKqMyqwCxjFt7Mt1ZJRGg8vovqwsiZAilksXiFaYeaztcz2TdzwdzyT45pFVnG78bV3MYHmHHmesfYsczyT45pFVnkNhmLdzcdziKkKzdKzdbqJDToba9YmMoiI0eQryscfeG76qEorCcGg7ADca)GRhYJQpbiIR(4sjayA)Olg5ndASxoYC6L25M76qEoKLeY4FqJIAg0yVCK50lTZn4dQLhGmebYqCcqKQO85wXiFhiuJaPjuJqcjuqa0yxRta4hC9qEu9ja31H8CI4KMqncioHccWDDipNiobiIR(4sjadAuuZs35fnJvh5n0wiaASR1jaTi8MoJuQ18jnHAeekHccWDDipNiobiIR(4sjaG78bV3gEfA1JhYegYqqOqMD7q2Ggf1S0DErZy1rEdTfcGg7ADca6LzmDqePjuJqIsOGaCxhYZjItaI4QpUuca4oFW7THxHw94HmHHmeekbqJDToby(oYJslZ434RnPjuJaIMqbb4UoKNteNaeXvFCPeGwL3Bd)GRNhsL)G5UoKNta0yxRtaAr4nDgPuR5tAstaEiCp(8aFDccfeQrGqbb4UoKNteNaeXvFCPeauAmvqMWcGmHqQqwsiZAilURKVPDZqQ8N5QhVbFLtfKz3oKjgKnR4shYBgsL)mx94HmBiaASR1japeUhFEGVobPjupjHccWDDipNiobiIR(4sjaZkU0H8MHu5pZvpEiljKX)Ggf18q4E85b(6egAlean216ea(1wuoK(3cPjuNqcfeG76qEorCcqex9XLsaMvCPd5ndPYFMRE8qwsiJ)bnkQ5HW94Zd81jm0wiaASR1jadPYFMRE8KMqnItOGaCxhYZjItaI4QpUuca)dAuuZdH7XNh4RtyOTqa0yxRtau3lrLu7ADstOwOekia31H8CI4eGiU6JlLaW)Ggf18q4E85b(6egAlean216eGOiDd5qJRjoPjnbiURKVPDcfeQrGqbb4UoKNteNaeXvFCPeaXGmRHSwL3Bd)GRxrZDDiphYSBhYMvCPd5nw2vwoYm6IZGVviZgiljKf3vY30U5u984kObFqT8aKjmKnzQqwsiZAitmilUZ3vVnZ3BruHHm72HmXGm(2Mq5O0Y8aRo30vCIYrcz2az2TdzJneGSKqgAHuuNXhulpazicKnPqjaASR1jaGVvWfBr0gQaPjupjHccWDDipNiobiIR(4sjaTkV3g(bxVIM76qEoKLeYSgYI7k5BA3CQEECf0GpOwEaYegYMmviljKznKjgKnR4shYBgsL)mx94Hm72HS4Us(M2ndPYFMRE8g8b1YdqMWqgYi3aQ2kKzdKzdKLeYSgYedYI78D1BZ89wevyiZUDitmiJVTjuokTmpWQZnDfNOCKqMnean216eaW3k4ITiAdvG0eQtiHccWDDipNiobiIR(4sjaIbz8TnHYrPL5bwDUPR4eLJKaOXUwNaekhLwMhy15KMqnItOGaCxhYZjItaI4QpUucGyqwRY7THFW1RO5UoKNdzjHmXGSzfx6qEtAT6YrMrxCgCbV30GqMD7q2Ggf1GsJRLoKrQ2sUH2cbqJDTobOf9SiAVjnHAHsOGaCxhYZjItaI4QpUucG1qMg7A(57hSEaYegY4pu4ZZTIr(oaz2TdzyT45pFVnkNhmLdzcdzjmviZgcGg7ADcWLufk1Z8hX)KMqDIsOGaCxhYZjItaI4QpUucWGgf1a(wbxSfrBOcg8b1YdqMWq2KcfYSBhYgBiazjHm0cPOoJpOwEaYqeilrtLaOXUwNayz7ADstOgrtOGaCxhYZjIta0yxRtaOdpx9bdea(drCzPR1jajMJQ0YgYqvPCOXjGm0fdz0bDipKv9bdgcqex9XLsag0OOgW3k4ITiAdvWqBH0KMayb)4co0MqbHAeiuqa0yxRtagB3YZZOsLQZtxoYCV2A5eG76qEorCstAstAstia]] )
end
