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
        jungle_stalker = {
            id = 252071, 
            duration = 30,
        },
        moonfire = {
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
            id = 16974,
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
        if sourceGUID == state.GUID then
            if subtype == "SPELL_AURA_REMOVED" then
                -- Track Prowl and Shadowmeld dropping, give a 0.2s window for the Rake snapshot.
                if spellID == 58984 or spellID == 5215 or spellID == 1102547 then
                    stealth_dropped = GetTime()
                end
            elseif subtype == "SPELL_AURA_APPLIED" then
                if snapshots[ spellID ] and ( subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' ) then
                    ns.saveDebuffModifier( spellID, calculate_multiplier( spellID ) )
                    ns.trackDebuff( spellID, destGUID, GetTime(), true )
                end
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

    local function comboSpender( a, r )
        if r == "combo_points" and a > 0 and state.talent.soul_of_the_forest.enabled then
            state.gain( a * 5, "energy" )
        end
    end

    spec:RegisterHook( "spend", comboSpender )
    spec:RegisterHook( "spendResources", comboSpender )


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
            ready = function ()
                --Removing settings options until implemented.
                --if active_enemies == 1 and settings.brutal_charges == 3 then return 3600 end
                --if active_enemies > 1 or settings.brutal_charges == 0 then return 0 end

                if active_enemies == 1 then return 3600 end
                if active_enemies > 1 then return 0 end

                -- We need time to generate 1 charge more than our settings.brutal_charges value.
                -- return ( 1 + settings.brutal_charges - cooldown.brutal_slash.charges_fractional ) * recharge
                return ( 4 - cooldown.brutal_slash.charges_fractional ) * recharge
            end,
            
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
            usable = function()
                return not buff.cat_form.up
            end,
            
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
            usable = function ()
                return not buff.cat_form.up
            end,
            
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
            
            startsCombat = false,
            texture = 136100,
            usable = function ()
                --add logic to use roots when current debuff is less than or equal to the cast time
                return (dot.entangling.expires <= abilities.entangling_roots.cast)
            end,
            
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
            
            unsupported = true,
            startsCombat = true,
            texture = 132140,
            
            handler = function ()
                gain( 5, "combo_points" )
                applyDebuff( "target", "feral_frenzy" )
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
            usable = function()
                return combo_points.current > 0
            end,

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
            unsupported = true,

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
            
            unsupported = true,
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
            
            unsupported = true,
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
            
            unsupported = true,
            startsCombat = false,
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
            min_range = 0,
            max_range = 0,
            
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
            usable = function () 
                return buff.cat_form.up 
            end,
            
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
            spendType = "mana",

            unsupported = true,
            startsCombat = true,
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
            
            startsCombat = true,
            texture = 136085,
            usable = function()
                if not talent.bloodtalons.enabled then return false end
                if buff.bloodtalons.up then return false end
                if buff.cat_form.up then
                    return buff.predatory_swiftness.up or time == 0
                end
            end,
            
            usable = function ()
                if not talent.bloodtalons.enabled then return false end
                if buff.bloodtalons.up then return false end
                if buff.cat_form.up then return buff.predatory_swiftness.up or time == 0 end
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
            
            unsupported = true,
            startsCombat = true,
            texture = 136081,

            talent = "restoration_affinity",
            
            handler = function ()
                unshift()
            end,
        },
        
        --Add support to remove corruption effects if not removed fast enough by healer.
        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            unsupported = true,
            startsCombat = true,
            texture = 135952,
            
            handler = function ()
            end,
        },
        

        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            startsCombat = true,
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
            
            unsupported = true,
            startsCombat = true,
            texture = 132132,
            
            handler = function ()
            end,
        },
        
        -- Spend Points in handler, check for points in usable function of rotation.
        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 30 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",
            
            startsCombat = true,
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
        
        -- Spend Points in handler, check for points in usable function of rotation.
        savage_roar = {
            id = 52610,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 30 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",
            
            startsCombat = false,
            texture = 236167,
            usable = function()
                return talent.savage_roar.enabled
            end,
            
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
            min_range = 0,
            max_range = 13,
            gcd = "spell",
            toggle = "interrupts",

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
            
            unsupported = true,
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
            
            unsupported = true,
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
            
            unsupported = true,
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
            
            unsupported = true,
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

            spend = -30,
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
            
            unsupported = true,
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
            
            unsupported = true,
            startsCombat = false,
            texture = 1518639,
            
            handler = function ()
            end,
        }, ]]
        

        wild_charge = {
            id = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 538771,
            usable = function () if buff.cat_form.up and target.outside8 and target.within25 then return target.exists end
                return false
            end,
            
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
            
            unsupported = true,
            startsCombat = true,
            texture = 236153,

            talent = "restoration_affinity",
            
            handler = function ()
                unshift()
                applyBuff( "wild_growth" )
            end,
        },
    } )


    class.specs[ 0 ].abilities.shadowmeld.recheck = setfenv( function () return buff.incarnation.remains - 0.1 end, state )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        package = "Feral"
    } )


    spec:RegisterPack( "Feral", 20180627.0950, [[dKK62aqiOqlIqapIOIYLieuTjc6tevegfH0Piuwfrj9kOuZIq1Tac0Ui1ViGHru1XuKwguWZiennIkDnqP2grj(grfghqOZbeuRJqqzEGsUNIAFqrhKqqwiuYfjQOAJecPtsur0kveZKOI0njeIDck(jHaLHceqlLqGQNQWubsRfia7vv)fWGf1HPSyv6Xu1Kb5YO2Sk(SignO60kTAcbYRjkMnj3gO2TKFlmCICCGGSCPEoKPJCDOA7arFxKA8eL68eO1tiuZxKSFQ8p9b9hqgXpmyq(PGO8YcgKd9u5NIb5k3FqckX)qY8Yyj8pkdm)druUn1pKmbvHb9G(duG3E(hWjscjctabKmeX3T0(aSaGaajia4GaGkqG)4IVksoz93Faze)WGb5NcIYllyqo0tLFkgK70FGKy)dZu5f5pGyK)hGcFrU8ICzco7Yq8XWvKllzEzSe2Lpr7YIOCBkxElxglJif7YNODzrirm3bbx7M4Mic5YjnBKldXMYLJJltWzxoD0Y4Yu4YiMCzCjxweLBt5YPnKl7dWskMyix(kOllcwPeSyTBIBIiIjckAxwohAjKlhhxgMGyryUjUjt1USllIeGKHCzraPosRebC5lFIMDzraVraNOblc4YB5Ysn7dWxJCzriqGYPUmAlp7Ycg4UmuuYjixUztPe0LlMHCzkCzCe7YEJaord2L3JllyG7YiCVNrOdUsjOll1rAfdPDtCtWG2LDzrKaKmKllcGJyacEBi4IaUmiTETRIrU8wu4YeC2LH4JHRixweceOCQ2nXnrKAx2LfrxUf0LfbNHCzreBbZnYLHIsob5YqHlBLGe8TsC5dE5YwjOldoAw)dPooRI)HCMllNlB2JtmKlF5t0Sl7dWxJC5lNSfs7YIqEplrixUIceeU1Gp4kx280gfYLJsjO2nX80gfsl1SpaFnA(OmKmUjMN2OqAPM9b4RryplWjci3eZtBuiTuZ(a81iSNfWWtaZfz0gLBI5PnkKwQzFa(Ae2Zc0CshPj4IVNzYuCr6RkciYurH0Czxfd5MyEAJcPLA2hGVgH9SasDKw5MyEAJcPLA2hGVgH9SaEJaord2nroZLhLjHGhKl32c5Yx8ZHHCzezeYLV8jA2L9b4RrU8Lt2c5Ywb5YsndckfeTvIlVixgkkw7MyEAJcPLA2hGVgH9SaOYKqWdcargHCtmpTrH0sn7dWxJWEwaPG2OCtCtKZCz5CzZECIHCzgKClOltly2Lj4SlBEkAxErUSbsBv2vXA3eZtBuOzqA9AxflEzG5zCedqWBdbxCqAkCEwE3eZtBuiSNfaKwV2vXIxgyEghXae82qWfhKMcNNNk(EMzqi8vsIH0k8ZXas3MK0wji3eZtBuiSNfOXlaZtBuaQfrIxgyEgTvIIbiRtys89mBEAbjdafKUxjmLpvkAbZyof2UjMN2OqyplqBYWIVNzmsRxMTssL6IFoAPosR04sUjMN2OqyplaKHGl(EMX4f)C0EJaordwJl5MyEAJcH9SagofagrMxg3eZtBuiSNfaCe1zBgWBK47zMmfxKwHxwdSfsABJ2O0CzxfdjeJ06LzRe3eZtBuiSNfazG0syGoSw89mJXl(5OrgiTegOdR14sUjMN2OqyplWLBe3Y4MyEAJcH9SaB5TUmAJYnX80gfc7zbOnHBeWbVf0nX80gfc7zbmeCdSvmc40CjIf0nX80gfc7zbAoPJ0eCX3ZSOKP4I0i7YnfbbxZLDvmuQux8Zrl1mKrrliak9EOIrinUKycjtXfPVQiGitffsZLDvmKWl(5OVQiGitffsdfPlH(a8naKITi0mSDtmpTrHWEwGELeFpZ(a8naKITi0mSDtmpTrHWEwacEBi4aEJeFpZyKwVmBLieKwV2vXACedqWBdbht5DtmpTrHWEwae8MHCtCtmpTrH0(iuqr6cndzi4IVNzmEXphT3iGt0G14sUjMN2OqAFekOiDHWEwaPosReFpZx8ZrVL36YOnkDZGTTqWsEnSfEXphTii8krXaiYuYWTgxYnX80gfs7JqbfPle2ZcC5gXTmIVNzU4orqmNfP8cf1hHcksxAAt4gbCWBb1nd22cHjStL6IFoAAt4gbCWBb14sI5MyEAJcP9rOGI0fc7zbOnHBeWbVfu89mZf3jcQH4Z6xcZzzrE3eZtBuiTpcfuKUqyplWLBe3YSvIBI5PnkK2hHcksxiSNfGv4fJasWxiR8S47z2hGVbGuSfHMLxixCNiiMZWwE3eZtBuiTpcfuKUqyplWwERlJ2OeFpZCXDIGyols5fkQpcfuKU00MWnc4G3cQBgSTfcZPWovQl(5OPnHBeWbVfuJljMBI5PnkK2hHcksxiSNfqkOnkXldmpl1HkQegcqksZT47zMSoHjnTGzakaGwgwYcStLsuAbZauaaTmSMcIYlu0l(5OVCJ4wgnUuQux8ZrVL36YOnknUKyI5MyEAJcP9rOGI0fc7zbmeCdSvmc40CjIfu89m7dW3aqk2IqyoJbHIIrYuCr6RkciYurH0CzxfdLk1f)C0xveqKPIcPXLeZnX80gfs7JqbfPle2ZcGGBqrAWScs89m7dW3aqk2IqWc2c5I7ebXC280gLUnzyTpqKqOG0TjdRLaJROvsTCdlmONk8IFoAAt4gbCWBb14scf9IFo6RkciYurH04sPsHrYuCr6RkciYurH0CzxfdjMqrXizkUi9wERlJ2O0CzxfdLkLpcfuKU0B5TUmAJs3myBleMtbrXeIXl(5O3YBDz0gLgxYnX80gfs7JqbfPle2ZcGJyGLyWi3e3eZtBuinARefdqwNW0S3iGt0GfFpZy8IFoAVraNObRXLCtmpTrH0OTsumazDctyplqBYWIVN5l(5OL6iTsJlLk1f)C0i4guKgmRG04sUjMN2OqA0wjkgGSoHjSNfWWPaWiY8Y4MyEAJcPrBLOyaY6eMWEwaVPuaMN2OaulIeVmW8SpcfuKUqUjMN2OqA0wjkgGSoHjSNf4WD43ahbCxIfNSoHjG9mdfKUxjnTEz2kriuq6EL0nd22cblrkKSoHjnTGzakaGwgZPYluuY6eM0WztrW1sEcwya2PsrMIlsJSl3ueeCnx2vXqI5MyEAJcPrBLOyaY6eMWEwGMt6inbx89m7dW3aqk2IqZWw4f)C0sndzu0ccGsVhQyesJljKmfxK(QIaImvuinx2vXqcV4NJ(QIaImvuinuKUekkgV4NJElV1LrBuACPuPGcs3RKUzW2wiybII5MyEAJcPrBLOyaY6eMWEwGMt6inbx89m7dW3aqk2IqyksHKP4I0xveqKPIcP5YUkgs4f)C0sndzu0ccGsVhQyesJlj8IFoAtILnGuZqgfTgxs4f)C0B5TUmAJsdfPl3eZtBuinARefdqwNWe2ZcC4o8BGJaUlXIVN5l(5Onjw2asndzu0ACjHIkQpaFdaPylcHPCfk6f)C0B5TUmAJsJlLkfzkUin4amxeqCa8kRxsqnx2vXqIjwQuIsMIlsFvrarMkkKMl7QyiHx8ZrFvrarMkkKgxsOpaFdaPylcHPiftm3eZtBuinARefdqwNWe2Zc04fG5Pnka1IiXldmpJiGZwlco3iX3ZSpaFdaPylcHPCDtmpTrH0OTsumazDctyplqJxaMN2OaulIeVmW8mIas4IBJIg5M4MyEAJcPreWzRfbNB0SuekGMrbE7zXprduSSP5PUjMN2OqAebC2ArW5gH9SaidKwcd0H1IVN5l(5OrgiTegOdR1qr6YnX80gfsJiGZwlco3iSNfqkcfqZOaV9S4NObkw208u3eZtBuinIaoBTi4CJWEwGELeNSoHjG9mJrA9YSvsQuI2myBleSMHWBJ2OKv51IumHIswNWKgoBkcUwYtyIbyleJKP4I0i7YnfbbxZLDvmKyPsjAZGTTqWAgcVnAJswLxdIcL4gTiIlcamUIwj1YnMqbP7vslbgxrRKA5wmHK1jmPPfmdqba0YycIUjMN2OqAebC2ArW5gH9SasrOaAgf4TNf)enqXYMMN6MyEAJcPreWzRfbNBe2ZcGmqAjmqhwl(EMV4NJgzG0syGoSw3myBleSMIb3eZtBuinIaoBTi4CJWEwGd3HFdCeWDjwCWMSb4I7ebNN6M4MyEAJcPreqcxCBu0O5Mt6inbx89mtMIlsFvrarMkkKMl7QyiHx8Zrl1mKrrliak9EOIrinUKWl(5OVQiGitffsdfPlH(a8naKITieMZyqOpcfuKU0gcUb2kgbCAUeXcQBgSTfcwjEi3eZtBuinIas4IBJIgH9SanN0rAcU47zMmfxK(QIaImvuinx2vXqcV4NJwQziJIwqau69qfJqACjHx8ZrFvrarMkkKgksxc9b4BaifBrOz5kekiDBYW6MbBBHGLCDtmpTrH0iciHlUnkAe2Zc0CshPj4IVNzgecFLKyiTTk8oaKc8YZnsizkUi9vfbezQOqAUSRIHek6f)C0sndzu0ccGsVhQyesJiZldMyivkrV4NJwQziJIwqau69qfJqAezEzWCQqOG0TjdRBgSTfcwIumXeEXph9vfbezQOqAOiD5MyEAJcPreqcxCBu0iSNf424KPaqkdbx89mJKyLcGSoHjK(24KPaqkdbhtigTndbqwNWeYnX80gfsJiGeU42OOryplGuekGMrbE7zXprduSSP5PUjMN2OqAebKWf3gfnc7zbi4THGd4ns89m38PzeC7QyHIIKyLcGSoHjKMG3gcoG3imXGyUjMN2OqAebKWf3gfnc7zbKIqb0mkWBpl(jAGILnnp1nX80gfsJiGeU42OOryplabVneCaVrIVNzKeRuaK1jmH0e82qWb8gHPifYGq4RKedPv4NJbKUnjPTsqcjtXfPVnozkaKYqW1Czxfd5MyEAJcPreqcxCBu0iSNfqkcfqZOaV9S4NObkw208u3eZtBuinIas4IBJIgH9SaTjdlozDcta7zgJ06LzRKuPefJKP4I0xveqKPIcP5YUkgsyZGTTqWccVnAJswLxlsXeswNWKMwWmafaqlJPCDtmpTrH0iciHlUnkAe2ZcifHcOzuG3Ew8t0aflBAEQBI5PnkKgrajCXTrrJWEwG2KHfNSoHjG9mtMIlsFvrarMkkKMl7QyiHx8ZrFvrarMkkKgxsOOI2myBleSMLdXekXnArexeayCfTsQLBmHcs3MmSwcmUIwj1YTSkVgeHTycjRtystlygGcaOLXuUUjMN2OqAebKWf3gfnc7zbUnozkaKYqWfFpZIEXphnTjCJao4TGACjHI22cbWGKlsBqqi9wyk6uSbBYgWd36egbc6HBDcJaoT5PnktjMS2ShU1jmaTGzXeZnX80gfsJiGeU42OOrypla4iQZ2mG3iXjRtycypZnFAgb3Uk2nX80gfsJiGeU42OOryplGuekGMrbE7zXprduSSP5PUjMN2OqAebKWf3gfnc7zbi4THGd4ns89m38PzeC7QyHIcsRx7QynoIbi4THGpJHuPqsSsbqwNWestWBdbhWBeMtfZnX80gfsJiGeU42OOryplabVneCaVrIVN5MpnJGBxfleKwV2vXACedqWBdbFEQWl(5O9k2AVHOTs0nBEYnX80gfsJiGeU42OOryplGuekGMrbE7zXprduSSP5PUjMN2OqAebKWf3gfnc7zbqPxjgWBK47zgjXkfazDctink9kXaEJWCQBI5PnkKgrajCXTrrJWEwae8MHeFpZqbPBtgw3myBleMIAEAJsJG3mK2hicBZtBu62KH1(arGGCXDIGIjcNlUteu3CcxPsDXphTxXw7neTvIUzZt)aKCJ2OEyWG8tbr5LfmihA5bHH9psBDTvc6h)qTic9G(d0wjkgGSoHPh0hMPpO)Gl7QyOhRF47L4ETFGrx(IFoAVraNObRXL(H5PnQF4nc4en4NEyWWd6p4YUkg6X6h(EjUx7hx8Zrl1rALgxYLtLYLV4NJgb3GI0GzfKgx6hMN2O(rBYWp9WiYh0FyEAJ6hgofagrMxMFWLDvm0J1tpmY9b9hCzxfd9y9dZtBu)WBkfG5Pnka1IOFOwebugy(h(iuqr6c90ddSFq)bx2vXqpw)W80g1poCh(nWra3L4F47L4ETFafKUxjnTEz2kriuq6EL0nd22cblrkKSoHjnTGzakaGwgZPYluuY6eM0WztrW1sEcwya2PsrMIlsJSl3ueeCnx2vXqI9dY6eMa2ZpGcs3RKMwVmBLiekiDVs6MbBBHGLifswNWKMwWmafaqlJ5u5fkkzDctA4SPi4Ajpblma7uPitXfPr2LBkccUMl7QyiXE6HrwEq)bx2vXqpw)W3lX9A)WhGVbGuSfHC5zxg2USqx(IFoAPMHmkAbbqP3dvmcPXLCzHUmzkUi9vfbezQOqAUSRIHCzHU8f)C0xveqKPIcPHI0Lll0Lf1LXOlFXph9wERlJ2O04sUCQuUmuq6EL0nd22c5YWYLbrxwSFyEAJ6hnN0rAc(tpmYXd6p4YUkg6X6h(EjUx7h(a8naKITiKlJPllsxwOltMIlsFvrarMkkKMl7QyixwOlFXphTuZqgfTGaO07HkgH04sUSqx(IFoAtILnGuZqgfTgxYLf6Yx8ZrVL36YOnknuKU(H5PnQF0CshPj4p9WaIpO)Gl7QyOhRF47L4ETFCXphTjXYgqQziJIwJl5YcDzrDzrDzFa(gasXweYLX0LLRll0Lf1LV4NJElV1LrBuACjxovkxMmfxKgCaMlcioaEL1ljOMl7QyixwmxwmxovkxwuxMmfxK(QIaImvuinx2vXqUSqx(IFo6RkciYurH04sUSqx2hGVbGuSfHCzmDzr6YI5YI9dZtBu)4WD43ahbCxIF6Hbe(b9hCzxfd9y9dFVe3R9dFa(gasXweYLX0LL7pmpTr9JgVampTrbOwe9d1IiGYaZ)araNTweCUrp9Wmv(h0FWLDvm0J1pmpTr9JgVampTrbOwe9d1IiGYaZ)arajCXTrrJE6PFaXhdxrpOpmtFq)bx2vXqpw)aKMcN)H8)W80g1paP1RDv8paP1aLbM)boIbi4THG)0ddgEq)bx2vXqpw)W80g1paP1RDv8paPPW5Fm9h(EjUx7hmie(kjXqAf(5yaPBtsARe0paP1aLbM)boIbi4THG)0dJiFq)bx2vXqpw)W3lX9A)W80csgakiDVsUmMUS8UCQuUmTGzxgtxEkS)H5PnQF04fG5Pnka1IOFOwebugy(hOTsumazDctp9Wi3h0FWLDvm0J1p89sCV2pWOltRxMTsC5uPC5l(5OL6iTsJl9dZtBu)Onz4NEyG9d6p4YUkg6X6h(EjUx7hy0LV4NJ2BeWjAWACPFyEAJ6hqgc(tpmYYd6pmpTr9ddNcaJiZlZp4YUkg6X6Phg54b9hCzxfd9y9dFVe3R9dYuCrAfEznWwiPTnAJsZLDvmKll0LXOltRxMTs(H5PnQFaoI6Snd4n6Phgq8b9hCzxfd9y9dFVe3R9dm6Yx8ZrJmqAjmqhwRXL(H5PnQFGmqAjmqhw)0ddi8d6pmpTr9Jl3iUL5hCzxfd9y90dZu5Fq)H5PnQFSL36YOnQFWLDvm0J1tpmtN(G(dZtBu)G2eUrah8wWFWLDvm0J1tpmtXWd6pmpTr9Jd3Mc40CjIf8hCzxfd9y90dZur(G(dUSRIHES(HVxI71(HOUmzkUinYUCtrqW1Czxfd5YPs5Yx8Zrl1mKrrliak9EOIrinUKllMll0LjtXfPVQiGitffsZLDvmKll0LV4NJ(QIaImvuinuKUCzHUSpaFdaPylc5YZUmS)H5PnQF0CshPj4p9WmvUpO)Gl7QyOhRF47L4ETF4dW3aqk2IqU8Sld7FyEAJ6h9k90dZuy)G(dUSRIHES(HVxI71(bgDzA9YSvIll0LbP1RDvSghXae82qWDzmDz5)H5PnQFqWBdbhWB0tpmtLLh0FyEAJ6hi4nd9dUSRIHESE6PFi1SpaFn6b9Hz6d6p4YUkg6X6Phgm8G(dUSRIHESE6HrKpO)Gl7QyOhRNEyK7d6p4YUkg6X6h(EjUx7hKP4I0xveqKPIcP5YUkg6hMN2O(rZjDKMG)0ddSFq)H5PnQFi1rA1p4YUkg6X6Phgz5b9hMN2O(H3iGt0G)bx2vXqpwp9WihpO)Gl7QyOhRNEyaXh0FyEAJ6hsbTr9dUSRIHESE6PF4JqbfPl0d6dZ0h0FWLDvm0J1p89sCV2pWOlFXphT3iGt0G14s)W80g1pGme8NEyWWd6p4YUkg6X6h(EjUx7hx8ZrVL36YOnkDZGTTqUmSCz51W2Lf6Yx8ZrlccVsumaImLmCRXL(H5PnQFi1rA1tpmI8b9hCzxfd9y9dFVe3R9dU4orqxgZzxwKY7YcDzrDzFekOiDPPnHBeWbVfu3myBlKlJPldBxovkx(IFoAAt4gbCWBb14sUSy)W80g1pUCJ4wMNEyK7d6p4YUkg6X6h(EjUx7hCXDIGAi(S(LCzmNDzzr(FyEAJ6h0MWnc4G3c(0ddSFq)H5PnQFC5gXTmBL8dUSRIHESE6HrwEq)bx2vXqpw)W3lX9A)WhGVbGuSfHC5zxwExwOlZf3jc6Yyo7YWw(FyEAJ6hScVyeqc(czLNF6HroEq)bx2vXqpw)W3lX9A)GlUte0LXC2LfP8USqxwux2hHcksxAAt4gbCWBb1nd22c5Yy6YtHTlNkLlFXphnTjCJao4TGACjxwSFyEAJ6hB5TUmAJ6Phgq8b9hCzxfd9y9dFVe3R9dY6eM00cMbOaaAzxgwUSSaBxovkxwuxMwWmafaql7YWYLNcIY7YcDzrD5l(5OVCJ4wgnUKlNkLlFXph9wERlJ2O04sUSyUSy)qkOnQFi1HkQegcqksZ9pmpTr9dPG2OE6Hbe(b9hCzxfd9y9dFVe3R9dFa(gasXweYLXC2LXGll0Lf1LXOltMIlsFvrarMkkKMl7Qyixovkx(IFo6RkciYurH04sUSy)W80g1poCBkGtZLiwWNEyMk)d6p4YUkg6X6h(EjUx7h(a8naKITiKldlxg2USqxMlUte0LXC2LnpTrPBtgw7de5YcDzOG0TjdRLaJROvsTC7YWYLXGEQll0LV4NJM2eUrah8wqnUKll0Lf1LV4NJ(QIaImvuinUKlNkLlJrxMmfxK(QIaImvuinx2vXqUSyUSqxwuxgJUmzkUi9wERlJ2O0Czxfd5YPs5Y(iuqr6sVL36YOnkDZGTTqUmMU8uq0LfZLf6Yy0LV4NJElV1LrBuACPFyEAJ6hi4guKgmRGE6Hz60h0FyEAJ6h4igyjgm6hCzxfd9y90t)araNTweCUrpOpmtFq)bx2vXqpw)4enqXYM(X0FyEAJ6hsrOaAgf4TNF6HbdpO)Gl7QyOhRF47L4ETFCXphnYaPLWaDyTgksx)W80g1pqgiTegOdRF6HrKpO)Gl7QyOhRFCIgOyzt)y6pmpTr9dPiuanJc82Zp9Wi3h0FWLDvm0J1pmpTr9JEL(HVxI71(bgP1lZwjPsjAZGTTqWAgcVnAJswLxlsXekkzDctA4SPi4AjpHjgGTqmsMIlsJSl3ueeCnx2vXqILkLOnd22cbRzi82OnkzvEnikuIB0IiUiaW4kALul3ycfKUxjTeyCfTsQLBXeswNWKMwWmafaqlJji(dY6eMa2ZpWiTEz2kjvkrBgSTfcwZq4TrBuYQ8ArkMqrjRtysdNnfbxl5jmXaSfIrYuCrAKD5MIGGR5YUkgsSuPeTzW2wiyndH3gTrjRYRbrHsCJweXfbagxrRKA5gtOG09kPLaJROvsTClMqY6eM00cMbOaaAzmbXNEyG9d6p4YUkg6X6hNObkw20pM(dZtBu)qkcfqZOaV98tpmYYd6p4YUkg6X6h(EjUx7hx8ZrJmqAjmqhwRBgSTfYLHLlpfd)W80g1pqgiTegOdRF6HroEq)byt2aCXDIG)y6pmpTr9Jd3HFdCeWDj(hCzxfd9y90t)arajCXTrrJEqFyM(G(dUSRIHES(HVxI71(bzkUi9vfbezQOqAUSRIHCzHU8f)C0sndzu0ccGsVhQyesJl5YcD5l(5OVQiGitffsdfPlxwOl7dW3aqk2IqUmMZUmgCzHUSpcfuKU0gcUb2kgbCAUeXcQBgSTfYLHLlN4H(H5PnQF0CshPj4p9WGHh0FWLDvm0J1p89sCV2pitXfPVQiGitffsZLDvmKll0LV4NJwQziJIwqau69qfJqACjxwOlFXph9vfbezQOqAOiD5YcDzFa(gasXweYLNDz56YcDzOG0TjdRBgSTfYLHLll3FyEAJ6hnN0rAc(tpmI8b9hCzxfd9y9dFVe3R9dgecFLKyiTTk8oaKc8YZnYLf6YKP4I0xveqKPIcP5YUkgYLf6YI6Yx8Zrl1mKrrliak9EOIrinImVmUmMUmgC5uPCzrD5l(5OLAgYOOfeaLEpuXiKgrMxgxgtxEQll0LHcs3MmSUzW2wixgwUSiDzXCzXCzHU8f)C0xveqKPIcPHI01pmpTr9JMt6inb)Phg5(G(dUSRIHES(HVxI71(bsIvkaY6eMq6BJtMcaPmeCxgtxE6pmpTr9JBJtMcaPme8NEyG9d6p4YUkg6X6hNObkw20pM(dZtBu)qkcfqZOaV98tpmYYd6p4YUkg6X6h(EjUx7hnFAgb3Uk2Lf6YI6YijwPaiRtycPj4THGd4nYLX0LXGll2pmpTr9dcEBi4aEJE6HroEq)bx2vXqpw)4enqXYM(X0FyEAJ6hsrOaAgf4TNF6HbeFq)bx2vXqpw)W3lX9A)ajXkfazDctinbVneCaVrUmMUSiDzHUmdcHVssmKwHFogq62KK2kb5YcDzYuCr6BJtMcaPmeCnx2vXq)W80g1pi4THGd4n6Phgq4h0FWLDvm0J1porduSSPFm9hMN2O(HuekGMrbE75NEyMk)d6p4YUkg6X6hMN2O(rBYW)W3lX9A)aJ06LzRKuPefJKP4I0xveqKPIcP5YUkgsyZGTTqWccVnAJswLxlsXeswNWKMwWmafaqlJPC)bzDcta75hyKwVmBLKkLOyKmfxK(QIaImvuinx2vXqcBgSTfcwq4TrBuYQ8ArkMqY6eM00cMbOaaAzmL7tpmtN(G(dUSRIHES(XjAGILn9JP)W80g1pKIqb0mkWBp)0dZum8G(dUSRIHES(H5PnQF0Mm8p89sCV2pitXfPVQiGitffsZLDvmKWl(5OVQiGitffsJljuurBgSTfcwZYHycL4gTiIlcamUIwj1YnMqbPBtgwlbgxrRKA5wwLxdIWwmHK1jmPPfmdqba0Yyk3FqwNWeWE(bzkUi9vfbezQOqAUSRIHeEXph9vfbezQOqACjHIkAZGTTqWAwoetOe3OfrCraGXv0kPwUXekiDBYWAjW4kALul3YQ8Aqe2IjKSoHjnTGzakaGwgt5(0dZur(G(dUSRIHES(HVxI71(HOU8f)C00MWnc4G3cQXLCzHUSOUCBleadsUiTbbH0B5Yy6YI6YtDzSDzWMSb8WToHrUmiOl7HBDcJaoT5Pnkt5YI5YYQl3ShU1jmaTGzxwmxwSFyEAJ6h3gNmfaszi4p9WmvUpO)Gl7QyOhRFyEAJ6hGJOoBZaEJ(HVxI71(rZNMrWTRI)bzDcta75hnFAgb3Uk(PhMPW(b9hCzxfd9y9Jt0aflB6ht)H5PnQFifHcOzuG3E(PhMPYYd6p4YUkg6X6h(EjUx7hnFAgb3Uk2Lf6YI6YG061UkwJJyacEBi4U8SlJbxovkxgjXkfazDctinbVneCaVrUmMU8uxwSFyEAJ6he82qWb8g90dZu54b9hCzxfd9y9dFVe3R9JMpnJGBxf7YcDzqA9AxfRXrmabVneCxE2LN6YcD5l(5O9k2AVHOTs0nBE6hMN2O(bbVneCaVrp9WmfeFq)bx2vXqpw)4enqXYM(X0FyEAJ6hsrOaAgf4TNF6Hzki8d6p4YUkg6X6h(EjUx7hijwPaiRtycPrPxjgWBKlJPlp9hMN2O(bk9kXaEJE6HbdY)G(dUSRIHES(HVxI71(buq62KH1nd22c5Yy6YI6YMN2O0i4ndP9bICzSDzZtBu62KH1(arUmiOlZf3jc6YI5YIWDzU4orqDZjC5YPs5Yx8Zr7vS1EdrBLOB280pmpTr9de8MHE6PN(HHtWJ(hYPwTYy7tp9p]] )
end