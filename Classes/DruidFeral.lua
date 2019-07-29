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
            talent = "brutal_slash",

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
            indicator = function ()
                if settings.cycle and talent.sabertooth.enabled and dot.rip.down and active_dot.rip > 0 then return "cycle" end
            end,

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

            damage = function ()
                return stat.attack_power * 0.18225
            end,

            tick_damage = function ()
                return stat.attack_power * 0.15561
            end,

            tick_dmg = function ()
                return stat.attack_power * 0.15561
            end,

            form = "cat_form",

            handler = function ()
                applyDebuff( "target", "rake" )
                debuff.rake.pmultiplier = persistent_multiplier

                gain( 1, "combo_points" )
                removeStack( "bloodtalons" )
            end,

            copy = "rake_bleed"
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
                if buff.cat_form.up and time > 0 and buff.predatory_swiftness.down then return false, "predatory_swiftness is down" end
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

            damage = function () return stat.attack_power * 0.28750 * ( active_dot.thrash_cat > 0 and 1.2 or 1 ) end,

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

        potion = "focused_resolve",

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

    spec:RegisterPack( "Feral", 20190728.2300, [[dSuBwbqibOfjOQOhjqCjvIk2KO4tcGAuckNsGAveO6veWSaWTea2ff)ck1WauoMOQLrG8mvcnnavUMkbBtLi9nvIY4euLZrGsRJafENGQsMNGk3tLAFeuhuLiAHeKhsGIMOGQQUOGQsTrvIWjfaXkfvMPkrL2jG8tbvvAOcQkyPcG0tvLPcL8vbvvSxi)vKbJQdt1Ib6Xenzv1Lr2SqFwfnAO40kwTkrvVgGMnLUTkSBL(TKHtOJlOQqlxQNJY0jDDOA7cOVliJxG05fLwpGQMVkP9dAuEewO33vcbKGawEblWUmbfEgbDrGbS8xe90SIe6j6sa9tc9w)GqVlb1Uf9e9S2Y)iSqpwH3sc9WOQitWaBSphfdoOrwhyZMdCRRtTY2Jk2S5qIn6bIpwnazrGO33vcbKGawEblWUmbfEOhtKKiGYdSlIEyM)Nwei69jMe9ccKFjO2TqE4FJpFyUGa5yuvKjyGn2NJIbh0iRdSzZbU11Pwz7rfB2CiXgMliqEoCBwixqHhaqUGawEblKhaqUGeKGHGUmyoyUGa5cMy89KycgWCbbYdai)s()0hYFaIBTqUqodJbMliqEaa5bOK1dk9HCSMtQdWmi)sG3zHCAP(mlKlXqsaHCTGCxu0MfYR1MfYdHHwihR5K6amdYVe4DwiFyqUBBY)zHCCrdmxqG8aaYlrAPo9RLG8Hb5y89BPpKpRs96wBwihmlKRyii3))AdFb5nDubsFixXqmcYd07XbTeZa5qE431MfYblfd1q(SqoyXyqECoXOmdmxqG8aaYfmRnqQvix9(K00eHCzT)rNAzqUwqUmR0sj17tszgyUGa5baKhGshvGeKhGXqERjIXOvsbyi)KwQhjK7sDQ1aZfeipaG8l5)d5c5wFLeKFjJXzhnlKl2t1JM1aZfeipaG8auAwz1Iv7kb5S6GG8kc5pmhvf(J)PamdYP)Omd6j2vCSe6fei)sqTBH8W)gF(WCbbYXOQitWaBSphfdoOrwhyZMdCRRtTY2Jk2S5qInmxqG8C42SqUGcpaGCbbS8cwipaGCbjibdbDzWCWCbbYfmX47jXemG5ccKhaq(L8)PpK)ae3AHCHCggdmxqG8aaYdqjRhu6d5ynNuhGzq(LaVZc50s9zwixIHKac5Ab5UOOnlKxRnlKhcdTqowZj1bygKFjW7Sq(WGC32K)Zc54IgyUGa5baKxI0sD6xlb5ddYX473sFiFwL61T2SqoywixXqqU))1g(cYB6OcK(qUIHyeKhO3JdAjMbYH8WVRnlKdwkgQH8zHCWIXG84CIrzgyUGa5baKlywBGuRqU69jPPjc5YA)Jo1YGCTGCzwPLsQ3NKYmWCbbYdaipaLoQajipaJH8wteJrRKcWq(jTupsi3L6uRbMliqEaa5xY)hYfYT(kji)sgJZoAwixSNQhnRbMliqEaa5bO0SYQfR2vcYz1bb5veYFyoQk8h)tbygKt)rzgyoyUGa5HVdkjXv6d5GuSAcYL1bORqoiDolZa5xsPKevgKV1gay8(iIBHCxQtTmiVwBwdmxqGCxQtTmJytY6a017O1zacZfei3L6ulZi2KSoaDvGBSJv9H5ccK7sDQLzeBswhGUkWn2o(5bTQRtTWCbbYdquiFyqEOQvmq(OqESAi3ThftHCkqQZwlb5Ab5h(SQplKRyANHbMZL6ulZi2KSoaDvGBSd07XbTeaRFq34mkPyANHbGaDloDdmyoxQtTmJytY6a0vbUXoqVhh0saS(bDJZOKIPDggac0T40TGayI3oWt9OKj0y)POLyyAA)ZEAO1bT0hMZL6ulZi2KSoaDvGBSd07XbTeaRFq39iM0rcidGaDloDhEWCUuNAzgXMK1bORcCJDtNDfsXaWeVbXJrZrvlGZMIvFy(vOnJ6wAvdOTQV62AzgADql9H5CPo1YmInjRdqxf4gBCgLgLoay9d62bEggVDwkwRMQysScrnmNl1PwMrSjzDa6Qa3yl2vilat8gepgnhvTaoBkw9H5xHwyoxQtTmJytY6a0vbUXw6Akw9bat8gepgnhvTaoBkw9H5xHwyUGa5V1fzykfYBF(qoiEmsFiNPUYGCqkwnb5Y6a0vihKoNLb5((HCXMcaXs1zpH8Hb5)AjdmxqGCxQtTmJytY6a0vbUXMTUidtPjM6kdMZL6ulZi2KSoaDvGBSflDQfMZL6ulZi2KSoaDvGBSbPMrnGamXBq8y0Cu1c4SPy1hMFfAH5CPo1YmInjRdqxf4gBDoPMLI4DwaM4niEmAoQAbC2uS6dZVcTzaXJrJoNuZsr8oR5xHwyoyUGa5HVdkjXv6d5uGuNfY15GGCfdb5UuRgYhgK7b6J1bTKbMZL6ul7MbiU1MaDggaM4DabXJrJyxHSgCXmbeepgnmm(VcDq2VbxeMZL6ultGBSB8n5sDQnzhMcW6h0nOB9vsamXB1T0Qgq36RKsEmo7Ozn06Gw6NbepgnhvTaoBkw9HbxeMZL6ultGBSLU1MCPo1MSdtby9d6UePLAaM4DalrAPo9RLYegiEmAaPMrnGgCXRxbXJrZSsVxxNAn4IbdZ5sDQLjWn2sxtXQpayI3beepgnsxtXQpm4IWCUuNAzcCJD7asamXBq8y0i2viRbx86vq8y0WW4)k0bz)gCryoxQtTmbUXw6wBYL6uBYomfG1pOBzv2FfAzWCUuNAzcCJDK6sofolbokbGmR0sj17tsz35byI3)sn9iA0rc4SNz(LA6r000HpllCxmJ69jPgDoOKwP)qcNhyzctDlTQH5GuRvPym06Gw6hmmNl1PwMa3yhPUKtHZsGJsaiZkTus9(Ku2DEaM4T6wAvdZbPwRsXyO1bT0pJSoaRKynRYeMjswBs9(KuMrX0odts6AMFPMEen6ibC2Zm)sn9iAA6WNLfUlMr9(KuJohusR0FiH)LA6r000HpltGa9ECqlz6rmPJeqMG7sDQ10JOrhjGjDoiyUGa5UuNAzcCJDtNDfsXaWeVL1byLeRzv29fYaIhJgXM(UwD2el0e1LymdUyg1T0QgqBvF1T1Ym06Gw6NbepgnG2Q(QBRLz(vOfMZL6ultGBSB8n5sDQnzhMcW6h0DC2HHHAgat8wwhGvsSMvzcdCWCUuNAzcCJT0T2Kl1P2KDykaRFq3N0sTRvZsEramXBMizTj17tszgft7mmjPRcNhMZL6ultGBSB8n5sDQnzhMcW6h09jTu7A1myoyoxQtTmJSk7VcTSBqQzudiat8MwQpZk89fbwMWKvz)vO1OZj1SueVZAA6WNLj8fUEfepgn6CsnlfX7SgCXGH5CPo1YmYQS)k0Ye4gBDoPMLI4DwaM4nTuFM18P4ihv47lfyxVcIhJgDoPMLI4DwZVcTWCUuNAzgzv2FfAzcCJni1mQbC2tyoxQtTmJSk7VcTmbUXwXu9YayI3UuNaPeT0XqmH)eBA6NuVpjLD9A7ZprbsRA8)NzMvyG7cWCUuNAzgzv2FfAzcCJTIHs4lyHV)uSAjbWeVbXJrttsaTeJLIvljdU41RG4XOrNtQzPiEN1GlcZ5sDQLzKvz)vOLjWn2h0r1ztvmzXLZp9BYpyamXBq8y0OZj1SueVZAWfZaIhJgqQzudO5xHwyoxQtTmJSk7VcTmbUXg0w1pvXKIHs0shzbyI3G4XOrNtQzPiEN1GlcZ5sDQLzKvz)vOLjWn2rQDBk20c8zbyI3Y6aSsI1Sk7gyWCUuNAzgzv2FfAzcCJDSK4m6NCGN6rPei5hamXBxQtGuIw6yiMWFInn9tQ3NKYUEnS2NFIcKw14)pZmRWcwGLHwQpZA(uCKJk89fawWWCUuNAzgzv2FfAzcCJTiEpXSZEMaTotbyI3UuNaPeT0XqmH)eBA6NuVpjLD9A7ZprbsRA8)NzMv4lfyWCbbYDPo1YmYQS)k0Ye4gBmK3AIymALeat8gepgn6CsnlfX7SgCryoxQtTmJSk7VcTmbUXEwP3RRtTamXBAP(mRW3xeyzctwL9xHwJoNuZsr8oRPPdFwMW5VW1RG4XOrNtQzPiEN1GlgmmNl1PwMrwL9xHwMa3ylw6ulat8w9(KuJohusR0FOWDPx461W05GsAL(dfU8HhWYegiEmAaPMrnGgCXRxbXJrZSsVxxNAn4IbhmmNl1PwMrwL9xHwMa3yZW4)k0bz)amXBzDawjXAwLfUlKHwQpZk8Tl1Pwt7asgzX0m)snTdizepWT6iAhQdNGm5ZaIhJgDoPMLI4DwdUyMWaXJrdOTQV62AzgCXRxdO6wAvdOTQV62AzgADql9dotybuDlTQzwP3RRtTgADql9VEvwL9xHwZSsVxxNAnnD4ZYeoF4fCMacIhJMzLEVUo1AWfH5CPo1YmYQS)k0Ye4gBCgLgLoay9d62zyc0xILAh4RojR2TamX7pbIhJM2b(QtYQDB6tG4XO5xH2Rx)eiEmAK1(XL6eiLMfW0NaXJrdUyg17tsn6CqjTsIsnDrGfU8MlC9Aa)eiEmAK1(XL6eiLMfW0NaXJrdUyMW(eiEmAAh4RojR2TPpbIhJgM6saf(wqxiaYdmb)tG4XOb0w1pvXKIHs0shzn4IxVQZbL0k9hkCahWcodiEmA05KAwkI3znnD4ZYeopWG5CPo1YmYQS)k0Ye4gBCgLgLoaGIrsQP1pOBzwPT0U2rMaTotbyI3Hrl1NznFkoYrf(MwQpZAA6Kwb)IbNbepgn6CsnlfX7SMFfAZeqh4PEuYC5X3tlLI4DwdToOL(WCUuNAzgzv2FfAzcCJnoJsJshaqXij106h0TmR0wAx7itGwNPamXBq8y0OZj1SueVZAWfZ4ap1JsMlp(EAPueVZAO1bT0hMZL6ulZiRY(RqltGBSXzuAu6aakgjPMw)GUDGNHXBNLI1QPkMeRqudWeVPL6ZSMpfh5OcFFbGbZ5sDQLzKvz)vOLjWn24mknkDWayI3G4XOrNtQzPiEN1GlE9QohusR0FOWjiGbZbZ5sDQLzIZommuZUB6SRqkgaM4niEmAeB67A1ztSqtuxIXm4Izu3sRAaTv9v3wlZqRdAPFgq8y0aAR6RUTwMHPUeWWjiyoxQtTmtC2HHHAMa3ylwLn1eRWBjbqS60sbvVZdZ5sDQLzIZommuZe4gBMhOFsPU8gGjEdIhJgMhOFsPU828RqlmNl1PwMjo7WWqntGBSfRYMAIv4TKaiwDAPGQ35H5CPo1YmXzhggQzcCJTyphUnfQDfdaYSslLuVpjLDNhGjEZejRnPEFskZi2ZHBtHAxXiC(m)sn9iAA6WNLfoGdMZL6ulZeNDyyOMjWn2IvztnXk8wsaeRoTuq178WCUuNAzM4Sddd1mbUXwSNd3Mc1UIbazwPLsQ3NKYUZdWeVzIK1MuVpjLze75WTPqTRye(wqWCUuNAzM4Sddd1mbUXwSkBQjwH3scGy1PLcQENhMZL6ulZeNDyyOMjWn29icGmR0sj17tsz35byI3buDlTQH5GuRvPym06Gw6NPPytmmoOLYOEFsQrNdkPv6pKW)sn9iAA6WNLjqGEpoOLm9iM0rcitWDPo1A6r0OJeWKohemNl1PwMjo7WWqntGBSfRYMAIv4TKaiwDAPGQ35H5CPo1YmXzhggQzcCJDpIaOEFsAAI3QBPvnmhKATkfJHwh0s)mHfqDKao751RnD4ZYc39hVDDQvWbM5IzePMnmLwnDGB1r0oul8VutpIgXdCRoI2H6GZOEFsQrNdkPv6pKW)sn9iAA6WNLjqGEpoOLm9iM0rcitWdlVa)sn9iA0rc4SNc(fdwWDPo1A6r0OJeWKohemNl1PwMjo7WWqntGBSfRYMAIv4TKaiwDAPGQ35H5CPo1YmXzhggQzcCJnZd0pPuxEdWeVbXJrdZd0pPuxEBA6WNLfU8ccMZL6ulZeNDyyOMjWn2IvztnXk8wsaeRoTuq178WCUuNAzM4Sddd1mbUX(WNdaM4niEmAMU20L3dXm4IWCUuNAzM4Sddd1mbUXosDjNcNLahLa4WdAIwQpZENhazwPLsQ3NKYUZdZbZ5sDQLzoPLAxRMD30zxHumamXB1T0QgqBvF1T1Ym06Gw6NbepgnIn9DT6SjwOjQlXygCXmG4XOb0w1xDBTmZVcTzK1byLeRzv2nWL5xQPDajtth(SSWbCWCUuNAzMtAP21QzcCJDtNDfsXaWeVv3sRAaTv9v3wlZqRdAPFgq8y0aAR6RUTwM5xH2mG4XOrSPVRvNnXcnrDjgZGlMrDlTQXIVENMLjoTRtTgADql9Z8l10oGKPPdFww4YdZ5sDQLzoPLAxRMjWn2GnU62eZ6mmamXBMizTj17tszgWgxDBIzDggH)eBA6NuVpjLbZ5sDQLzoPLAxRMjWn2IvztnXk8wsaeRoTuq178WCUuNAzMtAP21QzcCJTIPDgMK0vaM4DynfBIHXbTuWzcJjswBs9(KuMrX0odts6QWckyyoxQtTmZjTu7A1mbUXwSkBQjwH3scGy1PLcQENhMZL6ulZCsl1UwntGBSvmTZWKKUcWeVdtDlTQHjPvtvmbAR6BO1bT0pdiEmAysA1uftG2Q(MFfAdodtKS2K69jPmJIPDgMK0vHVimNl1PwM5KwQDTAMa3ylwLn1eRWBjbqS60sbvVZdZ5sDQLzoPLAxRMjWn2SqJiLKUcWeVbXJrdtsRMQyc0w13GlE9AyUuNAnSqJiLKUA((HFscotKS2K69jPmdl0isjPRchMl1Pwt7asMVF4NKaH5sDQ10oGuc0s03OJeW03p8tsWVqWbhmmNl1PwM5KwQDTAMa3ylwLn1eRWBjbqS60sbvVZdZ5sDQLzoPLAxRMjWn2TdibGmR0sj17tsz35byI3buhjGZEE9AybuDlTQb0w1xDBTmdToOL(zA6WNLfUpE76uRGdmZfdoJ69jPgDoOKwP)qcdCWCUuNAzMtAP21QzcCJTyv2utScVLeaXQtlfu9opmNl1PwM5KwQDTAMa3y3oGeaYSslLuVpjLDNhGjERULw1aAR6RUTwMHwh0s)mG4XOb0w1xDBTmdUyMWcRPdFww4UVSGZisnBykTA6a3QJODOw4FPM2bKmIh4wDeTd1coWmH3fcoJ69jPgDoOKwP)qcdCWCbbYd)mkgi)YnabYZa5cHfaqEicYL(c54mcYpQAJttqUwqoZdKGCHWcYLy8(Kyaa5U1wHM9eYXzqUwqoiPk1qEtXMyyG82bKG5CPo1YmN0sTRvZe4g7JQ240us6kat8gepgnG2Q(QBRLzWfZaIhJgXM(UwD2el0e1LymZVcTzK1byLeRzvw4UamNl1PwM5KwQDTAMa3yd24QBtmRZWaWeVddepgn6CsnlfX7SgCXmH1(8tuG0Qg))zMzfoS8cC4bnjX49jXcajgVpjwk2UuNADBWcEtsmEFsjDoOGdgMZL6ulZCsl1UwntGBSpQAJttjPRaiZkTus9(Ku2DEaM4DtXMyyCqlbZ5sDQLzoPLAxRMjWn2IvztnXk8wsaeRoTuq178WCUuNAzMtAP21QzcCJTIPDgMK0vaM4DtXMyyCqlLjSWc07XbTKbNrjft7mm3cktybeepgnZk9EDDQ1GlE9Qd8upkzcn2FkAjgMM2)SNgADql9do4RxzIK1MuVpjLzumTZWKKUkC(GH5ccK7sDQLzoPLAxRMjWn2kM2zyssxbyI3nfBIHXbTuMa9ECqlzWzusX0odZD(mG4XOrAjVLotN900Kl1mHfqq8y0mR0711PwdU41RoWt9OKj0y)POLyyAA)ZEAO1bT0pyyoxQtTmZjTu7A1mbUXwSkBQjwH3scGy1PLcQENhMZL6ulZCsl1UwntGBSzHgrkjDfGjEZejRnPEFskZWcnIus6QW5H5CPo1YmN0sTRvZe4gBgMM(amX7FPM2bKmnD4ZYeomxQtTggMM(gzXubCPo1AAhqYilMga0s9z2GVCOL6ZSMMoP96vq8y0iTK3sNPZEAAYLkmhmNl1PwM5KwQDTAwYl6wSkBQjwH3scGy1PLcQENhMZL6ulZCsl1Uwnl5fjWn2kM2zyssxbyI3H1uSjggh0sxV6sDcKs)snkM2zyssxdNl1jqkrlDme7YrqbNHjswBs9(KuMrX0odts6QWc66v1T0QgMKwnvXeOTQVHwh0s)mG4XOHjPvtvmbAR6B(vOndtKS2K69jPmJIPDgMK0vHVimNl1PwM5KwQDTAwYlsGBSfRYMAIv4TKaiwDAPGQ35H5CPo1YmN0sTRvZsErcCJnyJRUnXSoddat8MjswBs9(KuMbSXv3MywNHr4pXMM(j17tszWCUuNAzMtAP21QzjVibUXwSkBQjwH3scGy1PLcQENhMZL6ulZCsl1Uwnl5fjWn2SqJiLKUcWeVbXJrdtsRMQyc0w13GlcZbZfeihlmeKxI0snKFsl1U1MfYJL1wHGCfdb526CKqEfHCfdb5nXuiVIqUIHGCx0caKdIRq(WGCgj6TR0hYlCfYXqnb5XQHCBDos3c5sR3JMfMliqE4hcYdnwlKxI0c5HgfdKJ1LaaipBHd5sFHCMhjBwix6mfYvmddYJDDa5mLCRIbYdnkMcxHCWMCaN9eYh1aZ5sDQLzkrAP(wNtQzPiENfMliq(L0gYZYG8sKwip0OyG82bKaaYL1YWpM9eYzk5wfdK77hYRLGCHWcYLy8(KG8WMiKRULwL(bdZ5sDQLzkrAPwGBSBhqcGjEhqDKao751RG4XOrSRqwdUimxqG8lxszq(Hdib5m8MG8qeKt7hYvmeKxI0snKh(KrHpItRKcFc5HWqlKx4nKhNMPqEpIq(WGCDKao7jmxqGCxQtTmtjsl1cCJDGEpoOLay9d6UePL60VwcGaDloD)l10JOrhjGZEcZfeixOMCaH8cxH8kc5kgcYDPo1c52HPWCbbYDPo1YmLiTulWn2H8rbGrYBGzagWYdWeV)LA6r0OJeWzpH5ccKhGeH8qeKJXdKG8l3aeaGCF)qogpqAdWkK7II2H(q(OqEwsHCCgb5hvTXPjdmNl1PwMPePLAbUX(OQnonLKUcWeVdOosaN9eMliq(wq(s0hY1cYd5Jc5XQH8la5cMHpWGCFZEunbaKF5XzkK3JiK77hYdrqU3eKJlc5((H8gF3zpH5CPo1YmLiTulWn2I9C42uO2vmamXBxQtGuIw6yiMW5ZegiEmA05KAwkI3zn4IzcdepgnG2Q(QBRLzWfVEnGQBPvnG2Q(QBRLzO1bT0p4mHfq1T0Qgl(6DAwM40Uo1AO1bT0)61FPMJQ240us6QrhjGZEgCMaQJeWzpdgMZL6ulZuI0sTa3y3Jiat82L6eiLOLogIDNptyG4XOrNtQzPiEN1GlMjmq8y0aAR6RUTwMbx861aQULw1aAR6RUTwMHwh0s)GZ8l10oGKrhjGZEMjSaQULw1yXxVtZYeN21PwdToOL(xV(l1Cu1gNMssxn6ibC2ZGZeqDKao7zWWCWCUuNAzgq36RKUz4BCAcGjE3uSjggh0sxVgMl1jqkrlDmet48zc7xQHHVXPjttXMyyCqlD9Ql1jqk9l1WW340u4CPobsjAPJHybhmmNl1PwMb0T(kjbUX2IVENyApasamXBxQtGuIw6yiMWa31RH5sDcKs0shdXeoFgq8y0yXxVt0HyfI6dAvdUyWWCUuNAzgq36RKe4gBwz9ofQDfdat82L6eiLOLogIjSGYaIhJgwz9orhIviQpOvn4IWCUuNAzgq36RKe4gBM6ndVpjyoxQtTmdOB9vscCJnRSENc1UIbGjEdIhJgwz9orhIviQpOvn4IWCUuNAzgq36RKe4gBl(6DIP9aibWeVbXJrJfF9orhIviQpOvn4IWCUuNAzgq36RKe4gBwz9ofQDfd6fi1SPweqccy5fSa7Yeu4HEH8EN9KHEbihIvR0hYdpi3L6ulKBhMYmWCONDykdHf6vI0sncleq5ryHEUuNArpDoPMLI4Dw0Jwh0sFKqifbKGqyHE06Gw6Jec9K9Oupo6fqixhjGZEc5xVc5G4XOrSRqwdUi65sDQf9AhqcPiGUicl0Jwh0sFKqONShL6XrVac56ibC2t0ZL6ul6Du1gNMssxrkciGdHf6rRdAPpsi0t2Js94ONl1jqkrlDmedYfgYZd5zG8WGCq8y0OZj1SueVZAWfH8mqEyqoiEmAaTv9v3wlZGlc5xVc5beYv3sRAaTv9v3wlZqRdAPpKhmKNbYddYdiKRULw1yXxVtZYeN21PwdToOL(q(1Rq(VuZrvBCAkjD1OJeWzpH8GH8mqEaHCDKao7jKhm65sDQf9e75WTPqTRyqkcOlGWc9O1bT0hje6j7rPEC0ZL6eiLOLogIb53qEEipdKhgKdIhJgDoPMLI4DwdUiKNbYddYbXJrdOTQV62AzgCri)6vipGqU6wAvdOTQV62AzgADql9H8GH8mq(Vut7asgDKao7jKNbYddYdiKRULw1yXxVtZYeN21PwdToOL(q(1Rq(VuZrvBCAkjD1OJeWzpH8GH8mqEaHCDKao7jKhm65sDQf96rePif9oPLAxRML8IqyHakpcl0Jwh0sFKqOxS60sbvraLh9CPo1IEIvztnXk8wsifbKGqyHE06Gw6Jec9K9Oupo6fgK3uSjggh0sq(1RqUl1jqk9l1OyANHjjDfYdhK7sDcKs0shdXG8lhixqqEWqEgiNjswBs9(KuMrX0odts6kKlmKlii)6vixDlTQHjPvtvmbAR6BO1bT0hYZa5G4XOHjPvtvmbAR6B(vOfYZa5mrYAtQ3NKYmkM2zyssxHCHH8lIEUuNArpft7mmjPRifb0fryHE06Gw6Jec9IvNwkOkcO8ONl1Pw0tSkBQjwH3scPiGaoewOhToOL(iHqpzpk1JJEmrYAtQ3NKYmGnU62eZ6mmqUWq(Nytt)K69jPm0ZL6ul6b24QBtmRZWGueqxaHf6rRdAPpsi0lwDAPGQiGYJEUuNArpXQSPMyfEljKIa6sryHE06Gw6Jec9K9Oupo6bIhJgMKwnvXeOTQVbxe9CPo1IESqJiLKUIuKIEFk64wfHfcO8iSqpADql9rcHEYEuQhh9ciKdIhJgXUczn4IqEgipGqoiEmAyy8Ff6GSFdUi65sDQf9yaIBTjqNHbPiGeecl0Jwh0sFKqONl1Pw0RX3Kl1P2KDyk6j7rPEC0tDlTQb0T(kPKhJZoAwdToOL(qEgihepgnhvTaoBkw9Hbxe9SdttRFqOhOB9vsifb0fryHE06Gw6Jec9CPo1IEs3AtUuNAt2HPONShL6XrVac5LiTuN(1sqEgipmihepgnGuZOgqdUiKF9kKdIhJMzLEVUo1AWfH8Grp7W006he6vI0snsrabCiSqpADql9rcHEYEuQhh9ciKdIhJgPRPy1hgCr0ZL6ul6jDnfR(aPiGUacl0Jwh0sFKqONShL6Xrpq8y0i2viRbxeYVEfYbXJrddJ)RqhK9BWfrpxQtTOx7asifb0LIWc9O1bT0hje65sDQf9KU1MCPo1MSdtrp7W006he6jRY(RqldPiGUmewOhToOL(iHqpzpk1JJE)sn9iA0rc4SNqEgi)xQPhrtth(SmipCq(fH8mqU69jPgDoOKwP)qqUWqEEGb5zG8WGC1T0QgMdsTwLIXqRdAPpKhm65sDQf9IuxYPWzjWrj0tMvAPK69jPmeq5rkcOWdHf6rRdAPpsi0t2Js94ON6wAvdZbPwRsXyO1bT0hYZa5Y6aSsI1SkdYfgYzIK1MuVpjLzumTZWKKUc5zG8FPMEen6ibC2tipdK)l10JOPPdFwgKhoi)IqEgix9(KuJohusR0Fiixyi)xQPhrtth(SmixaipqVhh0sMEet6ibKb5coK7sDQ10JOrhjGjDoi0ZL6ul6fPUKtHZsGJsONmR0sj17tsziGYJueqcwewOhToOL(iHqpxQtTOxJVjxQtTj7Wu0t2Js94ONSoaRKynRYGCHHCGd9SdttRFqOxC2HHHAgsraLhyiSqpADql9rcHEUuNArpPBTjxQtTj7Wu0t2Js94OhtKS2K69jPmJIPDgMK0vixyipp6zhMMw)GqVtAP21QzjViKIakFEewOhToOL(iHqpxQtTOxJVjxQtTj7Wu0ZomnT(bHEN0sTRvZqksrpXMK1bORiSqaLhHf6rRdAPpsi0RerpgPONl1Pw0lqVhh0sOxGUfNqpGHEb6DA9dc9WzusX0oddsrajiewOhToOL(iHqVse9yKIEUuNArVa9ECqlHEb6wCc9ee6fO3P1pi0dNrjft7mmONShL6Xrph4PEuYeAS)u0smmnT)zpn06Gw6JueqxeHf6rRdAPpsi0RerpgPONl1Pw0lqVhh0sOxGUfNqVWd9c0706he61JyshjGmKIac4qyHE06Gw6Jec9K9Oupo6bIhJMJQwaNnfR(W8RqlKNbYv3sRAaTv9v3wlZqRdAPp65sDQf9A6SRqkgKIa6ciSqpADql9rcHERFqONd8mmE7SuSwnvXKyfIA0ZL6ul65apdJ3olfRvtvmjwHOgPiGUuewOhToOL(iHqpzpk1JJEG4XO5OQfWztXQpm)k0IEUuNArpXUczrkcOldHf6rRdAPpsi0t2Js94OhiEmAoQAbC2uS6dZVcTONl1Pw0t6Akw9bsrafEiSqpxQtTONyPtTOhToOL(iHqkciblcl0Jwh0sFKqONShL6Xrpq8y0Cu1c4SPy1hMFfArpxQtTOhi1mQbePiGYdmewOhToOL(iHqpzpk1JJEG4XO5OQfWztXQpm)k0c5zGCq8y0OZj1SueVZA(vOf9CPo1IE6CsnlfX7SifPO3jTu7A1mewiGYJWc9O1bT0hje6j7rPEC0tDlTQb0w1xDBTmdToOL(qEgihepgnIn9DT6SjwOjQlXygCripdKdIhJgqBvF1T1Ym)k0c5zGCzDawjXAwLb53qoWb5zG8FPM2bKmnD4ZYG8Wb5ah65sDQf9A6SRqkgKIasqiSqpADql9rcHEYEuQhh9u3sRAaTv9v3wlZqRdAPpKNbYbXJrdOTQV62AzMFfAH8mqoiEmAeB67A1ztSqtuxIXm4IqEgixDlTQXIVENMLjoTRtTgADql9H8mq(Vut7asMMo8zzqE4G88ONl1Pw0RPZUcPyqkcOlIWc9O1bT0hje6j7rPEC0JjswBs9(KuMbSXv3MywNHbYfgY)eBA6NuVpjLHEUuNArpWgxDBIzDggKIac4qyHE06Gw6Jec9IvNwkOkcO8ONl1Pw0tSkBQjwH3scPiGUacl0Jwh0sFKqONShL6XrVWG8MInXW4GwcYdgYZa5Hb5mrYAtQ3NKYmkM2zyssxHCHHCbb5bJEUuNArpft7mmjPRifb0LIWc9O1bT0hje6fRoTuqveq5rpxQtTONyv2utScVLesraDziSqpADql9rcHEYEuQhh9cdYv3sRAysA1uftG2Q(gADql9H8mqoiEmAysA1uftG2Q(MFfAH8GH8mqotKS2K69jPmJIPDgMK0vixyi)IONl1Pw0tX0odts6ksrafEiSqpADql9rcHEXQtlfufbuE0ZL6ul6jwLn1eRWBjHueqcwewOhToOL(iHqpzpk1JJEG4XOHjPvtvmbAR6BWfH8RxH8WGCxQtTgwOrKssxnF)WpjixWHCMizTj17tszgwOrKssxHCHH8WGCxQtTM2bKmF)Wpjixaipmi3L6uRPDaPeOLOVrhjGPVF4NeKl4q(fG8GH8GH8GrpxQtTOhl0isjPRifbuEGHWc9O1bT0hje6fRoTuqveq5rpxQtTONyv2utScVLesraLppcl0Jwh0sFKqONShL6XrVac56ibC2ti)6vipmipGqU6wAvdOTQV62AzgADql9H8mqEth(SmipCq(hVDDQfYfCihyMlc5bd5zGC17tsn6CqjTs)HGCHHCGd9CPo1IETdiHEYSslLuVpjLHakpsraLxqiSqpADql9rcHEXQtlfufbuE0ZL6ul6jwLn1eRWBjHueq5Vicl0Jwh0sFKqONShL6Xrp1T0QgqBvF1T1Ym06Gw6d5zGCq8y0aAR6RUTwMbxeYZa5Hb5Hb5nD4ZYG8WDd5xgKhmKNbYfPMnmLwnDGB1r0oud5cd5)snTdizepWT6iAhQHCbhYbMj8UaKhmKNbYvVpj1OZbL0k9hcYfgYbo0ZL6ul61oGe6jZkTus9(KugcO8ifbuEGdHf6rRdAPpsi0t2Js94OhiEmAaTv9v3wlZGlc5zGCq8y0i2031QZMyHMOUeJz(vOfYZa5Y6aSsI1SkdYdhKFb0ZL6ul6Du1gNMssxrkcO8xaHf6rRdAPpsi0t2Js94OxyqoiEmA05KAwkI3zn4IqEgipmiV95NOaPvn()ZmZc5cd5Hb55HCbG8dpOjjgVpjgKhaqUeJ3NelfBxQtTUfYdgYfCiVjjgVpPKoheKhmKhm65sDQf9aBC1TjM1zyqkcO8xkcl0Jwh0sFKqONShL6XrVMInXW4Gwc9CPo1IEhvTXPPK0v0tMvAPK69jPmeq5rkcO8xgcl0Jwh0sFKqOxS60sbvraLh9CPo1IEIvztnXk8wsifbu(WdHf6rRdAPpsi0t2Js94OxtXMyyCqlb5zG8WG8WG8a9ECqlzWzusX0oddKFd5ccYZa5Hb5beYbXJrZSsVxxNAn4Iq(1RqUd8upkzcn2FkAjgMM2)SNgADql9H8GH8GH8RxHCMizTj17tszgft7mmjPRqUWqEEipy0ZL6ul6PyANHjjDfPiGYlyryHE06Gw6Jec9IvNwkOkcO8ONl1Pw0tSkBQjwH3scPiGeeWqyHE06Gw6Jec9K9Oupo6XejRnPEFskZWcnIus6kKlmKNh9CPo1IESqJiLKUIueqckpcl0Jwh0sFKqONShL6XrVFPM2bKmnD4ZYGCHH8WGCxQtTggMM(gzXuixai3L6uRPDajJSykKhaqoTuFMfYdgYVCGCAP(mRPPtAH8RxHCq8y0iTK3sNPZEAAYLk65sDQf9yyA6JuKIEXzhggQziSqaLhHf6rRdAPpsi0t2Js94OhiEmAeB67A1ztSqtuxIXm4IqEgixDlTQb0w1xDBTmdToOL(qEgihepgnG2Q(QBRLzyQlbeYdhKli0ZL6ul610zxHumifbKGqyHE06Gw6Jec9IvNwkOkcO8ONl1Pw0tSkBQjwH3scPiGUicl0Jwh0sFKqONShL6Xrpq8y0W8a9tk1L3MFfArpxQtTOhZd0pPuxEJueqahcl0Jwh0sFKqOxS60sbvraLh9CPo1IEIvztnXk8wsifb0fqyHE06Gw6Jec9K9Oupo6XejRnPEFskZi2ZHBtHAxXa5cd55H8mq(VutpIMMo8zzqE4GCGd9CPo1IEI9C42uO2vmONmR0sj17tsziGYJueqxkcl0Jwh0sFKqOxS60sbvraLh9CPo1IEIvztnXk8wsifb0LHWc9O1bT0hje6j7rPEC0JjswBs9(KuMrSNd3Mc1UIbYf(gYfe65sDQf9e75WTPqTRyqpzwPLsQ3NKYqaLhPiGcpewOhToOL(iHqVy1PLcQIakp65sDQf9eRYMAIv4TKqkciblcl0Jwh0sFKqONShL6XrVac5QBPvnmhKATkfJHwh0sFipdK3uSjggh0sqEgix9(KuJohusR0Fiixyi)xQPhrtth(SmixaipqVhh0sMEet6ibKb5coK7sDQ10JOrhjGjDoi0ZL6ul61Ji6jZkTus9(KugcO8ifbuEGHWc9O1bT0hje6fRoTuqveq5rpxQtTONyv2utScVLesraLppcl0Jwh0sFKqONShL6Xrp1T0QgMdsTwLIXqRdAPpKNbYddYdiKRJeWzpH8RxH8Mo8zzqE4UH8pE76ulKl4qoWmxeYZa5IuZgMsRMoWT6iAhQHCHH8FPMEenIh4wDeTd1qEWqEgix9(KuJohusR0Fiixyi)xQPhrtth(SmixaipqVhh0sMEet6ibKb5coKhgKNhYfaY)LA6r0OJeWzpHCbhYViKhmKl4qUl1PwtpIgDKaM05GqpxQtTOxpIifbuEbHWc9O1bT0hje6fRoTuqveq5rpxQtTONyv2utScVLesraL)IiSqpADql9rcHEYEuQhh9aXJrdZd0pPuxEBA6WNLb5HdYZli0ZL6ul6X8a9tk1L3ifbuEGdHf6rRdAPpsi0lwDAPGQiGYJEUuNArpXQSPMyfEljKIak)fqyHE06Gw6Jec9K9Oupo6bIhJMPRnD59qmdUi65sDQf9o85aPiGYFPiSqpADql9rcHEhEqt0s9zw0lp65sDQf9IuxYPWzjWrj0tMvAPK69jPmeq5rksrpq36RKqyHakpcl0Jwh0sFKqONShL6XrVMInXW4GwcYVEfYddYDPobsjAPJHyqUWqEEipdKhgK)l1WW340KPPytmmoOLG8RxHCxQtGu6xQHHVXPjipCqUl1jqkrlDmedYdgYdg9CPo1IEm8nonHueqccHf6rRdAPpsi0t2Js94ONl1jqkrlDmedYfgYboi)6vipmi3L6eiLOLogIb5cd55H8mqoiEmAS4R3j6qScr9bTQbxeYdg9CPo1IEw817et7bqcPiGUicl0Jwh0sFKqONShL6XrpxQtGuIw6yigKlmKliipdKdIhJgwz9orhIviQpOvn4IONl1Pw0JvwVtHAxXGueqahcl0ZL6ul6XuVz49jHE06Gw6JecPiGUacl0Jwh0sFKqONShL6Xrpq8y0WkR3j6qScr9bTQbxe9CPo1IESY6Dku7kgKIa6sryHE06Gw6Jec9K9Oupo6bIhJgl(6DIoeRquFqRAWfrpxQtTONfF9oX0EaKqkcOldHf65sDQf9yL17uO2vmOhToOL(iHqksrpzv2FfAziSqaLhHf6rRdAPpsi0t2Js94OhTuFMfYf(gYViWG8mqEyqUSk7VcTgDoPMLI4Dwtth(Smixyi)cq(1RqoiEmA05KAwkI3zn4IqEWONl1Pw0dKAg1aIueqccHf6rRdAPpsi0t2Js94OhTuFM18P4ihfYf(gYVuGb5xVc5G4XOrNtQzPiEN18Rql65sDQf905KAwkI3zrkcOlIWc9CPo1IEGuZOgWzprpADql9rcHueqahcl0Jwh0sFKqONShL6XrpxQtGuIw6yigKlmK)j200pPEFskdYVEfYBF(jkqAvJ))mZSqUWqoWDb0ZL6ul6PyQEzifb0fqyHE06Gw6Jec9K9Oupo6bIhJMMKaAjglfRwsgCri)6vihepgn6CsnlfX7SgCr0ZL6ul6PyOe(cw47pfRwsifb0LIWc9O1bT0hje6j7rPEC0depgn6CsnlfX7SgCripdKdIhJgqQzudO5xHw0ZL6ul6DqhvNnvXKfxo)0Vj)GHueqxgcl0Jwh0sFKqONShL6Xrpq8y0OZj1SueVZAWfrpxQtTOhOTQFQIjfdLOLoYIueqHhcl0Jwh0sFKqONShL6XrpzDawjXAwLb53qoWqpxQtTOxKA3MInTaFwKIasWIWc9O1bT0hje6j7rPEC0ZL6eiLOLogIb5cd5FInn9tQ3NKYG8RxH8WG82NFIcKw14)pZmlKlmKlybgKNbYPL6ZSMpfh5OqUW3q(fagKhm65sDQf9ILeNr)Kd8upkLaj)aPiGYdmewOhToOL(iHqpzpk1JJEUuNaPeT0Xqmixyi)tSPPFs9(KugKF9kK3(8tuG0Qg))zMzHCHH8lfyONl1Pw0teVNy2zptGwNPifbu(8iSqpADql9rcHEYEuQhh9OL6ZSqUW3q(fbgKNbYddYLvz)vO1OZj1SueVZAA6WNLb5cd55VaKF9kKdIhJgDoPMLI4DwdUiKhm65sDQf9Mv6966ulsraLxqiSqpADql9rcHEYEuQhh9uVpj1OZbL0k9hcYdhKFPxaYVEfYddY15GsAL(db5HdYZhEadYZa5Hb5G4XObKAg1aAWfH8RxHCq8y0mR0711PwdUiKhmKhm65sDQf9elDQfPiGYFrewOhToOL(iHqpzpk1JJEY6aSsI1SkdYdhKFbipdKtl1NzHCHVHCxQtTM2bKmYIPqEgi)xQPDajJ4bUvhr7qnKhoixqM8qEgihepgn6CsnlfX7SgCripdKhgKdIhJgqBvF1T1Ym4Iq(1RqEaHC1T0QgqBvF1T1Ym06Gw6d5bd5zG8WG8ac5QBPvnZk9EDDQ1qRdAPpKF9kKlRY(RqRzwP3RRtTMMo8zzqUWqE(WdYdgYZa5beYbXJrZSsVxxNAn4IONl1Pw0JHX)vOdY(rkcO8ahcl0Jwh0sFKqONl1Pw0Zzyc0xILAh4RojR2TONShL6XrVpbIhJM2b(QtYQDB6tG4XO5xHwi)6vi)tG4XOrw7hxQtGuAwatFcepgn4IqEgix9(KuJohusRKOutxeyqE4G88Mla5xVc5beY)eiEmAK1(XL6eiLMfW0NaXJrdUiKNbYddY)eiEmAAh4RojR2TPpbIhJgM6saHCHVHCbDbipaG88adYfCi)tG4XOb0w1pvXKIHs0shzn4Iq(1RqUohusR0FiipCqoWbmipyipdKdIhJgDoPMLI4Dwtth(SmixyippWqV1pi0Zzyc0xILAh4RojR2Tifbu(lGWc9O1bT0hje6j7rPEC0lmiNwQpZA(uCKJc5cFd50s9zwttN0c5coKFripyipdKdIhJgDoPMLI4DwZVcTqEgipGqUd8upkzU847PLsr8oRHwh0sF0ZL6ul6jwsajLnap9tY6qexDDQn9PahjHEumssnT(bHEYSsBPDTJmbADMIueq5VuewOhToOL(iHqpzpk1JJEG4XOrNtQzPiEN1Glc5zGCh4PEuYC5X3tlLI4DwdToOL(ONl1Pw0tSKaskBaE6NK1HiU66uB6tbosc9OyKKAA9dc9KzL2s7Ahzc06mfPiGYFziSqpADql9rcHEYEuQhh9OL6ZSMpfh5OqUW3q(fag65sDQf9CGNHXBNLI1QPkMeRquJEumssnT(bHEoWZW4TZsXA1uftIviQrkcO8Hhcl0Jwh0sFKqONShL6Xrpq8y0OZj1SueVZAWfH8RxHCDoOKwP)qqE4GCbbm0ZL6ul6HZO0O0bdPifPONJRyQg9EZHGjsrkcb]] )
    
end
