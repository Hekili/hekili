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


    spec:RegisterPack( "Havoc", 20210628, [[dafEtbqievlsQsvEerv1LKQuPnjv6tcuJcrCke0QikqVsqmluQUfcq7IKFbadtQIJjOwgI0ZaqMgcORru02KQu(MGKghrvPZruvyDiqnpbPUhrSpeL)HaihuqISqIkpebYejQIlkiHnIaWhjQkAKevP6KefWkbOzsuOBkvPI2Pa5NiaQHkirzPevjpfjtLO0vLQuvFLOGgRuLSxs9xPmyvDyklwPESsMmQUm0MrQpJqJMiDAfRwQsfEnkLzt42aTBQ(TkdxahNOkLLd65cnDrxhfBhqFxQy8aOoVuvRxqIQ5Js2VK1H1YQP4wI6GiThsd3tVrQ8vrka1tOsAOQPY(bqnvaBXMre1uUbIAk5Dd4T0ubS(IZ4Az1uXJbUqnf1aYiSCoNGGgDQP2mJiLbC9wtXTe1brApKgUNEJu5RIuaQNqLuzQPIbWLoizgQHQMs6W5OR3AkogxAk5bbpVE5Dgpry9Y7gWBvaciJJ1tQ8L96jThsdxawasqsnNigj4cqcy99oX0apyaPxCI1BoV(qzxoNxpt0iI137Tr6dI1tpeLM1Jop27vV4ioR6nEVdMyI86ZRElqar)6px0V(8QFFXy90drPzuPPcap6rGAk5x(RxEqWZRxENXtewV8Ub8wfGYV8xpGmowpPYx2RN0EinCbybO8l)1tqsnNigj4cq5x(RNawFVtmnWdgq6fNy9MZRpu2LZ51ZenIy99EBK(Gy90drPz9OZJ9E1loIZQEJ37GjMiV(8Q3ceq0V(Zf9RpV63xmwp9quAgvfGfG2kNZJQaqCDGBlLSVmfiVrlS(iVZ4eB5bWJxaARCopQcaX1bUTmejaaObhBlq2DdeLKWXzdZwSVVArXLSd0emOKWSp0ss44SHPkSsQfBmrSTzOP7sc5jCC2WurQsQfBmrSTzOPzXkHJZgMQWQ1Dc(1XvCgOLZ5KjjHJZgMksvR7e8RJR4mqlNZjSa0w5CEufaIRdCBzisaaqdo2wGS7gikjHJZgMTyFF1IIlzhOjyqjKY(qljHJZgMksvsTyJjITndnDxsipHJZgMQWkPwSXeX2MHMMfReooByQivTUtWVoUIZaTCoNSeooByQcRw3j4xhxXzGwoNtybO8xFVFeRpu0hRxo0aR3Y6fxN6jayG9RVZKsRxoX486jayG9RFDG7XrE9DMuA94Ksry9YJbzJOWGy9hSE5bbpVE5eghJfG2kNZJQaqCDGBldrcaaAWX2cKD3arjmrSH9X2gnWgndSFBDoFY5C2bAcgusAc0t1wmoVrZa7Rq32cK3LeiJJ0hKiQ4gKnIcdInqKBcXColwPjqpvCe882wyCmQq32cKtybybybO8l)1hkayCXKiVEeic7xFoGy9PuSEBLhS(jwVb0gHTfOQa0w5CEucFIqMazbOTY58yisaW68idi2anIZQau(L)6LHy98ZdoRNF1NsNy9PbjIz9XowGaJtS(8Q3ceq0VE5yG(4eRxgEmoVau(L)6TvoNhdrcaGyAqIy2mM8AwM2In2fJJTfxsy2tdseZ2qlbCCcMJBgAA1Mb6JtS15yCUcIG24r2hAjqghPpiruTzG(4eBDogN3nnb6PIJGN32cJJrf62wG8cq5VEz4KspMSEcsQDX6LvkEW(1FW6LhdYgrHbr2RxoHXX6LhZxy9DMuA9eadmM1lN4oE9hSElRhGcPEsinK67mP06LfAJO(JUE5fZ4ewFAqIyglaTvoNhdrcaaAWX2cKD3arjBHXXg38fY(qlHCiJJ0hKiQwsTl2sP4b73LCiJJ0hKiQ4gKnIcdInqKBcXCo7anbdkjnb6PIEGXSTf3XvOBBbYzXkgafIwAqIygvBHXXg38fgMmjKaqeW0eONQeAJOD0niZ4k0TTa5ewak)1ldNuA9eKu7I1lRu8G9zVE5eghRxEmFH13rk61NsX63m001pX65xhN967mP06jagymRxoXD86TSEsdPEschs9DMuA9YcTru)rxV8IzCcR)G13zsP1hkIr0xy9YbrJT6TSEcmK6jbGcP(otkTEzH2iQ)ORxEXmoH1NgKiMXcqBLZ5XqKaaGgCSTaz3nquYwyCSXnFHSp0sGmosFqIOAj1UylLIhSp7anbdkzZqtRwsTl2sP4b7R4xhNfR0eONk6bgZ2wChxHUTfiVBmakeT0GeXmQ2cJJnU5lmmzsiHucyAc0tvcTr0o6gKzCf62wGCczXI80eONQv)LaBhDtQLqKRq32cK3ngafIwAqIygvBHXXg38fgMmjKqGeW0eONQeAJOD0niZ4k0TTa5ewak)1ldNuA9YJbzJOWGi71lNW4y9YJ5lSElR3piOjQpnirmRFDmEwFhPOx)MHMg51V7xVvFexNZny)6rAACLSx)bR3eDS(X6TSEcu2qQN(G17NtaLhe88zvaARCopgIeaa0GJTfi7UbIs2cJJnU5lK9HwcKXr6dsevCdYgrHbXgiYnHyoNDGMGbLKMa9urpWy22I74k0TTa5SyrYMHMwbIPbEWasV4evmbyXknb6PkH2iAhDdYmUcDBlqolwCCZqtRWye9f22q0ytXeGWUXaOq0sdseZOAlmo24MVWWKjHeaIaMMa9uLqBeTJUbzgxHUTfiNqwSipnb6PIJGNplf62wG8UXaOq0sdseZOAlmo24MVWWKjHalaL)679Jy9HIye9fwVCq0yR(nsFqSE5eghRxEmFH1p01pz9tSEdOncBlW6nNx)rtx)6ob)64fG2kNZJHibaan4yBbYUBGOKTW4yJB(cz)cibIrmzFOLKMa9uHXi6lSTHOXMcDBlqE31Dc(1XvymI(cBBiASPGOX7xaARCopgIeaa0GJTfi7UbIscCNyCIn6d2aX0yhOjyqjKNMa9uXrWZNLcDBlqE31Dc(1XvGyAGhmG0lorfebTXJHU36sZa7R4i9SMKmaQNcqBLZ5XqKaaGgCSTaz3nqusG7eJtSrFW2wyCSXnFHSd0emOeGgCSTavBHXXg38f2LeAgy)qhQYKaMMa9urpWy22I74k0TTa5YGK2dHfG2kNZJHibaan4yBbYUBGOKa3jgNyJ(GnSp22ObYoqtWGsstGEQ4i45ZsHUTfiVl5PjqpvBX48gndSVcDBlqE31Dc(1XvyFSTrdubrqB8yOjH4IRanawgKuc7sZa7R4i9SMKms7Pa0w5CEmejaaObhBlq2DdeL0XMCCIn6d2apq0tgq2bAcgusAc0tf4bIEYaQq32cK3L8ndnTc8arpzavmbkaTvoNhdrcawMq0SvoN3etmz3nquY6ob)64fG2kNZJHibaPu41PruydqK9HwYMHMwrJI2(a3gKdIEQIPTytIm7sYMHMwnGGNWY58MXanftawSiFZqtRaX0apyaPxCIkMaewaARCopgIeaaz8MTY58MyIj7UbIs4i45ZI9ycNvkjm7dTK0eONkocE(SuOBBbYlaTvoNhdrcaGmEZw5CEtmXKD3arj(bbnrbybOTY58OADNGFDCjGyAGhmG0lor2hAjKNMa9uXrWZNLcDBlqE31Dc(1XvyFSTrdubrqB8izK2txsiFDar38ube9uAFOcDBlqolwKZVufhNMr02qZ5QCwSnorczXIEiknBqe0gpgAsLzbOTY58OADNGFD8qKaaqmnWdgq6fNi7dTK0eONkocE(SuOBBbY7sY6ob)64kSp22ObQGiOnEKms7PljKd0GJTfOAlmo24MVqwSw3j4xhxTfghBCZxOcIG24rYiU4kqdGjKWUKq(6aIU5Pci6P0(qf62wGCwSiNFPkoonJOTHMZv5SyBCIeYIf9quA2GiOnEm0KkZcqBLZ5r16ob)64HibabUCoN9HwYMHMwbIPbEWasV4evqe0gpsgPYKfR9fJDPhIsZgebTXJHU36Pau(RxEqAJrK1ZeX6NebRxCeNvbOTY58OADNGFD8qKaaMi2MebJShfxgLKWXzdZWSp0saAWX2cuLWXzdZwSVVArXLsc3LKndnTcetd8GbKEXjQycWIfjKNMa9uXrWZNLcDBlqE31Dc(1XvGyAGhmG0lorfebTXJKrc9quA2GiOnEKmcqjCC2WufwTUtWVoUIZaTCoV3LucjKfl6HO0SbrqB8yOLqApeYIfjan4yBbQs44SHzl23xTO4sjK2L8eooByQivTUtWVoUcIgVpHSyroqdo2wGQeooBy2I99vlkUSa0w5CEuTUtWVoEisaateBtIGr2JIlJss44SHjPSp0saAWX2cuLWXzdZwSVVArXLsiTljBgAAfiMg4bdi9ItuXeGflsipnb6PIJGNplf62wG8UR7e8RJRaX0apyaPxCIkicAJhjJe6HO0SbrqB8izeGs44SHPIu16ob)64kod0Y58ExsjKqwSOhIsZgebTXJHwcP9qilwKa0GJTfOkHJZgMTyFF1IIlLeUl5jCC2WufwTUtWVoUcIgVpHSyroqdo2wGQeooBy2I99vlkUSa0w5CEuTUtWVoEisaqCCAgrBdnNZ(qlHC(LQ440mI2gAoxLZITXjwaARCopQw3j4xhpejaiLInPmEY(qlH80eONkocE(SuOBBbY7soqdo2wGQo2KJtSrFWg4bIEYa2LCGgCSTavbUtmoXg9bBGyASyTzOPv0mW5yInIwOCuXeOa0w5CEuTUtWVoEisaak6hhZBCCbrK9Hwcj2khGydDeCWizCmoqK3sdseZilwqB4nei6PY48OACYaOEiSaSa0w5CEuXrWZNLeAu0GmrPSp0sstGEQy89X482sQDrf62wG8UBgAAfJVpgN3wsTlQyc0LKLudseJsiLflsG2WBiq0tf4bebrpvJtw4E6cTH3qGONkJZJQXjlCpesybOTY58OIJGNpRqKaaoAP0wSdIbyFOLa0GJTfOAlmo24MVWcqBLZ5rfhbpFwHibaef2aeBjcgaJj7dTeBLdqSHocoyKmoghiYBPbjIzKflOn8gce9uzCEunozH7Pa0w5CEuXrWZNvisaqkfEDAef2aezFOLSoNZmPkIqOLiVruydquHUTfiV76ob)64kSp22ObQGiOnEm09wxY3m00kqmnWdgq6fNOIjqxY54MHMwHaCGlI8wNJX5kMafG2kNZJkocE(ScrcaW(yBJgi7dTeBLdqSHocoyKmoghiYBPbjIzKflOn8gce9uzCEunozKkZUKqoqdo2wGkMi2W(yBJgyJMb2VToNp5ColwXaOq0sdseZizHzXIMb2p0HApewaARCopQ4i45Zkejaylmo24MVq2hAjan4yBbQ2cJJnU5lSl5R7e8RJRaX0apyaPxCIkiA8(DjzDNGFDCf2hBB0avqe0gpsMmzXIeOn8gce9uzCEunozR7e8RJ3fAdVHarpvgNhvJhAsLjHewaARCopQ4i45ZkejayabpHLZ5nJbASp0siFZqtRgqWty5CEZyGMIjqbOTY58OIJGNpRqKaaZ9r6iSCoN9Hwc5an4yBbQcCNyCIn6d22cJJnU5lSa0w5CEuXrWZNvisaank2cJJSp0sOzG9vCKEwtsMecSNcqBLZ5rfhbpFwHibaymI(cBBiASvaARCopQ4i45Zkejayj1UylMWHnK9Hwc5an4yBbQcCNyCIn6d22cJJnU5lSl5an4yBbQcCNyCIn6d2W(yBJgybOTY58OIJGNpRqKaaAu0GmrPSp0sstGEQ4i45TTW4yuHUTfiVl5R7e8RJRW(yBJgOcIgVFxswsnirmkHuwSibAdVHarpvGhqee9unozH7Pl0gEdbIEQmopQgNSW9qiHfG2kNZJkocE(Scrca4i45X2EsK9v)LaBPbjIzusy2hAjqghPpiruTzG(4eBDogN3LJBgAA1Mb6JtS15yCUcIG24XqtGfG2kNZJkocE(ScrcaOrrdYeLY(qlH80eONkocEEBlmogvOBBbY7gdGcrlnirmJKfUljlPgKigLqklwKaTH3qGONkWdicIEQgNSW90fAdVHarpvgNhvJtw4EiKWcqBLZ5rfhbpFwHibaCe88yBpjwaARCopQ4i45ZkejaiLcVonIcBaISp0s2m00QJjBhDdAoruXeOa0w5CEuXrWZNvisaankAqMOu2hAjGhqee9uXNyA(cjlSmzXAZqtRoMSD0nO5erftGcqBLZ5rfhbpFwHibaarNisZiAqmHOLSp0sapGii6PIpX08fswyzwaARCopQ4i45ZkejaiLcVonIcBaISp0sstGEQ4i45TTW4yuHUTfiVaSa0w5CEu5he0esaIorKMr0GycrlzFOLKMa9ubEGONmGk0TTa5D3m00QaqmGbrUIFD8U5aIKfUa0w5CEu5he0eHiba0OObzIszFOLqYMHMwX47JX5TLu7IkMaSyb0GJTfOQJn54eB0hSbEGONmGDjH80eONkgFFmoVTKAxuHUTfiNflYx3j4xhxnGGNWY58MXanfenEFcjSljlPgKigLqklwKaTH3qGONkWdicIEQgNSW90fAdVHarpvgNhvJtw4EiKWcqBLZ5rLFqqteIeaqJI22GqJiY(qlXw5aeBOJGdgjJJXbI8wAqIygzXcAdVHarpvgNhvJtga1tbOTY58OYpiOjcrca4OLsBXoigG9Hwcqdo2wGQTW4yJB(claTvoNhv(bbnrisaWacEclNZBgd0yFOLq(MHMwnGGNWY58MXanftGcqBLZ5rLFqqteIeaquydqSLiyamMSp0sihObhBlqvhBYXj2Opyd8arpza7sITYbi2qhbhmsghJde5T0GeXmYIf0gEdbIEQmopQgNSW9qybOTY58OYpiOjcrcasPWRtJOWgGi7dTK15CMjvrecTe5nIcBaIk0TTa5Dx3j4xhxH9X2gnqfebTXJHU36s(MHMwbIPbEWasV4evmb6soh3m00keGdCrK36CmoxXeOa0w5CEu5he0eHibayFSTrdK9Hwc5an4yBbQ6ytooXg9bBGhi6jdyxsSvoaXg6i4GrY4yCGiVLgKiMrwSG2WBiq0tLX5r14KfwMDjHCGgCSTavmrSH9X2gnWgndSFBDoFY5CwSIbqHOLgKiMrYcZIfndSFOd1EiKWcqBLZ5rLFqqteIeaSfghBCZxi7dTeGgCSTavBHXXg38fwaARCopQ8dcAIqKaaAuSfghzFOLqZa7R4i9SMKmjeypfG2kNZJk)GGMiejaaJr0xyBdrJTcqBLZ5rLFqqteIeayUpshHLZ5Sp0sijnb6PIJGN32cJJrf62wGCwSihObhBlqvhBYXj2Opyd8arpzazXIMb2xXr6znzObOEyXAZqtRaX0apyaPxCIkicAJhdTmjSl5an4yBbQcCNyCIn6d22cJJnU5lSa0w5CEu5he0eHibalP2fBXeoSHSp0sijnb6PIJGN32cJJrf62wGCwSihObhBlqvhBYXj2Opyd8arpzazXIMb2xXr6znzObOEiSl5an4yBbQcCNyCIn6d2aX06soqdo2wGQa3jgNyJ(GTTW4yJB(claTvoNhv(bbnrisaa2hBB0azFOLKMa9uTfJZB0mW(k0TTa5DH2WBiq0tLX5r14KTUtWVoEbOTY58OYpiOjcrca4i45X2EsK9v)LaBPbjIzusy2hAjqghPpiruTzG(4eBDogN3LJBgAA1Mb6JtS15yCUcIG24XqtGfG2kNZJk)GGMiejaGJGNhB7jXcqBLZ5rLFqqteIeaqJIgKjkL9Hwc5PjqpvGhi6jdOcDBlqExOn8gce9ubEarq0t14KTKAqIyugmCpDttGEQ4i45TTW4yuHUTfiVa0w5CEu5he0eHiba0OylmoY(qlb8aIGONk(etZxizHLjlwBgAA1XKTJUbnNiQycuaARCopQ8dcAIqKaaAu0GmrPSp0sapGii6PIpX08fswyzYIfjBgAA1XKTJUbnNiQyc0L80eONkWde9KbuHUTfiNWcqBLZ5rLFqqteIeaaeDIinJObXeIwY(qlb8aIGONk(etZxizHLzbOTY58OYpiOjcrcasPWRtJOWgGi7dTK0eONkocEEBlmogvOBBbY1uaryCoxheP9qA4E6nsdvnvhd6JtmQPKHHsYRGKbcs(KGRVEzLI1pGboywp9bRpy)GGMi46HO8gZarE9XdeR3yYd0sKx)sQ5eXOQaughhRpSmj46jOZbIWe51hmKXr6dsev9k46ZR(GHmosFqIOQxk0TTa5bxpjHbycvfGfGYWqj5vqYabjFsW1xVSsX6hWahmRN(G1hmhPngrgC9quEJzGiV(4bI1Bm5bAjYRFj1CIyuvakJJJ1dqeC9e05aryI86dgY4i9bjIQEfC95vFWqghPpiru1lf62wG8GRNKWamHQcqzCCSEaIGRNGohictKxFWqghPpiru1RGRpV6dgY4i9bjIQEPq32cKhC9wwFOGaSmwpjHbycvfGY44y9eibxpbDoqeMiV(GHmosFqIOQxbxFE1hmKXr6dsev9sHUTfip46TS(qbbyzSEscdWeQkaLXXX6LjbxpbDoqeMiV(GHmosFqIOQxbxFE1hmKXr6dsev9sHUTfip46TS(qbbyzSEscdWeQkalaLHHsYRGKbcs(KGRVEzLI1pGboywp9bRp4aqCDGBldUEikVXmqKxF8aX6nM8aTe51VKAormQkaLXXX6jLGRNGohictKxFWjCC2Wufw1RGRpV6doHJZgMQmSQxbxpjKcWeQkaLXXX6jLGRNGohictKxFWjCC2WurQQxbxFE1hCchNnmvjPQEfC9KqkatOQaughhRhGi46jOZbIWe51hCchNnmvHv9k46ZR(Gt44SHPkdR6vW1tcPamHQcqzCCSEaIGRNGohictKxFWjCC2WurQQxbxFE1hCchNnmvjPQEfC9KqkatOQaughhRNaj46jOZbIWe51hmKXr6dsev9k46ZR(GHmosFqIOQxk0TTa5bxpjHbycvfGfGYWqj5vqYabjFsW1xVSsX6hWahmRN(G1h86ob)64bxpeL3ygiYRpEGy9gtEGwI86xsnNigvfGY44y9Hj46jOZbIWe51h86aIU5PQxk0TTa5bxFE1h86aIU5PQxbxpjHbycvfGY44y9KsW1tqNdeHjYRp41beDZtvVuOBBbYdU(8Qp41beDZtvVcUEscdWeQkaLXXX6jqcUEc6CGimrE9udibvFSVNgaxFVB95vVmYy1ZhGtCoV(lacT8G1tcaiSEscdWeQkaLXXX6jqcUEc6CGimrE9bNWXzdtvyvVcU(8Qp4eooByQYWQEfC9KegGjuvakJJJ1tGeC9e05aryI86doHJZgMksv9k46ZR(Gt44SHPkjv1RGRNKWamHQcqzCCSEzsW1tqNdeHjYRNAajO6J990a467DRpV6LrgRE(aCIZ51FbqOLhSEsaaH1tsyaMqvbOmoowVmj46jOZbIWe51hCchNnmvHv9k46ZR(Gt44SHPkdR6vW1tsyaMqvbOmoowVmj46jOZbIWe51hCchNnmvKQ6vW1Nx9bNWXzdtvsQQxbxpjHbycvfGfGYWqj5vqYabjFsW1xVSsX6hWahmRN(G1hmhbpFwbxpeL3ygiYRpEGy9gtEGwI86xsnNigvfGY44y9HbicUEc6CGimrE9bdzCK(GervVcU(8QpyiJJ0hKiQ6LcDBlqEW1tsyaMqvbybOmayGdMiVEzwVTY586ftmJQcqnLXKspOMIAajinLyIzulRMYpiOj0YQdkSwwnf62wGCTCAQfCseoMMknb6Pc8arpzavOBBbYRVB9BgAAvaigWGixXVoE9DRphqSEYQpSMYw5CUMci6erAgrdIjeTuN6GivlRMcDBlqUwon1cojchttrs9BgAAfJVpgN3wsTlQycuplw1d0GJTfOQJn54eB0hSbEGONmG13TEsQN86ttGEQy89X482sQDrf62wG86zXQEYRFDNGFDC1acEclNZBgd0uq049RNW6jS(U1ts9lPgKigRxs9Kwplw1ts9qB4nei6Pc8aIGONQXRNS6d3t9DRhAdVHarpvgNhvJxpz1hUN6jSEc1u2kNZ1u0OObzIs1PoiaslRMcDBlqUwon1cojchttzRCaIn0rWbJ1tw9CmoqK3sdseZy9Syvp0gEdbIEQmopQgVEYQhG6rtzRCoxtrJI22GqJiQtDqeOwwnf62wGCTCAQfCseoMMcObhBlq1wyCSXnFHAkBLZ5AkoAP0wSdIb0PoizQLvtHUTfixlNMAbNeHJPPiV(ndnTAabpHLZ5nJbAkMaAkBLZ5AQbe8ewoN3mgOPtDq9Mwwnf62wGCTCAQfCseoMMI86bAWX2cu1XMCCIn6d2apq0tgW67wpj1BRCaIn0rWbJ1tw9CmoqK3sdseZy9Syvp0gEdbIEQmopQgVEYQpCp1tOMYw5CUMIOWgGylrWaym1PoOqvlRMcDBlqUwon1cojchttToNZmPkIqOLiVruydquHUTfiV(U1VUtWVoUc7JTnAGkicAJhRp013B13TEYRFZqtRaX0apyaPxCIkMa13TEYRNJBgAAfcWbUiYBDogNRycOPSvoNRPsPWRtJOWgGOo1bjF1YQPq32cKRLttTGtIWX0uKxpqdo2wGQo2KJtSrFWg4bIEYawF36jPEBLdqSHocoySEYQNJXbI8wAqIygRNfR6H2WBiq0tLX5r141tw9HLz9DRNK6jVEGgCSTavmrSH9X2gnWgndSFBDoFY586zXQ(yauiAPbjIzSEYQpC9SyvpndSF9HU(qTN6jSEc1u2kNZ1uyFSTrduN6GKp0YQPq32cKRLttTGtIWX0uan4yBbQ2cJJnU5lutzRCoxtTfghBCZxOo1bfUhTSAk0TTa5A50ul4KiCmnfndSVIJ0ZAY6jts9eypAkBLZ5AkAuSfgh1PoOWH1YQPSvoNRPWye9f22q0yttHUTfixlNo1bfMuTSAk0TTa5A50ul4KiCmnfj1NMa9uXrWZBBHXXOcDBlqE9Syvp51d0GJTfOQJn54eB0hSbEGONmG1ZIv90mW(kospRjRp01dq9uplw1VzOPvGyAGhmG0lorfebTXJ1h66Lz9ewF36jVEGgCSTavbUtmoXg9bBBHXXg38fQPSvoNRPm3hPJWY5CDQdkmaPLvtHUTfixlNMAbNeHJPPiP(0eONkocEEBlmogvOBBbYRNfR6jVEGgCSTavDSjhNyJ(GnWde9KbSEwSQNMb2xXr6znz9HUEaQN6jS(U1tE9an4yBbQcCNyCIn6d2aX0QVB9Kxpqdo2wGQa3jgNyJ(GTTW4yJB(c1u2kNZ1ulP2fBXeoSH6uhuyculRMcDBlqUwon1cojchttLMa9uTfJZB0mW(k0TTa513TEOn8gce9uzCEunE9KvVTY5826ob)64AkBLZ5AkSp22ObQtDqHLPwwnf62wGCTCAkBLZ5AkocEESTNe1ul4KiCmnfKXr6dsevBgOpoXwNJX5k0TTa513TEoUzOPvBgOpoXwNJX5kicAJhRp01tGAQv)LaBPbjIzuhuyDQdkCVPLvtzRCoxtXrWZJT9KOMcDBlqUwoDQdkCOQLvtHUTfixlNMAbNeHJPPiV(0eONkWde9KbuHUTfiV(U1dTH3qGONkWdicIEQgVEYQFj1GeXy9YG1hUN67wFAc0tfhbpVTfghJk0TTa5AkBLZ5AkAu0GmrP6uhuy5Rwwnf62wGCTCAQfCseoMMc8aIGONk(etZxy9KvFyzwplw1VzOPvht2o6g0CIOIjGMYw5CUMIgfBHXrDQdkS8Hwwnf62wGCTCAQfCseoMMc8aIGONk(etZxy9KvFyzwplw1ts9BgAA1XKTJUbnNiQycuF36jV(0eONkWde9KbuHUTfiVEc1u2kNZ1u0OObzIs1Pois7rlRMcDBlqUwon1cojchttbEarq0tfFIP5lSEYQpSm1u2kNZ1uarNisZiAqmHOL6uhePH1YQPq32cKRLttTGtIWX0uPjqpvCe882wyCmQq32cKRPSvoNRPsPWRtJOWgGOo1PMIJ0gJi1YQdkSwwnLTY5CnfFIqMaPMcDBlqUwoDQdIuTSAkBLZ5AQ15rgqSbAeNLMcDBlqUwoDQdcG0YQPq32cKRLttDb0urm1u2kNZ1uan4yBbQPaAWMBGOMAlmo24MVqn1cojchttrE9qghPpiruTKAxSLsXd2xHUTfiV(U1tE9qghPpiruXniBefgeBGi3eI5Cf62wGCnfhJl4eiNZ1uYWjLEmz9eKu7I1lRu8G9R)G1lpgKnIcdISxVCcJJ1lpMVW67mP06jagymRxoXD86py9wwpafs9KqAi13zsP1ll0gr9hD9YlMXjS(0GeXmQPaAcgutLMa9urpWy22I74k0TTa51ZIv9XaOq0sdseZOAlmo24MVWW1tMK6jPEaQEcy9Pjqpvj0gr7OBqMXvOBBbYRNqDQdIa1YQPq32cKRLttDb0urm1u2kNZ1uan4yBbQPaAWMBGOMAlmo24MVqn1cojchttbzCK(Ger1sQDXwkfpyFf62wGCnfhJl4eiNZ1uYWjLwpbj1Uy9YkfpyF2RxoHXX6LhZxy9DKIE9PuS(ndnD9tSE(1XzV(otkTEcGbgZ6LtChVElRN0qQNKWHuFNjLwVSqBe1F01lVygNW6py9DMuA9HIye9fwVCq0yRElRNadPEsaOqQVZKsRxwOnI6p66LxmJty9PbjIzutb0emOMAZqtRwsTl2sP4b7R4xhVEwSQpnb6PIEGXSTf3XvOBBbYRVB9XaOq0sdseZOAlmo24MVWW1tMK6jPEsRNawFAc0tvcTr0o6gKzCf62wG86jSEwSQN86ttGEQw9xcSD0nPwcrUcDBlqE9DRpgafIwAqIygvBHXXg38fgUEYKupj1tG1taRpnb6PkH2iAhDdYmUcDBlqE9eQtDqYulRMcDBlqUwon1fqtfXutzRCoxtb0GJTfOMcObBUbIAQTW4yJB(c1ul4KiCmnfKXr6dsevCdYgrHbXgiYnHyoxHUTfixtXX4cobY5CnLmCsP1lpgKnIcdISxVCcJJ1lpMVW6TSE)GGMO(0GeXS(1X4z9DKIE9BgAAKx)UF9w9rCDo3G9RhPPXvYE9hSEt0X6hR3Y6jqzdPE6dwVFobuEqWZNLMcOjyqnvAc0tf9aJzBlUJRq32cKxplw1ts9BgAAfiMg4bdi9ItuXeOEwSQpnb6PkH2iAhDdYmUcDBlqE9Syvph3m00kmgrFHTnen2umbQNW67wFmakeT0GeXmQ2cJJnU5lmC9KjPEsQhGQNawFAc0tvcTr0o6gKzCf62wG86jSEwSQN86ttGEQ4i45ZsHUTfiV(U1hdGcrlnirmJQTW4yJB(cdxpzsQNa1PoOEtlRMcDBlqUwon1fqtbXiMAkBLZ5AkGgCSTa1uanyZnqutTfghBCZxOMAbNeHJPPstGEQWye9f22q0ytHUTfiV(U1VUtWVoUcJr0xyBdrJnfenEFnfhJl4eiNZ1u9(rS(qrmI(cRxoiASv)gPpiwVCcJJ1lpMVW6h66NS(jwVb0gHTfy9MZR)OPRFDNGFDCDQdku1YQPq32cKRLttDb0urm1u2kNZ1uan4yBbQPaAcgutrE9PjqpvCe88zPq32cKxF36x3j4xhxbIPbEWasV4evqe0gpwFORV3QVB90mW(kospRjRNS6bOE0uanyZnqutf4oX4eB0hSbIPPtDqYxTSAk0TTa5A50uxanvetnLTY5Cnfqdo2wGAkGMGb1uan4yBbQ2cJJnU5lS(U1ts90mW(1h66dvzwpbS(0eONk6bgZ2wChxHUTfiVEzW6jTN6jutb0Gn3arnvG7eJtSrFW2wyCSXnFH6uhK8Hwwnf62wGCTCAQlGMkIPMYw5CUMcObhBlqnfqtWGAQ0eONkocE(SuOBBbYRVB9KxFAc0t1wmoVrZa7Rq32cKxF36x3j4xhxH9X2gnqfebTXJ1h66jPEIlUc0a46LbRN06jS(U1tZa7R4i9SMSEYQN0E0uanyZnqutf4oX4eB0hSH9X2gnqDQdkCpAz1uOBBbY1YPPUaAQiMAkBLZ5AkGgCSTa1uanbdQPstGEQapq0tgqf62wG867wp51VzOPvGhi6jdOIjGMcObBUbIAQo2KJtSrFWg4bIEYaQtDqHdRLvtHUTfixlNMYw5CUMAzcrZw5CEtmXutjMy2Cde1uR7e8RJRtDqHjvlRMcDBlqUwon1cojchttTzOPv0OOTpWTb5GONQyAl2Qxs9YS(U1ts9BgAA1acEclNZBgd0umbQNfR6jV(ndnTcetd8GbKEXjQycupHAkBLZ5AQuk860ikSbiQtDqHbiTSAk0TTa5A50ul4KiCmnvAc0tfhbpFwk0TTa5AQycNvQdkSMYw5CUMcY4nBLZ5nXetnLyIzZnqutXrWZNLo1bfMa1YQPq32cKRLttzRCoxtbz8MTY58MyIPMsmXS5giQP8dcAcDQtnfhbpFwAz1bfwlRMcDBlqUwon1cojchttLMa9uX47JX5TLu7Ik0TTa513T(ndnTIX3hJZBlP2fvmbQVB9Ku)sQbjIX6LupP1ZIv9Kup0gEdbIEQapGii6PA86jR(W9uF36H2WBiq0tLX5r141tw9H7PEcRNqnLTY5CnfnkAqMOuDQdIuTSAk0TTa5A50ul4KiCmnfqdo2wGQTW4yJB(c1u2kNZ1uC0sPTyhedOtDqaKwwnf62wGCTCAQfCseoMMYw5aeBOJGdgRNS65yCGiVLgKiMX6zXQEOn8gce9uzCEunE9KvF4E0u2kNZ1uef2aeBjcgaJPo1brGAz1uOBBbY1YPPwWjr4yAQ15CMjvrecTe5nIcBaIk0TTa513T(1Dc(1XvyFSTrdubrqB8y9HU(ER(U1tE9BgAAfiMg4bdi9ItuXeO(U1tE9CCZqtRqaoWfrERZX4CftanLTY5CnvkfEDAef2ae1PoizQLvtHUTfixlNMAbNeHJPPSvoaXg6i4GX6jREoghiYBPbjIzSEwSQhAdVHarpvgNhvJxpz1tQmRVB9Kup51d0GJTfOIjInSp22Ob2OzG9BRZ5toNxplw1hdGcrlnirmJ1tw9HRNfR6PzG9Rp01hQ9upHAkBLZ5AkSp22ObQtDq9Mwwnf62wGCTCAQfCseoMMcObhBlq1wyCSXnFH13TEYRFDNGFDCfiMg4bdi9ItubrJ3V(U1ts9R7e8RJRW(yBJgOcIG24X6jREzwplw1ts9qB4nei6PY48OA86jREBLZ5T1Dc(1XRVB9qB4nei6PY48OA86dD9KkZ6jSEc1u2kNZ1uBHXXg38fQtDqHQwwnf62wGCTCAQfCseoMMI863m00Qbe8ewoN3mgOPycOPSvoNRPgqWty5CEZyGMo1bjF1YQPq32cKRLttTGtIWX0uKxpqdo2wGQa3jgNyJ(GTTW4yJB(c1u2kNZ1uM7J0ry5CUo1bjFOLvtHUTfixlNMAbNeHJPPOzG9vCKEwtwpzsQNa7rtzRCoxtrJITW4Oo1bfUhTSAkBLZ5AkmgrFHTnen20uOBBbY1YPtDqHdRLvtHUTfixlNMAbNeHJPPiVEGgCSTavbUtmoXg9bBBHXXg38fwF36jVEGgCSTavbUtmoXg9bByFSTrdutzRCoxtTKAxSft4WgQtDqHjvlRMcDBlqUwon1cojchttLMa9uXrWZBBHXXOcDBlqE9DRN86x3j4xhxH9X2gnqfenE)67wpj1VKAqIySEj1tA9Syvpj1dTH3qGONkWdicIEQgVEYQpCp13TEOn8gce9uzCEunE9KvF4EQNW6jutzRCoxtrJIgKjkvN6GcdqAz1uOBBbY1YPPSvoNRP4i45X2EsutTGtIWX0uqghPpiruTzG(4eBDogNRq32cKxF3654MHMwTzG(4eBDogNRGiOnES(qxpbQPw9xcSLgKiMrDqH1PoOWeOwwnf62wGCTCAQfCseoMMI86ttGEQ4i45TTW4yuHUTfiV(U1hdGcrlnirmJ1tw9HRVB9Ku)sQbjIX6LupP1ZIv9Kup0gEdbIEQapGii6PA86jR(W9uF36H2WBiq0tLX5r141tw9H7PEcRNqnLTY5CnfnkAqMOuDQdkSm1YQPSvoNRP4i45X2EsutHUTfixlNo1bfU30YQPq32cKRLttTGtIWX0uBgAA1XKTJUbnNiQycOPSvoNRPsPWRtJOWgGOo1bfou1YQPq32cKRLttTGtIWX0uGhqee9uXNyA(cRNS6dlZ6zXQ(ndnT6yY2r3GMtevmb0u2kNZ1u0OObzIs1PoOWYxTSAk0TTa5A50ul4KiCmnf4bebrpv8jMMVW6jR(WYutzRCoxtbeDIinJObXeIwQtDqHLp0YQPq32cKRLttTGtIWX0uPjqpvCe882wyCmQq32cKRPSvoNRPsPWRtJOWgGOo1PMADNGFDCTS6GcRLvtHUTfixlNMAbNeHJPPiV(0eONkocE(SuOBBbYRVB9R7e8RJRW(yBJgOcIG24X6jREs7P(U1ts9Kx)6aIU5Pci6P0(W6zXQEYRNFPkoonJOTHMZv5SyBCI1ty9Syvp9quA2GiOnES(qxpPYutzRCoxtbIPbEWasV4e1Pois1YQPq32cKRLttTGtIWX0uPjqpvCe88zPq32cKxF36jP(1Dc(1XvyFSTrdubrqB8y9KvpP9uF36jPEYRhObhBlq1wyCSXnFH1ZIv9R7e8RJR2cJJnU5lubrqB8y9KvpXfxbAaC9ewpH13TEsQN86xhq0npvarpL2hwplw1tE98lvXXPzeTn0CUkNfBJtSEcRNfR6PhIsZgebTXJ1h66jvMAkBLZ5AkqmnWdgq6fNOo1bbqAz1uOBBbY1YPPwWjr4yAQndnTcetd8GbKEXjQGiOnESEYQNuzwplw1VVyS(U1tpeLMnicAJhRp013B9OPSvoNRPcC5CUo1brGAz1uOBBbY1YPP4yCbNa5CUMsEqAJrK1ZeX6NebRxCeNLMAbNeHJPPaAWX2cuLWXzdZwSVVArXL1lP(W13TEsQFZqtRaX0apyaPxCIkMa1ZIv9Kup51NMa9uXrWZNLcDBlqE9DRFDNGFDCfiMg4bdi9ItubrqB8y9Kvpj1tpeLMnicAJhRNmcq1NWXzdtvgwTUtWVoUIZaTCoVEaupP1ty9ewplw1tpeLMnicAJhRp0sQN0EQNW6zXQEsQhObhBlqvchNnmBX((QffxwVK6jT(U1tE9jCC2WuLKQw3j4xhxbrJ3VEcRNfR6jVEGgCSTavjCC2WSf77RwuCPMkkUmQPs44SHzynLTY5CnfteBtIGrDQdsMAz1uOBBbY1YPPSvoNRPyIyBsemQPwWjr4yAkGgCSTavjCC2WSf77RwuCz9sQN067wpj1VzOPvGyAGhmG0lorftG6zXQEsQN86ttGEQ4i45ZsHUTfiV(U1VUtWVoUcetd8GbKEXjQGiOnESEYQNK6PhIsZgebTXJ1tgbO6t44SHPkjvTUtWVoUIZaTCoVEaupP1ty9ewplw1tpeLMnicAJhRp0sQN0EQNW6zXQEsQhObhBlqvchNnmBX((QffxwVK6dxF36jV(eooByQYWQ1Dc(1Xvq049RNW6zXQEYRhObhBlqvchNnmBX((QffxQPIIlJAQeooBysQo1b1BAz1uOBBbY1YPPwWjr4yAkYRNFPkoonJOTHMZv5SyBCIAkBLZ5AQ440mI2gAoxN6GcvTSAk0TTa5A50ul4KiCmnf51NMa9uXrWZNLcDBlqE9DRN86bAWX2cu1XMCCIn6d2apq0tgW67wp51d0GJTfOkWDIXj2OpydetREwSQFZqtROzGZXeBeTq5OIjGMYw5CUMkLInPmEQtDqYxTSAk0TTa5A50ul4KiCmnfj1BRCaIn0rWbJ1tw9CmoqK3sdseZy9Syvp0gEdbIEQmopQgVEYQhG6PEc1u2kNZ1uOOFCmVXXferDQtnvaiUoWTLAz1bfwlRMYw5CUMAFzkqEJwy9rENXj2YdGhxtHUTfixlNo1brQwwnf62wGCTCAQlGMkIPMYw5CUMcObhBlqnfqtWGAQWAQfCseoMMkHJZgMQmSsQfBmrSTzOPRVB9Kup51NWXzdtvsQsQfBmrSTzOPRNfR6t44SHPkdRw3j4xhxXzGwoNxpzsQpHJZgMQKu16ob)64kod0Y586jutb0Gn3arnvchNnmBX((QffxQtDqaKwwnf62wGCTCAQlGMkIPMYw5CUMcObhBlqnfqtWGAks1ul4KiCmnvchNnmvjPkPwSXeX2MHMU(U1ts9KxFchNnmvzyLul2yIyBZqtxplw1NWXzdtvsQADNGFDCfNbA5CE9KvFchNnmvzy16ob)64kod0Y586jutb0Gn3arnvchNnmBX((QffxQtDqeOwwnf62wGCTCAQlGMkIPMYw5CUMcObhBlqnfqtWGAQ0eONQTyCEJMb2xHUTfiV(U1ts9qghPpiruXniBefgeBGi3eI5Cf62wG86zXQ(0eONkocEEBlmogvOBBbYRNqnfhJl4eiNZ1u9(rS(qrFSE5qdSElRxCDQNaGb2V(otkTE5eJZRNaGb2V(1bUhh513zsP1JtkfH1lpgKnIcdI1FW6Lhe886LtyCmQPaAWMBGOMIjInSp22Ob2OzG9BRZ5toNRtDQtDQtTg]] )


end
