-- DruidFeral.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

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
        blood_scent = 22363, -- 202022
        predator = 22364, -- 202021
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
        jagged_wounds = 18579, -- 202032
        incarnation = 21704, -- 102543

        sabertooth = 21714, -- 202031
        brutal_slash = 21711, -- 202028
        savage_roar = 22370, -- 52610

        moment_of_clarity = 21646, -- 236068
        bloodtalons = 21649, -- 155672
        feral_frenzy = 21653, -- 274837
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3432, -- 214027
        relentless = 3433, -- 196029
        gladiators_medallion = 3431, -- 208683
        
        protector_of_the_grove = 847, -- 209730
        thorns = 201, -- 236696
        earthen_grasp = 202, -- 236023
        freedom_of_the_herd = 203, -- 213200
        malornes_swiftness = 601, -- 236012
        king_of_the_jungle = 602, -- 203052
        enraged_maim = 604, -- 236026
        savage_momentum = 820, -- 205673
        ferocious_wound = 611, -- 236020
        fresh_wound = 612, -- 203224
        rip_and_tear = 620, -- 203242
        tooth_and_claw = 3053, -- 236019
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
            duration = 15,
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
        moonfire_cat = {
            id = 155625, 
            duration = 16
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
        prowl = {
            id = 5215,
            duration = 3600,
        },
        rake = {
            id = 155722, 
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end,
            tick_time = function()
                local x = 3 -- Base Tick
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end,
        },
        regrowth = { 
            id = 8936, 
            duration = 12,
        },
        rip = {
            id = 1079,
            duration = function()
                local x = 24 --Base duration
                    return ( talent.jagged_wounds.enabled and x * 0.80 or x )
            end,
        },
        savage_roar = {
            id = 52610,
            duration = 36,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
        },
        survival_instincts = {
            id = 61336,
        },
        thrash_bear = {
            id = 192090,
            duration = 15,
            max_stack = 3,
        },
        thrash_cat ={
            id = 106830, 
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        },
        thrash = {
            id = function ()
                if buff.cat_form.up then return 106830 end
                return 192090
            end,
        },
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
                local x = 8 -- Base Duration
                if talent.predator.enabled then return x + 4 end
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
    } )


    spec:RegisterStateExpr( 'gcd', function()
        return buff.cat_form.up and 1.0 or max( 0.75, 1.5 * haste )
    end )


    local tf_spells = { rake = true, rip = true, thrash = true, moonfire_cat = true }
    local bt_spells = { rake = true, rip = true, thrash = true }
    local mc_spells = { thrash = true }
    local pr_spells = { rake = true }

    local modifiers = {
        [1822]   = 155722,
        [1079]   = 1079,
        [106830] = 106830,
        [8921]   = 155625
    }


    local stealth_dropped = 0

    local function calculate_multiplier( spellID )

        local tigers_fury = FindUnitBuffByID( "player", class.auras.tigers_fury.id, nil, "PLAYER" )
        local bloodtalons = FindUnitBuffByID( "player", class.auras.bloodtalons.id, nil, "PLAYER" )
        local clearcasting = FindUnitBuffByID( "player", class.auras.clearcasting.id, nil, "PLAYER" )
        local prowling = GetTime() - stealth_dropped < 0.2 or FindUnitBuffByID( "player", class.auras.incarnation.id, nil, "PLAYER" )

        if spellID == 155722 then
            return 1 * ( prowling and 2 or 1 ) * ( bloodtalons and 1.2 or 1 ) * ( tigers_fury and 1.15 or 1 )

        elseif spellID == 1079 then
            return 1 * ( bloodtalons and 1.2 or 1 ) * ( tigers_fury and 1.15 or 1 )

        elseif spellID == 106830 then
            return 1 * ( clearcasting and 1.2 or 1 ) * ( bloodtalons and 1.2 or 1 ) * ( tigers_fury and 1.15 or 1 )

        elseif spellID == 155625 then
            return 1 * ( tigers_fury and 1.15 or 1 )

        end

        return 1
    end

    spec:RegisterStateExpr( 'persistent_multiplier', function ()
        local mult = 1

        if not this_action then return mult end

        if tf_spells[ this_action ] and buff.tigers_fury.up then mult = mult * 1.15 end
        if bt_spells[ this_action ] and buff.bloodtalons.up then mult = mult * 1.20 end
        if mc_spells[ this_action ] and buff.clearcasting.up then mult = mult * 1.20 end
        if pr_spells[ this_action ] and ( buff.incarnation.up or buff.prowl.up or buff.shadowmeld.up or state.query_time - stealth_dropped < 0.2 ) then mult = mult * 2.00 end

        return mult
    end )


    local snapshots = {
        [155722] = true,
        [1079]   = true,
        [106830] = true,
        [155625] = true
    }

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
        if state.buff.cat_form.down then
            state.energy.regen = 10 + ( state.stat.haste * 10 )
        end
        state.debuff.rip.pmultiplier = nil
        state.debuff.rake.pmultiplier = nil
        state.debuff.thrash.pmultiplier = nil
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
            
            startsCombat = false,
            texture = 132276,
            
            noform = "bear_form",
            handler = function () shift( "bear_form" ) end,
        },
        

        berserk = {
            id = 106951,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 236149,
            
            form = "cat_form",
            notalent = "incarnation",

            toggle = "cooldowns",

            handler = function ()
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

                local x = 30
                if buff.scent_of_blood.up then x = x + buff.scent_of_blood.v1 end
                return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )
            end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132141,
            
            form = "cat_form",
            usable = function () return active_enemies > 2 or charges_fractional > 2.5 end,
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
            
            noform = "cat_form",
            handler = function ()
                shift( "cat_form" ) 
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
            
            handler = function ()
                gain( 25, "energy" )
                spend( min( 5, combo_points.current ), "combo_points" )
                removeBuff( "apex_predator" )
                removeStack( "bloodtalons" )

                if ( target.health_pct < 25 or talent.sabertooth.enabled ) and debuff.rip.up then
                    debuff.rip.expires = query_time + min( debuff.rip.remains + debuff.rip.duration, debuff.rip.duration * 1.3 )
                end
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
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 571586,

            toggle = "cooldowns",
            
            handler = function ()
                shift( "cat_form" )
                applyBuff( "incarnation" )
                applyBuff( "jungle_stalker" )
                energy.max = energy.max + 50 
            end,
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
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135753,
            
            form = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                removeBuff( "starsurge" )
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
                spend( combo_points.current, "combo_points" )
                removeStack( "bloodtalons" )
            end,
        },
        

        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            spend = -8,
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


            recheck = function () return dot.moonfire_cat.remains - dot.moonfire_cat.duration * 0.3, dot.moonfire_cat.remains end,
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
        

        prowl = {
            id = 5215,
            cast = 0,
            cooldown = function ()
                if buff.prowl.up then return 0 end
                return 6
            end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 514640,
            
            nobuff = "prowl",
            
            usable = function () return time == 0 or boss or buff.jungle_stalker.up end,
            recheck = function () return buff.incarnation.remains - 0.1 end,
            handler = function ()
                shift( "cat_form" )
                applyBuff( "prowl" )
            end,
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
            
            form = "cat_form",

            recheck = function () return dot.rake.remains - dot.rake.duration * 0.3, dot.rake.remains end,
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
                if buff.predator_swiftness.up then return 0 end
                return 1.5 * haste
            end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.14,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136085,
            
            usable = function ()
                if not talent.bloodtalons.enabled then return false end
                if buff.bloodtalons.up then return false end
                if buff.cat_form.down or not buff.prowl.up then return buff.predatory_swiftness.up or time == 0 end
                return false
            end,
            handler = function ()
                if buff.predatory_swiftness.down then unshift() end
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
            form = "cat_form",
            
            usable = function () return combo_points.current > 0 end,
            recheck = function () return dot.rip.remains - dot.rip.duration * 0.3, dot.rip.remains end,
            handler = function ()
                spend( combo_points.current, "combo_points" )

                applyDebuff( "target", "rip", min( 1.3 * class.auras.rip.duration, debuff.rip.remains + class.auras.rip.duration ) )
                debuff.rip.pmultiplier = persistent_multiplier
                removeStack( "bloodtalons" )
            end,
        },
        

        savage_roar = {
            id = 52610,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 30 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",
            
            startsCombat = false,
            texture = 236167,
            
            talent = "savage_roar",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                local cost = min( 5, combo_points.current )
                spend( cost, "combo_points" )

                applyBuff( "savage_roar", 6 + ( 6 * cost ) )
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
            
            usable = function () return target.casting end,
            handler = function ()
                interrupt()
            end,
        },
        

        solar_wrath = {
            id = 197629,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = true,
            texture = 535045,

            form = "moonkin_form",
            talent = "balance_affinity",
            
            handler = function ()
                removeBuff( "starsurge" )
            end,
        },
        

        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = false,
            texture = 132163,
            
            handler = function ()
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
                applyBuff( "starsurge" )
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
                return 40 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )
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

            copy = 213764,
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
        

        thrash_cat = {
            id = 106830,
            known = 106832,
            suffix = "(Cat)",
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.clearcasting.up then return 0 end
                return 45 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )
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

            spend = -40,
            spendType = "energy",
            
            startsCombat = false,
            texture = 132242,

            nobuff = "tigers_fury",
            handler = function ()
                shift( "cat_form" )
                applyBuff( "tigers_fury", talent.predator.enabled and 14 or 10 )
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


    -- Override this for rechecking.
    spec:RegisterAbility( "shadowmeld", {
        id = 58984,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        recheck = function () return energy[ "time_to_" .. action.rake.cost ], energy[ "time_to_" .. ( action.rake.cost + 1 ) ], buff.incarnation.remains - 0.1, buff.incarnation.remains end,
        usable = function () return boss and race.night_elf end,
        handler = function ()
            applyBuff( "shadowmeld" )
        end,
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        package = "Feral"
    } )


    spec:RegisterPack( "Feral", 20180712.2230, [[dW0H5aqiQeweskYJOsQQlbfs1MOI(essJIkLtrLQvPqsVck1SOcDlfczxu1VGIggOuhtbTmOGNrLOPPq01qsSnQKY3uiyCkK6CiPuRtHeZdjv3tv1(qIoiskzHqjxejfYgPsQYhrsrDsfc1kfsZekuDtOqk2Pc8tOqknuKuGLcfsEQkMQc1vrsH6RujvSwQKkTxG)cYGj1HPSyv5XcMSkDzuBwrFwOgTQYPvA1iPGEnvWSj52GQDl1VfnCK64qHy5sEoKPtCDOA7Gs(UqmEQKCEKW6HcL5dk2pIbdbJbNRjmyagG9Wrd7ryig8yadUC4WraCekOzWH2coyXm40gCgCC94YuGdTrHkTlym4Gs8kWGZNi0OrbtmPnKWVT9HeoMUUWY19Z192udaNh(QKrCdEGZ1egmadWE4OH9imedEmGbmm6roeCq0CamyiSDj4CzuaCg)TiIEreT8Xe9LNgUsiAAl4GfZe9mlI21Jltr0Bt0yzIOyIEMfrtTWyCLYNNeLeLAr0XfBcrFztr05KOLpMOJKLdeTKenIfIgNMOD94YueDedr0HeoTIf(s0pkiAmABffn7jrjrh6jAIgJMew8LOPMORmIIAIOF8mlMOPMcManZco1erVnrtxCiH)mHOPwudW4enA7at0uK4e9nBQkeDXMsrbr3mFjAjjACet0btGMzbNO3jrtrIt0i8qGrOjUsrbrtxzefF9GdDLZvXGJRprtnYvCax4lr)4zwmrhs4pti6hhVnYt0uRqGPfer3zpI(Sc(exr0wq2SreD2kk8KOwq2SrE6Idj8Nj)tLHCGe1cYMnYtxCiH)mb7FmNzEjrTGSzJ80fhs4ptW(htdpgo3IjB2KOwq2SrE6Idj8Njy)JzXXvgr(CCN)IP4w8pvMxXuzJ8CBpfFjrTGSzJ80fhs4ptW(ht6kJOirTGSzJ80fhs4ptW(hZGjqZSGtI66t0N2OrFPq0LTxI(HpN8LOrIjiI(XZSyIoKWFMq0poEBerB9LOPlEerNISDmrViI(Mn7jrTGSzJ80fhs4ptW(htuB0OVuGqIjisuliB2ipDXHe(ZeS)XKoLnBsuliB2ipDXHe(ZeS)XewwT2tXo2gC(hhXqYxzOphHLPW5FytIAbzZg5PloKWFMG9pMWYQ1Ek2X2GZ)4igs(kd95iSmfo)p0XD(Zye8LMMVEf(CAqrkJME7yejkjQRprtnYvCax4lrZWIlkiAzHZeT8XeTfKSi6fr0gSSvzpf7jrTGSzJW(hZcVHSGSzdPwK4yBW5F02XkgsSkMfh35VfKfwm0nfFT0ucByGrw4mLdPcjQfKnBe2)ywMdSJ783fYgCy7yyG5HpNE6kJO840KOwq2Sry)J51qFoUZFx8WNtFWeOzwW940KOwq2Sry)JPHljKjIfCGe1cYMnc7FmHNzp3IHcM44o)ftXT4v4TvqBJO3YKnBp32tXxNUq2GdBhtIAbzZgH9pMidwwmdvPvoUZFx8WNtpYGLfZqvALhNMe1cYMnc7FmFCH4YbsuliB2iS)XC7GvTjB2KOwq2Sry)JPSXCHGM4ffKOwq2Sry)J5KltbnlUXyuqIAbzZgH9pMfhxze5ZXD(7MykUfpYECjzkFEUTNIVWaZdFo90fFnjlkGqr2P0mc5XPD3PykUf)tL5vmv2ip32tXxNp850)uzEftLnYFZiTZqc)Lq052c6NkKOwq2Sry)JzT0oUZ)qc)Lq052c6NkKOwq2Sry)JP8vg6dkyIJ783fYgCy7yNWYQ1Ek2JJyi5Rm0hLWMe1cYMnc7FmFfUykiKYqFoUZFenRuqIvXSG8VcxmfeszOpkhsIAbzZgH9pMOilndfmXXD(JOzLcsSkMfKhfzPzOGjuoKe1cYMnc7FmrFfFjrjrTGSzJ8Hmv3msJ(Vg6ZXD(7Ih(C6dManZcUhNMe1cYMnYhYuDZinc7FmPRmIYXD()WNt)2bRAt2S9fd32grDy7PIZh(C6PgI3XkgcjMYbU840KOwq2Sr(qMQBgPry)J5Jlexo44o)5MRykO83LW2PBHmv3ms7LnMle0eVOWxmCBBeLubgyE4ZPx2yUqqt8IcpoT7KOwq2Sr(qMQBgPry)JPSXCHGM4ffoUZFU5kMc)LNByfk)DnytIAbzZg5dzQUzKgH9pMpUqC5W2XKOwq2Sr(qMQBgPry)J52bRAt2SDCN)CZvmfu(7sy70TqMQBgP9YgZfcAIxu4lgUTnIYHubgyE4ZPx2yUqqt8IcpoT7KOwq2Sr(qMQBgPry)JjDkB2o2gC(NUsv2X8fIoJWLJ78xSkMfVSWzijHUltDxJkWaJBYcNHKe6Um1hoAy70Th(C6FCH4YbponmW8WNt)2bRAt2S940U7ojQfKnBKpKP6MrAe2)yo5YuqZIBmgfoUZ)qc)Lq052cIYFm40nxiMIBX)uzEftLnYZT9u8fgyE4ZP)PY8kMkBKhN2DsuliB2iFit1nJ0iS)Xe9z3mcCwDDCN)He(lHOZTfe1PItU5kMck)TGSz7lZb2hsK48MIVmhypnCCLS0QLlQJb)qNp850lBmxiOjErHhN2PBp850)uzEftLnYJtddmUqmf3I)PY8kMkBKNB7P4R7oDZfIP4w8BhSQnzZ2ZT9u8fgyczQUzK2VDWQ2KnBFXWTTruoC0U70fp850VDWQ2KnBponjQfKnBKpKP6MrAe2)yIJyOvy4isusuliB2ipA7yfdjwfZYFWeOzwWDCN)U4HpN(GjqZSG7XPjrTGSzJ8OTJvmKyvmly)JzzoWoUZ)h(C6PRmIYJtddmp850J(SBgboRUECAsuliB2ipA7yfdjwfZc2)yA4sczIybhirTGSzJ8OTJvmKyvmly)JzWukiliB2qQfjo2gC(pKP6MrAejQfKnBKhTDSIHeRIzb7FmNCLHnXrqVvyhfRIzbAN)3u81s7Ln4W2XoVP4RL2xmCBBe1DPtXQyw8YcNHKe6UmLdHTt3eRIzX)XMs(80bH6yGkWaJykUfpYECjzkFEUTNIVUtIAbzZg5rBhRyiXQywW(hZIJRmI854o)dj8xcrNBlOFQ48HpNE6IVMKffqOi7uAgH840oftXT4FQmVIPYg552Ek(68HpN(NkZRyQSr(BgPD6MlE4ZPF7GvTjB2ECAyG5MIVwAFXWTTruF0UtIAbzZg5rBhRyiXQywW(hZIJRmI854o)dj8xcrNBlikDPtXuCl(NkZRyQSrEUTNIVoF4ZPNU4RjzrbekYoLMripoTZh(C6nA2vq0fFnjlpoTZh(C63oyvBYMT)MrAsuliB2ipA7yfdjwfZc2)yo5kdBIJGERWoUZ)h(C6nA2vq0fFnjlpoTt3ClKWFjeDUTGOCKoD7HpN(Tdw1MSz7XPHbgXuClE4jCUfOCcfuwTcfEUTNIVU7omW4MykUf)tL5vmv2ip32tXxNp850)uzEftLnYJt7mKWFjeDUTGO0LU7ojQfKnBKhTDSIHeRIzb7Fml8gYcYMnKArIJTbN)rc0C7f9XfYXD(hs4VeIo3wquossuliB2ipA7yfdjwfZc2)yw4nKfKnBi1IehBdo)JeOyU5YKSqKOKOwq2SrEKan3ErFCH(PZubvmkXRa74mlOMDL8pKe1cYMnYJeO52l6Jle2)yImyzXmuLw54o)F4ZPhzWYIzOkTYFZinjQfKnBKhjqZTx0hxiS)XKotfuXOeVcSJZSGA2vY)qsuliB2ipsGMBVOpUqy)JzT0okwfZc0o)DHSbh2oggyCRy422iQ)FXlt2Shvy7DP7oDtSkMf)hBk5ZthekXavC6cXuClEK94sYu(8CBpfFDhgyCRy422iQ)FXlt2Shvy7hTtAUqls4wGGJRKLwTCr5nfFT0EA44kzPvlxU7uSkMfVSWzijHUlt5OjrTGSzJ8ibAU9I(4cH9pM0zQGkgL4vGDCMfuZUs(hsIAbzZg5rc0C7f9Xfc7FmrgSSygQsRCCN)p850JmyzXmuLw5lgUTnI6dXajQfKnBKhjqZTx0hxiS)XCYvg2ehb9wHDeU5kiU5kMI)HKOKOwq2SrEKafZnxMKf6V44kJiFoUZFXuCl(NkZRyQSrEUTNIVoF4ZPNU4RjzrbekYoLMripoTZh(C6FQmVIPYg5VzK2ziH)si6CBbr5pgCgYuDZiTFYLPGMf3ymk8fd32gr94WLe1cYMnYJeOyU5YKSqy)JzXXvgr(CCN)IP4w8pvMxXuzJ8CBpfFD(WNtpDXxtYIciuKDknJqECANp850)uzEftLnYFZiTZqc)Lq052c6FKoVP4lZb2xmCBBe1hjjQfKnBKhjqXCZLjzHW(hZIJRmI854o)zmc(stZxVTk8kHOt8oWfYPykUf)tL5vmv2ip32tXxNU9WNtpDXxtYIciuKDknJqEKybhOedWaJBp850tx81KSOacfzNsZiKhjwWbkh68MIVmhyFXWTTru3LU7UZh(C6FQmVIPYg5VzKMe1cYMnYJeOyU5YKSqy)J5RWftbHug6ZXD(JOzLcsSkMfK)v4IPGqkd9r5LrBXxiXQywqKOwq2SrEKafZnxMKfc7FmPZubvmkXRa74mlOMDL8pKe1cYMnYJeOyU5YKSqy)JP8vg6dkyIJ78V4zXOp7PyNUHOzLcsSkMfKx(kd9bfmHsm4ojQfKnBKhjqXCZLjzHW(ht6mvqfJs8kWooZcQzxj)djrTGSzJ8ibkMBUmjle2)ykFLH(GcM44o)r0SsbjwfZcYlFLH(GcMqPlDYye8LMMVEf(CAqrkJME7yKtXuCl(xHlMccPm0NNB7P4ljQfKnBKhjqXCZLjzHW(ht6mvqfJs8kWooZcQzxj)djrTGSzJ8ibkMBUmjle2)ywMdSJIvXSaTZFxiBWHTJHbg3CHykUf)tL5vmv2ip32tXxNfd32gr9lEzYM9OcBVlD3PyvmlEzHZqscDxMYrsIAbzZg5rcum3CzswiS)XKotfuXOeVcSJZSGA2vY)qsuliB2ipsGI5MltYcH9pML5a7Oyvmlq78xmf3I)PY8kMkBKNB7P4RZh(C6FQmVIPYg5XPD6MBfd32gr9)rWDN0CHwKWTabhxjlTA5IYBk(YCG90WXvYsRwUgvy7hnvC3PyvmlEzHZqscDxMYrsIAbzZg5rcum3CzswiS)X8v4IPGqkd954o)D7HpNEzJ5cbnXlk840oDRS9cXWIBXB3lYVnLUneB4MRGcFwfZOru4ZQygbnlliB2MY9rT4WNvXmKSWz3DNe1cYMnYJeOyU5YKSqy)Jj8m75wmuWehfRIzbAN)fplg9zpftIAbzZg5rcum3CzswiS)XKotfuXOeVcSJZSGA2vY)qsuliB2ipsGI5MltYcH9pMYxzOpOGjoUZ)INfJ(SNID6gSSATNI94igs(kd99JbyGbrZkfKyvmliV8vg6dkycLdDNe1cYMnYJeOyU5YKSqy)JP8vg6dkyIJ78V4zXOp7PyNWYQ1Ek2JJyi5Rm03)qNp850huSvbdjBh7l2ccjQfKnBKhjqXCZLjzHW(ht6mvqfJs8kWooZcQzxj)djrTGSzJ8ibkMBUmjle2)yIIS0muWeh35pIMvkiXQywqEuKLMHcMq5qsuliB2ipsGI5MltYcH9pMOVIVoUZ)Bk(YCG9fd32grPBwq2S9OVIV(qIeSTGSz7lZb2hsKmI4MRykChJo3CftHV4yUHbMh(C6dk2QGHKTJ9fBbbCGfxOnBWama7HJg2UgggbpSP2ubCIyvVDmcCCDOwyudgXdOMhfIMOh)Xe9cNolHONzr0ufTDSIHeRIzHQeDXye8T4lrJs4mrB4sc3e(s0HpRJzKNefJVnt0UCuiAQXncNMolHVeTfKnBIMQgUKqMiwWbQ6jrjrDDOwyudgXdOMhfIMOh)Xe9cNolHONzr0u9YtdxjuLOlgJGVfFjAucNjAdxs4MWxIo8zDmJ8KOy8TzIEKJcrtnUr400zj8LOTGSzt0u1WLeYeXcoqvpjkjQRd1cJAWiEa18Oq0e94pMOx40zje9mlIMQHmv3msJOkrxmgbFl(s0Oeot0gUKWnHVeD4Z6yg5jrX4BZeTlhfIE83IiAULIcIo8XbhqeT8XeDit1nJ0e9mlIMQHmv3ms7LnMle0eVOWxmCBBevj6iFB4JOdwt0pMOlgHReIEBIoVxI(XFgS2Si6Ds0unKP6MrAVSXCHGM4ff(IHBBJOkrViIwY4yfFj6CoX8Ui7P4RNefJVnt0U2Oq0J)werZTuuq0Hpo4aIOLpMOdzQUzKMONzr0unKP6MrAVSXCHGM4ff(IHBBJOkrh5BdFeDWAI(XeDXiCLq0Bt059s0p(ZG1MfrVtIMQHmv3ms7LnMle0eVOWxmCBBevj6fr0sghR4lrNZjM3fzpfF9KOy8TzIMApke94Vfr0ClffeD4JdoGiA5Jj6qMQBgPj6zwenvdzQUzK2VDWQ2KnBFXWTTruLOJ8THpIoynr)yIUyeUsi6Tj68Ej6h)zWAZIO3jrt1qMQBgP9BhSQnzZ2xmCBBevj6fr0sghR4lrNZjM3fzpfF9KOKOUoulmQbJ4buZJcrt0J)yIEHtNLq0ZSiAQIeOyU5YKSquLOlgJGVfFjAucNjAdxs4MWxIo8zDmJ8KOy8TzIE4Oq0J)werZTuuq0Hpo4aIOLpMOdzQUzKMONzr0unKP6MrA)KltbnlUXyu4lgUTnIQeDKVn8r0bRj6ht0fJWvcrVnrN3lr)4pdwBwe9ojAQgYuDZiTFYLPGMf3ymk8fd32grvIEreTKXXk(s05CI5Dr2tXxpjkgFBMOh5Oq0yumTYc8LOP6LrBXxiXQywquLOJSYhrt1HuLODBORC3tIsIoIHtNLWxI21iAliB2eTArcYtIcoQfjiWyWbTDSIHeRIzbmgmyiym4WT9u8fGf4eQv4AnWXfe9dFo9btGMzb3Jtdowq2SbNGjqZSGdeWamagdoCBpfFbyboHAfUwdCE4ZPNUYikponrddme9dFo9Op7MrGZQRhNgCSGSzdoL5adeWaxcgdowq2Sbhdxsitel4a4WT9u8fGfqadgjym4WT9u8fGf4ybzZgCcMsbzbzZgsTibCulsGAdodoHmv3msJacyavaJbhUTNIVaSaNqTcxRbo3u81s7Ln4W2XoVP4RL2xmCBBe1DPtXQyw8YcNHKe6UmLdHTt3eRIzX)XMs(80bH6yGkWaJykUfpYECjzkFEUTNIVUdowq2SbNjxzytCe0BfgiGbUgym4WT9u8fGf4eQv4AnWjKWFjeDUTGi6FIMkeTtI(HpNE6IVMKffqOi7uAgH840eTtIwmf3I)PY8kMkBKNB7P4lr7KOF4ZP)PY8kMkBK)MrAI2jr7gr7cI(HpN(Tdw1MSz7XPjAyGHOVP4RL2xmCBBertDIE0eT7GJfKnBWP44kJiFabmyeaJbhUTNIVaSaNqTcxRboHe(lHOZTfertjr7sI2jrlMIBX)uzEftLnYZT9u8LODs0p850tx81KSOacfzNsZiKhNMODs0p850B0SRGOl(AswECAI2jr)WNt)2bRAt2S93msdowq2SbNIJRmI8beWGrdgdoCBpfFbyboHAfUwdCE4ZP3Ozxbrx81KS840eTtI2nI2nIoKWFjeDUTGiAkj6rs0ojA3i6h(C63oyvBYMThNMOHbgIwmf3IhEcNBbkNqbLvRqHNB7P4lr7or7orddmeTBeTykUf)tL5vmv2ip32tXxI2jr)WNt)tL5vmv2iponr7KOdj8xcrNBliIMsI2LeT7eT7GJfKnBWzYvg2ehb9wHbcya1gmgC42Ek(cWcCc1kCTg4es4VeIo3wqenLe9ibhliB2GtH3qwq2SHulsah1IeO2GZGdsGMBVOpUqabmyiSbJbhUTNIVaSahliB2GtH3qwq2SHulsah1IeO2GZGdsGI5MltYcbeGaoxEA4kbmgmyiym4WT9u8fGf4eQv4AnWXcYclg6MIVwAIMsIg2enmWq0YcNjAkj6HubCSGSzdofEdzbzZgsTibCulsGAdodoOTJvmKyvmlabmadGXGd32tXxawGtOwHR1ahxq0YgCy7yIggyi6h(C6PRmIYJtdowq2SbNYCGbcyGlbJbhUTNIVaSaNqTcxRboUGOF4ZPpyc0ml4ECAWXcYMn4Cn0hqadgjym4ybzZgCmCjHmrSGdGd32tXxawabmGkGXGd32tXxawGtOwHR1ahXuClEfEBf02i6TmzZ2ZT9u8LODs0UGOLn4W2XGJfKnBWbEM9ClgkycqadCnWyWHB7P4lalWjuRW1AGJli6h(C6rgSSygQsR840GJfKnBWbzWYIzOkTciGbJaym4ybzZgCECH4YbWHB7P4lalGagmAWyWXcYMn4SDWQ2KnBWHB7P4lalGagqTbJbhliB2GJSXCHGM4ffGd32tXxawabmyiSbJbhliB2GZKltbnlUXyuaoCBpfFbybeWGHdbJbhUTNIVaSaNqTcxRboUr0IP4w8i7XLKP8552Ek(s0Wadr)WNtpDXxtYIciuKDknJqECAI2DI2jrlMIBX)uzEftLnYZT9u8LODs0p850)uzEftLnYFZinr7KOdj8xcrNBliI(NOPc4ybzZgCkoUYiYhqadgIbWyWHB7P4lalWjuRW1AGtiH)si6CBbr0)envahliB2GtT0abmyOlbJbhUTNIVaSaNqTcxRboUGOLn4W2XeTtIgwwT2tXECedjFLH(iAkjAydowq2Sbh5Rm0huWeGagmCKGXGd32tXxawGtOwHR1ahenRuqIvXSG8VcxmfeszOpIMsIEi4ybzZgCEfUykiKYqFabmyivaJbhUTNIVaSaNqTcxRboiAwPGeRIzb5rrwAgkycrtjrpeCSGSzdoOilndfmbiGbdDnWyWXcYMn4G(k(coCBpfFbybeGao0fhs4ptaJbdgcgdoCBpfFbybeWamagdoCBpfFbybeWaxcgdoCBpfFbybeWGrcgdoCBpfFbyboHAfUwdCetXT4FQmVIPYg552Ek(cowq2SbNIJRmI8beWaQagdowq2Sbh6kJOahUTNIVaSacyGRbgdowq2SbNGjqZSGdoCBpfFbybeWGramgC42Ek(cWciGbJgmgCSGSzdo0PSzdoCBpfFbybeWaQnym4WT9u8fGf4altHZGdSbhliB2GdSSATNIbhyzfuBWzWbhXqYxzOpGagme2GXGd32tXxawGJfKnBWbwwT2tXGdSmfododbNqTcxRbomgbFPP5RxHpNguKYOP3ogboWYkO2GZGdoIHKVYqFabiGtit1nJ0iWyWGHGXGd32tXxawGtOwHR1ahxq0p850hmbAMfCpon4ybzZgCUg6diGbyamgC42Ek(cWcCc1kCTg48WNt)2bRAt2S9fd32gr0uNOHTNkeTtI(HpNEQH4DSIHqIPCGlpon4ybzZgCORmIciGbUemgC42Ek(cWcCc1kCTg4WnxXuq0u(t0Ue2eTtI2nIoKP6MrAVSXCHGM4ff(IHBBJiAkjAQq0Wadr)WNtVSXCHGM4ffECAI2DWXcYMn484cXLdabmyKGXGd32tXxawGtOwHR1ahU5kMc)LNByfIMYFI21Gn4ybzZgCKnMle0eVOaiGbubmgCSGSzdopUqC5W2XGd32tXxawabmW1aJbhUTNIVaSaNqTcxRboCZvmfenL)eTlHnr7KODJOdzQUzK2lBmxiOjErHVy422iIMsIEiviAyGHOF4ZPx2yUqqt8Icponr7o4ybzZgC2oyvBYMnqadgbWyWHB7P4lalWjuRW1AGJyvmlEzHZqscDxMOPor7AuHOHbgI2nIww4mKKq3LjAQt0dhnSjANeTBe9dFo9pUqC5GhNMOHbgI(HpN(Tdw1MSz7XPjA3jA3bh6u2Sbh6kvzhZxi6mcxGJfKnBWHoLnBGagmAWyWHB7P4lalWjuRW1AGtiH)si6CBbr0u(t0yGODs0Ur0UGOftXT4FQmVIPYg552Ek(s0Wadr)WNt)tL5vmv2iponr7o4ybzZgCMCzkOzXngJcGagqTbJbhUTNIVaSaNqTcxRboHe(lHOZTfertDIMkeTtIMBUIPGOP8NOTGSz7lZb2hsKq0oj6Bk(YCG90WXvYsRwUiAQt0yWpKODs0p850lBmxiOjErHhNMODs0Ur0p850)uzEftLnYJtt0Wadr7cIwmf3I)PY8kMkBKNB7P4lr7or7KODJODbrlMIBXVDWQ2KnBp32tXxIggyi6qMQBgP9BhSQnzZ2xmCBBertjrpC0eT7eTtI2fe9dFo9BhSQnzZ2Jtdowq2Sbh0NDZiWz1fiGbdHnym4ybzZgCWrm0kmCe4WT9u8fGfqac4GeO52l6JleymyWqWyWHB7P4lalWzMfuZUsadgcowq2Sbh6mvqfJs8kWabmadGXGd32tXxawGtOwHR1aNh(C6rgSSygQsR83msdowq2SbhKbllMHQ0kGag4sWyWHB7P4lalWzMfuZUsadgcowq2Sbh6mvqfJs8kWabmyKGXGd32tXxawGtOwHR1ahxiBWHTJHbg3kgUTnI6)x8YKn7rf2Ex6Ut3eRIzX)XMs(80bHsmqfNUqmf3IhzpUKmLpp32tXx3Hbg3kgUTnI6)x8YKn7rf2(r7KMl0IeUfi44kzPvlxuEtXxlTNgoUswA1YL7ofRIzXllCgssO7YuoAWXcYMn4ulnqadOcym4WT9u8fGf4mZcQzxjGbdbhliB2GdDMkOIrjEfyGag4AGXGd32tXxawGtOwHR1aNh(C6rgSSygQsR8fd32gr0uNOhIbWXcYMn4GmyzXmuLwbeWGramgCGBUcIBUIPaCgcowq2SbNjxzytCe0BfgC42Ek(cWciabCqcum3CzswiWyWGHGXGd32tXxawGtOwHR1ahXuCl(NkZRyQSrEUTNIVeTtI(HpNE6IVMKffqOi7uAgH840eTtI(HpN(NkZRyQSr(BgPjANeDiH)si6CBbr0u(t0yGODs0Hmv3ms7NCzkOzXngJcFXWTTren1j64WfCSGSzdofhxze5diGbyamgC42Ek(cWcCc1kCTg4iMIBX)uzEftLnYZT9u8LODs0p850tx81KSOacfzNsZiKhNMODs0p850)uzEftLnYFZinr7KOdj8xcrNBliI(NOhjr7KOVP4lZb2xmCBBertDIEKGJfKnBWP44kJiFabmWLGXGd32tXxawGtOwHR1ahgJGV0081BRcVsi6eVdCHiANeTykUf)tL5vmv2ip32tXxI2jr7gr)WNtpDXxtYIciuKDknJqEKybhiAkjAmq0Wadr7gr)WNtpDXxtYIciuKDknJqEKybhiAkj6HeTtI(MIVmhyFXWTTren1jAxs0Ut0Ut0oj6h(C6FQmVIPYg5VzKgCSGSzdofhxze5diGbJemgC42Ek(cWcCc1kCTg4GOzLcsSkMfK)v4IPGqkd9r0us0dbhliB2GZRWftbHug6diGbubmgC42Ek(cWcCMzb1SReWGHGJfKnBWHotfuXOeVcmqadCnWyWHB7P4lalWjuRW1AGtXZIrF2tXeTtI2nIgrZkfKyvmliV8vg6dkycrtjrJbI2DWXcYMn4iFLH(GcMaeWGramgC42Ek(cWcCMzb1SReWGHGJfKnBWHotfuXOeVcmqadgnym4WT9u8fGf4eQv4AnWbrZkfKyvmliV8vg6dkycrtjr7sI2jrZye8LMMVEf(CAqrkJME7yer7KOftXT4FfUykiKYqFEUTNIVGJfKnBWr(kd9bfmbiGbuBWyWHB7P4lalWzMfuZUsadgcowq2Sbh6mvqfJs8kWabmyiSbJbhUTNIVaSaNqTcxRboUq2GdBhddmU5cXuCl(NkZRyQSrEUTNIVolgUTnI6x8YKn7rf2Ex6UtXQyw8YcNHKe6UmLJeCSGSzdoL5adeWGHdbJbhUTNIVaSaNzwqn7kbmyi4ybzZgCOZubvmkXRadeWGHyamgC42Ek(cWcCc1kCTg4iMIBX)uzEftLnYZT9u815dFo9pvMxXuzJ840oDZTIHBBJO()i4UtAUqls4wGGJRKLwTCr5nfFzoWEA44kzPvlxJkS9JMkU7uSkMfVSWzijHUlt5ibhliB2GtzoWabmyOlbJbhUTNIVaSaNqTcxRboUr0p850lBmxiOjErHhNMODs0Ur0LTxigwClE7Er(TjAkjA3i6Hen2enCZvqHpRIzerpIi6WNvXmcAwwq2Snfr7orpQeDXHpRIzizHZeT7eT7GJfKnBW5v4IPGqkd9beWGHJemgC42Ek(cWcCc1kCTg4u8Sy0N9um4ybzZgCGNzp3IHcMaeWGHubmgC42Ek(cWcCMzb1SReWGHGJfKnBWHotfuXOeVcmqadg6AGXGd32tXxawGtOwHR1aNINfJ(SNIjANeTBenSSATNI94igs(kd9r0)engiAyGHOr0SsbjwfZcYlFLH(GcMq0us0djA3bhliB2GJ8vg6dkycqadgocGXGd32tXxawGtOwHR1aNINfJ(SNIjANenSSATNI94igs(kd9r0)e9qI2jr)WNtFqXwfmKSDSVyliGJfKnBWr(kd9bfmbiGbdhnym4WT9u8fGf4mZcQzxjGbdbhliB2GdDMkOIrjEfyGagmKAdgdoCBpfFbyboHAfUwdCq0SsbjwfZcYJIS0muWeIMsIEi4ybzZgCqrwAgkycqadWaSbJbhUTNIVaSaNqTcxRbo3u8L5a7lgUTnIOPKODJOTGSz7rFfF9Hejen2eTfKnBFzoW(qIeIEer0CZvmfeT7engDIMBUIPWxCm3enmWq0p850huSvbdjBh7l2cc4ybzZgCqFfFbcqac4y4YxwGdg361bBbcqaa]] )
end