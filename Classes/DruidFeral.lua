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

            form = "cat_form",

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
                unshift()
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


    spec:RegisterPack( "Feral", 20190401.1431, [[d00f8aqiGKhjOQljaK2Kq6tQiPrPGCkfOvPGQxPcnlOk3sqXUO4xQOgguPoMaTmbONPGY0GkX1uaTnvKY3ea14uaCovKyDcaENcqyEcQCpGAFcOdkaYcHkEiuj1efusxuai2OGs9rfGOrcvsuNubiTsHyMqLK0ovb)eQKudvfPAPckXtvPPcexfQKWxHkjXEv1Fv0Gr6WuTyiEmLMmGlJAZq6Zk0OHsNwQvRauVwqMnj3wO2Ts)w0WjLJdvsKLl55iMoX1jvBxfX3HcJhi15HQA9ca18HI2pO)Gpi)fWf(peqCh8uWnUG7GMG4YWcoSt7Vc(A8F1CBiFK)76X8FdBUC1F1C8vPd8G8xsQxw(VyfrJeaoFESfS6igBgFM0X6kx6CTLJkNjDS98Fr0BLmGUpYFbCH)dbe3bpfCJl4oOjiUmSGb80(lrJT)HG4Ey)fBdaW7J8xaMy)B4H0WMlxbPH1sVbGrcpKIvensa485XwWQJySz8zshRRCPZ1woQCM0X2ZiQe5mcQhga(KZAvI2kMC(0loS4na58PhwMH1sVbMHnxUYq6ylms4H0aKw1kiniEqAaXDWtbsddKI7tjaGl4ggbgj8qkUgRVJmjaaJeEinmqAacaGbG0BiDLcsXXjynWiHhsddKE6k3YaqkU2finSZkgsDuHli90RedfKs61Yq6PxjgkivQECKlcKIRDbsd7SInWiHhsddKgwyLdAgasbPh56ujqAyRx4dP8Y1i(qQflBdbPscPUMMcFinxf(qkgy5fsbPh56ujqAyRx4dPnbsDvXoa(qQUMbgj8qAyG0uJxUMa5YqAtGuS(cOyaiTxHR1vk8Hue8HubldPoaqUdiG0IJZtyaivWYegspXR2rumXaPqkU6vHpKIKcwUG0EHuKKqGu0EeRqmWiHhsddKIRXY2qqkAwqQ41ilqQn1xbsrZcsjy0A806cK2lKoYlxUKfbsvnrG0WegiDtbshW6ebsVwEfinrHuCuzcyGrcpKgginabaWaqkIBdPRbPAkFHu0SG0uJxUmWiHhsddKIRG07iKEXgNzyvhGpvcKYaTqm)vRs0wX)n8qAyZLRG0WAP3aWiHhsXkIgjaC(8yly1rm2m(mPJ1vU05Alhvot6y7zevICgb1ddaFYzTkrBftoF6fhw8gGC(0dlZWAP3aZWMlxziDSfgj8qAasRAfKgepinG4o4PaPHbsX9PeaWfCdJaJeEifxJ13rMeaGrcpKgginabaWaq6nKUsbP44eSgyKWdPHbspDLBzaifx7cKg2zfdPoQWfKE6vIHcsj9Azi90RedfKkvpoYfbsX1UaPHDwXgyKWdPHbsdlSYbndaPG0JCDQeinS1l8HuE5AeFi1ILTHGujHuxttHpKMRcFifdS8cPG0JCDQeinS1l8H0MaPUQyhaFivxZaJeEinmqAQXlxtGCziTjqkwFbumaK2RW16kf(qkc(qQGLHuhai3beqAXX5jmaKkyzcdPN4v7ikMyGuifx9QWhsrsblxqAVqkssiqkApIvigyKWdPHbsX1yzBiifnliv8AKfi1M6RaPOzbPemAnEADbs7fsh5LlxYIaPQMiqAycdKUPaPdyDIaPxlVcKMOqkoQmbmWiHhsddKgGaayaifXTH01GunLVqkAwqAQXlxgyKWdPHbsXvq6DesVyJZmSQdWNkbszGwigyeyKWdPbqanB1fgasry0Syi1MXiUaPi8yVedKgGSwwtiq6MByW6vmQUcsDR05sG0Cv4BGrCR05smAfBZyexaJQCsiye3kDUeJwX2mgXLJGpJMjamIBLoxIrRyBgJ4YrWND9XyEfx6CHrCR05smAfBZyexoc(8jE1oIIXB9ygC1AtPTHi4DIR0zWdamIBLoxIrRyBgJ4YrWNlESsmeS41OGfxXRyquzciUkxIHxhrXaWiUv6CjgTITzmIlhbFwRsmuWiUv6CjgTITzmIlhbF26YenRyye3kDUeJwX2mgXLJGptwxJGnLjrCHaJ4wPZLy0k2MXiUCe8zTu6CHrCR05smAfBZyexoc(mcxeUcbJaJeEinacOzRUWaqkFcx4dPshZqQGLHu3kzbPnbs9t8w5ik2aJ4wPZLa21LC6I42q41OGbfIokQrRsmugDTOGcrhf1qW6ajgXScWORbJ4wPZLCe8zsiDLAI4eSWiUv6CjhbF26k10TsN7u1ebV1JzWPgVCHxJcguPgVCnbYLJoeIokQbHlcxHm6AyIjIokQPxRxRlDUgDTbHrCR05soc(S1LjAwX41OGbfIokQX6YenRyJUgmIBLoxYrWN1QedfEnkyeDuuZawFhv8KiUkexMIJ9EjHlimIBLoxYrWNlpeJxJcgrhf1OvjgkJUgMyIOJIAiyDGeJywby01GrCR05soc(S1vQPBLo3PQjcERhZGTzQasmwcmIBLoxYrWNr5kTDQtMiTW4jEnYYSrblUIxXqCeUKmfSgEDefde1MXi5ul7vibs0yLAkEnYcXiylNGDADjkqkMQ1msBd17yuGumvRzko27LeUHfv8AKfJ0X8uYjqZbcKIPAntXXEVKJN4v7ik2uT2uABiYWDR05AQwZiTn0u6yggj8qkUY(cOyaifbFi9InoZWQoaFQeivLJTfs7L0amKg292eSCrmWiHhsDR05soc(CXJvIHGfVgfSnJrYPw2RqapWOi6OOgTIbCjl8NemAuzzcXORfvCfVIbrLjG4QCjgEDefdefrhf1GOYeqCvUedqIXcJ4wPZLCe8zRRut3kDUtvte8wpMbJ2BtWYfbVgfSnJrYPw2RqcexGrCR05soc(S1vQPBLo3PQjcERhZGh5LlxYIm9KXRrbBZyKCQL9kKWnWOenwPMIxJSqmc2YjyNwxcmimIBLoxYrWNTUsnDR05ovnrWB9yg8iVC5swe8AuW2mgjNAzVcjCdegbgXTsNlXyZubKySeWiCr4keEnkyE5Ae)abpmChDiBMkGeJ1i9ixKjQEHVP4yVxsGdetmTzQasmwJ0JCrMO6f(MIJ9EjHl4GWiUv6CjgBMkGeJLCe85ETETU05IxJcMxUgXpqWdd3WiUv6CjgBMkGeJLCe8zDcpBHJj41OGr0rrnspYfzIQx4B01GrCR05sm2mvajgl5i4ZspYfzIQx4JxJcMxUgX3aWOTTLabpqCJjMi6OOgPh5Imr1l8najglmIBLoxIXMPciXyjhbFgHlcxH6DegXTsNlXyZubKySKJGpRLPAwmj1llJhAwZLbTaoimIBLoxIXMPciXyjhbFgLlxnrlEdGXhVgfSnJrYPw2RqaJBye3kDUeJntfqIXsoc(SwkDU4TEmdgXfrXtTu6CNj60hBvl4JxJcw8AKfJ0X8uYjqZH70giMyoK0X8uYjqZHl4aG7OdHOJIAq4IWviJUgMyIOJIA61616sNRrxBWbHrCR05sm2mvajgl5i4ZeSoqIrmRaWRrbBZyKCQL9kKWnWO8Y1i(bc2TsNRP8qSXMejkqkMYdXgTyDL0AQMRWfqtWOi6OOgPh5Imr1l8n6Arhcrhf1GOYeqCvUeJUgMyckXv8kgevMaIRYLy41rumWGrhcuIR4vm9A9ADPZ1WRJOyamX0MPciXyn9A9ADPZ1uCS3ljWGdWGrbfIokQPxRxRlDUgDnyeye3kDUedAVnblxeWfpwjgcw8AuWi6OOgTIbCjl8NemAuzzcXORfvCfVIbrLjG4QCjgEDefdefrhf1GOYeqCvUedrCBOWfqye3kDUedAVnblxKJGpRLPAwmj1llJhAwZLbTaoimIBLoxIbT3MGLlYrWNj(j(ipR0l8AuWi6OOgIFIpYZk9YaKySWiUv6Cjg0EBcwUihbFwlt1SysQxwgp0SMldAbCqye3kDUedAVnblxKJGpRvDSRMyuUGfpXRrwMnkyIgRutXRrwigTQJD1eJYfSbg8O4kEfdXr4sYuWA41rumamIBLoxIbT3MGLlYrWN1YunlMK6LLXdnR5YGwahegXTsNlXG2BtWYf5i4ZvRHN41ilZgfmOexXRyiocxsMcwdVoIIbIwmAXeSoIIJkEnYIr6yEk5eO5absXuTMP4yVxYXt8QDefBQwBkTnez4Uv6CnvRzK2gAkDmdJ4wPZLyq7Tjy5ICe8zTmvZIjPEzz8qZAUmOfWbHrCR05smO92eSCroc(C1A4jEnYYSrblUIxXqCeUKmfSgEDefdeDiqjTnuVJyIzXXEVKWbgqVCPZD442mSOACrAIWRmJ1vsRPAUceift1AgTyDL0AQMRbJkEnYIr6yEk5eO5absXuTMP4yVxYXt8QDefBQwBkTnez4df8iqkMQ1msBd174Wh2Gd3TsNRPAnJ02qtPJzye3kDUedAVnblxKJGpRLPAwmj1llJhAwZLbTaoimIBLoxIbT3MGLlYrWNj(j(ipR0l8AuWi6OOgIFIpYZk9YuCS3ljCbdimIBLoxIbT3MGLlYrWN1YunlMK6LLXdnR5YGwahegXTsNlXG2BtWYf5i4ZXEhJxJcgrhf10vUZbSJbXORbJ4wPZLyq7Tjy5ICe8zTmvZIjPEzz8qZAUmOfWbHrCR05smO92eSCroc(mkxPTtDYePfgVyh0tE5AeFWbHrGrCR05smJ8YLlzraFIxTJOy8wpMbxEiEkcaEN4kDg8qbpoerJvQP41ileJGTCc2P1LWeCWHdkXv8kgKsxC1KOCcwdVoIIbgC4Uv6CnLhInsBdnLoMHrCR05smJ8YLlzroc(CXJvIHGfVgfS4kEfdIktaXv5sm86ikgikIokQrRyaxYc)jbJgvwMqm6Arr0rrniQmbexLlXaKySrTzmso1YEfcyCjkqkMYdXMIJ9EjHdxIkEnYIr6yEk5eO5absXuEi2uCS3l54jE1oIInLhINIaaJ4wPZLyg5LlxYICe8zTmvZIjPEzz8qZAUmOfWbHrCR05smJ8YLlzroc(C5Hy8eVgzz2OGhcusBd17iMyckXv8kgevMaIRYLy41rumq0IrlMG1ru8GrfVgzXiDmpLCc0CGaPykpeBko27LC8eVAhrXMYdXtraGrCR05smJ8YLlzroc(SwMQzXKuVSmEOznxg0c4GWiUv6CjMrE5YLSihbFU8qmEIxJSmBuWIR4vmiQmbexLlXWRJOyGOi6OOgevMaIRYLy01IwCS3ljCGdWr14I0eHxzgRRKwt1CfiqkMYdXgTyDL0AQMRHJBZamWOIxJSyKoMNsobAoqGumLhInfh79soEIxTJOyt5H4PiaWiUv6CjMrE5YLSihbFwlt1SysQxwgp0SMldAbCqye3kDUeZiVC5swKJGpJu6IRMeLtWIxJcEieDuuJ0JCrMO6f(gDnmXCilwVgzsGGdyuBMkGeJ1i9ixKjQEHVP4yVxsGO6k1SylwVg5P0X8GdgT8gyYNWRyCaaIP3ar1vQzXwSEnYtPJzye3kDUeZiVC5swKJGpRLPAwmj1llJhAwZLbTaoimIBLoxIzKxUCjlYrWNJZCr7INwxWt8AKLzJcUy0IjyDefhv8AKfJ0X8uYjqZbwCS3l54qb8yah(qenwPMIxJSqmc2YjyNwxctWbhoOexXRyqkDXvtIYjyn86ikgyWHdKIjoZfTlEADXiTn0u6yggXTsNlXmYlxUKf5i4ZAzQMfts9YY4HM1CzqlGdcJ4wPZLyg5LlxYICe8zbB5eStRl41OGlgTycwhrXrhIOXk1u8AKfIrWwob706sGbXeZH8ayUAHny0kGjQIjylEb6D0WRJOyGOIxJSyKoMNsobAoWIJ9EjhDR05AeSLtWoTUyK2gAkDmp4GWiUv6CjMrE5YLSihbFwlt1SysQxwgp0SMldAbCqye3kDUeZiVC5swKJGptWO14P1f8AuWenwPMIxJSqmemAnEADjWGWiUv6CjMrE5YLSihbFwlt1SysQxwgp0SMldAbCqye3kDUeZiVC5swKJGptWwmaEnkyGumLhInfh79scCi3kDUgc2Ibm2KihDR05AkpeBSjrcdVCnI)Gbq5LRr8nfpYlMyIOJIASk2lRtKEhnf7wbtmb1qIxJSyKoMNsobAoqGumLhInfh79soEIxTJOyt5H4PiadcJaJ4wPZLyg5LlxYIm9KbRLPAwmj1llJhAwZLbTaoimIBLoxIzKxUCjlY0t(i4Zc2YjyNwxWRrbxmAXeSoIIJs0yLAkEnYcXiylNGDADjWaIjMIR4vmelVYmrNiQmbm86ikgikIokQHy5vMj6erLjGbiXyJs0yLAkEnYcXiylNGDADjWHbJ4wPZLyg5LlxYIm9Kpc(SwMQzXKuVSmEOznxg0c4GWiUv6CjMrE5YLSitp5JGpJu6IRMeLtWIxJcMOXk1u8AKfIbP0fxnjkNGnqaM0fdmfVgzHaJ4wPZLyg5LlxYIm9Kpc(SwMQzXKuVSmEOznxg0c4GWiUv6CjMrE5YLSitp5JGptWO14P1f8AuWi6OOgILxzMOtevMagDnyeye3kDUetQXlxGLEKlYevVWhgXTsNlXKA8Y1rWNlpeJxJcgusBd17iMyIOJIA0QedLrxdgXTsNlXKA8Y1rWNJZCr7INwxWRrbdkPTH6DegXTsNlXKA8Y1rWN1Qo2vtmkxWIxJc2TsFcp5LJBMeyWO2mgjNAzVcjWGrhcrhf1i9ixKjQEHVrxl6qi6OOgevMaIRYLy01WetqjUIxXGOYeqCvUedVoIIbgm6qGsCfVIrPVEn7LO1LlDUgEDefdGjMaPyIZCr7INwxmsBd174GrbL02q9ooimIBLoxIj14LRJGpxTgEnky3k9j8KxoUzc4Grhcrhf1i9ixKjQEHVrxl6qi6OOgevMaIRYLy01WetqjUIxXGOYeqCvUedVoIIbgmkqkMYdXgPTH6Dm6qGsCfVIrPVEn7LO1LlDUgEDefdGjMaPyIZCr7INwxmsBd174GrbL02q9oo4FpHlsN7FiG4o4PG7aI7aAWDWGd8Vy4127i5V4QeGclhgqpmGmaaPqkiyziTJ1YsGu0SG0tfGrDDLCQqAX4kP3fdaPKmMHuxxYyxyai1I13rMyGrWvTxgsdgaGuCflrxtllHbGu3kDUq6P66soDrCBOt1aJaJmGgRLLWaqAagsDR05cPQMiedmYFvnripi)n14LRhK)qWhK)6wPZ9VspYfzIQx4)xEDefd848YFiGpi)LxhrXapo)1wTWv7)fuqQ02q9ocPyIjKIOJIA0QedLrx7VUv6C)B5H4x(dd7b5V86ikg4X5V2QfUA)VGcsL2gQ3X)6wPZ9VXzUODXtRlV8hWLhK)YRJOyGhN)ARw4Q9)6wPpHN8YXntG0aH0GqAui1MXi5ul7viqAGqAqinkKoeKIOJIAKEKlYevVW3ORbPrH0HGueDuudIktaXv5sm6AqkMycPGcsfxXRyquzciUkxIHxhrXaq6GqAuiDiifuqQ4kEfJsF9A2lrRlx6Cn86ikgasXetififtCMlAx806IrABOEhH0bH0OqkOGuPTH6Desh8VUv6C)Rw1XUAIr5c2x(dd8b5V86ikg4X5V2QfUA)VUv6t4jVCCZeifmKgesJcPdbPi6OOgPh5Imr1l8n6AqAuiDiifrhf1GOYeqCvUeJUgKIjMqkOGuXv8kgevMaIRYLy41rumaKoiKgfsbsXuEi2iTnuVJqAuiDiifuqQ4kEfJsF9A2lrRlx6Cn86ikgasXetififtCMlAx806IrABOEhH0bH0OqkOGuPTH6Desh8VUv6C)B1AV8YFh5LlxYIm9KFq(dbFq(lVoIIbEC(lAwZLbT8hc(x3kDU)vlt1SysQxw(L)qaFq(lVoIIbEC(RTAHR2)BXOftW6ikgsJcPenwPMIxJSqmc2YjyNwxG0aH0acPyIjKkUIxXqS8kZeDIOYeWWRJOyainkKIOJIAiwELzIoruzcyasmwinkKs0yLAkEnYcXiylNGDADbsdesh2FDR05(xbB5eStRlV8hg2dYF51rumWJZFrZAUmOL)qW)6wPZ9VAzQMfts9YYV8hWLhK)YRJOyGhN)ARw4Q9)s0yLAkEnYcXGu6IRMeLtWcPbcPamPlgykEnYc5VUv6C)lsPlUAsuob7l)Hb(G8xEDefd848x0SMldA5pe8VUv6C)RwMQzXKuVS8l)Ht7b5V86ikg4X5V2QfUA)Vi6OOgILxzMOtevMagDT)6wPZ9VemAnEAD5Lx(laJ66k5b5pe8b5V86ikg4X5V2QfUA)VGcsr0rrnAvIHYORbPrHuqbPi6OOgcwhiXiMvagDT)6wPZ9VUUKtxe3g6L)qaFq(RBLo3)scPRuteNG9V86ikg4X5L)WWEq(lVoIIbEC(RTAHR2)lOG0uJxUMa5YqAuiDiifrhf1GWfHRqgDniftmHueDuutVwVwx6Cn6Aq6G)1TsN7FTUsnDR05ovnr(RQjYC9y(VPgVC9YFaxEq(lVoIIbEC(RTAHR2)lOGueDuuJ1LjAwXgDT)6wPZ9VwxMOzf)YFyGpi)LxhrXapo)1wTWv7)frhf1mG13rfpjIRcXLP4yVxcKgoin4FDR05(xTkXq9YF40Eq(lVoIIbEC(RTAHR2)lIokQrRsmugDniftmHueDuudbRdKyeZkaJU2FDR05(3YdXV8hcWpi)LxhrXapo)1TsN7FTUsnDR05ovnr(RQjYC9y(V2mvajgl5L)Wa8G8xEDefd848xB1cxT)xXv8kgIJWLKPG1WRJOyainkKAZyKCQL9keinqiLOXk1u8AKfIrWwob706cKgfsbsXuTMrABOEhH0OqkqkMQ1mfh79sG0WbPddsJcPIxJSyKoMNsobAgsdesbsXuTMP4yVxcKEespXR2ruSPATP02qeiD4qQBLoxt1AgPTHMshZ)1TsN7Fr5kTDQtMiTWV8hoLhK)YRJOyGhN)ARw4Q9)AZyKCQL9keinqifx(RBLo3)ADLA6wPZDQAI8xvtK56X8Fr7Tjy5I8YFiiUFq(lVoIIbEC(RTAHR2)RnJrYPw2RqG0WbPdesJcPenwPMIxJSqmc2YjyNwxG0aH0G)1TsN7FTUsnDR05ovnr(RQjYC9y(VJ8YLlzrMEYV8hcg8b5V86ikg4X5V2QfUA)V2mgjNAzVcbsdhKoW)6wPZ9VwxPMUv6CNQMi)v1ezUEm)3rE5YLSiV8YF1k2MXiU8G8hc(G8xEDefd848YFiGpi)LxhrXapoV8hg2dYF51rumWJZl)bC5b5V86ikg4X5VN4kD(VdWFDR05(3t8QDef)3t8AUEm)3Q1MsBdrE5pmWhK)YRJOyGhN)ARw4Q9)kUIxXGOYeqCvUedVoIIb(RBLo3)w8yLyiyF5pCApi)1TsN7F1Qed1F51rumWJZl)Ha8dYFDR05(xRlt0SI)lVoIIbECE5pmapi)LxhrXapoV8hoLhK)6wPZ9VAP05(xEDefd848YFiiUFq(RBLo3)IWfHRq)LxhrXapoV8YFh5LlxYI8G8hc(G8xEDefd8483tCLo)3HG0Gq6riDiiLOXk1u8AKfIrWwob706cKgginiKoiKoCifuqQ4kEfdsPlUAsuobRHxhrXaq6Gq6WHu3kDUMYdXgPTHMshZ)1TsN7FpXR2ru8FpXR56X8Flpepfb4L)qaFq(lVoIIbEC(RTAHR2)R4kEfdIktaXv5sm86ikgasJcPi6OOgTIbCjl8NemAuzzcXORbPrHueDuudIktaXv5smajglKgfsTzmso1YEfcKcgsXfinkKcKIP8qSP4yVxcKgoifxG0OqQ41ilgPJ5PKtGMH0aHuGumLhInfh79sG0Jq6jE1oIInLhINIa8x3kDU)T4XkXqW(YFyypi)LxhrXapo)fnR5YGw(db)RBLo3)QLPAwmj1ll)YFaxEq(lVoIIbEC(RTAHR2)7qqkOGuPTH6DesXetifuqQ4kEfdIktaXv5sm86ikgasJcPfJwmbRJOyiDqinkKkEnYIr6yEk5eOzinqifift5HytXXEVei9iKEIxTJOyt5H4Pia)1TsN7Flpe)YFyGpi)LxhrXapo)fnR5YGw(db)RBLo3)QLPAwmj1ll)YF40Eq(lVoIIbEC(RTAHR2)R4kEfdIktaXv5sm86ikgasJcPi6OOgevMaIRYLy01G0OqAXXEVeinCGH0amKgfs14I0eHxzgRRKwt1CbPbcPaPykpeB0I1vsRPAUG0HdP42madesJcPIxJSyKoMNsobAgsdesbsXuEi2uCS3lbspcPN4v7ik2uEiEkcWFDR05(3YdXV8hcWpi)LxhrXapo)fnR5YGw(db)RBLo3)QLPAwmj1ll)YFyaEq(lVoIIbEC(RTAHR2)7qqkIokQr6rUitu9cFJUgKIjMq6qqQfRxJmbsdemKgqinkKAZubKySgPh5Imr1l8nfh79sG0aHuuDLAwSfRxJ8u6ygsheshesJcPL3at(eEfJdaqm9cPbcPO6k1SylwVg5P0X8FDR05(xKsxC1KOCc2x(dNYdYF51rumWJZFrZAUmOL)qW)6wPZ9VAzQMfts9YYV8hcI7hK)YRJOyGhN)ARw4Q9)wmAXeSoIIH0OqQ41ilgPJ5PKtGMH0aH0IJ9Ejq6riDiinGq6rinGq6WH0HGuIgRutXRrwigbB5eStRlqAyG0Gq6Gq6WHuqbPIR4vmiLU4Qjr5eSgEDefdaPdcPdhsbsXeN5I2fpTUyK2gAkDm)x3kDU)noZfTlEAD5L)qWGpi)LxhrXapo)fnR5YGw(db)RBLo3)QLPAwmj1ll)YFiyaFq(lVoIIbEC(RTAHR2)BXOftW6ikgsJcPdbPenwPMIxJSqmc2YjyNwxG0aH0GqkMycPdbPEamxTWgmAfWevXeSfVa9oA41rumaKgfsfVgzXiDmpLCc0mKgiKwCS3lbspcPUv6Cnc2YjyNwxmsBdnLoMH0bH0b)RBLo3)kylNGDAD5L)qWH9G8xEDefd848x0SMldA5pe8VUv6C)RwMQzXKuVS8l)HG4YdYF51rumWJZFTvlC1(FjASsnfVgzHyiy0A806cKgiKg8VUv6C)lbJwJNwxE5peCGpi)LxhrXapo)fnR5YGw(db)RBLo3)QLPAwmj1ll)YFi4P9G8xEDefd848xB1cxT)xGumLhInfh79sG0aH0HGu3kDUgc2Ibm2Kiq6ri1TsNRP8qSXMebsddKYlxJ4dPdcPbqHuE5AeFtXJ8cPyIjKIOJIASk2lRtKEhnf7wbsXetifuq6qqQ41ilgPJ5PKtGMH0aHuGumLhInfh79sG0Jq6jE1oIInLhINIaaPd(x3kDU)LGTyGxE5VO92eSCrEq(dbFq(lVoIIbEC(RTAHR2)lIokQrRyaxYc)jbJgvwMqm6AqAuivCfVIbrLjG4QCjgEDefdaPrHueDuudIktaXv5smeXTHG0WbPb8VUv6C)BXJvIHG9L)qaFq(lVoIIbEC(lAwZLbT8hc(x3kDU)vlt1SysQxw(L)WWEq(lVoIIbEC(RTAHR2)lIokQH4N4J8SsVmajg7FDR05(xIFIpYZk96L)aU8G8xEDefd848x0SMldA5pe8VUv6C)RwMQzXKuVS8l)Hb(G8xEDefd848xB1cxT)xIgRutXRrwigTQJD1eJYfSqAGqAqi9iKkUIxXqCeUKmfSgEDefd8x3kDU)vR6yxnXOCb7l)Ht7b5V86ikg4X5VOznxg0YFi4FDR05(xTmvZIjPEz5x(db4hK)YRJOyGhN)ARw4Q9)ckivCfVIH4iCjzkyn86ikgasJcPfJwmbRJOyinkKkEnYIr6yEk5eOzinqifift1AMIJ9Ejq6ri9eVAhrXMQ1MsBdrG0HdPUv6CnvRzK2gAkDm)x3kDU)TATx(ddWdYF51rumWJZFrZAUmOL)qW)6wPZ9VAzQMfts9YYV8hoLhK)YRJOyGhN)ARw4Q9)kUIxXqCeUKmfSgEDefdaPrH0HGuqbPsBd17iKIjMqAXXEVeinCGHua9YLoxiD4qkUnddsJcPACrAIWRmJ1vsRPAUG0aHuGumvRz0I1vsRPAUG0bH0OqQ41ilgPJ5PKtGMH0aHuGumvRzko27LaPhH0t8QDefBQwBkTnebshoKoeKgespcPaPyQwZiTnuVJq6WH0HbPdcPdhsDR05AQwZiTn0u6y(VUv6C)B1AV8hcI7hK)YRJOyGhN)IM1Czql)HG)1TsN7F1YunlMK6LLF5pem4dYF51rumWJZFTvlC1(Fr0rrne)eFKNv6LP4yVxcKgoinya)RBLo3)s8t8rEwPxV8hcgWhK)YRJOyGhN)IM1Czql)HG)1TsN7F1YunlMK6LLF5peCypi)LxhrXapo)1wTWv7)frhf10vUZbSJbXOR9x3kDU)n274x(dbXLhK)YRJOyGhN)IM1Czql)HG)1TsN7F1YunlMK6LLF5peCGpi)n2b9KxUgX)Vb)RBLo3)IYvA7uNmrAH)lVoIIbECE5L)AZubKySKhK)qWhK)YRJOyGhN)ARw4Q9)YlxJ4dPbcgshgUH0Oq6qqQntfqIXAKEKlYevVW3uCS3lbsdeshiKIjMqQntfqIXAKEKlYevVW3uCS3lbsdhKgesh8VUv6C)lcxeUc9YFiGpi)LxhrXapo)1wTWv7)LxUgXhsdemKomC)x3kDU)TxRxRlDUV8hg2dYF51rumWJZFTvlC1(Fr0rrnspYfzIQx4B01(RBLo3)Qt4zlCm5L)aU8G8xEDefd848xB1cxT)xE5AeFdaJ22wG0abdPde3qkMycPi6OOgPh5Imr1l8najg7FDR05(xPh5Imr1l8F5pmWhK)6wPZ9ViCr4kuVJ)LxhrXapoV8hoThK)YRJOyGhN)IM1Czql)HG)1TsN7F1YunlMK6LLF5peGFq(lVoIIbEC(RTAHR2)RnJrYPw2RqGuWqkU)RBLo3)IYLRMOfVbW4)YFyaEq(lVoIIbEC(RTAHR2)R41ilgPJ5PKtGMH0WbPN2aHumXeshcsLoMNsobAgsdhKgCaWnKgfshcsr0rrniCr4kKrxdsXetifrhf10R1R1LoxJUgKoiKo4F1sPZ9ViUikEQLsN7mrN(yRAb))6wPZ9VAP05(YF4uEq(lVoIIbEC(RTAHR2)RnJrYPw2RqG0WbPdesJcP8Y1i(qAGGHu3kDUMYdXgBseinkKcKIP8qSrlwxjTMQ5csdhKgqtqinkKIOJIAKEKlYevVW3ORbPrH0HGueDuudIktaXv5sm6AqkMycPGcsfxXRyquzciUkxIHxhrXaq6GqAuiDiifuqQ4kEftVwVwx6Cn86ikgasXeti1MPciXyn9A9ADPZ1uCS3lbsdesdoaq6GqAuifuqkIokQPxRxRlDUgDT)6wPZ9VeSoqIrmRaE5Lx(RRlyZ6V3ogx)Yl)d]] )
end
