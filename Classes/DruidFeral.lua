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


    spec:RegisterPack( "Feral", 20181211.1735, [[d4uLdbqiKkTiHeWJqk5scjiBsi(evcAucPoLkKvHuuEfsvZcj6wibTlb)sv0WuH6yQGLHuXZesAAiLY1qcTnqq9nqqghsGZHuKSoKIQ3jKanpKc3dK2hi0bPsOwisQhkKOMiiaxKkbQnIuQ(OqcQtsLqwjvQzsLaUjvcK2ji6NGaAOifXsbb6PQ0uvfUkvceFvirSxO(ledg4WuwmOEmvnzv1LrTzi9zv0OfQtR0Qrks9AQKMnr3wvA3s9BrdNqhxirA5kEoIPt66eSDQqFNkA8uj68ijRxiHMpvW(Lm(a(b((nLXqsNJpqbhOZHdHdqOOsrAdFvQez8v08UANm(22lJV0opMeFfnQKP9XpWxskmEgFJvvKqZF(8C1yb4GpFFs2xbPPB2(Xq1NK91)ewMWpHrnk8Zo(uCs0vYKN0KHHG2(jpPjqqeiGry)i0opMmq2xp(clSs1f1yy89BkJHKohFGcoqNdhchGqrnQ0bcJVer2JH8WXrfFJ3)NBmm((zIhFPvbODEmzbGagH9xUPvbIvvKqZF(8C1yb4GpFFs2xbPPB2(Xq1NK91)ewMWpHrnk8Zo(uCs0vYKN0KHHG2(jpPjqqeiGry)i0opMmq2xF5MwfacG98lmpf4WbklaDo(afuakSahOin)4Jl3LBAvGOCS1NmHMxUPvbOWc4I)F(xGRRcszbO2iXHYnTkafwax8)Z)cq9iOMSaxPrIFEDUICb0SaPi38uGTlWRGuxkuT5K1q5MwfGclanrAE(xGOSPfG2Z5TagQYtbOjt6uwaY2EUa0KjDklGo75jpKceLnTa0EoVHYnTkafwaiilnxY)c8yp5XfskaTlmuvaU55KQc4JzVRfqZcyIIsQkq2sQkGZyUlWJ9KhxiPa0UWqvbwsbm5W2NQciigk30QauybsrU5b5NnxGLuGyR)s(xGTvEAtkPQaWuvanMlG9)zhfSad)MoY)cOXmHlGJ2SgSKjHcuaiWwsvbGtnMNcSDbGtcPaO7zSsc4R4KORKXxAvaANhtwaiGry)LBAvGyvfj08Nppxnwao4Z3NK9vqA6MTFmu9jzF9pHLj8tyuJc)SJpfNeDLm5jnzyiOTFYtAceebcye2pcTZJjdK91xUPvbGayp)cZtboCGYcqNJpqbfGclWbksZp(4YD5MwfikhB9jtO5LBAvakSaU4)N)f46QGuwaQnsCOCtRcqHfWf))8VaupcQjlWvAK4NxNRixanlqkYnpfy7c8ki1LcvBoznuUPvbOWcqtKMN)fikBAbO9CElGHQ8uaAYKoLfGSTNlanzsNYcOZEEYdParztlaTNZBOCtRcqHfacYsZL8Vap2tECHKcq7cdvfGBEoPQa(y27Ab0SaMOOKQcKTKQc4mM7c8yp5XfskaTlmuvGLuatoS9PQacIHYnTkafwGuKBEq(zZfyjfi26VK)fyBLN2KsQkamvfqJ5cy)F2rblWWVPJ8VaAmt4c4OnRblzsOafacSLuva4uJ5PaBxa4Kqka6EgRKq5UCtRc4c2LSxq5FbGz0C4c4ZxytlamFUnjuaxS3ZIkPaD2uySnVOcYcyEDZMuGSLufk3Mx3SjbXH95lSPqrLgX1YT51nBsqCyF(cBk9qFIM5VCBEDZMeeh2NVWMsp0NMW5l3QPB2LBZRB2KG4W(8f2u6H(C4ZjDQXuUOqvtYTgGLz(vtMnjWTbl5F5MwfWfPfyjfWzoACbwTaO5uat(MeTaSJ8qv2Cb0SaV22QTDb04XiXLBZRB2KG4W(8f2u6H(0rBwdwYu22ldvGWiA8yKykD0Kcm0Jl3Mx3SjbXH95lSP0d9PJ2SgSKPSTxgQaHr04XiXu6OjfyO0HYffQff5zvo4CLFeujtIhU)BFg42GL8VCtRcabkYnpf4bTxGLuGplnQ4Fbw0c4KlqZ8VaAwGyB(EJOfy4ZjDQXfqAkpfi7cSDb0yUatQMUzxUnVUztcId7ZxytPh6thTznyjtzBVm0plnQ4pIIIKICZdLoAsbg6XLBAvGhXlPaXMOi3Kc4mM7cCnyE0m1ykla1Ym)QjZMuaybTaDQfWfWfvGLua1KCR8VCBEDZMeeh2NVWMsp0NoAZAWsMY2EzOFwAuXFeffjf5MhkD0Kcm0duUOqvtYTgigmpAMACGBdwY)iQj5wdWYm)QjZMe42GL8pcDvtYTgKcTniBte3X0n7a3gSK)LBZRB2KG4W(8f2u6H(uCsNYYT51nBsqCyF(cBk9qF6nfbnN3YnTkWTnrsCQfyS9xaybuu(xaIAkPaWmAoCb85lSPfaMp3MuaR)fqCykumvD7ZcSKc8ZMdLBZRB2KG4W(8f2u6H(K0MijoveIAkPCBEDZMeeh2NVWMsp0NIPUzxUnVUztcId7ZxytPh6tyEi84A5UCtRc4c2LSxq5Fbyh5HQcO7lxanMlG51CkWskG5OTsdwYHYT51nBcuIRcsjcSrIPCrHsxybu0G4KoLbbXi0fwafnqITF68LL)GGy5286MnHEOphHgX86MnICjkLT9YqtrU5HYffkCsirOBkYnpi)S5YT51nBc9qFocnI51nBe5sukB7LHs2(uYiQnNSwUl3Mx3SjbFMYF6Sjq)gjMYffkDHfqrdEtrqZ5niiwUnVUztc(mL)0ztOh6tXjDkPCrHclGIg22BtB6MDy4xBBcnooqXiWcOObAAH(uYie1KUYtqqSCBEDZMe8zk)PZMqp0NW8q4XvkxuOCZZjvqeAupos0(mL)0zh09KhccQWqvy4xBBcePOdoalGIg09KhccQWqvqq8OYT51nBsWNP8NoBc9qFQ7jpeeuHHkkxuOCZZjvHpJU(vHiui8XrGfqrd6EYdbbvyOk8tND5286Mnj4Zu(tNnHEOpH5HWJRBFwUnVUztc(mL)0ztOh6tuEmjc6WDuKkkxuO(8foreZTvc0Jl3Mx3SjbFMYF6Sj0d952EBAt3SPCrHYnpNubrOr94ir7Zu(tNDq3tEiiOcdvHHFTTjq8afDWbybu0GUN8qqqfgQccIhvUnVUztc(mL)0ztOh6tXu3SPSTxgkSPQKretDZgjrrSZvUkvuUOqvBoznO7lJOjYFzAaHPOdoeTUVmIMi)LPXbk44irdlGIgG5HWJRbbrhCawafnST3M20n7GG4rhvUnVUztc(mL)0ztOh6tsS9tNVS8t5Ic1NVWjIyUTsObfJWnpNubrOMx3SdJ5kh8jrJ8tnmMRCq8vqQROC5Hg0jCicSakAq3tEiiOcdvbbXirdlGIgGLz(vtMnjii6Gd0vnj3AawM5xnz2Ka3gSK)hfjA6QMKBnST3M20n7a3gSK)o4Gpt5pD2HT920MUzhg(12MaXduWrrOlSakAyBVnTPB2bbXYT51nBsWNP8NoBc9qFkqyKv5xs5UCtRcqRc8iMlqkYnpf4KBEmPKQcGMsz6SaAmxazEU(cKOfqJ5cmmrlqIwanMlGjkPSaWcAbwsbiSOnMY)cKcAbI5HlaAofqMNR3KfWlTzvQk30QaqGICV9zbEq7fW5kLfaMlWNLgv8ValAbCYfOz(xanlqSnFVr0cinLNceTZ41hxGytuKBsbCUACbigmpAMACbIuayTaWcAb6SaY9OYnTkaeOgZJZLWfWjxaNRuwGuK7c4C14c8G2PSauLcfWBDbigklPQaEJOfqJxsbqN8TaeLnPgxaNRgNcAbGh2CD7ZcSAOCBEDZMesrU5bQUN8qqqfgQOCrH6OnRbl5WNLgv8hrrrsrU5b6XLBAvaxS0PrfPaPi3fW5QXfymxzklGpBIW72NfGOSj14cy9VazZfG6hfWhBZjxGOx0cOMKBL)hvUnVUztcPi38qp0NJ5kt5IcLU66DD7thCawafnioPtzqqSCtRc4cWkPaVMRCbicdxaNCb4(xanMlqkYnpfikaHJsf42ZrbkGZyUlqkmfaDhIwGzflWskGUEx3(SCBEDZMesrU5HEOpD0M1GLmLT9YqtrU5b5NntPJMuGH(tnmRyqxVRBFwUPvbOEyZ1cKcAbs0cOXCbmVUzxa5s0YT51nBsif5Mh6H(0PTkLe2d94WXhFGYff6p1WSIbD9UU9z5MwfWfHwaNCbInh5c4c4IOSaw)lqS5i3UqTaMOOC5FbwTauXAbeiCbEZSr3HdLBAvaiqiiLfyrlGtUazlPQaXMJCbYMla1pkGp2MtUaMxxh5cqeT3c8MzJUdxaHwxzbCYfWBDbmrrjvfywXc4C14cSA5286MnjKICZd9qF(MzJUdJ4nLYffkD11762No4aSakAawM5xnz2KarnVRqpeXNVWjIyUTsObfl30QarHxh5UaEHz4wlGk0BFwGvlWskGjDAurkGZC04c8ABR22BFwanEmsmLfGKfqYkPaMOOKQcSAbI5HdLBZRB2KqkYnp0d9PgpgjMYffkD11762Nr85lCIiMBReAqXYnTkGlU)fyrlqNnxGeTaAmxadoDKlGjkkPIYc4KlazFfLuvGB8W)NupcQjlWvAK4NxNRixaHwxzbOy5286MnjKICZd9qFcpcQjrisJet5Ic1NVWjIyUTsObfJyEDDKr4MFxMaXdLBZRB2KqkYnp0d9jX5kYiEtPCrH6Zx4erm3wj0GIrmVUoYiCZVltG4HYT51nBsif5Mh6H(Kep8NYffQpFHteXCBLqdkwUPvbGG85Ko1yklGZyUlGtUaXMJCbOyb85lCwaXCBLuaR)fawM5xnz2Kcy9Va8QX8qZl30QarjCbInh5cCnyE0m14cy9VaDwaZRRJCbGLz(vtMnPae18UwGODCTc4ckTxaIO9Eubyh5UalAbwTadhLkSdtkGvGyB(fWBeTCtRceLWfi2CKlGvaXH)MMdvfG4Cr1MjKcioPVaMJ2knyjxGODCTcCHGfaDjXBFEu5286MnjKICZd9qFo85Ko1ykxuO(8foreZTvcukgrnj3AawM5xnz2Ka3gSK)rIwnj3AGyW8OzQXbUnyj)JalGIgGLz(vtMnj8tNTdoalGIgeh(BAouHqCUOAZesqq8OYnTkGlcTao5cW9N)fqqSaX289gr3(Saqq(CsNAmLfqGWf4bTxanlWWui3kpfWBAbqZ5TCBEDZMesrU5HEOp19KhccQWqv5MwfWf3)cKTNlGtUaNSwGyE4cyAbOyb85lCIiMBReklanTarlWSIfW6FbCYfWgUacIfW6FbgHU3(SCBEDZMesrU5HEOpNvKYffQpFHteXCBLaLIL7YT51nBsGS9PKruBozfQ3ue0CEPCrHsxybu0G3ue0CEdcILBZRB2Kaz7tjJO2CYk9qFoMRmLlkuybu0G4KoLbbrhCawafnqITF68LL)GGy5286Mnjq2(uYiQnNSsp0NMGMiMQM31YT51nBsGS9PKruBozLEOp9MuIyEDZgrUeLY2EzO(mL)0ztk3Mx3SjbY2NsgrT5Kv6H(eLN0VPabbEvMs1MtwrwuO)udZkg01762Nr(PgMvmm8RTnHgrnIAZjRbDFzenr(ldXdhhjA1MtwdXSj14GOxPbDOOdoOMKBnqmyE0m14a3gSK)hvUnVUztcKTpLmIAZjR0d95WNt6uJPCrH6Zx4erm3wjqPyeybu0G4WFtZHkeIZfvBMqccIrutYTgGLz(vtMnjWTbl5Feybu0aSmZVAYSjHF6SJenDHfqrdB7TPnDZoii6Gd)udZkgg(12Mqdk4OYT51nBsGS9PKruBozLEOphHgX86MnICjkLT9Yqjkc62ljMhcLlkuF(cNiI52kbI0w5286Mnjq2(uYiQnNSsp0NJqJyEDZgrUeLY2EzOef5KBEmnhs5UCBEDZMeikc62ljMhcuXmLidtsHXZuIMdsZUuHEOCBEDZMeikc62ljMhc9qFsmhTtgzsBOCrHclGIgiMJ2jJmPnHF6Sl3Mx3SjbIIGU9sI5Hqp0NIzkrgMKcJNPenhKMDPc9q5286Mnjque0Txsmpe6H(uC2xtI4CmnMs1MtwrwuOerwkruBozLeeN91KiohtJH4Hi)udZkgg(12MqdARCBEDZMeikc62ljMhc9qFkMPezyskmEMs0CqA2Lk0dLBZRB2Karrq3EjX8qOh6ZzfPuT5KvKffkD11762No4q0d)ABtOb0VWy6Mnn74qupks0QnNSgIztQXbrVcr6qXi0vnj3AGyW8OzQXbUnyj)pYbhIE4xBBcnG(fgt3SPzhhOGiI8qwIYTI8ki1vuU8aXFQHzfdIVcsDfLlphfrT5K1GUVmIMi)LHifuUnVUztcefbD7LeZdHEOpfZuImmjfgptjAoin7sf6HYT51nBsGOiOBVKyEi0d9jXC0ozKjTHYffkSakAGyoANmYK2eg(12MqJd0PCBEDZMeikc62ljMhc9qFkMPezyskmEMs0CqA2Lk0dLBZRB2Karrq3EjX8qOh6ZxBFPCrHclGIg2jBeAAZjjiiwUnVUztcefbD7LeZdHEOpr5j9BkqqGxLP81Cjc38Csf0dL7YT51nBsGOiNCZJP5qGo85Ko1ykxuOQj5wdWYm)QjZMe42GL8pcSakAqC4VP5qfcX5IQntibbXiWcOObyzMF1Kztc)0zhXNVWjIyUTsGsBr(PggZvom8RTnHg0w5286MnjquKtU5X0Ci0d95WNt6uJPCrHQMKBnalZ8RMmBsGBdwY)iWcOObyzMF1Kztc)0zhbwafnio830COcH4Cr1MjKGGye1KCRbPqBdY2eXDmDZoWTbl5FKFQHXCLdd)ABtOXHYT51nBsGOiNCZJP5qOh6t4rqnjcrAKykxuOerwkruBozLeGhb1KiePrIH4Nj7WFe1MtwjLBZRB2Karro5MhtZHqp0NIzkrgMKcJNPenhKMDPc9q5286MnjquKtU5X0Ci0d9PgpgjgXBkLlk0OhgDysSbl5JIenrKLse1MtwjbnEmsmI3uisNJk3Mx3SjbIICYnpMMdHEOpfZuImmjfgptjAoin7sf6HYT51nBsGOiNCZJP5qOh6tnEmsmI3ukxuOrRMKBnq8CRijkcSmZFGBdwY)iWcOObINBfjrrGLz(d)0zFueIilLiQnNSscA8yKyeVPqmQLBZRB2Karro5MhtZHqp0NIzkrgMKcJNPenhKMDPc9q5286MnjquKtU5X0Ci0d9jX5kYiEtPCrHclGIgiEUvKefbwM5piiwUnVUztcef5KBEmnhc9qFkMPezyskmEMs0CqA2Lk0dLBZRB2Karro5MhtZHqp0NJ5ktPAZjRilku6QR31TpDWHOPRAsU1aSmZVAYSjbUnyj)Jm8RTnHgFHX0nBA2XHOEue1Mtwd6(YiAI8xgI0w5286MnjquKtU5X0Ci0d9PyMsKHjPW4zkrZbPzxQqpuUnVUztcef5KBEmnhc9qFoMRmLQnNSISOqvtYTgGLz(vtMnjWTbl5Feybu0aSmZVAYSjbbXirh9WV22eAafcDuerEilr5wrEfK6kkxEG4p1WyUYbXxbPUIYLhA2XbkGIhfrT5K1GUVmIMi)LHiTvUPvbIswnUaUaUOcePau)GYc4KlG36ciq4c8MzJUdxanlaXCKla1pkGp2MtMqzbmPmDU9zbeifqZcaZQYtbggDysCbgZvUCBEDZMeikYj38yAoe6H(8nZgDhgXBkLlkuybu0aSmZVAYSjbbXiWcOObXH)MMdvieNlQ2mHe(PZoIpFHteXCBLqdkwUnVUztcef5KBEmnhc9qFcpcQjrisJet5IcnAybu0GUN8qqqfgQccIrIES9JWoYTgS)Ne2gIrFG(xZLi(yBozcf6JT5KjiOJ51nBtEenByFSnNmIUV8rhvUnVUztcef5KBEmnhc9qF(MzJUdJ4nLs1MtwrwuOdJomj2GLC5286MnjquKtU5X0Ci0d9PyMsKHjPW4zkrZbPzxQqpuUnVUztcef5KBEmnhc9qFQXJrIr8Ms5IcDy0HjXgSKJeD0oAZAWsoiqyenEmsmu6ejA6clGIg22BtB6MDqq0bhSOipRYbNR8JGkzs8W9F7Za3gSK)hDKdoqezPerT5KvsqJhJeJ4nfIhoQCBEDZMeikYj38yAoe6H(uJhJeJ4nLYff6WOdtInyjhXrBwdwYbbcJOXJrIHEicSakAWlzB8gr3(mmS51irtxybu0W2EBAt3SdcIo4Gff5zvo4CLFeujtIhU)BFg42GL8)OYT51nBsGOiNCZJP5qOh6tXmLidtsHXZuIMdsZUuHEOCBEDZMeikYj38yAoe6H(K4CfzeVPuUOqjISuIO2CYkjqCUImI3uiEOCBEDZMeikYj38yAoe6H(Kep8NYff6p1WyUYHHFTTjqmAZRB2bs8W)Gpjk9Mx3SdJ5kh8jrPqU55KQJIcXnpNufg(KBhCawafn4LSnEJOBFgg28k(6ipKnBmK054duWHJPdDc054Ogv81Pn92Ne8nkXfdbH0fbzuyAEbkWJyUa7RyoAbqZPaUqY2NsgrT5Kvxybgokvyh(xas(YfWe081u(xaFS1NmjuUDb2MlquP5fWfKMiikMJY)cyEDZUaUqtqtetvZ7QlmuUl3UOxXCu(xaiubmVUzxa5susOCJVMGgNd(E33Om(kxIsWpW3uKBEWpWqEa)aF52GL8htn(6Nv5zn81rBwdwYHplnQ4pIIIKICZtbGwGJXxZRB24RUN8qqqfgQWkgs6GFGVCBWs(JPgF9ZQ8Sg(s3cOR31TplGdouaybu0G4KoLbbr8186Mn(oMRmwXqgv8d81rtkW47p1WSIbD9UU9j(YTbl5pMA8186Mn(6OnRblz81rBqA7LX3uKBEq(zZyfdjTHFGVCBWs(JPgFjShFpoC8XhWxZRB24RtBv81pRYZA47p1WSIbD9UU9jwXqsr8d8LBdwYFm14RFwLN1Wx6waD9UU9zbCWHcalGIgGLz(vtMnjquZ7AbGwGdfisb85lCIiMBRKcqJcqr8186Mn((MzJUdJ4nfRyiHW4h4l3gSK)yQXx)SkpRHV0Ta66DD7ZcePa(8foreZTvsbOrbOi(AEDZgF14XiXyfdjec)aF52GL8htn(6Nv5zn81NVWjIyUTskankaflqKcyEDDKr4MFxMuaiwGd4R51nB8fEeutIqKgjgRyiPa8d8LBdwYFm14RFwLN1WxF(cNiI52kPa0OauSarkG511rgHB(DzsbGyboGVMx3SXxIZvKr8MIvmK0u4h4l3gSK)yQXx)SkpRHV(8foreZTvsbOrbOi(AEDZgFjXd)XkgYdhJFGVCBWs(JPgF9ZQ8Sg(6Zx4erm3wjfaAbOybIua1KCRbyzMF1KztcCBWs(xGifi6cOMKBnqmyE0m14a3gSK)fisbGfqrdWYm)QjZMe(PZUao4qbGfqrdId)nnhQqioxuTzcjiiwGJWxZRB247WNt6uJXkgYdhWpWxZRB24RUN8qqqfgQWxUnyj)XuJvmKhOd(b(YTbl5pMA81pRYZA4RpFHteXCBLuaOfGI4R51nB8DwrSIv89ZOMGuXpWqEa)aF52GL8htn(6Nv5zn8LUfawafnioPtzqqSarkaDlaSakAGeB)05ll)bbr8186Mn(sCvqkrGnsmwXqsh8d8LBdwYFm14R51nB8DeAeZRB2iYLO4RFwLN1Wx4KqkqKcq3cKICZdYpBgFLlrrA7LX3uKBEWkgYOIFGVCBWs(JPgFnVUzJVJqJyEDZgrUefFLlrrA7LXxY2NsgrT5KvSIv8vCyF(cBk(bgYd4h4l3gSK)yQXkgs6GFGVCBWs(JPgRyiJk(b(YTbl5pMASIHK2WpWxUnyj)XuJV(zvEwdFvtYTgGLz(vtMnjWTbl5p(AEDZgFh(CsNAmwXqsr8d81rtkW47X4l3gSK)yQXxZRB24RJ2SgSKXxhTbPTxgFfimIgpgjgRyiHW4h4l3gSK)yQXxZRB24RJ2SgSKXxhnPaJV0bFD0gK2Ez8vGWiA8yKy81pRYZA4Rff5zvo4CLFeujtIhU)BFg42GL8hRyiHq4h4RJMuGX3JXxUnyj)XuJVMx3SXxhTznyjJVoAdsBVm((zPrf)ruuKuKBEWkgska)aF52GL8htn(AEDZgFD0M1GLm(6Ojfy89a(6OniT9Y47NLgv8hrrrsrU5bF9ZQ8Sg(QMKBnqmyE0m14a3gSK)fisbutYTgGLz(vtMnjWTbl5FbIua6wa1KCRbPqBdY2eXDmDZoWTbl5pwXqstHFGVMx3SXxXjDkXxUnyj)XuJvmKhog)aFnVUzJVEtrqZ5fF52GL8htnwXqE4a(b(YTbl5pMASIH8aDWpWxZRB24RyQB24l3gSK)yQXkgYdrf)aFnVUzJVW8q4Xv8LBdwYFm1yfR4Rpt5pD2e8dmKhWpWxUnyj)XuJV(zvEwdFPBbGfqrdEtrqZ5niiIVMx3SX3VrIXkgs6GFGVCBWs(JPgF9ZQ8Sg(clGIg22BtB6MDy4xBBsbOrbooqXcePaWcOObAAH(uYie1KUYtqqeFnVUzJVIt6uIvmKrf)aF52GL8htn(6Nv5zn8LBEoPQaqeAbI6XfisbIUa(mL)0zh09KhccQWqvy4xBBsbGybOybCWHcalGIg09KhccQWqvqqSahHVMx3SXxyEi84kwXqsB4h4l3gSK)yQXx)SkpRHVCZZjvHpJU(vlaeHwai8XfisbGfqrd6EYdbbvyOk8tNn(AEDZgF19KhccQWqfwXqsr8d8186Mn(cZdHhx3(eF52GL8htnwXqcHXpWxUnyj)XuJV(zvEwdF95lCIiMBRKcaTahJVMx3SXxuEmjc6WDuKkSIHecHFGVCBWs(JPgF9ZQ8Sg(YnpNuvaicTar94ceParxaFMYF6Sd6EYdbbvyOkm8RTnPaqSahOybCWHcalGIg09KhccQWqvqqSahHVMx3SX3T920MUzJvmKua(b(YTbl5pMA8186Mn(kM6Mn(6Nv5zn8vT5K1GUVmIMi)LlankaeMIfWbhkq0fq3xgrtK)YfGgf4afCCbIuGOlaSakAaMhcpUgeelGdouaybu0W2EBAt3SdcIf4OcCe(kM6Mn(cBQkzeXu3Srsue7CLRsfwXqstHFGVCBWs(JPgF9ZQ8Sg(6Zx4erm3wjfGgfGIfisb4MNtQkaeHwaZRB2HXCLd(KOfisb(PggZvoi(ki1vuU8uaAua6eouGifawafnO7jpeeuHHQGGybIuGOlaSakAawM5xnz2KGGybCWHcq3cOMKBnalZ8RMmBsGBdwY)cCubIuGOlaDlGAsU1W2EBAt3SdCBWs(xahCOa(mL)0zh22BtB6MDy4xBBsbGyboqbf4OcePa0TaWcOOHT920MUzheeXxZRB24lj2(PZxw(XkgYdhJFGVMx3SXxbcJSk)sWxUnyj)XuJvSIVKTpLmIAZjR4hyipGFGVCBWs(JPgF9ZQ8Sg(s3calGIg8MIGMZBqqeFnVUzJVEtrqZ5fRyiPd(b(YTbl5pMA81pRYZA4lSakAqCsNYGGybCWHcalGIgiX2pD(YYFqqeFnVUzJVJ5kJvmKrf)aFnVUzJVMGMiMQM3v8LBdwYFm1yfdjTHFGVCBWs(JPgFnVUzJVEtkrmVUzJixIIVYLOiT9Y4Rpt5pD2eSIHKI4h4l3gSK)yQXx)SkpRHV)udZkg01762Nfisb(PgMvmm8RTnPa0OarTarkGAZjRbDFzenr(lxaiwGdhxGifi6cO2CYAiMnPghe9AbOrbOdflGdoua1KCRbIbZJMPgh42GL8VahHVMx3SXxuEs)Mcee4vzSIHecJFGVCBWs(JPgF9ZQ8Sg(6Zx4erm3wjfaAbOybIuaybu0G4WFtZHkeIZfvBMqccIfisbutYTgGLz(vtMnjWTbl5FbIuaybu0aSmZVAYSjHF6SlqKceDbOBbGfqrdB7TPnDZoiiwahCOa)udZkgg(12MuaAuakOahHVMx3SX3HpN0PgJvmKqi8d8LBdwYFm14R51nB8DeAeZRB2iYLO4RFwLN1WxF(cNiI52kPaqSa0g(kxII02lJVefbD7LeZdbRyiPa8d8LBdwYFm14R51nB8DeAeZRB2iYLO4RCjksBVm(suKtU5X0CiyfR4lrrq3EjX8qWpWqEa)aF52GL8htn(IMdsZUuXqEaFnVUzJVIzkrgMKcJNXkgs6GFGVCBWs(JPgF9ZQ8Sg(clGIgiMJ2jJmPnHF6SXxZRB24lXC0ozKjTbRyiJk(b(YTbl5pMA8fnhKMDPIH8a(AEDZgFfZuImmjfgpJvmK0g(b(YTbl5pMA81pRYZA4lrKLse1MtwjbXzFnjIZX04caXcCOarkWp1WSIHHFTTjfGgfG2WxZRB24R4SVMeX5yAmwXqsr8d8LBdwYFm14lAoin7sfd5b8186Mn(kMPezyskmEgRyiHW4h4l3gSK)yQXx)SkpRHV0Ta66DD7Zc4Gdfi6cm8RTnPa0aAb(cJPB2fGMvGJdrTahvGifi6cO2CYAiMnPghe9AbGybOdflqKcq3cOMKBnqmyE0m14a3gSK)f4Oc4Gdfi6cm8RTnPa0aAb(cJPB2fGMvGJduqbIuarEilr5wrEfK6kkxEkaelWp1WSIbXxbPUIYLNcCubIua1Mtwd6(YiAI8xUaqSaua(AEDZgFNveRyiHq4h4l3gSK)yQXx0CqA2LkgYd4R51nB8vmtjYWKuy8mwXqsb4h4l3gSK)yQXx)SkpRHVWcOObI5ODYitAty4xBBsbOrboqh8186Mn(smhTtgzsBWkgsAk8d8LBdwYFm14lAoin7sfd5b8186Mn(kMPezyskmEgRyipCm(b(YTbl5pMA81pRYZA4lSakAyNSrOPnNKGGi(AEDZgFFT9fRyipCa)aFFnxIWnpNuHVhWxZRB24lkpPFtbcc8Qm(YTbl5pMASIv8LOiNCZJP5qWpWqEa)aF52GL8htn(6Nv5zn8vnj3AawM5xnz2Ka3gSK)fisbGfqrdId)nnhQqioxuTzcjiiwGifawafnalZ8RMmBs4No7cePa(8foreZTvsbGwaARarkWp1WyUYHHFTTjfGgfG2WxZRB247WNt6uJXkgs6GFGVCBWs(JPgF9ZQ8Sg(QMKBnalZ8RMmBsGBdwY)cePaWcOObyzMF1Kztc)0zxGifawafnio830COcH4Cr1MjKGGybIua1KCRbPqBdY2eXDmDZoWTbl5FbIuGFQHXCLdd)ABtkankWb8186Mn(o85Ko1ySIHmQ4h4l3gSK)yQXx)SkpRHVerwkruBozLeGhb1KiePrIlaelWNj7WFe1Mtwj4R51nB8fEeutIqKgjgRyiPn8d8LBdwYFm14lAoin7sfd5b8186Mn(kMPezyskmEgRyiPi(b(YTbl5pMA81pRYZA4B0fyy0HjXgSKlWrfisbIUaerwkruBozLe04XiXiEtlaelaDkWr4R51nB8vJhJeJ4nfRyiHW4h4l3gSK)yQXx0CqA2LkgYd4R51nB8vmtjYWKuy8mwXqcHWpWxUnyj)XuJV(zvEwdFJUaQj5wdep3ksIIalZ8h42GL8VarkaSakAG45wrsueyzM)WpD2f4OcePaerwkruBozLe04XiXiEtlaelquXxZRB24RgpgjgXBkwXqsb4h4l3gSK)yQXx0CqA2LkgYd4R51nB8vmtjYWKuy8mwXqstHFGVCBWs(JPgF9ZQ8Sg(clGIgiEUvKefbwM5piiIVMx3SXxIZvKr8MIvmKhog)aF52GL8htn(IMdsZUuXqEaFnVUzJVIzkrgMKcJNXkgYdhWpWxUnyj)XuJV(zvEwdFPBb01762NfWbhkq0fGUfqnj3AawM5xnz2Ka3gSK)fisbg(12MuaAuGVWy6MDbOzf44qulWrfisbuBoznO7lJOjYF5caXcqB4R51nB8DmxzSIH8aDWpWxUnyj)XuJVO5G0SlvmKhWxZRB24RyMsKHjPW4zSIH8quXpWxUnyj)XuJV(zvEwdFvtYTgGLz(vtMnjWTbl5FbIuaybu0aSmZVAYSjbbXceParxGOlWWV22KcqdOfacvGJkqKciYdzjk3kYRGuxr5YtbGyb(PggZvoi(ki1vuU8uaAwbooqbuSahvGifqT5K1GUVmIMi)LlaelaTHVMx3SX3XCLXkgYd0g(b(YTbl5pMA81pRYZA4lSakAawM5xnz2KGGybIuaybu0G4WFtZHkeIZfvBMqc)0zxGifWNVWjIyUTskankafXxZRB247BMn6omI3uSIH8afXpWxUnyj)XuJV(zvEwdFJUaWcOObDp5HGGkmufeelqKceDbgB)iSJCRb7)jHTlaelq0f4qbOVaVMlr8X2CYKcqHfWhBZjtqqhZRB2MSahvaAwbg2hBZjJO7lxGJkWr4R51nB8fEeutIqKgjgRyipaHXpWxUnyj)XuJV(zvEwdFhgDysSblz8186Mn((MzJUdJ4nfRyipaHWpWxUnyj)XuJVO5G0SlvmKhWxZRB24RyMsKHjPW4zSIH8afGFGVCBWs(JPgF9ZQ8Sg(om6WKydwYfisbIUarxahTznyjheimIgpgjUaqlaDkqKceDbOBbGfqrdB7TPnDZoiiwahCOawuKNv5GZv(rqLmjE4(V9zGBdwY)cCuboQao4qbiISuIO2CYkjOXJrIr8MwaiwGdf4i8186Mn(QXJrIr8MIvmKhOPWpWxUnyj)XuJV(zvEwdFhgDysSbl5cePaoAZAWsoiqyenEmsCbGwGdfisbGfqrdEjBJ3i62NHHnVwGifi6cq3calGIg22BtB6MDqqSao4qbSOipRYbNR8JGkzs8W9F7Za3gSK)f4i8186Mn(QXJrIr8MIvmK05y8d8LBdwYFm14lAoin7sfd5b8186Mn(kMPezyskmEgRyiPZb8d8LBdwYFm14RFwLN1WxIilLiQnNSsceNRiJ4nTaqSahWxZRB24lX5kYiEtXkgs6qh8d8LBdwYFm14RFwLN1W3FQHXCLdd)ABtkaelq0fW86MDGep8p4tIwa6lG51n7WyUYbFs0cqHfGBEoPQahvGOqfGBEoPkm8j3fWbhkaSakAWlzB8gr3(mmS5v8186Mn(sIh(JvSIvSIvmga]] )
end