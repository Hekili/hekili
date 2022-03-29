-- DruidGuardian.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [x] savage_combatant
-- [ ] unchecked_aggression

-- Guardian Endurance
-- [-] layered_mane
-- [x] wellhoned_instincts


if UnitClassBase( "player" ) == "DRUID" then
    local spec = Hekili:NewSpecialization( 104 )

    spec:RegisterResource( Enum.PowerType.Rage, {
        oakhearts_puny_quods = {
            aura = "oakhearts_puny_quods",

            last = function ()
                local app = state.buff.oakhearts_puny_quods.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 10
        },

        raging_frenzy = {
            aura = "frenzied_regeneration",
            pvptalent = "raging_frenzy",

            last = function ()
                local app = state.buff.frenzied_regeneration.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 10 -- tooltip says 60, meaning this would be 20, but NOPE.
        },

        thrash_bear = {
            aura = "thrash_bear",
            talent = "blood_frenzy",
            debuff = true,

            last = function ()
                return state.debuff.thrash_bear.applied + floor( ( state.query_time - state.debuff.thrash_bear.applied ) / class.auras.thrash_bear.tick_time ) * class.auras.thrash_bear.tick_time
            end,

            interval = function () return class.auras.thrash_bear.tick_time end,
            value = function () return 2 * state.active_dot.thrash_bear end,
        }
    } )

    spec:RegisterResource( Enum.PowerType.LunarPower )
    spec:RegisterResource( Enum.PowerType.Mana )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Energy )


    -- Talents
    spec:RegisterTalents( {
        brambles = 22419, -- 203953
        blood_frenzy = 22418, -- 203962
        bristling_fur = 22420, -- 155835

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        balance_affinity = 22163, -- 197488
        feral_affinity = 22156, -- 202155
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        heart_of_the_wild = 18577, -- 319454

        soul_of_the_forest = 21709, -- 158477
        galactic_guardian = 21707, -- 203964
        incarnation = 22388, -- 102558

        earthwarden = 22423, -- 203974
        survival_of_the_fittest = 21713, -- 203965
        guardian_of_elune = 22390, -- 155578

        rend_and_tear = 22426, -- 204053
        lunar_beam = 22427, -- 204066
        pulverize = 22425, -- 80313
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( {
        alpha_challenge = 842, -- 207017
        charging_bash = 194, -- 228431
        demoralizing_roar = 52, -- 201664
        den_mother = 51, -- 236180
        emerald_slumber = 197, -- 329042
        entangling_claws = 195, -- 202226
        freedom_of_the_herd = 3750, -- 213200
        grove_protection = 5410, -- 354654
        malornes_swiftness = 1237, -- 236147
        master_shapeshifter = 49, -- 236144
        overrun = 196, -- 202246
        raging_frenzy = 192, -- 236153
        sharpened_claws = 193, -- 202110
        toughness = 50, -- 201259
    } )


    local mod_circle_hot = setfenv( function( x )
        return legendary.circle_of_life_and_death.enabled and ( 0.85 * x ) or x
    end, state )

    local mod_circle_dot = setfenv( function( x )
        return legendary.circle_of_life_and_death.enabled and ( 0.75 * x ) or x
    end, state )


    -- Auras
    spec:RegisterAuras( {
        aquatic_form = {
            id = 276012,
            duration = 3600,
            max_stack = 1,
        },
        astral_influence = {
            id = 197524,
        },
        barkskin = {
            id = 22812,
            duration = 12,
            max_stack = 1,
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        berserk = {
            id = 50334,
            duration = 15,
            max_stack = 1,
        },
        -- Alias for Berserk vs. Incarnation
        berserk_bear = {
            alias = { "berserk", "incarnation" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return talent.incarnation.enabled and 30 or 15 end,
        },
        bristling_fur = {
            id = 155835,
            duration = 8,
            max_stack = 1,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        convoke_the_spirits = {
            id = 323764,
            duration = 4,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
            max_stack = 1,
        },
        earthwarden = {
            id = 203975,
            duration = 3600,
            max_stack = 3,
        },
        entangling_roots = {
            id = 339,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        feline_swiftness = {
            id = 131768,
        },
        flight_form = {
            id = 276029,
            duration = 3600,
            max_stack = 1,
        },
        frenzied_regeneration = {
            id = 22842,
            duration = 3,
            max_stack = 1,
        },
        galactic_guardian = {
            id = 213708,
            duration = 15,
            max_stack = 1,
        },
        gore = {
            id = 93622,
            duration = 10,
            max_stack = 1,
        },
        growl = {
            id = 6795,
            duration = 3,
            max_stack = 1,
        },
        guardian_of_elune = {
            id = 213680,
            duration = 15,
            max_stack = 1,
        },
        heart_of_the_wild = {
            id = 319454,
            duration = 45,
            max_stack = 1,
            copy = { 319451, 319452, 319453 }
        },
        hibernate = {
            id = 2637,
            duration = 40,
            max_stack = 1,
        },
        immobilized = {
            id = 45334,
            duration = 4,
            max_stack = 1,
        },
        incapacitating_roar = {
            id = 99,
            duration = 3,
            max_stack = 1,
        },
        incarnation = {
            id = 102558,
            duration = 30,
            max_stack = 1,
            copy = "incarnation_guardian_of_ursoc"
        },
        intimidating_roar = {
            id = 236748,
            duration = 3,
            max_stack = 1,
        },
        ironfur = {
            id = 192081,
            duration = function () return buff.guardian_of_elune.up and 9 or 7 end,
            max_stack = 5,
        },
        lightning_reflexes = {
            id = 231065,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        mighty_bash = {
            id = 5211,
            duration = 4,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = function () return mod_circle_dot( 16 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonkin_form = {
            id = 197625,
            duration = 3600,
            max_stack = 1,
        },
        prowl = {
            id = 5215,
            duration = 3600,
            max_stack = 1,
        },
        pulverize = {
            id = 80313,
            duration = 10,
            max_stack = 1,
        },
        --[[ rake = {
            id = 155722,
            duration = 15,
            max_stack = 1,
        }, ]]
        regrowth = {
            id = 8936,
            duration = function () return mod_circle_hot( 12 ) end,
            type = "Magic",
            max_stack = 1,
        },
        rejuvenation = {
            id = 774,
            duration = function () return mod_circle_hot( 15 ) end,
            tick_time = function () return mod_circle_hot( 3 ) * haste end,
            max_stack = 1,
        },
        soulshape = {
            id = 310143,
            duration = 3600,
            max_stack = 1,
        },
        stampeding_roar = {
            id = 77761,
            duration = 8,
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = function () return mod_circle_dot( 12 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            max_stack = 1,
            type = "Magic",
        },
        survival_instincts = {
            id = 61336,
            duration = 6,
            max_stack = 1,
        },
        thick_hide = {
            id = 16931,
        },
        thrash_bear = {
            id = 192090,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function () return mod_circle_dot( 3 ) * haste end,
            max_stack = function () return legendary.luffainfused_embrace and 4 or 3 end,
        },
        --[[ thrash_cat = {
            id = 106830,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function () return mod_circle_dot( 3 ) * haste end,
            max_stack = 1,
        }, ]]
        tiger_dash = {
            id = 252216,
            duration = 5,
            max_stack = 1,
        },
        tooth_and_claw = {
            id = 135286,
            duration = 15,
            max_stack = 2
        },
        travel_form = {
            id = 783,
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            max_stack = 1,
            type = "Magic",
        },
        ursols_vortex = {
            id = 127797,
            duration = 3600,
            max_stack = 1,
        },
        wild_charge = {
            id = 102401,
            duration = 0.5,
            max_stack = 1,
        },
        wild_growth = {
            id = 48438,
            duration = 7,
            max_stack = 1,
        },
        yseras_gift = {
            id = 145108,
        },


        any_form = {
            alias = { "bear_form", "cat_form", "moonkin_form" },
            duration = 3600,
            aliasMode = "first",
            aliasType = "buff",
        },


        -- PvP Talents
        demoralizing_roar = {
            id = 201664,
            duration = 8,
            max_stack = 1,
        },

        den_mother = {
            id = 236181,
            duration = 3600,
            max_stack = 1,
        },

        focused_assault = {
            id = 206891,
            duration = 6,
            max_stack = 1,
        },

        grove_protection_defense = {
            id = 354704,
            duration = 12,
            max_stack = 1,
        },

        grove_protection_offense = {
            id = 354789,
            duration = 12,
            max_stack = 1,
        },

        master_shapeshifter_feral = {
            id = 236188,
            duration = 3600,
            max_stack = 1,
        },

        overrun = {
            id = 202244,
            duration = 3,
            max_stack = 1,
        },

        protector_of_the_pack = {
            id = 201940,
            duration = 3600,
            max_stack = 1,
        },

        sharpened_claws = {
            id = 279943,
            duration = 6,
            max_stack = 1,
        },

        -- Azerite
        masterful_instincts = {
            id = 273349,
            duration = 30,
            max_stack = 1,
        },

        -- Legendary
        lycaras_fleeting_glimpse = {
            id = 340060,
            duration = 5,
            max_stack = 1
        },
        ursocs_fury_remembered = {
            id = 345048,
            duration = 15,
            max_stack = 1,
        },
    } )


    Hekili:EmbedAdaptiveSwarm( spec )

    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
        if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )

        if legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent.restoration_affinity.enabled then
            applyBuff( "heart_of_the_wild" )
            applyDebuff( "player", "oath_of_the_elder_druid_icd" )
        end
    end )


    local affinities = {
        bear_form = "guardian_affinity",
        cat_form = "feral_affinity",
        moonkin_form = "balance_affinity",
    }

    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        applyBuff( form )

        if affinities[ form ] and legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent[ affinities[ form ] ].enabled then
            applyBuff( "heart_of_the_wild" )
            applyDebuff( "player", "oath_of_the_elder_druid_icd" )
        end
    end )

    spec:RegisterStateExpr( "ironfur_damage_threshold", function ()
        return ( settings.ironfur_damage_threshold or 0 ) / 100 * ( health.max )
    end )


    -- Gear.
    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364362, "tier28_4pc", 363496 )
    -- 2-Set - Architect's Design - Casting Barkskin causes you to Berserk for 4 sec.
    -- 4-Set - Architect's Aligner - While Berserked, you radiate (45%26.6% of Attack power) Cosmic damage to nearby enemies and heal yourself for (61%39.7% of Attack power) every 1 sec.
    spec:RegisterAuras( {
        architects_aligner = {
            id = 363793,
            duration = function () return talent.incarnation.enabled and 30 or 15 end,
            max_stack = 1,
        },
        architects_aligner_heal = {
            id = 363789,
            duration = function () return talent.incarnation.enabled and 30 or 15 end,
            max_stack = 1,
        }
    } )

    spec:RegisterGear( "class", 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )
    spec:RegisterGear( "tier19", 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( "tier20", 147136, 147138, 147134, 147133, 147135, 147137 ) -- Bonuses NYI
    spec:RegisterGear( "tier21", 152127, 152129, 152125, 152124, 152126, 152128 )

    spec:RegisterGear( "ailuro_pouncers", 137024 )
    spec:RegisterGear( "behemoth_headdress", 151801 )
    spec:RegisterGear( "chatoyant_signet", 137040 )
    spec:RegisterGear( "dual_determination", 137041 )
    spec:RegisterGear( "ekowraith_creator_of_worlds", 137015 )
    spec:RegisterGear( "elizes_everlasting_encasement", 137067 )
    spec:RegisterGear( "fiery_red_maimers", 144354 )
    spec:RegisterGear( "lady_and_the_child", 144295 )
    spec:RegisterGear( "luffa_wrappings", 137056 )
    spec:RegisterGear( "oakhearts_puny_quods", 144432 )
        spec:RegisterAura( "oakhearts_puny_quods", {
            id = 236479,
            duration = 3,
            max_stack = 1,
        } )
    spec:RegisterGear( "skysecs_hold", 137025 )
        spec:RegisterAura( "skysecs_hold", {
            id = 208218,
            duration = 3,
            max_stack = 1,
        } )

    spec:RegisterGear( "the_wildshapers_clutch", 137094 )

    spec:RegisterGear( "soul_of_the_archdruid", 151636 )


    spec:RegisterStateExpr( "lunar_eclipse", function ()
        return eclipse.wrath_counter
    end )

    spec:RegisterStateExpr( "solar_eclipse", function ()
        return eclipse.starfire_counter
    end )

    local LycarasHandler = setfenv( function ()
        if buff.travel_form.up then state:RunHandler( "stampeding_roar" )
        elseif buff.moonkin_form.up then state:RunHandler( "starfall" )
        elseif buff.bear_form.up then state:RunHandler( "barkskin" )
        elseif buff.cat_form.up then state:RunHandler( "primal_wrath" )
        else state:RunHandle( "wild_growth" ) end
    end, state )

    local SinfulHysteriaHandler = setfenv( function ()
        applyBuff( "ravenous_frenzy_sinful_hysteria" )
    end, state )

    spec:RegisterHook( "reset_precast", function ()
        if azerite.masterful_instincts.enabled and buff.survival_instincts.up and buff.masterful_instincts.down then
            applyBuff( "masterful_instincts", buff.survival_instincts.remains + 30 )
        end

        if buff.lycaras_fleeting_glimpse.up then
            state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
        end

        if legendary.sinful_hysteria.enabled and buff.ravenous_frenzy.up then
            state:QueueAuraExpiration( "ravenous_frenzy", SinfulHysteriaHandler, buff.ravenous_frenzy.expires )
        end

        eclipse.reset() -- from Balance.
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if not a or a.startsCombat then
            break_stealth()
        end

        if buff.ravenous_frenzy.up and ability ~= "ravenous_frenzy" then
            addStack( "ravenous_frenzy", nil, 1 )
        end
    end )


    spec:RegisterStateTable( "druid", setmetatable( {
    }, {
        __index = function( t, k )
            if k == "catweave_bear" then
                return talent.feral_affinity.enabled and settings.catweave_bear
            elseif k == "owlweave_bear" then
                return talent.balance_affinity.enabled and settings.owlweave_bear
            elseif k == "no_cds" then return not toggle.cooldowns
            elseif k == "primal_wrath" then return debuff.rip
            elseif k == "lunar_inspiration" then return debuff.moonfire_cat end

            local fallthru = rawget( debuff, k )
            if fallthru then return fallthru end
        end
    } ) )


    -- Abilities
    spec:RegisterAbilities( {
        alpha_challenge = {
            id = 207017,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            pvptalent = "alpha_challenge",

            startsCombat = true,
            texture = 132270,

            handler = function ()
                applyDebuff( "target", "focused_assault" )
            end,
        },


        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = function () return ( talent.survival_of_the_fittest.enabled and 40 or 60 ) * ( 1 + ( conduit.tough_as_bark.mod * 0.01 ) ) end,
            gcd = "off",

            startsCombat = false,
            texture = 136097,

            toggle = "defensives",
            defensive = true,

            usable = function ()
                if not tanking then return false, "player is not tanking right now"
                elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
                return true
            end,
            handler = function ()
                applyBuff( "barkskin" )

                if legendary.the_natural_orders_will.enabled and buff.bear_form.up then
                    applyBuff( "ironfur" )
                    applyBuff( "frenzied_regeneration" )
                end

                if set_bonus.tier28_2pc > 0 then
                    applyBuff( "berserk", max( buff.berserk.remains, 4 ) )
                    if set_bonus.tier28_4pc > 0 then
                        applyBuff( "architects_aligner", buff.berserk.remains )
                        applyBuff( "architects_aligner_heal", buff.berserk.remains )
                    end
                end
            end,
        },


        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -25,
            spendType = "rage",

            startsCombat = false,
            texture = 132276,

            essential = true,
            noform = "bear_form",

            handler = function ()
                shift( "bear_form" )
                if conduit.ursine_vigor.enabled then applyBuff( "ursine_vigor" ) end
            end,
        },


        berserk = {
            id = 50334,
            cast = 0,
            cooldown = function () return legendary.legacy_of_the_sleeper.enabled and 150 or 180 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 236149,

            notalent = "incarnation",

            handler = function ()
                applyBuff( "berserk" )
                if set_bonus.tier28_4pc > 0 then
                    applyBuff( "architects_aligner", buff.berserk.remains )
                    applyBuff( "architects_aligner_heal", buff.berserk.remains )
                end
            end,

            copy = "berserk_bear"
        },


        bristling_fur = {
            id = 155835,
            cast = 0,
            cooldown = 40,
            gcd = "spell",

            startsCombat = false,
            texture = 1033476,

            talent = "bristling_fur",

            usable = function ()
                if incoming_damage_3s < health.max * 0.1 then return false, "player has not taken 10% health in dmg in 3s" end
                return true
            end,
            handler = function ()
                applyBuff( "bristling_fur" )
            end,
        },


        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132115,

            noform = "cat_form",

            handler = function ()
                shift( "cat_form" )
                if pvptalent.master_shapeshifter.enabled and talent.feral_affinity.enabled then
                    applyBuff( "master_shapeshifter_feral" )
                end
            end,
        },


        cyclone = {
            id = 33786,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 136022,

            handler = function ()
                applyDebuff( "target", "cyclone" )
            end,
        },


        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 132120,

            handler = function ()
                shift( "cat_form" )
                applyBuff( "dash" )
            end,
        },


        demoralizing_roar = {
            id = 201664,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            pvptalent = "demoralizing_roar",

            startsCombat = true,
            texture = 132117,

            handler = function ()
                applyDebuff( "demoralizing_roar" )
                active_dot.demoralizing_roar = active_enemies
            end,
        },


        emerald_slumber = {
            id = 329042,
            cast = 8,
            cooldown = 120,
            channeled = true,
            gcd = "spell",

            toggle = "cooldowns",
            pvptalent = "emerald_slumber",

            startsCombat = false,
            texture = 1394953,

            handler = function ()
            end,
        },


        entangling_roots = {
            id = 339,
            cast = function () return pvptalent.entangling_claws.enabled and 0 or 1.7 end,
            cooldown = function () return pvptalent.entangling_claws.enabled and 6 or 0 end,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 136100,

            handler = function ()
                applyDebuff( "target", "entangling_roots" )
            end,
        },


        --[[ ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return args.max_energy == 1 and 50 or 25 end,
            spendType = "energy",

            startsCombat = true,
            texture = 132127,

            form = "cat_form",

            usable = function ()
                if combo_points.current == 0 then return false, "player has no combo points" end
                return true
            end,

            handler = function ()
                spend( min( 5, combo_points.current ), "combo_points" )
            end,
        }, ]]


        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = 2,
            cooldown = function () return buff.berserk_bear.up and ( level > 57 and 9 or 18 ) or 36 end,
            recharge = function () return buff.berserk_bear.up and ( level > 57 and 9 or 18 ) or 36 end,
            hasteCD = true,
            gcd = "spell",

            spend = 10,
            spendType = "rage",

            startsCombat = false,
            texture = 132091,

            toggle = "defensives",
            defensive = true,

            form = "bear_form",
            nobuff = "frenzied_regeneration",

            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( health.max * 0.08, "health" )
            end,

            auras = {
                -- Conduit (ICD)
                wellhoned_instincts = {
                    id = 340556,
                    duration = function ()
                        if conduit.wellhoned_instincts.enabled then return conduit.wellhoned_instincts.mod end
                        return 90
                    end,
                    max_stack = 1
                }
            }
        },

        grove_protection = {
            id = 354654,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 4067364,

            handler = function ()
                -- Don't apply auras; position dependent.
            end,
        },


        growl = {
            id = 6795,
            cast = 0,
            cooldown = function () return buff.berserk_bear.up and ( level > 57 and 2 or 4 ) or 8 end,
            gcd = "spell",

            nopvptalent = "alpha_challenge",

            startsCombat = true,
            texture = 132270,

            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },


        heart_of_the_wild = {
            id = 319454,
            cast = 0,
            cooldown = function () return 300 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135879,

            handler = function ()
                applyBuff( "heart_of_the_wild" )

                if talent.balance_affinity.enabled then
                    shift( "moonkin_form" )
                elseif talent.feral_affinity.enabled then
                    shift( "cat_form" )
                elseif talent.restoration_affinity.enabled then
                    unshift()
                end
            end,
        },


        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 136090,

            handler = function ()
                applyDebuff( "target", "hibernate" )
            end,
        },


        incapacitating_roar = {
            id = 99,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 132121,

            handler = function ()
                applyDebuff( "target", "incapacitating_roar" )
            end,
        },


        incarnation = {
            id = 102558,
            cast = 0,
            cooldown = function () return legendary.legacy_of_the_sleeper.enabled and 150 or 180 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,

            talent = "incarnation",

            handler = function ()
                applyBuff( "incarnation" )
                if set_bonus.tier28_4pc > 0 then
                    applyBuff( "architects_aligner", buff.incarnation.remains )
                    applyBuff( "architects_aligner_heal", buff.incarnation.remains )
                end
            end,

            copy = { "incarnation_guardian_of_ursoc", "Incarnation" }
        },


        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "off",

            spend = function () return buff.berserk_bear.up and 20 or 40 end,
            spendType = "rage",

            startsCombat = false,
            texture = 1378702,

            toggle = "defensives",
            defensive = true,

            form = "bear_form",

            usable = function ()
                if not tanking then return false, "player is not tanking right now"
                elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
                return true
            end,

            handler = function ()
                applyBuff( "ironfur" )
                removeBuff( "guardian_of_elune" )
            end,
        },


        lunar_beam = {
            id = 204066,
            cast = 0,
            cooldown = 75,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = true,
            texture = 136057,

            talent = "lunar_beam",

            handler = function ()
                applyBuff( "lunar_beam" )
            end,

            auras = {
                lunar_beam = {
                    duration = 8,
                    max_stack = 1,

                    generate = function( t )
                        local applied = action.lunar_beam.lastCast

                        if not t.name then t.name = class.auras.lunar_beam.name end

                        if applied and now - applied < 8 then
                            t.count = 1
                            t.expires = applied + 8
                            t.applied = applied
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.expires = 0
                        t.applied = 0
                        t.caster = "nobody"
                    end,
                },
            }
        },


        maim = {
            id = 22570,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 132134,

            talent = "feral_affinity",
            form = "cat_form",

            usable = function () return combo_points.current > 0, "requires combo_points" end,

            handler = function ()
                applyDebuff( "target", "maim", combo_points.current )
                spend( combo_points.current, "combo_points" )
            end,
        },


        mangle = {
            id = 33917,
            cast = 0,
            cooldown = function () return ( buff.berserk_bear.up and ( level > 57 and 1.5 or 3 ) or 6 ) * haste end,
            gcd = "spell",

            spend = function () return buff.gore.up and -19 or -15 end,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            form = "bear_form",

            handler = function ()
                if talent.guardian_of_elune.enabled then applyBuff( "guardian_of_elune" ) end
                removeBuff( "gore" )

                if conduit.savage_combatant.enabled then addStack( "savage_combatant", nil, 1 ) end
            end,

            auras = {
                -- Conduit
                savage_combatant = {
                    id = 340613,
                    duration = 15,
                    max_stack = 3
                }
            }
        },


        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 538515,

            talent = "mass_entanglement",

            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
            end,
        },


        maul = {
            id = 6807,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "rage",

            startsCombat = true,
            texture = 132136,

            form = "bear_form",

            usable = function ()
                if settings.maul_rage > 0 and rage.current - cost < settings.maul_rage then return false, "not enough additional rage" end
                return true
            end,

            handler = function ()
                if pvptalent.sharpened_claws.enabled or essence.conflict_and_strife.major then applyBuff( "sharpened_claws" ) end
                removeBuff( "savage_combatant" )
            end,
        },


        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 132114,

            talent = "mighty_bash",

            handler = function ()
                applyDebuff( "target", "mighty_bash" )
            end,
        },


        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 136096,

            handler = function ()
                applyDebuff( "target", "moonfire" )

                if buff.galactic_guardian.up then
                    gain( 8, "rage" )
                    removeBuff( "galactic_guardian" )
                end
            end,
        },


        moonkin_form = {
            id = 197625,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136036,

            noform = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                shift( "moonkin_form" )
            end,
        },


        overrun = {
            id = 202246,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 1408833,

            pvptalent = "overrun",

            handler = function ()
                applyDebuff( "target", "overrun" )
                setDistance( 5 )
            end,
        },


        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = false,
            texture = 514640,

            usable = function ()
                if time > 0 and ( not boss or not buff.shadowmeld.up ) then return false, "cannot stealth in combat"
                elseif buff.prowl.up then return false, "player is already prowling" end
                return true
            end,

            handler = function ()
                shift( "cat_form" )
                applyBuff( "prowl" )
            end,
        },


        pulverize = {
            id = 80313,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 1033490,

            talent = "pulverize",
            form = "bear_form",

            usable = function ()
                if debuff.thrash_bear.stack < 2 then return false, "target has fewer than 2 thrash stacks" end
                return true
            end,

            handler = function ()
                if debuff.thrash_bear.count > 2 then debuff.thrash_bear.count = debuff.thrash_bear.count - 2
                else removeDebuff( "target", "thrash_bear" ) end
                applyBuff( "pulverize" )
            end,
        },


        --[[ rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,
            spendType = "energy",

            startsCombat = true,
            texture = 132122,

            talent = "feral_affinity",
            form = "cat_form",

            handler = function ()
                applyDebuff( "target", "rake" )
                debuff.rake.pmultiplier = persistent_multiplier

                gain( 1, "combo_points" )
            end,
        }, ]]


        --[[ rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",

            spend = 0,
            spendType = "rage",

            startsCombat = true,
            texture = 136080,

            handler = function ()
            end,
        }, ]]


        regrowth = {
            id = 8936,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = false,
            texture = 136085,

            talent = "restoration_affinity",
            usable = function ()
                if not ( buff.bear_form.down and buff.cat_form.down and buff.travel_form.down and buff.moonkin_form.down ) then return false, "player is in a form" end
                return true
            end,

            handler = function ()
                applyBuff( "regrowth" )
            end,
        },


        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = false,
            texture = 136081,

            talent = "restoration_affinity",

            usable = function ()
                if not ( buff.bear_form.down and buff.cat_form.down and buff.travel_form.down and buff.moonkin_form.down ) then return false, "player is in a form" end
                return true
            end,
            handler = function ()
                applyBuff( "rejuvenation" )
            end,
        },


        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 135952,

            usable = function ()
                if buff.dispellable_poison.down and buff.dispellable_curse.down then return false, "player has no dispellable auras" end
                return true
            end,
            handler = function ()
                removeBuff( "dispellable_poison" )
                removeBuff( "dispellable_curse" )
            end,
        },


        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "defensives",
            defensive = true,

            startsCombat = true,
            texture = 136059,

            talent = "renewal",

            handler = function ()
                gain( 0.3 * health.max, "health" )
            end,
        },



        --[[ revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 132132,

            handler = function ()
            end,
        }, ]]


        --[[ rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 132152,

            talent = "feral_affinity",
            form = "cat_form",

            usable = function ()
                if combo_points.current == 0 then return false, "player has no combo points" end
                return true
            end,

            handler = function ()
                applyDebuff( "target", "rip" )
            end,
        }, ]]


        --[[ shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 136231,

            handler = function ()
            end,
        }, ]]


        skull_bash = {
            id = 106839,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 236946,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 132163,

            debuff = "dispellable_enrage",

            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
            end,
        },


        stampeding_roar = {
            id = 106898,
            cast = 0,
            cooldown = function () return pvptalent.freedom_of_the_herd.enabled and 0 or 60 end,
            gcd = "spell",

            startsCombat = false,
            texture = 464343,

            handler = function ()
                applyBuff( "stampeding_roar" )
                if buff.bear_form.down and buff.cat_form.down then
                    shift( "bear_form" )
                end
            end,
        },


        --[[ starfire = {
            id = 197628,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135753,

            talent = "balance_affinity",
            form = "moonkin_form",

            handler = function ()
            end,
        }, ]]


        starsurge = {
            id = 197626,
            cast = function () return buff.heart_of_the_wild.up and 0 or 2 end,
            cooldown = 10,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135730,

            talent = "balance_affinity",
            form = "moonkin_form",

            handler = function ()
                if buff.eclipse_solar.up then buff.eclipse_solar.empowerTime = query_time; applyBuff( "starsurge_empowerment_solar" ) end
                if buff.eclipse_lunar.up then buff.eclipse_lunar.empowerTime = query_time; applyBuff( "starsurge_empowerment_lunar" ) end
            end,
        },


        sunfire = {
            id = 197630,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.12,
            spendType = "mana",

            startsCombat = true,
            texture = 236216,

            talent = "balance_affinity",
            form = "moonkin_form",

            handler = function ()
                applyDebuff( "target", "sunfire" )
                active_dot.sunfire = active_enemies
            end,
        },


        survival_instincts = {
            id = 61336,
            cast = 0,
            charges = 2,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( talent.survival_of_the_fittest.enabled and ( 2/3 ) or 1 ) * 180 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( talent.survival_of_the_fittest.enabled and ( 2/3 ) or 1 ) * 180 end,
            gcd = "off",

            startsCombat = false,
            texture = 236169,

            toggle = "defensives",
            defensive = true,

            usable = function ()
                if not tanking then return false, "player is not tanking right now"
                elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
                return true
            end,

            handler = function ()
                applyBuff( "survival_instincts" )

                if azerite.masterful_instincts.enabled and buff.survival_instincts.up and buff.masterful_instincts.down then
                    applyBuff( "masterful_instincts", buff.survival_instincts.remains + 30 )
                end
            end,
        },


        swiftmend = {
            id = 18562,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = false,
            texture = 134914,

            talent = "restoration_affinity",
            toggle = "defensives",
            defensive = true,

            usable = function ()
                return IsSpellUsable( 18562 ) or buff.regrowth.up or buff.wild_growth.up or buff.rejuvenation.up, "requires a HoT"
            end,

            handler = function ()
                unshift()
                if buff.regrowth.up then removeBuff( "regrowth" )
                elseif buff.wild_growth.up then removeBuff( "wild_growth" )
                elseif buff.rejuvenation.up then removeBuff( "rejuvenation" ) end
            end,
        },


        swipe_bear = {
            id = 213771,
            known = 213764,
            suffix = "(Bear)",
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 134296,

            form = "bear_form",

            handler = function ()
            end,

            copy = { "swipe", 213764 },
            bind = { "swipe_bear", "swipe_cat", "swipe" }
        },


        --[[ teleport_moonglade = {
            id = 18960,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 4,
            spendType = "mana",

            startsCombat = true,
            texture = 135758,

            handler = function ()
            end,
        }, ]]


        thrash_bear = {
            id = 77758,
            known = 106832,
            suffix = "(Bear)",
            cast = 0,
            cooldown = function () return ( buff.berserk_bear.up and ( level > 57 and 1.5 or 3 ) or 6 ) * haste end,
            gcd = "spell",

            spend = -5,
            spendType = "rage",

            startsCombat = true,
            texture = 451161,

            form = "bear_form",
            bind = "thrash",

            handler = function ()
                applyDebuff( "target", "thrash_bear", 15, debuff.thrash_bear.count + 1 )
                active_dot.thrash_bear = active_enemies

                if legendary.ursocs_fury_remembered.enabled then
                    applyBuff( "ursocs_fury_remembered" )
                end
            end,
        },


        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = false,
            texture = 1817485,

            talent = "tiger_dash",

            handler = function ()
                applyBuff( "tiger_dash" )
            end,
        },


        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132144,

            handler = function ()
                shift( "travel_form" )
            end,
        },


        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 236170,

            talent = "balance_affinity",

            handler = function ()
                if target.distance < 15 then
                    applyDebuff( "target", "typhoon" )
                end
            end,
        },


        ursols_vortex = {
            id = 102793,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            talent = "restoration_affinity",

            startsCombat = true,
            texture = 571588,

            handler = function ()
                applyDebuff( "target", "ursols_vortex" )
            end,
        },


        wild_charge = {
            id = function ()
                if buff.bear_form.up then return 16979
                elseif buff.cat_form.up then return 49376
                elseif buff.moonkin_form.up then return 102383 end
                return 102401
            end,
            known = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            -- texture = 538771,

            talent = "wild_charge",

            usable = function () return target.exists and target.distance > 7, "target must be 8+ yards away" end,

            handler = function ()
                if buff.bear_form.up then target.distance = 5; applyDebuff( "target", "immobilized" )
                elseif buff.cat_form.up then target.distance = 5; applyDebuff( "target", "dazed" ) end
            end,

            copy = { 49376, 16979, 102401, 102383 }
        },


        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",

            spend = 0.22,
            spendType = "mana",

            startsCombat = false,
            texture = 236153,

            handler = function ()
                applyBuff( "wild_growth" )
            end,
        },


        --[[ wrath = {
            id = 5176,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 535045,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                removeStack( "solar_empowerment" )
            end,
        }, ]]
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "spectral_agility",

        package = "Guardian",
    } )

    spec:RegisterSetting( "maul_rage", 20, {
        name = "Excess Rage for |T132136:0|t Maul",
        desc = "If set above zero, the addon will recommend |T132136:0|t Maul only if you have at least this much excess Rage.",
        type = "range",
        min = 0,
        max = 60,
        step = 0.1,
        width = "full"
    } )

    spec:RegisterSetting( "mangle_more", false, {
        name = "Use |T132135:0|t Mangle More in Multi-Target",
        desc = "If checked, the default priority will recommend |T132135:0|t Mangle more often in |cFFFFD100multi-target|r scenarios.  This will generate roughly 15% more Rage and allow for more mitigation (or |T132136:0|t Maul) than otherwise, " ..
            "funnel slightly more damage into your primary target, but will |T134296:0|t Swipe less often, dealing less damage/threat to your secondary targets.",
        type = "toggle",
        width = "full",
    } )

    spec:RegisterSetting( "ironfur_damage_threshold", 5, {
        name = "Required Damage % for |T1378702:0|t Ironfur",
        desc = "If set above zero, the addon will not recommend |T1378702:0|t Ironfur unless your incoming damage for the past 5 seconds is greater than this percentage of your maximum health.",
        type = "range",
        min = 0,
        max = 100,
        step = 0.1,
        width = "full"
    } )

    spec:RegisterSetting( "shift_for_convoke", false, {
        name = "|T3636839:0|t Powershift for Convoke the Spirits",
        desc = "If checked and you are a Night Fae, the addon will recommend swapping to your Feral/Balance Affinity specialization before using |T3636839:0|t Convoke the Spirits.  " ..
            "This is a DPS gain unless you die horribly.",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "catweave_bear", false, {
        name = "|T132115:0|t Attempt Catweaving (Experimental)",
        desc = function()
            local affinity

            if state.talent.feral_affinity.enabled then
                affinity = "|cFF00FF00" .. ( GetSpellInfo( 202155 ) ) .. "|r"
            else
                affinity = "|cFFFF0000" .. ( GetSpellInfo( 202155 ) ) .. "|r"
            end

            return "If checked, the addon will use the experimental |cFFFFD100catweave|r priority included in the default priority pack.\n\nRequires " .. affinity .. "."
        end,
        type = "toggle",
        width = "full",
    } )

    spec:RegisterSetting( "owlweave_bear", false, {
        name = "|T136036:0|t Attempt Owlweaving (Experimental)",
        desc = function()
            local affinity

            if state.talent.balance_affinity.enabled then
                affinity = "|cFF00FF00" .. ( GetSpellInfo( 197488 ) ) .. "|r"
            else
                affinity = "|cFFFF0000" .. ( GetSpellInfo( 197488 ) ) .. "|r"
            end

            return "If checked, the addon will use the experimental |cFFFFD100owlweave|r priority included in the default priority pack.\n\nRequires " .. affinity .. "."
        end,
        type = "toggle",
        width = "full"
    } )

    spec:RegisterPack( "Guardian", 20220329, [[dyuiZbqiuvEeQqSjq6tuPsgfi6uqWQaHGxrLYSGq3cvOQDrYVOGggQGJHQQLPi1Zqv00aH6AOkSnqi9nQuPghieDouHY6OsfP5Pi5EOs7deCquHkSqQKEiQqQjIkurxKkvuFeecDsuHKvIk6MOcvANOk9tQuHEkKMkf4RuPIyVO8xknyOomXIvQhtQjlPlJSzQ6Zq0OvOtlA1uPcEnfA2k52u0UL63QA4k44uPkwUkpxIPlCDqTDf13PIXtLQ68ujwpvQsZxrSFGz8ZmGHwLGy8onhMEAoWZP5yk(5yCWDZdEYqdxgig6GOnkijgAlMedfIiSC1uAg6G4Y6LkZagA5HpnXqhJyO4o1qdrMXi8wPFtdlPj8sI8B9j(WWsAQnKHUHZvWr1SndTkbX4DAom90CGNtZXu8ZX4G7Mh8Zqf4y8pgkAAYrZqhZALA2MHwPIMHcrewUAknaZX5bNvaNCCLtpcWtZXqeGNMdtpnGtaNC0JsJKkUtbCYXdWCuT(VH)KGayoAjmKJ7)TXSb4Hl)lJKkamKPhGluezJeGZcaRhjTrQIGcWjhpaZr16)g(tccG)Hi)gGJhGlJPpayi)dG7pqaG3K)pcG5O)E(nskaNC8amk8WWFba7QCglgZgGHlcscGDYyeGH4bnaxOaG3Fdxum0vwIcZag6MKJzaJx(zgWqPw2lQYCLHQVmOlfgkFa8g27vBsoR)ptf8adv0r(ndDtYz9)zYcgVtZmGHsTSxuL5kdvFzqxkm0qwuhQrsUW(EBmswNCvvul7fvbyOamKaCilQd1wwsRjR49zNHlkQL9IQamcmurh53m0rsUW(EBmswNCvzbJxEYmGHsTSxuL5kdv0r(nd18)2NhXq1xg0LcdfsagsaMpaosTXSrcWqb4injB82Asameay(NgGHcWByVxHuwIosTfjSC1uAf8aaJaapzcadjaFK)OYOSxeadfGJ0KSXBRjbWqaG5FAagkaVH9Efszj6i1wKWYvtPvWdamcamcamuaw0rotwQjZKka8uameLHQDrViBihskkmE5NfmEHyMbmuQL9IQmxzOIoYVzOM)3(8igQ(YGUuyOqcWqcW8bWrQnMnsagkahPjzJ3wtcGHaaZ)0amca8KjamKa8r(JkJYEramuaostYgVTMeadbaM)PbyeayeayOaSOJCMSutMjva4Payikdv7IEr2qoKuuy8Yply8YdMbmurh53m0tMP(Hlw)rT71fgk1YErvMRSGXleLzadLAzVOkZvgQOJ8BgQ7WhWnskVZwPsKTlfRwwlgQ(YGUuyO6FMAPd1m1XOlhdTftIH6o8bCJKY7SvQez7sXQL1IfmED3mdyOul7fvzUYqfDKFZqJlBJuWpdvFzqxkmu(a4nS3RgU3zPGhayOaS(NPw6qntDm6YXqlRpyOXLTrk4NfmEHizgWqPw2lQYCLHk6i)MHgx2gPyAgQ(YGUuyO8bWByVxnCVZsbpaWqby9ptT0HAM6y0LJHwwFWqJlBJumnly8YXygWqPw2lQYCLHQVmOlfgQ(NPw6qntDm6YbWqb4nS3RYwlxlr(T6itj7cadbUa80qmadfG3WEVkBTCTe53QJmLSla8uCb4P5bdv0r(ndD4J8BwW4LFoWmGHsTSxuL5kdvFzqxkm0qAJzJeGHcWByVxTj5S()mvWdamuaUqHD)nCrfjDtdrAH4bnadbaMdmurh53m0TCglgZMfmE5NFMbmuQL9IQmxzO6ld6sHHYhaxp4SQ0s4qYmz3KCamuaMpaUEWzv9olhsMj7MKJHk6i)MHQ)E(ns2yKSLH8YOWcgV8pnZagk1YErvMRmu9LbDPWqHeG3WEV6KzQF4I1Fu7EDrbpaWtMaW8bW6FMAPd1m1XOlhaJadv0r(ndDtxHoJSGXl)8KzadLAzVOkZvgQ(YGUuyOqcWByVxDYm1pCX6pQDVUOGha4jtay(ay9ptT0HAM6y0LdGrGHk6i)MHMTwUwI8BwW4LFiMzadLAzVOkZvgQ(YGUuyOqcWByVxTPRqNr7MKtbpaWtMaWByVxLTwUwI8Blsy5QP023BHVYRvWdamcmurh53m0nDf6mMnswW4LFEWmGHk6i)MHsMdVdD293vgk1YErvMRSGXl)quMbmuQL9IQmxzO6ld6sHHcjaZhax)qjvziYzYwCKZ0wftbjPIuBmBKamuaMpaw0r(TsQYqKZKT4iNPTkMcssLT1VsKJbadfGHeG5dGRFOKQme5mzloYzAhjzPIuBmBKa8KjaC9dLuLHiNjBXrot7ijl1rMs2fagcampbyea4jta46hkPkdrot2IJCM2QykijvjeTraEkaMNamuaU(HsQYqKZKT4iNPTkMcssDKPKDbGNcG5badfGRFOKQme5mzloYzARIPGKurQnMnsagbgQOJ8BgQuLHiNjBXrotwW4LF3nZagk1YErvMRmu9LbDPWq3WEVcPSeDKAlsy5QP0k4bagkal6iNjl1KzsfaEkaMNmurh53muZ)BFEely8YpejZagk1YErvMRmurh53m0y8KYODtYXq1xg0Lcd9i)rLrzViaEYeaU(HkgpPmA3KCQsiAJa8uampb4jtayib46hQy8KYODtYPkHOncWtbWqmadfGp4M8)HKulyVxY2dxOQLm3NOjf5EGZHbQcWiaWtMaWIoYzYsnzMubGHaxagIb4jta4nS3R20vOZODtYPGhayOa8g27vB6k0z0Uj5uhzkzxa4P4cWi1va2naMdkEWq1UOxKnKdjffgV8ZcgV8ZXygWqPw2lQYCLHQVmOlfg6jijvL8Podagcam)CaGHcWfkISrwuMsJCrwZ)igQOJ8BgQP0ixely8onhygWqPw2lQYCLHQVmOlfgA5Hx7SRQb4saVilDWdr(TIAzVOkadfGHeGHeG1)VQVtRIXtkJ2njN6itj7cadbaMdamuaw))Q(oTYuAKlsDKPKDbGHaaZbagbagkadjax)qz(F7ZJuhzkzxayiWfG5jaJaadfGHeG3WEVkBTCTe53wKWYvtPTV3cFLxRQVtdWqb4nS3R20vOZODtYPQVtdWqb4nS3RqklrhP2IewUAkTQ(onaJaaJaapzcaxE41o7QA(xsKlYw(1m1HIAzVOkdn7GUdEiSPNHwE41o7QA(xsKlYw(1m1bui1)VQVtRIXtkJ2njN6itj7ce4au9)R670ktPrUi1rMs2fiWbeyOzh0DWdHnnnPAkbXq5NHk6i)MH6xuzuFIpyOzh0DWdHf563YIHYply8on)mdyOul7fvzUYq1xg0LcdDd79QS1Y1sKFBrclxnL2(El8vETQ(onadfG3WEVAtxHoJ2njNQ(onadfGfDKZKLAYmPcadbUameZqfDKFZqlo5az3KCSGX70tZmGHsTSxuL5kdvFzqxkmuib4nS3RYwlxlr(TcEaGraGHcWIoYzYsnzMubGNcG5japzcadjaVH9Ev2A5AjYVvWdamcamuaw0rotwQjZKka8uampbyOamKa8g27vX)XOv6QvVehvjeTragcCb4Pbyea4jtayib4nS3RI)JrR0vREjok4bagkaVH9Ev8FmALUA1lXrDKPKDbGNcG5xXdagbaEYeagsaEd79QImlijR(n3siDOkHOncWqGlaZtagbaEYeaEd79QnDf6mA3KCk4bagkal6iNjl1KzsfaEkaMNmurh53mutbEXcgVtZtMbmuQL9IQmxzO6ld6sHHcjaVH9EvrMfKKv)MBjKouLq0gbyiWfG5hGraGHcWqcWByVxf)hJwPRw9sCuWdamcamuaEd79QS1Y1sKFRGhayOaSOJCMSutMjvayUa80murh53mutbEXcgVtdXmdyOul7fvzUYq1xg0LcdDd79QS1Y1sKFRGhayOaSOJCMSutMjva4P4cW8KHk6i)MHAknYfXcgVtZdMbmuQL9IQmxzO6ld6sHHcjadjadjaVH9Ev8FmALUA1lXrvcrBeGHaxaEAagbaEYeagsaEd79Q4)y0kD1QxIJcEaGHcWByVxf)hJwPRw9sCuhzkzxa4Pay(v8aGraGNmbGHeG3WEVQiZcsYQFZTeshQsiAJame4cW8eGraGraGHcWIoYzYsnzMubGNcG5jaJadv0r(nd1uGxSGX70quMbmuQL9IQmxzO6ld6sHHk6iNjl1Kzsfagcam)murh53m0y8KYODtYXcgVt7UzgWqPw2lQYCLHQVmOlfgkKamKa8jijaEkaMJXbagbagkal6iNjl1KzsfaEkaMNamca8KjamKamKa8jijaEkagIKhamcamuaw0rotwQjZKka8uampbyOaCilQdv5Hx23BJrY6)JkHIAzVOkaJadv0r(nd1uAKlIfmENgIKzadLAzVOkZvgQOJ8Bg6a8AMU09smu9LbDPWqRFOIXtkJ2njNQeI2iadbaEAgQ2f9ISHCiPOW4LFwW4DAogZagQOJ8BgAmEsz0Uj5yOul7fvzUYcgV8KdmdyOul7fvzUYq1xg0Lcdv0rotwQjZKka8uampzOIoYVzOMc8IfmE5j)mdyOIoYVzOfNCGSBsogk1YErvMRSGXlpNMzadLAzVOkZvgQ(YGUuyONGKuvYN6ma4PayiMdamuaEd79Q8(2dFQJmLSla8uamhu8GHk6i)MHM33E4JfSGHAMrIuI8BMbmE5NzadLAzVOkZvgQ(YGUuyOzRFZSrARIPGKS8OaWqaGZ7Bp8zRIPGKSX4rLXFvbyOa8g27v59Th(uhzkzxa4PayEcWqea4rPeedv0r(ndnVV9Whly8onZagk1YErvMRmu9LbDPWqdPnMnsagkapsYkgvd6aGNcGHO8GHk6i)MHEutoYIfmE5jZagk1YErvMRmu9LbDPWqdPnMnsagkapsYkgvd6aGNcGHO8GHk6i)MH6pQDVjvThHKA6Ki)MfmEHyMbmuQL9IQmxzO6ld6sHHcjaZhaxp4SQ0s4qYmz3KCamuaMpaUEWzv9olhsMj7MKdGraGNmbGfDKZKLAYmPcadbUa80murh53muYC4DOZU)UYcgV8GzadLAzVOkZvgQ(YGUuyOH0gZgjadfGhjzfJQbDaWtbWUBEaWqb4S1Vz2iTvXuqswEuayiaWCqXpadraGhjzfJktX9zOIoYVzOB5mwmMnly8crzgWqPw2lQYCLHQVmOlfg6g27vf4BoNLLn7sKTokQ670amuaEd79QTCglgZwvFNgGHcWJKSIr1Goa4PayikhayOaC263mBK2QykijlpkameayoOMMhamebaEKKvmQmf3NHk6i)MHwGV5Cww2Slr26OWcwWqRKxGxbZagV8ZmGHsTSxuL5kdTsf9Ldr(nd1D29jnCqvaMMPZfaostcGJrcGfD8haNfawMLCj7fPyOIoYVzOfJWRLDlLrwW4DAMbmuQL9IQmxzOIoYVzOUdFa3iP8oBLkr2UuSAzTyO6ld6sHHYhaVH9E1W9olf8aadfG5dG1)m1shQzQJrxogAlMed1D4d4gjL3zRujY2LIvlRfly8YtMbmuQL9IQmxzOIoYVzOXLTrk4NHQVmOlfgkFa8g27vd37SuWdamuaMpaw)ZulDOMPogD5yOL1hm04Y2if8ZcgVqmZagk1YErvMRmurh53m04Y2iftZq1xg0LcdLpaEd79QH7Dwk4bagkaZhaR)zQLouZuhJUCm0Y6dgACzBKIPzbJxEWmGHsTSxuL5kdvFzqxkmu(ay9ptT0HAM6y0LdGHcWqcWqcWqcWHSOouJKCH992yKSo5QQOw2lQcWqb4nS3Rgj5c77TXizDYvvbpaWiaWqbyib46bNvLwchsMj7MKdGNmbGRhCwvVZYHKzYUj5ayeayOamFa8g27vd37SuWdamca8KjamKamKa8g27vB6k0z0Uj5uWda8Kja8g27vzRLRLi)2IewUAkT99w4R8Af8aaJaadfGHeG5dGRhCwvAjCizMSBsoagkaZhaxp4SQENLdjZKDtYbWiaWiaWiWqfDKFZqh(i)MfmEHOmdyOul7fvzUYq1xg0LcdTEWzvPLWHKzYUj5ayOamFaCiTXSrcWqby(ay9ptT0HAM6y0LdGHcWByVxLTwUwI8Blsy5QP023BHVYRv13PbyOa8g27vB6k0z0Uj5u13PbyOamKamKaS()v9DAvmEsz0Uj5uhzkzxayiaWCaGHcW6)x13PvMsJCrQJmLSlameayoaWqb46hkZ)BFEK6itj7cadbUamsDfGDdG5GIhamua(eKeapfadXCaGHcWByVxLTwUwI8Blsy5QP023BHVYRv13PbyOa8g27vB6k0z0Uj5u13PbyOa8g27viLLOJuBrclxnLwvFNgGraGNmbGHeG3WEVslH1)NPcEaGHcWuthsxayiaWtZdagbaEYeagsaU(H6eJK6i)rLrzViagkax)qD5G6i)rLrzViagbaEYeagsa(GBY)hss9smAFVngjlTQ0zRhCwvK7bohgOkadfG5dG3WEV6Ly0(EBmswAvPZwp4SQGhayOamKa8g27vAjS()mvWdamuaMA6q6cadbaEAoaWiaWqb4nS3Rgj5c77TXizDYvvDKPKDbGNIlaZphayea4jtayiby9ptT0HYOlxknadfG1)VQVtRiZH3Ho7(7Q6itj7capfxaMFagkal6iNjl1KzsfaEkaEAagbaEYeagsaEd79QrsUW(EBmswNCvvWdamuaMA6q6cadbaMJXbagbagbgAjUuhmE5NHk6i)MHEWTv0r(TDLLGHUYsyBXKyOAjCizMybJx3nZagk1YErvMRmu9LbDPWqRhCwvAjCizMSBsoagkaZhahsBmBKamuaw)ZulDOMPogD5ayOamKamKaS()v9DAvmEsz0Uj5uhzkzxayiaWCaGHcW6)x13PvMsJCrQJmLSlameayoaWqb46hkZ)BFEK6itj7cadbUamsDfGDdG5GIhamua(eKeapfadXCaGHcWByVxLTwUwI8Blsy5QP023BHVYRv13PbyOa8g27vB6k0z0Uj5u13PbyOa8g27viLLOJuBrclxnLwvFNgGraGNmbGHeG3WEVslH1)NPcEaGHcWuthsxayiaWtZdagbaEYeagsaU(H6eJK6i)rLrzViagkax)qD5G6i)rLrzViagkaFcscGNcGHyoaWqb4nS3RYwlxlr(TfjSC1uA77TWx51Q670amuaEd79QnDf6mA3KCQ670amuaEd79kKYs0rQTiHLRMsRQVtdWiaWiWqlXL6GXl)murh53m0dUTIoYVTRSem0vwcBlMedvlHdjZely8crYmGHsTSxuL5kdvFzqxkmu(a46bNvLwchsMj7MKdGHcWByVxPLW6)ZubpWqlXL6GXl)murh53m0dUTIoYVTRSem0vwcBlMedvlHdjZely8YXygWqPw2lQYCLHQVmOlfgA9GZQ6DwoKmt2njhadfG5dGdPnMnsagkaVH9Ev2A5AjYVTiHLRMsBFVf(kVwvFNgGHcWByVxTPRqNr7MKtvFNgGHcWqcWqcW6)x13PvX4jLr7MKtDKPKDbGHaaZbagkaR)FvFNwzknYfPoYuYUaWqaG5aadfG3WEVcPSeDKAlsy5QP0Q670amca8KjamKa8g27vM)3gZ26)ZubpaWqb46hQcC7ZJuh5pQmk7fbWiaWtMaWqcWhCt()qsQxIr77TXizPvLoB9GZQICpW5WavbyOamFa8g27vVeJ23BJrYsRkD26bNvf8aaJaapzcadjaR)zQLouDICmSEHayOaS()v9DAL(753izJrYwgYlJI6itj7capfxaMFagbagbgAjUuhmE5NHk6i)MHEWTv0r(TDLLGHUYsyBXKyOVZYHKzIfmE5NdmdyOul7fvzUYq1xg0LcdLpaUEWzv9olhsMj7MKdGHcWByVxz(FBmBR)ptf8adTexQdgV8ZqfDKFZqp42k6i)2UYsWqxzjSTysm03z5qYmXcgV8ZpZagk1YErvMRm0kv0xoe53muokpa7qURJaybG7e5y4fcGLUcWoeax)2DfaSJ0bahpaRLWHKzYW3z5qYmHialDfGDiaEuMjaEllP1KHE6KfalEF2z4cahYI6GQicWUtgPMMPdG1Fp)gjawxb4SaWWdaSdbWfNm0JaC2XdWI3NDgUaW()mb44byTucaodeb4r6ia28)2y2aS)ptfdv0r(nd9GBROJ8B7klbdvFzqxkm0cfr2ilQYy6dR)pR(753ibWqbyibyib4qwuhQTSKwtwX7Zodxuul7fvbyeayOamKamFaC9GZQslHdjZKDtYbWiaWqbyiby(a46bNv17SCizMSBsoagbagkadjaR)zQLouDICmSEHayOaS()v9DAL(753izJrYwgYlJI6itj7capfxaMFagbagbg6klHTftIH(6VNFJely8Y)0mdyOul7fvzUYqRurF5qKFZq5O8aSd5UocGfaUtKJHxiaw6ka7qaC9B3vaWoshaC8aSwchsMjdFNLdjZeIaS0va2Ha4rzMa4TSKwtg6PtwaS49zNHlaCilQdQIia7ozKAAMoaw)98BKayDfGZcadpaWoeaxCYqpcWzhpalEF2z4ca7)ZeGJhG1sja4mqeGhPJayTe()mby)FMkgQOJ8Bg6b3wrh532vwcgQ(YGUuyOfkISrwuLX0hw)Fw93ZVrcGHcWqcWqcWHSOouE6KLv8(SZWff1YErvagbagkadjaZhaxp4SQ0s4qYmz3KCamcamuagsaMpaUEWzv9olhsMj7MKdGraGHcWqcW6FMAPdvNihdRxiagkaR)FvFNwP)E(ns2yKSLH8YOOoYuYUaWtXfG5hGraGrGHUYsyBXKyOA93ZVrIfmE5NNmdyOul7fvzUYqfDKFZq1YAzfDKFBxzjyORSe2wmjgQzgjsjYVzbJx(HyMbmuQL9IQmxzOIoYVzOhCBfDKFBxzjyORSe2wmjg6MKJfSGH(6VNFJeZagV8ZmGHsTSxuL5kdvFzqxkm0qwuhQrsUW(EBmswNCvvul7fvbyOamFa8g27vJKCH992yKSo5QQGhayOamFa8g27vM)3gZ26)ZubpWqfDKFZqhj5c77TXizDYvLfmENMzadLAzVOkZvgQ(YGUuyO8bWByVxz(FBmBR)ptf8adv0r(nd18)2y2w)FMSGXlpzgWqPw2lQYCLHQVmOlfgA5Hx7SRkFELWwIlnskQL9IQamuaEd79kFELWwIlnsk4bgQOJ8BgQ(753izJrYwgYlJcly8cXmdyOul7fvzUYq1xg0Lcd9GBY)hssTiKI2f77TXizllIgOtrUh4CyGQmurh53mu93ZVrYgJKTmKxgfwW4LhmdyOul7fvzUYq1xg0LcdL0RCOqkPDX2K7ha8KjamPx5qHuLFjNTj3pyOIoYVzOLqoFEely8crzgWqPw2lQYCLHQVmOlfgkPx5qHus7ITj3pa4jtaysVYHcPwWTC2MC)GHk6i)MH6CsmYcgVUBMbmurh53mu93ZVrYgJKTmKxgfgk1YErvMRSGfm0HJ0V5wcMbmE5NzadLAzVOkZvgALk6lhI8BgQ7S7tA4GQa8M8)raS(n3saWBcz2ffaZXHwtdrbG7V54hLZ0dVayrh53fa(7LlkgQOJ8BgQXSRhvTLH8YOWcgVtZmGHsTSxuL5kdvFzqxkm0qwuhQrsUW(EBmswNCvvul7fvbyOamKaC9GZQslHdjZKDtYbWqb4nS3R0sy9)zQGha4jta46bNv17SCizMSBsoagkaVH9EL5)TXST()mvWda8Kja8g27vM)3gZ26)ZubpaWqb4qwuhQTSKwtwX7Zodxuul7fvbyeyOIoYVzOJKCH992yKSo5QYcgV8KzadLAzVOkZvgQ(YGUuyOByVxPLW6)ZubpaWqb46bNvLwchsMj7MKJHk6i)MHoCVZIfmEHyMbmuQL9IQmxzO6ld6sHHYhaVH9EL0Uy9)zQGhayOamKamKamFaC9GZQ6DwoKmt2njhadfG5dGRhCwvAjCizMSBsoagbagkadjaZhaR)zQLouDICmSEHayeayea4jtayibyiby(a46bNv17SCizMSBsoagkaZhaxp4SQ0s4qYmz3KCamcamuagsaw)ZulDO6e5yy9cbWqb4qwuhQJkXFsKFBfVp7mCrrTSxufGraGrGHk6i)MHUj5S()mzbJxEWmGHsTSxuL5kdvFzqxkm0nS3Rm)VnMT1)NPcEaGHcW1doRQ3z5qYmz3KCamuaMpaw)ZulDO6e5yy9cXqfDKFZqDojgzbJxikZagk1YErvMRmu9LbDPWq3WEVY8)2y2w)FMk4bagkaxp4SQENLdjZKDtYbWqby9ptT0HQtKJH1ledv0r(ndTeY5ZJybJx3nZagk1YErvMRmu9LbDPWqlp8ANDvnaxc4fzPdEiYVvul7fvb4jta4YdV2zxvZ)sICr2YVMPouul7fvzOzh0DWdHn9m0YdV2zxvZ)sICr2YVMPoyOzh0DWdHnnnPAkbXq5NHk6i)MH6xuzuFIpyOzh0DWdHf563YIHYplybdv))Q(oDHzaJx(zgWqfDKFZqh(i)MHsTSxuL5kly8onZagQOJ8Bg6E9F16HpxyOul7fvzUYcgV8Kzadv0r(ndDtxHoJzJKHsTSxuL5kly8cXmdyOIoYVzOYPLMSXFh1bdLAzVOkZvwW4LhmdyOIoYVzORe5yuSUdWvKMuhmuQL9IQmxzbJxikZagQOJ8BgQppAV(VYqPw2lQYCLfmED3mdyOIoYVzOsRPsCYYQL1IHsTSxuL5kly8crYmGHsTSxuL5kdvFzqxkm0nS3R2KCw)FMk4bgQOJ8Bg6(YsSYgP1dFSGXlhJzadLAzVOkZvgQ(YGUuyOqcW1puM)3(8ivKAJzJeGNmbGfDKZKLAYmPcadbaMFagbagkax)qfJNugTBsovKAJzJKHk6i)MHMTwUwI8BwW4LFoWmGHk6i)MHUPRqNrgk1YErvMRSGXl)8ZmGHsTSxuL5kdv0r(ndv7IE9X9DQT7Lucgk59KoSTysmuTl61h33P2UxsjybJx(NMzadv0r(ndfUq2miZcdLAzVOkZvwWcgQwchsMjMbmE5NzadLAzVOkZvgQ(YGUuyOHSOouJKCH992yKSo5QQOw2lQcWqby(a4nS3Rgj5c77TXizDYvvbpaWqby(a4nS3R0sy9)zQGhyOIoYVzOJKCH992yKSo5QYcgVtZmGHk6i)MHoCVZIHsTSxuL5kly8YtMbmuQL9IQmxzO6ld6sHHYhaVH9ELwcR)ptf8adv0r(ndvlH1)Njly8cXmdyOul7fvzUYq1xg0LcdDd79QH7Dwk4bgQOJ8Bg6jgjwW4LhmdyOul7fvzUYq1xg0LcdnKf1HAKKlSV3gJK1jxvf1YErvagkaZhaVH9E1ijxyFVngjRtUQk4bgQOJ8Bg6ijxyFVngjRtUQSGXleLzadLAzVOkZvgQ(YGUuyO1doRkTeoKmt2njhdv0r(ndLmhEh6S7VRSGXR7MzadLAzVOkZvgQ(YGUuyO1puNyKuh5pQmk7fbWtMaWuthsxa4PayiMhmurh53m0tmsSGXlejZagk1YErvMRmu9LbDPWqRFOUCqDK)OYOSxeadfG1V5(TdF2rbGHaxagIzOIoYVzOxoWcgVCmMbmuQL9IQmxzO6ld6sHHwp4SQ0s4qYmz3KCmurh53mu93ZVrYgJKTmKxgfwW4LFoWmGHsTSxuL5kdvFzqxkmu9BUF7WNDuayiWfGHyagkatnDiDbGHaaZdoWqfDKFZq90968Hl2Dged1uCFl10H0fgV8ZcgV8ZpZagk1YErvMRmu9LbDPWqHeG5dGRFOKQme5mzloYzARIPGKurQnMnsagkaZhal6i)wjvziYzYwCKZ0wftbjPY26xjYXaGHcWqcW8bW1pusvgICMSfh5mTJKSurQnMnsaEYeaU(HsQYqKZKT4iNPDKKL6itj7cadbaMNamca8KjaC9dLuLHiNjBXrotBvmfKKQeI2iapfaZtagkax)qjvziYzYwCKZ0wftbjPoYuYUaWtbW8aGHcW1pusvgICMSfh5mTvXuqsQi1gZgjaJadv0r(ndvQYqKZKT4iNjly8Y)0mdyOul7fvzUYq1xg0LcdT8WRD2v1aCjGxKLo4Hi)wrTSxufGHcWuthsxa4PayEYdaEYeaU8WRD2v18VKixKT8RzQdf1YErvgA2bDh8qytpdT8WRD2v18VKixKT8RzQdOuthsxMIN8GHMDq3bpe200KQPeedLFgQOJ8BgQFrLr9j(GHMDq3bpewKRFllgk)SGXl)8Kzadv0r(ndT4KdKDtYXqPw2lQYCLfmE5hIzgWqPw2lQYCLHQVmOlfg6r(JkJYEramuaw)M73o8zhfaEkaMhmurh53m0tmsSGXl)8GzadLAzVOkZvgQ(YGUuyO63C)2Hp7OaWtbW8GHk6i)MHwgpQYcwWq16VNFJeZagV8ZmGHsTSxuL5kdvFzqxkm0qwuhQrsUW(EBmswNCvvul7fvbyOamFa8g27vJKCH992yKSo5QQGhayOamFa8g27vAjS()mvWdmurh53m0rsUW(EBmswNCvzbJ3PzgWqPw2lQYCLHQVmOlfgkFa8g27vAjS()mvWdmurh53muTew)FMSGXlpzgWqfDKFZq1Fp)gjBms2YqEzuyOul7fvzUYcwWqFNLdjZeZagV8ZmGHsTSxuL5kdvFzqxkm0qwuhQrsUW(EBmswNCvvul7fvbyOamFa8g27vJKCH992yKSo5QQGhayOamFa8g27vM)3gZ26)ZubpWqfDKFZqhj5c77TXizDYvLfmENMzadLAzVOkZvgQ(YGUuyO8bWByVxz(FBmBR)ptf8adv0r(nd18)2y2w)FMSGXlpzgWqfDKFZqlHCf4djXqPw2lQYCLfmEHyMbmuQL9IQmxzO6ld6sHHEWn5)djPwesr7I992yKSLfrd0Pi3dComqvgQOJ8BgQ(753izJrYwgYlJcly8YdMbmuQL9IQmxzO6ld6sHHwE41o7QYNxjSL4sJKIAzVOkdv0r(ndv)98BKSXizld5LrHfmEHOmdyOul7fvzUYq1xg0LcdTEWzv9olhsMj7MKJHk6i)MHsMdVdD293vwW41DZmGHsTSxuL5kdvFzqxkmuiby(a46hkPkdrot2IJCM2QykijvKAJzJeGHcW8bWIoYVvsvgICMSfh5mTvXuqsQST(vICmayOamKamFaC9dLuLHiNjBXrot7ijlvKAJzJeGNmbGRFOKQme5mzloYzAhjzPoYuYUaWqaG5jaJaapzcax)qjvziYzYwCKZ0wftbjPkHOncWtbW8eGHcW1pusvgICMSfh5mTvXuqsQJmLSla8uampayOaC9dLuLHiNjBXrotBvmfKKksTXSrcWiWqfDKFZqLQme5mzloYzYcgVqKmdyOul7fvzUYqfDKFZqlWTppIHQVmOlfg6r(JkJYErmuTl6fzd5qsrHXl)SGXlhJzadLAzVOkZvgQOJ8BgQ5)TppIHQVmOlfg6r(JkJYEra8Kja8g27viLLOJuBrclxnLwbpWq1UOxKnKdjffgV8ZcgV8ZbMbmuQL9IQmxzO6ld6sHHQ)zQLouDICmSEHayOamPx5qHus7ITj3pyOIoYVzOLqoFEely8Yp)mdyOul7fvzUYq1xg0LcdLpaw)ZulDO6e5yy9cbWqbysVYHcPK2fBtUFWqfDKFZqDojgzbJx(NMzadLAzVOkZvgQ(YGUuyOqcWByVxr6voui7cULtbpaWtMaWByVxr6vouiB5xYPGhayeyOIoYVzO6VNFJKngjBziVmkSGXl)8KzadLAzVOkZvgQ(YGUuyOqcWKELdfsLTDb3YbWtMaWKELdfsv(LC2MC)aGraGNmbGHeGj9khkKkB7cULdGHcWByVxvc5kWhsYsMdVdDMuh2fClNcEaGrGHk6i)MHwc585rSGXl)qmZagQOJ8BgQZjXidLAzVOkZvwWcwWqNPRKFZ4DAom90Cy6PHOmuh56SrwyOCuMd)fufG5yaSOJ8BaELLOOaCYqldKMXl)CaIzOd37ZfXq5iCeagIiSC1uAaMJZdoRao5iCeaMJRC6raEAogIa80Cy6PbCc4KJWrayo6rPrsf3Pao5iCeaMJhG5OA9Fd)jbbWC0syih3)BJzdWdx(xgjvayitpaxOiYgjaNfawpsAJufbfGtochbG54byoQw)3WFsqa8pe53aC8aCzm9bad5FaC)bca8M8)ramh93ZVrsb4KJWrayoEagfEy4VaGDvoJfJzdWWfbjbWozmcWq8GgGluaW7VHlkaNao5iaS7S7tA4GQa8M8)raS(n3saWBcz2ffaZXHwtdrbG7V54hLZ0dVayrh53fa(7LlkaNIoYVlQHJ0V5wc34AOXSRhvTLH8YOa4u0r(DrnCK(n3s4gxdhj5c77TXizDYvfX0ZnKf1HAKKlSV3gJK1jxvf1YErvOqwp4SQ0s4qYmz3KCq3WEVslH1)NPcEyYK6bNv17SCizMSBsoOByVxz(FBmBR)ptf8WKjByVxz(FBmBR)ptf8a0qwuhQTSKwtwX7Zodxuul7fvraWPOJ87IA4i9BULWnUgoCVZcX0ZDd79kTew)FMk4bO1doRkTeoKmt2njhGtrh53f1Wr63ClHBCnCtYz9)zIy65Y3g27vs7I1)NPcEakKqYx9GZQ6DwoKmt2njhu(QhCwvAjCizMSBsoeGcjF6FMAPdvNihdRxieqyYeiHKV6bNv17SCizMSBsoO8vp4SQ0s4qYmz3KCiafs9ptT0HQtKJH1le0qwuhQJkXFsKFBfVp7mCrrTSxufbeaCk6i)UOgos)MBjCJRHoNeJiMEUByVxz(FBmBR)ptf8a06bNv17SCizMSBsoO8P)zQLouDICmSEHaCk6i)UOgos)MBjCJRHLqoFEeIPN7g27vM)3gZ26)ZubpaTEWzv9olhsMj7MKdQ(NPw6q1jYXW6fcWPOJ87IA4i9BULWnUg6xuzuFIpqm9Clp8ANDvnaxc4fzPdEiYVvul7fvNmP8WRD2v18VKixKT8RzQdf1YErveZoO7GhcBAAs1ucIl)iMDq3bpewKRFllU8Jy2bDh8qytp3YdV2zxvZ)sICr2YVMPoaCc4KJaWUZUpPHdQcW0mDUaWrAsaCmsaSOJ)a4SaWYSKlzVifGtrh53fUfJWRLDlLraNIoYVlUX1q4czZGmrSftIR7WhWnskVZwPsKTlfRwwletpx(2WEVA4ENLcEakF6FMAPd1m1XOlhGtrh53f34AiCHSzqMiwwFWnUSnsb)iMEU8TH9E1W9olf8au(0)m1shQzQJrxoaNIoYVlUX1q4czZGmrSS(GBCzBKIPrm9C5Bd79QH7Dwk4bO8P)zQLouZuhJUCaofDKFxCJRHdFKFJy65YN(NPw6qntDm6YbfsiHmKf1HAKKlSV3gJK1jxvf1YErvOByVxnsYf23BJrY6KRQcEabOqwp4SQ0s4qYmz3KCtMup4SQENLdjZKDtYHau(2WEVA4ENLcEaHjtGeYnS3R20vOZODtYPGhMmzd79QS1Y1sKFBrclxnL2(El8vETcEabOqYx9GZQslHdjZKDtYbLV6bNv17SCizMSBsoeqabaNCeocaZrlHdjZzJeGfDKFdWRSeaStUwa8Ma4tAao9icWMsJCrggJNugby5ia(BawxreGpbjbWzbG306DayiMdicWUx6mcWsxb4S1Y1sKFdWYraC9DAaw6kadrewwIosnaJewUAknaVH9EaolaC)bal6iNjeb4)a40Jia7qURJa4SbyTe()mbyPRam10H0faolaSS)zcGNMhicWUJhaNEa2Ha4rzMa4yKay3rjgb4fHK6QCUaWK7bohgOkIaCmsaCL2WEpaVY2ivb44b4ma4SaW9ham8aalDfGPMoKUaWzbGL9pta80Car3XdGtpa7qURJayJUCP0aS0va2D2C4DOdG3Fxby9)R670aCway4baw6katnzMubGLJa4S90L)bWXdWtRaCk6i)U4gxdp42k6i)2UYsGyjUuhC5hXwmjUAjCizMqm9CRhCwvAjCizMSBsoO8fsBmBKq5t)ZulDOMPogD5GUH9Ev2A5AjYVTiHLRMsBFVf(kVwvFNg6g27vB6k0z0Uj5u13PHcjK6)x13PvX4jLr7MKtDKPKDbcCaQ()v9DALP0ixK6itj7ce4a06hkZ)BFEK6itj7ce4IuxDJdkEa9eK0uqmhGUH9Ev2A5AjYVTiHLRMsBFVf(kVwvFNg6g27vB6k0z0Uj5u13PHUH9Efszj6i1wKWYvtPv13PryYei3WEVslH1)NPcEak10H0fimnpqyYeiRFOoXiPoYFuzu2lcA9d1LdQJ8hvgL9IqyYeip4M8)HKuVeJ23BJrYsRkD26bNvf5EGZHbQcLVnS3REjgTV3gJKLwv6S1doRk4bOqUH9ELwcR)ptf8auQPdPlqyAoGa0nS3Rgj5c77TXizDYvvDKPKDzkU8ZbeMmbs9ptT0HYOlxknu9)R670kYC4DOZU)UQoYuYUmfx(Hk6iNjl1KzsLPMgHjtGCd79QrsUW(EBmswNCvvWdqPMoKUaboghqabaNIoYVlUX1WdUTIoYVTRSeiwIl1bx(rSftIRwchsMjetp36bNvLwchsMj7MKdkFH0gZgju9ptT0HAM6y0LdkKqQ)FvFNwfJNugTBso1rMs2fiWbO6)x13PvMsJCrQJmLSlqGdqRFOm)V95rQJmLSlqGlsD1noO4b0tqstbXCa6g27vzRLRLi)2IewUAkT99w4R8Av9DAOByVxTPRqNr7MKtvFNg6g27viLLOJuBrclxnLwvFNgHjtGCd79kTew)FMk4bOuthsxGW08aHjtGS(H6eJK6i)rLrzViO1puxoOoYFuzu2lc6jiPPGyoaDd79QS1Y1sKFBrclxnL2(El8vETQ(on0nS3R20vOZODtYPQVtdDd79kKYs0rQTiHLRMsRQVtJacaofDKFxCJRHhCBfDKFBxzjqSexQdU8JylMexTeoKmtiMEU8vp4SQ0s4qYmz3KCq3WEVslH1)NPcEaWjhHJaWUJolhsMZgjal6i)gGxzjayNCTa4nbWN0aC6reGnLg5ImmgpPmcWYra83aSUIiaFcscGZcaVP17aW8Zdeby3lDgbyPRaC2A5AjYVby5iaU(onalDfGHicllrhPgGrclxnLgG3WEpaNfaU)aGfDKZKcGDhpao9icWoK76iaoBa28)2y2aS)ptaw6kaxGBFEeaNfa(i)rLrzVieby3XdGtpa7qa8OmtaCmsaS7OeJa8IqsDvoxayY9aNddufraogjaUsByVhGxzBKQaC8aCgaCwa4(dagEq5oEaC6byhYDDeaB0LlLgGLUcWUZMdVdDa8(7kaR)FvFNgGZcadpaWsxbyQjZKkaSCeaVP17aWtJia)haNEa2HCxhbW8Mihda2lealDfG5O)E(nsaSUcWzbGHhuaofDKFxCJRHhCBfDKFBxzjqSexQdU8JylMe33z5qYmHy65wp4SQENLdjZKDtYbLVqAJzJe6g27vzRLRLi)2IewUAkT99w4R8Av9DAOByVxTPRqNr7MKtvFNgkKqQ)FvFNwfJNugTBso1rMs2fiWbO6)x13PvMsJCrQJmLSlqGdq3WEVcPSeDKAlsy5QP0Q670imzcKByVxz(FBmBR)ptf8a06hQcC7ZJuh5pQmk7fHWKjqEWn5)djPEjgTV3gJKLwv6S1doRkY9aNddufkFByVx9smAFVngjlTQ0zRhCwvWdimzcK6FMAPdvNihdRxiO6)x13Pv6VNFJKngjBziVmkQJmLSltXLFeqaWPOJ87IBCn8GBROJ8B7klbIL4sDWLFeBXK4(olhsMjetpx(QhCwvVZYHKzYUj5GUH9EL5)TXST()mvWdao5iamhLhGDi31raSaWDICm8cbWsxbyhcGRF7Uca2r6aGJhG1s4qYmz47SCizMqeGLUcWoeapkZeaVLL0AYqpDYcGfVp7mCbGdzrDqveby3jJutZ0bW6VNFJeaRRaCway4ba2Ha4Itg6rao74byX7Zodxay)FMaC8aSwkbaNbIa8iDeaB(FBmBa2)NPcWPOJ87IBCn8GBROJ8B7klbITysCF93ZVrcX0ZTqrKnYIQmM(W6)ZQ)E(nsqHeYqwuhQTSKwtwX7Zodxuul7fvrakK8vp4SQ0s4qYmz3KCiafs(QhCwvVZYHKzYUj5qakK6FMAPdvNihdRxiO6)x13Pv6VNFJKngjBziVmkQJmLSltXLFeqaWjhbG5O8aSd5UocGfaUtKJHxiaw6ka7qaC9B3vaWoshaC8aSwchsMjdFNLdjZeIaS0va2Ha4rzMa4TSKwtg6PtwaS49zNHlaCilQdQIia7ozKAAMoaw)98BKayDfGZcadpaWoeaxCYqpcWzhpalEF2z4ca7)ZeGJhG1sja4mqeGhPJayTe()mby)FMkaNIoYVlUX1WdUTIoYVTRSei2IjXvR)E(nsiMEUfkISrwuLX0hw)Fw93ZVrckKqgYI6q5PtwwX7Zodxuul7fvrakK8vp4SQ0s4qYmz3KCiafs(QhCwvVZYHKzYUj5qakK6FMAPdvNihdRxiO6)x13Pv6VNFJKngjBziVmkQJmLSltXLFeqaWPOJ87IBCnulRLv0r(TDLLaXwmjUMzKiLi)gWPOJ87IBCn8GBROJ8B7klbITysC3KCaobCk6i)UO2KCC3KCw)FMiMEU8TH9E1MKZ6)Zubpa4u0r(DrTj5CJRHJKCH992yKSo5QIy65gYI6qnsYf23BJrY6KRQIAzVOkuidzrDO2YsAnzfVp7mCrrTSxufbaNIoYVlQnjNBCn08)2NhHO2f9ISHCiPOWLFetpxiHKVi1gZgj0injB82AsqG)PHUH9Efszj6i1wKWYvtPvWdimzcKh5pQmk7fbnstYgVTMee4FAOByVxHuwIosTfjSC1uAf8aciav0rotwQjZKktbrbCk6i)UO2KCUX1qZ)BFEeIAx0lYgYHKIcx(rm9CHes(IuBmBKqJ0KSXBRjbb(NgHjtG8i)rLrzViOrAs24T1KGa)tJacqfDKZKLAYmPYuquaNIoYVlQnjNBCn8KzQF4I1Fu7EDbWPOJ87IAtY5gxdHlKndYeXwmjUUdFa3iP8oBLkr2UuSAzTqm9C1)m1shQzQJrxoaNIoYVlQnjNBCneUq2mitelRp4gx2gPGFetpx(2WEVA4ENLcEaQ(NPw6qntDm6Yb4u0r(DrTj5CJRHWfYMbzIyz9b34Y2iftJy65Y3g27vd37SuWdq1)m1shQzQJrxoaNIoYVlQnjNBCnC4J8Betpx9ptT0HAM6y0Ld6g27vzRLRLi)wDKPKDbcCNgIHUH9Ev2A5AjYVvhzkzxMI708aWPOJ87IAtY5gxd3YzSymBetp3qAJzJe6g27vBsoR)ptf8a0cf293WfvK0nnePfIh0qGdaofDKFxuBso34AO(753izJrYwgYlJcIPNlF1doRkTeoKmt2njhu(QhCwvVZYHKzYUj5aCk6i)UO2KCUX1WnDf6mA3KCiMEUqUH9E1jZu)WfR)O296IcEyYe(0)m1shQzQJrxoeaCk6i)UO2KCUX1WS1Y1sKFJy65c5g27vNmt9dxS(JA3Rlk4Hjt4t)ZulDOMPogD5qaWPOJ87IAtY5gxd30vOZy2irm9CHCd79QnDf6mA3KCk4Hjt2WEVkBTCTe53wKWYvtPTV3cFLxRGhqaWPOJ87IAtY5gxdjZH3Ho7(7kGtrh53f1MKZnUgkvziYzYwCKZeX0Zfs(QFOKQme5mzloYzARIPGKurQnMnsO8j6i)wjvziYzYwCKZ0wftbjPY26xjYXakK8v)qjvziYzYwCKZ0osYsfP2y2iNmP(HsQYqKZKT4iNPDKKL6itj7ce4jctMu)qjvziYzYwCKZ0wftbjPkHOnofpHw)qjvziYzYwCKZ0wftbjPoYuYUmfpGw)qjvziYzYwCKZ0wftbjPIuBmBKia4u0r(DrTj5CJRHM)3(8ietp3nS3RqklrhP2IewUAkTcEaQOJCMSutMjvMINaofDKFxuBso34AymEsz0Uj5qu7IEr2qoKuu4YpIPN7r(JkJYErtMu)qfJNugTBsovjeTXP45Kjqw)qfJNugTBsovjeTXPGyOhCt()qsQfS3lz7Hlu1sM7t0KICpW5WavryYerh5mzPMmtQabUq8KjByVxTPRqNr7MKtbpaDd79QnDf6mA3KCQJmLSltXfPU6ghu8aWPOJ87IAtY5gxdnLg5Iqm9CpbjPQKp1zab(5a0cfr2ilktPrUiR5FeGtrh53f1MKZnUg6xuzuFIpqm9Clp8ANDvnaxc4fzPdEiYVvul7fvHcjK6)x13PvX4jLr7MKtDKPKDbcCaQ()v9DALP0ixK6itj7ce4acqHS(HY8)2NhPoYuYUabU8ebOqUH9Ev2A5AjYVTiHLRMsBFVf(kVwvFNg6g27vB6k0z0Uj5u13PHUH9Efszj6i1wKWYvtPv13PraHjtkp8ANDvn)ljYfzl)AM6qrTSxufXSd6o4HWMMMunLG4YpIzh0DWdHf563YIl)iMDq3bpe20ZT8WRD2v18VKixKT8RzQdOqQ)FvFNwfJNugTBso1rMs2fiWbO6)x13PvMsJCrQJmLSlqGdia4u0r(DrTj5CJRHfNCGqm9C3WEVkBTCTe53wKWYvtPTV3cFLxRQVtdDd79QnDf6mA3KCQ670qfDKZKLAYmPce4cXaofDKFxuBso34AOPaVqm9CHCd79QS1Y1sKFRGhqaQOJCMSutMjvMINtMa5g27vzRLRLi)wbpGaurh5mzPMmtQmfpHc5g27vX)XOv6QvVehvjeTriWDAeMmbYnS3RI)JrR0vREjok4bOByVxf)hJwPRw9sCuhzkzxMIFfpqyYei3WEVQiZcsYQFZTeshQsiAJqGlpryYKnS3R20vOZODtYPGhGk6iNjl1KzsLP4jGtrh53f1MKZnUgAkWletpxi3WEVQiZcsYQFZTeshQsiAJqGl)iafYnS3RI)JrR0vREjok4beGUH9Ev2A5AjYVvWdqfDKZKLAYmPc3PbCk6i)UO2KCUX1qtPrUietp3nS3RYwlxlr(TcEaQOJCMSutMjvMIlpbCk6i)UO2KCUX1qtbEHy65cjKqUH9Ev8FmALUA1lXrvcrBecCNgHjtGCd79Q4)y0kD1QxIJcEa6g27vX)XOv6QvVeh1rMs2LP4xXdeMmbYnS3RkYSGKS63ClH0HQeI2ie4YteqaQOJCMSutMjvMINia4u0r(DrTj5CJRHX4jLr7MKdX0Zv0rotwQjZKkqGFaNIoYVlQnjNBCn0uAKlcX0ZfsipbjnfhJdiav0rotwQjZKktXteMmbsipbjnfejpqaQOJCMSutMjvMINqdzrDOkp8Y(EBmsw)Fujuul7fvraWPOJ87IAtY5gxdhGxZ0LUxcrTl6fzd5qsrHl)iMEU1puX4jLr7MKtvcrBectd4u0r(DrTj5CJRHX4jLr7MKdWPOJ87IAtY5gxdnf4fIPNROJCMSutMjvMINaofDKFxuBso34AyXjhi7MKdWPOJ87IAtY5gxdZ7Bp8Hy65EcssvjFQZykiMdq3WEVkVV9WN6itj7YuCqXdaNaofDKFxuMzKiLi)MBEF7Hpetp3S1Vz2iTvXuqswEuGqEF7HpBvmfKKngpQm(Rk0nS3RY7Bp8PoYuYUmfpHimkLGaCk6i)UOmZirkr(TBCn8OMCKfIPNBiTXSrcDKKvmQg0XuquEa4u0r(DrzMrIuI8B34AO)O29Mu1EesQPtI8Betp3qAJzJe6ijRyunOJPGO8aWPOJ87IYmJePe53UX1qYC4DOZU)UIy65cjF1doRkTeoKmt2njhu(QhCwvVZYHKzYUj5qyYerh5mzPMmtQabUtd4u0r(DrzMrIuI8B34A4woJfJzJy65gsBmBKqhjzfJQbDmL7MhqZw)MzJ0wftbjz5rbcCqXpeHrswXOYuCFaNIoYVlkZmsKsKF7gxdlW3CollB2LiBDuqm9C3WEVQaFZ5SSSzxIS1rrvFNg6g27vB5mwmMTQ(on0rswXOAqhtbr5a0S1Vz2iTvXuqswEuGahutZdicJKSIrLP4(aobCk6i)UO0)VQVtx4o8r(nGtrh53fL()v9D6IBCnCV(VA9WNlaofDKFxu6)x13PlUX1WnDf6mMnsaNIoYVlk9)R670f34AOCAPjB83rDa4u0r(DrP)FvFNU4gxdxjYXOyDhGRinPoaCk6i)UO0)VQVtxCJRH(8O96)kGtrh53fL()v9D6IBCnuAnvItwwTSwaofDKFxu6)x13PlUX1W9LLyLnsRh(qm9C3WEVAtYz9)zQGhaCk6i)UO0)VQVtxCJRHzRLRLi)gX0ZfY6hkZ)BFEKksTXSrozIOJCMSutMjvGa)iaT(HkgpPmA3KCQi1gZgjGtrh53fL()v9D6IBCnCtxHoJaofDKFxu6)x13PlUX1q4czZGmrK8Esh2wmjUAx0RpUVtTDVKsa4u0r(DrP)FvFNU4gxdHlKndYSa4eWPOJ87IslHdjZe3rsUW(EBmswNCvrm9CdzrDOgj5c77TXizDYvvrTSxufkFByVxnsYf23BJrY6KRQcEakFByVxPLW6)Zubpa4u0r(DrPLWHKzYnUgoCVZcWPOJ87IslHdjZKBCnulH1)NjIPNlFByVxPLW6)Zubpa4u0r(DrPLWHKzYnUgEIrcX0ZDd79QH7Dwk4baNIoYVlkTeoKmtUX1WrsUW(EBmswNCvrm9CdzrDOgj5c77TXizDYvvrTSxufkFByVxnsYf23BJrY6KRQcEaWPOJ87IslHdjZKBCnKmhEh6S7VRiMEU1doRkTeoKmt2njhGtrh53fLwchsMj34A4jgjetp36hQtmsQJ8hvgL9IMmHA6q6YuqmpaCk6i)UO0s4qYm5gxdVCaX0ZT(H6Yb1r(JkJYErq1V5(TdF2rbcCHyaNIoYVlkTeoKmtUX1q93ZVrYgJKTmKxgfetp36bNvLwchsMj7MKdWPOJ87IslHdjZKBCn0t3RZhUy3zqiAkUVLA6q6cx(rm9C1V5(TdF2rbcCHyOuthsxGap4aGtrh53fLwchsMj34AOuLHiNjBXrotetpxi5R(HsQYqKZKT4iNPTkMcssfP2y2iHYNOJ8BLuLHiNjBXrotBvmfKKkBRFLihdOqYx9dLuLHiNjBXrot7ijlvKAJzJCYK6hkPkdrot2IJCM2rswQJmLSlqGNimzs9dLuLHiNjBXrotBvmfKKQeI24u8eA9dLuLHiNjBXrotBvmfKK6itj7Yu8aA9dLuLHiNjBXrotBvmfKKksTXSrIaGtrh53fLwchsMj34AOFrLr9j(aX0ZT8WRD2v1aCjGxKLo4Hi)wrTSxufk10H0LP4jpMmP8WRD2v18VKixKT8RzQdf1YErveZoO7GhcBAAs1ucIl)iMDq3bpewKRFllU8Jy2bDh8qytp3YdV2zxvZ)sICr2YVMPoGsnDiDzkEYdaNIoYVlkTeoKmtUX1WItoqaofDKFxuAjCizMCJRHNyKqm9CpYFuzu2lcQ(n3VD4ZoktXdaNIoYVlkTeoKmtUX1WY4rvetpx9BUF7WNDuMIhaobCk6i)UO06VNFJe3rsUW(EBmswNCvrm9CdzrDOgj5c77TXizDYvvrTSxufkFByVxnsYf23BJrY6KRQcEakFByVxPLW6)Zubpa4u0r(DrP1Fp)gj34AOwcR)ptetpx(2WEVslH1)NPcEaWPOJ87IsR)E(nsUX1q93ZVrYgJKTmKxgfaNaofDKFxuV(753iXDKKlSV3gJK1jxvetp3qwuhQrsUW(EBmswNCvvul7fvHY3g27vJKCH992yKSo5QQGhGY3g27vM)3gZ26)Zubpa4u0r(Dr96VNFJKBCn08)2y2w)FMiMEU8TH9EL5)TXST()mvWdaofDKFxuV(753i5gxd1Fp)gjBms2YqEzuqm9Clp8ANDv5ZRe2sCPrsrTSxuf6g27v(8kHTexAKuWdaofDKFxuV(753i5gxd1Fp)gjBms2YqEzuqm9Cp4M8)HKulcPODX(EBms2YIOb6uK7bohgOkGtrh53f1R)E(nsUX1WsiNppcX0ZL0RCOqkPDX2K7htMq6vouiv5xYzBY9daNIoYVlQx)98BKCJRHoNeJiMEUKELdfsjTl2MC)yYesVYHcPwWTC2MC)aWPOJ87I61Fp)gj34AO(753izJrYwgYlJcGtaNIoYVlQ3z5qYmXDKKlSV3gJK1jxvetp3qwuhQrsUW(EBmswNCvvul7fvHY3g27vJKCH992yKSo5QQGhGY3g27vM)3gZ26)Zubpa4u0r(Dr9olhsMj34AO5)TXST()mrm9C5Bd79kZ)BJzB9)zQGhaCk6i)UOENLdjZKBCnSeYvGpKeGtrh53f17SCizMCJRH6VNFJKngjBziVmkiMEUhCt()qsQfHu0UyFVngjBzr0aDkY9aNddufWPOJ87I6DwoKmtUX1q93ZVrYgJKTmKxgfetp3YdV2zxv(8kHTexAKuul7fvbCk6i)UOENLdjZKBCnKmhEh6S7VRiMEU1doRQ3z5qYmz3KCaofDKFxuVZYHKzYnUgkvziYzYwCKZeX0Zfs(QFOKQme5mzloYzARIPGKurQnMnsO8j6i)wjvziYzYwCKZ0wftbjPY26xjYXakK8v)qjvziYzYwCKZ0osYsfP2y2iNmP(HsQYqKZKT4iNPDKKL6itj7ce4jctMu)qjvziYzYwCKZ0wftbjPkHOnofpHw)qjvziYzYwCKZ0wftbjPoYuYUmfpGw)qjvziYzYwCKZ0wftbjPIuBmBKia4u0r(Dr9olhsMj34AybU95riQDrViBihskkC5hX0Z9i)rLrzViaNIoYVlQ3z5qYm5gxdn)V95riQDrViBihskkC5hX0Z9i)rLrzVOjt2WEVcPSeDKAlsy5QP0k4baNIoYVlQ3z5qYm5gxdlHC(8ietpx9ptT0HQtKJH1leusVYHcPK2fBtUFa4u0r(Dr9olhsMj34AOZjXiIPNlF6FMAPdvNihdRxiOKELdfsjTl2MC)aWPOJ87I6DwoKmtUX1q93ZVrYgJKTmKxgfetpxi3WEVI0RCOq2fClNcEyYKnS3Ri9khkKT8l5uWdia4u0r(Dr9olhsMj34AyjKZNhHy65cjPx5qHuzBxWTCtMq6vouiv5xYzBY9deMmbssVYHcPY2UGB5GUH9EvjKRaFijlzo8o0zsDyxWTCk4beaCk6i)UOENLdjZKBCn05KyKfSGXa]] )


end