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


    spec:RegisterPack( "Assassination", 20220514, [[difGddqivL8iLeDjsHYMiL(KQsnkvWPuHwLkIELevZsI4wsKAxs6xirnmKKoMQILHeEMeLMgjHRPKW2ijIVPIqnosr15ijsTosI6DijGmpKi3JKAFuL8pKeqDqveSqsbpuIKjIKqxuII2iPi1hrsuJKuOIojscALKKEjPqvZKui3KuKStvK(jscWqrsKLkrHNsQMQssxLuOsBLueFLKizSKIYEvP)QudMYHfwmv6XQYKf1LH2mj(mv1OvvDAPwnPqfETsQzlYTLWUv8BqdNkoUkcz5aphX0jUosTDL47QOgpvPopsQ1JKanFQI9J67N7Qx9Ci49ukOkfuq1v8rfvkklv1CQQsF1fQDWRUt8wh(4vFIc8QFcesqi9esdNRUtqDcg57QxDcKg8WR(VioevMYu2VLFA36dwqzsxqNcPHZdekcLjDXJYxDx6ojuHZ19QNdbVNsbvPGcQUIpQOsbfFujROSx9Gw(HGRUExuQR(FNZ4CDV6zK8U6NaHeespH0WHTYa6tJSQAQGA2(OIsyJcQsbfSQSQL6pgFKOYSQLMTtWXjrnBFteq)KVztjf(Sjq2iWcKTtGkPrSPabRjSjq2iXcYMda(qcPhF2KUaRSQLMnQiC(wyttIPj)SrpjKqytp1pKTyYSrf7hY25oLylfeHTeC8raBYFmSPPcIGa2obcjiKEQSQLMTYatH3SPPtHpMsH0WHnkZMMGtgfjyJq98y7qRWMMGtgfjyRjSjqF)eMzdQOWgeWgCylylbhF2kfv8yLvT0SPPI1iBA6es(FGqryRhbbaAhHTEy7blCdHTwHTZiBACqte2YDMTwytbcyBbMcPt4Matl4ivw1sZMgxcYMUg0zRacq2eiBe6Ic4WMgpU0Z3e2Ocasfet94ZwRWg1qA2(JfKn5hzJaPtU9KRSQLMTsbNfeiSbOhCFgcYvfaKiSjq2CPvuQa6b3NHG8wbajsL2PYQwA2oHCgZSPs1tM8caBQu)Oqe4Gvw1sZ2QNXynMzRm9MeJpDpHGSjq28rHnAcMzRvyJAi93liBAcozuKO0Ky8P7jemxV6PMiK7QxDIGrs(X8D17PFURE1XjCty(QHRE8Kgox9hOliWzlyHdsKREgjpq7inCU6N2()ejsRraBWHTYUQkZwPaDbboSTkw4Ge5Q)aTGGoU6sKWrQt7)lejsRrqfNWnHz20YgXbtPTeaFuiS5LA2klBAz7blCHBhypcHnVuZMkytlBsa8rPkDbUf4o3iBLMnawe9qyZl2ujx5Ekf3vV64eUjmF1WvpEsdNRoG2rOb4vpJKhODKgox9tB)FIeP1iGn4W2Nvvz20NWH8df2kdAhHgGx9hOfe0XvxIeosDA)FHirAncQ4eUjmZMw2EWcx42b2JqyZl1SPc20YMeaFuQsxGBbUZnYwPzdGfrpe28InvYvUNw27QxDCc3eMVA4QhpPHZv3bctBasG0GhE1Zi5bAhPHZvxN2vqGcTpQYSDcoojQzdcyRmqfas(z7Cl)S5sROGz2OYbaafKC1vGG9GEl3t)CL7PQ4U6vhNWnH5RgU6XtA4C19daak4v)bAbbDC1LiHJuj0UccuO9XkoHBcZSPLTVy7CNs7eKGB0Bsm(09ecYMw2oWgalIEiSrj2(qbBuMn0Bsm(09ecM3Gqq284HnNc6K0oPgbSrj1S9HTJSPLnja(OuLUa3cCNBKTsZgalIEiS5fBuC1Fu)s4wcGpkK7PFUY90vCx9QJt4MW8vdx94jnCU6oqyAdqcKg8WREgjpq7inCU660UccuO9r2kNTY0BIpBWHTpRQYSvgOcaj)SrLdaakiBHWM8JSHtMnOcBebJK8ZMazZhf2kcVzltdcPHdBUOceGSvMEtIXNUNqWRUceSh0B5E6NRCpvLCx9QJt4MW8vdx9hOfe0XvxIeosLq7kiqH2hR4eUjmZMw2KiHJurVjX4t3tiyfNWnHz20Yw8KEb34GfnsytnBFytlBU0kkvcTRGafAFScWIOhcBuITp1YE1JN0W5Q7haauWRCLR(smn5)U690p3vV64eUjmF1Wvh6C1jOC1JN0W5QVeGoCt4vFjs04v)aBFXgGEqfiWhRzmK)e1BYFKHNjvCc3eMztlBOIc(KEb3pyHlC7a7riS5LA2Eo7IW7nXbNmBhzZJh2oWgGEqfiWhRzmK)e1BYFKHNjvCc3eMztlBpyHlC7a7riSrj2OGTJx9msEG2rA4C11090KF2o3YpBfH3SvkQeBkqaBN2()crI0AeucB0tcje2Oj94Zgved5prnB6)rgEMC1xcWEIc8QpT)VqKiTgb7NZ(bNClnCUY9ukURE1XjCty(QHRE8Kgox9LyAY)vpJKhODKgoxDnjMM8Z25w(zRm9M4Zw5SDA7)lejsRrGkZMMk8UlOlyRuuj2IjZwz6nXNnagzQztbcyBqVf2OYLIkE1FGwqqhxDjs4iv0Bsm(09ecwXjCtyMnTSjrchPoT)VqKiTgbvCc3eMztlBlbOd3ewN2)xisKwJG9Zz)GtULgoSPLTheMYWZtf9MeJpDpHGvawe9qyJsS95k3tl7D1RooHBcZxnC1JN0W5QVett(V6zK8aTJ0W5QRjX0KF2o3YpBN2()crI0AeWw5SDkKTY0BIVkZMMk8UlOlyRuuj2IjZMMGtgfjyJ25Q)aTGGoU6sKWrQt7)lejsRrqfNWnHz20Y2xSjrchPIEtIXNUNqWkoHBcZSPLTLa0HBcRt7)lejsRrW(5SFWj3sdh20YwgDPvuQl4KrrIkTZvUNQI7QxDCc3eMVA4QhpPHZv3bctBasG0GhE1rVfqSJci9ixDvSIRUceSh0B5E6NRCpDf3vV64eUjmF1Wv)bAbbDC1LiHJuj0UccuO9XkoHBcZSPLTheMYWZt1paaOGvAh20YwgDPvuQl4KrrIkTdBAz7aBzOu9daakyfGkaK8hUjKnpEyldLQFaaqbRof0jPDsncyJsQz7dBhztlBpyHlC7a7ri1mQ0VwyZl1SDGnIdMsBja(OqQkXSHk71tVGe28IkWSPc2oYMw2arN34cosnYzsTh28ITpuC1JN0W5QVett(VY9uvYD1RooHBcZxnC1JN0W5QVett(V6zK8aTJ0W5QRjX0KF2o3YpBAQGiiGTtGqcspQmBLbTJqdWYPYbaafKTbkS1dBaubGKF2aX4JLWwMg0JpBAcozuKOC9)EPYMo1ZJTZT8ZMo6qAcBk9ej2(BHTwHnhiH0UjSE1FGwqqhx9dSjrchPweebb7GqccPNkoHBcZS5XdBa6bvGaFSweG1BOYw(XDrqeeSdcjiKEQ4eUjmZ2r20Y2xSLHsfq7i0aScqfas(d3eYMw2YqP6haauWkalIEiS5fBLLnTSLrxAfL6cozuKOs7WMw2oWwgDPvuQK)EPs7WMhpSLrxAfL6cozuKOcWIOhcBuInvWMhpSLHsLGoKMuL(TUhF2oYMw2YqPsqhstQaSi6HWgLyRSx5kx9mQe0j5U690p3vV6XtA4C1x3V1xDCc3eMVA4k3tP4U6vhNWnH5RgU6zK8aTJ0W5QxgirWij)S1kS5ajK2nHSDyGSTqNgeeUjKnCWIgjS1dBpyHBihV6XtA4C1jcgj5)k3tl7D1RooHBcZxnC1HoxDckx94jnCU6lbOd3eE1xIenE1joykTLa4JcPQeZgQSxp9csyJsSrXvFja7jkWRoPh)eULa4JYvUNQI7QxDCc3eMVA4QdDU6euU6XtA4C1xcqhUj8QVejA8QJdc8PUcqFC2pyHBpyMnVyRSR4QNrYd0osdNREPGfU9Gz2kZbb(uZwzG(4W2GygZSjq2iHqdcbV6lbyprbE1bOpoBsi0GqW8vUNUI7QxDCc3eMVA4QdDU6euU6XtA4C1xcqhUj8QVejA8Q)GWugEEQl4KrrIkalIEiSDs2wcqhUjSUGtgfj2Vm4QVeG9ef4vFbNmksSFqykdppBawe9qUY9uvYD1RooHBcZxnC1FGwqqhxDIGrs(XCfa9PXRora9tUN(5QhpPHZv)fP0oEsdNDQjYvp1ezprbE1jcgj5hZx5E6j(U6vhNWnH5RgU6XtA4C1FrkTJN0WzNAIC1tnr2tuGx9xMCL7PA(D1RooHBcZxnC1JN0W5Qts9d3XK35(Hx9msEG2rA4C1Ps0cB6dvKnAh26PLosjQztbcyRu0cBcKn5hzRu)bblHnaQaqYpBNB5NTYCwWbwWwRWwiSLGNzltdcPHZv)bAbbDC1)InxAfLkj1pChtEN7hwPDytlBpyHlC7a7riS5LA2(CL7PQ03vV64eUjmF1Wv)bAbbDC1DPvuQKu)WDm5DUFyL2HnTS5sROujP(H7yY7C)WkalIEiSrj2wbBAz7blCHBhypcHnVuZMkU6XtA4C1XzbhyXvUN(HQ3vV64eUjmF1WvpEsdNR(lsPD8Kgo7utKREQjYEIc8QNHYvUN(5ZD1RooHBcZxnC1JN0W5Q)IuAhpPHZo1e5QNAISNOaV65gGp5k3t)qXD1RooHBcZxnC1FGwqqhxDCqGp11mQ0VwyZl1S9zfSvoB4GaFQRa0hN9dw42dMV6XtA4C1dWlgClqaah5k3t)u27Qx94jnCU6b4fdUDOte8QJt4MW8vdx5E6hvCx9QhpPHZvp1()czRXbD2Vah5QJt4MW8vdx5E6NvCx9QhpPHZv3n83qLTa63AYvhNWnH5RgUYvU6oa8blCd5U690p3vV6XtA4C1dhNe1BhytGZvhNWnH5RgUY9ukURE1JN0W5Q7cfjH5TskOgZN7XFlqV75QJt4MW8vdx5EAzVRE1XjCty(QHRE8Kgox9IaSgZBfiyNXq(V6pqliOJR(xS9Gl4eJuxWr(PgWMw2arN34cosnYzsTh28ITpR4Q7aWhSWnKnbFWjtU6FO6vUNQI7QxDCc3eMVA4Q)aTGGoU6eiDYTNC1HMi0jCJaAhPHtfNWnHz284HncKo52tUUatH0jCtGPfCKkoHBcZx94jnCU6kjK8)aHICL7PR4U6vhNWnH5RgU6qNRobLRE8Kgox9La0HBcV6lrIgV6FyR0SDGna9GkqGpwZ0K1NJ0Aeq2oH8(R4eUjmZ2jz7aBuTQIvWw5SDGnckBx4qtQsJak08TkCESDs2OA9dBhz7iBhV6lbyprbE1xWjJIe7xgCL7PQK7QxDCc3eMVA4QdDU6euU6XtA4C1xcqhUj8QVejA8Q)HTsZ2b2a0dQab(yf6I5gNhwXjCtyMTtYgvRQqfSD8QNrYd0osdNR(Q)iBXcccFKTsrfld2AcBuTsbfS5slSLPr2eiBYpYwzCkvMTjeAaYguHTsrLyZhNsyJcVzt(BcBlrIgzRjSbDKUisSPabSrOEE94Zwc63VR(sa2tuGxDLu4JPuinC2Vm4k3tpX3vV64eUjmF1Wvh6C1jOC1JN0W5QVeGoCt4vFja7jkWRUa6znkBc1ZBtsq5Q)aTGGoU6cON1OuLp1)GSjsi1yOENDiSPLTdS9fBcON1OufkQ)bztKqQXq9o7qyZJh2eqpRrPkFQpimLHNNAMgesdh28snBcON1OufkQpimLHNNAMgesdh2oYMhpSjGEwJsv(uBsThYdqlHBc3Ni6ye6IDgx6hYMhpSDGThCbNyK6coYp1a20Y2xSjGEwJsvOO(hKnrcPgd17SdHnTSjGEwJsv(uBsL8hz4zFqqC2cuWc2oE1Zi5bAhPHZvNkIcck6bz78F)(z7qRWwmuFKnIecBU0kkSjGEwJcBNr2ohJWMazleblCe2eiBeQNhBNB5NnnbNmksuV6lrIgV6FUY9un)U6vhNWnH5RgU6qNRobLRE8Kgox9La0HBcV6lrIgV6uC1FGwqqhxDb0ZAuQcf1)GSjsi1yOENDiSPLTdS9fBcON1OuLp1)GSjsi1yOENDiS5XdBcON1OufkQpimLHNNAMgesdh28Inb0ZAuQYN6dctz45PMPbH0WHTJS5XdBcON1OufkQnP2d5bOLWnH7teDmcDXoJl9dzZJh2oW2dUGtmsDbh5NAaBAz7l2eqpRrPkFQ)bztKqQXq9o7qytlBcON1OufkQnPs(Jm8SpiioBbkybBhV6lbyprbE1fqpRrztOEEBsckx5EQk9D1RooHBcZxnC1HoxDckx94jnCU6lbOd3eE1xIenE1jOSDHdnPkncOqZ3QW5XMw2oWMa6znkv5t9piBIes9picUbH0JpBE8WMa6znkv5tTj1EipaTeUjCFIOJrOl2zCPFiBhV6lbyprbE1Pj4wa9SgL9NTda3l4KrrIRCp9dvVRE1XjCty(QHRo05Qtq5QhpPHZvFjaD4MWR(sKOXRobLTlCOjvPrafA(wfop20Y2b2eqpRrPkuu)dYMiHu)dIGBqi94ZMhpSjGEwJsvOO2KApKhGwc3eUpr0Xi0f7mU0pKTJx9LaSNOaV60eClGEwJYMITda3l4KrrIRCp9ZN7Qx94jnCU6ebJK8F1XjCty(QHRCp9df3vV64eUjmF1WvpEsdNRoj1pChtEN7hE1FGwqqhx9VytIeosDA)FHirAncQ4eUjmZMw2aOcaj)HBcV6oa8blCdztWhCYKR(NRCLREUb4tUREp9ZD1RooHBcZxnC1JN0W5QJZcoWIREgjpq7inCU6L5SGdSGTqytfLZ2HvuoBNB5NnQO(r2kfvQYgvyrbM7qWe1Sbh2OOC2Ka4JcPe2o3YpBAcozuKOe2Ga2o3YpBRQHsydk)i4Ctq2ohTWMceWgbwGSHdc8PUY2jKiq2ohTWwRWwz6nXNThSWfYwty7bl6XNnAN6v)bAbbDC1rff8j9cUFWcx42b2JqyZl1SPc2kNnjs4i1mIoiyteqiHpwuXjCtyMnTSDGTm6sROuxWjJIevAh284HTm6sROuj)9sL2HnpEylJU0kkvLu4JPuinCQ0oS5XdB4GaFQRzuPFTWgLuZgfRGTYzdhe4tDfG(4SFWc3EWmBE8W2xSTeGoCtyL0JFc3sa8rHnpEydvuWN0l4(blCHBhypcHnVy75SlcV3ehCYSDKnTSDGTVytIeosf9MeJpDpHGvCc3eMzZJh2Eqykdppv0Bsm(09ecwbyr0dHnVyJc2oEL7PuCx9QJt4MW8vdxDOZvNGYvpEsdNR(sa6WnHx9LirJx9hSWfUDG9iKAgv6xlS5fBFyZJh2Wbb(uxZOs)AHnkPMnkwbBLZgoiWN6ka9Xz)GfU9Gz284HTVyBjaD4MWkPh)eULa4JYvFja7jkWRonb3kDkHGRCpTS3vV64eUjmF1WvpEsdNRobbGqW82fo4M40RXREgjpq7inCU6NGJtIA201GoBcKTiLytcGpke2o3YpKwylylJU0kkSfe2Cane0c1LWMdavqaOhF2Ka4JcHTm194ZgbcheWwOiiGn5hzZb0fbGA2Ka4JYv)bAbbDC1xcqhUjSstWTsNsiGnTS9fBzOujiaecM3UWb3eNEnUZqPk9BDp(x5EQkURE1XjCty(QHRE8KgoxDccaHG5TlCWnXPxJx9hOfe0XvFjaD4MWknb3kDkHa20Y2xSLHsLGaqiyE7chCtC614odLQ0V194F1Fu)s4wcGpkK7PFUY90vCx9QJt4MW8vdx94jnCU6eeacbZBx4GBItVgV6zK8aTJ0W5QRXJOdBkaybBVWXPhF2E)bWhjSbbS5sdg2cHn5hzdNmBqf2uA)FHC1FGwqqhx9La0HBcR0eCR0PecytlBfbrqWoiKGq6zdWIOhcBuInQw1C20Y2b2CHecBAztP9)LnalIEiSrj1STc284HTheMYWZtLGaqiyE7chCtC61yTi8E)(dGpsyR0S9(dGps2kG4jnCIeBusnBuTsXky74vUNQsURE1XjCty(QHRE8KgoxDccaHG5TlCWnXPxJx9msEG2rA4C1vP(XHnn1jWwtyBGcBHW2F7)ZwMgesdNsyJq98y7Cl)SLJIWhzZLwrHW25w(H0cBWfeCg0sp(SPryKzZLA2ktVJcNeE1FGwqqhx9VyJGY2fo0KQ0iGcnFtHZJnTSTeGoCtyLMGBLoLqaBAzRiicc2bHeespBawe9qyJsSr1QMZMw2oWgbsNC7jxtyK3UuVrVJcNewXjCtyMnTS9fBU0kk1eg5Tl1B07OWjHvAh20YwgDPvuQl4KrrIkTdBE8WMlTIsTiaa4zmV9XcIahCJZFmpSahPs7WMhpS9fBlbOd3ewj94NWTeaFuytlBz0LwrPs(7LkTdBhVY90t8D1RooHBcZxnC1FGwqqhxDckBx4qtQsJak08nfop20Y2sa6WnHvAcUv6ucbSPLTIGiiyhesqi9Sbyr0dHnkXgvRAoBAzlJU0kkvFaD2h3fH8(R0oSPLTVyZLwrPMWiVDPEJEhfojSs7WMw2arN34cosnYzsTh28ITvC1JN0W5QtqaiemVDHdUjo9A8k3t187QxDCc3eMVA4QhpPHZvNGaqiyE7chCtC614vp1dUF5R(NvC1FGwqqhxDcKo52tUUgx6HSHqQGyQh)koHBcZSPLnxAfL6ACPhYgcPcIPE8Rz455QNrYd0osdNRUgxcYMUg0ztGSrOlkGdBA84spFtyJkaivqm1JpBTcBudPz7pwq2KFKncKo52tUEL7PQ03vV64eUjmF1WvpEsdNRUsmBOYE90li5QNrYd0osdNRUMog2GkSPXp9csyle2(OsxoBejERjSbvytJZoNXHnnKImsydcyl8JEicBQOC2Ka4JcPE1FGwqqhx9La0HBcR0eCR0PecytlBhyZLwrP(35moB3uKrsLiXBnBEPMTpQ0S5XdBhy7l2Cane0c1BaucPHdBAzJ4GP0wcGpkKQsmBOYE90liHnVuZwzzRC2icgj5hZva0Ngz7iBhVY90pu9U6vhNWnH5RgU6XtA4C1vIzdv2RNEbjx9msEG2rA4C110XWguHnn(PxqcBcKTWXjrnBoWMahcBTcB9epPxq2GdBXqnBsa8rHTdqaBXqnBUjeZ94ZMeaFuiSDULF2Cane0c1SbGsinCoYwiSv2vV6pqliOJRE8KEb3zOuZyKtuVDGnbo7muyJsSfpPxWnoyrJe20Y2b2(InhqdbTq9gaLqA4WMhpSLHs1paaOGvPFR7XNnpEyldLkG2rObyv636E8z7iBAzBjaD4MWknb3kDkHa20YgXbtPTeaFuivLy2qL96PxqcBEPMTYEL7PF(Cx9QJt4MW8vdx9hOfe0XvFjaD4MWknb3kDkHa20Y2sa6WnH1fCYOiX(bHPm88Sbyr0dHnVy7dvV6XtA4C1X3pSh)naDaDrm5RCp9df3vV64eUjmF1Wv)bAbbDC1xcqhUjSstWTsNsiGnTSDGTIGiiyhesqi9Sbyr0dHn1Srv20Y2xSbOhubc8XAgclCtrgR4eUjmZMhpS5sROuDt9KjDgR0oSD8QhpPHZvpkCPj)x5E6NYEx9QJt4MW8vdx94jnCU6f0sNcbV6pQFjClbWhfY90px9hOfe0XvFjaD4MWknb3kDkHa20YgXbtPTeaFuivLy2qL96PxqcBQzJIREgjpq7inCU6RgULwtrlDkeKnbYw44KOMnQig5e1SrLGnboSfcBuWMeaFuix5E6hvCx9QJt4MW8vdx9hOfe0XvFjaD4MWknb3kDkHGRE8Kgox9cAPtHGx5kx9xMCx9E6N7QxDCc3eMVA4QhpPHZvViaRX8wbc2zmK)REQhC)Yx9p1vC1Fu)s4wcGpkK7PFU6pqliOJRoi68gxWrQrotQ0oSPLTdS9fBlbOd3ewj94NWTeaFuyZJh2Ka4Jsv6cClWDUr2OeBLLQSDKnTSDGnja(OuLUa3cCNBKnkX2dw4c3oWEesnJk9Rf2ojBFQRGnpEy7blCHBhypcPMrL(1cBEPMTNZUi8EtCWjZ2XREgjpq7inCU6uHkSf5mHTaGSr7ucBKPDq2KFKn4GSDULF2sWZiryB1vPIv204sq2o)JdBzQ7XNnLGiiGn5pg2kfvITmQ0Vwydcy7Cl)qAHTyOMTsrLQx5Ekf3vV64eUjmF1WvpEsdNRErawJ5TceSZyi)x9msEG2rA4C1PcvyBGSf5mHTZDkXwUr2o3YFpSj)iBd6TWwzPkPe2OjiBAkfQiBkqaBfH3SvkQuLTtqeSWrytGSrOEESDULF200PWhtPqA4WwRWMdKqA3ewV6pqliOJRoi68gxWrQrotQ9WMxSvwQYwPzdeDEJl4i1iNj1mniKgoSPLThSWfUDG9iKAgv6xlS5LA2Eo7IW7nXbNmBAz7aBFX2dUGtmsDbh5NAaBE8W2b2YOlTIsvjf(ykfsdNkTdBE8W2dctz45PQKcFmLcPHtfGfrpe28ITpRGTJSPLTdSjrchP(aDbboBblCqIuXjCtyMnpEy7l2EqykdppvYFVubyKPMTJSD8k3tl7D1RooHBcZxnC1HoxDckx94jnCU6lbOd3eE1xIenE1)Injs4i1P9)fIeP1iOIt4MWmBE8W2xSjrchPIEtIXNUNqWkoHBcZS5XdBpimLHNNk6njgF6EcbRaSi6HWgLyBfSvA2OGTtYMejCKAgrheSjciKWhlQ4eUjmF1Zi5bAhPHZvxN65XMMGtgfjy7Cpz4z2o3YpBN2()crI0AeuEz6njgF6EcbzRvylCCs9lCt4vFja7jkWR(cozuKypT)VqKiTgb7hCYT0W5k3tvXD1RooHBcZxnC1HoxDckx94jnCU6lbOd3eE1xIenE1)Injs4i1IGiiyhesqi9uXjCtyMnpEyldLQFaaqbRs)w3JpBE8W2dUGtmsDbh5NAaBAz7blCHBhypcPMrL(1cBQzJQx9msEG2rA4C1vPIwydoSPj4Krrc2uGa2OYbaafKTZT8ZMM6ekHn6jHecBNr2caYwiSveEZwPOsSPabSPPtHpMsH0W5QVeG9ef4vFbNmksSlI9do5wA4CL7PR4U6vhNWnH5RgU6qNRobLRE8Kgox9La0HBcV6lbyprbE1xWjJIe7hCbNyK9do5wA4C1FGwqqhx9hCbNyK6AQbDmS5XdBp4coXi1bFayccYS5XdBp4coXi1bo4vpJKhODKgoxDDQNhBAcozuKGTZT8ZMMof(ykfsdh2IjZMo6qAcBbHTeC8zliSDgz7mC(wylbjiBbBVGiSbxqaBYpYMs7)lSLPbH0W5QVejA8Q)5k3tvj3vV64eUjmF1Wvh6C1jOC1JN0W5QVeGoCt4vFjs04vxjbHa2oW2b2uA)FzdWIOhcBLMnkOkBhzJYSDGTpuqv2ojBlbOd3ewxWjJIe7xgW2r2oYMxSPKGqaBhy7aBkT)VSbyr0dHTsZgfuLTsZ2dctz45PQKcFmLcPHtfGfrpe2oYgLz7aBFOGQSDs2wcqhUjSUGtgfj2VmGTJSDKnTS9GWugEEQkPWhtPqA4ubyr0dHnVy7dvzZJh2CPvuQkPWhtPqA4SDPvuQ0oS5XdBz0LwrPQKcFmLcPHtL2HnpEyZfsiSPLnL2)x2aSi6HWgLyJcQE1FGwqqhx9hCbNyK6coYp1GR(sa2tuGx9fCYOiX(bxWjgz)GtULgox5E6j(U6vhNWnH5RgU6qNRobLRE8Kgox9La0HBcV6lrIgV6kjieW2b2oWMs7)lBawe9qyR0Srbvz7iBuMTdS9HcQY2jzBjaD4MW6cozuKy)Ya2oY2r28InLeecy7aBhytP9)LnalIEiSvA2OGQSvA2Eqykdppvc6qAsfGfrpe2oYgLz7aBFOGQSDs2wcqhUjSUGtgfj2VmGTJSDKnpEyldLkbDinPk9BDp(S5XdBUqcHnTSP0()YgGfrpe2OeBuq1R(d0cc64Q)Gl4eJuN2)x2kbE1xcWEIc8QVGtgfj2p4coXi7hCYT0W5k3t187QxDCc3eMVA4QNrYd0osdNRUMoHK)hiue2uGa2Os0eHoHSvMaAhPHdBTcBduyJiyKKFmZgeWwpSfS9GWugEEy7r9lHx9hOfe0Xv)aBeiDYTNC1HMi0jCJaAhPHtfNWnHz284HncKo52tUUatH0jCtGPfCKkoHBcZSDKnTS9fBebJK8J5AKsSPLTVylJU0kk1fCYOirL2HnTSveebb7GqccPNnalIEiSPMnQYMw2oWgoiWN6Q0f4wG7IW79dw42dMzZl2OGnpEy7l2YOlTIsL83lvAh2oE17rqaG2r2TYvNaPtU9KRlWuiDc3eyAbh5Q3JGaaTJS7Icm3HGx9px94jnCU6kjK8)aHIC17rqaG2r2(jOBKU6FUY9uv67QxDCc3eMVA4QhpPHZvxjf(ykfsdNREgjpq7inCU66upp200PWhtPqA4W25w(zttWjJIeSfe2sWXNTGW2zKTZW5BHTeKGSfS9cIWgCbbSj)iBkT)VWwMgesdh2oabS1kSPj4Krrc2o3PeBpybYMB8wZw4h9q5MWMa99tyMnOIYX6v)bAbbDC1)InIGrs(XCfa9Pr20Y2b2wcqhUjSUGtgfj2pimLHNNnalIEiSrj2klBAzBjaD4MW6cozuKyxe7hCYT0WHnTSHkk4t6fC)GfUWTdShHWMxQztfSPLnja(OuLUa3cCNBKnVy7dvzZJh2YOlTIsDbNmksuPDyZJh2CHecBAztP9)LnalIEiSrj2OqfSD8k3t)q17QxDCc3eMVA4Q)aTGGoU6FXgrWij)yUcG(0iBAzdvuWN0l4(blCHBhypcHnVuZMkytlBhytjbHa2oW2b2uA)FzdWIOhcBLMnkubBhzJYSDGT4jnC2pimLHNh2ojBlbOd3ewvsHpMsH0Wz)Ya2oY2r28InLeecy7aBhytP9)LnalIEiSvA2OqfSvA2wcqhUjSUGtgfj2pimLHNNnalIEiSDKnkZ2b2IN0Wz)GWugEEy7KSTeGoCtyvjf(ykfsdN9ldy7iBhz74vpEsdNRUsk8XukKgox5E6Np3vV64eUjmF1WvpEsdNRobDin5QNrYd0osdNRUo1ZJnD0H0e2o3YpBAcozuKGTGWwco(Sfe2oJSDgoFlSLGeKTGTxqe2GliGn5hztP9)f2Y0GqA4ucBU0cBoaubbSjbWhfcBYFiSDUtj2s9cYwiSLWGiS9HQKR(d0cc64Q)fBebJK8J5ka6tJSPLTmuQ(baafSk9BDp(SPLTdS9GWugEEQl4KrrIkalIEiSrj2(WMw2Ka4Jsv6cClWDUr28ITpuLnpEylJU0kk1fCYOirL2HnpEyZfsiSPLnL2)x2aSi6HWgLy7dvz74vUN(HI7QxDCc3eMVA4Q)aTGGoU6FXgrWij)yUcG(0iBAz7aBkjieW2b2oWMs7)lBawe9qyR0S9HQSDKnkZw8Kgo7heMYWZdBhzZl2usqiGTdSDGnL2)x2aSi6HWwPz7dvzR0STeGoCtyDbNmksSFqykdppBawe9qy7iBuMT4jnC2pimLHNh2oY2XRE8KgoxDc6qAYvUN(PS3vV64eUjmF1Wvh6C1jOC1JN0W5QVeGoCt4vFjs04v)l2icgj5hZva0NgztlBzOub0ocnaRs)w3JpBAz7l2YOlTIsDbNmksuPDytlBlbOd3ewxWjJIe7P9)fIeP1iy)GtULgoSPLTLa0HBcRl4KrrIDrSFWj3sdh20Y2sa6WnH1fCYOiX(bxWjgz)GtULgox9msEG2rA4C11eCYOibBcKnxKnAcMzRvyBGcBebJK8J5syRmODeAaYwtyJ2Pe2IjZwKsSbLFeWMejCek)Gl4eJW2do5wA4qylaiBKqAIsJ5R(sa2tuGx9fCYOiX(bNClnCUY90pQ4U6vhNWnH5RgU6zK8aTJ0W5QRt98yt(r2Cane0c1SrKqyZLwrHnb0ZAuy7Cl)SPj4KrrIsydk)i4Ctq2OjiBWHTheMYWZZv)bAbbDC1pW2xSTeGoCtyLMGBb0ZAu2F2oaCVGtgfjyZJh2wcqhUjSUGtgfj2p4KBPHdBAz7aBpimLHNN6cozuKOcWIOhcBuInkyZJh2wcqhUjSUGtgfj2pimLHNNnalIEiS5fBcON1OuLp1heMYWZtntdcPHdBuMnky7iBE8WMs7)lBawe9qyJsQzJcQY2r20Y2b2wcqhUjSkGEwJYMq982KeuytnBFytlBhylJU0kk1fCYOirL2HnpEyBjaD4MWknb3cON1OS)SDa4EbNmksWMhpSP0()YgGfrpe2OKA2OGQSDKnpEy7aBlbOd3ewfqpRrztOEEBsckSPMnkytlBhy7l2eqpRrPkuuFqykdppvagzQzZJh2wcqhUjSUGtgfj2pimLHNNnalIEiS5fBuqv2oY2r284HTVyBjaD4MWQa6znkBc1ZBtsqHTJxDsckKRUa6znkFU6XtA4C1fqpRr5ZvUN(zf3vV64eUjmF1WvpEsdNRUa6znkuC1FGwqqhx9dS9fBlbOd3ewPj4wa9SgLnfBhaUxWjJIeS5XdBlbOd3ewxWjJIe7hCYT0WHnTSDGTheMYWZtDbNmksubyr0dHnkXgfS5XdBlbOd3ewxWjJIe7heMYWZZgGfrpe28Inb0ZAuQcf1heMYWZtntdcPHdBuMnky7iBE8WMs7)lBawe9qyJsQzJcQY2r20Y2b2wcqhUjSkGEwJYMq982KeuytnBuWMw2oWwgDPvuQl4KrrIkTdBE8W2sa6WnHvAcUfqpRrztX2bG7fCYOibBE8WMs7)lBawe9qyJsQzJcQY2r284HTdSTeGoCtyva9SgLnH65TjjOWMA2(WMw2oW2xSjGEwJsv(uFqykdppvagzQzZJh2wcqhUjSUGtgfj2pimLHNNnalIEiS5fBuqv2oY2r284HTVyBjaD4MWQa6znkBc1ZBtsqHTJxDsckKRUa6znkuCL7PFuj3vV64eUjmF1WvpEsdNR(cozuK4QNrYd0osdNRovOcB0KE8zBvk0C2uHZRe2YykOMn6r6eBYpY2GElSrfHRYM0V1S1kSDgz7fdB(rpSvabiBYFmSfSvwngB)brq2it4q(HcBpyHtaWmBcKn5hz7rda4iSj9BnBlrIgV6pqliOJR(sa6WnH1fCYOiX(bNClnCytlBhy7l2iOSDHdnPkncOqZ3QW5XMhpSDGTmuQ(baafS(heb3opHnVuZ2b2YqP6haauW6FqeC78K9GElBPFRzR0Svw2oY2r20Y2b2YqPcODeAaw)dIGBNNWMxQz7aBzOub0ocnaR)brWTZt2d6TSL(TMTsZwzz7iBhz74vUN(5eFx9QJt4MW8vdx94jnCU6O3Ky8P7je8QNrYd0osdNREz6njgF6Ecbz78poSnqHnIGrs(XmBXKzZfk)Svg0ocnazlMmBu5aaGcYwaq2ODytbcylbhF2Wbs7)xV6pqliOJR(xSremsYpMRaOpnYMw2oW2xSLHs1paaOGvaQaqYF4Mq20YwgkvaTJqdWkalIEiSDs2oW2h2kNnckBx4qtQsJak08TkCESDs2YOlTIsDbNmksuPDy7iBEXMkyRC2ubBNKTNZUi8EtCWjZMhpSLHsfq7i0aScWIOhcBNKnQwxbBEXMeaFuQsxGBbUZnY2r20YMeaFuQsxGBbUZnYMxSPIRCp9JMFx9QJt4MW8vdx94jnCU6K)E5QNrYd0osdNRU(FVWwRWgveUkHTaGSr7ucBTcBN2()cBA6azleblCe2eiBeQNhBNB5NnD0H0e2Ga20eCYOibBTcBNr2odNVf2ohebzRacq2K)yy7pskSP)3lFty7bHPm88C1FGwqqhx9Vy7bxWjgPoT)VSvcKnTS9fBz0LwrPs(7LkTdBAzldLQFaaqbRs)w3JpBAzldLkG2rObyv636E8ztlBhy7l2KiHJuFGUGaNTGfoirQ4eUjmZMhpS9fBeu2UWHMuLgbuO5BkCESPLTLa0HBcRKE8t4wcGpkS5XdBzOuFGUGaNTGfoirQs)w3JpBhVY90pQ03vV64eUjmF1Wv)bAbbDC1FWfCIrQt7)lBLaztlBFXwgDPvuQK)EPs7WMw2YqP6haauWQ0V194ZMw2YqPcODeAawL(TUhF20Y2b2oW2dctz45PsqhstQamYuZMhpS9GWugEEQe0H0KkalIEiS5fBFOGTJSvoBhy7bHPm88uxWjJIevagzQzZJh2wcqhUjSUGtgfj2pimLHNNnalIEiS5fBFOGTJSPMnky74vpEsdNRo5VxUY9ukO6D1RooHBcZxnC1FGwqqhxDxAfLQBccZjAIuby8e284HnxiHWMw2uA)FzdWIOhcBuITYsv284HTm6sROuxWjJIevANRE8KgoxDhO0W5k3tP4ZD1RooHBcZxnC1FGwqqhx9m6sROuxWjJIevANRE8KgoxD3eeM3k0aQVY9ukO4U6vhNWnH5RgU6pqliOJREgDPvuQl4KrrIkTZvpEsdNRUlciiyDp(x5EkfL9U6vhNWnH5RgU6pqliOJREgDPvuQl4KrrIkTZvpEsdNRUsdq3eeMVY9ukuXD1RooHBcZxnC1FGwqqhx9m6sROuxWjJIevANRE8Kgox9yEirarA)Iu6k3tPyf3vV64eUjmF1Wv)bAbbDC1)InIGrs(XCnsj20YwrqeeSdcjiKE2aSi6HWMA2O6vpEsdNR(lsPD8Kgo7utKREQjYEIc8QVett(VY9ukuj3vV64eUjmF1WvpEsdNR(5EYKxa2N)rHiWbV6pqliOJRoXbtPTeaFuivLy2qL96PxqcBEXwgjnaZBja(OqyZJh2arN34cosnYzsTh28InvcvzZJh2CHecBAztP9)LnalIEiSrj2oXx9jkWR(5EYKxa2N)rHiWbVY9ukoX3vV64eUjmF1WvpEsdNR(lE)4gQSJ3jIUbyElami0aKC1FGwqqhxDxAfLA8or0naZ7WBSs7WMw2oWgXbtPTeaFuivLy2qL96PxqcBQz7dBAzdeDEJl4i1iNj1EyZl2ujuLnpEyJ4GP0wcGpkKQsmBOYE90liHnVy7dBhzZJh2CHecBAztP9)LnalIEiSrj2Oyfx9jkWR(lE)4gQSJ3jIUbyElami0aKCL7PuO53vV64eUjmF1WvpEsdNRo5faYgQSvaHGGjsBIaAf8Q)aTGGoU6FXMlTIsL8cazdv2kGqqWePnraTcUvrL2HnpEyZfsiSPLnL2)x2aSi6HWgLyRSu9QprbE1jVaq2qLTcieemrAteqRGx5kx9muUREp9ZD1RooHBcZxnC1HoxDckx94jnCU6lbOd3eE1xIenE1Dane0c1BaucPHdBAz7aBzOu9daakyfGfrpe2OeBpimLHNNQFaaqbRzAqinCyZJh2wcqhUjScqFC2KqObHGz2oE1Zi5bAhPHZvxJ6IwyJGp4Kda1SrLdaakiHnfiGnhqdbTqnBaOesdh2Af2oJS9hliBLDfSHdc8PMna6JdBqaBu5aaGcY25oLyd92PbiBWHn5hzZb0fbGA2Ka4JYvFja7jkWRozD7SFu)s42paaOGx5Ekf3vV64eUjmF1Wvh6C1jOC1JN0W5QVeGoCt4vFjs04v3b0qqluVbqjKgoSPLTdSLrxAfLk5VxQ0oSPLnIdMsBja(OqQkXSHk71tVGe28InkyZJh2wcqhUjScqFC2KqObHGz2oE1Zi5bAhPHZvxJ6IwyJGp4Kda1Svg0ocnajSPabS5aAiOfQzdaLqA4WwRW2zKT)ybzRSRGnCqGp1SbqFCydcyt)VxyRjSr7WgCyJIvl)QVeG9ef4vNSUD2pQFjCdODeAaEL7PL9U6vhNWnH5RgU6qNRobLRE8Kgox9La0HBcV6lrIgV6z0LwrPUGtgfjQ0oSPLTdSLrxAfLk5VxQ0oS5XdBfbrqWoiKGq6zdWIOhcBEXgvz7iBAzldLkG2rObyfGfrpe28InkU6zK8aTJ0W5QRrDrlSvg0ocnajS1kSPj4KrrIY1)7fkRPcIGa2obcjiKEyRjSr7Wwmz2oJS9hliBuuoBe8bNmHTeQiSbh2KFKTYG2rObiBur4Qx9LaSNOaV6K1TZgq7i0a8k3tvXD1RooHBcZxnC1JN0W5Q7haauWREgjpq7inCU66o4RJeBu5aaGcYwmz2kdAhHgGSrqH2HnhqdbSjq2ktVjX4t3tiiBVGix9hOfe0XvxIeosf9MeJpDpHGvCc3eMztlBFX25oL2jib3O3Ky8P7jeKnTSLHs1paaOGvNc6K0oPgbSrj1S9HnTS9GWugEEQO3Ky8P7jeScWIOhcBuInkytlBehmL2sa8rHuvIzdv2RNEbjSPMTpSPLnq05nUGJuJCMu7HnVytLWMw2YqP6haauWkalIEiSDs2OADfSrj2Ka4Jsv6cClWDUXRCpDf3vV64eUjmF1Wv)bAbbDC1LiHJurVjX4t3tiyfNWnHz20Y2xSDUtPDcsWn6njgF6EcbztlBzOub0ocnaRof0jPDsncyJsQz7dBAz7aBOIc(KEb3pyHlC7a7riS5LA2Eo7IW7nXbNmBAz7bHPm88urVjX4t3tiyfGfrpe2OeBFytlBzOub0ocnaRaSi6HW2jzJQ1vWgLytcGpkvPlWTa35gz74vpEsdNRoG2rOb4vUNQsURE1XjCty(QHRE8KgoxDhimTbibsdE4vpJKhODKgoxDQCaaqbzJ2znIoLWwKiq2eqJe2eiB0eKTwyliSfSrCWxhj28XbbHabSPabSj)iBPGiSvkQeBUOceGSfSP0tt(rWvxbc2d6TCp9ZvUNEIVRE1XjCty(QHR(d0cc64Qdqfas(d3eYMw2EWcx42b2JqQzuPFTWMxQz7dBAz7aBof0jPDsncyJsQz7dBE8WgalIEiSrj1Sj9B9w6cKnTSrCWuAlbWhfsvjMnuzVE6fKWMxQzRSSDKnTSDGTVy7CNs7eKGB0Bsm(09ecYMhpSbWIOhcBusnBs)wVLUaz7KSrbBAzJ4GP0wcGpkKQsmBOYE90liHnVuZwzz7iBAz7aBsa8rPkDbUf4o3iBLMnawe9qy7iBEXMkytlBfbrqWoiKGq6zdWIOhcBQzJQx94jnCU6(baaf8k3t187QxDCc3eMVA4QRab7b9wUN(5QhpPHZv3bctBasG0GhEL7PQ03vV64eUjmF1WvpEsdNRUFaaqbV6zK8aTJ0W5QxMbirnBaubGKF2OYbaafKTwHTwyRjSfcBj4z2Y0GqA4W2bxAHTbkSrnkS5etgl63r2cHn5hzdNmBqf20eCYOibBNB5Nnv48U6pqliOJRobLTlCOjvPrafA(wfop20YwgDPvuQl4KrrIkTdBAzlJU0kk1fCYOirfGfrpe2OeBLLnTSbWIOhcBuITtmBAz7blCHBhypcPMrL(1cBEPMTpSPLTdS5uqNK2j1iGnkPMTpS5XdBaSi6HWgLuZM0V1BPlq20YgXbtPTeaFuivLy2qL96PxqcBEPMTYY2r20Y2b2Ka4Jsv6cClWDUr2knBaSi6HW2r28InkUY90pu9U6vhNWnH5RgU6kqWEqVL7PFU6XtA4C1DGW0gGein4Hx5E6Np3vV64eUjmF1WvpEsdNRUFaaqbV6pqliOJR(xSTeGoCtyLSUD2pQFjC7haauq20Ygavai5pCtiBAz7blCHBhypcPMrL(1cBEPMTpSPLTdS5uqNK2j1iGnkPMTpS5XdBaSi6HWgLuZM0V1BPlq20YgXbtPTeaFuivLy2qL96PxqcBEPMTYY2r20Y2b2(ITZDkTtqcUrVjX4t3tiiBE8WgalIEiSrj1Sj9B9w6cKTtYgfSPLnIdMsBja(OqQkXSHk71tVGe28snBLLTJSPLTdSjbWhLQ0f4wG7CJSvA2ayr0dHTJS5fBFOGnTSveebb7GqccPNnalIEiSPMnQE1Fu)s4wcGpkK7PFUY90puCx9QJt4MW8vdx94jnCU6pqxqGZwWchKix9h1VeULa4Jc5E6NR(d0cc64QtCWuAlbWhfcBEPMnkytlBOIc(KEb3pyHlC7a7riS5LA2ubBAzdhe4tDfG(4SFWc3EWmBEXgfuLnTSDGTVy7bHPm88uxWjJIevagzQzZJh2YqPcODeAawL(TUhF2oYMw2ayr0dHnkX2b2OGTYzRSSDs2oWgXbtPTeaFuiS5LA2ubBhz7iBNKTdS9HTsZ2b2iOSDHdnPkncOqZ3QW5X2jzlJU0kk1fCYOirL2HTtYgvRRGTJSD8QNrYd0osdNREPaDbboSTkw4GeHn4WwbDsANeYMeaFuiSfcBQOC2kfvITZ)4WgGEME8zdslS1dBuu6vqyliSLGJpBbHTZiB)XcYgoqA)F2aOpoSftMTaGZ3cBeuKE8zJ2HnfiGnnbNmksCL7PFk7D1RooHBcZxnC1JN0W5QdODeAaE1Zi5bAhPHZvxJhrh2ODyRmODeAaYwiSPIYzdoSfPeBsa8rHW2HZ)4WwQx6XNTeC8zdhiT)pBXKzBGcBKjCi)q54v)bAbbDC1)ITLa0HBcRK1TZgq7i0aKnTSHkk4t6fC)GfUWTdShHWMxQztfSPLnaQaqYF4Mq20Y2b2CkOts7KAeWgLuZ2h284Hnawe9qyJsQzt636T0fiBAzJ4GP0wcGpkKQsmBOYE90liHnVuZwzz7iBAz7aBFX25oL2jib3O3Ky8P7jeKnpEydGfrpe2OKA2K(TElDbY2jzJc20YgXbtPTeaFuivLy2qL96PxqcBEPMTYY2r20YMeaFuQsxGBbUZnYwPzdGfrpe28ITdSPc2kNTdSbOhubc8XAoi)94Vjpi9KbyQIt4MWmBNKTvW2r2kNTdSbOhubc8XAgclCtrgR4eUjmZ2jzBfSDKTYz7aBlbOd3ewbOpoBsi0GqWmBNKnvcBhz74vUN(rf3vV64eUjmF1WvpEsdNRoG2rOb4vpJKhODKgox9YmajQzdGkaK8Zwzq7i0aKTwHTwyRjSfcBj4z2Y0GqA4W2bxAHTbkSrnkS5etgl63r2cHn5hzdNmBqf20eCYOibBNB5Nnv48U6pqliOJRobLTlCOjvPrafA(wfop20YgQOGpPxW9dw4c3oWEecBEPMnvWMw2YOlTIsDbNmksuPDytlBz0LwrPUGtgfjQaSi6HWgLyRSSPLnawe9qyJsSP5SPLnja(OuLUa3cCNBKTsZgalIEiS5fBhytfSvoBhydqpOce4J1Cq(7XFtEq6jdWufNWnHz2ojBRGTJSvoBhydqpOce4J1mew4MImwXjCtyMTtY2ky7iBLZ2b2wcqhUjScqFC2KqObHGz2ojBQe2oY2r2OmBuCL7PFwXD1RooHBcZxnC1JN0W5QdODeAaE1FGwqqhx9VyBjaD4MWkzD7SFu)s4gq7i0aKnTS9fBlbOd3ewjRBNnG2rObiBAzdvuWN0l4(blCHBhypcHnVuZMkytlBaubGK)WnHSPLTdS5uqNK2j1iGnkPMTpS5XdBaSi6HWgLuZM0V1BPlq20YgXbtPTeaFuivLy2qL96PxqcBEPMTYY2r20Y2b2(ITZDkTtqcUrVjX4t3tiiBE8WgalIEiSrj1Sj9B9w6cKTtYgfSPLnIdMsBja(OqQkXSHk71tVGe28snBLLTJSPLnja(OuLUa3cCNBKTsZgalIEiS5fBhytfSvoBhydqpOce4J1Cq(7XFtEq6jdWufNWnHz2ojBRGTJSvoBhydqpOce4J1mew4MImwXjCtyMTtY2ky7iBLZ2b2wcqhUjScqFC2KqObHGz2ojBQe2oY2XR(J6xc3sa8rHCp9ZvUN(rLCx9QJt4MW8vdx94jnCU6pqxqGZwWchKix9msEG2rA4C110rk5gV1SDcWYKTsb6ccCyBvSWbjcBNB5Nn5hzJefiBjOF)yliSfUWfSe2CPf2A)bc6XNn5hzdhe4tnBp4KBPHdHTwHTZiBbaNVf2Oj94Zwzq7i0a8Q)aTGGoU6ehmL2sa8rHWMxQzJc20YgQOGpPxW9dw4c3oWEecBEPMnvWMw2ayr0dHnkXgfSvoBLLTtY2b2ioykTLa4JcHnVuZMky74vUN(5eFx9QJt4MW8vdx94jnCU6pqxqGZwWchKix9msEG2rA4C1lfOliWHTvXchKiSbh20xLTwHTEyZjMmw0p2IjZ2GbirnBfH3SHdc8PMTyYS1kSvMZcoWc2odNVf2Yq2kGaKTCue(iBzAKnbY2QAGYAQt4Q)aTGGoU6ehmL2sa8rHWMA2(WMw2oW2xSbOhubc8XAoi)94Vjpi9KbyQIt4MWmBE8WMlTIsfqp4(meK3kairQ0oSDKnTSHkk4t6fC)GfUWTdShHWMxQz7aBpNDr49M4GtMTsZ2h2oYMw2aOcaj)HBcztlBFX25oL2jib3O3Ky8P7jeKnTSDGTVylJU0kkvYFVuPDyZJh2YOlTIs1hqN9XDriV)kalIEiS5fBuW2r20YMeaFuQsxGBbUZnYwPzdGfrpe28InvCLRCLR(ccinCUNsbvPGcQwwQQ5x9Zby6XNC1vPoHY4uQWtPYQmBST6pYwx4abcBkqaBFtemsYpM)MnaEIOBaMzJalq2cAbwecMz79hJpsQSQAupiBQqLzRuWzbbcMztVlkfBeQhj8MnngBcKnnIoyl3lnPHdBqheeceW2bkFKTdF8(yLvLvvL6ekJtPcpLkRYSX2Q)iBDHdeiSPabS99smn5)B2a4jIUbyMncSazlOfyriyMT3Fm(iPYQQr9GS9rLzRuWzbbcMz7Ba9GkqGpw1SVztGS9nGEqfiWhRAwfNWnH5Vz7afEFSYQQr9GSPsuz2kfCwqGGz2(gqpOce4Jvn7B2eiBFdOhubc8XQMvXjCty(B2o8X7JvwvwvvQtOmoLk8uQSkZgBR(JS1foqGWMceW23oa8blCd5B2a4jIUbyMncSazlOfyriyMT3Fm(iPYQQr9GSPcvMTsbNfeiyMTVjq6KBp5QM9nBcKTVjq6KBp5QMvXjCty(B2o8X7JvwvnQhKnvOYSvk4SGabZS9nbsNC7jx1SVztGS9nbsNC7jx1SkoHBcZFZwiSvMubOrSD4J3hRSQAupiBRqLzRuWzbbcMz7Ba9GkqGpw1SVztGS9nGEqfiWhRAwfNWnH5Vz7WhVpwzv1OEq2ujQmBLcoliqWmBFdOhubc8XQM9nBcKTVb0dQab(yvZQ4eUjm)nBh(49XkRQg1dY2jwLzRuWzbbcMz7Bb0ZAuQFQA23Sjq2(wa9SgLQ8PQzFZ2bv49XkRQg1dY2jwLzRuWzbbcMz7Bb0ZAuQuu1SVztGS9Ta6znkvHIQM9nBhkR3hRSQAupiBAUkZwPGZccemZ23cON1Ou)u1SVztGS9Ta6znkv5tvZ(MTdL17JvwvnQhKnnxLzRuWzbbcMz7Bb0ZAuQuu1SVztGS9Ta6znkvHIQM9nBhuH3hRSQAupiBQ0QmBLcoliqWmBFlGEwJs9tvZ(MnbY23cON1OuLpvn7B2oqH3hRSQAupiBFOQkZwPGZccemZ23cON1OuPOQzFZMaz7Bb0ZAuQcfvn7B2oqH3hRSQSQQuNqzCkv4PuzvMn2w9hzRlCGaHnfiGTVZnaFY3SbWteDdWmBeybYwqlWIqWmBV)y8rsLvvJ6bztZvz2kfCwqGGz2(MaPtU9KRA23Sjq2(MaPtU9KRAwfNWnH5Vz7WhVpwzv1OEq2(qHkZwPGZccemZ23a6bvGaFSQzFZMaz7Ba9GkqGpw1SkoHBcZFZ2HpEFSYQYQQsDcLXPuHNsLvz2yB1FKTUWbce2uGa2((LjFZgapr0naZSrGfiBbTalcbZS9(JXhjvwvnQhKnvIkZwPGZccemZMExuk2iups4nBAm2eiBAeDWwUxAsdh2GoiieiGTdu(iBhOW7JvwvnQhKTtSkZwPGZccemZMExuk2iups4nBAm2eiBAeDWwUxAsdh2GoiieiGTdu(iBhOW7JvwvnQhKnnxLzRuWzbbcMz7BcKo52tUQzFZMaz7BcKo52tUQzvCc3eM)MTdu49XkRQg1dY2hQQYSvk4SGabZSP3fLInc1JeEZMgJnbYMgrhSL7LM0WHnOdccbcy7aLpY2bk8(yLvvJ6bz7dfQmBLcoliqWmB6DrPyJq9iH3SPXytGSPr0bB5EPjnCyd6GGqGa2oq5JSDGcVpwzv1OEq2(qHkZwPGZccemZMExuk2iups4nBAm2eiBAeDWwUxAsdh2GoiieiGTdu(iBhOW7JvwvnQhKTpQqLzRuWzbbcMztVlkfBeQhj8MnngBcKnnIoyl3lnPHdBqheeceW2bkFKTdF8(yLvvJ6bz7Jkuz2kfCwqGGz2(wa9SgL6NQM9nBcKTVfqpRrPkFQA23SD4J3hRSQAupiBFuHkZwPGZccemZ23cON1OuPOQzFZMaz7Bb0ZAuQcfvn7B2o8X7JvwvnQhKTpRqLzRuWzbbcMztVlkfBeQhj8MnngBcKnnIoyl3lnPHdBqheeceW2bkFKTdF8(yLvvJ6bz7Zkuz2kfCwqGGz2(wa9SgL6NQM9nBcKTVfqpRrPkFQA23SD4J3hRSQAupiBFwHkZwPGZccemZ23cON1OuPOQzFZMaz7Bb0ZAuQcfvn7B2o8X7JvwvwvvQtOmoLk8uQSkZgBR(JS1foqGWMceW23zO8nBa8er3amZgbwGSf0cSiemZ27pgFKuzv1OEq2(uwvMTsbNfeiyMTVb0dQab(yvZ(MnbY23a6bvGaFSQzvCc3eM)MTdu49XkRQg1dY2hvOYSvk4SGabZSP3fLInc1JeEZMgJnbYMgrhSL7LM0WHnOdccbcy7aLpY2HpEFSYQQr9GS9rfQmBLcoliqWmBFdOhubc8XQM9nBcKTVb0dQab(yvZQ4eUjm)nBhOW7JvwvnQhKTpRqLzRuWzbbcMz7Ba9GkqGpw1SVztGS9nGEqfiWhRAwfNWnH5Vz7afEFSYQQr9GS95eRYSvk4SGabZS9nGEqfiWhRA23Sjq2(gqpOce4JvnRIt4MW83SD4J3hRSQAupiBFoXQmBLcoliqWmBFdOhCFgcYvnRIt4MW83Sjq2(2LwrPcOhCFgcYBnRs78nBh(49XkRkRkvyHdeiyMTtmBXtA4WwQjcPYQE1jo47EkfRqL(Q7aGkDcV6RCLSDcesqi9esdh2kdOpnYQUYvYMMkOMTpQOe2OGQuqbRkR6kxjBL6pgFKOYSQRCLSvA2obhNe1S9nra9t(MnLu4ZMazJalq2obQKgXMceSMWMazJeliBoa4djKE8zt6cSYQUYvYwPzJkcNVf20KyAYpB0tcje20t9dzlMmBuX(HSDUtj2sbrylbhFeWM8hdBAQGiiGTtGqccPNkR6kxjBLMTYatH3SPPtHpMsH0WHnkZMMGtgfjyJq98y7qRWMMGtgfjyRjSjqF)eMzdQOWgeWgCylylbhF2kfv8yLvDLRKTsZMMkwJSPPti5)bcfHTEeeaODe26HThSWne2Af2oJSPXbnryl3z2AHnfiGTfykKoHBcmTGJuzvx5kzR0SPXLGSPRbD2kGaKnbYgHUOaoSPXJl98nHnQaGubXup(S1kSrnKMT)ybzt(r2iq6KBp5kR6kxjBLMTsbNfeiSbOhCFgcYvfaKiSjq2CPvuQa6b3NHG8wbajsL2PYQUYvYwPz7eYzmZMkvpzYlaSPs9JcrGdwzvx5kzR0ST6zmwJz2ktVjX4t3tiiBcKnFuyJMGz2Af2Ogs)9cYMMGtgfjknjgF6EcbZvwvw1vUs2ktVXhTGz2Crfiaz7blCdHnx0VhsLTt49qhHW2aNs)hGcf6eBXtA4qydojQRSQXtA4qQoa8blCdrD44KOE7aBcCyvJN0WHuDa4dw4gs5QPSluKeM3kPGAmFUh)Ta9Uhw14jnCivha(GfUHuUAkxeG1yERab7mgYFjoa8blCdztWhCYe1FOAjTI6VEWfCIrQl4i)ud0cIoVXfCKAKZKApE9zfSQXtA4qQoa8blCdPC1uwjHK)hiuKsAf1eiDYTNC1HMi0jCJaAhPHJhpeiDYTNCDbMcPt4Matl4iSQXtA4qQoa8blCdPC1uEjaD4MWsMOavVGtgfj2VmOKLirJQ)u6da6bvGaFSMPjRphP1iGSDc59FYduTQIvu(bckBx4qtQsJak08TkCENKQ1phpEKvDLST6pYwSGGWhzRuuXYGTMWgvRuqbBU0cBzAKnbYM8JSvgNsLzBcHgGSbvyRuuj28XPe2OWB2K)MW2sKOr2AcBqhPlIeBkqaBeQNxp(SLG(9JvnEsdhs1bGpyHBiLRMYlbOd3ewYefOALu4JPuinC2VmOKLirJQ)u6da6bvGaFScDXCJZdpjvRQqfhzvxjBuruqqrpiBN)73pBhAf2IH6JSrKqyZLwrHnb0ZAuy7mY25ye2eiBHiyHJWMazJq98y7Cl)SPj4KrrIkRA8KgoKQdaFWc3qkxnLxcqhUjSKjkq1cON1OSjupVnjbLswIenQ(tjTIAb0ZAuQFQ)bztKqQXq9o7q0E4lb0ZAuQuu)dYMiHuJH6D2H4XJa6znk1p1heMYWZtntdcPHJxQfqpRrPsr9bHPm88uZ0GqA4C0Jhb0ZAuQFQnP2d5bOLWnH7teDmcDXoJl9d945WdUGtmsDbh5NAG2VeqpRrPsr9piBIesngQ3zhIwb0ZAuQFQnPs(Jm8SpiioBbkyXrw14jnCivha(GfUHuUAkVeGoCtyjtuGQfqpRrztOEEBsckLSejAunfL0kQfqpRrPsr9piBIesngQ3zhI2dFjGEwJs9t9piBIesngQ3zhIhpcON1OuPO(GWugEEQzAqinC8sa9SgL6N6dctz45PMPbH0W5OhpcON1OuPO2KApKhGwc3eUpr0Xi0f7mU0p0JNdp4coXi1fCKFQbA)sa9SgL6N6Fq2ejKAmuVZoeTcON1OuPO2Kk5pYWZ(GG4SfOGfhzvJN0WHuDa4dw4gs5QP8sa6WnHLmrbQMMGBb0ZAu2F2oaCVGtgfjkzjs0OAckBx4qtQsJak08TkCEApiGEwJs9t9piBIes9picUbH0JVhpcON1Ou)uBsThYdqlHBc3Ni6ye6IDgx6hEKvnEsdhs1bGpyHBiLRMYlbOd3ewYefOAAcUfqpRrztX2bG7fCYOirjlrIgvtqz7chAsvAeqHMVvHZt7bb0ZAuQuu)dYMiHu)dIGBqi947XJa6znkvkQnP2d5bOLWnH7teDmcDXoJl9dpYQgpPHdP6aWhSWnKYvtzIGrs(zvJN0WHuDa4dw4gs5QPmj1pChtEN7hwIdaFWc3q2e8bNmr9NsAf1FjrchPoT)VqKiTgbvCc3eM1cqfas(d3eYQYQUYvYwz6n(OfmZgUGaQzt6cKn5hzlEceWwtylwIofUjSYQgpPHdr96(TMvDLSvgirWij)S1kS5ajK2nHSDyGSTqNgeeUjKnCWIgjS1dBpyHBihzvJN0WHuUAktemsYpRA8KgoKYvt5La0HBclzIcunPh)eULa4JsjlrIgvtCWuAlbWhfsvjMnuzVE6fKqjkyvxjBLcw42dMzRmhe4tnBLb6JdBdIzmZMazJecnieKvnEsdhs5QP8sa6WnHLmrbQgG(4SjHqdcbZLSejAunoiWN6ka9Xz)GfU9GzVk7kyvJN0WHuUAkVeGoCtyjtuGQxWjJIe7heMYWZZgGfrpKswIenQ(bHPm88uxWjJIevawe9qo5sa6WnH1fCYOiX(LbSQXtA4qkxnLFrkTJN0WzNAIuYefOAIGrs(XCjeb0pr9NsAf1ebJK8J5ka6tJSQXtA4qkxnLFrkTJN0WzNAIuYefO6xMWQUs2Os0cB6dvKnAh26PLosjQztbcyRu0cBcKn5hzRu)bblHnaQaqYpBNB5NTYCwWbwWwRWwiSLGNzltdcPHdRA8KgoKYvtzsQF4oM8o3pSKwr9xU0kkvsQF4oM8o3pSs7O9blCHBhypcXl1FyvJN0WHuUAkJZcoWIsAf1U0kkvsQF4oM8o3pSs7O1LwrPss9d3XK35(Hvawe9qO0k0(GfUWTdShH4LAvWQgpPHdPC1u(fP0oEsdNDQjsjtuGQZqHvnEsdhs5QP8lsPD8Kgo7utKsMOavNBa(ew14jnCiLRMYb4fdUfiaGJusROghe4tDnJk9RfVu)zfLJdc8PUcqFC2pyHBpyMvnEsdhs5QPCaEXGBh6ebzvJN0WHuUAkNA)FHS14Go7xGJWQgpPHdPC1u2n83qLTa63AcRkR6kxjBLcctz45HWQUs2OcvylYzcBbazJ2Pe2it7GSj)iBWbz7Cl)SLGNrIW2QRsfRSPXLGSD(hh2Yu3JpBkbrqaBYFmSvkQeBzuPFTWgeW25w(H0cBXqnBLIkvzvJN0WHuFzI6IaSgZBfiyNXq(lj1dUFz1FQROKh1VeULa4Jcr9NsAf1GOZBCbhPg5mPs7O9WxlbOd3ewj94NWTeaFu84rcGpkvPlWTa35gPuzP6rThKa4Jsv6cClWDUrk9GfUWTdShHuZOs)A5KFQRWJNhSWfUDG9iKAgv6xlEP(5SlcV3ehCYhzvxjBuHkSnq2ICMW25oLyl3iBNB5Vh2KFKTb9wyRSuLucB0eKnnLcvKnfiGTIWB2kfvQY2jicw4iSjq2iupp2o3YpBA6u4JPuinCyRvyZbsiTBcRSQXtA4qQVmPC1uUiaRX8wbc2zmK)sAf1GOZBCbhPg5mP2JxLLQLgeDEJl4i1iNj1mniKgoAFWcx42b2JqQzuPFT4L6NZUi8EtCWjR9Wxp4coXi1fCKFQbE8CiJU0kkvLu4JPuinCQ0oE88GWugEEQkPWhtPqA4ubyr0dXRpR4O2dsKWrQpqxqGZwWchKivCc3eM945RheMYWZtL83lvagzQpEKvDLSPt98yttWjJIeSDUNm8mBNB5NTtB)FHirAnckVm9MeJpDpHGS1kSfooP(fUjKvnEsdhs9LjLRMYlbOd3ewYefO6fCYOiXEA)FHirAnc2p4KBPHtjlrIgv)LejCK60()crI0AeuXjCty2JNVKiHJurVjX4t3tiyfNWnHzpEEqykdppv0Bsm(09ecwbyr0dHsRO0uCsjs4i1mIoiyteqiHpwuXjCtyMvDLSPsfTWgCyttWjJIeSPabSrLdaakiBNB5Nnn1jucB0tcje2oJSfaKTqyRi8MTsrLytbcyttNcFmLcPHdRA8KgoK6ltkxnLxcqhUjSKjkq1l4KrrIDrSFWj3sdNswIenQ(ljs4i1IGiiyhesqi9uXjCty2JNmuQ(baafSk9BDp(E88Gl4eJuxWr(PgO9blCHBhypcPMrL(1IAQYQUs20PEESPj4Krrc2o3YpBA6u4JPuinCylMmB6OdPjSfe2sWXNTGW2zKTZW5BHTeKGSfS9cIWgCbbSj)iBkT)VWwMgesdhw14jnCi1xMuUAkVeGoCtyjtuGQxWjJIe7hCbNyK9do5wA4usRO(bxWjgPUMAqhJhpp4coXi1bFayccYE88Gl4eJuh4GLSejAu9hw14jnCi1xMuUAkVeGoCtyjtuGQxWjJIe7hCbNyK9do5wA4usRO(bxWjgPUGJ8tnOKLirJQvsqi4WbL2)x2aSi6HuAkO6rn2Hpuq1tUeGoCtyDbNmksSFzWXJEPKGqWHdkT)VSbyr0dP0uq1s)GWugEEQkPWhtPqA4ubyr0d5Og7WhkO6jxcqhUjSUGtgfj2Vm44rTpimLHNNQsk8XukKgovawe9q86dv94XLwrPQKcFmLcPHZ2LwrPs74XtgDPvuQkPWhtPqA4uPD84XfsiAvA)FzdWIOhcLOGQSQXtA4qQVmPC1uEjaD4MWsMOavVGtgfj2p4coXi7hCYT0WPKwr9dUGtmsDA)FzReyjlrIgvRKGqWHdkT)VSbyr0dP0uq1JASdFOGQNCjaD4MW6cozuKy)YGJh9sjbHGdhuA)FzdWIOhsPPGQL(bHPm88ujOdPjvawe9qoQXo8HcQEYLa0HBcRl4KrrI9ldoE0JNmuQe0H0KQ0V1947XJlKq0Q0()YgGfrpekrbvzvxjBA6es(FGqrytbcyJkrte6eYwzcODKgoS1kSnqHnIGrs(XmBqaB9WwW2dctz45HTh1VeYQgpPHdP(YKYvtzLes(FGqrkPvuFGaPtU9KRo0eHoHBeq7inC84HaPtU9KRlWuiDc3eyAbh5O2Vicgj5hZ1iL0(vgDPvuQl4KrrIkTJ2IGiiyhesqi9Sbyr0drnv1Eahe4tDv6cClWDr49(blC7bZErHhpFLrxAfLk5VxQ0ohlPhbbaAhz3ffyUdbv)PKEeeaODKTFc6gj1FkPhbbaAhz3kQjq6KBp56cmfsNWnbMwWryvxjB6upp200PWhtPqA4W25w(zttWjJIeSfe2sWXNTGW2zKTZW5BHTeKGSfS9cIWgCbbSj)iBkT)VWwMgesdh2oabS1kSPj4Krrc2o3PeBpybYMB8wZw4h9q5MWMa99tyMnOIYXkRA8KgoK6ltkxnLvsHpMsH0WPKwr9xebJK8J5ka6tJApSeGoCtyDbNmksSFqykdppBawe9qOuz1UeGoCtyDbNmksSlI9do5wA4OfvuWN0l4(blCHBhypcXl1QqReaFuQsxGBbUZn61hQ6XtgDPvuQl4KrrIkTJhpUqcrRs7)lBawe9qOefQ4iRA8KgoK6ltkxnLvsHpMsH0WPKwr9xebJK8J5ka6tJArff8j9cUFWcx42b2Jq8sTk0EqjbHGdhuA)FzdWIOhsPPqfh1yhEqykdppNCjaD4MWQsk8XukKgo7xgC8OxkjieC4Gs7)lBawe9qknfQO0lbOd3ewxWjJIe7heMYWZZgGfrpKJASdpimLHNNtUeGoCtyvjf(ykfsdN9ldoE8iR6kztN65XMo6qAcBNB5NnnbNmksWwqylbhF2ccBNr2odNVf2sqcYwW2licBWfeWM8JSP0()cBzAqinCkHnxAHnhaQGa2Ka4JcHn5pe2o3PeBPEbzle2syqe2(qvcRA8KgoK6ltkxnLjOdPjL0kQ)IiyKKFmxbqFAuBgkv)aaGcwL(TUhFThEqykdpp1fCYOirfGfrpek9rReaFuQsxGBbUZn61hQ6XtgDPvuQl4KrrIkTJhpUqcrRs7)lBawe9qO0hQEKvnEsdhs9LjLRMYe0H0KsAf1FremsYpMRaOpnQ9GsccbhoO0()YgGfrpKs)HQh1ypimLHNNJEPKGqWHdkT)VSbyr0dP0FOAPxcqhUjSUGtgfj2pimLHNNnalIEih1ypimLHNNJhlNT4jnCi1xMuUAktqhstkPvu)frWij)yUcG(0O2dkjieC4Gs7)lBawe9qk9hQEuJ9GWugEEo6LsccbhoO0()YgGfrpKs)HQLEjaD4MW6cozuKy)GWugEE2aSi6HCuJ9GWugEEoEKvDLSPj4Krrc2eiBUiB0emZwRW2af2icgj5hZLWwzq7i0aKTMWgTtjSftMTiLydk)iGnjs4iu(bxWjgHThCYT0WHWwaq2iH0eLgZSQXtA4qQVmPC1uEjaD4MWsMOavVGtgfj2p4KBPHtjlrIgv)frWij)yUcG(0O2muQaAhHgGvPFR7Xx7xz0LwrPUGtgfjQ0oAxcqhUjSUGtgfj2t7)lejsRrW(bNClnC0UeGoCtyDbNmksSlI9do5wA4ODjaD4MW6cozuKy)Gl4eJSFWj3sdhw1vYMo1ZJn5hzZb0qqluZgrcHnxAff2eqpRrHTZT8ZMMGtgfjkHnO8JGZnbzJMGSbh2EqykdppSQXtA4qQVmPC1uMMG7wWcsjKeuiQfqpRr5tjTI6dFTeGoCtyLMGBb0ZAu2F2oaCVGtgfj84zjaD4MW6cozuKy)GtULgoAp8GWugEEQl4KrrIkalIEiuIcpEwcqhUjSUGtgfj2pimLHNNnalIEiEjGEwJs9t9bHPm88uZ0GqA4OXO4OhpkT)VSbyr0dHsQPGQh1EyjaD4MWQa6znkBc1ZBtsqr9hThYOlTIsDbNmksuPD84zjaD4MWknb3cON1OS)SDa4EbNmks4XJs7)lBawe9qOKAkO6rpEoSeGoCtyva9SgLnH65TjjOOMcTh(sa9SgLkf1heMYWZtfGrMApEwcqhUjSUGtgfj2pimLHNNnalIEiErbvpE0JNVwcqhUjSkGEwJYMq982KeuoYQgpPHdP(YKYvtzAcUBbliLqsqHOwa9SgfkkPvuF4RLa0HBcR0eClGEwJYMITda3l4KrrcpEwcqhUjSUGtgfj2p4KBPHJ2dpimLHNN6cozuKOcWIOhcLOWJNLa0HBcRl4KrrI9dctz45zdWIOhIxcON1OuPO(GWugEEQzAqinC0yuC0JhL2)x2aSi6Hqj1uq1JApSeGoCtyva9SgLnH65TjjOOMcThYOlTIsDbNmksuPD84zjaD4MWknb3cON1OSPy7aW9cozuKWJhL2)x2aSi6Hqj1uq1JE8CyjaD4MWQa6znkBc1ZBtsqr9hTh(sa9SgL6N6dctz45PcWitThplbOd3ewxWjJIe7heMYWZZgGfrpeVOGQhp6XZxlbOd3ewfqpRrztOEEBsckhzvxjBuHkSrt6XNTvPqZztfoVsylJPGA2OhPtSj)iBd6TWgveUkBs)wZwRW2zKTxmS5h9WwbeGSj)XWwWwz1yS9hebzJmHd5hkS9GfobaZSjq2KFKThnaGJWM0V1STejAKvnEsdhs9LjLRMYl4KrrIsAf1lbOd3ewxWjJIe7hCYT0Wr7HViOSDHdnPkncOqZ3QW55XZHmuQ(baafS(heb3opXl1hYqP6haauW6FqeC78K9GElBPFRlDzpEu7HmuQaAhHgG1)Gi425jEP(qgkvaTJqdW6FqeC78K9GElBPFRlDzpE8iR6kzRm9MeJpDpHGSD(hh2gOWgrWij)yMTyYS5cLF2kdAhHgGSftMnQCaaqbzlaiB0oSPabSLGJpB4aP9)RSQXtA4qQVmPC1ug9MeJpDpHGL0kQ)IiyKKFmxbqFAu7HVYqP6haauWkavai5pCtO2muQaAhHgGvawe9qo5HpLtqz7chAsvAeqHMVvHZ7Kz0LwrPUGtgfjQ0oh9sfLRIt(C2fH3BIdozpEYqPcODeAawbyr0d5KuTUcVKa4Jsv6cClWDUXJALa4Jsv6cClWDUrVubR6kzt)VxyRvyJkcxLWwaq2ODOceBTcBN2()cBA6azleblCe2eiBeQNhBNB5NnD0H0e2Ga20eCYOibBTcBNr2odNVf2ohebzRacq2K)yy7pskSP)3lFty7bHPm88WQgpPHdP(YKYvtzYFVusRO(RhCbNyK60()YwjqTFLrxAfLk5VxQ0oAZqP6haauWQ0V194RndLkG2rObyv636E81E4ljs4i1hOliWzlyHdsKkoHBcZE88fbLTlCOjvPrafA(McNN2La0HBcRKE8t4wcGpkE8KHs9b6ccC2cw4GePk9BDp(hzvJN0WHuFzs5QPm5VxkPvu)Gl4eJuN2)x2kbQ9Rm6sROuj)9sL2rBgkv)aaGcwL(TUhFTzOub0ocnaRs)w3JV2dhEqykdppvc6qAsfGrMApEEqykdppvc6qAsfGfrpeV(qXXYp8GWugEEQl4KrrIkaJm1E8SeGoCtyDbNmksSFqykdppBawe9q86dfhvtXrw14jnCi1xMuUAk7aLgoL0kQDPvuQUjimNOjsfGXt84XfsiAvA)FzdWIOhcLklv94jJU0kk1fCYOirL2HvnEsdhs9LjLRMYUjimVvObuxsROoJU0kk1fCYOirL2HvnEsdhs9LjLRMYUiGGG194xsROoJU0kk1fCYOirL2HvnEsdhs9LjLRMYknaDtqyUKwrDgDPvuQl4KrrIkTdRA8KgoK6ltkxnLJ5HebeP9lsPsAf1z0LwrPUGtgfjQ0oSQXtA4qQVmPC1u(fP0oEsdNDQjsjtuGQxIPj)L0kQ)IiyKKFmxJusBrqeeSdcjiKE2aSi6HOMQSQXtA4qQVmPC1uMMG7wWIsMOavFUNm5fG95FuicCWsAf1ehmL2sa8rHuvIzdv2RNEbjELrsdW8wcGpkepEarN34cosnYzsThVuju1JhxiHOvP9)LnalIEiu6eZQgpPHdP(YKYvtzAcUBblkzIcu9lE)4gQSJ3jIUbyElami0aKusRO2LwrPgVteDdW8o8gR0oApqCWuAlbWhfsvjMnuzVE6fKO(Jwq05nUGJuJCMu7Xlvcv94H4GP0wcGpkKQsmBOYE90liXRph94XfsiAvA)FzdWIOhcLOyfSQXtA4qQVmPC1uMMG7wWIsMOavtEbGSHkBfqiiyI0MiGwblPvu)LlTIsL8cazdv2kGqqWePnraTcUvrL2XJhxiHOvP9)LnalIEiuQSuLvLvLvDLRKnQydWNWwokcFKTWTtT0iHvDLSvMZcoWc2cHnvuoBhwr5SDULF2OI6hzRuuPkBuHffyUdbtuZgCyJIYztcGpkKsy7Cl)SPj4KrrIsydcy7Cl)STQgOceBq5hbNBcY25Of2uGa2iWcKnCqGp1v2oHebY25Of2Af2ktVj(S9GfUq2AcBpyrp(Sr7uzvJN0WHuZnaFIACwWbwusROgvuWN0l4(blCHBhypcXl1QOCjs4i1mIoiyteqiHpwuXjCtyw7Hm6sROuxWjJIevAhpEYOlTIsL83lvAhpEYOlTIsvjf(ykfsdNkTJhp4GaFQRzuPFTqj1uSIYXbb(uxbOpo7hSWThm7XZxlbOd3ewj94NWTeaFu84bvuWN0l4(blCHBhypcXRNZUi8EtCWjFu7HVKiHJurVjX4t3tiyfNWnHzpEEqykdppv0Bsm(09ecwbyr0dXlkoYQgpPHdPMBa(KYvt5La0HBclzIcunnb3kDkHGswIenQ(blCHBhypcPMrL(1IxF84bhe4tDnJk9RfkPMIvuooiWN6ka9Xz)GfU9GzpE(AjaD4MWkPh)eULa4JcR6kz7eCCsuZMUg0ztGSfPeBsa8rHW25w(H0cBbBz0LwrHTGWMdOHGwOUe2CaOcca94ZMeaFuiSLPUhF2iq4Ga2cfbbSj)iBoGUiauZMeaFuyvJN0WHuZnaFs5QPmbbGqW82fo4M40RXsAf1lbOd3ewPj4wPtjeO9RmuQeeacbZBx4GBItVg3zOuL(TUhFw14jnCi1CdWNuUAktqaiemVDHdUjo9ASKh1VeULa4Jcr9NsAf1lbOd3ewPj4wPtjeO9RmuQeeacbZBx4GBItVg3zOuL(TUhFw1vYMgpIoSPaGfS9chNE8z79haFKWgeWMlnyyle2KFKnCYSbvytP9)fcRA8KgoKAUb4tkxnLjiaecM3UWb3eNEnwsROEjaD4MWknb3kDkHaTfbrqWoiKGq6zdWIOhcLOAvZ1EWfsiAvA)FzdWIOhcLuVcpEEqykdppvccaHG5TlCWnXPxJ1IW797pa(iP0V)a4JKTciEsdNirj1uTsXkoYQUs2uP(XHnn1jWwtyBGcBHW2F7)ZwMgesdNsyJq98y7Cl)SLJIWhzZLwrHW25w(H0cBWfeCg0sp(SPryKzZLA2ktVJcNeYQgpPHdPMBa(KYvtzccaHG5TlCWnXPxJL0kQ)IGY2fo0KQ0iGcnFtHZt7sa6WnHvAcUv6ucbAlcIGGDqibH0ZgGfrpekr1QMR9absNC7jxtyK3UuVrVJcNewXjCtyw7xU0kk1eg5Tl1B07OWjHvAhTz0LwrPUGtgfjQ0oE84sROulcaaEgZBFSGiWb348hZdlWrQ0oE881sa6WnHvsp(jClbWhfTz0LwrPs(7LkTZrw14jnCi1CdWNuUAktqaiemVDHdUjo9ASKwrnbLTlCOjvPrafA(McNN2La0HBcR0eCR0Pec0weebb7GqccPNnalIEiuIQvnxBgDPvuQ(a6SpUlc59xPD0(LlTIsnHrE7s9g9okCsyL2rli68gxWrQrotQ941kyvxjBACjiB6AqNnbYgHUOaoSPXJl98nHnQaGubXup(S1kSrnKMT)ybzt(r2iq6KBp5kRA8KgoKAUb4tkxnLjiaecM3UWb3eNEnwsQhC)YQ)SIsAf1eiDYTNCDnU0dzdHubXup(ADPvuQRXLEiBiKkiM6XVMHNhw1vYMMog2GkSPXp9csyle2(OsxoBejERjSbvytJZoNXHnnKImsydcyl8JEicBQOC2Ka4JcPYQgpPHdPMBa(KYvtzLy2qL96PxqsjTI6La0HBcR0eCR0Pec0EWLwrP(35moB3uKrsLiXBTxQ)Os7XZHVCane0c1BaucPHJwIdMsBja(OqQkXSHk71tVGeVux2Yjcgj5hZva0NgpEKvDLSPPJHnOcBA8tVGe2eiBHJtIA2CGnboe2Af26jEsVGSbh2IHA2Ka4JcBhGa2IHA2CtiM7XNnja(Oqy7Cl)S5aAiOfQzdaLqA4CKTqyRSRYQgpPHdPMBa(KYvtzLy2qL96PxqsjTI64j9cUZqPMXiNOE7aBcC2zOqP4j9cUXblAKO9WxoGgcAH6nakH0WXJNmuQ(baafSk9BDp(E8KHsfq7i0aSk9BDp(h1UeGoCtyLMGBLoLqGwIdMsBja(OqQkXSHk71tVGeVuxww14jnCi1CdWNuUAkJVFyp(Ba6a6IyYL0kQxcqhUjSstWTsNsiq7sa6WnH1fCYOiX(bHPm88Sbyr0dXRpuLvnEsdhsn3a8jLRMYrHln5VKwr9sa6WnHvAcUv6ucbApueebb7GqccPNnalIEiQPQ2Va0dQab(yndHfUPiJE84sROuDt9KjDgR0ohzvxjBRgULwtrlDkeKnbYw44KOMnQig5e1SrLGnboSfcBuWMeaFuiSQXtA4qQ5gGpPC1uUGw6uiyjpQFjClbWhfI6pL0kQxcqhUjSstWTsNsiqlXbtPTeaFuivLy2qL96PxqIAkyvJN0WHuZnaFs5QPCbT0PqWsAf1lbOd3ewPj4wPtjeWQYQUYvYgvmkcFKn4ccyt6cKTWTtT0iHvDLSPrDrlSrWhCYbGA2OYbaafKWMceWMdOHGwOMnaucPHdBTcBNr2(JfKTYUc2Wbb(uZga9XHniGnQCaaqbz7CNsSHE70aKn4WM8JS5a6IaqnBsa8rHvnEsdhsndf1lbOd3ewYefOAY62z)O(LWTFaaqblzjs0OAhqdbTq9gaLqA4O9qgkv)aaGcwbyr0dHspimLHNNQFaaqbRzAqinC84zjaD4MWka9XztcHgecMpYQUs20OUOf2i4do5aqnBLbTJqdqcBkqaBoGgcAHA2aqjKgoS1kSDgz7pwq2k7kydhe4tnBa0hh2Ga20)7f2AcB0oSbh2Oy1YzvJN0WHuZqPC1uEjaD4MWsMOavtw3o7h1VeUb0ocnalzjs0OAhqdbTq9gaLqA4O9qgDPvuQK)EPs7OL4GP0wcGpkKQsmBOYE90liXlk84zjaD4MWka9XztcHgecMpYQUs20OUOf2kdAhHgGe2Af20eCYOir56)9cL1ubrqaBNaHeespS1e2ODylMmBNr2(JfKnkkNnc(GtMWwcve2GdBYpYwzq7i0aKnQiCvw14jnCi1mukxnLxcqhUjSKjkq1K1TZgq7i0aSKLirJQZOlTIsDbNmksuPD0EiJU0kkvYFVuPD84Piicc2bHeespBawe9q8IQh1MHsfq7i0aScWIOhIxuWQUs20DWxhj2OYbaafKTyYSvg0ocnazJGcTdBoGgcytGSvMEtIXNUNqq2EbryvJN0WHuZqPC1u2paaOGL0kQLiHJurVjX4t3tiyfNWnHzTFDUtPDcsWn6njgF6Ecb1MHs1paaOGvNc6K0oPgbus9hTpimLHNNk6njgF6EcbRaSi6Hqjk0sCWuAlbWhfsvjMnuzVE6fKO(Jwq05nUGJuJCMu7XlvI2muQ(baafScWIOhYjPADfuscGpkvPlWTa35gzvJN0WHuZqPC1ugq7i0aSKwrTejCKk6njgF6EcbR4eUjmR9RZDkTtqcUrVjX4t3tiO2muQaAhHgGvNc6K0oPgbus9hThqff8j9cUFWcx42b2Jq8s9ZzxeEVjo4K1(GWugEEQO3Ky8P7jeScWIOhcL(OndLkG2rObyfGfrpKts16kOKeaFuQsxGBbUZnEKvDLSrLdaakiB0oRr0Pe2IebYMaAKWMazJMGS1cBbHTGnId(6iXMpoiieiGnfiGn5hzlfeHTsrLyZfvGaKTGnLEAYpcyvJN0WHuZqPC1u2bctBasG0GhwIceSh0Br9hw14jnCi1mukxnL9daakyjTIAaQaqYF4MqTpyHlC7a7ri1mQ0Vw8s9hThCkOts7KAeqj1F84bGfrpekPw636T0fOwIdMsBja(OqQkXSHk71tVGeVux2JAp815oL2jib3O3Ky8P7je0Jhawe9qOKAPFR3sxGNKcTehmL2sa8rHuvIzdv2RNEbjEPUSh1EqcGpkvPlWTa35glnalIEih9sfAlcIGGDqibH0ZgGfrpe1uLvnEsdhsndLYvtzhimTbibsdEyjkqWEqVf1FyvxjBLzasuZgavai5NnQCaaqbzRvyRf2AcBHWwcEMTmniKgoSDWLwyBGcBuJcBoXKXI(DKTqyt(r2WjZguHnnbNmksW25w(ztfopw14jnCi1mukxnL9daakyjTIAckBx4qtQsJak08TkCEAZOlTIsDbNmksuPD0MrxAfL6cozuKOcWIOhcLkRwawe9qO0jw7dw4c3oWEesnJk9RfVu)r7bNc6K0oPgbus9hpEayr0dHsQL(TElDbQL4GP0wcGpkKQsmBOYE90liXl1L9O2dsa8rPkDbUf4o3yPbyr0d5OxuWQgpPHdPMHs5QPSdeM2aKaPbpSefiypO3I6pSQXtA4qQzOuUAk7haauWsEu)s4wcGpke1FkPvu)1sa6WnHvY62z)O(LWTFaaqb1cqfas(d3eQ9blCHBhypcPMrL(1IxQ)O9GtbDsANuJakP(JhpaSi6Hqj1s)wVLUa1sCWuAlbWhfsvjMnuzVE6fK4L6YEu7HVo3P0obj4g9MeJpDpHGE8aWIOhcLul9B9w6c8KuOL4GP0wcGpkKQsmBOYE90liXl1L9O2dsa8rPkDbUf4o3yPbyr0d5OxFOqBrqeeSdcjiKE2aSi6HOMQSQRKTsb6ccCyBvSWbjcBWHTc6K0ojKnja(Oqyle2ur5SvkQeBN)XHna9m94ZgKwyRh2OO0RGWwqylbhF2ccBNr2(JfKnCG0()SbqFCylMmBbaNVf2iOi94ZgTdBkqaBAcozuKGvnEsdhsndLYvt5hOliWzlyHdsKsEu)s4wcGpke1FkPvutCWuAlbWhfIxQPqlQOGpPxW9dw4c3oWEeIxQvHwCqGp1va6JZ(blC7bZErbv1E4RheMYWZtDbNmksubyKP2JNmuQaAhHgGvPFR7X)Owawe9qO0bkkVSN8aXbtPTeaFuiEPwfhpEYdFk9bckBx4qtQsJak08TkCENmJU0kk1fCYOirL25KuTUIJhzvxjBA8i6WgTdBLbTJqdq2cHnvuoBWHTiLytcGpke2oC(hh2s9sp(SLGJpB4aP9)zlMmBduyJmHd5hkhzvJN0WHuZqPC1ugq7i0aSKwr9xlbOd3ewjRBNnG2rObOwurbFsVG7hSWfUDG9ieVuRcTaubGK)WnHAp4uqNK2j1iGsQ)4XdalIEiusT0V1BPlqTehmL2sa8rHuvIzdv2RNEbjEPUSh1E4RZDkTtqcUrVjX4t3tiOhpaSi6Hqj1s)wVLUapjfAjoykTLa4JcPQeZgQSxp9cs8sDzpQvcGpkvPlWTa35glnalIEiEDqfLFaqpOce4J1Cq(7XFtEq6jdW0jxXXYpaOhubc8XAgclCtrgp5kow(HLa0HBcRa0hNnjeAqiy(KQKJhzvxjBLzasuZgavai5NTYG2rObiBTcBTWwtyle2sWZSLPbH0WHTdU0cBduyJAuyZjMmw0VJSfcBYpYgoz2GkSPj4Krrc2o3YpBQW5XQgpPHdPMHs5QPmG2rObyjTIAckBx4qtQsJak08TkCEArff8j9cUFWcx42b2Jq8sTk0MrxAfL6cozuKOs7OnJU0kk1fCYOirfGfrpekvwTaSi6HqjnxReaFuQsxGBbUZnwAawe9q86Gkk)aGEqfiWhR5G83J)M8G0tgGPtUIJLFaqpOce4J1mew4MImEYvCS8dlbOd3ewbOpoBsi0GqW8jvjhpQXOGvnEsdhsndLYvtzaTJqdWsEu)s4wcGpke1FkPvu)1sa6WnHvY62z)O(LWnG2rObO2VwcqhUjSsw3oBaTJqdqTOIc(KEb3pyHlC7a7riEPwfAbOcaj)HBc1EWPGojTtQraLu)XJhawe9qOKAPFR3sxGAjoykTLa4JcPQeZgQSxp9cs8sDzpQ9WxN7uANGeCJEtIXNUNqqpEayr0dHsQL(TElDbEsk0sCWuAlbWhfsvjMnuzVE6fK4L6YEuReaFuQsxGBbUZnwAawe9q86Gkk)aGEqfiWhR5G83J)M8G0tgGPtUIJLFaqpOce4J1mew4MImEYvCS8dlbOd3ewbOpoBsi0GqW8jvjhpYQUs200rk5gV1SDcWYKTsb6ccCyBvSWbjcBNB5Nn5hzJefiBjOF)yliSfUWfSe2CPf2A)bc6XNn5hzdhe4tnBp4KBPHdHTwHTZiBbaNVf2Oj94Zwzq7i0aKvnEsdhsndLYvt5hOliWzlyHdsKsAf1ehmL2sa8rH4LAk0Ikk4t6fC)GfUWTdShH4LAvOfGfrpekrr5L9KhioykTLa4JcXl1Q4iR6kzRuGUGah2wflCqIWgCytFv2Af26HnNyYyr)ylMmBdgGe1SveEZgoiWNA2IjZwRWwzol4aly7mC(wyldzRacq2Yrr4JSLPr2eiBRQbkRPobw14jnCi1mukxnLFGUGaNTGfoirkPvutCWuAlbWhfI6pAp8fGEqfiWhR5G83J)M8G0tgGjpEa0dUpdb5QcasKkoHBcZh1Ikk4t6fC)GfUWTdShH4L6dpNDr49M4GtU0FoQfGkaK8hUju7xN7uANGeCJEtIXNUNqqTh(kJU0kkvYFVuPD84jJU0kkvFaD2h3fH8(RaSi6H4ffh1kbWhLQ0f4wG7CJLgGfrpeVubRkR6kxjB6cgj5hZSDcpPHdHvDLSDA7)tKiTgbSbh2k7QQmBLc0fe4W2QyHdsew14jnCivIGrs(XS6hOliWzlyHdsKsAf1sKWrQt7)lejsRrqfNWnHzTehmL2sa8rH4L6YQ9blCHBhypcXl1QqReaFuQsxGBbUZnwAawe9q8sLWQUs2oT9)jsKwJa2GdBFwvLztFchYpuyRmODeAaYQgpPHdPsemsYpMlxnLb0ocnalPvulrchPoT)VqKiTgbvCc3eM1(GfUWTdShH4LAvOvcGpkvPlWTa35glnalIEiEPsyvxjB60UccuO9rvMTtWXjrnBqaBLbQaqYpBNB5NnxAffmZgvoaaOGew14jnCivIGrs(XC5QPSdeM2aKaPbpSefiypO3I6pSQXtA4qQebJK8J5Yvtz)aaGcwYJ6xc3sa8rHO(tjTIAjs4ivcTRGafAFSIt4MWS2Vo3P0obj4g9MeJpDpHGApaWIOhcL(qHgd9MeJpDpHG5nie0JhNc6K0oPgbus9NJALa4Jsv6cClWDUXsdWIOhIxuWQUs20PDfeOq7JSvoBLP3eF2GdBFwvLzRmqfas(zJkhaauq2cHn5hzdNmBqf2icgj5NnbYMpkSveEZwMgesdh2CrfiazRm9MeJpDpHGSQXtA4qQebJK8J5YvtzhimTbibsdEyjkqWEqVf1FyvJN0WHujcgj5hZLRMY(baafSKwrTejCKkH2vqGcTpwXjCtywRejCKk6njgF6EcbR4eUjmRnEsVGBCWIgjQ)O1LwrPsODfeOq7Jvawe9qO0NAzzvzvx5kzttIPj)SQRKnnDpn5NTZT8Zwr4nBLIkXMceW2PT)VqKiTgbLWg9KqcHnAsp(SrfXq(tuZM(FKHNjSQXtA4qQlX0KF1lbOd3ewYefO6P9)fIeP1iy)C2p4KBPHtjlrIgvF4la9GkqGpwZyi)jQ3K)idpt0Ikk4t6fC)GfUWTdShH4L6NZUi8EtCWjF0JNda6bvGaFSMXq(tuVj)rgEMO9blCHBhypcHsuCKvDLSPjX0KF2o3YpBLP3eF2kNTtB)FHirAncuz20uH3DbDbBLIkXwmz2ktVj(SbWitnBkqaBd6TWgvUuurw14jnCi1LyAYF5QP8smn5VKwrTejCKk6njgF6EcbR4eUjmRvIeosDA)FHirAncQ4eUjmRDjaD4MW60()crI0AeSFo7hCYT0Wr7dctz45PIEtIXNUNqWkalIEiu6dR6kzttIPj)SDULF2oT9)fIeP1iGTYz7uiBLP3eFvMnnv4DxqxWwPOsSftMnnbNmksWgTdRA8KgoK6smn5VC1uEjMM8xsROwIeosDA)FHirAncQ4eUjmR9ljs4iv0Bsm(09ecwXjCtyw7sa6WnH1P9)fIeP1iy)C2p4KBPHJ2m6sROuxWjJIevAhw14jnCi1LyAYF5QPSdeM2aKaPbpSefiypO3I6pLGElGyhfq6ruRIvWQgpPHdPUett(lxnLxIPj)L0kQLiHJuj0UccuO9XkoHBcZAFqykdppv)aaGcwPD0MrxAfL6cozuKOs7O9qgkv)aaGcwbOcaj)HBc94jdLQFaaqbRof0jPDsncOK6ph1(GfUWTdShHuZOs)AXl1hioykTLa4JcPQeZgQSxp9cs8IkWQ4Owq05nUGJuJCMu7XRpuWQUs20KyAYpBNB5NnnvqeeW2jqibPhvMTYG2rOby5u5aaGcY2af26HnaQaqYpBGy8Xsyltd6XNnnbNmksuU(FVuztN65X25w(zthDinHnLEIeB)TWwRWMdKqA3ewzvJN0WHuxIPj)LRMYlX0K)sAf1hKiHJulcIGGDqibH0tfNWnHzpEa0dQab(yTiaR3qLT8J7IGiiyhesqi9Cu7xzOub0ocnaRaubGK)WnHAZqP6haauWkalIEiEvwTz0LwrPUGtgfjQ0oApKrxAfLk5VxQ0oE8KrxAfL6cozuKOcWIOhcLuHhpzOujOdPjvPFR7X)O2muQe0H0KkalIEiuQSx5k3la]] )


end
