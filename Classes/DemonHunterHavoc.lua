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


    spec:RegisterPack( "Havoc", 20210403, [[daLgwbqiuKfPku0Jek0LufkSjPOpjKmkvvDkvvwfrvOxjKAwOGBPQKAxK8lPunmvbhtOAzOOEMqjttvjUMqrBtvj5BcLY4iQkohrvLwNQs18KsX9iI9Hc9pHsvDqvHQwOq4HQkLjkuWfvfQSrvHsFuOuXijQQQtsufSsvfZKOkDtHsvANcr)KOQcdvOujlLOQ0tr0ujQCvHsL6RevrJvkL2lP(RedgYHPSyP6XsAYO6YGnJuFgjgnr50kwTqPkETQOzt42iSBQ(TkdNiDCIQQSCOEUGPl66O02vL(Uuy8Qc58sjRNOQIMpsA)kToUwonj3sqhjZpWC8h(YdXsfpoZXkU8RMmBjf0KsT6tJcOjDJa0KY)27v1KsTwIZ4A50KHJfxbnj5qWkSCo)ByJo1KD2rKYdUURj5wc6iz(bMJ)WxEiwQ4XzowXJnnzqku1rgZyl20KYgohCDxtYHqvtgdaX5ls(N1taVi5F79Q7NhVu8iweZmSiMFG547N9Z3Kzofi899ZxVOyVqAehwQSlmHfzoFrXUUCoFrSbJcSOhZoqFyyr0dfz5IaNhEmxK4Om1fz8ypSHe4lkVfzsLkATOZfTwuElQFHWIOhkYYGstkfF0Ja0KXymUOyaioFrY)SEc4fj)BVxD)eJX4IE8sXJyrmZWIy(bMJVF2pXymUOVjZCkq477Nymgx0xVOyVqAehwQSlmHfzoFrXUUCoFrSbJcSOhZoqFyyr0dfz5IaNhEmxK4Om1fz8ypSHe4lkVfzsLkATOZfTwuElQFHWIOhkYYGA)SFSAoNhusXq9i6wkPFzkaEHwyTaEJXPuY7rJVFSAoNhusXq9i6wgTK2Fn8yDbWGBeGKep(tilHwETeexYWRjybjXzyOLK4XFcPkUsMfkH0sL5TkCPHM)zkXJ)esfZkzwOeslvM3QWLgOsnXJ)esvCv9ob)A4kol2Y5CgLK4XFcPIzv9ob)A4kol2Y58F7hRMZ5bLumupIULrlP9xdpwxam4gbijXJ)eYsOLxlbXLm8AcwqcZmm0ss84pHuXSsMfkH0sL5TkCPHM)zkXJ)esvCLmlucPLkZBv4sduPM4XFcPIzv9ob)A4kol2Y5Cgt84pHufxvVtWVgUIZITCo)3(jgxuS7aSOhxlyrragXISCrIRXIESS4wlQXKYwueIX5l6XYIBTO6r0hh4lQXKYwemPmaVOyWWpPimmSOdVOyaioFrrimoe2pwnNZdkPyOEeDlJws7VgESUayWncqcBakqlO0bJOqZIBvQNZNCoNHxtWcsstaEQ6IX5fAwClf4wxa8M)XSoqFykGIB4Nueggkea3eI5CQuttaEQ4aX5LUW4qqbU1fa)3(z)SFIXyCrpUhbv2e4lcEbCRfLdbSOugSiRMhErtyr2RncRla1(XQ5CEqcFcywP5(XQ5CEiAjTxppWsafcJYu3pXymUi5jSi(5rLlIFlkLnHfLgMcKlk0WKkDCklkVfzsLkATOiyX(4uwK88yD((jgJXfz1CopeTK2XqAykqwm28kwMw9jdIXHsLljodPHPazzOLqm(35qNLMw1zX(4uknowNRWaHnEGHHwcM1b6dtbuDwSpoLsJJ15nttaEQ4aX5LUW4qqbU1faF)eJlsEoPSJnx03KzxyrYjdoCRfD4ffdg(jfHHbgwuecJdlkgmVclQXKYw0JDWHCrriUJVOdVilxuSIEr)zo6f1yszlsoSnIfD0ls(Yo(VfLgMcKH9JvZ58q0sA)1WJ1fadUras6cJdfU5vGHHwctywhOpmfqvLzxOKYGd3QjtywhOpmfqXn8tkcddfcGBcXCodVMGfKKMa8urp4qw6I74kWTUa4uPgKccrjnmfidQUW4qHBEfIZOK)X6RttaEQsSnIYrxWSJRa36cG)B)eJlsEoPSf9nz2fwKCYGd3IHffHW4WIIbZRWIAid8fLYGf1zPPx0ewe)A4mSOgtkBrp2bhYffH4o(ISCrmh9I(hp6f1yszlsoSnIfD0ls(Yo(VfD4f1yszl6XfcGxHffbgSNlYYf9LOx0)yf9IAmPSfjh2gXIo6fjFzh)3IsdtbYW(XQ5CEiAjT)A4X6cGb3iajDHXHc38kWWqlbZ6a9HPaQQm7cLugC4wm8AcwqsNLMwvLzxOKYGd3sXVgovQPjapv0doKLU4oUcCRlaEZGuqikPHPazq1fghkCZRqCgL8N5Vonb4PkX2ikhDbZoUcCRla(pQuzknb4PQ2QkGYrxKzjg4kWTUa4ndsbHOKgMcKbvxyCOWnVcXzuY)V81Pjapvj2gr5Oly2XvGBDbW)TFIXfjpNu2IIbd)KIWWadlkcHXHffdMxHfz5I8dtyIfLgMcKlQESEUOgYaFrDwAAGVOERfzlka1Z5gU1IaAAOMmSOdVit0WAfwKLl6lYf9IOp8I8Z)6yaioFQ7hRMZ5HOL0(RHhRlagCJaK0fghkCZRaddTemRd0hMcO4g(jfHHHcbWnHyoNHxtWcsstaEQOhCilDXDCf4wxaCQu)3zPPveqAehwQSlmbfRuQuttaEQsSnIYrxWSJRa36cGtLkh6S00kieaVcLogSNkwP)AgKccrjnmfidQUW4qHBEfIZOK)X6RttaEQsSnIYrxWSJRa36cG)JkvMstaEQ4aX5tvbU1faVzqkieL0WuGmO6cJdfU5vioJs(Y(XQ5CEiAjT)A4X6cGb3iajsVtmoLc9HleqAm8AcwqctPjapvCG48PQa36cG3SENGFnCfbKgXHLk7ctqHbcB8qB(QM0S4wkoqp1jzmwpSFSAoNhIws7VgESUayWncqI07eJtPqF4sxyCOWnVcm8AcwqYRHhRlavxyCOWnVcn)tZIB1MylMFDAcWtf9GdzPlUJRa36cGlpY8d)2pwnNZdrlP9xdpwxam4gbir6DIXPuOpCbAbLoyem8AcwqsAcWtfhioFQkWTUa4nzknb4PQlgNxOzXTuGBDbWBwVtWVgUcAbLoyekmqyJhAZFkvUIWEK8iZ)AsZIBP4a9uNKrMFy)y1CopeTK2Fn8yDbWGBeGKg2KJtPqF4cecGxHshd2tgEnblijnb4PccbWRqPJb7PcCRlaEtMEn8yDbOKENyCkf6dx6cJdfU5vOjtVgESUausVtmoLc9HleqAnR3j4xdxbHa4vO0XG9uXkD)y1CopeTK2Fn8yDbWGBeGKg2KJtPqF4cXraEYsWWRjybjPjapvehb4jlHcCRlaEtM6S00kIJa8KLqXkD)y1CopeTK2RMquSAoNxetizWncqs9ob)A47hRMZ5HOL0EkdFnkue28cmm0s6S00kAqu6hr3WCcWtviT6tjXS5)olnTAiioHLZ5fJfBkwPuPYuNLMwraPrCyPYUWeuSs)TFSAoNhIws7vtikwnNZlIjKm4gbibcbWRqPJb7jdHep1usCggAjPjapvqiaEfkDmypvGBDbWB()1WJ1fGQHn54uk0hUaHa4vO0XG9Kkvo0zPPvqiaEfkDmypvSs)TFSAoNhIws7ywVy1CoViMqYGBeGeoqC(uziK4PMsIZWqljnb4PIdeNpvf4wxa89JvZ58q0sAhZ6fRMZ5fXesgCJaK4hMWe7N9JvZ58GQENGFnCjeqAehwQSlmbggAjm9pnb4PIdeNpvf4wxaCQuFn8yDbOKENyCkf6dxiG0(1SENGFnCf0ckDWiuyGWgpWiZp08pt17fCZt1l4PSwyf4wxaCQuzIFPkmonRO0XMZv5uFooLFuP2VqOj9qrwwWaHnEOnmhZ9JvZ58GQENGFn8OL0obKgXHLk7ctGHHwsAcWtfhioFQkWTUa4n)xVtWVgUcAbLoyekmqyJhyK5hA(NPxdpwxaQUW4qHBEfOsTENGFnCvxyCOWnVckmqyJhyKsLRiSh97xZ)mvVxWnpvVGNYAHvGBDbWPsLj(LQW40SIshBoxLt954u(TFSAoNhu17e8RHhTK2dJtZkkDS5CggAjmXVufgNMvu6yZ5QCQphNY(XQ5CEqvVtWVgE0sApLbfzSEYWqlHP0eGNkoqC(uvGBDbWBY0RHhRlavdBYXPuOpCH4iapzjOsTZstROzXZXgkum5NGIv6(XQ5CEqvVtWVgE0sAheTcJ5fouXaWWql5VvZ5fkGdedeyKdHbd8sAykqgOsfBdVaVGNkJZdQXzmwp8B)y1CopOQ3j4xdpAjTl9Y5CggAjDwAAfbKgXHLk7ctqHbcB8aJmhtQu7xi0KEOillyGWgp0MV6H9tmUOyaOnwrUi2aSOjbIfjoktD)y1CopOQ3j4xdpAjTZgGYKarGHG4YGKep(tiJZWql51WJ1fGkXJ)eYsOLxlbXLsI38FNLMwraPrCyPYUWeuSsPs9ptPjapvCG48PQa36cG3SENGFnCfbKgXHLk7ctqHbcB8aJ)PhkYYcgiSXdmg7N4XFcPkUQENGFnCfNfB5C(JbZ)(rLk9qrwwWaHnEOnsy(HFuP()1WJ1fGkXJ)eYsOLxlbXLsyUjtjE8NqQywvVtWVgUcdgV1pQuz61WJ1fGkXJ)eYsOLxlbXL7hRMZ5bv9ob)A4rlPD2auMeicmeexgKK4XFcjZmm0sEn8yDbOs84pHSeA51sqCPeMB(VZstRiG0ioSuzxyckwPuP(NP0eGNkoqC(uvGBDbWBwVtWVgUIasJ4WsLDHjOWaHnEGX)0dfzzbde24bgJ9t84pHuXSQENGFnCfNfB5C(JbZ)(rLk9qrwwWaHnEOnsy(HFuP()1WJ1fGkXJ)eYsOLxlbXLsI3KPep(tivXv17e8RHRWGXB9JkvMEn8yDbOs84pHSeA51sqC5(z)y1CopO4aX5tvcniky2GmggAj)ttaEQy9(X68svMDbf4wxa8MDwAAfR3pwNxQYSlOyL(R5)QmdtbcsyMk1)yB4f4f8urCVab4PACgJ)qtSn8c8cEQmopOgNX4p873(XQ5CEqXbIZNA0sANdwkReAaGuggAjVgESUauDHXHc38kSFSAoNhuCG48PgTK2PiS5fkjqifcjddTeRMZluahigiWihcdg4L0WuGmqLk2gEbEbpvgNhuJZy8h2pwnNZdkoqC(uJws7Pm81OqryZlWWqlPEoNDsvaWylbEHIWMxqbU1faVz9ob)A4kOfu6GrOWaHnEOnFvtM6S00kcinIdlv2fMGIvAtM4qNLMwbps6faEPXX6CfR09JvZ58GIdeNp1OL0o0ckDWiyyOLy1CEHc4aXabg5qyWaVKgMcKbQuX2WlWl4PY48GACgzoMn)Z0RHhRlafBakqlO0bJOqZIBvQNZNCoNk1GuqikPHPazGX4uPsZIB1My7HF7hRMZ5bfhioFQrlP9UW4qHBEfyyOL8A4X6cq1fghkCZRqtMQ3j4xdxraPrCyPYUWeuyW4TA(VENGFnCf0ckDWiuyGWgpWymPs9p2gEbEbpvgNhuJZy9ob)A4nX2WlWl4PY48GA82WCm)9B)y1CopO4aX5tnAjTpeeNWY58IXIT9JvZ58GIdeNp1OL0U5(iBewoNZWqlHPxdpwxakP3jgNsH(WLUW4qHBEf2pwnNZdkoqC(uJws70GOlmoWWqlHMf3sXb6PojJs(Yd7hRMZ5bfhioFQrlP9Qm7cLqINNaddTeMEn8yDbOKENyCkf6dx6cJdfU5vOjtVgESUausVtmoLc9HlqlO0bJy)y1CopO4aX5tnAjTtdIcMniJHHwsAcWtfhioV0fghckWTUa4nzQENGFnCf0ckDWiuyW4TA(VkZWuGGeMPs9p2gEbEbpve3lqaEQgNX4p0eBdVaVGNkJZdQXzm(d)(TFSAoNhuCG48PgTK25aX5HsFsGHARQakPHPazqsCggAjywhOpmfq1zX(4uknowN3KdDwAAvNf7JtP04yDUcde24H28L9JvZ58GIdeNp1OL0ohiopu6tc7hRMZ5bfhioFQrlP9ug(AuOiS5fyyOL0zPPvhBwo6c2CkGIv6(XQ5CEqXbIZNA0sANgefmBqgddTeI7fiapv8jKMxbgJhtQu7S00QJnlhDbBofqXkD)y1CopO4aX5tnAjT)cofGMvuWqIblzyOLqCVab4PIpH08kWy8yUFSAoNhuCG48PgTK2tz4RrHIWMxGHHwsAcWtfhioV0fghckWTUa47N9JvZ58GccbWRqPJb7PeieaVcLogSNmm0sOzXTyuI85HM)R3j4xdx1fghkCZRGcdgVfvQm9A4X6cq1fghkCZRWV9JvZ58GccbWRqPJb7z0sANdwkReAaGuggAjVgESUauDHXHc38k0KdDwAAfecGxHshd2tfR09JvZ58GccbWRqPJb7z0sAVlmou4MxbggAjVgESUauDHXHc38k0KdDwAAfecGxHshd2tfR09JvZ58GccbWRqPJb7z0sA3CFKnclNZzyOLWHolnTccbWRqPJb7PIv6(XQ5CEqbHa4vO0XG9mAjTxLzxOes88eyyOLWHolnTccbWRqPJb7PIv6(z)y1CopO8dtycjVGtbOzffmKyWsggAjPjapvehb4jlHcCRlaEZolnTskgKAyGR4xdVzoeaJX3pwnNZdk)WeMiAjTtdIcMniJHHwY)xdpwxaQg2KJtPqF4cXraEYsqLAAcWtfR3pwNxQYSlOa36cG3SZstRy9(X68svMDbfR0Fn)xLzykqqcZuP(hBdVaVGNkI7fiapvJZy8hAITHxGxWtLX5b14mg)HF)2pwnNZdk)WeMiAjTtdIs3WyJcWWqlXQ58cfWbIbcmYHWGbEjnmfiduPITHxGxWtLX5b14mgRh2pwnNZdk)WeMiAjTZblLvcnaqkddTKxdpwxaQUW4qHBEf2pwnNZdk)WeMiAjTpeeNWY58IXIT9JvZ58GYpmHjIws7ue28cLeiKcHKHHwctVgESUaunSjhNsH(WfIJa8KLO5FRMZluahigiWihcdg4L0WuGmqLk2gEbEbpvgNhuJZy8h(TFSAoNhu(Hjmr0sApLHVgfkcBEbggAj1Z5StQcagBjWlue28ckWTUa4nR3j4xdxbTGshmcfgiSXdT5RAYuNLMwraPrCyPYUWeuSsBYeh6S00k4rsVaWlnowNRyLUFSAoNhu(Hjmr0sAhAbLoyemm0sy61WJ1fGQHn54uk0hUqCeGNSen)B1CEHc4aXabg5qyWaVKgMcKbQuX2WlWl4PY48GACgJhZM)z61WJ1fGInafOfu6GruOzXTk1Z5toNtLAqkieL0WuGmWyCQuPzXTAtS9WVF7hRMZ5bLFycteTK27cJdfU5vGHHwYRHhRlavxyCOWnVc7hRMZ5bLFycteTK2PbrxyCGHHwcnlULId0tDsgL8Lh2pwnNZdk)WeMiAjTBUpYgHLZ5mm0s(NMa8uXbIZlDHXHGcCRlaovQm9A4X6cq1WMCCkf6dxiocWtwcQuPzXTuCGEQt2My9avQDwAAfbKgXHLk7ctqHbcB8qBI5VMm9A4X6cqj9oX4uk0hU0fghkCZRqtMEn8yDbOAytooLc9HlqiaEfkDmyp3pwnNZdk)WeMiAjTxLzxOes88eyyOL8pnb4PIdeNx6cJdbf4wxaCQuz61WJ1fGQHn54uk0hUqCeGNSeuPsZIBP4a9uNSnX6HFnz61WJ1fGs6DIXPuOpCHasRjtVgESUausVtmoLc9HlDHXHc38k0KPxdpwxaQg2KJtPqF4cecGxHshd2Z9JvZ58GYpmHjIws7qlO0bJGHHwsAcWtvxmoVqZIBPa36cG3eBdVaVGNkJZdQXzSENGFn89JvZ58GYpmHjIws7CG48qPpjWqTvvaL0WuGmijoddTemRd0hMcO6SyFCkLghRZBYHolnTQZI9XPuACSoxHbcB8qB(Y(XQ5CEq5hMWerlPDoqCEO0Ne2pwnNZdk)WeMiAjTtdIcMniJHHwctPjapvehb4jlHcCRlaEtSn8c8cEQiUxGa8unoJvzgMceKhJ)qZ0eGNkoqCEPlmoeuGBDbW3pwnNZdk)WeMiAjTtdIUW4addTeI7fiapv8jKMxbgJhtQu7S00QJnlhDbBofqXkD)y1CopO8dtyIOL0oniky2GmggAje3lqaEQ4tinVcmgpMuP(VZstRo2SC0fS5uafR0MmLMa8urCeGNSekWTUa4)2pwnNZdk)WeMiAjT)cofGMvuWqIblzyOLqCVab4PIpH08kWy8yUFSAoNhu(Hjmr0sApLHVgfkcBEbggAjPjapvCG48sxyCiOa36cGRjFbCyoxhjZpWC8hI1dYhnzdd7JtjOjLNpE5BKYdrg789fTi5KblAiKE4Cr0hErr5hMWerTimi)XoyGVOWralYyZJWsGVOQmZPab1(rEhhwu8V89f9TZFbCc8fffM1b6dtbuTnQfL3IIcZ6a9HPaQ2Qa36cGh1I(h)r)u7N9J88XlFJuEiYyNVVOfjNmyrdH0dNlI(WlkkoqBSImQfHb5p2bd8ffocyrgBEewc8fvLzofiO2pY74WII13x03o)fWjWxuuywhOpmfq12OwuElkkmRd0hMcOARcCRlaEul6F8h9tTFK3XHffRVVOVD(lGtGVOOWSoqFykGQTrTO8wuuywhOpmfq1wf4wxa8OwKLl6Xj)qEx0)4p6NA)iVJdl6lFFrF78xaNaFrrHzDG(WuavBJAr5TOOWSoqFykGQTkWTUa4rTilx0Jt(H8UO)XF0p1(rEhhwum)(I(25Vaob(IIcZ6a9HPaQ2g1IYBrrHzDG(WuavBvGBDbWJArwUOhN8d5Dr)J)OFQ9Z(rE(4LVrkpezSZ3x0IKtgSOHq6HZfrF4ffLumupIULrTimi)XoyGVOWralYyZJWsGVOQmZPab1(rEhhweZFFrF78xaNaFrrL4XFcPkUQTrTO8wuujE8NqQY4Q2g1I(Z8J(P2pY74WIy(7l6BN)c4e4lkQep(tivmRABulkVffvIh)jKQKzvBJAr)z(r)u7h5DCyrX67l6BN)c4e4lkQep(tivXvTnQfL3IIkXJ)esvgx12Ow0FMF0p1(rEhhwuS((I(25Vaob(IIkXJ)esfZQ2g1IYBrrL4XFcPkzw12Ow0FMF0p1(rEhhw0x((I(25Vaob(IIcZ6a9HPaQ2g1IYBrrHzDG(WuavBvGBDbWJAr)J)OFQ9Z(rE(4LVrkpezSZ3x0IKtgSOHq6HZfrF4ffv9ob)A4rTimi)XoyGVOWralYyZJWsGVOQmZPab1(rEhhwu8VVOVD(lGtGVOOQ3l4MNQ2Qa36cGh1IYBrrvVxWnpvTnQf9p(J(P2pY74WIy(7l6BN)c4e4lkQ69cU5PQTkWTUa4rTO8wuu17fCZtvBJAr)J)OFQ9J8ooSOy77l6BN)c4e4lICi(2IcT80E0IEmwuElsEzTfXN3jmNVOtkGT8Wl6F7)w0)4p6NA)iVJdlk2((I(25Vaob(IIkXJ)esvCvBJAr5TOOs84pHuLXvTnQf9p(J(P2pY74WIITVVOVD(lGtGVOOs84pHuXSQTrTO8wuujE8NqQsMvTnQf9p(J(P2pY74WIKpFFrF78xaNaFrKdX3wuOLN2Jw0JXIYBrYlRTi(8oH58fDsbSLhEr)B)3I(h)r)u7h5DCyrYNVVOVD(lGtGVOOs84pHufx12OwuElkQep(tivzCvBJAr)J)OFQ9J8ooSi5Z3x03o)fWjWxuujE8NqQyw12OwuElkQep(tivjZQ2g1I(h)r)u7N9J88XlFJuEiYyNVVOfjNmyrdH0dNlI(WlkkoqC(uJAryq(JDWaFrHJawKXMhHLaFrvzMtbcQ9J8ooSO4m)9f9TZFbCc8fffM1b6dtbuTnQfL3IIcZ6a9HPaQ2Qa36cGh1I(h)r)u7N9J8aH0dNaFrF1ISAoNViXeYGA)Ojn2u2H1KKdX30KIjKbTCAs)WeMqlNoY4A50KGBDbW1rOjR4jb8yAY0eGNkIJa8KLqbU1faFrnxuNLMwjfdsnmWv8RHVOMlkhcyrmUO4AsRMZ5AYxWPa0SIcgsmyPo1rYSwonj4wxaCDeAYkEsapMM8)IEn8yDbOAytooLc9Hlehb4jlXIOsDrPjapvSE)yDEPkZUGcCRla(IAUOolnTI17hRZlvz2fuSsx0Vf1Cr)xuvMHPaHfjzrmViQux0)fHTHxGxWtfX9ceGNQXxeJlk(dlQ5IW2WlWl4PY48GA8fX4II)WI(TOFAsRMZ5AsAquWSbz6uhzS0YPjb36cGRJqtwXtc4X0KwnNxOaoqmqyrmUioegmWlPHPazyruPUiSn8c8cEQmopOgFrmUOy9GM0Q5CUMKgeLUHXgfqN6i)Iwonj4wxaCDeAYkEsapMM81WJ1fGQlmou4MxbnPvZ5CnjhSuwj0aaP6uhzm1YPjTAoNRjhcIty5CEXyXMMeCRlaUocDQJ8R0YPjb36cGRJqtwXtc4X0KmTOxdpwxaQg2KJtPqF4cXraEYsSOMl6)ISAoVqbCGyGWIyCrCimyGxsdtbYWIOsDryB4f4f8uzCEqn(IyCrXFyr)0KwnNZ1Kue28cLeiKcHuN6iJnTCAsWTUa46i0Kv8KaEmnz9Co7KQaGXwc8cfHnVGcCRla(IAUO6Dc(1WvqlO0bJqHbcB8WIAZI(Qf1CrmTOolnTIasJ4WsLDHjOyLUOMlIPfXHolnTcEK0la8sJJ15kwPAsRMZ5AYug(AuOiS5f0Pos5Jwonj4wxaCDeAYkEsapMMKPf9A4X6cq1WMCCkf6dxiocWtwIf1Cr)xKvZ5fkGdedeweJlIdHbd8sAykqgwevQlcBdVaVGNkJZdQXxeJlkEmxuZf9FrmTOxdpwxak2auGwqPdgrHMf3QupNp5C(IOsDrbPGqusdtbYWIyCrXxevQlIMf3ArTzrX2dl63I(PjTAoNRjHwqPdgHo1rk)QLttcU1faxhHMSINeWJPjFn8yDbO6cJdfU5vqtA1Coxt2fghkCZRGo1rg)bTCAsWTUa46i0Kv8KaEmnjnlULId0tDYfXOKf9Lh0KwnNZ1K0GOlmoOtDKXJRLttcU1faxhHMSINeWJPj)VO0eGNkoqCEPlmoeuGBDbWxevQlIPf9A4X6cq1WMCCkf6dxiocWtwIfrL6IOzXTuCGEQtUO2SOy9WIOsDrDwAAfbKgXHLk7ctqHbcB8WIAZII5I(TOMlIPf9A4X6cqj9oX4uk0hU0fghkCZRWIAUiMw0RHhRlavdBYXPuOpCbcbWRqPJb7PM0Q5CUM0CFKnclNZ1PoY4mRLttcU1faxhHMSINeWJPj)VO0eGNkoqCEPlmoeuGBDbWxevQlIPf9A4X6cq1WMCCkf6dxiocWtwIfrL6IOzXTuCGEQtUO2SOy9WI(TOMlIPf9A4X6cqj9oX4uk0hUqaPTOMlIPf9A4X6cqj9oX4uk0hU0fghkCZRWIAUiMw0RHhRlavdBYXPuOpCbcbWRqPJb7PM0Q5CUMSkZUqjK45jOtDKXJLwonj4wxaCDeAYkEsapMMmnb4PQlgNxOzXTuGBDbWxuZfHTHxGxWtLX5b14lIXfz1CoVuVtWVgUM0Q5CUMeAbLoye6uhz8VOLttcU1faxhHM0Q5CUMKdeNhk9jbnzfpjGhttIzDG(WuavNf7JtP04yDUcCRla(IAUio0zPPvDwSpoLsJJ15kmqyJhwuBw0x0K1wvbusdtbYGoY46uhz8yQLttA1CoxtYbIZdL(KGMeCRlaUocDQJm(xPLttcU1faxhHMSINeWJPjzArPjapvehb4jlHcCRla(IAUiSn8c8cEQiUxGa8un(IyCrvzgMcewK84II)WIAUO0eGNkoqCEPlmoeuGBDbW1KwnNZ1K0GOGzdY0PoY4XMwonj4wxaCDeAYkEsapMMK4EbcWtfFcP5vyrmUO4XCruPUOolnT6yZYrxWMtbuSs1KwnNZ1K0GOlmoOtDKXLpA50KGBDbW1rOjR4jb8yAsI7fiapv8jKMxHfX4IIhZfrL6I(VOolnT6yZYrxWMtbuSsxuZfX0IstaEQiocWtwcf4wxa8f9ttA1CoxtsdIcMnitN6iJl)QLttcU1faxhHMSINeWJPjjUxGa8uXNqAEfweJlkEm1KwnNZ1KVGtbOzffmKyWsDQJK5h0YPjb36cGRJqtwXtc4X0KPjapvCG48sxyCiOa36cGRjTAoNRjtz4RrHIWMxqN6utYbAJvKA50rgxlNM0Q5CUMKpbmR0utcU1faxhHo1rYSwonPvZ5Cnz98albuimktvtcU1faxhHo1rglTCAsWTUa46i0KNunzasnPvZ5Cn5RHhRlan5RHlUraAYUW4qHBEf0Kv8KaEmnjtlcZ6a9HPaQQm7cLugC4wkWTUa4lQ5IyArywhOpmfqXn8tkcddfcGBcXCUcCRlaUMKdHkEKMZ5As55KYo2CrFtMDHfjNm4WTw0Hxumy4NueggyyrrimoSOyW8kSOgtkBrp2bhYffH4o(Io8ISCrXk6f9N5OxuJjLTi5W2iw0rVi5l74)wuAykqg0KVMGf0KPjapv0doKLU4oUcCRla(IOsDrbPGqusdtbYGQlmou4MxH4lIrjl6)II1I(6fLMa8uLyBeLJUGzhxbU1faFr)0PoYVOLttcU1faxhHM8KQjdqQjTAoNRjFn8yDbOjFnCXncqt2fghkCZRGMSINeWJPjXSoqFykGQkZUqjLbhULcCRlaUMKdHkEKMZ5As55KYw03KzxyrYjdoClgwuecJdlkgmVclQHmWxukdwuNLMErtyr8RHZWIAmPSf9yhCixueI74lYYfXC0l6F8OxuJjLTi5W2iw0rVi5l74)w0HxuJjLTOhxiaEfwueyWEUilx0xIEr)Jv0lQXKYwKCyBel6OxK8LD8FlknmfidAYxtWcAYolnTQkZUqjLbhULIFn8frL6IstaEQOhCilDXDCf4wxa8f1CrbPGqusdtbYGQlmou4MxH4lIrjl6)IyErF9IstaEQsSnIYrxWSJRa36cGVOFlIk1fX0IstaEQQTQcOC0fzwIbUcCRla(IAUOGuqikPHPazq1fghkCZRq8fXOKf9FrFzrF9IstaEQsSnIYrxWSJRa36cGVOF6uhzm1YPjb36cGRJqtEs1Kbi1KwnNZ1KVgESUa0KVgU4gbOj7cJdfU5vqtwXtc4X0KywhOpmfqXn8tkcddfcGBcXCUcCRlaUMKdHkEKMZ5As55KYwumy4NueggyyrrimoSOyW8kSilxKFyctSO0WuGCr1J1Zf1qg4lQZstd8f1BTiBrbOEo3WTweqtd1KHfD4fzIgwRWISCrFrUOxe9HxKF(xhdaX5tvt(AcwqtMMa8urp4qw6I74kWTUa4lIk1f9FrDwAAfbKgXHLk7ctqXkDruPUO0eGNQeBJOC0fm74kWTUa4lIk1fXHolnTccbWRqPJb7PIv6I(TOMlkifeIsAykqguDHXHc38keFrmkzr)xuSw0xVO0eGNQeBJOC0fm74kWTUa4l63IOsDrmTO0eGNkoqC(uvGBDbWxuZffKccrjnmfidQUW4qHBEfIVigLSOVOtDKFLwonj4wxaCDeAYtQMmaPM0Q5CUM81WJ1fGM81eSGMKPfLMa8uXbIZNQcCRla(IAUO6Dc(1WveqAehwQSlmbfgiSXdlQnl6RwuZfrZIBP4a9uNCrmUOy9GM81Wf3ianP07eJtPqF4cbKMo1rgBA50KGBDbW1rOjpPAYaKAsRMZ5AYxdpwxaAYxtWcAYxdpwxaQUW4qHBEfwuZf9Fr0S4wlQnlk2I5I(6fLMa8urp4qw6I74kWTUa4lsECrm)WI(PjFnCXncqtk9oX4uk0hU0fghkCZRGo1rkF0YPjb36cGRJqtEs1Kbi1KwnNZ1KVgESUa0KVMGf0KPjapvCG48PQa36cGVOMlIPfLMa8u1fJZl0S4wkWTUa4lQ5IQ3j4xdxbTGshmcfgiSXdlQnl6)IOu5kc7rlsECrmVOFlQ5IOzXTuCGEQtUigxeZpOjFnCXncqtk9oX4uk0hUaTGshmcDQJu(vlNMeCRlaUocn5jvtgGutA1Coxt(A4X6cqt(AcwqtMMa8ubHa4vO0XG9ubU1faFrnxetl61WJ1fGs6DIXPuOpCPlmou4MxHf1CrmTOxdpwxakP3jgNsH(WfciTf1Cr17e8RHRGqa8ku6yWEQyLQjFnCXncqt2WMCCkf6dxGqa8ku6yWEQtDKXFqlNMeCRlaUocn5jvtgGutA1Coxt(A4X6cqt(AcwqtMMa8urCeGNSekWTUa4lQ5IyArDwAAfXraEYsOyLQjFnCXncqt2WMCCkf6dxiocWtwcDQJmECTCAsWTUa46i0KwnNZ1KvtikwnNZlIjKAsXeYIBeGMSENGFnCDQJmoZA50KGBDbW1rOjR4jb8yAYolnTIgeL(r0nmNa8ufsR(CrswumxuZf9FrDwAA1qqCclNZlgl2uSsxevQlIPf1zPPveqAehwQSlmbfR0f9ttA1CoxtMYWxJcfHnVGo1rgpwA50KGBDbW1rOjR4jb8yAY0eGNkieaVcLogSNkWTUa4lQ5I(VOxdpwxaQg2KJtPqF4cecGxHshd2ZfrL6I4qNLMwbHa4vO0XG9uXkDr)0KHep1uhzCnPvZ5Cnz1eIIvZ58IycPMumHS4gbOjHqa8ku6yWEQtDKX)Iwonj4wxaCDeAYkEsapMMmnb4PIdeNpvf4wxaCnziXtn1rgxtA1CoxtIz9IvZ58IycPMumHS4gbOj5aX5tvN6iJhtTCAsWTUa46i0KwnNZ1KywVy1CoViMqQjftilUraAs)WeMqN6utYbIZNQwoDKX1YPjb36cGRJqtwXtc4X0K)xuAcWtfR3pwNxQYSlOa36cGVOMlQZstRy9(X68svMDbfR0f9Brnx0)fvLzykqyrsweZlIk1f9FryB4f4f8urCVab4PA8fX4II)WIAUiSn8c8cEQmopOgFrmUO4pSOFl6NM0Q5CUMKgefmBqMo1rYSwonj4wxaCDeAYkEsapMM81WJ1fGQlmou4MxbnPvZ5CnjhSuwj0aaP6uhzS0YPjb36cGRJqtwXtc4X0KwnNxOaoqmqyrmUioegmWlPHPazyruPUiSn8c8cEQmopOgFrmUO4pOjTAoNRjPiS5fkjqifcPo1r(fTCAsWTUa46i0Kv8KaEmnz9Co7KQaGXwc8cfHnVGcCRla(IAUO6Dc(1WvqlO0bJqHbcB8WIAZI(Qf1CrmTOolnTIasJ4WsLDHjOyLUOMlIPfXHolnTcEK0la8sJJ15kwPAsRMZ5AYug(AuOiS5f0PoYyQLttcU1faxhHMSINeWJPjTAoVqbCGyGWIyCrCimyGxsdtbYWIOsDryB4f4f8uzCEqn(IyCrmhZf1Cr)xetl61WJ1fGInafOfu6GruOzXTk1Z5toNViQuxuqkieL0WuGmSigxu8frL6IOzXTwuBwuS9WI(PjTAoNRjHwqPdgHo1r(vA50KGBDbW1rOjR4jb8yAYxdpwxaQUW4qHBEfwuZfX0IQ3j4xdxraPrCyPYUWeuyW4TwuZf9Fr17e8RHRGwqPdgHcde24HfX4II5IOsDr)xe2gEbEbpvgNhuJVigxKvZ58s9ob)A4lQ5IW2WlWl4PY48GA8f1MfXCmx0Vf9ttA1Coxt2fghkCZRGo1rgBA50KwnNZ1KdbXjSCoVySyttcU1faxhHo1rkF0YPjb36cGRJqtwXtc4X0KmTOxdpwxakP3jgNsH(WLUW4qHBEf0KwnNZ1KM7JSry5CUo1rk)QLttcU1faxhHMSINeWJPjPzXTuCGEQtUigLSOV8GM0Q5CUMKgeDHXbDQJm(dA50KGBDbW1rOjR4jb8yAsMw0RHhRlaL07eJtPqF4sxyCOWnVclQ5IyArVgESUausVtmoLc9HlqlO0bJqtA1CoxtwLzxOes88e0PoY4X1YPjb36cGRJqtwXtc4X0KPjapvCG48sxyCiOa36cGVOMlIPfvVtWVgUcAbLoyekmy8wlQ5I(VOQmdtbclsYIyEruPUO)lcBdVaVGNkI7fiapvJVigxu8hwuZfHTHxGxWtLX5b14lIXff)Hf9Br)0KwnNZ1K0GOGzdY0PoY4mRLttcU1faxhHM0Q5CUMKdeNhk9jbnzfpjGhttIzDG(WuavNf7JtP04yDUcCRla(IAUio0zPPvDwSpoLsJJ15kmqyJhwuBw0x0K1wvbusdtbYGoY46uhz8yPLttA1CoxtYbIZdL(KGMeCRlaUocDQJm(x0YPjb36cGRJqtwXtc4X0KDwAA1XMLJUGnNcOyLQjTAoNRjtz4RrHIWMxqN6iJhtTCAsWTUa46i0Kv8KaEmnjX9ceGNk(esZRWIyCrXJ5IOsDrDwAA1XMLJUGnNcOyLQjTAoNRjPbrbZgKPtDKX)kTCAsWTUa46i0Kv8KaEmnjX9ceGNk(esZRWIyCrXJPM0Q5CUM8fCkanROGHedwQtDKXJnTCAsWTUa46i0Kv8KaEmnzAcWtfhioV0fghckWTUa4AsRMZ5AYug(AuOiS5f0Po1K17e8RHRLthzCTCAsWTUa46i0Kv8KaEmnjtl6)IstaEQ4aX5tvbU1faFruPUOxdpwxakP3jgNsH(WfciTf9Brnxu9ob)A4kOfu6GrOWaHnEyrmUiMFyrnx0)fX0IQ3l4MNQxWtzTWlIk1fX0I4xQcJtZkkDS5Cvo1NJtzr)wevQlQFHWIAUi6HISSGbcB8WIAZIyoMAsRMZ5AscinIdlv2fMGo1rYSwonj4wxaCDeAYkEsapMMmnb4PIdeNpvf4wxa8f1Cr)xu9ob)A4kOfu6GrOWaHnEyrmUiMFyrnx0)fX0IEn8yDbO6cJdfU5vyruPUO6Dc(1WvDHXHc38kOWaHnEyrmUikvUIWE0I(TOFlQ5I(ViMwu9Eb38u9cEkRfEruPUiMwe)svyCAwrPJnNRYP(CCkl6NM0Q5CUMKasJ4WsLDHjOtDKXslNMeCRlaUocnzfpjGhttY0I4xQcJtZkkDS5Cvo1NJtrtA1CoxtggNMvu6yZ56uh5x0YPjb36cGRJqtwXtc4X0KmTO0eGNkoqC(uvGBDbWxuZfX0IEn8yDbOAytooLc9Hlehb4jlXIOsDrDwAAfnlEo2qHIj)euSs1KwnNZ1KPmOiJ1tDQJmMA50KGBDbW1rOjR4jb8yAY)lYQ58cfWbIbclIXfXHWGbEjnmfidlIk1fHTHxGxWtLX5b14lIXffRhw0pnPvZ5CnjiAfgZlCOIbqN6i)kTCAsWTUa46i0Kv8KaEmnzNLMwraPrCyPYUWeuyGWgpSigxeZXCruPUO(fclQ5IOhkYYcgiSXdlQnl6REqtA1Coxtk9Y5CDQJm20YPjb36cGRJqtYHqfpsZ5Cnzma0gRixeBaw0KaXIehLPQjR4jb8yAYxdpwxaQep(tilHwETeexUijlk(IAUO)lQZstRiG0ioSuzxyckwPlIk1f9FrmTO0eGNkoqC(uvGBDbWxuZfvVtWVgUIasJ4WsLDHjOWaHnEyrmUO)lIEOillyGWgpSigJ9xuIh)jKQmUQENGFnCfNfB5C(IAFrmVOFl63IOsDr0dfzzbde24Hf1gjlI5hw0VfrL6I(VOxdpwxaQep(tilHwETeexUijlI5f1CrmTOep(tivjZQ6Dc(1WvyW4Tw0VfrL6IyArVgESUaujE8NqwcT8AjiUutgexg0KjE8NqgxtA1CoxtYgGYKarqN6iLpA50KGBDbW1rOjTAoNRjzdqzsGiOjR4jb8yAYxdpwxaQep(tilHwETeexUijlI5f1Cr)xuNLMwraPrCyPYUWeuSsxevQl6)IyArPjapvCG48PQa36cGVOMlQENGFnCfbKgXHLk7ctqHbcB8WIyCr)xe9qrwwWaHnEyrmg7VOep(tivjZQ6Dc(1WvCwSLZ5lQ9fX8I(TOFlIk1frpuKLfmqyJhwuBKSiMFyr)wevQl6)IEn8yDbOs84pHSeA51sqC5IKSO4lQ5IyArjE8NqQY4Q6Dc(1WvyW4Tw0VfrL6IyArVgESUaujE8NqwcT8AjiUutgexg0KjE8NqYSo1PMecbWRqPJb7PwoDKX1YPjb36cGRJqtwXtc4X0K0S4wlIrjls(8WIAUO)lQENGFnCvxyCOWnVckmy8wlIk1fX0IEn8yDbO6cJdfU5vyr)0KwnNZ1KqiaEfkDmyp1PosM1YPjb36cGRJqtwXtc4X0KVgESUauDHXHc38kSOMlIdDwAAfecGxHshd2tfRunPvZ5CnjhSuwj0aaP6uhzS0YPjb36cGRJqtwXtc4X0KVgESUauDHXHc38kSOMlIdDwAAfecGxHshd2tfRunPvZ5CnzxyCOWnVc6uh5x0YPjb36cGRJqtwXtc4X0KCOZstRGqa8ku6yWEQyLQjTAoNRjn3hzJWY5CDQJmMA50KGBDbW1rOjR4jb8yAso0zPPvqiaEfkDmypvSs1KwnNZ1Kvz2fkHeppbDQtnPumupIULA50rgxlNM0Q5CUMSFzkaEHwyTaEJXPuY7rJRjb36cGRJqN6izwlNMeCRlaUocn5jvtgGutA1Coxt(A4X6cqt(AcwqtgxtwXtc4X0KjE8NqQY4kzwOeslvM3QWLgwuZf9FrmTOep(tivjZkzwOeslvM3QWLgwevQlkXJ)esvgxvVtWVgUIZITCoFrmkzrjE8NqQsMv17e8RHR4SylNZx0pn5RHlUraAYep(tilHwETeexQtDKXslNMeCRlaUocn5jvtgGutA1Coxt(A4X6cqt(AcwqtYSMSINeWJPjt84pHuLmRKzHsiTuzERcxAyrnx0)fX0Is84pHuLXvYSqjKwQmVvHlnSiQuxuIh)jKQKzv9ob)A4kol2Y58fX4Is84pHuLXv17e8RHR4SylNZx0pn5RHlUraAYep(tilHwETeexQtDKFrlNMeCRlaUocn5jvtgGutA1Coxt(A4X6cqt(AcwqtMMa8u1fJZl0S4wkWTUa4lQ5I(VimRd0hMcO4g(jfHHHcbWnHyoxbU1faFruPUO0eGNkoqCEPlmoeuGBDbWx0pnjhcv8inNZ1KXUdWIECTGffbyelYYfjUgl6XYIBTOgtkBrrigNVOhllU1IQhrFCGVOgtkBrWKYa8IIbd)KIWWWIo8IIbG48ffHW4qqt(A4IBeGMKnafOfu6GruOzXTk1Z5toNRtDQtDQtTg]] )


end
