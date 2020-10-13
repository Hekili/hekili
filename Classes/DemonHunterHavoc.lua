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

            handler = function ()
                removeBuff( "thirsting_blades" )
                if azerite.thirsting_blades.enabled then applyBuff( "thirsting_blades", nil, 0 ) end

                if buff.chaotic_blades.up then gain( 20, "fury" ) end -- legendary
            end,
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
        

        torment = {
            id = 281854,
            cast = 0,
            cooldown = 8,
            gcd = "off",

            startsCombat = true,
            texture = 1344654,

            handler = function ()
                applyDebuff( "target", "torment" )
            end,
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


    spec:RegisterPack( "Havoc", 20201013, [[diuCmbqisWJirInjfgfjXPijTkksvVIIQzHO6wsPc7Iu)IIYWqKogOyzsP8mPeMMuQ6AKi2gjs9nsK04KsLoNuIyEuKCpq1(aLoOuQOwifXdLsKYeLsf5IuKk1gPivYiPivCsPejTseXojr9tPejwQuIu9uatLeAVq(lvgSGdJAXc9yQAYeDzvBgOpJqJMK60sETusZgPBlv7w0VvA4G0YH65uA6kUof2oi(Uu04LsuNhrz9uKY8rW(jmcgKIiajphPCBK2gPWqkmTqtA7QeyivPradzqpcak7BLjEeqY9JamDyiRhbaLjJUSePicWUgy)raav3GYtTzlnmdoiGOrrNwQjkIaK8CKYTrABKcdPW0cnPTRsGH0wGaSqVhPSsuQkveG6skFIIia5TEeGsreANEFtrW0XiNJfbthgY6fKOueHwk(zJhlcW0cYfH2iTnsraqXlyrpcqPicTtVVPiy6yKZXIGPddz9csukIqlf)SXJfbyAb5IqBK2gPcseKOuebGKHAvVJiG5skcrdqWlfb7WJveIhCXxe8BpYJiepXkTIaNsrak(TdO7mvsuekRii38AbjSFQnTAO473EKhZHBMH9UAEN8K7hoBAw1mMToWnh3c6GUnpwqIGeLIiy6ULV3yUueoKJjteMQFryuFrG9ZIfHYkcmeUOCKETGe2p1Mw4YYInGocsy)uBAnhUz(nTg976mXYliH9tTP1C4MbHXfhPN8K7hEKYY7KC6p5qyQXHpm95OblSDCr6Us9tosVKabl0tPUHXe)y1rklVtYP)WalCvAr7yy6ZrpyUOUf0HnQu)KJ0lvvqc7NAtR5WndcJlosp5j3pCO7sRKOdCXU(hMCim14Wvyy6ZrlFFZYRFYr6Ln87sLBZu3)W9fdv9AlRg)oxP1ukDdqdmzA5blFnW2csfKW(P20AoCZGW4IJ0tEY9dh6U0kj6axSlsz5Dso9NCim14WHW4IJ0RJuwENKt)BOcObMmtPuvs7yy6Zrdwy74I0DL6NCKEPPVnsvvqc7NAtR5WndcJlosp5j3pCO7sRKOdCXUt2DXZDYHWuJdFy6ZrlFFZYRFYr6Lnuyy6ZrhPvkDGgyY0p5i9Yg(DPYTzQpz3fp31435kTMsfIEPUZTSPVnvBaAGjtlpy5Rb22ivqc7NAtR5WndcJlosp5j3p8MCnvs0bUy3T2N(7I4ZTsoeMAC4dtFo6BTp93fXNBv)KJ0lBOaegxCKEn0DPvs0bUyxKYY7KC6FdfGW4IJ0RHUlTsIoWf76F4g(DPYTzQV1(0FxeFUvTbubjSFQnTMd3mimU4i9KNC)WBY1ujrh4ID9T)Cm6KdHPgh(W0NJUV9NJrx)KJ0lBOq0aeu33(ZXORnGkiH9tTP1C4Mjll2a6iiH9tTP1C4M5zk1X(P20rl7qEY9d3VlvUntYlq4e9sn(DUslCsfKOueb2p1MwZHBg0Y3QZaQdeZe7phYlq4Y330zxdQdeZe7phlSKkirPicSFQnTMd3mOLVvNbuhiMj2FoKxGWbnWKPLhS81al8wOKgQOaBAhxZ1NSBDlOdZeV(jhPxsGGFxQCBM6t2DXZDn(DUslSWOBVQcsy)uBAnhUzJA820rKYfKtEbcpAacQbp1f3EKXY(ZrBh23kCL0qLObiOU69LYtTPJnWS2akbckenab19pCFXqvV2YQnGQQGe2p1MwZHBMNPuh7NAthTSd5j3p8BTp93fXNBL8ce(W0NJ(w7t)Dr85w1p5i9YgQaHXfhPx3KRPsIoWf7U1(0FxeFUvceKpAacQV1(0FxeFUvTbuvfKW(P20AoCZWgPJ9tTPJw2H8K7hU89nlp5fi8HPphT89nlV(jhPxkiH9tTP1C4MHnsh7NAthTSd5j3p8CXDMkirqc7NAtR2VlvUnt49pCFXqvV2YsEbcxbvgM(C0Y33S86NCKEjbcqyCXr61q3Lwjrh4ID9pSQeiawevpo87CLwt1MseKW(P20Q97sLBZ0C4M1)W9fdv9All5fi8HPphT89nlV(jhPx2qffyt74AU2RM3P8UbZPfCXDEQn1p5i9sceuXVlvUnt9j7U45Ug)oxPf22iTHkkaHXfhPxhPS8ojN(tGGFxQCBM6iLL3j50Fn(DUslSe9sDNBzvvvvbjSFQnTA)Uu52mnhUz2kbnOUiMtj5fiCfK7OTvcAqDrmNs9u(wRKOGe2p1MwTFxQCBMMd3Sr9DQnYrqc7NAtR2VlvUntZHBg4kLh7M1nQVdKY9liH9tTPv73Lk3MP5Wn7uYSfNo594FbjSFQnTA)Uu52mnhUzq3P2K8ceE0aeu3)W9fdv9AlRg)oxPf22ucbcGfr1Jd)oxP1uknPcsy)uBA1(DPYTzAoCZmS3vZ7KNC)WjY07zk9yRlUBsEbcxHHPphn4PUiJXmXRFYr6Lei43Lk3MPg8uxKXyM414ZsYeKW(P20Q97sLBZ0C4MzyVRM3j)GG3pUK7hUNmpDh8ML3fPSDiVaHhnab19pCFXqvV2YQnG2iAacQ7VVyYClOJA4lPtIp3TA52mBOIcqyCXr61rklVtYP)eiOGFxQCBM6iLL3j50Fn(SKmvfKW(P20Q97sLBZ0C4MzyVRM3jp5(HZw1q48whMnTf78lMPKxGWLpAacQXSPTyNFXm1jF0aeul3MjbcQiF0aeu73uA4NcYDv2Qt(ObiO2akbcrdqqD)d3xmu1RTSA87CLwyBJuvBmmM4hT6Z0rTgQFmvlGHabWIO6XHFNR0AQ2ivqc7NAtR2VlvUntZHBMH9UAEN8K7hoBAw1mMToWnh3c6GUnpM8ceUFxQCBM6(hUVyOQxBz1435kTMcgsjqWVlvUntD)d3xmu1RTSA87CLwyvAsfKOueH2PdYg0reazknY(wfbWflcgwosViuZ7wTGe2p1MwTFxQCBMMd3md7D18UL8ceE0aeu3)W9fdv9AlR2aQGe2p1MwTFxQCBMMd3mptPo2p1MoAzhYtUF43AF6VvqIGe2p1MwT89nlpCWtDydRAYlq4Qmm95OnY4AKsNxnVw9tosVSr0aeuBKX1iLoVAETAdOQ2qfVAgt8w4TrGGkyUKUd55O7lK3Fo6kHfgsBG5s6oKNJMLsRUsyHHuvvvqc7NAtRw((ML3C4MjppQD2M)qjVaHdHXfhPxhPS8ojN(liH9tTPvlFFZYBoCZis5cYDZ7qVDiVaHZ(PGC3Z3RBHvEBHV0nmM4hlbcyUKUd55OzP0QRewyivqc7NAtRw((ML3C4MnQXBthrkxqo5fiC)MsJA02JX8CPJiLlix)KJ0lB43Lk3MP(KDx8CxJFNR0AkLUHcrdqqD)d3xmu1RTSAdOnuq(ObiO(Tm01EPR5AKsTbubjSFQnTA57BwEZHB2j7U45o5fiCmxs3H8C0SuA1gqjqaZL0DiphnlLwDLW2MseKW(P20QLVVz5nhUzrklVtYP)KxGWHW4IJ0RJuwENKt)BOGFxQCBM6(hUVyOQxBz14ZsYAOIFxQCBM6t2DXZDn(DUslSQOK2bBAhxZ14dzPqQKOlsz5TAmNTA6BHQeiOcMlP7qEoAwkT6kH1VlvUnZgyUKUd55OzP0QR0uTPevvvqc7NAtRw((ML3C4Mv9(s5P20Xgywqc7NAtRw((ML3C4MXzwQlkp1MKxGWvacJlosVg6U0kj6axSlsz5Dso9xqc7NAtRw((ML3C4MbEAKYYtEbch0atMwEWYxdSWBpPcsy)uBA1Y33S8Md3mVAETo7GRwp5fiCfGW4IJ0RHUlTsIoWf7IuwENKt)BOaegxCKEn0DPvs0bUy3j7U45UGe2p1MwT89nlV5Wnd8uh2WQM8ce(W0NJw((MUiLL3QFYr6LnuWVlvUnt9j7U45UgFwswdv8QzmXBH3gbcQG5s6oKNJUVqE)5ORewyiTbMlP7qEoAwkT6kHfgsvvvbjSFQnTA57BwEZHBM89nTUynxqc7NAtRw((ML3C4MnQXBthrkxqo5fi8ObiOEng3c6WCs8AdOcsy)uBA1Y33S8Md3mWtDydRAYlq49fY7phTSSdN(dlmkHaHObiOEng3c6WCs8AdOcsy)uBA1Y33S8Md3mipjEqdQd)bFEiVaH3xiV)C0YYoC6pSWOebjSFQnTA57BwEZHB2OgVnDePCb5KxGWhM(C0Y330fPS8w9tosVuqIGe2p1Mw9T2N(7I4ZTc)w7t)Dr85wjVaHdAGjdw4TlPnuXVlvUntDKYY7KC6VgFwsgbckaHXfhPxhPS8ojN(RQGe2p1Mw9T2N(7I4ZTAoCZKNh1oBZFOKxGWHW4IJ0RJuwENKt)BiF0aeuFR9P)Ui(CRAdOcsy)uBA13AF6VlIp3Q5Wnlsz5Dso9N8ceoegxCKEDKYY7KC6Fd5JgGG6BTp93fXNBvBavqc7NAtR(w7t)Dr85wnhUzCML6IYtTj5fiC5JgGG6BTp93fXNBvBavqc7NAtR(w7t)Dr85wnhUzE18AD2bxTEYlq4Yhnab13AF6VlIp3Q2aQGebjSFQnT6BTp93chcJlosp5j3pCWtDrgJzI3zjl9KxGWhM(C0GN6ImgZeV(jhPxsoeMAC4(DPYTzQbp1fzmMjEn(SKSgQOIkkmm95OLVVz51p5i9sceIgGG6(hUVyOQxBz1gqvTHcqyCXr61n5AQKOdCXU(2Fog9gyUKUd55OzP0QRe2wqQQeiW(PGC3Z3RBHvEBHV0nmM4hRQcsy)uBA13AF6V1C4M530)CW8CPdKY9tEbcxffK7O9B6FoyEU0bs5(DrdCQNY3ALeBOa7NAtTFt)ZbZZLoqk3VUshiTiQEiqa0GsD47vZyI3nv)MIOxQ7ClRQGeLIi0opZ7qhrywrWsw6fHM1OwemDDQiycJXmXlclweANxt3Iqbkc1icnlkveIxemSxkcnRrDLIWO(Iq(wEeH2RerWE)Msl5IWoQpUzzViyyViinWvsueYf3zQienW2reKCNjETGe2p1Mw9T2N(BnhUzr6Us3c6g1398DYiVaHRIcdtFoAWtDrgJzIx)KJ0ljqWVlvUntn4PUiJXmXRXVZvAHT9kr1gkaHXfhPx3KRPsIoWf76B)5y0BOIkkmm95OLVVz51p5i9sceIgGG6(hUVyOQxBz1gqBOGFxQCBM6iLL3j50Fn(SKmvjqaSiQEC435kTMcomKQQGe2p1Mw9T2N(BnhUzr6Us3c6g1398DYiVaHpm95Obp1fzmMjE9tosVSbegxCKEn4PUiJXmX7SKLEbjSFQnT6BTp93AoCZiAWyzXPBbDSPD8oQjVaHRs0aeu3)W9fdv9AlR2aAd)Uu52m19pCFXqvV2YQXNLKPkbcrdqqD)d3xmu1RTSA87CLwyBtjeiawevpo87CLwtbVfKkiH9tTPvFR9P)wZHBg46nSx6yt74AUlEUtEbc3c9uQBymXpwDKYY7KC6pmWcVnceWCjDhYZrZsPvxjSknPcsy)uBA13AF6V1C4Mb1axGKvjrxKY2H8ceUf6Pu3WyIFS6iLL3j50FyGfEBeiG5s6oKNJMLsRUsyvAsfKW(P20QV1(0FR5WnBuFNrgxJu6axS)KxGWJgGGA89TsV16axS)AdOeienab147BLER1bUy)D(1iNJ12H9TAkyivqc7NAtR(w7t)TMd3mCbfk9UkDwOS)csy)uBA13AF6V1C4M1CXujKxPdF7MC6p5fi8ObiOU)H7lgQ61wwTbuceGW4IJ0Rbp1fzmMjENLS0liH9tTPvFR9P)wZHBw)9ftMBbDudFjDs85UL8ceoObMmt1EsBenab19pCFXqvV2YQnGkirPicMolvkcT0pdTsIIGPlk3VveaxSi8w(EJ5IaMtIxewSi0ArPIq0ae0sUiuGIa01ARi9ArODM2KjZkcdMmrywrG4hryuFrGUnVDeb)Uu52mfHiBVue2ueyiCr5i9IWZ3RB1csy)uBA13AF6V1C4MHpdTsIoqk3VL8ce(WyIF0t1VBwNSUPGrReceurLHXe)OvFMoQ1q9dSTlPeimmM4hT6Z0rTgQFmf82iv1gQW(PGC3Z3RBHddbcGfr1Jd)oxPf22AjQQkbcQmmM4h9u97M1b1pU2if2wqAdvy)uqU7571TWHHabWIO6XHFNR0cB7BVQQkirqc7NAtRoxCNPWH8K4bnOo8h85H8ce(W0NJUV9NJrx)KJ0lBenab1qXhkJVul3MzJP6hwyeKW(P20QZf3zQ5Wnd8uh2WQM8ceUkqyCXr61n5AQKOdCXU(2FogDcegM(C0gzCnsPZRMxR(jhPx2iAacQnY4AKsNxnVwTbuvBOIxnJjEl82iqqfmxs3H8C09fY7phDLWcdPnWCjDhYZrZsPvxjSWqQQQkiH9tTPvNlUZuZHBg4PUiJXmXtEbcN9tb5UNVx3cR82cFPBymXpwceWCjDhYZrZsPvxjSTGubjSFQnT6CXDMAoCZKNh1oBZFOKxGWHW4IJ0RJuwENKt)fKW(P20QZf3zQ5WnR69LYtTPJnWSGe2p1MwDU4otnhUzePCb5U5DO3oKxGWvacJlosVUjxtLeDGl213(ZXO3qf2pfK7E(EDlSYBl8LUHXe)yjqaZL0DiphnlLwDLWcdPQkiH9tTPvNlUZuZHB2OgVnDePCb5KxGW9BknQrBpgZZLoIuUGC9tosVSHFxQCBM6t2DXZDn(DUsRPu6gkenab19pCFXqvV2YQnG2qb5JgGG63Yqx7LUMRrk1gqfKW(P20QZf3zQ5Wn7KDx8CN8ceo7NcYDpFVUfwyAOIcyUKUd55OzP0QFlx2XsGaMlP7qEoAwkTAdOQ2qbimU4i96MCnvs0bUyxF7phJUGe2p1MwDU4otnhUzrklVtYP)KxGWHW4IJ0RJuwENKt)fKW(P20QZf3zQ5Wnd80iLLN8ceoObMmT8GLVgyH3EsfKW(P20QZf3zQ5Wn7KDx8CN8ceUcdtFo6iTsPd0atM(jhPx2qbimU4i96MCnvs0bUy3T2N(7I4ZT2aZL0DiphnlLwDLW63Lk3MPGe2p1MwDU4otnhUzCML6IYtTj5fiCvgM(C0Y330fPS8w9tosVKabfGW4IJ0RBY1ujrh4ID9T)Cm6eiaAGjtlpy5RXuTGuceIgGG6(hUVyOQxBz1435kTMsjQ2qbimU4i9AO7sRKOdCXUiLL3j50)gkaHXfhPx3KRPsIoWf7U1(0FxeFUvbjSFQnT6CXDMAoCZ8Q516SdUA9KxGWvzy6ZrlFFtxKYYB1p5i9sceuacJlosVUjxtLeDGl213(ZXOtGaObMmT8GLVgt1csvTHcqyCXr61q3Lwjrh4ID9pCdfGW4IJ0RHUlTsIoWf7IuwENKt)BOaegxCKEDtUMkj6axS7w7t)Dr85wfKW(P20QZf3zQ5Wn7KDx8CN8ce(W0NJosRu6anWKPFYr6LnWCjDhYZrZsPvxjS(DPYTzkiH9tTPvNlUZuZHBM89nTUynxqc7NAtRoxCNPMd3mWtDydRAYlq4kmm95O7B)5y01p5i9YgyUKUd55O7lK3Fo6kH1RMXeV10ddPngM(C0Y330fPS8w9tosVuqc7NAtRoxCNPMd3mWtJuwEYlq49fY7phTSSdN(dlmkHaHObiOEng3c6WCs8AdOcsy)uBA15I7m1C4MbEQdByvtEbcVVqE)5OLLD40FyHrjeiOs0aeuVgJBbDyojETb0gkmm95O7B)5y01p5i9svfKW(P20QZf3zQ5WndYtIh0G6WFWNhYlq49fY7phTSSdN(dlmkrqc7NAtRoxCNPMd3SrnEB6is5cYjVaHpm95OLVVPlsz5T6NCKEjcaYX2AtKYTrABKcdPW0gcOjJZkjAraTu7qx8CPiOufb2p1MIaTSJvlibbWgJ6fJaaQElneaTSJfPicixCNPifrkddsreWtosVezccWJR54IradtFo6(2FogD9tosVueAicrdqqnu8HY4l1YTzkcneHP6xeGveGbbW(P2eba5jXdAqD4p4ZdAqk3gsreWtosVezccWJR54IraQicqyCXr61n5AQKOdCXU(2FogDrGabryy6ZrBKX1iLoVAET6NCKEPi0qeIgGGAJmUgP05vZRvBaveuveAicQicE1mM4TIaCrOnrGabrqfraZL0DiphDFH8(ZrxPiaRiadPIqdraZL0DiphnlLwDLIaSIamKkcQkcQIay)uBIaap1HnSQrds5wGueb8KJ0lrMGa84AoUyea7NcYDpFVUveGveK3w4lDdJj(XkceiicyUKUd55OzP0QRueGveAbPia2p1MiaWtDrgJzIhniLBpsreWtosVezccWJR54IraqyCXr61rklVtYP)ia2p1Mia55rTZ28hkAqkReKIia2p1MiGQ3xkp1Mo2aZiGNCKEjYe0GuwPrkIaEYr6LitqaECnhxmcqbracJlosVUjxtLeDGl213(ZXOlcnebveb2pfK7E(EDRiaRiiVTWx6ggt8JveiqqeWCjDhYZrZsPvxPiaRiadPIGQia2p1MiaIuUGC38o0Bh0GuwPIueb8KJ0lrMGa84AoUyeGFtPrnA7XyEU0rKYfKRFYr6LIqdrWVlvUnt9j7U45Ug)oxPvemLiO0IqdrqbriAacQ7F4(IHQETLvBaveAickicYhnab1VLHU2lDnxJuQnGIay)uBIag14TPJiLlihniLBxKIiGNCKEjYeeGhxZXfJay)uqU7571TIaSIamIqdrqfrqbraZL0DiphnlLw9B5YowrGabraZL0DiphnlLwTburqvrOHiOGiaHXfhPx3KRPsIoWf76B)5y0raSFQnraNS7IN7ObPClbPic4jhPxImbb4X1CCXiaimU4i96iLL3j50Fea7NAteqKYY7KC6pAqkddPifrap5i9sKjiapUMJlgbaAGjtlpy5RreGfUi0EsraSFQnraGNgPS8ObPmmWGueb8KJ0lrMGa84AoUyeGcIWW0NJosRu6anWKPFYr6LIqdrqbracJlosVUjxtLeDGl2DR9P)Ui(CRIqdraZL0DiphnlLwDLIaSIa7NAtNFxQCBMia2p1MiGt2DXZD0GugM2qkIaEYr6LitqaECnhxmcqfryy6ZrlFFtxKYYB1p5i9srGabrqbracJlosVUjxtLeDGl213(ZXOlceiicGgyY0Ydw(AebtjcTGurGabriAacQ7F4(IHQETLvJFNR0kcMseuIiOQi0qeuqeGW4IJ0RHUlTsIoWf7IuwENKt)fHgIGcIaegxCKEDtUMkj6axS7w7t)Dr85wraSFQnraCML6IYtTjAqkdtlqkIaEYr6LitqaECnhxmcqfryy6ZrlFFtxKYYB1p5i9srGabrqbracJlosVUjxtLeDGl213(ZXOlceiicGgyY0Ydw(AebtjcTGurqvrOHiOGiaHXfhPxdDxALeDGl21)WIqdrqbracJlosVg6U0kj6axSlsz5Dso9xeAickicqyCXr61n5AQKOdCXUBTp93fXNBfbW(P2eb4vZR1zhC16rdszyApsreWtosVezccWJR54IradtFo6iTsPd0atM(jhPxkcnebmxs3H8C0SuA1vkcWkcSFQnD(DPYTzIay)uBIaoz3fp3rdszyucsrea7NAteG89nTUynhb8KJ0lrMGgKYWO0ifrap5i9sKjiapUMJlgbOGimm95O7B)5y01p5i9srOHiG5s6oKNJUVqE)5ORueGve8QzmXBfbtViadPIqdryy6ZrlFFtxKYYB1p5i9sea7NAtea4PoSHvnAqkdJsfPic4jhPxImbb4X1CCXiG(c59NJww2Ht)fbyfbyuIiqGGienab1RX4wqhMtIxBafbW(P2ebaEAKYYJgKYW0Uifrap5i9sKjiapUMJlgb0xiV)C0YYoC6ViaRiaJsebceebveHObiOEng3c6WCs8AdOIqdrqbryy6Zr33(ZXORFYr6LIGQia2p1MiaWtDydRA0GugMwcsreWtosVezccWJR54Ira9fY7phTSSdN(lcWkcWOeea7NAteaKNepOb1H)GppObPCBKIueb8KJ0lrMGa84AoUyeWW0NJw((MUiLL3QFYr6Lia2p1MiGrnEB6is5cYrdAqa3AF6VfPiszyqkIaEYr6LitqalueG9dcG9tTjcacJlospcactnocWVlvUntn4PUiJXmXRXNLKjcnebvebvebvebfeHHPphT89nlV(jhPxkceiicrdqqD)d3xmu1RTSAdOIGQIqdrqbracJlosVUjxtLeDGl213(ZXOlcnebmxs3H8C0SuA1vkcWkcTGurqvrGabrG9tb5UNVx3kcWkcYBl8LUHXe)yfbvraECnhxmcyy6ZrdEQlYymt86NCKEjcacJDj3pca8uxKXyM4DwYspAqk3gsreWtosVezccWJR54IraQickicYD0(n9phmpx6aPC)UObo1t5BTsIIqdrqbrG9tTP2VP)5G55shiL7xxPdKwevpIabcIaObL6W3RMXeVBQ(fbtjce9sDNBzrqvea7NAteGFt)ZbZZLoqk3pAqk3cKIiGNCKEjYeeGhxZXfJaureuqegM(C0GN6ImgZeV(jhPxkceiic(DPYTzQbp1fzmMjEn(DUsRiaRi0ELicQkcnebfebimU4i96MCnvs0bUyxF7phJUi0qeureureuqegM(C0Y33S86NCKEPiqGGienab19pCFXqvV2YQnGkcnebfeb)Uu52m1rklVtYP)A8zjzIGQIabcIayru94WVZvAfbtbxeGHurqvea7NAteqKUR0TGUr9DpFNm0GuU9ifrap5i9sKjiapUMJlgbmm95Obp1fzmMjE9tosVueAicqyCXr61GN6ImgZeVZsw6raSFQnrar6Us3c6g1398DYqdszLGueb8KJ0lrMGa84AoUyeGkIq0aeu3)W9fdv9AlR2aQi0qe87sLBZu3)W9fdv9AlRgFwsMiOQiqGGienab19pCFXqvV2YQXVZvAfbyfH2uIiqGGiawevpo87CLwrWuWfHwqkcG9tTjcGObJLfNUf0XM2X7OgniLvAKIiGNCKEjYeeGhxZXfJaSqpL6ggt8JvhPS8ojN(dJialCrOnrGabraZL0DiphnlLwDLIaSIGstkcG9tTjcaC9g2lDSPDCn3fp3rdszLksreWtosVezccWJR54IrawONsDdJj(XQJuwENKt)HreGfUi0MiqGGiG5s6oKNJMLsRUsrawrqPjfbW(P2eba1axGKvjrxKY2bniLBxKIiGNCKEjYeeGhxZXfJaIgGGA89TsV16axS)AdOIabcIq0aeuJVVv6Twh4I935xJCowBh23QiykragsraSFQnraJ67mY4AKsh4I9hniLBjifraSFQnra4cku6Dv6Sqz)rap5i9sKjObPmmKIueb8KJ0lrMGa84AoUyeq0aeu3)W9fdv9AlR2aQiqGGiaHXfhPxdEQlYymt8olzPhbW(P2eb0CXujKxPdF7MC6pAqkddmifrap5i9sKjiapUMJlgbaAGjtemLi0EsfHgIq0aeu3)W9fdv9AlR2akcG9tTjcO)(IjZTGoQHVKoj(C3IgKYW0gsreWtosVezccWJR54IradJj(rpv)UzDY6IGPeby0kreiqqeureureggt8Jw9z6Owd1pIaSIq7sQiqGGimmM4hT6Z0rTgQFebtbxeAJurqvrOHiOIiW(PGC3Z3RBfb4IamIabcIayru94WVZvAfbyfH2AjIGQIGQIabcIGkIWWyIF0t1VBwhu)4AJurawrOfKkcnebveb2pfK7E(EDRiaxeGreiqqealIQhh(DUsRiaRi0(2lcQkcQIay)uBIaWNHwjrhiL73Ig0GaKhKnOdsrKYWGuebW(P2ebill2a6GaEYr6Litqds52qkIay)uBIa8BAn631zILhb8KJ0lrMGgKYTaPic4jhPxImbbSqra2pia2p1MiaimU4i9iaim14iGHPphnyHTJls3vQFYr6LIabcIGf6Pu3WyIFS6iLL3j50FyebyHlcQicTqeAhIWW0NJEWCrDlOdBuP(jhPxkcQIaGWyxY9JaIuwENKt)rds52Jueb8KJ0lrMGawOia7hea7NAteaegxCKEeaeMACeGcIWW0NJw((MLx)KJ0lfHgIGFxQCBM6(hUVyOQxBz1435kTIGPebLweAicGgyY0Ydw(AebyfHwqkcacJDj3pca6U0kj6axSR)HrdszLGueb8KJ0lrMGawOia7hea7NAteaegxCKEeaeMACeaegxCKEDKYY7KC6Vi0qeureanWKjcMseuQkreAhIWW0NJgSW2XfP7k1p5i9srW0lcTrQiOkcacJDj3pca6U0kj6axSlsz5Dso9hniLvAKIiGNCKEjYeeWcfby)Gay)uBIaGW4IJ0JaGWuJJagM(C0Y33S86NCKEPi0qeuqegM(C0rALshObMm9tosVueAic(DPYTzQpz3fp31435kTIGPebvebIEPUZTSiy6fH2ebvfHgIaObMmT8GLVgrawrOnsraqySl5(raq3Lwjrh4IDNS7IN7ObPSsfPic4jhPxImbbSqra2pia2p1MiaimU4i9iaim14iGHPph9T2N(7I4ZTQFYr6LIqdrqbracJlosVg6U0kj6axSlsz5Dso9xeAickicqyCXr61q3Lwjrh4ID9pSi0qe87sLBZuFR9P)Ui(CRAdOiaim2LC)iGMCnvs0bUy3T2N(7I4ZTIgKYTlsreWtosVezccyHIaSFqaSFQnraqyCXr6raqyQXradtFo6(2FogD9tosVueAickicrdqqDF7phJU2akcacJDj3pcOjxtLeDGl213(ZXOJgKYTeKIia2p1MiazzXgqheWtosVezcAqkddPifrap5i9sKjiapUMJlgbq0l1435kTIaCrGuea7NAteGNPuh7NAthTSdcGw2XLC)ia)Uu52mrdszyGbPic4jhPxImbb4X1CCXiGObiOg8uxC7rgl7phTDyFRIaCrqjIqdrqfriAacQREFP8uB6ydmRnGkceiickicrdqqD)d3xmu1RTSAdOIGQia2p1MiGrnEB6is5cYrdszyAdPic4jhPxImbb4X1CCXiGHPph9T2N(7I4ZTQFYr6LIqdrqfracJlosVUjxtLeDGl2DR9P)Ui(CRIabcIG8rdqq9T2N(7I4ZTQnGkcQIay)uBIa8mL6y)uB6OLDqa0YoUK7hbCR9P)Ui(CRObPmmTaPic4jhPxImbb4X1CCXiGHPphT89nlV(jhPxIay)uBIaWgPJ9tTPJw2bbql74sUFeG89nlpAqkdt7rkIaEYr6LitqaSFQnrayJ0X(P20rl7GaOLDCj3pcixCNPObniaO473EKhKIiLHbPic4jhPxImbbKC)ia20SQzmBDGBoUf0bDBEmcG9tTjcGnnRAgZwh4MJBbDq3MhJg0Ga87sLBZePiszyqkIaEYr6LitqaECnhxmcqbrqfryy6ZrlFFZYRFYr6LIabcIaegxCKEn0DPvs0bUyx)dlcQkceiicGfr1Jd)oxPvemLi0MsqaSFQnra9pCFXqvV2YIgKYTHueb8KJ0lrMGa84AoUyeWW0NJw((MLx)KJ0lfHgIGkIGcIaBAhxZ1E18oL3nyoTGlUZtTP(jhPxkceiicQic(DPYTzQpz3fp31435kTIaSIqBKkcnebvebfebimU4i96iLL3j50FrGabrWVlvUntDKYY7KC6Vg)oxPveGvei6L6o3YIGQIGQIGQia2p1MiG(hUVyOQxBzrds5wGueb8KJ0lrMGa84AoUyeGcIGChTTsqdQlI5uQNY3ALeraSFQnra2kbnOUiMtjAqk3EKIia2p1MiGr9DQnYbb8KJ0lrMGgKYkbPicG9tTjcaCLYJDZ6g13bs5(rap5i9sKjObPSsJuebW(P2ebCkz2ItN8E8pc4jhPxImbniLvQifrap5i9sKjiapUMJlgbenab19pCFXqvV2YQXVZvAfbyfH2uIiqGGiawevpo87CLwrWuIGstkcG9tTjca6o1MObPC7Iueb8KJ0lrMGay)uBIaiY07zk9yRlUBIa84AoUyeGcIWW0NJg8uxKXyM41p5i9srGabrWVlvUntn4PUiJXmXRXNLKHasUFearMEptPhBDXDt0GuULGueb8KJ0lrMGay)uBIa8K5P7G3S8UiLTdcWJR54IrardqqD)d3xmu1RTSAdOIqdriAacQ7VVyYClOJA4lPtIp3TA52mfHgIGkIGcIaegxCKEDKYY7KC6ViqGGiOGi43Lk3MPosz5Dso9xJpljteufbCqW7hxY9Ja8K5P7G3S8UiLTdAqkddPifrap5i9sKjia2p1Mia2QgcN36WSPTyNFXmfb4X1CCXia5JgGGAmBAl25xmtDYhnab1YTzkceiicQicYhnab1(nLg(PGCxLT6KpAacQnGkceiicrdqqD)d3xmu1RTSA87CLwrawrOnsfbvfHgIWWyIF0Qpth1AO(remLi0cyebceebWIO6XHFNR0kcMseAJueqY9JayRAiCERdZM2ID(fZu0GuggyqkIaEYr6LitqaSFQnraSPzvZy26a3CClOd628yeGhxZXfJa87sLBZu3)W9fdv9AlRg)oxPvemLiadPIabcIGFxQCBM6(hUVyOQxBz1435kTIaSIGstkci5(raSPzvZy26a3CClOd628y0GugM2qkIaEYr6LitqaECnhxmciAacQ7F4(IHQETLvBafbW(P2ebyyVRM3TObPmmTaPic4jhPxImbbW(P2eb4zk1X(P20rl7GaOLDCj3pc4w7t)TObniGBTp93fXNBfPiszyqkIaEYr6LitqaECnhxmca0atMialCrODjveAicQic(DPYTzQJuwENKt)14ZsYebceebfebimU4i96iLL3j50Frqvea7NAteWT2N(7I4ZTIgKYTHueb8KJ0lrMGa84AoUyeaegxCKEDKYY7KC6Vi0qeKpAacQV1(0FxeFUvTbuea7NAteG88O2zB(dfniLBbsreWtosVezccWJR54IraqyCXr61rklVtYP)Iqdrq(ObiO(w7t)Dr85w1gqraSFQnrarklVtYP)ObPC7rkIaEYr6LitqaECnhxmcq(ObiO(w7t)Dr85w1gqraSFQnraCML6IYtTjAqkReKIiGNCKEjYeeGhxZXfJaKpAacQV1(0FxeFUvTbuea7NAteGxnVwNDWvRhnObbiFFZYJuePmmifrap5i9sKjiapUMJlgbOIimm95OnY4AKsNxnVw9tosVueAicrdqqTrgxJu68Q51QnGkcQkcnebvebVAgt8wraUi0MiqGGiOIiG5s6oKNJUVqE)5ORueGveGHurOHiG5s6oKNJMLsRUsrawragsfbvfbvraSFQnraGN6Wgw1ObPCBifrap5i9sKjiapUMJlgbaHXfhPxhPS8ojN(Jay)uBIaKNh1oBZFOObPClqkIaEYr6LitqaECnhxmcG9tb5UNVx3kcWkcYBl8LUHXe)yfbceebmxs3H8C0SuA1vkcWkcWqkcG9tTjcGiLli3nVd92bniLBpsreWtosVezccWJR54Ira(nLg1OThJ55shrkxqU(jhPxkcneb)Uu52m1NS7IN7A87CLwrWuIGslcnebfeHObiOU)H7lgQ61wwTburOHiOGiiF0aeu)wg6AV01CnsP2akcG9tTjcyuJ3MoIuUGC0Guwjifrap5i9sKjiapUMJlgbG5s6oKNJMLsR2aQiqGGiG5s6oKNJMLsRUsrawrOnLGay)uBIaoz3fp3rdszLgPic4jhPxImbb4X1CCXiaimU4i96iLL3j50FrOHiOGi43Lk3MPU)H7lgQ61wwn(SKmrOHiOIi43Lk3MP(KDx8CxJFNR0kcWkcQickreAhIaBAhxZ14dzPqQKOlsz5TAmNTkcMErOfIGQIabcIGkIaMlP7qEoAwkT6kfbyfb2p1Mo)Uu52mfHgIaMlP7qEoAwkT6kfbtjcTPerqvrqvea7NAteqKYY7KC6pAqkRurkIay)uBIaQEFP8uB6ydmJaEYr6Litqds52fPic4jhPxImbb4X1CCXiafebimU4i9AO7sRKOdCXUiLL3j50Fea7NAteaNzPUO8uBIgKYTeKIiGNCKEjYeeGhxZXfJaanWKPLhS81icWcxeApPia2p1MiaWtJuwE0GuggsrkIaEYr6LitqaECnhxmcqbracJlosVg6U0kj6axSlsz5Dso9xeAickicqyCXr61q3Lwjrh4IDNS7IN7ia2p1MiaVAETo7GRwpAqkddmifrap5i9sKjiapUMJlgbmm95OLVVPlsz5T6NCKEPi0qeuqe87sLBZuFYUlEURXNLKjcnebvebVAgt8wraUi0MiqGGiOIiG5s6oKNJUVqE)5ORueGveGHurOHiG5s6oKNJMLsRUsrawragsfbvfbvraSFQnraGN6Wgw1ObPmmTHuebW(P2ebiFFtRlwZrap5i9sKjObPmmTaPic4jhPxImbb4X1CCXiGObiOEng3c6WCs8AdOia2p1MiGrnEB6is5cYrdszyApsreWtosVezccWJR54Ira9fY7phTSSdN(lcWkcWOerGabriAacQxJXTGomNeV2akcG9tTjca8uh2WQgniLHrjifrap5i9sKjiapUMJlgb0xiV)C0YYoC6ViaRiaJsqaSFQnraqEs8Gguh(d(8GgKYWO0ifrap5i9sKjiapUMJlgbmm95OLVVPlsz5T6NCKEjcG9tTjcyuJ3MoIuUGC0Gg0Gg0Gqa]] )
end
