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
        blood_moon = 5433, -- 355995
        chaotic_imprint = 809, -- 356510
        cleansed_by_flame = 805, -- 205625
        cover_of_darkness = 1206, -- 357419
        demonic_origins = 810, -- 235893
        detainment = 812, -- 205596
        glimpse = 813, -- 354489
        isolated_prey = 5445, -- 357300
        mortal_dance = 1204, -- 328725
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
            duration = function () return pvptalent.isolated_prey.enabled and active_enemies == 1 and 3 or 2 end,
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
            duration = function () return pvptalent.cover_of_darkness.enabled and 10 or 8 end,
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
            duration = 40,
            max_stack = 5,
        },
        -- Legendary
        fel_devastation = {
            id = 333105,
            duration = 2,
            max_stack = 1,
        },
        furious_gaze = {
            id = 343312,
            duration = 12,
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
            duration = 6,
            max_stack = 1,
        },
        prepared = {
            id = 203650,
            duration = 10,
            max_stack = 1,
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

        demon_soul = {

            id = 208195,
            duration = 20,
            max_stack = 1,
        },


        -- PvP Talents
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
        },

        
        -- PvP Talents
        chaotic_imprint_shadow = {
            id = 356656,
            duration = 20,
            max_stack = 1,
        },
        chaotic_imprint_nature = {
            id = 356660,
            duration = 20,
            max_stack = 1,
        },
        chaotic_imprint_arcane = {
            id = 356658,
            duration = 20,
            max_stack = 1,
        },
        chaotic_imprint_fire = {
            id = 356661,
            duration = 20,
            max_stack = 1,
        },
        chaotic_imprint_frost = {
            id = 356659,
            duration = 20,
            max_stack = 1,
        },
        glimpse = {
            id = 354610,
            duration = 8,
            max_stack = 1,
        },
        isolated_prey = {
            id = 357305,
            duration = 6,
            max_stack = 1,
        },
        mortal_dance = {
            id = 328725,
            duration = 5,
            max_stack = 1,
        },

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

                if pvptalent.mortal_dance.enabled then
                    applyDebuff( "target", "mortal_dance" )
                end
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

                if pvptalent.mortal_dance.enabled then
                    applyDebuff( "target", "mortal_dance" )
                end
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

                if pvptalent.isolated_prey.enabled and active_enemies == 1 then
                    applyDebuff( "target", "isolated_prey" )
                end

                -- This is likely repeated per tick but it's not worth the CPU overhead to model each tick.
                if legendary.agony_gaze.enabled and debuff.sinful_brand.up then
                    debuff.sinful_brand.expires = debuff.sinful_brand.expires + 0.75
                end
            end,
            
            finish = function ()
                if level > 58 then applyBuff( "furious_gaze" ) end
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
                if pvptalent.isolated_prey.enabled and active_enemies == 1 then
                    gain( 35, "fury" )
                end
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
        

        metamorphosis = {
            id = 191427,
            cast = 0,
            cooldown = function () return ( level > 47 and 240 or 300 ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) - ( pvptalent.demonic_origins.up and 120 or 0 ) end,
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
                setCooldown( "global_cooldown", 6 )
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

                if pvptalent.glimpse.enabled then applyBuff( "glimpse" ) end
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

                if legendary.blind_faith.enabled then applyBuff( "blind_faith" ) end
            end,

            auras = {
                blind_faith = {
                    id = 355894,
                    duration = 20,
                    max_stack = 1,
                },
            }
        },

        
        -- Demon Hunter - Necrolord - 329554 - fodder_to_the_flame  (Fodder to the Flame)
        --[[ fodder_to_the_flame = {
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
        }, ]]


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

                if legendary.blazing_slaughter.enabled then
                    applyBuff( "immolation_aura" )
                    applyBuff( "blazing_slaughter" )
                end
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
                blazing_slaughter = {
                    id = 355892,
                    duration = 12,
                    max_stack = 20,
                }
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


    spec:RegisterPack( "Havoc", 20211101, [[defPSbqicPfHOQWJOe4siQkAtusFcrzuiKtHqTkfi5vQIAweIBPkPSlk(LQunmvjoMcAziv9mejMgIuDnkLABQsIVPkPACisPZHOQQ1PkLMhIk3JqTpKk)drsvhubIwiLOhQa1ePe0frKKnIOQYhvLKmsfi4KiskRermtvP4MiQkTtvr(PQKunuejvSufi1tjyQkGRQaHSvejv6RisXyPeAVI6VkAWsDyslgspwvnzuDzWMrYNvOrJuoTsRwbc1RPumBIUne7MQFRYWrPoUQKuwoupxKPl56Oy7i47QcJNsjNNs16ruL5Js2VW5H5bYcCTG8t0)c9dho8LHg6PN0jD6F9SqzNnKfyRFB0ril4kcKfgeuc3plWwTlpLNhilKog8hYcclcJuR98bJvQklGYSYIuZZOzbUwq(j6FH(Hdh(Yqd90t6Ko9VswiXg(5NS9R)6zbAlNdEgnlWH0plyHaY5rpiW4fGJEqqjC)GKNocackGJEOirt)l0pmijizW0uFesVni51IM8fkf5WSPDPnfT68Oj15Q98Ozs6ien5duG6Wq0u7iTkAW5jYhrlVX9hTYheZKkGhDDrRSzlTh95s7rxx0Oxkfn1osRsMGKxl63Cxc8OzyhDYU)xFm6JkAYxOuKdZM2L2u0eHSE0hv0u7iTkAmGORNIMqYeDHx3gOIEWwy0yTOb4OlAQhnIAlInzb24JALqwWcSGOTqa58Ohey8cWrpiOeUFqIfybr)0raqqbC0dfjA6FH(HbjbjwGfe9GPP(iKEBqIfybr)Art(cLICy20U0MIwDE0K6C1EE0mjDeIM8bkqDyiAQDKwfn48e5JOL34(Jw5dIzsfWJUUOv2SL2J(CP9ORlA0lLIMAhPvjtqIfybr)Ar)M7sGhnd7Ot29)6JrFurt(cLICy20U0MIMiK1J(OIMAhPvrJbeD9u0esMOl862av0d2cJgRfnahDrt9OruBrSjijir)1EEYWgd)dbvlXOxvsGpPKQDG)y9XzD2A9Ge9x75jdBm8peuTEw87eu8QOsqexraXfEDBGAMS7)zsELieujdiEOilL4cVUnqzgAOPPjtcMOmuuwjs0cVUnqzO3qtttMemrzOOyXQWRBduMHM)Ds(9WnCgSw750jUWRBdug6n)7K87HB4myT2Zjoir)1EEYWgd)dbvRNf)obfVkQeeXveqCHx3gOMj7(FMKxjcbvYaIPxKLsCHx3gOm0BOPPjtcMOmuuwjs0cVUnqzgAOPPjtcMOmuuSyv41Tbkd9M)Ds(9WnCgSw750v41TbkZqZ)oj)E4godwR9CIdsSGOheLGOjv2HOTeuKO1kA59iAYpgS9OFSfTOTuUopAYpgS9Ov55Jr)ylArdBrdWrBHk2MrPIHOpC0wiGCE0wkvoKIMXLqkfntA9XOhKJNBp6xLsEqqI(R98KHng(hcQwpl(DckEvujiIRiGyMemb7WefuKjfd2(8FoFR9CriOsgqCPsWldQCD(KIbB3aUIkbUvIWmoqD4rWWvSnJsfdteGRs5EolwLkbVmCa58jQu5qYaUIkbUvrXmoqD4rWOJNBFoQKhqCqI(R98KHng(hcQwpl(Df)vhM1HXGxbjbjwGfenPYwWNPaE0abaBp6ArGOlAq06VoC0BkALGUsfvcMGe9x75jX8nHzyxbj6V2Ztpl(9)5jgeyIOJ7piXcSGOjnq08ZjRIMFrx02u0LIhHk60dLn71hJUUOv2SL2J2sgSV(y0KMJX5bjwGfeT(R980ZIFhdLIhHAQm1n1Q0VnIixhMFU4HIukEeQ5sjgz93Ybugkkdkd2xFC(4yCUbdi66jrwkXyghOo8iyqzW(6JZhhJZTwQe8YWbKZNOsLdjd4kQe4bjwq0KMTODmv0dMMEPOhGgCy7rF4OTqfBZOuXGirBPu5q0wO6Fi6hBrlAYVfNQOTuEhp6dhTwrtkphnr0)C0p2Iw0dG1vg9rf9GMzDIJUu8iuPGe9x75PNf)obfVkQeeXveqmQu5WKR(hezPelkMXbQdpcMpn9sZIgCy7wffZ4a1HhbdxX2mkvmmraUkL75IqqLmG4sLGxgQfNQjQ8oUbCfvcCwSsSbPCwkEeQKbvQCyYv)ddPtmrKYRvQe8YuyDLZJAIzw3aUIkboXbjwq0KMTOf9GPPxk6bObh2UirBPu5q0wO6Fi6h0ap6Igenkdfv0BkA(9Wfj6hBrlAYVfNQOTuEhpATIM(NJMOHph9JTOf9ayDLrFurpOzwN4OpC0p2Iw0KQuc8peTLyqTjATIM0FoAIiLNJ(Xw0IEaSUYOpQOh0mRtC0LIhHkfKO)App9S43jO4vrLGiUIaIrLkhMC1)GilLymJduhEemFA6LMfn4W2fHGkzaXOmuuMpn9sZIgCy7g(9WzXQuj4LHAXPAIkVJBaxrLa3AIniLZsXJqLmOsLdtU6FyiDIjI(xRuj4LPW6kNh1eZSUbCfvcCIzXs0sLGxMV9VeMh1KMwyGBaxrLa3AIniLZsXJqLmOsLdtU6FyiDIjI0FTsLGxMcRRCEutmZ6gWvujWjoiXcIM0SfTOTqfBZOuXGirBPu5q0wO6FiATI2pmIkJUu8iur)pgVI(bnWJgLHIc4rJApAn6e8pNRy7rduuWVej6dhTkFO2trRv0K(aphn1HJ2p)1Sqa589hKO)App9S43jO4vrLGiUIaIrLkhMC1)GilLymJduhEemCfBZOuXWeb4QuUNlcbvYaIlvcEzOwCQMOY74gWvujWzXIiugkkdcukYHzt7sBYWWMfRsLGxMcRRCEutmZ6gWvujWzXIdOmuugiLa)dtumO2yyytS1eBqkNLIhHkzqLkhMC1)Wq6eteP8ALkbVmfwx58OMyM1nGROsGtmlwIwQe8YWbKZ3VbCfvcCRj2GuolfpcvYGkvom5Q)HH0jM0dsSGOheLGOjvPe4FiAlXGAt0Oa1HHOTuQCiAlu9pe9sf9wrVPOvc6kvujeT68OpkQO)3j53dpir)1EE6zXVtqXRIkbrCfbeJkvom5Q)bro2IXqckrwkXLkbVmqkb(hMOyqTXaUIkbU1)Ds(9Wnqkb(hMOyqTXGbLBpiXcIM0SfTOhKJNBp6xLsEq0QZJEW2)si6Jk6bbTWaxKOvc3YJMjT(y0wkvoeTfQ(hI(bnWJUObyi6nfDrdIM9Lsl6k3YE01fnyRcCE0Qh9G8ivrlSofJmAlXQZds0FTNNEw87eu8QOsqexraXOsLdtU6FqKLsmMXbQdpcgD8C7ZrL8aRLkbVmF7FjmpQjnTWaxecQKbetqXRIkbdQu5WKR(hSQ)Ajat(vM06umYjkwDo5Opir)1EE6zXVtqXRIkbrCfbeZ(o56JtQdprGsfHGkzaXIwQe8YWbKZ3VbCfvcCR)7K87HBqGsromBAxAtgmGORNi3RyLIbB3WbQ9VfDKYlbj6V2Ztpl(DckEvujiIRiGy23jxFCsD4jQu5WKR(heHGkzaXeu8QOsWGkvom5Q)bRerXGTtUx32VwPsWld1It1evEh3aUIkb(GI(xioir)1EE6zXVtqXRIkbrCfbeZ(o56JtQdpb7WefueriOsgqCPsWldhqoF)gWvujWTkAPsWldQCD(KIbB3aUIkbU1)Ds(9WnGDyIckIbdi66jYr04NBquBnOONyRumy7goqT)TOJ(xcsSGOjnBrl6b5452J(vPKhis0Avac7k66Ioz3)rtQSdrBjOirRop6)Ds(9WJMjPJq0uhoAe1wlcds0CgSw75IenJlHukATIMug45Ge9x75PNf)obfVkQeeXveq8dDR1hNuhEQJNBFoQKhiYsjgZ4a1HhbJoEU95OsEGieujdiwu(vM06umYjkwDUP2VnRpA9FNKFpCtADkg5efRo3GbeD9e5g)CdIARbfPBLir)3j53d3GaLICy20U0MmmSzXs)1saMGdilKepKyRj2GuolfpcvYa2HjkOiKtmPeKO)App9S43jO4vrLGiUIaIFOBT(4K6WtKdb8IbrecQKbexQe8YGCiGxmigWvujWTkkkdfLb5qaVyqmmSds0FTNNEw87FvkN6V2ZNYnvI4kci(FNKFp8GelWcIw)1EE6zXVZE)2mzypPW6ic4LiLD2GyoGCUilLyoGC(mDmYjfwhraVs09sqIfybrR)App9S43zVFBMmSNuyDeb8seKJdIDqXqQezPetuPsWldhqoF)tLnBO2cmGROsGBLIbB3WbQ9VfDIjfBZIfMXbQdpcgu568jLUfnROmuugu568jLUfnddBITsKO)7K87HBa7WefuedguUDwSOyW2jhP8cXbj6V2Ztpl(9Ig(EmhL6saezPeJYqrzOa5e9qqvmhb8YKk9BJyBBLiugkkZIGCsT2ZNkdwnmSzXsuugkkdcukYHzt7sBYWWM4Ge9x75PNf)oMXN6V2ZNYnvI4kciMdiNVFrsfE)L4HISuIlvcEz4aY573aUIkbEqI(R980ZIFhZ4t9x75t5MkrCfbe7hgrLbjbjwq0KAurtQl4fn74OvNhTW6umYOTeRopAodwR98O3u0hbahnPn6e8pNNI(Xw0IE4aIenBgm7lrXiL2J(bTLIkAYxOuKdZM2L2u0lcB9xrxx0(vrJbkmKOf9JTOfTgT8Ea4O5myT2ZJ2cVbcs0FTNNm)7K87Hlgbkf5WSPDPnjIuD(6Jt(Mk1)G4HViYsjw0sLGxgoGC((nGROsGB9Feax9Yqa8IMDSbCfvcCRyghOo8iy0XZTphvYdSYVYKwNIrorXQZnyarxprhP1AIniLZsXJqLmiqPihMnTlTP5IWw)f5O3kr)7K87HBa7Wefuedgq01t0r)lSyHEPKvQDKwnXaIUEIC0BBIds0FTNNm)7K87H)S43rGsromBAxAtIivNV(4KVPs9piE4lISuIlvcEz4aY573aUIkbU1)raC1ldbWlA2XgWvujWTIzCG6WJGrhp3(CujpWk)ktADkg5efRo3GbeD9eDKwRj2GuolfpcvYGaLICy20U0MMlcB9xKJERe9VtYVhUbSdtuqrmyarxprh9VyvuckEvujyqLkhMC1)alw)7K87HBqLkhMC1)Gbdi66j6g)CdIAlwSqVuYk1osRMyarxpro6TnXbjwq0dwtv0KVqPihMnTlTPOxQOFar)yLYOhHkAnAkgPmAsLDiAlbfjAmqHHeTOvNh9JZjRI(ia4h4TGOfwNIrgTLy15rZzWATNh9HJEPIUObrd()y8cWrVPOvjYLQOpcaoir)1EEY8VtYVh(ZIFhbkf5WSPDPnjYsjw0sLGxgoGC((nGROsGBLO)Ds(9WnGDyIckIbdi66j6O)fRej6)iaU6LHa4fn7yd4kQe4SyXVYKwNIrorXQZnyarxproXKwwSsSbPCwkEeQKbbkf5WSPDPnnxe26VOBiXSyHEPKvQDKwnXaIUEIC0BBIds0FTNNm)7K87H)S43rGsromBAxAtISuIlvcEz4aY573aUIkbUvI(3j53d3a2HjkOigmGORNOJ(xSsKOeu8QOsWGkvom5Q)bwS(3j53d3Gkvom5Q)bdgq01t0n(5ge1weBLir)hbWvVmeaVOzhBaxrLaNfl(vM06umYjkwDUbdi66jYjM0YIvIniLZsXJqLmiqPihMnTlTP5IWw)fDdjMfl0lLSsTJ0Qjgq01tKJEBtCqI(R98K5FNKFp8Nf)o7R2ZfzPeJYqrzqGsromBAxAtgmGORNOJEBZIf6LswP2rA1edi66jY9kVeKybrBHaLYiROzsq0BbirlVX9hKO)Appz(3j53d)zXVx41TbQHISuIjO4vrLGPWRBduZKD)ptYRep0krOmuugeOuKdZM2L2KHHnlwejAPsWldhqoF)gWvujWTIEPK1)Ds(9WniqPihMnTlTjdgq01t0re1osRMyarxpros9fEDBGYm08VtYVhUHZG1ApN8j9etmlwOxkzLAhPvtmGORNiNy6FHywSiIGIxfvcMcVUnqnt29)mjVsm9wfTWRBdug6n)7K87HBWGYTtmlwIsqXRIkbtHx3gOMj7(FMKxfKO)Appz(3j53d)zXVx41Tbk6fzPetqXRIkbtHx3gOMj7(FMKxjMEReHYqrzqGsromBAxAtgg2SyrKOLkbVmCa589BaxrLa3k6Lsw)3j53d3GaLICy20U0Mmyarxprhru7iTAIbeD9e5i1x41Tbkd9M)Ds(9WnCgSw75KpPNyIzXc9sjRu7iTAIbeD9e5et)leZIfreu8QOsWu41TbQzYU)Nj5vIhAv0cVUnqzgA(3j53d3GbLBNywSeLGIxfvcMcVUnqnt29)mjVkir)1EEY8VtYVh(ZIFpTofJCIIvNlYsjwu(vM06umYjkwDUP2VnRpALirXmoqD4rWOJNBFoQKhWIfr)7K87HBa7Wefuedgq01tKt84NBLIbBNoXKYletSvIe9FNKFpCdcukYHzt7sBYWWMfl9xlbycoGSqs8qIds0FTNNm)7K87H)S43lAWKgJxISuIfTuj4LHdiNVFd4kQe4wfLGIxfvcMh6wRpoPo8e5qaVyqSkkbfVkQemSVtU(4K6WteOuwSqzOOmum49ysZrL8add7Ge9x75jZ)oj)E4pl(DqApTQp5WhdGilLyI0FTeGj4aYcj64qAXaFwkEeQelwyD5tGa4Lr58KzD6iLxioijir)1EEYWbKZ3VyWomrbfrKLsmMXbQdpcgD8C7ZrL8aReP)AjatWbKfs0XH0Ib(Su8iujwSW6YNabWlJY5jZ60rVTFTsLGxMV9VeMh1KMwyGpOg(cXw5xzsRtXiNOy15MA)2S(Ov(vM06umYjkwDUbdi66jYjE8Zds0FTNNmCa589)S43Pa5eZKOjYsjUuj4LHXrpgNp)00lzaxrLa3kkdfLHXrpgNp)00lzyyBLOpnfpcjX0ZIfryD5tGa4Lb5iaiGxM1PB4lwX6YNabWlJY5jZ60n8fIjoir)1EEYWbKZ3)ZIFNdArBMEaaBrwkXeu8QOsWGkvom5Q)HGe9x75jdhqoF)pl(9rPUeGzbiSHujYsjw)1saMGdilKOJdPfd8zP4rOsSyH1LpbcGxgLZtM1PB4lbj6V2ZtgoGC((Fw87fn89yok1LaiYsj(FoNzltcWyTa(CuQlbWaUIkbU1)Ds(9WnGDyIckIbdi66jY9kwffLHIYGaLICy20U0MmmSTkkhqzOOmGTyFjGpFCmo3WWoir)1EEYWbKZ3)ZIFhSdtuqrezPeR)AjatWbKfs0XH0Ib(Su8iujwSW6YNabWlJY5jZ60rVTFTsLGxMV9VeMh1KMwyGpOg(IvIeLGIxfvcgMemb7WefuKjfd2(8FoFR9CwSsSbPCwkEeQeDdzXIIbBNCV(leBvuckEvujyEOBT(4K6WtD8C7ZrL8GGe9x75jdhqoF)pl(DuPYHjx9piYsjMGIxfvcguPYHjx9pyv0)Ds(9WniqPihMnTlTjdguUDRe9VtYVhUbSdtuqrmyarxprNTzXIiSU8jqa8YOCEYSoD)7K87HBfRlFceaVmkNNmRto6TnXehKO)Appz4aY57)zXVViiNuR98PYGvrwkXIIYqrzweKtQ1E(uzWQHHDqI(R98KHdiNV)Nf)U6(sBLATNlYsjwuckEvujyyFNC9Xj1HNOsLdtU6Fiir)1EEYWbKZ3)ZIFNcKOsLdISuIPyW2nCGA)BrNys)LGe9x75jdhqoF)pl(DiLa)dtumO2eKO)Appz4aY57)zXV)PPxAMk8AdiYsjwuckEvujyyFNC9Xj1HNOsLdtU6FWQOeu8QOsWW(o56JtQdpb7WefuKGe9x75jdhqoF)pl(DkqoXmjAISuIlvcEz4aY5tuPYHKbCfvcCRI(VtYVhUbSdtuqrmyq52Ts0NMIhHKy6zXIiSU8jqa8YGCeaeWlZ60n8fRyD5tGa4Lr58KzD6g(cXehKO)Appz4aY57)zXVZbKZtt0Tar(2)sywkEeQK4HISuIXmoqD4rWGYG91hNpogNBLdOmuugugSV(48XX4Cdgq01tKJ0ds0FTNNmCa589)S43Pa5eZKOjYsjw0sLGxgoGC(evQCizaxrLa3AIniLZsXJqLOBOvI(0u8iKetplweH1LpbcGxgKJaGaEzwNUHVyfRlFceaVmkNNmRt3WxiM4Ge9x75jdhqoF)pl(DoGCEAIUfeKO)Appz4aY57)zXVx0W3J5OuxcGilLyugkkZXuZJAIvFemmSds0FTNNmCa589)S43Pa5eZKOjYsjg5iaiGxg(Mk1)aDdTnlwOmuuMJPMh1eR(iyyyhKO)Appz4aY57)zXVta8rGIroXqHbTezPeJCeaeWldFtL6FGUH2oir)1EEYWbKZ3)ZIFVOHVhZrPUearwkXLkbVmCa58jQu5qYaUIkbEqsqI(R98KXpmIkfd2HjkOiISuIXmoqD4rWOJNBFoQKhyLi9xlbycoGSqIooKwmWNLIhHkXIfwx(eiaEzuopzwNUH2MyR8RmP1PyKtuS6CtTFBwF0k)ktADkg5efRo3GbeD9e5ep(5bj6V2Ztg)WiQ8zXVta8rGIroXqHbTezPexQe8YGCiGxmigWvujWTIYqrzyJb2kg4g(9WTwlcq3WGe9x75jJFyev(S43Pa5eZKOjYsjMiugkkdJJEmoF(PPxYWWMflckEvujyEOBT(4K6WtKdb8IbXkrIwQe8YW4OhJZNFA6LmGROsGZILO)7K87HBweKtQ1E(uzWQbdk3oXeBLOpnfpcjX0ZIfryD5tGa4Lb5iaiGxM1PB4lwX6YNabWlJY5jZ60n8fIjoir)1EEY4hgrLpl(DkqorvmwhbrwkX6VwcWeCazHeDCiTyGplfpcvIflSU8jqa8YOCEYSoDKYlbj6V2Ztg)WiQ8zXVZbTOntpaGTilLyckEvujyqLkhMC1)qqI(R98KXpmIkFw87lcYj1ApFQmyvKLsSOOmuuMfb5KATNpvgSAyyhKO)Appz8dJOYNf)(OuxcWSae2qQezPelkbfVkQemp0TwFCsD4jYHaEXGyLi9xlbycoGSqIooKwmWNLIhHkXIfwx(eiaEzuopzwNUHVqCqI(R98KXpmIkFw87fn89yok1LaiYsj(FoNzltcWyTa(CuQlbWaUIkbU1)Ds(9WnGDyIckIbdi66jY9kwffLHIYGaLICy20U0MmmSTkkhqzOOmGTyFjGpFCmo3WWoir)1EEY4hgrLpl(DWomrbfrKLsSOeu8QOsW8q3A9Xj1HNihc4fdIvI0FTeGj4aYcj64qAXaFwkEeQelwyD5tGa4Lr58KzD6gABRejkbfVkQemmjyc2HjkOitkgS95)C(w75SyLyds5Su8iuj6gYIffd2o5E9xi2QOeu8QOsW8q3A9Xj1HN6452NJk5behKO)Appz8dJOYNf)oQu5WKR(hezPetqXRIkbdQu5WKR(hcs0FTNNm(Hru5ZIFNcKOsLdISuIPyW2nCGA)BrNys)LGe9x75jJFyev(S43Huc8pmrXGAtqI(R98KXpmIkFw87Q7lTvQ1EUilLyIkvcEz4aY5tuPYHKbCfvcCwSeLGIxfvcMh6wRpoPo8e5qaVyqyXIIbB3WbQ9Vf5iLxyXcLHIYGaLICy20U0MmyarxproBtSvrjO4vrLGH9DY1hNuhEIkvom5Q)HGe9x75jJFyev(S43)00lntfETbezPetuPsWldhqoFIkvoKmGROsGZILOeu8QOsW8q3A9Xj1HNihc4fdclwumy7goqT)TihP8cXwfLGIxfvcg23jxFCsD4jcuQvrjO4vrLGH9DY1hNuhEIkvom5Q)HGe9x75jJFyev(S43b7WefuerwkXLkbVmOY15tkgSDd4kQe4wX6YNabWlJY5jZ609VtYVhUvrjO4vrLG5HU16JtQdp1XZTphvYdcs0FTNNm(Hru5ZIFNdiNNMOBbI8T)LWSu8iujXdfzPeJzCG6WJGbLb7RpoFCmo3khqzOOmOmyF9X5JJX5gmGORNihPhKO)Appz8dJOYNf)ohqopnr3ccs0FTNNm(Hru5ZIFNcKtmtIMilLyrlvcEzqoeWlged4kQe4wX6YNabWldYraqaVmRt3NMIhH0GA4lwlvcEz4aY5tuPYHKbCfvc8Ge9x75jJFyev(S43PajQu5GilLyKJaGaEz4BQu)d0n02SyHYqrzoMAEutS6JGHHDqI(R98KXpmIkFw87uGCIzs0ezPeJCeaeWldFtL6FGUH2MflIqzOOmhtnpQjw9rWWW2QOLkbVmihc4fdIbCfvcCIds0FTNNm(Hru5ZIFNa4JafJCIHcdAjYsjg5iaiGxg(Mk1)aDdTDqI(R98KXpmIkFw87fn89yok1LaiYsjUuj4LHdiNprLkhsgWvujWZceaCApp)e9Vq)Wxi)h(kzHhk2xFmLfindYb9tKAp9QEB0rpani6fH9HROPoC0K5hgrLKfngE1ywmWJoDiq0ktDiAb8O)0uFesMGK3Soe9W3g9GpNaGlGhnzyghOo8iySizrxx0KHzCG6WJGXIgWvujWjlAIgAlInbjVzDi6HVYBJEWNtaWfWJMmmJduhEemwKSORlAYWmoqD4rWyrd4kQe4KfnrdTfXMGKGesZGCq)eP2tVQ3gD0dqdIEryF4kAQdhnzCGszKfzrJHxnMfd8OthceTYuhIwap6pn1hHKji5nRdrtkVn6bFobaxapAYWmoqD4rWyrYIUUOjdZ4a1HhbJfnGROsGtw0en0weBcsEZ6q0KYBJEWNtaWfWJMmmJduhEemwKSORlAYWmoqD4rWyrd4kQe4KfTwrtQE1Ft0en0weBcsEZ6q0K(BJEWNtaWfWJMmmJduhEemwKSORlAYWmoqD4rWyrd4kQe4KfTwrtQE1Ft0en0weBcsEZ6q02(Trp4Zja4c4rtgMXbQdpcglsw01fnzyghOo8iySObCfvcCYIwROjvV6VjAIgAlInbjVzDi6x)Trp4Zja4c4rtwPsWlJfjl66IMSsLGxglAaxrLaNSO1kAs1R(BIMOH2IytqYBwhI(1FB0d(CcaUaE0KHzCG6WJGXIKfDDrtgMXbQdpcglAaxrLaNSOjAOTi2eK8M1HOho8Trp4Zja4c4rtgMXbQdpcglsw01fnzyghOo8iySObCfvcCYIwROjvV6VjAIgAlInbjbjKMb5G(jsTNEvVn6OhGge9IW(Wv0uhoAYyJH)HGQfzrJHxnMfd8OthceTYuhIwap6pn1hHKji5nRdrt)BJEWNtaWfWJMScVUnqzgASizrxx0Kv41Tbktn0yrYIMi6TfXMGK3Soen9Vn6bFobaxapAYk862aLHEJfjl66IMScVUnqzk6nwKSOjIEBrSji5nRdrtkVn6bFobaxapAYk862aLzOXIKfDDrtwHx3gOm1qJfjlAIO3weBcsEZ6q0KYBJEWNtaWfWJMScVUnqzO3yrYIUUOjRWRBduMIEJfjlAIO3weBcsEZ6q0K(BJEWNtaWfWJMmmJduhEemwKSORlAYWmoqD4rWyrd4kQe4Kfnr0BlInbjbjKMb5G(jsTNEvVn6OhGge9IW(Wv0uhoAY(3j53dNSOXWRgZIbE0PdbIwzQdrlGh9NM6JqYeK8M1HOh(2Oh85eaCb8Oj7Feax9Yyrd4kQe4KfDDrt2)iaU6LXIKfnrdTfXMGK3Soe9W3g9GpNaGlGhnzyghOo8iySizrxx0KHzCG6WJGXIgWvujWjlAIgAlInbjVzDiA6FB0d(CcaUaE0K9pcGREzSObCfvcCYIUUOj7Feax9YyrYIMOH2IytqYBwhIM(3g9GpNaGlGhnzyghOo8iySizrxx0KHzCG6WJGXIgWvujWjlAIgAlInbjVzDiAs5Trp4Zja4c4rt2)iaU6LXIgWvujWjl66IMS)raC1lJfjlAIgAlInbjVzDiAs)Trp4Zja4c4rt2)iaU6LXIgWvujWjl66IMS)raC1lJfjlAIgAlInbjVzDi6x5Trp4Zja4c4rlSido6KDVuBfn5ZORl63WOrZxcBApp6JnG16Wrt07ehnrdTfXMGK3Soe9R82Oh85eaCb8OjRWRBduMHglsw01fnzfEDBGYudnwKSOjAOTi2eK8M1HOFL3g9GpNaGlGhnzfEDBGYqVXIKfDDrtwHx3gOmf9glsw0en0weBcsEZ6q0V(BJEWNtaWfWJwyrgC0j7EP2kAYNrxx0VHrJMVe20EE0hBaR1HJMO3joAIgAlInbjVzDi6x)Trp4Zja4c4rtwHx3gOmdnwKSORlAYk862aLPgASizrt0qBrSji5nRdr)6Vn6bFobaxapAYk862aLHEJfjl66IMScVUnqzk6nwKSOjAOTi2eK8M1HOjTVn6bFobaxapAYWmoqD4rWyrYIUUOjdZ4a1HhbJfnGROsGtw0en0weBcscsindYb9tKAp9QEB0rpani6fH9HROPoC0KXbKZ3pzrJHxnMfd8OthceTYuhIwap6pn1hHKji5nRdrp8Trp4Zja4c4rtwPsWlJfjl66IMSsLGxglAaxrLaNSOjAOTi2eK8M1HOh(2Oh85eaCb8OjdZ4a1HhbJfjl66IMmmJduhEemw0aUIkbozrt0qBrSji5nRdr)kVn6bFobaxapAYkvcEzSizrxx0KvQe8Yyrd4kQe4KfnrdTfXMGK3Soe9qs)Trp4Zja4c4rtgMXbQdpcglsw01fnzyghOo8iySObCfvcCYIMOH2IytqsqcPgc7dxapABhT(R98OLBQsMGKSGYu0oCwqyrgCwqUPkLhil4hgrL5bYpnmpqwaCfvc8SLzHpElaVAwaZ4a1HhbJoEU95OsEGbCfvc8OTgnrrR)AjatWbKfsrtx0CiTyGplfpcvkAwSIgRlFceaVmkNNmRhnDrp02rtC0wJMFLjTofJCIIvNBQ9BZ6JrBnA(vM06umYjkwDUbdi66POjN4Oh)8SG(R98SayhMOGIKR8t0NhilaUIkbE2YSWhVfGxnluQe8YGCiGxmigWvujWJ2A0Omuug2yGTIbUHFp8OTgDTiq00f9WSG(R98SabWhbkg5edfg0kx5NiL8azbWvujWZwMf(4Ta8QzbIIgLHIYW4OhJZNFA6LmmSJMfROjO4vrLG5HU16JtQdproeWlgKOTgnrrlA0LkbVmmo6X485NMEjd4kQe4rZIv0Ig9)oj)E4Mfb5KATNpvgSAWGYThnXrtC0wJMOO)0u8iKIwC00hnlwrtu0yD5tGa4Lb5iaiGxM1JMUOh(s0wJgRlFceaVmkNNmRhnDrp8LOjoAIZc6V2ZZcuGCIzs0Yv(jsppqwaCfvc8SLzHpElaVAwq)1saMGdilKIMUO5qAXaFwkEeQu0Syfnwx(eiaEzuopzwpA6IMuEjlO)ApplqbYjQIX6iKR8t2opqwaCfvc8SLzHpElaVAwGGIxfvcguPYHjx9pKf0FTNNf4Gw0MPhaWox5NEL8azbWvujWZwMf(4Ta8QzbrJgLHIYSiiNuR98PYGvdd7SG(R98SWIGCsT2ZNkdwZv(PxppqwaCfvc8SLzHpElaVAwq0OjO4vrLG5HU16JtQdproeWlgKOTgnrrR)AjatWbKfsrtx0CiTyGplfpcvkAwSIgRlFceaVmkNNmRhnDrp8LOjolO)Applmk1LamlaHnKQCLFI0MhilaUIkbE2YSWhVfGxnl8pNZSLjbySwaFok1LayaxrLapARr)VtYVhUbSdtuqrmyarxpfn5I(vI2A0IgnkdfLbbkf5WSPDPnzyyhT1OfnAoGYqrzaBX(saF(4yCUHHDwq)1EEwOOHVhZrPUeGCLFI8ppqwaCfvc8SLzHpElaVAwq0OjO4vrLG5HU16JtQdproeWlgKOTgnrrR)AjatWbKfsrtx0CiTyGplfpcvkAwSIgRlFceaVmkNNmRhnDrp02rBnAIIw0OjO4vrLGHjbtWomrbfzsXGTp)NZ3AppAwSIoXgKYzP4rOsrtx0dJMfROPyW2JMCr)6VenXrBnArJMGIxfvcMh6wRpoPo8uhp3(CujpiAIZc6V2ZZcGDyIcksUYpn8L8azbWvujWZwMf(4Ta8QzbckEvujyqLkhMC1)qwq)1EEwavQCyYv)d5k)0WH5bYcGROsGNTml8XBb4vZcumy7goqT)TIMoXrt6VKf0FTNNfOajQu5qUYpnK(8azb9x75zbiLa)dtumO2KfaxrLapBzUYpnKuYdKfaxrLapBzw4J3cWRMfik6sLGxgoGC(evQCizaxrLapAwSIw0OjO4vrLG5HU16JtQdproeWlgKOzXkAkgSDdhO2)wrtUOjLxIMfROrzOOmiqPihMnTlTjdgq01trtUOTD0ehT1OfnAckEvujyyFNC9Xj1HNOsLdtU6FilO)ApplOUV0wPw755k)0qsppqwaCfvc8SLzHpElaVAwGOOlvcEz4aY5tuPYHKbCfvc8OzXkArJMGIxfvcMh6wRpoPo8e5qaVyqIMfROPyW2nCGA)Bfn5IMuEjAIJ2A0IgnbfVkQemSVtU(4K6WteO0OTgTOrtqXRIkbd77KRpoPo8evQCyYv)dzb9x75zHpn9sZuHxBGCLFAOTZdKfaxrLapBzw4J3cWRMfkvcEzqLRZNumy7gWvujWJ2A0yD5tGa4Lr58Kz9OPlA9x75Z)Ds(9WJ2A0IgnbfVkQemp0TwFCsD4PoEU95OsEqwq)1EEwaSdtuqrYv(PHVsEGSa4kQe4zlZc6V2ZZcCa580eDlil8XBb4vZcyghOo8iyqzW(6JZhhJZnGROsGhT1O5akdfLbLb7RpoFCmo3GbeD9u0KlAspl8T)LWSu8iuP8tdZv(PHVEEGSG(R98Sahqopnr3cYcGROsGNTmx5NgsAZdKfaxrLapBzw4J3cWRMfen6sLGxgKdb8IbXaUIkbE0wJgRlFceaVmihbab8YSE00f9NMIhHu0dQOh(s0wJUuj4LHdiNprLkhsgWvujWZc6V2ZZcuGCIzs0Yv(PHK)5bYcGROsGNTml8XBb4vZcihbab8YW3uP(hIMUOhA7OzXkAugkkZXuZJAIvFemmSZc6V2ZZcuGevQCix5NO)L8azbWvujWZwMf(4Ta8QzbKJaGaEz4BQu)drtx0dTD0SyfnrrJYqrzoMAEutS6JGHHD0wJw0OlvcEzqoeWlged4kQe4rtCwq)1EEwGcKtmtIwUYpr)W8azbWvujWZwMf(4Ta8QzbKJaGaEz4BQu)drtx0dTDwq)1EEwGa4JafJCIHcdALR8t0tFEGSa4kQe4zlZcF8waE1SqPsWldhqoFIkvoKmGROsGNf0FTNNfkA47XCuQlbix5klWbkLrw5bYpnmpqwq)1EEwGVjmd7klaUIkbE2YCLFI(8azb9x75zH)5jgeyIOJ7plaUIkbE2YCLFIuYdKfaxrLapBzw4yNfsqLf0FTNNfiO4vrLqwGGINUIazbuPYHjx9pKf(4Ta8QzbrJgZ4a1HhbZNMEPzrdoSDd4kQe4rBnArJgZ4a1HhbdxX2mkvmmraUkL75gWvujWZcCi9Xl7ApplqA2I2XurpyA6LIEaAWHTh9HJ2cvSnJsfdIeTLsLdrBHQ)HOFSfTOj)wCQI2s5D8OpC0AfnP8C0er)Zr)ylArpawxz0hv0dAM1jo6sXJqLYceujdKfkvcEzOwCQMOY74gWvujWJMfROtSbPCwkEeQKbvQCyYv)ddJMoXrtu0Ks0Vw0LkbVmfwx58OMyM1nGROsGhnX5k)ePNhilaUIkbE2YSWXolKGklO)ApplqqXRIkHSabfpDfbYcOsLdtU6Fil8XBb4vZcyghOo8iy(00lnlAWHTBaxrLaplWH0hVSR98SaPzlArpyA6LIEaAWHTls0wkvoeTfQ(hI(bnWJUObrJYqrf9MIMFpCrI(Xw0IM8BXPkAlL3XJwROP)5OjA4Zr)ylArpawxz0hv0dAM1jo6dh9JTOfnPkLa)drBjguBIwROj9NJMis55OFSfTOhaRRm6Jk6bnZ6ehDP4rOszbcQKbYcOmuuMpn9sZIgCy7g(9WJMfROlvcEzOwCQMOY74gWvujWJ2A0j2GuolfpcvYGkvom5Q)HHrtN4OjkA6J(1IUuj4LPW6kNh1eZSUbCfvc8OjoAwSIw0OlvcEz(2)syEutAAHbUbCfvc8OTgDIniLZsXJqLmOsLdtU6Fyy00joAIIM0J(1IUuj4LPW6kNh1eZSUbCfvc8Ojox5NSDEGSa4kQe4zlZch7SqcQSG(R98SabfVkQeYceu80veilGkvom5Q)HSWhVfGxnlGzCG6WJGHRyBgLkgMiaxLY9Cd4kQe4zboK(4LDTNNfinBrlAluX2mkvmis0wkvoeTfQ(hIwRO9dJOYOlfpcv0)JXROFqd8OrzOOaE0O2JwJob)Z5k2E0aff8lrI(WrRYhQ9u0AfnPpWZrtD4O9ZFnleqoF)zbcQKbYcLkbVmulovtu5DCd4kQe4rZIv0efnkdfLbbkf5WSPDPnzyyhnlwrxQe8YuyDLZJAIzw3aUIkbE0SyfnhqzOOmqkb(hMOyqTXWWoAIJ2A0j2GuolfpcvYGkvom5Q)HHrtN4OjkAsj6xl6sLGxMcRRCEutmZ6gWvujWJM4OzXkArJUuj4LHdiNVFd4kQe4rBn6eBqkNLIhHkzqLkhMC1)WWOPtC0KEUYp9k5bYcGROsGNTmlCSZcyibvwq)1EEwGGIxfvczbckE6kcKfqLkhMC1)qw4J3cWRMfkvcEzGuc8pmrXGAJbCfvc8OTg9)oj)E4giLa)dtumO2yWGYTNf4q6Jx21EEwyqucIMuLsG)HOTedQnrJcuhgI2sPYHOTq1)q0lv0Bf9MIwjORurLq0QZJ(OOI(FNKFp8CLF61ZdKfaxrLapBzw4yNfsqLf0FTNNfiO4vrLqwGGINUIazbuPYHjx9pKf(4Ta8QzbmJduhEem6452NJk5bgWvujWJ2A0LkbVmF7FjmpQjnTWa3aUIkbEwGdPpEzx75zbsZw0IEqoEU9OFvk5brRop6bB)lHOpQOhe0cdCrIwjClpAM06JrBPu5q0wO6Fi6h0ap6IgGHO3u0fniA2xkTORCl7rxx0GTkW5rRE0dYJufTW6umYOTeRoplqqLmqwGGIxfvcguPYHjx9peT1O1FTeGj)ktADkg5efRopAYfn95k)ePnpqwaCfvc8SLzHJDwibvwq)1EEwGGIxfvczbcQKbYcIgDPsWldhqoF)gWvujWJ2A0)7K87HBqGsromBAxAtgmGORNIMCr)krBnAkgSDdhO2)wrtx0KYlzbckE6kcKfyFNC9Xj1HNiqP5k)e5FEGSa4kQe4zlZch7SqcQSG(R98SabfVkQeYceujdKfiO4vrLGbvQCyYv)drBnAIIMIbBpAYf9RB7OFTOlvcEzOwCQMOY74gWvujWJEqfn9VenXzbckE6kcKfyFNC9Xj1HNOsLdtU6Fix5Ng(sEGSa4kQe4zlZch7SqcQSG(R98SabfVkQeYceujdKfkvcEz4aY573aUIkbE0wJw0OlvcEzqLRZNumy7gWvujWJ2A0)7K87HBa7Wefuedgq01trtUOjk6Xp3GO2k6bv00hnXrBnAkgSDdhO2)wrtx00)swGGINUIazb23jxFCsD4jyhMOGIKR8tdhMhilaUIkbE2YSWXolKGklO)ApplqqXRIkHSabfpDfbYcp0TwFCsD4PoEU95OsEqw4J3cWRMfWmoqD4rWOJNBFoQKhyaxrLaplWH0hVSR98SaPzlArpihp3E0VkL8arIwRcqyxrxx0j7(pAsLDiAlbfjA15r)VtYVhE0mjDeIM6WrJO2AryqIMZG1ApxKOzCjKsrRv0KYapNfiOsgiliA08RmP1PyKtuS6CtTFBwFmARr)VtYVhUjTofJCIIvNBWaIUEkAYf94NBquBf9GkAspARrtu0Ig9)oj)E4geOuKdZM2L2KHHD0SyfT(RLambhqwifT4OhgnXrBn6eBqkNLIhHkza7WefuKOjN4OjLCLFAi95bYcGROsGNTmlCSZcjOYc6V2ZZceu8QOsilqqLmqwOuj4Lb5qaVyqmGROsGhT1OfnAugkkdYHaEXGyyyNfiO4PRiqw4HU16JtQdproeWlgKCLFAiPKhilaUIkbE2YSG(R98SWxLYP(R98PCtvwqUPA6kcKf(3j53dpx5Ngs65bYcGROsGNTml8XBb4vZcOmuugkqorpeufZraVmPs)2eT4OTD0wJMOOrzOOmlcYj1ApFQmy1WWoAwSIw0OrzOOmiqPihMnTlTjdd7OjolO)Applu0W3J5OuxcqUYpn025bYcGROsGNTml8XBb4vZcLkbVmCa589BaxrLaplKk8(R8tdZc6V2ZZcygFQ)ApFk3uLfKBQMUIazboGC((Zv(PHVsEGSa4kQe4zlZc6V2ZZcygFQ)ApFk3uLfKBQMUIazb)WiQmx5klWbKZ3FEG8tdZdKfaxrLapBzw4J3cWRMfWmoqD4rWOJNBFoQKhyaxrLapARrtu06VwcWeCazHu00fnhslg4ZsXJqLIMfROX6YNabWlJY5jZ6rtx00B7OFTOlvcEz(2)syEutAAHbUbCfvc8Ohurp8LOjoARrZVYKwNIrorXQZn1(Tz9XOTgn)ktADkg5efRo3GbeD9u0KtC0JFEwq)1EEwaSdtuqrYv(j6ZdKfaxrLapBzw4J3cWRMfkvcEzyC0JX5Zpn9sgWvujWJ2A0Omuuggh9yC(8ttVKHHD0wJMOO)0u8iKIwC00hnlwrtu0yD5tGa4Lb5iaiGxM1JMUOh(s0wJgRlFceaVmkNNmRhnDrp8LOjoAIZc6V2ZZcuGCIzs0Yv(jsjpqwaCfvc8SLzHpElaVAwGGIxfvcguPYHjx9pKf0FTNNf4Gw0MPhaWox5Ni98azbWvujWZwMf(4Ta8Qzb9xlbycoGSqkA6IMdPfd8zP4rOsrZIv0yD5tGa4Lr58Kz9OPl6HVKf0FTNNfgL6saMfGWgsvUYpz78azbWvujWZwMf(4Ta8QzH)5CMTmjaJ1c4ZrPUead4kQe4rBn6)Ds(9WnGDyIckIbdi66POjx0Vs0wJw0OrzOOmiqPihMnTlTjdd7OTgTOrZbugkkdyl2xc4ZhhJZnmSZc6V2ZZcfn89yok1LaKR8tVsEGSa4kQe4zlZcF8waE1SG(RLambhqwifnDrZH0Ib(Su8iuPOzXkASU8jqa8YOCEYSE00fn92o6xl6sLGxMV9VeMh1KMwyGBaxrLap6bv0dFjARrtu0IgnbfVkQemmjyc2HjkOitkgS95)C(w75rZIv0j2GuolfpcvkA6IEy0Syfnfd2E0Kl6x)LOjoARrlA0eu8QOsW8q3A9Xj1HN6452NJk5bzb9x75zbWomrbfjx5NE98azbWvujWZwMf(4Ta8QzbckEvujyqLkhMC1)q0wJw0O)3j53d3GaLICy20U0Mmyq52J2A0ef9)oj)E4gWomrbfXGbeD9u00fTTJMfROjkASU8jqa8YOCEYSE00fT(R985)oj)E4rBnASU8jqa8YOCEYSE0KlA6TD0ehnXzb9x75zbuPYHjx9pKR8tK28azbWvujWZwMf(4Ta8QzbrJgLHIYSiiNuR98PYGvdd7SG(R98SWIGCsT2ZNkdwZv(jY)8azbWvujWZwMf(4Ta8QzbrJMGIxfvcg23jxFCsD4jQu5WKR(hYc6V2ZZcQ7lTvQ1EEUYpn8L8azbWvujWZwMf(4Ta8QzbkgSDdhO2)wrtN4Oj9xYc6V2ZZcuGevQCix5Ngompqwq)1EEwasjW)WefdQnzbWvujWZwMR8tdPppqwaCfvc8SLzHpElaVAwq0OjO4vrLGH9DY1hNuhEIkvom5Q)HOTgTOrtqXRIkbd77KRpoPo8eSdtuqrYc6V2ZZcFA6LMPcV2a5k)0qsjpqwaCfvc8SLzHpElaVAwOuj4LHdiNprLkhsgWvujWJ2A0Ig9)oj)E4gWomrbfXGbLBpARrtu0FAkEesrloA6JMfROjkASU8jqa8YGCeaeWlZ6rtx0dFjARrJ1LpbcGxgLZtM1JMUOh(s0ehnXzb9x75zbkqoXmjA5k)0qsppqwaCfvc8SLzb9x75zboGCEAIUfKf(4Ta8QzbmJduhEemOmyF9X5JJX5gWvujWJ2A0CaLHIYGYG91hNpogNBWaIUEkAYfnPNf(2)sywkEeQu(PH5k)0qBNhilaUIkbE2YSWhVfGxnliA0LkbVmCa58jQu5qYaUIkbE0wJoXgKYzP4rOsrtx0dJ2A0ef9NMIhHu0IJM(OzXkAIIgRlFceaVmihbab8YSE00f9WxI2A0yD5tGa4Lr58Kz9OPl6HVenXrtCwq)1EEwGcKtmtIwUYpn8vYdKf0FTNNf4aY5Pj6wqwaCfvc8SL5k)0WxppqwaCfvc8SLzHpElaVAwaLHIYCm18OMy1hbdd7SG(R98SqrdFpMJsDja5k)0qsBEGSa4kQe4zlZcF8waE1SaYraqaVm8nvQ)HOPl6H2oAwSIgLHIYCm18OMy1hbdd7SG(R98SafiNyMeTCLFAi5FEGSa4kQe4zlZcF8waE1SaYraqaVm8nvQ)HOPl6H2olO)Applqa8rGIroXqHbTYv(j6FjpqwaCfvc8SLzHpElaVAwOuj4LHdiNprLkhsgWvujWZc6V2ZZcfn89yok1LaKRCLf(3j53dppq(PH5bYcGROsGNTml8XBb4vZcIgDPsWldhqoF)gWvujWJ2A0)Ja4QxgcGx0SJJ2A0yghOo8iy0XZTphvYdmGROsGhT1O5xzsRtXiNOy15gmGORNIMUOjTrBn6eBqkNLIhHkzqGsromBAxAtZfHT(ROjx00hT1Ojk6)Ds(9WnGDyIckIbdi66POPlA6FjAwSIg9sPOTgn1osRMyarxpfn5IMEBhnXzbP681hN8nvQ)HSWWxYc6V2ZZciqPihMnTlTPSahsF8YU2ZZcKAurtQl4fn74OvNhTW6umYOTeRopAodwR98O3u0hbahnPn6e8pNNI(Xw0IE4aIenBgm7lrXiL2J(bTLIkAYxOuKdZM2L2u0lcB9xrxx0(vrJbkmKOf9JTOfTgT8Ea4O5myT2ZJ2cVbYv(j6ZdKfaxrLapBzw4J3cWRMfkvcEz4aY573aUIkbE0wJ(Feax9Yqa8IMDC0wJgZ4a1HhbJoEU95OsEGbCfvc8OTgn)ktADkg5efRo3GbeD9u00fnPnARrNyds5Su8iujdcukYHzt7sBAUiS1Ffn5IM(OTgnrr)VtYVhUbSdtuqrmyarxpfnDrt)lrBnArJMGIxfvcguPYHjx9penlwr)VtYVhUbvQCyYv)dgmGORNIMUOh)CdIAROzXkA0lLI2A0u7iTAIbeD9u0KlA6TD0eNf0FTNNfqGsromBAxAtzbP681hN8nvQ)HSWWxYv(jsjpqwaCfvc8SLzb9x75zbeOuKdZM2L2uwGdPpEzx75zHbRPkAYxOuKdZM2L2u0lv0pGOFSsz0JqfTgnfJugnPYoeTLGIengOWqIw0QZJ(X5KvrFea8d8wq0cRtXiJ2sS68O5myT2ZJ(WrVurx0GOb)FmEb4O3u0Qe5sv0hbaNf(4Ta8QzbrJUuj4LHdiNVFd4kQe4rBnAII(FNKFpCdyhMOGIyWaIUEkA6IM(xI2A0efTOr)pcGREziaErZooAwSIMFLjTofJCIIvNBWaIUEkAYjoAsB0SyfDIniLZsXJqLmiqPihMnTlTP5IWw)v00f9WOjoAwSIg9sPOTgn1osRMyarxpfn5IMEBhnX5k)ePNhilaUIkbE2YSWhVfGxnluQe8YWbKZ3VbCfvc8OTgnrr)VtYVhUbSdtuqrmyarxpfnDrt)lrBnAIIw0OjO4vrLGbvQCyYv)drZIv0)7K87HBqLkhMC1)Gbdi66POPl6Xp3GO2kAIJ2A0efTOr)pcGREziaErZooAwSIMFLjTofJCIIvNBWaIUEkAYjoAsB0SyfDIniLZsXJqLmiqPihMnTlTP5IWw)v00f9WOjoAwSIg9sPOTgn1osRMyarxpfn5IMEBhnXzb9x75zbeOuKdZM2L2uUYpz78azbWvujWZwMf(4Ta8QzbugkkdcukYHzt7sBYGbeD9u00fn92oAwSIg9sPOTgn1osRMyarxpfn5I(vEjlO)ApplW(Q98CLF6vYdKfaxrLapBzwq)1EEwOWRBdudZcCi9Xl7ApplyHaLYiROzsq0BbirlVX9Nf(4Ta8QzbckEvujyk862a1mz3)ZK8QOfh9WOTgnrrJYqrzqGsromBAxAtgg2rZIv0efTOrxQe8YWbKZ3VbCfvc8OTgn6LsrBn6)Ds(9WniqPihMnTlTjdgq01trtx0efn1osRMyarxpfn5i1hDHx3gOm1qZ)oj)E4godwR98OFpA6JM4OjoAwSIg9sPOTgn1osRMyarxpfn5ehn9VenXrZIv0efnbfVkQemfEDBGAMS7)zsEv0IJM(OTgTOrx41TbktrV5FNKFpCdguU9OjoAwSIw0OjO4vrLGPWRBduZKD)ptYRYv(PxppqwaCfvc8SLzHpElaVAwGGIxfvcMcVUnqnt29)mjVkAXrtF0wJMOOrzOOmiqPihMnTlTjdd7OzXkAIIw0OlvcEz4aY573aUIkbE0wJg9sPOTg9)oj)E4geOuKdZM2L2Kbdi66POPlAIIMAhPvtmGORNIMCK6JUWRBduMIEZ)oj)E4godwR98OFpA6JM4OjoAwSIg9sPOTgn1osRMyarxpfn5ehn9VenXrZIv0efnbfVkQemfEDBGAMS7)zsEv0IJEy0wJw0Ol862aLPgA(3j53d3GbLBpAIJMfROfnAckEvujyk862a1mz3)ZK8QSG(R98SqHx3gOOpx5NiT5bYcGROsGNTml8XBb4vZcIgn)ktADkg5efRo3u73M1hJ2A0efTOrJzCG6WJGrhp3(CujpWaUIkbE0Syfnrr)VtYVhUbSdtuqrmyarxpfn5eh94NhT1OPyW2JMoXrtkVenXrtC0wJMOOfn6)Ds(9WniqPihMnTlTjdd7OzXkA9xlbycoGSqkAXrpmAIZc6V2ZZcP1PyKtuS68CLFI8ppqwaCfvc8SLzHpElaVAwq0OlvcEz4aY573aUIkbE0wJw0OjO4vrLG5HU16JtQdproeWlgKOTgTOrtqXRIkbd77KRpoPo8ebknAwSIgLHIYqXG3JjnhvYdmmSZc6V2ZZcfnysJXRCLFA4l5bYcGROsGNTml8XBb4vZcefT(RLambhqwifnDrZH0Ib(Su8iuPOzXkASU8jqa8YOCEYSE00fnP8s0eNf0FTNNfaP90Q(KdFma5kxzb2y4FiOALhi)0W8azb9x75zb0RkjWNus1oWFS(4SoBTEwaCfvc8SL5k)e95bYcGROsGNTmlCSZcjOYc6V2ZZceu8QOsilqqLmqwyyw4J3cWRMfk862aLPgAOPPjtcMOmuurBnAIIw0Ol862aLPO3qtttMemrzOOIMfROl862aLPgA(3j53d3WzWATNhnDIJUWRBduMIEZ)oj)E4godwR98OjolqqXtxrGSqHx3gOMj7(FMKxLR8tKsEGSa4kQe4zlZch7SqcQSG(R98SabfVkQeYceujdKfOpl8XBb4vZcfEDBGYu0BOPPjtcMOmuurBnAIIw0Ol862aLPgAOPPjtcMOmuurZIv0fEDBGYu0B(3j53d3WzWATNhnDrx41Tbktn08VtYVhUHZG1AppAIZceu80veilu41TbQzYU)Nj5v5k)ePNhilaUIkbE2YSWXolKGklO)ApplqqXRIkHSabvYazHsLGxgu568jfd2UbCfvc8OTgnrrJzCG6WJGHRyBgLkgMiaxLY9Cd4kQe4rZIv0LkbVmCa58jQu5qYaUIkbE0wJw0OXmoqD4rWOJNBFoQKhyaxrLapAIZcCi9Xl7ApplmikbrtQSdrBjOirRv0Y7r0KFmy7r)ylArBPCDE0KFmy7rRYZhJ(Xw0Ig2IgGJ2cvSnJsfdrF4OTqa58OTuQCifnJlHukAM06Jrpihp3E0VkL8GSabfpDfbYcmjyc2HjkOitkgS95)C(w755k)KTZdKf0FTNNfu8xDywhgdELfaxrLapBzUYvUYvUYza]] )


end
