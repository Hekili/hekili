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

    spec:RegisterStateExpr( "effective_combo_points", function ()
        local c = combo_points.current or 0
        if not covenant.kyrian then return c end
        if c < 2 or c > 5 then return c end
        if buff[ "echoing_reprimand_" .. c ].up then return 7 end
        return c
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
        return ( GetPlayerAuraBySpellID( 1784 ) or GetPlayerAuraBySpellID( 115191 ) or GetPlayerAuraBySpellID( 115192 ) or GetPlayerAuraBySpellID( 11327 ) or GetTime() - stealth_dropped < 0.2 )
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
    Hekili.TB = tracked_bleeds

    local function NewBleed( key, spellID )
        tracked_bleeds[ key ] = {
            id = spellID,
            exsanguinate = {},
            vendetta = {},
            rate = {},
            last_tick = {},
            haste = {}
        }

        tracked_bleeds[ spellID ] = tracked_bleeds[ key ]
    end

    local function ApplyBleed( key, target, exsanguinate, vendetta )
        local bleed = tracked_bleeds[ key ]

        bleed.rate[ target ]         = 1 + ( exsanguinate and 1 or 0 ) + ( vendetta and 1 or 0 )
        bleed.last_tick[ target ]    = GetTime()
        bleed.exsanguinate[ target ] = exsanguinate
        bleed.vendetta[ target ]     = vendetta
        bleed.haste[ target ]        = 100 + GetHaste()
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

        bleed.haste[ target ] = 100 + GetHaste()
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
        bleed.haste[ target ]        = nil
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

            if tracked_bleeds[ spellID ] then
                if tick_events[ subtype ] then
                    UpdateBleedTick( spellID, destGUID, GetTime() )
                    return
                elseif removal_events[ subtype ] then
                    RemoveBleed( spellID, destGUID )
                    return
                end
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
    end, false )


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
        if this_action == "marked_for_death" then
            if cycle_enemies == 1 or active_dot.marked_for_death >= cycle_enemies then return end -- As far as we can tell, MfD is on everything we care about, so we don't cycle.
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

        if resource == "combo_points" and buff.flagellation_buff.up then
            if legendary.obedience.enabled then
                reduceCooldown( "flagellation", amt )
            end

            if debuff.flagellation.up then
                stat.mod_haste_pct = stat.mod_haste_pct + amt
            end
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
        return aura.exsanguinated_rate > ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 2 or 1 )
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
            duration = function () return ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ) * ( 2 * ( 1 + effective_combo_points ) ) end,
            max_stack = 1,
            meta = {
                exsanguinated = function( t ) return t.up and tracked_bleeds.crimson_tempest.exsanguinate[ target.unit ] or false end,
                vendetta_exsg = function( t ) return t.up and tracked_bleeds.crimson_tempest.vendetta[ target.unit ] or false end,
                exsanguinated_rate = function( t ) return t.up and tracked_bleeds.crimson_tempest.rate[ target.unit ] or 1 end,
                last_tick = function( t ) return t.up and ( tracked_bleeds.crimson_tempest.last_tick[ target.unit ] or t.applied ) or 0 end,
                tick_time = function( t )
                    if t.down then return haste * 2 end
                    local hasteMod = tracked_bleeds.crimson_tempest.haste[ target.unit ]
                    hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                    return hasteMod / t.exsanguinated_rate
                end,
                haste_pct = function( t ) return ( 100 / haste ) end,
                haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.crimson_tempest.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
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
                tick_time = function( t )
                    if t.down then return haste * 2 end
                    local hasteMod = tracked_bleeds.deadly_poison_dot.haste[ target.unit ]
                    hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                    return hasteMod / t.exsanguinated_rate
                end,
                haste_pct = function( t ) return ( 100 / haste ) end,
                haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.deadly_poison_dot.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
            },
        },
        elaborate_planning = {
            id = 193641,
            duration = 4,
            max_stack = 1,
        },
        envenom = {
            id = 32645,
            duration = function () return ( 1 + effective_combo_points ) end,
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
                tick_time = function( t )
                    if t.down then return haste * 2 end
                    local hasteMod = tracked_bleeds.garrote.haste[ target.unit ]
                    hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                    return hasteMod / t.exsanguinated_rate
                end,
                haste_pct = function( t ) return ( 100 / haste ) end,
                haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.garrote.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
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
                tick_time = function( t )
                    if t.down then return haste * 2 end
                    local hasteMod = tracked_bleeds.internal_bleeding.haste[ target.unit ]
                    hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                    return hasteMod / t.exsanguinated_rate
                end,
                haste_pct = function( t ) return ( 100 / haste ) end,
                haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.internal_bleeding.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
            },
        },
        iron_wire = {
            id = 256148,
            duration = 8,
            max_stack = 1,
        },
        kidney_shot = {
            id = 408,
            duration = function () return ( 1 + effective_combo_points ) end,
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
            duration = function () return ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ) * 4 * ( 1 + effective_combo_points ) end,
            tick_time = function () return ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ) * ( debuff.rupture.exsanguinated and haste or ( 2 * haste ) ) end,
            max_stack = 1,
            meta = {
                exsanguinated = function( t ) return t.up and tracked_bleeds.rupture.exsanguinate[ target.unit ] or false end,
                vendetta_exsg = function( t ) return t.up and tracked_bleeds.rupture.vendetta[ target.unit ] or false end,
                exsanguinated_rate = function( t ) return t.up and tracked_bleeds.rupture.rate[ target.unit ] or 1 end,
                last_tick = function( t ) return t.up and ( tracked_bleeds.rupture.last_tick[ target.unit ] or t.applied ) or 0 end,
                tick_time = function( t )
                    if t.down then return haste * 2 end
                    local hasteMod = tracked_bleeds.rupture.haste[ target.unit ]
                    hasteMod = 2 * ( hasteMod and ( 100 / hasteMod ) or haste )
                    return hasteMod / t.exsanguinated_rate
                end,
                haste_pct = function( t ) return ( 100 / haste ) end,
                haste_pct_next_tick = function( t ) return t.up and ( tracked_bleeds.rupture.haste[ target.unit ] or ( 100 / haste ) ) or 0 end,
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
            duration = function () return 6 * ( 1 + effective_combo_points ) end,
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
                applyDebuff( "target", "crimson_tempest", 2 + ( effective_combo_points * 2 ) )
                debuff.crimson_tempest.pmultiplier = persistent_multiplier
                debuff.crimson_tempest.exsanguinated_rate = 1
                debuff.crimson_tempest.exsanguinated = false

                if set_bonus.tier28_4pc > 0 and debuff.vendetta.up then
                    debuff.crimson_tempest.exsanguinated_rate = 2
                    debuff.crimson_tempest.vendetta_exsg = true
                end

                removeBuff( "echoing_reprimand_" .. combo_points.current )
                spend( combo_points.current, "combo_points" )

                if talent.elaborate_planning.enabled then applyBuff( "elaborate_planning" ) end
            end,
        },


        crimson_vial = {
            id = 185311,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return 20 + conduit.nimble_fingers.mod end,
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

                applyBuff( "envenom", 1 + effective_combo_points )
                removeBuff( "echoing_reprimand_" .. combo_points.current )
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
                local rate

                for i, aura in ipairs( true_exsanguinated ) do
                    local deb = debuff[ aura ]

                    if deb.up and not deb.exsanguinated then
                        deb.exsanguinated = true

                        rate = deb.exsanguinated_rate
                        deb.exsanguinated_rate = deb.exsanguinated_rate + 1

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

            spend = function () return 35 + conduit.nimble_fingers.mod end,
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
               	if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end
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
                applyDebuff( "target", "rupture", ( 4 + ( 4 * effective_combo_points ) ) * ( set_bonus.tier28_4pc > 0 and debuff.vendetta.up and 0.5 or 1 ), nil, nil, true )
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

                removeBuff( "echoing_reprimand_" .. combo_points.current )
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
                            bleed.expires = query_time + rem * rate / bleed.exsanguinated_rate
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

            indicator = function ()
                if settings.cycle and args.cycle_targets == 1 and active_enemies > 1 and target.time_to_die < longest_ttd then
                    return "cycle"
                end
            end,

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


    spec:RegisterPack( "Assassination", 20220821, [[Hekili:T33AZTnYXI(BrvQLMupOjHO8A7JKs51AtYUz39SLLV3nFsqqKGIicKGh8qY6uQ4V9B398aZmyMbG6rSVPsLuEfXJz6P7E63tJlgFXNV48zrLXx8BbJccg92GXdh)UjJgFX5L3Vo(IZxhn9MORH)yv0s4F)qrrurrYQOYKSv4DVpnlAgoifzv5tHNyrz56I3)6xFDs5IQRgonB5RlswwLsVX08O5L4VN(6lo)QQK0YFA1fxzfcg99xCEuv5IS8lo)8KLFeg5KzZIzpECXudyzZLFk76Q4n)8hQUUQOCZLbJ2h)NGGn)8MF(JlIwDDCX738ZhS5YpSED69BU8vfL5jtlF1MlNNgD9MllZ2Czr2Yy4b(9FbUyw(nf8RgDlC115ztJX5dF2KLXdPb7SSvVcMT)VrRskwS5YQvPWZS5YZttMcVt0QzWJq)5DjPPBUmncHT0maAYHHbaRnx(RW1WFjwpSb(tXPrFzZL)fa2Itt5RXxdZu8QzXLLrayD)QPBUSFYC1lMqW81xNgdZC2C4EzWqJVBeBE3C5hpBaBk(1OBIXziUybryG3Efaj5vRP)CZLaX7Qi8VHH5o4r)NeMDwcm0jLekAZL3MHaxACyrw6TXRkzd9)Nc4Xp)hoFZLlZYJ5OXQLlra5VhFBYQxbW5)D2)BCkHpXj4(SQnxUGq1LlIrArv6vjRMXgWpMT624CysZRwfhExw(SHZZZqWbh6RQMpFO8oH0DgwTM9QFayBai(pGXQyAeaY)XI4YIYSvCs4NVlgqeWt8JFPaytQqokoiFDmmbvf4n5G4Rq4tGUpO(5Nn8cGMxuwq7fkJJsHfbUX43OTyXRIUcijx8dat9u2ENP5jllYwfwgVCDCrjJRopzn7U)wY1lkkJsVjMt(o8ZVhWcS3bGzXlbVbqYsIG9RrPi6Ff8IL83CiFA3CzpaFUg4JclJYHffG8p9eymPBGu5SW1zaXNF9j01zp6qKxpSmlCwcSYb0vE8YOKv4tU5Y3CrjST1Xce5JQYJBBHngxyG4L1flYaS9NeVv3xzp1fWHowaRZYsdZJfs20wgNxDfaDZRUo(9sjk42HpfphEJf4(9Yfmgtek)Rr55zLXfxCoSPjCv8xkrgd4FM4yUVM9cwqdfYzwdjSdtetyAwrCySgNmC3(kl7JbCEajlr9XMfMtp8dpaI6a51LjRttqA0Xa(C8Mlh0vuAaaZ3pfeiWz14l0JEsi5nxUhT)8AfEgjQMJCbrCLCzhXRiPFatpBNOYU5LOu1zv5CjQxfpNeqPU3Vbr6ngWExPj87QIM1UpIdUfOwRIxMedypgMUhxEMYGQr7gEyt2Ks4)D(TKsiBYCYwdcLIlRFVBJaWhUl(xPvW)PpXbHIqH1omJZIJkxKEFyXIOzz3vOb2XapndYBUZB66qadhccBqsWag)u)UoY6JhSyb(0bgmf)LeMQw2gmIC(XFNRm63uerSFT24kMw7ZyZmiTHn1eAiKzyJQWLqyrmnB1SeAc9iHJJW1HpHPam4JXZUNoO9Eu37xaRIwYGDYmb2tMhhn7E(Qb5abU7pEMfooN8uTjSuq5h6CfZPezPaoAL(ePXh6t0zhWmQieggkJHeSIDQTWPA92OByN23f2rmYSyAx5TCabmVWN8BdXAaLmpkmAzw1kyx4KJAiIXu8yxfXiPtCjbay5aAf6bMLvkF4CMiuC4y7uvVPBTaQBtH9ZZtMIMdIB)7ByNXW5rRcZMhEZkqCbkI4ptkNzdtEuYSWyYOXOzZkgIMCEkQCQbFKfzWBbNMMb2jREV0iJ9KAowLXn5nxOujh9yyFsvbj8qWaUh4hYTdbziK13Sj4841fOH3ZbMlWi)fjCBMxNb2ZJCwQ0Z(soYLeCfgjS7xsxrkrTaZLr53G4qqZwOZxzGGBhPGClV0jV9mj91QSpSnwg2DkWvoEvItX4PvfnmPMzQGqnGbdtVHqJdKac)oQV3Hm9yahveW6jvKji13adIkpGfjZACbFkwQ(xLAalPvGOMBRsxfNZWnsnW1E9mOEE5JIn5DTRy172HJjZLQ1cH6PKwozt8s7ZhSuYV(EaTED8ks)CYkK)aPYhzGF(O8U)i9sOjvWBHkEIjxMyo)wIglfRcMSbxCNz2KF1oGkLC1KfAxfHYI7goDwUkmuFD(4eYFD)gSjDnByogVa8cyuaqoTApZIakg7hHOpDmp7eKiPVDWl99U8TZ3imDgbJV1X7wGHoieu6bwx3WI4FVQeDw6muniYTcQNGPsyWWhR4(dtgb)XfrfOeSCDxs(rWr6vzlz7jIOOrCxTfXQ4QDegIQbrc5cnT9JuK9ohlRy20ASE(BGkxu0868KmyEVxb8McI6k4lm(sGKGqRE8InT2xnyjQlepRcB3svK0rU8WexRJh5KpJg35kWtiDf1zT5D1mVY3dcgPm9gMiZroaWGMOEeIDgncFCSG4A6LDzhS)xojh8wGEFtPN1OlUulnBjgFezwOvbA1ZDu(0OvOZO55GovAAMOQ0GF)1vPfXgkpgFK6dMsw)f(pRMD9sCKmE23O(SxfDnPrgeDCtH(tcV4Aybt6qAOblcduasMky0ftnzYXpRSeUtiq5VpE2DaFpSa)sI574Y6B0Ib8TbtmjVTm2upnd4hIadqqtVwCFUxJXosz9eweJ2edRyGZ3I2jfXSIG3TUQOScuPfJ2KaaNUroYhRruefJQCnnxgMYhN6MXuGk09eTQ4M7iR9lcxhvoDrnWTl9OJgoHXdIM1gxgEv2Qk0wM48G3goz9u65gnKzx8aYvvBkOafxw0j9Oa5SRINLeVAASgOcW5KMok)zu2y0TGnoy8t(4zFIfD4rddcqblyKCRIv0x8PF7VcQ(rL6XmXPOZxWMomo6FbFg8TjqJnqzW8SeT3LerJrJMKpNMDDYuveHM4loYWuXPxKHyGGTBRUbid4ufwKMPh(t2nhwoEiO3leKqcmYRUpC26cHzSOVGINkWYtHCKkdJ0aL6OfHILugclpXGgdtcUxcilvL46j8)Pc25vTe2yElLxaE8rSUNSnaUN5eXIPY15rfRbbgLXlBYvCwmGWwcYqb7bwKmDbpdcWyoadxgQufvXihzwK)VdangRsujgWA(pkuCcs4G0WA(xBM50oBFGvYQJ1Vbz1gXxJEyLODAB0DtQAWZfv1bZQ(ezNQ6BFHf7WAhVBxchdhBdGxG(IIrnM22VDC9AWFvrCOynmoe02ekKDA1iRNPvsqNwjTsPDUscAUs0Sfq4vPHDgUSXY0Tann6TffmLabyxDo3XBMPAEsALDR4L2SJspMG6lpApHyHZoFaQjz4Ml)PLlbLxGdJuUsGDvb7THNqHI9nLISpZgF2f)8pG)eusLFxsbjnsM(rwgB52iU5YpKwKjUpkwJfuvY6yMsl4pjIC1ATGY4lK2tita4O4zXXRJZb2gGBbuRTudn33EquucxIwiu84JaEBtBIXqWf4XMy2BTJIVZAHtGpOUwOwcDFT4vFrqfh1wIw8P8a5BjGnTVz2rWgjpKEbqtMBNNNKMgN7ZA7I4CkmiOihWa21j3y61op)Gu(WjDOyPaiZelYJNHMJfjytG)SO2N49X)mEomlSApq8EZUN(DrgmTO7WZlz1uqm9QGpa3lEyvoD5QUEXPg6qllMq868a4zZQFV4HNTjERsQy7KK)oSpgeHKZI0W61eQC6cC0lyIEUQkFLTGmmNeY2LvMrWAdvDVF0W3k2GDvwbtRpnYkp1ju4h02FzzHne30kH8dKRIW55m0bAIoowGH)hX3f6ky6TJ3(Jfyac)1pWKMsHnhrrlaqVois7RBz4SOLKliiRTk)oyCu(DawKW9)sCeGGVcJa0xIwUo1ufxdD6bCD6prSV0f0uaacV6(Wy20BMfjs0S5Z4jzlsb8lXaUFhGtbTfuvNegVAre4chgLb5J6rSDVMApgyZhkfVVFjWvCy468QzxJjIa9xMV(Bb94i0ch5NVZxisTXMMcc3b3lbJzoYAKiUbl7OIWmErhPrFjO38bWnCgC)1L10tPGM8fMuTeeyM5BSAXqrq)DE6dWDEJF3EKFBtXQvdV5FJktUnx(dPrZeYYIUgjNCJZe5IOlIW6ZXnSAVl8kAmfHFKcs37Ko7StTkRW8SsURt9AlJGS6qApzTAicnppIk28a4rHSifVmfXSaWvWitGTkKbr8QKBLuRjSOiChEfyMbBx1u)YKTvh4AXsEaJUC4NvXVSPGuOnd2KidciEfAxg)bKjIQNhuQzIALjxtCdr()mY6MlIC70hRHoUDUhljXXiznmd5gP4GX0fzy4oZJjBywnZQtrTp199iud1fkKBPenWmWarK)w30wI9)QuS4btMfZL(whq3LxvXYpDJGBldgBvzskLaTgwW0H1HxAdlm)6b9l6Qd(v(mQXZFgX2T5YFN47y8Obs2564M3vSSLfi5djMDlpoq2m001YThEKFCKPEK6eu3Itp2QAnEUtKU544zS79XUyzyjTnZvXqy4qLbL6NqZ8HLb8VyaxRwJwnTkzTqDrgfIositky)ak9(ZF(SH8AR9oYomUlaZ5f4aREIXW2kHdHt0mhmqrzGV42CeZnbQbuJzpNb5SIAMWv4KGk2jyNv5shoc9RVcb3FD(zCh25fSf6RURijQxZZolKchMvGu1dAA0rDW861DAMK7QzG84k9AXhEPH7QpIMJXywUuycjhTNQxAW6cK2r1Da0GqEjJj0wU9LOqBbqIpRp1OaWYM6bKyNDBnGkMLckXFuxfy3bcKX8w3SwY2tVmUPGBdIatMkwZnsqJEDFPw4FBF5xuJN8wDpovFBnIX2zxr1yMENrb(czYRXu0UozHoXRiQpOuDKy89jrqOkb96PupH6wqDlJ0ryBvE5SukhSfVYyQSFxIAU5E43RmWxRINMNLMLpZ86GC0w5LAk1Hk6qrDDHrJHD2jI44R7yh7dSyRP42mLoxhOdTCjGKV8QLvHAor2(ubopndPh9P)VrCcWDumnzVMU9y8xUkHgrQkpfp2lToMh0QeSTBw7164rMd2PWJY9hvByKoE7kKk4YYkpfF7wxzl32uy(Tcr0SO72U5ti5YSO(ECOCsSB48OollWseb0D5t5KmrIV(DwXhS5YFKx9bm1buuRKEBYSrcnEiQgrb)fAi6f61T5ZvvnSPUCnRD6Lckm7IoQeZ2DOPVmM3c7yPGdQwfGbs95ndQ05YZ)vyYCLqNyUo0EqrwDqzB2QwdLN960SRIs5cbDgbenDoweCRlOwpTrphYQ5(9RFU6yw6oLY20vu0pOyQ8AZZB3GHMXT0mQgmYuxCn(yrL528Hv17spsljWQNDhCuK26mgME2xpXvaAAfd0o42VDzBtuKFX4EcR3)QklZScu2c5NtO)txOwpnqzGJna2c8sDyqrXWw3JiSC55F3X(8AhILskL4HboFwk2NKsXtJkU0yA8gpQOdCfwTkMXl4PAHLfl5Zpho(QdAjcuU3J3cV1yP((gCmDI3C8OTK3020mOb7KTyz1UTnEOOnIgPxLCnxo2DpRRcgTHEA6LH(PhrUDHoBXXQhbyDBh2xEusy5dJcId56aPnNkzbHdHVwmViZmFIl4EEvaBTkMNGE9A1uiflGAeLo2dFxE06cm2GXPGGv88pdd5uqUAjm1jOsxbPR1NSuuzSwe5GPGgF3PzGaQ1yO2cNxHRFTT3eHLcUdZSCg3wl71oCKyT4zskfvIRfyJx4nJTkquKwCEW6TxOBnQaL6soHIIfYsj29yyA4ogHx3E9mXqc2yjvzzBvCxG7XXs419xABVMvBgSr0sgOdudsQCgBuYzkhE1(Uf12zuKBaHh3TwGKaLy3zR2)4XmBlWI8PFG08zFqatNH7e06HHj4BiggRfl5ZjdtWJIHXgk6PYWm2gdZ4)fYWykglGyHCLbCXuBj688d78NdElyk96P4rymon6EmEFGpCAbO)SSpd)ob9Mr0IpMIbwd9Sr25oOCkay5d)omB2fyqelKDRbW691Ggm(zfJg6Pv0jXqmWIQ4QzUKCZmBRCpOs4KtlvTtKv7MRNYJFVR7sN12qgiDa5x1af2uvZuSpGnURRbKT135PGsRndOxeLAHTMLFhZivqMwCvgQMsA3bDT6wGalxs8aGWm1pEvw11l6OJP7SX9je2WGoj3o70smMLfFxNtcBBXz25YkWYj0tPN)fraNSnJJWeWDQDR(h4ZFa6OBf4QMcWWHyAbbCj2oeydtHA(6WR9Bm)J(lrKhposPLWFmKOO0SEMR5d2DSDxQ77weLoh7xbj3I1xInBputoLmIAg2yldXJhFSCzPEF1C)0wIPAVWJSKDwCMnh46kxGiwUl9Gx61EFBbpvQkWzCvPJXoXhUNt1ZBRcf(aEcVyA15yrSKBFu5fXqw2S0ka7cZ90YoyqUl)MRNBWRbUFjbUpCF(gacOaZ7ZVNge3LGG3bjoVioxuFQbU7Lc(gK5j5Xe0qJH7tqSVXalRpmtMPH4rIKgi3gbAn6VEJXB9e59exw30ecCz)WD8MHv4DIEHLkK5VGGqoIcaznRUzsHSjosh)Bg1kJ23lDITjuHlcxktNgnDrmcArt)FQyaeWzxy1Bu5Je9LyLchPTYRHzwyllT2qxJLwb6lyQhjWc(wwy(9n1CXElI1fCRfd0FiO7y2nX5txKep)cl1uJ2UphVKkFkteDvCAOH4tcGCgFsGusrAyowTM5RGTf4PTFESXOZKt76HdN0Li1vh9a3ZkcRUk7f0)caKwAgo1Zy9Ic9y2q2wvvWmkIERHwKqCvC5DXXRO(2r89XfTVmiNwUGDuCYSEoCApqC2lbZ(Mw1vJ5KQMe3S2vpnLtgn9HnnkOPFjzjw9bSdveD6deD9mogRzTswBceRozp8ircSWZSe1lkmQEbumz8xwNKZdhJ9J7qDq0kUjzDiBdqDVY6rCkuCJwBAMrBYdm9g)rGz5w))KXSCtBly(mqhkRpVNd8NOF(9OQXOTR5Y4ul4PuMoh42vKtBwsKCSxnktnZEu7851MTGZAuc5DvnAmypbzOaZTbMPzjxO0JmWlHgOqfKxRT8pDNpwhpnbpch1U4HGKCYa0ocNehaZVdDhjX85OkCQTUH1oB81hbN1s)HQxxQcSG23L0QQ3gqtdxdp2MdGxyPgLEoXnc(rh4M(BtZZRt4YXU3k4frO5bHcZPRGR7Rnnk5mRwFtCmLce6yycADffEpf(CCxiM2XiI4Z4QVgfkfvI8UKKmANeRl5IvHMO9mI1Xg13)Wcp2O1P52cBZGx4USpLKhBeoY6wvL0OXpHiYSDgz(XBqgPjpSq(MMD70UgZjZgzxTBDkd)s3D8qrjQPVfQKfh8nLUl7d7s)(XO807vAHrswn6KBuYKt3OjgblEkh1u4ZUhJZWAqOz8YKPd2y5e9zwjGtwpvZBixNMCh6081z0y1ZHMZpFRWz2nMfwyPnDbPBKENfYGLMDRA8YBAdhhl(F2D3obBCqx2EB7W16UDpz25Q9DOnS02Pzqu7LaK7wzxWifmU3yR554qPUlSpbv7ri4DBgzajuXIXVmE3S2ZZwfYBHw5bnnZ3S7EZSTKZYgVPUuBeTzbudjlrb5vRwrln6CEGgjfCWrf2Q3hMDSSuciDfGvYc5XuyOHLd7i5ktJGqajXv46CozVDFZoN14ivNWco0tLzT2jHVpBXKMCBcRtcvN9comYsicp9td8kWixmFDIxZuyY)wjSOnjfNsWZerWQvotCrut3lSyAw1Qz5XPATDQJucWT3ZrNXZ62X3Djl7LzrZLNs2z1mTvOUYC(gWwH25aFwSM4T))R0BwDfquDN1EuvJVmaoSsqDR))rUW)EjxWUPkUCBTHPkgNr80uwXC)HSFS5xxdXEC2P3pcrYuZTJ7f7vz3glQg2KRxLXBplmXfSiTPg0yr84eQz51PHLV3fpbtMmcZshmOHqFo7JTErF2Tx58plox91IsfAVJzIOPdzMahr3H6vtIUifpD4ZYe5cx0arK9RWp)dV(x)Ghu2j6f0tNyCPiZJIAB(DKrSFXh(VVz4BoytDdt3ukI)aj13A(RvsfRwp4ql0NBXo7juIgWGLhNxG0t(3FPrV7IZVlkhnNS4IZ)Jp8PF7N(T)673CjG1rw7KLRZWVdpKHHVsMaZxHdolDvB4nLROQYSLS9VtzF)LgU5N)fQZdo59YVOp4TXVVtu9suImgFhJg)lvy)qcmfSG0sNTweNO(VgwJ9h)f8Ry0MFUfaKLl0Td6gRdDVQM95F8kgSPEjbheCR(beqXgL38OhLoU0K9XTTB1zG7FL8u(ibR6R0eQEsJbAo1p(F)lgd2rpre1Zd6MnkFVXOikfWX1JIs1bIxR)Ko86bwED216FOYR)2TF27YR7z2vb(3T9ZUk)(4rB)0h0noDwFjC7yZnrgDKfvJByCWtKPQ1v20zfB3Y6npDjNbUzyFQd3JfP7Jp6PctMeXV5gVNbs6ypJxx2h3P33Z(yT3)zGNY34T1RNhHq5oU7Dw2wkuA8HpAbkASmpB2pzF8ESG1JxtEGpcw3hgV0DPD9AVdnCg29)padUvzd(jIQJdY3VHFk6WOuwuIuwY5JPyzh(oSmrYMNGL9WF6pvxnb84mX)aLs3X2hPu8g1FOsXFDWZ5hRu(a(Y8blLp4V0F0s5tZl1hUu(W)8(XlLpOCoXnB7hWubFGVpIP8N5z6dzQGx8h)s80kIRxKfEbA9Q4RbViXw400PXRrpGxLT6Gfr5lNxLk2HuGuW07HHJ)7Hshwor97GHL7V3jV21xad7pTztRA)g946tgpA)K5NSJzd)OxZcm50XhzFwQBQb4q5Szq8WdoBCc2hxrCV2hRxOtQlc8z57tvp1jJpOVsimm)QvSBF87uXE9Tf75DhnC8Gbdackxb2xPVheDzHBE04TT4LF)l2f)MxWwxV8Frd6c034qDjaFKxP2KfZ29FV(7uBpI5nF4H6xSXjX70tQFXg3CG6R6Td2)Wd9BSNWdi1tByB8LjyWtbvfOIQSm11OQM4X61RfSXPEqJduFZhpMYcLvByFCyk3htwokZ2E(E9TauQFId6mVXwdJbBpm64ZWqNPkoGrEGjDCtTVLc2uwq6k80u86Pgr3g6lb1ju1it5LHKLcqbkuKYa5TrjPuAoKa3j4x2qsw2t7twOCaTGaAq30ojwcsL7uhDCabGB13mq3tUrgE4tV1c(40dpY9448etXhrNhl6DTCORMLRorMhXgowt26hywKZyvmplLTomtNvqOZx8VNFASe6S9ilolfdMFz86PMEJtpzmbQVCFQ(uHr(hyee4CaB2UmNOE8rgq(eFdTTwlxph3rmbJD9aulX(4dhzaabTZkGDa62FikcOQpN(39oCrP)HWaiBhTN9kOQ5OqFD8uVUXhdp1BP9TVt63kFFgJR(RyRTTwGpSf7Kg(fWB2WNmE4r7RLiz2(4MDyyWOd7NDvqbvJCSb0)bGMTMx3wPjUladp8GT7C6jQzsCGeL(vSV7QHwT5WLfKh4j1HJoWvF4Tx7RCa3BAWfydMZ9UiYKlT3wVLeCRJio(oiZp8Wo1hPxzV1L7)0ZulO1ev6qHM9UEexTMpttG1GNZXGcsY2zk44Joiy32(uhHiJxYonBhXqQT6jd8IJEV7dpy5eGJyedR6TXAEYihmbV49o2oIoA2wRWnLgnnxLfRSH5QEnqYSWV1NNPLJs5dk1rZ63x7CpEqWObFx)XbJSBs2GbN64ToW72D)JzVwevm6Hh8iNXERNfEfqCzpnW84Grpp4rz7n4LftQ3hd8pASDt69cwN4G)KE8AP98p52ZQjQvpaD9FmrOBqVD0ou(92PzDz2ZrX0FYOE990(vpnaenRxvpd23sJufnfXOLPQDj1yp2maJszuFJ3MuBs7QbxY1edFQ613cBOHtFhFyVMpKQAIE2RGlWrHEnTAJKc0K6BNfFYGTEb5gw6BFF6ey)OyjxVP0mSPo3Mp5G2XGDCguni6BWwnQjPGjJYkrWIbb967mQbG)Fpn(KXJAWN4b4SZhaJX3jGqh06XJ6eTwokd2tM1MVLGkIl7Ry34SZQUnSc1gtMXHqYQELMyh7Eb0MuoByztRlmxBIgGbBT1wtc1)BNN4QbEkd(Ir3b16MLdvn5U85UbEAUe4JcfhafN(Dhc(hEWgEwqd8iejW(BQVpWxol(UaW4lDC1jbyOhKdBJuSCY4E9TjJQtRZMtf4hUN5kqlRwsWNCMUtRDygGPyh3trdPO8NiWd1l4Rb1Zs2OEmuVGTG6zUo3wQ3yTeT9cr94H06BXMvzdP(c5jaRLxEMDSLPlaxBTHuE6j2VEDFL8Gdb)u7BT5tYFzpnLs8LzO5x8(kPj(snUs2nGyhhDyYEw6Jf72F8EwRSHM7hgC6K9MSRAeezUOAoIJgE0PnnJBGnt7MW0azVbq(FT5RvdGSHnKW91lVfz8c6z4YPvlETzGs)DAnwP2A3J1gFyeUCpT5XM2eZxppNlN(ndYbjqZrSpoDCWG9SQgORIbHb4KGglnwhtuAhKrtz0HDq28VWCGR7KI4G3HNx20e72Zl7pID7X1BfID7DSN7l2r4XqscgAgNHHPfBBB0LbPu46o13NA0VdF4blP64nJSs7(E)WINE9NKfXO1f2RVhqfuE7a28T(gpWEqnoYpW7S7bAl1A74Shc6FsC2o)uYFT3whOpxl6A39ZfiwOWxBPD)zDQpbdhklRPNXYQR88ngDvskafXSSOktVUOHj0)O9eQto78b8S59tIWgIvna6Ftq9N459T5suU4IF(h(V08q6UizTXYkTyESm3C5hO25e7(0j18lfxZ73kmpTH)mH1XiuqvSCwFIsA3DgXR9AjLt2T(vxtG3i2RNBCGg4i34QMTAO)YbWRLQ2ALMpICVDQQYcgYRrmhQ)(7klWflzrD8ZWcMyb5vFU8lEUE76Oo57ItMklwFcV03xe6UCwDOlEpEQ9lYarVyXHmVugbqJo5Of8HLV97AgMxJH6Tdl)enEE6ZWDdHpENblc0E8Z4FclJCSTOmpNv9mRxtiKPlWXNBK4vv5R2yPWziHjfDeSDaMouCE8OHVTxFBISosZmPgZZqknhmO)a()ffgtGyu6XNmAyWrmVr(dY)JF9dm5gKFi4ACrc2Ixuc8RQTZcXJihMkBhg547agnc59lGDzWJGLL0xIwUwn5qTHIAXo2UI4KjLjfaLWRUpmMbisHymTvM3fTH1wWJXRSe1uEhaWGSqYsLW4vlqlRWIYHEmh7E7zKNPUJmEwWf2oN6W60jcWInlhrSl1hfJN2HWOtREzXbD0(Q5y7gC2a7l4ZfRcWmUi7tCeLLt0RnCJ6FN3Xnq27XVBpkKLyftr38VLmBgUr4hWgIbFhpLPScUUEHHAwaDnB3CTfNvMmlOPjKA7gfSAu70tg)UhEO)onAOT98zH4jhUNHx88Ol0y5sQjyQnyNVJIn82breP9KFUEwvlJNLhr6kWIamMrtzbteqZgClV78C4N7cgIn1Ku4z03bF(zpbVYX8BYlO2EwqnoQBelUzoW6wf)ywllG4PlYWOMNhtkexnZfzUlUHoYYeeT8QkMpvwzECNG7DS0qx4cRUkfDSkzwmtGdEItIU6GFTQmjvEoK4CgNreHnx(7StaerjdQj6nH3L8rPRkI95IuGVX3(4jnyNRjINZsQ(U1nA)BMMGTYImR8eDRiB2qf5wt2uOqFl9y3JL2cy2YWvIlIrfEpWb25fTrwRHdAylDZggLhSGEqN8THoOJiH)L2pQ7aMqhhyj7K9n93YHuIthnWwGCpLDacEo6N1MRgbtmS51J7x92XEp3rleIkn3RJpzCpVoSDCGx5m2dftplBOWisFCZOpBUmfuONWY0s)PgxM9D5zUw546hzm2A07TVYyBe(xBFJ2eBQ1EA3FoVd2Qw3JnyUutvH9YxgqL6O2hEq6eLSxT1I9ayueStcTny76LjKnCnjahWhObNoPlHrTnmggTQVsDQzpKlRh8mlc2C0Ifp(WEYO4(YsU9rFc6ovWoIWwSyRDASHLa9(3rM8Xb(4YXZVY36TExtQRrM0SrL1WyNEsGNco0(bVlyeDcmCKbmRE)iiD9d27WD7Babtgmy3(JpW(bvV5(su3b3lZx0UiSh1SgBu43XdIuDZZ3GBsCVh50(t2RVN(K4Uhnq7(cF)OR7YE3DFJOge(k1AE9qATQCWnH9rP24TFnq4FxdngIvDx1eiyZ)pC)pzIbpgzFZ0MzBtnY2P2q6hKvH9EuS(VSEe72UEPIFZdJaW5P3(EeEDnWjAQVQpuhmEG2Uex(Q1FhtNTTfsDPN1E5TNiIE151f81hyyfIeH1VeVeJzuNd)87Tq4KyszGGpXc20xptWGd5qZdRTVfXBSdQJrq9Czf(1GlxcRwDF2kuU1a15vxbwwoV6643lZykA62N0pN(i5lEMs8aTcKTBDV6t7XgF(sSqcCTgFG(sp5d(o1BmdBjhGmxDb6Ez5cmqmuNOMv1asQ2NA4Pytv6fIMHHShwrIfQnqq4NVwmIEgrSErK(ccJEsfoH33augejYE4HI9N8EYgPYiH1E2ySo6hvw1tASYHRLlO)m84ytjTN64mkSzS6OYiuW6hWG1noldAsdzdDiRx2u4uINwjr8Wd9DpcQV3Xb8Z7rK6sNX0SN(Q(9ylG7ljlRwYqlK6b2tY)0VqikwDd)x)4zM4akaOIIkZhv0NCcPAFNOW2cyMLLR6QKTSzba9ARl5AlEvRLo3RrRRdFvSsxwK(kRpjO4A33(W)MhfgTe0VwEYKJ6YQWYoXgjKWAs1ntMHunSE(9mLZzpii(QcVt)ZtgyTXYfyHKRfR)KvVxQfBpPGrYbi0wjPdu5yBICFssiTRxl9bdfNzg9spEoqAtXsTOCJRM7GfKE)2os917UXMcb1AqwGgOO94dyLgtD0H1R5BJ4HF6H2PE2njQHdytSDYKz5KqVgFp(qQd4FX)Vd]] )


end
