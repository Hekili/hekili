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
            copy = "berserk_bear"
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

    spec:RegisterHook( "reset_precast", function ()
        if azerite.masterful_instincts.enabled and buff.survival_instincts.up and buff.masterful_instincts.down then
            applyBuff( "masterful_instincts", buff.survival_instincts.remains + 30 )
        end

        if buff.lycaras_fleeting_glimpse.up then
            state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
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
            cooldown = function () return buff.berserk.up and ( level > 57 and 9 or 18 ) or 36 end,
            recharge = function () return buff.berserk.up and ( level > 57 and 9 or 18 ) or 36 end,
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
            cooldown = function () return buff.berserk.up and ( level > 57 and 2 or 4 ) or 8 end,
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
            end,

            copy = { "incarnation_guardian_of_ursoc", "Incarnation" }
        },


        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "off",

            spend = function () return buff.berserk.up and 20 or 40 end,
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
            cooldown = function () return ( buff.berserk.up and ( level > 57 and 1.5 or 3 ) or 6 ) * haste end,
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
            cooldown = function () return ( buff.berserk.up and ( level > 57 and 1.5 or 3 ) or 6 ) * haste end,
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

    spec:RegisterPack( "Guardian", 20210403, [[dCuZGbqiQu9iLsPnHk9jOuLrPK6ukfRckv0ROszwqj3ckvv7Is)cvLHrLOJrQyzkv8mQKmnLk11OsyBkvIVPukmoLsfNtPu06OsQI5PuY9qf7dkLdQuQklKuPhQuQ0ePsQsxekvLpsLuvNekvALkvntLsv1nvkvr7evPFcLk8uqnvufFvPuL2lk)LIbd5WelgKhtYKLYLr2mv9zOy0s40IwTsPk8AsvZwQUnPSBf)wvdxIoUsL0YbEUKMUW1HQTReFNkgpvs58OQA9ujvMVsY(vzMomEyWnjigV74YD0XL72LUYQJoUYfUuhgCWFjXGlfLEbdXGhrJyWU(4cOLYWGlf(7V0y8WGRpoqrm4IikRUE4JpmzuGdzvVgF1udVlr(Jci(GVAQP4JbdHN9a7omigCtcIX7oUChDC5UDPRS6OJR2Tl2MmybpkEadgo12Um4IS1OHbXGBuvXGD9XfqlL5qUEb4z72V9vcY(H2bRdTJl3XL3(B)2Tqgmu11ZTh7)qy3r9GYhibDOTRe8T98)rFohQeKpiJKQhAD6puLIihmhkRhsvqk9uBJ92J9FiS7OEq5dKGo0xg5phk(dvlsFCO1p4qZhBoee5FaDOT7plVEYYG7znQmEyWD(vcqEgpmE1HXddwur(ddw7)rFog)d0yW0iqDQX0LfSGbdrcGXdJxDy8WGPrG6uJPldwbYGaPWGD)qq4EVfIeGX)anlEjdwur(ddgIeGX)anwW4Dhgpmyrf5pmyGSqZJxnEanUo(zW0iqDQX0LfmEDfJhgmncuNAmDzWkqgeifgS7hQbWZMvjHdjlKbIeWH4Ei3pudGNn770DizHmqKayWIkYFyWQFwE9KjkitTmbzuzbJ3DZ4HbtJa1PgtxgScKbbsHbV(qq4EVfil084vJhqJRJFlE5HwT6qUFi1VqJmHDHMOGFWH2WGfvK)WGHiqLa6zbJxxW4HbtJa1PgtxgScKbbsHbV(qq4EVfil084vJhqJRJFlE5HwT6qUFi1VqJmHDHMOGFWH2WGfvK)WGZrjGrI8hwW4Dxy8WGPrG6uJPldwbYGaPWGxFiiCV3crGkb0BGibyXlp0Qvhcc37T5OeWir(JbdUaAPmM3BWb1xzXlp0ggSOI8hgmebQeqFoyybJ3TbJhgmncuNAmDzWkqgeifg86d5(HAFyLMug5czQocqZ0enbdzJuPphmhI7HC)qIkYFSstkJCHmvhbOzAIMGHS5y89etrCiUhA9HC)qTpSstkJCHmvhbOzkiPBJuPphmhA1Qd1(WknPmYfYuDeGMPGKUfqAso1dHTd5QdT5qRwDO2hwPjLrUqMQJa0mnrtWq2Aik9hARd5QdX9qTpSstkJCHmvhbOzAIMGHSastYPEOToKloe3d1(WknPmYfYuDeGMPjAcgYgPsFoyo0ggSOI8hgS0KYixit1raASGX72HXddMgbQtnMUmyfidcKcdgqEavleOoDOvRou7dBuaKAHbIeGTgIs)H26qU6qRwDO1hQ9HnkasTWarcWwdrP)qBDODFiUhcGpK)byiBh37LC84vQziniGOilTR4zzj1o0MdTA1HevKlKHgslP6HWgNdTBgSOI8hgCuaKAHbIealy8Unz8WGPrG6uJPldwbYGaPWGxFO1hcc37TyKUOIuzWGlGwkJfV8qBoe3djQixidnKws1dT1H25qBo0QvhA9HwFiiCV3Ir6IksLbdUaAPmw8YdT5qCpK7hQ9Hv7)XNaYgPsFoyoe3djQixidnKws1dHTdPZH4EOqayOWgPgzI30s6qy7q6SZH2WGfvK)WG1(F8jGybJxDCjJhgmncuNAmDzWkqgeifg86d1(WQ9)4tazbKMKt9qBX5qU6qCp06dbH79wmsxurQmyWfqlLXIxEOnhI7HevKlKHgslP6HW2HCXH4EOqayOWgPgzI30s6qy7q6SZH2WGfvK)WG1(F8jGybJxD0HXddMgbQtnMUmyfidcKcdgiyiBJ8PkJdHTdPJlpe3dvPiYbt1QjdMoz0EaXGfvK)WG1KbtNybJxD2HXddMgbQtnMUmyfidcKcdE9HaKhq1cbQthI7HevKlKHgslP6H26q7CiUhkeagkSrQrM4nTKoe2oKo7COnhA1QdT(qUFO2hwT)hFciBKk95G5qCpKOICHm0qAjvpe2oKohI7HcbGHcBKAKjEtlPdHTdPZohAddwur(ddw7)XNaIfmE1XvmEyW0iqDQX0LbRazqGuyWq4EVnhLagjYFmyWfqlLX8EdoO(kB7DMdX9qq4EVfIavcO3arcW2EN5qCpKOICHm0qAjvpe24CODZGfvK)WGRozjzGibWcgV6SBgpmyAeOo1y6YGvGmiqkmyiCV3MJsaJe5pw8YdX9qIkYfYqdPLu9qBDODyWIkYFyWAcENfmE1XfmEyW0iqDQX0LbRazqGuyWRpeeU3BRYIGHmQxdsczcBneL(dHnohsNdT5qCp06dbH7924)OWitZO6IJfV8qBoe3dbH792CucyKi)XIxEiUhsurUqgAiTKQhIZH2HblQi)HbRj4DwW4vNDHXddMgbQtnMUmyfidcKcdgc37T5OeWir(JfV8qCpKOICHm0qAjvp0wCoKRyWIkYFyWAYGPtSGXRoBdgpmyAeOo1y6YGvGmiqkm41hA9HwFiiCV3g)hfgzAgvxCS1qu6pe24CODo0MdTA1HwFiiCV3g)hfgzAgvxCS4LhI7HGW9EB8FuyKPzuDXXcinjN6H26q6yDXH2COvRo06dbH792QSiyiJ61GKqMWwdrP)qyJZHC1H2COnhI7HevKlKHgslP6H26qU6qByWIkYFyWAcENfmE1z7W4HbtJa1PgtxgScKbbsHblQixidnKws1dHTdPddwur(ddokasTWarcGfmE1zBY4HbtJa1PgtxgScKbbsHbV(qRpeqWqhARdTnD5H2CiUhsurUqgAiTKQhARd5QdT5qRwDO1hA9Hacg6qBDOTJlo0MdX9qIkYfYqdPLu9qBDixDiUhkKonHT(4DZ7nrbz8pGQHLgbQtTdTHblQi)HbRjdMoXcgV74sgpmyAeOo1y6YGfvK)WGlX7leiDDedwbYGaPWGBFyJcGulmqKaS1qu6pe2o0omyf)QozcbGHIkJxDybJ3D0HXddwur(ddokasTWarcGbtJa1PgtxwW4DNDy8WGPrG6uJPldwbYGaPWGfvKlKHgslP6H26qUIblQi)HbRj4DwW4DhxX4HblQi)HbxDYsYarcGbtJa1PgtxwW4DNDZ4HbtJa1PgtxgScKbbsHbdemKTr(uLXH26q72LhI7HGW9EBc(XJdSastYPEOToKlTUGblQi)HbNGF84awWcgSwgjgjYFy8W4vhgpmyAeOo1y6YGvGmiqkm4CuVwoymnrtWqgxupe2ouc(XJdmnrtWqMOaq1IV3oe3dbH792e8JhhybKMKt9qBDixDiSZdvi1GyWIkYFyWj4hpoGfmE3HXddMgbQtnMUmyfidcKcdoKrFoyoe3dvqspkSLQ4qBDODXfmyrf5pmyanKJ0zbJxxX4HbtJa1PgtxgScKbbsHbhYOphmhI7HkiPhf2svCOTo0U4cgSOI8hgShqJRlPMbqyOHasK)WcgV7MXddMgbQtnMUmyfidcKcdE9HC)qnaE2SkjCizHmqKaoe3d5(HAa8SzFNUdjlKbIeWH2COvRoKOICHm0qAjvpe24CODyWIkYFyWKw57qad0pnwW41fmEyW0iqDQX0LbRazqGuyWHm6ZbZH4EOcs6rHTufhARdTnCXH4EOCuVwoymnrtWqgxupe2oKlT6CiSZdvqspkSAIRXGfvK)WGHeG(Q(CybJ3DHXddMgbQtnMUmyfidcKcdgc37TvCWsUiDto1ihvuTT3zoe3dbH79wibOVQphB7DMdX9qfK0JcBPko0whAxC5H4EOCuVwoymnrtWqgxupe2oKlT74IdHDEOcs6rHvtCngSOI8hgCfhSKls3KtnYrfvwWcgSschswigpmE1HXddwur(ddUe8oDgmncuNAmDzbJ3Dy8WGPrG6uJPldwbYGaPWGD)qq4EVvjHX)anlEjdwur(ddwjHX)anwW41vmEyW0iqDQX0LbRazqGuyWq4EVTe8oDlEjdwur(ddgi6jwW4D3mEyW0iqDQX0LbRazqGuyWH0PjSfKacZ7nrbzCYEZsJa1P2H4Ei3peeU3BlibeM3BIcY4K9MfVKblQi)HbxqcimV3efKXj7nwW41fmEyW0iqDQX0LbRazqGuyWnaE2SkjCizHmqKayWIkYFyWKw57qad0pnwW4Dxy8WGPrG6uJPldwbYGaPWGBFybIEYcipGQfcuNoe3dPEnO3u(5e1dT1H2ndwur(ddgi6jwW4DBW4HbtJa1PgtxgScKbbsHb3(WcYslG8aQwiqD6qCpK61GEt5Ntupe24CODZGfvK)WGbzjly8UDy8WGPrG6uJPldwbYGaPWGBa8Szvs4qYczGibWGfvK)WGv)S86jtuqMAzcYOYcgVBtgpmyAeOo1y6YGvGmiqkmy1Rb9MYpNOEiSX5q7MblQi)Hb7jWRYhVAGYGyWAIRzOHay4NXRoSGXRoUKXddMgbQtnMUmyfidcKcdE9HC)qTpSstkJCHmvhbOzAIMGHSrQ0NdMdX9qUFirf5pwPjLrUqMQJa0mnrtWq2Cm(EIPioe3dT(qUFO2hwPjLrUqMQJa0mfK0TrQ0NdMdTA1HAFyLMug5czQocqZuqs3cinjN6HW2HC1H2COvRou7dR0KYixit1raAMMOjyiBneL(dT1HC1H4EO2hwPjLrUqMQJa0mnrtWqwaPj5up0whYfhI7HAFyLMug5czQocqZ0enbdzJuPphmhAddwur(ddwAszKlKP6ianwW4vhDy8WGPrG6uJPldwbYGaPWGvVg0Bk)CIQvHda0ehARd5cgSOI8hgCTaqnwWcgCNFLaefJhgV6W4HblQi)HbRKW4FGgdMgbQtnMUSGfm4g5f8EW4HXRomEyW0iqDQX0Lb3OQcKLr(ddg7Z1ifEqTdrleG)dfPgDOOGoKOIhCOSEizrYUa1jldwur(ddUQhV3nqsTGfmE3HXddMgbQtnMUmyfidcKcd29dbH792sW70T4Lmyrf5pmy8kzYG0QSGXRRy8WGPrG6uJPldwbYGaPWGxFO1hA9HcPttylibeM3BIcY4K9MLgbQtTdX9qq4EVTGeqyEVjkiJt2Bw8YdT5qCp06d1a4zZQKWHKfYarc4qRwDOgapB23P7qYczGibCOnhI7HC)qq4EVTe8oDlE5H2COvRo06dT(qq4EVfIavcO3arcWIxEOvRoeeU3BZrjGrI8hdgCb0szmV3GdQVYIxEOnhI7HwFi3pudGNnRschswidejGdX9qUFOgapB23P7qYczGibCOnhAZH2WGfvK)WGl)i)HfmE3nJhgmncuNAmDzWkqgeifgCdGNnRschswidejGdX9qq4EVvjHX)anlEjdUgGufmE1HblQi)HbdWhJOI8htpRbdUN1WmIgXGvs4qYcXcgVUGXddMgbQtnMUmyfidcKcdUbWZM9D6oKSqgisahI7HGW9ER2)J(Cm(hOzXlzW1aKQGXRomyrf5pmya(yevK)y6znyW9SgMr0ig870DizHybJ3DHXddMgbQtnMUm4gvvGSmYFyWyx)HCOdvil0H2(5xja5qDcdnnbW)HODfpllP2HKPDiiPlJIoK495Kb)hsQhsouiDAId5qhQ6KHQ4q5e)H0(F0NZH8pq7qof0qle4qrbDOo)kbihcc37puwpKeh6bhcI6VZH25qvsXGfvK)WGb4Jrur(JPN1GbRazqGuyWRp06dbWhY)amKTZVsas147ef5GXGPNALvYs7kEwwsTdT5qCp06dfsNMWcjDzuKr8(CYGFlncuNAhAZH4EO1hcc37TD(vcqQgFNOihmgm9uRSsw8YdT5qCp06dbH792o)kbivJVtuKdgdMEQvwjlG0KCQhAlohANdT5qByW9SgMr0igCNFLaKNfmE3gmEyW0iqDQX0Lb3OQcKLr(ddg76pKdDOczHo02p)kbihQtyOPja(peTR4zzj1oKmTd5jG0pK495Kb)hsQhsouiDAId5qhQ6KHQ4q5e)H8eq6hY)aTd5uqdTqGdff0H68ReGCiiCV)qz9qsCOhCiiQ)ohANdvjfdwur(ddgGpgrf5pMEwdgScKbbsHbV(qRpeaFi)dWq2o)kbivJVtuKdgdMEQvwjlTR4zzj1o0MdX9qRpuiDAcRNas3iEFozWVLgbQtTdT5qCp06dbH792o)kbivJVtuKdgdMEQvwjlE5H2CiUhA9HGW9EBNFLaKQX3jkYbJbtp1kRKfqAso1dTfNdTZH2COnm4EwdZiAedUZVsaIIfmE3omEyW0iqDQX0Lb3OQcKLr(ddg76pKdH9a0HKdnjMIWl0HKPDih6qTFWEXHCKjou8hsjHdjleFVt3HKfcRdjt7qo0HkKf6qqsxgfXNNas)qI3Ntg8FOq60eudRdT9wqdTqGdP(z51ths1ouwpeE5HCOdvDYqvCOCI)qI3Ntg8Fi)d0ou8hsj14qzG1HkiaDiT)h95Ci)d0Smyrf5pmya(yevK)y6znyWkqgeifgCLIihmvBTi9HX)aJ6NLxpDiUhA9HwFOq60ewiPlJImI3Ntg8BPrG6u7qBoe3dT(qUFOgapBwLeoKSqgisahAZH4EO1hY9d1a4zZ(oDhswidejGdT5qCp06dP(fAKjStIPimEHoe3dP(V3ENXQ(z51tMOGm1YeKr1cinjN6H2IZH05qBo0ggCpRHzenIb)QFwE9ely8Unz8WGPrG6uJPldUrvfilJ8hgm21Fihc7bOdjhAsmfHxOdjt7qo0HA)G9Id5itCO4pKschswi(ENUdjlewhsM2HCOdvil0HGKUmkIppbK(HeVpNm4)qH0PjOgwhA7TGgAHahs9ZYRNoKQDOSEi8Yd5qhQ6KHQ4q5e)HeVpNm4)q(hODO4pKsQXHYaRdvqa6qkj8pq7q(hOzzWIkYFyWa8XiQi)X0ZAWGvGmiqkm4kfroyQ2Ar6dJ)bg1plVE6qCp06dT(qH0PjSEciDJ495Kb)wAeOo1o0MdX9qRpK7hQbWZMvjHdjlKbIeWH2CiUhA9HC)qnaE2SVt3HKfYarc4qBoe3dT(qQFHgzc7KykcJxOdX9qQ)7T3zSQFwE9KjkitTmbzuTastYPEOT4CiDo0MdTHb3ZAygrJyWk1plVEIfmE1XLmEyW0iqDQX0LblQi)HbRKE3iQi)X0ZAWG7znmJOrmyTmsmsK)WcgV6OdJhgmncuNAmDzWIkYFyWa8XiQi)X0ZAWG7znmJOrmyisaSGfm4saPEnijy8W4vhgpmyAeOo1y6YGBuvbYYi)HbJ95AKcpO2HGi)dOdPEnijoeeHjNQ9qBFkfvg1dn)G9xianpE)qIkYFQh6No)wgSOI8hgS(CAaQzQLjiJkly8UdJhgmncuNAmDzWkqgeifgmeU3Bvsy8pqZIxEiUhQbWZMvjHdjlKbIeadwur(ddUe8oDwW41vmEyW0iqDQX0LbRazqGuyWUFiiCV3kd)g)d0S4LhI7HwFi3pudGNnRschswidejGdTA1HGW9ERscJ)bA227mhAZH4EO1hY9d1a4zZ(oDhswidejGdTA1HGW9ER2)J(Cm(hOzBVZCOnmyrf5pmyisag)d0ybJ3DZ4HbtJa1PgtxgScKbbsHbhsNMWwqcimV3efKXj7nlncuNAhI7HwFOgapBwLeoKSqgisahI7HGW9ERscJ)bAw8YdTA1HAa8SzFNUdjlKbIeWH4EiiCV3Q9)OphJ)bAw8YdTA1HGW9ER2)J(Cm(hOzXlpe3dfsNMWcjDzuKr8(CYGFlncuNAhAddwur(ddUGeqyEVjkiJt2BSGXRly8WGPrG6uJPldwbYGaPWGHW9ER2)J(Cm(hOzXlpe3d1a4zZ(oDhswidejGdX9qUFi1VqJmHDsmfHXledwur(dd2birbly8UlmEyW0iqDQX0LbRazqGuyWq4EVv7)rFog)d0S4LhI7HAa8SzFNUdjlKbIeWH4Ei1VqJmHDsmfHXledwur(ddUgcWNaIfSGbR(V3ENPY4HXRomEyWIkYFyWLFK)WGPrG6uJPlly8UdJhgSOI8hgmu))MXJd4NbtJa1PgtxwW41vmEyWIkYFyWqeOsa95GHbtJa1PgtxwW4D3mEyWIkYFyWcqjdzIhaOjyW0iqDQX0LfmEDbJhgSOI8hgCpXuevZ2d8ggnAcgmncuNAmDzbJ3DHXddwur(dd2NacQ)FJbtJa1PgtxwW4DBW4HblQi)HblJIQbq6gL07myAeOo1y6YcgVBhgpmyAeOo1y6YGvGmiqkmyiCV3crcW4FGMfVKblQi)HbdbYA0ZbJXJdybJ3TjJhgmncuNAmDzWkqgeifg86d1(WQ9)4tazJuPphmhA1QdjQixidnKws1dHTdPZH2CiUhQ9HnkasTWarcWgPsFoyyWIkYFyW5OeWir(dly8QJlz8WGfvK)WGHiqLa6zW0iqDQX0LfmE1rhgpmyAeOo1y6YGfvK)WGv8R6Fa(jvgOUudgm59KkmJOrmyf)Q(hGFsLbQl1GfmE1zhgpmyrf5pmy8kzYG0QmyAeOo1y6YcwWGF1plVEIXdJxDy8WGfvK)WG1(F0NJX)angmncuNAmDzbJ3Dy8WGPrG6uJPldwbYGaPWGdPttylibeM3BIcY4K9MLgbQtTdX9qUFiiCV3wqcimV3efKXj7nlEjdwur(ddUGeqyEVjkiJt2BSGXRRy8WGPrG6uJPldwbYGaPWGRpEhkNM1NGAyQbi1twAeOo1oe3dbH79wFcQHPgGupzXlzWIkYFyWQFwE9KjkitTmbzuzbJ3DZ4HbtJa1PgtxgScKbbsHbtQEwwjRm8BgY1IdTA1HivplRKT(DbygY1cgSOI8hgCneGpbely86cgpmyAeOo1y6YGvGmiqkmys1ZYkzLHFZqUwCOvRoeP6zzLSD8raMHCTGblQi)Hb7aKOGfmE3fgpmyAeOo1y6YGvGmiqkm4q60e2csaH59MOGmozVzPrG6u7qCpeeU3BlibeM3BIcY4K9MfVKblQi)HbR(z51tMOGm1YeKrLfmE3gmEyW0iqDQX0LbRazqGuyWH0PjSfKacZ7nrbzCYEZsJa1P2H4Ei1)927m2csaH59MOGmozVzbKMKt9qy7q64cgSOI8hgS6NLxpzIcYultqgvwW4D7W4HbtJa1PgtxgScKbbsHb7(HcPttylibeM3BIcY4K9MLgbQtngSOI8hgS6NLxpzIcYultqgvwWcgSs9ZYRNy8W4vhgpmyrf5pmyLeg)d0yW0iqDQX0LfmE3HXddMgbQtnMUmyfidcKcdoKonHTGeqyEVjkiJt2BwAeOo1oe3d5(HGW9EBbjGW8EtuqgNS3S4Lmyrf5pm4csaH59MOGmozVXcgVUIXddMgbQtnMUmyfidcKcdU(4DOCAwFcQHPgGupzPrG6u7qCpeeU3B9jOgMAas9KfVKblQi)HbR(z51tMOGm1YeKrLfmE3nJhgmncuNAmDzWkqgeifgCiDAcBbjGW8EtuqgNS3S0iqDQDiUhcc37TfKacZ7nrbzCYEZIxYGfvK)WGv)S86jtuqMAzcYOYcgVUGXddMgbQtnMUmyfidcKcdoKonHTGeqyEVjkiJt2BwAeOo1oe3dP(V3ENXwqcimV3efKXj7nlG0KCQhcBhshxWGfvK)WGv)S86jtuqMAzcYOYcgV7cJhgmncuNAmDzWkqgeifgS7hkKonHTGeqyEVjkiJt2BwAeOo1yWIkYFyWQFwE9KjkitTmbzuzblyWVt3HKfIXdJxDy8WGPrG6uJPldwbYGaPWGD)qq4EVv7)rFog)d0S4Lmyrf5pmyT)h95y8pqJfmE3HXddMgbQtnMUmyfidcKcdoKonHTGeqyEVjkiJt2BwAeOo1oe3d5(HGW9EBbjGW8EtuqgNS3S4Lmyrf5pm4csaH59MOGmozVXcgVUIXddwur(ddUgcOIdWqmyAeOo1y6YcgV7MXddMgbQtnMUmyfidcKcdU(4DOCAwFcQHPgGupzPrG6uJblQi)HbR(z51tMOGm1YeKrLfmEDbJhgmncuNAmDzWkqgeifgCdGNn770DizHmqKayWIkYFyWKw57qad0pnwW4Dxy8WGPrG6uJPldwbYGaPWGxFi3pu7dR0KYixit1raAMMOjyiBKk95G5qCpK7hsur(JvAszKlKP6iantt0emKnhJVNykIdX9qRpK7hQ9HvAszKlKP6iantbjDBKk95G5qRwDO2hwPjLrUqMQJa0mfK0TastYPEiSDixDOnhA1Qd1(WknPmYfYuDeGMPjAcgYwdrP)qBDixDiUhQ9HvAszKlKP6iantt0emKfqAso1dT1HCXH4EO2hwPjLrUqMQJa0mnrtWq2iv6ZbZH2WGfvK)WGLMug5czQocqJfmE3gmEyW0iqDQX0LblQi)HbxXhFcigScKbbsHbdipGQfcuNyWk(vDYecadfvgV6WcgVBhgpmyAeOo1y6YGfvK)WG1(F8jGyWkqgeifgmG8aQwiqD6qRwDiiCV3Ir6IksLbdUaAPmw8sgSIFvNmHaWqrLXRoSGX72KXddMgbQtnMUmyfidcKcdw9l0ityNetry8cDiUhIu9SSswz43mKRfmyrf5pm4AiaFciwW4vhxY4HbtJa1PgtxgScKbbsHb7(Hu)cnYe2jXuegVqhI7HivplRKvg(nd5Abdwur(dd2birbly8QJomEyW0iqDQX0LbRazqGuyWRpeeU3BjvplRKPJpcWIxEOvRoeeU3BjvplRKP(DbyXlp0ggSOI8hgS6NLxpzIcYultqgvwW4vNDy8WGPrG6uJPldwbYGaPWGxFis1ZYkzZX0XhbCOvRoeP6zzLS1VlaZqUwCOnhA1QdT(qKQNLvYMJPJpc4qCpeeU3BRHaQ4amKH0kFhcOrty64JaS4LhAddwur(ddUgcWNaIfmE1XvmEyWIkYFyWoajkyW0iqDQX0LfSGfm4fcuZFy8UJl3rhx6kxUnS6WGDeWKdMkdg7Qv(GGAhshDoKOI8Nd1ZAuT3EgCTKumE1XL7MbxcEF2jg82EixFCb0szoKRxaE2U9B7H2(kbz)q7G1H2XL74YB)TFBp02Tqgmu11ZTFBpe2)HWUJ6bLpqc6qBxj4B75)J(CoujiFqgjvp060FOkfroyouwpKQGu6P2g7TFBpe2)HWUJ6bLpqc6qFzK)CO4puTi9XHw)GdnFS5qqK)b0H2U)S86j7T)2VThc7Z1ifEqTdbr(hqhs9AqsCiictov7H2(ukQmQhA(b7VqaAE8(HevK)up0pD(T3Erf5pvBjGuVgKeUXHp950auZultqg1BVOI8NQTeqQxdsc34Wxj4D6yLEoq4EVvjHX)anlEj3gapBwLeoKSqgisa3Erf5pvBjGuVgKeUXHpisag)d0Wk9CChc37TYWVX)anlEj31U3a4zZQKWHKfYarcy1kiCV3QKW4FGMT9oZgURDVbWZM9D6oKSqgisaRwbH79wT)h95y8pqZ2ENzZTxur(t1wci1RbjHBC4RGeqyEVjkiJt2ByLEoH0PjSfKacZ7nrbzCYEZsJa1Pg31naE2SkjCizHmqKa4cH79wLeg)d0S4LRw1a4zZ(oDhswidejaUq4EVv7)rFog)d0S4LRwbH79wT)h95y8pqZIxYnKonHfs6YOiJ495Kb)wAeOo12C7fvK)uTLas9Aqs4gh(CasuGv65aH79wT)h95y8pqZIxYTbWZM9D6oKSqgisaCDx9l0ityNetry8cD7fvK)uTLas9Aqs4gh(QHa8jGWk9CGW9ER2)J(Cm(hOzXl52a4zZ(oDhswidejaUQFHgzc7KykcJxOB)TFBpe2NRrk8GAhIwia)hksn6qrbDirfp4qz9qYIKDbQt2BVOI8NkNQE8E3aj1IBVOI8NQBC4dVsMmiTkwPNJ7q4EVTe8oDlE5Txur(t1no8v(r(dwPNZ61RdPttylibeM3BIcY4K9MLgbQtnUq4EVTGeqyEVjkiJt2Bw8YnCx3a4zZQKWHKfYarcy1QgapB23P7qYczGibSHR7q4EVTe8oDlE5MvRwVgc37TqeOsa9gisaw8YvRGW9EBokbmsK)yWGlGwkJ59gCq9vw8YnCx7EdGNnRschswidejaUU3a4zZ(oDhswidejGnB2C732T9qBxjCizjhmhsur(ZH6znoKt27hcIoeqMdLESoKMmy6eFrbqQfhsa0H(5qQgwhciyOdL1dbr935q72LyDixhb0FizAhkhLagjYFoKaOd1EN5qY0oKRpU0fvKQdHbxaTuMdbH79hkRhA(4qIkYfcRd9GdLESoKdH9a0HY5qkj8pq7qY0oenead)hkRhsG(f6q74cSoe2b4qP)qo0HkKf6qrbDiSdjkouNWqtta8FiAxXZYsQH1HIc6qncc37puph9u7qXFOmouwp08XHWlpKmTdrdbWW)HY6HeOFHo0oUelSdWHs)HCiShGoKE(bPmhsM2HW(0kFhcCiOFAhs9FV9oZHY6HWlpKmTdrdPLu9qcGouoEcKp4qXFODS3(TDBpKOI8NQBC4dGpgrf5pMEwdSgrJ4OKWHKfcR0ZPbWZMvjHdjlKbIea31Rv)3BVZyJcGulmqKaSastYPInxYv9FV9oJvtgmDYcinjNk2Cj32hwT)hFcilG0KCQyJdgvZnxADbxGGH2A3UKleU3BZrjGrI8hdgCb0szmV3GdQVY2ENHleU3BHiqLa6nqKaST3z4cH79wmsxurQmyWfqlLX2ENzZQvRHW9ERscJ)bAw8sU0qam8JTDCXMvRw3(Wce9KfqEavleOoXT9HfKLwa5buTqG60MvRwdWhY)amK9LOW8EtuqgQ3iGPbWZML2v8SSKACDhc37TVefM3BIcYq9gbmnaE2S4LCxdH79wLeg)d0S4LCPHay4hB74YnCHW9EBbjGW8EtuqgNS3SastYPUfhDC5MvRwR(fAKjS65hKYWv9FV9oJL0kFhcyG(PzbKMKtDlo6WvurUqgAiTKQBTZMvRwdH792csaH59MOGmozVzXl5sdbWWp22MUCZMBVOI8NQBC4dGpgrf5pMEwdSgrJ4OKWHKfcRAasvWrhSspNgapBwLeoKSqgisaCHW9ERscJ)bAw8YB)2UThc7WP7qYsoyoKOI8Nd1ZACiNS3peeDiGmhk9yDinzW0j(IcGuloKaOd9ZHunSoeqWqhkRhcI6VZH0XfyDixhb0FizAhkhLagjYFoKaOd1EN5qY0oKRpU0fvKQdHbxaTuMdbH79hkRhA(4qIkYfYEiSdWHspwhYHWEa6q5CiT)h95Ci)d0oKmTdvXhFcOdL1dbipGQfcuNW6qyhGdL(d5qhQqwOdff0HWoKO4qDcdnnbW)HODfpllPgwhkkOd1iiCV)q9C0tTdf)HY4qz9qZhhcV0IDaou6pKdH9a0H0ZpiL5qY0oe2Nw57qGdb9t7qQ)7T3zouwpeE5HKPDiAiTKQhsa0HGO(7CODW6qp4qP)qoe2dqhI3etrCiVqhsM2H2U)S86PdPAhkRhcV0E732T9qIkYFQUXHpa(yevK)y6znWAenIZ70DizHWk9CAa8SzFNUdjlKbIea31Rv)3BVZyJcGulmqKaSastYPInxYv9FV9oJvtgmDYcinjNk2CjxGGH2AhxYfc37T5OeWir(JT9odxiCV3crGkb0BGibyBVZSz1Q1q4EVv7)rFog)d0S4LCBFyR4JpbKfqEavleOoTz1Q1q4EVv7)rFog)d0S4LCHW9EBbjGW8EtuqgNS3S4LBwTAneU3B1(F0NJX)anlEj31q4EVLu9SSsMo(ialE5Qvq4EVLu9SSsM63fGfVCdx3b4d5FagY(suyEVjkid1BeW0a4zZs7kEwwsTnRwTgGpK)byi7lrH59MOGmuVratdGNnlTR4zzj146oeU3BFjkmV3efKH6ncyAa8SzXl3SA1A1VqJmHDsmfHXlex1)927mw1plVEYefKPwMGmQwaPj5u3IJoBwTAT6xOrMWQNFqkdx1)927mwsR8DiGb6NMfqAso1T4Odxrf5czOH0sQU1oB2C7fvK)uDJdFa8XiQi)X0ZAG1iAeN3P7qYcHvnaPk4OdwPNtdGNn770DizHmqKa4cH79wT)h95y8pqZIxE732dHD9hYHouHSqhA7NFLaKd1jm00ea)hI2v8SSKAhsM2HGKUmk6qI3Ntg8FiPEi5qH0PjoKdDOQtgQIdLt8hs7)rFohY)aTd5uqdTqGdff0H68ReGCiiCV)qz9qsCOhCiiQ)ohANdvj1Txur(t1no8bWhJOI8htpRbwJOrC68ReG8yLEoRxdWhY)amKTZVsas147ef5GXGPNALvYs7kEwwsTnCxhsNMWcjDzuKr8(CYGFlncuNAB4Ugc37TD(vcqQgFNOihmgm9uRSsw8YnCxdH792o)kbivJVtuKdgdMEQvwjlG0KCQBXzNnBU9B7HWU(d5qhQqwOdT9ZVsaYH6egAAcG)dr7kEwwsTdjt7qEci9djEFozW)HK6HKdfsNM4qo0HQozOkouoXFipbK(H8pq7qof0qle4qrbDOo)kbihcc37puwpKeh6bhcI6VZH25qvsD7fvK)uDJdFa8XiQi)X0ZAG1iAeNo)kbikSspN1Rb4d5FagY25xjaPA8DIICWyW0tTYkzPDfpllP2gURdPtty9eq6gX7Zjd(T0iqDQTH7AiCV325xjaPA8DIICWyW0tTYkzXl3WDneU3B78ReGun(orroymy6PwzLSastYPUfND2S52VThc76pKdH9a0HKdnjMIWl0HKPDih6qTFWEXHCKjou8hsjHdjleFVt3HKfcRdjt7qo0HkKf6qqsxgfXNNas)qI3Ntg8FOq60eudRdT9wqdTqGdP(z51ths1ouwpeE5HCOdvDYqvCOCI)qI3Ntg8Fi)d0ou8hsj14qzG1HkiaDiT)h95Ci)d0S3Erf5pv34WhaFmIkYFm9SgynIgX5v)S86jSspNkfroyQ2Ar6dJ)bg1plVEI761H0PjSqsxgfzeVpNm43sJa1P2gURDVbWZMvjHdjlKbIeWgURDVbWZM9D6oKSqgisaB4Uw9l0ityNetry8cXv9FV9oJv9ZYRNmrbzQLjiJQfqAso1T4OZMn3(T9qyx)HCiShGoKCOjXueEHoKmTd5qhQ9d2loKJmXHI)qkjCizH47D6oKSqyDizAhYHouHSqhcs6YOi(8eq6hs8(CYG)dfsNMGAyDOT3cAOfcCi1plVE6qQ2HY6HWlpKdDOQtgQIdLt8hs8(CYG)d5FG2HI)qkPghkdSoubbOdPKW)aTd5FGM92lQi)P6gh(a4Jrur(JPN1aRr0iok1plVEcR0ZPsrKdMQTwK(W4FGr9ZYRN4UEDiDAcRNas3iEFozWVLgbQtTnCx7EdGNnRschswidejGnCx7EdGNn770DizHmqKa2WDT6xOrMWojMIW4fIR6)E7DgR6NLxpzIcYultqgvlG0KCQBXrNnBU9IkYFQUXHpL07grf5pMEwdSgrJ4OLrIrI8NBVOI8NQBC4dGpgrf5pMEwdSgrJ4arc42F7fvK)uTqKa4arcW4FGgwPNJ7q4EVfIeGX)anlE5Txur(t1crcWno8bKfAE8QXdOX1X)Txur(t1crcWno8P(z51tMOGm1YeKrfR0ZX9gapBwLeoKSqgisaCDVbWZM9D6oKSqgisa3Erf5pvleja34WhebQeqVbIeawPNZAiCV3cKfAE8QXdOX1XVfVC1k3v)cnYe2fAIc(bBU9IkYFQwisaUXHVCucyKi)bR0ZzneU3BbYcnpE14b04643IxUAL7QFHgzc7cnrb)Gn3Erf5pvleja34WhebQeqFoyWk9CwdH79wicujGEdejalE5Qvq4EVnhLagjYFmyWfqlLX8EdoO(klE5MBVOI8NQfIeGBC4tAszKlKP6ianSspN1U3(WknPmYfYuDeGMPjAcgYgPsFoy46UOI8hR0KYixit1raAMMOjyiBogFpXueCx7E7dR0KYixit1raAMcs62iv6ZbZQvTpSstkJCHmvhbOzkiPBbKMKtfBUAZQvTpSstkJCHmvhbOzAIMGHS1qu63YvCBFyLMug5czQocqZ0enbdzbKMKtDlxWT9HvAszKlKP6iantt0emKnsL(CWS52lQi)PAHib4gh(IcGulmqKaWkeagkmPNdG8aQwiqDA1Q2h2Oai1cdejaBneL(TC1QvRBFyJcGulmqKaS1qu63A3Cb4d5FagY2X9EjhpELAgsdcikYs7kEwwsTnRwjQixidnKwsvSXz33Erf5pvleja34WN2)JpbewPNZ61q4EVfJ0fvKkdgCb0szS4LB4kQixidnKws1T2zZQvRxdH79wmsxurQmyWfqlLXIxUHR7TpSA)p(eq2iv6Zbdxrf5czOH0sQInD4gcadf2i1it8MwsytND2C7fvK)uTqKaCJdFA)p(eqyLEoRBFy1(F8jGSastYPUfhxXDneU3BXiDrfPYGbxaTuglE5gUIkYfYqdPLufBUGBiamuyJuJmXBAjHnD2zZTxur(t1crcWno8PjdMoHv65aemKTr(uLb20XLCRue5GPA1KbtNmApGU9IkYFQwisaUXHpT)hFciSspN1aYdOAHa1jUIkYfYqdPLuDRD4gcadf2i1it8MwsytND2SA1A3BFy1(F8jGSrQ0NdgUIkYfYqdPLufB6WneagkSrQrM4nTKWMo7S52lQi)PAHib4gh(QozjHv65aH792CucyKi)XGbxaTugZ7n4G6RST3z4cH79wicujGEdejaB7DgUIkYfYqdPLufBC29Txur(t1crcWno8Pj4DSsphiCV3MJsaJe5pw8sUIkYfYqdPLuDRDU9IkYFQwisaUXHpnbVJv65Sgc37TvzrWqg1RbjHmHTgIsp24OZgURHW9EB8FuyKPzuDXXIxUHleU3BZrjGrI8hlEjxrf5czOH0sQYzNBVOI8NQfIeGBC4ttgmDcR0Zbc37T5OeWir(JfVKROICHm0qAjv3IJRU9IkYFQwisaUXHpnbVJv65SE9AiCV3g)hfgzAgvxCS1qu6XgND2SA1AiCV3g)hfgzAgvxCS4LCHW9EB8FuyKPzuDXXcinjN6w6yDXMvRwdH792QSiyiJ61GKqMWwdrPhBCC1MnCfvKlKHgslP6wUAZTxur(t1crcWno8ffaPwyGibGv65iQixidnKwsvSPZTxur(t1crcWno8PjdMoHv65SEnqWqBTnD5gUIkYfYqdPLuDlxTz1Q1RbcgARTJl2WvurUqgAiTKQB5kUH0PjS1hVBEVjkiJ)bunS0iqDQT52lQi)PAHib4gh(kX7leiDDewk(vDYecadfvo6Gv650(WgfaPwyGibyRHO0JTDU9IkYFQwisaUXHVOai1cdejGBVOI8NQfIeGBC4ttW7yLEoIkYfYqdPLuDlxD7fvK)uTqKaCJdFvNSKmqKaU9IkYFQwisaUXHVe8JhhGv65aemKTr(uLXw72LCHW9EBc(XJdSastYPULlTU42F7fvK)uTAzKyKi)Htc(XJdWk9CYr9A5GX0enbdzCrfBj4hpoW0enbdzIcavl(EJleU3BtWpECGfqAso1TCf2zHud62lQi)PA1YiXir(JBC4dqd5iDSspNqg95GHBbj9OWwQIT2fxC7fvK)uTAzKyKi)Xno85b046sQzaegAiGe5pyLEoHm6Zbd3cs6rHTufBTlU42lQi)PA1YiXir(JBC4J0kFhcyG(PHv65S29gapBwLeoKSqgisaCDVbWZM9D6oKSqgisaBwTsurUqgAiTKQyJZo3Erf5pvRwgjgjYFCJdFqcqFvFoyLEoHm6Zbd3cs6rHTufBTnCb3CuVwoymnrtWqgxuXMlT6GDwqspkSAIRD7fvK)uTAzKyKi)Xno8vXbl5I0n5uJCurfR0Zbc37TvCWsUiDto1ihvuTT3z4cH79wibOVQphB7DgUfK0JcBPk2AxCj3CuVwoymnrtWqgxuXMlT74cSZcs6rHvtCTB)Txur(t1Q(V3ENPYP8J8NBVOI8NQv9FV9ot1no8b1)Vz84a(V9IkYFQw1)927mv34WhebQeqFoyU9IkYFQw1)927mv34WNauYqM4baAIBVOI8NQv9FV9ot1no81tmfr1S9aVHrJM42lQi)PAv)3BVZuDJdF(eqq9)B3Erf5pvR6)E7DMQBC4tgfvdG0nkP3V9IkYFQw1)927mv34WheiRrphmgpoaR0Zbc37TqKam(hOzXlV9IkYFQw1)927mv34WxokbmsK)Gv65SU9Hv7)XNaYgPsFoywTsurUqgAiTKQytNnCBFyJcGulmqKaSrQ0NdMBVOI8NQv9FV9ot1no8brGkb0F7fvK)uTQ)7T3zQUXHp8kzYG0WI8EsfMr0iok(v9pa)KkduxQXTxur(t1Q(V3ENP6gh(WRKjdsRE7V9IkYFQwLeoKSqCkbVt)2lQi)PAvs4qYc5gh(usy8pqdR0ZXDiCV3QKW4FGMfV82lQi)PAvs4qYc5gh(aIEcR0Zbc37TLG3PBXlV9IkYFQwLeoKSqUXHVcsaH59MOGmozVHv65esNMWwqcimV3efKXj7nlncuNACDhc37TfKacZ7nrbzCYEZIxE7fvK)uTkjCizHCJdFKw57qad0pnSspNgapBwLeoKSqgisa3Erf5pvRschswi34Whq0tyLEoTpSarpzbKhq1cbQtCvVg0Bk)CI6w7(2lQi)PAvs4qYc5gh(azjwPNt7dlilTaYdOAHa1jUQxd6nLForfBC29Txur(t1QKWHKfYno8P(z51tMOGm1YeKrfR0ZPbWZMvjHdjlKbIeWTxur(t1QKWHKfYno85jWRYhVAGYGWstCndnead)C0bR0Zr9AqVP8ZjQyJZUV9IkYFQwLeoKSqUXHpPjLrUqMQJa0Wk9Cw7E7dR0KYixit1raAMMOjyiBKk95GHR7IkYFSstkJCHmvhbOzAIMGHS5y89etrWDT7TpSstkJCHmvhbOzkiPBJuPphmRw1(WknPmYfYuDeGMPGKUfqAsovS5QnRw1(WknPmYfYuDeGMPjAcgYwdrPFlxXT9HvAszKlKP6iantt0emKfqAso1TCb32hwPjLrUqMQJa0mnrtWq2iv6ZbZMBVOI8NQvjHdjlKBC4RwaOgwPNJ61GEt5NtuTkCaGMylxC7V9IkYFQwL6NLxpXrjHX)aTBVOI8NQvP(z51tUXHVcsaH59MOGmozVHv65esNMWwqcimV3efKXj7nlncuNACDhc37TfKacZ7nrbzCYEZIxE7fvK)uTk1plVEYno8P(z51tMOGm1YeKrfR0ZP(4DOCAwFcQHPgGupzPrG6uJleU3B9jOgMAas9KfV82lQi)PAvQFwE9KBC4t9ZYRNmrbzQLjiJkwPNtiDAcBbjGW8EtuqgNS3S0iqDQXfc37TfKacZ7nrbzCYEZIxE7fvK)uTk1plVEYno8P(z51tMOGm1YeKrfR0ZjKonHTGeqyEVjkiJt2BwAeOo14Q(V3ENXwqcimV3efKXj7nlG0KCQythxC7fvK)uTk1plVEYno8P(z51tMOGm1YeKrfR0ZX9q60e2csaH59MOGmozVzPrG6u72F7fvK)uTD(vcquCusy8pq72F7fvK)uTD(vcqEoA)p6ZX4FG2T)2lQi)PAF1plVEIJ2)J(Cm(hOD7fvK)uTV6NLxp5gh(kibeM3BIcY4K9gwPNtiDAcBbjGW8EtuqgNS3S0iqDQX1DiCV3wqcimV3efKXj7nlE5Txur(t1(QFwE9KBC4t9ZYRNmrbzQLjiJkwPNt9X7q50S(eudtnaPEYsJa1PgxiCV36tqnm1aK6jlE5Txur(t1(QFwE9KBC4RgcWNacR0ZHu9SSswz43mKRfRwrQEwwjB97cWmKRf3Erf5pv7R(z51tUXHphGefyLEoKQNLvYkd)MHCTy1ks1ZYkz74Jamd5AXTxur(t1(QFwE9KBC4t9ZYRNmrbzQLjiJkwPNtiDAcBbjGW8EtuqgNS3S0iqDQXfc37TfKacZ7nrbzCYEZIxE7fvK)uTV6NLxp5gh(u)S86jtuqMAzcYOIv65esNMWwqcimV3efKXj7nlncuNACv)3BVZylibeM3BIcY4K9MfqAsovSPJlU9IkYFQ2x9ZYRNCJdFQFwE9KjkitTmbzuXk9CCpKonHTGeqyEVjkiJt2BwAeOo1U93Erf5pv770DizH4O9)OphJ)bAyLEoUdH79wT)h95y8pqZIxE7fvK)uTVt3HKfYno8vqcimV3efKXj7nSspNq60e2csaH59MOGmozVzPrG6uJR7q4EVTGeqyEVjkiJt2Bw8YBVOI8NQ9D6oKSqUXHVAiGkoadD7fvK)uTVt3HKfYno8P(z51tMOGm1YeKrfR0ZP(4DOCAwFcQHPgGupzPrG6u72lQi)PAFNUdjlKBC4J0kFhcyG(PHv650a4zZ(oDhswidejGBVOI8NQ9D6oKSqUXHpPjLrUqMQJa0Wk9Cw7E7dR0KYixit1raAMMOjyiBKk95GHR7IkYFSstkJCHmvhbOzAIMGHS5y89etrWDT7TpSstkJCHmvhbOzkiPBJuPphmRw1(WknPmYfYuDeGMPGKUfqAsovS5QnRw1(WknPmYfYuDeGMPjAcgYwdrPFlxXT9HvAszKlKP6iantt0emKfqAso1TCb32hwPjLrUqMQJa0mnrtWq2iv6ZbZMBVOI8NQ9D6oKSqUXHVk(4taHLIFvNmHaWqrLJoyLEoaYdOAHa1PBVOI8NQ9D6oKSqUXHpT)hFciSu8R6KjeagkQC0bR0ZbqEavleOoTAfeU3BXiDrfPYGbxaTuglE5Txur(t1(oDhswi34WxneGpbewPNJ6xOrMWojMIW4fIlP6zzLSYWVzixlU9IkYFQ23P7qYc5gh(CasuGv654U6xOrMWojMIW4fIlP6zzLSYWVzixlU9IkYFQ23P7qYc5gh(u)S86jtuqMAzcYOIv65Sgc37TKQNLvY0XhbyXlxTcc37TKQNLvYu)UaS4LBU9IkYFQ23P7qYc5gh(QHa8jGWk9CwtQEwwjBoMo(iGvRivplRKT(DbygY1InRwTMu9SSs2CmD8raCHW9EBneqfhGHmKw57qanActhFeGfVCZTxur(t1(oDhswi34WNdqIcwWcgd]] )


end