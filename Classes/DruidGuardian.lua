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

    spec:RegisterPack( "Guardian", 20210916, [[dCKG8bqiQQ8iucAtG0NOQQyuGWPusTkQQQ4vuvAwGQUfkbyxK8lkLggkvogk0Yav8mQQY0avQRHs02avsFdLQ04OQQ05qPQADOeqMhiY9qr7de1brjqzHuv8qucXerjG6IuvvPpIsGCsuQkReL0mrjK6MOeOANOu(jkHQNcvtLsXxrjKSxu9xkgmKdtSyL6XKAYs5YiBMkFgugTu50IwnkHYRPunBjUnvz3k(nWWLQookvXYv55sA6cxhkBxj(oLmEqL48OG1tvvvZxjz)QAoJCB44njioBWHDWHr2X(zeUQyK9Ys)lCZsoEWqpXX7fTDbgXXhXJ44SGWKRLYWX7fgkaPXTHJxbyNM44Dr0xzbYwBHLrh2wPbE2wtpSIejy0N4cBRPN2wo(gllb7B4BoEtcIZgCyhCyKDSFgHRkgzVS0)c3(JJlyrh4444PhlchVlBnA4BoEJQAoolim5APmpIf4dlBpR4uFqEB6EeJWv4FeCyhCy8z9zLfPtgyuLfONvwapI9nAW1dojOhXIiHTSGdaJ9CEu)LGlJKQpcI09OkfroWEuwFKUJ02P2A1ZklGhX(gn46bNe0Ja9rcMhfGhv7sx8iia3JgqS(rBYbo6rSiGzbyNuC8swJk3goEHbTCcGBdNng52WXfDKGHJ7baJ9CmoW5XXPr2fQX9Hh8GJVj542WzJrUnCCAKDHACF446ld6sHJ73J2yoNAtYzCGZtH1ZXfDKGHJVj5moW5XdoBWHBdhNgzxOg3hoU(YGUu44HuOjuDKCHb4mrhzSYstrJSlu7rqFeepkKcnHAlfz0KrCUCYGbfnYUqThT(rqFKgSqJmHAHMOJHJJl6ibdhVJKlmaNj6iJvwA8GZM)42WXPr2fQX9HJl6ibdh3dagxEehxFzqxkCCiEeepYVhfP2EoWEe0hfPhzcGPL0JG8Jyeopc6J2yoNcMueDKAdmm5APmkS(hT(rRw9iiE0rUJQDYUqpc6JI0JmbW0s6rq(rmcNhb9rBmNtbtkIosTbgMCTugfw)Jw)O1CCnd6czc5GrrLZgJ8GZgCZTHJtJSluJ7dhx0rcgoUhamU8ioU(YGUu44q8iiEKFpksT9CG9iOpkspYeatlPhb5hXiCE06hTA1JG4rh5oQ2j7c9iOpkspYeatlPhb5hXiCE06hTMJRzqxitihmkQC2yKhC2yj3goUOJemC8twObGvnUJg)pdCCAKDHACF4bNn4k3goonYUqnUpCCrhjy44SyGaBGr5DMgvJCyOA0sPWX1xg0LchxdwOrMqTqt0XWXXhXJ44SyGaBGr5DMgvJCyOA0sPWdoBSxUnCCAKDHACF44IosWWXJlh7uWihxFzqxkCC)E0gZ5u9hWQOW6Fe0hPbl0itOwOj6y4441ci44XLJDkyKhC28VCB440i7c14(WXfDKGHJhxo2PaoCC9LbDPWX97rBmNt1FaRIcR)rqFKgSqJmHAHMOJHJJxlGGJhxo2Pao8GZg7NBdhNgzxOg3hoU(YGUu44AWcnYeQfAIogUhb9rBmNtLJwUrIemQJ8KCQpcYmFeCG7hb9rBmNtLJwUrIemQJ8KCQpcsmFeCyjhx0rcgoEpisWWdoBmYoUnCCAKDHACF446ld6sHJ73JAhw2uAjSizHmBsUhb9r(9O2HLnfWQyrYcz2KCCCrhjy44AWSaStMOJm1(8YOYdoBmYi3goonYUqnUpCC9LbDPWXH4rBmNtDYcnaSQXD04)zqH1)OvREKFpsdwOrMqTqt0XW9O1CCrhjy44B6Q0zNhC2yeoCB440i7c14(WX1xg0LchhIhTXCo1jl0aWQg3rJ)Nbfw)JwT6r(9inyHgzc1cnrhd3JwZXfDKGHJNJwUrIem8GZgJ(JBdhNgzxOg3hoU(YGUu44q8OnMZP20vPZUztYPW6F0QvpAJ5CQC0YnsKGXadtUwkJb4myxfOvy9pAnhx0rcgo(MUkD2Zbgp4SXiCZTHJtJSluJ7dhxFzqxkCCiEKFpQbcL0K(ixit1soptt8eyKksT9CG9iOpYVhj6ibJsAsFKlKPAjNNPjEcmsLJXvsyDXJG(iiEKFpQbcL0K(ixit1sopthjfvKA75a7rRw9Ogiust6JCHmvl58mDKuuh5j5uFeKFK)E06hTA1JAGqjnPpYfYuTKZZ0epbgPQHOT)ii9i)9iOpQbcL0K(ixit1soptt8eyK6ipjN6JG0Jy5JG(Ogiust6JCHmvl58mnXtGrQi12Zb2JwZXfDKGHJlnPpYfYuTKZJhC2yKLCB440i7c14(WX1xg0LchFJ5Ckysr0rQnWWKRLYOW6Fe0hj6ixidnKxs1hbPh5poUOJemCCpayC5r8GZgJWvUnCCAKDHACF44IosWWXJUtQDMnjhhxFzqxkC8JChv7KDHE0QvpQbcv0DsTZSj5u1q02FeKEK)E0QvpcIh1aHk6oP2z2KCQAiA7pcspcUFe0hDyd5ahmsvWCojhhwLAgYBFIMue7bl77P2Jw)OvREKOJCHm0qEjvFeKz(i4(rRw9OnMZP20vPZUztYPW6Fe0hTXCo1MUkD2nBso1rEso1hbjMpcMU9iFFe7uSKJRzqxitihmkQC2yKhC2yK9YTHJtJSluJ7dhxFzqxkC8tGrQg5sDgpcYpIr29iOpQsrKdSQYtgyfY4boIJl6ibdh3tgyfIhC2y0)YTHJtJSluJ7dhxFzqxkC8kaRSZPP6XQbwHm0H1hjyu0i7c1Ee0hbXJG4rAaO0awJk6oP2z2KCQJ8KCQpcYpIDpc6J0aqPbSgLNmWkK6ipjN6JG8Jy3Jw)iOpcIh1aHYdagxEK6ipjN6JGmZh5VhT(rqFeepAJ5CQC0YnsKGXadtUwkJb4myxfOvnG18iOpAJ5CQnDv6SB2KCQgWAEe0hTXCofmPi6i1gyyY1szunG18O1pA9JwT6rvawzNttTaksKfYubLfAcfnYUqnoEobDhwFyshhVcWk7CAQfqrISqMkOSqtafcnauAaRrfDNu7mBso1rEsoviZoOAaO0awJYtgyfsDKNKtfYSBnhpNGUdRpmPNh1sjiooJCCrhjy44Ucv70N4coEobDhwFyGvaBPWXzKhC2yK9ZTHJtJSluJ7dhxFzqxkC8nMZPYrl3ircgdmm5APmgGZGDvGw1awZJG(OnMZP20vPZUztYPAaR5rqFKOJCHm0qEjvFeKz(i4MJl6ibdhVAL9KztYXdoBWHDCB440i7c14(WX1xg0LchFJ5CQC0YnsKGrH1)iOps0rUqgAiVKQpcspYFpc6JG4rBmNtfaq0zKPz0fXsvdrB)rqM5JGZJw)OvREeepAJ5CQaaIoJmnJUiwkS(hb9rBmNtfaq0zKPz0fXsDKNKt9rq6rmQy5Jw)OvREeepAJ5CQQSiWiJg4TLqMqvdrB)rqM5J83Jw)OvRE0gZ5uB6Q0z3Sj5uy9pc6JeDKlKHgYlP6JG0J8hhx0rcgoUNGv4bNn4Wi3goonYUqnUpCC9LbDPWXH4rBmNtvLfbgz0aVTeYeQAiA7pcYmFeJpA9JG(iiE0gZ5ubaeDgzAgDrSuy9pA9JG(OnMZPYrl3ircgfw)JG(irh5czOH8sQ(iMpcoCCrhjy44EcwHhC2GdC42WXPr2fQX9HJRVmOlfo(gZ5u5OLBKibJcR)rqFKOJCHm0qEjvFeKy(i)XXfDKGHJ7jdScXdoBWXFCB440i7c14(WX1xg0LchhIhbXJG4rBmNtfaq0zKPz0fXsvdrB)rqM5JGZJw)OvREeepAJ5CQaaIoJmnJUiwkS(hb9rBmNtfaq0zKPz0fXsDKNKt9rq6rmQy5Jw)OvREeepAJ5CQQSiWiJg4TLqMqvdrB)rqM5J83Jw)O1pc6JeDKlKHgYlP6JG0J83JwZXfDKGHJ7jyfEWzdoWn3goonYUqnUpCC9LbDPWXfDKlKHgYlP6JG8JyKJl6ibdhp6oP2z2KC8GZgCyj3goonYUqnUpCC9LbDPWXH4rq8OtGrpcspI9ZUhT(rqFKOJCHm0qEjvFeKEK)E06hTA1JG4rq8OtGrpcspY)YYhT(rqFKOJCHm0qEjvFeKEK)Ee0hfsHMqvbyfdWzIoY4ahvdfnYUqThTMJl6ibdh3tgyfIhC2GdCLBdhNgzxOg3hoUOJemC8ESYcDP)N446ld6sHJ3aHk6oP2z2KCQAiA7pcYpcoCCnd6czc5GrrLZgJ8GZgCyVCB44IosWWXJUtQDMnjhhNgzxOg3hEWzdo(xUnCCAKDHACF446ld6sHJl6ixidnKxs1hbPh5poUOJemCCpbRWdoBWH9ZTHJl6ibdhVAL9KztYXXPr2fQX9HhC28h742WXPr2fQX9HJRVmOlfo(jWivJCPoJhbPhb3S7rqF0gZ5u5bgh2PoYtYP(ii9i2Pyjhx0rcgoEEGXHD8GhCCVmsysKGHBdNng52WXPr2fQX9HJRVmOlfoEoAGxoWmnXtGrgwwFeKFuEGXHDMM4jWit0DuTduApc6J2yoNkpW4Wo1rEso1hbPh5Vh5)8OoPgehx0rcgoEEGXHD8GZgC42WXPr2fQX9HJRVmOlfoEiJ9CG9iOpQJKs0P61XJG0JGRSKJl6ibdh)OHSKcp4S5pUnCCAKDHACF446ld6sHJhYyphypc6J6iPeDQED8ii9i4kl54IosWWXDhn()KAMJGrdDsKGHhC2GBUnCCAKDHACF446ld6sHJdXJ87rTdlBkTewKSqMnj3JG(i)Eu7WYMcyvSizHmBsUhT(rRw9irh5czOH8sQ(iiZ8rWHJl6ibdhN86bw0z2GPXdoBSKBdhNgzxOg3hoU(YGUu44Hm2Zb2JG(OoskrNQxhpcspI9YYhb9r5ObE5aZ0epbgzyz9rq(rStX4J8FEuhjLOt5jWfoUOJemC8TC2R2ZHhC2GRCB440i7c14(WX1xg0LchFJ5CQk2TKlsXKtnYrhvvdynpc6J2yoNAlN9Q9CunG18iOpQJKs0P61XJG0JGRS7rqFuoAGxoWmnXtGrgwwFeKFe7uWHLpY)5rDKuIoLNax44IosWWXRy3sUifto1ihDu5bp449hPbEBj42WzJrUnCCAKDHACF44nQQVSpsWWX9FHlKglO2J2KdC0J0aVTepAtWYPQEelyAn1h1hnGHfqNCEoSYJeDKGP(iWuyqXXfDKGHJBpN2rntTpVmQ8GZgC42WXPr2fQX9HJRVmOlfoEifAcvhjxyaot0rgRS0u0i7c1Ee0hbXJAhw2uAjSizHmBsUhb9rBmNtPLW4aNNcR)rRw9O2HLnfWQyrYcz2KCpc6J2yoNYdag75yCGZtH1)OvRE0gZ5uEaWyphJdCEkS(hb9rHuOjuBPiJMmIZLtgmOOr2fQ9O1CCrhjy44DKCHb4mrhzSYsJhC28h3goonYUqnUpCC9LbDPWX3yoNslHXbopfw)JG(O2HLnLwclswiZMKJJl6ibdhV)awfEWzdU52WXPr2fQX9HJRVmOlfoUFpAJ5CkzyW4aNNcR)rqFeepcIh53JAhw2uaRIfjlKztY9iOpYVh1oSSP0syrYcz2KCpA9JG(iiEKFpsdwOrMqnjSUW4e6rRF06hTA1JG4rq8i)Eu7WYMcyvSizHmBsUhb9r(9O2HLnLwclswiZMK7rRFe0hbXJ0GfAKjutcRlmoHEe0hfsHMqDunaNejymIZLtgmOOr2fQ9O1pAnhx0rcgo(MKZ4aNhp4SXsUnCCAKDHACF446ld6sHJVXCoLham2ZX4aNNcR)rqFu7WYMcyvSizHmBsUhb9r(9inyHgzc1KW6cJtioUOJemCCRtIoEWzdUYTHJtJSluJ7dhxFzqxkC8nMZP8aGXEogh48uy9pc6JAhw2uaRIfjlKztY9iOpsdwOrMqnjSUW4eIJl6ibdhVgY5YJ4bNn2l3goonYUqnUpCC9LbDPWXRaSYoNMQhRgyfYqhwFKGrrJSlu7rRw9OkaRSZPPwafjYczQGYcnHIgzxOghpNGUdRpmPJJxbyLDon1cOirwitfuwOj445e0Dy9Hj98OwkbXXzKJl6ibdh3vOAN(exWXZjO7W6ddScylfooJ8GhC8cdA5en3goBmYTHJl6ibdhxlHXbopoonYUqnUp8GhC8g5eSsWTHZgJCB440i7c14(WXBuvFzFKGHJ7)cxinwqThrl0XWJI0JEu0rps0b4EuwFKSizr2fsXXfDKGHJxTJvkMTu74bNn4WTHJtJSluJ7dhx0rcgoolgiWgyuENPr1ihgQgTukCC9LbDPWX97rBmNt1FaRIcR)rqFKFpsdwOrMqTqt0XWXXhXJ44SyGaBGr5DMgvJCyOA0sPWdoB(JBdhNgzxOg3hoUOJemC84YXofmYX1xg0Lch3VhTXCov)bSkkS(hb9r(9inyHgzc1cnrhdhhVwabhpUCStbJ8GZgCZTHJtJSluJ7dhx0rcgoEC5yNc4WX1xg0Lch3VhTXCov)bSkkS(hb9r(9inyHgzc1cnrhdhhVwabhpUCStbC4bNnwYTHJtJSluJ7dhxFzqxkCC)EKgSqJmHAHMOJH7rqFeepcIhbXJcPqtO6i5cdWzIoYyLLMIgzxO2JG(OnMZP6i5cdWzIoYyLLMcR)rRFe0hbXJAhw2uAjSizHmBsUhTA1JAhw2uaRIfjlKztY9O1pc6J87rBmNt1FaRIcR)rRF0QvpcIhbXJ2yoNAtxLo7MnjNcR)rRw9OnMZPYrl3ircgdmm5APmgGZGDvGwH1)O1pc6JG4r(9O2HLnLwclswiZMK7rqFKFpQDyztbSkwKSqMnj3Jw)O1pAnhx0rcgoEpisWWdoBWvUnCCAKDHACF446ld6sHJ3oSSP0syrYcz2KCpc6J87rAWcnYeQfAIogUhb9rBmNtLJwUrIemgyyY1szmaNb7QaTQbSMhb9rBmNtTPRsNDZMKt1awZJG(iiEeepsdaLgWAur3j1oZMKtDKNKt9rq(rS7rqFKgaknG1O8KbwHuh5j5uFeKFe7Ee0h1aHYdagxEK6ipjN6JGmZhbt3EKVpIDkw(iOp6ey0JG0JGB29iOpAJ5CQC0YnsKGXadtUwkJb4myxfOvnG18iOpAJ5CQnDv6SB2KCQgWAEe0hTXCofmPi6i1gyyY1szunG18O1pA1QhbXJ2yoNslHXbopfw)JG(iAOdgdpcYpcoS8rRF0QvpcIh1aH6e7K6i3r1ozxOhb9rnqOUSxDK7OANSl0Jw)OvREeep6WgYboyKcirNb4mrhzOsJot7WYMIypyzFp1Ee0h53J2yoNcirNb4mrhzOsJot7WYMcR)rqFeepAJ5CkTegh48uy9pc6JOHoym8ii)i4WUhT(rqF0gZ5uDKCHb4mrhzSYstDKNKt9rqI5JyKDpA9JwT6rq8inyHgzcLDgUuMhb9rAaO0awJI86bw0z2GPPoYtYP(iiX8rm(iOps0rUqgAiVKQpcspcopA9JwT6rq8OnMZP6i5cdWzIoYyLLMcR)rqFen0bJHhb5hX(z3Jw)O1C8ACPo4SXihx0rcgo(HngrhjymLSgC8swdZiEehxlHfjlep4SXE52WXPr2fQX9HJRVmOlfoE7WYMslHfjlKztY9iOpsdwOrMqTqt0XW9iOpcIhbXJ0aqPbSgv0DsTZSj5uh5j5uFeKFe7Ee0hPbGsdynkpzGvi1rEso1hb5hXUhb9rnqO8aGXLhPoYtYP(iiZ8rW0Th57JyNILpc6Jobg9ii9i4MDpc6J2yoNkhTCJejymWWKRLYyaod2vbAvdynpc6J2yoNAtxLo7MnjNQbSMhb9rBmNtbtkIosTbgMCTugvdynpc6Jobg9ii9i4MDpc6J2yoNkhTCJejymWWKRLYyaod2vbAvdynpc6J2yoNAtxLo7MnjNQbSMhb9rBmNtbtkIosTbgMCTugvdynpA9JwT6rq8OnMZP0syCGZtH1)iOpIg6GXWJG8JGdlF06hTA1JG4rnqOoXoPoYDuTt2f6rqFudeQl7vh5oQ2j7c9iOp6ey0JG0JGB29iOpAJ5CQC0YnsKGXadtUwkJb4myxfOvnG18iOpAJ5CQnDv6SB2KCQgWAEe0hTXCofmPi6i1gyyY1szunG18O1pAnhVgxQdoBmYXfDKGHJFyJr0rcgtjRbhVK1WmIhXX1syrYcXdoB(xUnCCAKDHACF446ld6sHJ73JAhw2uAjSizHmBsUhb9rBmNtPLW4aNNcRNJxJl1bNng54IosWWXpSXi6ibJPK1GJxYAygXJ44AjSizH4bNn2p3goonYUqnUpCC9LbDPWXBhw2uaRIfjlKztY9iOpcIhbXJ0aqPbSgv0DsTZSj5uh5j5uFeKFe7Ee0hPbGsdynkpzGvi1rEso1hb5hXUhb9rNaJEeKEeJS8rqF0gZ5u5OLBKibJQbSMhb9rBmNtTPRsNDZMKt1awZJG(OnMZPGjfrhP2adtUwkJQbSMhT(rRw9iiE0gZ5uEaWyphJdCEkS(hb9rnqOQyJlpsDK7OANSl0Jw)OvREeepAJ5CkpaySNJXbopfw)JG(OnMZP6i5cdWzIoYyLLMcR)rRF0QvpcIhDyd5ahmsbKOZaCMOJmuPrNPDyztrShSSVNApc6J87rBmNtbKOZaCMOJmuPrNPDyztH1)O1pA1QhbXJ0GfAKjutcRlmoHEe0hPbGsdynknywa2jt0rMAFEzuvh5j5uFeKy(igF06hTA1JG4rAWcnYek7mCPmpc6J0aqPbSgf51dSOZSbttDKNKt9rqI5Jy8rqFKOJCHm0qEjvFeKEeCE06hTMJxJl1bNng54IosWWXpSXi6ibJPK1GJxYAygXJ44aRIfjlep4SXi742WXPr2fQX9HJRVmOlfoUFpQDyztbSkwKSqMnj3JG(OnMZP8aGXEogh48uy9C8ACPo4SXihx0rcgo(HngrhjymLSgC8swdZiEehhyvSizH4bNngzKBdhNgzxOg3hoU(YGUu44TdlBkGvXIKfYSj5Ee0hTXCoLham2ZX4aNNcRNJxJl1bNng54IosWWXpSXi6ibJPK1GJxYAygXJ44aRIfjlep4SXiC42WXPr2fQX9HJ3OQ(Y(ibdhN95EKf9OozHEelAg0YjpQqWOPjhdpIypyzFp1EKmThTLImA6rIZLtgm8iP(i5rHuOjEKf9OQvg6UhLtaEKham2Z5roW59iRoAOf6Eu0rpQWGwo5rBmN7rz9rs8iW9OnvawpcopQsAoUOJemC8dBmIosWykzn446ld6sHJdXJG4rh2qoWbJufg0YjvJRquKdmdSs61xjfXEWY(EQ9O1pc6JG4rHuOjuBPiJMmIZLtgmOOr2fQ9O1pc6JG4rBmNtvyqlNunUcrroWmWkPxFLuy9pA9JG(iiE0gZ5ufg0YjvJRquKdmdSs61xj1rEso1hbjMpcopA9JwZXlznmJ4rC8cdA5eap4SXO)42WXPr2fQX9HJ3OQ(Y(ibdhN95EKf9OozHEelAg0YjpQqWOPjhdpIypyzFp1EKmTh5OtkpsCUCYGHhj1hjpkKcnXJSOhvTYq39OCcWJC0jLh5aN3JS6OHwO7rrh9OcdA5KhTXCUhL1hjXJa3J2uby9i48OkP54IosWWXpSXi6ibJPK1GJRVmOlfooepcIhDyd5ahmsvyqlNunUcrroWmWkPxFLue7bl77P2Jw)iOpcIhfsHMq5OtkgX5Yjdgu0i7c1E06hb9rq8OnMZPkmOLtQgxHOihygyL0RVskS(hT(rqFeepAJ5CQcdA5KQXvikYbMbwj96RK6ipjN6JGeZhbNhT(rR54LSgMr8ioEHbTCIMhC2yeU52WXPr2fQX9HJ3OQ(Y(ibdhN95EKf5Fo6rYJMewx4e6rY0EKf9Ogy8pXJSKjEuaEKwclswiBbwflswi4FKmThzrpQtwOhTLImAYwhDs5rIZLtgm8Oqk0eud(hXIQJgAHUhPbZcWo9iD7rz9ry9pYIEu1kdD3JYjapsCUCYGHh5aN3JcWJ0snEugW)Oo6Oh5baJ9CEKdCEkoUOJemC8dBmIosWykzn446ld6sHJxPiYbwvv7sxyCGZObZcWo9iOpcIhbXJcPqtO2srgnzeNlNmyqrJSlu7rRFe0hbXJ87rTdlBkTewKSqMnj3Jw)iOpcIh53JAhw2uaRIfjlKztY9O1pc6JG4rAWcnYeQjH1fgNqpc6J0aqPbSgLgmla7Kj6itTpVmQQJ8KCQpcsmFeJpA9JwZXlznmJ4rCCGgmla7ep4SXil52WXPr2fQX9HJ3OQ(Y(ibdhN95EKf5Fo6rYJMewx4e6rY0EKf9Ogy8pXJSKjEuaEKwclswiBbwflswi4FKmThzrpQtwOhTLImAYwhDs5rIZLtgm8Oqk0eud(hXIQJgAHUhPbZcWo9iD7rz9ry9pYIEu1kdD3JYjapsCUCYGHh5aN3JcWJ0snEugW)Oo6OhPLWboVh5aNNIJl6ibdh)WgJOJemMswdoU(YGUu44vkICGvv1U0fgh4mAWSaStpc6JG4rq8Oqk0ekhDsXioxozWGIgzxO2Jw)iOpcIh53JAhw2uAjSizHmBsUhT(rqFeepYVh1oSSPawflswiZMK7rRFe0hbXJ0GfAKjutcRlmoHEe0hPbGsdynknywa2jt0rMAFEzuvh5j5uFeKy(igF06hTMJxYAygXJ44Anywa2jEWzJr4k3goonYUqnUpCCrhjy44APumIosWykzn44LSgMr8ioUxgjmjsWWdoBmYE52WXPr2fQX9HJl6ibdh)WgJOJemMswdoEjRHzepIJVj54bp44AjSizH42WzJrUnCCrhjy449hWQWXPr2fQX9HhC2Gd3goonYUqnUpCC9LbDPWX97rBmNtPLW4aNNcRNJl6ibdhxlHXbopEWzZFCB440i7c14(WX1xg0LchFJ5CQ(dyvuy9CCrhjy44NyN4bNn4MBdhNgzxOg3hoU(YGUu44HuOjuDKCHb4mrhzSYstrJSlu7rqFKFpAJ5CQosUWaCMOJmwzPPW654IosWWX7i5cdWzIoYyLLgp4SXsUnCCAKDHACF446ld6sHJ3oSSP0syrYcz2KCCCrhjy44KxpWIoZgmnEWzdUYTHJtJSluJ7dhxFzqxkC8giuNyNuh5oQ2j7c9OvREen0bJHhbPhb3SKJl6ibdh)e7ep4SXE52WXPr2fQX9HJRVmOlfoEdeQl7vh5oQ2j7c9iOpsd82atpiNO(iiZ8rWnhx0rcgo(L98GZM)LBdhNgzxOg3hoU(YGUu44TdlBkTewKSqMnjhhx0rcgoUgmla7Kj6itTpVmQ8GZg7NBdhNgzxOg3hoU(YGUu44AG3gy6b5e1hbzMpcU54IosWWXD0b0jaRA2zqCCpbUyOHoymWzJrEWzJr2XTHJtJSluJ7dhxFzqxkCCiEKFpQbcL0K(ixit1soptt8eyKksT9CG9iOpYVhj6ibJsAsFKlKPAjNNPjEcmsLJXvsyDXJG(iiEKFpQbcL0K(ixit1sopthjfvKA75a7rRw9Ogiust6JCHmvl58mDKuuh5j5uFeKFK)E06hTA1JAGqjnPpYfYuTKZZ0epbgPQHOT)ii9i)9iOpQbcL0K(ixit1soptt8eyK6ipjN6JG0Jy5JG(Ogiust6JCHmvl58mnXtGrQi12Zb2JwZXfDKGHJlnPpYfYuTKZJhC2yKrUnCCAKDHACF446ld6sHJxbyLDonvpwnWkKHoS(ibJIgzxO2JG(iAOdgdpcspYFS8rRw9OkaRSZPPwafjYczQGYcnHIgzxOghpNGUdRpmPJJxbyLDon1cOirwitfuwOjGsdDWyas(JLC8Cc6oS(WKEEulLG44mYXfDKGHJ7kuTtFIl445e0Dy9HbwbSLchNrEWzJr4WTHJtJSluJ7dhxFzqxkCCrh5czOH8sQ(ii)ig54IosWWXRwzpz2KC8GZgJ(JBdhNgzxOg3hoU(YGUu44h5oQ2j7c9iOpsd82atpiNO(ii9iwYXfDKGHJFIDIhC2yeU52WXPr2fQX9HJRVmOlfoUg4TbMEqor9rq6rSKJl6ibdhV2DuJh8GJRbGsdynvUnC2yKBdhx0rcgoEpisWWXPr2fQX9HhC2Gd3goUOJemC8DbaAgh2XahNgzxOg3hEWzZFCB44IosWWX30vPZEoW440i7c14(WdoBWn3goUOJemCC50YqMaChnbhNgzxOg3hEWzJLCB44IosWWXljSUOAyXWAW8Oj440i7c14(WdoBWvUnCCrhjy44U8ODbaACCAKDHACF4bNn2l3goUOJemCCz0unoPy0sPWXPr2fQX9HhC28VCB440i7c14(WX1xg0LchFJ5CQnjNXbopfwphx0rcgo((YAuYbMXHD8GZg7NBdhNgzxOg3hoU(YGUu44q8OgiuEaW4YJurQTNdShTA1JeDKlKHgYlP6JG8Jy8rRFe0h1aHk6oP2z2KCQi12Zbghx0rcgoEoA5gjsWWdoBmYoUnCCrhjy44B6Q0zNJtJSluJ7dp4SXiJCB440i7c14(WXfDKGHJRzqxaXbMuB2fPgCCY5iDygXJ44Ag0fqCGj1MDrQbp4SXiC42WXfDKGHJJvjtgKxLJtJSluJ7dp4bhhObZcWoXTHZgJCB44IosWWX9aGXEogh48440i7c14(WdoBWHBdhNgzxOg3hoU(YGUu44HuOjuDKCHb4mrhzSYstrJSlu7rqFKFpAJ5CQosUWaCMOJmwzPPW654IosWWX7i5cdWzIoYyLLgp4S5pUnCCAKDHACF446ld6sHJxbyLDonLlVAyQXL2jfnYUqThb9rBmNt5YRgMACPDsH1ZXfDKGHJRbZcWozIoYu7ZlJkp4Sb3CB440i7c14(WX1xg0LchN0LSVskzyWmeCjE0QvpI0LSVsQkOiNzi4sWXfDKGHJxd5C5r8GZgl52WXPr2fQX9HJRVmOlfooPlzFLuYWGzi4s8OvREePlzFLufSroZqWLGJl6ibdh36KOJhC2GRCB440i7c14(WX1xg0LchpKcnHQJKlmaNj6iJvwAkAKDHApc6J2yoNQJKlmaNj6iJvwAkSEoUOJemCCnywa2jt0rMAFEzu5bNn2l3goonYUqnUpCC9LbDPWXdPqtO6i5cdWzIoYyLLMIgzxO2JG(inauAaRr1rYfgGZeDKXkln1rEso1hb5hXil54IosWWX1GzbyNmrhzQ95LrLhC28VCB440i7c14(WX1xg0Lch3VhfsHMq1rYfgGZeDKXklnfnYUqnoUOJemCCnywa2jt0rMAFEzu5bp44Anywa2jUnC2yKBdhx0rcgoUwcJdCECCAKDHACF4bNn4WTHJtJSluJ7dhxFzqxkC8qk0eQosUWaCMOJmwzPPOr2fQ9iOpYVhTXCovhjxyaot0rgRS0uy9CCrhjy44DKCHb4mrhzSYsJhC28h3goonYUqnUpCC9LbDPWXRaSYoNMYLxnm14s7KIgzxO2JG(OnMZPC5vdtnU0oPW654IosWWX1GzbyNmrhzQ95LrLhC2GBUnCCAKDHACF446ld6sHJhsHMq1rYfgGZeDKXklnfnYUqThb9rBmNt1rYfgGZeDKXklnfwphx0rcgoUgmla7Kj6itTpVmQ8GZgl52WXPr2fQX9HJRVmOlfoEifAcvhjxyaot0rgRS0u0i7c1Ee0hPbGsdynQosUWaCMOJmwzPPoYtYP(ii)igzjhx0rcgoUgmla7Kj6itTpVmQ8GZgCLBdhNgzxOg3hoU(YGUu44(9Oqk0eQosUWaCMOJmwzPPOr2fQXXfDKGHJRbZcWozIoYu7ZlJkp4bhhyvSizH42WzJrUnCCAKDHACF446ld6sHJ73J2yoNYdag75yCGZtH1ZXfDKGHJ7baJ9CmoW5XdoBWHBdhNgzxOg3hoU(YGUu44HuOjuDKCHb4mrhzSYstrJSlu7rqFKFpAJ5CQosUWaCMOJmwzPPW654IosWWX7i5cdWzIoYyLLgp4S5pUnCCrhjy441qUk2bJ440i7c14(WdoBWn3goonYUqnUpCC9LbDPWXRaSYoNMYLxnm14s7KIgzxOghx0rcgoUgmla7Kj6itTpVmQ8GZgl52WXPr2fQX9HJRVmOlfoE7WYMcyvSizHmBsooUOJemCCYRhyrNzdMgp4Sbx52WXPr2fQX9HJRVmOlfooepYVh1aHsAsFKlKPAjNNPjEcmsfP2EoWEe0h53JeDKGrjnPpYfYuTKZZ0epbgPYX4kjSU4rqFeepYVh1aHsAsFKlKPAjNNPJKIksT9CG9OvREudekPj9rUqMQLCEMoskQJ8KCQpcYpYFpA9JwT6rnqOKM0h5czQwY5zAINaJu1q02FeKEK)Ee0h1aHsAsFKlKPAjNNPjEcmsDKNKt9rq6rS8rqFudekPj9rUqMQLCEMM4jWivKA75a7rR54IosWWXLM0h5czQwY5XdoBSxUnCCAKDHACF44IosWWXRyJlpIJRVmOlfo(rUJQDYUqCCnd6czc5GrrLZgJ8GZM)LBdhNgzxOg3hoUOJemCCpayC5rCC9LbDPWXpYDuTt2f6rRw9OnMZPGjfrhP2adtUwkJcRNJRzqxitihmkQC2yKhC2y)CB440i7c14(WX1xg0LchxdwOrMqnjSUW4e6rqFePlzFLuYWGzi4sWXfDKGHJxd5C5r8GZgJSJBdhNgzxOg3hoU(YGUu44(9inyHgzc1KW6cJtOhb9rKUK9vsjddMHGlbhx0rcgoU1jrhp4SXiJCB440i7c14(WX1xg0LchhIhTXCofPlzFLmfSrofw)JwT6rBmNtr6s2xjtfuKtH1)O1CCrhjy44AWSaStMOJm1(8YOYdoBmchUnCCAKDHACF446ld6sHJdXJiDj7RKkhtbBK7rRw9isxY(kPQGICMHGlXJw)OvREeepI0LSVsQCmfSrUhb9rBmNtvd5QyhmYqE9al68OjmfSrofw)JwZXfDKGHJxd5C5r8GZgJ(JBdhx0rcgoU1jrhhNgzxOg3hEWdEWXxORMGHZgCyhCyKD(x4W(54wYn5aRYXzFE9GlO2JyKXhj6ibZJkznQQNvoETN0C2yKDWnhV)aUSqCCwil8rSGWKRLY8iwGpSS9SYczHpcN6dYBt3JyeUc)JGd7GdJpRpRSqw4Jyr6Kbgvzb6zLfYcFelGhX(gn46bNe0JyrKWwwWbGXEopQ)sWLrs1hbr6EuLIihypkRps3rA7uBT6zLfYcFelGhX(gn46bNe0Ja9rcMhfGhv7sx8iia3JgqS(rBYbo6rSiGzbyNupRpRSWh5)cxinwqThTjh4OhPbEBjE0MGLtv9iwW0AQpQpAadlGo58CyLhj6ibt9rGPWG6zv0rcMQQ)inWBlHVmT1EoTJAMAFEzuFwfDKGPQ6psd82s4ltB7i5cdWzIoYyLLg8PJzifAcvhjxyaot0rgRS0u0i7c1Gcr7WYMslHfjlKztYbDJ5CkTegh48uy9Rw1oSSPawflswiZMKd6gZ5uEaWyphJdCEkS(vR2yoNYdag75yCGZtH1dnKcnHAlfz0KrCUCYGbfnYUqT1pRIosWuv9hPbEBj8LPT9hWQaF6yUXCoLwcJdCEkSEOTdlBkTewKSqMnj3ZQOJemvv)rAG3wcFzA7MKZ4aNh8PJPFBmNtjddgh48uy9qHac)Ahw2uaRIfjlKztYb1V2HLnLwclswiZMKBnui8tdwOrMqnjSUW4eA96vRGac)Ahw2uaRIfjlKztYb1V2HLnLwclswiZMKBnui0GfAKjutcRlmoHGgsHMqDunaNejymIZLtgmOOr2fQTE9ZQOJemvv)rAG3wcFzAR1jrh8PJ5gZ5uEaWyphJdCEkSEOTdlBkGvXIKfYSj5G6NgSqJmHAsyDHXj0ZQOJemvv)rAG3wcFzABnKZLhbF6yUXCoLham2ZX4aNNcRhA7WYMcyvSizHmBsoOAWcnYeQjH1fgNqpRIosWuv9hPbEBj8LPTUcv70N4c4thZkaRSZPP6XQbwHm0H1hjyu0i7c1wTQcWk7CAQfqrISqMkOSqtOOr2fQbFobDhwFysppQLsqmze(Cc6oS(WaRa2sHjJWNtq3H1hM0XScWk7CAQfqrISqMkOSqt8S(SYcFK)lCH0yb1EeTqhdpksp6rrh9irhG7rz9rYIKfzxi1ZQOJemvMv7yLIzl1UNvrhjyQ(Y0wSkzYG8GFepIjlgiWgyuENPr1ihgQgTukWNoM(TXCov)bSkkSEO(Pbl0itOwOj6y4EwfDKGP6ltBXQKjdYd(AbemJlh7uWi8PJPFBmNt1FaRIcRhQFAWcnYeQfAIogUNvrhjyQ(Y0wSkzYG8GVwabZ4YXofWb(0X0VnMZP6pGvrH1d1pnyHgzc1cnrhd3ZQOJemvFzABpisWaF6y6NgSqJmHAHMOJHdkeqarifAcvhjxyaot0rgRS0u0i7c1GUXCovhjxyaot0rgRS0uy9RHcr7WYMslHfjlKztYTAv7WYMcyvSizHmBsU1q9BJ5CQ(dyvuy9RxTcci2yoNAtxLo7MnjNcRF1QnMZPYrl3ircgdmm5APmgGZGDvGwH1Vgke(1oSSP0syrYcz2KCq9RDyztbSkwKSqMnj361RFwzHSWhXIiHfjl5a7rIosW8OswJhzLLYJ20JozEu6G)rEYaRq2gDNu7EKC0JaZJ0n4F0jWOhL1hTPcW6rWn7G)r(F6S)izApkhTCJejyEKC0JAaR5rY0EelimPi6i1pcgMCTuMhTXCUhL1hnG4rIoYfc(hbUhLo4FKf5Fo6r58iTeoW59izApIg6GXWJY6JKnyHEeCyj8pIf)Eu6EKf9OozHEu0rpIfxIUhviy00KJHhrShSSVNAW)OOJEuJ2yo3Jk5yNApkapkJhL1hnG4ry9psM2JOHoym8OS(izdwOhbh2bpl(9O09ilY)C0JSZWLY8izApY)1Rhyr3J2GP9inauAaR5rz9ry9psM2JOH8sQ(i5OhLJJUeCpkapcoQNvrhjyQ(Y02dBmIosWykznGVgxQdMmc)iEetTewKSqWNoMTdlBkTewKSqMnjhu)0GfAKjul0eDmCq3yoNkhTCJejymWWKRLYyaod2vbAvdynq3yoNAtxLo7MnjNQbSgOqaHgaknG1OIUtQDMnjN6ipjNkKzhunauAaRr5jdScPoYtYPcz2bTbcLhamU8i1rEsoviZeMU5l7uSe6jWiib3Sd6gZ5u5OLBKibJbgMCTugdWzWUkqRAaRb6gZ5uB6Q0z3Sj5unG1aDJ5Ckysr0rQnWWKRLYOAaRz9QvqSXCoLwcJdCEkSEO0qhmgGmCy56vRGObc1j2j1rUJQDYUqqBGqDzV6i3r1ozxO1RwbXHnKdCWifqIodWzIoYqLgDM2HLnfXEWY(EQb1VnMZPas0zaot0rgQ0OZ0oSSPW6HcXgZ5uAjmoW5PW6HsdDWyaYWHDRHUXCovhjxyaot0rgRS0uh5j5uHetgz36vRGqdwOrMqzNHlLbQgaknG1OiVEGfDMnyAQJ8KCQqIjJqfDKlKHgYlPkKGZ6vRGyJ5CQosUWaCMOJmwzPPW6HsdDWyaYSF2TE9ZQOJemvFzA7HngrhjymLSgWxJl1btgHFepIPwclswi4thZ2HLnLwclswiZMKdQgSqJmHAHMOJHdkeqObGsdynQO7KANztYPoYtYPcz2bvdaLgWAuEYaRqQJ8KCQqMDqBGq5baJlpsDKNKtfYmHPB(YoflHEcmcsWn7GUXCovoA5gjsWyGHjxlLXaCgSRc0QgWAGUXCo1MUkD2nBsovdynq3yoNcMueDKAdmm5APmQgWAGEcmcsWn7GUXCovoA5gjsWyGHjxlLXaCgSRc0QgWAGUXCo1MUkD2nBsovdynq3yoNcMueDKAdmm5APmQgWAwVAfeBmNtPLW4aNNcRhkn0bJbidhwUE1kiAGqDIDsDK7OANSle0giux2RoYDuTt2fc6jWiib3Sd6gZ5u5OLBKibJbgMCTugdWzWUkqRAaRb6gZ5uB6Q0z3Sj5unG1aDJ5Ckysr0rQnWWKRLYOAaRz96NvrhjyQ(Y02dBmIosWykznGVgxQdMmc)iEetTewKSqWNoM(1oSSP0syrYcz2KCq3yoNslHXbopfw)ZklKf(iwCRIfjl5a7rIosW8OswJhzLLYJ20JozEu6G)rEYaRq2gDNu7EKC0JaZJ0n4F0jWOhL1hTPcW6rmYs4FK)No7psM2JYrl3ircMhjh9OgWAEKmThXcctkIos9JGHjxlL5rBmN7rz9rdiEKOJCHupIf)Eu6G)rwK)5OhLZJ8aGXEopYboVhjt7rvSXLh9OS(OJChv7KDHG)rS43Js3JSOh1jl0JIo6rS4s09OcbJMMCm8iI9GL99ud(hfD0JA0gZ5Eujh7u7rb4rz8OS(ObepcRxXIFpkDpYI8ph9i7mCPmpsM2J8F96bw09OnyApsdaLgWAEuwFew)JKP9iAiVKQpso6rBQaSEeCG)rG7rP7rwK)5OhXwcRlEKtOhjt7rSiGzbyNEKU9OS(iSE1ZQOJemvFzA7HngrhjymLSgWxJl1btgHFepIjWQyrYcbF6y2oSSPawflswiZMKdkeqObGsdynQO7KANztYPoYtYPcz2bvdaLgWAuEYaRqQJ8KCQqMDqpbgbjgzj0nMZPYrl3ircgvdynq3yoNAtxLo7MnjNQbSgOBmNtbtkIosTbgMCTugvdynRxTcInMZP8aGXEogh48uy9qBGqvXgxEK6i3r1ozxO1RwbXgZ5uEaWyphJdCEkSEOBmNt1rYfgGZeDKXklnfw)6vRG4WgYboyKcirNb4mrhzOsJot7WYMIypyzFp1G63gZ5uaj6maNj6idvA0zAhw2uy9RxTccnyHgzc1KW6cJtiOAaO0awJsdMfGDYeDKP2Nxgv1rEsoviXKX1RwbHgSqJmHYodxkdunauAaRrrE9al6mBW0uh5j5uHetgHk6ixidnKxsvibN1RFwfDKGP6ltBpSXi6ibJPK1a(ACPoyYi8J4rmbwflswi4tht)Ahw2uaRIfjlKztYbDJ5CkpaySNJXbopfw)ZQOJemvFzA7HngrhjymLSgWpIhXeyvSizHGVgxQdMmcF6y2oSSPawflswiZMKd6gZ5uEaWyphJdCEkS(Nvw4JyFUhzrpQtwOhXIMbTCYJkemAAYXWJi2dw23tThjt7rBPiJMEK4C5KbdpsQpsEuifAIhzrpQALHU7r5eGh5baJ9CEKdCEpYQJgAHUhfD0JkmOLtE0gZ5EuwFKepcCpAtfG1JGZJQK(zv0rcMQVmT9WgJOJemMswd4hXJywyqlNaGpDmHaIdBih4GrQcdA5KQXvikYbMbwj96RKIypyzFp1wdfIqk0eQTuKrtgX5Yjdgu0i7c1wdfInMZPkmOLtQgxHOihygyL0RVskS(1qHyJ5CQcdA5KQXvikYbMbwj96RK6ipjNkKycN1RFwzHpI95EKf9OozHEelAg0YjpQqWOPjhdpIypyzFp1EKmTh5OtkpsCUCYGHhj1hjpkKcnXJSOhvTYq39OCcWJC0jLh5aN3JS6OHwO7rrh9OcdA5KhTXCUhL1hjXJa3J2uby9i48OkPFwfDKGP6ltBpSXi6ibJPK1a(r8iMfg0YjA4thtiG4WgYboyKQWGwoPACfIICGzGvsV(kPi2dw23tT1qHiKcnHYrNumIZLtgmOOr2fQTgkeBmNtvyqlNunUcrroWmWkPxFLuy9RHcXgZ5ufg0YjvJRquKdmdSs61xj1rEsoviXeoRx)SYcFe7Z9ilY)C0JKhnjSUWj0JKP9il6rnW4FIhzjt8Oa8iTewKSq2cSkwKSqW)izApYIEuNSqpAlfz0KTo6KYJeNlNmy4rHuOjOg8pIfvhn0cDpsdMfGD6r62JY6JW6FKf9OQvg6UhLtaEK4C5KbdpYboVhfGhPLA8OmG)rD0rpYdag758ih48upRIosWu9LPTh2yeDKGXuYAa)iEetGgmla7e8PJzLIihyvvTlDHXboJgmla7euiGiKcnHAlfz0KrCUCYGbfnYUqT1qHWV2HLnLwclswiZMKBnui8RDyztbSkwKSqMnj3AOqObl0itOMewxyCcbvdaLgWAuAWSaStMOJm1(8YOQoYtYPcjMmUE9Zkl8rSp3JSi)ZrpsE0KW6cNqpsM2JSOh1aJ)jEKLmXJcWJ0syrYczlWQyrYcb)JKP9il6rDYc9OTuKrt26OtkpsCUCYGHhfsHMGAW)iwuD0ql09inywa2PhPBpkRpcR)rw0JQwzO7Euob4rIZLtgm8ih48EuaEKwQXJYa(h1rh9iTeoW59ih48upRIosWu9LPTh2yeDKGXuYAa)iEetTgmla7e8PJzLIihyvvTlDHXboJgmla7euiGiKcnHYrNumIZLtgmOOr2fQTgke(1oSSP0syrYcz2KCRHcHFTdlBkGvXIKfYSj5wdfcnyHgzc1KW6cJtiOAaO0awJsdMfGDYeDKP2Nxgv1rEsoviXKX1RFwfDKGP6ltB1sPyeDKGXuYAa)iEetVmsysKG5zv0rcMQVmT9WgJOJemMswd4hXJyUj5EwFwfDKGPQ2KCm3KCgh48GpDm9BJ5CQnjNXbopfw)ZQOJemv1MKZxM22rYfgGZeDKXkln4thZqk0eQosUWaCMOJmwzPPOr2fQbfIqk0eQTuKrtgX5Yjdgu0i7c1wdvdwOrMqTqt0XW9Sk6ibtvTj58LPTEaW4YJGxZGUqMqoyuuzYi8PJjeq4xKA75adAKEKjaMwsqMr4aDJ5Ckysr0rQnWWKRLYOW6xVAfeh5oQ2j7cbnspYeatljiZiCGUXCofmPi6i1gyyY1szuy9Rx)Sk6ibtvTj58LPTEaW4YJGxZGUqMqoyuuzYi8PJjeq4xKA75adAKEKjaMwsqMr4SE1kioYDuTt2fcAKEKjaMwsqMr4SE9ZQOJemv1MKZxM2EYcnaSQXD04)z4zv0rcMQAtY5ltBXQKjdYd(r8iMSyGaBGr5DMgvJCyOA0sPaF6yQbl0itOwOj6y4EwfDKGPQ2KC(Y0wSkzYG8GVwabZ4YXofmcF6y63gZ5u9hWQOW6HQbl0itOwOj6y4EwfDKGPQ2KC(Y0wSkzYG8GVwabZ4YXofWb(0X0VnMZP6pGvrH1dvdwOrMqTqt0XW9Sk6ibtvTj58LPT9Gibd8PJPgSqJmHAHMOJHd6gZ5u5OLBKibJ6ipjNkKzch4g6gZ5u5OLBKibJ6ipjNkKychw(Sk6ibtvTj58LPTAWSaStMOJm1(8YOcF6y6x7WYMslHfjlKztYb1V2HLnfWQyrYcz2KCpRIosWuvBsoFzA7MUkD2nBso4thti2yoN6KfAayvJ7OX)ZGcRF1k)0GfAKjul0eDmCRFwfDKGPQ2KC(Y02C0YnsKGb(0XeInMZPozHgaw14oA8)mOW6xTYpnyHgzc1cnrhd36NvrhjyQQnjNVmTDtxLo75ad(0XeInMZP20vPZUztYPW6xTAJ5CQC0YnsKGXadtUwkJb4myxfOvy9RFwfDKGPQ2KC(Y0wPj9rUqMQLCEWNoMq4xdekPj9rUqMQLCEMM4jWivKA75adQFIosWOKM0h5czQwY5zAINaJu5yCLewxafc)AGqjnPpYfYuTKZZ0rsrfP2EoWwTQbcL0K(ixit1sopthjf1rEsovi7V1Rw1aHsAsFKlKPAjNNPjEcmsvdrBhs(dAdekPj9rUqMQLCEMM4jWi1rEsoviXsOnqOKM0h5czQwY5zAINaJurQTNdS1pRIosWuvBsoFzARhamU8i4thZnMZPGjfrhP2adtUwkJcRhQOJCHm0qEjvHK)EwfDKGPQ2KC(Y02O7KANztYbVMbDHmHCWOOYKr4thZJChv7KDHwTQbcv0DsTZSj5u1q02HK)wTcIgiur3j1oZMKtvdrBhsWn0dBih4GrQcMZj54WQuZqE7t0KIypyzFp1wVALOJCHm0qEjvHmt4E1QnMZP20vPZUztYPW6HUXCo1MUkD2nBso1rEsoviXeMU5l7uS8zv0rcMQAtY5ltB9KbwHGpDmpbgPAKl1zazgzh0kfroWQkpzGviJh4ONvrhjyQQnjNVmT1vOAN(exaF6ywbyLDonvpwnWkKHoS(ibJIgzxOguiGqdaLgWAur3j1oZMKtDKNKtfYSdQgaknG1O8KbwHuh5j5uHm7wdfIgiuEaW4YJuh5j5uHmt)TgkeBmNtLJwUrIemgyyY1szmaNb7QaTQbSgOBmNtTPRsNDZMKt1awd0nMZPGjfrhP2adtUwkJQbSM1RxTQcWk7CAQfqrISqMkOSqtOOr2fQbFobDhwFysppQLsqmze(Cc6oS(WaRa2sHjJWNtq3H1hM0XScWk7CAQfqrISqMkOSqtafcnauAaRrfDNu7mBso1rEsoviZoOAaO0awJYtgyfsDKNKtfYSB9ZQOJemv1MKZxM2wTYEc(0XCJ5CQC0YnsKGXadtUwkJb4myxfOvnG1aDJ5CQnDv6SB2KCQgWAGk6ixidnKxsviZeUFwfDKGPQ2KC(Y0wpbRaF6yUXCovoA5gjsWOW6Hk6ixidnKxsvi5pOqSXCovaarNrMMrxelvneTDiZeoRxTcInMZPcai6mY0m6IyPW6HUXCovaarNrMMrxel1rEsoviXOILRxTcInMZPQYIaJmAG3wczcvneTDiZ0FRxTAJ5CQnDv6SB2KCkSEOIoYfYqd5Lufs(7zv0rcMQAtY5ltB9eSc8PJjeBmNtvLfbgz0aVTeYeQAiA7qMjJRHcXgZ5ubaeDgzAgDrSuy9RHUXCovoA5gjsWOW6Hk6ixidnKxsvMW5zv0rcMQAtY5ltB9KbwHGpDm3yoNkhTCJejyuy9qfDKlKHgYlPkKy6VNvrhjyQQnjNVmT1tWkWNoMqabeBmNtfaq0zKPz0fXsvdrBhYmHZ6vRGyJ5CQaaIoJmnJUiwkSEOBmNtfaq0zKPz0fXsDKNKtfsmQy56vRGyJ5CQQSiWiJg4TLqMqvdrBhYm9361qfDKlKHgYlPkK836NvrhjyQQnjNVmTn6oP2z2KCWNoMIoYfYqd5LufYm(Sk6ibtvTj58LPTEYaRqWNoMqaXjWiiX(z3AOIoYfYqd5Lufs(B9QvqaXjWii5Fz5AOIoYfYqd5Lufs(dAifAcvfGvmaNj6iJdCunu0i7c1w)Sk6ibtvTj58LPT9yLf6s)pbVMbDHmHCWOOYKr4thZgiur3j1oZMKtvdrBhYW5zv0rcMQAtY5ltBJUtQDMnj3ZQOJemv1MKZxM26jyf4thtrh5czOH8sQcj)9Sk6ibtvTj58LPTvRSNmBsUNvrhjyQQnjNVmTnpW4Wo4thZtGrQg5sDgqcUzh0nMZPYdmoStDKNKtfsStXYN1NvrhjyQkVmsysKGHzEGXHDWNoM5ObE5aZ0epbgzyzfY5bgh2zAINaJmr3r1oqPbDJ5CQ8aJd7uh5j5uHK)8F6KAqpRIosWuvEzKWKibJVmT9OHSKc8PJziJ9CGbTJKs0P61bKGRS8zv0rcMQYlJeMejy8LPTUJg)FsnZrWOHojsWaF6ygYyphyq7iPeDQEDaj4klFwfDKGPQ8YiHjrcgFzAl51dSOZSbtd(0Xec)Ahw2uAjSizHmBsoO(1oSSPawflswiZMKB9QvIoYfYqd5LufYmHZZQOJemvLxgjmjsW4ltB3YzVAph4thZqg75adAhjLOt1RdiXEzj0C0aVCGzAINaJmSScz2Py0)PJKs0P8e4YZQOJemvLxgjmjsW4ltBRy3sUifto1ihDuHpDm3yoNQIDl5Ium5uJC0rv1awd0nMZP2YzVAphvdynq7iPeDQEDaj4k7GMJg4Ldmtt8eyKHLviZofCyP)thjLOt5jWLN1NvrhjyQknauAaRPYShejyEwfDKGPQ0aqPbSMQVmTDxaGMXHDm8Sk6ibtvPbGsdynvFzA7MUkD2Zb2ZQOJemvLgaknG1u9LPTYPLHmb4oAINvrhjyQknauAaRP6ltBljSUOAyXWAW8OjEwfDKGPQ0aqPbSMQVmT1LhTlaq7zv0rcMQsdaLgWAQ(Y0wz0unoPy0sP8Sk6ibtvPbGsdynvFzA7(YAuYbMXHDWNoMBmNtTj5moW5PW6FwfDKGPQ0aqPbSMQVmTnhTCJejyGpDmHObcLhamU8ivKA75aB1krh5czOH8sQczgxdTbcv0DsTZSj5urQTNdSNvrhjyQknauAaRP6ltB30vPZ(ZQOJemvLgaknG1u9LPTyvYKb5bp5CKomJ4rm1mOlG4atQn7IuJNvrhjyQknauAaRP6ltBXQKjdYR(S(Sk6ibtvPLWIKfIz)bSkpRIosWuvAjSizH8LPTAjmoW5bF6y63gZ5uAjmoW5PW6FwfDKGPQ0syrYc5ltBpXobF6yUXCov)bSkkS(NvrhjyQkTewKSq(Y02osUWaCMOJmwzPbF6ygsHMq1rYfgGZeDKXklnfnYUqnO(TXCovhjxyaot0rgRS0uy9pRIosWuvAjSizH8LPTKxpWIoZgmn4thZ2HLnLwclswiZMK7zv0rcMQslHfjlKVmT9e7e8PJzdeQtStQJChv7KDHwTIg6GXaKGBw(Sk6ibtvPLWIKfYxM2Ezp8PJzdeQl7vh5oQ2j7cbvd82atpiNOczMW9ZQOJemvLwclswiFzARgmla7Kj6itTpVmQWNoMTdlBkTewKSqMnj3ZQOJemvLwclswiFzARJoGobyvZodcEpbUyOHoymWKr4thtnWBdm9GCIkKzc3pRIosWuvAjSizH8LPTst6JCHmvl58GpDmHWVgiust6JCHmvl58mnXtGrQi12Zbgu)eDKGrjnPpYfYuTKZZ0epbgPYX4kjSUake(1aHsAsFKlKPAjNNPJKIksT9CGTAvdekPj9rUqMQLCEMoskQJ8KCQq2FRxTQbcL0K(ixit1soptt8eyKQgI2oK8h0giust6JCHmvl58mnXtGrQJ8KCQqILqBGqjnPpYfYuTKZZ0epbgPIuBphyRFwfDKGPQ0syrYc5ltBDfQ2PpXfWNoMvawzNtt1JvdSczOdRpsWOOr2fQbLg6GXaK8hlxTQcWk7CAQfqrISqMkOSqtOOr2fQbFobDhwFysppQLsqmze(Cc6oS(WaRa2sHjJWNtq3H1hM0XScWk7CAQfqrISqMkOSqtaLg6GXaK8hlFwfDKGPQ0syrYc5ltBRwzpbF6yk6ixidnKxsviZ4ZQOJemvLwclswiFzA7j2j4thZJChv7KDHGQbEBGPhKtuHelFwfDKGPQ0syrYc5ltBRDh1GpDm1aVnW0dYjQqILpRpRIosWuvAnywa2jMAjmoW59Sk6ibtvP1GzbyN8LPTDKCHb4mrhzSYsd(0XmKcnHQJKlmaNj6iJvwAkAKDHAq9BJ5CQosUWaCMOJmwzPPW6FwfDKGPQ0AWSaSt(Y0wnywa2jt0rMAFEzuHpDmRaSYoNMYLxnm14s7KIgzxOg0nMZPC5vdtnU0oPW6FwfDKGPQ0AWSaSt(Y0wnywa2jt0rMAFEzuHpDmdPqtO6i5cdWzIoYyLLMIgzxOg0nMZP6i5cdWzIoYyLLMcR)zv0rcMQsRbZcWo5ltB1GzbyNmrhzQ95Lrf(0XmKcnHQJKlmaNj6iJvwAkAKDHAq1aqPbSgvhjxyaot0rgRS0uh5j5uHmJS8zv0rcMQsRbZcWo5ltB1GzbyNmrhzQ95Lrf(0X0Vqk0eQosUWaCMOJmwzPPOr2fQ9S(Sk6ibtvvyqlNOzQLW4aN3Z6ZQOJemvvHbTCcGPham2ZX4aN3Z6ZQOJemvfqdMfGDIPham2ZX4aN3ZQOJemvfqdMfGDYxM22rYfgGZeDKXkln4thZqk0eQosUWaCMOJmwzPPOr2fQb1VnMZP6i5cdWzIoYyLLMcR)zv0rcMQcObZcWo5ltB1GzbyNmrhzQ95Lrf(0XScWk7CAkxE1WuJlTtkAKDHAq3yoNYLxnm14s7KcR)zv0rcMQcObZcWo5ltBRHCU8i4thtsxY(kPKHbZqWLy1ksxY(kPQGICMHGlXZQOJemvfqdMfGDYxM2ADs0bF6ys6s2xjLmmygcUeRwr6s2xjvbBKZmeCjEwfDKGPQaAWSaSt(Y0wnywa2jt0rMAFEzuHpDmdPqtO6i5cdWzIoYyLLMIgzxOg0nMZP6i5cdWzIoYyLLMcR)zv0rcMQcObZcWo5ltB1GzbyNmrhzQ95Lrf(0XmKcnHQJKlmaNj6iJvwAkAKDHAq1aqPbSgvhjxyaot0rgRS0uh5j5uHmJS8zv0rcMQcObZcWo5ltB1GzbyNmrhzQ95Lrf(0X0Vqk0eQosUWaCMOJmwzPPOr2fQ9S(Sk6ibtvbSkwKSqm9aGXEogh48GpDm9BJ5CkpaySNJXbopfw)ZQOJemvfWQyrYc5ltB7i5cdWzIoYyLLg8PJzifAcvhjxyaot0rgRS0u0i7c1G63gZ5uDKCHb4mrhzSYstH1)Sk6ibtvbSkwKSq(Y02Aixf7GrpRIosWuvaRIfjlKVmTvdMfGDYeDKP2Nxgv4thZkaRSZPPC5vdtnU0oPOr2fQ9Sk6ibtvbSkwKSq(Y0wYRhyrNzdMg8PJz7WYMcyvSizHmBsUNvrhjyQkGvXIKfYxM2knPpYfYuTKZd(0Xec)AGqjnPpYfYuTKZZ0epbgPIuBphyq9t0rcgL0K(ixit1soptt8eyKkhJRKW6cOq4xdekPj9rUqMQLCEMoskQi12Zb2QvnqOKM0h5czQwY5z6iPOoYtYPcz)TE1Qgiust6JCHmvl58mnXtGrQAiA7qYFqBGqjnPpYfYuTKZZ0epbgPoYtYPcjwcTbcL0K(ixit1soptt8eyKksT9CGT(zv0rcMQcyvSizH8LPTvSXLhbVMbDHmHCWOOYKr4thZJChv7KDHEwfDKGPQawflswiFzARhamU8i41mOlKjKdgfvMmcF6yEK7OANSl0QvBmNtbtkIosTbgMCTugfw)ZQOJemvfWQyrYc5ltBRHCU8i4thtnyHgzc1KW6cJtiOKUK9vsjddMHGlXZQOJemvfWQyrYc5ltBToj6GpDm9tdwOrMqnjSUW4eckPlzFLuYWGzi4s8Sk6ibtvbSkwKSq(Y0wnywa2jt0rMAFEzuHpDmHyJ5CksxY(kzkyJCkS(vR2yoNI0LSVsMkOiNcRF9ZQOJemvfWQyrYc5ltBRHCU8i4thtiiDj7RKkhtbBKB1ksxY(kPQGICMHGlX6vRGG0LSVsQCmfSroOBmNtvd5QyhmYqE9al68OjmfSrofw)6NvrhjyQkGvXIKfYxM2ADs0XdEW5a]] )


end