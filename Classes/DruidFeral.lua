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
            elseif subtype == "SPELL_CAST_SUCCESS" and ( spellID == class.abilities.rip.id or spellID == class.abilities.primal_wrath.id ) then
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

                opener_done = true

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


    spec:RegisterPack( "Feral", 20190106.2117, [[d00T7aqiKsTiIOKEesjxIiQWMuH(esrzucvDkHkRcPGEfsLzbLClIe7sWVujgguOJPcwguWZek10qkY1iszBcL4BQufJtLQ6CifQ1HuiVJikvZJiP7PQAFcfhePOAHqrpePatuLQuxKiQOnsKkFKikHrsKQYjjIQwjrzMerL2PkLHkuslLikEQQmvvsxLikrFLivv7f4Vq1GHCyQwmsEmLMmixg1Mb1NfYOvrNwXQvPk51ivnBkUTQYUv63sgoHooruklx0ZrmDsxNGTRsLVtunEIiNhk16jsvMpry)sn4a4k4b5kdUHbmEGgJXdymwcy4WH7j23d4PylYGNOBP3JyWB9pg8KooDd4j6yBkhcCf8iLqAzW7uvrcn6YLOrpfOc267cz(emUo1AthwVqMp7fktrDHc2LceF3fXSGhdtUeRjlz8bICjwLm437uyGWLooDtGmFwWJsymQKFbuGhKRm4ggW4bAmgpGXyjGHdhUNylnWJiYwWTdym2G35abXlGc8GyIf8OvJKooDtJU3PWa1YOvJovvKqJUCjA0tbQGT(UqMpbJRtT20H1lK5ZEHYuuxOGDPaX3Drml4XWKlXAYsgFGixIvjd(9ofgiCPJt3eiZNTLrRgjZxbpXUrsdRgHbmEGg3iP0imGbAegUFlRLrRgrdo9nIj0OwgTAKuAenhcIHA0JEbJPry6KZqlJwnsknIMdbXqncZuqDtJEgNCE5jFe5gPvJkrE5SrZ2OpbJosr9mI1qlJwnsknkwnULHAenW1gjDv(1ihw5SrXAwYnnImRLBuSMLCtJ0CII4K0iAGRns6Q8l0YOvJKsJKmSXLed1ORteN0msJKoHe7gXlNry3i7jBPVrA1ixu0GDJQ1GDJKFYBJUorCsZins6esSB0qAKBs2HWUrcIHwgTAKuAujYlN4q1YnAin60xidd1Ozvox3yWUruy3i9KBKdbvRK9gL8xDhd1i9KjCJUZZXPmmj0YOvJKsJObNSL(gbxzJupJyTr2sy1gbxzJiYhrg36AJMTrr8YPRvsAKziAJKIuA0wAJUxceTrplVAJk4gHPPkOqlJwnsknIMdbXqnIYT0li2irJVncUYgvI8Yza8eZcEmm4rRgjDC6MgDVtHbQLrRgDQQiHgD5s0ONcubB9DHmFcgxNATPdRxiZN9cLPOUqb7sbIV7IywWJHjxI1KLm(arUeRsg87Dkmq4shNUjqMpBlJwnsMVcEIDJKgwncdy8anUrsPryad0imC)wwlJwnIgC6BetOrTmA1iP0iAoeed1Oh9cgtJW0jNHwgTAKuAenhcIHAeMPG6Mg9mo58Yt(iYnsRgvI8YzJMTrFcgDKI6zeRHwgTAKuAuSACld1iAGRns6Q8RroSYzJI1SKBAezwl3Oynl5MgP5efXjPr0axBK0v5xOLrRgjLgjzyJljgQrxNioPzKgjDcj2nIxoJWUr2t2sFJ0QrUOOb7gvRb7gj)K3gDDI4KMrAK0jKy3OH0i3KSdHDJeedTmA1iP0OsKxoXHQLB0qA0PVqggQrZQCUUXGDJOWUr6j3ihcQwj7nk5V6ogQr6jt4gDNNJtzysOLrRgjLgrdozl9ncUYgPEgXAJSLWQncUYgrKpImU11gnBJI4LtxRK0iZq0gjfP0OT0gDVeiAJEwE1gvWncttvqHwgTAKuAenhcIHAeLBPxqSrIgFBeCLnQe5LZqlRLrRgj5usSvqzOgrXWvYnYwFuU2ikoAwsOr0CRLfvsJ2ALYPNFWcMg5wDQL0OAnyhAzUvNAjbXKT1hLR)WgNqFlZT6uljiMST(OCLU)lWvb1YCRo1scIjBRpkxP7)Ile9XR66uBlZT6uljiMST(OCLU)ljhLLC9eRb(xDdVAGYufK6MAjbEDkdd1YOvJK8AJgsJKxPE2OrBeCLnYnFfrBeFhNyxl3iTA0NpR6Z2i9mDYzlZT6uljiMST(OCLU)l3554uggR1)4FbcJRNPtoX6o3iW)ySL5wDQLeet2wFuUs3)L78CCkdJ16F8VaHX1Z0jNyDNBe4FmG1a)7spohLdYhdeoSHjNjVqZgf41PmmulZT6uljiMST(OCLU)lIzj30YCRo1scIjBRpkxP7)I1vC4k)Az0QrV1fjNL2O0hOgrjadZqnIOUsAefdxj3iB9r5AJO4OzjnYxOgjMSuelvNnQrdPrq1YHwMB1PwsqmzB9r5kD)xiRlsolfNOUsAzUvNAjbXKT1hLR09FrS0P2wMB1PwsqmzB9r5kD)xO4KWj9TSwgTAKKtjXwbLHAeFhNy3iD(4gPNCJCRwzJgsJ878X4ugo0YCRo1s(j0lym4uo5eRb(N2ucWWbXSKBccIhPnLamCGC6qL8p2afeeBzUvNAj09FjfwC3QtT4MHOyT(h)xI8Yjwd8pTlrE5ehQwUL5wDQLq3)LuyXDRo1IBgII16F8pz2idJREgXAlRL5wDQLeSvzGk5l5NItcN0J1a)ZlNryhZFSX4X4TvzGk5BqNioj4Wcj2HK)8zjXinjKGsagoOteNeCyHe7GGyCTm3QtTKGTkdujFj09FrNioj4Wcj2ynW)8Yze2bigESJgZFSGXJucWWbDI4KGdlKyhGk5BlZT6uljyRYavYxcD)xO4KWj9Zg1YCRo1sc2QmqL8Lq3)fyoDdoCYR0dBSg4FB9rv4I1Sk5hJTm3QtTKGTkdujFj09FzwRNRRtTynW)8Yze2X8hBmEmEBvgOs(g0jItcoSqIDi5pFwsmhKMesqjadh0jItcoSqIDqqmUwMB1PwsWwLbQKVe6(Viw6ulwR)X)uUQggxS0Pw8cg3JgZOyJ1a)REgXAqNpgxlCOHLASinjKiED(yCTWHgwQhUpgpgpLamCGItcN0heeLqckby4WSwpxxNAdcIXfxlZT6uljyRYavYxcD)xiNouj)JnqynW)26JQWfRzvIuL2rE5mc7y(DRo1gsNEoylIEeQ0q60ZbXpbJoIMHtPIHWHJucWWbDI4KGdlKyheepgpLamCGYufK6MAjbbrjKG2QB4vduMQGu3uljWRtzyO4ogpTv3WRgM16566uBGxNYWqsiHTkdujFdZA9CDDQnK8NpljMd3pUJ0MsagomR1Z11P2GGylZT6uljyRYavYxcD)xeim(O8hPL1YCRo1scKzJmmU6zeR)wxXHR8dRb(N2ucWWbRR4Wv(feeBzUvNAjbYSrggx9mIv6(VKo9mwd8pLamCqml5MGGOesqjadhiNouj)JnqbbXwMB1PwsGmBKHXvpJyLU)lUGw4UQUL(wMB1PwsGmBKHXvpJyLU)lw3yWDRo1IBgII16F8VTkdujFjTm3QtTKaz2idJREgXkD)xG5SStjqWPgLXs9mIv8b(hQ0qoIbDS0pB0rOsd5igs(ZNLi1yFu9mI1GoFmUw4qdhZbmEmE1ZiwdNSB0ZGOvLkgKMesOUHxnqCko1Q0ZaVoLHHIRL5wDQLeiZgzyC1ZiwP7)sYrzjxpXAG)T1hvHlwZQKFPDKsagoiMmKRvInor(aRltibbXJQB4vduMQGu3uljWRtzyOJucWWbktvqQBQLeGk57X4PnLamCywRNRRtTbbrjKaQ0qoIHK)8zjs9(X1YCRo1scKzJmmU6zeR09FjfwC3QtT4MHOyT(h)dp7qo5KG1a)BRpQcxSMvjXqtTm3QtTKaz2idJREgXkD)xsHf3T6ulUzikwR)X)r8YPRvsAzTm3QtTKa8Sd5KtYVyvg8KjLqAzSGReFzjP)hAzUvNAjb4zhYjNe6(Vq878igplpXAG)PeGHde)opIXZYZaujFBzUvNAjb4zhYjNe6(ViwLbpzsjKwgl4kXxws6)HwMB1PwsaE2HCYjHU)lI585gC5PRNyPEgXk(a)tezJbx9mIvsqmNp3GlpD9mMdhHknKJyi5pFwIuPPwMB1PwsaE2HCYjHU)lIvzWtMucPLXcUs8LLK(FOL5wDQLeGNDiNCsO7)IyoFUbxE66jwQNrSIpW)er2yWvpJyLeeZ5Zn4YtxpJ5hdTm3QtTKa8Sd5KtcD)xeRYGNmPeslJfCL4llj9)qlZT6uljap7qo5Kq3)LCeXs9mIv8b(N26yPF2ijKi(K)8zjs9hsiDDQLgIXqSJ7y8QNrSgoz3ONbrRgdgK2rARUHxnqCko1Q0ZaVoLHHItcjIp5pFwIu)HesxNAPHymC)JICsgIYRI)jy0r0mCgduPHCedIFcgDendNXDu9mI1GoFmUw4qdhZ9BzUvNAjb4zhYjNe6(ViwLbpzsjKwgl4kXxws6)HwMB1PwsaE2HCYjHU)le)opIXZYtSg4Fkby4aXVZJy8S8mK8NplrQhWqlZT6uljap7qo5Kq3)fXQm4jtkH0Yybxj(Yss)p0YCRo1scWZoKtoj09F5ZNpSg4Fkby4WK1IFVC5KGGylZT6uljap7qo5Kq3)fyol7uceCQrzS(CjHZlNry)FOL1YCRo1scr8YPRvs(tokl56jwd8V6gE1aLPki1n1sc86ugg6iLamCqmzixReBCI8bwxMqccIhPeGHduMQGu3uljavY3J26JQWfRzvYpnDeQ0q60ZHK)8zjsLMAzUvNAjHiE501kj09Fj5OSKRNynW)QB4vduMQGu3uljWRtzyOJucWWbktvqQBQLeGk57rkby4GyYqUwj24e5dSUmHeeepQUHxnyewpXNLioPRtTbEDkddDeQ0q60ZHK)8zjs9qlZT6uljeXlNUwjHU)luPG6gCIXjNynW)er2yWvpJyLeOsb1n4eJtoJbIjtYq4QNrSsAzUvNAjHiE501kj09FrSkdEYKsiTmwWvIVSK0)dTm3QtTKqeVC6ALe6(VONPtoXTUI1a)hFYWjtoDkdh3X4jISXGREgXkjONPtoXTUgdgIRL5wDQLeI4LtxRKq3)fXQm4jtkH0Yybxj(Yss)p0YCRo1scr8YPRvsO7)IEMo5e36kwd8F8QB4vdelVkEbJtzQckWRtzyOJucWWbILxfVGXPmvbfGk5BChjISXGREgXkjONPtoXTUgtSBzUvNAjHiE501kj09FrSkdEYKsiTmwWvIVSK0)dTm3QtTKqeVC6ALe6(VqKpImU1vSg4Fkby4aXYRIxW4uMQGccIhjISXGREgXkjqKpImU11yo0YCRo1scr8YPRvsO7)Iyvg8KjLqAzSGReFzjP)hAzUvNAjHiE501kj09FjD6zSupJyfFG)PTow6NnscjIN2QB4vduMQGu3uljWRtzyOJj)5ZsKkKq66ulneJHyh3r1Ziwd68X4AHdnCm0ulZT6uljeXlNUwjHU)lIvzWtMucPLXcUs8LLK(FOL5wDQLeI4LtxRKq3)L0PNXs9mIv8b(xDdVAGYufK6MAjbEDkddDKsagoqzQcsDtTKGG4X4Jp5pFwIu)VN4okYjzikVk(NGrhrZWzmqLgsNEoi(jy0r0mCsdXy4(slUJQNrSg05JX1chA4yOPwgTAK0)ONnsYvY3OJncZRy1i5CJS(2ibc3OVQw4j5gPvJi(DCJW8AJSNEgXeSAKBmL8zJAKaPrA1ikwvoBuYWjtoBu60ZTm3QtTKqeVC6ALe6(V8v1cpjJBDfRb(NsagoqzQcsDtTKGG4rkby4GyYqUwj24e5dSUmHeGk57rB9rv4I1SkrQsRL5wDQLeI4LtxRKq3)fQuqDdoX4KtSg4)4PeGHd6eXjbhwiXoiiEm(0hiC(oE1GdbrcZgt8hO7ZLeU90ZiMif7PNrmbhoDRo16M4OHjBp9mIX15JJlUwMB1PwsiIxoDTscD)x(QAHNKXTUIL6zeR4d8FYWjtoDkd3YCRo1scr8YPRvsO7)Iyvg8KjLqAzSGReFzjP)hAzUvNAjHiE501kj09FrptNCIBDfRb(pz4KjNoLHpgF83554ugoiqyC9mDY5pgogpTPeGHdZA9CDDQniikHeU0JZr5G8XaHdByYzYl0SrbEDkddfxCsibrKngC1Ziwjb9mDYjU11yoexlZT6uljeXlNUwjHU)l6z6KtCRRynW)jdNm50Pm8X78CCkdheimUEMo58)Wrkby4G1WEADIoBuiz3QhJN2ucWWHzTEUUo1geeLqcx6X5OCq(yGWHnm5m5fA2OaVoLHHIRL5wDQLeI4LtxRKq3)fXQm4jtkH0Yybxj(Yss)p0YCRo1scr8YPRvsO7)cr(iY4wxXAG)jISXGREgXkjqKpImU11yo0YCRo1scr8YPRvsO7)c5mziSg4FOsdPtphs(ZNLet8UvNAdKZKHc2IO05wDQnKo9CWwevk8Yze2Xj5GxoJWoKCeVsibLamCWAypTorNnkKSB1wwlJwn66j3OsKxoBueVC6gd2ncUmMsEJ0tUrMkASnQGBKEYnkzI2OcUr6j3ix0GvJOe0gnKgryrpDLHAujOn6KtUrWv2itfnw30iRXZrXULrRgj9Zns(ymnQe5TrYh9SrxLoSAe2LqJS(2iIdZgSBK1jAJ0ZH0i4S(Aerz3ONns(ONLG2iQKD6NnQrJgAzUvNAjHsKxo)1jItcoSqIDlJwnIMBK7ytAujYBJKp6zJsNEgRgzRLi8nBuJik7g9Sr(c1OA5gH51gzp9mIBu8dCJu3WRYqX1YCRo1scLiVCs3)L0PNXAG)PTow6NnscjOeGHdIzj3eeeBz0QrsUSsA0Ntp3iIqYnso3iEHAKEYnQe5LZgjzLWs2e41YswBK8tEBujKncEsI2OCeB0qAKow6Nnk0iP0iPpFHmmuJMv5CDJb7grHDJK(y6hZeAz0QrUvNAjHsKxoP7)YDEooLHXA9p(Ve5LtCOAzSUZnc8puPHCed6yPF2OwgTAeMj703OsqBub3i9KBKB1P2gzgI2iP0OT0gjqyOgrHDJK(y6hZeAz0QrUvNAjHsKxoP7)ICFuSiS9hJbmIXdynW)qLgYrmOJL(zJAz0QrsE4gjNB0PFh3ijxjpwnYxOgD63XlntBKlkAggQrJ2iSzTrceUrFvTWtYHwMB1PwsOe5Lt6(V8v1cpjJBDfRb(N26yPF2OwgTA0wnAzgQrA1i5(OncUYgjTgrdIvsJ8f7VkzSA09sGOnkhXg5luJKZnYtUrcInYxOgLc7oBulZT6uljuI8YjD)xeZ5Zn4YtxpXAG)PnuPHCed6yPF2OJUvN7yCE5VHjXCOL5wDQLekrE5KU)l5iI1a)tBDS0pBulJwnsYd3is9X65SrnkQysJKN1g1i5JE2i9KBujYlNnYxOgHDj0iJBPVr26JQAKynRsWQrrvJ8t2HOrTm3QtTKqjYlN09FHkfu3Gtmo5eRb(3T6ChJZl)nmjMdTm3QtTKqjYlN09FHiFezCRRynW)UvN7yCE5VHjXCOL5wDQLekrE5KU)lKZKHaV74Km1cUHbmEGgJXdyuAbmGbmCFWtUN7SreWt6NMlzUj5VjzbnQrn66j3O5tSsTrWv2iAgz2idJREgXknRrjlztysgQrK6JBKlO1NRmuJSN(gXKqltYDwUrXMg1ijlxIGOyLkd1i3QtTnIM5cAH7Q6w6PzHwwltY)jwPYqn6EAKB1P2gzgIscTmWZmeLaUcELiVCcUcUDaCf8CRo1cE6eXjbhwiXg841PmmeatGcUHbWvWJxNYWqambpBokNJdE0Ur6yPF2OgjHenIsagoiMLCtqqe8CRo1cEPtpduWTydUcE86uggcGj4zZr5CCWJ2nshl9ZgbEUvNAbVVQw4jzCRRafCJMaxbpEDkddbWe8S5OCoo4r7gbvAihXGow6NnQrhBKB15ogNx(BysJIPrhap3QtTGNyoFUbxE66jqb3Kg4k4XRtzyiaMGNnhLZXbpA3iDS0pBe45wDQf8YreOGBXc4k4XRtzyiaMGNnhLZXbp3QZDmoV83WKgftJoaEUvNAbpQuqDdoX4KtGcUDpGRGhVoLHHaycE2Cuohh8CRo3X48YFdtAumn6a45wDQf8iYhrg36kqb3Up4k45wDQf8iNjdbE86uggcGjqbk4bXWUGrbxb3oaUcE86uggcGj4zZr5CCWJ2nIsagoiMLCtqqSrhBeTBeLamCGC6qL8p2afeebp3QtTGhHEbJbNYjNafCddGRGhVoLHHaycE2Cuohh8ODJkrE5ehQwg8CRo1cEPWI7wDQf3mef8mdrXx)JbVsKxobk4wSbxbpEDkddbWe8CRo1cEPWI7wDQf3mef8mdrXx)JbpYSrggx9mIvGcuWtmzB9r5k4k42bWvWJxNYWqambk4ggaxbpEDkddbWeOGBXgCf841PmmeatGcUrtGRGhVoLHHaycE2Cuohh8u3WRgOmvbPUPwsGxNYWqGNB1PwWl5OSKRNafCtAGRGhVoLHHaycE35gbg8Wi45wDQf8UZZXPmm4DNN4R)XGNaHX1Z0jNafClwaxbpEDkddbWe8CRo1cE3554ugg8UZncm4HbWZMJY54GNl94CuoiFmq4WgMCM8cnBuGxNYWqG3DEIV(hdEcegxptNCcuWT7bCf8CRo1cEIzj3aE86uggcGjqb3Up4k45wDQf8SUIdx5h4XRtzyiaMafCJgdUcE86uggcGjqb3oGrWvWZT6ul4jw6ul4XRtzyiaMafC7WbWvWZT6ul4rXjHt6bpEDkddbWeOaf8I4LtxRKaUcUDaCf841PmmeatWZMJY54GN6gE1aLPki1n1sc86uggQrhBeLamCqmzixReBCI8bwxMqccIn6yJOeGHduMQGu3uljavY3gDSr26JQWfRzvsJ(Ben1OJncQ0q60ZHK)8zjnsQnIMap3QtTGxYrzjxpbk4ggaxbpEDkddbWe8S5OCoo4PUHxnqzQcsDtTKaVoLHHA0XgrjadhOmvbPUPwsaQKVn6yJOeGHdIjd5ALyJtKpW6YesqqSrhBK6gE1Gry9eFwI4KUo1g41PmmuJo2iOsdPtphs(ZNL0iP2OdGNB1PwWl5OSKRNafCl2GRGhVoLHHaycE2Cuohh8iISXGREgXkjqLcQBWjgNC2OyAeetMKHWvpJyLaEUvNAbpQuqDdoX4KtGcUrtGRGhVoLHHaycEWvIVSKuWTdGNB1PwWtSkdEYKsiTmqb3Kg4k4XRtzyiaMGNnhLZXbV4BuYWjtoDkd3O4A0XgfFJiISXGREgXkjONPtoXTU2OyAegAuCGNB1PwWtptNCIBDfOGBXc4k4XRtzyiaMGhCL4lljfC7a45wDQf8eRYGNmPeslduWT7bCf841PmmeatWZMJY54Gx8nsDdVAGy5vXlyCktvqbEDkdd1OJnIsagoqS8Q4fmoLPkOaujFBuCn6yJiISXGREgXkjONPtoXTU2OyAuSbp3QtTGNEMo5e36kqb3Up4k4XRtzyiaMGhCL4lljfC7a45wDQf8eRYGNmPeslduWnAm4k4XRtzyiaMGNnhLZXbpkby4aXYRIxW4uMQGccIn6yJiISXGREgXkjqKpImU11gftJoaEUvNAbpI8rKXTUcuWTdyeCf841PmmeatWdUs8LLKcUDa8CRo1cEIvzWtMucPLbk42HdGRGhVoLHHaycE2Cuohh8ODJ0Xs)SrnscjAu8nI2nsDdVAGYufK6MAjbEDkdd1OJnk5pFwsJKAJGesxNABenSryme7gfxJo2i1Ziwd68X4AHdnCJIPr0e45wDQf8sNEgOGBhWa4k4XRtzyiaMGhCL4lljfC7a45wDQf8eRYGNmPeslduWTdXgCf841PmmeatWZMJY54GN6gE1aLPki1n1sc86uggQrhBeLamCGYufK6MAjbbXgDSrX3O4BuYF(SKgj1)gDpnkUgDSrICsgIYRI)jy0r0mC2OyAeuPH0PNdIFcgDendNnIg2imgUV0AuCn6yJupJynOZhJRfo0WnkMgrtGNB1PwWlD6zGcUDGMaxbpEDkddbWe8S5OCoo4rjadhOmvbPUPwsqqSrhBeLamCqmzixReBCI8bwxMqcqL8TrhBKT(OkCXAwL0iP2iPbEUvNAbVVQw4jzCRRafC7G0axbpEDkddbWe8S5OCoo4fFJOeGHd6eXjbhwiXoii2OJnk(gL(aHZ3XRgCiisy2gftJIVrhAeDn6ZLeU90ZiM0iP0i7PNrmbhoDRo16MgfxJOHnkz7PNrmUoFCJIRrXbEUvNAbpQuqDdoX4KtGcUDiwaxbpEDkddbWe8S5OCoo4LmCYKtNYWGNB1PwW7RQfEsg36kqb3oCpGRGhVoLHHaycEWvIVSKuWTdGNB1PwWtSkdEYKsiTmqb3oCFWvWJxNYWqambpBokNJdEjdNm50PmCJo2O4Bu8n6ophNYWbbcJRNPtoB0FJWqJo2O4BeTBeLamCywRNRRtTbbXgjHenYLECokhKpgiCydtotEHMnkWRtzyOgfxJIRrsirJiISXGREgXkjONPtoXTU2OyA0Hgfh45wDQf80Z0jN4wxbk42bAm4k4XRtzyiaMGNnhLZXbVKHtMC6ugUrhB0DEooLHdcegxptNC2O)gDOrhBeLamCWAypTorNnkKSB1gDSrX3iA3ikby4WSwpxxNAdcInscjAKl94CuoiFmq4WgMCM8cnBuGxNYWqnkoWZT6ul4PNPtoXTUcuWnmGrWvWJxNYWqambp4kXxwsk42bWZT6ul4jwLbpzsjKwgOGBy4a4k4XRtzyiaMGNnhLZXbpIiBm4QNrSsce5JiJBDTrX0OdGNB1PwWJiFezCRRafCddyaCf841PmmeatWZMJY54GhuPH0PNdj)5ZsAumnk(g5wDQnqotgkylI2i6AKB1P2q60ZbBr0gjLgXlNry3O4AKKJgXlNryhsoI3gjHenIsagoynSNwNOZgfs2Tk45wDQf8iNjdbuGcEWZoKtojGRGBhaxbpEDkddbWe8GReFzjPGBhap3QtTGNyvg8KjLqAzGcUHbWvWJxNYWqambpBokNJdEucWWbIFNhX4z5zaQKVGNB1PwWJ435rmEwEcuWTydUcE86uggcGj4bxj(Yssb3oaEUvNAbpXQm4jtkH0YafCJMaxbpEDkddbWe8S5OCoo4rezJbx9mIvsqmNp3GlpD9SrX0Odn6yJGknKJyi5pFwsJKAJOjWZT6ul4jMZNBWLNUEcuWnPbUcE86uggcGj4bxj(Yssb3oaEUvNAbpXQm4jtkH0YafClwaxbpEDkddbWe8S5OCoo4rezJbx9mIvsqmNp3GlpD9SrX83imaEUvNAbpXC(CdU801tGcUDpGRGhVoLHHaycEWvIVSKuWTdGNB1PwWtSkdEYKsiTmqb3Up4k4XRtzyiaMGNnhLZXbpA3iDS0pBuJKqIgfFJs(ZNL0iP(3iiH01P2grdBegdXUrX1OJnk(gPEgXA4KDJEgeTAJIPryqAn6yJODJu3WRgiofNAv6zGxNYWqnkUgjHenk(gL8NplPrs9VrqcPRtTnIg2imgUFJo2irojdr5vX)em6iAgoBumncQ0qoIbXpbJoIMHZgfxJo2i1Ziwd68X4AHdnCJIPr3h8CRo1cE5icuWnAm4k4XRtzyiaMGhCL4lljfC7a45wDQf8eRYGNmPeslduWTdyeCf841PmmeatWZMJY54GhLamCG435rmEwEgs(ZNL0iP2Odya8CRo1cEe)opIXZYtGcUD4a4k4XRtzyiaMGhCL4lljfC7a45wDQf8eRYGNmPeslduWTdyaCf841PmmeatWZMJY54GhLamCyYAXVxUCsqqe8CRo1cEF(8buWTdXgCf8(CjHZlNrydEhap3QtTGhmNLDkbco1Om4XRtzyiaMafOGNTkdujFjGRGBhaxbpEDkddbWe8S5OCoo4XlNry3Oy(BuSXyJo2O4BKTkdujFd6eXjbhwiXoK8NplPrX0iP1ijKOrucWWbDI4KGdlKyheeBuCGNB1PwWJItcN0duWnmaUcE86uggcGj4zZr5CCWJxoJWoaXWJD0gfZFJIfm2OJnIsagoOteNeCyHe7aujFbp3QtTGNorCsWHfsSbk4wSbxbp3QtTGhfNeoPF2iWJxNYWqambk4gnbUcE86uggcGj4zZr5CCWZwFufUynRsA0FJWi45wDQf8G50n4WjVspSbk4M0axbpEDkddbWe8S5OCoo4XlNry3Oy(BuSXyJo2O4BKTkdujFd6eXjbhwiXoK8NplPrX0OdsRrsirJOeGHd6eXjbhwiXoii2O4ap3QtTG3SwpxxNAbk4wSaUcE86uggcGj4zZr5CCWt9mI1GoFmUw4qd3iP2OyrAnscjAu8nsNpgxlCOHBKuB0H7JXgDSrX3ikby4afNeoPpii2ijKOrucWWHzTEUUo1geeBuCnkoWtS0PwWJYv1W4ILo1IxW4E0ygfBWZT6ul4jw6ulqb3UhWvWJxNYWqambpBokNJdE26JQWfRzvsJKAJKwJo2iE5mc7gfZFJCRo1gsNEoylI2OJncQ0q60ZbXpbJoIMHZgj1gHHWHgDSrucWWbDI4KGdlKyheeB0XgfFJOeGHduMQGu3uljii2ijKOr0UrQB4vduMQGu3uljWRtzyOgfxJo2O4BeTBK6gE1WSwpxxNAd86uggQrsirJSvzGk5BywRNRRtTHK)8zjnkMgD4(nkUgDSr0UrucWWHzTEUUo1geebp3QtTGh50Hk5FSbcOGB3hCf8CRo1cEcegFu(JaE86uggcGjqbk4rMnYW4QNrScUcUDaCf841PmmeatWZMJY54GhTBeLamCW6koCLFbbrWZT6ul4zDfhUYpGcUHbWvWJxNYWqambpBokNJdEucWWbXSKBccInscjAeLamCGC6qL8p2afeebp3QtTGx60ZafCl2GRGNB1PwWZf0c3v1T0dE86uggcGjqb3OjWvWJxNYWqambp3QtTGN1ngC3QtT4MHOGNzik(6Fm4zRYavYxcqb3Kg4k4XRtzyiaMGNnhLZXbpOsd5ig0Xs)Srn6yJGknKJyi5pFwsJKAJIDJo2i1Ziwd68X4AHdnCJIPrhWyJo2O4BK6zeRHt2n6zq0QnsQncdsRrsirJu3WRgiofNAv6zGxNYWqnkoWZT6ul4bZzzNsGGtnkduWTybCf841PmmeatWZMJY54GNT(OkCXAwL0O)gjTgDSrucWWbXKHCTsSXjYhyDzcjii2OJnsDdVAGYufK6MAjbEDkdd1OJnIsagoqzQcsDtTKaujFB0XgfFJODJOeGHdZA9CDDQnii2ijKOrqLgYrmK8NplPrsTr3VrXbEUvNAbVKJYsUEcuWT7bCf841PmmeatWZMJY54GNT(OkCXAwL0OyAenbEUvNAbVuyXDRo1IBgIcEMHO4R)XGh8Sd5Ktcqb3Up4k4XRtzyiaMGNB1PwWlfwC3QtT4MHOGNzik(6Fm4fXlNUwjbOafOGNlONvcEV5JgauGca]] )
end