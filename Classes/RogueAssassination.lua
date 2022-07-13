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


    spec:RegisterPack( "Assassination", 20220713, [[Hekili:T3ZAZTnos(BX1wJIKFOirlLjjRL2ktC25MzNj7uX5Uz)KPPLOS4AjrTKu2Xx5s)2VUB8GaGaGu(XKCBT1D1SXIKan6Ur)gnoV)5F(8ZMgveF(hd6fe0777FC3EV543mC45NvC364ZpBD0KRJUc(hRIwc)33LNhLNNSkQijDf(07wKgnfhL80nztG3yErX683(YxEvsX8nx2Ds6YxMNSCZc6lMKfnRa)7jV88ZUCtYIIFA15xAheo)SOnfZtZo)SZsw(EyGtMonM92X5tmaLTx8P0R2eV9N)5nlUB7f9doC7f4WT9N3(ZVFE0QRIZF72F(OTx8U1RXx4f5fzjtkEX2lMTi6QTxuKU9I80LXWl8B)c8JPzxNZ)1OBGFDDw6KyC2W3nzzCxAWonD1lk2EX)t0QK85BVyZQfW7S9IZwKmb(MOvtHxH(N3MSyX2lweLdV9IuaAYGHbaRTx8RWVH)Ly1Wg4pfVi6lBV4VcWw8If8v4lHzkE104IIiaSUB1KTx0ozM6pMqW8vxTigM50zWZsHHg)2i28U9I3FAh2u8RrxhJZqC(CIQaF9kasY2SM(NBVaOCxgH)ByyUfE1)5ge6NMadDsbHI2EXnPiWTiompDXnXRkyd9)Do86N9dNT9ILPzXC04MLlra5VfFtYQxaW5Fp9)nEbHpXj4U0nBVyoHQlMhJ0InlUmz1u2a((0v3eNbtA2MvXH3MMnT7SSueCWH(YnZM1v(Kq6jD3SM9PVdyAai(3HXkFseaY)(84I8I0vCs4NVngqeWB8HVKdSjBq(joiFvmmbBYXhYbXxGWNaDFu57pT75anpViN2iuehTawe4UIpsBWIxfDjqso)haw6jSnotYswMNUkSiE5648cgpDwYA2t)yYvZZlIwCDmN8D8NFlGfyFdaZIpc(cGKLebBwJwGO)vWhwW)YU8PD7fTa85AGpkSikdwuaYF8iymPhGu50W1PaXN)7dOFN9QDrE9WI0WPjWkhqxzXlJswHV52lE15fWEwhlqKpAtwCDlS(4cdKTSoFEkGT)K4RA(k7XUao2XcyDA6IWSyHynTLXzBUeGUzBUk(Tsjk42Hpfpd(I54(9I5mgtek)XOSS0I48Zpd20eUk(lfiJb8Fg4yUVI9bwqd5YzwdjShtet4I084Wynoz4PTvw2NGchjzjQV20Wm6LV)EquhiSUiz9IeKgDcGp7V9IonfLgaW8DtabcCwn(cD4JcjV9IdO9NxPWZir1CKliIRGl7iEfj9dy6z7ev2nVeLQoDtgxI6LXZibuQ79RqKELbS3uAc)PQOzTNJ4GBaQ1Q4LjXa2JHPBXLNPmOA0UUhxLnPa()o7gsjKnzoPRbHsXfLF3nra4dpf)xl2a)pTjoiuekS2HzCACuX8f3fMppAA6T5AGDmWtZG8Q78MSoeWWHGWgKe0HXp1UPJS(4blwGpTJbtXFnHPQLTbJiNV)34kJ(OIiIdl1gVHP1(u2mdsBytnHgczw1OkCjewetsxnnHMqps44iCD4tykad(y8ShOdAVf19(fWKOLmyNmtG9MzXrtVJVAqoqG7(9NAHJZjpvDclfu(UoxXCkr6cahTsFI04d9j6SbygvecddLYqcwXoLw4Sz9UOByV63f2qmY0yAx5nCabmVWN8BdXAaLmlkmAz6MvWUWbdRiIXu8ytfXiPtCjbay5aAf6bMMwiF5mMiuC4y7uvFOBTaQBtH9ZZsMGMdIB)BByNr3zrRctNfE9kqCbkI4VqkNzdtwuY0WyYOXOPtZ7IMCogvovHpYIm4DGttZa7KvVvAKXbsnhRs5M8MjuQKHEmCiPQGeEiyapa8c5MUGmeY6B2eCw86C0W7zaZfyK)8eUnZRtb75rolv6zBjh5scUcJe29lPRiLOuG5YOSRrCiOzl05N0rWTJuqULx6K3wMK(sv2hxhld7j54kh)vItX4TvfnmOKzkNqnGbdtUMqJDKac)jQF3Xm9yahveW6jvKji1xddIkpGfjZACbFkwQ(xLAalPvGOMB2SyvCgd3i1ax61tNY5Lpk2K3vVIvVBhoHmxQuleQNsA5KnXl1pFWsj7Q7a06vXRi9ZjRq(dKkp0a)8E5t)a9rOjvWxHkEIjxMyo)wGglfRcMSbx8KP2KFvpGkLCvLfAFfHYINgozAMkmu(78XjK)5(nyt6Aw3mmAb4pGrba50k9mlcOyS)ie9PJ5zNGej9Td(OV3LVD(gHjtjy81o(2Cm0bHGspW66kwe)BBkqNLofvdICRG6jyQegm8(nC)HjJGF)8OCucwMUljFaCKEv6s2EIikAe3wArSkUApHHOAqKqUqvB)ifzVXXYkMnTgRN)lqLlkAEDwskmV3PaEtarD58fgFjqsqOvp(JvT2xnyjQlepRcBpsvK0qxEyIR1(9CYNrJ7mf4jK(f1zT6t1mVY3lcgPm5AMiZEoaWGQOEeIDgncFCSG4A6JDzhS)pojd8wG(EtPNLOlUulnBj6pKml0QaTY5okBs0k0z0SmqNknnduvAWF(6nlYJnuE0FO6lUGS(l8FUz6vlXrY4DFL67Ez0vKgzq0X156Vj8HRHfmPdPIgSimqbizkNrxm1Kjh)0Ic4jHaL)U4P3c89Wc8ljMFJlRVrlgWVgmXK82Yyt9KuGFicmabn9A(DzEngBOY6jmpgTjgwXaNVfTtkIzfbVB9M8InGkTy0Mea40nYr(AvIIOyuLRPzYWu(Wu30NcuHUNOBYV(wYA)8W1rftMxcC7tVAVUdy8GOzTXfHxMUAdAltCwWRdhSEc9E96YSlUd5QQnfuGIll6KEqGC6LXttIxnjwdub4CqvhL)mkBm6gWghm(jV)0pXIoCVUbbOGfmsUBIv0x8Pp(JGQFuPEmtCk68fSPdJJ(xW3b)Ac0ydukmplr7Djr0y0Oj5ZlsVkzIkIqt8fhzyQ40lYqmqW2TvxdKbCQcZxKQh(t2d7w0VlO3leKqcmYRUlC66CHzSOVGI3kWYBHCKkdJ0aLYOfHILugclVrNkdtcUxcilBkW1t4)AdSZBZsyJ5nuEb4XhX6EY6a4wMtelMkxLfLVgeyueVSkxXPXacBjidfShyEYK58miaJzhmCzOsvufJCKzr()wa0ySkrfyaR5)rUItqchK6wY)AZmN6z7dSswDS(niR2i(A0dReTX1r3nPQbpvuvhmR6tKDQQV9fwSdRE8UDjCmCSnaEo6lkg1yAB)UX1Rb)BYJdfRH(HG2MqHStRgz9eTscA0kPwkTZvsq1vIMTacVknSZWLnwMUfOPrVUOGPeia7QZ5oEZmvZtsRSBfV0MDu6XauF5WdeIfo9SoOMKUBV4NwUeuEboms5kb2vfCWwEcfYp0ukYHmB8z)4N)b8pbLuz3MKtsJKPFKLXwUnIBV4DlYtfphfRXcQkzDmtPf8pjI8M1AbLXxiThqMaWrXtJJxhNbSna3cOwBPgAUT9GOOeUeTqO4Xhb8XM2eJHGlWJnXSVApfFN1cNaFqDTqTe6(sXR(IGkoQ1eT4X8a5BjGn1Vz2rWgjpKEgqtMBNNLSyrCMpRTZJZOWGGICadyxNCTPx788ds5dN0HILcGmtSipEkAowKGnb(N5L(eFi(pJNbZcR2deF307O)opfMw0D4zfSAkiM(uWhG7eVSkNUCvxU4udDOLfti(78a4zZQFV4HNSjENsQy9KK)gSpgeHKXI0W61eQCYCC0ZzIEUCt2kBbzygjKTjRmJG1gQ6EFVUVwSb7Y0CMwFAKvERru4h02FzzH1f30kH8JKRIWzzm0bAIoowGH)d57cDfm96XB)(CmaH)67ystPWMJOO5aOxgePd1TmCA0sYfeK1wLFhmok7wals4(FjocqWxIra6lrlxVWufxfD6bCD6psSV0f0faaeE5DHXSP3mlsKOzZ3XtYwKc4xIbC)waNcAlOQojmE18iWfomkdYx1Jy7wv1E0XMpukEF)CGR4WWvzBMEfMic0Fz(6Vg0JJqlm0pFNVqKAJnDbiChCVemMzO1irCnw2r5HP8IosJ(sqV5lGB4m4(llRPhtbn5lmPAjiWmZ3y1IHIG(B80hG786)Mdi)2MGvRg(W)lQi52EXpSiAQqww0vi5KBCMixenrewBoUHv5DHxsJPi8Juq6EJ0zN9kvzfMLwWDDQvDzeKvhshiRvdrO55ruXMhapiKfP4LPiMfaUCgzcSvHmiIxLCRKAnHffH7WFbMzW2vn1VmzBLbUwSK7WOlh)zv8lBkifAtHnjYGaI)cTlJ)cYer1Ydk1mrTYKRjEGi)FgzDZfrUE6J1qhxp3JLK4yKSgMHC9uCWyY8umCNzXKnmRMA1PO6N62EeQH6cfYTuIgykyGiYFRBAlX(F5cS4btMgZL(wgq3LxUHLF6kb3wgm2nfjlOeOvXcMgSo8sByH5xpOFrxE0VYNrnE(tj2UTx8BeFhJhnqYoxg38MILTSajFiXSB5XbYQHMUuUD3H(XrM6rktqDno9yRQ145or6MJJ3XU3h7JLHL02mxfdHHdvguQFcnZhwgW)fd46M1OvtRswluxKsHOJeYSaSFaLE)5pFAxET1Elzhg3fGz8cCGvpXyyBLWHWjAMdgOOmWxCBoI5MavbQXSNZGCwrnt4kCsqf7eSZQCPJ7H(1Vbb3FD2PCh25fSf6RURijQxZZolKchMvGu1JQA0rzW8A1CAMK7QAG84k9QXhEPH7QVIMJXywUuycjhTNOxAW6cK2t1Da0GqEjJj0wU7LOqDbqIpRp2OaWYM6rKyN9RnGkMLckXFuwfy3ccKX8wxTwYoqVmUPGBdIatMiwZvsqJEDFPw4F7E5xuIN8wDpovFBnIX2zxr1yMENrb(czYlXu0UozHoXRiQ3PuDKy89jrqOkb96PupH6wqDlJ0ry7uE5SukhSfVYyQSFxIAU(o4VxzGVwfpjlDrA2uZFhKJwlVuvPourhkQRlmAmSZorehFDl7yFGfBnf3Mj056aDOLlbK8LxTSkuZjYUNkWzlsr6rB6)3iob4okMMSxspUp(xUkHgrQkhJh7LAhZJQvc2UnRTQD8iZbBu4r5(JQnmshVDfsfCzzLNIVDRPSL7Akm)wHiAw0D728jKCzwuFpmuoj2nCwuJLfyjIa6U8PCsMiXx)gR4d2EXh4vFatDaf1kP3MmBKqJhIkruW)cne9C9628PQQg2wwUMLo9sbfM9JoQeZ6DOPTmM3c7yPGdQwfGbs95vdQ0zYZ)vyYmLqNyUo0ErrwDqzB2QwdL39QfPxgTGle0zeq005yrWTUGA90g9uiRM73V(5QJzP7ekBtxsr)GIPYlnpVDD6Ag3sZOAWitnX14tevMB1xwvVl9k1KaRw2DWrrARZyy6zF9axbOPwmq9GB76LTnqr(fJ7jSC)RQSmZkqzhKFoG(FAc16XbkDCSbWwGxkddkkg26EeHLlp97ooKx7qSusPepmW5ZcX(Kfu80OIlnMgV(9YBaxHvRIz8cEQwyzXs(0ZHJFANAIaL7941WB1xQVVchtJ4n73Bh5nTnnDQWozlww1BBJhkALOr6vjx1LJD3ZAQGrBONQEzOF6rKBxOZwCS6raw32HdLhLew(WOG4qUoqAZPswq4q4lfZlYmZN4CUNx5WwR8zjOxVwnfsXcOkrPZYUFroG5rM2EvDvPClkRVckKni(tWQyyh0EgXs2EX7W2Dzd)RsFQDVDG7XXsSK9xhxVKvicSr0s6wduJiOCgRuFvkNuZ2ULR0yuKBaHhKPAGKaLavzRq34biAhWI8PVJ0wrFqqhS4KsXuIZFOIDGYFPquU1w0JXFPGgYLf8nexM1Yj8PKll4bXLzdf9y5Y6BJlR)xpUSaINY5XcKpZwcFn)0a)5Gxd2AUEcEg)IxeDhgqmWjhTiyFA6NH)obn3x0dmMGrEcn9x2AlOGUdi5J)omDV5yu2YLTZaW821GiE(HPIg6jBOJQGyGfL5u1KT4Mx2w9qq14iNuQAifR4gxpHhGBxpLomQHmq6iYXJokCPQ6XTpGvEQRbKzpLRtovS25WxVkd1IRllbiMUYt6EVmfvTjvmt)wzpcGLSfEecy2chVkDZvZBONB7T19rO1WIhjZo74e0NLMBxhKaB7WzgcYQaXb0BPNGcrezSnJ9Wmun2UzXD8zWm7Sn5S4lMNCJPvhWpX2HaByYvtOf(BFK5aXFnICjWroFeoSGefLUzZmnNuULT7sDF38OfZWd0FYnybyyZEf1S3id5KHrOYyG4XjexMY2wn5i1L5M6RmhlPVeNzZbUm1(eXYmyk(c32t7AVTTOlk1e4mWJ058M4dpWP25DvFcFahXR2uDowmLN1CC9Ue83A6Ina2fM7jf16D4XoDSSCUxNkmCpWD9t4BaiGkC2MS7ObXTFOEhK4S84mrbCg4(C45BqMLKftqdngUlwaFJbw3ByQ(weINzqAGC35dSgEuVbbTCI8EKel7QabUSF4wE3Ik8wrZIsfY8xXmihroGSMw2TLq2eh5R(v9QLr77f9EnlqfUiCFmKNmpgbTOj)Rnmac4SZHDX5vy(LVs0xIvQSI6Q)eMvH1S0QdD1xAeOVOnouGf8TSq0HtnxaMlh)Uzy1dMTc4cXt)9mZsnLjw01lhoOjro64EcO19SYoZfPwpWf1hXf71AxBtRtkbjPiwXdl9yrtiRXP7FBLkx5xswIPzMD6rOYmx0ER4wvvTO4kvLZkiYJhkYubE4uOMoGrAQXT7XFzDsgpue2RR9YOLKFDY6qw1dv2uKEah3a3O1QQlRJV20PYhaMLBf7JgZYnrlNz7lD6B(8boWFIg32dQys2TUiItP5JPuA1XTj1JRw7BCSxjktnfouFB5LM9AXsuc5LqjAm4abzihdInMsrjxO0ZcWA3kOqfKxT92nDJOxhpjbRv)sxvqqsozaAhHtIdGz)SUdryG7vfKvxBpAVT(AyCtRPra1QjL7tq97sQvfsfOPIloNyZrgBfJYtjUrWp6a30Ex6sAncx239wbVicnlHvyoDz4JV(XNKZCZ6RJJPyDtN3oqDMOcRPqhJ7cX8lfreFgx9vOqPOcK3LKKr7KyTdvSCJe9HpSGLOg8gwHPg9il3h4btNWDxFFsYJnchzLMAaYqFDcrKz9mY86yVJIpHUyH8nn73ODnMtMnYUABzuggHMBaTIsut7Pujlo4B8KFF7s)(qu2I7u6vnswnQe9lyYPR0TAGfpLmskmq3H(lVgeAgVmzsNTwo6wML81G1t0SQ31Xg2HonFTalwI71mI)BfoZMXSeynX(nJ07mJ1w6QPQH9TQnCCS4)z3D9eS(bnz7TTtrP7(6Jzlk2x15BP)cZGO6R1d39SSGEkyCVXiYZ5ErDxyBcQoGqW7x1dxjuXIvTmUTS(WYof6wHw5ovnZ3SnoZSTKZYgVTSMkeNNEudjlG3zBwTIwAub9JgjfC0WCBf2bZowwOTLUcWYnDwmfovy5Wo7LYWHleqATiamnIW2bQfhPYaVZHEQEA1oYZTzlMfj3KWAzmLrHNdJSa7ZtJshVcmYeZxJ41mfM8VvclQtsXycEgic6QYHFkI6UAH5ts3SAAw8cT(l0qLa169atz8UUD8DFYYEz2GC5PKDwntBfklbJVbSvOEoWNeRjE9)FLEZspU36bqs1R1kb1T()h5c)7LCb7MQ4YT1kMQyCyGxSGv1UVl9dvVgfe7Xzht7iejtDXmUxSxMEtSOShtUAvkVpCWexWI0MAfDjIhNqnlVEdSCXg8imzYimlnWGgVPD3p6ZU9kN9zXbOUuuQq7DmtenDAIe4i6jut5r0UG4P1DAQiNUIofHSX095F4L)678GYgPxxknIXLICpkQT6fgIy)Ip8FBZW3C02YoJTPue)bsQT18WQKsrTMTGwOp3HD2dOenGblpolhPNSBzNHGw3ZUnkdnNm)8Z(939Pp(tF8hF72laSoYANSCDkEHRqgg(czI4Ebo4S0USL39LI2uKUKT)Dc7I2P72F(xOwm3G3kV6wWhJxJpuE)lqgJVJrJ)LnyJVbmfmN0sNUweNO2VewJT7)f86Qz7pxdaYYP3UbD91HUxuY(8pEbd2u)jbhe8O2beqXgLx9GhLgU0KnSRDB1zG7FH84CibRYFPku9Ogd0CQp83)fJbB4Jer90GUzJY3BmkIkARF5OOuKB4V1Eqd(8alFo73AFSYN)6DF2BYN7z2vb(3S7ZUk)E)E7(0h0moDwdOB3yZnrgnKfvJBOFWJKPQ2v2KP572Y6vpEjNbUzyFSd3dfP7Jp6XctMeXV5gVNmLH2hVMSpUrFVN9XAF)WN41JP(HDD9467RD9u7U3PP7OqP(h)GfO8hklZdeSE4AY1ggtTOnFy6x3WWUIav)gA4mS7)FagCRYg8tevhhKVFl)4sHrPmVaPSyTHKolbR1H)0FQSec4bxIF5tIpXYfqj(ZLxcL4FD0t5frjFaFEUmk5d(Z9fsjFAEUUuk5d)t7ftjFq5mFB31lNsbFGVlOs(78eDjvk4f)WxINSHy0fjExGwVm(kWXrS98mzs8A0P3vPRoAEu2YzBwi2uKJuWf3bdh)V7k9rzK6DCGLNFWOx662nW(BB2qIoSs)lEu)EhMmB0EMnZHwvRPKX9hAFwkpW64q58G(F)9opu82hxrOUoelrOrL1V80SdPcMAu)JARe1cZBKG9BJ3bbh02w4M3Vx3(D60biOCDwFL61)nzHBESNTT4L3Tb7J3NbS11ZF3QVjqFLJJKa8rELsRumBL7TAVxPjiMp8(7l)WkNHSXJk)WkpSJ6N6T7KF)9TRSNWdi1sByR01578yqvbQOkltDjQQkESC9AbBm2dASJ6x(WXuwOSAd7ddt5(uHYrz22Z3QTfGsT913yEJDggd2Dy0rl2VXufhWipwKoEOwFY3MYcsxHNgEwl1G4wrFjOoHkazkvmKSuakqHIushVjkzbLzdjWncV16izzpURJo5aAbbuHUPDiIeKk3zl6Kaca3P7do3tUrsD4tV1A8y8XdDpoopSp8r05b6DFlNxOPzQtK5PdHJ1KhRFMf5mwfZJbyTdZKP5e68z)UAtJLqNThzXzzvW8wpRLAgngpQpbQpFxdBQWi)YJabohWMTFMtupzObKpW3qBRTH1YXtetqFxVa1UJp54Egaqq9Scy39T(xIc6P67PFNMHlk9l5aGSn8a7fnv1rHU5Zu)DJl6m1hPDVMj9BLVpJXv)vSTLwkWh2InQIFb8gj7O(DhEOwUJz7JR29ybJoSFSlbfuvsRgq)7aA2Q(72QgX9by4(7T9KXJutEyhjk9RypvvdTAZHllipWtQJ7DKRESAR6x5aU30GlWgmN7DrKjxAVT(gi4whrC8DgCV)(9kpnQY(Mk3)PNO2lQjQ0Hcn7D0gUAnFMMaRbphDbfKKTJrWjdpky)6UgBqKXZzxeTHyi124JbEXrFv9(7TC4LrmIHv92ynh1ZbtWZEFbTHOJQTSiCtPrdrvzXkBgQQ)gizw436tZ0YrP8bL6wvTBRDuipkOxNVRD)GE2njRtNXo(QJ8UD3)y2Qgrf9U)EpYzS3wrHpbex2sdmpjO3tdEuEY8FEXK6hbF)JgB3KEF(0jo4pPhVwAp)JU1BAIA1dqx7hse660ApTZtER9QwkMTCu)8J61QTNwR54aq0SEH805qlnjt0ueJ2HP2pPg7XQbyukJ6B8wGzvAxj4sUMy4tvR2wydnC67KJBv9Luvt0YErBbok0QQvBKuGQuF7S4d6SZli3WsB77tha7hfl5YnLMHn1528bhvpgSHZGQbrFd2gjnjfmzuwjcwmiOvBNrna8)7XXN0Vxf(epaND(aym(obe6Gw3VxJO1YrPZbYS28TeurCzFf70Inw1THvO2yYmo3rw1Ruf7y3lG6KYzdlBADHYo4IN6wbPjEddrCc4Qv(Hu7zteJFYLBf)RDhT77V32ssSC9SFnW(xQZY5l9aFxayNJ(E4rbOx(YHTs2mg1VvBBIdA06S6ubU86zUc0sGKe8j)wB0AhMbyk2Z9uurGLdQzGhQzWxdQPLeb9qOMb7a10CDURuZ(A546zIAYJM03IT4WkcCfYBawlV8m7zljtaU2ABmC8i7)Ez3i8OJbxeBBTLfY)ypTYq8JzO5N9UrOj(snKo21DVNJ(syllDnI9B3)aRfvq19dDgp4Gb7Rg8oM3HMJyVUdhx1cQo2SQAatdL92g4FE7xR2gyfZ3GNRxzjsx1Bz4TNvJnTzBq79QnmL2AsGL69nIuTNMdyvZr5RNNYLt7QXxGeO5iSdJ7h05aRQbAQyqyagfuzPX6ZEY8)y0k)SAV(XwnT3CGl7)E4G3G3x2Q9A27l7QEn711BGEn7BSN2j2bMXqscgveNraXLXcSXRAVPJYEQ7Sop2Ol5D)9wYYWR6zL299(HfpDiojlIrdVRvBpGkO82bS5B91VJ94jm0pW7SHXPKvxVnNohC7y(8yz07uwghLh3UOltwakBJzz475)28)pV9P)28VeNYYN6iLuc7mAmhut6qSBEOUOsVrtwpVTGvIoYBRQDDgc4Da8APrSuRYdiVqJvLMYqEv8hU8E)uw8fwYWx)NGfmXc(1(cZ3c(WYDoTMLRLyOw7XIDU37Z(godwYJ9dFg)tyjo)4U27Biy7amDOz5KEDFDR2wKznAOMDeEV67pQ61E)jJWR8EM56)XDV13Cuung61uexD3G9Ty6mQE5S3YAGnXFPU7SEN7EBzKdKMJmEsWf2o20W60jcWIs9He7YtZf9Edx9Ycxz4HQ5)X4(ONvDs2UK6zzG7P9YH3cORzCJRT4Ss4WY1f)4r9Fd40(Ev6VQT8zc1OJpWWnxU73F9VE3BcgIn12V23pH)qEXE2YcQXrnnyXpSow3Q4hZAzbu52x3fzUj(P1ZYeWUV0DY84o5R7zP)IWfwPE5SZpnepSlbDlWR4UnVPkI95drGVX3(4jnyNRjINpnQ2J1nA)BMEYSYImTyKUvKv7VFCRjRkuOTLw(6jsBbm7G1kboWO6J74a78S2xL1WbvSLUA)lYdwqpQm(2qh0qKWFOTh5gGj0XbwYCwBt)TCiLyCVo2I05ywXT)u0ELnxncMyyZRh3VATN9waJwm2u61uNmQFlVoSDsGx5m2JvrllBOWq2Es1WZAUmfuOhXY0s7sgxMTD5zUwPI6hz03A4TTVYyBe(JTngBIn16wQhoJ3qvvRjVkmxQXY3EP1cOsDu793lDIs26WQXEamkc2jH2gS99YeYgUQeGJ4duNXdAsCgRdJHrR6RuJd2d5Y6HIYIGnhD8VtoULmmNpVKBF0NGMtfSJiSyXKItJvSeO1)oYK3pWhxoE2k(wVtWAsDns1KnQSggB8OapfdN9dfwqp60b4ifrw9(rq6AhCWX732acg0PZ(T7FK9drD19LOUdUxMpRn1wpQzn2OWFIheP6MNVb3K4EpY42doOTN223(d7O9CHVF0V7YE39FLij9FL6uSEiTwvo4MW(GuB86Vgi8VRIgdXQUPAceS5)hU)hnXGhJSVz66P1Pgz3uBi9dYQWEpkw)dRLLURRxQ6W8WiaCE6TwgHxxDCIMAR6d1r97OTlXLVAT3Z0zBpDI0XbE5ThiIE1zLve17yyfIeHf4dV8xzuNJ)8BTq4KyszGGhzbB6788BWHCS5bj23I4v2b1(iOEMSe4QWLlHvRUpBfk3zG6SnxcwwoBZvXVvMXu00TpPFgYrYx8uL4bAfiR36E132Jn(8LyUe4Qn(aTLEYh8DQpyk2UiazU6c09YYfyGyOgJmRQbKuTpvXtXQQ0ZfnQbz)vIeluAGGWpFTye9eIy9Ii9feg9KkmIFM2vgejYU7XI9N8(fgPYiH16WySo6hJt1tbRYb)KlO)u8OctjTN6gkkSzScnYiuW6f)(6k1zVM0q2qhY6Zk5oL4Pvse3FFB3JG63Dsa)SiePU0zmnhOVQFl2EY(sYYnlzOfs9a7n53ejeIIvyT)47p1ehqbavu1v(OI(Ktiv77efwxaZSSCvxLSLnlaOxzDjxAXRAXM5EnADD4RIvAYI0xDVjbfx7(oe(VzrHrlb9RfJgmSjRcl7eRKqcRjv3mzgs1W653ZuoN9GG4Rm1g)xg0XAtplWcjxlw)jRERul2bsbJKdqOTsshOYWwy4HKKqAxVw6d6ko0j61M7mG0Ual1IITUA8awq6TR74ExU7gBybuBRyoAGI2R3HvAmLrhwVOOnIh(4JTt9SBsufhWgy7uZYYjHErWEYXuJSFcE7h)gQ3SF()3d]] )


end
