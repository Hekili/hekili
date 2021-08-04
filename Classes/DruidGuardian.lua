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

    spec:RegisterPack( "Guardian", 20210804, [[dCeM7bqifrpcvuSjLQpPivAukPoLsXQuKs6vksMfOQBPivPDrYVeIggQihdvPLPuQNjeAAGk11ec2gQO03uKsnofPIZPiv16uKs08uk5EOs7duXbrfvQfQi8qurfteujvUOIufFeujLtQifTsufZevuj3eujvTtuv(jQOkpfQMkQQ(QIuc7fL)sXGHCyIfdYJj1Kv4YiBwWNbLrluNw0Qrfv1RfsZwIBtj7wQFdmCL44ksHLRYZL00P66qz7kQVtPgpOsCEuH1dQKmFLK9RQz8Y4NHpeNy8TnN2MxonD4eCR4L3T3MttFgUZXcXWxeDubgXWBXIy4W1WKBKsZWxeokazW4NHxbyNMy4XUVuNwgzKWspgdsPbwrwtlSI4jO1Ne8iRPLosgoeww8PzZGy4dXjgFBZPT5Ltthob3kE5D7T500HHlyEm4y44PfNddpohdQzqm8bv1mC4AyYnsPFeCDhwoEE4CJbdR6pcUH)rBZPT59555HZjwAyuDA5ZZ07JMMTgClGtC6rCoIhjC9aqhn7hTCj4spP6JwNHhvj3Zg2JY6J0XKokn2OEEMEF00S1GBbCItpcS4jOFKdEunod(JwdUh1aFZJGOa4OhX5a6zqusXWlz1Rm(z4fo0Yjag)m(4LXpdx0EcAgUfa0rZ2eaNfdNAbQqd2emN5mCisog)m(4LXpdNAbQqd2emC9LoDPWWN8rqyHGcIKZeaNLcBHHlApbndhIKZeaNfZz8TnJFgo1cuHgSjy46lD6sHH7sHAxftY5gqW4XKXoldf1cuHgpA)rRFKlfQDfKuKwtgjeYoDouulqfA8OnpA)rAWm1s7QzQ9yoogUO9e0m8yso3acgpMm2zzWCgFrKXpdNAbQqd2emC9LoDPWWx)O1pccleuWKIO9uBGHj3iLwHT8OnpA)rI2ZzYqnzLu9rB9OTF0MhTA1Jw)O1pccleuWKIO9uBGHj3iLwHT8OnpA)rt(ObWvwaqhYJuEQJMnShT)ir75mzOMSsQ(i48iEF0(JC5GrUYtlY4aZiPhbNhX72pAddx0EcAgUfa0H8iMZ4dUz8ZWPwGk0GnbdxFPtxkm81pAaCLfa0H8i1rws21hTf3hfXhT)O1pccleuWKIO9uBGHj3iLwHT8OnpA)rI2ZzYqnzLu9rW5rr4r7pYLdg5kpTiJdmJKEeCEeVB)OnmCr7jOz4waqhYJyoJViW4NHtTavObBcgU(sNUuy4RF0rHJQXcuHE0(JeTNZKHAYkP6J26rB)O9h5YbJCLNwKXbMrspcopI3TF0MhTA1Jw)OjF0a4klaOd5rkp1rZg2J2FKO9CMmutwjvFeCEeVpA)rUCWix5PfzCGzK0JGZJ4D7hTHHlApbnd3ca6qEeZz8Xzz8ZWfTNGMHFYm1aSQjCudxXbdNAbQqd2emNX30MXpdNAbQqd2emCr7jOz4C(ahRHr5DMbv9S5OA0sPWW1x60LcdxdMPwAxntThZXXWBXIy4C(ahRHr5DMbv9S5OA0sPWCgFthg)mCQfOcnytWWfTNGMH7x2rjNxgU(sNUuy4t(iiSqqTCa7IcB5r7psdMPwAxntThZXXWRfGZW9l7OKZlZz8n9z8ZWPwGk0Gnbdx0EcAgUFzhL8Tz46lD6sHHp5JGWcb1YbSlkSLhT)inyMAPD1m1EmhhdVwaod3VSJs(2mNXhVCIXpdNAbQqd2emC9LoDPWW1GzQL2vZu7XCCpA)rqyHGkBTCT4jOvhzjzxFeC4(OTH7hT)iiSqqLTwUw8e0QJSKSRpAlUpA7iWWfTNGMHVa8e0mNXhV8Y4NHtTavObBcgU(sNUuy4t(OXHLdLwCBsMjdej3J2F0KpACy5qbSl2KmtgisogUO9e0mCnONbrjJhtM6sEPxzoJpE3MXpdNAbQqd2emC9LoDPWWx)iiSqqDYm1aSQjCudxXHcB5rRw9OjFKgmtT0UAMApMJ7rBy4I2tqZWHORsxuMZ4J3iY4NHtTavObBcgU(sNUuy4RFeewiOozMAaw1eoQHR4qHT8OvRE0KpsdMPwAxntThZX9OnmCr7jOz4zRLRfpbnZz8XlCZ4NHtTavObBcgU(sNUuy4RFeewiOGORsxudejNcB5rRw9iiSqqLTwUw8e0gyyYnsPnGGb7QaTcB5rBy4I2tqZWHORsx0SHXCgF8gbg)mCQfOcnytWW1x60LcdF9JM8rdGRKHS45mzQ2YzzgILaJuEQJMnShT)OjFKO9e0kzilEotMQTCwMHyjWiv2MqjHf7pA)rRF0KpAaCLmKfpNjt1woltmjfLN6Ozd7rRw9ObWvYqw8CMmvB5SmXKuuhzjzxFeCEueF0MhTA1JgaxjdzXZzYuTLZYmelbgPQUOJ(OTEueF0(JgaxjdzXZzYuTLZYmelbgPoYsYU(OTEueE0(JgaxjdzXZzYuTLZYmelbgP8uhnBypAddx0EcAgUmKfpNjt1wolMZ4JxolJFgo1cuHgSjy46lD6sHHFu4OASavOhTA1Jgax5XNuJnqKCQQl6OpARhfXhTA1Jw)ObWvE8j1ydejNQ6Io6J26rW9J2F0H1uaCWivbleKSdyvAyilOt0KIMgy5YcnE0MhTA1JeTNZKHAYkP6JGd3hb3mCr7jOz4E8j1ydejhZz8X70MXpdNAbQqd2emC9LoDPWWpbgPgui1P)i48iE50J2FuLCpByvLL0WkKXcCedx0EcAgUL0WkeZz8X70HXpdNAbQqd2emC9LoDPWWRaScu2d1cw1XkKHoSfpbTIAbQqJhT)O1pA9J0aqzaSBLhFsn2arYPoYsYU(i48io9O9hPbGYay3klPHvi1rws21hbNhXPhT5r7pA9JgaxzbaDipsDKLKD9rWH7JI4J28O9hT(rqyHGkBTCT4jOnWWKBKsBabd2vbA1ay3pA)rqyHGcIUkDrnqKCQbWUF0(JGWcbfmPiAp1gyyYnsPvdGD)OnpAZJwT6rvawbk7HAgueplKPckZu7kQfOcny4z70DylUjdm8kaRaL9qndkINfYubLzQ991AaOma2TYJpPgBGi5uhzjzxHdN21aqzaSBLL0WkK6ilj7kC40ggE2oDh2IBsllAKItmCEz4I2tqZWdfQgRpj4m8SD6oSf3aRaGKcdNxMZ4J3PpJFgo1cuHgSjy46lD6sHHdHfcQS1Y1ING2adtUrkTbemyxfOvdGD)O9hbHfcki6Q0f1arYPga7(r7ps0EotgQjRKQpcoCFeCZWfTNGMHxTZfYarYXCgFBZjg)mCQfOcnytWW1x60LcdhcleuzRLRfpbTcB5r7ps0EotgQjRKQpARhfXhT)O1pccleuoa4XgPhgDrSvvx0rFeC4(OTF0MhTA1Jw)iiSqq5aGhBKEy0fXwHT8O9hbHfckha8yJ0dJUi2QJSKSRpARhXRkcpAZJwT6rRFeewiOQYSaJmAGfK4s7QQl6OpcoCFueF0MhTA1JGWcbfeDv6IAGi5uylpA)rI2ZzYqnzLu9rB9OiYWfTNGMHBjyfMZ4BBEz8ZWPwGk0GnbdxFPtxkm81pccleuvzwGrgnWcsCPDv1fD0hbhUpI3hT5r7pA9JGWcbLdaESr6HrxeBf2YJ28O9hbHfcQS1Y1INGwHT8O9hjApNjd1Kvs1hX9rBZWfTNGMHBjyfMZ4B7Tz8ZWPwGk0GnbdxFPtxkmCiSqqLTwUw8e0kSLhT)ir75mzOMSsQ(OT4(OiYWfTNGMHBjnScXCgFBhrg)mCQfOcnytWW1x60LcdF9Jw)O1pccleuoa4XgPhgDrSvvx0rFeC4(OTF0MhTA1Jw)iiSqq5aGhBKEy0fXwHT8O9hbHfckha8yJ0dJUi2QJSKSRpARhXRkcpAZJwT6rRFeewiOQYSaJmAGfK4s7QQl6OpcoCFueF0MhT5r7ps0EotgQjRKQpARhfXhTHHlApbnd3sWkmNX32WnJFgo1cuHgSjy46lD6sHHlApNjd1Kvs1hbNhXldx0EcAgUhFsn2arYXCgFBhbg)mCQfOcnytWW1x60LcdF9Jw)OtGrpARhn950J28O9hjApNjd1Kvs1hT1JI4J28OvRE06hT(rNaJE0wpA6eHhT5r7ps0EotgQjRKQpARhfXhT)ixku7QkaRyabJhtMa4OQROwGk04rBy4I2tqZWTKgwHyoJVT5Sm(z4ulqfAWMGHlApbndFbRmtxcxrmC9LoDPWWhax5XNuJnqKCQQl6OpcopABgUMdDHmUCWiVY4JxMZ4B7PnJFgUO9e0mCp(KASbIKJHtTavObBcMZ4B7PdJFgo1cuHgSjy46lD6sHHlApNjd1Kvs1hT1JIidx0EcAgULGvyoJVTN(m(z4I2tqZWR25czGi5y4ulqfAWMG5m(IiNy8ZWPwGk0GnbdxFPtxkm8tGrQbfsD6pARhb3C6r7pccleu5b6a2PoYsYU(OTEeNurGHlApbndppqhWoMZCgUv6jmXtqZ4NXhVm(z4ulqfAWMGHRV0PlfgE2AGv2WmdXsGrMiuFeCEuEGoGDMHyjWiJhFungugpA)rqyHGkpqhWo1rws21hT1JI4JMwFuSuDIHlApbndppqhWoMZ4BBg)mCQfOcnytWW1x60Lcd3LoA2WE0(JIjP4XQfT)OTEeNncmCr7jOz4h1KTuyoJViY4NHtTavObBcgU(sNUuy4U0rZg2J2FumjfpwTO9hT1J4SrGHlApbndpCudxL0WCemQPt8e0mNXhCZ4NHtTavObBcgU(sNUuy4RF0KpACy5qPf3MKzYarY9O9hn5Jghwoua7InjZKbIK7rBE0Qvps0EotgQjRKQpcoCF02mCr7jOz4K1cWModeOhmNXxey8ZWPwGk0GnbdxFPtxkmCx6Ozd7r7pkMKIhRw0(J26rt7i8O9hLTgyLnmZqSeyKjc1hbNhXjfVpAA9rXKu8yLLaxy4I2tqZWHKlAnA2mNXhNLXpdNAbQqd2emC9LoDPWWHWcbvf7MZzPyYU6zR9QAaS7hT)iiSqqbjx0A0SvdGD)O9hftsXJvlA)rB9iolNE0(JYwdSYgMziwcmYeH6JGZJ4KA7i8OP1hftsXJvwcCHHlApbndVIDZ5Sumzx9S1EL5mNHRf3MKzIXpJpEz8ZWfTNGMHVCa7cdNAbQqd2emNX32m(z4ulqfAWMGHRV0Plfg(KpccleuAXnbWzPWwy4I2tqZW1IBcGZI5m(IiJFgo1cuHgSjy46lD6sHHdHfcQLdyxuylmCr7jOz4NeLyoJp4MXpdNAbQqd2emC9LoDPWWDPqTRIj5Cdiy8yYyNLHIAbQqJhT)OjFeewiOIj5Cdiy8yYyNLHcBHHlApbndpMKZnGGXJjJDwgmNXxey8ZWPwGk0GnbdxFPtxkm8XHLdLwCBsMjdejhdx0EcAgozTaSPZab6bZz8Xzz8ZWPwGk0GnbdxFPtxkm8bWvNeLuhfoQglqf6r7psdSGaMfq2E9rB9i4MHlApbnd)KOeZz8nTz8ZWPwGk0GnbdxFPtxkm8bWvxUOokCunwGk0J2FKgybbmlGS96JGd3hb3mCr7jOz4xUWCgFthg)mCQfOcnytWW1x60LcdFCy5qPf3MKzYarYXWfTNGMHRb9mikz8yYuxYl9kZz8n9z8ZWPwGk0GnbdxFPtxkmCnWccywaz71hbhUpcUz4I2tqZWd0b0jaRAGsNy4wcCXqnDW4GXhVmNXhVCIXpdNAbQqd2emC9LoDPWWx)OjF0a4kzilEotMQTCwMHyjWiLN6Ozd7r7pAYhjApbTsgYINZKPAlNLziwcmsLTjusyX(J2F06hn5JgaxjdzXZzYuTLZYetsr5PoA2WE0QvpAaCLmKfpNjt1woltmjf1rws21hbNhfXhT5rRw9ObWvYqw8CMmvB5SmdXsGrQQl6OpARhfXhT)ObWvYqw8CMmvB5SmdXsGrQJSKSRpARhfHhT)ObWvYqw8CMmvB5SmdXsGrkp1rZg2J2WWfTNGMHldzXZzYuTLZI5m(4Lxg)mCQfOcnytWW1x60LcdVcWkqzpulyvhRqg6Ww8e0kQfOcnE0(JOMoyC8OTEueJWJwT6rvawbk7HAgueplKPckZu7kQfOcny4z70DylUjdm8kaRaL9qndkINfYubLzQ9DQPdghBfXiWWZ2P7WwCtAzrJuCIHZldx0EcAgEOq1y9jbNHNTt3HT4gyfaKuy48YCgF8UnJFgo1cuHgSjy46lD6sHHRbwqaZciBVQ0y3rT)OTEuey4I2tqZWRXhnyoZz4fo0YjAg)m(4LXpdx0EcAgUwCtaCwmCQfOcnytWCMZWhuqWkoJFgF8Y4NHtTavObBcg(GQ6lx8e0m8Ph4cPXCA8iAMooEKNw0J8y6rI2b3JY6JKzjlcuHumCr7jOz41OyLIbsQXmNX32m(z4ulqfAWMGHlApbndNZh4ynmkVZmOQNnhvJwkfgU(sNUuy4t(iiSqqTCa7IcB5r7pAYhPbZulTRMP2J54y4TyrmCoFGJ1WO8oZGQE2CunAPuyoJViY4NHtTavObBcgUO9e0mC)Yok58YW1x60LcdFYhbHfcQLdyxuylpA)rt(inyMAPD1m1EmhhdVwaod3VSJsoVmNXhCZ4NHtTavObBcgUO9e0mC)Yok5BZW1x60LcdFYhbHfcQLdyxuylpA)rt(inyMAPD1m1EmhhdVwaod3VSJs(2mNXxey8ZWPwGk0GnbdxFPtxkm8jFKgmtT0UAMApMJ7r7pA9Jw)O1pYLc1UkMKZnGGXJjJDwgkQfOcnE0(JGWcbvmjNBabJhtg7SmuylpAZJ2F06hnoSCO0IBtYmzGi5E0QvpACy5qbSl2KmtgisUhT5r7pAYhbHfcQLdyxuylpAZJwT6rRF06hbHfcki6Q0f1arYPWwE0QvpccleuzRLRfpbTbgMCJuAdiyWUkqRWwE0MhT)O1pAYhnoSCO0IBtYmzGi5E0(JM8rJdlhkGDXMKzYarY9OnpAZJ2WWfTNGMHVa8e0mNXhNLXpdNAbQqd2emC9LoDPWWhhwouAXTjzMmqKCpA)rt(inyMAPD1m1Emh3J2F06hT(rAaOma2TYJpPgBGi5uhzjzxFeCEeNE0(J0aqzaSBLL0WkK6ilj76JGZJ40J2F0a4klaOd5rQJSKSRpcoCFem94rt9ioPIWJ2F0jWOhT1JGBo9O9hbHfcQS1Y1ING2adtUrkTbemyxfOvdGD)O9hbHfcki6Q0f1arYPga7(r7pccleuWKIO9uBGHj3iLwna29J28OvRE06hbHfckT4Ma4SuylpA)ruthmoEeCE02r4rBE0QvpA9JgaxDsusDu4OASavOhT)ObWvxUOokCunwGk0J28OvRE06hDynfahmsbep2acgpMmuzqNzCy5qrtdSCzHgpA)rt(iiSqqbep2acgpMmuzqNzCy5qHT8O9hT(rqyHGslUjaolf2YJ2Fe10bJJhbNhTnNE0MhT)iiSqqftY5gqW4XKXold1rws21hTf3hXlNE0MhTA1Jw)inyMAPDvuoUu6hT)inauga7wrwlaB6mqGEOoYsYU(OT4(iEF0(JeTNZKHAYkP6J26rB)OnpA1QhT(rqyHGkMKZnGGXJjJDwgkSLhT)iQPdghpcopA6ZPhT5rBy4v)sTZ4JxgUO9e0m8dRnI2tqBkz1z4LS6MwSigUwCBsMjMZ4BAZ4NHtTavObBcgU(sNUuy4JdlhkT42KmtgisUhT)inyMAPD1m1Emh3J2F06hT(rAaOma2TYJpPgBGi5uhzjzxFeCEeNE0(J0aqzaSBLL0WkK6ilj76JGZJ40J2F0a4klaOd5rQJSKSRpcoCFem94rt9ioPIWJ2F0jWOhT1JGBo9O9hbHfcQS1Y1ING2adtUrkTbemyxfOvdGD)O9hbHfcki6Q0f1arYPga7(r7pccleuWKIO9uBGHj3iLwna29J2F0jWOhT1JGBo9O9hbHfcQS1Y1ING2adtUrkTbemyxfOvdGD)O9hbHfcki6Q0f1arYPga7(r7pccleuWKIO9uBGHj3iLwna29J28OvRE06hbHfckT4Ma4SuylpA)ruthmoEeCE02r4rBE0QvpA9JgaxDsusDu4OASavOhT)ObWvxUOokCunwGk0J2F0jWOhT1JGBo9O9hbHfcQS1Y1ING2adtUrkTbemyxfOvdGD)O9hbHfcki6Q0f1arYPga7(r7pccleuWKIO9uBGHj3iLwna29J28Onm8QFP2z8Xldx0EcAg(H1gr7jOnLS6m8swDtlwedxlUnjZeZz8nDy8ZWPwGk0GnbdxFPtxkm8jF04WYHslUnjZKbIK7r7pccleuAXnbWzPWwy4v)sTZ4JxgUO9e0m8dRnI2tqBkz1z4LS6MwSigUwCBsMjMZ4B6Z4NHtTavObBcgU(sNUuy4JdlhkGDXMKzYarY9O9hT(rRFKgakdGDR84tQXgiso1rws21hbNhXPhT)inauga7wzjnScPoYsYU(i48io9O9hDcm6rB9iEJWJ2FeewiOYwlxlEcA1ay3pA)rqyHGcIUkDrnqKCQbWUF0(JGWcbfmPiAp1gyyYnsPvdGD)OnpA1QhT(rqyHGYca6OzBcGZsHT8O9hnaUQI1H8i1rHJQXcuHE0MhTA1Jw)iiSqqzbaD0SnbWzPWwE0(JGWcbvmjNBabJhtg7SmuylpAZJwT6rRF0H1uaCWifq8ydiy8yYqLbDMXHLdfnnWYLfA8O9hn5JGWcbfq8ydiy8yYqLbDMXHLdf2YJ28OvRE06hPbZulTR6ewSBcc9O9hPbGYay3knONbrjJhtM6sEPxvhzjzxF0wCFeVpAZJwT6rRFKgmtT0Ukkhxk9J2FKgakdGDRiRfGnDgiqpuhzjzxF0wCFeVpA)rI2ZzYqnzLu9rB9OTF0MhTHHx9l1oJpEz4I2tqZWpS2iApbTPKvNHxYQBAXIy4a7InjZeZz8XlNy8ZWPwGk0GnbdxFPtxkm8jF04WYHcyxSjzMmqKCpA)rqyHGYca6OzBcGZsHTWWR(LANXhVmCr7jOz4hwBeTNG2uYQZWlz1nTyrmCGDXMKzI5m(4Lxg)mCQfOcnytWW1x60LcdFCy5qbSl2KmtgisUhT)iiSqqzbaD0SnbWzPWwy4v)sTZ4JxgUO9e0m8dRnI2tqBkz1z4LS6MwSigoWUytYmXCgF8UnJFgo1cuHgSjy4dQQVCXtqZWNMHhztpkwMPhX5IdTCYJkemQhYXXJOPbwUSqJhj94rqsrAn9ijeYoDoEKuFK8ixku7pYMEu1oDD8JY2bpYca6Oz)Oa4SEKDm10mDpYJPhv4qlN8iiSq4rz9rI)iW9iiQaSF02pQsAgUO9e0m8dRnI2tqBkz1z46lD6sHHV(rRF0H1uaCWivHdTCs1eke5zdZaRKwlvsrtdSCzHgpAZJ2F06h5sHAxbjfP1KrcHStNdf1cuHgpAZJ2F06hbHfcQchA5KQjuiYZgMbwjTwQKcB5rBE0(Jw)iiSqqv4qlNunHcrE2WmWkP1sLuhzjzxF0wCF02pAZJ2WWlz1nTyrm8chA5eaZz8XBez8ZWPwGk0GnbdFqv9LlEcAg(0m8iB6rXYm9ioxCOLtEuHGr9qooEennWYLfA8iPhpkqNuEKeczNohpsQpsEKlfQ9hztpQANUo(rz7GhfOtkpkaoRhzhtnnt3J8y6rfo0YjpccleEuwFK4pcCpcIka7hT9JQKMHlApbnd)WAJO9e0MswDgU(sNUuy4RF06hDynfahmsv4qlNunHcrE2WmWkP1sLu00alxwOXJ28O9hT(rUuO2vb6KIrcHStNdf1cuHgpAZJ2F06hbHfcQchA5KQjuiYZgMbwjTwQKcB5rBE0(Jw)iiSqqv4qlNunHcrE2WmWkP1sLuhzjzxF0wCF02pAZJ2WWlz1nTyrm8chA5enZz8XlCZ4NHtTavObBcg(GQ6lx8e0m8Pz4r2009OhjpQtyXEqOhj94r20JgGE66pYwA)ro4rAXTjzMIeyxSjzMG)rspEKn9OyzMEeKuKwtrgOtkpscHStNJh5sHANgW)OPfXutZ09inONbrPhPhpkRpcB5r20JQ2PRJFu2o4rsiKD6C8Oa4SEKdEKwQ(Jsh(hfth9ilaOJM9JcGZsXWfTNGMHFyTr0EcAtjRodxFPtxkm8k5E2WQQACgCtaCgnONbrPhT)O1pA9JCPqTRGKI0AYiHq2PZHIAbQqJhT5r7pA9JM8rJdlhkT42KmtgisUhT5r7pA9JM8rJdlhkGDXMKzYarY9OnpA)rRFKgmtT0UQtyXUji0J2FKgakdGDR0GEgeLmEmzQl5LEvDKLKD9rBX9r8(OnpAddVKv30IfXWbAqpdIsmNXhVrGXpdNAbQqd2em8bv1xU4jOz4tZWJSPP7rpsEuNWI9Gqps6XJSPhna901FKT0(JCWJ0IBtYmfjWUytYmb)JKE8iB6rXYm9iiPiTMImqNuEKeczNohpYLc1onG)rtlIPMMP7rAqpdIspspEuwFe2YJSPhvTtxh)OSDWJKqi7054rbWz9ih8iTu9hLo8pkMo6rAXdGZ6rbWzPy4I2tqZWpS2iApbTPKvNHRV0PlfgELCpByvvnodUjaoJg0ZGO0J2F06hT(rUuO2vb6KIrcHStNdf1cuHgpAZJ2F06hn5JghwouAXTjzMmqKCpAZJ2F06hn5Jghwoua7InjZKbIK7rBE0(Jw)inyMAPDvNWIDtqOhT)inauga7wPb9mikz8yYuxYl9Q6ilj76J2I7J49rBE0ggEjRUPflIHR1GEgeLyoJpE5Sm(z4ulqfAWMGHlApbndxlLIr0EcAtjRodVKv30IfXWTspHjEcAMZ4J3PnJFgo1cuHgSjy4I2tqZWpS2iApbTPKvNHxYQBAXIy4qKCmN5m8LJ0aliXz8Z4Jxg)mCQfOcnytWWhuvF5INGMHp9axinMtJhbrbWrpsdSGe)rqeSSRQhX5wRPfV(Og0tVXYzfWkps0Ec66JaDHdfdx0EcAgE0Shhnm1L8sVYCgFBZ4NHtTavObBcgU(sNUuy4UuO2vXKCUbemEmzSZYqrTavOXJ2F06hnoSCO0IBtYmzGi5E0(JGWcbLwCtaCwkSLhTA1Jghwoua7InjZKbIK7r7pccleuwaqhnBtaCwkSLhTA1JGWcbLfa0rZ2eaNLcB5r7pYLc1UcsksRjJeczNohkQfOcnE0ggUO9e0m8yso3acgpMm2zzWCgFrKXpdNAbQqd2emC9LoDPWWHWcbLwCtaCwkSLhT)OXHLdLwCBsMjdejhdx0EcAg(YbSlmNXhCZ4NHtTavObBcgU(sNUuy4t(iiSqqjnhMa4SuylpA)rRF06hn5Jghwoua7InjZKbIK7r7pAYhnoSCO0IBtYmzGi5E0MhT)O1pAYhPbZulTR6ewSBcc9OnpAZJwT6rRF06hn5Jghwoua7InjZKbIK7r7pAYhnoSCO0IBtYmzGi5E0MhT)O1psdMPwAx1jSy3ee6r7pYLc1U6OQdoXtqBKqi705qrTavOXJ28OvREKgmtT0UAMApMJ7rBy4I2tqZWHi5mbWzXCgFrGXpdNAbQqd2emC9LoDPWWHWcbLfa0rZ2eaNLcB5r7pACy5qbSl2KmtgisUhT)OjFKgmtT0UQtyXUjiedx0EcAgU9jEmZz8Xzz8ZWPwGk0GnbdxFPtxkmCiSqqzbaD0SnbWzPWwE0(Jghwoua7InjZKbIK7r7psdMPwAx1jSy3eeIHlApbndV6YfYJyoJVPnJFgo1cuHgSjy46lD6sHHxbyfOShQfSQJvidDylEcAf1cuHgpA1QhvbyfOShQzqr8SqMkOmtTROwGk0GHNTt3HT4MmWWRaScu2d1mOiEwitfuMP2z4z70DylUjTSOrkoXW5LHlApbndpuOAS(KGZWZ2P7WwCdScaskmCEzoZz4AaOma2DLXpJpEz8ZWfTNGMHVa8e0mCQfOcnytWCgFBZ4NHlApbndhQaadta74GHtTavObBcMZ4lIm(z4I2tqZWHORsx0SHXWPwGk0GnbZz8b3m(z4I2tqZWLtlnzCWDu7mCQfOcnytWCgFrGXpdx0EcAgEjHf7vdNp2aMf1odNAbQqd2emNXhNLXpdx0EcAgEipcQaadgo1cuHgSjyoJVPnJFgUO9e0mCP1u1pPy0sPWWPwGk0GnbZz8nDy8ZWPwGk0GnbdxFPtxkmCiSqqbrYzcGZsHTWWfTNGMHdDz1lzdZeWoMZ4B6Z4NHtTavObBcgU(sNUuy4RF0a4klaOd5rkp1rZg2JwT6rI2ZzYqnzLu9rW5r8(OnpA)rdGR84tQXgisoLN6OzdJHlApbndpBTCT4jOzoJpE5eJFgUO9e0mCi6Q0fLHtTavObBcMZ4JxEz8ZWPwGk0Gnbdx0EcAgUMdDb4hOtTbQivNHtHaPDtlwedxZHUa8d0P2avKQZCgF8UnJFgUO9e0mCSkzsNSQmCQfOcnytWCMZWbAqpdIsm(z8XlJFgUO9e0mClaOJMTjaolgo1cuHgSjyoJVTz8ZWPwGk0GnbdxFPtxkmCxku7Qyso3acgpMm2zzOOwGk04r7pAYhbHfcQyso3acgpMm2zzOWwy4I2tqZWJj5Cdiy8yYyNLbZz8frg)mCQfOcnytWW1x60LcdVcWkqzpuH8QUP6xgLuulqfA8O9hbHfcQqEv3u9lJskSfgUO9e0mCnONbrjJhtM6sEPxzoJp4MXpdNAbQqd2emC9LoDPWWjDjxQKsAomnbx8hTA1JiDjxQKQckYzAcU4mCr7jOz4vxUqEeZz8fbg)mCQfOcnytWW1x60LcdN0LCPskP5W0eCXF0QvpI0LCPsQcwlNPj4IZWfTNGMHBFIhZCgFCwg)mCQfOcnytWW1x60Lcd3Lc1UkMKZnGGXJjJDwgkQfOcnE0(JGWcbvmjNBabJhtg7SmuylmCr7jOz4AqpdIsgpMm1L8sVYCgFtBg)mCQfOcnytWW1x60Lcd3Lc1UkMKZnGGXJjJDwgkQfOcnE0(J0aqzaSBvmjNBabJhtg7SmuhzjzxFeCEeVrGHlApbndxd6zquY4XKPUKx6vMZ4B6W4NHtTavObBcgU(sNUuy4t(ixku7Qyso3acgpMm2zzOOwGk0GHlApbndxd6zquY4XKPUKx6vMZCgUwd6zquIXpJpEz8ZWfTNGMHRf3eaNfdNAbQqd2emNX32m(z4ulqfAWMGHRV0PlfgUlfQDvmjNBabJhtg7SmuulqfA8O9hn5JGWcbvmjNBabJhtg7SmuylmCr7jOz4XKCUbemEmzSZYG5m(IiJFgo1cuHgSjy46lD6sHHxbyfOShQqEv3u9lJskQfOcnE0(JGWcbviVQBQ(Lrjf2cdx0EcAgUg0ZGOKXJjtDjV0RmNXhCZ4NHtTavObBcgU(sNUuy4UuO2vXKCUbemEmzSZYqrTavOXJ2FeewiOIj5Cdiy8yYyNLHcBHHlApbndxd6zquY4XKPUKx6vMZ4lcm(z4ulqfAWMGHRV0PlfgUlfQDvmjNBabJhtg7SmuulqfA8O9hPbGYay3Qyso3acgpMm2zzOoYsYU(i48iEJadx0EcAgUg0ZGOKXJjtDjV0RmNXhNLXpdNAbQqd2emC9LoDPWWN8rUuO2vXKCUbemEmzSZYqrTavObdx0EcAgUg0ZGOKXJjtDjV0RmN5mCGDXMKzIXpJpEz8ZWPwGk0GnbdxFPtxkm8jFeewiOSaGoA2Ma4SuylmCr7jOz4waqhnBtaCwmNX32m(z4ulqfAWMGHRV0PlfgUlfQDvmjNBabJhtg7SmuulqfA8O9hn5JGWcbvmjNBabJhtg7SmuylmCr7jOz4XKCUbemEmzSZYG5m(IiJFgUO9e0m8Qlxf7GrmCQfOcnytWCgFWnJFgo1cuHgSjy46lD6sHHxbyfOShQqEv3u9lJskQfOcny4I2tqZW1GEgeLmEmzQl5LEL5m(IaJFgo1cuHgSjy46lD6sHHpoSCOa2fBsMjdejhdx0EcAgozTaSPZab6bZz8Xzz8ZWPwGk0GnbdxFPtxkm81pAYhnaUsgYINZKPAlNLziwcms5PoA2WE0(JM8rI2tqRKHS45mzQ2YzzgILaJuzBcLewS)O9hT(rt(ObWvYqw8CMmvB5SmXKuuEQJMnShTA1JgaxjdzXZzYuTLZYetsrDKLKD9rW5rr8rBE0QvpAaCLmKfpNjt1wolZqSeyKQ6Io6J26rr8r7pAaCLmKfpNjt1wolZqSeyK6ilj76J26rr4r7pAaCLmKfpNjt1wolZqSeyKYtD0SH9OnmCr7jOz4Yqw8CMmvB5SyoJVPnJFgo1cuHgSjy4I2tqZWRyDipIHRV0Plfg(rHJQXcuHy4Ao0fY4YbJ8kJpEzoJVPdJFgo1cuHgSjy4I2tqZWTaGoKhXW1x60Lcd)OWr1ybQqpA1QhbHfckysr0EQnWWKBKsRWwy4Ao0fY4YbJ8kJpEzoJVPpJFgo1cuHgSjy46lD6sHHRbZulTR6ewSBcc9O9hr6sUujL0CyAcU4mCr7jOz4vxUqEeZz8XlNy8ZWPwGk0GnbdxFPtxkm8jFKgmtT0UQtyXUji0J2FePl5sLusZHPj4IZWfTNGMHBFIhZCgF8YlJFgo1cuHgSjy46lD6sHHV(rqyHGI0LCPsMcwlNcB5rRw9iiSqqr6sUujtfuKtHT8OnmCr7jOz4AqpdIsgpMm1L8sVYCgF8UnJFgo1cuHgSjy46lD6sHHV(rKUKlvsLTPG1Y9OvREePl5sLuvqrottWf)rBE0QvpA9JiDjxQKkBtbRL7r7pccleuvxUk2bJmK1cWMolQDtbRLtHT8OnmCr7jOz4vxUqEeZz8XBez8ZWfTNGMHBFIhZWPwGk0GnbZzoZz4Z0vtqZ4BBoTnVCAAVDez42Y1zdRYWNMwlGZPXJ4L3hjApb9Jkz1RQNhg(YbczHy4CgoZJGRHj3iL(rW1Dy545HZWzEeNBmyyv)rWn8pABoTnVppppCgoZJ4CILggvNw(8Wz4mpA69rtZwdUfWjo9iohXJeUEaOJM9JwUeCPNu9rRZWJQK7zd7rz9r6yshLgBuppCgoZJMEF00S1GBbCItpcS4jOFKdEunod(JwdUh1aFZJGOa4OhX5a6zqus9888WzE00dCH0yonEeefah9inWcs8hbrWYUQEeNBTMw86JAqp9glNvaR8ir7jORpc0fouppI2tqxvlhPbwqIpf3iJM94OHPUKx61Nhr7jORQLJ0aliXNIBKXKCUbemEmzSZYa(mW1Lc1UkMKZnGGXJjJDwgkQfOcn2xpoSCO0IBtYmzGi52HWcbLwCtaCwkSLvRghwoua7InjZKbIKBhcleuwaqhnBtaCwkSLvRGWcbLfa0rZ2eaNLcBz3Lc1UcsksRjJeczNohkQfOcn288iApbDvTCKgybj(uCJC5a2f4ZaxiSqqPf3eaNLcBzFCy5qPf3MKzYarY98iApbDvTCKgybj(uCJeIKZeaNf8zG7KqyHGsAombWzPWw2xVEYXHLdfWUytYmzGi52NCCy5qPf3MKzYarYTzF9KAWm1s7QoHf7MGqB2SA161tooSCOa2fBsMjdej3(KJdlhkT42KmtgisUn7R1GzQL2vDcl2nbH2DPqTRoQ6Gt8e0gjeYoDouulqfASz1knyMAPD1m1Emh3MNhr7jORQLJ0aliXNIBK2N4XWNbUqyHGYca6OzBcGZsHTSpoSCOa2fBsMjdej3(KAWm1s7QoHf7MGqppI2tqxvlhPbwqIpf3iRUCH8i4ZaxiSqqzbaD0SnbWzPWw2hhwoua7InjZKbIKBxdMPwAx1jSy3ee65r0Ec6QA5inWcs8P4gzOq1y9jbh(mWTcWkqzpulyvhRqg6Ww8e0kQfOcnwTQcWkqzpuZGI4zHmvqzMAxrTavOb8z70DylUjTSOrkoXLx4Z2P7WwCdScaskC5f(SD6oSf3KbUvawbk7HAgueplKPckZu7ppppCMhn9axinMtJhrZ0XXJ80IEKhtps0o4EuwFKmlzrGkK65r0Ec6k3AuSsXaj14Nhr7jORtXnsSkzsNSGVflIlNpWXAyuENzqvpBoQgTukWNbUtcHfcQLdyxuyl7tQbZulTRMP2J54EEeTNGUof3iXQKjDYc(Ab4C9l7OKZl8zG7KqyHGA5a2ff2Y(KAWm1s7QzQ9yoUNhr7jORtXnsSkzsNSGVwaox)Yok5BdFg4ojewiOwoGDrHTSpPgmtT0UAMApMJ75r0Ec66uCJCb4jOHpdCNudMPwAxntThZXTVE9Axku7Qyso3acgpMm2zzOOwGk0yhcleuXKCUbemEmzSZYqHTSzF94WYHslUnjZKbIKB1QXHLdfWUytYmzGi52SpjewiOwoGDrHTSz1Q1RHWcbfeDv6IAGi5uylRwbHfcQS1Y1ING2adtUrkTbemyxfOvylB2xp54WYHslUnjZKbIKBFYXHLdfWUytYmzGi52SzZZdNHZ8iohXTjzoByps0Ec6hvYQ)i7SuEee9Ot6hLb4FKL0WkuKE8j14hjh9iq)i9a(hDcm6rz9rquby)i4MtW)i4k6I(iPhpkBTCT4jOFKC0Jga7(rspEeCnmPiAp1pcgMCJu6hbHfcpkRpQb(JeTNZe8pcCpkdW)iBA6E0JY(rAXdGZ6rspEe10bJJhL1hjqGz6rBhb4FeN39Om8iB6rXYm9ipMEeNN4XpQqWOEihhpIMgy5YcnG)rEm9ObbHfcpQKDuA8ih8O0FuwFud8hHT8iPhpIA6GXXJY6JeiWm9OT5e8CE3JYWJSPP7rpkkhxk9JKE8OPhRfGnDpcc0JhPbGYay3pkRpcB5rspEe1Kvs1hjh9OSd0LG7ro4rBREEeTNGUof3ipS2iApbTPKvh(QFP25Yl8TyrC1IBtYmbFg4ooSCO0IBtYmzGi52NudMPwAxntThZXTVETgakdGDR84tQXgiso1rws2v4WPDnauga7wzjnScPoYsYUchoTpaUYca6qEK6ilj7kC4ctpMItQiSFcmAl4Mt7qyHGkBTCT4jOnWWKBKsBabd2vbA1ay37qyHGcIUkDrnqKCQbWU3HWcbfmPiAp1gyyYnsPvdGDVz1Q1qyHGslUjaolf2Yo10bJd4SDe2SA16bWvNeLuhfoQglqfAFaC1LlQJchvJfOcTz1Q1hwtbWbJuaXJnGGXJjdvg0zghwou00alxwOX(KqyHGciESbemEmzOYGoZ4WYHcBzFnewiO0IBcGZsHTStnDW4aoBZPn7qyHGkMKZnGGXJjJDwgQJSKSRBXLxoTz1Q1AWm1s7QOCCP07AaOma2TISwa20zGa9qDKLKDDlU8UlApNjd1Kvs1T2EZQvRHWcbvmjNBabJhtg7Smuyl7uthmoGZ0NtB288iApbDDkUrEyTr0EcAtjRo8v)sTZLx4BXI4Qf3MKzc(mWDCy5qPf3MKzYarYTRbZulTRMP2J542xVwdaLbWUvE8j1ydejN6ilj7kC40UgakdGDRSKgwHuhzjzxHdN2haxzbaDipsDKLKDfoCHPhtXjve2pbgTfCZPDiSqqLTwUw8e0gyyYnsPnGGb7QaTAaS7DiSqqbrxLUOgiso1ay37qyHGcMueTNAdmm5gP0QbWU3pbgTfCZPDiSqqLTwUw8e0gyyYnsPnGGb7QaTAaS7DiSqqbrxLUOgiso1ay37qyHGcMueTNAdmm5gP0QbWU3SA1AiSqqPf3eaNLcBzNA6GXbC2ocBwTA9a4QtIsQJchvJfOcTpaU6Yf1rHJQXcuH2pbgTfCZPDiSqqLTwUw8e0gyyYnsPnGGb7QaTAaS7DiSqqbrxLUOgiso1ay37qyHGcMueTNAdmm5gP0QbWU3S55r0Ec66uCJ8WAJO9e0MswD4R(LANlVW3IfXvlUnjZe8zG7KJdlhkT42KmtgisUDiSqqPf3eaNLcB55HZWzEeNNDXMK5SH9ir7jOFujR(JSZs5rq0JoPFugG)rwsdRqr6XNuJFKC0Ja9J0d4F0jWOhL1hbrfG9J4ncW)i4k6I(iPhpkBTCT4jOFKC0Jga7(rspEeCnmPiAp1pcgMCJu6hbHfcpkRpQb(JeTNZK6rCE3JYa8pYMMUh9OSFKfa0rZ(rbWz9iPhpQI1H8OhL1hDu4OASavi4FeN39Om8iB6rXYm9ipMEeNN4XpQqWOEihhpIMgy5YcnG)rEm9ObbHfcpQKDuA8ih8O0FuwFud8hHTO48UhLHhztt3JEuuoUu6hj94rtpwlaB6EeeOhpsdaLbWUFuwFe2YJKE8iQjRKQpso6rquby)OTH)rG7rz4r2009OhXxcl2FuqOhj94rCoGEgeLEKE8OS(iSf1ZJO9e01P4g5H1gr7jOnLS6Wx9l1oxEHVflIlWUytYmbFg4ooSCOa2fBsMjdej3(61AaOma2TYJpPgBGi5uhzjzxHdN21aqzaSBLL0WkK6ilj7kC40(jWOT4nc7qyHGkBTCT4jOvdGDVdHfcki6Q0f1arYPga7EhcleuWKIO9uBGHj3iLwna29MvRwdHfcklaOJMTjaolf2Y(a4QkwhYJuhfoQglqfAZQvRHWcbLfa0rZ2eaNLcBzhcleuXKCUbemEmzSZYqHTSz1Q1hwtbWbJuaXJnGGXJjdvg0zghwou00alxwOX(KqyHGciESbemEmzOYGoZ4WYHcBzZQvR1GzQL2vDcl2nbH21aqzaSBLg0ZGOKXJjtDjV0RQJSKSRBXL3nRwTwdMPwAxfLJlLExdaLbWUvK1cWModeOhQJSKSRBXL3Dr75mzOMSsQU12B288iApbDDkUrEyTr0EcAtjRo8v)sTZLx4BXI4cSl2KmtWNbUtooSCOa2fBsMjdej3oewiOSaGoA2Ma4SuylppI2tqxNIBKhwBeTNG2uYQdFlwexGDXMKzc(QFP25Yl8zG74WYHcyxSjzMmqKC7qyHGYca6OzBcGZsHT88WzE00m8iB6rXYm9ioxCOLtEuHGr9qooEennWYLfA8iPhpcsksRPhjHq2PZXJK6JKh5sHA)r20JQ2PRJFu2o4rwaqhn7hfaN1JSJPMMP7rEm9OchA5KhbHfcpkRps8hbUhbrfG9J2(rvs)8iApbDDkUrEyTr0EcAtjRo8TyrClCOLtaWNbURxFynfahmsv4qlNunHcrE2WmWkP1sLu00alxwOXM91UuO2vqsrAnzKqi705qrTavOXM91qyHGQWHwoPAcfI8SHzGvsRLkPWw2SVgcleufo0YjvtOqKNnmdSsATuj1rws21T4U9MnppCMhnndpYMEuSmtpIZfhA5KhviyupKJJhrtdSCzHgps6XJc0jLhjHq2PZXJK6JKh5sHA)r20JQ2PRJFu2o4rb6KYJcGZ6r2XutZ09ipMEuHdTCYJGWcHhL1hj(Ja3JGOcW(rB)OkPFEeTNGUof3ipS2iApbTPKvh(wSiUfo0YjA4Za31RpSMcGdgPkCOLtQMqHipBygyL0APskAAGLll0yZ(Axku7QaDsXiHq2PZHIAbQqJn7RHWcbvHdTCs1eke5zdZaRKwlvsHTSzFnewiOkCOLtQMqHipBygyL0APsQJSKSRBXD7nBEE4mpAAgEKnnDp6rYJ6ewShe6rspEKn9ObONU(JSL2FKdEKwCBsMPib2fBsMj4FK0JhztpkwMPhbjfP1uKb6KYJKqi7054rUuO2Pb8pAArm10mDpsd6zqu6r6XJY6JWwEKn9OQD664hLTdEKeczNohpkaoRh5GhPLQ)O0H)rX0rpYca6Oz)Oa4SuppI2tqxNIBKhwBeTNG2uYQdFlwexGg0ZGOe8zGBLCpByvvnodUjaoJg0ZGO0(61UuO2vqsrAnzKqi705qrTavOXM91tooSCO0IBtYmzGi52SVEYXHLdfWUytYmzGi52SVwdMPwAx1jSy3eeAxdaLbWUvAqpdIsgpMm1L8sVQoYsYUUfxE3S55HZ8OPz4r2009OhjpQtyXEqOhj94r20JgGE66pYwA)ro4rAXTjzMIeyxSjzMG)rspEKn9OyzMEeKuKwtrgOtkpscHStNJh5sHANgW)OPfXutZ09inONbrPhPhpkRpcB5r20JQ2PRJFu2o4rsiKD6C8Oa4SEKdEKwQ(Jsh(hfth9iT4bWz9Oa4SuppI2tqxNIBKhwBeTNG2uYQdFlwexTg0ZGOe8zGBLCpByvvnodUjaoJg0ZGO0(61UuO2vb6KIrcHStNdf1cuHgB2xp54WYHslUnjZKbIKBZ(6jhhwoua7InjZKbIKBZ(AnyMAPDvNWIDtqODnauga7wPb9mikz8yYuxYl9Q6ilj76wC5DZMNhr7jORtXnsTukgr7jOnLS6W3IfX1k9eM4jOFEeTNGUof3ipS2iApbTPKvh(wSiUqKCppppI2tqxvqKCCHi5mbWzbFg4ojewiOGi5mbWzPWwEEeTNGUQGi5MIBKXKCUbemEmzSZYa(mW1Lc1UkMKZnGGXJjJDwgkQfOcn2x7sHAxbjfP1KrcHStNdf1cuHgB21GzQL2vZu7XCCppI2tqxvqKCtXnslaOd5rWNbURxdHfckysr0EQnWWKBKsRWw2SlApNjd1Kvs1T2EZQvRxdHfckysr0EQnWWKBKsRWw2Sp5a4klaOd5rkp1rZg2UO9CMmutwjvHdV7UCWix5PfzCGzKeC4D7nppI2tqxvqKCtXnslaOd5rWNbURhaxzbaDipsDKLKDDlUrCFnewiOGjfr7P2adtUrkTcBzZUO9CMmutwjvHte2D5GrUYtlY4aZij4W72BEEeTNGUQGi5MIBKwaqhYJGpdCxFu4OASavODr75mzOMSsQU127UCWix5PfzCGzKeC4D7nRwTEYbWvwaqhYJuEQJMnSDr75mzOMSsQchE3D5GrUYtlY4aZij4W72BEEeTNGUQGi5MIBKNmtnaRAch1WvC88iApbDvbrYnf3iXQKjDYc(wSiUC(ahRHr5DMbv9S5OA0sPaFg4QbZulTRMP2J54EEeTNGUQGi5MIBKyvYKozbFTaCU(LDuY5f(mWDsiSqqTCa7IcBzxdMPwAxntThZX98iApbDvbrYnf3iXQKjDYc(Ab4C9l7OKVn8zG7KqyHGA5a2ff2YUgmtT0UAMApMJ75r0Ec6QcIKBkUrUa8e0WNbUAWm1s7QzQ9yoUDiSqqLTwUw8e0QJSKSRWH72W9oewiOYwlxlEcA1rws21T4UDeEEeTNGUQGi5MIBKAqpdIsgpMm1L8sVcFg4o54WYHslUnjZKbIKBFYXHLdfWUytYmzGi5EEeTNGUQGi5MIBKq0vPlQbIKd(mWDnewiOozMAaw1eoQHR4qHTSA1KAWm1s7QzQ9yoUnppI2tqxvqKCtXnYS1Y1INGg(mWDnewiOozMAaw1eoQHR4qHTSA1KAWm1s7QzQ9yoUnppI2tqxvqKCtXnsi6Q0fnByWNbURHWcbfeDv6IAGi5uylRwbHfcQS1Y1ING2adtUrkTbemyxfOvylBEEeTNGUQGi5MIBKYqw8CMmvB5SGpdCxp5a4kzilEotMQTCwMHyjWiLN6OzdBFsr7jOvYqw8CMmvB5SmdXsGrQSnHscl23xp5a4kzilEotMQTCwMyskkp1rZg2QvdGRKHS45mzQ2YzzIjPOoYsYUcNiUz1QbWvYqw8CMmvB5SmdXsGrQQl6OBfX9bWvYqw8CMmvB5SmdXsGrQJSKSRBfH9bWvYqw8CMmvB5SmdXsGrkp1rZg2MNhr7jORkisUP4gPhFsn2arYbVlhmYnzG7rHJQXcuHwTAaCLhFsn2arYPQUOJUvexTA9a4kp(KASbIKtvDrhDl4E)WAkaoyKQGfcs2bSknmKf0jAsrtdSCzHgBwTs0EotgQjRKQWHlC)8iApbDvbrYnf3iTKgwHGpdCpbgPgui1PdhE50ELCpByvLL0WkKXcC0ZJO9e0vfej3uCJmuOAS(KGdFg4wbyfOShQfSQJvidDylEcAf1cuHg7RxRbGYay3kp(KASbIKtDKLKDfoCAxdaLbWUvwsdRqQJSKSRWHtB2xpaUYca6qEK6ilj7kC4gXn7RHWcbv2A5AXtqBGHj3iL2acgSRc0QbWU3HWcbfeDv6IAGi5udGDVdHfckysr0EQnWWKBKsRga7EZMvRQaScu2d1mOiEwitfuMP2vulqfAaF2oDh2IBsllAKItC5f(SD6oSf3aRaGKcxEHpBNUdBXnzGBfGvGYEOMbfXZczQGYm1((Anauga7w5XNuJnqKCQJSKSRWHt7AaOma2TYsAyfsDKLKDfoCAZZJO9e0vfej3uCJSANle8zGlewiOYwlxlEcAdmm5gP0gqWGDvGwna29oewiOGORsxudejNAaS7Dr75mzOMSsQchUW9ZJO9e0vfej3uCJ0sWkWNbUqyHGkBTCT4jOvyl7I2ZzYqnzLuDRiUVgcleuoa4XgPhgDrSvvx0rHd3T3SA1AiSqq5aGhBKEy0fXwHTSdHfckha8yJ0dJUi2QJSKSRBXRkcBwTAnewiOQYSaJmAGfK4s7QQl6OWHBe3SAfewiOGORsxudejNcBzx0EotgQjRKQBfXNhr7jORkisUP4gPLGvGpdCxdHfcQQmlWiJgybjU0UQ6IokC4Y7M91qyHGYbap2i9WOlITcBzZoewiOYwlxlEcAf2YUO9CMmutwjv5U9ZJO9e0vfej3uCJ0sAyfc(mWfcleuzRLRfpbTcBzx0EotgQjRKQBXnIppI2tqxvqKCtXnslbRaFg4UE9AiSqq5aGhBKEy0fXwvDrhfoC3EZQvRHWcbLdaESr6HrxeBf2YoewiOCaWJnspm6IyRoYsYUUfVQiSz1Q1qyHGQkZcmYObwqIlTRQUOJchUrCZMDr75mzOMSsQUve388iApbDvbrYnf3i94tQXgiso4Zaxr75mzOMSsQchEFEeTNGUQGi5MIBKwsdRqWNbURxFcmARPpN2SlApNjd1Kvs1TI4MvRwV(ey0wtNiSzx0EotgQjRKQBfXDxku7QkaRyabJhtMa4OQROwGk0yZZJO9e0vfej3uCJCbRmtxcxrWR5qxiJlhmYRC5f(mWDaCLhFsn2arYPQUOJcNTFEeTNGUQGi5MIBKE8j1ydej3ZJO9e0vfej3uCJ0sWkWNbUI2ZzYqnzLuDRi(8iApbDvbrYnf3iR25czGi5EEeTNGUQGi5MIBK5b6a2bFg4EcmsnOqQtFl4Mt7qyHGkpqhWo1rws21T4KkcppppI2tqxvwPNWepbn38aDa7GpdCZwdSYgMziwcmYeHkCYd0bSZmelbgz84JQXGYyhcleu5b6a2PoYsYUUveNwJLQtppI2tqxvwPNWepb9uCJ8OMSLc8zGRlD0SHThtsXJvlAFloBeEEeTNGUQSspHjEc6P4gz4OgUkPH5iyutN4jOHpdCDPJMnS9yskESAr7BXzJWZJO9e0vLv6jmXtqpf3ijRfGnDgiqpGpdCxp54WYHslUnjZKbIKBFYXHLdfWUytYmzGi52SALO9CMmutwjvHd3TFEeTNGUQSspHjEc6P4gjKCrRrZg(mW1LoA2W2JjP4XQfTV10oc7zRbwzdZmelbgzIqfoCsX70AmjfpwzjWLNhr7jORkR0tyINGEkUrwXU5CwkMSRE2AVcFg4cHfcQk2nNZsXKD1Zw7v1ay37qyHGcsUO1OzRga7EpMKIhRw0(wCwoTNTgyLnmZqSeyKjcv4Wj12ryAnMKIhRSe4YZZZJO9e0vLgakdGDx5Ua8e0ppI2tqxvAaOma2DDkUrcvaGHjGDC88iApbDvPbGYay31P4gjeDv6IMnSNhr7jORknauga7Uof3iLtlnzCWDu7ppI2tqxvAaOma2DDkUrwsyXE1W5JnGzrT)8iApbDvPbGYay31P4gzipcQaaJNhr7jORknauga7Uof3iLwtv)KIrlLYZJO9e0vLgakdGDxNIBKqxw9s2WmbSd(mWfcleuqKCMa4SuylppI2tqxvAaOma2DDkUrMTwUw8e0WNbURhaxzbaDips5PoA2WwTs0EotgQjRKQWH3n7dGR84tQXgisoLN6Ozd75r0Ec6QsdaLbWURtXnsi6Q0f95r0Ec6QsdaLbWURtXnsSkzsNSGNcbs7MwSiUAo0fGFGo1gOIu9Nhr7jORknauga7Uof3iXQKjDYQ(888iApbDvPf3MKzI7YbSlppI2tqxvAXTjzMMIBKAXnbWzbFg4ojewiO0IBcGZsHT88iApbDvPf3MKzAkUrEsuc(mWfcleulhWUOWwEEeTNGUQ0IBtYmnf3iJj5Cdiy8yYyNLb8zGRlfQDvmjNBabJhtg7SmuulqfASpjewiOIj5Cdiy8yYyNLHcB55r0Ec6QslUnjZ0uCJKSwa20zGa9a(mWDCy5qPf3MKzYarY98iApbDvPf3MKzAkUrEsuc(mWDaC1jrj1rHJQXcuH21aliGzbKTx3cUFEeTNGUQ0IBtYmnf3iVCb(mWDaC1LlQJchvJfOcTRbwqaZciBVchUW9ZJO9e0vLwCBsMPP4gPg0ZGOKXJjtDjV0RWNbUJdlhkT42KmtgisUNhr7jORkT42KmttXnYaDaDcWQgO0j4Te4IHA6GXbxEHpdC1aliGzbKTxHdx4(5r0Ec6QslUnjZ0uCJugYINZKPAlNf8zG76jhaxjdzXZzYuTLZYmelbgP8uhnBy7tkApbTsgYINZKPAlNLziwcmsLTjusyX((6jhaxjdzXZzYuTLZYetsr5PoA2WwTAaCLmKfpNjt1woltmjf1rws2v4eXnRwnaUsgYINZKPAlNLziwcmsvDrhDRiUpaUsgYINZKPAlNLziwcmsDKLKDDRiSpaUsgYINZKPAlNLziwcms5PoA2W288iApbDvPf3MKzAkUrgkunwFsWHpdCRaScu2d1cw1XkKHoSfpbTIAbQqJDQPdghBfXiSAvfGvGYEOMbfXZczQGYm1UIAbQqd4Z2P7WwCtAzrJuCIlVWNTt3HT4gyfaKu4Yl8z70DylUjdCRaScu2d1mOiEwitfuMP23PMoyCSveJWZJO9e0vLwCBsMPP4gzn(Ob8zGRgybbmlGS9QsJDh1(wr4555r0Ec6QsRb9mikXvlUjaoRNhr7jORkTg0ZGO0uCJmMKZnGGXJjJDwgWNbUUuO2vXKCUbemEmzSZYqrTavOX(KqyHGkMKZnGGXJjJDwgkSLNhr7jORkTg0ZGO0uCJud6zquY4XKPUKx6v4Za3kaRaL9qfYR6MQFzusrTavOXoewiOc5vDt1VmkPWwEEeTNGUQ0AqpdIstXnsnONbrjJhtM6sEPxHpdCDPqTRIj5Cdiy8yYyNLHIAbQqJDiSqqftY5gqW4XKXoldf2YZJO9e0vLwd6zquAkUrQb9mikz8yYuxYl9k8zGRlfQDvmjNBabJhtg7SmuulqfASRbGYay3Qyso3acgpMm2zzOoYsYUchEJWZJO9e0vLwd6zquAkUrQb9mikz8yYuxYl9k8zG7KUuO2vXKCUbemEmzSZYqrTavOXZZZJO9e0vvHdTCIMRwCtaCwppppI2tqxvfo0YjaUwaqhnBtaCwppppI2tqxvanONbrjUwaqhnBtaCwppI2tqxvanONbrPP4gzmjNBabJhtg7SmGpdCDPqTRIj5Cdiy8yYyNLHIAbQqJ9jHWcbvmjNBabJhtg7SmuylppI2tqxvanONbrPP4gPg0ZGOKXJjtDjV0RWNbUvawbk7HkKx1nv)YOKIAbQqJDiSqqfYR6MQFzusHT88iApbDvb0GEgeLMIBKvxUqEe8zGlPl5sLusZHPj4IVAfPl5sLuvqrottWf)5r0Ec6QcOb9miknf3iTpXJHpdCjDjxQKsAomnbx8vRiDjxQKQG1YzAcU4ppI2tqxvanONbrPP4gPg0ZGOKXJjtDjV0RWNbUUuO2vXKCUbemEmzSZYqrTavOXoewiOIj5Cdiy8yYyNLHcB55r0Ec6QcOb9miknf3i1GEgeLmEmzQl5LEf(mW1Lc1UkMKZnGGXJjJDwgkQfOcn21aqzaSBvmjNBabJhtg7SmuhzjzxHdVr45r0Ec6QcOb9miknf3i1GEgeLmEmzQl5LEf(mWDsxku7Qyso3acgpMm2zzOOwGk04555r0Ec6QcyxSjzM4AbaD0SnbWzbFg4ojewiOSaGoA2Ma4SuylppI2tqxva7InjZ0uCJmMKZnGGXJjJDwgWNbUUuO2vXKCUbemEmzSZYqrTavOX(KqyHGkMKZnGGXJjJDwgkSLNhr7jORkGDXMKzAkUrwD5Qyhm65r0Ec6QcyxSjzMMIBKAqpdIsgpMm1L8sVcFg4wbyfOShQqEv3u9lJskQfOcnEEeTNGUQa2fBsMPP4gjzTaSPZab6b8zG74WYHcyxSjzMmqKCppI2tqxva7InjZ0uCJugYINZKPAlNf8zG76jhaxjdzXZzYuTLZYmelbgP8uhnBy7tkApbTsgYINZKPAlNLziwcmsLTjusyX((6jhaxjdzXZzYuTLZYetsr5PoA2WwTAaCLmKfpNjt1woltmjf1rws2v4eXnRwnaUsgYINZKPAlNLziwcmsvDrhDRiUpaUsgYINZKPAlNLziwcmsDKLKDDRiSpaUsgYINZKPAlNLziwcms5PoA2W288iApbDvbSl2KmttXnYkwhYJGxZHUqgxoyKx5Yl8zG7rHJQXcuHEEeTNGUQa2fBsMPP4gPfa0H8i41COlKXLdg5vU8cFg4Eu4OASavOvRGWcbfmPiAp1gyyYnsPvylppI2tqxva7InjZ0uCJS6YfYJGpdC1GzQL2vDcl2nbH2jDjxQKsAomnbx8Nhr7jORkGDXMKzAkUrAFIhdFg4oPgmtT0UQtyXUji0oPl5sLusZHPj4I)8iApbDvbSl2KmttXnsnONbrjJhtM6sEPxHpdCxdHfcksxYLkzkyTCkSLvRGWcbfPl5sLmvqrof2YMNhr7jORkGDXMKzAkUrwD5c5rWNbURjDjxQKkBtbRLB1ksxYLkPQGICMMGl(MvRwt6sUujv2Mcwl3oewiOQUCvSdgziRfGnDwu7McwlNcBzZZJO9e0vfWUytYmnf3iTpXJz41fsZ4Jxob3mN5mga]] )


end