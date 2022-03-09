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


    spec:RegisterPack( "Havoc", 20220308, [[devNXbqikHfHivLhrjIlHivvBIs6tikJcICkiQvPIeELkIzruClvuv7IIFHizyQqDmPOLHs6zQOY0quvxJsuBtff(MkkACQOkNtkKADQO08qu5Eev7dL4Fisv6GuIulKsXdLc1eLcXfrKsBKsK4JQijJKsK0jrKIwjIyMQi1nrKc7ufYpLcjnuePkSuvKONsKPsP0vLcjSvPqI(kIuzSeLSxH(RunyfhM0IH0JvPjJQld2ms(SuA0OWPvA1isv0RLcMnHBJWUP63QA4Ouhxfj1YH65cMUKRJuBhcFxfmEIsDEkvRhrvMpkA)Io2mABuIRfepI1JzL1Jp3XnAZXnAY)mB2mkv2zdrj26TbTfIsUsarjlvfXFJsSv7Ix5rBJsHNgFHOK0sql0AFVXyLQIsO0ROin9iAuIRfepI1JzL1Jp3XnAZXnAY)mpUrhLcSHB8ilFMNzuIXY5GhrJsCiCJsncq8EowQ0Eb4CSuve)njH0qXxg5CEYKdRhZkRjjjjnMH6Tq4SjjNFoKgqPepMnJpSHCuNNdPhFTVNdDqBHCi9HcupgYHABzu5aopq6lhX3U3CuoPN0Hc45uFokB2c758UWEo1Nd6hc5qTTmQGjj58Z50)haphA25eS731BZ5PYH0akL4XSz8HnKdseRNZtLd12YOYbde66HCqem5u41BaQCACJKdwlgaoNIH65qOYgztuIn(PwbeLSeljNgbiEphlvAVaCowQkI)MKyjwsoKgk(YiNZtMCy9ywznjjjXsSKCAmd1BHWztsSeljNZphsdOuIhZMXh2qoQZZH0JV23ZHoOTqoK(qbQhd5qTTmQCaNhi9LJ4B3BokN0t6qb8CQphLnBH9CExypN6Zb9dHCO2wgvWKKyjwsoNFoN()a45qZoNGD)UEBopvoKgqPepMnJpSHCqIy9CEQCO2wgvoyGqxpKdIGjNcVEdqLtJBKCWAXaW5umuphcv2iBssss0BTVhmSXW9jq1so6xLa4DkHAh4hwVTxVSxpjrV1(EWWgd3NavRtKtkekEvubiJReG8cVEdq1d29Bpi(sgeQGgK3uMLsEHxVbOmnnm0qNoaDuAkkRizrHxVbOmSAyOHoDa6O0uumzw41BakttZ9Fb)p4gonwR9DwKx41BakdRM7)c(FWnCASw77iNKO3AFpyyJH7tGQ1jYjfcfVkQaKXvcqEHxVbO6b7(TheFjdcvqdYzvMLsEHxVbOmSAyOHoDa6O0uuwrYIcVEdqzAAyOHoDa6O0uumzw41BakdRM7)c(FWnCASw77Su41BakttZ9Fb)p4gonwR9DKtsSKCAueGCiT2HCSbuIC0khXFihlfAS9CoSfJCSrSophlfAS9CuX7T5Cylg5aBXaW50ikUHwHIHCEConcq8Eo2iuoeYH2fqiKdDy92CS0TVBpNtLsEqsIER99GHngUpbQwNiNuiu8QOcqgxja50bOd2HokOeDkAS9(9D(w77YGqf0G8sfGxguX68ofn2UbCfvaCRiHPDG6XTGHR4gAfkg6eaxfI9DMmlvaEz4aX7DuHYHGbCfvaCRwGPDG6XTGrBF3EVvjpa5Ke9w77bdBmCFcuToroPOeqGXfRuLmlL8WtlqxNBythkAb0bmn7AFNjZWtlqxNBq8cTwb0dVab4vsIER99GHngUpbQwNiNuk(Qo0RhJbVssssSeljhsRSHlDb8Caea2Eo1sa5umGC0B94C2qokcDfkQamjj6T23dY5BatZUss0BTVhoroPUVhOjGoH2U3KelXsYH0b5WFNSkh(NtXyd5ukUfQCchu2SxVnN6ZrzZwyphBOX(6T5q6EANNKyjwso6T23dNiNuyOuCluDLU(UwLEBqgX6q)YL3uMsXTq1xk5eRFwoGstrzqPX(6T9dpTZnyGqxpiZsjht7a1JBbdkn2xVTF4PDU1sfGxgoq8EhvOCiyaxrfapjXsYH0TfJNUYPXm0pKJTmGhBpNhNtJO4gAfkgKjhBekhYPru)c5Cylg5yPS4qLJnI)5584C0kNZDsoiX6j5Cylg5ylwxropvoNs61roNsXTqfss0BTVhoroPqO4vrfGmUsaYrfkh6C1VGmlLClW0oq94wWCzOFOxmGhB3QfyAhOECly4kUHwHIHobWvHyFxgeQGgKxQa8YqT4q1rf)ZnGROcGZKzGnie9sXTqfmOcLdDU6xOjlYr6CNFPcWltH1v0FQoMEDd4kQa4iNKyj5q62IronMH(HCSLb8y7YKJncLd50iQFHCoWa8CkgqoO0uu5SHC4)bxMCoSfJCSuwCOYXgX)8C0khwpjhKAEsoh2Iro2I1vKZtLZPKEDKZ5X5Cylg5qAdbWVqo2GbTHC0khY)KCq6CNKZHTyKJTyDf58u5CkPxh5Ckf3cvijrV1(E4e5KcHIxfvaY4kbihvOCOZv)cYSuYX0oq94wWCzOFOxmGhBxgeQGgKJstrzUm0p0lgWJTB4)bNjZsfGxgQfhQoQ4FUbCfvaCRb2Gq0lf3cvWGkuo05QFHMSihjwp)sfGxMcRRO)uDm96gWvubWrMjtlkvaEzU2VcO)uDgAHbUbCfvaCRb2Gq0lf3cvWGkuo05QFHMSihjY)8lvaEzkSUI(t1X0RBaxrfah5Keljhs3wmYPruCdTcfdYKJncLd50iQFHC0kh)XeQiNsXTqLZ9P9kNdmaphuAkkGNdQ9C0CcW9DUITNdqrb3sMCECoQ4GApKJw5q(2Esoupoh)9ZVraI33BsIER99WjYjfcfVkQaKXvcqoQq5qNR(fKzPKJPDG6XTGHR4gAfkg6eaxfI9DzqOcAqEPcWld1Idvhv8p3aUIkaotMiHstrziGsjEmBgFydgA2mzwQa8YuyDf9NQJPx3aUIkaotMCaLMIYaHa4xOJIbTbdnBKTgydcrVuClubdQq5qNR(fAYICKo35xQa8YuyDf9NQJPx3aUIkaoYmzArPcWldhiEFVgWvubWTgydcrVuClubdQq5qNR(fAYICYpjXsYPrraYH0gcGFHCSbdAd5GcupgYXgHYHCAe1VqolvoBLZgYrrORqrfqoQZZ5POY5(VG)h8Ke9w77HtKtkekEvubiJReGCuHYHox9liZZwogcqjZsjVub4LbcbWVqhfdAdgWvubWTE)xW)dUbcbWVqhfdAdgmOC7jjwsoKUTyKJLU9D75CQuYdYrDEon2(va58u5yPQfg4YKJI4xEo0H1BZXgHYHCAe1VqohyaEofdad5SHCkgqoS)qyrxXw2ZP(CazxGZZr9CS0pPnhP1POf5ydwDEsIER99WjYjfcfVkQaKXvcqoQq5qNR(fKzPKJPDG6XTGrBF3EVvjpWAPcWlZ1(va9NQZqlmWLbHkOb5iu8QOcWGkuo05QFbR6TweqN)LjSofTOJIvNtowts0BTVhoroPqO4vrfGmUsaYz)Vy92o1J7eqPYGqf0GClkvaEz4aX771aUIkaU17)c(FWneqPepMnJpSbdgi01dK7mSsrJTB4a1E3ILZDCsIER99WjYjfcfVkQaKXvcqo7)fR32PEChvOCOZv)cYGqf0GCekEvubyqfkh6C1VGvKOOX2j3zA5ZVub4LHAXHQJk(NBaxrfa)uW6XiNKO3AFpCICsHqXRIkazCLaKZ(FX6TDQh3b7qhfuczqOcAqEPcWldhiEFVgWvubWTArPcWldQyDENIgB3aUIkaU17)c(FWnGDOJckHbde66bYHu7LBiuzFkyfzRu0y7goqT3TyH1JtsSKCiDBXihlD772Z5uPKhitoAvab7kN6Zjy3V5qATd5ydOe5OopN7)c(FWZHoOTqoupohcv2lbnroCASw77YKdTlGqihTY5C2EssIER99WjYjfcfVkQaKXvcq(bDR1B7upURTVBV3QKhiZsjht7a1JBbJ2(U9ERsEGmiubni3c(xMW6u0IokwDUP2BdR3A9(VG)hCtyDkArhfRo3GbcD9a5AVCdHk7tb5BfjlU)l4)b3qaLs8y2m(Wgm0SzYuV1Ia6GdeleK3ezRb2Gq0lf3cvWa2HokOeKt(5ss0BTVhoroPqO4vrfGmUsaYpOBTEBN6XDINa8IMqgeQGgKxQa8Yq8eGx0egWvubWTAbknfLH4jaVOjm0Sts0BTVhoroPUQq01BTV3fBOKXvcq(9Fb)p4jjwILKJER99WjYjf792qNMDNcRTeGxYu2zdY5aX7YSuY5aX79Wtl6uyTLa8kWYXjjwILKJER99WjYjf792qNMDNcRTeGxYq8CqUdkgcLmlLCKkvaEz4aX77TRSzd1wGbCfvaCRu0y7goqT3Tyr(5SmtMyAhOEClyqfRZ7u6wmSIstrzqfRZ7u6wmm0Sr2kswC)xW)dUbSdDuqjmyq52zYKIgBNCN7yKts0BTVhoroPkg4)qVvOlcqMLsoknfLHceD0NavXCcWltO0BdYTSvKqPPOmlbXl0AFVR0y1qZMjtlqPPOmeqPepMnJpSbdnBKts0BTVhoroPW0ExV1(ExSHsgxja5CG499ktOW7TK3uMLsEPcWldhiEFVgWvubWts0BTVhoroPW0ExV1(ExSHsgxja5(JjursssILKdPjvonkbVyyhNJ68CKwNIwKJny155WPXATVNZgY5ra4CoVCcW9DEiNdBXiNM2ktoSPXS)afTqypNdmwkQCinGsjEmBgFyd5SeS1BLt954FLdgOWqGroh2IroAoI)aGZHtJ1AFpNg5TnjrV1(EWC)xW)dUCcOuIhZMXh2Gmc15R325BOu)cYBESmlLClkvaEz4aX771aUIkaU17JaC1ldcWlg2XgWvubWTIPDG6XTGrBF3EVvjpWk)ltyDkArhfRo3GbcD9alNN1aBqi6LIBHkyiGsjEmBgFyd9LGTElYXQvKU)l4)b3a2HokOegmqORhyH1JzYe9dbRuBlJQJbcD9a5y1YiNKO3AFpyU)l4)b)e5KIakL4XSz8HniJqD(6TD(gk1VG8MhlZsjVub4LHdeVVxd4kQa4wVpcWvVmiaVyyhBaxrfa3kM2bQh3cgT9D79wL8aR8VmH1POfDuS6Cdgi01dSCEwdSbHOxkUfQGHakL4XSz8Hn0xc26TihRwr6(VG)hCdyh6OGsyWaHUEGfwp2Qfiu8QOcWGkuo05QFbMmV)l4)b3Gkuo05QFbdgi01dS0E5gcv2mzI(HGvQTLr1XaHUEGCSAzKtsSKCASgQCinGsjEmBgFyd5Su5CaY5Wke50cvoAou0croKw7qo2akroyGcdbg5OopNdVtwLZJaWhWBb5iTofTihBWQZZHtJ1AFpNhNZsLtXaYb87t7fGZzd5OcIpu58iaCsIER99G5(VG)h8tKtkcOuIhZMXh2GmlLClkvaEz4aX771aUIkaUvKU)l4)b3a2HokOegmqORhyH1JTIKf3hb4QxgeGxmSJnGROcGZKj)ltyDkArhfRo3GbcD9a5KFEmzgydcrVuClubdbukXJzZ4dBOVeS1BXstKzYe9dbRuBlJQJbcD9a5y1YiNKO3AFpyU)l4)b)e5KIakL4XSz8HniZsjVub4LHdeVVxd4kQa4wr6(VG)hCdyh6OGsyWaHUEGfwp2kswGqXRIkadQq5qNR(fyY8(VG)hCdQq5qNR(fmyGqxpWs7LBiuzJSvKS4(iax9YGa8IHDSbCfvaCMm5FzcRtrl6Oy15gmqORhiN8ZJjZaBqi6LIBHkyiGsjEmBgFyd9LGTElwAImtMOFiyLABzuDmqORhihRwg5Ke9w77bZ9Fb)p4NiNuS)AFxMLsoknfLHakL4XSz8HnyWaHUEGfwTmtMOFiyLABzuDmqORhi3zCCsIER99G5(VG)h8tKtk6a03ciKXvcq(vVmG(t117PMEXaVxyqd0yiiZsjhLMIYO3tn9IbExLnyOzBfj9wlcOdoqSqqohclg49sXTqfSI1L3beGxgLZdM1z5moMjt9wlcOdoqSqGfoewmW7LIBHkWKj6hcwP2wgvhde66bYXQLrojXsYPrakLwu5qhGC2ciYr8T7njrV1(EWC)xW)d(jYjvHxVbOAkZsjhHIxfvaMcVEdq1d29Bpi(sEtRiHstrziGsjEmBgFydgA2mzIKfLkaVmCG499Aaxrfa3k6hcwV)l4)b3qaLs8y2m(WgmyGqxpWcsuBlJQJbcD9a5i9w41BakttZ9Fb)p4gonwR9Ds)SImYmzI(HGvQTLr1XaHUEGCYz9yKzYejekEvubyk86navpy3V9G4l5SA1IcVEdqzy1C)xW)dUbdk3oYmzAbcfVkQamfE9gGQhS73Eq8vsIER99G5(VG)h8tKtQcVEdqXQmlLCekEvubyk86navpy3V9G4l5SAfjuAkkdbukXJzZ4dBWqZMjtKSOub4LHdeVVxd4kQa4wr)qW69Fb)p4gcOuIhZMXh2Gbde66bwqIABzuDmqORhihP3cVEdqzy1C)xW)dUHtJ1AFN0pRiJmtMOFiyLABzuDmqORhiNCwpgzMmrcHIxfvaMcVEdq1d29Bpi(sEtRwu41BakttZ9Fb)p4gmOC7iZKPfiu8QOcWu41BaQEWUF7bXxjj6T23dM7)c(FWproPcRtrl6Oy15YSuYTG)LjSofTOJIvNBQ92W6TwrYcmTdupUfmA7727Tk5bmzI09Fb)p4gWo0rbLWGbcD9a5K3E5wPOX2zr(5ogzKTIKf3)f8)GBiGsjEmBgFydgA2mzQ3AraDWbIfcYBICsIER99G5(VG)h8tKtQIb0zq7LmlLClkvaEz4aX771aUIkaUvlqO4vrfG5GU16TDQh3jEcWlAcRwGqXRIkad7)fR32PECNakLjtuAkkdfnEF6qVvjpWqZojrV1(EWC)xW)d(jYjfiShw17C4IbqMLsos6TweqhCGyHalCiSyG3lf3cvGjtSU8oGa8YOCEWSolN7yKts0BTVhm3)f8)GFICsrjGaJlwPkzwk5HNwGUo3G4fATcOhEbcWlRwGstrzq8cTwb0dVab4vNbnH6)Yn0SLz9cWyA2vFjia(QfiVPmRxagtZU6TIhvfYBkZ6fGX0SR(sjp80c015geVqRva9WlqaELKKKO3AFpy4aX77voyh6OGsiZsjht7a1JBbJ2(U9ERsEGvK0BTiGo4aXcbw4qyXaVxkUfQatMyD5Dab4Lr58GzDwy1YNFPcWlZ1(va9NQZqlmWpfnpgzR8VmH1POfDuS6CtT3gwV1k)ltyDkArhfRo3GbcD9a5K3E5jj6T23dgoq8(EproPOarhthyiZsjVub4LH2rFAN3Vm0pyaxrfa3kknfLH2rFAN3Vm0pyOzBfPldf3cb5SYKjsyD5Dab4LH4raeGxM1zP5XwX6Y7acWlJY5bZ6S08yKrojrV1(EWWbI337jYjfh0IrpCaa2YSuYrO4vrfGbvOCOZv)cjj6T23dgoq8(EproPAf6Ia6fqWgcLmlLC9wlcOdoqSqGfoewmW7LIBHkWKjwxEhqaEzuopywNLMhNKO3AFpy4aX779e5KQyG)d9wHUiazwk53350BzcagRfW7TcDragWvubWTE)xW)dUbSdDuqjmyGqxpqUZWQfO0uugcOuIhZMXh2GHMTvl4aknfLbKn7pa8(HN25gA2jj6T23dgoq8(EproPa7qhfuczwk56TweqhCGyHalCiSyG3lf3cvGjtSU8oGa8YOCEWSolSA5ZVub4L5A)kG(t1zOfg4NIMhBfjlqO4vrfGHoaDWo0rbLOtrJT3VVZ3AFNjZaBqi6LIBHkWstMmPOX2j3zEmYwTaHIxfvaMd6wR32PECxBF3EVvjpijrV1(EWWbI337jYjfQq5qNR(fKzPKJqXRIkadQq5qNR(fSAX9Fb)p4gcOuIhZMXh2Gbdk3UvKU)l4)b3a2HokOegmqORhyXYmzIewxEhqaEzuopywNL7)c(FWTI1L3beGxgLZdM1jhRwgzKts0BTVhmCG499EICsTeeVqR99UsJvzwk5wGstrzwcIxO1(ExPXQHMDsIER99GHdeVV3tKtk19LXk0AFxMLsUfiu8QOcWW(FX6TDQh3rfkh6C1VqsIER99GHdeVV3tKtkkqGkuoiZsjNIgB3WbQ9UflYj)Jts0BTVhmCG499EICsbHa4xOJIbTHKe9w77bdhiEFVNiNuxg6h6HcVnaYSuYTaHIxfvag2)lwVTt94oQq5qNR(fSAbcfVkQamS)xSEBN6XDWo0rbLijrV1(EWWbI337jYjffi6y6adzwk5LkaVmCG49oQq5qWaUIkaUvlU)l4)b3a2HokOegmOC7wr6YqXTqqoRmzIewxEhqaEziEeab4LzDwAESvSU8oGa8YOCEWSolnpgzKts0BTVhmCG499EICsXbI3dD0TazU2VcOxkUfQG8MYSuYX0oq94wWGsJ91B7hEANBLdO0uuguASVEB)Wt7Cdgi01dKJ8ts0BTVhmCG499EICsrbIoMoWqMLsUfLkaVmCG49oQq5qWaUIkaU1aBqi6LIBHkWstRiDzO4wiiNvMmrcRlVdiaVmepcGa8YSolnp2kwxEhqaEzuopywNLMhJmYjj6T23dgoq8(EproP4aX7Ho6wqsIER99GHdeVV3tKtQIb(p0Bf6IaKzPKJstrzE6Q)uDS6TGHMDsIER99GHdeVV3tKtkkq0X0bgYSuYjEeab4LHVHs9lWstlZKjknfL5PR(t1XQ3cgA2jj6T23dgoq8(EproPqaElqrl6yOWGwYSuYjEeab4LHVHs9lWstlNKO3AFpy4aX779e5KQyG)d9wHUiazwk5LkaVmCG49oQq5qWaUIkaEsssIER99GXFmHkKd2HokOeYSuYX0oq94wWOTVBV3QKhyfj9wlcOdoqSqGfoewmW7LIBHkWKjwxEhqaEzuopywNLMwgzR8VmH1POfDuS6CtT3gwV1k)ltyDkArhfRo3GbcD9a5K3E5jj6T23dg)XeQ4e5Kcb4TafTOJHcdAjZsjVub4LH4jaVOjmGROcGBfLMIYWgdSvmWn8)GBTwcGLMjj6T23dg)XeQ4e5KIceDmDGHmlLCKqPPOm0o6t78(LH(bdnBMmrO4vrfG5GU16TDQh3jEcWlAcRizrPcWldTJ(0oVFzOFWaUIkaotMwC)xW)dUzjiEHw77DLgRgmOC7iJSvKUmuCleKZktMiH1L3beGxgIhbqaEzwNLMhBfRlVdiaVmkNhmRZsZJrg5Ke9w77bJ)ycvCICsrbIoQIXAliZsjxV1Ia6GdeleyHdHfd8EP4wOcmzI1L3beGxgLZdM1z5ChNKO3AFpy8htOItKtkoOfJE4aaSLzPKJqXRIkadQq5qNR(fss0BTVhm(JjuXjYj1sq8cT237knwLzPKBbknfLzjiEHw77DLgRgA2jj6T23dg)XeQ4e5KQvOlcOxabBiuYSuYTaHIxfvaMd6wR32PECN4jaVOjSIKERfb0bhiwiWchclg49sXTqfyYeRlVdiaVmkNhmRZsZJrojrV1(EW4pMqfNiNufd8FO3k0fbiZsj)(oNEltaWyTaEVvOlcWaUIkaU17)c(FWnGDOJckHbde66bYDgwTaLMIYqaLs8y2m(Wgm0STAbhqPPOmGSz)bG3p80o3qZojrV1(EW4pMqfNiNuGDOJckHmlLClqO4vrfG5GU16TDQh3jEcWlAcRiP3AraDWbIfcSWHWIbEVuClubMmX6Y7acWlJY5bZ6S00YwrYcekEvubyOdqhSdDuqj6u0y79778T23zYmWgeIEP4wOcS0KjtkASDYDMhJSvlqO4vrfG5GU16TDQh3123T3BvYdqojrV1(EW4pMqfNiNuOcLdDU6xqMLsocfVkQamOcLdDU6xijrV1(EW4pMqfNiNuuGavOCqMLsofn2UHdu7DlwKt(hNKO3AFpy8htOItKtkiea)cDumOnKKO3AFpy8htOItKtk19LXk0AFxMLsosLkaVmCG49oQq5qWaUIkaotMwGqXRIkaZbDR1B7upUt8eGx0emzsrJTB4a1E3ICN7yMmrPPOmeqPepMnJpSbdgi01dKZYiB1cekEvubyy)Vy92o1J7OcLdDU6xijrV1(EW4pMqfNiNuxg6h6HcVnaYSuYrQub4LHdeV3rfkhcgWvubWzY0cekEvubyoOBTEBN6XDINa8IMGjtkASDdhO27wK7ChJSvlqO4vrfGH9)I1B7upUtaLA1cekEvubyy)Vy92o1J7OcLdDU6xijrV1(EW4pMqfNiNuGDOJckHmlL8sfGxguX68ofn2UbCfvaCRyD5Dab4Lr58GzDwU)l4)b3Qfiu8QOcWCq3A92o1J7A7727Tk5bjj6T23dg)XeQ4e5KIdeVh6OBbYCTFfqVuClub5nLzPKJPDG6XTGbLg7R32p80o3khqPPOmO0yF92(HN25gmqORhih5NKO3AFpy8htOItKtkoq8EOJUfKKO3AFpy8htOItKtkkq0X0bgYSuYTOub4LH4jaVOjmGROcGBfRlVdiaVmepcGa8YSolxgkUfcNIMhBTub4LHdeV3rfkhcgWvubWts0BTVhm(JjuXjYjffiqfkhKzPKt8iacWldFdL6xGLMwMjtuAkkZtx9NQJvVfm0Sts0BTVhm(JjuXjYjffi6y6adzwk5epcGa8YW3qP(fyPPLzYejuAkkZtx9NQJvVfm0STArPcWldXtaErtyaxrfah5Ke9w77bJ)ycvCICsHa8wGIw0XqHbTKzPKt8iacWldFdL6xGLMwojrV1(EW4pMqfNiNufd8FO3k0fbiZsjVub4LHdeV3rfkhcgWvubWJsiaCyFpEeRhZkRhFUJpJO0bf7R3gIsKol9P8isZJovNnNCSLbKZsW(XvoupohY8htOcYYbdNA6fd8CcpbKJsxpHwapNld1BHGjj50Rd508S5043ra4c45qgM2bQh3cgzrwo1NdzyAhOEClyKLbCfvaCYYbPMYgztsYPxhYP5zC2CA87iaCb8Cidt7a1JBbJSilN6ZHmmTdupUfmYYaUIkaoz5GutzJSjjjjH0zPpLhrAE0P6S5KJTmGCwc2pUYH6X5qghOuArrwoy4utVyGNt4jGCu66j0c45CzOElemjjNEDiNZD2CA87iaCb8Cidt7a1JBbJSilN6ZHmmTdupUfmYYaUIkaoz5GutzJSjj50Rd5CUZMtJFhbGlGNdzyAhOEClyKfz5uFoKHPDG6XTGrwgWvubWjlhTYH02OE6CqQPSr2KKC61HCi)ZMtJFhbGlGNdzyAhOEClyKfz5uFoKHPDG6XTGrwgWvubWjlhTYH02OE6CqQPSr2KKC61HCS8zZPXVJaWfWZHmmTdupUfmYISCQphYW0oq94wWild4kQa4KLJw5qABupDoi1u2iBsso96qoN5zZPXVJaWfWZHSsfGxgzrwo1NdzLkaVmYYaUIkaoz5OvoK2g1tNdsnLnYMKKtVoKZzE2CA87iaCb8Cidt7a1JBbJSilN6ZHmmTdupUfmYYaUIkaoz5GutzJSjj50Rd50S5zZPXVJaWfWZHmmTdupUfmYISCQphYW0oq94wWild4kQa4KLJw5qABupDoi1u2iBssssiDw6t5rKMhDQoBo5yldiNLG9JRCOECoKXgd3NavlYYbdNA6fd8CcpbKJsxpHwapNld1BHGjj50Rd5W6zZPXVJaWfWZHScVEdqzAAKfz5uFoKv41Bakt10ilYYbjwLnYMKKtVoKdRNnNg)ocaxaphYk86naLHvJSilN6ZHScVEdqzkwnYISCqIvzJSjj50Rd5CUZMtJFhbGlGNdzfE9gGY00ilYYP(CiRWR3auMQPrwKLdsSkBKnjjNEDiNZD2CA87iaCb8CiRWR3augwnYISCQphYk86naLPy1ilYYbjwLnYMKKtVoKd5F2CA87iaCb8Cidt7a1JBbJSilN6ZHmmTdupUfmYYaUIkaoz5GeRYgztsYPxhYXYNnNg)ocaxaphYcpTaDDUrwKLt95qw4PfORZnYYaUIkaoz5GutzJSjj50Rd5y5ZMtJFhbGlGNdzHNwGUo3ilYYP(Cil80c015gzzaxrfaNSC0khsBJ6PZbPMYgztssscPZsFkpI08Ot1zZjhBza5SeSFCLd1JZHS7)c(FWjlhmCQPxmWZj8eqokD9eAb8CUmuVfcMKKtVoKtZZMtJFhbGlGNdz3hb4QxgzzaxrfaNSCQphYUpcWvVmYISCqQPSr2KKC61HCAE2CA87iaCb8Cidt7a1JBbJSilN6ZHmmTdupUfmYYaUIkaoz5GutzJSjj50Rd5W6zZPXVJaWfWZHS7JaC1lJSmGROcGtwo1Ndz3hb4Qxgzrwoi1u2iBsso96qoSE2CA87iaCb8Cidt7a1JBbJSilN6ZHmmTdupUfmYYaUIkaoz5GutzJSjj50Rd5CUZMtJFhbGlGNdz3hb4QxgzzaxrfaNSCQphYUpcWvVmYISCqQPSr2KKC61HCi)ZMtJFhbGlGNdz3hb4QxgzzaxrfaNSCQphYUpcWvVmYISCqQPSr2KKC61HCoZZMtJFhbGlGNJ0s04Cc29sLDoK(ZP(ConTMdFrSH99CE2awRhNdsKc5CqQPSr2KKC61HCoZZMtJFhbGlGNdzfE9gGY00ilYYP(CiRWR3auMQPrwKLdsnLnYMKKtVoKZzE2CA87iaCb8CiRWR3augwnYISCQphYk86naLPy1ilYYbPMYgztsYPxhY58oBon(DeaUaEoslrJZjy3lv25q6pN6Z500Ao8fXg23Z5zdyTECoirkKZbPMYgztsYPxhY58oBon(DeaUaEoKv41BakttJSilN6ZHScVEdqzQMgzrwoi1u2iBsso96qoN3zZPXVJaWfWZHScVEdqzy1ilYYP(CiRWR3auMIvJSilhKAkBKnjjNEDiNg9zZPXVJaWfWZHmmTdupUfmYISCQphYW0oq94wWild4kQa4KLdsnLnYMKKtVoKttwpBon(DeaUaEoKfEAb66CJSilN6ZHSWtlqxNBKLbCfvaCYYbPMYgztssscPZsFkpI08Ot1zZjhBza5SeSFCLd1JZHmoq8(EjlhmCQPxmWZj8eqokD9eAb8CUmuVfcMKKtVoKtZZMtJFhbGlGNdzLkaVmYISCQphYkvaEzKLbCfvaCYYbPMYgztsYPxhYP5zZPXVJaWfWZHmmTdupUfmYISCQphYW0oq94wWild4kQa4KLdsnLnYMKKtVoKZzC2CA87iaCb8CiRub4LrwKLt95qwPcWlJSmGROcGtwoi1u2iBsso96qonj)ZMtJFhbGlGNdzyAhOEClyKfz5uFoKHPDG6XTGrwgWvubWjlhKAkBKnjjjjKMeSFCb8CSCo6T23ZrSHkyssIskDX4XrjPLOXrjXgQq02OK)ycveTnEuZOTrjWvubWJ2eLU4Ta8QrjmTdupUfmA7727Tk5bgWvubWZXAoiLJERfb0bhiwiKdl5WHWIbEVuCluHCyYmhSU8oGa8YOCEWSEoSKttlNdY5ynh(xMW6u0IokwDUP2BdR3MJ1C4FzcRtrl6Oy15gmqORhYHCYZP9YJs6T23JsGDOJckrSIhXA02Oe4kQa4rBIsx8waE1OuPcWldXtaErtyaxrfaphR5GstrzyJb2kg4g(FWZXAo1sa5WsonJs6T23JsiaVfOOfDmuyqRyfp6CrBJsGROcGhTjkDXBb4vJsiLdknfLH2rFAN3Vm0pyOzNdtM5GqXRIkaZbDR1B7upUt8eGx0e5ynhKYXICkvaEzOD0N259ld9dgWvubWZHjZCSiN7)c(FWnlbXl0AFVR0y1GbLBphKZb5CSMds5CzO4wiKJ8CynhMmZbPCW6Y7acWldXJaiaVmRNdl5084CSMdwxEhqaEzuopywphwYP5X5GCoihL0BTVhLOarhthyeR4rKF02Oe4kQa4rBIsx8waE1OKERfb0bhiwiKdl5WHWIbEVuCluHCyYmhSU8oGa8YOCEWSEoSKZ5ookP3AFpkrbIoQIXAleR4rwoABucCfva8OnrPlElaVAucHIxfvaguHYHox9leL0BTVhL4Gwm6HdaWowXJoJOTrjWvubWJ2eLU4Ta8QrjlYbLMIYSeeVqR99UsJvdn7OKER99O0sq8cT237knwJv8OZmABucCfva8OnrPlElaVAuYICqO4vrfG5GU16TDQh3jEcWlAICSMds5O3AraDWbIfc5WsoCiSyG3lf3cvihMmZbRlVdiaVmkNhmRNdl5084CqokP3AFpk1k0fb0lGGneQyfp68I2gLaxrfapAtu6I3cWRgLUVZP3YeamwlG3Bf6IamGROcGNJ1CU)l4)b3a2HokOegmqORhYHC5Cg5ynhlYbLMIYqaLs8y2m(Wgm0SZXAowKdhqPPOmGSz)bG3p80o3qZokP3AFpkvmW)HERqxeqSIh1OJ2gLaxrfapAtu6I3cWRgLSihekEvubyoOBTEBN6XDINa8IMihR5Guo6TweqhCGyHqoSKdhclg49sXTqfYHjZCW6Y7acWlJY5bZ65WsonTCowZbPCSihekEvubyOdqhSdDuqj6u0y79778T23ZHjZCcSbHOxkUfQqoSKtZCyYmhkAS9CixoN5X5GCowZXICqO4vrfG5GU16TDQh3123T3BvYdYb5OKER99Oeyh6OGseR4rnpoABucCfva8OnrPlElaVAucHIxfvaguHYHox9leL0BTVhLqfkh6C1VqSIh1Sz02Oe4kQa4rBIsx8waE1Oefn2UHdu7DRCyrEoK)Xrj9w77rjkqGkuoeR4rnznABusV1(EuccbWVqhfdAdrjWvubWJ2eR4rnpx02Oe4kQa4rBIsx8waE1Oes5uQa8YWbI37OcLdbd4kQa45WKzowKdcfVkQamh0TwVTt94oXtaErtKdtM5qrJTB4a1E3khYLZ5oohMmZbLMIYqaLs8y2m(WgmyGqxpKd5YXY5GCowZXICqO4vrfGH9)I1B7upUJkuo05QFHOKER99OK6(YyfATVhR4rnj)OTrjWvubWJ2eLU4Ta8QrjKYPub4LHdeV3rfkhcgWvubWZHjZCSihekEvubyoOBTEBN6XDINa8IMihMmZHIgB3WbQ9UvoKlNZDCoiNJ1CSihekEvubyy)Vy92o1J7eqP5ynhlYbHIxfvag2)lwVTt94oQq5qNR(fIs6T23Jsxg6h6HcVnaXkEutlhTnkbUIkaE0MO0fVfGxnkvQa8YGkwN3POX2nGROcGNJ1CW6Y7acWlJY5bZ65Wso6T2373)f8)GNJ1CSihekEvubyoOBTEBN6XDT9D79wL8GOKER99Oeyh6OGseR4rnpJOTrjWvubWJ2eL0BTVhL4aX7Ho6wqu6I3cWRgLW0oq94wWGsJ91B7hEANBaxrfaphR5WbuAkkdkn2xVTF4PDUbde66HCixoKFu6A)kGEP4wOcXJAgR4rnpZOTrj9w77rjoq8EOJUfeLaxrfapAtSIh188I2gLaxrfapAtu6I3cWRgLSiNsfGxgINa8IMWaUIkaEowZbRlVdiaVmepcGa8YSEoSKZLHIBHqoNICAECowZPub4LHdeV3rfkhcgWvubWJs6T23JsuGOJPdmIv8OMn6OTrjWvubWJ2eLU4Ta8QrjIhbqaEz4BOu)c5WsonTComzMdknfL5PR(t1XQ3cgA2rj9w77rjkqGkuoeR4rSEC02Oe4kQa4rBIsx8waE1OeXJaiaVm8nuQFHCyjNMwohMmZbPCqPPOmpD1FQow9wWqZohR5yroLkaVmepb4fnHbCfva8CqokP3AFpkrbIoMoWiwXJyTz02Oe4kQa4rBIsx8waE1OeXJaiaVm8nuQFHCyjNMwokP3AFpkHa8wGIw0XqHbTIv8iwznABucCfva8OnrPlElaVAuQub4LHdeV3rfkhcgWvubWJs6T23Jsfd8FO3k0fbeRyfL4aLslQOTXJAgTnkP3AFpkX3aMMDfLaxrfapAtSIhXA02OKER99O099anb0j029gLaxrfapAtSIhDUOTrjWvubWJ2eLE2rPaurj9w77rjekEvubeLqO4URequcvOCOZv)crPlElaVAuYICW0oq94wWCzOFOxmGhB3aUIkaEowZXICW0oq94wWWvCdTcfdDcGRcX(UbCfva8Oehcx8YU23JsKUTy80vonMH(HCSLb8y7584CAef3qRqXGm5yJq5qonI6xiNdBXihlLfhQCSr8ppNhNJw5CUtYbjwpjNdBXihBX6kY5PY5usVoY5ukUfQqucHkOHOuPcWld1Idvhv8p3aUIkaEomzMtGnie9sXTqfmOcLdDU6xOzoSiphKY5C5C(5uQa8YuyDf9NQJPx3aUIkaEoihR4rKF02Oe4kQa4rBIsp7OuaQOKER99OecfVkQaIsiuC3vcikHkuo05QFHO0fVfGxnkHPDG6XTG5Yq)qVyap2UbCfva8Oehcx8YU23JsKUTyKtJzOFihBzap2Um5yJq5qonI6xiNdmapNIbKdknfvoBih(FWLjNdBXihlLfhQCSr8pphTYH1tYbPMNKZHTyKJTyDf58u5CkPxh5CECoh2IroK2qa8lKJnyqBihTYH8pjhKo3j5Cylg5ylwxropvoNs61roNsXTqfIsiubneLqPPOmxg6h6fd4X2n8)GNdtM5uQa8YqT4q1rf)ZnGROcGNJ1CcSbHOxkUfQGbvOCOZv)cnZHf55GuoSMZ5NtPcWltH1v0FQoMEDd4kQa45GComzMJf5uQa8YCTFfq)P6m0cdCd4kQa45ynNaBqi6LIBHkyqfkh6C1VqZCyrEoiLd5NZ5NtPcWltH1v0FQoMEDd4kQa45GCSIhz5OTrjWvubWJ2eLE2rPaurj9w77rjekEvubeLqO4URequcvOCOZv)crPlElaVAuct7a1JBbdxXn0kum0jaUke77gWvubWJsCiCXl7AFpkr62IronIIBOvOyqMCSrOCiNgr9lKJw54pMqf5ukUfQCUpTx5CGb45Gstrb8CqTNJMtaUVZvS9Cakk4wYKZJZrfhu7HC0khY32tYH6X54VF(ncq8(EJsiubneLkvaEzOwCO6OI)5gWvubWZHjZCqkhuAkkdbukXJzZ4dBWqZohMmZPub4LPW6k6pvhtVUbCfva8CyYmhoGstrzGqa8l0rXG2GHMDoiNJ1CcSbHOxkUfQGbvOCOZv)cnZHf55GuoNlNZpNsfGxMcRRO)uDm96gWvubWZb5CyYmhlYPub4LHdeVVxd4kQa45ynNaBqi6LIBHkyqfkh6C1VqZCyrEoKFSIhDgrBJsGROcGhTjk9SJsyiavusV1(EucHIxfvarjekU7kbeLqfkh6C1Vqu6I3cWRgLkvaEzGqa8l0rXG2GbCfva8CSMZ9Fb)p4giea)cDumOnyWGYThL4q4Ix21(EuQrraYH0gcGFHCSbdAd5GcupgYXgHYHCAe1VqolvoBLZgYrrORqrfqoQZZ5POY5(VG)h8yfp6mJ2gLaxrfapAtu6zhLcqfL0BTVhLqO4vrfqucHI7UsarjuHYHox9leLU4Ta8QrjmTdupUfmA7727Tk5bgWvubWZXAoLkaVmx7xb0FQodTWa3aUIkaEuIdHlEzx77rjs3wmYXs3(U9Covk5b5OopNgB)kGCEQCSu1cdCzYrr8lph6W6T5yJq5qonI6xiNdmapNIbGHC2qofdih2FiSORyl75uFoGSlW55OEow6N0MJ06u0ICSbRopkHqf0qucHIxfvaguHYHox9lKJ1C0BTiGo)ltyDkArhfRophYLdRXkE05fTnkbUIkaE0MO0ZokfGkkP3AFpkHqXRIkGOecvqdrjlYPub4LHdeVVxd4kQa45ynN7)c(FWneqPepMnJpSbdgi01d5qUCoJCSMdfn2UHdu7DRCyjNZDCucHI7Usarj2)lwVTt94obuASIh1OJ2gLaxrfapAtu6zhLcqfL0BTVhLqO4vrfqucHkOHOecfVkQamOcLdDU6xihR5Guou0y75qUCotlNZ5NtPcWld1Idvhv8p3aUIkaEoNICy94CqokHqXDxjGOe7)fR32PEChvOCOZv)cXkEuZJJ2gLaxrfapAtu6zhLcqfL0BTVhLqO4vrfqucHkOHOuPcWldhiEFVgWvubWZXAowKtPcWldQyDENIgB3aUIkaEowZ5(VG)hCdyh6OGsyWaHUEihYLds50E5gcv25CkYH1CqohR5qrJTB4a1E3khwYH1JJsiuC3vcikX(FX6TDQh3b7qhfuIyfpQzZOTrjWvubWJ2eLE2rPaurj9w77rjekEvubeLqO4URequ6GU16TDQh3123T3BvYdIsx8waE1OeM2bQh3cgT9D79wL8ad4kQa4rjoeU4LDTVhLiDBXihlD772Z5uPKhitoAvab7kN6Zjy3V5qATd5ydOe5OopN7)c(FWZHoOTqoupohcv2lbnroCASw77YKdTlGqihTY5C2EsucHkOHOKf5W)YewNIw0rXQZn1EBy92CSMZ9Fb)p4MW6u0IokwDUbde66HCixoTxUHqLDoNICi)CSMds5yro3)f8)GBiGsjEmBgFydgA25WKzo6TweqhCGyHqoYZPzoiNJ1CcSbHOxkUfQGbSdDuqjYHCYZ5CXkEutwJ2gLaxrfapAtu6zhLcqfL0BTVhLqO4vrfqucHkOHOuPcWldXtaErtyaxrfaphR5yroO0uugINa8IMWqZokHqXDxjGO0bDR1B7upUt8eGx0eXkEuZZfTnkbUIkaE0MOKER99O0vfIUER99UydvusSHQ7kbeLU)l4)bpwXJAs(rBJsGROcGhTjkDXBb4vJsO0uugkq0rFcufZjaVmHsVnKJ8CSCowZbPCqPPOmlbXl0AFVR0y1qZohMmZXICqPPOmeqPepMnJpSbdn7CqokP3AFpkvmW)HERqxeqSIh10YrBJsGROcGhTjkDXBb4vJsLkaVmCG499Aaxrfapkfk8ER4rnJs6T23JsyAVR3AFVl2qfLeBO6Usarjoq8(EJv8OMNr02Oe4kQa4rBIs6T23JsyAVR3AFVl2qfLeBO6Usarj)XeQiwXkkXbI33B024rnJ2gLaxrfapAtu6I3cWRgLW0oq94wWOTVBV3QKhyaxrfaphR5Guo6TweqhCGyHqoSKdhclg49sXTqfYHjZCW6Y7acWlJY5bZ65WsoSA5Co)CkvaEzU2VcO)uDgAHbUbCfva8Cof5084CqohR5W)YewNIw0rXQZn1EBy92CSMd)ltyDkArhfRo3GbcD9qoKtEoTxEusV1(EucSdDuqjIv8iwJ2gLaxrfapAtu6I3cWRgLkvaEzOD0N259ld9dgWvubWZXAoO0uugAh9PDE)Yq)GHMDowZbPCUmuCleYrEoSMdtM5GuoyD5Dab4LH4raeGxM1ZHLCAECowZbRlVdiaVmkNhmRNdl5084CqohKJs6T23JsuGOJPdmIv8OZfTnkbUIkaE0MO0fVfGxnkHqXRIkadQq5qNR(fIs6T23JsCqlg9WbayhR4rKF02Oe4kQa4rBIsx8waE1OKERfb0bhiwiKdl5WHWIbEVuCluHCyYmhSU8oGa8YOCEWSEoSKtZJJs6T23JsTcDra9ciydHkwXJSC02Oe4kQa4rBIsx8waE1O09Do9wMaGXAb8ERqxeGbCfva8CSMZ9Fb)p4gWo0rbLWGbcD9qoKlNZihR5yroO0uugcOuIhZMXh2GHMDowZXIC4aknfLbKn7pa8(HN25gA2rj9w77rPIb(p0Bf6IaIv8OZiABucCfva8OnrPlElaVAusV1Ia6GdeleYHLC4qyXaVxkUfQqomzMdwxEhqaEzuopywphwYHvlNZ5NtPcWlZ1(va9NQZqlmWnGROcGNZPiNMhNJ1CqkhlYbHIxfvag6a0b7qhfuIofn2E)(oFR99CyYmNaBqi6LIBHkKdl50mhMmZHIgBphYLZzECoiNJ1CSihekEvubyoOBTEBN6XDT9D79wL8GOKER99Oeyh6OGseR4rNz02Oe4kQa4rBIsx8waE1OecfVkQamOcLdDU6xihR5yro3)f8)GBiGsjEmBgFydgmOC75ynhKY5(VG)hCdyh6OGsyWaHUEihwYXY5WKzoiLdwxEhqaEzuopywphwYrV1(E)(VG)h8CSMdwxEhqaEzuopywphYLdRwohKZb5OKER99OeQq5qNR(fIv8OZlABucCfva8OnrPlElaVAuYICqPPOmlbXl0AFVR0y1qZokP3AFpkTeeVqR99UsJ1yfpQrhTnkbUIkaE0MO0fVfGxnkzroiu8QOcWW(FX6TDQh3rfkh6C1VqusV1(EusDFzScT23Jv8OMhhTnkbUIkaE0MO0fVfGxnkrrJTB4a1E3khwKNd5FCusV1(EuIceOcLdXkEuZMrBJs6T23Jsqia(f6OyqBikbUIkaE0MyfpQjRrBJsGROcGhTjkDXBb4vJswKdcfVkQamS)xSEBN6XDuHYHox9lKJ1CSihekEvubyy)Vy92o1J7GDOJckrusV1(Eu6Yq)qpu4TbiwXJAEUOTrjWvubWJ2eLU4Ta8QrPsfGxgoq8EhvOCiyaxrfaphR5yro3)f8)GBa7qhfucdguU9CSMds5CzO4wiKJ8CynhMmZbPCW6Y7acWldXJaiaVmRNdl5084CSMdwxEhqaEzuopywphwYP5X5GCoihL0BTVhLOarhthyeR4rnj)OTrjWvubWJ2eL0BTVhL4aX7Ho6wqu6I3cWRgLW0oq94wWGsJ91B7hEANBaxrfaphR5WbuAkkdkn2xVTF4PDUbde66HCixoKFu6A)kGEP4wOcXJAgR4rnTC02Oe4kQa4rBIsx8waE1OKf5uQa8YWbI37OcLdbd4kQa45ynNaBqi6LIBHkKdl50mhR5GuoxgkUfc5iphwZHjZCqkhSU8oGa8Yq8iacWlZ65WsonpohR5G1L3beGxgLZdM1ZHLCAECoiNdYrj9w77rjkq0X0bgXkEuZZiABusV1(EuIdeVh6OBbrjWvubWJ2eR4rnpZOTrjWvubWJ2eLU4Ta8QrjuAkkZtx9NQJvVfm0SJs6T23Jsfd8FO3k0fbeR4rnpVOTrjWvubWJ2eLU4Ta8QrjIhbqaEz4BOu)c5WsonTComzMdknfL5PR(t1XQ3cgA2rj9w77rjkq0X0bgXkEuZgD02Oe4kQa4rBIsx8waE1OeXJaiaVm8nuQFHCyjNMwokP3AFpkHa8wGIw0XqHbTIv8iwpoABucCfva8OnrPlElaVAuQub4LHdeV3rfkhcgWvubWJs6T23Jsfd8FO3k0fbeRyfLU)l4)bpAB8OMrBJsGROcGhTjkDXBb4vJswKtPcWldhiEFVgWvubWZXAo3hb4QxgeGxmSJZXAoyAhOECly023T3BvYdmGROcGNJ1C4FzcRtrl6Oy15gmqORhYHLCoVCSMtGnie9sXTqfmeqPepMnJpSH(sWwVvoKlhwZXAoiLZ9Fb)p4gWo0rbLWGbcD9qoSKdRhNdtM5G(HqowZHABzuDmqORhYHC5WQLZb5OKqD(6TD(gk1VquQ5Xrj9w77rjcOuIhZMXh2quIdHlEzx77rjstQCAucEXWooh155iTofTihBWQZZHtJ1AFpNnKZJaW5CE5eG778qoh2IronTvMCytJz)bkAHWEohySuu5qAaLs8y2m(WgYzjyR3kN6ZX)khmqHHaJCoSfJC0Ce)baNdNgR1(EonYBBSIhXA02Oe4kQa4rBIsx8waE1OuPcWldhiEFVgWvubWZXAo3hb4QxgeGxmSJZXAoyAhOECly023T3BvYdmGROcGNJ1C4FzcRtrl6Oy15gmqORhYHLCoVCSMtGnie9sXTqfmeqPepMnJpSH(sWwVvoKlhwZXAoiLZ9Fb)p4gWo0rbLWGbcD9qoSKdRhNJ1CSihekEvubyqfkh6C1VqomzMZ9Fb)p4guHYHox9lyWaHUEihwYP9YneQSZHjZCq)qihR5qTTmQogi01d5qUCy1Y5GCusV1(EuIakL4XSz8HneLeQZxVTZ3qP(fIsnpowXJox02Oe4kQa4rBIs6T23JseqPepMnJpSHOehcx8YU23JsnwdvoKgqPepMnJpSHCwQCoa5CyfICAHkhnhkAHihsRDihBaLihmqHHaJCuNNZH3jRY5ra4d4TGCKwNIwKJny155WPXATVNZJZzPYPya5a(9P9cW5SHCubXhQCEeaokDXBb4vJswKtPcWldhiEFVgWvubWZXAoiLZ9Fb)p4gWo0rbLWGbcD9qoSKdRhNJ1CqkhlY5(iax9YGa8IHDComzMd)ltyDkArhfRo3GbcD9qoKtEoNxomzMtGnie9sXTqfmeqPepMnJpSH(sWwVvoSKtZCqohMmZb9dHCSMd12YO6yGqxpKd5YHvlNdYXkEe5hTnkbUIkaE0MO0fVfGxnkvQa8YWbI33RbCfva8CSMds5C)xW)dUbSdDuqjmyGqxpKdl5W6X5ynhKYXICqO4vrfGbvOCOZv)c5WKzo3)f8)GBqfkh6C1VGbde66HCyjN2l3qOYohKZXAoiLJf5CFeGREzqaEXWoohMmZH)LjSofTOJIvNBWaHUEihYjpNZlhMmZjWgeIEP4wOcgcOuIhZMXh2qFjyR3khwYPzoiNdtM5G(HqowZHABzuDmqORhYHC5WQLZb5OKER99OebukXJzZ4dBiwXJSC02Oe4kQa4rBIsx8waE1OeknfLHakL4XSz8HnyWaHUEihwYHvlNdtM5G(HqowZHABzuDmqORhYHC5CghhL0BTVhLy)1(ESIhDgrBJsGROcGhTjkP3AFpkD1ldO)uD9EQPxmW7fg0angcrPlElaVAucLMIYO3tn9IbExLnyOzNJ1Cqkh9wlcOdoqSqih55WHWIbEVuCluHCSMdwxEhqaEzuopywphwY5moohMmZrV1Ia6GdeleYHLC4qyXaVxkUfQqomzMd6hc5ynhQTLr1XaHUEihYLdRwohKJsUsarPREza9NQR3tn9IbEVWGgOXqiwXJoZOTrjWvubWJ2eL0BTVhLk86navZOehcx8YU23JsncqP0Ikh6aKZwaroIVDVrPlElaVAucHIxfvaMcVEdq1d29Bpi(kh550mhR5GuoO0uugcOuIhZMXh2GHMDomzMds5yroLkaVmCG499AaxrfaphR5G(HqowZ5(VG)hCdbukXJzZ4dBWGbcD9qoSKds5qTTmQogi01d5qosV5u41Bakt10C)xW)dUHtJ1AFphsLdR5GCoiNdtM5G(HqowZHABzuDmqORhYHCYZH1JZb5CyYmhKYbHIxfvaMcVEdq1d29Bpi(kh55WAowZXICk86naLPy1C)xW)dUbdk3EoiNdtM5yroiu8QOcWu41BaQEWUF7bXxXkE05fTnkbUIkaE0MO0fVfGxnkHqXRIkatHxVbO6b7(TheFLJ8CynhR5GuoO0uugcOuIhZMXh2GHMDomzMds5yroLkaVmCG499AaxrfaphR5G(HqowZ5(VG)hCdbukXJzZ4dBWGbcD9qoSKds5qTTmQogi01d5qosV5u41BaktXQ5(VG)hCdNgR1(EoKkhwZb5CqohMmZb9dHCSMd12YO6yGqxpKd5KNdRhNdY5WKzoiLdcfVkQamfE9gGQhS73Eq8voYZPzowZXICk86naLPAAU)l4)b3GbLBphKZHjZCSihekEvubyk86navpy3V9G4ROKER99OuHxVbOynwXJA0rBJsGROcGhTjkDXBb4vJswKd)ltyDkArhfRo3u7TH1BZXAoiLJf5GPDG6XTGrBF3EVvjpWaUIkaEomzMds5C)xW)dUbSdDuqjmyGqxpKd5KNt7LNJ1COOX2ZHf55CUJZb5CqohR5GuowKZ9Fb)p4gcOuIhZMXh2GHMDomzMJERfb0bhiwiKJ8CAMdYrj9w77rPW6u0IokwDESIh184OTrjWvubWJ2eLU4Ta8QrjlYPub4LHdeVVxd4kQa45ynhlYbHIxfvaMd6wR32PECN4jaVOjYXAowKdcfVkQamS)xSEBN6XDcO0CyYmhuAkkdfnEF6qVvjpWqZokP3AFpkvmGodAVIv8OMnJ2gLaxrfapAtu6I3cWRgLqkh9wlcOdoqSqihwYHdHfd8EP4wOc5WKzoyD5Dab4Lr58Gz9CyjNZDCoihL0BTVhLaH9WQENdxmaXkEutwJ2gLaxrfapAtu6I3cWRgLcpTaDDUbXl0Afqp8ceGxgWvubWZXAowKdknfLbXl0Afqp8ceGxDg0eQ)l3qZokTEbymn7QVurPWtlqxNBq8cTwb0dVab4vuA9cWyA2vFjia(QfeLAgL0BTVhLOeqGXfRuvuA9cWyA2vVv8OQik1mwXkkXgd3NavROTXJAgTnkP3AFpkH(vjaENsO2b(H1B71l71JsGROcGhTjwXJynABucCfva8OnrPNDukavusV1(EucHIxfvarjeQGgIsnJsx8waE1OuHxVbOmvtddn0PdqhLMIkhR5GuowKtHxVbOmfRggAOthGoknfvomzMtHxVbOmvtZ9Fb)p4gonwR99CyrEofE9gGYuSAU)l4)b3WPXATVNdYrjekU7kbeLk86navpy3V9G4Ryfp6CrBJsGROcGhTjk9SJsbOIs6T23Jsiu8QOcikHqf0quI1O0fVfGxnkv41BaktXQHHg60bOJstrLJ1CqkhlYPWR3auMQPHHg60bOJstrLdtM5u41BaktXQ5(VG)hCdNgR1(EoSKtHxVbOmvtZ9Fb)p4gonwR99CqokHqXDxjGOuHxVbO6b7(TheFfR4rKF02Oe4kQa4rBIsp7OuaQOKER99OecfVkQaIsiubneLkvaEzqfRZ7u0y7gWvubWZXAoiLdM2bQh3cgUIBOvOyOtaCvi23nGROcGNdtM5uQa8YWbI37OcLdbd4kQa45ynhlYbt7a1JBbJ2(U9ERsEGbCfva8CqokXHWfVSR99OuJIaKdP1oKJnGsKJw5i(d5yPqJTNZHTyKJnI155yPqJTNJkEVnNdBXihylgaoNgrXn0kumKZJZPraI3ZXgHYHqo0UacHCOdR3MJLU9D75CQuYdIsiuC3vcikrhGoyh6OGs0POX27335BTVhR4rwoABucCfva8OnrPlElaVAuk80c015g20HIwaDatZU23nGROcGNdtM5eEAb66CdIxO1kGE4fiaVmGROcGhL0BTVhLOeqGXfRuvSIhDgrBJs6T23Jsk(Qo0RhJbVIsGROcGhTjwXkwXkwXi]] )


end
