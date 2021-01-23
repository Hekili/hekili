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


    spec:RegisterPack( "Havoc", 20210123, [[dKKSabqiKQEKuLYMeP(eLsnkkrNIsXQKQu1ROeMfi1TOuI2ff)seAyIOoMuvlte5zIatdePRrizBIG6BGiACIG05OucToqu18KQK7Hu2hsLdsivzHeIhcIWefbXfbrP2iLsWhjKQAKGOKtkvPYkbHzsPKStKKFsiv0sbrLNcyQGKVsPKASGOyVq9xHgmQomPflLhlyYOCzvBguFgjgnH60sETufZMOBd0UP63knCkPJtivA5iEUOMUIRtW2LkFxKmEcPCEKuRNqQW8PuTFiJ7JHcdW05yQsk5K6NC)KsGPpKmjrLCcWad1wpgWQg6rPCmGRGhdazPDBadyvPwUkddfgiVcKWXaafOGuNADibrHhmqtOKtVZXnmatNJPkPKtQFY9tkbM(qYKG0KefgiB9bmvIcscjXaIlg7oUHbyphWa9wVH4jKdUoIdzj4ZjioKL2Tbee9wVH4qOUGsOgXtkbqJ4jLCs9XawjlCjpgO36nepHCW1rCilbFobXHS0UnGGO36nehc1fuc1iEsjaAepPKtQpcceeAyQ1ZgRKhwWMo0A7mYZIWsL6ZsvoL4SIw5iiqq0B9gIdzlApimNH4V7eQr8PapIpIpIRHzjiELrCTtlP2K3GGqdtTEMgRYebRdccnm16zlOLyy9Sa4JGkLkGGO3qCBDnIxHbXHeI1nJ4qj(lHAOrCrKk7iEcr9Wr8u1igXTfksEqCrK7Yq8LG46G4jWce3YKSaXtvJyehkIwseFHrCiNq52G4JsO8jJGqdtTE2cAj2PKsBYdTRGNwtQShzQho0fmn6jc(HxcLBcI1nhhXFjudDNkfoTrL3hdCrYtSj3LzURn5z2TNTEPmokHYNSPjv2Jm1dVpD0Smb2YrL3hZq0sgx4irOCZDTjpZgee9gIBRRrmIdjeRBgXHs8xc1qJ4Iiv2r8eI6HJ4PeFhXhXhXBcWWiELrC2MYHgXtvJye3wOi5bXfrUldX1bXtYce3Y(wG4PQrmIdfrljIVWioKtOCBq8LG4PQrmIdzNZ3dhXfHCThexhehsTaXTmbwG4PQrmIdfrljIVWioKtOCBq8rju(KrqOHPwpBbTe7usPn5H2vWtRjv2Jm1dh6cMgrWp8sOCtqSU54i(lHAO7uPWP1eGHnbX6MJJ4VeQnSnLB3(OY7JbUi5j2K7Ym31M8S0zRxkJJsO8jBAsL9it9W7thnltYwoQ8(ygIwY4chjcLBURn5z2y3o9JkVpMa1b5JlCuSoKZm31M8S0zRxkJJsO8jBAsL9it9W7thnlHuB5OY7JziAjJlCKiuU5U2KNzdccnm16zlOLyNskTjp0UcEAw3vwoLi8sIGFuO7uPWPr)OY7JHDW1RG5U2KNLoSRKTPCd4hfCjwfV5kBihulp3ReonSaHAd7WvOg6sqYii0WuRNTGwIDkP0M8q7k4PzDxz5uIWlj2Kk7rM6HdDNkfoToLuAtEttQShzQhEAlHfiu3liPOSLJkVpg4IKNytUlZCxBYZ69jLSnii0WuRNTGwIDkP0M8q7k4PzDxz5uIWljEQFSDfe6ovkCAJkVpg2bxVcM7AtEwA6hvEFmnz5SiSaHAZDTjplDyxjBt5Mt9JTRGgYb1YZ9YskbMbufTEFs2KgwGqTHD4kudDjLmccnm16zlOLyNskTjp0UcEAP0AkNseEjXNZ3dp2ix7b6ovkCAJkVpMNZ3dp2ix7XCxBYZstFNskTjVX6UYYPeHxsSjv2Jm1dpn9DkP0M8gR7klNseEjrWpA6WUs2MYnpNVhESrU2JrWkccnm16zlOLyNskTjp0UcEAP0AkNseEjrWf8(iacDNkfoTrL3hd4cEFean31M8S003eGHnGl49ra0iyfbHgMA9Sf0smOszudtTEuw5bAxbpTWUs2MYHUGPrjWmKdQLNPLmccnm16zlOL4iMSPIuKA1DOlyAnbyyd8LX2c2ucd8(yYJg6HMOsBztag2uGGRuNA9OkquJGv72PVjadBa)OGlXQ4nxzJGvBqqOHPwpBbTedQug1WuRhLvEG2vWt7589WJnY1EGUGPnQ8(yEoFp8yJCThZDTjplTLDkP0M8MuAnLtjcVK4Z57HhBKR9y3o7nbyyZZ57HhBKR9yeSAdccnm16zlOLirWJAyQ1JYkpq7k4PXo46va6cM2OY7JHDW1RG5U2KNHGqdtTE2cAjse8OgMA9OSYd0UcEA(savjcceeAyQ1ZMWUs2MYPb(rbxIvXBUYqxW0O3YrL3hd7GRxbZDTjpZU9oLuAtEJ1DLLtjcVKi4h1M0HDLSnLBo1p2UcAihulptxsjN2s6dB3D1ht39rm1eZDTjpZUD6z7yYLdliJnI6mZuHEkNIn2TdxueprYb1YZ9kjrHGqdtTE2e2vY2uUf0se8JcUeRI3CLHUGPnQ8(yyhC9kyURn5zPTmSRKTPCZP(X2vqd5GA5z6sk50wsFNskTjVPjv2Jm1d3U9WUs2MYnnPYEKPE4gYb1YZ0rjWmGQOzJnPTK(W2Dx9X0DFetnXCxBYZSBNE2oMC5WcYyJOoZmvONYPydccnm16ztyxjBt5wqlXC5WcYyJOod6cMg9SDm5YHfKXgrDMzQqpLtbbHgMA9SjSRKTPClOL4i(rXc(aDbtJ(rL3hd7GRxbZDTjpln9DkP0M8MuAnLtjcVKi4cEFeaTBVjadBGfi1kKJuurh3iyfbHgMA9SjSRKTPClOLi8YyNeNnoIFewQGhbHgMA9SjSRKTPClOL4LuNl1JShi)qxW0Sudt1949dwpth75ICwCucLpz72jAXIV7(yuglBkNUeKSnii0WuRNnHDLSnLBbTeTUtTo0fmTMamSb8JcUeRI3CLnKdQLNPljrz3oCrr8ejhulp3Reozee9gINqoSkihehwLYMg6bXHxcIlK1M8iEnhmBqqOHPwpBc7kzBk3cAjkKFSMdMHUGP1eGHnGFuWLyv8MRSrWkcceeAyQ1Zg2bxVc0GVmseYIHUGPz5OY7JrWBRGZIbX6Mn31M8S0nbyyJG3wbNfdI1nBeSAtAldIvcLNPLKD7ws0IfF39XaUDh8(ykNU(jNMOfl(U7JrzSSPC66NSn2GGqdtTE2Wo46vWcAjYUoIJ5u)wHUGP1PKsBYBAsL9it9WrqOHPwpByhC9kybTePi1Q7X5GwFEGUGPPHP6E8(bRNPJ9CrolokHYNSD7eTyX3DFmkJLnLtx)KrqOHPwpByhC9kybTehXKnvKIuRUdDbtlSotOgt(eIoNfPi1Q7M7AtEw6WUs2MYnN6hBxbnKdQLN7vcNM(MamSb8JcUeRI3CLncwttp7nbyyZfnRB(SyQvWzgbRii0WuRNnSdUEfSGwIN6hBxbHUGPr0IfF39XOmw2iy1UDIwS47UpgLXYMYPljrHGqdtTE2Wo46vWcAj2Kk7rM6HdDbtRtjL2K30Kk7rM6HNM(WUs2MYnGFuWLyv8MRSHCLrDAld7kzBk3CQFSDf0qoOwEMorz3ULeTyX3DFmkJLnLtxyxjBt5PjAXIV7(yuglBkVxjjkBSbbHgMA9SHDW1RGf0sSabxPo16rvGOii0WuRNnSdUEfSGwIQ7L4sQtTo0fmn67usPn5nw3vwoLi8sInPYEKPE4ii0WuRNnSdUEfSGwIWx2Kk7qxW0GfiuByhUc1qhninzeeAyQ1Zg2bxVcwqlXGyDZX8qQEo0fmn67usPn5nw3vwoLi8sInPYEKPE4PPVtjL2K3yDxz5uIWljEQFSDfebHgMA9SHDW1RGf0se(Yirilg6cM2OY7JHDW1JnPYE2CxBYZstFyxjBt5Mt9JTRGgYvg1PTmiwjuEMws2TBjrlw8D3hd42DW7JPC66NCAIwS47UpgLXYMYPRFY2ydccnm16zd7GRxblOLi7GRNJTAo0bQdYhhLq5tMwFOlyAeb)WlHYnnbIxoLyQvWzPzVjadBAceVCkXuRGZmKdQLN7fKIGqdtTE2Wo46vWcAjYo465yRMJGqdtTE2Wo46vWcAjoIjBQifPwDh6cMwtag2SctCHJe1PCJGveeAyQ1Zg2bxVcwqlr4lJeHSyOlyAGB3bVpgwLh1dNU(IYU9MamSzfM4chjQt5gbRii0WuRNnSdUEfSGwID3PCybzK8HCDGUGPbUDh8(yyvEupC66lkeeAyQ1Zg2bxVcwqlXrmztfPi1Q7qxW0gvEFmSdUESjv2ZM7AtEgcceeAyQ1ZMNZ3dp2ix7H2Z57HhBKR9aDbtdwGqnD0sOjN2YWUs2MYnnPYEKPE4gYvg12TtFNskTjVPjv2Jm1d3geeAyQ1ZMNZ3dp2ix7XcAjYUoIJ5u)wHUGP1PKsBYBAsL9it9WtZEtag28C(E4Xg5ApgbRii0WuRNnpNVhESrU2Jf0sSjv2Jm1dh6cMwNskTjVPjv2Jm1dpn7nbyyZZ57HhBKR9yeSIGqdtTE28C(E4Xg5Apwqlr19sCj1Pwh6cMg7nbyyZZ57HhBKR9yeSIGqdtTE28C(E4Xg5ApwqlXGyDZX8qQEo0fmn2BcWWMNZ3dp2ix7Xiyfbbccnm16zJVeqvsR7oLdliJKpKRd0fmTrL3hd4cEFean31M8S0nbyyJvYTQKZmSnLNEkWtxFeeAyQ1ZgFjGQ0cAjcFzKiKfdDbtZYoLuAtEtkTMYPeHxseCbVpcG2TpQ8(ye82k4SyqSUzZDTjplDtag2i4TvWzXGyDZgbR2K2YGyLq5zAjz3ULeTyX3DFmGB3bVpMYPRFYPjAXIV7(yuglBkNU(jBJnii0WuRNn(savPf0se(YytjeLYHUGPPHP6E8(bRNPJ9CrolokHYNSD7eTyX3DFmkJLnLtxcsgbHgMA9SXxcOkTGwISRJ4yo1VvOlyADkP0M8MMuzpYupCeeAyQ1ZgFjGQ0cAjwGGRuNA9OkqueeAyQ1ZgFjGQ0cAjsrQv3JZbT(8aDbtJ(oLuAtEtkTMYPeHxseCbVpcGPTudt1949dwpth75ICwCucLpz72jAXIV7(yuglBkNU(jBdccnm16zJVeqvAbTehXKnvKIuRUdDbtlSotOgt(eIoNfPi1Q7M7AtEw6WUs2MYnN6hBxbnKdQLN7vcNM(MamSb8JcUeRI3CLncwttp7nbyyZfnRB(SyQvWzgbRii0WuRNn(savPf0s8u)y7ki0fmn67usPn5nP0AkNseEjrWf8(iaM2snmv3J3py9mDSNlYzXrju(KTBNOfl(U7JrzSSPC66lkBqqOHPwpB8LaQslOLytQShzQho0fmToLuAtEttQShzQhoccnm16zJVeqvAbTeHVSjv2HUGPblqO2WoCfQHoAqAYii0WuRNn(savPf0suDVexsDQ1HUGPz5OY7JHDW1JnPYE2CxBYZSBN(oLuAtEtkTMYPeHxseCbVpcG2TdlqO2WoCfQPxjiz72BcWWgWpk4sSkEZv2qoOwEUxIYM003PKsBYBSURSCkr4LeBsL9it9WttFNskTjVjLwt5uIWlj(C(E4Xg5Apii0WuRNn(savPf0smiw3CmpKQNdDbtZYrL3hd7GRhBsL9S5U2KNz3o9DkP0M8MuAnLtjcVKi4cEFeaTBhwGqTHD4kutVsqY2KM(oLuAtEJ1DLLtjcVKi4hnn9DkP0M8gR7klNseEjXMuzpYup8003PKsBYBsP1uoLi8sIpNVhESrU2dccnm16zJVeqvAbTep1p2UccDbtBu59X0KLZIWceQn31M8S0eTyX3DFmkJLnLtxyxjBt5ii0WuRNn(savPf0sKDW1ZXwnh6a1b5JJsO8jtRp0fmnIGF4Lq5MMaXlNsm1k4S0S3eGHnnbIxoLyQvWzgYb1YZ9csrqOHPwpB8LaQslOLi7GRNJTAoccnm16zJVeqvAbTeHVmseYIHUGPr)OY7JbCbVpcGM7AtEwAIwS47UpgWT7G3ht50feRekp377NC6rL3hd7GRhBsL9S5U2KNHGqdtTE24lbuLwqlr4lBsLDOlyAGB3bVpgwLh1dNU(IYU9MamSzfM4chjQt5gbRii0WuRNn(savPf0se(Yirilg6cMg42DW7JHv5r9WPRVOSB3YMamSzfM4chjQt5gbRPPFu59XaUG3hbqZDTjpZgeeAyQ1ZgFjGQ0cAj2DNYHfKrYhY1b6cMg42DW7JHv5r9WPRVOqqOHPwpB8LaQslOL4iMSPIuKA1DOlyAJkVpg2bxp2Kk7zZDTjpdd0DsUwhtvsjNuY9tQFcWaPuIxoLmgWwl6b5OQ3rLOpKhXrCOeFeVaTUKbXHxcIBBFjGQ02io5IUcf5mepVGhXvHzb15mepiwDkpBqqyRk)iEFifYJ4qI17ozodXTnrWp8sOCdKX2i(SiUTjc(HxcLBGmM7AtEMTrCl7lA2yqqGGWwl6b5OQ3rLOpKhXrCOeFeVaTUKbXHxcIBB2Hvb5yBeNCrxHICgINxWJ4QWSG6CgIheRoLNniiSvLFepbqEehsSE3jZziUTjc(HxcLBGm2gXNfXTnrWp8sOCdKXCxBYZSnIRdIdzl60wH4w2x0SXGGWwv(rCifYJ4qI17ozodXTnrWp8sOCdKX2i(SiUTjc(HxcLBGmM7AtEMTrCDqCiBrN2ke3Y(IMngeeiiS1IEqoQ6Duj6d5rCehkXhXlqRlzqC4LG42oSRKTPCBJ4Kl6kuKZq88cEexfMfuNZq8Gy1P8SbbHTQ8J49H8ioKy9UtMZqCBh2U7QpgiJ5U2KNzBeFwe32HT7U6JbYyBe3Y(IMngee2QYpINeKhXHeR3DYCgIB7W2Dx9Xazm31M8mBJ4ZI42oSD3vFmqgBJ4w2x0SXGGabHTw0dYrvVJkrFipIJ4qj(iEbADjdIdVee32SdUEfSnItUORqrodXZl4rCvywqDodXdIvNYZgee2QYpI3pjipIdjwV7K5me32eb)WlHYnqgBJ4ZI42Mi4hEjuUbYyURn5z2gXTSVOzJbbbcIEhO1LmNH4jmIRHPwhXLvEYgeeyazLNmgkmGVeqvIHctvFmuyG7AtEgwemqGuZjLIbgvEFmGl49ra0CxBYZq80iEtag2yLCRk5mdBt5iEAeFkWJ40H49XaAyQ1XaD3PCybzK8HCDWdMQKWqHbURn5zyrWabsnNukgWseVtjL2K3KsRPCkr4LebxW7JaiIB3oIpQ8(ye82k4SyqSUzZDTjpdXtJ4nbyyJG3wbNfdI1nBeSI42G4PrClr8GyLq5zeNgINeIB3oIBjIt0IfF39XaUDh8(ykhXPdX7NmINgXjAXIV7(yuglBkhXPdX7NmIBdIBdgqdtToga(YirilgpyQsagkmWDTjpdlcgiqQ5KsXaAyQUhVFW6zeNoeN9CrolokHYNmIB3oIt0IfF39XOmw2uoIthINGKXaAyQ1XaWxgBkHOuoEWubPyOWa31M8mSiyGaPMtkfd0PKsBYBAsL9it9WXaAyQ1XaSRJ4yo1Vv8GPsuyOWaAyQ1Xafi4k1PwpQcefdCxBYZWIGhmvjmgkmWDTjpdlcgiqQ5KsXa0J4DkP0M8MuAnLtjcVKi4cEFear80iULiUgMQ7X7hSEgXPdXzpxKZIJsO8jJ42TJ4eTyX3DFmkJLnLJ40H49tgXTbdOHPwhdqrQv3JZbT(8GhmvqsmuyG7AtEgwemqGuZjLIbcRZeQXKpHOZzrksT6U5U2KNH4Pr8WUs2MYnN6hBxbnKdQLNr8EH4jmINgXPhXBcWWgWpk4sSkEZv2iyfXtJ40J4S3eGHnx0SU5ZIPwbNzeSIb0WuRJbgXKnvKIuRUJhmvjumuyG7AtEgwemqGuZjLIbOhX7usPn5nP0AkNseEjrWf8(iaI4PrClrCnmv3J3py9mIthIZEUiNfhLq5tgXTBhXjAXIV7(yuglBkhXPdX7lke3gmGgMADmWP(X2vq8GPYwedfg4U2KNHfbdei1CsPyGoLuAtEttQShzQhogqdtTogOjv2Jm1dhpyQ6NmgkmWDTjpdlcgiqQ5KsXaWceQnSdxHAqC6OH4qAYyanm16ya4lBsLD8GPQFFmuyG7AtEgwemqGuZjLIbSeXhvEFmSdUESjv2ZM7AtEgIB3oItpI3PKsBYBsP1uoLi8sIGl49raeXTBhXHfiuByhUc1G49cXtqYiUD7iEtag2a(rbxIvXBUYgYb1YZiEVqCrH42G4PrC6r8oLuAtEJ1DLLtjcVKytQShzQhoINgXPhX7usPn5nP0AkNseEjXNZ3dp2ix7bdOHPwhdOUxIlPo164btv)KWqHbURn5zyrWabsnNukgWseFu59XWo46XMuzpBURn5ziUD7io9iENskTjVjLwt5uIWljcUG3hbqe3UDehwGqTHD4kudI3lepbjJ42G4PrC6r8oLuAtEJ1DLLtjcVKi4hfXtJ40J4DkP0M8gR7klNseEjXMuzpYupCepnItpI3PKsBYBsP1uoLi8sIpNVhESrU2dgqdtTogiiw3CmpKQNJhmv9tagkmWDTjpdlcgiqQ5KsXaJkVpMMSCwewGqT5U2KNH4PrCIwS47UpgLXYMYrC6qCnm16XWUs2MYXaAyQ1XaN6hBxbXdMQ(qkgkmWDTjpdlcgqdtTogGDW1ZXwnhdei1CsPyaIGF4Lq5MMaXlNsm1k4mZDTjpdXtJ4S3eGHnnbIxoLyQvWzgYb1YZiEVqCifdeOoiFCucLpzmv9XdMQ(IcdfgqdtTogGDW1ZXwnhdCxBYZWIGhmv9tymuyG7AtEgwemqGuZjLIbOhXhvEFmGl49ra0CxBYZq80iorlw8D3hd42DW7JPCeNoepiwjuEgX79iE)Kr80i(OY7JHDW1JnPYE2CxBYZWaAyQ1XaWxgjczX4btvFijgkmWDTjpdlcgiqQ5KsXaGB3bVpgwLh1dhXPdX7lke3UDeVjadBwHjUWrI6uUrWkgqdtToga(YMuzhpyQ6NqXqHbURn5zyrWabsnNukgaC7o49XWQ8OE4ioDiEFrH42TJ4wI4nbyyZkmXfosuNYncwr80io9i(OY7JbCbVpcGM7AtEgIBdgqdtToga(YirilgpyQ6BlIHcdCxBYZWIGbcKAoPuma42DW7JHv5r9WrC6q8(IcdOHPwhd0DNYHfKrYhY1bpyQskzmuyG7AtEgwemqGuZjLIbgvEFmSdUESjv2ZM7AtEggqdtTogyet2urksT6oEWdgGDyvqoyOWu1hdfgqdtTogGvzIG1bdCxBYZWIGhmvjHHcdOHPwhdewpla(iOsPcyG7AtEgwe8GPkbyOWa31M8mSiyG1kgi)bdOHPwhd0PKsBYJb6us0vWJbAsL9it9WXabsnNukgGEeNi4hEjuUjiw3CCe)LqT5U2KNHbyphiL1PwhdyRRr8kmioKqSUzehkXFjudnIlIuzhXtiQhoINQgXiUTqrYdIlICxgIVeexhepbwG4wMKfiEQAeJ4qr0sI4lmId5ek3geFucLpzmqNkfogyu59XaxK8eBYDzM7AtEgIB3oINTEPmokHYNSPjv2Jm1dVpIthne3sepbiUTeXhvEFmdrlzCHJeHYn31M8me3g8GPcsXqHbURn5zyrWaRvmq(dgqdtTogOtjL2Khd0PKORGhd0Kk7rM6HJbcKAoPumarWp8sOCtqSU54i(lHAZDTjpddWEoqkRtTogWwxJyehsiw3mIdL4VeQHgXfrQSJ4je1dhXtj(oIpIpI3eGHr8kJ4SnLdnINQgXiUTqrYdIlICxgIRdINKfiUL9TaXtvJyehkIwseFHrCiNq52G4lbXtvJyehYoNVhoIlc5ApiUoioKAbIBzcSaXtvJyehkIwseFHrCiNq52G4JsO8jJb6uPWXanbyytqSU54i(lHAdBt5iUD7i(OY7JbUi5j2K7Ym31M8mepnINTEPmokHYNSPjv2Jm1dVpIthne3sepje3wI4JkVpMHOLmUWrIq5M7AtEgIBdIB3oItpIpQ8(ycuhKpUWrX6qoZCxBYZq80iE26LY4OekFYMMuzpYup8(ioD0qClrCifXTLi(OY7JziAjJlCKiuU5U2KNH42GhmvIcdfg4U2KNHfbdSwXa5pyanm16yGoLuAtEmqNkfogGEeFu59XWo46vWCxBYZq80iEyxjBt5gWpk4sSkEZv2qoOwEgX7fINWiEAehwGqTHD4kudIthINGKXaDkj6k4Xaw3vwoLi8sIGFu8GPkHXqHbURn5zyrWaRvmq(dgqdtTogOtjL2Khd0PsHJb6usPn5nnPYEKPE4iEAe3sehwGqnI3lehskke3wI4JkVpg4IKNytUlZCxBYZq8EpINuYiUnyGoLeDf8yaR7klNseEjXMuzpYupC8GPcsIHcdCxBYZWIGbwRyG8hmGgMADmqNskTjpgOtLchdmQ8(yyhC9kyURn5ziEAeNEeFu59X0KLZIWceQn31M8mepnIh2vY2uU5u)y7kOHCqT8mI3le3seNsGzavrdX79iEsiUniEAehwGqTHD4kudIthINuYyGoLeDf8yaR7klNseEjXt9JTRG4btvcfdfg4U2KNHfbdSwXa5pyanm16yGoLuAtEmqNkfogyu59X8C(E4Xg5ApM7AtEgINgXPhX7usPn5nw3vwoLi8sInPYEKPE4iEAeNEeVtjL2K3yDxz5uIWljc(rr80iEyxjBt5MNZ3dp2ix7Xiyfd0PKORGhdKsRPCkr4LeFoFp8yJCTh8GPYwedfg4U2KNHfbdSwXa5pyanm16yGoLuAtEmqNkfogyu59XaUG3hbqZDTjpdXtJ40J4nbyyd4cEFeancwXaDkj6k4XaP0AkNseEjrWf8(iaIhmv9tgdfg4U2KNHfbdei1CsPyakbMHCqT8mItdXtgdOHPwhdeuPmQHPwpkR8GbKvEIUcEmqyxjBt54btv)(yOWa31M8mSiyGaPMtkfd0eGHnWxgBlytjmW7JjpAOheNgIlkepnIBjI3eGHnfi4k1PwpQce1iyfXTBhXPhXBcWWgWpk4sSkEZv2iyfXTbdOHPwhdmIjBQifPwDhpyQ6NegkmWDTjpdlcgiqQ5KsXaJkVpMNZ3dp2ix7XCxBYZq80iULiENskTjVjLwt5uIWlj(C(E4Xg5ApiUD7io7nbyyZZ57HhBKR9yeSI42Gb0WuRJbcQug1WuRhLvEWaYkprxbpg4589WJnY1EWdMQ(jadfg4U2KNHfbdei1CsPyGrL3hd7GRxbZDTjpddOHPwhdqe8OgMA9OSYdgqw5j6k4XaSdUEfWdMQ(qkgkmWDTjpdlcgqdtTogGi4rnm16rzLhmGSYt0vWJb8LaQs8Ghma7GRxbmuyQ6JHcdCxBYZWIGbcKAoPumGLi(OY7JrWBRGZIbX6Mn31M8mepnI3eGHncEBfCwmiw3SrWkIBdINgXTeXdIvcLNrCAiEsiUD7iULiorlw8D3hd42DW7JPCeNoeVFYiEAeNOfl(U7JrzSSPCeNoeVFYiUniUnyanm16ya4lJeHSy8GPkjmuyG7AtEgwemqGuZjLIb6usPn5nnPYEKPE4yanm16ya21rCmN63kEWuLamuyG7AtEgwemqGuZjLIb0WuDpE)G1ZioDio75ICwCucLpze3UDeNOfl(U7JrzSSPCeNoeVFYyanm16yaksT6ECoO1Nh8GPcsXqHbURn5zyrWabsnNukgiSotOgt(eIoNfPi1Q7M7AtEgINgXd7kzBk3CQFSDf0qoOwEgX7fINWiEAeNEeVjadBa)OGlXQ4nxzJGvepnItpIZEtag2CrZ6MplMAfCMrWkgqdtTogyet2urksT6oEWujkmuyG7AtEgwemqGuZjLIbiAXIV7(yuglBeSI42TJ4eTyX3DFmkJLnLJ40H4jjkmGgMADmWP(X2vq8GPkHXqHbURn5zyrWabsnNukgOtjL2K30Kk7rM6HJ4PrC6r8WUs2MYnGFuWLyv8MRSHCLrnINgXTeXd7kzBk3CQFSDf0qoOwEgXPdXffIB3oIBjIt0IfF39XOmw2uoIthIRHPwpg2vY2uoINgXjAXIV7(yuglBkhX7fINKOqCBqCBWaAyQ1XanPYEKPE44btfKedfgqdtTogOabxPo16rvGOyG7AtEgwe8GPkHIHcdCxBYZWIGbcKAoPuma9iENskTjVX6UYYPeHxsSjv2Jm1dhdOHPwhdOUxIlPo164btLTigkmWDTjpdlcgiqQ5KsXaWceQnSdxHAqC6OH4qAYyanm16ya4lBsLD8GPQFYyOWa31M8mSiyGaPMtkfdqpI3PKsBYBSURSCkr4LeBsL9it9Wr80io9iENskTjVX6UYYPeHxs8u)y7kigqdtTogiiw3CmpKQNJhmv97JHcdCxBYZWIGbcKAoPumWOY7JHDW1JnPYE2CxBYZq80io9iEyxjBt5Mt9JTRGgYvg1iEAe3sepiwjuEgXPH4jH42TJ4wI4eTyX3DFmGB3bVpMYrC6q8(jJ4PrCIwS47UpgLXYMYrC6q8(jJ42G42Gb0WuRJbGVmseYIXdMQ(jHHcdCxBYZWIGb0WuRJbyhC9CSvZXabsnNukgGi4hEjuUPjq8YPetTcoZCxBYZq80io7nbyyttG4LtjMAfCMHCqT8mI3lehsXabQdYhhLq5tgtvF8GPQFcWqHb0WuRJbyhC9CSvZXa31M8mSi4btvFifdfg4U2KNHfbdei1CsPyGMamSzfM4chjQt5gbRyanm16yGrmztfPi1Q74btvFrHHcdCxBYZWIGbcKAoPuma42DW7JHv5r9WrC6q8(IcXTBhXBcWWMvyIlCKOoLBeSIb0WuRJbGVmseYIXdMQ(jmgkmWDTjpdlcgiqQ5KsXaGB3bVpgwLh1dhXPdX7lkmGgMADmq3DkhwqgjFixh8GPQpKedfg4U2KNHfbdei1CsPyGrL3hd7GRhBsL9S5U2KNHb0WuRJbgXKnvKIuRUJh8GbSsEybB6GHctvFmuyanm16yG2oJ8SiSuP(SuLtjoROvog4U2KNHfbp4bde2vY2uogkmv9XqHbURn5zyrWabsnNukgGEe3seFu59XWo46vWCxBYZqC72r8oLuAtEJ1DLLtjcVKi4hfXTbXtJ4HDLSnLBo1p2UcAihulpJ40H4jLmINgXTeXPhXdB3D1ht39rm1ee3UDeNEeNTJjxoSGm2iQZmtf6PCkiUniUD7ioCrr8ejhulpJ49cXtsuyanm16yaWpk4sSkEZvgpyQscdfg4U2KNHfbdei1CsPyGrL3hd7GRxbZDTjpdXtJ4wI4HDLSnLBo1p2UcAihulpJ40H4jLmINgXTeXPhX7usPn5nnPYEKPE4iUD7iEyxjBt5MMuzpYupCd5GA5zeNoeNsGzavrdXTbXTbXtJ4wI40J4HT7U6JP7(iMAcIB3oItpIZ2XKlhwqgBe1zMPc9uofe3gmGgMADma4hfCjwfV5kJhmvjadfg4U2KNHfbdei1CsPya6rC2oMC5WcYyJOoZmvONYPGb0WuRJbYLdliJnI6m8GPcsXqHbURn5zyrWabsnNukgGEeFu59XWo46vWCxBYZq80io9iENskTjVjLwt5uIWljcUG3hbqe3UDeVjadBGfi1kKJuurh3iyfdOHPwhdmIFuSGp4btLOWqHb0WuRJbGxg7K4SXr8JWsf8yG7AtEgwe8GPkHXqHbURn5zyrWabsnNukgWsexdt1949dwpJ40H4SNlYzXrju(KrC72rCIwS47UpgLXYMYrC6q8eKmIBdgqdtTog4sQZL6r2dKF8GPcsIHcdCxBYZWIGbcKAoPumqtag2a(rbxIvXBUYgYb1YZioDiEsIcXTBhXHlkINi5GA5zeVxiEcNmgqdtTogW6o164btvcfdfg4U2KNHfbdOHPwhdiKFSMdMXaSNdKY6uRJbsihwfKdIdRsztd9G4WlbXfYAtEeVMdMnyGaPMtkfd0eGHnGFuWLyv8MRSrWkEWdg4589WJnY1EWqHPQpgkmWDTjpdlcgiqQ5KsXaWceQrC6OH4j0Kr80iULiEyxjBt5MMuzpYupCd5kJAe3UDeNEeVtjL2K30Kk7rM6HJ42Gb0WuRJbEoFp8yJCTh8GPkjmuyG7AtEgwemqGuZjLIb6usPn5nnPYEKPE4iEAeN9MamS5589WJnY1EmcwXaAyQ1XaSRJ4yo1Vv8GPkbyOWa31M8mSiyGaPMtkfd0PKsBYBAsL9it9Wr80io7nbyyZZ57HhBKR9yeSIb0WuRJbAsL9it9WXdMkifdfg4U2KNHfbdei1CsPya2BcWWMNZ3dp2ix7XiyfdOHPwhdOUxIlPo164btLOWqHbURn5zyrWabsnNukgG9MamS5589WJnY1EmcwXaAyQ1XabX6MJ5Hu9C8Gh8GbuHr8sWaafiKap4bJb]] )
end
