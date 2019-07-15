-- DruidFeral.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


local FindUnitBuffByID = ns.FindUnitBuffByID


if UnitClassBase( 'player' ) == 'DRUID' then
    local spec = Hekili:NewSpecialization( 103 )

    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.ComboPoints )

    spec:RegisterResource( Enum.PowerType.Rage )
    spec:RegisterResource( Enum.PowerType.LunarPower )
    spec:RegisterResource( Enum.PowerType.Mana )


    -- Talents
    spec:RegisterTalents( {
        predator = 22363, -- 202021
        sabertooth = 22364, -- 202031
        lunar_inspiration = 22365, -- 155580

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        balance_affinity = 22163, -- 197488
        guardian_affinity = 22158, -- 217615
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        typhoon = 18577, -- 132469

        soul_of_the_forest = 21708, -- 158476
        savage_roar = 18579, -- 52610
        incarnation = 21704, -- 102543

        scent_of_blood = 21714, -- 285564
        brutal_slash = 21711, -- 202028
        primal_wrath = 22370, -- 285381

        moment_of_clarity = 21646, -- 236068
        bloodtalons = 21649, -- 155672
        feral_frenzy = 21653, -- 274837
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3432, -- 214027
        relentless = 3433, -- 196029
        gladiators_medallion = 3431, -- 208683

        earthen_grasp = 202, -- 236023
        enraged_maim = 604, -- 236026
        ferocious_wound = 611, -- 236020
        freedom_of_the_herd = 203, -- 213200
        fresh_wound = 612, -- 203224
        heart_of_the_wild = 3053, -- 236019
        king_of_the_jungle = 602, -- 203052
        leader_of_the_pack = 3751, -- 202626
        malornes_swiftness = 601, -- 236012
        protector_of_the_grove = 847, -- 209730
        rip_and_tear = 620, -- 203242
        savage_momentum = 820, -- 205673
        thorns = 201, -- 236696
    } )


    -- Auras
    spec:RegisterAuras( {
        aquatic_form = {
            id = 276012,
        },
        astral_influence = {
            id = 197524,
        },
        berserk = {
            id = 106951,
            duration = 20,
            max_stack = 1,
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        bloodtalons = {
            id = 145152, 
            max_stack = 2,
            duration = 30,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        clearcasting = {
            id = 135700,
            duration = 15,
            max_stack = function()
                local x = 1 -- Base Stacks
                return talent.moment_of_clarity.enabled and 2 or x
            end,
        },
        dash = {
            id = 1850,
            duration = 10,
        },
        entangling_roots = {
            id = 339,
            duration = 30,
            type = "Magic",
        },
        feline_swiftness = {
            id = 131768,
        },
        feral_frenzy = {
            id = 274837,
            duration = 6,
        },
        feral_instinct = {
            id = 16949,
        },
        flight_form = {
            id = 276029,
        },
        frenzied_regeneration = {
            id = 22842,
        },
        hibernate = {
            id = 2637,
            duration = 40,
        },
        incarnation = {
            id = 102543,
            duration = 30,
        },
        infected_wounds = {
            id = 48484,
        },
        ironfur = {
            id = 192081,
            duration = 6,
        },
        jungle_stalker = {
            id = 252071, 
            duration = 30,
        },
        lunar_empowerment = {
            id = 164547,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        maim = {
            id = 22570,
            duration = 5,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = 16,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonfire_cat = {
            id = 155625, 
            duration = 16,
            tick_time = function() return 2 * haste end,
        },
        moonkin_form = {
            id = 197625,
        },
        omen_of_clarity = {
            id = 16864,
            duration = 16,
            max_stack = function () return talent.moment_of_clarity.enabled and 2 or 1 end,
        },
        predatory_swiftness = {
            id = 69369,
            duration = 12,
            max_stack = 1,
        },
        primal_fury = {
            id = 159286,
        },
        prowl_base = {
            id = 5215,
            duration = 3600,
        },
        prowl_incarnation = {
            id = 102547,
            duration = 3600,
        },
        prowl = {
            alias = { "prowl_base", "prowl_incarnation" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600,
        },
        rake = {
            id = 155722, 
            duration = 15,
            tick_time = function() return 3 * haste end,
        },
        regrowth = { 
            id = 8936, 
            duration = 12,
        },
        rip = {
            id = 1079,
            duration = 24,
            tick_time = function() return 2 * haste end,
        },
        savage_roar = {
            id = 52610,
            duration = 36,
        },
        scent_of_blood = {
            id = 285646,
            duration = 6,
            max_stack = 1,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
        },
        solar_empowerment = {
            id = 164545,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        survival_instincts = {
            id = 61336,
            duration = 6,
            max_stack = 1,
        },
        thrash_bear = {
            id = 192090,
            duration = 15,
            max_stack = 3,
        },
        thrash_cat ={
            id = 106830, 
            duration = 15,
            tick_time = function() return 3 * haste end,
        },
        --[[ thrash = {
            id = function ()
                if buff.cat_form.up then return 106830 end
                return 192090
            end,
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        }, ]]
        thick_hide = {
            id = 16931,
        },
        tiger_dash = {
            id = 252216,
            duration = 5,
        },
        tigers_fury = {
            id = 5217,
            duration = function()
                local x = 10 -- Base Duration
                if talent.predator.enabled then return x + 5 end
                return x
            end,
        },
        travel_form = {
            id = 783,
        },
        wild_charge = {
            id = 102401,
        },
        yseras_gift = {
            id = 145108,
        },


        -- PvP Talents
        cyclone = {
            id = 209753,
            duration = 6,
            max_stack = 1,
        },

        ferocious_wound = {
            id = 236021,
            duration = 30,
            max_stack = 2,
        },

        king_of_the_jungle = {
            id = 203059,
            duration = 24,
            max_stack = 3,
        },

        leader_of_the_pack = {
            id = 202636,
            duration = 3600,
            max_stack = 1,
        },

        thorns = {
            id = 236696,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers
        iron_jaws = {
            id = 276026,
            duration = 30,
            max_stack = 1,
        },

        jungle_fury = {
            id = 274426,
            duration = function () return talent.predator.enabled and 17 or 12 end,
            max_stack = 1,
        },
    } )


    -- Snapshotting
    local tf_spells = { rake = true, rip = true, thrash_cat = true, moonfire_cat = true, primal_wrath = true }
    local bt_spells = { rake = true, rip = true, thrash_cat = true, primal_wrath = true }
    local mc_spells = { thrash_cat = true }
    local pr_spells = { rake = true }

    local snapshot_value = {
        tigers_fury = 1.15,
        bloodtalons = 1.25,
        clearcasting = 1.15, -- TODO: Only if talented MoC, not used by 8.1 script
        prowling = 2
    }


    --[[ local modifiers = {
        [1822]   = 155722,
        [1079]   = 1079,
        [106830] = 106830,
        [8921]   = 155625
    } ]] -- ??


    local stealth_dropped = 0

    local function calculate_multiplier( spellID )

        local tigers_fury = FindUnitBuffByID( "player", class.auras.tigers_fury.id, "PLAYER" ) and snapshot_value.tigers_fury or 1
        local bloodtalons = FindUnitBuffByID( "player", class.auras.bloodtalons.id, "PLAYER" ) and snapshot_value.bloodtalons or 1
        local clearcasting = FindUnitBuffByID( "player", class.auras.clearcasting.id, "PLAYER" ) and state.talent.moment_of_clarity.enabled and snapshot_value.clearcasting or 1
        local prowling = ( GetTime() - stealth_dropped < 0.2 or FindUnitBuffByID( "player", class.auras.incarnation.id, "PLAYER" ) ) and snapshot_value.prowling or 1     

        if spellID == 155722 then
            return 1 * bloodtalons * tigers_fury * prowling

        elseif spellID == 1079 or spellID == 285381 then
            return 1 * bloodtalons * tigers_fury

        elseif spellID == 106830 then
            return 1 * bloodtalons * tigers_fury * clearcasting

        elseif spellID == 155625 then
            return 1 * tigers_fury

        end

        return 1
    end

    spec:RegisterStateExpr( 'persistent_multiplier', function ()
        local mult = 1

        if not this_action then return mult end

        if tf_spells[ this_action ] and buff.tigers_fury.up then mult = mult * snapshot_value.tigers_fury end
        if bt_spells[ this_action ] and buff.bloodtalons.up then mult = mult * snapshot_value.bloodtalons end
        if mc_spells[ this_action ] and buff.clearcasting.up then mult = mult * snapshot_value.clearcasting end
        if pr_spells[ this_action ] and ( buff.incarnation.up or buff.prowl.up or buff.shadowmeld.up or state.query_time - stealth_dropped < 0.2 ) then mult = mult * snapshot_value.prowling end

        return mult
    end )


    local snapshots = {
        [155722] = true,
        [1079]   = true,
        [106830] = true,
        [155625] = true
    }


    -- Tweaking for new Feral APL.
    local rip_applied = false

    spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
        rip_applied = false
    end )    

    spec:RegisterStateExpr( "opener_done", function ()
        return rip_applied
    end )


    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID then
            if subtype == "SPELL_AURA_REMOVED" then
                -- Track Prowl and Shadowmeld dropping, give a 0.2s window for the Rake snapshot.
                if spellID == 58984 or spellID == 5215 or spellID == 1102547 then
                    stealth_dropped = GetTime()
                end
            elseif snapshots[ spellID ] and ( subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' ) then
                ns.saveDebuffModifier( spellID, calculate_multiplier( spellID ) )
                ns.trackDebuff( spellID, destGUID, GetTime(), true )
            elseif subtype == "SPELL_CAST_SUCCESS" and ( spellID == class.abilities.rip.id or spellID == class.abilities.primal_wrath.id or spellID == class.abilities.ferocious_bite.id or spellID == class.abilities.maim.id or spellID == class.abilities.savage_roar.id ) then
                rip_applied = true
            end
        end
    end )  


    spec:RegisterStateFunction( "break_stealth", function ()
        removeBuff( "shadowmeld" )
        if buff.prowl.up then
            setCooldown( "prowl", 6 )
            removeBuff( "prowl" )
        end
    end )


    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
    end )


    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        applyBuff( form )
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if not a or a.startsCombat then
            break_stealth()
        end 
    end )

    spec:RegisterHook( "reset_precast", function ()
        if buff.cat_form.down then
            energy.regen = 10 + ( stat.haste * 10 )
        end
        debuff.rip.pmultiplier = nil
        debuff.rake.pmultiplier = nil
        debuff.thrash.pmultiplier = nil

        opener_done = nil
    end )

    spec:RegisterHook( "gain", function( amt, resource )
        if azerite.untamed_ferocity.enabled and amt > 0 and resource == "combo_points" then
            if talent.incarnation.enabled then gainChargeTime( "incarnation", 0.2 )
            else gainChargeTime( "berserk", 0.3 ) end
        end
    end )


    local function comboSpender( a, r )
        if r == "combo_points" and a > 0 and talent.soul_of_the_forest.enabled then
            gain( a * 5, "energy" )
        end
    end

    spec:RegisterHook( "spend", comboSpender )
    -- spec:RegisterHook( "spendResources", comboSpender )


    -- Legendaries.  Ugh.
    spec:RegisterGear( 'ailuro_pouncers', 137024 )
    spec:RegisterGear( 'behemoth_headdress', 151801 )
    spec:RegisterGear( 'chatoyant_signet', 137040 )        
    spec:RegisterGear( 'ekowraith_creator_of_worlds', 137015 )
    spec:RegisterGear( 'fiery_red_maimers', 144354 )
    spec:RegisterGear( 'luffa_wrappings', 137056 )
    spec:RegisterGear( 'soul_of_the_archdruid', 151636 )
    spec:RegisterGear( 'the_wildshapers_clutch', 137094 )

    -- Legion Sets (for now).
    spec:RegisterGear( 'tier21', 152127, 152129, 152125, 152124, 152126, 152128 )
        spec:RegisterAura( 'apex_predator', {
            id = 252752,
            duration = 25
         } ) -- T21 Feral 4pc Bonus.

    spec:RegisterGear( 'tier20', 147136, 147138, 147134, 147133, 147135, 147137 )
    spec:RegisterGear( 'tier19', 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( 'class', 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )


    -- Abilities
    spec:RegisterAbilities( {
        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -25,
            spendType = "rage",

            startsCombat = false,
            texture = 132276,

            noform = "bear_form",
            handler = function () shift( "bear_form" ) end,
        },


        berserk = {
            id = 106951,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "spell",

            startsCombat = false,
            texture = 236149,

            notalent = "incarnation",

            toggle = "cooldowns",

            handler = function ()
                if buff.cat_form.down then shift( "cat_form" ) end
                applyBuff( "berserk" )
                energy.max = energy.max + 50
            end,
        },


        brutal_slash = {
            id = 202028,
            cast = 0,
            charges = 3,

            cooldown = 8,
            recharge = 8,
            hasteCD = true,

            gcd = "spell",

            spend = function ()
                if buff.clearcasting.up then return 0 end

                local x = 25
                if buff.scent_of_blood.up then x = x + buff.scent_of_blood.v1 end
                return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132141,

            form = "cat_form",

            readyTime = function ()
                if settings.brutal_charges > 0 and active_enemies < 2 then return ( 1 + settings.brutal_charges - charges_fractional ) * recharge end
                return 0
            end,

            handler = function ()
                gain( 1, "combo_points" )
                removeStack( "bloodtalons" )
            end,
        },


        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132115,

            essential = true,

            noform = "cat_form",
            handler = function ()
                shift( "cat_form" ) 
            end,
        },


        cyclone = {
            id = 209753,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "cyclone",

            spend = 0.15,
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

            notalent = "tiger_dash",

            handler = function ()
                shift( "cat_form" )
                applyBuff( "dash" )
            end,
        },


        enraged_maul = {
            id = 236716,
            cast = 0,
            cooldown = 3,
            gcd = "spell",

            pvptalent = "heart_of_the_wild",
            form = "bear_form",

            spend = 40,
            spendType = "rage",

            startsCombat = true,
            texture = 132136,

            handler = function ()                
            end,
        },


        entangling_roots = {
            id = 339,
            cast = function ()
                if buff.predatory_swiftness.up then return 0 end
                return 1.7 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 136100,

            handler = function ()
                applyDebuff( "target", "entangling_roots" )
                removeBuff( "predatory_swiftness" )
                if talent.bloodtalons.enabled then applyBuff( "bloodtalons", 30, 2 ) end
            end,
        },


        feral_frenzy = {
            id = 274837,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = true,
            texture = 132140,

            handler = function ()
                gain( 5, "combo_points" )
                applyDebuff( "target", "feral_frenzy" )
                removeStack( "bloodtalons" )
            end,

            copy = "ashamanes_frenzy"
        },


        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.apex_predator.up then return 0 end
                -- going to require 50 energy and then refund it back...
                return 50 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132127,

            form = "cat_form",
            indicator = function ()
                if talent.sabertooth.enabled and dot.rip.down and active_dot.rip > 0 then return "cycle" end
            end,

            usable = function () return buff.apex_predator.up or combo_points.current > 0 end,
            handler = function ()
                if talent.sabertooth.enabled and debuff.rip.up then
                    debuff.rip.expires = debuff.rip.expires + ( 4 * combo_points.current )
                end

                if pvptalent.ferocious_wound.enabled and combo_points.current >= 5 then
                    applyDebuff( "target", "ferocious_wound", nil, min( 2, debuff.ferocious_wound.stack + 1 ) )
                end

                if buff.apex_predator.up then
                    applyBuff( "predatory_swiftness" )
                    removeBuff( "apex_predator" )
                else
                    gain( 25, "energy" )
                    if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end
                    spend( min( 5, combo_points.current ), "combo_points" )
                end

                opener_done = true

                removeStack( "bloodtalons" )
            end,
        },


        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = 1,
            cooldown = 36,
            recharge = 36,
            hasteCD = true,
            gcd = "spell",

            spend = 10,
            spendType = "rage",

            startsCombat = false,
            texture = 132091,

            talent = "guardian_affinity",
            form = "bear_form",

            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( health.max * 0.05, "health" )
            end,
        },


        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            startsCombat = true,
            texture = 132270,

            form = "bear_form",
            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },


        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            startsCombat = false,
            texture = 136090,

            handler = function ()
                applyDebuff( "target", "hibernate" )
            end,
        },


        incarnation = {
            id = 102543,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "spell",

            startsCombat = false,
            texture = 571586,

            toggle = "cooldowns",

            handler = function ()
                if buff.cat_form.down then shift( "cat_form" ) end
                applyBuff( "incarnation" )
                applyBuff( "jungle_stalker" )
                energy.max = energy.max + 50 
            end,

            copy = { "incarnation_king_of_the_jungle", "Incarnation" }
        },


        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            spend = 45,
            spendType = "rage",

            startsCombat = false,
            texture = 1378702,

            form = "bear_form",
            talent = "guardian_affinity",

            handler = function ()
                applyBuff( "ironfur", 6 + buff.ironfur.remains )
            end,
        },


        lunar_strike = {
            id = 197628,
            cast = function() return 2.5 * haste * ( buff.lunar_empowerment.up and 0.85 or 1 ) end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135753,

            form = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                removeStack( "lunar_empowerment" )
            end,
        },


        maim = {
            id = 22570,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 35 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132134,

            form = "cat_form",
            usable = function () return combo_points.current > 0 end,

            handler = function ()
                applyDebuff( "target", "maim", combo_points.current )
                if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end
                spend( combo_points.current, "combo_points" )
                removeStack( "bloodtalons" )
                removeBuff( "iron_jaws" )

                opener_done = true
            end,
        },


        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = -10,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            form = "bear_form",

            handler = function ()
                removeStack( "bloodtalons" )
            end,
        },


        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 538515,

            talent = "mass_entanglement",

            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
                active_dot.mass_entanglement = max( active_dot.mass_entanglement, true_active_enemies )
            end,
        },


        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = 50,
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

            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",

            form = "moonkin_form",

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                applyDebuff( "target", "moonfire" )
            end,
        },


        moonfire_cat = {            
            id = 155625,
            known = 8921,
            suffix = "(Cat)",
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 30 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 136096,

            talent = "lunar_inspiration",
            form = "cat_form",

            cycle = "moonfire_cat",
            aura = "moonfire_cat",

            handler = function ()
                applyDebuff( "target", "moonfire_cat" )
                debuff.moonfire_cat.pmultiplier = persistent_multiplier
                gain( 1, "combo_points" )
            end,

            copy = { 8921, 155625, "moonfire_cat" }
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


        primal_wrath = {
            id = 285381,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            talent = "primal_wrath",

            spend = 20,
            spendType = "energy",

            startsCombat = true,
            texture = 1392547,

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                applyDebuff( "target", "rip", 4 * combo_points.current )
                active_dot.rip = active_enemies

                opener_done = true

                spend( combo_points.current, "combo_points" )
            end,
        },


        prowl = {
            id = function () return buff.incarnation.up and 102547 or 5215 end,
            cast = 0,
            cooldown = function ()
                if buff.prowl.up then return 0 end
                return 6
            end,
            gcd = "off",

            startsCombat = false,
            texture = 514640,

            nobuff = "prowl",

            usable = function () return time == 0 or ( boss and buff.jungle_stalker.up ) end,

            handler = function ()
                shift( "cat_form" )
                applyBuff( buff.incarnation.up and "prowl_incarnation" or "prowl_base" )
            end,

            copy = { 5215, 102547 }
        },


        rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                return 35 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ), "energy"
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132122,

            cycle = "rake",
            min_ttd = 6,

            form = "cat_form",

            --[[ usable = function ()
                if settings.hold_bleed_pct > 0 then
                    local limit = settings.hold_bleed_pct * debuff.rake.duration
                    if target.time_to_die < limit then return false, "target will die in " .. target.time_to_die .. " seconds (<" .. limit .. ")" end
                end
                return true
            end, ]]

            handler = function ()
                applyDebuff( "target", "rake" )
                debuff.rake.pmultiplier = persistent_multiplier

                gain( 1, "combo_points" )
                removeStack( "bloodtalons" )
            end,
        },


        rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",

            spend = 0,
            spendType = "rage",

            startsCombat = false,
            texture = 136080,

            handler = function ()
            end,
        },


        regrowth = {
            id = 8936,
            cast = function ()
                if buff.predatory_swiftness.up then return 0 end
                return 1.5 * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = false,
            texture = 136085,

            usable = function ()
                if buff.bloodtalons.up then return false end
                -- Try without out-of-combat time == 0 check.
                if buff.prowl.up then return false, "prowling" end
                if buff.cat_form.up and buff.predatory_swiftness.down then return false, "predatory_swiftness is down" end
                return true
            end,

            handler = function ()
                if buff.predatory_swiftness.down then
                    unshift() 
                end
                removeBuff( "predatory_swiftness" )

                if talent.bloodtalons.enabled then applyBuff( "bloodtalons", 30, 2 ) end
                applyBuff( "regrowth", 12 )
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

            handler = function ()
                unshift()
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

            handler = function ()
            end,
        },


        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            startsCombat = false,
            texture = 136059,

            talent = "renewal",

            handler = function ()
                health.actual = min( health.max, health.actual + ( 0.3 * health.max ) )
            end,
        },


        revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = false,
            texture = 132132,

            handler = function ()
            end,
        },


        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 30 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132152,

            aura = "rip",
            cycle = "rip",
            min_ttd = 9.6,

            form = "cat_form",

            usable = function ()
                if combo_points.current == 0 then return false, "no combo points" end
                --[[ if settings.hold_bleed_pct > 0 then
                    local limit = settings.hold_bleed_pct * debuff.rip.duration
                    if target.time_to_die < limit then return false, "target will die in " .. target.time_to_die .. " seconds (<" .. limit .. ")" end
                end ]]
                return true
            end,            

            handler = function ()
                if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end
                spend( combo_points.current, "combo_points" )

                applyDebuff( "target", "rip", min( 1.3 * class.auras.rip.duration, debuff.rip.remains + class.auras.rip.duration ) )
                debuff.rip.pmultiplier = persistent_multiplier
                removeStack( "bloodtalons" )

                opener_done = true
            end,
        },


        rip_and_tear = {
            id = 203242,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 60,
            spendType = "energy",

            talent = "rip_and_tear",

            startsCombat = true,
            texture = 1029738,

            handler = function ()
                applyDebuff( "target", "rip" )
                applyDebuff( "target", "rake" )
            end,
        },


        savage_roar = {
            id = 52610,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 25 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 236167,

            talent = "savage_roar",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end

                local cost = min( 5, combo_points.current )
                spend( cost, "combo_points" )
                if buff.savage_roar.down then energy.regen = energy.regen * 1.1 end
                applyBuff( "savage_roar", 6 + ( 6 * cost ) )

                opener_done = true
            end,
        },


        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.clearcasting.up then return 0 end
                return 40 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) 
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 136231,

            form = "cat_form",

            handler = function ()
                gain( 1, "combo_points" )
                removeStack( "bloodtalons" )
                removeStack( "clearcasting" )
            end,
        },


        skull_bash = {
            id = 106839,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 236946,

            toggle = "interrupts",

            form = function () return buff.bear_form.up and "bear_form" or "cat_form" end,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()

                if pvptalent.savage_momentum.enabled then
                    gainChargeTime( "tigers_fury", 10 )
                    gainChargeTime( "survival_instincts", 10 )
                    gainChargeTime( "stampeding_roar", 10 )
                end
            end,
        },


        solar_wrath = {
            id = 197629,
            cast = function () return 1.5 * haste * ( buff.solar_empowerment.up and 0.85 or 1 ) end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 535045,

            form = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                removeStack( "solar_empowerment" )
            end,
        },


        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            toggle = "interrupts",

            startsCombat = false,
            texture = 132163,

            usable = function () return buff.dispellable_enrage.up end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
            end,
        },


        stampeding_roar = {
            id = 106898,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 464343,

            handler = function ()
                if buff.bear_form.down and buff.cat_form.down then
                    shift( "bear_form" )
                end
            end,
        },


        starsurge = {
            id = 197626,
            cast = 2,
            cooldown = 10,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135730,

            form = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                addStack( "solar_empowerment", nil, 1 )
                addStack( "lunar_empowerment", nil, 1 )
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

            form = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                applyDebuff( "target", "sunfire" )
                active_dot.sunfire = active_enemies
            end,
        },


        survival_instincts = {
            id = 61336,
            cast = 0,
            charges = 2,
            cooldown = 120,
            recharge = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 236169,

            handler = function ()
                applyBuff( "survival_instincts" )
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

            handler = function ()
                unshift()
            end,
        },


        swipe_cat = {
            id = 106785,
            known = 213764,
            suffix = "(Cat)",
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.clearcasting.up then return 0 end
                return max( 0, ( 35 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) ) + buff.scent_of_blood.v1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 134296,

            notalent = "brutal_slash",
            form = "cat_form",

            handler = function ()
                gain( 1, "combo_points" )
                removeStack( "bloodtalons" )
                removeStack( "clearcasting" )
            end,

            copy = { 213764, "swipe" },
        },

        teleport_moonglade = {
            id = 18960,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 4,
            spendType = "mana",

            startsCombat = false,
            texture = 135758,

            handler = function ()
            end,
        },


        thorns = {
            id = 236696,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = function ()
                if essence.conflict_and_strife.enabled then return end
                return "thorns"
            end,

            spend = 0.12,
            spendType = "mana",

            startsCombat = false,
            texture = 136104,

            handler = function ()
                applyBuff( "thorns" )
            end,
        },


        thrash_cat = {
            id = 106830,
            known = 106832,
            suffix = "(Cat)",
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.clearcasting.up then return 0 end
                return 40 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 451161,

            aura = "thrash_cat",
            cycle = "thrash_cat",

            form = "cat_form",
            recheck = function () return dot.thrash_cat.remains - dot.thrash_cat.duration * 0.3, dot.thrash_cat.remains end,
            handler = function ()
                applyDebuff( "target", "thrash_cat" )
                active_dot.thrash_cat = max( active_dot.thrash, true_active_enemies )
                debuff.thrash_cat.pmultiplier = persistent_multiplier

                if talent.scent_of_blood.enabled then
                    applyBuff( "scent_of_blood" )
                    buff.scent_of_blood.v1 = -3 * active_enemies
                end

                removeStack( "bloodtalons" )
                removeStack( "clearcasting" )
                if target.within8 then gain( 1, "combo_points" ) end
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
                shift( "cat_form" )
                applyBuff( "tiger_dash" )
            end,
        },


        tigers_fury = {
            id = 5217,
            cast = 0,
            cooldown = 30,
            gcd = "off",

            spend = -50,
            spendType = "energy",

            startsCombat = false,
            texture = 132242,

            usable = function () return buff.tigers_fury.down or energy.deficit > 50 + energy.regen end,
            handler = function ()
                shift( "cat_form" )
                applyBuff( "tigers_fury", talent.predator.enabled and 15 or 10 )
                if azerite.jungle_fury.enabled then applyBuff( "jungle_fury" ) end
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

            talent = "typhoon",

            handler = function ()
            end,
        },


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]


        wild_charge = {
            id = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = false,
            texture = 538771,

            handler = function ()
                setDistance( 5 )
                -- applyDebuff( "target", "dazed", 3 )
            end,
        },


        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",

            spend = 0.3,
            spendType = "mana",

            startsCombat = false,
            texture = 236153,

            talent = "restoration_affinity",

            handler = function ()
                unshift()
                applyBuff( "wild_growth" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageDots = false,
        damageExpiration = 3,

        potion = "battle_potion_of_agility",

        package = "Feral"
    } )

    spec:RegisterSetting( "brutal_charges", 2, {
        name = "Reserve |T132141:0|t Brutal Slash Charges",
        desc = "If set above zero, the addon will hold these Brutal Slash charges for when 3+ enemies have been detected.",
        icon = 132141,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 0,
        max = 4,
        step = 0.1,
        width = 1.5
    } )    

    spec:RegisterPack( "Feral", 20190707.2020, [[dSubfbqicIfrqf1JiiDjcveBsi9jcQ0OieNIqAvIkYRiqZccDlOqTlb)ckAyIkDmrPLrq5zqHmnOGUgLQABIkQVrqvJJqLohuaRJsvQ3rOIY8ev4EQO9rOCqkvrlKaEiuGAIeQO6IeQiTrkvjNKGkSsHyMqbIDcb)KsvGHsqfPLsPk0tvPPcr(kLQG2lO)QkdgPdt1IH0JjAYQQlJAZI8zvy0qPtR0QHcKEne1SP42c1Uv8BjdNsoobvelxQNJy6KUouTDkv(oLY4ju15ffRNqfMVOQ9dmmlej497kdrqy5MfdKRWNRWhewUctCTFw4vZyXWRLlr2py4D8ygETxC7g41YZyk)drcEjfElz4fRQwe7nMyESkwC0GSIXKSX4gx3AKTNumjBSet4ffFnQWXarH3VRmebHLBwmqUcFUcFqy5kmmY(5m8sSyjeHS5IrWl29)5bIcVFMiHxHcO2lUDdGkoVX3piIqbuSQArS3yI5XQyXrdYkgtYgJBCDRr2EsXKSXsmbrekGgb3KbqfEebuHLBwmaGIXaQWY1ElSCbrarekGIbJ1NdMyVbrekGIXaQ98)5pGErg3yaubCc2aiIqbumgqThzJlE(dOiThClCjaQ9cVZaO8W9rgavILLidOAbOULLjdGwJjdGAdlpaks7b3cxcGAVW7ma6sau30S)ZaO4wbqeHcOymGww8W97xddOlbqX6Z3WFaDhL7XnMmakAgavXYaQ))1iodqBoUSJ)aQILjmGAN3RJAysaqbu7bJjdGIwkwUb0Dau0Iqa00EGvjbqeHcOymGIbxJDCRaQ69bRVnbOYA(RU1qauTauzgPHFQ3hSscGicfqXya1EKJl7yav4IL9wFmHWJKfUa6bpCVsa1L6wtaerOakgdO2Z)hqfWn(iza1EMs7SAga1Q3QxntaET6kTggEfkGAV42naQ48gF)GicfqXQQfXEJjMhRIfhniRymjBmUX1Tgz7jftYglXeerOaAeCtgav4reqfwUzXaakgdOclx7TWYfeberOakgmwFoyI9gerOakgdO2Z)N)a6fzCJbqfWjydGicfqXya1EKnU45pGI0EWTWLaO2l8odGYd3hzaujwwImGQfG6wwMmaAnMmaQnS8aOiThClCjaQ9cVZaOlbqDtZ(pdGIBfarekGIXaAzXd3VFnmGUeafRpFd)b0DuUh3yYaOOzaufldO()xJ4maT54Yo(dOkwMWaQDEVoQHjbafqThmMmakAPy5gq3bqrlcbqt7bwLearekGIXakgCn2XTcOQ3hS(2eGkR5V6wdbq1cqLzKg(PEFWkjaIiuafJbu7roUSJbuHlw2B9Xecpsw4cOh8W9kbuxQBnbqeHcOymGAp)Fava34JKbu7zkTZQzauRERE1mbqeqeHcOItfplXv(dOOCQAgqLvmQRakkFSdjaO2tPKTucGo1GXy9ooHBauxQBneaTgtMaiIqbuxQBnKGvZYkg11ZKXjidIiua1L6wdjy1SSIrDvWtmtv9brekG6sDRHeSAwwXOUk4jMo(rmpQRBnGiUu3AibRMLvmQRcEIzZhDztXI4MorXtPqCvdY78svhh(LTjQ6gE0aQPQV6MAibECud)brekGkCOa6sauBvRyb0vb0u1aQBIlIcOSDCNPggq1cqJ9DuFhavX2obliIl1TgsWQzzfJ6QGNyAN3RJAyehpMpXj8tX2oblI25gC(mxqexQBnKGvZYkg1vbpX0oVxh1WioEmFIt4NITDcweTZn48PWqCtNU4G7v5GT18FjdtW28835iWJJA4piIl1TgsWQzzfJ6QGNyA1LndIB6efpLcXvniVZlvDC4x2gqexQBnKGvZYkg1vbpXu66lvDmIB6efpLcXvniVZlvDC4x2gqeHcO3XTiylfqBF)akkEkXFaLOUsauuovndOYkg1vafLp2HaO(8buRMXyRs1Doa0LaO)A4aiIqbuxQBnKGvZYkg1vbpXKmUfbBPpI6kbeXL6wdjy1SSIrDvWtmTkDRbeXL6wdjy1SSIrDvWtmr5MWnYiUPtu8ukex1G8oVu1XHFzBarCPU1qcwnlRyuxf8etDp4M8s4Dge30jkEkfIRAqENxQ64WVSnGiGicfqfNkEwIR8hqz74odGQBmdOkwgqDPwnGUea1TZxJJA4aiIl1TgYjbzCJ5H6eSiUPtHGINsbRUSzc4wrfckEkfiy9FzlMn)aUfiIl1TgIGNy24ZZL6wZZSefXXJ5tu34JKrCtNQB4rdOUXhj)8uANvZe4Xrn8pkkEkfIRAqENxQ64aUfiIl1TgIGNy24ZZL6wZZSefXXJ5ZYIhUrCtNcPS4H73VgoQiO4PuaLBc3ihWTYNhfpLc7i9ECDRjGBjkiIl1TgIGNykD9LQogXnDkeu8ukiD9LQooGBbI4sDRHi4jMTJmJ4MorXtPGvx2mbCR85rXtPabR)lBXS5hWTarCPU1qe8etPBmpxQBnpZsuehpMpLvz(LTHaI4sDRHi4jMjUl5w4Kh6QmIYmsd)uVpyLCMfXnD(ln0RvqxjY7Ce9xAOxRqZX(oKCGrrvVpynOBm)069xwSS5gve1n8ObIJYTwLInWJJA4VOGiUu3AicEIzZhDztXI4MoLvmA9SQDuYP9JIINsbRM)UwDMhX2M0HjKaUvu1n8ObutvF1n1qc84Og(hffpLcOMQ(QBQHe(LTbeXL6wdrWtmB855sDR5zwII44X8zANLGLBcIB6uwXO1ZQ2rjIHHGiUu3AicEIzJppxQBnpZsuehpMpp4HBxRMaIaI4sDRHeKvz(LTHCIYnHBKrCtN8W9rgXoXOCJkISkZVSnbDp4M8s4DMqZX(oeXSF(8O4Puq3dUjVeENjGBjkiIl1TgsqwL5x2gIGNyQ7b3KxcVZG4Mo5H7JmHpNw5QIDMZ5MppkEkf09GBYlH3zc)Y2aI4sDRHeKvz(LTHi4jMOCt4g5DoarCPU1qcYQm)Y2qe8etfB1dbXnD6sDTJF8WXlte7ZKT5)t9(Gvs(8TV)hBhpAW)FsyhXWq7dI4sDRHeKvz(LTHi4jMkw(HpOf(8FPQLmIB6efpLcnlr2WeYlvTKd4w5ZJINsbDp4M8s4DMaUfiIl1TgsqwL5x2gIGNygZXvN5vPNbxU)3VzpMG4MorXtPGUhCtEj8ota3kkkEkfq5MWnYHFzBarCPU1qcYQm)Y2qe8etutv)xLEkw(XdhNbXnDIINsbDp4M8s4DMaUfiIl1TgsqwL5x2gIGNyM42nVuZJ4idIB6uwXO1ZQ2rjN5cI4sDRHeKvz(LTHi4jMPsIt4)ZfhCVk)qzpgXnD6sDTJF8WXlte7ZKT5)t9(Gvs(8I0((FSD8Ob))jHDeddKBuE4(it4ZPvUQyN2pxrbrCPU1qcYQm)Y2qe8etl8Etz254HACII4MoDPU2XpE44LjI9zY28)PEFWkjF(23)JTJhn4)pjSJy5CUGicfqDPU1qcYQm)Y2qe8etSS36JjeEKmIB6efpLc6EWn5LW7mbClqexQBnKGSkZVSnebpXChP3JRBniUPtE4(iJyNyuUrfrwL5x2MGUhCtEj8otO5yFhIyzTF(8O4Puq3dUjVeENjGBjkiIl1TgsqwL5x2gIGNyAv6wdIB6u9(G1GUX8tR3F5CKZ2pFEr0nMFA9(lNJSIBUrfbfpLcOCt4g5aUv(8O4PuyhP3JRBnbClrffeXL6wdjiRY8lBdrWtmjy9FzlMnFe30PSIrRNvTJsYH9JYd3hze70L6wtODK5GSiA0FPH2rMdwX4gDTml35qyHSrrXtPGUhCtEj8ota3kQiO4Pua1u1xDtnKaUv(8crDdpAa1u1xDtnKapoQH)IgveHOUHhnSJ07X1TMapoQH)5ZlRY8lBtyhP3JRBnHMJ9DiILvCfnQqqXtPWosVhx3Ac4wGiUu3AibzvMFzBicEIjoHFRYXeqeqexQBnKqANLGLBYPvvMxZKcVLmIPQFdlE9mliIl1TgsiTZsWYnrWtmjUD(b)6YBe30jkEkfiUD(b)6Y7WVSnGiUu3AiH0olbl3ebpX0QkZRzsH3sgXu1VHfVEMfeXL6wdjK2zjy5Mi4jMw9g7MNT2vSikZin8t9(GvYzwe30jXInMN69bRKGvVXU5zRDfRyzJ(ln0RvO5yFhsoWqqexQBnKqANLGLBIGNyAvL51mPWBjJyQ63WIxpZcI4sDRHes7SeSCte8etREJDZZw7kweLzKg(PEFWk5mlIB6KyXgZt9(GvsWQ3y38S1UIvStHbI4sDRHes7SeSCte8etRQmVMjfElzetv)gw86zwqexQBnKqANLGLBIGNy2RfIYmsd)uVpyLCMfXnDkeDLiVZr(8I0CSVdjhNF821TMCk3agjAureI6gE0aXr5wRsXg4Xrn8x085fP5yFhsoo)4TRBn5uUbXnQf3KLO8OVyCJUwMLBX(Lg61kyfJB01YSClAu17dwd6gZpTE)LftCbrCPU1qcPDwcwUjcEIPvvMxZKcVLmIPQFdlE9mliIl1TgsiTZsWYnrWtmjUD(b)6YBe30jkEkfiUD(b)6Y7qZX(oKCKvyGiUu3AiH0olbl3ebpX0QkZRzsH3sgXu1VHfVEMfeXL6wdjK2zjy5Mi4jMX(gJ4MorXtPW218WG62ibClqexQBnKqANLGLBIGNyM4UKBHtEORYig7I)Xd3hzoZIOmJ0Wp17dwjNzbrarCPU1qch8WTRvtoB(OlBkwe30P6gE0aQPQV6MAibECud)JIINsbRM)UwDMhX2M0HjKaUvuu8ukGAQ6RUPgs4x2MOYkgTEw1ok5edJ(ln0oYCO5yFhsoWqqexQBnKWbpC7A1ebpXS5JUSPyrCtNQB4rdOMQ(QBQHe4Xrn8pkkEkfqnv9v3udj8lBtuu8uky1831QZ8i22KomHeWTIQUHhnyWhVF7qS221TMapoQH)r)LgAhzo0CSVdjhzbrCPU1qch8WTRvte8et0gxDZJyCcwe30jXInMN69bRKaAJRU5rmobRyFMSn)FQ3hSsarCPU1qch8WTRvte8etRQmVMjfElzetv)gw86zwqexQBnKWbpC7A1ebpXuX2ob7t6kIB6uKMtntW6Ogw0OIqSyJ5PEFWkjOyBNG9jDvmHjkiIl1Tgs4GhUDTAIGNyAvL51mPWBjJyQ63WIxpZcI4sDRHeo4HBxRMi4jMk22jyFsxrCtNIOUHhnqK8OVk9qnv9d84Og(hffpLcejp6Rsputv)WVSnIgLyXgZt9(GvsqX2ob7t6QyyeiIl1Tgs4GhUDTAIGNyAvL51mPWBjJyQ63WIxpZcI4sDRHeo4HBxRMi4jMeBRf)KUI4MorXtParYJ(Q0d1u1pGBLpViUu3AceBRf)KUg(ESFW5eXInMN69bRKaX2AXpPRIjIl1TMq7iZHVh7hSGI4sDRj0oYCqxjYVF8rozFrfvuqexQBnKWbpC7A1ebpX0QkZRzsH3sgXu1VHfVEMfeXL6wdjCWd3UwnrWtmBhzgrzgPHFQ3hSsoZI4MofIUsK35iFEreI6gE0aQPQV6MAibECud)J2CSVdjhF821TMCk3agjAu17dwd6gZpTE)LfddbrCPU1qch8WTRvte8etRQmVMjfElzetv)gw86zwqexQBnKWbpC7A1ebpXSDKzeLzKg(PEFWk5mlIB6uDdpAa1u1xDtnKapoQH)rrXtPaQPQV6MAibCROIisZX(oKCCk8Ig1IBYsuE0xmUrxlZYTy)sdTJmhSIXn6AzwUZPCdIR9fnQ69bRbDJ5NwV)YIHHGicfqThUkwafdIWbGgfqfajebuBmGk9bqXjmGgx1K2MbuTauIBhdOcGeGkX69btqeqDJPSTZbGItauTauuwvUb0MtntWcOTJmdI4sDRHeo4HBxRMi4jMXvnPT5N0ve30jkEkfqnv9v3udjGBfffpLcwn)DT6mpITnPdtiHFzBIkRy06zv7OKCyFqexQBnKWbpC7A1ebpXeTXv38igNGfXnDkckEkf09GBYlH3zc4wrfP99)y74rd()tc7iMizfm2f)tI17dMGXsSEFWKxQDPU14grZPMLy9(GF6gZIkkiIl1Tgs4GhUDTAIGNygx1K2MFsxruMrA4N69bRKZSiUPZMtntW6OggeXL6wdjCWd3UwnrWtmTQY8AMu4TKrmv9ByXRNzbrCPU1qch8WTRvte8etfB7eSpPRiUPZMtntW6OgoQiIyN3RJA4aoHFk22jypfwureckEkf2r6946wta3kFExCW9QCW2A(VKHjyBE(7Ce4Xrn8xurZNNyXgZt9(GvsqX2ob7t6QyzfferOaQl1Tgs4GhUDTAIGNyQyBNG9jDfXnD2CQzcwh1WrTZ71rnCaNWpfB7eSNzJIINsbPH9w6eDNJqZUuJkIqqXtPWosVhx3Ac4w5Z7IdUxLd2wZ)LmmbBZZFNJapoQH)IcI4sDRHeo4HBxRMi4jMwvzEntk8wYiMQ(nS41ZSGiUu3AiHdE421QjcEIjX2AXpPRiUPtIfBmp17dwjbIT1IFsxflliIl1Tgs4GhUDTAIGNysW28hXnD(ln0oYCO5yFhIyI4sDRjqW28pilIkOl1TMq7iZbzrumMhUpYiQ4eE4(itO5dEYNhfpLcsd7T0j6ohHMDPcIaIiuafjSmGww8WnGEWd3UXKbqtLXu2aufldOM6yLaALaufldOntuaTsaQILbu3YGiGIIRa6saucB5TR8hqlCfqXYndOPQbutDSs3aOsJ3RMberOaQ9qgqTTgdGww8aO2wflGIK9crantHdOsFauINytgav6efqvSlbqtDfdOeLDJIfqTTk2cxbu0MDK35aqxnaI4sDRHeklE4(u3dUjVeENberOaQ90yZZqa0YIha12Qyb02rMreqL1qWJ35aqjk7gflG6ZhqRHbubqcqLy9(Gbur2eGQUHhL)IcI4sDRHeklE4wWtmBhzgXnDkeDLiVZr(8O4PuWQlBMaUfiIqbumiSsa0yhzgqj4ndO2yaLNpGQyzaTS4HBav4mHfobNhjlCgqTHLhaTWBanTnrb0ETa0LaO6krENdqeHcOUu3AiHYIhUf8et78EDudJ44X8zzXd3VFnmI25gC(8xAOxRGUsK35aerOaQan7idOfUcOvcqvSmG6sDRbqnlrbrCHcOsDRHeklE4wWtmT5RIiHLN5gYn3SiUPZFPHETc6krENdqeHcOchja1gdOyD7yafdIWbIaQpFafRBhpcxfqDllZYFaDvandRakoHb04QM02CaeXL6wdjuw8WTGNygx1K2MFsxrCtNcrxjY7CaIiuaDkaDy(dOAbO28vb0u1aQ9bumyHtjaQpzIRMreqXGItuaTxla1NpGAJbuVzaf3cq95dOn(m7CaI4sDRHeklE4wWtmT6n2npBTRyrCtNUux74hpC8YeXYgveu8ukO7b3KxcVZeWTIkckEkfqnv9v3udjGBLpVqu3WJgqnv9v3udjWJJA4VOrfriQB4rdg8X73oeRTDDRjWJJA4F(8)sdXvnPT5N01GUsK35q0OcrxjY7CikiIl1TgsOS4HBbpXSxle30Pl11o(XdhVm5mBurqXtPGUhCtEj8ota3kQiO4Pua1u1xDtnKaUv(8crDdpAa1u1xDtnKapoQH)Ig9xAODK5GUsK35iQicrDdpAWGpE)2HyTTRBnbECud)ZN)xAiUQjTn)KUg0vI8ohIgvi6krENdrbrarCPU1qcOUXhjFsWN02mIB6S5uZeSoQHZNxexQRD8JhoEzIyzJkYV0abFsBZHMtntW6OgoFExQRD87xAGGpPT5C4sDTJF8WXltevuqexQBnKaQB8rYcEIPbF8(r0ErMrCtNUux74hpC8YeXWW85fXL6Ah)4HJxMiw2OO4PuWGpE)4yRYg3X8ObClrbrCPU1qcOUXhjl4jMKY49Zw7kwe30Pl11o(XdhVmrmHfffpLcKY49JJTkBChZJgWTarCPU1qcOUXhjl4jMe1BcEFWGiUu3Aibu34JKf8etsz8(zRDflIB6efpLcKY49JJTkBChZJgWTarCPU1qcOUXhjl4jMg8X7hr7fzgXnDIINsbd(49JJTkBChZJgWTarCPU1qcOUXhjl4jMKY49Zw7kw41oUjBnqeewUzXa5k85k8HCXa5IrWRnVNDoiWRWrSv1k)buHhqDPU1aOMLOKaic8AwIsGibVLfpCdrcIqwisWRl1Tg4v3dUjVeENbE5Xrn8hkauHiimisWlpoQH)qbGxzVk3RdVcbq1vI8ohaA(8akkEkfS6YMjGBbVUu3AG32rMHkebmcIe8YJJA4pua4v2RY96WRqauDLiVZb86sDRbEJRAsBZpPRqfIagcrcE5Xrn8hka8k7v5ED41L6Ah)4HJxMaOIbOzb0OaQiakkEkf09GBYlH3zc4waAuaveaffpLcOMQ(QBQHeWTa085buHaOQB4rdOMQ(QBQHe4Xrn8hqffqJcOIaOcbqv3WJgm4J3VDiwB76wtGhh1WFanFEa9xAiUQjTn)KUg0vI8ohaQOaAuaviaQUsK35aqffEDPU1aVw9g7MNT2vSqfIG9HibV84Og(dfaEL9QCVo86sDTJF8WXlta0tanlGgfqfbqrXtPGUhCtEj8ota3cqJcOIaOO4Pua1u1xDtnKaUfGMppGkeavDdpAa1u1xDtnKapoQH)aQOaAua9xAODK5GUsK35aqJcOIaOcbqv3WJgm4J3VDiwB76wtGhh1WFanFEa9xAiUQjTn)KUg0vI8ohaQOaAuaviaQUsK35aqffEDPU1aV9AbvOcVOUXhjdrcIqwisWlpoQH)qbGxzVk3RdVnNAMG1rnmGMppGkcG6sDTJF8WXltauXa0SaAuavea9xAGGpPT5qZPMjyDuddO5ZdOUux743V0abFsBZaAoauxQRD8JhoEzcGkkGkk86sDRbEj4tABgQqeegej4Lhh1WFOaWRSxL71HxxQRD8JhoEzcGkgGIHaA(8aQiaQl11o(XdhVmbqfdqZcOrbuu8ukyWhVFCSvzJ7yE0aUfGkk86sDRbEn4J3pI2lYmuHiGrqKGxECud)HcaVYEvUxhEDPU2XpE44LjaQyaQWa0OakkEkfiLX7hhBv24oMhnGBbVUu3AGxsz8(zRDfluHiGHqKGxxQBnWlr9MG3hm8YJJA4puaOcrW(qKGxECud)HcaVYEvUxhErXtPaPmE)4yRYg3X8ObCl41L6wd8skJ3pBTRyHkeHCgIe8YJJA4pua4v2RY96WlkEkfm4J3po2QSXDmpAa3cEDPU1aVg8X7hr7fzgQqeeEisWRl1Tg4LugVF2AxXcV84Og(dfaQqfE)CYXnkejiczHibV84Og(dfaEL9QCVo8keaffpLcwDzZeWTa0OaQqauu8ukqW6)YwmB(bCl41L6wd8sqg3yEOobluHiimisWlpoQH)qbGxxQBnWBJppxQBnpZsu4v2RY96WR6gE0aQB8rYppL2z1mbECud)b0OakkEkfIRAqENxQ64aUf8AwI(gpMHxu34JKHkebmcIe8YJJA4pua41L6wd824ZZL6wZZSefEL9QCVo8keaTS4H73VggqJcOIaOO4PuaLBc3ihWTa085buu8ukSJ07X1TMaUfGkk8AwI(gpMH3YIhUHkebmeIe8YJJA4pua4v2RY96WRqauu8ukiD9LQooGBbVUu3AGxPRVu1XqfIG9HibV84Og(dfaEL9QCVo8IINsbRUSzc4waA(8akkEkfiy9FzlMn)aUf86sDRbEBhzgQqeYzisWlpoQH)qbGxxQBnWR0nMNl1TMNzjk8AwI(gpMHxzvMFzBiqfIGWdrcE5Xrn8hka8k7v5ED49xAOxRGUsK35aqJcO)sd9AfAo23HaO5aqXiankGQEFWAq3y(P17VmGkgGMnxankGkcGQUHhnqCuU1QuSbECud)burHxxQBnWBI7sUfo5HUkdVYmsd)uVpyLariluHiiUqKGxECud)HcaVYEvUxhELvmA9SQDucGEcO2hqJcOO4PuWQ5VRvN5rSTjDycjGBbOrbu1n8ObutvF1n1qc84Og(dOrbuu8ukGAQ6RUPgs4x2g41L6wd828rx2uSqfIagaIe8YJJA4pua41L6wd824ZZL6wZZSefEL9QCVo8kRy06zv7OeavmafdHxZs034Xm8M2zjy5MaviczZfIe8YJJA4pua41L6wd824ZZL6wZZSefEnlrFJhZW7bpC7A1eOcv41QzzfJ6kejiczHibV84Og(dfaEL9QCVo8IINsH4QgK35LQoo8lBdGgfqv3WJgqnv9v3udjWJJA4p86sDRbEB(OlBkwOcrqyqKGxECud)HcaVLf8syfEDPU1aV2596OggETZn4m8Ml8AN3VXJz4fNWpfB7eSqfIagbrcE5Xrn8hka8wwWlHv41L6wd8AN3RJAy41o3GZWRWGx78(nEmdV4e(PyBNGfEL9QCVo86IdUxLd2wZ)LmmbBZZFNJapoQH)qfIagcrcE5Xrn8hka8k7v5ED4ffpLcXvniVZlvDC4x2g41L6wd8A1LnduHiyFisWlpoQH)qbGxzVk3RdVO4PuiUQb5DEPQJd)Y2aVUu3AGxPRVu1XqfIqodrcEDPU1aVwLU1aV84Og(dfaQqeeEisWlpoQH)qbGxzVk3RdVO4PuiUQb5DEPQJd)Y2aVUu3AGxuUjCJmuHiiUqKGxECud)HcaVYEvUxhErXtPqCvdY78svhh(LTbEDPU1aV6EWn5LW7mqfQW7bpC7A1eisqeYcrcE5Xrn8hka8k7v5ED4vDdpAa1u1xDtnKapoQH)aAuaffpLcwn)DT6mpITnPdtibClankGIINsbutvF1n1qc)Y2aOrbuzfJwpRAhLaONakgcOrb0FPH2rMdnh77qa0CaOyi86sDRbEB(OlBkwOcrqyqKGxECud)HcaVYEvUxhEv3WJgqnv9v3udjWJJA4pGgfqrXtPaQPQV6MAiHFzBa0OakkEkfSA(7A1zEeBBshMqc4waAuavDdpAWGpE)2HyTTRBnbECud)b0Oa6V0q7iZHMJ9DiaAoa0SWRl1Tg4T5JUSPyHkebmcIe8YJJA4pua4v2RY96WlXInMN69bRKaAJRU5rmoblGkgG(zY28)PEFWkbEDPU1aVOnU6MhX4eSqfIagcrcE5Xrn8hka8MQ(nS4viczHxxQBnWRvvMxZKcVLmuHiyFisWlpoQH)qbGxzVk3RdVIaOnNAMG1rnmGkkGgfqfbqjwSX8uVpyLeuSTtW(KUcOIbOcdqffEDPU1aVk22jyFsxHkeHCgIe8YJJA4pua4nv9ByXRqeYcVUu3AGxRQmVMjfElzOcrq4HibV84Og(dfaEL9QCVo8kcGQUHhnqK8OVk9qnv9d84Og(dOrbuu8ukqK8OVk9qnv9d)Y2aOIcOrbuIfBmp17dwjbfB7eSpPRaQyakgbVUu3AGxfB7eSpPRqfIG4crcE5Xrn8hka8MQ(nS4viczHxxQBnWRvvMxZKcVLmuHiGbGibV84Og(dfaEL9QCVo8IINsbIKh9vPhQPQFa3cqZNhqfbqDPU1ei2wl(jDn89y)Gb0CcqjwSX8uVpyLei2wl(jDfqfdqfbqDPU1eAhzo89y)GbubburauxQBnH2rMd6kr(9Jpa0CcqTpGkkGkkGkk86sDRbEj2wl(jDfQqeYMlej4Lhh1WFOaWBQ63WIxHiKfEDPU1aVwvzEntk8wYqfIq2SqKGxECud)HcaVYEvUxhEfcGQRe5Doa085burauHaOQB4rdOMQ(QBQHe4Xrn8hqJcOnh77qa0CaOF821TganNa0CdyeGkkGgfqvVpynOBm)069xgqfdqXq41L6wd82oYm8kZin8t9(GvceHSqfIqwHbrcE5Xrn8hka8MQ(nS4viczHxxQBnWRvvMxZKcVLmuHiKfJGibV84Og(dfaEL9QCVo8QUHhnGAQ6RUPgsGhh1WFankGIINsbutvF1n1qc4waAuaveaveaT5yFhcGMJtav4burb0OaQf3KLO8OVyCJUwMLBavma9xAODK5GvmUrxlZYnGMtaAUbX1(aQOaAuav9(G1GUX8tR3FzavmafdHxxQBnWB7iZWRmJ0Wp17dwjqeYcviczXqisWlpoQH)qbGxzVk3RdVO4Pua1u1xDtnKaUfGgfqrXtPGvZFxRoZJyBt6Wes4x2gankGkRy06zv7OeanhaQ9HxxQBnWBCvtAB(jDfQqeYAFisWlpoQH)qbGxzVk3RdVIaOO4Puq3dUjVeENjGBbOrbura023)JTJhn4)pjSdGkgGkcGMfqfeqJDX)Ky9(GjakgdOsSEFWKxQDPU14gavuanNa0MLy9(GF6gZaQOaQOWRl1Tg4fTXv38igNGfQqeYMZqKGxECud)HcaVYEvUxhEBo1mbRJAy41L6wd8gx1K2MFsxHxzgPHFQ3hSsGiKfQqeYk8qKGxECud)HcaVPQFdlEfIqw41L6wd8AvL51mPWBjdviczfxisWlpoQH)qbGxzVk3RdVnNAMG1rnmGgfqfbqfbqTZ71rnCaNWpfB7eSa6jGkmankGkcGkeaffpLc7i9ECDRjGBbO5ZdOU4G7v5GT18FjdtW28835iWJJA4pGkkGkkGMppGsSyJ5PEFWkjOyBNG9jDfqfdqZcOIcVUu3AGxfB7eSpPRqfIqwmaej4Lhh1WFOaWBQ63WIxHiKfEDPU1aVwvzEntk8wYqfIGWYfIe8YJJA4pua4v2RY96WlXInMN69bRKaX2AXpPRaQyaAw41L6wd8sSTw8t6kuHiiSSqKGxECud)HcaVYEvUxhE)LgAhzo0CSVdbqfdqfbqDPU1eiyB(hKfrbubbuxQBnH2rMdYIOakgdO8W9rgavuavCcGYd3hzcnFWdGMppGIINsbPH9w6eDNJqZUuHxxQBnWlbBZFOcv4nTZsWYnbIeeHSqKGxECud)HcaVPQFdlEfIqw41L6wd8AvL51mPWBjdviccdIe8YJJA4pua4v2RY96WlkEkfiUD(b)6Y7WVSnWRl1Tg4L425h8RlVHkebmcIe8YJJA4pua4nv9ByXRqeYcVUu3AGxRQmVMjfElzOcradHibV84Og(dfaEL9QCVo8sSyJ5PEFWkjy1BSBE2AxXcOIbOzb0Oa6V0qVwHMJ9DiaAoaumeEDPU1aVw9g7MNT2vSWRmJ0Wp17dwjqeYcvic2hIe8YJJA4pua4nv9ByXRqeYcVUu3AGxRQmVMjfElzOcriNHibV84Og(dfaEL9QCVo8sSyJ5PEFWkjy1BSBE2AxXcOIDcOcdEDPU1aVw9g7MNT2vSWRmJ0Wp17dwjqeYcviccpej4Lhh1WFOaWBQ63WIxHiKfEDPU1aVwvzEntk8wYqfIG4crcE5Xrn8hka8k7v5ED4viaQUsK35aqZNhqfbqBo23HaO54eq)4TRBnaAobO5gWiavuankGkcGkeavDdpAG4OCRvPyd84Og(dOIcO5ZdOIaOnh77qa0CCcOF821TganNa0CdIlGgfqT4MSeLh9fJB01YSCdOIbO)sd9AfSIXn6AzwUburb0OaQ69bRbDJ5NwV)YaQyaQ4cVUu3AG3ETGxzgPHFQ3hSsGiKfQqeWaqKGxECud)HcaVPQFdlEfIqw41L6wd8AvL51mPWBjdviczZfIe8YJJA4pua4v2RY96WlkEkfiUD(b)6Y7qZX(oeanhaAwHbVUu3AGxIBNFWVU8gQqeYMfIe8YJJA4pua4nv9ByXRqeYcVUu3AGxRQmVMjfElzOcriRWGibV84Og(dfaEL9QCVo8IINsHTR5Hb1Trc4wWRl1Tg4n23yOcrilgbrcE5Xrn8hka8g7I)Xd3hzG3SWRl1Tg4nXDj3cN8qxLHxzgPHFQ3hSsGiKfQqfELvz(LTHarcIqwisWlpoQH)qbGxzVk3RdV8W9rgavStafJYfqJcOIaOYQm)Y2e09GBYlH3zcnh77qauXau7dO5ZdOO4Puq3dUjVeENjGBbOIcVUu3AGxuUjCJmuHiimisWlpoQH)qbGxzVk3RdV8W9rMWNtRCvavStanNZfqZNhqrXtPGUhCtEj8ot4x2g41L6wd8Q7b3KxcVZavicyeej41L6wd8IYnHBK35aE5Xrn8hkauHiGHqKGxECud)HcaVYEvUxhEDPU2XpE44LjaQya6NjBZ)N69bReanFEaT99)y74rd()tc7aOIbOyO9HxxQBnWRIT6Havic2hIe8YJJA4pua4v2RY96WlkEkfAwISHjKxQAjhWTa085buu8ukO7b3KxcVZeWTGxxQBnWRILF4dAHp)xQAjdvic5mej4Lhh1WFOaWRSxL71Hxu8ukO7b3KxcVZeWTa0OakkEkfq5MWnYHFzBGxxQBnWBmhxDMxLEgC5(F)M9ycuHii8qKGxECud)HcaVYEvUxhErXtPGUhCtEj8ota3cEDPU1aVOMQ(Vk9uS8JhooduHiiUqKGxECud)HcaVYEvUxhELvmA9SQDucGEcO5cVUu3AG3e3U5LAEehzGkebmaej4Lhh1WFOaWRSxL71HxxQRD8JhoEzcGkgG(zY28)PEFWkbqZNhqfbqBF)p2oE0G))KWoaQyakgixankGYd3hzcFoTYvbuXobu7NlGkk86sDRbEtLeNW)Nlo4Ev(HYEmuHiKnxisWlpoQH)qbGxzVk3RdVUux74hpC8Yeavma9ZKT5)t9(GvcGMppG2((FSD8Ob))jHDauXa0Cox41L6wd8AH3BkZohpuJtuOcriBwisWlpoQH)qbGxzVk3RdV8W9rgavStafJYfqJcOIaOYQm)Y2e09GBYlH3zcnh77qauXa0S2hqZNhqrXtPGUhCtEj8ota3cqffEDPU1aV7i9ECDRbQqeYkmisWlpoQH)qbGxzVk3RdVQ3hSg0nMFA9(ldO5aqZz7dO5ZdOIaO6gZpTE)Lb0CaOzf3Cb0OaQiakkEkfq5MWnYbClanFEaffpLc7i9ECDRjGBbOIcOIcVUu3AGxRs3AGkeHSyeej4Lhh1WFOaWRSxL71HxzfJwpRAhLaO5aqTpGgfq5H7JmaQyNaQl1TMq7iZbzruankG(ln0oYCWkg3ORLz5gqZbGkSqwankGIINsbDp4M8s4DMaUfGgfqfbqrXtPaQPQV6MAibClanFEaviaQ6gE0aQPQV6MAibECud)burb0OaQiaQqau1n8OHDKEpUU1e4Xrn8hqZNhqLvz(LTjSJ07X1TMqZX(oeavmanR4cOIcOrbuHaOO4PuyhP3JRBnbCl41L6wd8sW6)YwmB(qfIqwmeIe86sDRbEXj8BvoMaV84Og(dfaQqfQWRJRyRgEVBmgmuHkec]] )
    
end
