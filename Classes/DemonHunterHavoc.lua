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


    spec:RegisterPack( "Havoc", 20210729.2, [[dafvubqievlsqvQhjGYLeuvSjfYNeOgfI4uiOvHsvXReuMfrXTujQ2fj)sLWWuO6ycYYquEgcKPPsKRjGSneaFdbkJtLO05qaY6qPI5jOY9is7dLY)euv1bfqvwOa8qeqteLQCrbvXgvjk(OaQQrkGkDseGALQKMjkv6McQkTtbYprPQKHkOkPLIsv1trYujkDvbvv(kcunwfk2lP(RIgSQomLfd4XQyYO6YqBgP(mcnAI40sTAuQk1RrKMnHBd0UP63knCIQJlGkwoONl00fDDuSDvQVRaJxHsNxbTEbvjMpkz)swhslRMIBjQdISXjl04x2XdPcracDPlrMMkhkh1uYTdPgrut5giQPcCT79OPKBdfRX1YQPIld8GAkQgKryzVobcn6utbW0IKa21aAkULOoiYgNSqJFzhpKkebi0LUuinvuoE0bficgbttjP5C01aAkogpAk2dbxV(axgpry9bU29EQRxzedRNmcizQNSXjluDTUsGsmNigzN66LxF4lMg4cLlzJDSEZ51hEDZE96zIgrS(WBaKEHy90nrjz9OZJH31lwI9PEJZ(MjMiV(CR3KlxmS(1fdRp36b2ySE6MOKmQQRxE9S7Ur0RNrE9XH(PDI1V01h(IPbUq5s2yhRNeW2RFPRNUjkjRhIGw7X6VJQ6ty7KIz9ei7vp0sjiS(uI51dAJLqLMsoCPBbQPcSaRE2dbxV(axgpry9bU29EQRbwGv)vgXW6jJasM6jBCYcvxRRbwGvpbkXCIyKDQRbwGv)LxF4lMg4cLlzJDSEZ51hEDZE96zIgrS(WBaKEHy90nrjz9OZJH31lwI9PEJZ(MjMiV(CR3KlxmS(1fdRp36b2ySE6MOKmQQRbwGv)Lxp7UBe96zKxFCOFANy9lD9HVyAGluUKn2X6jbS96x66PBIsY6HiO1ES(7OQ(e2oPywpbYE1dTuccRpLyE9G2yjuvxRR2j71Jk5q8SGawkfyZuG8jTWgI8bTtCM7yBVUANSxpQKdXZccyzysV42GTbiqzCdeLMW2jfZzCOFMrXMYCBcguAizAAPjSDsXufsjXItMiobyOPhrc5jSDsXurMsIfNmrCcWqtZIvcBNumvHuNDf8DGR4mql71ztAcBNumvKPo7k47axXzGw2RtyD1ozVEujhINfeWYWKEXTbBdqGY4giknHTtkMZ4q)mJInL52emOuYKPPLMW2jftfzkjwCYeXjadn9isipHTtkMQqkjwCYeXjadnnlwjSDsXurM6SRGVdCfNbAzVoBjSDsXufsD2vW3bUIZaTSxNW6AGvF4xeRp8meRpa0aR3Y6f7G6VmmWH1pOtj1hGODE9xgg4W6pliq7iV(bDkPEStjiSE2ZGKsuyqS(fwp7HGRxFacJJX6QDYE9OsoepliGLHj9IBd2gGaLXnqukteN4qCcGg4KMboCEwN3zVUm3MGbLMMa9ubiANpPzGdvOBacKpIeiJJ0lKiQ4gKuIcdItqKBcrVolwPjqpvCeC9jGW4yuHUbiqoH116ADnWcS6dpJfpmjYRhVr4W6ZgeRpLG1BNCH13X6TBRfgGav1v7K96rP8oczKN1v7K96XWKEXz9idiobnI9PUgybw9eCSE(6bN1Z36tjDS(0GeXS(4atU82jwFU1BYLlgwFamqVDI1tWxgNxxdSaRE7K96XWKEbetdseZPXK70Y0oKkJODCE4sdjtAqIyoBAPGTZoCeGHMwbWa92johSmoxbrqR9OmnTuiJJ0lKiQayGE7eNdwgNpknb6PIJGRpbeghJk0nabYRRbw9e8oLSmz9eOeBJ1lReCHdRFH1ZEgKuIcdIYuFacJJ1ZEMFW6h0PK6VmnmM1hGyxE9lSElRNGcREsilS6h0PK6LfATO(LUE2pt7ewFAqIygRR2j71JHj9IBd2gGaLXnqukGW44KB(bLPPLsoKXr6fsevhj2gNPeCHdhroKXr6fsevCdskrHbXjiYnHOxxMBtWGsttGEQOBymNaID5k0nabYzXkkhfIzAqIygvacJJtU5hmeBsjHGU80eONQeATyU0tit7k0nabYjSUgy1tW7us9eOeBJ1lReCHdLP(aeghRN9m)G1pqc61NsW6byOPRVJ1Z3bUm1pOtj1FzAymRpaXU86TSEYcREscfw9d6us9YcTwu)sxp7NPDcRFH1pOtj1hEIr0py9barJ06TS(lfw9KqqHv)GoLuVSqRf1V01Z(zANW6tdseZyD1ozVEmmPxCBW2aeOmUbIsbeghNCZpOmnTuiJJ0lKiQosSnotj4chkZTjyqPam00QJeBJZucUWHk(oWzXknb6PIUHXCci2LRq3aeiFuuokeZ0GeXmQaeghNCZpyi2KsczxEAc0tvcTwmx6jKPDf6gGa5eYIf5PjqpvNHhbox6PelHixHUbiq(OOCuiMPbjIzubimoo5MFWqSjLKlD5Pjqpvj0AXCPNqM2vOBacKtyDnWQNG3PK6zpdskrHbrzQpaHXX6zpZpy9wwVVqqtuFAqIyw)zz8S(bsqVEagAAKxpWW6T6J4zDUbhwpstJNuM6xy9MyGnmwVL1FjzdRE6fwVV(LZEi469PUANSxpgM0lUnyBacug3arPacJJtU5huMMwkKXr6fsevCdskrHbXjiYnHOxxMBtWGsttGEQOBymNaID5k0nabYzXIeagAAfiMg4cLlzJDuXiNfR0eONQeATyU0tit7k0nabYzXIJam00kmgr)GtaiAKQyKt4OOCuiMPbjIzubimoo5MFWqSjLec6YttGEQsO1I5spHmTRq3aeiNqwSipnb6PIJGR3hf6gGa5JIYrHyMgKiMrfGW44KB(bdXM0lvxdS6d)Iy9HNye9dwFaq0iTEaKEHy9bimowp7z(bRVPRVZ67y92T1cdqG1BoV(LMU(ZUc(oWRR2j71JHj9IBd2gGaLXnqukGW44KB(bLzLlfIrmLPPLMMa9uHXi6hCcarJuf6gGa5Jo7k47axHXi6hCcarJufen(W6QDYE9yysV42GTbiqzCdeLkFxr7eN0lCcIPjZTjyqPKNMa9uXrW17JcDdqG8rNDf8DGRaX0axOCjBSJkicAThdhbyendCOIJ09Pt2iOXRR2j71JHj9IBd2gGaLXnquQ8DfTtCsVWjGW44KB(bL52emO0Bd2gGavacJJtU5hCej0mWHHJGfOlpnb6PIUHXCci2LRq3aeiN9HSXjSUANSxpgM0lUnyBacug3arPY3v0oXj9cN4qCcGgOm3MGbLMMa9uXrW17JcDdqG8rKNMa9ubiANpPzGdvOBacKp6SRGVdCfoeNaObQGiO1EmCKq8WvG2yzFiJWr0mWHkos3NozJSXRR2j71JHj9IBd2gGaLXnqu6aRZ2joPx4eCbrpzaL52emO00eONkWfe9KbuHUbiq(iYbyOPvGli6jdOIrED1ozVEmmPxCmHyANSxFk6ykJBGO0ZUc(oWRR2j71JHj9IucChmjkS(gLPPLcWqtROrXeybbmihe9uft7qQ0anIeagAAvdcUcl71Ngd0umYzXICagAAfiMg4cLlzJDuXiNW6QDYE9yysVaY4t7K96trhtzCdeLYrW17JmXe2NuAizAAPPjqpvCeC9(Oq3aeiVUANSxpgM0lGm(0ozV(u0Xug3arP(cbnrDTUANSxpQo7k47axkiMg4cLlzJDuMMwk5PjqpvCeC9(Oq3aeiF0zxbFh4kCiobqdubrqR9iBKn(isi)S3OBEQUrpLmeQq3aeiNflY5BQITtZiMaqZ5QSpK2orczXIUjkjNqe0ApgoYcuD1ozVEuD2vW3bEysVaetdCHYLSXokttlnnb6PIJGR3hf6gGa5Ji5SRGVdCfoeNaObQGiO1EKnYgFejKFBW2aeOcqyCCYn)GSyD2vW3bUcqyCCYn)GkicAThzJ4HRaTXsiHJiH8ZEJU5P6g9uYqOcDdqGCwSiNVPk2onJycanNRY(qA7ejKfl6MOKCcrqR9y4ilq1v7K96r1zxbFh4Hj9c5B2RlttlfGHMwbIPbUq5s2yhvqe0ApYgzbIflGnghr3eLKticAThdhby86AGvp7H0gJiRNjI13jcwVyj2N6QDYE9O6SRGVd8WKEbteNDIGrzIInJsty7KIzizAAP3gSnabQsy7KI5mo0pZOytPHgrcadnTcetdCHYLSXoQyKZIfjKNMa9uXrW17JcDdqG8rNDf8DGRaX0axOCjBSJkicAThzJe6MOKCcrqR9y4c)ty7KIPkK6SRGVdCfNbAzVE4dzesilw0nrj5eIGw7XWjLSXjKflsUnyBacuLW2jfZzCOFMrXMsjBe5jSDsXurM6SRGVdCfen(qczXI8Bd2gGavjSDsXCgh6NzuSzD1ozVEuD2vW3bEysVGjIZorWOmrXMrPjSDsXKmzAAP3gSnabQsy7KI5mo0pZOytPKnIeagAAfiMg4cLlzJDuXiNflsipnb6PIJGR3hf6gGa5Jo7k47axbIPbUq5s2yhvqe0ApYgj0nrj5eIGw7XWf(NW2jftfzQZUc(oWvCgOL96HpKriHSyr3eLKticAThdNuYgNqwSi52GTbiqvcBNumNXH(zgfBkn0iYty7KIPkK6SRGVdCfen(qczXI8Bd2gGavjSDsXCgh6NzuSzD1ozVEuD2vW3bEysVi2onJycanNlttlLC(MQy70mIja0CUk7dPTtSUANSxpQo7k47apmPxKsWPegpLPPLsEAc0tfhbxVpk0nabYhr(TbBdqGQbwNTtCsVWj4cIEYaoI8Bd2gGavY3v0oXj9cNGyASybWqtROzG9YeNeTWlOIrED1ozVEuD2vW3bEysVafdJT5toEGikttlLe7K9norhbBmYghJne5Z0GeXmYIf0A(eVrpvgNhvTZgbnoH116QDYE9OIJGR3hP0OyczIsKPPLMMa9uX4alJZNhj2gvOBacKpcGHMwX4alJZNhj2gvmYhrYrIbjIrPKXIfjqR5t8g9ubU3ii6PQD2cn(iO18jEJEQmopQANTqJtiH1v7K96rfhbxVpHj9coAPKzCaIYLPPLEBW2aeOcqyCCYn)G1v7K96rfhbxVpHj9cIcRVXzIGYXykttl1ozFJt0rWgJSXXydr(mnirmJSybTMpXB0tLX5rv7SfA86QDYE9OIJGR3NWKErkbUdMefwFJY00spRZz6ufri0sKpjkS(gvOBacKp6SRGVdCfoeNaObQGiO1EmCeGrKdWqtRaX0axOCjBSJkg5JiNJam00kCSY3iYNdwgNRyKxxTt2RhvCeC9(eM0lWH4eanqzAAP2j7BCIoc2yKnogBiYNPbjIzKflO18jEJEQmopQANnYc0isi)2GTbiqfteN4qCcGg4KMboCEwN3zVolwr5OqmtdseZiBHyXIMbomCeSXjSUANSxpQ4i469jmPxaimoo5MFqzAAP3gSnabQaeghNCZp4iYp7k47axbIPbUq5s2yhvq04dhrYzxbFh4kCiobqdubrqR9iBbIflsGwZN4n6PY48OQD2o7k47aFe0A(eVrpvgNhvThoYceHewxTt2RhvCeC9(eM0lAqWvyzV(0yGMmnTuYbyOPvni4kSSxFAmqtXiVUANSxpQ4i469jmPxyU3sAHL96Y00sj)2GTbiqL8DfTtCsVWjGW44KB(bRR2j71JkocUEFct6f0OaqyCuMMwkndCOIJ09Pt2KEPXRR2j71JkocUEFct6fymI(bNaq0iTUANSxpQ4i469jmPxCKyBCgtytkkttlL8Bd2gGavY3v0oXj9cNacJJtU5hCe53gSnabQKVRODIt6foXH4eanW6QDYE9OIJGR3NWKEbnkMqMOezAAPPjqpvCeC9jGW4yuHUbiq(iYp7k47axHdXjaAGkiA8HJi5iXGeXOuYyXIeO18jEJEQa3Bee9u1oBHgFe0A(eVrpvgNhvTZwOXjKW6QDYE9OIJGR3NWKEbhbxpob6eL5m8iWzAqIygLgsMMwkKXr6fsevamqVDIZblJZhXragAAfad0BN4CWY4CfebT2JH7s1v7K96rfhbxVpHj9cAumHmrjY00sjpnb6PIJGRpbeghJk0nabYhfLJcXmnirmJSfAejhjgKigLsglwKaTMpXB0tf4EJGONQ2zl04JGwZN4n6PY48OQD2cnoHewxTt2RhvCeC9(eM0l4i46XjqNyD1ozVEuXrW17tysViLa3btIcRVrzAAPam00QLjNl9eAoruXiVUANSxpQ4i469jmPxqJIjKjkrMMwk4EJGONkEhtZpiBHcelwam00QLjNl9eAoruXiVUANSxpQ4i469jmPxCJorKMrmHycrlLPPLcU3ii6PI3X08dYwOavxTt2RhvCeC9(eM0lsjWDWKOW6BuMMwAAc0tfhbxFcimogvOBacKxxRR2j71JkFHGMq6n6erAgXeIjeTuMMwAAc0tf4cIEYaQq3aeiFeadnTsoeLBqKR47aFu2GiBHQR2j71JkFHGMimPxqJIjKjkrMMwkjam00kghyzC(8iX2OIrolw3gSnabQgyD2oXj9cNGli6jd4isipnb6PIXbwgNppsSnQq3aeiNflYp7k47ax1GGRWYE9PXanfen(qcjCejhjgKigLsglwKaTMpXB0tf4EJGONQ2zl04JGwZN4n6PY48OQD2cnoHewxTt2Rhv(cbnrysVGgftadcnIOmnTu7K9norhbBmYghJne5Z0GeXmYIf0A(eVrpvgNhvTZgbnED1ozVEu5le0eHj9coAPKzCaIYLPPLEBW2aeOcqyCCYn)G1v7K96rLVqqteM0lAqWvyzV(0yGMmnTuYbyOPvni4kSSxFAmqtXiVUANSxpQ8fcAIWKEbrH134mrq5ymLPPLs(TbBdqGQbwNTtCsVWj4cIEYaoIe7K9norhbBmYghJne5Z0GeXmYIf0A(eVrpvgNhvTZwOXjSUANSxpQ8fcAIWKErkbUdMefwFJY00spRZz6ufri0sKpjkS(gvOBacKp6SRGVdCfoeNaObQGiO1EmCeGrKdWqtRaX0axOCjBSJkg5JiNJam00kCSY3iYNdwgNRyKxxTt2Rhv(cbnrysVahIta0aLPPLs(TbBdqGQbwNTtCsVWj4cIEYaoIe7K9norhbBmYghJne5Z0GeXmYIf0A(eVrpvgNhvTZwOanIeYVnyBacuXeXjoeNaOboPzGdNN15D2RZIvuokeZ0GeXmYwiwSOzGddhbBCcjSUANSxpQ8fcAIWKEbGW44KB(bLPPLEBW2aeOcqyCCYn)G1v7K96rLVqqteM0lOrbGW4OmnTuAg4qfhP7tNSj9sJxxTt2Rhv(cbnrysVaJr0p4eaIgP1v7K96rLVqqteM0lm3BjTWYEDzAAPKKMa9uXrW1NacJJrf6gGa5Syr(TbBdqGQbwNTtCsVWj4cIEYaYIfndCOIJ09PZWrqJZIfadnTcetdCHYLSXoQGiO1EmCbIWrKFBW2aeOs(UI2joPx4eqyCCYn)G1v7K96rLVqqteM0losSnoJjSjfLPPLssAc0tfhbxFcimogvOBacKZIf53gSnabQgyD2oXj9cNGli6jdilw0mWHkos3NodhbnoHJi)2GTbiqL8DfTtCsVWjiM2iYVnyBacujFxr7eN0lCcimoo5MFW6QDYE9OYxiOjct6f4qCcGgOmnT00eONkar78jndCOcDdqG8rqR5t8g9uzCEu1oBNDf8DGxxTt2Rhv(cbnrysVGJGRhNaDIYCgEe4mnirmJsdjttlfY4i9cjIkagO3oX5GLX5J4iadnTcGb6TtCoyzCUcIGw7XWDP6QDYE9OYxiOjct6fCeC94eOtSUANSxpQ8fcAIWKEbnkMqMOezAAPKNMa9ubUGONmGk0nabYhbTMpXB0tf4EJGONQ2z7iXGeXi7tOXhLMa9uXrW1NacJJrf6gGa51v7K96rLVqqteM0lOrbGW4OmnTuW9gbrpv8oMMFq2cfiwSayOPvltox6j0CIOIrED1ozVEu5le0eHj9cAumHmrjY00sb3Bee9uX7yA(bzluGyXIeagAA1YKZLEcnNiQyKpI80eONkWfe9KbuHUbiqoH1v7K96rLVqqteM0lUrNisZiMqmHOLY00sb3Bee9uX7yA(bzluGQR2j71JkFHGMimPxKsG7GjrH13OmnT00eONkocU(eqyCmQq3aeixtDJWyVUoiYgNSqJtWiJasfstnWGE7eJAkcEGh7pic4Gc8zN6Rxwjy9nO8fM1tVW6d2xiOjcUEig4W0qKxFCbX6nMCbTe51FKyormQQRSB7y9Hce7upbU(nctKxFWqghPxirunMGRp36dgY4i9cjIQXOq3aeip46jj0yjuvxRRe8ap2FqeWbf4Zo1xVSsW6Bq5lmRNEH1hmhPngrgC9qmWHPHiV(4cI1Bm5cAjYR)iXCIyuvxz32X6ji2PEcC9BeMiV(GHmosVqIOAmbxFU1hmKXr6fsevJrHUbiqEW1tsOXsOQUYUTJ1tqSt9e463imrE9bdzCKEHer1ycU(CRpyiJJ0lKiQgJcDdqG8GR3Y6dpSVy36jj0yjuvxz32X6Ve7upbU(nctKxFWqghPxirunMGRp36dgY4i9cjIQXOq3aeip46TS(Wd7l2TEscnwcv1v2TDS(aXo1tGRFJWe51hmKXr6fsevJj46ZT(GHmosVqIOAmk0nabYdUElRp8W(IDRNKqJLqvDTUsWd8y)brahuGp7uF9YkbRVbLVWSE6fwFWYH4zbbSm46HyGdtdrE9XfeR3yYf0sKx)rI5eXOQUYUTJ1tg7upbU(nctKxFWjSDsXufsnMGRp36doHTtkMQmKAmbxpjKnwcv1v2TDSEYyN6jW1VryI86doHTtkMkYuJj46ZT(Gty7KIPkjtnMGRNeYglHQ6k72owpbXo1tGRFJWe51hCcBNumvHuJj46ZT(Gty7KIPkdPgtW1tczJLqvDLDBhRNGyN6jW1VryI86doHTtkMkYuJj46ZT(Gty7KIPkjtnMGRNeYglHQ6k72ow)LyN6jW1VryI86dgY4i9cjIQXeC95wFWqghPxirungf6gGa5bxpjHglHQ6ADLGh4X(dIaoOaF2P(6LvcwFdkFHz90lS(Gp7k47ap46HyGdtdrE9XfeR3yYf0sKx)rI5eXOQUYUTJ1hIDQNax)gHjYRp4ZEJU5PAmk0nabYdU(CRp4ZEJU5PAmbxpjHglHQ6k72owpzSt9e463imrE9bF2B0npvJrHUbiqEW1NB9bF2B0npvJj46jj0yjuvxz32X6Ve7upbU(nctKxpvdsG1hh6Pn26dFQp36zxgREEF3XE96x5i0Yfwpjxqy9KeASeQQRSB7y9xIDQNax)gHjYRp4e2oPyQcPgtW1NB9bNW2jftvgsnMGRNKqJLqvDLDBhR)sSt9e463imrE9bNW2jftfzQXeC95wFWjSDsXuLKPgtW1tsOXsOQUYUTJ1hi2PEcC9BeMiVEQgKaRpo0tBS1h(uFU1ZUmw98(UJ961VYrOLlSEsUGW6jj0yjuvxz32X6de7upbU(nctKxFWjSDsXufsnMGRp36doHTtkMQmKAmbxpjHglHQ6k72owFGyN6jW1VryI86doHTtkMkYuJj46ZT(Gty7KIPkjtnMGRNKqJLqvDTUsWd8y)brahuGp7uF9YkbRVbLVWSE6fwFWCeC9(eC9qmWHPHiV(4cI1Bm5cAjYR)iXCIyuvxz32X6drqSt9e463imrE9bdzCKEHer1ycU(CRpyiJJ0lKiQgJcDdqG8GRNKqJLqvDTUsadkFHjYRpq1BNSxVErhZOQUQPmMuYc1uunibQPeDmJAz1u(cbnHwwDqH0YQPq3aeixhGM6a7eHTPPstGEQaxq0tgqf6gGa51pQEagAALCik3GixX3bE9JQpBqSE2QpKMYozVUM6gDIinJycXeIwQtDqKPLvtHUbiqUoan1b2jcBttrs9am00kghyzC(8iX2OIrE9Syv)TbBdqGQbwNTtCsVWj4cIEYaw)O6jPEYRpnb6PIXbwgNppsSnQq3aeiVEwSQN86p7k47ax1GGRWYE9PXanfen(W6jSEcRFu9Ku)rIbjIX6Lwpz1ZIv9Kup0A(eVrpvG7ncIEQAVE2Qp041pQEO18jEJEQmopQAVE2Qp041ty9eQPSt2RRPOrXeYeLOtDqeKwwnf6gGa56a0uhyNiSnnLDY(gNOJGngRNT65ySHiFMgKiMX6zXQEO18jEJEQmopQAVE2QNGgxtzNSxxtrJIjGbHgruN6GUKwwnf6gGa56a0uhyNiSnn1TbBdqGkaHXXj38dQPSt2RRP4OLsMXbikxN6GcKwwnf6gGa56a0uhyNiSnnf51dWqtRAqWvyzV(0yGMIrUMYozVUMQbbxHL96tJbA6uhebqlRMcDdqGCDaAQdSte2MMI86VnyBacunW6SDIt6fobxq0tgW6hvpj1BNSVXj6iyJX6zREogBiYNPbjIzSEwSQhAnFI3ONkJZJQ2RNT6dnE9eQPSt2RRPikS(gNjckhJPo1brW0YQPq3aeixhGM6a7eHTPPoRZz6ufri0sKpjkS(gvOBacKx)O6p7k47axHdXjaAGkicAThRpC1taQFu9KxpadnTcetdCHYLSXoQyKx)O6jVEocWqtRWXkFJiFoyzCUIrUMYozVUMkLa3btIcRVrDQd6YQLvtHUbiqUoan1b2jcBttrE93gSnabQgyD2oXj9cNGli6jdy9JQNK6Tt234eDeSXy9SvphJne5Z0GeXmwplw1dTMpXB0tLX5rv71Zw9Hcu9JQNK6jV(Bd2gGavmrCIdXjaAGtAg4W5zDEN961ZIv9r5OqmtdseZy9SvFO6zXQEAg4W6dx9eSXRNW6jutzNSxxtHdXjaAG6uhebKwwnf6gGa56a0uhyNiSnn1TbBdqGkaHXXj38dQPSt2RRPaeghNCZpOo1bfACTSAk0nabY1bOPoWoryBAkAg4qfhP7tN1ZM06V04Ak7K96AkAuaimoQtDqHcPLvtzNSxxtHXi6hCcarJunf6gGa56a0PoOqKPLvtHUbiqUoan1b2jcBttrs9PjqpvCeC9jGW4yuHUbiqE9Syvp51FBW2aeOAG1z7eN0lCcUGONmG1ZIv90mWHkos3NoRpC1tqJxplw1dWqtRaX0axOCjBSJkicAThRpC1hO6jS(r1tE93gSnabQKVRODIt6fobeghNCZpOMYozVUMYCVL0cl711PoOqeKwwnf6gGa56a0uhyNiSnnfj1NMa9uXrW1NacJJrf6gGa51ZIv9Kx)TbBdqGQbwNTtCsVWj4cIEYawplw1tZahQ4iDF6S(WvpbnE9ew)O6jV(Bd2gGavY3v0oXj9cNGyA1pQEYR)2GTbiqL8DfTtCsVWjGW44KB(b1u2j711uhj2gNXe2KI6uhuOlPLvtHUbiqUoan1b2jcBttLMa9ubiANpPzGdvOBacKx)O6HwZN4n6PY48OQ96zRE7K96ZZUc(oW1u2j711u4qCcGgOo1bfkqAz1uOBacKRdqtzNSxxtXrW1JtGorn1b2jcBttbzCKEHerfad0BN4CWY4Cf6gGa51pQEocWqtRayGE7eNdwgNRGiO1ES(Wv)L0uNHhbotdseZOoOq6uhuicGwwnLDYEDnfhbxpob6e1uOBacKRdqN6GcrW0YQPq3aeixhGM6a7eHTPPiV(0eONkWfe9KbuHUbiqE9JQhAnFI3ONkW9gbrpvTxpB1FKyqIySE2N6dnE9JQpnb6PIJGRpbeghJk0nabY1u2j711u0OyczIs0PoOqxwTSAk0nabY1bOPoWoryBAkW9gbrpv8oMMFW6zR(qbQEwSQhGHMwTm5CPNqZjIkg5Ak7K96AkAuaimoQtDqHiG0YQPq3aeixhGM6a7eHTPPa3Bee9uX7yA(bRNT6dfO6zXQEsQhGHMwTm5CPNqZjIkg51pQEYRpnb6PcCbrpzavOBacKxpHAk7K96AkAumHmrj6uhezJRLvtHUbiqUoan1b2jcBttbU3ii6PI3X08dwpB1hkqAk7K96AQB0jI0mIjetiAPo1brwiTSAk0nabY1bOPoWoryBAQ0eONkocU(eqyCmQq3aeixtzNSxxtLsG7GjrH13Oo1PMIJ0gJi1YQdkKwwnLDYEDnfVJqg5PMcDdqGCDa6uhezAz1u2j711uN1JmG4e0i2hnf6gGa56a0PoicslRMcDdqGCDaAQvUMkIPMYozVUM62GTbiqn1TbNUbIAkaHXXj38dQPoWoryBAkYRhY4i9cjIQJeBJZucUWHk0nabYRFu9KxpKXr6fsevCdskrHbXjiYnHOxxHUbiqUMIJXdSLN96AkcENswMSEcuITX6LvcUWH1VW6zpdskrHbrzQpaHXX6zpZpy9d6us9xMggZ6dqSlV(fwVL1tqHvpjKfw9d6us9YcTwu)sxp7NPDcRpnirmJAQBtWGAQ0eONk6ggZjGyxUcDdqG86zXQ(OCuiMPbjIzubimoo5MFWq1ZM06jPEcQ(lV(0eONQeATyU0tit7k0nabYRNqDQd6sAz1uOBacKRdqtTY1urm1u2j711u3gSnabQPUn40nqutbimoo5MFqn1b2jcBttbzCKEHer1rITXzkbx4qf6gGa5AkogpWwE2RRPi4DkPEcuITX6LvcUWHYuFacJJ1ZEMFW6hib96tjy9am0013X657axM6h0PK6VmnmM1hGyxE9wwpzHvpjHcR(bDkPEzHwlQFPRN9Z0oH1VW6h0PK6dpXi6hS(aGOrA9ww)LcREsiOWQFqNsQxwO1I6x66z)mTty9PbjIzutDBcgutbWqtRosSnotj4chQ47aVEwSQpnb6PIUHXCci2LRq3aeiV(r1hLJcXmnirmJkaHXXj38dgQE2Kwpj1tw9xE9Pjqpvj0AXCPNqM2vOBacKxpH1ZIv9KxFAc0t1z4rGZLEkXsiYvOBacKx)O6JYrHyMgKiMrfGW44KB(bdvpBsRNK6Vu9xE9Pjqpvj0AXCPNqM2vOBacKxpH6uhuG0YQPq3aeixhGMALRPIyQPSt2RRPUnyBacutDBWPBGOMcqyCCYn)GAQdSte2MMcY4i9cjIkUbjLOWG4ee5Mq0RRq3aeixtXX4b2YZEDnfbVtj1ZEgKuIcdIYuFacJJ1ZEMFW6TSEFHGMO(0GeXS(ZY4z9dKGE9am00iVEGH1B1hXZ6CdoSEKMgpPm1VW6nXaBySElR)sYgw90lSEF9lN9qW17JM62emOMknb6PIUHXCci2LRq3aeiVEwSQNK6byOPvGyAGluUKn2rfJ86zXQ(0eONQeATyU0tit7k0nabYRNfR65iadnTcJr0p4eaIgPkg51ty9JQpkhfIzAqIygvacJJtU5hmu9SjTEsQNGQ)YRpnb6PkHwlMl9eY0UcDdqG86jSEwSQN86ttGEQ4i469rHUbiqE9JQpkhfIzAqIygvacJJtU5hmu9SjT(lPtDqeaTSAk0nabY1bOPw5AkigXutzNSxxtDBW2aeOM62Gt3arnfGW44KB(b1uhyNiSnnvAc0tfgJOFWjaensvOBacKx)O6p7k47axHXi6hCcarJufen(qnfhJhylp711uHFrS(WtmI(bRpaiAKwpasVqS(aeghRN9m)G13013z9DSE72AHbiW6nNx)stx)zxbFh46uhebtlRMcDdqGCDaAQvUMkIPMYozVUM62GTbiqn1Tjyqnf51NMa9uXrW17JcDdqG86hv)zxbFh4kqmnWfkxYg7OcIGw7X6dx9eG6hvpndCOIJ09PZ6zREcACn1TbNUbIAk57kAN4KEHtqmnDQd6YQLvtHUbiqUoan1kxtfXutzNSxxtDBW2aeOM62emOM62GTbiqfGW44KB(bRFu9KupndCy9HREcwGQ)YRpnb6PIUHXCci2LRq3aeiVE2N6jB86jutDBWPBGOMs(UI2joPx4eqyCCYn)G6uhebKwwnf6gGa56a0uRCnvetnLDYEDn1TbBdqGAQBtWGAQ0eONkocUEFuOBacKx)O6jV(0eONkar78jndCOcDdqG86hv)zxbFh4kCiobqdubrqR9y9HREsQN4HRaTXwp7t9KvpH1pQEAg4qfhP7tN1Zw9KnUM62Gt3arnL8DfTtCsVWjoeNaObQtDqHgxlRMcDdqGCDaAQvUMkIPMYozVUM62GTbiqn1TjyqnvAc0tf4cIEYaQq3aeiV(r1tE9am00kWfe9KbuXixtDBWPBGOMAG1z7eN0lCcUGONmG6uhuOqAz1uOBacKRdqtzNSxxtDmHyANSxFk6yQPeDmNUbIAQZUc(oW1PoOqKPLvtHUbiqUoan1b2jcBttbWqtROrXeybbmihe9uft7qA9sRpq1pQEsQhGHMw1GGRWYE9PXanfJ86zXQEYRhGHMwbIPbUq5s2yhvmYRNqnLDYEDnvkbUdMefwFJ6uhuicslRMcDdqGCDaAQdSte2MMknb6PIJGR3hf6gGa5AQyc7tQdkKMYozVUMcY4t7K96trhtnLOJ50nqutXrW17Jo1bf6sAz1uOBacKRdqtzNSxxtbz8PDYE9POJPMs0XC6giQP8fcAcDQtnfhbxVpAz1bfslRMcDdqGCDaAQdSte2MMknb6PIXbwgNppsSnQq3aeiV(r1dWqtRyCGLX5ZJeBJkg51pQEsQ)iXGeXy9sRNS6zXQEsQhAnFI3ONkW9gbrpvTxpB1hA86hvp0A(eVrpvgNhvTxpB1hA86jSEc1u2j711u0OyczIs0PoiY0YQPq3aeixhGM6a7eHTPPUnyBacubimoo5MFqnLDYEDnfhTuYmoar56uhebPLvtHUbiqUoan1b2jcBttzNSVXj6iyJX6zREogBiYNPbjIzSEwSQhAnFI3ONkJZJQ2RNT6dnUMYozVUMIOW6BCMiOCmM6uh0L0YQPq3aeixhGM6a7eHTPPoRZz6ufri0sKpjkS(gvOBacKx)O6p7k47axHdXjaAGkicAThRpC1taQFu9KxpadnTcetdCHYLSXoQyKx)O6jVEocWqtRWXkFJiFoyzCUIrUMYozVUMkLa3btIcRVrDQdkqAz1uOBacKRdqtDGDIW20u2j7BCIoc2ySE2QNJXgI8zAqIygRNfR6HwZN4n6PY48OQ96zREYcu9JQNK6jV(Bd2gGavmrCIdXjaAGtAg4W5zDEN961ZIv9r5OqmtdseZy9SvFO6zXQEAg4W6dx9eSXRNqnLDYEDnfoeNaObQtDqeaTSAk0nabY1bOPoWoryBAQBd2gGavacJJtU5hS(r1tE9NDf8DGRaX0axOCjBSJkiA8H1pQEsQ)SRGVdCfoeNaObQGiO1ESE2Qpq1ZIv9Kup0A(eVrpvgNhvTxpB1BNSxFE2vW3bE9JQhAnFI3ONkJZJQ2RpC1twGQNW6jutzNSxxtbimoo5MFqDQdIGPLvtHUbiqUoan1b2jcBttrE9am00QgeCfw2RpngOPyKRPSt2RRPAqWvyzV(0yGMo1bDz1YQPq3aeixhGM6a7eHTPPiV(Bd2gGavY3v0oXj9cNacJJtU5hutzNSxxtzU3sAHL966uhebKwwnf6gGa56a0uhyNiSnnfndCOIJ09PZ6ztA9xACnLDYEDnfnkaegh1PoOqJRLvtzNSxxtHXi6hCcarJunf6gGa56a0PoOqH0YQPq3aeixhGM6a7eHTPPiV(Bd2gGavY3v0oXj9cNacJJtU5hS(r1tE93gSnabQKVRODIt6foXH4eanqnLDYEDn1rITXzmHnPOo1bfImTSAk0nabY1bOPoWoryBAQ0eONkocU(eqyCmQq3aeiV(r1tE9NDf8DGRWH4eanqfen(W6hvpj1FKyqIySEP1tw9Syvpj1dTMpXB0tf4EJGONQ2RNT6dnE9JQhAnFI3ONkJZJQ2RNT6dnE9ewpHAk7K96AkAumHmrj6uhuicslRMcDdqGCDaAk7K96AkocUECc0jQPoWoryBAkiJJ0lKiQayGE7eNdwgNRq3aeiV(r1ZragAAfad0BN4CWY4CfebT2J1hU6VKM6m8iWzAqIyg1bfsN6GcDjTSAk0nabY1bOPoWoryBAkYRpnb6PIJGRpbeghJk0nabYRFu9r5OqmtdseZy9SvFO6hvpj1FKyqIySEP1tw9Syvpj1dTMpXB0tf4EJGONQ2RNT6dnE9JQhAnFI3ONkJZJQ2RNT6dnE9ewpHAk7K96AkAumHmrj6uhuOaPLvtzNSxxtXrW1JtGornf6gGa56a0PoOqeaTSAk0nabY1bOPoWoryBAkagAA1YKZLEcnNiQyKRPSt2RRPsjWDWKOW6BuN6GcrW0YQPq3aeixhGM6a7eHTPPa3Bee9uX7yA(bRNT6dfO6zXQEagAA1YKZLEcnNiQyKRPSt2RRPOrXeYeLOtDqHUSAz1uOBacKRdqtDGDIW20uG7ncIEQ4Dmn)G1Zw9HcKMYozVUM6gDIinJycXeIwQtDqHiG0YQPq3aeixhGM6a7eHTPPstGEQ4i46taHXXOcDdqGCnLDYEDnvkbUdMefwFJ6uNAQZUc(oW1YQdkKwwnf6gGa56a0uhyNiSnnf51NMa9uXrW17JcDdqG86hv)zxbFh4kCiobqdubrqR9y9SvpzJx)O6jPEYR)S3OBEQUrpLmewplw1tE98nvX2PzetaO5Cv2hsBNy9ewplw1t3eLKticAThRpC1twG0u2j711uGyAGluUKn2rDQdImTSAk0nabY1bOPoWoryBAQ0eONkocUEFuOBacKx)O6jP(ZUc(oWv4qCcGgOcIGw7X6zREYgV(r1ts9Kx)TbBdqGkaHXXj38dwplw1F2vW3bUcqyCCYn)GkicAThRNT6jE4kqBS1ty9ew)O6jPEYR)S3OBEQUrpLmewplw1tE98nvX2PzetaO5Cv2hsBNy9ewplw1t3eLKticAThRpC1twG0u2j711uGyAGluUKn2rDQdIG0YQPq3aeixhGM6a7eHTPPayOPvGyAGluUKn2rfebT2J1Zw9KfO6zXQEGngRFu90nrj5eIGw7X6dx9eGX1u2j711uY3SxxN6GUKwwnf6gGa56a0uCmEGT8SxxtXEiTXiY6zIy9DIG1lwI9rtDGDIW20u3gSnabQsy7KI5mo0pZOyZ6LwFO6hvpj1dWqtRaX0axOCjBSJkg51ZIv9Kup51NMa9uXrW17JcDdqG86hv)zxbFh4kqmnWfkxYg7OcIGw7X6zREsQNUjkjNqe0ApwF4c)RpHTtkMQmK6SRGVdCfNbAzVE9xupz1ty9ewplw1t3eLKticAThRpCsRNSXRNW6zXQEsQ)2GTbiqvcBNumNXH(zgfBwV06jR(r1tE9jSDsXuLKPo7k47axbrJpSEcRNfR6jV(Bd2gGavjSDsXCgh6NzuSPMkk2mQPsy7KIzinLDYEDnvcBNumdPtDqbslRMcDdqGCDaAk7K96AQe2oPysMM6a7eHTPPUnyBacuLW2jfZzCOFMrXM1lTEYQFu9KupadnTcetdCHYLSXoQyKxplw1ts9KxFAc0tfhbxVpk0nabYRFu9NDf8DGRaX0axOCjBSJkicAThRNT6jPE6MOKCcrqR9y9Hl8V(e2oPyQsYuNDf8DGR4mql71R)I6jREcRNW6zXQE6MOKCcrqR9y9HtA9KnE9ewplw1ts93gSnabQsy7KI5mo0pZOyZ6LwFO6hvp51NW2jftvgsD2vW3bUcIgFy9ewplw1tE93gSnabQsy7KI5mo0pZOytnvuSzutLW2jftY0PoicGwwnf6gGa56a0uhyNiSnnf51Z3ufBNMrmbGMZvzFiTDIAk7K96AQy70mIja0CUo1brW0YQPq3aeixhGM6a7eHTPPiV(0eONkocUEFuOBacKx)O6jV(Bd2gGavdSoBN4KEHtWfe9KbS(r1tE93gSnabQKVRODIt6fobX0QNfR6byOPv0mWEzItIw4fuXixtzNSxxtLsWPegp1PoOlRwwnf6gGa56a0uhyNiSnnfj1BNSVXj6iyJX6zREogBiYNPbjIzSEwSQhAnFI3ONkJZJQ2RNT6jOXRNqnLDYEDnfkggBZNC8aruN6utjhINfeWsTS6GcPLvtzNSxxtbSzkq(Kwydr(G2joZDSTRPq3aeixhGo1brMwwnf6gGa56a0uRCnvetnLDYEDn1TbBdqGAQBtWGAQqAQdSte2MMkHTtkMQmKsIfNmrCcWqtx)O6jPEYRpHTtkMQKmLelozI4eGHMUEwSQpHTtkMQmK6SRGVdCfNbAzVE9SjT(e2oPyQsYuNDf8DGR4mql71RNqn1TbNUbIAQe2oPyoJd9Zmk2uN6GiiTSAk0nabY1bOPw5AQiMAk7K96AQBd2gGa1u3MGb1uKPPoWoryBAQe2oPyQsYusS4KjItagA66hvpj1tE9jSDsXuLHusS4KjItagA66zXQ(e2oPyQsYuNDf8DGR4mql71RNT6ty7KIPkdPo7k47axXzGw2RxpHAQBdoDde1ujSDsXCgh6NzuSPo1bDjTSAk0nabY1bOPw5AQiMAk7K96AQBd2gGa1u3MGb1uPjqpvaI25tAg4qf6gGa51pQEsQhY4i9cjIkUbjLOWG4ee5Mq0RRq3aeiVEwSQpnb6PIJGRpbeghJk0nabYRNqnfhJhylp711uHFrS(WZqS(aqdSElRxSdQ)YWahw)GoLuFaI251FzyGdR)SGaTJ86h0PK6XoLGW6zpdskrHbX6xy9ShcUE9bimog1u3gC6giQPyI4ehIta0aN0mWHZZ68o711Po1Po1Pwd]] )


end
