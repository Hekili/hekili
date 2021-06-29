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

    spec:RegisterPack( "Guardian", 20210627, [[dCujHbqiQu9iLiztOsFckv1OukoLsPvrQk0ROsAwqj3IuvWUO0VqvzyuP4yujwMsfpJkLMMsL6AKQQTPerFdkvACkrOZPebRdkvrZtjQ7Hk2hukhuPsGfsQYdvIunrLiLCrOuL(OsKItcLkwPsvZekvHBQujODIQ0pvQe9uqnvufFvPsO9IYFPyWqomXIb5XKmzPCzKntvFgkgTeoTOvRePuVMuz2s1TjLDR43QA4s0XvQKwoWZL00fUouTDL03PIXtQkDEuvTEsvrZxjSFvM5cJhgCtcIX7oUzhxCZsUd216YsU7LGBwIm4G)sIbxkkDcgIbpIgXGxAWfqlLHbxk83FPX4HbxFCGIyWfruwXEYhFyYOahYQEn(QPgExI8hfq8bF1utXhdgcp7b2zyqm4MeeJ3DCZoU4MLChSR1LLC3lb3GDzWcEu8agmCQT0zWfzRrddIb3OQIbV0GlGwkZHwAbWZ2TFp(qhAhSlwhAh3SJBU93(LEHmyOk2ZBV(WHWoJ6bLpqc6qlDj4Bx4)JUCoujiFqgjvp0M0FOkfroyouwpKQGu6O2w7TxF4qyNr9GYhibDOVmYFou8hQwK(4qBEWHMp2EiiY)a6ql9FwFDKLb3ZAuz8WG78ReG8mEy86cJhgSOI8hgS2)JUCm(hOXGPrG6uJPhlybdgIeaJhgVUW4HbtJa1PgtpgScKbbsHb7(HGW9ElejaJ)bAw8sgSOI8hgmejaJ)bASGX7omEyWIkYFyWazLMhVA8aA0N8ZGPrG6uJPhly86wgpmyAeOo1y6XGvGmiqkmy3pudGNnRschswjdejGdX9qUFOgapB23P7qYkzGibWGfvK)WGv)S(6ituqMAzcYOYcgV7MXddMgbQtnMEmyfidcKcdEZHGW9ElqwP5XRgpGg9j)w8YdTyXHC)qQFLgzc7knrb)GdTLblQi)HbdrGkb0XcgV6NXddMgbQtnMEmyfidcKcdEZHGW9ElqwP5XRgpGg9j)w8YdTyXHC)qQFLgzc7knrb)GdTLblQi)HbNJsaJe5pSGX7sY4HbtJa1PgtpgScKbbsHbV5qq4EVfIavcOZarcWIxEOfloeeU3BZrjGrI8hdgCb0szmV3GdQVYIxEOTmyrf5pmyicujGUCWWcgVyxgpmyAeOo1y6XGvGmiqkm4nhY9d1(WknPmYvYuDeGMPjAcgYgPsxoyoe3d5(HevK)yLMug5kzQocqZ0enbdzZX47jMI4qCp0Md5(HAFyLMug5kzQocqZuqs3gPsxoyo0IfhQ9HvAszKRKP6iantbjDlG0KCQhcBhYThA7HwS4qTpSstkJCLmvhbOzAIMGHS1qu6o0YhYThI7HAFyLMug5kzQocqZ0enbdzbKMKt9qlFi9FiUhQ9HvAszKRKP6iantt0emKnsLUCWCOTmyrf5pmyPjLrUsMQJa0ybJ3LiJhgmncuNAm9yWkqgeifgmG8aQwiqD6qlwCO2h2Oai1cdejaBneLUdT8HC7HwS4qBou7dBuaKAHbIeGTgIs3Hw(q7(qCpeaFi)dWq2oU3l54XRuZqAqarrwAxXZYsQDOThAXIdjQixjdnKws1dHnohA3myrf5pm4Oai1cdejawW4DjW4HbtJa1PgtpgScKbbsHbV5qBoeeU3BXiDrfPYGbxaTuglE5H2EiUhsurUsgAiTKQhA5dTZH2EOflo0MdT5qq4EVfJ0fvKkdgCb0szS4LhA7H4Ei3pu7dR2)JpbKnsLUCWCiUhsurUsgAiTKQhcBhYLdX9qHaWqHnsnYeVPL0HW2HCzNdTLblQi)HbR9)4taXcgVU4ggpmyAeOo1y6XGvGmiqkm4nhQ9Hv7)XNaYcinjN6HwMZHC7H4EOnhcc37TyKUOIuzWGlGwkJfV8qBpe3djQixjdnKws1dHTdP)dX9qHaWqHnsnYeVPL0HW2HCzNdTLblQi)HbR9)4taXcgVU4cJhgmncuNAm9yWkqgeifgmqWq2g5tvghcBhYf3CiUhQsrKdMQvtgmDYO9aIblQi)HbRjdMoXcgVUSdJhgmncuNAm9yWkqgeifg8MdbipGQfcuNoe3djQixjdnKws1dT8H25qCpuiamuyJuJmXBAjDiSDix25qBp0IfhAZHC)qTpSA)p(eq2iv6YbZH4Eirf5kzOH0sQEiSDixoe3dfcadf2i1it8MwshcBhYLDo0wgSOI8hgS2)Jpbely86IBz8WGPrG6uJPhdwbYGaPWGHW9EBokbmsK)yWGlGwkJ59gCq9v227mhI7HGW9ElebQeqNbIeGT9oZH4Eirf5kzOH0sQEiSX5q7MblQi)HbxDYsYarcGfmEDz3mEyW0iqDQX0JbRazqGuyWq4EVnhLagjYFS4LhI7HevKRKHgslP6Hw(q7COfloeeU3BHiqLa6mqKaS4LhI7HevKRKHgslP6Hw(q7WGfvK)WG1e8oly86I(z8WGPrG6uJPhdwbYGaPWG3CiiCV3wLvbdzuVgKeYe2AikDhcBCoKlhA7H4EOnhcc37TX)rHrMMr1fhlE5H2EiUhcc37T5OeWir(JfV8qCpKOICLm0qAjvpeNdTddwur(ddwtW7SGXRlljJhgmncuNAm9yWkqgeifgmeU3BZrjGrI8hlE5H4Eirf5kzOH0sQEOL5Ci3YGfvK)WG1KbtNybJxxWUmEyW0iqDQX0JbRazqGuyWBo0MdT5qq4EVn(pkmY0mQU4yRHO0DiSX5q7COThAXIdT5qq4EVn(pkmY0mQU4yXlpe3dbH7924)OWitZO6IJfqAso1dT8HCXQ)dT9qlwCOnhcc37TvzvWqg1RbjHmHTgIs3HWgNd52dT9qBpe3djQixjdnKws1dT8HC7H2YGfvK)WG1e8oly86YsKXddMgbQtnMEmyfidcKcdwurUsgAiTKQhcBhYfgSOI8hgCuaKAHbIealy86YsGXddMgbQtnMEmyfidcKcdEZH2CiGGHo0YhAj4MdT9qCpKOICLm0qAjvp0YhYThA7HwS4qBo0Mdbem0Hw(qlr9FOThI7HevKRKHgslP6Hw(qU9qCpuiDAcB9X7M3BIcY4FavdlncuNAhAldwur(ddwtgmDIfmE3XnmEyW0iqDQX0JblQi)HbxI3xjqQpjgScKbbsHb3(WgfaPwyGibyRHO0DiSDODyWk(vDYecadfvgVUWcgV74cJhgSOI8hgCuaKAHbIeadMgbQtnMESGX7o7W4HbtJa1PgtpgScKbbsHblQixjdnKws1dT8HCldwur(ddwtW7SGX7oULXddwur(ddU6KLKbIeadMgbQtnMESGX7o7MXddMgbQtnMEmyfidcKcdgiyiBJ8PkJdT8H2TBoe3dbH792e8JhhybKMKt9qlFi3y1pdwur(ddob)4XbSGfmyTmsmsK)W4HXRlmEyW0iqDQX0JbRazqGuyW5OETCWyAIMGHm6VEiSDOe8JhhyAIMGHmrbGQfFVDiUhcc37Tj4hpoWcinjN6Hw(qU9q6JhQqQbXGfvK)WGtWpECaly8UdJhgmncuNAm9yWkqgeifgCiJUCWCiUhQGKEuylvXHw(qlP(zWIkYFyWaAihPZcgVULXddMgbQtnMEmyfidcKcdoKrxoyoe3dvqspkSLQ4qlFOLu)myrf5pmypGg9zsndGWqdbKi)HfmE3nJhgmncuNAm9yWkqgeifg8Md5(HAa8Szvs4qYkzGibCiUhY9d1a4zZ(oDhswjdejGdT9qlwCirf5kzOH0sQEiSX5q7WGfvK)WGjTY3HagOFASGXR(z8WGPrG6uJPhdwbYGaPWGdz0LdMdX9qfK0JcBPko0Yhc7Q)dX9q5OETCWyAIMGHm6VEiSDi3yD5q6JhQGKEuy1e9LblQi)HbdjaDvD5WcgVljJhgmncuNAm9yWkqgeifgmeU3BR4G1Cv6MCQroQOABVZCiUhcc37Tqcqxvxo227mhI7HkiPhf2svCOLp0s6MdX9q5OETCWyAIMGHm6VEiSDi3y3r)hsF8qfK0JcRMOVmyrf5pm4koynxLUjNAKJkQSGfmyLeoKSsmEy86cJhgSOI8hgCj4D6myAeOo1y6XcgV7W4HbtJa1PgtpgScKbbsHb7(HGW9ERscJ)bAw8sgSOI8hgSscJ)bASGXRBz8WGPrG6uJPhdwbYGaPWGHW9EBj4D6w8sgSOI8hgmq0rSGX7Uz8WGPrG6uJPhdwbYGaPWGdPttylibeM3BIcY4K9MLgbQtTdX9qUFiiCV3wqcimV3efKXj7nlEjdwur(ddUGeqyEVjkiJt2BSGXR(z8WGPrG6uJPhdwbYGaPWGBa8Szvs4qYkzGibWGfvK)WGjTY3HagOFASGX7sY4HbtJa1PgtpgScKbbsHb3(WceDKfqEavleOoDiUhs9AqVP8ZjQhA5dTBgSOI8hgmq0rSGXl2LXddMgbQtnMEmyfidcKcdU9HfKLwa5buTqG60H4Ei1Rb9MYpNOEiSX5q7MblQi)HbdYswW4DjY4HbtJa1PgtpgScKbbsHb3a4zZQKWHKvYarcGblQi)HbR(z91rMOGm1YeKrLfmExcmEyW0iqDQX0JbRazqGuyWQxd6nLFor9qyJZH2ndwur(dd2tGxLpE1aLbXG1e91qdbWWpJxxybJxxCdJhgmncuNAm9yWkqgeifg8Md5(HAFyLMug5kzQocqZ0enbdzJuPlhmhI7HC)qIkYFSstkJCLmvhbOzAIMGHS5y89etrCiUhAZHC)qTpSstkJCLmvhbOzkiPBJuPlhmhAXId1(WknPmYvYuDeGMPGKUfqAso1dHTd52dT9qlwCO2hwPjLrUsMQJa0mnrtWq2AikDhA5d52dX9qTpSstkJCLmvhbOzAIMGHSastYPEOLpK(pe3d1(WknPmYvYuDeGMPjAcgYgPsxoyo0wgSOI8hgS0KYixjt1raASGXRlUW4HbtJa1PgtpgScKbbsHbREnO3u(5evRchaOjo0Yhs)myrf5pm4AbGASGfm4o)kbikgpmEDHXddwur(ddwjHX)angmncuNAm9yblyWnYl49GXdJxxy8WGPrG6uJPhdUrvfilJ8hgm2R(sk8GAhIwja)hksn6qrbDirfp4qz9qYQKDbQtwgSOI8hgCvhEVBGKAbly8UdJhgmncuNAm9yWkqgeifgS7hcc37TLG3PBXlzWIkYFyW4vYKbPvzbJx3Y4HbtJa1PgtpgScKbbsHbV5qBo0MdfsNMWwqcimV3efKXj7nlncuNAhI7HGW9EBbjGW8EtuqgNS3S4LhA7H4EOnhQbWZMvjHdjRKbIeWHwS4qnaE2SVt3HKvYarc4qBpe3d5(HGW9EBj4D6w8YdT9qlwCOnhAZHGW9ElebQeqNbIeGfV8qlwCiiCV3MJsaJe5pgm4cOLYyEVbhuFLfV8qBpe3dT5qUFOgapBwLeoKSsgisahI7HC)qnaE2SVt3HKvYarc4qBp02dTLblQi)Hbx(r(dly8UBgpmyAeOo1y6XGvGmiqkm4gapBwLeoKSsgisahI7HGW9ERscJ)bAw8sgCnaPky86cdwur(ddgGpgrf5pMEwdgCpRHzenIbRKWHKvIfmE1pJhgmncuNAm9yWkqgeifgCdGNn770DizLmqKaoe3dbH79wT)hD5y8pqZIxYGRbivbJxxyWIkYFyWa8XiQi)X0ZAWG7znmJOrm43P7qYkXcgVljJhgmncuNAm9yWnQQazzK)WGXo(d5qhQqwPdH9GFLaKd1jm00ea)hI2v8SSKAhsM2HGKUmk6qI3Ntg8FiPEi5qH0PjoKdDOQtgQIdLt8hs7)rxohY)aTd5uqdTsGdff0H68ReGCiiCV)qz9qsCOhCiiQ)ohANdvjfdwur(ddgGpgrf5pMEwdgScKbbsHbV5qBoeaFi)dWq2o)kbivJVtuKdgdMEQvwjlTR4zzj1o02dX9qBouiDAclK0LrrgX7Zjd(T0iqDQDOThI7H2CiiCV325xjaPA8DIICWyW0tTYkzXlp02dX9qBoeeU3B78ReGun(orroymy6PwzLSastYPEOL5CODo02dTLb3ZAygrJyWD(vcqEwW4f7Y4HbtJa1PgtpgCJQkqwg5pmySJ)qo0HkKv6qyp4xja5qDcdnnbW)HODfpllP2HKPDipbK(HeVpNm4)qs9qYHcPttCih6qvNmufhkN4pKNas)q(hODiNcAOvcCOOGouNFLaKdbH79hkRhsId9Gdbr935q7COkPyWIkYFyWa8XiQi)X0ZAWGvGmiqkm4nhAZHa4d5FagY25xjaPA8DIICWyW0tTYkzPDfpllP2H2EiUhAZHcPtty9eq6gX7Zjd(T0iqDQDOThI7H2CiiCV325xjaPA8DIICWyW0tTYkzXlp02dX9qBoeeU3B78ReGun(orroymy6PwzLSastYPEOL5CODo02dTLb3ZAygrJyWD(vcquSGX7sKXddMgbQtnMEm4gvvGSmYFyWyh)HCiSpGoKCOjXueEHoKmTd5qhQ9d2poKJmXHI)qkjCizL47D6oKSsyDizAhYHouHSshcs6YOi(8eq6hs8(CYG)dfsNMGAyDODXcAOvcCi1pRVo6qQ2HY6HWlpKdDOQtgQIdLt8hs8(CYG)d5FG2HI)qkPghkdSoubbOdP9)OlNd5FGMLblQi)HbdWhJOI8htpRbdwbYGaPWGRue5GPARfPpm(hyu)S(6OdX9qBo0MdfsNMWcjDzuKr8(CYGFlncuNAhA7H4EOnhY9d1a4zZQKWHKvYarc4qBpe3dT5qUFOgapB23P7qYkzGibCOThI7H2Ci1VsJmHDsmfHXl0H4Ei1)927mw1pRVoYefKPwMGmQwaPj5up0YCoKlhA7H2YG7znmJOrm4x9Z6RJybJ3LaJhgmncuNAm9yWnQQazzK)WGXo(d5qyFaDi5qtIPi8cDizAhYHou7hSFCihzIdf)Hus4qYkX370DizLW6qY0oKdDOczLoeK0Lrr85jG0pK495Kb)hkKonb1W6q7If0qRe4qQFwFD0HuTdL1dHxEih6qvNmufhkN4pK495Kb)hY)aTdf)HusnougyDOccqhsjH)bAhY)anldwur(ddgGpgrf5pMEwdgScKbbsHbxPiYbt1wlsFy8pWO(z91rhI7H2COnhkKonH1taPBeVpNm43sJa1P2H2EiUhAZHC)qnaE2SkjCizLmqKao02dX9qBoK7hQbWZM9D6oKSsgisahA7H4EOnhs9R0ityNetry8cDiUhs9FV9oJv9Z6RJmrbzQLjiJQfqAso1dTmNd5YH2EOTm4EwdZiAedwP(z91rSGXRlUHXddMgbQtnMEmyrf5pmyL07grf5pMEwdgCpRHzenIbRLrIrI8hwW41fxy8WGPrG6uJPhdwur(ddgGpgrf5pMEwdgCpRHzenIbdrcGfSGbxci1RbjbJhgVUW4HbtJa1PgtpgCJQkqwg5pmySx9Lu4b1oee5FaDi1RbjXHGim5uThAxGsrLr9qZp6dfcqZJ3pKOI8N6H(PZVLblQi)HbRlNgGAMAzcYOYcgV7W4HbtJa1PgtpgScKbbsHbdH79wLeg)d0S4LhI7HAa8Szvs4qYkzGibWGfvK)WGlbVtNfmEDlJhgmncuNAm9yWkqgeifgS7hcc37TYWVX)anlE5H4EOnhY9d1a4zZQKWHKvYarc4qlwCiiCV3QKW4FGMT9oZH2EiUhAZHC)qnaE2SVt3HKvYarc4qlwCiiCV3Q9)OlhJ)bA227mhAldwur(ddgIeGX)anwW4D3mEyW0iqDQX0JbRazqGuyWH0PjSfKacZ7nrbzCYEZsJa1P2H4EOnhQbWZMvjHdjRKbIeWH4EiiCV3QKW4FGMfV8qlwCOgapB23P7qYkzGibCiUhcc37TA)p6YX4FGMfV8qlwCiiCV3Q9)OlhJ)bAw8YdX9qH0PjSqsxgfzeVpNm43sJa1P2H2YGfvK)WGlibeM3BIcY4K9gly8QFgpmyAeOo1y6XGvGmiqkmyiCV3Q9)OlhJ)bAw8YdX9qnaE2SVt3HKvYarc4qCpK7hs9R0ityNetry8cXGfvK)WGDasuWcgVljJhgmncuNAm9yWkqgeifgmeU3B1(F0LJX)anlE5H4EOgapB23P7qYkzGibCiUhs9R0ityNetry8cXGfvK)WGRHa8jGyblyWQ)7T3zQmEy86cJhgSOI8hgC5h5pmyAeOo1y6XcgV7W4HblQi)Hbd1)Vz84a(zW0iqDQX0JfmEDlJhgSOI8hgmebQeqxoyyW0iqDQX0JfmE3nJhgSOI8hgSauYqM4baAcgmncuNAm9ybJx9Z4HblQi)Hb3tmfr1S0gVHrJMGbtJa1PgtpwW4Djz8WGfvK)WG9jGG6)3yW0iqDQX0JfmEXUmEyWIkYFyWYOOAaKUrj9odMgbQtnMESGX7sKXddMgbQtnMEmyfidcKcdgc37TqKam(hOzXlzWIkYFyWqGSg9CWy84awW4DjW4HbtJa1PgtpgScKbbsHbV5qTpSA)p(eq2iv6YbZHwS4qIkYvYqdPLu9qy7qUCOThI7HAFyJcGulmqKaSrQ0LdggSOI8hgCokbmsK)WcgVU4ggpmyrf5pmyicujGogmncuNAm9ybJxxCHXddMgbQtnMEmyrf5pmyf)Q(hGFsLbQl1GbtEpPcZiAedwXVQ)b4NuzG6snybJxx2HXddwur(ddgVsMmiTkdMgbQtnMESGfm4x9Z6RJy8W41fgpmyrf5pmyT)hD5y8pqJbtJa1PgtpwW4DhgpmyAeOo1y6XGvGmiqkm4q60e2csaH59MOGmozVzPrG6u7qCpK7hcc37TfKacZ7nrbzCYEZIxYGfvK)WGlibeM3BIcY4K9gly86wgpmyAeOo1y6XGvGmiqkm46J3HYPz9jOgMAasDKLgbQtTdX9qq4EV1NGAyQbi1rw8sgSOI8hgS6N1xhzIcYultqgvwW4D3mEyW0iqDQX0JbRazqGuyWKQNLvYkd)MH034qlwCis1ZYkzRFxaMH03GblQi)Hbxdb4taXcgV6NXddMgbQtnMEmyfidcKcdMu9SSswz43mK(ghAXIdrQEwwjBhFeGzi9nyWIkYFyWoajkybJ3LKXddMgbQtnMEmyfidcKcdoKonHTGeqyEVjkiJt2BwAeOo1oe3dbH792csaH59MOGmozVzXlzWIkYFyWQFwFDKjkitTmbzuzbJxSlJhgmncuNAm9yWkqgeifgCiDAcBbjGW8EtuqgNS3S0iqDQDiUhs9FV9oJTGeqyEVjkiJt2BwaPj5upe2oKl6NblQi)HbR(z91rMOGm1YeKrLfmExImEyW0iqDQX0JbRazqGuyWUFOq60e2csaH59MOGmozVzPrG6uJblQi)HbR(z91rMOGm1YeKrLfSGbRu)S(6igpmEDHXddwur(ddwjHX)angmncuNAm9ybJ3Dy8WGPrG6uJPhdwbYGaPWGdPttylibeM3BIcY4K9MLgbQtTdX9qUFiiCV3wqcimV3efKXj7nlEjdwur(ddUGeqyEVjkiJt2BSGXRBz8WGPrG6uJPhdwbYGaPWGRpEhkNM1NGAyQbi1rwAeOo1oe3dbH79wFcQHPgGuhzXlzWIkYFyWQFwFDKjkitTmbzuzbJ3DZ4HbtJa1PgtpgScKbbsHbhsNMWwqcimV3efKXj7nlncuNAhI7HGW9EBbjGW8EtuqgNS3S4Lmyrf5pmy1pRVoYefKPwMGmQSGXR(z8WGPrG6uJPhdwbYGaPWGdPttylibeM3BIcY4K9MLgbQtTdX9qQ)7T3zSfKacZ7nrbzCYEZcinjN6HW2HCr)myrf5pmy1pRVoYefKPwMGmQSGX7sY4HbtJa1PgtpgScKbbsHb7(HcPttylibeM3BIcY4K9MLgbQtngSOI8hgS6N1xhzIcYultqgvwWcg870DizLy8W41fgpmyAeOo1y6XGvGmiqkmy3peeU3B1(F0LJX)anlEjdwur(ddw7)rxog)d0ybJ3Dy8WGPrG6uJPhdwbYGaPWGdPttylibeM3BIcY4K9MLgbQtTdX9qUFiiCV3wqcimV3efKXj7nlEjdwur(ddUGeqyEVjkiJt2BSGXRBz8WGfvK)WGRHaQ4amedMgbQtnMESGX7Uz8WGPrG6uJPhdwbYGaPWGRpEhkNM1NGAyQbi1rwAeOo1yWIkYFyWQFwFDKjkitTmbzuzbJx9Z4HbtJa1PgtpgScKbbsHb3a4zZ(oDhswjdejagSOI8hgmPv(oeWa9tJfmExsgpmyAeOo1y6XGvGmiqkm4nhY9d1(WknPmYvYuDeGMPjAcgYgPsxoyoe3d5(HevK)yLMug5kzQocqZ0enbdzZX47jMI4qCp0Md5(HAFyLMug5kzQocqZuqs3gPsxoyo0IfhQ9HvAszKRKP6iantbjDlG0KCQhcBhYThA7HwS4qTpSstkJCLmvhbOzAIMGHS1qu6o0YhYThI7HAFyLMug5kzQocqZ0enbdzbKMKt9qlFi9FiUhQ9HvAszKRKP6iantt0emKnsLUCWCOTmyrf5pmyPjLrUsMQJa0ybJxSlJhgmncuNAm9yWIkYFyWv8XNaIbRazqGuyWaYdOAHa1jgSIFvNmHaWqrLXRlSGX7sKXddMgbQtnMEmyrf5pmyT)hFcigScKbbsHbdipGQfcuNo0Ifhcc37TyKUOIuzWGlGwkJfVKbR4x1jtiamuuz86cly8Uey8WGPrG6uJPhdwbYGaPWGv)knYe2jXuegVqhI7HivplRKvg(ndPVbdwur(ddUgcWNaIfmEDXnmEyW0iqDQX0JbRazqGuyWUFi1VsJmHDsmfHXl0H4Eis1ZYkzLHFZq6BWGfvK)WGDasuWcgVU4cJhgmncuNAm9yWkqgeifg8MdbH79ws1ZYkz64JaS4LhAXIdbH79ws1ZYkzQFxaw8YdTLblQi)HbR(z91rMOGm1YeKrLfmEDzhgpmyAeOo1y6XGvGmiqkm4nhIu9SSs2CmD8rahAXIdrQEwwjB97cWmK(ghA7HwS4qBoeP6zzLS5y64Jaoe3dbH792AiGkoadziTY3HaA0eMo(ialE5H2YGfvK)WGRHa8jGybJxxClJhgSOI8hgSdqIcgmncuNAm9yblybdELa18hgV74MDCXn72nULb7iGjhmvgm2rR8bb1oKlUCirf5phQN1OAV9m4AjPy86IB2ndUe8(Stm4L6qln4cOLYCOLwa8SD7xQdThFOdTd2fRdTJB2Xn3(B)sDOLEHmyOk2ZB)sDi9HdHDg1dkFGe0Hw6sW3UW)hD5COsq(GmsQEOnP)qvkICWCOSEivbP0rTT2B)sDi9HdHDg1dkFGe0H(Yi)5qXFOAr6JdT5bhA(y7HGi)dOdT0)z91r2B)TFPoe2R(sk8GAhcI8pGoK61GK4qqeMCQ2dTlqPOYOEO5h9HcbO5X7hsur(t9q)053E7fvK)uTLas9Aqs4kh(0LtdqntTmbzuV9IkYFQ2saPEnijCLdFLG3PJv65aH79wLeg)d0S4LCBa8Szvs4qYkzGibC7fvK)uTLas9Aqs4kh(Giby8pqdR0ZXDiCV3kd)g)d0S4LC34EdGNnRschswjdejGflGW9ERscJ)bA227mB5UX9gapB23P7qYkzGibSybeU3B1(F0LJX)anB7DMT3Erf5pvBjGuVgKeUYHVcsaH59MOGmozVHv65esNMWwqcimV3efKXj7nlncuNAC30a4zZQKWHKvYarcGleU3Bvsy8pqZIxUyrdGNn770DizLmqKa4cH79wT)hD5y8pqZIxUybeU3B1(F0LJX)anlEj3q60ewiPlJImI3Ntg8BPrG6uB7Txur(t1wci1RbjHRC4ZbirbwPNdeU3B1(F0LJX)anlEj3gapB23P7qYkzGibW1D1VsJmHDsmfHXl0Txur(t1wci1RbjHRC4RgcWNacR0Zbc37TA)p6YX4FGMfVKBdGNn770DizLmqKa4Q(vAKjStIPimEHU93(L6qyV6lPWdQDiALa8FOi1Odff0Hev8GdL1djRs2fOozV9IkYFQCQ6W7DdKulU9IkYFQUYHp8kzYG0QyLEoUdH792sW70T4L3Erf5pvx5Wx5h5pyLEoB2SjKonHTGeqyEVjkiJt2BwAeOo14cH792csaH59MOGmozVzXl3YDtdGNnRschswjdejGflAa8SzFNUdjRKbIeWwUUdH792sW70T4LBxSyZgiCV3crGkb0zGibyXlxSac37T5OeWir(JbdUaAPmM3BWb1xzXl3YDJ7naE2SkjCizLmqKa46EdGNn770DizLmqKa2UD7TFPwQdT0LWHK1CWCirf5phQN14qozVFii6qazou6X6qAYGPt8ffaPwCibqh6NdPAyDiGGHouwpee1FNdTB3G1H0Neq3HKPDOCucyKi)5qcGou7DMdjt7qln4sxurQoegCb0szoeeU3FOSEO5JdjQixjSo0dou6X6qoe2hqhkNdPKW)aTdjt7q0qam8FOSEib6xPdTJ(X6q7sWHs)HCOdviR0HIc6q7sjkouNWqtta8FiAxXZYsQH1HIc6qncc37puphDu7qXFOmouwp08XHWlpKmTdrdbWW)HY6HeOFLo0oUbRDj4qP)qoe2hqhsh)GuMdjt7qyVALVdboe0pTdP(V3EN5qz9q4LhsM2HOH0sQEibqhkhpbYhCO4p0o2B)sTuhsur(t1vo8bWhJOI8htpRbwJOrCus4qYkHv650a4zZQKWHKvYarcG7MnQ)7T3zSrbqQfgisawaPj5uXMB4Q(V3ENXQjdMozbKMKtfBUHB7dR2)JpbKfqAsovSXbJQ5QBS6NlqWqlVB3Wfc37T5OeWir(JbdUaAPmM3BWb1xzBVZWfc37TqeOsaDgisa227mCHW9ElgPlQivgm4cOLYyBVZSDXInq4EVvjHX)anlEjxAiag(X2o6F7IfBAFybIoYcipGQfcuN42(WcYslG8aQwiqDA7IfBa4d5FagY(suyEVjkid1BeW0a4zZs7kEwwsnUUdH792xIcZ7nrbzOEJaMgapBw8sUBGW9ERscJ)bAw8sU0qam8JTDCZwUq4EVTGeqyEVjkiJt2BwaPj5uxMJlUz7IfBu)knYewD8dsz4Q(V3ENXsALVdbmq)0SastYPUmhx4kQixjdnKws1L3z7IfBGW9EBbjGW8EtuqgNS3S4LCPHay4hBlb3SD7Txur(t1vo8bWhJOI8htpRbwJOrCus4qYkHvnaPk44cwPNtdGNnRschswjdejaUq4EVvjHX)anlE5TFPwQdTlD6oKSMdMdjQi)5q9SghYj79dbrhciZHspwhstgmDIVOai1Idja6q)CivdRdbem0HY6HGO(7Cix0pwhsFsaDhsM2HYrjGrI8Ndja6qT3zoKmTdT0GlDrfP6qyWfqlL5qq4E)HY6HMpoKOICLShAxcou6X6qoe2hqhkNdP9)OlNd5FG2HKPDOk(4taDOSEia5buTqG6ewhAxcou6pKdDOczLouuqhAxkrXH6egAAcG)dr7kEwwsnSouuqhQrq4E)H65OJAhk(dLXHY6HMpoeEPDxcou6pKdH9b0H0XpiL5qY0oe2Rw57qGdb9t7qQ)7T3zouwpeE5HKPDiAiTKQhsa0HGO(7CODW6qp4qP)qoe2hqhI3etrCiVqhsM2Hw6)S(6OdPAhkRhcV0E7xQL6qIkYFQUYHpa(yevK)y6znWAenIZ70DizLWk9CAa8SzFNUdjRKbIea3nBu)3BVZyJcGulmqKaSastYPIn3Wv9FV9oJvtgmDYcinjNk2CdxGGHwEh3Wfc37T5OeWir(JT9odxiCV3crGkb0zGibyBVZSDXInq4EVv7)rxog)d0S4LCBFyR4JpbKfqEavleOoTDXInq4EVv7)rxog)d0S4LCHW9EBbjGW8EtuqgNS3S4LBxSydeU3B1(F0LJX)anlEj3nq4EVLu9SSsMo(ialE5Ifq4EVLu9SSsM63fGfVClx3b4d5FagY(suyEVjkid1BeW0a4zZs7kEwwsTTlwSbGpK)byi7lrH59MOGmuVratdGNnlTR4zzj146oeU3BFjkmV3efKH6ncyAa8SzXl3UyXg1VsJmHDsmfHXlex1)927mw1pRVoYefKPwMGmQwaPj5uxMJlBxSyJ6xPrMWQJFqkdx1)927mwsR8DiGb6NMfqAso1L54cxrf5kzOH0sQU8oB3E7fvK)uDLdFa8XiQi)X0ZAG1iAeN3P7qYkHvnaPk44cwPNtdGNn770DizLmqKa4cH79wT)hD5y8pqZIxE7xQdHD8hYHouHSshc7b)kbihQtyOPja(peTR4zzj1oKmTdbjDzu0HeVpNm4)qs9qYHcPttCih6qvNmufhkN4pK2)JUCoK)bAhYPGgALahkkOd15xja5qq4E)HY6HK4qp4qqu)Do0ohQsQBVOI8NQRC4dGpgrf5pMEwdSgrJ405xja5Xk9C2SbGpK)byiBNFLaKQX3jkYbJbtp1kRKL2v8SSKAB5UjKonHfs6YOiJ495Kb)wAeOo12YDdeU3B78ReGun(orroymy6PwzLS4LB5Ubc37TD(vcqQgFNOihmgm9uRSswaPj5uxMZoB3E7xQdHD8hYHouHSshc7b)kbihQtyOPja(peTR4zzj1oKmTd5jG0pK495Kb)hsQhsouiDAId5qhQ6KHQ4q5e)H8eq6hY)aTd5uqdTsGdff0H68ReGCiiCV)qz9qsCOhCiiQ)ohANdvj1Txur(t1vo8bWhJOI8htpRbwJOrC68ReGOWk9C2SbGpK)byiBNFLaKQX3jkYbJbtp1kRKL2v8SSKAB5UjKonH1taPBeVpNm43sJa1P2wUBGW9EBNFLaKQX3jkYbJbtp1kRKfVCl3nq4EVTZVsas147ef5GXGPNALvYcinjN6YC2z72B)sDiSJ)qoe2hqhso0KykcVqhsM2HCOd1(b7hhYrM4qXFiLeoKSs89oDhswjSoKmTd5qhQqwPdbjDzueFEci9djEFozW)HcPttqnSo0Uybn0kboK6N1xhDiv7qz9q4LhYHou1jdvXHYj(djEFozW)H8pq7qXFiLuJdLbwhQGa0H0(F0LZH8pqZE7fvK)uDLdFa8XiQi)X0ZAG1iAeNx9Z6RJWk9CQue5GPARfPpm(hyu)S(6iUB2esNMWcjDzuKr8(CYGFlncuNAB5UX9gapBwLeoKSsgisaB5UX9gapB23P7qYkzGibSL7g1VsJmHDsmfHXlex1)927mw1pRVoYefKPwMGmQwaPj5uxMJlB3E7xQdHD8hYHW(a6qYHMetr4f6qY0oKdDO2py)4qoYehk(dPKWHKvIV3P7qYkH1HKPDih6qfYkDiiPlJI4ZtaPFiX7Zjd(puiDAcQH1H2flOHwjWHu)S(6OdPAhkRhcV8qo0HQozOkouoXFiX7Zjd(pK)bAhk(dPKACOmW6qfeGoKsc)d0oK)bA2BVOI8NQRC4dGpgrf5pMEwdSgrJ4Ou)S(6iSspNkfroyQ2Ar6dJ)bg1pRVoI7MnH0PjSEciDJ495Kb)wAeOo12YDJ7naE2SkjCizLmqKa2YDJ7naE2SVt3HKvYarcyl3nQFLgzc7KykcJxiUQ)7T3zSQFwFDKjkitTmbzuTastYPUmhx2U92lQi)P6kh(usVBevK)y6znWAenIJwgjgjYFU9IkYFQUYHpa(yevK)y6znWAenIdejGB)Txur(t1crcGdejaJ)bAyLEoUdH79wisag)d0S4L3Erf5pvlejax5WhqwP5XRgpGg9j)3Erf5pvlejax5WN6N1xhzIcYultqgvSsph3Ba8Szvs4qYkzGibW19gapB23P7qYkzGibC7fvK)uTqKaCLdFqeOsaDgisayLEoBGW9ElqwP5XRgpGg9j)w8YflCx9R0ityxPjk4hS92lQi)PAHib4kh(YrjGrI8hSspNnq4EVfiR084vJhqJ(KFlE5IfUR(vAKjSR0ef8d2E7fvK)uTqKaCLdFqeOsaD5GbR0ZzdeU3BHiqLa6mqKaS4LlwaH792CucyKi)XGbxaTugZ7n4G6RS4LBV9IkYFQwisaUYHpPjLrUsMQJa0Wk9C24E7dR0KYixjt1raAMMOjyiBKkD5GHR7IkYFSstkJCLmvhbOzAIMGHS5y89etrWDJ7TpSstkJCLmvhbOzkiPBJuPlhmlw0(WknPmYvYuDeGMPGKUfqAsovS52Tlw0(WknPmYvYuDeGMPjAcgYwdrPBz3YT9HvAszKRKP6iantt0emKfqAso1L1p32hwPjLrUsMQJa0mnrtWq2iv6YbZ2BVOI8NQfIeGRC4lkasTWarcaRqayOWKEoaYdOAHa1PflAFyJcGulmqKaS1qu6w2TlwSP9HnkasTWarcWwdrPB5DZfGpK)byiBh37LC84vQziniGOilTR4zzj12UyHOICLm0qAjvXgNDF7fvK)uTqKaCLdFA)p(eqyLEoB2aH79wmsxurQmyWfqlLXIxULROICLm0qAjvxENTlwSzdeU3BXiDrfPYGbxaTuglE5wUU3(WQ9)4tazJuPlhmCfvKRKHgslPk2CHBiamuyJuJmXBAjHnx2z7Txur(t1crcWvo8P9)4taHv65SP9Hv7)XNaYcinjN6YCCl3nq4EVfJ0fvKkdgCb0szS4LB5kQixjdnKwsvSPFUHaWqHnsnYeVPLe2CzNT3Erf5pvlejax5WNMmy6ewPNdqWq2g5tvgyZf3WTsrKdMQvtgmDYO9a62lQi)PAHib4kh(0(F8jGWk9C2aipGQfcuN4kQixjdnKws1L3HBiamuyJuJmXBAjHnx2z7IfBCV9Hv7)XNaYgPsxoy4kQixjdnKwsvS5c3qayOWgPgzI30scBUSZ2BVOI8NQfIeGRC4R6KLewPNdeU3BZrjGrI8hdgCb0szmV3GdQVY2ENHleU3BHiqLa6mqKaST3z4kQixjdnKwsvSXz33Erf5pvlejax5WNMG3Xk9CGW9EBokbmsK)yXl5kQixjdnKws1L3zXciCV3crGkb0zGibyXl5kQixjdnKws1L352lQi)PAHib4kh(0e8owPNZgiCV3wLvbdzuVgKeYe2AikDyJJlB5Ubc37TX)rHrMMr1fhlE5wUq4EVnhLagjYFS4LCfvKRKHgslPkNDU9IkYFQwisaUYHpnzW0jSsphiCV3MJsaJe5pw8sUIkYvYqdPLuDzoU92lQi)PAHib4kh(0e8owPNZMnBGW9EB8FuyKPzuDXXwdrPdBC2z7IfBGW9EB8FuyKPzuDXXIxYfc37TX)rHrMMr1fhlG0KCQl7Iv)BxSydeU3BRYQGHmQxdsczcBneLoSXXTB3YvurUsgAiTKQl72T3Erf5pvlejax5WxuaKAHbIeawPNJOICLm0qAjvXMl3Erf5pvlejax5WNMmy6ewPNZMnabdT8sWnB5kQixjdnKws1LD72fl2SbiyOLxI6Flxrf5kzOH0sQUSB5gsNMWwF8U59MOGm(hq1WsJa1P22BVOI8NQfIeGRC4ReVVsGuFsyP4x1jtiamuu54cwPNt7dBuaKAHbIeGTgIsh2252lQi)PAHib4kh(IcGulmqKaU9IkYFQwisaUYHpnbVJv65iQixjdnKws1LD7Txur(t1crcWvo8vDYsYarc42lQi)PAHib4kh(sWpECawPNdqWq2g5tvglVB3Wfc37Tj4hpoWcinjN6YUXQ)B)Txur(t1QLrIrI8hoj4hpoaR0Zjh1RLdgtt0emKr)vSLGF84att0emKjkauT47nUq4EVnb)4XbwaPj5ux2T6JfsnOBVOI8NQvlJeJe5pUYHpanKJ0Xk9Ccz0LdgUfK0JcBPkwEj1)Txur(t1QLrIrI8hx5WNhqJ(mPMbqyOHasK)Gv65eYOlhmCliPhf2svS8sQ)BVOI8NQvlJeJe5pUYHpsR8DiGb6NgwPNZg3Ba8Szvs4qYkzGibW19gapB23P7qYkzGibSDXcrf5kzOH0sQIno7C7fvK)uTAzKyKi)Xvo8bjaDvD5Gv65eYOlhmCliPhf2svSm2v)CZr9A5GX0enbdz0FfBUX6I(ybj9OWQj67Txur(t1QLrIrI8hx5WxfhSMRs3KtnYrfvSsphiCV3wXbR5Q0n5uJCur12ENHleU3BHeGUQUCST3z4wqspkSLQy5L0nCZr9A5GX0enbdz0FfBUXUJ(1hliPhfwnrFV93Erf5pvR6)E7DMkNYpYFU9IkYFQw1)927mvx5Whu))MXJd4)2lQi)PAv)3BVZuDLdFqeOsaD5G52lQi)PAv)3BVZuDLdFcqjdzIhaOjU9IkYFQw1)927mvx5WxpXuevZsB8ggnAIBVOI8NQv9FV9ot1vo85tab1)VD7fvK)uTQ)7T3zQUYHpzuunas3OKE)2lQi)PAv)3BVZuDLdFqGSg9CWy84aSsphiCV3crcW4FGMfV82lQi)PAv)3BVZuDLdF5OeWir(dwPNZM2hwT)hFciBKkD5GzXcrf5kzOH0sQInx2YT9HnkasTWarcWgPsxoyU9IkYFQw1)927mvx5WhebQeq3Txur(t1Q(V3ENP6kh(WRKjdsdlY7jvygrJ4O4x1)a8tQmqDPg3Erf5pvR6)E7DMQRC4dVsMmiT6T)2lQi)PAvs4qYkXPe8o9BVOI8NQvjHdjRKRC4tjHX)anSsph3HW9ERscJ)bAw8YBVOI8NQvjHdjRKRC4di6iSsphiCV3wcENUfV82lQi)PAvs4qYk5kh(kibeM3BIcY4K9gwPNtiDAcBbjGW8EtuqgNS3S0iqDQX1DiCV3wqcimV3efKXj7nlE5Txur(t1QKWHKvYvo8rALVdbmq)0Wk9CAa8Szvs4qYkzGibC7fvK)uTkjCizLCLdFarhHv650(WceDKfqEavleOoXv9AqVP8ZjQlV7BVOI8NQvjHdjRKRC4dKLyLEoTpSGS0cipGQfcuN4QEnO3u(5evSXz33Erf5pvRschswjx5WN6N1xhzIcYultqgvSspNgapBwLeoKSsgisa3Erf5pvRschswjx5WNNaVkF8QbkdclnrFn0qam8ZXfSsph1Rb9MYpNOIno7(2lQi)PAvs4qYk5kh(KMug5kzQocqdR0ZzJ7TpSstkJCLmvhbOzAIMGHSrQ0LdgUUlQi)XknPmYvYuDeGMPjAcgYMJX3tmfb3nU3(WknPmYvYuDeGMPGKUnsLUCWSyr7dR0KYixjt1raAMcs6waPj5uXMB3Uyr7dR0KYixjt1raAMMOjyiBneLULDl32hwPjLrUsMQJa0mnrtWqwaPj5uxw)CBFyLMug5kzQocqZ0enbdzJuPlhmBV9IkYFQwLeoKSsUYHVAbGAyLEoQxd6nLFor1QWbaAIL1)T)2lQi)PAvQFwFDehLeg)d0U9IkYFQwL6N1xh5kh(kibeM3BIcY4K9gwPNtiDAcBbjGW8EtuqgNS3S0iqDQX1DiCV3wqcimV3efKXj7nlE5Txur(t1Qu)S(6ix5WN6N1xhzIcYultqgvSspN6J3HYPz9jOgMAasDKLgbQtnUq4EV1NGAyQbi1rw8YBVOI8NQvP(z91rUYHp1pRVoYefKPwMGmQyLEoH0PjSfKacZ7nrbzCYEZsJa1PgxiCV3wqcimV3efKXj7nlE5Txur(t1Qu)S(6ix5WN6N1xhzIcYultqgvSspNq60e2csaH59MOGmozVzPrG6uJR6)E7DgBbjGW8EtuqgNS3SastYPInx0)Txur(t1Qu)S(6ix5WN6N1xhzIcYultqgvSsph3dPttylibeM3BIcY4K9MLgbQtTB)Txur(t125xjarXrjHX)aTB)Txur(t125xja55O9)OlhJ)bA3(BVOI8NQ9v)S(6ioA)p6YX4FG2Txur(t1(QFwFDKRC4RGeqyEVjkiJt2ByLEoH0PjSfKacZ7nrbzCYEZsJa1Pgx3HW9EBbjGW8EtuqgNS3S4L3Erf5pv7R(z91rUYHp1pRVoYefKPwMGmQyLEo1hVdLtZ6tqnm1aK6ilncuNACHW9ERpb1WudqQJS4L3Erf5pv7R(z91rUYHVAiaFciSsphs1ZYkzLHFZq6BSybP6zzLS1VlaZq6BC7fvK)uTV6N1xh5kh(CasuGv65qQEwwjRm8BgsFJflivplRKTJpcWmK(g3Erf5pv7R(z91rUYHp1pRVoYefKPwMGmQyLEoH0PjSfKacZ7nrbzCYEZsJa1PgxiCV3wqcimV3efKXj7nlE5Txur(t1(QFwFDKRC4t9Z6RJmrbzQLjiJkwPNtiDAcBbjGW8EtuqgNS3S0iqDQXv9FV9oJTGeqyEVjkiJt2BwaPj5uXMl6)2lQi)PAF1pRVoYvo8P(z91rMOGm1YeKrfR0ZX9q60e2csaH59MOGmozVzPrG6u72F7fvK)uTVt3HKvIJ2)JUCm(hOHv654oeU3B1(F0LJX)anlE5Txur(t1(oDhswjx5WxbjGW8EtuqgNS3Wk9CcPttylibeM3BIcY4K9MLgbQtnUUdH792csaH59MOGmozVzXlV9IkYFQ23P7qYk5kh(QHaQ4am0Txur(t1(oDhswjx5WN6N1xhzIcYultqgvSspN6J3HYPz9jOgMAasDKLgbQtTBVOI8NQ9D6oKSsUYHpsR8DiGb6NgwPNtdGNn770DizLmqKaU9IkYFQ23P7qYk5kh(KMug5kzQocqdR0ZzJ7TpSstkJCLmvhbOzAIMGHSrQ0LdgUUlQi)XknPmYvYuDeGMPjAcgYMJX3tmfb3nU3(WknPmYvYuDeGMPGKUnsLUCWSyr7dR0KYixjt1raAMcs6waPj5uXMB3Uyr7dR0KYixjt1raAMMOjyiBneLULDl32hwPjLrUsMQJa0mnrtWqwaPj5uxw)CBFyLMug5kzQocqZ0enbdzJuPlhmBV9IkYFQ23P7qYk5kh(Q4Jpbewk(vDYecadfvoUGv65aipGQfcuNU9IkYFQ23P7qYk5kh(0(F8jGWsXVQtMqayOOYXfSspha5buTqG60Ifq4EVfJ0fvKkdgCb0szS4L3Erf5pv770DizLCLdF1qa(eqyLEoQFLgzc7KykcJxiUKQNLvYkd)MH0342lQi)PAFNUdjRKRC4ZbirbwPNJ7QFLgzc7KykcJxiUKQNLvYkd)MH0342lQi)PAFNUdjRKRC4t9Z6RJmrbzQLjiJkwPNZgiCV3sQEwwjthFeGfVCXciCV3sQEwwjt97cWIxU92lQi)PAFNUdjRKRC4RgcWNacR0ZzdP6zzLS5y64JawSGu9SSs263fGzi9n2UyXgs1ZYkzZX0XhbWfc37T1qavCagYqALVdb0OjmD8raw8YT3Erf5pv770DizLCLdFoajkyblyma]] )


end