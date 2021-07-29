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


    spec:RegisterPack( "Havoc", 20210729.1, [[daLDtbqievlcarEerv1LaqOnjf9jbQrHiofcAvOOuELGYSisUfcu2fj)cagMuIJjildr5zaOMgcW1iQY2qa5BcQ04qaLZHavRdffZtqv3Ji2hI0)aqkhuqfzHevEicKjIIQUOGkSraK8rIQsnsuuQojcOALa0mrrLBcGG2Pa5NaivdvqfLLsuv8uKmvIuxfar9vuuYyLsYEj1FLQbRQdtzXk1JvYKr1LH2ms9zeA0eLtRy1aiWRrrMnHBd0UP63QmCbCCIQswoONl00fDDuA7a67sHXlLuNxk16fur18rH9lzDiT0AkULOoiYAHSqTeUKrWvTqWdfUeabxtLTdGAQa2IjJiQPCde1um7gWBPPcyTfNX1sRPIhlCHAkQbKvy5Cobbn6utTzhrsG76TMIBjQdISwilulHlzeCvle8qHBleCnvmaU0bjVWnC1uYgohD9wtXX4stX8i451ZSZ6jcRNz3aERcqazDSEYi4svpzTqwOcWcqcsM5eXiZuasWQhGqmnWdgq2fNy9MZRpC2LZ51ZgnIy9aK2i9bX6PhIYY6rNhbivV4ioR6noabSXe51Nx9wGaI21FUOD95v)(IX6PhIYYOstfaE0Ja1uYV8xpZJGNxpZoRNiSEMDd4TkaLF5VEazfTRNmcUu1twlKfQaSau(L)6jizMteJmtbO8l)1tWQhGqmnWdgq2fNy9MZRpC2LZ51ZgnIy9aK2i9bX6PhIYY6rNhbivV4ioR6noabSXe51Nx9wGaI21FUOD95v)(IX6PhIYYOQaSa0w5CEufaIRdCBPK9LPa5DAH1g5ngNypVwpEbOTY58Okaexh42YWKaaGgCSTaLYnquschNjm7X2(QhfxkfqtWIscj1qljHJZeMQqkzwSZgX(MLMUjjKNWXzctfzkzwSZgX(MLMMbJeootyQcPw3j4xdxXzHwoNtQKeootyQitTUtWVgUIZcTCoNWcqBLZ5rvaiUoWTLHjbaan4yBbkLBGOKeooty2JT9vpkUukGMGfLqMudTKeootyQitjZID2i23S00njH8eootyQcPKzXoBe7BwAAgms44mHPIm16ob)A4kol0Y5Cst44mHPkKADNGFnCfNfA5CoHfGYF9aKJy9HJ2y9YHgy9wwV4AupaflSD9nMuw9YjgNxpaflSD9RdCpoYRVXKYQhNugcRN5nitefgeR)G1Z8i451lNW4ySa0w5CEufaIRdCBzysaaqdo2wGs5gikHnIDSn23Ob2PzHT7RZ5toNlfqtWIsstGEQ2IX5DAwyBf62wG8MKazDK(Gerf3GmruyqSdICtiMZzWinb6PIJGN33cJJrf62wGCclalalaLF5V(WrRXfBI86rGiSD95aI1NYW6TvEW6Ny9gqBe2wGQcqBLZ5rj8jczdKfG2kNZJHjbaRZJSGyh0ioRcq5x(RNzH1Zpp4SE(vFkBI1NgKiM1hBybcmoX6ZRElqar76LJf6JtSEM1X68cq5x(R3w5CEmmjaaIPbjIz3yZRBzAlMKsmo2xCjHKknirm7dTeWXzgoUzPPvBwOpoXEJJ15kicAJhLAOLazDK(Ger1Mf6JtS34yDEZ0eONkocEEFlmogvOBBbYlaL)6zwtk7yZ6jiz2fRxAz4bBx)bRN5nitefgeLQE5eghRN5nFH13ysz1dqnWywVCI741FW6TSEaoS6jHSWQVXKYQxAOnI6p66LpSJty9PbjIzSa0w5CEmmjaaObhBlqPCdeLSfgh7CZxOudTeYHSosFqIOAjZUypLHhSDtYHSosFqIOIBqMikmi2brUjeZ5sb0eSOK0eONk6bgZ(wChxHUTfiNbJyaui6PbjIzuTfgh7CZxyisLqcatWstGEQsOnI(r3HSJRq32cKtybO8xpZAsz1tqYSlwV0YWd2wQ6LtyCSEM38fwFdzOxFkdRFZstx)eRNFnCPQVXKYQhGAGXSE5e3XR3Y6jlS6jjuy13ysz1ln0gr9hD9Yh2XjS(dwFJjLvF4igrFH1lhenMQ3Y6jGWQNeaoS6BmPS6LgAJO(JUE5d74ewFAqIyglaTvoNhdtcaaAWX2cuk3arjBHXXo38fk1qlbY6i9bjIQLm7I9ugEW2sb0eSOKnlnTAjZUypLHhSTIFnCgmstGEQOhym7BXDCf62wG8MXaOq0tdseZOAlmo25MVWqKkHeYiyPjqpvj0gr)O7q2XvOBBbYjKbdYttGEQwTxcSF0DzwcrUcDBlqEZyaui6PbjIzuTfgh7CZxyisLqcbqWstGEQsOnI(r3HSJRq32cKtybO8xpZAsz1Z8gKjIcdIsvVCcJJ1Z8MVW6TSE)GGMO(0GeXS(1X6z9nKHE9BwAAKx)UD9w9rCDo3GTRhPPXvkv9hSEt0WAhR3Y6jaPdRE6dwVFobJ5rWZNvbOTY58yysaaqdo2wGs5gikzlmo25MVqPgAjqwhPpiruXnitefge7Gi3eI5CPaAcwusAc0tf9aJzFlUJRq32cKZGbjBwAAfiMg4bdi7ItuXgGbJ0eONQeAJOF0Di74k0TTa5myWXnlnTcJr0xyFdrJjfBacBgdGcrpnirmJQTW4yNB(cdrQesaycwAc0tvcTr0p6oKDCf62wGCczWG80eONkocE(SuOBBbYBgdGcrpnirmJQTW4yNB(cdrQecOau(RhGCeRpCeJOVW6LdIgt1Vr6dI1lNW4y9mV5lS(HU(jRFI1BaTryBbwV586pA66x3j4xdVa0w5CEmmjaaObhBlqPCdeLSfgh7CZxOuxajqmIPudTK0eONkmgrFH9nenMuOBBbYBUUtWVgUcJr0xyFdrJjfenE7cqBLZ5XWKaaGgCSTaLYnqusG7eJtStFWoiMMuanblkH80eONkocE(SuOBBbYBUUtWVgUcetd8GbKDXjQGiOnEm8eOM0SW2kospRjjfGBPa0w5CEmmjaaObhBlqPCdeLe4oX4e70hSVfgh7CZxOuanblkbObhBlq1wyCSZnFHnjHMf2o8HR8iyPjqpv0dmM9T4oUcDBlqoZgzTqybOTY58yysaaqdo2wGs5gikjWDIXj2PpyhBJ9nAGsb0eSOK0eONkocE(SuOBBbYBsEAc0t1wmoVtZcBRq32cK3CDNGFnCf2g7B0avqe0gpgEsiU4kqR1mBKrytAwyBfhPN1KKswlfG2kNZJHjbaan4yBbkLBGOKg2KJtStFWo4bIEYckfqtWIsstGEQapq0twqf62wG8MKVzPPvGhi6jlOInqbOTY58yysaWYeIUTY58UyIPuUbIsw3j4xdVa0w5CEmmjaiLbVgDIcBaIsn0s2S00kAu03h42GCq0tvmTftsKxts2S00Qbe8ewoN3nwOPydWGb5BwAAfiMg4bdi7ItuXgGWcqBLZ5XWKaaiR3TvoN3ftmLYnquchbpFwsft4SsjHKAOLKMa9uXrWZNLcDBlqEbOTY58yysaaK172kNZ7IjMs5gikXpiOjkalaTvoNhvR7e8RHlbetd8GbKDXjk1qlH80eONkocE(SuOBBbYBUUtWVgUcBJ9nAGkicAJhjLSwAsc5Rdi6MNkGONYAdvOBBbYzWGC(LQ440SI(gAoxLZIPXjsidg0drzzhIG24XWtM8kaTvoNhvR7e8RHhMeaaIPbEWaYU4eLAOLKMa9uXrWZNLcDBlqEtsw3j4xdxHTX(gnqfebTXJKswlnjHCGgCSTavBHXXo38fYGX6ob)A4QTW4yNB(cvqe0gpskXfxbATMqcBsc5Rdi6MNkGONYAdvOBBbYzWGC(LQ440SI(gAoxLZIPXjsidg0drzzhIG24XWtM8kaTvoNhvR7e8RHhMeae4Y5CPgAjBwAAfiMg4bdi7ItubrqB8iPKjpgm2xm2KEikl7qe0gpgEculfGYF9mpsBSISE2iw)Kiy9IJ4SkaTvoNhvR7e8RHhMeaWgX(KiyuQO4YOKeootygsQHwcqdo2wGQeooty2JT9vpkUusOMKSzPPvGyAGhmGSlorfBagmiH80eONkocE(SuOBBbYBUUtWVgUcetd8GbKDXjQGiOnEKusOhIYYoebTXJKcqlHJZeMQqQ1Dc(1WvCwOLZ5aejJqczWGEikl7qe0gpgEjK1cHmyqcqdo2wGQeooty2JT9vpkUucznjpHJZeMkYuR7e8RHRGOXBtidgKd0GJTfOkHJZeM9yBF1JIllaTvoNhvR7e8RHhMeaWgX(KiyuQO4YOKeootysMudTeGgCSTavjCCMWShB7REuCPeYAsYMLMwbIPbEWaYU4evSbyWGeYttGEQ4i45ZsHUTfiV56ob)A4kqmnWdgq2fNOcIG24rsjHEikl7qe0gpskaTeootyQitTUtWVgUIZcTCohGizesidg0drzzhIG24XWlHSwiKbdsaAWX2cuLWXzcZESTV6rXLsc1K8eootyQcPw3j4xdxbrJ3MqgmihObhBlqvchNjm7X2(QhfxwaARCopQw3j4xdpmjaioonROVHMZLAOLqo)svCCAwrFdnNRYzX04elaTvoNhvR7e8RHhMeaKYWUmwpLAOLqEAc0tfhbpFwk0TTa5njhObhBlqvdBYXj2Ppyh8arpzbBsoqdo2wGQa3jgNyN(GDqmngm2S00kAw4CSXorlCoQyduaARCopQw3j4xdpmjaafTJJ5DoUGik1qlHeBLdqSJocoyKuoghiY7PbjIzKbdOn8oce9uzCEunoPaClewawaARCopQ4i45Zscnk6q2OmPgAjPjqpvS((yDEFjZUOcDBlqEZnlnTI13hRZ7lz2fvSbAsYsMbjIrjKXGbjqB4Dei6Pc8aIGONQXjnulnH2W7iq0tLX5r14KgQfcjSa0w5CEuXrWZNvysaahTuwp2aXasn0saAWX2cuTfgh7CZxybOTY58OIJGNpRWKaaIcBaI9ebdGXuQHwITYbi2rhbhmskhJde590GeXmYGb0gEhbIEQmopQgN0qTuaARCopQ4i45ZkmjaiLbVgDIcBaIsn0swNZzNufri0sK3jkSbiQq32cK3CDNGFnCf2g7B0avqe0gpgEcutY3S00kqmnWdgq2fNOInqtY54MLMwHToWfrEVXX6CfBGcqBLZ5rfhbpFwHjbayBSVrduQHwITYbi2rhbhmskhJde590GeXmYGb0gEhbIEQmopQgNuYKxtsihObhBlqfBe7yBSVrdStZcB3xNZNCoNbJyaui6PbjIzK0qmyqZcBh(WTfclaTvoNhvCe88zfMeaSfgh7CZxOudTeGgCSTavBHXXo38f2K81Dc(1WvGyAGhmGSlorfenE7MKSUtWVgUcBJ9nAGkicAJhjvEmyqc0gEhbIEQmopQgN01Dc(1WBcTH3rGONkJZJQXdpzYJqclaTvoNhvCe88zfMeamGGNWY58UXcnPgAjKVzPPvdi4jSCoVBSqtXgOa0w5CEuXrWZNvysaG5(iBewoNl1qlHCGgCSTavbUtmoXo9b7BHXXo38fwaARCopQ4i45ZkmjaGgfBHXrPgAj0SW2kospRjjvcb0sbOTY58OIJGNpRWKaamgrFH9nenMkaTvoNhvCe88zfMeaSKzxSht4Wek1qlHCGgCSTavbUtmoXo9b7BHXXo38f2KCGgCSTavbUtmoXo9b7yBSVrdSa0w5CEuXrWZNvysaank6q2OmPgAjPjqpvCe88(wyCmQq32cK3K81Dc(1WvyBSVrdubrJ3UjjlzgKigLqgdgKaTH3rGONkWdicIEQgN0qT0eAdVJarpvgNhvJtAOwiKWcqBLZ5rfhbpFwHjbaCe88yFpjk1Q9sG90GeXmkjKudTeiRJ0hKiQ2SqFCI9ghRZBYXnlnTAZc9Xj2BCSoxbrqB8y4jGcqBLZ5rfhbpFwHjba0OOdzJYKAOLqEAc0tfhbpVVfghJk0TTa5nJbqHONgKiMrsd1KKLmdseJsiJbdsG2W7iq0tf4bebrpvJtAOwAcTH3rGONkJZJQXjnulesybOTY58OIJGNpRWKaaocEESVNelaTvoNhvCe88zfMeaKYGxJorHnarPgAjBwAA1XM9JUdnNiQyduaARCopQ4i45ZkmjaGgfDiBuMudTeWdicIEQ4tmnFHKgsEmySzPPvhB2p6o0CIOInqbOTY58OIJGNpRWKaaGOtePzfDiMq0sPgAjGhqee9uXNyA(cjnK8kaTvoNhvCe88zfMeaKYGxJorHnarPgAjPjqpvCe88(wyCmQq32cKxawaARCopQ8dcAcjarNisZk6qmHOLsn0sstGEQapq0twqf62wG8MBwAAvaigWGixXVgEZCarsdvaARCopQ8dcAIWKaaAu0HSrzsn0sizZstRy99X68(sMDrfBagmaAWX2cu1WMCCID6d2bpq0twWMKqEAc0tfRVpwN3xYSlQq32cKZGb5R7e8RHRgqWty5CE3yHMcIgVnHe2KKLmdseJsiJbdsG2W7iq0tf4bebrpvJtAOwAcTH3rGONkJZJQXjnulesybOTY58OYpiOjctcaOrrFBqOreLAOLyRCaID0rWbJKYX4arEpnirmJmyaTH3rGONkJZJQXjfGBPa0w5CEu5he0eHjbaC0sz9ydedi1qlbObhBlq1wyCSZnFHfG2kNZJk)GGMimjayabpHLZ5DJfAsn0siFZstRgqWty5CE3yHMInqbOTY58OYpiOjctcaikSbi2temagtPgAjKd0GJTfOQHn54e70hSdEGONSGnjXw5ae7OJGdgjLJXbI8EAqIygzWaAdVJarpvgNhvJtAOwiSa0w5CEu5he0eHjbaPm41OtuydquQHwY6Co7KQicHwI8orHnarf62wG8MR7e8RHRW2yFJgOcIG24XWtGAs(MLMwbIPbEWaYU4evSbAsoh3S00kS1bUiY7nowNRyduaARCopQ8dcAIWKaaSn23Obk1qlHCGgCSTavnSjhNyN(GDWde9KfSjj2khGyhDeCWiPCmoqK3tdseZidgqB4Dei6PY48OACsdjVMKqoqdo2wGk2i2X2yFJgyNMf2UVoNp5CodgXaOq0tdseZiPHyWGMf2o8HBlesybOTY58OYpiOjctca2cJJDU5luQHwcqdo2wGQTW4yNB(claTvoNhv(bbnrysaank2cJJsn0sOzHTvCKEwtsQecOLcqBLZ5rLFqqteMeaGXi6lSVHOXubOTY58OYpiOjctcam3hzJWY5CPgAjKKMa9uXrWZ7BHXXOcDBlqodgKd0GJTfOQHn54e70hSdEGONSGmyqZcBR4i9SMm8aClmySzPPvGyAGhmGSlorfebTXJHxEe2KCGgCSTavbUtmoXo9b7BHXXo38fwaARCopQ8dcAIWKaGLm7I9ychMqPgAjKKMa9uXrWZ7BHXXOcDBlqodgKd0GJTfOQHn54e70hSdEGONSGmyqZcBR4i9SMm8aCle2KCGgCSTavbUtmoXo9b7GyAnjhObhBlqvG7eJtStFW(wyCSZnFHfG2kNZJk)GGMimjaaBJ9nAGsn0sstGEQ2IX5DAwyBf62wG8MqB4Dei6PY48OACsx3j4xdVa0w5CEu5he0eHjbaCe88yFpjk1Q9sG90GeXmkjKudTeiRJ0hKiQ2SqFCI9ghRZBYXnlnTAZc9Xj2BCSoxbrqB8y4jGcqBLZ5rLFqqteMeaWrWZJ99KybOTY58OYpiOjctcaOrrhYgLj1qlH80eONkWde9KfuHUTfiVj0gEhbIEQapGii6PACsxYmirmYSfQLMPjqpvCe88(wyCmQq32cKxaARCopQ8dcAIWKaaAuSfghLAOLaEarq0tfFIP5lK0qYJbJnlnT6yZ(r3HMtevSbkaTvoNhv(bbnrysaank6q2OmPgAjGhqee9uXNyA(cjnK8yWGKnlnT6yZ(r3HMtevSbAsEAc0tf4bIEYcQq32cKtybOTY58OYpiOjctcaaIorKMv0HycrlLAOLaEarq0tfFIP5lK0qYRa0w5CEu5he0eHjbaPm41OtuydquQHwsAc0tfhbpVVfghJk0TTa5AkGimoNRdISwiluleiYiW0unmOpoXOMIzfojFcIapi5BMP(6Lwgw)ag4Gz90hS(G9dcAIGRhIYxSde51hpqSEJnpqlrE9lzMteJQcqMBCS(qYJzQNGohictKxFWqwhPpiru1QGRpV6dgY6i9bjIQwPq32cKhC9KeQ1eQkalazwHtYNGiWds(MzQVEPLH1pGboywp9bRpyosBSIm46HO8f7arE9XdeR3yZd0sKx)sM5eXOQaK5ghRhGzM6jOZbIWe51hmK1r6dsevTk46ZR(GHSosFqIOQvk0TTa5bxpjHAnHQcqMBCSEaMzQNGohictKxFWqwhPpiru1QGRpV6dgY6i9bjIQwPq32cKhC9wwF4aGoZvpjHAnHQcqMBCSEcGzQNGohictKxFWqwhPpiru1QGRpV6dgY6i9bjIQwPq32cKhC9wwF4aGoZvpjHAnHQcqMBCSE5Xm1tqNdeHjYRpyiRJ0hKiQAvW1Nx9bdzDK(GervRuOBBbYdUElRpCaqN5QNKqTMqvbybiZkCs(eebEqY3mt91lTmS(bmWbZ6Ppy9bhaIRdCBzW1dr5l2bI86JhiwVXMhOLiV(LmZjIrvbiZnowpzmt9e05aryI86doHJZeMQqQwfC95vFWjCCMWuLHuTk46jHSwtOQaK5ghRNmMPEc6CGimrE9bNWXzctfzQwfC95vFWjCCMWuLKPAvW1tczTMqvbiZnowpaZm1tqNdeHjYRp4eootyQcPAvW1Nx9bNWXzctvgs1QGRNeYAnHQcqMBCSEaMzQNGohictKxFWjCCMWurMQvbxFE1hCchNjmvjzQwfC9KqwRjuvaYCJJ1tamt9e05aryI86dgY6i9bjIQwfC95vFWqwhPpiru1kf62wG8GRNKqTMqvbybiZkCs(eebEqY3mt91lTmS(bmWbZ6Ppy9bVUtWVgEW1dr5l2bI86JhiwVXMhOLiV(LmZjIrvbiZnowFiMPEc6CGimrE9bVoGOBEQALcDBlqEW1Nx9bVoGOBEQAvW1tsOwtOQaK5ghRNmMPEc6CGimrE9bVoGOBEQALcDBlqEW1Nx9bVoGOBEQAvW1tsOwtOQaK5ghRNayM6jOZbIWe51tnGeu9X2EATUEaI1Nx9mhRvpFaoX586Vai0YdwpjaGW6jjuRjuvaYCJJ1tamt9e05aryI86doHJZeMQqQwfC95vFWjCCMWuLHuTk46jjuRjuvaYCJJ1tamt9e05aryI86doHJZeMkYuTk46ZR(Gt44mHPkjt1QGRNKqTMqvbiZnowV8yM6jOZbIWe51tnGeu9X2EATUEaI1Nx9mhRvpFaoX586Vai0YdwpjaGW6jjuRjuvaYCJJ1lpMPEc6CGimrE9bNWXzctvivRcU(8Qp4eootyQYqQwfC9KeQ1eQkazUXX6LhZupbDoqeMiV(Gt44mHPImvRcU(8Qp4eootyQsYuTk46jjuRjuvawaYScNKpbrGhK8nZuF9sldRFadCWSE6dwFWCe88zfC9qu(IDGiV(4bI1BS5bAjYRFjZCIyuvaYCJJ1hcGzM6jOZbIWe51hmK1r6dsevTk46ZR(GHSosFqIOQvk0TTa5bxpjHAnHQcWcqcCWahmrE9YREBLZ51lMygvfGAkXeZOwAnLFqqtOLwhuiT0Ak0TTa5A50ul4KiCmnvAc0tf4bIEYcQq32cKxFZ63S00QaqmGbrUIFn86BwFoGy9KwFinLTY5Cnfq0jI0SIoetiAPo1brMwAnf62wGCTCAQfCseoMMIK63S00kwFFSoVVKzxuXgOEgmQhObhBlqvdBYXj2Ppyh8arpzbRVz9Kup51NMa9uX67J159Lm7Ik0TTa51ZGr9Kx)6ob)A4Qbe8ewoN3nwOPGOXBxpH1ty9nRNK6xYmirmwVK6jREgmQNK6H2W7iq0tf4bebrpvJxpP1hQL6Bwp0gEhbIEQmopQgVEsRpul1ty9eQPSvoNRPOrrhYgLPtDqaSwAnf62wGCTCAQfCseoMMYw5ae7OJGdgRN065yCGiVNgKiMX6zWOEOn8oce9uzCEunE9Kwpa3IMYw5CUMIgf9TbHgruN6GiaT0Ak0TTa5A50ul4KiCmnfqdo2wGQTW4yNB(c1u2kNZ1uC0sz9ydedOtDqYtlTMcDBlqUwon1cojchttrE9BwAA1acEclNZ7gl0uSb0u2kNZ1udi4jSCoVBSqtN6GiqAP1uOBBbY1YPPwWjr4yAkYRhObhBlqvdBYXj2Ppyh8arpzbRVz9KuVTYbi2rhbhmwpP1ZX4arEpnirmJ1ZGr9qB4Dei6PY48OA86jT(qTupHAkBLZ5AkIcBaI9ebdGXuN6GcxT0Ak0TTa5A50ul4KiCmn16Co7KQicHwI8orHnarf62wG86Bw)6ob)A4kSn23ObQGiOnES(WxpbQ(M1tE9BwAAfiMg4bdi7ItuXgO(M1tE9CCZstRWwh4IiV34yDUInGMYw5CUMkLbVgDIcBaI6uhebMwAnf62wGCTCAQfCseoMMI86bAWX2cu1WMCCID6d2bpq0twW6Bwpj1BRCaID0rWbJ1tA9CmoqK3tdseZy9myup0gEhbIEQmopQgVEsRpK8QVz9Kup51d0GJTfOInIDSn23Ob2PzHT7RZ5toNxpdg1hdGcrpnirmJ1tA9HQNbJ6PzHTRp81hUTupH1tOMYw5CUMcBJ9nAG6uhebxlTMcDBlqUwon1cojchttb0GJTfOAlmo25MVqnLTY5Cn1wyCSZnFH6uhuOw0sRPq32cKRLttTGtIWX0u0SW2kospRjRNuj1taTOPSvoNRPOrXwyCuN6GcfslTMYw5CUMcJr0xyFdrJjnf62wGCTC6uhuiY0sRPq32cKRLttTGtIWX0uKuFAc0tfhbpVVfghJk0TTa51ZGr9Kxpqdo2wGQg2KJtStFWo4bIEYcwpdg1tZcBR4i9SMS(Wxpa3s9myu)MLMwbIPbEWaYU4evqe0gpwF4RxE1ty9nRN86bAWX2cuf4oX4e70hSVfgh7CZxOMYw5CUMYCFKnclNZ1PoOqaSwAnf62wGCTCAQfCseoMMIK6ttGEQ4i459TW4yuHUTfiVEgmQN86bAWX2cu1WMCCID6d2bpq0twW6zWOEAwyBfhPN1K1h(6b4wQNW6Bwp51d0GJTfOkWDIXj2PpyhetR(M1tE9an4yBbQcCNyCID6d23cJJDU5lutzRCoxtTKzxSht4WeQtDqHiaT0Ak0TTa5A50ul4KiCmnvAc0t1wmoVtZcBRq32cKxFZ6H2W7iq0tLX5r141tA92kNZ7R7e8RHRPSvoNRPW2yFJgOo1bfsEAP1uOBBbY1YPPSvoNRP4i45X(EsutTGtIWX0uqwhPpiruTzH(4e7nowNRq32cKxFZ654MLMwTzH(4e7nowNRGiOnES(WxpbOPwTxcSNgKiMrDqH0PoOqeiT0AkBLZ5AkocEESVNe1uOBBbY1YPtDqHcxT0Ak0TTa5A50ul4KiCmnf51NMa9ubEGONSGk0TTa513SEOn8oce9ubEarq0t141tA9lzgKigRNzR(qTuFZ6ttGEQ4i459TW4yuHUTfixtzRCoxtrJIoKnktN6GcrGPLwtHUTfixlNMAbNeHJPPapGii6PIpX08fwpP1hsE1ZGr9BwAA1XM9JUdnNiQydOPSvoNRPOrXwyCuN6GcrW1sRPq32cKRLttTGtIWX0uGhqee9uXNyA(cRN06djV6zWOEsQFZstRo2SF0DO5erfBG6Bwp51NMa9ubEGONSGk0TTa51tOMYw5CUMIgfDiBuMo1brwlAP1uOBBbY1YPPwWjr4yAkWdicIEQ4tmnFH1tA9HKNMYw5CUMci6erAwrhIjeTuN6GilKwAnf62wGCTCAQfCseoMMknb6PIJGN33cJJrf62wGCnLTY5CnvkdEn6ef2ae1Po1uCK2yfPwADqH0sRPSvoNRP4teYgi1uOBBbY1YPtDqKPLwtzRCoxtTopYcIDqJ4S0uOBBbY1YPtDqaSwAnf62wGCTCAQlGMkIPMYw5CUMcObhBlqnfqd2Dde1uBHXXo38fQPwWjr4yAkYRhY6i9bjIQLm7I9ugEW2k0TTa513SEYRhY6i9bjIkUbzIOWGyhe5MqmNRq32cKRP4yCbNa5CUMIznPSJnRNGKzxSEPLHhSD9hSEM3GmruyquQ6LtyCSEM38fwFJjLvpa1aJz9YjUJx)bR3Y6b4WQNeYcR(gtkREPH2iQ)ORx(WooH1NgKiMrnfqtWIAQ0eONk6bgZ(wChxHUTfiVEgmQpgafIEAqIygvBHXXo38fgQEsLupj1dW1tWQpnb6PkH2i6hDhYoUcDBlqE9eQtDqeGwAnf62wGCTCAQlGMkIPMYw5CUMcObhBlqnfqd2Dde1uBHXXo38fQPwWjr4yAkiRJ0hKiQwYSl2tz4bBRq32cKRP4yCbNa5CUMIznPS6jiz2fRxAz4bBlv9YjmowpZB(cRVHm0RpLH1VzPPRFI1ZVgUu13ysz1dqnWywVCI741Bz9Kfw9KekS6BmPS6LgAJO(JUE5d74ew)bRVXKYQpCeJOVW6LdIgt1Bz9eqy1tcahw9nMuw9sdTru)rxV8HDCcRpnirmJAkGMGf1uBwAA1sMDXEkdpyBf)A41ZGr9Pjqpv0dmM9T4oUcDBlqE9nRpgafIEAqIygvBHXXo38fgQEsLupj1tw9eS6ttGEQsOnI(r3HSJRq32cKxpH1ZGr9KxFAc0t1Q9sG9JUlZsiYvOBBbYRVz9XaOq0tdseZOAlmo25MVWq1tQK6jPEcOEcw9Pjqpvj0gr)O7q2XvOBBbYRNqDQdsEAP1uOBBbY1YPPUaAQiMAkBLZ5AkGgCSTa1uany3nqutTfgh7CZxOMAbNeHJPPGSosFqIOIBqMikmi2brUjeZ5k0TTa5AkogxWjqoNRPywtkREM3GmruyquQ6LtyCSEM38fwVL17he0e1NgKiM1VowpRVHm0RFZstJ863TR3QpIRZ5gSD9innUsPQ)G1BIgw7y9wwpbiDy1tFW69ZjympcE(S0uanblQPstGEQOhym7BXDCf62wG86zWOEsQFZstRaX0apyazxCIk2a1ZGr9Pjqpvj0gr)O7q2XvOBBbYRNbJ654MLMwHXi6lSVHOXKInq9ewFZ6JbqHONgKiMr1wyCSZnFHHQNuj1ts9aC9eS6ttGEQsOnI(r3HSJRq32cKxpH1ZGr9KxFAc0tfhbpFwk0TTa513S(yaui6PbjIzuTfgh7CZxyO6jvs9eGo1brG0sRPq32cKRLttDb0uqmIPMYw5CUMcObhBlqnfqd2Dde1uBHXXo38fQPwWjr4yAQ0eONkmgrFH9nenMuOBBbYRVz9R7e8RHRWye9f23q0ysbrJ3wtXX4cobY5Cnfa5iwF4igrFH1lhenMQFJ0heRxoHXX6zEZxy9dD9tw)eR3aAJW2cSEZ51F001VUtWVgUo1bfUAP1uOBBbY1YPPUaAQiMAkBLZ5AkGgCSTa1uanblQPiV(0eONkocE(SuOBBbYRVz9R7e8RHRaX0apyazxCIkicAJhRp81tGQVz90SW2kospRjRN06b4w0uany3nqutf4oX4e70hSdIPPtDqeyAP1uOBBbY1YPPUaAQiMAkBLZ5AkGgCSTa1uanblQPaAWX2cuTfgh7CZxy9nRNK6PzHTRp81hUYREcw9Pjqpv0dmM9T4oUcDBlqE9mB1twl1tOMcOb7UbIAQa3jgNyN(G9TW4yNB(c1PoicUwAnf62wGCTCAQlGMkIPMYw5CUMcObhBlqnfqtWIAQ0eONkocE(SuOBBbYRVz9KxFAc0t1wmoVtZcBRq32cKxFZ6x3j4xdxHTX(gnqfebTXJ1h(6jPEIlUc0AD9mB1tw9ewFZ6PzHTvCKEwtwpP1twlAkGgS7giQPcCNyCID6d2X2yFJgOo1bfQfT0Ak0TTa5A50uxanvetnLTY5Cnfqdo2wGAkGMGf1uPjqpvGhi6jlOcDBlqE9nRN863S00kWde9KfuXgqtb0GD3arnvdBYXj2Ppyh8arpzb1PoOqH0sRPq32cKRLttzRCoxtTmHOBRCoVlMyQPetm7UbIAQ1Dc(1W1PoOqKPLwtHUTfixlNMAbNeHJPP2S00kAu03h42GCq0tvmTft1lPE5vFZ6jP(nlnTAabpHLZ5DJfAk2a1ZGr9Kx)MLMwbIPbEWaYU4evSbQNqnLTY5CnvkdEn6ef2ae1PoOqaSwAnf62wGCTCAQfCseoMMknb6PIJGNplf62wGCnvmHZk1bfstzRCoxtbz9UTY58UyIPMsmXS7giQP4i45ZsN6GcraAP1uOBBbY1YPPSvoNRPGSE3w5CExmXutjMy2Dde1u(bbnHo1PMIJGNplT06GcPLwtHUTfixlNMAbNeHJPPstGEQy99X68(sMDrf62wG86Bw)MLMwX67J159Lm7Ik2a13SEsQFjZGeXy9sQNS6zWOEsQhAdVJarpvGhqee9unE9KwFOwQVz9qB4Dei6PY48OA86jT(qTupH1tOMYw5CUMIgfDiBuMo1brMwAnf62wGCTCAQfCseoMMcObhBlq1wyCSZnFHAkBLZ5AkoAPSESbIb0PoiawlTMcDBlqUwon1cojchttzRCaID0rWbJ1tA9CmoqK3tdseZy9myup0gEhbIEQmopQgVEsRpulAkBLZ5AkIcBaI9ebdGXuN6GiaT0Ak0TTa5A50ul4KiCmn16Co7KQicHwI8orHnarf62wG86Bw)6ob)A4kSn23ObQGiOnES(WxpbQ(M1tE9BwAAfiMg4bdi7ItuXgO(M1tE9CCZstRWwh4IiV34yDUInGMYw5CUMkLbVgDIcBaI6uhK80sRPq32cKRLttTGtIWX0u2khGyhDeCWy9KwphJde590GeXmwpdg1dTH3rGONkJZJQXRN06jtE13SEsQN86bAWX2cuXgXo2g7B0a70SW29158jNZRNbJ6JbqHONgKiMX6jT(q1ZGr90SW21h(6d3wQNqnLTY5Cnf2g7B0a1PoicKwAnf62wGCTCAQfCseoMMcObhBlq1wyCSZnFH13SEYRFDNGFnCfiMg4bdi7ItubrJ3U(M1ts9R7e8RHRW2yFJgOcIG24X6jTE5vpdg1ts9qB4Dei6PY48OA86jTEBLZ591Dc(1WRVz9qB4Dei6PY48OA86dF9KjV6jSEc1u2kNZ1uBHXXo38fQtDqHRwAnf62wGCTCAQfCseoMMI863S00Qbe8ewoN3nwOPydOPSvoNRPgqWty5CE3yHMo1brGPLwtHUTfixlNMAbNeHJPPiVEGgCSTavbUtmoXo9b7BHXXo38fQPSvoNRPm3hzJWY5CDQdIGRLwtHUTfixlNMAbNeHJPPOzHTvCKEwtwpPsQNaArtzRCoxtrJITW4Oo1bfQfT0AkBLZ5AkmgrFH9nenM0uOBBbY1YPtDqHcPLwtHUTfixlNMAbNeHJPPiVEGgCSTavbUtmoXo9b7BHXXo38fwFZ6jVEGgCSTavbUtmoXo9b7yBSVrdutzRCoxtTKzxSht4WeQtDqHitlTMcDBlqUwon1cojchttLMa9uXrWZ7BHXXOcDBlqE9nRN86x3j4xdxHTX(gnqfenE76Bwpj1VKzqIySEj1tw9myupj1dTH3rGONkWdicIEQgVEsRpul13SEOn8oce9uzCEunE9KwFOwQNW6jutzRCoxtrJIoKnktN6GcbWAP1uOBBbY1YPPSvoNRP4i45X(EsutTGtIWX0uqwhPpiruTzH(4e7nowNRq32cKxFZ654MLMwTzH(4e7nowNRGiOnES(WxpbOPwTxcSNgKiMrDqH0PoOqeGwAnf62wGCTCAQfCseoMMI86ttGEQ4i459TW4yuHUTfiV(M1hdGcrpnirmJ1tA9HQVz9Ku)sMbjIX6Lupz1ZGr9Kup0gEhbIEQapGii6PA86jT(qTuFZ6H2W7iq0tLX5r141tA9HAPEcRNqnLTY5Cnfnk6q2OmDQdkK80sRPSvoNRP4i45X(EsutHUTfixlNo1bfIaPLwtHUTfixlNMAbNeHJPP2S00QJn7hDhAoruXgqtzRCoxtLYGxJorHnarDQdku4QLwtHUTfixlNMAbNeHJPPapGii6PIpX08fwpP1hsE1ZGr9BwAA1XM9JUdnNiQydOPSvoNRPOrrhYgLPtDqHiW0sRPq32cKRLttTGtIWX0uGhqee9uXNyA(cRN06djpnLTY5Cnfq0jI0SIoetiAPo1bfIGRLwtHUTfixlNMAbNeHJPPstGEQ4i459TW4yuHUTfixtzRCoxtLYGxJorHnarDQtn16ob)A4AP1bfslTMcDBlqUwon1cojchttrE9PjqpvCe88zPq32cKxFZ6x3j4xdxHTX(gnqfebTXJ1tA9K1s9nRNK6jV(1beDZtfq0tzTH1ZGr9Kxp)svCCAwrFdnNRYzX04eRNW6zWOE6HOSSdrqB8y9HVEYKNMYw5CUMcetd8GbKDXjQtDqKPLwtHUTfixlNMAbNeHJPPstGEQ4i45ZsHUTfiV(M1ts9R7e8RHRW2yFJgOcIG24X6jTEYAP(M1ts9Kxpqdo2wGQTW4yNB(cRNbJ6x3j4xdxTfgh7CZxOcIG24X6jTEIlUc0AD9ewpH13SEsQN86xhq0npvarpL1gwpdg1tE98lvXXPzf9n0CUkNftJtSEcRNbJ6PhIYYoebTXJ1h(6jtEAkBLZ5AkqmnWdgq2fNOo1bbWAP1uOBBbY1YPPwWjr4yAQnlnTcetd8GbKDXjQGiOnESEsRNm5vpdg1VVyS(M1tpeLLDicAJhRp81tGArtzRCoxtf4Y5CDQdIa0sRPq32cKRLttXX4cobY5CnfZJ0gRiRNnI1pjcwV4ioln1cojchttb0GJTfOkHJZeM9yBF1JIlRxs9HQVz9Ku)MLMwbIPbEWaYU4evSbQNbJ6jPEYRpnb6PIJGNplf62wG86Bw)6ob)A4kqmnWdgq2fNOcIG24X6jTEsQNEikl7qe0gpwpPa0QpHJZeMQmKADNGFnCfNfA5CE9aOEYQNW6jSEgmQNEikl7qe0gpwF4LupzTupH1ZGr9Kupqdo2wGQeooty2JT9vpkUSEj1tw9nRN86t44mHPkjtTUtWVgUcIgVD9ewpdg1tE9an4yBbQs44mHzp22x9O4snvuCzutLWXzcZqAkBLZ5AQeootygsN6GKNwAnf62wGCTCAkBLZ5AQeootysMMAbNeHJPPaAWX2cuLWXzcZESTV6rXL1lPEYQVz9Ku)MLMwbIPbEWaYU4evSbQNbJ6jPEYRpnb6PIJGNplf62wG86Bw)6ob)A4kqmnWdgq2fNOcIG24X6jTEsQNEikl7qe0gpwpPa0QpHJZeMQKm16ob)A4kol0Y586bq9KvpH1ty9myup9quw2HiOnES(WlPEYAPEcRNbJ6jPEGgCSTavjCCMWShB7REuCz9sQpu9nRN86t44mHPkdPw3j4xdxbrJ3UEcRNbJ6jVEGgCSTavjCCMWShB7REuCPMkkUmQPs44mHjz6uhebslTMcDBlqUwon1cojchttrE98lvXXPzf9n0CUkNftJtutzRCoxtfhNMv03qZ56uhu4QLwtHUTfixlNMAbNeHJPPiV(0eONkocE(SuOBBbYRVz9Kxpqdo2wGQg2KJtStFWo4bIEYcwFZ6jVEGgCSTavbUtmoXo9b7GyA1ZGr9BwAAfnlCo2yNOfohvSb0u2kNZ1uPmSlJ1tDQdIatlTMcDBlqUwon1cojchttrs92khGyhDeCWy9KwphJde590GeXmwpdg1dTH3rGONkJZJQXRN06b4wQNqnLTY5CnfkAhhZ7CCbruN6utfaIRdCBPwADqH0sRPSvoNRP2xMcK3PfwBK3yCI98A94Ak0TTa5A50PoiY0sRPq32cKRLttDb0urm1u2kNZ1uan4yBbQPaAcwutfstTGtIWX0ujCCMWuLHuYSyNnI9nlnD9nRNK6jV(eootyQsYuYSyNnI9nlnD9myuFchNjmvzi16ob)A4kol0Y586jvs9jCCMWuLKPw3j4xdxXzHwoNxpHAkGgS7giQPs44mHzp22x9O4sDQdcG1sRPq32cKRLttDb0urm1u2kNZ1uan4yBbQPaAcwutrMMAbNeHJPPs44mHPkjtjZID2i23S0013SEsQN86t44mHPkdPKzXoBe7BwA66zWO(eootyQsYuR7e8RHR4SqlNZRN06t44mHPkdPw3j4xdxXzHwoNxpHAkGgS7giQPs44mHzp22x9O4sDQdIa0sRPq32cKRLttDb0urm1u2kNZ1uan4yBbQPaAcwutLMa9uTfJZ70SW2k0TTa513SEsQhY6i9bjIkUbzIOWGyhe5MqmNRq32cKxpdg1NMa9uXrWZ7BHXXOcDBlqE9eQP4yCbNa5CUMcGCeRpC0gRxo0aR3Y6fxJ6bOyHTRVXKYQxoX486bOyHTRFDG7XrE9nMuw94KYqy9mVbzIOWGy9hSEMhbpVE5eghJAkGgS7giQPyJyhBJ9nAGDAwy7(6C(KZ56uN6utzSPSdQPOgqcsN6uRb]] )


end
