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
            id = 69369,
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
        prowling = 1.6
    }

    local stealth_dropped = 0

    local function calculate_multiplier( spellID )
        local tigers_fury = FindUnitBuffByID( "player", class.auras.tigers_fury.id, "PLAYER" ) and snapshot_value.tigers_fury or 1
        local bloodtalons = FindUnitBuffByID( "player", class.auras.bloodtalons.id, "PLAYER" ) and snapshot_value.bloodtalons or 1
        local clearcasting = FindUnitBuffByID( "player", class.auras.clearcasting.id, "PLAYER" ) and state.talent.moment_of_clarity.enabled and snapshot_value.clearcasting or 1
        local prowling = ( GetTime() - stealth_dropped < 0.2 or FindUnitBuffByID( "player", class.auras.incarnation.id, "PLAYER" ) or FindUnitBuffByID( "player", class.auras.berserk.id, "PLAYER" ) ) and snapshot_value.prowling or 1

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
        if pr_spells[ this_action ] and ( buff.incarnation.up or buff.berserk.up or buff.prowl.up or buff.shadowmeld.up or state.query_time - stealth_dropped < 0.2 ) then mult = mult * snapshot_value.prowling end

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


    local last_bloodtalons_proc = 0

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID then
            if subtype == "SPELL_AURA_REMOVED" then
                -- Track Prowl and Shadowmeld dropping, give a 0.2s window for the Rake snapshot.
                if spellID == 58984 or spellID == 5215 or spellID == 1102547 then
                    stealth_dropped = GetTime()
                end
            elseif ( subtype == 'SPELL_AURA_APPLIED' or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' ) then
                if snapshots[ spellID ] then
                    ns.saveDebuffModifier( spellID, calculate_multiplier( spellID ) )
                    ns.trackDebuff( spellID, destGUID, GetTime(), true )
                elseif spellID == 145152 then -- Bloodtalons
                    last_bloodtalons_proc = GetTime()
                end
            elseif subtype == "SPELL_CAST_SUCCESS" and ( spellID == class.abilities.rip.id or spellID == class.abilities.primal_wrath.id or spellID == class.abilities.ferocious_bite.id or spellID == class.abilities.maim.id or spellID == class.abilities.savage_roar.id ) then
                rip_applied = true
            end
        end
    end )


    spec:RegisterStateExpr( "last_bloodtalons", function ()
        return last_bloodtalons_proc
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
        last_bloodtalons = nil
    end )

    spec:RegisterHook( "gain", function( amt, resource )
        if azerite.untamed_ferocity.enabled and amt > 0 and resource == "combo_points" then
            if talent.incarnation.enabled then gainChargeTime( "incarnation", 0.2 )
            else gainChargeTime( "berserk", 0.3 ) end
        end
    end )


    local function comboSpender( a, r )
        if r == "combo_points" and a > 0 then
            if talent.soul_of_the_forest.enabled then
                gain( a * 5, "energy" )
            end

            if buff.berserk.up or buff.incarnation.up and a > 4 then
                gain( level > 57 and 2 or 1, "combo_points" )
            end

            if a >= 5 then
                applyBuff( "predatory_swiftness" )
            end
        end
    end

    spec:RegisterHook( "spend", comboSpender )
    
    
    local combo_generators = {
        brutal_slash = true,
        feral_frenzy = true,
        moonfire_cat = true,  -- technically only true with lunar_inspiration, but if you press moonfire w/o lunar inspiration you are weird.
        rake         = true,
        shred        = true,
        swipe_cat    = true,
        thrash_cat   = true
    }

    spec:RegisterStateExpr( "will_proc_bloodtalons", function ()
        if not talent.bloodtalons.enabled then return false end
        
        local btCount = 0

        for k, v in pairs( combo_generators ) do
            if k ~= this_action then
                local lastCast = action[ k ].lastCast

                if lastCast > last_bloodtalons and query_time - lastCast < 5 then
                    btCount = btCount + 1
                end
            end

            if btCount > 1 then return true end
        end

        return false
    end )

    spec:RegisterStateFunction( "proc_bloodtalons", function()
        applyBuff( "bloodtalons", nil, 2 )
        last_bloodtalons = query_time
    end )


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

                if will_proc_bloodtalons then proc_bloodtalons() end
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

                if will_proc_bloodtalons then proc_bloodtalons() end
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
                spend( combo_points.current, "combo_points" )

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
                if will_proc_bloodtalons then proc_bloodtalons() end
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
                removeStack( "bloodtalons" )

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
                if will_proc_bloodtalons then proc_bloodtalons() end
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
                if level > 53 and ( buff.prowl.up or buff.berserk.up or buff.incarnation.up ) then
                    gain( 2, "combo_points" )
                else
                    gain( 1, "combo_points" )
                end

                removeStack( "clearcasting" )

                if will_proc_bloodtalons then proc_bloodtalons() end
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

            damage = function () return stat.attack_power * 0.28750 * ( active_dot.thrash_cat > 0 and 1.2 or 1 ) end, -- TODO: Check damage.

            handler = function ()
                gain( 1, "combo_points" )
                if will_proc_bloodtalons then proc_bloodtalons() end
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
                if target.within8 then
                    gain( 1, "combo_points" )
                    if will_proc_bloodtalons then proc_bloodtalons() end
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

    spec:RegisterPack( "Feral", 202008022, [[dueCpbqiLs8iLsYLukP0MeuJssYPKKAvav6vqjZciDlGkSls9luPgMKWXukwgqvptqyAkLQRjjY2ukL(gQQkJdvv5CkLI1burmpbr3dq7dOCquvvHfIk5HkLu1ervvvxuPKk2iqfPtQusXkbIzIQQkANa4OOQQspvvMkuQVQusL2lO)sYGf6WuTyv1JjAYk5YiBwIplPgnuCAfRgOI61OQmBuUTs1Uv53IgUalxQNdz6uUouTDbPVJQmEuv58a06Le18rf7NWWnqSHVLBeeaWxb4ROc(d8GxxX2S9nvW)GpdWac(cCjFEnbFNVtWh4uQDg8f4aYsFbXg(qjElj4dJzbiWjCZD9yyW)AzUZnA2XzUn5jBVyCJMDj3W3hFy2wZb)W3Yncca4Ra8vub)bEWRRyBcX2uriGpuajHaSPIqaFyM1Io4h(wescFBLicoLANjI8)n(SerWHiY)fFK8jI(Ter()PnafGiazReXTEm(vtiWjcq2kreCiISKjIUjIC5m)KKaKTsebhIixSmxMZYdjIxAI4ShWOD6mAPHVGoldJGVTsebNsTZer()gFwIi4qe5)Ips(er)wIi))0gGcqeGSvI4wpg)Qje4ebiBLicoerwYer3erUCMFssaYwjIGdrKlwMlZz5HeXlnrC2dy0oDgT0cqeGSvI4wh(rsCJwI4NkztIOm3)UjIFQEoKwe5)qkPadjIxEGdmEVxWzIOlTjpKiMhdqTaKTseDPn5H0bnjZ9VBalmhXNaKTseDPn5H0bnjZ9VBybK7sMlbiBLi6sBYdPdAsM7F3Wci3oE9oDMBtEcq2krCRXeXbjI8Y2WiIJjILSfrNTNitePqPgW8ir0srC3NZ85erdt7imcqCPn5H0bnjZ9VBybK7q9E8pJa98DcioIugM2ryanuNHtaRqaIlTjpKoOjzU)DdlGChQ3J)zeONVtaXrKYW0ocdOH6mCci4bDka9kt9yKM3WwQcJqyA6wZvRPZ)mAjaXL2Khsh0Km3)UHfqUd17X)mc0Z3jG9eOSrYhc0qDgobK)eG4sBYdPdAsM7F3Wci34isngTd657eqVYimE7ivjptLfvqYJAbiU0M8q6GMK5(3nSaYDqN8yGofGF8srVN5X3CQs276vY7eGSvI478aeM0eX2NLi(XlfAjIiZnKi(Ps2KikZ9VBI4NQNdjI(TeXGMahbPzZvlIdsex5rAbiBLi6sBYdPdAsM7F3Wci3OZdqystHm3qcqCPn5H0bnjZ9VBybK7G0M8eG4sBYdPdAsM7F3Wci3FQruZhOtb4hVu07zE8nNQK9UEL8obiU0M8q6GMK5(3nSaYTn1uJuf8gqqNcWpEPO3Z84Bovj7D9k5DH)4LI2MAQrQcEdOEL8obiU0M8q6GMK5(3nSaYT0nvj7DqNcWpEPO3Z84Bovj7D9k5DcqeGSvI4wh(rsCJwIifk1akI2StIOHHerxAzlIdse9q9H5FgPfG4sBYdbeXhoJP(ocdOtb4w(4LIoOtEmnEq4T8XlfncJVsE7eBPXdeG4sBYdHfqUB8t5sBYtXgKb657eWVZ8tsGofGMZOZ0FN5NKuEPm3yaQPZ)mAf(Jxk69mp(MtvYExJhiaXL2KhclGClDtvYEh0PaClF8srlDtvYExJhiaXL2KhclGC3oFeOtb4hVu0bDYJPXd4W5JxkAegFL82j2sJhiaXL2KhclGClDgt5sBYtXgKb657eqzMSvY7qcqCPn5HWci3fQt5K4i1FmcujGsgPmVRjdbCdOtb4knDpbABK8nxD4vA6Ec0nT7ZHczicBExtM2MDszPAneyBQiCvMZOZ0i)tTLPHrtN)z0QAbiU0M8qybK7c1PCsCK6pgbQeqjJuM31KHaUb0Pa0CgDMg5FQTmnmA68pJwHL5(pvb5CgcmuaXykZ7AYqAdt7imkPBHxPP7jqBJKV5QdVst3tGUPDFouidryZ7AY02StklvRHaBLMUNaDt7(CiSc17X)ms3tGYgjFiW1L2KNUNaTns(u2StcqCPn5HWci3n(PCPn5PydYa98DcyzUbHHAeOtbOm3)PkiNZqGTDbiU0M8qybKBPZykxAtEk2GmqpFNawth1ULns5jb6uaIcigtzExtgsByAhHrjDdSncqCPn5HWci3n(PCPn5PydYa98DcynDu7w2ibicqCPn5H0YmzRK3Ha(PgrnFGofG0rDnGGbmeveUkzMSvY702utnsvWBa1nT7ZHaRsC48XlfTn1uJuf8gqnEq1cqCPn5H0YmzRK3HWci32utnsvWBabDkaPJ6Aa1lQmYXad42wbhoF8srBtn1ivbVbuVsENaexAtEiTmt2k5DiSaY9NAe18nxTaexAtEiTmt2k5DiSaYTHj7db6ua6sBcLu0r7dHaBrOPPLY8UMmehoTplffkDM2xlKEoW2ELeG4sBYdPLzYwjVdHfqUnmKc)(j(TuLSLeOtb4hVu0nj5JriKQKTK04bC48XlfTn1uJuf8gqnEGaexAtEiTmt2k5DiSaY9oTNnGQSOy4YzPwn57iqNcWpEPOTPMAKQG3aQXdc)Xlf9NAe18PxjVtaIlTjpKwMjBL8oewa5(ZYCPYIYWqk6ODabDka)4LI2MAQrQcEdOgpqaIlTjpKwMjBL8oewa5UqTZuLMUkdiOtbOm3)PkiNZqaRqaIlTjpKwMjBL8oewa5UKsCeTuELPEms9jFh0Pa0L2ekPOJ2hcb2IqttlL5DnzioCQQ9zPOqPZ0(AH0Zb22ury6OUgq9IkJCmWawPkQwaIlTjpKwMjBL8oewa5oaVNcGZvR(mhzGofGU0MqjfD0(qiWweAAAPmVRjdXHt7ZsrHsNP91cPNdSTTcbiU0M8qAzMSvY7qybK7ACVxJFQSO8ktDAyaDka)4LI2MAQrQcEdOgpqaIlTjpKwMjBL8oewa5wMNKoRDJwQcZ3jqNcWpEPOTPMAKQG3aQXdeG4sBYdPLzYwjVdHfqU7jiGrQ5uOaxsGofGF8srBtn1ivbVbuJhiaXL2KhslZKTsEhclGCZlB2kuAovtO88tsGofGF8srBtn1ivbVbuJhiaXL2KhslZKTsEhclGC3KhmxTQW8Dcb6uaAExtM2MDszPAnui3ORehovvL5DnzAmKZmm6aPbg)vbhoM31KPXqoZWOdKwibc(kQoS5DnzAB2jLLQ1qGb(TPAoCQY8UMmTn7KYsvG0uGVcWcrfHnVRjtBZoPSuTgcSTV9QfG4sBYdPLzYwjVdHfqUNt6952KhOtbiDuxdiyadrfHRsMjBL8oTn1uJuf8gqDt7(CiW2ujoC(4LI2MAQrQcEdOgpOAbiU0M8qAzMSvY7qybK7G0M8aDkanVRjtBZoPSuTgkKBBL4WPkB2jLLQ1qHCd)vr4Q(4LI(tnIA(04bC48Xlf9CsVp3M804bvxTaexAtEiTmt2k5DiSaYncJVsE7eBb6uakZ9FQcY5muiRuy6OUgqWa6sBYt3oFKwMil8knD78r6GDCMnbSH6qcE9MWF8srBtn1ivbVbuJheUQpEPO)SmxMZYdPXd4WzlMZOZ0FwMlZz5H005FgTQoCvBXCgDMEoP3NBtEA68pJwC4iZKTsENEoP3NBtE6M295qGTH)Qo8w(4LIEoP3NBtEA8abiU0M8qAzMSvY7qybKBCePgJ2b98DcOJWeQFes1ELZwjZ2zGofGl6Jxk62RC2kz2otTOpEPOxjVJdNf9XlfTmVfU0Mqj1C8Pw0hVu04bHnVRjtBZoPSufinviQiKB0vIdNTSOpEPOL5TWL2ekPMJp1I(4LIgpiCvl6Jxk62RC2kz2otTOpEPOrMl5dmGGVsGJnvaUl6Jxk6plZLklkddPOJ2buJhWHJn7KYs1AOqU9kQo8hVu02utnsvWBa1nT7ZHaBtfcqCPn5H0YmzRK3HWci34isngTdkvkK0uNVtaLakzP15ns1N5id0PaSk6OUgq9IkJCmWash11aQBQMoWnevh(JxkABQPgPk4nG6vY7cVfVYupgPbNXVAgPk4nGA68pJwcqCPn5H0YmzRK3HWci34isngTdkvkK0uNVtaLakzP15ns1N5id0Pa8JxkABQPgPk4nGA8GWELPEmsdoJF1msvWBa105FgTeG4sBYdPLzYwjVdHfqUXrKAmAhuQuiPPoFNa6vgHXBhPk5zQSOcsEud6uash11aQxuzKJbgWkvHaexAtEiTmt2k5DiSaYnoIuJr7iqNcWpEPOTPMAKQG3aQXd4WXMDszPAnuibFfcqeG4sBYdPlZnimuJagKjt1ekXBjbAjB1r8ZaUraIlTjpKUm3GWqnclGCJ8q9As1P3GofGF8srJ8q9As1P36vY7eG4sBYdPlZnimuJWci3bzYunHs8wsGwYwDe)mGBeG4sBYdPlZnimuJWci3b9S7mfV2nmGkbuYiL5DnziGBaDkarbeJPmVRjdPd6z3zkETByaBt4vA6Ec0nT7ZHc52fG4sBYdPlZnimuJWci3bzYunHs8wsGwYwDe)mGBeG4sBYdPlZnimuJWci3b9S7mfV2nmGkbuYiL5DnziGBaDkarbeJPmVRjdPd6z3zkETByadi4fG4sBYdPlZnimuJWci3bzYunHs8wsGwYwDe)mGBeG4sBYdPlZnimuJWci39eaQeqjJuM31KHaUb0PaClMZOZ0i)tTLPHrtN)z0kCtLMqy8pJcBExtM2MDszPAneyR009eOBA3NdHvOEp(Nr6Ecu2i5dbUU0M809eOTrYNYMDsaIlTjpKUm3GWqnclGChKjt1ekXBjbAjB1r8ZaUraIlTjpKUm3GWqnclGC3taOsaLmszExtgc4gqNcqZz0zAK)P2Y0WOPZ)mAfUQTyJKV5Q5WPPDFouibUWB3M8a3k0HiCa1Obz0zQDCMnbSHAWwPP7jqhSJZSjGnuxDyZ7AY02StklvRHaBLMUNaDt7(CiSc17X)ms3tGYgjFiWTQnyTst3tG2gjFZvdUHOAW1L2KNUNaTns(u2StcqCPn5H0L5gegQrybK7GmzQMqjEljqlzRoIFgWncqCPn5H0L5gegQrybKBKhQxtQo9g0Pa8JxkAKhQxtQo9w30UphkKBaVaexAtEiDzUbHHAewa5oitMQjuI3sc0s2QJ4NbCJaexAtEiDzUbHHAewa5E3NDqNcWpEPONopf4SZdPXdeG4sBYdPlZnimuJWci3fQt5K4i1Fmc0DNFk6OUgqGBavcOKrkZ7AYqa3iaraIlTjpKUMoQDlBewa5(34MZuiMJWa6uaIcigtzExtgs)BCZzkeZryaBrOPPLY8UMmu4Q2IxzQhJ08g2svyectt3AUAnD(NrloCwPPnmTJWOKUPTrY3C1vZHZhVu0FwMlZz5H0RK3fM3WyQGoLQplZL5S8qcqCPn5H010rTBzJWci3bzYunHs8wsGwYwDe)mGBeG4sBYdPRPJA3YgHfqUnmTJWOKUb6uawvtLMqy8pJcJcigtzExtgsByAhHrjDdmWxnhoF8sr)zzUmNLhsVsExyEdJPc6uQ(SmxMZYdjaXL2Khsxth1ULnclGChKjt1ekXBjbAjB1r8ZaUraIlTjpKUMoQDlBewa52W0ocJs6gOtbyvMZOZ0ijDMklQplZLMo)ZOv4pEPOrs6mvwuFwMl9k5DvhgfqmMY8UMmK2W0ocJs6gyHqaIlTjpKUMoQDlBewa5oitMQjuI3sc0s2QJ4NbCJaexAtEiDnDu7w2iSaYnI3eqkPBGofGF8srJK0zQSO(SmxA8aoCQYL2KNgXBciL0n9Y39AcCrbeJPmVRjdPr8MasjDdSQCPn5PBNpsV8DVMWQkxAtE625JuFgrlTns(ulF3RjWTsvxD1C48Xlf9NL5YCwEi9k5DH5nmMkOtP6ZYCzolpKaexAtEiDnDu7w2iSaYDqMmvtOeVLeOLSvhXpd4gbiU0M8q6A6O2TSrybK725JavcOKrkZ7AYqa3a6uaUfBK8nxnhovTfZz0z6plZL5S8qA68pJwHBA3NdfYfE72Kh4wHoevh28UMmTn7KYs1AiW2ohoF8sr)zzUmNLhsVsExyEdJPc6uQ(SmxMZYdjaXL2Khsxth1ULnclGChKjt1ekXBjbAjB1r8ZaUraIlTjpKUMoQDlBewa5UD(iqLakzKY8UMmeWnGofGvvvt7(COqcK)vD4aQrdYOZu74mBcyd1GTst3oFKoyhNztaBOgCRqZFvQ6WM31KPTzNuwQwdb22fGSvI4w3XWiI8FU1iIHfrUWgurKhjIs)erCejI7zELPjr0sre5HsIixylIsmExtiqfrNXsEZvlI4ir0sr8tMrTi2uPjegrSD(ibiU0M8q6A6O2TSrybK79mVY0Ks6gOtb4hVu0bnTClBaviEtXocH0RK3fwM7)ufKZzOqwjoC(4LI(ZYCzolpKEL8UW8ggtf0Pu9zzUmNLhsaIlTjpKUMoQDlBewa5EpZRmnPKUbQeqjJuM31KHaUb0PaSPstim(NrcqCPn5H010rTBzJWci3)g3CMcXCegqNcWQ2IxzQhJ08g2svyectt3AUAnD(NrloCwPPnmTJWOKUPTrY3C1vh(JxkABQPgPk4nGA8GWv1(SuuO0zAFTq65aRQnyT78tjX4DnHahsmExtivPDPn55SQb3MKy8UMu2StvZHZhVu0FwMlZz5H0RK3fM3WyQGoLQplZL5S8qcqCPn5H010rTBzJWci3bzYunHs8wsGwYwDe)mGBeG4sBYdPRPJA3YgHfqUnmTJWOKUb6ua2uPjeg)ZOWvvvOEp(NrACePmmTJWae8HRAlF8srpN07ZTjpnEahoELPEmsZBylvHrimnDR5Q105FgTQUAoCqbeJPmVRjdPnmTJWOKUb2MQ5W5Jxk6plZL5S8q6vY7cZBymvqNs1NL5YCwEibiBLi6sBYdPRPJA3YgHfqUnmTJWOKUb6ua2uPjeg)ZOWH694FgPXrKYW0ocdWnH)4LIwYiVLoYMRw3KlTWvTLpEPONt6952KNgpGdhVYupgP5nSLQWieMMU1C1A68pJwvZHZhVu0FwMlZz5H0RK3fM3WyQGoLQplZL5S8qcqCPn5H010rTBzJWci3bzYunHs8wsGwYwDe)mGBeG4sBYdPRPJA3YgHfqUr8MasjDd0PaefqmMY8UMmKgXBciL0nW2WHZhVu0FwMlZz5H0RK3fM3WyQGoLQplZL5S8qcqCPn5H010rTBzJWci3imnTaDkaxPPBNps30UphcSQCPn5PryAAPLjYWYL2KNUD(iTmrg4GoQRbS6Tw6OUgqDt10XHZhVu0sg5T0r2C16MCPXHZhVu0FwMlZz5H0RK3fM3WyQGoLQplZL5S8qcqeG4sBYdPRPJA3YgP8KagKjt1ekXBjbAjB1r8ZaUraIlTjpKUMoQDlBKYtclGC3oFeOtbytLMqy8pJc)Xlf9NL5YCwEi9k5DH5nmMkOtP6ZYCzolpKaexAtEiDnDu7w2iLNewa5oitMQjuI3sc0s2QJ4NbCJaexAtEiDnDu7w2iLNewa52W0ocJs6gOtbyvnvAcHX)mIdhxAtOKALM2W0ocJs6wiDPnHsk6O9HqBTGV6WOaIXuM31KH0gM2ryus3ad8C4yoJotJK0zQSO(SmxA68pJwH)4LIgjPZuzr9zzU0RK3fgfqmMY8UMmK2W0ocJs6gyHGdNTyJKV5Qd7vM6XinVHTufgHW00TMRwtN)z0IdNpEPO)SmxMZYdPxjVlmVHXubDkvFwMlZz5HeG4sBYdPRPJA3YgP8KWci3bzYunHs8wsGwYwDe)mGBeG4sBYdPRPJA3YgP8KWci3)g3CMcXCegqNcquaXykZ7AYq6FJBotHyocdylcnnTuM31KH4W5Jxk6plZL5S8q6vY7cZBymvqNs1NL5YCwEibiU0M8q6A6O2TSrkpjSaYDqMmvtOeVLeOLSvhXpd4gbiU0M8q6A6O2TSrkpjSaYnI3eqkPBGofGF8srJK0zQSO(SmxA8aoC(4LI(ZYCzolpKEL8UW8ggtf0Pu9zzUmNLhsaIaexAtEi93z(jjGi8Rmnb6ua(XlfnjztaIuOK5TEL8UWF8srts2eGifd)8wVsEx4QAQ0ecJ)zehov5sBcLu0r7dHaBtyxAtOKALMgHFLPPq6sBcLu0r7dHQUAbiU0M8q6VZ8tsybKBK5ncVRjqNcWpEPOjjBcqKcLmV1nT7ZHat6itzZoXHZhVu0KKnbisXWpV1nT7ZHat6itzZojaXL2Khs)DMFsclGCJmVlttGofGF8srts2eGifd)8w30UphcmPJmLn7ehoOK5TIKSjarGvHaexAtEi93z(jjSaYnV2nmGofGF8srts2eGifkzERBA3NdbM0rMYMDIdhg(5TIKSjarGvb8fk1OjpiaGVcWxrf8xfGFd8XZ7BUAe8T1ShKTrlrK)jIU0M8er2GmKwac8XgKHGydF10rTBzJuEsqSHaSbIn8rN)z0cYf8vYwDe)miaBGpxAtEWxqMmvtOeVLe0GaaEi2WhD(NrlixWNShJ6XHVMknHW4FgjIHfXpEPO)SmxMZYdPxjVtedlI8ggtf0Pu9zzUmNLhc(CPn5bFTZhbniaHaIn8rN)z0cYf8vYwDe)miaBGpxAtEWxqMmvtOeVLe0GaSDi2WhD(NrlixWNShJ6XHVQeXMknHW4FgjIC4iIU0Mqj1knTHPDegL0nrmKIOlTjusrhTpese3AfrWlIvlIHfruaXykZ7AYqAdt7imkPBIiyIi4froCerZz0zAKKotLf1NL5stN)z0sedlIF8srJK0zQSO(Smx6vY7eXWIikGymL5DnziTHPDegL0nremrmeIihoI4werBK8nxTigwe9kt9yKM3WwQcJqyA6wZvRPZ)mAjIC4iIF8sr)zzUmNLhsVsENigwe5nmMkOtP6ZYCzolpe85sBYd(mmTJWOKUbniavcIn8rN)z0cYf8vYwDe)miaBGpxAtEWxqMmvtOeVLe0GaSTqSHp68pJwqUGpzpg1JdFOaIXuM31KH0)g3CMcXCegremrCrOPPLY8UMmKiYHJi(Xlf9NL5YCwEi9k5DIyyrK3WyQGoLQplZL5S8qWNlTjp4734MZuiMJWania8pi2WhD(NrlixWxjB1r8ZGaSb(CPn5bFbzYunHs8wsqdca)bXg(OZ)mAb5c(K9yupo89XlfnssNPYI6ZYCPXderoCeXpEPO)SmxMZYdPxjVtedlI8ggtf0Pu9zzUmNLhc(CPn5bFiEtaPKUbnObFlQ44mdIneGnqSHp68pJwqUGpzpg1JdFBre)4LIoOtEmnEGigwe3Ii(XlfncJVsE7eBPXdGpxAtEWhIpCgt9DegObba8qSHp68pJwqUGpzpg1JdFMZOZ0FN5NKuEPm3yaQPZ)mAjIHfXpEPO3Z84Bovj7DnEa85sBYd(A8t5sBYtXgKbFSbzQZ3j477m)Ke0Gaeci2WhD(NrlixWNShJ6XHVTiIF8srlDtvYExJhaFU0M8GpPBQs27qdcW2HydF05FgTGCbFYEmQhh((4LIoOtEmnEGiYHJi(XlfncJVsE7eBPXdGpxAtEWx78rqdcqLGydF05FgTGCbFU0M8GpPZykxAtEk2Gm4JnitD(obFYmzRK3HGgeGTfIn8rN)z0cYf85sBYd(kuNYjXrQ)ye8j7XOEC4BLMUNaTns(MRwedlIR009eOBA3NdjIHuedHigwenVRjtBZoPSuTgsebte3uHigweRsenNrNPr(NAltdJMo)ZOLiwn8jbuYiL5DnziiaBGgea(heB4Jo)ZOfKl4ZL2Kh8vOoLtIJu)Xi4t2Jr94WN5m6mnY)uBzAy005FgTeXWIOm3)PkiNZqIiyIikGymL5DnziTHPDegL0nrmSiUst3tG2gjFZvlIHfXvA6Ec0nT7ZHeXqkIHqedlIM31KPTzNuwQwdjIGjIR009eOBA3NdjIyjIH694FgP7jqzJKpKicUIOlTjpDpbABK8PSzNGpjGsgPmVRjdbbyd0GaWFqSHp68pJwqUGpzpg1JdFYC)NQGCodjIGjIBh(CPn5bFn(PCPn5PydYGp2Gm157e8vMBqyOgbniaBdeB4Jo)ZOfKl4t2Jr94WhkGymL5DnziTHPDegL0nremrCd85sBYd(KoJPCPn5PydYGp2Gm157e8vth1ULns5jbniaBQaIn8rN)z0cYf85sBYd(A8t5sBYtXgKbFSbzQZ3j4RMoQDlBe0Gg8f0Km3)UbXgcWgi2WhD(NrlixWxgaFiYGpxAtEWxOEp(NrWxOodNGVkGVq9wD(obF4iszyAhHbAqaapeB4Jo)ZOfKl4ldGpezWNlTjp4luVh)Zi4luNHtWh4Hpzpg1JdFELPEmsZBylvHrimnDR5Q105FgTGVq9wD(obF4iszyAhHbAqacbeB4Jo)ZOfKl4ldGpezWNlTjp4luVh)Zi4luNHtWh)bFH6T68Dc(6jqzJKpe0GaSDi2WhD(NrlixW357e85vgHXBhPk5zQSOcsEudFU0M8GpVYimE7ivjptLfvqYJAObbOsqSHp68pJwqUGpzpg1JdFF8srVN5X3CQs276vY7GpxAtEWxqN8yqdcW2cXg(CPn5bFbPn5bF05FgTGCbnia8pi2WhD(NrlixWNShJ6XHVpEPO3Z84Bovj7D9k5DWNlTjp47tnIA(Ggea(dIn8rN)z0cYf8j7XOEC47Jxk69mp(MtvYExVsENigwe)4LI2MAQrQcEdOEL8o4ZL2Kh8ztn1ivbVbeAqa2gi2WhD(NrlixWNShJ6XHVpEPO3Z84Bovj7D9k5DWNlTjp4t6MQK9o0Gg8vth1ULncIneGnqSHp68pJwqUGpzpg1JdFOaIXuM31KH0)g3CMcXCegremrCrOPPLY8UMmKigweRse3Ii6vM6XinVHTufgHW00TMRwtN)z0se5WrexPPnmTJWOKUPTrY3C1Iy1IihoI4hVu0FwMlZz5H0RK3jIHfrEdJPc6uQ(SmxMZYdbFU0M8GVFJBotHyocd0GaaEi2WhD(NrlixWxjB1r8ZGaSb(CPn5bFbzYunHs8wsqdcqiGydF05FgTGCbFYEmQhh(QseBQ0ecJ)zKigwerbeJPmVRjdPnmTJWOKUjIGjIGxeRwe5Wre)4LI(ZYCzolpKEL8ormSiYBymvqNs1NL5YCwEi4ZL2Kh8zyAhHrjDdAqa2oeB4Jo)ZOfKl4RKT6i(zqa2aFU0M8GVGmzQMqjEljObbOsqSHp68pJwqUGpzpg1JdFvjIMZOZ0ijDMklQplZLMo)ZOLigwe)4LIgjPZuzr9zzU0RK3jIvlIHfruaXykZ7AYqAdt7imkPBIiyIyiGpxAtEWNHPDegL0nObbyBHydF05FgTGCbFLSvhXpdcWg4ZL2Kh8fKjt1ekXBjbnia8pi2WhD(NrlixWNShJ6XHVpEPOrs6mvwuFwMlnEGiYHJiwLi6sBYtJ4nbKs6ME57EnjIGRiIcigtzExtgsJ4nbKs6MicMiwLi6sBYt3oFKE57EnjIyjIvjIU0M80TZhP(mIwABK8Pw(UxtIi4kIvseRweRweRwe5Wre)4LI(ZYCzolpKEL8ormSiYBymvqNs1NL5YCwEi4ZL2Kh8H4nbKs6g0GaWFqSHp68pJwqUGVs2QJ4Nbbyd85sBYd(cYKPAcL4TKGgeGTbIn8rN)z0cYf85sBYd(ANpc(K9yupo8Tfr0gjFZvlIC4iIvjIBrenNrNP)SmxMZYdPPZ)mAjIHfXM295qIyifXfE72KNicUIyf6qiIvlIHfrZ7AY02StklvRHerWeXTlIC4iIF8sr)zzUmNLhsVsENigwe5nmMkOtP6ZYCzolpe8jbuYiL5DnziiaBGgeGnvaXg(OZ)mAb5c(kzRoIFgeGnWNlTjp4litMQjuI3scAqa2SbIn8rN)z0cYf85sBYd(ANpc(K9yupo8vLiwLi20UphsedjqrK)jIvlIHfXaQrdYOZu74mBcyd1IiyI4knD78r6GDCMnbSHAreCfXk08xLeXQfXWIO5DnzAB2jLLQ1qIiyI42HpjGsgPmVRjdbbyd0GaSb8qSHp68pJwqUGpzpg1JdFF8srh00YTSbuH4nf7iesVsENigweL5(pvb5CgsedPiwjrKdhr8Jxk6plZL5S8q6vY7eXWIiVHXubDkvFwMlZz5HGpxAtEW3EMxzAsjDdAqa2eci2WhD(NrlixWNlTjp4BpZRmnPKUbFYEmQhh(AQ0ecJ)ze8jbuYiL5DnziiaBGgeGnBhIn8rN)z0cYf8j7XOEC4RkrClIOxzQhJ08g2svyectt3AUAnD(NrlrKdhrCLM2W0ocJs6M2gjFZvlIvlIHfXpEPOTPMAKQG3aQXdeXWIyvIy7ZsrHsNP91cPNtebteRse3iIyjI7o)usmExtireCiIsmExtivPDPn55mrSAreCfXMKy8UMu2StIy1IihoI4hVu0FwMlZz5H0RK3jIHfrEdJPc6uQ(SmxMZYdbFU0M8GVFJBotHyocd0GaSPsqSHp68pJwqUGVs2QJ4Nbbyd85sBYd(cYKPAcL4TKGgeGnBleB4Jo)ZOfKl4t2Jr94WxtLMqy8pJeXWIyvIyvIyOEp(NrACePmmTJWiIafrWlIHfXQeXTiIF8srpN07ZTjpnEGiYHJi6vM6XinVHTufgHW00TMRwtN)z0seRweRwe5WrerbeJPmVRjdPnmTJWOKUjIGjIBeXQfroCeXpEPO)SmxMZYdPxjVtedlI8ggtf0Pu9zzUmNLhc(CPn5bFgM2ryus3GgeGn8pi2WhD(NrlixWxjB1r8ZGaSb(CPn5bFbzYunHs8wsqdcWg(dIn8rN)z0cYf8j7XOEC4dfqmMY8UMmKgXBciL0nremrCJiYHJi(Xlf9NL5YCwEi9k5DIyyrK3WyQGoLQplZL5S8qWNlTjp4dXBciL0nObbyZ2aXg(OZ)mAb5c(K9yupo8Tst3oFKUPDFoKicMiwLi6sBYtJW00sltKjIyjIU0M80TZhPLjYerWHish11akIvlIBTIiDuxdOUPA6eroCeXpEPOLmYBPJS5Q1n5ste5Wre)4LI(ZYCzolpKEL8ormSiYBymvqNs1NL5YCwEi4ZL2Kh8HW00cAqd(kZnimuJGydbydeB4Jo)ZOfKl4RKT6i(zqa2aFU0M8GVGmzQMqjEljObba8qSHp68pJwqUGpzpg1JdFF8srJ8q9As1P36vY7GpxAtEWhYd1RjvNEdniaHaIn8rN)z0cYf8vYwDe)miaBGpxAtEWxqMmvtOeVLe0GaSDi2WhD(NrlixWNlTjp4lONDNP41UHb(K9yupo8HcigtzExtgsh0ZUZu8A3WiIGjIBeXWI4knDpb6M295qIyifXTdFsaLmszExtgccWgObbOsqSHp68pJwqUGVs2QJ4Nbbyd85sBYd(cYKPAcL4TKGgeGTfIn8rN)z0cYf85sBYd(c6z3zkETByGpzpg1JdFOaIXuM31KH0b9S7mfV2nmIiyafrWdFsaLmszExtgccWgObbG)bXg(OZ)mAb5c(kzRoIFgeGnWNlTjp4litMQjuI3scAqa4pi2WhD(NrlixWNlTjp4RNa4t2Jr94W3werZz0zAK)P2Y0WOPZ)mAjIHfXMknHW4FgjIHfrZ7AY02StklvRHerWeXvA6Ec0nT7ZHerSeXq9E8pJ09eOSrYhsebxr0L2KNUNaTns(u2StWNeqjJuM31KHGaSbAqa2gi2WhD(NrlixWxjB1r8ZGaSb(CPn5bFbzYunHs8wsqdcWMkGydF05FgTGCbFU0M8GVEcGpzpg1JdFMZOZ0i)tTLPHrtN)z0sedlIvjIBreTrY3C1IihoIyt7(CirmKafXfE72KNicUIyf6qiIHfXaQrdYOZu74mBcyd1IiyI4knDpb6GDCMnbSHArSArmSiAExtM2MDszPAnKicMiUst3tGUPDFoKiILigQ3J)zKUNaLns(qIi4kIvjIBerSeXvA6Ec02i5BUAreCfXqiIvlIGRi6sBYt3tG2gjFkB2j4tcOKrkZ7AYqqa2aniaB2aXg(OZ)mAb5c(kzRoIFgeGnWNlTjp4litMQjuI3scAqa2aEi2WhD(NrlixWNShJ6XHVpEPOrEOEnP60BDt7(CirmKI4gWdFU0M8GpKhQxtQo9gAqa2eci2WhD(NrlixWxjB1r8ZGaSb(CPn5bFbzYunHs8wsqdcWMTdXg(OZ)mAb5c(K9yupo89Xlf905PaNDEinEa85sBYd(29zhAqa2uji2WhD(NrlixW3UZpfDuxdi8Tb(CPn5bFfQt5K4i1Fmc(KakzKY8UMmeeGnqdAW33z(jji2qa2aXg(OZ)mAb5c(K9yupo89XlfnjztaIuOK5TEL8ormSi(XlfnjztaIum8ZB9k5DIyyrSkrSPstim(NrIihoIyvIOlTjusrhTpesebte3iIHfrxAtOKALMgHFLPjrmKIOlTjusrhTpeseRweRg(CPn5bFi8RmnbniaGhIn8rN)z0cYf8j7XOEC47JxkAsYMaePqjZBDt7(Ciremru6itzZojIC4iIF8srts2eGifd)8w30UphsebteLoYu2StWNlTjp4dzEJW7AcAqacbeB4Jo)ZOfKl4t2Jr94W3hVu0KKnbisXWpV1nT7ZHerWerPJmLn7KiYHJiIsM3ksYMaejIGjIvaFU0M8GpK5DzAcAqa2oeB4Jo)ZOfKl4t2Jr94W3hVu0KKnbisHsM36M295qIiyIO0rMYMDse5Wrez4N3ksYMaejIGjIvaFU0M8GpETByGg0GpzMSvY7qqSHaSbIn8rN)z0cYf8j7XOEC4JoQRbuebdOigIkeXWIyvIOmt2k5DABQPgPk4nG6M295qIiyIyLeroCeXpEPOTPMAKQG3aQXdeXQHpxAtEW3NAe18bniaGhIn8rN)z0cYf8j7XOEC4JoQRbuVOYihtebdOiUTviIC4iIF8srBtn1ivbVbuVsEh85sBYd(SPMAKQG3acniaHaIn85sBYd((uJOMV5QHp68pJwqUGgeGTdXg(OZ)mAb5c(K9yupo85sBcLu0r7dHerWeXfHMMwkZ7AYqIihoIy7ZsrHsNP91cPNtebte3ELGpxAtEWNHj7dbniavcIn8rN)z0cYf8j7XOEC47Jxk6MK8XiesvYwsA8arKdhr8JxkABQPgPk4nGA8a4ZL2Kh8zyif(9t8BPkzljObbyBHydF05FgTGCbFYEmQhh((4LI2MAQrQcEdOgpqedlIF8sr)PgrnF6vY7GpxAtEW3oTNnGQSOy4YzPwn57iObbG)bXg(OZ)mAb5c(K9yupo89XlfTn1uJuf8gqnEa85sBYd((SmxQSOmmKIoAhqObbG)GydF05FgTGCbFYEmQhh(K5(pvb5CgsebkIvaFU0M8GVc1otvA6QmGqdcW2aXg(OZ)mAb5c(K9yupo85sBcLu0r7dHerWeXfHMMwkZ7AYqIihoIyvIy7ZsrHsNP91cPNtebte3MkeXWIiDuxdOErLroMicgqrSsviIvdFU0M8GVskXr0s5vM6Xi1N8DObbytfqSHp68pJwqUGpzpg1JdFU0MqjfD0(qiremrCrOPPLY8UMmKiYHJi2(SuuO0zAFTq65erWeXTTc4ZL2Kh8fG3tbW5QvFMJmObbyZgi2WhD(NrlixWNShJ6XHVpEPOTPMAKQG3aQXdGpxAtEWxnU3RXpvwuELPonmqdcWgWdXg(OZ)mAb5c(K9yupo89XlfTn1uJuf8gqnEa85sBYd(K5jPZA3OLQW8DcAqa2eci2WhD(NrlixWNShJ6XHVpEPOTPMAKQG3aQXdGpxAtEWxpbbmsnNcf4scAqa2SDi2WhD(NrlixWNShJ6XHVpEPOTPMAKQG3aQXdGpxAtEWhVSzRqP5unHYZpjbniaBQeeB4Jo)ZOfKl4t2Jr94WN5DnzAB2jLLQ1qIyifXn6kjIC4iIvjIvjIM31KPXqoZWOdKMicMiYFviIC4iIM31KPXqoZWOdKMigsGIi4RqeRwedlIM31KPTzNuwQwdjIGjIGFBeXQfroCeXQerZ7AY02Stklvbstb(kerWeXquHigwenVRjtBZoPSuTgsebte3(2fXQHpxAtEWxtEWC1QcZ3je0GaSzBHydF05FgTGCbFYEmQhh(OJ6AafrWakIHOcrmSiwLikZKTsEN2MAQrQcEdOUPDFoKicMiUPsIihoI4hVu02utnsvWBa14bIy1WNlTjp4BoP3NBtEqdcWg(heB4Jo)ZOfKl4t2Jr94WN5DnzAB2jLLQ1qIyifXTTsIihoIyvIOn7KYs1AirmKI4g(RcrmSiwLi(Xlf9NAe18PXderoCeXpEPONt6952KNgpqeRweRg(CPn5bFbPn5bniaB4pi2WhD(NrlixWNShJ6XHpzU)tvqoNHeXqkIvsedlI0rDnGIiyafrxAtE625J0YezIyyrCLMUD(iDWooZMa2qTigsre86nIyyr8JxkABQPgPk4nGA8armSiwLi(Xlf9NL5YCwEinEGiYHJiUfr0CgDM(ZYCzolpKMo)ZOLiwTigweRse3IiAoJotpN07ZTjpnD(NrlrKdhruMjBL8o9CsVp3M80nT7ZHerWeXn8NiwTigwe3Ii(Xlf9CsVp3M804bWNlTjp4dHXxjVDITGgeGnBdeB4Jo)ZOfKl4ZL2Kh85imH6hHuTx5SvYSDg8j7XOEC4BrF8sr3ELZwjZ2zQf9Xlf9k5DIihoI4I(4LIwM3cxAtOKAo(ul6JxkA8armSiAExtM2MDszPkqAQquHigsrCJUsIihoI4weXf9XlfTmVfU0Mqj1C8Pw0hVu04bIyyrSkrCrF8sr3ELZwjZ2zQf9XlfnYCjFIiyafrWxjreCiIBQqebxrCrF8sr)zzUuzrzyifD0oGA8arKdhr0MDszPAnKigsrC7viIvlIHfXpEPOTPMAKQG3aQBA3NdjIGjIBQa(oFNGphHju)iKQ9kNTsMTZGgeaWxbeB4Jo)ZOfKl4ZL2Kh8jbuYsRZBKQpZrg8j7XOEC4RkrKoQRbuVOYihtebdOish11aQBQMoreCfXqiIvlIHfXpEPOTPMAKQG3aQxjVtedlIBre9kt9yKgCg)QzKQG3aQPZ)mAbFuPqstD(obFsaLS068gP6ZCKbniaGFdeB4Jo)ZOfKl4ZL2Kh8jbuYsRZBKQpZrg8j7XOEC47JxkABQPgPk4nGA8armSi6vM6Xin4m(vZivbVbutN)z0c(OsHKM68Dc(KakzP15ns1N5idAqaap4HydF05FgTGCbFU0M8GpVYimE7ivjptLfvqYJA4t2Jr94WhDuxdOErLroMicgqrSsvaFuPqstD(obFELry82rQsEMklQGKh1qdca4dbeB4Jo)ZOfKl4t2Jr94W3hVu02utnsvWBa14bIihoIOn7KYs1AirmKIi4Ra(CPn5bF4isngTJGg0Gg854gMSHV3SV1dnObHa]] )


end
