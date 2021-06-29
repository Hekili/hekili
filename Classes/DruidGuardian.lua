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

    spec:RegisterPack( "Guardian", 20210629, [[dCeOKbqiQu9iLk0MqfFcvr1OuIoLsyvujr9kQuMfuLBrLezxu6xOQmmsL6yujwMsINrLutdvHUgPs2Msf5BujHXPur5COkkRdvrsZtjP7HkTpLkDqufalKuXdvQOAIkvq5IOks9rLkiNevrSsLQMjQIe3evbODIQ0prvGEkOMkuvFfvb0Er5VumyihMyXG8ysMSuUmYMPQpdvgTKCArRwPcQEnPQzlv3Mu2TIFRYWLuhhvbTCv9CjMUW1HY2vkFNkgpvs68OQA9kvG5RKA)aZCHHpdUjbX4DfDVIl6ENwHNzDXvOBx7cdo4VMyW1IsVGJyWJOrm4Dim5BPmm4AH)(jng(m4YH9kIbxfrDHNkF8HlJkmiR604RKAyDjYBuV4d(kPMIpgmew2dEYWGyWnjigVRO7vCr370k8mRlUcD7ADZJmyblQUNbdNA7CgCv2A0WGyWnQOyW7qyY3szaODypw2a73JneaTcpdpaAfDVIUb7b735vYGJk8ub7DLaiEYOUV(EjiaANlbF8aE3OphaQ(Z7ZiPcaTm9auHIihCauwaivfP0tTfwWExjaINmQ7RVxccGU6iVbGIdGkvPpaOL3dqZflaiiYFpbq78B2o9KLb3Zsuy4ZG78RKxog(mEDHHpdwurEddw7UrFog)9AmyAeOo1y6WcwWGHi5z4Z41fg(myAeOo1y6WGvFg0Ncd2DaccZ7TqK8g)9AwSAgSOI8ggmejVXFVgly8UcdFgSOI8gg8lB0CyfJ)PzhWpdMgbQtnMoSGXRRz4ZGPrG6uJPddw9zqFkmy3bO2JLnRschs2idejpaXbGChGApw2SNt3HKnYarYZGfvK3WGv3SD6jturMsD(zuybJxEKHpdMgbQtnMomy1Nb9PWGxcqqyEV9LnAoSIX)0Sd43IvdqRxdqUdqQBJgzc7gnrf)paTGblQiVHbdrFHE9SGXRUy4ZGPrG6uJPddw9zqFkm4LaeeM3BFzJMdRy8pn7a(Ty1a061aK7aK62OrMWUrtuX)dqlyWIkYByW5OKFKiVHfmE3jg(myAeOo1y6WGvFg0NcdEjabH59wi6l0R3arYBXQbO1RbiimV3MJs(rI8gdom5BPmMZBW(YPSy1a0cgSOI8ggme9f61NdowW41vWWNbtJa1PgthgS6ZG(uyWlbi3bO2fwPj1rUrMIJ8AMMOj4iBKk95GdG4aqUdqIkYBSstQJCJmfh51mnrtWr2Cm(EIRkaioa0saYDaQDHvAsDKBKP4iVMPIKUnsL(CWbqRxdqTlSstQJCJmfh51mvK0TpPj5uaODbixdqlaO1RbO2fwPj1rUrMIJ8AMMOj4iBjeLEaAvaY1aehaQDHvAsDKBKP4iVMPjAcoY(KMKtbGwfG0faXbGAxyLMuh5gzkoYRzAIMGJSrQ0NdoaAbdwurEddwAsDKBKP4iVgly8UZy4ZGPrG6uJPddw9zqFkm4N8pvQeOobqRxdqTlSr1lLkdejVTeIspaTka5AaA9AaAja1UWgvVuQmqK82sik9a0QaepcqCaOhBi)94iBhZ7LC8yfQzinOxuKL4HyzDn1aOfa061aKOICJm0qAjvaOD5cq8idwurEddoQEPuzGi5zbJxEgdFgmncuNAmDyWQpd6tHbVeGwcqqyEVfN0fvKkdom5BPmwSAaAbaXbGevKBKHgslPcaTkaTcaTaGwVgGwcqlbiimV3It6IksLbhM8TuglwnaTaG4aqUdqTlSA3n(8jBKk95GdG4aqIkYnYqdPLubG2fGCbG4aqH84OWgPgzIZ0scG2fGCzfaAbdwurEddw7UXNpXcgVUOBg(myAeOo1y6WGvFg0NcdEja1UWQD34ZNSpPj5uaOv5cqUgG4aqlbiimV3It6IksLbhM8TuglwnaTaG4aqIkYnYqdPLubG2fG0faXbGc5XrHnsnYeNPLeaTla5Yka0cgSOI8ggS2DJpFIfmEDXfg(myAeOo1y6WGvFg0Ncd(fCKTr(uLbaTla5IUbioauHIihCfRMm46Kr7EIblQiVHbRjdUoXcgVUScdFgmncuNAmDyWQpd6tHbVeGEY)uPsG6eaXbGevKBKHgslPcaTkaTcaXbGc5XrHnsnYeNPLeaTla5Yka0caA9AaAja5oa1UWQD34ZNSrQ0NdoaIdajQi3idnKwsfaAxaYfaIdafYJJcBKAKjotljaAxaYLvaOfmyrf5nmyT7gF(ely86IRz4ZGPrG6uJPddw9zqFkm4YH1HYPzRXkbwNm0Jvh5nwAeOo1aioa0saAjaPUR3oNXgvVuQmqK82N0KCka0UaKUbioaK6UE7CgRMm46K9jnjNcaTlaPBaAbaXbGwcqTlSA3n(8j7tAsofaAxUaKRbOfaehaAjabH592CuYpsK3yWHjFlLXCEd2xoLTDodaXbGGW8Ele9f61BGi5TTZzaioaeeM3BXjDrfPYGdt(wkJTDodaTaGwWGfvK3WG9DQuPEXhSGXRl8idFgmncuNAmDyWQpd6tHbdH592CuYpsK3yWHjFlLXCEd2xoLTDodaXbGGW8Ele9f61BGi5TTZzaioaKOICJm0qAjvaOD5cq8idwurEddU4K1KbIKNfmEDrxm8zW0iqDQX0HbR(mOpfgmeM3BZrj)irEJfRgG4aqIkYnYqdPLubGwfGwbGwVgGGW8Ele9f61BGi5Ty1aehasurUrgAiTKka0Qa0kmyrf5nmynbRZcgVUStm8zW0iqDQX0HbR(mOpfg8saccZ7TfztWrg1PbjHmHTeIspaTlxaYfaAbaXbGwcqqyEVnUlQmY0mQU4yXQbOfaehaccZ7T5OKFKiVXIvdqCairf5gzOH0sQaqCbOvyWIkYByWAcwNfmEDXvWWNbtJa1PgthgS6ZG(uyWqyEVnhL8Je5nwSAaIdajQi3idnKwsfaAvUaKRzWIkYByWAYGRtSGXRl7mg(myAeOo1y6WGvFg0NcdEjaTeGwcqqyEVnUlQmY0mQU4ylHO0dq7YfGwbGwaqRxdqlbiimV3g3fvgzAgvxCSy1aehaccZ7TXDrLrMMr1fh7tAsofaAvaYfRUaOfa061a0saccZ7TfztWrg1PbjHmHTeIspaTlxaY1a0caAbaXbGevKBKHgslPcaTka5AaAbdwurEddwtW6SGXRl8mg(myAeOo1y6WGvFg0NcdwurUrgAiTKka0UaKlmyrf5nm4O6LsLbIKNfmExr3m8zW0iqDQX0HbR(mOpfg8saAja9cocGwfG4z6gGwaqCairf5gzOH0sQaqRcqUgGwaqRxdqlbOLa0l4iaAvaANPlaAbaXbGevKBKHgslPcaTka5AaIdafsNMWwoSU58MOIm(7PsyPrG6udGwWGfvK3WG1KbxNybJ3vCHHpdMgbQtnMomyrf5nm4AS(g95oGyWQpd6tHb3UWgvVuQmqK82sik9a0Ua0kmyf)Qozc5XrrHXRlSGX7kRWWNblQiVHbhvVuQmqK8myAeOo1y6WcgVR4Ag(myAeOo1y6WGvFg0NcdwurUrgAiTKka0QaKRzWIkYByWAcwNfmExHhz4ZGfvK3WGloznzGi5zW0iqDQX0HfmExrxm8zW0iqDQX0HbR(mOpfg8l4iBJ8PkdaAvaIh1naXbGGW8EB(34XE7tAsofaAvas3wDXGfvK3WGZ)gp2ZcwWG1YiXjrEddFgVUWWNbtJa1PgthgS6ZG(uyW5OoTCWzAIMGJm6Qaq7cq5FJh7nnrtWrMO6Ps11BaehaccZ7T5FJh7TpPj5uaOvbixdqUYauLucIblQiVHbN)nESNfmExHHpdMgbQtnMomy1Nb9PWGdz0NdoaIdavrspQS1QaGwfG2jDXGfvK3WGFAihPZcgVUMHpdMgbQtnMomy1Nb9PWGdz0NdoaIdavrspQS1QaGwfG2jDXGfvK3WG9pn7GKAMNWrd9sK3WcgV8idFgmncuNAmDyWQpd6tHbVeGChGApw2SkjCizJmqK8aehaYDaQ9yzZEoDhs2idejpaTaGwVgGevKBKHgslPcaTlxaAfgSOI8ggmPvFo0BGUPXcgV6IHpdMgbQtnMomy1Nb9PWGdz0NdoaIdavrspQS1QaGwfGCf6cG4aq5OoTCWzAIMGJm6Qaq7cq626ca5kdqvK0JkRM4Qmyrf5nmyi51x0Ndly8Utm8zW0iqDQX0HbR(mOpfgmeM3Bly)wUjDtoLihvuSTZzaioaeeM3BHKxFrFo225maehaQIKEuzRvbaTkaTt6gG4aq5OoTCWzAIMGJm6Qaq7cq62UIUaixzaQIKEuz1exLblQiVHbxW(TCt6MCkroQOWcwWGvs4qYgXWNXRlm8zWIkYByW1)50zW0iqDQX0HfmExHHpdMgbQtnMomy1Nb9PWGDhGGW8ERscJ)EnlwndwurEddwjHXFVgly86Ag(myAeOo1y6WGvFg0NcdgcZ7T1)50Ty1myrf5nm4x0tSGXlpYWNbtJa1PgthgS6ZG(uyWH0PjSvK8H58MOImozVzPrG6udG4aqUdqqyEVTIKpmN3evKXj7nlwndwurEddUIKpmN3evKXj7nwW4vxm8zW0iqDQX0HbR(mOpfgC7XYMvjHdjBKbIKNblQiVHbtA1Nd9gOBASGX7oXWNbtJa1PgthgS6ZG(uyWTlSVONSp5FQujqDcG4aqQtd6m1xorbGwfG4rgSOI8gg8l6jwW41vWWNbtJa1PgthgS6ZG(uyWTlSFwBFY)uPsG6eaXbGuNg0zQVCIcaTlxaIhzWIkYByWFwZcgV7mg(myAeOo1y6WGvFg0NcdU9yzZQKWHKnYarYZGfvK3WGv3SD6jturMsD(zuybJxEgdFgmncuNAmDyWQpd6tHbRonOZuF5efaAxUaepYGfvK3WG90FQ8WkgOmigSM4QgAOhh)mEDHfmEDr3m8zW0iqDQX0HbR(mOpfg8saYDaQDHvAsDKBKP4iVMPjAcoYgPsFo4aioaK7aKOI8gR0K6i3itXrEntt0eCKnhJVN4QcaIdaTeGChGAxyLMuh5gzkoYRzQiPBJuPphCa061au7cR0K6i3itXrEntfjD7tAsofaAxaY1a0caA9AaQDHvAsDKBKP4iVMPjAcoYwcrPhGwfGCnaXbGAxyLMuh5gzkoYRzAIMGJSpPj5uaOvbiDbqCaO2fwPj1rUrMIJ8AMMOj4iBKk95GdGwWGfvK3WGLMuh5gzkoYRXcgVU4cdFgmncuNAmDyWQpd6tHbxoSouonBnwjW6KHES6iVXsJa1PgaXbGOHEC8dqRcqUwxmyrf5nmyFNkvQx8bly86Ykm8zW0iqDQX0HbR(mOpfgS60Got9LtuSkS)PjaOvbiDXGfvK3WGlvp1yblyWD(vYlkg(mEDHHpdwurEddwjHXFVgdMgbQtnMoSGfm4g5fSEWWNXRlm8zW0iqDQX0Hb3OI6Z6iVHbZt7QKclOgarB0ZpafPgbqrfbqIkUhGYcajBs2fOozzWIkYByWf9y9UbskvSGX7km8zW0iqDQX0HbR(mOpfgS7aeeM3BR)ZPBXQzWIkYByWyfYKbPvybJxxZWNbtJa1PgthgS6ZG(uyWlbOLa0sakKonHTIKpmN3evKXj7nlncuNAaehaccZ7TvK8H58MOImozVzXQbOfaehaAja1ESSzvs4qYgzGi5bO1RbO2JLn750DizJmqK8a0caIda5oabH5926)C6wSAaAbaTEnaTeGwcqqyEVfI(c96nqK8wSAaA9AaccZ7T5OKFKiVXGdt(wkJ58gSVCklwnaTaG4aqlbi3bO2JLnRschs2idejpaXbGChGApw2SNt3HKnYarYdqlaOfa0cgSOI8ggC9f5nSGXlpYWNbtJa1PgthgS6ZG(uyWThlBwLeoKSrgisEaIdabH59wLeg)9AwSAgCj(ufmEDHblQiVHb)yJrurEJPNLGb3ZsygrJyWkjCizJybJxDXWNbtJa1PgthgS6ZG(uyWThlB2ZP7qYgzGi5bioaeeM3B1UB0NJXFVMfRMbxIpvbJxxyWIkYByWp2yevK3y6zjyW9SeMr0ig850DizJybJ3DIHpdMgbQtnMom4gvuFwh5nmyEIhGCiaQs2iaINc)k5faQt4OPjp)aeXdXY6AQbqY0aiiPlJIaiX7Zjd(biPaqcafsNMaGCiaQ4KHQcGYjoas7UrFoaK)EnaYPIgAJEakQiaQZVsEbGGW8EaklaKea09aee1phaAfaQqkgSOI8gg8Jngrf5nMEwcgS6ZG(uyWlbOLa0JnK)ECKTZVsEPy8DIICWzW1tT6czjEiwwxtnaAbaXbGwcqH0PjSqsxgfzeVpNm43sJa1PgaTaG4aqlbiimV325xjVum(orro4m46PwDHSy1a0caIdaTeGGW8EBNFL8sX47ef5GZGRNA1fY(KMKtbGwLlaTcaTaGwWG7zjmJOrm4o)k5LJfmEDfm8zW0iqDQX0Hb3OI6Z6iVHbZt8aKdbqvYgbq8u4xjVaqDchnn55hGiEiwwxtnasMga5Px6aK495Kb)aKuaibGcPttaqoeavCYqvbq5eha5Px6aK)EnaYPIgAJEakQiaQZVsEbGGW8EaklaKea09aee1phaAfaQqkgSOI8gg8Jngrf5nMEwcgS6ZG(uyWlbOLa0JnK)ECKTZVsEPy8DIICWzW1tT6czjEiwwxtnaAbaXbGwcqH0PjSE6LUr8(CYGFlncuNAa0caIdaTeGGW8EBNFL8sX47ef5GZGRNA1fYIvdqlaioa0saccZ7TD(vYlfJVtuKdodUEQvxi7tAsofaAvUa0ka0caAbdUNLWmIgXG78RKxuSGX7oJHpdMgbQtnMom4gvuFwh5nmyEIhGCiE(taKaqtIRk8cbqY0aihcGA3WZdaYrMaGIdGus4qYgX350DizJWdGKPbqoeavjBeabjDzueFE6LoajEFozWpafsNMGA4bq8aROH2OhGu3SD6jas1aOSaqy1aKdbqfNmuvauoXbqI3Ntg8dq(71aO4aiLucakd8aOk6jas7UrFoaK)EnldwurEdd(XgJOI8gtplbdw9zqFkm4cfro4k2sv6dJ)EJ6MTtpbqCaOLa0sakKonHfs6YOiJ495Kb)wAeOo1aOfaehaAja5oa1ESSzvs4qYgzGi5bOfaehaAja5oa1ESSzpNUdjBKbIKhGwaqCaOLaK62OrMWojUQW4fcG4aqQ76TZzSQB2o9KjQitPo)mk2N0KCka0QCbixaOfa0cgCplHzenIbFQB2o9ely8YZy4ZGPrG6uJPddUrf1N1rEddMN4bihIN)eaja0K4QcVqaKmnaYHaO2n88aGCKjaO4aiLeoKSr8DoDhs2i8aizAaKdbqvYgbqqsxgfXNNEPdqI3Ntg8dqH0PjOgEaepWkAOn6bi1nBNEcGunaklaewna5qauXjdvfaLtCaK495Kb)aK)EnakoasjLaGYapaQIEcGus4VxdG83RzzWIkYByWp2yevK3y6zjyWQpd6tHbxOiYbxXwQsFy83Bu3SD6jaIdaTeGwcqH0PjSE6LUr8(CYGFlncuNAa0caIdaTeGChGApw2SkjCizJmqK8a0caIdaTeGChGApw2SNt3HKnYarYdqlaioa0sasDB0ityNexvy8cbqCai1D925mw1nBNEYevKPuNFgf7tAsofaAvUaKla0caAbdUNLWmIgXGvQB2o9ely86IUz4ZGPrG6uJPddwurEddwj9UrurEJPNLGb3ZsygrJyWAzK4KiVHfmEDXfg(myAeOo1y6WGfvK3WGFSXiQiVX0ZsWG7zjmJOrmyisEwWcgC9tQtdscg(mEDHHpdMgbQtnMom4gvuFwh5nmyEAxLuyb1aiiYFpbqQtdscacIWLtXcq8aOuuDuaO5gxPk518yDasurEtbGUPZVLblQiVHbRpN2tntPo)mkSGX7km8zW0iqDQX0HbR(mOpfgmeM3Bvsy83RzXQbioau7XYMvjHdjBKbIKNblQiVHbx)NtNfmEDndFgmncuNAmDyWQpd6tHb7oabH59wz434VxZIvdqCaOLaK7au7XYMvjHdjBKbIKhGwVgGGW8ERscJ)EnB7CgaAbaXbGwcqUdqThlB2ZP7qYgzGi5bO1RbiimV3QD3OphJ)EnB7CgaAbdwurEddgIK34VxJfmE5rg(myAeOo1y6WGvFg0NcdoKonHTIKpmN3evKXj7nlncuNAaehaAja1ESSzvs4qYgzGi5bioaeeM3Bvsy83RzXQbO1RbO2JLn750DizJmqK8aehaccZ7TA3n6ZX4VxZIvdqRxdqqyEVv7UrFog)9AwSAaIdafsNMWcjDzuKr8(CYGFlncuNAa0cgSOI8ggCfjFyoVjQiJt2BSGXRUy4ZGPrG6uJPddw9zqFkmyimV3QD3OphJ)EnlwnaXbGApw2SNt3HKnYarYdqCai3bi1TrJmHDsCvHXledwurEdd25LOIfmE3jg(myAeOo1y6WGvFg0NcdgcZ7TA3n6ZX4VxZIvdqCaO2JLn750DizJmqK8aehasDB0ityNexvy8cXGfvK3WGlH8(8jwW41vWWNbtJa1PgthgS6ZG(uyWLdRdLtZwJvcSozOhRoYBS0iqDQXGfvK3WG9DQuPEXhSGfmy1D925mfg(mEDHHpdwurEddU(I8ggmncuNAmDybJ3vy4ZGfvK3WGH631mESNFgmncuNAmDybJxxZWNblQiVHbdrFHE95GJbtJa1PgthwW4Lhz4ZGfvK3WGLxjdzI7FAcgmncuNAmDybJxDXWNblQiVHb3tCvrXSdhRHtJMGbtJa1PgthwW4DNy4ZGfvK3WG95tq97AmyAeOo1y6WcgVUcg(myrf5nmyzuujEPBusVZGPrG6uJPdly8UZy4ZGPrG6uJPddw9zqFkmyimV3crYB83RzXQzWIkYByWqFwIEo4mESNfmE5zm8zW0iqDQX0HbR(mOpfg8saQDHv7UXNpzJuPphCa061aKOICJm0qAjvaODbixaOfaehaQDHnQEPuzGi5TrQ0NdogSOI8ggCok5hjYBybJxx0ndFgSOI8ggme9f61ZGPrG6uJPdly86Ilm8zW0iqDQX0HblQiVHbR4x1V4VjvgOUucgm59KkmJOrmyf)Q(f)nPYa1LsWcgVUScdFgSOI8ggmwHmzqAfgmncuNAmDyblyWN6MTtpXWNXRlm8zWIkYByWA3n6ZX4VxJbtJa1PgthwW4Dfg(myAeOo1y6WGvFg0NcdoKonHTIKpmN3evKXj7nlncuNAaehaYDaccZ7TvK8H58MOImozVzXQzWIkYByWvK8H58MOImozVXcgVUMHpdMgbQtnMomy1Nb9PWGlhwhkNM1NFjmL4t9KLgbQtnaIdabH59wF(LWuIp1twSAgSOI8ggS6MTtpzIkYuQZpJcly8YJm8zW0iqDQX0HbR(mOpfgmP6zDHSYWVzixnaO1Rbis1Z6czlxxEZqUAWGfvK3WGlH8(8jwW4vxm8zW0iqDQX0HbR(mOpfgmP6zDHSYWVzixnaO1Rbis1Z6cz7yJ8MHC1GblQiVHb78suXcgV7edFgmncuNAmDyWQpd6tHbhsNMWwrYhMZBIkY4K9MLgbQtnaIdabH592ks(WCEturgNS3Sy1myrf5nmy1nBNEYevKPuNFgfwW41vWWNbtJa1PgthgS6ZG(uyWH0PjSvK8H58MOImozVzPrG6udG4aqQ76TZzSvK8H58MOImozVzFstYPaq7cqUOlgSOI8ggS6MTtpzIkYuQZpJcly8UZy4ZGPrG6uJPddw9zqFkmy3bOq60e2ks(WCEturgNS3S0iqDQXGfvK3WGv3SD6jturMsD(zuyblyWk1nBNEIHpJxxy4ZGfvK3WGvsy83RXGPrG6uJPdly8UcdFgmncuNAmDyWQpd6tHbhsNMWwrYhMZBIkY4K9MLgbQtnaIda5oabH592ks(WCEturgNS3Sy1myrf5nm4ks(WCEturgNS3ybJxxZWNbtJa1PgthgS6ZG(uyWLdRdLtZ6ZVeMs8PEYsJa1PgaXbGGW8ERp)sykXN6jlwndwurEddwDZ2PNmrfzk15NrHfmE5rg(myAeOo1y6WGvFg0NcdoKonHTIKpmN3evKXj7nlncuNAaehaccZ7TvK8H58MOImozVzXQzWIkYByWQB2o9KjQitPo)mkSGXRUy4ZGPrG6uJPddw9zqFkm4q60e2ks(WCEturgNS3S0iqDQbqCai1D925m2ks(WCEturgNS3SpPj5uaODbix0fdwurEddwDZ2PNmrfzk15NrHfmE3jg(myAeOo1y6WGvFg0Ncd2DakKonHTIKpmN3evKXj7nlncuNAmyrf5nmy1nBNEYevKPuNFgfwWcg850DizJy4Z41fg(myAeOo1y6WGvFg0Ncd2DaccZ7TA3n6ZX4VxZIvZGfvK3WG1UB0NJXFVgly8UcdFgmncuNAmDyWQpd6tHbhsNMWwrYhMZBIkY4K9MLgbQtnaIda5oabH592ks(WCEturgNS3Sy1myrf5nm4ks(WCEturgNS3ybJxxZWNblQiVHbxc5lypoIbtJa1PgthwW4Lhz4ZGPrG6uJPddw9zqFkm4YH1HYPz95xctj(upzPrG6uJblQiVHbRUz70tMOImL68ZOWcgV6IHpdMgbQtnMomy1Nb9PWGBpw2SNt3HKnYarYZGfvK3WGjT6ZHEd0nnwW4DNy4ZGPrG6uJPddw9zqFkm4LaK7au7cR0K6i3itXrEntt0eCKnsL(CWbqCai3birf5nwPj1rUrMIJ8AMMOj4iBogFpXvfaehaAja5oa1UWknPoYnYuCKxZurs3gPsFo4aO1RbO2fwPj1rUrMIJ8AMks62N0KCka0UaKRbOfa061au7cR0K6i3itXrEntt0eCKTeIspaTka5AaIda1UWknPoYnYuCKxZ0enbhzFstYPaqRcq6cG4aqTlSstQJCJmfh51mnrtWr2iv6ZbhaTGblQiVHblnPoYnYuCKxJfmEDfm8zW0iqDQX0HblQiVHbxWgF(edw9zqFkm4N8pvQeOoXGv8R6KjKhhffgVUWcgV7mg(myAeOo1y6WGfvK3WG1UB85tmy1Nb9PWGFY)uPsG6eaTEnabH59wCsxurQm4WKVLYyXQzWk(vDYeYJJIcJxxybJxEgdFgmncuNAmDyWQpd6tHbRUnAKjStIRkmEHaioaeP6zDHSYWVzixnyWIkYByWLqEF(ely86IUz4ZGPrG6uJPddw9zqFkmy3bi1TrJmHDsCvHXleaXbGivpRlKvg(nd5QbdwurEdd25LOIfmEDXfg(myAeOo1y6WGvFg0NcdEjabH59ws1Z6cz6yJ8wSAaA9AaccZ7TKQN1fYuUU8wSAaAbdwurEddwDZ2PNmrfzk15NrHfmEDzfg(myAeOo1y6WGvFg0NcdEjarQEwxiBoMo2ipaTEnarQEwxiB56YBgYvdaAbaTEnaTeGivpRlKnhthBKhG4aqqyEVTeYxWECKH0Qph61OjmDSrElwnaTGblQiVHbxc595tSGXRlUMHpdwurEdd25LOIbtJa1PgthwWcwWG3OVK3W4DfDVIl6ENwXvWGDKFYbxHbZt0QVpOga5IlaKOI8gaQNLOyb7zWLAsX41fDZJm46)8zNyW7iaTdHjFlLbG2H9yzdSFhbO9ydbqRWZWdGwr3ROBWEW(DeG25vYGJk8ub73raYvcG4jJ6(67LGaODUe8Xd4DJ(CaO6pVpJKka0Y0dqfkICWbqzbGuvKsp1wyb73raYvcG4jJ6(67LGaORoYBaO4aOsv6daA59a0CXcacI83ta0o)MTtpzb7b73raIN2vjfwqnacI83taK60GKaGGiC5uSaepakfvhfaAUXvQsEnpwhGevK3uaOB68Bb7fvK3uS1pPonijCJlF6ZP9uZuQZpJcyVOI8MIT(j1PbjHBC5R(pNoEPNleM3Bvsy83RzXQ50ESSzvs4qYgzGi5b7fvK3uS1pPonijCJlFqK8g)9A4LEUUdH59wz434VxZIvZzP7ThlBwLeoKSrgis(1RHW8ERscJ)EnB7CMfCw6E7XYM9C6oKSrgis(1RHW8ER2DJ(Cm(71STZzwa2lQiVPyRFsDAqs4gx(Qi5dZ5nrfzCYEdV0ZnKonHTIKpmN3evKXj7nlncuNACw2ESSzvs4qYgzGi55aH59wLeg)9AwS61RBpw2SNt3HKnYarYZbcZ7TA3n6ZX4VxZIvVEneM3B1UB0NJXFVMfRMtiDAclK0LrrgX7Zjd(T0iqDQTaSxurEtXw)K60GKWnU858suHx65cH59wT7g95y83RzXQ50ESSzpNUdjBKbIKNJ7QBJgzc7K4QcJxiWErf5nfB9tQtdsc34YxjK3NpHx65cH59wT7g95y83RzXQ50ESSzpNUdjBKbIKNJ62OrMWojUQW4fcSxurEtXw)K60GKWnU857uPs9IpWl9ClhwhkNMTgReyDYqpwDK3yPrG6udShSFhbiEAxLuyb1aiAJE(bOi1iakQiasuX9auwaiztYUa1jlyVOI8Mc3IESE3ajLkWErf5nf34YhwHmzqAf8spx3HW8EB9FoDlwnyVOI8MIBC5R(I8g8sp3LlxgsNMWwrYhMZBIkY4K9MLgbQtnoqyEVTIKpmN3evKXj7nlw9colBpw2SkjCizJmqK8Rx3ESSzpNUdjBKbIKFbh3HW8EB9FoDlw9I1RxUecZ7Tq0xOxVbIK3IvVEneM3BZrj)irEJbhM8TugZ5nyF5uwS6fCw6E7XYMvjHdjBKbIKNJ7ThlB2ZP7qYgzGi5xSyby)oUJa0oxchs2YbhajQiVbG6zjaiNS3biicGEzaO0JhaPjdUoXxu9sPcGKNaOBaivdpa6fCeaLfacI6NdaXJ6gpaAhqVEasMgaLJs(rI8gasEcGANZaqY0aODimPlQivaeom5BPmaeeM3dqzbGMlairf5gHhaDpaLE8aihIN)eaLdaPKWFVgajtdGOHEC8dqzbGeOBJaOv0fEaep4dqPhGCiaQs2iakQiaIhuIkaQt4OPjp)aeXdXY6AQHhafvea1iimVhG65ONAauCaugauwaO5cacRgGKPbq0qpo(bOSaqc0Tra0k6gpEWhGspa5q88Nai98)PmaKmnaINwR(COhGGUPbqQ76TZzaOSaqy1aKmnaIgslPcajpbq54PpVhGIdGwXc2VJ7iajQiVP4gx(ESXiQiVX0ZsG3iAexLeoKSr4LEUThlBwLeoKSrgisEolxQUR3oNXgvVuQmqK82N0KCk7QBoQ76TZzSAYGRt2N0KCk7QBoTlSA3n(8j7tAsoLD5It1Ct3wDX5fC0Q8OU5aH592CuYpsK3yWHjFlLXCEd2xoLTDodhimV3crFHE9gisEB7CgoqyEVfN0fvKkdom5BPm225mlwVEjeM3Bvsy83RzXQ5qd944F3v01I1Rx2UW(IEY(K)PsLa1joTlSFwBFY)uPsG60I1Rx(yd5VhhzpjQmN3evKH6n6nThlBwIhIL11uJJ7qyEV9KOYCEturgQ3O30ESSzXQ5SecZ7Tkjm(71Sy1COHEC8V7k6EbhimV3wrYhMZBIkY4K9M9jnjNYQCDr3lwVEP62OrMWQN)pLHJ6UE7CglPvFo0BGUPzFstYPSkxx4iQi3idnKwsLvxzX61lHW8EBfjFyoVjQiJt2BwSAo0qpo(3LNP7fla7fvK3uCJlFp2yevK3y6zjWBenIRschs2i8kXNQGRl4LEUThlBwLeoKSrgisEoqyEVvjHXFVMfRgSFh3raIh0P7qYwo4airf5nauplba5K9oabra0ldaLE8ainzW1j(IQxkvaK8eaDdaPA4bqVGJaOSaqqu)Caix0fEa0oGE9aKmnakhL8Je5naK8ea1oNbGKPbq7qysxurQaiCyY3szaiimVhGYcanxaqIkYnYcq8GpaLE8aihIN)eaLdaPD3OphaYFVgajtdGkyJpFcGYca9K)PsLa1j8aiEWhGspa5qauLSrauuraepOevauNWrttE(biIhIL11udpakQiaQrqyEpa1Zrp1aO4aOmaOSaqZfaewTLh8bO0dqoep)jasp)FkdajtdG4P1Qph6biOBAaK6UE7CgaklaewnajtdGOH0sQaqYtaee1phaAf8aO7bO0dqoep)jaI3exvaqEHaizAa0o)MTtpbqQgaLfacR2c2VJ7iajQiVP4gx(ESXiQiVX0ZsG3iAe3ZP7qYgHx652ESSzpNUdjBKbIKNZYLQ76TZzSr1lLkdejV9jnjNYU6MJ6UE7CgRMm46K9jnjNYU6MZl4Ovxr3CGW8EBok5hjYBSTZz4aH59wi6l0R3arYBBNZSy96LqyEVv7UrFog)9AwSAoTlSfSXNpzFY)uPsG60I1RxcH59wT7g95y83RzXQ5aH592ks(WCEturgNS3Sy1lwVEjeM3B1UB0NJXFVMfRMZsimV3sQEwxithBK3IvVEneM3BjvpRlKPCD5Ty1l44(JnK)ECK9KOYCEturgQ3O30ESSzjEiwwxtTfRxV8XgYFpoYEsuzoVjQid1B0BApw2SepelRRPgh3HW8E7jrL58MOImuVrVP9yzZIvVy96LQBJgzc7K4QcJxioQ76TZzSQB2o9KjQitPo)mk2N0KCkRY1LfRxVuDB0ity1Z)NYWrDxVDoJL0Qph6nq30SpPj5uwLRlCevKBKHgslPYQRSybyVOI8MIBC57XgJOI8gtplbEJOrCpNUdjBeEL4tvW1f8sp32JLn750DizJmqK8CGW8ER2DJ(Cm(71Sy1G97iaXt8aKdbqvYgbq8u4xjVaqDchnn55hGiEiwwxtnasMgabjDzueajEFozWpajfasaOq60eaKdbqfNmuvauoXbqA3n6ZbG83Rbqov0qB0dqrfbqD(vYlaeeM3dqzbGKaGUhGGO(5aqRaqfsb2lQiVP4gx(ESXiQiVX0ZsG3iAe3o)k5LdV0ZD5YhBi)94iBNFL8sX47ef5GZGRNA1fYs8qSSUMAl4SmKonHfs6YOiJ495Kb)wAeOo1wWzjeM3B78RKxkgFNOihCgC9uRUqwS6fCwcH592o)k5LIX3jkYbNbxp1QlK9jnjNYQCxzXcW(DeG4jEaYHaOkzJaiEk8RKxaOoHJMM88dqepelRRPgajtdG80lDas8(CYGFaskaKaqH0PjaihcGkozOQaOCIdG80lDaYFVga5urdTrpafvea15xjVaqqyEpaLfasca6EacI6NdaTcavifyVOI8MIBC57XgJOI8gtplbEJOrC78RKxu4LEUlx(yd5Vhhz78RKxkgFNOihCgC9uRUqwIhIL11uBbNLH0PjSE6LUr8(CYGFlncuNAl4SecZ7TD(vYlfJVtuKdodUEQvxilw9colHW8EBNFL8sX47ef5GZGRNA1fY(KMKtzvURSyby)ocq8epa5q88NaibGMexv4fcGKPbqoea1UHNhaKJmbafhaPKWHKnIVZP7qYgHhajtdGCiaQs2iacs6YOi(80lDas8(CYGFakKonb1WdG4bwrdTrpaPUz70taKQbqzbGWQbihcGkozOQaOCIdGeVpNm4hG83RbqXbqkPeaug4bqv0taK2DJ(Cai)9AwWErf5nf34Y3Jngrf5nMEwc8grJ4EQB2o9eEPNBHIihCfBPk9HXFVrDZ2PN4SCziDAclK0LrrgX7Zjd(T0iqDQTGZs3Bpw2SkjCizJmqK8l4S092JLn750DizJmqK8l4SuDB0ityNexvy8cXrDxVDoJvDZ2PNmrfzk15NrX(KMKtzvUUSyby)ocq8epa5q88NaibGMexv4fcGKPbqoea1UHNhaKJmbafhaPKWHKnIVZP7qYgHhajtdGCiaQs2iacs6YOi(80lDas8(CYGFakKonb1WdG4bwrdTrpaPUz70taKQbqzbGWQbihcGkozOQaOCIdGeVpNm4hG83RbqXbqkPeaug4bqv0taKsc)9AaK)EnlyVOI8MIBC57XgJOI8gtplbEJOrCvQB2o9eEPNBHIihCfBPk9HXFVrDZ2PN4SCziDAcRNEPBeVpNm43sJa1P2colDV9yzZQKWHKnYarYVGZs3Bpw2SNt3HKnYarYVGZs1TrJmHDsCvHXleh1D925mw1nBNEYevKPuNFgf7tAsoLv56YIfG9IkYBkUXLpL07grf5nMEwc8grJ4QLrItI8gWErf5nf34Y3Jngrf5nMEwc8grJ4crYd2d2lQiVPyHi55crYB83RHx656oeM3BHi5n(71Sy1G9IkYBkwisE34Y3lB0CyfJ)PzhWpyVOI8MIfIK3nU8PUz70tMOImL68ZOGx656E7XYMvjHdjBKbIKNJ7ThlB2ZP7qYgzGi5b7fvK3uSqK8UXLpi6l0R3arYJx65UecZ7TVSrZHvm(NMDa)wS61RDxDB0ity3OjQ4)xa2lQiVPyHi5DJlF5OKFKiVbV0ZDjeM3BFzJMdRy8pn7a(Ty1Rx7U62OrMWUrtuX)VaSxurEtXcrY7gx(GOVqV(CWHx65UecZ7Tq0xOxVbIK3IvVEneM3BZrj)irEJbhM8TugZ5nyF5uwS6fG9IkYBkwisE34YN0K6i3itXrEn8sp3LU3UWknPoYnYuCKxZ0enbhzJuPphCCCxurEJvAsDKBKP4iVMPjAcoYMJX3tCvbNLU3UWknPoYnYuCKxZurs3gPsFo4wVUDHvAsDKBKP4iVMPIKU9jnjNYUUEX61TlSstQJCJmfh51mnrtWr2sik9R6AoTlSstQJCJmfh51mnrtWr2N0KCkRQloTlSstQJCJmfh51mnrtWr2iv6Zb3cWErf5nflejVBC5lQEPuzGi5XlKhhfM0Z9j)tLkbQtRx3UWgvVuQmqK82sik9R661Rx2UWgvVuQmqK82sik9RYJCESH83JJSDmVxYXJvOMH0GErrwIhIL11uBX61IkYnYqdPLuzxU8iyVOI8MIfIK3nU8PD34ZNWl9CxUecZ7T4KUOIuzWHjFlLXIvVGJOICJm0qAjvwDLfRxVCjeM3BXjDrfPYGdt(wkJfREbh3Bxy1UB85t2iv6Zbhhrf5gzOH0sQSRlCc5XrHnsnYeNPL0UUSYcWErf5nflejVBC5t7UXNpHx65USDHv7UXNpzFstYPSkxxZzjeM3BXjDrfPYGdt(wkJfREbhrf5gzOH0sQSRU4eYJJcBKAKjotlPDDzLfG9IkYBkwisE34YNMm46eEPN7l4iBJ8PkJDDr3Ckue5GRy1KbxNmA3tG9IkYBkwisE34YN2DJpFcV0ZD5t(NkvcuN4iQi3idnKwsLvxHtipokSrQrM4mTK21LvwSE9s3Bxy1UB85t2iv6Zbhhrf5gzOH0sQSRlCc5XrHnsnYeNPL0UUSYcWErf5nflejVBC5Z3PsL6fFGx65woSouonBnwjW6KHES6iVXsJa1PgNLlv31BNZyJQxkvgisE7tAsoLD1nh1D925mwnzW1j7tAsoLD19colBxy1UB85t2N0KCk7Y11l4SecZ7T5OKFKiVXGdt(wkJ58gSVCkB7CgoqyEVfI(c96nqK8225mCGW8EloPlQivgCyY3szSTZzwSaSxurEtXcrY7gx(koznHx65cH592CuYpsK3yWHjFlLXCEd2xoLTDodhimV3crFHE9gisEB7CgoIkYnYqdPLuzxU8iyVOI8MIfIK3nU8PjyD8spximV3MJs(rI8glwnhrf5gzOH0sQS6kRxdH59wi6l0R3arYBXQ5iQi3idnKwsLvxbSxurEtXcrY7gx(0eSoEPN7simV3wKnbhzuNgKeYe2sik97Y1LfCwcH5924UOYitZO6IJfREbhimV3MJs(rI8glwnhrf5gzOH0sQWDfWErf5nflejVBC5ttgCDcV0ZfcZ7T5OKFKiVXIvZrurUrgAiTKkRY11G9IkYBkwisE34YNMG1Xl9CxUCjeM3BJ7IkJmnJQlo2sik97YDLfRxVecZ7TXDrLrMMr1fhlwnhimV3g3fvgzAgvxCSpPj5uw1fRUwSE9simV3wKnbhzuNgKeYe2sik97Y11lwWrurUrgAiTKkR66fG9IkYBkwisE34Yxu9sPYarYJx65kQi3idnKwsLDDbSxurEtXcrY7gx(0KbxNWl9CxU8fC0Q8mDVGJOICJm0qAjvw11lwVE5YxWrRUZ01coIkYnYqdPLuzvxZjKonHTCyDZ5nrfz83tLWsJa1P2cWErf5nflejVBC5RgRVrFUdi8u8R6KjKhhffUUGx652UWgvVuQmqK82sik97UcyVOI8MIfIK3nU8fvVuQmqK8G9IkYBkwisE34YNMG1Xl9CfvKBKHgslPYQUgSxurEtXcrY7gx(koznzGi5b7fvK3uSqK8UXLV8VXJ94LEUVGJSnYNQmwLh1nhimV3M)nES3(KMKtzvDB1fypyVOI8MIvlJeNe5nCZ)gp2Jx65MJ60YbNPjAcoYORYU5FJh7nnrtWrMO6Ps11BCGW8EB(34XE7tAsoLvDTRCLuccSxurEtXQLrItI8g34Y3td5iD8sp3qg95GJtfj9OYwRIv3jDb2lQiVPy1YiXjrEJBC5Z)0SdsQzEchn0lrEdEPNBiJ(CWXPIKEuzRvXQ7KUa7fvK3uSAzK4KiVXnU8rA1Nd9gOBA4LEUlDV9yzZQKWHKnYarYZX92JLn750DizJmqK8lwVwurUrgAiTKk7YDfWErf5nfRwgjojYBCJlFqYRVOph8sp3qg95GJtfj9OYwRIvDf6ItoQtlhCMMOj4iJUk7QBRlUYvK0JkRM4QG9IkYBkwTmsCsK34gx(ky)wUjDtoLihvuWl9CHW8EBb73YnPBYPe5OIITDodhimV3cjV(I(CSTZz4urspQS1Qy1Ds3CYrDA5GZ0enbhz0vzxDBxrxUYvK0JkRM4QG9G9IkYBkw1D925mfU1xK3a2lQiVPyv31BNZuCJlFq97Agp2ZpyVOI8MIvDxVDotXnU8brFHE95GdSxurEtXQUR3oNP4gx(KxjdzI7FAcWErf5nfR6UE7CMIBC5RN4QIIzhowdNgnbyVOI8MIvDxVDotXnU85ZNG631a7fvK3uSQ76TZzkUXLpzuujEPBusVd2lQiVPyv31BNZuCJlFqFwIEo4mEShV0ZfcZ7TqK8g)9AwSAWErf5nfR6UE7CMIBC5lhL8Je5n4LEUlBxy1UB85t2iv6Zb361IkYnYqdPLuzxxwWPDHnQEPuzGi5TrQ0NdoWErf5nfR6UE7CMIBC5dI(c96b7fvK3uSQ76TZzkUXLpSczYG0WJ8EsfMr0iUk(v9l(BsLbQlLaSxurEtXQUR3oNP4gx(WkKjdsRa2d2lQiVPyvs4qYgXT(pNoyVOI8MIvjHdjBKBC5tjHXFVgEPNR7qyEVvjHXFVMfRgSxurEtXQKWHKnYnU89IEcV0ZfcZ7T1)50Ty1G9IkYBkwLeoKSrUXLVks(WCEturgNS3Wl9CdPttyRi5dZ5nrfzCYEZsJa1Pgh3HW8EBfjFyoVjQiJt2BwSAWErf5nfRschs2i34YhPvFo0BGUPHx652ESSzvs4qYgzGi5b7fvK3uSkjCizJCJlFVONWl9CBxyFrpzFY)uPsG6eh1PbDM6lNOSkpc2lQiVPyvs4qYg5gx((SgV0ZTDH9ZA7t(NkvcuN4OonOZuF5eLD5YJG9IkYBkwLeoKSrUXLp1nBNEYevKPuNFgf8sp32JLnRschs2idejpyVOI8MIvjHdjBKBC5Zt)PYdRyGYGWttCvdn0JJFUUGx65QonOZuF5eLD5YJG9IkYBkwLeoKSrUXLpPj1rUrMIJ8A4LEUlDVDHvAsDKBKP4iVMPjAcoYgPsFo444UOI8gR0K6i3itXrEntt0eCKnhJVN4QcolDVDHvAsDKBKP4iVMPIKUnsL(CWTED7cR0K6i3itXrEntfjD7tAsoLDD9I1RBxyLMuh5gzkoYRzAIMGJSLqu6x11CAxyLMuh5gzkoYRzAIMGJSpPj5uwvxCAxyLMuh5gzkoYRzAIMGJSrQ0NdUfG9IkYBkwLeoKSrUXLpFNkvQx8bEPNB5W6q50S1yLaRtg6XQJ8glncuNACOHEC8VQR1fyVOI8MIvjHdjBKBC5Ru9udV0ZvDAqNP(Yjkwf2)0eRQlWEWErf5nfRsDZ2PN4QKW4VxdSxurEtXQu3SD6j34YxfjFyoVjQiJt2B4LEUH0PjSvK8H58MOImozVzPrG6uJJ7qyEVTIKpmN3evKXj7nlwnyVOI8MIvPUz70tUXLp1nBNEYevKPuNFgf8sp3YH1HYPz95xctj(upzPrG6uJdeM3B95xctj(upzXQb7fvK3uSk1nBNEYnU8PUz70tMOImL68ZOGx65gsNMWwrYhMZBIkY4K9MLgbQtnoqyEVTIKpmN3evKXj7nlwnyVOI8MIvPUz70tUXLp1nBNEYevKPuNFgf8sp3q60e2ks(WCEturgNS3S0iqDQXrDxVDoJTIKpmN3evKXj7n7tAsoLDDrxG9IkYBkwL6MTtp5gx(u3SD6jturMsD(zuWl9CDpKonHTIKpmN3evKXj7nlncuNAG9G9IkYBk2o)k5ffxLeg)9AG9G9IkYBk2o)k5LJR2DJ(Cm(71a7b7fvK3uSN6MTtpXv7UrFog)9AG9IkYBk2tDZ2PNCJlFvK8H58MOImozVHx65gsNMWwrYhMZBIkY4K9MLgbQtnoUdH592ks(WCEturgNS3Sy1G9IkYBk2tDZ2PNCJlFQB2o9KjQitPo)mk4LEULdRdLtZ6ZVeMs8PEYsJa1PghimV36ZVeMs8PEYIvd2lQiVPyp1nBNEYnU8vc595t4LEUKQN1fYkd)MHC1y9As1Z6czlxxEZqUAa2lQiVPyp1nBNEYnU858suHx65sQEwxiRm8BgYvJ1RjvpRlKTJnYBgYvdWErf5nf7PUz70tUXLp1nBNEYevKPuNFgf8sp3q60e2ks(WCEturgNS3S0iqDQXbcZ7TvK8H58MOImozVzXQb7fvK3uSN6MTtp5gx(u3SD6jturMsD(zuWl9CdPttyRi5dZ5nrfzCYEZsJa1Pgh1D925m2ks(WCEturgNS3SpPj5u21fDb2lQiVPyp1nBNEYnU8PUz70tMOImL68ZOGx656EiDAcBfjFyoVjQiJt2BwAeOo1a7b7fvK3uSNt3HKnIR2DJ(Cm(71Wl9CDhcZ7TA3n6ZX4VxZIvd2lQiVPypNUdjBKBC5RIKpmN3evKXj7n8sp3q60e2ks(WCEturgNS3S0iqDQXXDimV3wrYhMZBIkY4K9MfRgSxurEtXEoDhs2i34YxjKVG94iWErf5nf750DizJCJlFQB2o9KjQitPo)mk4LEULdRdLtZ6ZVeMs8PEYsJa1PgyVOI8MI9C6oKSrUXLpsR(CO3aDtdV0ZT9yzZEoDhs2idejpyVOI8MI9C6oKSrUXLpPj1rUrMIJ8A4LEUlDVDHvAsDKBKP4iVMPjAcoYgPsFo444UOI8gR0K6i3itXrEntt0eCKnhJVN4QcolDVDHvAsDKBKP4iVMPIKUnsL(CWTED7cR0K6i3itXrEntfjD7tAsoLDD9I1RBxyLMuh5gzkoYRzAIMGJSLqu6x11CAxyLMuh5gzkoYRzAIMGJSpPj5uwvxCAxyLMuh5gzkoYRzAIMGJSrQ0NdUfG9IkYBk2ZP7qYg5gx(kyJpFcpf)Qozc5XrrHRl4LEUp5FQujqDcSxurEtXEoDhs2i34YN2DJpFcpf)Qozc5XrrHRl4LEUp5FQujqDA9AimV3It6IksLbhM8TuglwnyVOI8MI9C6oKSrUXLVsiVpFcV0ZvDB0ityNexvy8cXHu9SUqwz43mKRgG9IkYBk2ZP7qYg5gx(CEjQWl9CDxDB0ityNexvy8cXHu9SUqwz43mKRgG9IkYBk2ZP7qYg5gx(u3SD6jturMsD(zuWl9CxcH59ws1Z6cz6yJ8wS61RHW8ElP6zDHmLRlVfREbyVOI8MI9C6oKSrUXLVsiVpFcV0ZDjP6zDHS5y6yJ8RxtQEwxiB56YBgYvJfRxVKu9SUq2CmDSrEoqyEVTeYxWECKH0Qph61OjmDSrElw9cWErf5nf750DizJCJlFoVevSGfmga]] )


end