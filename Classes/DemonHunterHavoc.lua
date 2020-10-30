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


    spec:RegisterPack( "Havoc", 20201024, [[dKebpbqieLhjHK2Ke8jkKYOOGoffyvisWROOAwKGBHir2fP(ffLHrICmqYYKq9mjQAAsu5Aui2gfs(gIKmokKQZjHOwhIeL5Hi19qO9HO6GiskwifQhkHenrejuxucj0grKuQpIiPKrIiP6KisuTsqQzkHeStsu)ucrQLkHiPNcyQKqFvcrIXIiHSxi)LkdMQomQfl0JP0KjCzvBgOpdkJMICAPETeLzt0TL0Uf9BLgocoUeIy5q9CbtxX1jPTdIVlrgVesDEeX6Lqy(GQ9J0iOqkIae8CKYfRuXkbLsfxonufBeOGQiJagsiCeab2wgd7iGKRhbqQZqwlcGatICzbsreqyvX2Jaa6QQKNEZIsmdoiGOAlhs5jkIae8CKYfRuXkbLsfxonufBeOGQCiGaHBrkBesfPcbyQfINOicq8GfbuuPEsXVUj1tQRMZXupPodzTuOlQuFrA7SXJP(IlNcuFXkvSsiac4fSLhbuuPEsXVUj1tQRMZXupPodzTuOlQuFrA7SXJP(IlNcuFXkvSsuOPqxuPEGKjemTd1J5wq9rvqWlO(WWtG6JhCXN6TBnYd1hpSodupNcQNa(Kse2z6eg13bQxS51uOz70Bg0eW3U1ipMt0m1WD98QcjxprUicMymhCGBoUf0rylDmfAk0fvQVOyrFR6Cb1Fihtc1pD9u)y6upBNft9DG6ziCl5O8Ak0SD6ndefDaRsyOqZ2P3myorZSBguR3vzyTLcnBNEZG5endcJBokVcjxpXOKf3j40EfGWs1tCy5Zrd24W4IYDf6NCuEbC4bcxkDdJH9jOJswCNGt7HICIgwEsPHLph9G5w6wqhwTt9tokVWak0SD6ndMt0mimU5O8kKC9ejSRStyoWf7QFyfGWs1tKSHLphT41nBR(jhLxuWURuSLsD9dxxmbtBOdA8RCNbsBufavXKOfhST9qE5vIcnBNEZG5endcJBokVcjxprc7k7eMdCXUOKf3j40EfGWs1tecJBokVokzXDcoTVGHGQysinPYiKsdlFoAWghgxuURq)KJYlifkwjdOqZ2P3myorZGW4MJYRqY1tKWUYoH5axS7KCx8CvbiSu9ehw(C0Ix3ST6NCuErbYgw(C0rzNchOkMe9tokVOGDxPylL6tYDXZvn(vUZaPneMvORCrtkuSbfavXKOfhST9qEXkrHMTtVzWCIMbHXnhLxHKRNyjUNoH5axS7HWt7Dr85YuaclvpXHLph9dHN27I4ZLPFYr5ffidcJBokVMWUYoH5axSlkzXDcoTVazqyCZr51e2v2jmh4ID1pCb7UsXwk1peEAVlIpxMwLafA2o9MbZjAgeg3CuEfsUEIL4E6eMdCXU6wFoQvfGWs1tCy5Zrx36ZrTQFYr5ffilQccQRB95Ow1QeOqZ2P3myorZSSu6y70B6KDyui56jA3vk2sPcnirywHg)k3zGOsuOz70BgmNOzJj8wYbtYnKRqdsmQccQbV0f3AKXI6Zrhg2wgrJuWWOkiOUR1vYtVPJvXSwLaC4Kfvbb11pCDXemTHoOvjyafA2o9MbZjAMLLshBNEtNSdJcjxpXhcpT3fXNltHgK4WYNJ(HWt7Dr85Y0p5O8IcgcHXnhLxxI7PtyoWf7Ei80ExeFUm4WfpQccQFi80ExeFUmTkbdOqZ2P3myorZWQPJTtVPt2HrHKRNO41nBRcniXHLphT41nBR(jhLxqHMTtVzWCIMHvthBNEtNSdJcjxpXCXvwsHMcnBNEZG2URuSLsI1pCDXemTHoOqdsKmdhw(C0Ix3ST6NCuEbC4qyCZr51e2v2jmh4ID1pSbfmKm7c5jNJgYZXejy9tokVaoCYe7OdDcQkDrmNc902Y6eMbWHd2Wmno8RCNbsxSrOqZ2P3mOT7kfBP0CIMv)W1ftW0g6GcniXHLphT41nBR(jhLxuWqY4I44EU2AI3PTUbZzaCXvE6n1p5O8IcYd5ssBKYbhUH2DLITuQpj3fpx14x5odKxSsfmKmimU5O86OKf3j40E4WT7kfBPuhLS4obN2RXVYDgihMvORCrBGbguWqYSlKNCoAiphtKG1p5O8c4WjtSJo0jOQ0fXCk0tBlRtygqHMTtVzqB3vk2sP5enl0jOQ0fXCkuObjsMyhDOtqvPlI5uON2wwNWOqZ2P3mOT7kfBP0CIMnMUZKAouOz70Bg02DLITuAorZaxH4y3SUX0DGsUEk0SD6ndA7UsXwknNOzxssO50jUf)tHMTtVzqB3vk2sP5enJWo9Mk0GeJQGG66hUUycM2qh04x5odKxSrGdhSHzAC4x5odK2OuIcnBNEZG2URuSLsZjAMA4UEEvHKRNimwEllLhhCXDtfAqIKnS85ObV0fzmMHD9tokVaoC7UsXwk1Gx6ImgZWUgFwqcfA2o9MbTDxPylLMt0m1WD98Qche82XLC9eTKyL7G3STUOKdJcniXOkiOU(HRlMGPn0bTkHcrvqqD91ftIBbDsvBlCc85Aql2szbdjdcJBokVokzXDcoThoCYS7kfBPuhLS4obN2RXNfKyafA2o9MbTDxPylLMt0m1WD98QcjxproyccNp4WCrSyNDXSuHgKO4rvqqnMlIf7SlMLoXJQGGAXwkHd3qXJQGGA7Mcv70qURZYCIhvbb1QeGdpQccQRF46IjyAdDqJFL7mqEXkzqHHXW(OnDwoM0eSdPlpuWHd2Wmno8RCNbsxSsuOz70Bg02DLITuAorZud31ZRkKC9e5IiyIXCWbU54wqhHT0Xk0GeT7kfBPux)W1ftW0g6Gg)k3zG0qPeC42DLITuQRF46IjyAdDqJFL7mqUrPef6Ik1tk(GSQCOEqwkJSTmQhCXuVAGJYt998AqtHMTtVzqB3vk2sP5entnCxpVguObjgvbb11pCDXemTHoOvjqHMTtVzqB3vk2sP5enZYsPJTtVPt2HrHKRN4dHN2hOqtHMTtVzqlEDZ2se8shwnysHgKOHdlFoA1mUQPWznXBq)KJYlkevbb1QzCvtHZAI3GwLGbfm0AIXWEGyXWHBiMBH7qEo66c51NJUtYHsPcyUfUd55OzHiO7KCOuYadOqZ2P3mOfVUzBnNOzIZJjxO0pbfAqIqyCZr51rjlUtWP9uOz70Bg0Ix3STMt0mysUHC38kHhgfAqISDAi3981(bYfp04lCdJH9jahoMBH7qEoAwic6ojhkLOqZ2P3mOfVUzBnNOzJj8wYbtYnKRqds0UPqThD4ympx4Gj5gY1p5O8Ic2DLITuQpj3fpx14x5odK2Okqwufeux)W1ftW0g6GwLqbYepQccQFrtydx4kTQPqRsGcnBNEZGw86MT1CIMDsUlEUQqdseZTWDiphnlebTkb4WXClChYZrZcrq3j5fBek0SD6ndAXRB2wZjAwuYI7eCAVcnirimU5O86OKf3j40(cKz3vk2sPU(HRlMGPn0bn(SGKcgA3vk2sP(KCx8CvJFL7mqUHgHuIlIJ75A8HSsiDcZfLS4bnMZYifkVbWHBiMBH7qEoAwic6oj3URuSLYcyUfUd55OzHiO7K0fBedmGcnBNEZGw86MT1CIM116k5P30XQyMcnBNEZGw86MT1CIMXz2MAjp9Mk0GejdcJBokVMWUYoH5axSlkzXDcoTNcnBNEZGw86MT1CIMbEzuYIRqdseuftIwCW22d5elNsuOz70Bg0Ix3STMt0mRjEdUWG7YUcnirYGW4MJYRjSRStyoWf7IswCNGt7lqgeg3CuEnHDLDcZbUy3j5U45kfA2o9MbT41nBR5end8shwnysHgK4WYNJw86MUOKfpOFYr5ffiZURuSLs9j5U45QgFwqsbdTMymShiwmC4gI5w4oKNJUUqE95O7KCOuQaMBH7qEoAwic6ojhkLmWak0SD6ndAXRB2wZjAM41ndUypxbljw5DdJH9jqekfAqIy18Glg21rvC2jmxPvnf6xKO2eiCrbXJQGG6Oko7eMR0QMcn(vUZaPlhfA2o9MbT41nBR5ent86MbxSNtHMTtVzqlEDZ2AorZgt4TKdMKBixHgKyufeuVQJBbDyoHDTkbk0SD6ndAXRB2wZjAg4LoSAWKcniX6c51NJw0HHt7jhkJahEufeuVQJBbDyoHDTkbk0SD6ndAXRB2wZjAgKNWoOQ0H)Gppk0GeRlKxFoArhgoTNCOmcfA2o9MbT41nBR5enBmH3soysUHCfAqIdlFoAXRB6Isw8G(jhLxqHMcnBNEZG(HWt7Dr85Yi(q4P9Ui(Czk0GebvXKqorJUsfm0URuSLsDuYI7eCAVgFwqcC4KbHXnhLxhLS4obN2BafA2o9Mb9dHN27I4ZLzorZeNhtUqPFck0GeHW4MJYRJswCNGt7liEufeu)q4P9Ui(CzAvcuOz70Bg0peEAVlIpxM5enlkzXDcoTxHgKieg3CuEDuYI7eCAFbXJQGG6hcpT3fXNltRsGcnBNEZG(HWt7Dr85YmNOzCMTPwYtVPcnirXJQGG6hcpT3fXNltRsGcnBNEZG(HWt7Dr85YmNOzwt8gCHb3LDfAqIIhvbb1peEAVlIpxMwLafAk0SD6nd6hcpTpqecJBokVcjxprWlDrgJzy3fijTk0Gehw(C0Gx6ImgZWU(jhLxOaewQEI2DLITuQbV0fzmMHDn(SGKcgAOHKnS85OfVUzB1p5O8c4WJQGG66hUUycM2qh0QemOazqyCZr51L4E6eMdCXU6wFoQ1cyUfUd55OzHiO7K8YRKbWHZ2PHC3Zx7hix8qJVWnmg2NGbuOz70Bg0peEAFWCIMz30(CW8CHduY1Rqds0qYe7OTBAFoyEUWbk56DrvCQN2wwNWkqgBNEtTDt7ZbZZfoqjxVUthOSHzAGdhuvkD4BnXyy3nD9KgMvORCrBaf6Ik1tQzMxjmu)SuFGK0s9L6Xe1tQ9LuVXmgZWo1VyQNuZwuK6BqQVhQVulLuF8uVA4cQVupM6K6htN6Zx0d1xoJq9HB3ueuG63X0XL6WPE1WPEHkUtyuFU4klP(OkomuVGRmSRPqZ2P3mOFi80(G5enlk3v4wq3y6UNVsIcnirdjBy5ZrdEPlYymd76NCuEbC42DLITuQbV0fzmMHDn(vUZa5LZiguGmimU5O86sCpDcZbUyxDRph1AbdnKSHLphT41nBR(jhLxahEufeux)W1ftW0g6GwLqbYS7kfBPuhLS4obN2RXNfKyaC4GnmtJd)k3zG0eHsjdOqZ2P3mOFi80(G5enlk3v4wq3y6UNVsIcniXHLphn4LUiJXmSRFYr5ffGW4MJYRbV0fzmMHDxGK0sHMTtVzq)q4P9bZjAgmvglAoDlOJlIJ3XKcnirdJQGG66hUUycM2qh0Qeky3vk2sPU(HRlMGPn0bn(SGedGdpQccQRF46IjyAdDqJFL7mqEXgboCWgMPXHFL7mqAILxjk0SD6nd6hcpTpyorZaxRA4chxeh3ZDXZvfAqIbcxkDdJH9jOJswCNGt7HICIfdhoMBH7qEoAwic6oj3OuIcnBNEZG(HWt7dMt0mcQ4gKKoH5Isomk0GedeUu6ggd7tqhLS4obN2df5elgoCm3c3H8C0Sqe0DsUrPefA2o9Mb9dHN2hmNOzJP7uZ4QMch4ITxHgKyufeuJVTm5dbh4ITxRsao8OkiOgFBzYhcoWfBVZUQ5CSomSTmsdLsuOz70Bg0peEAFWCIMHBceK31PlqGTNcnBNEZG(HWt7dMt0SslwkG8oD4h2Kt7vObjgvbb11pCDXemTHoOvjahoeg3CuEn4LUiJXmS7cKKwk0SD6nd6hcpTpyorZQVUysClOtQABHtGpxdk0GebvXKq6YPuHOkiOU(HRlMGPn0bTkbk0SD6nd6hcpTpyorZWNj0jmhOKRpOGLeR8UHXW(eicLcniXHXW(ONUE3SorFsdL2iWHBOHdJH9rB6SCmPjyhYn6kbh(WyyF0MolhtAc2H0elwjdkyiBNgYDpFTFGiuWHpmg2h9017M1j6tEXfzdmaoCdhgd7JE66DZ6iyhxXkrE5vQGHSDAi3981(bIqbh(WyyF0txVBwNOp5LRCgyafAk0SD6nd6CXvwseYtyhuv6WFWNhfAqIdlFo66wFoQv9tokVOqufeutaFcm(cTylLfMUEYHIcnBNEZGoxCLLMt0mWlDy1GjfAqIgcHXnhLxxI7PtyoWf7QB95OwHdFy5ZrRMXvnfoRjEd6NCuErHOkiOwnJRAkCwt8g0QemOGHwtmg2delgoCdXClChYZrxxiV(C0DsoukvaZTWDiphnlebDNKdLsgyafA2o9MbDU4klnNOzGx6ImgZWUcnir2onK7E(A)a5IhA8fUHXW(eGdhZTWDiphnlebDNKxELOqZ2P3mOZfxzP5entCEm5cL(jOqdsecJBokVokzXDcoTNcnBNEZGoxCLLMt0SUwxjp9MowfZuOz70Bg05IRS0CIMbtYnK7Mxj8WOqdsKmimU5O86sCpDcZbUyxDRph1Abdz70qU75R9dKlEOXx4ggd7taoCm3c3H8C0Sqe0DsoukzafA2o9MbDU4klnNOzJj8wYbtYnKRqds0UPqThD4ympx4Gj5gY1p5O8Ic2DLITuQpj3fpx14x5odK2Okqwufeux)W1ftW0g6GwLqbYepQccQFrtydx4kTQPqRsGcnBNEZGoxCLLMt0StYDXZvfAqISDAi3981(bYHQGHKH5w4oKNJMfIG(fDhMaC4yUfUd55OzHiOvjyqbYGW4MJYRlX90jmh4ID1T(CuRuOz70Bg05IRS0CIMfLS4obN2RqdsecJBokVokzXDcoTNcnBNEZGoxCLLMt0mWlJswCfAqIGQys0Id22EiNy5uIcnBNEZGoxCLLMt0StYDXZvfAqIKnS85OJYofoqvmj6NCuErbYGW4MJYRlX90jmh4IDpeEAVlIpxwbm3c3H8C0Sqe0DsUDxPylLuOz70Bg05IRS0CIMXz2MAjp9Mk0GenCy5ZrlEDtxuYIh0p5O8c4WjdcJBokVUe3tNWCGl2v36ZrTchoOkMeT4GTThsxELGdpQccQRF46IjyAdDqJFL7mqAJyqbYGW4MJYRjSRStyoWf7IswCNGt7lqgeg3CuEDjUNoH5axS7HWt7Dr85YOqZ2P3mOZfxzP5enZAI3Glm4USRqds0WHLphT41nDrjlEq)KJYlGdNmimU5O86sCpDcZbUyxDRph1kC4GQys0Id22EiD5vYGcKbHXnhLxtyxzNWCGl2v)WfidcJBokVMWUYoH5axSlkzXDcoTVazqyCZr51L4E6eMdCXUhcpT3fXNlJcnBNEZGoxCLLMt0StYDXZvfAqIdlFo6OStHduftI(jhLxuaZTWDiphnlebDNKB3vk2sjfA2o9MbDU4klnNOzIx3m4I9CfSKyL3nmg2NarOuObjIvZdUyyxhvXzNWCLw1uOFrIAtGWffepQccQJQ4StyUsRAk04x5odKUCuOz70Bg05IRS0CIMjEDZGl2ZPqZ2P3mOZfxzP5end8shwnysHgKizdlFo66wFoQv9tokVOaMBH7qEo66c51NJUtYTMymShifGsPcdlFoAXRB6Isw8G(jhLxqHMTtVzqNlUYsZjAg4LrjlUcniX6c51NJw0HHt7jhkJahEufeuVQJBbDyoHDTkbk0SD6nd6CXvwAorZaV0HvdMuObjwxiV(C0IomCAp5qze4WnmQccQx1XTGomNWUwLqbYgw(C01T(CuR6NCuEHbuOz70Bg05IRS0CIMb5jSdQkD4p4ZJcniX6c51NJw0HHt7jhkJqHMTtVzqNlUYsZjA2ycVLCWKCd5k0Gehw(C0Ix30fLS4b9tokVaba54qVjs5IvQyLGsPIvcbuIXzNWciGIui1uKQYKYvMulszup1ROPt9DLWIhQhCXuVrZURuSLsJg1JFrIAJVG6dB9upRoBLNlOERjoH9GMcDrHop1dfPmQVOCtihpxq9gn7c5jNJMuK(jhLxy0O(zPEJMDH8KZrtkYOr9gcvrBGMcDrHop1xmPmQVOCtihpxq9gn7c5jNJMuK(jhLxy0O(zPEJMDH8KZrtkYOr9gcvrBGMcnfAs5vclEUG6jvupBNEtQx2HjOPqJay1X0IraaDTOebi7WeqkIaYfxzjsrKYqHueb8KJYlqgJaS4EoUzeWWYNJUU1NJAv)KJYlO(cuFufeutaFcm(cTylLuFbQF66PEYPEOqaSD6nraqEc7GQsh(d(8GgKYfJueb8KJYlqgJaS4EoUzeGHupeg3CuEDjUNoH5axSRU1NJAL6HdN6hw(C0QzCvtHZAI3G(jhLxq9fO(OkiOwnJRAkCwt8g0QeOEdO(cuVHuV1eJH9a1tK6lM6HdN6nK6XClChYZrxxiV(C0Ds9Kt9qPe1xG6XClChYZrZcrq3j1to1dLsuVbuVbia2o9MiaWlDy1Gj0GuU8ifrap5O8cKXialUNJBgbW2PHC3Zx7hOEYPEXdn(c3WyyFcupC4upMBH7qEoAwic6oPEYP(YRecGTtVjca8sxKXyg2rds5YHueb8KJYlqgJaS4EoUzeaeg3CuEDuYI7eCApcGTtVjcqCEm5cL(jGgKYgbPicGTtVjcOR1vYtVPJvXmc4jhLxGmgniLnkKIiGNCuEbYyeGf3ZXnJaiJ6HW4MJYRlX90jmh4ID1T(CuRuFbQ3qQNTtd5UNV2pq9Kt9IhA8fUHXW(eOE4WPEm3c3H8C0Sqe0Ds9Kt9qPe1BacGTtVjcaMKBi3nVs4HbniLjvifrap5O8cKXialUNJBgby3uO2JoCmMNlCWKCd56NCuEb1xG6T7kfBPuFsUlEUQXVYDgOEst9gf1xG6jJ6JQGG66hUUycM2qh0QeO(cupzuV4rvqq9lAcB4cxPvnfAvcia2o9MiGXeEl5Gj5gYrdszJosreWtokVazmcWI754MraSDAi3981(bQNCQhkQVa1Bi1tg1J5w4oKNJMfIG(fDhMa1dho1J5w4oKNJMfIGwLa1Ba1xG6jJ6HW4MJYRlX90jmh4ID1T(CuRia2o9MiGtYDXZv0GuUiJueb8KJYlqgJaS4EoUzeaeg3CuEDuYI7eCApcGTtVjcikzXDcoThniLHsjKIiGNCuEbYyeGf3ZXnJaavXKOfhST9q9KtK6lNsia2o9MiaWlJswC0GugkOqkIaEYr5fiJrawCph3mcGmQFy5ZrhLDkCGQys0p5O8cQVa1tg1dHXnhLxxI7PtyoWf7Ei80ExeFUmQVa1J5w4oKNJMfIGUtQNCQNTtVPZURuSLseaBNEteWj5U45kAqkdvXifrap5O8cKXialUNJBgbyi1pS85OfVUPlkzXd6NCuEb1dho1tg1dHXnhLxxI7PtyoWf7QB95OwPE4WPEqvmjAXbBBpupPP(YRe1dho1hvbb11pCDXemTHoOXVYDgOEst9gH6nG6lq9Kr9qyCZr51e2v2jmh4IDrjlUtWP9uFbQNmQhcJBokVUe3tNWCGl29q4P9Ui(Czia2o9MiaoZ2ul5P3eniLHQ8ifrap5O8cKXialUNJBgbyi1pS85OfVUPlkzXd6NCuEb1dho1tg1dHXnhLxxI7PtyoWf7QB95OwPE4WPEqvmjAXbBBpupPP(YRe1Ba1xG6jJ6HW4MJYRjSRStyoWf7QFyQVa1tg1dHXnhLxtyxzNWCGl2fLS4obN2t9fOEYOEimU5O86sCpDcZbUy3dHN27I4ZLHay70BIaSM4n4cdUl7ObPmuLdPic4jhLxGmgbyX9CCZiGHLphDu2PWbQIjr)KJYlO(cupMBH7qEoAwic6oPEYPE2o9Mo7UsXwkraSD6nraNK7INRObPmugbPic4jhLxGmgbW2P3ebiEDZGl2ZrawCph3mcaRMhCXWUoQIZoH5kTQPq)Ie1MaHlO(cuV4rvqqDufNDcZvAvtHg)k3zG6jn1xoeGLeR8UHXW(eqkdfAqkdLrHuebW2P3ebiEDZGl2Zrap5O8cKXObPmuKkKIiGNCuEbYyeGf3ZXnJaiJ6hw(C01T(CuR6NCuEb1xG6XClChYZrxxiV(C0Ds9Kt9wtmg2dupPa1dLsuFbQFy5ZrlEDtxuYIh0p5O8ceaBNEtea4LoSAWeAqkdLrhPic4jhLxGmgbyX9CCZiG6c51NJw0HHt7PEYPEOmc1dho1hvbb1R64wqhMtyxRsabW2P3ebaEzuYIJgKYqvKrkIaEYr5fiJrawCph3mcOUqE95OfDy40EQNCQhkJq9WHt9gs9rvqq9QoUf0H5e21QeO(cupzu)WYNJUU1NJAv)KJYlOEdqaSD6nraGx6WQbtObPCXkHueb8KJYlqgJaS4EoUzeqDH86Zrl6WWP9up5upugbbW2P3eba5jSdQkD4p4ZdAqkxmuifrap5O8cKXialUNJBgbmS85OfVUPlkzXd6NCuEbcGTtVjcymH3soysUHC0GgeWdHN2hqkIugkKIiGNCuEbYyeWsabe(Gay70BIaGW4MJYJaGWs1JaS7kfBPudEPlYymd7A8zbjuFbQ3qQ3qQ3qQNmQFy5ZrlEDZ2QFYr5fupC4uFufeux)W1ftW0g6GwLa1Ba1xG6jJ6HW4MJYRlX90jmh4ID1T(CuRuFbQhZTWDiphnlebDNup5uF5vI6nG6HdN6z70qU75R9dup5uV4HgFHBymSpbQ3aeGf3ZXnJagw(C0Gx6ImgZWU(jhLxGaGWyxY1JaaV0fzmMHDxGK0IgKYfJueb8KJYlqgJaS4EoUzeGHupzuVyhTDt7ZbZZfoqjxVlQIt902Y6eg1xG6jJ6z70BQTBAFoyEUWbk561D6aLnmtd1dho1dQkLo8TMymS7MUEQN0upmRqx5IM6nabW2P3eby30(CW8CHduY1JgKYLhPic4jhLxGmgbyX9CCZiadPEYO(HLphn4LUiJXmSRFYr5fupC4uVDxPylLAWlDrgJzyxJFL7mq9Kt9LZiuVbuFbQNmQhcJBokVUe3tNWCGl2v36ZrTs9fOEdPEdPEYO(HLphT41nBR(jhLxq9WHt9rvqqD9dxxmbtBOdAvcuFbQNmQ3URuSLsDuYI7eCAVgFwqc1Ba1dho1d2Wmno8RCNbQN0ePEOuI6nabW2P3ebeL7kClOBmD3ZxjbniLlhsreWtokVazmcWI754MradlFoAWlDrgJzyx)KJYlO(cupeg3CuEn4LUiJXmS7cKKweaBNEtequURWTGUX0DpFLe0Gu2iifrap5O8cKXialUNJBgbyi1hvbb11pCDXemTHoOvjq9fOE7UsXwk11pCDXemTHoOXNfKq9gq9WHt9rvqqD9dxxmbtBOdA8RCNbQNCQVyJq9WHt9GnmtJd)k3zG6jnrQV8kHay70BIaGPYyrZPBbDCrC8oMqdszJcPic4jhLxGmgbyX9CCZiGaHlLUHXW(e0rjlUtWP9qr9KtK6lM6HdN6XClChYZrZcrq3j1to1BukHay70BIaaxRA4chxeh3ZDXZv0GuMuHueb8KJYlqgJaS4EoUzeqGWLs3WyyFc6OKf3j40EOOEYjs9ft9WHt9yUfUd55OzHiO7K6jN6nkLqaSD6nraeuXnijDcZfLCyqdszJosreWtokVazmcWI754Mrarvqqn(2YKpeCGl2ETkbQhoCQpQccQX3wM8HGdCX27SRAohRddBlJ6jn1dLsia2o9MiGX0DQzCvtHdCX2JgKYfzKIia2o9MiaCtGG8UoDbcS9iGNCuEbYy0GugkLqkIaEYr5fiJrawCph3mciQccQRF46IjyAdDqRsG6HdN6HW4MJYRbV0fzmMHDxGK0Iay70BIakTyPaY70HFytoThniLHckKIiGNCuEbYyeGf3ZXnJaavXKq9KM6lNsuFbQpQccQRF46IjyAdDqRsabW2P3ebuFDXK4wqNu12cNaFUgqdszOkgPic4jhLxGmgbW2P3ebGptOtyoqjxFabyX9CCZiGHXW(ONUE3SorFQN0upuAJq9WHt9gs9gs9dJH9rB6SCmPjyhQNCQ3ORe1dho1pmg2hTPZYXKMGDOEstK6lwjQ3aQVa1Bi1Z2PHC3Zx7hOEIupuupC4u)WyyF0txVBwNOp1to1xCrM6nG6nG6HdN6nK6hgd7JE66DZ6iyhxXkr9Kt9LxjQVa1Bi1Z2PHC3Zx7hOEIupuupC4u)WyyF0txVBwNOp1to1xUYr9gq9gGaSKyL3nmg2NaszOqdAqaIdYQYbPiszOqkIay70BIaeDaRsyqap5O8cKXObPCXifraSD6nra2ndQ17QmS2IaEYr5fiJrds5YJueb8KJYlqgJawciGWheaBNEteaeg3CuEeaewQEeWWYNJgSXHXfL7k0p5O8cQhoCQpq4sPBymSpbDuYI7eCApuup5ePEdP(Yt9Ksu)WYNJEWClDlOdR2P(jhLxq9gGaGWyxY1JaIswCNGt7rds5YHueb8KJYlqgJawciGWheaBNEteaeg3CuEeaewQEeazu)WYNJw86MTv)KJYlO(cuVDxPylL66hUUycM2qh04x5odupPPEJI6lq9GQys0Id22EOEYP(YRecacJDjxpcGWUYoH5axSR(HrdszJGueb8KJYlqgJawciGWheaBNEteaeg3CuEeaewQEeaeg3CuEDuYI7eCAp1xG6nK6bvXKq9KM6jvgH6jLO(HLphnyJdJlk3vOFYr5fupPa1xSsuVbiaim2LC9iac7k7eMdCXUOKf3j40E0Gu2OqkIaEYr5fiJralbeq4dcGTtVjcacJBokpcaclvpcyy5ZrlEDZ2QFYr5fuFbQNmQFy5ZrhLDkCGQys0p5O8cQVa1B3vk2sP(KCx8CvJFL7mq9KM6nK6Hzf6kx0upPa1xm1Ba1xG6bvXKOfhST9q9Kt9fRecacJDjxpcGWUYoH5axS7KCx8CfniLjvifrap5O8cKXiGLaci8bbW2P3ebaHXnhLhbaHLQhbmS85OFi80ExeFUm9tokVG6lq9Kr9qyCZr51e2v2jmh4IDrjlUtWP9uFbQNmQhcJBokVMWUYoH5axSR(HP(cuVDxPylL6hcpT3fXNltRsabaHXUKRhbuI7PtyoWf7Ei80ExeFUm0Gu2OJueb8KJYlqgJawciGWheaBNEteaeg3CuEeaewQEeWWYNJUU1NJAv)KJYlO(cupzuFufeux36ZrTQvjGaGWyxY1JakX90jmh4ID1T(CuRObPCrgPic4jhLxGmgbyX9CCZiaywHg)k3zG6js9kHay70BIaSSu6y70B6KDyqaYomUKRhby3vk2sjAqkdLsifrap5O8cKXialUNJBgbevbb1Gx6IBnYyr95OddBlJ6js9gH6lq9gs9rvqqDxRRKNEthRIzTkbQhoCQNmQpQccQRF46IjyAdDqRsG6nabW2P3ebmMWBjhmj3qoAqkdfuifrap5O8cKXialUNJBgbmS85OFi80ExeFUm9tokVG6lq9gs9qyCZr51L4E6eMdCXUhcpT3fXNlJ6HdN6fpQccQFi80ExeFUmTkbQ3aeaBNEteGLLshBNEtNSddcq2HXLC9iGhcpT3fXNldniLHQyKIiGNCuEbYyeGf3ZXnJagw(C0Ix3ST6NCuEbcGTtVjcaRMo2o9MozhgeGSdJl56raIx3STObPmuLhPic4jhLxGmgbW2P3ebGvthBNEtNSddcq2HXLC9iGCXvwIg0GaiGVDRrEqkIugkKIiGNCuEbYyeqY1Ja4IiyIXCWbU54wqhHT0Xia2o9MiaUicMymhCGBoUf0rylDmAqdcWURuSLsKIiLHcPic4jhLxGmgbyX9CCZiaYOEdP(HLphT41nBR(jhLxq9WHt9qyCZr51e2v2jmh4ID1pm1Ba1xG6nK6jJ6TlKNCoAiphtKGPE4WPEYOEXo6qNGQsxeZPqpTTSoHr9gq9WHt9GnmtJd)k3zG6jn1xSrqaSD6nra1pCDXemTHoGgKYfJueb8KJYlqgJaS4EoUzeWWYNJw86MTv)KJYlO(cuVHupzupxeh3Z1wt8oT1nyodGlUYtVP(jhLxq9fOE5HCj1tAQ3iLJ6HdN6nK6T7kfBPuFsUlEUQXVYDgOEYP(IvI6lq9gs9Kr9qyCZr51rjlUtWP9upC4uVDxPylL6OKf3j40En(vUZa1to1dZk0vUOPEdOEdOEdO(cuVHupzuVDH8KZrd55yIem1dho1tg1l2rh6euv6Iyof6PTL1jmQ3aeaBNEteq9dxxmbtBOdObPC5rkIaEYr5fiJrawCph3mcGmQxSJo0jOQ0fXCk0tBlRtyia2o9MiGqNGQsxeZPaniLlhsreaBNEteWy6otQ5GaEYr5fiJrdszJGuebW2P3ebaUcXXUzDJP7aLC9iGNCuEbYy0Gu2OqkIay70BIaUKKqZPtCl(hb8KJYlqgJgKYKkKIiGNCuEbYyeGf3ZXnJaIQGG66hUUycM2qh04x5odup5uFXgH6HdN6bByMgh(vUZa1tAQ3OucbW2P3ebqyNEt0Gu2OJueb8KJYlqgJay70BIaGXYBzP84GlUBIaS4EoUzeazu)WYNJg8sxKXyg21p5O8cQhoCQ3URuSLsn4LUiJXmSRXNfKGasUEeamwEllLhhCXDt0GuUiJueb8KJYlqgJay70BIaSKyL7G3STUOKddcWI754MrarvqqD9dxxmbtBOdAvcuFbQpQccQRVUysClOtQABHtGpxdAXwkP(cuVHupzupeg3CuEDuYI7eCAp1dho1tg1B3vk2sPokzXDcoTxJpliH6nabCqWBhxY1JaSKyL7G3STUOKddAqkdLsifrap5O8cKXia2o9MiaoyccNp4WCrSyNDXSebyX9CCZiaXJQGGAmxel2zxmlDIhvbb1ITus9WHt9gs9Ihvbb12nfQ2PHCxNL5epQccQvjq9WHt9rvqqD9dxxmbtBOdA8RCNbQNCQVyLOEdO(cu)WyyF0MolhtAc2H6jn1xEOOE4WPEWgMPXHFL7mq9KM6lwjeqY1Ja4GjiC(GdZfXID2fZs0GugkOqkIaEYr5fiJraSD6nraCremXyo4a3CClOJWw6yeGf3ZXnJaS7kfBPux)W1ftW0g6Gg)k3zG6jn1dLsupC4uVDxPylL66hUUycM2qh04x5odup5uVrPeci56raCremXyo4a3CClOJWw6y0GugQIrkIaEYr5fiJrawCph3mciQccQRF46IjyAdDqRsabW2P3ebOgURNxdObPmuLhPic4jhLxGmgbW2P3ebyzP0X2P30j7WGaKDyCjxpc4HWt7dObniGhcpT3fXNldPiszOqkIaEYr5fiJrawCph3mcauftc1torQ3ORe1xG6nK6T7kfBPuhLS4obN2RXNfKq9WHt9Kr9qyCZr51rjlUtWP9uVbia2o9MiGhcpT3fXNldniLlgPic4jhLxGmgbyX9CCZiaimU5O86OKf3j40EQVa1lEufeu)q4P9Ui(CzAvcia2o9MiaX5XKlu6NaAqkxEKIiGNCuEbYyeGf3ZXnJaGW4MJYRJswCNGt7P(cuV4rvqq9dHN27I4ZLPvjGay70BIaIswCNGt7rds5YHueb8KJYlqgJaS4EoUzeG4rvqq9dHN27I4ZLPvjGay70BIa4mBtTKNEt0Gu2iifrap5O8cKXialUNJBgbiEufeu)q4P9Ui(CzAvcia2o9MiaRjEdUWG7YoAqdcq86MTfPiszOqkIaEYr5fiJrawCph3mcWqQFy5ZrRMXvnfoRjEd6NCuEb1xG6JQGGA1mUQPWznXBqRsG6nG6lq9gs9wtmg2duprQVyQhoCQ3qQhZTWDiphDDH86Zr3j1to1dLsuFbQhZTWDiphnlebDNup5upukr9gq9gGay70BIaaV0HvdMqds5IrkIaEYr5fiJrawCph3mcacJBokVokzXDcoThbW2P3ebiopMCHs)eqds5YJueb8KJYlqgJaS4EoUzeaBNgYDpFTFG6jN6fp04lCdJH9jq9WHt9yUfUd55OzHiO7K6jN6HsjeaBNEteamj3qUBELWddAqkxoKIiGNCuEbYyeGf3ZXnJaSBku7rhogZZfoysUHC9tokVG6lq92DLITuQpj3fpx14x5odupPPEJI6lq9Kr9rvqqD9dxxmbtBOdAvcuFbQNmQx8OkiO(fnHnCHR0QMcTkbeaBNEteWycVLCWKCd5ObPSrqkIaEYr5fiJrawCph3mcaZTWDiphnlebTkbQhoCQhZTWDiphnlebDNup5uFXgbbW2P3ebCsUlEUIgKYgfsreWtokVazmcWI754MraqyCZr51rjlUtWP9uFbQNmQ3URuSLsD9dxxmbtBOdA8zbjuFbQ3qQ3URuSLs9j5U45Qg)k3zG6jN6nK6nc1tkr9CrCCpxJpKvcPtyUOKfpOXCwg1tkq9LN6nG6HdN6nK6XClChYZrZcrq3j1to1Z2P30z3vk2sj1xG6XClChYZrZcrq3j1tAQVyJq9gq9gGay70BIaIswCNGt7rdszsfsreaBNEteqxRRKNEthRIzeWtokVazmAqkB0rkIaEYr5fiJrawCph3mcGmQhcJBokVMWUYoH5axSlkzXDcoThbW2P3ebWz2MAjp9MObPCrgPic4jhLxGmgbyX9CCZiaqvmjAXbBBpup5eP(YPecGTtVjca8YOKfhniLHsjKIiGNCuEbYyeGf3ZXnJaiJ6HW4MJYRjSRStyoWf7IswCNGt7P(cupzupeg3CuEnHDLDcZbUy3j5U45kcGTtVjcWAI3Glm4USJgKYqbfsreWtokVazmcWI754MradlFoAXRB6Isw8G(jhLxq9fOEYOE7UsXwk1NK7INRA8zbjuFbQ3qQ3AIXWEG6js9ft9WHt9gs9yUfUd55ORlKxFo6oPEYPEOuI6lq9yUfUd55OzHiO7K6jN6HsjQ3aQ3aeaBNEtea4LoSAWeAqkdvXifrap5O8cKXia2o9MiaXRBgCXEocWI754Mray18Glg21rvC2jmxPvnf6xKO2eiCb1xG6fpQccQJQ4StyUsRAk04x5odupPP(YHaSKyL3nmg2NaszOqdszOkpsreaBNEteG41ndUyphb8KJYlqgJgKYqvoKIiGNCuEbYyeGf3ZXnJaIQGG6vDClOdZjSRvjGay70BIagt4TKdMKBihniLHYiifrap5O8cKXialUNJBgbuxiV(C0IomCAp1to1dLrOE4WP(OkiOEvh3c6WCc7Avcia2o9MiaWlDy1Gj0GugkJcPic4jhLxGmgbyX9CCZiG6c51NJw0HHt7PEYPEOmccGTtVjcaYtyhuv6WFWNh0GugksfsreWtokVazmcWI754MradlFoAXRB6Isw8G(jhLxGay70BIagt4TKdMKBihnObnObniea]] )
end
