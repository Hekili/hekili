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


    spec:RegisterPack( "Havoc", 20210203, [[d0K2bbqicLfrPu0JqsytIOpjcAuusDkkfRsKu1ROKmlKk3cjrTlk(LiXWeHogeSmPcpteyAqO6AijTnrs6BqO04ejrNtKuX6GqQ5bH4EiL9Hu1bPukSqcvpuKuMOijCrKePncHK(iLsPgjsI4KqiXkLkntkLk3KsjQ2jsQFksQ0qPuIYsPucpfWurcFLsPQXcHI9c1Ff1Gr5WKwSuESqtgvxw1MH0NHOrtiNwYQPuI0RLkA2eDBG2nv)wPHtjooLsjlhXZfmDfxNGTlv9DrQXtPKops06PuIy(uQ2pOXiGPadW15yQ7iXoqiXosmbgeOkcjabeWadLwogWIg7urEmGRGhdqLO9BedyrPuUkhtbgiScK4XaafOGuNA9uJOOdgOjuYbrXXnmaxNJPUJe7aHe7iXeyqGQiKGerSyGGLhXutvelIfdiQ4874ggG)qedqfubKLko46qgvIGpNazujA)gHDPcQaYquFJiOekHSeqhK1rIDGaSlSlvqfqwQjsDKpGOHDPcQaYOYqMT8pk4sSiAdvaYuNdz2Y2PwhYeckYdz2MTJUKdzOfsrdKDNhSnHm5ISIqMYTLkeMZHSzHm1IfjLq26skHSzHS2gcqgAHu0emyalKfTKhdqfubKLko46qgvIGpNazujA)gHDPcQaYquFJiOekHSeqhK1rIDGaSlSlvqfqwQjsDKpGOHDPcQaYOYqMT8pk4sSiAdvaYuNdz2Y2PwhYeckYdz2MTJUKdzOfsrdKDNhSnHm5ISIqMYTLkeMZHSzHm1IfjLq26skHSzHS2gcqgAHu0emWUWUACQ1dglKhxWMo0A7mYZZOsLYZtxoY8S2A5WUWUubvazuP26JcZ5q27pHsiBkWdzJOdzACwcKvbit71sQn5nWUACQ1d04vGiyzGD14uRhSIwkX1dcGpdQiRiSlvaz2(AeTcdKLAI0nazui6lHs6GmXLk)qwQq94HS01icYqulsyGmXL7YHSLaz6azjWkiZ6oScYsxJiiJcIwsiBrHmBHq52azJsq(ja7QXPwpyfTu6vsPn5PZvWtRjv(ZC1JNUcLMyeb)Olb5nrr6gYJOVekPRxLcN2OY7JbTiHj3K7Yn31M8C72dwUuMhLG8tW0Kk)zU6XJa90Sobu5rL3hZq0sMx0mrOCZDTjp3gyxQaYS91icYsnr6gGmke9LqjDqM4sLFilvOE8qwAr3HSr0HSMakkKvbiJVPD6GS01icYqulsyGmXL7YHmDGSoScYSgbRGS01icYOGOLeYwuiZwiuUnq2sGS01icYOsdH7XdzItU2jKPdKH4wbzwNaRGS01icYOGOLeYwuiZwiuUnq2OeKFcWUACQ1dwrlLELuAtE6Cf80AsL)mx94PRqPre8JUeK3efPBipI(sOKUEvkCAnbuutuKUH8i6lHsdFt72TpQ8(yqlsyYn5UCZDTjppzWYLY8OeKFcMMu5pZvpEeONM1DqLhvEFmdrlzErZeHYn31M8CBSBxSrL3htKYO85fnlshY5M7AtEEYGLlL5rji)emnPYFMRE8iqpnRrCQ8OY7JziAjZlAMiuU5U2KNBdSRgNA9Gv0sPxjL2KNoxbpnl7klhzgDjzWpkD9Qu40eBu59XWp46v0CxBYZtg3vY30Ub8JcUelI2qfmKdQLhqKunjQaHsd)OvSg6tqIWUACQ1dwrlLELuAtE6Cf80SSRSCKz0LKBsL)mx94PRxLcNwVskTjVPjv(ZC1JpP1OcekreelvPYJkVpg0IeMCtUl3CxBYZt9DKOnWUACQ1dwrlLELuAtE6Cf80SSRSCKz0LKpLp3UcsxVkfoTrL3hd)GRxrZDTjppPyJkVpMMSCEgvGqP5U2KNNmURKVPDZP852vqd5GA5beXAKrUbuT1uFh2KevGqPHF0kwd9DKiSRgNA9Gv0sPxjL2KNoxbpT0AnLJmJUK8dH7XNBKRDsxVkfoTrL3hZdH7XNBKRDAURn55jfRxjL2K3yzxz5iZOlj3Kk)zU6XNuSELuAtEJLDLLJmJUKm4hnzCxjFt7Mhc3Jp3ix70iyb2vJtTEWkAP0RKsBYtNRGNwATMYrMrxsgCbVpcG01RsHtBu59XaUG3hbqZDTjppPynbuud4cEFeancwGD14uRhSIwkrvkZACQ1ZYkm05k4Pf3vY30oDfknKrUHCqT8aTeHD14uRhSIwkJiYMoJuQv)PRqP1eqrnOxMBlytjCW7JjmAStAunP1nbuutbcUsDQ1ZQarncwSBxSMakQb8JcUelI2qfmcwSb2vJtTEWkAPevPmRXPwplRWqNRGN2dH7XNBKRDsxHsBu59X8q4E85g5ANM7AtEEsR7vsPn5nP1AkhzgDj5hc3Jp3ix70UD(BcOOMhc3Jp3ix70iyXgyxno16bROLcrWZACQ1ZYkm05k4PXp46vKUcL2OY7JHFW1RO5U2KNd7QXPwpyfTuicEwJtTEwwHHoxbpnFjGQe2f2vJtTEWe3vY30onWpk4sSiAdvGUcLMywpQ8(y4hC9kAURn552T3RKsBYBSSRSCKz0LKb)O2KmURKVPDZP852vqd5GA5b67iXKwlwC7VR(y6VpIOKyURn552TlgFhtOCubzUruNBMk2z5iTXU92gcjrlKIMm5GA5bePdQc7QXPwpyI7k5BA3kAPa(rbxIfrBOc0vO0gvEFm8dUEfn31M88Kwh3vY30U5u(C7kOHCqT8a9DKysRfRxjL2K30Kk)zU6XB3ECxjFt7MMu5pZvpEd5GA5b6rg5gq1wTXMKwlwC7VR(y6VpIOKyURn552TlgFhtOCubzUruNBMk2z5iTb2vJtTEWe3vY30Uv0sjuoQGm3iQZPRqPjgFhtOCubzUruNBMk2z5iHD14uRhmXDL8nTBfTugrplsWh6kuAInQ8(y4hC9kAURn55jfRxjL2K3KwRPCKz0LKbxW7JaOD7nbuudQaPwHqgPAl5gblWUACQ1dM4Us(M2TIwkOlNFsE28i6zuPcEyxno16btCxjFt7wrlLlPmuQN5ps(PRqPzTgNQ)57hSEGE(df588OeKFc2Tt0INF)9XOCEWuo9jirBGD14uRhmXDL8nTBfTuSStToDfkTMakQb8JcUelI2qfmKdQLhOVdQA3EBdHKOfsrtMCqT8aIKQjc7sfqwQ4OQGCGmuvkBAStidDjqMqqBYdz1CWGb2vJtTEWe3vY30Uv0sri8CnhmqxHsRjGIAa)OGlXIOnubJGfyxyxno16bd)GRxrAOxMjcbr0vO0SEu59Xi4TvW55OiDdM7AtEEYMakQrWBRGZZrr6gmcwSjP1rrkb5d06WUDRjAXZV)(ya3(dEFmLtpcjMKOfp)(7Jr58GPC6rirBSb2vJtTEWWp46v0kAPWVoIYH0)wORqP1RKsBYBAsL)mx94HD14uRhm8dUEfTIwkiLA1)8Cqlpm0vO004u9pF)G1d0ZFOiNNhLG8tWUDIw887VpgLZdMYPhHeHD14uRhm8dUEfTIwkJiYMoJuQv)PRqPfxNluJjCcrNZZiLA1FZDTjppzCxjFt7Mt5ZTRGgYb1YdisQMuSMakQb8JcUelI2qfmcwskg)nbuuZTvlB48C6vW5gblWUACQ1dg(bxVIwrlLt5ZTRG0vO0iAXZV)(yuopyeSy3orlE(93hJY5bt503bvHD14uRhm8dUEfTIwknPYFMRE80vO06vsPn5nnPYFMRE8jflURKVPDd4hfCjweTHkyix5uM064Us(M2nNYNBxbnKdQLhONQ2TBnrlE(93hJY5bt50h3vY30EsIw887VpgLZdMYrKoOQn2a7QXPwpy4hC9kAfTukqWvQtTEwfikSRgNA9GHFW1ROv0srDVevsDQ1PRqPjwVskTjVXYUYYrMrxsUjv(ZC1Jh2vJtTEWWp46v0kAPGEztQ8txHsdvGqPHF0kwd90q8eHD14uRhm8dUEfTIwkrr6gYHHuDE6kuAI1RKsBYBSSRSCKz0LKBsL)mx94tkwVskTjVXYUYYrMrxs(u(C7kiSRgNA9GHFW1ROv0sb9YmriiIUcL2OY7JHFW1ZnPYFWCxBYZtkwCxjFt7Mt5ZTRGgYvoLjToksjiFGwh2TBnrlE(93hd42FW7JPC6riXKeT453FFmkNhmLtpcjAJnWUACQ1dg(bxVIwrlf(bxpKB1C6IugLppkb5NaneORqPre8JUeK30eiE5iZPxbNNK)MakQPjq8YrMtVco3qoOwEarqCyxno16bd)GRxrROLc)GRhYTAoSRgNA9GHFW1ROv0szer20zKsT6pDfkTMakQzfM8IMjQJ8gblWUACQ1dg(bxVIwrlf0lZeHGi6kuAGB)bVpgEfg1JNEeOQD7nbuuZkm5fntuh5ncwGD14uRhm8dUEfTIwk93rEubzM8HCDORqPbU9h8(y4vyupE6rGQWUACQ1dg(bxVIwrlLreztNrk1Q)0vO0gvEFm8dUEUjv(dM7AtEoSlSRgNA9G5HW94ZnY1oP9q4E85g5AN0vO0qfiuspTuzIjToURKVPDttQ8N5QhVHCLtPD7I1RKsBYBAsL)mx94Tb2vJtTEW8q4E85g5ANwrlf(1ruoK(3cDfkTELuAtEttQ8N5QhFs(BcOOMhc3Jp3ix70iyb2vJtTEW8q4E85g5ANwrlLMu5pZvpE6kuA9kP0M8MMu5pZvp(K83eqrnpeUhFUrU2PrWcSRgNA9G5HW94ZnY1oTIwkQ7LOsQtToDfkn(BcOOMhc3Jp3ix70iyb2vJtTEW8q4E85g5ANwrlLOiDd5WqQopDfkn(BcOOMhc3Jp3ix70iyb2f2vJtTEW4lbuL06VJ8OcYm5d56qxHsBu59XaUG3hbqZDTjppztaf1yHClk5CdFt7jNc80JaSRgNA9GXxcOkTIwkOxMjcbr0vO0SUxjL2K3KwRPCKz0LKbxW7JaOD7JkVpgbVTcophfPBWCxBYZt2eqrncEBfCEoks3GrWInjToksjiFGwh2TBnrlE(93hd42FW7JPC6riXKeT453FFmkNhmLtpcjAJnWUACQ1dgFjGQ0kAPGEzUPeII80vO004u9pF)G1d0ZFOiNNhLG8tWUDIw887VpgLZdMYPpbjc7QXPwpy8LaQsROLc)6ikhs)BHUcLwVskTjVPjv(ZC1Jh2vJtTEW4lbuLwrlLceCL6uRNvbIc7QXPwpy8LaQsROLcsPw9pph0YddDfknX6vsPn5nP1AkhzgDjzWf8(iaM0Anov)Z3py9a98hkY55rji)eSBNOfp)(7Jr58GPC6rirBGD14uRhm(savPv0szer20zKsT6pDfkT46CHAmHti6CEgPuR(BURn55jJ7k5BA3CkFUDf0qoOwEars1KI1eqrnGFuWLyr0gQGrWssX4VjGIAUTAzdNNtVco3iyb2vJtTEW4lbuLwrlLt5ZTRG0vO0eRxjL2K3KwRPCKz0LKbxW7JaysR14u9pF)G1d0ZFOiNNhLG8tWUDIw887VpgLZdMYPhbQAdSRgNA9GXxcOkTIwknPYFMRE80vO06vsPn5nnPYFMRE8WUACQ1dgFjGQ0kAPGEztQ8txHsdvGqPHF0kwd90q8eHD14uRhm(savPv0srDVevsDQ1PRqPz9OY7JHFW1ZnPYFWCxBYZTBxSELuAtEtATMYrMrxsgCbVpcG2TJkqO0WpAfRbrsqI2T3eqrnGFuWLyr0gQGHCqT8aIqvBskwVskTjVXYUYYrMrxsUjv(ZC1JpPy9kP0M8M0AnLJmJUK8dH7XNBKRDc7QXPwpy8LaQsROLsuKUHCyivNNUcLM1JkVpg(bxp3Kk)bZDTjp3UDX6vsPn5nP1AkhzgDjzWf8(iaA3oQaHsd)OvSgejbjAtsX6vsPn5nw2vwoYm6sYGF0KI1RKsBYBSSRSCKz0LKBsL)mx94tkwVskTjVjTwt5iZOlj)q4E85g5ANWUACQ1dgFjGQ0kAPCkFUDfKUcL2OY7JPjlNNrfiuAURn55jjAXZV)(yuopykN(4Us(M2HD14uRhm(savPv0sHFW1d5wnNUiLr5ZJsq(jqdb6kuAeb)Olb5nnbIxoYC6vW5j5VjGIAAceVCK50RGZnKdQLhqeeh2vJtTEW4lbuLwrlf(bxpKB1Cyxno16bJVeqvAfTuqVmtecIORqPj2OY7JbCbVpcGM7AtEEsIw887VpgWT)G3ht50hfPeKpK6riXKJkVpg(bxp3Kk)bZDTjph2vJtTEW4lbuLwrlf0lBsLF6kuAGB)bVpgEfg1JNEeOQD7nbuuZkm5fntuh5ncwGD14uRhm(savPv0sb9YmriiIUcLg42FW7JHxHr94PhbQA3U1nbuuZkm5fntuh5ncwsk2OY7JbCbVpcGM7AtEUnWUACQ1dgFjGQ0kAP0Fh5rfKzYhY1HUcLg42FW7JHxHr94PhbQc7QXPwpy8LaQsROLYiISPZiLA1F6kuAJkVpg(bxp3Kk)bZDTjphd0FsOwhtDhj2bcjIqhjadKwjE5idyaBVTHTGAefQTTr0qgKrHOdzfOLLmqg6sGSe6lbuLjeYi32sOiNdzHf8qMkmlOoNdzrrQJ8bdSRTR8dziG4iAil1wV)K5CilHeb)Olb5niMeczZczjKi4hDjiVbXyURn55jeYSgbB1gdSlSRT32WwqnIc122iAidYOq0HSc0YsgidDjqwc5hvfKtcHmYTTekY5qwybpKPcZcQZ5qwuK6iFWa7A7k)qwcq0qwQTE)jZ5qwcjc(rxcYBqmjeYMfYsirWp6sqEdIXCxBYZtiKPdKrLM6A7GmRrWwTXa7A7k)qgIJOHSuB9(tMZHSese8JUeK3GysiKnlKLqIGF0LG8geJ5U2KNNqithiJkn112bzwJGTAJb2f212BBylOgrHABBenKbzui6qwbAzjdKHUeilHXDL8nTNqiJCBlHICoKfwWdzQWSG6CoKffPoYhmWU2UYpKHaIgYsT17pzohYsyC7VR(yqmM7AtEEcHSzHSeg3(7QpgetcHmRrWwTXa7A7k)qwhiAil1wV)K5CilHXT)U6JbXyURn55jeYMfYsyC7VR(yqmjeYSgbB1gdSlSRT32WwqnIc122iAidYOq0HSc0YsgidDjqwc5hC9kMqiJCBlHICoKfwWdzQWSG6CoKffPoYhmWU2UYpKHqhiAil1wV)K5CilHeb)Olb5niMeczZczjKi4hDjiVbXyURn55jeYSgbB1gdSlSlIcOLLmNdzPkKPXPwhYKvycgyxmGSctatbgWxcOkXuGPgbmfyG7AtEowCmqKuZjLIbgvEFmGl49ra0CxBYZHSKqwtaf1yHClk5CdFt7qwsiBkWdz0dziGb04uRJb6VJ8OcYm5d56Ghm1DGPadCxBYZXIJbIKAoPumG1qwVskTjVjTwt5iZOljdUG3hbqiZUDiBu59Xi4TvW55OiDdM7AtEoKLeYAcOOgbVTcophfPBWiybYSbYsczwdzrrkb5dqgniRdiZUDiZAiJOfp)(7JbC7p49XuoKrpKHqIqwsiJOfp)(7Jr58GPCiJEidHeHmBGmBWaACQ1XaOxMjcbr4btDcWuGbURn55yXXarsnNukgqJt1)89dwpaz0dz8hkY55rji)eGm72HmIw887VpgLZdMYHm6HSeKigqJtToga9YCtjef5XdMAehtbg4U2KNJfhdej1CsPyGELuAtEttQ8N5QhpgqJtTogGFDeLdP)TGhm1uftbgqJtTogOabxPo16zvGOyG7AtEowC8GPovXuGbURn55yXXarsnNukgqmiRxjL2K3KwRPCKz0LKbxW7JaiKLeYSgY04u9pF)G1dqg9qg)HICEEucYpbiZUDiJOfp)(7Jr58GPCiJEidHeHmBWaACQ1XaiLA1)8Cqlpm4btnIftbg4U2KNJfhdej1CsPyG46CHAmHti6CEgPuR(BURn55qwsilURKVPDZP852vqd5GA5bidrGSufYsczIbznbuud4hfCjweTHkyeSazjHmXGm(BcOOMBRw2W550RGZncwWaACQ1XaJiYMoJuQv)XdM6ujMcmWDTjphlogisQ5KsXaIbz9kP0M8M0AnLJmJUKm4cEFeaHSKqM1qMgNQ)57hSEaYOhY4puKZZJsq(jaz2TdzeT453FFmkNhmLdz0dziqviZgmGgNADmWP852vq8GPo1btbg4U2KNJfhdej1CsPyGELuAtEttQ8N5QhpgqJtTogOjv(ZC1JhpyQrirmfyG7AtEowCmqKuZjLIbqfiuA4hTI1az0tdYq8eXaACQ1XaOx2Kk)4btnciGPadCxBYZXIJbIKAoPumG1q2OY7JHFW1ZnPYFWCxBYZHm72HmXGSELuAtEtATMYrMrxsgCbVpcGqMD7qgQaHsd)OvSgidrGSeKiKz3oK1eqrnGFuWLyr0gQGHCqT8aKHiqgvHmBGSKqMyqwVskTjVXYUYYrMrxsUjv(ZC1JhYsczIbz9kP0M8M0AnLJmJUK8dH7XNBKRDIb04uRJbu3lrLuNAD8GPgHoWuGbURn55yXXarsnNukgWAiBu59XWp465Mu5pyURn55qMD7qMyqwVskTjVjTwt5iZOljdUG3hbqiZUDidvGqPHF0kwdKHiqwcseYSbYsczIbz9kP0M8gl7klhzgDjzWpkKLeYedY6vsPn5nw2vwoYm6sYnPYFMRE8qwsitmiRxjL2K3KwRPCKz0LKFiCp(CJCTtmGgNADmquKUHCyivNhpyQribykWa31M8CS4yGiPMtkfdmQ8(yAYY5zubcLM7AtEoKLeYiAXZV)(yuopykhYOhY04uRNJ7k5BAhdOXPwhdCkFUDfepyQraXXuGbURn55yXXaACQ1Xa8dUEi3Q5yGiPMtkfdqe8JUeK30eiE5iZPxbNBURn55qwsiJ)MakQPjq8YrMtVco3qoOwEaYqeidXXarkJYNhLG8tatnc4btncuftbgqJtTogGFW1d5wnhdCxBYZXIJhm1iKQykWa31M8CS4yGiPMtkfdigKnQ8(yaxW7JaO5U2KNdzjHmIw887VpgWT)G3ht5qg9qwuKsq(aKL6HmeseYsczJkVpg(bxp3Kk)bZDTjphdOXPwhdGEzMieeHhm1iGyXuGbURn55yXXarsnNukgaC7p49XWRWOE8qg9qgcufYSBhYAcOOMvyYlAMOoYBeSGb04uRJbqVSjv(XdMAesLykWa31M8CS4yGiPMtkfdaU9h8(y4vyupEiJEidbQcz2TdzwdznbuuZkm5fntuh5ncwGSKqMyq2OY7JbCbVpcGM7AtEoKzdgqJtToga9YmriicpyQri1btbg4U2KNJfhdej1CsPyaWT)G3hdVcJ6Xdz0dziqvmGgNADmq)DKhvqMjFixh8GPUJeXuGbURn55yXXarsnNukgyu59XWp465Mu5pyURn55yano16yGreztNrk1Q)4bpya(rvb5GPatncykWaACQ1Xa8kqeSmyG7AtEowC8GPUdmfyano16yG46bbWNbvKvedCxBYZXIJhm1jatbg4U2KNJfhdSwWaHpyano16yGELuAtEmqVsYUcEmqtQ8N5QhpgisQ5KsXaIbzeb)Olb5nrr6gYJOVekn31M8Cma)HiPSm16yaBFnIwHbYsnr6gGmke9LqjDqM4sLFilvOE8qw6AebziQfjmqM4YD5q2sGmDGSeyfKzDhwbzPRreKrbrljKTOqMTqOCBGSrji)eWa9Qu4yGrL3hdArctUj3LBURn55qMD7qwWYLY8OeKFcMMu5pZvpEeGm6PbzwdzjaYOYq2OY7JziAjZlAMiuU5U2KNdz2Ghm1ioMcmWDTjphlogyTGbcFWaACQ1Xa9kP0M8yGELKDf8yGMu5pZvpEmqKuZjLIbic(rxcYBII0nKhrFjuAURn55ya(drszzQ1Xa2(AebzPMiDdqgfI(sOKoitCPYpKLkupEilTO7q2i6qwtaffYQaKX30oDqw6AebziQfjmqM4YD5qMoqwhwbzwJGvqw6Aebzuq0sczlkKzlek3giBjqw6AebzuPHW94HmXjx7eY0bYqCRGmRtGvqw6Aebzuq0sczlkKzlek3giBucYpbmqVkfogOjGIAII0nKhrFjuA4BAhYSBhYgvEFmOfjm5MCxU5U2KNdzjHSGLlL5rji)emnPYFMRE8iaz0tdYSgY6aYOYq2OY7JziAjZlAMiuU5U2KNdz2az2TdzIbzJkVpMiLr5ZlAwKoKZn31M8CiljKfSCPmpkb5NGPjv(ZC1JhbiJEAqM1qgIdzuziBu59XmeTK5fntek3CxBYZHmBWdMAQIPadCxBYZXIJbwlyGWhmGgNADmqVskTjpgOxLchdigKnQ8(y4hC9kAURn55qwsilURKVPDd4hfCjweTHkyihulpazicKLQqwsidvGqPHF0kwdKrpKLGeXa9kj7k4Xaw2vwoYm6sYGFu8GPovXuGbURn55yXXaRfmq4dgqJtTogOxjL2Khd0RsHJb6vsPn5nnPYFMRE8qwsiZAidvGqjKHiqgILQqgvgYgvEFmOfjm5MCxU5U2KNdzPEiRJeHmBWa9kj7k4Xaw2vwoYm6sYnPYFMRE84btnIftbg4U2KNJfhdSwWaHpyano16yGELuAtEmqVkfogyu59XWp46v0CxBYZHSKqMyq2OY7JPjlNNrfiuAURn55qwsilURKVPDZP852vqd5GA5bidrGmRHmKrUbuTvil1dzDaz2azjHmubcLg(rRynqg9qwhjIb6vs2vWJbSSRSCKz0LKpLp3UcIhm1PsmfyG7AtEowCmWAbde(Gb04uRJb6vsPn5Xa9Qu4yGrL3hZdH7XNBKRDAURn55qwsitmiRxjL2K3yzxz5iZOlj3Kk)zU6XdzjHmXGSELuAtEJLDLLJmJUKm4hfYsczXDL8nTBEiCp(CJCTtJGfmqVsYUcEmqATMYrMrxs(HW94ZnY1oXdM6uhmfyG7AtEowCmWAbde(Gb04uRJb6vsPn5Xa9Qu4yGrL3hd4cEFean31M8CiljKjgK1eqrnGl49ra0iybd0RKSRGhdKwRPCKz0LKbxW7JaiEWuJqIykWa31M8CS4yGiPMtkfdGmYnKdQLhGmAqwIyano16yGOkLzno16zzfgmGSct2vWJbI7k5BAhpyQrabmfyG7AtEowCmqKuZjLIbAcOOg0lZTfSPeo49Xegn2jKrdYOkKLeYSgYAcOOMceCL6uRNvbIAeSaz2TdzIbznbuud4hfCjweTHkyeSaz2Gb04uRJbgrKnDgPuR(Jhm1i0bMcmWDTjphlogisQ5KsXaJkVpMhc3Jp3ix70CxBYZHSKqM1qwVskTjVjTwt5iZOlj)q4E85g5ANqMD7qg)nbuuZdH7XNBKRDAeSaz2Gb04uRJbIQuM14uRNLvyWaYkmzxbpg4HW94ZnY1oXdMAesaMcmWDTjphlogisQ5KsXaJkVpg(bxVIM7AtEogqJtTogGi4zno16zzfgmGSct2vWJb4hC9kIhm1iG4ykWa31M8CS4yano16yaIGN14uRNLvyWaYkmzxbpgWxcOkXdEWa8dUEfXuGPgbmfyG7AtEowCmqKuZjLIbSgYgvEFmcEBfCEoks3G5U2KNdzjHSMakQrWBRGZZrr6gmcwGmBGSKqM1qwuKsq(aKrdY6aYSBhYSgYiAXZV)(ya3(dEFmLdz0dziKiKLeYiAXZV)(yuopykhYOhYqiriZgiZgmGgNADma6LzIqqeEWu3bMcmWDTjphlogisQ5KsXa9kP0M8MMu5pZvpEmGgNADma)6ikhs)BbpyQtaMcmWDTjphlogisQ5KsXaACQ(NVFW6biJEiJ)qroppkb5NaKz3oKr0INF)9XOCEWuoKrpKHqIyano16yaKsT6FEoOLhg8GPgXXuGbURn55yXXarsnNukgiUoxOgt4eIoNNrk1Q)M7AtEoKLeYI7k5BA3CkFUDf0qoOwEaYqeilvHSKqMyqwtaf1a(rbxIfrBOcgblqwsitmiJ)MakQ52QLnCEo9k4CJGfmGgNADmWiISPZiLA1F8GPMQykWa31M8CS4yGiPMtkfdq0INF)9XOCEWiybYSBhYiAXZV)(yuopykhYOhY6GQyano16yGt5ZTRG4btDQIPadCxBYZXIJbIKAoPumqVskTjVPjv(ZC1JhYsczIbzXDL8nTBa)OGlXIOnubd5kNsiljKznKf3vY30U5u(C7kOHCqT8aKrpKrviZUDiZAiJOfp)(7Jr58GPCiJEitJtTEoURKVPDiljKr0INF)9XOCEWuoKHiqwhufYSbYSbdOXPwhd0Kk)zU6XJhm1iwmfyano16yGceCL6uRNvbIIbURn55yXXdM6ujMcmWDTjphlogisQ5KsXaIbz9kP0M8gl7klhzgDj5Mu5pZvpEmGgNADmG6EjQK6uRJhm1PoykWa31M8CS4yGiPMtkfdGkqO0WpAfRbYONgKH4jIb04uRJbqVSjv(XdMAesetbg4U2KNJfhdej1CsPyaXGSELuAtEJLDLLJmJUKCtQ8N5QhpKLeYedY6vsPn5nw2vwoYm6sYNYNBxbXaACQ1Xarr6gYHHuDE8GPgbeWuGbURn55yXXarsnNukgyu59XWp465Mu5pyURn55qwsitmilURKVPDZP852vqd5kNsiljKznKffPeKpaz0GSoGm72HmRHmIw887VpgWT)G3ht5qg9qgcjczjHmIw887VpgLZdMYHm6HmeseYSbYSbdOXPwhdGEzMieeHhm1i0bMcmWDTjphlogqJtTogGFW1d5wnhdej1CsPyaIGF0LG8MMaXlhzo9k4CZDTjphYscz83eqrnnbIxoYC6vW5gYb1YdqgIaziogiszu(8OeKFcyQrapyQribykWaACQ1Xa8dUEi3Q5yG7AtEowC8GPgbehtbg4U2KNJfhdej1CsPyGMakQzfM8IMjQJ8gblyano16yGreztNrk1Q)4btncuftbg4U2KNJfhdej1CsPyaWT)G3hdVcJ6Xdz0dziqviZUDiRjGIAwHjVOzI6iVrWcgqJtToga9YmriicpyQrivXuGbURn55yXXarsnNukgaC7p49XWRWOE8qg9qgcufdOXPwhd0Fh5rfKzYhY1bpyQraXIPadCxBYZXIJbIKAoPumWOY7JHFW1ZnPYFWCxBYZXaACQ1XaJiYMoJuQv)XdEWawipUGnDWuGPgbmfyano16yG2oJ88mQuP880LJmpRTwog4U2KNJfhp4bd8q4E85g5ANykWuJaMcmWDTjphlogisQ5KsXaOcekHm6PbzPYeHSKqM1qwCxjFt7MMu5pZvpEd5kNsiZUDitmiRxjL2K30Kk)zU6Xdz2Gb04uRJbEiCp(CJCTt8GPUdmfyG7AtEowCmqKuZjLIb6vsPn5nnPYFMRE8qwsiJ)MakQ5HW94ZnY1oncwWaACQ1Xa8RJOCi9Vf8GPobykWa31M8CS4yGiPMtkfd0RKsBYBAsL)mx94HSKqg)nbuuZdH7XNBKRDAeSGb04uRJbAsL)mx94XdMAehtbg4U2KNJfhdej1CsPya(BcOOMhc3Jp3ix70iybdOXPwhdOUxIkPo164btnvXuGbURn55yXXarsnNukgG)MakQ5HW94ZnY1oncwWaACQ1Xarr6gYHHuDE8GhmqCxjFt7ykWuJaMcmWDTjphlogisQ5KsXaIbzwdzJkVpg(bxVIM7AtEoKz3oK1RKsBYBSSRSCKz0LKb)OqMnqwsilURKVPDZP852vqd5GA5biJEiRJeHSKqM1qMyqwC7VR(y6VpIOKaz2TdzIbz8DmHYrfK5grDUzQyNLJeYSbYSBhYABiazjHm0cPOjtoOwEaYqeiRdQIb04uRJba)OGlXIOnub8GPUdmfyG7AtEowCmqKuZjLIbgvEFm8dUEfn31M8CiljKznKf3vY30U5u(C7kOHCqT8aKrpK1rIqwsiZAitmiRxjL2K30Kk)zU6Xdz2TdzXDL8nTBAsL)mx94nKdQLhGm6HmKrUbuTviZgiZgiljKznKjgKf3(7QpM(7JikjqMD7qMyqgFhtOCubzUruNBMk2z5iHmBWaACQ1XaGFuWLyr0gQaEWuNamfyG7AtEowCmqKuZjLIbedY47ycLJkiZnI6CZuXolhjgqJtTogiuoQGm3iQZXdMAehtbg4U2KNJfhdej1CsPyaXGSrL3hd)GRxrZDTjphYsczIbz9kP0M8M0AnLJmJUKm4cEFeaHm72HSMakQbvGuRqiJuTLCJGfmGgNADmWi6zrc(Ghm1uftbgqJtTogaD58tYZMhrpJkvWJbURn55yXXdM6uftbg4U2KNJfhdej1CsPyaRHmnov)Z3py9aKrpKXFOiNNhLG8taYSBhYiAXZV)(yuopykhYOhYsqIqMnyano16yGlPmuQN5ps(XdMAelMcmWDTjphlogisQ5KsXanbuud4hfCjweTHkyihulpaz0dzDqviZUDiRTHaKLeYqlKIMm5GA5bidrGSunrmGgNADmGLDQ1XdM6ujMcmWDTjphlogqJtTogqi8CnhmGb4pejLLPwhdKkoQkihidvLYMg7eYqxcKje0M8qwnhmyWarsnNukgOjGIAa)OGlXIOnubJGf8Gh8GbuHr0sWaafyQHh8GX]] )
end
