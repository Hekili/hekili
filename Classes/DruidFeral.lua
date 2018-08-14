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
            
            usable = function () return buff.apex_predator.up or combo_points.current > 0 end,
            handler = function ()
                if buff.apex_predator.up then
                    applyBuff( "predatory_swiftness" )
                    removeBuff( "apex_predator" )
                else
                    gain( 25, "energy" )
                    if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end
                    spend( min( 5, combo_points.current ), "combo_points" )
                end

                
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
                if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end
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
                if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end
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
                if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end

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
        damageDots = false,
        damageExpiration = 6,
    
        package = "Feral"
    } )


    spec:RegisterPack( "Feral", 20180728.1755, [[d0er0aqiKuwecL4rKQK6sKQeSjsLpbuOrrk1PiLSkGcEfczwij3cjvzxu1VaQggqPJPiTmKipdHQPbu01qqTnsvLVHKkJJuvohPkL1rQQY8qI6EazFKIoisQQfIapKuLqteHc6IiuGnsQQQpIqH6KiusRuOmtekQBsQsvTtHQFsQsvgkPkjlLuLkpvHPQiUkcfYxrOiTxL(RQAWKCyklgWJfmzqDzInRkFwiJgKoTkRgHI41iHztLBdIDl1VfnCK64iuQLl55qMoQRJOTJG8DfLXtQIZtkSEsvIMVIQ9d170DYoGnw24ucSt1hyPokPp)uQJWeF6oynOLDqBbkSizhTbr2H(xkZTdAtdxAW7KDGsYki7akZ0i9h4GhDmusaFiHao6Gq6m(You2JbhDqcGd4saWbEg1dwie40v(oNGaFYjfLMc(ekn9tmSip4V(xkZ5rhKWoaiphtS2lWoGnw24ucSt1hyPokPp)uQdSeNWu3oq0syJpfSeFhWckSJjqpewDiSIHkyfS8mshJv0wGclsWQxwyL(xkZHvxJveym7eS6Lfwr91lLkzOECmCmQpwfvIXyfSyoSkFyfdvWQzzrbwXjwHegRiPXk9VuMdRMziSkKqODclWyfGgyLEV2PrlECmCSPEScR07NesGXkIf6kN5iwWka5LLGvelbJ)VSGqSGvxJv0LesiagJvuF9kIzScDDqWknssScoBWiJvLyoNgyvlcmwXjwrIeSky8)LfeS6EyLgjjwHidbbHEKoNgyfDLZCcShhdhJsEScR07eijHeySsAPI0aRcqLafy1mOsJv0jn91ry1KlskWicR0)KLgEScRMavWky5zKogRO(6veZyvaQeOaHvVSWkdRGL3fogRYhwPFGLiSsAPI0GkScGKXk0bbRybXxhHviO5mewXqngRyOhcRGAiSQtScqA5DmwPDwy1HWkdRqUlckJved1RgyLlriT87GUY35KDOxJved0JeizbgRaKxwcwfsiagJvas01ipwr9dbHMryvNn1dQvqEKoSYc8LncRY2PHhhZc8LnYtxsiHaymONZquGJzb(Yg5PljKqamMiqG)YeghZc8LnYtxsiHaymrGa3iJGinB8LnoMf4lBKNUKqcbWyIabEjrvoJHs19aXMtA2d4YeMnx2iV0gGtGXXSaFzJ80LesiagteiWjKvNb4eQAdIaIejFgAziOuriZrkGaloMf4lBKNUKqcbWyIaboHS6maNqvBqeqKi5ZqldbLkczosb0uQUhiHytE00cS3r(E2Fwz00xhHWXSaFzJ80LesiagteiWPRCMdhZc8LnYtxsiHaymrGapy8)LfeCm9ASA0gncAYyvzhmwbq(EcmwHyJryfG8YsWQqcbWyScqIUgHvwdJv0Lq9OtMVocRoewbNT4XXSaFzJ80LesiagteiWrTrJGM8hXgJWXSaFzJ80LesiagteiWPt(YghdhtVgRigOhjqYcmwjesknWk(GiyfdvWklWzHvhcRmczNZaCIhhZc8LnceIcsN7dyiO4ywGVSrebc8IS)wGVS)UdXu1gebe66iN8zRIeMQ7bcozFD0E(cuCD0858br0CkHXXSaFzJice4LrHq19arn(cuCD085aKVNNUYzopjnoMf4lBerGah2qqP6EGOga575dg)FzbXtsJJzb(YgreiWnso)gZwGcCmlWx2iIaboKm73vYpymv3deBoPzVJST6FnI(kJVS9sBaobwh14lqX1r4ywGVSrebcCKrils(vAfv3de1aiFppYiKfj)kTYtsJJzb(YgreiWbKcjff4ywGVSrebc8Rdw1gFzJJzb(YgreiW5lsk0)rwAGJzb(YgreiWljQYzmuQUhiTzZjn7rgGuCMmuV0gGtGNphG8980LaBCwA8rZUh3cc5jP1shBoPzpGlty2CzJ8sBaobwha575bCzcZMlBKhoN16cjeG8tNxZiqeghZc8LnIiqGxhnv3duiHaKF68AgbIW4ywGVSrebcCgAziO)GXuDpquJVafxhPJqwDgGt8Ki5ZqldbvtWIJzb(YgreiWrqlbghdhZc8LnYhY0bNZAeiydbLQ7bIAaKVNpy8)LfepjnoMf4lBKpKPdoN1iIaboDLZCuDpqaKVN)6GvTXx2(sGyxJOmy9ewha575jMq2ro5JyZrHuEsACmlWx2iFithCoRrebcCaPqsrbv3dK0sfPHMGioy1PDithCoR98fjf6)iln8LaXUgPjHNphG8988fjf6)iln8K0AHJzb(Yg5dz6GZznIiqGZxKuO)JS0ahZc8LnYhY0bNZAerGahqkKuuCDeoMf4lBKpKPdoN1iIab(tkZ9FL06LAq19afsia5NoVMrGaloMf4lBKpKPdoN1iIab(1bRAJVSP6EGKwQin0eeXbRoTdz6GZzTNViPq)hzPHVei21inNs45ZbiFppFrsH(pYsdpjTw4ywGVSr(qMo4CwJice40jFztvBqeq0v6YosG)05mPO6EGyRIe2Zhe5Z5h(ekRFeE(CT5dI858dFcLNQpWQtBaY3Zdifskk8K0ZNdq(E(Rdw1gFz7jP1slCmlWx2iFithCoRrebcCeudoNbrCWuDpqHecq(PZRzeLjSoPLksdnbzb(Y2xgfIpKiwhCY(YOq80qiD8r7oPOmL8t1bq(EE(IKc9FKLgEsADAdq(EEaxMWS5Yg5jPNpNAS5KM9aUmHzZLnYlTb4eyT0Pn1yZjn7VoyvB8LTxAdWjWZNhY0bNZA)1bRAJVS9LaXUgP5u9PLoQbq(E(Rdw1gFz7jPXXSaFzJ8HmDW5SgreiWjrY)ybcchdhZc8LnYJUoYjF2QiHbfm()Yccv3de1aiFpFW4)lliEsACmlWx2ip66iN8zRIeMiqGxgfcv3dea575PRCMZtspFoa575rqn4CgeXb7jPXXSaFzJ8ORJCYNTksyIabUrY53y2cuGJzb(Yg5rxh5KpBvKWebc8G5CFlWx2F3HyQAdIakKPdoN1iCmlWx2ip66iN8zRIeMiqG)KkdxsI(ahluXwfj8)EGGt2xhTNVafxhPdozFD0(sGyxJOmX1XwfjSNpiYNZp8jAofS60MTksypuXCmupDGPmLi885S5KM9idqkotgQxAdWjWAHJzb(Yg5rxh5KpBvKWebc8sIQCgdLQ7bkKqaYpDEnJaryDaKVNNUeyJZsJpA294wqipjTo2CsZEaxMWS5Yg5L2aCcSoaY3Zd4YeMnx2ipCoR1Pn1aiFp)1bRAJVS9K0ZNdNSVoAFjqSRruwFAHJzb(Yg5rxh5KpBvKWebc8sIQCgdLQ7bkKqaYpDEnJ0K46yZjn7bCzcZMlBKxAdWjW6aiFppDjWgNLgF0S7XTGqEsADaKVN3Of98Plb24S8K06aiFp)1bRAJVS9W5SghZc8LnYJUoYjF2QiHjce4pPYWLKOpWXcv3dea575nArpF6sGnolpjToT1oKqaYpDEnJ0em1Pna575VoyvB8LTNKE(C2CsZEijeP5F((bNvhRHxAdWjWAP185AZMtA2d4YeMnx2iV0gGtG1bq(EEaxMWS5Yg5jP1fsia5NoVMrAsCT0chZc8LnYJUoYjF2QiHjce4fz)TaFz)DhIPQnicie)FxFiOsHO6EGcjeG8tNxZinbtCmlWx2ip66iN8zRIeMiqGxK93c8L93DiMQ2GiGq8psAPmoleogoMf4lBKhX)31hcQuiq0z6(LGsYkiu9Y63IEyqtXXSaFzJ8i()U(qqLcreiWrgHSi5xPvuDpqaKVNhzeYIKFLw5HZznoMf4lBKhX)31hcQuiIaboDMUFjOKSccvVS(TOhg0uCmlWx2ipI)VRpeuPqebc86OPITks4)9arn(cuCD085Axce7AeLbbtwgFzdgaRN4APtB2QiH9qfZXq90bwtkryDuJnN0ShzasXzYq9sBaobwR5Z1Uei21ikdcMSm(YgmawV(0rlf6qS08hcPJpA3jLMWj7RJ2tdH0XhT7KslDSvrc75dI858dFIM6dhZc8LnYJ4)76dbvkerGaNot3VeuswbHQxw)w0ddAkoMf4lBKhX)31hcQuiIaboYiKfj)kTIQ7bcG898iJqwK8R0kFjqSRruEkLWXSaFzJ8i()U(qqLcreiWFsLHljrFGJfQGy65lTurAaAkogoMf4lBKhX)iPLY4SqGkjQYzmuQUhi2CsZEaxMWS5Yg5L2aCcSoaY3ZtxcSXzPXhn7ECliKNKwha575bCzcZMlBKhoN16cjeG8tNxZiqGPo4K9LrH4lbIDnIYGjoMf4lBKhX)iPLY4Sqebc8sIQCgdLQ7bsi2KhnTa7TZrw5Noj7GuiDS5KM9aUmHzZLnYlTb4eyDAdq(EE6sGnoln(Oz3JBbH8i2cuOjLMpxBaY3ZtxcSXzPXhn7ECliKhXwGcnNQdozFzui(sGyxJOmX1slDaKVNhWLjmBUSrE4CwJJzb(Yg5r8psAPmolerGahOizZ9rodbLQ7bcrlo3NTksyKhOizZ9rodbvtybDLa)zRIegHJzb(Yg5r8psAPmolerGaNot3VeuswbHQxw)w0ddAkoMf4lBKhX)iPLY4SqebcCgAziO)GXuDpqL8kbb1aCIoTr0IZ9zRIeg5zOLHG(dgRjL0chZc8LnYJ4FK0szCwiIaboDMUFjOKSccvVS(TOhg0uCmlWx2ipI)rslLXzHice4m0Yqq)bJP6EGq0IZ9zRIeg5zOLHG(dgRjX1jeBYJMwG9oY3Z(ZkJM(6iKo2CsZEGIKn3h5meuV0gGtGXXSaFzJ8i(hjTugNfIiqGtNP7xckjRGq1lRFl6HbnfhZc8LnYJ4FK0szCwiIabEzuiuXwfj8)EGOgFbkUoA(CTPgBoPzpGlty2CzJ8sBaobwxjqSRrugMSm(YgmawpX1shBvKWE(GiFo)WNOjyIJzb(Yg5r8psAPmolerGaNot3VeuswbHQxw)w0ddAkoMf4lBKhX)iPLY4Sqebc8YOqOITks4)9aXMtA2d4YeMnx2iV0gGtG1bq(EEaxMWS5Yg5jP1PT2LaXUgrzquNw6OLcDiwA(dH0XhT7Kst4K9LrH4PHq64J2DsbgaRxFewlDSvrc75dI858dFIMGjoMf4lBKhX)iPLY4SqebcCGIKn3h5meuQUhiTbiFppFrsH(pYsdpjToTl7G)cHKM9gmmYFTMApLiiME(bOwfjiQxaQvrc6)klWx2MtlWqjbOwfjF(GiAPfoMf4lBKhX)iPLY4SqebcCiz2VRKFWyQyRIe(FpqL8kbb1aCcoMf4lBKhX)iPLY4SqebcC6mD)sqjzfeQEz9BrpmOP4ywGVSrEe)JKwkJZcreiWzOLHG(dgt19avYReeudWj60MqwDgGt8Ki5ZqldbfeLMphrlo3NTksyKNHwgc6pySMt1chZc8LnYJ4FK0szCwiIabodTme0FWyQUhOsELGGAaorhHS6maN4jrYNHwgckOP6aiFpFWjwfmeFDKVelW4ywGVSrEe)JKwkJZcreiWPZ09lbLKvqO6L1Vf9WGMIJzb(Yg5r8psAPmolerGahn7OLFWyQUhieT4CF2QiHrE0SJw(bJ1CkoMf4lBKhX)iPLY4SqebcCe0sGP6EGGt2xgfIVei21in12c8LThbTeyFirmrwGVS9LrH4djIPEslvKgAPxqAPI0WxsK0ZNdq(E(GtSkyi(6iFjwG3bHKcDzVXPeyNQpWsDuI4EknL4t3XmR6RJq7Gyk1xVloXACIX6pScRMavWQdcDwmw9YcRaJORJCYNTksyWiwvcXM8kbgRqjebRmsoHySaJvbOwhjipogX81cwrC9hwrmQrK00zXcmwzb(YgRaJgjNFJzlqby0JJHJrmL6R3fNynoXy9hwHvtGky1bHolgREzHvGry5zKogmIvLqSjVsGXkucrWkJKtiglWyvaQ1rcYJJrmFTGvew)HveJAejnDwSaJvwGVSXkWOrY53y2cuag94y4yeRqOZIfySs)WklWx2yL7qmYJJTdJKHM1oghe9I7WDigTt2b66iN8zRIeENSXNUt2H0gGtGxc2rOowQZ2b1WkaY3Zhm()YcINKEhwGVS3rW4)llilVXP0ozhsBaobEjyhH6yPoBhaKVNNUYzopjnwnFowbq(EEeudoNbrCWEs6Dyb(YEhLrHS8gN47KDyb(YEhgjNFJzlqXoK2aCc8sWYBCWCNSdPnaNaVeSdlWx27iyo33c8L93DiEhUdX)2Gi7iKPdoN1OL34eENSdPnaNaVeSJqDSuNTd4K91r75lqX1ryLoScozFD0(sGyxJWkkJvehR0HvSvrc75dI858dFcwPjwnfSyLoSsBSITksypuXCmupDGXkkJvuIWy185yfBoPzpYaKIZKH6L2aCcmwP1oSaFzVJNuz4ss0h4yz5nU(Tt2H0gGtGxc2rOowQZ2riHaKF68AgHvGWkcJv6WkaY3ZtxcSXzPXhn7ECliKNKgR0HvS5KM9aUmHzZLnYlTb4eySshwbq(EEaxMWS5Yg5HZznwPdR0gROgwbq(E(Rdw1gFz7jPXQ5ZXk4K91r7lbIDncROmwPpSsRDyb(YEhLev5mg6YBCQBNSdPnaNaVeSJqDSuNTJqcbi)051mcR0eRiowPdRyZjn7bCzcZMlBKxAdWjWyLoScG8980LaBCwA8rZUh3cc5jPXkDyfa575nArpF6sGnolpjnwPdRaiFp)1bRAJVS9W5SEhwGVS3rjrvoJHU8gxF7KDiTb4e4LGDeQJL6SDaq(EEJw0ZNUeyJZYtsJv6WkTXkTXQqcbi)051mcR0eRatSshwPnwbq(E(Rdw1gFz7jPXQ5ZXk2CsZEijeP5F((bNvhRHxAdWjWyLwyLwy185yL2yfBoPzpGlty2CzJ8sBaobgR0HvaKVNhWLjmBUSrEsASshwfsia5NoVMryLMyfXXkTWkT2Hf4l7D8KkdxsI(ahllVX1B7KDiTb4e4LGDeQJL6SDesia5NoVMryLMyfyUdlWx27Oi7Vf4l7V7q8oChI)Tbr2bI)VRpeuPqlVXNc2DYoK2aCc8sWoSaFzVJIS)wGVS)UdX7WDi(3gezhi(hjTugNfA5L3bS8mshVt24t3j7Wc8L9oquq6CFadbDhsBaobEjy5noL2j7qAdWjWlb7iuhl1z7aozFD0E(cuCDewnFowXhebR0eRMs4Dyb(YEhfz)TaFz)DhI3H7q8VniYoqxh5KpBvKWlVXj(ozhsBaobEjyhH6yPoBhudR4lqX1ry185yfa575PRCMZtsVdlWx27OmkKL34G5ozhsBaobEjyhH6yPoBhudRaiFpFW4)lliEs6Dyb(YEhWgc6YBCcVt2Hf4l7DyKC(nMTaf7qAdWjWlblVX1VDYoK2aCc8sWoc1XsD2oyZjn7DKTv)Rr0xz8LTxAdWjWyLoSIAyfFbkUoAhwGVS3bKm73vYpy8YBCQBNSdPnaNaVeSJqDSuNTdQHvaKVNhzeYIKFLw5jP3Hf4l7DGmczrYVsRwEJRVDYoSaFzVdaPqsrXoK2aCc8sWYBC92ozhwGVS3X1bRAJVS3H0gGtGxcwEJpfS7KDyb(YEh8fjf6)iln2H0gGtGxcwEJpD6ozhsBaobEjyhH6yPoBhAJvS5KM9idqkotgQxAdWjWy185yfa575Plb24S04JMDpUfeYtsJvAHv6Wk2CsZEaxMWS5Yg5L2aCcmwPdRaiFppGlty2CzJ8W5SgR0HvHecq(PZRzewbcRi8oSaFzVJsIQCgdD5n(ukTt2H0gGtGxc2rOowQZ2riHaKF68AgHvGWkcVdlWx27Oo6L34tj(ozhsBaobEjyhH6yPoBhudR4lqX1ryLoSIqwDgGt8Ki5ZqldbfR0eRa7oSaFzVdgAziO)GXlVXNcM7KDyb(YEhiOLaVdPnaNaVeS8Y7GUKqcbW4DYgF6ozhsBaobEjy5noL2j7qAdWjWlblVXj(ozhsBaobEjy5noyUt2H0gGtGxc2rOowQZ2bBoPzpGlty2CzJ8sBaobEhwGVS3rjrvoJHU8gNW7KDiTb4e4LGDqiZrk7aS7Wc8L9oiKvNb4KDqiR(Tbr2bjs(m0YqqxEJRF7KDiTb4e4LGDyb(YEheYQZaCYoiK5iLDmDhH6yPoBhcXM8OPfyVJ89S)SYOPVocTdcz1VniYoirYNHwgc6YBCQBNSdlWx27GUYzUDiTb4e4LGL346BNSdlWx27iy8)LfKDiTb4e4LGL346TDYoK2aCc8sWYB8PGDNSdlWx27Go5l7DiTb4e4LGLxEhHmDW5SgTt24t3j7qAdWjWlb7iuhl1z7GAyfa575dg)FzbXtsVdlWx27a2qqxEJtPDYoK2aCc8sWoc1XsD2oaiFp)1bRAJVS9LaXUgHvugRaRNWyLoScG898eti7iN8rS5Oqkpj9oSaFzVd6kN5wEJt8DYoK2aCc8sWoc1XsD2oKwQinWknbHvehSyLoSsBSkKPdoN1E(IKc9FKLg(sGyxJWknXkcJvZNJvaKVNNViPq)hzPHNKgR0AhwGVS3bGuiPOy5noyUt2Hf4l7DWxKuO)JS0yhsBaobEjy5noH3j7Wc8L9oaKcjffxhTdPnaNaVeS8gx)2j7qAdWjWlb7iuhl1z7iKqaYpDEnJWkqyfy3Hf4l7D8KYC)xjTEPglVXPUDYoK2aCc8sWoc1XsD2oKwQinWknbHvehSyLoSsBSkKPdoN1E(IKc9FKLg(sGyxJWknXQPegRMphRaiFppFrsH(pYsdpjnwP1oSaFzVJRdw1gFzV8gxF7KDiTb4e4LGDeQJL6SDWwfjSNpiYNZp8jyfLXk9JWy185yL2yfFqKpNF4tWkkJvt1hyXkDyL2yfa575bKcjffEsASA(CScG898xhSQn(Y2tsJvAHvATd6KVS3bDLUSJe4pDotQDyb(YEh0jFzV8gxVTt2H0gGtGxc2rOowQZ2riHaKF68AgHvugRimwPdRKwQinWknbHvwGVS9LrH4djIXkDyfCY(YOq80qiD8r7oPWkkJvuYpfR0HvaKVNNViPq)hzPHNKgR0HvAJvaKVNhWLjmBUSrEsASA(CSIAyfBoPzpGlty2CzJ8sBaobgR0cR0HvAJvudRyZjn7VoyvB8LTxAdWjWy185yvithCoR9xhSQn(Y2xce7AewPjwnvFyLwyLoSIAyfa575VoyvB8LTNKEhwGVS3bcQbNZGio4L34tb7ozhwGVS3bjs(hlqq7qAdWjWlblV8oq8)D9HGkfANSXNUt2H0gGtGxc2XlRFl6H34t3Hf4l7DqNP7xckjRGS8gNs7KDiTb4e4LGDeQJL6SDaq(EEKrils(vALhoN17Wc8L9oqgHSi5xPvlVXj(ozhsBaobEjyhVS(TOhEJpDhwGVS3bDMUFjOKScYYBCWCNSdPnaNaVeSJqDSuNTdQHv8fO46iSA(CSsBSQei21iSIYGWkyYY4lBScmGvG1tCSslSshwPnwXwfjShQyogQNoWyLMyfLimwPdROgwXMtA2JmaP4mzOEPnaNaJvAHvZNJvAJvLaXUgHvugewbtwgFzJvGbScSE9Hv6WkAPqhILM)qiD8r7oPWknXk4K91r7PHq64J2DsHvAHv6Wk2QiH98br(C(HpbR0eR03oSaFzVJ6OxEJt4DYoK2aCc8sWoEz9Brp8gF6oSaFzVd6mD)sqjzfKL3463ozhsBaobEjyhH6yPoBhaKVNhzeYIKFLw5lbIDncROmwnLs7Wc8L9oqgHSi5xPvlVXPUDYoGy65lTurASJP7Wc8L9oEsLHljrFGJLDiTb4e4LGLxEhi(hjTugNfANSXNUt2H0gGtGxc2rOowQZ2bBoPzpGlty2CzJ8sBaobgR0HvaKVNNUeyJZsJpA294wqipjnwPdRaiFppGlty2CzJ8W5SgR0HvHecq(PZRzewbcRatSshwbNSVmkeFjqSRryfLXkWChwGVS3rjrvoJHU8gNs7KDiTb4e4LGDeQJL6SDieBYJMwG925iR8tNKDqkewPdRyZjn7bCzcZMlBKxAdWjWyLoSsBScG8980LaBCwA8rZUh3cc5rSfOaR0eROewnFowPnwbq(EE6sGnoln(Oz3JBbH8i2cuGvAIvtXkDyfCY(YOq8LaXUgHvugRiowPfwPfwPdRaiFppGlty2CzJ8W5SEhwGVS3rjrvoJHU8gN47KDiTb4e4LGDeQJL6SDGOfN7ZwfjmYduKS5(iNHGIvAIvWc6kb(ZwfjmAhwGVS3bqrYM7JCgc6YBCWCNSdPnaNaVeSJxw)w0dVXNUdlWx27Got3Veuswbz5noH3j7qAdWjWlb7iuhl1z7OKxjiOgGtWkDyL2yfIwCUpBvKWipdTme0FWySstSIsyLw7Wc8L9oyOLHG(dgV8gx)2j7qAdWjWlb74L1Vf9WB8P7Wc8L9oOZ09lbLKvqwEJtD7KDiTb4e4LGDeQJL6SDGOfN7ZwfjmYZqldb9hmgR0eRiowPdReIn5rtlWEh57z)zLrtFDecR0HvS5KM9afjBUpYziOEPnaNaVdlWx27GHwgc6py8YBC9Tt2H0gGtGxc2XlRFl6H34t3Hf4l7DqNP7xckjRGS8gxVTt2H0gGtGxc2rOowQZ2b1Wk(cuCDewnFowPnwrnSInN0ShWLjmBUSrEPnaNaJv6WQsGyxJWkkJvWKLXx2yfyaRaRN4yLwyLoSITksypFqKpNF4tWknXkWChwGVS3rzuilVXNc2DYoK2aCc8sWoEz9Brp8gF6oSaFzVd6mD)sqjzfKL34tNUt2H0gGtGxc2rOowQZ2bBoPzpGlty2CzJ8sBaobgR0HvaKVNhWLjmBUSrEsASshwPnwPnwvce7Aewrzqyf1HvAHv6WkAPqhILM)qiD8r7oPWknXk4K9LrH4PHq64J2DsHvGbScSE9rySslSshwXwfjSNpiYNZp8jyLMyfyUdlWx27OmkKL34tP0ozhsBaobEjyhH6yPoBhAJvaKVNNViPq)hzPHNKgR0HvAJvLDWFHqsZEdgg5VgR0eR0gRMIveHvqm98dqTksqyf1dRcqTksq)xzb(Y2CyLwyfyaRkja1Qi5ZhebR0cR0AhwGVS3bqrYM7JCgc6YB8PeFNSdPnaNaVeSJqDSuNTJsELGGAaozhwGVS3bKm73vYpy8YB8PG5ozhsBaobEjyhVS(TOhEJpDhwGVS3bDMUFjOKScYYB8PeENSdPnaNaVeSJqDSuNTJsELGGAaobR0HvAJveYQZaCINejFgAziOyfiSIsy185yfIwCUpBvKWipdTme0FWySstSAkwP1oSaFzVdgAziO)GXlVXNQF7KDiTb4e4LGDeQJL6SDuYReeudWjyLoSIqwDgGt8Ki5ZqldbfRaHvtXkDyfa575doXQGH4RJ8LybEhwGVS3bdTme0FW4L34tPUDYoK2aCc8sWoEz9Brp8gF6oSaFzVd6mD)sqjzfKL34t13ozhsBaobEjyhH6yPoBhiAX5(SvrcJ8OzhT8dgJvAIvt3Hf4l7DGMD0Ypy8YB8P6TDYoK2aCc8sWoc1XsD2oGt2xgfIVei21iSstSsBSYc8LThbTeyFirmwrewzb(Y2xgfIpKigROEyL0sfPbwPfwPxaRKwQin8LejnwnFowbq(E(GtSkyi(6iFjwG3Hf4l7DGGwc8YlV8YlVla]] )
end