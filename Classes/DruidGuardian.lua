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

    spec:RegisterPack( "Guardian", 20210829, [[dKeJ(bqiHIhbQuTjLQpHcjJsP4ukLwfOsIxju1SavDlqLK2fj)siAyOqDmusltjXZeQyAOqCnuk2gkL4BcvkJtOs6COukRduPW8us6EOO9bQ4GGkLSqHspefszIOuQIlkuPYhfQu1jfQeReLyMGkfDtukvPDIs1prPuzPOuQQEkunvHWxbvk1yrPuv2lQ(lfdgYHjwmipMutwsxgzZc(mOmAPYPfTAuivVwinBPCBkz3k(nWWLQookL0Yv55smDQUou2Us8Dk14bvIZJcwpOsQ5RKA)QAoR8i44vXjo7RW4vyLXX1vyBkwJBmEL4W244od9ehVx0rfyehFelIJh3JjxnLHJ3lm0asLhbhVaWonXX7CVVa3iYiHLEhgKsdSISKwynXtWOpj4rwslDKCCiSS5XLHdXXRItC2xHXRWkJJRRW2uSg3y8kXjUYXfmVdCCC80IrJJ3L1knCioELkAoECpMC1uMhX2ZHL1Nf4wyWWk(JwHTb)JwHXRW6ZYZcJwNmWOcCJNf4QpkUmAW1doXPhXOjEKS9cat0CEu)LGl9KkpAtgEuHCphypklps3r6OuDR6zbU6JIlJgC9GtC6rGEpbZJCWJkDzWF0gW9Ob4BFeefah9ignWSaIskoEllEHhbhVXGwobWJGZoR8i44I2tWWXTaGjAoMa4S440iqnQYJL7CNJdrYXJGZoR8i440iqnQYJLJRV0PlfoEmpccleuqKCMa4Suy9CCr7jy44qKCMa4S4oN9v4rWXPrGAuLhlhxFPtxkCCxA04Qoso3acgVJm2zRQOrGAu9r7pAZJCPrJRGKMmAYiHqoPZGIgbQr1hT9r7psdwOrgxTqJ3XWXXfTNGHJ3rY5gqW4DKXoBvUZzpo8i440iqnQYJLJRV0Plfo(MhT5rqyHGcM0eTNAdmm5QPmkS(hT9r7ps0EUqgAiRKkpA1hTYJ2(O1RF0MhT5rqyHGcM0eTNAdmm5QPmkS(hT9r7pkMhvbUYcaMqEKYtD0CG9O9hjApxidnKvsLhbNhX6J2FKlhmYvEArghyQj9i48iwx5rB54I2tWWXTaGjKhXDo7mcpcooncuJQ8y546lD6sHJV5rvGRSaGjKhPoYsYP8Ovz(O48O9hT5rqyHGcM0eTNAdmm5QPmkS(hT9r7ps0EUqgAiRKkpcopInpA)rUCWix5PfzCGPM0JGZJyDLhTLJlApbdh3caMqEe35SZgEeCCAeOgv5XYX1x60LchFZJokCuPtGA0J2FKO9CHm0qwjvE0QpALhT)ixoyKR80ImoWut6rW5rSUYJ2(O1RF0MhfZJQaxzbatips5PoAoWE0(JeTNlKHgYkPYJGZJy9r7pYLdg5kpTiJdm1KEeCEeRR8OTCCr7jy44waWeYJ4oND2cpcoUO9emC8twObGvmHJg4Ag440iqnQYJL7C2JB8i440iqnQYJLJlApbdhNrh4ydmkVZuPINddfJwAnoU(sNUu44AWcnY4QfA8ogoo(iwehNrh4ydmkVZuPINddfJwAnUZzpUYJGJtJa1OkpwoUO9emCC)Yjk5SYX1x60LchpMhbHfcQ(dy3uy9pA)rAWcnY4QfA8ogooEPbCoUF5eLCw5oND2gpcooncuJQ8y54I2tWWX9lNOKVchxFPtxkC8yEeewiO6pGDtH1)O9hPbl0iJRwOX7y444LgW54(LtuYxH7C2zLX8i440iqnQYJLJRV0PlfoUgSqJmUAHgVJH7r7pccleu5OLBepbJ6iljNYJGdZhTcJ8O9hbHfcQC0YnINGrDKLKt5rRY8rRWgoUO9emC8EGNGH7C2zLvEeCCAeOgv5XYX1x60LchpMhvpSSQ0IBtYczGi5E0(JI5r1dlRkGDZMKfYarYXXfTNGHJRbZcikz8oYu6Zl9c35SZ6k8i440iqnQYJLJRV0Plfo(MhbHfcQtwObGvmHJg4Aguy9pA96hfZJ0GfAKXvl04DmCpAlhx0EcgooeDf6IYDo7SghEeCCAeOgv5XYX1x60LchFZJGWcb1jl0aWkMWrdCndkS(hTE9JI5rAWcnY4QfA8ogUhTLJlApbdhphTCJ4jy4oNDwzeEeCCAeOgv5XYX1x60LchFZJGWcbfeDf6IAGi5uy9pA96hbHfcQC0YnINGXadtUAkJbemyxbOvy9pAlhx0EcgooeDf6IMdmUZzNv2WJGJtJa1OkpwoU(sNUu44BEumpQcCLuLEpxitXwoltvSeyKYtD0CG9O9hfZJeTNGrjvP3ZfYuSLZYuflbgPYXeAjSo)r7pAZJI5rvGRKQ075czk2Yzz6iPP8uhnhypA96hvbUsQsVNlKPylNLPJKM6iljNYJGZJIZJ2(O1RFuf4kPk9EUqMITCwMQyjWivXfD0hT6JIZJ2Fuf4kPk9EUqMITCwMQyjWi1rwsoLhT6JyZJ2Fuf4kPk9EUqMITCwMQyjWiLN6O5a7rB54I2tWWXLQ075czk2YzXDo7SYw4rWXPrGAuLhlhx0EcgoU3DsPZarYXX1x60Lch)OWrLobQrpA96hvbUY7oP0zGi5ufx0rF0QpkopA96hT5rvGR8UtkDgisovXfD0hT6JyKhT)OdBOa4GrQgwii5eWku1qwqNOjfXwXY(EQ(OTpA96hjApxidnKvsLhbhMpIr44Ag0nY4YbJ8cNDw5oNDwJB8i440iqnQYJLJRV0Plfo(jWivLcPo9hbNhXkJF0(JkK75aROSKbwJmwGJ44I2tWWXTKbwJ4oNDwJR8i440iqnQYJLJRV0PlfoEbG1GYPQ6XkowJm0H17jyu0iqnQ(O9hT5rBEKgaAvG9O8UtkDgiso1rwsoLhbNhX4hT)ina0Qa7rzjdSgPoYsYP8i48ig)OTpA)rBEuf4klayc5rQJSKCkpcomFuCE02hT)Onpccleu5OLBepbJbgMC1ugdiyWUcqRQa75r7pccleuq0vOlQbIKtvb2ZJ2FeewiOGjnr7P2adtUAkJQcSNhT9rBF061pQaWAq5uvlGM4zJmfqBHgxrJa1OkhphNUdR3nzGJxaynOCQQfqt8SrMcOTqJVVrdaTkWEuE3jLodejN6iljNcCy8UgaAvG9OSKbwJuhzj5uGdJ3YXZXP7W6DtAzr1uCIJZkhx0EcgoEOrLo9jbNJNJt3H17gynaK044SYDo7SY24rWXPrGAuLhlhxFPtxkCCiSqqLJwUr8emgyyYvtzmGGb7kaTQcSNhT)iiSqqbrxHUOgisovfyppA)rI2ZfYqdzLu5rWH5JyeoUO9emC8ID2tgisoUZzFfgZJGJtJa1OkpwoU(sNUu44qyHGkhTCJ4jyuy9pA)rI2ZfYqdzLu5rR(O48O9hT5rqyHGYbaVZit1OBITQ4Io6JGdZhTYJ2(O1RF0MhbHfckha8oJmvJUj2kS(hT)iiSqq5aG3zKPA0nXwDKLKt5rR(iwvS5rBF061pAZJGWcbvrweyKrdSGexgxvCrh9rWH5JIZJ2(O1RFeewiOGORqxudejNcR)r7ps0EUqgAiRKkpA1hfhoUO9emCClbRXDo7RWkpcooncuJQ8y546lD6sHJV5rqyHGQilcmYObwqIlJRkUOJ(i4W8rS(OTpA)rBEeewiOCaW7mYun6MyRW6F02hT)iiSqqLJwUr8emkS(hT)ir75czOHSsQ8iMpAfoUO9emCClbRXDo7RScpcooncuJQ8y546lD6sHJdHfcQC0YnINGrH1)O9hjApxidnKvsLhTkZhfhoUO9emCClzG1iUZzFL4WJGJtJa1OkpwoU(sNUu44BE0MhT5rqyHGYbaVZit1OBITQ4Io6JGdZhTYJ2(O1RF0MhbHfckha8oJmvJUj2kS(hT)iiSqq5aG3zKPA0nXwDKLKt5rR(iwvS5rBF061pAZJGWcbvrweyKrdSGexgxvCrh9rWH5JIZJ2(OTpA)rI2ZfYqdzLu5rR(O48OTCCr7jy44wcwJ7C2xHr4rWXPrGAuLhlhxFPtxkCCr75czOHSsQ8i48iw54I2tWWX9UtkDgisoUZzFf2WJGJtJa1OkpwoU(sNUu44BE0MhDcm6rR(i2gJF02hT)ir75czOHSsQ8OvFuCE02hTE9J28Onp6ey0Jw9rXv28OTpA)rI2ZfYqdzLu5rR(O48O9h5sJgxvayndiy8oYeahvCfncuJQpAlhx0EcgoULmWAe35SVcBHhbhNgbQrvESCCr7jy449yTf6s4AIJRV0PlfoEf4kV7KsNbIKtvCrh9rW5rRWX1mOBKXLdg5fo7SYDo7Re34rWXfTNGHJ7DNu6mqKCCCAeOgv5XYDo7Rex5rWXPrGAuLhlhxFPtxkCCr75czOHSsQ8OvFuC44I2tWWXTeSg35SVcBJhbhx0EcgoEXo7jdejhhNgbQrvESCNZECympcooncuJQ8y546lD6sHJFcmsvPqQt)rR(igHXpA)rqyHGkpWeWo1rwsoLhT6JySInCCr7jy445bMa2XDUZXTspHjEcgEeC2zLhbhNgbQrvESCC9LoDPWXZrdSYbMPkwcmYWMYJGZJYdmbSZuflbgz8UJkDGw9r7pccleu5bMa2PoYsYP8OvFuCEeCLh1jfN44I2tWWXZdmbSJ7C2xHhbhNgbQrvESCC9LoDPWXDzIMdShT)OosAENQx7pA1hXwydhx0Ecgo(rdzlnUZzpo8i440iqnQYJLJRV0PlfoUlt0CG9O9h1rsZ7u9A)rR(i2cB44I2tWWXdhnW1jvnhbJg6epbd35SZi8i440iqnQYJLJRV0Plfo(MhfZJQhwwvAXTjzHmqKCpA)rX8O6HLvfWUztYczGi5E02hTE9JeTNlKHgYkPYJGdZhTchx0Ecgooz1dSPZabMk35SZgEeCCAeOgv5XYX1x60Lch3LjAoWE0(J6iP5DQET)OvFuCJnpA)r5Obw5aZuflbgzyt5rW5rmwX6JGR8OosAENYsGlCCr7jy44qYfTenhUZzNTWJGJtJa1OkpwoU(sNUu44qyHGQGDl5I0m5u8C0Ervb2ZJ2FeewiOGKlAjAoQkWEE0(J6iP5DQET)OvFeBHXpA)r5Obw5aZuflbgzyt5rW5rmwTcBEeCLh1rsZ7uwcCHJlApbdhVGDl5I0m5u8C0EH7CNJ3FKgybjopco7SYJGJtJa1OkpwoELk6l79emC84o4cPXCQ(iikao6rAGfK4pcIGLtr9i4wAn17LhnGbUANCwbS2JeTNGP8iW0yqXXfTNGHJhnN6rvtPpV0lCNZ(k8i440iqnQYJLJRV0PlfoUlnACvhjNBabJ3rg7Svv0iqnQ(O9hT5r1dlRkT42KSqgisUhT)iiSqqPf3eaNLcR)rRx)O6HLvfWUztYczGi5E0(JGWcbLfamrZXeaNLcR)rRx)iiSqqzbat0CmbWzPW6F0(JCPrJRGKMmAYiHqoPZGIgbQr1hTLJlApbdhVJKZnGGX7iJD2QCNZEC4rWXPrGAuLhlhxFPtxkCCiSqqPf3eaNLcR)r7pQEyzvPf3MKfYarYXXfTNGHJ3Fa7g35SZi8i440iqnQYJLJRV0PlfoEmpccleuYWGjaolfw)J2F0MhT5rX8O6HLvfWUztYczGi5E0(JI5r1dlRkT42KSqgisUhT9r7pAZJI5rAWcnY4QjH15MGqpA7J2(O1RF0MhT5rX8O6HLvfWUztYczGi5E0(JI5r1dlRkT42KSqgisUhT9r7pAZJ0GfAKXvtcRZnbHE0(JCPrJRoQ4Gt8emgjeYjDgu0iqnQ(OTpAlhx0EcgooejNjaolUZzNn8i440iqnQYJLJRV0PlfooewiOSaGjAoMa4Suy9pA)r1dlRkGDZMKfYarY9O9hfZJ0GfAKXvtcRZnbH44I2tWWXTpX74oND2cpcooncuJQ8y546lD6sHJdHfcklayIMJjaolfw)J2Fu9WYQcy3SjzHmqKCpA)rAWcnY4QjH15MGqCCr7jy44fxUqEe35Sh34rWXPrGAuLhlhxFPtxkC8caRbLtv1JvCSgzOdR3tWOOrGAu9rRx)OcaRbLtvTaAINnYuaTfACfncuJQC8CC6oSE3KboEbG1GYPQwanXZgzkG2cnohphNUdR3nPLfvtXjooRCCr7jy44Hgv60NeCoEooDhwVBG1aqsJJZk35ohVXGworZJGZoR8i44I2tWWX1IBcGZIJtJa1OkpwUZDoELccwZ5rWzNvEeCCAeOgv5XYXRurFzVNGHJh3bxinMt1hrl0XWJ80IEK3rps0o4EuwEKSiztGAKIJlApbdhVefR1mqsPJ7C2xHhbhNgbQrvESCCr7jy44m6ahBGr5DMkv8CyOy0sRXX1x60LchpMhbHfcQ(dy3uy9pA)rX8inyHgzC1cnEhdhhFelIJZOdCSbgL3zQuXZHHIrlTg35ShhEeCCAeOgv5XYXfTNGHJ7xorjNvoU(sNUu44X8iiSqq1Fa7McR)r7pkMhPbl0iJRwOX7y444LgW54(LtuYzL7C2zeEeCCAeOgv5XYXfTNGHJ7xorjFfoU(sNUu44X8iiSqq1Fa7McR)r7pkMhPbl0iJRwOX7y444LgW54(LtuYxH7C2zdpcooncuJQ8y546lD6sHJhZJ0GfAKXvl04DmCpA)rBE0MhT5rU0OXvDKCUbemEhzSZwvrJa1O6J2FeewiO6i5Cdiy8oYyNTQcR)rBF0(J28O6HLvLwCBswidej3JwV(r1dlRkGDZMKfYarY9OTpA)rX8iiSqq1Fa7McR)rBF061pAZJ28iiSqqbrxHUOgisofw)JwV(rqyHGkhTCJ4jymWWKRMYyabd2vaAfw)J2(O9hT5rX8O6HLvLwCBswidej3J2FumpQEyzvbSB2KSqgisUhT9rBF0woUO9emC8EGNGH7C2zl8i440iqnQYJLJRV0PlfoE9WYQslUnjlKbIK7r7pkMhPbl0iJRwOX7y4E0(JGWcbvoA5gXtWyGHjxnLXacgSRa0QkWEE0(JGWcbfeDf6IAGi5uvG98O9hT5rBEKgaAvG9O8UtkDgiso1rwsoLhbNhX4hT)ina0Qa7rzjdSgPoYsYP8i48ig)O9hvbUYcaMqEK6iljNYJGdZhbtxFu8pIXk28O9hDcm6rR(igHXpA)rqyHGkhTCJ4jymWWKRMYyabd2vaAvfyppA)rqyHGcIUcDrnqKCQkWEE0(JGWcbfmPjAp1gyyYvtzuvG98OTpA96hT5rqyHGslUjaolfw)J2Fen0bJHhbNhTcBE02hTE9J28OkWvNeLuhfoQ0jqn6r7pQcC1L9QJchv6eOg9OTpA96hT5rh2qbWbJuaX7mGGX7id1Q0zQhwwveBfl77P6J2FumpccleuaX7mGGX7id1Q0zQhwwvy9pA)rBEeewiO0IBcGZsH1)O9hrdDWy4rW5rRW4hT9r7pccleuDKCUbemEhzSZwvDKLKt5rRY8rSY4hT9rRx)OnpsdwOrgxfLHlL5r7psdaTkWEuKvpWModeyQQJSKCkpAvMpI1hT)ir75czOHSsQ8OvF0kpA7JwV(rBEeewiO6i5Cdiy8oYyNTQcR)r7pIg6GXWJGZJyBm(rBF0woEXVu7C2zLJlApbdh)WgJO9emMwwCoEllUzelIJRf3MKfI7C2JB8i440iqnQYJLJRV0PlfoE9WYQslUnjlKbIK7r7psdwOrgxTqJ3XW9O9hT5rBEKgaAvG9O8UtkDgiso1rwsoLhbNhX4hT)ina0Qa7rzjdSgPoYsYP8i48ig)O9hvbUYcaMqEK6iljNYJGdZhbtxFu8pIXk28O9hDcm6rR(igHXpA)rqyHGkhTCJ4jymWWKRMYyabd2vaAvfyppA)rqyHGcIUcDrnqKCQkWEE0(JGWcbfmPjAp1gyyYvtzuvG98O9hDcm6rR(igHXpA)rqyHGkhTCJ4jymWWKRMYyabd2vaAvfyppA)rqyHGcIUcDrnqKCQkWEE0(JGWcbfmPjAp1gyyYvtzuvG98OTpA96hT5rqyHGslUjaolfw)J2Fen0bJHhbNhTcBE02hTE9J28OkWvNeLuhfoQ0jqn6r7pQcC1L9QJchv6eOg9O9hDcm6rR(igHXpA)rqyHGkhTCJ4jymWWKRMYyabd2vaAvfyppA)rqyHGcIUcDrnqKCQkWEE0(JGWcbfmPjAp1gyyYvtzuvG98OTpAlhV4xQDo7SYXfTNGHJFyJr0EcgtllohVLf3mIfXX1IBtYcXDo7XvEeCCAeOgv5XYX1x60LchpMhvpSSQ0IBtYczGi5E0(JGWcbLwCtaCwkSEoEXVu7C2zLJlApbdh)WgJO9emMwwCoEllUzelIJRf3MKfI7C2zB8i440iqnQYJLJRV0PlfoE9WYQcy3SjzHmqKCpA)rBE0MhPbGwfypkV7KsNbIKtDKLKt5rW5rm(r7psdaTkWEuwYaRrQJSKCkpcopIXpA)rNaJE0QpIv28O9hbHfcQC0YnINGrvb2ZJ2FeewiOGORqxudejNQcSNhT)iiSqqbtAI2tTbgMC1ugvfyppA7JwV(rBEeewiOSaGjAoMa4Suy9pA)rvGRkytipsDu4OsNa1OhT9rRx)OnpccleuwaWenhtaCwkS(hT)iiSqq1rY5gqW4DKXoBvfw)J2(O1RF0MhDydfahmsbeVZacgVJmuRsNPEyzvrSvSSVNQpA)rX8iiSqqbeVZacgVJmuRsNPEyzvH1)OTpA96hT5rAWcnY4QjH15MGqpA)rAaOvb2JsdMfquY4DKP0Nx6f1rwsoLhTkZhX6J2(O1RF0MhPbl0iJRIYWLY8O9hPbGwfypkYQhytNbcmv1rwsoLhTkZhX6J2FKO9CHm0qwjvE0QpALhT9rB54f)sTZzNvoUO9emC8dBmI2tWyAzX54TS4MrSiooWUztYcXDo7SYyEeCCAeOgv5XYX1x60LchpMhvpSSQa2nBswidej3J2FeewiOSaGjAoMa4Suy9C8IFP25SZkhx0Ecgo(Hngr7jymTS4C8wwCZiwehhy3SjzH4oNDwzLhbhNgbQrvESCC9LoDPWXRhwwva7MnjlKbIK7r7pccleuwaWenhtaCwkSEoEXVu7C2zLJlApbdh)WgJO9emMwwCoEllUzelIJdSB2KSqCNZoRRWJGJtJa1OkpwoELk6l79emC84s4r20J6Kf6rWnzqlN8OgbJMQCm8iITIL99u9rYuFeK0KrtpscHCsNHhjLhjpYLgn(JSPhvStx39OCCWJSaGjAopkaoRhz3rdTq3J8o6rng0YjpccleEuwEK4pcCpcIAa7hTYJkKMJlApbdh)WgJO9emMwwCoU(sNUu44BE0MhDydfahms1yqlNumHgrEoWmWAPvFHueBfl77P6J2(O9hT5rU0OXvqstgnzKqiN0zqrJa1O6J2(O9hT5rqyHGQXGwoPycnI8CGzG1sR(cPW6F02hT)Onpccleung0YjftOrKNdmdSwA1xi1rwsoLhTkZhTYJ2(OTC8wwCZiwehVXGwobWDo7SghEeCCAeOgv5XYXRurFzVNGHJhxcpYMEuNSqpcUjdA5Kh1iy0uLJHhrSvSSVNQpsM6Jc0jThjHqoPZWJKYJKh5sJg)r20Jk2PR7Euoo4rb6K2JcGZ6r2D0ql09iVJEuJbTCYJGWcHhLLhj(Ja3JGOgW(rR8OcP54I2tWWXpSXiApbJPLfNJRV0Plfo(MhT5rh2qbWbJung0YjftOrKNdmdSwA1xifXwXY(EQ(OTpA)rBEKlnACvGoPzKqiN0zqrJa1O6J2(O9hT5rqyHGQXGwoPycnI8CGzG1sR(cPW6F02hT)Onpccleung0YjftOrKNdmdSwA1xi1rwsoLhTkZhTYJ2(OTC8wwCZiwehVXGworZDo7SYi8i440iqnQYJLJxPI(YEpbdhpUeEKnXOo6rYJMewNhe6rYuFKn9Okyyu(JSLXFKdEKwCBswOib2nBswi4FKm1hztpQtwOhbjnz0uKb6K2JKqiN0z4rU0OXPk8pcUDhn0cDpsdMfqu6r66JYYJW6FKn9OID66UhLJdEKec5KodpkaoRh5GhPLI)O0H)rD0rpYcaMO58Oa4SuCCr7jy44h2yeTNGX0YIZX1x60LchVqUNdSIQ0Lb3eaNrdMfqu6r7pAZJ28ixA04kiPjJMmsiKt6mOOrGAu9rBF0(J28OyEu9WYQslUnjlKbIK7rBF0(J28OyEu9WYQcy3SjzHmqKCpA7J2F0MhPbl0iJRMewNBcc9O9hPbGwfypknywarjJ3rMsFEPxuhzj5uE0QmFeRpA7J2YXBzXnJyrCCGgmlGOe35SZkB4rWXPrGAuLhlhVsf9L9EcgoECj8iBIrD0JKhnjSopi0JKP(iB6rvWWO8hzlJ)ih8iT42KSqrcSB2KSqW)izQpYMEuNSqpcsAYOPid0jThjHqoPZWJCPrJtv4FeC7oAOf6EKgmlGO0J01hLLhH1)iB6rf701Dpkhh8ijeYjDgEuaCwpYbpslf)rPd)J6OJEKw8a4SEuaCwkoUO9emC8dBmI2tWyAzX546lD6sHJxi3Zbwrv6YGBcGZObZcik9O9hT5rBEKlnACvGoPzKqiN0zqrJa1O6J2(O9hT5rX8O6HLvLwCBswidej3J2(O9hT5rX8O6HLvfWUztYczGi5E02hT)OnpsdwOrgxnjSo3ee6r7psdaTkWEuAWSaIsgVJmL(8sVOoYsYP8Ovz(iwF02hTLJ3YIBgXI44AnywarjUZzNv2cpcooncuJQ8y54I2tWWX1sRzeTNGX0YIZXBzXnJyrCCR0tyINGH7C2znUXJGJtJa1OkpwoUO9emC8dBmI2tWyAzX54TS4MrSiooejh35ohxlUnjlepco7SYJGJlApbdhV)a2nooncuJQ8y5oN9v4rWXPrGAuLhlhxFPtxkC8yEeewiO0IBcGZsH1ZXfTNGHJRf3eaNf35ShhEeCCAeOgv5XYX1x60Lchhcleu9hWUPW654I2tWWXpjkXDo7mcpcooncuJQ8y546lD6sHJ7sJgx1rY5gqW4DKXoBvfncuJQpA)rX8iiSqq1rY5gqW4DKXoBvfwphx0EcgoEhjNBabJ3rg7Sv5oND2WJGJtJa1OkpwoU(sNUu441dlRkT42KSqgisooUO9emCCYQhytNbcmvUZzNTWJGJtJa1OkpwoU(sNUu44vGRojkPokCuPtGA0J2FKgybbm9GC8YJw9rmchx0Ecgo(jrjUZzpUXJGJtJa1OkpwoU(sNUu44vGRUSxDu4OsNa1OhT)inWccy6b54LhbhMpIr44I2tWWXVSN7C2JR8i440iqnQYJLJRV0PlfoE9WYQslUnjlKbIKJJlApbdhxdMfquY4DKP0Nx6fUZzNTXJGJtJa1OkpwoU(sNUu44AGfeW0dYXlpcomFeJWXfTNGHJhOdOtawXaLoXXTe4IHg6GXaNDw5oNDwzmpcooncuJQ8y546lD6sHJV5rX8OkWvsv69CHmfB5SmvXsGrkp1rZb2J2Fumps0EcgLuLEpxitXwoltvSeyKkhtOLW68hT)OnpkMhvbUsQsVNlKPylNLPJKMYtD0CG9O1RFuf4kPk9EUqMITCwMosAQJSKCkpcopkopA7JwV(rvGRKQ075czk2YzzQILaJufx0rF0QpkopA)rvGRKQ075czk2YzzQILaJuhzj5uE0QpInpA)rvGRKQ075czk2YzzQILaJuEQJMdShTLJlApbdhxQsVNlKPylNf35SZkR8i440iqnQYJLJRV0PlfoEbG1GYPQ6XkowJm0H17jyu0iqnQ(O9hrdDWy4rR(O4WMhTE9JkaSguov1cOjE2itb0wOXv0iqnQYXZXP7W6Dtg44fawdkNQAb0epBKPaAl0470qhmgwnoSHJNJt3H17M0YIQP4ehNvoUO9emC8qJkD6tcohphNUdR3nWAaiPXXzL7C2zDfEeCCAeOgv5XYX1x60LchpMhDydfahmsvpbdwNBabtLOEtaOXkkAeOgvF0(JI5rAWcnY4QfA8ogUhTE9J28OyE0HnuaCWiv9emyDUbemvI6nbGgROOrGAu9r7pkMhbHfcQoso3acgVJm2zRQW6F0woUO9emC8ID2tgisoUZzN14WJGJtJa1OkpwoU(sNUu44hfoQ0jqn6r7psdSGaMEqoE5rR(i2WXfTNGHJFsuI7C2zLr4rWXPrGAuLhlhxFPtxkCCnWccy6b54fLg7oA8hT6Jydhx0EcgoEP7Ok35ohxdaTkWEk8i4SZkpcoUO9emC8EGNGHJtJa1OkpwUZzFfEeCCr7jy44qnaOAcyhdCCAeOgv5XYDo7XHhbhx0EcgooeDf6IMdmooncuJQ8y5oNDgHhbhx0EcgoUCAziJdUJgNJtJa1OkpwUZzNn8i44I2tWWXBjSoVyy0XQWSOX540iqnQYJL7C2zl8i44I2tWWXd5rqnaOYXPrGAuLhl35Sh34rWXfTNGHJlJMk(jnJwAnooncuJQ8y5oN94kpcooncuJQ8y546lD6sHJdHfckisotaCwkSEoUO9emCCOllElhyMa2XDo7SnEeCCAeOgv5XYX1x60LchFZJQaxzbatips5PoAoWE061ps0EUqgAiRKkpcopI1hT9r7pQcCL3DsPZarYP8uhnhyCCr7jy445OLBepbd35SZkJ5rWXfTNGHJdrxHUOCCAeOgv5XYDo7SYkpcooncuJQ8y54I2tWWX1mOBa)atQnqnP4CCkeiTBgXI44Ag0nGFGj1gOMuCUZzN1v4rWXfTNGHJJvit6KvHJtJa1OkpwUZDooqdMfquIhbNDw5rWXfTNGHJBbat0CmbWzXXPrGAuLhl35SVcpcooncuJQ8y546lD6sHJ7sJgx1rY5gqW4DKXoBvfncuJQpA)rX8iiSqq1rY5gqW4DKXoBvfwphx0EcgoEhjNBabJ3rg7Sv5oN94WJGJtJa1OkpwoU(sNUu44fawdkNQkKxXnf)YOKIgbQr1hT)iiSqqfYR4MIFzusH1ZXfTNGHJRbZcikz8oYu6Zl9c35SZi8i440iqnQYJLJRV0PlfooPBzFHuYWGzi4I)O1RFePBzFHufqtoZqWfNJlApbdhV4YfYJ4oND2WJGJtJa1OkpwoU(sNUu44KUL9fsjddMHGl(JwV(rKUL9fs1Wg5mdbxCoUO9emCC7t8oUZzNTWJGJtJa1OkpwoU(sNUu44U0OXvDKCUbemEhzSZwvrJa1O6J2FeewiO6i5Cdiy8oYyNTQcRNJlApbdhxdMfquY4DKP0Nx6fUZzpUXJGJtJa1OkpwoU(sNUu44U0OXvDKCUbemEhzSZwvrJa1O6J2FKgaAvG9O6i5Cdiy8oYyNTQ6iljNYJGZJyLnCCr7jy44AWSaIsgVJmL(8sVWDo7XvEeCCAeOgv5XYX1x60LchpMh5sJgx1rY5gqW4DKXoBvfncuJQCCr7jy44AWSaIsgVJmL(8sVWDUZX1AWSaIs8i4SZkpcoUO9emCCT4Ma4S440iqnQYJL7C2xHhbhNgbQrvESCC9LoDPWXDPrJR6i5Cdiy8oYyNTQIgbQr1hT)OyEeewiO6i5Cdiy8oYyNTQcRNJlApbdhVJKZnGGX7iJD2QCNZEC4rWXPrGAuLhlhxFPtxkC8caRbLtvfYR4MIFzusrJa1O6J2FeewiOc5vCtXVmkPW654I2tWWX1GzbeLmEhzk95LEH7C2zeEeCCAeOgv5XYX1x60Lch3LgnUQJKZnGGX7iJD2QkAeOgvF0(JGWcbvhjNBabJ3rg7Svvy9CCr7jy44AWSaIsgVJmL(8sVWDo7SHhbhNgbQrvESCC9LoDPWXDPrJR6i5Cdiy8oYyNTQIgbQr1hT)ina0Qa7r1rY5gqW4DKXoBv1rwsoLhbNhXkB44I2tWWX1GzbeLmEhzk95LEH7C2zl8i440iqnQYJLJRV0PlfoEmpYLgnUQJKZnGGX7iJD2QkAeOgv54I2tWWX1GzbeLmEhzk95LEH7CNJdSB2KSq8i4SZkpcooncuJQ8y546lD6sHJhZJGWcbLfamrZXeaNLcRNJlApbdh3caMO5ycGZI7C2xHhbhNgbQrvESCC9LoDPWXDPrJR6i5Cdiy8oYyNTQIgbQr1hT)OyEeewiO6i5Cdiy8oYyNTQcRNJlApbdhVJKZnGGX7iJD2QCNZEC4rWXfTNGHJxC5kyhmIJtJa1OkpwUZzNr4rWXPrGAuLhlhxFPtxkC8caRbLtvfYR4MIFzusrJa1Okhx0EcgoUgmlGOKX7itPpV0lCNZoB4rWXPrGAuLhlhxFPtxkC86HLvfWUztYczGi544I2tWWXjREGnDgiWu5oND2cpcooncuJQ8y546lD6sHJV5rX8OkWvsv69CHmfB5SmvXsGrkp1rZb2J2Fumps0EcgLuLEpxitXwoltvSeyKkhtOLW68hT)OnpkMhvbUsQsVNlKPylNLPJKMYtD0CG9O1RFuf4kPk9EUqMITCwMosAQJSKCkpcopkopA7JwV(rvGRKQ075czk2YzzQILaJufx0rF0QpkopA)rvGRKQ075czk2YzzQILaJuhzj5uE0QpInpA)rvGRKQ075czk2YzzQILaJuEQJMdShTLJlApbdhxQsVNlKPylNf35Sh34rWXPrGAuLhlhx0EcgoEbBc5rCC9LoDPWXpkCuPtGAehxZGUrgxoyKx4SZk35Shx5rWXPrGAuLhlhx0EcgoUfamH8ioU(sNUu44hfoQ0jqn6rRx)iiSqqbtAI2tTbgMC1ugfwphxZGUrgxoyKx4SZk35SZ24rWXPrGAuLhlhxFPtxkCCnyHgzC1KW6CtqOhT)is3Y(cPKHbZqWfNJlApbdhV4YfYJ4oNDwzmpcooncuJQ8y546lD6sHJhZJ0GfAKXvtcRZnbHE0(JiDl7lKsggmdbxCoUO9emCC7t8oUZzNvw5rWXPrGAuLhlhxFPtxkC8npccleuKUL9fY0Wg5uy9pA96hbHfcks3Y(czkGMCkS(hTLJlApbdhxdMfquY4DKP0Nx6fUZzN1v4rWXPrGAuLhlhxFPtxkC8npI0TSVqQCmnSrUhTE9JiDl7lKQaAYzgcU4pA7JwV(rBEePBzFHu5yAyJCpA)rqyHGQ4YvWoyKHS6b20zrJBAyJCkS(hTLJlApbdhV4YfYJ4oNDwJdpcoUO9emCC7t8oooncuJQ8y5o35ohFHUscgo7RW4vyLXX1vyBCCB5MCGv44WTHBX2p7Xf2J7HB8Ohfrh9O0QhC(JcG7rmkT42KSqmQhDeBflpQ(OcWIEKG5alXP6J0DYaJkQNf4M5qpI1vGB8ignWSqNt1hXOoSHcGdgPy7Jr9ih8ig1HnuaCWifBFkAeOgvzupAZkWLTQNLNL4Ivp4CQ(iwz9rI2tW8Oww8I6zHJx6jnNDwzmJWX7pqiBehhUd3FuCpMC1uMhX2ZHL1Nf4oC)rWTWGHv8hTcBd(hTcJxH1NLNf4oC)rmADYaJkWnEwG7W9hbx9rXLrdUEWjo9ignXJKTxayIMZJ6VeCPNu5rBYWJkK75a7rz5r6oshLQBvplWD4(JGR(O4YObxp4eNEeO3tW8ih8Osxg8hTbCpAa(2hbrbWrpIrdmlGOK6z5zbU)O4o4cPXCQ(iikao6rAGfK4pcIGLtr9i4wAn17LhnGbUANCwbS2JeTNGP8iW0yq9SiApbtr1FKgybjE8mJmAo1JQMsFEPxEweTNGPO6psdSGepEMr2rY5gqW4DKXoBv4ZatxA04Qoso3acgVJm2zRQOrGAuDFt9WYQslUnjlKbIKBhcleuAXnbWzPW6xVUEyzvbSB2KSqgisUDiSqqzbat0CmbWzPW6xVgcleuwaWenhtaCwkS(DxA04kiPjJMmsiKt6mOOrGAuD7ZIO9emfv)rAGfK4XZmY(dy3GpdmHWcbLwCtaCwkS(96HLvLwCBswidej3ZIO9emfv)rAGfK4XZmsisotaCwWNbMXaHfckzyWeaNLcRFFZMyQhwwva7MnjlKbIKBpM6HLvLwCBswidej329nXObl0iJRMewNBccTD761B2et9WYQcy3SjzHmqKC7XupSSQ0IBtYczGi52UVrdwOrgxnjSo3eeA3LgnU6OIdoXtWyKqiN0zqrJa1O62TplI2tWuu9hPbwqIhpZiTpX7GpdmHWcbLfamrZXeaNLcRFVEyzvbSB2KSqgisU9y0GfAKXvtcRZnbHEweTNGPO6psdSGepEMrwC5c5rWNbMqyHGYcaMO5ycGZsH1VxpSSQa2nBswidej3UgSqJmUAsyDUji0ZIO9emfv)rAGfK4XZmYqJkD6tco8zGzbG1GYPQ6XkowJm0H17jyu0iqnQUEDbG1GYPQwanXZgzkG2cnUIgbQrv4ZXP7W6DtAzr1uCIjRWNJt3H17gynaK0yYk8540Dy9UjdmlaSguov1cOjE2itb0wOXFwEwG7pkUdUqAmNQpIwOJHh5Pf9iVJEKODW9OS8izrYMa1i1ZIO9emfMLOyTMbskDplI2tWuINzKyfYKozb)iwetgDGJnWO8otLkEomumAP1GpdmJbcleu9hWUPW63JrdwOrgxTqJ3XW9SiApbtjEMrIvit6Kf8LgWz6xorjNv4ZaZyGWcbv)bSBkS(9y0GfAKXvl04DmCplI2tWuINzKyfYKozbFPbCM(LtuYxb(mWmgiSqq1Fa7McRFpgnyHgzC1cnEhd3ZIO9emL4zgzpWtWaFgygJgSqJmUAHgVJHBFZMnU0OXvDKCUbemEhzSZwvrJa1O6oewiO6i5Cdiy8oYyNTQcRF7(M6HLvLwCBswidej3611dlRkGDZMKfYarYTDpgiSqq1Fa7McRF761B2aHfcki6k0f1arYPW6xVgcleu5OLBepbJbgMC1ugdiyWUcqRW63UVjM6HLvLwCBswidej3Em1dlRkGDZMKfYarYTD72Nf4oC)rmAIBtYsoWEKO9empQLf)r2zR9ii6rNmpkdW)ilzG1Oi9UtkDpso6rG5r6k8p6ey0JYYJGOgW(rmcJH)rW10f9rYuFuoA5gXtW8i5Ohvb2ZJKP(O4EmPjAp1pcgMC1uMhbHfcpklpAa(JeTNle8pcCpkdW)iBIrD0JY5rAXdGZ6rYuFen0bJHhLLhjqGf6rRWg4FeB39Om8iB6rDYc9iVJEeBN4DpQrWOPkhdpIyRyzFpvH)rEh9OkbHfcpQLtuQ(ih8O0FuwE0a8hH1)izQpIg6GXWJYYJeiWc9Ovym8SD3JYWJSjg1rpkkdxkZJKP(O4oREGnDpccm1hPbGwfyppklpcR)rYuFenKvsLhjh9OCc0LG7ro4rROEweTNGPepZipSXiApbJPLfh(IFP2zYk8Jyrm1IBtYcbFgywpSSQ0IBtYczGi52JrdwOrgxTqJ3XWTdHfcQC0YnINGXadtUAkJbemyxbOvvG9SdHfcki6k0f1arYPQa7zFZgna0Qa7r5DNu6mqKCQJSKCkWHX7AaOvb2JYsgynsDKLKtbomEVcCLfamH8i1rwsof4WeMUgpJvSz)ey0QmcJ3HWcbvoA5gXtWyGHjxnLXacgSRa0QkWE2HWcbfeDf6IAGi5uvG9SdHfckyst0EQnWWKRMYOQa7z761BGWcbLwCtaCwkS(DAOdgdWzf2SD96nvGRojkPokCuPtGA0Ef4Ql7vhfoQ0jqnA761BoSHcGdgPaI3zabJ3rgQvPZupSSQi2kw23t19yGWcbfq8odiy8oYqTkDM6HLvfw)(giSqqPf3eaNLcRFNg6GXaCwHXB3HWcbvhjNBabJ3rg7Svvhzj5uwLjRmE761B0GfAKXvrz4sz21aqRcShfz1dSPZabMQ6iljNYQmzDx0EUqgAiRKkRUY21R3aHfcQoso3acgVJm2zRQW63PHoymah2gJ3U9zr0EcMs8mJ8WgJO9emMwwC4l(LANjRWpIfXulUnjle8zGz9WYQslUnjlKbIKBxdwOrgxTqJ3XWTVzJgaAvG9O8UtkDgiso1rwsof4W4Dna0Qa7rzjdSgPoYsYPahgVxbUYcaMqEK6iljNcCyctxJNXk2SFcmAvgHX7qyHGkhTCJ4jymWWKRMYyabd2vaAvfyp7qyHGcIUcDrnqKCQkWE2HWcbfmPjAp1gyyYvtzuvG9SFcmAvgHX7qyHGkhTCJ4jymWWKRMYyabd2vaAvfyp7qyHGcIUcDrnqKCQkWE2HWcbfmPjAp1gyyYvtzuvG9SD96nqyHGslUjaolfw)on0bJb4ScB2UE9MkWvNeLuhfoQ0jqnAVcC1L9QJchv6eOgTFcmAvgHX7qyHGkhTCJ4jymWWKRMYyabd2vaAvfyp7qyHGcIUcDrnqKCQkWE2HWcbfmPjAp1gyyYvtzuvG9SD7ZIO9emL4zg5Hngr7jymTS4Wx8l1otwHFelIPwCBswi4ZaZyQhwwvAXTjzHmqKC7qyHGslUjaolfw)ZcChU)i2o7Mnjl5a7rI2tW8Oww8hzNT2JGOhDY8Oma)JSKbwJI07oP09i5OhbMhPRW)OtGrpklpcIAa7hXkBG)rW10f9rYuFuoA5gXtW8i5Ohvb2ZJKP(O4EmPjAp1pcgMC1uMhbHfcpklpAa(JeTNlK6rSD3JYa8pYMyuh9OCEKfamrZ5rbWz9izQpQGnH8OhLLhDu4OsNa1i4FeB39Om8iB6rDYc9iVJEeBN4DpQrWOPkhdpIyRyzFpvH)rEh9OkbHfcpQLtuQ(ih8O0FuwE0a8hH1Ry7UhLHhztmQJEuugUuMhjt9rXDw9aB6EeeyQpsdaTkWEEuwEew)JKP(iAiRKkpso6rqudy)OvG)rG7rz4r2eJ6OhXEcRZFuqOhjt9rmAGzbeLEKU(OS8iSE1ZIO9emL4zg5Hngr7jymTS4Wx8l1otwHFelIjWUztYcbFgywpSSQa2nBswidej3(MnAaOvb2JY7oP0zGi5uhzj5uGdJ31aqRcShLLmWAK6iljNcCy8(jWOvzLn7qyHGkhTCJ4jyuvG9SdHfcki6k0f1arYPQa7zhcleuWKMO9uBGHjxnLrvb2Z21R3aHfcklayIMJjaolfw)Ef4Qc2eYJuhfoQ0jqnA761BGWcbLfamrZXeaNLcRFhcleuDKCUbemEhzSZwvH1VD96nh2qbWbJuaX7mGGX7id1Q0zQhwwveBfl77P6EmqyHGciENbemEhzOwLot9WYQcRF761B0GfAKXvtcRZnbH21aqRcShLgmlGOKX7itPpV0lQJSKCkRYK1TRxVrdwOrgxfLHlLzxdaTkWEuKvpWModeyQQJSKCkRYK1Dr75czOHSsQS6kB3(SiApbtjEMrEyJr0Ecgtllo8f)sTZKv4hXIycSB2KSqWNbMXupSSQa2nBswidej3oewiOSaGjAoMa4Suy9plI2tWuINzKh2yeTNGX0YId)iwetGDZMKfc(IFP2zYk8zGz9WYQcy3SjzHmqKC7qyHGYcaMO5ycGZsH1)Sa3FuCj8iB6rDYc9i4MmOLtEuJGrtvogEeXwXY(EQ(izQpcsAYOPhjHqoPZWJKYJKh5sJg)r20Jk2PR7Euoo4rwaWenNhfaN1JS7OHwO7rEh9OgdA5KhbHfcpklps8hbUhbrnG9Jw5rfs)SiApbtjEMrEyJr0Ecgtllo8JyrmBmOLtaWNbMB2Cydfahms1yqlNumHgrEoWmWAPvFHueBfl77P629nU0OXvqstgnzKqiN0zqrJa1O629nqyHGQXGwoPycnI8CGzG1sR(cPW63UVbcleung0YjftOrKNdmdSwA1xi1rwsoLvzUY2TplW9hfxcpYMEuNSqpcUjdA5Kh1iy0uLJHhrSvSSVNQpsM6Jc0jThjHqoPZWJKYJKh5sJg)r20Jk2PR7Euoo4rb6K2JcGZ6r2D0ql09iVJEuJbTCYJGWcHhLLhj(Ja3JGOgW(rR8OcPFweTNGPepZipSXiApbJPLfh(rSiMng0YjA4ZaZnBoSHcGdgPAmOLtkMqJiphygyT0QVqkITIL99uD7(gxA04QaDsZiHqoPZGIgbQr1T7BGWcbvJbTCsXeAe55aZaRLw9fsH1VDFdewiOAmOLtkMqJiphygyT0QVqQJSKCkRYCLTBFwG7pkUeEKnXOo6rYJMewNhe6rYuFKn9Okyyu(JSLXFKdEKwCBswOib2nBswi4FKm1hztpQtwOhbjnz0uKb6K2JKqiN0z4rU0OXPk8pcUDhn0cDpsdMfqu6r66JYYJW6FKn9OID66UhLJdEKec5KodpkaoRh5GhPLI)O0H)rD0rpYcaMO58Oa4SuplI2tWuINzKh2yeTNGX0YId)iwetGgmlGOe8zGzHCphyfvPldUjaoJgmlGO0(MnU0OXvqstgnzKqiN0zqrJa1O629nXupSSQ0IBtYczGi52UVjM6HLvfWUztYczGi52UVrdwOrgxnjSo3eeAxdaTkWEuAWSaIsgVJmL(8sVOoYsYPSktw3U9zbU)O4s4r2eJ6OhjpAsyDEqOhjt9r20JQGHr5pYwg)ro4rAXTjzHIey3SjzHG)rYuFKn9OozHEeK0KrtrgOtApscHCsNHh5sJgNQW)i42D0ql09inywarPhPRpklpcR)r20Jk2PR7Euoo4rsiKt6m8Oa4SEKdEKwk(Jsh(h1rh9iT4bWz9Oa4SuplI2tWuINzKh2yeTNGX0YId)iwetTgmlGOe8zGzHCphyfvPldUjaoJgmlGO0(MnU0OXvb6KMrcHCsNbfncuJQB33et9WYQslUnjlKbIKB7(MyQhwwva7MnjlKbIKB7(gnyHgzC1KW6CtqODna0Qa7rPbZcikz8oYu6Zl9I6iljNYQmzD72Nfr7jykXZmsT0Agr7jymTS4WpIfX0k9eM4jyEweTNGPepZipSXiApbJPLfh(rSiMqKCplplI2tWuuqKCmHi5mbWzbFgygdewiOGi5mbWzPW6FweTNGPOGi5INzKDKCUbemEhzSZwf(mW0LgnUQJKZnGGX7iJD2QkAeOgv334sJgxbjnz0KrcHCsNbfncuJQB31GfAKXvl04DmCplI2tWuuqKCXZmslayc5rWNbMB2aHfckyst0EQnWWKRMYOW63UlApxidnKvsLvxz761B2aHfckyst0EQnWWKRMYOW63Uhtf4klayc5rkp1rZb2UO9CHm0qwjvGdR7UCWix5PfzCGPMeCyDLTplI2tWuuqKCXZmslayc5rWNbMBQaxzbatipsDKLKtzvMXzFdewiOGjnr7P2adtUAkJcRF7UO9CHm0qwjvGdB2D5GrUYtlY4atnj4W6kBFweTNGPOGi5INzKwaWeYJGpdm3Cu4OsNa1ODr75czOHSsQS6k7UCWix5PfzCGPMeCyDLTRxVjMkWvwaWeYJuEQJMdSDr75czOHSsQahw3D5GrUYtlY4atnj4W6kBFweTNGPOGi5INzKNSqdaRychnW1m8SiApbtrbrYfpZiXkKjDYc(rSiMm6ahBGr5DMkv8CyOy0sRbFgyQbl0iJRwOX7y4EweTNGPOGi5INzKyfYKozbFPbCM(LtuYzf(mWmgiSqq1Fa7McRFxdwOrgxTqJ3XW9SiApbtrbrYfpZiXkKjDYc(sd4m9lNOKVc8zGzmqyHGQ)a2nfw)UgSqJmUAHgVJH7zr0EcMIcIKlEMr2d8emWNbMAWcnY4QfA8ogUDiSqqLJwUr8emQJSKCkWH5kmYoewiOYrl3iEcg1rwsoLvzUcBEweTNGPOGi5INzKAWSaIsgVJmL(8sVaFgygt9WYQslUnjlKbIKBpM6HLvfWUztYczGi5EweTNGPOGi5INzKq0vOlQbIKd(mWCdewiOozHgawXeoAGRzqH1VEDmAWcnY4QfA8ogUTplI2tWuuqKCXZmYC0YnINGb(mWCdewiOozHgawXeoAGRzqH1VEDmAWcnY4QfA8ogUTplI2tWuuqKCXZmsi6k0fnhyWNbMBGWcbfeDf6IAGi5uy9RxdHfcQC0YnINGXadtUAkJbemyxbOvy9BFweTNGPOGi5INzKsv69CHmfB5SGpdm3etf4kPk9EUqMITCwMQyjWiLN6O5aBpgr7jyusv69CHmfB5SmvXsGrQCmHwcRZ33etf4kPk9EUqMITCwMosAkp1rZb261vGRKQ075czk2Yzz6iPPoYsYPaN4SD96kWvsv69CHmfB5SmvXsGrQIl6ORgN9kWvsv69CHmfB5SmvXsGrQJSKCkRYM9kWvsv69CHmfB5SmvXsGrkp1rZb22Nfr7jykkisU4zgP3DsPZarYbVMbDJmUCWiVWKv4ZaZJchv6eOgTEDf4kV7KsNbIKtvCrhD14SE9MkWvE3jLodejNQ4Io6QmY(HnuaCWivdleKCcyfQAilOt0KIyRyzFpv3UETO9CHm0qwjvGdtg5zr0EcMIcIKlEMrAjdSgbFgyEcmsvPqQthoSY49c5EoWkklzG1iJf4ONfr7jykkisU4zgzOrLo9jbh(mWSaWAq5uv9yfhRrg6W69emkAeOgv33SrdaTkWEuE3jLodejN6iljNcCy8UgaAvG9OSKbwJuhzj5uGdJ3UVPcCLfamH8i1rwsof4WmoB33aHfcQC0YnINGXadtUAkJbemyxbOvvG9SdHfcki6k0f1arYPQa7zhcleuWKMO9uBGHjxnLrvb2Z2TRxxaynOCQQfqt8SrMcOTqJROrGAuf(CC6oSE3KwwunfNyYk8540Dy9UbwdajnMScFooDhwVBYaZcaRbLtvTaAINnYuaTfA89nAaOvb2JY7oP0zGi5uhzj5uGdJ31aqRcShLLmWAK6iljNcCy82Nfr7jykkisU4zgzXo7j4ZatiSqqLJwUr8emgyyYvtzmGGb7kaTQcSNDiSqqbrxHUOgisovfyp7I2ZfYqdzLubomzKNfr7jykkisU4zgPLG1GpdmHWcbvoA5gXtWOW63fTNlKHgYkPYQXzFdewiOCaW7mYun6MyRkUOJchMRSD96nqyHGYbaVZit1OBITcRFhcleuoa4DgzQgDtSvhzj5uwLvfB2UE9giSqqvKfbgz0aliXLXvfx0rHdZ4SD9AiSqqbrxHUOgisofw)UO9CHm0qwjvwnoplI2tWuuqKCXZmslbRbFgyUbcleufzrGrgnWcsCzCvXfDu4WK1T7BGWcbLdaENrMQr3eBfw)2DiSqqLJwUr8emkS(Dr75czOHSsQWCLNfr7jykkisU4zgPLmWAe8zGjewiOYrl3iEcgfw)UO9CHm0qwjvwLzCEweTNGPOGi5INzKwcwd(mWCZMnqyHGYbaVZit1OBITQ4IokCyUY21R3aHfckha8oJmvJUj2kS(DiSqq5aG3zKPA0nXwDKLKtzvwvSz761BGWcbvrweyKrdSGexgxvCrhfomJZ2T7I2ZfYqdzLuz14S9zr0EcMIcIKlEMr6DNu6mqKCWNbMI2ZfYqdzLuboS(SiApbtrbrYfpZiTKbwJGpdm3S5ey0QSngVDx0EUqgAiRKkRgNTRxVzZjWOvJRSz7UO9CHm0qwjvwno7U0OXvfawZacgVJmbWrfxrJa1O62Nfr7jykkisU4zgzpwBHUeUMGxZGUrgxoyKxyYk8zGzf4kV7KsNbIKtvCrhfoR8SiApbtrbrYfpZi9UtkDgisUNfr7jykkisU4zgPLG1GpdmfTNlKHgYkPYQX5zr0EcMIcIKlEMrwSZEYarY9SiApbtrbrYfpZiZdmbSd(mW8eyKQsHuN(QmcJ3HWcbvEGjGDQJSKCkRYyfBEwEweTNGPOSspHjEcgM5bMa2bFgyMJgyLdmtvSeyKHnf4KhycyNPkwcmY4Dhv6aT6oewiOYdmbStDKLKtz14axPtko9SiApbtrzLEct8emXZmYJgYwAWNbMUmrZb2EhjnVt1R9vzlS5zr0EcMIYk9eM4jyINzKHJg46KQMJGrdDINGb(mW0LjAoW27iP5DQETVkBHnplI2tWuuwPNWepbt8mJKS6b20zGatf(mWCtm1dlRkT42KSqgisU9yQhwwva7MnjlKbIKB761I2ZfYqdzLubomx5zr0EcMIYk9eM4jyINzKqYfTenh4ZatxMO5aBVJKM3P61(QXn2SNJgyLdmtvSeyKHnf4WyfRWv6iP5DklbU8SiApbtrzLEct8emXZmYc2TKlsZKtXZr7f4ZatiSqqvWULCrAMCkEoAVOQa7zhcleuqYfTenhvfyp7DK08ovV2xLTW49C0aRCGzQILaJmSPahgRwHnWv6iP5DklbU8S8SiApbtrPbGwfypfM9apbZZIO9emfLgaAvG9uINzKqnaOAcyhdplI2tWuuAaOvb2tjEMrcrxHUO5a7zr0EcMIsdaTkWEkXZms50YqghChn(ZIO9emfLgaAvG9uINzKTewNxmm6yvyw04plI2tWuuAaOvb2tjEMrgYJGAaq9zr0EcMIsdaTkWEkXZmsz0uXpPz0sR9SiApbtrPbGwfypL4zgj0LfVLdmta7GpdmHWcbfejNjaolfw)ZIO9emfLgaAvG9uINzK5OLBepbd8zG5MkWvwaWeYJuEQJMdS1RfTNlKHgYkPcCyD7Ef4kV7KsNbIKt5PoAoWEweTNGPO0aqRcSNs8mJeIUcDrFweTNGPO0aqRcSNs8mJeRqM0jl4PqG0UzelIPMbDd4hysTbQjf)zr0EcMIsdaTkWEkXZmsSczsNSkplplI2tWuuAXTjzHy2Fa72ZIO9emfLwCBswO4zgPwCtaCwWNbMXaHfckT4Ma4Suy9plI2tWuuAXTjzHINzKNeLGpdmHWcbv)bSBkS(Nfr7jykkT42KSqXZmYoso3acgVJm2zRcFgy6sJgx1rY5gqW4DKXoBvfncuJQ7XaHfcQoso3acgVJm2zRQW6FweTNGPO0IBtYcfpZijREGnDgiWuHpdmRhwwvAXTjzHmqKCplI2tWuuAXTjzHINzKNeLGpdmRaxDsusDu4OsNa1ODnWccy6b54LvzKNfr7jykkT42KSqXZmYl7HpdmRaxDzV6OWrLobQr7AGfeW0dYXlWHjJ8SiApbtrPf3MKfkEMrQbZcikz8oYu6Zl9c8zGz9WYQslUnjlKbIK7zr0EcMIslUnjlu8mJmqhqNaSIbkDcElbUyOHoymWKv4ZatnWccy6b54f4WKrEweTNGPO0IBtYcfpZiLQ075czk2YzbFgyUjMkWvsv69CHmfB5SmvXsGrkp1rZb2EmI2tWOKQ075czk2YzzQILaJu5ycTewNVVjMkWvsv69CHmfB5SmDK0uEQJMdS1RRaxjvP3ZfYuSLZY0rstDKLKtboXz761vGRKQ075czk2YzzQILaJufx0rxno7vGRKQ075czk2YzzQILaJuhzj5uwLn7vGRKQ075czk2YzzQILaJuEQJMdSTplI2tWuuAXTjzHINzKHgv60NeC4ZaZcaRbLtv1JvCSgzOdR3tWOOrGAuDNg6GXWQXHnRxxaynOCQQfqt8SrMcOTqJROrGAuf(CC6oSE3KwwunfNyYk8540Dy9UbwdajnMScFooDhwVBYaZcaRbLtvTaAINnYuaTfA8DAOdgdRgh28SiApbtrPf3MKfkEMrwSZEc(mWmMdBOa4GrQ6jyW6CdiyQe1BcanwzpgnyHgzC1cnEhd361BI5WgkaoyKQEcgSo3acMkr9MaqJv2JbcleuDKCUbemEhzSZwvH1V9zr0EcMIslUnjlu8mJ8KOe8zG5rHJkDcuJ21aliGPhKJxwLnplI2tWuuAXTjzHINzKLUJQWNbMAGfeW0dYXlkn2D04RYMNLNfr7jykkTgmlGOetT4Ma4SEweTNGPO0AWSaIsXZmYoso3acgVJm2zRcFgy6sJgx1rY5gqW4DKXoBvfncuJQ7XaHfcQoso3acgVJm2zRQW6FweTNGPO0AWSaIsXZmsnywarjJ3rMsFEPxGpdmlaSguovviVIBk(LrjfncuJQ7qyHGkKxXnf)YOKcR)zr0EcMIsRbZcikfpZi1GzbeLmEhzk95LEb(mW0LgnUQJKZnGGX7iJD2QkAeOgv3HWcbvhjNBabJ3rg7Svvy9plI2tWuuAnywarP4zgPgmlGOKX7itPpV0lWNbMU0OXvDKCUbemEhzSZwvrJa1O6UgaAvG9O6i5Cdiy8oYyNTQ6iljNcCyLnplI2tWuuAnywarP4zgPgmlGOKX7itPpV0lWNbMX4sJgx1rY5gqW4DKXoBvfncuJQplplI2tWuung0YjAMAXnbWz9S8SiApbtr1yqlNayAbat0CmbWz9S8SiApbtrb0GzbeLyAbat0CmbWz9SiApbtrb0GzbeLINzKDKCUbemEhzSZwf(mW0LgnUQJKZnGGX7iJD2QkAeOgv3JbcleuDKCUbemEhzSZwvH1)SiApbtrb0GzbeLINzKAWSaIsgVJmL(8sVaFgywaynOCQQqEf3u8lJskAeOgv3HWcbviVIBk(Lrjfw)ZIO9emffqdMfqukEMrwC5c5rWNbMKUL9fsjddMHGl(61KUL9fsvan5mdbx8Nfr7jykkGgmlGOu8mJ0(eVd(mWK0TSVqkzyWmeCXxVM0TSVqQg2iNzi4I)SiApbtrb0GzbeLINzKAWSaIsgVJmL(8sVaFgy6sJgx1rY5gqW4DKXoBvfncuJQ7qyHGQJKZnGGX7iJD2QkS(Nfr7jykkGgmlGOu8mJudMfquY4DKP0Nx6f4ZatxA04Qoso3acgVJm2zRQOrGAuDxdaTkWEuDKCUbemEhzSZwvDKLKtboSYMNfr7jykkGgmlGOu8mJudMfquY4DKP0Nx6f4ZaZyCPrJR6i5Cdiy8oYyNTQIgbQr1NLNfr7jykkGDZMKfIPfamrZXeaNf8zGzmqyHGYcaMO5ycGZsH1)SiApbtrbSB2KSqXZmYoso3acgVJm2zRcFgy6sJgx1rY5gqW4DKXoBvfncuJQ7XaHfcQoso3acgVJm2zRQW6FweTNGPOa2nBswO4zgzXLRGDWONfr7jykkGDZMKfkEMrQbZcikz8oYu6Zl9c8zGzbG1GYPQc5vCtXVmkPOrGAu9zr0EcMIcy3SjzHINzKKvpWModeyQWNbM1dlRkGDZMKfYarY9SiApbtrbSB2KSqXZmsPk9EUqMITCwWNbMBIPcCLuLEpxitXwoltvSeyKYtD0CGThJO9emkPk9EUqMITCwMQyjWivoMqlH157BIPcCLuLEpxitXwolthjnLN6O5aB96kWvsv69CHmfB5SmDK0uhzj5uGtC2UEDf4kPk9EUqMITCwMQyjWivXfD0vJZEf4kPk9EUqMITCwMQyjWi1rwsoLvzZEf4kPk9EUqMITCwMQyjWiLN6O5aB7ZIO9emffWUztYcfpZilytipcEnd6gzC5GrEHjRWNbMhfoQ0jqn6zr0EcMIcy3SjzHINzKwaWeYJGxZGUrgxoyKxyYk8zG5rHJkDcuJwVgcleuWKMO9uBGHjxnLrH1)SiApbtrbSB2KSqXZmYIlxipc(mWudwOrgxnjSo3eeAN0TSVqkzyWmeCXFweTNGPOa2nBswO4zgP9jEh8zGzmAWcnY4QjH15MGq7KUL9fsjddMHGl(ZIO9emffWUztYcfpZi1GzbeLmEhzk95LEb(mWCdewiOiDl7lKPHnYPW6xVgcleuKUL9fYuan5uy9BFweTNGPOa2nBswO4zgzXLlKhbFgyUH0TSVqQCmnSrU1RjDl7lKQaAYzgcU4BxVEdPBzFHu5yAyJC7qyHGQ4YvWoyKHS6b20zrJBAyJCkS(TplI2tWuua7Mnjlu8mJ0(eVJ7CNZb]] )


end