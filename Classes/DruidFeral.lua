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

    spec:RegisterPack( "Feral", 20190714.2359, [[dSuHkbqicklsqfQhrq6scQq2Kq8jcqnkbYPeOwfbrVck1Saj3IGWUi6xqjdJa6ykILrq1Zeu10uKQRjO02uKKVPifJtrkDocGwhbaVtqLW8uK4EGyFcOdQiPSqc0djaXevKu5IcQeTrbvQtsasRuintfjvTtvu)uqLudvqfulLaqpvvMki1xfujzVq(RknyKomvlgupMIjRQUmQnRWNvHrdfNw0QfubETIQztPBlu7wPFlz4e64cQGSCPEoIPt66q12fGVliJxqX5vuwVGkA(Qi7hy0ee0O33vgDw4cCIauGtZKPlfE4d70kWWIE6mrg9eDZC)GrV1Jz0lCZTBrprFMT8pcA0Ju4THrpmQkseaWcRJuXGdlnvmwKmg36AwRP9HIfjJnyHEW4Pvfqxem69DLrNfUaNiaf40mz6sHh(WonHpSOhrKnOZtey4rpm5)Zlcg9(mXGEcfqd3C7waDQRXZpiQqbumQkseaWcRJuXGdlnvmwKmg36AwRP9HIfjJnybIkuankUDgGoz6qbOcxGteGaQqaOcp8caHDQarbrfkGkGGX3dMiaaIkuavia0P2)ZFa9nh3AbubDcgjiQqbuHaqfazRhg(dOqNhClGjaA4gVNbO8Y9Xma1GHnZbuTauxu0odqR1odqdHHxaf68GBbmbqd349manjaQBB2)ZauCrjiQqbuHaqlrE5((RLb0KaOy89B5pGMRY96w7mafEgGQyya1))AdxaOnhxbWFavXWegqdW70HTmrcOaA461odqHlfd3aAUakCria6ipWOejiQqbuHaqfqQnaUvav9(G1BoautT)uZAjaQwaQzMXYx17dwjsquHcOcbGkaYXvamGkGXWERxMq41Wcya9GxUtdG6gnRvcIkuavia0P2)dOc6wFnmGo1gJCtDgGk2z1PotcIkuaviaubqoxt1Iv7kdOKkMb0AaOpmXvn1H)zbmbq5FQej6j21iTm6juanCZTBb0PUgp)GOcfqXOQiraalSosfdoS0uXyrYyCRRzTM2hkwKm2GfiQqb0O42za6KPdfGkCboracOcbGk8Wlae2PcefevOaQacgFpyIaaiQqbuHaqNA)p)b03CCRfqf0jyKGOcfqfcavaKTEy4pGcDEWTaMaOHB8EgGYl3hZaudg2mhq1cqDrr7maTw7manegEbuOZdUfWeanCJ3Za0KaOUTz)pdqXfLGOcfqfcaTe5L77VwgqtcGIX3VL)aAUk3RBTZau4zaQIHbu))RnCbG2CCfa)bufdtyanaVth2YejGcOHRx7mafUumCdO5cOWfHaOJ8aJsKGOcfqfcavaP2a4wbu17dwV5aqn1(tnRLaOAbOMzglFvVpyLibrfkGkeaQaihxbWaQagd7TEzcHxdlGb0dE5onaQB0SwjiQqbuHaqNA)pGkOB91Wa6uBmYn1zaQyNvN6mjiQqbuHaqfa5CnvlwTRmGsQygqRbG(Wex1uh(NfWeaL)PsKGOGOcfqdxgg2GR8hqH5r1mGAQyyxbuy(ixIeqNAgdlQeaDRviW4D8a3cOUrZAjaAT2zsquHcOUrZAjsXMnvmSRqgwNmhevOaQB0SwIuSztfd7k2qWAu1hevOaQB0SwIuSztfd7k2qWYXpI5vDnRfevOaQaQcOjbqdvTIbqtfqhvdOUnUikGYbW9SAzavlan2Zv9Cbuft7emGOUrZAjsXMnvmSRydbRa8oDyld16XmeCcFvmTtWavaUfNHiqqu3OzTePyZMkg2vSHGvaENoSLHA9ygcoHVkM2jyGka3IZqeou5aIho5ovwgkT)7WYemnV)CpK86Ww(dI6gnRLifB2uXWUIneScW70HTmuRhZq6u8QPzobQaClodzAbrDJM1sKInBQyyxXgcwnF0vifdu5acm(yiJRANN7DuDS8xH2iQB5vLW2Q(QBRLi51HT8he1nAwlrk2SPIHDfBiyj2vilu5acm(yiJRANN7DuDS8xHwqu3OzTePyZMkg2vSHGLX17O6yOYbey8Xqgx1op37O6y5VcTGOcfqFRlsWukG2E(buy8XG)akrDLaOW8OAgqnvmSRakmFKlbq99dOInleILQ5EaOjbq)1YsquHcOUrZAjsXMnvmSRydblY6IemLEjQRequ3OzTePyZMkg2vSHGLyPzTGOUrZAjsXMnvmSRydblyUjCphQCabgFmKXvTZZ9oQow(RqliQB0SwIuSztfd7k2qWsZdUj3bEpdQCabgFmKXvTZZ9oQow(RqlikiQqb0WLHHn4k)buoaUNbOAgZaQIHbu3OvdOjbq9a806WwwcI6gnRLaHmh3AVWobdu5aIWGXhdPyxHSsCXicdgFmKem(VcfZ2Vexee1nAwlbBiy1471nAw71MefQ1JziWU1xddvoGOULxvc7wFn81hJCtDMKxh2Y)iW4JHmUQDEU3r1XsCrqu3OzTeSHGLXT2RB0S2RnjkuRhZqkrE5gQCaryLiVCF)1YrccgFmKWCt4EUex80jy8XqMRX711SwjU4PtW4JHe2w1xDBTejUyWGOUrZAjydblJR3r1XqLdicdgFmKgxVJQJL4IGOUrZAjydbR2NZqLdiW4JHuSRqwjU4PtW4JHKGX)vOy2(L4IGOUrZAjydblJBTx3OzTxBsuOwpMHyQY(Rqlbe1nAwlbBiyn4UmzHtUWPYqzMzS8v9(GvcKjqLdi)sLDkk10mp3Ji)sLDkkBo2ZLmLWhr9(GvPMX8vR7p5aNiWibPULxvsCyU1QumsEDyl)dge1nAwlbBiyn4UmzHtUWPYqzMzS8v9(GvcKjqLdiQB5vLehMBTkfJKxh2Y)iMkgUUIvUkjqIiBTx17dwjsft7emxJRr(Lk7uuQPzEUhr(Lk7uu2CSNlzkHpI69bRsnJ5Rw3FYb(lv2POS5ypxc2b4D6Www2P4vtZCIq6gnRv2POutZ8RMXmiQqbu3OzTeSHGvZhDfsXavoGyQy46kw5QeiHncm(yifB(7A1ZUKq5qxMqK4Iru3YRkHTv9v3wlrYRdB5Fey8XqcBR6RUTwI8xHwqu3OzTeSHGvJVx3OzTxBsuOwpMHmYnjy4MavoGyQy46kw5QKaNoiQB0Swc2qWQX3RB0S2RnjkuRhZqo4LBxRMaIcI6gnRLinvz)vOLabMBc3ZHkhq4L7Jzbcj8cmsqMQS)k0k18GBYDG3ZKnh75scmSNobJpgsnp4MCh49mjUyWGOUrZAjstv2FfAjydblnp4MCh49mOYbeE5(yM8ZJ0KAGqMkbE6em(yi18GBYDG3ZK)k0cI6gnRLinvz)vOLGneSG5MW98CparDJM1sKMQS)k0sWgcwkMQxcu5aIB0ma(YlhNmjWptYM)x17dwjNo1E(VCa8Qs))jYCdC6Hfe1nAwlrAQY(RqlbBiyPy4l(cx47)oQ2WqLdiW4JHSzZClti3r1gwIlE6em(yi18GBYDG3ZK4IGOUrZAjstv2FfAjydbRyoU6z3ACT4M8F)n7XeOYbey8XqQ5b3K7aVNjXfJaJpgsyUjCpx(RqliQB0SwI0uL9xHwc2qWc2w1)wJRIHV8YXZGkhqGXhdPMhCtUd8EMexee1nAwlrAQY(RqlbBiyn42T3rZB4Cgu5aIPIHRRyLRsGiqqu3OzTePPk7VcTeSHG1Om4e(F9Wj3PYxy2JHkhqCJMbWxE54Kjb(zs28)QEFWk50PGAp)xoaEvP))ezUbkafyeE5(yM8ZJ0KAGqcRadge1nAwlrAQY(RqlbBiyjI35ywUhxyRtuOYbe3Oza8LxoozsGFMKn)VQ3hSsoDQ98F5a4vL()tK5g4ujqquHcOUrZAjstv2FfAjydblmS36LjeEnmu5acm(yi18GBYDG3ZK4IGOUrZAjstv2FfAjydbRCnEVUM1cvoGWl3hZces4fyKGmvz)vOvQ5b3K7aVNjBo2ZLe4KWE6em(yi18GBYDG3ZK4IbdI6gnRLinvz)vOLGneSelnRfQCar9(GvPMX8vR7p5PmvH90PG0mMVAD)jpLjtRaJeem(yiH5MW9CjU4PtW4JHmxJ3RRzTsCXGdge1nAwlrAQY(RqlbBiyrW4)kumB)qLdiMkgUUIvUkzkHncVCFmlqiUrZALTpNLMIOr(LkBFolfJXTAkAtUNIWLtIaJpgsnp4MCh49mjUyKGGXhdjSTQV62AjsCXtNeM6wEvjSTQV62AjsEDyl)dosqctDlVQmxJ3RRzTsEDyl)pDYuL9xHwzUgVxxZALnh75scCY0gCeHbJpgYCnEVUM1kXfbrDJM1sKMQS)k0sWgcw4e(MkhtarbrDJM1sKJCtcgUjqA(ORqkgOYbey8Xqk2831QNDjHYHUmHiXfJOULxvcBR6RUTwIKxh2Y)iW4JHe2w1xDBTejrDZ8PiCqu3OzTe5i3KGHBc2qWsSk7TzsH3ggQr13LdJczciQB0SwICKBsWWnbBiyr8a8d(2L3qLdiW4JHK4b4h8TlVL)k0cI6gnRLih5MemCtWgcwIvzVntk82WqnQ(UCyuitarDJM1sKJCtcgUjydblXoJD7nu7kgOmZmw(QEFWkbYeOYbeIiBTx17dwjsXoJD7nu7kMaNe5xQStrzZXEUKPmDqu3OzTe5i3KGHBc2qWsSk7TzsH3ggQr13LdJczciQB0SwICKBsWWnbBiyj2zSBVHAxXaLzMXYx17dwjqMavoGqezR9QEFWkrk2zSBVHAxXeieHdI6gnRLih5MemCtWgcwIvzVntk82WqnQ(UCyuitarDJM1sKJCtcgUjydbRofHYmZy5R69bReitGkhqeM6wEvjXH5wRsXi51HT8psZJMjyCylhr9(GvPMX8vR7p5a)Lk7uu2CSNlb7a8oDyll7u8QPzoriDJM1k7uuQPz(vZyge1nAwlroYnjy4MGneSeRYEBMu4THHAu9D5WOqMaI6gnRLih5MemCtWgcwDkcL69bR3CarDlVQK4WCRvPyK86Ww(hjiHPPzEUhNo1CSNlzkq(4TRzTcPaLHpIi3KKO8Q3yCRMI2K7a)Lk7uukgJB1u0MChCe17dwLAgZxTU)Kd8xQStrzZXEUeSdW70HTSStXRMM5eHmOjy)lv2POutZ8CpeYWhSq6gnRv2POutZ8RMXmiQB0SwICKBsWWnbBiyjwL92mPWBdd1O67YHrHmbe1nAwlroYnjy4MGneSiEa(bF7YBOYbey8Xqs8a8d(2L3YMJ9CjtzIWbrDJM1sKJCtcgUjydblXQS3MjfEByOgvFxomkKjGOUrZAjYrUjbd3eSHGvSNXqLdiW4JHm7AVHd8qejUiiQB0SwICKBsWWnbBiyn4UmzHtUWPYqf7H5Yl3hZGmbkZmJLVQ3hSsGmbefe1nAwlrEWl3UwnbsZhDfsXavoGOULxvcBR6RUTwIKxh2Y)iW4JHuS5VRvp7scLdDzcrIlgbgFmKW2Q(QBRLi)vOnIPIHRRyLRsGm9i)sLTpNLnh75sMY0brDJM1sKh8YTRvtWgcwnF0vifdu5aI6wEvjSTQV62AjsEDyl)JaJpgsyBvF1T1sK)k0gbgFmKIn)DT6zxsOCOltisCXiQB5vLw817BUeXSDnRvYRdB5FKFPY2NZYMJ9CjtzciQB0SwI8GxUDTAc2qWcUXv3EjwNGbQCaHiYw7v9(GvIeUXv3EjwNGjWptYM)x17dwjGOUrZAjYdE521QjydblXQS3MjfEByOgvFxomkKjGOUrZAjYdE521Qjydblft7emxJRqLdib18Ozcgh2YbhjiIiBTx17dwjsft7emxJRbk8GbrDJM1sKh8YTRvtWgcwIvzVntk82WqnQ(UCyuitarDJM1sKh8YTRvtWgcwkM2jyUgxHkhqcsDlVQKy4vV14cBR6l51HT8pcm(yijgE1BnUW2Q(YFfAdocrKT2R69bRePIPDcMRX1adpiQB0SwI8GxUDTAc2qWsSk7TzsH3ggQr13LdJczciQB0SwI8GxUDTAc2qWIekf5RXvOYbey8Xqsm8Q3ACHTv9L4INofKB0SwjjukYxJRYVh7hSqsezR9QEFWkrscLI814AGb5gnRv2(Cw(9y)GXoi3OzTY2NZsnnZV)4dHmSbhCWGOUrZAjYdE521QjydblXQS3MjfEByOgvFxomkKjGOUrZAjYdE521QjydbR2NZqzMzS8v9(GvcKjqLdicttZ8CpoDkiHPULxvcBR6RUTwIKxh2Y)inh75sMYhVDnRvifOm8bhr9(GvPMX8vR7p5aNoiQB0SwI8GxUDTAc2qWsSk7TzsH3ggQr13LdJczciQB0SwI8GxUDTAc2qWQ95muMzglFvVpyLazcu5aI6wEvjSTQV62AjsEDyl)JaJpgsyBvF1T1sK4IrckOMJ9CjtbY0eCerUjjr5vVX4wnfTj3b(lv2(CwkgJB1u0MClKcuoTHn4iQ3hSk1mMVAD)jh40brfkGgUkvma6uVakGgbqfeAOa0qmGA8fqXjmGgx1oYMbuTauIhadOccnGAW49btGcqDRTcL7bGItauTauywvUb0MhntWaOTpNbrDJM1sKh8YTRvtWgcwXvTJS5RXvOYbey8XqcBR6RUTwIexmcm(yifB(7A1ZUKq5qxMqK)k0gXuXW1vSYvjtjSGOUrZAjYdE521Qjydbl4gxD7LyDcgOYbKGGXhdPMhCtUd8EMexmsqTN)lhaVQ0)FIm3adAc2XEyUgmEFWeHWGX7dMChTB0Sw3gSq2SbJ3h8vZyo4GbrDJM1sKh8YTRvtWgcwXvTJS5RXvOmZmw(QEFWkbYeOYbKMhntW4Wwge1nAwlrEWl3UwnbBiyjwL92mPWBdd1O67YHrHmbe1nAwlrEWl3UwnbBiyPyANG5ACfQCaP5rZemoSLJeuqb4D6WwwIt4RIPDcgicpsqcdgFmK5A8EDnRvIlE6Kho5ovwgkT)7WYemnV)CpK86Ww(hCWNorezR9QEFWkrQyANG5ACnWjbdIkua1nAwlrEWl3UwnbBiyPyANG5ACfQCaP5rZemoSLJeG3PdBzjoHVkM2jyGmjcm(yinw2BJt0CpKn7gnsqcdgFmK5A8EDnRvIlE6Kho5ovwgkT)7WYemnV)CpK86Ww(hmiQB0SwI8GxUDTAc2qWsSk7TzsH3ggQr13LdJczciQB0SwI8GxUDTAc2qWIekf5RXvOYbeIiBTx17dwjssOuKVgxdCciQB0SwI8GxUDTAc2qWIGP5pu5aYVuz7ZzzZXEUKadYnAwRKGP5V0uefB3OzTY2NZstruHGxUpMfC4iE5(yMS5dEpDcgFmKgl7TXjAUhYMDJcIcIkuafAmmGwI8YnGEWl3U1odqhL1wHaufddO26inaAnaufddOntuaTgaQIHbux0cfGcJRaAsaucl6TR8hqlCfqXWndOJQbuBDKg3cOgR3PodevOaA4kgqdLwlGwI8cOHsfdGcD4gkaDwHdOgFbuIpy7ma14efqvmjbqhDfdOeLDRIbqdLkMcxbu4M955EaOPkbrDJM1sKLiVCdrZdUj3bEpdevOa6uZgYNra0sKxanuQya02NZqbOMAj4X5EaOeLDRIbq99dO1YaQGqdOgmEFWaAq5aqv3YRY)GbrDJM1sKLiVCJneSAFodvoGimnnZZ940jy8Xqk2viRexeevOa6upRean2NZakbVzanedO8(bufddOLiVCdOHJjC4q48A4WXaAim8cOfEdOJSjkG2PiGMeavtZ8CparfkG6gnRLilrE5gBiyfG3PdBzOwpMHuI8Y99xldvaUfNH8lv2POutZ8CparfkGkyZ(CaTWvaTgaQIHbu3OzTaQnjkiQqbu3OzTezjYl3ydbRqEQqrydebkfOaNavoG8lv2POutZ8CparfkGkGoa0qmGIXdGb0PEbuOauF)akgpaEfWkG6II2K)aAQa6mwbuCcdOXvTJSzjiQB0SwISe5LBSHGvCv7iB(ACfQCaryAAMN7biQqb0Ta0L5pGQfGgYtfqhvdOHfqfqchMaO(olUAgkanCaorb0ofbuF)aAigq9MbuCra13pG247M7biQB0SwISe5LBSHGLyNXU9gQDfdu5aIB0ma(YlhNmjWjrccgFmKAEWn5oW7zsCXibbJpgsyBvF1T1sK4INojm1T8QsyBvF1T1sK86Ww(hCKGeM6wEvPfF9(MlrmBxZAL86Ww(F60VuzCv7iB(ACvQPzEUhbhryAAMN7rWGOUrZAjYsKxUXgcwDkcvoG4gndGV8YXjtGmjsqW4JHuZdUj3bEptIlgjiy8XqcBR6RUTwIex80jHPULxvcBR6RUTwIKxh2Y)GJ8lv2(CwQPzEUhrcsyQB5vLw817BUeXSDnRvYRdB5)Pt)sLXvTJS5RXvPMM55EeCeHPPzEUhbdIcI6gnRLiHDRVggcbFhzZqLdinpAMGXHT8Ptb5gndGV8YXjtcCsKG(Lkj47iBw28Ozcgh2YNo5gndGV)sLe8DKnpf3Oza8LxoozsWbdI6gnRLiHDRVggBiyzXxVVeTZ5mu5aIB0ma(YlhNmjWPF6uqUrZa4lVCCYKaNebgFmKw817lhlwH4oMxvIlgmiQB0SwIe2T(AySHGfPSEFd1UIbQCaXnAgaF5LJtMeOWJaJpgssz9(YXIviUJ5vL4IGOUrZAjsy36RHXgcwe1BcEFWGOUrZAjsy36RHXgcwKY69nu7kgOYbey8XqskR3xowScXDmVQexee1nAwlrc7wFnm2qWYIVEFjANZzOYbey8XqAXxVVCSyfI7yEvjUiiQB0SwIe2T(AySHGfPSEFd1UIb9cGBswl6SWf4ebOaNgbonsHlqHJEH8EZ9GGEcOXIvR8hqNga1nAwlGAtIsKGOONnjkbbn6vI8YncA05jiOrp3OzTONMhCtUd8Eg6XRdB5psqKIolCe0OhVoSL)ibrptNk3PJEcdq10mp3da90jafgFmKIDfYkXfrp3OzTOx7ZzKIohEe0OhVoSL)ibrptNk3PJEcdq10mp3d0ZnAwl6fx1oYMVgxrk680rqJE86Ww(Jee9mDQCNo65gndGV8YXjta0ab0jaAeaniafgFmKAEWn5oW7zsCrancGgeGcJpgsyBvF1T1sK4Ia6PtaQWau1T8QsyBvF1T1sK86Ww(dObdOra0GauHbOQB5vLw817BUeXSDnRvYRdB5pGE6eG(lvgx1oYMVgxLAAMN7bGgmGgbqfgGQPzEUhaAWONB0Sw0tSZy3Ed1UIbPOZHfbn6XRdB5psq0Z0PYD6ONB0ma(YlhNmbqHaOta0iaAqakm(yi18GBYDG3ZK4IaAeaniafgFmKW2Q(QBRLiXfb0tNauHbOQB5vLW2Q(QBRLi51HT8hqdgqJaO)sLTpNLAAMN7bGgbqdcqfgGQULxvAXxVV5seZ21SwjVoSL)a6Pta6VuzCv7iB(ACvQPzEUhaAWaAeavyaQMM55EaObJEUrZArVofrksrpy36RHrqJopbbn6XRdB5psq0Z0PYD6OxZJMjyCyldONobObbOUrZa4lVCCYeanqaDcGgbqdcq)Lkj47iBw28Ozcgh2Ya6PtaQB0ma((lvsW3r2mGofa1nAgaF5LJtMaObdObJEUrZArpc(oYMrk6SWrqJE86Ww(Jee9mDQCNo65gndGV8YXjta0ab0PdONobObbOUrZa4lVCCYeanqaDcGgbqHXhdPfF9(YXIviUJ5vL4IaAWONB0Sw0ZIVEFjANZzKIohEe0OhVoSL)ibrptNk3PJEUrZa4lVCCYeanqav4aAeafgFmKKY69LJfRqChZRkXfrp3OzTOhPSEFd1UIbPOZthbn65gnRf9iQ3e8(GrpEDyl)rcIu05WIGg941HT8hji6z6u5oD0dgFmKKY69LJfRqChZRkXfrp3OzTOhPSEFd1UIbPOZtfcA0Jxh2YFKGONPtL70rpy8XqAXxVVCSyfI7yEvjUi65gnRf9S4R3xI25CgPOZtdcA0ZnAwl6rkR33qTRyqpEDyl)rcIuKIEFE44wfbn68ee0OhVoSL)ibrptNk3PJEcdqHXhdPyxHSsCrancGkmafgFmKem(VcfZ2Vexe9CJM1IEK54w7f2jyqk6SWrqJE86Ww(Jee9mDQCNo6PULxvc7wFn81hJCtDMKxh2YFancGcJpgY4Q255EhvhlXfrp3OzTOxJVx3OzTxBsu0ZMe9UEmJEWU1xdJu05WJGg941HT8hji6z6u5oD0tyaAjYl33FTmGgbqdcqHXhdjm3eUNlXfb0tNauy8XqMRX711SwjUiGE6eGcJpgsyBvF1T1sK4IaAWONB0Sw0Z4w71nAw71Mef9SjrVRhZOxjYl3ifDE6iOrpEDyl)rcIEMovUth9egGcJpgsJR3r1XsCr0ZnAwl6zC9oQogPOZHfbn6XRdB5psq0Z0PYD6Ohm(yif7kKvIlcONobOW4JHKGX)vOy2(L4IONB0Sw0R95msrNNke0OhVoSL)ibrp3OzTONXT2RB0S2Rnjk6ztIExpMrptv2FfAjifDEAqqJE86Ww(Jee9CJM1IEdUltw4KlCQm6z6u5oD07xQStrPMM55EaOra0FPYofLnh75sa0PaOHhqJaOQ3hSk1mMVAD)jdObcOteiGgbqdcqv3YRkjom3AvkgjVoSL)aAWONzMXYx17dwjOZtqk680IGg941HT8hji65gnRf9gCxMSWjx4uz0Z0PYD6ON6wEvjXH5wRsXi51HT8hqJaOMkgUUIvUkbqdeqjIS1EvVpyLivmTtWCnUcOra0FPYofLAAMN7bGgbq)Lk7uu2CSNlbqNcGgEancGQEFWQuZy(Q19NmGgiG(lv2POS5ypxcGInGgG3PdBzzNIxnnZjaQqcOUrZALDkk10m)QzmJEMzglFvVpyLGopbPOZcqe0OhVoSL)ibrptNk3PJEMkgUUIvUkbqdeqNo65gnRf9A896gnR9AtIIE2KO31Jz0BKBsWWnbPOZteicA0Jxh2YFKGONB0Sw0RX3RB0S2Rnjk6ztIExpMrVdE521QjifPONyZMkg2ve0OZtqqJE86Ww(Jee9kr0JWk65gnRf9cW70HTm6fGBXz0tGOxaEFxpMrpCcFvmTtWGu0zHJGg941HT8hji6vIOhHv0ZnAwl6fG3PdBz0la3IZONWrptNk3PJEE4K7uzzO0(VdltW08(Z9qYRdB5p6fG331Jz0dNWxft7emifDo8iOrpEDyl)rcIELi6ryf9CJM1IEb4D6Wwg9cWT4m6nTOxaEFxpMrVofVAAMtqk680rqJE86Ww(Jee9mDQCNo6bJpgY4Q255Ehvhl)vOfqJaOQB5vLW2Q(QBRLi51HT8h9CJM1IEnF0vifdsrNdlcA0Jxh2YFKGONPtL70rpy8Xqgx1op37O6y5VcTONB0Sw0tSRqwKIopviOrpEDyl)rcIEMovUth9GXhdzCv78CVJQJL)k0IEUrZArpJR3r1XifDEAqqJEUrZArpXsZArpEDyl)rcIu05Pfbn6XRdB5psq0Z0PYD6Ohm(yiJRANN7DuDS8xHw0ZnAwl6bZnH75ifDwaIGg941HT8hji6z6u5oD0dgFmKXvTZZ9oQow(Rql65gnRf908GBYDG3ZqksrVdE521QjiOrNNGGg941HT8hji6z6u5oD0tDlVQe2w1xDBTejVoSL)aAeafgFmKIn)DT6zxsOCOltisCrancGcJpgsyBvF1T1sK)k0cOrautfdxxXkxLaOqa0PdOra0FPY2NZYMJ9Cja6ua0PJEUrZArVMp6kKIbPOZchbn6XRdB5psq0Z0PYD6ON6wEvjSTQV62AjsEDyl)b0iakm(yiHTv9v3wlr(RqlGgbqHXhdPyZFxRE2Lekh6YeIexeqJaOQB5vLw817BUeXSDnRvYRdB5pGgbq)LkBFolBo2ZLaOtbqNGEUrZArVMp6kKIbPOZHhbn6XRdB5psq0Z0PYD6OhrKT2R69bRejCJRU9sSobdGgiG(zs28)QEFWkb9CJM1IEWnU62lX6emifDE6iOrpEDyl)rcIEJQVlhgfDEc65gnRf9eRYEBMu4THrk6CyrqJE86Ww(Jee9mDQCNo6feG28Ozcgh2YaAWaAeaniaLiYw7v9(GvIuX0obZ14kGgiGkCany0ZnAwl6PyANG5ACfPOZtfcA0Jxh2YFKGO3O67YHrrNNGEUrZArpXQS3MjfEByKIopniOrpEDyl)rcIEMovUth9ccqv3YRkjgE1BnUW2Q(sEDyl)b0iakm(yijgE1BnUW2Q(YFfAb0Gb0iakrKT2R69bRePIPDcMRXvanqan8ONB0Sw0tX0obZ14ksrNNwe0OhVoSL)ibrVr13LdJIopb9CJM1IEIvzVntk82WifDwaIGg941HT8hji6z6u5oD0dgFmKedV6TgxyBvFjUiGE6eGgeG6gnRvscLI814Q87X(bdOcjGsezR9QEFWkrscLI814kGgiGgeG6gnRv2(Cw(9y)GbuSb0Gau3OzTY2NZsnnZV)4davib0WcObdObdObJEUrZArpsOuKVgxrk68ebIGg941HT8hji6nQ(UCyu05jONB0Sw0tSk7TzsH3ggPOZtMGGg941HT8hji65gnRf9AFoJEMovUth9egGQPzEUha6PtaAqaQWau1T8QsyBvF1T1sK86Ww(dOra0MJ9Cja6ua0pE7AwlGkKaQaLHhqdgqJaOQ3hSk1mMVAD)jdObcOth9mZmw(QEFWkbDEcsrNNiCe0OhVoSL)ibrVr13LdJIopb9CJM1IEIvzVntk82WifDEs4rqJE86Ww(Jee9CJM1IETpNrptNk3PJEQB5vLW2Q(QBRLi51HT8hqJaOW4JHe2w1xDBTejUiGgbqdcqdcqBo2ZLaOtbcGonaAWaAeavKBssuE1BmUvtrBYnGgiG(lv2(CwkgJB1u0MCdOcjGkq50gwanyancGQEFWQuZy(Q19NmGgiGoD0ZmZy5R69bRe05jifDEY0rqJE86Ww(Jee9mDQCNo6bJpgsyBvF1T1sK4IaAeafgFmKIn)DT6zxsOCOltiYFfAb0iaQPIHRRyLRsa0PaOHf9CJM1IEXvTJS5RXvKIopjSiOrpEDyl)rcIEMovUth9ccqHXhdPMhCtUd8EMexeqJaObbOTN)lhaVQ0)FImxanqaniaDcGInGg7H5AW49btauHaqny8(Gj3r7gnR1TaAWaQqcOnBW49bF1mMb0Gb0Grp3OzTOhCJRU9sSobdsrNNmviOrpEDyl)rcIEUrZArV4Q2r2814k6z6u5oD0R5rZemoSLrpZmJLVQ3hSsqNNGu05jtdcA0Jxh2YFKGO3O67YHrrNNGEUrZArpXQS3MjfEByKIopzArqJE86Ww(Jee9mDQCNo618Ozcgh2YaAeanianianaVth2YsCcFvmTtWaOqauHdOra0GauHbOW4JHmxJ3RRzTsCra90ja1dNCNkldL2)DyzcMM3FUhsEDyl)b0Gb0Gb0tNauIiBTx17dwjsft7emxJRaAGa6eany0ZnAwl6PyANG5ACfPOZteGiOrpEDyl)rcIEJQVlhgfDEc65gnRf9eRYEBMu4THrk6SWficA0Jxh2YFKGONPtL70rpIiBTx17dwjssOuKVgxb0ab0jONB0Sw0Jekf5RXvKIol8jiOrpEDyl)rcIEMovUth9(LkBFolBo2ZLaObcObbOUrZALemn)LMIOak2aQB0Swz7ZzPPikGkeakVCFmdqdgqdhbO8Y9XmzZh8cONobOW4JH0yzVnorZ9q2SBu0ZnAwl6rW08hPif9g5MemCtqqJopbbn6XRdB5psq0Z0PYD6Ohm(yifB(7A1ZUKq5qxMqK4IaAeavDlVQe2w1xDBTejVoSL)aAeafgFmKW2Q(QBRLijQBMdOtbqfo65gnRf9A(ORqkgKIolCe0OhVoSL)ibrVr13LdJIopb9CJM1IEIvzVntk82WifDo8iOrpEDyl)rcIEMovUth9GXhdjXdWp4BxEl)vOf9CJM1IEepa)GVD5nsrNNocA0Jxh2YFKGO3O67YHrrNNGEUrZArpXQS3MjfEByKIohwe0OhVoSL)ibrp3OzTONyNXU9gQDfd6z6u5oD0JiYw7v9(GvIuSZy3Ed1UIbqdeqNaOra0FPYofLnh75sa0PaOth9mZmw(QEFWkbDEcsrNNke0OhVoSL)ibrVr13LdJIopb9CJM1IEIvzVntk82WifDEAqqJE86Ww(Jee9CJM1IEIDg72BO2vmONPtL70rpIiBTx17dwjsXoJD7nu7kganqiaQWrpZmJLVQ3hSsqNNGu05Pfbn6XRdB5psq0Bu9D5WOOZtqp3OzTONyv2BZKcVnmsrNfGiOrpEDyl)rcIEUrZArVofrptNk3PJEcdqv3YRkjom3AvkgjVoSL)aAeaT5rZemoSLb0iaQ69bRsnJ5Rw3FYaAGa6VuzNIYMJ9Cjak2aAaENoSLLDkE10mNaOcjG6gnRv2POutZ8RMXm6zMzS8v9(Gvc68eKIoprGiOrpEDyl)rcIEJQVlhgfDEc65gnRf9eRYEBMu4THrk68KjiOrpEDyl)rcIEMovUth9u3YRkjom3AvkgjVoSL)aAeaniavyaQMM55EaONobOnh75sa0Pabq)4TRzTaQqcOcugEancGkYnjjkV6ng3QPOn5gqdeq)Lk7uukgJB1u0MCdObdOrau17dwLAgZxTU)Kb0ab0FPYofLnh75sauSb0a8oDyll7u8QPzobqfsaniaDcGInG(lv2POutZ8CpauHeqdpGgmGkKaQB0SwzNIsnnZVAgZONB0Sw0RtrKIopr4iOrpEDyl)rcIEJQVlhgfDEc65gnRf9eRYEBMu4THrk68KWJGg941HT8hji6z6u5oD0dgFmKepa)GVD5TS5ypxcGofaDIWrp3OzTOhXdWp4BxEJu05jthbn6XRdB5psq0Bu9D5WOOZtqp3OzTONyv2BZKcVnmsrNNewe0OhVoSL)ibrptNk3PJEW4JHm7AVHd8qejUi65gnRf9I9mgPOZtMke0OhVoSL)ibrVypmxE5(yg6nb9CJM1IEdUltw4KlCQm6zMzS8v9(Gvc68eKIu0ZuL9xHwccA05jiOrpEDyl)rcIEMovUth94L7JzaAGqa0WlqancGgeGAQY(RqRuZdUj3bEpt2CSNlbqdeqdlGE6eGcJpgsnp4MCh49mjUiGgm65gnRf9G5MW9CKIolCe0OhVoSL)ibrptNk3PJE8Y9Xm5NhPjvanqia6ujqa90jafgFmKAEWn5oW7zYFfArp3OzTONMhCtUd8EgsrNdpcA0ZnAwl6bZnH755EGE86Ww(JeePOZthbn6XRdB5psq0Z0PYD6ONB0ma(YlhNmbqdeq)mjB(FvVpyLaONobOTN)lhaVQ0)FImxanqaD6Hf9CJM1IEkMQxcsrNdlcA0Jxh2YFKGONPtL70rpy8Xq2SzULjK7OAdlXfb0tNauy8XqQ5b3K7aVNjXfrp3OzTONIHV4lCHV)7OAdJu05Pcbn6XRdB5psq0Z0PYD6Ohm(yi18GBYDG3ZK4IaAeafgFmKWCt4EU8xHw0ZnAwl6fZXvp7wJRf3K)7VzpMGu05Pbbn6XRdB5psq0Z0PYD6Ohm(yi18GBYDG3ZK4IONB0Sw0d2w1)wJRIHV8YXZqk680IGg941HT8hji6z6u5oD0ZuXW1vSYvjakeavGONB0Sw0BWTBVJM3W5mKIolarqJE86Ww(Jee9mDQCNo65gndGV8YXjta0ab0ptYM)x17dwja6PtaAqaA75)YbWRk9)NiZfqdeqfGceqJaO8Y9Xm5NhPjvanqiaAyfiGgm65gnRf9gLbNW)Rho5ov(cZEmsrNNiqe0OhVoSL)ibrptNk3PJEUrZa4lVCCYeanqa9ZKS5)v9(GvcGE6eG2E(VCa8Qs))jYCb0ab0PsGONB0Sw0teVZXSCpUWwNOifDEYee0OhVoSL)ibrptNk3PJE8Y9XmanqiaA4fiGgbqdcqnvz)vOvQ5b3K7aVNjBo2ZLaObcOtclGE6eGcJpgsnp4MCh49mjUiGgm65gnRf9Y1496AwlsrNNiCe0OhVoSL)ibrptNk3PJEQ3hSk1mMVAD)jdOtbqNQWcONobObbOAgZxTU)Kb0PaOtMwbcOra0Gauy8XqcZnH75sCra90jafgFmK5A8EDnRvIlcObdObJEUrZArpXsZArk68KWJGg941HT8hji6z6u5oD0ZuXW1vSYvja6ua0WcOrauE5(ygGgiea1nAwRS95S0uefqJaO)sLTpNLIX4wnfTj3a6uauHlNaOrauy8XqQ5b3K7aVNjXfb0iaAqakm(yiHTv9v3wlrIlcONobOcdqv3YRkHTv9v3wlrYRdB5pGgmGgbqdcqfgGQULxvMRX711SwjVoSL)a6PtaQPk7VcTYCnEVUM1kBo2ZLaObcOtMwanyancGkmafgFmK5A8EDnRvIlIEUrZArpcg)xHIz7hPOZtMocA0ZnAwl6Ht4BQCmb941HT8hjisrksrphxXun69YybeKIueca]] )
    
end
