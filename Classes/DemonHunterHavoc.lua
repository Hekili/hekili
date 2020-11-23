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


    spec:RegisterPack( "Havoc", 20201123, [[dG0IrbqieLhbsr2Kq8jqknkkPofLIvHII8kHKzHICluuODrQFrPQHrj5yGKLju5zcPAAGu11OuY2OukFdKknouuY5aPOwhLsvZdfv3dH2hk0brrrTqkvEiivyIGurDrqQi2iivK(iifyKOOuojkkyLGkZefLQDIOAPGuOEkqtff8vqkOXsPuzVq9xQAWuCyIflXJPYKr1LvTzaFgugnL40kETqvZMKBlPDl63knCe54GuilhYZfmDPUokTDq8DHY4fsX5bvTEHuA(iy)ingkmdyqU0htECwfNvqbvCrxdLTSIzbfgSHN0XGKex8cSJbtPEmiZMazDyqsc8Qv4ygWGHLf5ogeCQSkPNnHoqcqJblSJQzgsCbdYL(yYJZQ4SckOIl6AOSLvmlRGUyWaP7WKBlOl0fdAz48N4cgK)GddcnrnqNFDtQHzJn7JOgMnbY6OWbnrnKVqETCe1ex0zIAIZQ4ScdscTaJ6yqOjQb68RBsnmBSzFe1WSjqwhfoOjQH8fYRLJOM4IotutCwfNvu4OWbnrnGPqkyzBQbjdNAkSaaNtnHw6a1uoWIo142ArAQPCytgOgj5udj0zgjTDpjmQzcudFZRPWjUE2mOjHUBRfPJIO9SH7N(vMsPEIs0gSiij4b2S9lGN0g7ikCu4GMOgOtIM7y7ZPMd5i4PMEQNAAlNAexViQzcuJargLuuxtHtC9SzGiFciwsnfoX1ZMHOiAVBZaB9(QaBCu4expBgIIO9qe0if1zkL6jwuc)EUKUZeerXEITOE2AGbfAFrTlx)ukQZjqiq6kLVfeS3bDrj875s6oums06OZm2I6zRBKmk)c4rStQFkf152qGaInpWIGDTZISbFB5lc(ifwaaTZISbFB5lcEnFJLu4expBgIIO9qe0if1zkL6jsAx1KW8alYxFlmbruSNizTOE2A(RBoo9tPOopIBxfFJL66BPUisw2We0OxLjdm32IaWIGxZpW4MMXOBffoX1ZMHOiApebnsrDMsPEIK2vnjmpWI8fLWVNlP7mbruSNiebnsrDDrj875s6EeRbyrWZCORTygBr9S1adk0(IAxU(PuuNZmfNv2qHtC9SzikI2drqJuuNPuQNiPDvtcZdSi)H)(YLktqef7j2I6zR5VU540pLI68iK1I6zRlQj5Eawe86NsrDEe3Uk(gl1h(7lxQA0RYKbMBnmhxxLOHzkoBIaWIGxZpW4MMX4SIcN46zZqueThIGgPOotPupXyY0tcZdSi)dHNU7lOlXZeerXEITOE26hcpD3xqxIx)ukQZJqgebnsrDnPDvtcZdSiFrj875s6EeYGiOrkQRjTRAsyEGf5RVLiUDv8nwQFi80DFbDjEnljkCIRNndrr0EicAKI6mLs9eJjtpjmpWI81T(SzRmbruSNylQNTUU1NnBv)ukQZJqwHfaqx36ZMTQzjrHtC9SzikI27eLYlUE20RMqZuk1t0TRIVXsMgaIWCCn6vzYarROWjUE2mefr7BlOnMhMsgiNPbGyHfaqdCLVS1IG41NTo0IlEI2kI1fwaa9uRRs6ztVWIenljceiRWcaORVL6IizzdtqZsYgkCIRNndrr0ENOuEX1ZME1eAMsPEIpeE6UVGUeptdaXwupB9dHNU7lOlXRFkf15rSgIGgPOUoMm9KW8alY)q4P7(c6s8eiWFHfaq)q4P7(c6s8Aws2qHtC9SzikI2JytV46ztVAcntPupr(RBooMgaITOE2A(RBoo9tPOoNcN46zZqueThXMEX1ZME1eAMsPEI5IQIIchfoX1ZMbTBxfFJLeRVL6IizzdtGPbGizw3I6zR5VU540pLI6CceGiOrkQRjTRAsyEGf5RVfBIynzUfYtjBnKNTf4r6NsrDobcKX3whMeGv5lij56ECXpjmBiqayGzP9OxLjdmpoBrHtC9Szq72vX3yzueTV(wQlIKLnmbMgaITOE2A(RBoo9tPOopI1UDv8nwQp83xUu1OxLjdmgNvrSMmicAKI66Is43ZL0DceC7Q4BSuxuc)EUKURrVktgyeMJRRs0yJnrSMm3c5PKTgYZ2c8i9tPOoNabY4BRdtcWQ8fKKCDpU4NeMnu4expBg0UDv8nwgfr7dtcWQ8fKKCMgaIKX3whMeGv5lij56ECXpjmkCIRNndA3Uk(glJIO9TL7TWMntdarYAr9S18x3CC6NsrDEeYGiOrkQRJjtpjmpWI81T(SzReiuyba0aSOzzdEys0EnljkCIRNndA3Uk(glJIO9alNFKVxFB5EaLupfoX1ZMbTBxfFJLrr0(RGpms653H(PWjUE2mOD7Q4BSmkI2tA7ztMgaIfwaaD9TuxejlBycA0RYKbgJZweiamWS0E0RYKbMBBwrHtC9Szq72vX3yzueTNnC)0VYuk1teMOUtuQJc(YUjtdarYAr9S1ax5lccjWU(PuuNtGGBxfFJLAGR8fbHeyxJUWHNcN46zZG2TRIVXYOiApB4(PFLPdaCx7tPEIo4DQTrBooFrjHMPbGyHfaqxFl1frYYgMGMLuKclaGU(6IG3VaEfRB4Eo6snO5BSmI1KbrqJuuxxuc)EUKUtGazUDv8nwQlkHFpxs31OlC4THcN46zZG2TRIVXYOiApB4(PFLPuQNOeSarYh8ijAxK3TirX0aqK)claGgjr7I8Ufjkp)fwaanFJLeiyn)fwaaTBtoRRhi3pz8E(lSaaAwseiuyba013sDrKSSHjOrVktgymoRSjsliyV1wUOAlAsUM5rhkceagywAp6vzYaZJZkkCIRNndA3Uk(glJIO9SH7N(vMsPEIs0gSiij4b2S9lGN0g7iMgaIUDv8nwQRVL6IizzdtqJEvMmWCOSIab3Uk(gl113sDrKSSHjOrVktgy02SIch0e1aD(acRQPgarPkIlEQbyrudBqkQtnt)AqtHtC9Szq72vX3yzueTNnC)0VgyAaiwyba013sDrKSSHjOzjrHtC9Szq72vX3yzueT3jkLxC9SPxnHMPuQN4dHNUhOWrHtC9SzqZFDZXre4kpInyHPbGO1TOE2A2SSSj37SiBq)ukQZJuyba0SzzztU3zr2GMLKnrS2zrqWEGyCeiynsgU)qE266c51NTEsgHYQiiz4(d5zRfopONKrOSYgBOWjUE2mO5VU54IIO98lTfFi2pjMgaIqe0if11fLWVNlP7u4expBg08x3CCrr0EykzGCF)kPhAMgaIIRhi3)815bg5pmOZ9TGG9oqGasgU)qE2AHZd6jzekROWjUE2mO5VU54IIO9Tf0gZdtjdKZ0aq0TjNDAD4iK0N7HPKbY1pLI68iUDv8nwQp83xUu1OxLjdm32IqwHfaqxFl1frYYgMGMLueY4VWcaOF0qAdN7JTSjxZsIcN46zZGM)6MJlkI2F4VVCPY0aqejd3FipBTW5bnljceqYW9hYZwlCEqpjJXzlkCIRNndA(RBoUOiAFrj875s6otdaricAKI66Is43ZL09iK52vX3yPU(wQlIKLnmbn6ch(iw72vX3yP(WFF5svJEvMmWOTiqWAKmC)H8S1cNh0tYOBxfFJLrqYW9hYZwlCEqpjZJZw2ydfoX1ZMbn)1nhxueTFQ1vj9SPxyrcfoX1ZMbn)1nhxueTxYCSmkPNnzAaisgebnsrDnPDvtcZdSiFrj875s6ofoX1ZMbn)1nhxueTh4QIs4NPbGialcEn)aJBAgjc9wrHtC9SzqZFDZXffr7DwKn4dnAI)mnaejdIGgPOUM0UQjH5bwKVOe(9CjDpczqe0if11K2vnjmpWI8h(7lxQu4expBg08x3CCrr0EGR8i2GfMgaITOE2A(RB6lkH)G(PuuNhHm3Uk(gl1h(7lxQA0fo8rS2zrqWEGyCeiynsgU)qE266c51NTEsgHYQiiz4(d5zRfopONKrOSYgBOWjUE2mO5VU54IIO98x3m4ltFMCW7u33cc27arOyAaiIyZdSiyxxyr5KW8Xw2KhH)claGUWIYjH5JTSjxJEvMmWCONcN46zZGM)6MJlkI2ZFDZGVm9PWjUE2mO5VU54IIO9Tf0gZdtjdKZ0aqSWcaOx22VaEKKWUMLefoX1ZMbn)1nhxueTh4kpInyHPbGyDH86ZwZNqlP7mcLTiqOWcaOx22VaEKKWUMLefoX1ZMbn)1nhxueThYtyhGv5rVrxAMgaI1fYRpBnFcTKUZiu2IcN46zZGM)6MJlkI23wqBmpmLmqotdaXwupBn)1n9fLWFq)ukQZPWrHtC9Szq)q4P7(c6s8eFi80DFbDjEMgaIaSi4zKiZYQiw72vX3yPUOe(9CjDxJUWHNabYGiOrkQRlkHFpxs3THcN46zZG(HWt39f0L4JIO98lTfFi2pjMgaIqe0if11fLWVNlP7r4VWcaOFi80DFbDjEnljkCIRNnd6hcpD3xqxIpkI2xuc)EUKUZ0aqeIGgPOUUOe(9CjDpc)fwaa9dHNU7lOlXRzjrHtC9Szq)q4P7(c6s8rr0EjZXYOKE2KPbGi)fwaa9dHNU7lOlXRzjrHtC9Szq)q4P7(c6s8rr0ENfzd(qJM4ptdar(lSaa6hcpD3xqxIxZsIchfoX1ZMb9dHNUhicrqJuuNPuQNiWv(IGqcS7dWNoMgaITOE2AGR8fbHeyx)ukQZzcIOypr3Uk(gl1ax5lccjWUgDHdFeRT2AYAr9S18x3CC6NsrDobcfwaaD9TuxejlBycAws2eHmicAKI66yY0tcZdSiFDRpB2AeKmC)H8S1cNh0tYy0TYgceexpqU)5RZdmYFyqN7Bbb7DWgkCIRNnd6hcpDpefr7DB6E2iPp3dOK6zAaiAnz8T1UnDpBK0N7bus9(clk194IFsyritC9SP2TP7zJK(CpGsQxpPhqnWS0eiaWQuE0DweeS77PEMdZX1vjASHch0e1Wm39RKAQPxQjaF6OMytBHAGo9kQXobHeyNAwe1WmVqNqnda1mn1eBukQPCQHnCo1eBAltsnTLtn5JMMAGEBrnH72KhyIA22YrXMWPg2WPgolAsyutUOQOOMclk0udxQcSRPWjUE2mOFi809queTVO2L7xaFB5(NVcptdarRjRf1ZwdCLViiKa76NsrDobcUDv8nwQbUYxeesGDn6vzYaJqVTSjczqe0if11XKPNeMhyr(6wF2S1iwBnzTOE2A(RBoo9tPOoNaHclaGU(wQlIKLnmbnlPiK52vX3yPUOe(9CjDxJUWH3gceagywAp6vzYaZjcLv2qHtC9Szq)q4P7HOiAFrTl3Va(2Y9pFfEMgaITOE2AGR8fbHeyx)ukQZJarqJuuxdCLViiKa7(a8PJcN46zZG(HWt3drr0EyScIps6xaVeThTTfMgaIwxyba013sDrKSSHjOzjfXTRIVXsD9TuxejlBycA0fo82qGqHfaqxFl1frYYgMGg9QmzGX4SfbcadmlTh9QmzG5eJUvu4expBg0peE6EikI2dSo2W5EjApA67lxQmnaedKUs5Bbb7Dqxuc)EUKUdfJeJJabKmC)H8S1cNh0tYOTzffoX1ZMb9dHNUhIIO9Kyrda8tcZxusOzAaigiDLY3cc27GUOe(9CjDhkgjghbciz4(d5zRfopONKrBZkkCIRNnd6hcpDpefr7Bl3ZMLLn5EGf5otdaXclaGgDx8QhcEGf5UMLebcfwaan6U4vpe8alYDVBzZ(iDOfx8mhkROWjUE2mOFi809queThnKiPUFsFGK4ofoX1ZMb9dHNUhIIO9XwKId5t6rpSPKUZ0aqSWcaORVL6IizzdtqZsIabicAKI6AGR8fbHey3hGpDu4expBg0peE6EikI2xFDrW7xaVI1nCphDPgyAaicWIGN5qVvrkSaa66BPUisw2We0SKOWjUE2mOFi809queThDH0KW8akP(ato4DQ7Bbb7DGiumnaeBbb7TUN69965ZzouABrGG1w3cc2BTLlQ2IMKRzKzzfbcTGG9wB5IQTOj5AMtmoRSjI1IRhi3)815bIqrGqliyV19uVVxpFoJXbnBJneiyDliyV19uVVxpjx7JZkgJUvrSwC9a5(NVopqekceAbb7TUN69965Zze6HEBSHchfoX1ZMbDUOQOic5jSdWQ8O3OlntdaXwupBDDRpB2Q(PuuNhPWcaOjHojbDUMVXYi9upJqrHtC9SzqNlQkQOiApWvEeBWctdarRHiOrkQRJjtpjmpWI81T(SzRei0I6zRzZYYMCVZISb9tPOopsHfaqZMLLn5ENfzdAws2eXANfbb7bIXrGG1iz4(d5zRRlKxF26jzekRIGKH7pKNTw48GEsgHYkBSHcN46zZGoxuvurr0EGR8fbHeyNPbGO46bY9pFDEGr(dd6CFliyVdeiGKH7pKNTw48GEsgJUvu4expBg05IQIkkI2ZV0w8Hy)KyAaicrqJuuxxuc)EUKUtHtC9SzqNlQkQOiA)uRRs6ztVWIekCIRNnd6Crvrffr7HPKbY99RKEOzAaisgebnsrDDmz6jH5bwKVU1NnBnI1IRhi3)815bg5pmOZ9TGG9oqGasgU)qE2AHZd6jzekRSHcN46zZGoxuvurr0(2cAJ5HPKbYzAai62KZoToCes6Z9WuYa56NsrDEe3Uk(gl1h(7lxQA0RYKbMBBriRWcaORVL6IizzdtqZskcz8xyba0pAiTHZ9Xw2KRzjrHtC9SzqNlQkQOiA)H)(YLktdarX1dK7F(68aJqfXAYqYW9hYZwlCEq)OzcDGabKmC)H8S1cNh0SKSjczqe0if11XKPNeMhyr(6wF2SvkCIRNnd6Crvrffr7lkHFpxs3zAaicrqJuuxxuc)EUKUtHtC9SzqNlQkQOiApWvfLWptdarawe8A(bg30mse6TIcN46zZGoxuvurr0(d)9LlvMgaIK1I6zRlQj5Eawe86NsrDEeYGiOrkQRJjtpjmpWI8peE6UVGUeFeKmC)H8S1cNh0tYOBxfFJLu4expBg05IQIkkI2lzowgL0ZMmnaeTUf1ZwZFDtFrj8h0pLI6CceidIGgPOUoMm9KW8alYx36ZMTsGaalcEn)aJBAMhDRiqOWcaORVL6IizzdtqJEvMmWCBzteYGiOrkQRjTRAsyEGf5lkHFpxs3JqgebnsrDDmz6jH5bwK)HWt39f0L4PWjUE2mOZfvfvueT3zr2Gp0Oj(Z0aq06wupBn)1n9fLWFq)ukQZjqGmicAKI66yY0tcZdSiFDRpB2kbcaSi418dmUPzE0TYMiKbrqJuuxtAx1KW8alYxFlridIGgPOUM0UQjH5bwKVOe(9CjDpczqe0if11XKPNeMhyr(hcpD3xqxINcN46zZGoxuvurr0(d)9LlvMgaITOE26IAsUhGfbV(PuuNhbjd3FipBTW5b9Km62vX3yjfoX1ZMbDUOQOIIO98x3m4ltFMCW7u33cc27arOyAaiIyZdSiyxxyr5KW8Xw2KhH)claGUWIYjH5JTSjxJEvMmWCONcN46zZGoxuvurr0E(RBg8LPpfoX1ZMbDUOQOIIO9ax5rSblmnaejRf1Zwx36ZMTQFkf15rqYW9hYZwxxiV(S1tYOZIGG9aZeuwfPf1ZwZFDtFrj8h0pLI6CkCIRNnd6Crvrffr7bUQOe(zAaiwxiV(S18j0s6oJqzlcekSaa6LT9lGhjjSRzjrHtC9SzqNlQkQOiApWvEeBWctdaX6c51NTMpHws3zekBrGG1fwaa9Y2(fWJKe21SKIqwlQNTUU1NnBv)ukQZTHcN46zZGoxuvurr0EipHDawLh9gDPzAaiwxiV(S18j0s6oJqzlkCIRNnd6Crvrffr7BlOnMhMsgiNPbGylQNTM)6M(Is4pOFkf15yqihfMnXKhNvXzfuwfh0JbJjOCsybmi0qMzOXKZmqo0aBp1qnmy5uZujTOMAawe1aT5IQIcAPg0HgXoOZPMWwp1iS9wL(CQXzrsypOPWXSp5PgOSLTNAGo2eYr95ud0IyZdSiyxB7GwQPxQbArS5bweSRTD6NsrDo0snwdv0yJMchfoOHmZqJjNzGCOb2EQHAyWYPMPsArn1aSiQbA5hqyvn0snOdnIDqNtnHTEQry7Tk95uJZIKWEqtHJzFYtnr32tnqhBc5O(CQbArS5bweSRTDql10l1aTi28alc212o9tPOohAPgRHkASrtHJblNAawLAJnjmQryrsGAID0Pg2W5uZKutB5uJ46ztQrnHMAkSn1e7Otn52udWYMCQzsQPTCQr48nPgU0src32tHJAygPgNfzd(2Yxe8u4OWbnKzgAm5mdKdnW2tnuddwo1mvslQPgGfrnqRBxfFJLql1Go0i2bDo1e26PgHT3Q0Ntnolsc7bnfoM9jp1aLTNAGo2eYr95ud06wipLS12o9tPOohAPMEPgO1TqEkzRTDql1ynurJnAkCm7tEQjoBp1aDSjKJ6ZPgO1TqEkzRTD6NsrDo0sn9snqRBH8uYwB7GwQXAOIgB0u4OWbnKzgAm5mdKdnW2tnuddwo1mvslQPgGfrnql)1nhh0snOdnIDqNtnHTEQry7Tk95uJZIKWEqtHJzFYtnqfNTNAGo2eYr95ud0IyZdSiyxB7GwQPxQbArS5bweSRTD6NsrDo0snwdv0yJMchfoMHkPf1NtnqxQrC9Sj1OMqh0u4WGcBBzryqWPcDGbvtOdygWG5IQIcZaMCOWmGbFkf15y7WGo00hncgSf1Zwx36ZMTQFkf15uteQPWcaOjHojbDUMVXsQjc10t9udJuduyqX1ZMyqipHDawLh9gDPXnM84WmGbFkf15y7WGo00hncg0AQbIGgPOUoMm9KW8alYx36ZMTsneiqnTOE2A2SSSj37SiBq)ukQZPMiutHfaqZMLLn5ENfzdAwsuJnuteQXAQXzrqWEGAisnXrneiqnwtniz4(d5zRRlKxF26jPggPgOSIAIqniz4(d5zRfopONKAyKAGYkQXgQXgmO46ztmiWvEeBWcUXKhDmdyWNsrDo2omOdn9rJGbfxpqU)5RZdudJud)HbDUVfeS3bQHabQbjd3FipBTW5b9KudJut0TcdkUE2edcCLViiKa74gto0Jzad(ukQZX2HbDOPpAemiebnsrDDrj875s6oguC9SjgKFPT4dX(jHBm52cZaguC9SjgCQ1vj9SPxyrcg8PuuNJTd3yYTnmdyWNsrDo2omOdn9rJGbjJAGiOrkQRJjtpjmpWI81T(SzRuteQXAQrC9a5(NVopqnmsn8hg05(wqWEhOgceOgKmC)H8S1cNh0tsnmsnqzf1ydguC9SjgeMsgi33Vs6Hg3yYHUygWGpLI6CSDyqhA6Jgbd62KZoToCes6Z9WuYa56NsrDo1eHAC7Q4BSuF4VVCPQrVktgOgMtn2g1eHAiJAkSaa66BPUisw2We0SKOMiudzud)fwaa9JgsB4CFSLn5AwsyqX1ZMyW2cAJ5HPKbYXnMCMfMbm4tPOohBhg0HM(OrWGIRhi3)815bQHrQbkQjc1yn1qg1GKH7pKNTw48G(rZe6a1qGa1GKH7pKNTw48GMLe1yd1eHAiJAGiOrkQRJjtpjmpWI81T(SzRyqX1ZMyWd)9LlvCJjhAgZag8PuuNJTdd6qtF0iyqicAKI66Is43ZL0DmO46ztmyrj875s6oUXKdLvygWGpLI6CSDyqhA6JgbdcWIGxZpW4MMAyKi1a9wHbfxpBIbbUQOe(XnMCOGcZag8PuuNJTdd6qtF0iyqYOMwupBDrnj3dWIGx)ukQZPMiudzudebnsrDDmz6jH5bwK)HWt39f0L4PMiudsgU)qE2AHZd6jPggPgX1ZME3Uk(glXGIRNnXGh(7lxQ4gtouXHzad(ukQZX2HbDOPpAemO1utlQNTM)6M(Is4pOFkf15udbcudzudebnsrDDmz6jH5bwKVU1NnBLAiqGAayrWR5hyCttnmNAIUvudbcutHfaqxFl1frYYgMGg9QmzGAyo1ylQXgQjc1qg1arqJuuxtAx1KW8alYxuc)EUKUtnrOgYOgicAKI66yY0tcZdSi)dHNU7lOlXJbfxpBIbLmhlJs6ztCJjhQOJzad(ukQZX2HbDOPpAemO1utlQNTM)6M(Is4pOFkf15udbcudzudebnsrDDmz6jH5bwKVU1NnBLAiqGAayrWR5hyCttnmNAIUvuJnuteQHmQbIGgPOUM0UQjH5bwKV(wOMiudzudebnsrDnPDvtcZdSiFrj875s6o1eHAiJAGiOrkQRJjtpjmpWI8peE6UVGUepguC9Sjg0zr2Gp0Oj(JBm5qb9ygWGpLI6CSDyqhA6Jgbd2I6zRlQj5Eawe86NsrDo1eHAqYW9hYZwlCEqpj1Wi1iUE2072vX3yjguC9Sjg8WFF5sf3yYHYwygWGpLI6CSDyqX1ZMyq(RBg8LPpg0HM(OrWGi28alc21fwuojmFSLn56NsrDo1eHA4VWcaOlSOCsy(ylBY1OxLjdudZPgOhd6G3PUVfeS3bm5qHBm5qzBygWGIRNnXG8x3m4ltFm4tPOohBhUXKdf0fZag8PuuNJTdd6qtF0iyqYOMwupBDDRpB2Q(PuuNtnrOgKmC)H8S11fYRpB9KudJuJZIGG9a1Wmrnqzf1eHAAr9S18x30xuc)b9tPOohdkUE2edcCLhXgSGBm5qXSWmGbFkf15y7WGo00hncgSUqE9zR5tOL0DQHrQbkBrneiqnfwaa9Y2(fWJKe21SKWGIRNnXGaxvuc)4gtouqZygWGpLI6CSDyqhA6JgbdwxiV(S18j0s6o1Wi1aLTOgceOgRPMclaGEzB)c4rsc7AwsuteQHmQPf1Zwx36ZMTQFkf15uJnyqX1ZMyqGR8i2GfCJjpoRWmGbFkf15y7WGo00hncgSUqE9zR5tOL0DQHrQbkBHbfxpBIbH8e2byvE0B0Lg3yYJdkmdyWNsrDo2omOdn9rJGbBr9S18x30xuc)b9tPOohdkUE2ed2wqBmpmLmqoUXng8HWt3dygWKdfMbm4tPOohBhgCjHbdVXGIRNnXGqe0if1XGqef7XGUDv8nwQbUYxeesGDn6chEQjc1yn1yn1yn1qg10I6zR5VU540pLI6CQHabQPWcaORVL6IizzdtqZsIASHAIqnKrnqe0if11XKPNeMhyr(6wF2SvQjc1GKH7pKNTw48GEsQHrQj6wrn2qneiqnIRhi3)815bQHrQH)WGo33cc27a1ydg0HM(OrWGTOE2AGR8fbHeyx)ukQZXGqeKpL6XGax5lccjWUpaF6WnM84WmGbFkf15y7WGo00hncg0AQHmQHVT2TP7zJK(CpGsQ3xyrPUhx8tcJAIqnKrnIRNn1UnDpBK0N7bus96j9aQbMLMAiqGAayvkp6olcc299up1WCQbMJRRs0qn2GbfxpBIbDB6E2iPp3dOK6XnM8OJzad(ukQZX2HbDOPpAemO1udzutlQNTg4kFrqib21pLI6CQHabQXTRIVXsnWv(IGqcSRrVktgOggPgO3wuJnuteQHmQbIGgPOUoMm9KW8alYx36ZMTsnrOgRPgRPgYOMwupBn)1nhN(PuuNtneiqnfwaaD9TuxejlBycAwsuteQHmQXTRIVXsDrj875s6UgDHdp1yd1qGa1amWS0E0RYKbQH5ePgOSIASbdkUE2edwu7Y9lGVTC)ZxHh3yYHEmdyWNsrDo2omOdn9rJGbBr9S1ax5lccjWU(PuuNtnrOgicAKI6AGR8fbHey3hGpDyqX1ZMyWIAxUFb8TL7F(k84gtUTWmGbFkf15y7WGo00hncg0AQPWcaORVL6IizzdtqZsIAIqnUDv8nwQRVL6IizzdtqJUWHNASHAiqGAkSaa66BPUisw2We0OxLjdudJutC2IAiqGAagywAp6vzYa1WCIut0TcdkUE2edcJvq8rs)c4LO9OTTGBm52gMbm4tPOohBhg0HM(OrWGbsxP8TGG9oOlkHFpxs3HIAyKi1eh1qGa1GKH7pKNTw48GEsQHrQX2ScdkUE2edcSo2W5EjApA67lxQ4gto0fZag8PuuNJTdd6qtF0iyWaPRu(wqWEh0fLWVNlP7qrnmsKAIJAiqGAqYW9hYZwlCEqpj1Wi1yBwHbfxpBIbjXIga4NeMVOKqJBm5mlmdyWNsrDo2omOdn9rJGblSaaA0DXREi4bwK7AwsudbcutHfaqJUlE1dbpWIC37w2SpshAXfp1WCQbkRWGIRNnXGTL7zZYYMCpWICh3yYHMXmGbfxpBIbrdjsQ7N0hijUJbFkf15y7WnMCOScZag8PuuNJTdd6qtF0iyWclaGU(wQlIKLnmbnljQHabQbIGgPOUg4kFrqib29b4thguC9Sjgm2IuCiFsp6HnL0DCJjhkOWmGbFkf15y7WGo00hncgeGfbp1WCQb6TIAIqnfwaaD9TuxejlBycAwsyqX1ZMyW6RlcE)c4vSUH75Ol1aUXKdvCygWGpLI6CSDyqX1ZMyq0fstcZdOK6dyqhA6Jgbd2cc2BDp1771ZNtnmNAGsBlQHabQXAQXAQPfeS3AlxuTfnjxtnmsnmlROgceOMwqWERTCr1w0KCn1WCIutCwrn2qnrOgRPgX1dK7F(68a1qKAGIAiqGAAbb7TUN69965ZPggPM4GMPgBOgBOgceOgRPMwqWER7PEFVEsU2hNvudJut0TIAIqnwtnIRhi3)815bQHi1af1qGa10cc2BDp1771ZNtnmsnqp0tn2qn2GbDW7u33cc27aMCOWnUXG8diSQgZaMCOWmGbfxpBIb5taXsQXGpLI6CSD4gtECygWGIRNnXGUndS17RcSXHbFkf15y7WnM8OJzad(ukQZX2HbxsyWWBmO46ztmiebnsrDmierXEmylQNTgyqH2xu7Y1pLI6CQHabQjq6kLVfeS3bDrj875s6ouudJePgRPMOtnmJutlQNTUrYO8lGhXoP(PuuNtn2qneiqni28alc21olYg8TLVi41pLI6CQjc1uyba0olYg8TLVi418nwIbHiiFk1JblkHFpxs3XnMCOhZag8PuuNJTddUKWGH3yqX1ZMyqicAKI6yqiII9yqYOMwupBn)1nhN(PuuNtnrOg3Uk(gl113sDrKSSHjOrVktgOgMtn2g1eHAayrWR5hyCttnmsnr3kmieb5tPEmiPDvtcZdSiF9TGBm52cZag8PuuNJTddUKWGH3yqX1ZMyqicAKI6yqiII9yqicAKI66Is43ZL0DQjc1yn1aWIGNAyo1aDTf1WmsnTOE2AGbfAFrTlx)ukQZPgMjQjoROgBWGqeKpL6XGK2vnjmpWI8fLWVNlP74gtUTHzad(ukQZX2HbxsyWWBmO46ztmiebnsrDmierXEmylQNTM)6MJt)ukQZPMiudzutlQNTUOMK7byrWRFkf15uteQXTRIVXs9H)(YLQg9QmzGAyo1yn1aZX1vjAOgMjQjoQXgQjc1aWIGxZpW4MMAyKAIZkmieb5tPEmiPDvtcZdSi)H)(YLkUXKdDXmGbFkf15y7WGljmy4nguC9SjgeIGgPOogeIOypgSf1Zw)q4P7(c6s86NsrDo1eHAiJAGiOrkQRjTRAsyEGf5lkHFpxs3PMiudzudebnsrDnPDvtcZdSiF9TqnrOg3Uk(gl1peE6UVGUeVMLegeIG8PupgmMm9KW8alY)q4P7(c6s84gtoZcZag8PuuNJTddUKWGH3yqX1ZMyqicAKI6yqiII9yWwupBDDRpB2Q(PuuNtnrOgYOMclaGUU1NnBvZscdcrq(uQhdgtMEsyEGf5RB9zZwXnMCOzmdyWNsrDo2omOdn9rJGbH54A0RYKbQHi1yfguC9Sjg0jkLxC9SPxnHgdQMq7tPEmOBxfFJL4gtouwHzad(ukQZX2HbDOPpAemyHfaqdCLVS1IG41NTo0IlEQHi1ylQjc1yn1uyba0tTUkPNn9cls0SKOgceOgYOMclaGU(wQlIKLnmbnljQXgmO46ztmyBbTX8WuYa54gtouqHzad(ukQZX2HbDOPpAemylQNT(HWt39f0L41pLI6CQjc1yn1arqJuuxhtMEsyEGf5Fi80DFbDjEQHabQH)claG(HWt39f0L41SKOgBWGIRNnXGorP8IRNn9Qj0yq1eAFk1JbFi80DFbDjECJjhQ4WmGbFkf15y7WGo00hncgSf1ZwZFDZXPFkf15yqX1ZMyqeB6fxpB6vtOXGQj0(uQhdYFDZXHBm5qfDmdyWNsrDo2omO46ztmiIn9IRNn9Qj0yq1eAFk1JbZfvffUXngKe6UTwKgZaMCOWmGbFkf15y7WGPupguI2GfbjbpWMTFb8K2yhHbfxpBIbLOnyrqsWdSz7xapPn2r4g3yq3Uk(glXmGjhkmdyWNsrDo2omOdn9rJGbjJASMAAr9S18x3CC6NsrDo1qGa1arqJuuxtAx1KW8alYxFluJnuteQXAQHmQXTqEkzRH8STapIAiqGAiJA4BRdtcWQ8fKKCDpU4Neg1yd1qGa1amWS0E0RYKbQH5utC2cdkUE2edwFl1frYYgMaUXKhhMbm4tPOohBhg0HM(OrWGTOE2A(RBoo9tPOoNAIqnwtnUDv8nwQp83xUu1OxLjdudJutCwrnrOgRPgYOgicAKI66Is43ZL0DQHabQXTRIVXsDrj875s6Ug9QmzGAyKAG546QenuJnuJnuteQXAQHmQXTqEkzRH8STapIAiqGAiJA4BRdtcWQ8fKKCDpU4Neg1ydguC9SjgS(wQlIKLnmbCJjp6ygWGpLI6CSDyqhA6Jgbdsg1W3whMeGv5lij56ECXpjmmO46ztmyysawLVGKKJBm5qpMbm4tPOohBhg0HM(OrWGKrnTOE2A(RBoo9tPOoNAIqnKrnqe0if11XKPNeMhyr(6wF2SvQHabQPWcaObyrZYg8WKO9AwsyqX1ZMyW2Y9wyZg3yYTfMbmO46ztmiWY5h5713wUhqj1JbFkf15y7WnMCBdZaguC9Sjg8k4dJKE(DOFm4tPOohBhUXKdDXmGbFkf15y7WGo00hncgSWcaORVL6IizzdtqJEvMmqnmsnXzlQHabQbyGzP9OxLjdudZPgBZkmO46ztmiPTNnXnMCMfMbm4tPOohBhguC9SjgeMOUtuQJc(YUjg0HM(OrWGKrnTOE2AGR8fbHeyx)ukQZPgceOg3Uk(gl1ax5lccjWUgDHdpgmL6XGWe1DIsDuWx2nXnMCOzmdyWNsrDo2omO46ztmOdENAB0MJZxusOXGo00hncgSWcaORVL6IizzdtqZsIAIqnfwaaD91fbVFb8kw3W9C0LAqZ3yj1eHASMAiJAGiOrkQRlkHFpxs3PgceOgYOg3Uk(gl1fLWVNlP7A0fo8uJnyWdaCx7tPEmOdENAB0MJZxusOXnMCOScZag8PuuNJTddkUE2edkblqK8bpsI2f5DlsuyqhA6JgbdYFHfaqJKODrE3IeLN)claGMVXsQHabQXAQH)claG2TjN11dK7NmEp)fwaanljQHabQPWcaORVL6IizzdtqJEvMmqnmsnXzf1yd1eHAAbb7T2YfvBrtY1udZPMOdf1qGa1amWS0E0RYKbQH5utCwHbtPEmOeSarYh8ijAxK3TirHBm5qbfMbm4tPOohBhguC9SjguI2GfbjbpWMTFb8K2yhHbDOPpAemOBxfFJL66BPUisw2We0OxLjdudZPgOSIAiqGAC7Q4BSuxFl1frYYgMGg9QmzGAyKASnRWGPupguI2GfbjbpWMTFb8K2yhHBm5qfhMbm4tPOohBhg0HM(OrWGfwaaD9TuxejlBycAwsyqX1ZMyq2W9t)Aa3yYHk6ygWGpLI6CSDyqX1ZMyqNOuEX1ZME1eAmOAcTpL6XGpeE6Ea34gd(q4P7(c6s8ygWKdfMbm4tPOohBhg0HM(OrWGaSi4PggjsnmlROMiuJ1uJBxfFJL6Is43ZL0Dn6chEQHabQHmQbIGgPOUUOe(9CjDNASbdkUE2ed(q4P7(c6s84gtECygWGpLI6CSDyqhA6JgbdcrqJuuxxuc)EUKUtnrOg(lSaa6hcpD3xqxIxZscdkUE2edYV0w8Hy)KWnM8OJzad(ukQZX2HbDOPpAemiebnsrDDrj875s6o1eHA4VWcaOFi80DFbDjEnljmO46ztmyrj875s6oUXKd9ygWGpLI6CSDyqhA6JgbdYFHfaq)q4P7(c6s8AwsyqX1ZMyqjZXYOKE2e3yYTfMbm4tPOohBhg0HM(OrWG8xyba0peE6UVGUeVMLeguC9Sjg0zr2Gp0Oj(JBCJb5VU54WmGjhkmdyWNsrDo2omOdn9rJGbTMAAr9S1SzzztU3zr2G(PuuNtnrOMclaGMnllBY9olYg0SKOgBOMiuJ1uJZIGG9a1qKAIJAiqGASMAqYW9hYZwxxiV(S1tsnmsnqzf1eHAqYW9hYZwlCEqpj1Wi1aLvuJnuJnyqX1ZMyqGR8i2GfCJjpomdyWNsrDo2omOdn9rJGbHiOrkQRlkHFpxs3XGIRNnXG8lTfFi2pjCJjp6ygWGpLI6CSDyqhA6JgbdkUEGC)ZxNhOggPg(dd6CFliyVdudbcudsgU)qE2AHZd6jPggPgOScdkUE2edctjdK77xj9qJBm5qpMbm4tPOohBhg0HM(OrWGUn5StRdhHK(CpmLmqU(PuuNtnrOg3Uk(gl1h(7lxQA0RYKbQH5uJTrnrOgYOMclaGU(wQlIKLnmbnljQjc1qg1WFHfaq)OH0go3hBztUMLeguC9SjgSTG2yEykzGCCJj3wygWGpLI6CSDyqhA6JgbdIKH7pKNTw48GMLe1qGa1GKH7pKNTw48GEsQHrQjoBHbfxpBIbp83xUuXnMCBdZag8PuuNJTdd6qtF0iyqicAKI66Is43ZL0DQjc1qg142vX3yPU(wQlIKLnmbn6chEQjc1yn142vX3yP(WFF5svJEvMmqnmsn2IAiqGASMAqYW9hYZwlCEqpj1Wi1iUE2072vX3yj1eHAqYW9hYZwlCEqpj1WCQjoBrn2qn2GbfxpBIblkHFpxs3XnMCOlMbmO46ztm4uRRs6ztVWIem4tPOohBhUXKZSWmGbFkf15y7WGo00hncgKmQbIGgPOUM0UQjH5bwKVOe(9CjDhdkUE2edkzowgL0ZM4gto0mMbm4tPOohBhg0HM(OrWGaSi418dmUPPggjsnqVvyqX1ZMyqGRkkHFCJjhkRWmGbFkf15y7WGo00hncgKmQbIGgPOUM0UQjH5bwKVOe(9CjDNAIqnKrnqe0if11K2vnjmpWI8h(7lxQyqX1ZMyqNfzd(qJM4pUXKdfuygWGpLI6CSDyqhA6Jgbd2I6zR5VUPVOe(d6NsrDo1eHAiJAC7Q4BSuF4VVCPQrx4WtnrOgRPgNfbb7bQHi1eh1qGa1yn1GKH7pKNTUUqE9zRNKAyKAGYkQjc1GKH7pKNTw48GEsQHrQbkROgBOgBWGIRNnXGax5rSbl4gtouXHzad(ukQZX2HbfxpBIb5VUzWxM(yqhA6JgbdIyZdSiyxxyr5KW8Xw2KRFkf15uteQH)claGUWIYjH5JTSjxJEvMmqnmNAGEmOdEN6(wqWEhWKdfUXKdv0XmGbfxpBIb5VUzWxM(yWNsrDo2oCJjhkOhZag8PuuNJTdd6qtF0iyWclaGEzB)c4rsc7AwsyqX1ZMyW2cAJ5HPKbYXnMCOSfMbm4tPOohBhg0HM(OrWG1fYRpBnFcTKUtnmsnqzlQHabQPWcaOx22VaEKKWUMLeguC9Sjge4kpInyb3yYHY2WmGbFkf15y7WGo00hncgSUqE9zR5tOL0DQHrQbkBHbfxpBIbH8e2byvE0B0Lg3yYHc6Izad(ukQZX2HbDOPpAemylQNTM)6M(Is4pOFkf15yqX1ZMyW2cAJ5HPKbYXnUXnUXngd]] )
end
