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
            copy = 279526,
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

    spec:RegisterPack( "Feral", 20190805.2325, [[dSe3wbqibOfPsOspsGYLGsc2KO4tcGAucsNsqSkceVIaMfaULaWUO4xqPgguIJjQAzeOEMkbttLOUMaX2ujsFdkPACQeY5GssRdkP4DQeQY8eO6EQu7JG6GQeklKG8qOKstuLi0fvjuvBuLi6KcGyLIkZekj0obOFQse0qvjuHLkaspvvMku0xvjcSxq)vKbJQdt1Ib6Xenzv1Lr2SqFwfnAaDAfRgkj61qHztPBRc7wPFl1Wj0XvjurlxYZrz6KUouTDb03fuJxG05fLwpbsZxL0(Hmmpet477kbbuWyjpwflxewcIrWxqWy9ldFAwrc(eDjg(jbFRFqW3LKk3cFIEwB7FiMWhRXljbFavvKH1Gn2NJceh0i7dSzZbU11Pxz5rfB2CiXg(aXhRgGSqq477kbbuWyjpwflxewcIrWxqWy9lCrWhtKKqaZJLlaFaN)Nwii89jMe(cgIFjPYTi(LyHpFuUGH4avvKH1Gn2NJceh0i7dSzZbU11Pxz5rfB2CiXgLlyi(fd)eNPiEqaaXfmwYJvr8aaXf8fWAeCqq5q5cgIJ1c03tIH1GYfmepaq8l2)tFe)HbU1I4c5mGguUGH4baIhGswpO0hXXCoPkaZq8ljELfXPLQZSiUeijXaX1gXDrrBweVxBwepmqArCmNtQcWme)sIxzr8HH4UTi)NfXXfnOCbdXdaeVfPLQ0VxcXhgId03VL(i(SkvRBTzrCWSiUcKqC))79IhIx0rhi9rCfiXiepqVgh0smdIJ4xcxBwehSvGuH4ZI4GnJH4X5eOYmOCbdXdaehRT3aPsrC1RtstteXL9(hD6LH4AJ4YSslLuVojLzq5cgIhaiEakD0bsiEagi5LMigJwjfGr8tAPAKiUl1PxdkxWq8aaXVy)pIlKB9vsi(flgND0SiUynDnAwdkxWq8aaXdqPzLDj2LReIZ6dcX7iI)aE09Li(NcWmeN(JYmWNy1XXsWxWq8ljvUfXVel85JYfmehOQImSgSX(CuG4GgzFGnBoWTUo9klpQyZMdj2OCbdXVy4N4mfXdcaiUGXsESkIhaiUGVawJGdckhkxWqCSwG(EsmSguUGH4baIFX(F6J4pmWTwexiNb0GYfmepaq8auY6bL(ioMZjvbygIFjXRSioTuDMfXLajjgiU2iUlkAZI49AZI4HbslIJ5CsvaMH4xs8klIpme3Tf5)SioUObLlyiEaG4TiTuL(9si(WqCG((T0hXNvPADRnlIdMfXvGeI7)FVx8q8Io6aPpIRajgH4b614GwIzqCe)s4AZI4GTcKkeFwehSzmepoNavMbLlyiEaG4yT9givkIREDsAAIiUS3)OtVmexBexMvAPK61jPmdkxWq8aaXdqPJoqcXdWajV0eXy0kPamIFslvJeXDPo9Aq5cgIhai(f7)rCHCRVscXVyX4SJMfXfRPRrZAq5cgIhaiEaknRSlXUCLqCwFqiEhr8hWJUVeX)uaMH40FuMbLdLlyi(f)GssCL(ioif7IqCzFa6kIdsNZYmi(ftkjrLH4BVbaqVoI4we3L60ldX71M1GYfme3L60lZiwKSpaD9oADggOCbdXDPo9YmIfj7dqxf4g7y3FuUGH4UuNEzgXIK9bORcCJTJFEqR660lkxWq8aefXhgIhUlfiIpkIh7cXD7rZueNcKQS9siU2i(HpR6ZI4kWYzar5CPo9YmIfj7dqxf4g7a9ACqlbW6h0noJskWYzabiq3It3ybLZL60lZiwKSpaDvGBSd0RXbTeaRFq34mkPalNbeGaDloDlyaM4TlOunkzcp2FkAjgWI2)SNgADql9r5CPo9YmIfj7dqxf4g7a9ACqlbW6h0DnIjDKyWaiq3It3xekNl1PxMrSizFa6Qa3yx0z1HvGamXBq8y0C09IXSPyxhMFhEZOULw1aA7(RUTxMHwh0sFuoxQtVmJyrY(a0vbUXgNrPrPdaw)GUDbLb0lNLI9QPoMe7WuHY5sD6Lzels2hGUkWn2Ivh2cWeVbXJrZr3lgZMIDDy(D4fLZL60lZiwKSpaDvGBSLUMIDDaWeVbXJrZr3lgZMIDDy(D4fLlyi(BDrgWwr8YNpIdIhJ0hXzQRmehKIDriUSpaDfXbPZzziUVFexSOaqSvD2teFyi(VxYGYfme3L60lZiwKSpaDvGBSzRlYa2AIPUYq5CPo9YmIfj7dqxf4gBXwNEr5CPo9YmIfj7dqxf4gBqQyuHbat8gepgnhDVymBk21H53HxuoxQtVmJyrY(a0vbUXwNtQyPiELfGjEdIhJMJUxmMnf76W87WBgq8y0OZjvSueVYA(D4fLdLlyi(f)GssCL(iofivzrCDoiexbsiUl1Uq8HH4EG(yDqlzq5CPo9YUzyGBTjqNbeGjEhqq8y0iwDyRbxmtabXJrddO)7WhK9BWfr5CPo9Ye4g7cFtUuNEt2HPaS(bDd6wFLeat8wDlTQb0T(kPKhJZoAwdToOL(zaXJrZr3lgZMIDDyWfr5CPo9Ye4gBPBTjxQtVj7Wuaw)GUBrAPcGjEhWwKwQs)EPmQBPvnmhKkTBfOHwh0s)mHcIhJgqQyuHHbx86vq8y0mR0R11PxdUyiOCUuNEzcCJT01uSRdaM4DabXJrJ01uSRddUikNl1PxMa3yxogeat8gepgnIvh2AWfVEfepgnmG(VdFq2VbxeLZL60ltGBSLU1MCPo9MSdtby9d6w2T93HxgkNl1PxMa3yhPQLtJZsGJsaiZkTus96Ku2DEaM49VvtnIgDKym7zMFRMAenfD4ZYc(fYOEDsQrNdkPD6pKW5XsMqv3sRAyoivA3kqdToOL(HGY5sD6LjWn2rQA504Se4OeaYSslLuVojLDNhGjERULw1WCqQ0UvGgADql9Zi7dWoj2ZQmHzIK1MuVojLzuGLZaMKUM53QPgrJosmM9mZVvtnIMIo8zzb)czuVoj1OZbL0o9hs4FRMAenfD4ZYeiqVgh0sMAet6iXGjiUuNEn1iA0rIrsNdcLlyiUl1PxMa3yx0z1HvGamXBzFa2jXEwLDhKmG4XOrSOVRDLnXcprDjgZGlMrDlTQb029xDBVmdToOL(zaXJrdOT7V62EzMFhEr5CPo9Ye4g7cFtUuNEt2HPaS(bDhNDyaPIbWeVL9byNe7zvMWxgLZL60ltGBSLU1MCPo9MSdtby9d6(KwQCTlwYBcGjEZejRnPEDskZOalNbmjDv48OCUuNEzcCJDHVjxQtVj7Wuaw)GUpPLkx7IHYHY5sD6LzKDB)D4LDdsfJkmayI30s1zwHVVawYeQSB7VdVgDoPILI4vwtrh(SmHdY1RG4XOrNtQyPiEL1GlgckNl1PxMr2T93HxMa3yRZjvSueVYcWeVPLQZSMpfh5OcFFPy56vq8y0OZjvSueVYA(D4fLZL60lZi72(7WltGBSbPIrfgZEIY5sD6LzKDB)D4LjWn2kWUwgat82L6eiLOLogIj8Nytr)K61jPSRxlF(jkqAvJ))mZScF5GGY5sD6LzKDB)D4LjWn2kqkHVGn((tXUKeat8gepgnfjXWsmwk2LKm4IxVcIhJgDoPILI4vwdUikNl1PxMr2T93HxMa3yFqhDLn1XKfxo)0Vi)GbWeVbXJrJoNuXsr8kRbxmdiEmAaPIrfgMFhEr5CPo9YmYUT)o8Ye4gBqB3)uhtkqkrlDKfGjEdIhJgDoPILI4vwdUikNl1PxMr2T93HxMa3yhPYTPyrRGMfGjEl7dWoj2ZQSBSGY5sD6LzKDB)D4LjWn2XwIZOFYfuQgLsGKFaWeVDPobsjAPJHyc)j2u0pPEDsk761qlF(jkqAvJ))mZScJvXsgAP6mR5tXroQW3bblHGY5sD6LzKDB)D4LjWn2I41eZo7zc06mfGjE7sDcKs0shdXe(tSPOFs96Ku21RLp)efiTQX)FMzwHVuSGY5sD6LzKDB)D4LjWn2ajV0eXy0kjaM4niEmA05KkwkIxzn4IOCUuNEzgz32FhEzcCJ9SsVwxNEbyI30s1zwHVVawYeQSB7VdVgDoPILI4vwtrh(SmHZhKRxbXJrJoNuXsr8kRbxmeuoxQtVmJSB7VdVmbUXwS1PxaM4T61jPgDoOK2P)qb)sdY1RHQZbL0o9hk45ViSKjuq8y0asfJkmm4IxVcIhJMzLETUo9AWfdjeuoxQtVmJSB7VdVmbUXMb0)D4dY(byI3Y(aStI9Skl4bjdTuDMv4BxQtVMYXGmYMPz(TAkhdYiEGB1r0oufCbBYNbepgn6CsflfXRSgCXmHcIhJgqB3F1T9Ym4IxVgq1T0QgqB3F1T9Ym06Gw6hsMqdO6wAvZSsVwxNEn06Gw6F9QSB7VdVMzLETUo9Ak6WNLjC(lkKmbeepgnZk9ADD61GlIY5sD6LzKDB)D4LjWn24mknkDaW6h0TZagOVelvUG2vs2LBbyI3FcepgnLlODLKD520NaXJrZVdVxV(jq8y0i79Jl1jqknlgPpbIhJgCXmQxNKA05GsANeLA6cyj45nb561a(jq8y0i79Jl1jqknlgPpbIhJgCXmH(jq8y0uUG2vs2LBtFcepgnm1Lyi8TGdsaKhlcYNaXJrdOT7FQJjfiLOLoYAWfVEvNdkPD6puWVmwcjdiEmA05KkwkIxznfD4ZYeopwq5CPo9YmYUT)o8Ye4gBCgLgLoaGIrsQP1pOBzwPT1Q3rMaTotbyI3HslvNznFkoYrf(MwQoZAk6Kwb5cHKbepgn6CsflfXRSMFhEZeqxqPAuYGvIVNwkfXRSgADql9r5CPo9YmYUT)o8Ye4gBCgLgLoaGIrsQP1pOBzwPT1Q3rMaTotbyI3G4XOrNtQyPiEL1GlMXfuQgLmyL47PLsr8kRHwh0sFuoxQtVmJSB7VdVmbUXgNrPrPdaOyKKAA9d62fugqVCwk2RM6ysSdtfat8MwQoZA(uCKJk8DqWckNl1PxMr2T93HxMa3yJZO0O0bdGjEdIhJgDoPILI4vwdU41R6CqjTt)HcUGXckhkNl1PxMjo7Wasf7UOZQdRabyI3G4XOrSOVRDLnXcprDjgZGlMrDlTQb029xDBVmdToOL(zaXJrdOT7V62EzgM6smcUGr5CPo9YmXzhgqQycCJTy32urSgVKeaXUslfu9opkNl1PxMjo7WasftGBSzEG(jLQ2laM4niEmAyEG(jLQ2lZVdVOCUuNEzM4SddivmbUXwSBBQiwJxscGyxPLcQENhLZL60lZeNDyaPIjWn2I1C42u4YvGaiZkTus96Ku2DEaM4ntKS2K61jPmJynhUnfUCfOW5Z8B1uJOPOdFwwWVmkNl1PxMjo7WasftGBSf72MkI14LKai2vAPGQ35r5CPo9YmXzhgqQycCJTynhUnfUCfiaYSslLuVojLDNhGjEZejRnPEDskZiwZHBtHlxbk8TGr5CPo9YmXzhgqQycCJTy32urSgVKeaXUslfu9opkNl1PxMjo7WasftGBSRreazwPLsQxNKYUZdWeVdO6wAvdZbPs7wbAO1bT0ptrXIyaDqlLr96KuJohus70FiH)TAQr0u0HpltGa9ACqlzQrmPJedMG4sD61uJOrhjgjDoiuoxQtVmtC2HbKkMa3yl2TnveRXljbqSR0sbvVZJY5sD6LzIZomGuXe4g7Aebq96K00eVv3sRAyoivA3kqdToOL(zcnG6iXy2ZRxl6WNLf87pE560RGGfZfYisfBykTA6a3QJODOs4FRMAenIh4wDeTdvHKr96KuJohus70FiH)TAQr0u0HpltGa9ACqlzQrmPJedMGeAEb(TAQr0OJeJzpfKleIG4sD61uJOrhjgjDoiuoxQtVmtC2HbKkMa3yl2TnveRXljbqSR0sbvVZJY5sD6LzIZomGuXe4gBMhOFsPQ9cGjEdIhJgMhOFsPQ9Yu0Hpll45fmkNl1PxMjo7WasftGBSf72MkI14LKai2vAPGQ35r5CPo9YmXzhgqQycCJ9HphamXBq8y0mvVjSspmZGlIY5sD6LzIZomGuXe4g7ivTCACwcCucGdpOjAP6m7DEaKzLwkPEDsk7opkhkNl1PxM5KwQCTl2DrNvhwbcWeVv3sRAaTD)v32lZqRdAPFgq8y0iw031UYMyHNOUeJzWfZaIhJgqB3F1T9Ym)o8Mr2hGDsSNvz3xoZVvt5yqMIo8zzb)YOCUuNEzMtAPY1UycCJDrNvhwbcWeVv3sRAaTD)v32lZqRdAPFgq8y0aA7(RUTxM53H3mG4XOrSOVRDLnXcprDjgZGlMrDlTQXIVELMLjoLRtVgADql9Z8B1uogKPOdFwwWZJY5sD6LzoPLkx7IjWn2GfU62eZ6mGamXBMizTj1RtszgWcxDBIzDgqH)eBk6NuVojLHY5sD6LzoPLkx7IjWn2IDBtfXA8ssae7kTuq178OCUuNEzMtAPY1UycCJTcSCgWK0vaM4DOfflIb0bTuizcLjswBs96KuMrbwodys6QWcoeuoxQtVmZjTu5AxmbUXwSBBQiwJxscGyxPLcQENhLZL60lZCslvU2ftGBSvGLZaMKUcWeVdvDlTQHjPvtDmbA7(BO1bT0pdiEmAysA1uhtG2U)MFhEdjdtKS2K61jPmJcSCgWK0vHVakNl1PxM5KwQCTlMa3yl2TnveRXljbqSR0sbvVZJY5sD6LzoPLkx7IjWn2SWJiLKUcWeVbXJrdtsRM6yc0293GlE9AOUuNEnSWJiLKUA((HFscctKS2K61jPmdl8isjPRchQl1Pxt5yqMVF4NKaH6sD61uoguc0s03OJeJ03p8tsqcsiHeckNl1PxM5KwQCTlMa3yl2TnveRXljbqSR0sbvVZJY5sD6LzoPLkx7IjWn2LJbbGmR0sj1Rtsz35byI3buhjgZEE9AObuDlTQb029xDBVmdToOL(zk6WNLf8pE560RGGfZfcjJ61jPgDoOK2P)qcFzuoxQtVmZjTu5AxmbUXwSBBQiwJxscGyxPLcQENhLZL60lZCslvU2ftGBSlhdcazwPLsQxNKYUZdWeVv3sRAaTD)v32lZqRdAPFgq8y0aA7(RUTxMbxmtOHw0Hpll43y9qYisfBykTA6a3QJODOs4FRMYXGmIh4wDeTdvccwmxuqcjJ61jPgDoOK2P)qcFzuUGH4xcgfiIJvmabXZG4cHjaiEycXL(I44mcXp6EJtriU2ioZdKqCHWeXLa96KyaG4U12HN9eXXziU2ioiPkviErXIyar8YXGq5CPo9YmN0sLRDXe4g7JU34uus6kat8gepgnG2U)QB7LzWfZaIhJgXI(U2v2el8e1LymZVdVzK9byNe7zvwWdckNl1PxM5KwQCTlMa3ydw4QBtmRZacWeVdfepgn6CsflfXRSgCXmHw(8tuG0Qg))zMzfo08cC4bnjb61jXcajqVojwkwUuNEDBicsrsGEDsjDoOqcbLZL60lZCslvU2ftGBSp6EJtrjPRaiZkTus96Ku2DEaM4DrXIyaDqlHY5sD6LzoPLkx7IjWn2IDBtfXA8ssae7kTuq178OCUuNEzMtAPY1UycCJTcSCgWK0vaM4DrXIyaDqlLj0qd0RXbTKbNrjfy5mG3cotObeepgnZk9ADD61GlE9QlOunkzcp2FkAjgWI2)SNgADql9djKRxzIK1MuVojLzuGLZaMKUkC(qq5cgI7sD6LzoPLkx7IjWn2kWYzatsxbyI3fflIb0bTuMa9ACqlzWzusbwod4D(mG4XOrAjVKotN90uKl1mHgqq8y0mR0R11PxdU41RUGs1OKj8y)POLyalA)ZEAO1bT0peuoxQtVmZjTu5AxmbUXwSBBQiwJxscGyxPLcQENhLZL60lZCslvU2ftGBSzHhrkjDfGjEZejRnPEDskZWcpIus6QW5r5CPo9YmN0sLRDXe4gBgWI(amX7FRMYXGmfD4ZYeouxQtVggWI(gzZubCPo9AkhdYiBMga0s1z2qWkqlvNznfDs71RG4XOrAjVKotN90uKlvuouoxQtVmZjTu5AxSK30Ty32urSgVKeaXUslfu9opkNl1PxM5KwQCTlwYBsGBSvGLZaMKUcWeVdTOyrmGoOLUE1L6eiL(TAuGLZaMKUgCxQtGuIw6yigwbbhsgMizTj1Rtszgfy5mGjPRcl4Rxv3sRAysA1uhtG2U)gADql9ZaIhJgMKwn1XeOT7V53H3mmrYAtQxNKYmkWYzatsxf(cOCUuNEzMtAPY1UyjVjbUXwSBBQiwJxscGyxPLcQENhLZL60lZCslvU2fl5njWn2GfU62eZ6mGamXBMizTj1RtszgWcxDBIzDgqH)eBk6NuVojLHY5sD6LzoPLkx7IL8Me4gBXUTPIynEjjaIDLwkO6DEuoxQtVmZjTu5AxSK3Ka3yZcpIus6kat8gepgnmjTAQJjqB3FdUikhkxWqCmbsiElslvi(jTu5wBwep2wBhgXvGeIB7ZrI4DeXvGeIxetr8oI4kqcXDrlaioiUI4ddXzKOxUsFeVXvehiveIh7cXT95iDlIlTEnAwuUGH4xciep8yTiElslIhEuGioMxsaq8SnoIl9fXzEKSzrCPZuexbomepw9bIZuYTkqep8OaBCfXblYXy2teFudkNl1PxMPfPLQBDoPILI4vwuUGH4xmBypldXBrAr8WJceXlhdcaex2ld)y2teNPKBvGiUVFeVxcXfctexc0RtcXdDIiU6wAv6hckNl1PxMPfPLkbUXUCmiaM4Da1rIXSNxVcIhJgXQdBn4IOCbdXXkskdXpCmieNHxeIhMqCA)iUcKq8wKwQq8lUm6ItCAL0fxepmqAr8gVq84umfXRreXhgIRJeJzpr5cgI7sD6LzArAPsGBSd0RXbTeaRFq3TiTuL(9saeOBXP7FRMAen6iXy2tuUGH4cvKJbI34kI3rexbsiUl1Pxe3omfLlyiUl1PxMPfPLkbUXoSpkamsEJfdwWsEaM49VvtnIgDKym7jkxWq8aKiIhMqCGEGeIJvmabae33pId0dK2aSI4UOODOpIpkINLuehNri(r3BCkYGY5sD6LzArAPsGBSp6EJtrjPRamX7aQJeJzpr5cgIVnIVe9rCTr8W(OiESlepiiow7fhme33ShDraG4yL4mfXRreX99J4Hje3lcXXfrCF)iEHV7SNOCUuNEzMwKwQe4gBXAoCBkC5kqaM4Tl1jqkrlDmet48zcfepgn6CsflfXRSgCXmHcIhJgqB3F1T9Ym4IxVgq1T0QgqB3F1T9Ym06Gw6hsMqdO6wAvJfF9knltCkxNEn06Gw6F96VvZr3BCkkjD1OJeJzpdjta1rIXSNHGY5sD6LzArAPsGBSRreGjE7sDcKs0shdXUZNjuq8y0OZjvSueVYAWfZekiEmAaTD)v32lZGlE9Aav3sRAaTD)v32lZqRdAPFiz(TAkhdYOJeJzpZeAav3sRAS4RxPzzIt560RHwh0s)Rx)TAo6EJtrjPRgDKym7zizcOosmM9meuouoxQtVmdOB9vs3m8nofbWeVlkwedOdAPRxd1L6eiLOLogIjC(mH(B1WW34uKPOyrmGoOLUE1L6eiL(TAy4BCkk4UuNaPeT0XqSqcbLZL60lZa6wFLKa3yBXxVsmTgmiaM4Tl1jqkrlDmet4lF9AOUuNaPeT0XqmHZNbepgnw81ReDi2HP6Gw1GlgckNl1PxMb0T(kjbUXM1wVsHlxbcWeVDPobsjAPJHycl4mG4XOH1wVs0HyhMQdAvdUikNl1PxMb0T(kjbUXMPEXWRtcLZL60lZa6wFLKa3yZARxPWLRabyI3G4XOH1wVs0HyhMQdAvdUikNl1PxMb0T(kjbUX2IVELyAnyqamXBq8y0yXxVs0HyhMQdAvdUikNl1PxMb0T(kjbUXM1wVsHlxbcFbsfB6fcOGXsESkwW6c(Imc(cWxyV2zpzWxaYHyxk9r8lcXDPo9I42HPmdkh854kWUGV3CG1cF2HPmiMWxlslvqmHaMhIj85sD6f(05KkwkIxzHpADql9HcbviGcgIj8rRdAPpui4twJs14WxarCDKym7jIF9kIdIhJgXQdBn4IWNl1Px4RCmiOcb8cqmHpADql9HcbFYAuQgh(ciIRJeJzpHpxQtVW3r3BCkkjDfQqaVmet4Jwh0sFOqWNSgLQXHpxQtGuIw6yigIlmINhXZG4HI4G4XOrNtQyPiEL1GlI4zq8qrCq8y0aA7(RUTxMbxeXVEfXdiIRULw1aA7(RUTxMHwh0sFepeepdIhkIhqexDlTQXIVELMLjoLRtVgADql9r8Rxr8FRMJU34uus6QrhjgZEI4HG4zq8aI46iXy2tepe4ZL60l8jwZHBtHlxbcviGbbIj8rRdAPpui4twJs14WNl1jqkrlDmedXVr88iEgepuehepgn6CsflfXRSgCrepdIhkIdIhJgqB3F1T9Ym4Ii(1RiEarC1T0QgqB3F1T9Ym06Gw6J4HG4zq8FRMYXGm6iXy2tepdIhkIhqexDlTQXIVELMLjoLRtVgADql9r8Rxr8FRMJU34uus6QrhjgZEI4HG4zq8aI46iXy2tepe4ZL60l8vJiuHk8DslvU2fl5nbXecyEiMWhToOL(qHGVyxPLcQcbmp85sD6f(e72MkI14LKGkeqbdXe(O1bT0hke8jRrPAC4lueVOyrmGoOLq8RxrCxQtGu63Qrbwodys6kIhCe3L6eiLOLogIH4yfqCbJ4HG4zqCMizTj1Rtszgfy5mGjPRiUWiUGr8RxrC1T0QgMKwn1XeOT7VHwh0sFepdIdIhJgMKwn1XeOT7V53HxepdIZejRnPEDskZOalNbmjDfXfgXVa85sD6f(uGLZaMKUcviGxaIj8rRdAPpui4l2vAPGQqaZdFUuNEHpXUTPIynEjjOcb8YqmHpADql9HcbFYAuQgh(yIK1MuVojLzalC1TjM1zarCHr8pXMI(j1RtszWNl1Px4dSWv3MywNbeQqadcet4Jwh0sFOqWxSR0sbvHaMh(CPo9cFIDBtfXA8ssqfc4LcXe(O1bT0hke8jRrPAC4depgnmjTAQJjqB3FdUi85sD6f(yHhrkjDfQqf((u0XTketiG5HycF06Gw6dfc(K1Ouno8fqehepgnIvh2AWfr8miEarCq8y0Wa6)o8bz)gCr4ZL60l8XWa3AtGodiuHakyiMWhToOL(qHGpznkvJdFQBPvnGU1xjL8yC2rZAO1bT0hXZG4G4XO5O7fJztXUom4IWNl1Px4RW3Kl1P3KDyk8zhMMw)GGpq36RKGkeWlaXe(O1bT0hke8jRrPAC4lGiElslvPFVeINbXv3sRAyoivA3kqdToOL(iEgepuehepgnGuXOcddUiIF9kIdIhJMzLETUo9AWfr8qGpxQtVWN0T2Kl1P3KDyk8zhMMw)GGVwKwQGkeWldXe(O1bT0hke8jRrPAC4lGioiEmAKUMIDDyWfHpxQtVWN01uSRdOcbmiqmHpADql9HcbFYAuQgh(aXJrJy1HTgCre)6vehepgnmG(VdFq2Vbxe(CPo9cFLJbbviGxket4Jwh0sFOqWNl1Px4t6wBYL60BYomf(SdttRFqWNSB7VdVmOcbeRdXe(O1bT0hke85sD6f(Iu1YPXzjWrj4twJs14W3VvtnIgDKym7jINbX)TAQr0u0HpldXdoIFbepdIREDsQrNdkPD6peIlmINhliEgepuexDlTQH5GuPDRan06Gw6J4HaFYSslLuVojLbbmpuHaErqmHpADql9HcbFUuNEHVivTCACwcCuc(K1Ouno8PULw1WCqQ0UvGgADql9r8miUSpa7KypRYqCHrCMizTj1Rtszgfy5mGjPRiEge)3QPgrJosmM9eXZG4)wn1iAk6WNLH4bhXVaINbXvVoj1OZbL0o9hcXfgX)TAQr0u0HpldXfaXd0RXbTKPgXKosmyiUGG4UuNEn1iA0rIrsNdc(KzLwkPEDskdcyEOcbeRcXe(O1bT0hke8jRrPAC4t2hGDsSNvziUWi(LHpxQtVWxHVjxQtVj7Wu4ZomnT(bbFXzhgqQyqfcyESaXe(O1bT0hke8jRrPAC4JjswBs96KuMrbwodys6kIlmINh(CPo9cFs3AtUuNEt2HPWNDyAA9dc(oPLkx7IL8MGkeW85HycF06Gw6dfc(CPo9cFf(MCPo9MSdtHp7W006he8DslvU2fdQqf(els2hGUcXecyEiMWhToOL(qHGVwe(yKcFUuNEHVa9ACqlbFb6wCc(Wc8fOxP1pi4dNrjfy5mGqfcOGHycF06Gw6dfc(Ar4Jrk85sD6f(c0RXbTe8fOBXj4tWWNSgLQXHpxqPAuYeES)u0smGfT)zpn06Gw6dFb6vA9dc(WzusbwodiuHaEbiMWhToOL(qHGVwe(yKcFUuNEHVa9ACqlbFb6wCc(Ui4lqVsRFqWxnIjDKyWGkeWldXe(O1bT0hke8jRrPAC4depgnhDVymBk21H53HxepdIRULw1aA7(RUTxMHwh0sF4ZL60l8v0z1HvGqfcyqGycF06Gw6dfc(w)GGpxqza9YzPyVAQJjXomvWNl1Px4ZfugqVCwk2RM6ysSdtfuHaEPqmHpADql9HcbFYAuQgh(aXJrZr3lgZMIDDy(D4f(CPo9cFIvh2cviGyDiMWhToOL(qHGpznkvJdFG4XO5O7fJztXUom)o8cFUuNEHpPRPyxhqfc4fbXe(CPo9cFITo9cF06Gw6dfcQqaXQqmHpADql9HcbFYAuQgh(aXJrZr3lgZMIDDy(D4f(CPo9cFGuXOcdOcbmpwGycF06Gw6dfc(K1Ouno8bIhJMJUxmMnf76W87WlINbXbXJrJoNuXsr8kR53Hx4ZL60l8PZjvSueVYcvOcFN0sLRDXGycbmpet4Jwh0sFOqWNSgLQXHp1T0QgqB3F1T9Ym06Gw6J4zqCq8y0iw031UYMyHNOUeJzWfr8mioiEmAaTD)v32lZ87WlINbXL9byNe7zvgIFJ4xgXZG4)wnLJbzk6WNLH4bhXVm85sD6f(k6S6WkqOcbuWqmHpADql9HcbFYAuQgh(u3sRAaTD)v32lZqRdAPpINbXbXJrdOT7V62EzMFhEr8mioiEmAel67AxztSWtuxIXm4IiEgexDlTQXIVELMLjoLRtVgADql9r8mi(Vvt5yqMIo8zziEWr88WNl1Px4ROZQdRaHkeWlaXe(O1bT0hke8jRrPAC4JjswBs96KuMbSWv3MywNbeXfgX)eBk6NuVojLbFUuNEHpWcxDBIzDgqOcb8YqmHpADql9HcbFXUslfufcyE4ZL60l8j2TnveRXljbviGbbIj8rRdAPpui4twJs14WxOiErXIyaDqlH4HG4zq8qrCMizTj1Rtszgfy5mGjPRiUWiUGr8qGpxQtVWNcSCgWK0vOcb8sHycF06Gw6dfc(IDLwkOkeW8WNl1Px4tSBBQiwJxscQqaX6qmHpADql9HcbFYAuQgh(cfXv3sRAysA1uhtG2U)gADql9r8mioiEmAysA1uhtG2U)MFhEr8qq8miotKS2K61jPmJcSCgWK0vexye)cWNl1Px4tbwodys6kuHaErqmHpADql9HcbFXUslfufcyE4ZL60l8j2TnveRXljbviGyviMWhToOL(qHGpznkvJdFG4XOHjPvtDmbA7(BWfr8Rxr8qrCxQtVgw4rKssxnF)WpjexqqCMizTj1Rtszgw4rKssxrCHr8qrCxQtVMYXGmF)Wpjexaepue3L60RPCmOeOLOVrhjgPVF4NeIliiEqq8qq8qq8qGpxQtVWhl8isjPRqfcyESaXe(O1bT0hke8f7kTuqviG5HpxQtVWNy32urSgVKeuHaMppet4Jwh0sFOqWNl1Px4RCmi4twJs14WxarCDKym7jIF9kIhkIhqexDlTQb029xDBVmdToOL(iEgeVOdFwgIhCe)JxUo9I4ccIJfZfq8qq8miU61jPgDoOK2P)qiUWi(LHpzwPLsQxNKYGaMhQqaZlyiMWhToOL(qHGVyxPLcQcbmp85sD6f(e72MkI14LKGkeW8xaIj8rRdAPpui4ZL60l8voge8jRrPAC4tDlTQb029xDBVmdToOL(iEgehepgnG2U)QB7LzWfr8miEOiEOiErh(Smep43iowhXdbXZG4IuXgMsRMoWT6iAhQqCHr8FRMYXGmIh4wDeTdviUGG4yXCrbbXdbXZG4QxNKA05GsAN(dH4cJ4xg(KzLwkPEDskdcyEOcbm)LHycF06Gw6dfc(K1Ouno8bIhJgqB3F1T9Ym4IiEgehepgnIf9DTRSjw4jQlXyMFhEr8miUSpa7KypRYq8GJ4bb(CPo9cFhDVXPOK0vOcbmFqGycF06Gw6dfc(K1Ouno8fkIdIhJgDoPILI4vwdUiINbXdfXlF(jkqAvJ))mZSiUWiEOiEEexae)WdAsc0RtIH4baIlb61jXsXYL60RBr8qqCbbXlsc0RtkPZbH4HG4HaFUuNEHpWcxDBIzDgqOcbm)LcXe(O1bT0hke85sD6f(o6EJtrjPRWNSgLQXHVIIfXa6Gwc(KzLwkPEDskdcyEOcbmpwhIj8rRdAPpui4l2vAPGQqaZdFUuNEHpXUTPIynEjjOcbm)fbXe(O1bT0hke8jRrPAC4ROyrmGoOLq8miEOiEOiEGEnoOLm4mkPalNbeXVrCbJ4zq8qr8aI4G4XOzwPxRRtVgCre)6ve3fuQgLmHh7pfTedyr7F2tdToOL(iEiiEii(1RiotKS2K61jPmJcSCgWK0vexyeppIhc85sD6f(uGLZaMKUcviG5XQqmHpADql9HcbFXUslfufcyE4ZL60l8j2TnveRXljbviGcglqmHpADql9HcbFYAuQgh(yIK1MuVojLzyHhrkjDfXfgXZdFUuNEHpw4rKssxHkeqbNhIj8rRdAPpui4twJs14W3Vvt5yqMIo8zziUWiEOiUl1PxddyrFJSzkIlaI7sD61uogKr2mfXdaeNwQoZI4HG4yfqCAP6mRPOtAr8RxrCq8y0iTKxsNPZEAkYLk85sD6f(yal6dvOcFXzhgqQyqmHaMhIj8rRdAPpui4twJs14WhiEmAel67AxztSWtuxIXm4IiEgexDlTQb029xDBVmdToOL(iEgehepgnG2U)QB7LzyQlXaXdoIly4ZL60l8v0z1HvGqfcOGHycF06Gw6dfc(IDLwkOkeW8WNl1Px4tSBBQiwJxscQqaVaet4Jwh0sFOqWNSgLQXHpq8y0W8a9tkvTxMFhEHpxQtVWhZd0pPu1EbviGxgIj8rRdAPpui4l2vAPGQqaZdFUuNEHpXUTPIynEjjOcbmiqmHpADql9HcbFUuNEHpXAoCBkC5kq4twJs14WhtKS2K61jPmJynhUnfUCfiIlmINhXZG4)wn1iAk6WNLH4bhXVm8jZkTus96KugeW8qfc4LcXe(O1bT0hke8f7kTuqviG5HpxQtVWNy32urSgVKeuHaI1HycF06Gw6dfc(CPo9cFI1C42u4YvGWNSgLQXHpMizTj1RtszgXAoCBkC5kqex4BexWWNmR0sj1RtszqaZdviGxeet4Jwh0sFOqWxSR0sbvHaMh(CPo9cFIDBtfXA8ssqfciwfIj8rRdAPpui4ZL60l8vJi8jRrPAC4lGiU6wAvdZbPs7wbAO1bT0hXZG4fflIb0bTeINbXvVoj1OZbL0o9hcXfgX)TAQr0u0HpldXfaXd0RXbTKPgXKosmyiUGG4UuNEn1iA0rIrsNdc(KzLwkPEDskdcyEOcbmpwGycF06Gw6dfc(IDLwkOkeW8WNl1Px4tSBBQiwJxscQqaZNhIj8rRdAPpui4twJs14WN6wAvdZbPs7wbAO1bT0hXZG4HI4beX1rIXSNi(1RiErh(Smep43i(hVCD6fXfeehlMlG4zqCrQydtPvth4wDeTdviUWi(VvtnIgXdCRoI2HkepeepdIREDsQrNdkPD6peIlmI)B1uJOPOdFwgIlaIhOxJdAjtnIjDKyWqCbbXdfXZJ4cG4)wn1iA0rIXSNiUGG4xaXdbXfee3L60RPgrJosms6CqWNl1Px4RgrOcbmVGHycF06Gw6dfc(IDLwkOkeW8WNl1Px4tSBBQiwJxscQqaZFbiMWhToOL(qHGpznkvJdFG4XOH5b6NuQAVmfD4ZYq8GJ45fm85sD6f(yEG(jLQ2lOcbm)LHycF06Gw6dfc(IDLwkOkeW8WNl1Px4tSBBQiwJxscQqaZheiMWhToOL(qHGpznkvJdFG4XOzQEtyLEyMbxe(CPo9cFh(CaviG5VuiMWhToOL(qHGVdpOjAP6ml8Lh(CPo9cFrQA504Se4Oe8jZkTus96KugeW8qfQWNSB7VdVmiMqaZdXe(O1bT0hke8jRrPAC4JwQoZI4cFJ4xaliEgepuex2T93HxJoNuXsr8kRPOdFwgIlmIhee)6vehepgn6CsflfXRSgCrepe4ZL60l8bsfJkmGkeqbdXe(O1bT0hke8jRrPAC4JwQoZA(uCKJI4cFJ4xkwq8RxrCq8y0OZjvSueVYA(D4f(CPo9cF6CsflfXRSqfc4fGycFUuNEHpqQyuHXSNWhToOL(qHGkeWldXe(O1bT0hke8jRrPAC4ZL6eiLOLogIH4cJ4FInf9tQxNKYq8Rxr8YNFIcKw14)pZmlIlmIF5GaFUuNEHpfyxldQqadcet4Jwh0sFOqWNSgLQXHpq8y0uKedlXyPyxsYGlI4xVI4G4XOrNtQyPiEL1GlcFUuNEHpfiLWxWgF)PyxscQqaVuiMWhToOL(qHGpznkvJdFG4XOrNtQyPiEL1GlI4zqCq8y0asfJkmm)o8cFUuNEHVd6ORSPoMS4Y5N(f5hmOcbeRdXe(O1bT0hke8jRrPAC4depgn6CsflfXRSgCr4ZL60l8bA7(N6ysbsjAPJSqfc4fbXe(O1bT0hke8jRrPAC4t2hGDsSNvzi(nIJf4ZL60l8fPYTPyrRGMfQqaXQqmHpADql9HcbFYAuQgh(CPobsjAPJHyiUWi(Nytr)K61jPme)6vepueV85NOaPvn()ZmZI4cJ4yvSG4zqCAP6mR5tXrokIl8nIheSG4HaFUuNEHVylXz0p5ckvJsjqYpGkeW8ybIj8rRdAPpui4twJs14WNl1jqkrlDmedXfgX)eBk6NuVojLH4xVI4Lp)efiTQX)FMzwexye)sXc85sD6f(eXRjMD2ZeO1zkuHaMppet4Jwh0sFOqWNSgLQXHpq8y0OZjvSueVYAWfHpxQtVWhqYlnrmgTscQqaZlyiMWhToOL(qHGpznkvJdF0s1zwex4Be)cybXZG4HI4YUT)o8A05KkwkIxznfD4ZYqCHr88bbXVEfXbXJrJoNuXsr8kRbxeXdb(CPo9cFZk9ADD6fQqaZFbiMWhToOL(qHGpznkvJdFQxNKA05GsAN(dH4bhXV0GG4xVI4HI46CqjTt)Hq8GJ45ViSG4zq8qrCq8y0asfJkmm4Ii(1RioiEmAMv61660RbxeXdbXdb(CPo9cFITo9cviG5Vmet4Jwh0sFOqWNSgLQXHpzFa2jXEwLH4bhXdcINbXPLQZSiUW3iUl1Pxt5yqgzZuepdI)B1uogKr8a3QJODOcXdoIlytEepdIdIhJgDoPILI4vwdUiINbXdfXbXJrdOT7V62EzgCre)6vepGiU6wAvdOT7V62EzgADql9r8qq8miEOiEarC1T0QMzLETUo9AO1bT0hXVEfXLDB)D41mR0R11Pxtrh(Smexyep)fH4HG4zq8aI4G4XOzwPxRRtVgCr4ZL60l8Xa6)o8bz)qfcy(GaXe(O1bT0hke85sD6f(CgWa9LyPYf0UsYUCl8jRrPAC47tG4XOPCbTRKSl3M(eiEmA(D4fXVEfX)eiEmAK9(XL6eiLMfJ0NaXJrdUiINbXvVoj1OZbL0ojk10fWcIhCepVjii(1RiEar8pbIhJgzVFCPobsPzXi9jq8y0GlI4zq8qr8pbIhJMYf0UsYUCB6tG4XOHPUedex4BexWbbXdaeppwqCbbX)eiEmAaTD)tDmPaPeT0rwdUiIF9kIRZbL0o9hcXdoIFzSG4HG4zqCq8y0OZjvSueVYAk6WNLH4cJ45Xc8T(bbFodyG(sSu5cAxjzxUfQqaZFPqmHpADql9HcbFUuNEHpzwPT1Q3rMaTotHpznkvJdFHI40s1zwZNIJCuex4BeNwQoZAk6Kwexqq8lG4HG4zqCq8y0OZjvSueVYA(D4fXZG4beXDbLQrjdwj(EAPueVYAO1bT0h(OyKKAA9dc(KzL2wREhzc06mfQqaZJ1HycF06Gw6dfc(CPo9cFYSsBRvVJmbADMcFYAuQgh(aXJrJoNuXsr8kRbxeXZG4UGs1OKbReFpTukIxzn06Gw6dFumssnT(bbFYSsBRvVJmbADMcviG5ViiMWhToOL(qHGpxQtVWNlOmGE5SuSxn1XKyhMk4twJs14WhTuDM18P4ihfXf(gXdcwGpkgjPMw)GGpxqza9YzPyVAQJjXomvqfcyESket4Jwh0sFOqWNSgLQXHpq8y0OZjvSueVYAWfr8RxrCDoOK2P)qiEWrCbJf4ZL60l8HZO0O0bdQqf(aDRVscIjeW8qmHpADql9HcbFYAuQgh(kkwedOdAje)6vepue3L6eiLOLogIH4cJ45r8miEOi(VvddFJtrMIIfXa6GwcXVEfXDPobsPFRgg(gNIq8GJ4UuNaPeT0Xqmepeepe4ZL60l8XW34ueuHakyiMWhToOL(qHGpznkvJdFUuNaPeT0Xqmexye)Yi(1RiEOiUl1jqkrlDmedXfgXZJ4zqCq8y0yXxVs0HyhMQdAvdUiIhc85sD6f(S4RxjMwdgeuHaEbiMWhToOL(qHGpznkvJdFUuNaPeT0XqmexyexWiEgehepgnS26vIoe7WuDqRAWfHpxQtVWhRTELcxUceQqaVmet4ZL60l8XuVy41jbF06Gw6dfcQqadcet4Jwh0sFOqWNSgLQXHpq8y0WARxj6qSdt1bTQbxe(CPo9cFS26vkC5kqOcb8sHycF06Gw6dfc(K1Ouno8bIhJgl(6vIoe7WuDqRAWfHpxQtVWNfF9kX0AWGGkeqSoet4ZL60l8XARxPWLRaHpADql9HcbvOcvOcvie]] )
    
end
