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
    if not PTR then spec:RegisterTalents( {
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
    else
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
            incarnation_king_of_the_jungle = 21704, -- 102543
    
            scent_of_blood = 21714, -- 285564
            brutal_slash = 21711, -- 202028
            primal_wrath = 22370, -- 285381
    
            moment_of_clarity = 21646, -- 236068
            bloodtalons = 21649, -- 155672
            feral_frenzy = 21653, -- 274837
        } )
    end


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
        heart_of_the_wild = PTR and 3053 or nil, -- 236019
        king_of_the_jungle = 602, -- 203052
        leader_of_the_pack = PTR and 3751 or nil, -- 202626
        malornes_swiftness = 601, -- 236012
        protector_of_the_grove = 847, -- 209730
        rip_and_tear = 620, -- 203242
        savage_momentum = 820, -- 205673
        thorns = 201, -- 236696
        tooth_and_claw = not PTR and 3053 or nil, -- 236019
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


    local tf_spells = { rake = true, rip = true, thrash = true, moonfire_cat = true, primal_wrath = true }
    local bt_spells = { rake = true, rip = true, thrash = true, primal_wrath = true }
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

        elseif spellID == 1079 or spellID == 285381 then
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
            ready = function () return active_enemies > 2 and 0 or ( 2.5 - charges_fractional ) * recharge end, -- Use this for timing purposes.
            -- usable = function () return active_enemies > 2 or charges_fractional > 2.5 end,
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
            
            usable = function () return buff.apex_predator.up or combo_points.current > 0 end,
            handler = function ()
                if not PTR and ( target.health_pct < 25 or talent.sabertooth.enabled ) and debuff.rip.up then
                    debuff.rip.expires = query_time + min( debuff.rip.remains + debuff.rip.duration, debuff.rip.duration * 1.3 )
                elseif PTR and talent.sabertooth.enabled and debuff.rip.up then
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

                spend( combo_points.current, "combo_points" )
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
            
            spend = function () return ( PTR and 25 or 30 ) * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",
            
            startsCombat = false,
            texture = 236167,
            
            talent = "savage_roar",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end

                local cost = min( 5, combo_points.current )
                spend( cost, "combo_points" )
                if PTR and buff.savage_roar.down then energy.regen = energy.regen * 1.1 end
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

                if pvptalent.savage_momentum.enabled then
                    gainChargeTime( "tigers_fury", 10 )
                    gainChargeTime( "survival_instincts", 10 )
                    gainChargeTime( "stampeding_roar", 10 )
                end
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

            pvptalent = "thorns",
            
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

                applyBuff( "scent_of_blood" )
                buff.scent_of_blood.v1 = -3 * active_enemies

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


    spec:RegisterPack( "Feral", 20181219.1535, [[d4KjebqievTiHeIhHi5scju2Kq8jHemkviNsi1QqujVcrzwqLUfub7sWVufnmOIoMkyzis9mHKMgIkUgi02ab5BiI04Gk05qevRdruENqcP5HiCpqAFQqDqQqYcHQ8qqaMiiGUiIkvTrQq8rHeQojvi1kPsntevk3erLkTtq0preHHccQLcc0tvPPQkCvevQ4Rcjk7fYFryWahMYIb1JPQjRQUmQndLpRIgTqDALwnIi61ujnBIUTQ0Uv8BrdNGJlKOA5s9CKMoPRtOTtL47urJNkuNhQQ1lKiZNky)sgDa9aD)MYiijnopGJhi9bsE4aeJkejn5GUk(cm6kyExTtgDh7LrxhHBtIUcg(Y0(OhOlnfBpJUXQkqjzpFEUASiCWNVpP7RO00nhFBy6t6(6Fclt4NWygo8zxEk0j2kz6tiCZqqB)0NqyiibeylUFchHBtgO7RhDHfxP6Ohem6(nLrqsACEahpq6dK8Wbig1Ocrie6sfypcYd4mQOB8()8GGr3pt9OlPkGJWTjlaeylU)YnPkqSQcus2ZNNRglch857t6(kknDZX3gM(KUV(NWYe(jmMHdF2LNcDITsM(ec3me02p9jegcsab2I7NWr42Kb6(6l3KQaqGSNFH5Uahi54wasJZd4ybWHcCaIKSOIZYD5Mufaci2MtMsYk3KQa4qbCu)p)lW1vrPSa4z04q5MufahkGJ6)5FbWRfvtwGR0OXpVoxbUaAwGuGhUlWof4vuQloOwFYAOCtQcGdfaclnp)laeGPfWrY(TagMYDbGWD6uwa6oEUaq4oDklG275j30cabyAbCKSFdLBsvaCOaqqwAoM)f4XEYDuGwahrSXVa8W9j(fWhZExlGMfWeeK4xGCK4xaNX8uGh7j3rbAbCeXg)cS0cyYMTp(fquiuUjvbWHcKc8WnXphUalTaX28L8Va7OCpMuIFbGXVaAmxa7)ZjkAbA(nDH)fqJzkxaxSEnyjtdfOaKeJe)caNAm3fyNcaNuAbW2ZyLgqxHoXwjJUKQaoc3MSaqGT4(l3KQaXQkqjzpFEUASiCWNVpP7RO00nhFBy6t6(6Fclt4NWygo8zxEk0j2kz6tiCZqqB)0NqyiibeylUFchHBtgO7RVCtQcabYE(fM7cCGKJBbinopGJfahkWbisYIkol3LBsvaiGyBozkjRCtQcGdfWr9)8VaxxfLYcGNrJdLBsvaCOaoQ)N)faVwunzbUsJg)86Cf4cOzbsbE4Ua7uGxrPU4GA9jRHYnPkaouaiS088VaqaMwahj73cyyk3fac3PtzbO745caH70PSaAVNNCtlaeGPfWrY(nuUjvbWHcabzP5y(xGh7j3rbAbCeXg)cWd3N4xaFm7DTaAwatqqIFbYrIFbCgZtbESNChfOfWreB8lWslGjB2(4xarHq5MufahkqkWd3e)C4cS0ceBZxY)cSJY9ysj(fag)cOXCbS)pNOOfO530f(xanMPCbCX61GLmnuGcqsms8laCQXCxGDkaCsPfaBpJvAOCxUjvbi37y2lQ8VaWmw2Cb85lSPfaMp3HgkGJY7zbLwGjhCi26xmrzbmVU5qlqos8dLBZRBo0GqZ(8f2uOysJ6A5286Mdni0SpFHnLmOpXY8xUnVU5qdcn7Zxytjd6tt88Lh10nNYT51nhAqOzF(cBkzqF28zNo1yCxmOQj5rdWYm)QjZHg4XGL8VCtQc4O1cS0c4mBnUaRwaSSlGjFtQwa2fUXphUaAwGxBh12PaACB04YT51nhAqOzF(cBkzqF6I1RblzCh7LHkszcnUnAmUUysrgkol3Mx3CObHM95lSPKb9PlwVgSKXDSxgQiLj042OX46IjfzOKg3fdQfL4Evo4CLFcmjtJBE(7Cg4XGL8VCtQcqsiWd3f4HJuGLwGpln85FbwSc4KlWW8VaAwGyR)EJQfO5ZoDQXfqAk3fiNcStb0yUaDQMU5uUnVU5qdcn7Zxytjd6txSEnyjJ7yVm0pln85pHIrKc8WnUUysrgkol3KQapIxAbInbbEOfWzmpf4AWCRzQX4wa8Kz(vtMdTaWIAbMula5MJUalTaQj5r5F5286Mdni0SpFHnLmOpDX61GLmUJ9Yq)S0WN)ekgrkWd346IjfzOhWDXGQMKhnqnyU1m14apgSK)rutYJgGLz(vtMdnWJbl5FeYRMKhnifhRj2HkSTPBobEmyj)l3Mx3CObHM95lSPKb9PqNoLLBZRBo0GqZ(8f2uYG(0Bkbw2VLBsvG7yc04ulqB7VaWIyy8Vau1uAbGzSS5c4ZxytlamFUdTa28lGqZ4GqQ6oNfyPf4Ndhk3Mx3CObHM95lSPKb9jDmbACQeu1uA5286Mdni0SpFHnLmOpfsDZPCBEDZHgeA2NVWMsg0NWCt521YD5MufGCVJzVOY)cWUWn(fq3xUaAmxaZRzxGLwaZfBLgSKdLBZRBouOuxfLscyJgJ7IbL8WIyybHoDkdIcripSigwGgB)05ll)brHYT51nhkzqF2IdH51nhc5svCh7LHMc8WnUlgu4KsJq(uGhUj(5WLBZRBouYG(SfhcZRBoeYLQ4o2ldLUZPKjuRpzTCxUnVU5qd(mL)05qH(nAmUlguYdlIHf8MsGL9BquOCBEDZHg8zk)PZHsg0NcD6uI7IbfwedlSJ36X0nNqZV2ousGZaeJalIHfijfNtjtqvt6k3brHYT51nhAWNP8NohkzqFcZnLBxXDXGYd3N4Fm0OIZih5Zu(tNtq3tUPeyIn(HMFTDOhdrhCawedlO7j3ucmXg)GOq0LBZRBo0Gpt5pDouYG(u3tUPeyIn(4Uyq5H7t8dFgB9REmuieoJalIHf09KBkbMyJF4NoNYT51nhAWNP8NohkzqFcZnLBx35SCBEDZHg8zk)PZHsg0NyCBscSMNOe(4Uyq95lCsiK7OuO4SCBEDZHg8zk)PZHsg0N74TEmDZb3fdkpCFI)XqJkoJCKpt5pDobDp5MsGj24hA(12HE8bi6GdWIyybDp5MsGj24hefIUCBEDZHg8zk)PZHsg0NcPU5G7yVmuytvjtiK6MdrIryNRCv8XDXGQwFYAq3xMqtI)YKacbrhC4iDFzcnj(ltId4ioJCeSigwaMBk3UgefCWbyrmSWoERht3CcIcrhD5286Mdn4Zu(tNdLmOpPX2pD(YYpUlguF(cNec5okLeqmcpCFI)XqnVU5eAZvo4tQg5NAOnx5GWROuxb5YnjiD4qeyrmSGUNCtjWeB8dIcrocwedlalZ8RMmhAquWbhiVAsE0aSmZVAYCObEmyj)JoYrKxnjpAyhV1JPBobEmyj)DWbFMYF6Cc74TEmDZj08RTd94d4y0ripSigwyhV1JPBobrHYT51nhAWNP8NohkzqFkszIv5xA5UCtQcqQc8iMlqkWd3f4KhUnPe)cGLsz6SaAmxazEU(cKyfqJ5c0mvlqIvanMlGjiXTaWIAbwAbOSG1MY)cKIAbI5Mlaw2fqMNR3KfWlTEv8l3KQaKec8SZzbE4ifW5kLfaMlWNLg(8ValwbCYfyy(xanlqS1FVr1cinL7cCKZ41hxGytqGhAbCUACbOgm3AMACbIuayTaWIAbMSaYn6YnPkajHgZTZLYfWjxaNRuwGuGNc4C14c8WrWTa4NIfWBtbOgglXVaEJQfqJxAbW68TauLnPgxaNRgNIAbGB2CDNZcSAOCBEDZHgsbE4gQUNCtjWeB8XDXG6I1Rbl5WNLg(8NqXisbE4gkol3KQaokPtdFAbsbEkGZvJlqBUY4waFouX3DolavztQXfWMFbYHlaEpkGp26tUahTyfqnjpk)JUCBEDZHgsbE4MmOpBZvg3fdk51176oNo4aSigwqOtNYGOq5MufGCJvAbEnx5cqfBUao5cWZVaAmxGuGhUlquekhLlYJNJIuaNX8uGuSla22uTa9kuGLwaD9UUZz5286MdnKc8WnzqF6I1RblzCh7LHMc8WnXphgxxmPid9NAOxHGUEx35SCtQcGxZMRfif1cKyfqJ5cyEDZPaYLQLBZRBo0qkWd3Kb9PtBvCPShkod4eNhWDXG(tn0RqqxVR7CwUjvbC0yfWjxGyZfUaKBoAClGn)ceBUWtuqlGjiix(xGvla(SwarkxG3mhST5q5MufGKacIBbwSc4Klqos8lqS5cxGC4cG3Jc4JT(KlG511fUaub7TaVzoyBZfqC0vwaNCb82uatqqIFb6vOaoxnUaRwUnVU5qdPapCtg0NVzoyBZeEtXDXGsED9UUZPdoalIHfGLz(vtMdnqvZ7k0dr85lCsiK7OusaXYnPkqu81fEkGxSBE0cOIZoNfy1cS0cysNg(0c4mBnUaV2oQTZoNfqJBJgJBbOzbKSslGjiiXVaRwGyU5q5286MdnKc8WnzqFQXTrJXDXGsED9UUZzeF(cNec5okLeqSCtQc4OMFbwScm5WfiXkGgZfWGtx4cyccs8XTao5cq3xbj(f4g38)jETOAYcCLgn(515kWfqC0vwaiwUnVU5qdPapCtg0NWTOAscQ0OX4Uyq95lCsiK7OusaXiMxxxycE43LPhFOCBEDZHgsbE4MmOpPoxbMWBkUlguF(cNec5okLeqmI511fMGh(Dz6Xhk3Mx3COHuGhUjd6tACZFCxmO(8fojeYDukjGy5MufacYND6uJXTaoJ5Pao5ceBUWfaIfWNVWzbeYDuAbS5xayzMF1K5qlGn)cWRgZnjRCtQceLXfi2CHlW1G5wZuJlGn)cmzbmVUUWfawM5xnzo0cqvZ7AboYL1ka5UosbOc2B0fGDHNcSyfy1c0CuU42mTawbIT(xaVr1YnPkqugxGyZfUawbeA(BA24xaQZfthMslGqN(cyUyR0GLCboYL1kWfcwaSLgVZz0LBZRBo0qkWd3Kb9zZND6uJXDXG6Zx4Kqi3rPqHye1K8ObyzMF1K5qd8yWs(h5i1K8ObQbZTMPgh4XGL8pcSigwawM5xnzo0WpDoo4aSigwqO5VPzJpb15IPdtPbrHOl3KQaoASc4KlapF(xarHceB93BuDNZcab5ZoDQX4warkxGhosb0SanJd8OCxaVPfal73YT51nhAif4HBYG(u3tUPeyIn(LBsvah18lqoEUao5cCYAbI5MlGPfaIfWNVWjHqUJsXTaKKIuTa9kuaB(fWjxaR5cikuaB(fOfNzNZYT51nhAif4HBYG(SxbCxmO(8fojeYDukuiwUl3Mx3COb6oNsMqT(KvOEtjWY(f3fdk5HfXWcEtjWY(nikuUnVU5qd0DoLmHA9jRKb9zBUY4UyqHfXWccD6ugefCWbyrmSan2(PZxw(dIcLBZRBo0aDNtjtOwFYkzqFAIAsyQAExl3Mx3COb6oNsMqT(KvYG(0BsjH51nhc5svCh7LH6Zu(tNdTCBEDZHgO7Ckzc16twjd6tmUt)MIuc4vzCvRpzLyXG(tn0RqqxVR7Cg5NAOxHqZV2ouse1iQ1NSg09Lj0K4V8XhWzKJuRpzneZMuJdcELeKgIo4GAsE0a1G5wZuJd8yWs(hD5286Mdnq35uYeQ1NSsg0NnF2Ptng3fdQpFHtcHChLcfIrGfXWccn)nnB8jOoxmDyknikernjpAawM5xnzo0apgSK)rGfXWcWYm)QjZHg(PZjYrKhwedlSJ36X0nNGOGdo8tn0RqO5xBhkjWXOl3Mx3COb6oNsMqT(KvYG(SfhcZRBoeYLQ4o2ldfBNLgZnf3fdQpFHtcHChLEm5uUnVU5qd0DoLmHA9jRKb9zloeMx3CiKlvXDSxg6jpCBA20YD5286MdnGTZsJ5McvitjrZ0uS9mUyztmSJvOhk3Mx3CObSDwAm3uYG(KAUyNmrNwJ7IbfwedlqnxStMOtRd)05uUnVU5qdy7S0yUPKb9PqMsIMPPy7zCXYMyyhRqpuUnVU5qdy7S0yUPKb9PqVVMKWzBAmUQ1NSsSyqPcSusOwFYkni07RjjC2MgF8Hi)ud9keA(12HscYPCBEDZHgW2zPXCtjd6tHmLenttX2Z4ILnXWowHEOCBEDZHgW2zPXCtjd6tHEFnjHZ20yCvRpzLyXGsfyPKqT(KvAqO3xts4Snn(yOKUCBEDZHgW2zPXCtjd6tHmLenttX2Z4ILnXWowHEOCBEDZHgW2zPXCtjd6ZEfWvT(KvIfdk51176oNo4Wrn)A7qjb0VyB6Md5cNHOgDKJuRpzneZMuJdcE9ysdXiKxnjpAGAWCRzQXbEmyj)J2bhoQ5xBhkjG(fBt3Cix4mGJre4MUuLhL4vuQRGC5(4FQHEfccVIsDfKl3rhrT(K1GUVmHMe)Lpghl3Mx3CObSDwAm3uYG(uitjrZ0uS9mUyztmSJvOhk3Mx3CObSDwAm3uYG(KAUyNmrNwJ7IbfwedlqnxStMOtRdn)A7qjXbsxUnVU5qdy7S0yUPKb9PqMsIMPPy7zCXYMyyhRqpuUnVU5qdy7S0yUPKb95RTV4UyqHfXWcBNdbjP5Kgefk3Mx3CObSDwAm3uYG(eJ70VPiLaEvg3xZXe8W9j(qpuUl3Mx3COHtE420SPqB(StNAmUlgu1K8ObyzMF1K5qd8yWs(hbwedli0830SXNG6CX0HP0GOqeyrmSaSmZVAYCOHF6CI4Zx4Kqi3rPqjNi)udT5khA(12HscYPCBEDZHgo5HBtZMsg0NnF2Ptng3fdQAsE0aSmZVAYCObEmyj)JalIHfGLz(vtMdn8tNteyrmSGqZFtZgFcQZfthMsdIcrutYJgKIJ1e7qf220nNapgSK)r(PgAZvo08RTdLehk3Mx3COHtE420SPKb9jClQMKGknAmUlguQalLeQ1NSsdWTOAscQ0OXh)z628NqT(KvA5286MdnCYd3MMnLmOpfYus0mnfBpJlw2ed7yf6HYT51nhA4KhUnnBkzqFQXTrJj8MI7Ib9OMXAMgBWso6ihrfyPKqT(KvAqJBJgt4n9yshD5286MdnCYd3MMnLmOpfYus0mnfBpJlw2ed7yf6HYT51nhA4KhUnnBkzqFQXTrJj8MI7Ib9i1K8ObQNhLiXiGLz(d8yWs(hbwedlq98OejgbSmZF4NoNOJqfyPKqT(KvAqJBJgt4n94OwUnVU5qdN8WTPztjd6tHmLenttX2Z4ILnXWowHEOCBEDZHgo5HBtZMsg0NuNRat4nf3fdkSigwG65rjsmcyzM)GOq5286MdnCYd3MMnLmOpfYus0mnfBpJlw2ed7yf6HYT51nhA4KhUnnBkzqF2MRmUQ1NSsSyqjVUEx350bhoI8Qj5rdWYm)QjZHg4XGL8psZV2ous8fBt3Cix4me1OJOwFYAq3xMqtI)YhtoLBZRBo0WjpCBA2uYG(uitjrZ0uS9mUyztmSJvOhk3Mx3COHtE420SPKb9zBUY4QwFYkXIbvnjpAawM5xnzo0apgSK)rGfXWcWYm)QjZHgefIC0rn)A7qjbusA0re4MUuLhL4vuQRGC5(4FQH2CLdcVIsDfKl3KlCgWrigDe16twd6(YeAs8x(yYPCtQceLTACbi3C0fisbW7bUfWjxaVnfqKYf4nZbBBUaAwaQ5cxa8EuaFS1Nmf3cysz6CNZcislGMfaMvL7c0mwZ04c0MRC5286MdnCYd3MMnLmOpFZCW2Mj8MI7IbfwedlalZ8RMmhAquicSigwqO5VPzJpb15IPdtPHF6CI4Zx4Kqi3rPKaILBZRBo0WjpCBA2uYG(eUfvtsqLgng3fd6rWIyybDp5MsGj24hefICuB7NGDHhny)pnSZXhDGSxZXe(yRpzko4JT(KPeyT51nhtgn5QzFS1NmHUVC0rxUnVU5qdN8WTPztjd6Z3mhSTzcVP4QwFYkXIbTzSMPXgSKl3Mx3COHtE420SPKb9PqMsIMPPy7zCXYMyyhRqpuUnVU5qdN8WTPztjd6tnUnAmH3uCxmOnJ1mn2GLCKJoYfRxdwYbrktOXTrJHs6ihrEyrmSWoERht3CcIco4GfL4Evo4CLFcmjtJBE(7Cg4XGL8p6ODWbQalLeQ1NSsdACB0ycVPhFi6YT51nhA4KhUnnBkzqFQXTrJj8MI7IbTzSMPXgSKJ4I1Rbl5GiLj042OXqpebwedl4LS1EJQ7CgA28AKJipSigwyhV1JPBobrbhCWIsCVkhCUYpbMKPXnp)Dod8yWs(hD5286MdnCYd3MMnLmOpfYus0mnfBpJlw2ed7yf6HYT51nhA4KhUnnBkzqFsDUcmH3uCxmOubwkjuRpzLgOoxbMWB6Xhk3Mx3COHtE420SPKb9jnU5pUlg0FQH2CLdn)A7qp(iZRBobACZ)GpPkzMx3CcT5kh8jvXbE4(e)OJIXd3N4hA(KhhCawedl4LS1EJQ7CgA28k66c30nheKKgNhWXdK(WHWbsAuHi6606zNtk6gL5OGGq6OHmkojRaf4rmxG9viBTayzxGOaDNtjtOwFYAuOanhLlUn)lanF5cyIA(Ak)lGp2MtMgk3KB7WfiQKScqUZqffeYw5FbmVU5uGOGjQjHPQ5Dnkek3LBh9Rq2k)lajTaMx3CkGCPknuUrxtuJZgDV7lea6kxQsrpq3uGhUrpqqEa9aD5XGL8hHh667v5En01fRxdwYHpln85pHIrKc8WDbGwaCIUMx3CqxDp5MsGj24JueKKg9aD5XGL8hHh667v5En0L8fqxVR7CwahCOaWIyybHoDkdIcOR51nh0TnxzKIGmQOhOlpgSK)i8qxxmPiJU)ud9ke0176oNOR51nh01fRxdwYORlwtm2lJUPapCt8ZHrkcsYb9aD5XGL8hHh6szp6IZaoX5b0186Md660wfD99QCVg6(tn0RqqxVR7CIueKqe9aD5XGL8hHh667v5En0L8fqxVR7CwahCOaWIyybyzMF1K5qdu18UwaOf4qbIuaF(cNec5okTaKOaqeDnVU5GUVzoyBZeEtrkcsie6b6YJbl5pcp013RY9AOl5lGUEx35SarkGpFHtcHChLwasuaiIUMx3CqxnUnAmsrqssrpqxEmyj)r4HU(EvUxdD95lCsiK7O0cqIcaXcePaMxxxycE43LPf44cCaDnVU5GUWTOAscQ0OXifbjoIEGU8yWs(JWdD99QCVg66Zx4Kqi3rPfGefaIfisbmVUUWe8WVltlWXf4a6AEDZbDPoxbMWBksrqsYrpqxEmyj)r4HU(EvUxdD95lCsiK7O0cqIcar0186Md6sJB(JueKhWj6b6YJbl5pcp013RY9AORpFHtcHChLwaOfaIfisbutYJgGLz(vtMdnWJbl5FbIuGJkGAsE0a1G5wZuJd8yWs(xGifawedlalZ8RMmhA4NoNc4Gdfawedli0830SXNG6CX0HP0GOqbIgDnVU5GUnF2PtngPiipCa9aDnVU5GU6EYnLatSXhD5XGL8hHhsrqEG0OhOlpgSK)i8qxFVk3RHU(8fojeYDuAbGwaiIUMx3Cq3Efqksr3pJzIsf9ab5b0d0LhdwYFeEORVxL71qxYxayrmSGqNoLbrHcePaKVaWIyybAS9tNVS8hefqxZRBoOl1vrPKa2OXifbjPrpqxEmyj)r4HU(EvUxdDHtkTarka5lqkWd3e)Cy0186Md62IdH51nhc5sv0vUuLySxgDtbE4gPiiJk6b6YJbl5pcp0186Md62IdH51nhc5sv0vUuLySxgDP7Ckzc16twrksrxHM95lSPOhiipGEGU8yWs(JWdPiijn6b6YJbl5pcpKIGmQOhOlpgSK)i8qkcsYb9aD5XGL8hHh667v5En0vnjpAawM5xnzo0apgSK)OR51nh0T5ZoDQXifbjerpqxEmyj)r4HUUysrgDXj6AEDZbDDX61GLm66I1eJ9YORiLj042OXifbjec9aD5XGL8hHh6AEDZbDDX61GLm66Ijfz0L0ORVxL71qxlkX9QCW5k)eysMg38835mWJbl5p66I1eJ9YORiLj042OXifbjjf9aD5XGL8hHh66Ijfz0fNOR51nh01fRxdwYORlwtm2lJUFwA4ZFcfJif4HBKIGehrpqxEmyj)r4HUMx3CqxxSEnyjJUUysrgDpGU(EvUxdDvtYJgOgm3AMACGhdwY)cePaQj5rdWYm)QjZHg4XGL8Varka5lGAsE0GuCSMyhQW2MU5e4XGL8hDDXAIXEz09ZsdF(tOyePapCJueKKC0d0186Md6k0Ptj6YJbl5pcpKIG8aorpqxZRBoOR3ucSSFrxEmyj)r4HueKhoGEGU8yWs(JWdPiipqA0d0186Md6kK6Md6YJbl5pcpKIG8qurpqxZRBoOlm3uUDfD5XGL8hHhsrk6EYd3MMnf9ab5b0d0LhdwYFeEORVxL71qx1K8ObyzMF1K5qd8yWs(xGifawedli0830SXNG6CX0HP0GOqbIuayrmSaSmZVAYCOHF6CkqKc4Zx4Kqi3rPfaAbiNcePa)udT5khA(12HwasuaYbDnVU5GUnF2PtngPiijn6b6YJbl5pcp013RY9AORAsE0aSmZVAYCObEmyj)lqKcalIHfGLz(vtMdn8tNtbIuayrmSGqZFtZgFcQZfthMsdIcfisbutYJgKIJ1e7qf220nNapgSK)fisb(PgAZvo08RTdTaKOahqxZRBoOBZND6uJrkcYOIEGU8yWs(JWdD99QCVg6sfyPKqT(KvAaUfvtsqLgnUahxGpt3M)eQ1NSsrxZRBoOlClQMKGknAmsrqsoOhOlpgSK)i8qxSSjg2XkcYdOR51nh0vitjrZ0uS9msrqcr0d0LhdwYFeEORVxL71q3JkqZyntJnyjxGOlqKcCubOcSusOwFYknOXTrJj8MwGJlaPlq0OR51nh0vJBJgt4nfPiiHqOhOlpgSK)i8qxSSjg2XkcYdOR51nh0vitjrZ0uS9msrqssrpqxEmyj)r4HU(EvUxdDpQaQj5rduppkrIralZ8h4XGL8VarkaSigwG65rjsmcyzM)WpDofi6cePaubwkjuRpzLg042OXeEtlWXfiQOR51nh0vJBJgt4nfPiiXr0d0LhdwYFeEOlw2ed7yfb5b0186Md6kKPKOzAk2EgPiij5OhOlpgSK)i8qxFVk3RHUWIyybQNhLiXiGLz(dIcOR51nh0L6CfycVPifb5bCIEGU8yWs(JWdDXYMyyhRiipGUMx3CqxHmLenttX2Zifb5HdOhOlpgSK)i8qxFVk3RHUKVa66DDNZc4Gdf4Ocq(cOMKhnalZ8RMmhAGhdwY)cePan)A7qlajkWxSnDZPaKRcGZqulq0fisbuRpznO7ltOjXF5cCCbih0186Md62MRmsrqEG0OhOlpgSK)i8qxSSjg2XkcYdOR51nh0vitjrZ0uS9msrqEiQOhOlpgSK)i8qxFVk3RHUQj5rdWYm)QjZHg4XGL8VarkaSigwawM5xnzo0GOqbIuGJkWrfO5xBhAbib0cqslq0fisbe4MUuLhL4vuQRGC5UahxGFQH2CLdcVIsDfKl3fGCvaCgWriwGOlqKcOwFYAq3xMqtI)Yf44cqoOR51nh0TnxzKIG8a5GEGU8yWs(JWdD99QCVg6clIHfGLz(vtMdnikuGifawedli0830SXNG6CX0HP0WpDofisb85lCsiK7O0cqIcar0186Md6(M5GTnt4nfPiipar0d0LhdwYFeEORVxL71q3JkaSigwq3tUPeyIn(brHcePahvG22pb7cpAW(FAyNcCCboQahkazf41CmHp26tMwaCOa(yRpzkbwBEDZXKfi6cqUkqZ(yRpzcDF5ceDbIgDnVU5GUWTOAscQ0OXifb5bie6b6YJbl5pcp013RY9AOBZyntJnyjJUMx3Cq33mhSTzcVPifb5bsk6b6YJbl5pcp0flBIHDSIG8a6AEDZbDfYus0mnfBpJueKhWr0d0LhdwYFeEORVxL71q3MXAMgBWsUarkWrf4Oc4I1Rbl5GiLj042OXfaAbiDbIuGJka5laSigwyhV1JPBobrHc4GdfWIsCVkhCUYpbMKPXnp)Dod8yWs(xGOlq0fWbhkavGLsc16twPbnUnAmH30cCCbouGOrxZRBoORg3gnMWBksrqEGKJEGU8yWs(JWdD99QCVg62mwZ0ydwYfisbCX61GLCqKYeACB04caTahkqKcalIHf8s2AVr1DodnBETarkWrfG8fawedlSJ36X0nNGOqbCWHcyrjUxLdox5NatY04MN)oNbEmyj)lq0OR51nh0vJBJgt4nfPiijnorpqxEmyj)r4HUyztmSJveKhqxZRBoORqMsIMPPy7zKIGK0hqpqxEmyj)r4HU(EvUxdDPcSusOwFYknqDUcmH30cCCboGUMx3CqxQZvGj8MIueKKM0OhOlpgSK)i8qxFVk3RHU)udT5khA(12HwGJlWrfW86MtGg38p4tQwaYkG51nNqBUYbFs1cGdfGhUpXVarxGOyfGhUpXp08jpfWbhkaSigwWlzR9gv35m0S5v0186Md6sJB(JuKIUy7S0yUPOhiipGEGU8yWs(JWdDXYMyyhRiipGUMx3CqxHmLenttX2ZifbjPrpqxEmyj)r4HU(EvUxdDHfXWcuZf7Kj606WpDoOR51nh0LAUyNmrNwJueKrf9aD5XGL8hHh6ILnXWowrqEaDnVU5GUczkjAMMITNrkcsYb9aD5XGL8hHh667v5En0LkWsjHA9jR0GqVVMKWzBACboUahkqKc8tn0RqO5xBhAbirbih0186Md6k07RjjC2MgJueKqe9aD5XGL8hHh6ILnXWowrqEaDnVU5GUczkjAMMITNrkcsie6b6YJbl5pcp013RY9AOlvGLsc16twPbHEFnjHZ204cCm0cqA0186Md6k07RjjC2MgJueKKu0d0LhdwYFeEOlw2ed7yfb5b0186Md6kKPKOzAk2EgPiiXr0d0LhdwYFeEORVxL71qxYxaD9UUZzbCWHcCubA(12HwasaTaFX20nNcqUkaodrTarxGif4OcOwFYAiMnPghe8AboUaKgIfisbiFbutYJgOgm3AMACGhdwY)ceDbCWHcCubA(12HwasaTaFX20nNcqUkaod4ybIuabUPlv5rjEfL6kixUlWXf4NAOxHGWROuxb5YDbIUarkGA9jRbDFzcnj(lxGJlaoIUMx3Cq3Efqkcsso6b6YJbl5pcp0flBIHDSIG8a6AEDZbDfYus0mnfBpJueKhWj6b6YJbl5pcp013RY9AOlSigwGAUyNmrNwhA(12HwasuGdKgDnVU5GUuZf7Kj60AKIG8Wb0d0LhdwYFeEOlw2ed7yfb5b0186Md6kKPKOzAk2EgPiipqA0d0LhdwYFeEORVxL71qxyrmSW25qqsAoPbrb0186Md6(A7lsrqEiQOhO7R5ycE4(eF09a6AEDZbDX4o9BksjGxLrxEmyj)r4HuKIU0DoLmHA9jROhiipGEGU8yWs(JWdD99QCVg6s(calIHf8MsGL9BquaDnVU5GUEtjWY(fPiijn6b6YJbl5pcp013RY9AOlSigwqOtNYGOqbCWHcalIHfOX2pD(YYFquaDnVU5GUT5kJueKrf9aDnVU5GUMOMeMQM3v0LhdwYFeEifbj5GEGU8yWs(JWdDnVU5GUEtkjmVU5qixQIUYLQeJ9YORpt5pDouKIGeIOhOlpgSK)i8qxFVk3RHU)ud9ke0176oNfisb(Pg6vi08RTdTaKOarTarkGA9jRbDFzcnj(lxGJlWbCwGif4OcOwFYAiMnPghe8AbirbinelGdoua1K8ObQbZTMPgh4XGL8VarJUMx3CqxmUt)MIuc4vzKIGecHEGU8yWs(JWdD99QCVg66Zx4Kqi3rPfaAbGybIuayrmSGqZFtZgFcQZfthMsdIcfisbutYJgGLz(vtMdnWJbl5FbIuayrmSaSmZVAYCOHF6CkqKcCubiFbGfXWc74TEmDZjikuahCOa)ud9keA(12HwasuaCSarJUMx3Cq3Mp70PgJueKKu0d0LhdwYFeEORVxL71qxF(cNec5okTahxaYbDnVU5GUT4qyEDZHqUufDLlvjg7LrxSDwAm3uKIGehrpqxEmyj)r4HUMx3Cq3wCimVU5qixQIUYLQeJ9YO7jpCBA2uKIu01NP8Nohk6bcYdOhOlpgSK)i8qxFVk3RHUKVaWIyybVPeyz)gefqxZRBoO73OXifbjPrpqxEmyj)r4HU(EvUxdDHfXWc74TEmDZj08RTdTaKOa4maXcePaWIyybssX5uYeu1KUYDquaDnVU5GUcD6uIueKrf9aD5XGL8hHh667v5En0LhUpXVahdTarfNfisboQa(mL)05e09KBkbMyJFO5xBhAboUaqSao4qbGfXWc6EYnLatSXpikuGOrxZRBoOlm3uUDfPiijh0d0LhdwYFeEORVxL71qxE4(e)WNXw)Qf4yOfacHZcePaWIyybDp5MsGj24h(PZbDnVU5GU6EYnLatSXhPiiHi6b6AEDZbDH5MYTR7CIU8yWs(JWdPiiHqOhOlpgSK)i8qxFVk3RHU(8fojeYDuAbGwaCIUMx3CqxmUnjbwZtucFKIGKKIEGU8yWs(JWdD99QCVg6Yd3N4xGJHwGOIZcePahvaFMYF6Cc6EYnLatSXp08RTdTahxGdqSao4qbGfXWc6EYnLatSXpikuGOrxZRBoO7oERht3CqkcsCe9aD5XGL8hHh667v5En0vT(K1GUVmHMe)LlajkaecIfWbhkWrfq3xMqtI)YfGef4aoIZcePahvayrmSam3uUDnikuahCOaWIyyHD8wpMU5eefkq0fiA0vi1nh0f2uvYecPU5qKye25kxfF0186Md6kK6MdsrqsYrpqxEmyj)r4HU(EvUxdD95lCsiK7O0cqIcaXcePa8W9j(f4yOfW86MtOnx5GpPAbIuGFQH2CLdcVIsDfKl3fGefG0HdfisbGfXWc6EYnLatSXpikuGif4OcalIHfGLz(vtMdnikuahCOaKVaQj5rdWYm)QjZHg4XGL8VarxGif4Ocq(cOMKhnSJ36X0nNapgSK)fWbhkGpt5pDoHD8wpMU5eA(12HwGJlWbCSarxGifG8fawedlSJ36X0nNGOa6AEDZbDPX2pD(YYpsrqEaNOhOR51nh0vKYeRYVu0LhdwYFeEifPifPifHaa]] )
end