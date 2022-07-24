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


    spec:RegisterPack( "Assassination", 20220724, [[Hekili:T33AZTTrYI(Br1wHMupOjHiDS9ruB5y5nBYMKtklFVz)KGGibfXkscEWdjRtPI)2VD3ZdmZGzgakjh77wBTB5iIhZ0t390VNgxm8IpDX5ZIkIV43cgeem47dg1F4Rg(QJFZfNxC)M4loFt00BIUg(J1rRG)9D55r55jRJkssxJ39(LPrZWrjpTmBk8elkk2K)2x(YRtkwuEv)PPREzEYQYL0BmnlAEb(7PV8IZVQmzzXpT(IRSdcbxCEuzXI0Slo)8KvVhg5KzZIzpEC(udyz7LFm96Y4T)8pxU8(Txgm6q4FGXB7pV9NF)IO1xhN)2T)8rBV8DB2GpWlYlYsMw8ITxoFz01BVSiD7L5PRIHh43)f4IPz3KZVA0TWv3KLongNn8ztwf3NgSZsx)IITx()nADs(ITxwUEj8mBV88LjtH3jA9m4rO)8UKLl3E5YOC4PxMcqtgmmayT9YFfUg(lXQHnWFmEz0N3E5FdGT4Ll5RWxcZu86zXffrayD)6PBVSBYC1lMqW81xVmgM505W9sHHgF3i28U9Y3Fwp2u8Rr3eJZqC(cISaV9AasYk3q)52lbs3vr4FddZDWJ(VkrOFwcm0jfekA7L3MIa3Y4W80L3gVUGn0)FYHh)8F48TxUknlMJglxTcbK)r8TjRFbaN)3P)VXlj8job3NwU9YfeQUyrmslkxEvY6zSb89PRVnodM0SY1XH3LMnR)8SueCWH(QY5Z7lVtiDN(LByV67aMgaI)dySYNgbG8FSiUiViDnNe(P7Ibeb8eF4Z5aBsjYpXb5RJHjOmhVjheFbcFc09rvp)S(xa088ICANqrC0syrGBl(nAhw86ORasYf)aWspLTZzAwYQ801HfXR2eNxW4PZs2WU7VLC9I8IOL3eZjFh)P3cyb27aWS4LG3aizjrWU1OLi6Fn8If83SpFA3EzhaFUb4JclIYGffG8pDcmM0nqQCA4MuG4ZV(i66ShTpYRhwKgolbw5a6klEvuYA8j3E5RUOa206ybI8rLzXnTWgIlmq4YM8fPa2(JI3Q9RSN6c4yhlGnPPldZIfY10wgNxEfaDZlVo(Tsjk42HpgphEJf4(9Ifmgtek)XOSS0I48loh20eUo(ZfiJb8pJCm3xZEblOHC5mRHe2JjIjCzAECySgNmC3Ukl7taCEajlr9XMfMrp8dpaI6aP1fjBwMG0Ota85WTx2RTOuqQ907Ncce4SA8f64NesE7Lhq7pVwHNrIQ5ixqexbx2r8As6hW0Z2jQSBEfkvDwzgxI6vXZjbuQ79RrKELbS3wAc)UQOzT7J4GBbQ164vjXa2JHP7WLNPmOA0U(hxNnPa(FNFlPeYMmN0nGqP4IQ372ia8H7I)1Ys4)0L4GqrOWAhMXzXrflwEFy(IOzP3LRb2XapndYRVZB6MqadhccBqsqpg)u32oY6JhSyb(0Egmf)TeMQw2gmIC((FNRm63uerCyL24sMw7ZyZmiTHn1eAiKzwJQWLqyrmnD9SeAc9iHJJW1HpHPam4JXZEGoO9wu37NbBIwXGDYmb2tMfhn7E(Qb5abU73FMfooN8unjSuq577CfZPePlbC0A9jsJp0NOZwGzurimmukdjyf7uzHt5MDr3WEnVlSLyKzX0UYB5acyEHp53gI1akzwuy0Q0Y1WUWrJRjIXu8yBfXiPtCjbay5aAf6bMLwiF4mMiuC4y7uvVPBTaQBtH9ZZtMIMdIB)7AyNr)5rRdtNhEZAqCbkI4VskNzdtwuYSWyYOXOzZY7JMCEkQCQgFKfzW7aNMMb2jRFR0iJdKAowNYn5ntOujd9y4qsvbj8qWaEa4fYT9bziK13Sj484n5OH3ZbMlWi)fjCBM3Kc2ZJCwQ0ZUsoYveCfgjS7xsxrkrLaZvrz3G4qqZwOZxPNGBhPGClV0jVDmj9vQSpUjwg2DYXvoEvItX4PvfnmQIzkNqnGbdtVHqJ9Kac)oQV3Xm9yahveW6jvKji13adIkpGfjZACbFmwQ(xLAalP1GOMBlxUooJHBKAGR86Px18YhfBY7AwXQ3TdNqMlvPfc1tjTCYM4LMNpyPKD99aA9641K(5K1i)bsLhBGFEV8UFGEj0Kk4TqfpXKltmNFlqJLIvbt2GlUZmBYVAgqLsUQZcTVIqzXDdNoltfgQUoFCc5VUFd2KUM1pdJwaEbmkaiNwLNzrafJ9Jq0NoMNDcsK03o4L(Ex(25BeMoJGXx74DZXqheck9aRRRzr8VxwGolDgQge5wb1tWujmy49LC)HjJGF)IOCucwMUljFaCKED6k2EIikAe3vzrSkUApHHOAqKqUqDB)ifzVXXYkMnTgRN)oOYffnVjljfM37vaVPGOUC(cJVeiji0QhVyDR9vdwI6cXZQW2Tufjn2LhM4AD4aN8z04oxbEcPROoR1VRM5v(EqWiLP3WezoWbaguh1JqSZOr4JJfextVSl7G9)YjzG3c07Bk9ScDXLAPzlXWXKzHwfOvn3rztJwJoJMLb6uPPzKQsd(93uUmp2q5XWXQp4sY6VW)v5SRxHJKXZ(k1N9QORjnYGOJBY1Fs4f3alyshsnnyryGcqYuoJUyQjto(PffWDcbk)9XZUd47Hf4NtmFhxwFJwmGVnyIj5TLXM6PPa)qeyacA61I7Z8Am2yL1tyEmAtmSIboFlANueZkcE3MY8IsqLwmAtcaC6g5iFSArrumQY10CzykFCQBgsbQq3t0Y8BUJS2ppCtuX0fva3(0JoO)igpiAwBCr4vPRlrBzIZcED4OntPNBqFMDX9ixvTPGcuCzrN0JcKtVkEws86PXAGkaNJQ7O8NqzJr3c24GXp59N9rw0Hh0piafSGrYTmwrFXh)TFeu9Jk1JzItrNVGnDyC0)m(m4BtGgBGsH5zfAVljIgJgnjFEz61jtvreAIV4idtfNErgIbc2UT(gGmGtvy(Yu9WFYUz)IH9b9EHGesGrE99HZ2KlmJf9fu8ubwEkKJuzyKgOufTiuSKYqy5j6vBysW9sazPSaxpH)pLWoVYvWgZBP8cWJpI19KnbWDmNiwmvUolkFdiWOiEvDUIZIbe2kqgkypWIKPl4zqagZEy4YqLQOkg5iZI8)DaOXyvIkWawZ)rUItqchK6xX)AZmNMz7dSswDS(niR2i(A0dReTtBIUBsvdEUOQoyw1Ni7uvF7lSyhwZ4D7s4y4yBa8c0xumQX02(DJRxd(lZJdfRHHHG2MqHStRgz9mTscA1kPrkTZvsq9vIMTacVknSZWLnwMUfOPrVPOGPeia7QZ5oEZmvZtsRSBfV0MDu6XiuF54deIfo78EOMK(BV8NwTcuEboms5kb2vfCWwEcfYp0ukYHmB8zx8t)a(tqjv2Dj5K0iz6hzzSLBJ42lF3Y8uX9rXASGQswhZuAb)jrKl3OfugFH0EezcahfploEtCgW2aClGATvAO5U2dIIs4s0cHIhFeWBBAtmgcUap2eZER9u8DwlCc8b11c1sO7ReV6lcQ4O2q0IpLhiFlbSP5nZoc2i5H0xa0K5255jlxgN5ZA784mkmiOihWa2nj3y61op)Gu(WjDOyPaiZelYJNIMJfjytG)mVYN4dX)mEomlSApq8EZUN(DEkmTO7WZly1uqm9QGpa3lEyvoD5QUAXPg6qllMq868a4zZQFV4HNTjENsQyZKK)bSpgeHKXI0WMneQC6cC0ZzIEUQmBTTGmmNeY2MvMrWAdvDVFq)xl2GDvAotRpnYkp1ek8dA7VSSW6JBALq(rYvr48mg6anrhhlWW)X8DHUcMEZ4T)ybgGWF9DmPPuyZru0ca0RcI0H6wgolAf5ccYARYVdghLDhGfjC)Vehbi4RWia95OvBwAQIRMo9aUo9Ni2x6c6saacV6(Wy20BMfjs0S5Z4jzlsb8RWaUFhGtbTfuvNegVEre4chgLb5J6rSDN6Ap6zZhkfVV)sGR4WW1zLZUgteb6VmF93a6XrOfg7NVZxisTXMUeeUdUxcgZm2AKiUbl7O8WuErhPrFjO38bWnCgC)vL10tPGM8fMuTeeyM5BSAXqrq)dE6dWDEdFZbKFBtXQvdV5FNksUTx(dlJMjKLfDnso5gNjYfrBeH1LJByvEx4v0ykc)ifKU3iD2zVkvwHzPfCxN60ugbz1H0bYA1qeAEEevS5bWJczrkEzkIzbGlNrMaBvidI4vj3APwtyrr4o8kWmd2UQP(LjBRkW1ILCpgD54pPIFztbPqBgSjrgeq8k0Um(ditevhpOuZe1ktUM4gI8)zK1nxe5MPpwdDCZCpwsIJrYAygYnqXbJPlsXWDMft2WSEMvNIAEQ76rOgQlui3sjAGPGbIi)TUPTe7)vlXIhmzwmx6BvaDxDvjl)01cUTmySLfjlPeOvZcMwSo8sByH5xpOFrxD0VYNrnE(Zi2UTx(7eFhJhnqYoxf382ILTSajFiXSB5XbY6HMUsUD)X(XrM6rQsqDdo9yRQ145or6MJJNXU3h7JLHL02mxfdHHdvguQFcnZhwgW)IbCTCdA106Knc1fPui6iHmlb7hqP3F6tN1NxBT3r2HXDbyoVahy1tmg2wjCiCIM5Gbkkd8f3MJyUjq1GAm75miNvuZeUcNeuXob7Skx64bOF9Li4(RZpJ7WoVGTqF1Dfjr9AE2zHu4WScKQEuDJoQcMxN2tZKCx1dKhxPxd(WlnCx9r0CmgZYLcti5O9u9sdwxG0EQUdGgeYlzmH2YDVefAkas8z9Pgfaw2upIe7SFJbuXSuqj(JQQa7oqGmM3661s2b6LXnfCBqeyYuXAUwcA0R7l1c)B3l)Ik8K3Q7XP6BRrm2o7kQgZ07mkWxitEfMI21jl0jEfr9oLQJeJVpjccvjOxpL6ju3cQBvKocBNYlNLs5GT4vgtL97suZn3d)ETb(AD80S0LPzZmVoihTrEP6sDOIouuxxy0yyNDIio(6o2X(al2AkUntPZ1b6qlxci5lVAzvOMtKDpvGZxMI0JU0)3iob4okMMSxs3Ei(lxLqJivLNIh7LghZJAuc2UnRDAC8iZbBv4r5(JQnmshVDfsfCzzLNIVDRTSL7Akm)wHiAw0D728jKCzwuFpouoj2nCEuRLfyjIa6U8PCsMiXx)oR4d2E5h4vFatDaf1kP3MmBKqJhIQquWFHgIEHEDB(CvvdBRkxZkNEPGcZUOJkXSzhA6kJ5TWowk4GQvbyGuFE9GkDU88FfMmxj0jMRdThuKvhu2MTQ1q5zVEz6vrl5cbDgbenDoweCRlOwpTrphYQ5(9RFU6yw6oLY20vu0pOyQ8sZZBxV(MXT0mQgmYuBCn(erL5w)Hv17spsdjWQJDhCuK26mgME2xpYvaAAed0m42TzzBJuKFX4EcR2)QklZScu2b5NJO)tBOwpnqPNJna2c8svyqrXWw3JiSC55F3XH8AhILskL4HboFwi2NSKINgvCPX04nCqEl4kSAvmJxWt1cllwYNFoC8v71qeOCVhVbERHs9914yAfV5Wb7iVPTPPxn2jBXYQzBB8qrRfnsVk5QVCS7EwBfmAd9u3ld9tpIC7cD2IJvpcW62oCO8OKWYhgfehY1bsBovYcchcFPyErMz(eNZ98kh2ALppb961QPqkwavlkDw29lYbmpY02RQRALBrv9vqHSbXFcwfd7G2ZiwY2lEh2UlB4Fv6tJ7TdCpowILS)646LScrGnIws3AGAebLZyT6Rs5KA21TCLwJICdi8Gm1aKeOeOkBf6gpar7awKp99K2k6dc6HfNukMsC(nvSduELcr5wBrpg)HcAjxwW3qCzwlNWNtUSGhfxMnu0tLlBOnUSHF94YciEkNhlq(mBj818td8NcEnyR5MP4z8lEz09yaXaNC0IG9zPFc(DcAUVOhymfJ8eA6VS1wqbDhqYh)Dy6EZXOSLlBNbG5TBar88dtfn0tlPJQGyGfL5u9KT4Mx2w9qq14iNuQAifR4g3mLhGBx3LomQHmq6iYXJEkCPQ6XTpG1URRbKzpLRtovS25WxVkd1IRllbiMUYt6EVkfvTjvmtxRQhbWs2cpcbmBHJxNwE9Iw652EBDFeAnS4rYSZoobdzP521bjW2oCMHGSkqCe9u6jOqergBZ4amdvNA3S4E(myMD2MCw8flsU10Qd4sSDiWgMC1eAHx73yoq83IixcCKZhHdlirrPB2mxZjL7y7Uu33TiA5C8a9NClwag2Sxrn7nYqozyeQmgiECcXLPSDvtostzUP5kZXs6lXz2CGRsTprSmdMIVWT98U27Al6Isnbod8iDoVj(WdCQDEx1NWhWj8QnvNJft5zdhxVRa)TMTSeWUWCpTOrVdp2PJLvZ9MuHH7bURFcFdabuHZlZUNge3(H6DqIZYJZefWzG7ZHNVbzEswmbn0y4Uyb8ngyDVHP6BziEMbPbYDNpWA4r9ge0QjY7rsSQRce4Y(H74DlQW7enlkviZFfZGCe5aYAwv3wcztCKV6xnOrgTVx081Sav4IW9XqE6Iye0IM()uYaiGZoh2fNxJ5x(irFowPYkAQ(tywf2WsRj01qPrG(I24ybwW3YcrhMAUyVfX6cUcJrcpe0Dm7M4SPlsINBROt02954Lu5tzIOlJxgAi(KaixH6gjL54czowoJzRHTf4XrFESXOZKt76Hdh1MqzD8abIW9SIvpGRATdDVaaPvMXB8mwZAqpOgKTvL5mJIO3QVfjexfxCxC8AQXweFFCEZldYNfwDgHNj5hvNoYEnk210QUkmNu1K4MvE6PPCYORiSTwf)8ljRW0ZZo1nu55lAlyCmw9IjSYeiwHKE8yrgEWd1d1SgmsVpkMm(ZBsY4HWX(5bOkkt53KSjKTbOQzs9ioMgUrR1nZOj5bMoJ)iWSCR)FYywUPT5mFgOtT0NoWb(t0W7EufHZU19vCQf8ukvG9C7kYP1Rzqo2RcLPM6lQF38sZEuzfkH8UQcngCGGmKJb)htfRKlu6rg4LqnuOcYRXEINUZhBINMGNXHkx8qqsozaAhHtIdG53HUJKycpufo1u7IAVT(A0EZAObk1PnLjvqZ7sAu1BnOPMRHNyZbqBfXZZjUrWp6a30Dx6UCTcxo09wbVicnpiuyoDzWOV(yOKZSCZnXXuocOZPiO1vuz6ui3XDHyE5IiIpJR(AuOuubY7ssYODsS2ilwMwI(xiwOxuJXdRmxJElM7dkIzWlCxxKsYJnchzDRQsA04Nqez2mJmV()LrAYdlKVPz)wTRXCYSr2vBNLYWV0EhpuuIAAhQkzXbFJN6IWU0VpeLT8ELE8JKvJoAdfm5016YpWINsIlf(S7X4mSbeAgVkzAVTwoYBMLk3Ont18gY1XT2HonFTomwbpO58Z3kCMTJzjWAbr0osVZm9BPBWQgU862WXXI)ND3ntWgg0MT32o9PU7hsMT2zFNQbl9Lzge1CnY4UxVfmqbJ7n2AEoVqQ7c7sq1becE)6rgqcvSy8lJ3nR)1StH8wOvUxDZ8nB)1mBl5SSXBRQffrFia1qYsuqw5610sJoieOrsbhno3wbXWSJLLsaPRaSC6NftHHgwoSZSQmnccbKwlEctJio3YbrghPQewWHEQoK1oQ4DzlMLj3MWA1ovzVGdJSeIWt)upVcmYeZxR41mfM8VvclAssXPe8mseSALdnwe1v6cZNMwUEww8sT(Y0yLaC79GMz8SUD8DFYYEzw0C5PKDwntBfQkDLVbSvOzoWNfRjE9))k9MvwbERJcjvVrReu36)FKl8VxYfSBQIl3wRzQIXHOE5sw1o)U0pu)ZpHypo74ThHizQ7VX9I9Q0BJfLlAY1Rt59VeM4cwK2udASiECc1S860WYheINGjtgHzPfg04TCf8J(SBVY5FsCWZReLk0EhZertNclboIUd1mJeTzjE6WNLkYfUOdBiBOFF6hE5V(opOSj61ZtRyCPiZJIAR)HwrSFXh(VRz4BoABvhf3ukI)aj11A(RvsfRwtQql0N7Wo7ruIgWGLhNLJ0t(NNiWaVZVlkdnNm)IZ)J39XF7N(TF8TBVeW6iRDYQnP4hQgYWWxitG5lWbNLUQT8Uwvuzr6k2(3PSpqr93(Z)c1A(g9w5N8g824N)iQEjkqgJVJrJ)LsSHbbMcMtAPt3iItu3xcRXUd)m(z(z7p3aaYYf6UbDd1HUxuX(8pFbd2uVKGdcUv3acOyJYRE0JslxAYgD2UT6mW9VqEmyKGv1vQdvpPXanN6d)3)IXGn(jIOEEq3Sr57ngfrLaoSAuukoq8ADh1IxpWYRZUw3JvE9xV7ZEBEDpZUkW)MDF2v53hoy3N(G2XPZACF7gBUjYOLSOACdddEImvnUYMolF3wwV6Pl5mWnd7tD4ESiDF8rpvyYKi(n349SPm0(41M9XT699Spw79h)mVEm1pSRRhxVFJRNg39olDhfkn84hTaL)uzzEKG1JxtU2WyQfT9dZWMgg2Nwr13Hgod7()NGb3QSb)er1Xb573YpMzyukZlqklwBiPZtWAD4V8xQkHaEWL4F0oX7y5d3jE5QpEN4Vo658d4jFa)Y8r8Kp4FP)qEYNMVuFmp5d)Z7h0t(GYz(2URFupf8b((WEYFMNPpUNcEXp854PLeJUiX7c06vXxdooIT1OPtJ3Go9UoD9rlIYwnVCPytrosbxEpmC8F3x6JYe1VnewU)btEPRVke2FAZg50H167Ztgo4WK5t2ZSjy0PEnLC6WX2NLQd6pouoBqcp8GZMjG9XveQRdXseAsvDFpl7qQGPMm8OUkrTW8l5W(DXVDdh01w4M3Fq)H961diOCDwFL(gj0MfU5Xf32Ix(nHyF87abBD9LVl)3gOV2X4sa(iVsLvkMTa)oD3RYeeZB(WdvVyTZE3PtQEXA3SN6R6TRU)WdDRTNWdi1rByR1T(79uqvbQOkltDfQQoESA9AbBCQh0yp138XJPSqz1g2hhMY9PPLJYSTNVtxlaLAB)V18g7mmgS7WOJpnbTMQ4ag5XI0Xn1((cytzbPRWtJIRJAqCRPVeuNqfGmLkgswkafOqrkPJ3gLSKYSHe4MGFT)izzpTpJFYb0ccOgDt7WxjivUZw0jbeaUtFh9Cp5gj1Hp9wRXJtpES7XX5HKIpIopi07B5CwnltDImpvnCSMSDiWSiNXQyE8jBCyMolNqNFX)g3PXsOZ2JS4SSky(1IRJAgnoDYqcu)Y95Rtfg5F0nqGZbSz7YCI6jJnG8r(gABTBTooUJycg66bO2e9jhpWaacAMva7kYn)quqpvFo9VfC4Is)Jdbq2gFG9IMQ(OqFX4uVUXhio1BP99Gt63kFFgJR(Ry7ETsGpSfBsn)c4nG3jd7p(qTChZ2hxVR7cgDy)4QckOQLwnG(3d0Sv)62QgX9by4HhSDNtNOM8WEsu6xXErRgA1MdxwqEGNuhp4ix9M2onVYbCVPbxGnyo37IitU0EB9BrWToI447Sl)Wd7vDkEL9BwU)tptTLvtuPdfA27eqC1A(mnbwdEo6ckijBhJGtgFuW(n95)brgFj7(QTedP2(JmWlo6hTp8GLd9nIrmSQ3gR5Kboyc(I3pvBj6OEREc3uA0izvwSYMiR61ajZc)wFEMwokLpOux(QBxTJ64rbd69DDhgmWUjz96DQJ36iVB39pMDAquXGhEWJCg7TJv4vaXLD0aZtcg88GhLD0GVSys9wxG)rJTBsV)O6eh8x0JxlTN)j3YsnrT6bOR7JjcD96SN25WVZE1lfZooQF(jd601tlj90aq0SEH807qlnxu0ueJ2iQ2LuJ9y9amkLr9nERdToTRcCjxtm8PQtxlSHgo9DYXDQ)qQQj6yVOTahf6u3QnskqDQVDw8r925fKByPR99PJG9JILC1MsZWM6CB(OJAgd2Yzq1GOVbB)MMKcMmkReblge0PRZOga()904tgoOgFIhGZoFamgFNacDqRhoOv0A5O07azwB(wcQiUSVIDOYwR62WkuBmzgN7iR6vQJDS7fqts5SHLnTUqzhCXZDl00eVj7NghsT1orm(jxUv8V2D0UF4bBljXY1Z(1a7VPolNV0d8DbGDo67HNeGE5lh2AzZyYWoDTjoOvRZ6tf4YRN5kqlbssWN8BTvRDygGPyp3trnbwoOMbEOMbFnOMwse0JHAgSdutZ15UsnhQLJRVqutE0K(wS1qwtGRqEdWA5LNzpBjzcW1wB)JNoX(1R6IJhDm4IyxRT6r(l7PfqIVmdn)fVloAIVudPJDD375OFo2XsxJy)UdpWArfuF)qVthDWO9vdEhZ7qZrCq)XNw3cQE2SQAetdL92T4)12VwTBXAMVb3xVYsKUQ3XWBpRgBAZ2GU71yykT1CfR07BePApnvX6MJYxppNlNU1JVajqZryhoDyqVdSQgOTIbHbysqTLgR)ekZ)Jrlq0Q96hB10EZbUQVfIdElEEzlkSDpVSBe2UhxVXd2U3XEANyhygdjjyurCgbexglWgV690pk7PUZ68PgDxWhEWswgE1aR0UV3pS4PZ6jzrmAuGD66bubL3oGnFRVH9ShpHX(bEN9QpBz1ApNDSp)tIZMNNsQJ92O(CSLIx1wTRx6526Zk(AlnxpRt9emsKSewEglHQYtty0vjlbOiMLatzMTfTNGUJpqOo5SZ7XtK2pjIyhMWE0)NGQV4WhAZLPmXf)0p8FP5b1DrYYsLvvV8WiU9Y3rnpj29PZf5NZVM3Dtyo5c)jV)mOGQyPlEIsgVDgSPdAiBp2T(vxtG3GLRNwAGg4iT0QMTAO)YbWRLL0kLMpI0EDQQYcgYRM7(vFoyL1wILeyo8zybtSG8c)w(b4wV5yuL3BX5aLfMnHx8hkIAwgReWfVhpR65PGOxSUmMxid(MrFt0c(WYNICndZRWqD2JLAGApp9vHUMWhVZGfbAp(z8VGvWn2esMNXkCLnBieY0f44Zns8QYS1BTuZkKWK8wc2oathkopzq)x3PRnrwJ1mtQ280NYWad6pI)FrHXeigT8Kjd6hmM5nYFq(F8RVJj3G8dbxJlsWgQIsmxvTDwiEe5Wuz7WG2EhWOriVFbSldEeSIGyFm8BpkQb7yBlItMpeZVk)cHymTv1)M93XACBXRSc1uEhaWGSqYsLW41lqlRW6HHEmh7E7yKIN2JmEwWf2ov4W60jcWInlJj2LNNV))TC1lRlNXhQMERBWzdSVGpxSIVY4I9zELHjy08ZGpYEp8n0NB)iSyLOB(3PpV)BV8hOVV)86tdJKroxxVWqnlGUMTBU2IZQqLf00esn5ICw5HD6KHV5Hh6UxT2hBhFwio54dm8INhDHV(F1)BdgIn1Ku4z0NLD(X(aVYj8BYRL1owqnokzdlUz2Z6wf)ywllGAFu(DrMBJBOdSmbSpJ(ozECNB59S0(u4cRu)M9ZpShpUVn(wGxXN8(2Qi2Nlsb(gF7JN0GDUMiE6cPsRw3O9VzA50klY0Ij6wrwV9fYTMSUqHUw6OTNiTfWSbDRexeJIRUNdSZx02gTgoOMT01BptEWc6bDY3g6GwIe(tT7p3cmHooWsIb7A6VLdPeNoONTa5EkR29Fo6E0MRgbtmS51J7xD2ZEhUrleIkTsRtMmSJxh2ojWRCg7HIPJLnuyePpPE0NnxMck0tyzAPBqJlZUU8mxRsy9JmgAn692xzSnc)52LMnXMAnd2dNZ7xSQLCynMl1uvyVYHbuPoQ9HhKorj7mAnypagfb7KqBd2(EzczdxDcWr8bQ3PJAtyuBcJHrR6RuFr2d5Y6z(YIGnhn0WtoUJmkUFzj3(OpbTNkyhrylwSvonwZsGo)7it(WaFC54rh5B9gDRj11itA2OYAyStNe4Pw)SFM3cgqh(bhzaZQ3pcsx3GdoE)UgqWOE92V7WJSFgXRVVe1DW9Y8lAp71JAwJnk874brQU55BWnjU3JCA3rh01txjC)X90UVW3p66US3D)xjQbHVsncxpKwRkhCtyFuQnE9xde(3vtJHyv3wnbc28)d3)tMyWJr23mn11MuJSBQnK(bzvyVhfR)P1rw311lv8BEyeaop9oNJWRREortDv9H6OH902L4YxTU7z6STTqQl9S2lV9ir0RoVQGVEhdRqKiS(L4v3lJ6C8NERfcNetkde8elytFTRadoKJnpN0(weVYoOoeb1ZLv4xnUCjSA19zRq5oduNxEfyz58YRJFRmJPOPBFu)iYJKV4zkXd0kq2S19QpThB85lXCjW1y8b6k9Kp47uVXmSByaYC1fO7LLlWaXq99zwvdiPAFSMNI1vPNl6dfY2hfjwOYabHF(AXi6zeX6fr6lim6jvyc)i7RmisKD)Jf7p5TdnsLrcRZOXyD0pLQQhYxLZ1kxq)z4jHMsAp1SxuyZy1rLrOG1RT)n1ogbAsdzdDiRnYK7uINwjr8WdDDpcQV3jb8JArK6sNX0CG(Q(Ty3x7ZjRkxXqlK6b2tY)qRqikwDd)JV)mtCafaurrL5Jk6toHuTVtuytbmZYYvDvYw2SaGET1LCLfVQ1sN71O11HVkwPnlsFL1NeuCT77q4FZIcJwb6xlMmACBwfw2jwlHewtQUzYmKQH1ZVNPCo7bbXxv4D6FDupR90TalKCTy9NS(TsTyhifmsoaH2kjDGkd7qJhsscPD9APpOV4m1Ox6XZbs7sSulk26QVkybP3TPtZE1UBSFmqDLJfObkApEpwPXufDy9A(2iE4NESDQNDtIQ5a2iBhkywoj0RX3toM6t)tXpk2VHA98x8)7p]] )


end
