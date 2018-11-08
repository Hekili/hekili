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
                applyBuff( buff.incarnation.up and "prowl_incarnation" or "prowl_base" )
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


    spec:RegisterPack( "Feral", 20181022.2033, [[d40fcbqiIGfHOi6rqkUKkeHnPc(erOAuQiDkveRcrj9kIOzbP6waGDjYVurnma0XaLwgOWZuH00GuQRHiSniL4BeHyCQq5CaqzDikL3reszEiIUhKSpqrhKiuwiI0dvHOMiri5IQqeTref(irivNesjTsIQzIOOCtefv7eu1pruIHQcHLca5PQ0ubORQcr6Raq1EH6VimyvDyklgKhtvtgOlJAZq8zr1OfLtR0QruKEnrYSPYTb0UL63sgobhhrry5kEostN01j02js9DIY4vHQZdQSEeLQ5JOA)cJHfdi(cAkJHhgae2JblaHbmsWaGhfTrB0gFv4ey8vW8sz5m(2gqgFjdEmh(kyW5kdedi(slXXZ4BMQcuY25Z5RMjcL8fWZ0fOOZ0TA)yi6z6c0FgYvqNHqmaaKL(SWuiRJPNpIHbq2cspFeaicjQrCbjidEmxIUa94lK46u0AJHWxqtzm8WaGWEmybimGrcga8OOnAdl(sfypgEyb4rX3SfeKBme(cYup(IM4jdEmx8suJ4cgYrt8zQkqjBNpNVAMiuYxaptxGIot3Q9JHONPlq)zixbDgcXaaqw6ZctHSoME(iggazli98raGiKOgXfKGm4XCj6c0hYrt8KfVwq8epmGb6Xddac7XIhaI)yKTJcJ4pcY8qEihnXFKZSoNPKTqoAIhaIxIbcYGXFLs05INuJMLc5OjEaiEjgiidgpPJOAU4VoJMD(kBf441k(sGBEIF74bk60fauBYznfYrt8aq8hHZ8my8hztJNmQby8gIYt8hXuYCXt32ZXFetjZfVoBEop04pYMgpzudWuihnXdaXdGyNDCgmEa3CEK404jdXbU45MNC4I3NXEPIxR4nbbhCXxTdU4LLXD8aU58iXPXtgIdCXV04n3WgiCXlkKc5OjEai(sGBEiaRMJFPXNznOJbJFBLN2Co4IhcU41moEdeSAjAXpmWsAgmEnJPC8sBZAqoMMIpEYs7GlEOsZ4j(TJhQO04r28mLMc5OjEai(JubqtzW4bWxhy8KHByA2Wn425NrRT3M20T6ZhrPK5XRJTA8(mRZzAcFfMczDm(IM4jdEmx8suJ4cgYrt8zQkqjBNpNVAMiuYxaptxGIot3Q9JHONPlq)zixbDgcXaaqw6ZctHSoME(iggazli98raGiKOgXfKGm4XCj6c0hYrt8KfVwq8epmGb6Xddac7XIhaI)yKTJcJ4pcY8qEihnXFKZSoNPKTqoAIhaIxIbcYGXFLs05INuJMLc5OjEaiEjgiidgpPJOAU4VoJMD(kBf441k(sGBEIF74bk60fauBYznfYrt8aq8hHZ8my8hztJNmQby8gIYt8hXuYCXt32ZXFetjZfVoBEop04pYMgpzudWuihnXdaXdGyNDCgmEa3CEK404jdXbU45MNC4I3NXEPIxR4nbbhCXxTdU4LLXD8aU58iXPXtgIdCXV04n3WgiCXlkKc5OjEai(sGBEiaRMJFPXNznOJbJFBLN2Co4IhcU41moEdeSAjAXpmWsAgmEnJPC8sBZAqoMMIpEYs7GlEOsZ4j(TJhQO04r28mLMc5OjEai(JubqtzW4bWxhy8KHByA2Wn425NrRT3M20T6ZhrPK5XRJTA8(mRZzAkKhYrt8hjpo7fvgmEigPgoEFbeY04H48TPP4LyEplO047QbGmBaIi6I386wnn(QDWLc5Mx3QPjHH9fqitrH4mQuHCZRB10KWW(ciKPsI6msvGHCZRB10KWW(ciKPsI6SjMdKB10T6qU51TAAsyyFbeYujrDE48PKPzOViOuZXTMGCvbQMRAAIBdYXGHC0epAvJFPXlRgnl(vJhPM4nhWIQXZsZdCvZXRv8aTTvB741SXOzHCZRB10KWW(ciKPsI6S02SgKJrVnGmkrktOzJrZqxAZjYOGri386wnnjmSVaczQKOolTnRb5y0BdiJsKYeA2y0m0L2CImkyrFrqzKDEwLtcLmEikecnJjawvN42GCmyihnXtwe4MN4bKmIFPXdYodogm(fjEzC8nZGXRv8z2a6nQg)W5tjtZI3zkpXxD8BhVMXXpLA6wDi386wnnjmSVaczQKOolTnRb5y0BdiJcKDgCmiHIqucCZd6sBorgfad5OjEaZwA8zMGa304LLXD8xdIhTknd94j1vfOAUQPXdjQX3LgpzgAn(LgVAoUvgmKBEDRMMeg2xaHmvsuNL2M1GCm6TbKrbYodogKqrikbU5bDPnNiJcw0xeuQ54wtudIhTknlXTb5yWdQ54wtqUQavZvnnXTb5yWdsqnh3AYj22qSnvyht3QtCBqogmKBEDRMMeg2xaHmvsuNfMsMlKBEDRMMeg2xaHmvsuN9MsGudWqoAI)2ManR04hBbJhsebHbJNQMsJhIrQHJ3xaHmnEioFBA8wdgVWWaGqP625XV04bRMtHCZRB10KWW(ciKPsI6mTnbAwPeu1uAi386wnnjmSVaczQKOolu6wDi386wnnjmSVaczQKOodXdLhPc5HC0e)rYJZErLbJNLMh4IxxGC8AghV51AIFPXBsBRZGCCkKBEDRMIIkLOZraz0m0xeusasebjjmLmxsu4GeGerqs0mdSKbKDGjrHqU51TAQKOopInH51TAc3sv0BdiJQe4Mh0xeuqfLEqcLa38qawnhYnVUvtLe15rSjmVUvt4wQIEBazu0TZDmHAtoRH8qU51TAAYxLdSK1uuGgnd9fbLeGerqsEtjqQbysuiKBEDRMM8v5alznvsuNfMsMd9fbfKicsABVnTPB1PHbABtjjatK4aKicsImvSZDmbvnNu8Kefc5Mx3QPjFvoWswtLe1ziEO8if6lckU5jhoyI6Oa8WP(QCGLSoPBopuceXbU0WaTTPWKeKtoKicss3CEOeiIdCjrHtc5Mx3QPjFvoWswtLe1zDZ5HsGioWH(IGcsebjPBopuceXbUeyjRjNCU5jhUeiJS(vHjk0cad5Mx3QPjFvoWswtLe1ziEO8i125HCZRB10KVkhyjRPsI6mcpMJaz4MSdh6lckFbeQieQTvkkagYnVUvtt(QCGLSMkjQZB7TPnDRg9fbf38KdhmrDuaE4uFvoWswN0nNhkbI4axAyG22uycljiNCireKKU58qjqeh4sIcNeYnVUvtt(QCGLSMkjQZcLUvJEBazuqMQoMqO0TAIcHWYx3QWH(IGsTjN1KUazcTiaxMKOfsqo5NQlqMqlcWLjjShdGhofsebjbXdLhPsIcKtoKicsABVnTPB1jrHtojKBEDRMM8v5alznvsuNPzgyjdi7arFrq5lGqfHqTTsjjjoWnp5WbtuMx3QtJjfN8fvpawAAmP4KaqrNUcULhscJeShGerqs6MZdLarCGljkC4uireKeKRkq1CvttIcKtUeuZXTMGCvbQMRAAIBdYXGNC4ujOMJBnTT3M20T6e3gKJbjNCFvoWswN22BtB6wDAyG22uyc7Xo5GeGerqsB7TPnDRojkeYnVUvtt(QCGLSMkjQZIuMyvginKhYrt8OjEaZ44lbU5j(CU5XCo4IhPCUsw8AghVRYxF8fs8Agh)Wun(cjEnJJ3eCOhpKOg)sJNYc2ykdgFjQXNXdhpsnX7Q81BU49oBwfUqoAINSiW925XdizeVS15IhIJhKDgCmy8ls8Y44BMbJxR4ZSb0BunENP8e)PYYwFw8zMGa304LTAw8udIhTknl(dXdPXdjQX3v8U9KqoAINSOz8iBPC8Y44LTox8La3XlB1S4bKmqpE4kX49whp1qyhCX7nQgVMT04rMcy8uLnNMfVSvZkrnEOHnP2op(vtHCZRB10ujWnpO0nNhkbI4ah6lckPTznihNazNbhdsOieLa38GcGHC0eVeZjZGJgFjWD8Ywnl(XKIrpEF1urGBNhpvzZPzXBny8vZXtkGX7ZSjNJ)0fjE1CCRm4jHCZRB10ujWnpsI68ysXOViOKGUEP2oNCYHerqsctjZLefc5OjEYmwPXd0KIJNkoC8Y445gmEnJJVe4MN4jtszYeIC7zYKXllJ74lXjEKDOA8Zke)sJxxVuBNhYnVUvttLa38ijQZsBZAqog92aYOkbU5HaSAgDPnNiJcS00ScjD9sTDEihnXt6WMuXxIA8fs8AghV51T64Dlvd5Mx3QPPsGBEKe1zz2QOtzpkaMaiaHf9fbfyPPzfs66LA78qoAIhTIeVmo(mtAoEYm0k6XBny8zM0ClX14nbb3YGXVA8WXA8IuoEGv1i7WPqoAINSaGqp(fjEzC8v7Gl(mtAo(Q54jfW49z2KZXBEDLMJNkyaJhyvnYoC8ITUU4LXX7ToEtqWbx8ZkeVSvZIF1qU51TAAQe4MhjrDgyvnYomH3u0xeusqxVuBNto5qIiijixvGQ5QMMOQ5LcfSh8fqOIqO2wPKKeHC0eVe9vAUJ3lod3A8QyVDE8Rg)sJ3CYm4OXlRgnlEG22QT925XRzJrZqpEAfVJvA8MGGdU4xn(mE4ui386wnnvcCZJKOoRzJrZqFrqjbD9sTD(bFbeQieQTvkjjrihnXt6iQMl(RZOzXVD8KfbU5jEzRMfpmKmE1MCwPPqU51TAAQe4MhjrDgAevZrqDgnd9fbfvGDoc1MCwPWe2d(ciuriuBRussIqoAI)kBf443oEYIa38eVSvZIhgsgVAtoR0ui386wnnvcCZJKOotLTcmH3u0xeuub25iuBYzLctyp4lGqfHqTTsjjjc5OjEjwdg)IeFxnhFHeVMXXBqL0C8MGGdo0JxghpDbk4GlEA2WGXl266INeHCZRB10ujWnpsI6mnByq0xeu(ciuriuBRussIqoAIhaX5tjtZqpEzzChVmo(mtAoEseVVacvXluBR04TgmEixvGQ5QMgV1GXZRMXdzlKJM4bW54ZmP54VgepAvAw8wdgFxXBEDLMJhYvfOAUQPXtvZlv8Nk9AXtMtgXtfmGNepln3XViXVA8dtMqChMgVfFMnGX7nQgYrt8a4C8zM0C8w8cddAAnWfpv2IOntPXlmLpEtABDgKJJ)uPxl(lakEKLMTD(jHCZRB10ujWnpsI68W5tjtZqFrq5lGqfHqTTsrrIdQ54wtqUQavZvnnXTb5yWdNQMJBnrniE0Q0Se3gKJbpajIGKGCvbQMRAAcSK1KtoKicssyyqtRbocQSfrBMstIcNeYrt8OvK4LXXZnidgVOq8z2a6nQUDE8aioFkzAg6Xls54bKmIxR4hga4w5jEVPXJudWqU51TAAQe4MhjrDw3CEOeiIdCHC0eVeRbJVAphVmo(CwJpJhoEtJNeX7lGqfHqTTsrpEYurQg)ScXBny8Y44THJxuiERbJFe7E78qU51TAAQe4MhjrDEwb0xeu(ciuriuBRuuKiKhYnVUvtt0TZDmHAtoRO8MsGudq0xeusasebj5nLaPgGjrHqU51TAAIUDUJjuBYzvsuNhtkg9fbfKicssykzUKOa5KdjIGKOzgyjdi7atIcHCZRB10eD7ChtO2KZQKOoBIAryQAEPc5Mx3QPj625oMqTjNvjrD2BohH51TAc3sv0BdiJYxLdSK10qU51TAAIUDUJjuBYzvsuNr4P8BjsjGwLrxTjNvIfbfyPPzfs66LA78dGLMMvinmqBBkjp6b1MCwt6cKj0IaCzyclapCQAtoRPm2CAwsWRKegKGCYvZXTMOgepAvAwIBdYXGNeYnVUvtt0TZDmHAtoRsI68W5tjtZqFrq5lGqfHqTTsrrIdqIiijHHbnTg4iOYweTzknjkCqnh3AcYvfOAUQPjUnihdEasebjb5Qcunx10eyjRpCQeGerqsB7TPnDRojkqo5GLMMvinmqBBkjp2jHCZRB10eD7ChtO2KZQKOopInH51TAc3sv0BdiJIQeiBV0mEOOViO8fqOIqO2wPWeTd5Mx3QPj625oMqTjNvjrDEeBcZRB1eULQO3gqgfvjY5MhtRHgYd5Mx3QPjQsGS9sZ4HIsOkhXW0sC8m6i1q08XvuWgYnVUvttuLaz7LMXdvsuNPM0wotmLnOViOGerqsutAlNjMYMeyjRd5Mx3QPjQsGS9sZ4HkjQZcv5igMwIJNrhPgIMpUIc2qU51TAAIQeiBV0mEOsI68ScOR2KZkXIGsc66LA7CYj)0HbABtjjkqXX0TAYkath9KdNQ2KZAkJnNMLe8kmHbjoib1CCRjQbXJwLML42GCm4jKt(Pdd02MssuGIJPB1KvaMo2bbEOlv5wjak60vWT8atWstZkKeak60vWT8CYb1MCwt6cKj0IaCzyESqU51TAAIQeiBV0mEOsI6SqvoIHPL44z0rQHO5JROGnKBEDRMMOkbY2lnJhQKOotnPTCMykBqFrqbjIGKOM0wotmLnPHbABtjjSWiKBEDRMMOkbY2lnJhQKOoluLJyyAjoEgDKAiA(4kkyd5Mx3QPjQsGS9sZ4HkjQZaTfi6lckireK0ovtqMAYOjrHqU51TAAIQeiBV0mEOsI6mcpLFlrkb0Qm6aTJtWnp5WHc2qEi386wnnrvICU5X0AOOgoFkzAg6lck1CCRjixvGQ5QMM42GCm4bireKKWWGMwdCeuzlI2mLMefoajIGKGCvbQMRAAcSK1h8fqOIqO2wPOq7dGLMgtkonmqBBkjr7qU51TAAIQe5CZJP1qLe15HZNsMMH(IGsnh3AcYvfOAUQPjUnihdEasebjb5Qcunx10eyjRpajIGKegg00AGJGkBr0MP0KOWb1CCRjNyBdX2uHDmDRoXTb5yWdGLMgtkonmqBBkjHnKBEDRMMOkro38yAnujrDgAevZrqDgnd9fbfvGDoc1MCwPjOrunhb1z0mycY0Dyqc1MCwPHCZRB10evjY5MhtRHkjQZcv5igMwIJNrhPgIMpUIc2qU51TAAIQe5CZJP1qLe1znBmAgH3u0xeudJmmnZGC8HtPcSZrO2KZknPzJrZi8MctyCsi386wnnrvICU5X0AOsI6SqvoIHPL44z0rQHO5JROGnKBEDRMMOkro38yAnujrDEmPy0vBYzLyrqjbD9sTDo5KFQeuZXTMGCvbQMRAAIBdYXGhggOTnLKGIJPB1KvaMo6jhuBYznPlqMqlcWLHjAhYnVUvttuLiNBEmTgQKOoluLJyyAjoEgDKAiA(4kkyd5Mx3QPjQsKZnpMwdvsuNhtkgD1MCwjweuQ54wtqUQavZvnnXTb5yWdqIiijixvGQ5QMMefoC6Pdd02MssusKtoiWdDPk3kbqrNUcULhycwAAmP4KaqrNUcULhYkathJeNCqTjN1KUazcTiaxgMODihnXdGVAw8KzO14pepPaIE8Y449whViLJhyvnYoC8Afp1KMJNuaJ3NztotrpEZ5kzBNhVinETIhIvLN4hgzyAw8JjfhYnVUvttuLiNBEmTgQKOodSQgzhMWBk6lckireKeKRkq1CvttIchGerqscddAAnWrqLTiAZuAcSK1h8fqOIqO2wPKKeHCZRB10evjY5MhtRHkjQZqJOAocQZOzOViOofsebjPBopuceXbUKOWHthBbjyP5wtgiinTnmpfwjbAhNWNztotbaFMn5mLazmVUvBUtiRd7ZSjNj0fiFYjHCZRB10evjY5MhtRHkjQZaRQr2Hj8MIUAtoRelcQHrgMMzqooKBEDRMMOkro38yAnujrDwOkhXW0sC8m6i1q08XvuWgYnVUvttuLiNBEmTgQKOoRzJrZi8MI(IGAyKHPzgKJpC6PsBZAqoojszcnBmAgkyC4ujajIGK22BtB6wDsuGCYnYopRYjzRdKaXX0SHBWTZtCBqog8KtiNCQa7CeQn5SstA2y0mcVPWe2tc5Mx3QPjQsKZnpMwdvsuN1SXOzeEtrFrqnmYW0mdYXhK2M1GCCsKYeA2y0muWEasebj5DSnEJQBNNg286HtLaKicsABVnTPB1jrbYj3i78SkNKToqcehtZgUb3opXTb5yWtc5Mx3QPjQsKZnpMwdvsuNfQYrmmTehpJosnenFCffSHCZRB10evjY5MhtRHkjQZuzRat4nf9fbfvGDoc1MCwPjQSvGj8Mctyd5Mx3QPjQsKZnpMwdvsuNPzddI(IGcsebj5DSnEJQBNNg28Ai386wnnrvICU5X0AOsI6mWQAKDycVPOViOmYopRYjHsgpefcHMXeaRQtCBqog8GeGerqsB7TPnDRojkeYnVUvttuLiNBEmTgQKOotZgge9fbfyPPXKItdd02McZtnVUvNOzddM8fvL086wDAmP4KVOkaWnp5WDYrcU5jhU0W5Cto5qIiijVJTXBuD780WMxXxP5HUvJHhgae2JblaHbmsWaGhfg4RmB6TZP4laUedabpAfEj6KT4JhWmo(fOqnA8i1eVeNUDUJjuBYzvIh)WKje3HbJNwa54nrTaAkdgVpZ6CMMc5KzBZXFuYw8hPnvuqOgLbJ386wD8sCtulctvZlLepfYd5OvGc1Omy8sK4nVUvhVBPknfYXx3svkgq8Te4MhmGy4Hfdi(YTb5yqmP4RFwLN1WxPTznihNazNbhdsOieLa38epQ4bi(AEDRgF1nNhkbI4ahwXWddmG4l3gKJbXKIV(zvEwdFLq866LA784jN84HerqsctjZLefWxZRB147ysXyfd)rXaIVCBqogetk(kT5ez8fS00ScjD9sTDo(AEDRgFL2M1GCm(kTneTbKX3sGBEiaRMXkgE0gdi(YTb5yqmP4lL94lataeGWIVMx3QXxz2Q4RFwLN1WxWstZkK01l125yfdpjWaIVCBqogetk(6Nv5zn8vcXRRxQTZJNCYJhsebjb5Qcunx10evnVuXJkEyJ)q8(ciuriuBR04jz8KaFnVUvJVaRQr2Hj8MIvm8OfmG4l3gKJbXKIV(zvEwdFLq866LA784peVVacvec12knEsgpjWxZRB14RMngndRy4LiyaXxUnihdIjfF9ZQ8Sg(sfyNJqTjNvA8WmEyJ)q8(ciuriuBR04jz8KaFnVUvJVqJOAocQZOzyfd)XWaIVCBqogetk(6Nv5zn8LkWohHAtoR04Hz8Wg)H49fqOIqO2wPXtY4jb(AEDRgFPYwbMWBkwXWdGHbeF52GCmiMu81pRYZA4RVacvec12knEsgpjWxZRB14lnByqSIHhwaIbeF52GCmiMu81pRYZA4RVacvec12knEuXtI4peVAoU1eKRkq1CvttCBqogm(dXFA8Q54wtudIhTknlXTb5yW4pepKicscYvfOAUQPjWswhp5KhpKicssyyqtRbocQSfrBMstIcXFc(AEDRgFhoFkzAgwXWdlSyaXxZRB14RU58qjqeh4WxUnihdIjfRy4HfgyaXxUnihdIjfF9ZQ8Sg(6lGqfHqTTsJhv8KaFnVUvJVZkGvSIVGmIj6umGy4Hfdi(YTb5yqmP4RFwLN1WxjepKicssykzUKOq8hIxcXdjIGKOzgyjdi7atIc4R51TA8LkLOZraz0mSIHhgyaXxUnihdIjfF9ZQ8Sg(cvuA8hIxcXxcCZdby1m(AEDRgFhXMW86wnHBPk(6wQs0gqgFlbU5bRy4pkgq8LBdYXGysXxZRB147i2eMx3QjClvXx3svI2aY4lD7ChtO2KZkwXk(kmSVaczkgqm8WIbeF52GCmiMuSIHhgyaXxUnihdIjfRy4pkgq8LBdYXGysXkgE0gdi(YTb5yqmP4RFwLN1Wx1CCRjixvGQ5QMM42GCmi(AEDRgFhoFkzAgwXWtcmG4l3gKJbXKIVsBorgFHb(AEDRgFL2M1GCm(kTneTbKXxrktOzJrZWkgE0cgq8LBdYXGysXxZRB14R02SgKJXxPnNiJVWIV(zvEwdFnYopRYjHsgpefcHMXeaRQtCBqogeFL2gI2aY4RiLj0SXOzyfdVebdi(YTb5yqmP4R0MtKXxaIVMx3QXxPTznihJVsBdrBaz8fKDgCmiHIqucCZdwXWFmmG4l3gKJbXKIVMx3QXxPTznihJVsBorgFHfF9ZQ8Sg(QMJBnrniE0Q0Se3gKJbJ)q8Q54wtqUQavZvnnXTb5yW4peVeIxnh3AYj22qSnvyht3QtCBqogeFL2gI2aY4li7m4yqcfHOe4MhSIHhaddi(AEDRgFfMsMdF52GCmiMuSIHhwaIbeFnVUvJVEtjqQbi(YTb5yqmPyfdpSWIbeF52GCmiMuSIHhwyGbeFnVUvJVcLUvJVCBqogetkwXWd7rXaIVMx3QXxiEO8if(YTb5yqmPyfR4RVkhyjRPyaXWdlgq8LBdYXGysXx)SkpRHVsiEireKK3ucKAaMefWxZRB14lOrZWkgEyGbeF52GCmiMu81pRYZA4lKicsABVnTPB1PHbABtJNKXdWejI)q8qIiijYuXo3Xeu1CsXtsuaFnVUvJVctjZHvm8hfdi(YTb5yqmP4RFwLN1WxU5jhU4HjQ4pkaJ)q8NgVVkhyjRt6MZdLarCGlnmqBBA8WmEsep5KhpKicss3CEOeiIdCjrH4pbFnVUvJVq8q5rkSIHhTXaIVCBqogetk(6Nv5zn8fsebjPBopuceXbUeyjRJNCYJNBEYHlbYiRF14HjQ4rlaeFnVUvJV6MZdLarCGdRy4jbgq8186wn(cXdLhP2ohF52GCmiMuSIHhTGbeF52GCmiMu81pRYZA4RVacvec12knEuXdq8186wn(IWJ5iqgUj7WHvm8semG4l3gKJbXKIV(zvEwdF5MNC4IhMOI)Oam(dXFA8(QCGLSoPBopuceXbU0WaTTPXdZ4HLeXto5XdjIGK0nNhkbI4axsui(tWxZRB1472EBAt3QXkg(JHbeF52GCmiMu81pRYZA4RAtoRjDbYeAraUC8KmE0cjINCYJ)041fitOfb4YXtY4H9yam(dXFA8qIiijiEO8ivsuiEYjpEireK02EBAt3QtIcXFs8NGVcLUvJVqMQoMqO0TAIcHWYx3QWHVMx3QXxHs3QXkgEammG4l3gKJbXKIV(zvEwdF9fqOIqO2wPXtY4jr8hINBEYHlEyIkEZRB1PXKIt(IQXFiEWstJjfNeak60vWT8epjJhgjyJ)q8qIiijDZ5HsGioWLefI)q8NgpKicscYvfOAUQPjrH4jN84Lq8Q54wtqUQavZvnnXTb5yW4pj(dXFA8siE1CCRPT920MUvN42GCmy8KtE8(QCGLSoTT3M20T60WaTTPXdZ4H9yXFs8hIxcXdjIGK22BtB6wDsuaFnVUvJV0mdSKbKDGyfdpSaedi(AEDRgFfPmXQmqk(YTb5yqmPyfR4lvjY5MhtRHIbedpSyaXxUnihdIjfF9ZQ8Sg(QMJBnb5Qcunx10e3gKJbJ)q8qIiijHHbnTg4iOYweTzknjke)H4HerqsqUQavZvnnbwY64peVVacvec12knEuXJ2XFiEWstJjfNggOTnnEsgpAJVMx3QX3HZNsMMHvm8Wadi(YTb5yqmP4RFwLN1Wx1CCRjixvGQ5QMM42GCmy8hIhsebjb5Qcunx10eyjRJ)q8qIiijHHbnTg4iOYweTzknjke)H4vZXTMCITneBtf2X0T6e3gKJbJ)q8GLMgtkonmqBBA8KmEyXxZRB147W5tjtZWkg(JIbeF52GCmiMu81pRYZA4lvGDoc1MCwPjOrunhb1z0S4Hz8GmDhgKqTjNvk(AEDRgFHgr1CeuNrZWkgE0gdi(YTb5yqmP4lsnenFCfdpS4R51TA8vOkhXW0sC8mwXWtcmG4l3gKJbXKIV(zvEwdFhgzyAMb544pe)PXtfyNJqTjNvAsZgJMr4nnEygpmI)e8186wn(QzJrZi8MIvm8OfmG4l3gKJbXKIVi1q08Xvm8WIVMx3QXxHQCedtlXXZyfdVebdi(YTb5yqmP4RFwLN1WxjeVUEP2opEYjp(tJxcXRMJBnb5Qcunx10e3gKJbJ)q8dd02MgpjJhuCmDRoEYA8amD04pj(dXR2KZAsxGmHweGlhpmJhTXxZRB147ysXyfd)XWaIVCBqogetk(IudrZhxXWdl(AEDRgFfQYrmmTehpJvm8ayyaXxUnihdIjfF9ZQ8Sg(QMJBnb5Qcunx10e3gKJbJ)q8qIiijixvGQ5QMMefI)q8Ng)PXpmqBBA8Kev8sK4pj(dXlWdDPk3kbqrNUcULN4Hz8GLMgtkojau0PRGB5jEYA8amDmse)jXFiE1MCwt6cKj0IaC54Hz8On(AEDRgFhtkgRy4HfGyaXxUnihdIjfF9ZQ8Sg(cjIGKGCvbQMRAAsui(dXdjIGKegg00AGJGkBr0MP0eyjRJ)q8(ciuriuBR04jz8KaFnVUvJVaRQr2Hj8MIvm8Wclgq8LBdYXGysXx)SkpRHVNgpKicss3CEOeiIdCjrH4pe)PXp2csWsZTMmqqAA74Hz8NgpSXlz8aTJt4ZSjNPXdaX7ZSjNPeiJ51TAZf)jXtwJFyFMn5mHUa54pj(tWxZRB14l0iQMJG6mAgwXWdlmWaIVCBqogetk(6Nv5zn8DyKHPzgKJXxZRB14lWQAKDycVPyfdpShfdi(YTb5yqmP4lsnenFCfdpS4R51TA8vOkhXW0sC8mwXWdlAJbeF52GCmiMu81pRYZA47WidtZmihh)H4pn(tJxABwdYXjrktOzJrZIhv8Wi(dXFA8siEireK02EBAt3QtIcXto5XBKDEwLtYwhibIJPzd3GBNN42GCmy8Ne)jXto5XtfyNJqTjNvAsZgJMr4nnEygpSXFc(AEDRgF1SXOzeEtXkgEyjbgq8LBdYXGysXx)SkpRHVdJmmnZGCC8hIxABwdYXjrktOzJrZIhv8Wg)H4HerqsEhBJ3O625PHnVg)H4pnEjepKicsABVnTPB1jrH4jN84nYopRYjzRdKaXX0SHBWTZtCBqogm(tWxZRB14RMngnJWBkwXWdlAbdi(YTb5yqmP4lsnenFCfdpS4R51TA8vOkhXW0sC8mwXWdRebdi(YTb5yqmP4RFwLN1WxQa7CeQn5SstuzRat4nnEygpS4R51TA8LkBfycVPyfdpShddi(YTb5yqmP4RFwLN1WxireKK3X24nQUDEAyZR4R51TA8LMnmiwXWdlaggq8LBdYXGysXx)SkpRHVgzNNv5KqjJhIcHqZycGv1jUnihdg)H4Lq8qIiiPT920MUvNefWxZRB14lWQAKDycVPyfdpmaigq8LBdYXGysXx)SkpRHVGLMgtkonmqBBA8Wm(tJ386wDIMnmyYxunEjJ386wDAmP4KVOA8aq8CZtoCXFs8hjINBEYHlnCo3Xto5XdjIGK8o2gVr1TZtdBEfFnVUvJV0SHbXkwXxQsGS9sZ4HIbedpSyaXxUnihdIjfFrQHO5JRy4HfFnVUvJVcv5igMwIJNXkgEyGbeF52GCmiMu81pRYZA4lKicsIAsB5mXu2Kalzn(AEDRgFPM0wotmLnyfd)rXaIVCBqogetk(IudrZhxXWdl(AEDRgFfQYrmmTehpJvm8Ongq8LBdYXGysXx)SkpRHVsiED9sTDE8KtE8Ng)WaTTPXtsuXdkoMUvhpznEaMoA8Ne)H4pnE1MCwtzS50SKGxJhMXddse)H4Lq8Q54wtudIhTknlXTb5yW4pjEYjp(tJFyG2204jjQ4bfht3QJNSgpathl(dXlWdDPk3kbqrNUcULN4Hz8GLMMvijau0PRGB5j(tI)q8Qn5SM0fitOfb4YXdZ4pg(AEDRgFNvaRy4jbgq8LBdYXGysXxKAiA(4kgEyXxZRB14RqvoIHPL44zSIHhTGbeF52GCmiMu81pRYZA4lKicsIAsB5mXu2KggOTnnEsgpSWaFnVUvJVutAlNjMYgSIHxIGbeF52GCmiMu8fPgIMpUIHhw8186wn(kuLJyyAjoEgRy4pggq8LBdYXGysXx)SkpRHVqIiiPDQMGm1KrtIc4R51TA8fOTaXkgEammG4lq74eCZtoC4lS4R51TA8fHNYVLiLaAvgF52GCmiMuSIv8LUDUJjuBYzfdigEyXaIVCBqogetk(6Nv5zn8vcXdjIGK8MsGudWKOa(AEDRgF9MsGudqSIHhgyaXxUnihdIjfF9ZQ8Sg(cjIGKeMsMljkep5KhpKicsIMzGLmGSdmjkGVMx3QX3XKIXkg(JIbeFnVUvJVMOweMQMxk8LBdYXGysXkgE0gdi(YTb5yqmP4R51TA81BohH51TAc3sv81TuLOnGm(6RYbwYAkwXWtcmG4l3gKJbXKIV(zvEwdFblnnRqsxVuBNh)H4blnnRqAyG2204jz8hn(dXR2KZAsxGmHweGlhpmJhwag)H4pnE1MCwtzS50SKGxJNKXddsep5KhVAoU1e1G4rRsZsCBqogm(tWxZRB14lcpLFlrkb0QmwXWJwWaIVCBqogetk(6Nv5zn81xaHkcHABLgpQ4jr8hIhsebjjmmOP1ahbv2IOntPjrH4peVAoU1eKRkq1CvttCBqogm(dXdjIGKGCvbQMRAAcSK1XFi(tJxcXdjIGK22BtB6wDsuiEYjpEWstZkKggOTnnEsg)XI)e8186wn(oC(uY0mSIHxIGbeF52GCmiMu81pRYZA4RVacvec12knEygpAJVMx3QX3rSjmVUvt4wQIVULQeTbKXxQsGS9sZ4HIvm8hddi(YTb5yqmP4R51TA8DeBcZRB1eULQ4RBPkrBaz8LQe5CZJP1qXkwXk(AIAwn47DbEKXkwXya]] )
end