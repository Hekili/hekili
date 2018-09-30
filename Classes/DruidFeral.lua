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
        damageExpiration = 3,
    
        potion = "battle_potion_of_agility",
    
        package = "Feral"
    } )


    spec:RegisterPack( "Feral", 20180929.2129, [[d4uuabqisrTieLk9iOuDjeLQSjvWNquIrbk6uGkwfuk1RqunlOKBPcv7sIFPIAyGchdqwgIKNbLIPrksxduPTbOKVHOGXbO4CKIyDik07quQQ5Hi19GI9bO6GikPfIiEOkKyIqPKUOkekBerrFerPItIOuwjPQzcLsCtvij7eu1pvHGHQcrlvfs9uvAQQixvfcvFvfczVq(lcdwvhMYIb5Xu1Kb6YO2mu9zj1OLKtR0QbuQEnPKztLBdWUv8BrdNehxfsQLl1ZrA6exNK2oPuFNuz8Qq58GsRhqPmFsH9lmci0j0f0egbpPGbqadm0esPjfsbeP0e4cSqxbwfgDvmVwwnJUJbGrxYKBZHUkgSU0arNqxAQ2EgDRerHsgpFUELkvOIpbCMUauDMS54Bdxotxa(ZqUe6meUDCqw7ZkDIVoME(iB(OTfKE(ipAcS1wDbjitUnxHUa8OlK66eY2GGqxqtye8KcgabmWqtiLMuifqKcBqxQc7rWdemWg0TAbb5bbHUGm1JUypEYKBZfp2ARUGHEShFLikuY45Z1RuPcv8jGZ0fGQZKnhFB4Yz6cWFgYLqNHWTJdYAFwPt81X0ZhzZhTTG0Zh5rtGT2QlibzYT5k0fGp0J94VSIWaG4oEsPjyfpPGbqat8hpEnHmceqXFKhvH(qp2J)OuztntjJHESh)XJNSccYGXF1s15INeJwvc9yp(JhpzfeKbJNKwvmx8xNrRoF1TkC8sgFQWd3XVt8auDYECX6AwkHESh)XJ)iDMNbJ)Oys8Kz2aI3WfUJ)i7uNlE6oEo(JStDU4LERR5Mg)rXK4jZSbuc9yp(Jh)rZo7ymy8N2AUjl04jt1g245H7AyJ3xXETIxY4nffhSXNJd241vXt8N2AUjl04jt1g24xA8MRzde24vvkHESh)XJpv4HBcWC44xA8v2a6yW43r4EmNd24HGnEPIJ3abZHSF8ndi1MbJxQykhV2wVgKJPL4J)imoyJhkLkUJFN4HsknE8TUsOf0vPt81XOl2JNm52CXJT2QlyOh7XxjIcLmE(C9kvQqfFc4mDbO6mzZX3gUCMUa8NHCj0ziC74GS2Nv6eFDm98r28rBli98rE0eyRT6csqMCBUcDb4d9yp(lRimaiUJNuAcwXtkyaeWe)XJxtiJabu8h5rvOp0J94pkv2uZuYyOh7XF84jRGGmy8xTuDU4jXOvLqp2J)4XtwbbzW4jPvfZf)1z0QZxDRchVKXNk8WD87epavNShxSUMLsOh7XF84psN5zW4pkMepzMnG4nCH74pYo15INUJNJ)i7uNlEP36AUPXFumjEYmBaLqp2J)4XF0SZogdg)PTMBYcnEYuTHnEE4Ug249vSxR4LmEtrXbB854GnEDv8e)PTMBYcnEYuTHn(LgV5A2aHnEvLsOh7XF84tfE4Mamho(LgFLnGogm(DeUhZ5GnEiyJxQ44nqWCi7hFZasTzW4LkMYXRT1Rb5yAj(4pcJd24HsPI743jEOKsJhFRReAj0h6XE8hXog7vfgmEigpBoEFcaYK4H46DOL4jREpRi04NCoEL1aWvDXBEzZHgFooylHEZlBo0IsZ(eaKjyWDgvRqV5LnhArPzFcaYeYXCgptWqV5LnhArPzFcaYeYXC2uRbWJyYMtO38YMdTO0Spbazc5yo3CDN6KkSwCmI54rkqUmbfZLdTWJb5yWqp2JNSjXV041LTuf)kXJND8MdqsL4zT5g2C44LmEa2oITt8svB0QqV5LnhArPzFcaYeYXCwBRxdYXyngagJkLjKQ2OvyPT5uzmKk0BEzZHwuA2NaGmHCmN1261GCmwJbGXOszcPQnAfwABovgdqyT4ymGnUxHlkPoUjsCcPIjaK5u4XGCmyOh7XFeu4H74prMXV04bzNbldg)IhVoo(HzW4Lm(kRb9gvIV56o1jvX7mH74Zj(DIxQ447umzZj0BEzZHwuA2NaGmHCmN1261GCmwJbGXaYodwgKqWjsfE4glTnNkJbgHESh)PQLgFLPOWdnEDv8e)1G4wYuQWkEsCzckMlhA8qQs8tkXJTq2IFPXlMJhHbd9Mx2COfLM9jaitihZzTTEnihJ1yaymGSZGLbjeCIuHhUXsBZPYyacRfhJyoEKc1G4wYuQk8yqog8GyoEKcKltqXC5ql8yqog8GMfZXJuCQJ1e7qv22KnNcpgKJbd9Mx2COfLM9jaitihZzLo15c9Mx2COfLM9jaitihZzVje4zdi0J94VJPqRsj(2wW4HuXXzW4PIj04Hy8S549jaitIhIR3HgVnGXR08Xvsr2Po(LgpyoCj0BEzZHwuA2NaGmHCmNPJPqRsHGkMqd9Mx2COfLM9jaitihZzLu2Cc9Mx2COfLM9jaitihZziUPCRvOp0J94pIDm2Rkmy8S2CdB8YcGJxQ44nVKD8lnEtBBDgKJlHEZlBoumuTuDociJwH1IJrZqQ44fLo15kQkh0mKkoEHwzGPoaSdSOQe6nVS5qjhZ5wDimVS5q4wQG1yaymPcpCJ1IJbkP0dAov4HBcWC4qV5Lnhk5yo3QdH5Lnhc3sfSgdaJHUtTJjeRRzj0h6nVS5ql(mDGPUHIb0OvyT4y0mKkoEXBcbE2akQkHEZlBo0IpthyQBOKJ5SsN6CyT4yGuXXl74TEmzZP0maBhkPHrbUhGuXXla7QtTJjOI50I7IQsO38YMdT4Z0bM6gk5yodXnLBTWAXXWd31WcCmydmoatFMoWu3uKTMBkbUAdBPza2ouGdxn0asfhViBn3ucC1g2IQcCc9Mx2COfFMoWu3qjhZzzR5MsGR2WI1IJbsfhViBn3ucC1g2cyQB0qdE4Ug2ciJV(vaogGfmc9Mx2COfFMoWu3qjhZziUPCR1o1HEZlBo0IpthyQBOKJ5mo3MJaV5bydwSwCm(eausOK7iumWi0BEzZHw8z6atDdLCmN3XB9yYMdwlogE4UgwGJbBGXby6Z0bM6MIS1CtjWvBylndW2HcCGGRgAaPIJxKTMBkbUAdBrvboHEZlBo0IpthyQBOKJ5SskBoyngagdKjIJjuszZHiXjS61TcSyT4yeRRzPilaMqscWLjnWcUAObmLfatijb4YKgiGbghGjKkoEbIBk3Avuv0qdivC8YoERht2CkQkWboHEZlBo0IpthyQBOKJ5mTYatDayhiwlogFcakjuYDekPH7bE4UgwGJX8YMtPnT4IpPYbWukTPfxuaO6KvXTCtAsva6aKkoEr2AUPe4QnSfvLdWesfhVa5Yeumxo0IQIgAOzXC8ifixMGI5YHw4XGCmiCoatnlMJhPSJ36XKnNcpgKJb1qdFMoWu3u2XB9yYMtPza2ouGdeWaNdAgsfhVSJ36XKnNIQsO38YMdT4Z0bM6gk5yoRszIvya0qFOh7XJ94pvXXNk8WD818WT5CWgpE6CPU4LkoExwV(4t84Lko(MPs8jE8sfhVP4WkEivj(LgpLvS2egm(uvIVIBoE8SJ3L1R3CX7DwVcSHESh)rqHNDQJ)ezgVU15IhIJhKDgSmy8lE8644hMbJxY4RSg0BujENjChpm1vT(Q4RmffEOXRBLQ4Pge3sMsv8hIhsIhsvIFY4DlCc9yp(JGuXTULYXRJJx36CXNk8eVUvQI)ezIv8WMQX7TjEQHZoyJ3BujEPAPXJ3jG4PcBoPkEDRuLQs8qnBATtD8Ruc9Mx2COLuHhUXiBn3ucC1gwSwCmAB9AqoUaYodwgKqWjsfE4gdmc9ypEYQtNbln(uHN41Tsv8TPfJv8(COQa2PoEQWMtQI3gW4ZHJNKtX7RSUMJhMlE8I54ryq4e6nVS5qlPcpCtoMZTPfJ1IJrZY61ANAn0asfhVO0Poxrvj0J94XwyHgpatloEQAZXRJJNhW4Lko(uHhUJNSlLpQv5XZKDJxxfpXNQD84BtL47vj(LgVSET2Po0BEzZHwsfE4MCmN1261GCmwJbGXKk8WnbyomwABovgdykLEvkY61AN6qp2JNKMnTIpvL4t84LkoEZlBoX7wQe6nVS5qlPcpCtoMZ6SvWIYEmWOadyaewlogWuk9QuK1R1o1HEShpzdpEDC8vM2C8ylKnSI3gW4RmT5HSiXBkkULbJFL4HLL4vPC8aYCW3MlHESh)r4OXk(fpEDC854Gn(ktBo(C44j5u8(kRR54nVSAZXtvmaXdiZbFBoE1rwx864492eVPO4Gn(EvIx3kvXVsO38YMdTKk8Wn5yodiZbFBMWBcwlognlRxRDQ1qdivC8cKltqXC5qluX8AHbOd(eausOK7iusd3qp2JNSZQnpX7v7MhjErD2Po(vIFPXBoDgS041LTufpaBhX2zN64LQ2OvyfpnJ3XcnEtrXbB8ReFf3Cj0BEzZHwsfE4MCmNLQ2OvyT4y0SSET2P(GpbaLek5ocL0Wn0J94jPvfZf)1z0Q43j(JGcpChVUvQINuKhVyDnl0sO38YMdTKk8Wn5yod1QI5iOoJwH1IJHQWohHyDnluGd0bFcakjuYDekPHBOh7XF1TkC87e)rqHhUJx3kvXtkYJxSUMfAj0BEzZHwsfE4MCmNP6wfMWBcwlogQc7CeI11Sqboqh8jaOKqj3rOKgUHEShpzDaJFXJFYHJpXJxQ44nOuBoEtrXblwXRJJNUauCWgpTQzW4vhzDXd3qV5LnhAjv4HBYXCMw1miwlogFcakjuYDekPHBOh7XF0CDN6KkSIxxfpXRJJVY0MJhUX7taqz8k5ocnEBaJhYLjOyUCOXBdy88kvCtgd9yp(Jio(ktBo(RbXTKPufVnGXpz8MxwT54HCzckMlhA8uX8Afpm1ET4pQiZ4Pkga4epRnpXV4XVs8nFuRUntJ3IVYAW49gvc9yp(Jio(ktBoElELMbnjByJNQBXLHP04v60hVPTTodYXXdtTxl(7rhp(sR2PgoHEZlBo0sQWd3KJ5CZ1DQtQWAXX4taqjHsUJqXa3dI54rkqUmbfZLdTWJb5yWdWumhpsHAqClzkvfEmihdEasfhVa5Yeumxo0cyQB0qdivC8IsZGMKnSeuDlUmmLwuvGtOh7Xt2WJxhhppGmy8QkXxznO3OYo1XF0CDN6KkSIxLYXFImJxY4B(48iChV3K4XZgqO38YMdTKk8Wn5yolBn3ucC1g2qp2JNSoGXNJNJxhhFnlXxXnhVjXd349jaOKqj3rOyfpWUkvIVxL4TbmEDC8wZXRQeVnGX3QZStDO38YMdTKk8Wn5yo3RcwlogFcakjuYDekg4g6d9Mx2COf6o1oMqSUMfmEtiWZgawlogndPIJx8MqGNnGIQsO38YMdTq3P2XeI11SqoMZTPfJ1IJbsfhVO0PoxrvrdnGuXXl0kdm1bGDGfvLqV5LnhAHUtTJjeRRzHCmNnvjjmrmVwHEZlBo0cDNAhtiwxZc5yo7nNJW8YMdHBPcwJbGX4Z0bM6gAO38YMdTq3P2XeI11SqoMZ4CN(nvPeqRWyjwxZcXIJbmLsVkfz9ATt9bWuk9QuAgGTdL0yZbX6AwkYcGjKKaCzGdemoatX6AwkvS5KQIIxinPGRgAiMJhPqniULmLQcpgKJbHtO38YMdTq3P2XeI11SqoMZnx3PoPcRfhJpbaLek5ocfdCpaPIJxuAg0KSHLGQBXLHP0IQYbXC8ifixMGI5YHw4XGCm4bivC8cKltqXC5qlGPU5am1mKkoEzhV1JjBofvfn0amLsVkLMby7qjnWaNqV5LnhAHUtTJjeRRzHCmNB1HW8YMdHBPcwJbGXqfc8DwAf3uSwCm(eausOK7iuGRPHEZlBo0cDNAhtiwxZc5yo3QdH5Lnhc3sfSgdaJHke18WTjztd9HEZlBo0cviW3zPvCtXOKPJOzAQ2Egl8Sjg(ycgGc9Mx2COfQqGVZsR4MsoMZutBRMj60ASwCmqQ44fQPTvZeDADbm1nHEZlBo0cviW3zPvCtjhZzLmDentt12ZyHNnXWhtWauO38YMdTqfc8DwAf3uYXCUxfSeRRzHyXXOzz9ATtTgAaZMby7qjngq12KnhSnmkydCoatX6AwkvS5KQIIxaoPG7bnlMJhPqniULmLQcpgKJbHJgAaZMby7qjngq12KnhSnmkaZbfUPlv4riaO6KvXTCdCWuk9QuuaO6KvXTCdNdI11SuKfatijb4Yahyc9Mx2COfQqGVZsR4MsoMZkz6iAMMQTNXcpBIHpMGbOqV5LnhAHke47S0kUPKJ5m102QzIoTgRfhdKkoEHAAB1mrNwxAgGTdL0arQqV5LnhAHke47S0kUPKJ5SsMoIMPPA7zSWZMy4Jjyak0BEzZHwOcb(olTIBk5yodWwayT4yGuXXlBNdbWUPJwuvc9Mx2COfQqGVZsR4MsoMZ4CN(nvPeqRWybWogbpCxdlgGc9HEZlBo0cviQ5HBtYMIP56o1jvyT4yeZXJuGCzckMlhAHhdYXGhGuXXlkndAs2Wsq1T4YWuArv5aKkoEbYLjOyUCOfWu3CWNaGscLChHIrtpaMsPnT4sZaSDOKwtd9Mx2COfQquZd3MKnLCmNBUUtDsfwlogXC8ifixMGI5YHw4XGCm4bivC8cKltqXC5qlGPU5aKkoErPzqtYgwcQUfxgMslQkheZXJuCQJ1e7qv22KnNcpgKJbpaMsPnT4sZaSDOKgOqV5LnhAHke18WTjztjhZzOwvmhb1z0kSwCmuf25ieRRzHwGAvXCeuNrRaoit3MbjeRRzHg6nVS5qluHOMhUnjBk5yoRKPJOzAQ2Egl8Sjg(ycgGc9Mx2COfQquZd3MKnLCmNLQ2OveEtWAXX0mEZ0kdYXhGjvHDocX6AwOfPQnAfH3eGtk4e6nVS5qluHOMhUnjBk5yoRKPJOzAQ2Egl8Sjg(ycgGc9Mx2COfQquZd3MKnLCmNBtlglX6AwiwCmAwwVw7uRHgWuZI54rkqUmbfZLdTWJb5yWdndW2HsAq12KnhSnmkydCoiwxZsrwamHKeGldCnn0BEzZHwOcrnpCBs2uYXCwjthrZ0uT9mw4ztm8Xemaf6nVS5qluHOMhUnjBk5yo3MwmwI11SqS4yeZXJuGCzckMlhAHhdYXGhGuXXlqUmbfZLdTOQCaMWSza2ousJHmaNdkCtxQWJqaq1jRIB5g4GPuAtlUOaq1jRIB5gBdJcWax4CqSUMLISaycjjaxg4AAOh7XFeTsv8ylKT4pepjNWkEDC8EBIxLYXdiZbFBoEjJNAAZXtYP49vwxZuSI3CUu3o1XRsJxY4Hyr4o(MXBMwfFBAXHEZlBo0cviQ5HBtYMsoMZaYCW3Mj8MG1IJbsfhVa5Yeumxo0IQYbivC8IsZGMKnSeuDlUmmLwatDZbFcakjuYDekPHBO38YMdTqfIAE42KSPKJ5muRkMJG6mAfwlogycPIJxKTMBkbUAdBrv5amBBbjyT5rkgiiTSdWHjqKdWogHVY6AMECFL11mLaVnVS5yo4GTB2xzDntilagoWj0BEzZHwOcrnpCBs2uYXCgqMd(2mH3eSeRRzHyXX0mEZ0kdYXHEZlBo0cviQ5HBtYMsoMZkz6iAMMQTNXcpBIHpMGbOqV5LnhAHke18WTjztjhZzPQnAfH3eSwCmnJ3mTYGC8byQT1Rb54IkLjKQ2OvyiLgAqvyNJqSUMfArQAJwr4nb4abNqV5LnhAHke18WTjztjhZzPQnAfH3eSwCmnJ3mTYGC8bTTEnihxuPmHu1gTcdqhGuXXlEhBT3OYo1LMnVe6nVS5qluHOMhUnjBk5yoRKPJOzAQ2Egl8Sjg(ycgGc9Mx2COfQquZd3MKnLCmNP6wfMWBcwlogQc7CeI11SqluDRct4nb4af6nVS5qluHOMhUnjBk5yotRAgeRfhdKkoEX7yR9gv2PU0S5LqV5LnhAHke18WTjztjhZzazo4BZeEtWAXXyaBCVcxusDCtK4esftaiZPWJb5yWqV5LnhAHke18WTjztjhZzAvZGyT4yatP0MwCPza2ouGdtZlBofAvZGfFsfYnVS5uAtlU4tQCCE4Ugw4q2JhURHT0CnpAObKkoEX7yR9gv2PU0S5f0vBUPBoi4jfmacyGHMqknPqkGif2GU6SE2PMIUhrK1JgEYg8KDiJXh)Pko(fGs2s84zhpzHUtTJjeRRzHSeFZh1QBZGXttaC8MQKamHbJ3xztntlHESLD44XgYy8hXhQQIs2cdgV5LnN4jlMQKeMiMxlYsj0h6jBauYwyW4jdXBEzZjE3sfAj0JUULku0j0nv4HB0je8aHoHU8yqogerc667v4En0vBRxdYXfq2zWYGecorQWd3XJjEyGUMx2CqxzR5MsGR2WIee8KcDcD5XGCmiIe013RW9AORMJxwVw7uhVgAepKkoErPtDUIQc6AEzZbDBtlgji4Xg0j0vBZPYOlykLEvkY61ANA0vBRjgdaJUPcpCtaMdJUMx2CqxTTEnihJU8yqogercsqWRPOtOlpgKJbrKGUu2JUWOadyae6AEzZbD1zRGU(EfUxdDbtP0RsrwVw7uJee8WfDcD5XGCmiIe013RW9AORMJxwVw7uhVgAepKkoEbYLjOyUCOfQyETIht8af)H49jaOKqj3rOXt64Hl6AEzZbDbK5GVnt4nbji4bwOtOlpgKJbrKGU(EfUxdD1C8Y61AN64peVpbaLek5ocnEshpCrxZlBoORu1gTcji4jdOtOlpgKJbrKGU(EfUxdDPkSZriwxZcnEGhpqXFiEFcakjuYDeA8KoE4IUMx2CqxOwvmhb1z0kKGGhyqNqxEmihdIibD99kCVg6svyNJqSUMfA8apEGI)q8(eausOK7i04jD8WfDnVS5GUuDRct4nbji41e0j0LhdYXGisqxFVc3RHU(eausOK7i04jD8WfDnVS5GU0QMbrccEGGb6e6YJb5yqejORVxH71qxFcakjuYDeA8yIhUXFiEXC8ifixMGI5YHw4XGCmy8hIhMXlMJhPqniULmLQcpgKJbJ)q8qQ44fixMGI5YHwatDt8AOr8qQ44fLMbnjByjO6wCzykTOQepCqxZlBoOBZ1DQtQqccEGacDcDnVS5GUYwZnLaxTHfD5XGCmiIeKGGhisHoHU8yqogerc667v4En01NaGscLChHgpM4Hl6AEzZbD7vbjibDbzCt1jOti4bcDcD5XGCmiIe013RW9AORMJhsfhVO0Poxrvj(dXR54HuXXl0kdm1bGDGfvf018YMd6s1s15iGmAfsqWtk0j0LhdYXGisqxFVc3RHUqjLg)H41C8PcpCtaMdJUMx2Cq3wDimVS5q4wQGUULkeJbGr3uHhUrccESbDcD5XGCmiIe018YMd62QdH5Lnhc3sf01TuHymam6s3P2XeI11SGeKGUkn7taqMGoHGhi0j0LhdYXGisqccEsHoHU8yqogercsqWJnOtOlpgKJbrKGee8Ak6e6YJb5yqejORVxH71qxXC8ifixMGI5YHw4XGCmi6AEzZbDBUUtDsfsqWdx0j0vBZPYOlPqxTTMymam6QszcPQnAf6AEzZbD1261GCm6YJb5yqejibbpWcDcD5XGCmiIe018YMd6QT1Rb5y0vBZPYOlqORVxH71qxdyJ7v4IsQJBIeNqQycazofEmihdIUABnXyay0vLYesvB0kKGGNmGoHUABovgDHb6QT1eJbGrxq2zWYGecorQWd3OR5Lnh0vBRxdYXOlpgKJbrKGee8ad6e6YJb5yqejOR5Lnh0vBRxdYXOR2MtLrxGqxFVc3RHUI54rkudIBjtPQWJb5yW4peVyoEKcKltqXC5ql8yqogm(dXR54fZXJuCQJ1e7qv22KnNcpgKJbrxTTMymam6cYodwgKqWjsfE4gji41e0j018YMd6Q0Poh6YJb5yqejibbpqWaDcDnVS5GUEtiWZga6YJb5yqejibbpqaHoHU8yqogercsqWdePqNqxZlBoORskBoOlpgKJbrKGee8aHnOtOR5Lnh0fIBk3AHU8yqogercsqc66Z0bM6gk6ecEGqNqxEmihdIibD99kCVg6Q54HuXXlEtiWZgqrvbDnVS5GUGgTcji4jf6e6YJb5yqejORVxH71qxivC8YoERht2CkndW2HgpPJhgf4g)H4HuXXla7QtTJjOI50I7IQc6AEzZbDv6uNdji4Xg0j0LhdYXGisqxFVc3RHU8WDnSXdCmXJnWi(dXdZ49z6atDtr2AUPe4QnSLMby7qJh4Xd341qJ4HuXXlYwZnLaxTHTOQepCqxZlBoOle3uU1cji41u0j0LhdYXGisqxFVc3RHUqQ44fzR5MsGR2WwatDt8AOr88WDnSfqgF9RepWXepWcgOR5Lnh0v2AUPe4QnSibbpCrNqxZlBoOle3uU1ANA0LhdYXGisqccEGf6e6YJb5yqejORVxH71qxFcakjuYDeA8yIhgOR5Lnh0fNBZrG38aSblsqWtgqNqxEmihdIibD99kCVg6Yd31WgpWXep2aJ4pepmJ3NPdm1nfzR5MsGR2WwAgGTdnEGhpqWnEn0iEivC8IS1CtjWvBylQkXdh018YMd6UJ36XKnhKGGhyqNqxEmihdIibDnVS5GUkPS5GU(EfUxdDfRRzPilaMqscWLJN0XdSGB8AOr8WmEzbWessaUC8KoEGagye)H4Hz8qQ44fiUPCRvrvjEn0iEivC8YoERht2CkQkXdN4Hd6QKYMd6czI4ycLu2CisCcREDRalsqWRjOtOlpgKJbrKGU(EfUxdD9jaOKqj3rOXt64HB8hINhURHnEGJjEZlBoL20Il(KkXFiEWukTPfxuaO6KvXTChpPJNufGI)q8qQ44fzR5MsGR2WwuvI)q8WmEivC8cKltqXC5qlQkXRHgXR54fZXJuGCzckMlhAHhdYXGXdN4pepmJxZXlMJhPSJ36XKnNcpgKJbJxdnI3NPdm1nLD8wpMS5uAgGTdnEGhpqat8Wj(dXR54HuXXl74TEmzZPOQGUMx2CqxALbM6aWoqKGGhiyGoHUMx2CqxvktScdGIU8yqogercsqc6sfIAE42KSPOti4bcDcD5XGCmiIe013RW9AORyoEKcKltqXC5ql8yqogm(dXdPIJxuAg0KSHLGQBXLHP0IQs8hIhsfhVa5Yeumxo0cyQBI)q8(eausOK7i04XeVMg)H4btP0MwCPza2o04jD8Ak6AEzZbDBUUtDsfsqWtk0j0LhdYXGisqxFVc3RHUI54rkqUmbfZLdTWJb5yW4pepKkoEbYLjOyUCOfWu3e)H4HuXXlkndAs2Wsq1T4YWuArvj(dXlMJhP4uhRj2HQSTjBofEmihdg)H4btP0MwCPza2o04jD8aHUMx2Cq3MR7uNuHee8yd6e6YJb5yqejORVxH71qxQc7CeI11SqlqTQyocQZOvXd84bz62miHyDnlu018YMd6c1QI5iOoJwHee8Ak6e6YJb5yqejOlE2edFmbbpqOR5Lnh0vjthrZ0uT9msqWdx0j0LhdYXGisqxFVc3RHUnJ3mTYGCC8hIhMXtvyNJqSUMfArQAJwr4njEGhpPIhoOR5Lnh0vQAJwr4nbji4bwOtOlpgKJbrKGU4ztm8Xee8aHUMx2CqxLmDentt12ZibbpzaDcD5XGCmiIe013RW9AORMJxwVw7uhVgAepmJxZXlMJhPa5Yeumxo0cpgKJbJ)q8ndW2HgpPJhuTnzZjESD8WOGnXdN4peVyDnlfzbWessaUC8apEnfDnVS5GUTPfJee8ad6e6YJb5yqejOlE2edFmbbpqOR5Lnh0vjthrZ0uT9msqWRjOtOlpgKJbrKGU(EfUxdDfZXJuGCzckMlhAHhdYXGXFiEivC8cKltqXC5qlQkXFiEygpmJVza2o04jnM4jdXdN4peVc30Lk8ieauDYQ4wUJh4XdMsPnT4IcavNSkUL74X2XdJcWa34Ht8hIxSUMLISaycjjaxoEGhVMIUMx2Cq320IrccEGGb6e6YJb5yqejORVxH71qxivC8cKltqXC5qlQkXFiEivC8IsZGMKnSeuDlUmmLwatDt8hI3NaGscLChHgpPJhUOR5Lnh0fqMd(2mH3eKGGhiGqNqxEmihdIibD99kCVg6cZ4HuXXlYwZnLaxTHTOQe)H4Hz8TTGeS28ifdeKw2jEGhpmJhO4jpEa2Xi8vwxZ04pE8(kRRzkbEBEzZXCXdN4X2X3SVY6AMqwaC8WjE4GUMx2CqxOwvmhb1z0kKGGhisHoHU8yqogerc667v4En0Tz8MPvgKJrxZlBoOlGmh8TzcVjibbpqyd6e6YJb5yqejOlE2edFmbbpqOR5Lnh0vjthrZ0uT9msqWdKMIoHU8yqogerc667v4En0Tz8MPvgKJJ)q8WmETTEnihxuPmHu1gTkEmXtQ41qJ4PkSZriwxZcTivTrRi8MepWJhO4Hd6AEzZbDLQ2OveEtqccEGGl6e6YJb5yqejORVxH71q3MXBMwzqoo(dXRT1Rb54IkLjKQ2OvXJjEGI)q8qQ44fVJT2BuzN6sZMxqxZlBoORu1gTIWBcsqWdeWcDcD5XGCmiIe0fpBIHpMGGhi018YMd6QKPJOzAQ2Egji4bImGoHU8yqogerc667v4En0LQWohHyDnl0cv3QWeEtIh4Xde6AEzZbDP6wfMWBcsqWdeWGoHU8yqogerc667v4En0fsfhV4DS1EJk7uxA28c6AEzZbDPvndIee8aPjOtOlpgKJbrKGU(EfUxdDnGnUxHlkPoUjsCcPIjaK5u4XGCmi6AEzZbDbK5GVnt4nbji4jfmqNqxEmihdIibD99kCVg6cMsPnT4sZaSDOXd84Hz8Mx2Ck0QMbl(KkXtE8Mx2CkTPfx8jvI)4XZd31WgpCINSx88WDnSLMR5jEn0iEivC8I3Xw7nQStDPzZlOR5Lnh0Lw1misqc6sfc8DwAf3u0je8aHoHU8yqogerc6INnXWhtqWde6AEzZbDvY0r0mnvBpJee8KcDcD5XGCmiIe013RW9AOlKkoEHAAB1mrNwxatDd6AEzZbDPM2wnt0P1ibbp2GoHU8yqogerc6INnXWhtqWde6AEzZbDvY0r0mnvBpJee8Ak6e6YJb5yqejORVxH71qxnhVSET2PoEn0iEygFZaSDOXtAmXdQ2MS5ep2oEyuWM4Ht8hIhMXlwxZsPInNuvu8s8apEsb34peVMJxmhpsHAqClzkvfEmihdgpCIxdnIhMX3maBhA8Kgt8GQTjBoXJTJhgfGj(dXRWnDPcpcbavNSkUL74bE8GPu6vPOaq1jRIB5oE4e)H4fRRzPilaMqscWLJh4XdmOR5Lnh0TxfKGGhUOtOlpgKJbrKGU4ztm8Xee8aHUMx2CqxLmDentt12ZibbpWcDcD5XGCmiIe013RW9AOlKkoEHAAB1mrNwxAgGTdnEshpqKcDnVS5GUutBRMj60AKGGNmGoHU8yqogerc6INnXWhtqWde6AEzZbDvY0r0mnvBpJee8ad6e6YJb5yqejORVxH71qxivC8Y25qaSB6Ofvf018YMd6cWwaibbVMGoHUaSJrWd31WIUaHUMx2CqxCUt)MQucOvy0LhdYXGisqcsqx6o1oMqSUMf0je8aHoHU8yqogerc667v4En0vZXdPIJx8MqGNnGIQc6AEzZbD9MqGNnaKGGNuOtOlpgKJbrKGU(EfUxdDHuXXlkDQZvuvIxdnIhsfhVqRmWuha2bwuvqxZlBoOBBAXibbp2GoHUMx2CqxtvscteZRf6YJb5yqejibbVMIoHU8yqogerc6AEzZbD9MZryEzZHWTubDDlvigdaJU(mDGPUHIee8WfDcD5XGCmiIe013RW9AOlykLEvkY61AN64pepykLEvkndW2HgpPJhBI)q8I11SuKfatijb4YXd84bcgXFiEygVyDnlLk2CsvrXlXt64jfCJxdnIxmhpsHAqClzkvfEmihdgpCqxZlBoOlo3PFtvkb0kmsqWdSqNqxEmihdIibD99kCVg66taqjHsUJqJht8Wn(dXdPIJxuAg0KSHLGQBXLHP0IQs8hIxmhpsbYLjOyUCOfEmihdg)H4HuXXlqUmbfZLdTaM6M4pepmJxZXdPIJx2XB9yYMtrvjEn0iEWuk9QuAgGTdnEshpWepCqxZlBoOBZ1DQtQqccEYa6e6YJb5yqejORVxH71qxFcakjuYDeA8apEnfDnVS5GUT6qyEzZHWTubDDlvigdaJUuHaFNLwXnfji4bg0j0LhdYXGisqxZlBoOBRoeMx2CiClvqx3sfIXaWOlviQ5HBtYMIeKGe01uLQSr37c4OGeKGqa]] )
end