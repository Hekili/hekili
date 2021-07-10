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

    spec:RegisterPack( "Guardian", 20210710, [[dCucVbqikQEKiv1MqfFIIKAukPoLsXQePk8krkZsPQBPKKyxK6xueddvrhdvLLPK4zIuzAOk4AuKABOkKVrrsgNssQZPKuSoLKKmpLkUhQ0(uQ0bvssQfsr5HkjvMOssPCrrQI(OssjNKIeTseLzQKuv3ujPuTtuv9tufkpfutfvPVQKuL9IYFP0Gr6WelgKhtYKLQldTzr9zez0sXPfwnQcvVwKmBjUnf2TIFRQHlLoofjSCvEUKMovxhHTReFxeJxjjopIQ1lsvA(kL2pWm(y8YG7IJm(xHNRWhpnv8XtnF8Wk8XdRWGDYBrgCROsjKqg8igidE1IqUEiddUviV8sNXldU(eNczWnU3wxvzIjKcVHasREdtQHbrr84h1jz3KAyOmHbdref3uomigCxCKX)k8Cf(4PPIpEQ5JhwHpEGbleEZFmy4Wy1XGBIEhhgedUJvfdE1IqUEidGUA7iIoGmYikKdO8XZ9a6k8CfEcidq2QRrgsyDvfGSvfa1uoQ)A)tCeqxDIBYQ9)NuXaOTx8x4bwb01rgqRO7XqcqJkGQAqvkSVrdiBvbqnLJ6V2)ehb0V1JFau)b0AtKDaD9Fa68(gafcZ)Ha6Q7NLpfQzWLO6vgVm4c5k5KNXlJF(y8YGfLh)WGn(FsfJn)NbdghbQGDMzmN5myiuogVm(5JXldghbQGDMzmy1foEHWGnhqHiYznekNn)NHMOLblkp(HbdHYzZ)zWCg)RW4LbJJavWoZmgS6chVqyWUuWX1nOCU9ZwVbTjrPRXrGkyhq5aORbuxk44AiPiJcTsoht4KRXrGkyhq3aOCau1VGJmUEbhVH8Jblkp(Hb3GY52pB9g0MeLoZz8NogVmyCeOc2zMXGvx44fcdEnGUgqHiYznjPikpuwseY1dz0eTa6gaLdGkkpwqloOrGvaDhaDfaDdGUDlGUgqxdOqe5SMKueLhkljc56HmAIwaDdGYbqnhq7VRn(FYXHApuPIHeGYbqfLhlOfh0iWkGUlGYhGYbqD5iHU2dd06VThiGUlGY3ka6ggSO84hgSX)tooK5m(5bgVmyCeOc2zMXGvx44fcdEnG2FxB8)KJd1hAiXub0D4cOPdq5aORbuiICwtskIYdLLeHC9qgnrlGUbq5aOIYJf0IdAeyfq3fqnnGYbqD5iHU2dd06VThiGUlGY3ka6ggSO84hgSX)tooK5m(nnJxgmocub7mZyWQlC8cHbVgqpmFyTrGkiGYbqfLhlOfh0iWkGUdGUcGYbqD5iHU2dd06VThiGUlGY3ka6gaD7waDnGAoG2FxB8)KJd1EOsfdjaLdGkkpwqloOrGvaDxaLpaLdG6YrcDThgO1FBpqaDxaLVva0nmyr5XpmyJ)NCCiZz8ZJy8YGfLh)WGpzbNNOAZhoPxYzW4iqfSZmJ5m(nvmEzW4iqfSZmJblkp(HbZJ)oXqcJ7SDS6XqE1QKsHbRUWXlegS6xWrgxVGJ3q(XGhXazW84VtmKW4oBhREmKxTkPuyoJ)vnJxgmocub7mZyWIYJFyWev0goAWGvx44fcd2CafIiN1T3Nu0eTakhav9l4iJRxWXBi)yW1Y7my)Ijf68XCg)RggVmyCeOc2zMXGfLh)WGjQOnC0GbRUWXlegS5akeroRBVpPOjAbuoaQ6xWrgxVGJ3q(XGRL3zW(ftk0xH5m(5JNmEzW4iqfSZmJbRUWXlegS6xWrgxVGJ3q(bOCauiICwhJsUr84h9HgsmvaDxUa6k8aGYbqHiYzDmk5gXJF0hAiXub0D4cORyAgSO84hgC77XpmNXpF8X4LbJJavWoZmgS6chVqyWMdO9Ji6AL4jOSGwiuoaLdGAoG2pIOR)KscklOfcLJblkp(HbR(z5tHwVbT124cVYCg)8TcJxgmocub7mZyWQlC8cHbVgqHiYz9jl48evB(Wj9sUMOfq3Ufqnhqv)coY46fC8gYpaDddwuE8ddgcVkEPyoJF(shJxgmocub7mZyWQlC8cHbVgqHiYz9jl48evB(Wj9sUMOfq3Ufqnhqv)coY46fC8gYpaDddwuE8ddogLCJ4XpmNXpF8aJxgmocub7mZyWQlC8cHbVgqHiYzneEv8szHq50eTa62TakeroRJrj3iE8JLeHC9qg7NTex9vAIwaDddwuE8ddgcVkEPIHeZz8ZNPz8YGXrGkyNzgdwDHJxim41aQ5aA)DT0LwpwqBnrodBxmesO2dvQyibOCauZbur5XpAPlTESG2AICg2UyiKqDm2Cji14akhaDnGAoG2FxlDP1Jf0wtKZW2Gsr7HkvmKa0TBb0(7APlTESG2AICg2guk6dnKyQa6UaA6a0na62TaA)DT0LwpwqBnrodBxmesOU6IkfGUdGMoaLdG2FxlDP1Jf0wtKZW2fdHeQp0qIPcO7aOMgq5aO931sxA9ybT1e5mSDXqiHApuPIHeGUHblkp(HblDP1Jf0wtKZG5m(5JhX4LbJJavWoZmgS6chVqyWhMpS2iqfeq3Ufq7VR9MtQnwiuoD1fvkaDhanDa62Ta6AaT)U2BoP2yHq50vxuPa0DauEaq5aOhXG5)iH6crolXKjQy3IgqNOqnAkiI2wSdOBa0TBbur5XcAXbncScO7Yfq5bgSO84hgS3CsTXcHYXCg)8zQy8YGXrGkyNzgdwDHJxim4tiH6oMdv4a6UakF8eq5aOv09yiv1gYqQGwJ)qgSO84hgSHmKkiZz8Z3QMXldghbQGDMzmy1foEHWGRprbkMUULO6ef0IhrRh)OXrGkyhq5aORb01aQ6)s)tgT3CsTXcHYPp0qIPcO7cO8eq5aOQ)l9pz0gYqQG6dnKyQa6Uakpb0nakhaDnG2FxB8)KJd1hAiXub0D5cOPdq3aOCa01akeroRJrj3iE8JLeHC9qg7NTex9v6(NmakhafIiN1q4vXlLfcLt3)Kbq5aOqe5SMKueLhkljc56Hm6(Nma6gaDdGUDlGwFIcumD9YxepkOT(LfCCnocub7m4yC8oIw3gzgC9jkqX01lFr8OG26xwWX5Sw9FP)jJ2BoP2yHq50hAiXu3LNCu)x6FYOnKHub1hAiXu3LNByWX44DeTUnmmWEioYG5Jblkp(HbNlyTrDs2zWX44DeTULu5HKcdMpMZ4NVvdJxgmocub7mZyWQlC8cHbdrKZ6yuYnIh)yjrixpKX(zlXvFLU)jdGYbqHiYzneEv8szHq509pzauoaQO8ybT4Ggbwb0D5cO8adwuE8ddUMeTOfcLJ5m(xHNmEzW4iqfSZmJbRUWXlegmeroRJrj3iE8JMOfq5aOIYJf0IdAeyfq3bqxbq3UfqHiYzneEv8szHq50eTakhavuESGwCqJaRa6oa6kmyr5XpmydHOWCg)RWhJxgmocub7mZyWQlC8cHbVgqHiYzDvwesOv9gqIlJRRUOsbO7Yfq5dq3aOCa01akeroR9)9gRmDRQijAIwaDdGYbqHiYzDmk5gXJF0eTakhavuESGwCqJaRakxaDfgSO84hgSHquyoJ)vwHXldghbQGDMzmy1foEHWGHiYzDmk5gXJF0eTakhavuESGwCqJaRa6oCb00XGfLh)WGnKHubzoJ)vshJxgmocub7mZyWQlC8cHbVgqxdORbuiICw7)7nwz6wvrs0vxuPa0D5cORaOBa0TBb01akeroR9)9gRmDRQijAIwaLdGcrKZA)FVXkt3QksI(qdjMkGUdGYN20a6gaD7waDnGcrKZ6QSiKqR6nGexgxxDrLcq3LlGMoaDdGUbq5aOIYJf0IdAeyfq3bqthGUHblkp(HbBiefMZ4FfEGXldghbQGDMzmy1foEHWGfLhlOfh0iWkGUlGYhdwuE8dd2BoP2yHq5yoJ)vmnJxgmocub7mZyWQlC8cHbVgqxdONqcb0Da0vdpb0nakhavuESGwCqJaRa6oaA6a0na62Ta6AaDnGEcjeq3bqx1Mgq3aOCaur5XcAXbncScO7aOPdq5aOUuWX11NOy)S1BqB(pS6ACeOc2b0nmyr5XpmydzivqMZ4FfEeJxgmocub7mZyWIYJFyWTeLf8I0lYGvx44fcdU)U2BoP2yHq50vxuPa0Db0vyWkYvf06Yrc9kJF(yoJ)vmvmEzWIYJFyWEZj1glekhdghbQGDMzmNX)kRAgVmyCeOc2zMXGvx44fcdwuESGwCqJaRa6oaA6yWIYJFyWgcrH5m(xz1W4Lblkp(HbxtIw0cHYXGXrGkyNzgZz8NoEY4LbJJavWoZmgS6chVqyWNqc1DmhQWb0DauEGNakhafIiN1X9tM40hAiXub0DauEQnndwuE8ddoUFYehZzod2i8GK4XpmEz8ZhJxgmocub7mZyWQlC8cHbhJ6nIHKTlgcj0A6kGUlGg3pzIZ2fdHeA9MdRnFPdOCauiICwh3pzItFOHetfq3bqthGMEaOns1rgSO84hgCC)KjoMZ4FfgVmyCeOc2zMXGvx44fcd2LjvmKauoaAdkfVr3QCaDhaLhzAgSO84hg8HdMifMZ4pDmEzW4iqfSZmJbRUWXlegSltQyibOCa0gukEJUv5a6oakpY0myr5Xpm48Ht6nWU9qs4GN4XpmNXppW4LbJJavWoZmgS6chVqyWRbuZb0(reDTs8euwqlekhGYbqnhq7hr01FsjbLf0cHYbOBa0TBbur5XcAXbncScO7YfqxHblkp(HbJgTFcEwOF6mNXVPz8YGXrGkyNzgdwDHJximyxMuXqcq5aOnOu8gDRYb0DautLPbuoaAmQ3igs2UyiKqRPRa6Uakp18bOPhaAdkfVrBiRcdwuE8ddgsUu1uXWCg)8igVmyCeOc2zMXGvx44fcdgIiN1vIBjwKInMQhJYR6(NmakhafIiN1qYLQMkgD)tgaLdG2GsXB0Tkhq3bq5r8eq5aOXOEJyiz7IHqcTMUcO7cO8uVIPb00daTbLI3OnKvHblkp(HbxjULyrk2yQEmkVYCMZGvINGYcY4LXpFmEzWIYJFyWT3NuyW4iqfSZmJ5m(xHXldghbQGDMzmy1foEHWGnhqHiYzTsCB(pdnrldwuE8ddwjUn)NbZz8NogVmyCeOc2zMXGvx44fcdgIiN1T3Nu0eTmyr5Xpm4tsHmNXppW4LbJJavWoZmgS6chVqyWUuWX1nOCU9ZwVbTjrPRXrGkyhq5aOMdOqe5SUbLZTF26nOnjkDnrldwuE8ddUbLZTF26nOnjkDMZ430mEzW4iqfSZmJbRUWXlegC)iIUwjEcklOfcLJblkp(HbJgTFcEwOF6mNXppIXldghbQGDMzmy1foEHWG7VRpjfQpmFyTrGkiGYbqvVb0BB)y8kGUdGYdmyr5Xpm4tsHmNXVPIXldghbQGDMzmy1foEHWG7VRVOvFy(WAJavqaLdGQEdO32(X4vaDxUakpWGfLh)WGVOL5m(x1mEzW4iqfSZmJbRUWXlegC)iIUwjEcklOfcLJblkp(HbR(z5tHwVbT124cVYCg)RggVmyCeOc2zMXGvx44fcdw9gqVT9JXRa6UCbuEGblkp(HbNX7vXtuTqHJmydzvS4GhjYz8ZhZz8Zhpz8YGXrGkyNzgdwDHJxim41aQ5aA)DT0LwpwqBnrodBxmesO2dvQyibOCauZbur5XpAPlTESG2AICg2UyiKqDm2Cji14akhaDnGAoG2FxlDP1Jf0wtKZW2Gsr7HkvmKa0TBb0(7APlTESG2AICg2guk6dnKyQa6UaA6a0na62TaA)DT0LwpwqBnrodBxmesOU6IkfGUdGMoaLdG2FxlDP1Jf0wtKZW2fdHeQp0qIPcO7aOMgq5aO931sxA9ybT1e5mSDXqiHApuPIHeGUHblkp(HblDP1Jf0wtKZG5m(5JpgVmyCeOc2zMXGvx44fcdU(efOy66wIQtuqlEeTE8JghbQGDaLdGIdEKihq3bqtNPb0TBb06tuGIPRx(I4rbT1VSGJRXrGkyNbhJJ3r062iZGRprbkMUE5lIhf0w)YcoohCWJe57KotZGJXX7iADByyG9qCKbZhdwuE8ddoxWAJ6KSZGJXX7iADlPYdjfgmFmNXpFRW4LbJJavWoZmgS6chVqyWQ3a6TTFmEvRiUdhhq3bqnndwuE8ddU2CyN5mNbxixjNOy8Y4NpgVmyr5XpmyL428FgmyCeOc2zMXCMZG7ywikoJxg)8X4LbJJavWoZmgChRQlA94hgC65QGkch7akUGh5aQhgiG6niGkk)panQaQSirrGkOMblkp(HbxtrukwiP2WCg)RW4LbJJavWoZmgSO84hgmp(7edjmUZ2XQhd5vRskfgS6chVqyWMdOqe5SU9(KIMOfq5aOMdOQFbhzC9coEd5hdEedKbZJ)oXqcJ7SDS6XqE1QKsH5m(thJxgmocub7mZyWIYJFyWev0goAWGvx44fcd2CafIiN1T3Nu0eTakha1Cav9l4iJRxWXBi)yW1Y7my)Ijf68XCg)8aJxgmocub7mZyWIYJFyWev0goAWGvx44fcd2CafIiN1T3Nu0eTakha1Cav9l4iJRxWXBi)yW1Y7my)Ijf6RWCg)MMXldghbQGDMzmy1foEHWGnhqv)coY46fC8gYpaLdGUgqxdORbuxk446guo3(zR3G2KO014iqfSdOCauiICw3GY52pB9g0MeLUMOfq3aOCa01aA)iIUwjEcklOfcLdq3Ufq7hr01FsjbLf0cHYbOBauoaQ5akeroRBVpPOjAb0na62Ta6AaDnGcrKZAi8Q4LYcHYPjAb0TBbuiICwhJsUr84hljc56Hm2pBjU6R0eTa6gaLdGUgqnhq7hr01kXtqzbTqOCakha1CaTFerx)jLeuwqlekhGUbq3aOByWIYJFyWTVh)WCg)8igVmyCeOc2zMXGvx44fcdUFerxRepbLf0cHYbOCauiICwRe3M)Zqt0YGR(fkNXpFmyr5Xpm4JySIYJFSLO6m4suD7igidwjEckliZz8BQy8YGXrGkyNzgdwDHJxim4(reD9NusqzbTqOCakhafIiN1g)pPIXM)Zqt0YGR(fkNXpFmyr5Xpm4JySIYJFSLO6m4suD7igid(tkjOSGmNX)QMXldghbQGDMzm4owvx06XpmytzgqtqaTrwqaD1NCLCcGwqs40LJCafnferBl2buz6akKuKrHaQKZXeo5aQububqDPGJdOjiGwtcx1aOX4pGA8)Kkgan)NbGM0GdUGhG6niGwixjNaOqe5mGgvavCa9pafclFcGUcGwrfdwuE8dd(igRO84hBjQodwDHJxim41a6Aa9igm)hjuxixjNuT5cIEmKSKkHrBf1OPGiABXoGUbq5aORbuxk44AiPiJcTsoht4KRXrGkyhq3aOCa01akeroRlKRKtQ2CbrpgswsLWOTIAIwaDdGYbqxdOqe5SUqUsoPAZfe9yizjvcJ2kQp0qIPcO7Wfqxbq3aOByWLO62rmqgCHCLCYZCg)RggVmyCeOc2zMXG7yvDrRh)WGnLzanbb0gzbb0vFYvYjaAbjHtxoYbu0uqeTTyhqLPdOz8KcGk5CmHtoGkvavauxk44aAccO1KWvnaAm(dOz8KcGM)ZaqtAWbxWdq9geqlKRKtauiICgqJkGkoG(hGcHLpbqxbqROIblkp(HbFeJvuE8JTevNbRUWXleg8AaDnGEedM)JeQlKRKtQ2CbrpgswsLWOTIA0uqeTTyhq3aOCa01aQlfCCDgpPyLCoMWjxJJavWoGUbq5aORbuiICwxixjNuT5cIEmKSKkHrBf1eTa6gaLdGUgqHiYzDHCLCs1Mli6XqYsQegTvuFOHetfq3HlGUcGUbq3WGlr1TJyGm4c5k5efZz8Zhpz8YGXrGkyNzgdUJv1fTE8dd2uMb0e0uFiGka6eKA8SGaQmDanbb0(pMAhqtKXbu)buL4jOSGM8jLeuwW9aQmDanbb0gzbbuiPiJcnjJNuaujNJjCYbuxk44yFpGU61GdUGhGQ(z5tHaQQdOrfqjAb0eeqRjHRAa0y8hqLCoMWjhqZ)zaO(dOkP6aA47b0g8qa14)jvmaA(pdndwuE8dd(igRO84hBjQodwDHJxim4k6EmKQ6AtKDB(pR6NLpfcOCa01a6Aa1LcoUgskYOqRKZXeo5ACeOc2b0nakhaDnGAoG2pIORvINGYcAHq5a0nakhaDnGAoG2pIOR)KscklOfcLdq3aOCa01aQ6xWrgxpbPg3Mfeq5aOQ)l9pz0QFw(uO1BqBTnUWR6dnKyQa6oCbu(a0na6ggCjQUDedKb)QFw(uiZz8ZhFmEzW4iqfSZmJb3XQ6Iwp(HbBkZaAcAQpeqfaDcsnEwqavMoGMGaA)htTdOjY4aQ)aQs8euwqt(Ksckl4EavMoGMGaAJSGakKuKrHMKXtkaQKZXeo5aQlfCCSVhqx9AWbxWdqv)S8Pqav1b0OcOeTaAccO1KWvnaAm(dOsoht4KdO5)mau)buLuDan89aAdEiGQep)NbGM)ZqZGfLh)WGpIXkkp(XwIQZGvx44fcdUIUhdPQU2ez3M)ZQ(z5tHakhaDnGUgqDPGJRZ4jfRKZXeo5ACeOc2b0nakhaDnGAoG2pIORvINGYcAHq5a0nakhaDnGAoG2pIOR)KscklOfcLdq3aOCa01aQ6xWrgxpbPg3Mfeq5aOQ)l9pz0QFw(uO1BqBTnUWR6dnKyQa6oCbu(a0na6ggCjQUDedKbRu)S8PqMZ4NVvy8YGXrGkyNzgdwuE8ddwjLIvuE8JTevNbxIQBhXazWgHhKep(H5m(5lDmEzW4iqfSZmJblkp(HbFeJvuE8JTevNbxIQBhXazWqOCmN5m42dvVbK4mEz8ZhJxgmocub7mZyWDSQUO1JFyWPNRcQiCSdOqy(peqvVbK4akeskMQgqxvRuyRxb05NvLg5mYefavuE8tfq)PqUMblkp(HbNkM(HDBTnUWRmNX)kmEzW4iqfSZmJbRUWXlegmeroRvIBZ)zOjAbuoaA)iIUwjEcklOfcLJblkp(Hb3EFsH5m(thJxgmocub7mZyWQlC8cHb7sbhx3GY52pB9g0MeLUghbQGDaLdGUgq7hr01kXtqzbTqOCakhafIiN1kXT5)m0eTa62TaA)iIU(tkjOSGwiuoaLdGcrKZAJ)NuXyZ)zOjAb0TBbuiICwB8)KkgB(pdnrlGYbqDPGJRHKImk0k5CmHtUghbQGDaDddwuE8ddUbLZTF26nOnjkDMZ4Nhy8YGXrGkyNzgdwDHJximyZbuiICwld528FgAIwaLdGUgqxdOMdO9Ji66pPKGYcAHq5auoaQ5aA)iIUwjEcklOfcLdq3aOCa01aQ5aQ6xWrgxpbPg3Mfeq3aOBa0TBb01a6Aa1CaTFerx)jLeuwqlekhGYbqnhq7hr01kXtqzbTqOCa6gaLdGUgqv)coY46ji142SGakha1LcoU(WQ)N4XpwjNJjCY14iqfSdOBa0TBbu1VGJmUEbhVH8dq3WGfLh)WGHq5S5)myoJFtZ4LbJJavWoZmgS6chVqyWqe5S24)jvm28FgAIwaLdG2pIOR)KscklOfcLdq5aOMdOQFbhzC9eKACBwqgSO84hgCYjEdZz8ZJy8YGXrGkyNzgdwDHJximyiICwB8)KkgB(pdnrlGYbq7hr01FsjbLf0cHYbOCau1VGJmUEcsnUnlidwuE8ddU6YLJdzoJFtfJxgmocub7mZyWQlC8cHbxFIcumDDlr1jkOfpIwp(rJJavWoGUDlGwFIcumD9YxepkOT(LfCCnocub7m4yC8oIw3gzgC9jkqX01lFr8OG26xwWXzWX44DeTUnmmWEioYG5Jblkp(HbNlyTrDs2zWX44DeTULu5HKcdMpMZCgS6)s)tMkJxg)8X4Lblkp(Hb3(E8ddghbQGDMzmNX)kmEzWIYJFyWqL)72mXrodghbQGDMzmNXF6y8YGfLh)WGHWRIxQyiXGXrGkyNzgZz8ZdmEzWIYJFyWYPKbT(FhoodghbQGDMzmNXVPz8YGfLh)WGlbPgVA5Xj6KmWXzW4iqfSZmJ5m(5rmEzWIYJFyW54qOY)Dgmocub7mZyoJFtfJxgSO84hgSmkS6NuSkPuyW4iqfSZmJ5m(x1mEzW4iqfSZmJbRUWXlegmeroRHq5S5)m0eTmyr5XpmyOlQEjgs2mXXCg)RggVmyCeOc2zMXGvx44fcdEnG2FxB8)KJd1EOsfdjaD7wavuESGwCqJaRa6UakFa6gaLdG2Fx7nNuBSqOCApuPIHedwuE8ddogLCJ4XpmNXpF8KXldwuE8ddgcVkEPyW4iqfSZmJ5m(5JpgVmyCeOc2zMXGfLh)WGvKRkVF)eklurQodgZzu52rmqgSICv597NqzHks1zoJF(wHXldwuE8ddMOI2WrJkdghbQGDMzmN5m4x9ZYNcz8Y4NpgVmyr5XpmyJ)NuXyZ)zWGXrGkyNzgZz8VcJxgmocub7mZyWQlC8cHb7sbhx3GY52pB9g0MeLUghbQGDaLdGAoGcrKZ6guo3(zR3G2KO01eTmyr5Xpm4guo3(zR3G2KO0zoJ)0X4LbJJavWoZmgS6chVqyW1NOaftxNJR62QFrkuJJavWoGYbqHiYzDoUQBR(fPqnrldwuE8ddw9ZYNcTEdARTXfEL5m(5bgVmyCeOc2zMXGvx44fcdgvLOTIAzi3o4Q4a62TakQkrBf11ViNDWvXzWIYJFyWvxUCCiZz8BAgVmyCeOc2zMXGvx44fcdgvLOTIAzi3o4Q4a62TakQkrBf1fIro7GRIZGfLh)WGtoXByoJFEeJxgmocub7mZyWQlC8cHb7sbhx3GY52pB9g0MeLUghbQGDaLdGcrKZ6guo3(zR3G2KO01eTmyr5Xpmy1plFk06nOT2gx4vMZ43uX4LbJJavWoZmgS6chVqyWUuWX1nOCU9ZwVbTjrPRXrGkyhq5aOQ)l9pz0nOCU9ZwVbTjrPRp0qIPcO7cO8zAgSO84hgS6NLpfA9g0wBJl8kZz8VQz8YGXrGkyNzgdwDHJximyZbuxk446guo3(zR3G2KO014iqfSZGfLh)WGv)S8PqR3G2ABCHxzoZzWk1plFkKXlJF(y8YGfLh)WGvIBZ)zWGXrGkyNzgZz8VcJxgmocub7mZyWQlC8cHb7sbhx3GY52pB9g0MeLUghbQGDaLdGAoGcrKZ6guo3(zR3G2KO01eTmyr5Xpm4guo3(zR3G2KO0zoJ)0X4LbJJavWoZmgS6chVqyW1NOaftxNJR62QFrkuJJavWoGYbqHiYzDoUQBR(fPqnrldwuE8ddw9ZYNcTEdARTXfEL5m(5bgVmyCeOc2zMXGvx44fcd2LcoUUbLZTF26nOnjkDnocub7akhafIiN1nOCU9ZwVbTjrPRjAzWIYJFyWQFw(uO1BqBTnUWRmNXVPz8YGXrGkyNzgdwDHJximyxk446guo3(zR3G2KO014iqfSdOCau1)L(Nm6guo3(zR3G2KO01hAiXub0Dbu(mndwuE8ddw9ZYNcTEdARTXfEL5m(5rmEzW4iqfSZmJbRUWXlegS5aQlfCCDdkNB)S1BqBsu6ACeOc2zWIYJFyWQFw(uO1BqBTnUWRmN5m4pPKGYcY4LXpFmEzW4iqfSZmJbRUWXlegS5akeroRn(FsfJn)NHMOLblkp(HbB8)KkgB(pdMZ4FfgVmyCeOc2zMXGvx44fcd2LcoUUbLZTF26nOnjkDnocub7akha1CafIiN1nOCU9ZwVbTjrPRjAzWIYJFyWnOCU9ZwVbTjrPZCg)PJXldwuE8ddU6YvjosidghbQGDMzmNXppW4LbJJavWoZmgS6chVqyW1NOaftxNJR62QFrkuJJavWodwuE8ddw9ZYNcTEdARTXfEL5m(nnJxgmocub7mZyWQlC8cHb3pIOR)KscklOfcLJblkp(HbJgTFcEwOF6mNXppIXldghbQGDMzmy1foEHWGxdOMdO931sxA9ybT1e5mSDXqiHApuPIHeGYbqnhqfLh)OLU06XcARjYzy7IHqc1XyZLGuJdOCa01aQ5aA)DT0LwpwqBnrodBdkfThQuXqcq3Ufq7VRLU06XcARjYzyBqPOp0qIPcO7cOPdq3aOB3cO931sxA9ybT1e5mSDXqiH6QlQua6oaA6auoaA)DT0LwpwqBnrodBxmesO(qdjMkGUdGAAaLdG2FxlDP1Jf0wtKZW2fdHeQ9qLkgsa6ggSO84hgS0LwpwqBnrodMZ43uX4LbJJavWoZmgSO84hgCLyYXHmy1foEHWGpmFyTrGkidwrUQGwxosOxz8ZhZz8VQz8YGXrGkyNzgdwuE8dd24)jhhYGvx44fcd(W8H1gbQGa62TakeroRjjfr5HYsIqUEiJMOLbRixvqRlhj0Rm(5J5m(xnmEzW4iqfSZmJbRUWXlegS6xWrgxpbPg3Mfeq5aOOQeTvuld52bxfNblkp(HbxD5YXHmNXpF8KXldghbQGDMzmy1foEHWGnhqv)coY46ji142SGakhafvLOTIAzi3o4Q4myr5Xpm4Kt8gMZ4Np(y8YGXrGkyNzgdwDHJxim41akeroRrvjAROTqmYPjAb0TBbuiICwJQs0wrB9lYPjAb0nmyr5Xpmy1plFk06nOT2gx4vMZ4NVvy8YGXrGkyNzgdwDHJxim41akQkrBf1XyleJCa62TakQkrBf11ViNDWvXb0na62Ta6AafvLOTI6ySfIroaLdGcrKZ6QlxL4iHw0O9tWZah3wig50eTa6ggSO84hgC1LlhhYCg)8LogVmyr5Xpm4Kt8ggmocub7mZyoZzodEbVA8dJ)v45k8Xttfpx1A(yWjYnXqQYGnLgT)5yhq5JpavuE8dGwIQx1aYyWT3NJcYGt)0hqxTiKRhYaOR2oIOdil9tFaLmIc5akF8CpGUcpxHNaYaKL(PpGU6AKHewxvbil9tFaDvbqnLJ6V2)ehb0vN4MSA))jvmaA7f)fEGvaDDKb0k6EmKa0OcOQguLc7B0aYs)0hqxvaut5O(R9pXra9B94ha1FaT2ezhqx)hGoVVbqHW8FiGU6(z5tHAazaYsFan9CvqfHJDafcZ)HaQ6nGehqHqsXu1a6QALcB9kGo)SQ0iNrMOaOIYJFQa6pfY1aYeLh)u1ThQEdiXtJRjPIPFy3wBJl8kGmr5XpvD7HQ3as804As79jL9rMleroRvIBZ)zOjA50pIORvINGYcAHq5aKjkp(PQBpu9gqINgxtAq5C7NTEdAtIsFFK56sbhx3GY52pB9g0MeLUghbQGDoR7hr01kXtqzbTqOCCGiYzTsCB(pdnr72T9Ji66pPKGYcAHq54arKZAJ)NuXyZ)zOjA3UfIiN1g)pPIXM)Zqt0YXLcoUgskYOqRKZXeo5ACeOc23aituE8tv3EO6nGepnUMaHYzZ)zSpYCnhIiN1YqUn)NHMOLZ61M3pIOR)KscklOfcLJJ59Ji6AL4jOSGwiuUnCwBU6xWrgxpbPg3MfCZMTBxV28(reD9NusqzbTqOCCmVFerxRepbLf0cHYTHZA1VGJmUEcsnUnlihxk446dR(FIh)yLCoMWjxJJavW(MTBv)coY46fC8gYVnaYeLh)u1ThQEdiXtJRjjN4n7JmxiICwB8)KkgB(pdnrlN(reD9NusqzbTqOCCmx9l4iJRNGuJBZccituE8tv3EO6nGepnUMuD5YXH7JmxiICwB8)KkgB(pdnrlN(reD9NusqzbTqOCCu)coY46ji142SGaYeLh)u1ThQEdiXtJRj5cwBuNK99rMB9jkqX01TevNOGw8iA94hnocub7B3wFIcumD9YxepkOT(LfCCnocub77JXX7iADByyG9qCKlF7JXX7iADlPYdjfU8TpghVJO1TrMB9jkqX01lFr8OG26xwWXbKbil9b00Zvbveo2buCbpYbupmqa1Bqavu(FaAubuzrIIavqnGmr5XpvU1ueLIfsQnaYeLh)utJRjev0goASFedKlp(7edjmUZ2XQhd5vRskL9rMR5qe5SU9(KIMOLJ5QFbhzC9coEd5hGmr5Xp104AcrfTHJg7RL356xmPqNV9rMR5qe5SU9(KIMOLJ5QFbhzC9coEd5hGmr5Xp104AcrfTHJg7RL356xmPqFL9rMR5qe5SU9(KIMOLJ5QFbhzC9coEd5hGmr5Xp104As77Xp7JmxZv)coY46fC8gYpoRxV2LcoUUbLZTF26nOnjkDnocub7CGiYzDdkNB)S1BqBsu6AI2nCw3pIORvINGYcAHq52UTFerx)jLeuwqlek3goMdrKZ627tkAI2nB3UEneroRHWRIxklekNMOD7wiICwhJsUr84hljc56Hm2pBjU6R0eTB4S28(reDTs8euwqlekhhZ7hr01FsjbLf0cHYTzZgazPF6dORoXtqzjgsaQO84haTevhqtIsbqHqa9KbqJ8Ea1qgsf0eV5KAdGkhcO)aOQ(Ea9esiGgvafclFcGYd8CpGMEXlfGkthqJrj3iE8dGkhcO9pzauz6a6QfHueLhkaLeHC9qgafIiNb0OcOZ7aQO8yb3dO)bOrEpGMGM6db0yauL45)mauz6ako4rICanQaQa9liGUIP3dO8yhGgzanbb0gzbbuVbbuEmXBa0cscNUCKdOOPGiABX(Ea1BqaTJqe5mGwIjf2bu)b0Wb0OcOZ7akrlGkthqXbpsKdOrfqfOFbb0v45EESdqJmGMGM6db0uKFHmaQmDan90O9tWdqH(PdOQ)l9pza0OcOeTaQmDafh0iWkGkhcOXKXl(dq9hqxrdil9tFavuE8tnnUMCeJvuE8JTevF)igixL4jOSG7Jm3(reDTs8euwqlekhN1Rv)x6FYO9MtQnwiuo9Hgsm1D5jh1)L(NmAdzivq9Hgsm1D5jN(7AJ)NCCO(qdjM6UCjP6PXtTP5CcjChEGNCGiYzDmk5gXJFSKiKRhYy)SL4QVs3)KHderoRHWRIxklekNU)jdhiICwtskIYdLLeHC9qgD)tMnB3UgIiN1kXT5)m0eTCWbpsKV7kMEZ2TR7VRpjfQpmFyTrGkiN(76lA1hMpS2iqfCZ2TRpIbZ)rc1V4n2pB9g0ILoE2(reDnAkiI2wSZXCiICw)I3y)S1Bqlw64z7hr01eTCwdrKZAL428FgAIwo4GhjY3DfEUHderoRBq5C7NTEdAtIsxFOHetDhU8XZnB3Uw9l4iJRtr(fYWr9FP)jJgnA)e8Sq)01hAiXu3HlFCeLhlOfh0iW6oRSz721qe5SUbLZTF26nOnjkDnrlhCWJe57UA45MnaYeLh)utJRjhXyfLh)ylr13pIbYvjEckl4(QFHY5Y3(iZTFerxRepbLf0cHYXbIiN1kXT5)m0eTaYs)0hq5XskjOSedjavuE8dGwIQdOjrPaOqiGEYaOrEpGAidPcAI3CsTbqLdb0FauvFpGEcjeqJkGcHLpbq5Z07b00lEPauz6aAmk5gXJFau5qaT)jdGkthqxTiKIO8qbOKiKRhYaOqe5mGgvaDEhqfLhlOgq5XoanY7b0e0uFiGgdGA8)Kkgan)NbGkthqRetooeqJkGEy(WAJavW9akp2bOrgqtqaTrwqa1BqaLht8gaTGKWPlh5akAkiI2wSVhq9geq7ierodOLysHDa1FanCanQa68oGs0Q5XoanYaAcAQpeqtr(fYaOY0b00tJ2pbpaf6NoGQ(V0)KbqJkGs0cOY0buCqJaRaQCiGcHLpbqxzpG(hGgzanbn1hcO8hKACanliGkthqxD)S8Pqav1b0OcOeTAazPF6dOIYJFQPX1KJySIYJFSLO67hXa5(jLeuwW9rMB)iIU(tkjOSGwiuooRxR(V0)Kr7nNuBSqOC6dnKyQ7YtoQ)l9pz0gYqQG6dnKyQ7YtoNqc3zfEYbIiN1XOKBep(r3)KHderoRHWRIxklekNU)jZMTBxdrKZAJ)NuXyZ)zOjA50FxxjMCCO(W8H1gbQGB2UDneroRn(FsfJn)NHMOLderoRBq5C7NTEdAtIsxt0Uz721qe5S24)jvm28FgAIwoRHiYznQkrBfTfIronr72Tqe5SgvLOTI26xKtt0UHJ5hXG5)iH6x8g7NTEdAXshpB)iIUgnferBl23SD76JyW8FKq9lEJ9ZwVbTyPJNTFerxJMcIOTf7CmhIiN1V4n2pB9g0ILoE2(reDnr7MTBxR(fCKX1tqQXTzb5O(V0)KrR(z5tHwVbT124cVQp0qIPUdx(2SD7A1VGJmUof5xidh1)L(NmA0O9tWZc9txFOHetDhU8XruESGwCqJaR7SYMnaYeLh)utJRjhXyfLh)ylr13pIbY9tkjOSG7R(fkNlF7Jm3(reD9NusqzbTqOCCGiYzTX)tQyS5)m0eTaYsFa1uMb0eeqBKfeqx9jxjNaOfKeoD5ihqrtbr02IDavMoGcjfzuiGk5CmHtoGkvavauxk44aAccO1KWvnaAm(dOg)pPIbqZ)zaOjn4Gl4bOEdcOfYvYjakerodOrfqfhq)dqHWYNaORaOvubituE8tnnUMCeJvuE8JTevF)igi3c5k5KFFK5UE9rmy(psOUqUsoPAZfe9yizjvcJ2kQrtbr02I9nCw7sbhxdjfzuOvY5ycNCnocub7B4SgIiN1fYvYjvBUGOhdjlPsy0wrnr7goRHiYzDHCLCs1Mli6XqYsQegTvuFOHetDhURSzdGS0hqnLzanbb0gzbb0vFYvYjaAbjHtxoYbu0uqeTTyhqLPdOz8KcGk5CmHtoGkvavauxk44aAccO1KWvnaAm(dOz8KcGM)ZaqtAWbxWdq9geqlKRKtauiICgqJkGkoG(hGcHLpbqxbqROcqMO84NAACn5igRO84hBjQ((rmqUfYvYjQ9rM761hXG5)iH6c5k5KQnxq0JHKLujmAROgnferBl23WzTlfCCDgpPyLCoMWjxJJavW(goRHiYzDHCLCs1Mli6XqYsQegTvut0UHZAiICwxixjNuT5cIEmKSKkHrBf1hAiXu3H7kB2ail9butzgqtqt9HaQaOtqQXZccOY0b0eeq7)yQDanrghq9hqvINGYcAYNusqzb3dOY0b0eeqBKfeqHKImk0KmEsbqLCoMWjhqDPGJJ99a6Qxdo4cEaQ6NLpfcOQoGgvaLOfqtqaTMeUQbqJXFavY5ycNCan)NbG6pGQKQdOHVhqBWdbuJ)NuXaO5)m0aYeLh)utJRjhXyfLh)ylr13pIbY9v)S8PW9rMBfDpgsvDTjYUn)Nv9ZYNc5SETlfCCnKuKrHwjNJjCY14iqfSVHZAZ7hr01kXtqzbTqOCB4S28(reD9NusqzbTqOCB4Sw9l4iJRNGuJBZcYr9FP)jJw9ZYNcTEdARTXfEvFOHetDhU8TzdGS0hqnLzanbn1hcOcGobPgpliGkthqtqaT)JP2b0ezCa1FavjEcklOjFsjbLfCpGkthqtqaTrwqafskYOqtY4jfavY5ycNCa1Lcoo23dOREn4Gl4bOQFw(uiGQ6aAubuIwanbb0As4Qgang)bujNJjCYb08FgaQ)aQsQoGg(EaTbpeqvIN)ZaqZ)zObKjkp(PMgxtoIXkkp(XwIQVFedKRs9ZYNc3hzUv09yiv11Mi728Fw1plFkKZ61UuWX1z8KIvY5ycNCnocub7B4S28(reDTs8euwqlek3goRnVFerx)jLeuwqlek3goRv)coY46ji142SGCu)x6FYOv)S8PqR3G2ABCHx1hAiXu3HlFB2aituE8tnnUMOKsXkkp(XwIQVFedKRr4bjXJFaKjkp(PMgxtoIXkkp(XwIQVFedKlekhGmazIYJFQAiuoUqOC28Fg7JmxZHiYznekNn)NHMOfqMO84NQgcLlnUM0GY52pB9g0MeL((iZ1LcoUUbLZTF26nOnjkDnocub7Cw7sbhxdjfzuOvY5ycNCnocub7B4O(fCKX1l44nKFaYeLh)u1qOCPX1eJ)NCC4(iZD9AiICwtskIYdLLeHC9qgnr7goIYJf0IdAeyDNv2SD761qe5SMKueLhkljc56HmAI2nCmV)U24)jhhQ9qLkgsCeLhlOfh0iW6U8XXLJe6ApmqR)2EG7Y3kBaKjkp(PQHq5sJRjg)p54W9rM76(7AJ)NCCO(qdjM6oCthN1qe5SMKueLhkljc56HmAI2nCeLhlOfh0iW6UMMJlhj01EyGw)T9a3LVv2aituE8tvdHYLgxtm(FYXH7Jm31hMpS2iqfKJO8ybT4Ggbw3zfoUCKqx7HbA932dCx(wzZ2TRnV)U24)jhhQ9qLkgsCeLhlOfh0iW6U8XXLJe6ApmqR)2EG7Y3kBaKjkp(PQHq5sJRjNSGZtuT5dN0l5aYeLh)u1qOCPX1eIkAdhn2pIbYLh)DIHeg3z7y1JH8QvjLY(iZv9l4iJRxWXBi)aKjkp(PQHq5sJRjev0goASVwENRFXKcD(2hzUMdrKZ627tkAIwoQFbhzC9coEd5hGmr5XpvnekxACnHOI2WrJ91Y7C9lMuOVY(iZ1CiICw3EFsrt0Yr9l4iJRxWXBi)aKjkp(PQHq5sJRjTVh)SpYCv)coY46fC8gYpoqe5SogLCJ4Xp6dnKyQ7YDfEGderoRJrj3iE8J(qdjM6oCxX0aYeLh)u1qOCPX1e1plFk06nOT2gx419rMR59Ji6AL4jOSGwiuooM3pIOR)KscklOfcLdqMO84NQgcLlnUMaHxfVuwiuU9rM7AiICwFYcopr1MpCsVKRjA3U1C1VGJmUEbhVH8BdGmr5XpvnekxACnjgLCJ4Xp7Jm31qe5S(KfCEIQnF4KEjxt0UDR5QFbhzC9coEd53gazIYJFQAiuU04AceEv8sfdP9rM7AiICwdHxfVuwiuonr72Tqe5SogLCJ4XpwseY1dzSF2sC1xPjA3aituE8tvdHYLgxtKU06XcARjYzSpYCxBE)DT0LwpwqBnrodBxmesO2dvQyiXXCr5XpAPlTESG2AICg2UyiKqDm2Cji14CwBE)DT0LwpwqBnrodBdkfThQuXqA72(7APlTESG2AICg2guk6dnKyQ7MUnB32FxlDP1Jf0wtKZW2fdHeQRUOsTt640FxlDP1Jf0wtKZW2fdHeQp0qIPUJP50FxlDP1Jf0wtKZW2fdHeQ9qLkgsBaKjkp(PQHq5sJRjEZj1glek3ExosOBJm3dZhwBeOcUDB)DT3CsTXcHYPRUOsTt62UDD)DT3CsTXcHYPRUOsTdpW5igm)hjuxiYzjMmrf7w0a6efQrtbr02I9nB3kkpwqloOrG1D5YdaYeLh)u1qOCPX1edzivW9rM7jKqDhZHk8D5JNCQO7XqQQnKHubTg)HaYeLh)u1qOCPX1KCbRnQtY((iZT(efOy66wIQtuqlEeTE8JghbQGDoRxR(V0)Kr7nNuBSqOC6dnKyQ7YtoQ)l9pz0gYqQG6dnKyQ7YZnCw3FxB8)KJd1hAiXu3LB62WzneroRJrj3iE8JLeHC9qg7NTex9v6(NmCGiYzneEv8szHq509pz4arKZAssruEOSKiKRhYO7FYSzZ2T1NOaftxV8fXJcARFzbhxJJavW((yC8oIw3gggypeh5Y3(yC8oIw3sQ8qsHlF7JXX7iADBK5wFIcumD9YxepkOT(LfCCoRv)x6FYO9MtQnwiuo9Hgsm1D5jh1)L(NmAdzivq9Hgsm1D55gazIYJFQAiuU04AsnjAX9rMleroRJrj3iE8JLeHC9qg7NTex9v6(NmCGiYzneEv8szHq509pz4ikpwqloOrG1D5YdaYeLh)u1qOCPX1edHOSpYCHiYzDmk5gXJF0eTCeLhlOfh0iW6oRSDleroRHWRIxklekNMOLJO8ybT4Ggbw3zfazIYJFQAiuU04AIHqu2hzURHiYzDvwesOv9gqIlJRRUOsTlx(2WzneroR9)9gRmDRQijAI2nCGiYzDmk5gXJF0eTCeLhlOfh0iWk3vaKjkp(PQHq5sJRjgYqQG7JmxiICwhJsUr84hnrlhr5XcAXbncSUd30bituE8tvdHYLgxtmeIY(iZD961qe5S2)3BSY0TQIKORUOsTl3v2SD7AiICw7)7nwz6wvrs0eTCGiYzT)V3yLPBvfjrFOHetDh(0MEZ2TRHiYzDvwesOv9gqIlJRRUOsTl30Tzdhr5XcAXbncSUt62aituE8tvdHYLgxt8MtQnwiuU9rMRO8ybT4Ggbw3LpazIYJFQAiuU04AIHmKk4(iZD96tiH7SA45goIYJf0IdAeyDN0Tz721RpHeUZQ20B4ikpwqloOrG1Dshhxk4466tuSF26nOn)hwDnocub7BaKjkp(PQHq5sJRjTeLf8I0lUxrUQGwxosOx5Y3(iZT)U2BoP2yHq50vxuP2DfazIYJFQAiuU04AI3CsTXcHYbituE8tvdHYLgxtmeIY(iZvuESGwCqJaR7KoazIYJFQAiuU04AsnjArlekhGmr5XpvnekxACnjUFYe3(iZ9esOUJ5qf(o8ap5arKZ64(jtC6dnKyQ7WtTPbKbituE8tvBeEqs84hUX9tM42hzUXOEJyiz7IHqcTMUUBC)KjoBxmesO1BoS28LohiICwh3pzItFOHetDN0LE0ivhbKjkp(PQncpijE8tACn5WbtKY(iZ1LjvmK40GsXB0TkFhEKPbKjkp(PQncpijE8tACnjF4KEdSBpKeo4jE8Z(iZ1LjvmK40GsXB0TkFhEKPbKjkp(PQncpijE8tACnbnA)e8Sq)03hzURnVFerxRepbLf0cHYXX8(reD9NusqzbTqOCB2UvuESGwCqJaR7YDfazIYJFQAJWdsIh)KgxtGKlvnvm7JmxxMuXqItdkfVr3Q8DmvMMtmQ3igs2UyiKqRPR7YtnFPhnOu8gTHSkaYeLh)u1gHhKep(jnUMujULyrk2yQEmkVUpYCHiYzDL4wIfPyJP6XO8QU)jdhiICwdjxQAQy09pz40GsXB0TkFhEep5eJ6nIHKTlgcj0A66U8uVIPtpAqP4nAdzvaKbituE8tvR(V0)KPYT994hazIYJFQA1)L(Nm104Acu5)UntCKdituE8tvR(V0)KPMgxtGWRIxQyibituE8tvR(V0)KPMgxtKtjdA9)oCCazIYJFQA1)L(Nm104Asji14vlporNKbooGmr5XpvT6)s)tMAACnjhhcv(VdituE8tvR(V0)KPMgxtKrHv)KIvjLcGmr5XpvT6)s)tMAACnb6IQxIHKntC7JmxiICwdHYzZ)zOjAbKjkp(PQv)x6FYutJRjXOKBep(zFK5UU)U24)jhhQ9qLkgsB3kkpwqloOrG1D5BdN(7AV5KAJfcLt7HkvmKaKjkp(PQv)x6FYutJRjq4vXlfGmr5XpvT6)s)tMAACnHOI2WrJ9yoJk3oIbYvrUQ8(9tOSqfP6aYeLh)u1Q)l9pzQPX1eIkAdhnQaYaKjkp(PQvINGYcYT9(KcGmr5XpvTs8euwW04AIsCB(pJ9rMR5qe5SwjUn)NHMOfqMO84NQwjEcklyACn5Ku4(iZfIiN1T3Nu0eTaYeLh)u1kXtqzbtJRjnOCU9ZwVbTjrPVpYCDPGJRBq5C7NTEdAtIsxJJavWohZHiYzDdkNB)S1BqBsu6AIwazIYJFQAL4jOSGPX1e0O9tWZc9tFFK52pIORvINGYcAHq5aKjkp(PQvINGYcMgxtojfUpYC7VRpjfQpmFyTrGkih1Ba922pgVUdpaituE8tvRepbLfmnUMCr7(iZT)U(Iw9H5dRncub5OEdO32(X41D5YdaYeLh)u1kXtqzbtJRjQFw(uO1BqBTnUWR7Jm3(reDTs8euwqlekhGmr5XpvTs8euwW04AsgVxfpr1cfoU3qwflo4rICU8TpYCvVb0BB)y86UC5bazIYJFQAL4jOSGPX1ePlTESG2AICg7Jm31M3FxlDP1Jf0wtKZW2fdHeQ9qLkgsCmxuE8Jw6sRhlOTMiNHTlgcjuhJnxcsnoN1M3FxlDP1Jf0wtKZW2Gsr7HkvmK2UT)Uw6sRhlOTMiNHTbLI(qdjM6UPBZ2T931sxA9ybT1e5mSDXqiH6QlQu7Koo931sxA9ybT1e5mSDXqiH6dnKyQ7yAo931sxA9ybT1e5mSDXqiHApuPIH0gazIYJFQAL4jOSGPX1KCbRnQtY((iZT(efOy66wIQtuqlEeTE8JghbQGDo4GhjY3jDME726tuGIPRx(I4rbT1VSGJRXrGkyFFmoEhrRBdddShIJC5BFmoEhrRBjvEiPWLV9X44DeTUnYCRprbkMUE5lIhf0w)YcoohCWJe57KotdituE8tvRepbLfmnUMuBoSVpYCvVb0BB)y8QwrCho(oMgqgGmr5XpvTs9ZYNc5Qe3M)ZaqMO84NQwP(z5tHPX1Kguo3(zR3G2KO03hzUUuWX1nOCU9ZwVbTjrPRXrGkyNJ5qe5SUbLZTF26nOnjkDnrlGmr5XpvTs9ZYNctJRjQFw(uO1BqBTnUWR7Jm36tuGIPRZXvDB1VifQXrGkyNderoRZXvDB1VifQjAbKjkp(PQvQFw(uyACnr9ZYNcTEdARTXfEDFK56sbhx3GY52pB9g0MeLUghbQGDoqe5SUbLZTF26nOnjkDnrlGmr5XpvTs9ZYNctJRjQFw(uO1BqBTnUWR7Jmxxk446guo3(zR3G2KO014iqfSZr9FP)jJUbLZTF26nOnjkD9Hgsm1D5Z0aYeLh)u1k1plFkmnUMO(z5tHwVbT124cVUpYCn3LcoUUbLZTF26nOnjkDnocub7aYaKjkp(PQlKRKtuCvIBZ)zaidqMO84NQUqUso55A8)KkgB(pdazaYeLh)u1V6NLpfY14)jvm28FgaYeLh)u1V6NLpfMgxtAq5C7NTEdAtIsFFK56sbhx3GY52pB9g0MeLUghbQGDoMdrKZ6guo3(zR3G2KO01eTaYeLh)u1V6NLpfMgxtu)S8PqR3G2ABCHx3hzU1NOaftxNJR62QFrkuJJavWohiICwNJR62QFrkut0cituE8tv)QFw(uyACnP6YLJd3hzUOQeTvuld52bxfF7wuvI2kQRFro7GRIdituE8tv)QFw(uyACnj5eVzFK5IQs0wrTmKBhCv8TBrvjAROUqmYzhCvCazIYJFQ6x9ZYNctJRjQFw(uO1BqBTnUWR7Jmxxk446guo3(zR3G2KO014iqfSZbIiN1nOCU9ZwVbTjrPRjAbKjkp(PQF1plFkmnUMO(z5tHwVbT124cVUpYCDPGJRBq5C7NTEdAtIsxJJavWoh1)L(Nm6guo3(zR3G2KO01hAiXu3LptdituE8tv)QFw(uyACnr9ZYNcTEdARTXfEDFK5AUlfCCDdkNB)S1BqBsu6ACeOc2bKbituE8tv)jLeuwqUg)pPIXM)ZyFK5AoeroRn(FsfJn)NHMOfqMO84NQ(tkjOSGPX1Kguo3(zR3G2KO03hzUUuWX1nOCU9ZwVbTjrPRXrGkyNJ5qe5SUbLZTF26nOnjkDnrlGmr5Xpv9NusqzbtJRjvxUkXrcbKjkp(PQ)KscklyACnr9ZYNcTEdARTXfEDFK5wFIcumDDoUQBR(fPqnocub7aYeLh)u1FsjbLfmnUMGgTFcEwOF67Jm3(reD9NusqzbTqOCaYeLh)u1FsjbLfmnUMiDP1Jf0wtKZyFK5U28(7APlTESG2AICg2UyiKqThQuXqIJ5IYJF0sxA9ybT1e5mSDXqiH6yS5sqQX5S28(7APlTESG2AICg2gukApuPIH02T931sxA9ybT1e5mSnOu0hAiXu3nDB2UT)Uw6sRhlOTMiNHTlgcjuxDrLAN0XP)Uw6sRhlOTMiNHTlgcjuFOHetDhtZP)Uw6sRhlOTMiNHTlgcju7HkvmK2aituE8tv)jLeuwW04AsLyYXH7vKRkO1LJe6vU8TpYCpmFyTrGkiGmr5Xpv9NusqzbtJRjg)p54W9kYvf06Yrc9kx(2hzUhMpS2iqfC7wiICwtskIYdLLeHC9qgnrlGmr5Xpv9NusqzbtJRjvxUCC4(iZv9l4iJRNGuJBZcYbvLOTIAzi3o4Q4aYeLh)u1FsjbLfmnUMKCI3SpYCnx9l4iJRNGuJBZcYbvLOTIAzi3o4Q4aYeLh)u1FsjbLfmnUMO(z5tHwVbT124cVUpYCxdrKZAuvI2kAleJCAI2TBHiYznQkrBfT1ViNMODdGmr5Xpv9NusqzbtJRjvxUCC4(iZDnQkrBf1XyleJCB3IQs0wrD9lYzhCv8nB3UgvLOTI6ySfIrooqe5SU6YvjosOfnA)e8mWXTfIronr7gazIYJFQ6pPKGYcMgxtsoXByW1wuX4NpEYdmN5mga]] )


end