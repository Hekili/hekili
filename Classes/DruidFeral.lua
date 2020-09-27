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
        },
        adaptive_swarm_hot = {
            id = 325748,
            duration = function () return mod_circle_hot( 12 ) end,
            max_stack = 1,
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
        -- Damager
        kindred_empowerment = {
            id = 327139,
            duration = 10,
            max_stack = 1,
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

    spec:RegisterStateExpr( "will_proc_bloodtalons", function ()
        if not talent.bloodtalons.enabled then return false end
        if query_time - action[ this_action ].lastCast < 4 then return false end

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
                if will_proc_bloodtalons then proc_bloodtalons() end
                removeStack( "clearcasting" )
            end,

            copy = { 213764, "swipe" },
            bind = { "swipe_cat", "swipe_bear", "swipe" }
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
                return buff.lone_spirit.down and buff.kinded_spirits.down, "lone_spirit/kindred_spirits already applied"
            end,

            handler = function ()
                -- Let's just assume.
                applyBuff( "lone_spirit" )
            end,
        },

        empower_bond = {
            id = 326647,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = false,
            texture = 3528283,

            usable = function ()
                return buff.lone_spirit.up or buff.kindred_spirits.up, "requires kindred_spirits/lone_spirit"
            end,

            toggle = "essences",

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

            copy = { "lone_empowerment", "lone_meditation", "lone_protection", 326462, 326446, 338142 }
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

    spec:RegisterPack( "Feral", 20200823, [[duKQrbqiLiEKsKCjLiL2KKyucQoLsOvbQKxbfMfO0TavKDrQFHkAykbhtsAzkr9mbftduHRjiABGkQVjiKXji4CGkvRduPW8qvv3tv1(avDqbHclev4HkrQAIccvxujsfBeuPOtQePyLGIzkiu0ovvCubHspvvMku0xvIuP9c8xsgSehMQfdYJjmzL6YiBwOplPgnu60kwnOsPxJQYSr52kPDRYVfnCbwUuphY0PCDOA7csFhvz8OQY5vvA9cknFuP9t0GQambVTBe4ZYlS8cleclhg9YvHd4yzWZ(gqGxGl4ZRjW78vc8GBsTZaVa)ll9natWdL4TGapSMfGGBWjN1JHfhslYvorZkoZTjpr7rJt0Sk4e8GWhMT0CaiWB7gb(S8clVWcHWYHrVCv4aoQc3bpuajaFQUqyapSZEthac82esaElLSa3KANjlH4n(SLf4KSeIfFe8jl(TLLq8PTVsyKWSuYYspw)QjeCdjmlLSaNKfwYKf3KfoCMFcscZsjlWjzHdwMBZz5HKLlnzzwdy0kDgT1GxqNXHrG3sjlWnP2zYsiEJpBzbojlHyXhbFYIFBzjeFA7RegjmlLSS0J1VAcb3qcZsjlWjzHLmzXnzHdN5NGKWSuYcCsw4GL52CwEiz5stwM1agTsNrBTegjmlLSS0HFKa3OTSarXSjzrKRqUjlqu9CiTSeIHqqbgswU8Gty9EnIZKfxytEizjp2xTeMLswCHn5H0bnjYvi3(JmhXNeMLswCHn5H0bnjYvi3W4NZyMBjmlLS4cBYdPdAsKRqUHXpNoE9kDMBtEsywkzzPXKLbjl8Y2WklJjlXSLfNTMitwOqP(BEKSyPSS6Zz(CYIHTDewjmUWM8q6GMe5kKB)8n3UPTcfm9yijmsyCHn5H0bnjYvi3W4NZq9ECigb75R0poIug22ryHnuNHt)liHXf2Khsh0KixHCdJFod17XHyeSNVs)4iszyBhHf2qDgo9VmSt83dl1JrAEdBRImcHTPBpxTMohIrBjmUWM8q6GMe5kKBy8ZzOEpoeJG98v6VNaLnc(qWgQZWP)qqcJlSjpKoOjrUc5gg)CIJi1y0kSNVs)Eyry92rQyEMkJQGKh1syCHn5H0bnjYvi3W4NZGo5XGDI)q4XOEnZJV5uXSx17K3jHzPKL35biSPjlTpBzbcpgPTSGm3qYcefZMKfrUc5MSar1ZHKf)2YsqtWPG0S5QLLbjl78iTeMLswCHn5H0bnjYvi3W4Nt05biSPPqMBijmUWM8q6GMe5kKBy8ZzqAtEsyCHn5H0bnjYvi3W4NtiQruZhSt8hcpg1RzE8nNkM9QEN8ojmUWM8q6GMe5kKBy8ZPn1uJur8(lSt8hcpg1RzE8nNkM9QEN8Ukq4XO2MAQrQiE)vVtENegxytEiDqtICfYnm(5u4MkM9kSt8hcpg1RzE8nNkM9QEN8ojmsywkzzPd)ibUrBzHcL6VYInRKSyyjzXfw2YYGKfpuFyoeJ0syCHn5H(r8HZykihHf2j(Vei8yuh0jpMgpOYsGWJrncRVtEReBRXdKW4cBYdHXpNn(PCHn5PydYG98v6hYz(jiyN4V5m6mnKZ8tqkpgNBSVA6CigTRaHhJ61mp(MtfZEvJhiHXf2KhcJFofUPIzVc7e)xceEmQfUPIzVQXdKW4cBYdHXpNTZhb7e)HWJrDqN8yA8aUCHWJrncRVtEReBRXdKW4cBYdHXpNcNXuUWM8uSbzWE(k9lYKTtEhscJlSjpeg)CgPoftIJuqJrWk(kyKY8UMm0FvyN4)onDpbABe8nxDLDA6Ec0nT6ZH4FyQyExtM2MvszPApe8vxOs4MZOZ0ihIAltdRMohIr7fLW4cBYdHXpNrQtXK4if0yeSIVcgPmVRjd9xf2j(BoJotJCiQTmnSA6CigTRiYvOufKZzi4rbeJPmVRjdPnSTJWQeUvzNMUNaTnc(MRUYonDpb6Mw95q8pmvmVRjtBZkPSuThc(DA6Ec0nT6ZHWiuVhhIr6Ecu2i4dbxUWM809eOTrWNYMvscJlSjpeg)C24NYf2KNInid2ZxP)4Cdcl1iyN4VixHsvqoNHGhoKW4cBYdHXpN(2dSjusH459QegxytEim(5uKxOjFKYWskuW0JHGDI)ICfkvb5CgI)llHXf2KhcJFofoJPCHn5PydYG98v6VMoQDlBKYtc2j(JcigtzExtgsByBhHvjCd(QsyCHn5HW4NZg)uUWM8uSbzWE(k9xth1ULnscJegxytEiTit2o5DOFiQruZhSt8NoQR)c)FywOs4Imz7K3PTPMAKkI3F1nT6ZHGpKC5cHhJABQPgPI49xnEWIsyCHn5H0Imz7K3HW4NtBQPgPI49xyN4pDux)vVP4igd(F48cC5cHhJABQPgPI49x9o5DsyCHn5H0Imz7K3HW4NtAni5rTckVnSt8hcpg12utnsfX7VA8ajmUWM8qArMSDY7qy8Zje1iQ5BUAjmUWM8qArMSDY7qy8Zz7HsxIJuXMUW(f2j(th11F1BkoIX4)c6LdjCrh11F1Ro)KW4cBYdPfzY2jVdHXpNg2SpeSt83f2ekPOJwhcb)MqttBL5DnziUCBF2kku6mTV3i9CWdhHucJlSjpKwKjBN8oeg)CAyjf(bL43wfZwqWoXFi8yu3KGpgHqQy2csJhWLleEmQTPMAKkI3F14bsyCHn5H0Imz7K3HW4NZvAn7VQmQy4IzR2n5RiyN4peEmQTPMAKkI3F14bvGWJrne1iQ5tVtENegxytEiTit2o5Dim(5eIL5wLrLHLu0rRFHDI)q4XO2MAQrQiE)vJhiHXf2KhslYKTtEhcJFoJu7mvSPlSFHDI)ICfkvb5Cg6FbjmUWM8qArMSDY7qy8Zzmf4iAR8Ws9yKcI8vyN4VlSjusrhToec(nHMM2kZ7AYqC5gE7ZwrHsNP99gPNdE4(cvOJ66V6nfhXyW)hYfwucJlSjpKwKjBN8oeg)CgG3t87C1kiMJmyN4VlSjusrhToec(nHMM2kZ7AYqC52(SvuO0zAFVr65GhoVGegxytEiTit2o5Dim(5Sg3794NkJkpSuNgwyN4peEmQTPMAKkI3F14bsyCHn5H0Imz7K3HW4NtrEc6S2nARImFLGDI)q4XO2MAQrQiE)vJhiHXf2KhslYKTtEhcJFo7jiGrQ5uOaxqWoXFi8yuBtn1iveV)QXdKW4cBYdPfzY2jVdHXpN8YMTdLMt1ekp)eeSt8hcpg12utnsfX7VA8ajmUWM8qArMSDY7qy8ZztEWC1QiZxjeSt838UMmTnRKYs1Ei(xvhsUCdpCZ7AY0yjNzy1bcd(qybUCnVRjtJLCMHvhim()V8clwX8UMmTnRKYs1Ei4xgUVixUHBExtM2MvszPkqyQLxa(WSqfZ7AY02Ssklv7HGhoGJfLW4cBYdPfzY2jVdHXpNZj8(CBYd2j(th11FH)pmlujCrMSDY702utnsfX7V6Mw95qWxnKC5cHhJABQPgPI49xnEWIsyCHn5H0Imz7K3HW4NZG0M8GDI)M31KPTzLuwQ2dXF4Ci5YnCBwjLLQ9q8VAiSqLWHWJrne1iQ5tJhWLleEmQNt4952KNgpyXfLW4cBYdPfzY2jVdHXpNiS(o5TsSnSt8xKRqPkiNZq8pKvOJ66VW)7cBYt3oFKwKiRYonD78r6GvCMnbSHA(VSUAfi8yuBtn1iveV)QXdQeoeEmQHyzUnNLhsJhWL7smNrNPHyzUnNLhstNdXO9IvcFjMZOZ0Zj8(CBYttNdXOnxUImz7K3PNt4952KNUPvFoe8vdHfRSei8yupNW7ZTjpnEGegxytEiTit2o5Dim(5ehrQXOvypFL(De2q9JqQ2dB2kr2od2j(Vji8yu3EyZwjY2zQnbHhJ6DY74YDtq4XOwK3gxytOKAo(uBccpg14bvmVRjtBZkPSufimvywG)v1HKl3LSji8yulYBJlSjusnhFQnbHhJA8GkHVji8yu3EyZwjY2zQnbHhJAK5c(G)F5qcNQUaCTji8yudXYCRYOYWsk6O1VA8aUCTzLuwQ2dXF4yHfRaHhJABQPgPI49xDtR(Ci4RUGegxytEiTit2o5Dim(5ehrQXOvyPyKeM68v6x8vWsRZBekiMJmyN4F40rD9x9MIJym4)PJ66V6MQPdUcZIvGWJrTn1uJur8(REN8UklXdl1JrA4w8RMrQiE)vtNdXOTegxytEiTit2o5Dim(5ehrQXOvyPyKeM68v6x8vWsRZBekiMJmyN4peEmQTPMAKkI3F14bv8Ws9yKgUf)QzKkI3F105qmAlHXf2KhslYKTtEhcJFoXrKAmAfwkgjHPoFL(9WIW6TJuX8mvgvbjpQHDI)0rD9x9MIJym4)d5csyCHn5H0Imz7K3HW4NtCePgJwrWoXFi8yuBtn1iveV)QXd4Y1MvszPApe)xEbjmsyCHn5H0X5gewQr)bzYunHs8wqWgZwDe)S)QsyCHn5H0X5gewQry8ZjYd1RjvNEd7e)HWJrnYd1RjvNER3jVtcJlSjpKoo3GWsncJFodYKPAcL4TGGnMT6i(z)vLW4cBYdPJZniSuJW4NZGEwDMIx7gwyfFfmszExtg6VkSt8hfqmMY8UMmKoONvNP41UHf(Qv2PP7jq30QphI)WHegxytEiDCUbHLAeg)CgKjt1ekXBbbBmB1r8Z(RkHXf2KhshNBqyPgHXpNb9S6mfV2nSWk(kyKY8UMm0FvyN4pkGymL5DnziDqpRotXRDdl8)llHXf2KhshNBqyPgHXpNbzYunHs8wqWgZwDe)S)QsyCHn5H0X5gewQry8ZzpbWk(kyKY8UMm0FvyN4)smNrNProe1wMgwnDoeJ2vAk2ecRdXOkM31KPTzLuwQ2db)onDpb6Mw95qyeQ3JdXiDpbkBe8HGlxytE6Ec02i4tzZkjHXf2KhshNBqyPgHXpNbzYunHs8wqWgZwDe)S)QsyCHn5H0X5gewQry8ZzpbWk(kyKY8UMm0FvyN4V5m6mnYHO2Y0WQPZHy0Us4lXgbFZvZLBtR(Ci()VXB3M8GRf0HPsa1Obz0zQvCMnbSHA43PP7jqhSIZSjGnuVyfZ7AY02Ssklv7HGFNMUNaDtR(Cimc17XHyKUNaLnc(qWv4vXyNMUNaTnc(MRgUcZIWLlSjpDpbABe8PSzLKW4cBYdPJZniSuJW4NZGmzQMqjEliyJzRoIF2FvjmUWM8q64Cdcl1im(5e5H61KQtVHDI)q4XOg5H61KQtV1nT6ZH4F1LLW4cBYdPJZniSuJW4NZGmzQMqjEliyJzRoIF2FvjmUWM8q64Cdcl1im(5C1NvyN4peEmQNopfCRZdPXdKW4cBYdPJZniSuJW4NZi1PysCKcAmc2vNFk6OU(7FvyfFfmszExtg6VQegjmUWM8q6A6O2TSry8ZjuJBotHyoclSt8hfqmMY8UMmKgQXnNPqmhHf(nHMM2kZ7AYqvcFjEyPEmsZByBvKriSnD75Q105qmAZL7onTHTDewLWnTnc(MRErUCHWJrnelZT5S8q6DY7QWBymvqNcfelZT5S8qsyCHn5H010rTBzJW4NZGmzQMqjEliyJzRoIF2FvjmUWM8q6A6O2TSry8ZPHTDewLWnyN4F4nfBcH1HyufuaXykZ7AYqAdB7iSkHBWV8IC5cHhJAiwMBZz5H07K3vH3WyQGofkiwMBZz5HKW4cBYdPRPJA3YgHXpNbzYunHs8wqWgZwDe)S)QsyCHn5H010rTBzJW4NtdB7iSkHBWoX)WnNrNPrc6mvgvqSm3A6CigTRaHhJAKGotLrfelZTEN8UfRGcigtzExtgsByBhHvjCd(WiHXf2Khsxth1ULncJFodYKPAcL4TGGnMT6i(z)vLW4cBYdPRPJA3YgHXpNiEtaPeUb7e)HWJrnsqNPYOcIL5wJhWLB4UWM80iEtaPeUP3(QxtWfkGymL5DnzinI3eqkHBWhUlSjpD78r6TV61egH7cBYt3oFKcIr0wBJGp12x9AcUc5IlUixUq4XOgIL52CwEi9o5Dv4nmMkOtHcIL52CwEijmUWM8q6A6O2TSry8ZzqMmvtOeVfeSXSvhXp7VQegxytEiDnDu7w2im(5SD(iyfFfmszExtg6VkSt8Fj2i4BUAUCdFjMZOZ0qSm3MZYdPPZHy0UstR(Ci(VXB3M8GRf0HzXkM31KPTzLuwQ2dbpCWLleEmQHyzUnNLhsVtExfEdJPc6uOGyzUnNLhscJlSjpKUMoQDlBeg)CgKjt1ekXBbbBmB1r8Z(RkHXf2Khsxth1ULncJFoBNpcwXxbJuM31KH(Rc7e)dp8Mw95q8)peTyLaQrdYOZuR4mBcyd1WVtt3oFKoyfNztaBOgUwqhcHCXkM31KPTzLuwQ2dbpCiHzPKLLUJHvwcXCPrwQilCGjSYcpswe(jl4iswwZ8IttYILYcYdLKfoWuwey9UMqWkloJL8MRwwWrYILYcezg1YstXMqyLL25JKW4cBYdPRPJA3YgHXpNRzEXPjLWnyN4peEmQdAA7w2FviEt0ocH07K3vrKRqPkiNZq8pKC5cHhJAiwMBZz5H07K3vH3WyQGofkiwMBZz5HKW4cBYdPRPJA3YgHXpNRzEXPjLWnyfFfmszExtg6VkSt8VPytiSoeJKW4cBYdPRPJA3YgHXpNqnU5mfI5iSWoX)WxIhwQhJ08g2wfzecBt3EUAnDoeJ2C5UttByBhHvjCtBJGV5QxSceEmQTPMAKkI3F14bvcV9zROqPZ0(EJ0ZbF4vXy15NsG17AcbNey9UMqQy7cBYZzlcxnjW6DnPSzLwKlxi8yudXYCBolpKEN8Uk8ggtf0PqbXYCBolpKegxytEiDnDu7w2im(5mitMQjuI3cc2y2QJ4N9xvcJlSjpKUMoQDlBeg)CAyBhHvjCd2j(3uSjewhIrvcp8q9ECigPXrKYW2oc7)YvcFjq4XOEoH3NBtEA8aUC9Ws9yKM3W2QiJqyB62ZvRPZHy0EXf5YffqmMY8UMmK2W2ocRs4g8vxKlxi8yudXYCBolpKEN8Uk8ggtf0PqbXYCBolpKeMLswCHn5H010rTBzJW4NtdB7iSkHBWoX)MInHW6qmQsOEpoeJ04iszyBhH9VAfi8yulyK3chzZvRBYfwLWxceEmQNt4952KNgpGlxpSupgP5nSTkYie2MU9C1A6CigTxKlxi8yudXYCBolpKEN8Uk8ggtf0PqbXYCBolpKegxytEiDnDu7w2im(5mitMQjuI3cc2y2QJ4N9xvcJlSjpKUMoQDlBeg)CI4nbKs4gSt8hfqmMY8UMmKgXBciLWn4RYLleEmQHyzUnNLhsVtExfEdJPc6uOGyzUnNLhscJlSjpKUMoQDlBeg)CIW20g2j(Vtt3oFKUPvFoe8H7cBYtJW20wlsKHHlSjpD78rArIm4eDux)DXLw6OU(RUPA64Yfcpg1cg5TWr2C16MCHXLleEmQHyzUnNLhsVtExfEdJPc6uOGyzUnNLhscJegxytEiDnDu7w2iLN0FqMmvtOeVfeSXSvhXp7VQegxytEiDnDu7w2iLNeg)C2oFeSt8VPytiSoeJQaHhJAiwMBZz5H07K3vH3WyQGofkiwMBZz5HKW4cBYdPRPJA3YgP8KW4NZGmzQMqjEliyJzRoIF2FvjmUWM8q6A6O2TSrkpjm(50W2ocRs4gSt8p8MInHW6qmIlxxytOKANM2W2ocRs4g)DHnHsk6O1HqlTlVyfuaXykZ7AYqAdB7iSkHBWVmxUMZOZ0ibDMkJkiwMBnDoeJ2vGWJrnsqNPYOcIL5wVtExfuaXykZ7AYqAdB7iSkHBWhgUCxInc(MRUIhwQhJ08g2wfzecBt3EUAnDoeJ2C5cHhJAiwMBZz5H07K3vH3WyQGofkiwMBZz5HKW4cBYdPRPJA3YgP8KW4NZGmzQMqjEliyJzRoIF2FvjmUWM8q6A6O2TSrkpjm(5eQXnNPqmhHf2j(JcigtzExtgsd14MZuiMJWc)MqttBL5DnziUCHWJrnelZT5S8q6DY7QWBymvqNcfelZT5S8qsyCHn5H010rTBzJuEsy8ZzqMmvtOeVfeSXSvhXp7VQegxytEiDnDu7w2iLNeg)CI4nbKs4gSt8hcpg1ibDMkJkiwMBnEaxUq4XOgIL52CwEi9o5Dv4nmMkOtHcIL52CwEijmsyCHn5H0qoZpb9JWV40eSt8hcpg1KGnbisHsM36DY7QaHhJAsWMaePy4N36DY7QeEtXMqyDigXLB4UWMqjfD06qi4RwXf2ekP2PPr4xCAI)UWMqjfD06qOfxucJlSjpKgYz(jim(5ezEJW7Ac2j(dHhJAsWMaePqjZBDtR(Ci4foYu2SsC5cHhJAsWMaePy4N36Mw95qWlCKPSzLKW4cBYdPHCMFccJForM3XPjyN4peEmQjbBcqKIHFERBA1NdbVWrMYMvIlxuY8wrc2eGi4xqcJlSjpKgYz(jim(5Kx7gwyN4peEmQjbBcqKcLmV1nT6ZHGx4itzZkXLld)8wrc2eGi4xa8cLA0Kh4ZYlS8cleclS8YGhpVV5QrG3sZAq2gTLLqKS4cBYtwydYqAjmGhBqgcGj4vth1ULns5jbWe8PkatWJohIrBahGxmB1r8ZaFQcEUWM8aVGmzQMqjEliGb(SmatWJohIrBahGNOhJ6XbVMInHW6qmswQilq4XOgIL52CwEi9o5DYsfzH3WyQGofkiwMBZz5HapxytEGx78rad8jmambp6CigTbCaEXSvhXpd8Pk45cBYd8cYKPAcL4TGag4dCaWe8OZHy0gWb4j6XOECWlCzPPytiSoeJKfUCLfxytOKANM2W2ocRs4MSWFzXf2ekPOJwhcjllTYYYYYIYsfzbfqmMY8UMmK2W2ocRs4MSaVSSSSWLRSyoJotJe0zQmQGyzU105qmAllvKfi8yuJe0zQmQGyzU17K3jlvKfuaXykZ7AYqAdB7iSkHBYc8YsyKfUCLLLil2i4BUAzPIS4HL6XinVHTvrgHW20TNRwtNdXOTSWLRSaHhJAiwMBZz5H07K3jlvKfEdJPc6uOGyzUnNLhc8CHn5bEg22ryvc3ag4tibycE05qmAd4a8IzRoIFg4tvWZf2Kh4fKjt1ekXBbbmWh4matWJohIrBahGNOhJ6XbpuaXykZ7AYqAOg3CMcXCewzbEzztOPPTY8UMmKSWLRSaHhJAiwMBZz5H07K3jlvKfEdJPc6uOGyzUnNLhc8CHn5bEqnU5mfI5iSad8jebWe8OZHy0gWb4fZwDe)mWNQGNlSjpWlitMQjuI3ccyGpHaatWJohIrBahGNOhJ6Xbpi8yuJe0zQmQGyzU14bYcxUYceEmQHyzUnNLhsVtENSurw4nmMkOtHcIL52CwEiWZf2Kh4H4nbKs4gWag4TPOJZmaMGpvbycE05qmAd4a8e9yupo4Tezbcpg1bDYJPXdKLkYYsKfi8yuJW67K3kX2A8aWZf2Kh4H4dNXuqoclWaFwgGj4rNdXOnGdWt0Jr94GN5m6mnKZ8tqkpgNBSVA6CigTLLkYceEmQxZ84Bovm7vnEa45cBYd8A8t5cBYtXgKbESbzQZxjWdYz(jiGb(egaMGhDoeJ2aoaprpg1JdElrwGWJrTWnvm7vnEa45cBYd8eUPIzVcmWh4aGj4rNdXOnGdWt0Jr94GheEmQd6KhtJhilC5klq4XOgH13jVvIT14bGNlSjpWRD(iGb(esaMGhDoeJ2aoapxytEGNWzmLlSjpfBqg4XgKPoFLaprMSDY7qad8bodWe8OZHy0gWb45cBYd8IuNIjXrkOXiWt0Jr94G3onDpbABe8nxTSurw2PP7jq30Qphsw4VSegzPISyExtM2MvszPApKSaVSuDbzPISeUSyoJotJCiQTmnSA6CigTLLfbpXxbJuM31KHaFQcmWNqeatWJohIrBahGNlSjpWlsDkMehPGgJaprpg1JdEMZOZ0ihIAltdRMohIrBzPISiYvOufKZzizbEzbfqmMY8UMmK2W2ocRs4MSurw2PP7jqBJGV5QLLkYYonDpb6Mw95qYc)LLWilvKfZ7AY02Ssklv7HKf4LLDA6Ec0nT6ZHKfmKLq9ECigP7jqzJGpKSaxYIlSjpDpbABe8PSzLapXxbJuM31KHaFQcmWNqaGj4rNdXOnGdWt0Jr94GNixHsvqoNHKf4Lf4a8CHn5bEn(PCHn5PydYap2Gm15Re4fNBqyPgbmWh4oatWZf2Kh45BpWMqjfIN3RGhDoeJ2aoag4t1faycE05qmAd4a8e9yupo4jYvOufKZzizH)YYYGNlSjpWtKxOjFKYWskuW0JHag4t1Qambp6CigTbCaEIEmQhh8qbeJPmVRjdPnSTJWQeUjlWllvbpxytEGNWzmLlSjpfBqg4XgKPoFLaVA6O2TSrkpjGb(uDzaMGhDoeJ2aoapxytEGxJFkxytEk2GmWJnitD(kbE10rTBzJagWaVGMe5kKBambFQcWe8CHn5bE8n3UPTcfm9yiWJohIrBahad8zzaMGhDoeJ2aoaVma8qKbEUWM8aVq9ECigbEH6mCc8wa8c1B15Re4HJiLHTDewGb(egaMGhDoeJ2aoaVma8qKbEUWM8aVq9ECigbEH6mCc8wg8e9yupo45HL6XinVHTvrgHW20TNRwtNdXOn4fQ3QZxjWdhrkdB7iSad8boaycE05qmAd4a8YaWdrg45cBYd8c17XHye4fQZWjWleaVq9wD(kbE9eOSrWhcyGpHeGj4rNdXOnGdW78vc88WIW6TJuX8mvgvbjpQbpxytEGNhwewVDKkMNPYOki5rnWaFGZambp6CigTbCaEIEmQhh8GWJr9AMhFZPIzVQ3jVd8CHn5bEbDYJbmWNqeatWZf2Kh4fK2Kh4rNdXOnGdGb(ecambp6CigTbCaEIEmQhh8GWJr9AMhFZPIzVQ3jVd8CHn5bEquJOMpGb(a3bycE05qmAd4a8e9yupo4bHhJ61mp(MtfZEvVtENSurwGWJrTn1uJur8(REN8oWZf2Kh4ztn1iveV)cmWNQlaWe8OZHy0gWb4j6XOECWdcpg1RzE8nNkM9QEN8oWZf2Kh4jCtfZEfyad8QPJA3YgbWe8PkatWJohIrBahGNOhJ6XbpuaXykZ7AYqAOg3CMcXCewzbEzztOPPTY8UMmKSurwcxwwIS4HL6XinVHTvrgHW20TNRwtNdXOTSWLRSSttByBhHvjCtBJGV5QLLfLfUCLfi8yudXYCBolpKEN8ozPISWBymvqNcfelZT5S8qGNlSjpWdQXnNPqmhHfyGpldWe8OZHy0gWb4fZwDe)mWNQGNlSjpWlitMQjuI3ccyGpHbGj4rNdXOnGdWt0Jr94Gx4YstXMqyDigjlvKfuaXykZ7AYqAdB7iSkHBYc8YYYYYIYcxUYceEmQHyzUnNLhsVtENSurw4nmMkOtHcIL52CwEiWZf2Kh4zyBhHvjCdyGpWbatWJohIrBahGxmB1r8ZaFQcEUWM8aVGmzQMqjEliGb(esaMGhDoeJ2aoaprpg1JdEHllMZOZ0ibDMkJkiwMBnDoeJ2Ysfzbcpg1ibDMkJkiwMB9o5DYYIYsfzbfqmMY8UMmK2W2ocRs4MSaVSegWZf2Kh4zyBhHvjCdyGpWzaMGhDoeJ2aoaVy2QJ4Nb(uf8CHn5bEbzYunHs8wqad8jebWe8OZHy0gWb4j6XOECWdcpg1ibDMkJkiwMBnEGSWLRSeUS4cBYtJ4nbKs4ME7REnjlWLSGcigtzExtgsJ4nbKs4MSaVSeUS4cBYt3oFKE7REnjlyilHllUWM80TZhPGyeT12i4tT9vVMKf4swcPSSOSSOSSOSWLRSaHhJAiwMBZz5H07K3jlvKfEdJPc6uOGyzUnNLhc8CHn5bEiEtaPeUbmWNqaGj4rNdXOnGdWlMT6i(zGpvbpxytEGxqMmvtOeVfeWaFG7ambp6CigTbCaEUWM8aV25Japrpg1JdElrwSrW3C1YcxUYs4YYsKfZz0zAiwMBZz5H005qmAllvKLMw95qYc)LLnE72KNSaxYYc6WillklvKfZ7AY02Ssklv7HKf4Lf4qw4YvwGWJrnelZT5S8q6DY7KLkYcVHXubDkuqSm3MZYdbEIVcgPmVRjdb(ufyGpvxaGj4rNdXOnGdWlMT6i(zGpvbpxytEGxqMmvtOeVfeWaFQwfGj4rNdXOnGdWZf2Kh41oFe4j6XOECWlCzjCzPPvFoKSW)FzjejllklvKLaQrdYOZuR4mBcyd1Yc8YYonD78r6GvCMnbSHAzbUKLf0HqiLLfLLkYI5DnzABwjLLQ9qYc8YcCaEIVcgPmVRjdb(ufyGpvxgGj4rNdXOnGdWt0Jr94GheEmQdAA7w2FviEt0ocH07K3jlvKfrUcLQGCodjl8xwcPSWLRSaHhJAiwMBZz5H07K3jlvKfEdJPc6uOGyzUnNLhc8CHn5bERzEXPjLWnGb(unmambp6CigTbCaEUWM8aV1mV40Ks4g4j6XOECWRPytiSoeJapXxbJuM31KHaFQcmWNQWbatWJohIrBahGNOhJ6XbVWLLLilEyPEmsZByBvKriSnD75Q105qmAllC5kl700g22ryvc302i4BUAzzrzPISaHhJABQPgPI49xnEGSurwcxwAF2kku6mTV3i9CYc8Ys4Ysvzbdzz15NsG17AcjlWjzrG17AcPITlSjpNjllklWLS0KaR31KYMvswwuw4YvwGWJrnelZT5S8q6DY7KLkYcVHXubDkuqSm3MZYdbEUWM8apOg3CMcXCewGb(unKambp6CigTbCaEXSvhXpd8Pk45cBYd8cYKPAcL4TGag4tv4matWJohIrBahGNOhJ6XbVMInHW6qmswQilHllHllH694qmsJJiLHTDewz5xwwwwQilHlllrwGWJr9CcVp3M804bYcxUYIhwQhJ08g2wfzecBt3EUAnDoeJ2YYIYYIYcxUYckGymL5DnziTHTDewLWnzbEzPQSSOSWLRSaHhJAiwMBZz5H07K3jlvKfEdJPc6uOGyzUnNLhc8CHn5bEg22ryvc3ag4t1qeatWJohIrBahGxmB1r8ZaFQcEUWM8aVGmzQMqjEliGb(uneaycE05qmAd4a8e9yupo4HcigtzExtgsJ4nbKs4MSaVSuvw4YvwGWJrnelZT5S8q6DY7KLkYcVHXubDkuqSm3MZYdbEUWM8apeVjGuc3ag4tv4oatWJohIrBahGNOhJ6XbVDA625J0nT6ZHKf4LLWLfxytEAe2M2ArImzbdzXf2KNUD(iTirMSaNKf6OU(RSSOSS0kl0rD9xDt10jlC5klq4XOwWiVfoYMRw3KlmzHlxzbcpg1qSm3MZYdP3jVtwQil8ggtf0PqbXYCBolpe45cBYd8qyBAdmGbEX5gewQrambFQcWe8OZHy0gWb4fZwDe)mWNQGNlSjpWlitMQjuI3ccyGpldWe8OZHy0gWb4j6XOECWdcpg1ipuVMuD6TEN8oWZf2Kh4H8q9As1P3ad8jmambp6CigTbCaEXSvhXpd8Pk45cBYd8cYKPAcL4TGag4dCaWe8OZHy0gWb45cBYd8c6z1zkETBybprpg1JdEOaIXuM31KH0b9S6mfV2nSYc8YsvzPISStt3tGUPvFoKSWFzboapXxbJuM31KHaFQcmWNqcWe8OZHy0gWb4fZwDe)mWNQGNlSjpWlitMQjuI3ccyGpWzaMGhDoeJ2aoapxytEGxqpRotXRDdl4j6XOECWdfqmMY8UMmKoONvNP41UHvwG)xwwg8eFfmszExtgc8PkWaFcrambp6CigTbCaEXSvhXpd8Pk45cBYd8cYKPAcL4TGag4tiaWe8OZHy0gWb45cBYd86ja8e9yupo4TezXCgDMg5quBzAy105qmAllvKLMInHW6qmswQilM31KPTzLuwQ2djlWll7009eOBA1NdjlyilH694qms3tGYgbFizbUKfxytE6Ec02i4tzZkbEIVcgPmVRjdb(ufyGpWDaMGhDoeJ2aoaVy2QJ4Nb(uf8CHn5bEbzYunHs8wqad8P6cambp6CigTbCaEUWM8aVEcaprpg1JdEMZOZ0ihIAltdRMohIrBzPISeUSSezXgbFZvllC5klnT6ZHKf()llB82TjpzbUKLf0HrwQilbuJgKrNPwXz2eWgQLf4LLDA6Ec0bR4mBcyd1YYIYsfzX8UMmTnRKYs1EizbEzzNMUNaDtR(CizbdzjuVhhIr6Ecu2i4djlWLSeUSuvwWqw2PP7jqBJGV5QLf4swcJSSOSaxYIlSjpDpbABe8PSzLapXxbJuM31KHaFQcmWNQvbycE05qmAd4a8IzRoIFg4tvWZf2Kh4fKjt1ekXBbbmWNQldWe8OZHy0gWb4j6XOECWdcpg1ipuVMuD6TUPvFoKSWFzP6YGNlSjpWd5H61KQtVbg4t1WaWe8OZHy0gWb4fZwDe)mWNQGNlSjpWlitMQjuI3ccyGpvHdaMGhDoeJ2aoaprpg1JdEq4XOE68uWTopKgpa8CHn5bER(ScmWNQHeGj4rNdXOnGdWB15NIoQR)cEvbpxytEGxK6umjosbngbEIVcgPmVRjdb(ufyad8GCMFccGj4tvaMGhDoeJ2aoaprpg1JdEq4XOMeSjarkuY8wVtENSurwGWJrnjytaIum8ZB9o5DYsfzjCzPPytiSoeJKfUCLLWLfxytOKIoADiKSaVSuvwQilUWMqj1onnc)IttYc)LfxytOKIoADiKSSOSSi45cBYd8q4xCAcyGpldWe8OZHy0gWb4j6XOECWdcpg1KGnbisHsM36Mw95qYc8YIWrMYMvsw4YvwGWJrnjytaIum8ZBDtR(CizbEzr4itzZkbEUWM8apK5ncVRjGb(egaMGhDoeJ2aoaprpg1JdEq4XOMeSjarkg(5TUPvFoKSaVSiCKPSzLKfUCLfuY8wrc2eGizbEzzbWZf2Kh4HmVJttad8boaycE05qmAd4a8e9yupo4bHhJAsWMaePqjZBDtR(CizbEzr4itzZkjlC5klm8ZBfjytaIKf4LLfapxytEGhV2nSadyGNit2o5DiaMGpvbycE05qmAd4a8e9yupo4rh11FLf4)LLWSGSurwcxwezY2jVtBtn1iveV)QBA1NdjlWllHuw4YvwGWJrTn1uJur8(Rgpqwwe8CHn5bEquJOMpGb(SmatWJohIrBahGNOhJ6Xbp6OU(REtXrmMSa)VSaNxqw4YvwGWJrTn1uJur8(REN8oWZf2Kh4ztn1iveV)cmWNWaWe8OZHy0gWb4j6XOECWdcpg12utnsfX7VA8aWZf2Kh4rRbjpQvq5Tbg4dCaWe8CHn5bEquJOMV5Qbp6CigTbCamWNqcWe8OZHy0gWb4j6XOECWJoQR)Q3uCeJjl8xwwqVCiLf4swOJ66V6vNFGNlSjpWR9qPlXrQytxy)cmWh4matWJohIrBahGNOhJ6XbpxytOKIoADiKSaVSSj000wzExtgsw4YvwAF2kku6mTV3i9CYc8YcCesWZf2Kh4zyZ(qad8jebWe8OZHy0gWb4j6XOECWdcpg1nj4JriKkMTG04bYcxUYceEmQTPMAKkI3F14bGNlSjpWZWsk8dkXVTkMTGag4tiaWe8OZHy0gWb4j6XOECWdcpg12utnsfX7VA8azPISaHhJAiQruZNEN8oWZf2Kh4TsRz)vLrfdxmB1UjFfbmWh4oatWJohIrBahGNOhJ6Xbpi8yuBtn1iveV)QXdapxytEGhelZTkJkdlPOJw)cmWNQlaWe8OZHy0gWb4j6XOECWtKRqPkiNZqYYVSSa45cBYd8Iu7mvSPlSFbg4t1Qambp6CigTbCaEIEmQhh8CHnHsk6O1HqYc8YYMqttBL5DnzizHlxzjCzP9zROqPZ0(EJ0ZjlWllW9fKLkYcDux)vVP4igtwG)xwc5cYYIGNlSjpWlMcCeTvEyPEmsbr(kWaFQUmatWJohIrBahGNOhJ6XbpxytOKIoADiKSaVSSj000wzExtgsw4YvwAF2kku6mTV3i9CYc8YcCEbWZf2Kh4fG3t87C1kiMJmGb(unmambp6CigTbCaEIEmQhh8GWJrTn1uJur8(Rgpa8CHn5bE14EVh)uzu5HL60WcmWNQWbatWJohIrBahGNOhJ6Xbpi8yuBtn1iveV)QXdapxytEGNipbDw7gTvrMVsad8PAibycE05qmAd4a8e9yupo4bHhJABQPgPI49xnEa45cBYd86jiGrQ5uOaxqad8PkCgGj4rNdXOnGdWt0Jr94GheEmQTPMAKkI3F14bGNlSjpWJx2SDO0CQMq55NGag4t1qeatWJohIrBahGNOhJ6XbpZ7AY02Ssklv7HKf(llv1Huw4YvwcxwcxwmVRjtJLCMHvhimzbEzjewqw4YvwmVRjtJLCMHvhimzH))YYYlillklvKfZ7AY02Ssklv7HKf4LLLH7YYIYcxUYs4YI5DnzABwjLLQaHPwEbzbEzjmlilvKfZ7AY02Ssklv7HKf4Lf4aoKLfbpxytEGxtEWC1QiZxjeWaFQgcambp6CigTbCaEIEmQhh8OJ66VYc8)YsywqwQilHllImz7K3PTPMAKkI3F1nT6ZHKf4LLQHuw4YvwGWJrTn1uJur8(Rgpqwwe8CHn5bEZj8(CBYdyGpvH7ambp6CigTbCaEIEmQhh8mVRjtBZkPSuThsw4VSaNdPSWLRSeUSyZkPSuThsw4VSunewqwQilHllq4XOgIAe18PXdKfUCLfi8yupNW7ZTjpnEGSSOSSi45cBYd8csBYdyGplVaatWJohIrBahGNOhJ6XbprUcLQGCodjl8xwcPSurwOJ66VYc8)YIlSjpD78rArImzPISStt3oFKoyfNztaBOww4VSSSUQSurwGWJrTn1uJur8(RgpqwQilHllq4XOgIL52CwEinEGSWLRSSezXCgDMgIL52CwEinDoeJ2YYIYsfzjCzzjYI5m6m9CcVp3M8005qmAllC5klImz7K3PNt4952KNUPvFoKSaVSuneKLfLLkYYsKfi8yupNW7ZTjpnEa45cBYd8qy9DYBLyBGb(SCvaMGhDoeJ2aoapxytEGNJWgQFes1EyZwjY2zGNOhJ6XbVnbHhJ62dB2kr2otTji8yuVtENSWLRSSji8yulYBJlSjusnhFQnbHhJA8azPISyExtM2MvszPkqyQWSGSWFzPQoKYcxUYYsKLnbHhJArEBCHnHsQ54tTji8yuJhilvKLWLLnbHhJ62dB2kr2otTji8yuJmxWNSa)VSSCiLf4KSuDbzbUKLnbHhJAiwMBvgvgwsrhT(vJhilC5kl2Ssklv7HKf(llWXcYYIYsfzbcpg12utnsfX7V6Mw95qYc8Ys1faVZxjWZryd1pcPApSzRez7mGb(S8Yambp6CigTbCaEUWM8apXxblToVrOGyoYaprpg1JdEHll0rD9x9MIJymzb(FzHoQR)QBQMozbUKLWillklvKfi8yuBtn1iveV)Q3jVtwQillrw8Ws9yKgUf)QzKkI3F105qmAdEumsctD(kbEIVcwADEJqbXCKbmWNLddatWJohIrBahGNlSjpWt8vWsRZBekiMJmWt0Jr94GheEmQTPMAKkI3F14bYsfzXdl1JrA4w8RMrQiE)vtNdXOn4rXijm15Re4j(kyP15ncfeZrgWaFwgoaycE05qmAd4a8CHn5bEEyry92rQyEMkJQGKh1GNOhJ6Xbp6OU(REtXrmMSa)VSeYfapkgjHPoFLappSiSE7ivmptLrvqYJAGb(SCibycE05qmAd4a8e9yupo4bHhJABQPgPI49xnEGSWLRSyZkPSuThsw4VSS8cGNlSjpWdhrQXOveWagWaph3WMn49M1LEGbmaaa]] )


end
