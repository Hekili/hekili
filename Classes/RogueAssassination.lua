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


    spec:RegisterPack( "Assassination", 20220228, [[diLOLcqivf9iQQ0LqIqBIO6tQkmkvvoLQsRsjv9kHQMfvvDlHkTlj9lKOggsIJHewgH4zkPyAefUMskTnII4BesjJdjsDoIIK1rivVdjssZdjP7rO2hvL(hrPK6GeLQfsi5HuvXevsLUOqfTrcP4Jir0ijkLKtIebRej1ljKsntIsCtIsXovs6NeLsmuLuXsjkPNsKPQK4QirsTvII6RirIXkuH9Qu)vvgmPdlAXuPhRIjlXLH2mbFMkgTk1PLA1irs8AvsZwWTfYUv8BGHtvoorrQLd65iMoLRJuBxj(UkX4PQ48QQA9eLsnFHY(r9MI9kBPsA4EvrOIiIqfreHsxfznRrgYqMSLS)E4wYlpxthClnzeULKDcjjKEsRbZwYl)hazzVYwIaOHhClDBMhr0PmLDA7M2TEaruM0r0H0AWCGPGrzshDO8wYLUdgLWSD3sL0W9QIqfreHkIicLUkYAwJmwdfBPK2UbWTKuh5NT0Dxk4SD3sfKC2sYoHKespP1GHvzf4qJm1Ig0fsNW)SkcL2FwfHkIictntTFUZXbjIotDCzv298c)z9dIb7J9bRcH0HvdWkbeHSk7RJSWQaaELWQbyLKliREqWbjKECy16iSYuhxwxxW8HXQmNttUzLEciHWQuOpiR5uyDD7dY6LoeynKeJ1ayCqiR2DoSkBsIHqwLDcjjKEQm1XLvzfdPpSkAcPdgcP1GHvkZQmJtbnlzL8FoS(RfyvMXPGMLS2ewnGJtalSceeyfazfmSMSgaJdR(zD)wzQJlRYM8kYQOjGK7dmfmw7XqiK2ZyThwpGi30yTfy9cYkLk0eJ1sxyTnwfaqwxaH06a(iGWcowLPoUSsPMGSkjkjwJaqKvdWkHokcmSkAJl98bHvzlazBm0JdRTaR)b0SENliR2nYkbqhC7PuzQJlR(bmli0yfsp47cawQcqaXy1aS6sliuH0d(UaGLNaeqSkTxLPoUSk7LcwyLsPNc5KqwPuUrJyGbRm1XL1vUG5vSWAC6djhh6Esdz1aS6GgR0eSWAlW6Fa9hliRYmof0SmUKCCO7jnSu3sHMyK9kBjIHzWUXYEL9QuSxzlHt6gWYwuBP8yny2shyhraZZWipKyBPcsoW2ZAWSLwTDUjwgUIqwbdRRzfrNv)a7icyyDfmYdj2w6aBdHDULSmGJvN252iwgUIWkoPBalSkNvIhgcplHoOry1xXSUgwLZ6be5cEEGEmcR(kMvzWQCwTe6Gw16i8zGxPrwJlRqmk7HWQVSkt22Evr2RSLWjDdyzlQTuESgmBjiTNrdXTubjhy7zny2sR2o3eldxriRGHvkwr0zvAspYnWyvwP9mAiULoW2qyNBjld4y1PDUnILHRiSIt6gWcRYz9aICbppqpgHvFfZQmyvoRwcDqRADe(mWR0iRXLvigL9qy1xwLjBBV6A2RSLWjDdyzlQTuESgmBjpai8Gibqdp4wQGKdS9SgmBjjAxdHc0oOOZQS75f(ZkaYQSIcqKCZ6L2Uz1LwqalSsjtieyizljaGVb9X2RsX22RkJ9kBjCs3aw2IAlLhRbZwYjHqGHBPdSne25wYYaowLq7AiuG2bR4KUbSWQCw)K1lDi8cac(qFi54q3tAiRYz9hRqmk7HWkvzLcryLYSI(qYXHUN0WYdMgYASyS6frhS2l0iKvQkMvky9lRYz1sOdAvRJWNbELgznUScXOShcR(YQiBPZ)taFwcDqJSxLITTxDT7v2s4KUbSSf1wkpwdMTKhaeEqKaOHhClvqYb2EwdMTKeTRHqbAhK14zno9H4WkyyLIveDwLvuaIKBwPKjecmK10y1UrwXPWkqGvIHzWUz1aS6GgRrPpSwOHP1GHvxuaarwJtFi54q3tA4wsaaFd6JTxLITTxvMSxzlHt6gWYwuBPdSne25wYYaowLq7AiuG2bR4KUbSWQCwTmGJvrFi54q3tAyfN0nGfwLZAESEbF4GrnsyvmRuWQCwDPfeQeAxdHc0oyfIrzpewPkRuuxZwkpwdMTKtcHad3222sl50K79k7vPyVYwcN0nGLTO2saVTebTTuESgmBPLe2PBa3slzGg3s)y9twH0dkaGoyTGPDh()i3zbCHuXjDdyHv5SIcc4X6f8DarUGNhOhJWQVIz949IsFEepCkS(L1yXy9hRq6bfaqhSwW0Ud)FK7SaUqQ4KUbSWQCwpGixWZd0JryLQSkcRF3sfKCGTN1GzljA6Pj3SEPTBwJsFy1pRdRcaiRR2o3gXYWve6pR0tajewPj94W66IPDh(ZQ0DwaxiBPLe(Mmc3st7CBeldxr4749oGP0wdMTTxvK9kBjCs3aw2IAlLhRbZwAjNMCVLki5aBpRbZwsMZPj3SEPTBwJtFioSgpRR2o3gXYWvek6SkBsF6i6iw9Z6WAofwJtFioScXS8NvbaK1b9XyLs6N1DlDGTHWo3swgWXQOpKCCO7jnSIt6gWcRYz1YaowDANBJyz4kcR4KUbSWQCwxsyNUbSoTZTrSmCfHVJ37aMsBnyyvoRhaiuaxMk6djhh6EsdRqmk7HWkvzLITTxDn7v2s4KUbSSf1wkpwdMT0son5ElvqYb2EwdMTKmNttUz9sB3SUA7CBeldxriRXZ6QawJtFioIoRYM0NoIoIv)SoSMtHvzgNcAwYkT3w6aBdHDULSmGJvN252iwgUIWkoPBalSkN1pz1Yaowf9HKJdDpPHvCs3awyvoRljSt3awN252iwgUIW3X7DatPTgmSkN1c6sliuxWPGMLvAVTTxvg7v2s4KUbSSf1wkpwdMTKhaeEqKaOHhClH(yW8Lra6X2sYyTBjba8nOp2Evk22E11UxzlHt6gWYwuBPdSne25wYYaowLq7AiuG2bR4KUbSWQCwpaqOaUmvNecbgwP9yvoRf0LwqOUGtbnlR0ESkN1FSwaw1jHqGHvikarYD6gqwJfJ1cWQojecmS6frhS2l0iKvQkMvky9lRYz9aICbppqpgPwqH(0gR(kM1FSs8Wq4zj0bnsviNhq4DD6fKWQVYwZQmy9lRYzfMD5Hl4y1Sui1Ey1xwPqKTuESgmBPLCAY922Rkt2RSLWjDdyzlQTuESgmBPLCAY9wQGKdS9SgmBjzoNMCZ6L2Uzv2KedHSk7ess6r0zvwP9mAigpLmHqGHSoaJ1EyfIcqKCZkmhh0Fwl0WECyvMXPGMLXlD3lvwL(phwV02nRsOhPjSk0tgy9UnwBbw9aes7gW6w6aBdHDUL(XQLbCSAusme(scjjKEQ4KUbSWASyScPhuaaDWAucV(acp7gFrjXq4ljKKq6PIt6gWcRFzvoRFYAbyviTNrdXkefGi5oDdiRYzTaSQtcHadRqmk7HWQVSUgwLZAbDPfeQl4uqZYkThRYz9hRf0LwqOsU7LkThRXIXAbDPfeQl4uqZYkeJYEiSsvwLbRXIXAbyvc6rAs16Z1ECy9lRYzTaSkb9inPcXOShcRuL11STTTLkOqshS9k7vPyVYwkpwdMT01(CDlHt6gWYwuBBVQi7v2s4KUbSSf1wQGKdS9SgmBjzfjgMb7M1wGvpaH0UbK1FdG1f6WGW0nGSIdg1iH1Ey9aICt77wkpwdMTeXWmy3BBV6A2RSLWjDdyzlQTeWBlrqBlLhRbZwAjHD6gWT0sgOXTeXddHNLqh0ivHCEaH31PxqcRuLvr2slj8nzeULi94eWNLqh022EvzSxzlHt6gWYwuBjG3wIG2wkpwdMT0sc70nGBPLmqJBjCqOZ)keDW5DarU9Gfw9L11S2Tubjhy7zny2s(be52dwynohe68NvzfDWH1bXcwy1aSssJgMgULws4BYiClbrhCEK0OHPHLTTxDT7v2s4KUbSSf1w6aBdHDULigMb7glviWHg3sed2hBVkfBP8yny2sNmeE5XAW8cnX2sHMyVjJWTeXWmy3yzB7vLj7v2s4KUbSSf1wkpwdMT0jdHxESgmVqtSTuOj2BYiClDkKTTxv0AVYwcN0nGLTO2s5XAWSLiH(GVCkVsFWTubjhy7zny2sRdTXQ0SUSs7XApT1zi8NvbaKv)qBSAawTBKv)CNe0FwHOaej3SEPTBwJZzbhqeRTaRPXAaCH1cnmTgmBPdSne25w6twDPfeQKqFWxoLxPpyL2Jv5SEarUGNhOhJWQVIzLITTxLsVxzlHt6gWYwuBPdSne25wYLwqOsc9bF5uEL(GvApwLZQlTGqLe6d(YP8k9bRqmk7HWkvzDTSkN1diYf88a9yew9vmRYylLhRbZwcNfCarBBVQm1ELTeoPBalBrTLYJ1GzlDYq4LhRbZl0eBlfAI9Mmc3sfGTT9QuqL9kBjCs3aw2IAlLhRbZw6KHWlpwdMxOj2wk0e7nzeULknep222Rsbf7v2s4KUbSSf1w6aBdHDULWbHo)RfuOpTXQVIzLI1YA8SIdcD(xHOdoVdiYThSSLYJ1GzlLWto4Zaqio222RsHi7v2s5XAWSLs4jh85rhi4wcN0nGLTO22EvkwZELTuESgmBPq7CBKhLk0fNiCSTeoPBalBrTT9QuiJ9kBP8yny2sUPZdi8myFUs2s4KUbSSf1222wYdIhqKBA7v2RsXELTuESgmBP0Zl8)5bAcy2s4KUbSSf122RkYELTuESgmBjxGzbS8ec5FSCPhNNb8PNTeoPBalBrTT9QRzVYwcN0nGLTO2s5XAWSLIs4vS8eaWxbt7ElDGTHWo3sFY6bSGtowDbh7(pKv5ScZU8WfCSAwkKApS6lRuS2TKhepGi30Ee8aMczlrbv22EvzSxzlHt6gWYwuBPdSne25wIaOdU9uQE0eJoGpes7znyQ4KUbSWASySsa0b3Ek1fqiToGpciSGJvXjDdyzlLhRbZwsiGK7dmfSTTxDT7v2s4KUbSSf1wc4TLiOTLYJ1GzlTKWoDd4wAjd04wIcwJlR)yfspOaa6G1cn56LmCfHKNxAN7koPBalSUEw)XkvQYyTSgpR)yLG2Zfm0KQ1iuek9tgEhwxpRuPsbRFz9lRF3slj8nzeULwWPGMLVtbUT9QYK9kBjCs3aw2IAlb82se02s5XAWSLwsyNUbClTKbAClrbRXL1FScPhuaaDWkWflnohSIt6gWcRRNvQuLHmy97wQGKdS9SgmBPvUrwZfeMoiR(zDLvwBcRuPkIiS6sBSwOrwnaR2nYQSUkLK1jnAiYkqGv)SoS6GJ)SkIpSA3nH1LmqJS2ewbEwhLbwfaqwj)NtpoSgao9zlTKW3Kr4wsiKoyiKwdM3Pa32EvrR9kBjCs3aw2IAlb82se02s5XAWSLwsyNUbClTKW3Kr4wYG9CfTh5)CEKaW2shyBiSZTKb75kAvJI6DsEelTAo)FfpcRYz9hRFYQb75kAvtK6DsEelTAo)FfpcRXIXQb75kAvJI6bacfWLPwOHP1GHvFfZQb75kAvtK6bacfWLPwOHP1GH1VSglgRgSNROvnkQnP2d5aPT0nGpzA6Cm6Oxbx6dYASyS(Jvd2Zv0Qgf1Muj3zbCXbMeVNbmmIv5SEal4KJvxWXU)dz97wQGKdS9SgmBP1fneg1dY6L7(CZ6VwG1C()LvILgRU0ccSAWEUIgRxqwVKJXQbynndJ8mwnaRK)ZH1lTDZQmJtbnlRBPLmqJBjk22Evk9ELTeoPBalBrTLaEBjcABP8yny2sljSt3aULwYanULezlDGTHWo3sgSNROvnrQ3j5rS0Q58)v8iSkN1FS(jRgSNROvnkQ3j5rS0Q58)v8iSglgRgSNROvnrQhaiuaxMAHgMwdgw9Lvd2Zv0Qgf1daekGltTqdtRbdRFznwmwnypxrRAIuBsThYbsBPBaFY005y0rVcU0hK1yXy9hRgSNROvnrQnPsUZc4IdmjEpdyyeRYz9awWjhRUGJD)hY63T0scFtgHBjd2Zv0EK)Z5rcaBB7vLP2RSLYJ1Gzlrmmd29wcN0nGLTO22EvkOYELTeoPBalBrTLYJ1Gzlrc9bF5uEL(GBPdSne25w6twTmGJvN252iwgUIWkoPBalBjpiEarUP9i4bmfYwIITTTTuPH4X2RSxLI9kBjCs3aw2IAlLhRbZwcNfCarBPcsoW2ZAWSLIZzbhqeRPXQmIN1FRnEwV02nRRR0xw9Z6uzLsikclDAy4pRGHvrINvlHoOr8N1lTDZQmJtbnl9NvaK1lTDZ6kIYFwb2ncV0eK1lzBSkaGSsariR4GqN)vwL9abW6LSnwBbwJtFioSEarUawBcRhqupoSs7v3shyBiSZTekiGhRxW3be5cEEGEmcR(kMvzWA8SAzahRwq0dHpIbtlDWOkoPBalSkN1FSwqxAbH6cof0SSs7XASySwqxAbHk5UxQ0ESglgRf0LwqOkeshmesRbtL2J1yXyfhe68VwqH(0gRuvmRISwwJNvCqOZ)keDW5DarU9GfwJfJ1pzDjHD6gWkPhNa(Se6GgRXIXkkiGhRxW3be5cEEGEmcR(Y6X7fL(8iE4uy9lRYz9hRFYQLbCSk6djhh6EsdR4KUbSWASySEaGqbCzQOpKCCO7jnScXOShcR(YQiS(DB7vfzVYwcN0nGLTO2saVTebTTuESgmBPLe2PBa3slzGg3shqKl45b6Xi1ck0N2y1xwPG1yXyfhe68VwqH(0gRuvmRISwwJNvCqOZ)keDW5DarU9GfwJfJ1pzDjHD6gWkPhNa(Se6G2wAjHVjJWTenbFcDiGWTTxDn7v2s4KUbSSf1wkpwdMTebHW0WYZfm4J41xXTubjhy7zny2sYUNx4pRsIsIvdWAgcSAj0bncRxA7gqBSMSwqxAbbwtcREWgaB7V)S6brbec7XHvlHoOryT8VhhwjaWGqwtbdHSA3iREWokH)z1sOdABPdSne25wAjHD6gWknbFcDiGqwLZ6NSwawLGqyAy55cg8r86R4RaSQ1NR94ST9QYyVYwcN0nGLTO2s5XAWSLiieMgwEUGbFeV(kULoW2qyNBPLe2PBaR0e8j0HaczvoRFYAbyvccHPHLNlyWhXRVIVcWQwFU2JZw68)eWNLqh0i7vPyB7vx7ELTeoPBalBrTLYJ1GzlrqimnS8Cbd(iE9vClvqYb2EwdMTKOnIESkabrSEspVECy9CNqhKWkaYQlnCynnwTBKvCkSceyvODUnYw6aBdHDULwsyNUbSstWNqhciKv5SgLedHVKqscPNheJYEiSsvwPsLsZQCw)XQlGqyvoRcTZT9Gyu2dHvQkM11YASySEaGqbCzQeectdlpxWGpIxFfRrPpVZDcDqcRXL1ZDcDqYtaMhRbtgyLQIzLkvrwlRF32EvzYELTeoPBalBrTLYJ1GzlrqimnS8Cbd(iE9vClvqYb2EwdMTeLYnoSkBKDwBcRdWynnwVBNBwl0W0AW4pRK)ZH1lTDZAjJshKvxAbbcRxA7gqBScwq4fyB94WQSGzHv3)SgN(KrEbClDGTHWo3sFYkbTNlyOjvRrOiu6NiEhwLZ6sc70nGvAc(e6qaHSkN1OKyi8Lessi98Gyu2dHvQYkvQuAwLZ6pwja6GBpLAaZYZ9)d9jJ8cyfN0nGfwLZ6NS6sliudywEU)FOpzKxaR0ESkN1c6sliuxWPGMLvApwJfJvxAbHAucHGly55Gredm4dN7CoyeowL2J1yXy9twxsyNUbSs6XjGplHoOXQCwlOlTGqLC3lvApw)UT9QIw7v2s4KUbSSf1w6aBdHDULiO9CbdnPAncfHs)eX7WQCwxsyNUbSstWNqhciKv5SgLedHVKqscPNheJYEiSsvwPsLsZQCwlOlTGq1bsxCWxuAN7kThRYz9twDPfeQbmlp3)p0NmYlGvApwLZkm7YdxWXQzPqQ9WQVSU2TuESgmBjccHPHLNlyWhXRVIBBVkLEVYwcN0nGLTO2s5XAWSLiieMgwEUGbFeV(kULc9GVtzlrXA3shyBiSZTebqhC7PuVIl9qEaGSng6XPIt6gWcRYz1LwqOEfx6H8aazBm0JtTaUmBPcsoW2ZAWSLOutqwLeLeRgGvcDueyyv0gx65dcRYwaY2yOhhwBbw)dOz9oxqwTBKvcGo42tPUT9QYu7v2s4KUbSSf1wkpwdMTKqopGW760lizlvqYb2EwdMTKOjhwbcSkAp9csynnwPqMkEwjwEUsyfiWQSvDPGdRIkKfKWkaYA6K9qmwLr8SAj0bnsDlDGTHWo3sljSt3awPj4tOdbeYQCw)XQlTGq9UlfCEUHSGKkXYZvw9vmRuitXASyS(J1pz1d2ayB)FqGLwdgwLZkXddHNLqh0ivHCEaH31PxqcR(kMvzWA8Ssmmd2nwQqGdnY6xw)UT9QuqL9kBjCs3aw2IAlLhRbZwsiNhq4DD6fKSLki5aBpRbZws0KdRabwfTNEbjSAawtpVWFw9anbmewBbw7jpwVGScgwZ5pRwcDqJ1FaiR58Nv3aILECy1sOdAewV02nREWgaB7pRqGLwdMVSMgRRzLT0b2gc7ClLhRxWxby1cMLW)NhOjG5vagRuL18y9c(WbJAKWQCw)X6NS6bBaST)piWsRbdRXIXAbyvNecbgwT(CThhwJfJ1cWQqApJgIvRpx7XH1VSkN1Le2PBaR0e8j0HaczvoRepmeEwcDqJufY5beExNEbjS6RywxZ22Rsbf7v2s4KUbSSf1w6aBdHDULwsyNUbSstWNqhciKv5SEaGqbCzQl4uqZYkeJYEiS6lRuqLTuESgmBj8Cd6X5brpyhLtzB7vPqK9kBjCs3aw2IAlDGTHWo3sljSt3awPj4tOdbeYQCw)XAusme(scjjKEEqmk7HWQywPcRYz9twH0dkaGoyTaarUHSGvCs3awynwmwDPfeQUHEkKUGvApw)ULYJ1GzlLrU0K7TTxLI1SxzlHt6gWYwuBP8yny2sr0whsd3sN)Na(Se6GgzVkfBPdSne25wAjHD6gWknbFcDiGqwLZkXddHNLqh0ivHCEaH31PxqcRIzvKTubjhy7zny2sRKUXv2qBDinKvdWA65f(Z66Izj8N11b0eWWAASkcRwcDqJST9QuiJ9kBjCs3aw2IAlDGTHWo3sljSt3awPj4tOdbeULYJ1GzlfrBDinCBBBlDkK9k7vPyVYwcN0nGLTO2s5XAWSLIs4vS8eaWxbt7Elf6bFNYwII6A3sN)Na(Se6GgzVkfBPdSne25wcMD5Hl4y1SuivApwLZ6pw)K1Le2PBaRKECc4ZsOdASglgRwcDqRADe(mWR0iRuL11qfw)YQCw)XQLqh0QwhHpd8knYkvz9aICbppqpgPwqH(0gRRNvkQRL1yXy9aICbppqpgPwqH(0gR(kM1J3lk95r8WPW63Tubjhy7zny2succSMLcH1eISs75pRKP9qwTBKvWGSEPTBwdGliXyDLvw3kRuQjiRxUXH1Y)ECyvijgcz1UZHv)SoSwqH(0gRaiRxA7gqBSMZFw9Z6u32Evr2RSLWjDdyzlQTuESgmBPOeEflpba8vW0U3sfKCGTN1GzlrjiW6aynlfcRx6qG1sJSEPT7Ey1Urwh0hJ11qfI)SstqwLncRlRcaiRrPpS6N1PYQSBgg5zSAawj)NdRxA7MvrtiDWqiTgmS2cS6biK2nG1T0b2gc7ClbZU8WfCSAwkKApS6lRRHkSgxwHzxE4cownlfsTqdtRbdRYz9aICbppqpgPwqH(0gR(kM1J3lk95r8WPWQCw)K1daekGltLC3lviML)SkN1FS(jRhWco5y1fCS7)qwJfJ1c6sliufcPdgcP1GPs7XASySEaGqbCzQcH0bdH0AWuHyu2dHvFzLI1Y63TTxDn7v2s4KUbSSf1wc4TLiOTLYJ1GzlTKWoDd4wAjd04w6twTmGJvN252iwgUIWkoPBalSglgRFYQLbCSk6djhh6EsdR4KUbSWASySEaGqbCzQOpKCCO7jnScXOShcRuL11YACzvewxpRwgWXQfe9q4JyW0shmQIt6gWYwQGKdS9SgmBjP)ZHvzgNcAwY6LEkGlSEPTBwxTDUnILHRim(40hsoo09KgYAlWA65f6t6gWT0scFtgHBPfCkOz5BANBJyz4kcFhWuARbZ22RkJ9kBjCs3aw2IAlb82se02s5XAWSLwsyNUbClTKbACl9jRwgWXQrjXq4ljKKq6PIt6gWcRXIXAbyvNecbgwT(CThhwJfJ1dybNCS6co29FiRYz9aICbppqpgPwqH(0gRIzLkBPcsoW2ZAWSLOuY2yfmSkZ4uqZswfaqwPKjecmK1lTDZQSr29Nv6jGecRxqwtiYAASgL(WQFwhwfaqwfnH0bdH0AWSLws4BYiClTGtbnlFr57aMsBny22E11UxzlHt6gWYwuBjG3wIG2wkpwdMT0sc70nGBPLe(Mmc3sl4uqZY3bSGto27aMsBny2shyBiSZT0bSGtow96FyNdRXIX6bSGtowDWdeeaWcRXIX6bSGtowDadULki5aBpRbZws6)CyvMXPGMLSEPTBwfnH0bdH0AWWAofwLqpstynjSgaJdRjH1liRxaZhgRbabznz9KeJvWccz1UrwfANBJ1cnmTgmBPLmqJBjk22EvzYELTeoPBalBrTLaEBjcABP8yny2sljSt3aULwYanULecaaK1FS(JvH252Eqmk7HWACzveQW6xwPmR)yLcrOcRRN1Le2PBaRl4uqZY3Paz9lRFz1xwfcaaK1FS(JvH252Eqmk7HWACzveQWACz9aaHc4YufcPdgcP1GPcXOShcRFzLYS(JvkeHkSUEwxsyNUbSUGtbnlFNcK1VS(L1yXy1LwqOkeshmesRbZZLwqOs7XASySwqxAbHQqiDWqiTgmvApwJfJvxaHWQCwfANB7bXOShcRuLvrOYw6aBdHDULoGfCYXQl4y3)HBPLe(Mmc3sl4uqZY3bSGto27aMsBny22EvrR9kBjCs3aw2IAlb82se02s5XAWSLwsyNUbClTKbACljeaaiR)y9hRcTZT9Gyu2dH14YQiuH1VSszw)XkfIqfwxpRljSt3awxWPGMLVtbY6xw)YQVSkeaaiR)y9hRcTZT9Gyu2dH14YQiuH14Y6bacfWLPsqpstQqmk7HW6xwPmR)yLcrOcRRN1Le2PBaRl4uqZY3Paz9lRFznwmwlaRsqpstQwFU2JdRXIXQlGqyvoRcTZT9Gyu2dHvQYQiuzlDGTHWo3shWco5y1PDUTNqIBPLe(Mmc3sl4uqZY3bSGto27aMsBny22Evk9ELTeoPBalBrTLki5aBpRbZws0eqY9bMcgRcaiRRdnXOdiRXjK2ZAWWAlW6amwjgMb7glScGS2dRjRhaiuaxgwp)pbClDGTHWo3s)yLaOdU9uQE0eJoGpes7znyQ4KUbSWASySsa0b3Ek1fqiToGpciSGJvXjDdyH1VSkN1pzLyygSBSuZqGv5S(jRf0LwqOUGtbnlR0ESkN1OKyi8Lessi98Gyu2dHvXSsfwLZ6pwXbHo)RwhHpd8IsFEhqKBpyHvFzvewJfJ1pzTGU0ccvYDVuP9y97wQhdHqAp71cBjcGo42tPUacP1b8raHfCSTupgcH0E2RJIWsNgULOylLhRbZwsiGK7dmfSTupgcH0E2ZjaCZWwIITTxvMAVYwcN0nGLTO2s5XAWSLecPdgcP1GzlvqYb2EwdMTK0)5WQOjKoyiKwdgwV02nRYmof0SK1KWAamoSMewVGSEbmFySgaeK1K1tsmwbliKv7gzvODUnwl0W0AWW6paK1wGvzgNcAwY6Loey9aIqwDZZvwtNShk3ewnGJtalScee(w3shyBiSZT0NSsmmd2nwQqGdnYQCw)X6bacfWLPUGtbnlRqmk7HWkvzDnSkN1Le2PBaRl4uqZYxu(oGP0wdgwLZkkiGhRxW3be5cEEGEmcR(kMvzWQCwTe6Gw16i8zGxPrw9LvkOcRXIXAbDPfeQl4uqZYkThRXIXQlGqyvoRcTZT9Gyu2dHvQYQiYG1VBBVkfuzVYwcN0nGLTO2shyBiSZT0NSsmmd2nwQqGdnYQCwrbb8y9c(oGixWZd0Jry1xXSkdwLZ6pwfcaaK1FS(JvH252Eqmk7HWACzvezW6xwPmR)ynpwdM3bacfWLH11Z6sc70nGvHq6GHqAnyENcK1VS(LvFzviaaqw)X6pwfANB7bXOShcRXLvrKbRXL1daekGltDbNcAwwHyu2dH11Z6sc70nG1fCkOz57uGS(LvkZ6pwZJ1G5DaGqbCzyD9SUKWoDdyviKoyiKwdM3Paz9lRFz97wkpwdMTKqiDWqiTgmBBVkfuSxzlHt6gWYwuBP8yny2se0J0KTubjhy7zny2ss)NdRsOhPjSEPTBwLzCkOzjRjH1ayCynjSEbz9cy(WynaiiRjRNKyScwqiR2nYQq7CBSwOHP1GXFwDPnw9GOacz1sOdAewT70y9shcSg6fK10ynGjXyLcQq2shyBiSZT0NSsmmd2nwQqGdnYQCwlaR6KqiWWQ1NR94WQCw)X6bacfWLPUGtbnlRqmk7HWkvzLcwLZQLqh0QwhHpd8knYQVSsbvynwmwlOlTGqDbNcAwwP9ynwmwDbecRYzvODUTheJYEiSsvwPGkS(DB7vPqK9kBjCs3aw2IAlDGTHWo3sFYkXWmy3yPcbo0iRYz9hRcbaaY6pw)XQq7CBpigL9qynUSsbvy9lRuM18ynyEhaiuaxgw)YQVSkeaaiR)y9hRcTZT9Gyu2dH14YkfuH14Y6bacfWLPUGtbnlRqmk7HW66zDjHD6gW6cof0S8Dkqw)YkLznpwdM3bacfWLH1VS(DlLhRbZwIGEKMST9QuSM9kBjCs3aw2IAlDGTHWo3sFYkXWmy3yPcbo0iRYzTaSkK2ZOHy16Z1ECyvoRFYAbDPfeQl4uqZYkThRYzDjHD6gW6cof0S8nTZTrSmCfHVdykT1GHv5SUKWoDdyDbNcAw(IY3bmL2AWWQCwxsyNUbSUGtbnlFhWco5yVdykT1GzlLhRbZwAbNcAwUT9QuiJ9kBjCs3aw2IAlLhRbZwc9HKJdDpPHBPcsoW2ZAWSLItFi54q3tAiRxUXH1bySsmmd2nwynNcRUa7MvzL2ZOHiR5uyLsMqiWqwtiYkThRcaiRbW4WkoaAN76w6aBdHDUL(KvIHzWUXsfcCOrwLZ6pw)K1cWQojecmScrbisUt3aYQCwlaRcP9mAiwHyu2dHvFzvgSgpRYG11Z6X7fL(8iE4uynwmwlaRcP9mAiwHyu2dH11ZkvQRLvFz1sOdAvRJWNbELgz9lRYz1sOdAvRJWNbELgz1xwLX22RsXA3RSLWjDdyzlQTuESgmBjYDVSLki5aBpRbZws6UxyTfyDDbRqynHiR0E(ZAlW6QTZTXQOjrwtZWipJvdWk5)Cy9sB3SkHEKMWkaYQmJtbnlzTfy9cY6fW8HX6LKyiRraiYQDNdR3zqGvP7E5dcRhaiuaxMT0b2gc7Cl9jRf0LwqOsU7LkThRYz9hRfGvDsieyy16Z1ECyvoRfGvH0EgneRwFU2JdRFzvoR)y9twpGfCYXQt7CBpHeznwmw)X6pwpaqOaUmvc6rAsfIz5pRXIX6bacfWLPsqpstQqmk7HWQVSsHiS(L14z9hRhaiuaxM6cof0SScXS8N1yXy9aaHc4YuxWPGMLvigL9qyD9SUKWoDdyDbNcAw(ofiR(YkfIW6xwfZQiS(L1VBBVkfYK9kBjCs3aw2IAlDGTHWo3sU0ccv3aauc0eRcX8ySglgRUacHv5Sk0o32dIrzpewPkRRHkSglgRf0LwqOUGtbnlR0EBP8yny2sEaRbZ22RsHO1ELTeoPBalBrTLoW2qyNBPc6sliuxWPGMLvAVTuESgmBj3aauEc0W)BBVkfu69kBjCs3aw2IAlDGTHWo3sf0LwqOUGtbnlR0EBP8yny2sUiKGWR94ST9QuitTxzlHt6gWYwuBPdSne25wQGU0cc1fCkOzzL2BlLhRbZwsOHOBaakBBVQiuzVYwcN0nGLTO2shyBiSZTubDPfeQl4uqZYkT3wkpwdMTuohKyWm8oziST9QIqXELTeoPBalBrTLoW2qyNBPpzLyygSBSuZqGv5SgLedHVKqscPNheJYEiSkMvQSLYJ1GzlDYq4LhRbZl0eBlfAI9Mmc3sl50K7TTxver2RSLWjDdyzlQTuESgmBPl9uiNe(UCJgXadULoW2qyNBjIhgcplHoOrQc58acVRtVGew9L1csAiwEwcDqJWASyScZU8WfCSAwkKApS6lRYeQWASyS6ciewLZQq7CBpigL9qyLQSkATLMmc3sx6Pqoj8D5gnIbgCB7vfzn7v2s4KUbSSf1wkpwdMTKb75kAuSLki5aBpRbZws6)Cy1Urw9Gna22FwjwAS6sliWQb75kASEPTBwLzCkOzP)ScSBeEPjiR0eKvWW6bacfWLzlDGTHWo3sljSt3awnypxr7r(pNhjamwfZkfSkN1FSwqxAbH6cof0SSs7XASyS6ciewLZQq7CBpigL9qyLQIzveQW6xwJfJ1FSUKWoDdy1G9CfTh5)CEKaWyvmRIWQCw)Kvd2Zv0QMi1daekGltfIz5pRFznwmw)K1Le2PBaRgSNRO9i)NZJea222RkIm2RSLWjDdyzlQT0b2gc7ClTKWoDdy1G9CfTh5)CEKaWyvmRIWQCw)XAbDPfeQl4uqZYkThRXIXQlGqyvoRcTZT9Gyu2dHvQkMvrOcRFznwmw)X6sc70nGvd2Zv0EK)Z5rcaJvXSsbRYz9twnypxrRAuupaqOaUmviML)S(L1yXy9twxsyNUbSAWEUI2J8FopsayBP8yny2sgSNROjY222wQaS9k7vPyVYwcN0nGLTO2saVTebTTuESgmBPLe2PBa3slzGg3sEWgaB7)dcS0AWWQCw)XAbyvNecbgwHyu2dHvQY6bacfWLP6KqiWWAHgMwdgwJfJ1Le2PBaRq0bNhjnAyAyH1VBPcsoW2ZAWSLKLoQnwj4bmLe(NvkzcHadjSkaGS6bBaST)ScbwAnyyTfy9cY6DUGSUM1Ykoi05pRq0bhwbqwPKjecmK1lDiWk6JxdrwbdR2nYQhSJs4FwTe6G2wAjHVjJWTe5A79o)pb85KqiWWTTxvK9kBjCs3aw2IAlb82se02s5XAWSLwsyNUbClTKbACl5bBaST)piWsRbdRYz9hRf0LwqOsU7LkThRYzL4HHWZsOdAKQqopGW760liHvFzvewJfJ1Le2PBaRq0bNhjnAyAyH1VBPcsoW2ZAWSLKLoQnwj4bmLe(NvzL2ZOHiHvbaKvpydGT9NviWsRbdRTaRxqwVZfK11SwwXbHo)zfIo4WkaYQ0DVWAtyL2JvWWQiRe)wAjHVjJWTe5A79o)pb8bP9mAiUT9QRzVYwcN0nGLTO2saVTebTTuESgmBPLe2PBa3slzGg3sf0LwqOUGtbnlR0ESkN1FSwqxAbHk5UxQ0ESglgRrjXq4ljKKq65bXOShcR(Ykvy9lRYzTaSkK2ZOHyfIrzpew9Lvr2sfKCGTN1GzljlDuBSkR0EgnejS2cSkZ4uqZY4LU7fklBsIHqwLDcjjKEyTjSs7XAofwVGSENliRIepRe8aMcH1akyScgwTBKvzL2ZOHiRRlyLT0scFtgHBjY127bP9mAiUT9QYyVYwcN0nGLTO2s5XAWSLCsiey4wQGKdS9SgmBjjp80zGvkzcHadznNcRYkTNrdrwjOr7XQhSbqwnaRXPpKCCO7jnK1tsST0b2gc7ClzzahRI(qYXHUN0WkoPBalSkN1pz9shcVaGGp0hsoo09KgYQCwlaR6KqiWWQxeDWAVqJqwPQywPGv5SEaGqbCzQOpKCCO7jnScXOShcRuLvryvoRepmeEwcDqJufY5beExNEbjSkMvkyvoRWSlpCbhRMLcP2dR(YQmHv5Swaw1jHqGHvigL9qyD9SsL6AzLQSAj0bTQ1r4ZaVsJBBV6A3RSLWjDdyzlQT0b2gc7ClzzahRI(qYXHUN0WkoPBalSkN1FSIcc4X6f8DarUGNhOhJWQVIz949IsFEepCkSkN1daekGltf9HKJdDpPHvigL9qyLQSsbRYzTaSkK2ZOHyfIrzpewxpRuPUwwPkRwcDqRADe(mWR0iRF3s5XAWSLG0Egne32EvzYELTeoPBalBrTLYJ1Gzl5baHhejaA4b3sfKCGTN1GzlrjtieyiR0Exr0ZFwZabWQbBKWQbyLMGS2gRjH1KvIhE6mWQdoimnaKvbaKv7gznKeJv)SoS6IcaiYAYQqpn5gHBjba8nOp2Evk22EvrR9kBjCs3aw2IAlDGTHWo3squaIK70nGSkN1diYf88a9yKAbf6tBS6RywPGv5S(JvVi6G1EHgHSsvXSsbRXIXkeJYEiSsvXSA956Z6iKv5Ss8Wq4zj0bnsviNhq4DD6fKWQVIzDnS(Lv5S(J1pz9shcVaGGp0hsoo09KgYASyScXOShcRuvmRwFU(SoczD9SkcRYzL4HHWZsOdAKQqopGW760liHvFfZ6Ay9lRYz9hRwcDqRADe(mWR0iRXLvigL9qy9lR(YQmyvoRrjXq4ljKKq65bXOShcRIzLkBP8yny2sojecmCB7vP07v2s4KUbSSf1wsaaFd6JTxLITuESgmBjpai8Gibqdp422RktTxzlHt6gWYwuBP8yny2sojecmClDGTHWo3sFY6sc70nGvY127D(Fc4ZjHqGHSkNvikarYD6gqwLZ6be5cEEGEmsTGc9Pnw9vmRuWQCw)XQxeDWAVqJqwPQywPG1yXyfIrzpewPQywT(C9zDeYQCwjEyi8Se6GgPkKZdi8Uo9csy1xXSUgw)YQCw)X6NSEPdHxaqWh6djhh6EsdznwmwHyu2dHvQkMvRpxFwhHSUEwfHv5Ss8Wq4zj0bnsviNhq4DD6fKWQVIzDnS(Lv5S(JvlHoOvTocFg4vAK14YkeJYEiS(LvFzLcryvoRrjXq4ljKKq65bXOShcRIzLkBPZ)taFwcDqJSxLITTxLcQSxzlHt6gWYwuBP8yny2shyhraZZWipKyBPZ)taFwcDqJSxLIT0b2gc7Clr8Wq4zj0bncR(kMvryvoROGaESEbFhqKl45b6XiS6RywLbRYzfhe68VcrhCEhqKBpyHvFzveQWQCw)X6NSEaGqbCzQl4uqZYkeZYFwJfJ1cWQqApJgIvRpx7XH1VSkNvigL9qyLQSkcRXZ6AyD9S(JvIhgcplHoOry1xXSkdw)ULki5aBpRbZwYpWoIagwxbJ8qIXkyynIoyTxaz1sOdAewtJvzepR(zDy9YnoScPNPhhwb0gR9WQiXDTewtcRbW4WAsy9cY6DUGSIdG25Mvi6GdR5uynH48HXkbnRhhwP9yvaazvMXPGMLBBVkfuSxzlHt6gWYwuBP8yny2sqApJgIBPcsoW2ZAWSLeTr0JvApwLvApJgISMgRYiEwbdRziWQLqh0iS(7YnoSg6LECynaghwXbq7CZAofwhGXkzspYnW(ULoW2qyNBPpzDjHD6gWk5A79G0EgnezvoROGaESEbFhqKl45b6XiS6RywLbRYzfIcqKCNUbKv5S(JvVi6G1EHgHSsvXSsbRXIXkeJYEiSsvXSA956Z6iKv5Ss8Wq4zj0bnsviNhq4DD6fKWQVIzDnS(Lv5S(J1pz9shcVaGGp0hsoo09KgYASyScXOShcRuvmRwFU(SoczD9SkcRYzL4HHWZsOdAKQqopGW760liHvFfZ6Ay9lRYz1sOdAvRJWNbELgznUScXOShcR(Y6pwLbRXZ6pwH0dkaGoyTKK7ECEKdGEkqmuXjDdyH11Z6Az9lRXZ6pwH0dkaGoyTaarUHSGvCs3awyD9SUww)YA8S(J1Le2PBaRq0bNhjnAyAyH11ZQmH1VS(DB7vPqK9kBjCs3aw2IAlLhRbZwcs7z0qClDGTHWo3sFY6sc70nGvY127D(Fc4ds7z0qKv5S(jRljSt3awjxBVhK2ZOHiRYzffeWJ1l47aICbppqpgHvFfZQmyvoRquaIK70nGSkN1FS6frhS2l0iKvQkMvkynwmwHyu2dHvQkMvRpxFwhHSkNvIhgcplHoOrQc58acVRtVGew9vmRRH1VSkN1FS(jRx6q4fae8H(qYXHUN0qwJfJvigL9qyLQIz16Z1N1riRRNvryvoRepmeEwcDqJufY5beExNEbjS6RywxdRFzvoRwcDqRADe(mWR0iRXLvigL9qy1xw)XQmynEw)XkKEqba0bRLKC3JZJCa0tbIHkoPBalSUEwxlRFznEw)XkKEqba0bRfaiYnKfSIt6gWcRRN11Y6xwJN1FSUKWoDdyfIo48iPrdtdlSUEwLjS(L1VBPZ)taFwcDqJSxLITTxLI1SxzlHt6gWYwuBP8yny2shyhraZZWipKyBPcsoW2ZAWSLenzi4MNRSk7G4Kv)a7icyyDfmYdjgRxA7Mv7gzLKriRbGtFynjSMUGf0FwDPnwBNba7XHv7gzfhe68N1dykT1GHWAlW6fK1eIZhgR0KECyvwP9mAiULoW2qyNBjIhgcplHoOry1xXSkcRYzffeWJ1l47aICbppqpgHvFfZQmyvoRqmk7HWkvzvewJN11W66z9hRepmeEwcDqJWQVIzvgS(DB7vPqg7v2s4KUbSSf1wkpwdMT0b2reW8mmYdj2wQGKdS9SgmBj)a7icyyDfmYdjgRGHvPvyTfyThw9YPGr9H1CkSoycd)znk9HvCqOZFwZPWAlWACol4aIy9cy(WyTayncarwlzu6GSwOrwnaRRikklBK9T0b2gc7Clr8Wq4zj0bncRIzLcwLZ6pw)Kvi9GcaOdwlj5UhNh5aONcedvCs3awynwmwDPfeQq6bFxaWYtaciwL2J1VSkN1OKyi8Lessi98Gyu2dHvXSsfwLZkkiGhRxW3be5cEEGEmcR(kM1FSE8ErPppIhofwJlRuW6xwLZkefGi5oDdiRYz9twV0HWlai4d9HKJdDpPHSkN1FS(jRf0LwqOsU7LkThRXIXAbDPfeQoq6Id(Is7CxHyu2dHvFzvew)YQCwTe6Gw16i8zGxPrwJlRqmk7HWQVSkJTTTTTLwqiPbZEvrOIiIqfrOqMAlDjHtpoKTeLISlRRsjSkLu0zL1vUrw7ipa0yvaaz9dIHzWUXYhScrzA6gIfwjGiK1K2arPHfwp354GKktTS0dYQmeDw9dywqOHfwL6i)Wk5)yPpSsjYQbyvwOtwl9stAWWkWdHPbGS(JYFz9hf(8TYuZutPi7Y6QucRsjfDwzDLBK1oYdanwfaqw)yjNMC)bRquMMUHyHvcicznPnquAyH1ZDooiPYull9GSsHOZQFaZccnSW6hq6bfaqhSghFWQby9di9GcaOdwJJkoPBalFW6pr85BLPww6bzvMi6S6hWSGqdlS(bKEqba0bRXXhSAaw)aspOaa6G14OIt6gWYhS(JcF(wzQzQPuKDzDvkHvPKIoRSUYnYAh5bGgRcaiRF4bXdiYnTpyfIY00nelSsariRjTbIsdlSEUZXbjvMAzPhKvzi6S6hWSGqdlS(bbqhC7PuJJpy1aS(bbqhC7PuJJkoPBalFW6pk85BLPww6bzvgIoR(bmli0WcRFqa0b3Ek144dwnaRFqa0b3Ek14OIt6gWYhSMgRXPSfzH1Fu4Z3ktTS0dY6AfDw9dywqOHfw)aspOaa6G144dwnaRFaPhuaaDWACuXjDdy5dw)rHpFRm1YspiRYerNv)aMfeAyH1pG0dkaGoyno(GvdW6hq6bfaqhSghvCs3aw(G1Fu4Z3ktTS0dYQOLOZQFaZccnSW6hgSNROvPOghFWQby9dd2Zv0Qgf144dw)jdF(wzQLLEqwfTeDw9dywqOHfw)WG9CfTQi144dwnaRFyWEUIw1ePghFW6pr85BLPww6bzLsl6S6hWSGqdlS(Hb75kAvkQXXhSAaw)WG9CfTQrrno(G1FI4Z3ktTS0dYkLw0z1pGzbHgwy9dd2Zv0QIuJJpy1aS(Hb75kAvtKAC8bR)KHpFRm1m1ukYUSUkLWQusrNvwx5gzTJ8aqJvbaK1pknep2hScrzA6gIfwjGiK1K2arPHfwp354GKktTS0dYkLw0z1pGzbHgwy9dcGo42tPghFWQby9dcGo42tPghvCs3aw(G1Fu4Z3ktTS0dYkfIi6S6hWSGqdlS(bKEqba0bRXXhSAaw)aspOaa6G14OIt6gWYhS(JcF(wzQzQPuKDzDvkHvPKIoRSUYnYAh5bGgRcaiRFCkKpyfIY00nelSsariRjTbIsdlSEUZXbjvMAzPhKvzIOZQFaZccnSWQuh5hwj)hl9HvkrwnaRYcDYAPxAsdgwbEimnaK1Fu(lR)eXNVvMAzPhKvrlrNv)aMfeAyHvPoYpSs(pw6dRuISAawLf6K1sV0KgmSc8qyAaiR)O8xw)jIpFRm1YspiRuArNv)aMfeAyH1pia6GBpLAC8bRgG1pia6GBpLACuXjDdy5dw)jIpFRm1YspiRuqfrNv)aMfeAyHvPoYpSs(pw6dRuISAawLf6K1sV0KgmSc8qyAaiR)O8xw)jIpFRm1YspiRuiIOZQFaZccnSWQuh5hwj)hl9HvkrwnaRYcDYAPxAsdgwbEimnaK1Fu(lR)eXNVvMAzPhKvrwJOZQFaZccnSW6hgSNROvfPghFWQby9dd2Zv0QMi144dw)rHpFRm1YspiRIidrNv)aMfeAyH1pmypxrRsrno(GvdW6hgSNROvnkQXXhS(JcF(wzQzQPuKDzDvkHvPKIoRSUYnYAh5bGgRcaiRFua2hScrzA6gIfwjGiK1K2arPHfwp354GKktTS0dYkfui6S6hWSGqdlS(bKEqba0bRXXhSAaw)aspOaa6G14OIt6gWYhS(teF(wzQLLEqwPqerNv)aMfeAyH1pG0dkaGoyno(GvdW6hq6bfaqhSghvCs3aw(G1FI4Z3ktTS0dYkfYq0z1pGzbHgwy9di9GcaOdwJJpy1aS(bKEqba0bRXrfN0nGLpy9hf(8TYull9GSsHmeDw9dywqOHfw)asp47cawQXrfN0nGLpy1aS(HlTGqfsp47cawEXrL27dw)rHpFRm1m1ucrEaOHfwfTynpwdgwdnXivM6TKhei0bCl5x)YQStijH0tAnyyvwbo0itTF9lRIg0fsNW)SkcL2FwfHkIictntTF9lR(5ohhKi6m1(1VSgxwLDpVWFw)GyW(yFWQqiDy1aSsariRY(6ilSkaGxjSAawj5cYQheCqcPhhwTocRm1(1VSgxwxxW8HXQmNttUzLEciHWQuOpiR5uyDD7dY6LoeynKeJ1ayCqiR2DoSkBsIHqwLDcjjKEQm1(1VSgxwLvmK(WQOjKoyiKwdgwPmRYmof0SKvY)5W6VwGvzgNcAwYAty1aoobSWkqqGvaKvWWAYAamoS6N19BLP2V(L14YQSjVISkAci5(atbJ1EmecP9mw7H1diYnnwBbwVGSsPcnXyT0fwBJvbaK1fqiToGpciSGJvzQ9RFznUSsPMGSkjkjwJaqKvdWkHokcmSkAJl98bHvzlazBm0JdRTaR)b0SENliR2nYkbqhC7PuzQ9RFznUS6hWSGqJvi9GVlayPkabeJvdWQlTGqfsp47cawEcqaXQ0EvMA)6xwJlRYEPGfwPu6PqojKvkLB0igyWktTF9lRXL1vUG5vSWAC6djhh6Esdz1aS6GgR0eSWAlW6Fa9hliRYmof0SmUKCCO7jnSuzQzQ9RFzno9bp0gwy1ffaqK1diYnnwDrNEivwL9Zb9mcRdyI7DcJeOdSMhRbdHvWe(xzQZJ1GHu9G4be5MM40Zl8)5bAcyyQZJ1GHu9G4be5Mw8IPSlWSawEcH8pwU0JZZa(0dtDESgmKQhepGi30IxmLJs4vS8eaWxbt72FpiEarUP9i4bmfIykOI)TG4ppGfCYXQl4y3)HYHzxE4cownlfsThFPyTm15XAWqQEq8aICtlEXuwiGK7dmfm)BbXeaDWTNs1JMy0b8HqApRbtSyeaDWTNsDbesRd4Jacl4ym15XAWqQEq8aICtlEXuEjHD6gq)NmcfVGtbnlFNc0)LmqJIPiU)G0dkaGoyTqtUEjdxri55L25E9)OsvgRn(Fe0EUGHMuTgHIqPFYW7SEQuP473Vm1(L1vUrwZfeMoiR(zDLvwBcRuPkIiS6sBSwOrwnaR2nYQSUkLK1jnAiYkqGv)SoS6GJ)SkIpSA3nH1LmqJS2ewbEwhLbwfaqwj)NtpoSgao9HPopwdgs1dIhqKBAXlMYljSt3a6)KrOyHq6GHqAnyENc0)LmqJIPiU)G0dkaGoyf4ILgNdUEQuLHm(Yu7xwxx0qyupiRxU7ZnR)AbwZ5)xwjwAS6sliWQb75kASEbz9sogRgG10mmYZy1aSs(phwV02nRYmof0SSYuNhRbdP6bXdiYnT4ft5Le2PBa9FYiuSb75kApY)58ibG5)sgOrXu4Fli2G9CfTkf17K8iwA1C()kEe5)(0G9CfTQi17K8iwA1C()kEKyXmypxrRsr9aaHc4Yul0W0AW4Ryd2Zv0QIupaqOaUm1cnmTgmFJfZG9CfTkf1Mu7HCG0w6gWNmnDogD0RGl9bJf7Nb75kAvkQnPsUZc4IdmjEpdyyK8dybNCS6co29F4xM68ynyivpiEarUPfVykVKWoDdO)tgHInypxr7r(pNhjam)xYankwe)BbXgSNROvfPENKhXsRMZ)xXJi)3NgSNROvPOENKhXsRMZ)xXJelMb75kAvrQhaiuaxMAHgMwdgFnypxrRsr9aaHc4Yul0W0AW8nwmd2Zv0QIuBsThYbsBPBaFY005y0rVcU0hmwSFgSNROvfP2Kk5olGloWK49mGHrYpGfCYXQl4y3)HFzQZJ1GHu9G4be5Mw8IPmXWmy3m15XAWqQEq8aICtlEXuMe6d(YP8k9b93dIhqKBApcEatHiMc)BbXFAzahRoTZTrSmCfHvCs3awyQzQ9RFzno9bp0gwyfxq4FwTocz1UrwZJbGS2ewZLSdPBaRm15XAWqeFTpxzQ9lRYksmmd2nRTaREacPDdiR)gaRl0HbHPBazfhmQrcR9W6be5M2xM68ynyiXlMYedZGDZuNhRbdjEXuEjHD6gq)Nmcft6XjGplHoO5)sgOrXepmeEwcDqJufY5beExNEbjuveMA)YQFarU9GfwJZbHo)zvwrhCyDqSGfwnaRK0OHPHm15XAWqIxmLxsyNUb0)jJqXq0bNhjnAyAyX)LmqJIXbHo)Rq0bN3be52dw8DnRLPopwdgs8IP8jdHxESgmVqtm)Nmcftmmd2nw8NyW(yIPW)wqmXWmy3yPcbo0itDESgmK4ft5tgcV8ynyEHMy(pzek(uim1(L11H2yvAwxwP9yTN26me(ZQaaYQFOnwnaR2nYQFUtc6pRquaIKBwV02nRX5SGdiI1wG10ynaUWAHgMwdgM68ynyiXlMYKqFWxoLxPpO)TG4pDPfeQKqFWxoLxPpyL2t(be5cEEGEmIVIPGPopwdgs8IPmol4aI8Vfe7sliujH(GVCkVsFWkTNCxAbHkj0h8Lt5v6dwHyu2dHQRv(be5cEEGEmIVILbtDESgmK4ft5tgcV8ynyEHMy(pzekUamM68ynyiXlMYNmeE5XAW8cnX8FYiuCPH4XyQZJ1GHeVykNWto4ZaqioM)TGyCqOZ)Abf6tB(kMI1gpoi05FfIo48oGi3EWctDESgmK4ft5eEYbFE0bcYuNhRbdjEXuo0o3g5rPcDXjchJPopwdgs8IPSB68acpd2NReMAMA)6xw9daekGldHP2VSsjiWAwkewtiYkTN)SsM2dz1UrwbdY6L2UznaUGeJ1vwzDRSsPMGSE5ghwl)7XHvHKyiKv7ohw9Z6WAbf6tBScGSEPTBaTXAo)z1pRtLPopwdgs9uiIJs4vS8eaWxbt72)qp47uetrDT(F(Fc4ZsOdAeXu4FligMD5Hl4y1SuivAp5)(CjHD6gWkPhNa(Se6GwSywcDqRADe(mWR0ivxdv(k)NLqh0QwhHpd8kns1diYf88a9yKAbf6tBRNI6AJf7aICbppqpgPwqH(0MVIpEVO0NhXdNYxMA)YkLGaRdG1SuiSEPdbwlnY6L2U7Hv7gzDqFmwxdvi(Zknbzv2iSUSkaGSgL(WQFwNkRYUzyKNXQbyL8FoSEPTBwfnH0bdH0AWWAlWQhGqA3awzQZJ1GHupfs8IPCucVILNaa(kyA3(3cIHzxE4cownlfsThFxdvIlm7YdxWXQzPqQfAyAnyKFarUGNhOhJulOqFAZxXhVxu6ZJ4Htr(NhaiuaxMk5UxQqml)L)7ZdybNCS6co29FySyf0LwqOkeshmesRbtL2lwSdaekGltviKoyiKwdMkeJYEi(sXA)Yu7xwL(phwLzCkOzjRx6PaUW6L2UzD1252iwgUIW4JtFi54q3tAiRTaRPNxOpPBazQZJ1GHupfs8IP8sc70nG(pzekEbNcAw(M252iwgUIW3bmL2AW4)sgOrXFAzahRoTZTrSmCfHvCs3awIf7tld4yv0hsoo09KgwXjDdyjwSdaekGltf9HKJdDpPHvigL9qO6AJRiR3YaowTGOhcFedMw6GrvCs3awyQ9lRukzBScgwLzCkOzjRcaiRuYecbgY6L2Uzv2i7(Zk9eqcH1liRjeznnwJsFy1pRdRcaiRIMq6GHqAnyyQZJ1GHupfs8IP8sc70nG(pzekEbNcAw(IY3bmL2AW4)sgOrXFAzahRgLedHVKqscPNkoPBalXIvaw1jHqGHvRpx7XjwSdybNCS6co29FO8diYf88a9yKAbf6tBIPctTFzv6)CyvMXPGMLSEPTBwfnH0bdH0AWWAofwLqpstynjSgaJdRjH1liRxaZhgRbabznz9KeJvWccz1UrwfANBJ1cnmTgmm15XAWqQNcjEXuEjHD6gq)NmcfVGtbnlFhWco5yVdykT1GX)wq8bSGtow96FyNtSyhWco5y1bpqqaalXIDal4KJvhWG(VKbAumfm15XAWqQNcjEXuEjHD6gq)NmcfVGtbnlFhWco5yVdykT1GX)wq8bSGtowDbh7(p0)LmqJIfcaa83pH252Eqmk7HexrOYxkXFuicvw)sc70nG1fCkOz57uGF)6RqaaG)(j0o32dIrzpK4kcvI7bacfWLPkeshmesRbtfIrzpKVuI)OqeQS(Le2PBaRl4uqZY3Pa)(nwmxAbHQqiDWqiTgmpxAbHkTxSyf0LwqOkeshmesRbtL2lwmxaHixODUTheJYEiuveQWuNhRbdPEkK4ft5Le2PBa9FYiu8cof0S8Dal4KJ9oGP0wdg)BbXhWco5y1PDUTNqI(VKbAuSqaaG)(j0o32dIrzpK4kcv(sj(JcrOY6xsyNUbSUGtbnlFNc87xFfcaa83pH252Eqmk7HexrOsCpaqOaUmvc6rAsfIrzpKVuI)OqeQS(Le2PBaRl4uqZY3Pa)(nwScWQe0J0KQ1NR94elMlGqKl0o32dIrzpeQkcvyQ9lRIMasUpWuWyvaazDDOjgDaznoH0EwdgwBbwhGXkXWmy3yHvaK1Eynz9aaHc4YW65)jGm15XAWqQNcjEXuwiGK7dmfm)BbX)ia6GBpLQhnXOd4dH0EwdMyXia6GBpL6ciKwhWhbewWX(k)tIHzWUXsndb5FwqxAbH6cof0SSs7jpkjgcFjHKesppigL9qetf5)WbHo)RwhHpd8IsFEhqKBpyXxrIf7Zc6sliuj39sL27R)9yies7zVokclDAOyk8VhdHqAp75eaUzqmf(3JHqiTN9AbXeaDWTNsDbesRd4Jacl4ym1(LvP)ZHvrtiDWqiTgmSEPTBwLzCkOzjRjH1ayCynjSEbz9cy(WynaiiRjRNKyScwqiR2nYQq7CBSwOHP1GH1FaiRTaRYmof0SK1lDiW6beHS6MNRSMozpuUjSAahNawyfii8TYuNhRbdPEkK4ftzHq6GHqAny8Vfe)jXWmy3yPcbo0O8FhaiuaxM6cof0SScXOShcvxJ8Le2PBaRl4uqZYxu(oGP0wdg5OGaESEbFhqKl45b6Xi(kwgYTe6Gw16i8zGxPrFPGkXIvqxAbH6cof0SSs7flMlGqKl0o32dIrzpeQkIm(YuNhRbdPEkK4ftzHq6GHqAny8Vfe)jXWmy3yPcbo0OCuqapwVGVdiYf88a9yeFfld5)ecaa83pH252Eqmk7HexrKXxkXFhaiuaxM1VKWoDdyviKoyiKwdM3Pa)(1xHaaa)9tODUTheJYEiXveze3daekGltDbNcAwwHyu2dz9ljSt3awxWPGMLVtb(Ls83bacfWLz9ljSt3awfcPdgcP1G5DkWVF)Yu7xwL(phwLqpsty9sB3SkZ4uqZswtcRbW4WAsy9cY6fW8HXAaqqwtwpjXyfSGqwTBKvH252yTqdtRbJ)S6sBS6brbeYQLqh0iSA3PX6Loeyn0liRPXAatIXkfuHWuNhRbdPEkK4ftzc6rAI)TG4pjgMb7glviWHgLxaw1jHqGHvRpx7Xr(VdaekGltDbNcAwwHyu2dHQui3sOdAvRJWNbELg9LcQelwbDPfeQl4uqZYkTxSyUacrUq7CBpigL9qOkfu5ltDESgmK6PqIxmLjOhPj(3cI)KyygSBSuHahAu(pHaaa)9tODUTheJYEiXLcQ8Ls8aaHc4Y81xHaaa)9tODUTheJYEiXLcQe3daekGltDbNcAwwHyu2dz9ljSt3awxWPGMLVtb(Ls8aaHc4Y89ltDESgmK6PqIxmLxWPGML(3cI)KyygSBSuHahAuEbyviTNrdXQ1NR94i)Zc6sliuxWPGMLvAp5ljSt3awxWPGMLVPDUnILHRi8DatPTgmYxsyNUbSUGtbnlFr57aMsBnyKVKWoDdyDbNcAw(oGfCYXEhWuARbdtTFzno9HKJdDpPHSE5ghwhGXkXWmy3yH1CkS6cSBwLvApJgISMtHvkzcHadznHiR0ESkaGSgaJdR4aODURm15XAWqQNcjEXug9HKJdDpPH(3cI)KyygSBSuHahAu(VplaR6KqiWWkefGi5oDdO8cWQqApJgIvigL9q8vgXlJ1F8ErPppIhoLyXkaRcP9mAiwHyu2dz9uPUwFTe6Gw16i8zGxPXVYTe6Gw16i8zGxPrFLbtTFzv6UxyTfyDDbRqynHiR0EuQYAlW6QTZTXQOjrwtZWipJvdWk5)Cy9sB3SkHEKMWkaYQmJtbnlzTfy9cY6fW8HX6LKyiRraiYQDNdR3zqGvP7E5dcRhaiuaxgM68ynyi1tHeVyktU7f)BbXFwqxAbHk5UxQ0EY)vaw1jHqGHvRpx7XrEbyviTNrdXQ1NR948v(VppGfCYXQt7CBpHeJf73VdaekGltLGEKMuHyw(hl2bacfWLPsqpstQqmk7H4lfI8n(FhaiuaxM6cof0SScXS8pwSdaekGltDbNcAwwHyu2dz9ljSt3awxWPGMLVtb6lfI8vSiF)YuNhRbdPEkK4ftzpG1GX)wqSlTGq1naaLanXQqmpwSyUacrUq7CBpigL9qO6AOsSyf0LwqOUGtbnlR0Em15XAWqQNcjEXu2naaLNan8V)TG4c6sliuxWPGMLvApM68ynyi1tHeVyk7IqccV2JJ)TG4c6sliuxWPGMLvApM68ynyi1tHeVykl0q0naaf)BbXf0LwqOUGtbnlR0Em15XAWqQNcjEXuoNdsmygENme8VfexqxAbH6cof0SSs7XuNhRbdPEkK4ft5tgcV8ynyEHMy(pzekEjNMC7Fli(tIHzWUXsndb5rjXq4ljKKq65bXOShIyQWuNhRbdPEkK4ftzAc(AdJ8FYiu8LEkKtcFxUrJyGb9Vfet8Wq4zj0bnsviNhq4DD6fK4BbjnelplHoOrIfdMD5Hl4y1Sui1E8vMqLyXCbeICH252Eqmk7HqvrlMA)YQ0)5WQDJS6bBaST)SsS0y1LwqGvd2Zv0y9sB3SkZ4uqZs)zfy3i8stqwPjiRGH1daekGldtDESgmK6PqIxmLnypxrJc)BbXljSt3awnypxr7r(pNhjamXui)xbDPfeQl4uqZYkTxSyUacrUq7CBpigL9qOQyrOY3yX(TKWoDdy1G9CfTh5)CEKaWelI8pnypxrRks9aaHc4YuHyw()nwSpxsyNUbSAWEUI2J8Fopsaym15XAWqQNcjEXu2G9Cfnr8VfeVKWoDdy1G9CfTh5)CEKaWelI8Ff0LwqOUGtbnlR0EXI5cie5cTZT9Gyu2dHQIfHkFJf73sc70nGvd2Zv0EK)Z5rcatmfY)0G9CfTkf1daekGltfIz5)3yX(CjHD6gWQb75kApY)58ibGXuZu7x)Y662q8ySwYO0bznD7qBnsyQ9lRX5SGdiI10yvgXZ6V1gpRxA7M11v6lR(zDQSsjefHLonm8NvWWQiXZQLqh0i(Z6L2UzvMXPGML(ZkaY6L2UzDfrrPkRa7gHxAcY6LSnwfaqwjGiKvCqOZ)kRYEGay9s2gRTaRXPpehwpGixaRnH1diQhhwP9Qm15XAWqQLgIhtmol4aI8VfeJcc4X6f8DarUGNhOhJ4RyzeVLbCSAbrpe(igmT0bJQ4KUbSi)xbDPfeQl4uqZYkTxSyf0LwqOsU7LkTxSyf0LwqOkeshmesRbtL2lwmCqOZ)Abf6tBuvSiRnECqOZ)keDW5DarU9GLyX(CjHD6gWkPhNa(Se6GwSyOGaESEbFhqKl45b6Xi(E8ErPppIhoLVY)9PLbCSk6djhh6EsdR4KUbSel2bacfWLPI(qYXHUN0WkeJYEi(kYxM68ynyi1sdXJfVykVKWoDdO)tgHIPj4tOdbe6)sgOrXhqKl45b6Xi1ck0N28LIyXWbHo)RfuOpTrvXIS24XbHo)Rq0bN3be52dwIf7ZLe2PBaRKECc4ZsOdAm1(Lvz3Zl8NvjrjXQbyndbwTe6GgH1lTDdOnwtwlOlTGaRjHvpydGT93Fw9GOacH94WQLqh0iSw(3JdReayqiRPGHqwTBKvpyhLW)SAj0bnM68ynyi1sdXJfVyktqimnS8Cbd(iE9v0)wq8sc70nGvAc(e6qaHY)SaSkbHW0WYZfm4J41xXxbyvRpx7XHPopwdgsT0q8yXlMYeectdlpxWGpIxFf9)8)eWNLqh0iIPW)wq8sc70nGvAc(e6qaHY)SaSkbHW0WYZfm4J41xXxbyvRpx7XHP2VSkAJOhRcqqeRN0ZRhhwp3j0bjScGS6sdhwtJv7gzfNcRabwfANBJWuNhRbdPwAiES4ftzccHPHLNlyWhXRVI(3cIxsyNUbSstWNqhciuEusme(scjjKEEqmk7HqvQuP0Y)5cie5cTZT9Gyu2dHQIxBSyhaiuaxMkbHW0WYZfm4J41xXAu6Z7CNqhKe3ZDcDqYtaMhRbtgOQyQufzTFzQ9lRuk34WQSr2zTjSoaJ10y9UDUzTqdtRbJ)Ss(phwV02nRLmkDqwDPfeiSEPTBaTXkybHxGT1JdRYcMfwD)ZAC6tg5fqM68ynyi1sdXJfVyktqimnS8Cbd(iE9v0)wq8Ne0EUGHMuTgHIqPFI4DKVKWoDdyLMGpHoeqO8OKyi8Lessi98Gyu2dHQuPsPL)JaOdU9uQbmlp3)p0NmYlGvCs3awK)PlTGqnGz55()H(KrEbSs7jVGU0cc1fCkOzzL2lwmxAbHAucHGly55Gredm4dN7CoyeowL2lwSpxsyNUbSs6XjGplHoOjVGU0ccvYDVuP9(YuNhRbdPwAiES4ftzccHPHLNlyWhXRVI(3cIjO9CbdnPAncfHs)eX7iFjHD6gWknbFcDiGq5rjXq4ljKKq65bXOShcvPsLslVGU0ccvhiDXbFrPDUR0EY)0LwqOgWS8C))qFYiVawP9KdZU8WfCSAwkKAp(UwMA)YkLAcYQKOKy1aSsOJIadRI24spFqyv2cq2gd94WAlW6FanR35cYQDJSsa0b3EkvM68ynyi1sdXJfVyktqimnS8Cbd(iE9v0)qp47uetXA9Vfeta0b3Ek1R4spKhaiBJHECK7sliuVIl9qEaGSng6XPwaxgMA)YQOjhwbcSkAp9csynnwPqMkEwjwEUsyfiWQSvDPGdRIkKfKWkaYA6K9qmwLr8SAj0bnsLPopwdgsT0q8yXlMYc58acVRtVGe)BbXljSt3awPj4tOdbek)NlTGq9UlfCEUHSGKkXYZvFftHmvSy)(0d2ayB)FqGLwdg5epmeEwcDqJufY5beExNEbj(kwgXtmmd2nwQqGdn(9ltTFzv0KdRabwfTNEbjSAawtpVWFw9anbmewBbw7jpwVGScgwZ5pRwcDqJ1FaiR58Nv3aILECy1sOdAewV02nREWgaB7pRqGLwdMVSMgRRzfM68ynyi1sdXJfVyklKZdi8Uo9cs8VfeNhRxWxby1cMLW)NhOjG5vagvZJ1l4dhmQrI8FF6bBaST)piWsRbtSyfGvDsieyy16Z1ECIfRaSkK2ZOHy16Z1EC(kFjHD6gWknbFcDiGq5epmeEwcDqJufY5beExNEbj(kEnm15XAWqQLgIhlEXugp3GECEq0d2r5u8VfeVKWoDdyLMGpHoeqO8daekGltDbNcAwwHyu2dXxkOctDESgmKAPH4XIxmLZixAYT)TG4Le2PBaR0e8j0HacL)lkjgcFjHKesppigL9qetf5FcPhuaaDWAbaICdzbJfZLwqO6g6Pq6cwP9(Yu7xwxjDJRSH26qAiRgG10Zl8N11fZs4pRRdOjGH10yvewTe6GgHPopwdgsT0q8yXlMYr0whsd9)8)eWNLqh0iIPW)wq8sc70nGvAc(e6qaHYjEyi8Se6GgPkKZdi8Uo9cselctDESgmKAPH4XIxmLJOToKg6FliEjHD6gWknbFcDiGqMAMA)6xwx3mkDqwbliKvRJqwt3o0wJeMA)YQS0rTXkbpGPKW)SsjtieyiHvbaKvpydGT9NviWsRbdRTaRxqwVZfK11SwwXbHo)zfIo4WkaYkLmHqGHSEPdbwrF8AiYkyy1Urw9GDuc)ZQLqh0yQZJ1GHulat8sc70nG(pzekMCT9EN)Na(CsieyO)lzGgf7bBaST)piWsRbJ8FfGvDsieyyfIrzpeQEaGqbCzQojecmSwOHP1GjwSLe2PBaRq0bNhjnAyAy5ltTFzvw6O2yLGhWus4FwLvApJgIewfaqw9Gna22FwHalTgmS2cSEbz9oxqwxZAzfhe68Nvi6GdRaiRs39cRnHvApwbdRISs8m15XAWqQfGfVykVKWoDdO)tgHIjxBV35)jGpiTNrdr)xYank2d2ayB)FqGLwdg5)kOlTGqLC3lvAp5epmeEwcDqJufY5beExNEbj(ksSyljSt3awHOdopsA0W0WYxMA)YQS0rTXQSs7z0qKWAlWQmJtbnlJx6UxOSSjjgczv2jKKq6H1MWkThR5uy9cY6DUGSks8SsWdykewdOGXkyy1UrwLvApJgISUUGvyQZJ1GHulalEXuEjHD6gq)NmcftU2EpiTNrdr)xYankUGU0cc1fCkOzzL2t(Vc6sliuj39sL2lwSOKyi8Lessi98Gyu2dXxQ8vEbyviTNrdXkeJYEi(kctTFzvYdpDgyLsMqiWqwZPWQSs7z0qKvcA0ES6bBaKvdWAC6djhh6Esdz9KeJPopwdgsTaS4ftzNecbg6Fli2Yaowf9HKJdDpPHvCs3awK)5LoeEbabFOpKCCO7jnuEbyvNecbgw9IOdw7fAesvXui)aaHc4YurFi54q3tAyfIrzpeQkICIhgcplHoOrQc58acVRtVGeXuihMD5Hl4y1Sui1E8vMiVaSQtcHadRqmk7HSEQuxlvTe6Gw16i8zGxPrM68ynyi1cWIxmLH0Egne9VfeBzahRI(qYXHUN0WkoPBalY)Hcc4X6f8DarUGNhOhJ4R4J3lk95r8WPi)aaHc4YurFi54q3tAyfIrzpeQsH8cWQqApJgIvigL9qwpvQRLQwcDqRADe(mWR04xMA)YkLmHqGHSs7Dfrp)zndeaRgSrcRgGvAcYABSMewtwjE4PZaRo4GW0aqwfaqwTBK1qsmw9Z6WQlkaGiRjRc90KBeYuNhRbdPwaw8IPShaeEqKaOHh0Fba8nOpMykyQZJ1GHulalEXu2jHqGH(3cIHOaej3PBaLFarUGNhOhJulOqFAZxXui)NxeDWAVqJqQkMIyXGyu2dHQIT(C9zDekN4HHWZsOdAKQqopGW760liXxXR5R8FFEPdHxaqWh6djhh6EsdJfdIrzpeQk26Z1N1r46froXddHNLqh0ivHCEaH31PxqIVIxZx5)Se6Gw16i8zGxPX4cXOShYxFLH8OKyi8Lessi98Gyu2drmvyQZJ1GHulalEXu2dacpisa0Wd6Vaa(g0htmfm15XAWqQfGfVyk7KqiWq)p)pb8zj0bnIyk8Vfe)5sc70nGvY127D(Fc4ZjHqGHYHOaej3PBaLFarUGNhOhJulOqFAZxXui)NxeDWAVqJqQkMIyXGyu2dHQIT(C9zDekN4HHWZsOdAKQqopGW760liXxXR5R8FFEPdHxaqWh6djhh6EsdJfdIrzpeQk26Z1N1r46froXddHNLqh0ivHCEaH31PxqIVIxZx5)Se6Gw16i8zGxPX4cXOShYxFPqe5rjXq4ljKKq65bXOShIyQWu7xw9dSJiGH1vWipKyScgwJOdw7fqwTe6GgH10yvgXZQFwhwVCJdRq6z6XHvaTXApSksCxlH1KWAamoSMewVGSENliR4aODUzfIo4WAofwtioFySsqZ6XHvApwfaqwLzCkOzjtDESgmKAbyXlMYhyhraZZWipKy(F(Fc4ZsOdAeXu4FliM4HHWZsOdAeFflICuqapwVGVdiYf88a9yeFfld54GqN)vi6GZ7aIC7bl(kcvK)7ZdaekGltDbNcAwwHyw(hlwbyviTNrdXQ1NR948voeJYEiuvK4xZ6)r8Wq4zj0bnIVILXxMA)YQOnIESs7XQSs7z0qK10yvgXZkyyndbwTe6GgH1FxUXH1qV0JdRbW4WkoaANBwZPW6amwjt6rUb2xM68ynyi1cWIxmLH0Egne9Vfe)5sc70nGvY127bP9mAikhfeWJ1l47aICbppqpgXxXYqoefGi5oDdO8FEr0bR9cncPQykIfdIrzpeQk26Z1N1rOCIhgcplHoOrQc58acVRtVGeFfVMVY)95LoeEbabFOpKCCO7jnmwmigL9qOQyRpxFwhHRxe5epmeEwcDqJufY5beExNEbj(kEnFLBj0bTQ1r4ZaVsJXfIrzpeF)jJ4)bPhuaaDWAjj3948iha9uGyy9R9B8)G0dkaGoyTaarUHSGRFTFJ)3sc70nGvi6GZJKgnmnSSEzY3Vm15XAWqQfGfVykdP9mAi6)5)jGplHoOretH)TG4pxsyNUbSsU2EVZ)taFqApJgIY)CjHD6gWk5A79G0EgneLJcc4X6f8DarUGNhOhJ4RyzihIcqKCNUbu(pVi6G1EHgHuvmfXIbXOShcvfB956Z6iuoXddHNLqh0ivHCEaH31PxqIVIxZx5)(8shcVaGGp0hsoo09KgglgeJYEiuvS1NRpRJW1lICIhgcplHoOrQc58acVRtVGeFfVMVYTe6Gw16i8zGxPX4cXOShIV)Kr8)G0dkaGoyTKK7ECEKdGEkqmS(1(n(Fq6bfaqhSwaGi3qwW1V2VX)BjHD6gWkeDW5rsJgMgwwVm57xMA)YQOjdb38CLvzheNS6hyhradRRGrEiXy9sB3SA3iRKmcznaC6dRjH10fSG(ZQlTXA7maypoSA3iR4GqN)SEatPTgmewBbwVGSMqC(WyLM0JdRYkTNrdrM68ynyi1cWIxmLpWoIaMNHrEiX8Vfet8Wq4zj0bnIVIfrokiGhRxW3be5cEEGEmIVILHCigL9qOQiXVM1)J4HHWZsOdAeFflJVm1(Lv)a7icyyDfmYdjgRGHvPvyTfyThw9YPGr9H1CkSoycd)znk9HvCqOZFwZPWAlWACol4aIy9cy(WyTayncarwlzu6GSwOrwnaRRikklBKDM68ynyi1cWIxmLpWoIaMNHrEiX8Vfet8Wq4zj0bnIykK)7ti9GcaOdwlj5UhNh5aONcedXIbPh8DbalvbiGyvCs3aw(kpkjgcFjHKesppigL9qetf5OGaESEbFhqKl45b6Xi(k(3X7fL(8iE4uIlfFLdrbisUt3ak)ZlDi8cac(qFi54q3tAO8FFwqxAbHk5UxQ0EXIvqxAbHQdKU4GVO0o3vigL9q8vKVYTe6Gw16i8zGxPX4cXOShIVYGPMP2V(LvjdZGDJfwL9J1GHWu7xwxTDUjwgUIqwbdRRzfrNv)a7icyyDfmYdjgtDESgmKkXWmy3yr8b2reW8mmYdjM)TGyld4y1PDUnILHRiSIt6gWICIhgcplHoOr8v8AKFarUGNhOhJ4Ryzi3sOdAvRJWNbELgJleJYEi(ktyQ9lRR2o3eldxriRGHvkwr0zvAspYnWyvwP9mAiYuNhRbdPsmmd2nwIxmLH0Egne9VfeBzahRoTZTrSmCfHvCs3awKFarUGNhOhJ4Ryzi3sOdAvRJWNbELgJleJYEi(ktyQ9lRs0UgcfODqrNvz3Zl8NvaKvzffGi5M1lTDZQlTGawyLsMqiWqctDESgmKkXWmy3yjEXu2dacpisa0Wd6Vaa(g0htmfm15XAWqQedZGDJL4ftzNecbg6)5)jGplHoOretH)TGyld4yvcTRHqbAhSIt6gWI8pV0HWlai4d9HKJdDpPHY)bXOShcvPqekr0hsoo09KgwEW0WyX8IOdw7fAesvXu8vULqh0QwhHpd8kngxigL9q8veMA)YQeTRHqbAhK14zno9H4WkyyLIveDwLvuaIKBwPKjecmK10y1UrwXPWkqGvIHzWUz1aS6GgRrPpSwOHP1GHvxuaarwJtFi54q3tAitDESgmKkXWmy3yjEXu2dacpisa0Wd6Vaa(g0htmfm15XAWqQedZGDJL4ftzNecbg6Fli2YaowLq7AiuG2bR4KUbSi3Yaowf9HKJdDpPHvCs3awKNhRxWhoyuJeXui3LwqOsODnekq7GvigL9qOkf11WuZu7x)YQmNttUzQ9lRIMEAYnRxA7M1O0hw9Z6WQaaY6QTZTrSmCfH(Zk9eqcHvAspoSUUyA3H)SkDNfWfctDESgmK6son5w8sc70nG(pzekEANBJyz4kcFhV3bmL2AW4)sgOrX)(espOaa6G1cM2D4)JCNfWfICuqapwVGVdiYf88a9yeFfF8ErPppIhoLVXI9dspOaa6G1cM2D4)JCNfWfI8diYf88a9yeQkYxMA)YQmNttUz9sB3SgN(qCynEwxTDUnILHRiu0zv2K(0r0rS6N1H1CkSgN(qCyfIz5pRcaiRd6JXkL0pRltDESgmK6son5oEXuEjNMC7Fli2Yaowf9HKJdDpPHvCs3awKBzahRoTZTrSmCfHvCs3awKVKWoDdyDANBJyz4kcFhV3bmL2AWi)aaHc4YurFi54q3tAyfIrzpeQsbtTFzvMZPj3SEPTBwxTDUnILHRiK14zDvaRXPpehrNvzt6thrhXQFwhwZPWQmJtbnlzL2JPopwdgsDjNMChVykVKttU9VfeBzahRoTZTrSmCfHvCs3awK)PLbCSk6djhh6EsdR4KUbSiFjHD6gW60o3gXYWve(oEVdykT1GrEbDPfeQl4uqZYkThtDESgmK6son5oEXu2dacpisa0Wd6Vaa(g0htmf(J(yW8Lra6XelJ1YuNhRbdPUKttUJxmLxYPj3(3cITmGJvj0UgcfODWkoPBalYpaqOaUmvNecbgwP9KxqxAbH6cof0SSs7j)xbyvNecbgwHOaej3PBaJfRaSQtcHadREr0bR9cncPQyk(k)aICbppqpgPwqH(0MVI)r8Wq4zj0bnsviNhq4DD6fK4RS1Y4RCy2LhUGJvZsHu7XxkeHP2VSkZ50KBwV02nRYMKyiKvzNqsspIoRYkTNrdX4PKjecmK1byS2dRquaIKBwH54G(ZAHg2JdRYmof0SmEP7EPYQ0)5W6L2Uzvc9inHvHEYaR3TXAlWQhGqA3awzQZJ1GHuxYPj3XlMYl50KB)BbX)SmGJvJsIHWxsijH0tfN0nGLyXG0dkaGoynkHxFaHNDJVOKyi8Lessi98v(NfGvH0EgneRquaIK70nGYlaR6KqiWWkeJYEi(Ug5f0LwqOUGtbnlR0EY)vqxAbHk5UxQ0EXIvqxAbH6cof0SScXOShcvLrSyfGvjOhPjvRpx7X5R8cWQe0J0KkeJYEiuDnBjIhE2RkYALP2222Ba]] )


end
