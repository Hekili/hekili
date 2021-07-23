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

    spec:RegisterPack( "Guardian", 20210723, [[dCKL7bqifrpcuPSjLQpHsPAukPoLsXQuKk8kfjZcu1TavISls(Lq0WqHCmuslduXZuKY0qHY1qPyBGkPVHcvnoqLkNtrQ06avIY8uk5EOO9PuQdcQevlur4HOqfteuPQCrfPI(iOsvojkLYkrjMjkuPUjOsv1orP6NOucpfQMQq4ROqLSxu9xkgmKdtSyqEmPMScxgzZc(mOmAH60IwnkLOxlKMTe3Ms2Tu)gy4kXXrPKwUkpxstNQRdLTRO(oLA8ksvNhfSEqLW8vs2VQMZkpco(qCIZoCyeCyLrmE4mnfRmEgbxzeCLJ7mSqC8frhvGrC8wSiooCpm5gP0C8fHHcqg8i44va2PjoES7lv4YImsyPhJbP0aRiRPfwr8e06tcEK10shjhhclloBR5qC8H4eND4Wi4WkJy8WzAkwz8mIXyZ0LJlyEm4444PfJdhpohdQ5qC8bv1CC4EyYnsPFeCFhwoEwybRWWJyLnW)i4Wi4W6ZYZcJtS0WOkCzplWLEeBR1GBbCItpIXr8iH7ha6Oz)OLlbx6jvF06m8Ok5E2WEuwFKoM0rPXg1ZcCPhX2An4waN40JalEc6h5GhvJZG)O1G7rnW38iikao6rmoGEgeLuC8sw9kpcoEHbTCcGhbNDw5rWXfTNGMJBbaD0SnbWzXXPwGk0Gpb35ohhIKJhbNDw5rWXPwGk0GpbhxFPtxkC8jFeewiOGi5mbWzPWw44I2tqZXHi5mbWzXDo7WHhbhNAbQqd(eCC9LoDPWXDPqTRIj5Cdiy8yYyNLHIAbQqJhT)O1pYLc1UcsksRjJeczNodkQfOcnE0MhT)inyMAPD1m1Emdhhx0EcAoEmjNBabJhtg7Sm4oN9PXJGJtTavObFcoU(sNUu44RF06hbHfckysr0EQnWWKBKsRWwE0MhT)ir75mzOMSsQ(OTEeCE0MhTA1Jw)O1pccleuWKIO9uBGHj3iLwHT8OnpA)rt(ObWvwaqhYJuEQJMnShT)ir75mzOMSsQ(OTFeRpA)rUCWix5PfzCGzK0J2(rScNhTHJlApbnh3ca6qEe35SZy8i44ulqfAWNGJRV0Plfo(6hnaUYca6qEK6ilj76J2I5JM2J2F06hbHfckysr0EQnWWKBKsRWwE0MhT)ir75mzOMSsQ(OTFeBE0(JC5GrUYtlY4aZiPhT9JyfopAdhx0EcAoUfa0H8iUZzNn8i44ulqfAWNGJRV0Plfo(6hDu4OASavOhT)ir75mzOMSsQ(OTEeCE0(JC5GrUYtlY4aZiPhT9JyfopAZJwT6rRF0KpAaCLfa0H8iLN6Ozd7r7ps0EotgQjRKQpA7hX6J2FKlhmYvEArghygj9OTFeRW5rB44I2tqZXTaGoKhXDo7WvEeCCr7jO54NmtnaRAch1WfmWXPwGk0Gpb35SZ45rWXPwGk0Gpbhx0EcAooBjWXAyuENzqvpBgQgTukCC9LoDPWX1GzQL2vZu7XmCC8wSiooBjWXAyuENzqvpBgQgTukCNZoChpcoo1cuHg8j44I2tqZX9l7OKZkhxFPtxkC8jFeewiOwoGDrHT8O9hPbZulTRMP2Jz4441cW54(LDuYzL7C2NU8i44ulqfAWNGJlApbnh3VSJsoC446lD6sHJp5JGWcb1YbSlkSLhT)inyMAPD1m1EmdhhVwaoh3VSJsoC4oNDwzepcoo1cuHg8j446lD6sHJRbZulTRMP2Jz4E0(JGWcbv2A5AXtqRoYsYU(OTz(i4WypA)rqyHGkBTCT4jOvhzjzxF0wmFeCydhx0EcAo(cWtqZDo7SYkpcoo1cuHg8j446lD6sHJp5JghwouAXTjzMmqKCpA)rt(OXHLdfWUytYmzGi544I2tqZX1GEgeLmEmzQl5LEL7C2zfo8i44ulqfAWNGJRV0Plfo(6hbHfcQtMPgGvnHJA4cguylpA1Qhn5J0GzQL2vZu7XmCpAdhx0EcAooeDv6IYDo7SonEeCCQfOcn4tWX1x60LchF9JGWcb1jZudWQMWrnCbdkSLhTA1JM8rAWm1s7QzQ9ygUhTHJlApbnhpBTCT4jO5oNDwzmEeCCQfOcn4tWX1x60LchF9JGWcbfeDv6IAGi5uylpA1QhbHfcQS1Y1ING2adtUrkTbemyxfOvylpAdhx0EcAooeDv6IMnmUZzNv2WJGJtTavObFcoU(sNUu44RF0KpAaCLmKfpNjt1wolZqSeyKYtD0SH9O9hn5JeTNGwjdzXZzYuTLZYmelbgPY2ekjSy)r7pA9JM8rdGRKHS45mzQ2YzzIjPO8uhnBypA1QhnaUsgYINZKPAlNLjMKI6ilj76J2(rt7rBE0QvpAaCLmKfpNjt1wolZqSeyKQ6Io6J26rt7r7pAaCLmKfpNjt1wolZqSeyK6ilj76J26rS5r7pAaCLmKfpNjt1wolZqSeyKYtD0SH9OnCCr7jO54Yqw8CMmvB5S4oNDwHR8i44ulqfAWNGJRV0Plfo(rHJQXcuHE0QvpAaCLhFsn2arYPQUOJ(OTE00E0QvpA9Jgax5XNuJnqKCQQl6OpARhXypA)rhwtbWbJufSqqYoGvPHHSGortkITILll04rBE0Qvps0EotgQjRKQpABMpIX44I2tqZX94tQXgisoUZzNvgppcoo1cuHg8j446lD6sHJFcmsnOqQt)rB)iwz0J2FuLCpByvLL0WkKXcCehx0EcAoUL0Wke35SZkChpcoo1cuHg8j446lD6sHJxbyfOShQfSQJvidDylEcAf1cuHgpA)rRF06hPbGYay3kp(KASbIKtDKLKD9rB)ig9O9hPbGYay3klPHvi1rws21hT9Jy0J28O9hT(rdGRSaGoKhPoYsYU(OTz(OP9OnpA)rRFeewiOYwlxlEcAdmm5gP0gqWGDvGwna29J2FeewiOGORsxudejNAaS7hT)iiSqqbtkI2tTbgMCJuA1ay3pAZJ28OvREufGvGYEOMbfXZczQGYm1UIAbQqdoE2oDh2IBYahVcWkqzpuZGI4zHmvqzMAFFTgakdGDR84tQXgiso1rws21Tz0UgakdGDRSKgwHuhzjzx3MrB44z70DylUjTSOrkoXXzLJlApbnhpuOAS(KGZXZ2P7WwCdScaskCCw5oNDwNU8i44ulqfAWNGJRV0PlfooewiOYwlxlEcAdmm5gP0gqWGDvGwna29J2FeewiOGORsxudejNAaS7hT)ir75mzOMSsQ(OTz(igJJlApbnhVANlKbIKJ7C2HdJ4rWXPwGk0GpbhxFPtxkCCiSqqLTwUw8e0kSLhT)ir75mzOMSsQ(OTE00E0(Jw)iiSqq5aGhBKEy0fXwvDrh9rBZ8rW5rBE0QvpA9JGWcbLdaESr6HrxeBf2YJ2FeewiOCaWJnspm6IyRoYsYU(OTEeRk28OnpA1QhT(rqyHGQkZcmYObwqIlTRQUOJ(OTz(OP9OnpA1QhbHfcki6Q0f1arYPWwE0(JeTNZKHAYkP6J26rtJJlApbnh3sWkCNZoCyLhbhNAbQqd(eCC9LoDPWXx)iiSqqvLzbgz0aliXL2vvx0rF02mFeRpAZJ2F06hbHfckha8yJ0dJUi2kSLhT5r7pccleuzRLRfpbTcB5r7ps0EotgQjRKQpI5JGdhx0EcAoULGv4oND4ahEeCCQfOcn4tWX1x60LchhcleuzRLRfpbTcB5r7ps0EotgQjRKQpAlMpAACCr7jO54wsdRqCNZoCMgpcoo1cuHg8j446lD6sHJV(rRF06hbHfckha8yJ0dJUi2QQl6OpABMpcopAZJwT6rRFeewiOCaWJnspm6IyRWwE0(JGWcbLdaESr6HrxeB1rws21hT1JyvXMhT5rRw9O1pccleuvzwGrgnWcsCPDv1fD0hTnZhnThT5rBE0(JeTNZKHAYkP6J26rt7rB44I2tqZXTeSc35SdhgJhbhNAbQqd(eCC9LoDPWXfTNZKHAYkP6J2(rSYXfTNGMJ7XNuJnqKCCNZoCydpcoo1cuHg8j446lD6sHJV(rRF0jWOhT1JMUm6rBE0(JeTNZKHAYkP6J26rt7rBE0QvpA9Jw)OtGrpARhb3XMhT5r7ps0EotgQjRKQpARhnThT)ixku7QkaRyabJhtMa4OQROwGk04rB44I2tqZXTKgwH4oND4ax5rWXPwGk0Gpbhx0EcAo(cwzMUeUG446lD6sHJpaUYJpPgBGi5uvx0rF02pcoCCnd6czC5GrELZoRCNZoCy88i44I2tqZX94tQXgisooo1cuHg8j4oND4a3XJGJtTavObFcoU(sNUu44I2ZzYqnzLu9rB9OPXXfTNGMJBjyfUZzhotxEeCCr7jO54v7CHmqKCCCQfOcn4tWDo7tJr8i44ulqfAWNGJRV0Plfo(jWi1GcPo9hT1Jymg9O9hbHfcQ8aDa7uhzjzxF0wpIrk2WXfTNGMJNhOdyh35oh3k9eM4jO5rWzNvEeCCQfOcn4tWX1x60LchpBnWkByMHyjWidBQpA7hLhOdyNziwcmY4XhvJbLXJ2FeewiOYd0bStDKLKD9rB9OP9OPJhflvN44I2tqZXZd0bSJ7C2Hdpcoo1cuHg8j446lD6sHJ7shnBypA)rXKu8y1I2F0wpcUYgoUO9e0C8JAYwkCNZ(04rWXPwGk0GpbhxFPtxkCCx6Ozd7r7pkMKIhRw0(J26rWv2WXfTNGMJhoQHlsAyocg10jEcAUZzNX4rWXPwGk0GpbhxFPtxkC81pAYhnoSCO0IBtYmzGi5E0(JM8rJdlhkGDXMKzYarY9OnpA1QhjApNjd1Kvs1hTnZhbhoUO9e0CCYAbytNbc0dUZzNn8i44ulqfAWNGJRV0PlfoUlD0SH9O9hftsXJvlA)rB9igpBE0(JYwdSYgMziwcmYWM6J2(rmsX6JMoEumjfpwzjtphx0EcAooKCrRrZM7C2HR8i44ulqfAWNGJRV0PlfooewiOQy3Colft2vpBTxvdGD)O9hbHfcki5IwJMTAaS7hT)OyskESAr7pARhbxz0J2Fu2AGv2WmdXsGrg2uF02pIrk4WMhnD8OyskESYsMEoUO9e0C8k2nNZsXKD1Zw7vUZDo(YrAGfK48i4SZkpcoo1cuHg8j44dQQVCXtqZXNoNEsJ504rquaC0J0aliXFeebl7Q6rWLR10IxFudA4sXYzfWkps0Ec66JaDHbfhx0EcAoE0Shhnm1L8sVYDo7WHhbhNAbQqd(eCC9LoDPWXHWcbLwCtaCwkSLhT)OXHLdLwCBsMjdejhhx0EcAo(YbSlCNZ(04rWXPwGk0GpbhxFPtxkCCxku7Qyso3acgpMm2zzOOwGk04r7pA9JghwouAXTjzMmqKCpA)rqyHGslUjaolf2YJwT6rJdlhkGDXMKzYarY9O9hbHfcklaOJMTjaolf2YJwT6rqyHGYca6OzBcGZsHT8O9h5sHAxbjfP1KrcHStNbf1cuHgpAdhx0EcAoEmjNBabJhtg7Sm4oNDgJhbhNAbQqd(eCC9LoDPWXN8rqyHGsAgmbWzPWwE0(Jw)O1pAYhnoSCOa2fBsMjdej3J2F0KpACy5qPf3MKzYarY9OnpA)rRF0KpsdMPwAx1jSy3ee6rBE0MhTA1Jw)O1pAYhnoSCOa2fBsMjdej3J2F0KpACy5qPf3MKzYarY9OnpA)rRFKgmtT0UQtyXUji0J2FKlfQD1rvhCING2iHq2PZGIAbQqJhT5rRw9inyMAPD1m1Emd3J2WXfTNGMJdrYzcGZI7C2zdpcoo1cuHg8j446lD6sHJdHfcklaOJMTjaolf2YJ2F04WYHcyxSjzMmqKCpA)rt(inyMAPDvNWIDtqioUO9e0CC7t8yUZzhUYJGJtTavObFcoU(sNUu44qyHGYca6OzBcGZsHT8O9hnoSCOa2fBsMjdej3J2FKgmtT0UQtyXUjiehx0EcAoE1LlKhXDo7mEEeCCQfOcn4tWX1x60LchVcWkqzpulyvhRqg6Ww8e0kQfOcnE0QvpQcWkqzpuZGI4zHmvqzMAxrTavObhpBNUdBXnzGJxbyfOShQzqr8SqMkOmtTZXZ2P7WwCtAzrJuCIJZkhx0EcAoEOq1y9jbNJNTt3HT4gyfaKu44SYDUZXlmOLt08i4SZkpcoUO9e0CCT4Ma4S44ulqfAWNG7CNJpOGGvCEeC2zLhbhNAbQqd(eC8bv1xU4jO54tNtpPXCA8iAMogEKNw0J8y6rI2b3JY6JKzjlcuHuCCr7jO541OyLIbsQXCNZoC4rWXPwGk0Gpbhx0EcAooBjWXAyuENzqvpBgQgTukCC9LoDPWXN8rqyHGA5a2ff2YJ2F0KpsdMPwAxntThZWXXBXI44SLahRHr5DMbv9SzOA0sPWDo7tJhbhNAbQqd(eCCr7jO54(LDuYzLJRV0Plfo(KpccleulhWUOWwE0(JM8rAWm1s7QzQ9ygooETaCoUFzhLCw5oNDgJhbhNAbQqd(eCCr7jO54(LDuYHdhxFPtxkC8jFeewiOwoGDrHT8O9hn5J0GzQL2vZu7XmCC8Ab4CC)Yok5WH7C2zdpcoo1cuHg8j446lD6sHJp5J0GzQL2vZu7XmCpA)rRF06hT(rUuO2vXKCUbemEmzSZYqrTavOXJ2FeewiOIj5Cdiy8yYyNLHcB5rBE0(Jw)OXHLdLwCBsMjdej3JwT6rJdlhkGDXMKzYarY9OnpA)rt(iiSqqTCa7IcB5rBE0QvpA9Jw)iiSqqbrxLUOgisof2YJwT6rqyHGkBTCT4jOnWWKBKsBabd2vbAf2YJ28O9hT(rt(OXHLdLwCBsMjdej3J2F0KpACy5qbSl2KmtgisUhT5rBE0goUO9e0C8fGNGM7C2HR8i44ulqfAWNGJRV0Plfo(4WYHslUnjZKbIK7r7pAYhPbZulTRMP2Jz4E0(Jw)O1psdaLbWUvE8j1ydejN6ilj76J2(rm6r7psdaLbWUvwsdRqQJSKSRpA7hXOhT)ObWvwaqhYJuhzjzxF02mFem94rt9igPyZJ2F0jWOhT1Jymg9O9hbHfcQS1Y1ING2adtUrkTbemyxfOvdGD)O9hbHfcki6Q0f1arYPga7(r7pccleuWKIO9uBGHj3iLwna29J28OvRE06hbHfckT4Ma4SuylpA)ruthmgE02pcoS5rBE0QvpA9JgaxDsusDu4OASavOhT)ObWvxUOokCunwGk0J28OvRE06hDynfahmsbep2acgpMmuzqNzCy5qrSvSCzHgpA)rt(iiSqqbep2acgpMmuzqNzCy5qHT8O9hT(rqyHGslUjaolf2YJ2Fe10bJHhT9JGdJE0MhT)iiSqqftY5gqW4XKXold1rws21hTfZhXkJE0MhTA1Jw)inyMAPDvugUu6hT)inauga7wrwlaB6mqGEOoYsYU(OTy(iwF0(JeTNZKHAYkP6J26rW5rBE0QvpA9JGWcbvmjNBabJhtg7SmuylpA)ruthmgE02pA6YOhT5rB44v)sTZzNvoUO9e0C8dRnI2tqBkz154LS6MwSioUwCBsMjUZzNXZJGJtTavObFcoU(sNUu44JdlhkT42KmtgisUhT)inyMAPD1m1Emd3J2F06hT(rAaOma2TYJpPgBGi5uhzjzxF02pIrpA)rAaOma2TYsAyfsDKLKD9rB)ig9O9hnaUYca6qEK6ilj76J2M5JGPhpAQhXifBE0(Jobg9OTEeJXOhT)iiSqqLTwUw8e0gyyYnsPnGGb7QaTAaS7hT)iiSqqbrxLUOgiso1ay3pA)rqyHGcMueTNAdmm5gP0QbWUF0(Jobg9OTEeJXOhT)iiSqqLTwUw8e0gyyYnsPnGGb7QaTAaS7hT)iiSqqbrxLUOgiso1ay3pA)rqyHGcMueTNAdmm5gP0QbWUF0MhTA1Jw)iiSqqPf3eaNLcB5r7pIA6GXWJ2(rWHnpAZJwT6rRF0a4QtIsQJchvJfOc9O9hnaU6Yf1rHJQXcuHE0(Jobg9OTEeJXOhT)iiSqqLTwUw8e0gyyYnsPnGGb7QaTAaS7hT)iiSqqbrxLUOgiso1ay3pA)rqyHGcMueTNAdmm5gP0QbWUF0MhTHJx9l1oNDw54I2tqZXpS2iApbTPKvNJxYQBAXI44AXTjzM4oND4oEeCCQfOcn4tWX1x60LchFYhnoSCO0IBtYmzGi5E0(JGWcbLwCtaCwkSfoE1Vu7C2zLJlApbnh)WAJO9e0MswDoEjRUPflIJRf3MKzI7C2NU8i44ulqfAWNGJRV0Plfo(4WYHcyxSjzMmqKCpA)rRF06hPbGYay3kp(KASbIKtDKLKD9rB)ig9O9hPbGYay3klPHvi1rws21hT9Jy0J2F0jWOhT1JyLnpA)rqyHGkBTCT4jOvdGD)O9hbHfcki6Q0f1arYPga7(r7pccleuWKIO9uBGHj3iLwna29J28OvRE06hbHfcklaOJMTjaolf2YJ2F0a4QkwhYJuhfoQglqf6rBE0QvpA9JGWcbLfa0rZ2eaNLcB5r7pccleuXKCUbemEmzSZYqHT8OnpA1QhT(rhwtbWbJuaXJnGGXJjdvg0zghwoueBflxwOXJ2F0KpccleuaXJnGGXJjdvg0zghwouylpAZJwT6rRFKgmtT0UQtyXUji0J2FKgakdGDR0GEgeLmEmzQl5LEvDKLKD9rBX8rS(OnpA1QhT(rAWm1s7QOmCP0pA)rAaOma2TISwa20zGa9qDKLKD9rBX8rS(O9hjApNjd1Kvs1hT1JGZJ28OnC8QFP25SZkhx0EcAo(H1gr7jOnLS6C8swDtlwehhyxSjzM4oNDwzepcoo1cuHg8j446lD6sHJp5Jghwoua7InjZKbIK7r7pccleuwaqhnBtaCwkSfoE1Vu7C2zLJlApbnh)WAJO9e0MswDoEjRUPflIJdSl2KmtCNZoRSYJGJtTavObFcoU(sNUu44JdlhkGDXMKzYarY9O9hbHfcklaOJMTjaolf2chV6xQDo7SYXfTNGMJFyTr0EcAtjRohVKv30IfXXb2fBsMjUZzNv4WJGJtTavObFco(GQ6lx8e0CC2w4r20JILz6rmUzqlN8OcbJ6HCm8iITILll04rspEeKuKwtpscHStNHhj1hjpYLc1(JSPhvTtxh)OSDWJSaGoA2pkaoRhzhtnnt3J8y6rfg0YjpccleEuwFK4pcCpcIka7hbNhvjnhx0EcAo(H1gr7jOnLS6CC9LoDPWXx)O1p6WAkaoyKQWGwoPAcfI8SHzGvsRLkPi2kwUSqJhT5r7pA9JCPqTRGKI0AYiHq2PZGIAbQqJhT5r7pA9JGWcbvHbTCs1eke5zdZaRKwlvsHT8OnpA)rRFeewiOkmOLtQMqHipBygyL0APsQJSKSRpAlMpcopAZJ2WXlz1nTyrC8cdA5ea35SZ604rWXPwGk0GpbhFqv9LlEcAooBl8iB6rXYm9ig3mOLtEuHGr9qogEeXwXYLfA8iPhpkqNuEKeczNodpsQpsEKlfQ9hztpQANUo(rz7GhfOtkpkaoRhzhtnnt3J8y6rfg0YjpccleEuwFK4pcCpcIka7hbNhvjnhx0EcAo(H1gr7jOnLS6CC9LoDPWXx)O1p6WAkaoyKQWGwoPAcfI8SHzGvsRLkPi2kwUSqJhT5r7pA9JCPqTRc0jfJeczNodkQfOcnE0MhT)O1pccleufg0YjvtOqKNnmdSsATujf2YJ28O9hT(rqyHGQWGwoPAcfI8SHzGvsRLkPoYsYU(OTy(i48OnpAdhVKv30IfXXlmOLt0CNZoRmgpcoo1cuHg8j44dQQVCXtqZXzBHhztS9JEK8OoHf7bHEK0JhztpAaA2U)iBP9h5GhPf3MKzksGDXMKzc(hj94r20JILz6rqsrAnfzGoP8ijeYoDgEKlfQDAa)JyCftnnt3J0GEgeLEKE8OS(iSLhztpQANUo(rz7GhjHq2PZWJcGZ6ro4rAP6pkD4FumD0JSaGoA2pkaolfhx0EcAo(H1gr7jOnLS6CC9LoDPWXRK7zdRQQXzWnbWz0GEgeLE0(Jw)O1pYLc1UcsksRjJeczNodkQfOcnE0MhT)O1pAYhnoSCO0IBtYmzGi5E0MhT)O1pAYhnoSCOa2fBsMjdej3J28O9hT(rAWm1s7QoHf7MGqpA)rAaOma2Tsd6zquY4XKPUKx6v1rws21hTfZhX6J28OnC8swDtlwehhOb9mikXDo7SYgEeCCQfOcn4tWXhuvF5INGMJZ2cpYMy7h9i5rDcl2dc9iPhpYME0a0SD)r2s7pYbpslUnjZuKa7InjZe8ps6XJSPhflZ0JGKI0AkYaDs5rsiKD6m8ixku70a(hX4kMAAMUhPb9mik9i94rz9rylpYMEu1oDD8JY2bpscHStNHhfaN1JCWJ0s1Fu6W)Oy6OhPfpaoRhfaNLIJlApbnh)WAJO9e0MswDoU(sNUu44vY9SHvv14m4Ma4mAqpdIspA)rRF06h5sHAxfOtkgjeYoDguulqfA8OnpA)rRF0KpACy5qPf3MKzYarY9OnpA)rRF0KpACy5qbSl2KmtgisUhT5r7pA9J0GzQL2vDcl2nbHE0(J0aqzaSBLg0ZGOKXJjtDjV0RQJSKSRpAlMpI1hT5rB44LS6MwSioUwd6zquI7C2zfUYJGJtTavObFcoUO9e0CCTukgr7jOnLS6C8swDtlweh3k9eM4jO5oNDwz88i44ulqfAWNGJlApbnh)WAJO9e0MswDoEjRUPflIJdrYXDUZX1IBtYmXJGZoR8i44I2tqZXxoGDHJtTavObFcUZzho8i44ulqfAWNGJRV0Plfo(KpccleuAXnbWzPWw44I2tqZX1IBcGZI7C2Ngpcoo1cuHg8j446lD6sHJdHfcQLdyxuylCCr7jO54NeL4oNDgJhbhNAbQqd(eCC9LoDPWXDPqTRIj5Cdiy8yYyNLHIAbQqJhT)OjFeewiOIj5Cdiy8yYyNLHcBHJlApbnhpMKZnGGXJjJDwgCNZoB4rWXPwGk0GpbhxFPtxkC8XHLdLwCBsMjdejhhx0EcAoozTaSPZab6b35Sdx5rWXPwGk0GpbhxFPtxkC8bWvNeLuhfoQglqf6r7psdSGaMfq2E9rB9igJJlApbnh)KOe35SZ45rWXPwGk0GpbhxFPtxkC8bWvxUOokCunwGk0J2FKgybbmlGS96J2M5JymoUO9e0C8lx4oND4oEeCCQfOcn4tWX1x60LchFCy5qPf3MKzYarYXXfTNGMJRb9mikz8yYuxYl9k35SpD5rWXPwGk0GpbhxFPtxkCCnWccywaz71hTnZhXyCCr7jO54b6a6eGvnqPtCClz6nuthmg4SZk35SZkJ4rWXPwGk0GpbhxFPtxkC81pAYhnaUsgYINZKPAlNLziwcms5PoA2WE0(JM8rI2tqRKHS45mzQ2YzzgILaJuzBcLewS)O9hT(rt(ObWvYqw8CMmvB5SmXKuuEQJMnShTA1JgaxjdzXZzYuTLZYetsrDKLKD9rB)OP9OnpA1QhnaUsgYINZKPAlNLziwcmsvDrh9rB9OP9O9hnaUsgYINZKPAlNLziwcmsDKLKD9rB9i28O9hnaUsgYINZKPAlNLziwcms5PoA2WE0goUO9e0CCzilEotMQTCwCNZoRSYJGJtTavObFcoU(sNUu44vawbk7HAbR6yfYqh2INGwrTavOXJ2Fe10bJHhT1JMgBE0QvpQcWkqzpuZGI4zHmvqzMAxrTavObhpBNUdBXnzGJxbyfOShQzqr8SqMkOmtTVtnDWyyRPXgoE2oDh2IBsllAKItCCw54I2tqZXdfQgRpj4C8SD6oSf3aRaGKchNvUZzNv4WJGJtTavObFcoU(sNUu44AGfeWSaY2Rkn2Du7pARhXgoUO9e0C8A8rdUZDoUgakdGDx5rWzNvEeCCr7jO54lapbnhNAbQqd(eCNZoC4rWXfTNGMJdvaGHjGDmWXPwGk0Gpb35SpnEeCCr7jO54q0vPlA2W44ulqfAWNG7C2zmEeCCr7jO54YPLMmo4oQDoo1cuHg8j4oND2WJGJlApbnhVKWI9QHTeBaZIANJtTavObFcUZzhUYJGJlApbnhpKhbvaGbhNAbQqd(eCNZoJNhbhx0EcAoU0AQ6NumAPu44ulqfAWNG7C2H74rWXPwGk0GpbhxFPtxkCCiSqqbrYzcGZsHTWXfTNGMJdDz1lzdZeWoUZzF6YJGJtTavObFcoU(sNUu44RF0a4klaOd5rkp1rZg2JwT6rI2ZzYqnzLu9rB)iwF0MhT)ObWvE8j1ydejNYtD0SHXXfTNGMJNTwUw8e0CNZoRmIhbhx0EcAooeDv6IYXPwGk0Gpb35SZkR8i44ulqfAWNGJlApbnhxZGUa8d0P2avKQZXPqG0UPflIJRzqxa(b6uBGks15oNDwHdpcoUO9e0CCSkzsNSQCCQfOcn4tWDUZXbAqpdIs8i4SZkpcoUO9e0CClaOJMTjaoloo1cuHg8j4oND4WJGJtTavObFcoU(sNUu44UuO2vXKCUbemEmzSZYqrTavOXJ2F0KpccleuXKCUbemEmzSZYqHTWXfTNGMJhtY5gqW4XKXoldUZzFA8i44ulqfAWNGJRV0PlfoEfGvGYEOc5vDt1VmkPOwGk04r7pccleuH8QUP6xgLuylCCr7jO54AqpdIsgpMm1L8sVYDo7mgpcoo1cuHg8j446lD6sHJt6sUujL0myAA69hTA1JiDjxQKQckYzAA6DoUO9e0C8QlxipI7C2zdpcoo1cuHg8j446lD6sHJt6sUujL0myAA69hTA1JiDjxQKQG1YzAA6DoUO9e0CC7t8yUZzhUYJGJtTavObFcoU(sNUu44UuO2vXKCUbemEmzSZYqrTavOXJ2FeewiOIj5Cdiy8yYyNLHcBHJlApbnhxd6zquY4XKPUKx6vUZzNXZJGJtTavObFcoU(sNUu44UuO2vXKCUbemEmzSZYqrTavOXJ2FKgakdGDRIj5Cdiy8yYyNLH6ilj76J2(rSYgoUO9e0CCnONbrjJhtM6sEPx5oND4oEeCCQfOcn4tWX1x60LchFYh5sHAxftY5gqW4XKXoldf1cuHgCCr7jO54AqpdIsgpMm1L8sVYDUZX1AqpdIs8i4SZkpcoUO9e0CCT4Ma4S44ulqfAWNG7C2Hdpcoo1cuHg8j446lD6sHJ7sHAxftY5gqW4XKXoldf1cuHgpA)rt(iiSqqftY5gqW4XKXoldf2chx0EcAoEmjNBabJhtg7Sm4oN9PXJGJtTavObFcoU(sNUu44vawbk7HkKx1nv)YOKIAbQqJhT)iiSqqfYR6MQFzusHTWXfTNGMJRb9mikz8yYuxYl9k35SZy8i44ulqfAWNGJRV0PlfoUlfQDvmjNBabJhtg7SmuulqfA8O9hbHfcQyso3acgpMm2zzOWw44I2tqZX1GEgeLmEmzQl5LEL7C2zdpcoo1cuHg8j446lD6sHJ7sHAxftY5gqW4XKXoldf1cuHgpA)rAaOma2TkMKZnGGXJjJDwgQJSKSRpA7hXkB44I2tqZX1GEgeLmEmzQl5LEL7C2HR8i44ulqfAWNGJRV0Plfo(KpYLc1UkMKZnGGXJjJDwgkQfOcn44I2tqZX1GEgeLmEmzQl5LEL7CNJdSl2Kmt8i4SZkpcoo1cuHg8j446lD6sHJp5JGWcbLfa0rZ2eaNLcBHJlApbnh3ca6OzBcGZI7C2Hdpcoo1cuHg8j446lD6sHJ7sHAxftY5gqW4XKXoldf1cuHgpA)rt(iiSqqftY5gqW4XKXoldf2chx0EcAoEmjNBabJhtg7Sm4oN9PXJGJlApbnhV6YvXoyehNAbQqd(eCNZoJXJGJtTavObFcoU(sNUu44vawbk7HkKx1nv)YOKIAbQqdoUO9e0CCnONbrjJhtM6sEPx5oND2WJGJtTavObFcoU(sNUu44JdlhkGDXMKzYarYXXfTNGMJtwlaB6mqGEWDo7WvEeCCQfOcn4tWX1x60LchF9JM8rdGRKHS45mzQ2YzzgILaJuEQJMnShT)OjFKO9e0kzilEotMQTCwMHyjWiv2MqjHf7pA)rRF0KpAaCLmKfpNjt1woltmjfLN6Ozd7rRw9ObWvYqw8CMmvB5SmXKuuhzjzxF02pAApAZJwT6rdGRKHS45mzQ2YzzgILaJuvx0rF0wpAApA)rdGRKHS45mzQ2YzzgILaJuhzjzxF0wpInpA)rdGRKHS45mzQ2YzzgILaJuEQJMnShTHJlApbnhxgYINZKPAlNf35SZ45rWXPwGk0Gpbhx0EcAoEfRd5rCC9LoDPWXpkCunwGkehxZGUqgxoyKx5SZk35Sd3XJGJtTavObFcoUO9e0CClaOd5rCC9LoDPWXpkCunwGk0JwT6rqyHGcMueTNAdmm5gP0kSfoUMbDHmUCWiVYzNvUZzF6YJGJtTavObFcoU(sNUu44AWm1s7QoHf7MGqpA)rKUKlvsjndMMMENJlApbnhV6YfYJ4oNDwzepcoo1cuHg8j446lD6sHJp5J0GzQL2vDcl2nbHE0(JiDjxQKsAgmnn9ohx0EcAoU9jEm35SZkR8i44ulqfAWNGJRV0Plfo(6hbHfcksxYLkzkyTCkSLhTA1JGWcbfPl5sLmvqrof2YJ2WXfTNGMJRb9mikz8yYuxYl9k35SZkC4rWXPwGk0GpbhxFPtxkC81pI0LCPsQSnfSwUhTA1JiDjxQKQckYzAA69hT5rRw9O1pI0LCPsQSnfSwUhT)iiSqqvD5QyhmYqwlaB6SO2nfSwof2YJ2WXfTNGMJxD5c5rCNZoRtJhbhx0EcAoU9jEmhNAbQqd(eCN7CNJptxnbnND4Wi4WkJy8SYioUTCD2WQCC2M1c4CA8iwz9rI2tq)Osw9Q6zHJxxinNDwzeJXXxoqilehhUb3EeCpm5gP0pcUVdlhplWn42JybRWWJyLnW)i4Wi4W6ZYZcCdU9igNyPHrv4YEwGBWThbx6rSTwdUfWjo9ighXJeUFaOJM9JwUeCPNu9rRZWJQK7zd7rz9r6yshLgBuplWn42JGl9i2wRb3c4eNEeyXtq)ih8OACg8hTgCpQb(MhbrbWrpIXb0ZGOK6z5zbU9OPZPN0yonEeefah9inWcs8hbrWYUQEeC5AnT41h1GgUuSCwbSYJeTNGU(iqxyq9SiApbDvTCKgybj(umJmA2JJgM6sEPxFweTNGUQwosdSGeFkMrUCa7c8zGjewiO0IBcGZsHTSpoSCO0IBtYmzGi5EweTNGUQwosdSGeFkMrgtY5gqW4XKXold4Zatxku7Qyso3acgpMm2zzOOwGk0yF94WYHslUnjZKbIKBhcleuAXnbWzPWwwTACy5qbSl2KmtgisUDiSqqzbaD0SnbWzPWwwTccleuwaqhnBtaCwkSLDxku7kiPiTMmsiKD6mOOwGk0yZZIO9e0v1YrAGfK4tXmsisotaCwWNbMtcHfckPzWeaNLcBzF96jhhwoua7InjZKbIKBFYXHLdLwCBsMjdej3M91tQbZulTR6ewSBccTzZQvRxp54WYHcyxSjzMmqKC7tooSCO0IBtYmzGi52SVwdMPwAx1jSy3eeA3Lc1U6OQdoXtqBKqi70zqrTavOXMvR0GzQL2vZu7XmCBEweTNGUQwosdSGeFkMrAFIhdFgycHfcklaOJMTjaolf2Y(4WYHcyxSjzMmqKC7tQbZulTR6ewSBcc9SiApbDvTCKgybj(umJS6YfYJGpdmHWcbLfa0rZ2eaNLcBzFCy5qbSl2KmtgisUDnyMAPDvNWIDtqONfr7jORQLJ0aliXNIzKHcvJ1NeC4ZaZkaRaL9qTGvDSczOdBXtqROwGk0y1QkaRaL9qndkINfYubLzQDf1cuHgWNTt3HT4M0YIgP4etwHpBNUdBXnWkaiPWKv4Z2P7WwCtgywbyfOShQzqr8SqMkOmtT)S8Sa3E0050tAmNgpIMPJHh5Pf9ipMEKODW9OS(izwYIavi1ZIO9e0vM1OyLIbsQXplI2tqxNIzKyvYKozbFlwet2sGJ1WO8oZGQE2munAPuGpdmNecleulhWUOWw2NudMPwAxntThZW9SiApbDDkMrIvjt6Kf81cWz6x2rjNv4ZaZjHWcb1YbSlkSL9j1GzQL2vZu7XmCplI2tqxNIzKyvYKozbFTaCM(LDuYHd8zG5KqyHGA5a2ff2Y(KAWm1s7QzQ9ygUNfr7jORtXmYfGNGg(mWCsnyMAPD1m1Emd3(61RDPqTRIj5Cdiy8yYyNLHIAbQqJDiSqqftY5gqW4XKXoldf2YM91JdlhkT42KmtgisUvRghwoua7InjZKbIKBZ(KqyHGA5a2ff2YMvRwVgcleuq0vPlQbIKtHTSAfewiOYwlxlEcAdmm5gP0gqWGDvGwHTSzF9KJdlhkT42KmtgisU9jhhwoua7InjZKbIKBZMnplWn42JyCe3MK5SH9ir7jOFujR(JSZs5rq0JoPFugG)rwsdRqr6XNuJFKC0Ja9J0d4F0jWOhL1hbrfG9Jymgb)JGlOl6JKE8OS1Y1ING(rYrpAaS7hj94rW9WKIO9u)iyyYnsPFeewi8OS(Og4ps0EotW)iW9Oma)JSj2(rpk7hPfpaoRhj94ruthmgEuwFKabMPhbh2a)JylUhLHhztpkwMPh5X0Jylep(rfcg1d5y4reBflxwOb8pYJPhniiSq4rLSJsJh5GhL(JY6JAG)iSLhj94ruthmgEuwFKabMPhbhgbpBX9Om8iBITF0JIYWLs)iPhpA60Abyt3JGa94rAaOma29JY6JWwEK0JhrnzLu9rYrpk7aDj4EKdEeCuplI2tqxNIzKhwBeTNG2uYQdF1Vu7mzf(wSiMAXTjzMGpdmhhwouAXTjzMmqKC7tQbZulTRMP2Jz42xVwdaLbWUvE8j1ydejN6ilj762mAxdaLbWUvwsdRqQJSKSRBZO9bWvwaqhYJuhzjzx3Mjm9ykgPyZ(jWOTymgTdHfcQS1Y1ING2adtUrkTbemyxfOvdGDVdHfcki6Q0f1arYPga7EhcleuWKIO9uBGHj3iLwna29MvRwdHfckT4Ma4Suyl7uthmg2goSzZQvRhaxDsusDu4OASavO9bWvxUOokCunwGk0MvRwFynfahmsbep2acgpMmuzqNzCy5qrSvSCzHg7tcHfckG4XgqW4XKHkd6mJdlhkSL91qyHGslUjaolf2Yo10bJHTHdJ2SdHfcQyso3acgpMm2zzOoYsYUUftwz0MvRwRbZulTRIYWLsVRbGYay3kYAbytNbc0d1rws21TyY6UO9CMmutwjv3coBwTAnewiOIj5Cdiy8yYyNLHcBzNA6GXW2txgTzZZIO9e01Pyg5H1gr7jOnLS6Wx9l1otwHVflIPwCBsMj4ZaZXHLdLwCBsMjdej3UgmtT0UAMApMHBF9Anauga7w5XNuJnqKCQJSKSRBZODnauga7wzjnScPoYsYUUnJ2haxzbaDipsDKLKDDBMW0JPyKIn7NaJ2IXy0oewiOYwlxlEcAdmm5gP0gqWGDvGwna29oewiOGORsxudejNAaS7DiSqqbtkI2tTbgMCJuA1ay37NaJ2IXy0oewiOYwlxlEcAdmm5gP0gqWGDvGwna29oewiOGORsxudejNAaS7DiSqqbtkI2tTbgMCJuA1ay3BwTAnewiO0IBcGZsHTStnDWyyB4WMnRwTEaC1jrj1rHJQXcuH2haxD5I6OWr1ybQq7NaJ2IXy0oewiOYwlxlEcAdmm5gP0gqWGDvGwna29oewiOGORsxudejNAaS7DiSqqbtkI2tTbgMCJuA1ay3B28SiApbDDkMrEyTr0EcAtjRo8v)sTZKv4BXIyQf3MKzc(mWCYXHLdLwCBsMjdej3oewiO0IBcGZsHT8Sa3GBpITWUytYC2WEKO9e0pQKv)r2zP8ii6rN0pkdW)ilPHvOi94tQXpso6rG(r6b8p6ey0JY6JGOcW(rSYg4FeCbDrFK0JhLTwUw8e0pso6rdGD)iPhpcUhMueTN6hbdtUrk9JGWcHhL1h1a)rI2Zzs9i2I7rza(hztS9JEu2pYca6Oz)Oa4SEK0JhvX6qE0JY6JokCunwGke8pIT4EugEKn9OyzMEKhtpITq84hviyupKJHhrSvSCzHgW)ipME0GGWcHhvYoknEKdEu6pkRpQb(JWwuSf3JYWJSj2(rpkkdxk9JKE8OPtRfGnDpcc0JhPbGYay3pkRpcB5rspEe1Kvs1hjh9iiQaSFeCG)rG7rz4r2eB)OhXEcl2FuqOhj94rmoGEgeLEKE8OS(iSf1ZIO9e01Pyg5H1gr7jOnLS6Wx9l1otwHVflIjWUytYmbFgyooSCOa2fBsMjdej3(61AaOma2TYJpPgBGi5uhzjzx3Mr7AaOma2TYsAyfsDKLKDDBgTFcmAlwzZoewiOYwlxlEcA1ay37qyHGcIUkDrnqKCQbWU3HWcbfmPiAp1gyyYnsPvdGDVz1Q1qyHGYca6OzBcGZsHTSpaUQI1H8i1rHJQXcuH2SA1AiSqqzbaD0SnbWzPWw2HWcbvmjNBabJhtg7SmuylBwTA9H1uaCWifq8ydiy8yYqLbDMXHLdfXwXYLfASpjewiOaIhBabJhtgQmOZmoSCOWw2SA1AnyMAPDvNWIDtqODnauga7wPb9mikz8yYuxYl9Q6ilj76wmzDZQvR1GzQL2vrz4sP31aqzaSBfzTaSPZab6H6ilj76wmzDx0EotgQjRKQBbNnBEweTNGUofZipS2iApbTPKvh(QFP2zYk8Tyrmb2fBsMj4ZaZjhhwoua7InjZKbIKBhcleuwaqhnBtaCwkSLNfr7jORtXmYdRnI2tqBkz1HVflIjWUytYmbF1Vu7mzf(mWCCy5qbSl2KmtgisUDiSqqzbaD0SnbWzPWwEwGBpITfEKn9OyzMEeJBg0YjpQqWOEihdpIyRy5YcnEK0JhbjfP10JKqi70z4rs9rYJCPqT)iB6rv701XpkBh8ilaOJM9JcGZ6r2XutZ09ipMEuHbTCYJGWcHhL1hj(Ja3JGOcW(rW5rvs)SiApbDDkMrEyTr0EcAtjRo8TyrmlmOLtaWNbMRxFynfahmsvyqlNunHcrE2WmWkP1sLueBflxwOXM91UuO2vqsrAnzKqi70zqrTavOXM91qyHGQWGwoPAcfI8SHzGvsRLkPWw2SVgcleufg0YjvtOqKNnmdSsATuj1rws21TycNnBEwGBpITfEKn9OyzMEeJBg0YjpQqWOEihdpIyRy5YcnEK0JhfOtkpscHStNHhj1hjpYLc1(JSPhvTtxh)OSDWJc0jLhfaN1JSJPMMP7rEm9OcdA5KhbHfcpkRps8hbUhbrfG9JGZJQK(zr0Ec66umJ8WAJO9e0MswD4BXIywyqlNOHpdmxV(WAkaoyKQWGwoPAcfI8SHzGvsRLkPi2kwUSqJn7RDPqTRc0jfJeczNodkQfOcn2SVgcleufg0YjvtOqKNnmdSsATujf2YM91qyHGQWGwoPAcfI8SHzGvsRLkPoYsYUUft4SzZZcC7rSTWJSj2(rpsEuNWI9Gqps6XJSPhnanB3FKT0(JCWJ0IBtYmfjWUytYmb)JKE8iB6rXYm9iiPiTMImqNuEKeczNodpYLc1onG)rmUIPMMP7rAqpdIspspEuwFe2YJSPhvTtxh)OSDWJKqi70z4rbWz9ih8iTu9hLo8pkMo6rwaqhn7hfaNL6zr0Ec66umJ8WAJO9e0MswD4BXIyc0GEgeLGpdmRK7zdRQQXzWnbWz0GEgeL2xV2Lc1UcsksRjJeczNodkQfOcn2SVEYXHLdLwCBsMjdej3M91tooSCOa2fBsMjdej3M91AWm1s7QoHf7MGq7AaOma2Tsd6zquY4XKPUKx6v1rws21TyY6MnplWThX2cpYMy7h9i5rDcl2dc9iPhpYME0a0SD)r2s7pYbpslUnjZuKa7InjZe8ps6XJSPhflZ0JGKI0AkYaDs5rsiKD6m8ixku70a(hX4kMAAMUhPb9mik9i94rz9rylpYMEu1oDD8JY2bpscHStNHhfaN1JCWJ0s1Fu6W)Oy6OhPfpaoRhfaNL6zr0Ec66umJ8WAJO9e0MswD4BXIyQ1GEgeLGpdmRK7zdRQQXzWnbWz0GEgeL2xV2Lc1UkqNumsiKD6mOOwGk0yZ(6jhhwouAXTjzMmqKCB2xp54WYHcyxSjzMmqKCB2xRbZulTR6ewSBccTRbGYay3knONbrjJhtM6sEPxvhzjzx3IjRB28SiApbDDkMrQLsXiApbTPKvh(wSiMwPNWepb9ZIO9e01Pyg5H1gr7jOnLS6W3IfXeIK7z5zr0Ec6QcIKJjejNjaol4ZaZjHWcbfejNjaolf2YZIO9e0vfej3umJmMKZnGGXJjJDwgWNbMUuO2vXKCUbemEmzSZYqrTavOX(Axku7kiPiTMmsiKD6mOOwGk0yZUgmtT0UAMApMH7zr0Ec6QcIKBkMrAbaDipc(mWC9AiSqqbtkI2tTbgMCJuAf2YMDr75mzOMSsQUfC2SA161qyHGcMueTNAdmm5gP0kSLn7toaUYca6qEKYtD0SHTlApNjd1Kvs1TzD3Ldg5kpTiJdmJK2Mv4S5zr0Ec6QcIKBkMrAbaDipc(mWC9a4klaOd5rQJSKSRBXCA7RHWcbfmPiAp1gyyYnsPvylB2fTNZKHAYkP62Sz3Ldg5kpTiJdmJK2Mv4S5zr0Ec6QcIKBkMrAbaDipc(mWC9rHJQXcuH2fTNZKHAYkP6wWz3Ldg5kpTiJdmJK2Mv4Sz1Q1toaUYca6qEKYtD0SHTlApNjd1Kvs1TzD3Ldg5kpTiJdmJK2Mv4S5zr0Ec6QcIKBkMrEYm1aSQjCudxWWZIO9e0vfej3umJeRsM0jl4BXIyYwcCSggL3zgu1ZMHQrlLc8zGPgmtT0UAMApMH7zr0Ec6QcIKBkMrIvjt6Kf81cWz6x2rjNv4ZaZjHWcb1YbSlkSLDnyMAPD1m1Emd3ZIO9e0vfej3umJeRsM0jl4RfGZ0VSJsoCGpdmNecleulhWUOWw21GzQL2vZu7XmCplI2tqxvqKCtXmYfGNGg(mWudMPwAxntThZWTdHfcQS1Y1INGwDKLKDDBMWHX2HWcbv2A5AXtqRoYsYUUft4WMNfr7jORkisUPygPg0ZGOKXJjtDjV0RWNbMtooSCO0IBtYmzGi52NCCy5qbSl2KmtgisUNfr7jORkisUPygjeDv6IAGi5GpdmxdHfcQtMPgGvnHJA4cguylRwnPgmtT0UAMApMHBZZIO9e0vfej3umJmBTCT4jOHpdmxdHfcQtMPgGvnHJA4cguylRwnPgmtT0UAMApMHBZZIO9e0vfej3umJeIUkDrZgg8zG5AiSqqbrxLUOgisof2YQvqyHGkBTCT4jOnWWKBKsBabd2vbAf2YMNfr7jORkisUPygPmKfpNjt1wol4ZaZ1toaUsgYINZKPAlNLziwcms5PoA2W2Nu0EcALmKfpNjt1wolZqSeyKkBtOKWI991toaUsgYINZKPAlNLjMKIYtD0SHTA1a4kzilEotMQTCwMyskQJSKSRBpTnRwnaUsgYINZKPAlNLziwcmsvDrhDRPTpaUsgYINZKPAlNLziwcmsDKLKDDl2SpaUsgYINZKPAlNLziwcms5PoA2W28SiApbDvbrYnfZi94tQXgiso4D5GrUjdmpkCunwGk0QvdGR84tQXgisov1fD0TM2QvRhax5XNuJnqKCQQl6OBXy7hwtbWbJufSqqYoGvPHHSGortkITILll0yZQvI2ZzYqnzLuDBMm2ZIO9e0vfej3umJ0sAyfc(mW8eyKAqHuN(2SYO9k5E2WQklPHviJf4ONfr7jORkisUPygzOq1y9jbh(mWScWkqzpulyvhRqg6Ww8e0kQfOcn2xVwdaLbWUvE8j1ydejN6ilj762mAxdaLbWUvwsdRqQJSKSRBZOn7RhaxzbaDipsDKLKDDBMtBZ(AiSqqLTwUw8e0gyyYnsPnGGb7QaTAaS7DiSqqbrxLUOgiso1ay37qyHGcMueTNAdmm5gP0QbWU3Sz1QkaRaL9qndkINfYubLzQDf1cuHgWNTt3HT4M0YIgP4etwHpBNUdBXnWkaiPWKv4Z2P7WwCtgywbyfOShQzqr8SqMkOmtTVVwdaLbWUvE8j1ydejN6ilj762mAxdaLbWUvwsdRqQJSKSRBZOnplI2tqxvqKCtXmYQDUqWNbMqyHGkBTCT4jOnWWKBKsBabd2vbA1ay37qyHGcIUkDrnqKCQbWU3fTNZKHAYkP62mzSNfr7jORkisUPygPLGvGpdmHWcbv2A5AXtqRWw2fTNZKHAYkP6wtBFnewiOCaWJnspm6IyRQUOJUnt4Sz1Q1qyHGYbap2i9WOlITcBzhcleuoa4XgPhgDrSvhzjzx3IvfB2SA1AiSqqvLzbgz0aliXL2vvx0r3M502SAfewiOGORsxudejNcBzx0EotgQjRKQBnTNfr7jORkisUPygPLGvGpdmxdHfcQQmlWiJgybjU0UQ6Io62mzDZ(AiSqq5aGhBKEy0fXwHTSzhcleuzRLRfpbTcBzx0EotgQjRKQmHZZIO9e0vfej3umJ0sAyfc(mWecleuzRLRfpbTcBzx0EotgQjRKQBXCAplI2tqxvqKCtXmslbRaFgyUE9AiSqq5aGhBKEy0fXwvDrhDBMWzZQvRHWcbLdaESr6HrxeBf2YoewiOCaWJnspm6IyRoYsYUUfRk2Sz1Q1qyHGQkZcmYObwqIlTRQUOJUnZPTzZUO9CMmutwjv3AABEweTNGUQGi5MIzKE8j1ydejh8zGPO9CMmutwjv3M1Nfr7jORkisUPygPL0Wke8zG561NaJ2A6YOn7I2ZzYqnzLuDRPTz1Q1RpbgTfChB2SlApNjd1Kvs1TM2UlfQDvfGvmGGXJjtaCu1vulqfAS5zr0Ec6QcIKBkMrUGvMPlHli41mOlKXLdg5vMScFgyoaUYJpPgBGi5uvx0r3goplI2tqxvqKCtXmsp(KASbIK7zr0Ec6QcIKBkMrAjyf4Zatr75mzOMSsQU10EweTNGUQGi5MIzKv7CHmqKCplI2tqxvqKCtXmY8aDa7GpdmpbgPgui1PVfJXODiSqqLhOdyN6ilj76wmsXMNLNfr7jORkR0tyINGMzEGoGDWNbMzRbwzdZmelbgzytD78aDa7mdXsGrgp(OAmOm2HWcbvEGoGDQJSKSRBnTPJyP60ZIO9e0vLv6jmXtqpfZipQjBPaFgy6shnBy7XKu8y1I23cUYMNfr7jORkR0tyINGEkMrgoQHlsAyocg10jEcA4Zatx6OzdBpMKIhRw0(wWv28SiApbDvzLEct8e0tXmsYAbytNbc0d4ZaZ1tooSCO0IBtYmzGi52NCCy5qbSl2KmtgisUnRwjApNjd1Kvs1TzcNNfr7jORkR0tyINGEkMrcjx0A0SHpdmDPJMnS9yskESAr7BX4zZE2AGv2WmdXsGrg2u3MrkwNoIjP4Xklz6FweTNGUQSspHjEc6Pygzf7MZzPyYU6zR9k8zGjewiOQy3Colft2vpBTxvdGDVdHfcki5IwJMTAaS79yskESAr7Bbxz0E2AGv2WmdXsGrg2u3Mrk4WMPJyskESYsM(NLNfr7jORknauga7UYCb4jOFweTNGUQ0aqzaS76umJeQaadta7y4zr0Ec6QsdaLbWURtXmsi6Q0fnByplI2tqxvAaOma2DDkMrkNwAY4G7O2FweTNGUQ0aqzaS76umJSKWI9QHTeBaZIA)zr0Ec6QsdaLbWURtXmYqEeubagplI2tqxvAaOma2DDkMrkTMQ(jfJwkLNfr7jORknauga7UofZiHUS6LSHzcyh8zGjewiOGi5mbWzPWwEweTNGUQ0aqzaS76umJmBTCT4jOHpdmxpaUYca6qEKYtD0SHTALO9CMmutwjv3M1n7dGR84tQXgisoLN6Ozd7zr0Ec6QsdaLbWURtXmsi6Q0f9zr0Ec6QsdaLbWURtXmsSkzsNSGNcbs7MwSiMAg0fGFGo1gOIu9Nfr7jORknauga7UofZiXQKjDYQ(S8SiApbDvPf3MKzI5YbSlplI2tqxvAXTjzMMIzKAXnbWzbFgyojewiO0IBcGZsHT8SiApbDvPf3MKzAkMrEsuc(mWecleulhWUOWwEweTNGUQ0IBtYmnfZiJj5Cdiy8yYyNLb8zGPlfQDvmjNBabJhtg7SmuulqfASpjewiOIj5Cdiy8yYyNLHcB5zr0Ec6QslUnjZ0umJKSwa20zGa9a(mWCCy5qPf3MKzYarY9SiApbDvPf3MKzAkMrEsuc(mWCaC1jrj1rHJQXcuH21aliGzbKTx3IXEweTNGUQ0IBtYmnfZiVCb(mWCaC1LlQJchvJfOcTRbwqaZciBVUntg7zr0Ec6QslUnjZ0umJud6zquY4XKPUKx6v4ZaZXHLdLwCBsMjdej3ZIO9e0vLwCBsMPPygzGoGobyvdu6e8wY0BOMoymWKv4ZatnWccywaz71TzYyplI2tqxvAXTjzMMIzKYqw8CMmvB5SGpdmxp5a4kzilEotMQTCwMHyjWiLN6OzdBFsr7jOvYqw8CMmvB5SmdXsGrQSnHscl23xp5a4kzilEotMQTCwMyskkp1rZg2QvdGRKHS45mzQ2YzzIjPOoYsYUU902SA1a4kzilEotMQTCwMHyjWiv1fD0TM2(a4kzilEotMQTCwMHyjWi1rws21TyZ(a4kzilEotMQTCwMHyjWiLN6OzdBZZIO9e0vLwCBsMPPygzOq1y9jbh(mWScWkqzpulyvhRqg6Ww8e0kQfOcn2PMoymS10yZQvvawbk7HAgueplKPckZu7kQfOcnGpBNUdBXnPLfnsXjMScF2oDh2IBGvaqsHjRWNTt3HT4MmWScWkqzpuZGI4zHmvqzMAFNA6GXWwtJnplI2tqxvAXTjzMMIzK14JgWNbMAGfeWSaY2Rkn2Du7BXMNLNfr7jORkTg0ZGOetT4Ma4SEweTNGUQ0AqpdIstXmYyso3acgpMm2zzaFgy6sHAxftY5gqW4XKXoldf1cuHg7tcHfcQyso3acgpMm2zzOWwEweTNGUQ0AqpdIstXmsnONbrjJhtM6sEPxHpdmRaScu2dviVQBQ(Lrjf1cuHg7qyHGkKx1nv)YOKcB5zr0Ec6QsRb9miknfZi1GEgeLmEmzQl5LEf(mW0Lc1UkMKZnGGXJjJDwgkQfOcn2HWcbvmjNBabJhtg7SmuylplI2tqxvAnONbrPPygPg0ZGOKXJjtDjV0RWNbMUuO2vXKCUbemEmzSZYqrTavOXUgakdGDRIj5Cdiy8yYyNLH6ilj762SYMNfr7jORkTg0ZGO0umJud6zquY4XKPUKx6v4ZaZjDPqTRIj5Cdiy8yYyNLHIAbQqJNLNfr7jORQcdA5entT4Ma4SEwEweTNGUQkmOLtamTaGoA2Ma4SEwEweTNGUQaAqpdIsmTaGoA2Ma4SEweTNGUQaAqpdIstXmYyso3acgpMm2zzaFgy6sHAxftY5gqW4XKXoldf1cuHg7tcHfcQyso3acgpMm2zzOWwEweTNGUQaAqpdIstXmsnONbrjJhtM6sEPxHpdmRaScu2dviVQBQ(Lrjf1cuHg7qyHGkKx1nv)YOKcB5zr0Ec6QcOb9miknfZiRUCH8i4ZatsxYLkPKMbtttVVAfPl5sLuvqrotttV)SiApbDvb0GEgeLMIzK2N4XWNbMKUKlvsjndMMMEF1ksxYLkPkyTCMMME)zr0Ec6QcOb9miknfZi1GEgeLmEmzQl5LEf(mW0Lc1UkMKZnGGXJjJDwgkQfOcn2HWcbvmjNBabJhtg7SmuylplI2tqxvanONbrPPygPg0ZGOKXJjtDjV0RWNbMUuO2vXKCUbemEmzSZYqrTavOXUgakdGDRIj5Cdiy8yYyNLH6ilj762SYMNfr7jORkGg0ZGO0umJud6zquY4XKPUKx6v4ZaZjDPqTRIj5Cdiy8yYyNLHIAbQqJNLNfr7jORkGDXMKzIPfa0rZ2eaNf8zG5KqyHGYca6OzBcGZsHT8SiApbDvbSl2KmttXmYyso3acgpMm2zzaFgy6sHAxftY5gqW4XKXoldf1cuHg7tcHfcQyso3acgpMm2zzOWwEweTNGUQa2fBsMPPygz1LRIDWONfr7jORkGDXMKzAkMrQb9mikz8yYuxYl9k8zGzfGvGYEOc5vDt1VmkPOwGk04zr0Ec6QcyxSjzMMIzKK1cWModeOhWNbMJdlhkGDXMKzYarY9SiApbDvbSl2KmttXmszilEotMQTCwWNbMRNCaCLmKfpNjt1wolZqSeyKYtD0SHTpPO9e0kzilEotMQTCwMHyjWiv2MqjHf77RNCaCLmKfpNjt1woltmjfLN6OzdB1QbWvYqw8CMmvB5SmXKuuhzjzx3EABwTAaCLmKfpNjt1wolZqSeyKQ6Io6wtBFaCLmKfpNjt1wolZqSeyK6ilj76wSzFaCLmKfpNjt1wolZqSeyKYtD0SHT5zr0Ec6QcyxSjzMMIzKvSoKhbVMbDHmUCWiVYKv4ZaZJchvJfOc9SiApbDvbSl2KmttXmslaOd5rWRzqxiJlhmYRmzf(mW8OWr1ybQqRwbHfckysr0EQnWWKBKsRWwEweTNGUQa2fBsMPPygz1LlKhbFgyQbZulTR6ewSBccTt6sUujL0myAA69Nfr7jORkGDXMKzAkMrAFIhdFgyoPgmtT0UQtyXUji0oPl5sLusZGPPP3FweTNGUQa2fBsMPPygPg0ZGOKXJjtDjV0RWNbMRHWcbfPl5sLmfSwof2YQvqyHGI0LCPsMkOiNcBzZZIO9e0vfWUytYmnfZiRUCH8i4ZaZ1KUKlvsLTPG1YTAfPl5sLuvqrotttVVz1Q1KUKlvsLTPG1YTdHfcQQlxf7GrgYAbytNf1UPG1YPWw28SiApbDvbSl2KmttXms7t8yUZDoh]] )


end