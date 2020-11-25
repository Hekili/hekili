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


    spec:RegisterPack( "Havoc", 20201124, [[dGudrbqieLhjuLAtcPpbsYOOGoffXQajv9kHWSqLClkkr7Iu)IIQHrbogi1YeIEMqLMMqvDnkk2gQu13qLkghfLY5eQiRJIs18qLY9qO9Hk6GGKklKI0dbjfteKuQlcskXgbjL0hfQOmskkHtIkvYkbvMjQuP2jIQLkuL0tbAQOcFvOIQXsrjTxO(lvnykDyIflXJPYKr5YQ2mGpdkJMcDAfVgKy2KCBjTBr)wPHJihxOkXYH8CbtxQRJQ2oi(Uqz8cv48GQwVqvmFeSFKgdnMdmit6JjpsdI0aOHoY4RJmUX1G4gjgSHN0XGKehueyhdMs9yqZcbY6WGKe4vRWWCGbdlpYDmi4u5vspBc1GeGgdw4hvZDL4cgKj9XKhPbrAa0qhz81rg34AqKXjmyG0DyYnd3H7Gbnom2tCbdYEWHbJ3ulu7x3KAnl4Z(iQ1SqGSokCXBQL8fYRLJO2iJpxuBKgePbyqsOfyuhdgVPwO2VUj1AwWN9ruRzHazDu4I3ul5lKxlhrTrgFUO2inisdOWrHlEtTGPqkyCBQfjdJAl8aaNrTHw6a1woWIo162ArAQTCytgOwjzulj0nljTDpjmQDculBZRPWjUE2mOjHUBRfPJGO58H7N(vUsPEIs8emkij4b2S9lGN0g7ikCu4I3ululXXD89zu7HCe8uBp1tTTXtTIRxe1obQvGiJskQRPWjUE2mqKnbepPMcN46zZqeen3TzGVEFvGnokCIRNndrq0CicAKI6CLs9elkHDpts35cIO4pXwupBnWGcTVO2LPFkf1zeieiDLY3cc27GUOe29mjDhAojAyCnlBr9S1nsgLFb8i(j1pLI6mtiqaXNhyrWU2zu2GVn(fbF0cpaG2zu2GVn(fbVMTXskCIRNndrq0CicAKI6CLs9ejTRAsyEGf5RVfUGik(tKSwupBn71nhN(PuuNf1TRITXsD9TuxejJBycA0RYKbUX9rb4rWRzhyCtZzCnGcN46zZqeenhIGgPOoxPuprs7QMeMhyr(Isy3ZK0DUGik(teIGgPOUUOe29mjDpQHa8i45g3XmMLTOE2AGbfAFrTlt)ukQZG6J0atOWjUE2mebrZHiOrkQZvk1tK0UQjH5bwK)WFF5sLliII)eBr9S1Sx3CC6NsrDwuYAr9S1f1KmpapcE9tPOolQBxfBJL6d)9Llvn6vzYa3meMJPRsCa1hPjrb4rWRzhyCtZzKgqHtC9SzicIMdrqJuuNRuQNymz6jH5bwK)HWt39f0fOWferXFITOE26hcpD3xqxGI(PuuNfLmicAKI6As7QMeMhyr(Isy3ZK09OKbrqJuuxtAx1KW8alYxFlrD7QyBSu)q4P7(c6cu08KOWjUE2mebrZHiOrkQZvk1tmMm9KW8alYx36ZMVYferXFITOE266wF28v9tPOolkzfEaaDDRpB(QMNefoX1ZMHiiAUtukV46ztVAcnxPupr3Uk2gl5AaicZX0OxLjdenGcN46zZqeenVnI2yEykzGCUgaIfEaanWv(YwlcIvF26qloOq0mrnSWdaONADvspB6fEKO5jrGazfEaaD9TuxejJBycAEsMqHtC9SzicIM7eLYlUE20RMqZvk1t8HWt39f0fOW1aqSf1Zw)q4P7(c6cu0pLI6SOgcrqJuuxhtMEsyEGf5Fi80DFbDbkeiWEHhaq)q4P7(c6cu08KmHcN46zZqeenhXNEX1ZME1eAUsPEISx3CCCnaeBr9S1Sx3CC6NsrDgfoX1ZMHiiAoIp9IRNn9Qj0CLs9eZfvfffokCIRNndA3Uk2gljwFl1frY4gMaxdarYmSf1ZwZEDZXPFkf1zeiarqJuuxtAx1KW8alYxFlMe1qYClKNs2AipBJWJ0pLI6mceiJTTomjaVYxqsY094GYKWmHabGbMX2JEvMmWTindfoX1ZMbTBxfBJLrq086BPUisg3We4Aai2I6zRzVU540pLI6SOg62vX2yP(WFF5svJEvMmWzKge1qYGiOrkQRlkHDpts3jqWTRITXsDrjS7zs6Ug9QmzGtyoMUkXHjMe1qYClKNs2AipBJWJ0pLI6mceiJTTomjaVYxqsY094GYKWmHcN46zZG2TRITXYiiAEysaELVGKKX1aqKm226WKa8kFbjjt3JdktcJcN46zZG2TRITXYiiAEB8EJ8zZ1aqKSwupBn71nhN(PuuNfLmicAKI66yY0tcZdSiFDRpB(kbcfEaanapAw(GhMepxZtIcN46zZG2TRITXYiiAoWYyh5713gVhqj1tHtC9Szq72vX2yzeen)k4dJKE2DOFkCIRNndA3Uk2glJGO5K2E2KRbGyHhaqxFl1frY4gMGg9QmzGZindbcadmJTh9QmzGBCVbu4expBg0UDvSnwgbrZ5d3p9RCLs9eHjQ7eL6OGVSBY1aqKSwupBnWv(IGqcSRFkf1zei42vX2yPg4kFrqib21Olm4PWjUE2mOD7QyBSmcIMZhUF6x56aa31(uQNOdENAB0MJZxusO5Aaiw4ba013sDrKmUHjO5jfTWdaORVUi49lGxX7gMNHUudA2glJAizqe0if11fLWUNjP7eiqMBxfBJL6Isy3ZK0Dn6cdEtOWjUE2mOD7QyBSmcIMZhUF6x5kL6jkbJqK8bpsINf5DlsuCnaezVWdaOrs8SiVBrIYZEHhaqZ2yjbcgYEHhaq72KX76bY9tcfp7fEaanpjcek8aa66BPUisg3We0OxLjdCgPbMeTfeS3AJxuTrnjxZT4cnbcadmJTh9QmzGBrAafoX1ZMbTBxfBJLrq0C(W9t)kxPuprjEcgfKe8aB2(fWtAJDexdar3Uk2gl113sDrKmUHjOrVktg4g0gqGGBxfBJL66BPUisg3We0OxLjdCY9gqHlEtTqTpGWRAQfquQI4Gc1cSiQLpif1P2PFnOPWjUE2mOD7QyBSmcIMZhUF6xdCnael8aa66BPUisg3We08KOWjUE2mOD7QyBSmcIM7eLYlUE20RMqZvk1t8HWt3du4OWjUE2mOzVU54icCLhXhmY1aq0WwupBnFww(K5DgLnOFkf1zrl8aaA(SS8jZ7mkBqZtYKOg6mkiypqmscemejdZFipBDDH86ZwpjNqBquKmm)H8S1cJf0tYj0gyIju4expBg0Sx3CCrq0C2L2Ope7NexdaricAKI66Isy3ZK0DkCIRNndA2RBoUiiAomLmqUVFL0dnxdarX1dK7F(68aNShg0z(wqWEhiqajdZFipBTWyb9KCcTbu4expBg0Sx3CCrq082iAJ5HPKbY5Aai62KXpToCes6Z8WuYa56NsrDwu3Uk2gl1h(7lxQA0RYKbUX9rjRWdaORVL6IizCdtqZtkkzSx4ba0poiTHZ8Xw(KP5jrHtC9SzqZEDZXfbrZp83xUu5AaiIKH5pKNTwySGMNebcizy(d5zRfglONKZindfoX1ZMbn71nhxeenVOe29mjDNRbGiebnsrDDrjS7zs6EuYC7QyBSuxFl1frY4gMGgDHbFudD7QyBSuF4VVCPQrVktg40meiyisgM)qE2AHXc6j50TRITXYOizy(d5zRfglONKBrAgtmHcN46zZGM96MJlcIMp16QKE20l8iHcN46zZGM96MJlcIMlzoghL0ZMCnaejdIGgPOUM0UQjH5bwKVOe29mjDNcN46zZGM96MJlcIMdCvrjSZ1aqeGhbVMDGXnnNeJVbu4expBg0Sx3CCrq0CNrzd(qJgOCUgaIKbrqJuuxtAx1KW8alYxuc7EMKUhLmicAKI6As7QMeMhyr(d)9LlvkCIRNndA2RBoUiiAoWvEeFWixdaXwupBn71n9fLWEq)ukQZIsMBxfBJL6d)9Llvn6cd(Og6mkiypqmscemejdZFipBDDH86ZwpjNqBquKmm)H8S1cJf0tYj0gyIju4expBg0Sx3CCrq0C2RBg8LPpxo4DQ7Bbb7DGi0Cnaer85bweSRl8OCsy(ylFYIYEHhaqx4r5KW8Xw(KPrVktg4w8PWjUE2mOzVU54IGO5Sx3m4ltFkCIRNndA2RBoUiiAEBeTX8WuYa5Cnael8aa6LV9lGhjjSR5jrHtC9SzqZEDZXfbrZbUYJ4dg5AaiwxiV(S1Sj0s6oNqBgcek8aa6LV9lGhjjSR5jrHtC9SzqZEDZXfbrZH8e2b4vE0B0LMRbGyDH86ZwZMqlP7CcTzOWjUE2mOzVU54IGO5Tr0gZdtjdKZ1aqSf1ZwZEDtFrjSh0pLI6mkCu4expBg0peE6UVGUafIpeE6UVGUafUgaIa8i45KOzZGOg62vX2yPUOe29mjDxJUWGNabYGiOrkQRlkHDpts3nHcN46zZG(HWt39f0fOebrZzxAJ(qSFsCnaeHiOrkQRlkHDpts3JYEHhaq)q4P7(c6cu08KOWjUE2mOFi80DFbDbkrq08Isy3ZK0DUgaIqe0if11fLWUNjP7rzVWdaOFi80DFbDbkAEsu4expBg0peE6UVGUaLiiAUK5yCuspBY1aqK9cpaG(HWt39f0fOO5jrHtC9Szq)q4P7(c6cuIGO5oJYg8Hgnq5CnaezVWdaOFi80DFbDbkAEsu4OWjUE2mOFi809aricAKI6CLs9ebUYxeesGDFa(0X1aqSf1ZwdCLViiKa76NsrDgxqef)j62vX2yPg4kFrqib21Olm4JAOHgswlQNTM96MJt)ukQZiqOWdaORVL6IizCdtqZtYKOKbrqJuuxhtMEsyEGf5RB9zZxJIKH5pKNTwySGEsoJRbMqGG46bY9pFDEGt2dd6mFliyVdMqHtC9Szq)q4P7HiiAUBt3Zgj9zEaLupxdardjJTT2TP7zJK(mpGsQ3x4rPUhhuMewuYexpBQDB6E2iPpZdOK61t6budmJnbca8kLhDNrbb7(EQNBWCmDvIdtOWfVPwOUUFLutT9sTb4th1gBAJuluRxrTMkiKa7u7IOwOUfQfQDaO2PP2yJsrTLtT8HZO2ytBCsQTnEQnFC0uB8nd1gUBtwGlQDBJhfBcNA5dNAz8OjHrT5IQIIAl8OqtTmPkWUMcN46zZG(HWt3drq08IAxMFb8TX7F(k8CnaenKSwupBnWv(IGqcSRFkf1zei42vX2yPg4kFrqib21OxLjdCgFZysuYGiOrkQRJjtpjmpWI81T(S5Rrn0qYAr9S1Sx3CC6NsrDgbcfEaaD9TuxejJBycAEsrjZTRITXsDrjS7zs6UgDHbVjeiamWm2E0RYKbUreAdmHcN46zZG(HWt3drq08IAxMFb8TX7F(k8CnaeBr9S1ax5lccjWU(PuuNffIGgPOUg4kFrqib29b4thfoX1ZMb9dHNUhIGO5W4feBK0VaEjEoABJCnaenSWdaORVL6IizCdtqZtkQBxfBJL66BPUisg3We0Olm4nHaHcpaGU(wQlIKXnmbn6vzYaNrAgceagygBp6vzYa3igxdOWjUE2mOFi809qeenhyD8HZ8s8C003xUu5AaigiDLY3cc27GUOe29mjDhAojgjbcizy(d5zRfglONKtU3akCIRNnd6hcpDpebrZjXJga4NeMVOKqZ1aqmq6kLVfeS3bDrjS7zs6o0CsmsceqYW8hYZwlmwqpjNCVbu4expBg0peE6EicIM3gVNpllFY8alYDUgaIfEaan6oOOEi4bwK7AEseiu4ba0O7GI6HGhyrU7DlF2hPdT4Gc3G2akCIRNnd6hcpDpebrZrdjsQ7N0hijUtHtC9Szq)q4P7HiiAESfPyq(KE0dBkP7Cnael8aa66BPUisg3We08KiqaIGgPOUg4kFrqib29b4thfoX1ZMb9dHNUhIGO51xxe8(fWR4DdZZqxQbUgaIa8i45w8niAHhaqxFl1frY4gMGMNefoX1ZMb9dHNUhIGO5OlKMeMhqj1h4YbVtDFliyVdeHMRbGyliyV19uVVxpBo3GwBgcem0WwqWERnEr1g1KCnNMndiqOfeS3AJxuTrnjxZnIrAGjrnuC9a5(NVopqeAceAbb7TUN6996zZ5mY4KjMqGGHTGG9w3t9(E9KCTpsd4mUge1qX1dK7F(68arOjqOfeS36EQ33RNnNZ4hFtmHchfoX1ZMbDUOQOic5jSdWR8O3OlnxdaXwupBDDRpB(Q(PuuNfTWdaOjHojbDMMTXYO9upNqtHtC9SzqNlQkQiiAoWvEeFWixdardHiOrkQRJjtpjmpWI81T(S5Rei0I6zR5ZYYNmVZOSb9tPOolAHhaqZNLLpzENrzdAEsMe1qNrbb7bIrsGGHizy(d5zRRlKxF26j5eAdIIKH5pKNTwySGEsoH2atmHcN46zZGoxuvurq0CGR8fbHeyNRbGO46bY9pFDEGt2dd6mFliyVdeiGKH5pKNTwySGEsoJRbu4expBg05IQIkcIMZU0g9Hy)K4AaicrqJuuxxuc7EMKUtHtC9SzqNlQkQiiA(uRRs6ztVWJekCIRNnd6CrvrfbrZHPKbY99RKEO5AaisgebnsrDDmz6jH5bwKVU1NnFnQHIRhi3)815bozpmOZ8TGG9oqGasgM)qE2AHXc6j5eAdmHcN46zZGoxuvurq082iAJ5HPKbY5Aai62KXpToCes6Z8WuYa56NsrDwu3Uk2gl1h(7lxQA0RYKbUX9rjRWdaORVL6IizCdtqZtkkzSx4ba0poiTHZ8Xw(KP5jrHtC9SzqNlQkQiiA(H)(YLkxdarX1dK7F(68aNqh1qYqYW8hYZwlmwq)4ycDGabKmm)H8S1cJf08Kmjkzqe0if11XKPNeMhyr(6wF28vkCIRNnd6CrvrfbrZlkHDpts35AaicrqJuuxxuc7EMKUtHtC9SzqNlQkQiiAoWvfLWoxdaraEe8A2bg30Csm(gqHtC9SzqNlQkQiiA(H)(YLkxdarYAr9S1f1KmpapcE9tPOolkzqe0if11XKPNeMhyr(hcpD3xqxGsuKmm)H8S1cJf0tYPBxfBJLu4expBg05IQIkcIMlzoghL0ZMCnaenSf1ZwZEDtFrjSh0pLI6mceidIGgPOUoMm9KW8alYx36ZMVsGaapcEn7aJBAUfxdiqOWdaORVL6IizCdtqJEvMmWnZysuYGiOrkQRjTRAsyEGf5lkHDpts3JsgebnsrDDmz6jH5bwK)HWt39f0fOqHtC9SzqNlQkQiiAUZOSbFOrduoxdardBr9S1Sx30xuc7b9tPOoJabYGiOrkQRJjtpjmpWI81T(S5ReiaWJGxZoW4MMBX1atIsgebnsrDnPDvtcZdSiF9TeLmicAKI6As7QMeMhyr(Isy3ZK09OKbrqJuuxhtMEsyEGf5Fi80DFbDbku4expBg05IQIkcIMF4VVCPY1aqSf1ZwxutY8a8i41pLI6SOizy(d5zRfglONKt3Uk2glPWjUE2mOZfvfveenN96MbFz6ZLdEN6(wqWEhicnxdareFEGfb76cpkNeMp2YNSOSx4ba0fEuojmFSLpzA0RYKbUfFkCIRNnd6CrvrfbrZzVUzWxM(u4expBg05IQIkcIMdCLhXhmY1aqKSwupBDDRpB(Q(PuuNffjdZFipBDDH86ZwpjNoJcc2dq9qBq0wupBn71n9fLWEq)ukQZOWjUE2mOZfvfveenh4QIsyNRbGyDH86ZwZMqlP7CcTziqOWdaOx(2VaEKKWUMNefoX1ZMbDUOQOIGO5ax5r8bJCnaeRlKxF2A2eAjDNtOndbcgw4ba0lF7xapssyxZtkkzTOE266wF28v9tPOoZekCIRNnd6CrvrfbrZH8e2b4vE0B0LMRbGyDH86ZwZMqlP7CcTzOWjUE2mOZfvfveenVnI2yEykzGCUgaITOE2A2RB6lkH9G(PuuNHbHCuy2etEKgePbqdDKXfdgtq5KWcyW4COU4vY5UipoZStTulhgp1ovslQPwGfrTqvUOQOGkQf94f(bDg1g26PwHV3Q0NrToJsc7bnfoU7jp1cTzm7uluZMqoQpJAHkeFEGfb7AZkurT9sTqfIppWIGDTzv)ukQZGkQ1qOJdt0u4OWfNd1fVso3f5XzMDQLA5W4P2PsArn1cSiQfQyhq4vnurTOhVWpOZO2Wwp1k89wL(mQ1zusypOPWXDp5P24A2PwOMnHCuFg1cvi(8alc21MvOIA7LAHkeFEGfb7AZQ(PuuNbvuRHqhhMOPWrHlohQlELCUlYJZm7ul1YHXtTtL0IAQfyrulu52vX2yjurTOhVWpOZO2Wwp1k89wL(mQ1zusypOPWXDp5PwOn7uluZMqoQpJAHk3c5PKT2SQFkf1zqf12l1cvUfYtjBTzfQOwdHoomrtHJ7EYtTrA2PwOMnHCuFg1cvUfYtjBTzv)ukQZGkQTxQfQClKNs2AZkurTgcDCyIMchfU4COU4vY5UipoZStTulhgp1ovslQPwGfrTqf71nhhurTOhVWpOZO2Wwp1k89wL(mQ1zusypOPWXDp5PwOJ0StTqnBc5O(mQfQq85bweSRnRqf12l1cvi(8alc21Mv9tPOodQOwdHoomrtHJch3vL0I6ZOwUd1kUE2KAvtOdAkCyq1e6aMdmyUOQOWCGjhAmhyWNsrDg2umOdn9rJGbBr9S11T(S5R6NsrDg1gLAl8aaAsOtsqNPzBSKAJsT9up1Yj1cnguC9SjgeYtyhGx5rVrxACJjpsmhyWNsrDg2umOdn9rJGbnKAHiOrkQRJjtpjmpWI81T(S5RulbcuBlQNTMpllFY8oJYg0pLI6mQnk1w4ba08zz5tM3zu2GMNe1Ac1gLAnKADgfeShOwIuBKulbcuRHulsgM)qE266c51NTEsQLtQfAdO2OulsgM)qE2AHXc6jPwoPwOnGAnHAnbdkUE2edcCLhXhmIBm5XfZbg8PuuNHnfd6qtF0iyqX1dK7F(68a1Yj1YEyqN5Bbb7DGAjqGArYW8hYZwlmwqpj1Yj1gxdWGIRNnXGax5lccjWoUXKhFmhyWNsrDg2umOdn9rJGbHiOrkQRlkHDpts3XGIRNnXGSlTrFi2pjCJj3myoWGIRNnXGtTUkPNn9cpsWGpLI6mSP4gto3J5ad(ukQZWMIbDOPpAemizulebnsrDDmz6jH5bwKVU1NnFLAJsTgsTIRhi3)815bQLtQL9WGoZ3cc27a1sGa1IKH5pKNTwySGEsQLtQfAdOwtWGIRNnXGWuYa5((vsp04gto3bZbg8PuuNHnfd6qtF0iyq3Mm(P1HJqsFMhMsgix)ukQZO2OuRBxfBJL6d)9Llvn6vzYa1YnQL7P2OulzuBHhaqxFl1frY4gMGMNe1gLAjJAzVWdaOFCqAdN5JT8jtZtcdkUE2ed2grBmpmLmqoUXKB2WCGbFkf1zytXGo00hncguC9a5(NVopqTCsTqtTrPwdPwYOwKmm)H8S1cJf0poMqhOwceOwKmm)H8S1cJf08KOwtO2OulzulebnsrDDmz6jH5bwKVU1NnFfdkUE2edE4VVCPIBm5XjmhyWNsrDg2umOdn9rJGbHiOrkQRlkHDpts3XGIRNnXGfLWUNjP74gto0gG5ad(ukQZWMIbDOPpAemiapcEn7aJBAQLtIuB8nadkUE2edcCvrjSJBm5qdnMdm4tPOodBkg0HM(OrWGKrTTOE26IAsMhGhbV(PuuNrTrPwYOwicAKI66yY0tcZdSi)dHNU7lOlqHAJsTizy(d5zRfglONKA5KAfxpB6D7QyBSedkUE2edE4VVCPIBm5qhjMdm4tPOodBkg0HM(OrWGgsTTOE2A2RB6lkH9G(PuuNrTeiqTKrTqe0if11XKPNeMhyr(6wF28vQLabQfGhbVMDGXnn1YnQnUgqTeiqTfEaaD9TuxejJBycA0RYKbQLBuRzOwtO2OulzulebnsrDnPDvtcZdSiFrjS7zs6o1gLAjJAHiOrkQRJjtpjmpWI8peE6UVGUafmO46ztmOK5yCuspBIBm5qhxmhyWNsrDg2umOdn9rJGbnKABr9S1Sx30xuc7b9tPOoJAjqGAjJAHiOrkQRJjtpjmpWI81T(S5RulbculapcEn7aJBAQLBuBCnGAnHAJsTKrTqe0if11K2vnjmpWI813c1gLAjJAHiOrkQRjTRAsyEGf5lkHDpts3P2OulzulebnsrDDmz6jH5bwK)HWt39f0fOGbfxpBIbDgLn4dnAGYXnMCOJpMdm4tPOodBkg0HM(OrWGTOE26IAsMhGhbV(PuuNrTrPwKmm)H8S1cJf0tsTCsTIRNn9UDvSnwIbfxpBIbp83xUuXnMCOndMdm4tPOodBkguC9SjgK96MbFz6JbDOPpAemiIppWIGDDHhLtcZhB5tM(PuuNrTrPw2l8aa6cpkNeMp2YNmn6vzYa1YnQn(yqh8o19TGG9oGjhACJjhAUhZbguC9SjgK96MbFz6JbFkf1zytXnMCO5oyoWGpLI6mSPyqhA6Jgbdsg12I6zRRB9zZx1pLI6mQnk1IKH5pKNTUUqE9zRNKA5KADgfeShOwOEQfAdO2OuBlQNTM96M(IsypOFkf1zyqX1ZMyqGR8i(GrCJjhAZgMdm4tPOodBkg0HM(OrWG1fYRpBnBcTKUtTCsTqBgQLabQTWdaOx(2VaEKKWUMNeguC9Sjge4QIsyh3yYHooH5ad(ukQZWMIbDOPpAemyDH86ZwZMqlP7ulNul0MHAjqGAnKAl8aa6LV9lGhjjSR5jrTrPwYO2wupBDDRpB(Q(PuuNrTMGbfxpBIbbUYJ4dgXnM8inaZbg8PuuNHnfd6qtF0iyW6c51NTMnHws3PwoPwOndguC9SjgeYtyhGx5rVrxACJjpsOXCGbFkf1zytXGo00hncgSf1ZwZEDtFrjSh0pLI6mmO46ztmyBeTX8WuYa54g3yWhcpDpG5ato0yoWGpLI6mSPyWLegm8gdkUE2edcrqJuuhdcru8hd62vX2yPg4kFrqib21Olm4P2OuRHuRHuRHulzuBlQNTM96MJt)ukQZOwceO2cpaGU(wQlIKXnmbnpjQ1eQnk1sg1crqJuuxhtMEsyEGf5RB9zZxP2OulsgM)qE2AHXc6jPwoP24Aa1Ac1sGa1kUEGC)ZxNhOwoPw2dd6mFliyVduRjyqhA6Jgbd2I6zRbUYxeesGD9tPOoddcrq(uQhdcCLViiKa7(a8Pd3yYJeZbg8PuuNHnfd6qtF0iyqdPwYOw22A3MUNns6Z8akPEFHhL6ECqzsyuBuQLmQvC9SP2TP7zJK(mpGsQxpPhqnWm2ulbculaVs5r3zuqWUVN6PwUrTWCmDvIdQ1emO46ztmOBt3Zgj9zEaLupUXKhxmhyWNsrDg2umOdn9rJGbnKAjJABr9S1ax5lccjWU(PuuNrTeiqTUDvSnwQbUYxeesGDn6vzYa1Yj1gFZqTMqTrPwYOwicAKI66yY0tcZdSiFDRpB(k1gLAnKAnKAjJABr9S1Sx3CC6NsrDg1sGa1w4ba013sDrKmUHjO5jrTrPwYOw3Uk2gl1fLWUNjP7A0fg8uRjulbculWaZy7rVktgOwUrKAH2aQ1emO46ztmyrTlZVa(249pFfECJjp(yoWGpLI6mSPyqhA6Jgbd2I6zRbUYxeesGD9tPOoJAJsTqe0if11ax5lccjWUpaF6WGIRNnXGf1Um)c4BJ3)8v4XnMCZG5ad(ukQZWMIbDOPpAemOHuBHhaqxFl1frY4gMGMNe1gLAD7QyBSuxFl1frY4gMGgDHbp1Ac1sGa1w4ba013sDrKmUHjOrVktgOwoP2ind1sGa1cmWm2E0RYKbQLBeP24AaguC9SjgegVGyJK(fWlXZrBBe3yY5EmhyWNsrDg2umOdn9rJGbdKUs5Bbb7Dqxuc7EMKUdn1YjrQnsQLabQfjdZFipBTWyb9KulNul3BaguC9SjgeyD8HZ8s8C003xUuXnMCUdMdm4tPOodBkg0HM(OrWGbsxP8TGG9oOlkHDpts3HMA5Ki1gj1sGa1IKH5pKNTwySGEsQLtQL7nadkUE2edsIhnaWpjmFrjHg3yYnByoWGpLI6mSPyqhA6Jgbdw4ba0O7GI6HGhyrUR5jrTeiqTfEaan6oOOEi4bwK7E3YN9r6qloOqTCJAH2amO46ztmyB8E(SS8jZdSi3XnM84eMdmO46ztmiAirsD)K(ajXDm4tPOodBkUXKdTbyoWGpLI6mSPyqhA6Jgbdw4ba013sDrKmUHjO5jrTeiqTqe0if11ax5lccjWUpaF6WGIRNnXGXwKIb5t6rpSPKUJBm5qdnMdm4tPOodBkg0HM(OrWGa8i4PwUrTX3aQnk1w4ba013sDrKmUHjO5jHbfxpBIbRVUi49lGxX7gMNHUud4gto0rI5ad(ukQZWMIbfxpBIbrxinjmpGsQpGbDOPpAemyliyV19uVVxpBo1YnQfATzOwceOwdPwdP2wqWERnEr1g1KCn1Yj1A2mGAjqGABbb7T24fvButY1ul3isTrAa1Ac1gLAnKAfxpqU)5RZdulrQfAQLabQTfeS36EQ33RNnNA5KAJmorTMqTMqTeiqTgsTTGG9w3t9(E9KCTpsdOwoP24Aa1gLAnKAfxpqU)5RZdulrQfAQLabQTfeS36EQ33RNnNA5KAJF8PwtOwtWGo4DQ7Bbb7Dato04g3yq2beEvJ5ato0yoWGIRNnXGSjG4j1yWNsrDg2uCJjpsmhyqX1ZMyq3Mb(69vb24WGpLI6mSP4gtECXCGbFkf1zytXGljmy4nguC9SjgeIGgPOogeIO4pgSf1ZwdmOq7lQDz6NsrDg1sGa1giDLY3cc27GUOe29mjDhAQLtIuRHuBCPwZsQTf1Zw3izu(fWJ4Nu)ukQZOwtOwceOweFEGfb7ANrzd(24xe86NsrDg1gLAl8aaANrzd(24xe8A2glXGqeKpL6XGfLWUNjP74gtE8XCGbFkf1zytXGljmy4nguC9SjgeIGgPOogeIO4pgKmQTf1ZwZEDZXPFkf1zuBuQ1TRITXsD9TuxejJBycA0RYKbQLBul3tTrPwaEe8A2bg30ulNuBCnadcrq(uQhdsAx1KW8alYxFl4gtUzWCGbFkf1zytXGljmy4nguC9SjgeIGgPOogeIO4pgeIGgPOUUOe29mjDNAJsTgsTa8i4PwUrTChZqTMLuBlQNTgyqH2xu7Y0pLI6mQfQNAJ0aQ1emieb5tPEmiPDvtcZdSiFrjS7zs6oUXKZ9yoWGpLI6mSPyWLegm8gdkUE2edcrqJuuhdcru8hd2I6zRzVU540pLI6mQnk1sg12I6zRlQjzEaEe86NsrDg1gLAD7QyBSuF4VVCPQrVktgOwUrTgsTWCmDvIdQfQNAJKAnHAJsTa8i41SdmUPPwoP2inadcrq(uQhdsAx1KW8alYF4VVCPIBm5ChmhyWNsrDg2um4scdgEJbfxpBIbHiOrkQJbHik(JbBr9S1peE6UVGUaf9tPOoJAJsTKrTqe0if11K2vnjmpWI8fLWUNjP7uBuQLmQfIGgPOUM0UQjH5bwKV(wO2OuRBxfBJL6hcpD3xqxGIMNegeIG8PupgmMm9KW8alY)q4P7(c6cuWnMCZgMdm4tPOodBkgCjHbdVXGIRNnXGqe0if1XGqef)XGTOE266wF28v9tPOoJAJsTKrTfEaaDDRpB(QMNegeIG8PupgmMm9KW8alYx36ZMVIBm5XjmhyWNsrDg2umOdn9rJGbH5yA0RYKbQLi1AaguC9Sjg0jkLxC9SPxnHgdQMq7tPEmOBxfBJL4gto0gG5ad(ukQZWMIbDOPpAemyHhaqdCLVS1IGy1NTo0IdkulrQ1muBuQ1qQTWdaONADvspB6fEKO5jrTeiqTKrTfEaaD9TuxejJBycAEsuRjyqX1ZMyW2iAJ5HPKbYXnMCOHgZbg8PuuNHnfd6qtF0iyWwupB9dHNU7lOlqr)ukQZO2OuRHulebnsrDDmz6jH5bwK)HWt39f0fOqTeiqTSx4ba0peE6UVGUafnpjQ1emO46ztmOtukV46ztVAcngunH2Ns9yWhcpD3xqxGcUXKdDKyoWGpLI6mSPyqhA6Jgbd2I6zRzVU540pLI6mmO46ztmiIp9IRNn9Qj0yq1eAFk1JbzVU54WnMCOJlMdm4tPOodBkguC9SjgeXNEX1ZME1eAmOAcTpL6XG5IQIc34gdscD3wlsJ5ato0yoWGpLI6mSPyWuQhdkXtWOGKGhyZ2VaEsBSJWGIRNnXGs8emkij4b2S9lGN0g7iCJBmi71nhhMdm5qJ5ad(ukQZWMIbDOPpAemOHuBlQNTMpllFY8oJYg0pLI6mQnk1w4ba08zz5tM3zu2GMNe1Ac1gLAnKADgfeShOwIuBKulbcuRHulsgM)qE266c51NTEsQLtQfAdO2OulsgM)qE2AHXc6jPwoPwOnGAnHAnbdkUE2edcCLhXhmIBm5rI5ad(ukQZWMIbDOPpAemiebnsrDDrjS7zs6oguC9SjgKDPn6dX(jHBm5XfZbg8PuuNHnfd6qtF0iyqX1dK7F(68a1Yj1YEyqN5Bbb7DGAjqGArYW8hYZwlmwqpj1Yj1cTbyqX1ZMyqykzGCF)kPhACJjp(yoWGpLI6mSPyqhA6Jgbd62KXpToCes6Z8WuYa56NsrDg1gLAD7QyBSuF4VVCPQrVktgOwUrTCp1gLAjJAl8aa66BPUisg3We08KO2Oulzul7fEaa9JdsB4mFSLpzAEsyqX1ZMyW2iAJ5HPKbYXnMCZG5ad(ukQZWMIbDOPpAemisgM)qE2AHXcAEsulbculsgM)qE2AHXc6jPwoP2indguC9Sjg8WFF5sf3yY5EmhyWNsrDg2umOdn9rJGbHiOrkQRlkHDpts3P2OulzuRBxfBJL66BPUisg3We0Olm4P2OuRHuRBxfBJL6d)9Llvn6vzYa1Yj1AgQLabQ1qQfjdZFipBTWyb9KulNuR46ztVBxfBJLuBuQfjdZFipBTWyb9Kul3O2ind1Ac1AcguC9SjgSOe29mjDh3yY5oyoWGIRNnXGtTUkPNn9cpsWGpLI6mSP4gtUzdZbg8PuuNHnfd6qtF0iyqYOwicAKI6As7QMeMhyr(Isy3ZK0DmO46ztmOK5yCuspBIBm5XjmhyWNsrDg2umOdn9rJGbb4rWRzhyCttTCsKAJVbyqX1ZMyqGRkkHDCJjhAdWCGbFkf1zytXGo00hncgKmQfIGgPOUM0UQjH5bwKVOe29mjDNAJsTKrTqe0if11K2vnjmpWI8h(7lxQyqX1ZMyqNrzd(qJgOCCJjhAOXCGbFkf1zytXGo00hncgSf1ZwZEDtFrjSh0pLI6mQnk1sg162vX2yP(WFF5svJUWGNAJsTgsToJcc2dulrQnsQLabQ1qQfjdZFipBDDH86Zwpj1Yj1cTbuBuQfjdZFipBTWyb9KulNul0gqTMqTMGbfxpBIbbUYJ4dgXnMCOJeZbg8PuuNHnfdkUE2edYEDZGVm9XGo00hncgeXNhyrWUUWJYjH5JT8jt)ukQZO2Oul7fEaaDHhLtcZhB5tMg9QmzGA5g1gFmOdEN6(wqWEhWKdnUXKdDCXCGbfxpBIbzVUzWxM(yWNsrDg2uCJjh64J5ad(ukQZWMIbDOPpAemyHhaqV8TFb8ijHDnpjmO46ztmyBeTX8WuYa54gto0MbZbg8PuuNHnfd6qtF0iyW6c51NTMnHws3PwoPwOnd1sGa1w4ba0lF7xapssyxZtcdkUE2edcCLhXhmIBm5qZ9yoWGpLI6mSPyqhA6JgbdwxiV(S1Sj0s6o1Yj1cTzWGIRNnXGqEc7a8kp6n6sJBm5qZDWCGbFkf1zytXGo00hncgSf1ZwZEDtFrjSh0pLI6mmO46ztmyBeTX8WuYa54g3yWhcpD3xqxGcMdm5qJ5ad(ukQZWMIbDOPpAemiapcEQLtIuRzZaQnk1Ai162vX2yPUOe29mjDxJUWGNAjqGAjJAHiOrkQRlkHDpts3PwtWGIRNnXGpeE6UVGUafCJjpsmhyWNsrDg2umOdn9rJGbHiOrkQRlkHDpts3P2Oul7fEaa9dHNU7lOlqrZtcdkUE2edYU0g9Hy)KWnM84I5ad(ukQZWMIbDOPpAemiebnsrDDrjS7zs6o1gLAzVWdaOFi80DFbDbkAEsyqX1ZMyWIsy3ZK0DCJjp(yoWGpLI6mSPyqhA6JgbdYEHhaq)q4P7(c6cu08KWGIRNnXGsMJXrj9SjUXKBgmhyWNsrDg2umOdn9rJGbzVWdaOFi80DFbDbkAEsyqX1ZMyqNrzd(qJgOCCJBmOBxfBJLyoWKdnMdm4tPOodBkg0HM(OrWGKrTgsTTOE2A2RBoo9tPOoJAjqGAHiOrkQRjTRAsyEGf5RVfQ1eQnk1Ai1sg16wipLS1qE2gHhrTeiqTKrTST1Hjb4v(cssMUhhuMeg1Ac1sGa1cmWm2E0RYKbQLBuBKMbdkUE2edwFl1frY4gMaUXKhjMdm4tPOodBkg0HM(OrWGTOE2A2RBoo9tPOoJAJsTgsTUDvSnwQp83xUu1OxLjdulNuBKgqTrPwdPwYOwicAKI66Isy3ZK0DQLabQ1TRITXsDrjS7zs6Ug9QmzGA5KAH5y6QehuRjuRjuBuQ1qQLmQ1TqEkzRH8SncpIAjqGAjJAzBRdtcWR8fKKmDpoOmjmQ1emO46ztmy9TuxejJByc4gtECXCGbFkf1zytXGo00hncgKmQLTTomjaVYxqsY094GYKWWGIRNnXGHjb4v(cssgUXKhFmhyWNsrDg2umOdn9rJGbjJABr9S1Sx3CC6NsrDg1gLAjJAHiOrkQRJjtpjmpWI81T(S5RulbcuBHhaqdWJMLp4HjXZ18KWGIRNnXGTX7nYNnUXKBgmhyqX1ZMyqGLXoY3RVnEpGsQhd(ukQZWMIBm5CpMdmO46ztm4vWhgj9S7q)yWNsrDg2uCJjN7G5ad(ukQZWMIbDOPpAemyHhaqxFl1frY4gMGg9QmzGA5KAJ0mulbculWaZy7rVktgOwUrTCVbyqX1ZMyqsBpBIBm5MnmhyWNsrDg2umO46ztmimrDNOuhf8LDtmOdn9rJGbjJABr9S1ax5lccjWU(PuuNrTeiqTUDvSnwQbUYxeesGDn6cdEmyk1JbHjQ7eL6OGVSBIBm5XjmhyWNsrDg2umO46ztmOdENAB0MJZxusOXGo00hncgSWdaORVL6IizCdtqZtIAJsTfEaaD91fbVFb8kE3W8m0LAqZ2yj1gLAnKAjJAHiOrkQRlkHDpts3PwceOwYOw3Uk2gl1fLWUNjP7A0fg8uRjyWdaCx7tPEmOdENAB0MJZxusOXnMCOnaZbg8PuuNHnfdkUE2edkbJqK8bpsINf5DlsuyqhA6JgbdYEHhaqJK4zrE3IeLN9cpaGMTXsQLabQ1qQL9cpaG2TjJ31dK7NekE2l8aaAEsulbcuBHhaqxFl1frY4gMGg9QmzGA5KAJ0aQ1eQnk12cc2BTXlQ2OMKRPwUrTXfAQLabQfyGzS9OxLjdul3O2inadMs9yqjyeIKp4rs8SiVBrIc3yYHgAmhyWNsrDg2umO46ztmOepbJcscEGnB)c4jTXocd6qtF0iyq3Uk2gl113sDrKmUHjOrVktgOwUrTqBa1sGa162vX2yPU(wQlIKXnmbn6vzYa1Yj1Y9gGbtPEmOepbJcscEGnB)c4jTXoc3yYHosmhyWNsrDg2umOdn9rJGbl8aa66BPUisg3We08KWGIRNnXG8H7N(1aUXKdDCXCGbFkf1zytXGIRNnXGorP8IRNn9Qj0yq1eAFk1JbFi809aUXnUXGcFBCryqWPc1GBCJXa]] )
end
