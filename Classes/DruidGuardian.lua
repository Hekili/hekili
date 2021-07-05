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

    spec:RegisterPack( "Guardian", 20210705, [[dCeCRbqivqpsLuztOIpjijJsL4uQqRsqk8kvGzbPClvsr2fL(ffXWGu1XOiTmvk9muLAAcsCnuLSniv03eKuJtLu4CQKswNkPOmpvsUhQ0(uP4GQKsLfkiEOkPktuLuuDrbPOpQskLtcPsTsvQMPkPQ6MQKsv7evv)esL4PqmvufFvLuv2lk)LudgQdtSyqEmjtwQUmYMf6ZqYOLsNw0QHuj9AkQzlPBtHDR43knCP44qQWYv1ZLy6uDDqTDv03fy8cs15rvz9csP5lO2pWmtz8Wq6Itm(Vf93Ak6d1ONxw0Fn4fVV9AWqC(AigsJOmlOigYiged5Adw(EkddPr4RUsNXddPSWVIyiTU3uUMzIjOsVfgYQwdtkPbCv8Ch1lr3KsAOmHHabNvhDpmigsxCIX)TO)wtrFOg98YI(RbV49THAgIa7T7ZqqsJRhdPn7DAyqmKovumKRny57Pma818ho7G73HR8bW8cna(w0Fl6b3b3VETYGIkxZa3VMay09O2VzFXja(6jUjx73DmNda385(PNubGVKraUqUNdkaolaSQLuMP(rl4(1eaJUh1(n7lobWBJN7aW(cWL2m6a8L9b4z9Jamef3Na4R3oNRzYYqQzXlmEyiv(uYllJhg)MY4HHikp3HHyS7yohDCFdgcncuL6SqyoZziqK8mEy8BkJhgcncuL6SqyiQpD6tHHCiadbhJwisEDCFdlCddruEUddbIKxh33G5m(VLXddruEUdd5LtAw4Io(0eA5JHqJavPoleMZ4N3mEyi0iqvQZcHHO(0PpfgYHaC)HZUvjEajNKgIKhG5aWhcW9ho72nOgqYjPHi5ziIYZDyiQDoxZK2BjDPj)0lmNXFOW4HHqJavPolegI6tN(uyixayi4y0(YjnlCrhFAcT8zHBa4WHb4dby1EsJmU9KgVLVhGpYqeLN7WqGOVqVzMZ4NxmEyi0iqvQZcHHO(0PpfgYfagcogTVCsZcx0XNMqlFw4gaoCya(qawTN0iJBpPXB57b4Jmer55omKCuYpIN7WCg)OtgpmeAeOk1zHWquF60Ncd5cadbhJwi6l0BwdrYBHBa4WHbyi4y0MJs(r8Chnky57Pm6nQH)YQSWna8rgIO8Chgce9f6nNdkMZ4puZ4HHqJavPolegI6tN(uyixa4db4(6wPlnEEs6sG8g6UyiOiRNkZ5GcG5aWhcWIYZDSsxA88K0La5n0DXqqr2C0XAIQ1byoa8fa(qaUVUv6sJNNKUeiVHULKQ1tL5CqbWHddW91TsxA88K0La5n0TKuTpzi5ua4BayEdWhb4WHb4(6wPlnEEs6sG8g6UyiOiBXfLza(kaM3amhaUVUv6sJNNKUeiVHUlgckY(KHKtbGVcG5faZbG7RBLU045jPlbYBO7IHGISEQmNdka(idruEUddr6sJNNKUeiVbZz8Fny8WqOrGQuNfcdr9PtFkmKNIpvAfOkbWHddW91TE7lLwnejVT4IYmaFfaZBaoCya(ca3x36TVuA1qK82IlkZa8vaCOaWCa4hEO4(OiBfogLCIWfQRjdOxuKLqhWztd1b4JaC4WaSO88K00qgjva4B4cWHcdruEUddXBFP0QHi5zoJ)RfJhgcncuL6SqyiQpD6tHHCbGVaWqWXOfLufLNknky57Pmw4ga(iaZbGfLNNKMgYiPcaFfaFlaFeGdhgGVaWxayi4y0IsQIYtLgfS89uglCdaFeG5aWhcW91Tg7oX8jRNkZ5GcG5aWIYZtstdzKubGVbGnfG5aWU8Oi36PbP9v3tcGVbGn9wa(idruEUddXy3jMpXCg)MIEgpmeAeOk1zHWquF60Ncd5ca3x3AS7eZNSpzi5ua4R4cW8gG5aWxayi4y0IsQIYtLgfS89uglCdaFeG5aWIYZtstdzKubGVbG5faZbGD5rrU1tds7RUNeaFdaB6Ta8rgIO8ChgIXUtmFI5m(n1ugpmeAeOk1zHWquF60Ncd5fuKTtXuLoaFdaBk6byoaCHCphufRHmOQK2yFIHikp3HHyidQkXCg)MElJhgcncuL6SqyiQpD6tHHCbGFk(uPvGQeaZbGfLNNKMgYiPcaFfaFlaZbGD5rrU1tds7RUNeaFdaB6Ta8raoCya(caFia3x3AS7eZNSEQmNdkaMdalkppjnnKrsfa(ga2uaMda7YJICRNgK2xDpja(ga20Bb4Jmer55omeJDNy(eZz8BkVz8WqOrGQuNfcdr9PtFkmKYcxHYPBBGloCL00d345owAeOk1byoa8fa(caR2T23GX6TVuA1qK82NmKCka8nam6byoaSA3AFdgRHmOQK9jdjNcaFdaJEa(iaZbGVaW91Tg7oX8j7tgsofa(gUamVb4Jamha(cadbhJ2CuYpIN7OrblFpLrVrn8xwLTVbdaZbGHGJrle9f6nRHi5T9nyayoameCmArjvr5PsJcw(EkJTVbdaFeGpcWHddWLfUcLt3EUvXZkPlB9Kg3sJavPodjhN(hUX1zKHuw4kuoD75wfpRKUS1tACoxu7w7BWy92xkTAisE7tgsoLBqph1U1(gmwdzqvj7tgsoLBq)rgsoo9pCJRtddQNItmetziIYZDyiXkvAvVeDgsoo9pCJRrvxiPYqmL5m(nnuy8WqOrGQuNfcdr9PtFkmei4y0MJs(r8Chnky57Pm6nQH)YQS9nyayoameCmAHOVqVznejVTVbdaZbGfLNNKMgYiPcaFdxaouyiIYZDyiLGSH0qK8mNXVP8IXddHgbQsDwime1No9PWqGGJrBok5hXZDSWnamhawuEEsAAiJKka8va8TaC4WameCmAHOVqVznejVfUbG5aWIYZtstdzKubGVcGVLHikp3HHyiWvMZ43u0jJhgcncuL6SqyiQpD6tHHCbGHGJrBrofuKwTgqIlJBlUOmdW3WfGnfGpcWCa4lameCmA9D9wTmDTQkbw4ga(iaZbGHGJrBok5hXZDSWnamhawuEEsAAiJKkamxa(wgIO8ChgIHaxzoJFtd1mEyi0iqvQZcHHO(0PpfgceCmAZrj)iEUJfUbG5aWIYZtstdzKubGVIlaZBgIO8ChgIHmOQeZz8B61GXddHgbQsDwime1No9PWqUaWxa4lameCmA9D9wTmDTQkb2IlkZa8nCb4Bb4JaC4Wa8fagcogT(UERwMUwvLalCdaZbGHGJrRVR3QLPRvvjW(KHKtbGVcGn1Yla(iahomaFbGHGJrBrofuKwTgqIlJBlUOmdW3WfG5naFeGpcWCayr55jPPHmsQaWxbW8gGpYqeLN7Wqme4kZz8B61IXddHgbQsDwime1No9PWqeLNNKMgYiPcaFdaBkdruEUddXBFP0QHi5zoJ)BrpJhgcncuL6SqyiQpD6tHHCbGVaWVGIa4Ra4Rf6b4JamhawuEEsAAiJKka8vamVb4JaC4Wa8fa(ca)ckcGVcGVg8cGpcWCayr55jPPHmsQaWxbW8gG5aWUuPXTLfUQ3O2BjDCFQ4wAeOk1b4Jmer55omedzqvjMZ4)wtz8WqOrGQuNfcdruEUddPbUEsFgAjgI6tN(uyi91TE7lLwnejVT4IYmaFdaFldrXNQsAxEuKxy8BkZz8F7TmEyiIYZDyiE7lLwnejpdHgbQsDwimNX)T8MXddHgbQsDwime1No9PWqeLNNKMgYiPcaFfaZBgIO8ChgIHaxzoJ)Bdfgpmer55omKsq2qAisEgcncuL6SqyoJ)B5fJhgcncuL6SqyiQpD6tHH8ckY2PyQshGVcGdf0dWCayi4y0M)or43(KHKtbGVcGrVLxmer55omK83jc)mN5meJ0tuIN7W4HXVPmEyi0iqvQZcHHO(0PpfgsoQ1ihu6UyiOinVka8naC(7eHFDxmeuK2BFQ0U1oaZbGHGJrB(7eHF7tgsofa(kaM3aCOba3kfNyiIYZDyi5Vte(zoJ)Bz8WqOrGQuNfcdr9PtFkmexgZ5GcG5aWTKu9wBJYb4Ray0jVyiIYZDyipnuGuzoJFEZ4HHqJavPolegI6tN(uyiUmMZbfaZbGBjP6T2gLdWxbWOtEXqeLN7WqIpnH2K66Nqrd9IN7WCg)HcJhgcncuL6SqyiQpD6tHHCbGpeG7pC2TkXdi5K0qK8amha(qaU)Wz3Ub1asojnejpaFeGdhgGfLNNKMgYiPcaFdxa(wgIO8Chgcz0Sb0RH2PZCg)8IXddHgbQsDwime1No9PWqCzmNdkaMda3ss1BTnkhGVcGd18cG5aW5OwJCqP7IHGI08QaW3aWO3AkahAaWTKu9wRHe6mer55omei5nxmNdZz8Joz8WqOrGQuNfcdr9PtFkmei4y0wG)Z8uQ6CkEokVy7BWaWCayi4y0cjV5I5CS9nyayoaCljvV12OCa(kagDIEaMdaNJAnYbLUlgcksZRcaFdaJE7T8cGdna4wsQER1qcDgIO8Chgsb(pZtPQZP45O8cZzodrjEajNeJhg)MY4HHikp3HH08BqLHqJavPoleMZ4)wgpmeAeOk1zHWquF60Ncd5qagcogTkX1X9nSWnmer55omeL464(gmNXpVz8WqOrGQuNfcdr9PtFkmei4y028Bq1c3WqeLN7WqEXmXCg)HcJhgcncuL6SqyiQpD6tHH4sLg32sY76nQ9wshK1ULgbQsDaMdaFiadbhJ2wsExVrT3s6GS2TWnmer55omKwsExVrT3s6GS2zoJFEX4HHqJavPolegI6tN(uyi9ho7wL4bKCsAisEgIO8Chgcz0Sb0RH2PZCg)OtgpmeAeOk1zHWquF60NcdPVU9fZK9P4tLwbQsamhawTgqRUzZXla8vaCOWqeLN7WqEXmXCg)HAgpmeAeOk1zHWquF60NcdPVU9Zg7tXNkTcuLayoaSAnGwDZMJxa4B4cWHcdruEUdd5ZgMZ4)AW4HHqJavPolegI6tN(uyi9ho7wL4bKCsAisEgIO8ChgIANZ1mP9wsxAYp9cZz8FTy8WqOrGQuNfcdr9PtFkme1AaT6MnhVaW3WfGdfgIO8ChgsK(vLlCrdLoXqmKqxtd9O4JXVPmNXVPONXddHgbQsDwime1No9PWqUaWhcW91TsxA88K0La5n0DXqqrwpvMZbfaZbGpeGfLN7yLU045jPlbYBO7IHGIS5OJ1evRdWCa4la8HaCFDR0LgppjDjqEdDljvRNkZ5GcGdhgG7RBLU045jPlbYBOBjPAFYqYPaW3aW8gGpcWHddW91TsxA88K0La5n0DXqqr2IlkZa8vamVbyoaCFDR0LgppjDjqEdDxmeuK9jdjNcaFfaZlaMda3x3kDPXZtsxcK3q3fdbfz9uzohua8rgIO8ChgI0LgppjDjqEdMZ43utz8WqOrGQuNfcdr9PtFkmKYcxHYPBBGloCL00d345owAeOk1byoamn0JIpa(kaM38cGdhgGllCfkNU9CRINvsx26jnULgbQsDgsoo9pCJRZidPSWvOC62ZTkEwjDzRN04COHEu8DfV5fdjhN(hUX1PHb1tXjgIPmer55omKyLkTQxIodjhN(hUX1OQlKuziMYCg)MElJhgcncuL6SqyiQpD6tHHOwdOv3S54fRc(FACa(kaMxmer55omKs7tDMZCgsLpL8IIXdJFtz8WqeLN7WquIRJ7BWqOrGQuNfcZzodPtrbU6mEy8BkJhgcncuL6SqyiDQO(SXZDyiHMHoPGDQdW0j98bWEAqaS3saSO89b4SaWYPKvbQswgIO8ChgsXmCTQHKslZz8FlJhgcncuL6SqyiIYZDyiORRdpOO8FDNkEo8v0kPwziQpD6tHHCiadbhJ2MFdQw4gaMdaFbGHGJrle9f6nRHi5TWnaC4WameCmAZrj)iEUJgfS89ug9g1WFzv2(gmaC4WaSApPrg3ojQwxhfcG5aWQDR9nySQDoxZK2BjDPj)0l2NmKCka8vCbytb4JmKrmigc666Wdkk)x3PINdFfTsQvMZ4N3mEyi0iqvQZcHHO(0PpfgYHameCmAB(nOAHBa4WHb4dbyi4y028Bq1c3aWCaycDaNnnu3IUUo8GIY)1DQ45WxrRKAfG5aWxay1U1(gmwi6l0BwdrYBFYqYPaW3aW8g9aC4WaSA3AFdgBok5hXZD0OGLVNYO3Og(lRY(KHKtbGVbG5n6b4WHby1EsJmUDsuTUokeaZbGv7w7BWyv7CUMjT3s6st(PxSpzi5ua4BayEJEa(idruEUddbUq60jJcZz8hkmEyi0iqvQZcHHO(0PpfgYfa(caFbGDPsJBBj5D9g1ElPdYA3sJavPoaZbGHGJrBljVR3O2BjDqw7w4ga(iaZbGVaW9ho7wL4bKCsAisEaoCyaU)Wz3Ub1asojnejpaFeG5aWhcWqWXOT53GQfUbGpcWHddWxa4lameCmAHOVqVznejVfUbGdhgGHGJrBok5hXZD0OGLVNYO3Og(lRYc3aWhbyoa8fa(qaU)Wz3QepGKtsdrYdWCa4db4(dND7gudi5K0qK8a8ra(iaFKHikp3HH0SEUdZz8ZlgpmeAeOk1zHWquF60NcdP)Wz3QepGKtsdrYdWCayi4y0Qexh33Wc3Wqk(NkNXVPmer55omKhE0IYZD01S4mKAwC9igedrjEajNeZz8Joz8WqOrGQuNfcdr9PtFkmK(dND7gudi5K0qK8amhagcogTg7oMZrh33Wc3Wqk(NkNXVPmer55omKhE0IYZD01S4mKAwC9igedzdQbKCsmNXFOMXddHgbQsDwimKovuF245ome0DeGdiaUvoja(6NpL8caxju00LNpaMqhWztd1byz6amKuLrraSeJ5KoFaSuaybGDPsJdWbeaxcsx1cW54laBS7yohaoUVbah0sdDspa7Teax5tjVaWqWXiaNfawCaEFagIQBaaFlaxifdruEUdd5HhTO8ChDnlodr9PtFkmKla8fa(HhkUpkYw5tjVu0XkrEoO0OQPrtHSe6aoBAOoaFeG5aWxayxQ04wiPkJI0smMt68zPrGQuhGpcWCa4lameCmAR8PKxk6yLiphuAu10OPqw4ga(iaZbGVaWqWXOTYNsEPOJvI8CqPrvtJMczFYqYPaWxXfGVfGpcWhzi1S46rmigsLpL8YYCg)xdgpmeAeOk1zHWq6ur9zJN7Wqq3raoGa4w5Ka4RF(uYlaCLqrtxE(aycDaNnnuhGLPdWr6LkalXyoPZhalfawayxQ04aCabWLG0vTaCo(cWr6Lkah33aGdAPHoPhG9wcGR8PKxayi4yeGZcaloaVpadr1naGVfGlKIHikp3HH8WJwuEUJUMfNHO(0PpfgYfa(ca)Wdf3hfzR8PKxk6yLiphuAu10OPqwcDaNnnuhGpcWCa4laSlvACBKEPQLymN05ZsJavPoaFeG5aWxayi4y0w5tjVu0XkrEoO0OQPrtHSWna8raMdaFbGHGJrBLpL8srhRe55GsJQMgnfY(KHKtbGVIlaFlaFeGpYqQzX1JyqmKkFk5ffZz8FTy8WqOrGQuNfcdPtf1NnEUddbDhb4aku9eala8KOA9OqaSmDaoGa4(oHkhGdKXbyFbyL4bKCsMSb1asoj0ayz6aCabWTYjbWqsvgfzsKEPcWsmMt68bWUuPXPoAa81xln0j9aSANZ1mbWQoaNfagUbGdiaUeKUQfGZXxawIXCsNpaoUVba7laRKIdWPJga3spbWg7oMZbGJ7ByziIYZDyip8OfLN7ORzXziQpD6tHHui3ZbvXwAZORJ7Rv7CUMjaMdaFbGVaWUuPXTqsvgfPLymN05ZsJavPoaFeG5aWxa4db4(dNDRs8asojnejpaFeG5aWxa4db4(dND7gudi5K0qK8a8raMdaFbGv7jnY42jr166OqamhawTBTVbJvTZ5AM0ElPln5NEX(KHKtbGVIlaBkaFeGpYqQzX1JyqmKvTZ5AMyoJFtrpJhgcncuL6SqyiDQO(SXZDyiO7iahqHQNaybGNevRhfcGLPdWbea33ju5aCGmoa7laRepGKtYKnOgqYjHgalthGdiaUvojagsQYOitI0lvawIXCsNpa2Lkno1rdGV(APHoPhGv7CUMjaw1b4SaWWnaCabWLG0vTaCo(cWsmMt68bWX9nayFbyLuCaoD0a4w6jawjECFdaoUVHLHikp3HH8WJwuEUJUMfNHO(0PpfgsHCphufBPnJUoUVwTZ5AMayoa8fa(ca7sLg3gPxQAjgZjD(S0iqvQdWhbyoa8fa(qaU)Wz3QepGKtsdrYdWhbyoa8fa(qaU)Wz3Ub1asojnejpaFeG5aWxay1EsJmUDsuTUokeaZbGv7w7BWyv7CUMjT3s6st(PxSpzi5ua4R4cWMcWhb4JmKAwC9igedrP25CntmNXVPMY4HHqJavPolegIO8ChgIsQvTO8ChDnlodPMfxpIbXqmsprjEUdZz8B6TmEyi0iqvQZcHHikp3HH8WJwuEUJUMfNHuZIRhXGyiqK8mN5mKMNuRbK4mEy8BkJhgcncuL6SqyiDQO(SXZDyiHMHoPGDQdWquCFcGvRbK4ameHkNIfGV2PuuJxa4zNRPw5nIWvawuEUtbG3PYNLHikp3HHyoN(tDDPj)0lmNX)TmEyi0iqvQZcHHO(0PpfgceCmAvIRJ7ByHBayoaC)HZUvjEajNKgIKNHikp3HH08BqL5m(5nJhgcncuL6SqyiQpD6tHHCiadbhJwz4th33Wc3aWCa4la8HaC)HZUvjEajNKgIKhGdhgGHGJrRsCDCFdBFdga(iaZbGVaWhcW9ho72nOgqYjPHi5b4WHbyi4y0AS7yohDCFdBFdga(idruEUddbIKxh33G5m(dfgpmeAeOk1zHWquF60NcdXLknUTLK31Bu7TKoiRDlncuL6amha(ca3F4SBvIhqYjPHi5byoameCmAvIRJ7ByHBa4WHb4(dND7gudi5K0qK8amhagcogTg7oMZrh33Wc3aWHddWqWXO1y3XCo64(gw4gaMda7sLg3cjvzuKwIXCsNplncuL6a8rgIO8ChgsljVR3O2BjDqw7mNXpVy8WqOrGQuNfcdr9PtFkmei4y0AS7yohDCFdlCdaZbG7pC2TBqnGKtsdrYdWCa4dby1EsJmUDsuTUokedruEUddj4fVL5m(rNmEyi0iqvQZcHHO(0PpfgceCmAn2DmNJoUVHfUbG5aW9ho72nOgqYjPHi5byoaSApPrg3ojQwxhfIHikp3HHuC5J5tmNXFOMXddHgbQsDwime1No9PWqklCfkNUTbU4WvstpCJN7yPrGQuhGdhgGllCfkNU9CRINvsx26jnULgbQsDgsoo9pCJRZidPSWvOC62ZTkEwjDzRN04mKCC6F4gxNggupfNyiMYqeLN7WqIvQ0QEj6mKCC6F4gxJQUqsLHykZzodrTBTVbtHXdJFtz8WqeLN7WqAwp3HHqJavPoleMZ4)wgpmer55omeO6UDDe(5JHqJavPoleMZ4N3mEyiIYZDyiq0xO3CoOyi0iqvQZcH5m(dfgpmer55ome5vYqAF)NgNHqJavPoleMZ4NxmEyiIYZDyi1evRx0ORWDug04meAeOk1zHWCg)Otgpmer55omKy(euD3odHgbQsDwimNXFOMXddruEUddrgfv8xQALuRmeAeOk1zHWCg)xdgpmeAeOk1zHWquF60NcdbcogTqK864(gw4ggIO8Chgc0NfVMdkDe(zoJ)RfJhgcncuL6SqyiQpD6tHHCbG7RBn2DI5twpvMZbfahomalkppjnnKrsfa(ga2ua(iaZbG7RB92xkTAisERNkZ5GIHikp3HHKJs(r8ChMZ43u0Z4HHikp3HHarFHEZmeAeOk1zHWCg)MAkJhgcncuL6SqyiIYZDyik(u11)DsLgQkfNHqXiPC9igedrXNQU(VtQ0qvP4mNXVP3Y4HHikp3HHaxiD6KrHHqJavPoleMZCgYQ25CntmEy8BkJhgIO8ChgIXUJ5C0X9nyi0iqvQZcH5m(VLXddHgbQsDwime1No9PWqCPsJBBj5D9g1ElPdYA3sJavPoaZbGpeGHGJrBljVR3O2BjDqw7w4ggIO8ChgsljVR3O2BjDqw7mNXpVz8WqOrGQuNfcdr9PtFkmKYcxHYPBJ5xCDX)0mzPrGQuhG5aWqWXOnMFX1f)tZKfUHHikp3HHO25CntAVL0LM8tVWCg)HcJhgcncuL6SqyiQpD6tHHqQA2uiRm8Phk0DaoCyaMu1SPq2YwLxpuO7mer55omKIlFmFI5m(5fJhgcncuL6SqyiQpD6tHHqQA2uiRm8Phk0DaoCyaMu1SPq2k8iVEOq3ziIYZDyibV4TmNXp6KXddHgbQsDwime1No9PWqCPsJBBj5D9g1ElPdYA3sJavPoaZbGHGJrBljVR3O2BjDqw7w4ggIO8ChgIANZ1mP9wsxAYp9cZz8hQz8WqOrGQuNfcdr9PtFkmexQ042wsExVrT3s6GS2T0iqvQdWCay1U1(gm2wsExVrT3s6GS2Tpzi5ua4Bayt5fdruEUddrTZ5AM0ElPln5NEH5m(VgmEyi0iqvQZcHHO(0PpfgYHaSlvACBljVR3O2BjDqw7wAeOk1ziIYZDyiQDoxZK2BjDPj)0lmN5meLANZ1mX4HXVPmEyiIYZDyikX1X9nyi0iqvQZcH5m(VLXddHgbQsDwime1No9PWqCPsJBBj5D9g1ElPdYA3sJavPoaZbGpeGHGJrBljVR3O2BjDqw7w4ggIO8ChgsljVR3O2BjDqw7mNXpVz8WqOrGQuNfcdr9PtFkmKYcxHYPBJ5xCDX)0mzPrGQuhG5aWqWXOnMFX1f)tZKfUHHikp3HHO25CntAVL0LM8tVWCg)HcJhgcncuL6SqyiQpD6tHH4sLg32sY76nQ9wshK1ULgbQsDaMdadbhJ2wsExVrT3s6GS2TWnmer55ome1oNRzs7TKU0KF6fMZ4NxmEyi0iqvQZcHHO(0PpfgIlvACBljVR3O2BjDqw7wAeOk1byoaSA3AFdgBljVR3O2BjDqw72NmKCka8naSP8IHikp3HHO25CntAVL0LM8tVWCg)OtgpmeAeOk1zHWquF60Ncd5qa2LknUTLK31Bu7TKoiRDlncuL6mer55ome1oNRzs7TKU0KF6fMZCgYgudi5Ky8W43ugpmeAeOk1zHWquF60Ncd5qagcogTg7oMZrh33Wc3WqeLN7Wqm2DmNJoUVbZz8FlJhgcncuL6SqyiQpD6tHH4sLg32sY76nQ9wshK1ULgbQsDaMdaFiadbhJ2wsExVrT3s6GS2TWnmer55omKwsExVrT3s6GS2zoJFEZ4HHikp3HHuC5lWpkIHqJavPoleMZ4puy8WqOrGQuNfcdr9PtFkmKYcxHYPBJ5xCDX)0mzPrGQuNHikp3HHO25CntAVL0LM8tVWCg)8IXddHgbQsDwime1No9PWq6pC2TBqnGKtsdrYZqeLN7WqiJMnGEn0oDMZ4hDY4HHqJavPolegI6tN(uyixa4db4(6wPlnEEs6sG8g6UyiOiRNkZ5GcG5aWhcWIYZDSsxA88K0La5n0DXqqr2C0XAIQ1byoa8fa(qaUVUv6sJNNKUeiVHULKQ1tL5CqbWHddW91TsxA88K0La5n0TKuTpzi5ua4BayEdWhb4WHb4(6wPlnEEs6sG8g6UyiOiBXfLza(kaM3amhaUVUv6sJNNKUeiVHUlgckY(KHKtbGVcG5faZbG7RBLU045jPlbYBO7IHGISEQmNdka(idruEUddr6sJNNKUeiVbZz8hQz8WqOrGQuNfcdruEUddPapX8jgI6tN(uyipfFQ0kqvIHO4tvjTlpkYlm(nL5m(VgmEyi0iqvQZcHHikp3HHyS7eZNyiQpD6tHH8u8PsRavjaoCyagcogTOKQO8uPrblFpLXc3Wqu8PQK2Lhf5fg)MYCg)xlgpmeAeOk1zHWquF60NcdrTN0iJBNevRRJcbWCaysvZMczLHp9qHUZqeLN7WqkU8X8jMZ43u0Z4HHqJavPolegI6tN(uyihcWQ9KgzC7KOADDuiaMdatQA2uiRm8Phk0DgIO8ChgsWlElZz8BQPmEyi0iqvQZcHHO(0PpfgYfagcogTKQMnfsxHh5TWnaC4WameCmAjvnBkKUSv5TWna8rgIO8ChgIANZ1mP9wsxAYp9cZz8B6TmEyi0iqvQZcHHO(0PpfgYfaMu1SPq2C0v4rEaoCyaMu1SPq2YwLxpuO7a8raoCya(catQA2uiBo6k8ipaZbGHGJrBXLVa)Oinz0Sb0BqJRRWJ8w4ga(idruEUddP4YhZNyoJFt5nJhgIO8ChgsWlEldHgbQsDwimN5mNHCsFj3HX)TO)wtrp682Rfdjq(jhufgc62OzFN6aSPMcWIYZDa4Aw8IfCNHuAifJFtrFOWqA(nMvIHCDa81gS89uga(A(dNDW9RdGVdx5dG5fAa8TO)w0dUdUFDa81Rvguu5Ag4(1bWxtam6Eu73SV4eaF9e3KR97oMZbGB(C)0tQaWxYiaxi3ZbfaNfaw1skZu)OfC)6a4RjagDpQ9B2xCcG3gp3bG9fGlTz0b4l7dWZ6hbyikUpbWxVDoxZKfChC)6a4qZqNuWo1byikUpbWQ1asCagIqLtXcWx7ukQXla8SZ1uR8gr4kalkp3PaW7u5ZcUlkp3PyBEsTgqIFaxtmNt)PUU0KF6fWDr55ofBZtQ1as8d4AsZVbv0Yixi4y0Qexh33Wc3WP)Wz3QepGKtsdrYdUlkp3PyBEsTgqIFaxtGi51X9nqlJCpecogTYWNoUVHfUHZLd7pC2TkXdi5K0qK8HddbhJwL464(g2(gmh5C5W(dND7gudi5K0qK8HddbhJwJDhZ5OJ7By7BWCeCxuEUtX28KAnGe)aUM0sY76nQ9wshK1oAzKRlvACBljVR3O2BjDqw7wAeOk15CP)Wz3QepGKtsdrYZbcogTkX1X9nSWnHd3F4SB3GAajNKgIKNdeCmAn2DmNJoUVHfUjCyi4y0AS7yohDCFdlCdhxQ04wiPkJI0smMt68zPrGQu)i4UO8CNIT5j1Aaj(bCnj4fVfTmYfcogTg7oMZrh33Wc3WP)Wz3Ub1asojnejpNdv7jnY42jr166OqG7IYZDk2MNuRbK4hW1KIlFmFcTmYfcogTg7oMZrh33Wc3WP)Wz3Ub1asojnejph1EsJmUDsuTUoke4UO8CNIT5j1Aaj(bCnjwPsR6LOJwg5ww4kuoDBdCXHRKME4gp3XsJavPE4WLfUcLt3EUvXZkPlB9Kg3sJavPoA540)WnUonmOEkoX1u0YXP)HBCnQ6cjvUMIwoo9pCJRZi3YcxHYPBp3Q4zL0LTEsJdUdUFDaCOzOtkyN6amDspFaSNgea7TealkFFaolaSCkzvGQKfCxuEUtHBXmCTQHKsl4UO8CNYbCnbUq60jd0gXG4IUUo8GIY)1DQ45WxrRKAfTmY9qi4y028Bq1c3W5ceCmAHOVqVznejVfUjCyi4y0MJs(r8Chnky57Pm6nQH)YQS9nychwTN0iJBNevRRJcXrTBTVbJvTZ5AM0ElPln5NEX(KHKt5kUMEeCxuEUt5aUMaxiD6KrbTmY9qi4y028Bq1c3eo8HqWXOT53GQfUHdHoGZMgQBrxxhEqr5)6ov8C4ROvsTY5IA3AFdgle9f6nRHi5Tpzi5uUH3OpCy1U1(gm2CuYpIN7OrblFpLrVrn8xwL9jdjNYn8g9HdR2tAKXTtIQ11rH4O2T23GXQ25CntAVL0LM8tVyFYqYPCdVr)rWDr55oLd4AsZ65oOLrUxUCXLknUTLK31Bu7TKoiRDlncuL6CGGJrBljVR3O2BjDqw7w4MJCU0F4SBvIhqYjPHi5dhU)Wz3Ub1asojnej)rohcbhJ2MFdQw4MJHdF5ceCmAHOVqVznejVfUjCyi4y0MJs(r8Chnky57Pm6nQH)YQSWnh5C5W(dNDRs8asojnejpNd7pC2TBqnGKtsdrYF84rW9R76a4RN4bKCMdkawuEUdaxZIdWbzTcWqea)YaWzena2qguvYeV9LslalpbW7aWQoAa8lOiaolamev3aaouqpAaCOLEZaSmDaohL8J45oaS8ea33GbGLPdWxBWsvuEQayuWY3tzayi4yeGZcapRdWIYZtcnaEFaoJObWbuO6jaohawjECFdawMoatd9O4dGZcalq7jbW3Yl0ay0LhGZiahqaCRCsaS3sam6I4TaCLqrtxE(aycDaNnnuhna2BjaUtqWXiaxZXm1byFb40b4SaWZ6amCdalthGPHEu8bWzbGfO9Ka4BrpAOlpaNraoGcvpbWM57tzayz6aCOPrZgqpadTthGv7w7BWaWzbGHBayz6amnKrsfawEcGZjsFUpa7laFRfC)6UoawuEUt5aUM8WJwuEUJUMfhTrmiUkXdi5KqlJC7pC2TkXdi5K0qK8CUCrTBTVbJ1BFP0QHi5Tpzi5uUb9Cu7w7BWynKbvLSpzi5uUb9C6RBn2DI5t2NmKCk3WfLQFa6T8IZlOORcf0ZbcogT5OKFep3rJcw(EkJEJA4VSkBFdgoqWXOfI(c9M1qK82(gmCGGJrlkPkkpvAuWY3tzS9nyogo8fi4y0Qexh33Wc3WHg6rX3n3YRJHdFPVU9fZK9P4tLwbQsC6RB)SX(u8PsRavPJHdF5HhkUpkYUI3Q3O2Bjnv70R7pC2Te6aoBAOoNdHGJr7kEREJAVL0uTtVU)Wz3c3W5ceCmAvIRJ7ByHB4qd9O47MBr)roqWXOTLK31Bu7TKoiRD7tgsoLR4Ak6pgo8f1EsJmU1mFFkdh1U1(gmwYOzdOxdTt3(KHKt5kUMYruEEsAAiJKkxD7XWHVabhJ2wsExVrT3s6GS2TWnCOHEu8DZ1c9hpcUlkp3PCaxtE4rlkp3rxZIJ2igexL4bKCsOv8pvoxtrlJC7pC2TkXdi5K0qK8CGGJrRsCDCFdlCd4(1DDam6sqnGKZCqbWIYZDa4AwCaoiRvagIa4xgaoJObWgYGQsM4TVuAby5jaEhaw1rdGFbfbWzbGHO6gaWMYl0a4ql9Mbyz6aCok5hXZDay5jaUVbdalthGV2GLQO8ubWOGLVNYaWqWXiaNfaEwhGfLNNKfGrxEaoJObWbuO6jaoha2y3XCoaCCFdawMoaxGNy(eaNfa(P4tLwbQsObWOlpaNraoGa4w5KayVLay0fXBb4kHIMU88bWe6aoBAOoAaS3saCNGGJraUMJzQdW(cWPdWzbGN1by4gl6YdWzeGdOq1taSz((ugawMoahAA0Sb0dWq70by1U1(gmaCway4gawMoatdzKubGLNayiQUba8TObW7dWzeGdOq1tam)jQwhGJcbWY0b4R3oNRzcGvDaolamCJfC)6UoawuEUt5aUM8WJwuEUJUMfhTrmiUBqnGKtcTmYT)Wz3Ub1asojnejpNlxu7w7BWy92xkTAisE7tgsoLBqph1U1(gmwdzqvj7tgsoLBqpNxqrxDl65abhJ2CuYpIN7y7BWWbcogTq0xO3SgIK323G5y4WxGGJrRXUJ5C0X9nSWnC6RBlWtmFY(u8PsRavPJHdFbcogTg7oMZrh33Wc3WbcogTTK8UEJAVL0bzTBHBogo8fi4y0AS7yohDCFdlCdNlqWXOLu1SPq6k8iVfUjCyi4y0sQA2uiDzRYBHBoY5WhEO4(Oi7kEREJAVL0uTtVU)Wz3sOd4SPH6hdh(YdpuCFuKDfVvVrT3sAQ2Px3F4SBj0bC20qDohcbhJ2v8w9g1ElPPANED)HZUfU5y4Wxu7jnY42jr166OqCu7w7BWyv7CUMjT3s6st(PxSpzi5uUIRPhdh(IApPrg3AMVpLHJA3AFdglz0Sb0RH2PBFYqYPCfxt5ikppjnnKrsLRU94rWDr55oLd4AYdpAr55o6AwC0gXG4Ub1asoj0k(NkNRPOLrU9ho72nOgqYjPHi55abhJwJDhZ5OJ7ByHBa3VoagDhb4acGBLtcGV(5tjVaWvcfnD55dGj0bC20qDawMoadjvzuealXyoPZhalfawayxQ04aCabWLG0vTaCo(cWg7oMZbGJ7BaWbT0qN0dWElbWv(uYlameCmcWzbGfhG3hGHO6gaW3cWfsbUlkp3PCaxtE4rlkp3rxZIJ2ige3kFk5LfTmY9YLhEO4(OiBLpL8srhRe55GsJQMgnfYsOd4SPH6h5CXLknUfsQYOiTeJ5KoFwAeOk1pY5ceCmAR8PKxk6yLiphuAu10OPqw4MJCUabhJ2kFk5LIowjYZbLgvnnAkK9jdjNYvCV94rW9RdGr3raoGa4w5Ka4RF(uYlaCLqrtxE(aycDaNnnuhGLPdWr6LkalXyoPZhalfawayxQ04aCabWLG0vTaCo(cWr6Lkah33aGdAPHoPhG9wcGR8PKxayi4yeGZcaloaVpadr1naGVfGlKcCxuEUt5aUM8WJwuEUJUMfhTrmiUv(uYlk0Yi3lxE4HI7JISv(uYlfDSsKNdknQAA0uilHoGZMgQFKZfxQ042i9svlXyoPZNLgbQs9JCUabhJ2kFk5LIowjYZbLgvnnAkKfU5iNlqWXOTYNsEPOJvI8CqPrvtJMczFYqYPCf3BpEeC)6ay0DeGdOq1taSaWtIQ1JcbWY0b4acG77eQCaoqghG9fGvIhqYjzYgudi5KqdGLPdWbea3kNeadjvzuKjr6LkalXyoPZha7sLgN6ObWxFT0qN0dWQDoxZeaR6aCway4gaoGa4sq6QwaohFbyjgZjD(a44(gaSVaSskoaNoAaCl9eaBS7yohaoUVHfCxuEUt5aUM8WJwuEUJUMfhTrmiURANZ1mHwg5wi3ZbvXwAZORJ7Rv7CUMjoxU4sLg3cjvzuKwIXCsNplncuL6h5C5W(dNDRs8asojnej)roxoS)Wz3Ub1asojnej)roxu7jnY42jr166OqCu7w7BWyv7CUMjT3s6st(PxSpzi5uUIRPhpcUFDam6ocWbuO6jawa4jr16rHayz6aCabW9DcvoahiJdW(cWkXdi5KmzdQbKCsObWY0b4acGBLtcGHKQmkYKi9sfGLymN05dGDPsJtD0a4RVwAOt6by1oNRzcGvDaolamCdahqaCjiDvlaNJVaSeJ5KoFaCCFda2xawjfhGthnaULEcGvIh33aGJ7Byb3fLN7uoGRjp8OfLN7ORzXrBedIRsTZ5AMqlJClK75GQylTz01X91QDoxZeNlxCPsJBJ0lvTeJ5KoFwAeOk1pY5YH9ho7wL4bKCsAis(JCUCy)HZUDdQbKCsAis(JCUO2tAKXTtIQ11rH4O2T23GXQ25CntAVL0LM8tVyFYqYPCfxtpEeCxuEUt5aUMOKAvlkp3rxZIJ2igexJ0tuIN7aUlkp3PCaxtE4rlkp3rxZIJ2igexisEWDWDr55oflejpxisEDCFd0Yi3dHGJrlejVoUVHfUbCxuEUtXcrYFaxtE5KMfUOJpnHw(a3fLN7uSqK8hW1e1oNRzs7TKU0KF6f0Yi3d7pC2TkXdi5K0qK8CoS)Wz3Ub1asojnejp4UO8CNIfIK)aUMarFHEZAisE0Yi3lqWXO9LtAw4Io(0eA5Zc3eo8HQ9KgzC7jnElF)rWDr55oflej)bCnjhL8J45oOLrUxGGJr7lN0SWfD8Pj0YNfUjC4dv7jnY42tA8w((JG7IYZDkwis(d4Ace9f6nNdk0Yi3lqWXOfI(c9M1qK8w4MWHHGJrBok5hXZD0OGLVNYO3Og(lRYc3CeCxuEUtXcrYFaxtKU045jPlbYBGwg5E5W(6wPlnEEs6sG8g6UyiOiRNkZ5GIZHIYZDSsxA88K0La5n0DXqqr2C0XAIQ15C5W(6wPlnEEs6sG8g6wsQwpvMZbv4W91TsxA88K0La5n0TKuTpzi5uUH3hdhUVUv6sJNNKUeiVHUlgckYwCrz(kEZPVUv6sJNNKUeiVHUlgckY(KHKt5kEXPVUv6sJNNKUeiVHUlgckY6PYCoOocUlkp3PyHi5pGRjE7lLwnejpAU8OixNrUpfFQ0kqvkC4(6wV9LsRgIK3wCrz(kEho8L(6wV9LsRgIK3wCrz(QqHZdpuCFuKTchJsor4c11Kb0lkYsOd4SPH6hdhwuEEsAAiJKk3Wnua3fLN7uSqK8hW1eJDNy(eAzK7LlqWXOfLufLNknky57Pmw4MJCeLNNKMgYiPYv3EmC4lxGGJrlkPkkpvAuWY3tzSWnh5CyFDRXUtmFY6PYCoO4ikppjnnKrsLBmLJlpkYTEAqAF19KUX0BpcUlkp3PyHi5pGRjg7oX8j0Yi3l91Tg7oX8j7tgsoLR4YBoxGGJrlkPkkpvAuWY3tzSWnh5ikppjnnKrsLB4fhxEuKB90G0(Q7jDJP3EeCxuEUtXcrYFaxtmKbvLqlJCFbfz7umvPFJPONtHCphufRHmOQK2yFcCxuEUtXcrYFaxtm2DI5tOLrUxEk(uPvGQehr55jPPHmsQC1TCC5rrU1tds7RUN0nME7XWHVCyFDRXUtmFY6PYCoO4ikppjnnKrsLBmLJlpkYTEAqAF19KUX0BpcUlkp3PyHi5pGRjXkvAvVeD0Yi3YcxHYPBBGloCL00d345owAeOk15C5IA3AFdgR3(sPvdrYBFYqYPCd65O2T23GXAidQkzFYqYPCd6pY5sFDRXUtmFY(KHKt5gU8(iNlqWXOnhL8J45oAuWY3tz0Bud)Lvz7BWWbcogTq0xO3SgIK323GHdeCmArjvr5PsJcw(EkJTVbZXJHdxw4kuoD75wfpRKUS1tAClncuL6OLJt)d3460WG6P4extrlhN(hUX1OQlKu5AkA540)WnUoJCllCfkNU9CRINvsx26jnoNlQDR9nySE7lLwnejV9jdjNYnONJA3AFdgRHmOQK9jdjNYnO)i4UO8CNIfIK)aUMucYgcTmYfcogT5OKFep3rJcw(EkJEJA4VSkBFdgoqWXOfI(c9M1qK82(gmCeLNNKMgYiPYnCdfWDr55oflej)bCnXqGROLrUqWXOnhL8J45ow4goIYZtstdzKu5QBdhgcogTq0xO3SgIK3c3WruEEsAAiJKkxDl4UO8CNIfIK)aUMyiWv0Yi3lqWXOTiNcksRwdiXLXTfxuMVHRPh5CbcogT(UERwMUwvLalCZroqWXOnhL8J45ow4goIYZtstdzKuH7TG7IYZDkwis(d4AIHmOQeAzKleCmAZrj)iEUJfUHJO88K00qgjvUIlVb3fLN7uSqK8hW1edbUIwg5E5Yfi4y0676TAz6AvvcSfxuMVH7Thdh(ceCmA9D9wTmDTQkbw4goqWXO131B1Y01QQeyFYqYPCLPwEDmC4lqWXOTiNcksRwdiXLXTfxuMVHlVpEKJO88K00qgjvUI3hb3fLN7uSqK8hW1eV9LsRgIKhTmYvuEEsAAiJKk3yk4UO8CNIfIK)aUMyidQkHwg5E5YlOORUwO)ihr55jPPHmsQCfVpgo8LlVGIU6AWRJCeLNNKMgYiPYv8MJlvACBzHR6nQ9wsh3NkULgbQs9JG7IYZDkwis(d4AsdC9K(m0sOP4tvjTlpkYlCnfTmYTVU1BFP0QHi5TfxuMV5wWDr55oflej)bCnXBFP0QHi5b3fLN7uSqK8hW1edbUIwg5kkppjnnKrsLR4n4UO8CNIfIK)aUMucYgsdrYdUlkp3PyHi5pGRj5Vte(rlJCFbfz7umvPFvOGEoqWXOn)DIWV9jdjNYvO3YlWDWDr55ofRr6jkXZD4M)or4hTmYnh1AKdkDxmeuKMxLBYFNi8R7IHGI0E7tL2T25abhJ283jc)2NmKCkxX7qJwP4e4UO8CNI1i9eL45ohW1KNgkqQOLrUUmMZbfNwsQERTr5xHo5f4UO8CNI1i9eL45ohW1K4ttOnPU(ju0qV45oOLrUUmMZbfNwsQERTr5xHo5f4UO8CNI1i9eL45ohW1eYOzdOxdTthTmY9YH9ho7wL4bKCsAisEoh2F4SB3GAajNKgIK)y4WIYZtstdzKu5gU3cUlkp3PynsprjEUZbCnbsEZfZ5Gwg56YyohuCAjP6T2gLFvOMxCYrTg5Gs3fdbfP5v5g0Bnn0OLKQ3AnKqhCxuEUtXAKEIs8CNd4Asb(pZtPQZP45O8cAzKleCmAlW)zEkvDofphLxS9ny4abhJwi5nxmNJTVbdNwsQERTr5xHorpNCuRroO0DXqqrAEvUb92B5vOrljvV1AiHo4o4UO8CNIvTBTVbtHBZ65oG7IYZDkw1U1(gmLd4AcuD3Uoc)8bUlkp3Pyv7w7BWuoGRjq0xO3CoOa3fLN7uSQDR9nykhW1e5vYqAF)NghCxuEUtXQ2T23GPCaxtQjQwVOrxH7OmOXb3fLN7uSQDR9nykhW1Ky(euD3o4UO8CNIvTBTVbt5aUMiJIk(lvTsQvWDr55ofRA3AFdMYbCnb6ZIxZbLoc)OLrUqWXOfIKxh33Wc3aUlkp3Pyv7w7BWuoGRj5OKFep3bTmY9sFDRXUtmFY6PYCoOchwuEEsAAiJKk3y6ro91TE7lLwnejV1tL5CqbUlkp3Pyv7w7BWuoGRjq0xO3m4UO8CNIvTBTVbt5aUMaxiD6KbAumskxpIbXvXNQU(VtQ0qvP4G7IYZDkw1U1(gmLd4AcCH0PtgfWDWDr55ofRs8asojUn)gub3fLN7uSkXdi5KoGRjkX1X9nqlJCpecogTkX1X9nSWnG7IYZDkwL4bKCshW1KxmtOLrUqWXOT53GQfUbCxuEUtXQepGKt6aUM0sY76nQ9wshK1oAzKRlvACBljVR3O2BjDqw7wAeOk15CieCmABj5D9g1ElPdYA3c3aUlkp3PyvIhqYjDaxtiJMnGEn0oD0Yi3(dNDRs8asojnejp4UO8CNIvjEajN0bCn5fZeAzKBFD7lMj7tXNkTcuL4OwdOv3S54LRcfWDr55ofRs8asoPd4AYNnOLrU91TF2yFk(uPvGQeh1AaT6MnhVCd3qbCxuEUtXQepGKt6aUMO25CntAVL0LM8tVGwg52F4SBvIhqYjPHi5b3fLN7uSkXdi5KoGRjr6xvUWfnu6eAgsORPHEu8X1u0Yix1AaT6MnhVCd3qbCxuEUtXQepGKt6aUMiDPXZtsxcK3aTmY9YH91TsxA88K0La5n0DXqqrwpvMZbfNdfLN7yLU045jPlbYBO7IHGIS5OJ1evRZ5YH91TsxA88K0La5n0TKuTEQmNdQWH7RBLU045jPlbYBOBjPAFYqYPCdVpgoCFDR0LgppjDjqEdDxmeuKT4IY8v8MtFDR0LgppjDjqEdDxmeuK9jdjNYv8ItFDR0LgppjDjqEdDxmeuK1tL5CqDeCxuEUtXQepGKt6aUMeRuPv9s0rlJCllCfkNUTbU4WvstpCJN7yPrGQuNdn0JIVR4nVchUSWvOC62ZTkEwjDzRN04wAeOk1rlhN(hUX1PHb1tXjUMIwoo9pCJRrvxiPY1u0YXP)HBCDg5ww4kuoD75wfpRKUS1tACo0qpk(UI38cCxuEUtXQepGKt6aUMuAFQJwg5QwdOv3S54fRc(FA8R4f4o4UO8CNIvP25CntCvIRJ7BaUlkp3PyvQDoxZ0bCnPLK31Bu7TKoiRD0YixxQ042wsExVrT3s6GS2T0iqvQZ5qi4y02sY76nQ9wshK1UfUbCxuEUtXQu7CUMPd4AIANZ1mP9wsxAYp9cAzKBzHRq50TX8lUU4FAMS0iqvQZbcogTX8lUU4FAMSWnG7IYZDkwLANZ1mDaxtu7CUMjT3s6st(PxqlJCDPsJBBj5D9g1ElPdYA3sJavPohi4y02sY76nQ9wshK1UfUbCxuEUtXQu7CUMPd4AIANZ1mP9wsxAYp9cAzKRlvACBljVR3O2BjDqw7wAeOk15O2T23GX2sY76nQ9wshK1U9jdjNYnMYlWDr55ofRsTZ5AMoGRjQDoxZK2BjDPj)0lOLrUh6sLg32sY76nQ9wshK1ULgbQsDWDWDr55ofBLpL8IIRsCDCFdWDWDr55ofBLpL8YY1y3XCo64(gG7G7IYZDk2vTZ5AM4AS7yohDCFdWDr55of7Q25CnthW1KwsExVrT3s6GS2rlJCDPsJBBj5D9g1ElPdYA3sJavPoNdHGJrBljVR3O2BjDqw7w4gWDr55of7Q25CnthW1e1oNRzs7TKU0KF6f0Yi3YcxHYPBJ5xCDX)0mzPrGQuNdeCmAJ5xCDX)0mzHBa3fLN7uSRANZ1mDaxtkU8X8j0YixsvZMczLHp9qHUhomPQztHSLTkVEOq3b3fLN7uSRANZ1mDaxtcEXBrlJCjvnBkKvg(0df6E4WKQMnfYwHh51df6o4UO8CNIDv7CUMPd4AIANZ1mP9wsxAYp9cAzKRlvACBljVR3O2BjDqw7wAeOk15abhJ2wsExVrT3s6GS2TWnG7IYZDk2vTZ5AMoGRjQDoxZK2BjDPj)0lOLrUUuPXTTK8UEJAVL0bzTBPrGQuNJA3AFdgBljVR3O2BjDqw72NmKCk3ykVa3fLN7uSRANZ1mDaxtu7CUMjT3s6st(PxqlJCp0LknUTLK31Bu7TKoiRDlncuL6G7G7IYZDk2nOgqYjX1y3XCo64(gOLrUhcbhJwJDhZ5OJ7ByHBa3fLN7uSBqnGKt6aUM0sY76nQ9wshK1oAzKRlvACBljVR3O2BjDqw7wAeOk15CieCmABj5D9g1ElPdYA3c3aUlkp3Py3GAajN0bCnP4YxGFue4UO8CNIDdQbKCshW1e1oNRzs7TKU0KF6f0Yi3YcxHYPBJ5xCDX)0mzPrGQuhCxuEUtXUb1asoPd4Acz0Sb0RH2PJwg52F4SB3GAajNKgIKhCxuEUtXUb1asoPd4AI0LgppjDjqEd0Yi3lh2x3kDPXZtsxcK3q3fdbfz9uzohuCouuEUJv6sJNNKUeiVHUlgckYMJowtuToNlh2x3kDPXZtsxcK3q3ss16PYCoOchUVUv6sJNNKUeiVHULKQ9jdjNYn8(y4W91TsxA88K0La5n0DXqqr2IlkZxXBo91TsxA88K0La5n0DXqqr2NmKCkxXlo91TsxA88K0La5n0DXqqrwpvMZb1rWDr55of7gudi5KoGRjf4jMpHMIpvL0U8OiVW1u0Yi3NIpvAfOkbUlkp3Py3GAajN0bCnXy3jMpHMIpvL0U8OiVW1u0Yi3NIpvAfOkfomeCmArjvr5PsJcw(EkJfUbCxuEUtXUb1asoPd4AsXLpMpHwg5Q2tAKXTtIQ11rH4qQA2uiRm8Phk0DWDr55of7gudi5KoGRjbV4TOLrUhQ2tAKXTtIQ11rH4qQA2uiRm8Phk0DWDr55of7gudi5KoGRjQDoxZK2BjDPj)0lOLrUxGGJrlPQztH0v4rElCt4WqWXOLu1SPq6YwL3c3CeCxuEUtXUb1asoPd4AsXLpMpHwg5EHu1SPq2C0v4r(WHjvnBkKTSv51df6(XWHVqQA2uiBo6k8iphi4y0wC5lWpkstgnBa9g046k8iVfU5i4UO8CNIDdQbKCshW1KGx8wMZCgda]] )


end