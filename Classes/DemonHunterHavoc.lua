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


    spec:RegisterPack( "Havoc", 20201201, [[dGKLkbqiuKhPKsAtsHpPKIrrjCkuuRsjvLxrPQzrj6wusv1Ui5xsrggLKJPKSmPeptkQMMsQCnuGTrjv(MsQY4qbX5KIsTokPkZJsk3dH2hOQdIcswiLkpujLYerbfxujLiBujLO(iLuvgjkO0jvsPALGkZefKANislvkkXtvQPIc9vPOKglkOAVq9xQAWuCyIflQhtLjJQlRAZG8zqz0ukNwYRLsA2K62s1Uf(nWWruhxjLWYH8CrMUIRJsBxj(UuQXlffNhrSELuvnFeSFKgVcZiEZL5ysBXQwSAvlwTsTQ5my9yqZX7HeYhVjlUwfyhVdPF8MHvwao8MSqIgiCmJ4DcWIChV3vNvltbI1gsGg8oZw6zTh4mEZL5ysBXQwSAvlwTsTQ5my9AHHG3jY3HjLbR36H32ko)boJ38NC49ALAyyEheuddlBmhrnmSYcWrHBTsnmm39E(iQzLLutlw1Iv4nzeaQ0hVxRuddZ7GGAyyzJ5iQHHvwaokCRvQHH5U3ZhrnRSKAAXQwSIchfU1k1SwQzUJDoNA(YrKqnt1p1m2o1iUbGOMkrnYIuAjRVIcN4McejI8kHyjpu4e3uGizpXMCGiX2VVlWkhfoXnfis2tSPfbvswFldPFIzTWVNlH7wUiA2tCe9JrbvO04ZAaGREiz95eiKiFT2pcc2NKkRf(9CjCFf8eTO5w)wmI(XOgKuApaYJyRq9qY6ZTpZcbP6FKoar2givjflzMzMabeBCiac2voBci5hBhGiPrMfcs5SjGKFSDaIefh0oOWjUParYEInTiOsY6Bzi9tKmaORaMhcG89pILlIM9ezAe9JrXFheLt9qY6ZB4aanh0ou9pshGiBdKQKc9UurYAwxdiwejk(HkxnW3CROWjUParYEInTiOsY6Bzi9tKmaORaMhcG8zTWVNlH7wUiA2tCrqLK1xL1c)EUeU3WciwejwB9yG1)i6hJcQqPXN1aax9qY6ZxFTyfZu4e3uGizpXMweujz9TmK(jsga0vaZdbq(tY95lDlxen7joI(XO4VdIYPEiz95nyAe9JrL1vW9qSisupKS(8goaqZbTd1j5(8LUc9UurYAwaZXvDPzwFTWCdiwejk(HkxnW3Ivu4e3uGizpXMweujz9TmK(j2wQPcyEiaY)u6H7(m6sRwUiA2tCe9Jr9u6H7(m6sRQhswFEdMweujz9vKbaDfW8qaKpRf(9CjCVbtlcQKS(kYaGUcyEiaY3)inCaGMdAhQNspC3NrxAvXsMcN4Mcej7j20IGkjRVLH0pX2snvaZdbq(oO)yy7wUiA2tCe9Jr1b9hdBx9qY6ZBWuMfcs1b9hdBxXsMcN4Mcej7j2Kt0AV4MceEDLgldPFIoaqZbTdlliIWCCf6DPIerROWjUParYEInn2qG2EyAPwULfeXmleKc6AFg0ZcI3FmQ0iUwjYGgwKzHGuvVd0YuGWlSirXsMabMYSqqQ(hPdqKTbsvsXsMzkCIBkqKSNytorR9IBkq41vASmK(j(u6H7(m6sRwwqehr)yupLE4UpJU0Q6HK1N3WIfbvswFvBPMkG5Hai)tPhU7ZOlTsGa)zwii1tPhU7ZOlTQyjZmfoXnfis2tSjeB4f3uGWRR0yzi9tK)oikNLfeXr0pgf)Dquo1djRpNcN4Mcej7j2eIn8IBkq41vASmK(jgaux0u4OWjUPars5aanh0oi2)iDaISnqQswwqezYIr0pgf)Dquo1djRpNaHfbvswFfzaqxbmpea57FeMB4aanh0ouNK7Zx6k07sfj4BXQgwWKdS8qIrT8ySrcs9qY6ZjqGjoyuPkGy1(mscUAkxRvaJzceGky2gp6DPIK1AHbu4e3uGiPCaGMdAh2tSP(hPdqKTbsvYYcI4i6hJI)oikN6HK1N3WchaO5G2H6KCF(sxHExQibFlw1WcMweujz9vzTWVNlH7ei4aanh0ouzTWVNlH7k07sfj4H54QU0mmZCdlyYbwEiXOwEm2ibPEiz95eiWehmQufqSAFgjbxnLR1kGXmfoXnfiskhaO5G2H9eBkvbeR2NrsWTSGiYehmQufqSAFgjbxnLR1kGrHtCtbIKYbaAoODypXMgB3BJnglliImnI(XO4VdIYPEiz95nyArqLK1x1wQPcyEiaY3b9hdBNaHmleKcIfva2KhMS(VILmfoXnfiskhaO5G2H9eBccW5h5hGFSDpKw6NcN4McejLda0Cq7WEInDnjPscp)o0VLferle3ul3)496j45pvOZ9JGG9jrGaskU)lpgLW5jvfW3CRyMcN4McejLda0Cq7WEInrgmfiSSGiMzHGu9pshGiBdKQKc9Uurc(wyabcqfmBJh9UurYAwNvu4wRuddZHew9qnqIwNfxRudearnSjjRp1uZ7jffoXnfiskhaO5G2H9eBInDFnVNSSGiMzHGu9pshGiBdKQKILmfoXnfiskhaO5G2H9eBYjATxCtbcVUsJLH0pXNspCprHJcN4Mcejf)DquoIqx7rSjBwwqeTye9JrXgzaBW9oBciPEiz95nYSqqk2idydU3ztajflzMByHZMGG9eXwiqWcKuC)xEmQoy59hJQc4xzvdKuC)xEmkHZtQkGFLvmZmfoXnfisk(7GOC2tSj(LXMp1(NSLfeXfbvswFvwl875s4ofoXnfisk(7GOC2tSjyAPwUFEN8tJLferXn1Y9pEVEcE(tf6C)iiyFseiGKI7)YJrjCEsvb8RSIcN4Mcejf)Dquo7j20ydbA7HPLA5wwqeDGGZwJkDesMZ9W0sTC1djRpVHda0Cq7qDsUpFPRqVlvKSM11GPmleKQ)r6aezBGuLuSKBWe)zwii1BgYG05(2a2GRyjtHtCtbIKI)oikN9eB6KCF(s3YcIiskU)lpgLW5jflzceqsX9F5XOeopPQa(wyafoXnfisk(7GOC2tSPSw43ZLWDlliIlcQKS(QSw43ZLW9gm5aanh0ou9pshGiBdKQKcDHtsdlCaGMdAhQtY95lDf6DPIe8mGablqsX9F5XOeopPQaEhaO5G2rdKuC)xEmkHZtQkSwlmGzMPWjUParsXFheLZEInv9oqltbcVWIekCIBkqKu83br5SNytseLTsltbclliImTiOsY6Rida6kG5HaiFwl875s4ofoXnfisk(7GOC2tSjORZAHFlliIqSisu8dvUAGN46SIcN4Mcejf)Dquo7j2KZMas(0GQwVLferMweujz9vKbaDfW8qaKpRf(9CjCVbtlcQKS(kYaGUcyEiaYFsUpFPtHtCtbIKI)oikN9eBc6ApInzZYcI4i6hJI)oi8zTWFs9qY6ZBWKda0Cq7qDsUpFPRqx4K0WcNnbb7jITqGGfiP4(V8yuDWY7pgvfWVYQgiP4(V8yucNNuva)kRyMzkCIBkqKu83br5SNyt83brYNR5w6iXPVFeeSpjIRSSGiIyJdbqWUkZIIkG5BdydEd(ZSqqQmlkQaMVnGn4k07sfjRTokCIBkqKu83br5SNyt83brYNR5u4e3uGiP4VdIYzpXMgBiqBpmTul3YcIyMfcsbyhpaYJKa2vSKPWjUParsXFheLZEInbDThXMSzzbrSdwE)XO4vAKWD4xXaceYSqqka74bqEKeWUILmfoXnfisk(7GOC2tSPLhWoeR2J(GUmwwqe7GL3FmkELgjCh(vmGcN4Mcejf)Dquo7j20ydbA7HPLA5wwqehr)yu83bHpRf(tQhswFofokCIBkqKupLE4UpJU0kXNspC3NrxA1YcIielIe4jYqSQHfoaqZbTdvwl875s4UcDHtcbcmTiOsY6RYAHFpxc3zMcN4Mcej1tPhU7ZOlTApXM4xgB(u7FYwwqexeujz9vzTWVNlH7n4pZcbPEk9WDFgDPvflzkCIBkqKupLE4UpJU0Q9eBkRf(9CjC3YcI4IGkjRVkRf(9CjCVb)zwii1tPhU7ZOlTQyjtHtCtbIK6P0d39z0LwTNytseLTsltbclliI8NzHGupLE4UpJU0QILmfoXnfisQNspC3NrxA1EIn5SjGKpnOQ1BzbrK)mleK6P0d39z0LwvSKPWrHtCtbIK6P0d3texeujz9TmK(jcDTpliKa7(ejHZYcI4i6hJc6AFwqib2vpKS(Clxen7j6aanh0ouqx7ZccjWUcDHtsdlSWcMgr)yu83br5upKS(CceYSqqQ(hPdqKTbsvsXsM5gmTiOsY6RAl1ubmpea57G(JHT3ajf3)LhJs48KQc4BUvmtGG4MA5(hVxpbp)PcDUFeeSpjMPWjUPars9u6H7j7j2KdeUhdsMZ9qAPFlliIwWehmkhiCpgKmN7H0s)(mlkut5ATcynysCtbcLdeUhdsMZ9qAPFvfEiDbZ2qGaeRw7r3ztqWUFQ(Tgmhx1LMHzkCRvQHHAM3jpuZaOMejHJAAxJnQzT81uJDccjWo1aquddfyTe1uqutnut7sRPM8Pg205ut7ASvb1m2o1eVzgQzDmGAs3bcEYsQbm2oQDLo1WMo1WzrvaJAcaQlAQjZIsd1WLUa7kkCIBkqKupLE4EYEInL1aa3dG8JT7F8ojwwqeTGPr0pgf01(SGqcSREiz95ei4aanh0ouqx7ZccjWUc9Uurc(1XaMBW0IGkjRVQTutfW8qaKVd6pg2EdlSGPr0pgf)Dquo1djRpNaHmleKQ)r6aezBGuLuSKBWKda0Cq7qL1c)EUeURqx4KWmbcqfmBJh9UurYAexzfZu4e3uGiPEk9W9K9eBkRbaUha5hB3)4DsSSGioI(XOGU2NfesGD1djRpVXIGkjRVc6AFwqib29jschfoXnfisQNspCpzpXMGXkiEjHha5L1)rGXMLferlYSqqQ(hPdqKTbsvsXsUHda0Cq7q1)iDaISnqQsk0fojmtGqMfcs1)iDaISnqQsk07sfj4BHbeiavWSnE07sfjRrS5wrHtCtbIK6P0d3t2tSjiGJnDUxw)hvZ95lDlliIjYxR9JGG9jPYAHFpxc3xbpXwiqajf3)LhJs48KQc4ToROWjUPars9u6H7j7j2ezwubrsfW8zTKglliIjYxR9JGG9jPYAHFpxc3xbpXwiqajf3)LhJs48KQc4ToROWjUPars9u6H7j7j20y7E2idydUhcGC3YcIyMfcsHURv9tjpea5UILmbczwiif6Uw1pL8qaK7EhGnMJuPrCTATvwrHtCtbIK6P0d3t2tSjurMS((k8jYI7u4e3uGiPEk9W9K9eBQnaP5lVcp6jqiH7wwqeZSqqQ(hPdqKTbsvsXsMaHfbvswFf01(SGqcS7tKeokCIBkqKupLE4EYEIn1FhGiXdG8AwxX9C0LEYYcIielIeRToRAKzHGu9pshGiBdKQKILmfoXnfisQNspCpzpXMqxixbmpKw6pzPJeN((rqW(KiUYYcI4iiyFut1VFaEEDRTsXaceSWIrqW(OSDrp2uKDd8meRiqyeeSpkBx0Jnfz3ynITyfZnSqCtTC)J3RNiUIaHrqW(OMQF)a886W3sZMzMjqWIrqW(OMQF)a8KDJVfRGV5w1WcXn1Y9pEVEI4kcegbb7JAQ(9dWZRd)6whZmtHJcN4McejvaqDrtC5bSdXQ9OpOlJLfeXr0pgvh0FmSD1djRpVrMfcsrgDYc6Cfh0oAmv)WVIcN4McejvaqDrBpXMGU2Jyt2SSGiAXIGkjRVQTutfW8qaKVd6pg2obcJOFmk2idydU3ztaj1djRpVrMfcsXgzaBW9oBciPyjZCdlC2eeSNi2cbcwGKI7)YJr1blV)yuva)kRAGKI7)YJrjCEsvb8RSIzMPWjUParsfaux02tSjOR9zbHey3YcIO4MA5(hVxpbp)PcDUFeeSpjceqsX9F5XOeopPQa(MBffoXnfisQaG6I2EInXVm28P2)KTSGiUiOsY6RYAHFpxc3PWjUParsfaux02tSPQ3bAzkq4fwKqHtCtbIKkaOUOTNytW0sTC)8o5NglliImTiOsY6RAl1ubmpea57G(JHT3WcXn1Y9pEVEcE(tf6C)iiyFseiGKI7)YJrjCEsvb8RSIzkCIBkqKuba1fT9eBASHaT9W0sTClliIoqWzRrLocjZ5EyAPwU6HK1N3WbaAoODOoj3NV0vO3LkswZ6AWuMfcs1)iDaISnqQskwYnyI)mleK6ndzq6CFBaBWvSKPWjUParsfaux02tSPtY95lDlliImTiOsY6RAl1ubmpea57G(JHT3WcXn1Y9pEVEcE(tf6C)iiyFseiGKI7)YJrjCEsvb8RyaZu4e3uGiPcaQlA7j2uwl875s4ULfeXfbvswFvwl875s4ofoXnfisQaG6I2EInbDDwl8BzbreIfrIIFOYvd8exNvu4e3uGiPcaQlA7j2KerzR0YuGWYcIOfJOFmk(7GWN1c)j1djRpNabMweujz9vTLAQaMhcG8Dq)XW2jqaIfrIIFOYvJ1AUveiKzHGu9pshGiBdKQKc9UurYAmG5gmTiOsY6Rida6kG5HaiFwl875s4EdMweujz9vTLAQaMhcG8pLE4UpJU0kfoXnfisQaG6I2EIn5SjGKpnOQ1Bzbr0Ir0pgf)Dq4ZAH)K6HK1NtGatlcQKS(Q2snvaZdbq(oO)yy7eiaXIirXpu5QXAn3kMBW0IGkjRVImaORaMhcG89psdMweujz9vKbaDfW8qaKpRf(9CjCVbtlcQKS(Q2snvaZdbq(NspC3NrxALcN4McejvaqDrBpXMoj3NV0TSGioI(XOY6k4EiwejQhswFEdKuC)xEmkHZtQkG3baAoODqHtCtbIKkaOUOTNyt83brYNR5w6iXPVFeeSpjIRSSGiIyJdbqWUkZIIkG5BdydEd(ZSqqQmlkQaMVnGn4k07sfjRTokCIBkqKuba1fT9eBI)ois(CnNcN4McejvaqDrBpXMGU2Jyt2SSGiY0i6hJQd6pg2U6HK1N3ajf3)LhJQdwE)XOQaENnbb7P13kRAmI(XO4VdcFwl8NupKS(CkCIBkqKuba1fT9eBc66Sw43YcIyhS8(JrXR0iH7WVIbeiKzHGua2XdG8ijGDflzkCIBkqKuba1fT9eBc6ApInzZYcIyhS8(JrXR0iH7WVIbeiyrMfcsbyhpaYJKa2vSKBW0i6hJQd6pg2U6HK1NZmfoXnfisQaG6I2EInT8a2Hy1E0h0LXYcIyhS8(JrXR0iH7WVIbu4e3uGiPcaQlA7j20ydbA7HPLA5wwqehr)yu83bHpRf(tQhswFoEVCuQabM0wSQfRwTQfgcE3wqrfWs4DZkdvZcPRDsT(SEud1WOTtnvNmanudearnRjaOUOxd1G(AbBHoNAsG(PgHDaDzoNAC2Ka2tkkCm0vCQz16SEuZAdelhnNtnRbXghcGGDfdFnuZaOM1GyJdbqWUIHREiz95RHASyvZWSIchfUMvgQMfsx7KA9z9OgQHrBNAQozaAOgiaIAwd)qcREwd1G(AbBHoNAsG(PgHDaDzoNAC2Ka2tkkCm0vCQP5wpQzTbILJMZPM1GyJdbqWUIHVgQzauZAqSXHaiyxXWvpKS(81qnwSQzywrHJcxZkdvZcPRDsT(SEud1WOTtnvNmanudearnRXbaAoODSgQb91c2cDo1Ka9tnc7a6YCo14SjbSNuu4yOR4uZkRh1S2aXYrZ5uZACGLhsmkgU6HK1NVgQzauZACGLhsmkg(AOglw1mmROWXqxXPMwSEuZAdelhnNtnRXbwEiXOy4QhswF(AOMbqnRXbwEiXOy4RHASyvZWSIchfUMvgQMfsx7KA9z9OgQHrBNAQozaAOgiaIAwd)DquU1qnOVwWwOZPMeOFQryhqxMZPgNnjG9KIchdDfNAw1I1JAwBGy5O5CQzni24qaeSRy4RHAga1SgeBCiac2vmC1djRpFnuJfRAgMvu4OWT27KbO5CQX6OgXnfiOgDLMKIchERR0KWmI3ba1fnMrmPRWmI3pKS(CSD4TdvZrLG3JOFmQoO)yy7QhswFo10GAYSqqkYOtwqNR4G2b10GAMQFQbEQzfElUPabEV8a2Hy1E0h0LbpysBbZiE)qY6ZX2H3ounhvcEBb1SiOsY6RAl1ubmpea57G(JHTtneiqnJOFmk2idydU3ztaj1djRpNAAqnzwiifBKbSb37SjGKILm1Wm10GASGAC2eeSNOgIutludbcuJfudskU)lpgvhS8(Jrvb1ap1SYkQPb1GKI7)YJrjCEsvb1ap1SYkQHzQHz8wCtbc8g6ApInzdpysBoMr8(HK1NJTdVDOAoQe8wCtTC)J3RNOg4Pg(tf6C)iiyFsudbcudskU)lpgLW5jvfud8utZTcVf3uGaVHU2NfesGD8GjDDygX7hswFo2o82HQ5OsW7fbvswFvwl875s4oElUPabEZVm28P2)KXdMugGzeVf3uGaVREhOLPaHxyrcE)qY6ZX2HhmPwhMr8(HK1NJTdVDOAoQe8MjQzrqLK1x1wQPcyEiaY3b9hdBNAAqnwqnIBQL7F8E9e1ap1WFQqN7hbb7tIAiqGAqsX9F5XOeopPQGAGNAwzf1WmElUPabEdtl1Y9Z7KFAWdM01dZiE)qY6ZX2H3ounhvcE7abNTgv6iKmN7HPLA5QhswFo10GACaGMdAhQtY95lDf6DPIe1ynQX6OMgudtutMfcs1)iDaISnqQskwYutdQHjQH)mleK6ndzq6CFBaBWvSKXBXnfiW7Xgc02dtl1YXdMugcMr8(HK1NJTdVDOAoQe8MjQzrqLK1x1wQPcyEiaY3b9hdBNAAqnwqnIBQL7F8E9e1ap1WFQqN7hbb7tIAiqGAqsX9F5XOeopPQGAGNAwXaQHz8wCtbc8(KCF(shpysB2ygX7hswFo2o82HQ5OsW7fbvswFvwl875s4oElUPabEN1c)EUeUJhmPRScZiE)qY6ZX2H3ounhvcEdXIirXpu5QHAGNi1SoRWBXnfiWBORZAHF8GjD1kmJ49djRphBhE7q1Cuj4TfuZi6hJI)oi8zTWFs9qY6ZPgceOgMOMfbvswFvBPMkG5HaiFh0FmSDQHabQbIfrIIFOYvd1ynQP5wrneiqnzwiiv)J0biY2aPkPqVlvKOgRrnmGAyMAAqnmrnlcQKS(kYaGUcyEiaYN1c)EUeUtnnOgMOMfbvswFvBPMkG5Hai)tPhU7ZOlTI3IBkqG3seLTsltbc8GjDvlygX7hswFo2o82HQ5OsWBlOMr0pgf)Dq4ZAH)K6HK1NtneiqnmrnlcQKS(Q2snvaZdbq(oO)yy7udbcudelIef)qLRgQXAutZTIAyMAAqnmrnlcQKS(kYaGUcyEiaY3)iutdQHjQzrqLK1xrga0vaZdbq(Sw43ZLWDQPb1We1SiOsY6RAl1ubmpea5Fk9WDFgDPv8wCtbc82ztajFAqvRhpysx1CmJ49djRphBhE7q1Cuj49i6hJkRRG7HyrKOEiz95utdQbjf3)LhJs48KQcQbEQrCtbcVda0Cq7aVf3uGaVpj3NV0XdM0vRdZiE)qY6ZX2H3IBkqG383brYNR54TdvZrLG3i24qaeSRYSOOcy(2a2GREiz95utdQH)mleKkZIIkG5BdydUc9UurIASg1So82rItF)iiyFsysxHhmPRyaMr8wCtbc8M)ois(CnhVFiz95y7WdM0vwhMr8(HK1NJTdVDOAoQe8MjQze9Jr1b9hdBx9qY6ZPMgudskU)lpgvhS8(Jrvb1ap14SjiyprnRpQzLvutdQze9JrXFhe(Sw4pPEiz954T4Mce4n01EeBYgEWKUA9WmI3pKS(CSD4TdvZrLG3DWY7pgfVsJeUtnWtnRya1qGa1KzHGua2XdG8ijGDflz8wCtbc8g66Sw4hpysxXqWmI3pKS(CSD4TdvZrLG3DWY7pgfVsJeUtnWtnRya1qGa1yb1KzHGua2XdG8ijGDflzQPb1We1mI(XO6G(JHTREiz95udZ4T4Mce4n01EeBYgEWKUQzJzeVFiz95y7WBhQMJkbV7GL3FmkELgjCNAGNAwXa8wCtbc8E5bSdXQ9OpOldEWK2IvygX7hswFo2o82HQ5OsW7r0pgf)Dq4ZAH)K6HK1NJ3IBkqG3JneOThMwQLJh8G3pLE4EcZiM0vygX7hswFo2o8gqgVtFWBXnfiW7fbvswF8Er0ShVDaGMdAhkOR9zbHeyxHUWjHAAqnwqnwqnwqnmrnJOFmk(7GOCQhswFo1qGa1KzHGu9pshGiBdKQKILm1Wm10GAyIAweujz9vTLAQaMhcG8Dq)XW2PMgudskU)lpgLW5jvfud8utZTIAyMAiqGAe3ul3)496jQbEQH)uHo3pcc2Ne1WmE7q1Cuj49i6hJc6AFwqib2vpKS(C8Erq(q6hVHU2NfesGDFIKWHhmPTGzeVFiz95y7WBhQMJkbVTGAyIA4Gr5aH7XGK5CpKw63NzrHAkxRvaJAAqnmrnIBkqOCGW9yqYCUhsl9RQWdPly2gQHabQbIvR9O7Sjiy3pv)uJ1OgyoUQlnd1WmElUPabE7aH7XGK5CpKw6hpysBoMr8(HK1NJTdVDOAoQe82cQHjQze9JrbDTpliKa7QhswFo1qGa14aanh0ouqx7ZccjWUc9UurIAGNAwhdOgMPMgudtuZIGkjRVQTutfW8qaKVd6pg2o10GASGASGAyIAgr)yu83br5upKS(CQHabQjZcbP6FKoar2givjflzQPb1We14aanh0ouzTWVNlH7k0fojudZudbcudubZ24rVlvKOgRrKAwzf1WmElUPabEN1aa3dG8JT7F8oj4bt66WmI3pKS(CSD4TdvZrLG3JOFmkOR9zbHeyx9qY6ZPMguZIGkjRVc6AFwqib29jschElUPabEN1aa3dG8JT7F8oj4btkdWmI3pKS(CSD4TdvZrLG3wqnzwiiv)J0biY2aPkPyjtnnOghaO5G2HQ)r6aezBGuLuOlCsOgMPgceOMmleKQ)r6aezBGuLuO3Lksud8utlmGAiqGAGky2gp6DPIe1ynIutZTcVf3uGaVHXkiEjHha5L1)rGXgEWKADygX7hswFo2o82HQ5OsW7e5R1(rqW(KuzTWVNlH7ROg4jsnTqneiqniP4(V8yucNNuvqnWtnwNv4T4Mce4neWXMo3lR)JQ5(8LoEWKUEygX7hswFo2o82HQ5OsW7e5R1(rqW(KuzTWVNlH7ROg4jsnTqneiqniP4(V8yucNNuvqnWtnwNv4T4Mce4nzwubrsfW8zTKg8GjLHGzeVFiz95y7WBhQMJkbVZSqqk0DTQFk5Hai3vSKPgceOMmleKcDxR6NsEiaYDVdWgZrQ0iUwPgRrnRScVf3uGaVhB3ZgzaBW9qaK74btAZgZiElUPabEJkYK13xHprwChVFiz95y7WdM0vwHzeVFiz95y7WBhQMJkbVZSqqQ(hPdqKTbsvsXsMAiqGAweujz9vqx7ZccjWUprs4WBXnfiW72aKMV8k8ONaHeUJhmPRwHzeVFiz95y7WBhQMJkbVHyrKqnwJAwNvutdQjZcbP6FKoar2givjflz8wCtbc8U)oarIha51SUI75Ol9eEWKUQfmJ49djRphBhElUPabEJUqUcyEiT0FcVDOAoQe8EeeSpQP63papVo1ynQzLIbudbcuJfuJfuZiiyFu2UOhBkYUHAGNAyiwrneiqnJGG9rz7IESPi7gQXAePMwSIAyMAAqnwqnIBQL7F8E9e1qKAwrneiqnJGG9rnv)(b451Pg4PMwA2udZudZudbcuJfuZiiyFut1VFaEYUX3Ivud8utZTIAAqnwqnIBQL7F8E9e1qKAwrneiqnJGG9rnv)(b451Pg4PM1ToQHzQHz82rItF)iiyFsysxHh8G38djS6bZiM0vygXBXnfiWBELqSKh8(HK1NJTdpysBbZiElUPabE7arITFFxGvo8(HK1NJTdpysBoMr8(HK1NJTdVbKX70h8wCtbc8ErqLK1hVxen7X7r0pgfuHsJpRbaU6HK1NtneiqnjYxR9JGG9jPYAHFpxc3xrnWtKASGAAo1y9tnwqnJOFmQbjL2dG8i2kupKS(CQXEQjZcbP6FKoar2givjflzQHzQHzQHabQbXghcGGDLZMas(X2bisupKS(CQPb1KzHGuoBci5hBhGirXbTd8Erq(q6hVZAHFpxc3XdM01HzeVFiz95y7WBaz8o9bVf3uGaVxeujz9X7frZE8MjQze9JrXFheLt9qY6ZPMguJda0Cq7q1)iDaISnqQsk07sfjQXAuJ1rnnOgiwejk(Hkxnud8utZTcVxeKpK(XBYaGUcyEiaY3)i4btkdWmI3pKS(CSD4nGmEN(G3IBkqG3lcQKS(49IOzpEViOsY6RYAHFpxc3PMguJfudelIeQXAuZ6XaQX6NAgr)yuqfkn(Sga4QhswFo1S(OMwSIAygVxeKpK(XBYaGUcyEiaYN1c)EUeUJhmPwhMr8(HK1NJTdVbKX70h8wCtbc8ErqLK1hVxen7X7r0pgf)Dquo1djRpNAAqnmrnJOFmQSUcUhIfrI6HK1NtnnOghaO5G2H6KCF(sxHExQirnwJASGAG54QU0muZ6JAAHAyMAAqnqSisu8dvUAOg4PMwScVxeKpK(XBYaGUcyEiaYFsUpFPJhmPRhMr8(HK1NJTdVbKX70h8wCtbc8ErqLK1hVxen7X7r0pg1tPhU7ZOlTQEiz95utdQHjQzrqLK1xrga0vaZdbq(Sw43ZLWDQPb1We1SiOsY6Rida6kG5HaiF)JqnnOghaO5G2H6P0d39z0LwvSKX7fb5dPF8UTutfW8qaK)P0d39z0LwXdMugcMr8(HK1NJTdVbKX70h8wCtbc8ErqLK1hVxen7X7r0pgvh0FmSD1djRpNAAqnmrnzwiivh0FmSDflz8Erq(q6hVBl1ubmpea57G(JHTJhmPnBmJ49djRphBhE7q1Cuj4nmhxHExQirnePgRWBXnfiWBNO1EXnfi86kn4TUsJpK(XBhaO5G2bEWKUYkmJ49djRphBhE7q1Cuj4DMfcsbDTpd6zbX7pgvAexRudrQHbutdQXcQjZcbPQEhOLPaHxyrIILm1qGa1We1KzHGu9pshGiBdKQKILm1WmElUPabEp2qG2EyAPwoEWKUAfMr8(HK1NJTdVDOAoQe8Ee9Jr9u6H7(m6sRQhswFo10GASGAweujz9vTLAQaMhcG8pLE4UpJU0k1qGa1WFMfcs9u6H7(m6sRkwYudZ4T4Mce4Tt0AV4MceEDLg8wxPXhs)49tPhU7ZOlTIhmPRAbZiE)qY6ZX2H3ounhvcEpI(XO4VdIYPEiz954T4Mce4nIn8IBkq41vAWBDLgFi9J383br5WdM0vnhZiE)qY6ZX2H3IBkqG3i2WlUPaHxxPbV1vA8H0pEhaux04bp4nz0DGEwgmJ4bV5VdIYHzet6kmJ49djRphBhE7q1Cuj4TfuZi6hJInYa2G7D2eqs9qY6ZPMgutMfcsXgzaBW9oBciPyjtnmtnnOglOgNnbb7jQHi10c1qGa1yb1GKI7)YJr1blV)yuvqnWtnRSIAAqniP4(V8yucNNuvqnWtnRSIAyMAygVf3uGaVHU2Jyt2WdM0wWmI3pKS(CSD4TdvZrLG3lcQKS(QSw43ZLWD8wCtbc8MFzS5tT)jJhmPnhZiE)qY6ZX2H3ounhvcElUPwU)X71tud8ud)PcDUFeeSpjQHabQbjf3)LhJs48KQcQbEQzLv4T4Mce4nmTul3pVt(PbpysxhMr8(HK1NJTdVDOAoQe82bcoBnQ0rizo3dtl1YvpKS(CQPb14aanh0ouNK7Zx6k07sfjQXAuJ1rnnOgMOMmleKQ)r6aezBGuLuSKPMgudtud)zwii1BgYG05(2a2GRyjJ3IBkqG3JneOThMwQLJhmPmaZiE)qY6ZX2H3ounhvcEJKI7)YJrjCEsXsMAiqGAqsX9F5XOeopPQGAGNAAHb4T4Mce49j5(8LoEWKADygX7hswFo2o82HQ5OsW7fbvswFvwl875s4o10GAyIACaGMdAhQ(hPdqKTbsvsHUWjHAAqnwqnoaqZbTd1j5(8LUc9UurIAGNAya1qGa1yb1GKI7)YJrjCEsvb1ap1iUPaH3baAoODqnnOgKuC)xEmkHZtQkOgRrnTWaQHzQHz8wCtbc8oRf(9CjChpysxpmJ4T4Mce4D17aTmfi8clsW7hswFo2o8GjLHGzeVFiz95y7WBhQMJkbVzIAweujz9vKbaDfW8qaKpRf(9CjChVf3uGaVLikBLwMce4btAZgZiE)qY6ZX2H3ounhvcEdXIirXpu5QHAGNi1SoRWBXnfiWBORZAHF8GjDLvygX7hswFo2o82HQ5OsWBMOMfbvswFfzaqxbmpea5ZAHFpxc3PMgudtuZIGkjRVImaORaMhcG8NK7Zx64T4Mce4TZMas(0GQwpEWKUAfMr8(HK1NJTdVDOAoQe8Ee9JrXFhe(Sw4pPEiz95utdQHjQXbaAoODOoj3NV0vOlCsOMguJfuJZMGG9e1qKAAHAiqGASGAqsX9F5XO6GL3FmQkOg4PMvwrnnOgKuC)xEmkHZtQkOg4PMvwrnmtnmJ3IBkqG3qx7rSjB4bt6QwWmI3pKS(CSD4T4Mce4n)DqK85AoE7q1Cuj4nInoeab7QmlkQaMVnGn4QhswFo10GA4pZcbPYSOOcy(2a2GRqVlvKOgRrnRdVDK403pcc2NeM0v4bt6QMJzeVf3uGaV5VdIKpxZX7hswFo2o8GjD16WmI3pKS(CSD4TdvZrLG3zwiifGD8aipscyxXsgVf3uGaVhBiqBpmTulhpysxXamJ49djRphBhE7q1Cuj4DhS8(JrXR0iH7ud8uZkgqneiqnzwiifGD8aipscyxXsgVf3uGaVHU2Jyt2WdM0vwhMr8(HK1NJTdVDOAoQe8UdwE)XO4vAKWDQbEQzfdWBXnfiW7LhWoeR2J(GUm4bt6Q1dZiE)qY6ZX2H3ounhvcEpI(XO4VdcFwl8NupKS(C8wCtbc8ESHaT9W0sTC8Gh82baAoODGzet6kmJ49djRphBhE7q1Cuj4ntuJfuZi6hJI)oikN6HK1NtneiqnlcQKS(kYaGUcyEiaY3)iudZutdQXbaAoODOoj3NV0vO3Lksud8utlwrnnOglOgMOghy5HeJA5XyJee1qGa1We1WbJkvbeR2NrsWvt5ATcyudZudbcudubZ24rVlvKOgRrnTWa8wCtbc8U)r6aezBGuLWdM0wWmI3pKS(CSD4TdvZrLG3JOFmk(7GOCQhswFo10GASGACaGMdAhQtY95lDf6DPIe1ap10IvutdQXcQHjQzrqLK1xL1c)EUeUtneiqnoaqZbTdvwl875s4Uc9UurIAGNAG54QU0mudZudZutdQXcQHjQXbwEiXOwEm2ibrneiqnmrnCWOsvaXQ9zKeC1uUwRag1WmElUPabE3)iDaISnqQs4btAZXmI3pKS(CSD4TdvZrLG3mrnCWOsvaXQ9zKeC1uUwRagElUPabENQaIv7Zij44bt66WmI3pKS(CSD4TdvZrLG3mrnJOFmk(7GOCQhswFo10GAyIAweujz9vTLAQaMhcG8Dq)XW2PgceOMmleKcIfva2KhMS(VILmElUPabEp2U3gBm4btkdWmI3IBkqG3qao)i)a8JT7H0s)49djRphBhEWKADygX7hswFo2o82HQ5OsWBlOgXn1Y9pEVEIAGNA4pvOZ9JGG9jrneiqniP4(V8yucNNuvqnWtnn3kQHz8wCtbc8(AssLeE(DOF8GjD9WmI3pKS(CSD4TdvZrLG3zwiiv)J0biY2aPkPqVlvKOg4PMwya1qGa1avWSnE07sfjQXAuJ1zfElUPabEtgmfiWdMugcMr8(HK1NJTdVDOAoQe8oZcbP6FKoar2givjflz8wCtbc8MnDFnVNWdM0MnMr8(HK1NJTdVf3uGaVDIw7f3uGWRR0G36kn(q6hVFk9W9eEWdE)u6H7(m6sRygXKUcZiE)qY6ZX2H3ounhvcEdXIiHAGNi1WqSIAAqnwqnoaqZbTdvwl875s4UcDHtc1qGa1We1SiOsY6RYAHFpxc3PgMXBXnfiW7NspC3NrxAfpysBbZiE)qY6ZX2H3ounhvcEViOsY6RYAHFpxc3PMgud)zwii1tPhU7ZOlTQyjJ3IBkqG38lJnFQ9pz8GjT5ygX7hswFo2o82HQ5OsW7fbvswFvwl875s4o10GA4pZcbPEk9WDFgDPvflz8wCtbc8oRf(9CjChpysxhMr8(HK1NJTdVDOAoQe8M)mleK6P0d39z0LwvSKXBXnfiWBjIYwPLPabEWKYamJ49djRphBhE7q1Cuj4n)zwii1tPhU7ZOlTQyjJ3IBkqG3oBci5tdQA94bp4bVf2XgaH37QV2WdEWya]] )
end
