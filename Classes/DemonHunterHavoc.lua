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

                return app + floor( ( t - app ) / state.haste ) * state.haste
            end,

            interval = function () return state.haste end,
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
            duration = function () return 30 + ( pvptalent.demonic_origins.enabled and -15 or 0 ) + ( set_bonus.tier28_4pc > 0 and 6 or 0 ) end,
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


    local furySpent = 0

    local FURY = Enum.PowerType.Fury
    local lastFury = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "FURY" then
            local current = UnitPower( "player", FURY )

            if current < lastFury then
                furySpent = ( furySpent + lastFury - current ) % 60
            end

            lastFury = current
        end
    end )

    spec:RegisterStateExpr( "fury_spent", function ()
        return furySpent
    end )

    spec:RegisterHook( "spend", function( amt, resource )
        if set_bonus.tier28_4pc > 0 and resource == "fury" then
            fury_spent = fury_spent + amt
            if fury_spent > 60 then
                cooldown.metamorphosis.expires = cooldown.metamorphosis.expires - floor( fury_spent / 60 )
                fury_spent = fury_spent % 60
            end
        end
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

        fury_spent = nil
    end )


    spec:RegisterCycle( function ()
        if active_enemies == 1 then return end

        -- For Nemesis, we want to cast it on the lowest health enemy.
        if this_action == "nemesis" and Hekili:GetNumTTDsWithin( target.time_to_die ) > 1 then return "cycle" end
    end )

    
    -- Tier 28
    spec:RegisterGear( "tier28", 188898, 188896, 188894, 188893, 188892 )
    spec:RegisterSetBonuses( "tier28_2pc", 364438, "tier28_4pc", 363736 )    
    -- 2-Set - Deadly Dance - Increases Death Sweep and Annihilation / Blade Dance and Chaos Strike damage by 20%.
    -- 4-Set - Deadly Dance - Metamorphosis duration is increased by 6 sec. Every 60 Fury you consume reduces the cooldown of Metamorphosis by 1 sec.


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

            readyTime = function ()
                if prev_gcd[1].fel_rush then
                    return 3600
                end
                if settings.recommend_movement then return 0 end
                if buff.unbound_chaos.up and settings.unbound_movement then return 0 end
                return 3600
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

            readyTime = function ()
                if settings.recommend_movement then return 0 end
                return 3600
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

    spec:RegisterSetting( "unbound_movement", false, {
        name = "Recommend Movement for Unbound Chaos",
        desc = "When Recommend Movement is disabled, you can enable this option to override it and allow |T1247261:0|t Fel Rush to be recommended when Unbound Chaos is active.",
        type = "toggle",
        width = "full",
        disabled = function() return state.settings.recommend_movement end,
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
        width = "full",
        arg = function() return false end,
    } )


    spec:RegisterPack( "Havoc", 20220306, [[defYVbqiIslIsa5ruc6sucO2eLYNqugfKYPGuTkvrHxPkXSikULQu0UO4xisgMQKoMcAzOu9mvPY0OeY1Oe12uG03uLcJdrkoNQOiRtvknpevUhr1(qP8pkbOdQaHfsj5HkqnrkH6IQsvTrkbYhvfLAKucuNuvQsRermtvr1nvLQyNQI8tfiQHsjaSuvrjpLitvbCvfiITsja6RisPXIOQ9k0Fv0GL6WKwmepwvnzuDzWMrYNvOrJcNwPvRar61usnBc3gHDt1Vvz4OOJRkkQLd1ZfmDjxhP2oK8DvHXtjY5PuTEePA(OK9l64W4arjUwq8j2FLD2F9DVoOMHVb7w2YKMOuzNjeLyQFR1rik5kbeLSGvu3pkXuTloLhhikfoA8hIsslbTqR98bJvQkkHqVI696rKOexli(e7VYo7V(UxhuZW3GDlB53ikfyc)4tw(nEJOeJLZbpIeL4q4hLSyG48STGP9cWzBbROUFsY7rXFgzpOYKn7VYo7jjjjdMH6Jq4TjjVz2VhOuIdZKXf2q2QZZ2cGR2ZZMoOJq2wGqaQddztTJmQSbNhSaLT4g3F2kFqkDOaE21LTYKPWE2NlSNDDzJCHq2u7iJkyssEZSF(DbWZMMz2b7(F9XSpQSFpqPehMjJlSHSrJy9SpQSP2rgv2yGqxpKnQGj7cVU1qL9GT4SXAXaWzxmupBc1sOBIsmXh1kGOKfAHzBXaX5zBbt7fGZ2cwrD)Kel0cZ(9O4pJShuzYM9xzN9KKKel0cZEWmuFecVnjXcTWSFZSFpqPehMjJlSHSvNNTfaxTNNnDqhHSTaHauhgYMAhzuzdopybkBXnU)Sv(Gu6qb8SRlBLjtH9Spxyp76Yg5cHSP2rgvWKKyHwy2Vz2p)Ua4ztZm7GD)V(y2hv2VhOuIdZKXf2q2OrSE2hv2u7iJkBmqORhYgvWKDHx3AOYEWwC2yTya4SlgQNnHAj0njjjj6V2ZdgMy4FeiAjh5Qsa8jLqTd8hRpoRZsRNKO)AppyyIH)rGO1lYjfkfVkIaKXvcqEHx3AOMb7(FgexjdkvqdYhkZsjVWRBnuMHggAyshGjcnfLn0KTWRBnug2nm0WKoateAkkwSk86wdLzO5FNGFpCdNgR1EoBYl86wdLHDZ)ob)E4gonwR9C0ts0FTNhmmXW)iq06f5KcLIxfraY4kbiVWRBnuZGD)pdIRKbLkOb5SlZsjVWRBnug2nm0WKoateAkkBOjBHx3AOmdnm0WKoateAkkwSk86wdLHDZ)ob)E4gonwR9C2k86wdLzO5FNGFpCdNgR1Eo6jjwy2dscq2VVDiBRaLiBTYwCpY2cIgBp7hBXiBReRZZ2cIgBpBvC(y2p2Ir2WwmaC2wSITEuOyi7dNTfdeNNTvcLdHSPDbeczthwFm7bX452Z(zRKoKKO)AppyyIH)rGO1lYjfkfVkIaKXvcqoDaMGDyIakXKIgBF(pNV1EUmOubniVub4LbrSoFsrJTBaxrea3gAyAhOo8iy4k26rHIHjbWvHypNfRsfGxgoqC(erOCiyaxrea3MSyAhOo8iy0XZTphvshqpjr)1EEWWed)JarRxKtkkbey8XkvjZsjpC0cK15gM0HIwatatZS2ZzXkC0cK15guNqRvaZWjqbELKO)AppyyIH)rGO1lYjLI)QdZ6WyWRKKKel0cZ(9Te8PlGNnGcW2ZUwci7IbKT(RdN9gYwrPRqreGjjr)1EEqoFdyAMvsI(R98WlYj1)8anbmj0X9NKyHwy2KwiB(5KvzZVSlgBi7sXJqLD4HYK56Jzxx2ktMc7zBfn2xFmBs7r78Kel0cZw)1EE4f5KcdLIhHAQ01n1Q0V1YiwhMFU8HYukEeQ5sjNy93YbeAkkdcn2xFC(4ODUbde66bzwk5yAhOo8iyqOX(6JZhhTZTvQa8YWbIZNicLdbd4kIa4jjwy2K2TyC0v2dMHEHShGbCy7zF4STyfB9OqXGmzBLq5q2wS6Fi7hBXiBlOfhQSTsChp7dNTwz)UxYgn2Fj7hBXi7bW6kY(OY(zrVo6zxkEeQqsI(R98WlYjfkfVkIaKXvcqoIq5WKR(hKzPKllM2bQdpcMpd9cZIbCy72Kft7a1HhbdxXwpkummjaUke75YGsf0G8sfGxgQfhQjI4oUbCfraCwScmbHywkEeQGbrOCyYv)ddztoAV7nlvaEzkSUI5rnX0RBaxreah9KelmBs7wmYEWm0lK9amGdBxMSTsOCiBlw9pK9dgGNDXaYgHMIk7nKn)E4YK9JTyKTf0Idv2wjUJNTwzZ(lzJ2WxY(XwmYEaSUISpQSFw0RJE2ho7hBXi73pea)dzBfguRZwRSTOxYgT39s2p2Ir2dG1vK9rL9ZIED0ZUu8iuHKe9x75HxKtkukEvebiJReGCeHYHjx9piZsjht7a1HhbZNHEHzXaoSDzqPcAqocnfL5ZqVWSyah2UHFpCwSkvaEzOwCOMiI74gWvebWTfyccXSu8iubdIq5WKR(hgYMC0y)nlvaEzkSUI5rnX0RBaxreahDwSKTub4L5B)lG5rnzOfg4gWvebWTfyccXSu8iubdIq5WKR(hgYMC0SO3Sub4LPW6kMh1etVUbCfraC0tsSWSjTBXiBlwXwpkumit2wjuoKTfR(hYwRS9dtOISlfpcv2)J2RSFWa8SrOPOaE2i2ZwZoa)Z5k2E2aff8lzY(WzRIhQ9q2ALTfnWlztD4S9ZFtlgioF)jj6V2ZdViNuOu8Qicqgxja5icLdtU6FqMLsoM2bQdpcgUITEuOyysaCvi2ZLbLkOb5LkaVmulouteXDCd4kIa4SyHgcnfLHakL4WmzCHnyOzYIvPcWltH1vmpQjMEDd4kIa4SyXbeAkkdecG)HjcguRn0mr3wGjieZsXJqfmicLdtU6FyiBYr7DVzPcWltH1vmpQjMEDd4kIa4OZILSLkaVmCG489Baxrea3wGjieZsXJqfmicLdtU6FyiBYTOKelm7bjbi73pea)dzBfguRZgbOomKTvcLdzBXQ)HSxQS3k7nKTIsxHIiGSvNN9rrL9)ob)E4jj6V2ZdViNuOu8Qicqgxja5icLdtU6FqMJPCmeGsMLsEPcWldecG)HjcguRnGRicGB7FNGFpCdecG)HjcguRnyq52tsSWSjTBXi7bX452Z(zRKoKT68ShS9VaY(OY2cwlmWLjBf1T8SPdRpMTvcLdzBXQ)HSFWa8SlgagYEdzxmGSzEHWISITSNDDzdwQaNNT6zpiU3pBP1POfzBfwDEsI(R98WlYjfkfVkIaKXvcqoIq5WKR(hKzPKJPDG6WJGrhp3(CujDWwPcWlZ3(xaZJAYqlmWLbLkOb5Ou8QicWGiuom5Q)bB6VwuWKFLjSofTyIGvNto2ts0FTNhEroPqP4vreGmUsaYzENy9Xj1HNeqPYGsf0GCzlvaEz4aX573aUIiaUT)Dc(9WneqPehMjJlSbdgi01dKBqTrrJTB4a1(3IT39AsI(R98WlYjfkfVkIaKXvcqoZ7eRpoPo8erOCyYv)dYGsf0GCukEvebyqekhMC1)Gn0OOX2j3By53Sub4LHAXHAIiUJBaxrea)zW(RONKO)App8ICsHsXRIiazCLaKZ8oX6JtQdpb7WebuczqPcAqEPcWldhioF)gWvebWTjBPcWldIyD(KIgB3aUIiaUT)Dc(9WnGDyIakHbde66bYH24NBiul9myhDBu0y7goqT)TyJ9xtsSWSjTBXi7bX452Z(zRKoit2AvabZk76Yoy3)z)(2HSTcuISvNN9)ob)E4zth0riBQdNnHAPLGMiBonwR9CzYM2fqiKTwz)UbEjjr)1EE4f5KcLIxfraY4kbi)HU16JtQdp1XZTphvshKzPKJPDG6WJGrhp3(CujDqguQGgKll)ktyDkAXebRo3u7361hT9VtWVhUjSofTyIGvNBWaHUEGCJFUHqT0ZWISHMS)7e87HBiGsjomtgxydgAMSyP)ArbtWbIfcYhIUTatqiMLIhHkya7WebucYj)Djj6V2ZdViNuOu8Qicqgxja5p0TwFCsD4jXraErtidkvqdYlvaEziocWlAcd4kIa42KfHMIYqCeGx0egAMjj6V2ZdViNuFviM6V2ZNInuY4kbi)FNGFp8Kel0cZw)1EE4f5KI5(TEsZCsH1rcWlzk7mb5CG4Czwk5CG48z4OftkSosaEfy71Kel0cZw)1EE4f5KI5(TEsZCsH1rcWlziooi3bfdHsMLsoALkaVmCG489pvMmHAlWaUIiaUnkASDdhO2)wSj)DwMflmTduhEemiI15tkDlg2qOPOmiI15tkDlggAMOBdnz)3j43d3a2HjcOegmOC7SyrrJTtU39k6jj6V2ZdViNufd89yok0ffiZsjhHMIYqbIjYrGOyob4Lju63A5w2gAi0uuMLG4eATNpvASAOzYILSi0uugcOuIdZKXf2GHMj6jj6V2ZdViNuyAFQ)ApFk2qjJReGCoqC((Lju49xYhkZsjVub4LHdeNVFd4kIa4jj6V2ZdViNuyAFQ)ApFk2qjJReGC)WeQijjjXcZ(9sLTfGGxmSJZwDE2sRtrlY2kS68S50yT2ZZEdzFOaC2KMSdW)CEi7hBXi7Hdit2mPXmVafTqyp7hmwkQSFpqPehMjJlSHSxcM6VYUUS9RYgduyiWi7hBXiBnBX9aWzZPXATNNTfFdKKO)Appy(3j43dxobukXHzY4cBqgH681hN8nuQ)b5dFvMLsUSLkaVmCG489Baxrea32)qbU6Lbf4fd7yd4kIa42W0oqD4rWOJNBFoQKoyJFLjSofTyIGvNBWaHUEGnsJTatqiMLIhHkyiGsjomtgxydZLGP(lYXUn0(3j43d3a2HjcOegmqORhyJ9xzXc5cbBu7iJAIbcD9a5y3YONKO)Appy(3j43d)f5KIakL4WmzCHniJqD(6Jt(gk1)G8HVkZsjVub4LHdeNVFd4kIa42(hkWvVmOaVyyhBaxrea3gM2bQdpcgD8C7ZrL0bB8RmH1POfteS6Cdgi01dSrASfyccXSu8iubdbukXHzY4cByUem1Fro2TH2)ob)E4gWomraLWGbcD9aBS)QnzrP4vreGbrOCyYv)dSy9VtWVhUbrOCyYv)dgmqORhyB8ZneQLyXc5cbBu7iJAIbcD9a5y3YONKyHzpynuz)EGsjomtgxydzVuz)aY(Xkezpcv2A2u0cr2VVDiBRaLiBmqHHaJSvNN9JZjRY(qb4h4TGSLwNIwKTvy15zZPXATNN9HZEPYUyazd()O9cWzVHSvbXfQSpuaojr)1EEW8VtWVh(lYjfbukXHzY4cBqMLsUSLkaVmCG489Baxrea3gA)7e87HBa7Webucdgi01dSX(R2qt2)HcC1ldkWlg2XgWvebWzXIFLjSofTyIGvNBWaHUEGCYjnSyfyccXSu8iubdbukXHzY4cByUem1FX2q0zXc5cbBu7iJAIbcD9a5y3YONKO)Appy(3j43d)f5KIakL4WmzCHniZsjVub4LHdeNVFd4kIa42q7FNGFpCdyhMiGsyWaHUEGn2F1gAYIsXRIiadIq5WKR(hyX6FNGFpCdIq5WKR(hmyGqxpW24NBiulHUn0K9FOax9YGc8IHDSbCfraCwS4xzcRtrlMiy15gmqORhiNCsdlwbMGqmlfpcvWqaLsCyMmUWgMlbt9xSneDwSqUqWg1oYOMyGqxpqo2Tm6jj6V2ZdM)Dc(9WFroPyE1EUmlLCeAkkdbukXHzY4cBWGbcD9aBSBzwSqUqWg1oYOMyGqxpqUb91KelmBlgOuArLnDaYElGiBXnU)Ke9x75bZ)ob)E4ViNufEDRHAOmlLCukEvebyk86wd1my3)ZG4k5dTHgcnfLHakL4WmzCHnyOzYIfAYwQa8YWbIZ3VbCfraCBixiy7FNGFpCdbukXHzY4cBWGbcD9aBOrTJmQjgi01dKZcyHx3AOmdn)7e87HB40yT2ZTaZo6OZIfYfc2O2rg1ede66bYjN9xrNfl0qP4vreGPWRBnuZGD)pdIRKZUnzl86wdLHDZ)ob)E4gmOC7OZILSOu8QicWu41TgQzWU)NbXvjj6V2ZdM)Dc(9WFroPk86wdf7YSuYrP4vreGPWRBnuZGD)pdIRKZUn0qOPOmeqPehMjJlSbdntwSqt2sfGxgoqC((nGRicGBd5cbB)7e87HBiGsjomtgxydgmqORhydnQDKrnXaHUEGCwal86wdLHDZ)ob)E4gonwR9ClWSJo6SyHCHGnQDKrnXaHUEGCYz)v0zXcnukEvebyk86wd1my3)ZG4k5dTjBHx3AOmdn)7e87HBWGYTJolwYIsXRIiatHx3AOMb7(FgexLKO)Appy(3j43d)f5KkSofTyIGvNlZsjxw(vMW6u0IjcwDUP2V1RpAdnzX0oqD4rWOJNBFoQKoWIfA)7e87HBa7Webucdgi01dKt(4NBJIgBNn5V7v0r3gAY(VtWVhUHakL4WmzCHnyOzYIL(RffmbhiwiiFi6jj6V2ZdM)Dc(9WFroPkgWKbTxYSuYLTub4LHdeNVFd4kIa42KfLIxfraMh6wRpoPo8K4iaVOjSjlkfVkIammVtS(4K6WtcOuwSqOPOmu049OdZrL0bdnZKe9x75bZ)ob)E4ViNuGWEyvFYHpgazwk5OP)ArbtWbIfcSXHWIb(Su8iubwSW6YNakWlJY5bZ6S9Uxrpjr)1EEW8VtWVh(lYjfLacm(yLQKzPKhoAbY6CdQtO1kGz4eOaVSjlcnfLb1j0AfWmCcuGxtg0eQFl3qZuM1laJPzwZLGa4RwG8HYSEbymnZAokoeviFOmRxagtZSMlL8WrlqwNBqDcTwbmdNaf4vsssI(R98GHdeNVF5GDyIakHmlLCmTduhEem6452NJkPd2qt)1IcMGdeleyJdHfd8zP4rOcSyH1LpbuGxgLZdM1zJDl)MLkaVmF7FbmpQjdTWa)zm8v0TXVYewNIwmrWQZn1(TE9rB8RmH1POfteS6Cdgi01dKt(4NNKO)Appy4aX57)f5KIcetmDGHmlL8sfGxgAh5OD(8ZqVGbCfraCBi0uugAh5OD(8ZqVGHMPn0(mu8ieKZolwOH1LpbuGxgIdfqaEzwNTHVAdRlFcOaVmkNhmRZ2Wxrh9Ke9x75bdhioF)ViNuCqlgZWdaykZsjhLIxfrageHYHjx9pKKO)Appy4aX57)f5KAuOlkywabtiuYSuY1FTOGj4aXcb24qyXaFwkEeQalwyD5taf4Lr58GzD2g(AsI(R98GHdeNV)xKtQIb(Emhf6IcKzPK)pNtVLjaySwaFok0ffyaxrea32)ob)E4gWomraLWGbcD9a5guBYIqtrziGsjomtgxydgAM2KLdi0uugWsmVaWNpoANBOzMKO)Appy4aX57)f5KcSdteqjKzPKR)ArbtWbIfcSXHWIb(Su8iubwSW6YNakWlJY5bZ6SXULFZsfGxMV9VaMh1KHwyG)mg(Qn0KfLIxfrag6amb7WebuIjfn2(8FoFR9CwScmbHywkEeQaBdzXIIgBNCVXROBtwukEvebyEOBT(4K6WtD8C7ZrL0HKe9x75bdhioF)ViNuicLdtU6FqMLsokfVkIamicLdtU6FWMS)7e87HBiGsjomtgxydgmOC72q7FNGFpCdyhMiGsyWaHUEGnlZIfAyD5taf4Lr58GzD2(3j43d3gwx(eqbEzuopywNCSBz0rpjr)1EEWWbIZ3)lYj1sqCcT2ZNknwLzPKllcnfLzjioHw75tLgRgAMjj6V2ZdgoqC((FroPu3xgRqR9Czwk5YIsXRIiadZ7eRpoPo8erOCyYv)djj6V2ZdgoqC((FroPOabIq5GmlLCkASDdhO2)wSj3IEnjr)1EEWWbIZ3)lYjfecG)HjcguRts0FTNhmCG489)ICs9zOxygk8AniZsjxwukEvebyyENy9Xj1HNicLdtU6FWMSOu8QicWW8oX6JtQdpb7WebuIKe9x75bdhioF)ViNuuGyIPdmKzPKxQa8YWbIZNicLdbd4kIa42K9FNGFpCdyhMiGsyWGYTBdTpdfpcb5SZIfAyD5taf4LH4qbeGxM1zB4R2W6YNakWlJY5bZ6Sn8v0rpjr)1EEWWbIZ3)lYjfhiopmr2cK5B)lGzP4rOcYhkZsjht7a1Hhbdcn2xFC(4ODUnoGqtrzqOX(6JZhhTZnyGqxpqolkjr)1EEWWbIZ3)lYjffiMy6adzwk5YwQa8YWbIZNicLdbd4kIa42cmbHywkEeQaBdTH2NHIhHGC2zXcnSU8jGc8YqCOacWlZ6Sn8vByD5taf4Lr58GzD2g(k6ONKO)Appy4aX57)f5KIdeNhMiBbjj6V2ZdgoqC((FroPkg47XCuOlkqMLsocnfL5OR5rnXQpcgAMjj6V2ZdgoqC((FroPOaXethyiZsjN4qbeGxg(gk1)aBdTmlwi0uuMJUMh1eR(iyOzMKO)Appy4aX57)f5Kcf4JafTyIHcdAjZsjN4qbeGxg(gk1)aBdTCsI(R98GHdeNV)xKtQIb(Emhf6IcKzPKxQa8YWbIZNicLdbd4kIa4jjjj6V2Zdg)WeQqoyhMiGsiZsjht7a1HhbJoEU95Os6Gn00FTOGj4aXcb24qyXaFwkEeQalwyD5taf4Lr58GzD2gAz0TXVYewNIwmrWQZn1(TE9rB8RmH1POfteS6Cdgi01dKt(4NNKO)Appy8dtOIxKtkuGpcu0IjgkmOLmlL8sfGxgIJa8IMWaUIiaUneAkkdtmWuXa3WVhUTAja2gMKO)Appy8dtOIxKtkkqmX0bgYSuYrdHMIYq7ihTZNFg6fm0mzXcLIxfraMh6wRpoPo8K4iaVOjSHMSLkaVm0oYr785NHEbd4kIa4Syj7)ob)E4MLG4eATNpvASAWGYTJo62q7ZqXJqqo7SyHgwx(eqbEziouab4LzD2g(QnSU8jGc8YOCEWSoBdFfD0ts0FTNhm(HjuXlYjffiMikgRJGmlLC9xlkycoqSqGnoewmWNLIhHkWIfwx(eqbEzuopywNT39AsI(R98GXpmHkEroP4GwmMHhaWuMLsokfVkIamicLdtU6Fijr)1EEW4hMqfViNulbXj0ApFQ0yvMLsUSi0uuMLG4eATNpvASAOzMKO)Appy8dtOIxKtQrHUOGzbemHqjZsjxwukEvebyEOBT(4K6WtIJa8IMWgA6VwuWeCGyHaBCiSyGplfpcvGflSU8jGc8YOCEWSoBdFf9Ke9x75bJFycv8ICsvmW3J5OqxuGmlL8)5C6TmbaJ1c4ZrHUOad4kIa42(3j43d3a2HjcOegmqORhi3GAtweAkkdbukXHzY4cBWqZ0MSCaHMIYawI5fa(8Xr7CdnZKe9x75bJFycv8ICsb2HjcOeYSuYLfLIxfraMh6wRpoPo8K4iaVOjSHM(RffmbhiwiWghclg4ZsXJqfyXcRlFcOaVmkNhmRZ2qlBdnzrP4vreGHoatWomraLysrJTp)NZ3ApNfRatqiMLIhHkW2qwSOOX2j3B8k62KfLIxfraMh6wRpoPo8uhp3(CujDa9Ke9x75bJFycv8ICsHiuom5Q)bzwk5Ou8QicWGiuom5Q)HKe9x75bJFycv8ICsrbceHYbzwk5u0y7goqT)TytUf9AsI(R98GXpmHkEroPGqa8pmrWGADsI(R98GXpmHkEroPu3xgRqR9Czwk5OvQa8YWbIZNicLdbd4kIa4SyjlkfVkIamp0TwFCsD4jXraErtWIffn2UHdu7FlY9UxzXcHMIYqaLsCyMmUWgmyGqxpqolJUnzrP4vreGH5DI1hNuhEIiuom5Q)HKe9x75bJFycv8ICs9zOxygk8AniZsjhTsfGxgoqC(erOCiyaxreaNflzrP4vreG5HU16JtQdpjocWlAcwSOOX2nCGA)BrU39k62KfLIxfragM3jwFCsD4jbuQnzrP4vreGH5DI1hNuhEIiuom5Q)HKe9x75bJFycv8ICsb2HjcOeYSuYlvaEzqeRZNu0y7gWvebWTH1LpbuGxgLZdM1z7FNGFpCBYIsXRIiaZdDR1hNuhEQJNBFoQKoKKO)Appy8dtOIxKtkoqCEyISfiZ3(xaZsXJqfKpuMLsoM2bQdpcgeASV(48Xr7CBCaHMIYGqJ91hNpoANBWaHUEGCwusI(R98GXpmHkEroP4aX5HjYwqsI(R98GXpmHkEroPOaXethyiZsjx2sfGxgIJa8IMWaUIiaUnSU8jGc8YqCOacWlZ6S9zO4ri8mg(QTsfGxgoqC(erOCiyaxreapjr)1EEW4hMqfViNuuGarOCqMLsoXHciaVm8nuQ)b2gAzwSqOPOmhDnpQjw9rWqZmjr)1EEW4hMqfViNuuGyIPdmKzPKtCOacWldFdL6FGTHwMfl0qOPOmhDnpQjw9rWqZ0MSLkaVmehb4fnHbCfraC0ts0FTNhm(HjuXlYjfkWhbkAXedfg0sMLsoXHciaVm8nuQ)b2gA5Ke9x75bJFycv8ICsvmW3J5OqxuGmlL8sfGxgoqC(erOCiyaxreapkHcWH984tS)k7dho81HrPhk2xFmeLiTdIN1tV3NE2Vn7ShGbK9sW8Wv2uhoBY8dtOcYYgdpZ0lg4zhociBLUocTaE2FgQpcbtsYZxhYE4BZEWNJcWfWZMmmTduhEemKNSSRlBYW0oqD4rWqEd4kIa4KLnAdTe6MKKNVoK9Wb9Tzp4Zrb4c4ztgM2bQdpcgYtw21LnzyAhOo8iyiVbCfraCYYgTHwcDtssscPDq8SE69(0Z(TzN9amGSxcMhUYM6WztghOuArrw2y4zMEXap7WrazR01rOfWZ(Zq9riyssE(6q2V7Tzp4Zrb4c4ztgM2bQdpcgYtw21LnzyAhOo8iyiVbCfraCYYgTHwcDtsYZxhY(DVn7bFokaxapBYW0oqD4rWqEYYUUSjdt7a1Hhbd5nGRicGtw2AL97pi)8SrBOLq3KK881HSTO3M9GphfGlGNnzyAhOo8iyipzzxx2KHPDG6WJGH8gWvebWjlBTY(9hKFE2On0sOBssE(6q2w(Tzp4Zrb4c4ztgM2bQdpcgYtw21LnzyAhOo8iyiVbCfraCYYwRSF)b5NNnAdTe6MKKNVoK9B82Sh85OaCb8SjRub4LH8KLDDztwPcWld5nGRicGtw2AL97pi)8SrBOLq3KK881HSFJ3M9GphfGlGNnzyAhOo8iyipzzxx2KHPDG6WJGH8gWvebWjlB0gAj0njjpFDi7HdFB2d(CuaUaE2KHPDG6WJGH8KLDDztgM2bQdpcgYBaxreaNSS1k73Fq(5zJ2qlHUjjjjH0oiEwp9EF6z)2SZEagq2lbZdxztD4SjJjg(hbIwKLngEMPxmWZoCeq2kDDeAb8S)muFecMKKNVoKn7Vn7bFokaxapBYk86wdLzOH8KLDDztwHx3AOm1qd5jlB0y3sOBssE(6q2S)2Sh85OaCb8SjRWRBnug2nKNSSRlBYk86wdLPy3qEYYgn2Te6MKKNVoK97EB2d(CuaUaE2Kv41TgkZqd5jl76YMScVU1qzQHgYtw2OXULq3KK881HSF3BZEWNJcWfWZMScVU1qzy3qEYYUUSjRWRBnuMIDd5jlB0y3sOBssE(6q2w0BZEWNJcWfWZMmmTduhEemKNSSRlBYW0oqD4rWqEd4kIa4KLnASBj0njjpFDiBl)2Sh85OaCb8SjlC0cK15gYtw21LnzHJwGSo3qEd4kIa4KLnAdTe6MKKNVoKTLFB2d(CuaUaE2KfoAbY6Cd5jl76YMSWrlqwNBiVbCfraCYYwRSF)b5NNnAdTe6MKKKes7G4z9079PN9BZo7byazVempCLn1HZMS)Dc(9WjlBm8mtVyGND4iGSv66i0c4z)zO(iemjjpFDi7HVn7bFokaxapBY(hkWvVmK3aUIiaozzxx2K9puGREzipzzJ2qlHUjj55Rdzp8Tzp4Zrb4c4ztgM2bQdpcgYtw21LnzyAhOo8iyiVbCfraCYYgTHwcDtsYZxhYM93M9GphfGlGNnz)df4QxgYBaxreaNSSRlBY(hkWvVmKNSSrBOLq3KK881HSz)Tzp4Zrb4c4ztgM2bQdpcgYtw21LnzyAhOo8iyiVbCfraCYYgTHwcDtsYZxhY(DVn7bFokaxapBY(hkWvVmK3aUIiaozzxx2K9puGREzipzzJ2qlHUjj55RdzBrVn7bFokaxapBY(hkWvVmK3aUIiaozzxx2K9puGREzipzzJ2qlHUjj55RdzpOVn7bFokaxapBPLyWzhS7LAPSTaNDDz)CAnB(IAd75zFmbSwhoB0if6zJ2qlHUjj55RdzpOVn7bFokaxapBYk86wdLzOH8KLDDztwHx3AOm1qd5jlB0gAj0njjpFDi7b9Tzp4Zrb4c4ztwHx3AOmSBipzzxx2Kv41TgktXUH8KLnAdTe6MKKNVoK9B82Sh85OaCb8SLwIbNDWUxQLY2cC21L9ZP1S5lQnSNN9XeWAD4SrJuONnAdTe6MKKNVoK9B82Sh85OaCb8SjRWRBnuMHgYtw21LnzfEDRHYudnKNSSrBOLq3KK881HSFJ3M9GphfGlGNnzfEDRHYWUH8KLDDztwHx3AOmf7gYtw2On0sOBssE(6q2KM3M9GphfGlGNnzyAhOo8iyipzzxx2KHPDG6WJGH8gWvebWjlB0gAj0njjpFDi7HdFB2d(CuaUaE2KfoAbY6Cd5jl76YMSWrlqwNBiVbCfraCYYgTHwcDtssscPDq8SE69(0Z(TzN9amGSxcMhUYM6WztghioF)KLngEMPxmWZoCeq2kDDeAb8S)muFecMKKNVoK9W3M9GphfGlGNnzLkaVmKNSSRlBYkvaEziVbCfraCYYgTHwcDtsYZxhYE4BZEWNJcWfWZMmmTduhEemKNSSRlBYW0oqD4rWqEd4kIa4KLnAdTe6MKKNVoK9G(2Sh85OaCb8SjRub4LH8KLDDztwPcWld5nGRicGtw2On0sOBssE(6q2dTO3M9GphfGlGNnzyAhOo8iyipzzxx2KHPDG6WJGH8gWvebWjlB0gAj0njjjjVxcMhUaE2woB9x75zl2qfmjjrjLUyC4OK0sm4OKydvioquYpmHkIdeFAyCGOe4kIa4rRIsF8waE1OeM2bQdpcgD8C7ZrL0bd4kIa4zBlB0Yw)1IcMGdeleYMTS5qyXaFwkEeQq2SyLnwx(eqbEzuopywpB2YEOLZg9STLn)ktyDkAXebRo3u7361hZ2w28RmH1POfteS6Cdgi01dzto5zp(5rj9x75rjWomraLiwXNypoqucCfra8OvrPpElaVAuQub4LH4iaVOjmGRicGNTTSrOPOmmXatfdCd)E4zBl7AjGSzl7Hrj9x75rjuGpcu0IjgkmOvSIp9U4arjWvebWJwfL(4Ta8Qrj0YgHMIYq7ihTZNFg6fm0mZMfRSrP4vreG5HU16JtQdpjocWlAISTLnAzlB2LkaVm0oYr785NHEbd4kIa4zZIv2YM9)ob)E4MLG4eATNpvASAWGYTNn6zJE22YgTS)mu8ieYwE2SNnlwzJw2yD5taf4LH4qbeGxM1ZMTSh(A22YgRlFcOaVmkNhmRNnBzp81SrpB0Js6V2ZJsuGyIPdmIv8jlkoqucCfra8OvrPpElaVAus)1IcMGdeleYMTS5qyXaFwkEeQq2SyLnwx(eqbEzuopywpB2Y(DVgL0FTNhLOaXerXyDeIv8jlhhikbUIiaE0QO0hVfGxnkHsXRIiadIq5WKR(hIs6V2ZJsCqlgZWdaygR4tdACGOe4kIa4rRIsF8waE1OKSzJqtrzwcItO1E(uPXQHMzus)1EEuAjioHw75tLgRXk(0BehikbUIiaE0QO0hVfGxnkjB2Ou8QicW8q3A9Xj1HNehb4fnr22YgTS1FTOGj4aXcHSzlBoewmWNLIhHkKnlwzJ1LpbuGxgLZdM1ZMTSh(A2OhL0FTNhLgf6IcMfqWecvSIprAIdeLaxreapAvu6J3cWRgL(NZP3YeamwlGphf6IcmGRicGNTTS)3j43d3a2HjcOegmqORhYMCzpOzBlBzZgHMIYqaLsCyMmUWgm0mZ2w2YMnhqOPOmGLyEbGpFC0o3qZmkP)AppkvmW3J5OqxuqSIp9mfhikbUIiaE0QO0hVfGxnkjB2Ou8QicW8q3A9Xj1HNehb4fnr22YgTS1FTOGj4aXcHSzlBoewmWNLIhHkKnlwzJ1LpbuGxgLZdM1ZMTShA5STLnAzlB2Ou8QicWqhGjyhMiGsmPOX2N)Z5BTNNnlwzhyccXSu8iuHSzl7HzZIv2u0y7ztUSFJxZg9STLTSzJsXRIiaZdDR1hNuhEQJNBFoQKoKn6rj9x75rjWomraLiwXNg(ACGOe4kIa4rRIsF8waE1OekfVkIamicLdtU6FikP)AppkHiuom5Q)HyfFA4W4arjWvebWJwfL(4Ta8QrjkASDdhO2)wzZM8STOxJs6V2ZJsuGarOCiwXNgYECGOK(R98OeecG)HjcguRJsGRicGhTkwXNg(U4arjWvebWJwfL(4Ta8Qrj0YUub4LHdeNprekhcgWvebWZMfRSLnBukEvebyEOBT(4K6WtIJa8IMiBwSYMIgB3WbQ9Vv2Kl739A2SyLncnfLHakL4WmzCHnyWaHUEiBYLTLZg9STLTSzJsXRIiadZ7eRpoPo8erOCyYv)drj9x75rj19LXk0AppwXNgArXbIsGRicGhTkk9XBb4vJsOLDPcWldhioFIiuoemGRicGNnlwzlB2Ou8QicW8q3A9Xj1HNehb4fnr2SyLnfn2UHdu7FRSjx2V71SrpBBzlB2Ou8QicWW8oX6JtQdpjGsZ2w2YMnkfVkIammVtS(4K6WteHYHjx9peL0FTNhL(m0lmdfETgIv8PHwooqucCfra8OvrPpElaVAuQub4LbrSoFsrJTBaxreapBBzJ1LpbuGxgLZdM1ZMTS1FTNp)3j43dpBBzlB2Ou8QicW8q3A9Xj1HN6452NJkPdrj9x75rjWomraLiwXNgoOXbIsGRicGhTkkP)AppkXbIZdtKTGO0hVfGxnkHPDG6WJGbHg7RpoFC0o3aUIiaE22YMdi0uugeASV(48Xr7Cdgi01dztUSTOO03(xaZsXJqfIpnmwXNg(gXbIs6V2ZJsCG48WezlikbUIiaE0QyfFAiPjoqucCfra8OvrPpElaVAus2SlvaEziocWlAcd4kIa4zBlBSU8jGc8YqCOacWlZ6zZw2FgkEecz)mYE4RzBl7sfGxgoqC(erOCiyaxreapkP)AppkrbIjMoWiwXNg(mfhikbUIiaE0QO0hVfGxnkrCOacWldFdL6FiB2YEOLZMfRSrOPOmhDnpQjw9rWqZmkP)AppkrbceHYHyfFI9xJdeLaxreapAvu6J3cWRgLiouab4LHVHs9pKnBzp0YzZIv2OLncnfL5OR5rnXQpcgAMzBlBzZUub4LH4iaVOjmGRicGNn6rj9x75rjkqmX0bgXk(e7dJdeLaxreapAvu6J3cWRgLiouab4LHVHs9pKnBzp0Yrj9x75rjuGpcu0IjgkmOvSIpXo7XbIsGRicGhTkk9XBb4vJsLkaVmCG48jIq5qWaUIiaEus)1EEuQyGVhZrHUOGyfROehOuArfhi(0W4arj9x75rj(gW0mROe4kIa4rRIv8j2JdeL0FTNhL(NhOjGjHoU)Oe4kIa4rRIv8P3fhikbUIiaE0QO0XmkfGkkP)AppkHsXRIiGOekfpDLaIsicLdtU6Fik9XBb4vJsYMnM2bQdpcMpd9cZIbCy7gWvebWZ2w2YMnM2bQdpcgUITEuOyysaCvi2ZnGRicGhL4q4JxM1EEuI0UfJJUYEWm0lK9amGdBp7dNTfRyRhfkgKjBRekhY2Iv)dz)ylgzBbT4qLTvI74zF4S1k739s2OX(lz)ylgzpawxr2hv2pl61rp7sXJqfIsOubneLkvaEzOwCOMiI74gWvebWZMfRSdmbHywkEeQGbrOCyYv)ddZMn5zJw2Vl73m7sfGxMcRRyEutm96gWvebWZg9yfFYIIdeLaxreapAvu6ygLcqfL0FTNhLqP4vrequcLINUsarjeHYHjx9peL(4Ta8QrjmTduhEemFg6fMfd4W2nGRicGhL4q4JxM1EEuI0UfJShmd9czpad4W2LjBRekhY2Iv)dz)Gb4zxmGSrOPOYEdzZVhUmz)ylgzBbT4qLTvI74zRv2S)s2On8LSFSfJShaRRi7Jk7Nf96ON9HZ(XwmY(9dbW)q2wHb16S1kBl6LSr7DVK9JTyK9ayDfzFuz)SOxh9SlfpcvikHsf0qucHMIY8zOxywmGdB3WVhE2SyLDPcWld1Id1erCh3aUIiaE22YoWeeIzP4rOcgeHYHjx9pmmB2KNnAzZE2Vz2LkaVmfwxX8OMy61nGRicGNn6zZIv2YMDPcWlZ3(xaZJAYqlmWnGRicGNTTSdmbHywkEeQGbrOCyYv)ddZMn5zJw2wu2Vz2LkaVmfwxX8OMy61nGRicGNn6Xk(KLJdeLaxreapAvu6ygLcqfL0FTNhLqP4vrequcLINUsarjeHYHjx9peL(4Ta8QrjmTduhEemCfB9OqXWKa4QqSNBaxreapkXHWhVmR98OePDlgzBXk26rHIbzY2kHYHSTy1)q2ALTFycvKDP4rOY(F0EL9dgGNncnffWZgXE2A2b4FoxX2ZgOOGFjt2hoBv8qThYwRSTObEjBQdNTF(BAXaX57pkHsf0quQub4LHAXHAIiUJBaxreapBwSYgTSrOPOmeqPehMjJlSbdnZSzXk7sfGxMcRRyEutm96gWvebWZMfRS5acnfLbcbW)WebdQ1gAMzJE22YoWeeIzP4rOcgeHYHjx9pmmB2KNnAz)USFZSlvaEzkSUI5rnX0RBaxreapB0ZMfRSLn7sfGxgoqC((nGRicGNTTSdmbHywkEeQGbrOCyYv)ddZMn5zBrXk(0GghikbUIiaE0QO0XmkHHaurj9x75rjukEvebeLqP4PRequcrOCyYv)drPpElaVAuQub4LbcbW)WebdQ1gWvebWZ2w2)7e87HBGqa8pmrWGATbdk3EuIdHpEzw75rPbjbi73pea)dzBfguRZgbOomKTvcLdzBXQ)HSxQS3k7nKTIsxHIiGSvNN9rrL9)ob)E4Xk(0BehikbUIiaE0QO0XmkfGkkP)AppkHsXRIiGOekfpDLaIsicLdtU6Fik9XBb4vJsyAhOo8iy0XZTphvshmGRicGNTTSlvaEz(2)cyEutgAHbUbCfra8OehcF8YS2ZJsK2TyK9Gy8C7z)SvshYwDE2d2(xazFuzBbRfg4YKTI6wE20H1hZ2kHYHSTy1)q2pyaE2fdadzVHSlgq2mVqyrwXw2ZUUSblvGZZw9She37NT06u0ISTcRopkHsf0qucLIxfrageHYHjx9pKTTS1FTOGj)ktyDkAXebRopBYLn7Xk(ePjoqucCfra8OvrPJzukavus)1EEucLIxfrarjuQGgIsYMDPcWldhioF)gWvebWZ2w2)7e87HBiGsjomtgxydgmqORhYMCzpOzBlBkASDdhO2)wzZw2V71OekfpDLaIsmVtS(4K6WtcO0yfF6zkoqucCfra8OvrPJzukavus)1EEucLIxfrarjuQGgIsOu8QicWGiuom5Q)HSTLnAztrJTNn5Y(nSC2Vz2LkaVmulouteXDCd4kIa4z)mYM9xZg9OekfpDLaIsmVtS(4K6WteHYHjx9peR4tdFnoqucCfra8OvrPJzukavus)1EEucLIxfrarjuQGgIsLkaVmCG489BaxreapBBzlB2LkaVmiI15tkASDd4kIa4zBl7)Dc(9WnGDyIakHbde66HSjx2OL94NBiulL9ZiB2Zg9STLnfn2UHdu7FRSzlB2FnkHsXtxjGOeZ7eRpoPo8eSdteqjIv8PHdJdeLaxreapAvu6ygLcqfL0FTNhLqP4vrequcLINUsarPh6wRpoPo8uhp3(CujDik9XBb4vJsyAhOo8iy0XZTphvshmGRicGhL4q4JxM1EEuI0UfJSheJNBp7NTs6GmzRvbemRSRl7GD)N97BhY2kqjYwDE2)7e87HNnDqhHSPoC2eQLwcAIS50yT2ZLjBAxaHq2AL97g4LOekvqdrjzZMFLjSofTyIGvNBQ9B96JzBl7)Dc(9WnH1POfteS6Cdgi01dztUSh)CdHAPSFgzBrzBlB0Yw2S)3j43d3qaLsCyMmUWgm0mZMfRS1FTOGj4aXcHSLN9WSrpBBzhyccXSu8iubdyhMiGsKn5KN97Iv8PHShhikbUIiaE0QO0XmkfGkkP)AppkHsXRIiGOekvqdrPsfGxgIJa8IMWaUIiaE22Yw2SrOPOmehb4fnHHMzucLINUsarPh6wRpoPo8K4iaVOjIv8PHVloqucCfra8Ovrj9x75rPVket9x75tXgQOKyd10vcik9VtWVhESIpn0IIdeLaxreapAvu6J3cWRgLqOPOmuGyICeikMtaEzcL(ToB5zB5STLnAzJqtrzwcItO1E(uPXQHMz2SyLTSzJqtrziGsjomtgxydgAMzJEus)1EEuQyGVhZrHUOGyfFAOLJdeLaxreapAvu6J3cWRgLkvaEz4aX573aUIiaEuku49xXNggL0FTNhLW0(u)1E(uSHkkj2qnDLaIsCG489hR4tdh04arjWvebWJwfL0FTNhLW0(u)1E(uSHkkj2qnDLaIs(HjurSIvuIdeNV)4aXNgghikbUIiaE0QO0hVfGxnkHPDG6WJGrhp3(CujDWaUIiaE22YgTS1FTOGj4aXcHSzlBoewmWNLIhHkKnlwzJ1LpbuGxgLZdM1ZMTSz3Yz)MzxQa8Y8T)fW8OMm0cdCd4kIa4z)mYE4RzJE22YMFLjSofTyIGvNBQ9B96JzBlB(vMW6u0IjcwDUbde66HSjN8Sh)8OK(R98OeyhMiGseR4tShhikbUIiaE0QO0hVfGxnkvQa8Yq7ihTZNFg6fmGRicGNTTSrOPOm0oYr785NHEbdnZSTLnAz)zO4riKT8SzpBwSYgTSX6YNakWldXHciaVmRNnBzp81STLnwx(eqbEzuopywpB2YE4RzJE2OhL0FTNhLOaXethyeR4tVloqucCfra8OvrPpElaVAucLIxfrageHYHjx9peL0FTNhL4GwmMHhaWmwXNSO4arjWvebWJwfL(4Ta8Qrj9xlkycoqSqiB2YMdHfd8zP4rOczZIv2yD5taf4Lr58Gz9Szl7HVgL0FTNhLgf6IcMfqWecvSIpz54arjWvebWJwfL(4Ta8QrP)5C6TmbaJ1c4ZrHUOad4kIa4zBl7)Dc(9WnGDyIakHbde66HSjx2dA22Yw2SrOPOmeqPehMjJlSbdnZSTLTSzZbeAkkdyjMxa4ZhhTZn0mJs6V2ZJsfd89yok0ffeR4tdACGOe4kIa4rRIsF8waE1OK(RffmbhiwiKnBzZHWIb(Su8iuHSzXkBSU8jGc8YOCEWSE2SLn7wo73m7sfGxMV9VaMh1KHwyGBaxreap7Nr2dFnBBzJw2YMnkfVkIam0byc2HjcOetkAS95)C(w75zZIv2bMGqmlfpcviB2YEy2SyLnfn2E2Kl7341SrpBBzlB2Ou8QicW8q3A9Xj1HN6452NJkPdrj9x75rjWomraLiwXNEJ4arjWvebWJwfL(4Ta8QrjukEvebyqekhMC1)q22Yw2S)3j43d3qaLsCyMmUWgmyq52Z2w2OL9)ob)E4gWomraLWGbcD9q2SLTLZMfRSrlBSU8jGc8YOCEWSE2SLT(R985)ob)E4zBlBSU8jGc8YOCEWSE2KlB2TC2ONn6rj9x75rjeHYHjx9peR4tKM4arjWvebWJwfL(4Ta8QrjzZgHMIYSeeNqR98PsJvdnZOK(R98O0sqCcT2ZNknwJv8PNP4arjWvebWJwfL(4Ta8QrjzZgLIxfragM3jwFCsD4jIq5WKR(hIs6V2ZJsQ7lJvO1EESIpn814arjWvebWJwfL(4Ta8QrjkASDdhO2)wzZM8STOxJs6V2ZJsuGarOCiwXNgomoqus)1EEuccbW)WebdQ1rjWvebWJwfR4tdzpoqucCfra8OvrPpElaVAus2SrP4vreGH5DI1hNuhEIiuom5Q)HSTLTSzJsXRIiadZ7eRpoPo8eSdteqjIs6V2ZJsFg6fMHcVwdXk(0W3fhikbUIiaE0QO0hVfGxnkvQa8YWbIZNicLdbd4kIa4zBlBzZ(FNGFpCdyhMiGsyWGYTNTTSrl7pdfpcHSLNn7zZIv2OLnwx(eqbEziouab4Lz9Szl7HVMTTSX6YNakWlJY5bZ6zZw2dFnB0Zg9OK(R98OefiMy6aJyfFAOffhikbUIiaE0QOK(R98Oehiopmr2cIsF8waE1OeM2bQdpcgeASV(48Xr7Cd4kIa4zBlBoGqtrzqOX(6JZhhTZnyGqxpKn5Y2IIsF7Fbmlfpcvi(0WyfFAOLJdeLaxreapAvu6J3cWRgLKn7sfGxgoqC(erOCiyaxreapBBzhyccXSu8iuHSzl7HzBlB0Y(ZqXJqiB5zZE2SyLnAzJ1LpbuGxgIdfqaEzwpB2YE4RzBlBSU8jGc8YOCEWSE2SL9WxZg9SrpkP)AppkrbIjMoWiwXNgoOXbIs6V2ZJsCG48WezlikbUIiaE0QyfFA4BehikbUIiaE0QO0hVfGxnkHqtrzo6AEutS6JGHMzus)1EEuQyGVhZrHUOGyfFAiPjoqucCfra8OvrPpElaVAuI4qbeGxg(gk1)q2SL9qlNnlwzJqtrzo6AEutS6JGHMzus)1EEuIcetmDGrSIpn8zkoqucCfra8OvrPpElaVAuI4qbeGxg(gk1)q2SL9qlhL0FTNhLqb(iqrlMyOWGwXk(e7VghikbUIiaE0QO0hVfGxnkvQa8YWbIZNicLdbd4kIa4rj9x75rPIb(Emhf6IcIvSIs)7e87Hhhi(0W4arjWvebWJwfL(4Ta8QrjzZUub4LHdeNVFd4kIa4zBl7)HcC1ldkWlg2XzBlBmTduhEem6452NJkPdgWvebWZ2w28RmH1POfteS6Cdgi01dzZw2KMSTLDGjieZsXJqfmeqPehMjJlSH5sWu)v2KlB2Z2w2OL9)ob)E4gWomraLWGbcD9q2SLn7VMnlwzJCHq22YMAhzutmqORhYMCzZULZg9OKqD(6Jt(gk1)quA4Rrj9x75rjcOuIdZKXf2quIdHpEzw75rP3lv2wacEXWooB15zlTofTiBRWQZZMtJ1App7nK9HcWztAYoa)Z5HSFSfJShoGmzZKgZ8cu0cH9SFWyPOY(9aLsCyMmUWgYEjyQ)k76Y2VkBmqHHaJSFSfJS1Sf3daNnNgR1EE2w8nqSIpXECGOe4kIa4rRIsF8waE1OuPcWldhioF)gWvebWZ2w2)df4QxguGxmSJZ2w2yAhOo8iy0XZTphvshmGRicGNTTS5xzcRtrlMiy15gmqORhYMTSjnzBl7atqiMLIhHkyiGsjomtgxydZLGP(RSjx2SNTTSrl7)Dc(9WnGDyIakHbde66HSzlB2FnBBzlB2Ou8QicWGiuom5Q)HSzXk7)Dc(9WnicLdtU6FWGbcD9q2SL94NBiulLnlwzJCHq22YMAhzutmqORhYMCzZULZg9OK(R98OebukXHzY4cBikjuNV(4KVHs9peLg(ASIp9U4arjWvebWJwfL0FTNhLiGsjomtgxydrjoe(4LzTNhLgSgQSFpqPehMjJlSHSxQSFaz)yfIShHkBnBkAHi733oKTvGsKngOWqGr2QZZ(X5KvzFOa8d8wq2sRtrlY2kS68S50yT2ZZ(WzVuzxmGSb)F0Eb4S3q2QG4cv2hkahL(4Ta8QrjzZUub4LHdeNVFd4kIa4zBlB0Y(FNGFpCdyhMiGsyWaHUEiB2YM9xZ2w2OLTSz)puGREzqbEXWooBwSYMFLjSofTyIGvNBWaHUEiBYjpBst2SyLDGjieZsXJqfmeqPehMjJlSH5sWu)v2SL9WSrpBwSYg5cHSTLn1oYOMyGqxpKn5YMDlNn6Xk(KffhikbUIiaE0QO0hVfGxnkvQa8YWbIZ3VbCfra8STLnAz)VtWVhUbSdteqjmyGqxpKnBzZ(RzBlB0Yw2SrP4vreGbrOCyYv)dzZIv2)7e87HBqekhMC1)Gbde66HSzl7Xp3qOwkB0Z2w2OLTSz)puGREzqbEXWooBwSYMFLjSofTyIGvNBWaHUEiBYjpBst2SyLDGjieZsXJqfmeqPehMjJlSH5sWu)v2SL9WSrpBwSYg5cHSTLn1oYOMyGqxpKn5YMDlNn6rj9x75rjcOuIdZKXf2qSIpz54arjWvebWJwfL(4Ta8QrjeAkkdbukXHzY4cBWGbcD9q2SLn7woBwSYg5cHSTLn1oYOMyGqxpKn5YEqFnkP)AppkX8Q98yfFAqJdeLaxreapAvus)1EEuQWRBnudJsCi8XlZAppkzXaLslQSPdq2BbezlUX9hL(4Ta8QrjukEvebyk86wd1my3)ZG4QSLN9WSTLnAzJqtrziGsjomtgxydgAMzZIv2OLTSzxQa8YWbIZ3VbCfra8STLnYfczBl7)Dc(9WneqPehMjJlSbdgi01dzZw2OLn1oYOMyGqxpKn5SaMDHx3AOm1qZ)ob)E4gonwR98Sjv2SNn6zJE2SyLnYfczBlBQDKrnXaHUEiBYjpB2FnB0ZMfRSrlBukEvebyk86wd1my3)ZG4QSLNn7zBlBzZUWRBnuMIDZ)ob)E4gmOC7zJE2SyLTSzJsXRIiatHx3AOMb7(FgexfR4tVrCGOe4kIa4rRIsF8waE1OekfVkIamfEDRHAgS7)zqCv2YZM9STLnAzJqtrziGsjomtgxydgAMzZIv2OLTSzxQa8YWbIZ3VbCfra8STLnYfczBl7)Dc(9WneqPehMjJlSbdgi01dzZw2OLn1oYOMyGqxpKn5SaMDHx3AOmf7M)Dc(9WnCASw75ztQSzpB0Zg9SzXkBKleY2w2u7iJAIbcD9q2KtE2S)A2ONnlwzJw2Ou8QicWu41TgQzWU)NbXvzlp7HzBlBzZUWRBnuMAO5FNGFpCdguU9SrpBwSYw2SrP4vreGPWRBnuZGD)pdIRIs6V2ZJsfEDRHI9yfFI0ehikbUIiaE0QO0hVfGxnkjB28RmH1POfteS6CtTFRxFmBBzJw2YMnM2bQdpcgD8C7ZrL0bd4kIa4zZIv2OL9)ob)E4gWomraLWGbcD9q2KtE2JFE22YMIgBpB2KN97EnB0Zg9STLnAzlB2)7e87HBiGsjomtgxydgAMzZIv26VwuWeCGyHq2YZEy2OhL0FTNhLcRtrlMiy15Xk(0ZuCGOe4kIa4rRIsF8waE1OKSzxQa8YWbIZ3VbCfra8STLTSzJsXRIiaZdDR1hNuhEsCeGx0ezBlBzZgLIxfragM3jwFCsD4jbuA2SyLncnfLHIgVhDyoQKoyOzgL0FTNhLkgWKbTxXk(0WxJdeLaxreapAvu6J3cWRgLqlB9xlkycoqSqiB2YMdHfd8zP4rOczZIv2yD5taf4Lr58Gz9Szl739A2OhL0FTNhLaH9WQ(KdFmaXk(0WHXbIsGRicGhTkk9XBb4vJsHJwGSo3G6eATcygobkWld4kIa4zBlBzZgHMIYG6eATcygobkWRjdAc1VLBOzgLwVamMMznxQOu4OfiRZnOoHwRaMHtGc8kkTEbymnZAUeeaF1cIsdJs6V2ZJsuciW4JvQkkTEbymnZAokoeveLggRyfLyIH)rGOvCG4tdJdeL0FTNhLqUQeaFsju7a)X6JZ6S06rjWvebWJwfR4tShhikbUIiaE0QO0XmkfGkkP)AppkHsXRIiGOekvqdrPHrPpElaVAuQWRBnuMAOHHgM0byIqtrLTTSrlBzZUWRBnuMIDddnmPdWeHMIkBwSYUWRBnuMAO5FNGFpCdNgR1EE2Sjp7cVU1qzk2n)7e87HB40yT2ZZg9OekfpDLaIsfEDRHAgS7)zqCvSIp9U4arjWvebWJwfLoMrPaurj9x75rjukEvebeLqPcAikXEu6J3cWRgLk86wdLPy3Wqdt6amrOPOY2w2OLTSzx41Tgktn0Wqdt6amrOPOYMfRSl86wdLPy38VtWVhUHtJ1AppB2YUWRBnuMAO5FNGFpCdNgR1EE2OhLqP4PRequQWRBnuZGD)pdIRIv8jlkoqucCfra8OvrPJzukavus)1EEucLIxfrarjuQGgIsLkaVmiI15tkASDd4kIa4zBlB0Ygt7a1HhbdxXwpkummjaUke75gWvebWZMfRSlvaEz4aX5teHYHGbCfra8STLTSzJPDG6WJGrhp3(CujDWaUIiaE2OhL4q4JxM1EEuAqsaY(9TdzBfOezRv2I7r2wq0y7z)ylgzBLyDE2wq0y7zRIZhZ(XwmYg2IbGZ2IvS1JcfdzF4STyG48STsOCiKnTlGqiB6W6Jzpigp3E2pBL0HOekfpDLaIs0byc2HjcOetkAS95)C(w75Xk(KLJdeLaxreapAvu6J3cWRgLchTazDUHjDOOfWeW0mR9Cd4kIa4zZIv2HJwGSo3G6eATcygobkWld4kIa4rj9x75rjkbey8XkvfR4tdACGOK(R98OKI)QdZ6WyWROe4kIa4rRIvSIvSIvmc]] )


end
