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

        potion = "phantom_fire",

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


    spec:RegisterPack( "Havoc", 20201207, [[dCKh7aqiuHhjfQAtsrFskKrrj5uusTkLeXROumluj3cvuQDrQFjfmmuvogKyzsj9mLKmnkL4AOISnkL03KcLXHkQ6CkjQwhQOyEkjCpeAFiOdsPuyHOQ6HukLMOsIYfPukQpQKu1ivsQCsPqLvQKAMkjs7esAPOIk9uLAQiWxrfLmwLKYEb9xHgmfhMyXI6XcMmsxw1MH4ZqQrtP60sETuIztYTLQDt1VbgoQYXrfvSCOEUitxX1r02vIVlLA8ukvNhvQ1tPuK5tj2pkdrbsaCtL5quBLVw5dLw5RX0OWhkRC(qbUhU5D4MNeArqF42L(H7vNSacWnpHBfqOqcG7eGehoCVRoPsMc42wSGmWDMSutJZHz4MkZHO2kFTYhkTYxJPrHpu48CYwH7eVhGOYPgRXGB7fLEhMHB6tb4UXZmRS3boZS6i95yMz1jlGaBDJNzwzp8E(yMPX4IzALVw5dU5HbiL6WDJNzwzVdCMz1r6ZXmZQtwab26gpZSYE498XmtJXfZ0kFTYhBnBDJNzSnB7pqoNYmF5yUzMP6Nzg7NzKWaWmtLygzrkLKvxZwlHPaEIiTsysEdBTeMc4jBi2qa4jY(JDbDfyRLWuapzdXgweCjz15YL(jMvc9rQ4HZ1IOipXru3hnsHttmRaaQ(UKvNAXsI3vQ4iy0Fs6SsOpsfpCuiKOvRIZ2Qru3h9GLsfbirmz567swDQnzseeD)J0byE2bPkPj5zT1wSGj9JaWOVoyxaP4y)am3nZKii6GDbKIJ9dWCRPG2oBTeMc4jBi2WIGljRoxU0prEaGQC0reao2)iCTikYtKJru3hn9DGxb9DjRoTzaauuqBx3)iDaMNDqQsA87s5PvyRnriXCRPhPc1q4Q4JTwctb8KneByrWLKvNlx6Nipaqvo6icahZkH(iv8W5AruKN4IGljRUoRe6JuXdVPviKyUxrJXjo7ru3hnsHttmRaaQ(UKvNUsALpRzRLWuapzdXgweCjz15YL(jYdauLJoIaWXZ9J5lDUwef5joI6(OPVd8kOVlz1Pn5ye19rNvLtJiKyU13LS60MbaqrbTD95(X8LUg)UuEAfwHoq1DX2xjTADtesm3A6rQqne2kFS1sykGNSHydlcUKS6C5s)eBl1uo6icahFkDp8ygFPfUwef5joI6(OFkDp8ygFPf9DjRoTjhlcUKS6AEaGQC0reaoMvc9rQ4H3KJfbxswDnpaqvo6icah7FKMbaqrbTD9tP7HhZ4lTOj5XwlHPaEYgInSi4sYQZLl9tSTut5OJiaCSd63hYoxlII8ehrDF0Dq)(q213LS60MCKjrq0Dq)(q21K8yRLWuapzdXgcIsfLWuapQQ0WLl9tmaakkOTZvHqeDGQXVlLNiYhBTeMc4jBi2WyhdAhrRKA5CvieZKiiAKRIzqplyA)(OtJeAHiNAAvMebrx9oqjtb8OqIfnjplw4itIGO7FKoaZZoivjnjpRzRLWuapzdXgcIsfLWuapQQ0WLl9t8P09WJz8Lw4QqioI6(OFkDp8ygFPf9DjRoTPvlcUKS662snLJoIaWXNs3dpMXxAXIf6ZKii6Ns3dpMXxArtYZA2AjmfWt2qSbmPhLWuapQQ0WLl9tK(oWRaxfcXru3hn9DGxb9DjRoLTwctb8KneBat6rjmfWJQknC5s)eDaUlk2A2AjmfWt6aaOOG2oX(hPdW8SdsvIRcHihwnI6(OPVd8kOVlz1PwSSi4sYQR5baQYrhra4y)JyDZaaOOG2U(C)y(sxJFxkpryR810kocGL7Ip6L7JDUX67swDQflCqbJovocPkMXIt1tfAPC0wBXcsH2(eXVlLNwrRCITwctb8KoaakkOTBdXg6FKoaZZoivjUkeIJOUpA67aVc67swDAtRcaGIcA76Z9J5lDn(DP8eHTYxtR4yrWLKvxNvc9rQ4HBXsaauuqBxNvc9rQ4HRXVlLNieDGQ7ITBT1nTIJay5U4JE5(yNBS(UKvNAXchuWOtLJqQIzS4u9uHwkhT1S1sykGN0baqrbTDBi2qQCesvmJfNYvHqKdky0PYrivXmwCQEQqlLJMTwctb8KoaakkOTBdXgg7pAN0hUkeICmI6(OPVd8kOVlz1Pn5yrWLKvx3wQPC0reao2b97dz3ILmjcIgHexaYueTyB6AsES1sykGN0baqrbTDBi2acGspooG4y)reL0pBTeMc4jDaauuqB3gInCf3Ps8i9b8pxfcrRKWulpE)96jcPpv4tJJGr)jzXcwkA8l3hTqPjD5eUk(SMTwctb8KoaakkOTBdXg4bMc4CvieZKii6(hPdW8SdsvsJFxkpryRCYIfKcT9jIFxkpTcBLp26gpZSYoIqQgMbruQSeAHzqayMHmjz1zMAEpPzRLWuapPdaGIcA72qSbY0J18EIRcHyMebr3)iDaMNDqQsAsES1S1sykGN003bEfiICvetMSZvHq0Qru3hnPNbKongSlGK(UKvN2mtIGOj9mG0PXGDbK0K8SUPvb7cg9teB1IfRWsrJF5(O7GL3Vp6Yjef(AILIg)Y9rluAsxoHOWN1wZwlHPaEstFh4vWgInqVm2JP2)84QqiUi4sYQRZkH(iv8WzRLWuapPPVd8kydXgqRKA5X5DEpnCvieLWulpE)96jcPpv4tJJGr)jzXcwkA8l3hTqPjD5eIcFS1sykGN003bEfSHydJDmODeTsQLZvHqmaCkzn60XyzonIwj1Y13LS60MbaqrbTD95(X8LUg)UuEAf2AtoYKii6(hPdW8SdsvstYRjh0Njrq0325bsNgBdiDQMKhBTeMc4jn9DGxbBi2W5(X8LoxfcrSu04xUpAHstAsEwSGLIg)Y9rluAsxoHTYj2AjmfWtA67aVc2qSHSsOpsfpCUkeIlcUKS66SsOpsfp8MCeaaff0219pshG5zhKQKgFHYDtRcaGIcA76Z9J5lDn(DP8eHCYIfRWsrJF5(OfknPlNWaaOOG2EtSu04xUpAHst6YxrRCYARzRLWuapPPVd8kydXgQEhOKPaEuiXcBTeMc4jn9DGxbBi2G4EzVuYuaNRcHihlcUKS6AEaGQC0reaoMvc9rQ4HZwlHPaEstFh4vWgInGCvwj0ZvHqeHeZTMEKkudHeTf(yRLWuapPPVd8kydXgc2fqkMgC1Y5QqiYXIGljRUMhaOkhDebGJzLqFKkE4n5yrWLKvxZdauLJoIaWXZ9J5lD2AjmfWtA67aVc2qSbKRIyYKDUkeIJOUpA67apMvc9j9DjRoTjhbaqrbTD95(X8LUgFHYDtRc2fm6Ni2QflwHLIg)Y9r3blVFF0Ltik81elfn(L7JwO0KUCcrHpRTMTwctb8KM(oWRGneBG(oWtXCnNRa3b1JJGr)jrefUkeIys)iam6RZKyVC0X2asN2K(mjcIotI9YrhBdiDQg)UuEAf2cBTeMc4jn9DGxbBi2a9DGNI5AoBTeMc4jn9DGxbBi2WyhdAhrRKA5CvieZKiiAa5ebirS4OVMKhBTeMc4jn9DGxbBi2aYvrmzYoxfcXoy597JMwPr8WjefozXsMebrdiNiajIfh91K8yRLWuapPPVd8kydXgwUJ(iKQi(d(YWvHqSdwE)(OPvAepCcrHtS1sykGN003bEfSHydJDmODeTsQLZvHqCe19rtFh4XSsOpPVlz1PS1S1sykGN0pLUhEmJV0cXNs3dpMXxAHRcHicjMBcjY55RPvbaqrbTDDwj0hPIhUgFHYTflCSi4sYQRZkH(iv8WTMTwctb8K(P09WJz8LwSHyd0lJ9yQ9ppUkeIlcUKS66SsOpsfp8M0Njrq0pLUhEmJV0IMKhBTeMc4j9tP7HhZ4lTydXgYkH(iv8W5QqiUi4sYQRZkH(iv8WBsFMebr)u6E4Xm(slAsES1sykGN0pLUhEmJV0IneBqCVSxkzkGZvHqK(mjcI(P09WJz8Lw0K8yRLWuapPFkDp8ygFPfBi2qWUasX0GRwoxfcr6ZKii6Ns3dpMXxArtYJTMTwctb8K2b4UOiUCh9rivr8h8LHRcH4iQ7JUd63hYU(UKvN2mtIGO5HppbFQMcA7nNQFcrHTwctb8K2b4UOSHydixfXKj7CvieTArWLKvx3wQPC0reao2b97dz3ILru3hnPNbKongSlGK(UKvN2mtIGOj9mG0PXGDbK0K8SUPvb7cg9teB1IfRWsrJF5(O7GL3Vp6Yjef(AILIg)Y9rluAsxoHOWN1wZwlHPaEs7aCxu2qSbKRIzbJf0NRcHOeMA5X7Vxpri9PcFACem6pjlwWsrJF5(OfknPlNWvXhBTeMc4jTdWDrzdXgOxg7Xu7FECviexeCjz11zLqFKkE4S1sykGN0oa3fLneBO6DGsMc4rHelS1sykGN0oa3fLneBaTsQLhN3590WvHqKJfbxswDDBPMYrhra4yh0VpK9MwjHPwE8(71tesFQWNghbJ(tYIfSu04xUpAHst6Yjef(SMTwctb8K2b4UOSHydJDmODeTsQLZvHqmaCkzn60XyzonIwj1Y13LS60MbaqrbTD95(X8LUg)UuEAf2AtoYKii6(hPdW8SdsvstYRjh0Njrq0325bsNgBdiDQMKhBTeMc4jTdWDrzdXgo3pMV05QqiYXIGljRUUTut5OJiaCSd63hYEtRKWulpE)96jcPpv4tJJGr)jzXcwkA8l3hTqPjD5eIcNSMTwctb8K2b4UOSHydzLqFKkE4CviexeCjz11zLqFKkE4S1sykGN0oa3fLneBa5QSsONRcHicjMBn9ivOgcjAl8XwlHPaEs7aCxu2qSbX9YEPKPaoxfcrRgrDF003bEmRe6t67swDQflCSi4sYQRBl1uo6icah7G(9HSBXccjMBn9ivOMvSk(SyjtIGO7FKoaZZoivjn(DP80k4K1n5yrWLKvxZdauLJoIaWXSsOpsfp8MCSi4sYQRBl1uo6icahFkDp8ygFPf2AjmfWtAhG7IYgIneSlGumn4QLZvHq0Qru3hn9DGhZkH(K(UKvNAXchlcUKS662snLJoIaWXoOFFi7wSGqI5wtpsfQzfRIpRBYXIGljRUMhaOkhDebGJ9pstoweCjz118aav5OJiaCmRe6JuXdVjhlcUKS662snLJoIaWXNs3dpMXxAHTwctb8K2b4UOSHydN7hZx6CviehrDF0zv50icjMB9DjRoTjwkA8l3hTqPjD5egaaff02zRLWuapPDaUlkBi2a9DGNI5AoxbUdQhhbJ(tIikCvieXK(ray0xNjXE5OJTbKoTj9zseeDMe7LJo2gq6un(DP80kSf2AjmfWtAhG7IYgInqFh4PyUMZwlHPaEs7aCxu2qSbKRIyYKDUkeICmI6(O7G(9HSRVlz1PnXsrJF5(O7GL3Vp6YjmyxWOFALGcFnhrDF003bEmRe6t67swDkBTeMc4jTdWDrzdXgqUkRe65Qqi2blVFF00knIhoHOWjlwYKiiAa5ebirS4OVMKhBTeMc4jTdWDrzdXgqUkIjt25Qqi2blVFF00knIhoHOWjlwSktIGObKteGeXIJ(AsEn5ye19r3b97dzxFxYQtTMTwctb8K2b4UOSHydl3rFesve)bFz4Qqi2blVFF00knIhoHOWj2AjmfWtAhG7IYgInm2XG2r0kPwoxfcXru3hn9DGhZkH(K(UKvNc3lhNkGdrTv(ALpuALpuG72c2lhDcU5SSn4CrTXH6QNZWmmdb2pZuDEa8WmiamZ0ihG7IQrmd(CoKf(uMjb6NzeYb0L5uMjyxC0pPzRxPLFMbfBHZWm2wGVC8CkZ0imPFeag91RwJyMbWmnct6hbGrF9QPVlz1PnIzScfB3AnBnBnNLTbNlQnoux9CgMHziW(zMQZdGhMbbGzMgrpIqQMgXm4Z5qw4tzMeOFMrihqxMtzMGDXr)KMTELw(zMvXzygBlWxoEoLzAeM0pcaJ(6vRrmZayMgHj9JaWOVE103LS60gXmwHITBTMTMTMZY2GZf1ghQREodZWmey)mt15bWdZGaWmtJcaGIcA7nIzWNZHSWNYmjq)mJqoGUmNYmb7IJ(jnB9kT8ZmOWzygBlWxoEoLzAuaSCx8rVA67swDAJyMbWmnkawUl(OxTgXmwHITBTMTELw(zMw5mmJTf4lhpNYmnkawUl(Oxn9DjRoTrmZayMgfal3fF0RwJygRqX2TwZwZwZzzBW5IAJd1vpNHzygcSFMP68a4HzqayMPr03bEfAeZGpNdzHpLzsG(zgHCaDzoLzc2fh9tA26vA5NzqPvodZyBb(YXZPmtJWK(ray0xVAnIzgaZ0imPFeag91RM(UKvN2iMXkuSDR1S1S1nUopaEoLz4eZiHPaoZOQ0K0S1WTqo2by4ExDBlCRQ0KGea3oa3ffKaiQOajaUVlz1Pq(H7aUMJlbUhrDF0Dq)(q213LS6uMPjZKjrq08WNNGpvtbTDMPjZmv)mdHmdkWTeMc4W9YD0hHufXFWxg4arTvibW9DjRofYpChW1CCjWTvmZIGljRUUTut5OJiaCSd63hYoZyXcZmI6(Oj9mG0PXGDbK03LS6uMPjZKjrq0KEgq60yWUasAsEmJ1mttMXkMjyxWOFIziYmTYmwSWmwXmyPOXVCF0DWY73hD5mdHmdk8XmnzgSu04xUpAHst6Yzgczgu4JzSMzSgULWuahUrUkIjt2Hde1vbjaUVlz1Pq(H7aUMJlbULWulpE)96jMHqMH(uHpnocg9NeZyXcZGLIg)Y9rluAsxoZqiZSk(GBjmfWHBKRIzbJf0hoquTfibW9DjRofYpChW1CCjW9IGljRUoRe6JuXdhULWuahUPxg7Xu7FEWbIkNGea3sykGd3vVduYuapkKybUVlz1Pq(HdevBfsaCFxYQtH8d3bCnhxcCZbZSi4sYQRBl1uo6icah7G(9HSZmnzgRygjm1YJ3FVEIziKzOpv4tJJGr)jXmwSWmyPOXVCF0cLM0LZmeYmOWhZynClHPaoCJwj1YJZ78EAGde1gdsaCFxYQtH8d3bCnhxcChaoLSgD6ySmNgrRKA567swDkZ0KzcaGIcA76Z9J5lDn(DP8eZScMXwzMMmdhmtMebr3)iDaMNDqQsAsEmttMHdMH(mjcI(2opq60yBaPt1K8GBjmfWH7Xog0oIwj1YHdevopKa4(UKvNc5hUd4AoUe4MdMzrWLKvx3wQPC0reao2b97dzNzAYmwXmsyQLhV)E9eZqiZqFQWNghbJ(tIzSyHzWsrJF5(OfknPlNziKzqHtmJ1WTeMc4W95(X8LoCGOUYHea33LS6ui)WDaxZXLa3lcUKS66SsOpsfpC4wctbC4oRe6JuXdhoqurHpibW9DjRofYpChW1CCjWncjMBn9ivOgMHqImJTWhClHPaoCJCvwj0dhiQOGcKa4(UKvNc5hUd4AoUe42kMze19rtFh4XSsOpPVlz1PmJflmdhmZIGljRUUTut5OJiaCSd63hYoZyXcZGqI5wtpsfQHzwbZSk(yglwyMmjcIU)r6amp7GuL043LYtmZkygoXmwZmnzgoyMfbxswDnpaqvo6icahZkH(iv8WzMMmdhmZIGljRUUTut5OJiaC8P09WJz8LwGBjmfWHBX9YEPKPaoCGOIsRqcG77swDkKF4oGR54sGBRyMru3hn9DGhZkH(K(UKvNYmwSWmCWmlcUKS662snLJoIaWXoOFFi7mJflmdcjMBn9ivOgMzfmZQ4JzSMzAYmCWmlcUKS6AEaGQC0reao2)imttMHdMzrWLKvxZdauLJoIaWXSsOpsfpCMPjZWbZSi4sYQRBl1uo6icahFkDp8ygFPf4wctbC4oyxaPyAWvlhoqurzvqcG77swDkKF4oGR54sG7ru3hDwvonIqI5wFxYQtzMMmdwkA8l3hTqPjD5mdHmJeMc4XaaOOG2oClHPaoCFUFmFPdhiQOylqcG77swDkKF4wctbC4M(oWtXCnhUd4AoUe4gt6hbGrFDMe7LJo2gq6u9DjRoLzAYm0Njrq0zsSxo6yBaPt143LYtmZkygBbUdChupocg9NeevuGdevu4eKa4wctbC4M(oWtXCnhUVlz1Pq(HdevuSvibW9DjRofYpChW1CCjWnhmZiQ7JUd63hYU(UKvNYmnzgSu04xUp6oy597JUCMHqMjyxWOFIzwjmdk8XmnzMru3hn9DGhZkH(K(UKvNc3sykGd3ixfXKj7WbIkkngKa4(UKvNc5hUd4AoUe4UdwE)(OPvAepCMHqMbfoXmwSWmzseenGCIaKiwC0xtYdULWuahUrUkRe6Hdevu48qcG77swDkKF4oGR54sG7oy597JMwPr8Wzgczgu4eZyXcZyfZKjrq0aYjcqIyXrFnjpMPjZWbZmI6(O7G(9HSRVlz1PmJ1WTeMc4WnYvrmzYoCGOIYkhsaCFxYQtH8d3bCnhxcC3blVFF00knIhoZqiZGcNGBjmfWH7L7OpcPkI)GVmWbIAR8bjaUVlz1Pq(H7aUMJlbUhrDF003bEmRe6t67swDkClHPaoCp2XG2r0kPwoCGdCtpIqQgibqurbsaClHPaoCtReMK3a33LS6ui)WbIARqcGBjmfWH7aWtK9h7c6ka33LS6ui)WbI6QGea33LS6ui)WnGhCN(a3sykGd3lcUKS6W9IOipCpI6(OrkCAIzfaq13LS6uMXIfMjX7kvCem6pjDwj0hPIhokmdHezgRyMvXmC2mJvmZiQ7JEWsPIaKiMSC9DjRoLzSHzYKii6(hPdW8SdsvstYJzSMzSMzSyHzWK(ray0xhSlGuCSFaMB9DjRoLzAYmzseeDWUasXX(byU1uqBhUxeC0L(H7SsOpsfpC4ar1wGea33LS6ui)WnGhCN(a3sykGd3lcUKS6W9IOipCZbZmI6(OPVd8kOVlz1PmttMjaakkOTR7FKoaZZoivjn(DP8eZScMXwzMMmdcjMBn9ivOgMHqMzv8b3lco6s)Wnpaqvo6icah7Fe4arLtqcG77swDkKF4gWdUtFGBjmfWH7fbxswD4EruKhUxeCjz11zLqFKkE4mttMXkMbHeZnZScMPX4eZWzZmJOUpAKcNMywbau9DjRoLzwjmtR8Xmwd3lco6s)Wnpaqvo6icahZkH(iv8WHdevBfsaCFxYQtH8d3aEWD6dClHPaoCVi4sYQd3lII8W9iQ7JM(oWRG(UKvNYmnzgoyMru3hDwvonIqI5wFxYQtzMMmtaauuqBxFUFmFPRXVlLNyMvWmwXmOduDxSDMzLWmTYmwZmnzgesm3A6rQqnmdHmtR8b3lco6s)Wnpaqvo6icahp3pMV0Hde1gdsaCFxYQtH8d3aEWD6dClHPaoCVi4sYQd3lII8W9iQ7J(P09WJz8Lw03LS6uMPjZWbZSi4sYQR5baQYrhra4ywj0hPIhoZ0Kz4GzweCjz118aav5OJiaCS)ryMMmtaauuqBx)u6E4Xm(slAsEW9IGJU0pC3wQPC0reao(u6E4Xm(slWbIkNhsaCFxYQtH8d3aEWD6dClHPaoCVi4sYQd3lII8W9iQ7JUd63hYU(UKvNYmnzgoyMmjcIUd63hYUMKhCVi4Ol9d3TLAkhDebGJDq)(q2Hde1voKa4(UKvNc5hUd4AoUe4gDGQXVlLNygImdFWTeMc4WDquQOeMc4rvLg4wvPj6s)WDaauuqBhoqurHpibW9DjRofYpChW1CCjWDMebrJCvmd6zbt73hDAKqlmdrMHtmttMXkMjtIGOREhOKPaEuiXIMKhZyXcZWbZKjrq09pshG5zhKQKMKhZynClHPaoCp2XG2r0kPwoCGOIckqcG77swDkKF4oGR54sG7ru3h9tP7HhZ4lTOVlz1PmttMXkMzrWLKvx3wQPC0reao(u6E4Xm(slmJflmd9zsee9tP7HhZ4lTOj5Xmwd3sykGd3brPIsykGhvvAGBvLMOl9d3pLUhEmJV0cCGOIsRqcG77swDkKF4oGR54sG7ru3hn9DGxb9DjRofULWuahUXKEuctb8OQsdCRQ0eDPF4M(oWRaCGOIYQGea33LS6ui)WTeMc4WnM0JsykGhvvAGBvLMOl9d3oa3ffCGdCtFh4vasaevuGea33LS6ui)WDaxZXLa3wXmJOUpAspdiDAmyxaj9DjRoLzAYmzseenPNbKongSlGKMKhZynZ0KzSIzc2fm6NygImtRmJflmJvmdwkA8l3hDhS8(9rxoZqiZGcFmttMblfn(L7JwO0KUCMHqMbf(ygRzgRHBjmfWHBKRIyYKD4arTvibW9DjRofYpChW1CCjW9IGljRUoRe6JuXdhULWuahUPxg7Xu7FEWbI6QGea33LS6ui)WDaxZXLa3syQLhV)E9eZqiZqFQWNghbJ(tIzSyHzWsrJF5(OfknPlNziKzqHp4wctbC4gTsQLhN3590ahiQ2cKa4(UKvNc5hUd4AoUe4oaCkzn60XyzonIwj1Y13LS6uMPjZeaaff021N7hZx6A87s5jMzfmJTYmnzgoyMmjcIU)r6amp7GuL0K8yMMmdhmd9zsee9TDEG0PX2asNQj5b3sykGd3JDmODeTsQLdhiQCcsaCFxYQtH8d3bCnhxcCJLIg)Y9rluAstYJzSyHzWsrJF5(OfknPlNziKzALtWTeMc4W95(X8LoCGOARqcG77swDkKF4oGR54sG7fbxswDDwj0hPIhoZ0Kz4GzcaGIcA76(hPdW8SdsvsJVq5MzAYmwXmbaqrbTD95(X8LUg)UuEIziKz4eZyXcZyfZGLIg)Y9rluAsxoZqiZiHPaEmaakkOTZmnzgSu04xUpAHst6YzMvWmTYjMXAMXA4wctbC4oRe6JuXdhoquBmibWTeMc4WD17aLmfWJcjwG77swDkKF4arLZdjaUVlz1Pq(H7aUMJlbU5GzweCjz118aav5OJiaCmRe6JuXdhULWuahUf3l7LsMc4WbI6khsaCFxYQtH8d3bCnhxcCJqI5wtpsfQHziKiZyl8b3sykGd3ixLvc9WbIkk8bjaUVlz1Pq(H7aUMJlbU5GzweCjz118aav5OJiaCmRe6JuXdNzAYmCWmlcUKS6AEaGQC0reaoEUFmFPd3sykGd3b7ciftdUA5WbIkkOajaUVlz1Pq(H7aUMJlbUhrDF003bEmRe6t67swDkZ0Kz4GzcaGIcA76Z9J5lDn(cLBMPjZyfZeSly0pXmezMwzglwygRygSu04xUp6oy597JUCMHqMbf(yMMmdwkA8l3hTqPjD5mdHmdk8XmwZmwd3sykGd3ixfXKj7WbIkkTcjaUVlz1Pq(HBjmfWHB67apfZ1C4oGR54sGBmPFeag91zsSxo6yBaPt13LS6uMPjZqFMebrNjXE5OJTbKovJFxkpXmRGzSf4oWDq94iy0FsqurboqurzvqcGBjmfWHB67apfZ1C4(UKvNc5hoqurXwGea33LS6ui)WDaxZXLa3zseenGCIaKiwC0xtYdULWuahUh7yq7iALulhoqurHtqcG77swDkKF4oGR54sG7oy597JMwPr8Wzgczgu4eZyXcZKjrq0aYjcqIyXrFnjp4wctbC4g5QiMmzhoqurXwHea33LS6ui)WDaxZXLa3DWY73hnTsJ4HZmeYmOWj4wctbC4E5o6JqQI4p4ldCGOIsJbjaUVlz1Pq(H7aUMJlbUhrDF003bEmRe6t67swDkClHPaoCp2XG2r0kPwoCGdChaaff02HearffibW9DjRofYpChW1CCjWnhmJvmZiQ7JM(oWRG(UKvNYmwSWmlcUKS6AEaGQC0reao2)imJ1mttMjaakkOTRp3pMV0143LYtmdHmtR8XmnzgRygoyMay5U4JE5(yNBmZyXcZWbZqbJovocPkMXIt1tfAPC0mJ1mJflmdsH2(eXVlLNyMvWmTYj4wctbC4U)r6amp7GuLGde1wHea33LS6ui)WDaxZXLa3JOUpA67aVc67swDkZ0KzSIzcaGIcA76Z9J5lDn(DP8eZqiZ0kFmttMXkMHdMzrWLKvxNvc9rQ4HZmwSWmbaqrbTDDwj0hPIhUg)UuEIziKzqhO6Uy7mJ1mJ1mttMXkMHdMjawUl(OxUp25gZmwSWmCWmuWOtLJqQIzS4u9uHwkhnZynClHPaoC3)iDaMNDqQsWbI6QGea33LS6ui)WDaxZXLa3CWmuWOtLJqQIzS4u9uHwkhnClHPaoCNkhHufZyXPWbIQTajaUVlz1Pq(H7aUMJlbU5GzgrDF003bEf03LS6uMPjZWbZSi4sYQRBl1uo6icah7G(9HSZmwSWmzseencjUaKPiAX201K8GBjmfWH7X(J2j9boqu5eKa4wctbC4gbqPhhhqCS)iIs6hUVlz1Pq(HdevBfsaCFxYQtH8d3bCnhxcCBfZiHPwE8(71tmdHmd9PcFACem6pjMXIfMblfn(L7JwO0KUCMHqMzv8Xmwd3sykGd3xXDQepsFa)dhiQngKa4(UKvNc5hUd4AoUe4otIGO7FKoaZZoivjn(DP8eZqiZ0kNyglwygKcT9jIFxkpXmRGzSv(GBjmfWHBEGPaoCGOY5Hea33LS6ui)WDaxZXLa3zseeD)J0byE2bPkPj5b3sykGd3KPhR59eCGdC)u6E4Xm(slqcGOIcKa4(UKvNc5hUd4AoUe4gHeZnZqirMHZZhZ0KzSIzcaGIcA76SsOpsfpCn(cLBMXIfMHdMzrWLKvxNvc9rQ4HZmwd3sykGd3pLUhEmJV0cCGO2kKa4(UKvNc5hUd4AoUe4ErWLKvxNvc9rQ4HZmnzg6ZKii6Ns3dpMXxArtYdULWuahUPxg7Xu7FEWbI6QGea33LS6ui)WDaxZXLa3lcUKS66SsOpsfpCMPjZqFMebr)u6E4Xm(slAsEWTeMc4WDwj0hPIhoCGOAlqcG77swDkKF4oGR54sGB6ZKii6Ns3dpMXxArtYdULWuahUf3l7LsMc4WbIkNGea33LS6ui)WDaxZXLa30Njrq0pLUhEmJV0IMKhClHPaoChSlGumn4QLdh4a38Wpa6zzGeah4ah4aH]] )
end
