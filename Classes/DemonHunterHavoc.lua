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
                    debuff.sinful.brand.expires = debuff.sinful_brand.expires + 0.5
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


    spec:RegisterPack( "Havoc", 20210627, [[daLgsbqiKulcbcEerv1LuKKSjfLpjqnkKWPqqRIiH8kbXSqP6wiqAxK8lfPggaCmb1YqIEgaQPHaCnIK2MGK(MGeJJiH6CkssToeOMNGu3Ji2hsY)uKuCqIQuwirLhIaAIevXfjQkTrfjvFKOQWijQs1jrGOvcqZKir3ursu7uG8tei0qvKeSuIQKNIOPsK6Qksk9vIemwfj2lP(RcdwvhMYIvQhRKjt4YqBgP(mcnAIYPLA1ksI8AukZgv3gODt1Vvz4c44evfTCqpxOPl66Oy7a67kIXdGCEfvRxrsO5Js2VK1H1sRjfwI6GOeauggaHkLHIkCOcWaqQuQjZ5bqnzaBXMre1KUbIAs5Dd4T0KbS58ZeAP1KXJbUqnjzdYWTSpNaHgDQj3mnpjiD9wtkSe1brjaOmmacvkdfv4qLYqrQAYyaCPdsQHsOOjL1cb66TMuGXLMuEqWZRxENXtewV8Ub8wfGaY4y9ugkSxpLaGYWfGfGeOmZjIrcUaKGw)uzmnWdgq2f7y9MlQFQWL951ZenIy9ee2i9bX6PBIYY6rxejiup)i2R6nXujMyII6ZRElqa(86pNpV(8QFFXy90nrzzuPjdap6MJAs5x(RxEqWZRxENXtewV8Ub8wfGYV8xpGmowpLHc71tjaOmCbybO8l)1tGYmNigj4cq5x(RNGw)uzmnWdgq2f7y9MlQFQWL951ZenIy9ee2i9bX6PBIYY6rxejiup)i2R6nXujMyII6ZRElqa(86pNpV(8QFFXy90nrzzuvawaARSppQcaX1bUTuY(YKJIbn3MJIjTtCKha1EbOTY(8Okaexh42YqKmnqd22MJS7gikjHTZgMJ4CFnI8lzhOXzqjHzVPLKW2zdtvyLmloyI4yZqtpJcQty7SHPIsLmloyI4yZqtZIvcBNnmvHvR74IBIRemql7ZPsscBNnmvuQw3Xf3exjyGw2NtybOTY(8Okaexh42YqKmnqd22MJS7gikjHTZgMJ4CFnI8lzhOXzqjuYEtljHTZgMkkvYS4GjIJndn9mkOoHTZgMQWkzwCWeXXMHMMfRe2oByQOuTUJlUjUsWaTSpNQe2oByQcRw3Xf3exjyGw2NtybO8x)uBeRx(ohRxo0aR3Y653K6N6mW51pPtz1lhVDr9tDg486xh4UDuu)KoLvp2PmewV8yq2iYniw)bRxEqWZRxoUjWybOTY(8Okaexh42YqKmnqd22MJS7gikHjIdCoo2OboOzGZhRZfD2NZoqJZGssJJEQ282fdAg4Cf62MJIzuazCK(GerLWGSrKBqCaIcJZ7ZzXkno6PsGGNp2CtGrf62MJcclalalaLF5VE5laHlMef1Jar486ZgeRpLH1BR8G13X6nGwZTnhvfG2k7ZJseDeYeilaTv2NhdrY0RZJmG4a0i2Rcq5x(RxkG1lop4SEXvFkRJ1NgKiM1hNybc0oX6ZRElqa(86LJb6TtSEPWX4Icq5x(R3wzFEmejtdX0GeXCym5nSmTfBSZBhhlHKWSNgKiMJMwcy7eSa3m00Qnd0BN4yYX4cfebT2JS30sGmosFqIOAZa92joMCmUywAC0tLabpFS5MaJk0TnhffGYF9sHoLDmz9eOm7I1lTm8GZR)G1lpgKnICdISxVCCtG1lpMVW6N0PS6N6nmM1lh)or9hSElRhGdPEkOmK6N0PS6LgAnV(JUE5ft7ewFAqIyglaTv2NhdrY0anyBBoYUBGOKn3e4qy(czVPLqnKXr6dsevlz2fhPm8GZNrnKXr6dsevcdYgrUbXbikmoVpNDGgNbLKgh9ur3Wyo287ek0TnhfSyfdGC(inirmJQn3e4qy(cdtLekaycAAC0tvcTMpo6bKPDf62MJcclaL)6LcDkREcuMDX6LwgEW5SxVCCtG1lpMVW6Nid96tzy9BgA667y9IBIZE9t6uw9t9ggZ6LJFNOElRNYqQNIWHu)KoLvV0qR51F01lVyANW6py9t6uw9Y3ye9fwVCq0yRElRNacPEka4qQFsNYQxAO186p66LxmTty9PbjIzSa0wzFEmejtd0GTT5i7UbIs2CtGdH5lK9MwcKXr6dsevlz2fhPm8GZzhOXzqjBgAA1sMDXrkdp4CL4M4SyLgh9ur3Wyo287ek0TnhfZIbqoFKgKiMr1MBcCimFHHPscfusqtJJEQsO18XrpGmTRq32CuqilwuNgh9uTMV444OhYSeIcf62MJIzXaiNpsdseZOAZnboeMVWWujHccGGMgh9uLqR5JJEazAxHUT5OGWcq5VEPqNYQxEmiBe5gezVE54MaRxEmFH1Bz9(bbnE9PbjIz9RJXZ6Nid963m00OO(986T6J46CHbNxpstJRK96py9gFInpwVL1tashs90hSE)CcQ8GGN3RcqBL95XqKmnqd22MJS7gikzZnboeMVq2BAjqghPpirujmiBe5gehGOW48(C2bACgusAC0tfDdJ5yZVtOq32CuWIffBgAAfiMg4bdi7IDuXeGfR04ONQeAnFC0dit7k0TnhfSyjWndnTcJr0x4ydrJnftacNfdGC(inirmJQn3e4qy(cdtLekaycAAC0tvcTMpo6bKPDf62MJcczXI604ONkbcEEVuOBBokMfdGC(inirmJQn3e4qy(cdtLecOau(RFQnI1lFJr0xy9YbrJT63i9bX6LJBcSE5X8fwFtxFN13X6nGwZTnhR3Cr9hnD9R74IBIxaARSppgIKPbAW22CKD3arjBUjWHW8fY(fqceJyYEtljno6PcJr0x4ydrJnf62MJIzR74IBIRWye9fo2q0ytbrtmVa0wzFEmejtd0GTT5i7UbIscChVDId6doaX0yhOXzqjuNgh9ujqWZ7LcDBZrXS1DCXnXvGyAGhmGSl2rfebT2JHouNrZaNReiDV6KkagafG2k7ZJHizAGgSTnhz3nqusG74TtCqFWXMBcCimFHSd04mOeGgSTnhvBUjWHW8foJcAg48qhksLGMgh9ur3Wyo287ek0TnhfsrucaclaTv2NhdrY0anyBBoYUBGOKa3XBN4G(GdCoo2ObYoqJZGssJJEQei459sHUT5Oyg1PXrpvBE7IbndCUcDBZrXS1DCXnXv4CCSrdubrqR9yOPG4sOanaskIscNrZaNReiDV6KkkbqbOTY(8yisMgObBBZr2DdeLmX6SDId6doapq0tgq2bACgusAC0tf4bIEYaQq32CumJ6ndnTc8arpzavmbkaTv2NhdrY0lJZh2k7Zh8oMS7gikzDhxCt8cqBL95XqKmDkdEtge5wdezVPLSzOPv0iFSpWTbfGONQyAl2Ki1zuSzOPvni4XTSpFymqtXeGflQ3m00kqmnWdgq2f7OIjaHfG2k7ZJHizAiJpSv2Np4Dmz3nquIabpVxShtyVsjHzVPLKgh9ujqWZ7LcDBZrrbOTY(8yisMgY4dBL95dEht2DdeL4he04fGfG2k7ZJQ1DCXnXLaIPbEWaYUyhzVPLqDAC0tLabpVxk0TnhfZw3Xf3exHZXXgnqfebT2JurjaMrb1Rdi6MNkGONYMdvOBBokyXIAXLQy70m8XgAUqL9IT2jsilw0nrz5aIGw7XqtPulaTv2NhvR74IBIhIKPbX0apyazxSJS30ssJJEQei459sHUT5OygfR74IBIRW54yJgOcIGw7rQOeaZOGAGgSTnhvBUjWHW8fYI16oU4M4Qn3e4qy(cvqe0ApsfXLqbAaeHeoJcQxhq0npvarpLnhQq32CuWIf1IlvX2Pz4Jn0CHk7fBTtKqwSOBIYYbebT2JHMsPwaARSppQw3Xf3epejth4Y(C2BAjBgAAfiMg4bdi7IDubrqR9ivukvwS2xmoJUjklhqe0Apg6qfafGYF9YdsBm8SEMiwFNiy98JyVkaTv2NhvR74IBIhIKPzI4OtemYEKFzuscBNnmdZEtlbObBBZrvcBNnmhX5(Ae5xkj8mk2m00kqmnWdgq2f7OIjalwuqDAC0tLabpVxk0TnhfZw3Xf3exbIPbEWaYUyhvqe0Apsff0nrz5aIGw7rQMAsy7SHPkSADhxCtCLGbAzF(ufLesilw0nrz5aIGw7XqlHsaqilwua0GTT5OkHTZgMJ4CFnI8lLq5mQty7SHPIs16oU4M4kiAI5eYIf1anyBBoQsy7SH5io3xJi)YcqBL95r16oU4M4HizAMio6ebJSh5xgLKW2zdtkzVPLa0GTT5OkHTZgMJ4CFnI8lLq5mk2m00kqmnWdgq2f7OIjalwuqDAC0tLabpVxk0TnhfZw3Xf3exbIPbEWaYUyhvqe0Apsff0nrz5aIGw7rQMAsy7SHPIs16oU4M4kbd0Y(8PkkjKqwSOBIYYbebT2JHwcLaGqwSOaObBBZrvcBNnmhX5(Ae5xkj8mQty7SHPkSADhxCtCfenXCczXIAGgSTnhvjSD2WCeN7RrKFzbOTY(8OADhxCt8qKmDSDAg(ydnxWEtlHAXLQy70m8XgAUqL9IT2jwaARSppQw3Xf3epejtNYWHmgpzVPLqDAC0tLabpVxk0TnhfZOgObBBZr1eRZ2joOp4a8arpzaNrnqd22MJQa3XBN4G(GdqmnwS2m00kAgyFmXbrBQiQycuaARSppQw3Xf3epejtJ85X28HaxqezVPLqHTYgioqhbBmsLaJnefJ0GeXmYIf0AXabIEQmHiQANkagaewawaARSppQei459scnYhqMOm2BAjPXrpvm((yCXyjZUOcDBZrXSndnTIX3hJlglz2fvmbMrXsMbjIrjuYIffqRfdei6Pc8aIGONQ2PkmaMbTwmqGONktiIQ2PkmaiKWcqBL95rLabpVxHizAbAPSrCcIbyVPLa0GTT5OAZnboeMVWcqBL95rLabpVxHizAICRbIJebdGXK9MwITYgioqhbBmsLaJnefJ0GeXmYIf0AXabIEQmHiQANQWaOa0wzFEujqWZ7visMoLbVjdICRbIS30swNly6ufri0sumiYTgiQq32CumBDhxCtCfohhB0avqe0Apg6qDg1BgAAfiMg4bdi7IDuXeyg1cCZqtRqakWfrXyYX4cftGcqBL95rLabpVxHizACoo2ObYEtlXwzdehOJGngPsGXgIIrAqIygzXcATyGarpvMqevTtfLsDgfud0GTT5OIjIdCoo2OboOzGZhRZfD2NZIvmaY5J0GeXmsvywSOzGZdDOaaclaTv2Nhvce88EfIKP3CtGdH5lK9Mwcqd22MJQn3e4qy(cNr96oU4M4kqmnWdgq2f7OcIMy(mkw3Xf3exHZXXgnqfebT2JujvwSOaATyGarpvMqevTt16oU4M4ZGwlgiq0tLjerv7HMsPsiHfG2k7ZJkbcEEVcrY0ni4XTSpFymqJ9Mwc1BgAAvdcECl7Zhgd0umbkaTv2Nhvce88EfIKPn3Bzn3Y(C2BAjud0GTT5OkWD82joOp4yZnboeMVWcqBL95rLabpVxHizAAKV5MazVPLqZaNReiDV6KkjeaakaTv2Nhvce88EfIKPXye9fo2q0yRa0wzFEujqWZ7visMEjZU4iMWMnK9Mwc1anyBBoQcChVDId6do2CtGdH5lCg1anyBBoQcChVDId6doW54yJgybOTY(8OsGGN3RqKmTabppo2DISVMV44inirmJscZEtlbY4i9bjIQnd0BN4yYX4IzcCZqtR2mqVDIJjhJluqe0ApgAcOa0wzFEujqWZ7visMMg5ditug7nTeQtJJEQei45Jn3eyuHUT5OywmaY5J0GeXmsv4zuSKzqIyucLSyrb0AXabIEQapGii6PQDQcdGzqRfdei6PYeIOQDQcdacjSa0wzFEujqWZ7visMwGGNhh7oXcqBL95rLabpVxHiz6ug8MmiYTgiYEtlzZqtRoMCC0dO5erftGcqBL95rLabpVxHizAAKpGmrzS30sapGii6Ps0X08fsvyPYI1MHMwDm54OhqZjIkMafG2k7ZJkbcEEVcrY0arNisZWhqmHOLS30sapGii6Ps0X08fsvyPwaARSppQei459kejtNYG3KbrU1ar2BAjPXrpvce88XMBcmQq32CuuawaARSppQ8dcACjarNisZWhqmHOLS30ssJJEQapq0tgqf62MJIzBgAAvaigWGOqjUj(SSbrQcxaARSppQ8dcA8qKmnnYhqMOm2BAjuSzOPvm((yCXyjZUOIjalwanyBBoQMyD2oXb9bhGhi6jd4mkOono6PIX3hJlglz2fvOBBokyXI61DCXnXvni4XTSpFymqtbrtmNqcNrXsMbjIrjuYIffqRfdei6Pc8aIGONQ2PkmaMbTwmqGONktiIQ2PkmaiKWcqBL95rLFqqJhIKPPr(yBqOrezVPLyRSbId0rWgJujWydrXinirmJSybTwmqGONktiIQ2PcGbqbOTY(8OYpiOXdrY0c0szJ4eedWEtlbObBBZr1MBcCimFHfG2k7ZJk)GGgpejt3GGh3Y(8HXan2BAjuVzOPvni4XTSpFymqtXeOa0wzFEu5he04HizAICRbIJebdGXK9Mwc1anyBBoQMyD2oXb9bhGhi6jd4mkSv2aXb6iyJrQeySHOyKgKiMrwSGwlgiq0tLjerv7ufgaewaARSppQ8dcA8qKmDkdEtge5wdezVPLSoxW0PkIqOLOyqKBnquHUT5Oy26oU4M4kCoo2ObQGiO1Em0H6mQ3m00kqmnWdgq2f7OIjWmQf4MHMwHauGlIIXKJXfkMafG2k7ZJk)GGgpejtJZXXgnq2BAjud0GTT5OAI1z7eh0hCaEGONmGZOWwzdehOJGngPsGXgIIrAqIygzXcATyGarpvMqevTtvyPoJcQbAW22CuXeXbohhB0ah0mW5J15Io7ZzXkga58rAqIygPkmlw0mW5HouaaHewaARSppQ8dcA8qKm9MBcCimFHS30saAW22CuT5MahcZxybOTY(8OYpiOXdrY00iFZnbYEtlHMboxjq6E1jvsiaauaARSppQ8dcA8qKmngJOVWXgIgBfG2k7ZJk)GGgpejtBU3YAUL95S30sOino6PsGGNp2CtGrf62MJcwSOgObBBZr1eRZ2joOp4a8arpzazXIMboxjq6E1zObyaWI1MHMwbIPbEWaYUyhvqe0ApgAPs4mQbAW22Cuf4oE7eh0hCS5MahcZxybOTY(8OYpiOXdrY0lz2fhXe2SHS30sOino6PsGGNp2CtGrf62MJcwSOgObBBZr1eRZ2joOp4a8arpzazXIMboxjq6E1zObyaq4mQbAW22Cuf4oE7eh0hCaIPnJAGgSTnhvbUJ3oXb9bhBUjWHW8fwaARSppQ8dcA8qKmnohhB0azVPLKgh9uT5Tlg0mW5k0TnhfZGwlgiq0tLjerv7uTUJlUjEbOTY(8OYpiOXdrY0ce884y3jY(A(IJJ0GeXmkjm7nTeiJJ0hKiQ2mqVDIJjhJlMjWndnTAZa92joMCmUqbrqR9yOjGcqBL95rLFqqJhIKPfi45XXUtSa0wzFEu5he04HizAAKpGmrzS30sOono6Pc8arpzavOBBokMbTwmqGONkWdicIEQANQLmdseJsrHbWS04ONkbcE(yZnbgvOBBokkaTv2Nhv(bbnEisMMg5BUjq2BAjGhqee9uj6yA(cPkSuzXAZqtRoMCC0dO5erftGcqBL95rLFqqJhIKPPr(aYeLXEtlb8aIGONkrhtZxivHLklwuSzOPvhtoo6b0CIOIjWmQtJJEQapq0tgqf62MJcclaTv2Nhv(bbnEisMgi6erAg(aIjeTK9Mwc4bebrpvIoMMVqQcl1cqBL95rLFqqJhIKPtzWBYGi3AGi7nTK04ONkbcE(yZnbgvOBBok0KarySpxheLaGYWaqQaGsn5ed6TtmQjLcYBYRGiids(GGRVEPLH13Gboywp9bRpy)GGgp46HO8jtdrr9XdeR3yYd0suu)sM5eXOQaukBhRpSuj46jWZbIWef1hmKXr6dsevtj46ZR(GHmosFqIOAkk0TnhfbxpfHbicvfGfGsb5n5vqeKbjFqW1xV0YW6BWahmRN(G1hSaPngEgC9qu(KPHOO(4bI1Bm5bAjkQFjZCIyuvakLTJ1dWeC9e45aryII6dgY4i9bjIQPeC95vFWqghPpirunff62MJIGRNIWaeHQcqPSDSEaMGRNaphictuuFWqghPpirunLGRpV6dgY4i9bjIQPOq32CueC9wwV8LGOuwpfHbicvfGsz7y9eabxpbEoqeMOO(GHmosFqIOAkbxFE1hmKXr6dsevtrHUT5Oi46TSE5lbrPSEkcdqeQkaLY2X6LkbxpbEoqeMOO(GHmosFqIOAkbxFE1hmKXr6dsevtrHUT5Oi46TSE5lbrPSEkcdqeQkalaLcYBYRGiids(GGRVEPLH13Gboywp9bRp4aqCDGBldUEikFY0quuF8aX6nM8aTef1VKzormQkaLY2X6PKGRNaphictuuFWjSD2WufwnLGRpV6doHTZgMQmSAkbxpfucqeQkaLY2X6PKGRNaphictuuFWjSD2WurPAkbxFE1hCcBNnmvjLQPeC9uqjarOQaukBhRhGj46jWZbIWef1hCcBNnmvHvtj46ZR(Gty7SHPkdRMsW1tbLaeHQcqPSDSEaMGRNaphictuuFWjSD2WurPAkbxFE1hCcBNnmvjLQPeC9uqjarOQaukBhRNai46jWZbIWef1hmKXr6dsevtj46ZR(GHmosFqIOAkk0TnhfbxpfHbicvfGfGsb5n5vqeKbjFqW1xV0YW6BWahmRN(G1h86oU4M4bxpeLpzAikQpEGy9gtEGwII6xYmNigvfGsz7y9Hj46jWZbIWef1h86aIU5PAkk0TnhfbxFE1h86aIU5PAkbxpfHbicvfGsz7y9usW1tGNdeHjkQp41beDZt1uuOBBokcU(8Qp41beDZt1ucUEkcdqeQkaLY2X6jacUEc8CGimrr9KnibwFCUNgav)uv95vVuYy1lAGDSpV(lacT8G1tX0ewpfHbicvfGsz7y9eabxpbEoqeMOO(Gty7SHPkSAkbxFE1hCcBNnmvzy1ucUEkcdqeQkaLY2X6jacUEc8CGimrr9bNW2zdtfLQPeC95vFWjSD2WuLuQMsW1tryaIqvbOu2owVuj46jWZbIWef1t2Gey9X5EAau9tv1Nx9sjJvVOb2X(86Vai0Ydwpftty9uegGiuvakLTJ1lvcUEc8CGimrr9bNW2zdtvy1ucU(8Qp4e2oByQYWQPeC9uegGiuvakLTJ1lvcUEc8CGimrr9bNW2zdtfLQPeC95vFWjSD2WuLuQMsW1tryaIqvbybOuqEtEfebzqYheC91lTmS(gmWbZ6Ppy9blqWZ7vW1dr5tMgII6JhiwVXKhOLOO(LmZjIrvbOu2owFykj46jWZbIWef1hmKXr6dsevtj46ZR(GHmosFqIOAkk0TnhfbxpfHbicvfGfGeKGboyII6LA92k7ZRN3XmQka1K8oMrT0As)GGgxlToOWAP1KOBBok0YPjxWoryBAY04ONkWde9KbuHUT5OO(z1VzOPvbGyadIcL4M41pR(SbX6PQ(WAsBL95AsGOtePz4diMq0sDQdIsT0As0TnhfA50KlyNiSnnjf1VzOPvm((yCXyjZUOIjq9Syvpqd22MJQjwNTtCqFWb4bIEYaw)S6POEQRpno6PIX3hJlglz2fvOBBokQNfR6PU(1DCXnXvni4XTSpFymqtbrtmVEcRNW6Nvpf1VKzqIySEj1tz9Syvpf1dTwmqGONkWdicIEQAVEQQpmaQFw9qRfdei6PYeIOQ96PQ(WaOEcRNqnPTY(CnjnYhqMOmDQdcG1sRjr32CuOLttUGDIW20K2kBG4aDeSXy9uvVaJnefJ0GeXmwplw1dTwmqGONktiIQ2RNQ6byaOjTv2NRjPr(yBqOre1PoicqlTMeDBZrHwon5c2jcBttc0GTT5OAZnboeMVqnPTY(CnPaTu2iobXa6uhKu1sRjr32CuOLttUGDIW20Kux)MHMw1GGh3Y(8HXanftanPTY(CnzdcECl7Zhgd00PoOqvlTMeDBZrHwon5c2jcBttsD9anyBBoQMyD2oXb9bhGhi6jdy9ZQNI6Tv2aXb6iyJX6PQEbgBikgPbjIzSEwSQhATyGarpvMqevTxpv1hga1tOM0wzFUMKi3AG4irWaym1PoOqrlTMeDBZrHwon5c2jcBttUoxW0PkIqOLOyqKBnquHUT5OO(z1VUJlUjUcNJJnAGkicAThRp01hQ1pREQRFZqtRaX0apyazxSJkMa1pREQRxGBgAAfcqbUikgtogxOycOjTv2NRjtzWBYGi3AGOo1bjfRLwtIUT5OqlNMCb7eHTPjPUEGgSTnhvtSoBN4G(GdWde9KbS(z1tr92kBG4aDeSXy9uvVaJnefJ0GeXmwplw1dTwmqGONktiIQ2RNQ6dl16Nvpf1tD9anyBBoQyI4aNJJnAGdAg48X6CrN951ZIv9XaiNpsdseZy9uvF46zXQEAg486dD9HcaQNW6jutARSpxtIZXXgnqDQdAQwlTMeDBZrHwon5c2jcBttc0GTT5OAZnboeMVqnPTY(Cn5MBcCimFH6uhuyaOLwtIUT5OqlNMCb7eHTPjPzGZvcKUxDwpvsQNaaGM0wzFUMKg5BUjqDQdkCyT0AsBL95AsmgrFHJnen20KOBBok0YPtDqHPulTMeDBZrHwon5c2jcBttsr9PXrpvce88XMBcmQq32Cuuplw1tD9anyBBoQMyD2oXb9bhGhi6jdy9SyvpndCUsG09QZ6dD9amaQNfR63m00kqmnWdgq2f7OcIGw7X6dD9sTEcRFw9uxpqd22MJQa3XBN4G(GJn3e4qy(c1K2k7Z1KM7TSMBzFUo1bfgG1sRjr32CuOLttUGDIW20KuuFAC0tLabpFS5MaJk0Tnhf1ZIv9uxpqd22MJQjwNTtCqFWb4bIEYawplw1tZaNReiDV6S(qxpadG6jS(z1tD9anyBBoQcChVDId6doaX0QFw9uxpqd22MJQa3XBN4G(GJn3e4qy(c1K2k7Z1Klz2fhXe2SH6uhuycqlTMeDBZrHwon5c2jcBttMgh9uT5Tlg0mW5k0Tnhf1pREO1Ibce9uzcru1E9uvVTY(8X6oU4M4AsBL95AsCoo2ObQtDqHLQwAnj62MJcTCAsBL95AsbcEECS7e1KlyNiSnnjKXr6dsevBgO3oXXKJXfk0Tnhf1pREbUzOPvBgO3oXXKJXfkicAThRp01taAY18fhhPbjIzuhuyDQdkCOQLwtARSpxtkqWZJJDNOMeDBZrHwoDQdkCOOLwtIUT5OqlNMCb7eHTPjPU(04ONkWde9KbuHUT5OO(z1dTwmqGONkWdicIEQAVEQQFjZGeXy9sr1hga1pR(04ONkbcE(yZnbgvOBBok0K2k7Z1K0iFazIY0PoOWsXAP1KOBBok0YPjxWoryBAsWdicIEQeDmnFH1tv9HLA9Syv)MHMwDm54OhqZjIkMaAsBL95AsAKV5Ma1PoOWt1AP1KOBBok0YPjxWoryBAsWdicIEQeDmnFH1tv9HLA9Syvpf1VzOPvhtoo6b0CIOIjq9ZQN66tJJEQapq0tgqf62MJI6jutARSpxtsJ8bKjktN6GOeaAP1KOBBok0YPjxWoryBAsWdicIEQeDmnFH1tv9HLQM0wzFUMei6erAg(aIjeTuN6GOmSwAnj62MJcTCAYfSte2MMmno6PsGGNp2CtGrf62MJcnPTY(CnzkdEtge5wde1Po1KcK2y4PwADqH1sRjTv2NRjfDeYei1KOBBok0YPtDquQLwtARSpxtUopYaIdqJyV0KOBBok0YPtDqaSwAnj62MJcTCAYlGMmIPM0wzFUMeObBBZrnjqdoCde1KBUjWHW8fQjxWoryBAsQRhY4i9bjIQLm7IJugEW5k0Tnhf1pREQRhY4i9bjIkHbzJi3G4aefgN3NRq32CuOjfyCb7azFUMuk0PSJjRNaLzxSEPLHhCE9hSE5XGSrKBqK96LJBcSE5X8fw)KoLv)uVHXSE543jQ)G1Bz9aCi1tbLHu)KoLvV0qR51F01lVyANW6tdseZOMeOXzqnzAC0tfDdJ5yZVtOq32Cuuplw1hdGC(inirmJQn3e4qy(cdxpvsQNI6b46jO1Ngh9uLqR5JJEazAxHUT5OOEc1PoicqlTMeDBZrHwon5fqtgXutARSpxtc0GTT5OMeObhUbIAYn3e4qy(c1KlyNiSnnjKXr6dsevlz2fhPm8GZvOBBok0KcmUGDGSpxtkf6uw9eOm7I1lTm8GZzVE54MaRxEmFH1prg61NYW63m0013X6f3eN96N0PS6N6nmM1lh)or9wwpLHupfHdP(jDkREPHwZR)ORxEX0oH1FW6N0PS6LVXi6lSE5GOXw9wwpbes9uaWHu)KoLvV0qR51F01lVyANW6tdseZOMeOXzqn5MHMwTKzxCKYWdoxjUjE9SyvFAC0tfDdJ5yZVtOq32Cuu)S6JbqoFKgKiMr1MBcCimFHHRNkj1tr9uwpbT(04ONQeAnFC0dit7k0Tnhf1ty9Syvp11Ngh9uTMV444OhYSeIcf62MJI6NvFmaY5J0GeXmQ2CtGdH5lmC9ujPEkQNaQNGwFAC0tvcTMpo6bKPDf62MJI6juN6GKQwAnj62MJcTCAYlGMmIPM0wzFUMeObBBZrnjqdoCde1KBUjWHW8fQjxWoryBAsiJJ0hKiQegKnICdIdquyCEFUcDBZrHMuGXfSdK95AsPqNYQxEmiBe5gezVE54MaRxEmFH1Bz9(bbnE9PbjIz9RJXZ6Nid963m00OO(986T6J46CHbNxpstJRK96py9gFInpwVL1tashs90hSE)CcQ8GGN3lnjqJZGAY04ONk6ggZXMFNqHUT5OOEwSQNI63m00kqmnWdgq2f7OIjq9SyvFAC0tvcTMpo6bKPDf62MJI6zXQEbUzOPvymI(chBiASPycupH1pR(yaKZhPbjIzuT5MahcZxy46Pss9uupaxpbT(04ONQeAnFC0dit7k0Tnhf1ty9Syvp11Ngh9ujqWZ7LcDBZrr9ZQpga58rAqIygvBUjWHW8fgUEQKupbOtDqHQwAnj62MJcTCAYlGMeIrm1K2k7Z1KanyBBoQjbAWHBGOMCZnboeMVqn5c2jcBttMgh9uHXi6lCSHOXMcDBZrr9ZQFDhxCtCfgJOVWXgIgBkiAI5AsbgxWoq2NRjNAJy9Y3ye9fwVCq0yR(nsFqSE54MaRxEmFH13013z9DSEdO1CBZX6nxu)rtx)6oU4M46uhuOOLwtIUT5OqlNM8cOjJyQjTv2NRjbAW22Cutc04mOMK66tJJEQei459sHUT5OO(z1VUJlUjUcetd8GbKDXoQGiO1ES(qxFOw)S6PzGZvcKUxDwpv1dWaqtc0Gd3arnzG74TtCqFWbiMMo1bjfRLwtIUT5OqlNM8cOjJyQjTv2NRjbAW22Cutc04mOMeObBBZr1MBcCimFH1pREkQNMboV(qxFOi16jO1Ngh9ur3Wyo287ek0Tnhf1lfvpLaOEc1Kan4Wnqutg4oE7eh0hCS5MahcZxOo1bnvRLwtIUT5OqlNM8cOjJyQjTv2NRjbAW22Cutc04mOMmno6PsGGN3lf62MJI6Nvp11Ngh9uT5Tlg0mW5k0Tnhf1pR(1DCXnXv4CCSrdubrqR9y9HUEkQN4sOanaQEPO6PSEcRFw90mW5kbs3RoRNQ6PeaAsGgC4giQjdChVDId6doW54yJgOo1bfgaAP1KOBBok0YPjVaAYiMAsBL95AsGgSTnh1KanodQjtJJEQapq0tgqf62MJI6Nvp11VzOPvGhi6jdOIjGMeObhUbIAYjwNTtCqFWb4bIEYaQtDqHdRLwtIUT5OqlNM0wzFUMCzC(WwzF(G3XutY7yoCde1KR74IBIRtDqHPulTMeDBZrHwon5c2jcBttUzOPv0iFSpWTbfGONQyAl2Qxs9sT(z1tr9BgAAvdcECl7Zhgd0umbQNfR6PU(ndnTcetd8GbKDXoQycupHAsBL95AYug8MmiYTgiQtDqHbyT0As0TnhfA50KlyNiSnnzAC0tLabpVxk0TnhfAYyc7vQdkSM0wzFUMeY4dBL95dEhtnjVJ5WnqutkqWZ7Lo1bfMa0sRjr32CuOLttARSpxtcz8HTY(8bVJPMK3XC4giQj9dcACDQtnPabpVxAP1bfwlTMeDBZrHwon5c2jcBttMgh9uX47JXfJLm7Ik0Tnhf1pR(ndnTIX3hJlglz2fvmbQFw9uu)sMbjIX6LupL1ZIv9uup0AXabIEQapGii6PQ96PQ(WaO(z1dTwmqGONktiIQ2RNQ6ddG6jSEc1K2k7Z1K0iFazIY0Poik1sRjr32CuOLttUGDIW20KanyBBoQ2CtGdH5lutARSpxtkqlLnItqmGo1bbWAP1KOBBok0YPjxWoryBAsBLnqCGoc2ySEQQxGXgIIrAqIygRNfR6Hwlgiq0tLjerv71tv9HbGM0wzFUMKi3AG4irWaym1PoicqlTMeDBZrHwon5c2jcBttUoxW0PkIqOLOyqKBnquHUT5OO(z1VUJlUjUcNJJnAGkicAThRp01hQ1pREQRFZqtRaX0apyazxSJkMa1pREQRxGBgAAfcqbUikgtogxOycOjTv2NRjtzWBYGi3AGOo1bjvT0As0TnhfA50KlyNiSnnPTYgioqhbBmwpv1lWydrXinirmJ1ZIv9qRfdei6PYeIOQ96PQEkLA9ZQNI6PUEGgSTnhvmrCGZXXgnWbndC(yDUOZ(86zXQ(yaKZhPbjIzSEQQpC9SyvpndCE9HU(qba1tOM0wzFUMeNJJnAG6uhuOQLwtIUT5OqlNMCb7eHTPjbAW22CuT5MahcZxy9ZQN66x3Xf3exbIPbEWaYUyhvq0eZRFw9uu)6oU4M4kCoo2ObQGiO1ESEQQxQ1ZIv9uup0AXabIEQmHiQAVEQQ3wzF(yDhxCt86Nvp0AXabIEQmHiQAV(qxpLsTEcRNqnPTY(Cn5MBcCimFH6uhuOOLwtIUT5OqlNMCb7eHTPjPU(ndnTQbbpUL95dJbAkMaAsBL95AYge84w2NpmgOPtDqsXAP1KOBBok0YPjxWoryBAsQRhObBBZrvG74TtCqFWXMBcCimFHAsBL95AsZ9wwZTSpxN6GMQ1sRjr32CuOLttUGDIW20K0mW5kbs3RoRNkj1taaqtARSpxtsJ8n3eOo1bfgaAP1K2k7Z1KymI(chBiASPjr32CuOLtN6GchwlTMeDBZrHwon5c2jcBttsD9anyBBoQcChVDId6do2CtGdH5lS(z1tD9anyBBoQcChVDId6doW54yJgOM0wzFUMCjZU4iMWMnuN6GctPwAnj62MJcTCAsBL95AsbcEECS7e1KlyNiSnnjKXr6dsevBgO3oXXKJXfk0Tnhf1pREbUzOPvBgO3oXXKJXfkicAThRp01taAY18fhhPbjIzuhuyDQdkmaRLwtIUT5OqlNMCb7eHTPjPU(04ONkbcE(yZnbgvOBBokQFw9XaiNpsdseZy9uvF46Nvpf1VKzqIySEj1tz9Syvpf1dTwmqGONkWdicIEQAVEQQpmaQFw9qRfdei6PYeIOQ96PQ(WaOEcRNqnPTY(CnjnYhqMOmDQdkmbOLwtARSpxtkqWZJJDNOMeDBZrHwoDQdkSu1sRjr32CuOLttUGDIW20KBgAA1XKJJEanNiQycOjTv2NRjtzWBYGi3AGOo1bfou1sRjr32CuOLttUGDIW20KGhqee9uj6yA(cRNQ6dl16zXQ(ndnT6yYXrpGMtevmb0K2k7Z1K0iFazIY0PoOWHIwAnj62MJcTCAYfSte2MMe8aIGONkrhtZxy9uvFyPQjTv2NRjbIorKMHpGycrl1PoOWsXAP1KOBBok0YPjxWoryBAY04ONkbcE(yZnbgvOBBok0K2k7Z1KPm4nzqKBnquN6utUUJlUjUwADqH1sRjr32CuOLttUGDIW20KuxFAC0tLabpVxk0Tnhf1pR(1DCXnXv4CCSrdubrqR9y9uvpLaO(z1tr9ux)6aIU5Pci6PS5W6zXQEQRxCPk2ondFSHMluzVyRDI1ty9SyvpDtuwoGiO1ES(qxpLsvtARSpxtcIPbEWaYUyh1Poik1sRjr32CuOLttUGDIW20KPXrpvce88EPq32Cuu)S6PO(1DCXnXv4CCSrdubrqR9y9uvpLaO(z1tr9uxpqd22MJQn3e4qy(cRNfR6x3Xf3exT5MahcZxOcIGw7X6PQEIlHc0aO6jSEcRFw9uup11VoGOBEQaIEkBoSEwSQN66fxQITtZWhBO5cv2l2ANy9ewplw1t3eLLdicAThRp01tPu1K2k7Z1KGyAGhmGSl2rDQdcG1sRjr32CuOLttUGDIW20KBgAAfiMg4bdi7IDubrqR9y9uvpLsTEwSQFFXy9ZQNUjklhqe0ApwFORpubGM0wzFUMmWL956uhebOLwtIUT5OqlNMuGXfSdK95As5bPngEwpteRVteSE(rSxAYfSte2MMeObBBZrvcBNnmhX5(Ae5xwVK6dx)S6PO(ndnTcetd8GbKDXoQycuplw1tr9uxFAC0tLabpVxk0Tnhf1pR(1DCXnXvGyAGhmGSl2rfebT2J1tv9uupDtuwoGiO1ESEQMAQpHTZgMQmSADhxCtCLGbAzFE9txpL1ty9ewplw1t3eLLdicAThRp0sQNsaupH1ZIv9uupqd22MJQe2oByoIZ91iYVSEj1tz9ZQN66ty7SHPkPuTUJlUjUcIMyE9ewplw1tD9anyBBoQsy7SH5io3xJi)snzKFzutMW2zdZWAsBL95AsMio6ebJ6uhKu1sRjr32CuOLttARSpxtYeXrNiyutUGDIW20KanyBBoQsy7SH5io3xJi)Y6LupL1pREkQFZqtRaX0apyazxSJkMa1ZIv9uup11Ngh9ujqWZ7LcDBZrr9ZQFDhxCtCfiMg4bdi7IDubrqR9y9uvpf1t3eLLdicAThRNQPM6ty7SHPkPuTUJlUjUsWaTSpV(PRNY6jSEcRNfR6PBIYYbebT2J1hAj1tjaQNW6zXQEkQhObBBZrvcBNnmhX5(Ae5xwVK6dx)S6PU(e2oByQYWQ1DCXnXvq0eZRNW6zXQEQRhObBBZrvcBNnmhX5(Ae5xQjJ8lJAYe2oBysPo1bfQAP1KOBBok0YPjxWoryBAsQRxCPk2ondFSHMluzVyRDIAsBL95AYy70m8XgAUqN6GcfT0As0TnhfA50KlyNiSnnj11Ngh9ujqWZ7LcDBZrr9ZQN66bAW22CunX6SDId6doapq0tgW6Nvp11d0GTT5OkWD82joOp4aetREwSQFZqtROzG9XeheTPIOIjGM0wzFUMmLHdzmEQtDqsXAP1KOBBok0YPjxWoryBAskQ3wzdehOJGngRNQ6fySHOyKgKiMX6zXQEO1Ibce9uzcru1E9uvpadG6jutARSpxtI85X28Haxqe1Po1KbG46a3wQLwhuyT0AsBL95AY9LjhfdAUnhftAN4ipaQDnj62MJcTC6uheLAP1KOBBok0YPjVaAYiMAsBL95AsGgSTnh1KanodQjdRjxWoryBAYe2oByQYWkzwCWeXXMHMU(z1tr9uxFcBNnmvjLkzwCWeXXMHMUEwSQpHTZgMQmSADhxCtCLGbAzFE9ujP(e2oByQskvR74IBIRemql7ZRNqnjqdoCde1KjSD2WCeN7RrKFPo1bbWAP1KOBBok0YPjVaAYiMAsBL95AsGgSTnh1KanodQjPutUGDIW20KjSD2WuLuQKzXbtehBgA66Nvpf1tD9jSD2WuLHvYS4GjIJndnD9SyvFcBNnmvjLQ1DCXnXvcgOL951tv9jSD2WuLHvR74IBIRemql7ZRNqnjqdoCde1KjSD2WCeN7RrKFPo1braAP1KOBBok0YPjVaAYiMAsBL95AsGgSTnh1KanodQjtJJEQ282fdAg4Cf62MJI6Nvpf1dzCK(GerLWGSrKBqCaIcJZ7ZvOBBokQNfR6tJJEQei45Jn3eyuHUT5OOEc1KcmUGDGSpxto1gX6LVZX6LdnW6TSE(nP(PodCE9t6uw9YXBxu)uNboV(1bUBhf1pPtz1JDkdH1lpgKnICdI1FW6Lhe886LJBcmQjbAWHBGOMKjIdCoo2OboOzGZhRZfD2NRtDQtnPXKYoOMKSbjqDQtTg]] )


end
