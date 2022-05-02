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


    spec:RegisterPack( "Havoc", 20220501, [[dafiObqiIslcPuWJqQkxcPuOnjf(erXOqkofKYQOuIELusZcPYTurHDrXVur1WurCmPOLreEMksnnKs11OeSnkL03qkPghLq05ursSoKsmpKQCpuQ9re9pKsroiLsyHusEiLsnrkH6IQOOnIuk5JQirJKsiCskHKvcPAMQO0nrkLANsj(jLqQHQIKKLQIeEkkMkLIRIukQVIusglLu2lv(RunyLomPfdXJvPjJQld2mI(SkmAI0PvSAvKK61uIMnHBJWUf(TQgor1XvrsTCOEovnDjxhjBhs(UuQXtjvNNs16rQQMpkz)I210zJJHRf4ArItKqItSWjnns08KMnTGJPSlhCmY1RL6b4ycLaCmwekQ)6yKR2fVYD24y8pf(cogMHGsO18HTXkz5yqOgrzrfoehdxlW1IeNiHeNyHtAAKO5jnB6y8YHRRflqRP1ogPdNdHdXXWb)1XyXaXh5ArqffGZ1Iqr93eDAB1EUnPlxjorcjs0t0TTunoapTKOFg5sBdLs8y5sF)4ZvdEUNQ(A(ixkVEa5sBabiFmKl5CiTYfcUN2qUI)yU5Q8t1u(c45wFUQC5c75(HWEU1NlY795sohslVjr)mY9S)7Hixk556Th3joY9jZL2gkL4XYL((XNlnetK7tMl5CiTYfde6e(Cr5n5w4jSeQCTTfNlwlPao3sQg5sOwhnJJro(jhb4yOp6lxlgi(ixlcQOaCUwekQ)MOtF0xU02Q9CBsxUsCIesKONOtF0xU2wQghGNws0Pp6l3ZixABOuIhlx67hFUAWZ9u1xZh5s51dixAdia5JHCjNdPvUqW90gYv8hZnxLFQMYxap36ZvLlxyp3pe2ZT(CrEVpxY5qA5nj60h9L7zK7z)3drUuYZ1BpUtCK7tMlTnukXJLl99JpxAiMi3NmxY5qALlgi0j85IYBYTWtyju5ABloxSwsbCULunYLqToAMe9eD9wZhEJCmCFceTyJ8vjaENuO2bE7jo61B9js01BnF4nYXW9jq0Qv2NJsXJIia6cLayx4jSeQU3EC7EXx0Hsfua7M0nKSl8ewcLPPrQ67uEOJqrs2Ggzl8ewcLrcJu13P8qhHIKKfRcpHLqzAAU)l4F7WWPWAnFij7cpHLqzKWC)xW)2HHtH1A(aTeD9wZhEJCmCFceTAL95Ou8OicGUqja2fEclHQ7Th3Ux8fDOubfWwc6gs2fEclHYiHrQ67uEOJqrs2Ggzl8ewcLPPrQ67uEOJqrsYIvHNWsOmsyU)l4F7WWPWAnFizHNWsOmnn3)f8VDy4uyTMpqlrN(YL2ShY9mTd5AfOe5QvUIVDU0wuy752EkP5ALycEU0wuy75QIpoYT9usZfMskGZ1IvSLhcfd5(4CTyG4JCTsOCWNlviaVpxk)eh5Alo(WEUNsL(HeD9wZhEJCmCFceTAL95Ou8OicGUqja2uEOd2HocOeDskS9(9d(uZh0Hsfua7sfqugeXe8ojf2Ubcfra8g0GPcG8XhGHRylpekg6eaxfI5dwSkvarz4aXhDeHYbVbcfra8gYIPcG8XhGrp(WE)qPFaTeD9wZhEJCmCFceTAL95KcWl9IvYIUHKT)PeitWnYP8fLa6aMsEnFWIL)PeitWnOEHwJa6(xGcIkrxV18H3ihd3NarRwzFUIVAa96XyiQe9eD6J(Y9mToCPkGNlGcW2ZTgci3skKRERhN74ZvrPJqreGjrxV18HNnF8yk5vIUER5dFRSp)(HNIa6e6XCt0Pp6lxAfKl)dzQC5FUL0XNBP4dOY13wLlFIJCRpxvUCH9CTIchtCKlT6PcEIo9rF5Q3A(W3k7ZXqP4dO6kv9DTk9AjDIjG(LZUjDLIpGQpKSjMGw4acfjPbHchtC0B)ub3GbcDcpDdjBmvaKp(amiu4yIJE7Nk4nkvarz4aXhDeHYbVbcfra8eD6lxA1usFQkxBlvFFU2ifES9CFCUwSIT8qOyGUCTsOCixlwJlKB7PKMlT1G9vUwj(NN7JZvRCpDR5sJeTMB7PKMRnyDe5(K5EkOMaTClfFaLprxV18HVv2NJsXJIia6cLayJiuo05ACb6gs2YIPcG8XhG5kvFFVKcp2EdzXubq(4dWWvSLhcfdDcGRcX8bDOubfWUubeLHCW(QJi(NBGqreaNflVCqi6LIpGYBqekh6CnUqtjztZPpJsfquMcRJO)KDm1egiuebWrlrN(YLwnL0CTTu995AJu4X2PlxRekhY1I14c52wke5wsHCrOijZD85Y)2bD52EkP5sBnyFLRvI)55QvUs0AU00S1CBpL0CTbRJi3Nm3tb1eOL7JZT9usZ9m9EiUqUwHb1YC1kxAV1CP50TMB7PKMRnyDe5(K5EkOMaTClfFaLprxV18HVv2NJsXJIia6cLayJiuo05ACb6gs2yQaiF8byUs133lPWJTthkvqbSrOijnxP677Lu4X2n8VDWIvPcikd5G9vhr8p3aHIiaEdVCqi6LIpGYBqekh6CnUqtjztJeNrPciktH1r0FYoMAcdekIa4OXILSLkGOmx7xb0FYUuTWa3aHIiaEdVCqi6LIpGYBqekh6CnUqtjztdTFgLkGOmfwhr)j7yQjmqOicGJwIo9LlTAkP5AXk2YdHIb6Y1kHYHCTynUqUALB8ycvKBP4dOY9(urLBBPqKlcfjjWZfXEUAUE4(bxX2ZfijHBrxUpoxv0wT7ZvRCPDBAnxYhNB8XzyXaXhZnrxV18HVv2NJsXJIia6cLayJiuo05ACb6gs2yQaiF8by4k2YdHIHobWvHy(GouQGcyxQaIYqoyF1re)ZnqOicGZIfniuKKgcOuIhlx67hVHsolwLkGOmfwhr)j7yQjmqOicGZIfhqOijnG3dXf6iyqT0qjhTgE5Gq0lfFaL3Giuo05ACHMsYMMtFgLkGOmfwhr)j7yQjmqOicGJglwYwQaIYWbIpMRbcfra8gE5Gq0lfFaL3Giuo05ACHMsYM2t0PVCPn7HCptVhIlKRvyqTmxeG8XqUwjuoKRfRXfYDiZDQChFUkkDekIaYvdEUpjzU3)f8VDKOR3A(W3k7ZrP4rreaDHsaSrekh6CnUaDVC2yWdfDdj7sfqugW7H4cDemOwAGqreaVX9Fb)BhgW7H4cDemOwAWGYTNOtF5sRMsAU2IJpSN7PuPFixn45AB7xbK7tMRfHwyGtxUkQF45s5N4ixRekhY1I14c52wke5wsbmK74ZTKc5k)9(bzetzp36ZfSEbbpxnY1w8NzUmtqsjY1kSg8eD9wZh(wzFokfpkIaOlucGnIq5qNRXfOBizJPcG8XhGrp(WE)qPFOrPcikZ1(va9NSlvlmWPdLkOa2Ou8OicWGiuo05ACHg6TguqN)LXpbjLOJG1Gtpjs01BnF4BL95Ou8OicGUqja2Y)xmXrN8XDcOu6qPckGTSLkGOmCG4J5AGqreaVX9Fb)BhgcOuIhlx67hVbde6eE6zRniPW2nCGCUtj5PpjrxV18HVv2NJsXJIia6cLayl)FXehDYh3rekh6CnUaDOubfWgLIhfrageHYHoxJl0GgskSD6rRTWzuQaIYqoyF1re)ZnqOicGBlL4e0s01BnF4BL95Ou8OicGUqja2Y)xmXrN8XDWo0raLGouQGcyxQaIYWbIpMRbcfra8gYwQaIYGiMG3jPW2nqOicG34(VG)Tddyh6iGsyWaHoHNE0CC5gc162sjqRbjf2UHdKZDkjL4KeD6lxA1usZ1wC8H9CpLk9d0LRwfqiVYT(C92JBUNPDixRaLixn45E)xW)2rUuE9aYL8X5sOwFiOiYLtH1A(GUCPcb495QvUN2Mwt01BnF4BL95Ou8OicGUqja2T1PM4Ot(4UE8H9(Hs)aDdjBmvaKp(am6Xh27hk9d0HsfuaBz5Fz8tqsj6iyn4MAUwoXrJ7)c(3om(jiPeDeSgCdgi0j8074YneQ1TL0EdAK9(VG)TddbukXJLl99J3qjNfl9wdkOdbqmGNDt0A4LdcrVu8buEdyh6iGsqp2NorxV18HVv2NJsXJIia6cLay3wNAIJo5J7epbeffbDOubfWUubeLH4jGOOimqOicG3qwekssdXtarrryOKNOR3A(W3k7ZVQq01BnF0fJVOlucG99Fb)Bhj60h9LRER5dFRSpx(CTStjVtI1dcik6k7Yb2CG4d6gs2CG4JU)PeDsSEqar5L8KeD6J(YvV18HVv2NlFUw2PK3jX6bbefDephyhGIbFr3qYMMsfqugoq8XC7QC5qnfyGqreaVbjf2UHdKZDkjzFAlWIfMkaYhFageXe8oPoL0giuKKgeXe8oPoLudLC0AqJS3)f8VDya7qhbucdguUDwSiPW2P3PpbTeD9wZh(wzFEjf)T7hcDqb0nKSrOijnKGOJ8eikMtarz8LETKTfAqdcfjPziiEHwZhDLcRgk5SyjlcfjPHakL4XYL((XBOKJwIUER5dFRSphtfD9wZhDX4l6cLayZbIpMlD(cp3IDt6gs2LkGOmCG4J5AGqreaprxV18HVv2NJPIUER5JUy8fDHsaSJhtOIe9eD6lxBR(kxABOuIhlx67hFUdzUTHCBpcrUhqLRMljLqK7zAhY1kqjYfdKyWln3hN7qMBjfYfI7tffGZD85QcI3x5(OaCIUER5dV5(VG)Td2eqPepwU03pE6gs2YwQaIYWbIpMRbcfra8g0C)xW)2HbSdDeqjmyGqNWlPeNWIf5CiT6yGqNWtpjSaAj66TMp8M7)c(3oAL95eqPepwU03pE6gs2LkGOmCG4J5AGqreaVbn3)f8VDya7qhbucdgi0j8skXjnOrwukEuebyqekh6CnUalw3)f8VDyqekh6CnUGbde6eEjpUCdHAD0yXICoKwDmqOt4PNewaTeD9wZhEZ9Fb)BhTY(C5FnFq3qYgHIK0qaLs8y5sF)4nyGqNWlPewGflK37BqohsRogi0j80ZwpjrxV18H3C)xW)2rRSpNYd9Pac6cLayF1RuO)KD9EQPgmW7fgupfg80nKSrOijn69utnyG3vRdgk5nOHg9wdkOdbqmGNnh8dg49sXhq5BG1H3buqugLZ9MjK0wpHfl9wdkOdbqmGxso4hmW7LIpGYJwdA0BnOGoeaXaE6DAwSU)l4F7Wa2HocOegmqOt4PNeNGglwiV33GCoKwDmqOt4PNewaTeD6lxlgivkrLlLhYDkGixXFm3eD9wZhEZ9Fb)BhTY(8cpHLq1KUHKnkfpkIamfEclHQ7Th3Ux8f7MnObHIK0qaLs8y5sF)4nuYzXIgzlvarz4aXhZ1aHIiaEdK37BC)xW)2HHakL4XYL((XBWaHoHxsAiNdPvhde6eE6rBQWtyjuMMM7)c(3omCkSwZh0gLan0yXc59(gKZH0QJbcDcp9ylXjOXIfnOu8OicWu4jSeQU3EC7EXxSLOHSfEclHYiH5(VG)TddguUD0yXswukEuebyk8ewcv3BpUDV4ReD9wZhEZ9Fb)BhTY(8cpHLqjbDdjBukEuebyk8ewcv3BpUDV4l2s0GgekssdbukXJLl99J3qjNflAKTubeLHdeFmxdekIa4nqEVVX9Fb)BhgcOuIhlx67hVbde6eEjPHCoKwDmqOt4PhTPcpHLqzKWC)xW)2HHtH1A(G2OeOHglwiV33GCoKwDmqOt4PhBjobnwSObLIhfraMcpHLq192JB3l(IDZgYw4jSekttZ9Fb)BhgmOC7OXILSOu8OicWu4jSeQU3EC7EXxj66TMp8M7)c(3oAL95(jiPeDeSgC6gs2YY)Y4NGKs0rWAWn1CTCIJg0ilMkaYhFag94d79dL(bwSO5(VG)Tddyh6iGsyWaHoHNESpU8gKuy7sY(0NGgAnOr27)c(3omeqPepwU03pEdLCwS0BnOGoeaXaE2nrlrxV18H3C)xW)2rRSpVKcDPurr3qYw2sfqugoq8XCnqOicG3qwukEuebyARtnXrN8XDINaIIIOHSOu8OicWi)FXehDYh3jGszXcHIK0qsHNNY3pu6hmuYt01BnF4n3)f8VD0k7ZbHD)OrNdxma0nKSPrV1Gc6qaed4LKd(bd8EP4dO8SyH1H3buqugLZ9MjK80NGwIUER5dV5(VG)TJwzFoPa8sVyLSOBiz7FkbYeCdQxO1iGU)fOGOAilcfjPb1l0Aeq3)cuquDPueA8d3qjNUjkaJPKx9HGa4Jwa7M0nrbymL8QFiEevWUjDtuagtjV6djB)tjqMGBq9cTgb09VafevIEIUER5dVHdeFmx2GDOJakbDdjBmvaKp(am6Xh27hk9dnOrV1Gc6qaed4LKd(bd8EP4dO8SyH1H3buqugLZ9MjKuclCgLkGOmx7xb0FYUuTWa3w28e0AW)Y4NGKs0rWAWn1CTCIJg8Vm(jiPeDeSgCdgi0j80J9XLNOR3A(WB4aXhZTv2NtcIoMYlLUHKDPcikdvG8ubVFLQV3aHIiaEdekssdvG8ubVFLQV3qjVbnxPk(a8SLGflAW6W7akikdXJciGOmtizZtAG1H3buqugLZ9MjKS5jOHwIUER5dVHdeFm3wzFoh0sA33ga50nKSrP4rreGbrOCOZ14cj66TMp8goq8XCBL95hcDqb9ciKd(IUHKTERbf0HaigWljh8dg49sXhq5zXcRdVdOGOmkN7ntizZts01BnF4nCG4J52k7ZlP4VD)qOdkGUHK99do1ugpGXAb8(HqhuGbcfra8g3)f8VDya7qhbucdgi0j80ZwBilcfjPHakL4XYL((XBOK3qwoGqrsAaRl)9aV3(PcUHsEIUER5dVHdeFm3wzFoyh6iGsq3qYwV1Gc6qaed4LKd(bd8EP4dO8SyH1H3buqugLZ9MjKuclCgLkGOmx7xb0FYUuTWa3w28Kg0ilkfpkIamuEOd2HocOeDskS9(9d(uZhSy5LdcrVu8buEjBYIfjf2o9O1NGwdzrP4rreGPTo1ehDYh31JpS3pu6hs01BnF4nCG4J52k7Zrekh6CnUaDdjBukEuebyqekh6CnUqdzV)l4F7WqaLs8y5sF)4nyq52BqZ9Fb)BhgWo0raLWGbcDcVKwGflAW6W7akikJY5EZesE)xW)2rdSo8oGcIYOCU3mb9KWcOHwIUER5dVHdeFm3wzF(qq8cTMp6kfwPBizllcfjPziiEHwZhDLcRgk5j66TMp8goq8XCBL95AeJ0rO18bDdjBzrP4rreGr()Ijo6KpUJiuo05ACHeD9wZhEdhi(yUTY(CsqGiuoq3qYMKcB3WbY5oLKSP9ts01BnF4nCG4J52k7ZbVhIl0rWGAzIUER5dVHdeFm3wzF(vQ((UVWJLaDdjBzrP4rreGr()Ijo6KpUJiuo05ACHgYIsXJIiaJ8)ftC0jFChSdDeqjs01BnF4nCG4J52k7Zjbrht5Ls3qYUubeLHdeF0rekh8giuebWBi79Fb)BhgWo0raLWGbLBVbnxPk(a8SLGflAW6W7akikdXJciGOmtizZtAG1H3buqugLZ9MjKS5jOHwIUER5dVHdeFm3wzFohi(W3rMcO7A)kGEP4dO8SBs3qYgtfa5JpadcfoM4O3(PcEdoGqrsAqOWXeh92pvWnyGqNWtpAprxV18H3WbIpMBRSpNeeDmLxkDdjBzlvarz4aXhDeHYbVbcfra8gE5Gq0lfFaLxYMnO5kvXhGNTeSyrdwhEhqbrziEuabeLzcjBEsdSo8oGcIYOCU3mHKnpbn0s01BnF4nCG4J52k7Z5aXh(oYuqIUER5dVHdeFm3wzFEjf)T7hcDqb0nKSrOijnpv1FYowJdWqjprxV18H3WbIpMBRSpNeeDmLxkDdjBIhfqarz4JV04cs20cSyHqrsAEQQ)KDSghGHsEIUER5dVHdeFm3wzFokioaskrhdfg0IUHKnXJciGOm8XxACbjBAHeD9wZhEdhi(yUTY(8sk(B3pe6GcOBizxQaIYWbIp6icLdEdekIa4j6j66TMp8M4XeQGnyh6iGsq3qYgtfa5JpaJE8H9(Hs)qdA0BnOGoeaXaEj5GFWaVxk(akplwyD4DafeLr5CVzcjBAb0AW)Y4NGKs0rWAWn1CTCIJg8Vm(jiPeDeSgCdgi0j80J9XLNOR3A(WBIhtOIwzFokioaskrhdfg0IUHKDPcikdXtarrryGqreaVbcfjProgKRyGB4F7OrneGKnt01BnF4nXJjurRSpNeeDmLxkDdjBAqOijnubYtf8(vQ(EdLCwSqP4rreGPTo1ehDYh3jEcikkIg0iBPcikdvG8ubVFLQV3aHIiaolwYE)xW)2HziiEHwZhDLcRgmOC7OHwdAUsv8b4zlblw0G1H3buqugIhfqarzMqYMN0aRdVdOGOmkN7ntizZtqdTeD9wZhEt8ycv0k7ZjbrhrXy9aOBizR3AqbDiaIb8sYb)GbEVu8buEwSW6W7akikJY5EZesE6ts01BnF4nXJjurRSpNdAjT7BdGC6gs2Ou8OicWGiuo05ACHeD9wZhEt8ycv0k7ZhcIxO18rxPWkDdjBzrOijndbXl0A(ORuy1qjprxV18H3epMqfTY(8dHoOGEbeYbFr3qYwwukEuebyARtnXrN8XDINaIIIObn6TguqhcGyaVKCWpyG3lfFaLNflSo8oGcIYOCU3mHKnpbTeD9wZhEt8ycv0k7ZlP4VD)qOdkGUHK99do1ugpGXAb8(HqhuGbcfra8g3)f8VDya7qhbucdgi0j80ZwBilcfjPHakL4XYL((XBOK3qwoGqrsAaRl)9aV3(PcUHsEIUER5dVjEmHkAL95GDOJakbDdjBzrP4rreGPTo1ehDYh3jEcikkIg0O3AqbDiaIb8sYb)GbEVu8buEwSW6W7akikJY5EZes20cnOrwukEuebyO8qhSdDeqj6Kuy797h8PMpyXYlheIEP4dO8s2KflskSD6rRpbTgYIsXJIiatBDQjo6KpURhFyVFO0pGwIUER5dVjEmHkAL95icLdDUgxGUHKnkfpkIamicLdDUgxirxV18H3epMqfTY(CsqGiuoq3qYMKcB3WbY5oLKSP9ts01BnF4nXJjurRSph8EiUqhbdQLj66TMp8M4XeQOv2NRrmshHwZh0nKSPPubeLHdeF0rekh8giuebWzXswukEuebyARtnXrN8XDINaIIIGflskSDdhiN7u070NWIfcfjPHakL4XYL((XBWaHoHNEwaTgYIsXJIiaJ8)ftC0jFChrOCOZ14cj66TMp8M4XeQOv2NFLQVV7l8yjq3qYMMsfqugoq8rhrOCWBGqreaNflzrP4rreGPTo1ehDYh3jEcikkcwSiPW2nCGCUtrVtFcAnKfLIhfrag5)lM4Ot(4obuAdzrP4rreGr()Ijo6KpUJiuo05ACHeD9wZhEt8ycv0k7Zb7qhbuc6gs2LkGOmiIj4DskSDdekIa4nW6W7akikJY5EZesE)xW)2rdzrP4rreGPTo1ehDYh31JpS3pu6hs01BnF4nXJjurRSpNdeF47itb0DTFfqVu8buE2nPBizJPcG8XhGbHchtC0B)ubVbhqOijniu4yIJE7Nk4gmqOt4PhTNOR3A(WBIhtOIwzFohi(W3rMcs01BnF4nXJjurRSpNeeDmLxkDdjBzlvarziEcikkcdekIa4nW6W7akikdXJciGOmti5vQIpaVTS5jnkvarz4aXhDeHYbVbcfra8eD9wZhEt8ycv0k7ZjbbIq5aDdjBIhfqarz4JV04cs20cSyHqrsAEQQ)KDSghGHsEIUER5dVjEmHkAL95KGOJP8sPBizt8OacikdF8LgxqYMwGflAqOijnpv1FYowJdWqjVHSLkGOmepbeffHbcfraC0s01BnF4nXJjurRSphfehajLOJHcdAr3qYM4rbequg(4lnUGKnTqIUER5dVjEmHkAL95Lu83UFi0bfq3qYUubeLHdeF0rekh8giuebWDmOaSF(W1IeNiHeNq7syr6yAR4yIdVJHwzlofTyr1YPKwYnxBKc5oeYFCLl5JZvM4XeQqMCXWPMAWapx)ta5Qu1tOfWZ9kvJdWBs0p7eqUnPLCT9hOaCb8CLbtfa5JpaJ1Kj36ZvgmvaKp(amwZaHIiaUm5sttRJMjr)Sta520wPLCT9hOaCb8CLbtfa5JpaJ1Kj36ZvgmvaKp(amwZaHIiaUm5sttRJMjrprNwzlofTyr1YPKwYnxBKc5oeYFCLl5JZvgoqQuIsMCXWPMAWapx)ta5Qu1tOfWZ9kvJdWBs0p7eqUNMwY12FGcWfWZvgmvaKp(amwtMCRpxzWubq(4dWyndekIa4YKlnnToAMe9ZobK7PPLCT9hOaCb8CLbtfa5JpaJ1Kj36ZvgmvaKp(amwZaHIiaUm5QvUNPf9zZLMMwhntI(zNaYL2PLCT9hOaCb8CLbtfa5JpaJ1Kj36ZvgmvaKp(amwZaHIiaUm5QvUNPf9zZLMMwhntI(zNaY1c0sU2(duaUaEUYGPcG8XhGXAYKB95kdMkaYhFagRzGqreaxMC1k3Z0I(S5sttRJMjr)Sta5sRPLCT9hOaCb8CLPubeLXAYKB95ktPcikJ1mqOicGltUAL7zArF2CPPP1rZKOF2jGCP10sU2(duaUaEUYGPcG8XhGXAYKB95kdMkaYhFagRzGqreaxMCPPP1rZKOF2jGCB2KwY12FGcWfWZvgmvaKp(amwtMCRpxzWubq(4dWyndekIa4YKRw5EMw0NnxAAAD0mj6j60kBXPOflQwoL0sU5AJui3Hq(JRCjFCUYihd3NarlzYfdNAQbd8C9pbKRsvpHwap3RunoaVjr)Sta5kbTKRT)afGlGNRmfEclHY00ynzYT(CLPWtyjuMQPXAYKlnsyD0mj6NDcixjOLCT9hOaCb8CLPWtyjugjmwtMCRpxzk8ewcLPKWynzYLgjSoAMe9ZobK7PPLCT9hOaCb8CLPWtyjuMMgRjtU1NRmfEclHYunnwtMCPrcRJMjr)Sta5EAAjxB)bkaxapxzk8ewcLrcJ1Kj36ZvMcpHLqzkjmwtMCPrcRJMjr)Sta5s70sU2(duaUaEUYGPcG8XhGXAYKB95kdMkaYhFagRzGqreaxMCPrcRJMjr)Sta5AbAjxB)bkaxapxz8pLazcUXAYKB95kJ)PeitWnwZaHIiaUm5sttRJMjr)Sta5AbAjxB)bkaxapxz8pLazcUXAYKB95kJ)PeitWnwZaHIiaUm5QvUNPf9zZLMMwhntIEIoTYwCkAXIQLtjTKBU2ifYDiK)4kxYhNRm3)f8VDitUy4utnyGNR)jGCvQ6j0c45ELQXb4nj6NDcixlql5A7pqb4c45Yme2oxV9OuRNlTXCRp3ZsP5YhuJF(i3xoG16X5sZ5OLlnnToAMe9ZobKRfOLCT9hOaCb8CLPWtyjuMMgRjtU1NRmfEclHYunnwtMCPPP1rZKOF2jGCTaTKRT)afGlGNRmfEclHYiHXAYKB95ktHNWsOmLegRjtU0006Ozs0p7eqU2kTKRT)afGlGNlZqy7C92JsTEU0gZT(CplLMlFqn(5JCF5awRhNlnNJwU0006Ozs0p7eqU2kTKRT)afGlGNRmfEclHY00ynzYT(CLPWtyjuMQPXAYKlnnToAMe9ZobKRTsl5A7pqb4c45ktHNWsOmsySMm5wFUYu4jSektjHXAYKlnnToAMe9ZobKlTMwY12FGcWfWZvgmvaKp(amwtMCRpxzWubq(4dWyndekIa4YKlnnToAMe9ZobKBZtOLCT9hOaCb8CLX)ucKj4gRjtU1NRm(NsGmb3yndekIa4YKlnnToAMe9eDALT4u0IfvlNsAj3CTrkK7qi)XvUKpoxz4aXhZvMCXWPMAWapx)ta5Qu1tOfWZ9kvJdWBs0p7eqUnPLCT9hOaCb8CLPubeLXAYKB95ktPcikJ1mqOicGltU0006Ozs0p7eqUnPLCT9hOaCb8CLbtfa5JpaJ1Kj36ZvgmvaKp(amwZaHIiaUm5sttRJMjr)Sta5AR0sU2(duaUaEUYuQaIYynzYT(CLPubeLXAgiuebWLjxAAAD0mj6NDci3M0oTKRT)afGlGNRmyQaiF8bySMm5wFUYGPcG8XhGXAgiuebWLjxAAAD0mj6j6wueYFCb8CTqU6TMpYvm(YBs0Dmkvj9XogMHW2ogX4lVZght8ycv4SX1stNnogiuebWDw5yU4Pa8OogmvaKp(am6Xh27hk9dgiuebWZTrU0KRERbf0HaigWNRK5Yb)GbEVu8bu(CzXkxSo8oGcIYOCU3mrUsMBtlKlA52ix(xg)eKuIocwdUPMRLtCKBJC5Fz8tqsj6iyn4gmqOt4ZLESZ94YDm6TMpCmGDOJakHRCTiHZghdekIa4oRCmx8uaEuhtPcikdXtarrryGqreap3g5IqrsAKJb5kg4g(3oYTrU1qa5kzUnDm6TMpCmOG4aiPeDmuyqlx5A50oBCmqOicG7SYXCXtb4rDm0KlcfjPHkqEQG3Vs13BOKNllw5IsXJIiatBDQjo6KpUt8equue52ixAYv2ClvarzOcKNk49Ru99giuebWZLfRCLn37)c(3omdbXl0A(ORuy1GbLBpx0YfTCBKln5ELQ4dWNl7CLixwSYLMCX6W7akikdXJciGOmtKRK528KCBKlwhEhqbrzuo3BMixjZT5j5IwUO5y0BnF4yibrht5L6kxl0UZghdekIa4oRCmx8uaEuhJERbf0HaigWNRK5Yb)GbEVu8bu(CzXkxSo8oGcIYOCU3mrUsM7PpXXO3A(WXqcIoIIX6b4kxlwWzJJbcfraCNvoMlEkapQJbLIhfrageHYHoxJl4y0BnF4y4Gws7(2ai3vUwSvNnogiuebWDw5yU4Pa8OogzZfHIK0meeVqR5JUsHvdLChJER5dhZqq8cTMp6kfwDLRfATZghdekIa4oRCmx8uaEuhJS5IsXJIiatBDQjo6KpUt8equue52ixAYvV1Gc6qaed4ZvYC5GFWaVxk(akFUSyLlwhEhqbrzuo3BMixjZT5j5IMJrV18HJ5qOdkOxaHCWxUY1IfPZghdekIa4oRCmx8uaEuhZ9do1ugpGXAb8(HqhuGbcfra8CBK79Fb)BhgWo0raLWGbcDcFU0lxBn3g5kBUiuKKgcOuIhlx67hVHsEUnYv2C5acfjPbSU83d8E7Nk4gk5og9wZhoMsk(B3pe6GcCLRLtfNnogiuebWDw5yU4Pa8OogzZfLIhfraM26utC0jFCN4jGOOiYTrU0KRERbf0HaigWNRK5Yb)GbEVu8bu(CzXkxSo8oGcIYOCU3mrUsMBtlKBJCPjxzZfLIhfragkp0b7qhbuIojf2E)(bFQ5JCzXkxVCqi6LIpGYNRK52mxwSYLKcBpx6LlT(KCrl3g5kBUOu8OicW0wNAIJo5J76Xh27hk9d5IMJrV18HJbSdDeqjCLRLMN4SXXaHIiaUZkhZfpfGh1XGsXJIiadIq5qNRXfCm6TMpCmicLdDUgxWvUwA20zJJbcfraCNvoMlEkapQJHKcB3WbY5ovUsYoxA)ehJER5dhdjiqekhCLRLMs4SXXO3A(WXaEpexOJGb1shdekIa4oRCLRLMN2zJJbcfraCNvoMlEkapQJHMClvarz4aXhDeHYbVbcfra8CzXkxzZfLIhfraM26utC0jFCN4jGOOiYLfRCjPW2nCGCUtLl9Y90NKllw5IqrsAiGsjESCPVF8gmqOt4ZLE5AHCrl3g5kBUOu8OicWi)FXehDYh3rekh6CnUGJrV18HJrJyKocTMpCLRLM0UZghdekIa4oRCmx8uaEuhdn5wQaIYWbIp6icLdEdekIa45YIvUYMlkfpkIamT1PM4Ot(4oXtarrrKllw5ssHTB4a5CNkx6L7Ppjx0YTrUYMlkfpkIamY)xmXrN8XDcO0CBKRS5IsXJIiaJ8)ftC0jFChrOCOZ14cog9wZhoMRu99DFHhlbx5APPfC24yGqrea3zLJ5INcWJ6ykvarzqetW7Kuy7giuebWZTrUyD4DafeLr5CVzICLmx9wZh97)c(3oYTrUYMlkfpkIamT1PM4Ot(4UE8H9(Hs)GJrV18HJbSdDeqjCLRLM2QZghdekIa4oRCm6TMpCmCG4dFhzkWXCXtb4rDmyQaiF8byqOWXeh92pvWnqOicGNBJC5acfjPbHchtC0B)ub3GbcDcFU0lxA3XCTFfqVu8buExlnDLRLM0ANnog9wZhogoq8HVJmf4yGqrea3zLRCT00I0zJJbcfraCNvoMlEkapQJr2ClvarziEcikkcdekIa452ixSo8oGcIYq8OacikZe5kzUxPk(a85AlZT5j52i3sfqugoq8rhrOCWBGqrea3XO3A(WXqcIoMYl1vUwAEQ4SXXaHIiaUZkhZfpfGh1Xq8OacikdF8LgxixjZTPfYLfRCrOijnpv1FYowJdWqj3XO3A(WXqcceHYbx5ArItC24yGqrea3zLJ5INcWJ6yiEuabeLHp(sJlKRK520c5YIvU0KlcfjP5PQ(t2XACagk552ixzZTubeLH4jGOOimqOicGNlAog9wZhogsq0XuEPUY1IenD24yGqrea3zLJ5INcWJ6yiEuabeLHp(sJlKRK520cog9wZhoguqCaKuIogkmOLRCTiHeoBCmqOicG7SYXCXtb4rDmLkGOmCG4JoIq5G3aHIiaUJrV18HJPKI)29dHoOax5khdhivkr5SX1stNnog9wZhog(4XuYlhdekIa4oRCLRfjC24y0BnF4yUF4PiGoHEmxhdekIa4oRCLRLt7SXXaHIiaUZkhZl3X4HYXO3A(WXGsXJIiahdkf3dLaCmicLdDUgxWXCXtb4rDmYMlMkaYhFaMRu999sk8y7giuebWZTrUYMlMkaYhFagUIT8qOyOtaCviMpmqOicG7y4G)Ih518HJHwnL0NQY12s13NRnsHhBp3hNRfRylpekgOlxRekhY1I14c52EkP5sBnyFLRvI)55(4C1k3t3AU0irR52EkP5AdwhrUpzUNcQjql3sXhq5DmOubf4ykvarzihSV6iI)5giuebWZLfRC9YbHOxk(akVbrOCOZ14cnZvs25stUNo3Zi3sfquMcRJO)KDm1egiuebWZfnx5AH2D24yGqrea3zLJ5L7y8q5y0BnF4yqP4rreGJbLI7HsaogeHYHoxJl4yU4Pa8OogmvaKp(amxP677Lu4X2nqOicG7y4G)Ih518HJHwnL0CTTu995AJu4X2PlxRekhY1I14c52wke5wsHCrOijZD85Y)2bD52EkP5sBnyFLRvI)55QvUs0AU00S1CBpL0CTbRJi3Nm3tb1eOL7JZT9usZ9m9EiUqUwHb1YC1kxAV1CP50TMB7PKMRnyDe5(K5EkOMaTClfFaL3XGsfuGJbHIK0CLQVVxsHhB3W)2rUSyLBPcikd5G9vhr8p3aHIiaEUnY1lheIEP4dO8geHYHoxJl0mxjzNln5krUNrULkGOmfwhr)j7yQjmqOicGNlA5YIvUYMBPcikZ1(va9NSlvlmWnqOicGNBJC9YbHOxk(akVbrOCOZ14cnZvs25stU0EUNrULkGOmfwhr)j7yQjmqOicGNlAUY1IfC24yGqrea3zLJ5L7y8q5y0BnF4yqP4rreGJbLI7HsaogeHYHoxJl4yU4Pa8OogmvaKp(amCfB5HqXqNa4QqmFyGqrea3XWb)fpYR5dhdTAkP5AXk2YdHIb6Y1kHYHCTynUqUALB8ycvKBP4dOY9(urLBBPqKlcfjjWZfXEUAUE4(bxX2ZfijHBrxUpoxv0wT7ZvRCPDBAnxYhNB8XzyXaXhZ1XGsfuGJPubeLHCW(QJi(NBGqreapxwSYLMCrOijneqPepwU03pEdL8CzXk3sfquMcRJO)KDm1egiuebWZLfRC5acfjPb8EiUqhbdQLgk55IwUnY1lheIEP4dO8geHYHoxJl0mxjzNln5E6CpJClvarzkSoI(t2XutyGqreapx0YLfRCLn3sfqugoq8XCnqOicGNBJC9YbHOxk(akVbrOCOZ14cnZvs25s7UY1IT6SXXaHIiaUZkhZl3XGbpuog9wZhogukEueb4yqP4EOeGJbrOCOZ14coMlEkapQJPubeLb8EiUqhbdQLgiuebWZTrU3)f8VDyaVhIl0rWGAPbdk3UJHd(lEKxZhogAZEi3Z07H4c5AfgulZfbiFmKRvcLd5AXACHChYCNk3XNRIshHIiGC1GN7tsM79Fb)BhUY1cT2zJJbcfraCNvoMxUJXdLJrV18HJbLIhfraogukUhkb4yqekh6CnUGJ5INcWJ6yWubq(4dWOhFyVFO0pyGqreap3g5wQaIYCTFfq)j7s1cdCdekIa4ogo4V4rEnF4yOvtjnxBXXh2Z9uQ0pKRg8CTT9RaY9jZ1IqlmWPlxf1p8CP8tCKRvcLd5AXACHCBlfIClPagYD85wsHCL)E)GmIPSNB95cwVGGNRg5Al(ZmxMjiPe5AfwdUJbLkOahdkfpkIamicLdDUgxi3g5Q3AqbD(xg)eKuIocwdEU0lxjCLRflsNnogiuebWDw5yE5ogpuog9wZhogukEueb4yqPckWXiBULkGOmCG4J5AGqreap3g5E)xW)2HHakL4XYL((XBWaHoHpx6LRTMBJCjPW2nCGCUtLRK5E6tCmOuCpucWXi)FXehDYh3jGsDLRLtfNnogiuebWDw5yE5ogpuog9wZhogukEueb4yqPckWXGsXJIiadIq5qNRXfYTrU0Kljf2EU0lxATfY9mYTubeLHCW(QJi(NBGqreapxBzUsCsUO5yqP4EOeGJr()Ijo6KpUJiuo05ACbx5AP5joBCmqOicG7SYX8YDmEOCm6TMpCmOu8OicWXGsfuGJPubeLHdeFmxdekIa452ixzZTubeLbrmbVtsHTBGqreap3g5E)xW)2HbSdDeqjmyGqNWNl9YLMCpUCdHA9CTL5krUOLBJCjPW2nCGCUtLRK5kXjogukUhkb4yK)VyIJo5J7GDOJakHRCT0SPZghdekIa4oRCmVChJhkhJER5dhdkfpkIaCmOuCpucWX0wNAIJo5J76Xh27hk9doMlEkapQJbtfa5JpaJE8H9(Hs)GbcfraChdh8x8iVMpCm0QPKMRT44d75Ekv6hOlxTkGqELB956Th3Cpt7qUwbkrUAWZ9(VG)TJCP86bKl5JZLqT(qqrKlNcR18bD5sfcW7ZvRCpTnT6yqPckWXiBU8Vm(jiPeDeSgCtnxlN4i3g5E)xW)2HXpbjLOJG1GBWaHoHpx6L7XLBiuRNRTmxAp3g5stUYM79Fb)BhgcOuIhlx67hVHsEUSyLRERbf0HaigWNl7CBMlA52ixVCqi6LIpGYBa7qhbuICPh7CpTRCT0ucNnogiuebWDw5yE5ogpuog9wZhogukEueb4yqPckWXuQaIYq8equuegiuebWZTrUYMlcfjPH4jGOOimuYDmOuCpucWX0wNAIJo5J7epbeffHRCT080oBCmqOicG7SYXO3A(WXCvHOR3A(OlgF5yeJV6HsaoM7)c(3oCLRLM0UZghdekIa4oRCmx8uaEuhdcfjPHeeDKNarXCcikJV0RL5YoxlKBJCPjxekssZqq8cTMp6kfwnuYZLfRCLnxekssdbukXJLl99J3qjpx0Cm6TMpCmLu83UFi0bf4kxlnTGZghdekIa4oRCmx8uaEuhtPcikdhi(yUgiuebWDm(cp3Y1sthJER5dhdMk66TMp6IXxogX4REOeGJHdeFmxx5APPT6SXXaHIiaUZkhJER5dhdMk66TMp6IXxogX4REOeGJjEmHkCLRCmCG4J56SX1stNnogiuebWDw5yU4Pa8OogmvaKp(am6Xh27hk9dgiuebWZTrU0KRERbf0HaigWNRK5Yb)GbEVu8bu(CzXkxSo8oGcIYOCU3mrUsMRewi3Zi3sfquMR9Ra6pzxQwyGBGqreapxBzUnpjx0YTrU8Vm(jiPeDeSgCtnxlN4i3g5Y)Y4NGKs0rWAWnyGqNWNl9yN7XL7y0BnF4ya7qhbucx5ArcNnogiuebWDw5yU4Pa8OoMsfqugQa5PcE)kvFVbcfra8CBKlcfjPHkqEQG3Vs13BOKNBJCPj3RufFa(CzNRe5YIvU0KlwhEhqbrziEuabeLzICLm3MNKBJCX6W7akikJY5EZe5kzUnpjx0YfnhJER5dhdji6ykVux5A50oBCmqOicG7SYXCXtb4rDmOu8OicWGiuo05ACbhJER5dhdh0sA33ga5UY1cT7SXXaHIiaUZkhZfpfGh1XO3AqbDiaIb85kzUCWpyG3lfFaLpxwSYfRdVdOGOmkN7ntKRK528ehJER5dhZHqhuqVac5GVCLRfl4SXXaHIiaUZkhZfpfGh1XC)GtnLXdySwaVFi0bfyGqreap3g5E)xW)2HbSdDeqjmyGqNWNl9Y1wZTrUYMlcfjPHakL4XYL((XBOKNBJCLnxoGqrsAaRl)9aV3(PcUHsUJrV18HJPKI)29dHoOax5AXwD24yGqrea3zLJ5INcWJ6y0BnOGoeaXa(CLmxo4hmW7LIpGYNllw5I1H3buqugLZ9MjYvYCLWc5Eg5wQaIYCTFfq)j7s1cdCdekIa45AlZT5j52ixAYv2CrP4rreGHYdDWo0raLOtsHT3VFWNA(ixwSY1lheIEP4dO85kzUnZLfRCjPW2ZLE5sRpjx0YTrUYMlkfpkIamT1PM4Ot(4UE8H9(Hs)GJrV18HJbSdDeqjCLRfATZghdekIa4oRCmx8uaEuhdkfpkIamicLdDUgxi3g5kBU3)f8VDyiGsjESCPVF8gmOC752ixAY9(VG)Tddyh6iGsyWaHoHpxjZ1c5YIvU0KlwhEhqbrzuo3BMixjZvV18r)(VG)TJCBKlwhEhqbrzuo3BMix6LRewix0YfnhJER5dhdIq5qNRXfCLRflsNnogiuebWDw5yU4Pa8OogzZfHIK0meeVqR5JUsHvdLChJER5dhZqq8cTMp6kfwDLRLtfNnogiuebWDw5yU4Pa8OogzZfLIhfrag5)lM4Ot(4oIq5qNRXfCm6TMpCmAeJ0rO18HRCT08eNnogiuebWDw5yU4Pa8OogskSDdhiN7u5kj7CP9tCm6TMpCmKGarOCWvUwA20zJJrV18HJb8EiUqhbdQLogiuebWDw5kxlnLWzJJbcfraCNvoMlEkapQJr2CrP4rreGr()Ijo6KpUJiuo05ACHCBKRS5IsXJIiaJ8)ftC0jFChSdDeqjCm6TMpCmxP677(cpwcUY1sZt7SXXaHIiaUZkhZfpfGh1XuQaIYWbIp6icLdEdekIa452ixzZ9(VG)Tddyh6iGsyWGYTNBJCPj3RufFa(CzNRe5YIvU0KlwhEhqbrziEuabeLzICLm3MNKBJCX6W7akikJY5EZe5kzUnpjx0YfnhJER5dhdji6ykVux5APjT7SXXaHIiaUZkhJER5dhdhi(W3rMcCmx8uaEuhdMkaYhFagekCmXrV9tfCdekIa452ixoGqrsAqOWXeh92pvWnyGqNWNl9YL2Dmx7xb0lfFaL31stx5APPfC24yGqrea3zLJ5INcWJ6yKn3sfqugoq8rhrOCWBGqreap3g56LdcrVu8bu(CLm3M52ixAY9kvXhGpx25krUSyLln5I1H3buqugIhfqarzMixjZT5j52ixSo8oGcIYOCU3mrUsMBZtYfTCrZXO3A(WXqcIoMYl1vUwAARoBCm6TMpCmCG4dFhzkWXaHIiaUZkx5APjT2zJJbcfraCNvoMlEkapQJbHIK08uv)j7ynoadLChJER5dhtjf)T7hcDqbUY1stlsNnogiuebWDw5yU4Pa8OogIhfqarz4JV04c5kzUnTqUSyLlcfjP5PQ(t2XACagk5og9wZhogsq0XuEPUY1sZtfNnogiuebWDw5yU4Pa8OogIhfqarz4JV04c5kzUnTGJrV18HJbfehajLOJHcdA5kxlsCIZghdekIa4oRCmx8uaEuhtPcikdhi(OJiuo4nqOicG7y0BnF4ykP4VD)qOdkWvUYXC)xW)2HZgxlnD24yGqrea3zLJrV18HJHakL4XYL((X7y4G)Ih518HJX2QVYL2gkL4XYL((XN7qMBBi32JqK7bu5Q5ssje5EM2HCTcuICXajg8sZ9X5oK5wsHCH4(urb4ChFUQG49vUpka7yU4Pa8OogzZTubeLHdeFmxdekIa452ixAY9(VG)Tddyh6iGsyWaHoHpxjZvItYLfRCjNdPvhde6e(CPxUsyHCrZvUwKWzJJbcfraCNvoMlEkapQJPubeLHdeFmxdekIa452ixAY9(VG)Tddyh6iGsyWaHoHpxjZvItYTrU0KRS5IsXJIiadIq5qNRXfYLfRCV)l4F7WGiuo05ACbdgi0j85kzUhxUHqTEUOLllw5sohsRogi0j85sVCLWc5IMJrV18HJHakL4XYL((X7kxlN2zJJbcfraCNvoMlEkapQJbHIK0qaLs8y5sF)4nyGqNWNRK5kHfYLfRCrEVp3g5sohsRogi0j85sVCT1tCm6TMpCmY)A(WvUwODNnogiuebWDw5y0BnF4yU6vk0FYUEp1udg49cdQNcdEhZfpfGh1XGqrsA07PMAWaVRwhmuYZTrU0Kln5Q3AqbDiaIb85Yoxo4hmW7LIpGYNBJCX6W7akikJY5EZe5kzU26j5YIvU6TguqhcGyaFUsMlh8dg49sXhq5ZfTCBKln5Q3AqbDiaIb85sVCpDUSyL79Fb)BhgWo0raLWGbcDcFU0lxjojx0YLfRCrEVp3g5sohsRogi0j85sVCLWc5IMJjucWXC1RuO)KD9EQPgmW7fgupfg8UY1IfC24yGqrea3zLJrV18HJPWtyjunDmCWFXJ8A(WXyXaPsjQCP8qUtbe5k(J56yU4Pa8OogukEuebyk8ewcv3BpUDV4RCzNBZCBKln5IqrsAiGsjESCPVF8gk55YIvU0KRS5wQaIYWbIpMRbcfra8CBKlY7952i37)c(3omeqPepwU03pEdgi0j85kzU0Kl5CiT6yGqNWNl9OnLBHNWsOmvtZ9Fb)BhgofwR5JCppxjYfTCrlxwSYf59(CBKl5CiT6yGqNWNl9yNReNKlA5YIvU0KlkfpkIamfEclHQ7Th3Ux8vUSZvICBKRS5w4jSektjH5(VG)TddguU9CrlxwSYv2CrP4rreGPWtyjuDV9429IVCLRfB1zJJbcfraCNvoMlEkapQJbLIhfraMcpHLq192JB3l(kx25krUnYLMCrOijneqPepwU03pEdL8CzXkxAYv2Clvarz4aXhZ1aHIiaEUnYf59(CBK79Fb)BhgcOuIhlx67hVbde6e(CLmxAYLCoKwDmqOt4ZLE0MYTWtyjuMscZ9Fb)BhgofwR5JCppxjYfTCrlxwSYf59(CBKl5CiT6yGqNWNl9yNReNKlA5YIvU0KlkfpkIamfEclHQ7Th3Ux8vUSZTzUnYv2Cl8ewcLPAAU)l4F7WGbLBpx0YLfRCLnxukEuebyk8ewcv3BpUDV4lhJER5dhtHNWsOKWvUwO1oBCmqOicG7SYXCXtb4rDmYMl)lJFcskrhbRb3uZ1YjoYTrU0KRS5IPcG8XhGrp(WE)qPFWaHIiaEUSyLln5E)xW)2HbSdDeqjmyGqNWNl9yN7XLNBJCjPW2Zvs25E6tYfTCrl3g5stUYM79Fb)BhgcOuIhlx67hVHsEUSyLRERbf0HaigWNl7CBMlAog9wZhog)eKuIocwdURCTyr6SXXaHIiaUZkhZfpfGh1XiBULkGOmCG4J5AGqreap3g5kBUOu8OicW0wNAIJo5J7epbeffrUnYv2CrP4rreGr()Ijo6KpUtaLMllw5IqrsAiPWZt57hk9dgk5og9wZhoMsk0LsfLRCTCQ4SXXaHIiaUZkhZfpfGh1XqtU6TguqhcGyaFUsMlh8dg49sXhq5ZLfRCX6W7akikJY5EZe5kzUN(KCrZXO3A(WXac7(rJohUyaCLRLMN4SXXaHIiaUZkhZfpfGh1X4FkbYeCdQxO1iGU)fOGOmqOicGNBJCLnxekssdQxO1iGU)fOGO6sPi04hUHsUJzIcWyk5vFiDm(NsGmb3G6fAncO7FbkikhZefGXuYR(qqa8rlWX00XO3A(WXqkaV0lwjlhZefGXuYR(H4ruHJPPRCLJrogUpbIwoBCT00zJJrV18HJb5Rsa8oPqTd82tC0R36t4yGqrea3zLRCTiHZghdekIa4oRCmVChJhkhJER5dhdkfpkIaCmOubf4yA6yU4Pa8OoMcpHLqzQMgPQVt5HocfjzUnYLMCLn3cpHLqzkjmsvFNYdDeksYCzXk3cpHLqzQMM7)c(3omCkSwZh5kj7Cl8ewcLPKWC)xW)2HHtH1A(ix0CmOuCpucWXu4jSeQU3EC7EXxUY1YPD24yGqrea3zLJ5L7y8q5y0BnF4yqP4rreGJbLkOahJeoMlEkapQJPWtyjuMscJu13P8qhHIKm3g5stUYMBHNWsOmvtJu13P8qhHIKmxwSYTWtyjuMscZ9Fb)BhgofwR5JCLm3cpHLqzQMM7)c(3omCkSwZh5IMJbLI7HsaoMcpHLq192JB3l(YvUwODNnogiuebWDw5yE5ogpuog9wZhogukEueb4yqPckWXuQaIYGiMG3jPW2nqOicGNBJCPjxmvaKp(amCfB5HqXqNa4QqmFyGqreapxwSYTubeLHdeF0rekh8giuebWZTrUYMlMkaYhFag94d79dL(bdekIa45IMJHd(lEKxZhogAZEi3Z0oKRvGsKRw5k(25sBrHTNB7PKMRvIj45sBrHTNRk(4i32tjnxykPaoxlwXwEiumK7JZ1IbIpY1kHYbFUuHa8(CP8tCKRT44d75Ekv6hCmOuCpucWXq5Hoyh6iGs0jPW273p4tnF4kxlwWzJJbcfraCNvoMlEkapQJX)ucKj4g5u(IsaDatjVMpmqOicGNllw56FkbYeCdQxO1iGU)fOGOmqOicG7y0BnF4yifGx6fRKLRCTyRoBCm6TMpCmk(Qb0RhJHOCmqOicG7SYvUYvUYvoha]] )


end
