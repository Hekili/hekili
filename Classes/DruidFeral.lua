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


    spec:RegisterPack( "Feral", 20190123.1046, [[dWuS9aqiGspIc4sqvvXMuGpPcjJsf4uQGwLku9kGywuq3sfv7Is)sbnmkKoMqSmkqptiPPbvfxtfL2Mku8nOQKXrHOZPcPwNkk8ovikZtiX9qu7Jc1bvrrler6HQqyIqvvUiuvvAJqvLpcvLQCsvisRKImtOQuPDQI8tviIHsHWsvHspfWubsxvfIQVcvLQAVq(RIgmOdt1IHYJfmzv6YO2mcFwOgnu50sTAOQuEnf1Sj62k0Uv1VfnCcoouvQy5sEostN01j02fs9DGQXduCEeX6HQQQ5dvz)knkccueW1vgDYGgnYrB0igmQ2igfFWx4ZrJauseyeGGhm7Xmc49rgbGFC5seGGtIm9lcueanfRaJaWPQa9mgomUvCIy2qooK2JIsx78dLtOdP9yyiMmXgIr4NF5Ohkujrlz6qJO4J17lDOrCSt8xj23j(XLlT0EmGaWeBPEK(imeW1vgDYGgnYrB0igmQ2igfFWx4JrIaOcCaDkIrJkcaxFV8JWqaxMgqagyH4hxUCH4VsSVRjdSqCQkqpJHdJBfNiMnKJdP9OO01o)q5e6qApggIjtSHye(5xo6Hcvs0sMo0ik(y9(shAeh7e)vI9DIFC5slThdRjdSqt(l6fjl0Gr1WfAqJg5Ox45lmIrpd85ywtRjdSWJaN)Xm9mwtgyHNVWZ8E57cbmlkLlKuNIZUMmWcpFHN59Y3fsAjQUCHasNIBia4TaVqnxykWpxlS)fokk1(C1RywTRjdSWZxOri9aFx4r46cXVSgxOtOCTqJOsWLlK2FGxOruj4YfQvhhZfDHhHRle)YA0UMmWcpFHhllDWW3fcAhZ1rrxi(jwKSq(5kMKfgWXbZluZf6ccsswy(sswi444FHG2XCDu0fIFIfjlSPl0Lf7xswOOGDnzGfE(ctb(5AEZNxytxio)Vs(UW(vUExkjzHyKSqfhVq)EZ)iBHfpMrZ3fQ4ykVWO9QDmjtTlCHhjVKKfILkoUwy)lelP0fs0X4uQDnzGfE(cpcCCW8cjYAHQxXSUWqk(6cjYAHuWBbEgCDH9VWy(5Y1SOlu2uDHNF(c)uxi(MivxiqGFDHjXcjvM51UMmWcpFHN59Y3fI5bZIcluq6)cjYAHPa)CzxtgyHNVWJCA)Xlea3yM4pXlFu0fY3wPweGqLeTKragyH4hxUCH4VsSVRjdSqCQkqpJHdJBfNiMnKJdP9OO01o)q5e6qApggIjtSHye(5xo6Hcvs0sMo0ik(y9(shAeh7e)vI9DIFC5slThdRjdSqt(l6fjl0Gr1WfAqJg5Ox45lmIrpd85ywtRjdSWJaN)Xm9mwtgyHNVWZ8E57cbmlkLlKuNIZUMmWcpFHN59Y3fsAjQUCHasNIBia4TaVqnxykWpxlS)fokk1(C1RywTRjdSWZxOri9aFx4r46cXVSgxOtOCTqJOsWLlK2FGxOruj4YfQvhhZfDHhHRle)YA0UMmWcpFHhllDWW3fcAhZ1rrxi(jwKSq(5kMKfgWXbZluZf6ccsswy(sswi444FHG2XCDu0fIFIfjlSPl0Lf7xswOOGDnzGfE(ctb(5AEZNxytxio)Vs(UW(vUExkjzHyKSqfhVq)EZ)iBHfpMrZ3fQ4ykVWO9QDmjtTlCHhjVKKfILkoUwy)lelP0fs0X4uQDnzGfE(cpcCCW8cjYAHQxXSUWqk(6cjYAHuWBbEgCDH9VWy(5Y1SOlu2uDHNF(c)uxi(MivxiqGFDHjXcjvM51UMmWcpFHN59Y3fI5bZIcluq6)cjYAHPa)CzxtgyHNVWJCA)Xlea3yM4pXlFu0fY3wP210AYale)4YLle)vI9DnzGfItvb6zmCyCR4eXSHCCiThfLU25hkNqhs7XWqmzIneJWp)YrpuOsIwY0HgrXhR3x6qJ4yN4VsSVt8JlxAP9yynzGfAYFrVizHN1WfAqJg5Ox45l0Gg8mmOrUMwtgyHhbo)Jz6zSMmWcpFHN59Y3fcywukxiPofNDnzGfE(cpZ7LVlK0suD5cbKof3qaWBbEHAUWuGFUwy)lCuuQ95QxXSAxtgyHNVqJq6b(UWJW1fIFznUqNq5AHgrLGlxiT)aVqJOsWLluRooMl6cpcxxi(L1ODnzGfE(cpww6GHVle0oMRJIUq8tSizH8ZvmjlmGJdMxOMl0feKKSW8LKSqWXX)cbTJ56OOle)elswytxOll2VKSqrb7AYal88fMc8Z18MpVWMUqC(FL8DH9RC9UusYcXizHkoEH(9M)r2clEmJMVluXXuEHr7v7ysMAx4cpsEjjlelvCCTW(xiwsPlKOJXPu7AYal88fEe44G5fsK1cvVIzDHHu81fsK1cPG3c8m46c7FHX8ZLRzrxOSP6cp)8f(PUq8nrQUqGa)6ctIfsQmZRDnzGfE(cpZ7LVleZdMffwOG0)fsK1ctb(5YUMwtgyH4Fbdhev(UqmMilEHHCeZ1fIXX9tTl8mdbwqPl8Z)CCEnsikxOh0oF6cZxsIDn5bTZNAfkoKJyUsMq6uZRjpOD(uRqXHCeZvqipKiZ7AYdANp1kuCihXCfeYdDX4r(vx78xtEq78PwHId5iMRGqEy0E1oMKn89rMC1ctTdMPggTlfzYg5AYdANp1kuCihXCfeYdloUsWvCg2eKvxYVAXKzEvxMp1YVJj57AYdANp1kuCihXCfeYdfQeC5AYdANp1kuCihXCfeYdPVlqXL6KQUsxtEq78PwHId5iMRGqEOqQD(RjpOD(uRqXHCeZvqipeJlkxMxtRjdSq8VGHdIkFxihnxKSqTh5fQ44f6bnRf20f6r7T0XKSDn5bTZNs2f1C6Q6bZg2eKblMibHvOsWLwrHbGftKGWsX53e8rwETIcRjpOD(uqipKAwukNyof3AYdANpfeYddUuo9G25pLnvn89rMCkWpxg2eKbBkWpxZB(8GdWejiSyCr5YSvuap8WejiS9h86DTZ3kkC4AYdANpfeYddUojYA0WMGmyXejiSbxNeznAffwtEq78PGqEy5MzdBcYyIeewHkbxAffWdpmrcclfNFtWhz51kkSM8G25tbH8WGlLtpOD(tztvdFFKjhYuEtWF6AYdANpfeYdj4kdDksNyTYgQEfZ6SjiRUKF1sDmU0mvCw(DmjFheYrSCkK9RuJPcSuovVIzLAvCLtXndUo4MQTAbR2bZ9hp4MQTAbBXJE)0Oe1bQxXSA1EKNAoVnB8nvB1c2Ih9(PGeTxTJjzB1ctTdMPh3dANVTAbR2bZtTh51Kh0oFkiKhgCPC6bTZFkBQA47JmzI(BkoUOg2eKd5iwofY(vQX4ZAYdANpfeYddUuo9G25pLnvn89rMCm)C5Aw0PNSHnb5qoILtHSFLgLZoGkWs5u9kMvQvXvof3m4QXrwtEq78PGqEyWLYPh0o)PSPQHVpYKJ5NlxZIAytqoKJy5ui7xPr5SRP1Kh0oFQnKP8MG)uYyCr5YSHnbz(5kMeJjhvJo4GqMYBc(B1oMl6KqSiXw8O3p14ZIhEHmL3e83QDmx0jHyrIT4rVFAuIC4AYdANp1gYuEtWFkiKh2FWR31oFdBcY8ZvmjgtoQgDn5bTZNAdzkVj4pfeYdfP8SvEKAytqgtKGWQDmx0jHyrIvuyn5bTZNAdzkVj4pfeYd1oMl6KqSiXWMGm)CftI9YeDOvJjFwJIhEyIeewTJ5IojelsS3e8Fn5bTZNAdzkVj4pfeYdX4IYL5(JxtEq78P2qMYBc(tbH8qHmLZIPPyfydjYA(myuYrwtEq78P2qMYBc(tbH8qcUC5KO4h)NedBcYHCelNcz)kLSrxtEq78P2qMYBc(tbH8qHu78n89rMmMRQKNcP25ptIPh3YwjXWMGS6vmRwTh5PMZBZr5yolE4DG2J8uZ5T5OeXin6GdWejiSyCr5YSvuap8WejiS9h86DTZ3kkC4HRjpOD(uBit5nb)PGqEifNFtWhz51WMGCihXYPq2VsJYzhWpxXKymzpOD(2YnZ2qs1b3uTLBMTcJIsTfKnxrXG2idWejiSAhZfDsiwKyffgCaMibHftM5vDz(uROaE4bw1L8RwmzMx1L5tT87ys(E4GdaR6s(vB)bVEx78T87ys(IhEHmL3e832FWR31oFBXJE)uJJyKhoaSyIee2(dE9U25BffwtRjpOD(ulr)nfhxuYfhxj4kodBcYyIeewHIVUMfjtk4nH(mLAffgOUKF1IjZ8QUmFQLFhtY3byIeewmzMx1L5tTu1dMJIbxtEq78PwI(BkoUOGqEOqMYzX0uScSHeznFgmk5iRjpOD(ulr)nfhxuqipK6r7X8SsVmSjiJjsqyPE0EmpR0l7nb)xtEq78PwI(BkoUOGqEOqMYzX0uScSHeznFgmk5iRjpOD(ulr)nfhxuqipuO6rxobVCfNHQxXSoBcYubwkNQxXSsTcvp6Yj4LR4mociQl5xTuhJlntfNLFhtY31Kh0oFQLO)MIJlkiKhkKPCwmnfRaBirwZNbJsoYAYdANp1s0FtXXffeYdRwWq1RywNnbzWQUKF1sDmU0mvCw(DmjFhumrXuCoMKhOEfZQv7rEQ582SX3uTvlylE07Ncs0E1oMKTvlm1oyMECpOD(2QfSAhmp1EKxtEq78PwI(BkoUOGqEOqMYzX0uScSHeznFgmk5iRjpOD(ulr)nfhxuqipSAbdvVIzD2eKvxYVAPogxAMkol)oMKVdoaSAhm3FmE4v8O3pnkKVILRD(h3O2OoqGlAtv(15OOuBbzZLX3uTvlyfgfLAliBUoCG6vmRwTh5PMZBZgFt1wTGT4rVFkir7v7ys2wTWu7Gz6Xpici3uTvly1oyU)4Jh1dpUh0oFB1cwTdMNApYRjpOD(ulr)nfhxuqipuit5SyAkwb2qISMpdgLCK1Kh0oFQLO)MIJlkiKhs9O9yEwPxg2eKXejiSupApMNv6LT4rVFAuIyW1Kh0oFQLO)MIJlkiKhkKPCwmnfRaBirwZNbJsoYAYdANp1s0FtXXffeYdh9E0WMGmMibHTR8N4Bo4uROWAYdANp1s0FtXXffeYdfYuolMMIvGnKiR5ZGrjhzn5bTZNAj6VP44Icc5HeCLHofPtSwzdhDWm5NRysihznTM8G25tTX8ZLRzrjhTxTJjzdFFKjxUzEQ61WODPit(GiGCavGLYP6vmRuRIRCkUzW1ZJC4XbR6s(vlwjQUCsLofNLFhtY3dpUh0oFB5MzR2bZtTh51Kh0oFQnMFUCnlkiKhwCCLGR4mSjiRUKF1IjZ8QUmFQLFhtY3byIeewHIVUMfjtk4nH(mLAffgGjsqyXKzEvxMp1EtW)bHCelNcz)kLm(m4MQTCZST4rVFAuWNbQxXSA1EKNAoVnB8nvB5MzBXJE)uqI2R2XKSTCZ8u17AYdANp1gZpxUMffeYdfYuolMMIvGnKiR5ZGrjhzn5bTZNAJ5NlxZIcc5HLBMnu9kM1ztq(aWQDWC)X4HhyvxYVAXKzEvxMp1YVJj57GIjkMIZXK8HduVIz1Q9ip1CEB24BQ2YnZ2Ih9(PGeTxTJjzB5M5PQ31Kh0oFQnMFUCnlkiKhkKPCwmnfRaBirwZNbJsoYAYdANp1gZpxUMffeYdl3mBO6vmRZMGS6s(vlMmZR6Y8Pw(DmjFhGjsqyXKzEvxMp1kkmO4rVFAuiJVgiWfTPk)6CuuQTGS5Y4BQ2YnZwHrrP2cYMRJBuRrE2bQxXSA1EKNAoVnB8nvB5MzBXJE)uqI2R2XKSTCZ8u17AYdANp1gZpxUMffeYdfYuolMMIvGnKiR5ZGrjhzn5bTZNAJ5NlxZIcc5HyLO6Yjv6uCg2eKpatKGWQDmx0jHyrIvuap8oiGZRyMAmzdoiKP8MG)wTJ5IojelsSfp69tnMqukNfhW5vmp1EKp8WbL33jhn)Q1VxQTFJjeLYzXbCEfZtTh51Kh0oFQnMFUCnlkiKhkKPCwmnfRaBirwZNbJsoYAYdANp1gZpxUMffeYdhZ8j6INbxnu9kM1ztqUyIIP4Cmjpq9kMvR2J8uZ5TzJlE07NcYbgeedE8dOcSuovVIzLAvCLtXndUEEKdpoyvxYVAXkr1LtQ0P4S87ys(E4XVPAhZ8j6INbxTAhmp1EKxtEq78P2y(5Y1SOGqEOqMYzX0uScSHeznFgmk5iRjpOD(uBm)C5AwuqipuXvof3m4QHnb5IjkMIZXK8GdOcSuovVIzLAvCLtXndUACe8W7ah)NRwzl4T8ojKmfxX)T)yl)oMKVduVIz1Q9ip1CEB24Ih9(PG4bTZ3Q4kNIBgC1QDW8u7r(WdxtEq78P2y(5Y1SOGqEOqMYzX0uScSHeznFgmk5iRjpOD(uBm)C5AwuqipKcElWZGRg2eKPcSuovVIzLAPG3c8m4QXrwtEq78P2y(5Y1SOGqEOqMYzX0uScSHeznFgmk5iRjpOD(uBm)C5AwuqipKIR4RHnb5BQ2YnZ2Ih9(PgFGh0oFlfxXxBiPkiEq78TLBMTHKQNZpxXKCi(h(5kMeBXX8JhEyIee2GK9k4uT)yBXEqXdpWEG6vmRwTh5PMZBZgFt1wUz2w8O3pfKO9QDmjBl3mpv9E4AAn5bTZNAJ5NlxZIo9KjlKPCwmnfRaBirwZNbJsoYAYdANp1gZpxUMfD6jdc5HkUYP4MbxnSjixmrXuCoMKhqfyPCQEfZk1Q4kNIBgC1ydIhEQl5xT0a)6mjMyYmVw(DmjFhGjsqyPb(1zsmXKzET3e8FavGLYP6vmRuRIRCkUzWvJJ6AYdANp1gZpxUMfD6jdc5HczkNfttXkWgsK18zWOKJSM8G25tTX8ZLRzrNEYGqEiwjQUCsLofNHnbzQalLt1RywPwSsuD5KkDkoJVmTl(ovVIzLUM8G25tTX8ZLRzrNEYGqEOqMYzX0uScSHeznFgmk5iRjpOD(uBm)C5Aw0PNmiKhsbVf4zWvdBcYyIeewAGFDMetmzMxROWAAn5bTZNAtb(5IS2XCrNeIfjRjpOD(uBkWpxGqEy5MzdBcYGv7G5(JXdpmrccRqLGlTIcRjpOD(uBkWpxGqEOq1JUCcE5kodBcYEq7O5j)8yZuJJmiKJy5ui7xPghzWbyIeewTJ5IojelsSIcdoatKGWIjZ8QUmFQvuap8aR6s(vlMmZR6Y8Pw(DmjFpCWbGvDj)Qvk(En7Nk0LRD(w(DmjFXdVBQ2XmFIU4zWvR2bZ9hF4aWQDWC)XhUM8G25tTPa)Cbc5Hvlyytq2dAhnp5NhBMsoYGdWejiSAhZfDsiwKyffgCaMibHftM5vDz(uROaE4bw1L8RwmzMx1L5tT87ys(E4GBQ2YnZwTdM7pEWbGvDj)Qvk(En7Nk0LRD(w(DmjFXdVBQ2XmFIU4zWvR2bZ9hF4aWQDWC)XhIaIMlANp6KbnAKJ2Orm6XynyKi4lea4E99htra47FMh7PJ0t47DglCHGIJxypkKLUqISw4rDzcxuQh1clgFhXU47cP5iVqxuZrx57cd48pMP21e(U9ZlmYzSWJ8NkkiKLY3f6bTZFHhLlQ50v1dMpk7AAnDKokKLY3fIVwOh0o)fkBQsTRjeGlQ4Ycba0Jhbcq2uLIafbKc8Zfcu0PiiqraEq78raAhZfDsiwKGa43XK8frksrNmicuea)oMKVisraHQvUAhba2fQDWC)Xlep8wiMibHvOsWLwrbeGh0oFeq5MzKIofveOia(DmjFrKIacvRC1ocWdAhnp5NhBMUqJxyKfoyHHCelNcz)kDHgVWilCWcpyHyIeewTJ5IojelsSIclCWcpyHyIeewmzMx1L5tTIclep8wiyxO6s(vlMmZR6Y8Pw(DmjFx4HlCWcpyHGDHQl5xTsX3Rz)uHUCTZ3YVJj57cXdVfEt1oM5t0fpdUA1oyU)4fE4chSqWUqTdM7pEHhIa8G25JaeQE0LtWlxXHu0j8bbkcGFhtYxePiGq1kxTJa8G2rZt(5XMPlK8cJSWbl8GfIjsqy1oMl6KqSiXkkSWbl8GfIjsqyXKzEvxMp1kkSq8WBHGDHQl5xTyYmVQlZNA53XK8DHhUWbl8MQTCZSv7G5(Jx4GfEWcb7cvxYVALIVxZ(PcD5ANVLFhtY3fIhEl8MQDmZNOlEgC1QDWC)Xl8WfoyHGDHAhm3F8cpeb4bTZhbuTasrkciMFUCnl60tgbk6ueeOia(DmjFrKIaiYA(myu0PiiapOD(iaHmLZIPPyfyKIozqeOia(DmjFrKIacvRC1ocOyIIP4CmjVWblKkWs5u9kMvQvXvof3m46cnEHgCH4H3cvxYVAPb(1zsmXKzET87ys(UWbletKGWsd8RZKyIjZ8AVj4)chSqQalLt1RywPwfx5uCZGRl04fgveGh0oFeGIRCkUzWvKIofveOia(DmjFrKIaiYA(myu0PiiapOD(iaHmLZIPPyfyKIoHpiqra87ys(IifbeQw5QDeavGLYP6vmRulwjQUCsLof3cnEHxM2fFNQxXSsraEq78rayLO6Yjv6uCifD6Siqra87ys(IifbqK18zWOOtrqaEq78raczkNfttXkWifD6yqGIa43XK8frkciuTYv7iamrcclnWVotIjMmZRvuab4bTZhbqbVf4zWvKIueWLjCrPIafDkccuea)oMKVisraHQvUAhba2fIjsqyfQeCPvuyHdwiyxiMibHLIZVj4JS8AffqaEq78raUOMtxvpygPOtgebkcWdANpcGAwukNyofhcGFhtYxePifDkQiqra87ys(IifbeQw5QDeayxykWpxZB(8chSWdwiMibHfJlkxMTIclep8wiMibHT)GxVRD(wrHfEicWdANpci4s50dAN)u2ufbiBQoFFKraPa)CHu0j8bbkcGFhtYxePiGq1kxTJaa7cXejiSbxNeznAffqaEq78rabxNeznIu0PZIafbWVJj5lIueqOALR2rayIeewHkbxAffwiE4TqmrcclfNFtWhz51kkGa8G25Jak3mJu0PJbbkcGFhtYxePiapOD(iGGlLtpOD(tztveGSP689rgbeYuEtWFksrNWxiqra87ys(IifbeQw5QDeG6s(vl1X4sZuXz53XK8DHdwyihXYPq2VsxOXlKkWs5u9kMvQvXvof3m46chSWBQ2QfSAhm3F8chSWBQ2QfSfp69txyuwyux4GfQEfZQv7rEQ5828cnEH3uTvlylE07NUqqwy0E1oMKTvlm1oyMUWJVqpOD(2QfSAhmp1EKraEq78raeCLHofPtSwzKIozKiqra87ys(IifbeQw5QDeqihXYPq2VsxOXleFqaEq78rabxkNEq78NYMQiazt157JmcGO)MIJlksrNoAeOia(DmjFrKIacvRC1ociKJy5ui7xPlmkl8SlCWcPcSuovVIzLAvCLtXndUUqJxyeeGh0oFeqWLYPh0o)PSPkcq2uD((iJaI5NlxZIo9Krk6ueJIafbWVJj5lIueqOALR2raHCelNcz)kDHrzHNfb4bTZhbeCPC6bTZFkBQIaKnvNVpYiGy(5Y1SOifPiaHId5iMRiqrNIGafbWVJj5lIuKIozqeOia(DmjFrKIu0POIafbWVJj5lIuKIoHpiqra87ys(IifbeTlfzeGrIa8G25JaI2R2XKmciAVMVpYiGQfMAhmtrk60zrGIa43XK8frkciuTYv7ia1L8RwmzMx1L5tT87ys(Ia8G25JakoUsWvCifD6yqGIa8G25JaeQeCjcGFhtYxePifDcFHafbWVJj5lIuKIozKiqraEq78racP25Ja43XK8frksrNoAeOiapOD(iamUOCzgbWVJj5lIuKIueqm)C5AwueOOtrqGIa43XK8frkciAxkYiGdwyKfcYcpyHubwkNQxXSsTkUYP4Mbxx45lmYcpCHhFHGDHQl5xTyLO6Yjv6uCw(DmjFx4Hl84l0dANVTCZSv7G5P2JmcWdANpciAVAhtYiGO9A((iJak3mpv9Iu0jdIafbWVJj5lIueqOALR2raQl5xTyYmVQlZNA53XK8DHdwiMibHvO4RRzrYKcEtOptPwrHfoyHyIeewmzMx1L5tT3e8FHdwyihXYPq2Vsxi5fIplCWcVPAl3mBlE07NUWOSq8zHdwO6vmRwTh5PMZBZl04fEt1wUz2w8O3pDHGSWO9QDmjBl3mpv9Ia8G25JakoUsWvCifDkQiqra87ys(IifbqK18zWOOtrqaEq78raczkNfttXkWifDcFqGIa43XK8frkciuTYv7iGdwiyxO2bZ9hVq8WBHGDHQl5xTyYmVQlZNA53XK8DHdwyXeftX5ysEHhUWblu9kMvR2J8uZ5T5fA8cVPAl3mBlE07NUqqwy0E1oMKTLBMNQEraEq78raLBMrk60zrGIa43XK8frkcGiR5ZGrrNIGa8G25JaeYuolMMIvGrk60XGafbWVJj5lIueqOALR2raQl5xTyYmVQlZNA53XK8DHdwiMibHftM5vDz(uROWchSWIh9(PlmkKxi(AHdwOax0MQ8RZrrP2cYMRfA8cVPAl3mBfgfLAliBUw4XxOrTg5zx4GfQEfZQv7rEQ5828cnEH3uTLBMTfp69txiilmAVAhtY2YnZtvViapOD(iGYnZifDcFHafbWVJj5lIuearwZNbJIofbb4bTZhbiKPCwmnfRaJu0jJebkcGFhtYxePiGq1kxTJaoyHyIeewTJ5IojelsSIclep8w4blmGZRyMUqJjVqdUWblmKP8MG)wTJ5IojelsSfp69txOXlKqukNfhW5vmp1EKx4Hl8WfoyHL33jhn)Q1VxQT)fA8cjeLYzXbCEfZtThzeGh0oFeawjQUCsLofhsrNoAeOia(DmjFrKIaiYA(myu0PiiapOD(iaHmLZIPPyfyKIofXOiqra87ys(IifbeQw5QDeqXeftX5ysEHdwO6vmRwTh5PMZBZl04fw8O3pDHGSWdwObxiil0Gl84l8GfsfyPCQEfZk1Q4kNIBgCDHNVWil8WfE8fc2fQUKF1IvIQlNuPtXz53XK8DHhUWJVWBQ2XmFIU4zWvR2bZtThzeGh0oFeWyMprx8m4ksrNIebbkcGFhtYxePiaISMpdgfDkccWdANpcqit5SyAkwbgPOtrmicuea)oMKVisraHQvUAhbumrXuCoMKx4GfEWcPcSuovVIzLAvCLtXndUUqJxyKfIhEl8Gf64)C1kBbVL3jHKP4k(V9hB53XK8DHdwO6vmRwTh5PMZBZl04fw8O3pDHGSqpOD(wfx5uCZGRwTdMNApYl8WfEicWdANpcqXvof3m4ksrNIeveOia(DmjFrKIaiYA(myu0PiiapOD(iaHmLZIPPyfyKIofbFqGIa43XK8frkciuTYv7iaQalLt1RywPwk4TapdUUqJxyeeGh0oFeaf8wGNbxrk6uKZIafbWVJj5lIuearwZNbJIofbb4bTZhbiKPCwmnfRaJu0Pihdcuea)oMKVisraHQvUAhbCt1wUz2w8O3pDHgVWdwOh0oFlfxXxBiP6cbzHEq78TLBMTHKQl88fYpxXKSWdxi(NfYpxXKyloM)fIhEletKGWgKSxbNQ9hBl2d6cXdVfc2fEWcvVIz1Q9ip1CEBEHgVWBQ2YnZ2Ih9(PleKfgTxTJjzB5M5PQ3fEicWdANpcGIR4lsrkcGO)MIJlkcu0Piiqra87ys(IifbeQw5QDeaMibHvO4RRzrYKcEtOptPwrHfoyHQl5xTyYmVQlZNA53XK8DHdwiMibHftM5vDz(ulv9G5fgLfAqeGh0oFeqXXvcUIdPOtgebkcGFhtYxePiaISMpdgfDkccWdANpcqit5SyAkwbgPOtrfbkcGFhtYxePiGq1kxTJaWejiSupApMNv6L9MG)iapOD(iaQhThZZk9cPOt4dcuea)oMKVisraeznFgmk6ueeGh0oFeGqMYzX0uScmsrNolcuea)oMKVisraHQvUAhbqfyPCQEfZk1ku9OlNGxUIBHgVWileKfQUKF1sDmU0mvCw(DmjFraEq78racvp6Yj4LR4qk60XGafbWVJj5lIuearwZNbJIofbb4bTZhbiKPCwmnfRaJu0j8fcuea)oMKVisraHQvUAhba2fQUKF1sDmU0mvCw(DmjFx4GfwmrXuCoMKx4GfQEfZQv7rEQ5828cnEH3uTvlylE07NUqqwy0E1oMKTvlm1oyMUWJVqpOD(2QfSAhmp1EKraEq78ravlGu0jJebkcGFhtYxePiaISMpdgfDkccWdANpcqit5SyAkwbgPOthncuea)oMKVisraHQvUAhbOUKF1sDmU0mvCw(DmjFx4GfEWcb7c1oyU)4fIhElS4rVF6cJc5fEflx78x4XxOrTrDHdwOax0MQ8RZrrP2cYMRfA8cVPARwWkmkk1wq2CTWdx4GfQEfZQv7rEQ5828cnEH3uTvlylE07NUqqwy0E1oMKTvlm1oyMUWJVWdwyKfcYcVPARwWQDWC)Xl84lmQl8WfE8f6bTZ3wTGv7G5P2JmcWdANpcOAbKIofXOiqra87ys(IifbqK18zWOOtrqaEq78raczkNfttXkWifDkseeOia(DmjFrKIacvRC1ocatKGWs9O9yEwPx2Ih9(PlmklmIbraEq78raupApMNv6fsrNIyqeOia(DmjFrKIaiYA(myu0PiiapOD(iaHmLZIPPyfyKIofjQiqra87ys(IifbeQw5QDeaMibHTR8N4Bo4uROacWdANpcy07rKIofbFqGIa43XK8frkcGiR5ZGrrNIGa8G25JaeYuolMMIvGrk6uKZIafbm6GzYpxXKGaIGa8G25Jai4kdDksNyTYia(DmjFrKIuKIaczkVj4pfbk6ueeOia(DmjFrKIacvRC1ocGFUIjzHgtEHr1OlCWcpyHHmL3e83QDmx0jHyrIT4rVF6cnEHNDH4H3cdzkVj4Vv7yUOtcXIeBXJE)0fgLfgzHhIa8G25JaW4IYLzKIozqeOia(DmjFrKIacvRC1ocGFUIjzHgtEHr1OiapOD(iG(dE9U25Ju0POIafbWVJj5lIueqOALR2rayIeewTJ5IojelsSIciapOD(iarkpBLhPifDcFqGIa43XK8frkciuTYv7ia(5kMe7Lj6qRl0yYl8SgDH4H3cXejiSAhZfDsiwKyVj4pcWdANpcq7yUOtcXIeKIoDweOiapOD(iamUOCzU)yea)oMKVisrk60XGafbWVJj5lIuearwZNbJIofbb4bTZhbiKPCwmnfRaJu0j8fcuea)oMKVisraHQvUAhbeYrSCkK9R0fsEHgfb4bTZhbqWLlNef)4)KGu0jJebkcGFhtYxePiGq1kxTJauVIz1Q9ip1CEBEHrzHhZzxiE4TWdwO2J8uZ5T5fgLfgXin6chSWdwiMibHfJlkxMTIclep8wiMibHT)GxVRD(wrHfE4cpebiKANpcaZvvYtHu78NjX0JBzRKGa8G25JaesTZhPOthncuea)oMKVisraHQvUAhbeYrSCkK9R0fgLfE2foyH8Zvmjl0yYl0dANVTCZSnKuDHdw4nvB5MzRWOOuBbzZ1cJYcnOnYchSqmrccR2XCrNeIfjwrHfoyHhSqmrcclMmZR6Y8PwrHfIhEleSluDj)QftM5vDz(ul)oMKVl8WfoyHhSqWUq1L8R2(dE9U25B53XK8DH4H3cdzkVj4VT)GxVRD(2Ih9(Pl04fgXix4HlCWcb7cXejiS9h86DTZ3kkGa8G25JaO48Bc(ilVifPifPifHaa]] )
end
