-- DruidFeral.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID = ns.FindUnitBuffByID


-- Conduits
-- [-] carnivorous_instinct
-- [-] incessant_hunter
-- [x] sudden_ambush
-- [ ] taste_for_blood


if UnitClassBase( "player" ) == "DRUID" then
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


    local mod_circle_hot = setfenv( function( x )
        return legendary.circle_of_life_and_death.enabled and ( 0.85 * x ) or x
    end, state )

    local mod_circle_dot = setfenv( function( x )
        return legendary.circle_of_life_and_death.enabled and ( 0.75 * x ) or x
    end, state )


    -- Auras
    spec:RegisterAuras( {
        adaptive_swarm_dot = {
            id = 325733,
            duration = function () return mod_circle_dot( 12 ) end,
            max_stack = 1,
            copy = "adaptive_swarm_damage"
        },
        adaptive_swarm_hot = {
            id = 325748,
            duration = function () return mod_circle_hot( 12 ) end,
            max_stack = 1,
            copy = "adaptive_swarm_heal"
        },
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
            copy = { 279526, "berserk_cat" },
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
            max_stack = function() return talent.moment_of_clarity.enabled and 2 or 1 end,
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
        --[[ Inherit from Balance to support empowerment.
        eclipse_lunar = {
            id = 48518,
            duration = 10,
            max_stack = 1,
        },
        eclipse_solar = {
            id = 48517,
            duration = 10,
            max_stack = 1,
        }, ]]
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
            max_stack = 1,
            copy = { 108292, 108293, 108294 }
        },
        hibernate = {
            id = 2637,
            duration = 40,
        },
        incarnation = {
            id = 102543,
            duration = 30,
            max_stack = 1,
            copy = "incarnation_king_of_the_jungle"
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
            duration = function () return mod_circle_dot( 16 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonfire_cat = {
            id = 155625,
            duration = function () return mod_circle_dot( 16 ) end,
            tick_time = function() return mod_circle_dot( 2 ) * haste end,
            max_stack = 1,
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
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function() return mod_circle_dot( 3 ) * haste end,
        },
        ravenous_frenzy = {
            id = 323546,
            duration = 20,
            max_stack = 20,
        },
        ravenous_frenzy_stun = {
            id = 323557,
            duration = 1,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = function () return mod_circle_hot( 12 ) end,
            type = "Magic",
            max_stack = 1,
        },
        rip = {
            id = 1079,
            duration = function () return mod_circle_dot( 24 ) end,
            tick_time = function() return mod_circle_dot( 2 ) * haste end,
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
            duration = function () return mod_circle_dot( 12 ) end,
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
            duration = function () return mod_circle_dot( 15 ) end,
            max_stack = 3,
        },
        thrash_cat ={
            id = 106830,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function() return mod_circle_dot( 3 ) * haste end,
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

        eye_of_fearful_symmetry = {
            id = 339142,
            duration = 15,
            max_stack = 1,
        },


        -- Conduits
        sudden_ambush = {
            id = 340698,
            duration = 15,
            max_stack = 1
        }
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

    spec:RegisterStateExpr( "persistent_multiplier", function ()
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
            elseif ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
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
        if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )

        if legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent.restoration_affinity.enabled then
            applyBuff( "heart_of_the_wild" )
            applyDebuff( "player", "oath_of_the_elder_druid_icd" )
        end
    end )


    local affinities = {
        bear_form = "guardian_affinity",
        cat_form = "feral_affinity",
        moonkin_form = "balance_affinity",
    }

    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        if conduit.tireless_pursuit.enabled and ( buff.cat_form.up or buff.travel_form.up ) then applyBuff( "tireless_pursuit" ) end

        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        applyBuff( form )

        if affinities[ form ] and legendary.oath_of_the_elder_druid.enabled and debuff.oath_of_the_elder_druid_icd.down and talent[ affinities[ form ] ].enabled then
            applyBuff( "heart_of_the_wild" )
            applyDebuff( "player", "oath_of_the_elder_druid_icd" )
        end
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if not a or a.startsCombat then
            break_stealth()
        end

        if buff.ravenous_frenzy.up and ability ~= "ravenous_frenzy" then
            addStack( "ravenous_frenzy", nil, 1 )
        end
    end )


    spec:RegisterStateExpr( "lunar_eclipse", function ()
        return 0
    end )

    spec:RegisterStateExpr( "solar_eclipse", function ()
        return 0
    end )


    spec:RegisterAuras( {
        bt_brutal_slash = {
            duration = 4,
            max_stack = 1,
        },
        bt_moonfire = {
            duration = 4,
            max_stack = 1,            
        },
        bt_rake = {
            duration = 4,
            max_stack = 1
        },
        bt_shred = {
            duration = 4,
            max_stack = 1,
        },
        bt_swipe = {
            duration = 4,
            max_stack = 1,
        },
        bt_thrash = {
            duration = 4,
            max_stack = 1
        }
    } )


    local bt_auras = {
        bt_brutal_slash = "brutal_slash",
        bt_moonfire = "moonfire_cat",
        bt_rake = "rake",
        bt_shred = "shred",
        bt_swipe = "swipe_cat",
        bt_thrash = "thrash_cat"
    }

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

        -- Bloodtalons
        if talent.bloodtalons.enabled then
            for bt_buff, bt_ability in pairs( bt_auras ) do
                local last = action[ bt_ability ].lastCast

                if now - last < 4 then
                    applyBuff( bt_buff )
                    buff[ bt_buff ].applied = last
                    buff[ bt_buff ].expires = last + 4
                end
            end
        end

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

            if legendary.frenzyband.enabled then
                gainChargeTime( talent.incarnation.enabled and "incarnation" or "berserk", 0.2 )
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

    spec:RegisterStateExpr( "active_bt_triggers", function ()
        if not talent.bloodtalons.enabled then return 0 end

        local btCount = 0

        for k, v in pairs( combo_generators ) do
            if k ~= this_action then
                local lastCast = action[ k ].lastCast

                if lastCast > last_bloodtalons and query_time - lastCast < 4 then
                    btCount = btCount + 1
                end
            end
        end

        return btCount
    end )

    spec:RegisterStateExpr( "will_proc_bloodtalons", function ()
        if not talent.bloodtalons.enabled then return false end
        if query_time - action[ this_action ].lastCast < 4 then return false end
        return active_bt_triggers == 2
    end )

    spec:RegisterStateFunction( "proc_bloodtalons", function()
        for aura in pairs( bt_auras ) do
            removeBuff( aura )
        end

        applyBuff( "bloodtalons", nil, 2 )
        last_bloodtalons = query_time
    end )


    -- Legendaries.  Ugh.
    spec:RegisterGear( "ailuro_pouncers", 137024 )
    spec:RegisterGear( "behemoth_headdress", 151801 )
    spec:RegisterGear( "chatoyant_signet", 137040 )
    spec:RegisterGear( "ekowraith_creator_of_worlds", 137015 )
    spec:RegisterGear( "fiery_red_maimers", 144354 )
    spec:RegisterGear( "luffa_wrappings", 137056 )
    spec:RegisterGear( "soul_of_the_archdruid", 151636 )
    spec:RegisterGear( "the_wildshapers_clutch", 137094 )

    -- Legion Sets (for now).
    spec:RegisterGear( "tier21", 152127, 152129, 152125, 152124, 152126, 152128 )
        spec:RegisterAura( "apex_predator", {
            id = 252752,
            duration = 25
         } ) -- T21 Feral 4pc Bonus.

    spec:RegisterGear( "tier20", 147136, 147138, 147134, 147133, 147135, 147137 )
    spec:RegisterGear( "tier19", 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( "class", 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )


    -- Abilities
    spec:RegisterAbilities( {
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = function () return 60 * ( 1 + ( conduit.tough_as_bark.mod * 0.01 ) ) end,
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
            handler = function ()
                shift( "bear_form" )
                if conduit.ursine_vigor.enabled then applyBuff( "ursine_vigor" ) end
            end,
        },


        berserk = {
            id = 106951,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
            gcd = "off",

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
                if buff.clearcasting.up then
                    if legendary.cateye_curio.enabled then
                        return 25 * -0.25
                    end
                    return 0
                end
                return max( 0, 25 * ( ( buff.berserk.up or buff.incarnation.up ) and 0.6 or 1 ) + buff.scent_of_blood.v1 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132141,

            form = "cat_form",
            talent = "brutal_slash",

            handler = function ()
                gain( 1, "combo_points" )

                applyBuff( "bt_brutal_slash" )
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

                if buff.eye_of_fearful_symmetry.up then gain( 3, "combo_points" ) end

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


        heart_of_the_wild = {
            id = 319454,
            cast = 0,
            cooldown = function () return 300 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135879,

            handler = function ()
                applyBuff( "heart_of_the_wild" )
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
            gcd = "off",

            startsCombat = false,
            texture = 571586,

            toggle = "cooldowns",
            talent = "incarnation",
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

                if buff.eye_of_fearful_symmetry.up then gain( 3, "combo_points" ) end

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
            cooldown = function () return 30  * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
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
            cooldown = function () return 60 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
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
                applyBuff( "bt_moonfire" )
                if will_proc_bloodtalons then proc_bloodtalons() end
            end,

            copy = { 8921, 155625, "moonfire_cat", "lunar_inspiration" }
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
                applyDebuff( "target", "rip", mod_circle_dot( 2 + 2 * combo_points.current ) )
                active_dot.rip = active_enemies

                spend( combo_points.current, "combo_points" )
                removeStack( "bloodtalons" )

                if buff.eye_of_fearful_symmetry.up then gain( 3, "combo_points" ) end

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

                applyBuff( "bt_rake" )
                if will_proc_bloodtalons then proc_bloodtalons() end

                removeBuff( "sudden_ambush" )
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

            auras = {
                -- Conduit
                born_anew = {
                    id = 341448,
                    duration = 8,
                    max_stack = 1
                }
            }
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

                applyDebuff( "target", "rip", mod_circle_dot( min( 1.3 * class.auras.rip.duration, debuff.rip.remains + class.auras.rip.duration ) ) )
                debuff.rip.pmultiplier = persistent_multiplier

                removeStack( "bloodtalons" )

                if buff.eye_of_fearful_symmetry.up then gain( 3, "combo_points" ) end

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

                if buff.eye_of_fearful_symmetry.up then gain( 3, "combo_points" ) end

                opener_done = true
            end,
        },


        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.clearcasting.up then
                    if legendary.cateye_curio.enabled then return -10 end
                    return 0
                end
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

                applyBuff( "bt_shred" )
                if will_proc_bloodtalons then proc_bloodtalons() end
                removeBuff( "sudden_ambush" )
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
            cast = function () return ( buff.heart_of_the_wild.up and 0 or 2 ) * haste end,
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
                if buff.clearcasting.up then
                    if legendary.cateye_curio.enabled then return 35 * -0.25 end
                    return 0
                end
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

                applyBuff( "bt_swipe" )
                if will_proc_bloodtalons then proc_bloodtalons() end
                removeStack( "clearcasting" )
            end,

            copy = { 213764, "swipe" },
            bind = { "swipe_cat", "swipe_bear", "swipe", "brutal_slash" }
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
                if buff.clearcasting.up then
                    if legendary.cateye_curio.enabled then return -10 end
                    return 0
                end
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

                active_dot.thrash_cat = max( active_dot.thrash, active_enemies )
                debuff.thrash_cat.pmultiplier = persistent_multiplier

                if talent.scent_of_blood.enabled then
                    applyBuff( "scent_of_blood" )
                    buff.scent_of_blood.v1 = -3 * active_enemies
                end

                removeStack( "clearcasting" )
                if target.within8 then
                    gain( 1, "combo_points" )
                    applyBuff( "bt_thrash" )
                    if will_proc_bloodtalons then proc_bloodtalons() end
                end
            end,

            copy = { "thrash", 106832 },
            bind = { "thrash_cat", "thrash_bear", "thrash" }
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

                if legendary.eye_of_fearful_symmetry.enabled then
                    applyBuff( "eye_of_fearful_symmetry" )
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


        -- Covenants (belongs in DruidBalance, really).

        -- Druid - Kyrian    - 326434 - kindred_spirits      (Kindred Spirits)
        --                   - 326647 - empower_bond         (Empower Bond)
        kindred_spirits = {
            id = 326434,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 3565444,

            essential = true,

            usable = function ()
                return buff.lone_spirit.down and buff.kindred_spirits.down, "lone_spirit/kindred_spirits already applied"
            end,

            bind = "empower_bond",

            handler = function ()
                unshift()
                -- Let's just assume.
                applyBuff( "lone_spirit" )
            end,

            auras = {
                -- Damager
                kindred_empowerment = {
                    id = 327139,
                    duration = 10,
                    max_stack = 1,
                    copy = "kindred_empowerment_energize",
                },
                -- From Damager
                kindred_empowerment_partner = {
                    id = 327022,
                    duration = 10,
                    max_stack = 1,
                },
                kindred_focus = {
                    id = 327148,
                    duration = 10,
                    max_stack = 1,
                },
                kindred_focus_partner = {
                    id = 327071,
                    duration = 10,
                    max_stack = 1,
                },
                -- Tank
                kindred_protection = {
                    id = 327037,
                    duration = 10,
                    max_stack = 1,
                },
                kindred_protection_partner = {
                    id = 327148,
                    duration = 10,
                    max_stack = 1,
                },
                kindred_spirits = {
                    id = 326967,
                    duration = 3600,
                    max_stack = 1,
                },
                lone_spirit = {
                    id = 338041,
                    duration = 3600,
                    max_stack = 1,
                },
                lone_empowerment = {
                    id = 338142,
                    duration = 10,
                    max_stack = 1,
                },                
            }
        },

        empower_bond = {
            id = 326647,
            known = function () return covenant.kyrian and ( buff.lone_spirit.up or buff.kindred_spirits.up ) end,
            cast = 0,
            cooldown = function () return 60 * ( 1 - ( conduit.deep_allegiance.mod * 0.01 ) ) end,
            gcd = "spell",

            startsCombat = false,
            texture = 3528283,

            usable = function ()
                return buff.lone_spirit.up or buff.kindred_spirits.up, "requires kindred_spirits/lone_spirit"
            end,

            toggle = "essences",

            bind = "kindred_spirits",

            handler = function ()
                if buff.lone_spirit.up then
                    if role.tank then applyBuff( "lone_protection" )
                    elseif role.healer then applyBuff( "lone_meditation" )
                    else applyBuff( "lone_empowerment" ) end
                else
                    if role.tank then
                        applyBuff( "kindred_protection" )
                        applyBuff( "kindred_protection_partner" )
                    elseif role.healer then
                        applyBuff( "kindred_meditation" )
                        applyBuff( "kindred_meditation_partner" )
                    else
                        applyBuff( "kindred_empowerment" )
                        applyBuff( "kindred_empowerment_partner" )
                    end
                end
            end,

            copy = { "lone_empowerment", "lone_meditation", "lone_protection", 326462, 326446, 338142, 338018 }
        },

        -- Druid - Necrolord - 325727 - adaptive_swarm       (Adaptive Swarm)
        adaptive_swarm = {
            id = 325727,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = true,
            texture = 3578197,

            handler = function ()
                applyDebuff( "target", "adaptive_swarm_dot", nil, 325733 )
            end,

            copy = "adaptive_swarm_damage"
        },

        -- Druid - Night Fae - 323764 - convoke_the_spirits  (Convoke the Spirits)
        convoke_the_spirits = {
            id = 323764,
            cast = 4,
            channeled = true,
            cooldown = 120,
            gcd = "spell",

            toggle = "essences",

            startsCombat = true,
            texture = 3636839,

            finish = function ()
                -- Can we safely assume anything is going to happen?
                if state.spec.feral then
                    applyBuff( "tigers_fury" )
                    if target.distance < 8 then
                        gain( 5, "combo_points" )
                    end
                elseif state.spec.guardian then
                elseif state.spec.balance then
                end
            end,
        },

        -- Druid - Venthyr   - 323546 - ravenous_frenzy      (Ravenous Frenzy)
        ravenous_frenzy = {
            id = 323546,
            cast = 0,
            cooldown = 180,
            gcd = "off",

            startsCombat = true,
            texture = 3565718,

            toggle = "essences",

            handler = function ()
                applyBuff( "ravenous_frenzy" )
            end,
        }
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

    spec:RegisterPack( "Feral", 20201013, [[dO0P(aqibq9iceDjvQIAteKpPsvOrjLYPKs1Qiq6vGkZsk5wcaTlk9lcyyeuhtfzzQu5zcittqvxJa12eq13eqX4iq4CQuLwNaaMNa09uH9jOCqbaLfcQ6HcOutuaeDrbaYgfaPpkaiDsbuYkvrntvQICtbav7uLYpfaHLQsvWtLyQQK(QaGyVk9xHgSKomPflvpgvtgOlJSzk(minAq50IwTGkEniA2OCBPy3Q63qgoHoUaa1Yv8COMovxhW2vj(UGmEbv68GW6vPQMVaTFIEpTx3cO60E7oHVt4tcFkqwHf(09k4aTfhcrAlIkhsfkTLxBOTeGsJY2IOcbdPG71TGradN2cm3fXbaeqaOPddOB5OgbWzdat9e98rnUa4SHlWw6ajZdS(TVfq1P92DcFNWNe(0D27cKGd8tcElyrIV3ojCG2cSeeK(TVfqcZ3IGuwdqPrzYAaYbibLNfKYAacUJ60iRNURLSENW3j8wehKjz0weKYAaknktwdqoajO8SGuwdqWDuNgz90DTK17e(oHLNLNvUNOhBfhIJA6Qd3Hax0j1oJA9AdDyqadxm2tNADrza0HWYZcszTaBiqz9qwfULSEd9bq8RIyyixwVhuijz9qwp1swlVkIHHCz9EqHKK1dz9UwY69uGLSEiRbQLSwcLIKSEiRHxEw5EIESvCioQPRoChcCrNu7mQ1Rn0HjzmAADrza0Xj5zL7j6XwXH4OMU6WDiWfDsTZOwV2qhMKXOP1fLbqhc3knh69PjDYgkzGrdJWWg6bZhQLETZiq5zL7j6XwXH4OMU6WDiWfDsTZOwV2qhtkg9KdjU1fLbqhbg5zL7j6XwXH4OMU6WDiWfDsTZOwV2qhoSrXWIEYHe36IYaOdbH8SY9e9yR4qCutxD4oe4IoP2zuRxBOdh2Oyyrp5qIBDrza0HWTsZHEFAsNSHsgy0WimSHEW8HAPx7mcuEw5EIESvCioQPRoChcaz(GdbgXI5KowEw5EIESvCioQPRoChcioOqSwP5Odym2ge6Hm)ObnnwquOxEw5EIESvCioQPRoChc4juAWrdWarR0C0bmgBdc9qMF0GMglik0luhWySEcLgC0amqybrHE5zL7j6XwXH4OMU6WDiax9ObnnYZYZcsznaOWL4aobkR0fAGqw9SHKvhgjRk3rJSMyzvVOjt7mYkpRCprp(GRE0GMMwP5OdymwU6rdAASGOqV8SY9e9y4oeya(OY9e9rwI9wV2qhDLPpNALMdxz072UY0Ntr1yYpDiS0RDgbkuhWySni0dz(rdAASaIYZk3t0JH7qamKamwSRyyYZk3t0JH7qaXbfIjpRCprpgUdb4kJfvUNOpYsS361g6GJqmquOxEw5EIEmChcmaFu5EI(ilXERxBOdt(jggnTsZbh10rrru(ooSJ2eCa8IoP2zK1GagUySNo1U8SY9e9y4oeya(OY9e9rwI9wV2qhyNuMdRvAo6agJTtdMgiJC1TaIbd2bmgB(CDE1t0BbedgSdymwmmfefQHyGwaXGb7agJfdacsFuB6ayywaXGb7agJvCqHywar5zL7j6XWDiGcQIEEHI4q60ipRCprpgUdb4O)ccsk6WOiwmN0XTsZbh10rrru(ooG3jpliL1RWizTbHDzLcxr6X5fswH)QSYHGZizTTRWgcdtwlWgcuwlHsrsw5iSlRNojyzLEAGcrlzTrHKKvmWqYAisw56lRnkKKS6WuxwZxwdVScLH6kd3U8SY9e9y4oeqeHyXHWiGHtTsZHRm6DBNHqGUYqp2sV2zeOqDaJX2zieORm0JTGOqVqTrpnqHaUazfSGspnqHWoeu6HRTWlSG2bmglNr6WvSNpulGy7Th2rBNoj4a4Dbsq7agJnFUoV6j6JqMp0iYeDyumCaEOmYci2Uqk3ZluS7rFsOqPbFiS8SY9e9y4oeya(OY9e9rwI9wV2qhDgcb6kd94wP5Wvg9UTZqiqxzOhBPx7mcuO26agJTZqiqxzOhBbrH(GbvUNxOy3J(KqHsd(4U2LNvUNOhd3HaJcj1IdbNrrxhOKJpo1knhdzgcdt7mkyqrAWj2P3JnampfzjnHbIC7OqswXgaMNISKg5zL7j6XWDiGHgLfnd93hIwP5GJA6OOikFhFiS8SY9e9y4oeObHEtouKREloeCgfDDGso(4uR0CmKzimmTZi5zL7j6XWDiGdBumSix9wP5yiZqyyANrYZk3t0JH7qG(a4klIzkgwR0C0whWySEcLgC0amqybefQTrtWiDHE3QGGyB(H12j4A0WnYHPducha5W0bkHJMr5EIEL1UGoehMoqPONnu7TluByrIXIUoqjhB7dGRSiMPyycQY9e92(a4klIzkgMfuBuO09SY9e92(a4klIzkgMLJWE7H1MY9e9wmSHaTGAJcLUNvUNO3IHneOLJWE7YZk3t0JH7qaCOuKIC1BLMdSiXyrxhOKJT4qPif5Qh2DYZk3t0JH7qamSHaBLMJoGXy5mshUI98HAbeLNvUNOhd3HaCLXIk3t0hzj2B9AdDysgJMwP5GEAGcH1Zgk6OyJgUb8uWGbyxz072odHaDLHESLETZiq5z5zL7j6X2odHaDLHE8XOqsT4qWzu01bk54JtTsZrBbyp5qMp0GbBBiZqyyANrcjsdoXo9ESbG5PilPjmqKBhfsYk2aW8uKL00E7c1bmgB3JJcjzbrHE5zL7j6X2odHaDLHEmChcWaEDI5JfZr9e9T4qWzu01bk54JtTsZXqMHWW0oJeQdym2UhBqO3KdzbrHE5zL7j6X2odHaDLHEmChc4WgfdlYvVfhcoJIUoqjhFCQvAogYmegM2zKqDaJX29OdBummlik0lpRCprp22zieORm0JH7qG(a4klIzkgwR0C0bmgB3J9bWvweZummlik0lpRCprp22zieORm0JH7qaCOuKIC1BLMJoGXy7Eehkfjlik0lewKySORduYXwCOuKIC1d7K8SY9e9yBNHqGUYqpgUdbWWgcSvAo6agJT7rmSHaTGOqV8SY9e9yBNHqGUYqpgUdbWHsrkYvVvAo6agJT7rCOuKSGOqV8SY9e9yBNHqGUYqpgUdbCyJIHf5Q3knhDaJX29OdBummlik0lplpRCprp2Yrigik0F0PbtdKTsZrhWySIdkeZcIc9YZk3t0JTCeIbIc9WDiq(CDE1t03knhDaJXkoOqmlik0lpliL1RdeYQ(GY6JCznKIDswVgGkR0tduiAjRDaxwvggjRqrYQbnY69PbszvFqzLRZlpRCprp2Yrigik0d3HaEcLgC0amq0knh0tduiSGKj5PhMGfCWGT1bmgBNgmnqg5QBbefQdym2onyAGmYv3ouJMpoGNcu7bd2whWyS5Z15vprVfquOoGXyZNRZREI(iK5dnImrhgfdhGhkJSd1O5Jd4Pa1U8SY9e9ylhHyGOqpChcGHPGOqnedSvAo6agJ1tO0GJgGbclGOqDaJX2PbtdKrU6wquOxOoGXyZNRZREI(iK5dnImrhgfdhGhkJSGOqVqDaJXkoOqmlik0leh10rrru(ooGHxiqKBhfsYk2aW8uKL0eWt2axi6PbkeHfEHLNvUNOhB5iedef6H7qaQrefIMyh9GTsZrhWySEcLgC0amqybeLNvUNOhB5iedef6H7qGonyAGmFOTsZrhWySEcLgC0amqybedgSdym2onyAGmYv3cigmyhWyS5Z15vprFeY8HgrMOdJIHdWdLrwar5zL7j6XwocXarHE4oeqe5j6BLMJoGXy70GPbYixDlGyWGDaJXMpxNx9e9riZhAezIomkgoapugzbeLNvUNOhB5iedef6H7qGrVqpcahnd93hIwP5GEAGcHfKmjp9akS9oblO0tduiSnA4kpRCprp2Yrigik0d3HaCLXIk3t0hzj2B9AdDqym9CsEw5EIESLJqmquOhUdbaWumDQP1Rn0HIHDrFchh9(OjYrJYALMdqQdym2rVpAIC0OSii1bmglik0hmii1bmglh9GaCpVqX8HmcsDaJXcikKRduYTE2qrhff5EmqchWtwbhmyagK6agJLJEqaUNxOy(qgbPoGXybefQnqQdym2rVpAIC0OSii1bmgl2voKHDCNGdGNewqbPoGXy7mecmImrhgfPNAGWcigmORduYTE2qrhfbtkGHx42fQdymwpHsdoAagiSd1O5Jd7KWYZk3t0JTCeIbIc9WDiaaMIPtn4wP5OdymwpHsdoAagiSaIbd66aLCRNnu0rrWKc4DclplpRCprp2sym9C6WHHMh3knhk3ZluKEQjjCyGeohcm66aLCCWGJMGr6c9UvbbX28dl8cwEw5EIESLWy65eChc4WOiW3rapy0Ggo1knhDaJXoehsgHXrdA4KfqmyWoGXy9ekn4ObyGWcikpRCprp2sym9CcUdbAOg0arezImaEcgbhsBWTsZrhWySDAW0azKRUfqmyWoGXyZNRZREI(iK5dnImrhgfdhGhkJSaIYZk3t0JTegtpNG7qGodHaJit0Hrr6PgiALMJoGXy9ekn4ObyGWcikeh10rrru(o(qWYZk3t0JTegtpNG7qadIdGjWOEFAsNIDsBALMdL75fksp1KeomqcNdbgDDGsooyW2gnbJ0f6DRccIT5h29kSq0tduiSGKj5Ph2HGfUD5zL7j6XwcJPNtWDiGiWKgiYhASZuS3knhk3ZluKEQjjCyGeohcm66aLCCWGJMGr6c9UvbbX28dlWfwEw5EIESLWy65eChcafqhWu)iYe17tdYH1knhDaJX6juAWrdWaHfquEw5EIESLWy65eChcWrpNEFuNaJgM2qTsZrhWySEcLgC0amqybeLNvUNOhBjmMEob3HatkkYOy(rSOYPwP5OdymwpHsdoAagiSaIYZk3t0JTegtpNG7qGqOHbEHYpoeg96ZPwP5OdymwpHsdoAagiSaIYZk3t0JTegtpNG7qGHuX8HgnmTHWT4qWzu01bk54wP5W1bk5wpBOOJIGjfWtwbhmyBT56aLClmszomRi3dtqiCWGUoqj3cJuMdZkY9aECNWTlKRduYTE2qrhfbtkS7U32dgSnxhOKB9SHIokkY94DchwGewixhOKB9SHIokcMuyHp8TlplpRCprp2AsgJMJrHKAXHGZOORduYXhNALMJl6KANrwtYy0CCsiqKBhfsYk2aW8uKL0eWdrAWj2P3JnampfzjncnKzimmTZi5zL7j6XwtYy0a3HaJcj1knhx0j1oJSMKXO54oHgYmegM2zK8SY9e9yRjzmAG7qagWRtmFSyoQNOVvAoUOtQDgznjJrZrGeAiZqyyANrYZk3t0JTMKXObUdbWHsrQvAoUOtQDgznjJrZr4LNvUNOhBnjJrdChcGHneO8S8SY9e9yRj)edJMdSErHsXbPtR0CmKzimmTZi5zbPSgaUcjjRyGHKvhjR3NgKS6Wiz9IoP2zKSIrYkg1qYkIbkRxugajRGO)E0Lv6bLvarzLLpuAYhQ8SY9e9yRj)edJg4oe4IoP2zuRxBOJoH94KITUOma6q4wP5Wvg9UvCYgLfdnQdZsV2zeO8SGuwvUNOhBn5Nyy0a3HaCi4S8HgVOtQDg161g6OtypoPylK4rJgUTUOma6aCasq7KIwp5qIJq18jWi6JdzgcdRvAoCLrVBfNSrzXqJ6WS0RDgbkpRCprp2AYpXWObUdbeNSrzXqJ6WAXHGZOORduYXhNALMdSiXyrxhOKJTIt2OSyOrDyH1wGG7KG6kJE3I1onoc5WS0RDgb2U8SY9e9yRj)edJg4oeysXwCi4mk66aLC8XPwP5OTaSNCiZhAWGTnuJMpgooQPJIIO8DSG6kJE3I1onoc5WS0RDgb2Eabbg1t0lOcBduWGGi3oPOvSbG5PilPjGI0GtStVhBayEkYsAAxOHmdHHPDgjpRCprp2AYpXWObUdbA0SPvAo6agJnh0hdhne2cikpRCprp2AYpXWObUdbm0G4jcah7PtTA0WnspnqH44uloeCgfDDGso(4K8S8SY9e9yl2jL5WogGpQCprFKLyV1Rn0rNHqGUYqpUvAoCLrVB7mec0vg6Xw61oJafQdym2odHaDLHESfef6LNvUNOhBXoPmhgChcmkKuloeCgfDDGso(4uR0CaIC7OqswXgaMNISKMaEYg4YZk3t0JTyNuMddUdbWWgcuEwEw5EIESTRm950bg4n5qTsZrhWySeNLIykIrmDSGOqVqDaJXsCwkIPid41XcIc9c12qMHWW0oJcgSnL75fksp1KeoStcPCpVqrqKBXaVjhkGk3ZluKEQjjC7TlpRCprp22vM(CcUdbWUoyGbk1knhDaJXsCwkIPigX0XouJMpomUI9ONnuWGDaJXsCwkIPid41XouJMpomUI9ONnK8SY9e9yBxz6Zj4oea76yYHALMJoGXyjolfXuKb86yhQrZhhgxXE0ZgkyqmIPtK4SuetHjS8SY9e9yBxz6Zj4oei0OoSwP5OdymwIZsrmfXiMo2HA08XHXvSh9SHcgKb86ejolfXuycVLl0Gt0V3Ut47e(KWNUBlH05ZhkElbGea29WTaRBbGgaqwL1RWiznBerJlRg0iR3JGKrby(9OSouaWa5qGYkg1qYQc4Og1jqzLdtFOe2kpFpLpjRNc8aaYAGn6VqJtGYAjBcSLvmeVRHRSEplRoswVNauzfmVK4e9YksKg1rJS2MaTlRTDx42UvEwEoWQrenobkR3RSQCprVSYsSJTYZBrbCyOzlLSjWElSe7496wmjJrZEDVDAVUf61oJax43IY9e9BzuiPTWN0Pj1TCrNu7mYAsgJgz9qwpjRcjRGi3okKKvSbG5PilPrwd4HSksdoXo9ESbG5PilPrwfswhYmegM2z0w4qWzu01bk5492P13B3Tx3c9ANrGl8BHpPttQB5IoP2zK1KmgnY6HSENSkKSoKzimmTZOTOCpr)wgfsA99wG2RBHETZiWf(TWN0Pj1TCrNu7mYAsgJgz9qwdKSkKSoKzimmTZOTOCpr)wAqO3Kdf5QV(El871TqV2ze4c)w4t60K6wUOtQDgznjJrJSEiRHFlk3t0VfCOuKIC1xFVj496wuUNOFlyydbUf61oJax4xF9TyYpXWOzVU3oTx3c9ANrGl8BHpPttQBziZqyyANrBr5EI(TG1lkukoiDwFVD3EDl0RDgbUWVfK4wWKVfL7j63YfDsTZOTCrza0weEl8jDAsDlUYO3TIt2OSyOrDyw61oJa3YfDIV2qBPtypoP467TaTx3c9ANrGl8Br5EI(TiozJYIHg1HTf(KonPUfSiXyrxhOKJTIt2OSyOrDyYAyYABYAGKv4K1tYQGkRUYO3TyTtJJqoml9ANrGYA7BHdbNrrxhOKJ3BNwFVf(96wOx7mcCHFlk3t0VLjf3cFsNMu3sBYAaww9Kdz(qL1GbL12K1HA08XYkCYkh10rrru(owwfuz1vg9UfRDACeYHzPx7mcuwBxwdOSccmQNOxwfuzvyBGK1GbLvqKBNu0k2aW8uKL0iRbuwfPbNyNEp2aW8uKL0iRTlRcjRdzgcdt7mAlCi4mk66aLC8E7067nbVx3c9ANrGl8BHpPttQBPdym2CqFmC0qylG4wuUNOFlnA2S(ElW3RBHETZiWf(T0OHBKEAGcXwoTfL7j63IHgepra4ypDAlCi4mk66aLC8E706RVfcJPNt7192P96wOx7mcCHFl8jDAsDlk3ZluKEQjjSSgMScs4CiWORduYXYAWGY6OjyKUqVBvqqSnFznmzn8cElk3t0VfhgAE867T72RBHETZiWf(TWN0Pj1T0bmg7qCizeghnOHtwarznyqzTdymwpHsdoAagiSaIBr5EI(T4WOiW3rapy0GgoT(Elq71TqV2ze4c)w4t60K6w6agJTtdMgiJC1TaIYAWGYAhWyS5Z15vprFeY8HgrMOdJIHdWdLrwaXTOCpr)wAOg0arezImaEcgbhsBWRV3c)EDl0RDgbUWVf(KonPULoGXy9ekn4ObyGWcikRcjRCuthffr57yz9qwf8wuUNOFlDgcbgrMOdJI0tnqS(EtW71TqV2ze4c)w4t60K6wuUNxOi9utsyznmzfKW5qGrxhOKJL1GbL12K1rtWiDHE3QGGyB(YAyY69kSSkKSspnqHWcsMKNUSg2HSkyHL123IY9e9BXG4aycmQ3NM0PyN0M13Bb(EDl0RDgbUWVf(KonPUfL75fksp1KewwdtwbjCoey01bk5yznyqzD0emsxO3Tkii2MVSgMSg4cVfL7j63IiWKgiYhASZuSV(ElWSx3c9ANrGl8BHpPttQBPdymwpHsdoAagiSaIBr5EI(TafqhWu)iYe17tdYHT(EtqSx3c9ANrGl8BHpPttQBPdymwpHsdoAagiSaIBr5EI(TWrpNEFuNaJgM2qRV3U396wOx7mcCHFl8jDAsDlDaJX6juAWrdWaHfqClk3t0VLjffzum)iwu5067TtcVx3c9ANrGl8BHpPttQBPdymwpHsdoAagiSaIBr5EI(TecnmWlu(XHWOxFoT(E70P96wOx7mcCHFl8jDAsDlUoqj36zdfDuemjznGY6jRGL1GbL12K12KvxhOKBHrkZHzf5USgMSkiewwdguwDDGsUfgPmhMvK7YAapK17ewwBxwfswDDGsU1Zgk6OiysYAyY6D3RS2USgmOS2MS66aLCRNnu0rrrUhVtyznmznqclRcjRUoqj36zdfDuemjznmzn8HxwBFlk3t0VLHuX8HgnmTHWRV(w6ktFoTx3BN2RBHETZiWf(TWN0Pj1T0bmglXzPiMIyethlik0lRcjRDaJXsCwkIPid41XcIc9YQqYABY6qMHWW0oJK1GbL12KvL75fksp1KewwdtwpjRcjRk3Zluee5wmWBYHK1akRk3ZluKEQjjSS2US2(wuUNOFlyG3KdT(E7U96wOx7mcCHFl8jDAsDlDaJXsCwkIPigX0XouJMpwwdtw5k2JE2qYAWGYAhWySeNLIykYaEDSd1O5JL1WKvUI9ONn0wuUNOFlyxhmWaLwFVfO96wOx7mcCHFl8jDAsDlDaJXsCwkIPid41XouJMpwwdtw5k2JE2qYAWGYkgX0jsCwkIjznmzv4TOCpr)wWUoMCO13BHFVUf61oJax43cFsNMu3shWySeNLIykIrmDSd1O5JL1WKvUI9ONnKSgmOSYaEDIeNLIyswdtwfElk3t0VLqJ6WwF9TasgfG57192P96wOx7mcCHFl8jDAsDlDaJXYvpAqtJfef63IY9e9BHRE0GMM13B3Tx3c9ANrGl8BHpPttQBXvg9UTRm95uunM8thcl9ANrGYQqYAhWySni0dz(rdAASaIBr5EI(TmaFu5EI(ilX(wyj2JV2qBPRm95067TaTx3IY9e9BbdjaJf7kg2wOx7mcCHF99w43RBr5EI(TioOqSTqV2ze4c)67nbVx3c9ANrGl8Br5EI(TWvglQCprFKLyFlSe7XxBOTWrigik0V(ElW3RBHETZiWf(TWN0Pj1TWrnDuueLVJL1WoK12KvblRbqz9IoP2zK1GagUySNojRTVfL7j63Ya8rL7j6JSe7BHLyp(AdTft(jggnRV3cm71TqV2ze4c)w4t60K6w6agJTtdMgiJC1TaIYAWGYAhWyS5Z15vprVfquwdguw7agJfdtbrHAigOfquwdguw7agJfdacsFuB6ayywarznyqzTdymwXbfIzbe3IY9e9Bza(OY9e9rwI9TWsShFTH2c2jL5WwFVji2RBr5EI(TOGQONxOioKonBHETZiWf(13B37EDl0RDgbUWVf(KonPUfoQPJIIO8DSSgqz9UTOCpr)w4O)ccsk6WOiwmN0XRV3oj8EDl0RDgbUWVf(KonPUfxz072odHaDLHESLETZiqzvizTdym2odHaDLHESfef6LvHK12Kv6PbkeYkCYAGScwwfuzLEAGcHDiO0lRWjRTjRHxyzvqL1oGXy5mshUI98HAbeL12L12L1WoK12K1tNeSSgaL17cKSkOYAhWyS5Z15vprFeY8HgrMOdJIHdWdLrwarzTDzvizv5EEHIDp6tcfknyz9qwfElk3t0VfreIfhcJagoT(E70P96wOx7mcCHFl8jDAsDlUYO3TDgcb6kd9yl9ANrGYQqYABYAhWySDgcb6kd9ylik0lRbdkRk3ZluS7rFsOqPblRhY6DYA7Br5EI(TmaFu5EI(ilX(wyj2JV2qBPZqiqxzOhV(E70D71TqV2ze4c)wuUNOFlJcjTf(KonPULHmdHHPDgjRbdkRI0GtStVhBayEkYsAK1WKvqKBhfsYk2aW8uKL0SfoeCgfDDGsoEVDA992PaTx3c9ANrGl8BHpPttQBHJA6OOikFhlRhYQWBr5EI(TyOrzrZq)9Hy992PWVx3c9ANrGl8Br5EI(T0GqVjhkYvFl8jDAsDldzgcdt7mAlCi4mk66aLC8E7067TtcEVUf61oJax43cFsNMu3YqMHWW0oJ2IY9e9BXHnkgwKR(67Ttb(EDl0RDgbUWVf(KonPUL2K1oGXy9ekn4ObyGWcikRcjRTjRJMGr6c9UvbbX28L1WK12K1tYkCYAJgUromDGsyznakRCy6aLWrZOCprVYK12LvbvwhIdthOu0ZgswBxwBxwfswBtwXIeJfDDGso22haxzrmtXWKvbvwvUNO32haxzrmtXWSGAJcLKvbKvL7j6T9bWvweZummlhHDzTDznmzTnzv5EIElg2qGwqTrHsYQaYQY9e9wmSHaTCe2L123IY9e9BPpaUYIyMIHT(E7uGzVUf61oJax43cFsNMu3cwKySORduYXwCOuKIC1L1WK172IY9e9BbhkfPix913BNee71TqV2ze4c)w4t60K6w6agJLZiD4k2ZhQfqClk3t0VfmSHaxFVD6E3RBHETZiWf(TWN0Pj1TqpnqHW6zdfDuSrdxznGY6jznyqznalRUYO3TDgcb6kd9yl9ANrGBr5EI(TWvglQCprFKLyFlSe7XxBOTysgJM1xFlIdXrnD13R7Tt71TqV2ze4c)wqIBbt(wuUNOFlx0j1oJ2YfLbqBr4TCrN4Rn0wmiGHlg7PtRV3UBVUf61oJax43csClyY3IY9e9B5IoP2z0wUOmaAlN2YfDIV2qBXKmgnRV3c0EDl0RDgbUWVfK4wWKVfL7j63YfDsTZOTCrza0weEl8jDAsDl69PjDYgkzGrdJWWg6bZhQLETZiWTCrN4Rn0wmjJrZ67TWVx3c9ANrGl8BbjUfm5Br5EI(TCrNu7mAlxugaTLaZwUOt81gAltkg9KdjE99MG3RBHETZiWf(TGe3cM8TOCpr)wUOtQDgTLlkdG2IGylx0j(AdTfh2Oyyrp5qIxFVf471TqV2ze4c)wqIBbt(wuUNOFlx0j1oJ2YfLbqBr4TWN0Pj1TO3NM0jBOKbgnmcdBOhmFOw61oJa3YfDIV2qBXHnkgw0toK413BbM96wuUNOFlqMp4qGrSyoPJ3c9ANrGl8RV3ee71TqV2ze4c)w4t60K6w6agJTbHEiZpAqtJfef63IY9e9BrCqHyRV3U396wOx7mcCHFl8jDAsDlDaJX2GqpK5hnOPXcIc9YQqYAhWySEcLgC0amqybrH(TOCpr)w8ekn4ObyGy992jH3RBr5EI(TWvpAqtZwOx7mcCHF913c2jL5W2R7Tt71TqV2ze4c)w4t60K6wCLrVB7mec0vg6Xw61oJaLvHK1oGXy7mec0vg6XwquOFlk3t0VLb4Jk3t0hzj23clXE81gAlDgcb6kd9413B3Tx3c9ANrGl8Br5EI(TmkK0w4t60K6warUDuijRydaZtrwsJSgqz9KnW3chcoJIUoqjhV3oT(Elq71TOCpr)wWWgcCl0RDgbUWV(6BHJqmquOFVU3oTx3c9ANrGl8BHpPttQBPdymwXbfIzbrH(TOCpr)w60GPbY13B3Tx3c9ANrGl8BHpPttQBPdymwXbfIzbrH(TOCpr)wYNRZREI(13BbAVUf61oJax43cFsNMu3c90afclizsE6YAyYQGfSSgmOS2MS2bmgBNgmnqg5QBbeLvHK1oGXy70GPbYixD7qnA(yznGY6PajRTlRbdkRTjRDaJXMpxNx9e9warzvizTdym28568QNOpcz(qJit0HrXWb4HYi7qnA(yznGY6PajRTVfL7j63INqPbhnadeRV3c)EDl0RDgbUWVf(KonPULoGXy9ekn4ObyGWcikRcjRDaJX2PbtdKrU6wquOxwfsw7agJnFUoV6j6JqMp0iYeDyumCaEOmYcIc9YQqYAhWySIdkeZcIc9YQqYkh10rrru(owwdOSgEzvizfe52rHKSInampfzjnYAaL1t2axwfswPNgOqiRHjRHx4TOCpr)wWWuquOgIbU(EtW71TqV2ze4c)w4t60K6w6agJ1tO0GJgGbclG4wuUNOFluJikenXo6bxFVf471TqV2ze4c)w4t60K6w6agJ1tO0GJgGbclGOSgmOS2bmgBNgmnqg5QBbeL1GbL1oGXyZNRZREI(iK5dnImrhgfdhGhkJSaIBr5EI(T0PbtdK5dD99wGzVUf61oJax43cFsNMu3shWySDAW0azKRUfquwdguw7agJnFUoV6j6JqMp0iYeDyumCaEOmYciUfL7j63IiYt0V(EtqSx3c9ANrGl8BHpPttQBHEAGcHfKmjpDznGYQW27eSSkOYk90afcBJgUBr5EI(Tm6f6ra4OzO)(qS(E7E3RBHETZiWf(TOCpr)w4kJfvUNOpYsSVfwI94Rn0wimMEoT(E7KW71TqV2ze4c)wETH2IIHDrFchh9(OjYrJY2IY9e9BrXWUOpHJJEF0e5OrzBHpPttQBbK6agJD07JMihnklcsDaJXcIc9YAWGYki1bmglh9GaCpVqX8HmcsDaJXcikRcjRUoqj36zdfDuuK7XajSSgqz9KvWYAWGYAawwbPoGXy5OheG75fkMpKrqQdymwarzvizTnzfK6agJD07JMihnklcsDaJXIDLdPSg2HSENGL1aOSEsyzvqLvqQdym2odHaJit0Hrr6PgiSaIYAWGYQRduYTE2qrhfbtswdOSgEHL12LvHK1oGXy9ekn4ObyGWouJMpwwdtwpj867TtN2RBHETZiWf(TWN0Pj1T0bmgRNqPbhnadewarznyqz11bk5wpBOOJIGjjRbuwVt4TOCpr)waWumDQbV(6BPZqiqxzOhVx3BN2RBHETZiWf(TOCpr)wgfsAl8jDAsDlTjRbyz1toK5dvwdguwBtwhYmegM2zKSkKSksdoXo9ESbG5PilPrwdtwbrUDuijRydaZtrwsJS2US2USkKS2bmgB3JJcjzbrH(TWHGZOORduYX7TtRV3UBVUf61oJax43IY9e9BPbHEtouKR(w4t60K6wgYmegM2zKSkKS2bmgB3Jni0BYHSGOq)w4qWzu01bk5492P13BbAVUf61oJax43IY9e9BXHnkgwKR(w4t60K6wgYmegM2zKSkKS2bmgB3JoSrXWSGOq)w4qWzu01bk5492P13BHFVUf61oJax43cFsNMu3shWySDp2haxzrmtXWSGOq)wuUNOFl9bWvweZumS13BcEVUf61oJax43cFsNMu3shWySDpIdLIKfef6LvHKvSiXyrxhOKJT4qPif5QlRHjRN2IY9e9BbhkfPix913Bb(EDl0RDgbUWVf(KonPULoGXy7EedBiqlik0VfL7j63cg2qGRV3cm71TqV2ze4c)w4t60K6w6agJT7rCOuKSGOq)wuUNOFl4qPif5QV(EtqSx3c9ANrGl8BHpPttQBPdym2UhDyJIHzbrH(TOCpr)wCyJIHf5QV(6RV(67c]] )

    
end
