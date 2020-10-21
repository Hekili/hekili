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
        halfgiant_empowerment = {
            id = 337532,
            duration = 3600,
            max_stack = 1,
            -- TODO: Requires
        },
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
        essence_break = {
            id = 320338,
            duration = 8,
            max_stack = 1
        },

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

            toggle = "cooldowns",

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
            
            toggle = "cooldowns",

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

            toggle = "cooldowns",

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


    spec:RegisterSetting( "recommend_movement", false, {
        name = "Recommend Movement",
        desc = "If checked, the addon will recommend |T1247261:0|t Fel Rush / |T1348401:0|t Vengeful Retreat when it is a potential DPS gain.\n\n" ..
            "These abilities are critical for DPS when using the Momentum or Unbound Chaos talents.\n\n" ..
            "If not using Momentum, you may want to leave this disabled to avoid unnecessary movement in combat.",
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


    spec:RegisterPack( "Havoc", 20201020, [[diujnbqiIKhPqk2KcmkQqNIkYQuiLEfvQMfIQBPqvSls9lQuggOQJbQSmfINPqY0uOY1iIABurX3uOQghvuQZrfLmpIi3db7dr6GurvXcPcEOcvjMOcvPUivuLAJkuL0iPIQ4KurvPvIi2jrQFsfvjpfWujc7fYFPyWcomQfl0JP0Kr6YQ2mqFgKgnvYPL8AfkZMWTv0Uf9BLgoOCCQOQA5q9CQA6sDDIA7G47kOXRqQopIY6PIkZhH2pjJGdjbcGY9rspc8JapCWpc8A4CwJsYWdhcOjd2raWy7ym0JasEEeGZddzTiaymzILPijqa(vgBpcaOMYcURnhVGzWgbeLlr78nrreaL7JKEe4hbE4GFe41W5Sg14KSZGa8WUfjTKh)Xhb4QO0NOicGEVfbmAuHX7p3ufCEKZ(yvW5HHSwfjJgvW5LT34XQWiWtUkmc8JapcagEblXraJgvy8(ZnvbNh5SpwfCEyiRvrYOrfCEz7nESkmc8KRcJa)iWRirrYOrfasgM312QaMlQkeLbbpvf8n3EviEWfFvWUZi3Qq8qR0RcCsvby4pEGTDxjuvO8QaDZRvKW2U20RHHVDNrUDNGBY(BQ(tYtEEcSZ5DXy2Ba3SnlOb2o8yfjksgnQGZ7r)w5(uv4qoMmvOR5vH21vb22lwfkVkWq4sWrX1ksyBxB6jqlpwgwRiHTDTP3DcUz30lpVzYqlRIe221ME3j4gegxCuCYtEEcrbtVHYP9KdHfYNqZINTgSW(2ef7s1p5O4uIe9WUqyAgd9Txhfm9gkN2dhPeCCuJNMfpBDJ5sywqdwUs9toko1jfjSTRn9UtWnimU4O4KN88eGTROsOgWfBMVzYHWc5tqQMfpBn9ZnlR(jhfNoWURGUdt98npxmmxRV8A8NCLEj5mdaLXKPPhSSvt6OGxrcB7AtV7eCdcJloko5jppby7kQeQbCXMOGP3q50EYHWc5tacJlokUoky6nuoTFGJGYyYK04l5XtZINTgSW(2ef7s1p5O40r7iW7KIe221ME3j4gegxCuCYtEEcW2vujud4InNSBINNKdHfYNqZINTM(5MLv)KJIthivZINTokQKAaLXKPFYrXPdS7kO7WuFYUjEEQXFYv6LKJqTu9Kh9r7ionaugtMMEWYwnPJaVIe221ME3j4gegxCuCYtEEcd5QReQbCXM79pT3eXNhJCiSq(eAw8S137FAVjIppM(jhfNoqkimU4O4Ay7kQeQbCXMOGP3q50(bsbHXfhfxdBxrLqnGl2mFZdS7kO7WuFV)P9Mi(8yAzyksyBxB6DNGBqyCXrXjp55jmKRUsOgWfBM78zlpjhclKpHMfpB9CNpB5P(jhfNoqQOmiOEUZNT8uldtrcB7AtV7eCZYcHHTDTPru(M8KNNGDxbDhMKxGeGAPA8NCLEcWRiHTDTP3DcU1UW7qdubxqo5fiHOmiOg8ctCNrgtNpBTVz7yeK8ahJYGG6Aoxb31MgwgZAzyejkvugeupFZZfdZ16lVwgMtksyBxB6DNGBwwimSTRnnIY3KN88eU3)0EteFEmYlqcnlE2679pT3eXNht)KJIth4iegxCuC9qU6kHAaxS5E)t7nr85XisK(OmiO(E)t7nr85X0YWCsrcB7AtV7eCdlNg221Mgr5BYtEEc0p3SSKxGeAw8S10p3SS6NCuCQIe221ME3j4gwonSTRnnIY3KN88eYfpzHIefjSTRn9A7Uc6omjmFZZfdZ16lp5fibPCSzXZwt)CZYQFYrXPejcHXfhfxdBxrLqnGl2mFZorKiyb1vBWFYv6L0iswrcB7AtV2URGUdt3j428npxmmxRV8KxGeAw8S10p3SS6NCuC6ahLIDUJR(ARlE7YAAmNEWfp5U2u)KJItjs0r7Uc6om1NSBINNA8NCLEshb(bokfegxCuCDuW0BOCAprI2Df0DyQJcMEdLt714p5k9Kc1s1tE0DYjNuKW2U20RT7kO7W0DcU5ReuwyIyoPKxGeKIUT2xjOSWeXCs1DzhRsOksyBxB612Df0Dy6ob3Ax34soBfjSTRn9A7Uc6omDNGBGlLESPxt76gqbpVIe221METDxbDhMUtWTliZxCAO3I)vKW2U20RT7kO7W0DcUbB7AtYlqcrzqq98npxmmxRV8A8NCLEshrYejcwqD1g8NCLEj5mWRiHTDTPxB3vq3HP7eCt2Ft1FsEYZtaklULfIJ9M4Uj5fibPAw8S1GxyImgZqV(jhfNsKODxbDhMAWlmrgJzOxJptjtrcB7AtV2URGUdt3j4MS)MQ)K8dcEBBsEEcwYSITXBwwtuW(M8cKqugeupFZZfdZ16lVwg2GOmiOE(5IjZSGgHSTOgk(80RP7WCGJsbHXfhfxhfm9gkN2tKOu2Df0DyQJcMEdLt714ZuYCsrcB7AtV2URGUdt3j4MS)MQ)K8KNNa7DbHZ7ny25wSXUywqEbsG(OmiOgZo3In2fZcd9rzqqnDhMej6i9rzqqTDtQSTli3u5yg6JYGGAzyejgLbb1Z38CXWCT(YRXFYv6jDe4DAqZyOV1UolAxAy2wsJcoIeblOUAd(tUsVKgbEfjSTRn9A7Uc6omDNGBY(BQ(tYtEEcSZ5DXy2Ba3SnlOb2o8yYlqc2Df0DyQNV55IH5A9LxJ)KR0lj4GNir7Uc6om1Z38CXWCT(YRXFYv6j1zGxrYOrfgVpillAvaKfIiBhtfaxSki75O4Qq1F61ksyBxB612Df0Dy6ob3K93u9NEYlqcrzqq98npxmmxRV8AzyksyBxB612Df0Dy6ob3SSqyyBxBAeLVjp55jCV)P9EfjksyBxB610p3SSeaVWGL9UiVaj4yZINTwoJRCsnwx861p5O40brzqqTCgx5KASU41RLH50ahTUym07jmcrIoI5IAoKNTEUq(8zRRKu4GFaMlQ5qE2AMs96kjfo4DYjfjSTRn9A6NBww3j4g9C7Y4h(dJ8cKaegxCuCDuW0BOCAVIe221MEn9ZnlR7eCdQGli30Fc7(M8cKaB7cYnp)SUNu69f(utZyOV9ejI5IAoKNTMPuVUssHdEfjSTRn9A6NBww3j4w7cVdnqfCb5KxGeSBsLRw7pgZ9PgOcUGC9tokoDGDxbDhM6t2nXZtn(tUsVKCMbsfLbb1Z38CXWCT(YRLHnqk6JYGG6p6Ww)PMHRCs1YWuKW2U20RPFUzzDNGBNSBINNKxGeWCrnhYZwZuQxldJirmxuZH8S1mL61vs6iswrcB7AtVM(5ML1DcUffm9gkN2tEbsacJlokUoky6nuoTFGu2Df0DyQNV55IH5A9LxJptjBGJ2Df0DyQpz3epp14p5k9K6OKhpSZDC1xJpKvaPsOMOGP3RXCo2ODuorKOJyUOMd5zRzk1RRKu7Uc6omhG5IAoKNTMPuVUsjnIKDYjfjSTRn9A6NBww3j4wnNRG7AtdlJzfjSTRn9A6NBww3j4gNz5QeCxBsEbsqkimU4O4Ay7kQeQbCXMOGP3q50EfjSTRn9A6NBww3j4g4frbtp5fibqzmzA6blB1KsyCWRiHTDTPxt)CZY6ob3SU41B8nUg7KxGeKccJlokUg2UIkHAaxSjky6nuoTFGuqyCXrX1W2vujud4InNSBINNksyBxB610p3SSUtWnWlmyzVlYlqcnlE2A6NBAIcMEV(jhfNoqk7Uc6om1NSBINNA8zkzdC06IXqVNWiej6iMlQ5qE265c5ZNTUssHd(byUOMd5zRzk1RRKu4G3jNuKW2U20RPFUzzDNGB0p30BIvFYTKzf30mg6Bpb4iVajGLZdUyOxhLXzLqndx5KQVZVCbd2PdOpkdcQJY4SsOMHRCs14p5k9sACksyBxB610p3SSUtWn6NB6nXQVIe221MEn9ZnlR7eCRDH3HgOcUGCYlqcrzqq9k3Mf0G5e61YWuKW2U20RPFUzzDNGBGxyWYExKxGeMlKpF2AA5BoTNu4KmrIrzqq9k3Mf0G5e61YWuKW2U20RPFUzzDNGBqEc9GYcd(n(CtEbsyUq(8zRPLV50EsHtYksyBxB610p3SSUtWT2fEhAGk4cYjVaj0S4zRPFUPjky696NCuCQIefjSTRn9679pT3eXNhJW9(N2BI4ZJrEbsaugtgPeC2WpWr7Uc6om1rbtVHYP9A8zkzejkfegxCuCDuW0BOCAVtksyBxB6137FAVjIppM7eCJEUDz8d)HrEbsacJlokUoky6nuoTFa9rzqq99(N2BI4ZJPLHPiHTDTPxFV)P9Mi(8yUtWTOGP3q50EYlqcqyCXrX1rbtVHYP9dOpkdcQV3)0EteFEmTmmfjSTRn9679pT3eXNhZDcUXzwUkb31MKxGeOpkdcQV3)0EteFEmTmmfjSTRn9679pT3eXNhZDcUzDXR34BCn2jVajqFugeuFV)P9Mi(8yAzyksuKW2U20RV3)0EpbimU4O4KN88eaVWezmMHEJNS0sEbsOzXZwdEHjYymd96NCuCk5qyH8jy3vq3HPg8ctKXyg614ZuYg4OJokvZINTM(5MLv)KJItjsmkdcQNV55IH5A9LxldZPbsbHXfhfxpKRUsOgWfBM78zlphG5IAoKNTMPuVUsshf8orKiB7cYnp)SUNu69f(utZyOV9oPiHTDTPxFV)P9E3j4MDt7ZgZ9Pgqbpp5fibhLIUT2UP9zJ5(udOGN3eLXPUl7yvcDGuSTRn12nTpBm3NAaf886knGIcQRMirqzHWGV1fJHEtxZljOwQEYJUtksgnQGZNU)ewRc9QcEYsRkmSAxQW41lubhymMHEvyXQGZN15TkuGQq1QWWsiuH4vbz)PQWWQDvPk0UUkKF0BvyCswf83Uj1tUkSTRJhw(RcY(RcuzCLqvHCXtwOcrzSVvbkpzOxRiHTDTPxFV)P9E3j4wuSl1SGM21np)KmYlqcokvZINTg8ctKXyg61p5O4uIeT7kO7WudEHjYymd9A8NCLEshNKDAGuqyCXrX1d5QReQbCXM5oF2YZbo6OunlE2A6NBww9tokoLiXOmiOE(MNlgMR1xETmSbsz3vq3HPoky6nuoTxJptjZjIeblOUAd(tUsVKiah8oPiHTDTPxFV)P9E3j4wuSl1SGM21np)KmYlqcnlE2AWlmrgJzOx)KJIthaHXfhfxdEHjYymd9gpzPvrcB7AtV(E)t79UtWnOYmMwCAwqd7ChVTlYlqcogLbb1Z38CXWCT(YRLHnWURGUdt98npxmmxRV8A8zkzorKyugeupFZZfdZ16lVg)jxPN0rKmrIGfuxTb)jxPxsegf8ksyBxB6137FAV3DcUbUwz)Pg25oU6BINNKxGe8WUqyAgd9Txhfm9gkN2dhPegHirmxuZH8S1mL61vsQZaVIe221ME99(N27DNGBWKXfizvc1efSVjVaj4HDHW0mg6BVoky6nuoThosjmcrIyUOMd5zRzk1RRKuNbEfjSTRn9679pT37ob3Ax3iNXvoPgWfBp5fiHOmiOgF7yI79gWfBVwggrIrzqqn(2Xe37nGl2EJDLZ(yTVz7ysco4vKW2U20RV3)0EV7eCdxWGjUPsJhgBVIe221ME99(N27DNGBdxSGc5vAW3VjN2tEbsikdcQNV55IH5A9LxldJirimU4O4AWlmrgJzO34jlTksyBxB6137FAV3DcUn)CXKzwqJq2wudfFE6jVajakJjtsJd(brzqq98npxmmxRV8AzyksyBxB6137FAV3DcUHpdRsOgqbpVNClzwXnnJH(2taoYlqcnJH(w318MEn06scoTKjs0rhBgd9T21zr7sdZ2K6SHNiXMXqFRDDw0U0WSTKimc8onWr22fKBE(zDpb4isSzm036UM30RHwN0rCwo5erIo2mg6BDxZB61aZ2MrGN0rb)ahzBxqU55N19eGJiXMXqFR7AEtVgADsh34CYjfjksyBxB615INSGaKNqpOSWGFJp3KxGeAw8S1ZD(SLN6NCuC6GOmiOgg(Wy8PA6omh018KcNIe221MEDU4jlCNGBGxyWYExKxGeCecJlokUEixDLqnGl2m35ZwEsKyZINTwoJRCsnwx861p5O40brzqqTCgx5KASU41RLH50ahTUym07jmcrIoI5IAoKNTEUq(8zRRKu4GFaMlQ5qE2AMs96kjfo4DYjfjSTRn96CXtw4ob3aVWezmMHEYlqcSTli388Z6EsP3x4tnnJH(2tKiMlQ5qE2AMs96kjDuWRiHTDTPxNlEYc3j4g9C7Y4h(dJ8cKaegxCuCDuW0BOCAVIe221MEDU4jlCNGB1CUcURnnSmMvKW2U20RZfpzH7eCdQGli30Fc7(M8cKGuqyCXrX1d5QReQbCXM5oF2YZboY2UGCZZpR7jLEFHp10mg6BprIyUOMd5zRzk1RRKu4G3jfjSTRn96CXtw4ob3Ax4DObQGliN8cKGDtQC1A)XyUp1avWfKRFYrXPdS7kO7WuFYUjEEQXFYv6LKZmqQOmiOE(MNlgMR1xETmSbsrFugeu)rh26p1mCLtQwgMIe221MEDU4jlCNGBNSBINNKxGeyBxqU55N19Kc3ahLcZf1CipBntPE9h9Y3EIeXCrnhYZwZuQxldZPbsbHXfhfxpKRUsOgWfBM78zlpvKW2U20RZfpzH7eClky6nuoTN8cKaegxCuCDuW0BOCAVIe221MEDU4jlCNGBGxefm9KxGeaLXKPPhSSvtkHXbVIe221MEDU4jlCNGBNSBINNKxGeKQzXZwhfvsnGYyY0p5O40bsbHXfhfxpKRUsOgWfBU3)0EteFESbyUOMd5zRzk1RRKu7Uc6omvKW2U20RZfpzH7eCJZSCvcURnjVaj4yZINTM(5MMOGP3RFYrXPejkfegxCuC9qU6kHAaxSzUZNT8KirqzmzA6blB1sAuWtKyugeupFZZfdZ16lVg)jxPxss2PbsbHXfhfxdBxrLqnGl2efm9gkN2pqkimU4O46HC1vc1aUyZ9(N2BI4ZJPiHTDTPxNlEYc3j4M1fVEJVX1yN8cKGJnlE2A6NBAIcMEV(jhfNsKOuqyCXrX1d5QReQbCXM5oF2YtIebLXKPPhSSvlPrbVtdKccJlokUg2UIkHAaxSz(MhifegxCuCnSDfvc1aUytuW0BOCA)aPGW4IJIRhYvxjud4In37FAVjIppMIe221MEDU4jlCNGBNSBINNKxGeAw8S1rrLudOmMm9tokoDaMlQ5qE2AMs96kj1URGUdtfjSTRn96CXtw4ob3OFUP3eR(KBjZkUPzm03EcWrEbsalNhCXqVokJZkHAgUYjvFNF5cgSthqFugeuhLXzLqndx5KQXFYv6L04uKW2U20RZfpzH7eCJ(5MEtS6RiHTDTPxNlEYc3j4g4fgSS3f5fibPAw8S1ZD(SLN6NCuC6amxuZH8S1ZfYNpBDLKADXyO3pAHd(bnlE2A6NBAIcMEV(jhfNQiHTDTPxNlEYc3j4g4frbtp5fiH5c5ZNTMw(Mt7jfojtKyugeuVYTzbnyoHETmmfjSTRn96CXtw4ob3aVWGL9UiVajmxiF(S10Y3CApPWjzIeDmkdcQx52SGgmNqVwg2aPAw8S1ZD(SLN6NCuCQtksyBxB615INSWDcUb5j0dklm434Zn5fiH5c5ZNTMw(Mt7jfojRiHTDTPxNlEYc3j4w7cVdnqfCb5KxGeAw8S10p30efm9E9tokofba5yFTjs6rGFe4HdE4CgeWqgNvc1JaC(oHT4(uvy8vb221MQGO8TxRibbWYTRfJaaQ54feGO8Thjbcix8KfijqsdhsceWtokof5acWIR(4IranlE265oF2Yt9tokovfgOcrzqqnm8HX4t10DyQcduHUMxfivfGdbW2U2eba5j0dklm434ZnQrspcsceWtokof5acWIR(4IraoQcqyCXrX1d5QReQbCXM5oF2YtvGirvOzXZwlNXvoPgRlE96NCuCQkmqfIYGGA5mUYj1yDXRxldtfCsfgOcoQcwxmg69QabvyevGirvWrvaZf1CipB9CH85ZwxPkqQkah8QWavaZf1CipBntPEDLQaPQaCWRcoPcoHayBxBIaaVWGL9Uqns6rHKab8KJItroGaS4QpUyeaB7cYnp)SUxfivfO3x4tnnJH(2RcejQcyUOMd5zRzk1RRufivfgf8ia221MiaWlmrgJzOh1iPhhsceWtokof5acWIR(4IraqyCXrX1rbtVHYP9ia221Mia652LXp8hgQrslzKeia221MiGAoxb31MgwgZiGNCuCkYbuJK2zqsGaEYrXPihqawC1hxmcqkvacJlokUEixDLqnGl2m35ZwEQcdubhvb22fKBE(zDVkqQkqVVWNAAgd9TxfisufWCrnhYZwZuQxxPkqQkah8QGtia221MiaOcUGCt)jS7BuJKE8rsGaEYrXPihqawC1hxmcWUjvUAT)ym3NAGk4cY1p5O4uvyGky3vq3HP(KDt88uJ)KR0RcssfCgvyGkiLkeLbb1Z38CXWCT(YRLHPcdubPub6JYGG6p6Ww)PMHRCs1YWqaSTRnraTl8o0avWfKJAK0oBKeiGNCuCkYbeGfx9XfJayBxqU55N19QaPQaCQWavWrvqkvaZf1CipBntPE9h9Y3EvGirvaZf1CipBntPETmmvWjvyGkiLkaHXfhfxpKRUsOgWfBM78zlpraSTRnraNSBINNOgjTZcjbc4jhfNICabyXvFCXiaimU4O46OGP3q50EeaB7AtequW0BOCApQrsdh8ijqap5O4uKdialU6JlgbakJjttpyzRwfiLGkmo4raSTRnraGxefm9OgjnCWHKab8KJItroGaS4QpUyeGuQqZINTokQKAaLXKPFYrXPQWavqkvacJlokUEixDLqnGl2CV)P9Mi(8yQWavaZf1CipBntPEDLQaPQaB7AtJDxbDhMia221MiGt2nXZtuJKgUrqsGaEYrXPihqawC1hxmcWrvOzXZwt)CttuW071p5O4uvGirvqkvacJlokUEixDLqnGl2m35ZwEQcejQcGYyY00dw2QvbjPcJcEvGirvikdcQNV55IH5A9LxJ)KR0RcssfKSk4KkmqfKsfGW4IJIRHTROsOgWfBIcMEdLt7vHbQGuQaegxCuC9qU6kHAaxS5E)t7nr85XqaSTRnraCMLRsWDTjQrsd3OqsGaEYrXPihqawC1hxmcWrvOzXZwt)CttuW071p5O4uvGirvqkvacJlokUEixDLqnGl2m35ZwEQcejQcGYyY00dw2QvbjPcJcEvWjvyGkiLkaHXfhfxdBxrLqnGl2mFZQWavqkvacJlokUg2UIkHAaxSjky6nuoTxfgOcsPcqyCXrX1d5QReQbCXM79pT3eXNhdbW2U2ebyDXR34BCn2rnsA4ghsceWtokof5acWIR(4IranlE26OOsQbugtM(jhfNQcdubmxuZH8S1mL61vQcKQcSTRnn2Df0DyIayBxBIaoz3epprnsA4KmsceWtokof5acGTDTjcG(5MEtS6JaS4QpUyeawop4IHEDugNvc1mCLtQ(o)YfmyNQcdub6JYGG6OmoReQz4kNun(tUsVkijvyCialzwXnnJH(2JKgouJKgoNbjbcGTDTjcG(5MEtS6JaEYrXPihqnsA4gFKeiGNCuCkYbeGfx9XfJaKsfAw8S1ZD(SLN6NCuCQkmqfWCrnhYZwpxiF(S1vQcKQcwxmg69QWOvfGdEvyGk0S4zRPFUPjky696NCuCkcGTDTjca8cdw27c1iPHZzJKab8KJItroGaS4QpUyeWCH85ZwtlFZP9QaPQaCswfisufIYGG6vUnlObZj0RLHHayBxBIaaViky6rnsA4Cwijqap5O4uKdialU6JlgbmxiF(S10Y3CAVkqQkaNKvbIevbhvHOmiOELBZcAWCc9AzyQWavqkvOzXZwp35ZwEQFYrXPQGtia221MiaWlmyzVluJKEe4rsGaEYrXPihqawC1hxmcyUq(8zRPLV50EvGuvaojJayBxBIaG8e6bLfg8B85g1iPhboKeiGNCuCkYbeGfx9XfJaAw8S10p30efm9E9tokofbW2U2eb0UW7qdubxqoQrnc4E)t79ijqsdhsceWtokof5acyHHa8VraSTRnraqyCXrXraqyH8ra2Df0DyQbVWezmMHEn(mLmvyGk4Ok4Ok4OkiLk0S4zRPFUzz1p5O4uvGirvikdcQNV55IH5A9LxldtfCsfgOcsPcqyCXrX1d5QReQbCXM5oF2YtvyGkG5IAoKNTMPuVUsvGuvyuWRcoPcejQcSTli388Z6EvGuvGEFHp10mg6BVk4ecWIR(4IranlE2AWlmrgJzOx)KJItraqySj55raGxyImgZqVXtwArns6rqsGaEYrXPihqawC1hxmcWrvqkvGUT2UP9zJ5(udOGN3eLXPUl7yvcvfgOcsPcSTRn12nTpBm3NAaf886knGIcQRwfisufaLfcd(wxmg6nDnVkijvaQLQN8ORcoHayBxBIaSBAF2yUp1ak45rns6rHKab8KJItroGaS4QpUyeGJQGuQqZINTg8ctKXyg61p5O4uvGirvWURGUdtn4fMiJXm0RXFYv6vbsvHXjzvWjvyGkiLkaHXfhfxpKRUsOgWfBM78zlpvHbQGJQGJQGuQqZINTM(5MLv)KJItvbIevHOmiOE(MNlgMR1xETmmvyGkiLky3vq3HPoky6nuoTxJptjtfCsfisufalOUAd(tUsVkijcQaCWRcoHayBxBIaIIDPMf00UU55NKHAK0Jdjbc4jhfNICabyXvFCXiGMfpBn4fMiJXm0RFYrXPQWavacJlokUg8ctKXyg6nEYslcGTDTjcik2LAwqt76MNFsgQrslzKeiGNCuCkYbeGfx9XfJaCufIYGG65BEUyyUwF51YWuHbQGDxbDhM65BEUyyUwF514ZuYubNubIevHOmiOE(MNlgMR1xEn(tUsVkqQkmIKvbIevbWcQR2G)KR0RcsIGkmk4raSTRnraqLzmT40SGg25oEBxOgjTZGKab8KJItroGaS4QpUyeGh2fctZyOV96OGP3q50E4ubsjOcJOcejQcyUOMd5zRzk1RRufivfCg4raSTRnraGRv2FQHDUJR(M45jQrsp(ijqap5O4uKdialU6Jlgb4HDHW0mg6BVoky6nuoThovGucQWiQarIQaMlQ5qE2AMs96kvbsvbNbEeaB7AteamzCbswLqnrb7BuJK2zJKab8KJItroGaS4QpUyequgeuJVDmX9Ed4ITxldtfisufIYGGA8TJjU3BaxS9g7kN9XAFZ2XubjPcWbpcGTDTjcODDJCgx5KAaxS9OgjTZcjbcGTDTjcaxWGjUPsJhgBpc4jhfNICa1iPHdEKeiGNCuCkYbeGfx9XfJaIYGG65BEUyyUwF51YWubIevbimU4O4AWlmrgJzO34jlTia221MiGHlwqH8kn473Kt7rnsA4Gdjbc4jhfNICabyXvFCXiaqzmzQGKuHXbVkmqfIYGG65BEUyyUwF51YWqaSTRnraZpxmzMf0iKTf1qXNNEuJKgUrqsGaEYrXPihqaSTRnra4ZWQeQbuWZ7rawC1hxmcOzm036UM30RHwxfKKkaNwYQarIQGJQGJQqZyOV1UolAxAy2wfivfC2WRcejQcnJH(w76SODPHzBvqseuHrGxfCsfgOcoQcSTli388Z6EvGGkaNkqKOk0mg6BDxZB61qRRcKQcJ4SubNubNubIevbhvHMXqFR7AEtVgy22mc8QaPQWOGxfgOcoQcSTli388Z6EvGGkaNkqKOk0mg6BDxZB61qRRcKQcJBCQGtQGtialzwXnnJH(2JKgouJAea9GSSOrsGKgoKeia221MiaA5XYWAeWtokof5aQrspcsceaB7AteGDtV88MjdTSiGNCuCkYbuJKEuijqap5O4uKdiGfgcW)gbW2U2ebaHXfhfhbaHfYhb0S4zRblSVnrXUu9tokovfisuf8WUqyAgd9Txhfm9gkN2dNkqkbvWrvyuQW4rfAw8S1nMlHzbny5k1p5O4uvWjeaegBsEEequW0BOCApQrspoKeiGNCuCkYbeWcdb4FJayBxBIaGW4IJIJaGWc5JaKsfAw8S10p3SS6NCuCQkmqfS7kO7WupFZZfdZ16lVg)jxPxfKKk4mQWavaugtMMEWYwTkqQkmk4raqySj55raW2vujud4InZ3mQrslzKeiGNCuCkYbeWcdb4FJayBxBIaGW4IJIJaGWc5JaGW4IJIRJcMEdLt7vHbQGJQaOmMmvqsQW4lzvy8OcnlE2AWc7BtuSlv)KJItvHrRkmc8QGtiaim2K88iay7kQeQbCXMOGP3q50EuJK2zqsGaEYrXPihqalmeG)ncGTDTjcacJlokocaclKpcOzXZwt)CZYQFYrXPQWavqkvOzXZwhfvsnGYyY0p5O4uvyGky3vq3HP(KDt88uJ)KR0RcssfCufGAP6jp6QWOvfgrfCsfgOcGYyY00dw2QvbsvHrGhbaHXMKNhbaBxrLqnGl2CYUjEEIAK0JpsceWtokof5acyHHa8VraSTRnraqyCXrXraqyH8ranlE2679pT3eXNht)KJItvHbQGuQaegxCuCnSDfvc1aUytuW0BOCAVkmqfKsfGW4IJIRHTROsOgWfBMVzvyGky3vq3HP(E)t7nr85X0YWqaqySj55rad5QReQbCXM79pT3eXNhd1iPD2ijqap5O4uKdiGfgcW)gbW2U2ebaHXfhfhbaHfYhb0S4zRN78zlp1p5O4uvyGkiLkeLbb1ZD(SLNAzyiaim2K88iGHC1vc1aUyZCNpB5jQrs7SqsGaEYrXPihqawC1hxmcaQLQXFYv6vbcQa8ia221Mialleg221Mgr5BeGO8Tj55ra2Df0DyIAK0WbpsceWtokof5acWIR(4Irarzqqn4fM4oJmMoF2AFZ2XubcQGKvHbQGJQqugeuxZ5k4U20WYywldtfisufKsfIYGG65BEUyyUwF51YWubNqaSTRnraTl8o0avWfKJAK0WbhsceWtokof5acWIR(4IranlE2679pT3eXNht)KJItvHbQGJQaegxCuC9qU6kHAaxS5E)t7nr85XubIevb6JYGG679pT3eXNhtldtfCcbW2U2ebyzHWW2U20ikFJaeLVnjppc4E)t7nr85XqnsA4gbjbc4jhfNICabyXvFCXiGMfpBn9ZnlR(jhfNIayBxBIaWYPHTDTPru(gbikFBsEEea9ZnllQrsd3OqsGaEYrXPihqaSTRnray50W2U20ikFJaeLVnjppcix8KfOg1iay4B3zKBKeiPHdjbc4jhfNICabK88ia258Uym7nGB2Mf0aBhEmcGTDTjcGDoVlgZEd4MTzbnW2HhJAuJaU3)0EteFEmKeiPHdjbc4jhfNICabyXvFCXiaqzmzQaPeubNn8QWavWrvWURGUdtDuW0BOCAVgFMsMkqKOkiLkaHXfhfxhfm9gkN2RcoHayBxBIaU3)0EteFEmuJKEeKeiGNCuCkYbeGfx9XfJaGW4IJIRJcMEdLt7vHbQa9rzqq99(N2BI4ZJPLHHayBxBIaONBxg)WFyOgj9OqsGaEYrXPihqawC1hxmcacJlokUoky6nuoTxfgOc0hLbb137FAVjIppMwggcGTDTjciky6nuoTh1iPhhsceWtokof5acWIR(4Ira0hLbb137FAVjIppMwggcGTDTjcGZSCvcURnrnsAjJKab8KJItroGaS4QpUyea9rzqq99(N2BI4ZJPLHHayBxBIaSU41B8nUg7Og1ia7Uc6omrsGKgoKeiGNCuCkYbeGfx9XfJaKsfCufAw8S10p3SS6NCuCQkqKOkaHXfhfxdBxrLqnGl2mFZQGtQarIQayb1vBWFYv6vbjPcJizeaB7AteW8npxmmxRV8Ogj9iijqap5O4uKdialU6Jlgb0S4zRPFUzz1p5O4uvyGk4OkiLkWo3XvFT1fVDznnMtp4INCxBQFYrXPQarIQGJQGDxbDhM6t2nXZtn(tUsVkqQkmc8QWavWrvqkvacJlokUoky6nuoTxfisufS7kO7Wuhfm9gkN2RXFYv6vbsvbOwQEYJUk4Kk4Kk4ecGTDTjcy(MNlgMR1xEuJKEuijqap5O4uKdialU6JlgbiLkq3w7ReuwyIyoP6USJvjueaB7AteGVsqzHjI5KIAK0JdjbcGTDTjcODDJl5Srap5O4uKdOgjTKrsGayBxBIaaxk9ytVM21nGcEEeWtokof5aQrs7mijqaSTRnraxqMV40qVf)JaEYrXPihqns6Xhjbc4jhfNICabyXvFCXiGOmiOE(MNlgMR1xEn(tUsVkqQkmIKvbIevbWcQR2G)KR0RcssfCg4raSTRnraW2U2e1iPD2ijqap5O4uKdia221MiaOS4wwio2BI7MialU6JlgbiLk0S4zRbVWezmMHE9tokovfisufS7kO7WudEHjYymd9A8zkziGKNhbaLf3YcXXEtC3e1iPDwijqap5O4uKdia221MialzwX24nlRjkyFJaS4QpUyequgeupFZZfdZ16lVwgMkmqfIYGG65NlMmZcAeY2IAO4ZtVMUdtvyGk4OkiLkaHXfhfxhfm9gkN2RcejQcsPc2Df0DyQJcMEdLt714ZuYubNqahe822K88ialzwX24nlRjkyFJAK0WbpsceWtokof5acGTDTjcG9UGW59gm7Cl2yxmlqawC1hxmcG(OmiOgZo3In2fZcd9rzqqnDhMQarIQGJQa9rzqqTDtQSTli3u5yg6JYGGAzyQarIQqugeupFZZfdZ16lVg)jxPxfivfgbEvWjvyGk0mg6BTRZI2LgMTvbjPcJcovGirvaSG6Qn4p5k9QGKuHrGhbK88ia27ccN3BWSZTyJDXSa1iPHdoKeiGNCuCkYbeaB7Atea7CExmM9gWnBZcAGTdpgbyXvFCXia7Uc6om1Z38CXWCT(YRXFYv6vbjPcWbVkqKOky3vq3HPE(MNlgMR1xEn(tUsVkqQk4mWJasEEea7CExmM9gWnBZcAGTdpg1iPHBeKeiGNCuCkYbeGfx9XfJaIYGG65BEUyyUwF51YWqaSTRnraY(BQ(tpQrsd3OqsGaEYrXPihqaSTRnrawwimSTRnnIY3iar5BtYZJaU3)0EpQrncG(5MLfjbsA4qsGaEYrXPihqawC1hxmcWrvOzXZwlNXvoPgRlE96NCuCQkmqfIYGGA5mUYj1yDXRxldtfCsfgOcoQcwxmg69QabvyevGirvWrvaZf1CipB9CH85ZwxPkqQkah8QWavaZf1CipBntPEDLQaPQaCWRcoPcoHayBxBIaaVWGL9Uqns6rqsGaEYrXPihqawC1hxmcacJlokUoky6nuoThbW2U2ebqp3Um(H)Wqns6rHKab8KJItroGaS4QpUyeaB7cYnp)SUxfivfO3x4tnnJH(2RcejQcyUOMd5zRzk1RRufivfGdEeaB7AteaubxqUP)e29nQrspoKeiGNCuCkYbeGfx9XfJaSBsLRw7pgZ9PgOcUGC9tokovfgOc2Df0DyQpz3epp14p5k9QGKubNrfgOcsPcrzqq98npxmmxRV8AzyQWavqkvG(OmiO(JoS1FQz4kNuTmmeaB7Ateq7cVdnqfCb5OgjTKrsGaEYrXPihqawC1hxmcaZf1CipBntPETmmvGirvaZf1CipBntPEDLQaPQWisgbW2U2ebCYUjEEIAK0odsceWtokof5acWIR(4IraqyCXrX1rbtVHYP9QWavqkvWURGUdt98npxmmxRV8A8zkzQWavWrvWURGUdt9j7M45Pg)jxPxfivfCufKSkmEub25oU6RXhYkGujutuW071yohtfgTQWOubNubIevbhvbmxuZH8S1mL61vQcKQcSTRnn2Df0DyQcdubmxuZH8S1mL61vQcssfgrYQGtQGtia221MiGOGP3q50EuJKE8rsGayBxBIaQ5CfCxBAyzmJaEYrXPihqnsANnsceWtokof5acWIR(4IrasPcqyCXrX1W2vujud4InrbtVHYP9ia221MiaoZYvj4U2e1iPDwijqap5O4uKdialU6JlgbakJjttpyzRwfiLGkmo4raSTRnraGxefm9OgjnCWJKab8KJItroGaS4QpUyeGuQaegxCuCnSDfvc1aUytuW0BOCAVkmqfKsfGW4IJIRHTROsOgWfBoz3eppraSTRnrawx86n(gxJDuJKgo4qsGaEYrXPihqawC1hxmcOzXZwt)CttuW071p5O4uvyGkiLky3vq3HP(KDt88uJptjtfgOcoQcwxmg69QabvyevGirvWrvaZf1CipB9CH85ZwxPkqQkah8QWavaZf1CipBntPEDLQaPQaCWRcoPcoHayBxBIaaVWGL9UqnsA4gbjbc4jhfNICabW2U2ebq)CtVjw9rawC1hxmcalNhCXqVokJZkHAgUYjvFNF5cgStvHbQa9rzqqDugNvc1mCLtQg)jxPxfKKkmoeGLmR4MMXqF7rsdhQrsd3OqsGayBxBIaOFUP3eR(iGNCuCkYbuJKgUXHKab8KJItroGaS4QpUyequgeuVYTzbnyoHETmmeaB7Ateq7cVdnqfCb5OgjnCsgjbc4jhfNICabyXvFCXiG5c5ZNTMw(Mt7vbsvb4KSkqKOkeLbb1RCBwqdMtOxlddbW2U2ebaEHbl7DHAK0W5mijqap5O4uKdialU6JlgbmxiF(S10Y3CAVkqQkaNKraSTRnraqEc9GYcd(n(CJAK0Wn(ijqap5O4uKdialU6Jlgb0S4zRPFUPjky696NCuCkcGTDTjcODH3HgOcUGCuJAuJAuJqa]] )
end
