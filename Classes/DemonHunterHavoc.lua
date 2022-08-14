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

            copy = "blade_dance1"
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


    spec:RegisterPack( "Havoc", 20220809, [[Hekili:v3vBZTnos6FlE3AvKY4rJeLLtM5S8wtYKDNj1C5UAD2AUQU6effjKfVqrQJVyhFLk9B)6gaeeacaKs2oj3xsSjiA0VJNUbj98XZ)48BIckjZ)G3ipVrVE8fdh)JtE9fZVP8HTK53Sni8tb3c)qAWg4F)1G7YcXR(qswqeo5ISQ8qyKBI3uLeugNL(28GvLZVzzvCs5VLoFPXfycScfBjHZ)W0x9Q53SookIWUxsbSa)cztw6(f)AvAjjh(FCz3)(FU62QIY9l(XZ3VaP2(3V)9VDDq6TKIFA)7)(9l(xjLbBYY3UoRiUy)IG0O9l(3ZqMA)IQcqo2V4pTKSklh(HvX3UgOfjnQ4pTFrs2TXHWmI(VHvGatRmd(TTBtEy)ISu8FXlSmROGpZIH0v83ZYkii13UFrXdPHXP3cty1bSs)nXPSb4RBoztqCkmYDaLwuMhN(jcC53(lWqbLRrPUeeT9l2e85bdbvEE2Q4eqr)N)Z7xyw9GJysfHxVrnH)2xEvfFv)cPUqPoiefMIHBZjHzBwguoBzwzzcjYFvsWdKO7H12Vm7ZWcD49(DZ(H7cYJdwMqoh98NXxrFKP9lsYkp)UGKkYSXNhVQEWHJhUoOWVQG4VSA1QE9pREapLb2TRzcHzzjrz3NomQkNg9C9SMjDWGdEmSQNmR6zJvhBHvnWnx7qmaofS4)ZcW75Dpa)ZBibBaVKs095(9l(Bv5GFY9XLRHHsIrNp2LcsYqxc2iKyML9xcY)0TjbORywUW7)njbqYcWxknHG(AvfuVPF(2SuGq)9G)xsx0wOKsEaKwGb9xb8GFywAumonUERmiHKwoCjYM07yijfNFuV(5vPyiYTKHr1SO)gsuqscmDq3XMzeYV(lPSRyUN1m3aKJ9Vfyyl23vGaUoetRIMqiJBYsGxgUfI)Qsa2pVABjDbfdDxgMlggRil5oGhmt3G8WGuceeKNtVhwy67(mjSIgytUJG2KY4nem8c(hGkOfGMX4UG4euwgki(SO4cKxexawdqBwuTbulbywd6c8haHIYsFrj(FiHrYvgaQc4kf3dPsOgsP0kVPkpLET)iRc8vOuPzjYjSj7huvM5huwc7zDoyTi(HrqakFqqZbjv(Pic6xpCjJI(3JeCip7cQDBmlk3sph2sQR(Fa(QzvL0mTzG88X1Kmu5Lj7)Eo3RfVuAiP2p)VfNJ5SFtswweBgyGYKVdYd69D130hZb9nlN4)OkgcW4QSczTTQVnLn9JWLcfnjxUqKj9lP8OSROb3y1OGviRcYpWP1Ip42TLKK4ZzNHsR64RN1FY3ZNAjka(zR8Zb2VEYdekpnn3HQQ14ghuVq0cYCcXCoNBwnIQqu71FSdviQRzJ9UcyJjCDEtoj4tSPFbo9jpHwaZgaUgM6xkF9HO0jYIyqZ3ZPI3ZTIF3UZ4Jh(qiKPagFDqzoPJu)IoBwT79J640S8nbjnX)Hq0wzT1gvjyIOL4odqUbcMBoadRiWaHLNZJwsUp4HcUn7JG9AfE10S0VNUvbM35OnqNwKqFQrCJmyMHvBf2qJ6QD745Kimxq)LOhimTbUTaTey1yFJykHozxVqAFBTiIA0GQ2WymsSuBlboEYmmmTgAq3SbzBNLtki0n64SVQAPwieiouhg(NOhKC(KrdWyQ3IE7SO4FL6VFoY4zXrceewY7GYoDNkmf0waEB8Y4K4soExYNlji5rmO)C272V4M40vvjO2dx2oj8koGnOc6zooL7owtozdzpC1Ud(LSYHfu(aupaBCLNDgzlOqXT7Gv3hDG5K3MtKq)R6SZ3j9Ql7rrkfrwfhgxE9KrDBHL1goeV(iXV6vt)E7XIV0B0GUTM1O)udV1L3ZSddSXvKtjHwO)THrdHksEP3av9H3iZ(OOVyzjzdGHI6vHy4vrqJ(yIqQ6k1O57G1bQbhUNAm4N3GnMINaYmAvHCFaa5LRqA88S5rw7BO7FnSmo8tazAujkJwRwQ1kxa1DyXpctAYDIjPKnXKIzJ1ZhwRUVA2KUjyBY2aMWknlD9vBm1SK41xgQvvgplSxGp7x9tIlkzRstsovOPBb9HF1w)v5b3IK7CSRkZO(wOULHMerTlUJIRh1kr2KfrMLsGnNkOjk7R6Z6dOMjLXLeHeP47nBY0D7KG5YCOb106EmOXnxGUjKKnsYbhsZUBhnmCIAGw568S79HTobBhYCuAUIa(ayzh5rOemSaXOpBAp2(LXB2KX6DeaHppGA8pZ4oPkReidhAj46GZlGItdl51NBmKUvsXHM8EAO6BdqSLATPa387Ekm(eitpf)catbC4tucAZjRat1AgyfCo0TqGDTY4nWHU5zYMmCjYGIUAkxRw1ptrtqrZBjrvFRPJGSoGjd7NIFDKO30bhUwG(4Gv7uwmWZXu27D7ets6QI5XtomORS6wAtReEAg3o6ApWLh7ivpvAE5iJKe7jae(SHNbjpyBbUTljbGCMdgjWvn0hwxqJeJoiTsICmdeqHWSKeGy08rvLvGtHGVPj9PXaCy)QC6KUWPHbHRPaecc)FQIbic(aoHGcL1rmuWNjqavV(91sZcf2YMkllBpaCzKpbBIWWGOOIHXPxF5i9KZxRnliRH6nC1ejZ(b7tc7vB0(qT50(DUkOkPe3VdbHbcCDBinPu4TLIg6lCapORyZg3ZgA9(2ITOSOBKpx3xve(RoAs2FXBGz5EgvH03bZ717mdDMJMwgr(BFMU0yETOX8(YQXm0YXhHgBCVZmykovnMmUgA2yRqH6BStFaVApCygKdKUNnSx9ObdosusMTWqIH1WUnU25Orhyc0K0W6Lkawe6M8v5Xzvfu5tg1KmFqsEOioi1pIeMtO4d67otcav5WeqYqoKPULgLQ3nuocp9ldkOnbPqLGaZFEmUZm2mtFaDcjkoOK2SFXvVnjBzqIYLCTKYNibxVptu4HT6(ofvJNOOiTYfF54rd6z1l9GbK9fpG1rvnGOlVQyTe4GQ0LyRs9P9WQjdaQQvhc32b(jqikM5brcsIXga(dfHiikJhzAZhqmgyIHIibLR9lUNq2QKgtcJHPPXaQ6JB)YrtFck9XJmrADKWyZRQIb9m4VaUtr8H6qDKx2ZmC4ENv36OpVnRaOiRD2YXEnSJS72jiJUCSKr654av06u81J5vq8kWZ0CYNMGbtsKwVtm2QaBPoPj(DHFDQQJzTAOEcgCnr4kgDn1QVHMd2sHpMMEqAA86y29rNRXeXT4NdXR07ajGA5Gxy05vPTAMUbwNQXYS(ePtCLLnqQv8DmjJ5dtZsfQplPzGFQWFjac9CwGa3BMvQPTJpY1XoD1fTj7N5s41IPEEL5UKNJkPzvL0wsJp2bw8RLLqbZfbLFJElxpEkhwrhOeif3sW9UYjyfpL2Oyx4ENh0xdbynh45zp8XtF87uZ4pl6gBD(IQV3Mt2gGNdennhE4Vxp2aDLTE9nUj)UDUbukkAWiWbatUiQwppjd1(GNmxDfHAzaS98TKtCBs5c1fK9OWMiM1jTTHy2hcSPf89NKN6itAXVja(i4g5q0NdvW0VaOFmPL7a6hZE4DahqJYZmmaX46yt67i9PCv2Mu)m9rndD1Kr8namFctthybqHB5xh2YtkdBJLqj4K4wzFx7haLlyQT5zzmB1ZkehtRtl7VCMTnSSKZNVTawzIZTZDgDCkqsmY9MjuFtuQNnj1ucGJh1J1m0o0sZV5osEbmD(tW70rJNFZ9buJCX8B(JF(F8HF7d)9FA)c6tUZ(fXB2MLxYptYxWwXxGNbcRVZ7xuKHpoz4ZQ1Ma6Jzwi7ztD4(3)7XPWqJbI92SuyzPd)IghU)JxWowu5lvZNVaFuFOp7NCQC5JKm7FFlYweRR0hNWn5rYvpsQGhe87(3(DnYDXtl5M(0sUxProUZQGw1)(rtOoZxQowNS)Pox1QhM4H1848X80vyI(E3OZ4xQKDT(EscOTP7zy6EhoDDFZJC1Tn9oU6NSRScv09Gf91vqKMRyZp5ePXr7KuVv)X5JG6P)zAr1wKue6d)e7OeRFYd2V4)C)I2o7Z)R)f8CSlXNipydhQiylA7M4nVL(aTug859l(lmvWVxfGZ8U4c6kMTLafiGsv)FyqBzbA3TQlt3HBL80F9tRW86hNWyB6Duy(XtogrjpOEEIo6G3v)AElAoo3A9CZDyVcvH6jr1Od94O5ItplwTY932uhypTjIgF2wqD18BO)e((BXaOb)0hOVly1G(EZ8BcZH0bqTdZVXuJTeGOx0dwv2s0u58(fxdHcQvpVFXUD4BRJETk07fqPUyaLw2A8L5bfVxqxnB)IBdb0QmzfKeEPtZlbGRwfnlWTPl2HDdJEz2RdbYZnlMouCCrNyDr7ZPTEdZyAiNLCwRUpd4dhnpJrPZAEubn3cnQoFqnn5vnTFbOk9yuOVIbtQelMcyeDQ2mPJyKVrlvxueQDUWQ25r6jnzK6cYBNhUMtTUMMAEsdzKAFhsMlTsMZ4g2dBqxdX0gdj4RCrWo5o8i1zutvdlQ26qKdFTvoSLE7rzqR93dcBHKL07Pw1P3PV6bT0VVgMwUKwKL)XV6k1PsbRDPbHmQP0KqgHydSI(cYbkSxnQoO1MKi1Ehz7QCkXXJoXGb5lI0X(2gYnhdeeiRYfQXMusrjcnbTGnL75OmTX70zwvxn7PoJylM(AnDdJFfMtHnG92rsVTPMSlwA2xJ4k3cvQiAp14ZSi6M5r5(4Lo5(TsLo7jHT2Gtx7YWwh)6umDmSWsmHEM9MnaeDQ0mUi1MEkZ2U6kkvXFbqr5MSIaXqE5vYHekmGAaH9uZnyemcVXXg7cKaVuSjVZoeAAd(X2taFqtkf5lfbzA9f1CAdp75WCVe9nVk1opw1AwWY4zphOn(Wn0rVwbS62oOTxyj6ar7vPaNVWXI9g7Q5uPKow5n4v7g1ZgNbwQcsPK0XJdP)Kp7JiHsEcf31MakL3dszVwL7YWlPxJYa)ssKhVLXhF9E9CrjpPIiSCgExLmSXVYRLhBZtWPDc9JOaNqgFT)qFudORFm2f3gfd65)F8BYRWyrtpCWlJlZq5Yq2Rt2rVUyhfBNB(XU7yxZl6YAAQkPNgFNJlu9BI3A4oh523ATlsUlwu54Dy59)TgqwhmUDkXGUdfVbBhLJ0fMkag9qOV1UNKpcNBm(A(Qv(4HVQVA(ophV4YMQq)PjMWs30ChVBmA5BKxZzreJXhgfu241uR3hpksyptDAWPMMUwUDOD)UNi1acTQvznsQXyQxjKPwm0oVAvV0xU((PYrZgZ68s8R7efpQzouViDDGYTZPouPnkClLQ5UFp9PnQfFh)yYrDAUdmaEwnakfTPd(UtXM2klSBHPTfd(m)ACl767SD5cdHLEMRAjUqQFvwFHJyBIO3ASz0UuzA7kXJ3nTd9tA62txTyYEJgRJv05WMxyBBw66BXyNKe17O9gEZoSeo1K3uWrJAOmKXx6zQUs0zqBpoN17uBbwXa7T9S9(ROfsdQE6RknwyOGQ5QVp0kQa(8D2WexZNFIt8Ysz06R9Xp5PKY1ks7xkovJEFLoOklN2tpRNOuVV8hTJ9w06UZYAhZYZ2jenwQl0hEuh2JF(M9OoSFGupsn1Xfw07R9HDyoMY(PRzfnM9na5hBkpQYUX(AAs(dJZAR11MU1Rygc1aoneEo7c8PCMKD74ZAT9)hC4g2Bz7rCCrkTW05XfzpHAheJdC7mIbTb4G(rDyprOZtXrZbu9vA7Rsg9dq60KY(l)bJypb9zTC8y6GtRt481qJEPsx4TF8o2ZE5(CsoaxO9mepYJJ5XCIpsq(nDmi2twCIhdIa(UbaN1ZsjHVwLEFr)ka5W1wRI8w3lYJFa2kF0mA2zPtqpp5f(qCbk5yr(sqePruOJOo1bUfelwrNOsDDQ(Cqq0ab6x06EMw7lL2OI99iYeawE9OT8i1AcdQOSkmtPXVJqhipAFpHSP1WMCX4lh02aetXEE2)KdDalP9PhQ2XWq1BZmat1EM2lhzUPeMa7oWwbJxrBIUIVOri8EJe(GoCi4oJ8Eg4qhzaFQi7f)ZyKwkiRFlKmIS9WVMn8E10RTJTOFBhvGq8BRfRxZAVPMs6VUFH0J4SGg1D9A)IFOU3GTPUNPyv6lLNXS07vdXs6zKwS(npxK8wWyNyUXD3jM4BhtGHp2spJMGXhyc0)Mm1rtGE0IxR1U4STn91Eadm1WjUe6knbRfpmnfTqwSAg(ty1aPf606YAJqllhTuDLBhjB1wR8irARsi2dgMaRO2Nbkz4ySVbvnLWzKtF8DZBI6JZQ63CQwkl06xWjJ9C21NqkOSAPpnuoOSYnw)XMA(nsTJT57AL89Y(euH3ifBR4LfBU(d5JT)WxOvRXX3w(XkWeBcLL)tiHK7UuYg17aTLU3madGCNRs5SWmMR(OEyLOYNNr5tN7pu(01akYNrU)62uaTlEh1Z8J8PQy5u863XN0kU41EhnCNwDGXJY)R2F7qKv3oAJPj06gsMO)NQdvDxR5CmMjOgvE9qQ)18qn2MMGiOQCDwo9pvtVLEL5)F)]] )


end
