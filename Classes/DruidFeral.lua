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


    --[[ spec:RegisterStateExpr( 'gcd', function()
        return buff.cat_form.up and 1.0 or max( 0.75, 1.5 * haste )
    end ) ]]


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
            elseif subtype == "SPELL_CAST_SUCCESS" and spellID == class.abilities.rip.id then
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


    spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
        rip_applied = false
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

                local x = 25
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

            essential = true,
            
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
                removeBuff( "lunar_empowerment" )
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
                if buff.cat_form.down or not buff.prowl.up then return buff.predatory_swiftness.up or time == 0 or boss end
                return true
            end,
            recheck = function () return buff.bloodtalons.remains end,
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
            form = "cat_form",
            
            usable = function () return combo_points.current > 0 end,
            recheck = function () return dot.rip.remains - dot.rip.duration * 0.3, dot.rip.remains end,
            handler = function ()
                if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end
                spend( combo_points.current, "combo_points" )

                applyDebuff( "target", "rip", min( 1.3 * class.auras.rip.duration, debuff.rip.remains + class.auras.rip.duration ) )
                debuff.rip.pmultiplier = persistent_multiplier
                removeStack( "bloodtalons" )

                opener_done = true
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
                removeBuff( "solar_empowerment" )
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
                applyBuff( "solar_empowerment" )
                applyBuff( "lunar_empowerment" )
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
                return 35 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )
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
    
        potion = "battle_potion_of_agility",
    
        package = "Feral"
    } )


    spec:RegisterPack( "Feral", 20180918.1319, [[d4e6(aqiePweIKKhHiCjQufSjjXNqKuJce5uGOwfIO6viQMfu0TGsyxs8laAyssDma1YOsLNbaMguIUgaABss4BiI04KK05qKW6ab6DuPk08Gs6EG0(aHoiIeTqOupKkvPjIiIUiIKuBKkv1hbGWjreLvsfntaOCtaiANqHFcavdvsIwkiGNQstfqUkIi0xrKe7fYFryWQ6WuwmOEmvnzGUmQndvFwfgTK60kTAerWRPcnBsDBv0Uv8BHHtIJtLQOLl1ZrA6exNK2ovkFNkz8GGopIY6bG08Pc2VOraJacDbnHry4UQbUQvtkaUQfGbaGjfUdDfYuy0vX8oAhm6o2jJUUp3MgDvmY0HbIacDPHA7z0TwefkeeqapwPwfU4JtaP7PQ2KngFB4cG090diSoGbeg3Wcq2nav6aF1mfWQSziGTGuaRsiabjzRUGeUp3MUq3tp6cRUAHKniy0f0egHH7Qg4QwnPa4QwagaagGyzvGUuf2JWa4Qba0fKPE0Le57(CB68jjB1fmDsI8RfrHcbbeWJvQvHl(4eq6EQQnzJX3gUaiDp9acRdyaHXnSaKDdqLoWxntbSkBgcylifWQecqqs2QliH7ZTPl090Nojr(xwr4tyUZhlXmF3vnWvnFSi)QaccavNFvcGmDMojr(U3ABoykemDsI8XI8jLGGmy(xhv168X2O1L0jjYhlYNuccYG5JDRkMo)R2O1aEDTkC(sKFOWd35Vt(NQAzXcX6dwkPtsKpwKFvQnpdMV71K8D)OpZ3WfUZVk7WLoF6oEo)QSdx68LEpo4MMV71K8D)OplPtsKpwKFOWd3eGXW5V08RTbuZG5VJW9yAnz5dtw(snNVbcgJ7X8B(mCJbZxQzkNVBwVgSMPf0vPd8vZOljY395205ts2Qly6Ke5xlIcfcciGhRuRcx8XjG09uvBYgJVnCbq6E6bewhWacJBybi7gGkDGVAMcyv2meWwqkGvjeGGKSvxqc3NBtxO7PpDsI8VSIWNWCNpwIz(URAGRA(yr(vbeeaQo)Qeaz6mDsI8DV12CWuiy6Ke5Jf5tkbbzW8VoQQ15JTrRlPtsKpwKpPeeKbZh7wvmD(xTrRb86Av48Li)qHhUZFN8pv1YIfI1hSusNKiFSi)QuBEgmF3Rj57(rFMVHlCNFv2HlD(0D8C(vzhU05l9ECWnnF3Rj57(rFwsNKiFSi)qHhUjaJHZFP5xBdOMbZFhH7X0AYYhMS8LAoFdemg3J538z4gdMVuZuoF3SEnyntlPZ0jjYNuneYEvHbZhMXJMZ3hNWMKpmFSdTKpP07zfHM)edwuB9jUQoFZlBm08JrtwjDAEzJHwuA2hNWMafxBuhtNMx2yOfLM9XjSjKdfq8iatNMx2yOfLM9XjSjKdfqt94KhXKnM0P5LngArPzFCcBc5qbS5JoCj1yU4qftZJuG1rakMogAHhdwZGPtsKpjtYFP57kAPo)vYhp68n9zqL8z34MSy48Li)tBhX2jFPUnAD608YgdTO0SpoHnHCOa6M1RbRzmh7KHQszcPUnAnMUzAvgQ7sNMx2yOfLM9XjSjKdfq3SEnynJ5yNmuvkti1TrRX0ntRYqbgZfhQbGY9kCrjCXnrGti1mXzetHhdwZGPtsKpaUcpCNpqUF(lnFqwBKXG5V457IZFygmFjYV2AqVrL8B(OdxsD(At4o)yYFN8LAo)oet2ysNMx2yOfLM9XjSjKdfq3SEnynJ5yNmuqwBKXGecorOWd3y6MPvzOvNojr(avV08RnffEO57QMN8Vgm3sesnM5JTocqX0XqZhwvYFcjFamsw(lnFX08imy608YgdTO0SpoHnHCOa6M1RbRzmh7KHcYAJmgKqWjcfE4gt3mTkdfymxCOIP5rkudMBjcPUWJbRzWkIP5rkW6iafthdTWJbRzWkKwmnpsrRowtSdvzBt2yk8yWAgmDAEzJHwuA2hNWMqouav6WLoDAEzJHwuA2hNWMqoua9MqGh9z6Ke5FhtHwhs(TTG5dRIJZG5tftO5dZ4rZ57JtytYhMp2HMVnG5R0mwOeISZr(lnFWy4s608YgdTO0SpoHnHCOashtHwhcbvmHMonVSXqlkn7JtytihkGkHSXKonVSXqlkn7JtytihkGWCt52X0z6Ke5tQgczVQWG5ZUXnz5l7jNVuZ5BEj68xA(MB2QnynxsNMx2yOqnvjimrmVJyU4qjnSkoErPdx6IQsfsdRIJxO1gy46K1GfvL0P5Lngk5qbK6OQwtaB0AmxCOKgwfhVO0HlDrvPcPHvXXl0AdmCDYAWIQs608YgdLCOa2QdH5Lngc9sfmh7KHgk8WnMloushk8WnbymC608YgdLCOa2QdH5Lngc9sfmh7KHs35qZeI1hSKotNMx2yOfFeAWW1qHcA0AmxCOKgwfhV4nHap6ZIQs608YgdT4JqdgUgk5qbuPdxAmxCOWQ44LD8wpMSXuA(02HI1QlaScSkoEHKG6COzcQyAh5UOQKonVSXql(i0GHRHsouaH5MYTJyU4q5H7dYGiuaO6kqYhHgmCnfzp4MsGR2KvA(02Hcra6GdWQ44fzp4MsGR2KvuvGC608YgdT4JqdgUgk5qbu2dUPe4QnzyU4q5H7dYkGm(6xbIqRIQtNMx2yOfFeAWW1qjhkGWCt52XDosNMx2yOfFeAWW1qjhkG4CBAc8MhauYWCXH6Jt4Gqj2rOqRoDAEzJHw8rObdxdLCOaUJ36XKngmxCO8W9bzqekauDfi5JqdgUMIShCtjWvBYknFA7qHiWa0bhGvXXlYEWnLaxTjROQa50P5LngAXhHgmCnuYHcOsiBmyo2jdf2erZekHSXqe4e2XQxHmmxCOI1hSuK9KjKGaCzSwfa0bhGKSNmHeeGlJvGRA1vGeSkoEbMBk3owuvCWbyvC8YoERht2ykQkqgYPtZlBm0Ipcny4AOKdfqATbgUozniMlouFCchekXocfRaScpCFqgeHAEzJP0MJCXhuPcyiL2CKlkNQAzv0l3y1DfGRaRIJxK9GBkbUAtwrvPcKGvXXlW6iafthdTOQ4GdKwmnpsbwhbOy6yOfEmyndc5kqI0IP5rk74TEmzJPWJbRzqhCWhHgmCnLD8wpMSXuA(02HcrGRkKRqAyvC8YoERht2ykQkPtZlBm0Ipcny4AOKdfqvktScFstNPtsKpjYhOAo)qHhUZ)GhUnTMS8XdToCLVuZ5RJJ1NFGNVuZ53mvYpWZxQ58nfnM5dRk5V08PSI1MWG5hQs(1CZ5JhD(64y9MoFV26vilDsI8bWv4zNJ8bY9Z31Q15dZ5dYAJmgm)fpFxC(dZG5lr(1wd6nQKV2eUZhsUQxFD(1MIcp08DTsD(udMBjcPo)k5dl5dRk5pr(6fYPtsKpaUuZTRLY57IZ31Q15hk8KVRvQZhi3hZ8jluZ3Bt(udN1KLV3Os(s9sZhVJZ8PcBAPoFxRuhQs(WnBoUZr(RusNMx2yOLqHhUHk7b3ucC1MmmxCOUz9AWAUaYAJmgKqWjcfE4gA1PtsKpPu7YiJMFOWt(UwPo)2CKXmFFmu1ZDoYNkSPL68Tbm)y48XgO891wFW5dPfpFX08imiKtNMx2yOLqHhUjhkGT5iJ5IdL0Y6DCNdhCawfhVO0HlDrvjDsI8bWyHM)P5iNpvT58DX5Zdy(snNFOWd35tQIYUNQ84zsv57QMN8d1oF8TPs(9QK)sZxwVJ7CKojr(Mx2yOLqHhUjhkGUz9AWAgZXozOHcpCtagdJPBMwLHcgsPxLISEh35iDsI8XUzZX8dvj)apFPMZ38Ygt(6LkPtZlBm0sOWd3Kdfqx2kyszp0QlvxnWyU4qbdP0RsrwVJ7CKojr(Km88DX5xBUX5dGrYWmFBaZV2CJhsTKVPOOxgm)vYNmwYxLY5FgXGVnxsNKiFaCiaM5V457IZpgnz5xBUX5hdNp2aLVV26doFZlRBC(uf7m)Zig8T58vhz157IZ3Bt(MIIMS87vjFxRuN)kPtZlBm0sOWd3KdfWZig8TzcVjyU4qjTSEh35WbhGvXXlW6iafthdTqfZ7iuGR4Jt4Gqj2rOyfGPtsKpaI1nEY3R2nps(I6SZr(RK)sZ30UmYO57kAPo)tBhX2zNJ8L62O1yMpnYxZcnFtrrtw(RKFn3CjDAEzJHwcfE4MCOak1TrRXCXHsAz9oUZrfFCchekXocfRamDsI8XUvftN)vB0683jFaCfE4oFxRuNV7ipFX6dwOL0P5LngAju4HBYHciCRkMMGQnAnMlouQcR1eI1hSqHiWv8XjCqOe7iuScW0jjY)6Av483jFaCfE4oFxRuNV7ipFX6dwOL0P5LngAju4HBYHci11QWeEtWCXHsvyTMqS(GfkebUIpoHdcLyhHIvaMojr(KYbm)fp)jgo)apFPMZ3Gd348nffnzyMVloF6EQOjlFADZG5RoYQZhGPtZlBm0sOWd3KdfqADZGyU4q9XjCqOe7iuScW0jjYhcWhD4sQXmFx18KVlo)AZnoFaMVpoHJ8vIDeA(2aMpSocqX0XqZ3gW85vQ5gcMojr(KkC(1MBC(xdMBjcPoFBaZFI8nVSUX5dRJaumDm08PI5DmFi52A5dG09ZNQyNqoF2nEYFXZFL8B29uDBMMVLFT1G57nQKojr(KkC(1MBC(w(kndAs0KLp11IldtP5R0HpFZnB1gSMZhsUTw(xiq(4lTENdiNonVSXqlHcpCtouaB(OdxsnMlouFCchekXocfkaRiMMhPaRJaumDm0cpgSMbRajX08ifQbZTeHux4XG1myfyvC8cSocqX0XqlGHRXbhGvXXlkndAs0KrqDT4YWuArvbYPtsKpjdpFxC(8aYG5RQKFT1GEJk7CKpeGp6WLuJz(QuoFGC)8Li)MXcEeUZ3Bs(4rFMonVSXqlHcpCtouaL9GBkbUAtw6Ke5tkhW8JXZ57IZ)GL8R5MZ3K8by((4eoiuIDekM5tsqLk53Rs(2aMVloFR58vvY3gW8B1z25iDAEzJHwcfE4MCOa2RcMlouFCchekXocfkatNPtZlBm0cDNdntiwFWcuVje4rFI5IdL0WQ44fVje4rFwuvsNMx2yOf6ohAMqS(GfYHcyBoYyU4qHvXXlkD4sxuvCWbyvC8cT2adxNSgSOQKonVSXql0Do0mHy9blKdfqtvccteZ7y608YgdTq35qZeI1hSqoua9MwtyEzJHqVubZXozO(i0GHRHMonVSXql0Do0mHy9blKdfqCUd)gQuc4vymfRpyHyXHcgsPxLISEh35OcyiLEvknFA7qXkaurS(GLISNmHeeGldrGRUcKeRpyPuZMwQlkEbRUdGo4GyAEKc1G5wIqQl8yWAgeYPtZlBm0cDNdntiwFWc5qbS5JoCj1yU4q9XjCqOe7iuOaScSkoErPzqtIMmcQRfxgMslQkvetZJuG1rakMogAHhdwZGvGvXXlW6iafthdTagUMkqI0WQ44LD8wpMSXuuvCWbWqk9QuA(02HI1Qc50P5LngAHUZHMjeRpyHCOa2QdH5Lngc9sfmh7KHsfc8DwAn3umxCO(4eoiuIDekeXY0P5LngAHUZHMjeRpyHCOa2QdH5Lngc9sfmh7KHsfIdE42KOPPZ0P5LngAHke47S0AUPqvIqt0mnuBpJjE0eddHcuGtNMx2yOfQqGVZsR5MsouaPMB2bt0H1yU4qHvXXluZn7Gj6W6cy4AsNMx2yOfQqGVZsR5MsouavIqt0mnuBpJjE0eddHcuGtNMx2yOfQqGVZsR5Msoua7vbtX6dwiwCOKwwVJ7C4GdqQ5tBhkwHcQ2MSXqYRUaaqUcKeRpyPuZMwQlkEbIUdGviTyAEKc1G5wIqQl8yWAgeYo4aKA(02HIvOGQTjBmK8QlvTIc30Lk8ieNQAzv0l3qemKsVkfLtvTSk6LBixrS(GLISNmHeeGldXQMonVSXqluHaFNLwZnLCOaQeHMOzAO2Egt8OjggcfOaNonVSXqluHaFNLwZnLCOasn3SdMOdRXCXHcRIJxOMB2bt0H1LMpTDOyfy3LonVSXqluHaFNLwZnLCOaIZD43qLsaVcJ5PbHe8W9bzqboDMonVSXqluH4GhUnjAk0Mp6WLuJ5IdvmnpsbwhbOy6yOfEmyndwbwfhVO0mOjrtgb11IldtPfvLkWQ44fyDeGIPJHwadxtfFCchekXocfkwwbmKsBoYLMpTDOyfltNMx2yOfQqCWd3MenLCOa28rhUKAmxCOIP5rkW6iafthdTWJbRzWkWQ44fyDeGIPJHwadxtfyvC8IsZGMenzeuxlUmmLwuvQiMMhPOvhRj2HQSTjBmfEmyndwbmKsBoYLMpTDOyf40P5LngAHkeh8WTjrtjhkGWTQyAcQ2O1yU4qPkSwtiwFWcTa3QIPjOAJwdrqMUndsiwFWcnDAEzJHwOcXbpCBs0uYHcOseAIMPHA7zmXJMyyiuGcC608YgdTqfIdE42KOPKdfqPUnAnH3emxCOnJ3mT2G1CfirvyTMqS(GfArQBJwt4nbIUdYPtZlBm0cvio4HBtIMsouavIqt0mnuBpJjE0eddHcuGtNMx2yOfQqCWd3MenLCOa2MJmMI1hSqS4qjTSEh35WbhGePftZJuG1rakMogAHhdwZGvA(02HIvq12KngsE1faaYveRpyPi7jtibb4YqeltNMx2yOfQqCWd3MenLCOaQeHMOzAO2Egt8OjggcfOaNonVSXqluH4GhUnjAk5qbSnhzmfRpyHyXHkMMhPaRJaumDm0cpgSMbRaRIJxG1rakMogArvPcKGuZN2ouScLKc5kkCtxQWJqCQQLvrVCdrWqkT5ixuov1YQOxUj5vxQkaHCfX6dwkYEYesqaUmeXY0jjYNuzL68bWiz5xjFSbcZ8DX57TjFvkN)zed(2C(sKp1CJZhBGY3xB9btXmFtRdx7CKVknFjYhMfH78BgVzAD(T5iNonVSXqluH4GhUnjAk5qb8mIbFBMWBcMlouyvC8cSocqX0XqlQkvGvXXlkndAs0KrqDT4YWuAbmCnv8XjCqOe7iuScW0P5LngAHkeh8WTjrtjhkGWTQyAcQ2O1yU4qHeSkoEr2dUPe4QnzfvLkqQTfKGDJhPyGG0Yoqesat(PbHe(ARpykw4RT(GPe4T5LngtdzsEZ(ARpyczpzid50P5LngAHkeh8WTjrtjhkGNrm4BZeEtWuS(GfIfhAZ4ntRnynNonVSXqluH4GhUnjAk5qbujcnrZ0qT9mM4rtmmekqboDAEzJHwOcXbpCBs0uYHcOu3gTMWBcMlo0MXBMwBWAUcKCZ61G1CrLYesDB0AOUZbhOkSwtiwFWcTi1TrRj8MarGHC608YgdTqfIdE42KOPKdfqPUnAnH3emxCOnJ3mT2G1Cf3SEnynxuPmHu3gTgkWvGvXXlEnBT3OYohLMnVKonVSXqluH4GhUnjAk5qbujcnrZ0qT9mM4rtmmekqboDAEzJHwOcXbpCBs0uYHci11QWeEtWCXHsvyTMqS(GfAH6AvycVjqe40P5LngAHkeh8WTjrtjhkG06MbXCXHcRIJx8A2AVrLDoknBEjDAEzJHwOcXbpCBs0uYHc4zed(2mH3emxCOgak3RWfLWf3eboHuZeNrmfEmyndMonVSXqluH4GhUnjAk5qbKw3miMlouWqkT5ixA(02HcrizEzJPqRBgS4dQqU5LnMsBoYfFqfSGhUpidYUh4H7dYknFWJdoaRIJx8A2AVrLDoknBEbDDJB6gdcd3vnWvTAsr1aSuD1aKuGUUSE25GIUKkKsiagKmmaqabZpFGQ583tLOL8XJoFsniJBQAHuNFZUNQBZG5tJtoFtvIttyW8912CW0s6eaBhoFGHG5tsCOQkkrlmy(Mx2yYNuBQsqyIyEhj1L0z6KuHucbWGKHbaciy(5dunN)EQeTKpE05tQP7COzcX6dwi153S7P62my(04KZ3uL40egmFFTnhmTKobW2HZhaGG5tsCOQkkrlmy(Mx2yYNuBQsqyIyEhj1L0z6KKDQeTWG5tsZ38Ygt(6Lk0s6eD1lvOiGq3qHhUraHWayeqOlpgSMbryJU(EfUxdDDZ61G1CbK1gzmiHGtek8WD(qZVA018Ygd6k7b3ucC1MmKGWWDiGqxEmyndIWgD99kCVg6s68L174oh57Gd5dRIJxu6WLUOQGUMx2yq32CKrccdaabe6YJbRzqe2OlL9OB1LQRgy018Ygd66YwbD99kCVg6cgsPxLISEh35ajimWseqOlpgSMbryJU(EfUxdDjD(Y6DCNJ8DWH8HvXXlW6iafthdTqfZ7y(qZh48RKVpoHdcLyhHMpwZhGOR5Lng09mIbFBMWBcsqyaqeqOlpgSMbryJU(EfUxdDjD(Y6DCNJ8RKVpoHdcLyhHMpwZhGOR5Lng0vQBJwJeegvbci0LhdwZGiSrxFVc3RHUufwRjeRpyHMpeZh48RKVpoHdcLyhHMpwZhGOR5Lng0fUvfttq1gTgjimiPiGqxEmyndIWgD99kCVg6svyTMqS(GfA(qmFGZVs((4eoiuIDeA(ynFaIUMx2yqxQRvHj8MGeegvfbe6YJbRzqe2ORVxH71qxFCchekXocnFSMparxZlBmOlTUzqKGWGuGacD5XG1micB013RW9AORpoHdcLyhHMp08by(vYxmnpsbwhbOy6yOfEmyndMFL8Hu(IP5rkudMBjcPUWJbRzW8RKpSkoEbwhbOy6yOfWW1KVdoKpSkoErPzqtIMmcQRfxgMslQk5dz018Ygd628rhUKAKGWa4QraHUMx2yqxzp4MsGR2KHU8yWAgeHnsqyamWiGqxEmyndIWgD99kCVg66Jt4Gqj2rO5dnFaIUMx2yq3Evqcsqxqg3u1cciegaJacD5XG1micB013RW9AOlPZhwfhVO0HlDrvj)k5t68HvXXl0AdmCDYAWIQc6AEzJbDnvjimrmVJibHH7qaHU8yWAgeHn667v4En0L05dRIJxu6WLUOQKFL8jD(WQ44fATbgUoznyrvbDnVSXGUuhv1AcyJwJeegaaci0LhdwZGiSrxFVc3RHUKo)qHhUjaJHrxZlBmOBRoeMx2yi0lvqx9sfIXoz0nu4HBKGWalraHU8yWAgeHn6AEzJbDB1HW8YgdHEPc6QxQqm2jJU0Do0mHy9blibjORsZ(4e2eeqimagbe6YJbRzqe2ibHH7qaHU8yWAgeHnsqyaaiGqxEmyndIWgjimWseqOlpgSMbryJU(EfUxdDftZJuG1rakMogAHhdwZGOR5Lng0T5JoCj1ibHbaraHU8yWAgeHn66MPvz01DOR5Lng01nRxdwZORBwtm2jJUQuMqQBJwJeegvbci0LhdwZGiSrxZlBmORBwVgSMrx3mTkJUaJU(EfUxdDnauUxHlkHlUjcCcPMjoJyk8yWAgeDDZAIXoz0vLYesDB0AKGWGKIacD5XG1micB01ntRYOB1OR5Lng01nRxdwZORBwtm2jJUGS2iJbjeCIqHhUrccJQIacD5XG1micB018Ygd66M1RbRz01ntRYOlWORVxH71qxX08ifQbZTeHux4XG1my(vYxmnpsbwhbOy6yOfEmyndMFL8jD(IP5rkA1XAIDOkBBYgtHhdwZGORBwtm2jJUGS2iJbjeCIqHhUrccdsbci018Ygd6Q0Hln6YJbRzqe2ibHbWvJacDnVSXGUEtiWJ(eD5XG1micBKGWayGraHU8yWAgeHnsqyaS7qaHUMx2yqxLq2yqxEmyndIWgjimagaqaHUMx2yqxyUPC7i6YJbRzqe2ibjORpcny4AOiGqyamci0LhdwZGiSrxFVc3RHUKoFyvC8I3ec8OplQkOR5Lng0f0O1ibHH7qaHU8yWAgeHn667v4En0fwfhVSJ36XKnMsZN2o08XA(vxay(vYhwfhVqsqDo0mbvmTJCxuvqxZlBmORshU0ibHbaGacD5XG1micB013RW9AOlpCFqw(qeA(aq15xjFiLVpcny4AkYEWnLaxTjR08PTdnFiMpaZ3bhYhwfhVi7b3ucC1MSIQs(qgDnVSXGUWCt52rKGWalraHU8yWAgeHn667v4En0LhUpiRaY4RFL8Hi08RIQrxZlBmORShCtjWvBYqccdaIacDnVSXGUWCt52XDoqxEmyndIWgjimQceqOlpgSMbryJU(EfUxdD9XjCqOe7i08HMF1OR5Lng0fNBttG38aGsgsqyqsraHU8yWAgeHn667v4En0LhUpilFicnFaO68RKpKY3hHgmCnfzp4MsGR2KvA(02HMpeZhyaMVdoKpSkoEr2dUPe4QnzfvL8Hm6AEzJbD3XB9yYgdsqyuveqOlpgSMbryJU(EfUxdDfRpyPi7jtibb4Y5J18RcaMVdoKpKYx2tMqccWLZhR5dCvRo)k5dP8HvXXlWCt52XIQs(o4q(WQ44LD8wpMSXuuvYhY5dz0vjKng0f2erZekHSXqe4e2XQxHm018Ygd6QeYgdsqyqkqaHU8yWAgeHn667v4En01hNWbHsSJqZhR5dW8RKppCFqw(qeA(Mx2ykT5ix8bvYVs(GHuAZrUOCQQLvrVCNpwZ3DfGZVs(WQ44fzp4MsGR2KvuvYVs(qkFyvC8cSocqX0XqlQk57Gd5t68ftZJuG1rakMogAHhdwZG5d58RKpKYN05lMMhPSJ36XKnMcpgSMbZ3bhY3hHgmCnLD8wpMSXuA(02HMpeZh4QMpKZVs(KoFyvC8YoERht2ykQkOR5Lng0LwBGHRtwdIeegaxnci018Ygd6QszIv4tk6YJbRzqe2ibjOlvio4HBtIMIacHbWiGqxEmyndIWgD99kCVg6kMMhPaRJaumDm0cpgSMbZVs(WQ44fLMbnjAYiOUwCzykTOQKFL8HvXXlW6iafthdTagUM8RKVpoHdcLyhHMp08XY8RKpyiL2CKlnFA7qZhR5JLOR5Lng0T5JoCj1ibHH7qaHU8yWAgeHn667v4En0vmnpsbwhbOy6yOfEmyndMFL8HvXXlW6iafthdTagUM8RKpSkoErPzqtIMmcQRfxgMslQk5xjFX08ifT6ynXouLTnzJPWJbRzW8RKpyiL2CKlnFA7qZhR5dm6AEzJbDB(OdxsnsqyaaiGqxEmyndIWgD99kCVg6svyTMqS(GfAbUvfttq1gToFiMpit3MbjeRpyHIUMx2yqx4wvmnbvB0AKGWalraHU8yWAgeHn6IhnXWqOGWay018Ygd6QeHMOzAO2Egjimaici0LhdwZGiSrxFVc3RHUnJ3mT2G1C(vYhs5tvyTMqS(GfArQBJwt4njFiMV7YhYOR5Lng0vQBJwt4nbjimQceqOlpgSMbryJU4rtmmekimagDnVSXGUkrOjAMgQTNrccdskci0LhdwZGiSrxFVc3RHUKoFz9oUZr(o4q(qkFsNVyAEKcSocqX0Xql8yWAgm)k538PTdnFSMpOABYgt(K88RUaa5d58RKVy9blfzpzcjiaxoFiMpwIUMx2yq32CKrccJQIacD5XG1micB0fpAIHHqbHbWOR5Lng0vjcnrZ0qT9msqyqkqaHU8yWAgeHn667v4En0vmnpsbwhbOy6yOfEmyndMFL8HvXXlW6iafthdTOQKFL8Hu(qk)MpTDO5JvO5tsZhY5xjFfUPlv4riov1YQOxUZhI5dgsPnh5IYPQwwf9YD(K88RUuvaMpKZVs(I1hSuK9KjKGaC58Hy(yj6AEzJbDBZrgjimaUAeqOlpgSMbryJU(EfUxdDHvXXlW6iafthdTOQKFL8HvXXlkndAs0KrqDT4YWuAbmCn5xjFFCchekXocnFSMparxZlBmO7zed(2mH3eKGWayGraHU8yWAgeHn667v4En0fs5dRIJxK9GBkbUAtwrvj)k5dP8BBbjy34rkgiiTSt(qmFiLpW5tE(Nges4RT(GP5Jf57RT(GPe4T5LngtNpKZNKNFZ(ARpyczp58HC(qgDnVSXGUWTQyAcQ2O1ibHbWUdbe6YJbRzqe2ORVxH71q3MXBMwBWAgDnVSXGUNrm4BZeEtqccdGbaeqOlpgSMbryJU4rtmmekimagDnVSXGUkrOjAMgQTNrccdGXseqOlpgSMbryJU(EfUxdDBgVzATbR58RKpKY3nRxdwZfvkti1TrRZhA(UlFhCiFQcR1eI1hSqlsDB0AcVj5dX8boFiJUMx2yqxPUnAnH3eKGWayaIacD5XG1micB013RW9AOBZ4ntRnynNFL8DZ61G1CrLYesDB068HMpW5xjFyvC8IxZw7nQSZrPzZlOR5Lng0vQBJwt4nbjimaUkqaHU8yWAgeHn6IhnXWqOGWay018Ygd6QeHMOzAO2EgjimaMKIacD5XG1micB013RW9AOlvH1AcX6dwOfQRvHj8MKpeZhy018Ygd6sDTkmH3eKGWa4QIacD5XG1micB013RW9AOlSkoEXRzR9gv25O0S5f018Ygd6sRBgejimaMuGacD5XG1micB013RW9AORbGY9kCrjCXnrGti1mXzetHhdwZGOR5Lng09mIbFBMWBcsqy4UQraHU8yWAgeHn667v4En0fmKsBoYLMpTDO5dX8Hu(Mx2yk06Mbl(Gk5tE(Mx2ykT5ix8bvYhlYNhUpilFiNV7H85H7dYknFWt(o4q(WQ44fVMT2BuzNJsZMxqxZlBmOlTUzqKGe0Lke47S0AUPiGqyamci0LhdwZGiSrx8OjggcfegaJUMx2yqxLi0entd12ZibHH7qaHU8yWAgeHn667v4En0fwfhVqn3SdMOdRlGHRbDnVSXGUuZn7Gj6WAKGWaaqaHU8yWAgeHn6IhnXWqOGWay018Ygd6QeHMOzAO2EgjimWseqOlpgSMbryJU(EfUxdDjD(Y6DCNJ8DWH8Hu(nFA7qZhRqZhuTnzJjFsE(vxaG8HC(vYhs5lwFWsPMnTuxu8s(qmF3bW8RKpPZxmnpsHAWClri1fEmyndMpKZ3bhYhs538PTdnFScnFq12KnM8j55xDPQ5xjFfUPlv4riov1YQOxUZhI5dgsPxLIYPQwwf9YD(qo)k5lwFWsr2tMqccWLZhI5xv018Ygd62RcsqyaqeqOlpgSMbryJU4rtmmekimagDnVSXGUkrOjAMgQTNrccJQabe6YJbRzqe2ORVxH71qxyvC8c1CZoyIoSU08PTdnFSMpWUdDnVSXGUuZn7Gj6WAKGWGKIacDpniKGhUpidDbgDnVSXGU4Ch(nuPeWRWOlpgSMbryJeKGU0Do0mHy9bliGqyamci0LhdwZGiSrxFVc3RHUKoFyvC8I3ec8OplQkOR5Lng01BcbE0NibHH7qaHU8yWAgeHn667v4En0fwfhVO0HlDrvjFhCiFyvC8cT2adxNSgSOQGUMx2yq32CKrccdaabe6AEzJbDnvjimrmVJOlpgSMbryJeegyjci0LhdwZGiSrxZlBmOR30AcZlBme6LkOREPcXyNm66JqdgUgksqyaqeqOlpgSMbryJU(EfUxdDbdP0RsrwVJ7CKFL8bdP0RsP5tBhA(ynFai)k5lwFWsr2tMqccWLZhI5dC15xjFiLVy9blLA20sDrXl5J18DhaZ3bhYxmnpsHAWClri1fEmyndMpKrxZlBmOlo3HFdvkb8kmsqyufiGqxEmyndIWgD99kCVg66Jt4Gqj2rO5dnFaMFL8HvXXlkndAs0KrqDT4YWuArvj)k5lMMhPaRJaumDm0cpgSMbZVs(WQ44fyDeGIPJHwadxt(vYhs5t68HvXXl74TEmzJPOQKVdoKpyiLEvknFA7qZhR5x18Hm6AEzJbDB(OdxsnsqyqsraHU8yWAgeHn667v4En01hNWbHsSJqZhI5JLOR5Lng0TvhcZlBme6LkOREPcXyNm6sfc8DwAn3uKGWOQiGqxEmyndIWgDnVSXGUT6qyEzJHqVubD1lvig7KrxQqCWd3MenfjibjORPk1rJU3909IeKGq]] )
end