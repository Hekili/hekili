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
        cyclone = {
            id = 209753,
            duration = 6,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
        },
        eclipse_lunar = {
            id = 48518,
            duration = 10,
            max_stack = 1,
        },
        eclipse_solar = {
            id = 48517,
            duration = 10,
            max_stack = 1,
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
            max_stack = 1,
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
        heart_of_the_wild = {
            id = 108291,
            duration = 45,
            max_stack = 1
        },
        hibernate = {
            id = 2637,
            duration = 40,
        },
        incarnation = {
            id = 102543,
            duration = 30,
            max_stack = 1,
        },
        infected_wounds = {
            id = 48484,
            duration = 12,
            type = "Disease",
            max_stack = 1,
        },
        ironfur = {
            id = 192081,
            duration = 7,
            max_stack = function () return talent.guardian_affinity.enabled and 2 or 1 end
        },
        jungle_stalker = {
            id = 252071,
            duration = 30,
            max_stack = 1,
        },
        maim = {
            id = 22570,
            duration = 5,
            max_stack = 1,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        mighty_bash = {
            id = 5211,
            duration = 4,
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
            duration = 3600,
            max_stack = 1,
        },
        omen_of_clarity = {
            id = 16864,
            duration = 16,
            max_stack = function () return talent.moment_of_clarity.enabled and 2 or 1 end,
        },
        predatory_swiftness = {
            id = 16974,
            duration = 12,
            type = "Magic",
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
            type = "Magic",
            max_stack = 1,
        },
        rip = {
            id = 1079,
            duration = 24,
            tick_time = function() return 2 * haste end,
        },
        savage_roar = {
            id = 52610,
            duration = 36,
            max_stack = 1,
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
        stampeding_roar = {
            id = 77764,
            duration = 8,
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = 12,
            type = "Magic",
            max_stack = 1,
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
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        wild_charge = {
            id = 102401,
            duration = 0.5,
            max_stack = 1,
        },
        yseras_gift = {
            id = 145108,
            duration = 3600,
            max_stack = 1
        },


        -- PvP Talents
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


        -- Legendaries
        apex_predators_craving = {
            id = 339140,
            duration = 15,
            max_stack = 1,
        },

        druid_feral_runecarve_2 = {
            id = 339142,
            duration = 15,
            max_stack = 1,
        },        
    } )


    -- Snapshotting
    local tf_spells = { rake = true, rip = true, thrash_cat = true, moonfire_cat = true, primal_wrath = true }
    local bt_spells = { rip = true }
    local mc_spells = { thrash_cat = true }
    local pr_spells = { rake = true }

    local snapshot_value = {
        tigers_fury = 1.15,
        bloodtalons = 1.3,
        clearcasting = 1.15, -- TODO: Only if talented MoC, not used by 8.1 script
        prowling = 2
    }

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


    spec:RegisterStateExpr( "lunar_eclipse", function ()
        return 0
    end )

    spec:RegisterStateExpr( "solar_eclipse", function ()
        return 0
    end )

    spec:RegisterHook( "reset_precast", function ()
        if buff.cat_form.down then
            energy.regen = 10 + ( stat.haste * 10 )
        end
        debuff.rip.pmultiplier = nil
        debuff.rake.pmultiplier = nil
        debuff.thrash.pmultiplier = nil

        -- Eclipses
        solar_eclipse = buff.eclipse_lunar.up and 2 or GetSpellCount( 197628 )
        lunar_eclipse = buff.eclipse_solar.up and 2 or GetSpellCount( 5176 )

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
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            toggle = "false",

            startsCombat = false,
            texture = 136097,
            
            handler = function ()
                applyBuff( "barkskin" )
            end,
        },


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
            nobuff = "berserk", -- VoP

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
            id = 33786,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "cyclone",

            spend = 0.1,
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
            gcd = "off",

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
                if buff.apex_predator.up or buff.apex_predators_craving.up then return 0 end
                -- going to require 50 energy and then refund it back...
                if talent.sabertooth.enabled and debuff.rip.up then
                    -- Let's make FB available sooner if we need to keep a Rip from falling off.
                    local nrg = 50 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 )
                    
                    if energy[ "time_to_" .. nrg ] - debuff.rip.remains > 0 then
                        return max( 25, energy.current + ( (debuff.rip.remains - 1 ) * energy.regen ) )
                    end
                end
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

                if buff.apex_predator.up or buff.apex_predators_craving.up then
                    applyBuff( "predatory_swiftness" )
                    removeBuff( "apex_predator" )
                    removeBuff( "apex_predators_craving" )
                else
                    -- gain( 25, "energy" )
                    if combo_points.current == 5 then applyBuff( "predatory_swiftness" ) end
                    spend( min( 5, combo_points.current ), "combo_points" )
                end

                removeStack( "bloodtalons" )

                if buff.druid_feral_runecarve_2.up then gain( 3, "combo_points" ) end

                opener_done = true
            end,
        },


        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            cooldown = 36,
            charges = function () return talent.guardian_affinity.enabled and buff.heart_of_the_wild.up and 2 or nil end,
            recharge = function () return talent.guardian_affinity.enabled and buff.heart_of_the_wild.up and 36 or nil end,
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
            nobuff = "incarnation", -- VoP

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

            spend = 40,
            spendType = "rage",

            startsCombat = false,
            texture = 1378702,

            form = "bear_form",
            talent = "guardian_affinity",

            handler = function ()
                applyBuff( "ironfur", 6 + buff.ironfur.remains )
            end,
        },


        --[[ lunar_strike = {
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
        }, ]]


        maim = {
            id = 22570,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 30 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) end,
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

                if buff.druid_feral_runecarve_2.up then gain( 3, "combo_points" ) end

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
            cooldown = 60,
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

            spend = 0.06,
            spendType = "mana",

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
            aura = "rip",

            spend = 20,
            spendType = "energy",

            startsCombat = true,
            texture = 1392547,

            usable = function () return combo_points.current > 0, "no combo points" end,
            handler = function ()
                applyDebuff( "target", "rip", 2 + 2 * combo_points.current )
                active_dot.rip = active_enemies

                spend( combo_points.current, "combo_points" )

                if buff.druid_feral_runecarve_2.up then gain( 3, "combo_points" ) end

                opener_done = true
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

                if ( query_time - action.thrash_cat.lastCast < 5 ) and ( query_time - action.rake.lastCast < 5 ) then
                    applyBuff( "bloodtalons", nil, 2 )
                end
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

            usable = function ()
                return debuff.dispellable_curse.up or debuff.dispellable_poison.up, "requires dispellable curse or poison"
            end,

            handler = function ()
                removeDebuff( "player", "dispellable_curse" )
                removeDebuff( "player", "dispellable_poison" )
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

                if buff.druid_feral_runecarve_2.up then gain( 3, "combo_points" ) end

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

                if buff.druid_feral_runecarve_2.up then gain( 3, "combo_points" ) end

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
                removeStack( "clearcasting" )

                if ( query_time - action.shred.lastCast < 5 ) and ( query_time - action.rake.lastCast < 5 ) then
                    applyBuff( "bloodtalons", nil, 2 )
                end
            end,
        },


        skull_bash = {
            id = 106839,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            startsCombat = true,
            texture = 236946,

            toggle = "interrupts",
            interrupt = true,

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
                applyBuff( "stampeding_roar" )
            end,
        },


        starfire = {
            id = 197628,
            cast = function () return 2.5 * ( buff.eclipse_lunar.up and 0.92 or 1 ) * haste end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135753,
            
            handler = function ()
                if buff.eclipse_lunar.down and solar_eclipse > 0 then
                    solar_eclipse = solar_eclipse - 1
                    if solar_eclipse == 0 then applyBuff( "eclipse_solar" ) end
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
                if buff.eclipse_lunar.up then buff.eclipse_lunar.expires = buff.eclipse_lunar.expires + 2 end
                if buff.eclipse_solar.up then buff.eclipse_solar.expires = buff.eclipse_solar.expires + 2 end
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
            cooldown = 180,
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
            id = 305497,
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

                removeStack( "clearcasting" )
                if target.within8 then gain( 1, "combo_points" ) end

                if ( query_time - action.shred.lastCast < 5 ) and ( query_time - action.rake.lastCast < 5 ) then
                    applyBuff( "bloodtalons", nil, 2 )
                end
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
                applyBuff( "tigers_fury" )
                if azerite.jungle_fury.enabled then applyBuff( "jungle_fury" ) end

                if legendary.druid_feral_runecarve_2.enabled then
                    applyBuff( "druid_feral_runecarve_2" )
                end
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

            talent = "balance_affinity",

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

            form = "cat_form",

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


        wrath = {
            id = 5176,
            cast = function () return 1.5 * ( buff.eclipse_solar.up and 0.92 or 1 ) * haste end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = true,
            texture = 535045,
            
            handler = function ()
                if buff.eclipse_solar.down and lunar_eclipse > 0 then
                    lunar_eclipse = lunar_eclipse - 1
                    if lunar_eclipse == 0 then applyBuff( "eclipse_lunar" ) end
                end
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

    spec:RegisterPack( "Feral", 20200723.2, [[dKKHvbqiujwKOKepcKQUKQqrBsq9jujvLrjGoLaSkuj5vOcZceULQq1UO4xOsnmvbhtfzzGuEMGOPPkKRjkLTbsfFdvszCIsQZjkjwhQKQmpbH7PkTpiQdkkjvlev0dvfkmrvHsUOOKK2OQqPojQKkRuv0mbPs1obrdfvsv1rbPsXtvPPcr(QOKu2lWFfAWeDyQwmOEmHjRQUmYMf5ZIQrdHtlz1GujVgKmBkDBvy3k9BfdhvDCqQuA5s9CuMoPRdPTli9DrX4fL48QOwVOunFbA)qn4eajW97kbGeApaThEGRbTqAGwiFaAq7e4QN5jWL3fq55e4U(bbUp2u7wWL3pBh)dqcCzdAliWfHQ8mUECZDEPiqHnI5GBwDGADTMv0Es5MvhcUbxy0YQCDlagC)UsaiH2dq7Hh4AqlKGlJNeaip9qibxe1)tlagC)etaUqpw(ytTBXYhRgT(y5JJLq3GwcOWsF)y5Jv16z8t8tOhlFmq4BoX46HFc9y5JJL2XILUILC6wFfe(j0JLpowYPDMV62zzy5okwwh8w6GwL(gWLVNuzjWf6XYhBQDlw(y1O1hlFCSe6g0safw67hlFSQwpJFIFc9y5JbcFZjgxp8tOhlFCS0owS0vSKt36RGWpHES8XXsoTZ8v3oldl3rXY6G3sh0Q03GFIFc9yzw1SqcuL(yjmLMMWsXCa7kwct51YmyzwDHG4vgwUZ(4i8(iHAXsxO1SmSCw7zd(j0JLUqRzzg(MeZbSRVjRZGc)e6XsxO1SmdFtI5a2voE5onZh)e6XsxO1SmdFtI5a2voE52rZpOvDTMf)e6XsUofllgwMzAfbwwkwMMglD7XWuSKcL6ZZsyPoy5HxR61ILkI2ziWpDHwZYm8njMdyx54L7q9UCylbX6h0lkJIkI2ziGiu3IsVpGF6cTMLz4BsmhWUYXl3H6D5WwcI1pOxugfveTZqarOUfLEHgev61Zo1LsMmL9htwIHOP9xBUHwh2sF8txO1SmdFtI5a2voE5ouVlh2sqS(b92fFulbumic1TO0BwJF6cTMLz4BsmhWUYXl3OmkwkDaX6h0RNDgcVDwmnRgNuKFYqn(Pl0AwMHVjXCa7khVCZ3tglev6fgnLmhZSqvBmn9H5pzw8tOhlVRZZqmkw2E9Xsy0uI(yjtDLHLWuAAclfZbSRyjmLxldl99JL8n948JQ1MJLfdl)Zsg8tOhlDHwZYm8njMdyx54LB268meJgzQRm8txO1SmdFtI5a2voE5MF0Aw8txO1SmdFtI5a2voE5gMAg1qbrLEHrtjZXmlu1gttFy(tMf)0fAnlZW3KyoGDLJxU1kNAwmH2NHOsVWOPK5yMfQAJPPpm)jZgggnLmALtnlMq7ZM)KzXpDHwZYm8njMdyx54LBHRX00hquPxy0uYCmZcvTX00hM)KzXpXpHESmRAwibQsFSKcL6ZyPwhewQiiS0f60yzXWspuVSoSLm4NUqRzzVmOqT2iSZqarLE5cmAkz47jJ1GYhMlWOPKHHW)tMdY(nO84NUqRzzC8YDJUrxO1SrBXuiw)GEHDRVccIk9QULw1a7wFfu0tPAl9SHwh2s)WWOPK5yMfQAJPPpmO84NUqRzzC8YTWT2Ol0A2OTykeRFqVdpTudrLE5YWtl1X)Suy1T0QgMdtToJIWqRdBPF4aHrtjdm1mQHYGYhmimAkzQv496AnRbLpa8txO1SmoE5w4Amn9bev6LlWOPKr4Amn9HbLh)0fAnlJJxUBhkcIk9cJMsg(EYynO8bdcJMsggc)pzoi73GYJF6cTMLXXl3c3AJUqRzJ2IPqS(b9kMX(Nmld)0fAnlJJxUtupIAqzr4sjieNfwkQENtk79eev69pQPlEJwcOQnp8Futx8MMo8AzHiKHvVZj1O1bf1j(lc5tpeoq1T0QgMdtToJIWqRdBPFa4NUqRzzC8YDI6rudklcxkbH4SWsr17CszVNGOsVQBPvnmhMADgfHHwh2s)WI5aEI8tTkdzgpzTr17Cszgfr7merHRH)JA6I3OLaQAZd)h10fVPPdVwwiczy17CsnADqrDI)Iq(pQPlEtthETmoc17YHTKPl(OwcOyCLl0Awtx8gTeqf16GWpDHwZY44L7gDJUqRzJ2IPqS(b9MQTyiOMbrLEfZb8e5NAvgYpc)0fAnlJJxUfU1gDHwZgTftHy9d6nNwQDDAw0hcIk9Y4jRnQENtkZOiANHikCf5t4NUqRzzC8YDJUrxO1SrBXuiw)GEZPLAxNMHFIF6cTMLzeZy)tML9ctnJAOGOsV0sD(zKFd5dHdumJ9pzwJw5uZIj0(SPPdVwgYzlyqy0uYOvo1SycTpBq5da)0fAnlZiMX(NmlJJxU1kNAwmH2NHOsV0sD(zZNsLOuKFHopemimAkz0kNAwmH2Nn)jZIF6cTMLzeZy)tMLXXl3WuZOgQAZXpDHwZYmIzS)jZY44LBfX0ldIk96cTcLI0shfXq(tSQPFu9oNuwWGTx)ifkTQX)FMPwKFu2WpDHwZYmIzS)jZY44LBfbfrx4bD)X00ccIk9cJMsMMeqzjglMMwqgu(GbHrtjJw5uZIj0(SbLh)0fAnlZiMX(NmlJJxUpOJPphNu0IkQF83KFWGOsVWOPKrRCQzXeAF2GYhggnLmWuZOgkZFYS4NUqRzzgXm2)KzzC8YnSDMFCsrfbfPLoodrLEHrtjJw5uZIj0(SbLh)0fAnlZiMX(NmlJJxUtu72yQPn7NHOsVI5aEI8tTk79b8txO1SmJyg7FYSmoE5oncug9JE2PUukct(bev61fAfkfPLokIH8Nyvt)O6DoPSGbdS96hPqPvn()Zm1ICw5HW0sD(zZNsLOuKFZ2dbGF6cTMLzeZy)tMLXXl38ODLoxBEe26mfIk96cTcLI0shfXq(tSQPFu9oNuwWGTx)ifkTQX)FMPwKHopGF6cTMLzeZy)tMLXXl35OE)lFJtk6zN6rrarLEHrtjJw5uZIj0(SbLh)0fAnlZiMX(NmlJJxUfZkOvBxPFmz9dcIk9cJMsgTYPMftO9zdkp(Pl0AwMrmJ9pzwghVC3fpVLI1gz8UGGOsVWOPKrRCQzXeAF2GYJF6cTMLzeZy)tMLXXl3zM2(dLQn2eBwFfeev6fgnLmALtnlMq7ZguE8txO1SmJyg7FYSmoE5UjNV28yY6hedIk9QENtQrRdkQt8xuiozYwWGbgO6DoPgeKBvegEHICw)qWGQ35KAqqUvry4fAiEH2dbew9oNuJwhuuN4ViKHwwjGGbdu9oNuJwhuuNiVqJq7bKd5dHvVZj1O1bf1j(lc5h9OaWpDHwZYmIzS)jZY44L7AfEVUwZcrLEPL68Zi)gYhchOyg7FYSgTYPMftO9ztthETmKpLTGbHrtjJw5uZIj0(SbLpa8txO1SmJyg7FYSmoE5MF0AwiQ0R6DoPgToOOoXFrHa6KTGbduRdkQt8xuioL1peoqy0uYatnJAOmO8bdcJMsMAfEVUwZAq5dia8txO1SmJyg7FYSmoE5MHW)tMdY(HOsVI5aEI8tTklezlmTuNFg5xxO1SM2HImIHPH)JAAhkYWFGA1I3wuhcOzofggnLmALtnlMq7Zgu(WbcJMsgy7mF1TZYmO8bdYf1T0Qgy7mF1TZYm06Ww6hq4a5I6wAvtTcVxxRzn06Ww6hmOyg7FYSMAfEVUwZAA6WRLH8PSoGWCbgnLm1k8EDTM1GYJF6cTMLzeZy)tMLXXl3OmkwkDaX6h0RZqeQVel2E2NokM2TquP3pbJMsM2Z(0rX0Un(jy0uY8NmBWGFcgnLmIz)OcTcLI1cv8tWOPKbLpS6DoPgToOOorEHgd5dH4KjBbdYLpbJMsgXSFuHwHsXAHk(jy0uYGYhoWpbJMsM2Z(0rX0Un(jy0uYWuxafYVqlBp(Ph4QpbJMsgy7m)4KIkckslDC2GYhmOwhuuN4VOq8OhcimmAkz0kNAwmH2NnnD41Yq(0d4NUqRzzgXm2)KzzC8YnkJILshqqPej046h0R4SWoApBjIWwNPquP3aPL68ZMpLkrPi)sl15NnnLtlxfYacdJMsgTYPMftO9zZFYSH5INDQlLmqxOBULIj0(SHwh2sF8txO1SmJyg7FYSmoE5gLrXsPdiOuIeAC9d6vCwyhTNTeryRZuiQ0lmAkz0kNAwmH2NnO8H9StDPKb6cDZTumH2Nn06Ww6JF6cTMLzeZy)tMLXXl3OmkwkDabLsKqJRFqVE2zi82zX0SACsr(jd1quPxAPo)S5tPsukYVz7b8txO1SmJyg7FYSmoE5gLrXsPdgev6fgnLmALtnlMq7Zgu(Gb16GI6e)ffcO9a(j(Pl0AwMjvBXqqn7LFgBSj2G2ccI00XLYI(Ec)0fAnlZKQTyiOMXXl3mpupNI94nev6fgnLmmpupNI94T5pzw8txO1SmtQ2IHGAghVCZpJn2eBqBbbrA64szrFpHF6cTMLzs1wmeuZ44LB(UoCBmt7kcieNfwkQENtk79eev6LXtwBu9oNuMHVRd3gZ0UIa5tH)JA6I300Hxllepc)0fAnlZKQTyiOMXXl38ZyJnXg0wqqKMoUuw03t4NUqRzzMuTfdb1moE5MVRd3gZ0UIacXzHLIQ35KYEpbrLEz8K1gvVZjLz476WTXmTRiq(fA4NUqRzzMuTfdb1moE5MFgBSj2G2ccI00XLYI(Ec)0fAnlZKQTyiOMXXl3DXdH4SWsr17CszVNGOsVCrDlTQH5WuRZOim06Ww6hUPutmeoSLcRENtQrRdkQt8xeY)rnDXBA6WRLXrOExoSLmDXh1safJRCHwZA6I3OLaQOwhe(Pl0AwMjvBXqqnJJxU5NXgBInOTGGinDCPSOVNWpDHwZYmPAlgcQzC8YDx8qiolSuu9oNu27jiQ0R6wAvdZHPwNrryO1HT0pCGCrlbu1MhmythETSq8(rBxRz5QhmHmmp1SIP0QXduRw82IAK)JA6I3WFGA1I3wuhqy17CsnADqrDI)Iq(pQPlEtthETmoc17YHTKPl(OwcOyCvGN44pQPlEJwcOQnNRczaCLl0Awtx8gTeqf16GWpDHwZYmPAlgcQzC8Yn)m2ytSbTfeePPJlLf99e(Pl0AwMjvBXqqnJJxUzEOEof7XBiQ0lmAkzyEOEof7XBtthETSqCcA4NUqRzzMuTfdb1moE5MFgBSj2G2ccI00XLYI(Ec)0fAnlZKQTyiOMXXl3hEDarLEHrtjt1ZgHU8mmdkp(Pl0AwMjvBXqqnJJxUtupIAqzr4sjio8SePL68ZVNGqCwyPO6DoPS3t4N4NUqRzzMCAP21PzVnL3tgfbev6vDlTQb2oZxD7SmdToSL(HHrtjdFtFxN(CKLPs6smMbLpmmAkzGTZ8v3olZ8NmByXCapr(PwL9(OW)rnTdfzA6WRLfIhHF6cTMLzYPLAxNMXXl3nL3tgfbev6vDlTQb2oZxD7SmdToSL(HHrtjdSDMV62zzM)KzddJMsg(M(Uo95iltL0LymdkFy1T0Qgl66DSwgF1UwZAO1HT0p8Fut7qrMMo8AzH4e(Pl0AwMjNwQDDAghVCd3OQBJmRZqarLEz8K1gvVZjLzGBu1TrM1ziq(tSQPFu9oNuw4a5INDQlLmzk7pMSedrt7V2CdToSL(bd(h1OiANHikC1OLaQAZda)0fAnlZKtl1UonJJxU5NXgBInOTGGinDCPSOVNWpDHwZYm50sTRtZ44LBfr7merHRquP3aBk1edHdBPWmEYAJQ35KYmkI2ziIcxrgAbGF6cTMLzYPLAxNMXXl38ZyJnXg0wqqKMoUuw03t4NUqRzzMCAP21PzC8YTIODgIOWviQ0BGQBPvnmbTACsry7mFdToSL(HHrtjdtqRgNue2oZ38NmBaHz8K1gvVZjLzueTZqefUICiXpDHwZYm50sTRtZ44LB(zSXMydAliisthxkl67j8txO1SmtoTu760moE5MLP4POWviQ0lmAkzycA14KIW2z(gu(Gbd0fAnRHLP4POWvZ3p8CIRy8K1gvVZjLzyzkEkkCf5aDHwZAAhkY89dpN4iqxO1SM2HIIWwI(gTeqf)(HNtCv2ciGaWpDHwZYm50sTRtZ44LB(zSXMydAliisthxkl67j8txO1SmtoTu760moE5UDOiieNfwkQENtk79eev6LlAjGQ28GbdKlQBPvnW2z(QBNLzO1HT0pCthETSq8rBxRz5QhmHmGWQ35KA06GI6e)fH8JWpDHwZYm50sTRtZ44LB(zSXMydAliisthxkl67j8txO1SmtoTu760moE5UDOiieNfwkQENtk79eev6vDlTQb2oZxD7SmdToSL(HHrtjdSDMV62zzgu(WbgythETSq8Y1cimp1SIP0QXduRw82IAK)JAAhkYWFGA1I3wuZvpyY6Sfqy17CsnADqrDI)Iq(r4NqpwMvRueyj0DUoSmmwYjsqGLziSu4lwIYiS8yMnvnHL6GLmpucl5ejSuGW7CIbbw6w7KP2CSeLHL6GLWKQuJLnLAIHalBhkc)0fAnlZKtl1UonJJxUpMztvtrHRquPxy0uYaBN5RUDwMbLpmmAkz4B6760NJSmvsxIXm)jZgwmhWtKFQvzHiB4NUqRzzMCAP21PzC8Y9XmBQAkkCfcXzHLIQ35KYEpbrLEBk1edHdBj8txO1SmtoTu760moE5gUrv3gzwNHaIk9gix8StDPKjtz)XKLyiAA)1MBO1HT0pyW)Ogfr7merHRgTeqvBEaHHrtjJw5uZIj0(SbLpCGTx)ifkTQX)FMPwKd8ehhEwIceENtShxGW7CIftTl0Aw3gax1KaH35uuRdka8txO1SmtoTu760moE5MFgBSj2G2ccI00XLYI(Ec)0fAnlZKtl1UonJJxUveTZqefUcrLEBk1edHdBPWbgyOExoSLmOmkQiANH4fAHdKlWOPKPwH3RR1Sgu(Gb9StDPKjtz)XKLyiAA)1MBO1HT0pGacgKXtwBu9oNuMrr0odru4kYNca)e6XsxO1SmtoTu760moE5wr0odru4kev6TPutmeoSLchQ3LdBjdkJIkI2ziEpfggnLmcl5TWzAT5MMCHgoqUaJMsMAfEVUwZAq5dg0Zo1LsMmL9htwIHOP9xBUHwh2s)aWpDHwZYm50sTRtZ44LB(zSXMydAliisthxkl67j8txO1SmtoTu760moE5MLP4POWviQ0lJNS2O6DoPmdltXtrHRiFc)0fAnlZKtl1UonJJxUziA6drLE)JAAhkY00Hxld5aDHwZAyiA6Bedt5WfAnRPDOiJyy6Jtl15Nd4XKwQZpBAkN2GbHrtjJWsElCMwBUPjxO4N4NUqRzzMCAP21PzrFOx(zSXMydAliisthxkl67j8txO1SmtoTu760SOpehVCRiANHikCfIk9gytPMyiCylfmOl0kuk(h1OiANHikCneUqRqPiT0rrShtOfqygpzTr17Cszgfr7merHRidTGbv3sRAycA14KIW2z(gADyl9ddJMsgMGwnoPiSDMV5pz2WmEYAJQ35KYmkI2ziIcxroKbdYfTeqvBEyp7uxkzYu2FmzjgIM2FT5gADyl9XpDHwZYm50sTRtZI(qC8Yn)m2ytSbTfeePPJlLf99e(Pl0AwMjNwQDDAw0hIJxUHBu1TrM1ziGOsVmEYAJQ35KYmWnQ62iZ6mei)jw10pQENtkd)0fAnlZKtl1Uonl6dXXl38ZyJnXg0wqqKMoUuw03t4NUqRzzMCAP21PzrFioE5MLP4POWviQ0lmAkzycA14KIW2z(guE8t8tOhlrcbHLdpTuJL50sTBTNXY0yTtgSurqyPDYlbwojSurqyztmflNewQiiS05TqGLWOkwwmSKr8E7k9XYbvXseutyzAAS0o5LWTyPW6DPNXpHESmRgHLzkRflhEAXYmLIalr6XgcS88GILcFXsMNi7zSu4mflvefdlt9CGLmLCRIalZukIbvXs4MCOQnhll1GF6cTMLzgEAP(vRCQzXeAFg)e6XYS62m(zgwo80ILzkfbw2oueeyPywg6rT5yjtj3QiWsF)y5SewYjsyPaH35ewgyLWs1T0Q0pa8txO1SmZWtl1C8YD7qrquPxUOLaQAZdgegnLm89KXAq5XpHESe6oPmS8WHIWsgAtyzgclP9JLkcclhEAPglZQWiOBrPvqzvWYmiOflh0gltvZuSSlESSyyPwcOQnh)e6XsxO1SmZWtl1C8YDOExoSLGy9d6D4PL64FwcIqDlk9(h10fVrlbu1MJFc9yjNn5qHLdQILtclveew6cTMflTftXpHES0fAnlZm80snhVCNXlfcgjEFW8WdNGOsV)rnDXB0savT54NqpwY1LWYmewIWdLWsO7CDqGL((XseEO0Y1NILopVTOpwwkwEMuSeLry5XmBQAYGF6cTMLzgEAPMJxUpMztvtrHRquPxUOLaQAZXpHESChSCj6JL6GLz8sXY00yz2WYhdU(zyPVNpMMGalHUqzkw2fpw67hlZqyP3ewIYJL((XYgD3AZXpDHwZYmdpTuZXl38DD42yM2vequPxxOvOuKw6OigYNchimAkz0kNAwmH2NnO8HdegnLmW2z(QBNLzq5dgKlQBPvnW2z(QBNLzO1HT0pGWbYf1T0Qgl66DSwgF1UwZAO1HT0pyW)OMJz2u1uu4Qrlbu1MhqyUOLaQAZda)0fAnlZm80snhVC3fpev61fAfkfPLokI9EkCGWOPKrRCQzXeAF2GYhoqy0uYaBN5RUDwMbLpyqUOULw1aBN5RUDwMHwh2s)ac)h10ouKrlbu1MhoqUOULw1yrxVJ1Y4R21AwdToSL(bd(h1CmZMQMIcxnAjGQ28acZfTeqvBEa4N4NUqRzzgy36RGEzOBQAcIk9cJMsgsylEgfzJ1BZFYSHHrtjdjSfpJIw01BZFYSHdSPutmeoSLcgmqxOvOuKw6OigYNc7cTcLI)rnm0nvnfcxOvOuKw6OiwabGF6cTMLzGDRVcIJxUzQ3m0oNGOsVWOPKHe2INrr2y9200HxldzHZ0OwhuWGWOPKHe2INrrl66TPPdVwgYcNPrToi8txO1SmdSB9vqC8Ynt9ovnbrLEHrtjdjSfpJIw01BtthETmKfotJADqbdYgR3rsylEgH8d4NUqRzzgy36RG44L7mTRiGOsVWOPKHe2INrr2y9200HxldzHZ0OwhuWGw017ijSfpJq(bWnuQz1SaiH2dq7Hh4AqlKGBgV3AZzGlx3b)0k9XYSglDHwZIL2IPmd(j46OkIPb3BD8yaU2IPmasG7Wtl1aKaqEcGe46cTMfC1kNAwmH2NbxADyl9bCcuaKqdGe4sRdBPpGtWv0LsD5GlxWsTeqvBowgmiwcJMsg(EYynO8GRl0AwWTDOiGcGmKaKaxADyl9bCcUIUuQlhC5cwQLaQAZbxxO1SG7XmBQAkkCfOaiFeajWLwh2sFaNGROlL6YbxxOvOuKw6OigwImwEcldJLbILWOPKrRCQzXeAF2GYJLHXYaXsy0uYaBN5RUDwMbLhldgel5cwQULw1aBN5RUDwMHwh2sFSmaSmmwgiwYfSuDlTQXIUEhRLXxTR1SgADyl9XYGbXY)OMJz2u1uu4Qrlbu1MJLbGLHXsUGLAjGQ2CSmaW1fAnl4Y31HBJzAxrauaKzdGe4sRdBPpGtWv0LsD5GRl0kukslDuedlFXYtyzySmqSegnLmALtnlMq7ZguESmmwgiwcJMsgy7mF1TZYmO8yzWGyjxWs1T0Qgy7mF1TZYm06Ww6JLbGLHXY)OM2HImAjGQ2CSmmwgiwYfSuDlTQXIUEhRLXxTR1SgADyl9XYGbXY)OMJz2u1uu4Qrlbu1MJLbGLHXsUGLAjGQ2CSmaW1fAnl42fpqbk4Mtl1Uonl6dbqca5jasGlToSL(aob300XLYIcG8e46cTMfC5NXgBInOTGakasObqcCP1HT0hWj4k6sPUCWnqSSPutmeoSLWYGbXsxOvOu8pQrr0odru4kwgcS0fAfkfPLokIHLpMyj0WYaWYWyjJNS2O6DoPmJIODgIOWvSezSeAyzWGyP6wAvdtqRgNue2oZ3qRdBPpwgglHrtjdtqRgNue2oZ38Nmlwgglz8K1gvVZjLzueTZqefUILiJLHeldgel5cwQLaQAZXYWyPNDQlLmzk7pMSedrt7V2CdToSL(GRl0AwWvr0odru4kqbqgsasGlToSL(aob300XLYIcG8e46cTMfC5NXgBInOTGakaYhbqcCP1HT0hWj4k6sPUCWLXtwBu9oNuMbUrv3gzwNHalrgl)eRA6hvVZjLbUUqRzbx4gvDBKzDgcGcGmBaKaxADyl9bCcUPPJlLffa5jW1fAnl4YpJn2eBqBbbuaKqhasGlToSL(aobxrxk1LdUWOPKHjOvJtkcBN5Bq5bxxO1SGlltXtrHRafOG7NsoQvbibG8eajWLwh2sFaNGROlL6YbxUGLWOPKHVNmwdkpwggl5cwcJMsggc)pzoi73GYdUUqRzbxguOwBe2ziakasObqcCP1HT0hWj46cTMfCB0n6cTMnAlMcUIUuQlhCv3sRAGDRVck6PuTLE2qRdBPpwgglHrtjZXmlu1gttFyq5bxBX046he4c7wFfeqbqgsasGlToSL(aobxxO1SGRWT2Ol0A2OTyk4k6sPUCWLly5Wtl1X)Sewgglv3sRAyom16mkcdToSL(yzySmqSegnLmWuZOgkdkpwgmiwcJMsMAfEVUwZAq5XYaaxBX046he4o80snqbq(iasGlToSL(aobxrxk1LdUCblHrtjJW1yA6ddkp46cTMfCfUgttFauaKzdGe4sRdBPpGtWv0LsD5GlmAkz47jJ1GYJLbdILWOPKHHW)tMdY(nO8GRl0AwWTDOiGcGe6aqcCP1HT0hWj46cTMfCfU1gDHwZgTftbxBX046he4kMX(NmldOai5AaKaxADyl9bCcUIUuQlhC)JA6I3OLaQAZXYWy5Futx8MMo8AzyziWYqILHXs17CsnADqrDI)IWsKXYtpGLHXYaXs1T0QgMdtToJIWqRdBPpwga46cTMfCtupIAqzr4sjWvCwyPO6DoPmaKNakaYSgGe4sRdBPpGtWv0LsD5GR6wAvdZHPwNrryO1HT0hldJLI5aEI8tTkdlrglz8K1gvVZjLzueTZqefUILHXY)OMU4nAjGQ2CSmmw(h10fVPPdVwgwgcSmKyzySu9oNuJwhuuN4ViSezS8pQPlEtthETmSKdSmuVlh2sMU4JAjGIHLCfw6cTM10fVrlburToiW1fAnl4MOEe1GYIWLsGR4SWsr17CszaipbuaKzfasGlToSL(aobxxO1SGBJUrxO1SrBXuWv0LsD5GRyoGNi)uRYWsKXYhbU2IPX1piWnvBXqqndOaip9aajWLwh2sFaNGRl0AwWv4wB0fAnB0wmfCfDPuxo4Y4jRnQENtkZOiANHikCflrglpbU2IPX1piWnNwQDDAw0hcOaipDcGe4sRdBPpGtW1fAnl42OB0fAnB0wmfCTftJRFqGBoTu760mGcuWLVjXCa7kajaKNaibU06Ww6d4eChEWLrk46cTMfCd17YHTe4gQBrjW9bWnuVJRFqGlkJIkI2ziakasObqcCP1HT0hWj4o8GlJuW1fAnl4gQ3LdBjWnu3IsGl0a3q9oU(bbUOmkQiANHaCfDPuxo46zN6sjtMY(JjlXq00(Rn3qRdBPpqbqgsasGlToSL(aob3HhCzKcUUqRzb3q9UCylbUH6wucCZAWnuVJRFqGBx8rTeqXakaYhbqcCP1HT0hWj4U(bbUE2zi82zX0SACsr(jd1GRl0AwW1ZodH3olMMvJtkYpzOgOaiZgajWLwh2sFaNGROlL6Ybxy0uYCmZcvTX00hM)KzbxxO1SGlFpzSafaj0bGe46cTMfC5hTMfCP1HT0hWjqbqY1aibU06Ww6d4eCfDPuxo4cJMsMJzwOQnMM(W8Nml46cTMfCHPMrnuafazwdqcCP1HT0hWj4k6sPUCWfgnLmhZSqvBmn9H5pzwSmmwcJMsgTYPMftO9zZFYSGRl0AwWvRCQzXeAFgOaiZkaKaxADyl9bCcUIUuQlhCHrtjZXmlu1gttFy(tMfCDHwZcUcxJPPpakqb3CAP21PzaKaqEcGe4sRdBPpGtWv0LsD5GR6wAvdSDMV62zzgADyl9XYWyjmAkz4B6760NJSmvsxIXmO8yzySegnLmW2z(QBNLz(tMfldJLI5aEI8tTkdlFXYhHLHXY)OM2HImnD41YWYqGLpcCDHwZcUnL3tgfbqbqcnasGlToSL(aobxrxk1LdUQBPvnW2z(QBNLzO1HT0hldJLWOPKb2oZxD7SmZFYSyzySegnLm8n9DD6ZrwMkPlXyguESmmwQULw1yrxVJ1Y4R21AwdToSL(yzyS8pQPDOitthETmSmey5jW1fAnl42uEpzueafazibibU06Ww6d4eCfDPuxo4Y4jRnQENtkZa3OQBJmRZqGLiJLFIvn9JQ35KYWYWyzGyjxWsp7uxkzYu2FmzjgIM2FT5gADyl9XYGbXY)Ogfr7merHRgTeqvBowga46cTMfCHBu1TrM1ziakaYhbqcCP1HT0hWj4MMoUuwuaKNaxxO1SGl)m2ytSbTfeqbqMnasGlToSL(aobxrxk1LdUbILnLAIHWHTewgglz8K1gvVZjLzueTZqefUILiJLqdldaCDHwZcUkI2ziIcxbkasOdajWLwh2sFaNGBA64szrbqEcCDHwZcU8ZyJnXg0wqafajxdGe4sRdBPpGtWv0LsD5GBGyP6wAvdtqRgNue2oZ3qRdBPpwgglHrtjdtqRgNue2oZ38Nmlwgawgglz8K1gvVZjLzueTZqefUILiJLHeCDHwZcUkI2ziIcxbkaYSgGe4sRdBPpGtWnnDCPSOaipbUUqRzbx(zSXMydAliGcGmRaqcCP1HT0hWj4k6sPUCWfgnLmmbTACsry7mFdkpwgmiwgiw6cTM1WYu8uu4Q57hEoHLCfwY4jRnQENtkZWYu8uu4kwImwgiw6cTM10ouK57hEoHLCGLbILUqRznTdffHTe9nAjGk(9dpNWsUclZgwgawgawga46cTMfCzzkEkkCfOaip9aajWLwh2sFaNGBA64szrbqEcCDHwZcU8ZyJnXg0wqafa5PtaKaxADyl9bCcUIUuQlhC5cwQLaQAZXYGbXYaXsUGLQBPvnW2z(QBNLzO1HT0hldJLnD41YWYqGLF021AwSKRWYhmHeldaldJLQ35KA06GI6e)fHLiJLpcCDHwZcUTdfbUIZclfvVZjLbG8eqbqEcAaKaxADyl9bCcUPPJlLffa5jW1fAnl4YpJn2eBqBbbuaKNcjajWLwh2sFaNGROlL6Ybx1T0Qgy7mF1TZYm06Ww6JLHXsy0uYaBN5RUDwMbLhldJLbILbILnD41YWYq8ILCnSmaSmmwYtnRykTA8a1QfVTOglrgl)JAAhkYWFGA1I3wuJLCfw(GjRZgwgawgglvVZj1O1bf1j(lclrglFe46cTMfCBhkcCfNfwkQENtkda5jGcG80JaibU06Ww6d4eCfDPuxo4cJMsgy7mF1TZYmO8yzySegnLm8n9DD6ZrwMkPlXyM)KzXYWyPyoGNi)uRYWYqGLzdCDHwZcUhZSPQPOWvGcG8u2aibU06Ww6d4eCfDPuxo42uQjgch2sGRl0AwW9yMnvnffUcUIZclfvVZjLbG8eqbqEc6aqcCP1HT0hWj4k6sPUCWnqSKlyPNDQlLmzk7pMSedrt7V2CdToSL(yzWGy5FuJIODgIOWvJwcOQnhldaldJLWOPKrRCQzXeAF2GYJLHXYaXY2RFKcLw14)pZulwImwgiwEcl5alp8Sefi8oNyy5JJLceENtSyQDHwZ6wSmaSKRWYMei8oNIADqyzaGRl0AwWfUrv3gzwNHaOaipX1aibU06Ww6d4eCtthxklkaYtGRl0AwWLFgBSj2G2ccOaipL1aKaxADyl9bCcUIUuQlhCBk1edHdBjSmmwgiwgiwgQ3LdBjdkJIkI2ziWYxSeAyzySmqSKlyjmAkzQv496AnRbLhldgel9StDPKjtz)XKLyiAA)1MBO1HT0hldaldaldgelz8K1gvVZjLzueTZqefUILiJLNWYaaxxO1SGRIODgIOWvGcG8uwbGe4sRdBPpGtWnnDCPSOaipbUUqRzbx(zSXMydAliGcGeApaqcCP1HT0hWj4k6sPUCWLXtwBu9oNuMHLP4POWvSezS8e46cTMfCzzkEkkCfOaiH2jasGlToSL(aobxrxk1LdU)rnTdfzA6WRLHLiJLbILUqRznmen9nIHPyjhyPl0Awt7qrgXWuS8XXsAPo)mwgaw(yIL0sD(ztt50ILbdILWOPKryjVfotRn30KluW1fAnl4Yq00hOafCt1wmeuZaibG8eajWLwh2sFaNGBA64szrbqEcCDHwZcU8ZyJnXg0wqafaj0aibU06Ww6d4eCfDPuxo4cJMsgMhQNtXE828Nml46cTMfCzEOEof7XBGcGmKaKaxADyl9bCcUPPJlLffa5jW1fAnl4YpJn2eBqBbbuaKpcGe4sRdBPpGtWv0LsD5GlJNS2O6DoPmdFxhUnMPDfbwImwEcldJL)rnDXBA6WRLHLHalFe46cTMfC576WTXmTRiaxXzHLIQ35KYaqEcOaiZgajWLwh2sFaNGBA64szrbqEcCDHwZcU8ZyJnXg0wqafaj0bGe4sRdBPpGtWv0LsD5GlJNS2O6DoPmdFxhUnMPDfbwI8lwcnW1fAnl4Y31HBJzAxraUIZclfvVZjLbG8eqbqY1aibU06Ww6d4eCtthxklkaYtGRl0AwWLFgBSj2G2ccOaiZAasGlToSL(aobxrxk1LdUCblv3sRAyom16mkcdToSL(yzySSPutmeoSLWYWyP6DoPgToOOoXFryjYy5Futx8MMo8AzyjhyzOExoSLmDXh1safdl5kS0fAnRPlEJwcOIADqGRl0AwWTlEWvCwyPO6DoPmaKNakaYScajWLwh2sFaNGBA64szrbqEcCDHwZcU8ZyJnXg0wqafa5PhaibU06Ww6d4eCfDPuxo4QULw1WCyQ1zuegADyl9XYWyzGyjxWsTeqvBowgmiw20HxldldXlw(rBxRzXsUclFWesSmmwYtnRykTA8a1QfVTOglrgl)JA6I3WFGA1I3wuJLbGLHXs17CsnADqrDI)IWsKXY)OMU4nnD41YWsoWYq9UCylz6IpQLakgwYvyzGy5jSKdS8pQPlEJwcOQnhl5kSmKyzayjxHLUqRznDXB0savuRdcCDHwZcUDXdUIZclfvVZjLbG8eqbqE6eajWLwh2sFaNGBA64szrbqEcCDHwZcU8ZyJnXg0wqafa5jObqcCP1HT0hWj4k6sPUCWfgnLmmpupNI94TPPdVwgwgcS8e0axxO1SGlZd1ZPypEduaKNcjajWLwh2sFaNGBA64szrbqEcCDHwZcU8ZyJnXg0wqafa5PhbqcCP1HT0hWj4k6sPUCWfgnLmvpBe6YZWmO8GRl0AwW9WRdGcG8u2aibU06Ww6d4eCp8SePL68ZG7jW1fAnl4MOEe1GYIWLsGR4SWsr17CszaipbuGcUIzS)jZYaibG8eajWLwh2sFaNGROlL6YbxAPo)mwI8lwgYhWYWyzGyPyg7FYSgTYPMftO9ztthETmSezSmByzWGyjmAkz0kNAwmH2NnO8yzaGRl0AwWfMAg1qbuaKqdGe4sRdBPpGtWv0LsD5GlTuNF28Pujkflr(flHopGLbdILWOPKrRCQzXeAF28Nml46cTMfC1kNAwmH2NbkaYqcqcCDHwZcUWuZOgQAZbxADyl9bCcuaKpcGe4sRdBPpGtWv0LsD5GRl0kukslDuedlrgl)eRA6hvVZjLHLbdILTx)ifkTQX)FMPwSezS8rzdCDHwZcUkIPxgqbqMnasGlToSL(aobxrxk1LdUWOPKPjbuwIXIPPfKbLhldgelHrtjJw5uZIj0(SbLhCDHwZcUkckIUWd6(JPPfeqbqcDaibU06Ww6d4eCfDPuxo4cJMsgTYPMftO9zdkpwgglHrtjdm1mQHY8Nml46cTMfCpOJPphNu0IkQF83KFWakasUgajWLwh2sFaNGROlL6Ybxy0uYOvo1SycTpBq5bxxO1SGlSDMFCsrfbfPLooduaKznajWLwh2sFaNGROlL6YbxXCapr(PwLHLVy5dGRl0AwWnrTBJPM2SFgOaiZkaKaxADyl9bCcUIUuQlhCDHwHsrAPJIyyjYy5Nyvt)O6DoPmSmyqSmqSS96hPqPvn()Zm1ILiJLzLhWYWyjTuNF28Pujkflr(flZ2dyzaGRl0AwWnncug9JE2PUukct(bqbqE6basGlToSL(aobxrxk1LdUUqRqPiT0rrmSezS8tSQPFu9oNugwgmiw2E9JuO0Qg))zMAXsKXsOZdGRl0AwWLhTR05AZJWwNPafa5PtaKaxADyl9bCcUIUuQlhCHrtjJw5uZIj0(SbLhCDHwZcU5OE)lFJtk6zN6rrauaKNGgajWLwh2sFaNGROlL6Ybxy0uYOvo1SycTpBq5bxxO1SGRywbTA7k9JjRFqafa5PqcqcCP1HT0hWj4k6sPUCWfgnLmALtnlMq7ZguEW1fAnl42fpVLI1gz8UGakaYtpcGe4sRdBPpGtWv0LsD5GlmAkz0kNAwmH2NnO8GRl0AwWnZ02FOuTXMyZ6RGakaYtzdGe4sRdBPpGtWv0LsD5GR6DoPgToOOoXFryziWYtMSHLbdILbILbILQ35KAqqUvry4fkwImwM1pGLbdILQ35KAqqUvry4fkwgIxSeApGLbGLHXs17CsnADqrDI)IWsKXsOLvWYaWYGbXYaXs17CsnADqrDI8cncThWsKXYq(awgglvVZj1O1bf1j(lclrglF0JWYaaxxO1SGBtoFT5XK1pigqbqEc6aqcCP1HT0hWj4k6sPUCWLwQZpJLi)ILH8bSmmwgiwkMX(NmRrRCQzXeAF200HxldlrglpLnSmyqSegnLmALtnlMq7ZguESmaW1fAnl4wRW711AwGcG8exdGe4sRdBPpGtWv0LsD5GR6DoPgToOOoXFryziWsOt2WYGbXYaXsToOOoXFryziWYtz9dyzySmqSegnLmWuZOgkdkpwgmiwcJMsMAfEVUwZAq5XYaWYaaxxO1SGl)O1Safa5PSgGe4sRdBPpGtWv0LsD5GRyoGNi)uRYWYqGLzdldJL0sD(zSe5xS0fAnRPDOiJyykwggl)JAAhkYWFGA1I3wuJLHalHM5ewgglHrtjJw5uZIj0(SbLhldJLbILWOPKb2oZxD7SmdkpwgmiwYfSuDlTQb2oZxD7SmdToSL(yzayzySmqSKlyP6wAvtTcVxxRzn06Ww6JLbdILIzS)jZAQv496AnRPPdVwgwImwEkRXYaWYWyjxWsy0uYuRW711Awdkp46cTMfCzi8)K5GSFGcG8uwbGe4sRdBPpGtWv0LsD5G7NGrtjt7zF6OyA3g)emAkz(tMfldgel)emAkzeZ(rfAfkfRfQ4NGrtjdkpwgglvVZj1O1bf1jYl0yiFaldbwEYKnSmyqSKly5NGrtjJy2pQqRqPyTqf)emAkzq5XYWyzGy5NGrtjt7zF6OyA3g)emAkzyQlGclr(flHw2WYhhlp9awYvy5NGrtjdSDMFCsrfbfPLooBq5XYGbXsToOOoXFryziWYh9awgawgglHrtjJw5uZIj0(SPPdVwgwImwE6bWD9dcCDgIq9LyX2Z(0rX0UfCDHwZcUodrO(sSy7zF6OyA3cuaKq7basGlToSL(aobxrxk1LdUbIL0sD(zZNsLOuSe5xSKwQZpBAkNwSKRWYqILbGLHXsy0uYOvo1SycTpB(tMfldJLCbl9StDPKb6cDZTumH2Nn06Ww6dUUqRzbxXzHD0E2seHTotbxkLiHgx)GaxXzHD0E2seHTotbkasODcGe4sRdBPpGtWv0LsD5GlmAkz0kNAwmH2NnO8yzyS0Zo1LsgOl0n3sXeAF2qRdBPp46cTMfCfNf2r7zlre26mfCPuIeAC9dcCfNf2r7zlre26mfOaiHg0aibU06Ww6d4eCfDPuxo4sl15NnFkvIsXsKFXYS9a46cTMfC9SZq4TZIPz14KI8tgQbxkLiHgx)Gaxp7meE7SyAwnoPi)KHAGcGeAHeGe4sRdBPpGtWv0LsD5GlmAkz0kNAwmH2NnO8yzWGyPwhuuN4ViSmeyj0EaCDHwZcUOmkwkDWakqbxy36RGaibG8eajWLwh2sFaNGROlL6Ybxy0uYqcBXZOiBSEB(tMfldJLWOPKHe2INrrl66T5pzwSmmwgiw2uQjgch2syzWGyzGyPl0kukslDuedlrglpHLHXsxOvOu8pQHHUPQjSmeyPl0kukslDuedldaldaCDHwZcUm0nvnbuaKqdGe4sRdBPpGtWv0LsD5GlmAkziHT4zuKnwVnnD41YWsKXsHZ0OwhewgmiwcJMsgsylEgfTOR3MMo8AzyjYyPWzAuRdcCDHwZcUm1BgANtafazibibU06Ww6d4eCfDPuxo4cJMsgsylEgfTOR3MMo8AzyjYyPWzAuRdcldgelzJ17ijSfpJWsKXYhaxxO1SGlt9ovnbuaKpcGe4sRdBPpGtWv0LsD5GlmAkziHT4zuKnwVnnD41YWsKXsHZ0OwhewgmiwArxVJKWw8mclrglFaCDHwZcUzAxrauGcuGcuaaa]] )


end
