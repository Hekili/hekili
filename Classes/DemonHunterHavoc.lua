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


    spec:RegisterPack( "Havoc", 20201213, [[dCKG7aqiuHhjLiTjPOpjfYOOKCkkPwLuI4vuknluj3cvuyxK6xsbddvvhdsSmLeptkutJsbxdvKTrPiFtkrnokfLZrPqSoLKQ5jLW9qs7dj6GOIsTquvEiLIQjQKKCrkfQ6JOIIgPssQtQKewPsQzQKeTtiPLsPq6Pk1urcFfvuYyvsk7f0FfAWuCyIflYJfmzexw1MH4ZqQrtP60sETusZMKBlv7MQFdmCuLJtPqz5q9CrnDfxhP2Us8DPuJhvuDEuPwpLcvMpLy)OmefifWnrMdrDf(xHFuwbLgRrHFoTsJ5eCpCZ7Wnpj0QG(WTl9d3RAzbeGBEc3kGqGua3zanoC4ExDALmfWT5ybzG7eDPMvHdtWnrMdrDf(xHFuwbLgRrHFoTc)TmCN59aevo1YTmCBViK7WeCtEoa3TuMzv9oWzMvnTphZmRAzbeyRBPmZQ6H3thZmO0yUyMv4Ff(HBEyasPoC3szMv17aNzw10(CmZSQLfqGTULYmRQhEpDmZGsJ5IzwH)v4NTMTwctb8SMh(bqpjd1eyg1jreLW9jTlhDCaCE5S1S1TuMXgpN)a9CcZ8LJ5MzMQFMzSFMrcdaZmvMzKfPussDnBTeMc4zQKkJP5nS1sykGNTLAdbGNP7p2f0vGTwctb8STuByrWLKuNlx6NAsjKhjIhoxlII(uhrDF0ifopXKcai67ssDIflzExPIJGr)jRtkH8ir8WrHsQw1yodRgrDF0dwkveGeX0LRVlj1j2MOrq09pshG5zhKRSMMN1wBXcM2pcaJ(6GDbKJJ9dWC3mrJGOd2fqoo2paZTMaA7S1sykGNTLAdlcUKK6C5s)u5baQYrhra4y)JW1IOOpvogrDF0K3bEf03LK6KMbaqraTDD)J0byE2b5kRXVlLNBHn1eHgZTMCKkudLnMF2AjmfWZ2sTHfbxssDUCPFQ8aav5OJiaCmPeYJeXdNRfrrFQlcUKK66Ksipsep8MwHqJ5UfTmN4mgrDF0ifopXKcai67ssDslzf(TMTwctb8STuByrWLKuNlx6Nkpaqvo6icahp3pMU05Aru0N6iQ7JM8oWRG(UKuN0KJru3hDsvojIqJ5wFxsQtAgaafb021N7htx6A87s55wyf6ar3foVLSI1nrOXCRjhPc1q5k8ZwlHPaE2wQnSi4ssQZLl9tTTut5OJiaC8589WJj8Lw5Aru0N6iQ7J(589WJj8Lw13LK6KMCSi4ssQR5baQYrhra4ysjKhjIhEtoweCjj118aav5OJiaCS)rAgaafb021pNVhEmHV0QMMhBTeMc4zBP2WIGljPoxU0p12snLJoIaWXoOFFO7CTik6tDe19r3b97dDxFxsQtAYrIgbr3b97dDxtZJTwctb8STuBiikvuctb8OQYdxU0p1aaOiG2oxfcv0bIg)UuEMk)S1sykGNTLAdJDmODeTsQLZvHqnrJGOrUkMa9KGj97JopsOvQCQPvjAeeD17aLmfWJcnw008SyHJencIU)r6amp7GCL108SMTwctb8STuBiikvuctb8OQYdxU0p1NZ3dpMWxALRcH6iQ7J(589WJj8Lw13LK6KMwTi4ssQRBl1uo6icahFoFp8ycFPvlwiprJGOFoFp8ycFPvnnpRzRLWuapBl1gW0Euctb8OQYdxU0pvY7aVcCviuhrDF0K3bEf03LK6e2AjmfWZ2sTbmThLWuapQQ8WLl9t1b4UOyRzRLWuapRdaGIaA7u7FKoaZZoixzUkeQCy1iQ7JM8oWRG(UKuNyXYIGljPUMhaOkhDebGJ9pI1ndaGIaA76Z9JPlDn(DP8mLRWFtR4iawUl(OxUp25gRVlj1jwSWbbm6C5i0QyclorpvO1YrBTflifA7te)UuEUfRWj2AjmfWZ6aaOiG2UTuBO)r6amp7GCL5QqOoI6(OjVd8kOVlj1jnTkaakcOTRp3pMU0143LYZuUc)nTIJfbxssDDsjKhjIhUflbaqraTDDsjKhjIhUg)UuEMs0bIUlCU1w30kocGL7Ip6L7JDUX67ssDIflCqaJoxocTkMWIt0tfATC0wZwlHPaEwhaafb02TLAd5YrOvXewCcxfcvoiGrNlhHwftyXj6PcTwoA2AjmfWZ6aaOiG2UTuByS)ODAF4QqOYXiQ7JM8oWRG(UKuN0KJfbxssDDBPMYrhra4yh0Vp0Dlws0iiAeACbOZr0InURP5XwlHPaEwhaafb02TLAdiac544aIJ9hrus)S1sykGN1baqraTDBP2WvCNlXJKhW)CviuTsctT8493RNPK8CHpjocg9NSflyPiXVCF0cHK1LtzJ53A2AjmfWZ6aaOiG2UTuBGhykGZvHqnrJGO7FKoaZZoixzn(DP8mLRWjlwqk02Ni(DP8ClSj(zRBPmZQ6icTAygerPssOvMbbGzg6SKuNzQ59SMTwctb8SoaakcOTBl1gOZpwZ7zUkeQjAeeD)J0byE2b5kRP5XwZwlHPaEwtEh4vGkYvrmD2oxfcvRgrDF00Ecq7KyWUaY67ssDsZencIM2taANed2fqwtZZ6MwfSly0ptDflwSclfj(L7JUdwE)(OlNsu4Vjwks8l3hTqizD5uIc)wBnBTeMc4zn5DGxbBP2a5YypMB)ZJRcH6IGljPUoPeYJeXdNTwctb8SM8oWRGTuBaTsQLhN3598WvHqvctT8493RNPK8CHpjocg9NSflyPiXVCF0cHK1Ltjk8ZwlHPaEwtEh4vWwQnm2XG2r0kPwoxfc1aWj01OZhJL5KiALulxFxsQtAgaafb021N7htx6A87s55wytn5irJGO7FKoaZZoixznnVMCqEIgbrFoNhiFsSnG2jAAES1sykGN1K3bEfSLAdN7htx6CviuXsrIF5(OfcjRP5zXcwks8l3hTqizD5uUcNyRLWuapRjVd8kyl1gskH8ir8W5QqOUi4ssQRtkH8ir8WBYraaueqBx3)iDaMNDqUYA8fc3nTkaakcOTRp3pMU0143LYZuYjlwSclfj(L7JwiKSUCkdaGIaA7nXsrIF5(OfcjRlVfRWjRTMTwctb8SM8oWRGTuBO6DGsMc4rHglS1sykGN1K3bEfSLAdI7L9sjtbCUkeQCSi4ssQR5baQYrhra4ysjKhjIhoBTeMc4zn5DGxbBP2aYvjLqoxfcveAm3AYrQqnus1g4NTwctb8SM8oWRGTuBiyxa5yEWvRNRcHkhlcUKK6AEaGQC0reaoMuc5rI4H3KJfbxssDnpaqvo6icahp3pMU0zRLWuapRjVd8kyl1gqUkIPZ25QqOoI6(OjVd8ysjKN13LK6KMCeaafb021N7htx6A8fc3nTkyxWOFM6kwSyfwks8l3hDhS8(9rxoLOWFtSuK4xUpAHqY6YPef(T2A2AjmfWZAY7aVc2sTbY7apht1CUcChupocg9Nmvu4QqOIP9JaWOVorJ9YrhBdODstYt0ii6en2lhDSnG2jA87s55wydS1sykGN1K3bEfSLAdK3bEoMQ5S1sykGN1K3bEfSLAdJDmODeTsQLZvHqnrJGOb0teGeXIJ(AAES1sykGN1K3bEfSLAdixfX0z7Cviu7GL3VpAsLhXdNsu4KfljAeenGEIaKiwC0xtZJTwctb8SM8oWRGTuBy5o6JqRI4p4ldxfc1oy597JMu5r8WPefoXwlHPaEwtEh4vWwQnm2XG2r0kPwoxfc1ru3hn5DGhtkH8S(UKuNWwZwlHPaEw)C(E4Xe(sRuFoFp8ycFPvUkeQi0yUPKQnJ)Mwfaafb021jLqEKiE4A8fc3wSWXIGljPUoPeYJeXd3A2AjmfWZ6NZ3dpMWxA1wQnqUm2J52)84QqOUi4ssQRtkH8ir8WBsEIgbr)C(E4Xe(sRAAES1sykGN1pNVhEmHV0QTuBiPeYJeXdNRcH6IGljPUoPeYJeXdVj5jAee9Z57Hht4lTQP5XwlHPaEw)C(E4Xe(sR2sTbX9YEPKPaoxfcvYt0ii6NZ3dpMWxAvtZJTwctb8S(589WJj8LwTLAdb7cihZdUA9CviujprJGOFoFp8ycFPvnnp2A2AjmfWZAhG7II6YD0hHwfXFWxgUkeQJOUp6oOFFO767ssDsZencIMh(8e8jAcOT3CQ(Pef2AjmfWZAhG7IYwQnGCvetNTZvHq1QfbxssDDBPMYrhra4yh0Vp0DlwgrDF00Ecq7KyWUaY67ssDsZencIM2taANed2fqwtZZ6MwfSly0ptDflwSclfj(L7JUdwE)(OlNsu4Vjwks8l3hTqizD5uIc)wBnBTeMc4zTdWDrzl1gqUkMemwqFUkeQsyQLhV)E9mLKNl8jXrWO)KTyblfj(L7JwiKSUCkBm)S1sykGN1oa3fLTuBGCzShZT)5XvHqDrWLKuxNuc5rI4HZwlHPaEw7aCxu2sTHQ3bkzkGhfASWwlHPaEw7aCxu2sTb0kPwECEN3ZdxfcvoweCjj11TLAkhDebGJDq)(q3BALeMA5X7Vxptj55cFsCem6pzlwWsrIF5(OfcjRlNsu43A2AjmfWZAhG7IYwQnm2XG2r0kPwoxfc1aWj01OZhJL5KiALulxFxsQtAgaafb021N7htx6A87s55wytn5irJGO7FKoaZZoixznnVMCqEIgbrFoNhiFsSnG2jAAES1sykGN1oa3fLTuB4C)y6sNRcHkhlcUKK662snLJoIaWXoOFFO7nTsctT8493RNPK8CHpjocg9NSflyPiXVCF0cHK1LtjkCYA2AjmfWZAhG7IYwQnKuc5rI4HZvHqDrWLKuxNuc5rI4HZwlHPaEw7aCxu2sTbKRskHCUkeQi0yU1KJuHAOKQnWpBTeMc4zTdWDrzl1ge3l7LsMc4CviuTAe19rtEh4XKsipRVlj1jwSWXIGljPUUTut5OJiaCSd63h6Ufli0yU1KJuHAArJ53ILencIU)r6amp7GCL143LYZTGtw3KJfbxssDnpaqvo6icahtkH8ir8WBYXIGljPUUTut5OJiaC8589WJj8LwzRLWuapRDaUlkBP2qWUaYX8GRwpxfcvRgrDF0K3bEmPeYZ67ssDIflCSi4ssQRBl1uo6icah7G(9HUBXccnMBn5ivOMw0y(TUjhlcUKK6AEaGQC0reao2)in5yrWLKuxZdauLJoIaWXKsipsep8MCSi4ssQRBl1uo6icahFoFp8ycFPv2AjmfWZAhG7IYwQnCUFmDPZvHqDe19rNuLtIi0yU13LK6KMyPiXVCF0cHK1LtzaaueqBNTwctb8S2b4UOSLAdK3bEoMQ5Cf4oOECem6pzQOWvHqft7hbGrFDIg7LJo2gq7KMKNOrq0jASxo6yBaTt043LYZTWgyRLWuapRDaUlkBP2a5DGNJPAoBTeMc4zTdWDrzl1gqUkIPZ25QqOYXiQ7JUd63h6U(UKuN0elfj(L7JUdwE)(OlNYGDbJ(5wck83Ce19rtEh4XKsipRVlj1jS1sykGN1oa3fLTuBa5QKsiNRcHAhS8(9rtQ8iE4uIcNSyjrJGOb0teGeXIJ(AAES1sykGN1oa3fLTuBa5QiMoBNRcHAhS8(9rtQ8iE4uIcNSyXQencIgqpraselo6RP51KJru3hDh0Vp0D9DjPoXA2AjmfWZAhG7IYwQnSCh9rOvr8h8LHRcHAhS8(9rtQ8iE4uIcNyRLWuapRDaUlkBP2WyhdAhrRKA5CviuhrDF0K3bEmPeYZ67ssDcCVCCUaoe1v4Ff(rzf(Bz4UTG9YrNHBoloBBuuxfOYzU6mdZqH9ZmvNhapmdcaZmnYb4UOAeZGVngDHpHzYG(zgHEaDzoHzc2fh9ZA26vz5NzqXgwDMXMd8LJNtyMgHP9JaWOVE1AeZmaMPryA)iam6Rxn9DjPoPrmJvOW5wRzRzR5S4STrrDvGkN5QZmmdf2pZuDEa8WmiamZ0iYreA10iMbFBm6cFcZKb9Zmc9a6YCcZeSlo6N1S1RYYpZ04vNzS5aF545eMPryA)iam6RxTgXmdGzAeM2pcaJ(6vtFxsQtAeZyfkCU1A2A2AoloBBuuxfOYzU6mdZqH9ZmvNhapmdcaZmnkaakcOT3iMbFBm6cFcZKb9Zmc9a6YCcZeSlo6N1S1RYYpZGYQZm2CGVC8CcZ0Oay5U4JE103LK6KgXmdGzAuaSCx8rVAnIzScfo3AnB9QS8ZmRS6mJnh4lhpNWmnkawUl(Oxn9DjPoPrmZayMgfal3fF0RwJygRqHZTwZwZwZzXzBJI6QavoZvNzygkSFMP68a4HzqayMPrK3bEfAeZGVngDHpHzYG(zgHEaDzoHzc2fh9ZA26vz5NzqzLvNzS5aF545eMPryA)iam6RxTgXmdGzAeM2pcaJ(6vtFxsQtAeZyfkCU1A2A26vrNhapNWm2eZiHPaoZOQ8K1S1WTqp2by4ExDBoCRQ8KHua3oa3ffKciQOaPaUVlj1jq(G7aUMJlbUhrDF0Dq)(q313LK6eMPjZKOrq08WNNGprtaTDMPjZmv)mdLmdkWTeMc4W9YD0hHwfXFWxg4arDfifW9DjPobYhChW1CCjWTvmZIGljPUUTut5OJiaCSd63h6oZyXcZmI6(OP9eG2jXGDbK13LK6eMPjZKOrq00Ecq7KyWUaYAAEmJ1mttMXkMjyxWOFMzOYmRWmwSWmwXmyPiXVCF0DWY73hD5mdLmdk8ZmnzgSuK4xUpAHqY6Yzgkzgu4NzSMzSgULWuahUrUkIPZ2Hde1gdPaUVlj1jq(G7aUMJlbULWulpE)96zMHsMH8CHpjocg9NmZyXcZGLIe)Y9rleswxoZqjZ0y(HBjmfWHBKRIjbJf0hoquTbifW9DjPobYhChW1CCjW9IGljPUoPeYJeXdhULWuahUjxg7XC7FEWbIkNGua3sykGd3vVduYuapk0ybUVlj1jq(GdevBcsbCFxsQtG8b3bCnhxcCZbZSi4ssQRBl1uo6icah7G(9HUZmnzgRygjm1YJ3FVEMzOKzipx4tIJGr)jZmwSWmyPiXVCF0cHK1LZmuYmOWpZynClHPaoCJwj1YJZ78EEGde1wgsbCFxsQtG8b3bCnhxcChaoHUgD(ySmNerRKA567ssDcZ0KzcaGIaA76Z9JPlDn(DP8mZ0cMXMyMMmdhmtIgbr3)iDaMNDqUYAAEmttMHdMH8encI(Copq(KyBaTt008GBjmfWH7Xog0oIwj1YHdevBgKc4(UKuNa5dUd4AoUe4MdMzrWLKux3wQPC0reao2b97dDNzAYmwXmsyQLhV)E9mZqjZqEUWNehbJ(tMzSyHzWsrIF5(OfcjRlNzOKzqHtmJ1WTeMc4W95(X0LoCGOAJaPaUVlj1jq(G7aUMJlbUxeCjj11jLqEKiE4WTeMc4WDsjKhjIhoCGOIc)qkG77ssDcKp4oGR54sGBeAm3AYrQqnmdLuzgBGF4wctbC4g5QKsihoqurbfifW9DjPobYhChW1CCjWTvmZiQ7JM8oWJjLqEwFxsQtyglwygoyMfbxssDDBPMYrhra4yh0Vp0DMXIfMbHgZTMCKkudZ0cMPX8ZmwSWmjAeeD)J0byE2b5kRXVlLNzMwWmCIzSMzAYmCWmlcUKK6AEaGQC0reaoMuc5rI4HZmnzgoyMfbxssDDBPMYrhra44Z57Hht4lTc3sykGd3I7L9sjtbC4arfLvGua33LK6eiFWDaxZXLa3wXmJOUpAY7apMuc5z9DjPoHzSyHz4GzweCjj11TLAkhDebGJDq)(q3zglwygeAm3AYrQqnmtlyMgZpZynZ0Kz4GzweCjj118aav5OJiaCS)ryMMmdhmZIGljPUMhaOkhDebGJjLqEKiE4mttMHdMzrWLKux3wQPC0reao(C(E4Xe(sRWTeMc4WDWUaYX8GRwpCGOIsJHua33LK6eiFWDaxZXLa3JOUp6KQCseHgZT(UKuNWmnzgSuK4xUpAHqY6YzgkzgjmfWJbaqraTD4wctbC4(C)y6shoqurXgGua33LK6eiFWTeMc4Wn5DGNJPAoChW1CCjWnM2pcaJ(6en2lhDSnG2j67ssDcZ0KziprJGOt0yVC0X2aANOXVlLNzMwWm2aCh4oOECem6pziQOahiQOWjifWTeMc4Wn5DGNJPAoCFxsQtG8bhiQOytqkG77ssDcKp4oGR54sGBoyMru3hDh0Vp0D9DjPoHzAYmyPiXVCF0DWY73hD5mdLmtWUGr)mZ0sygu4NzAYmJOUpAY7apMuc5z9DjPobULWuahUrUkIPZ2HdevuAzifW9DjPobYhChW1CCjWDhS8(9rtQ8iE4mdLmdkCIzSyHzs0iiAa9ebirS4OVMMhClHPaoCJCvsjKdhiQOyZGua33LK6eiFWDaxZXLa3DWY73hnPYJ4HZmuYmOWjMXIfMXkMjrJGOb0teGeXIJ(AAEmttMHdMze19r3b97dDxFxsQtygRHBjmfWHBKRIy6SD4arffBeifW9DjPobYhChW1CCjWDhS8(9rtQ8iE4mdLmdkCcULWuahUxUJ(i0Qi(d(YahiQRWpKc4(UKuNa5dUd4AoUe4Ee19rtEh4XKsipRVlj1jWTeMc4W9yhdAhrRKA5WboWn5icTAGuarffifWTeMc4WnPYyAEdCFxsQtG8bhiQRaPaULWuahUdapt3FSlORaCFxsQtG8bhiQngsbCFxsQtG8b3aEWD(dClHPaoCVi4ssQd3lII(W9iQ7JgPW5jMuaarFxsQtyglwyMmVRuXrWO)K1jLqEKiE4OWmusLzSIzAmZWzWmwXmJOUp6blLkcqIy6Y13LK6eMXwMjrJGO7FKoaZZoixznnpMXAMXAMXIfMbt7hbGrFDWUaYXX(byU13LK6eMPjZKOrq0b7cihh7hG5wtaTD4ErWrx6hUtkH8ir8WHdevBasbCFxsQtG8b3aEWD(dClHPaoCVi4ssQd3lII(WnhmZiQ7JM8oWRG(UKuNWmnzMaaOiG2UU)r6amp7GCL143LYZmtlygBIzAYmi0yU1KJuHAygkzMgZpCVi4Ol9d38aav5OJiaCS)rGdevobPaUVlj1jq(GBap4o)bULWuahUxeCjj1H7frrF4ErWLKuxNuc5rI4HZmnzgRygeAm3mtlyMwMtmdNbZmI6(OrkCEIjfaq03LK6eMPLWmRWpZynCVi4Ol9d38aav5OJiaCmPeYJeXdhoquTjifW9DjPobYhCd4b35pWTeMc4W9IGljPoCVik6d3JOUpAY7aVc67ssDcZ0Kz4GzgrDF0jv5KicnMB9DjPoHzAYmbaqraTD95(X0LUg)UuEMzAbZyfZGoq0DHZzMwcZScZynZ0KzqOXCRjhPc1WmuYmRWpCVi4Ol9d38aav5OJiaC8C)y6shoquBzifW9DjPobYhCd4b35pWTeMc4W9IGljPoCVik6d3JOUp6NZ3dpMWxAvFxsQtyMMmdhmZIGljPUMhaOkhDebGJjLqEKiE4mttMHdMzrWLKuxZdauLJoIaWX(hHzAYmbaqraTD9Z57Hht4lTQP5b3lco6s)WDBPMYrhra44Z57Hht4lTchiQ2mifW9DjPobYhCd4b35pWTeMc4W9IGljPoCVik6d3JOUp6oOFFO767ssDcZ0Kz4Gzs0ii6oOFFO7AAEW9IGJU0pC3wQPC0reao2b97dDhoquTrGua33LK6eiFWDaxZXLa3Oden(DP8mZqLz4hULWuahUdIsfLWuapQQ8a3Qkprx6hUdaGIaA7WbIkk8dPaUVlj1jq(G7aUMJlbUt0iiAKRIjqpjys)(OZJeALzOYmCIzAYmwXmjAeeD17aLmfWJcnw008yglwygoyMencIU)r6amp7GCL108ygRHBjmfWH7Xog0oIwj1YHdevuqbsbCFxsQtG8b3bCnhxcCpI6(OFoFp8ycFPv9DjPoHzAYmwXmlcUKK662snLJoIaWXNZ3dpMWxALzSyHziprJGOFoFp8ycFPvnnpMXA4wctbC4oikvuctb8OQYdCRQ8eDPF4(589WJj8LwHdevuwbsbCFxsQtG8b3bCnhxcCpI6(OjVd8kOVlj1jWTeMc4WnM2JsykGhvvEGBvLNOl9d3K3bEfGdevuAmKc4(UKuNa5dULWuahUX0Euctb8OQYdCRQ8eDPF42b4UOGdCGBY7aVcqkGOIcKc4(UKuNa5dUd4AoUe42kMze19rt7jaTtIb7ciRVlj1jmttMjrJGOP9eG2jXGDbK108ygRzMMmJvmtWUGr)mZqLzwHzSyHzSIzWsrIF5(O7GL3Vp6Yzgkzgu4NzAYmyPiXVCF0cHK1LZmuYmOWpZynZynClHPaoCJCvetNTdhiQRaPaUVlj1jq(G7aUMJlbUxeCjj11jLqEKiE4WTeMc4Wn5YypMB)ZdoquBmKc4(UKuNa5dUd4AoUe4wctT8493RNzgkzgYZf(K4iy0FYmJflmdwks8l3hTqizD5mdLmdk8d3sykGd3OvsT848oVNh4ar1gGua33LK6eiFWDaxZXLa3bGtORrNpglZjr0kPwU(UKuNWmnzMaaOiG2U(C)y6sxJFxkpZmTGzSjMPjZWbZKOrq09pshG5zhKRSMMhZ0Kz4GziprJGOpNZdKpj2gq7ennp4wctbC4ESJbTJOvsTC4arLtqkG77ssDcKp4oGR54sGBSuK4xUpAHqYAAEmJflmdwks8l3hTqizD5mdLmZkCcULWuahUp3pMU0HdevBcsbCFxsQtG8b3bCnhxcCVi4ssQRtkH8ir8WzMMmdhmtaaueqBx3)iDaMNDqUYA8fc3mttMXkMjaakcOTRp3pMU0143LYZmdLmdNyglwygRygSuK4xUpAHqY6YzgkzgjmfWJbaqraTDMPjZGLIe)Y9rleswxoZ0cMzfoXmwZmwd3sykGd3jLqEKiE4WbIAldPaULWuahUREhOKPaEuOXcCFxsQtG8bhiQ2mifW9DjPobYhChW1CCjWnhmZIGljPUMhaOkhDebGJjLqEKiE4WTeMc4WT4EzVuYuahoquTrGua33LK6eiFWDaxZXLa3i0yU1KJuHAygkPYm2a)WTeMc4WnYvjLqoCGOIc)qkG77ssDcKp4oGR54sGBoyMfbxssDnpaqvo6icahtkH8ir8WzMMmdhmZIGljPUMhaOkhDebGJN7htx6WTeMc4WDWUaYX8GRwpCGOIckqkG77ssDcKp4oGR54sG7ru3hn5DGhtkH8S(UKuNWmnzgoyMaaOiG2U(C)y6sxJVq4MzAYmwXmb7cg9ZmdvMzfMXIfMXkMblfj(L7JUdwE)(OlNzOKzqHFMPjZGLIe)Y9rleswxoZqjZGc)mJ1mJ1WTeMc4WnYvrmD2oCGOIYkqkG77ssDcKp4wctbC4M8oWZXunhUd4AoUe4gt7hbGrFDIg7LJo2gq7e9DjPoHzAYmKNOrq0jASxo6yBaTt043LYZmtlygBaUdChupocg9NmevuGdevuAmKc4wctbC4M8oWZXunhUVlj1jq(GdevuSbifW9DjPobYhChW1CCjWDIgbrdONiajIfh9108GBjmfWH7Xog0oIwj1YHdevu4eKc4(UKuNa5dUd4AoUe4UdwE)(OjvEepCMHsMbfoXmwSWmjAeenGEIaKiwC0xtZdULWuahUrUkIPZ2HdevuSjifW9DjPobYhChW1CCjWDhS8(9rtQ8iE4mdLmdkCcULWuahUxUJ(i0Qi(d(YahiQO0YqkG77ssDcKp4oGR54sG7ru3hn5DGhtkH8S(UKuNa3sykGd3JDmODeTsQLdh4a3pNVhEmHV0kKciQOaPaUVlj1jq(G7aUMJlbUrOXCZmusLzSz8ZmnzgRyMaaOiG2UoPeYJeXdxJVq4MzSyHz4GzweCjj11jLqEKiE4mJ1WTeMc4W9Z57Hht4lTchiQRaPaUVlj1jq(G7aUMJlbUxeCjj11jLqEKiE4mttMH8encI(589WJj8Lw108GBjmfWHBYLXEm3(NhCGO2yifW9DjPobYhChW1CCjW9IGljPUoPeYJeXdNzAYmKNOrq0pNVhEmHV0QMMhClHPaoCNuc5rI4HdhiQ2aKc4(UKuNa5dUd4AoUe4M8encI(589WJj8Lw108GBjmfWHBX9YEPKPaoCGOYjifW9DjPobYhChW1CCjWn5jAee9Z57Hht4lTQP5b3sykGd3b7cihZdUA9WboWDaaueqBhsbevuGua33LK6eiFWDaxZXLa3CWmwXmJOUpAY7aVc67ssDcZyXcZSi4ssQR5baQYrhra4y)JWmwZmnzMaaOiG2U(C)y6sxJFxkpZmuYmRWpZ0KzSIz4GzcGL7Ip6L7JDUXmJflmdhmdbm6C5i0QyclorpvO1YrZmwZmwSWmifA7te)UuEMzAbZScNGBjmfWH7(hPdW8SdYvgoquxbsbCFxsQtG8b3bCnhxcCpI6(OjVd8kOVlj1jmttMXkMjaakcOTRp3pMU0143LYZmdLmZk8ZmnzgRygoyMfbxssDDsjKhjIhoZyXcZeaafb021jLqEKiE4A87s5zMHsMbDGO7cNZmwZmwZmnzgRygoyMay5U4JE5(yNBmZyXcZWbZqaJoxocTkMWIt0tfATC0mJ1WTeMc4WD)J0byE2b5kdhiQngsbCFxsQtG8b3bCnhxcCZbZqaJoxocTkMWIt0tfATC0WTeMc4WDUCeAvmHfNahiQ2aKc4(UKuNa5dUd4AoUe4MdMze19rtEh4vqFxsQtyMMmdhmZIGljPUUTut5OJiaCSd63h6oZyXcZKOrq0i04cqNJOfBCxtZdULWuahUh7pAN2h4arLtqkGBjmfWHBeaHCCCaXX(JikPF4(UKuNa5doquTjifW9DjPobYhChW1CCjWTvmJeMA5X7VxpZmuYmKNl8jXrWO)KzglwygSuK4xUpAHqY6YzgkzMgZpZynClHPaoCFf35s8i5b8pCGO2YqkG77ssDcKp4oGR54sG7encIU)r6amp7GCL143LYZmdLmZkCIzSyHzqk02Ni(DP8mZ0cMXM4hULWuahU5bMc4WbIQndsbCFxsQtG8b3bCnhxcCNOrq09pshG5zhKRSMMhClHPaoCtNFSM3ZWboWnp8dGEsgifqurbsbClHPaoCNaZOojIOeUpPD5OJdGZlhUVlj1jq(GdCGdCGdec]] )
end
