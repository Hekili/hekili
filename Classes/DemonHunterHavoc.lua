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


    spec:RegisterPack( "Havoc", 20220821, [[Hekili:v31)ZTTTs()w8RZtrk1vvI2YjTJLFttAETntVC38CVj3pjkirilEHIuh)ID8nE0F73UaGGaqaGuY2j5MoJRnbXI974ZUGKz24z)1SRJiL0zFiyuqWOxhmE44xF2pD(RMDD59BPZUElz5Ni3a)skzd8ZFNCB2s8Q3NKrIWzxKvLVeg564nvjKY4S03Mtwvo76fvXjL)r6Sf2xHjWu3sxo7dtEfSyRJJIO87LwalWVs3KLUB(VxLwsZH)pUS7E)VuDtvr5U5bJpf(bqUDVF37F7As6n0IFE37)HDZ)3OLKnz5BxNvexSBojnA38)JmKR2nVQaeKDZ)BlORYYHFzv8nRbIrtJk(B7MNKDt8sygr)3WsqHPvMb)12Tj3VBEwk(t8clYkkeZSyiBf)ZSScks9T7MxCF6Y40BGjSApwP)M4u(aI1nNUHeNcJClqP5L5XPFIcx(T)kmePCnk2LGOTB(gYNhme055zRItan939D7MBx)GJyvhHd0ONW)6lVUsSQFH0xOutwIctXWT50LzBwqkNUiRSmHgfUkHCpn6oyTdlZ(mSq7FVF)0F8wsEmzrc9u03FQyfdrMoSijR80Bjjv0PJpnEv9GdhpCnPiSQGgUOA1QE9pPEGaTbE4HMjSmlljk7U0Hrv5S4NRM2mP9gCWJHvduz1axS6yhSQfU5kpIbWPGf))Sa8EE39WpEdLSb8skr3N72n)FwLd(j3fxUggkjgD(4xIKKHUe8rOXCl7VsY)0nje0vmlx6()MecKUa8LstOOVwvbZB6xUjlfi0Vr(FPDrBHsk9EqAbgmCfWdHlZsJIXPj0BLKeAA5WfiBYUJH0uC(r96NxLIHi3qhgvZIHBOrKKey6GUJpZiKFdxWyx5CpPzUeKJdVbyyh23vGaUEjMyfnHqo3KfaVmCle)vLaSFE12s2ckh62mmBmmwrwYTapyNUK8LKukeeKNZUhEy67(mDzflWMElfTjLXBOy4f8dGkOfGLX4wsCckldLeFAuCbYlYlaRbOnlQ2aQfcM1GTaFeiuuw6lkX)hsyKCLeqvaxP4oivcZqQKw5nv5PSR9XSkWxHrLMLiNYNCiPQmlKuwc7ADkyTOHlJGauXGGMdsQ8Zru0VE4cofdVdj4qr2fu72yw0ULEESLmx9pc(QzvLSmTzG88xRPzOYlt1)9uHxlEP0L0A)8)zCoM0(njzzr8zGbkN99qEWGVV(M(RCqFZZj(VQIHamHkRqvBR7BZyZWiCPqrtXLBjYKHLmEu1v0IBSEuWkKvb5h40AXhC72stscfSZqLvD8vt7F2piMAjkaHzRcZb2VEYdKkpdn3(QQ14ghmVq0cYDcXCoNAxnIQqu71FShviQR5J9UcyJjCDEtoL8j(0phN(zpHwa7gaHgM5xQE9HO0jZIyrZ3ZRIpWVI)Hhorm(Y7xczkGXxtkZPDK6N3zZQBVFuhNMLVHK0e)VeI2kRT2OkbteTa3zaYnqXCZemSIcdSS8ur0sYDK7le2S)cSxRWRMML(dSTkW8ohSb64Ie6ZmIBubZmSAR0gAvx9WdICsuUly4c0deM2a)wGwcSASVrCLqNSRNRSVTrernAqDBymgjwASLGapzggMwdnOB2GSTtZPfu2gDc2xxTuleseh6dd)i6EfNpv0aCM6TO3opk(3z(7NImEwCKebHJ8oOSZ2PctbTfG3gViojUuG3L(5sksEed6VK9UDZVooDvvcQ9WLTtcVMdydQGE2JtfUJ1Kt1q2dxTBH)iRCybJpa1dWgxg4Mr2ckuC7oy1drhyb5D5ej1)6o7IDsV8IEmKsr0vXlJlV6SrDBHv1gEeV(iXV8vt(b3XIVmy0GUTM1O)0dVnL3tCddSXvuqjPwO)nlJgcvK8YGb66JGr29rrFXYs6gadfZRcXWRJGg9XKHu1vQXY3bRdufoCp1yWpTbBmdpbKz0Pc5oca5vOqA88C5rw7By6FnSmE5NaY0Os0gTwTuRvohQ7WHFeM0u4ettPBIPfthBMpSwDF50Z6MGTjBdycRmS01xTXuZtIxFzOwvv8SWEbH8)mmjUOKVknj50HMUf0hHvBdxLtUbj3PyFvMY8TqDlhnjIAxEhfxnQvISjlIonLcBovWsu2x3NneqntlJlPsjsZ3B6ztE4bfyUChAqnTUhhACZfyBcPyJuCWH0Sp8alm8m9aTY15z3fcBDc2oK5y0Cff8bWYoYJqjyybIrF6KE89lJ3SjJ39iacFoHz8pX6oPAReid7Bje6GtlGItxwkQp3AiDRKsan59Sq13sqSLgTPa387ogm(eitpd)catbC4t0cAZPRat1AoyfCoSTqGDTYeDWHT5zYMmCjYGIUAkxRw1pvttWqZ7irvFNPJGSoGjd7NsyDKyWKb7VwG(yVv7ywmWZXw27hEqojLRkNNi5WGUYQBznTs6PzD7ORcaxESJu90P5fJSssSNaq4ZgrgKCY2cCBxAca5mhmsGR6YqyDbnsm6G0kjYXmqafwMLKaeJLpQQScCkK8nlPplgqa7xNtpRlC6sYY1macKL)pvXaeHqaNaPqBDKdr(mfcO61VVrAwOWw(u5zz7bGlJcPytegsIIkggNE1fJmtoFLXSGSg63WLNPy23BFsyVAR2hMnN1WZvKQKsC)oeegiW1TH0Msr0wkwOV0bCVUInDCpxO177k2IXI(r(CvFDr4F4Pjz)9Gb2L7PmfsFpmFqVtS0zowAze5V7z6tJf0Igl4lRgZslhFeASX9oXIPOtASVdBkbMJUynSvDKWnKGG2Y4DOKcbvB3Yl9POe0ra2limhRFyrgIXt2XAKIy2ESAcscVCfyVE(wbrmOCd9gQxyDuvCwSDhCcnRV1opc6o3HNtHCYmmea2HrdgCGO2S7XbjQwdISVDYASj2aXPmSzPlGhcd0rvECwvbt(urXPYh0K7lIjPHr0L5ugEL((ZSbqN2pHOkeivQ7OXTMDNvG408YGcAdjfQmfy(tJrKcyZvdb0s0Oysj7WhKx9MKSfKeTl5BjvpHeHEFQSqix1HEmQMazrAgLV(YXJg0ZPx6EdO6lUhRJQAaHzEvXAfWkvPlWw3gY6PwtgjuvRpeUni8BGqumnaIeueJnaCmgIvqugpY2MHGymWgdfrjLRdlUJs3QLwvbZJTPXbohIWbeO7pcL(4r2iTjYCSzAvXGEg8xa3PiXqDOU2l6zhEEVtQBL1N3MvauK3ED1yVg2r1D7iKrFowQip9CapgDU(QXIkAEf4zAp5ttWGnjYOxowBDHRuNSDc8HNEIUJzTAOEcwCnr4twDnnQ3ILd2rHy2MojnnEDm)(yZ1AI4w8ZH4v2DGeqV80ZT68Q1MpB3aVZ5yzFFI2jUYXgi1k(oMKX(H75OI5NL0mWVveUaGgCkpqq4nZl911Xz57yWU882K9t8j8gXupVYCxYZXK0SQswlYXhdch(1QsOK5IIH69aVLRgpraROducKIBO4Ex5uScSsxuSlCV3dESHa8Mv88Sh(4jp(DQ58NdDJRoXX03BZPBj45sXsZHhg9vJTqxvRxFRBY)Wd(buklIXkWbOgbzuTzEsEvedEYC11eQfey75BOh52KQnoqs2dcBICwh12gYzVpWMwW3FuEQJSPf)Ma4JKBudrFoubt(cG(XMwUdOFS7H3bCankp7WaKJBInPVN0NQv9Bt9Z1h1m0LNnsSbG9t8AYahak8l)MWwEszyxSekbhf3Q676(aX8btTnplRzREwH4yBDAz)LtCTHLJC(ITfWkt8UDU3OJJbsIvU3oH6BJs9CjP2saC4OECMH2JwA213sZlGPx)mfp6NMD9DeMrUy21F8x(xF4p(WV9Z7MZEsI2npEZ2S8sXzK(c(k(c8mz49bF38Im8XBdF2X2qyTGBj)zLD4U3)NXPWqJbI92Suyzzd)IghU)RxWpMw1lvZNVaF0JyplQcQCXJKm7EFlYweVl5hMWD2JKREKubpy639V)NgK78NwYn5PLCVYGCcNvjTQ)7dMqDMV0DSoA)ttUQvpm5dp6H5JfyQWK9HVrNjUuj)A9dueqxtpWY0d2F6M(Mh4Q7A6DC1pAxznQy6bl7RRKinxXLFYrsJd2jPER(dZhXiw464nVL94Vus(8U5)Dod(NvKDZJIVngt)VBE2wkaFhxZ()4G2IrB3O3LP7XORo9x)0kmV(XjmUMEhfMXJoAxynYygi1r)VU62j6GYH51zM6SdPY1fQNevJjYGdMlo(Km1k3)GPlXjpP(rpA3C8rHb1vZUguHRZYzVNxVD21SRJV(xC0uWV9b27swncT3m76L5akAaO)SRT1fkjI359aEGVGnL5UB(vqKHEPU7M)Wd4R6JzHfS7fGuoFaJwU6sL9bLVurxoD38Bwcql5soijI6CMvcOmDkAoWgZwS9BDf7Y83LcKNBwmtCZ4IEMZfTVG2MD3IRH8wFyT6(eGp80PloLoP55m0E)Uy68b10uuIZU5GQmGtH(AgmL6H4kGrSP6YKoIt(gTuDfmO25CNANhPN0zJ0xqrV3W1CIZ10wNoAiJsV2qYCHtYCIWWUF30AiMXyibFLpc2j3HhPoJzQAyr9(8HC4RDYHT0iogd6SzCqylK6KDp1QoZ2YvpOJMZ1W0Q1FIS8p9vxPorjyTlDZJtnTo6XjeFGvS3UoqH9Qr1bTUKeLEXOAxvtjoE0rgmOErKoU32qTtwGGazvoxp2KrkgryjOLSPAdcvPnENEZQ6RZm1zeBX0xRPBy8lXCk8bC37q2TnXMDXrN5Aex1(DYer3PgFMfr)mpk3hU0P2CuM05ojSZUr6Bxg(6ewNIPJHfoIjmZS3SbGSTI2XfP3Hsv22xlmzk(ZbkQ2rueigYlVsnKqJb0diCNAUbJGv4nE2yxIe4LYn592opBBWp2Dc496OOmFPmiZOjM2tBe4ohM)LOV9vP25XPwZbwMa35aDXh(Hog0kGv)2bJ9clrhiwJfL48Low8x3xdNkT0XAV(Vg3Oz24mWsvqlvKorCi73c5Fdk0YtO5U2eqP9suQ61QDxwEd)Aug4hII84TC(4R372lk5jvuPLZYl6KLn(1EN(4BEcoTNX(cmiiK13zq0h1c66hJDXVrXIE()h)AalnwS0d79M8Ynu(mK96KDmOl2r5252Fg5o0188USM2Qs6PX35Wcv)M4voUZrU9Dw7II7IdvoEhoE5HRbK1bJBNsmy6qjA32b5iDUTcGrpe2R87r5Ji4gRVJWgLpU)7jSHVZZXB9STk0FAIjC0nn)X7wJw(g5DKwgXy9jhbLnrn1M9XJHeoWwNg8QPzRLFhA)V4kknGWOAvEJKAmMMvczRfdTZRo1l9vRVFIA0S1SoVe)0qXWJANdnls3eOC7CQhvAJc3rPA(73tFwJAXxqqUCuNMBpdqGtdGwrBMGV7uSPRYc7wyABXGpZVd4QU(EBxU0q4ON56wIZv6xLZ3oi(MiMTgBkRlv22Us(SyZ6q)znD7PRwmvVrR1Xk7CyZB7TllD9TyTtsY6DmE9W5hwIGAQBk4PrnmgY6Bmntxj7mORN9Y6DQDaRyG72E2E)vmcPbvFj(EwJfgkPAU(ltTMkqmFVnmX38fN4KOSuoT(AF8tbAPCDI0(LYt1O3xPdQYXP90Z5jk17l)r74UfT(7SSXXS8SDcrJv6c9(h1H74NVzpQd3hi1JutDyHf9(AFyh2JPCF6AorJ5EdqXXMkIQCBSVILKF)4S2ADTTB9sUHqpGZaHN3UaFmNjz3o(SwB))EhUH7w2EahxKwlm9ECrUtO2bXyp3oRyqBaoyEuhUte69uCmCa1F)Z(QKrFpKonPS)YFWiUtqFslhpMj406eoFn0OxO1fE3hVJ7Sx(pNK9Wf6odXJ84yEmN4JcKFBhdI7Kfh5XGiHVBbWz9S0s4BuP3x0pHqECTnQiV19IcehGT2xCJMDw6e0ZJEH3hxGwowKVKerzen6iRtDGFbXHv0lQuFNQVaeelqG95WUNT1(cLnQ4FmJSbGvupAlFlIAOuR3Pf0QYcWWCQw)CfTNKB8zlYL(fBhgxc8qBlGrL7o6(lB0ESKXx4OAxil15n1cGw35KVyK92xydw8axLwEjRD7AETwb7hms6T6X1r42k6UGhDKfKSY8CIVwsgjRC(jxYkg49)O5i6QtV2oGJ(TDOcsXVTMXEfVrOgkP)XU5kpB0sAu3FSDZ)X6Ui2M6EQMvPVsgj7sFqnymLhUA5638eukAwJBI5hHENyIVDmbw(Mo9mAcgVNjW8t)uhnbMrlb2QYrl(5l6hmQg(t(vIQL6LAR5V9nEyjS18mHnWxImE7Q42swr5yLzINwSbkl0X1X4gXwvoAkYRl483)4jS2NaThVtxv1XFi3K4En((tPcTK)XVQLImF8DM8m9hnx9p2vTuLPZpDuw7FUVVDvZUw9BsLhkRDJ1FLRMDTsRLB(GAPEV8V9v4nYWPlFl1Mz(al56FbqmQB6WpIHXAqEBs2O(VLgkU7kPd1Vd0w6F7kmaYF2uTZ1Z6Ujh0dEft(cSkFMC)(YNPgqt(SY9x1McODX7GE(LupHihNiz)o(uJjeV27oJ)0QdS(yj8v7Fevuv3EAjRT6jSKmX8FZs01DTMZXAMG66gQhs)Fwt0JTR)Vz)F]] )


end
