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

    spec:RegisterPack( "Guardian", 20210708, [[dCKRQbqirQEKsfAtOIprrvmkLuNsjzvuKqVsKYSquUffvP2fL(fQQggQIogfXYuk1ZOOY0qvORrrQTHQaFJIKmoksQZPurzDkvqmpLsUhQ0(uQ0bvQiYcPO8qLkstuPcsxKIQKpQur4KuKOvQu1mvQOQBQuru7evLFsrcEkOMkQsFvPIk7fL)sQbJ0HjwmipMKjlvxgAZI6ZiYOLItlSALkOETiz2sCBkSBf)wvdxkDCuf0Yv55sA6uDDe2Us8DrmEkQQZJOA9kvG5RuSFGzMW4Lb3fhz8Tnp32eEAQ4PP2Acp3MhnN5yWo5TidUvuPesidEedKbVtqixpKHb3kKxEPZ4LbxFItHm4g3BR7q4NFsH3qazvVb)1WGOiE8J6KSZFnmu8ZGHiIIBkhgedUloY4BBEUTj80uXttT1eEUnpAotyWcH38hdgom2Pm4MO3XHbXG7yvXG3jiKRhYaO7qpIOd2VNOqoGAQjdq3MNBZtWEW(DAJmKW6oeWEZBa1uoQ)A)tCeq3PIZ)o5)NuXaOTx8x4bwb01rgqRO7XqcqJkGQAqvkSVYc2BEdOMYr9x7FIJa636XpaQ)aATjYoGU(paDEFfGcH5)qaDN(ZYNcTm4su9kJxgCHCLCYZ4LXNjmEzWIYJFyWg)pPIrN)ZGbJJavWoZmMZCgmekhJxgFMW4LbJJavWoZmgS6chVqyWPdOqe5SfcLtN)ZWs0YGfLh)WGHq505)myoJVTz8YGXrGkyNzgdwDHJximyxk442guox)zT3G6KO0T4iqfSdOCa01aQlfCClKuKrHAjNJjCYT4iqfSdORauoaQ6xWrg3UGJ3q(XGfLh)WGBq5C9N1EdQtIsN5m(mhJxgSO84hg8jl48evD(WzhqodghbQGDMzmNXhpY4LbJJavWoZmgS6chVqyWPdO9Ji6wL4jOSGAiuoaLdGMoG2pIOB)KscklOgcLJblkp(HbR(z5tHAVb1124cVYCgFMMXldghbQGDMzmy1foEHWGxdOqe5S9KfCEIQoF4Sdi3s0cOB2aOPdOQFbhzC7coEd5hGUIblkp(HbdHxfVumNXhpGXldghbQGDMzmy1foEHWGxdOqe5S9KfCEIQoF4Sdi3s0cOB2aOPdOQFbhzC7coEd5hGUIblkp(HbhJsUr84hMZ4ZuX4LbJJavWoZmgS6chVqyWRbuiIC2cHxfVuAiuolrlGUzdGcrKZ2yuYnIh)OjrixpKr)znXvFLLOfqxXGfLh)WGHWRIxQyiXCgFMAgVmyCeOc2zMXGvx44fcdEnGMoG2F3kDP1JfuxtKZq3fdHeA9qLkgsakhanDavuE8Jv6sRhlOUMiNHUlgcj0gJoxcsnoGYbqxdOPdO93TsxA9yb11e5m0nOuSEOsfdjaDZgaT)Uv6sRhlOUMiNHUbLI9qdjMkGUlGAoaDfGUzdG2F3kDP1JfuxtKZq3fdHeARUOsbOBbOMdq5aO93TsxA9yb11e5m0DXqiH2dnKyQa6waQPbuoaA)DR0LwpwqDnrodDxmesO1dvQyibORyWIYJFyWsxA9yb11e5myoJVDgJxgmocub7mZyWQlC8cHbFy(WAJavqaDZgaT)U1BoP2OHq5SvxuPa0TauZbOB2aORb0(7wV5KAJgcLZwDrLcq3cq5raLdGEedM)JeAle5SetMOIDnAaDIcTipKiABXoGUcq3SbqfLhlOgh0iWkGUlxaLhzWIYJFyWEZj1gnekhZz8zcpz8YGXrGkyNzgdwDHJxim41a6AafIiNTKKIO8qPjrixpKXs0cORauoaQO8yb14Ggbwb0Ta0Tb0va6Mna6AaDnGcrKZwssruEO0KiKRhYyjAb0vakhanDaT)U14)jhhA9qLkgsakhavuESGACqJaRa6UaQjakha1LJe6wpmqT)6EGa6UaQjBdORyWIYJFyWg)p54qMZ4Zety8YGXrGkyNzgdwDHJxim41aA)DRX)too0EOHetfq3IlGAoaLdGUgqHiYzljPikpuAseY1dzSeTa6kaLdGkkpwqnoOrGvaDxa10akha1LJe6wpmqT)6EGa6UaQjBdORyWIYJFyWg)p54qMZ4ZKTz8YGXrGkyNzgdwDHJxim4tiH2oMdv4a6UaQj8eq5aOv09yivTgYqQGAJ)qgSO84hgSHmKkiZz8zI5y8YGXrGkyNzgdwDHJxim41a6H5dRncubbuoaQO8yb14Ggbwb0Ta0TbuoaQlhj0TEyGA)19ab0Dbut2gqxbOB2aORb00b0(7wJ)NCCO1dvQyibOCaur5XcQXbncScO7cOMaOCauxosOB9Wa1(R7bcO7cOMSnGUIblkp(HbB8)KJdzoJpt4rgVmyCeOc2zMXGvx44fcdU(efOy62wIQtuqnEeTE8JfhbQGDaLdGUgqxdOQ)l9pzSEZj1gnekN9qdjMkGUlGYtaLdGQ(V0)KXAidPcAp0qIPcO7cO8eqxbOCa01aA)DRX)too0EOHetfq3LlGAoaDfGYbqxdOqe5SngLCJ4XpAseY1dz0FwtC1xz7FYaOCauiIC2cHxfVuAiuoB)tgaLdGcrKZwssruEO0KiKRhYy7FYaORa0va6MnaA9jkqX0TlFr8OG66xwWXT4iqfSZGJXX7iADDKzW1NOaft3U8fXJcQRFzbhNZA1)L(NmwV5KAJgcLZEOHetDxEYr9FP)jJ1qgsf0EOHetDxEUIbhJJ3r066WWa7H4id2egSO84hgCUG1g1jzNbhJJ3r06AsLhskmytyoJptmnJxgmocub7mZyWQlC8cHbdrKZ2yuYnIh)OjrixpKr)znXvFLT)jdGYbqHiYzleEv8sPHq5S9pzauoaQO8yb14Ggbwb0D5cO8idwuE8ddUMeTOgcLJ5m(mHhW4LbJJavWoZmgS6chVqyWqe5SngLCJ4XpwIwaLdGkkpwqnoOrGvaDlaDBaDZgafIiNTq4vXlLgcLZs0cOCaur5XcQXbncScOBbOBZGfLh)WGneIcZz8zIPIXldghbQGDMzmy1foEHWGxdOqe5STklcjuREdiXLXTvxuPa0D5cOMaORauoa6AafIiNT()EJwMUwvKelrlGUcq5aOqe5SngLCJ4XpwIwaLdGkkpwqnoOrGvaLlGUndwuE8dd2qikmNXNjMAgVmyCeOc2zMXGvx44fcdgIiNTXOKBep(Xs0cOCaur5XcQXbncScOBXfqnhdwuE8dd2qgsfK5m(mzNX4LbJJavWoZmgS6chVqyWRb01a6AafIiNT()EJwMUwvKeB1fvkaDxUa62a6kaDZgaDnGcrKZw)FVrltxRksILOfq5aOqe5S1)3B0Y01QIKyp0qIPcOBbOMynnGUcq3SbqxdOqe5STklcjuREdiXLXTvxuPa0D5cOMdqxbORauoaQO8yb14Ggbwb0TauZbORyWIYJFyWgcrH5m(2MNmEzW4iqfSZmJbRUWXlegSO8yb14Ggbwb0DbutyWIYJFyWEZj1gnekhZz8TTjmEzW4iqfSZmJbRUWXleg8AaDnGEcjeq3cq3z8eqxbOCaur5XcQXbncScOBbOMdqxbOB2aORb01a6jKqaDla1uBAaDfGYbqfLhlOgh0iWkGUfGAoaLdG6sbh3wFII(ZAVb15)WQBXrGkyhqxXGfLh)WGnKHubzoJVT3MXldghbQGDMzmyr5Xpm4wIYcEXoazWQlC8cHb3F36nNuB0qOC2QlQua6Ua62myf5QcQD5iHELXNjmNX32MJXldwuE8dd2BoP2OHq5yW4iqfSZmJ5m(2Mhz8YGXrGkyNzgdwDHJximyr5XcQXbncScOBbOMJblkp(HbBiefMZ4BBtZ4Lblkp(HbxtIwudHYXGXrGkyNzgZz8TnpGXldghbQGDMzmy1foEHWGpHeA7youHdOBbO8ipbuoakeroBJ7NmXzp0qIPcOBbO80AAgSO84hgCC)KjoMZCgSr4bjXJFy8Y4ZegVmyCeOc2zMXGvx44fcdog1BedjDxmesO20vaDxanUFYeNUlgcju7nhwB(shq5aOqe5SnUFYeN9qdjMkGUfGAoa1ueqBKQJmyr5Xpm44(jtCmNX32mEzW4iqfSZmJbRUWXlegSltQyibOCa0gukEJTv5a6wakpW0myr5Xpm4dhmrkmNXN5y8YGXrGkyNzgdwDHJximyxMuXqcq5aOnOu8gBRYb0TauEGPzWIYJFyW5dNDqGD9HKWbpXJFyoJpEKXldghbQGDMzmy1foEHWGxdOPdO9Ji6wL4jOSGAiuoaLdGMoG2pIOB)KscklOgcLdqxbOB2aOIYJfuJdAeyfq3LlGUndwuE8ddgnA)e80q)0zoJptZ4LbJJavWoZmgS6chVqyWUmPIHeGYbqBqP4n2wLdOBbOMktdOCa0yuVrmK0DXqiHAtxb0DbuEAnbqnfb0gukEJ1qmFgSO84hgmKCPQPIH5m(4bmEzW4iqfSZmJbRUWXlegmeroBRe3sSifDmvpgLxT9pzauoakeroBHKlvnvm2(NmakhaTbLI3yBvoGUfGYd4jGYbqJr9gXqs3fdHeQnDfq3fq5PDBtdOMIaAdkfVXAiMpdwuE8ddUsClXIu0Xu9yuEL5mNbRepbLfKXlJpty8YGfLh)WGBVpPWGXrGkyNzgZz8TnJxgmocub7mZyWQlC8cHbNoGcrKZwL468FgwIwgSO84hgSsCD(pdMZ4ZCmEzW4iqfSZmJbRUWXlegmeroBBVpPyjAzWIYJFyWNKczoJpEKXldghbQGDMzmy1foEHWGDPGJBBq5C9N1EdQtIs3IJavWoGYbqthqHiYzBdkNR)S2BqDsu6wIwgSO84hgCdkNR)S2BqDsu6mNXNPz8YGXrGkyNzgdwDHJxim4(reDRs8euwqnekhdwuE8ddgnA)e80q)0zoJpEaJxgmocub7mZyWQlC8cHb3F3Esk0Ey(WAJavqaLdGQEdOx3(X4vaDlaLhzWIYJFyWNKczoJptfJxgmocub7mZyWQlC8cHb3F3ErR9W8H1gbQGakhav9gqVU9JXRa6UCbuEKblkp(HbFrlZz8zQz8YGXrGkyNzgdwDHJxim4(reDRs8euwqnekhdwuE8ddw9ZYNc1EdQRTXfEL5m(2zmEzW4iqfSZmJbRUWXlegS6nGED7hJxb0D5cO8idwuE8ddoJ3RINOQHchzWgI5RXbpsKZ4ZeMZ4ZeEY4LbJJavWoZmgS6chVqyWRb00b0(7wPlTESG6AICg6UyiKqRhQuXqcq5aOPdOIYJFSsxA9yb11e5m0DXqiH2y05sqQXbuoa6AanDaT)Uv6sRhlOUMiNHUbLI1dvQyibOB2aO93TsxA9yb11e5m0nOuShAiXub0DbuZbORa0nBa0(7wPlTESG6AICg6UyiKqB1fvkaDla1CakhaT)Uv6sRhlOUMiNHUlgcj0EOHetfq3cqnnGYbq7VBLU06XcQRjYzO7IHqcTEOsfdjaDfdwuE8ddw6sRhlOUMiNbZz8zIjmEzW4iqfSZmJbRUWXlegC9jkqX0TTevNOGA8iA94hlocub7akhafh8iroGUfGAotdOB2aO1NOaft3U8fXJcQRFzbh3IJavWodoghVJO11rMbxFIcumD7YxepkOU(LfCCo4GhjY3YCMMbhJJ3r066WWa7H4id2egSO84hgCUG1g1jzNbhJJ3r06AsLhskmytyoJpt2MXldghbQGDMzmy1foEHWGvVb0RB)y8QvrChooGUfGAAgSO84hgCT5WoZzodUqUsorX4LXNjmEzWIYJFyWkX15)myW4iqfSZmJ5mNb3XSquCgVm(mHXldghbQGDMzm4owvx06XpmyZlZhveo2buCbpYbupmqa1Bqavu(FaAubuzrIIavqldwuE8ddUMIOu0qsTH5m(2MXldghbQGDMzmyr5Xpm4D43jgsyCNUJvpgYRALukmy1foEHWGthqHiYzB79jflrldEedKbVd)oXqcJ70DS6XqEvRKsH5m(mhJxgmocub7mZyWQlC8cHbNoGcrKZ227tkwIwgSO84hgmrf1HJgvMZ4Jhz8YGXrGkyNzgdwDHJxim41a6AaDnG6sbh32GY56pR9guNeLUfhbQGDaLdGcrKZ2guox)zT3G6KO0TeTa6kaLdGUgq7hr0TkXtqzb1qOCa6MnaA)iIU9tkjOSGAiuoaDfGYbqthqHiYzB79jflrlGUcq3SbqxdORbuiIC2cHxfVuAiuolrlGUzdGcrKZ2yuYnIh)OjrixpKr)znXvFLLOfqxbOCa01aA6aA)iIUvjEcklOgcLdq5aOPdO9Ji62pPKGYcQHq5a0va6kaDfdwuE8ddU994hMZ4Z0mEzW4iqfSZmJbRUWXlegC)iIUvjEcklOgcLdq5aOqe5SvjUo)NHLOLbx9luoJptyWIYJFyWhXOfLh)Olr1zWLO66rmqgSs8euwqMZ4JhW4LbJJavWoZmgS6chVqyW9Ji62pPKGYcQHq5auoakeroBn(FsfJo)NHLOLbx9luoJptyWIYJFyWhXOfLh)Olr1zWLO66rmqg8NusqzbzoJptfJxgmocub7mZyWDSQUO1JFyWMYmGMGaAJSGa6op5k5eaTGKWPlh5akYdjI2wSdOY0buiPiJcbujNJjCYbuPcOcG6sbhhqtqaTMeUQbqJXFa14)jvmaA(pdanPbhCbpa1BqaTqUsobqHiYzanQaQ4a6Fakew(eaDBaTIkgSO84hg8rmAr5Xp6suDgS6chVqyWRb01a6rmy(psOTqUsoPQZfe9yiPjvcJ2kArEir02IDaDfGYbqxdOUuWXTqsrgfQLCoMWj3IJavWoGUcq5aORbuiIC2wixjNu15cIEmK0KkHrBfTeTa6kaLdGUgqHiYzBHCLCsvNli6XqstQegTv0EOHetfq3IlGUnGUcqxXGlr11JyGm4c5k5KN5m(m1mEzW4iqfSZmJb3XQ6Iwp(HbBkZaAccOnYccO78KRKta0cscNUCKdOipKiABXoGkthqZ4jfavY5ycNCavQaQaOUuWXb0eeqRjHRAa0y8hqZ4jfan)NbGM0GdUGhG6niGwixjNaOqe5mGgvavCa9pafclFcGUnGwrfdwuE8dd(igTO84hDjQodwDHJxim41a6Aa9igm)hj0wixjNu15cIEmK0KkHrBfTipKiABXoGUcq5aORbuxk442mEsrl5CmHtUfhbQGDaDfGYbqxdOqe5STqUsoPQZfe9yiPjvcJ2kAjAb0vakhaDnGcrKZ2c5k5KQoxq0JHKMujmARO9qdjMkGUfxaDBaDfGUIbxIQRhXazWfYvYjkMZ4BNX4LbJJavWoZmgChRQlA94hgSPmdOjO55qava0ji14zbbuz6aAccO9FmpoGMiJdO(dOkXtqzb5)tkjOSGKbOY0b0eeqBKfeqHKImkK)mEsbqLCoMWjhqDPGJJDYa0DUgCWf8au1plFkeqvDanQakrlGMGaAnjCvdGgJ)aQKZXeo5aA(pda1FavjvhqdNmaTbpeqn(FsfdGM)ZWYGfLh)WGpIrlkp(rxIQZGvx44fcdUIUhdPQT2ezxN)tR(z5tHakhaDnGUgqDPGJBHKImkul5CmHtUfhbQGDaDfGYbqxdOPdO9Ji6wL4jOSGAiuoaDfGYbqxdOPdO9Ji62pPKGYcQHq5a0vakhaDnGQ(fCKXTtqQX1zbbuoaQ6)s)tgR6NLpfQ9guxBJl8Q9qdjMkGUfxa1eaDfGUIbxIQRhXazWV6NLpfYCgFMWtgVmyCeOc2zMXG7yvDrRh)WGnLzanbnphcOcGobPgpliGkthqtqaT)J5Xb0ezCa1FavjEckli)FsjbLfKmavMoGMGaAJSGakKuKrH8NXtkaQKZXeo5aQlfCCStgGUZ1GdUGhGQ(z5tHaQQdOrfqjAb0eeqRjHRAa0y8hqLCoMWjhqZ)zaO(dOkP6aA4KbOn4HaQs88FgaA(pdldwuE8dd(igTO84hDjQodwDHJxim4k6EmKQ2AtKDD(pT6NLpfcOCa01a6Aa1LcoUnJNu0soht4KBXrGkyhqxbOCa01aA6aA)iIUvjEcklOgcLdqxbOCa01aA6aA)iIU9tkjOSGAiuoaDfGYbqxdOQFbhzC7eKACDwqaLdGQ(V0)KXQ(z5tHAVb1124cVAp0qIPcOBXfqnbqxbORyWLO66rmqgSs9ZYNczoJptmHXldghbQGDMzmyr5XpmyLukAr5Xp6suDgCjQUEedKbBeEqs84hMZ4ZKTz8YGXrGkyNzgdwuE8dd(igTO84hDjQodUevxpIbYGHq5yoZzWThQEdiXz8Y4ZegVmyCeOc2zMXG7yvDrRh)WGnVmFur4yhqHW8FiGQEdiXbuiKumvlGUtsPWwVcOZpM3nYzKjkaQO84NkG(tHCldwuE8ddovm9d76ABCHxzoJVTz8YGXrGkyNzgdwDHJximyiIC2QexN)ZWs0cOCa0(reDRs8euwqnekhdwuE8ddU9(KcZz8zogVmyCeOc2zMXGvx44fcd2LcoUTbLZ1Fw7nOojkDlocub7akhaDnG2pIOBvINGYcQHq5auoakeroBvIRZ)zyjAb0nBa0(reD7Nusqzb1qOCakhafIiNTg)pPIrN)ZWs0cOB2aOqe5S14)jvm68FgwIwaLdG6sbh3cjfzuOwY5ycNClocub7a6kgSO84hgCdkNR)S2BqDsu6mNXhpY4LbJJavWoZmgS6chVqyWPdOqe5SvgY15)mSeTakhaDnGUgqthq7hr0TFsjbLfudHYbOCa00b0(reDRs8euwqnekhGUcq5aORb00bu1VGJmUDcsnUoliGUcqxbOB2aORb01aA6aA)iIU9tkjOSGAiuoaLdGMoG2pIOBvINGYcQHq5a0vakhaDnGQ(fCKXTtqQX1zbbuoaQlfCC7Hv)pXJF0soht4KBXrGkyhqxbOB2aOQFbhzC7coEd5hGUIblkp(HbdHYPZ)zWCgFMMXldghbQGDMzmy1foEHWGHiYzRX)tQy05)mSeTakhaTFer3(jLeuwqnekhGYbqthqv)coY42ji146SGmyr5Xpm4Kt8gMZ4JhW4LbJJavWoZmgS6chVqyWqe5S14)jvm68FgwIwaLdG2pIOB)KscklOgcLdq5aOQFbhzC7eKACDwqgSO84hgC1LlhhYCgFMkgVmyCeOc2zMXGvx44fcdU(efOy62wIQtuqnEeTE8JfhbQGDaDZgaT(efOy62LViEuqD9ll44wCeOc2zWX44DeTUoYm46tuGIPBx(I4rb11VSGJZGJXX7iADDyyG9qCKbBcdwuE8ddoxWAJ6KSZGJXX7iADnPYdjfgSjmN5my1)L(NmvgVm(mHXldwuE8ddU994hgmocub7mZyoJVTz8YGfLh)WGHk)31zIJCgmocub7mZyoJpZX4Lblkp(HbdHxfVuXqIbJJavWoZmMZ4Jhz8YGfLh)WGLtjdQ9)oCCgmocub7mZyoJptZ4Lblkp(HbxcsnEvVdt0jzGJZGXrGkyNzgZz8Xdy8YGfLh)WGZXHqL)7myCeOc2zMXCgFMkgVmyr5Xpmyzuy1pPOvsPWGXrGkyNzgZz8zQz8YGXrGkyNzgdwDHJximyiIC2cHYPZ)zyjAzWIYJFyWqxu9smK0zIJ5m(2zmEzW4iqfSZmJbRUWXleg8AaT)U14)jhhA9qLkgsa6MnaQO8yb14Ggbwb0Dbuta0vakhaT)U1BoP2OHq5SEOsfdjgSO84hgCmk5gXJFyoJpt4jJxgSO84hgmeEv8sXGXrGkyNzgZz8zIjmEzW4iqfSZmJblkp(HbRixvE)(juAOIuDgmMZOY1JyGmyf5QY73pHsdvKQZCgFMSnJxgSO84hgmrf1HJgvgmocub7mZyoZzWV6NLpfY4LXNjmEzWIYJFyWg)pPIrN)ZGbJJavWoZmMZ4BBgVmyCeOc2zMXGvx44fcd2LcoUTbLZ1Fw7nOojkDlocub7akhanDafIiNTnOCU(ZAVb1jrPBjAzWIYJFyWnOCU(ZAVb1jrPZCgFMJXldghbQGDMzmy1foEHWGRprbkMUnhx11v)IuOfhbQGDaLdGcrKZ2CCvxx9lsHwIwgSO84hgS6NLpfQ9guxBJl8kZz8XJmEzW4iqfSZmJbRUWXlegmQkrBfTYqUEqZ3b0nBauuvI2kARFro9GMVZGfLh)WGRUC54qMZ4Z0mEzW4iqfSZmJbRUWXlegmQkrBfTYqUEqZ3b0nBauuvI2kAleJC6bnFNblkp(HbNCI3WCgF8agVmyCeOc2zMXGvx44fcd2LcoUTbLZ1Fw7nOojkDlocub7akhafIiNTnOCU(ZAVb1jrPBjAzWIYJFyWQFw(uO2BqDTnUWRmNXNPIXldghbQGDMzmy1foEHWGDPGJBBq5C9N1EdQtIs3IJavWoGYbqv)x6FYyBq5C9N1EdQtIs3EOHetfq3fqnX0myr5Xpmy1plFku7nOU2gx4vMZ4ZuZ4LbJJavWoZmgS6chVqyWPdOUuWXTnOCU(ZAVb1jrPBXrGkyNblkp(HbR(z5tHAVb1124cVYCMZGvQFw(uiJxgFMW4Lblkp(HbRexN)ZGbJJavWoZmMZ4BBgVmyCeOc2zMXGvx44fcd2LcoUTbLZ1Fw7nOojkDlocub7akhanDafIiNTnOCU(ZAVb1jrPBjAzWIYJFyWnOCU(ZAVb1jrPZCgFMJXldghbQGDMzmy1foEHWGRprbkMUnhx11v)IuOfhbQGDaLdGcrKZ2CCvxx9lsHwIwgSO84hgS6NLpfQ9guxBJl8kZz8XJmEzW4iqfSZmJbRUWXlegSlfCCBdkNR)S2BqDsu6wCeOc2buoakeroBBq5C9N1EdQtIs3s0YGfLh)WGv)S8PqT3G6ABCHxzoJptZ4LbJJavWoZmgS6chVqyWUuWXTnOCU(ZAVb1jrPBXrGkyhq5aOQ)l9pzSnOCU(ZAVb1jrPBp0qIPcO7cOMyAgSO84hgS6NLpfQ9guxBJl8kZz8Xdy8YGXrGkyNzgdwDHJxim40buxk442guox)zT3G6KO0T4iqfSZGfLh)WGv)S8PqT3G6ABCHxzoZzWFsjbLfKXlJpty8YGXrGkyNzgdwDHJxim40buiIC2A8)KkgD(pdlrldwuE8dd24)jvm68FgmNX32mEzW4iqfSZmJbRUWXlegSlfCCBdkNR)S2BqDsu6wCeOc2buoaA6akeroBBq5C9N1EdQtIs3s0YGfLh)WGBq5C9N1EdQtIsN5m(mhJxgSO84hgC1LRsCKqgmocub7mZyoJpEKXldghbQGDMzmy1foEHWGRprbkMUnhx11v)IuOfhbQGDgSO84hgS6NLpfQ9guxBJl8kZz8zAgVmyCeOc2zMXGvx44fcdUFer3(jLeuwqnekhdwuE8ddgnA)e80q)0zoJpEaJxgmocub7mZyWQlC8cHbVgqthq7VBLU06XcQRjYzO7IHqcTEOsfdjaLdGMoGkkp(XkDP1JfuxtKZq3fdHeAJrNlbPghq5aORb00b0(7wPlTESG6AICg6gukwpuPIHeGUzdG2F3kDP1JfuxtKZq3GsXEOHetfq3fqnhGUcq3Sbq7VBLU06XcQRjYzO7IHqcTvxuPa0TauZbOCa0(7wPlTESG6AICg6UyiKq7HgsmvaDla10akhaT)Uv6sRhlOUMiNHUlgcj06HkvmKa0vmyr5XpmyPlTESG6AICgmNXNPIXldghbQGDMzmyr5Xpm4kXKJdzWQlC8cHbFy(WAJavqgSICvb1UCKqVY4ZeMZ4ZuZ4LbJJavWoZmgSO84hgSX)tooKbRUWXleg8H5dRncubb0nBauiIC2sskIYdLMeHC9qglrldwrUQGAxosOxz8zcZz8TZy8YGXrGkyNzgdwDHJximy1VGJmUDcsnUoliGYbqrvjAROvgY1dA(odwuE8ddU6YLJdzoJpt4jJxgmocub7mZyWQlC8cHbNoGQ(fCKXTtqQX1zbbuoakQkrBfTYqUEqZ3zWIYJFyWjN4nmNXNjMW4LbJJavWoZmgS6chVqyWRbuiIC2IQs0wrDHyKZs0cOB2aOqe5SfvLOTI66xKZs0cORyWIYJFyWQFw(uO2BqDTnUWRmNXNjBZ4LbJJavWoZmgS6chVqyWRbuuvI2kAJrxig5a0nBauuvI2kARFro9GMVdORa0nBa01akQkrBfTXOleJCakhafIiNTvxUkXrc1Or7NGNboUUqmYzjAb0vmyr5Xpm4QlxooK5m(mXCmEzWIYJFyWjN4nmyCeOc2zMXCMZCg8cE14hgFBZZTnHNMkEAAgCICtmKQmytPr7Fo2butmbqfLh)aOLO6vlypdU2IkgFMWtEKb3EFokidEhb0Dcc56Hma6o0Ji6G97iGUNOqoGAQjdq3MNBZtWEW(Deq3PnYqcR7qa73ra18gqnLJ6V2)ehb0DQ48Vt()jvmaA7f)fEGvaDDKb0k6EmKa0OcOQguLc7RSG97iGAEdOMYr9x7FIJa636XpaQ)aATjYoGU(paDEFfGcH5)qaDN(ZYNcTG9G97iGAEz(OIWXoGcH5)qav9gqIdOqiPyQwaDNKsHTEfqNFmVBKZituaur5Xpva9Nc5wWEr5XpvB7HQ3as804YFQy6h21124cVc2lkp(PABpu9gqINgx(BVpPqwK5crKZwL468FgwIwo9Ji6wL4jOSGAiuoWEr5XpvB7HQ3as804YFdkNR)S2BqDsu6KfzUUuWXTnOCU(ZAVb1jrPBXrGkyNZ6(reDRs8euwqnekhhiIC2QexN)ZWs0Uzt)iIU9tkjOSGAiuooqe5S14)jvm68FgwI2nBGiYzRX)tQy05)mSeTCCPGJBHKImkul5CmHtUfhbQG9vG9IYJFQ22dvVbK4PXLFiuoD(pdYIm30HiYzRmKRZ)zyjA5SED69Ji62pPKGYcQHq54KE)iIUvjEcklOgcLBfN1PR(fCKXTtqQX1zbxTAZM1RtVFer3(jLeuwqnekhN07hr0TkXtqzb1qOCR4Sw9l4iJBNGuJRZcYXLcoU9WQ)N4XpAjNJjCYT4iqfSVAZg1VGJmUDbhVH8BfyVO84NQT9q1BajEAC5p5eVHSiZfIiNTg)pPIrN)ZWs0YPFer3(jLeuwqnekhN0v)coY42ji146SGG9IYJFQ22dvVbK4PXL)QlxooKSiZfIiNTg)pPIrN)ZWs0YPFer3(jLeuwqnekhh1VGJmUDcsnUoliyVO84NQT9q1BajEAC5pxWAJ6KStwK5wFIcumDBlr1jkOgpIwp(XIJavW(Mn1NOaft3U8fXJcQRFzbh3IJavWozX44DeTUommWEioY1eYIXX7iADnPYdjfUMqwmoEhrRRJm36tuGIPBx(I4rb11VSGJd2d2VJaQ5L5Jkch7akUGh5aQhgiG6niGkk)panQaQSirrGkOfSxuE8tLBnfrPOHKAdyVO84NAAC5NOI6WrdYgXa5Ud)oXqcJ70DS6XqEvRKsHSiZnDiIC22EFsXs0c2lkp(PMgx(jQOoC0OswK5MoeroBBVpPyjAb7fLh)utJl)TVh)qwK5UE9Axk442guox)zT3G6KO0T4iqfSZbIiNTnOCU(ZAVb1jrPBjAxXzD)iIUvjEcklOgcLBZM(reD7Nusqzb1qOCR4KoeroBBVpPyjAxTzZ61qe5SfcVkEP0qOCwI2nBGiYzBmk5gXJF0KiKRhYO)SM4QVYs0UIZ607hr0TkXtqzb1qOCCsVFer3(jLeuwqnek3QvRa73XDeq3PINGYsmKaur5XpaAjQoGMeLcGcHa6jdGgzYaudzivq(9MtQnaQCiG(dGQ6KbONqcb0OcOqy5tauEKNKbO7a8sbOY0b0yuYnIh)aOYHaA)tgavMoGUtqifr5HcqjrixpKbqHiYzanQa68oGkkpwqYa0)a0itgGMGMNdb0yauL45)mauz6ako4rICanQaQa9liGUTPjdqnfoanYaAccOnYccOEdcOMcI3aOfKeoD5ihqrEir02IDYauVbb0ocrKZaAjMuyhq9hqdhqJkGoVdOeTaQmDafh8iroGgvavG(feq3MNKzkCaAKb0e08CiGMI8lKbqLPdOMxgTFcEak0pDav9FP)jdGgvaLOfqLPdO4Ggbwbu5qanMmEXFaQ)a62wW(DChbur5Xp104Y)rmAr5Xp6suDYgXa5QepbLfKSiZTFer3QepbLfudHYXz9A1)L(NmwV5KAJgcLZEOHetDxEYr9FP)jJ1qgsf0EOHetDxEYP)U14)jhhAp0qIPUlxsQEA80AAoNqc3Ih5jhiIC2gJsUr84hnjc56Hm6pRjU6RS9pz4arKZwi8Q4LsdHYz7FYWbIiNTKKIO8qPjrixpKX2)Kz1MnRHiYzRsCD(pdlrlhCWJe57UTPxTzZ6(72tsH2dZhwBeOcYP)U9Iw7H5dRncubxTzZ6JyW8FKq7lEJ(ZAVb1yPJNUFer3I8qIOTf7CshIiNTV4n6pR9guJLoE6(reDlrlN1qe5SvjUo)NHLOLdo4rI8D3MNR4arKZ2guox)zT3G6KO0ThAiXu3IRj8C1MnRv)coY42uKFHmCu)x6FYyrJ2pbpn0pD7Hgsm1T4Achr5XcQXbncSU12R2SzneroBBq5C9N1EdQtIs3s0Ybh8ir(U7mEUAfyVO84NAAC5)igTO84hDjQozJyGCvINGYcsw1Vq5CnHSiZTFer3QepbLfudHYXbIiNTkX15)mSeTG974ocOMcjLeuwIHeGkkp(bqlr1b0KOuauieqpza0itgGAidPcYV3CsTbqLdb0FauvNma9esiGgvafclFcGAIPjdq3b4LcqLPdOXOKBep(bqLdb0(NmaQmDaDNGqkIYdfGsIqUEidGcrKZaAub05DavuESGwa1u4a0itgGMGMNdb0yauJ)NuXaO5)mauz6aALyYXHaAub0dZhwBeOcsgGAkCaAKb0eeqBKfeq9geqnfeVbqlijC6YroGI8qIOTf7KbOEdcODeIiNb0smPWoG6pGgoGgvaDEhqjATMchGgzanbnphcOPi)czauz6aQ5Lr7NGhGc9thqv)x6FYaOrfqjAbuz6akoOrGvavoeqHWYNaOBtgG(hGgzanbnphcO8fKACanliGkthq3P)S8Pqav1b0OcOeTwW(DChbur5Xp104Y)rmAr5Xp6suDYgXa5(jLeuwqYIm3(reD7Nusqzb1qOCCwVw9FP)jJ1BoP2OHq5ShAiXu3LNCu)x6FYynKHubThAiXu3LNCoHeU128KderoBJrj3iE8JT)jdhiIC2cHxfVuAiuoB)tMvB2SgIiNTg)pPIrN)ZWs0YP)UTsm54q7H5dRncubxTzZAiIC2A8)KkgD(pdlrlhiIC22GY56pR9guNeLULOD1MnRHiYzRX)tQy05)mSeTCwdrKZwuvI2kQleJCwI2nBGiYzlQkrBf11ViNLODfN0pIbZ)rcTV4n6pR9guJLoE6(reDlYdjI2wSVAZM1hXG5)iH2x8g9N1EdQXshpD)iIUf5HerBl25KoeroBFXB0Fw7nOglD809Ji6wI2vB2Sw9l4iJBNGuJRZcYr9FP)jJv9ZYNc1EdQRTXfE1EOHetDlUMSAZM1QFbhzCBkYVqgoQ)l9pzSOr7NGNg6NU9qdjM6wCnHJO8yb14Ggbw3A7vRa7fLh)utJl)hXOfLh)Olr1jBedK7NusqzbjR6xOCUMqwK52pIOB)KscklOgcLJderoBn(FsfJo)NHLOfSFhbutzgqtqaTrwqaDNNCLCcGwqs40LJCaf5HerBl2buz6akKuKrHaQKZXeo5aQububqDPGJdOjiGwtcx1aOX4pGA8)Kkgan)NbGM0GdUGhG6niGwixjNaOqe5mGgvavCa9pafclFcGUnGwrfyVO84NAAC5)igTO84hDjQozJyGClKRKtEYIm31RpIbZ)rcTfYvYjvDUGOhdjnPsy0wrlYdjI2wSVIZAxk44wiPiJc1soht4KBXrGkyFfN1qe5STqUsoPQZfe9yiPjvcJ2kAjAxXzneroBlKRKtQ6CbrpgsAsLWOTI2dnKyQBXD7vRa73ra1uMb0eeqBKfeq35jxjNaOfKeoD5ihqrEir02IDavMoGMXtkaQKZXeo5aQububqDPGJdOjiGwtcx1aOX4pGMXtkaA(pdanPbhCbpa1BqaTqUsobqHiYzanQaQ4a6Fakew(eaDBaTIkWEr5Xp104Y)rmAr5Xp6suDYgXa5wixjNOilYCxV(igm)hj0wixjNu15cIEmK0KkHrBfTipKiABX(koRDPGJBZ4jfTKZXeo5wCeOc2xXzneroBlKRKtQ6CbrpgsAsLWOTIwI2vCwdrKZ2c5k5KQoxq0JHKMujmARO9qdjM6wC3E1kW(DeqnLzanbnphcOcGobPgpliGkthqtqaT)J5Xb0ezCa1FavjEckli)FsjbLfKmavMoGMGaAJSGakKuKrH8NXtkaQKZXeo5aQlfCCStgGUZ1GdUGhGQ(z5tHaQQdOrfqjAb0eeqRjHRAa0y8hqLCoMWjhqZ)zaO(dOkP6aA4KbOn4HaQX)tQya08FgwWEr5Xp104Y)rmAr5Xp6suDYgXa5(QFw(uizrMBfDpgsvBTjYUo)Nw9ZYNc5SETlfCClKuKrHAjNJjCYT4iqfSVIZ607hr0TkXtqzb1qOCR4So9(reD7Nusqzb1qOCR4Sw9l4iJBNGuJRZcYr9FP)jJv9ZYNc1EdQRTXfE1EOHetDlUMSAfy)ocOMYmGMGMNdbubqNGuJNfeqLPdOjiG2)X84aAImoG6pGQepbLfK)pPKGYcsgGkthqtqaTrwqafskYOq(Z4jfavY5ycNCa1Lcoo2jdq35AWbxWdqv)S8Pqav1b0OcOeTaAccO1KWvnaAm(dOsoht4KdO5)mau)buLuDanCYa0g8qavjE(pdan)NHfSxuE8tnnU8FeJwuE8JUevNSrmqUk1plFkKSiZTIUhdPQT2ezxN)tR(z5tHCwV2LcoUnJNu0soht4KBXrGkyFfN1P3pIOBvINGYcQHq5wXzD69Ji62pPKGYcQHq5wXzT6xWrg3obPgxNfKJ6)s)tgR6NLpfQ9guxBJl8Q9qdjM6wCnz1kWEr5Xp104YVskfTO84hDjQozJyGCncpijE8dyVO84NAAC5)igTO84hDjQozJyGCHq5a7b7fLh)uTqOCCHq505)milYCthIiNTqOC68FgwIwWEr5XpvlekxAC5VbLZ1Fw7nOojkDYImxxk442guox)zT3G6KO0T4iqfSZzTlfCClKuKrHAjNJjCYT4iqfSVIJ6xWrg3UGJ3q(b2lkp(PAHq5sJl)NSGZtu15dNDa5G9IYJFQwiuU04YV6NLpfQ9guxBJl8kzrMB69Ji6wL4jOSGAiuooP3pIOB)KscklOgcLdSxuE8t1cHYLgx(HWRIxknekhzrM7AiIC2EYcoprvNpC2bKBjA3SjD1VGJmUDbhVH8BfyVO84NQfcLlnU8hJsUr84hYIm31qe5S9KfCEIQoF4Sdi3s0Uzt6QFbhzC7coEd53kWEr5XpvlekxAC5hcVkEPIHezrM7AiIC2cHxfVuAiuolr7Mnqe5SngLCJ4XpAseY1dz0FwtC1xzjAxb2lkp(PAHq5sJl)sxA9yb11e5milYCxNE)DR0LwpwqDnrodDxmesO1dvQyiXjDr5XpwPlTESG6AICg6UyiKqBm6Cji14CwNE)DR0LwpwqDnrodDdkfRhQuXqAZM(7wPlTESG6AICg6guk2dnKyQ7AUvB20F3kDP1JfuxtKZq3fdHeARUOsTL540F3kDP1JfuxtKZq3fdHeAp0qIPULP50F3kDP1JfuxtKZq3fdHeA9qLkgsRa7fLh)uTqOCPXLFV5KAJgcLJmxosORJm3dZhwBeOcUzt)DR3CsTrdHYzRUOsTL52SzD)DR3CsTrdHYzRUOsTfpY5igm)hj0wiYzjMmrf7A0a6efArEir02I9vB2ikpwqnoOrG1D5YJG9IYJFQwiuU04YVX)tooKSiZD9AiIC2sskIYdLMeHC9qglr7koIYJfuJdAeyDRTxTzZ61qe5SLKueLhknjc56HmwI2vCsV)U14)jhhA9qLkgsCeLhlOgh0iW6UMWXLJe6wpmqT)6EG7AY2Ra7fLh)uTqOCPXLFJ)NCCizrM76(7wJ)NCCO9qdjM6wCnhN1qe5SLKueLhknjc56HmwI2vCeLhlOgh0iW6UMMJlhj0TEyGA)19a31KTxb2lkp(PAHq5sJl)gYqQGKfzUNqcTDmhQW31eEYPIUhdPQ1qgsfuB8hc2lkp(PAHq5sJl)g)p54qYIm31hMpS2iqfKJO8yb14Ggbw3ABoUCKq36HbQ9x3dCxt2E1MnRtV)U14)jhhA9qLkgsCeLhlOgh0iW6UMWXLJe6wpmqT)6EG7AY2Ra7fLh)uTqOCPXL)CbRnQtYozrMB9jkqX0TTevNOGA8iA94hlocub7CwVw9FP)jJ1BoP2OHq5ShAiXu3LNCu)x6FYynKHubThAiXu3LNR4SU)U14)jhhAp0qIPUlxZTIZAiIC2gJsUr84hnjc56Hm6pRjU6RS9pz4arKZwi8Q4LsdHYz7FYWbIiNTKKIO8qPjrixpKX2)Kz1QnBQprbkMUD5lIhfux)YcoUfhbQGDYIXX7iADDyyG9qCKRjKfJJ3r06AsLhskCnHSyC8oIwxhzU1NOaft3U8fXJcQRFzbhNZA1)L(NmwV5KAJgcLZEOHetDxEYr9FP)jJ1qgsf0EOHetDxEUcSxuE8t1cHYLgx(RjrlswK5crKZ2yuYnIh)OjrixpKr)znXvFLT)jdhiIC2cHxfVuAiuoB)tgoIYJfuJdAeyDxU8iyVO84NQfcLlnU8BiefYImxiIC2gJsUr84hlrlhr5XcQXbncSU12B2arKZwi8Q4LsdHYzjA5ikpwqnoOrG1T2gSxuE8t1cHYLgx(neIczrM7AiIC2wLfHeQvVbK4Y42QlQu7Y1KvCwdrKZw)FVrltxRksILODfhiIC2gJsUr84hlrlhr5XcQXbncSYDBWEr5XpvlekxAC53qgsfKSiZfIiNTXOKBep(Xs0YruESGACqJaRBX1CG9IYJFQwiuU04YVHquilYCxVEneroB9)9gTmDTQij2QlQu7YD7vB2SgIiNT()EJwMUwvKelrlhiIC26)7nAz6AvrsShAiXu3YeRPxTzZAiIC2wLfHeQvVbK4Y42QlQu7Y1CRwXruESGACqJaRBzUvG9IYJFQwiuU04YV3CsTrdHYrwK5kkpwqnoOrG1DnbSxuE8t1cHYLgx(nKHubjlYCxV(es4w7mEUIJO8yb14Ggbw3YCR2Sz96tiHBzQn9koIYJfuJdAeyDlZXXLcoUT(ef9N1EdQZ)Hv3IJavW(kWEr5XpvlekxAC5VLOSGxSdqYuKRkO2LJe6vUMqwK52F36nNuB0qOC2QlQu7UnyVO84NQfcLlnU87nNuB0qOCG9IYJFQwiuU04YVHquilYCfLhlOgh0iW6wMdSxuE8t1cHYLgx(RjrlQHq5a7fLh)uTqOCPXL)4(jtCKfzUNqcTDmhQW3Ih5jhiIC2g3pzIZEOHetDlEAnnypyVO84NQ1i8GK4XpCJ7NmXrwK5gJ6nIHKUlgcjuB66UX9tM40DXqiHAV5WAZx6CGiYzBC)Kjo7Hgsm1TmNPyJuDeSxuE8t1AeEqs84N04Y)HdMifYImxxMuXqItdkfVX2Q8T4bMgSxuE8t1AeEqs84N04YF(WzheyxFijCWt84hYImxxMuXqItdkfVX2Q8T4bMgSxuE8t1AeEqs84N04YpA0(j4PH(PtwK5Uo9(reDRs8euwqnekhN07hr0TFsjbLfudHYTAZgr5XcQXbncSUl3Tb7fLh)uTgHhKep(jnU8djxQAQyilYCDzsfdjonOu8gBRY3YuzAoXOEJyiP7IHqc1MUUlpTMyk2GsXBSgI5d2lkp(PAncpijE8tAC5VsClXIu0Xu9yuELSiZfIiNTvIBjwKIoMQhJYR2(NmCGiYzlKCPQPIX2)KHtdkfVX2Q8T4b8KtmQ3igs6UyiKqTPR7Yt72M2uSbLI3yneZhShSxuE8t1Q(V0)KPYT994hWEr5XpvR6)s)tMAAC5hQ8FxNjoYb7fLh)uTQ)l9pzQPXLFi8Q4LkgsG9IYJFQw1)L(Nm104YVCkzqT)3HJd2lkp(PAv)x6FYutJl)LGuJx17WeDsg44G9IYJFQw1)L(Nm104YFooeQ8FhSxuE8t1Q(V0)KPMgx(LrHv)KIwjLcyVO84NQv9FP)jtnnU8dDr1lXqsNjoYImxiIC2cHYPZ)zyjAb7fLh)uTQ)l9pzQPXL)yuYnIh)qwK5UU)U14)jhhA9qLkgsB2ikpwqnoOrG1DnzfN(7wV5KAJgcLZ6HkvmKa7fLh)uTQ)l9pzQPXLFi8Q4LcSxuE8t1Q(V0)KPMgx(jQOoC0GmmNrLRhXa5QixvE)(juAOIuDWEr5XpvR6)s)tMAAC5NOI6WrJkypyVO84NQvjEckli327tkG9IYJFQwL4jOSGPXLFL468FgKfzUPdrKZwL468FgwIwWEr5XpvRs8euwW04Y)jPqYImxiIC22EFsXs0c2lkp(PAvINGYcMgx(Bq5C9N1EdQtIsNSiZ1LcoUTbLZ1Fw7nOojkDlocub7CshIiNTnOCU(ZAVb1jrPBjAb7fLh)uTkXtqzbtJl)Or7NGNg6NozrMB)iIUvjEcklOgcLdSxuE8t1QepbLfmnU8FskKSiZT)U9KuO9W8H1gbQGCuVb0RB)y86w8iyVO84NQvjEcklyAC5)IwYIm3(72lAThMpS2iqfKJ6nGED7hJx3Llpc2lkp(PAvINGYcMgx(v)S8PqT3G6ABCHxjlYC7hr0TkXtqzb1qOCG9IYJFQwL4jOSGPXL)mEVkEIQgkCKmdX814GhjY5AczrMR6nGED7hJx3Llpc2lkp(PAvINGYcMgx(LU06XcQRjYzqwK5Uo9(7wPlTESG6AICg6UyiKqRhQuXqIt6IYJFSsxA9yb11e5m0DXqiH2y05sqQX5So9(7wPlTESG6AICg6gukwpuPIH0Mn93TsxA9yb11e5m0nOuShAiXu31CR2SP)Uv6sRhlOUMiNHUlgcj0wDrLAlZXP)Uv6sRhlOUMiNHUlgcj0EOHetDltZP)Uv6sRhlOUMiNHUlgcj06HkvmKwb2lkp(PAvINGYcMgx(ZfS2Ooj7KfzU1NOaft32suDIcQXJO1JFS4iqfSZbh8ir(wMZ0B2uFIcumD7YxepkOU(LfCClocub7KfJJ3r066WWa7H4ixtilghVJO11KkpKu4AczX44DeTUoYCRprbkMUD5lIhfux)YcoohCWJe5Bzotd2lkp(PAvINGYcMgx(Rnh2jlYCvVb0RB)y8QvrCho(wMgShSxuE8t1Qu)S8PqUkX15)ma7fLh)uTk1plFkmnU83GY56pR9guNeLozrMRlfCCBdkNR)S2BqDsu6wCeOc25KoeroBBq5C9N1EdQtIs3s0c2lkp(PAvQFw(uyAC5x9ZYNc1EdQRTXfELSiZT(efOy62CCvxx9lsHwCeOc25arKZ2CCvxx9lsHwIwWEr5XpvRs9ZYNctJl)QFw(uO2BqDTnUWRKfzUUuWXTnOCU(ZAVb1jrPBXrGkyNderoBBq5C9N1EdQtIs3s0c2lkp(PAvQFw(uyAC5x9ZYNc1EdQRTXfELSiZ1LcoUTbLZ1Fw7nOojkDlocub7Cu)x6FYyBq5C9N1EdQtIs3EOHetDxtmnyVO84NQvP(z5tHPXLF1plFku7nOU2gx4vYIm30DPGJBBq5C9N1EdQtIs3IJavWoypyVO84NQTqUsorXvjUo)NbypyVO84NQTqUso55A8)KkgD(pdWEWEr5Xpv7R(z5tHCn(FsfJo)NbyVO84NQ9v)S8PW04YFdkNR)S2BqDsu6KfzUUuWXTnOCU(ZAVb1jrPBXrGkyNt6qe5STbLZ1Fw7nOojkDlrlyVO84NQ9v)S8PW04YV6NLpfQ9guxBJl8kzrMB9jkqX0T54QUU6xKcT4iqfSZbIiNT54QUU6xKcTeTG9IYJFQ2x9ZYNctJl)vxUCCizrMlQkrBfTYqUEqZ33SbvLOTI26xKtpO57G9IYJFQ2x9ZYNctJl)jN4nKfzUOQeTv0kd56bnFFZguvI2kAleJC6bnFhSxuE8t1(QFw(uyAC5x9ZYNc1EdQRTXfELSiZ1LcoUTbLZ1Fw7nOojkDlocub7CGiYzBdkNR)S2BqDsu6wIwWEr5Xpv7R(z5tHPXLF1plFku7nOU2gx4vYImxxk442guox)zT3G6KO0T4iqfSZr9FP)jJTbLZ1Fw7nOojkD7Hgsm1DnX0G9IYJFQ2x9ZYNctJl)QFw(uO2BqDTnUWRKfzUP7sbh32GY56pR9guNeLUfhbQGDWEWEr5Xpv7Nusqzb5A8)KkgD(pdYIm30HiYzRX)tQy05)mSeTG9IYJFQ2pPKGYcMgx(Bq5C9N1EdQtIsNSiZ1LcoUTbLZ1Fw7nOojkDlocub7CshIiNTnOCU(ZAVb1jrPBjAb7fLh)uTFsjbLfmnU8xD5QehjeSxuE8t1(jLeuwW04YV6NLpfQ9guxBJl8kzrMB9jkqX0T54QUU6xKcT4iqfSd2lkp(PA)KscklyAC5hnA)e80q)0jlYC7hr0TFsjbLfudHYb2lkp(PA)KscklyAC5x6sRhlOUMiNbzrM7607VBLU06XcQRjYzO7IHqcTEOsfdjoPlkp(XkDP1JfuxtKZq3fdHeAJrNlbPgNZ607VBLU06XcQRjYzOBqPy9qLkgsB20F3kDP1JfuxtKZq3GsXEOHetDxZTAZM(7wPlTESG6AICg6UyiKqB1fvQTmhN(7wPlTESG6AICg6UyiKq7Hgsm1TmnN(7wPlTESG6AICg6UyiKqRhQuXqAfyVO84NQ9tkjOSGPXL)kXKJdjtrUQGAxosOx5AczrM7H5dRncubb7fLh)uTFsjbLfmnU8B8)KJdjtrUQGAxosOx5AczrM7H5dRncub3SbIiNTKKIO8qPjrixpKXs0c2lkp(PA)KscklyAC5V6YLJdjlYCv)coY42ji146SGCqvjAROvgY1dA(oyVO84NQ9tkjOSGPXL)Kt8gYIm30v)coY42ji146SGCqvjAROvgY1dA(oyVO84NQ9tkjOSGPXLF1plFku7nOU2gx4vYIm31qe5SfvLOTI6cXiNLODZgiIC2IQs0wrD9lYzjAxb2lkp(PA)KscklyAC5V6YLJdjlYCxJQs0wrBm6cXi3MnOQeTv0w)IC6bnFF1MnRrvjAROngDHyKJderoBRUCvIJeQrJ2pbpdCCDHyKZs0UcSxuE8t1(jLeuwW04YFYjEdZzoJb]] )


end