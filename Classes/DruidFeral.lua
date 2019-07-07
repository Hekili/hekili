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
        moonfire = {
            id = 164812,
            duration = 16,
            tick_time = function () return 2 * haste end,
            type = "Magic",
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

            spend = -25,
            spendType = "rage",

            startsCombat = false,
            texture = 132276,

            noform = "bear_form",
            handler = function () shift( "bear_form" ) end,
        },


        berserk = {
            id = 106951,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
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

            readyTime = function ()
                if settings.brutal_charges > 0 and active_enemies < 2 then return ( 1 + settings.brutal_charges - charges_fractional ) * recharge end
                return 0
            end,

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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
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

            copy = { "incarnation_king_of_the_jungle", "Incarnation" }
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
            cast = function() return 2.5 * haste * ( buff.lunar_empowerment.up and 0.85 or 1 ) end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135753,

            form = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                removeStack( "lunar_empowerment" )
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

            spend = -10,
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


        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",

            form = "moonkin_form",

            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                applyDebuff( "target", "moonfire" )
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
            gcd = "off",

            startsCombat = false,
            texture = 514640,

            nobuff = "prowl",

            usable = function () return time == 0 or ( boss and buff.jungle_stalker.up ) end,

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

            cycle = "rake",
            min_ttd = 6,

            form = "cat_form",

            --[[ usable = function ()
                if settings.hold_bleed_pct > 0 then
                    local limit = settings.hold_bleed_pct * debuff.rake.duration
                    if target.time_to_die < limit then return false, "target will die in " .. target.time_to_die .. " seconds (<" .. limit .. ")" end
                end
                return true
            end, ]]

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
            min_ttd = 9.6,

            form = "cat_form",

            usable = function ()
                if combo_points.current == 0 then return false, "no combo points" end
                --[[ if settings.hold_bleed_pct > 0 then
                    local limit = settings.hold_bleed_pct * debuff.rip.duration
                    if target.time_to_die < limit then return false, "target will die in " .. target.time_to_die .. " seconds (<" .. limit .. ")" end
                end ]]
                return true
            end,            

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

            form = function () return buff.bear_form.up and "bear_form" or "cat_form" end,

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
            cast = function () return 1.5 * haste * ( buff.solar_empowerment.up and 0.85 or 1 ) end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 535045,

            form = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                removeStack( "solar_empowerment" )
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

            usable = function () return buff.dispellable_enrage.up end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
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
                addStack( "solar_empowerment", nil, 1 )
                addStack( "lunar_empowerment", nil, 1 )
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
                active_dot.sunfire = active_enemies
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

            pvptalent = function ()
                if essence.conflict_and_strife.enabled then return end
                return "thorns"
            end,

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

    spec:RegisterSetting( "brutal_charges", 2, {
        name = "Reserve |T132141:0|t Brutal Slash Charges",
        desc = "If set above zero, the addon will hold these Brutal Slash charges for when 3+ enemies have been detected.",
        icon = 132141,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 0,
        max = 4,
        step = 0.1,
        width = 1.5
    } )    

    spec:RegisterPack( "Feral", 20190707.0903, [[dSemfbqicIfbsk1JiiDjkvi2Kq6tuQGrrqDkcXQaj4veOzbIUfHc7IIFbfnmjvDmjXYOuPNbs00KuPRrPQ2gij(gLQyCek6CuQsRdKqEhLkIMNKkUNkAFesheKuSqc4HGKKjsPIWfPuHYgPurDsqsQvkeZeKqzNGWpPuHQHcskPLsPI0tvPPcs9vkviTxi)vvgmshMQfdQht0Kvvxg1ML4ZQWOHsNwXQbju9AOWSfCBHA3k9BrdNsooiPelxQNJy6KUouTDcvFNsz8ekDEjP1dsQMVKY(bgvbbn6(DLrqy36RyV1Bp1BpM6T36TR9Hs0vRAXORLlXWpy0D9ygDTZC7b01YRgs)JGgDjjElz0fRQweOimX8yuS4WgzgJjzIXdUo5kBVOysMyjMOlm(euO6fbJUFxzee2T(k2B92t92JPEXekRRDHs0LyXseevQhkrxSZ)ZlcgD)mrIUcfqTZC7ba1orJpFqeHcOyv1IafHjMhJIfh2iZymjtmEW1jxz7fftYelXeerOaAe8qva1EGeqTB9vSxavma06ftOO6TxqeqeHcOqvy99GjqrGicfqfdafQ5)5pGEXapeaubCcwdiIqbuXaqTt5Glw(dOqphCBhiaQDgVRcO8Y9rvavILLyaOAcOULvOkGMBOkGAdlVak0Zb32bcGANX7Qa6qaup0S)RcO4wgqeHcOIbGMw8Y97NldOdbqX67pWFaDwL71dHQakCvavXYaQ))5ANeqBoofN)aQILjmGkU3JdhyIbqbu74BOkGcNkwUb0zbu4Kqa0YCGvjgqeHcOIbGcvLR4CRaQ69bRVPaOYC)Jo5saunbuzvzGFQ3hSsmGicfqfda1oLJtXza1oGL9wFmHWRKTda6bVCpsa1L6KRbDT6SmbgDfkGAN52daQDIgF(GicfqXQQfbkctmpgfloSrMXysMy8GRtUY2lkMKjwIjiIqb0i4HQaQ9ajGA36RyVaQyaO1lMqr1BVGiGicfqHQW67btGIarekGkgakuZ)ZFa9IbEiaOc4eSgqeHcOIbGANYbxS8hqHEo42oqau7mExfq5L7JQaQellXaq1eqDlRqvan3qva1gwEbuONdUTdea1oJ3vb0HaOEOz)xfqXTmGicfqfdanT4L73pxgqhcGI13FG)a6Sk3Rhcvbu4QaQILbu))Z1ojG2CCko)bufltyavCVhhoWedGcO2X3qvafovSCdOZcOWjHaOL5aRsmGicfqfdafQkxX5wbu17dwFtbqL5(hDYLaOAcOYQYa)uVpyLyarekGkgaQDkhNIZaQDal7T(ycHxjBha0dE5EKaQl1jxdiIqbuXaqHA(Favap4RKbuOMsz2rRcOw9K9OvnGiGicfqTJjwwIR8hqH5s2mGkZyyxbuy(ywIbqHAKs2sja6MRyG174cEaqDPo5sa0CdvnGicfqDPo5smwnlZyyxplbNGbiIqbuxQtUeJvZYmg2vbpXSK5herOaQl1jxIXQzzgd7QGNy64hX8QUo5cI4sDYLySAwMXWUk4jMnF0PnflKt5egVumXzUym7RKDS5N22OQh4vnWHm)QhYLy41Hd8herOakuTcOdbqTLTIfqhfqlzdOEiojkGYIZD1Czavtan2Nv9zbufB7eSGiUuNCjgRMLzmSRcEIP4EpoCGHC9y(eNWpfB7eSqkUhW5Z6brCPo5smwnlZyyxf8etX9EC4ad56X8joHFk22jyHuCpGZN2fYPC6qDUhLn2MW)vcmbBZ7F2ddVoCG)GiUuNCjgRMLzmSRcEIPvN2cqoLty8sXeN5IXSVs2XMFABbrCPo5smwnlZyyxf8etPRVs2XqoLty8sXeN5IXSVs2XMFABbrekGEx3IGnvaT95dOW4Lc)buI6kbqH5s2mGkZyyxbuy(ywcG67hqTAwmSsvN9aqhcG(ZLnGicfqDPo5smwnlZyyxf8etY6weSP(iQReqexQtUeJvZYmg2vbpX0k1jxqexQtUeJvZYmg2vbpXeMBc3ya5uoHXlftCMlgZ(kzhB(PTfeXL6KlXy1SmJHDvWtm15GBYRG3vHCkNW4LIjoZfJzFLSJn)02cIaIiua1oMyzjUYFaLfN7QaQoXmGQyza1LA2a6qauxCFcoCGnGiUuNCjNemWdHhStWc5uofcmEPyS60wWGBfviW4LIHG1)PTyo8n4wGiUuNCjcEIzJVpxQtUVWquixpMpH9GVsgYPCQEGx1a7bFL8ZlLzhTQHxhoW)OW4LIjoZfJzFLSJn4wGiUuNCjcEIzJVpxQtUVWquixpMptlE5gYPCkK0IxUF)C5OcdJxkgyUjCJHb3Qwny8sXmR0711jxdULiGiUuNCjcEIP01xj7yiNYPqGXlfJ01xj7ydUfiIl1jxIGNy2ogmKt5egVumwDAlyWTQvdgVumeS(pTfZHVb3ceXL6KlrWtmLEi8CPo5(cdrHC9y(uMz4N2wciIl1jxIGNyw4oLtItEWJYqkRkd8t9(GvYzfiNY5pvtpwgDKym7r0FQMESmnh7ZsQdugv9(GvJoX8tZ3FyrRuFuHvpWRAiom3AMkwdVoCG)IaI4sDYLi4jMnF0PnflKt5uMXW5ZkNvjN2pkmEPySA(7A2vFeBtrxMqm4wrvpWRAGdz(vpKlXWRdh4Fuy8sXahY8REixI5N2wqexQtUebpXSX3Nl1j3xyikKRhZNLzhcwUjqoLtzgdNpRCwLiADbrCPo5se8eZgFFUuNCFHHOqUEmFEWl3UMnbebeXL6KlXiZm8tBl5eMBc3ya5uo5L7JQIEcL1hvyzMHFABn6CWn5vW7QMMJ9zjIA)A1GXlfJohCtEf8UQb3seqexQtUeJmZWpTTebpXuNdUjVcExfYPCYl3hvnFUmYrf9eQuFTAW4LIrNdUjVcEx18tBliIl1jxIrMz4N2wIGNycZnHBmM9aeXL6KlXiZm8tBlrWtmvSzVeiNYPl1rC(Xlhpmr0ptMM)p17dwj1Q1(8FS48Qg))jMzfTU2heXL6KlXiZm8tBlrWtmvS8dFHt89)kzlziNYjmEPyAwIrGjKxjBjBWTQvdgVum6CWn5vW7QgClqexQtUeJmZWpTTebpXmMJZU6llVaUC(VFZEmbYPCcJxkgDo4M8k4DvdUvuy8sXaZnHBmm)02cI4sDYLyKzg(PTLi4jMWHm)VS8uS8JxoUkKt5egVum6CWn5vW7QgClqexQtUeJmZWpTTebpXSWThELMxOEviNYPmJHZNvoRsoRheXL6KlXiZm8tBlrWtmlPeNW)Nd15Eu(bZEmKt50L6io)4LJhMi6NjtZ)N69bRKA1eU95)yX5vn()tmZkQ9wFuE5(OQ5ZLroQON2VErarCPo5smYmd)02se8etl8EkvN94bhCIc5uoDPoIZpE54HjI(zY08)PEFWkPwT2N)JfNx14)pXmROqL6brekG6sDYLyKzg(PTLi4jMyzV1hti8kziNYjmEPy05GBYRG3vn4wGiUuNCjgzMHFABjcEI5SsVxxNCHCkN8Y9rvrpHY6JkSmZWpTTgDo4M8k4DvtZX(SerRy)A1GXlfJohCtEf8UQb3seqexQtUeJmZWpTTebpX0k1jxiNYP69bRgDI5NMV)W1bQy)A1ewNy(P57pCDQiM1hvyy8sXaZnHBmm4w1QbJxkMzLEVUo5AWTereqexQtUeJmZWpTTebpXKG1)PTyo8HCkNYmgoFw5SkPo2pkVCFuv0txQtUM2XGnYKOr)PAAhd2yfJh0XkmCxh7AQefgVum6CWn5vW7QgCROcdJxkg4qMF1d5sm4w1Qje1d8Qg4qMF1d5sm86Wb(lsuHfI6bEvZSsVxxNCn86Wb(xRMmZWpTTMzLEVUo5AAo2NLiAfXuKOcbgVumZk9EDDY1GBbI4sDYLyKzg(PTLi4jM4e(nkhtararCPo5smLzhcwUjNwzgEnts8wYqwY(TSy1ZkGiUuNCjMYSdbl3ebpXK4I7h8RtVHCkNW4LIH4I7h8RtVn)02cI4sDYLykZoeSCte8etRmdVMjjElzilz)wwS6zfqexQtUetz2HGLBIGNyA1tShE2AxXcPSQmWp17dwjNvGCkNeloeEQ3hSsmw9e7HNT2vSIwj6pvtpwMMJ9zj1PUGiUuNCjMYSdbl3ebpX0kZWRzsI3sgYs2VLfREwbeXL6KlXuMDiy5Mi4jMw9e7HNT2vSqkRkd8t9(GvYzfiNYjXIdHN69bReJvpXE4zRDfRON2feXL6KlXuMDiy5Mi4jMwzgEnts8wYqwY(TSy1ZkGiUuNCjMYSdbl3ebpXShliLvLb(PEFWk5ScKt5ui6iXy2JA1eU5yFwsDo)4TRtUqH6nqPirfwiQh4vnehMBntfRHxhoWFrQvt4MJ9zj158J3Uo5cfQ3iMrT4MmeLx9fJh0XkmCl6pvtpwgRy8GowHHBrIQEFWQrNy(P57pSOIjiIl1jxIPm7qWYnrWtmTYm8AMK4TKHSK9BzXQNvarCPo5smLzhcwUjcEIjXf3p4xNEd5uoHXlfdXf3p4xNEBAo2NLuNk2feXL6KlXuMDiy5Mi4jMwzgEnts8wYqwY(TSy1ZkGiUuNCjMYSdbl3ebpXm2NyiNYjmEPyMo3huC3gXGBbI4sDYLykZoeSCte8eZc3PCsCYdEugYyxSpE5(O6zfiLvLb(PEFWk5ScKt58NQPhltZX(SeqeqexQtUeZbVC7A2KZMp60MIfYPCQEGx1ahY8REixIHxhoW)OW4LIXQ5VRzx9rSnfDzcXGBffgVumWHm)QhYLy(PTnQmJHZNvoRsoRB0FQM2XGnnh7ZsQtDbrCPo5smh8YTRzte8eZMp60MIfYPCQEGx1ahY8REixIHxhoW)OW4LIboK5x9qUeZpTTrHXlfJvZFxZU6JyBk6YeIb3kQ6bEvtaF9(nlXAAxNCn86Wb(h9NQPDmytZX(SK6ubeXL6KlXCWl3UMnrWtmHBC1dpsWjyHCkNeloeEQ3hSsmWnU6Hhj4eSI(zY08)PEFWkbeXL6KlXCWl3UMnrWtmTYm8AMK4TKHSK9BzXQNvarCPo5smh8YTRzte8etfB7eSpPRqoLtHBU0mbRdhyrIkmXIdHN69bReJITDc2N0vrTRiGiUuNCjMdE521SjcEIPvMHxZKeVLmKLSFllw9SciIl1jxI5GxUDnBIGNyQyBNG9jDfYPCkS6bEvdrYR(YYdoK53WRdh4Fuy8sXqK8QVS8Gdz(n)02ksuIfhcp17dwjgfB7eSpPRIcLGiUuNCjMdE521SjcEIPvMHxZKeVLmKLSFllw9SciIl1jxI5GxUDnBIGNysSnw8t6kKt5egVumejV6llp4qMFdUvTAc7sDY1qSnw8t6Q57X(bdfiwCi8uVpyLyi2gl(jDvuHDPo5AAhd289y)GfuyxQtUM2XGn6iX49JpGc2xerebeXL6KlXCWl3UMnrWtmTYm8AMK4TKHSK9BzXQNvarCPo5smh8YTRzte8eZ2XGHuwvg4N69bRKZkqoLtHOJeJzpQvtyHOEGx1ahY8REixIHxhoW)Onh7ZsQZhVDDYfkuVbkfjQ69bRgDI5NMV)WIwxqexQtUeZbVC7A2ebpX0kZWRzsI3sgYs2VLfREwbeXL6KlXCWl3UMnrWtmBhdgszvzGFQ3hSsoRa5uovpWRAGdz(vpKlXWRdh4Fuy8sXahY8REixIb3kQWc3CSplPoN2JirT4MmeLx9fJh0XkmCl6pvt7yWgRy8GowHHBOq9gX0(Iev9(GvJoX8tZ3FyrRliIqbu7OJIfqHIbvdOrbubGgsa1gdOsFbuCcdOXzULPzavtaL4IZaQaqdOsSEFWeibupesBZEaO4eavtafMvLBaT5sZeSaA7yWGiUuNCjMdE521SjcEIzCMBzA(jDfYPCcJxkg4qMF1d5sm4wrHXlfJvZFxZU6JyBk6YeI5N22OYmgoFw5SkPo2heXL6KlXCWl3UMnrWtmHBC1dpsWjyHCkNcdJxkgDo4M8k4DvdUvuHBF(pwCEvJ))eZSIkCfbJDX(Ky9(GjIHeR3hm5vAxQtUEqeOqZsSEFWpDIzrebeXL6KlXCWl3UMnrWtmJZCltZpPRqkRkd8t9(GvYzfiNYzZLMjyD4adI4sDYLyo4LBxZMi4jMwzgEnts8wYqwY(TSy1ZkGiUuNCjMdE521SjcEIPITDc2N0viNYzZLMjyD4ahvyHf37XHdSbNWpfB7eSN2nQWcbgVumZk9EDDY1GBvRMd15Eu2yBc)xjWeSnV)zpm86Wb(lIi1QrS4q4PEFWkXOyBNG9jDv0kIaIiua1L6KlXCWl3UMnrWtmvSTtW(KUc5uoBU0mbRdh4OI794Wb2Gt4NITDc2ZkrHXlfJmWElDIo7HPzxQrfwiW4LIzwP3RRtUgCRA1COo3JYgBt4)kbMGT59p7HHxhoWFrarCPo5smh8YTRzte8etRmdVMjjElzilz)wwS6zfqexQtUeZbVC7A2ebpXKyBS4N0viNYjXIdHN69bRedX2yXpPRIwbeXL6KlXCWl3UMnrWtmjyB(d5uo)PAAhd20CSplruHDPo5AiyB(BKjrf0L6KRPDmyJmjQyWl3hvfXocVCFu108bV1QbJxkgzG9w6eD2dtZUubrarekGcnwgqtlE5gqp4LBpeQcOLmesBaQILb0qEmsanlaQILb0MjkGMfavXYaQBfGeqHXvaDiakHT82v(dOjUcOy5Mb0s2aAipgPhauzW7rRcIiua1okdO2MqaqtlEbuBJIfqH2odjGwnXbuPVakXlCOkGkDIcOk2HaOLoJbuIYEqXcO2gfBIRakCZogZEaOJAarCPo5smPfVCFQZb3KxbVRcIiuafQjyZRsa00Ixa12Oyb02XGHeqL5sWJN9aqjk7bflG67hqZLbubGgqLy9(GbuHNcGQEGxL)IaI4sDYLyslE5wWtmBhdgYPCkeDKym7rTAW4LIXQtBbdUfiIqbuOySsa0yhdgqj4ndO2yaL3pGQyzanT4LBafQnHHAbNxjd1gqTHLxanXBaTmnrb0ESa0HaO6iXy2dqeHcOUuNCjM0IxUf8etX9EC4ad56X8zAXl3VFUmKI7bC(8NQPhlJosmM9aerOaQan7yaOjUcOzbqvSmG6sDYfqddrbrCHcOsDYLyslE5wWtmT5JcjHLN1BQV(kqoLZFQMESm6iXy2dqeHcOq1fa1gdOyDXzafkgunKaQVFafRloV2bfqDlRWWFaDuaTkRakoHb04m3Y0SbeXL6KlXKw8YTGNygN5wMMFsxHCkNcrhjgZEaIiuaDtaDz(dOAcO28rb0s2aQ9buOkOwjaQVvJZMHeqHIJtuaThla13pGAJbuVzaf3cq99dOn(UZEaI4sDYLyslE5wWtmT6j2dpBTRyHCkNUuhX5hVC8WerRevMXW5ZkNvjIwjQWW4LIrNdUjVcEx1GBfvyy8sXahY8REixIb3QwnHOEGx1ahY8REixIHxhoWFrIkSqupWRAc4R3Vzjwt76KRHxhoW)A1(PAIZCltZpPRgDKym7HirfIosmM9qeqexQtUetAXl3cEIzpwqoLtxQJ48JxoEyYzLOcdJxkgDo4M8k4DvdUvuHHXlfdCiZV6HCjgCRA1eI6bEvdCiZV6HCjgED4a)fj6pvt7yWgDKym7ruHfI6bEvtaF9(nlXAAxNCn86Wb(xR2pvtCMBzA(jD1OJeJzpejQq0rIXShIaIaI4sDYLyG9GVs(KGVLPziNYzZLMjyD4axRMWUuhX5hVC8WerRev4FQgc(wMMnnxAMG1HdCTAUuhX53pvdbFltZ1XL6io)4LJhMiIiGiUuNCjgyp4RKf8eZa(69JO9Gbd5uoDPoIZpE54HjIw3A1e2L6io)4LJhMiALOW4LIjGVE)4yR0g3X8QgClrarCPo5smWEWxjl4jMKm49Zw7kwiNYPl1rC(Xlhpmru7gfgVumKm49JJTsBChZRAWTarCPo5smWEWxjl4jMe1BcEFWGiUuNCjgyp4RKf8etsg8(zRDflKt5egVumKm49JJTsBChZRAWTarCPo5smWEWxjl4jMb817hr7bdgYPCcJxkMa(69JJTsBChZRAWTarCPo5smWEWxjl4jMKm49Zw7kw0vCUjtUiiSB9vS36RB9vmvQluwbDT59o7bbDHQJTYw5pGApaQl1jxanmeLyarq3WquccA0nT4LBe0iiQGGgDDPo5IU6CWn5vW7QOlVoCG)ibqkcc7IGgD51Hd8hja6k7r5EC0viaQosmM9aqRvdqHXlfJvN2cgCl01L6Kl62ogmsrqaLiOrxED4a)rcGUYEuUhhDfcGQJeJzpqxxQtUOBCMBzA(jDfPiiQlcA0LxhoWFKaORShL7XrxxQJ48JxoEycGkkGwbqJcOYmgoFw5SkbqffqRaOrbuHbuy8sXOZb3KxbVRAWTa0OaQWakmEPyGdz(vpKlXGBbO1QbOcbqvpWRAGdz(vpKlXWRdh4pGkcGgfqfgqfcGQEGx1eWxVFZsSM21jxdVoCG)aATAa6pvtCMBzA(jD1OJeJzpaura0OaQqauDKym7bGkc66sDYfDT6j2dpBTRyrkcc7JGgD51Hd8hja6k7r5EC01L6io)4LJhMaONaAfankGkmGcJxkgDo4M8k4DvdUfGgfqfgqHXlfdCiZV6HCjgClaTwnaviaQ6bEvdCiZV6HCjgED4a)bura0Oa6pvt7yWgDKym7bGgfqfgqfcGQEGx1eWxVFZsSM21jxdVoCG)aATAa6pvtCMBzA(jD1OJeJzpaura0OaQqauDKym7bGkc66sDYfD7XcPifDH9GVsgbncIkiOrxED4a)rcGUYEuUhhDBU0mbRdhyaTwnavya1L6io)4LJhMaOIcOva0OaQWa6pvdbFltZMMlntW6WbgqRvdqDPoIZVFQgc(wMMb06aOUuhX5hVC8Weaveave01L6Kl6sW3Y0msrqyxe0OlVoCG)ibqxzpk3JJUUuhX5hVC8WeavuaTUaATAaQWaQl1rC(XlhpmbqffqRaOrbuy8sXeWxVFCSvAJ7yEvdUfGkc66sDYfDd4R3pI2dgmsrqaLiOrxED4a)rcGUYEuUhhDDPoIZpE54HjaQOaQDb0OakmEPyizW7hhBL24oMx1GBHUUuNCrxsg8(zRDflsrquxe0ORl1jx0LOEtW7dgD51Hd8hjasrqyFe0OlVoCG)ibqxzpk3JJUW4LIHKbVFCSvAJ7yEvdUf66sDYfDjzW7NT2vSifbbubbn6YRdh4psa0v2JY94OlmEPyc4R3po2kTXDmVQb3cDDPo5IUb817hr7bdgPiiShe0ORl1jx0LKbVF2AxXIU86Wb(JeaPifD)CXXdkcAeevqqJU86Wb(JeaDL9OCpo6keafgVumwDAlyWTa0OaQqauy8sXqW6)0wmh(gCl01L6Kl6sWapeEWoblsrqyxe0OlVoCG)ibqxxQtUOBJVpxQtUVWqu0v2JY94OR6bEvdSh8vYpVuMD0QgED4a)b0OakmEPyIZCXy2xj7ydUf6ggI(wpMrxyp4RKrkccOebn6YRdh4psa01L6Kl6247ZL6K7lmefDL9OCpo6keanT4L73pxgqJcOcdOW4LIbMBc3yyWTa0A1auy8sXmR0711jxdUfGkc6ggI(wpMr30IxUrkcI6IGgD51Hd8hja6k7r5EC0viakmEPyKU(kzhBWTqxxQtUOR01xj7yKIGW(iOrxED4a)rcGUYEuUhhDHXlfJvN2cgClaTwnafgVumeS(pTfZHVb3cDDPo5IUTJbJueeqfe0OlVoCG)ibqxxQtUOR0dHNl1j3xyik6ggI(wpMrxzMHFABjifbH9GGgD51Hd8hja6k7r5EC09NQPhlJosmM9aqJcO)un9yzAo2NLaO1bqHsankGQEFWQrNy(P57pmGkkGwPEankGkmGQEGx1qCyU1mvSgED4a)burqxxQtUOBH7uojo5bpkJUYQYa)uVpyLGGOcsrqiMiOrxED4a)rcGUYEuUhhDLzmC(SYzvcGEcO2hqJcOW4LIXQ5VRzx9rSnfDzcXGBbOrbu1d8Qg4qMF1d5sm86Wb(dOrbuy8sXahY8REixI5N2w01L6Kl628rN2uSifbH9IGgD51Hd8hja66sDYfDB895sDY9fgIIUYEuUhhDLzmC(SYzvcGkkGwx0nme9TEmJULzhcwUjifbrL6rqJU86Wb(JeaDDPo5IUn((CPo5(cdrr3Wq036Xm6EWl3UMnbPifDTAwMXWUIGgbrfe0OlVoCG)ibqxzpk3JJUW4LIjoZfJzFLSJn)02cOrbu1d8Qg4qMF1d5sm86Wb(JUUuNCr3Mp60MIfPiiSlcA0LxhoWFKaOBAHUewrxxQtUOR4EpoCGrxX9aoJU1JUI79B9ygDXj8tX2oblsrqaLiOrxED4a)rcGUPf6syfDDPo5IUI794WbgDf3d4m6Ax0vCVFRhZOloHFk22jyrxzpk3JJUouN7rzJTj8FLatW28(N9WWRdh4psrquxe0OlVoCG)ibqxzpk3JJUW4LIjoZfJzFLSJn)02IUUuNCrxRoTfqkcc7JGgD51Hd8hja6k7r5EC0fgVumXzUym7RKDS5N2w01L6Kl6kD9vYogPiiGkiOrxxQtUORvQtUOlVoCG)ibqkcc7bbn6YRdh4psa0v2JY94OlmEPyIZCXy2xj7yZpTTORl1jx0fMBc3yGueeIjcA0LxhoWFKaORShL7Xrxy8sXeN5IXSVs2XMFABrxxQtUORohCtEf8Uksrk6EWl3UMnbbncIkiOrxED4a)rcGUYEuUhhDvpWRAGdz(vpKlXWRdh4pGgfqHXlfJvZFxZU6JyBk6YeIb3cqJcOW4LIboK5x9qUeZpTTaAuavMXW5ZkNvja6jGwxankG(t10ogSP5yFwcGwhaTUORl1jx0T5JoTPyrkcc7IGgD51Hd8hja6k7r5EC0v9aVQboK5x9qUedVoCG)aAuafgVumWHm)QhYLy(PTfqJcOW4LIXQ5VRzx9rSnfDzcXGBbOrbu1d8QMa(69BwI10Uo5A41Hd8hqJcO)unTJbBAo2NLaO1bqRGUUuNCr3Mp60MIfPiiGse0OlVoCG)ibqxzpk3JJUeloeEQ3hSsmWnU6Hhj4eSaQOa6NjtZ)N69bRe01L6Kl6c34QhEKGtWIuee1fbn6YRdh4psa0TK9BzXQiiQGUUuNCrxRmdVMjjElzKIGW(iOrxED4a)rcGUYEuUhhDfgqBU0mbRdhyaveankGkmGsS4q4PEFWkXOyBNG9jDfqffqTlGkc66sDYfDvSTtW(KUIueeqfe0OlVoCG)ibq3s2VLfRIGOc66sDYfDTYm8AMK4TKrkcc7bbn6YRdh4psa0v2JY94ORWaQ6bEvdrYR(YYdoK53WRdh4pGgfqHXlfdrYR(YYdoK538tBlGkcGgfqjwCi8uVpyLyuSTtW(KUcOIcOqj66sDYfDvSTtW(KUIueeIjcA0LxhoWFKaOBj73YIvrqubDDPo5IUwzgEnts8wYifbH9IGgD51Hd8hja6k7r5EC0fgVumejV6llp4qMFdUfGwRgGkmG6sDY1qSnw8t6Q57X(bdOqbaLyXHWt9(GvIHyBS4N0vavuavya1L6KRPDmyZ3J9dgqfeqfgqDPo5AAhd2OJeJ3p(aqHcaQ9burauraurqxxQtUOlX2yXpPRifbrL6rqJU86Wb(JeaDlz)wwSkcIkORl1jx01kZWRzsI3sgPiiQubbn6YRdh4psa0v2JY94ORqauDKym7bGwRgGkmGkeav9aVQboK5x9qUedVoCG)aAuaT5yFwcGwha9J3Uo5cOqbaTEducOIaOrbu17dwn6eZpnF)Hburb06IUUuNCr32XGrxzvzGFQ3hSsqqubPiiQyxe0OlVoCG)ibq3s2VLfRIGOc66sDYfDTYm8AMK4TKrkcIkqjcA0LxhoWFKaORShL7Xrx1d8Qg4qMF1d5sm86Wb(dOrbuy8sXahY8REixIb3cqJcOcdOcdOnh7Zsa06CcO2dGkcGgfqT4MmeLx9fJh0XkmCdOIcO)unTJbBSIXd6yfgUbuOaGwVrmTpGkcGgfqvVpy1Otm)089hgqffqRl66sDYfDBhdgDLvLb(PEFWkbbrfKIGOsDrqJU86Wb(JeaDL9OCpo6cJxkg4qMF1d5sm4waAuafgVumwn)Dn7QpITPOltiMFABb0OaQmJHZNvoRsa06aO2hDDPo5IUXzULP5N0vKIGOI9rqJU86Wb(JeaDL9OCpo6kmGcJxkgDo4M8k4DvdUfGgfqfgqBF(pwCEvJ))eZSaQOaQWaAfavqan2f7tI17dMaOIbGkX69btEL2L6KRhaurauOaG2SeR3h8tNygqfbqfbDDPo5IUWnU6Hhj4eSifbrfOccA0LxhoWFKaORShL7Xr3MlntW6WbgDDPo5IUXzULP5N0v0vwvg4N69bReeevqkcIk2dcA0LxhoWFKaOBj73YIvrqubDDPo5IUwzgEnts8wYifbrfXebn6YRdh4psa0v2JY94OBZLMjyD4adOrbuHbuHbuX9EC4aBWj8tX2oblGEcO2fqJcOcdOcbqHXlfZSsVxxNCn4waATAaQd15Eu2yBc)xjWeSnV)zpm86Wb(dOIaOIaO1QbOeloeEQ3hSsmk22jyFsxburb0kaQiORl1jx0vX2ob7t6ksrquXErqJU86Wb(JeaDlz)wwSkcIkORl1jx01kZWRzsI3sgPiiSB9iOrxED4a)rcGUYEuUhhDjwCi8uVpyLyi2gl(jDfqffqRGUUuNCrxITXIFsxrkcc7wbbn6YRdh4psa0v2JY94O7pvt7yWMMJ9zjaQOaQWaQl1jxdbBZFJmjkGkiG6sDY10ogSrMefqfdaLxUpQcOIaO2rauE5(OQP5dEb0A1auy8sXidS3sNOZEyA2Lk66sDYfDjyB(JuKIULzhcwUjiOrqubbn6YRdh4psa0TK9BzXQiiQGUUuNCrxRmdVMjjElzKIGWUiOrxED4a)rcGUYEuUhhDHXlfdXf3p4xNEB(PTfDDPo5IUexC)GFD6nsrqaLiOrxED4a)rcGULSFllwfbrf01L6Kl6ALz41mjXBjJuee1fbn6YRdh4psa0v2JY94OlXIdHN69bReJvpXE4zRDflGkkGwbqJcO)un9yzAo2NLaO1bqRl66sDYfDT6j2dpBTRyrxzvzGFQ3hSsqqubPiiSpcA0LxhoWFKaOBj73YIvrqubDDPo5IUwzgEnts8wYifbbubbn6YRdh4psa0v2JY94OlXIdHN69bReJvpXE4zRDflGk6jGAx01L6Kl6A1tShE2AxXIUYQYa)uVpyLGGOcsrqypiOrxED4a)rcGULSFllwfbrf01L6Kl6ALz41mjXBjJueeIjcA0LxhoWFKaORShL7XrxHaO6iXy2daTwnavyaT5yFwcGwNta9J3Uo5cOqbaTEducOIaOrbuHbuHaOQh4vnehMBntfRHxhoWFaveaTwnavyaT5yFwcGwNta9J3Uo5cOqbaTEJycOrbulUjdr5vFX4bDScd3aQOa6pvtpwgRy8GowHHBaveankGQEFWQrNy(P57pmGkkGkMORl1jx0Thl0vwvg4N69bReeevqkcc7fbn6YRdh4psa0TK9BzXQiiQGUUuNCrxRmdVMjjElzKIGOs9iOrxED4a)rcGUYEuUhhDHXlfdXf3p4xNEBAo2NLaO1bqRyx01L6Kl6sCX9d(1P3ifbrLkiOrxED4a)rcGULSFllwfbrf01L6Kl6ALz41mjXBjJueevSlcA0LxhoWFKaORShL7Xrxy8sXmDUpO4UnIb3cDDPo5IUX(eJueevGse0OBSl2hVCFufDRGUUuNCr3c3PCsCYdEugDLvLb(PEFWkbbrf0LxhoWFKaORShL7Xr3FQMESmnh7ZsqksrxzMHFABjiOrqubbn6YRdh4psa0v2JY94OlVCFufqf9eqHY6b0OaQWaQmZWpTTgDo4M8k4DvtZX(Seavua1(aATAakmEPy05GBYRG3vn4waQiORl1jx0fMBc3yGuee2fbn6YRdh4psa0v2JY94OlVCFu185Yihfqf9eqHk1dO1QbOW4LIrNdUjVcEx18tBl66sDYfD15GBYRG3vrkccOebn66sDYfDH5MWngZEGU86Wb(JeaPiiQlcA0LxhoWFKaORShL7XrxxQJ48JxoEycGkkG(zY08)PEFWkbqRvdqBF(pwCEvJ))eZSaQOaADTp66sDYfDvSzVeKIGW(iOrxED4a)rcGUYEuUhhDHXlftZsmcmH8kzlzdUfGwRgGcJxkgDo4M8k4DvdUf66sDYfDvS8dFHt89)kzlzKIGaQGGgD51Hd8hja6k7r5EC0fgVum6CWn5vW7QgClankGcJxkgyUjCJH5N2w01L6Kl6gZXzx9LLxaxo)3VzpMGuee2dcA0LxhoWFKaORShL7Xrxy8sXOZb3KxbVRAWTqxxQtUOlCiZ)llpfl)4LJRIueeIjcA0LxhoWFKaORShL7XrxzgdNpRCwLaONaA9ORl1jx0TWThELMxOEvKIGWErqJU86Wb(JeaDL9OCpo66sDeNF8YXdtaurb0ptMM)p17dwjaATAaQWaA7Z)XIZRA8)NyMfqffqT36b0OakVCFu185Yihfqf9eqTF9aQiORl1jx0TKsCc)FouN7r5hm7XifbrL6rqJU86Wb(JeaDL9OCpo66sDeNF8YXdtaurb0ptMM)p17dwjaATAaA7Z)XIZRA8)NyMfqffqHk1JUUuNCrxl8EkvN94bhCIIueevQGGgD51Hd8hja6k7r5EC0LxUpQcOIEcOqz9aAuavyavMz4N2wJohCtEf8UQP5yFwcGkkGwX(aATAakmEPy05GBYRG3vn4waQiORl1jx0DwP3RRtUifbrf7IGgD51Hd8hja6k7r5EC0v9(GvJoX8tZ3FyaToakuX(aATAaQWaQoX8tZ3FyaToaAfXSEankGkmGcJxkgyUjCJHb3cqRvdqHXlfZSsVxxNCn4waQiaQiORl1jx01k1jxKIGOcuIGgD51Hd8hja6k7r5EC0vMXW5ZkNvjaADau7dOrbuE5(OkGk6jG6sDY10ogSrMefqJcO)unTJbBSIXd6yfgUb06aO21ubqJcOW4LIrNdUjVcEx1GBbOrbuHbuy8sXahY8REixIb3cqRvdqfcGQEGx1ahY8REixIHxhoWFaveankGkmGkeav9aVQzwP3RRtUgED4a)b0A1auzMHFABnZk9EDDY10CSplbqffqRiMaQiaAuaviakmEPyMv6966KRb3cDDPo5IUeS(pTfZHpsrquPUiOrxxQtUOloHFJYXe0LxhoWFKaifPifDDCfB2O7DIHQqksria]] )
    
end
