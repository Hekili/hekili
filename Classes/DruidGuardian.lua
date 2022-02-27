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
                return state.debuff.thrash_bear.applied + floor( state.query_time - state.debuff.thrash_bear.applied )
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

    spec:RegisterPack( "Guardian", 20220226, [[dCK)XbqiuvEeQcAta6tuPcJcaNcGwfvQiVIkLzbHUfvQQSls(ffYWqfCmuLwMIKNHQOPbb11qfABqq8niizCOkGZrLkzDOku18uK6EOs7dcCqufcwifQhIQanrufICrQurTrufc9rQuv1jHGuRev0nrviQDIQQFIQq6PqAQuGVIQqL9IYFP0GH6WelwPEmPMSKUmYMPQpdrJwbNw0QrvO8AQKzRKBtr7wQFRQHRqhNkvLLRYZLy6cxhOTRO(ovmEQuLZtbTEQuPMVIy)GMXlZagAvcIX)uCyQP4WutHqutnfh4icZldnmCKyOJI2LGKyOTysmu3Fq5QP0m0rXW1lvMbm0YdEAIHoeXyHhVrgHmJbWTs)MgvstWLe536t8HrL0uBedDdMRaHUzBgAvcIX)uCyQP4WutHqutnfh4icZqfWy4pgkAAYdYqhYALA2MHwPIMH6(dkxnLgI5r6aZkKtEeP9bkNHq8uCeriEkom1uqoHCYdoinsQWJhYP7heJq36)g)tccI5bLWiEK)VDLnepE5FzKubIbi9qCHIiBKqCwGy9aPDrvavqoD)Gye6w)34Fsqq8pg53qC8qCzi9bedWFqC)bGq8M8)rqmp43ZVlsXqxzjkmdyOBsoMbm(5LzadLAzVOkZygQ(YGUuyO8bXBqVxTj5S()mvGJmurh53m0njN1)Njly8pfZagk1YErvMXmu9LbDPWqdzrDOgi5c77TXazDYvvrTSxufIbcXaaXHSOouBzjTMSI3NDggQOw2lQcXaYqfDKFZqhi5c77TXazDYvLfm(5jZagk1YErvMXmurh53muZ)BFEedvFzqxkmuaGyaGy(G4i1UYgjedeIJ0KSXBRjbXiaI5DkigieVb9Efszj6i1wKGYvtPvGJqmGq8Kjqmaq8r(JkdYErqmqiostYgVTMeeJaiM3PGyGq8g07viLLOJuBrckxnLwbocXacXacXaHyrh5mzPMmtQaXtdXiegQ2q9ISHCiPOW4NxwW4hHzgWqPw2lQYmMHk6i)MHA(F7ZJyO6ld6sHHcaedaeZhehP2v2iHyGqCKMKnEBnjigbqmVtbXacXtMaXaaXh5pQmi7fbXaH4injB82AsqmcGyENcIbeIbeIbcXIoYzYsnzMubINgIrimuTH6fzd5qsrHXpVSGXphzgWqfDKFZqpzM6hSy9h1UBdzOul7fvzgZcg)ieMbmuQL9IQmJzOIoYVzO8yFa2iP8oBLkr2gwSAzTyO6ld6sHHQ)zQLouZuhdgEm0wmjgkp2hGnskVZwPsKTHfRwwlwW4hHIzadLAzVOkZygQOJ8BgACz7IcEzO6ld6sHHYheVb9E149olf4iedeI1)m1shQzQJbdpgAz9bdnUSDrbVSGXppaZagk1YErvMXmurh53m04Y2fftXq1xg0LcdLpiEd69QX7DwkWrigieR)zQLouZuhdgEm0Y6dgACz7IIPybJF3fZagk1YErvMXmu9LbDPWq1)m1shQzQJbdpigieVb9Ev2A5AjYVvhzkzxGyeWfINcHHyGq8g07vzRLRLi)wDKPKDbINMlepfhzOIoYVzOJFKFZcg)8YbMbmuQL9IQmJzO6ld6sHHYhexpWSQ0s4qYmz3KCqmqiMpiUEGzv9olhsMj7MKJHk6i)MHQ)E(Dr2yGSLX8YOWcg)8YlZagk1YErvMXmu9LbDPWqbaI3GEV6KzQFWI1Fu7UnubocXtMaX8bX6FMAPd1m1XGHhedidv0r(ndDtxHoxSGXpVtXmGHsTSxuLzmdvFzqxkmuaG4nO3RozM6hSy9h1UBdvGJq8KjqmFqS(NPw6qntDmy4bXaYqfDKFZqZwlxlr(nly8ZlpzgWqPw2lQYmMHQVmOlfgkaq8g07vB6k05YUj5uGJq8Kjq8g07vzRLRLi)2IeuUAkT99wWR8Af4iedidv0r(ndDtxHoxzJKfm(5fHzgWqfDKFZqjZX3Ho7(7kdLAzVOkZywW4NxoYmGHsTSxuLzmdvFzqxkmuaGy(G46hkPkJrot2IJCM2QykijvKAxzJeIbcX8bXIoYVvsvgJCMSfh5mTvXuqsQST(vICiGyGqmaqmFqC9dLuLXiNjBXrot7ajlvKAxzJeINmbIRFOKQmg5mzloYzAhizPoYuYUaXiaI5jediepzcex)qjvzmYzYwCKZ0wftbjPkHODbXtdX8eIbcX1pusvgJCMSfh5mTvXuqsQJmLSlq80qmhHyGqC9dLuLXiNjBXrotBvmfKKksTRSrcXaYqfDKFZqLQmg5mzloYzYcg)8IqygWqPw2lQYmMHQVmOlfg6g07viLLOJuBrckxnLwbocXaHyrh5mzPMmtQaXtdX8KHk6i)MHA(F7ZJybJFErOygWqPw2lQYmMHk6i)MHgdNugSBsogQ(YGUuyOh5pQmi7fbXtMaX1puXWjLb7MKtvcr7cINgI5jepzcedaex)qfdNugSBsovjeTliEAigHHyGq8b2K)pKKAb69s2EWcvTK5(enPi3hyoosvigqiEYeiw0rotwQjZKkqmc4cXimepzceVb9E1MUcDUSBsof4iedeI3GEVAtxHox2njN6itj7cepnxigPUcXUbXCqXrgQ2q9ISHCiPOW4NxwW4NxEaMbmuQL9IQmJzO6ld6sHHEcssvjFQZaIraeZlhGyGqCHIiBKfLP0ixK18pIHk6i)MHAknYfXcg)86UygWqPw2lQYmMHQVmOlfgA5bx7SRQrWsaUilDGJr(TIAzVOkedeIbaIbaI1)VQVtRIHtkd2njN6itj7ceJaiMdqmqiw))Q(oTYuAKlsDKPKDbIraeZbigqigiedaex)qz(F7ZJuhzkzxGyeWfI5jediedeIbaI3GEVkBTCTe53wKGYvtPTV3cELxRQVtdXaH4nO3R20vOZLDtYPQVtdXaH4nO3RqklrhP2IeuUAkTQ(onediediepzcexEW1o7QA(xsKlYw(1m1HIAzVOkdn7GUdCmSPNHwEW1o7QA(xsKlYw(1m1bqa0)VQVtRIHtkd2njN6itj7cc4aq9)R670ktPrUi1rMs2feWbazOzh0DGJHnnnPAkbXq5LHk6i)MH6xuzqFIpyOzh0DGJHf563YIHYlly8pfhygWqPw2lQYmMHQVmOlfg6g07vzRLRLi)2IeuUAkT99wWR8Av9DAigieVb9E1MUcDUSBsov9DAigiel6iNjl1KzsfigbCHyeMHk6i)MHwCYrYUj5ybJ)P4LzadLAzVOkZygQ(YGUuyOaaXBqVxLTwUwI8Bf4iediedeIfDKZKLAYmPcepneZtiEYeigaiEd69QS1Y1sKFRahHyaHyGqSOJCMSutMjvG4PHyEcXaHyaG4nO3RI)JbR0vREjoQsiAxqmc4cXtbXacXtMaXaaXBqVxf)hdwPRw9sCuGJqmqiEd69Q4)yWkD1QxIJ6itj7cepneZRIJqmGq8Kjqmaq8g07vfzwqsw9BULq6qvcr7cIraxiMNqmGq8Kjq8g07vB6k05YUj5uGJqmqiw0rotwQjZKkq80qmpzOIoYVzOMc4Ifm(NAkMbmuQL9IQmJzO6ld6sHHcaeVb9EvrMfKKv)MBjKouLq0UGyeWfI5fIbeIbcXaaXBqVxf)hdwPRw9sCuGJqmGqmqiEd69QS1Y1sKFRahHyGqSOJCMSutMjvGyUq8umurh53mutbCXcg)tXtMbmuQL9IQmJzO6ld6sHHUb9Ev2A5AjYVvGJqmqiw0rotwQjZKkq80CHyEYqfDKFZqnLg5IybJ)PqyMbmuQL9IQmJzO6ld6sHHcaedaedaeVb9Ev8FmyLUA1lXrvcr7cIraxiEkigqiEYeigaiEd69Q4)yWkD1QxIJcCeIbcXBqVxf)hdwPRw9sCuhzkzxG4PHyEvCeIbeINmbIbaI3GEVQiZcsYQFZTeshQsiAxqmc4cX8eIbeIbeIbcXIoYzYsnzMubINgI5jedidv0r(nd1uaxSGX)uCKzadLAzVOkZygQ(YGUuyOIoYzYsnzMubIraeZldv0r(ndngoPmy3KCSGX)uieMbmuQL9IQmJzO6ld6sHHcaedaeFcscINgIDxCaIbeIbcXIoYzYsnzMubINgI5jediepzcedaedaeFcscINgI5b4iediedeIfDKZKLAYmPcepneZtigiehYI6qvEWL992yGS()OsOOw2lQcXaYqfDKFZqnLg5IybJ)PqOygWqPw2lQYmMHk6i)MHocUMPlD3edvFzqxkm06hQy4KYGDtYPkHODbXiaINIHQnuViBihskkm(5Lfm(NIhGzadv0r(ndngoPmy3KCmuQL9IQmJzbJ)PCxmdyOul7fvzgZq1xg0Lcdv0rotwQjZKkq80qmpzOIoYVzOMc4Ifm(5jhygWqfDKFZqlo5iz3KCmuQL9IQmJzbJFEYlZagk1YErvMXmu9LbDPWqpbjPQKp1zaXtdXimhGyGq8g07v59Th8uhzkzxG4PHyoO4idv0r(ndnVV9Ghlybd1mJePe53mdy8ZlZagk1YErvMXmu9LbDPWqZw)MzJ0wftbjz5ybIraeN33EWZwftbjzJHJkd)QcXaH4nO3RY7Bp4PoYuYUaXtdX8eIDNG4bPeedv0r(ndnVV9Ghly8pfZagk1YErvMXmu9LbDPWqdPDLnsigiepqYkguJ6aINgIriCKHk6i)MHEutoYIfm(5jZagk1YErvMXmu9LbDPWqdPDLnsigiepqYkguJ6aINgIriCKHk6i)MH6pQD3jvThHKA6Ki)Mfm(ryMbmuQL9IQmJzO6ld6sHHcaeZhexpWSQ0s4qYmz3KCqmqiMpiUEGzv9olhsMj7MKdIbeINmbIfDKZKLAYmPceJaUq8umurh53muYC8DOZU)UYcg)CKzadLAzVOkZygQ(YGUuyOH0UYgjedeIhizfdQrDaXtdXiuCeIbcXzRFZSrARIPGKSCSaXiaI5GIxi2DcIhizfdktX9yOIoYVzOB5CvCLnly8JqygWqPw2lQYmMHQVmOlfg6g07vfWBoNLLn7sKTokQ670qmqiEd69QTCUkUYwvFNgIbcXdKSIb1OoG4PHyechGyGqC263mBK2QykijlhlqmcGyoOMIJqS7eepqYkguMI7XqfDKFZqlG3CollB2LiBDuyblyOV(753fXmGXpVmdyOul7fvzgZq1xg0LcdnKf1HAGKlSV3gdK1jxvf1YErvigieZheVb9E1ajxyFVngiRtUQkWrigieZheVb9EL5)TRST()mvGJmurh53m0bsUW(EBmqwNCvzbJ)PygWqPw2lQYmMHQVmOlfgkFq8g07vM)3UY26)ZuboYqfDKFZqn)VDLT1)Njly8ZtMbmuQL9IQmJzO6ld6sHHwEW1o7QYNxjSL4sxKIAzVOkedeI3GEVYNxjSL4sxKcCKHk6i)MHQ)E(Dr2yGSLX8YOWcg)imZagk1YErvMXmu9LbDPWqpWM8)HKulcPOn0(EBmq2YIOr6uK7dmhhPkdv0r(ndv)987ISXazlJ5LrHfm(5iZagk1YErvMXmu9LbDPWqj9khlKsAdTn5Ebepzcet6vowiv5xYzBY9cgQOJ8BgAjKZNhXcg)ieMbmuQL9IQmJzO6ld6sHHs6vowiL0gABY9ciEYeiM0RCSqQfylNTj3lyOIoYVzOoNedSGXpcfZagQOJ8BgQ(753fzJbYwgZlJcdLAzVOkZywWcgAL8c4kygW4NxMbmuQL9IQmJzOvQOVCmYVzOUZUhPbdQcX0mDgcXrAsqCmqqSOJ)G4SaXYSKlzVifdv0r(ndT4cCTSBPmWcg)tXmGHsTSxuLzmdv0r(ndLh7dWgjL3zRujY2WIvlRfdvFzqxkmu(G4nO3RgV3zPahHyGqmFqS(NPw6qntDmy4XqBXKyO8yFa2iP8oBLkr2gwSAzTybJFEYmGHsTSxuLzmdv0r(ndnUSDrbVmu9LbDPWq5dI3GEVA8ENLcCeIbcX8bX6FMAPd1m1XGHhdTS(GHgx2UOGxwW4hHzgWqPw2lQYmMHk6i)MHgx2UOykgQ(YGUuyO8bXBqVxnEVZsbocXaHy(Gy9ptT0HAM6yWWJHwwFWqJlBxumfly8ZrMbmuQL9IQmJzO6ld6sHHYheR)zQLouZuhdgEqmqigaigaigaioKf1HAGKlSV3gdK1jxvf1YErvigieVb9E1ajxyFVngiRtUQkWrigqigiedaexpWSQ0s4qYmz3KCq8KjqC9aZQ6DwoKmt2njhediedeI5dI3GEVA8ENLcCeIbeINmbIbaIbaI3GEVAtxHox2njNcCeINmbI3GEVkBTCTe53wKGYvtPTV3cELxRahHyaHyGqmaqmFqC9aZQslHdjZKDtYbXaHy(G46bMv17SCizMSBsoigqigqigqgQOJ8Bg64h53SGXpcHzadLAzVOkZygQ(YGUuyO1dmRkTeoKmt2njhedeI5dIdPDLnsigieZheR)zQLouZuhdgEqmqiEd69QS1Y1sKFBrckxnL2(El4vETQ(onedeI3GEVAtxHox2njNQ(onedeIbaIbaI1)VQVtRIHtkd2njN6itj7ceJaiMdqmqiw))Q(oTYuAKlsDKPKDbIraeZbigiex)qz(F7ZJuhzkzxGyeWfIrQRqSBqmhuCeIbcXNGKG4PHyeMdqmqiEd69QS1Y1sKFBrckxnL2(El4vETQ(onedeI3GEVAtxHox2njNQ(onedeI3GEVcPSeDKAlsq5QP0Q670qmGq8Kjqmaq8g07vAjS()mvGJqmqiMA6qAieJaiEkocXacXtMaXaaX1puN4Iuh5pQmi7fbXaH46hQlhvh5pQmi7fbXacXtMaXaaXhyt()qsQxIb77TXazPvLoB9aZQICFG54ivHyGqmFq8g07vVed23BJbYsRkD26bMvf4iedeIbaI3GEVslH1)NPcCeIbcXuthsdHyeaXtXbigqigieVb9E1ajxyFVngiRtUQQJmLSlq80CHyE5aediepzcedaeR)zQLouUm8sPHyGqS()v9DAfzo(o0z3FxvhzkzxG4P5cX8cXaHyrh5mzPMmtQaXtdXtbXacXtMaXaaXBqVxnqYf23BJbY6KRQcCeIbcXuthsdHyeaXUloaXacXaYqlXL6GXpVmurh53m0dSTIoYVTRSem0vwcBlMedvlHdjZely8JqXmGHsTSxuLzmdvFzqxkm06bMvLwchsMj7MKdIbcX8bXH0UYgjedeI1)m1shQzQJbdpigiedaedaeR)FvFNwfdNugSBso1rMs2figbqmhGyGqS()v9DALP0ixK6itj7ceJaiMdqmqiU(HY8)2NhPoYuYUaXiGleJuxHy3GyoO4iedeIpbjbXtdXimhGyGq8g07vzRLRLi)2IeuUAkT99wWR8Av9DAigieVb9E1MUcDUSBsov9DAigieVb9Efszj6i1wKGYvtPv13PHyaH4jtGyaG4nO3R0sy9)zQahHyGqm10H0qigbq8uCeIbeINmbIbaIRFOoXfPoYFuzq2lcIbcX1puxoQoYFuzq2lcIbcXNGKG4PHyeMdqmqiEd69QS1Y1sKFBrckxnL2(El4vETQ(onedeI3GEVAtxHox2njNQ(onedeI3GEVcPSeDKAlsq5QP0Q670qmGqmGm0sCPoy8Zldv0r(nd9aBROJ8B7klbdDLLW2IjXq1s4qYmXcg)8amdyOul7fvzgZq1xg0LcdLpiUEGzvPLWHKzYUj5GyGq8g07vAjS()mvGJm0sCPoy8Zldv0r(nd9aBROJ8B7klbdDLLW2IjXq1s4qYmXcg)UlMbmuQL9IQmJzO6ld6sHHwpWSQENLdjZKDtYbXaHy(G4qAxzJeIbcXBqVxLTwUwI8Blsq5QP023BbVYRv13PHyGq8g07vB6k05YUj5u13PHyGqmaqmaqS()v9DAvmCszWUj5uhzkzxGyeaXCaIbcX6)x13PvMsJCrQJmLSlqmcGyoaXaH4nO3RqklrhP2IeuUAkTQ(onediepzcedaeVb9EL5)TRST()mvGJqmqiU(HQa2(8i1r(JkdYErqmGq8Kjqmaq8b2K)pKK6LyW(EBmqwAvPZwpWSQi3hyoosvigieZheVb9E1lXG992yGS0QsNTEGzvbocXacXtMaXaaX6FMAPdvNihcRxiigieR)FvFNwP)E(Dr2yGSLX8YOOoYuYUaXtZfI5fIbeIbKHwIl1bJFEzOIoYVzOhyBfDKFBxzjyORSe2wmjg67SCizMybJFE5aZagk1YErvMXmu9LbDPWq5dIRhywvVZYHKzYUj5GyGq8g07vM)3UY26)ZuboYqlXL6GXpVmurh53m0dSTIoYVTRSem0vwcBlMed9DwoKmtSGXpV8YmGHsTSxuLzmdTsf9LJr(ndfH2dXoK74iiwG4oroeEHGyPRqSdbX1VDhbe7iDaXXdXAjCizMm6DwoKmticXsxHyhcIhKzcI3YsAnzKNozbXI3NDggcXHSOoOkIqmpUbQPz6Gy93ZVlcI1violqm4ie7qqCXjd9aeND8qS49zNHHqS)ptioEiwlLaIZariEGocIn)VDLne7)ZuXqfDKFZqpW2k6i)2UYsWq1xg0LcdTqrKnYIQmK(W6)ZQ)E(DrqmqigaigaioKf1HAllP1Kv8(SZWqf1YErvigqigiedaeZhexpWSQ0s4qYmz3KCqmGqmqigaiMpiUEGzv9olhsMj7MKdIbeIbcXaaX6FMAPdvNihcRxiigieR)FvFNwP)E(Dr2yGSLX8YOOoYuYUaXtZfI5fIbeIbKHUYsyBXKyOV(753fXcg)8ofZagk1YErvMXm0kv0xog53mueApe7qUJJGybI7e5q4fcILUcXoeex)2DeqSJ0behpeRLWHKzYO3z5qYmHielDfIDiiEqMjiEllP1KrE6KfelEF2zyiehYI6GQicX84gOMMPdI1Fp)UiiwxH4SaXGJqSdbXfNm0dqC2XdXI3NDggcX()mH44HyTuciodeH4b6iiwlH)pti2)NPIHk6i)MHEGTv0r(TDLLGHQVmOlfgAHIiBKfvzi9H1)Nv)987IGyGqmaqmaqCilQdLNozzfVp7mmurTSxufIbeIbcXaaX8bX1dmRkTeoKmt2njhediedeIbaI5dIRhywvVZYHKzYUj5GyaHyGqmaqS(NPw6q1jYHW6fcIbcX6)x13Pv6VNFxKngiBzmVmkQJmLSlq80CHyEHyaHyazORSe2wmjgQw)987IybJFE5jZagk1YErvMXmurh53muTSwwrh532vwcg6klHTftIHAMrIuI8BwW4NxeMzadLAzVOkZygQOJ8Bg6b2wrh532vwcg6klHTftIHUj5yblyOJhPFZTemdy8ZlZagk1YErvMXm0kv0xog53mu3z3J0GbvH4n5)JGy9BULaI3eYSlkiMhbTMgJce3F7(niNPhCbXIoYVlq83ldvmurh53muxzxpQAlJ5LrHfm(NIzadLAzVOkZygQ(YGUuyOHSOoudKCH992yGSo5QQOw2lQcXaHyaG46bMvLwchsMj7MKdIbcXBqVxPLW6)ZubocXtMaX1dmRQ3z5qYmz3KCqmqiEd69kZ)BxzB9)zQahH4jtG4nO3Rm)VDLT1)NPcCeIbcXHSOouBzjTMSI3NDggQOw2lQcXaYqfDKFZqhi5c77TXazDYvLfm(5jZagk1YErvMXmu9LbDPWq3GEVslH1)NPcCeIbcX1dmRkTeoKmt2njhdv0r(ndD8ENfly8JWmdyOul7fvzgZq1xg0LcdLpiEd69kPn06)ZubocXaHyaGyaGy(G46bMv17SCizMSBsoigieZhexpWSQ0s4qYmz3KCqmGqmqigaiMpiw)ZulDO6e5qy9cbXacXacXtMaXaaXaaX8bX1dmRQ3z5qYmz3KCqmqiMpiUEGzvPLWHKzYUj5GyaHyGqmaqS(NPw6q1jYHW6fcIbcXHSOouhvI)Ki)2kEF2zyOIAzVOkediedidv0r(ndDtYz9)zYcg)CKzadLAzVOkZygQ(YGUuyOBqVxz(F7kBR)ptf4iedeIRhywvVZYHKzYUj5GyGqmFqS(NPw6q1jYHW6fIHk6i)MH6CsmWcg)ieMbmuQL9IQmJzO6ld6sHHUb9EL5)TRST()mvGJqmqiUEGzv9olhsMj7MKdIbcX6FMAPdvNihcRxigQOJ8BgAjKZNhXcg)iumdyOul7fvzgZq1xg0LcdT8GRD2v1iyjaxKLoWXi)wrTSxufINmbIlp4ANDvn)ljYfzl)AM6qrTSxuLHMDq3bog20Zqlp4ANDvn)ljYfzl)AM6GHMDq3bog200KQPeedLxgQOJ8BgQFrLb9j(GHMDq3bogwKRFllgkVSGfmu9)R670fMbm(5Lzadv0r(ndD8J8Bgk1YErvMXSGX)umdyOIoYVzO71)vRh8mKHsTSxuLzmly8ZtMbmurh53m0nDf6CLnsgk1YErvMXSGXpcZmGHk6i)MHkNwAYg)DuhmuQL9IQmJzbJFoYmGHk6i)MHUsKdrXYJbwrAsDWqPw2lQYmMfm(rimdyOIoYVzO(8O96)kdLAzVOkZywW4hHIzadv0r(ndvAnvItwwTSwmuQL9IQmJzbJFEaMbmuQL9IQmJzO6ld6sHHUb9E1MKZ6)ZuboYqfDKFZq3xwIv2iTEWJfm(DxmdyOul7fvzgZq1xg0LcdfaiU(HY8)2NhPIu7kBKq8KjqSOJCMSutMjvGyeaX8cXacXaH46hQy4KYGDtYPIu7kBKmurh53m0S1Y1sKFZcg)8YbMbmurh53m0nDf6CXqPw2lQYmMfm(5LxMbmuQL9IQmJzOIoYVzOAd1RpUVtTDVKsWqjVN0HTftIHQnuV(4(o129skbly8Z7umdyOIoYVzOGfYMbzwyOul7fvzgZcwWq1s4qYmXmGXpVmdyOul7fvzgZq1xg0LcdnKf1HAGKlSV3gdK1jxvf1YErvigieZheVb9E1ajxyFVngiRtUQkWrigieZheVb9ELwcR)ptf4idv0r(ndDGKlSV3gdK1jxvwW4FkMbmurh53m0X7DwmuQL9IQmJzbJFEYmGHsTSxuLzmdvFzqxkmu(G4nO3R0sy9)zQahzOIoYVzOAjS()mzbJFeMzadLAzVOkZygQ(YGUuyOBqVxnEVZsboYqfDKFZqpXfXcg)CKzadLAzVOkZygQ(YGUuyOHSOoudKCH992yGSo5QQOw2lQcXaHy(G4nO3Rgi5c77TXazDYvvboYqfDKFZqhi5c77TXazDYvLfm(rimdyOul7fvzgZq1xg0LcdTEGzvPLWHKzYUj5yOIoYVzOK547qND)DLfm(rOygWqPw2lQYmMHQVmOlfgA9d1jUi1r(JkdYErq8Kjqm10H0qiEAigH5idv0r(nd9exely8ZdWmGHsTSxuLzmdvFzqxkm06hQlhvh5pQmi7fbXaHy9BUF74NDuGyeWfIrygQOJ8Bg6LJSGXV7IzadLAzVOkZygQ(YGUuyO1dmRkTeoKmt2njhdv0r(ndv)987ISXazlJ5LrHfm(5LdmdyOul7fvzgZq1xg0Lcdv)M73o(zhfigbCHyegIbcXuthsdHyeaXCKdmurh53mupDVoFWIDNbXqnf3ZsnDinKXpVSGXpV8YmGHsTSxuLzmdvFzqxkmuaGy(G46hkPkJrot2IJCM2QykijvKAxzJeIbcX8bXIoYVvsvgJCMSfh5mTvXuqsQST(vICiGyGqmaqmFqC9dLuLXiNjBXrot7ajlvKAxzJeINmbIRFOKQmg5mzloYzAhizPoYuYUaXiaI5jediepzcex)qjvzmYzYwCKZ0wftbjPkHODbXtdX8eIbcX1pusvgJCMSfh5mTvXuqsQJmLSlq80qmhHyGqC9dLuLXiNjBXrotBvmfKKksTRSrcXaYqfDKFZqLQmg5mzloYzYcg)8ofZagk1YErvMXmu9LbDPWqlp4ANDvncwcWfzPdCmYVvul7fvHyGqm10H0qiEAiMNCeINmbIlp4ANDvn)ljYfzl)AM6qrTSxuLHMDq3bog20Zqlp4ANDvn)ljYfzl)AM6ai10H0WP5jhzOzh0DGJHnnnPAkbXq5LHk6i)MH6xuzqFIpyOzh0DGJHf563YIHYlly8ZlpzgWqfDKFZqlo5iz3KCmuQL9IQmJzbJFEryMbmuQL9IQmJzO6ld6sHHEK)OYGSxeedeI1V5(TJF2rbINgI5idv0r(nd9exely8ZlhzgWqPw2lQYmMHQVmOlfgQ(n3VD8Zokq80qmhzOIoYVzOLHJQSGfmuT(753fXmGXpVmdyOul7fvzgZq1xg0LcdnKf1HAGKlSV3gdK1jxvf1YErvigieZheVb9E1ajxyFVngiRtUQkWrigieZheVb9ELwcR)ptf4idv0r(ndDGKlSV3gdK1jxvwW4FkMbmuQL9IQmJzO6ld6sHHYheVb9ELwcR)ptf4idv0r(ndvlH1)Njly8ZtMbmurh53mu93ZVlYgdKTmMxgfgk1YErvMXSGfm03z5qYmXmGXpVmdyOul7fvzgZq1xg0LcdnKf1HAGKlSV3gdK1jxvf1YErvigieZheVb9E1ajxyFVngiRtUQkWrigieZheVb9EL5)TRST()mvGJmurh53m0bsUW(EBmqwNCvzbJ)PygWqPw2lQYmMHQVmOlfgkFq8g07vM)3UY26)ZuboYqfDKFZqn)VDLT1)Njly8ZtMbmurh53m0sixb8qsmuQL9IQmJzbJFeMzadLAzVOkZygQ(YGUuyOhyt()qsQfHu0gAFVngiBzr0iDkY9bMJJuLHk6i)MHQ)E(Dr2yGSLX8YOWcg)CKzadLAzVOkZygQ(YGUuyOLhCTZUQ85vcBjU0fPOw2lQYqfDKFZq1Fp)UiBmq2YyEzuybJFecZagk1YErvMXmu9LbDPWqRhywvVZYHKzYUj5yOIoYVzOK547qND)DLfm(rOygWqPw2lQYmMHQVmOlfgkaqmFqC9dLuLXiNjBXrotBvmfKKksTRSrcXaHy(Gyrh53kPkJrot2IJCM2Qykijv2w)kroeqmqigaiMpiU(HsQYyKZKT4iNPDGKLksTRSrcXtMaX1pusvgJCMSfh5mTdKSuhzkzxGyeaX8eIbeINmbIRFOKQmg5mzloYzARIPGKuLq0UG4PHyEcXaH46hkPkJrot2IJCM2Qykij1rMs2fiEAiMJqmqiU(HsQYyKZKT4iNPTkMcssfP2v2iHyazOIoYVzOsvgJCMSfh5mzbJFEaMbmuQL9IQmJzOIoYVzOfW2NhXq1xg0Lcd9i)rLbzVigQ2q9ISHCiPOW4NxwW43DXmGHsTSxuLzmdv0r(nd18)2NhXq1xg0Lcd9i)rLbzViiEYeiEd69kKYs0rQTibLRMsRahzOAd1lYgYHKIcJFEzbJFE5aZagk1YErvMXmu9LbDPWq1)m1shQoroewVqqmqiM0RCSqkPn02K7fmurh53m0siNppIfm(5LxMbmuQL9IQmJzO6ld6sHHYheR)zQLouDICiSEHGyGqmPx5yHusBOTj3lyOIoYVzOoNedSGXpVtXmGHsTSxuLzmdvFzqxkmuaG4nO3Ri9khlKDb2YPahH4jtG4nO3Ri9khlKT8l5uGJqmGmurh53mu93ZVlYgdKTmMxgfwW4NxEYmGHsTSxuLzmdvFzqxkmuaGysVYXcPY2UaB5G4jtGysVYXcPk)soBtUxaXacXtMaXaaXKELJfsLTDb2YbXaH4nO3RkHCfWdjzjZX3HotQd7cSLtbocXaYqfDKFZqlHC(8iwW4NxeMzadv0r(nd15KyGHsTSxuLzmlyblyOZ0vYVz8pfhMIxE5DkEYqDKRZgzHHIqBo(xqvi2DbXIoYVH4vwIIcYjdD8EFUigkpKhcXU)GYvtPHyEKoWSc5KhYdHyEeP9bkNHq8uCeriEkom1uqoHCYd5Hqmp4G0iPcpEiN8qEie7(bXi0T(VX)KGGyEqjmIh5)BxzdXJx(xgjvGyaspexOiYgjeNfiwpqAxufqfKtEipeID)Gye6w)34Fsqq8pg53qC8qCzi9bedWFqC)bGq8M8)rqmp43ZVlsb5eYjpeIDNDpsdgufI3K)pcI1V5wciEtiZUOGyEe0AAmkqC)T73GCMEWfel6i)UaXFVmub5u0r(DrnEK(n3s4gxJCLD9OQTmMxgfiNIoYVlQXJ0V5wc34A0ajxyFVngiRtUQiMEUHSOoudKCH992yGSo5QQOw2lQceG6bMvLwchsMj7MKd4g07vAjS()mvGJtMupWSQENLdjZKDtYbCd69kZ)BxzB9)zQahNmzd69kZ)BxzB9)zQahbgYI6qTLL0AYkEF2zyOIAzVOkGqofDKFxuJhPFZTeUX1OX7DwiMEUBqVxPLW6)ZubocSEGzvPLWHKzYUj5GCk6i)UOgps)MBjCJRrBsoR)ptetpx(2GEVsAdT()mvGJabaa(QhywvVZYHKzYUj5aYx9aZQslHdjZKDtYbiqa4t)ZulDO6e5qy9cbiGtMaaa8vpWSQENLdjZKDtYbKV6bMvLwchsMj7MKdqGaO)zQLouDICiSEHagYI6qDuj(tI8BR49zNHHkQL9IQaciKtrh53f14r63ClHBCnY5KyaX0ZDd69kZ)BxzB9)zQahbwpWSQENLdjZKDtYbKp9ptT0HQtKdH1leKtrh53f14r63ClHBCnQeY5ZJqm9C3GEVY8)2v2w)FMkWrG1dmRQ3z5qYmz3KCa1)m1shQoroewVqqofDKFxuJhPFZTeUX1i)Ikd6t8bIPNB5bx7SRQrWsaUilDGJr(TIAzVO6KjLhCTZUQM)Le5ISLFntDOOw2lQIy2bDh4yytttQMsqC5fXSd6oWXWIC9BzXLxeZoO7ahdB65wEW1o7QA(xsKlYw(1m1bKtiN8qi2D29inyqviMMPZqiostcIJbcIfD8heNfiwMLCj7fPGCk6i)UWT4cCTSBPma5u0r(DXnUgbwiBgKjITysC5X(aSrs5D2kvISnSy1YAHy65Y3g07vJ37SuGJa5t)ZulDOMPogm8GCk6i)U4gxJalKndYeXY6dUXLTlk4fX0ZLVnO3RgV3zPahbYN(NPw6qntDmy4b5u0r(DXnUgbwiBgKjIL1hCJlBxumfIPNlFBqVxnEVZsbocKp9ptT0HAM6yWWdYPOJ87IBCnA8J8Betpx(0)m1shQzQJbdpGaaaaHSOoudKCH992yGSo5QQOw2lQcCd69QbsUW(EBmqwNCvvGJaceG6bMvLwchsMj7MKBYK6bMv17SCizMSBsoabY3g07vJ37SuGJaozcaaSb9E1MUcDUSBsof44KjBqVxLTwUwI8Blsq5QP023BbVYRvGJacea(QhywvAjCizMSBsoG8vpWSQENLdjZKDtYbiGac5KhYdHyEqjCizoBKqSOJ8BiELLaIDY1cI3eeFsdXPhri2uAKlYOy4KYaelhbXFdX6kIq8jijiolq8MwVdeJWCari2DtNliw6keNTwUwI8BiwocIRVtdXsxHy3Fqzj6i1qmsq5QP0q8g07H4SaX9hqSOJCMqeI)dItpIqSd5oocIZgI1s4)ZeILUcXuthsdH4SaXY(NjiEkoIieZJEqC6HyhcIhKzcIJbcI5rLyaIxesQRYzietUpWCCKQicXXabXvAd69q8kBxufIJhIZaIZce3FaXGJqS0viMA6qAieNfiw2)mbXtXbe5rpio9qSd5oocIDz4LsdXsxHy3zZX3HoiE)DfI1)VQVtdXzbIbhHyPRqm1KzsfiwocIZ2tx(hehpepLcYPOJ87IBCn6aBROJ8B7klbIL4sDWLxeBXK4QLWHKzcX0ZTEGzvPLWHKzYUj5aYxiTRSrcKp9ptT0HAM6yWWd4g07vzRLRLi)2IeuUAkT99wWR8Av9DAGBqVxTPRqNl7MKtvFNgiaaO)FvFNwfdNugSBso1rMs2feWbG6)x13PvMsJCrQJmLSliGdaRFOm)V95rQJmLSliGlsD1noO4iWtqstJWCa4g07vzRLRLi)2IeuUAkT99wWR8Av9DAGBqVxTPRqNl7MKtvFNg4g07viLLOJuBrckxnLwvFNgWjtayd69kTew)FMkWrGuthsdrWuCeWjtaO(H6exK6i)rLbzViG1puxoQoYFuzq2lcWjta4aBY)hss9smyFVngilTQ0zRhywvK7dmhhPkq(2GEV6LyW(EBmqwAvPZwpWSQahbcWg07vAjS()mvGJaPMoKgIGP4aGa3GEVAGKlSV3gdK1jxv1rMs2LP5YlhaCYea0)m1shkxgEP0a1)VQVtRiZX3Ho7(7Q6itj7Y0C5fOOJCMSutMjvMEkaNmbGnO3Rgi5c77TXazDYvvbocKA6qAicCxCaqaHCk6i)U4gxJoW2k6i)2UYsGyjUuhC5fXwmjUAjCizMqm9CRhywvAjCizMSBsoG8fs7kBKa1)m1shQzQJbdpGaaG()v9DAvmCszWUj5uhzkzxqahaQ)FvFNwzknYfPoYuYUGaoaS(HY8)2NhPoYuYUGaUi1v34GIJapbjnncZbGBqVxLTwUwI8Blsq5QP023BbVYRv13PbUb9E1MUcDUSBsov9DAGBqVxHuwIosTfjOC1uAv9DAaNmbGnO3R0sy9)zQahbsnDinebtXraNmbG6hQtCrQJ8hvgK9Iaw)qD5O6i)rLbzViGNGKMgH5aWnO3RYwlxlr(TfjOC1uA77TGx51Q670a3GEVAtxHox2njNQ(onWnO3RqklrhP2IeuUAkTQ(onGac5u0r(DXnUgDGTv0r(TDLLaXsCPo4YlITysC1s4qYmHy65Yx9aZQslHdjZKDtYbCd69kTew)FMkWriN8qEieZJ6SCizoBKqSOJ8BiELLaIDY1cI3eeFsdXPhri2uAKlYOy4KYaelhbXFdX6kIq8jijiolq8MwVdeZlhreID305cILUcXzRLRLi)gILJG4670qS0vi29huwIosneJeuUAkneVb9EiolqC)bel6iNjfeZJEqC6reIDi3XrqC2qS5)TRSHy)FMqS0viUa2(8iiolq8r(JkdYEricX8OheNEi2HG4bzMG4yGGyEujgG4fHK6QCgcXK7dmhhPkIqCmqqCL2GEpeVY2fvH44H4mG4SaX9hqm4OIh9G40dXoK74ii2LHxknelDfIDNnhFh6G493viw))Q(oneNfigCeILUcXutMjvGy5iiEtR3bINcri(pio9qSd5oocI5proeqSxiiw6keZd(987IGyDfIZcedoQGCk6i)U4gxJoW2k6i)2UYsGyjUuhC5fXwmjUVZYHKzcX0ZTEGzv9olhsMj7MKdiFH0UYgjWnO3RYwlxlr(TfjOC1uA77TGx51Q670a3GEVAtxHox2njNQ(onqaaq))Q(oTkgoPmy3KCQJmLSliGda1)VQVtRmLg5IuhzkzxqahaUb9Efszj6i1wKGYvtPv13PbCYea2GEVY8)2v2w)FMkWrG1pufW2NhPoYFuzq2lcWjta4aBY)hss9smyFVngilTQ0zRhywvK7dmhhPkq(2GEV6LyW(EBmqwAvPZwpWSQahbCYea0)m1shQoroewVqa1)VQVtR0Fp)UiBmq2YyEzuuhzkzxMMlVaciKtrh53f34A0b2wrh532vwcelXL6GlVi2IjX9DwoKmtiMEU8vpWSQENLdjZKDtYbCd69kZ)BxzB9)zQahHCYdHyeApe7qUJJGybI7e5q4fcILUcXoeex)2DeqSJ0behpeRLWHKzYO3z5qYmHielDfIDiiEqMjiEllP1KrE6KfelEF2zyiehYI6GQicX84gOMMPdI1Fp)UiiwxH4SaXGJqSdbXfNm0dqC2XdXI3NDggcX()mH44HyTuciodeH4b6ii28)2v2qS)ptfKtrh53f34A0b2wrh532vwceBXK4(6VNFxeIPNBHIiBKfvzi9H1)Nv)987IacaaHSOouBzjTMSI3NDggQOw2lQciqa4REGzvPLWHKzYUj5aeia8vpWSQENLdjZKDtYbiqa0)m1shQoroewVqa1)VQVtR0Fp)UiBmq2YyEzuuhzkzxMMlVaciKtEieJq7HyhYDCeelqCNihcVqqS0vi2HG463UJaIDKoG44HyTeoKmtg9olhsMjeHyPRqSdbXdYmbXBzjTMmYtNSGyX7ZoddH4qwuhufriMh3a10mDqS(753fbX6keNfigCeIDiiU4KHEaIZoEiw8(SZWqi2)NjehpeRLsaXzGiepqhbXAj8)zcX()mvqofDKFxCJRrhyBfDKFBxzjqSftIRw)987Iqm9CluezJSOkdPpS()S6VNFxeqaaiKf1HYtNSSI3NDggQOw2lQciqa4REGzvPLWHKzYUj5aeia8vpWSQENLdjZKDtYbiqa0)m1shQoroewVqa1)VQVtR0Fp)UiBmq2YyEzuuhzkzxMMlVaciKtrh53f34AKwwlROJ8B7klbITysCnZirkr(nKtrh53f34A0b2wrh532vwceBXK4Uj5GCc5u0r(DrTj54Uj5S()mrm9C5Bd69QnjN1)NPcCeYPOJ87IAtY5gxJgi5c77TXazDYvfX0ZnKf1HAGKlSV3gdK1jxvf1YErvGaeYI6qTLL0AYkEF2zyOIAzVOkGqofDKFxuBso34AK5)TppcrTH6fzd5qsrHlViMEUaaaFrQDLnsGrAs24T1KqaVtbCd69kKYs0rQTibLRMsRahbCYeaoYFuzq2lcyKMKnEBnjeW7ua3GEVcPSeDKAlsq5QP0kWrabeOOJCMSutMjvMgHa5u0r(DrTj5CJRrM)3(8ie1gQxKnKdjffU8Iy65caa8fP2v2ibgPjzJ3wtcb8ofGtMaWr(JkdYEraJ0KSXBRjHaENcqabk6iNjl1KzsLPriqofDKFxuBso34A0jZu)GfR)O2DBiKtrh53f1MKZnUgbwiBgKjITysC5X(aSrs5D2kvISnSy1YAHy65Q)zQLouZuhdgEqofDKFxuBso34AeyHSzqMiwwFWnUSDrbViMEU8Tb9E149olf4iq9ptT0HAM6yWWdYPOJ87IAtY5gxJalKndYeXY6dUXLTlkMcX0ZLVnO3RgV3zPahbQ)zQLouZuhdgEqofDKFxuBso34A04h53iMEU6FMAPd1m1XGHhWnO3RYwlxlr(T6itj7cc4ofcdCd69QS1Y1sKFRoYuYUmn3P4iKtrh53f1MKZnUgP)E(Dr2yGSLX8YOGy65Yx9aZQslHdjZKDtYbKV6bMv17SCizMSBsoiNIoYVlQnjNBCnAtxHox2njhIPNlaBqVxDYm1pyX6pQD3gQahNmHp9ptT0HAM6yWWdqiNIoYVlQnjNBCnkBTCTe53iMEUaSb9E1jZu)GfR)O2DBOcCCYe(0)m1shQzQJbdpaHCk6i)UO2KCUX1OnDf6CLnsetpxa2GEVAtxHox2njNcCCYKnO3RYwlxlr(TfjOC1uA77TGx51kWraHCk6i)UO2KCUX1iYC8DOZU)Uc5u0r(DrTj5CJRrsvgJCMSfh5mrm9CbGV6hkPkJrot2IJCM2QykijvKAxzJeiFIoYVvsvgJCMSfh5mTvXuqsQST(vICiacaF1pusvgJCMSfh5mTdKSurQDLnYjtQFOKQmg5mzloYzAhizPoYuYUGaEc4Kj1pusvgJCMSfh5mTvXuqsQsiAxtZtG1pusvgJCMSfh5mTvXuqsQJmLSltZrG1pusvgJCMSfh5mTvXuqsQi1UYgjGqofDKFxuBso34AK5)TppcX0ZDd69kKYs0rQTibLRMsRahbk6iNjl1KzsLP5jKtrh53f1MKZnUgfdNugSBsoe1gQxKnKdjffU8Iy65EK)OYGSx0Kj1puXWjLb7MKtvcr7AAEozca1puXWjLb7MKtvcr7AAeg4b2K)pKKAb69s2EWcvTK5(enPi3hyoosvaNmr0rotwQjZKkiGlcpzYg07vB6k05YUj5uGJa3GEVAtxHox2njN6itj7Y0CrQRUXbfhHCk6i)UO2KCUX1itPrUietp3tqsQk5tDgiGxoaSqrKnYIYuAKlYA(hb5u0r(DrTj5CJRr(fvg0N4detp3YdU2zxvJGLaCrw6ahJ8Bf1YErvGaaG()v9DAvmCszWUj5uhzkzxqahaQ)FvFNwzknYfPoYuYUGaoaiqaQFOm)V95rQJmLSliGlpbeiaBqVxLTwUwI8Blsq5QP023BbVYRv13PbUb9E1MUcDUSBsov9DAGBqVxHuwIosTfjOC1uAv9DAabCYKYdU2zxvZ)sICr2YVMPouul7fvrm7GUdCmSPPjvtjiU8Iy2bDh4yyrU(TS4YlIzh0DGJHn9Clp4ANDvn)ljYfzl)AM6aia6)x13PvXWjLb7MKtDKPKDbbCaO()v9DALP0ixK6itj7cc4aGqofDKFxuBso34AuXjhjetp3nO3RYwlxlr(TfjOC1uA77TGx51Q670a3GEVAtxHox2njNQ(onqrh5mzPMmtQGaUimKtrh53f1MKZnUgzkGletpxa2GEVkBTCTe53kWrabk6iNjl1KzsLP55KjaSb9Ev2A5AjYVvGJacu0rotwQjZKktZtGaSb9Ev8FmyLUA1lXrvcr7cbCNcWjtayd69Q4)yWkD1QxIJcCe4g07vX)XGv6QvVeh1rMs2LP5vXraNmbGnO3RkYSGKS63ClH0HQeI2fc4YtaNmzd69QnDf6Cz3KCkWrGIoYzYsnzMuzAEc5u0r(DrTj5CJRrMc4cX0ZfGnO3RkYSGKS63ClH0HQeI2fc4YlGabyd69Q4)yWkD1QxIJcCeqGBqVxLTwUwI8Bf4iqrh5mzPMmtQWDkiNIoYVlQnjNBCnYuAKlcX0ZDd69QS1Y1sKFRahbk6iNjl1KzsLP5YtiNIoYVlQnjNBCnYuaxiMEUaaaaBqVxf)hdwPRw9sCuLq0Uqa3PaCYea2GEVk(pgSsxT6L4OahbUb9Ev8FmyLUA1lXrDKPKDzAEvCeWjtayd69QImlijR(n3siDOkHODHaU8eqabk6iNjl1KzsLP5jGqofDKFxuBso34AumCszWUj5qm9CfDKZKLAYmPcc4fYPOJ87IAtY5gxJmLg5Iqm9CbaGtqst7U4aGafDKZKLAYmPY08eWjtaaGtqstZdWrabk6iNjl1KzsLP5jWqwuhQYdUSV3gdK1)hvcf1YErvaHCk6i)UO2KCUX1OrW1mDP7MquBOEr2qoKuu4YlIPNB9dvmCszWUj5uLq0UqWuqofDKFxuBso34AumCszWUj5GCk6i)UO2KCUX1itbCHy65k6iNjl1KzsLP5jKtrh53f1MKZnUgvCYrYUj5GCk6i)UO2KCUX1O8(2dEiMEUNGKuvYN6mMgH5aWnO3RY7Bp4PoYuYUmnhuCeYjKtrh53fLzgjsjYV5M33EWdX0ZnB9BMnsBvmfKKLJfeK33EWZwftbjzJHJkd)QcCd69Q8(2dEQJmLSltZt3PbPeeKtrh53fLzgjsjYVDJRrh1KJSqm9CdPDLnsGdKSIb1OoMgHWriNIoYVlkZmsKsKF7gxJ8h1U7KQ2JqsnDsKFJy65gs7kBKahizfdQrDmncHJqofDKFxuMzKiLi)2nUgrMJVdD293vetpxa4REGzvPLWHKzYUj5aYx9aZQ6DwoKmt2njhGtMi6iNjl1KzsfeWDkiNIoYVlkZmsKsKF7gxJ2Y5Q4kBetp3qAxzJe4ajRyqnQJPrO4iWS1Vz2iTvXuqswowqahu86onqYkguMI7b5u0r(DrzMrIuI8B34Aub8MZzzzZUezRJcIPN7g07vfWBoNLLn7sKTokQ670a3GEVAlNRIRSv13PboqYkguJ6yAechaMT(nZgPTkMcsYYXcc4GAko6onqYkguMI7b5eYPOJ87Is))Q(oDH74h53qofDKFxu6)x13PlUX1O96)Q1dEgc5u0r(DrP)FvFNU4gxJ20vOZv2iHCk6i)UO0)VQVtxCJRrYPLMSXFh1bKtrh53fL()v9D6IBCnALihIILhdSI0K6aYPOJ87Is))Q(oDXnUg5ZJ2R)RqofDKFxu6)x13PlUX1iP1ujozz1YAb5u0r(DrP)FvFNU4gxJ2xwIv2iTEWdX0ZDd69QnjN1)NPcCeYPOJ87Is))Q(oDXnUgLTwUwI8BetpxaQFOm)V95rQi1UYg5KjIoYzYsnzMubb8ciW6hQy4KYGDtYPIu7kBKqofDKFxu6)x13PlUX1OnDf6Cb5u0r(DrP)FvFNU4gxJalKndYerY7jDyBXK4QnuV(4(o129skbKtrh53fL()v9D6IBCncSq2miZcKtiNIoYVlkTeoKmtChi5c77TXazDYvfX0ZnKf1HAGKlSV3gdK1jxvf1YErvG8Tb9E1ajxyFVngiRtUQkWrG8Tb9ELwcR)ptf4iKtrh53fLwchsMj34A049oliNIoYVlkTeoKmtUX1iTew)FMiMEU8Tb9ELwcR)ptf4iKtrh53fLwchsMj34A0jUietp3nO3RgV3zPahHCk6i)UO0s4qYm5gxJgi5c77TXazDYvfX0ZnKf1HAGKlSV3gdK1jxvf1YErvG8Tb9E1ajxyFVngiRtUQkWriNIoYVlkTeoKmtUX1iYC8DOZU)UIy65wpWSQ0s4qYmz3KCqofDKFxuAjCizMCJRrN4Iqm9CRFOoXfPoYFuzq2lAYeQPdPHtJWCeYPOJ87IslHdjZKBCn6Yretp36hQlhvh5pQmi7fbu)M73o(zhfeWfHHCk6i)UO0s4qYm5gxJ0Fp)UiBmq2YyEzuqm9CRhywvAjCizMSBsoiNIoYVlkTeoKmtUX1ipDVoFWIDNbHOP4EwQPdPHC5fX0Zv)M73o(zhfeWfHbsnDinebCKdqofDKFxuAjCizMCJRrsvgJCMSfh5mrm9CbGV6hkPkJrot2IJCM2QykijvKAxzJeiFIoYVvsvgJCMSfh5mTvXuqsQST(vICiacaF1pusvgJCMSfh5mTdKSurQDLnYjtQFOKQmg5mzloYzAhizPoYuYUGaEc4Kj1pusvgJCMSfh5mTvXuqsQsiAxtZtG1pusvgJCMSfh5mTvXuqsQJmLSltZrG1pusvgJCMSfh5mTvXuqsQi1UYgjGqofDKFxuAjCizMCJRr(fvg0N4detp3YdU2zxvJGLaCrw6ahJ8Bf1YErvGuthsdNMNCCYKYdU2zxvZ)sICr2YVMPouul7fvrm7GUdCmSPPjvtjiU8Iy2bDh4yyrU(TS4YlIzh0DGJHn9Clp4ANDvn)ljYfzl)AM6ai10H0WP5jhHCk6i)UO0s4qYm5gxJko5ib5u0r(DrPLWHKzYnUgDIlcX0Z9i)rLbzViG63C)2Xp7OmnhHCk6i)UO0s4qYm5gxJkdhvrm9C1V5(TJF2rzAoc5eYPOJ87IsR)E(DrChi5c77TXazDYvfX0ZnKf1HAGKlSV3gdK1jxvf1YErvG8Tb9E1ajxyFVngiRtUQkWrG8Tb9ELwcR)ptf4iKtrh53fLw)987ICJRrAjS()mrm9C5Bd69kTew)FMkWriNIoYVlkT(753f5gxJ0Fp)UiBmq2YyEzuGCc5u0r(Dr96VNFxe3bsUW(EBmqwNCvrm9CdzrDOgi5c77TXazDYvvrTSxufiFBqVxnqYf23BJbY6KRQcCeiFBqVxz(F7kBR)ptf4iKtrh53f1R)E(DrUX1iZ)BxzB9)zIy65Y3g07vM)3UY26)Zuboc5u0r(Dr96VNFxKBCns)987ISXazlJ5LrbX0ZT8GRD2vLpVsylXLUif1YErvGBqVx5ZRe2sCPlsboc5u0r(Dr96VNFxKBCns)987ISXazlJ5LrbX0Z9aBY)hssTiKI2q77TXazllIgPtrUpWCCKQqofDKFxuV(753f5gxJkHC(8ietpxsVYXcPK2qBtUxmzcPx5yHuLFjNTj3lGCk6i)UOE93ZVlYnUg5CsmGy65s6vowiL0gABY9Ijti9khlKAb2YzBY9ciNIoYVlQx)987ICJRr6VNFxKngiBzmVmkqoHCk6i)UOENLdjZe3bsUW(EBmqwNCvrm9CdzrDOgi5c77TXazDYvvrTSxufiFBqVxnqYf23BJbY6KRQcCeiFBqVxz(F7kBR)ptf4iKtrh53f17SCizMCJRrM)3UY26)ZeX0ZLVnO3Rm)VDLT1)NPcCeYPOJ87I6DwoKmtUX1Osixb8qsqofDKFxuVZYHKzYnUgP)E(Dr2yGSLX8YOGy65EGn5)djPwesrBO992yGSLfrJ0Pi3hyoosviNIoYVlQ3z5qYm5gxJ0Fp)UiBmq2YyEzuqm9Clp4ANDv5ZRe2sCPlsrTSxufYPOJ87I6DwoKmtUX1iYC8DOZU)UIy65wpWSQENLdjZKDtYb5u0r(Dr9olhsMj34AKuLXiNjBXrotetpxa4R(HsQYyKZKT4iNPTkMcssfP2v2ibYNOJ8BLuLXiNjBXrotBvmfKKkBRFLihcGaWx9dLuLXiNjBXrot7ajlvKAxzJCYK6hkPkJrot2IJCM2bswQJmLSliGNaozs9dLuLXiNjBXrotBvmfKKQeI2108ey9dLuLXiNjBXrotBvmfKK6itj7Y0Cey9dLuLXiNjBXrotBvmfKKksTRSrciKtrh53f17SCizMCJRrfW2NhHO2q9ISHCiPOWLxetp3J8hvgK9IGCk6i)UOENLdjZKBCnY8)2NhHO2q9ISHCiPOWLxetp3J8hvgK9IMmzd69kKYs0rQTibLRMsRahHCk6i)UOENLdjZKBCnQeY5ZJqm9C1)m1shQoroewVqaj9khlKsAdTn5EbKtrh53f17SCizMCJRroNediMEU8P)zQLouDICiSEHas6vowiL0gABY9ciNIoYVlQ3z5qYm5gxJ0Fp)UiBmq2YyEzuqm9Cbyd69ksVYXczxGTCkWXjt2GEVI0RCSq2YVKtbociKtrh53f17SCizMCJRrLqoFEeIPNlaKELJfsLTDb2YnzcPx5yHuLFjNTj3laCYeai9khlKkB7cSLd4g07vLqUc4HKSK547qNj1HDb2YPahbeYPOJ87I6DwoKmtUX1iNtIbgAzK0m(5LdimlybJb]] )


end