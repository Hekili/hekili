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


    spec:RegisterPack( "Feral", 20180905.0059, [[d80zcbqiQOArIaOhbQYLebiBse9jrsmkrOtjsSkKQuVIkYSaLULkrTlr9lqXWeP6yGklte0ZOIY0uj01qkSnKQQVHuLmoqv5CGQQwNkr6DIauZdPO7bj7tKYbbvvwisLhkssnrvc4IIKKSrKQ4JQeiJuKKuNePQ0kPsMPiGUPkbQDcP6NIKedveOLQsqpfOPQs6QQeH(Qkr0EH6VizWkomLfdYJPQjd4YO2meFwfnAv40QA1QebVMky2eDBvQDl1VLmCcoosvXYv65iMoPRtOTtf67uPgViPopKY6fbG5JuA)cJHdFfdcykJrpHPdh8Lo8p9lMtpDAa)t)IyqfnbgdkyEhStgd22nJbPhEnjguWqtwga(kgKuIRNXGhQkqUuyG581drOSVUHH83Ist)Q9RHOWq(BpmqYccgie7YaSJWiSfYlzcmj4YxO9aeysWlK6cSIpaf9WRjZK)2JbHeFPsFBmegeWugJEctho4lD4F6olNqNDr4sycXGeb2JrhU0DggeGjEmi8IHE41KXCbwXhiCbVyouvGCPWaZ5RhIqzFDdd5VfLM(v7xdrHH83EyGKfemqi2LbyhHrylKxYeysWLVq7biWKGxi1fyfFak6HxtMj)TpCbVyazbLVH4nMlcBmjmD4GVyUCm0)L6S0JjbVGdxHl4ftQ(W6tMCPHl4fZLJb(baWaXa6GOugdDg5ihUGxmxoMeOicIfZLCnbHVpjXuTeTyUnv5ng3hChJKDKLXqZyGdo6phUGxmxog4haadedDROAYyaLg5igTIPe4M3yiF75yEnviXq0T6tEJrpSogWJLbYHl4fZLJjbLMNbIjvBAm0tT3XyikVXKGB5wgd5BphtcULBzm6(NN8sIjvBAm0tT35Wf8I5YXucCZlfq1CmpjMdRbKmqmFR82MuIwmqOfJEWXyaavNaoMLVlhzGy0dMWX4OTVbjzsoCbVyUCmWpPSChZv6jgTIbIJXBeng3hChZv6jMNedq5UHng2rUJ5rIbTsmvwoMU0yKM3HVpJHBEprlMej)njgJeZfibbJPzrDnjSX83cB5itI5k9eJOG(3CkzmOWwiVKXGWlg6HxtgZfyfFGWf8I5qvbYLcdmNVEicL91nmK)wuA6xTFnefgYF7HbswqWaHyxgGDegHTqEjtGjbx(cThGatcEHuxGv8bOOhEnzM83(Wf8IbKfu(gI3yUiSXKW0Hd(I5YXq)xQZspMe8coCfUGxmP6dRpzYLgUGxmxog4haadedOdIszm0zKJC4cEXC5ysGIiiwmxY1ee((Ket1s0I52uL3yCFWDms2rwgdnJbo4O)C4cEXC5yGFaamqm0TIQjJbuAKJy0kMsGBEJH8TNJ51uHedr3Qp5ng9W6yapwgihUGxmxoMeuAEgiMuTPXqp1EhJHO8gtcULBzmKV9Cmj4wULXO7FEYljMuTPXqp1ENdxWlMlhtjWnVuavZX8KyoSgqYaX8TYBBsjAXaHwm6bhJbauDc4yw(UCKbIrpychJJ2(gKKj5Wf8I5YXa)KYYDmxPNy0kgiogVr0yCFWDmxPNyEsmaL7g2yyh5oMhjg0kXuz5y6sJrAEh((mgU59eTysK83KymsmxGeemMMf11KWgZFlSLJmjMR0tmIc6FZPKdxHl4ftQQuZErLbIbIrQLJXx3qMgdeF(njhd8Z7zbLetx9LpS9grugJ51VAsmvlrlhUmV(vtYcl7RBitrHinIdHlZRF1KSWY(6gYuNqbdsvaHlZRF1KSWY(6gYuNqbJjEEZTA6xD4Y86xnjlSSVUHm1juWS85wU1dyFeuQj5wZqYQautwnjZTbjzGWL51VAswyzFDdzQtOGXrBFdsYW22nJsKWu6XAKdyD0KImQ0dxMx)QjzHL91nKPoHcghT9nijdBB3mkrctPhRroG1rtkYOGd2hbftFeFbbgilfrqmk3Rji89jjPKDKL0eo4O)Wf8IzkbU5LcOAovI5jXCynGKbI5BL32Ks0IbcTy0dogdaOAyJPAphJEWXG8lrJ5cFHyEsmMGG8zGy(oglgK)8qZHl4fJ51VAswyzFDdzQtOGXrBFdsYW22nJQe4MxkGQzyD0KImQ0dxWlMufbU5nMR0tmpjgawAOXaX8iX4MJPzgigTI5WwaVr0yw(Cl36rmst5nMQJ57y0doMTut)QdxMx)QjzHL91nKPoHcghT9nijdBB3mkawAOXaukcvjWnVW6OjfzuPhUGxmxpEsmhMGa3KyCFWDmGgeVAv6bSXqNSka1KvtIbsuJPlnMei9nMNeJAsUvgiCzE9RMKfw2x3qM6ekyC023GKmSTDZOayPHgdqPiuLa38cRJMuKrbhSpck1KCRzIbXRwLEK52GKmqs1KCRzizvaQjRMK52GKmqsNRMKBnlfBBP(Mi8RPF1zUnijdeUmV(vtYcl7RBitDcfmcB5wgUmV(vtYcl7RBitDcfmEtPqQ9oCbVyaBtGCuAmR9aXajIGWaXqutjXaXi1YX4RBitJbIp)MeJ1aXiS8Lfkv)(mMNedq1CoCzE9RMKfw2x3qM6ekyiTjqokLIOMscxMx)QjzHL91nKPoHcgiEj86q4Y86xnjlSSVUHm1juWiu6xD4kCbVysvLA2lQmqmSJ8Iwm6FZXOhCmMxRnMNeJ5O9sdsY5WL51VAcktulktvZ7aSpckNdjIGKf2YTmlkK05qIiizYHbuUVzjqwuiCzE9RM4ekyioikLuqg5iCzE9RM4ekywXMY86xnL8jkSTDZOkbU5f2hbLZlbU5LcOAoCzE9RM4ekywXMY86xnL8jkSTDZOiFFkzk12twdxHlZRF1KSVkjq5UjOamYbSpckNdjIGK9MsHu7DwuiCzE9RMK9vjbk3nXjuWiSLBjSpckireK83EBBt)QZlFBFtOz6zAKesebjFji2NsMIOM0bEZIcHlZRF1KSVkjq5UjoHcgiEj86aSpckU59eT0q5S0tMOVkjq5UZ6FYlHcrCrlV8T9njnAqlTqIiiz9p5LqHiUOLffsjCzE9RMK9vjbk3nXjuWO)jVekeXfnyFeuCZ7jAzag59VMgk6pDAPfsebjR)jVekeXfTmq5UdxMx)QjzFvsGYDtCcfmq8s41HVpdxMx)QjzFvsGYDtCcfmi8AskKL7eaOb7JGYx3qfLq9TsqLE4Y86xnj7RscuUBItOG5BVTTPF1W(iO4M3t0sdLZspzI(QKaL7oR)jVekeXfT8Y323K0GJg0slKicsw)tEjuiIlAzrHucxMx)QjzFvsGYDtCcfmcL(vdBB3mkitvjtju6xnvHqzNV8v0G9rqP2EYAw)BMslkGNPj9tdAPnr9VzkTOaEMMWbFPNmrireKmeVeEDilkqlTqIii5V922M(vNffsjLWL51VAs2xLeOC3eNqbd5Wak33Sea2hbLVUHkkH6BLqtAKKBEprlnuMx)QZR5aN9frtcuAEnh4SWTOuFb5ZlntygUKqIiiz9p5LqHiUOLffsMiKicsgswfGAYQjzrbAP15Qj5wZqYQautwnjZTbjzGusMOZvtYTM)2BBB6xDMBdsYa0sRVkjq5UZF7TTn9RoV8T9njn4GVus6CireK83EBBt)QZIcHlZRF1KSVkjq5UjoHcgrct9kFtcxHl4fd8I56bhtjWnVXCYnVMuIwmiLuwUJrp4yK157JPqIrp4ywMOXuiXOhCmMGe2yGe1yEsmewWwtzGykrnMdE5yqQngzD(EtgJxA7ROfUGxmPkcC)9zmxPNyC)szmqCmaS0qJbI5rIXnhtZmqmAfZHTaEJOXinL3ys09X7pI5Wee4MeJ7xpIb0G4vRspIjzm0DngirnMUIjbsFtjCbVysv0dED)eog3CmUFPmMsG7yC)6rmxPhyJbTsmgV1XqmewIwmEJOXOhpjgKTUJHOSj1JyC)6rjQXaTS5W3NX8AoCzE9RMKlbU5fL(N8sOqex0G9rq5OTVbj5maln0yakfHQe4MxuPhUGxmWpPBdnsmLa3X4(1JywZbg2y8vteV)(mgIYMupIXAGyQMJHURX4pS9KJjXhjg1KCRmqkHlZRF1KCjWnVoHcM1CGH9rq5C99o89jT0cjIGKf2YTmlkeUGxmjqwjXCBoWXqexog3CmCdeJEWXucCZBmjajm9rKBpNamg3hChtjUXG8lrJzFHyEsm67D47ZWf8IX86xnjxcCZRtOGXrBFdsYW22nJQe4MxkGQzyD0KImk4G9rqbuAEFHS(Eh((mCbVyOBzZHykrnMcjg9GJX86xDmYNOHl4fJ51VAsUe4MxNqbJB7vyjShv650thoyFeuaLM3xiRV3HVpdxWlg6lsmU5yomh5ysG0xyJXAGyomh5ov0ymbb5ZaX8AmOXAmIeoM7QAKF5C4cEXKQCHWgZJeJBoMQLOfZH5iht1Cm0Dng)HTNCmMxFh5yic2Dm3v1i)YXi26lJXnhJ36ymbbjAXSVqmUF9iMxdxMx)Qj5sGBEDcfm3v1i)YuEtH9rq5C99o89jT0cjIGKHKvbOMSAsMOM3buWL0x3qfLq9TsOjncxWlMlO3rUJXlUl3AmQy)9zmVgZtIXKUn0iX4Uw9iMB7B1((7Zy0J1ihWgdPIrYkjgtqqIwmVgZbVCoCzE9RMKlbU51juWOhRroG9rq5C99o89zsFDdvuc13kHM0iCbVysmvn7Wl)uI5sKWXq3kQMmgqProI5rIbTsmg1KCRmqmi1gZRWgZRPcjgIUvFYBm6H1XaESmqoCzE9RMKlbU51juWaTIQjPisJCa7JGYx3qfLq9TsOjncxWlg4xdeZJetxnhtHeJEWXyqLJCmMGGenyJXnhd5VfKOfd5yzGyeB9LXqJWL51VAsUe4MxNqbd5yzayFeu(6gQOeQVvcnPr4cEXCH85wU1dyJX9b3X4MJ5WCKJHgX4RBOkgH6BLeJ1aXajRcqnz1KySgig(1dEV0Wf8I5sYXCyoYXaAq8QvPhXynqmDfJ513rogizvaQjRMedrnVdXKOJVfZfm9edrWUtjg2rUJ5rI51ywM(i(ltIXI5WwGy8grdxWlMljhZH5ihJfJWYaMwlAXqC)iAZesmcB5JXC0EPbj5ys0X3Ib8cJb5jhFFMs4Y86xnjxcCZRtOGz5ZTCRhWEylG3ikkDfzyFeu(6gQOeQVvckAKunj3AgswfGAYQjzUnijdKmr1KCRzIbXRwLEK52GKmqsireKmKSka1KvtYaL7MwAHerqYcldyATOrrC)iAZeswuiLWf8IH(IeJBogUbyGyefI5WwaVr0VpJ5c5ZTCRhWgJiHJ5k9eJwXS8L5w5ngVPXGu7D4Y86xnjxcCZRtOGr)tEjuiIlAHl4fd8RbIPAphJBoMtwJ5GxogtJHgX4RBOIsO(wjWgZLGirJzFHySgig3Cm2YXikeJ1aXSID)9z4Y86xnjxcCZRtOGzFbyFeu(6gQOeQVvckAeUcxMx)QjzY3NsMsT9KvuEtPqQ9g2hbLZHerqYEtPqQ9olkeUmV(vtYKVpLmLA7jRoHcM1CGH9rqbjIGKf2YTmlkqlTqIiizYHbuUVzjqwuiCzE9RMKjFFkzk12twDcfmMOwuMQM3HWL51VAsM89PKPuBpz1juW4nPKY86xnL8jkSTDZO8vjbk3njCzE9RMKjFFkzk12twDcfmi8w(VejuqVYWQ2EYk1JGcO08(cz99o89zsGsZ7lKx(2(MqtNLuT9K1S(3mLwuapNgCPNmr12twZhSj1JSGxPzcPbT0QMKBntmiE1Q0Jm3gKKbsjCzE9RMKjFFkzk12twDcfmlFULB9a2hbLVUHkkH6BLGIgjHerqYcldyATOrrC)iAZeswuiPAsU1mKSka1KvtYCBqsgijKicsgswfGAYQjzGYDNmrNdjIGK)2BBB6xDwuGwAbknVVqE5B7BcnHVucxMx)QjzY3NsMsT9KvNqbZYNB5wpG9rq5RBOIsO(wjP5SKQj5wZqYQautwnjZTbjzGKqIiizHLbmTw0OiUFeTzcjlkKesebjBcCQPewgW0AZIcjHerqYF7TTn9RoduU7WL51VAsM89PKPuBpz1juWGWB5)sKqb9kd7JGcsebjBcCQPewgW0AZIcjtmrFDdvuc13kjTlMmrireK83EBBt)QZIc0sRAsU18DDZTsviuEPTVIwMBdsYaPKcT0MOAsU1mKSka1KvtYCBqsgijKicsgswfGAYQjzrHK(6gQOeQVvsAolLucxMx)QjzY3NsMsT9KvNqbZk2uMx)QPKprHTTBgfrPq((jh8sG9rq5RBOIsO(wjPDXWL51VAsM89PKPuBpz1juWSInL51VAk5tuyB7MrruQtU510AjHRWL51VAsMOuiF)KdEjOeQssTmPexpdlsTunNAffCHlZRF1KmrPq((jh8sCcfmeZr7KP2YwyFeuqIiizI5ODYuBzBgOC3HlZRF1KmrPq((jh8sCcfmcvjPwMuIRNHfPwQMtTIcUWL51VAsMOuiF)KdEjoHcM9fGvT9KvQhbLZ137W3N0sBIlFBFtOjkaX10VA6D6zNLsYevBpznFWMupYcEnTesJKoxnj3AMyq8QvPhzUnijdKcT0M4Y323eAIcqCn9RMENEg(skWl5jk3k1TOuFb5ZBAaLM3xilClk1xq(8Mss12twZ6FZuArb8CAWx4Y86xnjtukKVFYbVeNqbJqvsQLjL46zyrQLQ5uROGlCzE9RMKjkfY3p5GxItOGHyoANm1w2c7JGcsebjtmhTtMAlBZlFBFtOjCjmCzE9RMKjkfY3p5GxItOGbH3Y)LiHc6vg2Bl1uCZ7jAOGlCfUmV(vtYeL6KBEnTwcQLp3YTEa7JGsnj3AgswfGAYQjzUnijdKesebjlSmGP1IgfX9JOntizrHKqIiizizvaQjRMKbk3DsFDdvuc13kb1ftcuAEnh48Y323eAEXWL51VAsMOuNCZRP1sCcfmlFULB9a2hbftFeFbbgiBVuClkHsS98ssQMKBndjRcqnz1Km3gKKbsMiKicswyzatRfnkI7hrBMqYe18oKwcPL2eHerqYcldyATOrrC)iAZesMOM3H0GljqP51CGZlFBFtOPZsjLKqIiizizvaQjRMKbk3D4Y86xnjtuQtU510AjoHcgOvunjfrAKdyFeuebwkPuBpzLKHwr1KueProsdGj)YauQTNSscxMx)QjzIsDYnVMwlXjuWiuLKAzsjUEgwKAPAo1kk4cxMx)QjzIsDYnVMwlXjuWOhRroO8Mc7JGAzKLjhgKKtMirGLsk12twjz9ynYbL300sykHlZRF1KmrPo5MxtRL4ekyeQssTmPexpdlsTunNAffCHlZRF1KmrPo5MxtRL4eky0J1ihuEtH9rqreyPKsT9KvswpwJCq5nnnNLKPpIVGadKLIiigL71ee((KKunj3AgAfvtsrKg5iZTbjzGWL51VAsMOuNCZRP1sCcfmcvjPwMuIRNHfPwQMtTIcUWL51VAsMOuNCZRP1sCcfmR5adRA7jRupckNRV3HVpPL2eDUAsU1mKSka1KvtYCBqsgi5Y323eAciUM(vtVtp7SusQ2EYAw)BMslkGNt7IHlZRF1KmrPo5MxtRL4ekyeQssTmPexpdlsTunNAffCHlZRF1KmrPo5MxtRL4ekywZbgw12twPEeuQj5wZqYQautwnjZTbjzGKqIiizizvaQjRMKffsMyIlFBFtOjk6vkjf4L8eLBL6wuQVG85nnGsZR5aNfUfL6liFEP3PNHpAKss12twZ6FZuArb8CAxmCzE9RMKjk1j38AATeNqbd0kQMKIinYbSpcQeHerqY6FYlHcrCrllkKmX1Eak2rU1SbaqYFNwIW50TLAk)HTNm5Y(dBpzcfYAE9R2KPqVx2Fy7jtP)nNskHlZRF1KmrPo5MxtRL4ekyURQr(LP8McRA7jRupcQLrwMCyqsoCzE9RMKjk1j38AATeNqbJqvsQLjL46zyrQLQ5uROGlCzE9RMKjk1j38AATeNqbJESg5GYBkSpcQLrwMCyqsozIoA7Bqsolsyk9ynYbQeslTebwkPuBpzLK1J1ihuEttdUucxMx)QjzIsDYnVMwlXjuWOhRroO8Mc7JGAzKLjhgKKt6OTVbj5SiHP0J1ihOGljKics2lzB9gr)(mVS51WL51VAsMOuNCZRP1sCcfmcvjPwMuIRNHfPwQMtTIcUWL51VAsMOuNCZRP1sCcfme3Vat5nf2hbfrGLsk12twjzI7xGP8MMgCHlZRF1KmrPo5MxtRL4ekyihlda7JGcO08AoW5LVTVjPLO51V6m5yzGSViQtMx)QZR5aN9frVm38EIwkjG4M3t0YlFYnT0cjIGK9s2wVr0VpZlBEfd6iVKVAm6jmD4GV0H)PFXCcHZz0ad622(7tcg8sc)Uq0PVOFbDPXeZ1doM)wOwngKAJjvayetuQPsmltFe)LbIHu3CmMOw3MYaX4pS(Kj5Wvc8Bog4U0yUeBIOGqTkdeJ51V6ysftulktvZ7qQKdxHRlj87crN(I(f0Lgtmxp4y(BHA1yqQnMuH89PKPuBpznvIzz6J4VmqmK6MJXe162ugig)H1NmjhUsGFZX4SlnMlXMikiuRYaXyE9RoMuXe1IYu18oKk5Wv4I(EluRYaXqVIX86xDmYNOKC4cdAI6rTyqW)ovJbLprj4RyWsGBEXxXOdh(kgKBdsYay6WG(9vEFdd6OTVbj5maln0yakfHQe4M3yqft6yqZRF1yq9p5LqHiUOHvm6jeFfdYTbjzamDyq)(kVVHbDEm67D47ZyOL2yGerqYcB5wMffWGMx)QXGR5aJvm6odFfdYTbjzamDyq)(kVVHbDEm67D47ZyOL2yGerqYqYQautwnjtuZ7qmOIbUysgJVUHkkH6BLednJHgyqZRF1yW7QAKFzkVPyfJ(fXxXGCBqsgathg0VVY7ByqNhJ(Eh((mMKX4RBOIsO(wjXqZyObg086xngupwJCGvm60aFfdYTbjzamDyq)(kVVHb91nurjuFRKyOzm0adAE9RgdcTIQjPisJCGvm60p(kgKBdsYay6WG(9vEFdd6RBOIsO(wjXqZyObg086xngKCSmawXOtVWxXGCBqsgathg086xngC5ZTCRhyq)(kVVHb91nurjuFRKyqfdnIjzmQj5wZqYQautwnjZTbjzGysgtIXOMKBntmiE1Q0Jm3gKKbIjzmqIiizizvaQjRMKbk3Dm0sBmqIiizHLbmTw0OiUFeTzcjlketkyWdBb8grXG6kYyfJo8HVIbnV(vJb1)KxcfI4IggKBdsYay6WkgD4p(kgKBdsYay6WG(9vEFdd6RBOIsO(wjXGkgAGbnV(vJb3xaRyfdcWiMOuXxXOdh(kgKBdsYay6WG(9vEFdd68yGerqYcB5wMffIjzmopgireKm5Wak33SeilkGbnV(vJbnrTOmvnVdyfJEcXxXGMx)QXGeheLskiJCGb52GKmaMoSIr3z4RyqUnijdGPdd63x59nmOZJPe4MxkGQzmO51VAm4k2uMx)QPKprXGYNOuTDZyWsGBEXkg9lIVIb52GKmaMomO51VAm4k2uMx)QPKprXGYNOuTDZyqY3NsMsT9KvSIvmOWY(6gYu8vm6WHVIb52GKmaMoSIrpH4RyqUnijdGPdRy0Dg(kgKBdsYay6Wkg9lIVIb52GKmaMomOFFL33WGQj5wZqYQautwnjZTbjzamO51VAm4YNB5wpWkgDAGVIb52GKmaMomOJMuKXGPJbnV(vJbD023GKmg0rBPA7MXGIeMspwJCGvm60p(kgKBdsYay6WGMx)QXGoA7Bqsgd6OjfzmiCyq)(kVVHbz6J4liWazPicIr5EnbHVpjXKmgj7ilJHMXahC0pg0rBPA7MXGIeMspwJCGvm60l8vmi3gKKbW0HbD0KImgmDmO51VAmOJ2(gKKXGoAlvB3mgeGLgAmaLIqvcCZlwXOdF4RyqUnijdGPddAE9Rgd6OTVbjzmOJMuKXGWHb97R8(ggunj3AMyq8QvPhzUnijdetYyutYTMHKvbOMSAsMBdsYaXKmgNhJAsU1SuSTL6BIWVM(vN52GKmag0rBPA7MXGaS0qJbOueQsGBEXkgD4p(kg086xnguyl3smi3gKKbW0Hvm6WLo(kg086xng0BkfsT3yqUnijdGPdRy0Hdo8vmi3gKKbW0Hvm6WLq8vmO51VAmieVeEDadYTbjzamDyfJoCodFfdAE9Rgdku6xngKBdsYay6WkwXG(QKaL7MGVIrho8vmi3gKKbW0Hb97R8(gg05XajIGK9MsHu7DwuadAE9RgdcyKdSIrpH4RyqUnijdGPdd63x59nmiKics(BVTTPF15LVTVjXqZysptJysgdKics(sqSpLmfrnPd8MffWGMx)QXGcB5wIvm6odFfdYTbjzamDyq)(kVVHb5M3t0IjnuX4S0JjzmjgJVkjq5UZ6FYlHcrCrlV8T9njM0IHgXqlTXajIGK1)KxcfI4IwwuiMuWGMx)QXGq8s41bSIr)I4RyqUnijdGPdd63x59nmi38EIwgGrE)RXKgQyO)0JHwAJbsebjR)jVekeXfTmq5UXGMx)QXG6FYlHcrCrdRy0Pb(kg086xngeIxcVo89jgKBdsYay6WkgD6hFfdYTbjzamDyq)(kVVHb91nurjuFRKyqft6yqZRF1yqeEnjfYYDca0WkgD6f(kgKBdsYay6WG(9vEFddYnVNOftAOIXzPhtYysmgFvsGYDN1)KxcfI4IwE5B7BsmPfdC0igAPngireKS(N8sOqex0YIcXKcg086xng8BVTTPF1yfJo8HVIb52GKmaMomOFFL33WGQTNSM1)MP0Ic45yOzm0pnIHwAJjXy0)MP0Ic45yOzmWbFPhtYysmgireKmeVeEDilkedT0gdKics(BVTTPF1zrHysjMuWGcL(vJbHmvLmLqPF1ufcLD(YxrddAE9Rgdku6xnwXOd)XxXGCBqsgathg0VVY7ByqFDdvuc13kjgAgdnIjzmCZ7jAXKgQymV(vNxZbo7lIgtYyaknVMdCw4wuQVG85ngAgtcZWftYyGerqY6FYlHcrCrllketYysmgireKmKSka1KvtYIcXqlTX48yutYTMHKvbOMSAsMBdsYaXKsmjJjXyCEmQj5wZF7TTn9RoZTbjzGyOL2y8vjbk3D(BVTTPF15LVTVjXKwmWbFXKsmjJX5XajIGK)2BBB6xDwuadAE9RgdsomGY9nlbWkgD4shFfdAE9RgdksyQx5BcgKBdsYay6WkwXGKVpLmLA7jR4Ry0HdFfdYTbjzamDyq)(kVVHbDEmqIiizVPui1ENffWGMx)QXGEtPqQ9gRy0ti(kgKBdsYay6WG(9vEFddcjIGKf2YTmlkedT0gdKicsMCyaL7BwcKffWGMx)QXGR5aJvm6odFfdAE9RgdAIArzQAEhWGCBqsgathwXOFr8vmi3gKKbW0HbnV(vJb9MuszE9RMs(efdkFIs12nJb9vjbk3nbRy0Pb(kgKBdsYay6WG(9vEFddcuAEFHS(Eh((mMKXauAEFH8Y323KyOzmolMKXO2EYAw)BMslkGNJjTyGl9ysgtIXO2EYA(GnPEKf8Am0mMesJyOL2yutYTMjgeVAv6rMBdsYaXKcg086xngeH3Y)LiHc6vgRy0PF8vmi3gKKbW0Hb97R8(gg0x3qfLq9TsIbvm0iMKXajIGKfwgW0ArJI4(r0MjKSOqmjJrnj3AgswfGAYQjzUnijdetYyGerqYqYQautwnjduU7ysgtIX48yGerqYF7TTn9RolkedT0gdqP59fYlFBFtIHMXaFXKcg086xngC5ZTCRhyfJo9cFfdYTbjzamDyq)(kVVHb91nurjuFRKyslgNftYyutYTMHKvbOMSAsMBdsYaXKmgireKSWYaMwlAue3pI2mHKffIjzmqIiiztGtnLWYaMwBwuiMKXajIGK)2BBB6xDgOC3yqZRF1yWLp3YTEGvm6Wh(kgKBdsYay6WG(9vEFddcjIGKnbo1ucldyATzrHysgtIXKym(6gQOeQVvsmPfZfJjzmjgdKics(BVTTPF1zrHyOL2yutYTMVRBUvQcHYlT9v0YCBqsgiMuIjLyOL2ysmg1KCRzizvaQjRMK52GKmqmjJbsebjdjRcqnz1KSOqmjJXx3qfLq9TsIjTyCwmPetkyqZRF1yqeEl)xIekOxzSIrh(JVIb52GKmaMomOFFL33WG(6gQOeQVvsmPfZfXGMx)QXGRytzE9RMs(efdkFIs12nJbjkfY3p5GxcwXOdx64RyqUnijdGPddAE9RgdUInL51VAk5tumO8jkvB3mgKOuNCZRP1sWkwXGeLc57NCWlbFfJoC4RyqUnijdGPddIulvZPwXOdhg086xnguOkj1YKsC9mwXONq8vmi3gKKbW0Hb97R8(ggesebjtmhTtMAlBZaL7gdAE9RgdsmhTtMAlBXkgDNHVIb52GKmaMomisTunNAfJoCyqZRF1yqHQKultkX1ZyfJ(fXxXGCBqsgathg0VVY7ByqNhJ(Eh((mgAPnMeJz5B7Bsm0evmaIRPF1XqVJj9SZIjLysgtIXO2EYA(GnPEKf8AmPftcPrmjJX5XOMKBntmiE1Q0Jm3gKKbIjLyOL2ysmMLVTVjXqtuXaiUM(vhd9oM0ZWxmjJrGxYtuUvQBrP(cYN3yslgGsZ7lKfUfL6liFEJjLysgJA7jRz9VzkTOaEoM0Ib(WGMx)QXG7lGvm60aFfdYTbjzamDyqKAPAo1kgD4WGMx)QXGcvjPwMuIRNXkgD6hFfdYTbjzamDyq)(kVVHbHerqYeZr7KP2Y28Y323KyOzmWLqmO51VAmiXC0ozQTSfRy0Px4RyWBl1uCZ7jAyq4WGMx)QXGi8w(VejuqVYyqUnijdGPdRyfdsuQtU510Aj4Ry0HdFfdYTbjzamDyq)(kVVHbvtYTMHKvbOMSAsMBdsYaXKmgireKSWYaMwlAue3pI2mHKffIjzmqIiizizvaQjRMKbk3DmjJXx3qfLq9TsIbvmxmMKXauAEnh48Y323KyOzmxedAE9RgdU85wU1dSIrpH4RyqUnijdGPdd63x59nmitFeFbbgiBVuClkHsS98sIjzmQj5wZqYQautwnjZTbjzGysgtIXajIGKfwgW0ArJI4(r0MjKmrnVdXKwmjmgAPnMeJbsebjlSmGP1IgfX9JOntizIAEhIjTyGlMKXauAEnh48Y323KyOzmolMuIjLysgdKicsgswfGAYQjzGYDJbnV(vJbx(Cl36bwXO7m8vmi3gKKbW0Hb97R8(ggKiWsjLA7jRKm0kQMKIinYrmPfdat(LbOuBpzLGbnV(vJbHwr1KueProWkg9lIVIb52GKmaMomisTunNAfJoCyqZRF1yqHQKultkX1ZyfJonWxXGCBqsgathg0VVY7ByWLrwMCyqsoMKXKymebwkPuBpzLK1J1ihuEtJjTysymPGbnV(vJb1J1ihuEtXkgD6hFfdYTbjzamDyqKAPAo1kgD4WGMx)QXGcvjPwMuIRNXkgD6f(kgKBdsYay6WG(9vEFddseyPKsT9KvswpwJCq5nnM0IXzXKmgM(i(ccmqwkIGyuUxtq47tsmjJrnj3AgAfvtsrKg5iZTbjzamO51VAmOESg5GYBkwXOdF4RyqUnijdGPddIulvZPwXOdhg086xnguOkj1YKsC9mwXOd)XxXGCBqsgathg0VVY7ByqNhJ(Eh((mgAPnMeJX5XOMKBndjRcqnz1Km3gKKbIjzmlFBFtIHMXaiUM(vhd9oM0ZolMuIjzmQTNSM1)MP0Ic45yslMlIbnV(vJbxZbgRy0HlD8vmi3gKKbW0HbrQLQ5uRy0HddAE9RgdkuLKAzsjUEgRy0Hdo8vmi3gKKbW0Hb97R8(ggunj3AgswfGAYQjzUnijdetYyGerqYqYQautwnjlketYysmMeJz5B7Bsm0evm0RysjMKXiWl5jk3k1TOuFb5ZBmPfdqP51CGZc3Is9fKpVXqVJj9m8rJysjMKXO2EYAw)BMslkGNJjTyUig086xngCnhySIrhUeIVIb52GKmaMomOFFL33WGjgdKicsw)tEjuiIlAzrHysgtIXS2dqXoYTMnaas(7yslMeJbUyCkMBl1u(dBpzsmxog)HTNmHcznV(vBYysjg6Dml7pS9KP0)MJjLysbdAE9RgdcTIQjPisJCGvm6W5m8vmi3gKKbW0Hb97R8(ggCzKLjhgKKXGMx)QXG3v1i)YuEtXkgD4Ui(kgKBdsYay6WGi1s1CQvm6WHbnV(vJbfQssTmPexpJvm6Wrd8vmi3gKKbW0Hb97R8(ggCzKLjhgKKJjzmjgJJ2(gKKZIeMspwJCedQysym0sBmebwkPuBpzLK1J1ihuEtJjTyGlMuWGMx)QXG6XAKdkVPyfJoC0p(kgKBdsYay6WG(9vEFddUmYYKddsYXKmghT9nijNfjmLESg5iguXaxmjJbsebj7LSTEJOFFMx28kg086xngupwJCq5nfRy0HJEHVIb52GKmaMomisTunNAfJoCyqZRF1yqHQKultkX1ZyfJoCWh(kgKBdsYay6WG(9vEFddseyPKsT9KvsM4(fykVPXKwmWHbnV(vJbjUFbMYBkwXOdh8hFfdYTbjzamDyq)(kVVHbbknVMdCE5B7BsmPftIXyE9Rotowgi7lIgJtXyE9RoVMdC2xenMlhd38EIwmPetcOy4M3t0YlFYDm0sBmqIiizVKT1Be97Z8YMxXGMx)QXGKJLbWkwXkwXkgd]] )
end