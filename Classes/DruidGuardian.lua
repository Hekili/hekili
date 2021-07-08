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

    spec:RegisterPack( "Guardian", 20210708.1, [[dC0SQbqirQEefvAtOIprrfgLsQtPKSkufQELiLzHOClkQO2fL(fQQggQIogfXYuQ4zuu10OiX1Oi12qvGVrrsnouf05ukPSoLsumpLsDpuP9PuPdQusKfsr5HkLKMOsjkDrkQiFuPKWjPijRuPQzQusv3uPKO2jQk)evHYtb1urv6RkLuzVO8xsnyKomXIb5XKmzP6YqBwuFgrgTuCAHvRuIQxlsMTe3Mc7wXVv1WLshhvHSCvEUKMovxhHTReFxeJxPeopIQ1RuImFLI9dmZegVm4U4iJVD45oMWttnp5Hwt4HMMN8ChgStElYGBfvkHeYGhXazWBfeY1dzyWTc5Lx6mEzW1N4uidUX926wg(5Nu4neqw1BWFnmikIh)Ooj78xddf)myiIO4MQHbXG7IJm(2HN7ycpn18KhAnHhAAEYttyWcH38hdgom2Qm4MO3XHbXG7yvXG3kiKRhYaOBzpIOd2VNOqoGYdjdq3HN7WtWEW(TAJmKW6wgWEZza1unQ)A)tCeq3QIZ)w5)NuXaOTx8x4bwb01rgqRO7XqcqJkGQAqvkSVYc2BodOMQr9x7FIJa636XpaQ)aATjYoGU(paDEFfGcH5)qaDR(ZYNcTm4su9kJxgCHCLCYZ4LXNjmEzWIYJFyWg)pPIrN)ZGbJJavWoZmMZCgmekhJxgFMW4LbJJavWoZmgS6chVqyWPdOqe5SfcLtN)ZWs0YGfLh)WGHq505)myoJVDy8YGXrGkyNzgdwDHJximyxk442guox)zT3G6KO0T4iqfSdOCa01aQlfCClKuKrHAjNJjCYT4iqfSdORauoaQ6xWrg3UGJ3q(XGfLh)WGBq5C9N1EdQtIsN5m(mpJxgmocub7mZyWQlC8cHbVgqxdOqe5SLKueLhknjc56HmwIwaDfGYbqfLhlOgh0iWkGUnGUdGUcq3SbqxdORbuiIC2sskIYdLMeHC9qglrlGUcq5aOPdO93Tg)p54qRhQuXqcq5aOIYJfuJdAeyfq3fqnbq5aOUCKq36HbQ9x3deq3fqnzhaDfdwuE8dd24)jhhYCgFMcJxgmocub7mZyWQlC8cHbVgq7VBn(FYXH2dnKyQa62CbuZdOCa01akeroBjjfr5HstIqUEiJLOfqxbOCaur5XcQXbncScO7cOMgq5aOUCKq36HbQ9x3deq3fqnzhaDfdwuE8dd24)jhhYCgFMMXldghbQGDMzmy1foEHWGxdOhMpS2iqfeq5aOIYJfuJdAeyfq3gq3bq5aOUCKq36HbQ9x3deq3fqnzhaDfGUzdGUgqthq7VBn(FYXHwpuPIHeGYbqfLhlOgh0iWkGUlGAcGYbqD5iHU1ddu7VUhiGUlGAYoa6kgSO84hgSX)tooK5m(4bmEzWIYJFyWNSGZtu15dNTe5myCeOc2zMXCgFMAgVmyCeOc2zMXGvx44fcdoDaTFer3QepbLfudHYbOCa00b0(reD7Nusqzb1qOCmyr5Xpmy1plFku7nOU2gx4vMZ4JhY4LbJJavWoZmgS6chVqyWRbuiIC2EYcoprvNpC2sKBjAb0nBa00bu1VGJmUDbhVH8dqxXGfLh)WGHWRIxkMZ4BRX4LbJJavWoZmgS6chVqyWRbuiIC2EYcoprvNpC2sKBjAb0nBa00bu1VGJmUDbhVH8dqxXGfLh)WGJrj3iE8dZz8zcpz8YGXrGkyNzgdwDHJxim41akeroBHWRIxknekNLOfq3SbqHiYzBmk5gXJF0KiKRhYO)SM4QVYs0cORyWIYJFyWq4vXlvmKyoJptmHXldghbQGDMzmy1foEHWGxdOPdO93TsxA9yb11e5m0DXqiHwpuPIHeGYbqthqfLh)yLU06XcQRjYzO7IHqcTXOZLGuJdOCa01aA6aA)DR0LwpwqDnrodDdkfRhQuXqcq3Sbq7VBLU06XcQRjYzOBqPyp0qIPcO7cOMhqxbOB2aO93TsxA9yb11e5m0DXqiH2QlQua62aQ5buoaA)DR0LwpwqDnrodDxmesO9qdjMkGUnGAAaLdG2F3kDP1JfuxtKZq3fdHeA9qLkgsa6kgSO84hgS0LwpwqDnrodMZ4ZKDy8YGXrGkyNzgdwDHJxim4dZhwBeOccOB2aO93TEZj1gnekNT6IkfGUnGAEaDZgaDnG2F36nNuB0qOC2QlQua62aQPaOCa0JyW8FKqBHiNLyYevSRrdOtuOf5rerBl2b0va6MnaQO8yb14Ggbwb0D5cOMcdwuE8dd2BoP2OHq5yoJptmpJxgmocub7mZyWQlC8cHbFcj02XCOchq3fqnHNakhaTIUhdPQ1qgsfuB8hYGfLh)WGnKHubzoJptmfgVmyCeOc2zMXGvx44fcdU(efOy62wIQtuqnEeTE8JfhbQGDaLdGUgqxdOQ)l9pzSEZj1gnekN9qdjMkGUlGYtaLdGQ(V0)KXAidPcAp0qIPcO7cO8eqxbOCa01aA)DRX)too0EOHetfq3LlGAEaDfGYbqxdOqe5SngLCJ4XpAseY1dz0FwtC1xz7FYaOCauiIC2cHxfVuAiuoB)tgaLdGcrKZwssruEO0KiKRhYy7FYaORa0va6MnaA9jkqX0TlFr8OG66xwWXT4iqfSZGJXX7iADDKzW1NOaft3U8fXJcQRFzbhNZA1)L(NmwV5KAJgcLZEOHetDxEYr9FP)jJ1qgsf0EOHetDxEUIbhJJ3r066WWa7H4id2egSO84hgCUG1g1jzNbhJJ3r06AsLhskmytyoJptmnJxgmocub7mZyWQlC8cHbdrKZ2yuYnIh)OjrixpKr)znXvFLT)jdGYbqHiYzleEv8sPHq5S9pzauoaQO8yb14Ggbwb0D5cOMcdwuE8ddUMeTOgcLJ5m(mHhW4LbJJavWoZmgS6chVqyWqe5SngLCJ4XpwIwaLdGkkpwqnoOrGvaDBaDhaDZgafIiNTq4vXlLgcLZs0cOCaur5XcQXbncScOBdO7WGfLh)WGneIcZz8zIPMXldghbQGDMzmy1foEHWGxdOqe5STklcjuREdiXLXTvxuPa0D5cOMaORauoa6AafIiNT()EJwMUwvKelrlGUcq5aOqe5SngLCJ4XpwIwaLdGkkpwqnoOrGvaLlGUddwuE8dd2qikmNXNj8qgVmyCeOc2zMXGvx44fcdgIiNTXOKBep(Xs0cOCaur5XcQXbncScOBZfqnpdwuE8dd2qgsfK5m(mzRX4LbJJavWoZmgS6chVqyWRb01a6AafIiNT()EJwMUwvKeB1fvkaDxUa6oa6kaDZgaDnGcrKZw)FVrltxRksILOfq5aOqe5S1)3B0Y01QIKyp0qIPcOBdOMynnGUcq3SbqxdOqe5STklcjuREdiXLXTvxuPa0D5cOMhqxbORauoaQO8yb14Ggbwb0TbuZdORyWIYJFyWgcrH5m(2HNmEzW4iqfSZmJbRUWXlegSO8yb14Ggbwb0DbutyWIYJFyWEZj1gnekhZz8TJjmEzW4iqfSZmJbRUWXleg8AaDnGEcjeq3gq3A8eqxbOCaur5XcQXbncScOBdOMhqxbOB2aORb01a6jKqaDBaLhAAaDfGYbqfLhlOgh0iWkGUnGAEaLdG6sbh3wFII(ZAVb15)WQBXrGkyhqxXGfLh)WGnKHubzoJVD2HXldghbQGDMzmyr5Xpm4wIYcEXwczWQlC8cHb3F36nNuB0qOC2QlQua6Ua6omyf5QcQD5iHELXNjmNX3oMNXldwuE8dd2BoP2OHq5yW4iqfSZmJ5m(2Xuy8YGXrGkyNzgdwDHJximyr5XcQXbncScOBdOMNblkp(HbBiefMZ4BhtZ4Lblkp(HbxtIwudHYXGXrGkyNzgZz8TdpGXldghbQGDMzmy1foEHWGpHeA7youHdOBdOMcpbuoakeroBJ7NmXzp0qIPcOBdO80AAgSO84hgCC)KjoMZCgSr4bjXJFy8Y4ZegVmyCeOc2zMXGvx44fcdog1BedjDxmesO20vaDxanUFYeNUlgcju7nhwB(shq5aOqe5SnUFYeN9qdjMkGUnGAEaLhhqBKQJmyr5Xpm44(jtCmNX3omEzW4iqfSZmJbRUWXlegSltQyibOCa0gukEJTv5a62akpW0myr5Xpm4dhmrkmNXN5z8YGXrGkyNzgdwDHJximyxMuXqcq5aOnOu8gBRYb0TbuEGPzWIYJFyW5dNTuGD9HKWbpXJFyoJptHXldghbQGDMzmy1foEHWGxdOPdO9Ji6wL4jOSGAiuoaLdGMoG2pIOB)KscklOgcLdqxbOB2aOIYJfuJdAeyfq3LlGUddwuE8ddgnA)e80q)0zoJptZ4LbJJavWoZmgS6chVqyWUmPIHeGYbqBqP4n2wLdOBdOMAtdOCa0yuVrmK0DXqiHAtxb0DbuEAnbq5Xb0gukEJ1q2cgSO84hgmKCPQPIH5m(4bmEzW4iqfSZmJbRUWXlegmeroBRe3sSifDmvpgLxT9pzauoakeroBHKlvnvm2(NmakhaTbLI3yBvoGUnGYd4jGYbqJr9gXqs3fdHeQnDfq3fq5PDhtdO84aAdkfVXAiBbdwuE8ddUsClXIu0Xu9yuEL5mNb3EO6nGeNXlJpty8YGXrGkyNzgdUJv1fTE8dd2CAlqfHJDafcZ)HaQ6nGehqHqsXuTa6wjLcB9kGo)yo3iNrMOaOIYJFQa6pfYTmyr5Xpm4uX0pSRRTXfEL5m(2HXldghbQGDMzmy1foEHWGHiYzRsCD(pdlrlGYbq7hr0TkXtqzb1qOCmyr5Xpm427tkmNXN5z8YGXrGkyNzgdwDHJximyxk442guox)zT3G6KO0T4iqfSdOCa01aA)iIUvjEcklOgcLdq5aOqe5SvjUo)NHLOfq3Sbq7hr0TFsjbLfudHYbOCauiIC2A8)KkgD(pdlrlGUzdGcrKZwJ)NuXOZ)zyjAbuoaQlfCClKuKrHAjNJjCYT4iqfSdORyWIYJFyWnOCU(ZAVb1jrPZCgFMcJxgmocub7mZyWQlC8cHbNoGcrKZwzixN)ZWs0cOCa01a6AanDaTFer3(jLeuwqnekhGYbqthq7hr0TkXtqzb1qOCa6kaLdGUgqthqv)coY42ji146SGa6kaDfGUzdGUgqxdOPdO9Ji62pPKGYcQHq5auoaA6aA)iIUvjEcklOgcLdqxbOCa01aQ6xWrg3obPgxNfeq5aOUuWXThw9)ep(rl5CmHtUfhbQGDaDfGUzdGQ(fCKXTl44nKFa6kgSO84hgmekNo)NbZz8zAgVmyCeOc2zMXGvx44fcdgIiNTg)pPIrN)ZWs0cOCa0(reD7Nusqzb1qOCakhanDav9l4iJBNGuJRZcYGfLh)WGtoXByoJpEaJxgmocub7mZyWQlC8cHbdrKZwJ)NuXOZ)zyjAbuoaA)iIU9tkjOSGAiuoaLdGQ(fCKXTtqQX1zbzWIYJFyWvxUCCiZz8zQz8YGXrGkyNzgdwDHJxim46tuGIPBBjQorb14r06XpwCeOc2b0nBa06tuGIPBx(I4rb11VSGJBXrGkyNbhJJ3r066iZGRprbkMUD5lIhfux)YcoodoghVJO11HHb2dXrgSjmyr5Xpm4CbRnQtYodoghVJO11KkpKuyWMWCMZGlKRKtumEz8zcJxgSO84hgSsCD(pdgmocub7mZyoZzWDmlefNXlJpty8YGXrGkyNzgdUJv1fTE8dd2CAlqfHJDafxWJCa1ddeq9geqfL)hGgvavwKOiqf0YGfLh)WGRPikfnKuByoJVDy8YGXrGkyNzgdwuE8ddEl)DIHeg3P7y1JH8QwjLcdwDHJxim40buiIC22EFsXs0YGhXazWB5VtmKW4oDhREmKx1kPuyoJpZZ4LbJJavWoZmgS6chVqyWPdOqe5ST9(KILOLblkp(HbturD4OrL5m(mfgVmyCeOc2zMXGvx44fcdEnGUgqxdOUuWXTnOCU(ZAVb1jrPBXrGkyhq5aOqe5STbLZ1Fw7nOojkDlrlGUcq5aORb0(reDRs8euwqnekhGUzdG2pIOB)KscklOgcLdqxbOCa00buiIC22EFsXs0cORa0nBa01a6AafIiNTq4vXlLgcLZs0cOB2aOqe5SngLCJ4XpAseY1dz0FwtC1xzjAb0vakhaDnGMoG2pIOBvINGYcQHq5auoaA6aA)iIU9tkjOSGAiuoaDfGUcqxXGfLh)WGBFp(H5m(mnJxgmocub7mZyWQlC8cHb3pIOBvINGYcQHq5auoakeroBvIRZ)zyjAzWv)cLZ4ZegSO84hg8rmAr5Xp6suDgCjQUEedKbRepbLfK5m(4bmEzW4iqfSZmJbRUWXlegC)iIU9tkjOSGAiuoaLdGcrKZwJ)NuXOZ)zyjAzWv)cLZ4ZegSO84hg8rmAr5Xp6suDgCjQUEedKb)jLeuwqMZ4ZuZ4LbJJavWoZmgChRQlA94hgSPkdOjiG2iliGU1tUsobqlijC6YroGI8iIOTf7aQmDafskYOqavY5ycNCavQaQaOUuWXb0eeqRjHRAa0y8hqn(FsfdGM)ZaqtAWbxWdq9geqlKRKtauiICgqJkGkoG(hGcHLpbq3bqROIblkp(HbFeJwuE8JUevNbRUWXleg8AaDnGEedM)JeAlKRKtQ6CbrpgsAsLWOTIwKhreTTyhqxbOCa01aQlfCClKuKrHAjNJjCYT4iqfSdORauoa6AafIiNTfYvYjvDUGOhdjnPsy0wrlrlGUcq5aORbuiIC2wixjNu15cIEmK0KkHrBfThAiXub0T5cO7aORa0vm4suD9igidUqUso5zoJpEiJxgmocub7mZyWDSQUO1JFyWMQmGMGaAJSGa6wp5k5eaTGKWPlh5akYJiI2wSdOY0b0mEsbqLCoMWjhqLkGkaQlfCCanbb0As4Qgang)b0mEsbqZ)zaOjn4Gl4bOEdcOfYvYjakerodOrfqfhq)dqHWYNaO7aOvuXGfLh)WGpIrlkp(rxIQZGvx44fcdEnGUgqpIbZ)rcTfYvYjvDUGOhdjnPsy0wrlYJiI2wSdORauoa6Aa1LcoUnJNu0soht4KBXrGkyhqxbOCa01akeroBlKRKtQ6CbrpgsAsLWOTIwIwaDfGYbqxdOqe5STqUsoPQZfe9yiPjvcJ2kAp0qIPcOBZfq3bqxbORyWLO66rmqgCHCLCII5m(2AmEzW4iqfSZmJb3XQ6Iwp(HbBQYaAcAooeqfaDcsnEwqavMoGMGaA)hZHdOjY4aQ)aQs8euwq()KscklizaQmDanbb0gzbbuiPiJc5pJNuaujNJjCYbuxk44yNmaDRRbhCbpav9ZYNcbuvhqJkGs0cOjiGwtcx1aOX4pGk5CmHtoGM)Zaq9hqvs1b0WjdqBWdbuJ)NuXaO5)mSmyr5Xpm4Jy0IYJF0LO6my1foEHWGRO7XqQARnr215)0QFw(uiGYbqxdORbuxk44wiPiJc1soht4KBXrGkyhqxbOCa01aA6aA)iIUvjEcklOgcLdqxbOCa01aA6aA)iIU9tkjOSGAiuoaDfGYbqxdOQFbhzC7eKACDwqaLdGQ(V0)KXQ(z5tHAVb1124cVAp0qIPcOBZfqnbqxbORyWLO66rmqg8R(z5tHmNXNj8KXldghbQGDMzm4owvx06XpmytvgqtqZXHaQaOtqQXZccOY0b0eeq7)yoCanrghq9hqvINGYcY)NusqzbjdqLPdOjiG2iliGcjfzui)z8KcGk5CmHtoG6sbhh7KbOBDn4Gl4bOQFw(uiGQ6aAubuIwanbb0As4Qgang)bujNJjCYb08FgaQ)aQsQoGgozaAdEiGQep)NbGM)ZWYGfLh)WGpIrlkp(rxIQZGvx44fcdUIUhdPQT2ezxN)tR(z5tHakhaDnGUgqDPGJBZ4jfTKZXeo5wCeOc2b0vakhaDnGMoG2pIOBvINGYcQHq5a0vakhaDnGMoG2pIOB)KscklOgcLdqxbOCa01aQ6xWrg3obPgxNfeq5aOQ)l9pzSQFw(uO2BqDTnUWR2dnKyQa62Cbuta0va6kgCjQUEedKbRu)S8PqMZ4Zety8YGXrGkyNzgdwuE8ddwjLIwuE8JUevNbxIQRhXazWgHhKep(H5m(mzhgVmyCeOc2zMXGfLh)WGpIrlkp(rxIQZGlr11JyGmyiuoMZCgSs8euwqgVm(mHXldwuE8ddU9(KcdghbQGDMzmNX3omEzW4iqfSZmJbRUWXlegC6akeroBvIRZ)zyjAzWIYJFyWkX15)myoJpZZ4LbJJavWoZmgS6chVqyWqe5ST9(KILOLblkp(HbFskK5m(mfgVmyCeOc2zMXGvx44fcd2LcoUTbLZ1Fw7nOojkDlocub7akhanDafIiNTnOCU(ZAVb1jrPBjAzWIYJFyWnOCU(ZAVb1jrPZCgFMMXldghbQGDMzmy1foEHWG7hr0TkXtqzb1qOCmyr5Xpmy0O9tWtd9tN5m(4bmEzW4iqfSZmJbRUWXlegC)D7jPq7H5dRncubbuoaQ6nGED7hJxb0TbutHblkp(HbFskK5m(m1mEzW4iqfSZmJbRUWXlegC)D7fT2dZhwBeOccOCau1Ba962pgVcO7YfqnfgSO84hg8fTmNXhpKXldghbQGDMzmy1foEHWG7hr0TkXtqzb1qOCmyr5Xpmy1plFku7nOU2gx4vMZ4BRX4LbJJavWoZmgS6chVqyWQ3a61TFmEfq3LlGAkmyr5Xpm4mEVkEIQgkCKbBiBHgh8iroJptyoJpt4jJxgmocub7mZyWQlC8cHbVgqthq7VBLU06XcQRjYzO7IHqcTEOsfdjaLdGMoGkkp(XkDP1JfuxtKZq3fdHeAJrNlbPghq5aORb00b0(7wPlTESG6AICg6gukwpuPIHeGUzdG2F3kDP1JfuxtKZq3GsXEOHetfq3fqnpGUcq3Sbq7VBLU06XcQRjYzO7IHqcTvxuPa0TbuZdOCa0(7wPlTESG6AICg6UyiKq7HgsmvaDBa10akhaT)Uv6sRhlOUMiNHUlgcj06HkvmKa0vmyr5XpmyPlTESG6AICgmNXNjMW4LbJJavWoZmgS6chVqyW1NOaft32suDIcQXJO1JFS4iqfSdOCauCWJe5a62aQ5nnGUzdGwFIcumD7YxepkOU(LfCClocub7m4yC8oIwxhzgC9jkqX0TlFr8OG66xwWX5GdEKiFBZBAgCmoEhrRRdddShIJmytyWIYJFyW5cwBuNKDgCmoEhrRRjvEiPWGnH5m(mzhgVmyCeOc2zMXGvx44fcdw9gqVU9JXRwfXD44a62aQPzWIYJFyW1Md7mN5my1)L(NmvgVm(mHXldwuE8ddU994hgmocub7mZyoJVDy8YGfLh)WGHk)31zIJCgmocub7mZyoJpZZ4Lblkp(HbdHxfVuXqIbJJavWoZmMZ4Zuy8YGfLh)WGLtjdQ9)oCCgmocub7mZyoJptZ4Lblkp(HbxcsnEvVLt0jzGJZGXrGkyNzgZz8Xdy8YGfLh)WGZXHqL)7myCeOc2zMXCgFMAgVmyr5Xpmyzuy1pPOvsPWGXrGkyNzgZz8Xdz8YGXrGkyNzgdwDHJximyiIC2cHYPZ)zyjAzWIYJFyWqxu9smK0zIJ5m(2AmEzW4iqfSZmJbRUWXleg8AaT)U14)jhhA9qLkgsa6MnaQO8yb14Ggbwb0Dbuta0vakhaT)U1BoP2OHq5SEOsfdjgSO84hgCmk5gXJFyoJpt4jJxgSO84hgmeEv8sXGXrGkyNzgZz8zIjmEzW4iqfSZmJblkp(HbRixvE)(juAOIuDgmMZOY1JyGmyf5QY73pHsdvKQZCgFMSdJxgSO84hgmrf1HJgvgmocub7mZyoZzWV6NLpfY4LXNjmEzWIYJFyWg)pPIrN)ZGbJJavWoZmMZ4BhgVmyCeOc2zMXGvx44fcd2LcoUTbLZ1Fw7nOojkDlocub7akhanDafIiNTnOCU(ZAVb1jrPBjAzWIYJFyWnOCU(ZAVb1jrPZCgFMNXldghbQGDMzmy1foEHWGRprbkMUnhx11v)IuOfhbQGDaLdGcrKZ2CCvxx9lsHwIwgSO84hgS6NLpfQ9guxBJl8kZz8zkmEzW4iqfSZmJbRUWXlegmQkrBfTYqUEWTWb0nBauuvI2kARFro9GBHZGfLh)WGRUC54qMZ4Z0mEzW4iqfSZmJbRUWXlegmQkrBfTYqUEWTWb0nBauuvI2kAleJC6b3cNblkp(HbNCI3WCgF8agVmyCeOc2zMXGvx44fcd2LcoUTbLZ1Fw7nOojkDlocub7akhafIiNTnOCU(ZAVb1jrPBjAzWIYJFyWQFw(uO2BqDTnUWRmNXNPMXldghbQGDMzmy1foEHWGDPGJBBq5C9N1EdQtIs3IJavWoGYbqv)x6FYyBq5C9N1EdQtIs3EOHetfq3fqnX0myr5Xpmy1plFku7nOU2gx4vMZ4JhY4LbJJavWoZmgS6chVqyWPdOUuWXTnOCU(ZAVb1jrPBXrGkyNblkp(HbR(z5tHAVb1124cVYCMZGvQFw(uiJxgFMW4Lblkp(HbRexN)ZGbJJavWoZmMZ4BhgVmyCeOc2zMXGvx44fcd2LcoUTbLZ1Fw7nOojkDlocub7akhanDafIiNTnOCU(ZAVb1jrPBjAzWIYJFyWnOCU(ZAVb1jrPZCgFMNXldghbQGDMzmy1foEHWGRprbkMUnhx11v)IuOfhbQGDaLdGcrKZ2CCvxx9lsHwIwgSO84hgS6NLpfQ9guxBJl8kZz8zkmEzW4iqfSZmJbRUWXlegSlfCCBdkNR)S2BqDsu6wCeOc2buoakeroBBq5C9N1EdQtIs3s0YGfLh)WGv)S8PqT3G6ABCHxzoJptZ4LbJJavWoZmgS6chVqyWUuWXTnOCU(ZAVb1jrPBXrGkyhq5aOQ)l9pzSnOCU(ZAVb1jrPBp0qIPcO7cOMyAgSO84hgS6NLpfQ9guxBJl8kZz8Xdy8YGXrGkyNzgdwDHJxim40buxk442guox)zT3G6KO0T4iqfSZGfLh)WGv)S8PqT3G6ABCHxzoZzWFsjbLfKXlJpty8YGXrGkyNzgdwDHJxim40buiIC2A8)KkgD(pdlrldwuE8dd24)jvm68FgmNX3omEzW4iqfSZmJbRUWXlegSlfCCBdkNR)S2BqDsu6wCeOc2buoaA6akeroBBq5C9N1EdQtIs3s0YGfLh)WGBq5C9N1EdQtIsN5m(mpJxgSO84hgC1LRsCKqgmocub7mZyoJptHXldghbQGDMzmy1foEHWGRprbkMUnhx11v)IuOfhbQGDgSO84hgS6NLpfQ9guxBJl8kZz8zAgVmyCeOc2zMXGvx44fcdUFer3(jLeuwqnekhdwuE8ddgnA)e80q)0zoJpEaJxgmocub7mZyWQlC8cHbVgqthq7VBLU06XcQRjYzO7IHqcTEOsfdjaLdGMoGkkp(XkDP1JfuxtKZq3fdHeAJrNlbPghq5aORb00b0(7wPlTESG6AICg6gukwpuPIHeGUzdG2F3kDP1JfuxtKZq3GsXEOHetfq3fqnpGUcq3Sbq7VBLU06XcQRjYzO7IHqcTvxuPa0TbuZdOCa0(7wPlTESG6AICg6UyiKq7HgsmvaDBa10akhaT)Uv6sRhlOUMiNHUlgcj06HkvmKa0vmyr5XpmyPlTESG6AICgmNXNPMXldghbQGDMzmyr5Xpm4kXKJdzWQlC8cHbFy(WAJavqgSICvb1UCKqVY4ZeMZ4JhY4LbJJavWoZmgSO84hgSX)tooKbRUWXleg8H5dRncubb0nBauiIC2sskIYdLMeHC9qglrldwrUQGAxosOxz8zcZz8T1y8YGXrGkyNzgdwDHJximy1VGJmUDcsnUoliGYbqrvjAROvgY1dUfodwuE8ddU6YLJdzoJpt4jJxgmocub7mZyWQlC8cHbNoGQ(fCKXTtqQX1zbbuoakQkrBfTYqUEWTWzWIYJFyWjN4nmNXNjMW4LbJJavWoZmgS6chVqyWRbuiIC2IQs0wrDHyKZs0cOB2aOqe5SfvLOTI66xKZs0cORyWIYJFyWQFw(uO2BqDTnUWRmNXNj7W4LbJJavWoZmgS6chVqyWRbuuvI2kAJrxig5a0nBauuvI2kARFro9GBHdORa0nBa01akQkrBfTXOleJCakhafIiNTvxUkXrc1Or7NGNboUUqmYzjAb0vmyr5Xpm4QlxooK5m(mX8mEzWIYJFyWjN4nmyCeOc2zMXCMZCg8cE14hgF7WZDmHNMAEYdzWjYnXqQYGnvgT)5yhqnXeavuE8dGwIQxTG9m427ZrbzWMR5cOBfeY1dza0TShr0b7nxZfq3tuihq5HKbO7WZD4jypyV5AUa6wTrgsyDldyV5AUaQ5mGAQg1FT)jocOBvX5FR8)tQya02l(l8aRa66idOv09yibOrfqvnOkf2xzb7nxZfqnNbut1O(R9pXra9B94ha1FaT2ezhqx)hGoVVcqHW8FiGUv)z5tHwWEWEZfqnN2cur4yhqHW8FiGQEdiXbuiKumvlGUvsPWwVcOZpMZnYzKjkaQO84NkG(tHClyVO84NQT9q1BajEAC5pvm9d76ABCHxb7fLh)uTThQEdiXtJl)T3NuilYCHiYzRsCD(pdlrlN(reDRs8euwqnekhyVO84NQT9q1BajEAC5VbLZ1Fw7nOojkDYImxxk442guox)zT3G6KO0T4iqfSZzD)iIUvjEcklOgcLJderoBvIRZ)zyjA3SPFer3(jLeuwqnekhhiIC2A8)KkgD(pdlr7Mnqe5S14)jvm68FgwIwoUuWXTqsrgfQLCoMWj3IJavW(kWEr5XpvB7HQ3as804YpekNo)NbzrMB6qe5SvgY15)mSeTCwVo9(reD7Nusqzb1qOCCsVFer3QepbLfudHYTIZ60v)coY42ji146SGRwTzZ61P3pIOB)KscklOgcLJt69Ji6wL4jOSGAiuUvCwR(fCKXTtqQX1zb54sbh3Ey1)t84hTKZXeo5wCeOc2xTzJ6xWrg3UGJ3q(TcSxuE8t12EO6nGepnU8NCI3qwK5crKZwJ)NuXOZ)zyjA50pIOB)KscklOgcLJt6QFbhzC7eKACDwqWEr5XpvB7HQ3as804YF1LlhhswK5crKZwJ)NuXOZ)zyjA50pIOB)KscklOgcLJJ6xWrg3obPgxNfeSxuE8t12EO6nGepnU8NlyTrDs2jlYCRprbkMUTLO6efuJhrRh)yXrGkyFZM6tuGIPBx(I4rb11VSGJBXrGkyNSyC8oIwxhggypeh5AczX44DeTUMu5HKcxtilghVJO11rMB9jkqX0TlFr8OG66xwWXb7b7nxa1CAlqfHJDafxWJCa1ddeq9geqfL)hGgvavwKOiqf0c2lkp(PYTMIOu0qsTbSxuE8tnnU8turD4ObzJyGC3YFNyiHXD6ow9yiVQvsPqwK5MoeroBBVpPyjAb7fLh)utJl)evuhoAujlYCthIiNTT3NuSeTG9IYJFQPXL)23JFilYCxVETlfCCBdkNR)S2BqDsu6wCeOc25arKZ2guox)zT3G6KO0TeTR4SUFer3QepbLfudHYTzt)iIU9tkjOSGAiuUvCshIiNTT3NuSeTR2Sz9AiIC2cHxfVuAiuolr7Mnqe5SngLCJ4XpAseY1dz0FwtC1xzjAxXzD69Ji6wL4jOSGAiuooP3pIOB)KscklOgcLB1QvG9MR5cOBvXtqzjgsaQO84haTevhqtIsbqHqa9KbqJmzaQHmKki)EZj1gavoeq)bqvDYa0tiHaAubuiS8jaQPWtYa0TeEPauz6aAmk5gXJFau5qaT)jdGkthq3kiKIO8qbOKiKRhYaOqe5mGgvaDEhqfLhliza6FaAKjdqtqZXHaAmaQs88FgaQmDafh8iroGgvavG(feq3X0KbO8yhGgzanbb0gzbbuVbbuEmXBa0cscNUCKdOipIiABXozaQ3GaAhHiYzaTetkSdO(dOHdOrfqN3buIwavMoGIdEKihqJkGkq)ccO7WtY4XoanYaAcAooeqtr(fYaOY0buZjJ2pbpaf6NoGQ(V0)KbqJkGs0cOY0buCqJaRaQCiGgtgV4pa1FaDhlyV5AUaQO84NAAC5)igTO84hDjQozJyGCvINGYcswK52pIOBvINGYcQHq54SET6)s)tgR3CsTrdHYzp0qIPUlp5O(V0)KXAidPcAp0qIPUlp50F3A8)KJdThAiXu3LljvpnEAnnNtiHBBk8KderoBJrj3iE8JMeHC9qg9N1ex9v2(NmCGiYzleEv8sPHq5S9pz4arKZwssruEO0KiKRhYy7FYSAZM1qe5SvjUo)NHLOLdo4rI8D3X0R2SzD)D7jPq7H5dRncub50F3ErR9W8H1gbQGR2Sz9rmy(psO9fVr)zT3GAS0Xt3pIOBrEer02IDoPdrKZ2x8g9N1EdQXshpD)iIULOLZAiIC2QexN)ZWs0Ybh8ir(U7WZvCGiYzBdkNR)S2BqDsu62dnKyQBZ1eEUAZM1QFbhzCBkYVqgoQ)l9pzSOr7NGNg6NU9qdjM62CnHJO8yb14Ggbw3ENvB2SgIiNTnOCU(ZAVb1jrPBjA5GdEKiF3TgpxTcSxuE8tnnU8FeJwuE8JUevNSrmqUkXtqzbjR6xOCUMqwK52pIOBvINGYcQHq54arKZwL468FgwIwWEZ1CbuESKscklXqcqfLh)aOLO6aAsukakecONmaAKjdqnKHub53BoP2aOYHa6paQQtgGEcjeqJkGcHLpbqnX0KbOBj8sbOY0b0yuYnIh)aOYHaA)tgavMoGUvqifr5HcqjrixpKbqHiYzanQa68oGkkpwqlGYJDaAKjdqtqZXHaAmaQX)tQya08FgaQmDaTsm54qanQa6H5dRncubjdq5XoanYaAccOnYccOEdcO8yI3aOfKeoD5ihqrEer02IDYauVbb0ocrKZaAjMuyhq9hqdhqJkGoVdOeTwESdqJmGMGMJdb0uKFHmaQmDa1CYO9tWdqH(PdOQ)l9pza0OcOeTaQmDafh0iWkGkhcOqy5ta0Didq)dqJmGMGMJdbu(csnoGMfeqLPdOB1Fw(uiGQ6aAubuIwlyV5AUaQO84NAAC5)igTO84hDjQozJyGC)KscklizrMB)iIU9tkjOSGAiuooRxR(V0)KX6nNuB0qOC2dnKyQ7YtoQ)l9pzSgYqQG2dnKyQ7YtoNqc3EhEYbIiNTXOKBep(X2)KHderoBHWRIxknekNT)jZQnBwdrKZwJ)NuXOZ)zyjA50F3wjMCCO9W8H1gbQGR2SzneroBn(FsfJo)NHLOLderoBBq5C9N1EdQtIs3s0UAZM1qe5S14)jvm68FgwIwoRHiYzlQkrBf1fIrolr7Mnqe5SfvLOTI66xKZs0UIt6hXG5)iH2x8g9N1EdQXshpD)iIUf5rerBl2xTzZ6JyW8FKq7lEJ(ZAVb1yPJNUFer3I8iIOTf7CshIiNTV4n6pR9guJLoE6(reDlr7QnBwR(fCKXTtqQX1zb5O(V0)KXQ(z5tHAVb1124cVAp0qIPUnxtwTzZA1VGJmUnf5xidh1)L(Nmw0O9tWtd9t3EOHetDBUMWruESGACqJaRBVZQvG9IYJFQPXL)Jy0IYJF0LO6KnIbY9tkjOSGKv9luoxtilYC7hr0TFsjbLfudHYXbIiNTg)pPIrN)ZWs0c2BUaQPkdOjiG2iliGU1tUsobqlijC6YroGI8iIOTf7aQmDafskYOqavY5ycNCavQaQaOUuWXb0eeqRjHRAa0y8hqn(FsfdGM)ZaqtAWbxWdq9geqlKRKtauiICgqJkGkoG(hGcHLpbq3bqROcSxuE8tnnU8FeJwuE8JUevNSrmqUfYvYjpzrM761hXG5)iH2c5k5KQoxq0JHKMujmAROf5rerBl2xXzTlfCClKuKrHAjNJjCYT4iqfSVIZAiIC2wixjNu15cIEmK0KkHrBfTeTR4SgIiNTfYvYjvDUGOhdjnPsy0wr7Hgsm1T5UZQvG9MlGAQYaAccOnYccOB9KRKta0cscNUCKdOipIiABXoGkthqZ4jfavY5ycNCavQaQaOUuWXb0eeqRjHRAa0y8hqZ4jfan)NbGM0GdUGhG6niGwixjNaOqe5mGgvavCa9pafclFcGUdGwrfyVO84NAAC5)igTO84hDjQozJyGClKRKtuKfzURxFedM)JeAlKRKtQ6CbrpgsAsLWOTIwKhreTTyFfN1UuWXTz8KIwY5ycNClocub7R4SgIiNTfYvYjvDUGOhdjnPsy0wrlr7koRHiYzBHCLCsvNli6XqstQegTv0EOHetDBU7SAfyV5cOMQmGMGMJdbubqNGuJNfeqLPdOjiG2)XC4aAImoG6pGQepbLfK)pPKGYcsgGkthqtqaTrwqafskYOq(Z4jfavY5ycNCa1Lcoo2jdq36AWbxWdqv)S8Pqav1b0OcOeTaAccO1KWvnaAm(dOsoht4KdO5)mau)buLuDanCYa0g8qa14)jvmaA(pdlyVO84NAAC5)igTO84hDjQozJyGCF1plFkKSiZTIUhdPQT2ezxN)tR(z5tHCwV2LcoUfskYOqTKZXeo5wCeOc2xXzD69Ji6wL4jOSGAiuUvCwNE)iIU9tkjOSGAiuUvCwR(fCKXTtqQX1zb5O(V0)KXQ(z5tHAVb1124cVAp0qIPUnxtwTcS3CbutvgqtqZXHaQaOtqQXZccOY0b0eeq7)yoCanrghq9hqvINGYcY)NusqzbjdqLPdOjiG2iliGcjfzui)z8KcGk5CmHtoG6sbhh7KbOBDn4Gl4bOQFw(uiGQ6aAubuIwanbb0As4Qgang)bujNJjCYb08FgaQ)aQsQoGgozaAdEiGQep)NbGM)ZWc2lkp(PMgx(pIrlkp(rxIQt2igixL6NLpfswK5wr3JHu1wBISRZ)Pv)S8PqoRx7sbh3MXtkAjNJjCYT4iqfSVIZ607hr0TkXtqzb1qOCR4So9(reD7Nusqzb1qOCR4Sw9l4iJBNGuJRZcYr9FP)jJv9ZYNc1EdQRTXfE1EOHetDBUMSAfyVO84NAAC5xjLIwuE8JUevNSrmqUgHhKep(bSxuE8tnnU8FeJwuE8JUevNSrmqUqOCG9G9IYJFQwiuoUqOC68FgKfzUPdrKZwiuoD(pdlrlyVO84NQfcLlnU83GY56pR9guNeLozrMRlfCCBdkNR)S2BqDsu6wCeOc25S2LcoUfskYOqTKZXeo5wCeOc2xXr9l4iJBxWXBi)a7fLh)uTqOCPXLFJ)NCCizrM761qe5SLKueLhknjc56HmwI2vCeLhlOgh0iW627SAZM1RHiYzljPikpuAseY1dzSeTR4KE)DRX)too06HkvmK4ikpwqnoOrG1DnHJlhj0TEyGA)19a31KDwb2lkp(PAHq5sJl)g)p54qYIm3193Tg)p54q7Hgsm1T5AEoRHiYzljPikpuAseY1dzSeTR4ikpwqnoOrG1DnnhxosOB9Wa1(R7bURj7ScSxuE8t1cHYLgx(n(FYXHKfzURpmFyTrGkihr5XcQXbncSU9oCC5iHU1ddu7VUh4UMSZQnBwNE)DRX)too06HkvmK4ikpwqnoOrG1DnHJlhj0TEyGA)19a31KDwb2lkp(PAHq5sJl)NSGZtu15dNTe5G9IYJFQwiuU04YV6NLpfQ9guxBJl8kzrMB69Ji6wL4jOSGAiuooP3pIOB)KscklOgcLdSxuE8t1cHYLgx(HWRIxknekhzrM7AiIC2EYcoprvNpC2sKBjA3SjD1VGJmUDbhVH8BfyVO84NQfcLlnU8hJsUr84hYIm31qe5S9KfCEIQoF4SLi3s0Uzt6QFbhzC7coEd53kWEr5XpvlekxAC5hcVkEPIHezrM7AiIC2cHxfVuAiuolr7Mnqe5SngLCJ4XpAseY1dz0FwtC1xzjAxb2lkp(PAHq5sJl)sxA9yb11e5milYCxNE)DR0LwpwqDnrodDxmesO1dvQyiXjDr5XpwPlTESG6AICg6UyiKqBm6Cji14CwNE)DR0LwpwqDnrodDdkfRhQuXqAZM(7wPlTESG6AICg6guk2dnKyQ7A(vB20F3kDP1JfuxtKZq3fdHeARUOsTT550F3kDP1JfuxtKZq3fdHeAp0qIPUTP50F3kDP1JfuxtKZq3fdHeA9qLkgsRa7fLh)uTqOCPXLFV5KAJgcLJmxosORJm3dZhwBeOcUzt)DR3CsTrdHYzRUOsTT53SzD)DR3CsTrdHYzRUOsTTPW5igm)hj0wiYzjMmrf7A0a6efArEer02I9vB2ikpwqnoOrG1D5AkG9IYJFQwiuU04YVHmKkizrM7jKqBhZHk8DnHNCQO7XqQAnKHub1g)HG9IYJFQwiuU04YFUG1g1jzNSiZT(efOy62wIQtuqnEeTE8JfhbQGDoRxR(V0)KX6nNuB0qOC2dnKyQ7YtoQ)l9pzSgYqQG2dnKyQ7YZvCw3F3A8)KJdThAiXu3LR5xXzneroBJrj3iE8JMeHC9qg9N1ex9v2(NmCGiYzleEv8sPHq5S9pz4arKZwssruEO0KiKRhYy7FYSA1Mn1NOaft3U8fXJcQRFzbh3IJavWozX44DeTUommWEioY1eYIXX7iADnPYdjfUMqwmoEhrRRJm36tuGIPBx(I4rb11VSGJZzT6)s)tgR3CsTrdHYzp0qIPUlp5O(V0)KXAidPcAp0qIPUlpxb2lkp(PAHq5sJl)1KOfjlYCHiYzBmk5gXJF0KiKRhYO)SM4QVY2)KHderoBHWRIxknekNT)jdhr5XcQXbncSUlxtbSxuE8t1cHYLgx(neIczrMleroBJrj3iE8JLOLJO8yb14Ggbw3ENnBGiYzleEv8sPHq5SeTCeLhlOgh0iW627a2lkp(PAHq5sJl)gcrHSiZDneroBRYIqc1Q3asCzCB1fvQD5AYkoRHiYzR)V3OLPRvfjXs0UIderoBJrj3iE8JLOLJO8yb14Ggbw5UdyVO84NQfcLlnU8BidPcswK5crKZ2yuYnIh)yjA5ikpwqnoOrG1T5AEWEr5XpvlekxAC53qikKfzURxVgIiNT()EJwMUwvKeB1fvQD5UZQnBwdrKZw)FVrltxRksILOLderoB9)9gTmDTQij2dnKyQBBI10R2SzneroBRYIqc1Q3asCzCB1fvQD5A(vR4ikpwqnoOrG1Tn)kWEr5XpvlekxAC53BoP2OHq5ilYCfLhlOgh0iW6UMa2lkp(PAHq5sJl)gYqQGKfzURxFcjC7TgpxXruESGACqJaRBB(vB2SE9jKWT5HMEfhr5XcQXbncSUT554sbh3wFII(ZAVb15)WQBXrGkyFfyVO84NQfcLlnU83suwWl2sizkYvfu7Yrc9kxtilYC7VB9MtQnAiuoB1fvQD3bSxuE8t1cHYLgx(9MtQnAiuoWEr5XpvlekxAC53qikKfzUIYJfuJdAeyDBZd2lkp(PAHq5sJl)1KOf1qOCG9IYJFQwiuU04YFC)KjoYIm3tiH2oMdv4BBk8KderoBJ7NmXzp0qIPUnpTMgShSxuE8t1AeEqs84hUX9tM4ilYCJr9gXqs3fdHeQnDD34(jtC6UyiKqT3CyT5lDoqe5SnUFYeN9qdjM62MNhVrQoc2lkp(PAncpijE8tAC5)WbtKczrMRltQyiXPbLI3yBv(28atd2lkp(PAncpijE8tAC5pF4SLcSRpKeo4jE8dzrMRltQyiXPbLI3yBv(28atd2lkp(PAncpijE8tAC5hnA)e80q)0jlYCxNE)iIUvjEcklOgcLJt69Ji62pPKGYcQHq5wTzJO8yb14Ggbw3L7oG9IYJFQwJWdsIh)Kgx(HKlvnvmKfzUUmPIHeNgukEJTv5BBQnnNyuVrmK0DXqiHAtx3LNwt4XBqP4nwdzla7fLh)uTgHhKep(jnU8xjULyrk6yQEmkVswK5crKZ2kXTelsrht1Jr5vB)tgoqe5SfsUu1uXy7FYWPbLI3yBv(28aEYjg1BedjDxmesO201D5PDhtZJ3GsXBSgYwa2d2lkp(PAv)x6FYu52(E8dyVO84NQv9FP)jtnnU8dv(VRZeh5G9IYJFQw1)L(Nm104YpeEv8sfdjWEr5XpvR6)s)tMAAC5xoLmO2)7WXb7fLh)uTQ)l9pzQPXL)sqQXR6TCIojdCCWEr5XpvR6)s)tMAAC5phhcv(Vd2lkp(PAv)x6FYutJl)YOWQFsrRKsbSxuE8t1Q(V0)KPMgx(HUO6LyiPZehzrMleroBHq505)mSeTG9IYJFQw1)L(Nm104YFmk5gXJFilYCx3F3A8)KJdTEOsfdPnBeLhlOgh0iW6UMSIt)DR3CsTrdHYz9qLkgsG9IYJFQw1)L(Nm104YpeEv8sb2lkp(PAv)x6FYutJl)evuhoAqgMZOY1JyGCvKRkVF)eknurQoyVO84NQv9FP)jtnnU8turD4OrfShSxuE8t1QepbLfKB79jfWEr5XpvRs8euwW04YVsCD(pdYIm30HiYzRsCD(pdlrlyVO84NQvjEcklyAC5)KuizrMleroBBVpPyjAb7fLh)uTkXtqzbtJl)nOCU(ZAVb1jrPtwK56sbh32GY56pR9guNeLUfhbQGDoPdrKZ2guox)zT3G6KO0TeTG9IYJFQwL4jOSGPXLF0O9tWtd9tNSiZTFer3QepbLfudHYb2lkp(PAvINGYcMgx(pjfswK52F3Esk0Ey(WAJavqoQ3a61TFmEDBtbSxuE8t1QepbLfmnU8FrlzrMB)D7fT2dZhwBeOcYr9gqVU9JXR7Y1ua7fLh)uTkXtqzbtJl)QFw(uO2BqDTnUWRKfzU9Ji6wL4jOSGAiuoWEr5XpvRs8euwW04YFgVxfprvdfosMHSfACWJe5CnHSiZv9gqVU9JXR7Y1ua7fLh)uTkXtqzbtJl)sxA9yb11e5milYCxNE)DR0LwpwqDnrodDxmesO1dvQyiXjDr5XpwPlTESG6AICg6UyiKqBm6Cji14CwNE)DR0LwpwqDnrodDdkfRhQuXqAZM(7wPlTESG6AICg6guk2dnKyQ7A(vB20F3kDP1JfuxtKZq3fdHeARUOsTT550F3kDP1JfuxtKZq3fdHeAp0qIPUTP50F3kDP1JfuxtKZq3fdHeA9qLkgsRa7fLh)uTkXtqzbtJl)5cwBuNKDYIm36tuGIPBBjQorb14r06XpwCeOc25GdEKiFBZB6nBQprbkMUD5lIhfux)YcoUfhbQGDYIXX7iADDyyG9qCKRjKfJJ3r06AsLhskCnHSyC8oIwxhzU1NOaft3U8fXJcQRFzbhNdo4rI8TnVPb7fLh)uTkXtqzbtJl)1Md7KfzUQ3a61TFmE1QiUdhFBtd2d2lkp(PAvQFw(uixL468FgG9IYJFQwL6NLpfMgx(Bq5C9N1EdQtIsNSiZ1LcoUTbLZ1Fw7nOojkDlocub7CshIiNTnOCU(ZAVb1jrPBjAb7fLh)uTk1plFkmnU8R(z5tHAVb1124cVswK5wFIcumDBoUQRR(fPqlocub7CGiYzBoUQRR(fPqlrlyVO84NQvP(z5tHPXLF1plFku7nOU2gx4vYImxxk442guox)zT3G6KO0T4iqfSZbIiNTnOCU(ZAVb1jrPBjAb7fLh)uTk1plFkmnU8R(z5tHAVb1124cVswK56sbh32GY56pR9guNeLUfhbQGDoQ)l9pzSnOCU(ZAVb1jrPBp0qIPURjMgSxuE8t1Qu)S8PW04YV6NLpfQ9guxBJl8kzrMB6UuWXTnOCU(ZAVb1jrPBXrGkyhShSxuE8t1wixjNO4QexN)ZaShSxuE8t1wixjN8Cn(FsfJo)NbypyVO84NQ9v)S8PqUg)pPIrN)ZaSxuE8t1(QFw(uyAC5VbLZ1Fw7nOojkDYImxxk442guox)zT3G6KO0T4iqfSZjDiIC22GY56pR9guNeLULOfSxuE8t1(QFw(uyAC5x9ZYNc1EdQRTXfELSiZT(efOy62CCvxx9lsHwCeOc25arKZ2CCvxx9lsHwIwWEr5Xpv7R(z5tHPXL)QlxooKSiZfvLOTIwzixp4w4B2GQs0wrB9lYPhClCWEr5Xpv7R(z5tHPXL)Kt8gYImxuvI2kALHC9GBHVzdQkrBfTfIro9GBHd2lkp(PAF1plFkmnU8R(z5tHAVb1124cVswK56sbh32GY56pR9guNeLUfhbQGDoqe5STbLZ1Fw7nOojkDlrlyVO84NQ9v)S8PW04YV6NLpfQ9guxBJl8kzrMRlfCCBdkNR)S2BqDsu6wCeOc25O(V0)KX2GY56pR9guNeLU9qdjM6UMyAWEr5Xpv7R(z5tHPXLF1plFku7nOU2gx4vYIm30DPGJBBq5C9N1EdQtIs3IJavWoypyVO84NQ9tkjOSGCn(FsfJo)NbzrMB6qe5S14)jvm68FgwIwWEr5Xpv7NusqzbtJl)nOCU(ZAVb1jrPtwK56sbh32GY56pR9guNeLUfhbQGDoPdrKZ2guox)zT3G6KO0TeTG9IYJFQ2pPKGYcMgx(RUCvIJec2lkp(PA)KscklyAC5x9ZYNc1EdQRTXfELSiZT(efOy62CCvxx9lsHwCeOc2b7fLh)uTFsjbLfmnU8JgTFcEAOF6KfzU9Ji62pPKGYcQHq5a7fLh)uTFsjbLfmnU8lDP1JfuxtKZGSiZDD693TsxA9yb11e5m0DXqiHwpuPIHeN0fLh)yLU06XcQRjYzO7IHqcTXOZLGuJZzD693TsxA9yb11e5m0nOuSEOsfdPnB6VBLU06XcQRjYzOBqPyp0qIPUR5xTzt)DR0LwpwqDnrodDxmesOT6Ik12MNt)DR0LwpwqDnrodDxmesO9qdjM62MMt)DR0LwpwqDnrodDxmesO1dvQyiTcSxuE8t1(jLeuwW04YFLyYXHKPixvqTlhj0RCnHSiZ9W8H1gbQGG9IYJFQ2pPKGYcMgx(n(FYXHKPixvqTlhj0RCnHSiZ9W8H1gbQGB2arKZwssruEO0KiKRhYyjAb7fLh)uTFsjbLfmnU8xD5YXHKfzUQFbhzC7eKACDwqoOQeTv0kd56b3chSxuE8t1(jLeuwW04YFYjEdzrMB6QFbhzC7eKACDwqoOQeTv0kd56b3chSxuE8t1(jLeuwW04YV6NLpfQ9guxBJl8kzrM7AiIC2IQs0wrDHyKZs0UzderoBrvjAROU(f5SeTRa7fLh)uTFsjbLfmnU8xD5YXHKfzURrvjAROngDHyKBZguvI2kARFro9GBHVAZM1OQeTv0gJUqmYXbIiNTvxUkXrc1Or7NGNboUUqmYzjAxb2lkp(PA)KscklyAC5p5eVHbxBrfJpt4PPWCMZya]] )


end