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


    spec:RegisterPack( "Havoc", 20201012, [[diu5mbqisOhrIu2KuyuKKoffXQKsjEffvZIeClPuHDrQFrrzyishduzzsrEMukMMuQ6AKi2gjs(MuQ04OivohfPQ5rrY9aL9HioOuQOwijXdLsjPjkLkYfjrQYgLsjLrsIu5KsPKyLGQ2jjQFsIuvlvkLu9uatfr1EH8xQAWcomQfl0JPYKj6YQ2mqFgHgnj1PL8APOMns3wQ2TOFR0WbPLd1ZP00vCDkSDq8DPKXlLsDEeL1trkZhb7NWi4qKJaK8CKYnrAtKchPW1KUj4AI0MAxeWqg0JaGYUMzIhbKC)iaLogY6qaqzYOllrKJaSRb2Deaq1nO8uB2wfZGdciAu0PTsIIiajphPCtK2ePWrkCnPBcUMifoLGaSqVdPSsA32fbOUKYNOicqERdbO0eH2P33ueu6mY5yrqPJHSob8knrqPVB24XIaCnPGi0ePnrkcakEbl6raknrOD69nfbLoJCoweu6yiRtaVsteu67MnESiaxtkicnrAtKkGxaVsteasgQv9oIaMlPienabVueSdpwriEWfFrWT9ipIq8eR0kcCkfbO43oGUZujrrOSIGCZRfWZUP20QHIVB7rEmhMz2KHAvVJ3o8yfWZUP20QHIVB7rEmhMzq3P2uap7MAtRgk(UTh5XCyMzyVVM3vi5(HXMMvnJzRhCZXVGEOBRJfWlGxPjck9A77mMlfHd5yYeHP6xeg1xey3SyrOSIadHlkhPxlGNDtTPfMSSydOJaE2n1MwZHzMBtRr)(otSCc4z3uBAnhMzqyCXr6vi5(HfPS8EjNURaeMACydtFoAWcBhFKURu)KJ0ljqWc9uQFymXpwDKYY7LC6oCKat120ogM(C0dMlQFb9yJk1p5i9steWZUP20AomZGW4IJ0RqY9dd6U0kj6bxSV)HvactnomfhM(C0Y33SC6NCKEzd3Uu52k19pCFXqvV2YQXVZvAnLs1a0atMwEWYvdjTHub8SBQnTMdZmimU4i9kKC)WGUlTsIEWf7JuwEVKt3vactnomimU4i96iLL3l509gQcAGjZuTRsAhdtFoAWcBhFKURu)KJ0lBlnrQjc4z3uBAnhMzqyCXr6vi5(HbDxALe9Gl2FYUpEURaeMACydtFoA57Bwo9tosVSHIdtFo6iTsPh0atM(jhPx2WTlvUTs9j7(45Ug)oxP1uQs0j1DUTBlnzsdqdmzA5blxnK0ePc4z3uBAnhMzqyCXr6vi5(H1IRPsIEWf7V1(0DFeFUzfGWuJdBy6ZrFR9P7(i(CZ6NCKEzdfHW4IJ0RHUlTsIEWf7JuwEVKt3BOiegxCKEn0DPvs0dUyF)d3WTlvUTs9T2NU7J4ZnRnGkGNDtTP1CyMbHXfhPxHK7hwlUMkj6bxSVV9NJrxbim14WgM(C09T)Cm66NCKEzdfJgGG6(2FogDTbub8SBQnTMdZmzzXgqhb8SBQnTMdZmhtPE2n1MEAzhfsUFyUDPYTvQqbcJOtQXVZvAHrQaELMiWUP20AomZGwUM9gq9GyMy)5Oqbct((ME7Aq9GyMy)5yjHub8knrGDtTP1CyMbTCn7nG6bXmX(ZrHcegObMmT8GLRgsG1gL0qvfzt74AU(KDRFb9yM41p5i9sceC7sLBRuFYUpEURXVZvAjboD7nrap7MAtR5WmBuJ3wEIuUGCfkqyrdqqn4P(42Jmw2FoA7WUMHPKgQgnab1vVVuEQn9SbM1gqjqqXObiOU)H7lgQ61wwTbuteWZUP20AomZCmL6z3uB6PLDui5(HDR9P7(i(CZkuGWgM(C03AF6UpIp3S(jhPx2qvimU4i96wCnvs0dUy)T2NU7J4ZntGG8rdqq9T2NU7J4ZnRnGAIaE2n1MwZHzg2i9SBQn90YokKC)WKVVz5uOaHnm95OLVVz50p5i9sb8SBQnTMdZmSr6z3uB6PLDui5(HLlUZub8c4z3uBA1UDPYTvcR)H7lgQ61wwfkqykQ6W0NJw((MLt)KJ0ljqacJlosVg6U0kj6bxSV)HnHabWIO6XJFNR0AQMuIaE2n1MwTBxQCBLMdZS(hUVyOQxBzvOaHnm95OLVVz50p5i9YgQQiBAhxZ1o18oLZpyoTGlUZtTP(jhPxsGGQUDPYTvQpz3hp31435kTK0ePnuvrimU4i96iLL3l50DceC7sLBRuhPS8EjNURXVZvAjHOtQ7CBBIjMiGNDtTPv72Lk3wP5WmZwjOb1hXCkvOaHPOChTTsqdQpI5uQNY1CLefWZUP20QD7sLBR0CyMnQVxTroc4z3uBA1UDPYTvAomZaxP8y)S(r99GuUFb8SBQnTA3Uu52knhMzNsMT40lVd)lGNDtTPv72Lk3wP5Wmd6o1MkuGWIgGG6(hUVyOQxBz1435kTK0KsiqaSiQE8435kTMsPivap7MAtR2TlvUTsZHzMH9(AExHK7hgrMEhtPhB9XDtfkqykom95Obp1hzmMjE9tosVKab3Uu52k1GN6JmgZeVgFwsMaE2n1MwTBxQCBLMdZmd7918Uche8UXNC)WCK5O7G3SC(iLTJcfiSObiOU)H7lgQ61wwTb0grdqqD)9ftMFb9udxj9s85Uvl3wzdvvecJlosVosz59soDNabfD7sLBRuhPS8EjNURXNLKzIaE2n1MwTBxQCBLMdZmd7918Ucj3pm2QgcN36XSPTyVBXmvHceM8rdqqnMnTf7DlMPE5JgGGA52kjqqv5JgGGA3Msd3uqUVYM9Yhnab1gqjqiAacQ7F4(IHQETLvJFNR0sstKAsJHXe)OvFMoQ1qDJPAdCeiawevpE87CLwt1ePc4z3uBA1UDPYTvAomZmS3xZ7kKC)WytZQMXS1dU54xqp0T1XkuGWC7sLBRu3)W9fdv9AlRg)oxP1uWrkbcUDPYTvQ7F4(IHQETLvJFNR0sIsrQaELMi0oDq2GoIaitPr21SiaUyrWWYr6fHAE3QfWZUP20QD7sLBR0CyMzyVVM3TkuGWIgGG6(hUVyOQxBz1gqfWZUP20QD7sLBR0CyM5yk1ZUP20tl7OqY9d7w7t3Tc4fWZUP20QLVVz5GbEQhByvRqbct1HPphTrgxJu6DQ51QFYr6LnIgGGAJmUgP07uZRvBa1KgQ6uZyI3cRjceufZL0FiphDFH8(ZrxjjWrAdmxs)H8C0SuA1vscCKAIjc4z3uBA1Y33SCMdZm55rT326hQcfimimU4i96iLL3l50Db8SBQnTA57BwoZHzgrkxqUFEh6TJcfim2nfK7F(EDljYBl8L(HXe)yjqaZL0FiphnlLwDLKahPc4z3uBA1Y33SCMdZSrnEB5js5cYvOaH52uAuJ2EmMNl9ePCb56NCKEzd3Uu52k1NS7JN7A87CLwtPunumAacQ7F4(IHQETLvBaTHIYhnab1VTHU2l9TwJuQnGkGNDtTPvlFFZYzomZoz3hp3vOaHH5s6pKNJMLsR2akbcyUK(d55OzP0QRKKMuIaE2n1MwT89nlN5Wmlsz59soDxHcegegxCKEDKYY7LC6EdfD7sLBRu3)W9fdv9AlRgFwswdvD7sLBRuFYUpEURXVZvAjrvL0oyt74AUgFilfsLe9rklVvJ5S52sBmHabvXCj9hYZrZsPvxjjUDPYTv2aZL0FiphnlLwDLMQjLyIjc4z3uBA1Y33SCMdZSQ3xkp1ME2aZc4z3uBA1Y33SCMdZmoZsDr5P2uHceMIqyCXr61q3Lwjrp4I9rklVxYP7c4z3uBA1Y33SCMdZmWtJuwEfkqyGgyY0YdwUAibw7jvap7MAtRw((MLZCyM5uZR1BhC18vOaHPiegxCKEn0DPvs0dUyFKYY7LC6EdfHW4IJ0RHUlTsIEWf7pz3hp3fWZUP20QLVVz5mhMzGN6Xgw1kuGWgM(C0Y330hPS8w9tosVSHIUDPYTvQpz3hp314ZsYAOQtnJjElSMiqqvmxs)H8C09fY7phDLKahPnWCj9hYZrZsPvxjjWrQjMiGNDtTPvlFFZYzomZKVVP1hR5c4z3uBA1Y33SCMdZSrnEB5js5cYvOaHfnab1RX4xqpMtIxBavap7MAtRw((MLZCyMbEQhByvRqbcRVqE)5OLLD40DsGtjeienab1RX4xqpMtIxBavap7MAtRw((MLZCyMb5jXdAq94p4ZJcfiS(c59NJww2Ht3jboLiGNDtTPvlFFZYzomZg14TLNiLlixHce2W0NJw((M(iLL3QFYr6Lc4fWZUP20QV1(0DFeFUzy3AF6UpIp3ScfimqdmzKaZ0rAdvD7sLBRuhPS8EjNURXNLKrGGIqyCXr61rklVxYP7MiGNDtTPvFR9P7(i(CZMdZm55rT326hQcfimimU4i96iLL3l509gYhnab13AF6UpIp3S2aQaE2n1Mw9T2NU7J4ZnBomZIuwEVKt3vOaHbHXfhPxhPS8EjNU3q(ObiO(w7t39r85M1gqfWZUP20QV1(0DFeFUzZHzgNzPUO8uBQqbct(ObiO(w7t39r85M1gqfWZUP20QV1(0DFeFUzZHzMtnVwVDWvZxHceM8rdqq9T2NU7J4ZnRnGkGxap7MAtR(w7t3TWGW4IJ0RqY9dd8uFKXyM49wYsNcfiSHPphn4P(iJXmXRFYr6LkaHPghMBxQCBLAWt9rgJzIxJpljRHQQQQIdtFoA57Bwo9tosVKaHObiOU)H7lgQ61wwTbutAOiegxCKEDlUMkj6bxSVV9NJrVbMlP)qEoAwkT6kjPnKAcbcSBki3)896wsK3w4l9dJj(XAIaE2n1Mw9T2NUBnhMzUnDphmpx6bPC)kuGWuvr5oA3MUNdMNl9GuUFF0aN6PCnxjXgkYUP2u7209CW8CPhKY9RR0dslIQhceanOup(o1mM49t1VPi6K6o32MiGxPjcTZZ8o0reMveSKLorOvnQfH2ANkcQWymt8IWIfH25vPNiuGIqnIqRIsfH4fbd7LIqRAuxPimQViKVThrO9kreS3TP0QGiSJ6JBv2lcg2lcsdCLefHCXDMkcrdSDebj3zIxlGNDtTPvFR9P7wZHzwKUR0VG(r99pFNmfkqyQQ4W0NJg8uFKXyM41p5i9sceC7sLBRudEQpYymt8A87CLwsAVsmPHIqyCXr61T4AQKOhCX((2Fog9gQQQIdtFoA57Bwo9tosVKaHObiOU)H7lgQ61wwTb0gk62Lk3wPosz59soDxJpljZecealIQhp(DUsRPGbhPMiGNDtTPvFR9P7wZHzwKUR0VG(r99pFNmfkqydtFoAWt9rgJzIx)KJ0lBaHXfhPxdEQpYymt8ElzPtap7MAtR(w7t3TMdZmIgmwwC6xqpBAhVJAfkqyQgnab19pCFXqvV2YQnG2WTlvUTsD)d3xmu1RTSA8zjzMqGq0aeu3)W9fdv9AlRg)oxPLKMucbcGfr1Jh)oxP1uWAdPc4z3uBA13AF6U1CyMbUod7LE20oUM7JN7kuGWSqpL6hgt8JvhPS8EjNUdhjWAIabmxs)H8C0SuA1vsIsrQaE2n1Mw9T2NUBnhMzqnWfizvs0hPSDuOaHzHEk1pmM4hRosz59soDhosG1ebcyUK(d55OzP0QRKeLIub8SBQnT6BTpD3AomZg13BKX1iLEWf7UcfiSObiOgFxZ0BTEWf7U2akbcrdqqn(UMP3A9Gl2DVBnY5yTDyxZMcosfWZUP20QV1(0DR5WmdxqHsVVsVfk7UaE2n1Mw9T2NUBnhMzTwmvc5v6X3UjNURqbclAacQ7F4(IHQETLvBaLabimU4i9AWt9rgJzI3BjlDc4z3uBA13AF6U1CyM1FFXK5xqp1WvsVeFUBvOaHbAGjZuTN0grdqqD)d3xmu1RTSAdOc4vAIGs3sLIqB9ZqRKOi0wJY9BfbWflcVTVZyUiG5K4fHflcnxuQienabTkicfOiaDT2ksVweANPTyYSIWGjteMvei(reg1xeOBRBhrWTlvUTsriY2lfHnfbgcxuosVi8896wTaE2n1Mw9T2NUBnhMz4ZqRKOhKY9BvOaHnmM4h9u97N1lRBk40kHabvvDymXpA1NPJAnu3qIPJuceggt8Jw9z6Owd1nMcwtKAsdvz3uqU)571TWGJabWIO6XJFNR0sstMEtmHabvhgt8JEQ(9Z6H6gFtKssBiTHQSBki3)896wyWrGayru94XVZvAjP9T3eteWlGNDtTPvNlUZuyqEs8Ggup(d(8OqbcBy6Zr33(ZXORFYr6LnIgGGAO4dLXxQLBRSXu9tcCc4z3uBA15I7m1CyMbEQhByvRqbctvimU4i96wCnvs0dUyFF7phJobcdtFoAJmUgP07uZRv)KJ0lBenab1gzCnsP3PMxR2aQjnu1PMXeVfwteiOkMlP)qEo6(c59NJUssGJ0gyUK(d55OzP0QRKe4i1eteWZUP20QZf3zQ5Wmd8uFKXyM4vOaHXUPGC)Z3RBjrEBHV0pmM4hlbcyUK(d55OzP0QRKK2qQaE2n1MwDU4otnhMzYZJAVT1pufkqyqyCXr61rklVxYP7c4z3uBA15I7m1CyMv9(s5P20Zgywap7MAtRoxCNPMdZmIuUGC)8o0BhfkqykcHXfhPx3IRPsIEWf77B)5y0BOk7McY9pFVULe5Tf(s)WyIFSeiG5s6pKNJMLsRUssGJuteWZUP20QZf3zQ5WmBuJ3wEIuUGCfkqyUnLg1OThJ55sprkxqU(jhPx2WTlvUTs9j7(45Ug)oxP1ukvdfJgGG6(hUVyOQxBz1gqBOO8rdqq9BBOR9sFR1iLAdOc4z3uBA15I7m1CyMDYUpEURqbcJDtb5(NVx3scCnuvrmxs)H8C0SuA1VTl7yjqaZL0FiphnlLwTbutAOiegxCKEDlUMkj6bxSVV9NJrxap7MAtRoxCNPMdZSiLL3l50DfkqyqyCXr61rklVxYP7c4z3uBA15I7m1CyMbEAKYYRqbcd0atMwEWYvdjWApPc4z3uBA15I7m1CyMDYUpEURqbctXHPphDKwP0dAGjt)KJ0lBOiegxCKEDlUMkj6bxS)w7t39r85MBG5s6pKNJMLsRUssC7sLBRuap7MAtRoxCNPMdZmoZsDr5P2uHceMQdtFoA57B6JuwER(jhPxsGGIqyCXr61T4AQKOhCX((2FogDceanWKPLhSC1yQ2qkbcrdqqD)d3xmu1RTSA87CLwtPetAOiegxCKEn0DPvs0dUyFKYY7LC6EdfHW4IJ0RBX1ujrp4I93AF6UpIp3SaE2n1MwDU4otnhMzo18A92bxnFfkqyQom95OLVVPpsz5T6NCKEjbckcHXfhPx3IRPsIEWf77B)5y0jqa0atMwEWYvJPAdPM0qrimU4i9AO7sRKOhCX((hUHIqyCXr61q3Lwjrp4I9rklVxYP7nuecJlosVUfxtLe9Gl2FR9P7(i(CZc4z3uBA15I7m1CyMDYUpEURqbcBy6ZrhPvk9GgyY0p5i9YgyUK(d55OzP0QRKe3Uu52kfWZUP20QZf3zQ5Wmt((MwFSMlGNDtTPvNlUZuZHzg4PESHvTcfimfhM(C09T)Cm66NCKEzdmxs)H8C09fY7phDLK4uZyI32wGJ0gdtFoA57B6JuwER(jhPxkGNDtTPvNlUZuZHzg4PrklVcfiS(c59NJww2Ht3jboLqGq0aeuVgJFb9yojETbub8SBQnT6CXDMAomZap1JnSQvOaH1xiV)C0YYoC6ojWPeceunAacQxJXVGEmNeV2aAdfhM(C09T)Cm66NCKEPjc4z3uBA15I7m1CyMb5jXdAq94p4ZJcfiS(c59NJww2Ht3jboLiGNDtTPvNlUZuZHz2OgVT8ePCb5kuGWgM(C0Y330hPS8w9tosVeba5yBTjs5MiTjsj103KsHaAX4SsIweqBLo0fpxkcTRiWUP2ueOLDSAb8ia2yuVyeaq1BRIaOLDSiYra5I7mfrosz4qKJaEYr6LivqaoCnhxmcyy6Zr33(ZXORFYr6LIqdriAacQHIpugFPwUTsrOHimv)IajIaCia2n1MiaipjEqdQh)bFEqds5MqKJaEYr6LivqaoCnhxmcqvracJlosVUfxtLe9Gl233(ZXOlceiicdtFoAJmUgP07uZRv)KJ0lfHgIq0aeuBKX1iLENAETAdOIGjIqdrqvrWPMXeVveGjcnjceiicQkcyUK(d55O7lK3Fo6kfbseb4iveAicyUK(d55OzP0QRueireGJurWerWeea7MAtea4PESHvnAqk3ge5iGNCKEjsfeGdxZXfJay3uqU)571TIajIG82cFPFymXpwrGabraZL0FiphnlLwDLIajIqBifbWUP2ebaEQpYymt8ObPC7rKJaEYr6LivqaoCnhxmcacJlosVosz59soDhbWUP2ebippQ92w)qrdszLGihbWUP2ebu9(s5P20Zgygb8KJ0lrQGgKYkfICeWtosVePccWHR54IrakkcqyCXr61T4AQKOhCX((2FogDrOHiOQiWUPGC)Z3RBfbseb5Tf(s)WyIFSIabcIaMlP)qEoAwkT6kfbseb4ivembbWUP2ebqKYfK7N3HE7GgKYTlICeWtosVePccWHR54IraUnLg1OThJ55sprkxqU(jhPxkcneb3Uu52k1NS7JN7A87CLwrWuIGsjcnebffHObiOU)H7lgQ61wwTburOHiOOiiF0aeu)2g6AV03AnsP2akcGDtTjcyuJ3wEIuUGC0Gu20Hihb8KJ0lrQGaC4AoUyea7McY9pFVUveireGteAicQkckkcyUK(d55OzP0QFBx2XkceiicyUK(d55OzP0QnGkcMicnebffbimU4i96wCnvs0dUyFF7phJocGDtTjc4KDF8ChniLn9iYrap5i9sKkiahUMJlgbaHXfhPxhPS8EjNUJay3uBIaIuwEVKt3rdsz4ifroc4jhPxIubb4W1CCXiaqdmzA5blxnIajWeH2tkcGDtTjca80iLLhniLHdoe5iGNCKEjsfeGdxZXfJauuegM(C0rALspObMm9tosVueAickkcqyCXr61T4AQKOhCX(BTpD3hXNBweAicyUK(d55OzP0QRueirey3uB6D7sLBRebWUP2ebCYUpEUJgKYW1eICeWtosVePccWHR54IraQkcdtFoA57B6JuwER(jhPxkceiickkcqyCXr61T4AQKOhCX((2FogDrGabra0atMwEWYvJiykrOnKkceiicrdqqD)d3xmu1RTSA87CLwrWuIGsebteHgIGIIaegxCKEn0DPvs0dUyFKYY7LC6Ui0qeuueGW4IJ0RBX1ujrp4I93AF6UpIp3mcGDtTjcGZSuxuEQnrdsz4AdICeWtosVePccWHR54IraQkcdtFoA57B6JuwER(jhPxkceiickkcqyCXr61T4AQKOhCX((2FogDrGabra0atMwEWYvJiykrOnKkcMicnebffbimU4i9AO7sRKOhCX((hweAickkcqyCXr61q3Lwjrp4I9rklVxYP7IqdrqrracJlosVUfxtLe9Gl2FR9P7(i(CZia2n1MiaNAETE7GRMpAqkdx7rKJaEYr6LivqaoCnhxmcyy6ZrhPvk9GgyY0p5i9srOHiG5s6pKNJMLsRUsrGerGDtTP3TlvUTsea7MAteWj7(45oAqkdNsqKJay3uBIaKVVP1hR5iGNCKEjsf0GugoLcroc4jhPxIubb4W1CCXiaffHHPphDF7phJU(jhPxkcnebmxs)H8C09fY7phDLIajIGtnJjERi0web4iveAicdtFoA57B6JuwER(jhPxIay3uBIaap1JnSQrdsz4Axe5iGNCKEjsfeGdxZXfJa6lK3FoAzzhoDxeireGtjIabcIq0aeuVgJFb9yojETbuea7MAtea4PrklpAqkdNPdroc4jhPxIubb4W1CCXiG(c59NJww2Ht3fbseb4uIiqGGiOQienab1RX4xqpMtIxBaveAickkcdtFo6(2FogD9tosVuembbWUP2ebaEQhByvJgKYWz6rKJaEYr6LivqaoCnhxmcOVqE)5OLLD40DrGeraoLGay3uBIaG8K4bnOE8h85bniLBIue5iGNCKEjsfeGdxZXfJagM(C0Y330hPS8w9tosVebWUP2ebmQXBlprkxqoAqdc4w7t3TiYrkdhICeWtosVePccyHIaSFqaSBQnraqyCXr6raqyQXraUDPYTvQbp1hzmMjEn(SKmrOHiOQiOQiOQiOOimm95OLVVz50p5i9srGabriAacQ7F4(IHQETLvBavemreAickkcqyCXr61T4AQKOhCX((2FogDrOHiG5s6pKNJMLsRUsrGerOnKkcMiceiicSBki3)896wrGerqEBHV0pmM4hRiyccWHR54IradtFoAWt9rgJzIx)KJ0lraqySp5(raGN6JmgZeV3sw6qds5MqKJaEYr6LivqaoCnhxmcqvrqrrqUJ2TP75G55spiL73hnWPEkxZvsueAickkcSBQn1UnDphmpx6bPC)6k9G0IO6reiqqeanOup(o1mM49t1ViykrGOtQ7CBlcMGay3uBIaCB6EoyEU0ds5(rds52Gihb8KJ0lrQGaC4AoUyeGQIGIIWW0NJg8uFKXyM41p5i9srGabrWTlvUTsn4P(iJXmXRXVZvAfbseH2RerWerOHiOOiaHXfhPx3IRPsIEWf77B)5y0fHgIGQIGQIGIIWW0NJw((MLt)KJ0lfbceeHObiOU)H7lgQ61wwTburOHiOOi42Lk3wPosz59soDxJpljtemreiqqealIQhp(DUsRiykyIaCKkcMGay3uBIaI0DL(f0pQV)57KHgKYThroc4jhPxIubb4W1CCXiGHPphn4P(iJXmXRFYr6LIqdracJlosVg8uFKXyM49wYshcGDtTjcis3v6xq)O((NVtgAqkRee5iGNCKEjsfeGdxZXfJauveIgGG6(hUVyOQxBz1gqfHgIGBxQCBL6(hUVyOQxBz14ZsYebtebceeHObiOU)H7lgQ61wwn(DUsRiqIi0KsebceebWIO6XJFNR0kcMcMi0gsraSBQnraenySS40VGE20oEh1ObPSsHihb8KJ0lrQGaC4AoUyeGf6Pu)WyIFS6iLL3l50D4ebsGjcnjceiicyUK(d55OzP0QRueireuksraSBQnraGRZWEPNnTJR5(45oAqk3UiYrap5i9sKkiahUMJlgbyHEk1pmM4hRosz59soDhorGeyIqtIabcIaMlP)qEoAwkT6kfbsebLIuea7MAteaudCbswLe9rkBh0Gu20Hihb8KJ0lrQGaC4AoUyeq0aeuJVRz6Twp4IDxBaveiqqeIgGGA8DntV16bxS7E3AKZXA7WUMfbtjcWrkcGDtTjcyuFVrgxJu6bxS7ObPSPhrocGDtTjcaxqHsVVsVfk7oc4jhPxIubniLHJue5iGNCKEjsfeGdxZXfJaIgGG6(hUVyOQxBz1gqfbceebimU4i9AWt9rgJzI3BjlDia2n1MiGwlMkH8k94B3Kt3rdsz4Gdroc4jhPxIubb4W1CCXiaqdmzIGPeH2tQi0qeIgGG6(hUVyOQxBz1gqraSBQnra93xmz(f0tnCL0lXN7w0GugUMqKJaEYr6LivqaoCnhxmcyymXp6P63pRxwxemLiaNwjIabcIGQIGQIWWyIF0Qpth1AOUreiremDKkceiicdJj(rR(mDuRH6grWuWeHMivemreAicQkcSBki3)896wraMiaNiqGGiawevpE87CLwrGerOjtViyIiyIiqGGiOQimmM4h9u97N1d1n(MiveireAdPIqdrqvrGDtb5(NVx3kcWeb4ebceebWIO6XJFNR0kcKicTV9IGjIGjia2n1Mia8zOvs0ds5(TObnia5bzd6GihPmCiYraSBQnraYYInGoiGNCKEjsf0GuUje5ia2n1Mia3MwJ(9DMy5qap5i9sKkObPCBqKJaEYr6LivqalueG9dcGDtTjcacJlospcactnocyy6Zrdwy74J0DL6NCKEPiqGGiyHEk1pmM4hRosz59soDhorGeyIGQIqBeH2Himm95Ohmxu)c6XgvQFYr6LIGjiaim2NC)iGiLL3l50D0GuU9iYrap5i9sKkiGfkcW(bbWUP2ebaHXfhPhbaHPghbOOimm95OLVVz50p5i9srOHi42Lk3wPU)H7lgQ61wwn(DUsRiykrqPeHgIaObMmT8GLRgrGerOnKIaGWyFY9JaGUlTsIEWf77Fy0GuwjiYrap5i9sKkiGfkcW(bbWUP2ebaHXfhPhbaHPghbaHXfhPxhPS8EjNUlcnebvfbqdmzIGPeH2vjIq7qegM(C0Gf2o(iDxP(jhPxkcTfrOjsfbtqaqySp5(raq3Lwjrp4I9rklVxYP7ObPSsHihb8KJ0lrQGawOia7hea7MAteaegxCKEeaeMACeWW0NJw((MLt)KJ0lfHgIGIIWW0NJosRu6bnWKPFYr6LIqdrWTlvUTs9j7(45Ug)oxPvemLiOQiq0j1DUTfH2Ii0KiyIi0qeanWKPLhSC1icKicnrkcacJ9j3pca6U0kj6bxS)KDF8ChniLBxe5iGNCKEjsfeWcfby)Gay3uBIaGW4IJ0JaGWuJJagM(C03AF6UpIp3S(jhPxkcnebffbimU4i9AO7sRKOhCX(iLL3l50DrOHiOOiaHXfhPxdDxALe9Gl23)WIqdrWTlvUTs9T2NU7J4ZnRnGIaGWyFY9JaAX1ujrp4I93AF6UpIp3mAqkB6qKJaEYr6LivqalueG9dcGDtTjcacJlospcactnocyy6Zr33(ZXORFYr6LIqdrqrriAacQ7B)5y01gqraqySp5(raT4AQKOhCX((2FogD0Gu20JihbWUP2ebill2a6GaEYr6Livqdsz4ifroc4jhPxIubb4W1CCXiaIoPg)oxPveGjcKIay3uBIaCmL6z3uB6PLDqa0Yo(K7hb42Lk3wjAqkdhCiYrap5i9sKkiahUMJlgbenab1GN6JBpYyz)5OTd7AweGjckreAicQkcrdqqD17lLNAtpBGzTburGabrqrriAacQ7F4(IHQETLvBavembbWUP2ebmQXBlprkxqoAqkdxtiYrap5i9sKkiahUMJlgbmm95OV1(0DFeFUz9tosVueAicQkcqyCXr61T4AQKOhCX(BTpD3hXNBweiqqeKpAacQV1(0DFeFUzTburWeea7MAteGJPup7MAtpTSdcGw2XNC)iGBTpD3hXNBgniLHRniYrap5i9sKkiahUMJlgbmm95OLVVz50p5i9sea7MAtea2i9SBQn90YoiaAzhFY9JaKVVz5qdsz4ApICeWtosVePccGDtTjcaBKE2n1MEAzheaTSJp5(ra5I7mfnObbafF32J8GihPmCiYrap5i9sKkObPCtiYraSBQnraq3P2eb8KJ0lrQGgKYTbroc4jhPxIubbKC)ia20SQzmB9GBo(f0dDBDmcGDtTjcGnnRAgZwp4MJFb9q3whJg0GaU1(0DFeFUze5iLHdroc4jhPxIubb4W1CCXiaqdmzIajWebthPIqdrqvrWTlvUTsDKYY7LC6UgFwsMiqGGiOOiaHXfhPxhPS8EjNUlcMGay3uBIaU1(0DFeFUz0GuUje5iGNCKEjsfeGdxZXfJaGW4IJ0RJuwEVKt3fHgIG8rdqq9T2NU7J4ZnRnGIay3uBIaKNh1EBRFOObPCBqKJaEYr6LivqaoCnhxmcacJlosVosz59soDxeAicYhnab13AF6UpIp3S2akcGDtTjcisz59soDhniLBpICeWtosVePccWHR54IraYhnab13AF6UpIp3S2akcGDtTjcGZSuxuEQnrdszLGihb8KJ0lrQGaC4AoUyeG8rdqq9T2NU7J4ZnRnGIay3uBIaCQ516TdUA(Obnia3Uu52krKJugoe5iGNCKEjsfeGdxZXfJauueuvegM(C0Y33SC6NCKEPiqGGiaHXfhPxdDxALe9Gl23)WIGjIabcIayru94XVZvAfbtjcnPeea7MAteq)d3xmu1RTSObPCtiYrap5i9sKkiahUMJlgbmm95OLVVz50p5i9srOHiOQiOOiWM2X1CTtnVt58dMtl4I78uBQFYr6LIabcIGQIGBxQCBL6t29XZDn(DUsRiqIi0ePIqdrqvrqrracJlosVosz59soDxeiqqeC7sLBRuhPS8EjNURXVZvAfbsebIoPUZTTiyIiyIiyccGDtTjcO)H7lgQ61ww0GuUniYrap5i9sKkiahUMJlgbOOii3rBRe0G6JyoL6PCnxjrea7MAteGTsqdQpI5uIgKYThrocGDtTjcyuFVAJCqap5i9sKkObPSsqKJay3uBIaaxP8y)S(r99GuUFeWtosVePcAqkRuiYraSBQnraNsMT40lVd)JaEYr6Livqds52froc4jhPxIubb4W1CCXiGObiOU)H7lgQ61wwn(DUsRiqIi0KsebceebWIO6XJFNR0kcMseuksraSBQnraq3P2eniLnDiYrap5i9sKkia2n1MiaIm9oMsp26J7MiahUMJlgbOOimm95Obp1hzmMjE9tosVueiqqeC7sLBRudEQpYymt8A8zjziGK7hbqKP3Xu6XwFC3eniLn9iYrap5i9sKkia2n1Miahzo6o4nlNpsz7GaC4AoUyeq0aeu3)W9fdv9AlR2aQi0qeIgGG6(7lMm)c6PgUs6L4ZDRwUTsrOHiOQiOOiaHXfhPxhPS8EjNUlceiickkcUDPYTvQJuwEVKt314ZsYebtqahe8UXNC)iahzo6o4nlNpsz7GgKYWrkICeWtosVePccGDtTjcGTQHW5TEmBAl27wmtraoCnhxmcq(ObiOgZM2I9UfZuV8rdqqTCBLIabcIGQIG8rdqqTBtPHBki3xzZE5JgGGAdOIabcIq0aeu3)W9fdv9AlRg)oxPveireAIurWerOHimmM4hT6Z0rTgQBebtjcTborGabraSiQE8435kTIGPeHMifbKC)ia2QgcN36XSPTyVBXmfniLHdoe5iGNCKEjsfea7MAteaBAw1mMTEWnh)c6HUTogb4W1CCXia3Uu52k19pCFXqvV2YQXVZvAfbtjcWrQiqGGi42Lk3wPU)H7lgQ61wwn(DUsRiqIiOuKIasUFeaBAw1mMTEWnh)c6HUTogniLHRje5iGNCKEjsfeGdxZXfJaIgGG6(hUVyOQxBz1gqraSBQnrag27R5DlAqkdxBqKJaEYr6LivqaSBQnraoMs9SBQn90YoiaAzhFY9JaU1(0DlAqdcq((MLdrosz4qKJaEYr6LivqaoCnhxmcqvryy6ZrBKX1iLENAET6NCKEPi0qeIgGGAJmUgP07uZRvBavemreAicQkco1mM4TIamrOjrGabrqvraZL0FiphDFH8(ZrxPiqIiahPIqdraZL0FiphnlLwDLIajIaCKkcMicMGay3uBIaap1JnSQrds5MqKJaEYr6LivqaoCnhxmcacJlosVosz59soDhbWUP2ebippQ92w)qrds52Gihb8KJ0lrQGaC4AoUyea7McY9pFVUveireK3w4l9dJj(XkceiicyUK(d55OzP0QRueireGJuea7MAtearkxqUFEh6TdAqk3Ee5iGNCKEjsfeGdxZXfJaCBknQrBpgZZLEIuUGC9tosVueAicUDPYTvQpz3hp31435kTIGPebLseAickkcrdqqD)d3xmu1RTSAdOIqdrqrrq(ObiO(Tn01EPV1AKsTbuea7MAteWOgVT8ePCb5ObPSsqKJaEYr6LivqaoCnhxmcaZL0FiphnlLwTburGabraZL0FiphnlLwDLIajIqtkbbWUP2ebCYUpEUJgKYkfICeWtosVePccWHR54IraqyCXr61rklVxYP7IqdrqrrWTlvUTsD)d3xmu1RTSA8zjzIqdrqvrWTlvUTs9j7(45Ug)oxPveireuveuIi0oeb20oUMRXhYsHujrFKYYB1yoBweAlIqBebtebceebvfbmxs)H8C0SuA1vkcKicSBQn9UDPYTvkcnebmxs)H8C0SuA1vkcMseAsjIGjIGjia2n1MiGiLL3l50D0GuUDrKJay3uBIaQEFP8uB6zdmJaEYr6LivqdszthICeWtosVePccWHR54IrakkcqyCXr61q3Lwjrp4I9rklVxYP7ia2n1MiaoZsDr5P2eniLn9iYrap5i9sKkiahUMJlgbaAGjtlpy5QreibMi0EsraSBQnraGNgPS8ObPmCKIihb8KJ0lrQGaC4AoUyeGIIaegxCKEn0DPvs0dUyFKYY7LC6Ui0qeuueGW4IJ0RHUlTsIEWf7pz3hp3raSBQnrao18A92bxnF0Gugo4qKJaEYr6LivqaoCnhxmcyy6ZrlFFtFKYYB1p5i9srOHiOOi42Lk3wP(KDF8CxJpljteAicQkco1mM4TIamrOjrGabrqvraZL0FiphDFH8(ZrxPiqIiahPIqdraZL0FiphnlLwDLIajIaCKkcMicMGay3uBIaap1JnSQrdsz4AcrocGDtTjcq((MwFSMJaEYr6Livqdsz4AdICeWtosVePccWHR54Irardqq9Am(f0J5K41gqraSBQnraJA82YtKYfKJgKYW1Ee5iGNCKEjsfeGdxZXfJa6lK3FoAzzhoDxeireGtjIabcIq0aeuVgJFb9yojETbuea7MAtea4PESHvnAqkdNsqKJaEYr6LivqaoCnhxmcOVqE)5OLLD40DrGeraoLGay3uBIaG8K4bnOE8h85bniLHtPqKJaEYr6LivqaoCnhxmcyy6ZrlFFtFKYYB1p5i9sea7MAteWOgVT8ePCb5ObnObnObHa]] )
end
