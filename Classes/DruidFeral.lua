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
        heart_of_the_wild = 3053, -- 236019
        king_of_the_jungle = 602, -- 203052
        leader_of_the_pack = 3751, -- 202626
        malornes_swiftness = 601, -- 236012
        protector_of_the_grove = 847, -- 209730
        rip_and_tear = 620, -- 203242
        savage_momentum = 820, -- 205673
        thorns = 201, -- 236696
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
            duration = 16,
            tick_time = function() return 2 * haste end,
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
            duration = 15,
            tick_time = function() return 3 * haste end,
        },
        regrowth = { 
            id = 8936, 
            duration = 12,
        },
        rip = {
            id = 1079,
            duration = 24,
            tick_time = function() return 2 * haste end,
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
            duration = 15,
            tick_time = function() return 3 * haste end,
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
                local x = 10 -- Base Duration
                if talent.predator.enabled then return x + 5 end
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


    -- Snapshotting
    local tf_spells = { rake = true, rip = true, thrash_cat = true, moonfire_cat = true, primal_wrath = true }
    local bt_spells = { rake = true, rip = true, thrash_cat = true, primal_wrath = true }
    local mc_spells = { thrash_cat = true }
    local pr_spells = { rake = true }
    
    local snapshot_value = {
        tigers_fury = 1.15,
        bloodtalons = 1.25,
        clearcasting = 1.15, -- TODO: Only if talented MoC, not used by 8.1 script
        prowling = 2
    }


    --[[ local modifiers = {
        [1822]   = 155722,
        [1079]   = 1079,
        [106830] = 106830,
        [8921]   = 155625
    } ]] -- ??
    

    local stealth_dropped = 0

    local function calculate_multiplier( spellID )

        local tigers_fury = FindUnitBuffByID( "player", class.auras.tigers_fury.id, "PLAYER" ) and snapshot_value.tigers_fury or 1
        local bloodtalons = FindUnitBuffByID( "player", class.auras.bloodtalons.id, "PLAYER" ) and snapshot_value.bloodtalons or 1
        local clearcasting = FindUnitBuffByID( "player", class.auras.clearcasting.id, "PLAYER" ) and state.talent.moment_of_clarity.enabled and snapshot_value.clearcasting or 1
        local prowling = ( GetTime() - stealth_dropped < 0.2 or FindUnitBuffByID( "player", class.auras.incarnation.id, "PLAYER" ) ) and snapshot_value.prowling or 1     

        if spellID == 155722 then
            return 1 * bloodtalons * tigers_fury * prowling

        elseif spellID == 1079 or spellID == 285381 then
            return 1 * bloodtalons * tigers_fury

        elseif spellID == 106830 then
            return 1 * bloodtalons * tigers_fury * clearcasting

        elseif spellID == 155625 then
            return 1 * tigers_fury

        end

        return 1
    end

    spec:RegisterStateExpr( 'persistent_multiplier', function ()
        local mult = 1

        if not this_action then return mult end

        if tf_spells[ this_action ] and buff.tigers_fury.up then mult = mult * snapshot_value.tigers_fury end
        if bt_spells[ this_action ] and buff.bloodtalons.up then mult = mult * snapshot_value.bloodtalons end
        if mc_spells[ this_action ] and buff.clearcasting.up then mult = mult * snapshot_value.clearcasting end
        if pr_spells[ this_action ] and ( buff.incarnation.up or buff.prowl.up or buff.shadowmeld.up or state.query_time - stealth_dropped < 0.2 ) then mult = mult * snapshot_value.prowling end

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
            elseif subtype == "SPELL_CAST_SUCCESS" and ( spellID == class.abilities.rip.id or spellID == class.abilities.primal_wrath.id or spellID == class.abilities.ferocious_bite.id or spellID == class.abilities.maim.id or spellID == class.abilities.savage_roar.id ) then
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
            
            notalent = "incarnation",

            toggle = "cooldowns",

            handler = function ()
                if buff.cat_form.down then shift( "cat_form" ) end
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
                if talent.sabertooth.enabled and debuff.rip.up then
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

                opener_done = true
                
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
                if buff.cat_form.down then shift( "cat_form" ) end
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

                opener_done = true
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
            
            usable = function () return time == 0 or ( boss and buff.jungle_stalker.up ) end,

            readyTime = function () return buff.jungle_stalker.remains - 0.5 end,

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
            
            spend = function () return 25 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
            spendType = "energy",
            
            startsCombat = false,
            texture = 236167,
            
            talent = "savage_roar",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end

                local cost = min( 5, combo_points.current )
                spend( cost, "combo_points" )
                if buff.savage_roar.down then energy.regen = energy.regen * 1.1 end
                applyBuff( "savage_roar", 6 + ( 6 * cost ) )

                opener_done = true
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
            
            debuff = "casting",
            readyTime = state.timeToInterrupt,

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

            toggle = "interrupts",
            
            startsCombat = false,
            texture = 132163,
            
            usable = function () return debuff.dispellable_enrage.up end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
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


    spec:RegisterPack( "Feral", 20190202.0115, [[dW0E7aqivKEKqIlrjuQnju(eqOgLqQtjuzvcv5vQOMfuLBrjyxu8lvWWOK4yukldQuptOQMgLqUMqsBdiOVbvcJJskohqG1bvs9okHsMhLuDpOyFuIoiLKYcHkEiujAIusQUiLqHnsjjFeiKYjbcHvkeZeiK0ovH(jLqrdLskTuOsYtvPPcuUkqi6RaHuTxq)vrdgPdt1IH4XcMmGlJAZq6Zk0OHsNwQvtju51uQMnPUTc2Ts)w0WjXXbcjwUKNJy6exNK2UkIVdunEGOZdv16PeQA(aP9RQH2GGbVaUWWJ42k2abwb3wb3gRyZgUWISbVc(km8Q4b7(idVRpWWRvXLRHxfhFD6aqWGxsQwbgEXkIcbxF4WylyvrmHC4aPhu1U05gkhvoq6HWbeDICab1TaaFYbLkrBntoyTfJR8gGCWAXvtREP2atRIlxBi9qaEruBTaIyHiWlGlm8iUTInqGvSHBRXydeevqy8Xn8su4a8OnReF4fBdaWlebEbysaEJYtTkUC9tT6LAd8rIYtXkIcbxF4WylyvrmHC4aPhu1U05gkhvoq6HWbeDICab1TaaFYbLkrBntoyTfJR8gGCWAXvtREP2atRIlxBi9q4JeLNAvmsP6f(pf349uCBfBGGNAHNAfB4ABr9J8rIYtXLy9DKj46psuEQfEQvdaGbE61UQw)uCCcwZhjkp1cp1QbaWapfNsvC9tVANG9Wf8wHFQKpnv4LRN27thu1sBbXRrwmFKO8ul8uRv7bg4P4sxEQvL1WtDuHRNATvcU(PKEd8tT2kbx)uP6XrUipfx6YtTQSgmFKO8ul8uCfRDqYapfSEKlqm5PwLAH)t5LRr8FAalhS)ujFQROOX)P5QX)PGJL3NcwpYfiM8uRsTW)Pn5PUUyha)NQQy(ir5Pw4PPcVCnbYLFAtEkwFb0mWt7v4ADTg)NIG)tfS8tDaGCTy90IhYtyGNkyzc)0t8QDentmp9Pwmxn(pfjfSC90EFkssipfThXkeZhjkp1cpfxILd2FkAwpv8AKLNgs1vEkAwpLaERWZGlpT3NoYlxUKf5P6Mip1cw4PBkp1ItLip9g4vEAI(uC0zcy(ir5Pw4Pwnaag4PiEWUQYtv0((u0SEAQWlxMpsuEQfEkissVJp9IDitRUkadIjpLbAHyGxLkrBndVr5PwfxU(Pw9sTb(ir5PyfrHGRpCySfSQiMqoCG0dQAx6CdLJkhi9q4aIoroGG6waGp5GsLOTMjhS2IXvEdqoyT4QPvVuBGPvXLRnKEi8rIYtTkgPu9c)NIB8EkUTInqWtTWtTInCTTO(r(ir5P4sS(oYeC9hjkp1cp1QbaWap9AxvRFkoobR5JeLNAHNA1aayGNItPkU(PxTtWE4cERWpvYNMk8Y1t79PdQAPTG41ilMpsuEQfEQ1Q9ad8uCPlp1QYA4PoQW1tT2kbx)usVb(PwBLGRFQu94ixKNIlD5PwvwdMpsuEQfEkUI1oizGNcwpYfiM8uRsTW)P8Y1i(pnGLd2FQKp1vu04)0C14)uWXY7tbRh5cetEQvPw4)0M8uxxSdG)tvvmFKO8ul80uHxUMa5YpTjpfRVaAg4P9kCTUwJ)trW)Pcw(PoaqUwSEAXd5jmWtfSmHF6jE1oIMjMN(ulMRg)NIKcwUEAVpfjjKNI2JyfI5JeLNAHNIlXYb7pfnRNkEnYYtdP6kpfnRNsaVv4zWLN27th5LlxYI8uDtKNAbl80nLNAXPsKNEd8kpnrFko6mbmFKO8ul8uRgaad8uepyxv5PkAFFkAwpnv4LlZhjkp1cpfejP3XNEXoKPvxfGbXKNYaTqmFKpsuEQfdqYbvHbEkcJMf)0qoG4Ytr4XEjMNA1cbwripDZ1cy9Aavv)upiDUKNMRgFZhXdsNlXOuCihqCbdQ2j2)iEq6CjgLId5aIlNXCantGpIhKoxIrP4qoG4YzmhC1XbEfx6C)iEq6CjgLId5aIlNXC4eVAhrZ4T(aJPALP0b7e8oX1QmgR5J4bPZLyukoKdiUCgZHIhReCblEnkgX18kgeDMaIRZLy41r0mWhXdsNlXOuCihqC5mMdkvcU(J4bPZLyukoKdiUCgZHGlt0Sg(iEq6CjgLId5aIlNXCGSUcbBktI4c5J4bPZLyukoKdiUCgZbLu6C)iEq6CjgLId5aIlNXCaHlcx2)iFKO8ulgGKdQcd8u(eUW)PspWpvWYp1dswpTjp1pXBTJOzZhXdsNlbJRk50fXd2XRrXCkIkkQrPsW1gvLyNIOIIAiyDGe8bwdyuv(iEq6CjNXCGyxvRNiob7hXdsNl5mMdbxRNEq6CN6Mi4T(aJjv4Ll8AumNMk8Y1eixow0iQOOgeUiCz3OQakOiQOOMEdETU05AuvI7J4bPZLCgZHGlt0SgWRrXCkIkkQj4YenRbJQYhXdsNl5mMdLBNXRrXGOIIAuQeCTrvbuqrurrneSoqc(aRbmQkFepiDUKZyoeCTE6bPZDQBIG36dmMqMAGe8L8r8G05soJ5akxzOtvYePfgpXRrwMnkgX18kgIJWLKPG1WRJOzGyHCajNkzVcXsIcR1tXRrwigbB5eSZGlXasXuTIr6G9EhJbKIPAftXdEVeRh)yIxJSyKEGNsobA2sGumvRykEW7LC(eVAhrZMQvMshStINhKoxt1kgPd2NspWFepiDUKZyoeCTE6bPZDQBIG36dmg0EBcwUi41Oyc5asovYEfILw0hXdsNl5mMdbxRNEq6CN6Mi4T(aJzKxUCjlY0tgVgftihqYPs2RqSEuJruyTEkEnYcXiylNGDgCXsBFepiDUKZyoeCTE6bPZDQBIG36dmMrE5YLSi41Oyc5asovYEfI1J6h5J4bPZLyczQbsWxcgeUiCzhVgfdVCnIVLyIVvIfDitnqc(AKEKlYevTW3u8G3lXYOckOHm1aj4Rr6rUitu1cFtXdEVeRBlUpIhKoxIjKPgibFjNXCO3GxRlDU41Oy4LRr8Tet8TYhXdsNlXeYudKGVKZyoOs4zl8abVgfdIkkQr6rUitu1cFJQYhXdsNlXeYudKGVKZyoi9ixKjQAHpEnkgE5AeFdaJ2HwSetuTcOGIOIIAKEKlYevTW3aKGVFepiDUetitnqc(soJ5acxeUS374hXdsNlXeYudKGVKZyoOKPEwmjvRaJhAwZLbPGX2hXdsNlXeYudKGVKZyoGYLRNOfVw84JxJIjKdi5uj7viySYhXdsNlXeYudKGVKZyoOKsNlERpWyqCr08ujLo3zIo9Xw3c(41OyeVgzXi9apLCc0S1bHrfuqJw6bEk5eOzRBZASsSOrurrniCr4YUrvbuqrurrn9g8ADPZ1OQexCFepiDUetitnqc(soJ5abRdKGpWAa8AumHCajNkzVcX6rngVCnIVLy8G05Ak3oBcjrIbKIPC7SrzqvlTIU5Y642ylgIkkQr6rUitu1cFJQsSOrurrni6mbexNlXOQakONkUMxXGOZeqCDUedVoIMbIlw0NkUMxX0BWR1LoxdVoIMbaf0qMAGe810BWR1LoxtXdEVelTznXf7uevuutVbVwx6CnQkFKpIhKoxIbT3MGLlcMIhReCblEnkgevuuJsXaUKf(tc4nQSmHyuvIjUMxXGOZeqCDUedVoIMbIHOIIAq0zciUoxIHiEWU1X9hXdsNlXG2BtWYf5mMdkzQNfts1kW4HM1CzqkyS9r8G05smO92eSCroJ5aXpXh5zLEHxJIbrff1q8t8rEwPxgGe89J4bPZLyq7Tjy5ICgZbLm1ZIjPAfy8qZAUmifm2(iEq6Cjg0EBcwUiNXCqP6bxpbVCblEIxJSmBumefwRNIxJSqmkvp46j4LlyT02zX18kgIJWLKPG1WRJOzGpIhKoxIbT3MGLlYzmhuYuplMKQvGXdnR5YGuWy7J4bPZLyq7Tjy5ICgZHQvWt8AKLzJI5uX18kgIJWLKPG1WRJOzGyfJwmbRJO5yIxJSyKEGNsobA2sGumvRykEW7LC(eVAhrZMQvMshStINhKoxt1kgPd2NspWFepiDUedAVnblxKZyoOKPEwmjvRaJhAwZLbPGX2hXdsNlXG2BtWYf5mMdvRGN41ilZgfJ4AEfdXr4sYuWA41r0mqSOpv6G9Ehbf0Ih8EjwhdGA5sNB8SIj(Xu4I0eHxzoOQLwr3CzjqkMQvmkdQAPv0nxXft8AKfJ0d8uYjqZwcKIPAftXdEVKZN4v7iA2uTYu6GDs8I22zGumvRyKoyV3X4f)4INhKoxt1kgPd2NspWFepiDUedAVnblxKZyoOKPEwmjvRaJhAwZLbPGX2hXdsNlXG2BtWYf5mMde)eFKNv6fEnkgevuudXpXh5zLEzkEW7LyDB4(J4bPZLyq7Tjy5ICgZbLm1ZIjPAfy8qZAUmifm2(iEq6Cjg0EBcwUiNXCyW7b8AumiQOOMUYDAX5GtmQkFepiDUedAVnblxKZyoOKPEwmjvRaJhAwZLbPGX2hXdsNlXG2BtWYf5mMdOCLHovjtKwy8gCqo5LRr8Xy7J8r8G05smJ8YLlzrWCIxTJOz8wFGXuUDEkcaEN4Avgt02ohnrH16P41ileJGTCc2zWflylU4DQ4AEfdsPkUEs0obRHxhrZaXfppiDUMYTZgPd2NspWFepiDUeZiVC5swKZyou8yLGlyXRrXiUMxXGOZeqCDUedVoIMbIHOIIAukgWLSWFsaVrLLjeJQsmevuudIotaX15smaj4BSqoGKtLSxHGXIIbKIPC7SP4bVxI1TOyIxJSyKEGNsobA2sGumLBNnfp49soFIxTJOzt525PiaFepiDUeZiVC5swKZyoOKPEwmjvRaJhAwZLbPGX2hXdsNlXmYlxUKf5mMdLBNXt8AKLzJIj6tLoyV3rqb9uX18kgeDMaIRZLy41r0mqSIrlMG1r0CCXeVgzXi9apLCc0SLaPyk3oBkEW7LC(eVAhrZMYTZtra(iEq6CjMrE5YLSiNXCqjt9SysQwbgp0SMldsbJTpIhKoxIzKxUCjlYzmhk3oJN41ilZgfJ4AEfdIotaX15sm86iAgigIkkQbrNjG46CjgvLyfp49sSogCrmfUinr4vMdQAPv0nxwcKIPC7SrzqvlTIU5kEwXynrnM41ilgPh4PKtGMTeift52ztXdEVKZN4v7iA2uUDEkcWhXdsNlXmYlxUKf5mMdkzQNfts1kW4HM1CzqkyS9r8G05smJ8YLlzroJ5asPkUEs0oblEnkMOrurrnspYfzIQw4Buvaf0Ody9AKjwIb3XczQbsWxJ0JCrMOQf(MIh8EjwIQQ1ZIdy9AKNspWXfxSYBGjFcVIXbaiMETevvRNfhW61ipLEG)iEq6CjMrE5YLSiNXCqjt9SysQwbgp0SMldsbJTpIhKoxIzKxUCjlYzmhgYCr7INbxWt8AKLzJIPy0IjyDenht8AKfJ0d8uYjqZww8G3l5C04(mUJx0efwRNIxJSqmc2YjyNbxSGT4I3PIR5vmiLQ46jr7eSgEDendex8asXmK5I2fpdUyKoyFk9a)r8G05smJ8YLlzroJ5GsM6zXKuTcmEOznxgKcgBFepiDUeZiVC5swKZyoiylNGDgCbVgftXOftW6iAow0efwRNIxJSqmc2YjyNbxS0gOGgTBXZvlSb8wdmr1mbBXlqVJgEDendet8AKfJ0d8uYjqZww8G3l5ShKoxJGTCc2zWfJ0b7tPh44I7J4bPZLyg5LlxYICgZbLm1ZIjPAfy8qZAUmifm2(iEq6CjMrE5YLSiNXCGaERWZGl41OyikSwpfVgzHyiG3k8m4IL2(iEq6CjMrE5YLSiNXCqjt9SysQwbgp0SMldsbJTpIhKoxIzKxUCjlYzmhiylgaVgfdqkMYTZMIh8EjwgThKoxdbBXaMqsKZEq6CnLBNnHKiwGxUgXpol28Y1i(MIh5fuqrurrnbn7vWjsVJMI9GakONgT41ilgPh4PKtGMTeift52ztXdEVKZN4v7iA2uUDEkcqCFKpIhKoxIzKxUCjlY0tgJsM6zXKuTcmEOznxgKcgBFepiDUeZiVC5swKPN8zmheSLtWodUGxJIPy0IjyDenhJOWA9u8AKfIrWwob7m4IL4guqfxZRyibELzIor0zcy41r0mqmevuudjWRmt0jIotadqc(gJOWA9u8AKfIrWwob7m4ILX)J4bPZLyg5LlxYIm9KpJ5GsM6zXKuTcmEOznxgKcgBFepiDUeZiVC5swKPN8zmhqkvX1tI2jyXRrXquyTEkEnYcXGuQIRNeTtWAjat6IbMIxJSq(iEq6CjMrE5YLSitp5ZyoOKPEwmjvRaJhAwZLbPGX2hXdsNlXmYlxUKfz6jFgZbc4TcpdUGxJIbrff1qc8kZeDIOZeWOQ8r(iEq6CjMuHxUWi9ixKjQAH)hXdsNlXKk8Y1zmhk3oJxJI5uPd27DeuqrurrnkvcU2OQ8r8G05smPcVCDgZHHmx0U4zWf8AumNkDWEVJFepiDUetQWlxNXCqP6bxpbVCblEnkgpi9j8KxEOzIL2IfYbKCQK9kelTflAevuuJ0JCrMOQf(gvLyrJOIIAq0zciUoxIrvbuqpvCnVIbrNjG46CjgEDendexSOpvCnVIrRUEn7LO0LlDUgEDendakOaPygYCr7INbxmshS37yCXov6G9EhJ7J4bPZLysfE56mMdvRGxJIXdsFcp5LhAMGXwSOrurrnspYfzIQw4BuvIfnIkkQbrNjG46Cjgvfqb9uX18kgeDMaIRZLy41r0mqCXasXuUD2iDWEVJXI(uX18kgT661SxIsxU05A41r0maOGcKIziZfTlEgCXiDWEVJXf7uPd27Dmo49eUiDUWJ42k2abwXgUJVXMvSiqi8cUxBVJe4feDRgU6iiIJGOHRF6tbdl)0Eqjl5POz9uqmaJ6QAbe)0IbrrTlg4PKCGFQRk5GlmWtdy9DKjMpciQ9Yp1gU(PGixIQIswcd8upiDUpfe7QsoDr8GDqS5J8rarmOKLWapfx8upiDUpv3eHy(iWRUjcbcg8Mk8Yfem4rBqWGxpiDUWR0JCrMOQf(WlVoIMbG4af4rCdbdE51r0maeh4nuTWv7W7Ppv6G9EhFkOG(uevuuJsLGRnQkWRhKox4TC7muGhJpem4LxhrZaqCG3q1cxTdVEq6t4jV8qZKNA5tT90ypnKdi5uj7vip1YNA7PXEA0pfrff1i9ixKjQAHVrv5PXEA0pfrff1GOZeqCDUeJQYtbf0NE6tfxZRyq0zciUoxIHxhrZapnUNg7Pr)0tFQ4AEfJwD9A2lrPlx6Cn86iAg4PGc6tbsXmK5I2fpdUyKoyV3XNg3tJ90tFQ0b79o(04GxpiDUWRs1dUEcE5cwOapArqWGxEDendaXbEdvlC1o86bPpHN8YdntEkMNA7PXEA0pfrff1i9ixKjQAHVrv5PXEA0pfrff1GOZeqCDUeJQYtbf0NE6tfxZRyq0zciUoxIHxhrZapnUNg7PaPyk3oBKoyV3XNg7Pr)0tFQ4AEfJwD9A2lrPlx6Cn86iAg4PGc6tbsXmK5I2fpdUyKoyV3XNg3tJ90tFQ0b79o(04GxpiDUWB1kqbkW7iVC5swKPNmem4rBqWGxEDendaXbErZAUmif4rBWRhKox4vjt9SysQwbgkWJ4gcg8YRJOzaioWBOAHR2H3IrlMG1r08tJ9uIcR1tXRrwigbB5eSZGlp1YNI7NckOpvCnVIHe4vMj6erNjGHxhrZapn2trurrnKaVYmrNi6mbmaj47tJ9uIcR1tXRrwigbB5eSZGlp1YNgF41dsNl8kylNGDgCbkWJXhcg8YRJOzaioWlAwZLbPapAdE9G05cVkzQNfts1kWqbE0IGGbV86iAgaId8gQw4QD4LOWA9u8AKfIbPufxpjANG9Pw(uaM0fdmfVgzHaVEq6CHxKsvC9KODcwOapgviyWlVoIMbG4aVOznxgKc8On41dsNl8QKPEwmjvRadf4rqiem4LxhrZaqCG3q1cxTdViQOOgsGxzMOteDMagvf41dsNl8saVv4zWfOaf4fGrDvTabdE0gem4LxhrZaqCG3q1cxTdVN(uevuuJsLGRnQkpn2tp9PiQOOgcwhibFG1agvf41dsNl86QsoDr8GDOapIBiyWRhKox4LyxvRNiobl8YRJOzaioqbEm(qWGxEDendaXbE9G05cVbxRNEq6CN6MiWBOAHR2H3tFAQWlxtGC5Ng7Pr)0OFAitnqc(Aq4IWLDtXdEVKNA5tTYtbf0NIOIIAq4IWLDJQYtJ7PGc6trurrn9g8ADPZ1OQ804GxDtK56dm8Mk8YfuGhTiiyWlVoIMbG4aVHQfUAhEp9PiQOOMGlt0SgmQkWRhKox4n4YenRbOapgviyWlVoIMbG4aVHQfUAhErurrnkvcU2OQ8uqb9PiQOOgcwhibFG1agvf41dsNl8wUDgkWJGqiyWlVoIMbG4aVEq6CH3GR1tpiDUtDte4v3ezU(adVHm1aj4lbkWJ4ciyWlVoIMbG4aVHQfUAhEfxZRyiocxsMcwdVoIMbEASNgYbKCQK9kKNA5tjkSwpfVgzHyeSLtWodU80ypfift1kgPd27D8PXEkqkMQvmfp49sEQ1FA8FASNkEnYIr6bEk5eO5NA5tbsXuTIP4bVxYtp)0t8QDenBQwzkDWo5PX7PEq6CnvRyKoyFk9adVEq6CHxuUYqNQKjslmuGhTgiyWlVoIMbG4aVEq6CH3GR1tpiDUtDte4nuTWv7WBihqYPs2RqEQLp1IGxDtK56dm8I2BtWYfbkWJGaiyWlVoIMbG4aVEq6CH3GR1tpiDUtDte4nuTWv7WBihqYPs2RqEQ1FAuFASNsuyTEkEnYcXiylNGDgC5Pw(uBWRUjYC9bgEh5LlxYIm9KHc8OnRabdE51r0maeh41dsNl8gCTE6bPZDQBIaVHQfUAhEd5asovYEfYtT(tJk8QBImxFGH3rE5YLSiqbkWRsXHCaXfiyWJ2GGbV86iAgaIduGhXnem4LxhrZaqCGc8y8HGbV86iAgaIduGhTiiyW7jUwLHxRbE51r0maeh41dsNl8EIxTJOz49eVMRpWWB1ktPd2jqbEmQqWGxEDendaXbEdvlC1o8kUMxXGOZeqCDUedVoIMbGxpiDUWBXJvcUGfkWJGqiyWRhKox4vPsW1WlVoIMbG4af4rCbem4LxhrZaqCGc8O1abdE9G05cVkP05cV86iAgaIduGhbbqWGxpiDUWlcxeUSdV86iAgaIduGc8oYlxUKfbcg8OniyW7jUwLH3OFQTNE(Pr)uIcR1tXRrwigbB5eSZGlp1cp12tJ7PX7PN(uX18kgKsvC9KODcwdVoIMbEACpnEp1dsNRPC7Sr6G9P0dm8YRJOzaioWRhKox49eVAhrZW7jEnxFGH3YTZtraGc8iUHGbV86iAgaId8gQw4QD4vCnVIbrNjG46CjgEDend80ypfrff1OumGlzH)KaEJkltigvLNg7PiQOOgeDMaIRZLyasW3Ng7PHCajNkzVc5PyEQf90ypfift52ztXdEVKNA9NArpn2tfVgzXi9apLCc08tT8PaPyk3oBkEW7L80Zp9eVAhrZMYTZtraGxpiDUWBXJvcUGfkWJXhcg8YRJOzaioWlAwZLbPapAdE9G05cVkzQNfts1kWqbE0IGGbV86iAgaId8gQw4QD4n6NE6tLoyV3XNckOp90NkUMxXGOZeqCDUedVoIMbEASNwmAXeSoIMFACpn2tfVgzXi9apLCc08tT8PaPyk3oBkEW7L80Zp9eVAhrZMYTZtraGxpiDUWB52zOapgviyWlVoIMbG4aVOznxgKc8On41dsNl8QKPEwmjvRadf4rqiem4LxhrZaqCG3q1cxTdVIR5vmi6mbexNlXWRJOzGNg7PiQOOgeDMaIRZLyuvEASNw8G3l5PwhZtXfpn2tv4I0eHxzoOQLwr3C9ulFkqkMYTZgLbvT0k6MRNgVNAfJ1e1Ng7PIxJSyKEGNsobA(Pw(uGumLBNnfp49sE65NEIxTJOzt525PiaWRhKox4TC7muGhXfqWGxEDendaXbErZAUmif4rBWRhKox4vjt9SysQwbgkWJwdem4LxhrZaqCG3q1cxTdVr)uevuuJ0JCrMOQf(gvLNckOpn6NgW61itEQLyEkUFASNgYudKGVgPh5Imrvl8nfp49sEQLpfvvRNfhW61ipLEGFACpnUNg7PL3at(eEfJdaqm9(ulFkQQwploG1RrEk9adVEq6CHxKsvC9KODcwOapccGGbV86iAgaId8IM1CzqkWJ2GxpiDUWRsM6zXKuTcmuGhTzfiyWlVoIMbG4aVHQfUAhElgTycwhrZpn2tfVgzXi9apLCc08tT8Pfp49sE65Ng9tX9tp)uC)0490OFkrH16P41ileJGTCc2zWLNAHNA7PX90490tFQ4AEfdsPkUEs0obRHxhrZapnUNgVNcKIziZfTlEgCXiDW(u6bgE9G05cVdzUODXZGlqbE0MniyWlVoIMbG4aVOznxgKc8On41dsNl8QKPEwmjvRadf4rB4gcg8YRJOzaioWBOAHR2H3IrlMG1r08tJ90OFkrH16P41ileJGTCc2zWLNA5tT9uqb9Pr)u3INRwyd4TgyIQzc2IxGEhn86iAg4PXEQ41ilgPh4PKtGMFQLpT4bVxYtp)upiDUgbB5eSZGlgPd2NspWpnUNgh86bPZfEfSLtWodUaf4rBXhcg8YRJOzaioWlAwZLbPapAdE9G05cVkzQNfts1kWqbE0MfbbdE51r0maeh4nuTWv7WlrH16P41iledb8wHNbxEQLp1g86bPZfEjG3k8m4cuGhTfviyWlVoIMbG4aVOznxgKc8On41dsNl8QKPEwmjvRadf4rBGqiyWlVoIMbG4aVHQfUAhEp9PewZbPZ9PGc6tbsXuUD2u8G3l5Pw(0OFQhKoxdbBXaMqsKNE(PEq6CnLBNnHKip1cpLxUgX)PX9ul2pLxUgX3u8iVpfuqFkIkkQjOzVcor6D0uShKNckOp90Ng9tfVgzXi9apLCc08tT8PaPyk3oBkEW7L80Zp9eVAhrZMYTZtraEACWRhKox4LGTyaOaf4fT3MGLlcem4rBqWGxEDendaXbEdvlC1o8IOIIAukgWLSWFsaVrLLjeJQYtJ9uX18kgeDMaIRZLy41r0mWtJ9uevuudIotaX15smeXd2FQ1FkUHxpiDUWBXJvcUGfkWJ4gcg8YRJOzaioWlAwZLbPapAdE9G05cVkzQNfts1kWqbEm(qWGxEDendaXbEdvlC1o8IOIIAi(j(ipR0ldqc(cVEq6CHxIFIpYZk9ckWJweem4LxhrZaqCGx0SMldsbE0g86bPZfEvYuplMKQvGHc8yuHGbV86iAgaId8gQw4QD4LOWA9u8AKfIrP6bxpbVCb7tT8P2E65NkUMxXqCeUKmfSgEDendaVEq6CHxLQhC9e8YfSqbEeecbdE51r0maeh4fnR5YGuGhTbVEq6CHxLm1ZIjPAfyOapIlGGbV86iAgaId8gQw4QD490NkUMxXqCeUKmfSgEDend80ypTy0IjyDen)0ypv8AKfJ0d8uYjqZp1YNcKIPAftXdEVKNE(PN4v7iA2uTYu6GDYtJ3t9G05AQwXiDW(u6bgE9G05cVvRaf4rRbcg8YRJOzaioWlAwZLbPapAdE9G05cVkzQNfts1kWqbEeeabdE51r0maeh4nuTWv7WR4AEfdXr4sYuWA41r0mWtJ90OF6Ppv6G9EhFkOG(0Ih8Ejp16yEkGA5sN7tJ3tTIj(pn2tv4I0eHxzoOQLwr3C9ulFkqkMQvmkdQAPv0nxpnUNg7PIxJSyKEGNsobA(Pw(uGumvRykEW7L80Zp9eVAhrZMQvMshStEA8EA0p12tp)uGumvRyKoyV3XNgVNg)Ng3tJ3t9G05AQwXiDW(u6bgE9G05cVvRaf4rBwbcg8YRJOzaioWlAwZLbPapAdE9G05cVkzQNfts1kWqbE0MniyWlVoIMbG4aVHQfUAhErurrne)eFKNv6LP4bVxYtT(tTHB41dsNl8s8t8rEwPxqbE0gUHGbV86iAgaId8IM1CzqkWJ2GxpiDUWRsM6zXKuTcmuGhTfFiyWlVoIMbG4aVHQfUAhErurrnDL70IZbNyuvGxpiDUW7G3dqbE0MfbbdE51r0maeh4fnR5YGuGhTbVEq6CHxLm1ZIjPAfyOapAlQqWG3bhKtE5AeF41g86bPZfEr5kdDQsMiTWWlVoIMbG4afOaVHm1aj4lbcg8OniyWlVoIMbG4aVHQfUAhE5LRr8FQLyEA8TYtJ90OFAitnqc(AKEKlYevTW3u8G3l5Pw(0O(uqb9PHm1aj4Rr6rUitu1cFtXdEVKNA9NA7PXbVEq6CHxeUiCzhkWJ4gcg8YRJOzaioWBOAHR2HxE5Ae)NAjMNgFRaVEq6CH3EdETU05cf4X4dbdE51r0maeh4nuTWv7WlIkkQr6rUitu1cFJQc86bPZfEvj8SfEGaf4rlccg8YRJOzaioWBOAHR2HxE5AeFdaJ2HwEQLyEAuTYtbf0NIOIIAKEKlYevTW3aKGVWRhKox4v6rUitu1cFOapgviyWRhKox4fHlcx27DeE51r0maehOapccHGbV86iAgaId8IM1CzqkWJ2GxpiDUWRsM6zXKuTcmuGhXfqWGxEDendaXbEdvlC1o8gYbKCQK9kKNI5PwbE9G05cVOC56jAXRfp(qbE0AGGbV86iAgaId86bPZfEvsPZfEdvlC1o8kEnYIr6bEk5eO5NA9NccJ6tbf0Ng9tLEGNsobA(Pw)P2SgR80ypn6NIOIIAq4IWLDJQYtbf0NIOIIA6n416sNRrv5PX904GxLu6CHxexenpvsPZDMOtFS1TGpuGhbbqWGxEDendaXbEdvlC1o8gYbKCQK9kKNA9Ng1Ng7P8Y1i(p1smp1dsNRPC7SjKe5PXEkqkMYTZgLbvT0k6MRNA9NIBJTNg7PiQOOgPh5Imrvl8nQkpn2tJ(PiQOOgeDMaIRZLyuvEkOG(0tFQ4AEfdIotaX15sm86iAg4PX90ypn6NE6tfxZRy6n416sNRHxhrZapfuqFAitnqc(A6n416sNRP4bVxYtT8P2SMNg3tJ90tFkIkkQP3GxRlDUgvf41dsNl8sW6aj4dSgakqbkWRRkyZcEV9aUekqbcba]] )
end
