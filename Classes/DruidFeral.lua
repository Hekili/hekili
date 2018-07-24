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

        local tigers_fury = FindUnitBuffByID( "player", class.auras.tigers_fury.id, "PLAYER" )
        local bloodtalons = FindUnitBuffByID( "player", class.auras.bloodtalons.id, "PLAYER" )
        local clearcasting = FindUnitBuffByID( "player", class.auras.clearcasting.id, "PLAYER" )
        local prowling = GetTime() - stealth_dropped < 0.2 or FindUnitBuffByID( "player", class.auras.incarnation.id, "PLAYER" )

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
            recheck = function () return buff.bloodtalons.remains end,
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


    spec:RegisterPack( "Feral", 20180723.2131, [[dOee2aqiKuwesQIhHKQ0Lqsf1MOcFcjvsJIkQtrLyvQivVcu1SqsUfvsXUOQFbunmGshtOSmGINbL00urY1qcTnve6BujvJtfrNtfbwhsQaZdj4EazFqPoOksPfcQ8qKuHmrKurUisQuTrvKItIKkOvQcntKuPCtKuHANQGFQIGYqvrqwQkcQEQctvOAVk9xadMuhMYIvPhlyYGCzInROplKrdkNwvRgjvIxtfz2KCBOy3s9BrdhPoovsPLl55qMoQRdvBhkX3PsnEQKCEKO1JKQA(QO2pI3yB8DazSShadyJDsW66GbREWedRXofw3btjTSdAl4Kfj7OnmYoonszQDqBuQsdAJVduIxbzhWyMgrDa4Gh9mm8RpKyah9yWvg)zhkBYGJEmbWVQ8c(DAUgiblGtx58vcc84VuGjg4XbtmaQtf(dbCAKYuE0JjSJl(RyQd79UdiJL9ayaBStcwxhmy1dMyyfSXC9DGOLWEigyX6oGeuyhXH9iI(rendtiAizA4kMOPTGtwKq0ZSi6tJuMIO)MOHZywje9mlI(0s9LkzyEYrYXtlrhvIXenKykIoNendtiA3z5erZjrJeMOXPj6tJuMIODBiIoKyOvclqe9LsI(ewROSfp5i5ymprt0uhNyrGiAQh6kDROEi6RmZsiAQNGXaZSWq9q0Ft00LesmxJj6t7je1nIg9DqiAktCIgkBQRmrxIPuus0TiqenNenosi6GXaZSWq0)KOPmXjAeEiii0exPOKOPR0TsG8KJKJGXt0e9jCbtIfbIOLwQikj6amj4er7gM0enDst)Derh)JKI6kIOpn4fLEIMOJdtiAizA4kMOpTNqu3i6amj4eIONzr0grdjZp8mrNtI(ebl8eT0sfrjve9fNjA0JHOzbXFhr0iyPBerZWmMOzypIOHziIUtI(kTmFMODolI(reTr0i1hbJjAQtNqdIwLiKl(Dqx58vYoOEjAQ7Usc4Sar0xzMLq0HeZ1yI(krFJ8e9PneeAgr0D2UgywHzIRiAlWF2iIoBfLEYrlWF2ipDjHeZ1yqtLHCIC0c8NnYtxsiXCngEqGpZeIC0c8NnYtxsiXCngEqGB4ryKMn(ZMC0c8NnYtxsiXCngEqGxsuLUzyu9tqSPKM9xvMqSPYg5L2UkbIC0c8NnYtxsiXCngEqGtxPBf5Of4pBKNUKqI5Am8GapymWmlmKJuVe9OnAeSKj6YEiI(IpNcerJyJre9vMzjeDiXCnMOVs03iI2AiIMUexdDY83re9JiAOSfp5Of4pBKNUKqI5Am8Gah1gncwYai2ye5Of4pBKNUKqI5Am8GaNo5pBYrlWF2ipDjHeZ1y4bbowS6TRsOQnmciCKaWWkdbJkSykCbeyjhTa)zJ80LesmxJHhe4yXQ3UkHQ2WiGWrcadRmemQWIPWfqXO6NGexl(ttlqEf(CAaUlJM(7ie5i5i1lrtD3vsaNfiIwWIuus08JriAgMq0wGZIOFerByXELDvINC0c8NncEqGx4nGf4pBa1JyQAdJac9DKsayRIeMQFcYc8JfbakzF90yd2ZN5hJGDmksoAb(ZgbpiWlZjHQFcIA8hC67OZNV4ZPNUs3kpon5Of4pBe8GahYqWO6NGO2fFo9bJbMzHXJttoAb(ZgbpiWnCobmMTGtKJwG)SrWdcCmz2ZVeGGXu9tqSPKM9k82kGVr0Fz8NTxA7QeihuJ)GtFhroAb(ZgbpiWrgwSibOsRO6NGO2fFo9idlwKauPvECAYrlWF2i4bb(vkKuoroAb(ZgbpiW)oyvB8Nn5Of4pBe8GaN)iPqat8IsYrlWF2i4bb(uktbmlPP(usoAb(ZgbpiWljQs3mmQ(jiNztjn7r2vkotgMxA7QeOZNV4ZPNUeiJZIsaK7FYTGqECAxCWMsA2FvzcXMkBKxA7Qeihx850FvzcXMkBKhkD3ocjMBcqNFZiquKC0c8NncEqGxpnv)euiXCta68BgbIIKJwG)SrWdcCgwziyabJP6NGOg)bN(oYbwS6TRs84ibGHvgcg2GLC0c8NncEqGFlC2uaiLHGr1pbHOfLcGTksyK)w4SPaqkdbd7yKJwG)SrWdcCK7Nwacgt1pbHOfLcGTksyKh5(PfGGXyhJC0c8NncEqGJGvce5i5Of4pBKpKPckD3iqqgcgv)ee1U4ZPpymWmlmECAYrlWF2iFitfu6UrWdcC6kDRO6NGU4ZP)7GvTXF2(sWyFJOay9u0XfFo9uxW7iLaGyt5KuECAYrlWF2iFitfu6UrWdc8RuiPCIQFcsAPIOeBqyfSoCoKPckD3E(JKcbmXlk9LGX(gHnfpF(IpNE(JKcbmXlk940UqoAb(Zg5dzQGs3ncEqGZFKuiGjErj5Of4pBKpKPckD3i4bb(vkKuo9De5Of4pBKpKPckD3i4bb(3bRAJ)SP6NGKwQikXgewbRdNdzQGs3TN)iPqat8IsFjySVryhJINpFXNtp)rsHaM4fLECAxihTa)zJ8HmvqP7gbpiWPt(ZMQ2WiGORuLDKabqNULIQFcITksyp)yeaobGEHcNifpF2z(XiaCca9cfIDsW6W5l(C6VsHKYjpo95Zx850)DWQ24pBpoTlUqoAb(Zg5dzQGs3ncEqGpLYuaZsAQpLu9tqHeZnbOZVze2GaJdNPgBkPz)vLjeBQSrEPTRsGoF(IpN(Rkti2uzJ840UqoAb(Zg5dzQGs3ncEqGJGzqPBmIcIQFckKyUjaD(nJOafDiTuruInilWF2(YCs8HeXoGs2xMtINgdUIFA1lffaJpMJl(C65pskeWeVO0Jt7W5l(C6VQmHytLnYJtF(m1ytjn7VQmHytLnYlTDvcKloCMASPKM9FhSQn(Z2lTDvc05ZHmvqP72)DWQ24pBFjySVryh7KU4GAx850)DWQ24pBpon5Of4pBKpKPckD3i4bboosaEwWGihjhTa)zJ8OVJucaBvKWGcgdmZcdv)ee1U4ZPpymWmlmECAYrlWF2ip67iLaWwfjm8GaVmNeQ(jOl(C6PR0TYJtF(8fFo9iygu6gJOG840KJwG)SrE03rkbGTksy4bbUHZjGXSfCIC0c8NnYJ(osjaSvrcdpiWdMsbyb(Zgq9iMQ2WiGczQGs3nIC0c8NnYJ(osjaSvrcdpiWNsLHpXra3NfQyRIeg4NGGs2xpTN)GtFh5akzF90(sWyFJOawDWwfjSNFmcaNaqVGDmW6Wz2QiH9WetXW80bMcGHINpZMsA2JSRuCMmmV02vjqUqoAb(Zg5rFhPea2QiHHhe4LevPBggv)euiXCta68BgbIIoU4ZPNUeiJZIsaK7FYTGqECAhSPKM9xvMqSPYg5L2UkbYXfFo9xvMqSPYg5Hs3TdNP2fFo9FhSQn(Z2JtF(muY(6P9LGX(grHt6c5Of4pBKh9DKsayRIegEqGxsuLUzyu9tqHeZnbOZVze2y1bBkPz)vLjeBQSrEPTRsGCCXNtpDjqgNfLai3)KBbH840oU4ZP3OfxbqxcKXz5XPDCXNt)3bRAJ)S9qP7MC0c8NnYJ(osjaSvrcdpiWNsLHpXra3NfQ(jOl(C6nAXva0LazCwECAho7CiXCta68BgH9PC48fFo9FhSQn(Z2JtF(mBkPzpMeJ0mqobckREMsV02vjqU4Y5ZoZMsA2FvzcXMkBKxA7Qeihx850FvzcXMkBKhN2riXCta68BgHnwDXfYrlWF2ip67iLaWwfjm8GaVWBalWF2aQhXu1ggbeIbMF)iysHO6NGcjMBcqNFZiSpf5Of4pBKh9DKsayRIegEqGx4nGf4pBa1JyQAdJacXarslLXzHihjhTa)zJ8igy(9JGjfceDMkGsqjEfeQMzb0IRyqXihTa)zJ8igy(9JGjfcEqGJmSyrcqLwr1pbDXNtpYWIfjavALhkD3KJwG)SrEedm)(rWKcbpiWPZubuckXRGq1mlGwCfdkg5Of4pBKhXaZVFemPqWdc86PPITksyGFcIA8hC67OZNDUem23ikaccVm(Z(0bRhRU4Wz2QiH9WetXW80bgBWqrhuJnL0ShzxP4mzyEPTRsGC58zNlbJ9nIcGGWlJ)SpDW6pPdAPqpILMbWGR4Nw9sHnuY(6P90yWv8tREPCXbBvKWE(XiaCca9c2NKC0c8NnYJyG53pcMui4bboDMkGsqjEfeQMzb0IRyqXihTa)zJ8igy(9JGjfcEqGJmSyrcqLwr1pbDXNtpYWIfjavALVem23ikedmKJwG)SrEedm)(rWKcbpiWNsLHpXra3NfQWyUcqAPIOeumYrYrlWF2ipIbIKwkJZcbQKOkDZWO6NGytjn7VQmHytLnYlTDvcKJl(C6PlbY4SOea5(NCliKhN2XfFo9xvMqSPYg5Hs3TJqI5Ma053mcBqGXritfu6U9tPmfWSKM6tPVem23ikefGihTa)zJ8igisAPmole8GaVKOkDZWO6NGytjn7VQmHytLnYlTDvcKJl(C6PlbY4SOea5(NCliKhN2XfFo9xvMqSPYg5Hs3TJqI5Ma053mc0PCaLSVmNeFjySVru4uKJwG)SrEedejTugNfcEqGxsuLUzyu9tqIRf)PPfiV9k8kbOt8oifYbBkPz)vLjeBQSrEPTRsGC48fFo90LazCwucGC)tUfeYJyl4e2G58zNV4ZPNUeiJZIsaK7FYTGqEeBbNWoMdOK9L5K4lbJ9nIcy1fxCCXNt)vLjeBQSrEO0DtoAb(Zg5rmqK0szCwi4bb(TWztbGugcgv)eeIwuka2QiHr(BHZMcaPmemSHe0xceaBvKWiYrlWF2ipIbIKwkJZcbpiWPZubuckXRGq1mlGwCfdkg5Of4pBKhXarslLXzHGhe4mSYqWacgt1pbvYSeem7QehoJOfLcGTksyKNHvgcgqWySbJlKJwG)SrEedejTugNfcEqGtNPcOeuIxbHQzwaT4kgumYrlWF2ipIbIKwkJZcbpiWzyLHGbemMQFccrlkfaBvKWipdRmemGGXyJvhIRf)PPfiVcFona3Lrt)DeYbBkPz)TWztbGugcMxA7QeiYrlWF2ipIbIKwkJZcbpiWPZubuckXRGq1mlGwCfdkg5Of4pBKhXarslLXzHGhe4L5KqfBvKWa)ee14p403rNp7m1ytjn7VQmHytLnYlTDvcKJsWyFJOaeEz8N9PdwpwDXbBvKWE(XiaCca9c2NIC0c8NnYJyGiPLY4SqWdcC6mvaLGs8kiunZcOfxXGIroAb(Zg5rmqK0szCwi4bbEzojuXwfjmWpbXMsA2FvzcXMkBKxA7Qeihx850FvzcXMkBKhN2HZoxcg7Befa56U4Gwk0JyPzam4k(PvVuydLSVmNepngCf)0QxQthS(tsrxCWwfjSNFmcaNaqVG9PihTa)zJ8igisAPmole8Ga)w4SPaqkdbJQFcY5l(C65pskeWeVO0Jt7W5YEiablsZEdcc5)gBNJbpgZvabywfjixtaMvrccywwG)SnLlNEjbywfja8JrCXfYrlWF2ipIbIKwkJZcbpiWXKzp)sacgtfBvKWa)eujZsqWSRsihTa)zJ8igisAPmole8GaNotfqjOeVccvZSaAXvmOyKJwG)SrEedejTugNfcEqGZWkdbdiymv)eujZsqWSRsC4mwS6TRs84ibGHvgcgiWC(mIwuka2QiHrEgwziyabJXoMlKJwG)SrEedejTugNfcEqGZWkdbdiymv)eujZsqWSRsCGfRE7QeposayyLHGbkMJl(C6dkXQGH4VJ8LybMC0c8NnYJyGiPLY4SqWdcC6mvaLGs8kiunZcOfxXGIroAb(Zg5rmqK0szCwi4bboY9tlabJP6NGq0IsbWwfjmYJC)0cqWySJroAb(Zg5rmqK0szCwi4bbocwjqu9tqqj7lZjXxcg7Be2oBb(Z2JGvcKpKigElWF2(YCs8HeXUgPLkIsxOolTuru6ljs6ZNV4ZPpOeRcgI)oYxIf4DGfPqF27bWa2yNeSUEmW4bdyW6oCBv)DeAh7q9igTX3b67iLaWwfj8gFpeBJVdPTRsGw42rOEwQ32b1i6l(C6dgdmZcJhNEhwG)S3rWyGzwywEpaMn(oK2UkbAHBhH6zPEBhx850txPBLhNMOpFMOV4ZPhbZGs3yefKhNEhwG)S3rzojlVhW6gFhwG)S3HHZjGXSfCAhsBxLaTWT8E4uB8DiTDvc0c3oSa)zVJGPuawG)SbupI3H6rmqByKDeYubLUB0Y7bkUX3H02vjqlC7iupl1B7akzF90E(do9Der7GOHs2xpTVem23iIMcenwjAhenBvKWE(XiaCca9crJnrhdSeTdI2zIMTksypmXummpDGjAkq0GHIe95ZenBkPzpYUsXzYW8sBxLar0USdlWF27ykvg(ehbCFwwEpCIB8DiTDvc0c3oc1Zs92ocjMBcqNFZiIgertrI2brFXNtpDjqgNfLai3)KBbH840eTdIMnL0S)QYeInv2iV02vjqeTdI(IpN(Rkti2uzJ8qP7MODq0ot0uJOV4ZP)7GvTXF2ECAI(8zIgkzF90(sWyFJiAkq0NKODzhwG)S3rjrv6MHT8EW1347qA7QeOfUDeQNL6TDesm3eGo)Mren2enwjAhenBkPz)vLjeBQSrEPTRsGiAhe9fFo90LazCwucGC)tUfeYJtt0oi6l(C6nAXva0LazCwECAI2brFXNt)3bRAJ)S9qP7EhwG)S3rjrv6MHT8E4KB8DiTDvc0c3oc1Zs92oU4ZP3OfxbqxcKXz5XPjAheTZeTZeDiXCta68Bgr0yt0NIODq0ot0x850)DWQ24pBponrF(mrZMsA2JjXindKtGGYQNP0lTDvcer7cr7crF(mr7mrZMsA2FvzcXMkBKxA7QeiI2brFXNt)vLjeBQSrECAI2brhsm3eGo)Mren2enwjAxiAx2Hf4p7DmLkdFIJaUpllVhobB8DiTDvc0c3oc1Zs92ocjMBcqNFZiIgBI(u7Wc8N9ok8gWc8NnG6r8oupIbAdJSdedm)(rWKcT8Eigy347qA7QeOfUDyb(ZEhfEdyb(Zgq9iEhQhXaTHr2bIbIKwkJZcT8Y7asMgUI347HyB8DiTDvc0c3oc1Zs92oSa)yraGs2xpnrJnrdwI(8zIMFmcrJnrhJI7Wc8N9ok8gWc8NnG6r8oupIbAdJSd03rkbGTks4L3dGzJVdPTRsGw42rOEwQ32b1iA(do9DerF(mrFXNtpDLUvEC6Dyb(ZEhL5KS8EaRB8DiTDvc0c3oc1Zs92oOgrFXNtFWyGzwy8407Wc8N9oGmeSL3dNAJVdlWF27WW5eWy2coTdPTRsGw4wEpqXn(oK2UkbAHBhH6zPEBhSPKM9k82kGVr0Fz8NTxA7QeiI2brtnIM)GtFhTdlWF27atM98lbiy8Y7HtCJVdPTRsGw42rOEwQ32b1i6l(C6rgwSibOsR8407Wc8N9oqgwSibOsRwEp46B8Dyb(ZEhxPqs50oK2UkbAHB59Wj347Wc8N9o(oyvB8N9oK2UkbAHB59WjyJVdlWF27G)iPqat8IYDiTDvc0c3Y7HyGDJVdlWF27ykLPaML0uFk3H02vjqlClVhIfBJVdPTRsGw42rOEwQ32HZenBkPzpYUsXzYW8sBxLar0Npt0x850txcKXzrjaY9p5wqiponr7cr7GOztjn7VQmHytLnYlTDvcer7GOV4ZP)QYeInv2ipu6UjAheDiXCta68Bgr0GiAkUdlWF27OKOkDZWwEpedmB8DiTDvc0c3oc1Zs92ocjMBcqNFZiIgertXDyb(ZEh1tV8Eigw347qA7QeOfUDeQNL6TDqnIM)GtFhr0oiASy1BxL4XrcadRmemIgBIgS7Wc8N9oyyLHGbemE59qStTX3H02vjqlC7iupl1B7arlkfaBvKWi)TWztbGugcgrJnrhBhwG)S3XTWztbGugc2Y7HyuCJVdPTRsGw42rOEwQ32bIwuka2QiHrEK7Nwacgt0yt0X2Hf4p7DGC)0cqW4L3dXoXn(oSa)zVdeSsG2H02vjqlClV8oOljKyUgVX3dX247qA7QeOfUL3dGzJVdPTRsGw4wEpG1n(oK2UkbAHB59WP247qA7QeOfUDeQNL6TDWMsA2FvzcXMkBKxA7QeODyb(ZEhLevPBg2Y7bkUX3Hf4p7DqxPB1oK2UkbAHB59WjUX3Hf4p7DemgyMfMDiTDvc0c3Y7bxFJVdPTRsGw4wEpCYn(oSa)zVd6K)S3H02vjqlClVhobB8DiTDvc0c3oWIPWLDa2Dyb(ZEhyXQ3UkzhyXkG2Wi7ahjamSYqWwEpedSB8DiTDvc0c3oSa)zVdSy1BxLSdSykCzhX2rOEwQ32H4AXFAAbYRWNtdWDz00FhH2bwScOnmYoWrcadRmeSLxEhHmvqP7gTX3dX247qA7QeOfUDeQNL6TDqnI(IpN(GXaZSW4XP3Hf4p7DaziylVhaZgFhsBxLaTWTJq9SuVTJl(C6)oyvB8NTVem23iIMceny9uKODq0x850tDbVJucaInLts5XP3Hf4p7DqxPB1Y7bSUX3H02vjqlC7iupl1B7qAPIOKOXgerJvWs0oiANj6qMkO0D75pskeWeVO0xcg7BerJnrtrI(8zI(IpNE(JKcbmXlk940eTl7Wc8N9oUsHKYPL3dNAJVdlWF27G)iPqat8IYDiTDvc0c3Y7bkUX3Hf4p7DCLcjLtFhTdPTRsGw4wEpCIB8DiTDvc0c3oc1Zs92oKwQikjASbr0yfSeTdI2zIoKPckD3E(JKcbmXlk9LGX(gr0yt0XOirF(mrFXNtp)rsHaM4fLECAI2LDyb(ZEhFhSQn(ZE59GRVX3H02vjqlC7iupl1B7GTksyp)yeaobGEHOParFIuKOpFMODMO5hJaWja0lenfi6yNeSeTdI2zI(IpN(RuiPCYJtt0Npt0x850)DWQ24pBponr7cr7YoOt(ZEh0vQYosGaOt3sTdlWF27Go5p7L3dNCJVdPTRsGw42rOEwQ32riXCta68Bgr0ydIObdr7GODMOPgrZMsA2FvzcXMkBKxA7QeiI(8zI(IpN(Rkti2uzJ840eTl7Wc8N9oMszkGzjn1NYL3dNGn(oK2UkbAHBhH6zPEBhHeZnbOZVzertbIMIeTdIwAPIOKOXgerBb(Z2xMtIpKiMODq0qj7lZjXtJbxXpT6LIOPardgFmI2brFXNtp)rsHaM4fLECAI2br7mrFXNt)vLjeBQSrECAI(8zIMAenBkPz)vLjeBQSrEPTRsGiAxiAheTZen1iA2usZ(Vdw1g)z7L2UkbIOpFMOdzQGs3T)7GvTXF2(sWyFJiASj6yNKODHODq0uJOV4ZP)7GvTXF2EC6Dyb(ZEhiygu6gJOGwEpedSB8Dyb(ZEh4ib4zbdAhsBxLaTWT8Y7aXaZVFemPqB89qSn(oK2UkbAHBhZSaAXv8Ei2oSa)zVd6mvaLGs8kilVhaZgFhsBxLaTWTJq9SuVTJl(C6rgwSibOsR8qP7EhwG)S3bYWIfjavA1Y7bSUX3H02vjqlC7yMfqlUI3dX2Hf4p7DqNPcOeuIxbz59WP247qA7QeOfUDeQNL6TDqnIM)GtFhr0Npt0ot0LGX(gr0uaerdHxg)zt0NordwpwjAxiAheTZenBvKWEyIPyyE6at0yt0GHIeTdIMAenBkPzpYUsXzYW8sBxLar0Uq0Npt0ot0LGX(gr0uaerdHxg)zt0Nordw)jjAhenTuOhXsZayWv8tREPiASjAOK91t7PXGR4Nw9sr0Uq0oiA2QiH98Jra4ea6fIgBI(K7Wc8N9oQNE59af347qA7QeOfUDmZcOfxX7Hy7Wc8N9oOZubuckXRGS8E4e347qA7QeOfUDeQNL6TDCXNtpYWIfjavALVem23iIMceDmWSdlWF27azyXIeGkTA59GRVX3bgZvaslveL7i2oSa)zVJPuz4tCeW9zzhsBxLaTWT8Y7aXarslLXzH247HyB8DiTDvc0c3oc1Zs92oytjn7VQmHytLnYlTDvcer7GOV4ZPNUeiJZIsaK7FYTGqECAI2brFXNt)vLjeBQSrEO0Dt0oi6qI5Ma053mIOXgerdgI2brhYubLUB)uktbmlPP(u6lbJ9nIOParhfG2Hf4p7DusuLUzylVhaZgFhsBxLaTWTJq9SuVTd2usZ(Rkti2uzJ8sBxLar0oi6l(C6PlbY4SOea5(NCliKhNMODq0x850FvzcXMkBKhkD3eTdIoKyUjaD(nJiAqe9PiAhenuY(YCs8LGX(gr0uGOp1oSa)zVJsIQ0ndB59aw347qA7QeOfUDeQNL6TDiUw8NMwG82RWReGoX7GuiI2brZMsA2FvzcXMkBKxA7QeiI2br7mrFXNtpDjqgNfLai3)KBbH8i2cor0yt0GHOpFMODMOV4ZPNUeiJZIsaK7FYTGqEeBbNiASj6yeTdIgkzFzoj(sWyFJiAkq0yLODHODHODq0x850FvzcXMkBKhkD37Wc8N9okjQs3mSL3dNAJVdPTRsGw42rOEwQ32bIwuka2QiHr(BHZMcaPmemIgBIo2oSa)zVJBHZMcaPmeSL3duCJVdPTRsGw42XmlGwCfVhITdlWF27GotfqjOeVcYY7HtCJVdPTRsGw42rOEwQ32rjZsqWSRsiAheTZenIwuka2QiHrEgwziyabJjASjAWq0USdlWF27GHvgcgqW4L3dU(gFhsBxLaTWTJzwaT4kEpeBhwG)S3bDMkGsqjEfKL3dNCJVdPTRsGw42rOEwQ32bIwuka2QiHrEgwziyabJjASjASs0oiAX1I)00cKxHpNgG7YOP)ocr0oiA2usZ(BHZMcaPmemV02vjq7Wc8N9oyyLHGbemE59WjyJVdPTRsGw42XmlGwCfVhITdlWF27GotfqjOeVcYY7HyGDJVdPTRsGw42rOEwQ32b1iA(do9DerF(mr7mrtnIMnL0S)QYeInv2iV02vjqeTdIUem23iIMceneEz8NnrF6eny9yLODHODq0Svrc75hJaWja0len2e9P2Hf4p7DuMtYY7HyX247qA7QeOfUDmZcOfxX7Hy7Wc8N9oOZubuckXRGS8Eigy247qA7QeOfUDeQNL6TDWMsA2FvzcXMkBKxA7QeiI2brFXNt)vLjeBQSrECAI2br7mr7mrxcg7BertbqeTRt0Uq0oiAAPqpILMbWGR4Nw9sr0yt0qj7lZjXtJbxXpT6LIOpDIgS(tsrI2fI2brZwfjSNFmcaNaqVq0yt0NAhwG)S3rzojlVhIH1n(oK2UkbAHBhH6zPEBhot0x850ZFKuiGjErPhNMODq0ot0L9qacwKM9geeY)nrJnr7mrhJOHNOXyUciaZQibr0UgIoaZQibbmllWF2MIODHOpDIUKamRIea(XieTleTl7Wc8N9oUfoBkaKYqWwEpe7uB8DiTDvc0c3oc1Zs92okzwccMDvYoSa)zVdmz2ZVeGGXlVhIrXn(oK2UkbAHBhZSaAXv8Ei2oSa)zVd6mvaLGs8kilVhIDIB8DiTDvc0c3oc1Zs92okzwccMDvcr7GODMOXIvVDvIhhjamSYqWiAqenyi6ZNjAeTOuaSvrcJ8mSYqWacgt0yt0XiAx2Hf4p7DWWkdbdiy8Y7HyU(gFhsBxLaTWTJq9SuVTJsMLGGzxLq0oiASy1BxL4XrcadRmemIgerhJODq0x850huIvbdXFh5lXc8oSa)zVdgwziyabJxEpe7KB8DiTDvc0c3oMzb0IR49qSDyb(ZEh0zQakbL4vqwEpe7eSX3H02vjqlC7iupl1B7arlkfaBvKWipY9tlabJjASj6y7Wc8N9oqUFAbiy8Y7bWa2n(oK2UkbAHBhH6zPEBhqj7lZjXxcg7BerJnr7mrBb(Z2JGvcKpKiMOHNOTa)z7lZjXhset0UgIwAPIOKODHOPot0slveL(sIKMOpFMOV4ZPpOeRcgI)oYxIf4Dyb(ZEhiyLaT8YlVddNHL1ogpgQJwE5Db]] )
end