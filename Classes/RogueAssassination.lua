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


    spec:RegisterPack( "Assassination", 20220809, [[Hekili:T33AZTnYXI(BrvQLMupOjHO861hjLYR1MKDZU(SLLV3nFsqqKGIicKGh8qY6uQ4V9B398aZmyMbG6rSVPsLuEfXJz6P7E63tJlgFXNV48zrLXx8XGrbbJE74jddgF0BhD0fNxE)64loFD00BIUg(JvrlH)99ffrffjRIktYwH39(0SOz4OuKvLpfEIfLLRlE3RF91jLlQUA40SLVUizzvk9gtZJMxI)E6RV48RQssl)5vxCLDqy8fNhvvUil)IZppz5hGroz2Sy2Jhxm1aw2C5NYUUkEZV8(QRRkk3C5pS)MlXbCZVS5x(WIOvxhx8Un)YbBU89RxNE)MlFvrzEY0YxT5Y5PrxV5YYSnxwKTmgEGF)xHlMLFtb)Qr3cxDDE20yC6WNnzz8qAWolB1RGj7)B0QKIfBUSAvk8mBU880KPW7eTAg8i0FExsA6MltJqqlndGMCyyaWAZL)gCn8xILdBG)uCA0x2C5FbGT40u(s81WmfVAwCzzeaw3VA6Ml7Nmx9IjemF91PXWmNnhUxgm047gXM3nx(HZgWMIFl6MyCgIlwq0f4TxbqsE1A6p3Cjq7Ukc)ByyUdE0)jHyNLadDsjHI2C5TziWLghwKLEB8Qs2q))PaE8Z)XZ3C5YS8yoASA5seq(7X3MS6vaC(FN9)gNs4tCcUpRAZLliuD5IyKwuLEvYQzSb8dzRUnohM08QvXH3LLpB488meCWH(QQ5ZhkVtiDNHvRzV67bUgaI)dySkMgbG8FSiUSOmBfNe(57Ibeb8e)0xka2KkKHIdYxhdtqvbEtoi(ke(eO7dQF(zdVaO5fLf0wHY4OuyrG7l(iTflEv0vaj5IFe4PNY26mnpzzr2QWY4LRJlkzm15jRz39JjxVOOmk9Myo57Wp)oalWEhaMfVe8gajljc2UgLIO)vWlwYFZH8PDZL9a85AGpkSmkhwuaY)0tGXKUbsLZcxNbeF(1NqxN9OdrE9WYSWzjWkhqx5XlJswHp5MlFZfLWUwhlqKpQkpUTf2yCHbsxwxSidW2Fs8wDFL9uxah6ybSollnmpwiytBzCE1va0nV6643jLOGBh(u8C4nwG73lxWymrO8VgLNNvgxCX5WMMWvXFPezmG)zIJ5(A2lybnuiNznKWomrmHPzfXHXACYWD7RSSpgW5bKSe1hBwyo9Wp8aiQdexxMSonbPrhd4ZXBUCqxrPbamF)uqGaNvJVqp6jHK3C5E0(ZRv4zKOAoYfeXvYLDeVIK(bm9SDIk7MxIsvNvLZLOEv8CsaL6E)geP3ya7DLMWVRkAw7(io4wGATkEzsmG9yy6EC5zkdQgTB4HnztkH)353skHSjZjBniukUS(9UncaF4U4FLwb)N(ehekcfw7WmoloQCr69HflIMLDxHgyhd80miV5oVPRdbmCiiSbjbdy8t976iRpEWIf4thyWu8xsyQAzBWiY5h(DUYOpQiIy)ATXvmT2NXMzqAdBQj0qiZUgvHlHWIyA2Qzj0e6rchhHRdFctbyWhJNDpDq7DOU3VagfTKb7KzcSNmpoA298vdYbcC3F4mlCCo5PAtyPGYp05kMtjYsbC0k9jsJp0NOZoGzurimmugdjyf7uBHt16Tr3WoTVlSJyKzX0UYB5acyEHp53gI1akzEuy0YSQvWUWjh1qeJP4XUkIrsN4scaWYb0k0dmlRu(W5mrO4WX2PQEt3Abu3Mc7NNNmfnhe3(33WoJHZJwfMnp8MvG4cueXFMuoZgM8OKzHXKrJrZMvmen58uu5ud(ilYG3conndStw9oPrg7j1CSkJBYBUqPso6XW(KQcs4HGbCpWnKBhcYqiRVztW5XRlqdVNdmxGr(ls42mVodSNh5SuPN9LCKlj4kmsy3VKUIuIAbMlJYVbXHGMTqNVYab3osb5wEPtE7zs6RvzFyBSmS7uGRC8QeNIXtRkAysnZubHAadgMEdHghibe(DuFVdz6XaoQiG1tQitqQVbgevEalsM14c(uSu9Vk1awsRarn3wLUkoNHBKAGR96zq98YhfBY7AxXQ3TdhtMlvRfc1tjTCYM4L2NpyPKF99aA964vK(5Kvi)bsLpYa)8b5D)j6LqtQG3cv8etUmXC(TenwkwfmzdU4oZSj)QDavk5Qjl0UkcLf3nC6SCvyO(68XjK)6(nyt6A2WCmCb4fWOaGCA1EMfbum2pcrF6yE2jirsF7Gx67D5BNVry6mcgFRJ3TadDqiO0dSUUHfX)Evj6S0zOAqKBfupbtLWGHpuX9hMmc(dlIkqjy56UK8tGJ0RYwY2terrJ4UAlIvXv7imevdIeYfAA7hPi7hCSSIztRX65VbQCrrZRZtYG59EfWBkiQRGVW4lbsccT6Xl20AF1GLOUq8SkSDlvrsh5YdtCToEKt(mACNRapH0vuN1M3vZ8kFpiyKY0ByImh5aadAI6ri2z0i8XXcIRPx2LDW(F5KCWBb69nLEwJU4sT0SLy8rKzHwfOvp3r5tJwHoJMNd6uPPzIQsd(9xxLweBO8y8rQpykz9x4)SA21lXrY4zFJ6ZEv01Kgzq0Xnf6pj8IRHfmPdPHgSimqbizQGrxm1Kjh)SYs4oHaL)(4z3b89Wc8ljMVJlRVrlgW3gmXK82Yyt90mGFicmabn9AX95Eng7iL1tyrmAtmSIboFlANueZkcE36QIYkqLwmAtcaC6g5iFSgrrumQY10CzykFCQBgtbQq3t0QIBUJS2ViCDu50f1a3U0JoA4egpiAwBCz4vzRQqBzIZdEB4K1tPNB0qMDXdixvTPGcuCzrN0JcKZUkEws8QPXAGkaNtA6O8NrzJr3c24GXp5dN9jw0HhnmiafSGrYTkwrFXN(4Ffu9Jk1JzItrNVGnDyC0)c(m4BtGgBGYG5zjAVljIgJgnjFon76KPQicnXxCKHPItVidXabB3wDdqgWPkSintp8NSBoSC8qqVxiiHeyKxDF4S1fcZyrFbfpvGLNc5ivggPbk1rlcflPmewEIbngMeCVeqwQkX1t4)tfSZRAjSX8wkVa84JyDpzBaCpZjIftLRZJkwdcmkJx2KR4SyaHTeKHc2dSiz6cEgeGXCagUmuPkQIroYSi)FhaAmwLOsmG18FuO4eKWbPH18V2mZPD2(aRKvhRFdYQnIVg9Wkr702O7Mu1GNlQQdMv9jYov13(cl2H1oE3Ueogo2gaVa9ffJAmTTF7461G)QI4qXAyCiOTjui70QrwptRKGoTsALs7CLe0CLOzlGWRsd7mCzJLPBbAA0BlkykbcWU6CUJ3mt18K0k7wXlTzhLEmb1xE0EcXcND(autYWnx(ZlxckVahgPCLa7Qc2BdpHcf7BkfzFMn(Sl(5Fe)jOKk)UKcsAKm9JSm2YTrCZLVpTitCFuSglOQK1XmLwWFse5Q1AbLXxiTNqMaWrXZIJxhNdSna3cOwBPgAUV9GOOeUeTqO4Xhb82M2eJHGlWJnXS3AhfFN1cNaFqDTqTe6(AXR(IGkoQTeT4t5bY3saBAFZSJGnsEi9cGMm3oppjnno3N12fX5uyqqroGbSRtUX0RDE(bP8Ht6qXsbqMjwKhpdnhlsWMa)zrTpX7J)z8Cywy1EG49MDp97ImyAr3HNxYQPGy6vbFaUx8WQC6YvD9Itn0HwwmH415bWZMv)EXdpBt8wLuX2jj)DyFmicjNfPH1Rju50f4OxWe9Cvv(kBbzyojKTlRmJG1gQ6E)OHVvSb7QScMwFAKvEQtOWpOT)YYcBiUPvc5hixfHZZzOd0eDCSad)pIVl0vW0BhV9hlWae(BVNjnLcBoIIwaGEDqK2x3YWzrljxqqwBv(DW4O87aSiH7)14iabFfgbOVeTCDQPkUg60d460FIyFPlOPaaeE19HXSP3mlsKOzZNXtYwKc4xIbC)oaNcAlOQojmE1IiWfomkdYh1Jy7En1EmWMpukEF)sGR4WW15vZUgteb6VmF93c6XrOfoYpFNVqKAJnnfeUdUxcgZCK1irCdw2rfHz8IosJ(sqV5dGB4m4(RlRPNsbn5lmPAjiWmZ3y1IHIG(780hG78g)d7r(TnfRwn8M)nQk52C5pMgntill6AKCYnotKlIUicRph3Wk9UWROXue(rkiD)G0zNDQvzfMNvYDDQxBzeKvhs7jRvdrO55ruXMhapkKfP4LPiMfaUcgzcSvHmiIxLCRKAnHffH7WRaZmy7QM6xMST6axlwYdy0Ld)Sk(LnfKcTzWMezqaXRq7Y4pGmru98GsntuRm5AIBiY)Nrw3CrKBN(yn0XTZ9yjjogjRHzi3ifhmMUidd3zEmzdZQzwDkQ9PUVhHAOUqHClLObMbgiI836M2sS)xLIfpyYSyU036a6U8Qkw(PBeCBzWyRktsPeO1WcMoSo8sByH5xpOFrxDWVXNrnE(Zi2Unx(7eFhJhnqYoxh38UILTSajFiXSB5XbYMHMUwU9WJ8JJm1JuNG6wC6XwvRXZDI0nhhpJDVp2fldlPTzUkgcdhQmOu)mAMpSmG)fd4A1A0QPvjRfQlYOq0rczsb7hqP3F(ZNnKxBT3r2HXDbyoVahy1tmg2wjCiCIM5Gbkkd8f3MJyUjqnGAm75miNvuZeUcNeuXob7Skx6WrOF9vi4(BZpJ7WoVGTqF1Dfjr9AE2zHu4WScKQEqtJoQdMxVUtZKCxndKhxPxl(WlnCx9r0CmgZYLcti5O9u9sdwxG0oQUdGgeYlzmH2YTVefAlas8z9Pgfaw2upGe7SBRbuXSuqj(J6Qa7oqGmM36M1s2E6LXnfCBqeyYuXAUrcA0R7l1c)B7l)IA8K3Q7XP6BRrm2o7kQgZ07mkWxitEnMI21jl0jEfr9ELQJeJVpjccvjOxpL6ju3cQBzKocBRYlNLs5GT4vgtL97suZn3d)ELb(Av808S0S8zMxhKJ2kVutPourhkQRlmAmSZorehFDh7yFGfBnf3MP056aDOLlbK8LxTSkuZjY2NkW5Pzi9Op9)nItaUJIPj710ThJ)Yvj0isv5P4XEP1X8GwLGTDZAVwhpYCWofEuU)OAdJ0XBxHubxww5P4B36kB52McZVviIMfD32nFcjxMf13JdLtIDdNh1zzbwIiGUlFkNKjs81VZk(Gnx(t8QpGPoGIAL0BtMnsOXdr1ik4VqdrVqVUnFUQQHn1LRzTtVuqHzx0rLy2Udn9LX8wyhlfCq1QamqQpVzqLoxE(VctMRe6eZ1H2dkYQdkBZw1AO8SxNMDvukxiOZiGOPZXIGBDb16Pn65qwn3VF9ZvhZs3Pu2MUII(bftLxBEE7gm0mULMr1GrM6IRXhlQm3MpSQEx6rAjbw9S7GJI0wNXW0Z(6jUcqtRyG2b3(TlBBII8lg3ty9(xvzzMvGYwi)Cc9F6c16PbkdCSbWwGxQddkkg26EeHLlp)7o2Nx7qSusPepmW5ZsX(KukEAuXLgtJ34rfDGRWQvXmEbpvlSSyjF(5WXxDqlrGY9E8w4Tgl133GJPt8MJhTL8M2MMbnyNSflR2TTXdfTr0i9QKR5YXU7zDvWOn0ttVm0p9iYTl0zlow9iaRB7W(YJsclFyuqCixhiT5ujliCi81I5fzM5tCb3ZRcyRvX8e0RxRMcPybuJO0XE47YJwxGXgmofeSIN)zyiNcYvlHPobv6kiDT(KLIkJ1Iihmf047ondeqTgd1w48kC9RT9MiSuWDyMLZ42AzV2HJeRfptsPOsCDzdit8Nij48qZBVS2AuVj1fycfZkKbsSxXWqWDmcMU9QxITKTXaQYG2QWTa3JJLGP7Vq2EnRsmyJOL8nhOgsu5m2OaZuoQQ9DlyTZOi3acpkBTajbkrQZwL(XJq2wGf5t)aPXY(GGby1zLH1ea)MkgclVcY5664IWFOGoYLf8nexM16P85Kll4rXLzdf9u5YgBJlB8xpUSaINYvoYfZSL43Zpo0Fo4TGX2RNIhYX40O7XiccE5Pfc)ZY(m87e0Fhrtazkg6n03hzV9GY6aGKp87W8DxGHzSq2pha77xd644NMmAONwrNvdXalQZRMzBYnVSTccHkYtoPu1ssw1DUEkpc)UUlDACdzG0bKNxdu4svnKX(a24UUgqMbLopNuAnIa9YSulW2SmazgldY4JRYqvBsltORv3KeyzBIhIeMZaXRYQUErhDDDNnUpdXgM8jz2zNNIXS8876KuyBhoZsywjyoHEk9m0icjLTzCeMIUtT7xWaFEmqhURaxvDagWetRoGlX2HaBykuZOhETpY8G6Ver(e5iPxcp2qIIs78zUMxA3X2DPUVBru6CSJgKClwbk2Sxrn9vYyUzyfUmiqE8cZLT89vZouBPUQ9stYs(BXz2CGRRTbIy5U4eEPx79TfEvPMaNrELoO7eF4Eo1oVT6t4d4j8YTvNJfXsU9ILxMdzzZsRaSlm3tl7Gj7U8SUEUb)k4EUe4(4)5BaiGcCai)EAqCxKcEhK48I4CrfSg4UBl4BqMNKhtqdngUpJX(gdSW)WCDMgIhAsAGCxhFwJpS3OaxprEptM1TvHax2pChVDzfENOBzPcz(lziKJOaqwZQB3uiBIJe2)MrTYO99s3CBcv4IWLY0PrtxeJGw00)NkgabC2fw9xv(irFjwP0sARaCywf2YsRn01yPrG(c36rcSGVLfwbaMAUyVfX6cUcJPcie0Dm7M48PlsINFHLQUrB3NJxsLpLjIUkon0q8jbqoJGjqkPyrmhRNZ8vW2c884pp2y0zYPD9WHt6sS8QJVG7zfHvxfgd6Ebaslnd46zSUvHEuDiBRQkygfrV1qlsiUkU8U44vuN9i((4I2xgKplxWoSozwpPoThQo7fPzFtR6QXCsvtIBw7PNMYjJ2cXMgL80VMSeRpb2XoIoFcI(IghJ1SAkRnbIvjThEKifx4PAI6wfg13akMm(lRtY5HWX(bIOomBf3KSoKTbOUBA9ioNkUrRnnZOn5bMoJ)iWSCR)FYywUPTfmFgOJT1N3Zb(t0X)EuvH021(zCQf8ukxOdC7kYPnlAso2RgLPM7pQH)8AZM0znkH8UQgngSNGmuGz)aZfTKlu6rg4LqduOcYR1McOUZhRJNMGhYJAx8qqsozaAhHtIdG53HUJKygFufo1w)YANn(60GZAPds1Rl1jwq77sAv1BdOPHRHhBZbWlSuftpN4gb)OdCt)TP961jC5y3Bf8Ii08GqH501zhYxJCuYzwT(M4ykjj0b1e06kknFkK74UqmXKreXNXvFnkukQe5Djjz0ojwF0fRtnrdCeR0nQZaILMSrZvZTf2MbVWDHHkjp2iCK1TQkPrJFcrKz7mY8daHmstEyH8nn72PDnMtMnYUA)8ug(LU74HIsutFlujlo4BkDxyi2L(9tr5P3R0KJKSA0z7OKjNUrBocw8uwSPWNDpgNH1GqZ4LjthSXYz(ZSwbNSEQM3qUoV5o0P5R3PXQ4dnNF(wHZSBmlSWsB6cs3i9ol1blTdx1WL30goow8)S7UDc24GUS922XV1DdHYS3w77yDyPXuZGO2lsi3n7UGrkyCVXwZZbMsDxyFcQ2JqW72mYasOIfJFz8UznWNTkK3cTYdAAMVz))MzBjNLnEtDX4iAedOgswIcYRwTIwA0jbbnsk4GJkSvrqm7yzPeq6kaROgYJPWqdlh2H2vMgbHasIRW1jHYEdbNDsSXrQoHfCONkeBTZkFF2Ijn52ewVgQo7fCyKLqeE6Ng4vGrUy(6eVMPWK)TsyrBskoLGNjIGvRCQ5IO2YxyX0SQvZYJt1AmvhPeGBVN0oJN1TJV7sw2lZIMlpLSZQzARqDT78nGTcTZb(SynXB))xP3SYkGO6oRoPQgF7aCyLG6w))JCH)9sUGDtvC52Adtvmof5PPSY9(9z)uZV)gI94SZ3FeIKP2Fh3l2RYUnwuVSjxVkJ3axyIlyrAtnOXI4XjuZYRtdlFrmEcMmzeMLoyqdH(C2PB9I(SBVY5FwCY7RfLk0EhZerthdnboIUd1nNe9zkE6WNLjYfUOfJi7OHF(hF9V9EpOSt0RNNoX4srMhf128lnJy)Ip8FFZW3CWM6wQUPue)bsQV18xRKkwTU0HwOp3ID2tOenGblpoVaPNSpqtFFWKlo)UOC0CYIlo)pE)N(4p)X)672CjG1rw7KLRZWVupKHHVsMaZxHdolDvB4TTROQYSLS9VtzFHMgU5x(vQ3eo5DYV5p4TXpauu9suImgFhJg)RvyhtcmfSG0sNTweNO(VgwJ9h)f87C0MFPfaKLl0Td6gRdDVQM95F8kgSPEjbheCR(beqXgL38OhLoU0KD6TTB1zG7FL8CajbR6R0eQEsJbAo1p9F)Rgd2rpre1Zd6MnkFVXOiQeWX1JIsXbIxR)Ko86bwED216FOYR)2TF27YR7z2vb(Fy7NDv(9XJ2(PpOBC6Sox42XMBIm6ilQg3W4GNitvRRSPZk2UL1BE6sodCZW(uhUhls3hF0tfMmjIFZnEpdK0XEgVUSpUtVVN9XAV)ZapLVXBRxppcHYDC37SSTuO04dF0cu0yzE2SFY(49ybRhVM8aFeSUpmEP7s761EhA4mS7)FagCRYg8ZevhhKVFd)C2HrPSOePSKZhtXYo8hWYejBEcw2d)P)uD1eWJZe)lykDhlFftXRx)Lmf)1bpNFnt5d4lZx0u(G)s)vnLpnVuFzt5d)Z7x3u(GYze3STFHtf8b((kNYFMNPV0PcEXF6lXtRiMErs4fO1RIVgCIe7XttNgVgDaEv2QdweLVCEvQydsbsbtVhgo(Vhk9x5e1pugwU)EN8AxFImS)0MD1Q9B0eSpz8O9tMFYoMDeKEnRVKthFK9zPURhGdLZUfXdp4SZkyFCfH9AFSCHoPUgWNLVpv8uNm(G(krWW8ZAXU9XpKf713wON3D0WXdgmaiOC9xFL(Gr0LfU5zN32Ix(bYyx8JIbBD9Y)jpOlqFJJ0La8rELAlwm)Ea0R)o1MJyEZhEO(fBCo8o9K6xSXnhO(QEBX9p8q)g7j8as90g2gF6cg8uqvbQOkltDnQQjESE9AbBCQh04a138XJPSqz1g2hhMY9jRLJYSTNVxFlaL63aHoZBS1WyW2dJo(on0zQIdyKhxsh3u7JTGnLfKUcpDnVEQb0TH(sqDcvmYuAzizPauGcfPeqEBuskLLdjWDc(PpKKL90(MgkhqliGg0nTdILGu5oZrhhqa4w9rf09KBKGh(0BTEpo9WJCpoopWu8r05HIExlN5Qz5QtK5jSHJ1K9gcMf5mwfZJszRdZ0zfe68f)d(NglHoBpYIZYWG5NoVEQz340tgtG6l33YpvyK)fibbohWMTlZjQhFKbKpX3qBR3Z1ZXDetWyxpa1ZSp(Wrgaqq7ScylIU9hIcaQ6ZP)HXdxu6FPmaY2r7zVaQAok0Npp1RB81Yt9wAFC8K(TY3NX4Q)k27BRf4dBXoPHFb8Ur8jJhE0(A5rMTpUzligm6W(rxfuq1ifBa9FaOzR51TvzI7cWWdpy7oNEIAIehirPFfBmVAOvBoCzb5bEsD4OdC1OE71(khW9MgCb2G5CVlIm5s7T18jb36iIJVZX8dpSt9j6v28D5(p9m1JAnrLouOzVTiXvR5Z0eyn45ymOGKSDKco(Odc2TTVfsiY4LSv02rmKAVGYaV4O58(Wdwoa4igXWQEBSMNmYbtWlEZLTJOJM99kCtPrx1vzXk7OUQxdKml8B95zA5Ou(GsT8S(91o2JhemAW31FCWi7MKnyWPoERd8UD3)y2RfrfJE4bpYzS3BAHxbex2tdmpoy0ZdEu2DdEzXK6TXa)JgB3KEZI1jo4pPhVwAp)tU)TAIA1dqx)hte6g0BhTZKFVDAwwM9Cul9NmQxFp9N1tdarZ6f1ZG9T0Pvrtrm6PQAxsn2JndWOug1349r1M0UAWLCnXWNQE9TWgA403Xh2R5dPQMON9c4cCuOxtR2iPanP(2zXNmyRxqUHL(23Nob2pkwY1BkndBQZT5toODmyhNbvdI(gSxKAskyYOSseSyqqV(oJAa4)3tJpz8Og8jEao78bWy8Dci0bTE8OorRLJYG9KzT5BjOI4Y(k2Uo7SQBdRqTXKzCgKSQxPj2XUxaTjLZgw206cZ1MO)xWwBT1fr9)25jU6WNYGVy0(qTUz5qvtUlFU75NUwcf7t9HprIiO4cOeea3HK)HhSH3f0epcvcS)M67l8LdJVlamgth3Dsagkc5W2iLlNmUxFBYS606S5ub(L7zUc0YYLe8jNR70AhMbyk2X9u0qQQdQzGhQzWxdQPLSv9yOMbBb10CDUTuZXAjI7fIAYd513I9YYgAfeYBawlV8m7yltyaU2A)Q80tSF962o5bhc(X23AVPK)YE6zL4lZqZV4TDst8LACNSBGXooAaL9S0Ml2T)49Sw5dn3pm40j7nzx1imYCH1Cehn8OtBAM3aBM(nHPHYE)H8)AZxR(dzdBmH7Rx(lY4j0ZWLuRweBZaM(70ASuT1niRnoXiC6E6cKnTzMVEEoxo9BgeesGMJyJC64Gb7zvnqxfdcdWjbnwASgQO0ojJE2Od7KS5)H5ax3OfXbVdpVSNk2TNx2(e72JR3Pe727yp3ySt4JHKem0nodttl2(2OjesP41DQXp1ODi(WdwsfYBgzL299(HfpTcqjlIrNnSxFpGkO82bS5B9nEG9GECKFG3zZf0wQ32Xzlg0)K4SB)PKFBVDwqFUE01M)NBRpR5RT0naTo1NGHlLLv1Zyz9vE8hJUkjfGIywwwLPFx0pf6F0Ec1jND(aE2((zryfXQka9)jO(Be9(2CzkxCXp)J)xAEqDxKS2zzLEmpwNBU89u3EIDF6GC(LIR5TJfMN4WFMWAOekOkwoTprjT8oJi2ETKsk7w)QRjWBe91ZDoqdCK7CvZwn0F5a41sLBTsZhrU5ovvzbd51iMe1FaFLfaJLSSo(zybtSG8Qtx(jtxVBEuNCEXbxLflqHx87lcTxoRo1fVhp1)fzGOxS4rMxkJqOrJE0c(WYhpEndZRXq92HL)Igpp9D8UHWhVZGfbAp(z8pHLzo21uMNZQUM1RjeY0f44Zns8QQ8vBSuynKWKIoc2oathkopE0W32RVnrwhPzMuJ5ziLgeg0Fa))IcJjqmk94tgnm4iM3i)b5)XV9EMCdYpeCnUib7amkbgw12zH4rKdtLTdJS8DaJgH8(vWUm4rWYw6lrlxRM8O2qrTyhBxrCYK2KcGs4v3hgZaePqmM2kZ7I2WAl4Y4vwIAkVdayqwizPsy8QfOLvyr7qpMJDV9mYdv3rgpl4cBhJDyD6ebyXMLJi2L6JQXt7qA0PvVS4HoAF1CWDdoBG9f85IvHygxK9nsIYck61gUr9VZBihi794FypkKMyfvr38VLmBgUr4hX(LbFhpLjTcUUEHHAwaDnB3CTfNvgnlOPjK6khfSAy70tg)dp8q)DA0VB75ZcXtoCpdV45rxOXYLutWuBWo)hfB4DlIis7j)C)SQwgplpJ0vGfbymJMYcMiGM9)wEZ75Wp3fmeBQjPWZOpK(8ZMcELJ53KxWT9SGACuxjwCZCG1Tk(XSwwaXtxKHrvppMuiUAMlYCxCdDKLjiA5vvmFQSY84ob47yPFVWfwDvk6yvYSyMah8ePeD1b)wvzsQ8CkX5moJicBU83zNqiIsgut0BcVl5Jsxve7ZfPaFJV9XtAWoxtepNMu9FRB0(3m9iBLfzw5j6wr2SFlYTMSPqH(wAbVhlTfWSJIRexeJkaFGdSZlAFUwdh0Ww6M9tkpyb9Go5BdDqhrc)lTDv3bmHooWs2l7B6VLdPeNoAGTa5Ek7ag8C0URnxncMyyZRh3V6TJ9wYJwiev69xhFY4EEDy74aVYzShkMEw2qHrK(4MrF2CzkOqpHLPL2xnUm77YZCTY11pYyS1O3BFLX2i8V22kTj2uR71U)CEdUvTUiBWCPMQc7L3mGk1rTp8G0jkzRCRf7bWOiyNeABW21ltiB4AsaoGpqdoDsxcJABymmAvFLAKZEixwpyAweS5OdmE8H9KrX9LLC7J(e0DQGDeHTyXw70ydlb69VJm5Jd8XLJNVLV17mVMuxJmPzJkRHXo9KapfKO9dMxWi6eA4idyw9(rq66hS3H723acMmyWU9hFG9dYEZ9LOUdUxMVOnzypQzn2OWVJheP6MNVb3K4EpYP9NSxFpTrXDpAG29f((rx3L9U7(grni8vQZ96H0Av5GBc7JsTXB)AGW)UgAmeR6UQjqWM)F4(FYedEmY(MPl02MAKTtTH0piRc79Oy9FzTq2TD9sf)MhgbGZtV9(i86AGt0uFvFOoy8aTDjU8vR)oMoBBlK6spR9YBpre9QZRl4R3ZWkejcRFjEjiZOoh(53zHWjXKYabFIfSPVEQGbhYHMhMBFlI3yhuhJG65Yk8RbxUewT6(SvOCRbQZRUcSSCE11XVtMXu00TpPFo(rYx8mL4bAfiB36E1N2Jn(8LyHe4An(a9LEYh8DQ3yg2YoazU6c09YYfyGyOgvnRQbKuTp1WtXMQ0lenldzpUIeluBGGWpFTye9mIy9Ii9feg9KkCcVVcOmisK9Wdf7p59SnsLrcR9TXyD0pkTQNezLdFlxq)z4X1MsAp1rAuyZy1rLrOG1pacRBCwh0KgYg6qwVUPWPepTsI4Hh67EeuFVJd4NhKi1LoJPzp9v97Wwe3xswwTKHwi1dSNK)LHHquS6g(V(HZmXbuaqffvMpQOp5es1(orHTfWmllx1vjBzZca61wxY1w8QwlDUxJwxh(QyLUSi9vwFsqX1UV9H)npkmAjOFT8Kjh1LvHLDInsiH1KQBMmdPAy987zkNZEqq8vfEN(NNmWAJNlWcjxlw)jRENul2EsbJKdqOTsshOYX2i5(KKqAxVw6dgkotn6LE8CG0MILAr5gxn)bli9(TDK7R3DJnncQ1HSanqr7XhWknM6OdRxZ3gXd)0dTt9SBsudhWMy7KlZYjHEn(E8HudY)I)F)]] )


end
