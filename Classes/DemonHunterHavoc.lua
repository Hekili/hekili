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
            id = 337313,
            duration = 3600,
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

        potion = "potion_of_unbridled_fury",

        package = "Havoc",
    } )


    spec:RegisterSetting( "recommend_movement", true, {
        name = "Recommend Movement",
        desc = "If checked, the addon will recommend |T1247261:0|t Fel Rush / |T1348401:0|t Vengeful Retreat when it is a potential DPS gain.\n\n" ..
            "These abilities are critical for DPS when using the Momentum or Unbound Chaos talents.\n\n" ..
            "If not using Momentum or Unbound Chaos, you may want to disabled this to avoid unnecessary movement in combat.",
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


    spec:RegisterPack( "Havoc", 20201128, [[dGKyqbqieLhbsH2Kq6tGuAuueNIcAvOiOxrr1SqrDlHkk7Iu)simmkWXajlti6zcvAAGu11OizBOi6BOi04aPOZbsbRtOcnpuKUhcTpuWbrrGfsr5HGujteKkvxeKkfBeKkL(OqfPrkubojfPWkrGzsrkANiQwQqfXtbAQOqFvOcASuKs7fQ)svdMshMyXs8yQmzuDzvBgWNbLrtHoTuVwOQztYTL0Uf9BLgoICCHkQwoKNly6kUokTDq8DHY4PivNhbTEqQy(GQ9J0yOWmIb5YCm5rAqKgafurcn1qXKgePPIedoes6yqsIlEb2XGPupgmoqGSomijHq1kCmJyWWYIChdc2vwLm9MqxibyWGf2wnMgjUGb5YCm5rAqKgafurcn1qXKgezCzIyWaP7WKBkMitedAS58N4cgK)GddcnsTq3FDtQnoGnNJO24abY6OeansTKVqETCe1gj0KzQnsdI0amij0c0QJbHgPwO7VUj1ghWMZruBCGazDucGgPwYxiVwoIAJeAYm1gPbrAaLakbqJul0nM(DSZ5u7HCeHu701tTJXtTIBwe12bQvGiTskQRPeiUP3mqK3belPHsG4MEZG5eJWTzGTEFvG1okbIB6ndMtmcicQLI6mNs9elkHFpxs3zgIOypXruphnqJcJVO2LRFkf15WHhiDLYpcc2NGUOe(9CjDhkgiAsCJZmze1ZrpiPv(fWJy7u)ukQZnVWcaORFK6IizCdDqZsYqdHdhXMhyrWU2zu2GFm(fry0claG2zu2GFm(frOMVXskbIB6ndMtmcicQLI6mNs9ejTRQtyEGf5RFeMHik2tKSruphn)1nBN(PuuNh1TRIVXsD9JuxejJBOdA0RsNbMYKrbyreQ5hOD9WqCnGsG4MEZG5eJaIGAPOoZPuprs7Q6eMhyr(Is43ZL0DMHik2teIGAPOUUOe(9CjDpQjaSiczkt0uXzJOEoAGgfgFrTlx)ukQZzcJ0adPeiUP3myoXiGiOwkQZCk1tK0UQoH5bwK)eEF5sLziII9ehr9C08x3SD6NsrDEuYgr9C0fvNCpalIq9tPOopQBxfFJL6t49Llvn6vPZatnbMJRRIPZegPHrbyreQ5hOD9WqKgqjqCtVzWCIrarqTuuN5uQNymPNoH5bwK)HWt39f0L4zgIOypXruph9dHNU7lOlXRFkf15rjdIGAPOUM0UQoH5bwKVOe(9CjDpkzqeulf11K2v1jmpWI81psu3Uk(gl1peE6UVGUeVMLeLaXn9MbZjgbeb1srDMtPEIXKE6eMhyr(6wFoSvMHik2tCe1Zrx36ZHTQFkf15rjRWcaORB95Ww1SKOeiUP3myoXiCIs5f30B6vDyyoL6j62vX3yjZnaryoUg9Q0zGObuce30BgmNyeJr0gZdtjnKZCdqSWcaObUYx2Arq86ZrhgXfprtf1KclaGUR1vjtVPxyrIMLeC4Kvyba01psDrKmUHoOzjziLaXn9MbZjgHtukV4MEtVQddZPupXhcpD3xqxIN5gG4iQNJ(HWt39f0L41pLI68OMarqTuuxht6PtyEGf5Fi80DFbDjE4W5VWcaOFi80DFbDjEnljdPeiUP3myoXiqSPxCtVPx1HH5uQNi)1nBhZnaXruphn)1nBN(PuuNtjqCtVzWCIrGytV4MEtVQddZPupXCrvrrjGsG4MEZG2TRIVXsI1psDrKmUHoWCdqKmtgr9C08x3SD6NsrDoC4qeulf11K2v1jmpWI81pIHrnHm3c5PKJgYZXiHi9tPOohoCY47OdDcWQ8fKKC90U47eMHWHd0WmoE0RsNbMgPPOeiUP3mOD7Q4BS0CIru)i1frY4g6aZnaXruphn)1nBN(PuuNh1e3Uk(gl1NW7lxQA0RsNbgI0GOMqgeb1srDDrj875s6oC4UDv8nwQlkHFpxs31OxLodmaZX1vX0n0WOMqMBH8uYrd55yKqK(PuuNdhoz8D0Hobyv(cssUEAx8DcZqkbIB6ndA3Uk(glnNyeHobyv(cssoZnarY47OdDcWQ8fKKC90U47egLaXn9MbTBxfFJLMtmIX49gzZH5gGizJOEoA(RB2o9tPOopkzqeulf11XKE6eMhyr(6wFoSv4WlSaaAawuVSbpmb6CnljkbIB6ndA3Uk(glnNyealNFKFw)y8EaLupLaXn9MbTBxfFJLMtmIRim0s653H(PeiUP3mOD7Q4BS0CIrqANEtMBaIfwaaD9JuxejJBOdA0RsNbgI0uWHd0WmoE0RsNbMYKgqjqCtVzq72vX3yP5eJGnCFpVYCk1teMOUtuQJc(YUjZnarYgr9C0ax5lccjWU(PuuNdhUBxfFJLAGR8fbHeyxJUWjKsG4MEZG2TRIVXsZjgbB4(EEL5daC34tPEIocDQDqB2oFrjHH5gGyHfaqx)i1frY4g6GMLu0claGU(6Ii0VaEfRR5Eo6snO5BSmQjKbrqTuuxxuc)EUKUdhozUDv8nwQlkHFpxs31OlCcnKsG4MEZG2TRIVXsZjgbB4(EEL5uQNOemcrYh8ib6SiVBrII5gGi)fwaansGolY7wKO88xyba08nwchUj8xyba0Un5SUPHCFNX75VWcaOzjbhEHfaqx)i1frY4g6Gg9Q0zGHinWWOJGG9rB8IAmQj5gMgxOGdhOHzC8OxLodmnsdOeiUP3mOD7Q4BS0CIrWgUVNxzoL6jkqNGrbjbpWMJFb8K2yhXCdq0TRIVXsD9JuxejJBOdA0RsNbMcLbWH72vX3yPU(rQlIKXn0bn6vPZadmPbucGgPwO7hqyvd1cikvrCXtTalIAzdsrDQTNxdAkbIB6ndA3Uk(glnNyeSH7751aZnaXclaGU(rQlIKXn0bnljkbIB6ndA3Uk(glnNyeorP8IB6n9QommNs9eFi809aLakbIB6ndA(RB2oIax5rSbJm3aenze1ZrZMLLn5ENrzd6NsrDE0claGMnllBY9oJYg0SKmmQjoJcc2deJeoCtqsZ9hYZrxxiV(C0DYaugefjn3FiphTW5bDNmaLbgAiLaXn9Mbn)1nBN5eJGFzm6dX(jXCdqeIGAPOUUOe(9CjDNsG4MEZGM)6MTZCIratjnK7Nxj9WWCdquCtd5(NV2pWa)HgDUFeeSpb4WrsZ9hYZrlCEq3jdqzaLaXn9Mbn)1nBN5eJymI2yEykPHCMBaIUn5S9OdhHK5CpmL0qU(PuuNh1TRIVXs9j8(YLQg9Q0zGPmzuYkSaa66hPUisg3qh0SKIsg)fwaa9nDsB4CFSLn5Awsuce30Bg08x3SDMtmIt49LlvMBaIiP5(d55OfopOzjbhosAU)qEoAHZd6ozistrjqCtVzqZFDZ2zoXikkHFpxs3zUbicrqTuuxxuc)EUKUhLm3Uk(gl11psDrKmUHoOrx4eg1e3Uk(gl1NW7lxQA0RsNbgmfC4MGKM7pKNJw48GUtgC7Q4BSmksAU)qEoAHZd6ozAKMYqdPeiUP3mO5VUz7mNyeDTUkz6n9clsOeiUP3mO5VUz7mNyesMTXwjtVjZnarYGiOwkQRjTRQtyEGf5lkHFpxs3PeiUP3mO5VUz7mNyeaxvuc)m3aebyreQ5hOD9WarO3akbIB6ndA(RB2oZjgHZOSbFyqD8N5gGizqeulf11K2v1jmpWI8fLWVNlP7rjdIGAPOUM0UQoH5bwK)eEF5sLsG4MEZGM)6MTZCIraCLhXgmYCdqCe1ZrZFDtFrj8h0pLI68OK52vX3yP(eEF5svJUWjmQjoJcc2deJeoCtqsZ9hYZrxxiV(C0DYaugefjn3FiphTW5bDNmaLbgAiLaXn9Mbn)1nBN5eJG)6MbFPNZSJqN6(rqW(eicfZnareBEGfb76clk7eMp2YM8O8xyba0fwu2jmFSLn5A0RsNbMc9uce30Bg08x3SDMtmc(RBg8LEoLaXn9Mbn)1nBN5eJymI2yEykPHCMBaIfwaa9Yo(fWJKe21SKOeiUP3mO5VUz7mNyeax5rSbJm3aeRlKxFoAEhgjDNbOmfC4fwaa9Yo(fWJKe21SKOeiUP3mO5VUz7mNyeqEc7aSkp6d6YWCdqSUqE95O5DyK0DgGYuuce30Bg08x3SDMtmIXiAJ5HPKgYzUbioI65O5VUPVOe(d6NsrDoLakbIB6nd6hcpD3xqxIN4dHNU7lOlXZCdqeGfrideHMge1e3Uk(gl1fLWVNlP7A0foHWHtgeb1srDDrj875s6UHuce30Bg0peE6UVGUeV5eJGFzm6dX(jXCdqeIGAPOUUOe(9CjDpk)fwaa9dHNU7lOlXRzjrjqCtVzq)q4P7(c6s8MtmIIs43ZL0DMBaIqeulf11fLWVNlP7r5VWcaOFi80DFbDjEnljkbIB6nd6hcpD3xqxI3CIriz2gBLm9Mm3ae5VWcaOFi80DFbDjEnljkbIB6nd6hcpD3xqxI3CIr4mkBWhguh)zUbiYFHfaq)q4P7(c6s8AwsucOeiUP3mOFi809aricQLI6mNs9ebUYxeesGDFGW0XCdqCe1ZrdCLViiKa76NsrDoZqef7j62vX3yPg4kFrqib21OlCcJAIjMq2iQNJM)6MTt)ukQZHdVWcaORFK6IizCdDqZsYWOKbrqTuuxht6PtyEGf5RB95WwJIKM7pKNJw48GUtgIRbgchU4MgY9pFTFGb(dn6C)iiyFcgsjqCtVzq)q4P7bZjgHBt3ZbjZ5EaLupZnartiJVJ2TP75GK5CpGsQ3xyrPEAx8DclkzIB6n1UnDphKmN7bus96o9aQgMXboCawLYJUZOGGD)01ZuyoUUkMUHucGgPwMGzEL0qTZsTbcth1gRhJul0TxrTMjiKa7u7IOwMGf6gQTbO2EO2yTsrTLtTSHZP2y9yStQDmEQnVPpul0BkQnC3M8aZu7ogpkwho1Ygo1YzrDcJAZfvff1wyrHHA5svGDnLaXn9Mb9dHNUhmNyef1UC)c4hJ3)8vczUbiAczJOEoAGR8fbHeyx)ukQZHd3TRIVXsnWv(IGqcSRrVkDgya6nLHrjdIGAPOUoM0tNW8alYx36ZHTg1etiBe1ZrZFDZ2PFkf15WHxyba01psDrKmUHoOzjfLm3Uk(gl1fLWVNlP7A0foHgchoqdZ44rVkDgykrOmWqkbIB6nd6hcpDpyoXikQD5(fWpgV)5ReYCdqCe1ZrdCLViiKa76NsrDEuicQLI6AGR8fbHey3himDuce30Bg0peE6EWCIraJvq8ws)c4fOZr7yK5gGOjfwaaD9JuxejJBOdAwsrD7Q4BSux)i1frY4g6GgDHtOHWHxyba01psDrKmUHoOrVkDgyistbhoqdZ44rVkDgykX4AaLaXn9Mb9dHNUhmNyeaRJnCUxGoh1Z9LlvMBaIbsxP8JGG9jOlkHFpxs3HIbIrchosAU)qEoAHZd6ozGjnGsG4MEZG(HWt3dMtmcsSOgGWoH5lkjmm3aedKUs5hbb7tqxuc)EUKUdfdeJeoCK0C)H8C0cNh0DYatAaLaXn9Mb9dHNUhmNyeJX7zZYYMCpWICN5gGyHfaqJUlE1dbpWICxZsco8claGgDx8QhcEGf5U3TS5CKomIlEMcLbuce30Bg0peE6EWCIrGAsKu33PpqsCNsG4MEZG(HWt3dMtmIylsXH8o9Oh2us3zUbiwyba01psDrKmUHoOzjbhoeb1srDnWv(IGqcS7deMokbIB6nd6hcpDpyoXiQVUic9lGxX6AUNJUudm3aebyreYuO3GOfwaaD9JuxejJBOdAwsuce30Bg0peE6EWCIrGUqQtyEaLuFGzhHo19JGG9jqekMBaIJGG9rpD9(z98(mfkTPGd3etgbb7J24f1yutYnmannao8rqW(OnErng1KCdtjgPbgg1eXnnK7F(A)arOGdFeeSp6PR3pRN3NHiHgm0q4WnzeeSp6PR3pRNKB8rAadX1GOMiUPHC)Zx7hicfC4JGG9rpD9(z98(ma9qVHgsjGsG4MEZGoxuvueH8e2byvE0h0LH5gG4iQNJUU1NdBv)ukQZJwyba0KqNKGoxZ3yz0PRNbOOeiUP3mOZfvfL5eJa4kpInyK5gGOjqeulf11XKE6eMhyr(6wFoSv4Whr9C0SzzztU3zu2G(PuuNhTWcaOzZYYMCVZOSbnljdJAIZOGG9aXiHd3eK0C)H8C01fYRphDNmaLbrrsZ9hYZrlCEq3jdqzGHgsjqCtVzqNlQkkZjgbWv(IGqcSZCdquCtd5(NV2pWa)HgDUFeeSpb4WrsZ9hYZrlCEq3jdX1akbIB6nd6CrvrzoXi4xgJ(qSFsm3aeHiOwkQRlkHFpxs3PeiUP3mOZfvfL5eJOR1vjtVPxyrcLaXn9MbDUOQOmNyeWusd5(5vspmm3aejdIGAPOUoM0tNW8alYx36ZHTg1eXnnK7F(A)ad8hA05(rqW(eGdhjn3FiphTW5bDNmaLbgsjqCtVzqNlQkkZjgXyeTX8Wusd5m3aeDBYz7rhocjZ5EykPHC9tPOopQBxfFJL6t49Llvn6vPZatzYOKvyba01psDrKmUHoOzjfLm(lSaa6B6K2W5(ylBY1SKOeiUP3mOZfvfL5eJ4eEF5sL5gGO4MgY9pFTFGbOIAcziP5(d55OfopOVP3HjahosAU)qEoAHZdAwsggLmicQLI66yspDcZdSiFDRph2kLaXn9MbDUOQOmNyefLWVNlP7m3aeHiOwkQRlkHFpxs3PeiUP3mOZfvfL5eJa4QIs4N5gGialIqn)aTRhgic9gqjqCtVzqNlQkkZjgXj8(YLkZnarYgr9C0fvNCpalIq9tPOopkzqeulf11XKE6eMhyr(hcpD3xqxIpksAU)qEoAHZd6ozWTRIVXskbIB6nd6CrvrzoXiKmBJTsMEtMBaIMmI65O5VUPVOe(d6NsrDoC4KbrqTuuxht6PtyEGf5RB95WwHdhGfrOMFG21dtJRbWHxyba01psDrKmUHoOrVkDgyQPmmkzqeulf11K2v1jmpWI8fLWVNlP7rjdIGAPOUoM0tNW8alY)q4P7(c6s8uce30Bg05IQIYCIr4mkBWhguh)zUbiAYiQNJM)6M(Is4pOFkf15WHtgeb1srDDmPNoH5bwKVU1NdBfoCaweHA(bAxpmnUgyyuYGiOwkQRjTRQtyEGf5RFKOKbrqTuuxtAxvNW8alYxuc)EUKUhLmicQLI66yspDcZdSi)dHNU7lOlXtjqCtVzqNlQkkZjgXj8(YLkZnaXruphDr1j3dWIiu)ukQZJIKM7pKNJw48GUtgC7Q4BSKsG4MEZGoxuvuMtmc(RBg8LEoZocDQ7hbb7tGium3aerS5bweSRlSOSty(ylBYJYFHfaqxyrzNW8Xw2KRrVkDgyk0tjqCtVzqNlQkkZjgb)1nd(spNsG4MEZGoxuvuMtmcGR8i2GrMBaIKnI65ORB95Ww1pLI68OiP5(d55ORlKxFo6ozWzuqWEGjekdIoI65O5VUPVOe(d6NsrDoLaXn9MbDUOQOmNyeaxvuc)m3aeRlKxFoAEhgjDNbOmfC4fwaa9Yo(fWJKe21SKOeiUP3mOZfvfL5eJa4kpInyK5gGyDH86ZrZ7WiP7maLPGd3KclaGEzh)c4rsc7AwsrjBe1Zrx36ZHTQFkf15gsjqCtVzqNlQkkZjgbKNWoaRYJ(GUmm3aeRlKxFoAEhgjDNbOmfLaXn9MbDUOQOmNyeJr0gZdtjnKZCdqCe1ZrZFDtFrj8h0pLI6CmiKJc9MyYJ0GinakOIe6XGXeu2jSagmoKjioHCtdYJtJJul1YOXtTDL0IgQfyrul0MlQkkOLArpoNTrNtTHTEQvyNTkZ5uRZOKWEqtjW0SZtTqzQ4i1cDTjKJMZPwOfXMhyrWU20cTu7Sul0IyZdSiyxBA1pLI6COLAnbkt3qnLakbXHmbXjKBAqECACKAPwgnEQTRKw0qTalIAHw(bew1aTul6X5Sn6CQnS1tTc7SvzoNADgLe2dAkbMMDEQnUXrQf6AtihnNtTqlInpWIGDTPfAP2zPwOfXMhyrWU20QFkf15ql1AcuMUHAkbucIdzcIti30G8404i1sTmA8uBxjTOHAbwe1cTUDv8nwcTul6X5Sn6CQnS1tTc7SvzoNADgLe2dAkbMMDEQfQ4i1cDTjKJMZPwO1TqEk5OnT6NsrDo0sTZsTqRBH8uYrBAHwQ1eOmDd1ucmn78uBKXrQf6AtihnNtTqRBH8uYrBA1pLI6COLANLAHw3c5PKJ20cTuRjqz6gQPeqjioKjioHCtdYJtJJul1YOXtTDL0IgQfyrul0YFDZ2bTul6X5Sn6CQnS1tTc7SvzoNADgLe2dAkbMMDEQfQiJJul01MqoAoNAHweBEGfb7Atl0sTZsTqlInpWIGDTPv)ukQZHwQ1eOmDd1ucOeyAujTO5CQLjPwXn9MuRQdtqtjadQ6WeWmIbZfvffMrm5qHzed(ukQZXMHbDOEoQfm4iQNJUU1NdBv)ukQZP2OuBHfaqtcDsc6CnFJLuBuQD66PwgOwOWGIB6nXGqEc7aSkp6d6YGhm5rIzed(ukQZXMHbDOEoQfmOjuleb1srDDmPNoH5bwKVU1NdBLAHdNAhr9C0SzzztU3zu2G(PuuNtTrP2claGMnllBY9oJYg0SKOwdP2OuRjuRZOGG9a1sKAJKAHdNAnHArsZ9hYZrxxiV(C0DsTmqTqza1gLArsZ9hYZrlCEq3j1Ya1cLbuRHuRHyqXn9MyqGR8i2Gr8GjpUygXGpLI6CSzyqhQNJAbdkUPHC)Zx7hOwgOw(dn6C)iiyFculC4ulsAU)qEoAHZd6oPwgO24AaguCtVjge4kFrqib2XdMCOhZig8PuuNJndd6q9CulyqicQLI66Is43ZL0DmO4MEtmi)Yy0hI9tcpyYnfMrmO4MEtmyxRRsMEtVWIem4tPOohBgEWKZKygXGpLI6CSzyqhQNJAbdsg1crqTuuxht6PtyEGf5RB95WwP2OuRjuR4MgY9pFTFGAzGA5p0OZ9JGG9jqTWHtTiP5(d55OfopO7KAzGAHYaQ1qmO4MEtmimL0qUFEL0ddEWKZeXmIbFkf15yZWGouph1cg0TjNThD4iKmN7HPKgY1pLI6CQnk162vX3yP(eEF5svJEv6mqTmLAzsQnk1sg1wyba01psDrKmUHoOzjrTrPwYOw(lSaa6B6K2W5(ylBY1SKWGIB6nXGJr0gZdtjnKJhm5qtmJyWNsrDo2mmOd1ZrTGbf30qU)5R9dulduluuBuQ1eQLmQfjn3FiphTW5b9n9ombQfoCQfjn3FiphTW5bnljQ1qQnk1sg1crqTuuxht6PtyEGf5RB95WwXGIB6nXGNW7lxQ4bto0aMrm4tPOohBgg0H65OwWGqeulf11fLWVNlP7yqXn9MyWIs43ZL0D8GjhkdWmIbFkf15yZWGouph1cgeGfrOMFG21d1YarQf6nadkUP3edcCvrj8Jhm5qbfMrm4tPOohBgg0H65OwWGKrTJOEo6IQtUhGfrO(PuuNtTrPwYOwicQLI66yspDcZdSi)dHNU7lOlXtTrPwK0C)H8C0cNh0DsTmqTIB6n9UDv8nwIbf30BIbpH3xUuXdMCOIeZig8PuuNJndd6q9CulyqtO2ruphn)1n9fLWFq)ukQZPw4WPwYOwicQLI66yspDcZdSiFDRph2k1cho1cWIiuZpq76HAzk1gxdOw4WP2claGU(rQlIKXn0bn6vPZa1YuQ1uuRHuBuQLmQfIGAPOUM0UQoH5bwKVOe(9CjDNAJsTKrTqeulf11XKE6eMhyr(hcpD3xqxIhdkUP3edkz2gBLm9M4btouXfZig8PuuNJndd6q9CulyqtO2ruphn)1n9fLWFq)ukQZPw4WPwYOwicQLI66yspDcZdSiFDRph2k1cho1cWIiuZpq76HAzk1gxdOwdP2Oulzuleb1srDnPDvDcZdSiF9JqTrPwYOwicQLI6As7Q6eMhyr(Is43ZL0DQnk1sg1crqTuuxht6PtyEGf5Fi80DFbDjEmO4MEtmOZOSbFyqD8hpyYHc6XmIbFkf15yZWGouph1cgCe1ZrxuDY9aSic1pLI6CQnk1IKM7pKNJw48GUtQLbQvCtVP3TRIVXsmO4MEtm4j8(YLkEWKdLPWmIbFkf15yZWGIB6nXG8x3m4l9CmOd1ZrTGbrS5bweSRlSOSty(ylBY1pLI6CQnk1YFHfaqxyrzNW8Xw2KRrVkDgOwMsTqpg0rOtD)iiyFcyYHcpyYHIjXmIbf30BIb5VUzWx65yWNsrDo2m8GjhkMiMrm4tPOohBgg0H65OwWGKrTJOEo66wFoSv9tPOoNAJsTiP5(d55ORlKxFo6oPwgOwNrbb7bQLjKAHYaQnk1oI65O5VUPVOe(d6NsrDoguCtVjge4kpInyepyYHcAIzed(ukQZXMHbDOEoQfmyDH86ZrZ7WiP7ulduluMIAHdNAlSaa6LD8lGhjjSRzjHbf30BIbbUQOe(XdMCOGgWmIbFkf15yZWGouph1cgSUqE95O5DyK0DQLbQfktrTWHtTMqTfwaa9Yo(fWJKe21SKO2Oulzu7iQNJUU1NdBv)ukQZPwdXGIB6nXGax5rSbJ4btEKgGzed(ukQZXMHbDOEoQfmyDH86ZrZ7WiP7ulduluMcdkUP3edc5jSdWQ8OpOldEWKhjuygXGpLI6CSzyqhQNJAbdoI65O5VUPVOe(d6NsrDoguCtVjgCmI2yEykPHC8Ghm4dHNUhWmIjhkmJyWNsrDo2mm4scdg(Gbf30BIbHiOwkQJbHik2JbD7Q4BSudCLViiKa7A0foHuBuQ1eQ1eQ1eQLmQDe1ZrZFDZ2PFkf15ulC4uBHfaqx)i1frY4g6GMLe1Ai1gLAjJAHiOwkQRJj90jmpWI81T(CyRuBuQfjn3FiphTW5bDNulduBCnGAnKAHdNAf30qU)5R9duldul)HgDUFeeSpbQ1qmOd1ZrTGbhr9C0ax5lccjWU(PuuNJbHiiFk1JbbUYxeesGDFGW0Hhm5rIzed(ukQZXMHbDOEoQfmOjulzulFhTBt3ZbjZ5EaLuVVWIs90U47eg1gLAjJAf30BQDB6Eoizo3dOK61D6bunmJd1cho1cWQuE0DgfeS7NUEQLPulmhxxftNAnedkUP3ed6209CqYCUhqj1Jhm5XfZig8PuuNJndd6q9CulyqtOwYO2ruphnWv(IGqcSRFkf15ulC4uRBxfFJLAGR8fbHeyxJEv6mqTmqTqVPOwdP2Oulzuleb1srDDmPNoH5bwKVU1NdBLAJsTMqTMqTKrTJOEoA(RB2o9tPOoNAHdNAlSaa66hPUisg3qh0SKO2OulzuRBxfFJL6Is43ZL0Dn6cNqQ1qQfoCQfOHzC8OxLodultjsTqza1AiguCtVjgSO2L7xa)y8(NVsiEWKd9ygXGpLI6CSzyqhQNJAbdoI65ObUYxeesGD9tPOoNAJsTqeulf11ax5lccjWUpqy6WGIB6nXGf1UC)c4hJ3)8vcXdMCtHzed(ukQZXMHbDOEoQfmOjuBHfaqx)i1frY4g6GMLe1gLAD7Q4BSux)i1frY4g6GgDHti1Ai1cho1wyba01psDrKmUHoOrVkDgOwgO2inf1cho1c0WmoE0RsNbQLPeP24AaguCtVjgegRG4TK(fWlqNJ2XiEWKZKygXGpLI6CSzyqhQNJAbdgiDLYpcc2NGUOe(9CjDhkQLbIuBKulC4ulsAU)qEoAHZd6oPwgOwM0amO4MEtmiW6ydN7fOZr9CF5sfpyYzIygXGpLI6CSzyqhQNJAbdgiDLYpcc2NGUOe(9CjDhkQLbIuBKulC4ulsAU)qEoAHZd6oPwgOwM0amO4MEtmijwudqyNW8fLeg8GjhAIzed(ukQZXMHbDOEoQfmyHfaqJUlE1dbpWICxZsIAHdNAlSaaA0DXREi4bwK7E3YMZr6WiU4PwMsTqzaguCtVjgCmEpBww2K7bwK74bto0aMrmO4MEtmiQjrsDFN(ajXDm4tPOohBgEWKdLbygXGpLI6CSzyqhQNJAbdwyba01psDrKmUHoOzjrTWHtTqeulf11ax5lccjWUpqy6WGIB6nXGXwKId5D6rpSPKUJhm5qbfMrm4tPOohBgg0H65OwWGaSicPwMsTqVbuBuQTWcaORFK6IizCdDqZscdkUP3edwFDre6xaVI11CphDPgWdMCOIeZig8PuuNJnddkUP3edIUqQtyEaLuFad6q9CulyWrqW(ONUE)SEEFQLPuluAtrTWHtTMqTMqTJGG9rB8IAmQj5gQLbQfAAa1cho1occ2hTXlQXOMKBOwMsKAJ0aQ1qQnk1Ac1kUPHC)Zx7hOwIuluulC4u7iiyF0txVFwpVp1Ya1gj0a1Ai1Ai1cho1Ac1occ2h9017N1tYn(inGAzGAJRbuBuQ1eQvCtd5(NV2pqTePwOOw4WP2rqW(ONUE)SEEFQLbQf6HEQ1qQ1qmOJqN6(rqW(eWKdfEWdgKFaHvnygXKdfMrmO4MEtmiVdiwsdg8PuuNJndpyYJeZiguCtVjg0TzGTEFvG1om4tPOohBgEWKhxmJyWNsrDo2mm4scdg(Gbf30BIbHiOwkQJbHik2Jbhr9C0ankm(IAxU(PuuNtTWHtTbsxP8JGG9jOlkHFpxs3HIAzGi1Ac1gxQnoJAnHAhr9C0dsALFb8i2o1pLI6CQ1CQTWcaORFK6IizCdDqZsIAnKAnKAHdNArS5bweSRDgLn4hJFreQFkf15uBuQTWcaODgLn4hJFreQ5BSedcrq(uQhdwuc)EUKUJhm5qpMrm4tPOohBggCjHbdFWGIB6nXGqeulf1XGqef7XGKrTJOEoA(RB2o9tPOoNAJsTUDv8nwQRFK6IizCdDqJEv6mqTmLAzsQnk1cWIiuZpq76HAzGAJRbyqicYNs9yqs7Q6eMhyr(6hbpyYnfMrm4tPOohBggCjHbdFWGIB6nXGqeulf1XGqef7XGqeulf11fLWVNlP7uBuQ1eQfGfri1YuQLjAkQnoJAhr9C0ankm(IAxU(PuuNtTmHuBKgqTgIbHiiFk1JbjTRQtyEGf5lkHFpxs3XdMCMeZig8PuuNJnddUKWGHpyqXn9MyqicQLI6yqiII9yWruphn)1nBN(PuuNtTrPwYO2ruphDr1j3dWIiu)ukQZP2OuRBxfFJL6t49Llvn6vPZa1YuQ1eQfMJRRIPtTmHuBKuRHuBuQfGfrOMFG21d1Ya1gPbyqicYNs9yqs7Q6eMhyr(t49Llv8GjNjIzed(ukQZXMHbxsyWWhmO4MEtmieb1srDmierXEm4iQNJ(HWt39f0L41pLI6CQnk1sg1crqTuuxtAxvNW8alYxuc)EUKUtTrPwYOwicQLI6As7Q6eMhyr(6hHAJsTUDv8nwQFi80DFbDjEnljmieb5tPEmymPNoH5bwK)HWt39f0L4XdMCOjMrm4tPOohBggCjHbdFWGIB6nXGqeulf1XGqef7XGJOEo66wFoSv9tPOoNAJsTKrTfwaaDDRph2QMLegeIG8PupgmM0tNW8alYx36ZHTIhm5qdygXGpLI6CSzyqhQNJAbdcZX1OxLodulrQ1amO4MEtmOtukV4MEtVQddgu1HXNs9yq3Uk(glXdMCOmaZig8PuuNJndd6q9CulyWclaGg4kFzRfbXRphDyex8ulrQ1uuBuQ1eQTWcaO7ADvY0B6fwKOzjrTWHtTKrTfwaaD9JuxejJBOdAwsuRHyqXn9MyWXiAJ5HPKgYXdMCOGcZig8PuuNJndd6q9CulyWruph9dHNU7lOlXRFkf15uBuQ1eQfIGAPOUoM0tNW8alY)q4P7(c6s8ulC4ul)fwaa9dHNU7lOlXRzjrTgIbf30BIbDIs5f30B6vDyWGQom(uQhd(q4P7(c6s84btourIzed(ukQZXMHbDOEoQfm4iQNJM)6MTt)ukQZXGIB6nXGi20lUP30R6WGbvDy8PupgK)6MTdpyYHkUygXGpLI6CSzyqXn9MyqeB6f30B6vDyWGQom(uQhdMlQkk8Ghmij0DBTidMr8Gb5VUz7WmIjhkmJyWNsrDo2mmOd1ZrTGbnHAhr9C0SzzztU3zu2G(PuuNtTrP2claGMnllBY9oJYg0SKOwdP2OuRjuRZOGG9a1sKAJKAHdNAnHArsZ9hYZrxxiV(C0DsTmqTqza1gLArsZ9hYZrlCEq3j1Ya1cLbuRHuRHyqXn9MyqGR8i2Gr8GjpsmJyWNsrDo2mmOd1ZrTGbHiOwkQRlkHFpxs3XGIB6nXG8lJrFi2pj8GjpUygXGpLI6CSzyqhQNJAbdkUPHC)Zx7hOwgOw(dn6C)iiyFculC4ulsAU)qEoAHZd6oPwgOwOmadkUP3edctjnK7Nxj9WGhm5qpMrm4tPOohBgg0H65OwWGUn5S9OdhHK5CpmL0qU(PuuNtTrPw3Uk(gl1NW7lxQA0RsNbQLPultsTrPwYO2claGU(rQlIKXn0bnljQnk1sg1YFHfaqFtN0go3hBztUMLeguCtVjgCmI2yEykPHC8Gj3uygXGpLI6CSzyqhQNJAbdIKM7pKNJw48GMLe1cho1IKM7pKNJw48GUtQLbQnstHbf30BIbpH3xUuXdMCMeZig8PuuNJndd6q9CulyqicQLI66Is43ZL0DQnk1sg162vX3yPU(rQlIKXn0bn6cNqQnk1Ac162vX3yP(eEF5svJEv6mqTmqTMIAHdNAnHArsZ9hYZrlCEq3j1Ya1kUP3072vX3yj1gLArsZ9hYZrlCEq3j1YuQnstrTgsTgIbf30BIblkHFpxs3XdMCMiMrmO4MEtmyxRRsMEtVWIem4tPOohBgEWKdnXmIbFkf15yZWGouph1cgKmQfIGAPOUM0UQoH5bwKVOe(9CjDhdkUP3edkz2gBLm9M4bto0aMrm4tPOohBgg0H65OwWGaSic18d0UEOwgisTqVbyqXn9MyqGRkkHF8GjhkdWmIbFkf15yZWGouph1cgKmQfIGAPOUM0UQoH5bwKVOe(9CjDNAJsTKrTqeulf11K2v1jmpWI8NW7lxQyqXn9MyqNrzd(WG64pEWKdfuygXGpLI6CSzyqhQNJAbdoI65O5VUPVOe(d6NsrDo1gLAjJAD7Q4BSuFcVVCPQrx4esTrPwtOwNrbb7bQLi1gj1cho1Ac1IKM7pKNJUUqE95O7KAzGAHYaQnk1IKM7pKNJw48GUtQLbQfkdOwdPwdXGIB6nXGax5rSbJ4btourIzed(ukQZXMHbf30BIb5VUzWx65yqhQNJAbdIyZdSiyxxyrzNW8Xw2KRFkf15uBuQL)claGUWIYoH5JTSjxJEv6mqTmLAHEmOJqN6(rqW(eWKdfEWKdvCXmIbf30BIb5VUzWx65yWNsrDo2m8GjhkOhZig8PuuNJndd6q9CulyWclaGEzh)c4rsc7AwsyqXn9MyWXiAJ5HPKgYXdMCOmfMrm4tPOohBgg0H65OwWG1fYRphnVdJKUtTmqTqzkQfoCQTWcaOx2XVaEKKWUMLeguCtVjge4kpInyepyYHIjXmIbFkf15yZWGouph1cgSUqE95O5DyK0DQLbQfktHbf30BIbH8e2byvE0h0LbpyYHIjIzed(ukQZXMHbDOEoQfm4iQNJM)6M(Is4pOFkf15yqXn9MyWXiAJ5HPKgYXdEWGpeE6UVGUepMrm5qHzed(ukQZXMHbDOEoQfmialIqQLbIul00aQnk1Ac162vX3yPUOe(9CjDxJUWjKAHdNAjJAHiOwkQRlkHFpxs3PwdXGIB6nXGpeE6UVGUepEWKhjMrm4tPOohBgg0H65OwWGqeulf11fLWVNlP7uBuQL)claG(HWt39f0L41SKWGIB6nXG8lJrFi2pj8GjpUygXGpLI6CSzyqhQNJAbdcrqTuuxxuc)EUKUtTrPw(lSaa6hcpD3xqxIxZscdkUP3edwuc)EUKUJhm5qpMrm4tPOohBgg0H65OwWG8xyba0peE6UVGUeVMLeguCtVjguYSn2kz6nXdMCtHzed(ukQZXMHbDOEoQfmi)fwaa9dHNU7lOlXRzjHbf30BIbDgLn4ddQJ)4bpyq3Uk(glXmIjhkmJyWNsrDo2mmOd1ZrTGbjJAnHAhr9C08x3SD6NsrDo1cho1crqTuuxtAxvNW8alYx)iuRHuBuQ1eQLmQ1TqEk5OH8CmsiIAHdNAjJA57OdDcWQ8fKKC90U47eg1Ai1cho1c0WmoE0RsNbQLPuBKMcdkUP3edw)i1frY4g6aEWKhjMrm4tPOohBgg0H65OwWGJOEoA(RB2o9tPOoNAJsTMqTUDv8nwQpH3xUu1OxLodulduBKgqTrPwtOwYOwicQLI66Is43ZL0DQfoCQ1TRIVXsDrj875s6Ug9Q0zGAzGAH546Qy6uRHuRHuBuQ1eQLmQ1TqEk5OH8CmsiIAHdNAjJA57OdDcWQ8fKKC90U47eg1AiguCtVjgS(rQlIKXn0b8GjpUygXGpLI6CSzyqhQNJAbdsg1Y3rh6eGv5lij56PDX3jmmO4MEtmyOtawLVGKKJhm5qpMrm4tPOohBgg0H65OwWGKrTJOEoA(RB2o9tPOoNAJsTKrTqeulf11XKE6eMhyr(6wFoSvQfoCQTWcaObyr9Yg8WeOZ1SKWGIB6nXGJX7nYMdEWKBkmJyqXn9MyqGLZpYpRFmEpGsQhd(ukQZXMHhm5mjMrmO4MEtm4vegAj987q)yWNsrDo2m8GjNjIzed(ukQZXMHbDOEoQfmyHfaqx)i1frY4g6Gg9Q0zGAzGAJ0uulC4ulqdZ44rVkDgOwMsTmPbyqXn9Myqs70BIhm5qtmJyWNsrDo2mmO4MEtmimrDNOuhf8LDtmOd1ZrTGbjJAhr9C0ax5lccjWU(PuuNtTWHtTUDv8nwQbUYxeesGDn6cNqmyk1JbHjQ7eL6OGVSBIhm5qdygXGpLI6CSzyqXn9MyqhHo1oOnBNVOKWGbDOEoQfmyHfaqx)i1frY4g6GMLe1gLAlSaa66RlIq)c4vSUM75Ol1GMVXsQnk1Ac1sg1crqTuuxxuc)EUKUtTWHtTKrTUDv8nwQlkHFpxs31OlCcPwdXGha4UXNs9yqhHo1oOnBNVOKWGhm5qzaMrm4tPOohBgguCtVjgucgHi5dEKaDwK3TirHbDOEoQfmi)fwaansGolY7wKO88xyba08nwsTWHtTMqT8xyba0Un5SUPHCFNX75VWcaOzjrTWHtTfwaaD9JuxejJBOdA0RsNbQLbQnsdOwdP2Ou7iiyF0gVOgJAsUHAzk1gxOOw4WPwGgMXXJEv6mqTmLAJ0amyk1JbLGris(GhjqNf5Dlsu4btouqHzed(ukQZXMHbf30BIbfOtWOGKGhyZXVaEsBSJWGouph1cg0TRIVXsD9JuxejJBOdA0RsNbQLPulugqTWHtTUDv8nwQRFK6IizCdDqJEv6mqTmqTmPbyWuQhdkqNGrbjbpWMJFb8K2yhHhm5qfjMrm4tPOohBgg0H65OwWGfwaaD9JuxejJBOdAwsyqXn9Myq2W998AapyYHkUygXGpLI6CSzyqXn9MyqNOuEXn9MEvhgmOQdJpL6XGpeE6Eap4bpyqHDmUimiyxHUWdEWya]] )
end
