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


    spec:RegisterPack( "Havoc", 20210307, [[d0KOcbqicvlIcvXJasztIsFsuWOOiDkkIvjQk6vuiZcj5wuOODrPFjkAyIQCmGyzkIEMOQAAirCnKO2MOq9nGKACuOKZbKQADajzEajUhszFivDqrHOfsO8qrvPjkkKUisKyJIcHpsHQQrIejDsGuLvQintrvHBsHQ0orQ8tkuQAOuOuAPuOWtbmvKWxrIuJfiv2lu)vKbJYHjTyfESqtgvxw1MH0NbQrtiNwYQPqPYRveMnr3gIDt1VvA4uWXPqvz5iEUGPl11jy7kQVlQmEku58iPwpfkfZNIA)GgdcMcmax7JPBY8MeK8YFEGAliglktzmqtTHJbmOXjuWhd4kYXauQ68gXaguQLRYXuGbcRajEmaqHii1UwpFjkAJbgcLSb9C8adW1(y6MmVjbjV8NhO2cIXIYucLb9XabdpIPJYGAqngquX53Xdma)Higa0anilJEK1HmkvbVpbYOu15ncNcAGgKz8QKOiideQGSjZBsqGtHtbnqdYYxrQd(bqfCkObAqMXeYmEFRilXGOnubitDoKzSD7ADitiOGpKz8mo6soKHwGf1q2DEW4bYKl4kczk3yNqOphY6fYudgKudzRlPgY6fYgBiazOfyrDWIbmqw0sEmaObAqwg9iRdzuQcEFcKrPQZBeof0aniZ4vjrrqgiubztM3KGaNcNcAGgKLVIuh8dGk4uqd0GmJjKz8(wrwIbrBOcqM6CiZy7216qMqqbFiZ4zC0LCidTalQHS78GXdKjxWveYuUXoHqFoK1lKPgmiPgYwxsnK1lKn2qaYqlWI6GfofovJDTEWAG84Im0M2y7wEEcvQuFEUYbN614khofof0aniJsX4EuOphY(8judzDHCiRfDitJ9sGSkaz6SwsDiVfovJDTEGgVcebdnCQg7A9Gr0YmUEqa5jefCfHtbnqdYO0hY4RNHgY4lK1IQaK1kb8BilKtnyOCWqwVqMAWGKAitmbIxoyiJsVcohof0anitJDTEWiAzsEReWVtQqVjTBnobvYYFkYPbcvTsa)ovO0qkhuX)qaf1oeiE5Gt5wbNBjhrlpqvHsJi4hDjGVDiq8YbNYTcopBRY7TLFK1tdPYFWExhYZHtbniJsxTOvOHS8vKUbiJcrFjutfKjMu5hYYOQhpKLRArqwgrrcnKjMCxoKTeitBil)gbzMoPrqwUQfbzuq0sczlkKzmek3eiRvc43b4un216bJOL5SskDipvUICAdPYFIRE8uvO0eNi4hDjGVnks3qQf9LqnvZQu40AvEVTOfj0PHCxU9UoKNB2CWWLYuReWVd2Hu5pXvpEqONMP53y2Q8EBBIwY0IMicLBVRd55MaNcAqgLUArqw(ks3aKrHOVeQPcYetQ8dzzu1JhYYj6oK1IoKneqrHSkaz8nNtfKLRArqwgrrcnKjMCxoKPnKnPrqMPGyeKLRArqgfeTKq2IczgdHYnbYwcKLRArqgLsiCpEitmY1jGmTHmkXiiZ08BeKLRArqgfeTKq2IczgdHYnbYALa(DaovJDTEWiAzoRKshYtLRiN2qQ8N4QhpvfknIGF0La(2OiDdPw0xc1unRsHtBiGIAJI0nKArFjuB5Bo3S5wL3BlArcDAi3LBVRd55zdgUuMALa(DWoKk)jU6Xdc90mDsJzRY7TTjAjtlAIiuU9UoKNBIzZI3Q8EBJuhLpTOjrAto3ExhYZZgmCPm1kb87GDiv(tC1Jhe6PzkLymBvEVTnrlzArteHYT31H8CtGt1yxRhmIwMZkP0H8u5kYPzyxz5GtOljH8wPAwLcNM4TkV3w(rwVI276qEE24Us(MZTiVvKLyq0gQGLCeT8aOKXzrfiuB5hTIvtF(ZdovJDTEWiAzoRKshYtLRiNMHDLLdoHUK0qQ8N4QhpvZQu40MvsPd5TdPYFIRE8znfvGqnOaQPSXSv592IwKqNgYD5276qEE(CY8mbovJDTEWiAzoRKshYtLRiNMHDLLdoHUK0P(PXveQMvPWP1Q8EB5hz9kAVRd55zfVv592oKLZtOceQT31H88SXDL8nNBp1pnUIyjhrlpakMcoYTiQXLpN0KSOceQT8JwXQPFY8Gt1yxRhmIwMZkP0H8u5kYPLtRUCWj0LKEiCp(0GCDcQMvPWP1Q8EBFiCp(0GCDc7DDippR4ZkP0H8wd7klhCcDjPHu5pXvp(SIpRKshYBnSRSCWj0LKqERzJ7k5Bo3(q4E8Pb56ewbdWPASR1dgrlZzLu6qEQCf50YPvxo4e6ssilY9waHQzvkCATkV3wKf5ElGyVRd55zfFiGIArwK7TaIvWaCQg7A9Gr0YmQszsJDTEswHMkxroT4Us(MZHt1yxRhmIwMTiYMlbwQ18PQqPneqrTOxMglYqjCK7Tn0ACcAuoRPdbuuBHGSsTR1tQarTcgmBw8HakQf5TISedI2qfScgmbovJDTEWiAzgvPmPXUwpjRqtLRiN2dH7XNgKRtqvOjvSPbcvfkTwL3B7dH7XNgKRtyVRd55znDwjLoK3MtRUCWj0LKEiCp(0GCDcZM5FiGIAFiCp(0GCDcRGbtGt1yxRhmIwMebpPXUwpjRqtLRiNg)iRxrQcnPInnqOQqP1Q8EB5hz9kAVRd55WPASR1dgrltIGN0yxRNKvOPYvKtZxcIkHtHt1yxRhSXDL8nNtd5TISedI2qfOQqPjUPTkV3w(rwVI276qEUzZZkP0H8wd7klhCcDjjK3QjzJ7k5Bo3EQFACfXsoIwEG(jZlRPIh357Q3257TiQj276qEUzZIZ32gkhvqMge152UItuoytmBESHqw0cSOoroIwEauMKYWPASR1d24Us(MZnIwMiVvKLyq0gQavfkTwL3Bl)iRxr7DDippRPXDL8nNBp1pnUIyjhrlpq)K5L1uXNvsPd5TdPYFIRE8Mnh3vY3CUDiv(tC1J3soIwEGEWrUfrnotmjRPIh357Q3257TiQj276qEUzZIZ32gkhvqMge152UItuoytGt1yxRhSXDL8nNBeTmdLJkitdI6CQkuAIZ32gkhvqMge152UItuoy4un216bBCxjFZ5grlZw0tIe8MQcLM4TkV3w(rwVI276qEEwXNvsPd5T50QlhCcDjjKf5ElGy28qaf1IkqQviKaRgBUvWaCQg7A9GnURKV5CJOLj6Y5NK6n1IEcvQihovJDTEWg3vY3CUr0Y8sQdL6j(JKFQkuAMQXUMF6(rQhON)qrop1kb87GzZeT4PpFVTkNhSLtF(ZZe4un216bBCxjFZ5grltdBxRtvHsBiGIArERilXGOnubl5iA5b6NKYMnp2qilAbwuNihrlpakzCEWPGgKLrpQkiBidvLYHgNaYqxcKje0H8qw1hjyHt1yxRhSXDL8nNBeTmfcpv9rcuvO0gcOOwK3kYsmiAdvWkyaofovJDTEWYpY6vKg6LjIqqevfkntBvEVTc(yfCEkks3G9UoKNNDiGIAf8Xk48uuKUbRGbtYAAuKsa)aTjnB2uIw80NV3wKD(i3BB50dsEzjAXtF(EBvopylNEqYZetGt1yxRhS8JSEfnIwM8RTOui3VbQkuAZkP0H82Hu5pXvpE4un216bl)iRxrJOLjyPwZp1hXWdnvfknn218t3ps9a98hkY5PwjGFhmBMOfp957Tv58GTC6bjp4un216bl)iRxrJOLzlIS5sGLAnFQkuAX15cvBdNq0(8eyPwZ3ExhYZZg3vY3CU9u)04kILCeT8aOKXzfFiGIArERilXGOnubRGHSIZ)qaf1EJZWgopLBfCUvWaCQg7A9GLFK1ROr0Y8u)04kcvfknIw80NV3wLZdwbdMnt0IN(892QCEWwo9tsz4un216bl)iRxrJOL5qQ8N4QhpvfkTzLu6qE7qQ8N4QhFwXJ7k5Bo3I8wrwIbrBOcwYvo1znnURKV5C7P(PXvel5iA5b6PSzZMs0IN(892QCEWwo9XDL8nNNLOfp957Tv58GTCqzskBIjWPASR1dw(rwVIgrlZcbzLAxRNubIcNQXUwpy5hz9kAeTmv3lrLu7ADQkuAIpRKshYBnSRSCWj0LKgsL)ex94Ht1yxRhS8JSEfnIwMOxoKk)uvO0qfiuB5hTIvtpnkjp4un216bl)iRxrJOLzuKUHuOj1eNQcLM4ZkP0H8wd7klhCcDjPHu5pXvp(SIpRKshYBnSRSCWj0LKo1pnUIaNQXUwpy5hz9kAeTmrVmrecIOQqP1Q8EB5hz90qQ8hS31H88SIh3vY3CU9u)04kILCLtDwtJIuc4hOnPzZMs0IN(892ISZh5EBlNEqYllrlE6Z3BRY5bB50dsEMycCQg7A9GLFK1ROr0YKFK1dPr1NQi1r5tTsa)oqdeQkuAeb)Olb8TdbIxo4uUvW5z5FiGIAhceVCWPCRGZTKJOLhafkbovJDTEWYpY6v0iAzYpY6H0O6dNQXUwpy5hz9kAeTmBrKnxcSuR5tvHsBiGIAxHoTOjI6GVvWaCQg7A9GLFK1ROr0Ye9YeriiIQcLgYoFK7TLxHw94PhekB28qaf1UcDArte1bFRGb4un216bl)iRxrJOL58DWhvqMiVjxBQkuAi78rU3wEfA1JNEqOmCQg7A9GLFK1ROr0YSfr2CjWsTMpvfkTwL3Bl)iRNgsL)G9UoKNdNcNQXUwpyFiCp(0GCDcApeUhFAqUobvfknubc10tZyLxwtJ7k5Bo3oKk)jU6XBjx5uB2S4ZkP0H82Hu5pXvpEtGt1yxRhSpeUhFAqUoHr0YKFTfLc5(nqvHsBwjLoK3oKk)jU6XNL)HakQ9HW94tdY1jScgGt1yxRhSpeUhFAqUoHr0YCiv(tC1JNQcL2SskDiVDiv(tC1Jpl)dbuu7dH7XNgKRtyfmaNQXUwpyFiCp(0GCDcJOLP6EjQKAxRtvHsJ)HakQ9HW94tdY1jScgGt1yxRhSpeUhFAqUoHr0Ymks3qk0KAItvHsJ)HakQ9HW94tdY1jScgGtHt1yxRhS(squjT57GpQGmrEtU2uvO0AvEVTilY9waXExhYZZoeqrTgi3Gso3Y3CE2Uqo9GaNQXUwpy9LGOsJOLj6LjIqqevfkntNvsPd5T50QlhCcDjjKf5ElGy2CRY7TvWhRGZtrr6gS31H88SdbuuRGpwbNNII0nyfmyswtJIuc4hOnPzZMs0IN(892ISZh5EBlNEqYllrlE6Z3BRY5bB50dsEMycCQg7A9G1xcIknIwMOxMgkHOGpvfknn218t3ps9a98hkY5PwjGFhmBMOfp957Tv58GTC6ZFEWPASR1dwFjiQ0iAzYV2IsHC)gOQqPnRKshYBhsL)ex94Ht1yxRhS(squPr0YSqqwP216jvGOWPASR1dwFjiQ0iAzcwQ18t9rm8qtvHst8zLu6qEBoT6YbNqxsczrU3ciznvJDn)09Jupqp)HICEQvc43bZMjAXtF(EBvopylNEqYZe4un216bRVeevAeTmBrKnxcSuR5tvHslUoxOAB4eI2NNal1A(276qEE24Us(MZTN6NgxrSKJOLhaLmoR4dbuulYBfzjgeTHkyfmKvC(hcOO2BCg2W5PCRGZTcgGt1yxRhS(squPr0Y8u)04kcvfknXNvsPd5T50QlhCcDjjKf5ElGK1un218t3ps9a98hkY5PwjGFhmBMOfp957Tv58GTC6bHYMaNQXUwpy9LGOsJOL5qQ8N4QhpvfkTzLu6qE7qQ8N4QhpCQg7A9G1xcIknIwMOxoKk)uvO0qfiuB5hTIvtpnkjp4un216bRVeevAeTmv3lrLu7ADQkuAM2Q8EB5hz90qQ8hS31H8CZMfFwjLoK3MtRUCWj0LKqwK7TaIzZOceQT8JwXQbL8NNzZdbuulYBfzjgeTHkyjhrlpaku2KSIpRKshYBnSRSCWj0LKgsL)ex94Zk(SskDiVnNwD5GtOlj9q4E8Pb56eWPASR1dwFjiQ0iAzgfPBifAsnXPQqPzARY7TLFK1tdPYFWExhYZnBw8zLu6qEBoT6YbNqxsczrU3ciMnJkqO2YpAfRguYFEMKv8zLu6qERHDLLdoHUKeYBnR4ZkP0H8wd7klhCcDjPHu5pXvp(SIpRKshYBZPvxo4e6sspeUhFAqUobCQg7A9G1xcIknIwMN6NgxrOQqP1Q8EBhYY5jubc1276qEEwIw80NV3wLZd2YPpURKV5C4un216bRVeevAeTm5hz9qAu9PksDu(uReWVd0aHQcLgrWp6saF7qG4LdoLBfCEw(hcOO2HaXlhCk3k4Cl5iA5bqHsGt1yxRhS(squPr0YKFK1dPr1hovJDTEW6lbrLgrlt0lteHGiQkuAI3Q8EBrwK7TaI9UoKNNLOfp957TfzNpY92wo9rrkb8d5tqYlBRY7TLFK1tdPYFWExhYZHt1yxRhS(squPr0Ye9YHu5NQcLgYoFK7TLxHw94PhekB28qaf1UcDArte1bFRGb4un216bRVeevAeTmrVmrecIOQqPHSZh5EB5vOvpE6bHYMnB6qaf1UcDArte1bFRGHSI3Q8EBrwK7TaI9UoKNBcCQg7A9G1xcIknIwMZ3bFubzI8MCTPQqPHSZh5EB5vOvpE6bHYWPASR1dwFjiQ0iAz2IiBUeyPwZNQcLwRY7TLFK1tdPYFWExhYZXaZNeQ1X0nzEtcsEtMx(Xa5uIxo4agGsNrAmOd0JoJFqfKbzui6qwHyyjnKHUeild(squzgGmYn(ekY5qwyroKPc9IO95qwuK6GFWcNMpk)qgiucOcYY31NpPphYYarWp6saFlOldqwVqwgic(rxc4BbD276qEEgGmtbX4mXcNcNsPZing0b6rNXpOcYGmkeDiRqmSKgYqxcKLb(rvbzNbiJCJpHICoKfwKdzQqViAFoKffPo4hSWP5JYpKLFqfKLVRpFsFoKLbIGF0La(wqxgGSEHSmqe8JUeW3c6S31H88mazAdzukg7ZhqMPGyCMyHtZhLFiJsavqw(U(8j95qwgic(rxc4BbDzaY6fYYarWp6saFlOZExhYZZaKPnKrPySpFazMcIXzIfofoLsNrAmOd0JoJFqfKbzui6qwHyyjnKHUeildXDL8nNNbiJCJpHICoKfwKdzQqViAFoKffPo4hSWP5JYpKbcOcYY31NpPphYYqCNVREBbD276qEEgGSEHSme357Q3wqxgGmtbX4mXcNMpk)q2KGkilFxF(K(CildXD(U6Tf0zVRd55zaY6fYYqCNVREBbDzaYmfeJZelCkCkLoJ0yqhOhDg)GkidYOq0HScXWsAidDjqwg4hz9kMbiJCJpHICoKfwKdzQqViAFoKffPo4hSWP5JYpKbYKGkilFxF(K(Cildeb)Olb8TGUmaz9czzGi4hDjGVf0zVRd55zaYmfeJZelCkCkOhIHL0NdzzmKPXUwhYKvOdw4umGScDatbgWxcIkXuGPdemfyG76qEowmmqKu9jLIbAvEVTilY9waXExhYZHSSq2qaf1AGCdk5ClFZ5qwwiRlKdz0dzGGb0yxRJbMVd(OcYe5n5AJBmDtIPadCxhYZXIHbIKQpPumGPq2SskDiVnNwD5GtOljHSi3BbeiZSziRv592k4JvW5POiDd276qEoKLfYgcOOwbFScopffPBWkyaYmbYYczMczrrkb8dqgniBsiZSziZuiJOfp957TfzNpY92woKrpKbsEqwwiJOfp957Tv58GTCiJEidK8GmtGmtWaASR1XaOxMicbr4gtx(XuGbURd55yXWars1NukgqJDn)09Jupaz0dz8hkY5PwjGFhGmZMHmIw80NV3wLZd2YHm6HS8NhgqJDToga9Y0qjef8XnMokbtbg4UoKNJfddejvFsPyGzLu6qE7qQ8N4QhpgqJDTogGFTfLc5(nGBmDugtbgqJDTogOqqwP216jvGOyG76qEowmCJPlJXuGbURd55yXWars1NukgqCiBwjLoK3MtRUCWj0LKqwK7TacKLfYmfY0yxZpD)i1dqg9qg)HICEQvc43biZSziJOfp957Tv58GTCiJEidK8GmtWaASR1XaGLAn)uFedp04gthOgtbg4UoKNJfddejvFsPyG46CHQTHtiAFEcSuR5BVRd55qwwilURKV5C7P(PXvel5iA5biduGSmgYYczIdzdbuulYBfzjgeTHkyfmazzHmXHm(hcOO2BCg2W5PCRGZTcgWaASR1XaTiYMlbwQ18XnMoJfMcmWDDiphlggisQ(KsXaIdzZkP0H82CA1LdoHUKeYICVfqGSSqMPqMg7A(P7hPEaYOhY4puKZtTsa)oazMndzeT4PpFVTkNhSLdz0dzGqziZemGg7ADmWP(PXveCJPd0htbg4UoKNJfddejvFsPyGzLu6qE7qQ8N4QhpgqJDTogyiv(tC1Jh3y6ajpmfyG76qEowmmqKu9jLIbqfiuB5hTIvdz0tdYOK8WaASR1XaOxoKk)4gthiGGPadCxhYZXIHbIKQpPumGPqwRY7TLFK1tdPYFWExhYZHmZMHmXHSzLu6qEBoT6YbNqxsczrU3ciqMzZqgQaHAl)OvSAiduGS8NhKz2mKneqrTiVvKLyq0gQGLCeT8aKbkqgLHmtGSSqM4q2SskDiV1WUYYbNqxsAiv(tC1JhYYczIdzZkP0H82CA1LdoHUK0dH7XNgKRtGb0yxRJbu3lrLu7ADCJPdKjXuGbURd55yXWars1NukgWuiRv592YpY6PHu5pyVRd55qMzZqM4q2SskDiVnNwD5GtOljHSi3BbeiZSzidvGqTLF0kwnKbkqw(ZdYmbYYczIdzZkP0H8wd7klhCcDjjK3kKLfYehYMvsPd5Tg2vwo4e6ssdPYFIRE8qwwitCiBwjLoK3MtRUCWj0LKEiCp(0GCDcmGg7ADmquKUHuOj1eh3y6aj)ykWa31H8CSyyGiP6tkfd0Q8EBhYY5jubc1276qEoKLfYiAXtF(EBvopylhYOhY0yxRNI7k5BohdOXUwhdCQFACfb3y6aHsWuGbURd55yXWaASR1Xa8JSEinQ(yGiP6tkfdqe8JUeW3oeiE5Gt5wbNBVRd55qwwiJ)HakQDiq8YbNYTco3soIwEaYafiJsWarQJYNALa(Dathi4gthiugtbgqJDTogGFK1dPr1hdCxhYZXIHBmDGKXykWa31H8CSyyGiP6tkfdioK1Q8EBrwK7TaI9UoKNdzzHmIw80NV3wKD(i3BB5qg9qwuKsa)aKLpHmqYdYYczTkV3w(rwpnKk)b7DDiphdOXUwhdGEzIieeHBmDGaQXuGbURd55yXWars1NukgazNpY92YRqRE8qg9qgiugYmBgYgcOO2vOtlAIOo4BfmGb0yxRJbqVCiv(XnMoqmwykWa31H8CSyyGiP6tkfdGSZh5EB5vOvpEiJEidekdzMndzMczdbuu7k0Pfnruh8TcgGSSqM4qwRY7TfzrU3ci276qEoKzcgqJDToga9Yeriic3y6ab0htbg4UoKNJfddejvFsPyaKD(i3BlVcT6Xdz0dzGqzmGg7ADmW8DWhvqMiVjxBCJPBY8WuGbURd55yXWars1NukgOv592YpY6PHu5pyVRd55yan216yGwezZLal1A(4g3ya(rvbzJPathiykWaASR1Xa8kqem0yG76qEowmCJPBsmfyan216yG46bbKNquWvedCxhYZXIHBmD5htbg4UoKNJfddSgWaH3yan216yGzLu6qEmWSssUICmWqQ8N4QhpgisQ(KsXaIdzeb)Olb8Trr6gsTOVeQT31H8Cma)HiPm016yakD1IwHgYYxr6gGmke9LqnvqMysLFilJQE8qwUQfbzzefj0qMyYD5q2sGmTHS8BeKz6Kgbz5QweKrbrljKTOqMXqOCtGSwjGFhWaZQu4yGwL3BlArcDAi3LBVRd55qMzZqwWWLYuReWVd2Hu5pXvpEqGm6PbzMcz5hYmMqwRY7TTjAjtlAIiuU9UoKNdzMGBmDucMcmWDDiphlggynGbcVXaASR1XaZkP0H8yGzLKCf5yGHu5pXvpEmqKu9jLIbic(rxc4BJI0nKArFjuBVRd55ya(drszOR1Xau6Qfbz5RiDdqgfI(sOMkitmPYpKLrvpEilNO7qwl6q2qaffYQaKX3CovqwUQfbzzefj0qMyYD5qM2q2KgbzMcIrqwUQfbzuq0sczlkKzmek3eiBjqwUQfbzukHW94HmXixNaY0gYOeJGmtZVrqwUQfbzuq0sczlkKzmek3eiRvc43bmWSkfogyiGIAJI0nKArFjuB5BohYmBgYAvEVTOfj0PHCxU9UoKNdzzHSGHlLPwjGFhSdPYFIRE8Gaz0tdYmfYMeYmMqwRY7TTjAjtlAIiuU9UoKNdzMazMndzIdzTkV32i1r5tlAsK2KZT31H8CillKfmCPm1kb87GDiv(tC1JheiJEAqMPqgLazgtiRv5922eTKPfnrek3ExhYZHmtWnMokJPadCxhYZXIHbwdyGWBmGg7ADmWSskDipgywLchdioK1Q8EB5hz9kAVRd55qwwilURKV5ClYBfzjgeTHkyjhrlpazGcKLXqwwidvGqTLF0kwnKrpKL)8WaZkj5kYXag2vwo4e6ssiVvCJPlJXuGbURd55yXWaRbmq4ngqJDTogywjLoKhdmRsHJbMvsPd5TdPYFIRE8qwwiZuidvGqnKbkqgOMYqMXeYAvEVTOfj0PHCxU9UoKNdz5tiBY8GmtWaZkj5kYXag2vwo4e6ssdPYFIRE84gthOgtbg4UoKNJfddSgWaH3yan216yGzLu6qEmWSkfogOv592YpY6v0ExhYZHSSqM4qwRY7TDilNNqfiuBVRd55qwwilURKV5C7P(PXvel5iA5biduGmtHmWrUfrnoilFcztczMazzHmubc1w(rRy1qg9q2K5HbMvsYvKJbmSRSCWj0LKo1pnUIGBmDglmfyG76qEowmmWAadeEJb0yxRJbMvsPd5XaZQu4yGwL3B7dH7XNgKRtyVRd55qwwitCiBwjLoK3Ayxz5GtOljnKk)jU6XdzzHmXHSzLu6qERHDLLdoHUKeYBfYYczXDL8nNBFiCp(0GCDcRGbmWSssUICmqoT6YbNqxs6HW94tdY1jWnMoqFmfyG76qEowmmWAadeEJb0yxRJbMvsPd5XaZQu4yGwL3BlYICVfqS31H8CillKjoKneqrTilY9waXkyadmRKKRihdKtRUCWj0LKqwK7TacUX0bsEykWa31H8CSyyan216yGOkLjn216jzfAmGScDYvKJbI7k5Boh3y6abemfyG76qEowmmqKu9jLIbgcOOw0ltJfzOeoY92gAnobKrdYOmKLfYmfYgcOO2cbzLAxRNubIAfmazMndzIdzdbuulYBfzjgeTHkyfmazMGb0yxRJbArKnxcSuR5JBmDGmjMcmWDDiphlggisQ(KsXaTkV32hc3JpnixNWExhYZHSSqMPq2SskDiVnNwD5GtOlj9q4E8Pb56eqMzZqg)dbuu7dH7XNgKRtyfmazMGbcnPInMoqWaASR1XarvktASR1tYk0yazf6KRihd8q4E8Pb56e4gthi5htbg4UoKNJfddejvFsPyGwL3Bl)iRxr7DDiphdeAsfBmDGGb0yxRJbicEsJDTEswHgdiRqNCf5ya(rwVI4gthiucMcmWDDiphlggqJDTogGi4jn216jzfAmGScDYvKJb8LGOsCJBma)iRxrmfy6abtbg4UoKNJfddejvFsPyatHSwL3BRGpwbNNII0nyVRd55qwwiBiGIAf8Xk48uuKUbRGbiZeillKzkKffPeWpaz0GSjHmZMHmtHmIw80NV3wKD(i3BB5qg9qgi5bzzHmIw80NV3wLZd2YHm6HmqYdYmbYmbdOXUwhdGEzIieeHBmDtIPadCxhYZXIHbIKQpPumWSskDiVDiv(tC1JhdOXUwhdWV2IsHC)gWnMU8JPadCxhYZXIHbIKQpPumGg7A(P7hPEaYOhY4puKZtTsa)oazMndzeT4PpFVTkNhSLdz0dzGKhgqJDTogaSuR5N6Jy4Hg3y6OemfyG76qEowmmqKu9jLIbIRZfQ2goHO95jWsTMV9UoKNdzzHS4Us(MZTN6NgxrSKJOLhGmqbYYyillKjoKneqrTiVvKLyq0gQGvWaKLfYehY4FiGIAVXzydNNYTco3kyadOXUwhd0IiBUeyPwZh3y6OmMcmWDDiphlggisQ(KsXaeT4PpFVTkNhScgGmZMHmIw80NV3wLZd2YHm6HSjPmgqJDTog4u)04kcUX0LXykWa31H8CSyyGiP6tkfdmRKshYBhsL)ex94HSSqM4qwCxjFZ5wK3kYsmiAdvWsUYPgYYczMczXDL8nNBp1pnUIyjhrlpaz0dzugYmBgYmfYiAXtF(EBvopylhYOhY0yxRNI7k5BohYYczeT4PpFVTkNhSLdzGcKnjLHmtGmtWaASR1XadPYFIRE84gthOgtbgqJDTogOqqwP216jvGOyG76qEowmCJPZyHPadCxhYZXIHbIKQpPumG4q2SskDiV1WUYYbNqxsAiv(tC1JhdOXUwhdOUxIkP2164gthOpMcmWDDiphlggisQ(KsXaOceQT8JwXQHm6PbzusEyan216ya0lhsLFCJPdK8WuGbURd55yXWars1NukgqCiBwjLoK3Ayxz5GtOljnKk)jU6XdzzHmXHSzLu6qERHDLLdoHUK0P(PXvemGg7ADmquKUHuOj1eh3y6abemfyG76qEowmmqKu9jLIbAvEVT8JSEAiv(d276qEoKLfYehYI7k5Bo3EQFACfXsUYPgYYczMczrrkb8dqgniBsiZSziZuiJOfp957TfzNpY92woKrpKbsEqwwiJOfp957Tv58GTCiJEidK8GmtGmtWaASR1XaOxMicbr4gthitIPadCxhYZXIHb0yxRJb4hz9qAu9Xars1NukgGi4hDjGVDiq8YbNYTco3ExhYZHSSqg)dbuu7qG4LdoLBfCULCeT8aKbkqgLGbIuhLp1kb87aMoqWnMoqYpMcmGg7ADma)iRhsJQpg4UoKNJfd3y6aHsWuGbURd55yXWars1NukgyiGIAxHoTOjI6GVvWagqJDTogOfr2CjWsTMpUX0bcLXuGbURd55yXWars1NukgazNpY92YRqRE8qg9qgiugYmBgYgcOO2vOtlAIOo4BfmGb0yxRJbqVmrecIWnMoqYymfyG76qEowmmqKu9jLIbq25JCVT8k0QhpKrpKbcLXaASR1XaZ3bFubzI8MCTXnMoqa1ykWa31H8CSyyGiP6tkfd0Q8EB5hz90qQ8hS31H8CmGg7ADmqlIS5sGLAnFCJBmGbYJlYqBmfy6abtbgqJDTogySDlppHkvQppx5Gt9ACLJbURd55yXWnUXapeUhFAqUobMcmDGGPadCxhYZXIHbIKQpPumaQaHAiJEAqMXkpillKzkKf3vY3CUDiv(tC1J3sUYPgYmBgYehYMvsPd5TdPYFIRE8qMjyan216yGhc3JpnixNa3y6Metbg4UoKNJfddejvFsPyGzLu6qE7qQ8N4QhpKLfY4FiGIAFiCp(0GCDcRGbmGg7ADma)AlkfY9Ba3y6YpMcmWDDiphlggisQ(KsXaZkP0H82Hu5pXvpEillKX)qaf1(q4E8Pb56ewbdyan216yGHu5pXvpECJPJsWuGbURd55yXWars1NukgG)HakQ9HW94tdY1jScgWaASR1XaQ7LOsQDToUX0rzmfyG76qEowmmqKu9jLIb4FiGIAFiCp(0GCDcRGbmGg7ADmquKUHuOj1eh34gde3vY3CoMcmDGGPadCxhYZXIHbIKQpPumG4qMPqwRY7TLFK1RO9UoKNdzMndzZkP0H8wd7klhCcDjjK3kKzcKLfYI7k5Bo3EQFACfXsoIwEaYOhYMmpillKzkKjoKf357Q3257TiQjqMzZqM4qgFBBOCubzAquNB7kor5GHmtGmZMHSXgcqwwidTalQtKJOLhGmqbYMKYyan216yaK3kYsmiAdva3y6Metbg4UoKNJfddejvFsPyGwL3Bl)iRxr7DDiphYYczMczXDL8nNBp1pnUIyjhrlpaz0dztMhKLfYmfYehYMvsPd5TdPYFIRE8qMzZqwCxjFZ52Hu5pXvpEl5iA5biJEidCKBruJdYmbYmbYYczMczIdzXD(U6TD(ElIAcKz2mKjoKX32gkhvqMge152UItuoyiZemGg7ADmaYBfzjgeTHkGBmD5htbg4UoKNJfddejvFsPyaXHm(22q5OcY0GOo32vCIYbJb0yxRJbcLJkitdI6CCJPJsWuGbURd55yXWars1NukgqCiRv592YpY6v0ExhYZHSSqM4q2SskDiVnNwD5GtOljHSi3BbeiZSziBiGIArfi1kesGvJn3kyadOXUwhd0IEsKG34gthLXuGb0yxRJbqxo)KuVPw0tOsf5yG76qEowmCJPlJXuGbURd55yXWars1NukgWuitJDn)09Jupaz0dz8hkY5PwjGFhGmZMHmIw80NV3wLZd2YHm6HS8NhKzcgqJDTog4sQdL6j(JKFCJPduJPadCxhYZXIHbIKQpPumWqaf1I8wrwIbrBOcwYr0Ydqg9q2KugYmBgYgBiazzHm0cSOoroIwEaYafilJZddOXUwhdyy7ADCJPZyHPadCxhYZXIHb0yxRJbecpv9rcya(drszOR1Xaz0JQcYgYqvPCOXjGm0LazcbDipKv9rcwmqKu9jLIbgcOOwK3kYsmiAdvWkya34g3yavOfTemaqHKV4g3ym]] )
end
