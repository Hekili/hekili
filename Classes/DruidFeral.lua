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
                -- if not talent.bloodtalons.enabled then return false end
                if buff.bloodtalons.up then return false end
                -- if buff.cat_form.down or not buff.prowl.up then return buff.predatory_swiftness.up or time == 0 end
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
    
        package = "Feral"
    } )


    spec:RegisterPack( "Feral", 20180904.2135, [[d8e5cbqicQwevuj9iKOUevuPSjr0NaO0OOs1PejwfbfEfvWSqc3IaYUe1VafddGCmaSmQu8mQOmnrQ6Air2gbL(gafJdGQZrLsSorQ07OIQW8ia3duTprshKaQwib5HIuktKakDrQOkAJuPuFKkLuJKkQeNKkQyLujZKkQQBksPQDIK8tQOknurkzPIuXtbAQGsxLkLKVsaf7fQ)cXGv1HPSyqEmvnzL6YO2mK(SsA0kXPvz1IuQ8AQqZMOBdODl1VLmCK64eu0Yv8CetN01j02PI8Dry8IuCEc06PIkvZhj1(fgdagwm42ugtLBaeaaoGClaYzz3aGZOeLewmOkinJbPnVJ2kJbBdiJbDBEmjgK2euw2gdlgKuIJNXGlQstsxyGz90frOSVacd5akkn9Q2pgQcd5a6HbswqWaHAc0MDcg6PqpjtGjTgoDSBtGjTsheb2r82iUnpMmtoGEmiK4jvNtJHWGBtzmvUbqaa4aYTaiNLDdaUj9Pp9yqcn7XubaGCggCZepgKYX728yY4fyhXBhUOC8lQstsxyGz90frOSVacd5akkn9Q2pgQcd5a6HbswqWaHAc0MDcg6PqpjtGjTgoDSBtGjTsheb2r82iUnpMmtoG(WfLJhKPvgiepXNEkI3nacaapEbkEHnDDgGIpTs7dxHlkhFABX6vMKUHlkhVafVaFV5D8GokkLXlKrwYHlkhVafVZxef1IxGzmA6RxjXxTuW4bAQYt8jw4oEj7elJxaXdaacBoCr54fO4f47nVJxOrunz8GsJSeVwXx0CZt8KR9C8NcyjXt0P6vEIxxSoEWLH35WfLJxGIpTKMN3XN2mnE3UgGXBOkpXNwtLqgp5AphFAnvcz86CRR8qIpTzA8UDnaZHlkhVafFrZnpi7Q54ps8lwVL8o(RvEAtkfmEibJxx44T9UANhXpmWYjEhVUWeoENS5mijtYyq6PqpjJbPC8UnpMmEb2r82Hlkh)IQ0K0fgywpDrek7lGWqoGIstVQ9JHQWqoGEyGKfemqOMaTzNGHEk0tYeysRHth72eysR0brGDeVnIBZJjZKdOpCr54bzALbcXt8PNI4DdGaaWJxGIxytxNbO4tR0(Wv4IYXN2wSELjPB4IYXlqXlW3BEhpOJIsz8czKLC4IYXlqX78frrT4fygJM(6vs8vlfmEGMQ8eFIfUJxYoXY4fq8aaGWMdxuoEbkEb(EZ74fAevtgpO0ilXRv8fn38ep5Aph)Paws8eDQELN41fRJhCz4DoCr54fO4tlP55D8PntJ3TRby8gQYt8P1ujKXtU2ZXNwtLqgVo36kpK4tBMgVBxdWC4IYXlqXx0CZdYUAo(Je)I1BjVJ)ALN2KsbJhsW41foEBVR25r8ddSCI3XRlmHJ3jBodsYKC4kCr54DEMg2lQ8oEigTgoEFbeY04H41Rj54f4EptRK47QfOfBaIkkJ386vnj(QLcMdxMxVQjz6H9fqitHJknIJHlZRx1Km9W(ciKPoahg0Q2HlZRx1Km9W(ciKPoahgtCfi3QPx1HlZRx1Km9W(ciKPoahMHxNkHUqXHcxnj3Agsw1wnz1Km3gKK3HlZRx1Km9W(ciKPoahgNS5mijtrBaz4IegrxgJSqHtMuKHdOWL51RAsMEyFbeYuhGdJt2CgKKPOnGmCrcJOlJrwOWjtkYWbGIdfolmfpAAENLIOOgsIXOPVELKuYoXsbaaacB4IYX)fn38GSRM)4ps8lwVL8o(RvEAtkfmEibJxx44T9UAkIVAphVUWXJEdrJpDo64ps8gnT84D8xhVfp6TUO5WfLJ386vnjtpSVaczQdWHXjBodsYu0gqgErZnpi7QzkCYKImCafUOC8oV0CZt8W62XFK43S0eK3XFOXNGJVzEhVwXVyZ2Ben(HxNkHUeV0uEIV64VoEDHJFk10R6WL51RAsMEyFbeYuhGdJt2CgKKPOnGm8nlnb5nIIIu0CZdfozsrgoGcxuoEyxos8lgnn3K4tSWD8GgepAv6cfXlKSQTAYQjXdjQX3LgVZ35e)rIxnj3kVdxMxVQjz6H9fqitDaomozZzqsMI2aYW3S0eK3ikksrZnpu4Kjfz4aqXHcxnj3AMyq8OvPlzUnijVtQMKBndjRARMSAsMBdsY7Kcxnj3Awk22GCnH(gtVQZCBqsEhUmVEvtY0d7lGqM6aCyONkHmCzE9QMKPh2xaHm1b4W4nfbTgGHlkhpyB0KLsJFSBhpKikkVJNOMsIhIrRHJ3xaHmnEiE9As8wVJNEybIUu9614ps87Q5C4Y86vnjtpSVaczQdWHH0gnzPueIAkjCzE9QMKPh2xaHm1b4WaXdHhhdxMxVQjz6H9fqitDaom0LEvhUcxuoENNPH9IkVJNDIhbJxpGC86chV51AI)iXBozN0GKCoCzE9QMa3e1cXu18osXHcx4qIOOz6PsiZI0jfoKikAMSy7kbqwUZI0HlZRx1ehGddXrrPebYilHlZRx1ehGdZi2iMxVQrKhrPOnGm8IMBEO4qHl8IMBEq2vZHlZRx1ehGdZi2iMxVQrKhrPOnGmCY1RsgrTzL1Wv4Y86vnj7RsURenb(2iluCOWfoKikA2BkcAnaZI0HlZRx1KSVk5Us0ehGdd9ujKuCOWHerrZx7TPn9Qopmq7AIaauMsjHerrZPDI9QKriQjDKNSiD4Y86vnj7RsURenXb4WaXdHhhP4qHZnpRcMkCNbOKU7RsUReDwVvEiiOIJG5HbAxtsLsutnKikAwVvEiiOIJGzr6ucxMxVQjzFvYDLOjoahg9w5HGGkocsXHcNBEwfmVz0ZFAQWfwafUmVEvtY(QK7krtCaomq8q4XXRxdxMxVQjzFvYDLOjoahguEmjc6WTZDbP4qH7lGqfcDDTsGdOWL51RAs2xLCxjAIdWH5AVnTPx1uCOW5MNvbtfUZaus39vj3vIoR3kpeeuXrW8WaTRjPcaLOMAiru0SER8qqqfhbZI0PeUmVEvtY(QK7krtCaom0LEvtrBaz4qMQsgHU0RAKcfXwp5PcsXHcxTzL1SEazeTq2hlaHLsutT76bKr0czFSaaaWbus3HerrZq8q4XXSin1udjIIMV2BtB6vDwKoLucxMxVQjzFvYDLOjoahgYITReaz5MIdfUVacvi011kraukj38SkyQWnVEvNhZro7lIMCxAEmh5mnqrPE0YJhb4MmajHerrZ6TYdbbvCemlsN0Diru0mKSQTAYQjzrAQPw4Qj5wZqYQ2QjRMK52GK8oLKUlC1KCR5R920MEvN52GK8MAQ9vj3vIoFT3M20R68WaTRjPcaGNssHdjIIMV2BtB6vDwKoCzE9QMK9vj3vIM4aCyejmYPmqs4kCr54PC8WUWXx0CZt8RCZJjLcgpAjLvI41foEzTE(4l041fo(HjA8fA86chVrlPiEirn(JepHPTXuEhFjQXVWdhpAnXlR1ZBY49sBovWWfLJ35LM7RxJhw3o(eNugpeh)MLMG8o(dn(eC8nZ741k(fB2EJOXlnLN4DpXY5xIFXOP5MeFItxIh0G4rRsxIpz8cbB8qIA8DfVZ35Ks4IYX78Ql8K4iC8j44tCsz8fn3XN40L4H1TPiEblX49whpXqzPGX7nIgVUCK4rNcy8eLnPUeFItxkrnEOHnhVEn(tZHlZRx1KCrZnpW1BLhccQ4iifhkCNS5mijN3S0eK3ikksrZnpWbu4IYXlWLjmbjXx0ChFItxIFmhzkI3xnre41RXtu2K6s8wVJVAoEHGnE)InRC8UFOXRMKBL3PeUmVEvtYfn384aCygZrMIdfUW1Z741RutnKikAMEQeYSiD4IYX78zLepqZroEI4WXNGJN7D86chFrZnpX7CLWctrU9SZ14tSWD8L4ep6nen(5OJ)iXRN3XRxdxuoEZRx1KCrZnpoahgNS5mijtrBaz4fn38GSRMPWjtkYWbGIdf(U08C0z98oE9A4IYXl0WMJXxIA8fA86chV51R64LhrdxuoEZRx1KCrZnpoahMe2PuqypCaLbeGaGIdf(U08C0z98oE9A4IYX7CqJpbh)I5ehVZ35qr8wVJFXCIBaRgVrtlpEh)PXliRXls44bwvJEdNdxuoEN30HI4p04tWXxTuW4xmN44RMJxiyJ3VyZkhV51ZjoEcTbmEGv1O3WXl26jJpbhV364nAAPGXphD8joDj(tdxMxVQj5IMBECaomaRQrVHr8MsXHcx465D86vQPgsefndjRARMSAsMOM3r4aK0xaHke66ALiakfUOC8U1NtChVxCgU14vX(614pn(JeVjtycsIprn6s8aTRv76RxJxxgJSqr8KkEjRK4nAAPGXFA8l8W5WL51RAsUO5MhhGdJUmgzbXBkfhkCHRN3XRxt6lGqfcDDTseaLcxuoE3DUWoEYlL4DRiC8cnIQjJhuAKL4p04fSeJxnj3kVJhTM4pLI4pfWsINOt1R8eVUyD8GldVZHlZRx1KCrZnpoahgOrunjcrAKfkou4(ciuHqxxRebqPKUl8XUnc7e3A22BsMtZruc1up2TryN4wZ2EtYxNkQOuImSFXMvgrpGm1utOzPerTzLvsgAevtIqKgzjvasjCr54D35c74jVuI3TIWXdM4O54p041fE44THJhOOupAjhVAZkRKC4Y86vnjx0CZJdWHHK4OzeVPuCOW9fqOcHUUwjcGsjj0SuIO2SYkjtsC0mI30ubiCr54f49o(dn(UAo(cnEDHJ3GkN44nAAPGueFcoEYbKwky8KLH3Xl26jJNsHlZRx1KCrZnpoahgYYWBkou4(ciuHqxxRebqPWfLJpD41PsOlueFIfUJpbh)I5ehpLI3xaHQ4PRRvs8wVJhsw1wnz1K4TEhpF6cpPB4IYXlWWXVyoXXdAq8OvPlXB9o(UI3865ehpKSQTAYQjXtuZ7y8U70zXN272XtOnGPep7e3XFOXFA8dlmfVHjXBXVyZoEVr0WfLJxGHJFXCIJ3INE4TP1iy8KehQ2mHep9u(4nNStAqsoE3D6S4btN4rpYY1RPeUmVEvtYfn384aCygEDQe6cfl2S9grHRJitXHc3xaHke66ALaNsjvtYTMHKvTvtwnjZTbj5Ds3vtYTMjgepAv6sMBdsY7KqIOOzizvB1KvtY7krtn1qIOOz6H3MwJGiKehQ2mHKfPtjCr54DoOXNGJN7nVJxKo(fB2EJOxVgF6WRtLqxOiErchpSUD8Af)Wce3kpX7nnE0AagUmVEvtYfn384aCy0BLhccQ4iy4IYXlW7D8v754tWXVYA8l8WXBA8ukEFbeQqORRvcfXN2js04NJoER3XNGJ3goEr64TEh)i291RHlZRx1KCrZnpoahM5OP4qH7lGqfcDDTsGtPWv4Y86vnjtUEvYiQnRSc3BkcAnaP4qHlCiru0S3ue0AaMfPdxMxVQjzY1RsgrTzLvhGdZyoYuCOWHerrZ0tLqMfPPMAiru0mzX2vcGSCNfPdxMxVQjzY1RsgrTzLvhGdJjQfIPQ5DmCzE9QMKjxVkze1MvwDaomEtkrmVEvJipIsrBaz4(QK7krtcxMxVQjzY1RsgrTzLvhGddkpL)krcc0PmfQnRSICOW3LMNJoRN3XRxtUlnphDEyG21eb4SKQnRSM1diJOfY(4ubaqjDxTzL18cBsDjt7vb4gkrn1Qj5wZedIhTkDjZTbj5DkHlZRx1Km56vjJO2SYQdWHz41PsOluCOW9fqOcHUUwjWPusiru0m9WBtRrqesIdvBMqYI0jvtYTMHKvTvtwnjZTbj5Dsiru0mKSQTAYQj5DLOt6UWHerrZx7TPn9Qolstn17sZZrNhgODnraaEkHlZRx1Km56vjJO2SYQdWHz41PsOluCOW9fqOcHUUwjP6SKQj5wZqYQ2QjRMK52GK8ojKikAME4TP1iicjXHQntizr6KqIOOzJMtdc9WBtRjlsNesefnFT3M20R68Us0HlZRx1Km56vjJO2SYQdWHbLNYFLibb6uMIdfoKikA2O50Gqp820AYI0jD3DFbeQqORRvsQPpP7qIOO5R920MEvNfPPMA1KCRzGfqUvKcfXlT5ubZCBqsENskutT7Qj5wZqYQ2QjRMK52GK8ojKikAgsw1wnz1KSiDsFbeQqORRvsQolLucxMxVQjzY1RsgrTzLvhGdZi2iMxVQrKhrPOnGmCIIGE9rw4HqXHc3xaHke66ALKA6dxMxVQjzY1RsgrTzLvhGdZi2iMxVQrKhrPOnGmCIISYnpMwdjCfUmVEvtYefb96JSWdboDvsKHjL44zkqRbP50OWbiCzE9QMKjkc61hzHhIdWHHyozRmYu2qXHchsefntmNSvgzkBY7krhUmVEvtYefb96JSWdXb4WqxLezysjoEMc0AqAonkCacxMxVQjzIIGE9rw4H4aCyMJMc1Mvwrou4cxpVJxVsn1Upmq7AIaGVfhtVQfgak7Sus6UAZkR5f2K6sM2RP6gkLu4Qj5wZedIhTkDjZTbj5DkutT7dd0UMia4BXX0RAHbGYaEsAEihr5wrakk1JwE8K6U08C0zAGIs9OLhpPKuTzL1SEazeTq2hNkGhUmVEvtYefb96JSWdXb4WqxLezysjoEMc0AqAonkCacxMxVQjzIIGE9rw4H4aCyiMt2kJmLnuCOWHerrZeZjBLrMYM8WaTRjcaa3eUmVEvtYefb96JSWdXb4WGYt5VsKGaDktbqlniCZZQGWbiCfUmVEvtYefzLBEmTgc8HxNkHUqXHcxnj3Agsw1wnz1Km3gKK3jHerrZ0dVnTgbrijouTzcjlsNesefndjRARMSAsExj6K(ciuHqxxRe4Pp5U08yoY5HbAxteq6dxMxVQjzIISYnpMwdXb4Wm86uj0fkou4SWu8OP5D2oP4ui0Ly75HKunj3Agsw1wnz1Km3gKK3jDhsefntp820AeeHK4q1MjKmrnVJP6gQP2Diru0m9WBtRrqesIdvBMqYe18oMkaj3LMhZropmq7AIaCwkPKesefndjRARMSAsExj6WL51RAsMOiRCZJP1qCaomqJOAseI0iluCOWj0SuIO2SYkjdnIQjrisJSK6Mj3WBe1MvwjHlZRx1Kmrrw5MhtRH4aCyORsImmPehptbAninNgfoaHlZRx1Kmrrw5MhtRH4aCy0LXiliEtP4qHpm6WKfdsYjDNqZsjIAZkRKSUmgzbXBAQUjLWL51RAsMOiRCZJP1qCaom0vjrgMuIJNPaTgKMtJchGWL51RAsMOiRCZJP1qCaom6YyKfeVPuCOWj0SuIO2SYkjRlJrwq8MMQZsYctXJMM3zPikQHKymA6RxjjvtYTMHgr1KiePrwYCBqsEhUmVEvtYefzLBEmTgIdWHHUkjYWKsC8mfO1G0CAu4aeUmVEvtYefzLBEmTgIdWHzmhzkuBwzf5qHlC98oE9k1u7UWvtYTMHKvTvtwnjZTbj5DYHbAxteWwCm9QwyaOSZsjPAZkRz9aYiAHSpo10hUmVEvtYefzLBEmTgIdWHHUkjYWKsC8mfO1G0CAu4aeUmVEvtYefzLBEmTgIdWHzmhzkuBwzf5qHRMKBndjRARMSAsMBdsY7KqIOOzizvB1KvtYI0jD39HbAxteaCatkjP5HCeLBfbOOupA5XtQ7sZJ5iNPbkk1JwE8imaugWPukjvBwznRhqgrlK9XPM(WL51RAsMOiRCZJP1qCaomqJOAseI0iluCOWDhsefnR3kpeeuXrWSiDs3h72iStCRzBVj5Rt1DaCaOLge)InRmrG8l2SYee0X86vTjtrymSFXMvgrpGCkPeUmVEvtYefzLBEmTgIdWHbyvn6nmI3ukuBwzf5qHpm6WKfdsYHlZRx1Kmrrw5MhtRH4aCyORsImmPehptbAninNgfoaHlZRx1Kmrrw5MhtRH4aCy0LXiliEtP4qHpm6WKfdsYjD3jBodsYzrcJOlJrwG7gQPMqZsjIAZkRKSUmgzbXBAQaKs4Y86vnjtuKvU5X0AioahgDzmYcI3ukou4dJomzXGKCsNS5mijNfjmIUmgzboajHerrZEjBJ3i61R5HnVgUmVEvtYefzLBEmTgIdWHHUkjYWKsC8mfO1G0CAu4aeUmVEvtYefzLBEmTgIdWHHK4OzeVPuCOWj0SuIO2SYkjtsC0mI30ubiCzE9QMKjkYk38yAnehGddzz4nfhk8DP5XCKZdd0UMKQ7MxVQZKLH3zFruhmVEvNhZro7lIkqCZZQGP4CJBEwfmp8k3utnKikA2lzB8grVEnpS5vmOt8qUQXu5gabaGdiaJBa8maagkrjmycB6RxjyqbgbE6qLZHk360n(4HDHJ)asxJgpAnXdy3mQjkvaB8dlmfVH3XtkGC8MOwanL3X7xSELj5WLZ)AoEas34DRAIinDnkVJ386vD8awtuletvZ7iGnhUcxcmc80HkNdvU1PB8Xd7ch)bKUgnE0AIhWsUEvYiQnRScyJFyHP4n8oEsbKJ3e1cOP8oE)I1RmjhUC(xZX7S0nE3QMistxJY74nVEvhpG1e1cXu18ocyZHRWLZbiDnkVJhWeV51R64Lhrj5Wfg0e1LAWGGhW0gguEeLGHfdw0CZdgwmvaGHfdYTbj5nwimOFoLNZWGozZzqsoVzPjiVruuKIMBEIhE8acdAE9QgdQ3kpeeuXrqSIPYnyyXGCBqsEJfcd6Nt55mmOWJxpVJxVgp1uhpKikAMEQeYSing086vngCmhzSIPYzyyXGCBqsEJfcd6Nt55mmOWJxpVJxVgp1uhpKikAgsw1wnz1KmrnVJXdpEaIpz8(ciuHqxxRK4fq8ucdAE9QgdcSQg9ggXBkwXuLEmSyqUnijVXcHb9ZP8Cggu4XRN3XRxJpz8(ciuHqxxRK4fq8ucdAE9QgdQlJrwq8MIvmvucdlgKBdsYBSqyq)CkpNHb9fqOcHUUwjXlG4Pu8jJ394fE8JDBe2jU1ST3KmNMJOK4PM64h72iStCRzBVj5RJp14rfLsKH9l2SYi6bKJNAQJNqZsjIAZkRKm0iQMeHinYs8PgpaXNcg086vngeAevtIqKgzbRyQewmSyqUnijVXcHb9ZP8Cgg0xaHke66ALeVaINsXNmEcnlLiQnRSsYKehnJ4nn(uJhamO51RAmijXrZiEtXkMkadgwmi3gKK3yHWG(5uEodd6lGqfcDDTsIxaXtjmO51RAmizz4nwXub4yyXGCBqsEJfcdAE9Qgdo86uj0fmOFoLNZWG(ciuHqxxRK4HhpLIpz8Qj5wZqYQ2QjRMK52GK8o(KX7E8Qj5wZedIhTkDjZTbj5D8jJhsefndjRARMSAsExj64PM64HerrZ0dVnTgbrijouTzcjlshFkyWfB2EJOyqDezSIPYTGHfdAE9QgdQ3kpeeuXrqmi3gKK3yHWkMkaaegwmi3gKK3yHWG(5uEodd6lGqfcDDTsIhE8ucdAE9QgdohnwXkgCZOMOuXWIPcamSyqUnijVXcHb9ZP8Cggu4XdjIIMPNkHmlshFY4fE8qIOOzYITReaz5olsJbnVEvJbnrTqmvnVJyftLBWWIbnVEvJbjokkLiqgzbdYTbj5nwiSIPYzyyXGCBqsEJfcd6Nt55mmOWJVO5MhKD1mg086vngCeBeZRx1iYJOyq5ruK2aYyWIMBEWkMQ0JHfdYTbj5nwimO51RAm4i2iMxVQrKhrXGYJOiTbKXGKRxLmIAZkRyfRyq6H9fqitXWIPcamSyqUnijVXcHvmvUbdlgKBdsYBSqyftLZWWIb52GK8glewXuLEmSyqUnijVXcHb9ZP8Cggunj3Agsw1wnz1Km3gKK3yqZRx1yWHxNkHUGvmvucdlgKBdsYBSqyqNmPiJbbeg086vng0jBodsYyqNSbPnGmguKWi6YyKfSIPsyXWIb52GK8gleg086vng0jBodsYyqNmPiJbbad6Nt55mmilmfpAAENLIOOgsIXOPVELeFY4LStSmEbepaaiSyqNSbPnGmguKWi6YyKfSIPcWGHfdYTbj5nwimOtMuKXGacdAE9Qgd6KnNbjzmOt2G0gqgdUzPjiVruuKIMBEWkMkahdlgKBdsYBSqyqZRx1yqNS5mijJbDYKImgeamOFoLNZWGQj5wZedIhTkDjZTbj5D8jJxnj3Agsw1wnz1Km3gKK3XNmEHhVAsU1SuSTb5Ac9nMEvN52GK8gd6KniTbKXGBwAcYBeffPO5MhSIPYTGHfdAE9QgdspvcjgKBdsYBSqyftfaacdlg086vng0BkcAnaXGCBqsEJfcRyQaaamSyqUnijVXcHvmva4gmSyqZRx1yqiEi84igKBdsYBSqyftfaoddlg086vngKU0RAmi3gKK3yHWkwXG(QK7krtWWIPcamSyqUnijVXcHb9ZP8Cggu4XdjIIM9MIGwdWSing086vngCBKfSIPYnyyXGCBqsEJfcd6Nt55mmiKikA(AVnTPx15HbAxtIxaXdOmLIpz8qIOO50oXEvYie1KoYtwKgdAE9QgdspvcjwXu5mmSyqUnijVXcHb9ZP8CggKBEwfm(uHhVZau8jJ3949vj3vIoR3kpeeuXrW8WaTRjXNA8ukEQPoEiru0SER8qqqfhbZI0XNcg086vngeIhcpoIvmvPhdlgKBdsYBSqyq)CkpNHb5MNvbZBg98NgFQWJxybeg086vnguVvEiiOIJGyftfLWWIbnVEvJbH4HWJJxVIb52GK8glewXujSyyXGCBqsEJfcd6Nt55mmOVacvi011kjE4XdimO51RAmikpMebD425UGyftfGbdlgKBdsYBSqyq)CkpNHb5MNvbJpv4X7mafFY4DpEFvYDLOZ6TYdbbvCempmq7As8PgpaukEQPoEiru0SER8qqqfhbZI0XNcg086vng8AVnTPx1yftfGJHfdYTbj5nwimO51RAmiDPx1yq)CkpNHbvBwznRhqgrlK9XXlG4fwkfp1uhV7XRhqgrlK9XXlG4baWbu8jJ394HerrZq8q4XXSiD8utD8qIOO5R920MEvNfPJpL4tbdsx6vngeYuvYi0LEvJuOi26jpvqSIPYTGHfdYTbj5nwimOFoLNZWG(ciuHqxxRK4fq8uk(KXZnpRcgFQWJ386vDEmh5SViA8jJFxAEmh5mnqrPE0YJN4fq8Ujdq8jJhsefnR3kpeeuXrWSiD8jJ394HerrZqYQ2QjRMKfPJNAQJx4XRMKBndjRARMSAsMBdsY74tj(KX7E8cpE1KCR5R920MEvN52GK8oEQPoEFvYDLOZx7TPn9Qopmq7As8PgpaaE8PeFY4fE8qIOO5R920MEvNfPXGMxVQXGKfBxjaYYnwXubaGWWIbnVEvJbfjmYPmqcgKBdsYBSqyfRyqY1RsgrTzLvmSyQaadlgKBdsYBSqyq)CkpNHbfE8qIOOzVPiO1amlsJbnVEvJb9MIGwdqSIPYnyyXGCBqsEJfcd6Nt55mmiKikAMEQeYSiD8utD8qIOOzYITReaz5olsJbnVEvJbhZrgRyQCggwmO51RAmOjQfIPQ5DedYTbj5nwiSIPk9yyXGCBqsEJfcdAE9Qgd6nPeX86vnI8ikguEefPnGmg0xLCxjAcwXurjmSyqUnijVXcHb9ZP8CggCxAEo6SEEhVEn(KXVlnphDEyG21K4fq8ol(KXR2SYAwpGmIwi7JJp14baqXNmE3JxTzL18cBsDjt714fq8UHsXtn1XRMKBntmiE0Q0Lm3gKK3XNcg086vngeLNYFLibb6ugRyQewmSyqUnijVXcHb9ZP8Cgg0xaHke66ALep84Pu8jJhsefntp820AeeHK4q1MjKSiD8jJxnj3Agsw1wnz1Km3gKK3XNmEiru0mKSQTAYQj5DLOJpz8UhVWJhsefnFT3M20R6SiD8utD87sZZrNhgODnjEbepGhFkyqZRx1yWHxNkHUGvmvagmSyqUnijVXcHb9ZP8Cgg0xaHke66ALeFQX7S4tgVAsU1mKSQTAYQjzUnijVJpz8qIOOz6H3MwJGiKehQ2mHKfPJpz8qIOOzJMtdc9WBtRjlshFY4HerrZx7TPn9QoVReng086vngC41PsOlyftfGJHfdYTbj5nwimOFoLNZWGqIOOzJMtdc9WBtRjlshFY4DpE3J3xaHke66ALeFQXN(4tgV7XdjIIMV2BtB6vDwKoEQPoE1KCRzGfqUvKcfXlT5ubZCBqsEhFkXNs8utD8UhVAsU1mKSQTAYQjzUnijVJpz8qIOOzizvB1KvtYI0XNmEFbeQqORRvs8PgVZIpL4tbdAE9QgdIYt5VsKGaDkJvmvUfmSyqUnijVXcHb9ZP8Cgg0xaHke66ALeFQXNEmO51RAm4i2iMxVQrKhrXGYJOiTbKXGefb96JSWdbRyQaaqyyXGCBqsEJfcdAE9QgdoInI51RAe5rumO8iksBazmirrw5MhtRHGvSIbjkc61hzHhcgwmvaGHfdYTbj5nwimiAninNgftfayqZRx1yq6QKidtkXXZyftLBWWIb52GK8gleg0pNYZzyqiru0mXCYwzKPSjVReng086vngKyozRmYu2GvmvoddlgKBdsYBSqyq0AqAonkMkaWGMxVQXG0vjrgMuIJNXkMQ0JHfdYTbj5nwimOFoLNZWGcpE98oE9A8utD8Uh)WaTRjXla4XVfhtVQJxyepGYol(uIpz8UhVAZkR5f2K6sM2RXNA8UHsXNmEHhVAsU1mXG4rRsxYCBqsEhFkXtn1X7E8dd0UMeVaGh)wCm9QoEHr8akd4XNmEAEihr5wrakk1JwE8eFQXVlnphDMgOOupA5Xt8PeFY4vBwznRhqgrlK9XXNA8aog086vngCoASIPIsyyXGCBqsEJfcdIwdsZPrXubag086vngKUkjYWKsC8mwXujSyyXGCBqsEJfcd6Nt55mmiKikAMyozRmYu2KhgODnjEbepaUbdAE9QgdsmNSvgzkBWkMkadgwmiqlniCZZQGyqaWGMxVQXGO8u(RejiqNYyqUnijVXcHvSIbjkYk38yAnemSyQaadlgKBdsYBSqyq)CkpNHbvtYTMHKvTvtwnjZTbj5D8jJhsefntp820AeeHK4q1MjKSiD8jJhsefndjRARMSAsExj64tgVVacvi011kjE4XN(4tg)U08yoY5HbAxtIxaXNEmO51RAm4WRtLqxWkMk3GHfdYTbj5nwimOFoLNZWGSWu8OP5D2oP4ui0Ly75HeFY4vtYTMHKvTvtwnjZTbj5D8jJ394HerrZ0dVnTgbrijouTzcjtuZ7y8PgVBINAQJ394HerrZ0dVnTgbrijouTzcjtuZ7y8PgpaXNm(DP5XCKZdd0UMeVaI3zXNs8PeFY4HerrZqYQ2QjRMK3vIgdAE9Qgdo86uj0fSIPYzyyXGCBqsEJfcd6Nt55mmiHMLse1MvwjzOrunjcrAKL4tn(ntUH3iQnRSsWGMxVQXGqJOAseI0ilyftv6XWIb52GK8glegeTgKMtJIPcamO51RAmiDvsKHjL44zSIPIsyyXGCBqsEJfcd6Nt55mm4WOdtwmijhFY4DpEcnlLiQnRSsY6YyKfeVPXNA8Uj(uWGMxVQXG6YyKfeVPyftLWIHfdYTbj5nwimiAninNgftfayqZRx1yq6QKidtkXXZyftfGbdlgKBdsYBSqyq)CkpNHbj0SuIO2SYkjRlJrwq8MgFQX7S4tgplmfpAAENLIOOgsIXOPVELeFY4vtYTMHgr1KiePrwYCBqsEJbnVEvJb1LXiliEtXkMkahdlgKBdsYBSqyq0AqAonkMkaWGMxVQXG0vjrgMuIJNXkMk3cgwmi3gKK3yHWG(5uEoddk841Z741RXtn1X7E8cpE1KCRzizvB1KvtYCBqsEhFY4hgODnjEbe)wCm9QoEHr8ak7S4tj(KXR2SYAwpGmIwi7JJp14tpg086vngCmhzSIPcaaHHfdYTbj5nwimiAninNgftfayqZRx1yq6QKidtkXXZyftfaaGHfdYTbj5nwimOFoLNZWGQj5wZqYQ2QjRMK52GK8o(KXdjIIMHKvTvtwnjlshFY4DpE3JFyG21K4fa84bmXNs8jJNMhYruUveGIs9OLhpXNA87sZJ5iNPbkk1JwE8eVWiEaLbCkfFkXNmE1MvwZ6bKr0czFC8PgF6XGMxVQXGJ5iJvmva4gmSyqUnijVXcHb9ZP8Cgg094HerrZ6TYdbbvCemlshFY4Dp(XUnc7e3A22Bs(64tnE3JhG4DiEGwAq8l2SYK4fO49l2SYee0X86vTjJpL4fgXpSFXMvgrpGC8PeFkyqZRx1yqOrunjcrAKfSIPcaNHHfdYTbj5nwimOFoLNZWGdJomzXGKmg086vngeyvn6nmI3uSIPcG0JHfdYTbj5nwimiAninNgftfayqZRx1yq6QKidtkXXZyftfaucdlgKBdsYBSqyq)CkpNHbhgDyYIbj54tgV7X7KnNbj5SiHr0LXilXdpE3ep1uhpHMLse1MvwjzDzmYcI304tnEaIpfmO51RAmOUmgzbXBkwXubGWIHfdYTbj5nwimOFoLNZWGdJomzXGKC8jJ3jBodsYzrcJOlJrwIhE8aeFY4HerrZEjBJ3i61R5HnVIbnVEvJb1LXiliEtXkMkaamyyXGCBqsEJfcdIwdsZPrXubag086vngKUkjYWKsC8mwXubaGJHfdYTbj5nwimOFoLNZWGeAwkruBwzLKjjoAgXBA8PgpayqZRx1yqsIJMr8MIvmva4wWWIb52GK8gleg0pNYZzyWDP5XCKZdd0UMeFQX7E8MxVQZKLH3zFr04DiEZRx15XCKZ(IOXlqXZnpRcgFkX7ClEU5zvW8WRChp1uhpKikA2lzB8grVEnpS5vmO51RAmizz4nwXkwXkwXy]] )
end