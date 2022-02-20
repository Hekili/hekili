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


    spec:RegisterPack( "Assassination", 20220219, [[divXNdqiqWJqb5ssLGnHk9jurnkqYPaPwLsKEfQWSqHULurTlP8lPsnmqvDmqLLHI6zkr10qf5AkrSnPc4BsLqgNub6CGqQ1jvqVdfurZdf4EGY(OO8pPsO0bLkrluQipuQKMiiexuQqTruq5JGqzKsLqXjrbvTsvOxIIeMPsuCtuK0orr8tPsOAOkrPLkvipvjnvqvUkkOsBffP(kks0ybHQ9Is)vLgSOdt1If4Xk1Kf6YqBgjFgvnAv0PLSAuqfETky2u62cA3k(TQgofooiKy5aphX0jUosTDPQVRegpfvNheTEqiP5tr2pPzHJfESRrxqwMWm8zMz4ZmCq0nMH)s4eCSRcKgi7QHVp48i764Hi7AxsioHuJl1pSRgoK23JSWJDL80GnYUEkIbPd7UB(soPdA7pSBsfsBDP(zdCkPBsfU7MDnGUScd)WgWUgDbzzcZWNzMHpZWbr3GdIEjCA5lND1PLZhWUUwHDLD9SIrCydyxJizZU2LeIti14s9JMD0ZtJ6rgggaODaKAchenJAYm8zMz9OESRN(WJKoup2zn7sddlKAYzIaQTWznPSoVMYRj5drn7YLDz0K6bhiAkVMeVh10a8BKqQHxtPcXMESZAcr(HZIMmTpf5ut6XIeIMR2AJA6tutisTrnxuwRMwNiAA)HhbAkN(Ojt1jcc0SljeNqQPPh7SMDeADZ1KHzDE0ADP(rZU1KPXjII4AsGC2AcvrPjtJtefX1SiAkppVfJA(uuA(an)rtxt7p8A2vic0n9yN1KP6hqnzywKCUboLOzncca0gIM1O5(ddCrZIsZfOMmCqtenJvuZs0K6bA2)wxklEjVThhPPh7SMmCjOMRDAvZWhGAkVMe6WWF0KPa7RHZen7I)qurBn8AwuAc5tR5P3JAkNOMKN2gutSPh7SMD9NEeiAcOh8U4bXgf4jIMYRzanfvdqp4DXdIxkWtKgTrtp2zn7YyeJAYuwtKSDGMmLNOqKFWMESZAcVfOFaJA2XMt8HNUgxqnLxtEu0KMGrnlknH8P5CpQjtJtefX7mXhE6ACbJn9OESJnh30cg1maPEaQ5(ddCrZaKVgstZUCVrdHO58tNpDqifTvtFl1pen)Xcztp6BP(H0ma4(ddCbMByyH8A8f5h9OVL6hsZaG7pmWfoG1DWlIfJxkRdjgxud)vEZRrp6BP(H0ma4(ddCHdyDh6Gdy8s9GBeD5KrdaU)WaxUeC)tKado4Zyrbdc7VhhFKwpoYjKaUaVIxShhP5XiPvJzWTe9OVL6hsZaG7pmWfoG1nLfjNBGtjmwuWipTnOMyZGMi0w8IaAdP(XKjYtBdQj26FRlLfVK32JJOh9Tu)qAgaC)HbUWbSU7Dq5bwKXXdry94err87ocyS3T0im46mua6bPEap2I0KdlC7beqUgUSpxkuWVXPLWbueuUb)qtAsHaM7GxozSxk8BWbn0qRhH3jQP3JaNh1SRqKosZIOj8BmZSMb0IMrAut51uorn7iMaX0CCHgGA(uA21LvtECyutMnxt5SiA27wAuZIO5BivOB1K6bAsGC21WRP95RTE03s9dPzaW9hg4chW6U3bLhyrghpeHrzDE0ADP(5UJag7DlncdUodfGEqQhWJTpaJfoBCPWVXjobTEeIGcccRb1CXzTp1eQIstFGeAnjIlAgqtrPPaQ5akAUa1CHpIMYRPlcgAiAkVMeiNTMlk5utMgNikI30J(wQFindaU)Wax4aw39oO8alY44HimbuZbuUeiN9LyFHXE3sJWGJXIcMaQ5akn4ANo5sexA(a5nAq4cfeeqnhqPXC70jxI4sZhiVrdIjtcOMdO0GRT)3g)ftlsdCP(XmycOMdO0yUT)3g)ftlsdCP(bAtMeqnhqPbxRiTAiBaT4bw8crH2hHo8gX(AJMmbLaQ5akn4AfPro94VGh4eJR8cgYD)944J06XroHeaTE03s9dPzaW9hg4chW6U3bLhyrghpeHjGAoGYLa5SVe7lm27wAegZmwuWeqnhqPXC70jxI4sZhiVrdcxOGGaQ5akn4ANo5sexA(a5nAqmzsa1CaLgZT9)24VyArAGl1pMjGAoGsdU2(FB8xmTinWL6hOnzsa1CaLgZTI0QHSb0IhyXlefAFe6WBe7RnAYeucOMdO0yUvKg50J)cEGtmUYlyi393JJpsRhh5esa06rFl1pKMba3FyGlCaRBIGUvo1J(wQFindaU)Wax4aw3eBTXRpXBS2iJgaC)HbUCj4(NibgCmwuWGG4wCK2u8NcrC7be0WXdSyupQh7yZXnTGrnXEeaPMsfIAkNOM(wEGMfrtV3lRhyXME03s9db2HAFqp2rirq3kNAwuAA8esfyrnHAEn7PTdc8alQjoyyHenRrZ9hg4c06rFl1peoG1nrq3kN6rFl1peoG1DVdkpWImoEicJudVfVId4rHXE3sJWigO1EfhWJcPr5Z9PUhMQhjmGz9yx)WGAWOMD8GaEi1SJqEC0CqmIrnLxtIl0axq9OVL6hchW6U3bLhyrghpeHbqECUexObUGrg7DlncdheWdzdG84C3Fyqny0SLVe9OVL6hchW6E7w713s9Z1weHXXdryebDRCIrgjcO2cm4ySOGre0TYjgBGNNg1J(wQFiCaR7TBTxFl1pxBreghpeHTJe94YslAUoqenPn0SMsk3AHutQhOzxPfnLxt5e1SRNobzutasbqYPMlk5uZoE6X5d1SO00fnT)cnJ0axQF0J(wQFiCaRBIT241N4nwBKXIcgecOPOAeBTXRpXBS2yJ2G7(dd(RXxJqmdgC6rFl1peoG1no948HmwuWcOPOAeBTXRpXBS2yJ2GBanfvJyRnE9jEJ1gBam0RHWGLWD)Hb)14RriMbJt6rFl1peoG192T2RVL6NRTicJJhIWIVOh9Tu)q4aw3B3AV(wQFU2IimoEiclwaCl6rFl1peoG1Td2(Gx5baCeglky4GaEiBrKQ2Lygm4wch4GaEiBaKhN7(ddQbJ6rFl1peoG1Td2(GxdAlb1J(wQFiCaRBBXFkKldh0r(qCe9OVL6hchW6oW5Vp1va1(arpQh76)24Vyi6rgEkn9yKOPdqnPnyutYugOMYjQ5pOMlk5ut7VajIMWdEqKMMmCjOMloXrZiK1WRjLteeOPC6JMDDz1mIu1UenFGMlk58Pfn9bsn76Y20J(wQFiTDKal0bhW4L6b3i6YjJ2AW7ocdU2syCd52IxXb8OqGbhJffmGxXl2JJ08yK0On4cfe6Dq5bwSrQH3IxXb8OyYK4aEuAsfIx5VXczWYHp0CHsCapknPcXR83yHmy)Hb)14RriTisv7swkCTLyY0(dd(RXxJqArKQ2LygSTXn0n)smWjcTEKHNsZ510JrIMlkRvZyHAUOKZA0uornh0CrZLdFcJAstqnzQuqenPEGMHU5A21LTPzxkcgAiAkVMeiNTMlk5utgM15rR1L6hnlknnEcPcSytp6BP(H02rchW6o0bhW4L6b3i6YjJffmGxXl2JJ08yK0QXSLd)od8kEXECKMhJKwKg4s9d39hg8xJVgH0IivTlXmyBJBOB(LyGtKle2)BJ)IProR(ga9iKCHcc7VhhFKwpoYjKatMIyanfvJY68O16s9tJ2WKP9)24VyAuwNhTwxQFAam0RHygClbA94kKZwtMgNikIR5IAI)cnxuYPMmP4pfI42diGJo2CIp8014cQzrPPByyRThyr9OVL6hsBhjCaR7EhuEGfzC8qewporue)of)Pqe3Eab39pXsQFyS3T0imiiUfhPnf)Pqe3EabnC8algnzccIBXrAO5eF4PRXfSHJhyXOjt7)TXFX0qZj(WtxJlydGHEnegSKoZ8sf3IJ0IiAGGlraU48yydhpWIr9itPxIM)OjtJtefX1K6bAcXCa4fuZfLCQjtTlzut6XIeIMlqnDaQPlAg6MRzxxwnPEGMmmRZJwRl1p6rFl1pK2os4aw39oO8alY44HiSECIOi(n0V7FILu)WyVBPryqqClosl0jccUoH4esnnC8algnzk(sJ3bGxWMu7d1WBY0(7XXhP1JJCcjG7(dd(RXxJqArKQ2Lad(6XviNTMmnoruexZfLCQjdZ68O16s9JM(e1CfnifrtNOP9hEnDIMlqnx8dNfnTpb101C7erZVhbAkNOMuf)POzKg4s9JE03s9dPTJeoG1DVdkpWImoEicRhNikIF3Fpo(i39pXsQFySOGT)EC8rAhGeu(yY0(7XXhPn4g82henzA)944J0MFqg7Dlncdo9OVL6hsBhjCaR7EhuEGfzC8qewporue)U)EC8rU7FILu)WyrbB)944J06XroHeWyVBPryu2)bqbfvXFkxag61q6mZWh6UauWXm8xAVdkpWITECIOi(DhbqdTzu2)bqbfvXFkxag61q6mZWVZ7)TXFX0OSopATUu)0ayOxdb6UauWXm8xAVdkpWITECIOi(DhbqdTjtb0uunkRZJwRl1p3aAkQgTHjtrmGMIQrzDE0ADP(PrByYuWtiCPk(t5cWqVgcdyg(6rFl1pK2os4aw39oO8alY44HiSECIOi(D)944JC3)elP(HXIc2(7XXhPnf)PCPCKXE3sJWOS)dGckQI)uUam0RH0zMHp0DbOGJz4V0EhuEGfB94err87ocGgAZOS)dGckQI)uUam0RH0zMHFN3)BJ)IPrqdsrAam0RHaDxak4yg(lT3bLhyXwporue)UJaOH2KP4lncAqkstQ9HA4nzk4jeUuf)PCbyOxdHbmdF9idZIKZnWPenPEGMllnrOTOMDmG2qQF0SO0CErtIGUvoXOMpqZA001C)Vn(lgn3qUTOE03s9dPTJeoG1nLfjNBGtjmwuWGI802GAIndAIqBXlcOnK6htMipTnOMyR)TUuw8sEBpoc0CHarq3kNyS5wlxieXaAkQwporueVrBWn0jccUoH4esnxag61qGbFUqHdc4HSjviEL)g6MF3Fyqny0mMnzccrmGMIQroR(gTb0mwJGaaTHCRWqmwUGWGJXAeeaOnKlV9dClm4ySgbbaAd5wuWipTnOMyR)TUuw8sEBpoIECfYzRjdZ68O16s9JMlk5utMgNikIRPt00(dVMorZfOMl(HZIM2NGA6AUDIO53JanLtutQI)u0msdCP(rtOEGMfLMmnoruexZfL1Q5(drnd89bnDEVMUlIMYZZBXOMpff0n9OVL6hsBhjCaRBkRZJwRl1pmwuWGarq3kNySbEEAKlu7)TXFX06XjII4nag61qyWY527GYdSyRhNikIFd97(Nyj1pCrkkClvpE3FyWFn(AeIzW4exXb8O0KkeVYFJfAgCW3KPigqtr16XjII4nAdtMcEcHlvXFkxag61qyaZCcA9OVL6hsBhjCaRBkRZJwRl1pmwuWGarq3kNySbEEAKlsrHBP6X7(dd(RXxJqmdgN4cfL9Fauqrv8NYfGHEnKoZmNGUla1(FB8xmlT3bLhyXgL15rR1L6N7ocGgAZOS)dGckQI)uUam0RH0zM5uN3)BJ)IP1JtefXBam0RHS0EhuEGfB94err87ocGUla1(FB8xmlT3bLhyXgL15rR1L6N7ocGgAO1JRqoBnxrdsr0CrjNAY04errCnDIM2F410jAUa1CXpCw00(eutxZTten)EeOPCIAsv8NIMrAGl1pmQzaTOPbaPqGMId4rHOPC6IMlkRvtB1JA6IMw0jIMWbFIE03s9dPTJeoG1nbnifHXIcgeic6w5eJnWZtJCJV04Da4fSj1(qn8CHA)Vn(lMwporueVbWqVgcdGJR4aEuAsfIx5VXcndo4BYuedOPOA94err8gTHjtbpHWLQ4pLlad9Aimao4dTE03s9dPTJeoG1nbnifHXIcgeic6w5eJnWZtJCHIY(pakOOk(t5cWqVgsNHd(q3f2)BJ)IbAZOS)dGckQI)uUam0RH0z4GFN3)BJ)IP1JtefXBam0RHS0EhuEGfB94err87ocGUlS)3g)fd0qRh9Tu)qA7iHdyD3JtefXzSOGbbIGUvoXyd880i34lnaTHqdWMu7d1WZfcrmGMIQ1JtefXB0gC7Dq5bwS1JtefXVtXFkeXThqWD)tSK6hU9oO8al26XjII43q)U)jws9d3EhuEGfB94err87(7XXh5U)jws9JESJnN4dpDnUGAU4ehnNx0KiOBLtmQPprndE5uZoI2qObOM(e1eI5aWlOMoa1K2qtQhOP9hEnX5P5pB6rFl1pK2os4aw3O5eF4PRXfKXIcgeic6w5eJnWZtJCHccXxA8oa8c2aifajNEGf5gFPbOneAa2ayOxdXmoXbNw624g6MFjg4exkuW1fIV0a0gcnaBO5eF4PRXfmEbUGqBYu8LgG2qObydGHEnKLc)2smtCapknPcXR83yHqZvCapknPcXR83yHMXj946z1RzrPje5HhrthGAsBWWPMfLMmP4pfnzyoQPlcgAiAkVMeiNTMlk5uZv0GuenFGMmnoruexZIsZfOMl(HZIMlCIGAg(aut50hnpDlLMRNvpNjAU)3g)fJE03s9dPTJeoG1n5S6zSOGbHigqtr1iNvFJ2GluXxA8oa8c2KAFOgEUXxAaAdHgGnP2hQHhAUqbH93JJpsBk(t5s5Ojtqb1(FB8xmncAqksdGEestM2)BJ)IPrqdsrAam0RHygCmdnhqT)3g)ftRhNikI3aOhH0KP9)24VyA94err8gad9AilT3bLhyXwporue)UJaZGJzOHXm0qRh9Tu)qA7iHdyDB8s9dJffSaAkQwG9)OLMina6BXKPGNq4sv8NYfGHEnegSC4BYuedOPOA94err8gTHE03s9dPTJeoG1DG9)4LIgajJffSigqtr16XjII4nAd9OVL6hsBhjCaR7aeqqWHA4zSOGfXaAkQwporueVrBOh9Tu)qA7iHdyDtvamW(FKXIcwedOPOA94err8gTHE03s9dPTJeoG1TpBKia3E3U1YyrblIb0uuTECIOiEJ2qp6BP(H02rchW6E7w713s9Z1weHXXdry9(uKtglkyqGiOBLtm2CRLBOteeCDcXjKAUam0RHad(6rFl1pK2os4aw30e8wcgY44HiSf1ejBhCxCIcr(bzSOGrmqR9koGhfsJYN7tDpmvpsmlIKcGXR4aEuiMmb8kEXECKMhJKwnM1bGVjtbpHWLQ4pLlad9AimOlspUc5S1uornna1dkbsnjIlAgqtrPPaQ5akAUOKtnzACIOioJA(YjcwueutAcQ5pAU)3g)fJE03s9dPTJeoG1TaQ5akWXyrbR3bLhyXMaQ5akxcKZ(sSVadoUqfXaAkQwporueVrByYuWtiCPk(t5cWqVgcdGXm8H2KjO6Dq5bwSjGAoGYLa5SVe7lWyMleeqnhqPXCB)Vn(lMga9iKqBYee6Dq5bwSjGAoGYLa5SVe7l6rFl1pK2os4aw3cOMdOWmJffSEhuEGfBcOMdOCjqo7lX(cmM5cvedOPOA94err8gTHjtbpHWLQ4pLlad9AimagZWhAtMGQ3bLhyXMaQ5akxcKZ(sSVadoUqqa1CaLgCT9)24VyAa0JqcTjtqO3bLhyXMaQ5akxcKZ(sSVOh1JqKcGBrZOh68OMEqzlPqIESJNEC(qnDrtoXHMqTeo0CrjNAcrwHwZUUSnnz4ddXy5cAHuZF0Kzo0uCapkeg1CrjNAY04errCg18bAUOKtnHxNy4uZxorWIIGAUWlrtQhOj5drnXbb8q20SlTKxZfEjAwuA2XMt41C)HbVMfrZ9hwdVM0gn9OVL6hslwaClWWPhNpKXIcgsrHBP6X7(dd(RXxJqmdgN4qCloslIObcUeb4IZJHnC8alg5cvedOPOA94err8gTHjtrmGMIQroR(gTHjtrmGMIQrzDE0ADP(PrByYeoiGhYwePQDjmagZlHdCqapKnaYJZD)Hb1GrtMGqVdkpWInsn8w8koGhftMqkkClvpE3FyWFn(AeIzBJBOB(LyGteAUqbbXT4in0CIp8014c2WXdSy0KP9)24VyAO5eF4PRXfSbWqVgIzmdTE03s9dPflaUfoG1DVdkpWImoEicJMGxQYAraJ9ULgHT)WG)A81iKwePQDjMbNjt4GaEiBrKQ2LWaymVeoWbb8q2aipo39hgudgnzcc9oO8al2i1WBXR4aEu0JDPHHfsnx70QMYRPBTAkoGhfIMlk58PfnDnJyanfLMortdq9GsGKrnnaifca1WRP4aEuiAgHSgEnj)piqtNsqGMYjQPbOcDaKAkoGhf9OVL6hslwaClCaRBccaUGXBWp4Lyuhqglky9oO8al2Oj4LQSweWfcXxAeeaCbJ3GFWlXOoG34lnP2hQHxp6BP(H0Ifa3chW6MGaGly8g8dEjg1bKXnKBlEfhWJcbgCmwuW6Dq5bwSrtWlvzTiGleIV0iia4cgVb)GxIrDaVXxAsTpudVEKPardnPaFOMB3WOgEn3NoGhjA(andObJMUOPCIAItuZNstQI)ui6rFl1pKwSa4w4aw3eeaCbJ3GFWlXOoGmwuW6Dq5bwSrtWlvzTiGBOteeCDcXjKAUam0RHWa436GCHk4jeUuf)PCbyOxdHbWwIjt7)TXFX0iia4cgVb)GxIrDaBHU539Pd4rsN3NoGhjxkGVL6h3YayWVX8sGwpYuEIJMm1UuZIO58IMUO5zXFQzKg4s9dJAsGC2AUOKtnJEOZJAgqtrr0CrjNpTO53JGfGsQHxZLb9OMbqQzhBUhAyr9OVL6hslwaClCaRBccaUGXBWp4LyuhqglkyqGGYn4hAstkeWCh8YSXMBVdkpWInAcEPkRfbCdDIGGRtioHuZfGHEnega)whKluKN2gutSzrpEdG8IM7HgwSHJhyXixieqtr1SOhVbqErZ9qdl2On4gXaAkQwporueVrByYuanfvl0bGFbgV8yir(bV4C6ZgdXrA0gMmbHEhuEGfBKA4T4vCapkCJyanfvJCw9nAdO1J(wQFiTybWTWbSUjia4cgVb)GxIrDazSOGrq5g8dnPjfcyUdEz2yZT3bLhyXgnbVuL1IaUHorqW1jeNqQ5cWqVgcdGFRdYnIb0uunEaDKhVHUSpB0gCHqanfvZIE8ga5fn3dnSyJ2GlWR4f7XrAEmsA1y2s0JmCjOMRDAvt51Kqhg(JMmfyFnCMOzx8hIkARHxZIstiFAnp9Eut5e1K802GAIn9OVL6hslwaClCaRBccaUGXBWp4LyuhqgT1G3DegClHXIcg5PTb1eBhW(Ai3)HOI2A45gqtr1oG91qU)drfT1W3I)IrpYW8rZNstMIP6rIMUOjCq0COjr89bIMpLMDXuXioA2jRhrIMpqtN3RHiAYjo0uCapkKME03s9dPflaUfoG1nLp3N6EyQEKWyrbR3bLhyXgnbVuL1IaUqfqtr1oRyeNBG1JiPreFFWmyWbrBYeuqWaupOeiVGxCP(HlXaT2R4aEuinkFUp19Wu9iXmyCIdIGUvoXyd880i0qRhzy(O5tPjtXu9irt510nmSqQPXxKFiAwuAwJVLQh18hn9bsnfhWJIMq9an9bsndSigRHxtXb8Oq0CrjNAAaQhucKAcEXL6hO10fnxo80J(wQFiTybWTWbSUP85(u3dt1Jeg3qUT4vCapkeyWXyrbdkiyaQhucKxWlUu)yYu8LgVdaVGnP2hQH3KP4lnaTHqdWMu7d1Wdn3EhuEGfB0e8svwlc4smqR9koGhfsJYN7tDpmvpsmd2Y1J(wQFiTybWTWbSUX95xd)fGgGk0NiJffSEhuEGfB0e8svwlc4U)3g)ftRhNikI3ayOxdXm4GVE03s9dPflaUfoG1ThgqtozSOG17GYdSyJMGxQYAraxOcDIGGRtioHuZfGHEneyWNlea0ds9aESf)pmW6r0KPaAkQwGTMiPIyJ2aA9i88GoZuPLY6cQP8A6ggwi1eIGE0cPMl7xKF00fnzwtXb8Oq0J(wQFiTybWTWbSUdPLY6cY4gYTfVId4rHadoglky9oO8al2Oj4LQSweWLyGw7vCapkKgLp3N6EyQEKaJz9OVL6hslwaClCaR7qAPSUGmwuW6Dq5bwSrtWlvzTiqpQhHiEOZJA(9iqtPcrn9GYwsHe94YuHLOjb3)eDaKAcXCa4fKOj1d00aupOei1e8Il1pAwuAUa1807rnx(s0eheWdPMaKhhnFGMqmhaEb1CrzTAIMBuauZF0uornnavOdGutXb8OOh9Tu)qAXxG17GYdSiJJhIWihkJ7gYTfV8oa8cYyVBPrygG6bLa5f8Il1pCHk(sJ3bGxWgad9Aimy)Vn(lMgVdaVGTinWL6htM6Dq5bwSbqECUexObUGrO1JltfwIMeC)t0bqQzhrBi0aKOj1d00aupOei1e8Il1pAwuAUa1807rnx(s0eheWdPMaKhhnFGMRNvVMfrtAdn)rtMHhh6rFl1pKw8foG1DVdkpWImoEicJCOmUBi3w8cOneAaYyVBPrygG6bLa5f8Il1pCHkIb0uunYz13On4smqR9koGhfsJYN7tDpmvpsmJztM6Dq5bwSbqECUexObUGrO1JltfwIMDeTHqdqIMfLMmnorueNJ1ZQVBMQteeOzxsioHuJMfrtAdn9jQ5cuZtVh1Kzo0KG7FIenTiLO5pAkNOMDeTHqdqnHip80J(wQFiT4lCaR7EhuEGfzC8qeg5qzCb0gcnazS3T0iSigqtr16XjII4nAdUqfXaAkQg5S6B0gMmf6ebbxNqCcPMlad9AiMbFO5gFPbOneAa2ayOxdXmM1JRg4UCRMqmhaEb10NOMDeTHqdqnjOqBOPbOEGMYRzhBoXhE6ACb1C7erp6BP(H0IVWbSU5Da4fKXIcM4wCKgAoXhE6ACbB44bwmYfclkR9AFcErZj(WtxJli34lnEhaEbBgH0wPmSfcyam44U)3g)ftdnN4dpDnUGnag61qyaZCjgO1EfhWJcPr5Z9PUhMQhjWGJlWR4f7XrAEmsA1ywhGB8LgVdaVGnag61qwk8BlHbId4rPjviEL)glup6BP(H0IVWbSUb0gcnazSOGjUfhPHMt8HNUgxWgoEGfJCHcPOWTu94D)Hb)14RriMbBBCdDZVedCIC3)BJ)IPHMt8HNUgxWgad9AimaoUXxAaAdHgGnag61qwk8BlHbId4rPjviEL)gleA9ieZbGxqnPnoGObJA6wYRPakKOP8AstqnlrtNOPRjXa3LB1Khhe4Yd0K6bAkNOMwNiA21LvZaK6bOMUMu1uKteOh9Tu)qAXx4aw3g)BVaK80GnYi1dUdAUado9OVL6hsl(chW6M3bGxqglkyaKcGKtpWIC3FyWFn(AeslIu1UeZGbhxOmcPTszyleWayWzYead9AimaMu7dxPcrUed0AVId4rH0O85(u3dt1JeZGTCO5cfewuw71(e8IMt8HNUgxqtMayOxdHbWKAF4kviUuM5smqR9koGhfsJYN7tDpmvpsmd2YHMluId4rPjviEL)glSZam0RHaTzCIBOteeCDcXjKAUam0RHad(6rFl1pKw8foG1TX)2lajpnyJms9G7GMlWGtp6BP(H0IVWbSU5Da4fKXnKBlEfhWJcbgCmwuWGqVdkpWInYHY4UHCBXlVdaVGCbifajNEGf5U)WG)A81iKwePQDjMbdoUqzesBLYWwiGbWGZKjag61qyamP2hUsfICjgO1EfhWJcPr5Z9PUhMQhjMbB5qZfkiSOS2R9j4fnN4dpDnUGMmbWqVgcdGj1(WvQqCPmZLyGw7vCapkKgLp3N6EyQEKygSLdnxOehWJstQq8k)nwyNbyOxdbAZGJzUHorqW1jeNqQ5cWqVgcm4Rh7kOcj)Oj8WqdKiA(JMH0wPmSOMId4rHOPlAYjo0SRlRMloXrta9m1WR5tlAwJMm35Lq00jAA)HxtNO5cuZtVh1eNNM)utaYJJM(e10b4Wzrtcksn8AsBOj1d0KPXjII46rFl1pKw8foG19guHKFUcgAGeHXnKBlEfhWJcbgCmwuWigO1EfhWJcXmymZfPOWTu94D)Hb)14RriMbJtCXbb8q2aipo39hgudgnJz4ZfkiS)3g)ftRhNikI3aOhH0KP4lnaTHqdWMu7d1Wdnxag61qyaZCS8LcfXaT2R4aEuiMbJtqRhzkq0qtAdn7iAdHgGA6IMCIdn)rt3A1uCapkenHAXjoAAR(A410(dVM4808NA6tuZ5fnjJBqoFbA9OVL6hsl(chW6gqBi0aKXIcge6Dq5bwSrougxaTHqdqUiffULQhV7pm4VgFncXmyCIlaPai50dSixOmcPTszyleWayWzYead9AimaMu7dxPcrUed0AVId4rH0O85(u3dt1JeZGTCO5cfewuw71(e8IMt8HNUgxqtMayOxdHbWKAF4kviUuM5smqR9koGhfsJYN7tDpmvpsmd2YHMR4aEuAsfIx5VXc7mad9AiMbfN4aka9GupGhBrNCwd)LSF6jcq7sxc0CafGEqQhWJT4)HbwpIlDjqZbu9oO8al2aipoxIl0axW4s7aqdTE03s9dPfFHdyDdOneAaY4gYTfVId4rHadoglkyqO3bLhyXg5qzC3qUT4fqBi0aKle6Dq5bwSrougxaTHqdqUiffULQhV7pm4VgFncXmyCIlaPai50dSixOmcPTszyleWayWzYead9AimaMu7dxPcrUed0AVId4rH0O85(u3dt1JeZGTCO5cfewuw71(e8IMt8HNUgxqtMayOxdHbWKAF4kviUuM5smqR9koGhfsJYN7tDpmvpsmd2YHMR4aEuAsfIx5VXc7mad9AiMbfN4aka9GupGhBrNCwd)LSF6jcq7sxc0CafGEqQhWJT4)HbwpIlDjqZbu9oO8al2aipoxIl0axW4s7aqdTEKH5wBGVpOzx(DSMDfuHKF0eEyObsenxuYPMYjQjXdrnTpFT10jA6bFpYOMb0IMf)8GA41uornXbb8qQ5(Nyj1penlknxGA6aC4SOjnPgEn7iAdHgG6rFl1pKw8foG19guHKFUcgAGeHXIcgXaT2R4aEuiMbJzUiffULQhV7pm4VgFncXmyCIlad9AimGzow(sHIyGw7vCapkeZGXjO1JDfuHKF0eEyObsen)rZv4PzrPznAA4tedRTM(e1CqhyHuZq3CnXbb8qQPprnlkn74PhNpuZf)WzrZ4Rz4dqnJEOZJAgPrnLxt41PUzQDPE03s9dPfFHdyDVbvi5NRGHgirySOGrmqR9koGhfcm44cfea0ds9aESfDYzn8xY(PNiaTMmbOh8U4bXgf4jsdhpWIrO5g6ebbxNqCcPMlad9AiWGpxKIc3s1J39hg8xJVgHygmO2g3q38lXaNyNHdAUaKcGKtpWICHWIYAV2NGx0CIp8014cYfkieXaAkQg5S6B0gMmfXaAkQgpGoYJ3qx2Nnag61qmJzO5koGhLMuH4v(BSWodWqVgIzCspQhxf0TYjg1Sl3s9drpYKI)KiU9ac08hnxo86qn7kOcj)Oj8WqdKi6rFl1pKgrq3kNye2guHKFUcgAGeHXIcM4wCK2u8NcrC7be0WXdSyKlXaT2R4aEuiMbB5C3FyWFn(AeIzW4exXb8O0KkeVYFJf2zag61qmRdOhzsXFse3EabA(JMWbVouZ1XniNVOzhrBi0aup6BP(H0ic6w5eJCaRBaTHqdqglkyIBXrAtXFkeXThqqdhpWIrU7pm4VgFncXmyCIR4aEuAsfIx5VXc7mad9AiM1b0JR0bccOO5XouZU0WWcPMpqZocPai5uZfLCQzanffg1eI5aWlirp6BP(H0ic6w5eJCaRBJ)TxasEAWgzK6b3bnxGbNE03s9dPre0TYjg5aw38oa8cY4gYTfVId4rHadoglkyIBXrAe6abbu08ydhpWIrUqyrzTx7tWlAoXhE6ACb5cfad9AimaoM7cO5eF4PRXfmEbUGMmzesBLYWwiGbWGdAUId4rPjviEL)glSZam0RHygZ6Xv6abbu08OMCOzhBoHxZF0eo41HA2rifajNAcXCa4futx0uornXjQ5tPjrq3kNAkVM8OOzOBUMrAGl1pAgGupa1SJnN4dpDnUG6rFl1pKgrq3kNyKdyDB8V9cqYtd2iJup4oO5cm40J(wQFinIGUvoXihW6M3bGxqglkyIBXrAe6abbu08ydhpWIrUIBXrAO5eF4PRXfSHJhyXixFlvpEXbdlKadoUb0uuncDGGakAESbWqVgcdGRTC9OEKP9PiN6rgwnf5uZfLCQzOBUMDDz1K6bAYKI)uiIBpGag1KESiHOjnPgEnHiOlNwi1C90J)cIE03s9dP17troH17GYdSiJJhIWMI)uiIBpGG724U)jws9dJ9ULgHbfea0ds9aESfrxoTqEjNE8xq4Iuu4wQE8U)WG)A81ieZGTnUHU5xIborOnzcka9GupGhBr0LtlKxYPh)feU7pm4VgFncHbmdTEKP9PiNAUOKtn7yZj8AYHMmP4pfI42diOd1KP6MxH0HA21LvtFIA2XMt41eGEesnPEGMdAUOjeRRqe9OVL6hsR3NICYbSU79PiNmwuWe3IJ0qZj(WtxJlydhpWIrUIBXrAtXFkeXThqqdhpWIrU9oO8al2MI)uiIBpGG724U)jws9d39)24VyAO5eF4PRXfSbWqVgcdGtpY0(uKtnxuYPMmP4pfI42diqto0KjVMDS5e(outMQBEfshQzxxwn9jQjtJtefX1K2qp6BP(H069PiNCaR7EFkYjJffmXT4iTP4pfI42diOHJhyXixiiUfhPHMt8HNUgxWgoEGfJC7Dq5bwSnf)Pqe3Eab3TXD)tSK6hUrmGMIQ1JtefXB0g6rFl1pKwVpf5KdyDB8V9cqYtd2iJup4oO5cm4yenxa(1dF6rGXPLOh9Tu)qA9(uKtoG1DVpf5KXIcM4wCKgHoqqafnp2WXdSyK7(FB8xmnEhaEbB0gCJyanfvRhNikI3On4cv8LgVdaVGnasbqYPhyrtMIV04Da4fSzesBLYWwiGbWGdAU7pm4VgFncPfrQAxIzWGIyGw7vCapkKgLp3N6EyQEKywxSCcAUaVIxShhP5XiPvJzWXSEKP9PiNAUOKtnzQorqGMDjH4KA6qn7iAdHgGCaXCa4fuZ5fnRrtasbqYPMaF4rg1msdQHxtMgNikIZX6z130CfYzR5Iso1CfnifrtQACRMNLOzrPPXtivGfB6rFl1pKwVpf5KdyD37trozSOGbL4wCKwOteeCDcXjKAA44bwmAYeGEqQhWJTqhC4(ux5eVHorqW1jeNqQbAUqi(sdqBi0aSbqkaso9alYn(sJ3bGxWgad9AiMTCUrmGMIQ1JtefXB0gCHkIb0uunYz13OnmzkIb0uuTECIOiEdGHEnegWjtMIV0iObPinP2hQHhAUXxAe0GuKgad9Aimy5SR2Iiew4XUse0TYjgzHhltGJfESR44bwmY2j2vFl1pSRBqfs(5kyObse21is2GYqQFyxzsXFse3EabA(JMlhEDOMDfuHKF0eEyObse21nOeeuo7Q4wCK2u8NcrC7be0WXdSyutUAsmqR9koGhfIMMbtZLRjxn3FyWFn(AeIMMbttoPjxnfhWJstQq8k)nwOMDwtag61q00mn7aScltyMfESR44bwmY2j2vFl1pSRaAdHgGSRrKSbLHu)WUYKI)KiU9ac08hnHdEDOMRJBqoFrZoI2qObi76gucckNDvClosBk(tHiU9acA44bwmQjxn3FyWFn(AeIMMbttoPjxnfhWJstQq8k)nwOMDwtag61q00mn7aScltwol8yxXXdSyKTtSR(wQFyxn(3Ebi5PbBKDnIKnOmK6h21v6abbu08yhQzxAyyHuZhOzhHuaKCQ5Iso1mGMIcJAcXCa4fKWUs9G7GMlSmbowHLjCIfESR44bwmY2j21nOeeuo7Q4wCKgHoqqafnp2WXdSyutUAcbnxuw71(e8IMt8HNUgxqn5QjuAcWqVgIMmqt4ywZU1enN4dpDnUGXlWfuttM00iK2kLHTqGMmaMMWPj0AYvtXb8O0KkeVYFJfQzN1eGHEnennttMzx9Tu)WUY7aWli76gYTfVId4rHWYe4yfwMSew4XUIJhyXiBNyx9Tu)WUA8V9cqYtd2i7AejBqzi1pSRR0bccOO5rn5qZo2CcVM)OjCWRd1SJqkaso1eI5aWlOMUOPCIAItuZNstIGUvo1uEn5rrZq3CnJ0axQF0maPEaQzhBoXhE6ACbzxPEWDqZfwMahRWYKoal8yxXXdSyKTtSRBqjiOC2vXT4incDGGakAESHJhyXOMC1uClosdnN4dpDnUGnC8alg1KRM(wQE8IdgwirtyAcNMC1mGMIQrOdeeqrZJnag61q0KbAcxB5SR(wQFyx5Da4fKvyf21EFkYjl8yzcCSWJDfhpWIr2oXU(gSReuyx9Tu)WU27GYdSi7AVBPr2vO0ecAcOhK6b8ylIUCAH8so94VG0WXdSyutUAIuu4wQE8U)WG)A81ienndMMBJBOB(LyGtutO10KjnHsta9GupGhBr0LtlKxYPh)fKgoEGfJAYvZ9hg8xJVgHOjd0KznHMDT3b3Xdr21P4pfI42di4UnU7FILu)WUgrYgugs9d7kdRMICQ5Iso1m0nxZUUSAs9anzsXFkeXThqaJAspwKq0KMudVMqe0LtlKAUE6XFbHvyzcZSWJDfhpWIr2oXU6BP(HDT3NICYUgrYgugs9d7kt7tro1CrjNA2XMt41KdnzsXFkeXThqqhQjt1nVcPd1SRlRM(e1SJnNWRja9iKAs9anh0CrtiwxHiSRBqjiOC2vXT4in0CIp8014c2WXdSyutUAkUfhPnf)Pqe3EabnC8alg1KRM9oO8al2MI)uiIBpGG724U)jws9JMC1C)Vn(lMgAoXhE6ACbBam0RHOjd0eowHLjlNfESR44bwmY2j2vFl1pSR9(uKt21is2GYqQFyxzAFkYPMlk5utMu8NcrC7beOjhAYKxZo2CcFhQjt1nVcPd1SRlRM(e1KPXjII4AsBWUUbLGGYzxf3IJ0MI)uiIBpGGgoEGfJAYvtiOP4wCKgAoXhE6ACbB44bwmQjxn7Dq5bwSnf)Pqe3Eab3TXD)tSK6hn5QzedOPOA94err8gTbRWYeoXcp2vC8algz7e7QVL6h2vJ)TxasEAWgzxrZfGF9WNEe2voTe2vQhCh0CHLjWXkSmzjSWJDfhpWIr2oXUUbLGGYzxf3IJ0i0bccOO5XgoEGfJAYvZ9)24VyA8oa8c2On0KRMrmGMIQ1JtefXB0gAYvtO0m(sJ3bGxWgaPai50dSOMMmPz8LgVdaVGnJqARug2cbAYayAcNMqRjxn3FyWFn(AeslIu1UenndMMqPjXaT2R4aEuinkFUp19Wu9irtZ6IvtoPj0AYvtGxXl2JJ08yK0QrtZ0eoMzx9Tu)WU27trozfwM0byHh7koEGfJSDID13s9d7AVpf5KDnIKnOmK6h2vM2NICQ5Iso1KP6ebbA2LeItQPd1SJOneAaYbeZbGxqnNx0SgnbifajNAc8HhzuZinOgEnzACIOiohRNvFtZviNTMlk5uZv0GuenPQXTAEwIMfLMgpHubwSXUUbLGGYzxHstXT4iTqNii46eIti10WXdSyuttM0eqpi1d4XwOdoCFQRCI3qNii46eIti10WXdSyutO1KRMqqZ4lnaTHqdWgaPai50dSOMC1m(sJ3bGxWgad9AiAAMMlxtUAgXaAkQwporueVrBOjxnHsZigqtr1iNvFJ2qttM0mIb0uuTECIOiEdGHEnenzGMCsttM0m(sJGgKI0KAFOgEnHwtUAgFPrqdsrAam0RHOjd0C5ScRWUgrkN2kSWJLjWXcp2vFl1pSRhQ9b2vC8algz7eRWYeMzHh7koEGfJSDIDnIKnOmK6h21ocjc6w5uZIstJNqQalQjuZRzpTDqGhyrnXbdlKOznAU)WaxGMD13s9d7krq3kNScltwol8yxXXdSyKTtSRVb7kbf2vFl1pSR9oO8alYU27wAKDLyGw7vCapkKgLp3N6EyQEKOjd0Kz21EhChpezxj1WBXR4aEuyfwMWjw4XUIJhyXiBNyxFd2vckSR(wQFyx7Dq5bwKDT3T0i7koiGhYga5X5U)WGAWOMMP5Yxc7AVdUJhISRaKhNlXfAGlyKDnIKnOmK6h21U(Hb1Grn74bb8qQzhH84O5GyeJAkVMexObUGScltwcl8yxXXdSyKTtSRBqjiOC2vIGUvoXyd880i7kra1wyzcCSR(wQFyx3U1E9Tu)CTfryxTfrUJhISRebDRCIrwHLjDaw4XUIJhyXiBNyx9Tu)WUUDR96BP(5AlIWUAlIChpezx3rcRWYKUiw4XUIJhyXiBNyx9Tu)WUsS1gV(eVXAJSRrKSbLHu)WUUS0IMRdertAdnRPKYTwi1K6bA2vArt51uorn76Ptqg1eGuaKCQ5Iso1SJNEC(qnlknDrt7VqZinWL6h21nOeeuo7ke0mGMIQrS1gV(eVXAJnAdn5Q5(dd(RXxJq00myAchRWYKoil8yxXXdSyKTtSRBqjiOC21aAkQgXwB86t8gRn2On0KRMb0uunIT241N4nwBSbWqVgIMmqZLOjxn3FyWFn(AeIMMbttoXU6BP(HDfNEC(qwHLjq0SWJDfhpWIr2oXU6BP(HDD7w713s9Z1weHD1we5oEiYUgFHvyzcCWNfESR44bwmY2j2vFl1pSRB3AV(wQFU2IiSR2Ii3Xdr21ybWTWkSmbo4yHh7koEGfJSDIDDdkbbLZUIdc4HSfrQAxIMMbtt4wIMCOjoiGhYga5X5U)WGAWi7QVL6h2vhS9bVYda4iScltGJzw4XU6BP(HD1bBFWRbTLGSR44bwmY2jwHLjWTCw4XU6BP(HD1w8Nc5YWbDKpehHDfhpWIr2oXkSmbooXcp2vFl1pSRbo)9PUcO2hiSR44bwmY2jwHvyxna4(ddCHfESmbow4XU6BP(HD1nmSqEn(I8d7koEGfJSDIvyzcZSWJD13s9d7AWlIfJxkRdjgxud)vEZRHDfhpWIr2oXkSmz5SWJDfhpWIr2oXUUbLGGYzxHGM7VhhFKwpoYjKan5QjWR4f7XrAEmsA1OPzAc3syx9Tu)WUg6Gdy8s9GBeD5KD1aG7pmWLlb3)ejSRWbFwHLjCIfESR44bwmY2j21nOeeuo7k5PTb1eBg0eH2IxeqBi1pnC8alg10KjnjpTnOMyR)TUuw8sEBposdhpWIr2vFl1pSRuwKCUboLWkSmzjSWJDfhpWIr2oXU(gSReuyx9Tu)WU27GYdSi7AVBPr2v40SZAcLMa6bPEap2I0KdlC7beqUgUSpB44bwmQ5s1eknHFJtlrto0eknjOCd(HM0Kcbm3bVCYyR5s1e(n40eAnHwtOzx7DWD8qKDThNikIF3raRWYKoal8yxXXdSyKTtSRVb7kbf2vFl1pSR9oO8alYU27wAKDfon7SMqPjGEqQhWJTpaJfoBSHJhyXOMlvt434eN0eA21EhChpezxPSopATUu)C3ra7AejBqzi1pSRW7e107rGZJA2vishPzr0e(nMzwZaArZinQP8AkNOMDetGyAoUqdqnFkn76YQjpomQjZMRPCwen7DlnQzr08nKk0TAs9anjqo7A410(81Mvyzsxel8yxXXdSyKTtSRVb7kbf2vFl1pSR9oO8alYU27G74Hi7QaQ5akxcKZ(sSVWU27wAKDfo21is2GYqQFyxHiOGGWAqnxCw7tnHQO00hiHwtI4IMb0uuAkGAoGIMlqnx4JOP8A6IGHgIMYRjbYzR5Iso1KPXjII4n21nOeeuo7QaQ5aknbU2PtUeXLMpqEJgen5QjuAcbnfqnhqPjm3oDYLiU08bYB0GOPjtAkGAoGstGRT)3g)ftlsdCP(rtZGPPaQ5aknH52(FB8xmTinWL6hnHwttM0ua1CaLMaxRiTAiBaT4bw8crH2hHo8gX(AJAAYKMqPPaQ5aknbUwrAKtp(l4boX4kVGHAYvZ93JJpsRhh5esGMqZkSmPdYcp2vC8algz7e76BWUsqHD13s9d7AVdkpWISR9ULgzxzMDT3b3Xdr2vbuZbuUeiN9LyFHDDdkbbLZUkGAoGstyUD6KlrCP5dK3ObrtUAcLMqqtbuZbuAcCTtNCjIlnFG8gniAAYKMcOMdO0eMB7)TXFX0I0axQF00mnfqnhqPjW12)BJ)IPfPbUu)Oj0AAYKMcOMdO0eMBfPvdzdOfpWIxik0(i0H3i2xButtM0eknfqnhqPjm3ksJC6XFbpWjgx5fmutUAU)EC8rA94iNqc0eAwHLjq0SWJD13s9d7krq3kNSR44bwmY2jwHLjWbFw4XUIJhyXiBNyx3Gsqq5SRqqtXT4iTP4pfI42diOHJhyXi7QVL6h2vIT241N4nwBKD1aG7pmWLlb3)ejSRWXkSc7ASa4wyHhltGJfESR44bwmY2j2vFl1pSR40JZhYUgrYgugs9d7Ahp948HA6IMCIdnHAjCO5Iso1eIScTMDDzBAYWhgIXYf0cPM)OjZCOP4aEuimQ5Iso1KPXjII4mQ5d0CrjNAcVoXOMVCIGffb1CHxIMupqtYhIAIdc4HSPzxAjVMl8s0SO0SJnNWR5(ddEnlIM7pSgEnPnASRBqjiOC2vKIc3s1J39hg8xJVgHOPzW0KtAYHMIBXrArenqWLiaxCEmSHJhyXOMC1eknJyanfvRhNikI3On00KjnJyanfvJCw9nAdnnzsZigqtr1OSopATUu)0On00KjnXbb8q2IivTlrtgattMxIMCOjoiGhYga5X5U)WGAWOMMmPje0S3bLhyXgPgElEfhWJIMMmPjsrHBP6X7(dd(RXxJq00mn3g3q38lXaNOMqRjxnHstiOP4wCKgAoXhE6ACbB44bwmQPjtAU)3g)ftdnN4dpDnUGnag61q00mnzwtOzfwMWml8yxXXdSyKTtSRVb7kbf2vFl1pSR9oO8alYU27wAKDD)Hb)14RriTisv7s00mnHtttM0eheWdzlIu1UenzamnzEjAYHM4GaEiBaKhN7(ddQbJAAYKMqqZEhuEGfBKA4T4vCapkSR9o4oEiYUstWlvzTiGvyzYYzHh7koEGfJSDID13s9d7kbbaxW4n4h8smQdi7AejBqzi1pSRDPHHfsnx70QMYRPBTAkoGhfIMlk58PfnDnJyanfLMortdq9GsGKrnnaifca1WRP4aEuiAgHSgEnj)piqtNsqGMYjQPbOcDaKAkoGhf21nOeeuo7AVdkpWInAcEPkRfbAYvtiOz8LgbbaxW4n4h8smQd4n(stQ9HA4zfwMWjw4XUIJhyXiBNyx3Gsqq5SR9oO8al2Oj4LQSweOjxnHGMXxAeeaCbJ3GFWlXOoG34lnP2hQHND13s9d7kbbaxW4n4h8smQdi76gYTfVId4rHWYe4yfwMSew4XUIJhyXiBNyx9Tu)WUsqaWfmEd(bVeJ6aYUgrYgugs9d7ktbIgAsb(qn3UHrn8AUpDaps08bAgqdgnDrt5e1eNOMpLMuf)Pqyx3Gsqq5SR9oO8al2Oj4LQSweOjxndDIGGRtioHuZfGHEnenzGMWV1b1KRMqPzWtiAYvtQI)uUam0RHOjdGP5s00Kjn3)BJ)IPrqaWfmEd(bVeJ6a2cDZV7thWJen7SM7thWJKlfW3s9JB1KbW0e(nMxIMqZkSmPdWcp2vC8algz7e7QVL6h2vccaUGXBWp4Lyuhq21is2GYqQFyxzkpXrtMAxQzr0CErtx08S4p1msdCP(HrnjqoBnxuYPMrp05rndOPOiAUOKZNw087rWcqj1WR5YGEuZai1SJn3dnSi76gucckNDfcAsq5g8dnPjfcyUdEz2yRjxn7Dq5bwSrtWlvzTiqtUAg6ebbxNqCcPMlad9AiAYanHFRdQjxnHstYtBdQj2SOhVbqErZ9qdl2WXdSyutUAcbndOPOAw0J3aiVO5EOHfB0gAYvZigqtr16XjII4nAdnnzsZaAkQwOda)cmE5XqI8dEX50NngIJ0On00KjnHGM9oO8al2i1WBXR4aEu0KRMrmGMIQroR(gTHMqZkSmPlIfESR44bwmY2j21nOeeuo7kbLBWp0KMuiG5o4LzJTMC1S3bLhyXgnbVuL1Ian5QzOteeCDcXjKAUam0RHOjd0e(ToOMC1mIb0uunEaDKhVHUSpB0gAYvtiOzanfvZIE8ga5fn3dnSyJ2qtUAc8kEXECKMhJKwnAAMMlHD13s9d7kbbaxW4n4h8smQdiRWYKoil8yxXXdSyKTtSR(wQFyxjia4cgVb)GxIrDazxT1G3DKDfULWUgrYgugs9d7kdxcQ5ANw1uEnj0HH)Ojtb2xdNjA2f)HOI2A41SO0eYNwZtVh1uornjpTnOMyJDDdkbbLZUsEABqnX2bSVgY9FiQOTg(goEGfJAYvZaAkQ2bSVgY9FiQOTg(w8xmScltGOzHh7koEGfJSDID13s9d7kLp3N6EyQEKWUgrYgugs9d7kdZhnFknzkMQhjA6IMWbrZHMeX3hiA(uA2ftfJ4OzNSEejA(anDEVgIOjN4qtXb8OqASRBqjiOC21EhuEGfB0e8svwlc0KRMqPzanfv7SIrCUbwpIKgr89bnndMMWbrRPjtAcLMqqtdq9GsG8cEXL6hn5QjXaT2R4aEuinkFUp19Wu9irtZGPjN0Kdnjc6w5eJnWZtJAcTMqZkSmbo4Zcp2vC8algz7e7QVL6h2vkFUp19Wu9iHDDd52IxXb8OqyzcCSRrKSbLHu)WUYW8rZNstMIP6rIMYRPByyHutJVi)q0SO0SgFlvpQ5pA6dKAkoGhfnH6bA6dKAgyrmwdVMId4rHO5Iso10aupOei1e8Il1pqRPlAUC4XUUbLGGYzxHstiOPbOEqjqEbV4s9JMMmPz8LgVdaVGnP2hQHxttM0m(sdqBi0aSj1(qn8AcTMC1S3bLhyXgnbVuL1Ian5QjXaT2R4aEuinkFUp19Wu9irtZGP5YzfwMahCSWJDfhpWIr2oXUUbLGGYzx7Dq5bwSrtWlvzTiqtUAU)3g)ftRhNikI3ayOxdrtZ0eo4ZU6BP(HDf3NFn8xaAaQqFIScltGJzw4XUIJhyXiBNyx3Gsqq5SR9oO8al2Oj4LQSweOjxnHsZqNii46eIti1CbyOxdrtyAcFn5Qje0eqpi1d4Xw8)WaRhXgoEGfJAAYKMb0uuTaBnrsfXgTHMqZU6BP(HD1ddOjNScltGB5SWJDfhpWIr2oXU6BP(HDnKwkRli76gYTfVId4rHWYe4yxJizdkdP(HDfEEqNzQ0szDb1uEnDddlKAcrqpAHuZL9lYpA6IMmRP4aEuiSRBqjiOC21EhuEGfB0e8svwlc0KRMed0AVId4rH0O85(u3dt1JenHPjZScltGJtSWJDfhpWIr2oXUUbLGGYzx7Dq5bwSrtWlvzTiGD13s9d7AiTuwxqwHvyx3rcl8yzcCSWJDfhpWIr2oXU6BP(HDn0bhW4L6b3i6Yj7QTg8UJSRW1wc7AejBqzi1pSRm8uA6XirthGAsBWOMKPmqnLtuZFqnxuYPM2FbsenHh8Ginnz4sqnxCIJMriRHxtkNiiqt50hn76YQzePQDjA(anxuY5tlA6dKA21LTXUUbLGGYzxbEfVyposZJrsJ2qtUAcLMqqZEhuEGfBKA4T4vCapkAAYKMId4rPjviEL)glutgO5YHVMqRjxnHstXb8O0KkeVYFJfQjd0C)Hb)14RriTisv7s0CPAcxBjAAYKM7pm4VgFncPfrQAxIMMbtZTXn0n)smWjQj0SRBi3w8koGhfcltGJvyzcZSWJDfhpWIr2oXU6BP(HDn0bhW4L6b3i6Yj7AejBqzi1pSRm8uAoVMEms0CrzTAgluZfLCwJMYjQ5GMlAUC4tyutAcQjtLcIOj1d0m0nxZUUSnn7srWqdrt51Ka5S1CrjNAYWSopATUu)OzrPPXtivGfBSRBqjiOC2vGxXl2JJ08yK0QrtZ0C5WxZoRjWR4f7XrAEmsArAGl1pAYvZ9hg8xJVgH0IivTlrtZGP524g6MFjg4e1KRMqqZ9)24VyAKZQVbqpcPMC1eknHGM7VhhFKwpoYjKannzsZigqtr1OSopATUu)0On00Kjn3)BJ)IPrzDE0ADP(PbWqVgIMMPjClrtOzfwMSCw4XUIJhyXiBNyxFd2vckSR(wQFyx7Dq5bwKDT3T0i7ke0uClosBk(tHiU9acA44bwmQPjtAcbnf3IJ0qZj(WtxJlydhpWIrnnzsZ9)24VyAO5eF4PRXfSbWqVgIMmqZLOzN1KznxQMIBXrArenqWLiaxCEmSHJhyXi7AVdUJhISR94err87u8NcrC7beC3)elP(HDnIKnOmK6h21viNTMmnoruexZf1e)fAUOKtnzsXFkeXThqahDS5eF4PRXfuZIst3WWwBpWISclt4el8yxXXdSyKTtSRVb7kbf2vFl1pSR9oO8alYU27wAKDfcAkUfhPf6ebbxNqCcPMgoEGfJAAYKMXxA8oa8c2KAFOgEnnzsZ93JJpsRhh5esGMC1C)Hb)14RriTisv7s0eMMWNDT3b3Xdr21ECIOi(n0V7FILu)WUgrYgugs9d7ktPxIM)OjtJtefX1K6bAcXCa4fuZfLCQjtTlzut6XIeIMlqnDaQPlAg6MRzxxwnPEGMmmRZJwRl1pScltwcl8yxXXdSyKTtSRVb7kbf2vFl1pSR9oO8alYU27G74Hi7Aporue)U)EC8rU7FILu)WU27wAKDfo21is2GYqQFyxxHC2AY04errCnxuYPMmmRZJwRl1pA6tuZv0GuenDIM2F410jAUa1CXpCw00(eutxZTten)EeOPCIAsv8NIMrAGl1pSRBqjiOC2193JJps7aKGYhnnzsZ93JJpsBWn4TpiQPjtAU)EC8rAZpiRWYKoal8yxXXdSyKTtSRVb7kbf2vFl1pSR9oO8alYU27wAKDLY(pqtO0eknPk(t5cWqVgIMDwtMHVMqRz3AcLMWXm81CPA27GYdSyRhNikIF3rGMqRj0AAMMu2)bAcLMqPjvXFkxag61q0SZAYm81SZAU)3g)ftJY68O16s9tdGHEnenHwZU1eknHJz4R5s1S3bLhyXwporue)UJanHwtO10KjndOPOAuwNhTwxQFUb0uunAdnnzsZigqtr1OSopATUu)0On00KjndEcrtUAsv8NYfGHEnenzGMmdF21EhChpezx7XjII4393JJpYD)tSK6h21nOeeuo76(7XXhP1JJCcjGvyzsxel8yxXXdSyKTtSRVb7kbf2vFl1pSR9oO8alYU27wAKDLY(pqtO0eknPk(t5cWqVgIMDwtMHVMqRz3AcLMWXm81CPA27GYdSyRhNikIF3rGMqRj0AAMMu2)bAcLMqPjvXFkxag61q0SZAYm81SZAU)3g)ftJGgKI0ayOxdrtO1SBnHst4yg(AUun7Dq5bwS1JtefXV7iqtO1eAnnzsZ4lncAqkstQ9HA410KjndEcrtUAsv8NYfGHEnenzGMmdF21EhChpezx7XjII4393JJpYD)tSK6h21nOeeuo76(7XXhPnf)PCPCKvyzshKfESR44bwmY2j21is2GYqQFyxzywKCUboLOj1d0CzPjcTf1SJb0gs9JMfLMZlAse0TYjg18bAwJMUM7)TXFXO5gYTfzx3Gsqq5SRqPj5PTb1eBg0eH2IxeqBi1pnC8alg10KjnjpTnOMyR)TUuw8sEBposdhpWIrnHwtUAcbnjc6w5eJn3A1KRMqqZigqtr16XjII4nAdn5QzOteeCDcXjKAUam0RHOjmnHVMC1eknXbb8q2KkeVYFdDZV7pmOgmQPzAYSMMmPje0mIb0uunYz13On0eA21AeeaOnKBrXUsEABqnXw)BDPS4L82ECe21AeeaOnKBfgIXYfKDfo2vFl1pSRuwKCUboLWUwJGaaTHC5TFGBzxHJvyzcenl8yxXXdSyKTtSR(wQFyxPSopATUu)WUgrYgugs9d76kKZwtgM15rR1L6hnxuYPMmnoruextNOP9hEnDIMlqnx8dNfnTpb101C7erZVhbAkNOMuf)POzKg4s9JMq9anlknzACIOiUMlkRvZ9hIAg47dA68EnDxenLNN3IrnFkkOBSRBqjiOC2viOjrq3kNySbEEAutUAcLM7)TXFX06XjII4nag61q0KbAUCn5QzVdkpWITECIOi(n0V7FILu)OjxnrkkClvpE3FyWFn(AeIMMbttoPjxnfhWJstQq8k)nwOMMPjCWxttM0mIb0uuTECIOiEJ2qttM0m4jen5QjvXFkxag61q0KbAYmN0eAwHLjWbFw4XUIJhyXiBNyx3Gsqq5SRqqtIGUvoXyd880OMC1ePOWTu94D)Hb)14RriAAgmn5KMC1eknPS)d0eknHstQI)uUam0RHOzN1KzoPj0A2TMqPPVL6N7(FB8xmAUun7Dq5bwSrzDE0ADP(5UJanHwtO10mnPS)d0eknHstQI)uUam0RHOzN1KzoPzN1C)Vn(lMwporueVbWqVgIMlvZEhuEGfB94err87oc0eAn7wtO003s9ZD)Vn(lgnxQM9oO8al2OSopATUu)C3rGMqRj0Acn7QVL6h2vkRZJwRl1pScltGdow4XUIJhyXiBNyx9Tu)WUsqdsryxJizdkdP(HDDfYzR5kAqkIMlk5utMgNikIRPt00(dVMorZfOMl(HZIM2NGA6AUDIO53JanLtutQI)u0msdCP(HrndOfnnaifc0uCapkenLtx0CrzTAAREutx00Ior0eo4tyx3Gsqq5SRqqtIGUvoXyd880OMC1m(sJ3bGxWMu7d1WRjxnHsZ9)24VyA94err8gad9AiAYanHttUAkoGhLMuH4v(BSqnntt4GVMMmPzedOPOA94err8gTHMMmPzWtiAYvtQI)uUam0RHOjd0eo4Rj0ScltGJzw4XUIJhyXiBNyx3Gsqq5SRqqtIGUvoXyd880OMC1eknPS)d0eknHstQI)uUam0RHOzN1eo4Rj0A2TM(wQFU7)TXFXOj0AAMMu2)bAcLMqPjvXFkxag61q0SZAch81SZAU)3g)ftRhNikI3ayOxdrZLQzVdkpWITECIOi(DhbAcTMDRPVL6N7(FB8xmAcTMqZU6BP(HDLGgKIWkSmbULZcp2vC8algz7e76gucckNDfcAse0TYjgBGNNg1KRMXxAaAdHgGnP2hQHxtUAcbnJyanfvRhNikI3On0KRM9oO8al26XjII43P4pfI42di4U)jws9JMC1S3bLhyXwporue)g639pXsQF0KRM9oO8al26XjII4393JJpYD)tSK6h2vFl1pSR94errCwHLjWXjw4XUIJhyXiBNyx9Tu)WUIMt8HNUgxq21is2GYqQFyx7yZj(WtxJlOMloXrZ5fnjc6w5eJA6tuZGxo1SJOneAaQPprnHyoa8cQPdqnPn0K6bAA)HxtCEA(Zg76gucckNDfcAse0TYjgBGNNg1KRMqPje0m(sJ3bGxWgaPai50dSOMC1m(sdqBi0aSbWqVgIMMPjN0Kdn5KMlvZTXn0n)smWjQ5s1eknHtZU1m(sdqBi0aSHMt8HNUgxW4f4cQj0AAYKMXxAaAdHgGnag61q0CPAc)2s00mnfhWJstQq8k)nwOMqRjxnfhWJstQq8k)nwOMMPjNyfwMa3syHh7koEGfJSDID13s9d7k5S6zxJizdkdP(HDD9S61SO0eI8WJOPdqnPnyuZIstMu8NIMmmh10fbdnenLxtcKZwZfLCQ5kAqkIMpqtMgNikIRzrP5cuZf)WzrZforqndFaQPC6JMNULsZ1ZQNZen3)BJ)IHDDdkbbLZUcbnJyanfvJCw9nAdn5QjuAgFPX7aWlytQ9HA41KRMXxAaAdHgGnP2hQHxtO1KRMqPje0C)944J0MI)uUuoQPjtAcLMqP5(FB8xmncAqksdGEesnnzsZ9)24VyAe0GuKgad9AiAAMMWXSMqRjhAcLM7)TXFX06XjII4na6ri10Kjn3)BJ)IP1JtefXBam0RHO5s1S3bLhyXwporue)UJanntt4ywtO1eMMmRj0AcnRWYe46aSWJDfhpWIr2oXUUbLGGYzxdOPOAb2)JwAI0aOVfnnzsZGNq0KRMuf)PCbyOxdrtgO5YHVMMmPzedOPOA94err8gTb7QVL6h2vJxQFyfwMaxxel8yxXXdSyKTtSRBqjiOC21igqtr16XjII4nAd2vFl1pSRb2)JxkAaKScltGRdYcp2vC8algz7e76gucckNDnIb0uuTECIOiEJ2GD13s9d7Aacii4qn8ScltGdIMfESR44bwmY2j21nOeeuo7AedOPOA94err8gTb7QVL6h2vQcGb2)JScltyg(SWJDfhpWIr2oXUUbLGGYzxJyanfvRhNikI3Onyx9Tu)WU6ZgjcWT3TBTScltygow4XUIJhyXiBNyx9Tu)WUUDR96BP(5AlIWUUbLGGYzxHGMebDRCIXMBTAYvZqNii46eIti1CbyOxdrtyAcF2vBrK74Hi7AVpf5KvyzcZmZcp2vC8algz7e7QVL6h21f1ejBhCxCIcr(bzx3Gsqq5SRed0AVId4rH0O85(u3dt1JenntZiskagVId4rHOPjtAc8kEXECKMhJKwnAAMMDa4RPjtAg8eIMC1KQ4pLlad9AiAYan7IyxhpezxxutKSDWDXjke5hKvyzcZlNfESR44bwmY2j2vFl1pSRcOMdOah7AejBqzi1pSRRqoBnLtutdq9GsGutI4IMb0uuAkGAoGIMlk5utMgNikIZOMVCIGffb1KMGA(JM7)TXFXWUUbLGGYzx7Dq5bwSjGAoGYLa5SVe7lActt40KRMqPzedOPOA94err8gTHMMmPzWtiAYvtQI)uUam0RHOjdGPjZWxtO10KjnHsZEhuEGfBcOMdOCjqo7lX(IMW0Kzn5Qje0ua1CaLMWCB)Vn(lMga9iKAcTMMmPje0S3bLhyXMaQ5akxcKZ(sSVWkSmHzoXcp2vC8algz7e76gucckNDT3bLhyXMaQ5akxcKZ(sSVOjmnzwtUAcLMrmGMIQ1JtefXB0gAAYKMbpHOjxnPk(t5cWqVgIMmaMMmdFnHwttM0ekn7Dq5bwSjGAoGYLa5SVe7lActt40KRMqqtbuZbuAcCT9)24VyAa0JqQj0AAYKMqqZEhuEGfBcOMdOCjqo7lX(c7QVL6h2vbuZbuyMvyf214lSWJLjWXcp2vC8algz7e76BWUsqHD13s9d7AVdkpWISR9ULgzxna1dkbYl4fxQF0KRMqPz8LgVdaVGnag61q0KbAU)3g)ftJ3bGxWwKg4s9JMMmPzVdkpWInaYJZL4cnWfmQj0SR9o4oEiYUsoug3nKBlE5Da4fKDnIKnOmK6h21LPclrtcU)j6ai1eI5aWlirtQhOPbOEqjqQj4fxQF0SO0CbQ5P3JAU8LOjoiGhsnbipoA(anHyoa8cQ5IYA1en3OaOM)OPCIAAaQqhaPMId4rHvyzcZSWJDfhpWIr2oXU(gSReuyx9Tu)WU27GYdSi7AVBPr2vdq9GsG8cEXL6hn5QjuAgXaAkQg5S6B0gAYvtIbATxXb8OqAu(CFQ7HP6rIMMPjZAAYKM9oO8al2aipoxIl0axWOMqZU27G74Hi7k5qzC3qUT4fqBi0aKDnIKnOmK6h21LPclrtcU)j6ai1SJOneAas0K6bAAaQhucKAcEXL6hnlknxGAE69OMlFjAIdc4HutaYJJMpqZ1ZQxZIOjTHM)OjZWJdwHLjlNfESR44bwmY2j213GDLGc7QVL6h21EhuEGfzx7DlnYUgXaAkQwporueVrBOjxnHsZigqtr1iNvFJ2qttM0m0jccUoH4esnxag61q00mnHVMqRjxnJV0a0gcnaBam0RHOPzAYm7AVdUJhISRKdLXfqBi0aKDnIKnOmK6h21LPclrZoI2qObirZIstMgNikIZX6z13nt1jcc0SljeNqQrZIOjTHM(e1CbQ5P3JAYmhAsW9prIMwKs08hnLtuZoI2qObOMqKhESclt4el8yxXXdSyKTtSR(wQFyx5Da4fKDnIKnOmK6h21vdCxUvtiMdaVGA6tuZoI2qObOMeuOn00aupqt51SJnN4dpDnUGAUDIWUUbLGGYzxf3IJ0qZj(WtxJlydhpWIrn5Qje0CrzTx7tWlAoXhE6ACb1KRMXxA8oa8c2mcPTszyleOjdGPjCAYvZ9)24VyAO5eF4PRXfSbWqVgIMmqtM1KRMed0AVId4rH0O85(u3dt1JenHPjCAYvtGxXl2JJ08yK0QrtZ0SdOjxnJV04Da4fSbWqVgIMlvt43wIMmqtXb8O0KkeVYFJfYkSmzjSWJDfhpWIr2oXUUbLGGYzxf3IJ0qZj(WtxJlydhpWIrn5QjuAIuu4wQE8U)WG)A81ienndMMBJBOB(LyGtutUAU)3g)ftdnN4dpDnUGnag61q0KbAcNMC1m(sdqBi0aSbWqVgIMlvt43wIMmqtXb8O0KkeVYFJfQj0SR(wQFyxb0gcnazfwM0byHh7koEGfJSDID13s9d7QX)2lajpnyJSRrKSbLHu)WUcXCa4futAJdiAWOMUL8AkGcjAkVM0euZs00jA6AsmWD5wn5XbbU8anPEGMYjQP1jIMDDz1maPEaQPRjvnf5ebSRup4oO5cltGJvyzsxel8yxXXdSyKTtSRBqjiOC2vasbqYPhyrn5Q5(dd(RXxJqArKQ2LOPzW0eon5QjuAAesBLYWwiqtgatt400KjnbyOxdrtgattP2hUsfIAYvtIbATxXb8OqAu(CFQ7HP6rIMMbtZLRj0AYvtO0ecAUOS2R9j4fnN4dpDnUGAAYKMam0RHOjdGPPu7dxPcrnxQMmRjxnjgO1EfhWJcPr5Z9PUhMQhjAAgmnxUMqRjxnHstXb8O0KkeVYFJfQzN1eGHEnenHwtZ0KtAYvZqNii46eIti1CbyOxdrtyAcF2vFl1pSR8oa8cYkSmPdYcp2vC8algz7e7k1dUdAUWYe4yx9Tu)WUA8V9cqYtd2iRWYeiAw4XUIJhyXiBNyx3Gsqq5SRqqZEhuEGfBKdLXDd52IxEhaEb1KRMaKcGKtpWIAYvZ9hg8xJVgH0IivTlrtZGPjCAYvtO00iK2kLHTqGMmaMMWPPjtAcWqVgIMmaMMsTpCLke1KRMed0AVId4rH0O85(u3dt1JenndMMlxtO1KRMqPje0CrzTx7tWlAoXhE6ACb10KjnbyOxdrtgattP2hUsfIAUunzwtUAsmqR9koGhfsJYN7tDpmvps00myAUCnHwtUAcLMId4rPjviEL)gluZoRjad9AiAcTMMPjCmRjxndDIGGRtioHuZfGHEnenHPj8zx9Tu)WUY7aWli76gYTfVId4rHWYe4yfwMah8zHh7koEGfJSDID13s9d76guHKFUcgAGeHDDd52IxXb8OqyzcCSRrKSbLHu)WU2vqfs(rt4HHgir08hndPTszyrnfhWJcrtx0KtCOzxxwnxCIJMa6zQHxZNw0SgnzUZlHOPt00(dVMorZfOMNEpQjopn)PMaKhhn9jQPdWHZIMeuKA41K2qtQhOjtJtefXzx3Gsqq5SRed0AVId4rHOPzW0Kzn5QjsrHBP6X7(dd(RXxJq00myAYjn5QjoiGhYga5X5U)WGAWOMMPjZWxtUAcLMqqZ9)24VyA94err8ga9iKAAYKMXxAaAdHgGnP2hQHxtO1KRMam0RHOjd0Kzn5qZLR5s1eknjgO1EfhWJcrtZGPjN0eAwHLjWbhl8yxXXdSyKTtSR(wQFyxb0gcnazxJizdkdP(HDLPardnPn0SJOneAaQPlAYjo08hnDRvtXb8Oq0eQfN4OPT6RHxt7p8AIZtZFQPprnNx0KmUb58fOzx3Gsqq5SRqqZEhuEGfBKdLXfqBi0autUAIuu4wQE8U)WG)A81ienndMMCstUAcqkaso9alQjxnHstJqARug2cbAYayAcNMMmPjad9AiAYayAk1(WvQqutUAsmqR9koGhfsJYN7tDpmvps00myAUCnHwtUAcLMqqZfL1ETpbVO5eF4PRXfuttM0eGHEnenzamnLAF4kviQ5s1Kzn5QjXaT2R4aEuinkFUp19Wu9irtZGP5Y1eAn5QP4aEuAsfIx5VXc1SZAcWqVgIMMPjuAYjn5qtO0eqpi1d4Xw0jN1WFj7NEIa02WXdSyuZLQ5s0eAn5qtO0eqpi1d4Xw8)WaRhXgoEGfJAUunxIMqRjhAcLM9oO8al2aipoxIl0axWOMlvZoGMqRj0ScltGJzw4XUIJhyXiBNyx3Gsqq5SRqqZEhuEGfBKdLXDd52IxaTHqdqn5Qje0S3bLhyXg5qzCb0gcna1KRMiffULQhV7pm4VgFncrtZGPjN0KRMaKcGKtpWIAYvtO00iK2kLHTqGMmaMMWPPjtAcWqVgIMmaMMsTpCLke1KRMed0AVId4rH0O85(u3dt1JenndMMlxtO1KRMqPje0CrzTx7tWlAoXhE6ACb10KjnbyOxdrtgattP2hUsfIAUunzwtUAsmqR9koGhfsJYN7tDpmvps00myAUCnHwtUAkoGhLMuH4v(BSqn7SMam0RHOPzAcLMCsto0eknb0ds9aESfDYzn8xY(PNiaTnC8alg1CPAUenHwto0eknb0ds9aESf)pmW6rSHJhyXOMlvZLOj0AYHMqPzVdkpWInaYJZL4cnWfmQ5s1SdOj0Acn7QVL6h2vaTHqdq21nKBlEfhWJcHLjWXkSmbULZcp2vC8algz7e7QVL6h21nOcj)Cfm0ajc7AejBqzi1pSRmm3Ad89bn7YVJ1SRGkK8JMWddnqIO5Iso1uornjEiQP95RTMortp47rg1mGw0S4NhudVMYjQjoiGhsn3)elP(HOzrP5cuthGdNfnPj1WRzhrBi0aKDDdkbbLZUsmqR9koGhfIMMbttM1KRMiffULQhV7pm4VgFncrtZGPjN0KRMam0RHOjd0Kzn5qZLR5s1eknjgO1EfhWJcrtZGPjN0eAwHLjWXjw4XUIJhyXiBNyx9Tu)WUUbvi5NRGHgiryxJizdkdP(HDTRGkK8JMWddnqIO5pAUcpnlknRrtdFIyyT10NOMd6alKAg6MRjoiGhsn9jQzrPzhp948HAU4holAgFndFaQz0dDEuZinQP8AcVo1ntTlzx3Gsqq5SRed0AVId4rHOjmnHttUAcLMqqta9GupGhBrNCwd)LSF6jcqBdhpWIrnnzsZaAkQgGEW7IheVuGNinAdnHwtUAg6ebbxNqCcPMlad9AiActt4RjxnrkkClvpE3FyWFn(AeIMMbttO0CBCdDZVedCIA2znHttO1KRMaKcGKtpWIAYvtiO5IYAV2NGx0CIp8014cQjxnHstiOzedOPOAKZQVrBOPjtAgXaAkQgpGoYJ3qx2Nnag61q00mnzwtO1KRMId4rPjviEL)gluZoRjad9AiAAMMCIvyfwHDThbK6hwMWm8zgo4Gd(WXUUWbtn8e2vMYUSJycdptGyDOMAcVtuZk04bIMupqtote0TYjg5SMaeIcDbWOMKpe10PLp0fmQ5(0hEK00JltnOMCQd1SR)0JabJAUwHDvtcKJ4MRzxqt51CzODnJvFrQF08nqGlpqtO6gAnHcoZHUPh1JmLDzhXegEMaX6qn1eENOMvOXdenPEGMCU3NICYznbief6cGrnjFiQPtlFOlyuZ9Pp8iPPhxMAqnHRd1SR)0JabJAYza9GupGhBqCoRP8AYza9GupGhBq8goEGfJCwtOy2COB6XLPguZoqhQzx)Phbcg1KZa6bPEap2G4Cwt51KZa6bPEap2G4nC8alg5SMqbN5q30J6rMYUSJycdptGyDOMAcVtuZk04bIMupqtoBaW9hg4cN1eGquOlag1K8HOMoT8HUGrn3N(WJKMECzQb1KtDOMD9NEeiyutotEABqnXgeNZAkVMCM802GAIniEdhpWIroRjuWzo0n94YudQjN6qn76p9iqWOMCM802GAInioN1uEn5m5PTb1eBq8goEGfJCwtx0SJ7IVmAcfCMdDtpUm1GAUKouZU(tpcemQjNb0ds9aESbX5SMYRjNb0ds9aESbXB44bwmYznHcoZHUPhxMAqn7aDOMD9NEeiyutodOhK6b8ydIZznLxtodOhK6b8ydI3WXdSyKZAcfCMdDtpUm1GA2f1HA21F6rGGrn5SaQ5akn4AqCoRP8AYzbuZbuAcCnioN1ekozo0n94YudQzxuhQzx)Phbcg1KZcOMdO0yUbX5SMYRjNfqnhqPjm3G4CwtOy2COB6XLPguZoyhQzx)Phbcg1KZcOMdO0GRbX5SMYRjNfqnhqPjW1G4CwtOy2COB6XLPguZoyhQzx)Phbcg1KZcOMdO0yUbX5SMYRjNfqnhqPjm3G4CwtO4K5q30J6rMYUSJycdptGyDOMAcVtuZk04bIMupqtohlaUfoRjaHOqxamQj5drnDA5dDbJAUp9Hhjn94YudQzhSd1SR)0JabJAYzYtBdQj2G4Cwt51KZKN2gutSbXB44bwmYznHcoZHUPhxMAqnHJ5ouZU(tpcemQjNb0ds9aESbX5SMYRjNb0ds9aESbXB44bwmYznHcoZHUPh1JmLDzhXegEMaX6qn1eENOMvOXdenPEGMCEhjCwtacrHUayutYhIA60Yh6cg1CF6dpsA6XLPguZoqhQzx)Phbcg1CTc7QMeihXnxZUGMYR5Yq7AgR(Iu)O5BGaxEGMq1n0AcfZMdDtpUm1GA2f1HA21F6rGGrnxRWUQjbYrCZ1SlOP8AUm0UMXQVi1pA(giWLhOjuDdTMqXS5q30JltnOMDWouZU(tpcemQjNjpTnOMydIZznLxtotEABqnXgeVHJhyXiN1ekMnh6MECzQb1eo43HA21F6rGGrnxRWUQjbYrCZ1SlOP8AUm0UMXQVi1pA(giWLhOjuDdTMqXS5q30JltnOMWXChQzx)Phbcg1CTc7QMeihXnxZUGMYR5Yq7AgR(Iu)O5BGaxEGMq1n0AcfZMdDtpUm1GAchN6qn76p9iqWOMRvyx1Ka5iU5A2f0uEnxgAxZy1xK6hnFde4Yd0eQUHwtOGZCOB6XLPgutMxEhQzx)Phbcg1KZcOMdO0yUbX5SMYRjNfqnhqPjm3G4CwtOGZCOB6XLPgutM5uhQzx)Phbcg1KZcOMdO0GRbX5SMYRjNfqnhqPjW1G4CwtOGZCOB6r9itzx2rmHHNjqSoutnH3jQzfA8artQhOjNJVWznbief6cGrnjFiQPtlFOlyuZ9Pp8iPPhxMAqnHdUouZU(tpcemQjNb0ds9aESbX5SMYRjNb0ds9aESbXB44bwmYznHIzZHUPhxMAqnHJ5ouZU(tpcemQjNb0ds9aESbX5SMYRjNb0ds9aESbXB44bwmYznHIzZHUPhxMAqnHJtDOMD9NEeiyutodOhK6b8ydIZznLxtodOhK6b8ydI3WXdSyKZAcfCMdDtpUm1GAchN6qn76p9iqWOMCgqp4DXdIniEdhpWIroRP8AY5aAkQgGEW7IheVq8gTbN1ek4mh6MEupYWhA8abJA2fPPVL6hnTfrin9i7Qb4PklYUYqmKMDjH4esnUu)Ozh980OEKHyinzyyaG2bqQjCq0mQjZWNzM1J6rgIH0SRN(WJKoupYqmKMDwZU0WWcPMCMiGAlCwtkRZRP8As(quZUCzxgnPEWbIMYRjX7rnna)gjKA41uQqSPhzigsZoRje5holAY0(uKtnPhlsiAUARnQPprnHi1g1CrzTAADIOP9hEeOPC6JMmvNiiqZUKqCcPMMEKHyin7SMDeADZ1KHzDE0ADP(rZU1KPXjII4AsGC2AcvrPjtJtefX1SiAkppVfJA(uuA(an)rtxt7p8A2vic0n9idXqA2znzQ(butgMfjNBGtjAwJGaaTHOznAU)Wax0SO0CbQjdh0erZyf1SenPEGM9V1LYIxYB7XrA6rgIH0SZAYWLGAU2PvndFaQP8AsOdd)rtMcSVgot0Sl(drfT1WRzrPjKpTMNEpQPCIAsEABqnXMEKHyin7SMD9NEeiAcOh8U4bXgf4jIMYRzanfvdqp4DXdIxkWtKgTrtpYqmKMDwZUmgXOMmL1ejBhOjt5jke5hSPhzigsZoRj8wG(bmQzhBoXhE6ACb1uEn5rrtAcg1SO0eYNMZ9OMmnorueVZeF4PRXfm20J6rgIH0SJnh30cg1maPEaQ5(ddCrZaKVgstZUCVrdHO58tNpDqifTvtFl1pen)Xcztp6BP(H0ma4(ddCbMByyH8A8f5h9OVL6hsZaG7pmWfoG1DWlIfJxkRdjgxud)vEZRrp6BP(H0ma4(ddCHdyDh6Gdy8s9GBeD5KrdaU)WaxUeC)tKado4Zyrbdc7VhhFKwpoYjKaUaVIxShhP5XiPvJzWTe9OVL6hsZaG7pmWfoG1nLfjNBGtjmwuWipTnOMyZGMi0w8IaAdP(XKjYtBdQj26FRlLfVK32JJOh9Tu)qAgaC)HbUWbSU7Dq5bwKXXdry94err87ocyS3T0im46mua6bPEap2I0KdlC7beqUgUSpxkuWVXPLWbueuUb)qtAsHaM7GxozSxk8BWbn0qRhzinH3jQP3JaNh1SRqKosZIOj8BmZSMb0IMrAut51uorn7iMaX0CCHgGA(uA21LvtECyutMnxt5SiA27wAuZIO5BivOB1K6bAsGC21WRP95RTE03s9dPzaW9hg4chW6U3bLhyrghpeHrzDE0ADP(5UJag7DlncdUodfGEqQhWJTpaJfoBCPWVXjobTEKH0eIGcccRb1CXzTp1eQIstFGeAnjIlAgqtrPPaQ5akAUa1CHpIMYRPlcgAiAkVMeiNTMlk5utMgNikI30J(wQFindaU)Wax4aw39oO8alY44HimbuZbuUeiN9LyFHXE3sJWGJXIcMaQ5akn4ANo5sexA(a5nAq4cfeeqnhqPXC70jxI4sZhiVrdIjtcOMdO0GRT)3g)ftlsdCP(XmycOMdO0yUT)3g)ftlsdCP(bAtMeqnhqPbxRiTAiBaT4bw8crH2hHo8gX(AJMmbLaQ5akn4AfPro94VGh4eJR8cgYD)944J06XroHeaTE03s9dPzaW9hg4chW6U3bLhyrghpeHjGAoGYLa5SVe7lm27wAegZmwuWeqnhqPXC70jxI4sZhiVrdcxOGGaQ5akn4ANo5sexA(a5nAqmzsa1CaLgZT9)24VyArAGl1pMjGAoGsdU2(FB8xmTinWL6hOnzsa1CaLgZTI0QHSb0IhyXlefAFe6WBe7RnAYeucOMdO0yUvKg50J)cEGtmUYlyi393JJpsRhh5esa06rFl1pKMba3FyGlCaRBIGUvo1J(wQFindaU)Wax4aw3eBTXRpXBS2iJgaC)HbUCj4(NibgCmwuWGG4wCK2u8NcrC7be0WXdSyupQhzigsZo2CCtlyutShbqQPuHOMYjQPVLhOzr0079Y6bwSPh9Tu)qGDO2h0JmKMDese0TYPMfLMgpHubwutOMxZEA7GapWIAIdgwirZA0C)HbUaTE03s9dHdyDte0TYPE03s9dHdyD37GYdSiJJhIWi1WBXR4aEuyS3T0imIbATxXb8OqAu(CFQ7HP6rcdywpYqA21pmOgmQzhpiGhsn7iKhhnheJyut51K4cnWfup6BP(HWbSU7Dq5bwKXXdryaKhNlXfAGlyKXE3sJWWbb8q2aipo39hgudgnB5lrp6BP(HWbSU3U1E9Tu)CTfryC8qegrq3kNyKrIaQTadoglkyebDRCIXg45Pr9OVL6hchW6E7w713s9Z1weHXXdry7irpYqAUS0IMRdertAdnRPKYTwi1K6bA2vArt51uorn76Ptqg1eGuaKCQ5Iso1SJNEC(qnlknDrt7VqZinWL6h9OVL6hchW6MyRnE9jEJ1gzSOGbHaAkQgXwB86t8gRn2On4U)WG)A81ieZGbNE03s9dHdyDJtpoFiJffSaAkQgXwB86t8gRn2On4gqtr1i2AJxFI3yTXgad9AimyjC3FyWFn(AeIzW4KE03s9dHdyDVDR96BP(5AlIW44HiS4l6rFl1peoG192T2RVL6NRTicJJhIWIfa3IE03s9dHdyD7GTp4vEaahHXIcgoiGhYwePQDjMbdULWboiGhYga5X5U)WGAWOE03s9dHdyD7GTp41G2sq9OVL6hchW62w8Nc5YWbDKpehrp6BP(HWbSUdC(7tDfqTpq0J6rgIH0SR)BJ)IHOhzinz4P00JrIMoa1K2GrnjtzGAkNOM)GAUOKtnT)cKiAcp4brAAYWLGAU4ehnJqwdVMuorqGMYPpA21LvZisv7s08bAUOKZNw00hi1SRlBtp6BP(H02rcSqhCaJxQhCJOlNmARbV7im4AlHXnKBlEfhWJcbgCmwuWaEfVyposZJrsJ2GluqO3bLhyXgPgElEfhWJIjtId4rPjviEL)glKblh(qZfkXb8O0KkeVYFJfYG9hg8xJVgH0IivTlzPW1wIjt7pm4VgFncPfrQAxIzW2g3q38lXaNi06rgstgEknNxtpgjAUOSwnJfQ5IsoRrt5e1CqZfnxo8jmQjnb1KPsbr0K6bAg6MRzxx2MMDPiyOHOP8AsGC2AUOKtnzywNhTwxQF0SO004jKkWIn9OVL6hsBhjCaR7qhCaJxQhCJOlNmwuWaEfVyposZJrsRgZwo87mWR4f7XrAEmsArAGl1pC3FyWFn(AeslIu1UeZGTnUHU5xIborUqy)Vn(lMg5S6Ba0JqYfkiS)EC8rA94iNqcmzkIb0uunkRZJwRl1pnAdtM2)BJ)IPrzDE0ADP(PbWqVgIzWTeO1JmKMRqoBnzACIOiUMlQj(l0CrjNAYKI)uiIBpGao6yZj(WtxJlOMfLMUHHT2EGf1J(wQFiTDKWbSU7Dq5bwKXXdry94err87u8NcrC7beC3)elP(HXE3sJWGG4wCK2u8NcrC7be0WXdSy0KjiiUfhPHMt8HNUgxWgoEGfJMmT)3g)ftdnN4dpDnUGnag61qyWs6mZlvCloslIObcUeb4IZJHnC8alg1JmKMmLEjA(JMmnoruextQhOjeZbGxqnxuYPMm1UKrnPhlsiAUa10bOMUOzOBUMDDz1K6bAYWSopATUu)Oh9Tu)qA7iHdyD37GYdSiJJhIW6XjII43q)U)jws9dJ9ULgHbbXT4iTqNii46eIti10WXdSy0KP4lnEhaEbBsTpudVjt7VhhFKwpoYjKaU7pm4VgFncPfrQAxcm4RhzinxHC2AY04errCnxuYPMmmRZJwRl1pA6tuZv0GuenDIM2F410jAUa1CXpCw00(eutxZTten)EeOPCIAsv8NIMrAGl1p6rFl1pK2os4aw39oO8alY44HiSECIOi(D)944JC3)elP(HXIc2(7XXhPDasq5Jjt7VhhFK2GBWBFq0KP93JJpsB(bzS3T0im40J(wQFiTDKWbSU7Dq5bwKXXdry94err87(7XXh5U)jws9dJffS93JJpsRhh5esaJ9ULgHrz)hafuuf)PCbyOxdPZmdFO7cqbhZWFP9oO8al26XjII43Dean0Mrz)hafuuf)PCbyOxdPZmd)oV)3g)ftJY68O16s9tdGHEneO7cqbhZWFP9oO8al26XjII43Dean0Mmfqtr1OSopATUu)CdOPOA0gMmfXaAkQgL15rR1L6NgTHjtbpHWLQ4pLlad9AimGz4Rh9Tu)qA7iHdyD37GYdSiJJhIW6XjII4393JJpYD)tSK6hglky7VhhFK2u8NYLYrg7DlncJY(pakOOk(t5cWqVgsNzg(q3fGcoMH)s7Dq5bwS1JtefXV7iaAOnJY(pakOOk(t5cWqVgsNzg(DE)Vn(lMgbnifPbWqVgc0DbOGJz4V0EhuEGfB94err87ocGgAtMIV0iObPinP2hQH3KPGNq4sv8NYfGHEnegWm81JmKMmmlso3aNs0K6bAUS0eH2IA2XaAdP(rZIsZ5fnjc6w5eJA(anRrtxZ9)24Vy0Cd52I6rFl1pK2os4aw3uwKCUboLWyrbdkYtBdQj2mOjcTfViG2qQFmzI802GAIT(36szXl5T94iqZfcebDRCIXMBTCHqedOPOA94err8gTb3qNii46eIti1CbyOxdbg85cfoiGhYMuH4v(BOB(D)Hb1GrZy2KjieXaAkQg5S6B0gqZyncca0gYTcdXy5ccdogRrqaG2qU82pWTWGJXAeeaOnKBrbJ802GAIT(36szXl5T94i6rgsZviNTMmmRZJwRl1pAUOKtnzACIOiUMort7p8A6enxGAU4holAAFcQPR52jIMFpc0uornPk(trZinWL6hnH6bAwuAY04errCnxuwRM7pe1mW3h0059A6UiAkppVfJA(uuq30J(wQFiTDKWbSUPSopATUu)WyrbdcebDRCIXg45PrUqT)3g)ftRhNikI3ayOxdHblNBVdkpWITECIOi(n0V7FILu)WfPOWTu94D)Hb)14RriMbJtCfhWJstQq8k)nwOzWbFtMIyanfvRhNikI3Onmzk4jeUuf)PCbyOxdHbmZjO1J(wQFiTDKWbSUPSopATUu)WyrbdcebDRCIXg45PrUiffULQhV7pm4VgFncXmyCIluu2)bqbfvXFkxag61q6mZCc6Uau7)TXFXS0EhuEGfBuwNhTwxQFU7iaAOnJY(pakOOk(t5cWqVgsNzMtDE)Vn(lMwporueVbWqVgYs7Dq5bwS1JtefXV7ia6Uau7)TXFXS0EhuEGfBuwNhTwxQFU7iaAOHwpYqAUc5S1CfnifrZfLCQjtJtefX10jAA)HxtNO5cuZf)Wzrt7tqnDn3or087rGMYjQjvXFkAgPbUu)WOMb0IMgaKcbAkoGhfIMYPlAUOSwnTvpQPlAArNiAch8j6rFl1pK2os4aw3e0GueglkyqGiOBLtm2appnYn(sJ3bGxWMu7d1WZfQ9)24VyA94err8gad9AimaoUId4rPjviEL)gl0m4GVjtrmGMIQ1JtefXB0gMmf8ecxQI)uUam0RHWa4Gp06rFl1pK2os4aw3e0GueglkyqGiOBLtm2appnYfkk7)aOGIQ4pLlad9AiDgo4dDxy)Vn(lgOnJY(pakOOk(t5cWqVgsNHd(DE)Vn(lMwporueVbWqVgYs7Dq5bwS1JtefXV7ia6UW(FB8xmqdTE03s9dPTJeoG1DporueNXIcgeic6w5eJnWZtJCJV0a0gcnaBsTpudpxieXaAkQwporueVrBWT3bLhyXwporue)of)Pqe3Eab39pXsQF427GYdSyRhNikIFd97(Nyj1pC7Dq5bwS1JtefXV7VhhFK7(Nyj1p6rgsZo2CIp8014cQ5ItC0CErtIGUvoXOM(e1m4Ltn7iAdHgGA6tutiMdaVGA6autAdnPEGM2F41eNNM)SPh9Tu)qA7iHdyDJMt8HNUgxqglkyqGiOBLtm2appnYfkieFPX7aWlydGuaKC6bwKB8LgG2qObydGHEneZ4ehCAPBJBOB(LyGtCPqbxxi(sdqBi0aSHMt8HNUgxW4f4ccTjtXxAaAdHgGnag61qwk8BlXmXb8O0KkeVYFJfcnxXb8O0KkeVYFJfAgN0JmKMRNvVMfLMqKhEenDaQjTbdNAwuAYKI)u0KH5OMUiyOHOP8AsGC2AUOKtnxrdsr08bAY04errCnlknxGAU4holAUWjcQz4dqnLtF080TuAUEw9CMO5(FB8xm6rFl1pK2os4aw3KZQNXIcgeIyanfvJCw9nAdUqfFPX7aWlytQ9HA45gFPbOneAa2KAFOgEO5cfe2Fpo(iTP4pLlLJMmbfu7)TXFX0iObPina6rinzA)Vn(lMgbnifPbWqVgIzWXm0Ca1(FB8xmTECIOiEdGEestM2)BJ)IP1JtefXBam0RHS0EhuEGfB94err87ocmdoMHggZqdTE03s9dPTJeoG1TXl1pmwuWcOPOAb2)JwAI0aOVftMcEcHlvXFkxag61qyWYHVjtrmGMIQ1JtefXB0g6rFl1pK2os4aw3b2)JxkAaKmwuWIyanfvRhNikI3On0J(wQFiTDKWbSUdqabbhQHNXIcwedOPOA94err8gTHE03s9dPTJeoG1nvbWa7)rglkyrmGMIQ1JtefXB0g6rFl1pK2os4aw3(SrIaC7D7wlJffSigqtr16XjII4nAd9OVL6hsBhjCaR7TBTxFl1pxBreghpeH17trozSOGbbIGUvoXyZTwUHorqW1jeNqQ5cWqVgcm4Rh9Tu)qA7iHdyDttWBjyiJJhIWwutKSDWDXjke5hKXIcgXaT2R4aEuinkFUp19Wu9iXSiskagVId4rHyYeWR4f7XrAEmsA1ywha(Mmf8ecxQI)uUam0RHWGUi9idP5kKZwt5e10aupOei1KiUOzanfLMcOMdOO5Iso1KPXjII4mQ5lNiyrrqnPjOM)O5(FB8xm6rFl1pK2os4aw3cOMdOahJffSEhuEGfBcOMdOCjqo7lX(cm44cvedOPOA94err8gTHjtbpHWLQ4pLlad9AimagZWhAtMGQ3bLhyXMaQ5akxcKZ(sSVaJzUqqa1CaLgZT9)24VyAa0JqcTjtqO3bLhyXMaQ5akxcKZ(sSVOh9Tu)qA7iHdyDlGAoGcZmwuW6Dq5bwSjGAoGYLa5SVe7lWyMlurmGMIQ1JtefXB0gMmf8ecxQI)uUam0RHWaymdFOnzcQEhuEGfBcOMdOCjqo7lX(cm44cbbuZbuAW12)BJ)IPbqpcj0MmbHEhuEGfBcOMdOCjqo7lX(IEupYqmKMqKcGBrZOh68OMEqzlPqIEKH0SJNEC(qnDrtoXHMqTeo0CrjNAcrwHwZUUSnnz4ddXy5cAHuZF0Kzo0uCapkeg1CrjNAY04errCg18bAUOKtnHxNy4uZxorWIIGAUWlrtQhOj5drnXbb8q20SlTKxZfEjAwuA2XMt41C)HbVMfrZ9hwdVM0gn9OVL6hslwaClWWPhNpKXIcgsrHBP6X7(dd(RXxJqmdgN4qCloslIObcUeb4IZJHnC8alg5cvedOPOA94err8gTHjtrmGMIQroR(gTHjtrmGMIQrzDE0ADP(PrByYeoiGhYwePQDjmagZlHdCqapKnaYJZD)Hb1GrtMGqVdkpWInsn8w8koGhftMqkkClvpE3FyWFn(AeIzBJBOB(LyGteAUqbbXT4in0CIp8014c2WXdSy0KP9)24VyAO5eF4PRXfSbWqVgIzmdTE03s9dPflaUfoG1DVdkpWImoEicJMGxQYAraJ9ULgHT)WG)A81iKwePQDjMbNjt4GaEiBrKQ2LWaymVeoWbb8q2aipo39hgudgnzcc9oO8al2i1WBXR4aEu0JmKMDPHHfsnx70QMYRPBTAkoGhfIMlk58PfnDnJyanfLMortdq9GsGKrnnaifca1WRP4aEuiAgHSgEnj)piqtNsqGMYjQPbOcDaKAkoGhf9OVL6hslwaClCaRBccaUGXBWp4Lyuhqglky9oO8al2Oj4LQSweWfcXxAeeaCbJ3GFWlXOoG34lnP2hQHxp6BP(H0Ifa3chW6MGaGly8g8dEjg1bKXnKBlEfhWJcbgCmwuW6Dq5bwSrtWlvzTiGleIV0iia4cgVb)GxIrDaVXxAsTpudVEKH0KPardnPaFOMB3WOgEn3NoGhjA(andObJMUOPCIAItuZNstQI)ui6rFl1pKwSa4w4aw3eeaCbJ3GFWlXOoGmwuW6Dq5bwSrtWlvzTiGBOteeCDcXjKAUam0RHWa436GCHk4jeUuf)PCbyOxdHbWwIjt7)TXFX0iia4cgVb)GxIrDaBHU539Pd4rsN3NoGhjxkGVL6h3YayWVX8sGwpYqAYuEIJMm1UuZIO58IMUO5zXFQzKg4s9dJAsGC2AUOKtnJEOZJAgqtrr0CrjNpTO53JGfGsQHxZLb9OMbqQzhBUhAyr9OVL6hslwaClCaRBccaUGXBWp4LyuhqglkyqGGYn4hAstkeWCh8YSXMBVdkpWInAcEPkRfbCdDIGGRtioHuZfGHEnega)whKluKN2gutSzrpEdG8IM7HgwSHJhyXixieqtr1SOhVbqErZ9qdl2On4gXaAkQwporueVrByYuanfvl0bGFbgV8yir(bV4C6ZgdXrA0gMmbHEhuEGfBKA4T4vCapkCJyanfvJCw9nAdO1J(wQFiTybWTWbSUjia4cgVb)GxIrDazSOGrq5g8dnPjfcyUdEz2yZT3bLhyXgnbVuL1IaUHorqW1jeNqQ5cWqVgcdGFRdYnIb0uunEaDKhVHUSpB0gCHqanfvZIE8ga5fn3dnSyJ2GlWR4f7XrAEmsA1y2s0JmKMmCjOMRDAvt51Kqhg(JMmfyFnCMOzx8hIkARHxZIstiFAnp9Eut5e1K802GAIn9OVL6hslwaClCaRBccaUGXBWp4LyuhqgT1G3DegClHXIcg5PTb1eBhW(Ai3)HOI2A45gqtr1oG91qU)drfT1W3I)IrpYqAYW8rZNstMIP6rIMUOjCq0COjr89bIMpLMDXuXioA2jRhrIMpqtN3RHiAYjo0uCapkKME03s9dPflaUfoG1nLp3N6EyQEKWyrbR3bLhyXgnbVuL1IaUqfqtr1oRyeNBG1JiPreFFWmyWbrBYeuqWaupOeiVGxCP(HlXaT2R4aEuinkFUp19Wu9iXmyCIdIGUvoXyd880i0qRhzinzy(O5tPjtXu9irt510nmSqQPXxKFiAwuAwJVLQh18hn9bsnfhWJIMq9an9bsndSigRHxtXb8Oq0CrjNAAaQhucKAcEXL6hO10fnxo80J(wQFiTybWTWbSUP85(u3dt1Jeg3qUT4vCapkeyWXyrbdkiyaQhucKxWlUu)yYu8LgVdaVGnP2hQH3KP4lnaTHqdWMu7d1Wdn3EhuEGfB0e8svwlc4smqR9koGhfsJYN7tDpmvpsmd2Y1J(wQFiTybWTWbSUX95xd)fGgGk0NiJffSEhuEGfB0e8svwlc4U)3g)ftRhNikI3ayOxdXm4GVE03s9dPflaUfoG1ThgqtozSOG17GYdSyJMGxQYAraxOcDIGGRtioHuZfGHEneyWNlea0ds9aESf)pmW6r0KPaAkQwGTMiPIyJ2aA9idPj88GoZuPLY6cQP8A6ggwi1eIGE0cPMl7xKF00fnzwtXb8Oq0J(wQFiTybWTWbSUdPLY6cY4gYTfVId4rHadoglky9oO8al2Oj4LQSweWLyGw7vCapkKgLp3N6EyQEKaJz9OVL6hslwaClCaR7qAPSUGmwuW6Dq5bwSrtWlvzTiqpQhzigstiIh68OMFpc0uQqutpOSLuirpYqAUmvyjAsW9prhaPMqmhaEbjAs9anna1dkbsnbV4s9JMfLMlqnp9EuZLVenXbb8qQja5XrZhOjeZbGxqnxuwRMO5gfa18hnLtutdqf6ai1uCapk6rFl1pKw8fy9oO8alY44HimYHY4UHCBXlVdaVGm27wAeMbOEqjqEbV4s9dxOIV04Da4fSbWqVgcd2)BJ)IPX7aWlylsdCP(XKPEhuEGfBaKhNlXfAGlyeA9idP5YuHLOjb3)eDaKA2r0gcnajAs9anna1dkbsnbV4s9JMfLMlqnp9EuZLVenXbb8qQja5XrZhO56z1Rzr0K2qZF0Kz4XHE03s9dPfFHdyD37GYdSiJJhIWihkJ7gYTfVaAdHgGm27wAeMbOEqjqEbV4s9dxOIyanfvJCw9nAdUed0AVId4rH0O85(u3dt1JeZy2KPEhuEGfBaKhNlXfAGlyeA9idP5YuHLOzhrBi0aKOzrPjtJtefX5y9S67MP6ebbA2LeIti1Ozr0K2qtFIAUa1807rnzMdnj4(NirtlsjA(JMYjQzhrBi0autiYdp9OVL6hsl(chW6U3bLhyrghpeHrougxaTHqdqg7DlnclIb0uuTECIOiEJ2GlurmGMIQroR(gTHjtHorqW1jeNqQ5cWqVgIzWhAUXxAaAdHgGnag61qmJz9idP5QbUl3QjeZbGxqn9jQzhrBi0autck0gAAaQhOP8A2XMt8HNUgxqn3or0J(wQFiT4lCaRBEhaEbzSOGjUfhPHMt8HNUgxWgoEGfJCHWIYAV2NGx0CIp8014cYn(sJ3bGxWMriTvkdBHagadoU7)TXFX0qZj(WtxJlydGHEnegWmxIbATxXb8OqAu(CFQ7HP6rcm44c8kEXECKMhJKwnM1b4gFPX7aWlydGHEnKLc)2syG4aEuAsfIx5VXc1J(wQFiT4lCaRBaTHqdqglkyIBXrAO5eF4PRXfSHJhyXixOqkkClvpE3FyWFn(AeIzW2g3q38lXaNi39)24VyAO5eF4PRXfSbWqVgcdGJB8LgG2qObydGHEnKLc)2syG4aEuAsfIx5VXcHwpYqAcXCa4futAJdiAWOMUL8AkGcjAkVM0euZs00jA6AsmWD5wn5XbbU8anPEGMYjQP1jIMDDz1maPEaQPRjvnf5eb6rFl1pKw8foG1TX)2lajpnyJms9G7GMlWGtp6BP(H0IVWbSU5Da4fKXIcgaPai50dSi39hg8xJVgH0IivTlXmyWXfkJqARug2cbmagCMmbWqVgcdGj1(WvQqKlXaT2R4aEuinkFUp19Wu9iXmylhAUqbHfL1ETpbVO5eF4PRXf0Kjag61qyamP2hUsfIlLzUed0AVId4rH0O85(u3dt1JeZGTCO5cL4aEuAsfIx5VXc7mad9AiqBgN4g6ebbxNqCcPMlad9AiWGVE03s9dPfFHdyDB8V9cqYtd2iJup4oO5cm40J(wQFiT4lCaRBEhaEbzCd52IxXb8OqGbhJffmi07GYdSyJCOmUBi3w8Y7aWlixasbqYPhyrU7pm4VgFncPfrQAxIzWGJlugH0wPmSfcyam4mzcGHEnegatQ9HRuHixIbATxXb8OqAu(CFQ7HP6rIzWwo0CHcclkR9AFcErZj(WtxJlOjtam0RHWaysTpCLkexkZCjgO1EfhWJcPr5Z9PUhMQhjMbB5qZfkXb8O0KkeVYFJf2zag61qG2m4yMBOteeCDcXjKAUam0RHad(6rgsZUcQqYpAcpm0ajIM)OziTvkdlQP4aEuiA6IMCIdn76YQ5ItC0eqptn8A(0IM1OjZDEjenDIM2F410jAUa1807rnX5P5p1eG84OPprnDaoCw0KGIudVM0gAs9anzACIOiUE03s9dPfFHdyDVbvi5NRGHgiryCd52IxXb8OqGbhJffmIbATxXb8OqmdgZCrkkClvpE3FyWFn(AeIzW4exCqapKnaYJZD)Hb1GrZyg(CHcc7)TXFX06XjII4na6rinzk(sdqBi0aSj1(qn8qZfGHEnegWmhlFPqrmqR9koGhfIzW4e06rgstMcen0K2qZoI2qObOMUOjN4qZF00TwnfhWJcrtOwCIJM2QVgEnT)WRjopn)PM(e1CErtY4gKZxGwp6BP(H0IVWbSUb0gcnazSOGbHEhuEGfBKdLXfqBi0aKlsrHBP6X7(dd(RXxJqmdgN4cqkaso9alYfkJqARug2cbmagCMmbWqVgcdGj1(WvQqKlXaT2R4aEuinkFUp19Wu9iXmylhAUqbHfL1ETpbVO5eF4PRXf0Kjag61qyamP2hUsfIlLzUed0AVId4rH0O85(u3dt1JeZGTCO5koGhLMuH4v(BSWodWqVgIzqXjoGcqpi1d4Xw0jN1WFj7NEIa0U0LanhqbOhK6b8yl(FyG1J4sxc0CavVdkpWInaYJZL4cnWfmU0oa0qRh9Tu)qAXx4aw3aAdHgGmUHCBXR4aEuiWGJXIcge6Dq5bwSroug3nKBlEb0gcna5cHEhuEGfBKdLXfqBi0aKlsrHBP6X7(dd(RXxJqmdgN4cqkaso9alYfkJqARug2cbmagCMmbWqVgcdGj1(WvQqKlXaT2R4aEuinkFUp19Wu9iXmylhAUqbHfL1ETpbVO5eF4PRXf0Kjag61qyamP2hUsfIlLzUed0AVId4rH0O85(u3dt1JeZGTCO5koGhLMuH4v(BSWodWqVgIzqXjoGcqpi1d4Xw0jN1WFj7NEIa0U0LanhqbOhK6b8yl(FyG1J4sxc0CavVdkpWInaYJZL4cnWfmU0oa0qRhzinzyU1g47dA2LFhRzxbvi5hnHhgAGerZfLCQPCIAs8qut7ZxBnDIMEW3JmQzaTOzXppOgEnLtutCqapKAU)jws9drZIsZfOMoaholAstQHxZoI2qObOE03s9dPfFHdyDVbvi5NRGHgirySOGrmqR9koGhfIzWyMlsrHBP6X7(dd(RXxJqmdgN4cWqVgcdyMJLVuOigO1EfhWJcXmyCcA9idPzxbvi5hnHhgAGerZF0CfEAwuAwJMg(eXWARPprnh0bwi1m0nxtCqapKA6tuZIsZoE6X5d1CXpCw0m(Ag(auZOh68OMrAut51eEDQBMAxQh9Tu)qAXx4aw3Bqfs(5kyObseglkyed0AVId4rHadoUqbba9GupGhBrNCwd)LSF6jcqRjta6bVlEqSrbEI0WXdSyeAUHorqW1jeNqQ5cWqVgcm4ZfPOWTu94D)Hb)14RriMbdQTXn0n)smWj2z4GMlaPai50dSixiSOS2R9j4fnN4dpDnUGCHccrmGMIQroR(gTHjtrmGMIQXdOJ84n0L9zdGHEneZygAUId4rPjviEL)glSZam0RHygN0J6rgIH0Cvq3kNyuZUCl1pe9idPjtk(tI42diqZF0C5WRd1SRGkK8JMWddnqIOh9Tu)qAebDRCIryBqfs(5kyObseglkyIBXrAtXFkeXThqqdhpWIrUed0AVId4rHygSLZD)Hb)14RriMbJtCfhWJstQq8k)nwyNbyOxdXSoGEKH0Kjf)jrC7beO5pAch86qnxh3GC(IMDeTHqdq9OVL6hsJiOBLtmYbSUb0gcnazSOGjUfhPnf)Pqe3EabnC8alg5U)WG)A81ieZGXjUId4rPjviEL)glSZam0RHywhqpYqAUshiiGIMh7qn7sddlKA(an7iKcGKtnxuYPMb0uuyutiMdaVGe9OVL6hsJiOBLtmYbSUn(3Ebi5PbBKrQhCh0CbgC6rFl1pKgrq3kNyKdyDZ7aWliJBi3w8koGhfcm4ySOGjUfhPrOdeeqrZJnC8alg5cHfL1ETpbVO5eF4PRXfKluam0RHWa4yUlGMt8HNUgxW4f4cAYKriTvkdBHagadoO5koGhLMuH4v(BSWodWqVgIzmRhzinxPdeeqrZJAYHMDS5eEn)rt4GxhQzhHuaKCQjeZbGxqnDrt5e1eNOMpLMebDRCQP8AYJIMHU5AgPbUu)Ozas9auZo2CIp8014cQh9Tu)qAebDRCIroG1TX)2lajpnyJms9G7GMlWGtp6BP(H0ic6w5eJCaRBEhaEbzSOGjUfhPrOdeeqrZJnC8alg5kUfhPHMt8HNUgxWgoEGfJC9Tu94fhmSqcm44gqtr1i0bccOO5Xgad9AimaU2Y1J6rgIH0KP9PiN6rgstgwnf5uZfLCQzOBUMDDz1K6bAYKI)uiIBpGag1KESiHOjnPgEnHiOlNwi1C90J)cIE03s9dP17troH17GYdSiJJhIWMI)uiIBpGG724U)jws9dJ9ULgHbfea0ds9aESfrxoTqEjNE8xq4Iuu4wQE8U)WG)A81ieZGTnUHU5xIborOnzcka9GupGhBr0LtlKxYPh)feU7pm4VgFncHbmdTEKH0KP9PiNAUOKtn7yZj8AYHMmP4pfI42diOd1KP6MxH0HA21LvtFIA2XMt41eGEesnPEGMdAUOjeRRqe9OVL6hsR3NICYbSU79PiNmwuWe3IJ0qZj(WtxJlydhpWIrUIBXrAtXFkeXThqqdhpWIrU9oO8al2MI)uiIBpGG724U)jws9d39)24VyAO5eF4PRXfSbWqVgcdGtpYqAY0(uKtnxuYPMmP4pfI42diqto0KjVMDS5e(outMQBEfshQzxxwn9jQjtJtefX1K2qp6BP(H069PiNCaR7EFkYjJffmXT4iTP4pfI42diOHJhyXixiiUfhPHMt8HNUgxWgoEGfJC7Dq5bwSnf)Pqe3Eab3TXD)tSK6hUrmGMIQ1JtefXB0g6rFl1pKwVpf5KdyDB8V9cqYtd2iJup4oO5cm4yenxa(1dF6rGXPLOh9Tu)qA9(uKtoG1DVpf5KXIcM4wCKgHoqqafnp2WXdSyK7(FB8xmnEhaEbB0gCJyanfvRhNikI3On4cv8LgVdaVGnasbqYPhyrtMIV04Da4fSzesBLYWwiGbWGdAU7pm4VgFncPfrQAxIzWGIyGw7vCapkKgLp3N6EyQEKywxSCcAUaVIxShhP5XiPvJzWXSEKH0KP9PiNAUOKtnzQorqGMDjH4KA6qn7iAdHgGCaXCa4fuZ5fnRrtasbqYPMaF4rg1msdQHxtMgNikIZX6z130CfYzR5Iso1CfnifrtQACRMNLOzrPPXtivGfB6rFl1pKwVpf5KdyD37trozSOGbL4wCKwOteeCDcXjKAA44bwmAYeGEqQhWJTqhC4(ux5eVHorqW1jeNqQbAUqi(sdqBi0aSbqkaso9alYn(sJ3bGxWgad9AiMTCUrmGMIQ1JtefXB0gCHkIb0uunYz13OnmzkIb0uuTECIOiEdGHEnegWjtMIV0iObPinP2hQHhAUXxAe0GuKgad9Aimy5SRedCZYeMxcenRWkSSa]] )


end
