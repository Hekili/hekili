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
            "These abilities are critical for DPS when using the Momentum talent.\n\n" ..
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


    spec:RegisterPack( "Havoc", 20201016, [[dKejpbqiIupskrztsrFskHQrrj6uukwLuIQxrPYSiIULuczxK6xuQAyeHJbswMusptkvMgIGRrj02qe6BucyCucY5KsKwNuQkZdr09qW(qKoOuIWcPu6HsjumrkbkxKsqvBKsGkFukHsJKsq5KsjIwji1mPeOQDsK8tkbvwQuQQ6PaMkIYxLsvfJvkvvAVq9xQmykomQfl0JPQjt4YQ2mqFgugnL0PL8APuMnj3wQ2TOFR0WbvhNsGSCipxW0vCDIA7G47sHXlLQCEevRxkbZhH2psJHctggqWZXs1QeTkbusafjQHsIwBhuwimWqo8JbGZ(2yyhdKC)yalmgY6XaWzYvllWKHbcRmYFmaq1Lv8uB2IbXGdgikxQPLmXrmGGNJLQvjAvcOKaksudLeT2kjqIyGa87XszrlGfadyTeIN4igq8Ghd0YOglyVVj1yHjNZruJfgdz9uOBzuJfo)SXJOgOirjPMwLOvjWaWrlyPogOLrnwWEFtQXctoNJOglmgY6Pq3YOglC(zJhrnqrIssnTkrRsqHMcDlJAasgEW6oudIlb1eLbbVGAcdpbQjEWfDQXV9iput8WQmqnCkOg4O3IGVZujmQPcuJyZRPqZ(P2mOHJUF7rESJG9YH7Q5DjtUFcCleSYio4a3CClOd(24ik0uOBzuJf(27E55cQ5qoICQzQ(PMX6Pg2plIAQa1Wq4sXr11uOz)uBgiiQasg(qHM9tTzWoc273mi3VRZWkpfA2p1Mb7iypegvCuDjtUFcrflUtWP)scHvYNWWQNJgSqHXfv7k0p5O6cIedWVs5ggb7tqhvS4obN(dfPeSSDTOHvph9G4s5wqhsUs9toQUWgk0SFQnd2rWEimQ4O6sMC)eGVRQsyoWf56FyjHWk5tq6HvphT49nlV(jhvx00VRsSnsD)d3xeCRBOcA07CLbssInbLrKRfhS81qA7KGcn7NAZGDeShcJkoQUKj3pb47QQeMdCrUOIf3j40FjHWk5tacJkoQUoQyXDco9VPLGYiYjPfWITOHvphnyHcJlQ2vOFYr1fT8wLWgk0SFQnd2rWEimQ4O6sMC)eGVRQsyoWf5o53fp3LecRKpHHvphT49nlV(jhvx0u6HvphDuvPWbkJix)KJQlA63vj2gP(KFx8CxJENRmqslH5f6o3ET8wTPjOmICT4GLVgsBvck0SFQnd2rWEimQ4O6sMC)eAW1ujmh4ICpeE6VlIo3MKqyL8jmS65OFi80FxeDUn9toQUOP0qyuXr11W3vvjmh4ICrflUtWP)nLgcJkoQUg(UQkH5axKR)HB63vj2gP(HWt)Dr0520YWPqZ(P2myhb7HWOIJQlzY9tObxtLWCGlY13(ZrUljewjFcdREo6(2FoYD9toQUOP0rzqqDF7ph5UwgofA2p1Mb7iyVNvkh7NAtNQcJKj3pb)UkX2iLSajaZl0O35kdeKGcn7NAZGDeSFSI2goykUGCjlqcrzqqn4vU42Jms0Fo6WW(2iyXMwgLbb1vVVkEQnDSmI1YWjsu6OmiOU)H7lcU1nubTmCBOqZ(P2myhb79Ss5y)uB6uvyKm5(j8q4P)Ui6CBswGegw9C0peE6VlIo3M(jhvx00simQ4O66gCnvcZbUi3dHN(7IOZTrKO4rzqq9dHN(7IOZTPLHBdfA2p1Mb7iypsoDSFQnDQkmsMC)eeVVz5LSajmS65OfVVz51p5O6ck0SFQnd2rWEKC6y)uB6uvyKm5(jKlQZkk0uOz)uBg0(DvITrsO)H7lcU1nubjlqcsB5WQNJw8(MLx)KJQlisecJkoQUg(UQkH5axKR)HTHirWcM1XHENRmqYwTifA2p1MbTFxLyBK2rW((hUVi4w3qfKSajmS65OfVVz51p5O6IMwkn3chvZ1ER8oL3niodGlQZtTP(jhvxqKOL(DvITrQp53fp31O35kdK2QenTuAimQ4O66OIf3j40FIe97QeBJuhvS4obN(RrVZvgifMxO7C7zJn2qHM9tTzq73vj2gPDeSpujOSYfrCkKSajiTyhDOsqzLlI4uONY3wLWOqZ(P2mO97QeBJ0oc2pwVZQCouOz)uBg0(DvITrAhb7bxH4i3SUX6DGkUFk0SFQndA)UkX2iTJG9xrEO40jUh9tHM9tTzq73vj2gPDeSh(o1MswGeIYGG6(hUVi4w3qf0O35kdK2QfjseSGzDCO35kdKKeLGcn7NAZG2VRsSns7iyVC4UAExYK7NamwDpRuhfCXDtjlqcspS65ObVYfzeIHD9toQUGir)UkX2i1Gx5ImcXWUgDwqofA2p1MbTFxLyBK2rWE5WD18UKhe8(XLC)e8K7v7G2S8UOIdJKfiHOmiOU)H7lcU1nubTm8MrzqqD)9frUBbDkzFjCc05Eql2gztlLgcJkoQUoQyXDco9NirP97QeBJuhvS4obN(RrNfKBdfA2p1MbTFxLyBK2rWE5WD18UKj3pboyfcNp4qClSiNFrSsYcKG4rzqqnIBHf58lIvoXJYGGAX2ijs0sXJYGGA)Mcz)uqURY2CIhLbb1YWjsmkdcQ7F4(IGBDdvqJENRmqARsytZHrW(OTEwnw1W9djBhuejcwWSoo07CLbs2QeuOz)uBg0(DvITrAhb7Ld3vZ7sMC)e4wiyLrCWbU54wqh8TXrswGe87QeBJu3)W9fb36gQGg9oxzGKqjbrI(DvITrQ7F4(IGBDdvqJENRmqkjkbf6wg1yb7GSSAOgqwPISVnQbCruJCGJQtn18EqtHM9tTzq73vj2gPDeSxoCxnVhKSajeLbb19pCFrWTUHkOLHtHM9tTzq73vj2gPDeS3ZkLJ9tTPtvHrYK7NWdHN(hOqtHM9tTzqlEFZYta8khsoyvYcKGLdREoA5mUYPW5TYBq)KJQlAgLbb1YzCLtHZBL3GwgUnnT0BLrWEGqRejAjIlH7qEo6(c59NJUssHsIMiUeUd55OzHiORKuOKWgBOqZ(P2mOfVVz5TJG9IZJvxOXpCjlqcqyuXr11rflUtWP)uOz)uBg0I33S82rWEykUGC38o8hgjlqcSFki39896bsfpuOlCdJG9jqKiIlH7qEoAwic6kjfkjOqZ(P2mOfVVz5TJG9Jv02WbtXfKlzbsWVPqUgD4iepx4GP4cY1p5O6IM(DvITrQp53fp31O35kdKKeBkDugeu3)W9fb36gQGwgEtPfpkdcQF7bFdx4ASYPqldNcn7NAZGw8(ML3oc2FYVlEUlzbsaXLWDiphnlebTmCIerCjChYZrZcrqxjPTArk0SFQndAX7BwE7iyFuXI7eC6VKfibimQ4O66OIf3j40)Ms73vj2gPU)H7lcU1nubn6SG8Mw63vj2gP(KFx8CxJENRmqQLwSfXTWr1Cn6qwfKkH5Ikw8GgXzBT82zdrIwI4s4oKNJMfIGUss97QeBJSjIlH7qEoAwic6kjzRw0gBOqZ(P2mOfVVz5TJG9vVVkEQnDSmIPqZ(P2mOfVVz5TJG9CML1sXtTPKfibPHWOIJQRHVRQsyoWf5IkwCNGt)PqZ(P2mOfVVz5TJG9GxfvS4swGeaLrKRfhS81qkbsqck0SFQndAX7BwE7iyV3kVbxyqvBxYcKG0qyuXr11W3vvjmh4ICrflUtWP)nLgcJkoQUg(UQkH5axK7KFx8CNcn7NAZGw8(ML3oc2dELdjhSkzbsyy1ZrlEFtxuXIh0p5O6IMs73vj2gP(KFx8CxJoliVPLERmc2deALirlrCjChYZr3xiV)C0vskus0eXLWDiphnlebDLKcLe2ydfA2p1MbT49nlVDeSx8(MbxSMlPNCV6UHrW(eiaLKfibKCEWfb76OmkReMRXkNc9TGKl4WVOP4rzqqDugLvcZ1yLtHg9oxzGKKafA2p1MbT49nlVDeSx8(MbxSMtHM9tTzqlEFZYBhb7hROTHdMIlixYcKqugeuVYJBbDioHDTmCk0SFQndAX7BwE7iyp4voKCWQKfiH(c59NJwuHHt)jfklsKyugeuVYJBbDioHDTmCk0SFQndAX7BwE7iypKNWoOSYH(GopswGe6lK3FoArfgo9NuOSifA2p1MbT49nlVDeSFSI2goykUGCjlqcdREoAX7B6Ikw8G(jhvxqHMcn7NAZG(HWt)Dr052i8q4P)Ui6CBswGeaLrKtkblKenT0VRsSnsDuXI7eC6VgDwqorIsdHrfhvxhvS4obN(BdfA2p1Mb9dHN(7IOZTzhb7fNhRUqJF4swGeGWOIJQRJkwCNGt)BkEugeu)q4P)Ui6CBAz4uOz)uBg0peE6VlIo3MDeSpQyXDco9xYcKaegvCuDDuXI7eC6FtXJYGG6hcp93frNBtldNcn7NAZG(HWt)Dr052SJG9CML1sXtTPKfibXJYGG6hcp93frNBtldNcn7NAZG(HWt)Dr052SJG9ER8gCHbvTDjlqcIhLbb1peE6VlIo3MwgofAk0SFQnd6hcp9pqacJkoQUKj3pbWRCrgHyy3fip9swGegw9C0Gx5ImcXWU(jhvxijewjFc(DvITrQbVYfzeIHDn6SG8MwAPLspS65OfVVz51p5O6cIeJYGG6(hUVi4w3qf0YWTPP0qyuXr11n4AQeMdCrU(2FoY9MiUeUd55OzHiORK02jHnejY(PGC3Z3Rhiv8qHUWnmc2NGnuOz)uBg0peE6FWoc2730)Cq8CHduX9lzbsWsPf7O9B6FoiEUWbQ4(DrzuQNY3wLWAkn7NAtTFt)ZbXZfoqf3VUshOQGzDiseuwPCO7TYiy3nv)KeMxO7C7zdf6wg10smZ7WhQzwQjqE6PMg1yLASG7kQXwgHyyNAwe10sSw4PMcKAQHAAukf1ep1ihUGAAuJ1kPMX6PM8T3qnKGfPMW9Bkcssn7y9Ogv4uJC4uJqgvjmQjxuNvutugfgQrWDg21uOz)uBg0peE6FWoc2hv7kClOBSE3Z3jxYcKGLspS65ObVYfzeIHD9toQUGir)UkX2i1Gx5ImcXWUg9oxzGusWI20uAimQ4O66gCnvcZbUixF7ph5EtlTu6HvphT49nlV(jhvxqKyugeu3)W9fb36gQGwgEtP97QeBJuhvS4obN(RrNfKBdrIGfmRJd9oxzGKeGscBOqZ(P2mOFi80)GDeSpQ2v4wq3y9UNVtUKfiHHvphn4vUiJqmSRFYr1fnHWOIJQRbVYfzeIHDxG80tHM9tTzq)q4P)b7iypmzgjkoDlOJBHJ2XQKfiblJYGG6(hUVi4w3qf0YWB63vj2gPU)H7lcU1nubn6SGCBismkdcQ7F4(IGBDdvqJENRmqARwKirWcM1XHENRmqscTtck0SFQnd6hcp9pyhb7bxVC4ch3chvZDXZDjlqcb4xPCdJG9jOJkwCNGt)HIucTsKiIlH7qEoAwic6kjLeLGcn7NAZG(HWt)d2rWE4YOcK8kH5IkomswGecWVs5ggb7tqhvS4obN(dfPeALirexc3H8C0Sqe0vskjkbfA2p1Mb9dHN(hSJG9J17KZ4kNch4I8xYcKqugeuJUVn1dbh4I8xldNiXOmiOgDFBQhcoWf5VZVY5CKomSVnscLeuOz)uBg0peE6FWoc2Jk4Wv3vPlaN9Ncn7NAZG(HWt)d2rW(glsjG8kDOh2Kt)LSajeLbb19pCFrWTUHkOLHtKiegvCuDn4vUiJqmS7cKNEk0SFQnd6hcp9pyhb77VViYDlOtj7lHtGo3dswGeaLrKtssqIMrzqqD)d3xeCRBOcAz4uOz)uBg0peE6FWoc2JodVsyoqf3Fqsp5E1DdJG9jqakjlqcdJG9rpv)UzDI6KekTfjs0slhgb7J26z1yvd3pKAHKGiXHrW(OTEwnw1W9djj0Qe200s2pfK7E(E9abOisCyeSp6P63nRtuN0wBP2ydrIwomc2h9u97M1b3pUwLG02jrtlz)uqU7571deGIiXHrW(ONQF3SorDsjbsWgBOqtHM9tTzqNlQZkcqEc7GYkh6d68izbsyy1Zr33(ZrURFYr1fnJYGGA4OdNrxOfBJS5u9tkuuOz)uBg05I6SYoc2dELdjhSkzbsWsimQ4O66gCnvcZbUixF7ph5orIdREoA5mUYPW5TYBq)KJQlAgLbb1YzCLtHZBL3GwgUnnT0BLrWEGqRejAjIlH7qEo6(c59NJUssHsIMiUeUd55OzHiORKuOKWgBOqZ(P2mOZf1zLDeSh8kxKrig2LSajW(PGC3Z3Rhiv8qHUWnmc2NarIiUeUd55OzHiORK02jbfA2p1MbDUOoRSJG9IZJvxOXpCjlqcqyuXr11rflUtWP)uOz)uBg05I6SYoc2x9(Q4P20XYiMcn7NAZGoxuNv2rWEykUGC38o8hgjlqcsdHrfhvx3GRPsyoWf56B)5i3BAj7NcYDpFVEGuXdf6c3WiyFcejI4s4oKNJMfIGUssHscBOqZ(P2mOZf1zLDeSFSI2goykUGCjlqc(nfY1OdhH45chmfxqU(jhvx00VRsSns9j)U45Ug9oxzGKKytPJYGG6(hUVi4w3qf0YWBkT4rzqq9Bp4B4cxJvofAz4uOz)uBg05I6SYoc2FYVlEUlzbsG9tb5UNVxpqkunTuAexc3H8C0Sqe0V9QWeiseXLWDiphnlebTmCBAknegvCuDDdUMkH5axKRV9NJCNcn7NAZGoxuNv2rW(OIf3j40FjlqcqyuXr11rflUtWP)uOz)uBg05I6SYoc2dEvuXIlzbsaugrUwCWYxdPeibjOqZ(P2mOZf1zLDeS)KFx8CxYcKG0dREo6OQsHdugrU(jhvx0uAimQ4O66gCnvcZbUi3dHN(7IOZT1eXLWDiphnlebDLK63vj2gjfA2p1MbDUOoRSJG9CML1sXtTPKfiblhw9C0I330fvS4b9toQUGirPHWOIJQRBW1ujmh4IC9T)CK7ejckJixloy5RHKTtcIeJYGG6(hUVi4w3qf0O35kdK0I20uAimQ4O6A47QQeMdCrUOIf3j40)MsdHrfhvx3GRPsyoWf5Ei80FxeDUnk0SFQnd6CrDwzhb79w5n4cdQA7swGeSCy1ZrlEFtxuXIh0p5O6cIeLgcJkoQUUbxtLWCGlY13(ZrUtKiOmICT4GLVgs2ojSPP0qyuXr11W3vvjmh4IC9pCtPHWOIJQRHVRQsyoWf5IkwCNGt)BknegvCuDDdUMkH5axK7HWt)Dr052OqZ(P2mOZf1zLDeS)KFx8CxYcKWWQNJoQQu4aLrKRFYr1fnrCjChYZrZcrqxjP(DvITrsHM9tTzqNlQZk7iyV49ndUynxYHrW(4kqc9kBFIhLbb1rzuwjmxJvofA07CLbjlqci58Glc21rzuwjmxJvof6BbjxWHFrtXJYGG6OmkReMRXkNcn6DUYajjbk0SFQnd6CrDwzhb7fVVzWfR5uOz)uBg05I6SYoc2dELdjhSkzbsq6HvphDF7ph5U(jhvx0eXLWDiphDFH8(ZrxjPERmc2dTCOKO5WQNJw8(MUOIfpOFYr1fuOz)uBg05I6SYoc2dEvuXIlzbsOVqE)5Ofvy40FsHYIejgLbb1R84wqhItyxldNcn7NAZGoxuNv2rWEWRCi5Gvjlqc9fY7phTOcdN(tkuwKirlJYGG6vEClOdXjSRLH3u6HvphDF7ph5U(jhvxydfA2p1MbDUOoRSJG9qEc7GYkh6d68izbsOVqE)5Ofvy40FsHYIuOz)uBg05I6SYoc2pwrBdhmfxqUKfiHHvphT49nDrflEq)KJQlWaqokuBILQvjAvcOKaQ2HbAWOSsybmq7NwI2FPAjLQfB7JAOgYSEQP6Wx0qnGlIAAXZf1zvlo1GUfKCHUGAcB)udlpBNNlOgVvoH9GMcTf8vEQbkl2(OM2)3xixqn9kBFTFPgV17BJASm3HAyiCP4O6utLuZ7YkEQnTHASeQ2ZgnfAYSEQbCvQTrLWOgwgXbQPXrNAKdxqnvsnJ1tnSFQnPgvfgQjkputJJo1K7qnGRCkOMkPMX6Pgwi2KAe8Wro82hfAQPfrnrzuwjmxJvofuOPq3(PLO9xQwsPAX2(OgQHmRNAQo8fnud4IOMwCX7Bw(wCQbDli5cDb1e2(PgwE2opxqnERCc7bnfAYSEQbCvQTrLWOgwgXbQPXrNAKdxqnvsnJ1tnSFQnPgvfgQjkputJJo1K7qnGRCkOMkPMX6Pgwi2KAe8Wro82hfAQPfrnrzuwjmxJvofuOPq3s2HVO5cQXcqnSFQnPgvfMGMcngGLhRlcdau9wmyavfMaMmmqUOoRWKHLckmzyGNCuDb2wmGhvZrfJbgw9C09T)CK76NCuDb10KAIYGGA4OdNrxOfBJKAAsnt1p1qk1afgG9tTjgaYtyhuw5qFqNh8GLQvmzyGNCuDb2wmGhvZrfJbSKAGWOIJQRBW1ujmh4IC9T)CK7udrIuZWQNJwoJRCkCER8g0p5O6cQPj1eLbb1YzCLtHZBL3Gwgo1yd10KASKA8wzeShOgcutRudrIuJLudIlH7qEo6(c59NJUsQHuQbkjOMMudIlH7qEoAwic6kPgsPgOKGASHASbdW(P2edaELdjhSIhSuTdtgg4jhvxGTfd4r1CuXya2pfK7E(E9a1qk1iEOqx4ggb7tGAisKAqCjChYZrZcrqxj1qk10ojWaSFQnXaGx5ImcXWoEWsrcyYWap5O6cSTyapQMJkgdaHrfhvxhvS4obN(Jby)uBIbeNhRUqJF44blLfXKHby)uBIbQEFv8uB6yzeJbEYr1fyBXdwksetgg4jhvxGTfd4r1CuXyaPPgimQ4O66gCnvcZbUixF7ph5o10KASKAy)uqU7571dudPuJ4HcDHByeSpbQHirQbXLWDiphnlebDLudPudusqn2Gby)uBIbGP4cYDZ7WFyWdwklaMmmWtoQUaBlgWJQ5OIXa(nfY1OdhH45chmfxqU(jhvxqnnPg)UkX2i1N87IN7A07CLbQHKudjsnnPgPPMOmiOU)H7lcU1nubTmCQPj1in1iEugeu)2d(gUW1yLtHwgogG9tTjgySI2goykUGC8GLYcHjdd8KJQlW2Ib8OAoQyma7NcYDpFVEGAiLAGIAAsnwsnstniUeUd55OzHiOF7vHjqnejsniUeUd55OzHiOLHtn2qnnPgPPgimQ4O66gCnvcZbUixF7ph5ogG9tTjg4KFx8ChpyPAPyYWap5O6cSTyapQMJkgdaHrfhvxhvS4obN(Jby)uBIbIkwCNGt)XdwkOKatgg4jhvxGTfd4r1CuXyaqze5AXblFnudPeOgsqcma7NAtma4vrfloEWsbfuyYWap5O6cSTyapQMJkgdin1mS65OJQkfoqze56NCuDb10KAKMAGWOIJQRBW1ujmh4ICpeE6VlIo3g10KAqCjChYZrZcrqxj1qk1W(P2053vj2gjgG9tTjg4KFx8ChpyPGQvmzyGNCuDb2wmGhvZrfJbSKAgw9C0I330fvS4b9toQUGAisKAKMAGWOIJQRBW1ujmh4IC9T)CK7udrIudOmICT4GLVgQHKut7KGAisKAIYGG6(hUVi4w3qf0O35kdudjPglsn2qnnPgPPgimQ4O6A47QQeMdCrUOIf3j40FQPj1in1aHrfhvx3GRPsyoWf5Ei80FxeDUnma7NAtmaNzzTu8uBIhSuq1omzyGNCuDb2wmGhvZrfJbSKAgw9C0I330fvS4b9toQUGAisKAKMAGWOIJQRBW1ujmh4IC9T)CK7udrIudOmICT4GLVgQHKut7KGASHAAsnstnqyuXr11W3vvjmh4IC9pm10KAKMAGWOIJQRHVRQsyoWf5IkwCNGt)PMMuJ0udegvCuDDdUMkH5axK7HWt)Dr052WaSFQnXaER8gCHbvTD8GLcksatgg4jhvxGTfd4r1CuXyGHvphDuvPWbkJix)KJQlOMMudIlH7qEoAwic6kPgsPg2p1Mo)UkX2iXaSFQnXaN87IN74blfuwetgg4jhvxGTfd4r1CuXyaKCEWfb76OmkReMRXkNc9TGKl4WVGAAsnIhLbb1rzuwjmxJvofA07CLbQHKudjGby)uBIbeVVzWfR5yGHrW(4kqmaEWsbfjIjddW(P2ediEFZGlwZXap5O6cST4blfuwamzyGNCuDb2wmGhvZrfJbKMAgw9C09T)CK76NCuDb10KAqCjChYZr3xiV)C0vsnKsnERmc2dutlNAGscQPj1mS65OfVVPlQyXd6NCuDbgG9tTjga8khsoyfpyPGYcHjdd8KJQlW2Ib8OAoQymqFH8(ZrlQWWP)udPuduwKAisKAIYGG6vEClOdXjSRLHJby)uBIbaVkQyXXdwkOAPyYWap5O6cSTyapQMJkgd0xiV)C0IkmC6p1qk1aLfPgIePglPMOmiOELh3c6qCc7Az4uttQrAQzy1Zr33(ZrURFYr1fuJnya2p1MyaWRCi5Gv8GLQvjWKHbEYr1fyBXaEunhvmgOVqE)5Ofvy40FQHuQbklIby)uBIbG8e2bLvo0h05bpyPAfkmzyGNCuDb2wmGhvZrfJbgw9C0I330fvS4b9toQUadW(P2edmwrBdhmfxqoEWdg4HWt)dyYWsbfMmmWtoQUaBlgyHJbcFWaSFQnXaqyuXr1XaqyL8Xa(DvITrQbVYfzeIHDn6SGCQPj1yj1yj1yj1in1mS65OfVVz51p5O6cQHirQjkdcQ7F4(IGBDdvqldNASHAAsnstnqyuXr11n4AQeMdCrU(2FoYDQPj1G4s4oKNJMfIGUsQHuQPDsqn2qnejsnSFki39896bQHuQr8qHUWnmc2Na1ydgacJCj3pga8kxKrig2DbYtpgWJQ5OIXadREoAWRCrgHyyx)KJQlWdwQwXKHbEYr1fyBXaEunhvmgWsQrAQrSJ2VP)5G45chOI73fLrPEkFBvcJAAsnstnSFQn1(n9phepx4avC)6kDGQcM1HAisKAaLvkh6ERmc2Dt1p1qsQbMxO7C7rn2Gby)uBIb8B6FoiEUWbQ4(XdwQ2Hjdd8KJQlW2Ib8OAoQymGLuJ0uZWQNJg8kxKrig21p5O6cQHirQXVRsSnsn4vUiJqmSRrVZvgOgsPgsWIuJnuttQrAQbcJkoQUUbxtLWCGlY13(ZrUtnnPglPglPgPPMHvphT49nlV(jhvxqnejsnrzqqD)d3xeCRBOcAz4uttQrAQXVRsSnsDuXI7eC6VgDwqo1yd1qKi1awWSoo07CLbQHKeOgOKGASbdW(P2edev7kClOBSE3Z3jhpyPibmzyGNCuDb2wmGhvZrfJbgw9C0Gx5ImcXWU(jhvxqnnPgimQ4O6AWRCrgHyy3fip9ya2p1MyGOAxHBbDJ17E(o54blLfXKHbEYr1fyBXaEunhvmgWsQjkdcQ7F4(IGBDdvqldNAAsn(DvITrQ7F4(IGBDdvqJoliNASHAisKAIYGG6(hUVi4w3qf0O35kdudPutRwKAisKAalywhh6DUYa1qscut7KadW(P2edatMrIIt3c64w4ODSIhSuKiMmmWtoQUaBlgWJQ5OIXab4xPCdJG9jOJkwCNGt)HIAiLa10k1qKi1G4s4oKNJMfIGUsQHuQHeLadW(P2edaUE5WfoUfoQM7IN74blLfatgg4jhvxGTfd4r1CuXyGa8RuUHrW(e0rflUtWP)qrnKsGAALAisKAqCjChYZrZcrqxj1qk1qIsGby)uBIbGlJkqYReMlQ4WGhSuwimzyGNCuDb2wmGhvZrfJbIYGGA09TPEi4axK)Az4udrIutugeuJUVn1dbh4I835x5Coshg23g1qsQbkjWaSFQnXaJ17KZ4kNch4I8hpyPAPyYWaSFQnXaOcoC1Dv6cWz)Xap5O6cST4blfusGjdd8KJQlW2Ib8OAoQymqugeu3)W9fb36gQGwgo1qKi1aHrfhvxdELlYied7Ua5PhdW(P2ed0yrkbKxPd9WMC6pEWsbfuyYWap5O6cSTyapQMJkgdakJiNAij1qcsqnnPMOmiOU)H7lcU1nubTmCma7NAtmq)9frUBbDkzFjCc05EapyPGQvmzyGNCuDb2wmGhvZrfJbggb7JEQ(DZ6e1PgssnqPTi1qKi1yj1yj1mmc2hT1ZQXQgUFOgsPglKeudrIuZWiyF0wpRgRA4(HAijbQPvjOgBOMMuJLud7NcYDpFVEGAiqnqrnejsndJG9rpv)UzDI6udPutRTuQXgQXgQHirQXsQzyeSp6P63nRdUFCTkb1qk10ojOMMuJLud7NcYDpFVEGAiqnqrnejsndJG9rpv)UzDI6udPudjqcuJnuJnya2p1Mya0z4vcZbQ4(dyap5E1DdJG9jGLck8GhmG4GSSAWKHLckmzya2p1MyarfqYWhmWtoQUaBlEWs1kMmma7NAtmGFZGC)UodR8yGNCuDb2w8GLQDyYWap5O6cSTyGfogi8bdW(P2edaHrfhvhdaHvYhdmS65ObluyCr1Uc9toQUGAisKAcWVs5ggb7tqhvS4obN(df1qkbQXsQPDutlIAgw9C0dIlLBbDi5k1p5O6cQXgmaeg5sUFmquXI7eC6pEWsrcyYWap5O6cSTyGfogi8bdW(P2edaHrfhvhdaHvYhdin1mS65OfVVz51p5O6cQPj143vj2gPU)H7lcU1nubn6DUYa1qsQHePMMudOmICT4GLVgQHuQPDsGbGWixY9JbGVRQsyoWf56Fy8GLYIyYWap5O6cSTyGfogi8bdW(P2edaHrfhvhdaHvYhdaHrfhvxhvS4obN(tnnPglPgqze5udjPglGfPMwe1mS65ObluyCr1Uc9toQUGAA5utRsqn2GbGWixY9JbGVRQsyoWf5IkwCNGt)Xdwksetgg4jhvxGTfdSWXaHpya2p1MyaimQ4O6yaiSs(yGHvphT49nlV(jhvxqnnPgPPMHvphDuvPWbkJix)KJQlOMMuJFxLyBK6t(DXZDn6DUYa1qsQXsQbMxO7C7rnTCQPvQXgQPj1akJixloy5RHAiLAAvcmaeg5sUFma8DvvcZbUi3j)U45oEWszbWKHbEYr1fyBXalCmq4dgG9tTjgacJkoQogacRKpgyy1Zr)q4P)Ui6CB6NCuDb10KAKMAGWOIJQRHVRQsyoWf5IkwCNGt)PMMuJ0udegvCuDn8DvvcZbUix)dtnnPg)UkX2i1peE6VlIo3MwgogacJCj3pgObxtLWCGlY9q4P)Ui6CB4blLfctgg4jhvxGTfdSWXaHpya2p1MyaimQ4O6yaiSs(yGHvphDF7ph5U(jhvxqnnPgPPMOmiOUV9NJCxldhdaHrUK7hd0GRPsyoWf56B)5i3XdwQwkMmmWtoQUaBlgG9tTjgWZkLJ9tTPtvHbd4r1CuXyayEHg9oxzGAiqnsGbuvyCj3pgWVRsSns8GLckjWKHbEYr1fyBXaEunhvmgikdcQbVYf3EKrI(Zrhg23g1qGASi10KASKAIYGG6Q3xfp1MowgXAz4udrIuJ0utugeu3)W9fb36gQGwgo1ydgG9tTjgySI2goykUGC8GLckOWKHbEYr1fyBXaSFQnXaEwPCSFQnDQkmyapQMJkgdmS65OFi80FxeDUn9toQUGAAsnwsnqyuXr11n4AQeMdCrUhcp93frNBJAisKAepkdcQFi80FxeDUnTmCQXgmGQcJl5(XapeE6VlIo3gEWsbvRyYWap5O6cSTya2p1MyaKC6y)uB6uvyWaEunhvmgyy1ZrlEFZYRFYr1fyavfgxY9JbeVVz5XdwkOAhMmmWtoQUaBlgG9tTjgajNo2p1MovfgmGQcJl5(Xa5I6Scp4bdahD)2J8GjdlfuyYWap5O6cSTyGK7hdWTqWkJ4GdCZXTGo4BJJWaSFQnXaCleSYio4a3CClOd(24i8GhmGFxLyBKyYWsbfMmmWtoQUaBlgWJQ5OIXastnwsndREoAX7BwE9toQUGAisKAGWOIJQRHVRQsyoWf56FyQXgQHirQbSGzDCO35kdudjPMwTigG9tTjgO)H7lcU1nub8GLQvmzyGNCuDb2wmGhvZrfJbgw9C0I33S86NCuDb10KASKAKMA4w4OAU2BL3P8UbXzaCrDEQn1p5O6cQHirQXsQXVRsSns9j)U45Ug9oxzGAiLAAvcQPj1yj1in1aHrfhvxhvS4obN(tnejsn(DvITrQJkwCNGt)1O35kdudPudmVq352JASHASHASbdW(P2ed0)W9fb36gQaEWs1omzyGNCuDb2wmGhvZrfJbKMAe7OdvckRCreNc9u(2QeggG9tTjgiujOSYfrCkWdwksatggG9tTjgySENv5CWap5O6cST4blLfXKHby)uBIbaxH4i3SUX6DGkUFmWtoQUaBlEWsrIyYWaSFQnXaxrEO40jUh9JbEYr1fyBXdwklaMmmWtoQUaBlgWJQ5OIXarzqqD)d3xeCRBOcA07CLbQHuQPvlsnejsnGfmRJd9oxzGAij1qIsGby)uBIbGVtTjEWszHWKHbEYr1fyBXaj3pgagRUNvQJcU4UjgG9tTjgagRUNvQJcU4UjgWJQ5OIXastndREoAWRCrgHyyx)KJQlOgIePg)UkX2i1Gx5ImcXWUgDwqoEWs1sXKHbEYr1fyBXaEunhvmgikdcQ7F4(IGBDdvqldNAAsnrzqqD)9frUBbDkzFjCc05Eql2gj10KASKAKMAGWOIJQRJkwCNGt)PgIePgPPg)UkX2i1rflUtWP)A0zb5uJnya2p1Myap5E1oOnlVlQ4WGboi49Jl5(XaEY9QDqBwExuXHbpyPGscmzyGNCuDb2wmqY9Jb4GviC(GdXTWIC(fXkma7NAtmahScHZhCiUfwKZViwHb8OAoQymG4rzqqnIBHf58lIvoXJYGGAX2iPgIePglPgXJYGGA)Mcz)uqURY2CIhLbb1YWPgIePMOmiOU)H7lcU1nubn6DUYa1qk10QeuJnuttQzyeSpARNvJvnC)qnKKAAhuudrIudybZ64qVZvgOgssnTkbEWsbfuyYWap5O6cSTyGK7hdWTqWkJ4GdCZXTGo4BJJWaSFQnXaCleSYio4a3CClOd(24imGhvZrfJb87QeBJu3)W9fb36gQGg9oxzGAij1aLeudrIuJFxLyBK6(hUVi4w3qf0O35kdudPudjkbEWsbvRyYWap5O6cSTyapQMJkgdeLbb19pCFrWTUHkOLHJby)uBIbKd3vZ7b8GLcQ2Hjdd8KJQlW2Iby)uBIb8Ss5y)uB6uvyWaQkmUK7hd8q4P)b8GhmWdHN(7IOZTHjdlfuyYWap5O6cSTyapQMJkgdakJiNAiLa1yHKGAAsnwsn(DvITrQJkwCNGt)1OZcYPgIePgPPgimQ4O66OIf3j40FQXgma7NAtmWdHN(7IOZTHhSuTIjdd8KJQlW2Ib8OAoQymaegvCuDDuXI7eC6p10KAepkdcQFi80FxeDUnTmCma7NAtmG48y1fA8dhpyPAhMmmWtoQUaBlgWJQ5OIXaqyuXr11rflUtWP)uttQr8OmiO(HWt)Dr0520YWXaSFQnXarflUtWP)4blfjGjdd8KJQlW2Ib8OAoQymG4rzqq9dHN(7IOZTPLHJby)uBIb4mlRLINAt8GLYIyYWap5O6cSTyapQMJkgdiEugeu)q4P)Ui6CBAz4ya2p1MyaVvEdUWGQ2oEWdgq8(MLhtgwkOWKHbEYr1fyBXaEunhvmgWsQzy1ZrlNXvofoVvEd6NCuDb10KAIYGGA5mUYPW5TYBqldNASHAAsnwsnERmc2dudbQPvQHirQXsQbXLWDiphDFH8(Zrxj1qk1aLeuttQbXLWDiphnlebDLudPudusqn2qn2Gby)uBIbaVYHKdwXdwQwXKHbEYr1fyBXaEunhvmgacJkoQUoQyXDco9hdW(P2ediopwDHg)WXdwQ2Hjdd8KJQlW2Ib8OAoQyma7NcYDpFVEGAiLAepuOlCdJG9jqnejsniUeUd55OzHiORKAiLAGscma7NAtmamfxqUBEh(ddEWsrcyYWap5O6cSTyapQMJkgd43uixJoCeINlCWuCb56NCuDb10KA87QeBJuFYVlEURrVZvgOgssnKi10KAKMAIYGG6(hUVi4w3qf0YWPMMuJ0uJ4rzqq9Bp4B4cxJvofAz4ya2p1MyGXkAB4GP4cYXdwklIjdd8KJQlW2Ib8OAoQymaIlH7qEoAwicAz4udrIudIlH7qEoAwic6kPgsPMwTigG9tTjg4KFx8ChpyPirmzyGNCuDb2wmGhvZrfJbGWOIJQRJkwCNGt)PMMuJ0uJFxLyBK6(hUVi4w3qf0OZcYPMMuJLuJFxLyBK6t(DXZDn6DUYa1qk1yj1yrQPfrnClCunxJoKvbPsyUOIfpOrC2g10YPM2rn2qnejsnwsniUeUd55OzHiORKAiLAy)uB687QeBJKAAsniUeUd55OzHiORKAij10QfPgBOgBWaSFQnXarflUtWP)4blLfatggG9tTjgO69vXtTPJLrmg4jhvxGTfpyPSqyYWap5O6cSTyapQMJkgdin1aHrfhvxdFxvLWCGlYfvS4obN(Jby)uBIb4mlRLINAt8GLQLIjdd8KJQlW2Ib8OAoQymaOmICT4GLVgQHucudjibgG9tTjga8QOIfhpyPGscmzyGNCuDb2wmGhvZrfJbKMAGWOIJQRHVRQsyoWf5IkwCNGt)PMMuJ0udegvCuDn8DvvcZbUi3j)U45ogG9tTjgWBL3GlmOQTJhSuqbfMmmWtoQUaBlgWJQ5OIXadREoAX7B6Ikw8G(jhvxqnnPgPPg)UkX2i1N87IN7A0zb5uttQXsQXBLrWEGAiqnTsnejsnwsniUeUd55O7lK3Fo6kPgsPgOKGAAsniUeUd55OzHiORKAiLAGscQXgQXgma7NAtma4voKCWkEWsbvRyYWap5O6cSTyapQMJkgdGKZdUiyxhLrzLWCnw5uOVfKCbh(futtQr8OmiOokJYkH5ASYPqJENRmqnKKAibma7NAtmG49ndUynhd4j3RUByeSpbSuqHhSuq1omzya2p1MyaX7BgCXAog4jhvxGTfpyPGIeWKHbEYr1fyBXaEunhvmgikdcQx5XTGoeNWUwgogG9tTjgySI2goykUGC8GLcklIjdd8KJQlW2Ib8OAoQymqFH8(ZrlQWWP)udPuduwKAisKAIYGG6vEClOdXjSRLHJby)uBIbaVYHKdwXdwkOirmzyGNCuDb2wmGhvZrfJb6lK3FoArfgo9NAiLAGYIya2p1MyaipHDqzLd9bDEWdwkOSayYWap5O6cSTyapQMJkgdmS65OfVVPlQyXd6NCuDbgG9tTjgySI2goykUGC8Gh8Gh8GXa]] )
end
