-- RogueAssassination.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local IterateTargets, ActorHasDebuff = ns.iterateTargets, ns.actorHasDebuff
local orderedPairs = ns.orderedPairs

local format = string.format


-- Conduits
-- [-] lethal_poisons
-- [-] maim_mangle
-- [-] poisoned_katar
-- [x] wellplaced_steel

-- Covenant
-- [-] reverberation
-- [-] slaughter_scars
-- [-] sudden_fractures
-- [-] septic_shock

-- Endurance
-- [x] cloaked_in_shadows
-- [x] nimble_fingers -- may need to double check which reductions come first.
-- [-] recuperator

-- Finesse
-- [x] fade_to_nothing
-- [x] prepared_for_all
-- [x] quick_decisions
-- [x] rushed_setup


if UnitClassBase( 'player' ) == 'ROGUE' then
    local spec = Hekili:NewSpecialization( 259 )

    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Energy, {
        vendetta_regen = {
            aura = "vendetta_regen",

            last = function ()
                local app = state.buff.vendetta_regen.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 20,
        },

        garrote_vim = {
            aura = "garrote",
            debuff = true,

            last = function ()
                local app = state.debuff.garrote.last_tick
                local exp = state.debuff.garrote.expires
                local tick = state.debuff.garrote.tick_time
                local t = state.query_time

                return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
            end,

            stop = function ()
                return state.debuff.wound_poison_dot.down and state.debuff.deadly_poison_dot.down
            end,

            interval = function ()
                return state.debuff.garrote.tick_time
            end,

            value = 8
        },

        internal_bleeding_vim = {
            aura = "internal_bleeding",
            debuff = true,

            last = function ()
                local app = state.debuff.internal_bleeding.last_tick
                local exp = state.debuff.internal_bleeding.expires
                local tick = state.debuff.internal_bleeding.tick_time
                local t = state.query_time

                return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
            end,

            stop = function ()
                return state.debuff.wound_poison_dot.down and state.debuff.deadly_poison_dot.down
            end,

            interval = function ()
                return state.debuff.internal_bleeding.tick_time
            end,

            value = 8
        },

        rupture_vim = {
            aura = "rupture",
            debuff = true,

            last = function ()
                local app = state.debuff.rupture.last_tick
                local exp = state.debuff.rupture.expires
                local tick = state.debuff.rupture.tick_time
                local t = state.query_time

                return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
            end,

            stop = function ()
                return state.debuff.wound_poison_dot.down and state.debuff.deadly_poison_dot.down
            end,

            interval = function ()
                return state.debuff.rupture.tick_time
            end,

            value = 8
        },

        crimson_tempest_vim = {
            aura = "crimson_tempest",
            debuff = true,

            last = function ()
                local app = state.debuff.crimson_tempest.last_tick
                local exp = state.debuff.crimson_tempest.expires
                local tick = state.debuff.crimson_tempest.tick_time
                local t = state.query_time

                return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
            end,

            stop = function ()
                return state.debuff.wound_poison_dot.down and state.debuff.deadly_poison_dot.down
            end,

            interval = function ()
                return state.debuff.crimson_tempest.tick_time
            end,

            value = 8
        },

        nothing_personal = {
            aura = "nothing_personal_regen",

            last = function ()
                local app = state.buff.nothing_personal_regen.applied
                local exp = state.buff.nothing_personal_regen.expires
                local tick = state.buff.nothing_personal_regen.tick_time
                local t = state.query_time

                return min( exp, app + ( floor( ( t - app ) / tick ) * tick ) )
            end,

            stop = function ()
                return state.buff.nothing_personal_regen.down
            end,

            interval = function ()
                return state.buff.nothing_personal_regen.tick_time
            end,

            value = 4
        }
    } )

    -- Talents
    spec:RegisterTalents( {
        master_poisoner = 22337, -- 196864
        elaborate_planning = 22338, -- 193640
        blindside = 22339, -- 111240

        nightstalker = 22331, -- 14062
        subterfuge = 22332, -- 108208
        master_assassin = 23022, -- 255989

        vigor = 19239, -- 14983
        deeper_stratagem = 19240, -- 193531
        marked_for_death = 19241, -- 137619

        leeching_poison = 22340, -- 280716
        cheat_death = 22122, -- 31230
        elusiveness = 22123, -- 79008

        internal_bleeding = 19245, -- 154904
        iron_wire = 23037, -- 196861
        prey_on_the_weak = 22115, -- 131511

        venom_rush = 22343, -- 152152
        alacrity = 23015, -- 193539
        exsanguinate = 22344, -- 200806

        poison_bomb = 21186, -- 255544
        hidden_blades = 22133, -- 270061
        crimson_tempest = 23174, -- 121411
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        creeping_venom = 141, -- 354895
        death_from_above = 3479, -- 269513
        dismantle = 5405, -- 207777
        flying_daggers = 144, -- 198128
        hemotoxin = 830, -- 354124
        intent_to_kill = 130, -- 197007
        maneuverability = 3448, -- 197000
        smoke_bomb = 3480, -- 212182
        system_shock = 147, -- 198145
        thick_as_thieves = 5408, -- 221622
    } )


    spec:RegisterStateExpr( "cp_max_spend", function ()
        return combo_points.max
    end )

    -- Commented out in SimC, but my implementation should hold up vs. theirs.
    -- APLs will use effective_combo_points.
    spec:RegisterStateExpr( "animacharged_cp", function ()
        local n = buff.echoing_reprimand.stack
        if n > 0 then return n end
        return combo_points.max
    end )

    spec:RegisterStateExpr( "effective_combo_points", function ()
        if buff.echoing_reprimand.up and combo_points.current == buff.echoing_reprimand.stack then
            return 7
        end
        return combo_points.current
    end )

    local stealth = {
        rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
        mantle  = { "stealth", "vanish" },
        sepsis  = { "sepsis_buff" },
        all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld", "sepsis_buff" }
    }

    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            if k == "rogue" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up
            elseif k == "rogue_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains )

            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "mantle_remains" then
                return max( buff.stealth.remains, buff.vanish.remains )
            
            elseif k == "sepsis" then
                return buff.sepsis_buff.up
            elseif k == "sepsis_remains" then
                return buff.sepsis_buff.remains
            
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up or buff.sepsis_buff.up
            elseif k == "remains" or k == "all_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains, buff.sepsis_buff.remains )
            end

            return false
        end
    } ) )

    spec:RegisterStateExpr( "master_assassin_remains", function ()
        if not ( talent.master_assassin.enabled or legendary.mark_of_the_master_assassin.enabled ) then return 0 end

        if stealthed.mantle then return cooldown.global_cooldown.remains + ( legendary.mark_of_the_master_assassin.enabled and 4 or 3 )
        elseif buff.master_assassin_any.up then return buff.master_assassin_any.remains end
        return 0
    end )

    local stealth_dropped = 0

    local function isStealthed()
        return ( FindUnitBuffByID( "player", 1784 ) or FindUnitBuffByID( "player", 115191 ) or FindUnitBuffByID( "player", 115192 ) or FindUnitBuffByID( "player", 11327 ) or GetTime() - stealth_dropped < 0.2 )
    end

    local calculate_multiplier = setfenv( function( spellID )
        local mult = 1
        local stealth = isStealthed()

        if stealth then
            if talent.nightstalker.enabled then
                mult = mult * 1.5
            end

            -- Garrote.
            if talent.subterfuge.enabled and spellID == 703 then
                mult = mult * 1.8
            end
        end

        return mult
    end, state )


    -- Bleed Modifiers
    -- 9.2 adds a set bonus that is essentially a second Exsanguinate.
    -- We need to be able to tell that an aura has been Exsanguinated via talent *and* Exsanguinated by Vendetta and 4pc.

    local tier28_vendetta_spells = {
        garrote = 1,
        rupture = 1,
        crimson_tempest = 1,
        internal_bleeding = 1,

        deadly_poison_dot = 1,
        sepsis = 1,
        serrated_bone_spike = 1,
    }
    
    local tracked_bleeds = {}
    
    local function NewBleed( key, spellID )
        tracked_bleeds[ key ] = {
            id = spellID,
            exsanguinate = {},
            vendetta = {},
            rate = {},
            last_tick = {}
        }

        tracked_bleeds[ spellID ] = tracked_bleeds[ key ]
    end

    local function ApplyBleed( key, target, exsanguinate, vendetta )
        local bleed = tracked_bleeds[ key ]

        bleed.rate[ target ]         = 1 + ( exsanguinate and 1 or 0 ) + ( vendetta and 1 or 0 )
        bleed.last_tick[ target ]    = GetTime()
        bleed.exsanguinate[ target ] = exsanguinate
        bleed.vendetta[ target ]     = vendetta
    end

    local function UpdateBleed( key, target, exsanguinate, vendetta )
        local bleed = tracked_bleeds[ key ]

        if not bleed.rate[ target ] then
            return
        end

        if exsanguinate and not bleed.exsanguinate[ target ] then
            bleed.rate[ target ] = bleed.rate[ target ] + 1
            bleed.exsanguinate[ target ] = true
        end

        if vendetta and not bleed.vendetta[ target ] then
            bleed.rate[ target ] = bleed.rate[ target ] + 1
            bleed.vendetta[ target ] = true
        end
    end

    local function UpdateBleedTick( key, target, time )
        local bleed = tracked_bleeds[ key ]

        if not bleed.rate[ target ] then return end

        bleed.last_tick[ target ] = time or GetTime()
    end

    local function RemoveBleed( key, target )
        local bleed = tracked_bleeds[ key ]

        bleed.rate[ target ]         = nil
        bleed.last_tick[ target ]    = nil
        bleed.exsanguinate[ target ] = nil
        bleed.vendetta[ target ]     = nil
    end

    local function GetExsanguinateRate( aura, target )
        return tracked_bleeds[ aura ] and tracked_bleeds[ aura ].rate[ target ] or 1
    end

    NewBleed( "garrote", 703 )
    NewBleed( "rupture", 1943 )
    NewBleed( "crimson_tempest", 121411 )
    NewBleed( "internal_bleeding", 154904 )

    NewBleed( "deadly_poison_dot", 2823 )
    NewBleed( "sepsis", 328305 )
    NewBleed( "serrated_bone_spike", 324073 )

    local application_events = {
        SPELL_AURA_APPLIED      = true,
        SPELL_AURA_APPLIED_DOSE = true,
        SPELL_AURA_REFRESH      = true,
    }

    local removal_events = {
        SPELL_AURA_REMOVED      = true,
        SPELL_AURA_BROKEN       = true,
        SPELL_AURA_BROKEN_SPELL = true,        
    }

    local stealth_spells = {
        [1784  ] = true,
        [115191] = true,
    }

    local tick_events = {
        SPELL_PERIODIC_DAMAGE   = true,
    }

    local death_events = {
        UNIT_DIED               = true,
        UNIT_DESTROYED          = true,
        UNIT_DISSIPATES         = true,
        PARTY_KILL              = true,
        SPELL_INSTAKILL         = true,
    }

    -- We need to know if a target has Vendetta on it when we apply a bleed, for Tier 28 purposes.
    local vendetta_info = {}


    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID then
            if removal_events[ subtype ] then
                if stealth_spells[ spellID ] then
                    stealth_dropped = GetTime()
                    return
                end
            end

            if application_events[ subtype ] then
                if spellID == 79140 then
                    -- TODO: Review for Vendetta duration extensions.
                    vendetta_info[ destGUID ] = GetTime() + 20

                    -- We applied Vendetta; if we have Tier28 2pc, we have to modify the applied aura.
                    if state.set_bonus.tier28_4pc > 0 then
                        UpdateBleed( "garrote", destGUID, nil, true )
                        UpdateBleed( "rupture", destGUID, nil, true )
                        UpdateBleed( "crimson_tempest", destGUID, nil, true )
                        UpdateBleed( "internal_bleeding", destGUID, nil, true )

                        UpdateBleed( "deadly_poison_dot", destGUID, nil, true )
                        UpdateBleed( "sepsis", destGUID, nil, true )
                        UpdateBleed( "serrated_bone_spike", destGUID, nil, true )
                    end

                    return
                end

                if tracked_bleeds[ spellID ] then
                    -- TODO:  Modernize basic debuff tracking and snapshotting.
                    ns.saveDebuffModifier( spellID, calculate_multiplier( spellID ) )
                    ns.trackDebuff( spellID, destGUID, GetTime(), true )

                    ApplyBleed( spellID, destGUID, nil, state.set_bonus.tier28_4pc > 0 and vendetta_info[ destGUID ] and vendetta_info[ destGUID ] > GetTime() )
                    return
                end

                return
            end

            if tick_events[ subtype ] and tracked_bleeds[ spellID ] then
                UpdateBleedTick( spellID, destGUID, GetTime() )
                return
            end

            -- Exsanguinate was used.
            if subtype == "SPELL_CAST_SUCCESS" and spellID == 200806 then
                UpdateBleed( "garrote", destGUID, true, nil )
                UpdateBleed( "rupture", destGUID, true, nil )
                UpdateBleed( "crimson_tempest", destGUID, true, nil )
                UpdateBleed( "internal_bleeding", destGUID, true, nil )
                return
            end
        end

        if death_events[ subtype ] then
            --[[ TODO: Deal with annoying Training Dummy resets.

            RemoveBleed( "garrote", destGUID )
            RemoveBleed( "rupture", destGUID )
            RemoveBleed( "crimson_tempest", destGUID )
            RemoveBleed( "internal_bleeding", destGUID )

            RemoveBleed( "deadly_poison_dot", destGUID )
            RemoveBleed( "sepsis", destGUID )
            RemoveBleed( "serrated_bone_spike", destGUID ) ]]

            vendetta_info[ destGUID ] = nil
        end
    end )


    spec:RegisterHook( "UNIT_ELIMINATED", function( guid )
        vendetta_info[ guid ] = nil
    end )


    local energySpent = 0

    local ENERGY = Enum.PowerType.Energy
    local lastEnergy = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "ENERGY" then
            local current = UnitPower( "player", ENERGY )

            if current < lastEnergy then
                energySpent = ( energySpent + lastEnergy - current ) % 30
            end

            lastEnergy = current
        end
    end )

    spec:RegisterCycle( function ()
        if active_enemies == 1 then return end
        if this_action == "marked_for_death" then
            if active_dot.marked_for_death >= cycle_enemies then return end -- As far as we can tell, MfD is on everything we care about, so we don't cycle.
            if debuff.marked_for_death.up then return "cycle" end -- If current target already has MfD, cycle.
            if target.time_to_die > 3 + Hekili:GetLowestTTD() and active_dot.marked_for_death == 0 then return "cycle" end -- If our target isn't lowest TTD, and we don't have to worry that the lowest TTD target is already MfD'd, cycle.
        end
    end )

    spec:RegisterStateExpr( "energy_spent", function ()
        return energySpent
    end )

    spec:RegisterHook( "spend", function( amt, resource )
        if legendary.duskwalkers_patch.enabled and cooldown.vendetta.remains > 0 and resource == "energy" and amt > 0 then
            energy_spent = energy_spent + amt
            local reduction = floor( energy_spent / 30 )
            energy_spent = energy_spent % 30

            if reduction > 0 then
                reduceCooldown( "vendetta", reduction )
            end
        end
        
        if resource == "combo_points" and legendary.obedience.enabled and buff.flagellation_buff.up then
            reduceCooldown( "flagellation", amt )
        end
    end )


    spec:RegisterStateExpr( 'persistent_multiplier', function ()
        local mult = 1

        if not this_action then return mult end

        local stealth = buff.stealth.up or buff.subterfuge.up

        if stealth then
            if talent.nightstalker.enabled then
                mult = mult * 2
            end

            if talent.subterfuge.enabled and this_action == "garrote" then
                mult = mult * 1.8
            end
        end

        return mult
    end )




    local exsanguinated_spells = {
        garrote = "garrote",
        kidney_shot = "internal_bleeding",
        rupture = "rupture",
        crimson_tempest = "crimson_tempest",

        deadly_poison = "deadly_poison_dot",
        sepsis = "sepsis",
        serrated_bone_spike = "serrated_bone_spike",
    }

    -- Auras that aren't impacted by Tier 28.
    local true_exsanguinated = {
        "garrote",
        "internal_bleeding",
        "rupture",
        "crimson_tempest",
    }

    spec:RegisterStateExpr( "exsanguinated", function ()
        local aura = this_action and exsanguinated_spells[ this_action ]
        aura = aura and debuff[ aura ]

        if not aura or not aura.up then return false end
        return aura.exsanguinated_rate > 1
    end )

    spec:RegisterStateExpr( "will_lose_exsanguinate", function ()
        local aura = this_action and exsanguinated_spells[ this_action ]
        aura = aura and debuff[ aura ]

        if not aura or not aura.up then return false end
        return aura.exsanguinated_rate > ( debuff.vendetta.up and 2 or 1 )
    end )

    spec:RegisterStateExpr( "exsanguinated_rate", function ()
        local aura = this_action and exsanguinated_spells[ this_action ]
        aura = aura and debuff[ aura ]

        if not aura or not aura.up then return 1 end
        return aura.exsanguinated_rate
    end )


    -- Enemies with either Deadly Poison or Wound Poison applied.
    spec:RegisterStateExpr( "poisoned_enemies", function ()
        return ns.countUnitsWithDebuffs( "deadly_poison_dot", "wound_poison_dot", "crippling_poison_dot" )
    end )

    spec:RegisterStateExpr( "poison_remains", function ()
        return debuff.lethal_poison.remains
    end )


    local valid_bleeds = { "garrote", "internal_bleeding", "rupture", "crimson_tempest", "mutilated_flesh", "serrated_bone_spike" }

    -- Count of bleeds on targets.
    spec:RegisterStateExpr( "bleeds", function ()
        local n = 0

        for _, aura in pairs( valid_bleeds ) do
            if debuff[ aura ].up then
                n = n + 1
            end
        end
        
        return n
    end )
    
    -- Count of bleeds on all poisoned (Deadly/Wound) targets.
    spec:RegisterStateExpr( "poisoned_bleeds", function ()
        return ns.conditionalDebuffCount( "deadly_poison_dot", "wound_poison_dot", "garrote", "internal_bleeding", "rupture" )
    end )
    
    
    spec:RegisterStateExpr( "ss_buffed", function ()
        return false
    end )

    spec:RegisterStateExpr( "non_ss_buffed_targets", function ()
        return active_enemies
        --[[ local count = ( debuff.garrote.down or not debuff.garrote.exsanguinated ) and 1 or 0

        for guid, counted in ns.iterateTargets() do
            if guid ~= target.unit and counted and ( not ns.actorHasDebuff( guid, 703 ) or not ssG[ guid ] ) then
                count = count + 1
            end
        end

        return count ]]
    end )

    spec:RegisterStateExpr( "ss_buffed_targets_above_pandemic", function ()
        --[[ if not debuff.garrote.refreshable and debuff.garrote.ss_buffed then
            return 1
        end ]]
        return 0
    end )



    spec:RegisterStateExpr( "pmultiplier", function ()
        if not this_action then return 0 end

        local a = class.abilities[ this_action ]
        if not a then return 0 end

        local aura = a.aura or this_action
        if not aura then return 0 end

        if debuff[ aura ] and debuff[ aura ].up then
            return debuff[ aura ].pmultiplier or 1
        end

        return 0
    end )

    spec:RegisterStateExpr( "priority_rotation", function ()
        return settings.priority_rotation
    end )


    local ExpireSepsis = setfenv( function ()
        applyBuff( "sepsis_buff" )

        if legendary.toxic_onslaught.enabled then
            applyBuff( "adrenaline_rush", 10 )
            applyBuff( "shadow_blades", 10 )
        end
    end, state )


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364667, "tier28_4pc", 363591 )
    -- 2-Set - Grudge Match - Shiv causes enemies within 15 yards to take 40% increased damage from your Poisons and Bleeds for 9 seconds.
    -- 4-Set - Grudge Match - Vendetta causes Poisons and Bleeds on your target to expire 100% faster.
    spec:RegisterAuras( {
        grudge_match = {
            id = 264668,
            duration = 9,
            max_stack = 1,
        },
    } )

    local ExpireVendetta = setfenv( function ()
        if debuff.serrated_bone_spike.up and debuff.serrated_bone_spike.vendetta_exsg then
            debuff.serrated_bone_spike.vendetta_exsg = false
            debuff.serrated_bone_spike.exsanguinated_rate = max( 1, debuff.serrated_bone_spike.exsanguinated_rate - 1 )
        end
    end, state )

    
    spec:RegisterHook( "reset_precast", function ()
        Hekili.Exsg = "Bleed Snapshots       Remains  Multip.  RateMod  Exsang.  Tier-28\n"
        for _, aura in orderedPairs( exsanguinated_spells ) do
            local d = debuff[ aura ]
            d.pmultiplier = nil
            d.exsanguinated_rate = nil
            d.vendetta_exsg = nil
            d.exsanguinated = nil

            Hekili.Exsg = format( "%s%-20s  %7.2f  %7.2f  %7.2f  %7s  %7s\n", Hekili.Exsg, aura, d.remains, d.pmultiplier, d.exsanguinated_rate, d.exsanguinated and "true" or "false", d.vendetta_exsg and "true" or "false" )
        end

        if Hekili.ActiveDebug then Hekili:Debug( Hekili.Exsg ) end

        if debuff.sepsis.up then
            state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
        end

        for guid, expiration in pairs( vendetta_info ) do
            if expiration < now then
                vendetta_info[ guid ] = nil

                if tracked_bleeds.serrated_bone_spike.vendetta[ guid ] and tracked_bleeds.serrated_bone_spike.vendetta[ guid ] > 1 then
                    tracked_bleeds.serrated_bone_spike.vendetta[ guid ] = tracked_bleeds.serrated_bone_spike.vendetta[ guid ] - 1
                end
            end
        end

        if set_bonus.tier28_4pc > 0 and debuff.vendetta.up then
            state:QueueAuraExpiration( "vendetta", ExpireVendetta, debuff.vendetta.expires )
        end

        class.abilities.apply_poison = class.abilities.apply_poison_actual
        if buff.lethal_poison.down or level < 33 then
            class.abilities.apply_poison = state.spec.assassination and level > 12 and class.abilities.deadly_poison or class.abilities.instant_poison
        else
            if level > 32 and buff.nonlethal_poison.down then class.abilities.apply_poison = class.abilities.crippling_poison end
        end
    end )

    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.mantle and ( not a or a.startsCombat ) then
            if talent.master_assassin.enabled then
                applyBuff( "master_assassin" )
            end

            if talent.subterfuge.enabled then
                applyBuff( "subterfuge" )
            end

            if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
                applyBuff( "master_assassins_mark", 4 )
            end

            if buff.stealth.up then
                setCooldown( "stealth", 2 )
            end

            removeBuff( "stealth" )
            removeBuff( "shadowmeld" )
            removeBuff( "vanish" )
        end

        class.abilities.apply_poison = class.abilities.apply_poison_actual
        if buff.lethal_poison.down or level < 33 then
            class.abilities.apply_poison = state.spec.assassination and level > 12 and class.abilities.deadly_poison or class.abilities.instant_poison
        else
            if level > 32 and buff.nonlethal_poison.down then class.abilities.apply_poison = class.abilities.crippling_poison end
        end
    end )


    -- Auras
    spec:RegisterAuras( {
        blind = {
            id = 2094,
            duration = 60,
            max_stack = 1,
        },
        blindside = {
            id = 121153,
            duration = 10,
            max_stack = 1,
        },
        cheap_shot = {
            id = 1833,
            duration = 4,
            max_stack = 1,
        },
        cloak_of_shadows = {
            id = 31224,
            duration = 5,
            max_stack = 1,
        },
        crimson_tempest = {
            id = 121411,
            duration = function () return ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ) * ( talent.deeper_stratagem.enabled and 14 or 12 ) end,
            max_stack = 1,
            meta = {
                exsanguinated = function( t ) return t.up and tracked_bleeds.crimson_tempest.exsanguinate[ target.unit ] or false end,
                vendetta_exsg = function( t ) return t.up and tracked_bleeds.crimson_tempest.vendetta[ target.unit ] or false end,
                exsanguinated_rate = function( t ) return t.up and tracked_bleeds.crimson_tempest.rate[ target.unit ] or 1 end,
                last_tick = function( t ) return t.up and ( tracked_bleeds.crimson_tempest.last_tick[ target.unit ] or t.applied ) or 0 end,
                tick_time = function( t ) return t.up and ( haste * ( 2 / t.exsanguinated_rate ) ) or ( haste * 2 ) end,
            },                    
        },
        crimson_vial = {
            id = 185311,
            duration = 4,
            max_stack = 1,
        },
        crippling_poison = {
            id = 3408,
            duration = 3600,
            max_stack = 1,
        },
        crippling_poison_dot = {
            id = 3409,
            duration = 12,
            max_stack = 1,
        },
        deadly_poison = {
            id = 2823,
            duration = 3600,
            max_stack = 1,
        },
        deadly_poison_dot = {
            id = 2818,
            duration = function () return ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ) * ( 12 * haste ) end,
            max_stack = 1,
            exsanguinated = false,
            meta = {
                vendetta_exsg = function( t ) return t.up and tracked_bleeds.deadly_poison_dot.vendetta[ target.unit ] or false end,
                exsanguinated_rate = function( t ) return t.up and tracked_bleeds.deadly_poison_dot.rate[ target.unit ] or 1 end,
                last_tick = function( t ) return t.up and ( tracked_bleeds.deadly_poison_dot.last_tick[ target.unit ] or t.applied ) or 0 end,
                tick_time = function( t ) return t.up and ( haste * ( 2 / t.exsanguinated_rate ) ) or ( haste * 2 ) end,
            },                    
        },  
        elaborate_planning = {
            id = 193641,
            duration = 4,
            max_stack = 1,
        },
        envenom = {
            id = 32645,
            duration = function () return talent.deeper_stratagem.enabled and 7 or 6 end,
            type = "Poison",
            max_stack = 1,
        },
        evasion = {
            id = 5277,
            duration = 10,
            max_stack = 1,
        },
        feint = {
            id = 1966,
            duration = 6,
            max_stack = 1,
        },
        fleet_footed = {
            id = 31209,
        },
        garrote = {
            id = 703,
            duration = function() return ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ) * 18 end,
            max_stack = 1,
            ss_buffed = false,
            meta = {
                duration = function( t ) return t.up and ( 18 * haste / t.exsanguinated_rate ) or class.auras.garrote.duration end,
                exsanguinated = function( t ) return t.up and tracked_bleeds.garrote.exsanguinate[ target.unit ] or false end,
                vendetta_exsg = function( t ) return t.up and tracked_bleeds.garrote.vendetta[ target.unit ] or false end,
                exsanguinated_rate = function( t ) return t.up and tracked_bleeds.garrote.rate[ target.unit ] or 1 end,
                last_tick = function( t ) return t.up and ( tracked_bleeds.garrote.last_tick[ target.unit ] or t.applied ) or 0 end,
                tick_time = function( t ) return t.up and ( haste * 2 / t.exsanguinated_rate ) or ( haste * 2 ) end,
            },
        },
        garrote_silence = {
            id = 1330,
            duration = function () return talent.iron_wire.enabled and 6 or 3 end,
            max_stack = 1,
        },
        hidden_blades = {
            id = 270070,
            duration = 3600,
            max_stack = 20,
        },
        internal_bleeding = {
            id = 154953,
            duration = function () return ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ) * 6 end,
            max_stack = 1,
            meta = {
                exsanguinated = function( t ) return t.up and tracked_bleeds.internal_bleeding.exsanguinate[ target.unit ] or false end,
                vendetta_exsg = function( t ) return t.up and tracked_bleeds.internal_bleeding.vendetta[ target.unit ] or false end,
                exsanguinated_rate = function( t ) return t.up and tracked_bleeds.internal_bleeding.rate[ target.unit ] or 1 end,
                last_tick = function( t ) return t.up and ( tracked_bleeds.internal_bleeding.last_tick[ target.unit ] or t.applied ) or 0 end,
                tick_time = function( t ) return t.up and ( haste * 2 / t.exsanguinated_rate ) or ( haste * 2 ) end,
            },
        },
        iron_wire = {
            id = 256148,
            duration = 8,
            max_stack = 1,
        },
        kidney_shot = {
            id = 408,
            duration = function () return talent.deeper_stratagem.enabled and 7 or 6 end,
            max_stack = 1,
        },
        marked_for_death = {
            id = 137619,
            duration = 60,
            max_stack = 1,
        },
        master_assassin = {
            id = 256735,
            duration = 3,
            max_stack = 1,
        },
        prey_on_the_weak = {
            id = 255909,
            duration = 6,
            max_stack = 1,
        },
        rupture = {
            id = 1943,
            duration = function () return ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ) * ( talent.deeper_stratagem.enabled and 28 or 24 ) end,
            tick_time = function () return ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ) * ( debuff.rupture.exsanguinated and haste or ( 2 * haste ) ) end,
            max_stack = 1,
            meta = {
                exsanguinated = function( t ) return t.up and tracked_bleeds.rupture.exsanguinate[ target.unit ] or false end,
                vendetta_exsg = function( t ) return t.up and tracked_bleeds.rupture.vendetta[ target.unit ] or false end,
                exsanguinated_rate = function( t ) return t.up and tracked_bleeds.rupture.rate[ target.unit ] or 1 end,
                last_tick = function( t ) return t.up and ( tracked_bleeds.rupture.last_tick[ target.unit ] or t.applied ) or 0 end,
                tick_time = function( t ) return t.up and ( haste * 2 / t.exsanguinated_rate ) or ( haste * 2 ) end,
            },
        },
        shadowstep = {
            id = 36554,
            duration = 2,
            max_stack = 1,
        },
        shroud_of_concealment = {
            id = 114018,
            duration = 15,
            max_stack = 1,
        },
        slice_and_dice = {
            id = 315496,
            duration = function () return talent.deeper_stratagem.enabled and 42 or 36 end,
            max_stack = 1
        },
        sprint = {
            id = 2983,
            duration = 8,
            max_stack = 1,
        },
        stealth = {
            id = function () return talent.subterfuge.enabled and 115191 or 1784 end,
            duration = 3600,
            max_stack = 1,
            copy = { 115191, 1784 }
        },
        subterfuge = {
            id = 115192,
            duration = 3,
            max_stack = 1,
        },
        tricks_of_the_trade = {
            id = 57934,
            duration = 30,
            max_stack = 1,
        },
        vanish = {
            id = 11327,
            duration = 3,
            max_stack = 1,
        },
        vendetta = {
            id = 79140,
            duration = 20,
            max_stack = 1,
        },
        vendetta_regen = {
            name = "Vendetta Regen",
            duration = 3,
            max_stack = 1,
            generate = function ()
                local cast = action.vendetta.lastCast or 0
                local up = cast + 3 < query_time

                local vr = buff.vendetta_regen

                if up then
                    vr.count = 1
                    vr.expires = cast + 3
                    vr.applied = cast
                    vr.caster = "player"
                    return
                end
                vr.count = 0
                vr.expires = 0
                vr.applied = 0
                vr.caster = "nobody"                
            end,
        },
        venomous_wounds = {
            id = 79134,
        },
        wound_poison = {
            id = 8679,
            duration = 3600,
            max_stack = 1,
        },
        wound_poison_dot = {
            id = 8680,
            duration = 12,
            max_stack = 1,
            no_ticks = true,
        },


        lethal_poison = {
            alias = { "deadly_poison", "wound_poison", "instant_poison" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600
        },
        nonlethal_poison = {
            alias = { "crippling_poison", "numbing_poison" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600
        },


        -- Azerite Powers
        nothing_personal = {
            id = 286581,
            duration = 20,
            tick_time = 2,
            max_stack = 1,
        },

        nothing_personal_regen = {
            id = 289467,
            duration = 20,
            tick_time = 2,
            max_stack = 1,
        },

        scent_of_blood = {
            id = 277731,
            duration = 24,            
        },

        sharpened_blades = {
            id = 272916,
            duration = 20,
            max_stack = 30
        },

        -- PvP Talents
        creeping_venom = {
            id = 198097,
            duration = 4,
            max_stack = 18,
        },

        system_shock = {
            id = 198222,
            duration = 2,
        },

        -- Legendaries
        bloodfang = {
            id = 23581,
            duration = 6,
            max_stack = 1
        },

        master_assassins_mark = {
            id = 340094,
            duration = 4,
            max_stack = 1
        },

        master_assassin_any = {
            alias = { "master_assassin", "master_assassins_mark" },
            aliasMode = "longest",
            aliasType = "buff",
            duration = function () return legendary.mark_of_the_master_assassin.enabled and 4 or 3 end,
        }
    } )

    
    -- Abilities
    spec:RegisterAbilities( {
        ambush = {
            id = 8676,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return buff.blindside.up and 0 or 50 end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132282,
            
            usable = function () return stealthed.all or buff.blindside.up or buff.sepsis_buff.up, "requires stealth or blindside or sepsis proc" end,
            
            handler = function ()                
                gain( 2, "combo_points" )
                if buff.sepsis_buff.up then removeBuff( "sepsis_buff" )
                else
                    removeBuff( "blindside" )
                end
            end,
        },
        
        
        blind = {
            id = 2094,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = true,
            texture = 136175,

            handler = function ()
                applyDebuff( "target", "blind" )
            end,
        },


        cheap_shot = {
            id = 1833,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 40 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132092,

            cycle = function ()
                if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
            end,

            usable = function ()
                if boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all, "not stealthed"
            end,

            nodebuff = "cheap_shot",

            handler = function ()
                applyDebuff( "target", "cheap_shot" )
                gain( 1, "combo_points" )

                if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end

                if talent.prey_on_the_weak.enabled then applyDebuff( "target", "prey_on_the_weak" ) end
            end,
        },


        cloak_of_shadows = {
            id = 31224,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 136177,

            handler = function ()
                applyBuff( "cloak_of_shadows" )
            end,
        },


        crimson_tempest = {
            id = 121411,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,
            spendType = "energy",

            startsCombat = true,
            texture = 464079,

            talent = "crimson_tempest",
            aura = "crimson_tempest",
            cycle = "crimson_tempest",            

            usable = function () return combo_points.current > 0 end,

            handler = function ()
                applyDebuff( "target", "crimson_tempest", 2 + ( combo_points.current * 2 ) )
                debuff.crimson_tempest.pmultiplier = persistent_multiplier
                debuff.crimson_tempest.exsanguinated_rate = 1
                debuff.crimson_tempest.exsanguinated = false
                
                if set_bonus.tier28_4pc > 0 and debuff.vendetta.up then
                    debuff.crimson_tempest.exsanguinated_rate = 2
                    debuff.crimson_tempest.vendetta_exsg = true
                end

                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
                spend( combo_points.current, "combo_points" )

                if talent.elaborate_planning.enabled then applyBuff( "elaborate_planning" ) end
            end,
        },


        crimson_vial = {
            id = 185311,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return 20 - conduit.nimble_fingers.mod end,
            spendType = "energy",

            startsCombat = false,
            texture = 1373904,

            toggle = "defensives",

            handler = function ()
                applyBuff( "crimson_vial" )
            end,
        },


        crippling_poison = {
            id = 3408,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            essential = true,

            texture = 132274,

            readyTime = function () return buff.nonlethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "crippling_poison" )
            end,
        },


        deadly_poison = {
            id = 2823,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            essential = true,
            texture = 132290,

            
            readyTime = function () return buff.lethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "deadly_poison" )
            end,
        },


        distract = {
            id = 1725,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return 30 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132289,

            handler = function ()
            end,
        },


        envenom = {
            id = 32645,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,

            spendType = "energy",

            startsCombat = true,
            texture = 132287,

            usable = function () return combo_points.current > 0, "requires combo_points" end,

            handler = function ()
                if pvptalent.system_shock.enabled then
                    if combo_points.current >= 5 and debuff.garrote.up and debuff.rupture.up and ( debuff.deadly_poison_dot.up or debuff.wound_poison_dot.up ) then
                        applyDebuff( "target", "system_shock", 2 )
                    end
                end

                if pvptalent.creeping_venom.enabled then
                    applyDebuff( "target", "creeping_venom" )
                end

                if level > 55 and buff.slice_and_dice.up then
                    buff.slice_and_dice.expires = buff.slice_and_dice.expires + combo_points.current * 3
                end

                applyBuff( "envenom", 1 + combo_points.current )
                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
                spend( combo_points.current, "combo_points" )

                if talent.elaborate_planning.enabled then applyBuff( "elaborate_planning" ) end
            end,
        },


        evasion = {
            id = 5277,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 136205,

            handler = function ()
                applyBuff( "evasion" )
            end,
        },


        exsanguinate = {
            id = 200806,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = true,
            texture = 538040,

            talent = "exsanguinate",

            handler = function ()
                local deb, rate, rem, dur

                for i, aura in ipairs( true_exsanguinated ) do
                    local deb = debuff[ aura ]

                    if deb.up and not deb.exsanguinated then
                        deb.exsanguinated = true

                        rate = deb.exsanguinated_rate
                        deb.exsanguinated_rate = deb.exsanguinated_rate + 1

                        rem = deb.remains
                        deb.expires = query_time + ( deb.remains * rate / deb.exsanguinated_rate )
                        deb.duration = deb.expires - deb.applied
                    end
                end
            end,
        },


        fan_of_knives = {
            id = 51723,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 35,
            spendType = "energy",

            startsCombat = true,
            texture = 236273,

            cycle = function () return buff.deadly_poison.up and "deadly_poison" or nil end,

            handler = function ()
                gain( 1, "combo_points" )
                removeBuff( "hidden_blades" )
                if buff.deadly_poison.up then
                    applyDebuff( "target", "deadly_poison" )
                    active_dot.deadly_poison = min( active_enemies, active_dot.deadly_poison + 8 )
                end
            end,
        },


        feint = {
            id = 1966,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = function () return 35 - conduit.nimble_fingers.mod end,
            spendType = "energy",

            startsCombat = false,
            texture = 132294,

            handler = function ()
                applyBuff( "feint" )
            end,
        },


        garrote = {
            id = 703,
            cast = 0,
            cooldown = function () return ( talent.subterfuge.enabled and ( buff.stealth.up or buff.subterfuge.up ) ) and 0 or 6 end,
            gcd = "spell",

            spend = 45,
            spendType = "energy",

            startsCombat = true,
            texture = 132297,

            aura = "garrote",
            cycle = "garrote",

            handler = function ()
                applyDebuff( "target", "garrote" )
                
                debuff.garrote.pmultiplier = persistent_multiplier
                debuff.garrote.exsanguinated_rate = 1
                debuff.garrote.exsanguinated = false

                if set_bonus.tier28_4pc > 0 and debuff.vendetta.up then
                    debuff.garrote.exsanguinated_rate = 2
                    debuff.garrote.vendetta_exsg = true
                end

                gain( 1, "combo_points" )

                if stealthed.rogue then
                    if level > 45 then applyDebuff( "target", "garrote_silence" ) end
                    if talent.iron_wire.enabled then applyDebuff( "target", "iron_wire" ) end

                    if azerite.shrouded_suffocation.enabled then
                        gain( 2, "combo_points" )
                        debuff.garrote.ss_buffed = true
                    end
                end
            end,
        },


        kick = {
            id = 1766,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            startsCombat = true,
            texture = 132219,

            toggle = "interrupts",
            interrupt = true,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
                
                if conduit.prepared_for_all.enabled and cooldown.cloak_of_shadows.remains > 0 then
                    reduceCooldown( "cloak_of_shadows", 2 * conduit.prepared_for_all.mod )
                end
            end,
        },


        kidney_shot = {
            id = 408,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 25 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132298,

            aura = "internal_bleeding",
            cycle = "internal_bleeding",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if talent.internal_bleeding.enabled then
                    applyDebuff( "target", "internal_bleeding" )
                    debuff.internal_bleeding.pmultiplier = persistent_multiplier
                    debuff.internal_bleeding.exsanguinated = false
                    debuff.internal_bleeding.exsanguinated_rate = 1
                                    
                    if set_bonus.tier28_4pc > 0 and debuff.vendetta.up then
                        debuff.internal_bleeding.exsanguinated_rate = 2
                        debuff.internal_bleeding.vendetta_exsg = true
                    end
                end

                applyDebuff( "target", "kidney_shot", 1 + combo_points.current )
                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
                spend( combo_points.current, "combo_points" )

                if talent.elaborate_planning.enabled then applyBuff( "elaborate_planning" ) end
            end,
        },


        marked_for_death = {
            id = 137619,
            cast = 0,
            cooldown = 30,
            gcd = "off",

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return combo_points.current <= settings.mfd_points, "combo_point (" .. combo_points.current .. ") > user preference (" .. settings.mfd_points .. ")"
            end,

            handler = function ()
                gain( 5, "combo_points" )
                applyDebuff( "target", "marked_for_death" )
            end,
        },


        mutilate = {
            id = 1329,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 50,
            spendType = "energy",

            startsCombat = true,
            texture = 132304,

            handler = function ()
                gain( 2, "combo_points" )

                if talent.venom_rush.enabled and ( debuff.deadly_poison_dot.up or debuff.wound_poison_dot.up or debuff.crippling_poison_dot.up ) then
                    gain( 8, "energy" )
                end

                if legendary.doomblade.enabled then
                    applyDebuff( "target", "mutilated_flesh" )
                end
            end,

            auras = {
                mutilated_flesh = {
                    id = 340431,
                    duration = 6,
                    max_stack = 1
                }
            }
        },


        numbing_poison = {
            id = 5761,
            cast = 1,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136066,

            readyTime = function () return buff.nonlethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "numbing_poison" )
            end,
        },


        --[[ pick_lock = {
            id = 1804,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 136058,

            handler = function ()
            end,
        },


        pick_pocket = {
            id = 921,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            startsCombat = true,
            texture = 133644,

            handler = function ()
            end,
        }, ]]


        poisoned_knife = {
            id = 185565,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 1373909,

            handler = function ()
                removeBuff( "sharpened_blades" )
                gain( 1, "combo_points" )
            end,
        },


        rupture = {
            id = 1943,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = true,
            texture = 132302,

            aura = "rupture",
            cycle = "rupture",

            usable = function () return combo_points.current > 0, "requires combo_points" end,
            handler = function ()
                applyDebuff( "target", "rupture", ( 4 + ( 4 * effective_combo_points ) ) * ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ) )
                debuff.rupture.pmultiplier = persistent_multiplier
                debuff.rupture.exsanguinated = false
                debuff.rupture.exsanguinated_rate = 1

                if set_bonus.tier28_4pc > 0 and debuff.vendetta.up then
                    debuff.rupture.exsanguinated_rate = 2
                    debuff.rupture.vendetta_exsg = true
                end

                if azerite.scent_of_blood.enabled then
                    applyBuff( "scent_of_blood", dot.rupture.remains )
                end

                if combo_points.current == animacharged_cp then
                    removeBuff( "echoing_reprimand_" .. combo_points.current )
                end
                spend( combo_points.current, "combo_points" )
            end,
        },


        sap = {
            id = 6770,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132310,

            usable = function () return stealthed.all or buff.sepsis_buff.up, "requires stealth" end,
            handler = function ()
                applyDebuff( "target", "sap" )
                removeBuff( "sepsis_buff" )
            end,
        },


        shadowstep = {
            id = 36554,
            cast = 0,
            charges = 1,
            cooldown = function ()
                return 30 * ( 1 - conduit.quick_decisions.mod * 0.01 ) * ( pvptalent.intent_to_kill.enabled and debuff.vendetta.up and 0.1 or 1 )
            end,
            recharge = function ()
                if pvptalent.intent_to_kill.enabled and debuff.vendetta.up then return 10 end
                return 30 * ( 1 - conduit.quick_decisions.mod * 0.01 )
            end,                
            gcd = "spell",

            startsCombat = false,
            texture = 132303,

            handler = function ()
                applyBuff( "shadowstep" )
                setDistance( 5 )
            end,
        },
        

        shiv = {
            id = 5938,
            cast = 0,
            cooldown = 25,
            gcd = "spell",
            
            spend = function () return legendary.tiny_toxic_blade.enabled and 0 or 20 end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 135428,
            
            handler = function ()
                gain( 1, "combo_points" )
                applyDebuff( "target", "crippling_poison_shiv" )
                
                if level > 57 then applyDebuff( "target", "shiv" ) end

                if conduit.wellplaced_steel.enabled and debuff.envenom.up then
                    debuff.envenom.expires = debuff.envenom.expires + conduit.wellplaced_steel.mod
                end
            end,

            auras = {
                crippling_poison_shiv = {
                    id = 115196,
                    duration = 9,
                    max_stack = 1,        
                },
                shiv = {
                    id = 319504,
                    duration = 9,
                    max_stack = 1,
                },
            }
        },


        shroud_of_concealment = {
            id = 114018,
            cast = 0,
            cooldown = 360,
            gcd = "spell",

            startsCombat = false,
            texture = 635350,

            usable = function () return stealthed.all, "requires stealth" end,
            handler = function ()
                applyBuff( "shroud_of_concealment" )
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
            end,
        },


        sprint = {
            id = 2983,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 132307,

            handler = function ()
                applyBuff( "sprint" )
            end,
        },


        stealth = {
            id = 1784,
            cast = 0,
            cooldown = 2,
            gcd = "spell",

            startsCombat = false,
            texture = 132320,

            usable = function () return time == 0 and not buff.stealth.up and not buff.vanish.up, "requires out of combat and not stealthed" end,            
            handler = function ()
                applyBuff( "stealth" )

                if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
            end,

            auras = {
                -- Conduit
                cloaked_in_shadows = {
                    id = 341530,
                    duration = 3600,
                    max_stack = 1
                },
                -- Conduit
                fade_to_nothing = {
                    id = 341533,
                    duration = 3,
                    max_stack = 1
                }
            }
        },


        tricks_of_the_trade = {
            id = 57934,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 236283,

            handler = function ()
                applyBuff( "tricks_of_the_trade" )
            end,
        },


        vanish = {
            id = 1856,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 132331,

            disabled = function ()
                return not settings.solo_vanish and not ( boss and group ), "can only vanish in a boss encounter or with a group"
            end,

            handler = function ()
                applyBuff( "vanish" )
                applyBuff( "stealth" )

                if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end -- ???
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end

                if legendary.invigorating_shadowdust.enabled then
                    for name, cd in pairs( cooldown ) do
                        if cd.remains > 0 then reduceCooldown( name, 20 ) end
                    end
                end
            end,
        },


        vendetta = {
            id = 79140,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 458726,

            aura = "vendetta",

            handler = function ()
                applyDebuff( "target", "vendetta" )
                applyBuff( "vendetta_regen" )

                if azerite.nothing_personal.enabled then
                    applyDebuff( "target", "nothing_personal" )
                    applyBuff( "nothing_personal_regen" )
                end

                if set_bonus.tier28_4pc > 0 then
                    for k, v in pairs( tier28_vendetta_spells ) do
                        local bleed = debuff[ k ]
                        if bleed.up and not bleed.vendetta_exsg then
                            local rate = bleed.exsanguinated_rate
                            bleed.exsanguinated_rate = rate + 1
                            bleed.vendetta_exsg = true

                            local rem = bleed.remains
                            bleed.expires = query_time + bleed.remains * rate / bleed.exsanguinated_rate
                        end
                    end
                end
            end,
        },


        wound_poison = {
            id = 8679,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            essential = true,

            texture = 134197,

            readyTime = function () return buff.lethal_poison.remains - 120 end,
            
            handler = function ()
                applyBuff( "wound_poison" )
            end,
        },


        apply_poison = {
            name = _G.MINIMAP_TRACKING_VENDOR_POISON,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            essential = true,

            texture = function ()
                if buff.lethal_poison.down or level < 33 then
                    return state.spec.assassination and level > 12 and class.abilities.deadly_poison.texture or class.abilities.instant_poison.texture
                end
                if level > 32 and buff.nonlethal_poison.down then return class.abilities.crippling_poison.texture end
            end,

            bind = function ()
                if buff.lethal_poison.down or level < 33 then
                    return state.spec.assassination and level > 12 and "deadly_poison" or "instant_poison"
                end
                if level > 32 and "nonlethal_poison" then return "crippling_poison" end
            end,

            usable = function ()
                return buff.lethal_poison.down or level > 32 and buff.nonlethal_poison.down, "requires missing poison"
            end,

            handler = function ()
                if buff.lethal_poison.down then
                    applyBuff( state.spec.assassination and level > 12 and "deadly_poison" or "instant_poison" )
                elseif level > 32 then applyBuff( "crippling_poison" ) end
            end,

            copy = "apply_poison_actual"
        },


        -- Covenant Abilities
        -- Rogue - Kyrian    - 323547 - echoing_reprimand    (Echoing Reprimand)
        echoing_reprimand = {
            id = 323547,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = function () return 10 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 3565450,

            toggle = "essences",

            cp_gain = function () return ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 1 or 0 ) + 2 end,

            handler = function ()
                -- Can't predict the Animacharge, unless you have the legendary.
                if legendary.resounding_clarity.enabled then
                    applyBuff( "echoing_reprimand_2", nil, 2 )
                    applyBuff( "echoing_reprimand_3", nil, 3 )
                    applyBuff( "echoing_reprimand_4", nil, 4 )
                    applyBuff( "echoing_reprimand_5", nil, 5 )
                end
                gain( action.echoing_reprimand.cp_gain, "combo_points" )
            end,

            disabled = function ()
                return covenant.kyrian and not IsSpellKnownOrOverridesKnown( 323547 ), "you have not finished your kyrian covenant intro"
            end,

            auras = {
                echoing_reprimand_2 = {
                    id = 323558,
                    duration = 45,
                    max_stack = 6,
                },
                echoing_reprimand_3 = {
                    id = 323559,
                    duration = 45,
                    max_stack = 6,
                },
                echoing_reprimand_4 = {
                    id = 323560,
                    duration = 45,
                    max_stack = 6,
                    copy = 354835,
                },
                echoing_reprimand_5 = {
                    id = 354838,
                    duration = 45,
                    max_stack = 6,
                },
                echoing_reprimand = {
                    alias = { "echoing_reprimand_2", "echoing_reprimand_3", "echoing_reprimand_4", "echoing_reprimand_5" },
                    aliasMode = "first",
                    aliasType = "buff",
                    meta = {
                        stack = function ()
                            if combo_points.current > 1 and combo_points.current < 6 and buff[ "echoing_reprimand_" .. combo_points.current ].up then return combo_points.current end

                            if buff.echoing_reprimand_2.up then return 2 end
                            if buff.echoing_reprimand_3.up then return 3 end
                            if buff.echoing_reprimand_4.up then return 4 end
                            if buff.echoing_reprimand_5.up then return 5 end

                            return 0
                        end
                    }
                }
            }
        },

        -- Rogue - Necrolord - 328547 - serrated_bone_spike  (Serrated Bone Spike)
        serrated_bone_spike = {
            id = 328547,
            cast = 0,
            charges = function () return legendary.deathspike.equipped and 5 or 3 end,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 3578230,

            toggle = "essences",

            cycle = "serrated_bone_spike",

            cp_gain = function () return ( buff.broadside.up and 1 or 0 ) + active_dot.serrated_bone_spike end,

            handler = function ()
                applyDebuff( "target", "serrated_bone_spike" )
                debuff.serrated_bone_spike.exsanguinated_rate = 1

                if set_bonus.tier28_4pc > 0 and debuff.vendetta.up then
                    debuff.serrated_bone_spike.exsanguinated_rate = 2
                    debuff.serrated_bone_spike.vendetta_exsg = true
                end

                gain( ( buff.broadside.up and 1 or 0 ) + active_dot.serrated_bone_spike, "combo_points" )
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
            end,

            auras = {
                serrated_bone_spike = {
                    id = 324073,
                    duration = 3600,
                    max_stack = 1,
                    exsanguinated = false,
                    meta = {
                        vendetta_exsg = function( t ) return t.up and tracked_bleeds.serrated_bone_spike.vendetta[ target.unit ] or false end,
                        exsanguinated_rate = function( t ) return t.up and tracked_bleeds.serrated_bone_spike.rate[ target.unit ] or 1 end,
                        last_tick = function( t ) return t.up and ( tracked_bleeds.serrated_bone_spike.last_tick[ target.unit ] or t.applied ) or 0 end,
                        tick_time = function( t ) return t.up and ( haste * 2 / t.exsanguinated_rate ) or ( haste * 2 ) end,
                    },
                    copy = "serrated_bone_spike_dot",
                },
            }
        },

        -- Rogue - Night Fae - 328305 - sepsis               (Sepsis)
        sepsis = {
            id = 328305,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            startsCombat = true,
            texture = 3636848,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "sepsis" )
                debuff.sepsis.exsanguinated_rate = 1

                if set_bonus.tier28_4pc > 0 and debuff.vendetta.up then
                    debuff.sepsis.exsanguinated_rate = 2
                    debuff.sepsis.vendetta_exsg = true
                end                
            end,

            auras = {
                sepsis = {
                    id = 328305,
                    duration = function () return ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ) * 10 end,
                    max_stack = 1,
                    exsanguinated = false,
                    meta = {
                        vendetta_exsg = function( t ) return t.up and tracked_bleeds.sepsis.vendetta[ target.unit ] or false end,
                        exsanguinated_rate = function( t ) return t.up and tracked_bleeds.sepsis.rate[ target.unit ] or 1 end,
                        last_tick = function( t ) return t.up and ( tracked_bleeds.sepsis.last_tick[ target.unit ] or t.applied ) or 0 end,
                        tick_time = function( t ) return t.up and ( haste * 2 / t.exsanguinated_rate ) or ( haste * 2 ) end,
                    },
                },
                sepsis_buff = {
                    id = 347037,
                    duration = 5,
                    max_stack = 1
                }
            }
        },

        -- Rogue - Venthyr   - 323654 - flagellation         (Flagellation)
        flagellation = {
            id = 323654,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            spend = 0,
            spendType = "energy",
            
            startsCombat = true,
            texture = 3565724,

            toggle = "essences",

            handler = function ()
                applyBuff( "flagellation" )
                applyDebuff( "target", "flagellation", 30 )
            end,

            auras = {
                flagellation = {
                    id = 323654,
                    duration = 12,
                    max_stack = 30,
                    generate = function( t, aType )
                        local unit, func

                        if aType == "debuff" then
                            unit = "target"
                            func = FindUnitDebuffByID
                        else
                            unit = "player"
                            func = FindUnitBuffByID
                        end
                        
                        local name, _, count, _, duration, expires, caster = func( unit, 323654 )

                        if name then
                            t.count = 1
                            t.expires = expires
                            t.applied = expires - duration
                            t.caster = "player"
                            return
                        end
            
                        t.count = 0
                        t.expires = 0
                        t.applied = 0
                        t.caster = "nobody"
                    end,
                    copy = "flagellation_buff"
                },
            },
        },


        -- PvP Talents
        shadowy_duel = {
            id = 207736,
            cast = 0,
            cooldown = 120,
            gcd = "off",
            
            pvptalent = "shadowy_duel",

            startsCombat = false,
            texture = 1020341,

            usable = function () return target.is_player, "requires a player target" end,
            
            handler = function ()
                applyBuff( "shadowy_duel" )
            end,

            auras = {
                shadowy_duel = {
                    id = 210558,
                    duration = 6,
                    max_stack = 1,
                },        
            }
        },

        smoke_bomb = {
            id = 212182,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            pvptalent = "smoke_bomb",

            startsCombat = false,
            texture = 458733,
            
            handler = function ()
                applyDebuff( "player", "smoke_bomb" )
                if target.within8 then applyDebuff( "target", "smoke_bomb" ) end
            end,

            auras = {
                smoke_bomb = {
                    id = 212183,
                    duration = 5,
                    max_stack = 1,
                },        
            }
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "phantom_fire",

        package = "Assassination",
    } )


    spec:RegisterSetting( "priority_rotation", false, {
        name = "Funnel AOE -> Target",
        desc = "If checked, the addon's default priority list will focus on funneling damage into your primary target when multiple enemies are present.",
        type = "toggle",
        width = 1.5
    } )

    spec:RegisterSetting( "envenom_pool_pct", 50, {
        name = "Energy % for |T132287:0|t Envenom",
        desc = "If set above 0, the addon will pool to this Energy threshold before recommending |T132287:0|t Envenom.",
        type = "range",
        min = 0,
        max = 100,
        step = 1,
        width = 1.5
    } )

    spec:RegisterStateExpr( "envenom_pool_deficit", function ()
        return energy.max * ( ( 100 - ( settings.envenom_pool_pct or 100 ) ) / 100 )
    end )

    spec:RegisterSetting( "mfd_points", 3, {
        name = "|T236340:0|t Marked for Death Combo Points",
        desc = "The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer.",
        type = "range",
        min = 0,
        max = 5,
        step = 1,
        width = "full"
    } )

    spec:RegisterSetting( "solo_vanish", true, {
        name = "Allow |T132331:0|t Vanish when Solo",
        desc = "If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat).",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "allow_shadowmeld", nil, {
        name = "Allow |T132089:0|t Shadowmeld",
        desc = "If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  " ..
            "Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat).",
        type = "toggle",
        width = "full",
        get = function () return not Hekili.DB.profile.specs[ 259 ].abilities.shadowmeld.disabled end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 259 ].abilities.shadowmeld.disabled = not val
        end,
    } )     


    spec:RegisterPack( "Assassination", 20220302, [[diLTLcqiGOhjO0LqsqBIO6taHrbuofqAvQe1ReQAwcQULqL2LK(fsKHHe1XqclJq8mvcMgrHRPsOTriv9nKeLXrifNJOuX6ikY7qsK08qs6EeQ9ji9pIsvQdsuklKqYdfumrvI0ffQOnsiL(iscnsIsvYjrsGvIK6LijQMjrjUjHuzNkj9tIsvmuvIyPeL0tjYuvsCvKeP2krr9vKeXyfQWEvQ)cyWKoSOftLESkMSexgAZi1NPIrRsDAPwnsIeVwL0SPQBlKDR43QA4cCCIsLwoONJy6uUobBxj(UsQXliopq16jkv18fk7h1Bk2RSLkPH7vfHYIicLVaLfPkIiYGczqXwYapa3sb55A6GBPjJWTKSrijH0tA9pBPGeC)NL9kBjYlap4w62SaImrjk502TGB98ruI0rc(06FoWK2OePJouAl5k0EJky2UBPsA4EvrOSiIq5lqzrQIiImOqerZwkfS7hULK6OWSLU7sbNT7wQGKZws2iKKq6jT(hwL13razQfDj8CZQiHZQiuweryQzQdZDooirMyQJlRYwqGhCwbbXG9XabR0(0Hv7zL8riRY2LilSs)WRewTNvsUGSga)dsi94WQ1ryLPoUSEP)acJvzoNMCZQW4rcHvjFFqwZPW6L2hK11T3ZQpjgR(FCqiR2DoSk6sIHqwLncjjKEQm1XLvzf9ziSkA9Pd69P1)WkLyvMXPGMLSsaFoScwtZQmJtbnlzTjSAVJJhlS(00S(qw)H1Kv)poSgMlf0ktDCzv0LxrwfTEKCFGjTXApgcHcbgR9W65JCtJ1MM11iRuPiqmwlDH12yL(HSU8(0ApcqE)cowLPoUSsLMGSkjkjwJEiYQ9SseII(HvQCCPhqqyv2Zl7J(ECyTPzf8xG17Cbz1UrwjVG3TNsLPoUSgMFwqOXkuyqG1pSuPHpXy1EwDfOPRqHbbw)Wcan8jwviOYuhxwLTsblSsL0tHCsiRuj3OrSFWktDCzDL1yEflSgNHqYXrON0qwTNvh0yvGGfwBAwb)faXcYQmJtbnlJljhhHEsdl1TKVjgzVYwIyy6TBSSxzVkf7v2s4KUESSf1wkpw)Zw6a7iYpaggfGeBlvqYb2bw)ZwA125MyP)kcz9hwVWkYeRHb2rKFyDfmkaj2w6aBdHDULS0JJvN252iw6VIWkoPRhlSkNvsa69awcDqJWAOIz9cSkN1Zh5(abFpgH1qfZQmyvoRwcDqRADecypqPrwJlRqmk7HWAOSk632Evr2RSLWjD9yzlQTuES(NTeuiWeG4wQGKdSdS(NT0QTZnXs)veY6pSsXkYeRstgqUFJvzviWeG4w6aBdHDULS0JJvN252iw6VIWkoPRhlSkN1Zh5(abFpgH1qfZQmyvoRwcDqRADecypqPrwJlRqmk7HWAOSk632E1lSxzlHt66XYwuBP8y9pBPG)9aqK8cWdULki5a7aR)zljj4AiKwWbLjwLTGap4S(qwLvKgIKBwx32nRUc00yHvQycHVHKTe9dbgmeBVkfBBVQm2RSLWjD9yzlQTuES(NTKtcHVHBPdSne25wYspowLi4AiKwWbR4KUESWQCwbjRRBVhW)eeadHKJJqpPHSkNvWyfIrzpewPkRuicRuIvmesooc9KgwaGPHSglgRbrcERd8nczLQIzLcwbLv5SAj0bTQ1riG9aLgznUScXOShcRHYQiBPd4hpcyj0bnYEvk22E1lUxzlHt66XYwuBP8y9pBPG)9aqK8cWdULki5a7aR)zljj4AiKwWbznEwJZqioS(dRuSImXQSI0qKCZkvmHW3qwtJv7gzfNcRpnRedtVDZQ9S6GgRrziSweGP1)WQls)qK14mesooc9KgULOFiWGHy7vPyB7vf97v2s4KUESSf1w6aBdHDULS0JJvjcUgcPfCWkoPRhlSkNvl94yvmesooc9KgwXjD9yHv5SMhRxqaCWOgjSkMvkyvoRUc00vIGRHqAbhScXOShcRuLvkQxylLhR)zl5Kq4B4222wAjNMCVxzVkf7v2s4KUESSf1w6d2se02s5X6F2sljStxpULwsVaULaJvqYkuyq6h6G1cM2ThCaYDw(1KkoPRhlSkNvKMgpwVGaNpY9bc(EmcRHkM1taqugcajaNcRGYASyScgRqHbPFOdwlyA3EWbi3z5xtQ4KUESWQCwpFK7de89yewPkRIWkOBPcsoWoW6F2sI2EAYnRRB7M1OmewdZLWk9dzD1252iw6VIWWzvy8iHWQaPhhwVumTBp4SkDNLFnzlTKqGjJWT00o3gXs)vecCcao)uAR)zB7vfzVYwcN01JLTO2s5X6F2sl50K7Tubjhyhy9pBjzoNMCZ662UznodH4WA8SUA7CBel9xrOmXQOldPJeIynmxcR5uynodH4WkeZc4Ss)qwhmeJvQyyU0T0b2gc7ClzPhhRIHqYXrON0WkoPRhlSkNvl94y1PDUnIL(RiSIt66XcRYzDjHD66X60o3gXs)vecCcao)uAR)Hv5SE(3x(1tfdHKJJqpPHvigL9qyLQSsX22REH9kBjCsxpw2IAlLhR)zlTKttU3sfKCGDG1)SLK5CAYnRRB7M1vBNBJyP)kcznEwx9znodH4itSk6Yq6iHiwdZLWAofwLzCkOzjRcbBPdSne25wYspowDANBJyP)kcR4KUESWQCwbjRw6XXQyiKCCe6jnSIt66XcRYzDjHD66X60o3gXs)vecCcao)uAR)Hv5SwqxbA66cof0SSkeST9QYyVYwcN01JLTO2s5X6F2sb)7bGi5fGhClHHyWeiJEHX2sY4IBj6hcmyi2Evk22E1lUxzlHt66XYwuBPdSne25wYspowLi4AiKwWbR4KUESWQCwp)7l)6P6Kq4ByviGv5SwqxbA66cof0SSkeWQCwbJ1YBvNecFdRqKgIK701JSglgRL3Qoje(gwdIe8wh4BeYkvfZkfSckRYz98rUpqW3JrQfKUpTXAOIzfmwjbO3dyj0bnsLohGNg460liH1qL9MvzWkOSkNvy2faCbhRMLcP2dRHYkfISLYJ1)SLwYPj3BBVQOFVYwcN01JLTO2s5X6F2sl50K7Tubjhyhy9pBjzoNMCZ662Uzv0LedHSkBess6rMyvwfcmbigpvmHW3qwN3yThwHinej3ScZXbdN1IaShhwLzCkOzz8s39sLvjWNdRRB7MvjmG0ewP7j9SE3gRnnRbpH0UESULoW2qyNBjWy1spownkjgcbscjjKEQ4KUESWASyScfgK(HoynkHxbEAa7gbIsIHqGKqscPNkoPRhlSckRYzfKSwERcfcmbiwHinej3PRhzvoRL3Qoje(gwHyu2dH1qz9cSkN1c6kqtxxWPGMLvHawLZkySwqxbA6k5UxQcbSglgRf0vGMUUGtbnlRqmk7HWkvzvgSglgRL3QemG0KQ1NR94WkOSkN1YBvcgqAsfIrzpewPkRxyBBBlvq6uWB7v2RsXELTuES(NT01(CDlHt66XYwuBBVQi7v2s4KUESSf1wQGKdSdS(NTKSIedtVDZAtZAWtiTRhzfS5zDrWpimD9iR4GrnsyThwpFKBAGULYJ1)SLigME7EB7vVWELTeoPRhlBrTL(GTebTTuES(NT0sc701JBPL0lGBjsa69awcDqJuPZb4PbUo9csyLQSkYwAjHatgHBjspoEeWsOdABBVQm2RSLWjD9yzlQT0hSLiOTLYJ1)SLwsyNUEClTKEbClHdcDaVcrhCaoFKBpyH1qz9cxClvqYb2bw)ZwkmFKBpyH14CqOd4SkROdoSoiwWcR2ZkjnbyA4wAjHatgHBji6GdajnbyAyzB7vV4ELTeoPRhlBrTLoW2qyNBjIHP3UXsf(oc4wIyW(y7vPylLhR)zlDsVhipw)dGVj2wY3edyYiClrmm92nw22Evr)ELTeoPRhlBrTLYJ1)SLoP3dKhR)bW3eBl5BIbmzeULofY22RsLTxzlHt66XYwuBP8y9pBjIVpiqofGsFWTubjhyhy9pBPlrWyvAUuwfcyTN2607bNv6hYAyemwTNv7gznm3jbdNvisdrYnRRB7M14CwW5JyTPznnw9)AwlcW06F2shyBiSZTeiz1vGMUs89bbYPau6dwfcyvoRNpY9bc(EmcRHkMvk22EvrZELTeoPRhlBrTLoW2qyNBjxbA6kX3heiNcqPpyviGv5S6kqtxj((Ga5uak9bRqmk7HWkvz9ISkN1Zh5(abFpgH1qfZQm2s5X6F2s4SGZhTT9QYo7v2s4KUESSf1wkpw)Zw6KEpqES(haFtSTKVjgWKr4wQ8222RsbL3RSLWjD9yzlQTuES(NT0j9EG8y9pa(MyBjFtmGjJWTuPH4X22EvkOyVYwcN01JLTO2shyBiSZTeoi0b8AbP7tBSgQywP4ISgpR4GqhWRq0bhGZh52dw2s5X6F2sj8KdcypeIJTT9QuiYELTuES(NTucp5GabcEcULWjD9yzlQTTxLIlSxzlLhR)zl5BNBJaqLIqXjchBlHt66XYwuBBVkfYyVYwkpw)ZwYnDaEAad2NRKTeoPRhlBrTTTTLcG45JCtBVYEvk2RSLYJ1)SLYGap4abFt(zlHt66XYwuBBVQi7v2s5X6F2sUVzESaq7tWXY6ECaSpKE2s4KUESSf122REH9kBjCsxpw2IAlLhR)zlfLWRybG(HafmT7T0b2gc7Clbswp)co5y1fCSBWHSkNvy2faCbhRMLcP2dRHYkfxClfaXZh5Mgabp)uiBjkO822RkJ9kBjCsxpw2IAlDGTHWo3sKxW72tPgiqmbpcGqHaR)PIt66XcRXIXk5f8U9uQlVpT2JaK3VGJvXjD9yzlLhR)zlr7rY9bM0222REX9kBjCsxpw2IAl9bBjcABP8y9pBPLe2PRh3slPxa3suWACzfmwHcds)qhSweixxN(RiKaeK25UIt66XcRxMvWyLYvzCrwJNvWyLGgG7pcKQ1iuerdGmcoSEzwPCLcwbLvqzf0T0scbMmc3sl4uqZsGtbUT9QI(9kBjCsxpw2IAl9bBjcABP8y9pBPLe2PRh3slPxa3suWACzfmwHcds)qhS(UyPX5GvCsxpwy9YSs5QmKbRGULki5a7aR)zlTYnYAUGW0bznmxQSYAtyLYvreHvxbJ1IaYQ9SA3iRY6QurwN0eGiRpnRH5sy1bNWzvKqy1UBcRlPxazTjS(bwhLEwPFiReWNtpoS6FN(SLwsiWKr4wI2NoO3Nw)dWPa32EvQS9kBjCsxpw2IAl9bBjcABP8y9pBPLe2PRh3sljeyYiClzWEUIgab85aq8VTLoW2qyNBjd2Zv0Qgf17KaqS0Q5aoqjGWQCwbJvqYQb75kAvtK6DsaiwA1CahOeqynwmwnypxrRAuup)7l)6PweGP1)WAOIz1G9CfTQjs98VV8RNAraMw)dRGYASySAWEUIw1OO2KApKduWsxpci7kKJjebuWL(GSglgRGXQb75kAvJIAtQK7S8RDGjjaWEdJyvoRNFbNCS6co2n4qwbDlvqYb2bw)Zw6srdHr9GSU(Up3ScwtZAoGdkRelnwDfOPz1G9CfnwxJSUohJv7znndJcmwTNvc4ZH11TDZQmJtbnlRBPL0lGBjk22EvrZELTeoPRhlBrTL(GTebTTuES(NT0sc701JBPL0lGBjr2shyBiSZTKb75kAvtK6DsaiwA1CahOeqyvoRGXkiz1G9CfTQrr9ojaelTAoGduciSglgRgSNROvnrQN)9LF9ulcW06FynuwnypxrRAuup)7l)6PweGP1)WkOSglgRgSNROvnrQnP2d5afS01JaYUc5ycrafCPpiRXIXkySAWEUIw1eP2Kk5ol)AhyscaS3WiwLZ65xWjhRUGJDdoKvq3sljeyYiClzWEUIgab85aq8VTT9QYo7v2s5X6F2sedtVDVLWjD9yzlQTTxLckVxzlHt66XYwuBP8y9pBjIVpiqofGsFWT0b2gc7ClbswT0JJvN252iw6VIWkoPRhlSkNvisdrYD66XTuaepFKBAae88tHSLOyBBBlvAiES9k7vPyVYwcN01JLTO2s5X6F2s4SGZhTLki5a7aR)zlfNZcoFeRPXQmINvWUy8SUUTBwVujqznmxsLvQGOiS0PHEWz9hwfjEwTe6GgjCwx32nRYmof0SmCwFiRRB7M1vev4S(2ncx3eK11zBSs)qwjFeYkoi0b8kRYMN8SUoBJ1MM14meIdRNpY9zTjSE(OECyviOULoW2qyNBjKMgpwVGaNpY9bc(EmcRHkMvzWA8SAPhhRwqmaHaedMw6GrvCsxpwyvoRGXAbDfOPRl4uqZYQqaRXIXAbDfOPRK7EPkeWASySwqxbA6kTpDqVpT(NQqaRXIXkoi0b8AbP7tBSsvXSkYfznEwXbHoGxHOdoaNpYThSWASyScswxsyNUESs6XXJawcDqJ1yXyfPPXJ1liW5JCFGGVhJWAOSEcaIYqaib4uyfuwLZkyScswT0JJvXqi54i0tAyfN01JfwJfJ1Z)(YVEQyiKCCe6jnScXOShcRHYQiSc622RkYELTeoPRhlBrTL(GTebTTuES(NT0sc701JBPL0lGBPZh5(abFpgPwq6(0gRHYkfSglgR4GqhWRfKUpTXkvfZQixK14zfhe6aEfIo4aC(i3EWcRXIXkizDjHD66XkPhhpcyj0bTT0scbMmc3sceeGU9EeUT9QxyVYwcN01JLTO2s5X6F2seectdlaU)GaKG(kULki5a7aR)zljBbbEWzvsusSApRP3ZQLqh0iSUUT7xWynzTGUc00SMewdG9dBd8WznaI0ie2JdRwcDqJWAb8ECyL8)GqwtAdHSA3iRbWokHGZQLqh02shyBiSZT0sc701Jvbccq3EpczvoRGK1YBvccHPHfa3FqasqFfbkVvT(CThNTTxvg7v2s4KUESSf1wkpw)ZwIGqyAybW9heGe0xXT0b2gc7ClTKWoD9yvGGa0T3JqwLZkizT8wLGqyAybW9heGe0xrGYBvRpx7XzlDa)4ralHoOr2RsX22REX9kBjCsxpw2IAlLhR)zlrqimnSa4(dcqc6R4wQGKdSdS(NTevoIbSsd)iwpzqqpoSEUtOdsy9HS6kahwtJv7gzfNcRpnR0TZTr2shyBiSZT0sc701Jvbccq3EpczvoRrjXqiqsijH0daeJYEiSsvwPCv0WQCwbJv3NqyvoR0TZTbaXOShcRuvmRxK1yXy98VV8RNkbHW0WcG7piajOVI1OmeGZDcDqcRXL1ZDcDqcanmpw)t6zLQIzLYvrUiRGUT9QI(9kBjCsxpw2IAlLhR)zlrqimnSa4(dcqc6R4wQGKdSdS(NTevYnoSk6KnwBcRZBSMgR3TZnRfbyA9pHZkb85W662UzTKrPdYQRannH11TD)cgR)ccxdBRhhwLfmlS6coRXzizuGh3shyBiSZTeizLGgG7pcKQ1iuerdGibhwLZ6sc701Jvbccq3EpczvoRrjXqiqsijH0daeJYEiSsvwPCv0WQCwbJvYl4D7Pu9ywaCbhadjJc8yfN01JfwLZkiz1vGMU6XSa4coagsgf4XQqaRYzTGUc001fCkOzzviG1yXy1vGMUgLq4VglaoyeX(bbW5oNdgHJvfcynwmwbjRljStxpwj944ralHoOXQCwlORanDLC3lvHawbDB7vPY2RSLWjD9yzlQT0b2gc7ClrqdW9hbs1AekIObqKGdRYzDjHD66XQabbOBVhHSkN1OKyieijKKq6baIrzpewPkRuUkAyvoRf0vGMU6afkoiquAN7QqaRYzfKS6kqtx9ywaCbhadjJc8yviGv5ScZUaGl4y1Sui1EynuwV4wkpw)ZwIGqyAybW9heGe0xXTTxv0SxzlHt66XYwuBP8y9pBjccHPHfa3FqasqFf3s(EqGtzlrXf3shyBiSZTe5f8U9uQxXLEia)l7J(ECQ4KUESWQCwDfOPRxXLEia)l7J(ECQLF9SLki5a7aR)zlrLMGSkjkjwTNvIqu0pSsLJl9accRYEEzF03JdRnnRG)cSENliR2nYk5f8U9uQBBVQSZELTeoPRhlBrTLYJ1)SLOZb4PbUo9cs2sfKCGDG1)SLeT5W6tZkv(0liH10yLczN4zLy55kH1NMvzV6sbhwfLpliH1hYA6K9qmwLr8SAj0bnsDlDGTHWo3sljStxpwfiiaD79iKv5ScgRUc0017UuWbW1NfKujwEUYAOIzLczhwJfJvWyfKSga7h2g4aW3sR)Hv5SscqVhWsOdAKkDoapnW1PxqcRHkMvzWA8Ssmm92nwQW3razfuwbDB7vPGY7v2s4KUESSf1wkpw)ZwIohGNg460lizlvqYb2bw)Zws0MdRpnRu5tVGewTN1miWdoRbFt(HWAtZAp5X6fK1FynhWz1sOdASc2dznhWz11JyPhhwTe6GgH11TDZAaSFyBGZk8T06FaL10y9cRSLoW2qyNBP8y9ccuERwWS4bhi4BYpaL3yLQSMhRxqaCWOgjSkNvWyfKSga7h2g4aW3sR)H1yXyT8w1jHW3WQ1NR94WASySwERcfcmbiwT(CThhwbLv5SUKWoD9yvGGa0T3JqwLZkja9EalHoOrQ05a80axNEbjSgQywVW22Rsbf7v2s4KUESSf1w6aBdHDULwsyNUESkqqa627riRYz98VV8RN6cof0SScXOShcRHYkfuElLhR)zlHN7Vhhaiga7OCkBBVkfISxzlHt66XYwuBPdSne25wAjHD66XQabbOBVhHSkNvWynkjgcbscjjKEaGyu2dHvXSszwLZkizfkmi9dDWA5)ixFwWkoPRhlSglgRUc00vxFpfsxWQqaRGULYJ1)SLYixbY922RsXf2RSLWjD9yzlQTuES(NTuKG1(0WT0b8JhbSe6GgzVkfBPdSne25wAjHD66XQabbOBVhHSkNvsa69awcDqJuPZb4PbUo9csyvmRISLki5a7aR)zlTs6gxrNG1(0qwTN1miWdoRxkMfp4SEjFt(H10yvewTe6GgzB7vPqg7v2s4KUESSf1w6aBdHDULwsyNUESkqqa627r4wkpw)ZwksWAFA4222w6ui7v2RsXELTeoPRhlBrTLYJ1)SLIs4vSaq)qGcM29wY3dcCkBjkQxClDa)4ralHoOr2RsXw6aBdHDULGzxaWfCSAwkKQqaRYzfmwbjRljStxpwj944ralHoOXASySAj0bTQ1riG9aLgzLQSEbkZkOSkNvWy1sOdAvRJqa7bknYkvz98rUpqW3JrQfKUpTX6LzLI6fznwmwpFK7de89yKAbP7tBSgQywpbarziaKaCkSc6wQGKdSdS(NTevanRzPqynHiRcbHZkz6aKv7gz9hK11TDZQ)xJeJ1vw5sRSsLMGSU(ghwlG3JdR0jXqiR2DoSgMlH1cs3N2y9HSUUT7xWynhWznmxsDB7vfzVYwcN01JLTO2s5X6F2srj8kwaOFiqbt7ElvqYb2bw)ZwIkGM15znlfcRRBVN1sJSUUT7Ey1UrwhmeJ1lqzs4SkqqwfD0xkR0pK1OmewdZLuzv2mdJcmwTNvc4ZH11TDZQO1NoO3Nw)dRnnRbpH0UESULoW2qyNBjy2faCbhRMLcP2dRHY6fOmRXLvy2faCbhRMLcPweGP1)WQCwpFK7de89yKAbP7tBSgQywpbarziaKaCkSkNvqY65FF5xpvYDVuHywaNv5ScgRGK1ZVGtowDbh7gCiRXIXAbDfOPR0(0b9(06FQcbSglgRN)9LF9uP9Pd69P1)uHyu2dH1qzLIlYkOBBV6f2RSLWjD9yzlQT0hSLiOTLYJ1)SLwsyNUEClTKEbClbswT0JJvN252iw6VIWkoPRhlSglgRGKvl94yvmesooc9KgwXjD9yH1yXy98VV8RNkgcjhhHEsdRqmk7HWkvz9ISgxwfH1lZQLECSAbXaecqmyAPdgvXjD9yzlvqYb2bw)Zwsc85WQmJtbnlzDDpLFnRRB7M1vBNBJyP)kcJpodHKJJqpPHS20SMbb((KUEClTKqGjJWT0cof0SeyANBJyP)kcbo)uAR)zB7vLXELTeoPRhlBrTL(GTebTTuES(NT0sc701JBPL0lGBjqYQLECSAusmecKessi9uXjD9yH1yXyT8w1jHW3WQ1NR94WASySE(fCYXQl4y3GdzvoRNpY9bc(EmsTG09PnwfZkL3sfKCGDG1)SLOsY2y9hwLzCkOzjR0pKvQycHVHSUUTBwfDYw4SkmEKqyDnYAcrwtJ1OmewdZLWk9dzv06th07tR)zlTKqGjJWT0cof0Seikbo)uAR)zB7vV4ELTeoPRhlBrTL(GTebTTuES(NT0sc701JBPLecmzeULwWPGMLaNFbNCmGZpL26F2shyBiSZT05xWjhREfCyNdRXIX65xWjhRo4b((hwynwmwp)co5y15hClvqYb2bw)Zwsc85WQmJtbnlzDDB3SkA9Pd69P1)WAofwLWastynjS6)XH1KW6AK11)acJv)tqwtwpjXy9xqiR2nYkD7CBSweGP1)SLwsVaULOyB7vf97v2s4KUESSf1w6d2se02s5X6F2sljStxpULwsVaULO9)dzfmwbJv6252aGyu2dH14YQiuMvqzLsScgRuicLz9YSUKWoD9yDbNcAwcCkqwbLvqznuwP9)dzfmwbJv6252aGyu2dH14YQiuM14Y65FF5xpvAF6GEFA9pvigL9qyfuwPeRGXkfIqzwVmRljStxpwxWPGMLaNcKvqzfuwJfJvxbA6kTpDqVpT(haxbA6QqaRXIXAbDfOPR0(0b9(06FQcbSglgRUpHWQCwPBNBdaIrzpewPkRIq5T0b2gc7ClD(fCYXQl4y3Gd3sljeyYiClTGtbnlbo)co5yaNFkT1)ST9Quz7v2s4KUESSf1w6d2se02s5X6F2sljStxpULwsVaULO9)dzfmwbJv6252aGyu2dH14YQiuMvqzLsScgRuicLz9YSUKWoD9yDbNcAwcCkqwbLvqznuwP9)dzfmwbJv6252aGyu2dH14YQiuM14Y65FF5xpvcgqAsfIrzpewbLvkXkySsHiuM1lZ6sc701J1fCkOzjWPazfuwbL1yXyT8wLGbKMuT(CThhwJfJv3NqyvoR0TZTbaXOShcRuLvrO8w6aBdHDULo)co5y1PDUna6e3sljeyYiClTGtbnlbo)co5yaNFkT1)ST9QIM9kBjCsxpw2IAlvqYb2bw)Zws06rY9bM0gR0pK1lrGycEK14ekey9pS20SoVXkXW0B3yH1hYApSMSE(3x(1dRhWpEClDGTHWo3sGXk5f8U9uQbcetWJaiuiW6FQ4KUESWASySsEbVBpL6Y7tR9ia59l4yvCsxpwyfuwLZkizLyy6TBSutVNv5ScswlORanDDbNcAwwfcyvoRrjXqiqsijH0daeJYEiSkMvkZQCwbJvCqOd4vRJqa7bIYqaoFKBpyH1qzvewJfJvqYAbDfOPRK7EPkeWkOBPEmecfcmGMElrEbVBpL6Y7tR9ia59l4yBPEmecfcmGokclDA4wIITuES(NTeThj3hysBBPEmecfcmah)7M(TefBBVQSZELTeoPRhlBrTLYJ1)SLO9Pd69P1)SLki5a7aR)zljb(Cyv06th07tR)H11TDZQmJtbnlznjS6)XH1KW6AK11)acJv)tqwtwpjXy9xqiR2nYkD7CBSweGP1)WkypK1MMvzgNcAwY6627z98riRU55kRPt2dLAcR2744XcRpnnO1T0b2gc7ClbswjgME7glv47iGSkNvWy98VV8RN6cof0SScXOShcRuL1lWQCwxsyNUESUGtbnlbIsGZpL26FyvoRinnESEbboFK7de89yewdvmRYGv5SAj0bTQ1riG9aLgznuwPGYSglgRf0vGMUUGtbnlRcbSglgRUpHWQCwPBNBdaIrzpewPkRIidwbDB7vPGY7v2s4KUESSf1w6aBdHDULajRedtVDJLk8DeqwLZkstJhRxqGZh5(abFpgH1qfZQmyvoRGXkT)FiRGXkySs3o3gaeJYEiSgxwfrgSckRuIvWynpw)dW5FF5xpSEzwxsyNUESs7th07tR)b4uGSckRGYAOSs7)hYkyScgR0TZTbaXOShcRXLvrKbRXL1Z)(YVEQl4uqZYkeJYEiSEzwxsyNUESUGtbnlbofiRGYkLyfmwZJ1)aC(3x(1dRxM1Le2PRhR0(0b9(06FaofiRGYkOSc6wkpw)ZwI2NoO3Nw)Z22Rsbf7v2s4KUESSf1wkpw)ZwIGbKMSLki5a7aR)zljb(CyvcdinH11TDZQmJtbnlznjS6)XH1KW6AK11)acJv)tqwtwpjXy9xqiR2nYkD7CBSweGP1)eoRUcgRbqKgHSAj0bncR2DASUU9Ew99cYAAS6XKySsbLjBPdSne25wcKSsmm92nwQW3razvoRL3Qoje(gwT(CThhwLZkySE(3x(1tDbNcAwwHyu2dHvQYkfSkNvlHoOvTocbShO0iRHYkfuM1yXyTGUc001fCkOzzviG1yXy19jewLZkD7CBaqmk7HWkvzLckZkOBBVkfISxzlHt66XYwuBPdSne25wcKSsmm92nwQW3razvoRGXkT)FiRGXkySs3o3gaeJYEiSgxwPGYSckRuI18y9paN)9LF9WkOSgkR0()HScgRGXkD7CBaqmk7HWACzLckZACz98VV8RN6cof0SScXOShcRxM1Le2PRhRl4uqZsGtbYkOSsjwZJ1)aC(3x(1dRGYkOBP8y9pBjcgqAY22RsXf2RSLWjD9yzlQT0b2gc7ClbswjgME7glv47iGSkN1YBvOqGjaXQ1NR94WQCwbjRf0vGMUUGtbnlRcbSkN1Le2PRhRl4uqZsGPDUnIL(Rie48tPT(hwLZ6sc701J1fCkOzjqucC(P0w)dRYzDjHD66X6cof0Se48l4KJbC(P0w)Zwkpw)ZwAbNcAwUT9QuiJ9kBjCsxpw2IAlLhR)zlHHqYXrON0WTubjhyhy9pBP4mesooc9KgY66BCyDEJvIHP3UXcR5uy19TBwLvHataISMtHvQycHVHSMqKvHawPFiR(FCyfNxW5UULoW2qyNBjqYkXW0B3yPcFhbKv5ScgRGK1YBvNecFdRqKgIK701JSkN1YBvOqGjaXkeJYEiSgkRYG14zvgSEzwpbarziaKaCkSglgRL3QqHataIvigL9qy9YSs56fznuwTe6Gw16ieWEGsJSckRYz1sOdAvRJqa7bknYAOSkJTTxLIlUxzlHt66XYwuBP8y9pBjYDVSLki5a7aR)zljD3lS20SEP)kewtiYQqq4S20SUA7CBSkAtK10mmkWy1EwjGphwx32nRsyaPjS(qwLzCkOzjRnnRRrwx)dimwxNedzn6HiR2DoSENEAwLU7fqqy98VV8RNT0b2gc7ClbswlORanDLC3lvHawLZkySwER6Kq4By16Z1ECyvoRL3QqHataIvRpx7XHvqzvoRGXkiz98l4KJvN252aOtK1yXyfmwbJ1Z)(YVEQemG0KkeZc4SglgRN)9LF9ujyaPjvigL9qynuwPqewbL14zfmwp)7l)6PUGtbnlRqmlGZASySE(3x(1tDbNcAwwHyu2dH1lZ6sc701J1fCkOzjWPaznuwPqewbLvXSkcRGYkOBBVkfI(9kBjCsxpw2IAlDGTHWo3sUc00vx))fVaXQqmpgRXIXQ7tiSkNv6252aGyu2dHvQY6fOmRXIXAbDfOPRl4uqZYQqWwkpw)Zwk4T(NTTxLcQS9kBjCsxpw2IAlDGTHWo3sf0vGMUUGtbnlRcbBP8y9pBjx))faAbi4BBVkfIM9kBjCsxpw2IAlDGTHWo3sf0vGMUUGtbnlRcbBP8y9pBjxesq41EC22EvkKD2RSLWjD9yzlQT0b2gc7ClvqxbA66cof0SSkeSLYJ1)SLOBi66)VST9QIq59kBjCsxpw2IAlDGTHWo3sf0vGMUUGtbnlRcbBP8y9pBPCoiXGPh4KE)22Rkcf7v2s4KUESSf1w6aBdHDULajRedtVDJLA69SkN1OKyieijKKq6baIrzpewfZkL3s5X6F2sN07bYJ1)a4BITL8nXaMmc3sl50K7TTxver2RSLWjD9yzlQTuES(NT06EkKtcbwFJgX(b3shyBiSZTeja9EalHoOrQ05a80axNEbjSgkRfK0qSayj0bncRXIXkm7caUGJvZsHu7H1qzv0tzwJfJv3NqyvoR0TZTbaXOShcRuLvQST0Kr4wADpfYjHaRVrJy)GBBVQixyVYwcN01JLTO2s5X6F2sgSNROrXwQGKdSdS(NTKe4ZHv7gzna2pSnWzLyPXQRannRgSNROX662UzvMXPGMLHZ6B3iCDtqwfiiR)W65FF5xpBPdSne25wAjHD66XQb75kAaeWNdaX)gRIzLcwLZkySwqxbA66cof0SSkeWASyS6(ecRYzLUDUnaigL9qyLQIzvekZkOSglgRGX6sc701Jvd2Zv0aiGphaI)nwfZQiSkNvqYQb75kAvtK65FF5xpviMfWzfuwJfJvqY6sc701Jvd2Zv0aiGphaI)TTTxvezSxzlHt66XYwuBPdSne25wAjHD66XQb75kAaeWNdaX)gRIzvewLZkySwqxbA66cof0SSkeWASyS6(ecRYzLUDUnaigL9qyLQIzvekZkOSglgRGX6sc701Jvd2Zv0aiGphaI)nwfZkfSkNvqYQb75kAvJI65FF5xpviMfWzfuwJfJvqY6sc701Jvd2Zv0aiGphaI)TTuES(NTKb75kAISTTTLkVTxzVkf7v2s4KUESSf1w6d2se02s5X6F2sljStxpULwsVaULcG9dBdCa4BP1)WQCwbJ1YBvNecFdRqmk7HWkvz98VV8RNQtcHVH1IamT(hwJfJ1Le2PRhRq0bhasAcW0WcRGULki5a7aR)zljlDuBSsWZpLecoRuXecFdjSs)qwdG9dBdCwHVLw)dRnnRRrwVZfK1lCrwXbHoGZkeDWH1hYkvmHW3qwx3EpRyibnez9hwTBK1ayhLqWz1sOdABPLecmzeULix7aGd4hpc4Kq4B422RkYELTeoPRhlBrTL(GTebTTuES(NT0sc701JBPL0lGBPay)W2aha(wA9pSkNvWyTGUc00vYDVufcyvoRKa07bSe6GgPsNdWtdCD6fKWAOSkcRXIX6sc701Jvi6GdajnbyAyHvq3sfKCGDG1)SLKLoQnwj45NscbNvzviWeGiHv6hYAaSFyBGZk8T06FyTPzDnY6DUGSEHlYkoi0bCwHOdoS(qwLU7fwBcRcbS(dRISs8BPLecmzeULix7aGd4hpcafcmbiUT9QxyVYwcN01JLTO2sFWwIG2wkpw)ZwAjHD66XT0s6fWTubDfOPRl4uqZYQqaRYzfmwlORanDLC3lvHawJfJ1OKyieijKKq6baIrzpewdLvkZkOSkN1YBvOqGjaXkeJYEiSgkRISLki5a7aR)zljlDuBSkRcbMaejS20SkZ4uqZY4LU7fkj6sIHqwLncjjKEyTjSkeWAofwxJSENliRIepRe88tHWQhPnw)Hv7gzvwfcmbiY6L(RSLwsiWKr4wICTdaGcbMae32EvzSxzlHt66XYwuBP8y9pBjNecFd3sfKCGDG1)SLKcWtNEwPIje(gYAofwLvHataISsqtiG1ay)qwTN14mesooc9KgY6jj2w6aBdHDULS0JJvXqi54i0tAyfN01JfwLZkizDD79a(NGayiKCCe6jnKv5SwER6Kq4BynisWBDGVriRuvmRuWQCwp)7l)6PIHqYXrON0WkeJYEiSsvwfHv5SscqVhWsOdAKkDoapnW1PxqcRIzLcwLZkm7caUGJvZsHu7H1qzv0ZQCwlVvDsi8nScXOShcRxMvkxViRuLvlHoOvTocbShO0422REX9kBjCsxpw2IAlDGTHWo3sw6XXQyiKCCe6jnSIt66XcRYzfmwrAA8y9ccC(i3hi47XiSgQywpbarziaKaCkSkN1Z)(YVEQyiKCCe6jnScXOShcRuLvkyvoRL3QqHataIvigL9qy9YSs56fzLQSAj0bTQ1riG9aLgzf0TuES(NTeuiWeG422Rk63RSLWjD9yzlQTuES(NTuW)EaisEb4b3sfKCGDG1)SLOIje(gYQqWvedcN10tEwnyJewTNvbcYABSMewtwjb4PtpRo4GW0EiR0pKv7gz1NeJ1WCjS6I0peznzLUNMCJWTe9dbgmeBVkfBBVkv2ELTeoPRhlBrTLoW2qyNBjisdrYD66rwLZ65JCFGGVhJuliDFAJ1qfZkfSkNvWynisWBDGVriRuvmRuWASyScXOShcRuvmRwFUcyDeYQCwjbO3dyj0bnsLohGNg460liH1qfZ6fyfuwLZkyScswx3EpG)jiagcjhhHEsdznwmwHyu2dHvQkMvRpxbSocz9YSkcRYzLeGEpGLqh0iv6CaEAGRtVGewdvmRxGvqzvoRGXQLqh0QwhHa2duAK14YkeJYEiSckRHYQmyvoRrjXqiqsijH0daeJYEiSkMvkVLYJ1)SLCsi8nCB7vfn7v2s4KUESSf1wI(HadgITxLITuES(NTuW)EaisEb4b32EvzN9kBjCsxpw2IAlLhR)zl5Kq4B4w6aBdHDULajRljStxpwjx7aGd4hpc4Kq4BiRYzfI0qKCNUEKv5SE(i3hi47Xi1cs3N2ynuXSsbRYzfmwdIe8wh4BeYkvfZkfSglgRqmk7HWkvfZQ1NRawhHSkNvsa69awcDqJuPZb4PbUo9csynuXSEbwbLv5ScgRGK11T3d4FccGHqYXrON0qwJfJvigL9qyLQIz16ZvaRJqwVmRIWQCwjbO3dyj0bnsLohGNg460liH1qfZ6fyfuwLZkySAj0bTQ1riG9aLgznUScXOShcRGYAOSsHiSkN1OKyieijKKq6baIrzpewfZkL3shWpEeWsOdAK9QuST9Quq59kBjCsxpw2IAlLhR)zlDGDe5hadJcqITLoGF8iGLqh0i7vPylDGTHWo3sKa07bSe6GgH1qfZQiSkNvKMgpwVGaNpY9bc(EmcRHkMvzWQCwXbHoGxHOdoaNpYThSWAOSkcLzvoRGXkiz98VV8RN6cof0SScXSaoRXIXA5TkuiWeGy16Z1ECyfuwLZkeJYEiSsvwfH14z9cSEzwbJvsa69awcDqJWAOIzvgSc6wQGKdSdS(NTuyGDe5hwxbJcqIX6pSgj4ToWJSAj0bncRPXQmIN1WCjSU(ghwHcZ0JdRVGXApSksCViH1KWQ)hhwtcRRrwVZfKvCEbNBwHOdoSMtH1eIdimwjOz94WQqaR0pKvzgNcAwUT9QuqXELTeoPRhlBrTLYJ1)SLGcbMae3sfKCGDG1)SLOYrmGvHawLvHataISMgRYiEw)H107z1sOdAewbB9noS67LECy1)JdR48co3SMtH15nwjtgqUFd0T0b2gc7ClbswxsyNUESsU2baqHataISkNvKMgpwVGaNpY9bc(EmcRHkMvzWQCwHinej3PRhzvoRGXAqKG36aFJqwPQywPG1yXyfIrzpewPQywT(CfW6iKv5SscqVhWsOdAKkDoapnW1PxqcRHkM1lWkOSkNvWyfKSUU9Ea)tqamesooc9KgYASyScXOShcRuvmRwFUcyDeY6LzvewLZkja9EalHoOrQ05a80axNEbjSgQywVaRGYQCwTe6Gw16ieWEGsJSgxwHyu2dH1qzfmwLbRXZkyScfgK(HoyTKK7ECaiNxykq0xXjD9yH1lZ6fzfuwJNvWyfkmi9dDWA5)ixFwWkoPRhlSEzwViRGYA8ScgRljStxpwHOdoaK0eGPHfwVmRIEwbLvq32EvkezVYwcN01JLTO2s5X6F2sqHataIBPdSne25wcKSUKWoD9yLCTdaoGF8iauiWeGiRYzfKSUKWoD9yLCTdaGcbMaezvoRinnESEbboFK7de89yewdvmRYGv5ScrAisUtxpYQCwbJ1GibV1b(gHSsvXSsbRXIXkeJYEiSsvXSA95kG1riRYzLeGEpGLqh0iv6CaEAGRtVGewdvmRxGvqzvoRGXkizDD79a(NGayiKCCe6jnK1yXyfIrzpewPQywT(CfW6iK1lZQiSkNvsa69awcDqJuPZb4PbUo9csynuXSEbwbLv5SAj0bTQ1riG9aLgznUScXOShcRHYkySkdwJNvWyfkmi9dDWAjj394aqoVWuGOVIt66XcRxM1lYkOSgpRGXkuyq6h6G1Y)rU(SGvCsxpwy9YSErwbL14zfmwxsyNUEScrhCaiPjatdlSEzwf9SckRGULoGF8iGLqh0i7vPyB7vP4c7v2s4KUESSf1wkpw)Zw6a7iYpaggfGeBlvqYb2bw)Zws0MEVBEUYQS9XjRHb2rKFyDfmkajgRRB7Mv7gzLKriR(3PpSMewt3FbdNvxbJ12zEypoSA3iR4GqhWz98tPT(hcRnnRRrwtioGWyvG0JdRYQqGjaXT0b2gc7ClrcqVhWsOdAewdvmRIWQCwrAA8y9ccC(i3hi47XiSgQywLbRYzfIrzpewPkRIWA8SEbwVmRGXkja9EalHoOrynuXSkdwbDB7vPqg7v2s4KUESSf1wkpw)Zw6a7iYpaggfGeBlvqYb2bw)ZwkmWoI8dRRGrbiXy9hwLwH1MM1EyniNcg1hwZPW6Gj0doRrziSIdcDaN1CkS20SgNZcoFeRR)begRLN1OhISwYO0bzTiGSApRRikkj6KTT0b2gc7ClrcqVhWsOdAewfZkfSkNvWyfKScfgK(HoyTKK7ECaiNxykq0xXjD9yH1yXy1vGMUcfgey9dla0WNyvHawbLv5SgLedHajHKespaqmk7HWQywPmRYzfPPXJ1liW5JCFGGVhJWAOIzfmwpbarziaKaCkSgxwPGvqzvoRqKgIK701JSkNvqY6627b8pbbWqi54i0tAiRYzfmwbjRf0vGMUsU7LQqaRXIXAbDfOPRoqHIdceL25UcXOShcRHYQiSckRYz1sOdAvRJqa7bknYACzfIrzpewdLvzSTTTTT0ccj9p7vfHYIicLfrerZwADcNECiBjQeztwxLkyvQOmXkRRCJS2rbp0yL(HSccIHP3UXciyfIYUcnelSs(iK1uW(O0WcRN7CCqsLPww6bzvgYeRH5NfeAyHvPokmSsaFSmewPcz1EwLfHK1sV0K(hw)aeM2dzfmkbkRGrriGwzQzQPsKnzDvQGvPIYeRSUYnYAhf8qJv6hYkiwYPj3GGvik7k0qSWk5Jqwtb7JsdlSEUZXbjvMAzPhKvkKjwdZpli0WcRGakmi9dDWACacwTNvqafgK(HoynoQ4KUESacwbtKqaTYull9GSk6LjwdZpli0WcRGakmi9dDWACacwTNvqafgK(HoynoQ4KUESacwbJIqaTYuZutLiBY6QubRsfLjwzDLBK1ok4HgR0pKvqeaXZh5MgiyfIYUcnelSs(iK1uW(O0WcRN7CCqsLPww6bzvgYeRH5NfeAyHvqqEbVBpLACacwTNvqqEbVBpLACuXjD9ybeScgfHaALPww6bzvgYeRH5NfeAyHvqqEbVBpLACacwTNvqqEbVBpLACuXjD9ybeSMgRXPShzHvWOieqRm1YspiRxuMynm)SGqdlSccOWG0p0bRXbiy1Ewbbuyq6h6G14OIt66Xciyfmkcb0ktTS0dYQOxMynm)SGqdlSccOWG0p0bRXbiy1Ewbbuyq6h6G14OIt66Xciyfmkcb0ktTS0dYkvMmXAy(zbHgwyfegSNROvPOghGGv7zfegSNROvnkQXbiyfmzecOvMAzPhKvQmzI1W8ZccnSWkimypxrRksnoabR2ZkimypxrRAIuJdqWkyIecOvMAzPhKvrJmXAy(zbHgwyfegSNROvPOghGGv7zfegSNROvnkQXbiyfmrcb0ktTS0dYQOrMynm)SGqdlSccd2Zv0QIuJdqWQ9Sccd2Zv0QMi14aeScMmcb0ktntnvISjRRsfSkvuMyL1vUrw7OGhASs)qwbrPH4XabRqu2vOHyHvYhHSMc2hLgwy9CNJdsQm1YspiRIgzI1W8ZccnSWkiiVG3TNsnoabR2ZkiiVG3TNsnoQ4KUESacwbJIqaTYull9GSsHiYeRH5NfeAyHvqafgK(HoynoabR2ZkiGcds)qhSghvCsxpwabRGrriGwzQzQPsKnzDvQGvPIYeRSUYnYAhf8qJv6hYkiofciyfIYUcnelSs(iK1uW(O0WcRN7CCqsLPww6bzv0ltSgMFwqOHfwL6OWWkb8XYqyLkKv7zvweswl9st6Fy9dqyApKvWOeOScMiHaALPww6bzLktMynm)SGqdlSk1rHHvc4JLHWkviR2ZQSiKSw6LM0)W6hGW0EiRGrjqzfmrcb0ktTS0dYQOrMynm)SGqdlSccYl4D7PuJdqWQ9SccYl4D7PuJJkoPRhlGGvWejeqRm1YspiRuqzzI1W8ZccnSWQuhfgwjGpwgcRuHSApRYIqYAPxAs)dRFact7HScgLaLvWejeqRm1YspiRuiImXAy(zbHgwyvQJcdReWhldHvQqwTNvzrizT0lnP)H1paHP9qwbJsGYkyIecOvMAzPhKvrUGmXAy(zbHgwyfegSNROvfPghGGv7zfegSNROvnrQXbiyfmkcb0ktTS0dYQiYqMynm)SGqdlSccd2Zv0QuuJdqWQ9Sccd2Zv0Qgf14aeScgfHaALPMPMkr2K1vPcwLkktSY6k3iRDuWdnwPFiRGO8giyfIYUcnelSs(iK1uW(O0WcRN7CCqsLPww6bzLckKjwdZpli0WcRGakmi9dDWACacwTNvqafgK(HoynoQ4KUESacwbtKqaTYull9GSsHiYeRH5NfeAyHvqafgK(HoynoabR2ZkiGcds)qhSghvCsxpwabRGjsiGwzQLLEqwPqgYeRH5NfeAyHvqafgK(HoynoabR2ZkiGcds)qhSghvCsxpwabRGrriGwzQLLEqwPqgYeRH5NfeAyHvqafgey9dl14OIt66Xciy1EwbHRanDfkmiW6hwaIJQqaiyfmkcb0ktntnvquWdnSWkvgR5X6Fy13eJuzQ3sbWNU94wkSHLvzJqscPN06FyvwFhbKPoSHLvrxcp3Sks4SkcLfreMAM6WgwwdZDooirMyQdByznUSkBbbEWzfeed2hdeSs7thwTNvYhHSkBxISWk9dVsy1Ewj5cYAa8piH0JdRwhHvM6WgwwJlRx6pGWyvMZPj3SkmEKqyvY3hK1CkSEP9bzDD79S6tIXQ)hheYQDNdRIUKyiKvzJqscPNktDydlRXLvzf9ziSkA9Pd69P1)WkLyvMXPGMLSsaFoScwtZQmJtbnlzTjSAVJJhlS(00S(qw)H1Kv)poSgMlf0ktDydlRXLvrxEfzv06rY9bM0gR9yiekeyS2dRNpYnnwBAwxJSsLIaXyT0fwBJv6hY6Y7tR9ia59l4yvM6WgwwJlRuPjiRsIsI1OhISApReHOOFyLkhx6beewL98Y(OVhhwBAwb)fy9oxqwTBKvYl4D7PuzQdByznUSgMFwqOXkuyqG1pSuPHpXy1EwDfOPRqHbbw)Wcan8jwviOYuh2WYACzv2kfSWkvspfYjHSsLCJgX(bRm1HnSSgxwxznMxXcRXziKCCe6jnKv7z1bnwfiyH1MMvWFbqSGSkZ4uqZY4sYXrON0WsLPMPoSHL14me8iyyHvxK(HiRNpYnnwDrNEivwLTZbdmcRZpX9oHr0cEwZJ1)qy9hp4vM68y9pKAaepFKBAIZGap4abFt(HPopw)dPgaXZh5Mw8IPK7BMhla0(eCSSUhha7dPhM68y9pKAaepFKBAXlMsrj8kwaOFiqbt7o8aiE(i30ai45Ncrmfuo8Mwmip)co5y1fCSBWHYHzxaWfCSAwkKApHsXfzQZJ1)qQbq88rUPfVykr7rY9bM0w4nTyYl4D7PudeiMGhbqOqG1)elg5f8U9uQlVpT2JaK3VGJXuNhR)HudG45JCtlEXuAjHD66XWNmcfVGtbnlbofy4lPxaftrCbdkmi9dDWArGCDD6VIqcqqAN7ldgLRY4IXdgbna3FeivRrOiIgazeCUmLRuakOGYuhwwx5gznxqy6GSgMlvwzTjSs5QiIWQRGXAraz1EwTBKvzDvQiRtAcqK1NM1WCjS6Gt4SksiSA3nH1L0lGS2ew)aRJspR0pKvc4ZPhhw9VtFyQZJ1)qQbq88rUPfVykTKWoD9y4tgHIP9Pd69P1)aCkWWxsVakMI4cguyq6h6G13flnoh8YuUkdzaktDyz9srdHr9GSU(Up3ScwtZAoGdkRelnwDfOPz1G9CfnwxJSUohJv7znndJcmwTNvc4ZH11TDZQmJtbnlRm15X6Fi1aiE(i30IxmLwsyNUEm8jJqXgSNRObqaFoae)BHVKEbumfH30InypxrRsr9ojaelTAoGduciYbdKgSNROvfPENeaILwnhWbkbKyXmypxrRsr98VV8RNAraMw)tOInypxrRks98VV8RNAraMw)dOXIzWEUIwLIAtQ9qoqblD9iGSRqoMqeqbx6dglgygSNROvPO2Kk5ol)AhyscaS3Wi5NFbNCS6co2n4qqzQZJ1)qQbq88rUPfVykTKWoD9y4tgHInypxrdGa(Cai(3cFj9cOyrcVPfBWEUIwvK6DsaiwA1CahOeqKdginypxrRsr9ojaelTAoGduciXIzWEUIwvK65FF5xp1IamT(NqnypxrRsr98VV8RNAraMw)dOXIzWEUIwvKAtQ9qoqblD9iGSRqoMqeqbx6dglgygSNROvfP2Kk5ol)AhyscaS3Wi5NFbNCS6co2n4qqzQZJ1)qQbq88rUPfVykrmm92ntDES(hsnaINpYnT4ftjIVpiqofGsFWWdG45JCtdGGNFkeXueEtlgKw6XXQt7CBel9xryfN01Jf5qKgIK701Jm1m1HnSSgNHGhbdlSIlieCwTocz1UrwZJ9qwBcR5s2(01JvM68y9peXx7ZvM6WYQSIedtVDZAtZAWtiTRhzfS5zDrWpimD9iR4GrnsyThwpFKBAGYuNhR)HeVykrmm92ntDES(hs8IP0sc701JHpzekM0JJhbSe6Gw4lPxaftcqVhWsOdAKkDoapnW1PxqcvfHPoSSgMpYThSWACoi0bCwLv0bhwhelyHv7zLKMamnKPopw)djEXuAjHD66XWNmcfdrhCaiPjatdlHVKEbumoi0b8keDWb48rU9GLqVWfzQZJ1)qIxmLoP3dKhR)bW3el8jJqXedtVDJLWjgSpMykcVPftmm92nwQW3razQZJ1)qIxmLoP3dKhR)bW3el8jJqXNcHPoSSEjcgRsZLYQqaR90wNEp4Ss)qwdJGXQ9SA3iRH5ojy4ScrAisUzDDB3SgNZcoFeRnnRPXQ)xZAraMw)dtDES(hs8IPeX3heiNcqPpy4nTyq6kqtxj((Ga5uak9bRcbYpFK7de89yKqftbtDES(hs8IPeol48rH30IDfOPReFFqGCkaL(GvHa5Uc00vIVpiqofGsFWkeJYEiu9IYpFK7de89yKqfldM68y9pK4ftPt69a5X6Fa8nXcFYiuC5nM68y9pK4ftPt69a5X6Fa8nXcFYiuCPH4XyQZJ1)qIxmLs4jheWEiehl8Mwmoi0b8AbP7tBHkMIlgpoi0b8keDWb48rU9GfM68y9pK4ftPeEYbbce8eKPopw)djEXuY3o3gbGkfHIteogtDES(hs8IPKB6a80agSpxjm1m1HnSSgM)9LF9qyQdlRub0SMLcH1eISkeeoRKPdqwTBK1Fqwx32nR(FnsmwxzLlTYkvAcY66BCyTaEpoSsNedHSA35WAyUewliDFAJ1hY662UFbJ1CaN1WCjvM68y9pK6PqehLWRybG(HafmT7W99GaNIykQxm8d4hpcyj0bnIykcVPfdZUaGl4y1SuivHa5GbYLe2PRhRKEC8iGLqh0IfZsOdAvRJqa7bkns1lqzqLdMLqh0QwhHa2duAKQNpY9bc(EmsTG09PTltr9IXID(i3hi47Xi1cs3N2cv8jaikdbGeGtbuM6WYkvanRZZAwkewx3EpRLgzDDB39WQDJSoyigRxGYKWzvGGSk6OVuwPFiRrziSgMlPYQSzggfySApReWNdRRB7MvrRpDqVpT(hwBAwdEcPD9yLPopw)dPEkK4ftPOeEfla0peOGPDhEtlgMDbaxWXQzPqQ9e6fOCCHzxaWfCSAwkKAraMw)J8Zh5(abFpgPwq6(0wOIpbarziaKaCkYb55FF5xpvYDVuHywaxoyG88l4KJvxWXUbhglwbDfOPR0(0b9(06FQcbXID(3x(1tL2NoO3Nw)tfIrzpKqP4IGYuhwwLaFoSkZ4uqZswx3t5xZ662UzD1252iw6VIW4JZqi54i0tAiRnnRzqGVpPRhzQZJ1)qQNcjEXuAjHD66XWNmcfVGtbnlbM252iw6VIqGZpL26FcFj9cOyqAPhhRoTZTrS0FfHvCsxpwIfdKw6XXQyiKCCe6jnSIt66XsSyN)9LF9uXqi54i0tAyfIrzpeQEX4kYLT0JJvligGqaIbtlDWOkoPRhlm1HLvQKSnw)HvzgNcAwYk9dzLkMq4BiRRB7MvrNSfoRcJhjewxJSMqK10ynkdH1WCjSs)qwfT(0b9(06FyQZJ1)qQNcjEXuAjHD66XWNmcfVGtbnlbIsGZpL26FcFj9cOyqAPhhRgLedHajHKespvCsxpwIfR8w1jHW3WQ1NR94el25xWjhRUGJDdou(5JCFGGVhJuliDFAtmLzQdlRsGphwLzCkOzjRRB7MvrRpDqVpT(hwZPWQegqAcRjHv)poSMewxJSU(hqyS6FcYAY6jjgR)ccz1UrwPBNBJ1IamT(hM68y9pK6PqIxmLwsyNUEm8jJqXl4uqZsGZVGtogW5NsB9pH30Ip)co5y1RGd7CIf78l4KJvh8aF)dlXID(fCYXQZpy4lPxaftbtDES(hs9uiXlMsljStxpg(KrO4fCkOzjW5xWjhd48tPT(NWBAXNFbNCS6co2n4WWxsVakM2)pemWOBNBdaIrzpK4kcLbLkemkeHYxEjHD66X6cof0Se4uGGcAO0()HGbgD7CBaqmk7HexrOCCp)7l)6Ps7th07tR)PcXOShcOuHGrHiu(YljStxpwxWPGMLaNceuqJfZvGMUs7th07tR)bWvGMUkeelwbDfOPR0(0b9(06FQcbXI5(eIC6252aGyu2dHQIqzM68y9pK6PqIxmLwsyNUEm8jJqXl4uqZsGZVGtogW5NsB9pH30Ip)co5y1PDUna6edFj9cOyA))qWaJUDUnaigL9qIRiuguQqWOqekF5Le2PRhRl4uqZsGtbckOHs7)hcgy0TZTbaXOShsCfHYX98VV8RNkbdinPcXOShcOuHGrHiu(YljStxpwxWPGMLaNceuqJfR8wLGbKMuT(CThNyXCFcroD7CBaqmk7HqvrOmtDyzv06rY9bM0gR0pK1lrGycEK14ekey9pS20SoVXkXW0B3yH1hYApSMSE(3x(1dRhWpEKPopw)dPEkK4ftjApsUpWK2cVPfdg5f8U9uQbcetWJaiuiW6FIfJ8cE3Ek1L3Nw7raY7xWXavoijgME7gl107LdYc6kqtxxWPGMLvHa5rjXqiqsijH0daeJYEiIPSCWWbHoGxTocbShikdb48rU9GLqfjwmqwqxbA6k5UxQcbGgEpgcHcbgqhfHLonumfH3JHqOqGb44F30lMIW7XqiuiWaAAXKxW72tPU8(0ApcqE)cogtDyzvc85WQO1NoO3Nw)dRRB7MvzgNcAwYAsy1)JdRjH11iRR)begR(NGSMSEsIX6VGqwTBKv6252yTiatR)HvWEiRnnRYmof0SK11T3Z65JqwDZZvwtNShk1ewT3XXJfwFAAqRm15X6Fi1tHeVykr7th07tR)j8MwmijgME7glv47iGYb78VV8RN6cof0SScXOShcvVG8Le2PRhRl4uqZsGOe48tPT(h5innESEbboFK7de89yKqfld5wcDqRADecypqPXqPGYXIvqxbA66cof0SSkeelM7tiYPBNBdaIrzpeQkImaLPopw)dPEkK4ftjAF6GEFA9pH30IbjXW0B3yPcFhbuostJhRxqGZh5(abFpgjuXYqoy0()HGbgD7CBaqmk7HexrKbOuHGD(3x(1ZLxsyNUESs7th07tR)b4uGGcAO0()HGbgD7CBaqmk7HexrKrCp)7l)6PUGtbnlRqmk7HC5Le2PRhRl4uqZsGtbckviyN)9LF9C5Le2PRhR0(0b9(06FaofiOGcktDyzvc85WQegqAcRRB7MvzgNcAwYAsy1)JdRjH11iRR)begR(NGSMSEsIX6VGqwTBKv6252yTiatR)jCwDfmwdGincz1sOdAewT70yDD79S67fK10y1JjXyLcktyQZJ1)qQNcjEXuIGbKMeEtlgKedtVDJLk8Deq5L3Qoje(gwT(CThh5GD(3x(1tDbNcAwwHyu2dHQui3sOdAvRJqa7bkngkfuowSc6kqtxxWPGMLvHGyXCFcroD7CBaqmk7HqvkOmOm15X6Fi1tHeVykrWastcVPfdsIHP3UXsf(ocOCWO9)dbdm6252aGyu2djUuqzqPcp)7l)6b0qP9)dbdm6252aGyu2djUuq54E(3x(1tDbNcAwwHyu2d5YljStxpwxWPGMLaNceuQWZ)(YVEafuM68y9pK6PqIxmLwWPGMLH30IbjXW0B3yPcFhbuE5TkuiWeGy16Z1ECKdYc6kqtxxWPGMLvHa5ljStxpwxWPGMLat7CBel9xriW5NsB9pYxsyNUESUGtbnlbIsGZpL26FKVKWoD9yDbNcAwcC(fCYXao)uAR)HPoSSgNHqYXrON0qwxFJdRZBSsmm92nwynNcRUVDZQSkeycqK1CkSsfti8nK1eISkeWk9dz1)JdR48co3vM68y9pK6PqIxmLWqi54i0tAy4nTyqsmm92nwQW3raLdgilVvDsi8nScrAisUtxpkV8wfkeycqScXOShsOYiEzC5taqugcajaNsSyL3QqHataIvigL9qUmLRxmulHoOvTocbShO0iOYTe6Gw16ieWEGsJHkdM6WYQ0DVWAtZ6L(RqynHiRcbuPYAtZ6QTZTXQOnrwtZWOaJv7zLa(CyDDB3SkHbKMW6dzvMXPGMLS20SUgzD9pGWyDDsmK1OhISA35W6D6Pzv6UxabH1Z)(YVEyQZJ1)qQNcjEXuIC3lH30IbzbDfOPRK7EPkeihSYBvNecFdRwFU2JJ8YBvOqGjaXQ1NR94aQCWa55xWjhRoTZTbqNySyGb25FF5xpvcgqAsfIzb8yXo)7l)6PsWastQqmk7HekfIaA8GD(3x(1tDbNcAwwHywapwSZ)(YVEQl4uqZYkeJYEixEjHD66X6cof0Se4uGHsHiGkweqbLPopw)dPEkK4ftPG36FcVPf7kqtxD9)x8ceRcX8yXI5(eIC6252aGyu2dHQxGYXIvqxbA66cof0SSkeWuNhR)Hupfs8IPKR))caTae8WBAXf0vGMUUGtbnlRcbm15X6Fi1tHeVyk5IqccV2Jt4nT4c6kqtxxWPGMLvHaM68y9pK6PqIxmLOBi66)VeEtlUGUc001fCkOzzviGPopw)dPEkK4ftPCoiXGPh4KEF4nT4c6kqtxxWPGMLvHaM68y9pK6PqIxmLoP3dKhR)bW3el8jJqXl50K7WBAXGKyy6TBSutVxEusmecKessi9aaXOShIykZuNhR)Hupfs8IPKabbAdJcFYiu86EkKtcbwFJgX(bdVPftcqVhWsOdAKkDoapnW1PxqsOfK0qSayj0bnsSyWSla4cownlfsTNqf9uowm3NqKt3o3gaeJYEiuLkJPoSSkb(Cy1UrwdG9dBdCwjwAS6kqtZQb75kASUUTBwLzCkOzz4S(2ncx3eKvbcY6pSE(3x(1dtDES(hs9uiXlMsgSNROrr4nT4Le2PRhRgSNRObqaFoae)BIPqoyf0vGMUUGtbnlRcbXI5(eIC6252aGyu2dHQIfHYGglgyljStxpwnypxrdGa(Cai(3elICqAWEUIwvK65FF5xpviMfWbnwmqUKWoD9y1G9Cfnac4ZbG4FJPopw)dPEkK4ftjd2Zv0ej8Mw8sc701Jvd2Zv0aiGphaI)nXIihSc6kqtxxWPGMLvHGyXCFcroD7CBaqmk7HqvXIqzqJfdSLe2PRhRgSNRObqaFoae)BIPqoinypxrRsr98VV8RNkeZc4GglgixsyNUESAWEUIgab85aq8VXuZuh2WY6L2q8ySwYO0bznDBFBnsyQdlRX5SGZhXAASkJ4zfSlgpRRB7M1lvcuwdZLuzLkikclDAOhCw)HvrINvlHoOrcN11TDZQmJtbnldN1hY662UzDfrrLkRVDJW1nbzDD2gR0pKvYhHSIdcDaVYQS5jpRRZ2yTPznodH4W65JCFwBcRNpQhhwfcQm15X6Fi1sdXJjgNfC(OWBAXinnESEbboFK7de89yKqflJ4T0JJvligGqaIbtlDWOkoPRhlYbRGUc001fCkOzzviiwSc6kqtxj39sviiwSc6kqtxP9Pd69P1)ufcIfdhe6aETG09PnQkwKlgpoi0b8keDWb48rU9GLyXa5sc701JvspoEeWsOdAXIH004X6fe48rUpqW3Jrc9eaeLHaqcWPaQCWaPLECSkgcjhhHEsdR4KUESel25FF5xpvmesooc9KgwHyu2djuraLPopw)dPwAiES4ftPLe2PRhdFYiuSabbOBVhHHVKEbu85JCFGGVhJuliDFAlukIfdhe6aETG09PnQkwKlgpoi0b8keDWb48rU9GLyXa5sc701JvspoEeWsOdAm1HLvzliWdoRsIsIv7zn9EwTe6GgH11TD)cgRjRf0vGMM1KWAaSFyBGhoRbqKgHWECy1sOdAewlG3JdRK)heYAsBiKv7gzna2rjeCwTe6GgtDES(hsT0q8yXlMseectdlaU)GaKG(kgEtlEjHD66XQabbOBVhHYbz5TkbHW0WcG7piajOVIaL3QwFU2JdtDES(hsT0q8yXlMseectdlaU)GaKG(kg(b8JhbSe6GgrmfH30IxsyNUESkqqa627rOCqwERsqimnSa4(dcqc6Riq5TQ1NR94WuhwwPYrmGvA4hX6jdc6XH1ZDcDqcRpKvxb4WAASA3iR4uy9PzLUDUnctDES(hsT0q8yXlMseectdlaU)GaKG(kgEtlEjHD66XQabbOBVhHYJsIHqGKqscPhaigL9qOkLRIg5G5(eIC6252aGyu2dHQIVySyN)9LF9ujieMgwaC)bbib9vSgLHaCUtOdsI75oHoibGgMhR)j9uvmLRICrqzQdlRuj34WQOt2yTjSoVXAASE3o3SweGP1)eoReWNdRRB7M1sgLoiRUc00ewx329lyS(liCnSTECyvwWSWQl4SgNHKrbEKPopw)dPwAiES4ftjccHPHfa3FqasqFfdVPfdscAaU)iqQwJqrenaIeCKVKWoD9yvGGa0T3Jq5rjXqiqsijH0daeJYEiuLYvrJCWiVG3TNs1JzbWfCamKmkWJvCsxpwKdsxbA6QhZcGl4ayizuGhRcbYlORanDDbNcAwwfcIfZvGMUgLq4VglaoyeX(bbW5oNdgHJvfcIfdKljStxpwj944ralHoOjVGUc00vYDVufcaLPopw)dPwAiES4ftjccHPHfa3FqasqFfdVPftqdW9hbs1AekIObqKGJ8Le2PRhRceeGU9EekpkjgcbscjjKEaGyu2dHQuUkAKxqxbA6QduO4GarPDURcbYbPRanD1JzbWfCamKmkWJvHa5WSla4cownlfsTNqVitDyzLknbzvsusSApReHOOFyLkhx6beewL98Y(OVhhwBAwb)fy9oxqwTBKvYl4D7PuzQZJ1)qQLgIhlEXuIGqyAybW9heGe0xXW99GaNIykUy4nTyYl4D7PuVIl9qa(x2h994i3vGMUEfx6Ha8VSp67XPw(1dtDyzv0MdRpnRu5tVGewtJvkKDINvILNRewFAwL9QlfCyvu(SGewFiRPt2dXyvgXZQLqh0ivM68y9pKAPH4XIxmLOZb4PbUo9cscVPfVKWoD9yvGGa0T3Jq5G5kqtxV7sbhaxFwqsLy55AOIPq2jwmWazaSFyBGdaFlT(h5Ka07bSe6GgPsNdWtdCD6fKeQyzepXW0B3yPcFhbeuqzQdlRI2Cy9PzLkF6fKWQ9SMbbEWzn4BYpewBAw7jpwVGS(dR5aoRwcDqJvWEiR5aoRUEel94WQLqh0iSUUTBwdG9dBdCwHVLw)dOSMgRxyfM68y9pKAPH4XIxmLOZb4PbUo9cscVPfNhRxqGYB1cMfp4abFt(bO8gvZJ1liaoyuJe5GbYay)W2aha(wA9pXIvER6Kq4By16Z1ECIfR8wfkeycqSA95ApoGkFjHD66XQabbOBVhHYjbO3dyj0bnsLohGNg460lijuXxGPopw)dPwAiES4ftj8C)94aaXayhLtj8Mw8sc701Jvbccq3EpcLF(3x(1tDbNcAwwHyu2djukOmtDES(hsT0q8yXlMszKRa5o8Mw8sc701Jvbccq3EpcLdwusmecKessi9aaXOShIyklhKqHbPFOdwl)h56ZcglMRanD113tH0fSkeaktDyzDL0nUIobR9PHSApRzqGhCwVumlEWz9s(M8dRPXQiSAj0bnctDES(hsT0q8yXlMsrcw7tdd)a(XJawcDqJiMIWBAXljStxpwfiiaD79iuoja9EalHoOrQ05a80axNEbjIfHPopw)dPwAiES4ftPibR9PHH30IxsyNUESkqqa627ritntDydlRxAgLoiR)ccz16iK10T9T1iHPoSSklDuBSsWZpLecoRuXecFdjSs)qwdG9dBdCwHVLw)dRnnRRrwVZfK1lCrwXbHoGZkeDWH1hYkvmHW3qwx3EpRyibnez9hwTBK1ayhLqWz1sOdAm15X6Fi1YBIxsyNUEm8jJqXKRDaWb8JhbCsi8nm8L0lGIdG9dBdCa4BP1)ihSYBvNecFdRqmk7Hq1Z)(YVEQoje(gwlcW06FIfBjHD66XkeDWbGKMamnSaktDyzvw6O2yLGNFkjeCwLvHataIewPFiRbW(HTboRW3sR)H1MM11iR35cY6fUiR4GqhWzfIo4W6dzv6UxyTjSkeW6pSkYkXZuNhR)HulVfVykTKWoD9y4tgHIjx7aGd4hpcafcmbig(s6fqXbW(HTboa8T06FKdwbDfOPRK7EPkeiNeGEpGLqh0iv6CaEAGRtVGKqfjwSLe2PRhRq0bhasAcW0WcOm1HLvzPJAJvzviWeGiH1MMvzgNcAwgV0DVqjrxsmeYQSrijH0dRnHvHawZPW6AK17CbzvK4zLGNFkew9iTX6pSA3iRYQqGjarwV0FfM68y9pKA5T4ftPLe2PRhdFYium5Ahaafcmbig(s6fqXf0vGMUUGtbnlRcbYbRGUc00vYDVufcIflkjgcbscjjKEaGyu2djukdQ8YBvOqGjaXkeJYEiHkctDyzvkapD6zLkMq4BiR5uyvwfcmbiYkbnHawdG9dz1EwJZqi54i0tAiRNKym15X6Fi1YBXlMsoje(ggEtl2spowfdHKJJqpPHvCsxpwKdY1T3d4FccGHqYXrON0q5L3Qoje(gwdIe8wh4BesvXui)8VV8RNkgcjhhHEsdRqmk7HqvrKtcqVhWsOdAKkDoapnW1PxqIykKdZUaGl4y1Sui1Ecv0lV8w1jHW3WkeJYEixMY1lsvlHoOvTocbShO0itDES(hsT8w8IPeuiWeGy4nTyl94yvmesooc9KgwXjD9yroyinnESEbboFK7de89yKqfFcaIYqaib4uKF(3x(1tfdHKJJqpPHvigL9qOkfYlVvHcbMaeRqmk7HCzkxVivTe6Gw16ieWEGsJGYuhwwPIje(gYQqWvedcN10tEwnyJewTNvbcYABSMewtwjb4PtpRo4GW0EiR0pKv7gz1NeJ1WCjS6I0peznzLUNMCJqM68y9pKA5T4ftPG)9aqK8cWdgo9dbgmetmfm15X6Fi1YBXlMsoje(ggEtlgI0qKCNUEu(5JCFGGVhJuliDFAluXuihSGibV1b(gHuvmfXIbXOShcvfB95kG1rOCsa69awcDqJuPZb4PbUo9cscv8favoyGCD79a(NGayiKCCe6jnmwmigL9qOQyRpxbSocVSiYjbO3dyj0bnsLohGNg460lijuXxau5Gzj0bTQ1riG9aLgJleJYEiGgQmKhLedHajHKespaqmk7HiMYm15X6Fi1YBXlMsb)7bGi5fGhmC6hcmyiMykyQZJ1)qQL3IxmLCsi8nm8d4hpcyj0bnIykcVPfdYLe2PRhRKRDaWb8JhbCsi8nuoePHi5oD9O8Zh5(abFpgPwq6(0wOIPqoybrcERd8ncPQykIfdIrzpeQk26ZvaRJq5Ka07bSe6GgPsNdWtdCD6fKeQ4laQCWa5627b8pbbWqi54i0tAySyqmk7HqvXwFUcyDeEzrKtcqVhWsOdAKkDoapnW1PxqsOIVaOYbZsOdAvRJqa7bkngxigL9qanukerEusmecKessi9aaXOShIykZuhwwddSJi)W6kyuasmw)H1ibV1bEKvlHoOrynnwLr8SgMlH1134WkuyMECy9fmw7HvrI7fjSMew9)4WAsyDnY6DUGSIZl4CZkeDWH1CkSMqCaHXkbnRhhwfcyL(HSkZ4uqZsM68y9pKA5T4ftPdSJi)ayyuasSWpGF8iGLqh0iIPi8Mwmja9EalHoOrcvSiYrAA8y9ccC(i3hi47XiHkwgYXbHoGxHOdoaNpYThSeQiuwoyG88VV8RN6cof0SScXSaESyL3QqHataIvRpx7Xbu5qmk7HqvrI)cxgmsa69awcDqJeQyzaktDyzLkhXawfcyvwfcmbiYAASkJ4z9hwtVNvlHoOryfS134WQVx6XHv)poSIZl4CZAofwN3yLmza5(nqzQZJ1)qQL3IxmLGcbMaedVPfdYLe2PRhRKRDaauiWeGOCKMgpwVGaNpY9bc(EmsOILHCisdrYD66r5Gfej4ToW3iKQIPiwmigL9qOQyRpxbSocLtcqVhWsOdAKkDoapnW1PxqsOIVaOYbdKRBVhW)eeadHKJJqpPHXIbXOShcvfB95kG1r4Lfroja9EalHoOrQ05a80axNEbjHk(cGk3sOdAvRJqa7bkngxigL9qcfmzepyqHbPFOdwlj5UhhaY5fMce9x(IGgpyqHbPFOdwl)h56ZcE5lcA8GTKWoD9yfIo4aqstaMgwUSOhuqzQZJ1)qQL3IxmLGcbMaed)a(XJawcDqJiMIWBAXGCjHD66Xk5AhaCa)4raOqGjar5GCjHD66Xk5AhaafcmbikhPPXJ1liW5JCFGGVhJeQyzihI0qKCNUEuoybrcERd8ncPQykIfdIrzpeQk26ZvaRJq5Ka07bSe6GgPsNdWtdCD6fKeQ4laQCWa5627b8pbbWqi54i0tAySyqmk7HqvXwFUcyDeEzrKtcqVhWsOdAKkDoapnW1PxqsOIVaOYTe6Gw16ieWEGsJXfIrzpKqbtgXdguyq6h6G1ssU7XbGCEHPar)LViOXdguyq6h6G1Y)rU(SGx(IGgpyljStxpwHOdoaK0eGPHLll6bfuM6WYQOn9E38CLvz7JtwddSJi)W6kyuasmwx32nR2nYkjJqw9VtFynjSMU)cgoRUcgRTZ8WECy1UrwXbHoGZ65NsB9pewBAwxJSMqCaHXQaPhhwLvHataIm15X6Fi1YBXlMshyhr(bWWOaKyH30IjbO3dyj0bnsOIfrostJhRxqGZh5(abFpgjuXYqoeJYEiuvK4VWLbJeGEpGLqh0iHkwgGYuhwwddSJi)W6kyuasmw)HvPvyTPzThwdYPGr9H1CkSoyc9GZAugcR4GqhWznNcRnnRX5SGZhX66FaHXA5zn6HiRLmkDqwlciR2Z6kIIsIozJPopw)dPwElEXu6a7iYpaggfGel8Mwmja9EalHoOretHCWajuyq6h6G1ssU7XbGCEHParFSyqHbbw)WsLg(eRIt66XcOYJsIHqGKqscPhaigL9qetz5innESEbboFK7de89yKqfd2jaikdbGeGtjUuaQCisdrYD66r5GCD79a(NGayiKCCe6jnuoyGSGUc00vYDVufcIfRGUc00vhOqXbbIs7CxHyu2djuravULqh0QwhHa2duAmUqmk7HeQmyQzQdByzvYW0B3yHvz7y9peM6WY6QTZnXs)veY6pSEHvKjwddSJi)W6kyuasmM68y9pKkXW0B3yr8b2rKFammkajw4nTyl94y1PDUnIL(RiSIt66XICsa69awcDqJeQ4li)8rUpqW3JrcvSmKBj0bTQ1riG9aLgJleJYEiHk6zQdlRR2o3el9xriR)WkfRitSknza5(nwLvHataIm15X6FivIHP3UXs8IPeuiWeGy4nTyl94y1PDUnIL(RiSIt66XI8Zh5(abFpgjuXYqULqh0QwhHa2duAmUqmk7HeQONPoSSkj4AiKwWbLjwLTGap4S(qwLvKgIKBwx32nRUc00yHvQycHVHeM68y9pKkXW0B3yjEXuk4FpaejVa8GHt)qGbdXetbtDES(hsLyy6TBSeVyk5Kq4By4hWpEeWsOdAeXueEtl2spowLi4AiKwWbR4KUESihKRBVhW)eeadHKJJqpPHYbdIrzpeQsHiuHyiKCCe6jnSaatdJflisWBDGVrivftbOYTe6Gw16ieWEGsJXfIrzpKqfHPoSSkj4AiKwWbznEwJZqioS(dRuSImXQSI0qKCZkvmHW3qwtJv7gzfNcRpnRedtVDZQ9S6GgRrziSweGP1)WQls)qK14mesooc9KgYuNhR)HujgME7glXlMsb)7bGi5fGhmC6hcmyiMykyQZJ1)qQedtVDJL4ftjNecFddVPfBPhhRseCnesl4GvCsxpwKBPhhRIHqYXrON0WkoPRhlYZJ1liaoyuJeXui3vGMUseCnesl4GvigL9qOkf1lWuZuh2WYQmNttUzQdlRI2EAYnRRB7M1OmewdZLWk9dzD1252iw6VIWWzvy8iHWQaPhhwVumTBp4SkDNLFnHPopw)dPUKttUfVKWoD9y4tgHIN252iw6VIqGtaW5NsB9pHVKEbumyGekmi9dDWAbt72doa5ol)AICKMgpwVGaNpY9bc(EmsOIpbarziaKaCkGglgyqHbPFOdwlyA3EWbi3z5xtKF(i3hi47XiuveqzQdlRYCon5M11TDZACgcXH14zD1252iw6VIqzIvrxgshjeXAyUewZPWACgcXHviMfWzL(HSoyigRuXWCPm15X6Fi1LCAYD8IP0son5o8MwSLECSkgcjhhHEsdR4KUESi3spowDANBJyP)kcR4KUESiFjHD66X60o3gXs)vecCcao)uAR)r(5FF5xpvmesooc9KgwHyu2dHQuWuhwwL5CAYnRRB7M1vBNBJyP)kcznEwx9znodH4itSk6Yq6iHiwdZLWAofwLzCkOzjRcbm15X6Fi1LCAYD8IP0son5o8MwSLECS60o3gXs)vewXjD9yroiT0JJvXqi54i0tAyfN01Jf5ljStxpwN252iw6VIqGtaW5NsB9pYlORanDDbNcAwwfcyQZJ1)qQl50K74ftPG)9aqK8cWdgo9dbgmetmfHJHyWeiJEHXelJlYuNhR)HuxYPj3XlMsl50K7WBAXw6XXQebxdH0coyfN01Jf5N)9LF9uDsi8nSkeiVGUc001fCkOzzviqoyL3Qoje(gwHinej3PRhJfR8w1jHW3WAqKG36aFJqQkMcqLF(i3hi47Xi1cs3N2cvmyKa07bSe6GgPsNdWtdCD6fKeQS3Yau5WSla4cownlfsTNqPqeM6WYQmNttUzDDB3Sk6sIHqwLncjj9itSkRcbMaeJNkMq4BiRZBS2dRqKgIKBwH54GHZAra2JdRYmof0SmEP7EPYQe4ZH11TDZQegqAcR09KEwVBJ1MM1GNqAxpwzQZJ1)qQl50K74ftPLCAYD4nTyWS0JJvJsIHqGKqscPNkoPRhlXIbfgK(HoynkHxbEAa7gbIsIHqGKqscPhqLdYYBvOqGjaXkePHi5oD9O8YBvNecFdRqmk7He6fKxqxbA66cof0SSkeihSc6kqtxj39sviiwSc6kqtxxWPGMLvigL9qOQmIfR8wLGbKMuT(CThhqLxERsWastQqmk7Hq1lSLib4zVQixu2zBBBVb]] )


end
