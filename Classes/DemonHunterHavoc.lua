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
                    debuff.sinful.brand.expires = debuff.sinful_brand.expires + 0.75
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


    spec:RegisterPack( "Havoc", 20210916, [[da1uvbqiuslsqk1JqjYLaqHnjL8jbQrHGofsyvcOWReeZcLQBHayxK8layysP6ycQLriEMukMgcORjGSneG(MGunoeO4CaOQ1HsW8eKCpcAFOu(hak1bfqvTqb4HiqMikrDrbPyJaOYhfqvgPaQ0jrGsReGMjkHUjakANcKFkGImubPKwQak9uKAQesxfaL8veOASai7Lu)vQgSQomLfRspwftgvxgAZi6Zi0OjWPvSAbPeVgjA2eDBG2nv)wPHtOoUaQy5GEUqtx01rX2b03LIgVukDEPW6fqrnFK0(LSoSwunn3suhKiTls42b4dtavHd9arGHjqnD2qmQPfBhknIOM2nquth4Aa3JMwS1qUgxlQMoUmWdQPPhqgPLZ6ee0itn9LzKjbRRVAAULOoirAxKWTdWhMaQch6bIaBNGrthfJhDqbk0dDnTGHZrxF10CmE00SmcUE9bUmEIW6dCnG7PaKgfNi4fH13g2RxK2fjCbybibjWCIyKfkaja1dWetdCHIfSXjwV586dTU5SE9mrJiwFO9fjxiwp5quqwp68yOD9YL4CQ34HwyIjYRp36nXILnQFDzJ6ZT(7gJ1toefKrvbibOEwC3i61ZiU(yd)moX6xY6byIPbUqXc24eRNqWXRFjRNCikiRhIG24X6bgv1NWXPeZ6jiwUEOLcqy9PaZRh0AlfknTy4sosutZsSu9SmcUE9bUmEIW6dCnG7PaKLyP6PrXjcEry9TH96fPDrcxawaYsSu9eKaZjIrwOaKLyP6ja1dWetdCHIfSXjwV586dTU5SE9mrJiwFO9fjxiwp5quqwp68yOD9YL4CQ34HwyIjYRp36nXILnQFDzJ6ZT(7gJ1toefKrvbilXs1taQNf3nIE9mIRp2WpJtS(LSEaMyAGluSGnoX6jeC86xY6jhIcY6HiOnESEGrv9jCCkXSEcILRhAPaewFkW86bT2sHQaSa0o5SEujgINf8APW7MPe5DsP1a5nhNyp32oEbODYz9Osmepl41YqecaGgCSRez3nquychNsm7Xg(PhLBYoqtYGcdZ(qkmHJtjMQWkbwSZeX(LHKSfHSMWXPetLikbwSZeX(LHKKk1eooLyQcRo7k5BtxXzGwoRZMWeooLyQerD2vY3MUIZaTCwNIcq7KZ6rLyiEwWRLHieaan4yxjYUBGOWeooLy2Jn8tpk3KDGMKbfkc7dPWeooLyQerjWIDMi2VmKKTiK1eooLyQcReyXote7xgssQut44uIPse1zxjFB6kod0YzD2s44uIPkS6SRKVnDfNbA5SoffGSu9aSIy9HMgy9bGgy9wwVCBwpahdSr9nNuq9bihNxpahdSr9Nf8ooYRV5KcQhNuacRNLniLeLgeRFH1ZYi461hG04ySa0o5SEujgINf8Azicbaqdo2vIS7gikKjIDSb2VOb2jzGn6N15toRZoqtYGcttIEQUYX5Dsgydf62vI8weczCKCHerf3GusuAqSdICtkN1Psnnj6PIJGR3VsJJrf62vICkkalalazjwQ(qtBXdtI86rGiSr95aI1NcW6TtUW6Ny9gqBK2vIQcq7KZ6rH8jczeNfG2jN1JHieaN1JmGyh0ioNcqwILQNGJ1Zxp4SE(wFkyI1NgKiM1hBAIfpoX6ZTEtSyzJ6dGb6JtSEc(Y48cqwILQ3o5SEmeHaaIPbjIz3yYTBzAhkzxoo2pCHHzpnirm7dPqWXzboEzijvxgOpoXEZLX5kicAJhzFifczCKCHer1Lb6JtS3CzCER0KONkocUE)knogvOBxjYlazP6j4tkyzY6jib2gRxub4cBu)cRNLniLeLgezV(aKghRNLn)G13Csb1dWnWywFaYD51VW6TS(2es9eksi13Csb1lk0gz9lz9bwMXPO(0GeXmwaANCwpgIqaa0GJDLi7UbIcVsJJDU5hK9HuiRqghjxiruDeyBSNcWf2OfRqghjxiruXniLeLge7Gi3KYzD2bAsguyAs0tf5aJz)k3LRq3UsKtLAumkL90GeXmQUsJJDU5hmmBcjSneG0KONQeAJSVKDiZ4k0TRe5uuaYs1tWNuq9eKaBJ1lQaCHnyV(aKghRNLn)G13ua61NcW6VmKK1pX65BtN96BoPG6b4gymRpa5U86TSErcPEcdhs9nNuq9IcTrw)swFGLzCkQFH13Csb1hAIr0py9barJY6TSEcmK6jSnHuFZjfuVOqBK1VK1hyzgNI6tdseZybODYz9yicbaqdo2vIS7gik8kno25MFq2hsHqghjxiruDeyBSNcWf2GDGMKbfEzijvhb2g7PaCHnu8TPtLAAs0tf5aJz)k3LRq3UsK3kkgLYEAqIygvxPXXo38dgMnHekcbinj6PkH2i7lzhYmUcD7krofuPYAAs0t1PXrI9LSlWsiYvOBxjYBffJszpnirmJQR04yNB(bdZMqcjqcqAs0tvcTr2xYoKzCf62vICkkazP6j4tkOEw2GusuAqK96dqACSEw28dwVL17le0K1NgKiM1FwgpRVPa0R)YqsI86VnQ3QpIN15gSr9ijjEs2RFH1BYMwJy9wwpbkAi1tUW691jaSmcU(CkaTtoRhdriaaAWXUsKD3arHxPXXo38dY(qkeY4i5cjIkUbPKO0Gyhe5MuoRZoqtYGcttIEQihym7x5UCf62vICQuj8YqsQaX0axOybBCIkgXuPMMe9uLqBK9LSdzgxHUDLiNkvoEzijvymI(b7xiAuQyetrROyuk7PbjIzuDLgh7CZpyy2esyBiaPjrpvj0gzFj7qMXvOBxjYPGkvwttIEQ4i46ZrHUDLiVvumkL90GeXmQUsJJDU5hmmBcjWcqwQEawrS(qtmI(bRpaiAuw)fjxiwFasJJ1ZYMFW6hY6NS(jwVb0gPDLy9MZRFjjR)SRKVn9cq7KZ6XqecaGgCSRez3nqu4vACSZn)GSVIfcXiMSpKcttIEQWye9d2Vq0OuHUDLiV1zxjFB6kmgr)G9lenkvq04nkaTtoRhdriaaAWXUsKD3arHI3vooXo5c7GyASd0KmOqwttIEQ4i46ZrHUDLiV1zxjFB6kqmnWfkwWgNOcIG24XqraBrYaBO4i5CMKT20EbODYz9yicbaqdo2vIS7giku8UYXj2jxy)kno25MFq2bAsguiqdo2vIQR04yNB(bBrijdSrOc9arastIEQihym7x5UCf62vI8adrANIcq7KZ6XqecaGgCSRez3nquO4DLJtStUWo2a7x0azhOjzqHPjrpvCeC95Oq3UsK3I10KONQRCCENKb2qHUDLiV1zxjFB6kSb2VObQGiOnEmues8WvGwBdmeHIwKmWgkosoNjztK2laTtoRhdriaaAWXUsKD3arHnTjhNyNCHDWfe9KbKDGMKbfMMe9ubUGONmGk0TRe5Ty9YqsQaxq0tgqfJ4cq7KZ6XqecGJjLD7KZ6D5et2DdefE2vY3MEbilXs1BNCwpgIqaiEou2ze3jHgrq0t2ZgIrHCeCD2hsHCeC9ECzKDsOree9mYw7fGSelvVDYz9yicbG45qzNrCNeAebrpzhC5Oqhnigt2hsHeMMe9uXrW1Nt3elgZjrf62vI8wKmWgkosoNjztyBcevQqghjxiruDLJZ7K2KcADzijvx548oPnPafJykAriRNDL8TPRWgy)IgOcIgVbvQKmWgHQnTtrbODYz9yicbqkaUn7eL2aezFifEzijvKOSFxWRb5GONQyAhkfgOweEzijvdi4kTCwVBmqtXiMkvwVmKKkqmnWfkwWgNOIrmffG2jN1JHieaqgVBNCwVlNyYUBGOqocU(CypMW5KcdZ(qkmnj6PIJGRphf62vI8cq7KZ6XqecaiJ3TtoR3Ltmz3nquOVqqtwawaANCwpQo7k5BtxiiMg4cflyJtK9HuiRPjrpvCeC95Oq3UsK36SRKVnDf2a7x0avqe0gpYMiT3Iqwplq0npvarpf0aQq3UsKtLkR8nvXXjzK9l0CUkNdLJtKcQujhIcYoebTXJHsKavaANCwpQo7k5BtpeHaaetdCHIfSXjY(qkmnj6PIJGRphf62vI8weE2vY3MUcBG9lAGkicAJhztK2BriRan4yxjQUsJJDU5hKk1ZUs(20vxPXXo38dQGiOnEKnIhUc0Alfu0Iqwplq0npvarpf0aQq3UsKtLkR8nvXXjzK9l0CUkNdLJtKcQujhIcYoebTXJHsKavaANCwpQo7k5BtpeHaq8MZ6SpKcVmKKkqmnWfkwWgNOcIG24r2ejquPE3ySf5quq2HiOnEmueW2lazP6zzK0yKz9mrS(jrW6LlX5uaANCwpQo7k5BtpeHaGjI9jrWi7r5MrHjCCkXmm7dPqGgCSRevjCCkXShB4NEuUPWWTi8YqsQaX0axOybBCIkgXuPsiRPjrpvCeC95Oq3UsK36SRKVnDfiMg4cflyJtubrqB8iBesoefKDicAJhdfa7eooLyQcRo7k5BtxXzGwoRdWqekOGkvYHOGSdrqB8yOeks7uqLkHan4yxjQs44uIzp2Wp9OCtHI0I1eooLyQerD2vY3MUcIgVbfuPYkqdo2vIQeooLy2Jn8tpk3Sa0o5SEuD2vY3MEicbate7tIGr2JYnJct44uIPiSpKcbAWXUsuLWXPeZESHF6r5McfPfHxgssfiMg4cflyJtuXiMkvcznnj6PIJGRphf62vI8wNDL8TPRaX0axOybBCIkicAJhzJqYHOGSdrqB8yOayNWXPetLiQZUs(20vCgOLZ6ameHckOsLCiki7qe0gpgkHI0ofuPsiqdo2vIQeooLy2Jn8tpk3uy4wSMWXPetvy1zxjFB6kiA8guqLkRan4yxjQs44uIzp2Wp9OCZcq7KZ6r1zxjFB6HieaXXjzK9l0Co7dPqw5BQIJtYi7xO5CvohkhNybODYz9O6SRKVn9qecGua2fW4j7dPqwttIEQ4i46ZrHUDLiVfRan4yxjQAAtooXo5c7Gli6jdylwbAWXUsujEx54e7KlSdIPrL6LHKurYaNLj2jAbMrfJ4cq7KZ6r1zxjFB6HieaOSrCmVZXder2hsHeANCaID0rWbJSXX4arEpnirmJuPcTH3rGONkJZJQXzRnTtrbybODYz9OIJGRphHKOSdzIcyFifMMe9uX43LX59JaBJk0TRe5TUmKKkg)UmoVFeyBuXiUfHhbgKigfkcvQecTH3rGONkWficIEQgNTWT3cAdVJarpvgNhvJZw42PGIcq7KZ6rfhbxFoHieaC0sb9ytefZ(qkeObh7kr1vACSZn)GfG2jN1JkocU(CcriaikTbi2teumgt2hsH2jhGyhDeCWiBCmoqK3tdseZivQqB4Dei6PY48OAC2c3EbODYz9OIJGRpNqecGuaCB2jkTbiY(qk8SoNzsveHqlrENO0gGOcD7krERZUs(20vydSFrdubrqB8yOiGTy9YqsQaX0axOybBCIkgXTyLJxgssf2wXBe59MlJZvmIlaTtoRhvCeC95eIqaGnW(fnq2hsH2jhGyhDeCWiBCmoqK3tdseZivQqB4Dei6PY48OAC2ejqTiKvGgCSRevmrSJnW(fnWojdSr)SoFYzDQuJIrPSNgKiMr2ctLkjdSrOc92POa0o5SEuXrW1NticbWvACSZn)GSpKcbAWXUsuDLgh7CZpylwp7k5BtxbIPbUqXc24evq04nAr4zxjFB6kSb2VObQGiOnEKTarLkHqB4Dei6PY48OAC2o7k5BtVf0gEhbIEQmopQgpuIeikOOa0o5SEuXrW1NticbWacUslN17gd0yFifY6LHKunGGR0Yz9UXanfJ4cq7KZ6rfhbxFoHieaM7JGrA5So7dPqwbAWXUsujEx54e7KlSFLgh7CZpybODYz9OIJGRpNqecasuELghzFifsYaBO4i5CMKnHey7fG2jN1JkocU(CcriaWye9d2Vq0OSa0o5SEuXrW1NticbWrGTXEmHdLi7dPqwbAWXUsujEx54e7KlSFLgh7CZpylwbAWXUsujEx54e7KlSJnW(fnWcq7KZ6rfhbxFoHieaKOSdzIcyFifMMe9uXrW17xPXXOcD7krElwp7k5BtxHnW(fnqfenEJweEeyqIyuOiuPsi0gEhbIEQaxGii6PAC2c3ElOn8oce9uzCEunoBHBNckkaTtoRhvCeC95eIqaWrW1J97Ki7Nghj2tdseZOWWSpKcHmosUqIO6Ya9Xj2BUmoVfhVmKKQld0hNyV5Y4CfebTXJHIalaTtoRhvCeC95eIqaqIYoKjkG9HuiRPjrpvCeC9(vACmQq3UsK3kkgLYEAqIygzlClcpcmirmkueQujeAdVJarpvGlqee9unoBHBVf0gEhbIEQmopQgNTWTtbffG2jN1JkocU(Ccria4i46X(DsSa0o5SEuXrW1NticbqkaUn7eL2aezFifEzijvlt2xYo0CIOIrCbODYz9OIJGRpNqecasu2HmrbSpKcbxGii6PIpX08dYw4arL6LHKuTmzFj7qZjIkgXfG2jN1JkocU(CcriaaIorKKr2HycrlzFifcUarq0tfFIP5hKTWbQa0o5SEuXrW1NticbqkaUn7eL2aezFifMMe9uXrW17xPXXOcD7krEbybODYz9OYxiOjfceDIijJSdXeIwY(qkmnj6PcCbrpzavOBxjYBDzijvIHOydICfFB6TYbezlCbODYz9OYxiOjdriairzhYefW(qkKWldjPIXVlJZ7hb2gvmIPsfObh7krvtBYXj2jxyhCbrpzaBriRPjrpvm(DzCE)iW2OcD7krovQSE2vY3MUAabxPLZ6DJbAkiA8guqrlcpcmirmkueQujeAdVJarpvGlqee9unoBHBVf0gEhbIEQmopQgNTWTtbffG2jN1JkFHGMmeHaGeL9RbHgrK9HuODYbi2rhbhmYghJde590GeXmsLk0gEhbIEQmopQgNT20EbODYz9OYxiOjdria4OLc6XMikM9Huiqdo2vIQR04yNB(blaTtoRhv(cbnzicbWacUslN17gd0yFifY6LHKunGGR0Yz9UXanfJ4cq7KZ6rLVqqtgIqaquAdqSNiOymMSpKczfObh7krvtBYXj2jxyhCbrpzaBrODYbi2rhbhmYghJde590GeXmsLk0gEhbIEQmopQgNTWTtrbODYz9OYxiOjdriasbWTzNO0gGi7dPWZ6CMjvrecTe5DIsBaIk0TRe5To7k5BtxHnW(fnqfebTXJHIa2I1ldjPcetdCHIfSXjQye3IvoEzijvyBfVrK3BUmoxXiUa0o5SEu5le0KHieaydSFrdK9HuiRan4yxjQAAtooXo5c7Gli6jdylcTtoaXo6i4Gr24yCGiVNgKiMrQuH2W7iq0tLX5r14SfoqTiKvGgCSRevmrSJnW(fnWojdSr)SoFYzDQuJIrPSNgKiMr2ctLkjdSrOc92PGIcq7KZ6rLVqqtgIqaCLgh7CZpi7dPqGgCSRevxPXXo38dwaANCwpQ8fcAYqecasuELghzFifsYaBO4i5CMKnHey7fG2jN1JkFHGMmeHaaJr0py)crJYcq7KZ6rLVqqtgIqayUpcgPLZ6SpKcjmnj6PIJGR3VsJJrf62vICQuzfObh7krvtBYXj2jxyhCbrpzaPsLKb2qXrY5mzOAt7uPEzijvGyAGluSGnorfebTXJHkqu0IvGgCSRevI3vooXo5c7xPXXo38dwaANCwpQ8fcAYqecGJaBJ9ychkr2hsHeMMe9uXrW17xPXXOcD7krovQSc0GJDLOQPn54e7KlSdUGONmGuPsYaBO4i5CMmuTPDkAXkqdo2vIkX7khNyNCHDqmTwSc0GJDLOs8UYXj2jxy)kno25MFWcq7KZ6rLVqqtgIqaGnW(fnq2hsHPjrpvx548ojdSHcD7krElOn8oce9uzCEunoBNDL8TPxaANCwpQ8fcAYqecaocUESFNez)04iXEAqIygfgM9HuiKXrYfsevxgOpoXEZLX5T44LHKuDzG(4e7nxgNRGiOnEmueybODYz9OYxiOjdria4i46X(DsSa0o5SEu5le0KHieaKOSdzIcyFifYAAs0tf4cIEYaQq3UsK3cAdVJarpvGlqee9unoBhbgKigdmc3ER0KONkocUE)knogvOBxjYlaTtoRhv(cbnzicbajkVsJJSpKcbxGii6PIpX08dYw4arL6LHKuTmzFj7qZjIkgXfG2jN1JkFHGMmeHaGeLDitua7dPqWficIEQ4tmn)GSfoquPs4LHKuTmzFj7qZjIkgXTynnj6PcCbrpzavOBxjYPOa0o5SEu5le0KHieaarNisYi7qmHOLSpKcbxGii6PIpX08dYw4avaANCwpQ8fcAYqecGuaCB2jkTbiY(qkmnj6PIJGR3VsJJrf62vICnnqegN11bjs7IeU9qxeaELiA6Mg0hNyuttWd8dSbrWguGhluF9IkaRFafVWSEYfwFW(cbnzW1dXahMbI86JliwVXKlOLiV(JaZjIrvbiloowF4aXc1tqRdeHjYRpyiJJKlKiQaOGRp36dgY4i5cjIkasHUDLip46jmCBPqvawasWd8dSbrWguGhluF9IkaRFafVWSEYfwFWCK0yKzW1dXahMbI86JliwVXKlOLiV(JaZjIrvbiloowFByH6jO1bIWe51hmKXrYfsevauW1NB9bdzCKCHerfaPq3UsKhC9egUTuOkazXXX6BdlupbToqeMiV(GHmosUqIOcGcU(CRpyiJJKlKiQaif62vI8GR3Y6dnbMyX6jmCBPqvaYIJJ1tGSq9e06aryI86dgY4i5cjIkak46ZT(GHmosUqIOcGuOBxjYdUElRp0eyIfRNWWTLcvbiloowFGyH6jO1bIWe51hmKXrYfsevauW1NB9bdzCKCHerfaPq3UsKhC9wwFOjWelwpHHBlfQcWcqcEGFGnic2Gc8yH6Rxuby9dO4fM1tUW6dwmepl41YGRhIbomde51hxqSEJjxqlrE9hbMteJQcqwCCSEryH6jO1bIWe51hCchNsmvHvauW1NB9bNWXPetvgwbqbxpHI0wkufGS44y9IWc1tqRdeHjYRp4eooLyQerbqbxFU1hCchNsmvPikak46juK2sHQaKfhhRVnSq9e06aryI86doHJtjMQWkak46ZT(Gt44uIPkdRaOGRNqrAlfQcqwCCS(2Wc1tqRdeHjYRp4eooLyQerbqbxFU1hCchNsmvPikak46juK2sHQaKfhhRNazH6jO1bIWe51hmKXrYfsevauW1NB9bdzCKCHerfaPq3UsKhC9egUTuOkalaj4b(b2GiydkWJfQVErfG1pGIxywp5cRp4ZUs(20dUEig4WmqKxFCbX6nMCbTe51FeyormQkazXXX6dZc1tqRdeHjYRp4ZceDZtfaPq3UsKhC95wFWNfi6MNkak46jmCBPqvaYIJJ1lclupbToqeMiV(Gplq0npvaKcD7krEW1NB9bFwGOBEQaOGRNWWTLcvbiloowpbYc1tqRdeHjYRNEajO6Jn80AB9amQp36zrgRE(aCIZ61VIrOLlSEcbaf1ty42sHQaKfhhRNazH6jO1bIWe51hCchNsmvHvauW1NB9bNWXPetvgwbqbxpHHBlfQcqwCCSEcKfQNGwhictKxFWjCCkXujIcGcU(CRp4eooLyQsruauW1ty42sHQaKfhhRpqSq9e06aryI86PhqcQ(ydpT2wpaJ6ZTEwKXQNpaN4SE9RyeA5cRNqaqr9egUTuOkazXXX6delupbToqeMiV(Gt44uIPkScGcU(CRp4eooLyQYWkak46jmCBPqvaYIJJ1hiwOEcADGimrE9bNWXPetLikak46ZT(Gt44uIPkfrbqbxpHHBlfQcWcqcEGFGnic2Gc8yH6Rxuby9dO4fM1tUW6dMJGRpNGRhIbomde51hxqSEJjxqlrE9hbMteJQcqwCCS(WTHfQNGwhictKxFWqghjxirubqbxFU1hmKXrYfsevaKcD7krEW1ty42sHQaSaKGfu8ctKxFGQ3o5SE9YjMrvbOM2ysbluttpGeKMwoXmQfvt7le0KAr1bfwlQMgD7krUoan9bojchttNMe9ubUGONmGk0TRe513Q(ldjPsmefBqKR4BtV(w1NdiwpB1hwtBNCwxtdeDIijJSdXeIwQtDqIOfvtJUDLixhGM(aNeHJPPjS(ldjPIXVlJZ7hb2gvmIRNk16bAWXUsu10MCCIDYf2bxq0tgW6BvpH1ZA9Pjrpvm(DzCE)iW2OcD7krE9uPwpR1F2vY3MUAabxPLZ6DJbAkiA8g1tr9uuFR6jS(JadseJ1lSErQNk16jSEOn8oce9ubUarq0t141Zw9HBV(w1dTH3rGONkJZJQXRNT6d3E9uupfAA7KZ6AAsu2Hmrb6uhuB0IQPr3UsKRdqtFGtIWX002jhGyhDeCWy9SvphJde590GeXmwpvQ1dTH3rGONkJZJQXRNT6Bt7AA7KZ6AAsu2VgeAerDQdIa1IQPr3UsKRdqtFGtIWX00an4yxjQUsJJDU5hutBNCwxtZrlf0JnruSo1bfiTOAA0TRe56a00h4KiCmnnR1Fzijvdi4kTCwVBmqtXiwtBNCwxtpGGR0Yz9UXanDQdIaQfvtJUDLixhGM(aNeHJPPzTEGgCSRevnTjhNyNCHDWfe9KbS(w1ty92jhGyhDeCWy9SvphJde590GeXmwpvQ1dTH3rGONkJZJQXRNT6d3E9uOPTtoRRPjkTbi2teumgtDQdk01IQPr3UsKRdqtFGtIWX00N15mtQIieAjY7eL2aevOBxjYRVv9NDL8TPRWgy)IgOcIG24X6dv9eW6BvpR1FzijvGyAGluSGnorfJ46BvpR1ZXldjPcBR4nI8EZLX5kgXAA7KZ6A6uaCB2jkTbiQtDqemAr10OBxjY1bOPpWjr4yAAwRhObh7krvtBYXj2jxyhCbrpzaRVv9ewVDYbi2rhbhmwpB1ZX4arEpnirmJ1tLA9qB4Dei6PY48OA86zR(WbQ(w1ty9Swpqdo2vIkMi2Xgy)IgyNKb2OFwNp5SE9uPwFumkL90GeXmwpB1hUEQuRNKb2O(qvFO3E9uupfAA7KZ6AASb2VObQtDqa8Ar10OBxjY1bOPpWjr4yAAGgCSRevxPXXo38dQPTtoRRPVsJJDU5huN6Gc3Uwunn62vICDaA6dCseoMMMKb2qXrY5mz9SjSEcSDnTDYzDnnjkVsJJ6uhu4WAr102jN110ymI(b7xiAuQPr3UsKRdqN6GclIwunn62vICDaA6dCseoMMMW6ttIEQ4i469R04yuHUDLiVEQuRN16bAWXUsu10MCCIDYf2bxq0tgW6PsTEsgydfhjNZK1hQ6Bt71tLA9xgssfiMg4cflyJtubrqB8y9HQ(avpf13QEwRhObh7krL4DLJtStUW(vACSZn)GAA7KZ6AAZ9rWiTCwxN6Gc3gTOAA0TRe56a00h4KiCmnnH1NMe9uXrW17xPXXOcD7krE9uPwpR1d0GJDLOQPn54e7KlSdUGONmG1tLA9KmWgkosoNjRpu13M2RNI6BvpR1d0GJDLOs8UYXj2jxyhetR(w1ZA9an4yxjQeVRCCIDYf2VsJJDU5hutBNCwxtFeyBSht4qjQtDqHjqTOAA0TRe56a00h4KiCmnDAs0t1vooVtYaBOq3UsKxFR6H2W7iq0tLX5r141Zw92jN17NDL8TPRPTtoRRPXgy)IgOo1bfoqAr10OBxjY1bOPTtoRRP5i46X(DsutFGtIWX00qghjxiruDzG(4e7nxgNRq3UsKxFR654LHKuDzG(4e7nxgNRGiOnES(qvpbQPpnosSNgKiMrDqH1PoOWeqTOAA7KZ6AAocUESFNe10OBxjY1bOtDqHdDTOAA0TRe56a00h4KiCmnnR1NMe9ubUGONmGk0TRe513QEOn8oce9ubUarq0t141Zw9hbgKigRpWO(WTxFR6ttIEQ4i469R04yuHUDLixtBNCwxttIYoKjkqN6GctWOfvtJUDLixhGM(aNeHJPPbxGii6PIpX08dwpB1hoq1tLA9xgss1YK9LSdnNiQyeRPTtoRRPjr5vACuN6GcdWRfvtJUDLixhGM(aNeHJPPbxGii6PIpX08dwpB1hoq1tLA9ew)LHKuTmzFj7qZjIkgX13QEwRpnj6PcCbrpzavOBxjYRNcnTDYzDnnjk7qMOaDQdsK21IQPr3UsKRdqtFGtIWX00Glqee9uXNyA(bRNT6dhinTDYzDnnq0jIKmYoetiAPo1bjsyTOAA0TRe56a00h4KiCmnDAs0tfhbxVFLghJk0TRe5AA7KZ6A6uaCB2jkTbiQtDQP5iPXitTO6GcRfvtBNCwxtZNiKrCQPr3UsKRdqN6GerlQM2o5SUM(SEKbe7GgX5OPr3UsKRdqN6GAJwunn62vICDaA6vSMoIPM2o5SUMgObh7krnnqd2Dde10xPXXo38dQPpWjr4yAAwRhY4i5cjIQJaBJ9uaUWgk0TRe513QEwRhY4i5cjIkUbPKO0Gyhe5MuoRRq3UsKRP5y8ahX5SUMMGpPGLjRNGeyBSErfGlSr9lSEw2GusuAqK96dqACSEw28dwFZjfupa3aJz9bi3Lx)cR3Y6Bti1tOiHuFZjfuVOqBK1VK1hyzgNI6tdseZOMgOjzqnDAs0tf5aJz)k3LRq3UsKxpvQ1hfJszpnirmJQR04yNB(bdxpBcRNW6Bt9eG6ttIEQsOnY(s2HmJRq3UsKxpf6uhebQfvtJUDLixhGMEfRPJyQPTtoRRPbAWXUsutd0GD3arn9vACSZn)GA6dCseoMMgY4i5cjIQJaBJ9uaUWgk0TRe5AAogpWrCoRRPj4tkOEcsGTX6fvaUWgSxFasJJ1ZYMFW6Bka96tby9xgsY6Ny98TPZE9nNuq9aCdmM1hGCxE9wwViHupHHdP(MtkOErH2iRFjRpWYmof1VW6BoPG6dnXi6hS(aGOrz9wwpbgs9e2MqQV5KcQxuOnY6xY6dSmJtr9PbjIzutd0KmOM(YqsQocSn2tb4cBO4BtVEQuRpnj6PICGXSFL7YvOBxjYRVv9rXOu2tdseZO6kno25MFWW1ZMW6jSErQNauFAs0tvcTr2xYoKzCf62vI86POEQuRN16ttIEQonosSVKDbwcrUcD7krE9TQpkgLYEAqIygvxPXXo38dgUE2ewpH1tG1taQpnj6PkH2i7lzhYmUcD7krE9uOtDqbslQMgD7krUoan9kwthXutBNCwxtd0GJDLOMgOb7UbIA6R04yNB(b10h4KiCmnnKXrYfsevCdsjrPbXoiYnPCwxHUDLixtZX4boIZzDnnbFsb1ZYgKsIsdISxFasJJ1ZYMFW6TSEFHGMS(0GeXS(ZY4z9nfGE9xgssKx)Tr9w9r8So3GnQhjjXtYE9lSEt20AeR3Y6jqrdPEYfwVVobGLrW1NJMgOjzqnDAs0tf5aJz)k3LRq3UsKxpvQ1ty9xgssfiMg4cflyJtuXiUEQuRpnj6PkH2i7lzhYmUcD7krE9uPwphVmKKkmgr)G9lenkvmIRNI6BvFumkL90GeXmQUsJJDU5hmC9SjSEcRVn1taQpnj6PkH2i7lzhYmUcD7krE9uupvQ1ZA9PjrpvCeC95Oq3UsKxFR6JIrPSNgKiMr1vACSZn)GHRNnH1tG6uhebulQMgD7krUoan9kwtdXiMAA7KZ6AAGgCSRe10any3nqutFLgh7CZpOM(aNeHJPPttIEQWye9d2Vq0OuHUDLiV(w1F2vY3MUcJr0py)crJsfenEdnnhJh4ioN110aSIy9HMye9dwFaq0OS(lsUqS(aKghRNLn)G1pK1pz9tSEdOns7kX6nNx)ssw)zxjFB66uhuORfvtJUDLixhGMEfRPJyQPTtoRRPbAWXUsutd0KmOMM16ttIEQ4i46ZrHUDLiV(w1F2vY3MUcetdCHIfSXjQGiOnES(qvpbS(w1tYaBO4i5CMSE2QVnTRPbAWUBGOMw8UYXj2jxyhettN6Giy0IQPr3UsKRdqtVI10rm102jN110an4yxjQPbAsgutd0GJDLO6kno25MFW6BvpH1tYaBuFOQp0du9eG6ttIEQihym7x5UCf62vI86dmQxK2RNcnnqd2Dde10I3vooXo5c7xPXXo38dQtDqa8Ar10OBxjY1bOPxXA6iMAA7KZ6AAGgCSRe10anjdQPttIEQ4i46ZrHUDLiV(w1ZA9Pjrpvx548ojdSHcD7krE9TQ)SRKVnDf2a7x0avqe0gpwFOQNW6jE4kqRT1hyuVi1tr9TQNKb2qXrY5mz9SvViTRPbAWUBGOMw8UYXj2jxyhBG9lAG6uhu421IQPr3UsKRdqtVI10rm102jN110an4yxjQPbAsgutNMe9ubUGONmGk0TRe513QEwR)YqsQaxq0tgqfJynnqd2Dde10nTjhNyNCHDWfe9KbuN6GchwlQMgD7krUoanTDYzDn9XKYUDYz9UCIPMwoXS7giQPp7k5BtxN6GclIwunn62vICDaA6dCseoMM(YqsQirz)UGxdYbrpvX0ouwVW6du9TQNW6VmKKQbeCLwoR3ngOPyexpvQ1ZA9xgssfiMg4cflyJtuXiUEk002jN110Pa42StuAdquN6Gc3gTOAA0TRe56a00h4KiCmnDAs0tfhbxFok0TRe5A6ycNtQdkSM2o5SUMgY4D7KZ6D5etnTCIz3nqutZrW1NJo1bfMa1IQPr3UsKRdqtBNCwxtdz8UDYz9UCIPMwoXS7giQP9fcAsDQtnnhbxFoAr1bfwlQMgD7krUoan9bojchttNMe9uX43LX59JaBJk0TRe513Q(ldjPIXVlJZ7hb2gvmIRVv9ew)rGbjIX6fwVi1tLA9ewp0gEhbIEQaxGii6PA86zR(WTxFR6H2W7iq0tLX5r141Zw9HBVEkQNcnTDYzDnnjk7qMOaDQdseTOAA0TRe56a00h4KiCmnnqdo2vIQR04yNB(b102jN110C0sb9ytefRtDqTrlQMgD7krUoan9bojchttBNCaID0rWbJ1Zw9CmoqK3tdseZy9uPwp0gEhbIEQmopQgVE2QpC7AA7KZ6AAIsBaI9ebfJXuN6GiqTOAA0TRe56a00h4KiCmn9zDoZKQicHwI8orPnarf62vI86Bv)zxjFB6kSb2VObQGiOnES(qvpbS(w1ZA9xgssfiMg4cflyJtuXiU(w1ZA9C8YqsQW2kEJiV3CzCUIrSM2o5SUMofa3MDIsBaI6uhuG0IQPr3UsKRdqtFGtIWX002jhGyhDeCWy9SvphJde590GeXmwpvQ1dTH3rGONkJZJQXRNT6fjq13QEcRN16bAWXUsuXeXo2a7x0a7KmWg9Z68jN1RNk16JIrPSNgKiMX6zR(W1tLA9KmWg1hQ6d92RNcnTDYzDnn2a7x0a1PoicOwunn62vICDaA6dCseoMMgObh7kr1vACSZn)G13QEwR)SRKVnDfiMg4cflyJtubrJ3O(w1ty9NDL8TPRWgy)IgOcIG24X6zR(avpvQ1ty9qB4Dei6PY48OA86zRE7KZ69ZUs(20RVv9qB4Dei6PY48OA86dv9IeO6POEk002jN110xPXXo38dQtDqHUwunn62vICDaA6dCseoMMM16VmKKQbeCLwoR3ngOPyeRPTtoRRPhqWvA5SE3yGMo1brWOfvtJUDLixhGM(aNeHJPPzTEGgCSRevI3vooXo5c7xPXXo38dQPTtoRRPn3hbJ0YzDDQdcGxlQMgD7krUoan9bojchtttYaBO4i5CMSE2ewpb2UM2o5SUMMeLxPXrDQdkC7Ar102jN110ymI(b7xiAuQPr3UsKRdqN6GchwlQMgD7krUoan9bojchttZA9an4yxjQeVRCCIDYf2VsJJDU5hS(w1ZA9an4yxjQeVRCCIDYf2Xgy)IgOM2o5SUM(iW2ypMWHsuN6GclIwunn62vICDaA6dCseoMMonj6PIJGR3VsJJrf62vI86BvpR1F2vY3MUcBG9lAGkiA8g13QEcR)iWGeXy9cRxK6PsTEcRhAdVJarpvGlqee9unE9SvF42RVv9qB4Dei6PY48OA86zR(WTxpf1tHM2o5SUMMeLDituGo1bfUnAr10OBxjY1bOPTtoRRP5i46X(DsutFGtIWX00qghjxiruDzG(4e7nxgNRq3UsKxFR654LHKuDzG(4e7nxgNRGiOnES(qvpbQPpnosSNgKiMrDqH1PoOWeOwunn62vICDaA6dCseoMMM16ttIEQ4i469R04yuHUDLiV(w1hfJszpnirmJ1Zw9HRVv9ew)rGbjIX6fwVi1tLA9ewp0gEhbIEQaxGii6PA86zR(WTxFR6H2W7iq0tLX5r141Zw9HBVEkQNcnTDYzDnnjk7qMOaDQdkCG0IQPTtoRRP5i46X(DsutJUDLixhGo1bfMaQfvtJUDLixhGM(aNeHJPPVmKKQLj7lzhAoruXiwtBNCwxtNcGBZorPnarDQdkCORfvtJUDLixhGM(aNeHJPPbxGii6PIpX08dwpB1hoq1tLA9xgss1YK9LSdnNiQyeRPTtoRRPjrzhYefOtDqHjy0IQPr3UsKRdqtFGtIWX00Glqee9uXNyA(bRNT6dhinTDYzDnnq0jIKmYoetiAPo1bfgGxlQMgD7krUoan9bojchttNMe9uXrW17xPXXOcD7krUM2o5SUMofa3MDIsBaI6uNA6ZUs(201IQdkSwunn62vICDaA6dCseoMMM16ttIEQ4i46ZrHUDLiV(w1F2vY3MUcBG9lAGkicAJhRNT6fP96BvpH1ZA9Nfi6MNkGONcAaRNk16zTE(MQ44KmY(fAoxLZHYXjwpf1tLA9KdrbzhIG24X6dv9IeinTDYzDnniMg4cflyJtuN6GerlQMgD7krUoan9bojchttNMe9uXrW1NJcD7krE9TQNW6p7k5BtxHnW(fnqfebTXJ1Zw9I0E9TQNW6zTEGgCSRevxPXXo38dwpvQ1F2vY3MU6kno25MFqfebTXJ1Zw9epCfO126POEkQVv9ewpR1FwGOBEQaIEkObSEQuRN165BQIJtYi7xO5CvohkhNy9uupvQ1toefKDicAJhRpu1lsG002jN110GyAGluSGnorDQdQnAr10OBxjY1bOPpWjr4yA6ldjPcetdCHIfSXjQGiOnESE2QxKavpvQ1F3yS(w1toefKDicAJhRpu1taBxtBNCwxtlEZzDDQdIa1IQPr3UsKRdqtZX4boIZzDnnlJKgJmRNjI1pjcwVCjohn9bojchttd0GJDLOkHJtjM9yd)0JYnRxy9HRVv9ew)LHKubIPbUqXc24evmIRNk16jSEwRpnj6PIJGRphf62vI86Bv)zxjFB6kqmnWfkwWgNOcIG24X6zREcRNCiki7qe0gpwFOayxFchNsmvzy1zxjFB6kod0Yz96bq9Iupf1tr9uPwp5quq2HiOnES(qjSErAVEkQNk16jSEGgCSRevjCCkXShB4NEuUz9cRxK6BvpR1NWXPetvkI6SRKVnDfenEJ6POEQuRN16bAWXUsuLWXPeZESHF6r5MA6OCZOMoHJtjMH102jN110jCCkXmSo1bfiTOAA0TRe56a002jN110jCCkXuen9bojchttd0GJDLOkHJtjM9yd)0JYnRxy9IuFR6jS(ldjPcetdCHIfSXjQyexpvQ1ty9SwFAs0tfhbxFok0TRe513Q(ZUs(20vGyAGluSGnorfebTXJ1Zw9ewp5quq2HiOnES(qbWU(eooLyQsruNDL8TPR4mqlN1Rha1ls9uupf1tLA9KdrbzhIG24X6dLW6fP96POEQuRNW6bAWXUsuLWXPeZESHF6r5M1lS(W13QEwRpHJtjMQmS6SRKVnDfenEJ6POEQuRN16bAWXUsuLWXPeZESHF6r5MA6OCZOMoHJtjMIOtDqeqTOAA0TRe56a00h4KiCmnnR1Z3ufhNKr2VqZ5QCouoornTDYzDnDCCsgz)cnNRtDqHUwunn62vICDaA6dCseoMMM16ttIEQ4i46ZrHUDLiV(w1ZA9an4yxjQAAtooXo5c7Gli6jdy9TQN16bAWXUsujEx54e7KlSdIPvpvQ1FzijvKmWzzIDIwGzuXiwtBNCwxtNcWUagp1PoicgTOAA0TRe56a00h4KiCmnnH1BNCaID0rWbJ1Zw9CmoqK3tdseZy9uPwp0gEhbIEQmopQgVE2QVnTxpfAA7KZ6AAu2ioM354bIOo1PMwmepl41sTO6GcRfvtBNCwxtF3mLiVtkTgiV54e7522X10OBxjY1bOtDqIOfvtJUDLixhGMEfRPJyQPTtoRRPbAWXUsutd0KmOMoSM(aNeHJPPt44uIPkdReyXote7xgsY6BvpH1ZA9jCCkXuLIOeyXote7xgsY6PsT(eooLyQYWQZUs(20vCgOLZ61ZMW6t44uIPkfrD2vY3MUIZaTCwVEk00any3nqutNWXPeZESHF6r5M6uhuB0IQPr3UsKRdqtVI10rm102jN110an4yxjQPbAsgutlIM(aNeHJPPt44uIPkfrjWIDMi2VmKK13QEcRN16t44uIPkdReyXote7xgsY6PsT(eooLyQsruNDL8TPR4mqlN1RNT6t44uIPkdRo7k5BtxXzGwoRxpfAAGgS7giQPt44uIzp2Wp9OCtDQdIa1IQPr3UsKRdqtVI10rm102jN110an4yxjQPbAsgutNMe9uDLJZ7KmWgk0TRe513QEcRhY4i5cjIkUbPKO0Gyhe5MuoRRq3UsKxpvQ1NMe9uXrW17xPXXOcD7krE9uOP5y8ahX5SUMgGveRp00aRpa0aR3Y6LBZ6b4yGnQV5KcQpa5486b4yGnQ)SG3XrE9nNuq94Kcqy9SSbPKO0Gy9lSEwgbxV(aKghJAAGgS7giQPzIyhBG9lAGDsgyJ(zD(KZ66uN6uN6uRba]] )


end
