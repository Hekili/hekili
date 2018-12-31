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
        incarnation = 21704, -- 102543

        scent_of_blood = 21714, -- 285564
        brutal_slash = 21711, -- 202028
        primal_wrath = 22370, -- 285381

        moment_of_clarity = 21646, -- 236068
        bloodtalons = 21649, -- 155672
        feral_frenzy = 21653, -- 274837
    } )


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
            id = function () return buff.incarnation.up and 102547 or 5215 end,
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

            copy = { 5215, 102547 }
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
                -- Try without out-of-combat time == 0 check.
                if buff.prowl.up then return false, "prowling" end
                if buff.cat_form.up and buff.predatory_swiftness.down then return false, "predatory_swiftness is down" end
                return true
            end,

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

                if talent.scent_of_blood.enabled then
                    applyBuff( "scent_of_blood" )
                    buff.scent_of_blood.v1 = -3 * active_enemies
                end

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


    spec:RegisterPack( "Feral", 20181230.0935, [[d4enfbqiKkTiQqfEesjxIkujBsi9jQqPrPI4uQiTkKIQxHu1SGkDlHi7sWVaKHbGoMkQLHuXZecMgsPCnOI2gsr5BifPXbvOZHueRdPu5DuHkAEifUhqTpa4GuHKfcv5HuHutuiQCrKsv1gPcXhPcvQtsfkwjvQzIuQYnrkvL2jG6NcrvdfQGwkubEQknva6QiLQIVkef2lK)IKbRQdtzXq5Xu1Kb5YO2mO(SkmAH60kTAHO0RPsA2eDBGSBf)wYWj44crrlxQNJy6KUoH2ovIVtfnEHqNhQQ1tfQA(ub7x0OZiarxitzeW0bGNXXZ0jcamaqAseWzeWj6Q4lWORG5D1oy0Dmqm66iCBs0vWWxwgecq0LuITNr3yvfi0oGa6y1yrSGVabezbjknDRX3gScezb5bctwyaHbBrcIDbiHUGxjtach2moWwicq4qCavKRfxikhHBtgilip6IjUs1Xmim0fYugbmDa4zC8mDIaadaKMebCshAk6seypc4ZamcOB8cbXdcdDHyIhDPv(oc3Mm)ixlUqPBALFSQceAhqaDSASiwWxGaISGeLMU14BdwbISG8aHjlmGWGTibXUaKqxWRKjaHdBghylebiCioGkY1IleLJWTjdKfKpDtR8JCSNbHXD(raG4MpDa4zCm)iLpaPj0UiqBP70nTY3rhBZbtODPBALFKY3rbbXq5FDvukZhpJehs30k)iLVJccIHYhVwunz(xPrIb66Cf481k)sGhUZFN8bjk1nsQ1hSgs30k)iLpouAEgkFhTP57ivdkFdw5oFCyxoL5t2XZ5Jd7YPmFT3JdUj57OnnFhPAqH0nTYps5JdyPfrgkFa3dUDSK8DeXg)85H7d8Z3hZExZxR8nbbj(5xJe)8DgZt(aUhC7yj57iIn(5VK8nzZge(5lkes30k)iLFjWd3uq1W5VK8JTbsYq5VJY9ysj(5JHF(AmNVbbvJJZ8Bgu5cdLVgZeoFxSEnmjtc5NFKFK4NpwPXCN)o5Jves(W7rSscPBALFKY3rhZExZhU68vRpynFFjoA(WvNpX5kWuEtZFN8p4HBtRMKVCjA(rks5pLMFKvKO5F98O5xW5JNSkOa6k0f8kz0Lw57iCBY8JCT4cLUPv(XQkqODab0XQXIybFbciYcsuA6wJVnyfiYcYdeMSWacd2Iee7cqcDbVsMaeoSzCGTqeGWH4aQixlUquoc3Mmqwq(0nTYpYXEgeg35hbaIB(0bGNXX8Ju(aKMq7IaTLUt30kFhDSnhmH2LUPv(rkFhfeedL)1vrPmF8msCiDtR8Ju(okiigkF8Ar1K5FLgjgORZvGZxR8lbE4o)DYhKOu3iPwFWAiDtR8Ju(4qP5zO8D0MMVJunO8nyL78XHD5uMpzhpNpoSlNY81Epo4MKVJ208DKQbfs30k)iLpoGLwezO8bCp42XsY3reB8ZNhUpWpFFm7DnFTY3eeK4NFns8Z3zmp5d4EWTJLKVJi24N)sY3KnBq4NVOqiDtR8Ju(LapCtbvdN)sYp2gijdL)ok3JjL4Npg(5RXC(geunooZVzqLlmu(Amt48DX61WKmjKF(r(rIF(yLgZD(7Kpwri5dVhXkjKUPv(rkFhDm7DnF4QZxT(G189L4O5dxD(eNRat5nn)DY)GhUnTAs(YLO5hPiL)uA(rwrIM)1ZJMFbNpEYQGcP70nTYN2FezVOYq5JXWvZ57lqyMMpgFSdjKVJY7zbLK)utKITgeSOmFZRBnK8RrIFiDBEDRHeeA2xGWmfmS0iUMUnVU1qccn7lqyMspyGGRckDBEDRHeeA2xGWmLEWazIhG4rnDRjDBEDRHeeA2xGWmLEWa18rxo1yCxyWQj5rdyYQGutwdjWJHjzO0nTY3XO5VK8DwTgN)Q5dxD(Meur08zx4g)A481kFq2oQTt(ACBK40T51TgsqOzFbcZu6bdKlwVgMKXDmqmyrctPXTrIX1ftkYGby6286wdji0SVaHzk9GbYfRxdtY4ogigSiHP042iX46IjfzW0b3fgS545Evo4CLquWsMe38aTZrGhdtYqPBALFKxGhUZhqhj)LKpeln8zO8x48DY5pmdLVw5hBnK3iA(nF0LtnoFPPCNFn5Vt(AmNFxQPBnPBZRBnKGqZ(ceMP0dgixSEnmjJ7yGyWqS0WNHOuyQsGhUX1ftkYGby6Mw5dy8sYp2ee4HKVZyEY)AyCRvPX4MpEYQGutwdjFmrn)P08P9Cm5VK8vtYJYqPBZRBnKGqZ(ceMP0dgixSEnmjJ7yGyWqS0WNHOuyQsGhUX1ftkYGpJ7cdwnjpAGyyCRvPXbEmmjdfvnjpAatwfKAYAibEmmjdfLUQj5rdsXXAQDicBB6wtGhdtYqPBZRBnKGqZ(ceMP0dgiHUCkt3Mx3AibHM9fimtPhmqEtPGRgu6Mw5FhtGexA(TTq5JjcdZq5tutj5JXWvZ57lqyMMpgFSdjFBGYxO5ijuQUZr(ljFOA4q6286wdji0SVaHzk9GbImMajUukIAkjDBEDRHeeA2xGWmLEWaju6wt6286wdji0SVaHzk9GbcJBc3UMUt30kFA)rK9IkdLp7c34NVUG481yoFZRvN)sY3CXwPHj5q6286wdbmXvrPKcZiX4UWGPlMimCqOlNYGOqu6IjcdhiXgu5eelHcIcPBZRBne6bdulouMx3AOKlrXDmqm4sGhUXDHbJvesu6wc8WnfunC6286wdHEWa1IdL51Tgk5suChdedMSZHKPuRpynDNUnVU1qc(QKqLZHagYiX4UWGPlMimCWBkfC1GcIcPBZRBnKGVkju5Ci0dgiHUCkXDHbJjcdh2XB9y6wtOzq2oeAaWaoJIjcdhISIZHKPiQjDL7GOq6286wdj4Rscvohc9GbcJBc3UI7cdMhUpWhaGJaaJEIVkju5Cc6EWnHcwSXp0miBhcaWPdoGjcdh09GBcfSyJFqu400T51TgsWxLeQCoe6bdKUhCtOGfB8XDHbZd3h4hGy41VkaatZayumry4GUhCtOGfB8dqLZjDBEDRHe8vjHkNdHEWaHXnHBx35iDBEDRHe8vjHkNdHEWabZTjPGBEC84J7cd2xGWkkHAhLagGPBZRBnKGVkju5Ci0dgOD8wpMU1G7cdMhUpWhaGJaaJEIVkju5Cc6EWnHcwSXp0miBhcaoJthCategoO7b3ekyXg)GOWPPBZRBnKGVkju5Ci0dgiHs3AWDmqmymtvjtju6wdvbtzhRCv8XDHbRwFWAqxqmLwuqltdAgoDWHt0fetPff0Y04mocWONGjcdhW4MWTRbrbhCategoSJ36X0TMGOWPNMUnVU1qc(QKqLZHqpyGiXgu5eelHWDHb7lqyfLqTJsOboJYd3h4daWMx3AcT5kh8frJcvAOnx5GairPUcYLBAqNW5OyIWWbDp4Mqbl24hefIEcMimCatwfKAYAibrbhCGUQj5rdyYQGutwdjWJHjzOtJEcDvtYJg2XB9y6wtGhdtYqo4GVkju5Cc74TEmDRj0miBhcaoJJNgLUyIWWHD8wpMU1eefs3Mx3AibFvsOY5qOhmqIeMAvgejDNUnVU1qcKDoKmLA9bRG9MsbxniCxyW0ftego4nLcUAqbrH0T51TgsGSZHKPuRpyLEWa1MRmUlmymry4GqxoLbrbhCategoqInOYjiwcfefs3Mx3AibYohsMsT(Gv6bdKjQfLPQ5DnDBEDRHei7Cizk16dwPhmqEtkPmVU1qjxII7yGyW(QKqLZHKUnVU1qcKDoKmLA9bR0dgiyUl)wIekSvzCvRpyLAHbdvAOxHGUEx35ikuPHEfcndY2HqJievT(G1GUGykTOGwgaNby0tuRpyneZMuJdcELg0bNo4GAsE0aXW4wRsJd8yysg600T51TgsGSZHKPuRpyLEWa18rxo1yCxyW(cewrju7OeW4mkMimCqOzitRgFkIZfwhMqcIcrvtYJgWKvbPMSgsGhdtYqrXeHHdyYQGutwdjavoNONqxmry4WoERht3AcIco4auPHEfcndY2HqdC800T51TgsGSZHKPuRpyLEWa1IdL51Tgk5suChdedgENLeZnb3fgSVaHvuc1okba0w6286wdjq25qYuQ1hSspyGAXHY86wdLCjkUJbIbFWd3MwnjDNUnVU1qcW7SKyUjGfQss1mPeBpJlC1udhrf850T51TgsaENLeZnHEWarmxSdMQlRXDHbJjcdhiMl2bt1L1bOY5KUnVU1qcW7SKyUj0dgiHQKuntkX2Z4cxn1WrubFoDBEDRHeG3zjXCtOhmqc9cYKuoBtJXvT(GvQfgmrGLsk16dwjbHEbzskNTPXa4CuOsd9keAgKTdHg0w6286wdjaVZsI5MqpyGeQss1mPeBpJlC1udhrf850T51TgsaENLeZnHEWaj0lits5Snngx16dwPwyWebwkPuRpyLee6fKjPC2MgdaW0jDBEDRHeG3zjXCtOhmqcvjPAMuITNXfUAQHJOc(C6286wdjaVZsI5MqpyG6vax16dwPwyW0vxVR7C4GdN0miBhcnadj2MU1qZbyicNg9e16dwdXSj14GGxbaDWzu6QMKhnqmmU1Q04apgMKHo1bhoPzq2oeAagsSnDRHMdWaogvGBYsuEukqIsDfKl3aaQ0qVcbbqIsDfKl3NgvT(G1GUGykTOGwga4y6286wdjaVZsI5MqpyGeQss1mPeBpJlC1udhrf850T51TgsaENLeZnHEWarmxSdMQlRXDHbJjcdhiMl2bt1L1HMbz7qOXz6KUnVU1qcW7SKyUj0dgiHQKuntkX2Z4cxn1WrubFoDBEDRHeG3zjXCtOhmqGSfeUlmymry4W21qfznNKGOq6286wdjaVZsI5MqpyGG5U8BjsOWwLXfKfrkE4(aFWNt3PBZRBnKWbpCBA1eWnF0Ltng3fgSAsE0aMSki1K1qc8yysgkkMimCqOzitRgFkIZfwhMqcIcrXeHHdyYQGutwdjavoNO(cewrju7OeW0wuOsdT5khAgKTdHg0w6286wdjCWd3MwnHEWa18rxo1yCxyWQj5rdyYQGutwdjWJHjzOOyIWWbmzvqQjRHeGkNtumry4GqZqMwn(ueNlSomHeefIQMKhnifhRP2HiSTPBnbEmmjdffQ0qBUYHMbz7qOX50T51Tgs4GhUnTAc9GbcRfvtsrKgjg3fgmrGLsk16dwjbSwunjfrAKyaaXKTzik16dwjPBZRBnKWbpCBA1e6bdKqvsQMjLy7zCHRMA4iQGpNUnVU1qch8WTPvtOhmqACBKykVP4UWGpPz4MjXgMKpn6jebwkPuRpyLe042iXuEtbaDonDBEDRHeo4HBtRMqpyGeQss1mPeBpJlC1udhrf850T51Tgs4GhUnTAc9GbsJBJet5nf3fg8jQj5rdeppkvbtHjRckWJHjzOOyIWWbINhLQGPWKvbfGkNZPrjcSusPwFWkjOXTrIP8McGiKUnVU1qch8WTPvtOhmqcvjPAMuITNXfUAQHJOc(C6286wdjCWd3MwnHEWarCUcmL3uCxyWyIWWbINhLQGPWKvbfefIseyPKsT(GvsG4CfykVPa4C6286wdjCWd3MwnHEWajuLKQzsj2Egx4QPgoIk4ZPBZRBnKWbpCBA1e6bduBUY4QwFWk1cdMU66DDNdhC4e6QMKhnGjRcsnznKapgMKHI2miBhcnGeBt3AO5ameHtJQwFWAqxqmLwuqldaAlDBEDRHeo4HBtRMqpyGeQss1mPeBpJlC1udhrf850T51Tgs4GhUnTAc9GbQnxzCvRpyLAHbRMKhnGjRcsnznKapgMKHIIjcdhWKvbPMSgsqui6jN0miBhcnattpnQa3KLO8OuGeL6kixUbauPH2CLdcGeL6kixUP5amGJ480OQ1hSg0fetPff0YaG2s30k)iJvJZN2ZXKF08XdqCZ3jNV3M8fjC(GQAG3MZxR8jMlC(4by((yRpycU5Bsz5CNJ8fj5Rv(ySQCNFZWntIZVnx50T51Tgs4GhUnTAc9Gbcuvd82mL3uCxyWyIWWbmzvqQjRHeefIIjcdheAgY0QXNI4CH1HjKau5CI6lqyfLqTJsObot3Mx3AiHdE420Qj0dgiSwunjfrAKyCxyWNGjcdh09GBcfSyJFqui6jTTquSl8ObdcIe2baNCMEqweP8XwFWKi5JT(GjuWT51TgtEknVzFS1hmLUG4tpnDBEDRHeo4HBtRMqpyGav1aVnt5nfx16dwPwyWnd3mj2WKC6286wdjCWd3MwnHEWajuLKQzsj2Egx4QPgoIk4ZPBZRBnKWbpCBA1e6bdKg3gjMYBkUlm4MHBMeByso6jN4I1RHj5GiHP042iXGPt0tOlMimCyhV1JPBnbrbhCWC8CVkhCUsikyjtIBEG25iWJHjzOtp1bhicSusPwFWkjOXTrIP8McGZNMUnVU1qch8WTPvtOhmqACBKykVP4UWGBgUzsSHj5OUy9AysoisyknUnsm4ZrXeHHdEjBT3i6ohHMnVg9e6Ijcdh2XB9y6wtquWbhmhp3RYbNReIcwYK4MhODoc8yysg600T51Tgs4GhUnTAc9GbsOkjvZKsS9mUWvtnCevWNt3Mx3AiHdE420Qj0dgiIZvGP8MI7cdMiWsjLA9bRKaX5kWuEtbW50T51Tgs4GhUnTAc9GbIe3meUlmyOsdT5khAgKTdbaNyEDRjqIBgk4lIsV51TMqBUYbFr0iXd3h4FQJlE4(a)qZh84GdyIWWbVKT2BeDNJqZMxt3PBALpTYhWyo)sGhUZ)GhUnPe)8HlPSCMVgZ5lRJ1NFbNVgZ53mrZVGZxJ58nbjU5JjQ5VK8jSG1MYq5xIA(XCZ5dxD(Y6y9MmFV06vXpDtR8J8c8SZr(a6i57CLY8X48HyPHpdL)cNVto)HzO81k)yRH8grZxAk35FIZ41hNFSjiWdjFNRgNpXW4wRsJZpA(yA(yIA(tLVCpnDtR8J8Am3oxcNVtoFNRuMFjWt(oxnoFaDeCZh)smFVn5tmywIF(EJO5RXljF4UaLprztQX57C14suZhRzZ1DoYF1q6286wdjuc8WnyDp4Mqbl24J7cd2fRxdtYbiwA4ZqukmvjWd3Gby6Mw57OKon8j5xc8KVZvJZVnxzCZ3xdre0oh5tu2KAC(2aLFnC(4by((yRp48pzHZxnjpkdDA6286wdjuc8Wn9GbQnxzCxyW0vxVR7C4GdyIWWbHUCkdIcPBALpThRK8bzUY5teBoFNC(8aLVgZ5xc8WD(ooiCKPipE2Xr(oJ5j)sSZhEBIMFVc5VK81176ohPBZRBnKqjWd30dgixSEnmjJ7yGyWLapCtbvdJRlMuKbdvAOxHGUEx35iDtR8XRzZ18lrn)coFnMZ386wt(YLOPBZRBnKqjWd30dgiN2Q4sypyagaiapJ7cdgQ0qVcbD9UUZr6Mw57yGZ3jNFS5cNpTNJb38Tbk)yZfECSA(MGGCzO8xnF8znFrcNpOQg4T5q6Mw5h5Xb4M)cNVto)AK4NFS5cNFnC(4by((yRp48nVUUW5temq5dQQbEBoFXrxz(o5892KVjiiXp)EfY35QX5VA6286wdjuc8Wn9Gbcuvd82mL3uCxyW0vxVR7C4GdyIWWbmzvqQjRHeiQ5Df85O(cewrju7OeAGZ0nTY3X96cp57f7MhnFvC25i)vZFj5BsNg(K8DwTgNpiBh12zNJ8142iX4MpPYxYkjFtqqIF(RMFm3CiDBEDRHekbE4MEWaPXTrIXDHbtxD9UUZruFbcROeQDucnWz6Mw57OgO8x48NA48l481yoFdRCHZ3eeK4JB(o58jlibj(5FJBgci8Ar1K5FLgjgORZvGZxC0vMpot3Mx3AiHsGhUPhmqyTOAskI0iX4UWG9fiSIsO2rj0aNrnVUUWu8WGwMaGZPBZRBnKqjWd30dgiIZvGP8MI7cd2xGWkkHAhLqdCg1866ctXddAzcaoNUnVU1qcLapCtpyGiXndH7cd2xGWkkHAhLqdCMUPv(4a(OlNAmU57mMN8DY5hBUW5JZ89fiSkFHAhLKVnq5JjRcsnznK8TbkFE1yUPDPBALFKbNFS5cN)1W4wRsJZ3gO8NkFZRRlC(yYQGutwdjFIAExZ)exwlFAFDK8jcgOtZNDHN8x48xn)MJmf3Mj5B5hBnu(EJOPBALFKbNFS5cNVLVqZqMwn(5tCUW6Wes(cD5Z3CXwPHj58pXL1Y)IdYhEjX7CCA6286wdjuc8Wn9GbQ5JUCQX4UWG9fiSIsO2rjGXzu1K8ObmzvqQjRHe4XWKmu0tutYJgigg3AvACGhdtYqrXeHHdyYQGutwdjavohhCategoi0mKPvJpfX5cRdtibrHtt30kFhdC(o585bIHYxui)yRH8gr35iFCaF0Ltng38fjC(a6i5Rv(nhjEuUZ3BA(WvdkDBEDRHekbE4MEWaP7b3ekyXg)0nTY3rnq5xJNZ3jN)bR5hZnNVP5JZ89fiSIsO2rj4MFKvKO53Rq(2aLVtoFR58ffY3gO8BXz25iDBEDRHekbE4MEWa1RaUlmyFbcROeQDucyCIUUWnzRbbmDa4zC8mDottcNXzeWj6606zNdc6gz4OWba7ya2XnTl)8bmMZFbjuTMpC157yj7Cizk16dwDS53CKP42mu(KceNVjQfitzO89X2CWKq6M2Bho)iq7YN2NHikiuTYq5BEDRjFhRjQfLPQ5D1Xgs3PBhdiHQvgkFAA(Mx3AYxUeLes3ORCjkbbi6wc8WncqeWNraIU8yysgcHh667v5En01fRxdtYbiwA4ZqukmvjWd35doFaIUMx3AqxDp4Mqbl24JueW0bbi6YJHjzieEORVxL71qx6MVUEx35iFhCiFmry4GqxoLbrb0186wd62MRmsrahbeGOlpgMKHq4HUUysrgDHkn0RqqxVR7CGUMx3AqxxSEnmjJUUyn1yGy0Te4HBkOAyKIaM2qaIU8yysgcHh6syp6cWaab4z0186wd660wfD99QCVg6cvAOxHGUEx35aPiGXjcq0LhdtYqi8qxFVk3RHU0nFD9UUZr(o4q(yIWWbmzvqQjRHeiQ5DnFW5Fo)O57lqyfLqTJsYNg5Jt0186wd6cQQbEBMYBksratZqaIU8yysgcHh667v5En0LU5RR31DoYpA((cewrju7OK8Pr(4eDnVU1GUACBKyKIaMMIaeD5XWKmecp013RY9AORVaHvuc1okjFAKpoZpA(MxxxykEyqltYha5FgDnVU1GUyTOAskI0iXifbmoIaeD5XWKmecp013RY9AORVaHvuc1okjFAKpoZpA(MxxxykEyqltYha5FgDnVU1GUeNRat5nfPiGPjiarxEmmjdHWdD99QCVg66lqyfLqTJsYNg5Jt0186wd6sIBgcPiGpdqeGOlpgMKHq4HU(EvUxdD9fiSIsO2rj5doFCMF08vtYJgWKvbPMSgsGhdtYq5hn)tYxnjpAGyyCRvPXbEmmjdLF08XeHHdyYQGutwdjavoN8DWH8XeHHdcndzA14trCUW6Wesqui)trxZRBnOBZhD5uJrkc4ZNraIUMx3AqxDp4Mqbl24JU8yysgcHhsraFMoiarxEmmjdHWdD99QCVg66lqyfLqTJsYhC(4eDnVU1GU9kGuKIUqmSjkveGiGpJaeD5XWKmecp013RY9AOlDZhtegoi0Ltzqui)O5t38XeHHdKydQCcILqbrb0186wd6sCvukPWmsmsratheGOlpgMKHq4HU(EvUxdDXkcj)O5t38lbE4McQggDnVU1GUT4qzEDRHsUefDLlrPgdeJULapCJueWrabi6YJHjzieEOR51Tg0TfhkZRBnuYLOORCjk1yGy0LSZHKPuRpyfPifDfA2xGWmfbic4ZiarxEmmjdHWdPiGPdcq0LhdtYqi8qkc4iGaeD5XWKmecpKIaM2qaIU8yysgcHh667v5En0vnjpAatwfKAYAibEmmjdHUMx3Aq3Mp6YPgJueW4ebi6YJHjzieEORlMuKrxaIUMx3AqxxSEnmjJUUyn1yGy0vKWuACBKyKIaMMHaeD5XWKmecp0186wd66I1RHjz01ftkYOlDqxFVk3RHUMJN7v5GZvcrblzsCZd0ohbEmmjdHUUyn1yGy0vKWuACBKyKIaMMIaeD5XWKmecp01ftkYOlarxZRBnORlwVgMKrxxSMAmqm6cXsdFgIsHPkbE4gPiGXreGOlpgMKHq4HUMx3AqxxSEnmjJUUysrgDpJU(EvUxdDvtYJgigg3AvACGhdtYq5hnF1K8ObmzvqQjRHe4XWKmu(rZNU5RMKhnifhRP2HiSTPBnbEmmjdHUUyn1yGy0fILg(meLctvc8WnsrattqaIUMx3AqxHUCkrxEmmjdHWdPiGpdqeGOR51Tg01BkfC1GqxEmmjdHWdPiGpFgbi6YJHjzieEifb8z6GaeDnVU1GUcLU1GU8yysgcHhsraFociarxZRBnOlg3eUDfD5XWKmecpKIu09GhUnTAccqeWNraIU8yysgcHh667v5En0vnjpAatwfKAYAibEmmjdLF08XeHHdcndzA14trCUW6Wesqui)O5JjcdhWKvbPMSgsaQCo5hnFFbcROeQDus(GZN2YpA(qLgAZvo0miBhs(0iFAdDnVU1GUnF0LtngPiGPdcq0LhdtYqi8qxFVk3RHUQj5rdyYQGutwdjWJHjzO8JMpMimCatwfKAYAibOY5KF08XeHHdcndzA14trCUW6Wesqui)O5RMKhnifhRP2HiSTPBnbEmmjdLF08Hkn0MRCOzq2oK8Pr(NrxZRBnOBZhD5uJrkc4iGaeD5XWKmecp013RY9AOlrGLsk16dwjbSwunjfrAK48bq(qmzBgIsT(Gvc6AEDRbDXAr1KuePrIrkcyAdbi6YJHjzieEOlC1udhrfb8z0186wd6kuLKQzsj2EgPiGXjcq0LhdtYqi8qxFVk3RHUNKFZWntInmjN)P5hn)tYNiWsjLA9bRKGg3gjMYBA(aiF6K)POR51Tg0vJBJet5nfPiGPziarxEmmjdHWdDHRMA4iQiGpJUMx3AqxHQKuntkX2Zifbmnfbi6YJHjzieEORVxL71q3tYxnjpAG45rPkykmzvqbEmmjdLF08XeHHdeppkvbtHjRckavoN8pn)O5teyPKsT(GvsqJBJet5nnFaKFeqxZRBnORg3gjMYBksraJJiarxEmmjdHWdDHRMA4iQiGpJUMx3AqxHQKuntkX2Zifbmnbbi6YJHjzieEORVxL71qxmry4aXZJsvWuyYQGcIc5hnFIalLuQ1hSsceNRat5nnFaK)z0186wd6sCUcmL3uKIa(maraIU8yysgcHh6cxn1WruraFgDnVU1GUcvjPAMuITNrkc4ZNraIU8yysgcHh667v5En0LU5RR31DoY3bhY)K8PB(Qj5rdyYQGutwdjWJHjzO8JMFZGSDi5tJ8HeBt3AYNMNpadri)tZpA(Q1hSg0fetPff0Y5dG8Pn0186wd62MRmsraFMoiarxEmmjdHWdDHRMA4iQiGpJUMx3AqxHQKuntkX2Zifb85iGaeD5XWKmecp013RY9AORAsE0aMSki1K1qc8yysgk)O5JjcdhWKvbPMSgsqui)O5Fs(NKFZGSDi5tdW5ttZ)08JMVa3KLO8OuGeL6kixUZha5dvAOnx5GairPUcYL78P55dWaoIZ8pn)O5RwFWAqxqmLwuqlNpaYN2qxZRBnOBBUYifb8zAdbi6YJHjzieEORVxL71qxmry4aMSki1K1qcIc5hnFmry4GqZqMwn(ueNlSomHeGkNt(rZ3xGWkkHAhLKpnYhNOR51Tg0fuvd82mL3uKIa(moraIU8yysgcHh667v5En09K8XeHHd6EWnHcwSXpikKF08pj)2wik2fE0Gbbrc7KpaY)K8pNp95dYIiLp26dMKFKY3hB9btOGBZRBnMm)tZNMNFZ(yRpykDbX5FA(NIUMx3AqxSwunjfrAKyKIa(mndbi6YJHjzieEORVxL71q3MHBMeBysgDnVU1GUGQAG3MP8MIueWNPPiarxEmmjdHWdDHRMA4iQiGpJUMx3AqxHQKuntkX2Zifb8zCebi6YJHjzieEORVxL71q3MHBMeByso)O5Fs(NKVlwVgMKdIeMsJBJeNp48Pt(rZ)K8PB(yIWWHD8wpMU1eefY3bhY3C8CVkhCUsikyjtIBEG25iWJHjzO8pn)tZ3bhYNiWsjLA9bRKGg3gjMYBA(ai)Z5Fk6AEDRbD142iXuEtrkc4Z0eeGOlpgMKHq4HU(EvUxdDBgUzsSHj58JMVlwVgMKdIeMsJBJeNp48pNF08XeHHdEjBT3i6ohHMnVMF08pjF6MpMimCyhV1JPBnbrH8DWH8nhp3RYbNReIcwYK4MhODoc8yysgk)trxZRBnORg3gjMYBksrathaIaeD5XWKmecp0fUAQHJOIa(m6AEDRbDfQss1mPeBpJueW05mcq0LhdtYqi8qxFVk3RHUebwkPuRpyLeioxbMYBA(ai)ZOR51Tg0L4CfykVPifbmDOdcq0LhdtYqi8qxFVk3RHUqLgAZvo0miBhs(ai)tY386wtGe3muWxenF6Z386wtOnx5GViA(rkFE4(a)8pnFhx5Zd3h4hA(GN8DWH8XeHHdEjBT3i6ohHMnVIUMx3AqxsCZqifPOl8oljMBccqeWNraIU8yysgcHh6cxn1WruraFgDnVU1GUcvjPAMuITNrkcy6GaeD5XWKmecp013RY9AOlMimCGyUyhmvxwhGkNd6AEDRbDjMl2bt1L1ifbCeqaIU8yysgcHh6cxn1WruraFgDnVU1GUcvjPAMuITNrkcyAdbi6YJHjzieEORVxL71qxIalLuQ1hSscc9cYKuoBtJZha5Fo)O5dvAOxHqZGSDi5tJ8Pn0186wd6k0lits5SnngPiGXjcq0LhdtYqi8qx4QPgoIkc4ZOR51Tg0vOkjvZKsS9msratZqaIU8yysgcHh667v5En0LiWsjLA9bRKGqVGmjLZ2048ba48Pd6AEDRbDf6fKjPC2MgJueW0ueGOlpgMKHq4HUWvtnCeveWNrxZRBnORqvsQMjLy7zKIaghraIU8yysgcHh667v5En0LU5RR31DoY3bhY)K8BgKTdjFAaoFiX20TM8P55dWqeY)08JM)j5RwFWAiMnPghe8A(aiF6GZ8JMpDZxnjpAGyyCRvPXbEmmjdL)P57Gd5Fs(ndY2HKpnaNpKyB6wt(088byahZpA(cCtwIYJsbsuQRGC5oFaKpuPHEfccGeL6kixUZ)08JMVA9bRbDbXuArbTC(aiFCeDnVU1GU9kGueW0eeGOlpgMKHq4HUWvtnCeveWNrxZRBnORqvsQMjLy7zKIa(maraIU8yysgcHh667v5En0ftegoqmxSdMQlRdndY2HKpnY)mDqxZRBnOlXCXoyQUSgPiGpFgbi6YJHjzieEOlC1udhrfb8z0186wd6kuLKQzsj2EgPiGptheGOlpgMKHq4HU(EvUxdDXeHHdBxdvK1CscIcOR51Tg0fKTGqkc4Zrabi6cYIifpCFGp6EgDnVU1GUWCx(TejuyRYOlpgMKHq4HuKIU(QKqLZHGaeb8zeGOlpgMKHq4HU(EvUxdDPB(yIWWbVPuWvdkikGUMx3AqxiJeJueW0bbi6YJHjzieEORVxL71qxmry4WoERht3AcndY2HKpnYhGbCMF08XeHHdrwX5qYue1KUYDquaDnVU1GUcD5uIueWrabi6YJHjzieEORVxL71qxE4(a)8ba48JaaZpA(NKVVkju5Cc6EWnHcwSXp0miBhs(aiFCMVdoKpMimCq3dUjuWIn(brH8pfDnVU1GUyCt42vKIaM2qaIU8yysgcHh667v5En0LhUpWpaXWRF18ba48Pzam)O5Jjcdh09GBcfSyJFaQCoOR51Tg0v3dUjuWIn(ifbmoraIUMx3AqxmUjC76ohOlpgMKHq4HueW0meGOlpgMKHq4HU(EvUxdD9fiSIsO2rj5doFaIUMx3AqxyUnjfCZJJhFKIaMMIaeD5XWKmecp013RY9AOlpCFGF(aaC(raG5hn)tY3xLeQCobDp4Mqbl24hAgKTdjFaK)zCMVdoKpMimCq3dUjuWIn(brH8pfDnVU1GU74TEmDRbPiGXreGOlpgMKHq4HU(EvUxdDvRpynOliMslkOLZNg5tZWz(o4q(NKVUGykTOGwoFAK)zCeG5hn)tYhtegoGXnHBxdIc57Gd5Jjcdh2XB9y6wtqui)tZ)u0vO0Tg0fZuvYucLU1qvWu2XkxfF0186wd6ku6wdsrattqaIU8yysgcHh667v5En01xGWkkHAhLKpnYhN5hnFE4(a)8ba48nVU1eAZvo4lIMF08Hkn0MRCqaKOuxb5YD(0iF6eoNF08XeHHd6EWnHcwSXpikKF08pjFmry4aMSki1K1qcIc57Gd5t38vtYJgWKvbPMSgsGhdtYq5FA(rZ)K8PB(Qj5rd74TEmDRjWJHjzO8DWH89vjHkNtyhV1JPBnHMbz7qYha5FghZ)08JMpDZhtegoSJ36X0TMGOa6AEDRbDjXgu5eelHqkc4Zaebi6AEDRbDfjm1Qmic6YJHjzieEifPOlzNdjtPwFWkcqeWNraIU8yysgcHh667v5En0LU5Jjcdh8MsbxnOGOa6AEDRbD9MsbxniKIaMoiarxEmmjdHWdD99QCVg6Ijcdhe6YPmikKVdoKpMimCGeBqLtqSekikGUMx3Aq32CLrkc4iGaeDnVU1GUMOwuMQM3v0LhdtYqi8qkcyAdbi6YJHjzieEOR51Tg01BsjL51Tgk5su0vUeLAmqm66RscvohcsraJteGOlpgMKHq4HU(EvUxdDHkn0RqqxVR7CKF08Hkn0RqOzq2oK8Pr(ri)O5RwFWAqxqmLwuqlNpaY)maZpA(NKVA9bRHy2KACqWR5tJ8PdoZ3bhYxnjpAGyyCRvPXbEmmjdL)POR51Tg0fM7YVLiHcBvgPiGPziarxEmmjdHWdD99QCVg66lqyfLqTJsYhC(4m)O5JjcdheAgY0QXNI4CH1HjKGOq(rZxnjpAatwfKAYAibEmmjdLF08XeHHdyYQGutwdjavoN8JM)j5t38XeHHd74TEmDRjikKVdoKpuPHEfcndY2HKpnYhhZ)u0186wd628rxo1yKIaMMIaeD5XWKmecp013RY9AORVaHvuc1okjFaKpTHUMx3Aq3wCOmVU1qjxIIUYLOuJbIrx4Dwsm3eKIaghraIU8yysgcHh6AEDRbDBXHY86wdLCjk6kxIsngigDp4HBtRMGuKIu01e14Qr37cYrJuKIq]] )
end