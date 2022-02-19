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
            elseif k == "lunar_inspiration" then return debuff.moonfire_cat
            elseif debuff[ k ] ~= nil then return debuff[ k ]
            end
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
                addStack( "lunar_empowerment" )
                addStack( "solar_empowerment" )
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

    spec:RegisterPack( "Guardian", 20211123, [[dCeL8bqiPsEekjSjLQpjvkzukfNsj1QKkLYRKkAwGQUfOsKDrYVOuAyOK6yOqltPupdLQMgOsDnuQSnqL03KkvACOKiNdujSoqLOmpLsUhkAFGkoikjQSqPcpeLKyIGkr1fLkLQpIsIYjLkfTsuIzIssQBIsIQ2jkLFIss1tHQPsP4ROKKSxu9xkgmKdtSyqEmPMSuUmYMPYNbLrtvDArRgLKYRPunBjUnvz3k(nWWLQoUuPWYv55sA6cxhkBxj(oLmEPsvNhfSEPsfZxjz)QAoJCB44njioBBZ6TzKrg3M9QT3M1WvgzhhpyON449I2UaJ44J4rCCwzyY1sz449cdfG042WXRaSttCC)i6RWLzRTWYWhdsPbE2wtpSIejy0N4cBRPN2wooewwIU5WH44njioBBZ6TzKrg3M9QT3M1WvgHBoUGf(GJJJNESkCC)S1OHdXXBuvZXzLHjxlL5rWLFyz7zHnWc5br3JyK9W)OTz92m(S8SWQ4ldmQcx2ZcCPh1nhn46bNe0JyvKWww5bGXEopQ)sWLrs1hTjDpQsrKdShL1hP9jTDQTw9Sax6rDZrdUEWjb9iqFKG5rb4rv)0fpAd4E0aI1pcICGJEeRcywa2jfhVK1OYTHJxyqlNa42WzJrUnCCrhjy44EaWyphJdCECCAeOc14DWdEWXHi542WzJrUnCCAeOc14DWX1xg0LchVRhbH5CkisoJdCEkSEoUOJemCCisoJdCE8GZ22CB440iqfQX7GJRVmOlfoEifAcLpjxyaot4tgRS0u0iqfQ9O9hT5rHuOjuqsrgnzeNlNmyqrJavO2Jw)O9hPbl0itOwOj8z444IosWWX9j5cdWzcFYyLLgp4SXEUnCCAeOc14DWXfDKGHJ7baJlpIJRVmOlfo(MhT5rD9Oi12Zb2J2FuKEKjaMwspcopIXTF0(JGWCofmPi6i1gyyY1szuy9pA9JwT6rBE0rUJQ(cuHE0(JI0JmbW0s6rW5rmU9J2FeeMZPGjfrhP2adtUwkJcR)rRF0AoUMbDHmHCWOOYzJrEWzdU52WXPrGkuJ3bhx0rcgoUhamU8ioU(YGUu44BE0Mh11JIuBphypA)rr6rMayAj9i48ig3(rRF0QvpAZJoYDu1xGk0J2FuKEKjaMwspcopIXTF06hTMJRzqxitihmkQC2yKhC2yh3goUOJemC8twObGvnUJMUddCCAeOc14DWdoBWvUnCCAeOc14DWXfDKGHJZQbcSbgL3zAunYHHQrlLchxFzqxkCCnyHgzc1cnHpdhhFepIJZQbcSbgL3zAunYHHQrlLcp4S1D52WXPrGkuJ3bhx0rcgoEC5yNcg546ld6sHJ31JGWCov)bSkkS(hT)inyHgzc1cnHpdhhVwabhpUCStbJ8GZgRe3gooncuHA8o44IosWWXJlh7uSnhxFzqxkC8UEeeMZP6pGvrH1)O9hPbl0itOwOj8z4441ci44XLJDk2MhC2Gl42WXPrGkuJ3bhxFzqxkCCnyHgzc1cnHpd3J2FeeMZPYrl3ircg1rEso1hbhMpAB4(r7pccZ5u5OLBKibJ6ipjN6J2I5J2MDCCrhjy449Gibdp4SXiR52WXPrGkuJ3bhxFzqxkC8UEu7WYMslHfjlKbIK7r7pQRh1oSSPawflswidejhhx0rcgoUgmla7Kj8jtTpVmQ8GZgJmYTHJtJavOgVdoU(YGUu44BEeeMZPozHgaw14oA6omOW6F0QvpQRhPbl0itOwOj8z4E0AoUOJemCCi6Q0zNhC2yCBUnCCAeOc14DWX1xg0LchFZJGWCo1jl0aWQg3rt3Hbfw)JwT6rD9inyHgzc1cnHpd3JwZXfDKGHJNJwUrIem8GZgJSNBdhNgbQqnEhCC9LbDPWX38iimNtbrxLo7gisofw)JwT6rqyoNkhTCJejymWWKRLYyaod2vbAfw)JwZXfDKGHJdrxLo75aJhC2yeU52WXPrGkuJ3bhxFzqxkC8npQRh1aHsAsFKlKPAjNNPjEcmsfP2EoWE0(J66rIosWOKM0h5czQwY5zAINaJu5yCLeMF8O9hT5rD9Ogiust6JCHmvl58m(KuurQTNdShTA1JAGqjnPpYfYuTKZZ4tsrDKNKt9rW5rS)rRF0QvpQbcL0K(ixit1soptt8eyKQgI2(J26rS)r7pQbcL0K(ixit1soptt8eyK6ipjN6J26rS7r7pQbcL0K(ixit1soptt8eyKksT9CG9O1CCrhjy44st6JCHmvl584bNngzh3gooncuHA8o446ld6sHJdH5Ckysr0rQnWWKRLYOW6F0(JeDKlKHgYlP6J26rSNJl6ibdh3dagxEep4SXiCLBdhNgbQqnEhCCrhjy44H)jvFdejhhxFzqxkC8JChv9fOc9OvREudeQW)KQVbIKtvdrB)rB9i2)OvRE0Mh1aHk8pP6BGi5u1q02F0wpcUF0(JoSHCGdgPkyoNKJdRsnd5bDIMuu3al77P2Jw)OvREKOJCHm0qEjvFeCy(i4(rRw9iimNtbrxLo7gisofw)J2FeeMZPGORsNDdejN6ipjN6J2I5JGPBpQZhXAf744Ag0fYeYbJIkNng5bNng7UCB440iqfQX7GJRVmOlfo(jWivJCPoJhbNhXiRF0(JQue5aRQ8KbwHmEGJ44IosWWX9KbwH4bNngzL42WXPrGkuJ3bhxFzqxkC8kaRaLtt1JvdSczOdRpsWOOrGku7r7pAZJ28inauAaRrf(Nu9nqKCQJ8KCQpcopI1pA)rAaO0awJYtgyfsDKNKt9rW5rS(rRF0(J28OgiuEaW4YJuh5j5uFeCy(i2)O1pA)rBEeeMZPYrl3ircgdmm5APmgGZGDvGw1awZJ2FeeMZPGORsNDdejNQbSMhT)iimNtbtkIosTbgMCTugvdynpA9Jw)OvREufGvGYPPwafjYczQGYcnHIgbQqnoEobDhwFyshhVcWkq50ulGIezHmvqzHMyFJgaknG1Oc)tQ(giso1rEsov4W6DnauAaRr5jdScPoYtYPchwVMJNtq3H1hM0ZJAPeehNroUOJemCCxHQ(6tCbhpNGUdRpmWkaiPWXzKhC2yeUGBdhNgbQqnEhCC9LbDPWXHWCovoA5gjsWyGHjxlLXaCgSRc0QgWAE0(JGWCofeDv6SBGi5unG18O9hj6ixidnKxs1hbhMpcU54IosWWXRwzpzGi54bNTTzn3gooncuHA8o446ld6sHJdH5CQC0YnsKGrH1)O9hj6ixidnKxs1hT1Jy)J2F0MhbH5CQaacFJmnJUiwQAiA7pcomF02pA9JwT6rBEeeMZPcai8nY0m6IyPW6F0(JGWCovaaHVrMMrxel1rEso1hT1JyuXUhT(rRw9OnpccZ5uvzrGrgnWdsczcvneT9hbhMpI9pA9JwT6rqyoNcIUkD2nqKCkS(hT)irh5czOH8sQ(OTEe754IosWWX9eScp4STnJCB440iqfQX7GJRVmOlfo(MhbH5CQQSiWiJg4bjHmHQgI2(JGdZhX4Jw)O9hT5rqyoNkaGW3itZOlILcR)rRF0(JGWCovoA5gjsWOW6F0(JeDKlKHgYlP6Jy(OT54IosWWX9eScp4ST92CB440iqfQX7GJRVmOlfooeMZPYrl3ircgfw)J2FKOJCHm0qEjvF0wmFe754IosWWX9KbwH4bNTTzp3gooncuHA8o446ld6sHJV5rBE0MhbH5CQaacFJmnJUiwQAiA7pcomF02pA9JwT6rBEeeMZPcai8nY0m6IyPW6F0(JGWCovaaHVrMMrxel1rEso1hT1JyuXUhT(rRw9OnpccZ5uvzrGrgnWdsczcvneT9hbhMpI9pA9Jw)O9hj6ixidnKxs1hT1Jy)JwZXfDKGHJ7jyfEWzBB4MBdhNgbQqnEhCC9LbDPWXfDKlKHgYlP6JGZJyKJl6ibdhp8pP6BGi54bNTTzh3gooncuHA8o446ld6sHJV5rBE0jWOhT1JGly9Jw)O9hj6ixidnKxs1hT1Jy)Jw)OvRE0MhT5rNaJE0wpIvIDpA9J2FKOJCHm0qEjvF0wpI9pA)rHuOjuvawXaCMWNmoWr1qrJavO2JwZXfDKGHJ7jdScXdoBBdx52WXPrGkuJ3bhx0rcgoEpwzHUS7qCC9LbDPWXBGqf(Nu9nqKCQAiA7pcopABoUMbDHmHCWOOYzJrEWzB7Ul3goUOJemC8W)KQVbIKJJtJavOgVdEWzBBwjUnCCAeOc14DWX1xg0Lchx0rUqgAiVKQpARhXEoUOJemCCpbRWdoBBdxWTHJl6ibdhVAL9KbIKJJtJavOgVdEWzJ9SMBdhNgbQqnEhCC9LbDPWXpbgPAKl1z8OTEeCZ6hT)iimNtLhyCyN6ipjN6J26rSwXooUOJemC88aJd74bp44EzKWKibd3goBmYTHJtJavOgVdoU(YGUu445ObE5aZ0epbgzyx9rW5r5bgh2zAINaJmH)rvFqP9O9hbH5CQ8aJd7uh5j5uF0wpI9pQB7r(snioUOJemC88aJd74bNTT52WXPrGkuJ3bhxFzqxkC8qg75a7r7pYNKs4R61XJ26rWv2XXfDKGHJF0qwsHhC2yp3gooncuHA8o446ld6sHJhYyphypA)r(KucFvVoE0wpcUYooUOJemCC3rt3jPM5iy0qNejy4bNn4MBdhNgbQqnEhCC9LbDPWX38OUEu7WYMslHfjlKbIK7r7pQRh1oSSPawflswidej3Jw)OvREKOJCHm0qEjvFeCy(OT54IosWWXjVEGfDgiW04bNn2XTHJtJavOgVdoU(YGUu44Hm2Zb2J2FKpjLWx1RJhT1J6US7r7pkhnWlhyMM4jWid7QpcopI1kgFu32J8jPe(kpP754IosWWXHKZE1Eo8GZgCLBdhNgbQqnEhCC9LbDPWXHWCovf7wYfPyYPg5OJQQbSMhT)iimNtbjN9Q9CunG18O9h5tsj8v964rB9i4kRF0(JYrd8YbMPjEcmYWU6JGZJyTAB29OUTh5tsj8vEs3ZXfDKGHJxXULCrkMCQro6OYdEWX7psd8GKGBdNng52WXPrGkuJ3bhVrv9L9rcgoE3E3tASGApcICGJEKg4bjXJGiy5uvpIvoTM6J6JgWaxYxophw5rIosWuFeykmO44IosWWXTNt7OMP2NxgvEWzBBUnCCAeOc14DWX1xg0LchpKcnHYNKlmaNj8jJvwAkAeOc1E0(J28O2HLnLwclswidej3J2FeeMZP0syCGZtH1)OvREu7WYMcyvSizHmqKCpA)rqyoNYdag75yCGZtH1)OvREeeMZP8aGXEogh48uy9pA)rHuOjuqsrgnzeNlNmyqrJavO2JwZXfDKGHJ7tYfgGZe(KXklnEWzJ9CB440iqfQX7GJRVmOlfooeMZP0syCGZtH1)O9h1oSSP0syrYczGi544IosWWX7pGvHhC2GBUnCCAeOc14DWX1xg0LchVRhbH5CkzyW4aNNcR)r7pAZJ28OUEu7WYMcyvSizHmqKCpA)rD9O2HLnLwclswidej3Jw)O9hT5rD9inyHgzc1KW8dJtOhT(rRF0QvpAZJ28OUEu7WYMcyvSizHmqKCpA)rD9O2HLnLwclswidej3Jw)O9hT5rAWcnYeQjH5hgNqpA)rHuOjuhvdWjrcgJ4C5KbdkAeOc1E06hTMJl6ibdhhIKZ4aNhp4SXoUnCCAeOc14DWX1xg0LchhcZ5uEaWyphJdCEkS(hT)O2HLnfWQyrYczGi5E0(J66rAWcnYeQjH5hgNqCCrhjy44wNe(8GZgCLBdhNgbQqnEhCC9LbDPWXHWCoLham2ZX4aNNcR)r7pQDyztbSkwKSqgisUhT)inyHgzc1KW8dJtioUOJemC8AiNlpIhC26UCB440iqfQX7GJRVmOlfoEfGvGYPP6XQbwHm0H1hjyu0iqfQ9OvREufGvGYPPwafjYczQGYcnHIgbQqnoEobDhwFyshhVcWkq50ulGIezHmvqzHMGJNtq3H1hM0ZJAPeehNroUOJemCCxHQ(6tCbhpNGUdRpmWkaiPWXzKh8GJxyqlNO52WzJrUnCCrhjy44AjmoW5XXPrGkuJ3bp4bhVrobReCB4SXi3gooncuHA8o44nQQVSpsWWX727EsJfu7r0cDm8Oi9Ohf(0JeDaUhL1hjlsweOcP44IosWWXR2XkfdKu95bNTT52WXPrGkuJ3bhx0rcgooRgiWgyuENPr1ihgQgTukCC9LbDPWX76rqyoNQ)awffw)J2FuxpsdwOrMqTqt4ZWXXhXJ44SAGaBGr5DMgvJCyOA0sPWdoBSNBdhNgbQqnEhCCrhjy44XLJDkyKJRVmOlfoExpccZ5u9hWQOW6F0(J66rAWcnYeQfAcFgooETacoEC5yNcg5bNn4MBdhNgbQqnEhCCrhjy44XLJDk2MJRVmOlfoExpccZ5u9hWQOW6F0(J66rAWcnYeQfAcFgooETacoEC5yNIT5bNn2XTHJtJavOgVdoU(YGUu44D9inyHgzc1cnHpd3J2F0MhT5rBEuifAcLpjxyaot4tgRS0u0iqfQ9O9hbH5CkFsUWaCMWNmwzPPW6F06hT)OnpQDyztPLWIKfYarY9OvREu7WYMcyvSizHmqKCpA9J2FuxpccZ5u9hWQOW6F06hTA1J28OnpccZ5uq0vPZUbIKtH1)OvREeeMZPYrl3ircgdmm5APmgGZGDvGwH1)O1pA)rBEuxpQDyztPLWIKfYarY9O9h11JAhw2uaRIfjlKbIK7rRF06hTMJl6ibdhVhejy4bNn4k3gooncuHA8o446ld6sHJ3oSSP0syrYczGi5E0(J66rAWcnYeQfAcFgUhT)iimNtLJwUrIemgyyY1szmaNb7QaTQbSMhT)iimNtbrxLo7gisovdynpA)rBE0MhPbGsdynQW)KQVbIKtDKNKt9rW5rS(r7psdaLgWAuEYaRqQJ8KCQpcopI1pA)rnqO8aGXLhPoYtYP(i4W8rW0Th15JyTIDpA)rNaJE0wpcUz9J2FeeMZPYrl3ircgdmm5APmgGZGDvGw1awZJ2FeeMZPGORsNDdejNQbSMhT)iimNtbtkIosTbgMCTugvdynpA9JwT6rBEeeMZP0syCGZtH1)O9hrdDWy4rW5rBZUhT(rRw9OnpQbc1j2j1rUJQ(cuHE0(JAGqDzV6i3rvFbQqpA9JwT6rBE0HnKdCWifqcFdWzcFYqLgDM2HLnf1nWY(EQ9O9h11JGWCofqcFdWzcFYqLgDM2HLnfw)J2F0MhbH5CkTegh48uy9pA)r0qhmgEeCE02S(rRF0(JGWCoLpjxyaot4tgRS0uh5j5uF0wmFeJS(rRF0QvpAZJ0GfAKju2z4szE0(J0aqPbSgf51dSOZabMM6ipjN6J2I5Jy8r7ps0rUqgAiVKQpARhT9Jw)OvRE0MhbH5CkFsUWaCMWNmwzPPW6F0(JOHoym8i48i4cw)O1pAnhVgxQdoBmYXfDKGHJFyJr0rcgtjRbhVK1WmIhXX1syrYcXdoBDxUnCCAeOc14DWX1xg0LchVDyztPLWIKfYarY9O9hPbl0itOwOj8z4E0(J28OnpsdaLgWAuH)jvFdejN6ipjN6JGZJy9J2FKgaknG1O8KbwHuh5j5uFeCEeRF0(JAGq5baJlpsDKNKt9rWH5JGPBpQZhXAf7E0(Jobg9OTEeCZ6hT)iimNtLJwUrIemgyyY1szmaNb7QaTQbSMhT)iimNtbrxLo7gisovdynpA)rqyoNcMueDKAdmm5APmQgWAE0(Jobg9OTEeCZ6hT)iimNtLJwUrIemgyyY1szmaNb7QaTQbSMhT)iimNtbrxLo7gisovdynpA)rqyoNcMueDKAdmm5APmQgWAE06hTA1J28iimNtPLW4aNNcR)r7pIg6GXWJGZJ2MDpA9JwT6rBEudeQtStQJChv9fOc9O9h1aH6YE1rUJQ(cuHE0(Jobg9OTEeCZ6hT)iimNtLJwUrIemgyyY1szmaNb7QaTQbSMhT)iimNtbrxLo7gisovdynpA)rqyoNcMueDKAdmm5APmQgWAE06hTMJxJl1bNng54IosWWXpSXi6ibJPK1GJxYAygXJ44AjSizH4bNnwjUnCCAeOc14DWX1xg0LchVRh1oSSP0syrYczGi5E0(JGWCoLwcJdCEkSEoEnUuhC2yKJl6ibdh)WgJOJemMswdoEjRHzepIJRLWIKfIhC2Gl42WXPrGkuJ3bhxFzqxkC82HLnfWQyrYczGi5E0(J28OnpsdaLgWAuH)jvFdejN6ipjN6JGZJy9J2FKgaknG1O8KbwHuh5j5uFeCEeRF0(Jobg9OTEeJS7r7pccZ5u5OLBKibJQbSMhT)iimNtbrxLo7gisovdynpA)rqyoNcMueDKAdmm5APmQgWAE06hTA1J28iimNt5baJ9CmoW5PW6F0(JAGqvXgxEK6i3rvFbQqpA9JwT6rBEeeMZP8aGXEogh48uy9pA)rqyoNYNKlmaNj8jJvwAkS(hT(rRw9Onp6WgYboyKciHVb4mHpzOsJot7WYMI6gyzFp1E0(J66rqyoNciHVb4mHpzOsJot7WYMcR)rRF0QvpAZJ0GfAKjutcZpmoHE0(J0aqPbSgLgmla7Kj8jtTpVmQQJ8KCQpAlMpIXhT(rRw9OnpsdwOrMqzNHlL5r7psdaLgWAuKxpWIodeyAQJ8KCQpAlMpIXhT)irh5czOH8sQ(OTE02pA9JwZXRXL6GZgJCCrhjy44h2yeDKGXuYAWXlznmJ4rCCGvXIKfIhC2yK1CB440iqfQX7GJRVmOlfoExpQDyztbSkwKSqgisUhT)iimNt5baJ9CmoW5PW65414sDWzJroUOJemC8dBmIosWykzn44LSgMr8iooWQyrYcXdoBmYi3gooncuHA8o446ld6sHJ3oSSPawflswidej3J2FeeMZP8aGXEogh48uy9C8ACPo4SXihx0rcgo(HngrhjymLSgC8swdZiEehhyvSizH4bNng3MBdhNgbQqnEhC8gv1x2hjy44Dt3JSOh5ll0JyvZGwo5rfcgnn5y4ru3al77P2JKP9iiPiJMEK4C5KbdpsQpsEuifAIhzrpQALH2)r5eGh5baJ9CEKdCEpYYNgAHUhf(0JkmOLtEeeMZ9OS(ijEe4EeevawpA7hvjnhx0rcgo(HngrhjymLSgCC9LbDPWX38Onp6WgYboyKQWGwoPACfIICGzGvsV(kPOUbw23tThT(r7pAZJcPqtOGKImAYioxozWGIgbQqThT(r7pAZJGWCovHbTCs14kef5aZaRKE9vsH1)O1pA)rBEeeMZPkmOLtQgxHOihygyL0RVsQJ8KCQpAlMpA7hT(rR54LSgMr8ioEHbTCcGhC2yK9CB440iqfQX7GJ3OQ(Y(ibdhVB6EKf9iFzHEeRAg0YjpQqWOPjhdpI6gyzFp1EKmTh5OtkpsCUCYGHhj1hjpkKcnXJSOhvTYq7)OCcWJC0jLh5aN3JS8PHwO7rHp9OcdA5KhbH5CpkRpsIhbUhbrfG1J2(rvsZXfDKGHJFyJr0rcgtjRbhxFzqxkC8npAZJoSHCGdgPkmOLtQgxHOihygyL0RVskQBGL99u7rRF0(J28Oqk0ekhDsXioxozWGIgbQqThT(r7pAZJGWCovHbTCs14kef5aZaRKE9vsH1)O1pA)rBEeeMZPkmOLtQgxHOihygyL0RVsQJ8KCQpAlMpA7hT(rR54LSgMr8ioEHbTCIMhC2yeU52WXPrGkuJ3bhVrv9L9rcgoE309ilQBD0JKhnjm)Wj0JKP9il6rnW0TIhzjt8Oa8iTewKSq2cSkwKSqW)izApYIEKVSqpcskYOjBD0jLhjoxozWWJcPqtqn4FeRkFAOf6EKgmla70J0ThL1hH1)il6rvRm0(pkNa8iX5YjdgEKdCEpkapsl14rza)J8PJEKham2Z5roW5P44IosWWXpSXi6ibJPK1GJRVmOlfoELIihyvv1pDHXboJgmla70J2F0MhT5rHuOjuqsrgnzeNlNmyqrJavO2Jw)O9hT5rD9O2HLnLwclswidej3Jw)O9hT5rD9O2HLnfWQyrYczGi5E06hT)OnpsdwOrMqnjm)W4e6r7psdaLgWAuAWSaStMWNm1(8YOQoYtYP(OTy(igF06hTMJxYAygXJ44anywa2jEWzJr2XTHJtJavOgVdoEJQ6l7JemC8UP7rwu36OhjpAsy(HtOhjt7rw0JAGPBfpYsM4rb4rAjSizHSfyvSizHG)rY0EKf9iFzHEeKuKrt26OtkpsCUCYGHhfsHMGAW)iwv(0ql09inywa2PhPBpkRpcR)rw0JQwzO9Fuob4rIZLtgm8ih48EuaEKwQXJYa(h5th9iTeoW59ih48uCCrhjy44h2yeDKGXuYAWXRXL6GZgJCC9LbDPWXRue5aRQQ(PlmoWz0GzbyNE0(J28OnpkKcnHYrNumIZLtgmOOrGku7rRF0(J28OUEu7WYMslHfjlKbIK7rRF0(J28OUEu7WYMcyvSizHmqKCpA9J2F0MhPbl0itOMeMFyCc9O9hPbGsdynknywa2jt4tMAFEzuvh5j5uF0wmFeJpA9JwZXlznmJ4rCCTgmla7ep4SXiCLBdhNgbQqnEhCCrhjy44APumIosWykzn44LSgMr8ioUxgjmjsWWdoBm2D52WXPrGkuJ3bhx0rcgo(HngrhjymLSgC8swdZiEehhIKJh8GJRLWIKfIBdNng52WXfDKGHJ3FaRchNgbQqnEh8GZ22CB440iqfQX7GJRVmOlfoExpccZ5uAjmoW5PW654IosWWX1syCGZJhC2yp3gooncuHA8o446ld6sHJdH5CQ(dyvuy9CCrhjy44NyN4bNn4MBdhNgbQqnEhCC9LbDPWXdPqtO8j5cdWzcFYyLLMIgbQqThT)OUEeeMZP8j5cdWzcFYyLLMcRNJl6ibdh3NKlmaNj8jJvwA8GZg742WXPrGkuJ3bhxFzqxkC82HLnLwclswidejhhx0rcgoo51dSOZabMgp4Sbx52WXPrGkuJ3bhxFzqxkC8giuNyNuh5oQ6lqf6rRw9iAOdgdpARhb3SJJl6ibdh)e7ep4S1D52WXPrGkuJ3bhxFzqxkC8giux2RoYDu1xGk0J2FKg4bbm9GCI6JGdZhb3CCrhjy44x2ZdoBSsCB440iqfQX7GJRVmOlfoE7WYMslHfjlKbIKJJl6ibdhxdMfGDYe(KP2NxgvEWzdUGBdhNgbQqnEhCC9LbDPWX1apiGPhKtuFeCy(i4MJl6ibdh3rhqNaSQbkdIJ7jDVHg6GXaNng5bNngzn3gooncuHA8o446ld6sHJV5rD9Ogiust6JCHmvl58mnXtGrQi12Zb2J2Fuxps0rcgL0K(ixit1soptt8eyKkhJRKW8JhT)OnpQRh1aHsAsFKlKPAjNNXNKIksT9CG9OvREudekPj9rUqMQLCEgFskQJ8KCQpcopI9pA9JwT6rnqOKM0h5czQwY5zAINaJu1q02F0wpI9pA)rnqOKM0h5czQwY5zAINaJuh5j5uF0wpIDpA)rnqOKM0h5czQwY5zAINaJurQTNdShTMJl6ibdhxAsFKlKPAjNhp4SXiJCB440iqfQX7GJRVmOlfoEfGvGYPP6XQbwHm0H1hjyu0iqfQ9O9hrdDWy4rB9i2ZUhTA1JQaScuon1cOirwitfuwOju0iqfQXXZjO7W6dt644vawbkNMAbuKilKPckl0e70qhmg2I9SJJNtq3H1hM0ZJAPeehNroUOJemCCxHQ(6tCbhpNGUdRpmWkaiPWXzKhC2yCBUnCCAeOc14DWX1xg0Lchx0rUqgAiVKQpcopIroUOJemC8Qv2tgisoEWzJr2ZTHJtJavOgVdoU(YGUu44h5oQ6lqf6r7psd8GaMEqor9rB9i2XXfDKGHJFIDIhC2yeU52WXPrGkuJ3bhxFzqxkCCnWdcy6b5e1hT1Jyhhx0rcgoE1)Ogp4bhxdaLgWAQCB4SXi3goUOJemC8EqKGHJtJavOgVdEWzBBUnCCrhjy44qfaOzCyhdCCAeOc14DWdoBSNBdhx0rcgooeDv6SNdmooncuHA8o4bNn4MBdhx0rcgoUCAzitaUJMGJtJavOgVdEWzJDCB44IosWWXljm)OAy1WAW8Oj440iqfQX7GhC2GRCB44IosWWXD5rqfaOXXPrGkuJ3bp4S1D52WXfDKGHJlJMQXjfJwkfooncuHA8o4bNnwjUnCCAeOc14DWX1xg0LchhcZ5uqKCgh48uy9CCrhjy44qxwJsoWmoSJhC2Gl42WXPrGkuJ3bhxFzqxkC8npQbcLhamU8ivKA75a7rRw9irh5czOH8sQ(i48igF06hT)OgiuH)jvFdejNksT9CGXXfDKGHJNJwUrIem8GZgJSMBdhx0rcgooeDv6SZXPrGkuJ3bp4SXiJCB440iqfQX7GJl6ibdhxZGUaIdmP2avKAWXjNJ0HzepIJRzqxaXbMuBGksn4bNng3MBdhx0rcgoowLmzqEvooncuHA8o4bp44anywa2jUnC2yKBdhx0rcgoUham2ZX4aNhhNgbQqnEh8GZ22CB440iqfQX7GJRVmOlfoEifAcLpjxyaot4tgRS0u0iqfQ9O9h11JGWCoLpjxyaot4tgRS0uy9CCrhjy44(KCHb4mHpzSYsJhC2yp3gooncuHA8o446ld6sHJxbyfOCAkxE1WuJlTtkAeOc1E0(JGWCoLlVAyQXL2jfwphx0rcgoUgmla7Kj8jtTpVmQ8GZgCZTHJtJavOgVdoU(YGUu44KUK9vsjddMH6(4rRw9isxY(kPQGICMH6(GJl6ibdhVgY5YJ4bNn2XTHJtJavOgVdoU(YGUu44KUK9vsjddMH6(4rRw9isxY(kPkyJCMH6(GJl6ibdh36KWNhC2GRCB440iqfQX7GJRVmOlfoEifAcLpjxyaot4tgRS0u0iqfQ9O9hbH5CkFsUWaCMWNmwzPPW654IosWWX1GzbyNmHpzQ95LrLhC26UCB440iqfQX7GJRVmOlfoEifAcLpjxyaot4tgRS0u0iqfQ9O9hPbGsdynkFsUWaCMWNmwzPPoYtYP(i48igzhhx0rcgoUgmla7Kj8jtTpVmQ8GZgRe3gooncuHA8o446ld6sHJ31JcPqtO8j5cdWzcFYyLLMIgbQqnoUOJemCCnywa2jt4tMAFEzu5bp44Anywa2jUnC2yKBdhx0rcgoUwcJdCECCAeOc14DWdoBBZTHJtJavOgVdoU(YGUu44HuOju(KCHb4mHpzSYstrJavO2J2FuxpccZ5u(KCHb4mHpzSYstH1ZXfDKGHJ7tYfgGZe(KXklnEWzJ9CB440iqfQX7GJRVmOlfoEfGvGYPPC5vdtnU0oPOrGku7r7pccZ5uU8QHPgxANuy9CCrhjy44AWSaStMWNm1(8YOYdoBWn3gooncuHA8o446ld6sHJhsHMq5tYfgGZe(KXklnfncuHApA)rqyoNYNKlmaNj8jJvwAkSEoUOJemCCnywa2jt4tMAFEzu5bNn2XTHJtJavOgVdoU(YGUu44HuOju(KCHb4mHpzSYstrJavO2J2FKgaknG1O8j5cdWzcFYyLLM6ipjN6JGZJyKDCCrhjy44AWSaStMWNm1(8YOYdoBWvUnCCAeOc14DWX1xg0LchVRhfsHMq5tYfgGZe(KXklnfncuHACCrhjy44AWSaStMWNm1(8YOYdEWXbwflswiUnC2yKBdhNgbQqnEhCC9LbDPWX76rqyoNYdag75yCGZtH1ZXfDKGHJ7baJ9CmoW5XdoBBZTHJtJavOgVdoU(YGUu44HuOju(KCHb4mHpzSYstrJavO2J2FuxpccZ5u(KCHb4mHpzSYstH1ZXfDKGHJ7tYfgGZe(KXklnEWzJ9CB44IosWWXRHCvSdgXXPrGkuJ3bp4Sb3CB440iqfQX7GJRVmOlfoEfGvGYPPC5vdtnU0oPOrGkuJJl6ibdhxdMfGDYe(KP2NxgvEWzJDCB440iqfQX7GJRVmOlfoE7WYMcyvSizHmqKCCCrhjy44KxpWIodeyA8GZgCLBdhNgbQqnEhCC9LbDPWX38OUEudekPj9rUqMQLCEMM4jWivKA75a7r7pQRhj6ibJsAsFKlKPAjNNPjEcmsLJXvsy(XJ2F0Mh11JAGqjnPpYfYuTKZZ4tsrfP2EoWE0QvpQbcL0K(ixit1sopJpjf1rEso1hbNhX(hT(rRw9Ogiust6JCHmvl58mnXtGrQAiA7pARhX(hT)Ogiust6JCHmvl58mnXtGrQJ8KCQpARhXUhT)Ogiust6JCHmvl58mnXtGrQi12Zb2JwZXfDKGHJlnPpYfYuTKZJhC26UCB440iqfQX7GJl6ibdhVInU8ioU(YGUu44h5oQ6lqfIJRzqxitihmkQC2yKhC2yL42WXPrGkuJ3bhx0rcgoUhamU8ioU(YGUu44h5oQ6lqf6rRw9iimNtbtkIosTbgMCTugfwphxZGUqMqoyuu5SXip4SbxWTHJtJavOgVdoU(YGUu44AWcnYeQjH5hgNqpA)rKUK9vsjddMH6(GJl6ibdhVgY5YJ4bNngzn3gooncuHA8o446ld6sHJ31J0GfAKjutcZpmoHE0(JiDj7RKsggmd19bhx0rcgoU1jHpp4SXiJCB440iqfQX7GJRVmOlfo(MhbH5CksxY(kzkyJCkS(hTA1JGWCofPlzFLmvqrofw)JwZXfDKGHJRbZcWozcFYu7ZlJkp4SX42CB440iqfQX7GJRVmOlfo(Mhr6s2xjvoMc2i3JwT6rKUK9vsvbf5md19XJw)OvRE0Mhr6s2xjvoMc2i3J2FeeMZPQHCvSdgziVEGfDE0eMc2iNcR)rR54IosWWXRHCU8iEWzJr2ZTHJl6ibdh36KWNJtJavOgVdEWdEWXxORMGHZ22SEBgznCbJWvoULCtoWQC8UPxp4cQ9igz8rIosW8OswJQ6zHJx7jnNngznCZX7pGllehNvWkEeRmm5APmpcU8dlBplScwXJydSqEq09igzp8pABwVnJplplScwXJyv8LbgvHl7zHvWkEeCPh1nhn46bNe0JyvKWww5bGXEopQ)sWLrs1hTjDpQsrKdShL1hP9jTDQTw9SWkyfpcU0J6MJgC9Gtc6rG(ibZJcWJQ(PlE0gW9ObeRFee5ah9iwfWSaStQNLNfwXJ627EsJfu7rqKdC0J0apijEeeblNQ6rSYP1uFuF0ag4s(Y55Wkps0rcM6JatHb1ZIOJemvv)rAGhKeDY0w750oQzQ95Lr9zr0rcMQQ)inWdsIozARpjxyaot4tgRS0GpDmdPqtO8j5cdWzcFYyLLMIgbQqT9nTdlBkTewKSqgisUDimNtPLW4aNNcRF1Q2HLnfWQyrYczGi52HWCoLham2ZX4aNNcRF1kimNt5baJ9CmoW5PW63dPqtOGKImAYioxozWGIgbQqT1plIosWuv9hPbEqs0jtB7pGvb(0XecZ5uAjmoW5PW63Bhw2uAjSizHmqKCplIosWuv9hPbEqs0jtBHi5moW5bF6y2feMZPKHbJdCEkS(9nB6QDyztbSkwKSqgisU9UAhw2uAjSizHmqKCR330LgSqJmHAsy(HXj061RwTztxTdlBkGvXIKfYarYT3v7WYMslHfjlKbIKB9(gnyHgzc1KW8dJtO9qk0eQJQb4KibJrCUCYGbfncuHARx)Si6ibtv1FKg4bjrNmT16KWh(0XecZ5uEaWyphJdCEkS(92HLnfWQyrYczGi527sdwOrMqnjm)W4e6zr0rcMQQ)inWdsIozABnKZLhbF6ycH5CkpaySNJXbopfw)E7WYMcyvSizHmqKC7AWcnYeQjH5hgNqplIosWuv9hPbEqs0jtBDfQ6RpXfWNoMvawbkNMQhRgyfYqhwFKGrrJavO2QvvawbkNMAbuKilKPckl0ekAeOc1GpNGUdRpmPNh1sjiMmcFobDhwFyGvaqsHjJWNtq3H1hM0XScWkq50ulGIezHmvqzHM4z5zHv8OU9UN0yb1EeTqhdpksp6rHp9irhG7rz9rYIKfbQqQNfrhjyQmR2XkfdKu9FweDKGP2jtBXQKjdYd(r8iMSAGaBGr5DMgvJCyOA0sPaF6y2feMZP6pGvrH1V3LgSqJmHAHMWNH7zr0rcMANmTfRsMmip4RfqWmUCStbJWNoMDbH5CQ(dyvuy97DPbl0itOwOj8z4EweDKGP2jtBXQKjdYd(AbemJlh7uSn8PJzxqyoNQ)awffw)ExAWcnYeQfAcFgUNfrhjyQDY02EqKGb(0XSlnyHgzc1cnHpd3(MnBcPqtO8j5cdWzcFYyLLMIgbQqTDimNt5tYfgGZe(KXklnfw)69nTdlBkTewKSqgisUvRAhw2uaRIfjlKbIKB9ExqyoNQ)awffw)6vR2SbcZ5uq0vPZUbIKtH1VAfeMZPYrl3ircgdmm5APmgGZGDvGwH1VEFtxTdlBkTewKSqgisU9UAhw2uaRIfjlKbIKB961plScwXJyvKWIKLCG9irhjyEujRXJSYs5rq0JozEu6G)rEYaRq2g(Nu9FKC0JaZJ0n4F0jWOhL1hbrfG1JGBwd)J6o0z)rY0EuoA5gjsW8i5Oh1awZJKP9iwzysr0rQFemm5APmpccZ5EuwF0aIhj6ixi4Fe4Eu6G)rwu36OhLZJ0s4aN3JKP9iAOdgdpkRpsGal0J2MDW)iw97rP7rw0J8Lf6rHp9iwDj8FuHGrttogEe1nWY(EQb)JcF6rnccZ5Eujh7u7rb4rz8OS(ObepcR)rY0Een0bJHhL1hjqGf6rBZA4z1VhLUhzrDRJEKDgUuMhjt7rD7E9al6EeeyApsdaLgWAEuwFew)JKP9iAiVKQpso6r54Olb3JcWJ2w9Si6ibtTtM2EyJr0rcgtjRb814sDWKr4hXJyQLWIKfc(0XSDyztPLWIKfYarYT3LgSqJmHAHMWNHBhcZ5u5OLBKibJbgMCTugdWzWUkqRAaRzhcZ5uq0vPZUbIKt1awZ(MnAaO0awJk8pP6BGi5uh5j5uHdR31aqPbSgLNmWkK6ipjNkCy9EdekpayC5rQJ8KCQWHjmDRtwRy3(jWOTGBwVdH5CQC0YnsKGXadtUwkJb4myxfOvnG1SdH5Cki6Q0z3arYPAaRzhcZ5uWKIOJuBGHjxlLr1awZ6vR2aH5CkTegh48uy970qhmgGZ2SB9QvBAGqDIDsDK7OQVavO9giux2RoYDu1xGk06vR2Cyd5ahmsbKW3aCMWNmuPrNPDyztrDdSSVNA7DbH5CkGe(gGZe(KHkn6mTdlBkS(9nqyoNslHXbopfw)on0bJb4SnRxVdH5CkFsUWaCMWNmwzPPoYtYPUftgz96vR2Obl0itOSZWLYSRbGsdynkYRhyrNbcmn1rEso1TyY4UOJCHm0qEjv3A71RwTbcZ5u(KCHb4mHpzSYstH1VtdDWyaoWfSE96NfrhjyQDY02dBmIosWykznGVgxQdMmc)iEetTewKSqWNoMTdlBkTewKSqgisUDnyHgzc1cnHpd3(MnAaO0awJk8pP6BGi5uh5j5uHdR31aqPbSgLNmWkK6ipjNkCy9EdekpayC5rQJ8KCQWHjmDRtwRy3(jWOTGBwVdH5CQC0YnsKGXadtUwkJb4myxfOvnG1SdH5Cki6Q0z3arYPAaRzhcZ5uWKIOJuBGHjxlLr1awZ(jWOTGBwVdH5CQC0YnsKGXadtUwkJb4myxfOvnG1SdH5Cki6Q0z3arYPAaRzhcZ5uWKIOJuBGHjxlLr1awZ6vR2aH5CkTegh48uy970qhmgGZ2SB9QvBAGqDIDsDK7OQVavO9giux2RoYDu1xGk0(jWOTGBwVdH5CQC0YnsKGXadtUwkJb4myxfOvnG1SdH5Cki6Q0z3arYPAaRzhcZ5uWKIOJuBGHjxlLr1awZ61plIosWu7KPTh2yeDKGXuYAaFnUuhmze(r8iMAjSizHGpDm7QDyztPLWIKfYarYTdH5CkTegh48uy9plScwXJy1TkwKSKdShj6ibZJkznEKvwkpcIE0jZJsh8pYtgyfY2W)KQ)JKJEeyEKUb)Jobg9OS(iiQaSEeJSd(h1DOZ(JKP9OC0YnsKG5rYrpQbSMhjt7rSYWKIOJu)iyyY1szEeeMZ9OS(Obeps0rUqQhXQFpkDW)ilQBD0JY5rEaWypNh5aN3JKP9Ok24YJEuwF0rUJQ(cuHG)rS63Js3JSOh5ll0JcF6rS6s4)OcbJMMCm8iQBGL99ud(hf(0JAeeMZ9Oso2P2JcWJY4rz9rdiEewVIv)Eu6EKf1To6r2z4szEKmTh1T71dSO7rqGP9inauAaR5rz9ry9psM2JOH8sQ(i5OhbrfG1J2g(hbUhLUhzrDRJEeBjm)4roHEKmThXQaMfGD6r62JY6JW6vplIosWu7KPTh2yeDKGXuYAaFnUuhmze(r8iMaRIfjle8PJz7WYMcyvSizHmqKC7B2ObGsdynQW)KQVbIKtDKNKtfoSExdaLgWAuEYaRqQJ8KCQWH17NaJ2Ir2TdH5CQC0YnsKGr1awZoeMZPGORsNDdejNQbSMDimNtbtkIosTbgMCTugvdynRxTAdeMZP8aGXEogh48uy97nqOQyJlpsDK7OQVavO1RwTbcZ5uEaWyphJdCEkS(DimNt5tYfgGZe(KXklnfw)6vR2Cyd5ahmsbKW3aCMWNmuPrNPDyztrDdSSVNA7DbH5CkGe(gGZe(KHkn6mTdlBkS(1RwTrdwOrMqnjm)W4eAxdaLgWAuAWSaStMWNm1(8YOQoYtYPUftgxVA1gnyHgzcLDgUuMDnauAaRrrE9al6mqGPPoYtYPUftg3fDKlKHgYlP6wBVE9ZIOJem1ozA7HngrhjymLSgWxJl1btgHFepIjWQyrYcbF6y2v7WYMcyvSizHmqKC7qyoNYdag75yCGZtH1)Si6ibtTtM2EyJr0rcgtjRb8J4rmbwflswi4RXL6GjJWNoMTdlBkGvXIKfYarYTdH5CkpaySNJXbopfw)ZcR4rDt3JSOh5ll0JyvZGwo5rfcgnn5y4ru3al77P2JKP9iiPiJMEK4C5KbdpsQpsEuifAIhzrpQALH2)r5eGh5baJ9CEKdCEpYYNgAHUhf(0JkmOLtEeeMZ9OS(ijEe4EeevawpA7hvj9ZIOJem1ozA7HngrhjymLSgWpIhXSWGwobaF6yUzZHnKdCWivHbTCs14kef5aZaRKE9vsrDdSSVNAR33esHMqbjfz0KrCUCYGbfncuHAR33aH5CQcdA5KQXvikYbMbwj96RKcRF9(gimNtvyqlNunUcrroWmWkPxFLuh5j5u3I52Rx)SWkEu309il6r(Yc9iw1mOLtEuHGrttogEe1nWY(EQ9izApYrNuEK4C5KbdpsQpsEuifAIhzrpQALH2)r5eGh5OtkpYboVhz5tdTq3JcF6rfg0YjpccZ5EuwFKepcCpcIkaRhT9JQK(zr0rcMANmT9WgJOJemMswd4hXJywyqlNOHpDm3S5WgYboyKQWGwoPACfIICGzGvsV(kPOUbw23tT17BcPqtOC0jfJ4C5KbdkAeOc1wVVbcZ5ufg0YjvJRquKdmdSs61xjfw)69nqyoNQWGwoPACfIICGzGvsV(kPoYtYPUfZTxV(zHv8OUP7rwu36OhjpAsy(HtOhjt7rw0JAGPBfpYsM4rb4rAjSizHSfyvSizHG)rY0EKf9iFzHEeKuKrt26OtkpsCUCYGHhfsHMGAW)iwv(0ql09inywa2PhPBpkRpcR)rw0JQwzO9Fuob4rIZLtgm8ih48EuaEKwQXJYa(h5th9ipaySNZJCGZt9Si6ibtTtM2EyJr0rcgtjRb8J4rmbAWSaStWNoMvkICGvvv)0fgh4mAWSaSt7B2esHMqbjfz0KrCUCYGbfncuHAR330v7WYMslHfjlKbIKB9(MUAhw2uaRIfjlKbIKB9(gnyHgzc1KW8dJtODnauAaRrPbZcWozcFYu7ZlJQ6ipjN6wmzC96NfwXJ6MUhzrDRJEK8OjH5hoHEKmThzrpQbMUv8ilzIhfGhPLWIKfYwGvXIKfc(hjt7rw0J8Lf6rqsrgnzRJoP8iX5YjdgEuifAcQb)Jyv5tdTq3J0GzbyNEKU9OS(iS(hzrpQALH2)r5eGhjoxozWWJCGZ7rb4rAPgpkd4FKpD0J0s4aN3JCGZt9Si6ibtTtM2EyJr0rcgtjRb8J4rm1AWSaStWxJl1btgHpDmRue5aRQQ(PlmoWz0GzbyN23SjKcnHYrNumIZLtgmOOrGkuB9(MUAhw2uAjSizHmqKCR330v7WYMcyvSizHmqKCR33Obl0itOMeMFyCcTRbGsdynknywa2jt4tMAFEzuvh5j5u3IjJRx)Si6ibtTtM2QLsXi6ibJPK1a(r8iMEzKWKibZZIOJem1ozA7HngrhjymLSgWpIhXeIK7z5zr0rcMQcIKJjejNXbop4thZUGWCofejNXbopfw)ZIOJemvfejxNmT1NKlmaNj8jJvwAWNoMHuOju(KCHb4mHpzSYstrJavO2(Mqk0ekiPiJMmIZLtgmOOrGkuB9UgSqJmHAHMWNH7zr0rcMQcIKRtM26baJlpcEnd6czc5GrrLjJWNoMB20vKA75aBpspYeatlj4W427qyoNcMueDKAdmm5APmkS(1RwT5i3rvFbQq7r6rMayAjbhg3EhcZ5uWKIOJuBGHjxlLrH1VE9ZIOJemvfejxNmT1dagxEe8Ag0fYeYbJIktgHpDm3SPRi12Zb2EKEKjaMwsWHXTxVA1MJChv9fOcThPhzcGPLeCyC71RFweDKGPQGi56KPTNSqdaRAChnDhgEweDKGPQGi56KPTyvYKb5b)iEetwnqGnWO8otJQromunAPuGpDm1GfAKjul0e(mCplIosWuvqKCDY0wSkzYG8GVwabZ4YXofmcF6y2feMZP6pGvrH1VRbl0itOwOj8z4EweDKGPQGi56KPTyvYKb5bFTacMXLJDk2g(0XSlimNt1FaRIcRFxdwOrMqTqt4ZW9Si6ibtvbrY1jtB7brcg4thtnyHgzc1cnHpd3oeMZPYrl3ircg1rEsov4WCB4EhcZ5u5OLBKibJ6ipjN6wm3MDplIosWuvqKCDY0wnywa2jt4tMAFEzuHpDm7QDyztPLWIKfYarYT3v7WYMcyvSizHmqKCplIosWuvqKCDY0wi6Q0z3arYbF6yUbcZ5uNSqdaRAChnDhguy9Rw1LgSqJmHAHMWNHB9ZIOJemvfejxNmTnhTCJejyGpDm3aH5CQtwObGvnUJMUddkS(vR6sdwOrMqTqt4ZWT(zr0rcMQcIKRtM2crxLo75ad(0XCdeMZPGORsNDdejNcRF1kimNtLJwUrIemgyyY1szmaNb7QaTcRF9ZIOJemvfejxNmTvAsFKlKPAjNh8PJ5MUAGqjnPpYfYuTKZZ0epbgPIuBphy7Dj6ibJsAsFKlKPAjNNPjEcmsLJXvsy(X(MUAGqjnPpYfYuTKZZ4tsrfP2EoWwTQbcL0K(ixit1sopJpjf1rEsov4W(1Rw1aHsAsFKlKPAjNNPjEcmsvdrBFl2V3aHsAsFKlKPAjNNPjEcmsDKNKtDl2T3aHsAsFKlKPAjNNPjEcmsfP2EoWw)Si6ibtvbrY1jtB9aGXLhbF6ycH5Ckysr0rQnWWKRLYOW63fDKlKHgYlP6wS)zr0rcMQcIKRtM2g(Nu9nqKCWRzqxitihmkQmze(0X8i3rvFbQqRw1aHk8pP6BGi5u1q023I9RwTPbcv4Fs13arYPQHOTVfCVFyd5ahmsvWCojhhwLAgYd6enPOUbw23tT1Rwj6ixidnKxsv4WeUxTccZ5uq0vPZUbIKtH1VdH5Cki6Q0z3arYPoYtYPUfty6wNSwXUNfrhjyQkisUozARNmWke8PJ5jWivJCPod4WiR3Rue5aRQ8KbwHmEGJEweDKGPQGi56KPTUcv91N4c4thZkaRaLtt1JvdSczOdRpsWOOrGkuBFZgnauAaRrf(Nu9nqKCQJ8KCQWH17AaO0awJYtgyfsDKNKtfoSE9(MgiuEaW4YJuh5j5uHdt2VEFdeMZPYrl3ircgdmm5APmgGZGDvGw1awZoeMZPGORsNDdejNQbSMDimNtbtkIosTbgMCTugvdynRxVAvfGvGYPPwafjYczQGYcnHIgbQqn4ZjO7W6dt65rTucIjJWNtq3H1hgyfaKuyYi85e0Dy9HjDmRaScuon1cOirwitfuwOj23ObGsdynQW)KQVbIKtDKNKtfoSExdaLgWAuEYaRqQJ8KCQWH1RFweDKGPQGi56KPTvRSNGpDmHWCovoA5gjsWyGHjxlLXaCgSRc0QgWA2HWCofeDv6SBGi5unG1Sl6ixidnKxsv4WeUFweDKGPQGi56KPTEcwb(0XecZ5u5OLBKibJcRFx0rUqgAiVKQBX(9nqyoNkaGW3itZOlILQgI2oCyU96vR2aH5CQaacFJmnJUiwkS(DimNtfaq4BKPz0fXsDKNKtDlgvSB9QvBGWCovvweyKrd8GKqMqvdrBhomz)6vRGWCofeDv6SBGi5uy97IoYfYqd5LuDl2)Si6ibtvbrY1jtB9eSc8PJ5gimNtvLfbgz0apijKju1q02HdtgxVVbcZ5ubae(gzAgDrSuy9R3HWCovoA5gjsWOW63fDKlKHgYlPkZTFweDKGPQGi56KPTEYaRqWNoMqyoNkhTCJejyuy97IoYfYqd5LuDlMS)zr0rcMQcIKRtM26jyf4thZnB2aH5CQaacFJmnJUiwQAiA7WH52RxTAdeMZPcai8nY0m6IyPW63HWCovaaHVrMMrxel1rEso1TyuXU1RwTbcZ5uvzrGrgnWdsczcvneTD4WK9RxVl6ixidnKxs1Ty)6NfrhjyQkisUozAB4Fs13arYbF6yk6ixidnKxsv4W4ZIOJemvfejxNmT1tgyfc(0XCZMtGrBbxW617IoYfYqd5LuDl2VE1QnBobgTfRe7wVl6ixidnKxs1Ty)EifAcvfGvmaNj8jJdCunu0iqfQT(zr0rcMQcIKRtM22JvwOl7oe8Ag0fYeYbJIktgHpDmBGqf(Nu9nqKCQAiA7Wz7NfrhjyQkisUozAB4Fs13arY9Si6ibtvbrY1jtB9eSc8PJPOJCHm0qEjv3I9plIosWuvqKCDY02Qv2tgisUNfrhjyQkisUozABEGXHDWNoMNaJunYL6m2cUz9oeMZPYdmoStDKNKtDlwRy3ZYZIOJemvLxgjmjsWWmpW4Wo4thZC0aVCGzAINaJmSRcN8aJd7mnXtGrMW)OQpO02HWCovEGXHDQJ8KCQBX(UnFPg0ZIOJemvLxgjmjsW0jtBpAilPaF6ygYyphy7(KucFvVo2cUYUNfrhjyQkVmsysKGPtM26oA6oj1mhbJg6Kibd8PJziJ9CGT7tsj8v96yl4k7EweDKGPQ8YiHjrcMozAl51dSOZabMg8PJ5MUAhw2uAjSizHmqKC7D1oSSPawflswidej36vReDKlKHgYlPkCyU9ZIOJemvLxgjmjsW0jtBHKZE1EoWNoMHm2Zb2UpjLWx1RJT6USBphnWlhyMM4jWid7QWH1kg728jPe(kpP7FweDKGPQ8YiHjrcMozABf7wYfPyYPg5OJk8PJjeMZPQy3sUifto1ihDuvnG1SdH5Cki5SxTNJQbSMDFskHVQxhBbxz9EoAGxoWmnXtGrg2vHdRvBZUUnFskHVYt6(NLNfrhjyQknauAaRPYShejyEweDKGPQ0aqPbSMANmTfQaanJd7y4zr0rcMQsdaLgWAQDY0wi6Q0zphyplIosWuvAaO0awtTtM2kNwgYeG7OjEweDKGPQ0aqPbSMANmTTKW8JQHvdRbZJM4zr0rcMQsdaLgWAQDY0wxEeubaAplIosWuvAaO0awtTtM2kJMQXjfJwkLNfrhjyQknauAaRP2jtBHUSgLCGzCyh8PJjeMZPGi5moW5PW6FweDKGPQ0aqPbSMANmTnhTCJejyGpDm30aHYdagxEKksT9CGTALOJCHm0qEjvHdJR3BGqf(Nu9nqKCQi12Zb2ZIOJemvLgaknG1u7KPTq0vPZ(ZIOJemvLgaknG1u7KPTyvYKb5bp5CKomJ4rm1mOlG4atQnqfPgplIosWuvAaO0awtTtM2IvjtgKx9z5zr0rcMQslHfjleZ(dyvEweDKGPQ0syrYc1jtB1syCGZd(0XSlimNtPLW4aNNcR)zr0rcMQslHfjluNmT9e7e8PJjeMZP6pGvrH1)Si6ibtvPLWIKfQtM26tYfgGZe(KXkln4thZqk0ekFsUWaCMWNmwzPPOrGkuBVlimNt5tYfgGZe(KXklnfw)ZIOJemvLwclswOozAl51dSOZabMg8PJz7WYMslHfjlKbIK7zr0rcMQslHfjluNmT9e7e8PJzdeQtStQJChv9fOcTAfn0bJHTGB29Si6ibtvPLWIKfQtM2Ezp8PJzdeQl7vh5oQ6lqfAxd8GaMEqorfomH7NfrhjyQkTewKSqDY0wnywa2jt4tMAFEzuHpDmBhw2uAjSizHmqKCplIosWuvAjSizH6KPTo6a6eGvnqzqW7jDVHg6GXatgHpDm1apiGPhKtuHdt4(zr0rcMQslHfjluNmTvAsFKlKPAjNh8PJ5MUAGqjnPpYfYuTKZZ0epbgPIuBphy7Dj6ibJsAsFKlKPAjNNPjEcmsLJXvsy(X(MUAGqjnPpYfYuTKZZ4tsrfP2EoWwTQbcL0K(ixit1sopJpjf1rEsov4W(1Rw1aHsAsFKlKPAjNNPjEcmsvdrBFl2V3aHsAsFKlKPAjNNPjEcmsDKNKtDl2T3aHsAsFKlKPAjNNPjEcmsfP2EoWw)Si6ibtvPLWIKfQtM26ku1xFIlGpDmRaScuonvpwnWkKHoS(ibJIgbQqTDAOdgdBXE2TAvfGvGYPPwafjYczQGYcnHIgbQqn4ZjO7W6dt65rTucIjJWNtq3H1hgyfaKuyYi85e0Dy9HjDmRaScuon1cOirwitfuwOj2PHoymSf7z3ZIOJemvLwclswOozAB1k7j4thtrh5czOH8sQchgFweDKGPQ0syrYc1jtBpXobF6yEK7OQVavODnWdcy6b5e1Ty3ZIOJemvLwclswOozAB1)Og8PJPg4bbm9GCI6wS7z5zr0rcMQsRbZcWoXulHXboVNfrhjyQkTgmla7uNmT1NKlmaNj8jJvwAWNoMHuOju(KCHb4mHpzSYstrJavO2ExqyoNYNKlmaNj8jJvwAkS(NfrhjyQkTgmla7uNmTvdMfGDYe(KP2Nxgv4thZkaRaLtt5YRgMACPDsrJavO2oeMZPC5vdtnU0oPW6FweDKGPQ0AWSaStDY0wnywa2jt4tMAFEzuHpDmdPqtO8j5cdWzcFYyLLMIgbQqTDimNt5tYfgGZe(KXklnfw)ZIOJemvLwdMfGDQtM2QbZcWozcFYu7ZlJk8PJzifAcLpjxyaot4tgRS0u0iqfQTRbGsdynkFsUWaCMWNmwzPPoYtYPchgz3ZIOJemvLwdMfGDQtM2QbZcWozcFYu7ZlJk8PJzxHuOju(KCHb4mHpzSYstrJavO2ZYZIOJemvvHbTCIMPwcJdCEplplIosWuvfg0YjaMEaWyphJdCEplplIosWuvanywa2jMEaWyphJdCEplIosWuvanywa2PozARpjxyaot4tgRS0GpDmdPqtO8j5cdWzcFYyLLMIgbQqT9UGWCoLpjxyaot4tgRS0uy9plIosWuvanywa2PozARgmla7Kj8jtTpVmQWNoMvawbkNMYLxnm14s7KIgbQqTDimNt5YRgMACPDsH1)Si6ibtvb0GzbyN6KPT1qoxEe8PJjPlzFLuYWGzOUpwTI0LSVsQkOiNzOUpEweDKGPQaAWSaStDY0wRtcF4thtsxY(kPKHbZqDFSAfPlzFLufSroZqDF8Si6ibtvb0GzbyN6KPTAWSaStMWNm1(8YOcF6ygsHMq5tYfgGZe(KXklnfncuHA7qyoNYNKlmaNj8jJvwAkS(NfrhjyQkGgmla7uNmTvdMfGDYe(KP2Nxgv4thZqk0ekFsUWaCMWNmwzPPOrGkuBxdaLgWAu(KCHb4mHpzSYstDKNKtfomYUNfrhjyQkGgmla7uNmTvdMfGDYe(KP2Nxgv4thZUcPqtO8j5cdWzcFYyLLMIgbQqTNLNfrhjyQkGvXIKfIPham2ZX4aNh8PJzxqyoNYdag75yCGZtH1)Si6ibtvbSkwKSqDY0wFsUWaCMWNmwzPbF6ygsHMq5tYfgGZe(KXklnfncuHA7DbH5CkFsUWaCMWNmwzPPW6FweDKGPQawflswOozABnKRIDWONfrhjyQkGvXIKfQtM2QbZcWozcFYu7ZlJk8PJzfGvGYPPC5vdtnU0oPOrGku7zr0rcMQcyvSizH6KPTKxpWIodeyAWNoMTdlBkGvXIKfYarY9Si6ibtvbSkwKSqDY0wPj9rUqMQLCEWNoMB6QbcL0K(ixit1soptt8eyKksT9CGT3LOJemkPj9rUqMQLCEMM4jWivogxjH5h7B6QbcL0K(ixit1sopJpjfvKA75aB1Qgiust6JCHmvl58m(Kuuh5j5uHd7xVAvdekPj9rUqMQLCEMM4jWivneT9Ty)EdekPj9rUqMQLCEMM4jWi1rEso1Ty3EdekPj9rUqMQLCEMM4jWivKA75aB9ZIOJemvfWQyrYc1jtBRyJlpcEnd6czc5GrrLjJWNoMh5oQ6lqf6zr0rcMQcyvSizH6KPTEaW4YJGxZGUqMqoyuuzYi8PJ5rUJQ(cuHwTccZ5uWKIOJuBGHjxlLrH1)Si6ibtvbSkwKSqDY02AiNlpc(0XudwOrMqnjm)W4eAN0LSVskzyWmu3hplIosWuvaRIfjluNmT16KWh(0XSlnyHgzc1KW8dJtODsxY(kPKHbZqDF8Si6ibtvbSkwKSqDY0wnywa2jt4tMAFEzuHpDm3aH5CksxY(kzkyJCkS(vRGWCofPlzFLmvqrofw)6NfrhjyQkGvXIKfQtM2wd5C5rWNoMBiDj7RKkhtbBKB1ksxY(kPQGICMH6(y9QvBiDj7RKkhtbBKBhcZ5u1qUk2bJmKxpWIopActbBKtH1V(zr0rcMQcyvSizH6KPTwNe(8GhCoa]] )


end