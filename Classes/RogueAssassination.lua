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


    spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )

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


    spec:RegisterPack( "Assassination", 20220308, [[diLGNcqivf9iHsDjvvLSjIYNuvyuQQCkvLwLsQ6vcvnlHIBjuPDjPFHKyyQQYXqclJq6zkj10iQ01usY2ieX3iePghrv4CkPIwhrfENQQQsZdjP7rO2hvf)JOksDqIQQfsi8qHsMOQQIlkurBKqu9rvvvgjrvKCsvvvzLiPEjHizMevLBsik7ujLFsufXqvsLwkrv6PezQkjUQQQQQTsurFvvvPgRqf2Rs9xvzWKoSOftLESkMSexgAZi1NPIrRsDAPwTQQQIxRsmBb3wi7wXVbgov54kPclh0ZrmDkxNGTReFxL04PQ05rIwprvuZNQQ9J6nf7v2sL0W9AI(NOI(3Q)BDw)BDUQv)Nizlzu6HBjV8CjDWT0Kr4ws(jKKq6jTgmBjVKYail7v2seGa8GBPBZ8iYbvOItB3cU1diIkKosiKwdMdmPnQq6Odv2sUcDW(FZ2Dlvsd3Rj6FIk6FR(V1z9V15Qw9FYDlLc2naULK6OyTLU7sbNT7wQGKZws(jKKq6jTgmSkVahbKPwKLWZnRYJyyv0)evuMAM6yDNJdsKdM64YQ875fOK1pigSp2hSshshwnaReqeYQ8VUYhR0a4fcRgGvsUGS6bbhKq6XHvRJWktDCz9FaZhgRYzon5MvHjGecRsH(GSMtH1)PpiRx7qG1qsmwdGXbHSA35WQiljgczv(jKKq6PYuhxwLxmK(YQipKoyiKwdgwPcRYjof0SKvcLZH1FnnRYjof0SK1MWQbCCcyHvannRaiRGH1K1ayCynw)Z3ktDCzvKLxqwf5bKCFGjTXApgcHcEgR9W6be5MgRnnRxrw))iqmwlDH12yLgazDbesRd4Jacl4yvM64Y6)pbzvsesSgbGiRgGvIqueyyvKcx65dcRYtaYZyOhhwBAwPeiW6DUGSA3iReGqWTNsLPoUSglWSGqJvOWGVRayPsdbeJvdWQRanDfkm47kawE0qaXQcEvM64YQ8xkyH1)DpfYjHS(VVrJyGbRm1XL1vUI5fSWAC6ljhhHEsdz1aS6GgRceSWAtZkLaHpwqwLtCkOzzCj54i0tAyPULcnXi7v2sedZGDJL9k71OyVYwcN0nGLTi2s5XAWSLoWoIaMNHrEiX2sfKCGTN1GzlTw7CtSmCbHScgwx9kYbRXc2reWW6kyKhsST0b2gc7ClzzahRoTZTrSmCbHvCs3awyvgRepmeEwcDqJWQpIzD1SkJ1diYf88a9yew9rmRYLvzSAj0bTQ1r4ZaVsJSgxwHyu2dHvFyvKST9AIUxzlHt6gWYweBP8yny2sqbptaIBPcsoW2ZAWSLwRDUjwgUGqwbdRuSICWQ0KEKBGXQ8k4zcqClDGTHWo3swgWXQt7CBeldxqyfN0nGfwLX6be5cEEGEmcR(iMv5YQmwTe6Gw16i8zGxPrwJlRqmk7HWQpSks22ETvVxzlHt6gWYweBP8yny2sEaq4brcqaEWTubjhy7zny2sscUgcPfCq5Gv53ZlqjRaiRYlsdrYnRxB7MvxbAASW6)LqiWqYwIgaFd6RTxJITTxtU7v2s4KUbSSfXwkpwdMTKtcHad3shyBiSZTKLbCSkrW1qiTGdwXjDdyHvzS(jRx7q4fae8H(sYXrON0qwLX6pwHyu2dHvQYkfIYkvyf9LKJJqpPHLhmnKv)(z1lsiyTxOriRuvmRuW6xwLXQLqh0QwhHpd8knYACzfIrzpew9Hvr3shkpb8zj0bnYEnk22ETvTxzlHt6gWYweBP8yny2sEaq4brcqaEWTubjhy7zny2sscUgcPfCqwJN140xIdRGHvkwroyvErAisUz9)sieyiRPXQDJSItHvanRedZGDZQby1bnwJsFzTiatRbdRUinaISgN(sYXrON0WTena(g0xBVgfBBVMizVYwcN0nGLTi2shyBiSZTKLbCSkrW1qiTGdwXjDdyHvzSAzahRI(sYXrON0WkoPBalSkJ18y9c(WbJAKWQywPGvzS6kqtxjcUgcPfCWkeJYEiSsvwPOU6TuESgmBjNecbgUTTTLwYPj37v2RrXELTeoPBalBrSLaEBjcABP8yny2sljSt3aULwYGaUL(X6NScfgKgaDWAbt7oq5JCNfWvsfN0nGfwLXkstJhRxW3be5cEEGEmcR(iM1J3lk99r8WPW6xw97N1FScfgKgaDWAbt7oq5JCNfWvsfN0nGfwLX6be5cEEGEmcRuLvrz97wQGKdS9SgmBjrEpn5M1RTDZAu6lRXADzLgazDT252iwgUGWyyvyciHWQaPhhw)hmT7aLSkDNfWvYwAjHVjJWT00o3gXYWfe(oEVdykT1GzB71eDVYwcN0nGLTi2s5XAWSLwYPj3BPcsoW2ZAWSLKZCAYnRxB7M140xIdRXZ6ATZTrSmCbHYbRIS03osiI1yTUSMtH140xIdRqmluYknaY6G(AS(FX6F2shyBiSZTKLbCSk6ljhhHEsdR4KUbSWQmwTmGJvN252iwgUGWkoPBalSkJ1Le2PBaRt7CBeldxq4749oGP0wdgwLX6bacfW1PI(sYXrON0WkeJYEiSsvwPyB71w9ELTeoPBalBrSLYJ1GzlTKttU3sfKCGTN1GzljN50KBwV22nRR1o3gXYWfeYA8SUgG140xIJCWQil9TJeIynwRlR5uyvoXPGMLSk4TLoW2qyNBjld4y1PDUnILHliSIt6gWcRYy9twTmGJvrFj54i0tAyfN0nGfwLX6sc70nG1PDUnILHli8D8EhWuARbdRYyTGUc001fCkOzzvWBB71K7ELTeoPBalBrSLYJ1Gzl5baHhejab4b3sOVgmFzeqySTKCx1wIgaFd6RTxJITTxBv7v2s4KUbSSfXw6aBdHDULSmGJvjcUgcPfCWkoPBalSkJ1daekGRt1jHqGHvbpwLXAbDfOPRl4uqZYQGhRYy9hRfGvDsieyyfI0qKCNUbKv)(zTaSQtcHadRErcbR9cnczLQIzLcw)YQmwpGixWZd0JrQfKUpTXQpIz9hRepmeEwcDqJuPZ5bOFxMEbjS6J80Skxw)YQmwHzxE4cownlfsThw9HvkeDlLhRbZwAjNMCVT9AIK9kBjCs3aw2IylLhRbZwAjNMCVLki5aBpRbZwsoZPj3SETTBwfzjXqiRYpHKKEKdwLxbptaIX)FjecmK1byS2dRqKgIKBwH54GXWAra2JdRYjof0SmEP7EPYQeLZH1RTDZQe6rAcR09KbwVBJ1MMvpaH0UbSULoW2qyNBPFSAzahRgLedHVKqscPNkoPBalS63pRqHbPbqhSgLWlpa9ZUXxusme(scjjKEQ4KUbSW6xwLX6NSwawfk4zcqScrAisUt3aYQmwlaR6KqiWWkeJYEiS6dRRMvzSwqxbA66cof0SSk4XQmw)XAbDfOPRK7EPk4XQF)SwqxbA66cof0SScXOShcRuLv5YQF)SwawLGEKMuT(CPhhw)YQmwlaRsqpstQqmk7HWkvzD1BBBBPcsNcbBVYEnk2RSLYJ1GzlDPpx2s4KUbSSfX22Rj6ELTeoPBalBrSLki5aBpRbZwsErIHzWUzTPz1dqiTBaz93ayDrimimDdiR4GrnsyThwpGi30(ULYJ1Gzlrmmd2922RT69kBjCs3aw2Iylb82se02s5XAWSLwsyNUbClTKbbClr8Wq4zj0bnsLoNhG(Dz6fKWkvzv0T0scFtgHBjspob8zj0bTTTxtU7v2s4KUbSSfXwc4TLiOTLYJ1GzlTKWoDd4wAjdc4wche6qzfIo48oGi3EWcR(W6Qx1wQGKdS9SgmBPybIC7blSgNdcDOKv5fDWH1bXcwy1aSsstaMgULws4BYiClbrhCEK0eGPHLTTxBv7v2s4KUbSSfXw6aBdHDULigMb7glviWra3sed2hBVgfBP8yny2sNmeE5XAW8cnX2sHMyVjJWTeXWmy3yzB71ej7v2s4KUbSSfXwkpwdMT0jdHxESgmVqtSTuOj2BYiClDkKTTxtKEVYwcN0nGLTi2s5XAWSLiH(GVCkVsFWTubjhy7zny2sRRGXQ08pSk4XApT1ziqjR0aiRXsWy1aSA3iRX6ojymScrAisUz9AB3SgNZcoGiwBAwtJ1a4kRfbyAny2shyBiSZT0NS6kqtxjH(GVCkVsFWQGhRYy9aICbppqpgHvFeZkfBBVM8yVYwcN0nGLTi2shyBiSZTKRanDLe6d(YP8k9bRcESkJvxbA6kj0h8Lt5v6dwHyu2dHvQY6QyvgRhqKl45b6XiS6JywL7wkpwdMTeol4aI22ET15ELTeoPBalBrSLYJ1GzlDYq4LhRbZl0eBlfAI9Mmc3sfGTT9Au83ELTeoPBalBrSLYJ1GzlDYq4LhRbZl0eBlfAI9Mmc3sLgIhBB71OGI9kBjCs3aw2IylDGTHWo3s4GqhkRfKUpTXQpIzLIvXA8SIdcDOScrhCEhqKBpyzlLhRbZwkHNCWNbGqCSTTxJcr3RSLYJ1GzlLWto4ZtiqWTeoPBalBrST9AuS69kBP8yny2sH252iV)pcfNiCSTeoPBalBrST9Aui39kBP8yny2sUPZdq)myFUq2s4KUbSSfX222wYdIhqKBA7v2RrXELTuESgmBP0Zlq5Zd0eWSLWjDdyzlITTxt09kBP8yny2sUaZcy5rhskXY1ECEgW3E2s4KUbSSfX22RT69kBjCs3aw2IylLhRbZwkkHxWYJgaFfmT7T0b2gc7Cl9jRhWco5y1fCSBkHSkJvy2LhUGJvZsHu7HvFyLIvTL8G4be5M2JGhWuiBjk(BB71K7ELTeoPBalBrSLoW2qyNBjcqi42tP6jqmHa(qOGN1GPIt6gWcR(9ZkbieC7PuxaH06a(iGWcowfN0nGLTuESgmBj6asUpWK222ETvTxzlHt6gWYweBjG3wIG2wkpwdMT0sc70nGBPLmiGBjkynUS(JvOWG0aOdwlcKlxZWfesEEPDUR4KUbSW66z9hR)vL7QynEw)XkbTNlyeivRrOOYJNC9oSUEw)RsbRFz9lRF3slj8nzeULwWPGMLVtbUT9AIK9kBjCs3aw2Iylb82se02s5XAWSLwsyNUbClTKbbClrbRXL1FScfgKgaDWkWflnohSIt6gWcRRN1)QYvUS(DlvqYb2EwdMT0k3iR5ccthK1y9pYlRnH1)QIkkRUcgRfbKvdWQDJSkVR9FSoPjarwb0SgR1LvhCIHvr9Lv7UjSUKbbK1MWkWZ6OmWknaYkHY50JdRbGtF2slj8nzeULOdPdgcP1G5DkWTTxtKEVYwcN0nGLTi2saVTebTTuESgmBPLe2PBa3slj8nzeULmypxq7rOCopsayBPdSne25wYG9CbTQrr9ojpILwnhkFfpcRYy9hRFYQb75cAvt06DsEelTAou(kEew97Nvd2Zf0Qgf1daekGRtTiatRbdR(iMvd2Zf0QMO1daekGRtTiatRbdRFz1VFwnypxqRAuuBsThYbkyPBaFRdHCmHOxbx6dYQF)S(Jvd2Zf0Qgf1Muj3zbC1bMeVNbmmIvzSEal4KJvxWXUPeY63Tubjhy7zny2s)dAimQhK1R395M1FnnR5q5xwjwAS6kqtZQb75cASEfz9AogRgG10mmYZy1aSsOCoSETTBwLtCkOzzDlTKbbClrX22Rjp2RSLWjDdyzlITeWBlrqBlLhRbZwAjHD6gWT0sgeWTKOBPdSne25wYG9CbTQjA9ojpILwnhkFfpcRYy9hRFYQb75cAvJI6DsEelTAou(kEew97Nvd2Zf0QMO1daekGRtTiatRbdR(WQb75cAvJI6bacfW1PweGP1GH1VS63pRgSNlOvnrRnP2d5afS0nGV1HqoMq0RGl9bz1VFw)XQb75cAvt0AtQK7SaU6atI3ZaggXQmwpGfCYXQl4y3ucz97wAjHVjJWTKb75cApcLZ5rcaBB71wN7v2s5XAWSLigMb7ElHt6gWYweBBVgf)TxzlHt6gWYweBP8yny2sKqFWxoLxPp4w6aBdHDUL(Kvld4y1PDUnILHliSIt6gWcRYyfI0qKCNUbCl5bXdiYnThbpGPq2suSTTTLknep2EL9AuSxzlHt6gWYweBP8yny2s4SGdiAlvqYb2EwdMTuCol4aIynnwLB8S(BvXZ612Uz9FK(YASw3kR)VOiS0PHbkzfmSkA8SAj0bnsmSETTBwLtCkOzzmScGSETTBwxreXWkWUr41MGSEnBJvAaKvciczfhe6qzLv5pqaSEnBJ1MM140xIdRhqKlG1MW6be1JdRcE1T0b2gc7ClH004X6f8DarUGNhOhJWQpIzvUSgpRwgWXQfe9q4JyW0shmQIt6gWcRYy9hRf0vGMUUGtbnlRcES63pRf0vGMUsU7LQGhR(9ZAbDfOPR0H0bdH0AWuf8y1VFwXbHouwliDFAJvQkMvrxfRXZkoi0HYkeDW5DarU9Gfw97N1pzDjHD6gWkPhNa(Se6GgR(9ZkstJhRxW3be5cEEGEmcR(W6X7fL((iE4uy9lRYy9hRFYQLbCSk6ljhhHEsdR4KUbSWQF)SEaGqbCDQOVKCCe6jnScXOShcR(WQOS(DB71eDVYwcN0nGLTi2saVTebTTuESgmBPLe2PBa3slzqa3shqKl45b6Xi1cs3N2y1hwPGv)(zfhe6qzTG09PnwPQywfDvSgpR4GqhkRq0bN3be52dwy1VFw)K1Le2PBaRKECc4ZsOdABPLe(Mmc3sce8r3Hac32ETvVxzlHt6gWYweBP8yny2seectdlpxWGpIxFb3sfKCGTN1Gzlj)EEbkzvsesSAawZqGvlHoOry9AB3abJ1K1c6kqtZAsy1d2ayBugdREqKgHWECy1sOdAewlu2JdReayqiRjTHqwTBKvpyhLqkz1sOdABPdSne25wAjHD6gWQabF0DiGqwLX6NSwawLGqyAy55cg8r86l4RaSQ1Nl94ST9AYDVYwcN0nGLTi2s5XAWSLiieMgwEUGbFeV(cULoW2qyNBPLe2PBaRce8r3HaczvgRFYAbyvccHPHLNlyWhXRVGVcWQwFU0JZw6q5jGplHoOr2RrX22RTQ9kBjCs3aw2IylLhRbZwIGqyAy55cg8r86l4wQGKdS9SgmBjrke9yLgcIy9KEE94W65oHoiHvaKvxb4WAASA3iR4uyfqZkD7CBKT0b2gc7ClTKWoDdyvGGp6oeqiRYynkjgcFjHKesppigL9qyLQS(xvEWQmw)XQlGqyvgR0TZT9Gyu2dHvQkM1vXQF)SEaGqbCDQeectdlpxWGpIxFbRrPVVZDcDqcRXL1ZDcDqYJgMhRbtgyLQIz9VQORI1VBBVMizVYwcN0nGLTi2s5XAWSLiieMgwEUGbFeV(cULki5aBpRbZw6FFJdRIm5N1MW6amwtJ1725M1IamTgmXWkHY5W612UzTKrPdYQRannH1RTDdemwbli8kSTECyv(WSWQlLSgN(MrEbClDGTHWo3sFYkbTNlyeivRrOOYJNOEhwLX6sc70nGvbc(O7qaHSkJ1OKyi8Lessi98Gyu2dHvQY6Fv5bRYy9hReGqWTNsnGz55s5d9nJ8cyfN0nGfwLX6NS6kqtxdywEUu(qFZiVawf8yvgRf0vGMUUGtbnlRcES63pRUc001OecbxXYZbJigyWho35CWiCSQGhR(9Z6NSUKWoDdyL0JtaFwcDqJvzSwqxbA6k5UxQcES(DB71eP3RSLWjDdyzlIT0b2gc7Clrq75cgbs1AekQ84jQ3HvzSUKWoDdyvGGp6oeqiRYynkjgcFjHKesppigL9qyLQS(xvEWQmwlORanD1bkuCWxuAN7QGhRYy9twDfOPRbmlpxkFOVzKxaRcESkJvy2LhUGJvZsHu7HvFyDvBP8yny2seectdlpxWGpIxFb32En5XELTeoPBalBrSLYJ1GzlrqimnS8Cbd(iE9fClf6bFNYwIIvTLoW2qyNBjcqi42tPEbx6H8aa5zm0JtfN0nGfwLXQRanD9cU0d5baYZyOhNAbCD2sfKCGTN1Gzl9)tqwLeHeRgGvIqueyyvKcx65dcRYtaYZyOhhwBAwPeiW6DUGSA3iReGqWTNsDB71wN7v2s4KUbSSfXwkpwdMTeDopa97Y0lizlvqYb2EwdMTKiphwb0Sksn9csynnwPyDgpRelpxiScOzvEQUuWHvreYcsyfaznDYEigRYnEwTe6GgPULoW2qyNBPLe2PBaRce8r3HaczvgR)y1vGMUE3Lcop3qwqsLy55cR(iMvkwNS63pR)y9tw9Gna2gLpiWsRbdRYyL4HHWZsOdAKkDopa97Y0liHvFeZQCznEwjgMb7glviWraz9lRF32Enk(BVYwcN0nGLTi2s5XAWSLOZ5bOFxMEbjBPcsoW2ZAWSLe55WkGMvrQPxqcRgG10ZlqjREGMagcRnnR9KhRxqwbdR5qjRwcDqJ1FaiR5qjRUbel94WQLqh0iSETTBw9Gna2gLScbwAny(YAASU6v2shyBiSZTuESEbFfGvlywcu(8anbmVcWyLQSMhRxWhoyuJewLX6pw)KvpydGTr5dcS0AWWQF)Swaw1jHqGHvRpx6XHv)(zTaSkuWZeGy16ZLECy9lRYyDjHD6gWQabF0DiGqwLXkXddHNLqh0iv6CEa63LPxqcR(iM1vVT9AuqXELTeoPBalBrSLoW2qyNBPLe2PBaRce8r3HaczvgRhaiuaxN6cof0SScXOShcR(Wkf)TLYJ1GzlHNBqpopi6b7OCkBBVgfIUxzlHt6gWYweBPdSne25wAjHD6gWQabF0DiGqwLX6pwJsIHWxsijH0ZdIrzpewfZ6FSkJ1pzfkmina6G1cae5gYcwXjDdyHv)(z1vGMU6g6Pq6cwf8y97wkpwdMTug5kqU32Enkw9ELTeoPBalBrSLYJ1GzlfjyDinClDO8eWNLqh0i71OylDGTHWo3sljSt3awfi4JUdbeYQmwjEyi8Se6GgPsNZdq)Um9csyvmRIULki5aBpRbZwAL0nUImbRdPHSAawtpVaLS(pywcuY66cAcyynnwfLvlHoOr22EnkK7ELTeoPBalBrSLoW2qyNBPLe2PBaRce8r3Hac3s5XAWSLIeSoKgUTTTLofYEL9AuSxzlHt6gWYweBP8yny2srj8cwE0a4RGPDVLc9GVtzlrrDvBPdLNa(Se6GgzVgfBPdSne25wcMD5Hl4y1SuivbpwLX6pw)K1Le2PBaRKECc4ZsOdAS63pRwcDqRADe(mWR0iRuL1v)hRFzvgR)y1sOdAvRJWNbELgzLQSEarUGNhOhJuliDFAJ11Zkf1vXQF)SEarUGNhOhJuliDFAJvFeZ6X7fL((iE4uy97wQGKdS9SgmBP)hnRzPqynHiRcEXWkzApKv7gzfmiRxB7M1a4ksmwxzL)PY6)pbz96noSwOShhwPtIHqwT7CynwRlRfKUpTXkaY612UbcgR5qjRXADRBBVMO7v2s4KUbSSfXwkpwdMTuucVGLhna(kyA3BPcsoW2ZAWSL(F0SoawZsHW61oeyT0iRxB7UhwTBK1b91yD1)rIHvbcYQiJ(FyLgaznk9L1yTUvwLFZWipJvdWkHY5W612UzvKhshmesRbdRnnREacPDdyDlDGTHWo3sWSlpCbhRMLcP2dR(W6Q)J14Ykm7YdxWXQzPqQfbyAnyyvgRhqKl45b6Xi1cs3N2y1hXSE8ErPVpIhofwLX6NSEaGqbCDQK7EPcXSqjRYy9hRFY6bSGtowDbh7MsiR(9ZAbDfOPR0H0bdH0AWuf8y1VFwpaqOaUov6q6GHqAnyQqmk7HWQpSsXQy9722RT69kBjCs3aw2Iylb82se02s5XAWSLwsyNUbClTKbbCl9jRwgWXQt7CBeldxqyfN0nGfw97N1pz1Yaowf9LKJJqpPHvCs3awy1VFwpaqOaUov0xsooc9KgwHyu2dHvQY6QynUSkkRRNvld4y1cIEi8rmyAPdgvXjDdyzlvqYb2EwdMTKeLZHv5eNcAwY61EkGRSETTBwxRDUnILHlim(40xsooc9KgYAtZA65f6t6gWT0scFtgHBPfCkOz5BANBJyz4ccFhWuARbZ22Rj39kBjCs3aw2Iylb82se02s5XAWSLwsyNUbClTKbbCl9jRwgWXQrjXq4ljKKq6PIt6gWcR(9ZAbyvNecbgwT(CPhhw97N1dybNCS6co2nLqwLX6be5cEEGEmsTG09PnwfZ6FBPcsoW2ZAWSL(3zBScgwLtCkOzjR0aiR)xcHadz9AB3SkYK)yyvyciHW6vK1eISMgRrPVSgR1LvAaKvrEiDWqiTgmBPLe(Mmc3sl4uqZYxu(oGP0wdMTTxBv7v2s4KUbSSfXwc4TLiOTLYJ1GzlTKWoDd4wAjHVjJWT0cof0S8Dal4KJ9oGP0wdMT0b2gc7ClDal4KJvVqjSZHv)(z9awWjhRo4bccayHv)(z9awWjhRoGb3sfKCGTN1Gzljr5CyvoXPGMLSETTBwf5H0bdH0AWWAofwLqpstynjSgaJdRjH1RiRxbZhgRbabznz9KeJvWccz1UrwPBNBJ1IamTgmBPLmiGBjk22EnrYELTeoPBalBrSLaEBjcABP8yny2sljSt3aULwYGaULOdaaK1FS(Jv6252Eqmk7HWACzv0)y9lRuH1FSsHO)X66zDjHD6gW6cof0S8Dkqw)Y6xw9Hv6aaaz9hR)yLUDUTheJYEiSgxwf9pwJlRhaiuaxNkDiDWqiTgmvigL9qy9lRuH1FSsHO)X66zDjHD6gW6cof0S8Dkqw)Y6xw97NvxbA6kDiDWqiTgmpxbA6QGhR(9ZAbDfOPR0H0bdH0AWuf8y1VFwDbecRYyLUDUTheJYEiSsvwf9VT0b2gc7ClDal4KJvxWXUPeULws4BYiClTGtbnlFhWco5yVdykT1GzB71eP3RSLWjDdyzlITeWBlrqBlLhRbZwAjHD6gWT0sgeWTeDaaGS(J1FSs3o32dIrzpewJlRI(hRFzLkS(Jvke9pwxpRljSt3awxWPGMLVtbY6xw)YQpSshaaiR)y9hR0TZT9Gyu2dH14YQO)XACz9aaHc46ujOhPjvigL9qy9lRuH1FSsHO)X66zDjHD6gW6cof0S8Dkqw)Y6xw97N1cWQe0J0KQ1Nl94WQF)S6ciewLXkD7CBpigL9qyLQSk6FBPdSne25w6awWjhRoTZT9OtClTKW3Kr4wAbNcAw(oGfCYXEhWuARbZ22Rjp2RSLWjDdyzlITubjhy7zny2sI8asUpWK2yLgazDDfiMqaznoHcEwdgwBAwhGXkXWmy3yHvaK1Eynz9aaHc46W6HYta3shyBiSZT0pwjaHGBpLQNaXec4dHcEwdMkoPBalS63pReGqWTNsDbesRd4Jacl4yvCs3awy9lRYy9twjgMb7gl1meyvgRFYAbDfOPRl4uqZYQGhRYynkjgcFjHKesppigL9qyvmR)XQmw)Xkoi0HYQ1r4ZaVO033be52dwy1hwfLv)(z9twlORanDLC3lvbpw)UL6XqiuWZEn9wIaecU9uQlGqADaFeqybhBl1JHqOGN96OiS0PHBjk2s5XAWSLOdi5(atABl1JHqOGN9Cca3mSLOyB71wN7v2s4KUbSSfXwkpwdMTeDiDWqiTgmBPcsoW2ZAWSLKOCoSkYdPdgcP1GH1RTDZQCItbnlznjSgaJdRjH1RiRxbZhgRbabznz9KeJvWccz1UrwPBNBJ1IamTgmS(dazTPzvoXPGMLSETdbwpGiKv38CH10j7HknHvd44eWcRaA6V1T0b2gc7Cl9jRedZGDJLke4iGSkJ1FSEaGqbCDQl4uqZYkeJYEiSsvwxnRYyDjHD6gW6cof0S8fLVdykT1GHvzSI004X6f8DarUGNhOhJWQpIzvUSkJvlHoOvTocFg4vAKvFyLI)y1VFwlORanDDbNcAwwf8y1VFwDbecRYyLUDUTheJYEiSsvwfvUS(DB71O4V9kBjCs3aw2IylDGTHWo3sFYkXWmy3yPcbociRYyfPPXJ1l47aICbppqpgHvFeZQCzvgR)yLoaaqw)X6pwPBNB7bXOShcRXLvrLlRFzLkS(J18ynyEhaiuaxhwxpRljSt3awPdPdgcP1G5Dkqw)Y6xw9Hv6aaaz9hR)yLUDUTheJYEiSgxwfvUSgxwpaqOaUo1fCkOzzfIrzpewxpRljSt3awxWPGMLVtbY6xwPcR)ynpwdM3bacfW1H11Z6sc70nGv6q6GHqAnyENcK1VS(L1VBP8yny2s0H0bdH0AWST9AuqXELTeoPBalBrSLYJ1Gzlrqpst2sfKCGTN1Gzljr5Cyvc9inH1RTDZQCItbnlznjSgaJdRjH1RiRxbZhgRbabznz9KeJvWccz1UrwPBNBJ1IamTgmXWQRGXQhePriRwcDqJWQDNgRx7qG1qVGSMgRbmjgRu8hzlDGTHWo3sFYkXWmy3yPcbociRYyTaSQtcHadRwFU0JdRYy9hRhaiuaxN6cof0SScXOShcRuLvkyvgRwcDqRADe(mWR0iR(Wkf)XQF)SwqxbA66cof0SSk4XQF)S6ciewLXkD7CBpigL9qyLQSsXFS(DB71Oq09kBjCs3aw2IylDGTHWo3sFYkXWmy3yPcbociRYy9hR0baaY6pw)XkD7CBpigL9qynUSsXFS(LvQWAESgmVdaekGRdRFz1hwPdaaK1FS(Jv6252Eqmk7HWACzLI)ynUSEaGqbCDQl4uqZYkeJYEiSUEwxsyNUbSUGtbnlFNcK1VSsfwZJ1G5DaGqbCDy9lRF3s5XAWSLiOhPjBBVgfREVYwcN0nGLTi2shyBiSZT0NSsmmd2nwQqGJaYQmwlaRcf8mbiwT(CPhhwLX6NSwqxbA66cof0SSk4XQmwxsyNUbSUGtbnlFt7CBeldxq47aMsBnyyvgRljSt3awxWPGMLVO8DatPTgmSkJ1Le2PBaRl4uqZY3bSGto27aMsBny2s5XAWSLwWPGMLBBVgfYDVYwcN0nGLTi2s5XAWSLqFj54i0tA4wQGKdS9SgmBP40xsooc9KgY61BCyDagRedZGDJfwZPWQlWUzvEf8mbiYAofw)VecbgYAcrwf8yLgaznaghwXbi4Cx3shyBiSZT0NSsmmd2nwQqGJaYQmw)X6NSwaw1jHqGHvisdrYD6gqwLXAbyvOGNjaXkeJYEiS6dRYL14zvUSUEwpEVO03hXdNcR(9ZAbyvOGNjaXkeJYEiSUEw)RUkw9HvlHoOvTocFg4vAK1VSkJvlHoOvTocFg4vAKvFyvUBBVgfRAVYwcN0nGLTi2s5XAWSLi39YwQGKdS9SgmBjP7EH1MM1)bScH1eISk4fdRnnRR1o3gRI8eznndJ8mwnaRekNdRxB7Mvj0J0ewbqwLtCkOzjRnnRxrwVcMpmwVMedzncarwT7Cy9od0SkD3lFqy9aaHc46SLoW2qyNBPpzTGUc00vYDVuf8yvgR)yTaSQtcHadRwFU0JdRYyTaSkuWZeGy16ZLECy9lRYy9hRFY6bSGtowDANB7rNiR(9Z6pw)X6bacfW1PsqpstQqmluYQF)SEaGqbCDQe0J0KkeJYEiS6dRuikRFznEw)X6bacfW1PUGtbnlRqmluYQF)SEaGqbCDQl4uqZYkeJYEiSUEwxsyNUbSUGtbnlFNcKvFyLcrz9lRIzvuw)Y63TTxJcrYELTeoPBalBrSLoW2qyNBjxbA6QBaakbbIvHyEmw97NvxaHWQmwPBNB7bXOShcRuL1v)hR(9ZAbDfOPRl4uqZYQG3wkpwdMTKhWAWST9AuisVxzlHt6gWYweBPdSne25wQGUc001fCkOzzvWBlLhRbZwYnaaLhTaKYTTxJc5XELTeoPBalBrSLoW2qyNBPc6kqtxxWPGMLvbVTuESgmBjxesq4LEC22EnkwN7v2s4KUbSSfXw6aBdHDULkORanDDbNcAwwf82s5XAWSLOBi6gaGY22Rj6F7v2s4KUbSSfXw6aBdHDULkORanDDbNcAwwf82s5XAWSLY5GedMH3jdHTTxtuk2RSLWjDdyzlIT0b2gc7Cl9jRedZGDJLAgcSkJ1OKyi8Lessi98Gyu2dHvXS(3wkpwdMT0jdHxESgmVqtSTuOj2BYiClTKttU32EnrfDVYwcN0nGLTi2s5XAWSLU2tHCs476nAedm4w6aBdHDULiEyi8Se6GgPsNZdq)Um9csy1hwliPHy5zj0bncR(9Zkm7YdxWXQzPqQ9WQpSks(Jv)(z1fqiSkJv6252Eqmk7HWkvzvKElnzeULU2tHCs476nAedm422Rj6Q3RSLWjDdyzlITuESgmBPtEUXhG(LN1HqdXYZGyseGizlDGTHWo3sUc0018SoeAiwEPVyvWJvzS(JvIhgcplHoOrQ058a0VltVGewfZkfSkJvy2LhUGJvZsHu7HvFyvK8hR(9ZkXddHNLqh0iv6CEa63LPxqcR(WkfS(Lv)(z1fqiSkJv6252Eqmk7HWkvzv0vTLMmc3sN8CJpa9lpRdHgILNbXKiarY22RjQC3RSLWjDdyzlITuESgmBjd2Zf0OylvqYb2EwdMTKeLZHv7gz1d2ayBuYkXsJvxbAAwnypxqJ1RTDZQCItbnlJHvGDJWRnbzvGGScgwpaqOaUoBPdSne25wAjHD6gWQb75cApcLZ5rcaJvXSsbRYy9hRf0vGMUUGtbnlRcES63pRUacHvzSs3o32dIrzpewPQywf9pw)YQF)S(J1Le2PBaRgSNlO9iuoNhjamwfZQOSkJ1pz1G9CbTQjA9aaHc46uHywOK1VS63pRFY6sc70nGvd2Zf0EekNZJea222Rj6Q2RSLWjDdyzlIT0b2gc7ClTKWoDdy1G9CbThHY58ibGXQywfLvzS(J1c6kqtxxWPGMLvbpw97NvxaHWQmwPBNB7bXOShcRuvmRI(hRFz1VFw)X6sc70nGvd2Zf0EekNZJeagRIzLcwLX6NSAWEUGw1OOEaGqbCDQqmluY6xw97N1pzDjHD6gWQb75cApcLZ5rcaBlLhRbZwYG9Cbnr3222sfGTxzVgf7v2s4KUbSSfXwc4TLiOTLYJ1GzlTKWoDd4wAjdc4wYd2ayBu(GalTgmSkJ1FSwaw1jHqGHvigL9qyLQSEaGqbCDQojecmSweGP1GHv)(zDjHD6gWkeDW5rstaMgwy97wQGKdS9SgmBj5RJAJvcEatjHuY6)LqiWqcR0aiREWgaBJswHalTgmS20SEfz9oxqwx9Qyfhe6qjRq0bhwbqw)VecbgY61oeyf91RHiRGHv7gz1d2rjKswTe6G2wAjHVjJWTe5s79ouEc4ZjHqGHBBVMO7v2s4KUbSSfXwc4TLiOTLYJ1GzlTKWoDd4wAjdc4wYd2ayBu(GalTgmSkJ1FSwqxbA6k5UxQcESkJvIhgcplHoOrQ058a0VltVGew9Hvrz1VFwxsyNUbScrhCEK0eGPHfw)ULki5aBpRbZws(6O2yLGhWusiLSkVcEMaejSsdGS6bBaSnkzfcS0AWWAtZ6vK17CbzD1RIvCqOdLScrhCyfazv6UxyTjSk4Xkyyv0vIFlTKW3Kr4wICP9Ehkpb8bf8mbiUT9AREVYwcN0nGLTi2saVTebTTuESgmBPLe2PBa3slzqa3sf0vGMUUGtbnlRcESkJ1FSwqxbA6k5UxQcES63pRrjXq4ljKKq65bXOShcR(W6FS(LvzSwawfk4zcqScXOShcR(WQOBPcsoW2ZAWSLKVoQnwLxbptaIewBAwLtCkOzz8s39cvezjXqiRYpHKespS2ewf8ynNcRxrwVZfKvrJNvcEatHWAaPnwbdR2nYQ8k4zcqK1)bSYwAjHVjJWTe5s79GcEMae32En5UxzlHt6gWYweBP8yny2sojecmClvqYb2EwdMTKKhE6mW6)LqiWqwZPWQ8k4zcqKvcAcES6bBaKvdWAC6ljhhHEsdz9KeBlDGTHWo3swgWXQOVKCCe6jnSIt6gWcRYy9twV2HWlai4d9LKJJqpPHSkJ1cWQojecmS6fjeS2l0iKvQkMvkyvgRhaiuaxNk6ljhhHEsdRqmk7HWkvzvuwLXkXddHNLqh0iv6CEa63LPxqcRIzLcwLXkm7YdxWXQzPqQ9WQpSksyvgRfGvDsieyyfIrzpewxpR)vxfRuLvlHoOvTocFg4vACB71w1ELTeoPBalBrSLoW2qyNBjld4yv0xsooc9KgwXjDdyHvzS(JvKMgpwVGVdiYf88a9yew9rmRhVxu67J4HtHvzSEaGqbCDQOVKCCe6jnScXOShcRuLvkyvgRfGvHcEMaeRqmk7HW66z9V6QyLQSAj0bTQ1r4ZaVsJS(DlLhRbZwck4zcqCB71ej7v2s4KUbSSfXwkpwdMTKhaeEqKaeGhClvqYb2EwdMT0)LqiWqwf8UGOxmSMbcGvd2iHvdWQabzTnwtcRjRep80zGvhCqyAaiR0aiR2nYAijgRXADz1fPbqK1Kv6EAYnc3s0a4BqFT9AuST9AI07v2s4KUbSSfXw6aBdHDULGinej3PBazvgRhqKl45b6Xi1cs3N2y1hXSsbRYy9hRErcbR9cnczLQIzLcw97NvigL9qyLQIz16ZLN1riRYyL4HHWZsOdAKkDopa97Y0liHvFeZ6Qz9lRYy9hRFY61oeEbabFOVKCCe6jnKv)(zfIrzpewPQywT(C5zDeY66zvuwLXkXddHNLqh0iv6CEa63LPxqcR(iM1vZ6xwLX6pwTe6Gw16i8zGxPrwJlRqmk7HW6xw9Hv5YQmwJsIHWxsijH0ZdIrzpewfZ6FBP8yny2sojecmCB71Kh7v2s4KUbSSfXwIgaFd6RTxJITuESgmBjpai8Gibiap422RTo3RSLWjDdyzlITuESgmBjNecbgULoW2qyNBPpzDjHD6gWk5s79ouEc4ZjHqGHSkJvisdrYD6gqwLX6be5cEEGEmsTG09Pnw9rmRuWQmw)XQxKqWAVqJqwPQywPGv)(zfIrzpewPQywT(C5zDeYQmwjEyi8Se6GgPsNZdq)Um9csy1hXSUAw)YQmw)X6NSETdHxaqWh6ljhhHEsdz1VFwHyu2dHvQkMvRpxEwhHSUEwfLvzSs8Wq4zj0bnsLoNhG(Dz6fKWQpIzD1S(LvzS(JvlHoOvTocFg4vAK14YkeJYEiS(LvFyLcrzvgRrjXq4ljKKq65bXOShcRIz9VT0HYtaFwcDqJSxJITTxJI)2RSLWjDdyzlITuESgmBPdSJiG5zyKhsST0HYtaFwcDqJSxJIT0b2gc7Clr8Wq4zj0bncR(iMvrzvgRinnESEbFhqKl45b6XiS6JywLlRYyfhe6qzfIo48oGi3EWcR(WQO)XQmw)X6NSEaGqbCDQl4uqZYkeZcLS63pRfGvHcEMaeRwFU0JdRFzvgRqmk7HWkvzvuwJN1vZ66z9hRepmeEwcDqJWQpIzvUS(DlvqYb2EwdMTuSGDebmSUcg5HeJvWWAKqWAVaYQLqh0iSMgRYnEwJ16Y61BCyfkmtpoScemw7HvrJ7QiSMewdGXH1KW6vK17CbzfhGGZnRq0bhwZPWAcX5dJvcAwpoSk4XknaYQCItbnl32EnkOyVYwcN0nGLTi2s5XAWSLGcEMae3sfKCGTN1GzljsHOhRcESkVcEMaeznnwLB8ScgwZqGvlHoOry931BCyn0l94WAamoSIdqW5M1CkSoaJvYKEKBG9DlDGTHWo3sFY6sc70nGvYL27bf8mbiYQmwrAA8y9c(oGixWZd0Jry1hXSkxwLXkePHi5oDdiRYy9hRErcbR9cnczLQIzLcw97NvigL9qyLQIz16ZLN1riRYyL4HHWZsOdAKkDopa97Y0liHvFeZ6Qz9lRYy9hRFY61oeEbabFOVKCCe6jnKv)(zfIrzpewPQywT(C5zDeY66zvuwLXkXddHNLqh0iv6CEa63LPxqcR(iM1vZ6xwLXQLqh0QwhHpd8knYACzfIrzpew9H1FSkxwJN1FScfgKgaDWAjj3948ihGWuGyOIt6gWcRRN1vX6xwJN1FScfgKgaDWAbaICdzbR4KUbSW66zDvS(L14z9hRljSt3awHOdopsAcW0WcRRNvrcRFz9722RrHO7v2s4KUbSSfXwkpwdMTeuWZeG4w6aBdHDUL(K1Le2PBaRKlT37q5jGpOGNjarwLX6NSUKWoDdyLCP9EqbptaISkJvKMgpwVGVdiYf88a9yew9rmRYLvzScrAisUt3aYQmw)XQxKqWAVqJqwPQywPGv)(zfIrzpewPQywT(C5zDeYQmwjEyi8Se6GgPsNZdq)Um9csy1hXSUAw)YQmw)X6NSETdHxaqWh6ljhhHEsdz1VFwHyu2dHvQkMvRpxEwhHSUEwfLvzSs8Wq4zj0bnsLoNhG(Dz6fKWQpIzD1S(LvzSAj0bTQ1r4ZaVsJSgxwHyu2dHvFy9hRYL14z9hRqHbPbqhSwsYDpopYbimfigQ4KUbSW66zDvS(L14z9hRqHbPbqhSwaGi3qwWkoPBalSUEwxfRFznEw)X6sc70nGvi6GZJKMamnSW66zvKW6xw)ULouEc4ZsOdAK9AuST9AuS69kBjCs3aw2IylLhRbZw6a7icyEgg5HeBlvqYb2EwdMTKipdb38CHv5heNSglyhradRRGrEiXy9AB3SA3iRKmcznaC6dRjH10fSGXWQRGXA7maypoSA3iR4Gqhkz9aMsBnyiS20SEfznH48HXQaPhhwLxbptaIBPdSne25wI4HHWZsOdAew9rmRIYQmwrAA8y9c(oGixWZd0Jry1hXSkxwLXkeJYEiSsvwfL14zD1SUEw)XkXddHNLqh0iS6JywLlRF32EnkK7ELTeoPBalBrSLYJ1GzlDGDebmpdJ8qITLki5aBpRbZwkwWoIagwxbJ8qIXkyyvAfwBAw7HvVCkyuFynNcRdMWaLSgL(Ykoi0HswZPWAtZACol4aIy9ky(WyTayncarwlzu6GSweqwnaRRicQiYK)T0b2gc7Clr8Wq4zj0bncRIzLcwLX6pw)KvOWG0aOdwlj5UhNh5aeMcedvCs3awy1VFwDfOPRqHbFxbWYJgciwvWJ1VSkJ1OKyi8Lessi98Gyu2dHvXS(hRYyfPPXJ1l47aICbppqpgHvFeZ6pwpEVO03hXdNcRXLvky9lRYyfI0qKCNUbKvzS(jRx7q4fae8H(sYXrON0qwLX6pw)K1c6kqtxj39svWJv)(zTGUc00vhOqXbFrPDURqmk7HWQpSkkRFzvgRwcDqRADe(mWR0iRXLvigL9qy1hwL722222sliK0GzVMO)jQO)T6)eDlDnHtpoKT0)w(L31(FR9FYbRSUYnYAh5bGgR0aiRFqmmd2nw(GviUoeAiwyLaIqwtbdeLgwy9CNJdsQm1YxpiRYvoynwGzbHgwyvQJIfRekhl9L1)fRgGv5tizT0lnPbdRapeMgaY6pQ8L1Fu473ktnt9)w(L31(FR9FYbRSUYnYAh5bGgR0aiRFSKttU)GviUoeAiwyLaIqwtbdeLgwy9CNJdsQm1YxpiRuihSglWSGqdlS(buyqAa0bRXXhSAaw)akmina6G14OIt6gWYhS(tuF)wzQLVEqwfjYbRXcmli0WcRFafgKgaDWAC8bRgG1pGcdsdGoynoQ4KUbS8bR)OW3VvMAM6)T8lVR9)w7)KdwzDLBK1oYdanwPbqw)WdIhqKBAFWkexhcnelSsariRPGbIsdlSEUZXbjvMA5RhKv5khSglWSGqdlS(bbieC7PuJJpy1aS(bbieC7PuJJkoPBalFW6pk89BLPw(6bzvUYbRXcmli0WcRFqacb3Ek144dwnaRFqacb3Ek14OIt6gWYhSMgRXP8e5J1Fu473ktT81dY6QKdwJfywqOHfw)akmina6G144dwnaRFafgKgaDWACuXjDdy5dw)rHVFRm1YxpiRIe5G1ybMfeAyH1pGcdsdGoyno(GvdW6hqHbPbqhSghvCs3aw(G1Fu473ktT81dYQiTCWASaZccnSW6hgSNlOvPOghFWQby9dd2Zf0Qgf144dw)jxF)wzQLVEqwfPLdwJfywqOHfw)WG9CbTQO144dwnaRFyWEUGw1eTghFW6pr99BLPw(6bzvEihSglWSGqdlS(Hb75cAvkQXXhSAaw)WG9CbTQrrno(G1FI673ktT81dYQ8qoynwGzbHgwy9dd2Zf0QIwJJpy1aS(Hb75cAvt0AC8bR)KRVFRm1m1)B5xEx7)T2)jhSY6k3iRDKhaASsdGS(rPH4X(GviUoeAiwyLaIqwtbdeLgwy9CNJdsQm1YxpiRYd5G1ybMfeAyH1piaHGBpLAC8bRgG1piaHGBpLACuXjDdy5dw)rHVFRm1YxpiRuiQCWASaZccnSW6hqHbPbqhSghFWQby9dOWG0aOdwJJkoPBalFW6pk89BLPMP(Fl)Y7A)V1(p5Gvwx5gzTJ8aqJvAaK1pofYhScX1HqdXcReqeYAkyGO0WcRN7CCqsLPw(6bzvKihSglWSGqdlSk1rXIvcLJL(Y6)IvdWQ8jKSw6LM0GHvGhctdaz9hv(Y6pr99BLPw(6bzvKwoynwGzbHgwyvQJIfRekhl9L1)fRgGv5tizT0lnPbdRapeMgaY6pQ8L1FI673ktT81dYQ8qoynwGzbHgwy9dcqi42tPghFWQby9dcqi42tPghvCs3aw(G1FI673ktT81dYkf)jhSglWSGqdlSk1rXIvcLJL(Y6)IvdWQ8jKSw6LM0GHvGhctdaz9hv(Y6pr99BLPw(6bzLcrLdwJfywqOHfwL6OyXkHYXsFz9FXQbyv(eswl9stAWWkWdHPbGS(JkFz9NO((TYulF9GSkQCLdwJfywqOHfw)WG9CbTQO144dwnaRFyWEUGw1eTghFW6pk89BLPw(6bzv0vjhSglWSGqdlS(Hb75cAvkQXXhSAaw)WG9CbTQrrno(G1Fu473ktnt9)w(L31(FR9FYbRSUYnYAh5bGgR0aiRFua2hScX1HqdXcReqeYAkyGO0WcRN7CCqsLPw(6bzLckKdwJfywqOHfw)akmina6G144dwnaRFafgKgaDWACuXjDdy5dw)jQVFRm1YxpiRuiQCWASaZccnSW6hqHbPbqhSghFWQby9dOWG0aOdwJJkoPBalFW6pr99BLPw(6bzLc5khSglWSGqdlS(buyqAa0bRXXhSAaw)akmina6G14OIt6gWYhS(JcF)wzQLVEqwPqUYbRXcmli0WcRFafg8Dfal14OIt6gWYhSAaw)WvGMUcfg8DfalV4Ok49bR)OW3VvMAM6)xKhaAyHvrAwZJ1GH1qtmsLPEl5bb0Da3sXo2Sk)essi9KwdgwLxGJaYuh7yZQilHNBwLhXWQO)jQOm1m1Xo2SgR7CCqICWuh7yZACzv(98cuY6hed2h7dwPdPdRgGvciczv(xx5JvAa8cHvdWkjxqw9GGdsi94WQ1ryLPo2XM14Y6)aMpmwLZCAYnRctajewLc9bznNcR)tFqwV2HaRHKySgaJdcz1UZHvrwsmeYQ8tijH0tLPo2XM14YQ8IH0xwf5H0bdH0AWWkvyvoXPGMLSsOCoS(RPzvoXPGMLS2ewnGJtalScOPzfazfmSMSgaJdRX6F(wzQJDSznUSkYYliRI8asUpWK2yThdHqbpJ1Ey9aICtJ1MM1RiR)FeigRLUWABSsdGSUacP1b8raHfCSktDSJnRXL1)FcYQKiKyncarwnaReHOiWWQifU0ZhewLNaKNXqpoS20SsjqG17Cbz1UrwjaHGBpLktDSJnRXL1ybMfeAScfg8DfalvAiGySAawDfOPRqHbFxbWYJgciwvWRYuh7yZACzv(lfSW6)UNc5Kqw)33OrmWGvM6yhBwJlRRCfZlyH140xsooc9KgYQby1bnwfiyH1MMvkbcFSGSkN4uqZY4sYXrON0WsLPMPo2XM140x8iyyHvxKgarwpGi30y1fD6Huzv(ph0ZiSoGjU3jmIwiWAESgmewbtGYktDESgmKQhepGi30eNEEbkFEGMagM68ynyivpiEarUPfVyQ4cmlGLhDiPelx7X5zaF7HPopwdgs1dIhqKBAXlMkrj8cwE0a4RGPDhJhepGi30Ee8aMcrmf)fttl(ZdybNCS6co2nLqzWSlpCbhRMLcP2JpuSkM68ynyivpiEarUPfVyQqhqY9bM0wmnTycqi42tP6jqmHa(qOGN1GXVFcqi42tPUacP1b8raHfCmM68ynyivpiEarUPfVyQSKWoDdymtgHIxWPGMLVtbgZsgeqXue3FqHbPbqhSweixUMHliK88s7CV(F)vL7QI)hbTNlyeivRrOOYJNC9oR)VkfF)(LPo2SUYnYAUGW0bznw)J8YAty9VQOIYQRGXAraz1aSA3iRY7A)hRtAcqKvanRXADz1bNyyvuFz1UBcRlzqazTjSc8SokdSsdGSsOCo94WAa40hM68ynyivpiEarUPfVyQSKWoDdymtgHIPdPdgcP1G5DkWywYGakMI4(dkmina6GvGlwACo46)Rkx5(LPo2S(pOHWOEqwVE3NBw)10SMdLFzLyPXQRannRgSNlOX6vK1R5ySAawtZWipJvdWkHY5W612UzvoXPGMLvM68ynyivpiEarUPfVyQSKWoDdymtgHInypxq7rOCopsayXSKbbumfX00InypxqRsr9ojpILwnhkFfpISFFAWEUGwv06DsEelTAou(kEe)(nypxqRsr9aaHc46ulcW0AW4Jyd2Zf0QIwpaqOaUo1IamTgmF973G9CbTkf1Mu7HCGcw6gW36qihti6vWL(G(9)ZG9CbTkf1Muj3zbC1bMeVNbmms2bSGtowDbh7Ms4xM68ynyivpiEarUPfVyQSKWoDdymtgHInypxq7rOCopsayXSKbbuSOX00InypxqRkA9ojpILwnhkFfpISFFAWEUGwLI6DsEelTAou(kEe)(nypxqRkA9aaHc46ulcW0AW4Jb75cAvkQhaiuaxNAraMwdMV(9BWEUGwv0AtQ9qoqblDd4BDiKJje9k4sFq)()zWEUGwv0AtQK7SaU6atI3Zaggj7awWjhRUGJDtj8ltDESgmKQhepGi30IxmvigMb7MPopwdgs1dIhqKBAXlMkKqFWxoLxPpymEq8aICt7rWdykeXuettl(tld4y1PDUnILHliSIt6gWImisdrYD6gqMAM6yhBwJtFXJGHfwXfesjRwhHSA3iR5XaqwBcR5s2H0nGvM68ynyiIV0Nlm1XMv5fjgMb7M1MMvpaH0UbK1FdG1fHWGW0nGSIdg1iH1Ey9aICt7ltDESgmK4ftfIHzWUzQZJ1GHeVyQSKWoDdymtgHIj94eWNLqh0IzjdcOyIhgcplHoOrQ058a0VltVGeQkktDSznwGi3EWcRX5GqhkzvErhCyDqSGfwnaRK0eGPHm15XAWqIxmvwsyNUbmMjJqXq0bNhjnbyAyjMLmiGIXbHouwHOdoVdiYThS4ZQxftDESgmK4ftLtgcV8ynyEHMyXmzekMyygSBSedXG9XetrmnTyIHzWUXsfcCeqM68ynyiXlMkNmeE5XAW8cnXIzYiu8PqyQJnRRRGXQ08pSk4XApT1ziqjR0aiRXsWy1aSA3iRX6ojymScrAisUz9AB3SgNZcoGiwBAwtJ1a4kRfbyAnyyQZJ1GHeVyQqc9bF5uEL(GX00I)0vGMUsc9bF5uEL(GvbpzhqKl45b6Xi(iMcM68ynyiXlMk4SGdikMMwSRanDLe6d(YP8k9bRcEYCfOPRKqFWxoLxPpyfIrzpeQUkzhqKl45b6Xi(iwUm15XAWqIxmvozi8YJ1G5fAIfZKrO4cWyQZJ1GHeVyQCYq4LhRbZl0elMjJqXLgIhJPopwdgs8IPscp5GpdaH4yX00IXbHouwliDFAZhXuSQ4XbHouwHOdoVdiYThSWuNhRbdjEXujHNCWNNqGGm15XAWqIxmvcTZTrE)Fekor4ym15XAWqIxmvCtNhG(zW(CHWuZuh7yZASaGqbCDim1XM1)hnRzPqynHiRcEXWkzApKv7gzfmiRxB7M1a4ksmwxzL)PY6)pbz96noSwOShhwPtIHqwT7CynwRlRfKUpTXkaY612UbcgR5qjRXADRm15XAWqQNcrCucVGLhna(kyA3Xe6bFNIykQRkMdLNa(Se6GgrmfX00IHzxE4cownlfsvWt2VpxsyNUbSs6XjGplHoO53VLqh0QwhHpd8kns1v)3xz)Se6Gw16i8zGxPrQEarUGNhOhJuliDFAB9uuxLF)hqKl45b6Xi1cs3N28r8X7fL((iE4u(YuhBw)F0SoawZsHW61oeyT0iRxB7UhwTBK1b91yD1)rIHvbcYQiJ(FyLgaznk9L1yTUvwLFZWipJvdWkHY5W612UzvKhshmesRbdRnnREacPDdyLPopwdgs9uiXlMkrj8cwE0a4RGPDhttlgMD5Hl4y1Sui1E8z1)fxy2LhUGJvZsHulcW0AWi7aICbppqpgPwq6(0MpIpEVO03hXdNISppaqOaUovYDVuHywOu2VppGfCYXQl4y3uc97VGUc00v6q6GHqAnyQcE(9FaGqbCDQ0H0bdH0AWuHyu2dXhkw1xM6yZQeLZHv5eNcAwY61EkGRSETTBwxRDUnILHlim(40xsooc9KgYAtZA65f6t6gqM68ynyi1tHeVyQSKWoDdymtgHIxWPGMLVPDUnILHli8DatPTgmXSKbbu8NwgWXQt7CBeldxqyfN0nGf)()0Yaowf9LKJJqpPHvCs3aw87)aaHc46urFj54i0tAyfIrzpeQUQ4k66TmGJvli6HWhXGPLoyufN0nGfM6yZ6)oBJvWWQCItbnlzLgaz9)sieyiRxB7MvrM8hdRctajewVISMqK10ynk9L1yTUSsdGSkYdPdgcP1GHPopwdgs9uiXlMkljSt3agZKrO4fCkOz5lkFhWuARbtmlzqaf)PLbCSAusme(scjjKEQ4KUbS43FbyvNecbgwT(CPhh)(pGfCYXQl4y3ucLDarUGNhOhJuliDFAt8Fm1XMvjkNdRYjof0SK1RTDZQipKoyiKwdgwZPWQe6rAcRjH1ayCynjSEfz9ky(WynaiiRjRNKyScwqiR2nYkD7CBSweGP1GHPopwdgs9uiXlMkljSt3agZKrO4fCkOz57awWjh7DatPTgmX00IpGfCYXQxOe2543)bSGtowDWdeeaWIF)hWco5y1bmymlzqaftbtDESgmK6PqIxmvwsyNUbmMjJqXl4uqZY3bSGto27aMsBnyIPPfFal4KJvxWXUPegZsgeqX0baa(7hD7CBpigL9qIRO)99F9Jcr)B9ljSt3awxWPGMLVtb(9Rp0baa(7hD7CBpigL9qIRO)f3daekGRtLoKoyiKwdMkeJYEiF)x)Oq0)w)sc70nG1fCkOz57uGF)63VRanDLoKoyiKwdMNRanDvWZV)c6kqtxPdPdgcP1GPk453VlGqKr3o32dIrzpeQk6Fm15XAWqQNcjEXuzjHD6gWyMmcfVGtbnlFhWco5yVdykT1GjMMw8bSGtowDANB7rNymlzqafthaa4VF0TZT9Gyu2djUI(33)1pke9V1VKWoDdyDbNcAw(of43V(qhaa4VF0TZT9Gyu2djUI(xCpaqOaUovc6rAsfIrzpKV)RFui6FRFjHD6gW6cof0S8DkWVF97VaSkb9inPA95spo(97ciez0TZT9Gyu2dHQI(htDSzvKhqY9bM0gR0aiRRRaXeciRXjuWZAWWAtZ6amwjgMb7glScGS2dRjRhaiuaxhwpuEcitDESgmK6PqIxmvOdi5(atAlMMw8pcqi42tP6jqmHa(qOGN1GXVFcqi42tPUacP1b8raHfCSVY(KyygSBSuZqq2Nf0vGMUUGtbnlRcEYIsIHWxsijH0ZdIrzpeX)j7hoi0HYQ1r4ZaVO033be52dw8ru)()SGUc00vYDVuf8(gtpgcHcE2RJIWsNgkMIy6XqiuWZEobGBgetrm9yiek4zVMwmbieC7PuxaH06a(iGWcogtDSzvIY5WQipKoyiKwdgwV22nRYjof0SK1KWAamoSMewVISEfmFySgaeK1K1tsmwbliKv7gzLUDUnwlcW0AWW6paK1MMv5eNcAwY61oey9aIqwDZZfwtNShQ0ewnGJtalScOP)wzQZJ1GHupfs8IPcDiDWqiTgmX00I)KyygSBSuHahbu2VdaekGRtDbNcAwwHyu2dHQRw2sc70nG1fCkOz5lkFhWuARbJmKMgpwVGVdiYf88a9yeFelxzwcDqRADe(mWR0Opu8NF)f0vGMUUGtbnlRcE(97ciez0TZT9Gyu2dHQIk3Vm15XAWqQNcjEXuHoKoyiKwdMyAAXFsmmd2nwQqGJakdPPXJ1l47aICbppqpgXhXYv2p6aaa)9JUDUTheJYEiXvu5(9F97aaHc46S(Le2PBaR0H0bdH0AW8of43V(qhaa4VF0TZT9Gyu2djUIk34EaGqbCDQl4uqZYkeJYEiRFjHD6gW6cof0S8DkWV)RFhaiuaxN1VKWoDdyLoKoyiKwdM3Pa)(9ltDSzvIY5WQe6rAcRxB7Mv5eNcAwYAsynaghwtcRxrwVcMpmwdacYAY6jjgRGfeYQDJSs3o3gRfbyAnyIHvxbJvpisJqwTe6GgHv7onwV2HaRHEbznnwdysmwP4pctDESgmK6PqIxmviOhPjX00I)KyygSBSuHahbuwbyvNecbgwT(CPhhz)oaqOaUo1fCkOzzfIrzpeQsHmlHoOvTocFg4vA0hk(ZV)c6kqtxxWPGMLvbp)(DbeIm6252Eqmk7Hqvk(7ltDESgmK6PqIxmviOhPjX00I)KyygSBSuHahbu2p6aaa)9JUDUTheJYEiXLI)((VoaqOaUoF9HoaaWF)OBNB7bXOShsCP4V4EaGqbCDQl4uqZYkeJYEiRFjHD6gW6cof0S8DkWV)RdaekGRZ3Vm15XAWqQNcjEXuzbNcAwgttl(tIHzWUXsfcCeqzfGvHcEMaeRwFU0JJSplORanDDbNcAwwf8KTKWoDdyDbNcAw(M252iwgUGW3bmL2AWiBjHD6gW6cof0S8fLVdykT1Gr2sc70nG1fCkOz57awWjh7DatPTgmm1XM140xsooc9KgY61BCyDagRedZGDJfwZPWQlWUzvEf8mbiYAofw)VecbgYAcrwf8yLgaznaghwXbi4CxzQZJ1GHupfs8IPc6ljhhHEsdJPPf)jXWmy3yPcbocOSFFwaw1jHqGHvisdrYD6gqzfGvHcEMaeRqmk7H4JCJxUR)49IsFFepCk(9xawfk4zcqScXOShY6)RUkFSe6Gw16i8zGxPXVYSe6Gw16i8zGxPrFKltDSzv6UxyTPz9FaRqynHiRcE)FzTPzDT252yvKNiRPzyKNXQbyLq5Cy9AB3SkHEKMWkaYQCItbnlzTPz9kY6vW8HX61KyiRraiYQDNdR3zGMvP7E5dcRhaiuaxhM68ynyi1tHeVyQqU7LyAAXFwqxbA6k5UxQcEY(vaw1jHqGHvRpx6XrwbyvOGNjaXQ1Nl948v2VppGfCYXQt7CBp6e97)3VdaekGRtLGEKMuHywO0V)daekGRtLGEKMuHyu2dXhke9B8)oaqOaUo1fCkOzzfIzHs)(paqOaUo1fCkOzzfIrzpK1VKWoDdyDbNcAw(ofOpui6xXI(9ltDESgmK6PqIxmv8awdMyAAXUc00v3aaucceRcX8y(97ciez0TZT9Gyu2dHQR(p)(lORanDDbNcAwwf8yQZJ1GHupfs8IPIBaakpAbiLX00IlORanDDbNcAwwf8yQZJ1GHupfs8IPIlcji8spoX00IlORanDDbNcAwwf8yQZJ1GHupfs8IPcDdr3aauIPPfxqxbA66cof0SSk4XuNhRbdPEkK4ftLCoiXGz4DYqiMMwCbDfOPRl4uqZYQGhtDESgmK6PqIxmvozi8YJ1G5fAIfZKrO4LCAYDmnT4pjgMb7gl1meKfLedHVKqscPNheJYEiI)JPopwdgs9uiXlMkce81ggfZKrO4R9uiNe(UEJgXadgttlM4HHWZsOdAKkDopa97Y0liXNcsAiwEwcDqJ43pm7YdxWXQzPqQ94Ji5p)(DbeIm6252Eqmk7HqvrAM68ynyi1tHeVyQiqWxByumtgHIp55gFa6xEwhcnelpdIjraIKyAAXUc0018SoeAiwEPVyvWt2pIhgcplHoOrQ058a0VltVGeXuidMD5Hl4y1Sui1E8rK8NF)epmeEwcDqJuPZ5bOFxMEbj(qXx)(DbeIm6252Eqmk7HqvrxftDSzvIY5WQDJS6bBaSnkzLyPXQRannRgSNlOX612UzvoXPGMLXWkWUr41MGSkqqwbdRhaiuaxhM68ynyi1tHeVyQyWEUGgfX00IxsyNUbSAWEUG2Jq5CEKaWetHSFf0vGMUUGtbnlRcE(97ciez0TZT9Gyu2dHQIf9VV(9)BjHD6gWQb75cApcLZ5rcatSOY(0G9CbTQO1daekGRtfIzHYV(9)5sc70nGvd2Zf0EekNZJeagtDESgmK6PqIxmvmypxqt0yAAXljSt3awnypxq7rOCopsayIfv2Vc6kqtxxWPGMLvbp)(DbeIm6252Eqmk7HqvXI(3x)()TKWoDdy1G9CbThHY58ibGjMczFAWEUGwLI6bacfW1PcXSq5x)()CjHD6gWQb75cApcLZ5rcaJPMPo2XM1)PH4XyTKrPdYA62H2AKWuhBwJZzbhqeRPXQCJN1FRkEwV22nR)J0xwJ16wz9)ffHLonmqjRGHvrJNvlHoOrIH1RTDZQCItbnlJHvaK1RTDZ6kI4)lRa7gHxBcY61SnwPbqwjGiKvCqOdLvwL)abW61SnwBAwJtFjoSEarUawBcRhqupoSk4vzQZJ1GHulnepMyCwWbefttlgPPXJ1l47aICbppqpgXhXYnEld4y1cIEi8rmyAPdgvXjDdyr2Vc6kqtxxWPGMLvbp)(lORanDLC3lvbp)(lORanDLoKoyiKwdMQGNF)4GqhkRfKUpTrvXIUQ4XbHouwHOdoVdiYThS43)NljSt3awj94eWNLqh087hPPXJ1l47aICbppqpgXNJ3lk99r8WP8v2VpTmGJvrFj54i0tAyfN0nGf)(paqOaUov0xsooc9KgwHyu2dXhr)YuNhRbdPwAiES4ftLLe2PBaJzYiuSabF0DiGWywYGak(aICbppqpgPwq6(0Mpu43poi0HYAbP7tBuvSORkECqOdLvi6GZ7aIC7bl(9)5sc70nGvspob8zj0bnM6yZQ875fOKvjriXQbyndbwTe6GgH1RTDdemwtwlORannRjHvpydGTrzmS6brAec7XHvlHoOryTqzpoSsaGbHSM0gcz1Urw9GDucPKvlHoOXuNhRbdPwAiES4ftfccHPHLNlyWhXRVGX00IxsyNUbSkqWhDhciu2NfGvjieMgwEUGbFeV(c(kaRA95spom15XAWqQLgIhlEXuHGqyAy55cg8r86lymhkpb8zj0bnIykIPPfVKWoDdyvGGp6oeqOSplaRsqimnS8Cbd(iE9f8vaw16ZLECyQJnRIui6XkneeX6j986XH1ZDcDqcRaiRUcWH10y1UrwXPWkGMv6252im15XAWqQLgIhlEXuHGqyAy55cg8r86lymnT4Le2PBaRce8r3HacLfLedHVKqscPNheJYEiu9VQ8q2pxaHiJUDUTheJYEiuv8Q87)aaHc46ujieMgwEUGbFeV(cwJsFFN7e6GK4EUtOdsE0W8ynyYavf)xv0v9LPo2S(VVXHvrM8ZAtyDagRPX6D7CZAraMwdMyyLq5Cy9AB3SwYO0bz1vGMMW612UbcgRGfeEf2wpoSkFywy1LswJtFZiVaYuNhRbdPwAiES4ftfccHPHLNlyWhXRVGX00I)KG2ZfmcKQ1iuu5XtuVJSLe2PBaRce8r3HacLfLedHVKqscPNheJYEiu9VQ8q2pcqi42tPgWS8CP8H(MrEbSIt6gWISpDfOPRbmlpxkFOVzKxaRcEYkORanDDbNcAwwf8873vGMUgLqi4kwEoyeXad(W5oNdgHJvf887)ZLe2PBaRKECc4ZsOdAYkORanDLC3lvbVVm15XAWqQLgIhlEXuHGqyAy55cg8r86lymnTycApxWiqQwJqrLhpr9oYwsyNUbSkqWhDhciuwusme(scjjKEEqmk7Hq1)QYdzf0vGMU6afko4lkTZDvWt2NUc001aMLNlLp03mYlGvbpzWSlpCbhRMLcP2JpRIPo2S()tqwLeHeRgGvIqueyyvKcx65dcRYtaYZyOhhwBAwPeiW6DUGSA3iReGqWTNsLPopwdgsT0q8yXlMkeectdlpxWGpIxFbJj0d(ofXuSQyAAXeGqWTNs9cU0d5baYZyOhhzUc001l4spKhaipJHECQfW1HPo2SkYZHvanRIutVGewtJvkwNXZkXYZfcRaAwLNQlfCyveHSGewbqwtNShIXQCJNvlHoOrQm15XAWqQLgIhlEXuHoNhG(Dz6fKettlEjHD6gWQabF0DiGqz)CfOPR3DPGZZnKfKujwEU4JykwN(9)7tpydGTr5dcS0AWiJ4HHWZsOdAKkDopa97Y0liXhXYnEIHzWUXsfcCeWVFzQJnRI8CyfqZQi10liHvdWA65fOKvpqtadH1MM1EYJ1liRGH1COKvlHoOX6paK1COKv3aILECy1sOdAewV22nREWgaBJswHalTgmFznnwx9km15XAWqQLgIhlEXuHoNhG(Dz6fKettlopwVGVcWQfmlbkFEGMaMxbyunpwVGpCWOgjY(9PhSbW2O8bbwAny87VaSQtcHadRwFU0JJF)fGvHcEMaeRwFU0JZxzljSt3awfi4JUdbekJ4HHWZsOdAKkDopa97Y0liXhXRMPopwdgsT0q8yXlMk45g0JZdIEWokNsmnT4Le2PBaRce8r3HacLDaGqbCDQl4uqZYkeJYEi(qXFm15XAWqQLgIhlEXujJCfi3X00IxsyNUbSkqWhDhciu2VOKyi8Lessi98Gyu2dr8FY(ekmina6G1cae5gYc63VRanD1n0tH0fSk49LPo2SUs6gxrMG1H0qwnaRPNxGsw)hmlbkzDDbnbmSMgRIYQLqh0im15XAWqQLgIhlEXujsW6qAymhkpb8zj0bnIykIPPfVKWoDdyvGGp6oeqOmIhgcplHoOrQ058a0VltVGeXIYuNhRbdPwAiES4ftLibRdPHX00IxsyNUbSkqWhDhciKPMPo2XM1)jJshKvWccz16iK10TdT1iHPo2SkFDuBSsWdykjKsw)VecbgsyLgaz1d2ayBuYkeyP1GH1MM1RiR35cY6QxfR4GqhkzfIo4WkaY6)LqiWqwV2HaROVEnezfmSA3iREWokHuYQLqh0yQZJ1GHulat8sc70nGXmzekMCP9Ehkpb85KqiWWywYGak2d2ayBu(GalTgmY(vaw1jHqGHvigL9qO6bacfW1P6KqiWWAraMwdg)(xsyNUbScrhCEK0eGPHLVm1XMv5RJAJvcEatjHuYQ8k4zcqKWknaYQhSbW2OKviWsRbdRnnRxrwVZfK1vVkwXbHouYkeDWHvaKvP7EH1MWQGhRGHvrxjEM68ynyi1cWIxmvwsyNUbmMjJqXKlT37q5jGpOGNjaXywYGak2d2ayBu(GalTgmY(vqxbA6k5UxQcEYiEyi8Se6GgPsNZdq)Um9cs8ru)(xsyNUbScrhCEK0eGPHLVm1XMv5RJAJv5vWZeGiH1MMv5eNcAwgV0DVqfrwsmeYQ8tijH0dRnHvbpwZPW6vK17Cbzv04zLGhWuiSgqAJvWWQDJSkVcEMaez9FaRWuNhRbdPwaw8IPYsc70nGXmzekMCP9EqbptaIXSKbbuCbDfOPRl4uqZYQGNSFf0vGMUsU7LQGNF)rjXq4ljKKq65bXOShIp)9vwbyvOGNjaXkeJYEi(iktDSzvYdpDgy9)sieyiR5uyvEf8mbiYkbnbpw9GnaYQbyno9LKJJqpPHSEsIXuNhRbdPwaw8IPItcHadJPPfBzahRI(sYXrON0WkoPBalY(8AhcVaGGp0xsooc9KgkRaSQtcHadRErcbR9cncPQykKDaGqbCDQOVKCCe6jnScXOShcvfvgXddHNLqh0iv6CEa63LPxqIykKbZU8WfCSAwkKAp(isKvaw1jHqGHvigL9qw)F1vrvlHoOvTocFg4vAKPopwdgsTaS4ftfOGNjaXyAAXwgWXQOVKCCe6jnSIt6gWISFinnESEbFhqKl45b6Xi(i(49IsFFepCkYoaqOaUov0xsooc9KgwHyu2dHQuiRaSkuWZeGyfIrzpK1)xDvu1sOdAvRJWNbELg)YuhBw)VecbgYQG3fe9IH1mqaSAWgjSAawfiiRTXAsynzL4HNodS6GdctdazLgaz1UrwdjXynwRlRUinaISMSs3ttUritDESgmKAbyXlMkEaq4brcqaEWyObW3G(AIPGPopwdgsTaS4ftfNecbggttlgI0qKCNUbu2be5cEEGEmsTG09PnFetHSFErcbR9cncPQyk87hIrzpeQk26ZLN1rOmIhgcplHoOrQ058a0VltVGeFeV6VY(951oeEbabFOVKCCe6jn0VFigL9qOQyRpxEwhHRxuzepmeEwcDqJuPZ5bOFxMEbj(iE1FL9ZsOdAvRJWNbELgJleJYEiF9rUYIsIHWxsijH0ZdIrzpeX)XuNhRbdPwaw8IPIhaeEqKaeGhmgAa8nOVMykyQZJ1GHulalEXuXjHqGHXCO8eWNLqh0iIPiMMw8NljSt3awjxAV3HYtaFojecmugePHi5oDdOSdiYf88a9yKAbP7tB(iMcz)8Iecw7fAesvXu43peJYEiuvS1NlpRJqzepmeEwcDqJuPZ5bOFxMEbj(iE1FL97ZRDi8cac(qFj54i0tAOF)qmk7HqvXwFU8SocxVOYiEyi8Se6GgPsNZdq)Um9cs8r8Q)k7NLqh0QwhHpd8kngxigL9q(6dfIklkjgcFjHKesppigL9qe)htDSznwWoIagwxbJ8qIXkyynsiyTxaz1sOdAewtJv5gpRXADz96noScfMPhhwbcgR9WQOXDvewtcRbW4WAsy9kY6DUGSIdqW5Mvi6GdR5uynH48HXkbnRhhwf8yLgazvoXPGMLm15XAWqQfGfVyQCGDebmpdJ8qIfZHYtaFwcDqJiMIyAAXepmeEwcDqJ4JyrLH004X6f8DarUGNhOhJ4Jy5kdhe6qzfIo48oGi3EWIpI(NSFFEaGqbCDQl4uqZYkeZcL(9xawfk4zcqSA95spoFLbXOShcvfn(vV(FepmeEwcDqJ4Jy5(LPo2SksHOhRcESkVcEMaeznnwLB8ScgwZqGvlHoOry931BCyn0l94WAamoSIdqW5M1CkSoaJvYKEKBG9LPopwdgsTaS4ftfOGNjaXyAAXFUKWoDdyLCP9EqbptaIYqAA8y9c(oGixWZd0Jr8rSCLbrAisUt3ak7NxKqWAVqJqQkMc)(Hyu2dHQIT(C5zDekJ4HHWZsOdAKkDopa97Y0liXhXR(RSFFETdHxaqWh6ljhhHEsd97hIrzpeQk26ZLN1r46fvgXddHNLqh0iv6CEa63LPxqIpIx9xzwcDqRADe(mWR0yCHyu2dXNFYn(FqHbPbqhSwsYDpopYbimfigw)Q(g)pOWG0aOdwlaqKBil46x134)TKWoDdyfIo48iPjatdlRxK89ltDESgmKAbyXlMkqbptaIXCO8eWNLqh0iIPiMMw8NljSt3awjxAV3HYtaFqbptaIY(CjHD6gWk5s79GcEMaeLH004X6f8DarUGNhOhJ4Jy5kdI0qKCNUbu2pViHG1EHgHuvmf(9dXOShcvfB95YZ6iugXddHNLqh0iv6CEa63LPxqIpIx9xz)(8AhcVaGGp0xsooc9Kg63peJYEiuvS1NlpRJW1lQmIhgcplHoOrQ058a0VltVGeFeV6VYSe6Gw16i8zGxPX4cXOShIp)KB8)GcdsdGoyTKK7ECEKdqykqmS(v9n(FqHbPbqhSwaGi3qwW1VQVX)BjHD6gWkeDW5rstaMgwwVi57xM6yZQipdb38CHv5heNSglyhradRRGrEiXy9AB3SA3iRKmcznaC6dRjH10fSGXWQRGXA7maypoSA3iR4Gqhkz9aMsBnyiS20SEfznH48HXQaPhhwLxbptaIm15XAWqQfGfVyQCGDebmpdJ8qIfttlM4HHWZsOdAeFelQmKMgpwVGVdiYf88a9yeFelxzqmk7HqvrJF1R)hXddHNLqh0i(iwUFzQJnRXc2reWW6kyKhsmwbdRsRWAtZApS6LtbJ6dR5uyDWegOK1O0xwXbHouYAofwBAwJZzbhqeRxbZhgRfaRraiYAjJshK1IaYQbyDfrqfrM8ZuNhRbdPwaw8IPYb2reW8mmYdjwmnTyIhgcplHoOretHSFFcfgKgaDWAjj3948ihGWuGyWVFOWGVRayPsdbeRIt6gWYxzrjXq4ljKKq65bXOShI4)KH004X6f8DarUGNhOhJ4J4FhVxu67J4HtjUu8vgePHi5oDdOSpV2HWlai4d9LKJJqpPHY(9zbDfOPRK7EPk453FbDfOPRoqHId(Is7CxHyu2dXhr)kZsOdAvRJWNbELgJleJYEi(ixMAM6yhBwLmmd2nwyv(pwdgctDSzDT25Myz4cczfmSU6vKdwJfSJiGH1vWipKym15XAWqQedZGDJfXhyhraZZWipKyX00ITmGJvN252iwgUGWkoPBalYiEyi8Se6GgXhXRw2be5cEEGEmIpILRmlHoOvTocFg4vAmUqmk7H4JiHPo2SUw7CtSmCbHScgwPyf5GvPj9i3aJv5vWZeGitDESgmKkXWmy3yjEXubk4zcqmMMwSLbCS60o3gXYWfewXjDdyr2be5cEEGEmIpILRmlHoOvTocFg4vAmUqmk7H4JiHPo2Skj4AiKwWbLdwLFpVaLScGSkVinej3SETTBwDfOPXcR)xcHadjm15XAWqQedZGDJL4ftfpai8Gibiapym0a4BqFnXuWuNhRbdPsmmd2nwIxmvCsieyymhkpb8zj0bnIykIPPfBzahRseCnesl4GvCs3awK951oeEbabFOVKCCe6jnu2pigL9qOkfI(VqFj54i0tAy5btd973lsiyTxOrivftXxzwcDqRADe(mWR0yCHyu2dXhrzQJnRscUgcPfCqwJN140xIdRGHvkwroyvErAisUz9)sieyiRPXQDJSItHvanRedZGDZQby1bnwJsFzTiatRbdRUinaISgN(sYXrON0qM68ynyivIHzWUXs8IPIhaeEqKaeGhmgAa8nOVMykyQZJ1GHujgMb7glXlMkojecmmMMwSLbCSkrW1qiTGdwXjDdyrMLbCSk6ljhhHEsdR4KUbSilpwVGpCWOgjIPqMRanDLi4AiKwWbRqmk7HqvkQRMPMPo2XMv5mNMCZuhBwf590KBwV22nRrPVSgR1LvAaK11ANBJyz4ccJHvHjGecRcKECy9FW0UduYQ0Dwaxjm15XAWqQl50KBXljSt3agZKrO4PDUnILHli8D8EhWuARbtmlzqaf)7tOWG0aOdwlyA3bkFK7SaUsKH004X6f8DarUGNhOhJ4J4J3lk99r8WP81V)FqHbPbqhSwW0Udu(i3zbCLi7aICbppqpgHQI(LPo2SkN50KBwV22nRXPVehwJN11ANBJyz4ccLdwfzPVDKqeRXADznNcRXPVehwHywOKvAaK1b91y9)I1)WuNhRbdPUKttUJxmvwYPj3X00ITmGJvrFj54i0tAyfN0nGfzwgWXQt7CBeldxqyfN0nGfzljSt3awN252iwgUGW3X7DatPTgmYoaqOaUov0xsooc9KgwHyu2dHQuWuhBwLZCAYnRxB7M11ANBJyz4ccznEwxdWAC6lXroyvKL(2rcrSgR1L1CkSkN4uqZswf8yQZJ1GHuxYPj3XlMkl50K7yAAXwgWXQt7CBeldxqyfN0nGfzFAzahRI(sYXrON0WkoPBalYwsyNUbSoTZTrSmCbHVJ37aMsBnyKvqxbA66cof0SSk4XuNhRbdPUKttUJxmv8aGWdIeGa8GXqdGVb91etrmOVgmFzeqymXYDvm15XAWqQl50K74ftLLCAYDmnTyld4yvIGRHqAbhSIt6gWISdaekGRt1jHqGHvbpzf0vGMUUGtbnlRcEY(vaw1jHqGHvisdrYD6gq)(laR6KqiWWQxKqWAVqJqQkMIVYoGixWZd0JrQfKUpT5J4FepmeEwcDqJuPZ5bOFxMEbj(ipTC)kdMD5Hl4y1Sui1E8HcrzQJnRYzon5M1RTDZQiljgczv(jKK0JCWQ8k4zcqm()lHqGHSoaJ1EyfI0qKCZkmhhmgwlcWECyvoXPGMLXlD3lvwLOCoSETTBwLqpstyLUNmW6DBS20S6biK2nGvM68ynyi1LCAYD8IPYson5oMMw8pld4y1OKyi8Lessi9uXjDdyXVFOWG0aOdwJs4LhG(z34lkjgcFjHKespFL9zbyvOGNjaXkePHi5oDdOScWQojecmScXOShIpRwwbDfOPRl4uqZYQGNSFf0vGMUsU7LQGNF)f0vGMUUGtbnlRqmk7Hqv563Fbyvc6rAs16ZLEC(kRaSkb9inPcXOShcvx9wI4HN9AIUQ15222Ed]] )


end
