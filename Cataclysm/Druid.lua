if UnitClassBase( 'player' ) ~= 'DRUID' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local currentBuild = select( 4, GetBuildInfo() )

local FindUnitDebuffByID = ns.FindUnitDebuffByID
local FindUnitBuffByID = ns.FindUnitBuffByID
local round = ns.round

local strformat = string.format

local spec = Hekili:NewSpecialization( 11 )

-- Trinkets
spec:RegisterGear( "grim_toll", 40256 )
spec:RegisterGear( "mjolnir_runestone", 45931 )
spec:RegisterGear( "dark_matter", 46038 )
spec:RegisterGear( "deaths_choice", 47303 )
spec:RegisterGear( "deaths_choice_heroic", 47464 )
spec:RegisterGear( "deaths_verdict", 47115 )
spec:RegisterGear( "deaths_verdict_heroic", 47131 )
spec:RegisterGear( "whispering_fanged_skull", 50342 )
spec:RegisterGear( "whispering_fanged_skull", 50343 )

-- Idols
spec:RegisterGear( "idol_of_worship", 39757 )
spec:RegisterGear( "idol_of_the_ravenous_beast", 40713 )
spec:RegisterGear( "idol_of_the_corruptor", 45509 )
spec:RegisterGear( "idol_of_mutilation", 47668 )

-- Sets
-- old
spec:RegisterGear( "tier7feral", 39557, 39553, 39555, 39554, 39556, 40472, 40473, 40493, 40471, 40494 )
spec:RegisterGear( "tier8feral", 45355, 45356, 45357, 45358, 45359, 46158, 46161, 46160, 46159, 46157 )
spec:RegisterGear( "tier9feral", 48188, 48189, 48190, 48191, 48192, 48193, 48194, 48195, 48196, 48197, 48198, 48199, 48200, 48201, 48202, 48203, 48204, 48205, 48206, 48207, 48208, 48209, 48210, 48211, 48212, 48213, 48214, 48215, 48216, 48217)
spec:RegisterGear( "tier10feral", 50824, 50825, 50826, 50827, 50828, 51140, 51141, 51142, 51143, 51144, 51295, 51296, 51297, 51298, 51299 )
spec:RegisterGear( "tier7balance", 39545, 39544, 39548, 39546, 39547, 40467, 40466, 40470, 40468, 40469 )
spec:RegisterGear( "tier8balance", 46313, 45351, 45352, 45353, 45354, 46191, 46189, 46196, 46192, 46194 )
spec:RegisterGear( "tier9balance", 48158, 48159, 48160, 48161, 48162, 48163, 48164, 48165, 48166, 48167, 48168, 48169, 48170, 48171, 48172, 48173, 48174, 48175, 48176, 48177, 48178, 48179, 48180, 48181, 48182, 48183, 48184, 48185, 48186, 48187 )
spec:RegisterGear( "tier10balance", 50819, 50820, 50821, 50822, 50823, 51145, 51146, 51147, 51148, 51149, 51290, 51291, 51292, 51293, 51294)
-- Cata
--- Feral
spec:RegisterGear( "tier11feral", 60290, 60286, 60288, 60287, 60289, 65189, 65190, 65191, 65192, 65193 )
--- Balance

local function rage_amount()
    --local d = UnitDamage( "player" ) * 0.7
    --local c = ( state.level > 70 and 1.4139 or 1 ) * ( 0.0091107836 * ( state.level ^ 2 ) + 3.225598133 * state.level + 4.2652911 )
    --local f = 3.5
    --local s = 2.5
--
    --return min( ( 15 * d ) / ( 4 * c ) + ( f * s * 0.5 ), 15 * d / c )
    local hit_factor = 6.5
    local speed = 2.5 -- fixed for bear
    local rage_multiplier = 1

    return hit_factor * speed * rage_multiplier

end

-- Generic function to calculate the total damage for an ability
-- Parameters:
-- flatdmg: The base damage or pre-calculated damage of the ability with AP/WeaponDPS
-- coefficient: The scaling coefficient for the damage source, if AP is already calculated use 0 to avoid double counting
-- weaponBased: Boolean indicating if the damage is based on weapon DPS, if false it is based on attack power
-- masteryFlag: Boolean indicating if mastery affects the ability, for feral only apply for bleed damage
-- armorFlag: Boolean indicating if armor reduction should be applied. Armor reduces physical damage
-- talentAndBuffModifiers: Combined modifiers from talents and buffs
-- critChanceMult: Extra multiplier for critical chance, use nil as default
-- Returns: The total damage after applying all modifiers
local function calculate_damage(flatdmg, coefficient, weaponBased, masteryFlag, armorFlag, talentAndBuffModifiers, critChanceMult)
    local feralAura = 1
    local armor = 1
    local mastery = 1

    if armorFlag then
        local boss_armor = 10643 * (1 - 0.2*(state.debuff.major_armor_reduction.up and 1 or 0)) * (1 - 0.2 * (state.debuff.shattering_throw.up and 1 or 0))
        local armor_coeff = (1 - boss_armor/15232.5) -- no more armor_pen
        local armor = armorFlag and armor_coeff or 1
    end
    if masteryFlag then
        mastery = state.talent.mangle.enabled and (1.25 + state.stat.mastery_value * 0.03125) or 1 -- razorClawsMultiplier
    end

    local crit = math.min((1 + state.stat.crit*0.01*(critChanceMult or 1)), 2)
    local tf = state.buff.tigers_fury.up and class.auras.tigers_fury.multiplier or 1
    local sourceDamageValue = (weaponBased and state.stat.weapon_dps) or state.stat.attack_power

    return (flatdmg + coefficient*sourceDamageValue) * crit * mastery * feralAura * armor * tf * talentAndBuffModifiers
end

-- Force reset when Combo Points change, even if recommendations are in progress.
spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( _, _, powerType )
    if powerType == "COMBO_POINTS" then
        Hekili:ForceUpdate( powerType, true )
    end
end )

-- Glyph of Shred helper
local tracked_rips = {}
local rip_extension = 6
Hekili.TR = tracked_rips;

local function NewRip( target, tfactive )
    tracked_rips[ target ] = {
        --extension = 0,
        --applications = 0,
        tf_snapshot = tfactive
    }
    rip_extension = 0
end
local function DummyRip( target )
    if not tracked_rips[ target ] then
        tracked_rips[ target ] = {
            --extension = 0,
            --applications = 0,
            tf_snapshot = false
        }
    end
end

local function RipShred( target ) -- called on shreded targets having rip
    if not tracked_rips[ target ] then
        DummyRip( target )
    end
    --if tracked_rips[ target ].applications < 3 then
    --    tracked_rips[ target ].extension = tracked_rips[ target ].extension + 2
    --    tracked_rips[ target ].applications = tracked_rips[ target ].applications + 1
    --end
    if rip_extension < 6 then
        rip_extension = rip_extension + 2
    end
end

local function RemoveRip( target )
    tracked_rips[ target ] = nil
end

local function GetTrackedRip( target ) 
    if not tracked_rips[ target ] then
        DummyRip( target ) -- I think this is just to avoid "nullpointer" - dont want to reset extension, so will add dummy
    end
    -- Rip-Extends are shared across all targets, so we override here
    local tr = tracked_rips[ target ]
    tr.extension = rip_extension
    return tr
end


-- Combat log handlers
local attack_events = {
    SPELL_CAST_SUCCESS = true
}

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

local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

local eclipse_lunar_last_applied = 0
local eclipse_solar_last_applied = 0
spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID ~= state.GUID then
        return
    end

    if subtype == "SPELL_AURA_APPLIED" then
        if spellID == 48518 then
            eclipse_lunar_last_applied = GetTime()
        elseif spellID == 48517 then
            eclipse_solar_last_applied = GetTime()
        end
    end
    
    -- track buffed rips using rip_tracker as well
    if attack_events[subtype] then
        if spellID == 1079 then -- Spell is rip
            local tf_up = not( FindUnitBuffByID( "player", 5217 ) == nil) -- if buff is not active, will eval to nil
            NewRip( destGUID, tf_up)
        end
    end

    if state.glyph.bloodletting.enabled then
        if attack_events[subtype] then
            -- Track rip time extension from Glyph of Rip
            if spellID == 5221 and not( FindUnitDebuffByID( "target", 1079 ) == nil) then -- Spell is Shred and rip is active on target
                RipShred( destGUID )
            end
        end

        --if application_events[subtype] then
        --    -- Remove previously tracked rip
        --    if spellID == 1079 then
        --        RemoveRip( destGUID )
        --    end
        --end

        if removal_events[subtype] then
            -- Remove previously tracked rip
            if spellID == 1079 then
                RemoveRip( destGUID )
            end
        end

        if death_events[subtype] then
            -- Remove previously tracked rip
            if spellID == 1079 then
                RemoveRip( destGUID )
            end
        end
    end
end, false )

spec:RegisterHook( "UNIT_ELIMINATED", function( guid )
    RemoveRip( guid )
end )

local LastFinisherCp = 0
local LastSeenCp = 0
local CurrentCp = 0
local DruidFinishers = {
    [52610] = true,
    [22568] = true,
    [1079] = true,
    [22570] = true
}

spec:RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", "player", "target", function(event, unit, _, spellID )
    if DruidFinishers[spellID] then
        LastSeenCp = GetComboPoints("player", "target")
    end
end)

spec:RegisterUnitEvent( "UNIT_POWER_UPDATE", "player", "COMBO_POINTS", function(event, unit)
    CurrentCp = GetComboPoints("player", "target")
    if CurrentCp == 0 and LastSeenCp > 0 then
        LastFinisherCp = LastSeenCp
    end
end)

spec:RegisterStateTable( "rip_tracker", setmetatable( {
    cache = {},
    reset = function( t )
        table.wipe(t.cache)
    end
    }, {
    __index = function( t, k )
        if not t.cache[k] then
            local tr = GetTrackedRip( k )
            if tr then
                t.cache[k] = { extension = tr.extension, tf_snapshot = tr.tf_snapshot}
            end
        end
        return t.cache[k]
    end
}))

-- This function calculates the "Rend and Tear" damage modifier for the Shred/Maul ability when it is applied to a bleeding target.
spec:RegisterStateExpr("rend_and_tear_mod_shred", function()
    local mod_list = {1.07, 1.13, 1.2}
    if not debuff.bleed.up or talent.rend_and_tear.rank == 0 then
        return 1
    else
        return mod_list[talent.rend_and_tear.rank]
    end
end)

-- This function calculates the "Rend and Tear" critical modifier for the Ferocious Bite ability when it is applied to a bleeding target.
spec:RegisterStateExpr("rend_and_tear_mod_bite", function()
    local mod_list = {1.08, 1.17, 1.25}
    if not debuff.bleed.up or talent.rend_and_tear.rank == 0 then
        return 1
    else
        return mod_list[talent.rend_and_tear.rank]
    end
end)

local lastfinishercp = nil
spec:RegisterStateExpr("last_finisher_cp", function()
    return lastfinishercp
end)

spec:RegisterStateFunction("set_last_finisher_cp", function(val)
    lastfinishercp = val
end)

spec:RegisterStateExpr("pseudo_rip_tf_snapshot", function()
    if tracked_rips[ target.unit ] then
       return tracked_rips[ target.unit ].tf_snapshot 
    end
    return "leer"
end)

spec:RegisterStateExpr("rip_tf_snapshot", function()
    return rip_tracker[target.unit].tf_snapshot
end)

local ExpirePrimalMadness = setfenv( function ()

    if buff.primal_madness.up then
        gain(-10 * talent.primal_madness.rank, "energy")
        energy.max = energy.max - 10 * talent.primal_madness.rank
    end
end, state )

local training_dummy_cache = {}
local avg_rage_amount = rage_amount()
spec:RegisterHook( "reset_precast", function()
    stat.spell_haste = stat.spell_haste * ( 1 + ( 0.01 * talent.celestial_focus.rank ) + ( buff.natures_grace.up and 0.2 or 0 ) + ( buff.moonkin_form.up and ( talent.improved_moonkin_form.rank * 0.01 ) or 0 ) )

    rip_tracker:reset()
    set_last_finisher_cp(LastFinisherCp)

    if buff.primal_madness.up then
        buff.primal_madness.expires = max(buff.tigers_fury.expires, buff.berserk.expires)
        state:QueueAuraExpiration( "primal_madness", ExpirePrimalMadness, buff.primal_madness.expires)
    end
    
    --if IsCurrentSpell( class.abilities.maul.id ) then
    --    start_maul()
    --    Hekili:Debug( "Starting Maul, next swing in %.2f...", buff.maul.remains)
    --end

    avg_rage_amount = rage_amount()

    buff.eclipse_lunar.last_applied = eclipse_lunar_last_applied
    buff.eclipse_solar.last_applied = eclipse_solar_last_applied

    if debuff.training_dummy.up and not training_dummy_cache[target.unit] then
        training_dummy_cache[target.unit] = true
    end
end )

spec:RegisterStateExpr("rage_gain", function()
    return avg_rage_amount
end)

spec:RegisterStateExpr("rip_canextend", function()
    return debuff.rip.up and glyph.bloodletting.enabled and rip_tracker[target.unit].extension < 6
end)

spec:RegisterStateExpr("rip_maxremains", function()
    if debuff.rip.remains == 0 then
        return 0
    else
        return debuff.rip.remains + ((debuff.rip.up and glyph.bloodletting.enabled and (6 - rip_tracker[target.unit].extension)) or 0)
    end
end)


spec:RegisterStateExpr( "mainhand_remains", function()
    local next_swing, real_swing, pseudo_swing = 0, 0, 0
    if now == query_time then
        real_swing = nextMH - now
        next_swing = real_swing > 0 and real_swing or 0
    else
        if query_time <= nextMH then
            pseudo_swing = nextMH - query_time
        else
            pseudo_swing = (query_time - nextMH) % mainhand_speed
        end
        next_swing = pseudo_swing
    end
    return next_swing
end)


spec:RegisterStateExpr("is_training_dummy", function()
    return training_dummy_cache[target.unit] == true
end)

spec:RegisterStateExpr("ttd", function()
    if is_training_dummy then
        return Hekili.Version:match( "^Dev" ) and settings.dummy_ttd or 300
    end

    return target.time_to_die
end)

spec:RegisterStateExpr("base_end_thresh", function()
    return calc_rip_end_thresh
end)

spec:RegisterStateExpr("bite_at_end", function()
    return combo_points.current == 5 and (ttd < end_thresh_for_clip or (debuff.rip.up and ttd - debuff.rip.remains < base_end_thresh))
end)

spec:RegisterStateExpr("is_execute_phase", function()
    return target.health.pct <= 25
end)

spec:RegisterStateExpr("can_bite", function()
    if buff.tigers_fury.up and is_execute_phase then
        return true
    end

    if buff.savage_roar.remains < settings.min_bite_sr_remains then
        return false
    end
    
    if is_execute_phase then
        return not rip_tf_snapshot
    end 

    return debuff.rip.remains >= settings.min_bite_rip_remains
end)

spec:RegisterStateExpr("bite_before_rip", function()
    return combo_points.current == 5 and debuff.rip.up and buff.savage_roar.up and (settings.ferociousbite_enabled or is_execute_phase) and can_bite
end)

spec:RegisterStateExpr("bite_now", function()
    local bite_now =  (bite_before_rip or bite_at_end) and not buff.clearcasting.up
    -- Ignore minimum CP enforcement during Execute phase if Rip is about to fall off
    local emergency_bite_now = is_execute_phase and debuff.rip.up and (debuff.rip.remains < debuff.rip.tick_time) and (combo_points.current >= 1) and talent.blood_in_the_water.rank == 2

    return bite_now or emergency_bite_now
end)


spec:RegisterStateExpr("wait_for_tf", function()
    --cooldown.tigers_fury.remains<=buff.berserk.duration&cooldown.tigers_fury.remains+1<ttd-buff.berserk.duration
    return talent.berserk.enabled and ( cooldown.tigers_fury.remains <= buff.berserk.duration and cooldown.tigers_fury.remains + latency < ttd - buff.berserk.duration )
end)

spec:RegisterStateExpr("try_tigers_fury", function()
    -- Handle Tiger's Fury
    if not cooldown.tigers_fury.up then
        return false
    end

    local gcd_time_to_rdy = gcd.remains
    local leeway_time = max(gcd_time_to_rdy, latency)
    local tf_energy_thresh = calc_tf_energy_thresh(leeway_time)
    local tf_now = (energy.current < tf_energy_thresh) and not buff.berserk.up

    return tf_now
end)

spec:RegisterStateExpr("try_berserk", function()
    -- Berserk algorithm: time Berserk for just after a Tiger's Fury
    -- *unless* we'll lose Berserk uptime by waiting for Tiger's Fury to
    -- come off cooldown. The latter exception is necessary for
    -- Lacerateweave rotation since TF timings can drift over time.
    local is_clearcast = buff.clearcasting.up
    local berserk_now = cooldown.berserk.up and not wait_for_tf and not is_clearcast

    -- 471aa6c removed lacerate wait

    return berserk_now
end)


spec:RegisterStateExpr("rip_now", function() 
    --!debuff.rip.up&combo_points.current=5&ttd>=end_thresh
    local rip_cc_check = debuff.bleed.up and not buff.clearcasting.up or true

    local rip_now = combo_points.current == 5 and ttd >= end_thresh_for_clip and rip_cc_check and (not debuff.rip.up or (query_time > rip_refresh_time and not is_execute_phase))
    
    local max_rip_ticks = aura.rip.duration/aura.rip.tick_time

    -- Delay Rip refreshes if Tiger's Fury will be usable soon enough for the snapshot to outweigh the lost Rip ticks from waiting
    if rip_now and not buff.tigers_fury.up then
        local buffed_tick_count = math.min(max_rip_ticks, math.floor((ttd - final_tick_leeway) / aura.rip.tick_time))
        local delay_breakpoint = final_tick_leeway + 0.15 * buffed_tick_count * aura.rip.tick_time

        if tf_expected_before(time, time + delay_breakpoint) then
            local delay_seconds = delay_breakpoint
            local energy_to_dump = energy.current + delay_seconds * energy.regen - calc_tf_energy_thresh(latency)
            local seconds_to_dump = ceil(energy_to_dump / action.shred.cost)

            if seconds_to_dump < delay_seconds then
                return false
            end
        end
    end

    return rip_now

end)

-- Rake calcs

spec:RegisterStateExpr("final_rake_tick_leeway", function()
    return max(debuff.rake.remains % debuff.rake.tick_time, 0)
end)

spec:RegisterStateExpr("rake_now", function()
    local rake_cc_check = (not buff.clearcasting.up) or (not debuff.rake.up) or (debuff.rake.remains < 1)
    local rake_now = (not debuff.rake.up or (debuff.rake.remains < debuff.rake.tick_time)) and (ttd > debuff.rake.tick_time) and rake_cc_check

    -- DELETEME: only for old gear
    if rake_now and (set_bonus.tier9feral_2pc == 1 or set_bonus.tier10feral_4pc == 1) then
        return true
    end

    -- Additionally, don't Rake if the current Shred DPE is higher due to trinket procs etc.
    if settings.rake_dpe_check and rake_now then
        local rake_dpe = calc_rake_dpe
        local shred_dpe = calc_shred_dpe
        rake_now = rake_dpe >= shred_dpe
    end

    -- Additionally, don't Rake if there is insufficient time to max out our available glyph of shred extensions before rip falls off - skip if not relevant
    if rake_now and debuff.rip.up then
        local remaining_rip_dur = rip_maxremains
        local energy_for_shreds = energy.current - action.rake.cost - action.rip.cost + debuff.rip.remains * energy.regen + (tf_expected_before(time, time + debuff.rip.remains) and 60 or 0)
        local max_shreds_possible = min(energy_for_shreds / action.shred.cost, (debuff.rip.expires - (query_time + 1)))

        return (not rip_canextend) or (max_shreds_possible > (remaining_rip_dur - debuff.rip.remains))
    end

    -- Apply same TF Rip delay logic to Rake as well
    if rake_now and not buff.tigers_fury.up then
        local buffed_tick_count = (math.floor(min(aura.rake.duration,ttd-final_rake_tick_leeway)/aura.rake.tick_time))
        local delay_breakpoint = final_rake_tick_leeway + 0.15 * buffed_tick_count * aura.rake.tick_time

        if tf_expected_before(time, time + delay_breakpoint) then
            local delay_seconds = delay_breakpoint
            local energy_to_dump = energy.current + delay_seconds * energy.regen - calc_tf_energy_thresh(latency)
            local seconds_to_dump = ceil(energy_to_dump / action.shred.cost)

            if seconds_to_dump < delay_seconds then
                return false
            end
        end
    end

    return rake_now

end)


spec:RegisterStateExpr("roar_now", function()
    return combo_points.current >= 1 and (not buff.savage_roar.up or clip_roar) and (debuff.rip.up or combo_points.current <3 or ttd < base_end_thresh)
end)

spec:RegisterStateExpr("ravage_now", function()
    return action.ravage.usable and not buff.clearcasting.up and energy.current + 2 * energy.regen < energy.max
end)

spec:RegisterStateExpr("ff_now", function()
    return settings.maintain_ff and debuff.major_armor_reduction.down
end)

spec:RegisterStateFunction("calc_tf_energy_thresh", function(leeway)
    local delayTime = leeway + (buff.clearcasting.up and 1 or 0) + (buff.stampede_cat.up and active_enemies == 1 and 1 or 0)
    return (40.0 - delayTime *  energy.regen)
end)

spec:RegisterStateExpr("final_tick_leeway", function()
    return max(debuff.rip.remains % debuff.rip.tick_time, 0) --debuff.rip.tick_time_remains not possible because of shred extensions (crashes default)
end)

spec:RegisterStateExpr("end_thresh_for_clip", function()
    return base_end_thresh + final_tick_leeway
end)

spec:RegisterStateExpr("rip_refresh_time", function()
    return calc_rip_refresh_time
end)

--- Return the time at which Rip should be refreshed.
spec:RegisterStateExpr("calc_rip_refresh_time", function()
    local reaction_time = latency -- TODO: This appears to always be 0.1, a very low value, in order to clip the rip with TF the addon has a 0.2s window to perform this query before TF drops and then the user must react in the remaining time.
    local now = query_time
    if not debuff.rip.up then
        return query_time - reaction_time
    end

    -- If we're not gaining a new Tiger's Fury snapshot, then use the standard 1 tick refresh window
    local standard_refresh_time = debuff.rip.expires -- - debuff.rip.tick_time -- TODO: reimplement 1 tick refresh window when we find out how to calc overridablility

    if not buff.tigers_fury.up or is_execute_phase or (combo_points.current < 5) then
        return standard_refresh_time
    end

    -- Likewise, if the existing TF buff will still be up at the start of the normal window, then don't clip unnecessarily
    local tf_end = buff.tigers_fury.expires

    if tf_end > standard_refresh_time + reaction_time then
        return standard_refresh_time
    end

    -- Potential clips for a TF snapshot should be done as late as possible
    local latest_possible_snapshot = tf_end - reaction_time * 2 

    -- Determine if an early clip would cost us an extra Rip cast over the course of the fight
    local max_rip_dur = aura.rip.duration + (glyph.bloodletting.enabled and 6 or 0)
    local ttd_absolute = ttd + now -- Note that standard_refresh_time and latest_possible_snapshot are absolute time units, not intervals of time.

    local final_possible_rip_cast = ttd_absolute - cached_rip_end_thresh -- TODO: ingore execution fase for now '(talent.blood_in_the_water.rank == 2 and target.time_to_25 - reaction_time) or ', target.time_to_25 does not exist
    local min_rips_possible = math.floor((final_possible_rip_cast - standard_refresh_time) / max_rip_dur)
    local projected_rip_casts = math.floor((final_possible_rip_cast - latest_possible_snapshot) / max_rip_dur)

    -- If the clip is free, then always allow it
    if projected_rip_casts == min_rips_possible then
        return latest_possible_snapshot
    end

    -- If the clip costs us a Rip cast (30 Energy), then we need to determine whether the damage gain is worth the spend.
    -- First calculate the maximum number of buffed Rip ticks we can get out before the fight ends.
    local buffed_tick_count = min(max_rip_dur/aura.rip.tick_time + 1, (ttd_absolute - latest_possible_snapshot) / aura.rip.tick_time)

    -- Subtract out any ticks that would already be buffed by an existing snapshot
    if rip_tf_snapshot then
        buffed_tick_count = buffed_tick_count - debuff.rip.ticks_remain
    end

    -- Perform a DPE comparison vs. Shred
    local tick_dmg = calc_rip_tick_damage
    local expected_damage_gain = tick_dmg * (1.0 - 1.0/1.15) * buffed_tick_count
    local energy_equivalent = expected_damage_gain / action.shred.damage * action.shred.cost

    Hekili:Debug("Rip TF snapshot is worth %.1f Energy, DMG gain %.1f, ticks %.1f, dmg: %.1f", energy_equivalent, expected_damage_gain, buffed_tick_count, tick_dmg)

    return (energy_equivalent > action.rip.cost) and latest_possible_snapshot or standard_refresh_time
end)

spec:RegisterStateExpr("feral_t11_build_now", function()
    return set_bonus.tier11feral_4pc == 1 and buff.strength_of_the_panther.stacks < 3 and not bearweaving_enabled
end)

spec:RegisterStateExpr("feral_t11_refresh_now", function()
    
    return set_bonus.tier11feral_4pc == 1 and buff.strength_of_the_panther.remains < 1 + latency and ttd > 1
end)

spec:RegisterStateExpr("feral_t11_refresh_next", function()
    
    return set_bonus.tier11feral_4pc == 1 and buff.strength_of_the_panther.remains < 2 + latency and ttd > 2
end)

spec:RegisterStateExpr("mangle_refresh_now", function()
    --!debuff.mangle.up&ttd>=1
    return (not debuff.mangle.up) and ttd > 1
end)

spec:RegisterStateExpr("mangle_refresh_pending", function()
    return (not feral_t11_refresh_now and not mangle_refresh_now) and ((debuff.mangle.up and debuff.mangle.remains < ttd - 1) or (set_bonus.tier11feral_4pc == 1 and buff.strength_of_the_panther.stacks == 3 and buff.strength_of_the_panther.remains < ttd-1))
end)

spec:RegisterStateExpr("clip_mangle", function()
    -- This only works in simulation-context
        --if mangle_refresh_pending then
        --    local num_mangles_remaining = floor(1 + (ttd - 1 - debuff.mangle.remains) / 60)
        --    local earliest_mangle = ttd - num_mangles_remaining * 60
        --    return earliest_mangle <= 0
        --end

    if mangle_refresh_pending and not set_bonus.tier11feral_4pc == 1 and not bearweaving_enabled then
        return (ttd + 5 > debuff.mangle.remains) and (ttd -5 < debuff.mangle_cat.duration) and not buff.clearcasting.up
    end

    return false
end)

spec:RegisterStateExpr("mangle_now", function()
    return (mangle_refresh_now or clip_mangle)
end)

spec:RegisterStateExpr("ff_procs_ooc", function()
    return glyph.omen_of_clarity.enabled
end)


spec:RegisterStateExpr("calc_rake_dpe", function()
    local rake_dmg = action.rake.damage + action.rake.tick_damage*(math.floor(min(aura.rake.duration,ttd)/aura.rake.tick_time))
    return rake_dmg / action.rake.cost
end)

spec:RegisterStateExpr("calc_shred_dpe", function()
    local shred_dpe = action.shred.damage/action.shred.cost
    return shred_dpe
end)


spec:RegisterStateExpr("calc_bite_dpe", function()
    local avg_base_damage = 377.877920772
    local scaling_per_combo_point = 0.125
    local dmg_per_combo_point = 576.189844175
    local cp = combo_points.current

    local base_cost = (buff.clearcasting.up and 0) or (25 * ((buff.berserk.up and 0.5) or 1))
    local excess_energy = min(25, energy.current - base_cost) or 0

    local bonus_crit = rend_and_tear_mod_shred
    local damage_multiplier = (1 + talent.feral_aggression.rank*0.05) * (1 + excess_energy/25)

    local bite_damage = avg_base_damage + cp*(dmg_per_combo_point + state.stat.attack_power*scaling_per_combo_point)

    bite_damage = calculate_damage(bite_damage, 0, false, false, true, damage_multiplier, bonus_crit) 
    Hekili:Debug("bite_damage (%.2f), excess_energy (%d)", bite_damage, excess_energy)

    local bite_dpe = bite_damage / (base_cost + excess_energy) -- TODO: check if this should include excess energy

    return bite_dpe
end)

spec:RegisterStateExpr("calc_rip_tick_damage", function() -- TODO move this to an action?
    local base_damage = 56
    local combo_point_coeff = 161
    local attack_power_coeff = 0.0207
    local cp = combo_points.current

    local damage_multiplier = (glyph.rip.enabled and 1.15 or 1) * (debuff.mangle.up and 1.3 or 1)
    local flat_damage = base_damage + cp*(combo_point_coeff + state.stat.attack_power*attack_power_coeff)

    local tick_damage = calculate_damage(flat_damage, 0, false, true, false, damage_multiplier)

    Hekili:Debug("Rip tick damage (%.2f)", tick_damage)

    return tick_damage
end)

local cachedRipEndThresh = 10 -- placeholder until first calc
spec:RegisterStateExpr("cached_rip_end_thresh", function()
    return cachedRipEndThresh
end)

spec:RegisterStateExpr("calc_rip_end_thresh", function()
    if combo_points.current < 5 then
        return cached_rip_end_thresh
    end
    
    --Calculate the minimum DoT duration at which a Rip cast will provide higher DPE than a Bite cast
    local expected_bite_dpe = calc_bite_dpe
    local expected_rip_tick_dpe = calc_rip_tick_damage/action.rip.cost
    local num_ticks_to_break_even = 1 + math.floor(expected_bite_dpe/expected_rip_tick_dpe)

    Hekili:Debug("Bite Break-Even Point = %d Rip ticks", num_ticks_to_break_even)

    local end_thresh = num_ticks_to_break_even * aura.rip.tick_time

    --Store the result so we can keep using it even when not at 5 CP
    cachedRipEndThresh = end_thresh

    return end_thresh

end)

spec:RegisterStateExpr("clip_roar", function()
    local local_ttd = ttd
    local rip_max_remains = rip_maxremains
    local roar_remains = buff.savage_roar.remains
    local combo_point = combo_points.current

    if combo_point == 0 then
        return false
    end

    if not debuff.rip.up or (local_ttd - debuff.rip.remains < cached_rip_end_thresh) then
        return false
    end
    
    -- Calculate with projected Rip end time assuming full Glyph of Shred extensions
    if (roar_remains > rip_max_remains + settings.rip_leeway) then
        return false
    end
    
    if (roar_remains >= local_ttd) then
        return false
    end
    
    -- Calculate when roar would end if casted now
    -- Calculate roar duration since aura.savage_roar.duration gives wrong values
    local new_roar_dur = 9 + (combo_points.current*5) + (talent.endless_carnage.rank * 4)
    Hekili:Debug("Roar duration: (%.1f VS %.1f) CP: (%.1f)", new_roar_dur, aura.savage_roar.duration, combo_points.current)
    
    
    --If a fresh Roar cast now would cover us to end of fight, then clip now for maximum CP efficiency.
    if new_roar_dur >= local_ttd then
        return true
    end
    
    --If waiting another GCD to build an additional CP would lower our total Roar casts for the fight, then force a wait.    
    if new_roar_dur + 1 + (combo_points.current < 5 and 5 or 0) >= local_ttd then
        return false
    end
    
    -- Clip as soon as we have enough CPs for the new roar to expire well after the current rip
    if not is_execute_phase then
        return new_roar_dur >= (rip_max_remains + settings.min_roar_offset)
    end
    
    -- Under Execute conditions, ignore the offset rule and instead optimize for as few Roar casts as possible
    if combo_point < 5 then
        return false
    end
    
    local min_roars_possible = math.floor((local_ttd - roar_remains) / new_duration)
    local projected_roar_casts = math.floor(local_ttd / new_duration)
    Hekili:Debug("Roar execution: min (%.1f) VS projected (%.1f)", min_roars_possible, projected_roar_casts)
        
    return projected_roar_casts == min_roars_possible
end)

spec:RegisterStateFunction("tf_expected_before", function(current_time, future_time)
    if cooldown.tigers_fury.remains > 0 then
        return current_time + cooldown.tigers_fury.remains < future_time
    end
    if buff.berserk.up then
        return current_time + buff.berserk.remains < future_time
    end
    return true
end)


spec:RegisterStateFunction("berserk_expected_at", function(current_time, future_time)
    if not talent.berserk.enabled then
        return false
    end
    if buff.berserk.up then
        return future_time < current_time + buff.berserk.remains
    end
    if cooldown.berserk.remains > 0 then
        return (future_time > current_time + cooldown.berserk.remains)
    end
    if buff.tigers_fury.up then
        return (future_time > current_time + buff.tigers_fury.remains)
    end

    return tf_expected_before(current_time, future_time)
end)


spec:RegisterStateExpr("rip_refresh_pending", function()
    return debuff.rip.up and (debuff.rip.remains < ttd - base_end_thresh) and (combo_points.current >= (is_execute_phase and 1 or 5))
end)

spec:RegisterStateExpr("rake_refresh_pending", function()
    return debuff.rake.up and (debuff.rake.remains < ttd - debuff.rake.tick_time)
end)

spec:RegisterStateExpr("roar_refresh_pending", function()
    return buff.savage_roar.up and (buff.savage_roar.remains < ttd - latency) and combo_points.current >= 1
end)

--- Calculates and returns a table of pending actions with their respective refresh times and costs.
spec:RegisterStateExpr("pending_actions", function()
    local pending_actions = {
        mangle_cat = {
            refresh_time = 0,
            refresh_cost = 0
        },
        rake = {
            refresh_time = 0,
            refresh_cost = 0
        },
        rip = {
            refresh_time = 0,
            refresh_cost = 0
        },
        savage_roar = {
            refresh_time = 0,
            refresh_cost = 0
        }
    }

    if rip_refresh_pending and query_time < rip_refresh_time then
        pending_actions.rip.refresh_time = rip_refresh_time
        pending_actions.rip.refresh_cost = action.rip.cost * (berserk_expected_at(query_time, rip_refresh_time) and 0.5 or 1)
    else
        pending_actions.rip.refresh_time = 0
        pending_actions.rip.refresh_cost = 0
    end

    if rake_refresh_pending and debuff.rake.remains > debuff.rake.tick_time then
        pending_actions.rake.refresh_time = debuff.rake.expires - debuff.rake.tick_time
        pending_actions.rake.refresh_cost = action.rake.cost * (berserk_expected_at(query_time, pending_actions.rake.refresh_time) and 0.5 or 1)
    else
        pending_actions.rake.refresh_time = 0
        pending_actions.rake.refresh_cost = 0
    end

    if mangle_refresh_pending then
        pending_actions.mangle_cat.refresh_time = query_time + debuff.mangle.remains
        pending_actions.mangle_cat.refresh_cost = action.mangle_cat.cost * (berserk_expected_at(query_time, pending_actions.mangle_cat.refresh_time) and 0.5 or 1)
    else
        pending_actions.mangle_cat.refresh_time = 0
        pending_actions.mangle_cat.refresh_cost = 0
    end

    if roar_refresh_pending then
        pending_actions.savage_roar.refresh_time = buff.savage_roar.expires
        pending_actions.savage_roar.refresh_cost = action.savage_roar.cost * (berserk_expected_at(query_time, buff.savage_roar.expires) and 0.5 or 1)
    else
        pending_actions.savage_roar.refresh_time = 0
        pending_actions.savage_roar.refresh_cost = 0
    end

    if pending_actions.rip.refresh_time > 0 and pending_actions.savage_roar.refresh_time > 0 then
        if pending_actions.rip.refresh_time < pending_actions.savage_roar.refresh_time then
            pending_actions.savage_roar.refresh_time = 0
            pending_actions.savage_roar.refresh_cost = 0
        else
            pending_actions.rip.refresh_time = 0
            pending_actions.rip.refresh_cost = 0
        end
    end
    
    return pending_actions
end)

--- This function sorts pending actions based on their refresh times.
-- Actions with a refresh time of 0 are placed at the end of the list.
spec:RegisterStateFunction("sorted_actions", function(pending_actions_map)
    Hekili:Debug("sorted_actions called")
    local sorted_action_list = {}
    for entry in pairs(pending_actions_map) do
        table.insert(sorted_action_list, entry)
    end

    table.sort(sorted_action_list, function(a, b)
        if pending_actions_map[a].refresh_time == 0 then
            return false
        elseif pending_actions_map[b].refresh_time == 0 then
            return true
        else
            return pending_actions_map[a].refresh_time < pending_actions_map[b].refresh_time
        end
    end)

    return sorted_action_list
end)

--- Calculates and returns the refresh time of the next pending action.
spec:RegisterStateExpr("next_refresh_at", function()
    local pending_actions_map = pending_actions
    local sorted_action_list = sorted_actions(pending_actions_map)
    
    return pending_actions_map[sorted_action_list[1]].refresh_time
end)

spec:RegisterStateExpr("excess_e", function()
    --if active_enemies <= 2 then
        
    --else
    --    if buff.savage_roar.up then
    --        pending_actions.savage_roar.refresh_time = query_time + buff.savage_roar.remains
    --        pending_actions.savage_roar.refresh_cost = 25 * (berserk_expected_at(query_time, query_time + buff.savage_roar.remains) and 0.5 or 1)
    --        if combo_points.current == 0 and buff.savage_roar.remains > 1 then
    --            if set_bonus.idol_of_the_corruptor == 1 or set_bonus.idol_of_mutilation == 1 then
    --                pending_actions.mangle_cat.refresh_time = query_time + buff.savage_roar.remains - 1
    --                pending_actions.mangle_cat.refresh_cost = 40 * (berserk_expected_at(query_time, query_time + debuff.mangle.remains) and 0.5 or 1)
    --                pending_actions.rake.refresh_time = 0
    --                pending_actions.rake.refresh_cost = 0
    --            else
    --                pending_actions.rake.refresh_time = query_time + buff.savage_roar.remains - 1
    --                pending_actions.rake.refresh_cost = 40 * (berserk_expected_at(query_time, query_time + debuff.rake.remains) and 0.5 or 1)
    --                pending_actions.mangle_cat.refresh_time = 0
    --                pending_actions.mangle_cat.refresh_cost = 0
    --            end
    --        else
    --            pending_actions.rake.refresh_time = 0
    --            pending_actions.rake.refresh_cost = 0
    --            pending_actions.mangle_cat.refresh_time = 0
    --            pending_actions.mangle_cat.refresh_cost = 0
    --        end
    --    else
    --        pending_actions.savage_roar.refresh_time = 0
    --        pending_actions.savage_roar.refresh_cost = 0
    --        pending_actions.rake.refresh_time = 0
    --        pending_actions.rake.refresh_cost = 0
    --        pending_actions.mangle_cat.refresh_time = 0
    --        pending_actions.mangle_cat.refresh_cost = 0
    --    end
    --end

    

    local floating_energy = 0
    local previous_time = query_time
    local tf_pending = false
    local regen_rate = energy.regen
    local pending_actions_map = pending_actions
    local sorted_action_list = sorted_actions(pending_actions_map)

    for i = 1, #sorted_action_list do
        local entry = sorted_action_list[i]
        if pending_actions_map[entry].refresh_time > 0 and pending_actions_map[entry].refresh_time < 3600 then
            local elapsed_time = pending_actions_map[entry].refresh_time - previous_time
            local energy_gain = elapsed_time * regen_rate
            if not tf_pending then
                tf_pending = tf_expected_before(query_time, pending_actions_map[entry].refresh_time)
                if tf_pending then
                    pending_actions_map[entry].refresh_cost = pending_actions_map[entry].refresh_cost - 60
                end
            end

            if energy_gain < pending_actions_map[entry].refresh_cost then
                floating_energy = floating_energy + pending_actions_map[entry].refresh_cost -  energy_gain
                previous_time = pending_actions_map[entry].refresh_time
            else
                previous_time = previous_time + pending_actions_map[entry].refresh_cost / regen_rate
            end
        end
    end

    local time_to_cap = query_time + (energy.max - energy.current) / regen_rate
    local time_to_end = query_time + ttd
    local trinket_active = false
    local earliest_proc = 0
    local earliest_proc_end = 0
    if settings.optimize_trinkets and debuff.rip.up then
        for entry in pairs(trinket) do
            if tonumber(entry) then
                local t = trinket[entry]
                if t.proc and t.ability then
                    local t_action = action[t.ability]
                    if t_action and t_action.cooldown > 0 then
                        local t_buff = nil

                        -- Find the trinket buff to inspect
                        local aura_type = type(t_action.aura)
                        local auras_type = type(t_action.auras)
                        if aura_type == "number" and t_action.aura > 0 
                        or aura_type == "string" and #t_action.aura > 0 then
                            t_buff = buff[t_action.aura]
                        elseif auras_type == "table" then
                            for a in pairs(t_action.auras) do
                                if buff[a].up then
                                    t_buff = buff[a]
                                    break
                                elseif t_buff == nil 
                                or buff[a].last_application > t_buff.last_application then
                                    t_buff = buff[a]
                                end
                            end
                        end

                        if t_buff then
                            local t_earliest_proc = t_buff.last_application > 0 and (t_buff.last_application + t_action.cooldown) or 0
                            if t_earliest_proc > 0 and (earliest_proc == 0 or t_earliest_proc < earliest_proc) then
                                earliest_proc = t_earliest_proc
                                earliest_proc_end = t_earliest_proc + t_buff.duration
                            end
                            trinket_active = trinket_active or t_buff.up
                            Hekili:Debug(tostring(t.ability).." trinket proc at approximately "..tostring(earliest_proc - query_time))
                        end
                    end
                end
            end
        end
        
        if (not trinket_active) and earliest_proc > 0 and earliest_proc < time_to_cap and earliest_proc_end <= time_to_end then
            floating_energy = max(floating_energy, energy.max)
            Hekili:Debug("(excess_e) Pooling to "..tostring(floating_energy).." for trinket proc at approximately "..tostring(earliest_proc - query_time))
        end
    end

    if combo_points.current == 5 and not (bite_now)
        and (not trinket_active) and buff.savage_roar.up and buff.savage_roar.remains < ttd
        and rip_refresh_pending
        and min(buff.savage_roar.remains, debuff.rip.remains) < time_to_cap - query_time then
            floating_energy = max(floating_energy, energy.max)
            Hekili:Debug("(excess_e) Pooling to "..tostring(floating_energy).." for next finisher")
    end

    return energy.current - floating_energy
end)


spec:RegisterStateExpr("should_bearweave", function() -- aka can_bearweave
    if not bearweaving_enabled or buff.clearcasting.up or buff.berserk.up or (buff.stampede_cat.up and active_enemies == 1) then
        return false
    end

    local target_weave_duration = 1.5 * 2 + latency * 2
    if talent.furor.rank == 3 and (not leaveweaving_enabled or cooldown.feral_charge_cat.remains > target_weave_duration) then
        target_weave_duration = target_weave_duration + 1.5
    end

    local furor_cap = min(100 * talent.furor.rank/3, 100 - 1.5 * energy.regen)
    local weave_energy = furor_cap - target_weave_duration * energy.regen

    if energy.current > weave_energy then
        Hekili:Debug("Current Energy %d is higher than maximum Energy to start Weave %d without capping %d.", energy.current, weave_energy, furor_cap)
        return false
    end

    -- Prioritize all timers over weaving
    local default_weave_duration = 1.5 * 3 + latency * 2
    local earliest_weave_end = query_time + default_weave_duration
    local next_refresh_time = next_refresh_at
    local is_pooling = next_refresh_time > 0

    if is_pooling and next_refresh_time < earliest_weave_end then
        Hekili:Debug("is_pooling (%s) and next_refresh_at (%d) < earliest_weave_end (%d)", tostring(is_pooling), next_refresh_time, earliest_weave_end)
        return false
    end

    -- Mana check
    if mana.current < action.cat_form.spend * 2 then
        Hekili:Debug("Current Mana (%d) not enough for two shifts", mana.current)
        return false
    end

    -- Also add a condition to make sure we can spend down our Energy post-weave before the encounter ends or TF is ready.
    local energy_to_dump = energy.current + default_weave_duration * energy.regen
    local time_to_dump = earliest_weave_end + floor(energy_to_dump / action.shred.cost)
    Hekili:Debug("time_to_dump (%d) - query_time < ttd (%d) and not tf_expected_before (%d))", time_to_dump, query_time, ttd, tf_expected_before(query_time, time_to_dump))
    return time_to_dump - query_time < ttd and not tf_expected_before(query_time, time_to_dump)
end)


spec:RegisterStateExpr("should_cat", function() -- aka terminate_bearweave
     -- Shift back early if a bear auto resulted in an Omen proc
    if buff.clearcasting.up then
		return true
	end

    -- Also terminate early if Feral Charge is off cooldown to avoid accumulating delays for Ravage opportunities
    if leaveweaving_enabled and cooldown.feral_charge_cat.up and query_time - action.bear_form.lastCast > 1.5 then
        return true
    end

    -- Check Energy pooling leeway
    local next_gcd_length = (action.thrash.ready or action.mangle_bear.ready) and 1.5 or 0
    local smallest_weave_extension = next_gcd_length + latency
    local final_energy = energy.current + smallest_weave_extension * energy.regen
    
    local furor_cap = min(100 * talent.furor.rank/3, 100 - 1.5 * energy.regen)
    if final_energy > furor_cap then
        return true
    end

    -- Check timer leeway
    local earliest_weave_end = query_time + smallest_weave_extension + 1.5
    local next_refresh_time = next_refresh_at
    local is_pooling = next_refresh_time > 0

    if is_pooling and next_refresh_time < earliest_weave_end then
        return true
    end

    -- Also add a condition to prevent extending a weave if we don't have enough time to spend the pooled Energy thus far.
    local energy_to_dump = final_energy + 1.5 * energy.regen -- need to include Cat Form GCD here
    local time_to_dump = earliest_weave_end + floor(energy_to_dump / action.shred.cost)
    
    return (time_to_dump - query_time >= ttd) or tf_expected_before(query_time, time_to_dump)
end)

spec:RegisterStateExpr("movement_speed", function()
    return select( 2, GetUnitSpeed( "player" ) )
end)

-- Calculate if we should Leaveweave/Meleeweave (run out and feral_charge_cat in for stampede)
spec:RegisterStateExpr("should_leaveweave", function()
    -- Estimate time to run out and charge back in
    local run_out_time = (action.feral_charge_cat.real_minRange + 1 - target.distance) / movement_speed + latency
    local charge_in_time = (action.feral_charge_cat.real_minRange + 1) / 80 + latency
    local weave_duration = run_out_time + charge_in_time
    local weave_energy = energy.max - (weave_duration * energy.regen)

    if (not leaveweaving_enabled) or (cooldown.feral_charge_cat.remains >= run_out_time - latency) or (energy.current > weave_energy) or aggro or buff.clearcasting.up or buff.berserk.up then
        return false
    end

    -- Prioritize all timers over weaving
    local weave_end = query_time + weave_duration
    local next_refresh_time = next_refresh_at
    local is_pooling = next_refresh_time > 0

    if (is_pooling and next_refresh_time < weave_end) or tf_expected_before(query_time, weave_end) then
        return false
    end

    -- Also add an end-of-fight condition to make sure we can spend down our Energy post-weave before the encounter ends.
    local energy_to_dump = energy.current + weave_duration * energy.regen
    local time_to_dump = floor(energy_to_dump / action.shred.cost)
    return weave_duration + time_to_dump < ttd
end)

spec:RegisterStateExpr("bear_mode_tank_enabled", function()
    return settings.bear_form_mode == "tank"
end)

spec:RegisterStateExpr("bearweaving_enabled", function()
    return settings.bearweaving_enabled and (settings.bearweaving_bossonly == false or state.encounterDifficulty > 0) and (settings.bearweaving_instancetype == "any" or (settings.bearweaving_instancetype == "dungeon" and (instanceType == "party" or instanceType == "raid")) or (settings.bearweaving_instancetype == "raid" and instanceType == "raid"))
end)

-- Resources
spec:RegisterResource( Enum.PowerType.Rage, {
    enrage = {
        aura = "enrage",

        last = function()
            local app = state.buff.enrage.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 2
    },

    mainhand = {
        swing = "mainhand",
        aura = "bear_form",

        last = function()
            local swing = state.combat == 0 and state.now or state.swings.mainhand
            local t = state.query_time

            return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
        end,

        interval = "mainhand_speed",

        stop = function() return state.swings.mainhand == 0 end,
        value = function( now )
            return rage_amount()
        end,
    },
} )
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy)


-- Talents
spec:RegisterTalents( {
    --balance
    balance_of_power = {1783, 2, 33592, 33596},
    dreamstate = {1784, 2, 33597, 33599},
    earth_and_moon = {11277, 1, 48506},
    euphoria = {7457, 2, 81061, 81062},
    force_of_nature = {10014, 1, 33831},
    fungal_growth = {10018, 2, 78788, 78789},
    gale_winds = {1925, 2, 48488, 48514},
    genesis = {11284, 3, 57810, 57811, 57812},
    lunar_shower = {10008, 3, 33603, 33604, 33605},
    moonfury = {792, 1, 16913},
    moonglow = {9968, 3, 16845, 16846, 16847},
    moonkin_form = {11278, 1, 24858},
    natures_grace = {9974, 3, 16880, 61345, 61346},
    natures_majesty = {9970, 2, 35363, 35364},
    owlkin_frenzy = {10006, 3, 48389, 48392, 48393},
    shooting_stars = {8381, 2, 93398, 93399},
    solar_beam = {9976, 1, 78675},
    starfall = {10020, 1, 48505},
    starlight_wrath = {9964, 3, 16814, 16815, 16816},
    sunfire = {12150, 1, 93401},
    typhoon = {10012, 1, 50516},

    --feral
    berserk = {9270, 1, 50334},
    blood_in_the_water = {9264, 2, 80318, 80319},
    brutal_impact = {9232, 2, 16940, 16941},
    endless_carnage = {11194, 2, 80314, 80315},
    feral_aggression = {11285, 2, 16858, 16859},
    feral_charge = {9222, 1, 49377},
    feral_swiftness = {9218, 2, 17002, 24866},
    furor = {11716, 3, 17056, 17058, 17059},
    fury_swipes = {9228, 3, 48532, 80552, 80553},
    infected_wounds = {9256, 2, 48483, 48484},
    king_of_the_jungle = {9246, 3, 48492, 48494, 48495},
    leader_of_the_pack = {9248, 1, 17007},
    mangle = {  1796, 1, 33917 },
    natural_reaction = {9240, 2, 57878, 57880},
    nurturing_instinct = {9226, 2, 33872, 33873},
    predatory_strikes = {9238, 2, 16972, 16974},
    primal_fury = {8761, 2, 37116, 37117},
    primal_madness = {8335, 2, 80316, 80317},
    pulverize = {9317, 1, 80313},
    rend_and_tear = {9266, 3, 48432, 48433, 48434},
    stampede = {8301, 2, 78892, 78893},
    survival_instincts = {9236, 1, 61336},
    thick_hide = {8293, 3, 16929, 16930, 16931},

    --restoration
    blessing_of_the_grove = {9665, 2, 78784, 78785},
    efflorescence = {9357, 3, 34151, 81274, 81275},
    empowered_touch = {9355, 2, 33879, 33880},
    fury_of_stormrage = {11712, 2, 17104, 24943},
    gift_of_the_earthmother = {9371, 3, 51179, 51180, 51181},
    heart_of_the_wild = {11715, 3, 17003, 17004, 17005},
    improved_rejuvenation = {9339, 3, 17111, 17112, 17113},
    living_seed = {9347, 3, 48496, 48499, 48500},
    malfurions_gift = {12146, 2, 92363, 92364},
    master_shapeshifter = {8277, 1, 48411},
    natural_shapeshifter = {8237, 2, 16833, 16834},
    naturalist = {11699, 2, 17069, 17070},
    natures_bounty = {9349, 3, 17074, 17075, 17076},
    natures_cure = {8763, 1, 88423},
    natures_swiftness = {9343, 1, 17116},
    natures_ward = {8267, 2, 33881, 33882},
    perseverance = {11279, 3, 78734, 78735, 78736},
    revitalize = {8269, 2, 48539, 48544},
    swift_rejuvenation = {8265, 1, 33886},
    tree_of_life = {8271, 1, 33891},
    wild_growth = {8279, 1, 48438},
    
} )


-- Glyphs
spec:RegisterGlyphs( {
    --Prime
    [62969] = "berserk",--Increases the duration of Berserk by 10 sec.
    [54815] = "bloodletting",--Each time you Shred or Mangle in Cat Form, the duration of your Rip on the target is extended by 2 sec, up to amaximum of 6 sec.
    [54830] = "insect_swarm",--Increases the damage of your Insect Swarm ability by 30%.
    [94382] = "lacerate",--Increases the critical strike chance of your Lacerate ability by 5%.
    [54826] = "lifebloom",--Increases the critical effect chance of your Lifebloom by 10%.
    [54813] = "mangle",--Increases the damage done by Mangle by 10%.
    [54829] = "moonfire",--Increases the periodic damage of your Moonfire ability by 20%.
    [54743] = "regrowth",--Your Regrowth heal-over-time will automatically refresh its duration on targets at or below 50% health.
    [54754] = "rejuvenation",--Increases the healing done by your Rejuvenation by 10%.
    [54818] = "rip",--Increases the periodic damage of your Rip by 15%.
    [63055] = "savage Roar",--Your Savage Roar ability grants an additional 5% bonus damage done.
    [54845] = "starfire",--Your Starfire ability increases the duration of your Moonfire effect on the target by 3 sec, up to a maximum of 9 additional seconds. Only functions on the target With your most recently applied Moonfire.
    [62971] = "starsurge",--When your Starsurge deals damage, the cooldown remaining on your Starfall is reduced by 5 sec.
    [54824] = "swiftmend",--Your Swiftmend ability no longer consumes a Rejuvenation or Regrowth effect from the target.
    [94390] = "tigers_fury",--Reduces the cooldown of your Tiger's Fury ability by 3 sec.
    [62970] = "wrath",--Increases the damage done by your Wrath by 10%.
    --Major
    [63057] = "barkskin",--Reduces the chance you'll be critically hit by 25% while Barkskin is active.
    [54760] = "entangling_roots",--Reduces the cast time ofyour Entangling Roots by 0.2 sec.
    [94386] = "faerie_fire",--Increases the range ofyour Faerie Fire and Feral Faerie Fire abilities by 10 yds.
    [94388] = "feral_charge",--Reduces the cooldown of your Feral Charge (Cat) ability by 2 sec and the cooldown of your Feral Charge (Bear) ability by 1 sec.
    [67598] = "ferocious_bite",--Your Ferocious Bite ability heals you for 1 % ofyour maximum health for each 10 energy used.
    [62080] = "focus",--Increases the damage done by Starfall by 10%, but decreases its radius by 50%.
    [54810] = "frenzied_regeneration",--While Frenzied Regeneration is active, healing effects on you are 30% more powerful but causes your Frenzied Regeneration to no longer convert rage into health.
    [54825] = "healing_touch",--When you cast Healing Touch, the cooldown on your Nature's Swiftness is reduced by 1 0 sec.
    [54831] = "hurricane",--Your Hurricane ability now also slows the movement speed of its victims by 50%.
    [54832] = "innervate",--When Innervate is cast on a friendly target other than the caster, the caster will gain 10% of maximum mana over 10 sec.
    [54811] = "maul",--Your Maul ability now hits 1 additional target for 50% damage.
    [63056] = "monsoon",--Reduces the cooldown of your Typhoon spell by 3 sec.
    [413895] = "omen_of_clarity",--Your Omen of Clarity talent has a 100% chance to be triggered by successfully casting Faerie Fire(Feral). Does not trigger on players or player-controlled pets.
    [54821] = "pounce",--Increases the range of your Pounce by 3 yards.
    [54733] = "rebirth",--Players resurrected by Rebirth are returned to life With 100% health.
    [54812] = "solar_beam",--Increases the duration of your Solar Beam silence effect by 5 sec.
    [54828] = "starfall",--Reduces the cooldown of Starfall by 30 sec.
    [57862] = "thorns",--Reduces the cooldown of your Thorns spell by 20 sec.
    [54756] = "wild_growth",--Wild Growth can affect 1 additional target, but its cooldown is increased by 2 sec.
    --Minor
    [57856] = "aquatic_form",--Increases your swim speed by 50% while in Aquatic Form.
    [57858] = "challenging_roar",--Reduces the cooldown of your Challenging Roar ability by 30 sec.
    [59219] = "dash",--Reduces the cooldown of your Dash ability by 20%.
    [57855] = "mark_of_the_wild",--Mana cost of your Mark of the Wild reduced by 50%.
    [95212] = "the_treant",--Your Tree of Life Form now resembles a Treant.
    [62135] = "typhoon",--Reduces the cost of your Typhoon spell by 8% and increases its radius by 10 yards, but it no longer knocks enemies back.
    [57857] = "unburdened_rebirth",--Your Rebirth spell no longer requires a reagent.
} )


-- Auras
spec:RegisterAuras( {
    -- Attempts to cure $3137s1 poison every $t1 seconds.
    abolish_poison = {
        id = 2893,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
    },
    -- Immune to Polymorph effects.  Increases swim speed by $5421s1% and allows underwater breathing.
    aquatic_form = {
        id = 1066,
        duration = 3600,
        max_stack = 1,
    },
    -- All damage taken is reduced by $s2%.  While protected, damaging attacks will not cause spellcasting delays.
    barkskin = {
        id = 22812,
        duration = function() return 12 + ((set_bonus.tier7feral_4pc == 1 and 3) or 0) end,
        max_stack = 1,
    },
    -- Stunned.
    bash = {
        id = 5211,
        duration = function() return 4 + ( 0.5 * talent.brutal_impact.rank ) end,
        max_stack = 1,
        copy = { 5211, 6798, 8983, 58861 },
    },
    bear_form = {
        id = 5487,
        duration = 3600,
        max_stack = 1,
        copy = { 5487, 9634, "dire_bear_form" }
    },
    -- Your Lacerate periodic damage has a 50% chance to refresh the cooldown of Mangle (Bear) and make it free. 
    -- When activated, this ability allows Mangle (Bear) to hit up to 3 targets with no cooldown, 
    -- reduces Cat Form abilities' energy cost by 50% for 15 seconds, and prevents the use of Tiger's Fury during Berserk.
    berserk = {
        id = 50334,
        duration = function() return glyph.berserk.enabled and 25 or 15 end,
        max_stack = 1,
    },
    -- Immunity to Polymorph effects.  Increases melee attack power by $3025s1 plus Agility.
    cat_form = {
        id = 768,
        duration = 3600,
        max_stack = 1,
    },
    -- Taunted.
    challenging_roar = {
        id = 5209,
        duration = 6,
        max_stack = 1,
    },
    -- Your next damage or healing spell or offensive ability has its mana, rage or energy cost reduced by $s1%.
    clearcasting = {
        id = 16870,
        duration = 15,
        max_stack = 1,
        copy = "omen_of_clarity"
    },
    -- Invulnerable, but unable to act.
    cyclone = {
        id = 33786,
        duration = 6,
        max_stack = 1,
    },
    -- Increases movement speed by $s1% while in Cat Form.
    dash = {
        id = 33357,
        duration = 15,
        max_stack = 1,
        copy = { 1850, 9821, 33357 },
    },
    -- Dazed.
    dazed = {
        id = 50411,
        duration = 3,
        max_stack = 1,
        copy = { 50411, 50259 },
    },
    -- Decreases melee attack power by $s1.
    demoralizing_roar = {
        id = 48560,
        duration = 30,
        max_stack = 1,
        copy = { 99, 1735, 9490, 9747, 9898, 26998, 48559, 48560 },
    },
    -- Increases spell damage taken by $s1%.
    earth_and_moon = {
        id = 60433,
        duration = 15,
        max_stack = 1,
        copy = { 60433, 60432, 60431 },
    },
    -- Starfire critical hit +40%.
    eclipse_lunar = {
        id = 48518,
        duration = 3600,
        max_stack = 1,
        last_applied = 0,
        copy = "lunar_eclipse",
    },
    -- Wrath damage bonus.
    eclipse_solar = {
        id = 48517,
        duration = 3600,
        max_stack = 1,
        last_applied = 0,
        copy = "eclipse_solar",
    },
    eclipse = {
        alias = { "eclipse_lunar", "eclipse_solar" },
        aliasType = "buff",
        aliasMode = "first"
    },
    -- Your next Starfire will be an instant cast spell.
    elunes_wrath = {
        id = 64823,
        duration = 10,
        max_stack = 1,
    },
    -- Gain $/10;s1 rage per second.  Base armor reduced.
    enrage = {
        id = 5229,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
    },
    -- Rooted.  Causes $s2 Nature damage every $t2 seconds.
    entangling_roots = {
        id = 19975,
        duration = 27,
        max_stack = 1,
        copy = { 339, 1062, 5195, 5196, 9852, 9853, 19970, 19971, 19972, 19973, 19974, 19975, 26989, 27010, 53308, 53313, 65857, 66070 },
    },
    -- Reduces damage from falling.
    feline_grace = {
        id = 20719,
        duration = 3600,
        max_stack = 1,
    },
    -- Increases the damage caused by your Ferocious Bite by 10% and causes Faerie Fire (Feral) to apply 3 stacks of the Faerie Fire effect when cast.
    feral_aggression = {
        id = 16859,
        duration = 3600,
        max_stack = 1,
        copy = { 16862, 16861, 16860, 16859, 16858 },
    },
    -- Immobilized.
    feral_charge_effect = {
        id = 45334,
        duration = 4,
        max_stack = 1,
        copy = { 45334, 19675 },
    },
    flight_form = {
        id = 33943,
        duration = 3600,
        max_stack = 1,
    },
    force_of_nature = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=33831)
        id = 33831,
        duration = 30,
        max_stack = 1,
    },
    form = {
        alias = { "aquatic_form", "cat_form", "bear_form", "flight_form", "moonkin_form", "swift_flight_form", "travel_form"  },
        aliasType = "buff",
        aliasMode = "first"
    },
    -- Converting rage into health.
    frenzied_regeneration = {
        id = 22842,
        duration = 20,
        tick_time = 1,
        max_stack = 1,
        copy = { 22842, 22895, 22896, 26999 },
    },
    -- Taunted.
    growl = {
        id = 6795,
        duration = 3,
        max_stack = 1,
    },
    -- Asleep.
    hibernate = {
        id = 2637,
        duration = 40,
        max_stack = 1,
        copy = { 2637, 18657, 18658 },
    },
    -- $42231s1 damage every $t3 seconds, and time between attacks increased by $s2%.$?$w1<0[ Movement slowed by $w1%.][]
    hurricane = {
        id = 16914,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
        copy = { 16914, 17401, 17402, 27012, 48467 },
    },
    -- TODO: remove 
    improved_rejuvenation = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=17113)
        id = 17113,
        duration = 3600,
        max_stack = 1,
        copy = { 17113, 17112, 17111 },
    },
    -- Movement speed slowed by $s1% and attack speed slowed by $s2%.
    infected_wounds = {
        id = 58179,
        duration = 12,
        max_stack = 1,
        copy = { 58181, 58180, 58179 },
    },
    -- Regenerating mana.
    innervate = {
        id = 29166,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
    },
    -- Chance to hit with melee and ranged attacks decreased by $s2% and $s1 Nature damage every $t1 sec.
    insect_swarm = {
        id = 5570,
        duration = 12,
        tick_time = 2,
        max_stack = 1,
        copy = { 5570, 24974, 24975, 24976, 24977, 27013, 48468 },
    },
    -- $s1 damage every $t sec
    lacerate = {
        id = 33745,
        duration = 15,
        tick_time = 3,
        max_stack = 3,
        copy = { 33745, 48567, 48568 },
    },
    -- Heals $s1 every second and $s2 when effect finishes or is dispelled.
    lifebloom = {
        id = 33763,
        duration = 10,
        tick_time = 1,
        max_stack = 3,
        copy = { 33763, 48450, 48451 },
    },
    mark_of_the_wild = {
        id = 79061,
        duration = 36000,
        max_stack = 1,
        shared = "player",
        copy = { 1126, 5232, 5234, 6756, 8907, 9884, 9885, 16878, 24752, 26990, 39233, 48469 },
    },
    -- TODO: remove
    maul = {
        duration = function() return swings.mainhand_speed end,
        max_stack = 1,
    },
    -- $s1 Arcane damage every $t1 seconds.
    moonfire = {
        id = 8921,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
        copy = { 8921, 8924, 8925, 8926, 8927, 8928, 8929, 9833, 9834, 9835, 26987, 26988, 48462, 48463, 65856 },
    },
    -- Increases spell critical chance by $s1%.
    moonkin_aura = {
        id = 24907,
        duration = 3600,
        max_stack = 1,
    },
    -- Immune to Polymorph effects.  Armor contribution from items is increased by $24905s1%.  Damage taken while stunned reduced $69366s1%.  Single target spell criticals instantly regenerate $53506s1% of your total mana.
    moonkin_form = {
        id = 24858,
        duration = 3600,
        max_stack = 1,
    },
    -- Reduces all damage taken by $s1%.
    natural_perfection = {
        id = 45283,
        duration = 8,
        max_stack = 3,
        copy = { 45281, 45282, 45283 },
    },
    natural_shapeshifter = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=16835)
        id = 16833,
        duration = 6,
        max_stack = 1,
        copy = { 16835, 16834, 16833 },
    },
    -- Reduces the cast time of your Healing Touch and Nourish spells by 0.50 sec.
    naturalist = {
        id = 17070,
        duration = 3600,
        max_stack = 1,
        copy = { 17073, 17072, 17071, 17070, 17069 },
    },
    -- Spell casting speed increased by $s1%.
    natures_grace = {
        id = 16886,
        duration = 15,
        max_stack = 1,
    },
    -- Melee damage you take has a chance to entangle the enemy.
    natures_grasp = {
        id = 16689,
        duration = 45,
        max_stack = 1,
        copy = { 16689, 16810, 16811, 16812, 16813, 17329, 27009, 53312, 66071 },
    },
    -- Your next Nature spell will be an instant cast spell.
    natures_swiftness = {
        id = 17116,
        duration = 3600,
        max_stack = 1,
    },
    -- Damage increased by $s2%, $s3% base mana is restored every $T3 sec, and damage done to you no longer causes pushback.
    owlkin_frenzy = {
        id = 48391,
        duration = 10,
        max_stack = 1,
    },
    -- Stunned.
    pounce = {
        id = 9005,
        duration = 3,
        max_stack = 1,
        copy = { 9005, 9823, 9827, 27006, 49803 },
    },
    -- Bleeding for $s1 damage every $t1 seconds.
    pounce_bleed = {
        id = 9007,
        duration = 18,
        tick_time = 3,
        max_stack = 1,
        copy = { 9007, 9824, 9826, 27007, 49804 },
    },
    -- Your next Nature spell will be an instant cast spell.
    predators_swiftness = {
        id = 69369,
        duration = 8,
        max_stack = 1,
    },
    -- Total Energy increased by 20.
    primal_madness = {
        id = 80886,
        duration = 20,
        max_stack = 1,
    },
    -- Stealthed.  Movement speed slowed by $s2%.
    prowl = {
        id = 5215,
        duration = 3600,
        max_stack = 1,
    },
    -- Melee critical strike chance increased by 3%.
    pulverize = {
        id = 80951,
        duration = 10,
        max_stack = 3,

    },
    -- Bleeding for $s2 damage every $t2 seconds.
    rake = {
        id = 1822,
        duration = function() return 9 + (talent.endless_carnage.rank * 3) + ((set_bonus.tier9feral_2pc == 1 and 3) or 0) end,
        tick_time = 3,
        mechanic = "bleed",
        max_stack = 1,
        copy = { 1822, 1823, 1824, 9904, 27003, 48573, 48574, 59881, 59882, 59883, 59884, 59885, 59886 },
    },
    -- Heals $s2 every $t2 seconds.
    regrowth = {
        id = 8936,
        duration = 6,
        max_stack = 1,
        copy = { 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858, 26980, 48442, 48443, 66067 },
    },
    -- Heals $s1 damage every $t1 seconds.
    rejuvenation = {
        id = 774,
        duration = 12,
        tick_time = 3,
        max_stack = 1,
        copy = { 774, 1058, 1430, 2090, 2091, 3627, 8070, 8910, 9839, 9840, 9841, 25299, 26981, 26982, 48440, 48441 },
    },
    -- Bleed damage every $t1 seconds.
    rip = {
        id = 1079,
        duration = function() return 16 + ((set_bonus.tier7feral_2pc == 1 and 4) or 0) end,
        tick_time = 2,
        max_stack = 1,
        copy = { 1079, 9492, 9493, 9752, 9894, 9896, 27008, 49799, 49800 },
    },
    -- Absorbs physical damage equal to $s1% of your attack power for 1 hit.
    savage_defense = {
        id = 62606,
        duration = 10,
        max_stack = 1,
    },
    -- Physical damage done increased by $s2%.
    savage_roar = {
        id = 52610,
        duration = function()
            if combo_points.current == 0 then
                return 0
            end
            -- The base duration is 14s + 5s per extra CP. We assume 9s for 0 CP to make the calculations easier.
            return 9 + (combo_points.current * 5) + (talent.endless_carnage.rank * 4) + (set_bonus.tier8feral_4pc == 1 and 8 or 0)
        end,
        max_stack = 1,
        copy = { 52610 },
    },
    -- Melee haste increased by 15%.
    stampede_bear = {
        id = 81016,
        duration = 8,
        max_stack = 1,
        copy = {81016, 81017}

    },
    -- Your next Ravage can be used without requiring stealth or proper positioning, and costs 100% less energy.
    stampede_cat = {
        id = 81021,
        duration = 10,
        max_stack = 1,
        copy = {81021, 81022}

    },
    -- Summoning stars from the sky.
    starfall = {
        id = 48505,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
        copy = { 48505, 50286, 50288, 50294, 53188, 53189, 53190, 53191, 53194, 53195, 53196, 53197, 53198, 53199, 53200, 53201 },
    },
    -- Reduces the cast time of your Wrath and Starfire spells by 0.15-0.5 sec.
    starlight_wrath = {
        id = 16815,
        duration = 3600,
        max_stack = 1,
        copy = { 16818, 16817, 16816, 16815, 16814 },
    },
    -- Increases your attack power by 1% for 30 sec when you use Mangle (Cat).  Stacks up to 3 times. tier11feral_4pc-Bonus
    strength_of_the_panther = {
        id = 90166,
        duration = 30,
        max_stack = 3,
    },
    -- Health increased by 30% of maximum while in Bear Form, Cat Form, or Dire Bear Form.
    survival_instincts = {
        id = 61336,
        duration = 12,
        max_stack = 1,
    },
    -- Immune to Polymorph effects.  Movement speed increased by $40121s2% and allows you to fly.
    swift_flight_form = {
        id = 40120,
        duration = 3600,
        max_stack = 1,
    },
    -- Causes $s1 Nature damage to attackers.
    thorns = {
        id = 467,
        duration = 20,
        max_stack = 1,
        shared = "target",
        copy = { 467, 782, 1075, 8914, 9756, 9910, 16877, 26992, 53307, 66068 },
    },
    -- Increases damage done by $s1.
    tigers_fury = {
        id = 5217,
        duration = 6,
        max_stack = 1,
        multiplier = function() return 1.15 end,
        copy = { 5217, 6793, 9845, 9846, 50212, 50213 },
    },
    -- Tracking humanoids.
    track_humanoids = {
        id = 5225,
        duration = 3600,
        max_stack = 1,
    },
    -- Heals nearby party members for $s1 every $t2 seconds.
    tranquility = {
        id = 740,
        duration = 8,
        max_stack = 1,
        copy = { 740, 8918, 9862, 9863, 26983, 48446, 48447 },
    },
    -- Immune to Polymorph effects.  Movement speed increased by $5419s1%.
    travel_form = {
        id = 783,
        duration = 3600,
        max_stack = 1,
    },
    -- Immune to Polymorph effects. Increases healing received by $34123s1% for all party and raid members within $34123a1 yards.
    tree_of_life = {
        id = 33891,
        duration = 25,
        max_stack = 1,
    },
    -- Dazed.
    typhoon = {
        id = 61391,
        duration = 6,
        max_stack = 1,
        copy = { 53227, 61387, 61388, 61390, 61391 },
    },
    -- Stunned.
    war_stomp = {
        id = 20549,
        duration = 2,
        max_stack = 1,
    },
    -- Heals $s1 damage every $t1 second.
    wild_growth = {
        id = 48438,
        duration = 7,
        tick_time = 1,
        max_stack = 1,
        copy = { 48438, 53248, 53249, 53251 },
    },

    rupture = {
        id = 1943,
        duration = 6,
        max_stack = 1,
        shared = "target",
        copy = { 1943, 8639, 8640, 11273, 11274, 11275, 26867, 48671 }
    },
    garrote = {
        id = 703,
        duration = 18,
        max_stack = 1,
        shared = "target",
        copy = { 703, 8631, 8632, 8633, 11289, 11290, 26839, 26884, 48675 }
    },
    rend = {
        id = 94009,
        duration = 15,
        max_stack = 1,
        shared = "target",
        copy = { 772, 6546, 6547, 6548, 11572, 11573, 11574, 25208, 94009 }
    },
    deep_wound = {
        id = 43104,
        duration = 12,
        max_stack = 1,
        shared = "target",
        copy = {43104, 413764}
    },
    bleed = {
        alias = { "lacerate", "pounce_bleed", "rip", "rake", "deep_wound", "rend", "garrote", "rupture" },
        aliasType = "debuff",
        aliasMode = "longest"
    }
} )


-- Form Helper
spec:RegisterStateFunction( "swap_form", function( form )
    removeBuff( "form" )
    removeBuff( "maul" )

    if form == "bear_form" then
        spend( rage.current, "rage" )
        if talent.furor.rank==3 then
            gain( 10, "rage" )
        end
    end

    if form then
        applyBuff( form )
    end
end )

-- Maul Helper
local finish_maul = setfenv( function()
    spend( (buff.clearcasting.up and 0) or (15 * ((buff.berserk.up and 0.5) or 1)), "rage" )
end, state )

spec:RegisterStateFunction( "start_maul", function()
    local next_swing = mainhand_remains
    if next_swing <= 0 then
        next_swing = mainhand_speed
    end
    applyBuff( "maul", next_swing )
    state:QueueAuraExpiration( "maul", finish_maul, buff.maul.expires )
end )


-- Abilities
spec:RegisterAbilities( {
    --Increases your attack power by 25%. In the Feral Abilities category. Requires Druid.  
    aggression = {
        id = 84735,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 132138,

        --fix:
        
        handler = function()
            --"/cata/spell=101690/greater-heal"
        end,

    },
    --Shapeshift into aquatic form, increasing swim speed by 50% and allowing the Druid to breathe underwater.  Also protects the caster from Polymorph effects.The act of shapeshifting frees the caster of movement slowing effects.
    aquatic_form = {
        id = 1066,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08, 
        spendType = "mana",

        startsCombat = true,
        texture = 132112,

        --fix:
        
        handler = function()
            swap_form( "aquatic_form" )
        end,

    },
    --The Druid's skin becomes as tough as bark.  All damage taken is reduced by 20%.  While protected, damaging attacks will not cause spellcasting delays.  This spell is usable while stunned, frozen, incapacitated, feared or asleep.  Usable in all forms.  Lasts 12 sec.
    barkskin = {
        id = 22812,
        cast = 0,
        cooldown = function() return 60 - ((set_bonus.tier9feral_4pc == 1 and 12) or 0) end,
        gcd = "off",

        

        startsCombat = true,
        texture = 136097,

        toggle = "cooldowns",
        
        handler = function()
        end,

    },
    --Stuns the target for 4 sec. In the Feral Abilities category. Requires Druid.  A spell from Classic World of Warcraft.
    bash = {
        id = 5211,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or 10 end, 
        spendType = "rage",

        startsCombat = true,
        texture = 132114,
        debuff = "casting",
        readyTime = state.timeToInterrupt,
        toggle = "interrupts",

        form = "bear_form",
        handler = function()
            interrupt()
            removeBuff( "clearcasting" )
        end,

    },
    --Shapeshift into Bear Form, increasing armor contribution from cloth and leather items by 120% and Stamina by 20%.  Significantly increases threat generation, causes Agility to increase attack power, and also protects the caster from Polymorph effects and allows the use of various bear abilities.The act of shapeshifting frees the caster of movement slowing effects.
    bear_form = {
        id = 5487,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.05, 
        spendType = "mana",

        startsCombat = true,
        texture = 132276,

        --fix:
        
        handler = function()
            swap_form( "bear_form" )
        end,

        copy = "dire_bear_form"
    },
    --Your Lacerate periodic damage has a 50% chance to refresh the cooldown of your Mangle (Bear) ability and make it cost no rage.  In addition, when activated this ability causes your Mangle (Bear) ability to hit up to 3 targets and have no cooldown, and reduces the energy cost of all your Cat Form abilities by 50%.  Lasts 15 sec.  You cannot use Tiger's Fury while Berserk is active.
    berserk = {
        id = 50334,
        cast = 0,
        cooldown = 180,
        gcd = "off",
        talent = "berserk",
        startsCombat = true,
        texture = 236149,
        toggle = "cooldowns",
        handler = function()
            applyBuff( "berserk" )
            if talent.primal_madness.enabled then
                if not buff.primal_madness.up then
                    energy.max = energy.max + 10 * talent.primal_madness.rank
                    gain(10 * talent.primal_madness.rank, "energy")
                end
                applyBuff("primal_madness", buff.berserk.duration)
                buff.primal_madness.expires = buff.berserk.expires
                state:QueueAuraExpiration( "primal_madness", ExpirePrimalMadness, buff.primal_madness.expires)                
            end
        end,
    },
    --When you Ferocious Bite a target at or below 25% health, you have a chance to instantly refresh the duration of your Rip on the target. Requires Druid.
    blood_in_the_water = {
        id = 80863,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 237347,

        --fix:
        
        handler = function()
            --"/cata/spell=80863/blood-in-the-water"
        end,

    },
    --Shapeshift into Cat Form, causing agility to increase attack power.  Also protects the caster from Polymorph effects and allows the use of various cat abilities.The act of shapeshifting frees the caster of movement slowing effects.
    cat_form = {
        id = 768,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.05, 
        spendType = "mana",

        startsCombat = true,
        texture = 132115,

        --fix:
        
        handler = function()
            swap_form( "cat_form" )
        end,

    },
    --Reduces the pushback suffered from damaging attacks while casting Wrath, Starfire, Entangling Roots, Hurricane, Typhoon, Hibernate, Cyclone, and Starfire by 70%.
    celestial_focus = {
        id = 84738,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 135728,

        --fix:
        
        handler = function()
            --"/cata/spell=45283/natural-perfection"
        end,

    },
    --Forces all nearby enemies within 10 yards to focus attacks on you for 6 sec. In the Feral Abilities category. Requires Druid. 
    challenging_roar = {
        id = 5209,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 15, 
        spendType = "rage",

        startsCombat = true,
        texture = 132117,

        form = "bear_form",
        handler = function()
        end,

    },
    --Claw the enemy, causing 77% of normal damage plus 637.  Awards 1 combo point. In the Feral Abilities category. Requires Druid. 
    claw = {
        id = 1082,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 40, 
        spendType = "energy",

        startsCombat = true,
        texture = 132140,

        form = "cat_form",
        handler = function()
            gain( 1, "combo_points" )
        end,

    },
    --Cower, causing no damage but lowering your threat by 10%, making the enemy less likely to attack you. In the Feral Abilities category. Requires Druid.
    cower = {
        id = 8998,
        cast = 0,
        cooldown = 10,
        gcd = "totem",

        spend = function() return 20 * ((buff.berserk.up and 0.5) or 1) end, 
        spendType = "energy",

        startsCombat = true,
        texture = 132118,

        form = "cat_form",
        handler = function()
            --"/cata/spell=8998/cower"
        end,

    },
    --Tosses the enemy target into the air, preventing all action but making them invulnerable for up to 6 sec.  Only one target can be affected by your Cyclone at a time.
    cyclone = {
        id = 33786,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08, 
        spendType = "mana",

        startsCombat = true,
        texture = 136022,

        --fix:
        
        handler = function()
        end,

    },
    --Increases movement speed by 70% while in Cat Form for 15 sec.  Does not break prowling. In the Feral Abilities category. Requires Druid. 
    dash = {
        id = 1850,
        cast = 0,
        cooldown = function() return 180 * ( glyph.dash.enabled and 0.8 or 1 ) end,
        gcd = "off",

        

        startsCombat = true,
        texture = 132120,
        toggle = "cooldowns",
        --fix:
        
        handler = function()
            --"/cata/spell=1850/dash"
        end,

    },
    --The Druid roars, reducing the physical damage caused by all enemies within 10 yards by 10% for 30 sec. In the Feral Abilities category. 
    demoralizing_roar = {
        id = 99,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 10, 
        spendType = "rage",

        startsCombat = true,
        texture = 132121,

        form = "bear_form",
        handler = function()
            applyDebuff( "target", "demoralizing_roar", 30 )
        end,

    },
    --Allows the druid to clear all roots when Shapeshifting in addition to snares. In the Restoration Abilities category. 
    disentanglement = {
        id = 96429,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 132158,

        --fix:
        
        handler = function()
            --"/cata/spell=100855/tranquility"
        end,

    },
    --In the Balance Abilities category. Requires Druid.   
    eclipse_mastery_driver_passive = {
        id = 79577,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 132347,

        --fix:
        
        handler = function()
            --"/cata/spell=79577/eclipse-mastery-driver-passive"
        end,

    },
    --Generates 20 Rage, and then generates an additional 10 Rage over 10 sec. In the Feral Abilities category. Requires Druid. 
    enrage = {
        id = 5229,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        

        startsCombat = true,
        texture = 132126,

        form = "bear_form",
        handler = function()
            gain(20, "rage" )
            applyBuff( "enrage" )
        end,

    },
    --Roots the target in place for 30 sec.  Damage caused may interrupt the effect.Tree of LifeTree of Life: Instant cast. In the Balance Abilities category.
    entangling_roots = {
        id = 339,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.07, 
        spendType = "mana",

        startsCombat = true,
        texture = 136100,

        --fix:
        
        handler = function()
            applyDebuff( "target", "entangling_roots", 30 )
        end,

    },
    --Decreases the armor of the target by 4% for 5 min.  While affected, the target cannot stealth or turn invisible.  Stacks up to 3 times. Requires Druid.
    faerie_fire = {
        id = 770,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08, 
        spendType = "mana",

        startsCombat = true,
        texture = 136033,

        
        handler = function()
            applyDebuff( "target", "faerie_fire", 300, min( 3, debuff.faerie_fire.stack + 1 ) )
        end,

    },
    --Decreases the armor of the target by 4% for 5 min.  While affected, the target cannot stealth or turn invisible.  Stacks up to 3 times.  Deals 2950 damage and additional threat when used in Bear Form.
    faerie_fire_feral = {
        id = 16857,
        cast = 0,
        cooldown = 6,
        gcd = "totem",

        

        startsCombat = true,
        texture = 136033,

        --fix:
        stance = "Cat Form, Bear Form",
        handler = function()
            applyDebuff( "target", "faerie_fire", 300, min( 3, debuff.faerie_fire.stack + ( 1 + talent.feral_aggression.rank ) ) )
            if glyph.omen_of_clarity.enabled then
                applyBuff("clearcasting")
            end
        end,

    },
    --Reduces damage from falling. In the Feral Abilities category. Requires Druid.  A spell from Classic World of Warcraft.
    feline_grace = {
        id = 20719,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 132914,

        form = "cat_form",
        handler = function()
            --"/cata/spell=20719/feline-grace"
        end,

    },
    --Causes you to charge an enemy, immobilizing them for 4 sec. In the Feral Abilities category. Requires Druid. 
    feral_charge_bear = {
        id = 16979,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        spend = 5, 
        spendType = "rage",

        minRange = 8,
        maxRange = 25,

        startsCombat = true,
        texture = 132183,
        talent = "feral_charge",
        
        buff = "bear_form",
        handler = function()
            if talent.stampede.enabled then
                applyBuff("stampede_bear")
            end
            applyDebuff("target", "feral_charge_effect", 4)
        end,

    },
    --Causes you to leap behind an enemy, dazing them for 3 sec. In the Feral Abilities category. Requires Druid. 
    feral_charge_cat = {
        id = 49376,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        spend = 10, 
        spendType = "energy",

        minRange = function() return leaveweaving_enabled and 0 or 8 end, -- we need to set this to 0 to indicate leaveweaving
        real_minRange = 8, -- we still need the real value for leaveweave calculations
        maxRange = 25,

        startsCombat = true,
        texture = 304501,
        talent = "feral_charge",

        buff = "cat_form",
        handler = function()
            if talent.stampede.enabled then
                applyBuff("stampede_cat")
            end
            applyDebuff("taget", "dazed", 3)
        end,

    },
    --Reduces the chance enemies have to detect you while Prowling. In the Feral Abilities category. Requires Druid. 
    feral_instinct = {
        id = 87335,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 132089,

        --fix:
        
        handler = function()
            --"/cata/spell=87335/feral-instinct"
        end,

    },
    --Finishing move that causes damage per combo pointGlyph of Ferocious Biteand consumes up to 25 additional energy to increase damage by up to 100%, and heals you for 1% of your total maximum health for each 10 energy used and consumes up to 25 additional energy to increase damage by up to 100%.  Damage is increased by your attack power.   1 point  : (214 + 36 * 1 *      1 + 0.125 * Attack power *      1)-(463 + 36 * 1 *      1 + 0.125 * Attack power *      1) damage   2 points: (214 + 36 * 2 *      1 + 0.250 * Attack power *      1)-(463 + 36 * 2 *      1 + 0.250 * Attack power *      1) damage   3 points: (214 + 36 * 3 *      1 + 0.375 * Attack power *      1)-(463 + 36 * 3 *      1 + 0.375 * Attack power *      1) damage   4 points: (214 + 36 * 4 *      1 + 0.500 * Attack power *      1)-(463 + 36 * 4 *      1 + 0.500 * Attack power *      1) damage   5 points: (214 + 36 * 5 *      1 + 0.625 * Attack power *      1)-(463 + 36 * 5 *      1 + 0.625 * Attack power *      1) damage
    ferocious_bite = {
        id = 22568,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function()
            local base_cost = (buff.clearcasting.up and 0) or (25 * ((buff.berserk.up and 0.5) or 1))
            local excess_energy = min(25, energy.current - base_cost) or 0
            return  base_cost + excess_energy end, 
        spendType = "energy",

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost
        cost = function () return max( 25, class.abilities.ferocious_bite.spend ) end,

        startsCombat = true,
        texture = 132127,

        form = "cat_form",
        handler = function()
            removeBuff( "clearcasting" )
            set_last_finisher_cp(combo_points.current)
            spend( combo_points.current, "combo_points" )
            --spend( min( 30, energy.current ), "energy" )
            if debuff.rip.up and talent.blood_in_the_water.rank == 2 and target.health.pct < 20 then applyDebuff( "target", "rip", debuff.rip.duration) end
        end,

    },
    --Shapeshift into flight form, increasing movement speed by 150% and allowing you to fly.  Cannot use in combat. The act of shapeshifting frees the caster of movement slowing effects.
    flight_form = {
        id = 33943,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08, 
        spendType = "mana",

        startsCombat = true,
        texture = 132128,

        --fix:
        
        handler = function()
            --"/cata/spell=33943/flight-form"
        end,

    },
    --Increases maximum health by 30%, increases health to 30% (if below that value), and Glyph of Frenzied Regenerationhealing received is increased by 30%.  Lasts 20 secconverts up to 10 Rage per second into health for 20 sec.  Each point of Rage is converted into 0.30% of max health.
    frenzied_regeneration = {
        id = 22842,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        

        startsCombat = true,
        texture = 132091,
        toggle = "cooldowns",

        form = "bear_form",
        handler = function()
            applyBuff( "frenzied_regeneration" )
        end,

    },
    --When your Treants die or your Wild Mushrooms are triggered, you spawn a Fungal Growth at its wake covering the area within 8 yards, slowing all enemy targets. Lasts 20 sec.
    fungal_growth = {
        id = 81283,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        

        startsCombat = true,
        texture = 134222,

        --fix:
        
        handler = function()
            --"/cata/spell=81283/fungal-growth"
        end,
        copy = {81291}
    },
    --When you autoattack while in Cat Form or Bear Form, you have a chance to cause a Fury Swipe dealing 310% weapon damage. This effect cannot occur more than once every 3 sec.
    fury_swipes = {
        id = 80861,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        

        startsCombat = true,
        texture = 132140,

        --fix:
        stance = "Cat Form, Bear Form",
        handler = function()
            --"/cata/spell=80861/fury-swipes"
        end,

    },
    --Healing increased by 25%. In the Restoration Abilities category. Requires Druid.  
    gift_of_nature = {
        id = 87305,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 136094,
        
        handler = function()
        end,

    },
    --Taunts the target to attack you, but has no effect if the target is already attacking you. In the Feral Abilities category. Requires Druid. 
    growl = {
        id = 6795,
        cast = 0,
        cooldown = function() return 8 - ((set_bonus.tier9feral_2pc == 1 and 2) or 0) end,
        gcd = "off",

        

        startsCombat = true,
        texture = 132270,

        form = "bear_form",
        handler = function()
        end,

    },
    --Heals a friendly target for 7211 to 8516Glyph of Healing Touchand reduces your remaining cooldown on Nature's Swiftness by 10 sec. Requires Druid.
    healing_touch = {
        id = 5185,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend =function() return (buff.clearcasting.up and 0) or 0.3 end,  
        spendType = "mana",

        startsCombat = true,
        texture = 136041,

        --fix:
        
        handler = function()
            removeBuff( "clearcasting" )
        end,

    },
    --Forces the enemy target to sleep for up to 40 sec.  Any damage will awaken the target.  Only one target can be forced to hibernate at a time.  Only works on Beasts and Dragonkin.
    hibernate = {
        id = 2637,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.07, 
        spendType = "mana",

        startsCombat = true,
        texture = 136090,

        --fix:
        
        handler = function()
            applyDebuff( "target", "hibernate", 40)
        end,

    },
    --Creates a violent storm in the target area causing 323 Nature damage to enemies every 1 sec,Glyph of Hurricanereducing movement speed by 50% and increasing the time between attacks of enemies by 20%.  Lasts 10 sec.  Druid must channel to maintain the spell.
    hurricane = {
        id = 16914,
        cast = function() return 10 * haste end,
        channeled = true,
        breakable = true,
        cooldown = 0,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or 0.81 end,
        spendType = "mana",

        startsCombat = true,
        texture = 136018,

        aura = "hurricane",
        tick_time = function () return class.auras.hurricane.tick_time end,
        
        start = function ()
            applyDebuff( "target", "hurricane" )
        end,

        tick = function ()
        end,

        breakchannel = function ()
            removeDebuff( "target", "hurricane" )
        end,

        handler = function ()
            removeBuff( "clearcasting" )
        end,

    },
    --Your Faerie Fire spell also increases the chance the target will be hit by spell attacks by 3%, and increases the critical strike chance of your damage spells by 3% on targets afflicted by Faerie Fire.
    improved_faerie_fire = {
        id = 33602,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 136033,

        --fix:
        
        handler = function()
            --"/cata/spell=91565/faerie-fire"
        end,
        copy = {33601},
    },
    
    --Causes the target to regenerate 5% of maximum mana over 10 sec.  If cast on self, the caster will regenerate an additional (15)% of maximum mana over 10 sec.Glyph of InnervateIf cast on a target other than the caster, the caster will gain 10% of maximum mana over 10 sec
    innervate = {
        id = 29166,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        

        startsCombat = true,
        texture = 136048,

        toggle = "cooldowns",
        handler = function ()
            applyBuff( "innervate" )
        end,

    },
    --The enemy target is swarmed by insects, causing 816 Nature damage over 12 sec. In the Balance Abilities category. Requires Druid. 
    insect_swarm = {
        id = 5570,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or 0.08 end,
        spendType = "mana",

        startsCombat = true,
        texture = 136045,

        --fix:
        
        handler = function()
            applyDebuff( "target", "insect_swarm" )
            removeBuff( "clearcasting" )
        end,

    },
    --Lacerates the enemy target, dealing [3608 + (Attack power * 0.0552)] damage and making them bleed for [5 * (69 + (Attack power * 0.00369))] damage over 15 sec.  Damage increased by attack power.  This effect stacks up to 3 times on the same target.
    lacerate = {
        id = 33745,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or 15 end,
        spendType = "rage",

        startsCombat = true,
        texture = 132131,

        form = "bear_form",
        handler = function()
            removeBuff( "clearcasting" )
            applyDebuff( "target", "lacerate", 15, min( 3, debuff.lacerate.stack + 1 ) )
        end,

    },
    --Heals the target for [2280 * ((1))] over 10 sec.  When Lifebloom expires or is dispelled, the target is instantly healed for [1848 * (1 *  (1) *  1 *  (1) *  1)]. This effect can stack up to 3 times on the same target. Lifebloom can be active only on one target at a time.Tree of LifeTree of Life: Can be cast on unlimited targets.
    lifebloom = {
        id = 33763,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend =function() return (buff.clearcasting.up and 0) or 0.07 end, 
        spendType = "mana",

        startsCombat = true,
        texture = 134206,

        --fix:
        
        handler = function()
            removeBuff( "clearcasting" )
        end,

    },
    --Finishing move that causes damage and stuns the target.  Causes more damage and lasts longer per combo point:   1 point  : (84 * 1 +  74 + 1.55 * Mainhand weapon min damage)-(84 * 1 +  74 + 1.55 * Mainhand weapon max damage) damage, 1 sec   2 points: (84 * 2 +  74 + 1.55 * Mainhand weapon min damage)-(84 * 2 +  74 + 1.55 * Mainhand weapon max damage) damage, 2 sec   3 points: (84 * 3 +  74 + 1.55 * Mainhand weapon min damage)-(84 * 3 +  74 + 1.55 * Mainhand weapon max damage) damage, 3 sec   4 points: (84 * 4 +  74 + 1.55 * Mainhand weapon min damage)-(84 * 4 +  74 + 1.55 * Mainhand weapon max damage) damage, 4 sec   5 points: (84 * 5 +  74 + 1.55 * Mainhand weapon min damage)-(84 * 5 +  74 + 1.55 * Mainhand weapon max damage) damage, 5 sec
    maim = {
        id = 22570,
        cast = 0,
        cooldown = 10,
        gcd = "totem",

        spend = function() return (buff.clearcasting.up and 0) or (35 * ((buff.berserk.up and 0.5) or 1)) end,
        spendType = "energy",

        startsCombat = true,
        texture = 132134,
        toggle = "interrupts",
        readyTime = state.timeToInterrupt,
        debuff = "casting",

        form = "cat_form",
        handler = function()
            
            interrupt()
            applyDebuff( "target", "maim", combo_points.current )
            removeBuff( "clearcasting" )
            set_last_finisher_cp(combo_points.current)
            spend( combo_points.current, "combo_points" )
        end,

    },
    --Mangle the target for 50% normal damage plus 1559 and causes the target to take 30% additional damage from bleed effects for 1 min. Requires Druid.
    mangle_bear = {
        id = 33878,
        cast = 0,
        cooldown = function() return buff.berserk.up and 0 or 6 end,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or 15 end, 
        spendType = "rage",

        startsCombat = true,
        texture = 132135,

        form = "bear_form",
        handler = function()
            removeDebuff( "mangle" )
            applyDebuff( "target", "mangle_bear", 60 )
            removeBuff( "clearcasting" )
        end,

    },
    --Mangle the target for 540% normal damage plus 56 and causes the target to take 30% additional damage from bleed effects for 1 min.  Awards 1 combo point.
    mangle_cat = {
        id = 33876,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function () return (buff.clearcasting.up and 0) or (35 * ((buff.berserk.up and 0.5) or 1)) end, 
        spendType = "energy",

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 35, class.abilities.mangle_cat.spend ) end,

        startsCombat = true,
        texture = 132135,

        form = "cat_form",
        handler = function()
            removeDebuff( "target", "mangle" )
            applyDebuff( "target", "mangle_cat", 60 )
            removeBuff( "clearcasting" )
            gain( 1, "combo_points" )
        end,

    },
    --Increases the friendly target's Strength, Agility, Stamina, and Intellect by 5%, and all magical resistances by (85 / 2 - 0.5), for 1 hour.  If target is in your party or raid, all party and raid members will be affected.
    mark_of_the_wild = {
        id = 1126,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return glyph.mark_of_the_wild.enabled and 0.12 or 0.24 end, 
        spendType = "mana",

        startsCombat = true,
        texture = 136078,

        --fix:
        
        handler = function()
            applyBuff( "mark_of_the_wild" )
            swap_form( "" )
        end,

    },
    --An attack that instantly deals (35 + Attack power * 0.19 - 1) physical damageGlyph of Maul and an additional [(35 + Attack power * 0.19 - 1) * 0.50] damage to a nearby target  Effects which increase Bleed damage also increase Maul damage.
    maul = {
        id = 6807,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        spend = function() return (buff.clearcasting.up and 0) or (30 * ((buff.berserk.up and 0.5) or 1)) end, 
        spendType = "rage",

        startsCombat = true,
        texture = 132136,

        form = "bear_form",
        handler = function()
        end,

    },
    --Allows 50% of your mana regeneration from Spirit to continue while in combat. In the Restoration Abilities category. Requires Druid. 
    meditation = {
        id = 85101,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 136090,

        --fix:
        
        handler = function()
            --"/cata/spell=85101/meditation"
        end,

    },
    --TODO: implement lunar shower, natures_grace, moonglow
    --Burns the enemy for 218 Arcane damage and then an additional (94 * 6) Arcane damage over 12 sec. In the Balance Abilities category. Requires Druid.
    moonfire = {
        id = 8921,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0 or 0.09) end, 
        spendType = "mana",

        startsCombat = true,
        texture = 136096,

        --fix:
        
        handler = function()
            removeBuff( "clearcasting" )
            applyDebuff( "target", "moonfire" )
        end,

    },
     --Shapeshift into Moonkin Form, increasing Arcane and Nature spell damage by 10%, reducing all damage taken by 15%, and increases spell haste of all party and raid members by 5%. The Moonkin can not cast healing or resurrection spells while shapeshifted.The act of shapeshifting frees the caster of movement impairing effects.
    moonkin_form = {
        id = 24858,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        spend = 0.13, 
        spendType = "mana",
        talent = "moonkin_form",
        startsCombat = true,
        texture = 136036,
        --fix:
        handler = function()
            swap_form( "moonkin_form" )
        end,
    },
    


    --Reduces the pushback suffered from damaging attacks while casting Healing Touch, Regrowth, Tranquility, Rebirth, Cyclone, Entangling Roots, and Nourish.
    natures_focus = {
        id = 84736,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 136100,

        --fix:
        
        handler = function()
            --"/cata/spell=100855/tranquility"
        end,

    },
    --While active, any time an enemy strikes the caster they have a 100% chance to become afflicted by Entangling Roots. 3 charges.  Lasts 45 sec.
    natures_grasp = {
        id = 16689,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        

        startsCombat = true,
        texture = 136063,
        toggle = "cooldowns",
        --fix:
        handler = function()
            applyBuff( "natures_grasp" )
        end,

    },
        --When activated, your next Nature spell with a base casting time less than 10 sec. becomes an instant cast spell.  If that spell is a healing spell, the amount healed will be increased by 50%.
    natures_swiftness = {
        id = 17116,
        cast = 0,
        cooldown = 3,
        gcd = "off",
    
        talent = "natures_swiftness",
    
        startsCombat = true,
        texture = 136076,
        toggle = "cooldowns",
    
        handler = function()
            applyBuff( "natures_swiftness" )
        end,
    
    },
    --Heals a friendly target for 2403 to 2792. Heals for an additional 20% if you have a Rejuvenation, Regrowth, Lifebloom, or Wild Growth effect active on the target.
    nourish = {
        id = 50464,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or  0.1 end, 
        spendType = "mana",

        startsCombat = true,
        texture = 236162,

        --fix:
        
        handler = function()
            removeBuff( "clearcasting" )
        end,

    },
    --Pounce, stunning the target for 3 sec and causing 2346 Bleed damage over 18 sec.  Must be prowling.  Awards 1 combo point. In the Feral Abilities category.
    pounce = {
        id = 9005,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return (buff.clearcasting.up and 0) or (50 * ((buff.berserk.up and 0.5) or 1)) end,
        spendType = "energy",

        startsCombat = true,
        texture = 132142,

        form = "cat_form",
        handler = function()
            removeBuff( "clearcasting" )
            applyDebuff( "target", "pounce", 3)
            applyDebuff( "target", "pounce_bleed", 18 )
            gain( 1, "combo_points" )
        end,

    },
    --Gives you a 100% chance to gain an additional 5 Rage anytime you get a critical strike while in Bear Form. In the Feral Abilities category. Requires Druid.
    primal_fury = {
        id = 16961,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 132278,

        form = "bear_form",
        handler = function()
        end,

    },
    --Tiger's Fury and Beserk also increases your maximum Energy by 10/20 during its duration, and your Enrage and Beserk abilities instantly generates 60/120 Rage.
    primal_madness = {
        id = 80886,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "primal_madness",

        startsCombat = true,
        texture = 132242,

        --fix:
        
        handler = function()
            --"/cata/spell=80886/primal-madness"
        end,
        copy = {17080, 80879}
    },
    --Allows the Druid to prowl around, but reduces your movement speed by 30%.  Lasts until cancelled. In the Feral Abilities category.  
    prowl = {
        id = 5215,
        cast = 0,
        cooldown = 10,
        gcd = "off",

        

        startsCombat = true,
        texture = 514640,

        form = "cat_form",
        handler = function()
            applyBuff( "prowl" )
        end,
    },
    --In the Feral Abilities category. Requires Druid.   
    pulverize = {
        id = 80313,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "pulverize",
        spend = function () return (buff.clearcasting.up and 0) or 15 end,
        spendType = "rage",

        startsCombat = true,
        texture = 132318,

        form = "bear_form",
        handler = function()
            if debuff.lacerate.up then
                applyBuff("pulverize", 10, min( 3, debuff.lacerate.stack ) )
                removeDebuff("target","lacerate")
            end
            removeBuff( "clearcasting" )
        end,

    },
    --Rake the target for (Attack power * 0.147 +  56) Bleed damage and an additional Endless Carnage(56 * 5 + Attack power * 0.735)(56 * 4 + Attack power * 0.588)(56 * 3 + Attack power * 0.441) Bleed damage over 9 sec.  Awards 1 combo point.
    rake = {
        id = 1822,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function () return (buff.clearcasting.up and 0) or (35 * ((buff.berserk.up and 0.5) or 1)) end, 
        spendType = "energy",

        startsCombat = true,
        texture = 132122,
        damage = function ()
            local damage_multiplier = (debuff.mangle.up and 1.3 or 1)
            return calculate_damage( 56, 0.147, false, true, false, damage_multiplier )
        end,
        tick_damage = function () -- TODO: Rake can be snapshotted with Tiger's Fury and should continue to apply the increased damage even after Tiger's Fury expires.
            local damage_multiplier = (debuff.mangle.up and 1.3 or 1) * (set_bonus.tier11feral_2pc == 1 and 1.1 or 1)
            return calculate_damage( 56, 0.147, false, true, false, damage_multiplier )
        end,

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 35, class.abilities.rake.spend ) end,

        
        readyTime = function() return max( 0, debuff.rake.remains - debuff.rake.tick_time ) end,

        form = "cat_form",
        handler = function()
            applyDebuff( "target", "rake" )
            removeBuff( "clearcasting" )
            gain( 1, "combo_points" )
        end,

    },
    --Ravage the target, causing 625% damage plus 50 to the target.  Must be prowling and behind the target.  Awards 1 combo point. In the Feral Abilities category.
    ravage = {
        id = 6785,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return (buff.clearcasting.up and 0) or (60 * (1 - ((buff.stampede_cat.up and 0.5*talent.stampede.rank) or 0) ) * ((buff.berserk.up and 0.5) or 1)) end, 
        spendType = "energy",

        startsCombat = true,
        texture = 132141,

        usable = function() return buff.stampede_cat.up or buff.prowl.up, "must have stampede_cat-buff or be prowling behind target" end,

        form = "cat_form",
        handler = function()
            if not (buff.stampede_cat.up and talent.stampede.rank==2) then
                removeBuff( "clearcasting" )
            end
            removeBuff( "stampede_cat")
            gain( 1, "combo_points" )
        end,
        copy = {81170}

    },
    --TODO:current:
    --Returns the spirit to the body, restoring a dead target to life with 20% health and 20% mana. In the Restoration Abilities category. Requires Druid.
    rebirth = {
        id = 20484,
        cast = 2,
        cooldown = 600,
        gcd = "spell",

        

        startsCombat = true,
        texture = 136080,

        
        
        handler = function()
            --"/cata/spell=20484/rebirth"
        end,

    },
    --Heals a friendly target for 3579.5 and another [1083 * ((1))] over 6 sec.Glyph of RegrowthRegrowth's duration automatically refreshes to 6 sec each time it heals targets at or below 50% healthTree of LifeTree of Life: Instant cast.
    regrowth = {
        id = 8936,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or 0.35 end, 
        spendType = "mana",

        startsCombat = true,
        texture = 136085,

        --fix:
        
        handler = function()
            removeBuff( "clearcasting" )
        end,

    },
    --Heals the target for 1307 every 3 sec for 12 sec. In the Restoration Abilities category. Requires Druid. 
    rejuvenation = {
        id = 774,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or 0.2 end, 
        spendType = "mana",

        startsCombat = true,
        texture = 136081,

        --fix:
        
        handler = function()
            removeBuff( "clearcasting" )
        end,

    },
    --Nullifies corrupting effects on the friendly target, Nature's Cureremoving 0 Magic, 1 Curse, and 1 Poison effectremoving 1 Curse and 1 Poison effect.
    remove_corruption = {
        id = 2782,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.17, 
        spendType = "mana",

        startsCombat = true,
        texture = 135952,

        handler = function()
            --"/cata/spell=2782/remove-corruption"
        end,

    },
    --Brings all dead party and raid members back to life with 35% health and 35% mana. Cannot be cast in combat or while in a battleground or arena.
    revitalize = {
        id = 450759,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 1.0, 
        spendType = "mana",

        startsCombat = true,
        texture = 132125,
      
        handler = function()
            --"/cata/spell=450759/revitalize"
        end,

    },
    --Returns the spirit to the body, restoring a dead target to life with 35% of maximum health and mana.  Cannot be cast when in combat. Requires Druid.
    revive = {
        id = 50769,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.72, 
        spendType = "mana",

        startsCombat = true,
        texture = 132132,

        handler = function()
            --"/cata/spell=50769/revive"
        end,

    },
    --Finishing move that causes Bleed damage over time.  Damage increases per combo point and by your attack power:   1 point: [(57 + 4 * 1 + 0.0207 * Attack power) * 8] damage over 16 sec.   2 points: [(57 + 4 * 2 + 0.0414 * Attack power) * 8] damage over 16 sec.   3 points: [(57 + 4 * 3 + 0.0621 * Attack power) * 8] damage over 16 sec.   4 points: [(57 + 4 * 4 + 0.0828 * Attack power) * 8] damage over 16 sec.   5 points: [(57 + 4 * 5 + 0.1035 * Attack power) * 8] damage over 16 sec.Glyph of BloodlettingEach time you Shred or Mangle the target while in Cat Form the duration of your Rip on that target is extended by 2 sec, up to a maximum of 6 sec
    rip = {
        id = 1079,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function ()
            if buff.clearcasting.up then
                return 0
            end
            return ((30 - ((set_bonus.tier10feral_2pc == 1 and 10) or 0)) * ((buff.berserk.up and 0.5) or 1))
        end,
        spendType = "energy",

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost
        cost = function () return max( 30, class.abilities.rip.spend ) end,

        startsCombat = true,
        texture = 132152,

        usable = function() return combo_points.current > 0, "requires combo_points" end,
        readyTime = function() return max( 0, debuff.rip.remains - debuff.rip.tick_time ) end, -- ((not rip_tf_snapshot or buff.tigers_fury.up ) and debuff.rip.tick_time or 0) end, -- Disable last tick refresh for now until we know if new rip is stronger
        handler = function ()
            applyDebuff( "target", "rip" )
            removeBuff( "clearcasting" )
            set_last_finisher_cp(combo_points.current)
            spend( combo_points.current, "combo_points" )
            rip_tracker[target.unit].extension = 0
            rip_tracker[target.unit].tf_snapshot = buff.tigers_fury.up 
        end,

    },
    --Each time you deal a non-periodic critical strike while in Bear Form, you have a 50% chance to gain Savage Defense, absorbing physical damage equal to 35% of your attack power for 10 sec.
    savage_defense = {
        id = 62600,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 132278,

        form = "bear_form",
        handler = function()
            applyBuff("savage_defense")
        end,

    },
    --Finishing move that consumes combo points on any nearby target to increase autoattack damage done by 80%.  Only useable while in Cat Form.  Lasts longer per combo point:   1 point  : 14 seconds   2 points: 19 seconds   3 points: 24 seconds   4 points: 29 seconds   5 points: 34 seconds
    savage_roar = {
        id = 52610,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return 25 * ((buff.berserk.up and 0.5) or 1) end, 
        spendType = "energy",

        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 25, class.abilities.savage_roar.spend ) end,

        startsCombat = false,
        texture = 236167,

        usable = function() return combo_points.current > 0, "requires combo_points" end,
        handler = function ()
            applyBuff( "savage_roar" )
            set_last_finisher_cp(combo_points.current)
            spend( combo_points.current, "combo_points" )
        end,

    },
    --Reduces the mana cost of all shapeshifting by 60%. In the Feral Abilities category. Requires Druid. 
    shapeshifter = {
        id = 87793,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 236161,

        
        handler = function()
        end,

    },
    --Shred the target, causing 540% damage plus 56 to the target.  Must be behind the target.  Awards 1 combo point.  Effects which increase Bleed damage also increase Shred damage.
    shred = {
        id = 5221,
        cast = 0,
        cooldown = 0,
        gcd = "totem",
        school = "physical",

        spend = function () return (buff.clearcasting.up and 0) or (40 * ((buff.berserk.up and 0.5) or 1)) end, 
        spendType = "energy",

        startsCombat = true,
        texture = 136231,

        form = "cat_form",
        damage = function ()
            local damage_multiplier = (debuff.mangle.up and 1.3 or 1) * rend_and_tear_mod_shred
            return calculate_damage( 56 , 5.40, true, false, true, damage_multiplier)
        end,
    
        -- This will override action.X.cost to avoid a non-zero return value, as APL compares damage/cost with Shred.
        cost = function () return max( 40, class.abilities.shred.spend ) end,

        handler = function ()
            if rip_canextend then
                rip_tracker[target.unit].extension = rip_tracker[target.unit].extension + 2
                applyDebuff( "target", "rip", debuff.rip.remains + 2)
            end
            gain( 1, "combo_points" )
            removeBuff( "clearcasting" )
        end,

    },
    --You charge and skull bash the target, interrupting spellcasting and preventing any spell in that school from being cast for 4 sec. Requires Druid.
    skull_bash_cat = {
        id = 80965,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 25, 
        spendType = "energy",

        startsCombat = true,
        texture = 236946,
        toggle = "interrupts",
        readyTime = state.timeToInterrupt,
        debuff = "casting",

        form = "cat_form",
        handler = function()
            interrupt()
        end,

    },
    --You charge and skull bash the target, interrupting spellcasting and preventing any spell in that school from being cast for 4 sec. Requires Druid.
    skull_bash_bear = {
        id = 80964,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 15, 
        spendType = "rage",

        startsCombat = true,
        texture = 133732,
        toggle = "interrupts",
        readyTime = state.timeToInterrupt,
        debuff = "casting",

        form = "bear_form",
        handler = function()
            interrupt()
        end,

    },
    --Soothes the target, dispelling all enrage effects. In the Balance Abilities category. Requires Druid. 
    soothe = {
        id = 2908,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06, 
        spendType = "mana",

        startsCombat = true,
        texture = 132163,

        handler = function()
            removeDebuff( "target", "dispellable_enrage" )
        end,

    },
    --TODO: make aura instead
    --Increases your melee haste by 30% after you use Feral Charge (Bear) for 8 sec, and your next Ravage will temporarily not require stealth or have a positioning requirement for 10 sec after you use Feral Charge (Cat), and cost 100% less energy.
    stampede = {
        id = 81017,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "stampede",

        startsCombat = true,
        texture = 304501,

        --fix:
        
        handler = function()
            --"/cata/spell=5221/shred"
        end,
        copy= {81016, 81021, 81022}
    },
    --The Druid roars, increasing the movement speed of all friendly players within 10 yards by 60% for 8 sec. Does not break prowling. 
    stampeding_roar_cat = {
        id = 77764,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 30, 
        spendType = "energy",

        startsCombat = true,
        texture = 464343,

        --fix:
        
        handler = function()
            applyBuff("stampeding_roar")
        end,

    },
    --The Druid roars, increasing the movement speed of all friendly players within 10 yards by 60% for 8 sec. In the Feral Abilities category. 
    stampeding_roar_bear = {
        id = 77761,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 15, 
        spendType = "rage",

        startsCombat = true,
        texture = 463283,

        --fix:
        
        handler = function()
            applyBuff("stampeding_roar")
        end,

    },
    --You summon a flurry of stars from the sky on all targets within 40 yards of the caster that you're in combat with, each dealing 398.5 Arcane damage. Maximum 20 stars. Lasts 10 sec.  Shapeshifting into an animal form or mounting cancels the effect. Any effect which causes you to lose control of your character will suppress the starfall effect.
    starfall = {
        id = 48505,
        cast = 0,
        cooldown = function() return glyph.starfall.enabled and 60 or 90 end,
        gcd = "spell",
        spend =function() return (buff.clearcasting.up and 0 or 0.35) * (1 - talent.moonglow.rank * 0.03) end,
        spendType = "mana",
        talent = "starfall",
        startsCombat = true,
        texture = 236168,
        toggle = "cooldowns",
        handler = function ()
            removeBuff( "clearcasting" )
        end,
    },
        --Causes 1364.5 Arcane damage to the targetGlyph of Starfireand increases the duration of your Moonfire effect on the target by 3 sec, up to a maximum of 9 additional seconds.StarsurgeGenerates 20 Solar Energy
    starfire = {
        id = 2912,
        cast = function() return (3.5 * haste) - (talent.starlight_wrath.rank * 0.1) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0 or 0.11) * (1 - talent.moonglow.rank * 0.03) end, 
        spendType = "mana",

        startsCombat = true,
        texture = 135753,

        handler = function()
            removeBuff( "clearcasting" )
            if glyph.starfire.enabled and debuff.moonfire.up then
                debuff.moonfire.expires = debuff.moonfire.expires + 3
                -- TODO: Cap at 3 applications.
            end
        end,

    },
    --You fuse the power of the moon and sun, launching a devastating blast of energy at the target. Causes 1211.5 Spellstorm damage to the target and generates 15 Lunar or Solar energy, whichever is more beneficial to you.
    starsurge = {
        id = 78674,
        cast = 0, --TODO: check if this is really instant
        cooldown = 15,
        gcd = "spell",
        spend = function() return (buff.clearcasting.up and 0 or 0.11) * (1 - talent.moonglow.rank * 0.03) end, 
        spendType = "mana",
        startsCombat = true,
        texture = 135730,
        --fix:
        stance = "None",
        handler = function()
            --TODO: generates 15 Lunar or Solar energy
        end,
    },
    --Reduces all damage taken by 50% for 12 sec.  Only usable while in Bear Form or Cat Form. In the Druid Talents category. 
    survival_instincts = {
        id = 61336,
        cast = 0,
        cooldown = 180,
        gcd = "off",
        talent = "survival_instincts",
        startsCombat = true,
        texture = 236169,
        toggle = "cooldowns",
        handler = function()
            applyBuff( "survival_instincts" )
        end,
    },
    --TODO: Add genesis, add lunar_shower
    --Burns the enemy for 218 Nature damage and then an additional (94 * 6) Nature damage over 12 sec. In the Balance Abilities category. Requires Druid.
    sunfire = {
        id = 93402,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0 or 0.09) * (1 - talent.moonglow.rank * 0.03) end, 
        spendType = "mana",

        startsCombat = true,
        texture = 236216,
        talent = "sunfire",
    
        handler = function()
            --"/cata/spell=93402/sunfire"
        end,

    },
    --Swift Flight Form, available in Phase 2 of Burning Crusade Classic, grants Druids a 280% speed boost. Shapeshift into swift flight form, increasing movement speed by 280% and allowing you to fly.  Cannot use in combat.The act of shapeshifting frees the caster of movement slowing effects.
    swift_flight_form = {
        id = 40120,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08, 
        spendType = "mana",

        startsCombat = true,
        texture = 132128,

        --fix:
        
        handler = function()
            swap_form("swift_flight_form")
        end,

    },
    --Glyph of SwiftmendInstantly heals a friendly target that has an active Rejuvenation or Regrowth effect for 5229Consumes a Rejuvenation or Regrowth effect on a friendly target to instantly heal the target for 5229.
    swiftmend = {
        id = 18562,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        spend = function() return (buff.clearcasting.up and 0) or 0.1 end, 
        spendType = "mana",
        talent = "swiftmend",
        startsCombat = true,
        texture = 134914,
        handler = function()
            removeBuff( "clearcasting" )
            if glyph.swiftmend.enabled then return end
            if buff.rejuvenation.up then removeBuff( "rejuvenation" )
            elseif buff.regrowth.up then removeBuff( "regrowth" ) end
        end,
    },
    --Swipe nearby enemies, inflicting 929 damage.  Damage increased by attack power. In the Feral Abilities category. Requires Druid. 
    swipe_bear = {
        id = 779,
        cast = 0,
        cooldown = 3,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or 15 end, 
        spendType = "rage",

        startsCombat = true,
        texture = 134296,

        form = "bear_form",
        handler = function()
            removeBuff( "clearcasting" )
        end,

    },
    --Swipe nearby enemies, inflicting 526% weapon damage. In the Feral Abilities category. Requires Druid. 
    swipe_cat = {
        id = 62078,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function () return (buff.clearcasting.up and 0) or (45 * ((buff.berserk.up and 0.5) or 1)) end, 
        spendType = "energy",

        startsCombat = true,
        texture = 134296,

        form = "cat_form",
        handler = function()
            removeBuff( "clearcasting" )
        end,

    },
    --Teleports the caster to the Moonglade. In the Balance Abilities category. Requires Druid.  
    teleport_moonglade = {
        id = 18960,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 120, 
        spendType = "mana",

        startsCombat = true,
        texture = 135758,

        handler = function()
            --"/cata/spell=18960/teleport-moonglade"
        end,

    },
    --Thorns sprout from the friendly target causing Mangle[179 + (Attack power * .168)][(179 + (Spell power * .168)) *  1] Nature damage to attackers when hit.  VengeanceAttack power gained from Vengeance will not increase Thorns damageLasts 20 sec.
    thorns = {
        id = 467,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or 0.36 end, 
        spendType = "mana",

        startsCombat = true,
        texture = 136104,

        handler = function()
            removeBuff( "clearcasting" )
            applyBuff( "thorns" )
        end,

    },
    --Deals (Attack power * 0.0982 +  933) to (Attack power * 0.0982 +  1151) damage, and causes all targets within 8 yards to bleed for [(Attack power * 0.0167 +  581) * 3] damage over 6 sec.
    thrash = {
        id = 77758,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or 25 end, 
        spendType = "rage",

        startsCombat = true,
        texture = 451161,

        form = "bear_form",
        handler = function()
            removeBuff( "clearcasting" )
            applyDebuff("thresh")
        end,

    },
    --Increases physical damage done by 15% for 6 sec. In the Feral Abilities category. Requires Druid.  
    tigers_fury = {
        id = 5217,
        cast = 0,
        cooldown = function() return 30 - ((set_bonus.tier7feral_4pc == 1 and 3) or 0) end,
        gcd = "off",

        

        startsCombat = true,
        texture = 132242,
        
        usable = function() return not buff.berserk.up end,

        form = "cat_form",
        handler = function()
            applyBuff("tigers_fury")
            if talent.primal_madness.enabled then -- we dont need to check on primal_madness.up since TF cant be casted during active berserk
                applyBuff("primal_madness", aura.tigers_fury.duration)
                energy.max = energy.max + 10 * talent.primal_madness.rank
                gain(10 * talent.primal_madness.rank, "energy")
                buff.primal_madness.expires = buff.tigers_fury.expires
                state:QueueAuraExpiration( "primal_madness", ExpirePrimalMadness, buff.primal_madness.expires) 
            end
            gain( 20 * talent.king_of_the_jungle.rank, "energy" )
        end,

    },
    --Shows the location of all nearby humanoids on the minimap.  Only one type of thing can be tracked at a time. In the Feral Abilities category.
    track_humanoids = {
        id = 5225,
        cast = 0,
        cooldown = 1.5,
        gcd = "off",

        

        startsCombat = true,
        texture = 132328,

        form = "cat_form",
        handler = function()
            applyBuff("track_humanoids")
        end,

    },
    --Heals 5 nearby lowest health party or raid targets within 40 yards with Tranquility every 2 sec for 8 sec. Tranquility heals for 3882 plus an additional 343 every 2 sec over 8 sec. Stacks up to 3 times. The Druid must channel to maintain the spell.
    tranquility = {
        id = 740,
        cast = function() return 8 * haste end,
        channeled = true,
        breakable = true,
        cooldown = 480,
        gcd = "spell",

        spend = function() return (buff.clearcasting.up and 0) or 0.32 end, 
        spendType = "mana",

        startsCombat = true,
        texture = 136107,

        toggle = "cooldowns",
        
        handler = function()
            removeBuff( "clearcasting" )
        end,
        copy = {44203}
    },
    --See also: Archdruid's Lunarwing Form. Shapeshift into travel form, increasing movement speed by 40%.  Also protects the caster from Polymorph effects.  Only useable outdoors.The act of shapeshifting frees the caster of movement slowing effects.
    travel_form = {
        id = 783,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08, 
        spendType = "mana",

        startsCombat = true,
        texture = 132144,

        handler = function()
            swap_form( "travel_form" )
        end,
    },
        --You summon a violent Typhoon that does 1298 Nature damage to targets in front of the caster within 30 yards, knocking them back and dazing them for 6 sec.
    typhoon = {
        id = 50516,
        cast = 0,
        cooldown = function() return glyph.monsoon.enabled and 17 or 20 end,
        gcd = "spell",
        spend = function() return (buff.clearcasting.up and 0) or (0.16 * ( glyph.typhoon.enabled and 0.92 or 1 )) end, 
        spendType = "mana",
        talent = "typhoon",
        startsCombat = true,
        texture = 236170,
        handler = function()
            removeBuff( "clearcasting" )
        end,
    },
    --TODO: dafuq is this
    --Each time you take damage while in Bear Form, you gain 5% of the damage taken as attack power, up to a maximum of 10% of your health.  Entering Cat Form will cancel this effect.
    vengeance = {
        id = 84840,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        

        startsCombat = true,
        texture = 236265,

        form = "bear_form",
        handler = function()
            applyBuff("vengeance")
        end,

    },
    --Grow a magical Mushroom with 5 Health at the target location. After 6 sec, the Mushroom will become invisible. When detonated by the Druid, all Mushrooms will explode dealing 934 Nature damage to all nearby enemies within 6 yards. Only 3 Mushrooms can be placed at one time. Use Wild Mushroom: Detonate to detonate all Mushrooms.
    wild_mushroom = {
        id = 88747,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = function() return (buff.clearcasting.up and 0) or 0.11 end, 
        spendType = "mana",

        startsCombat = true,
        texture = 464341,

        --fix:
        
        handler = function()
            applyBuff("wild_mushroom")
        end,
        copy = {78777}
    },
    --Detonates all of your Wild Mushrooms, dealing 934 Nature damage to all nearby targets within 6 yards. In the Balance Abilities category. Requires Druid.
    wild_mushroom_detonate = {
        id = 88751,
        cast = 0,
        cooldown = 10,
        gcd = "off",

        
        usable = function() return buff.wild_mushroom.up end,
        startsCombat = true,
        texture = 464342,

        handler = function()
            removeBuff("wild_mushroom")
        end,

    },
    --Causes 884 Nature damage to the target. StarsurgeGenerates 13 Lunar EnergyTree of LifeTree of Life: Cast time reduced by 50%, damage increased by 30%.
    wrath = {
        id = 5176,
        cast = function() return ( 2.5* haste ) - ( talent.starlight_wrath.rank * 0.1 ) end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return ( buff.clearcasting.up and 0 or 0.09 ) * ( 1 - talent.moonglow.rank * 0.03 ) end,
        spendType = "mana",

        startsCombat = true,
        texture = 535045,

        handler = function()
            removeBuff( "clearcasting" )
        end,

    },
} )


-- Settings
spec:RegisterSetting( "druid_description", nil, {
    type = "description",
    name = "Adjust the settings below according to your playstyle preference.  It is always recommended that you use a simulator "..
        "to determine the optimal values for these settings for your specific character.\n\n"
} )

spec:RegisterSetting( "druid_feral_header", nil, {
    type = "header",
    name = "Feral: General"
} )

spec:RegisterSetting( "druid_feral_description", nil, {
    type = "description",
    name = strformat( "These settings will change the %s behavior when using the default |cFF00B4FFFeral|r priority.\n\n", Hekili:GetSpellLinkWithTexture( spec.abilities.cat_form.id ) )
} )


spec:RegisterSetting( "min_roar_offset", 29, {
    type = "range",
    name = strformat( "Minimum %s before %s", Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.savage_roar.id ) ),
    desc = strformat( "Sets the minimum number of seconds over the current %s duration required for %s recommendations.\n\n"..
        --"Recommendation:\n - 34 with T8-4PC\n - 24 without T8-4PC\n\n"..
        "Default: 29", Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.savage_roar.id ) ),
    width = "full",
    min = 0,
    softMax = 42,
    step = 1,
} )

spec:RegisterSetting( "rip_leeway", 1, {
    type = "range",
    name = strformat( "%s Leeway", Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ) ),
    desc = "Sets the leeway allowed when deciding whether to recommend clipping Savage Roar.\n\nThere are cases where Rip falls "..
        "very shortly before Roar and, due to default priorities and player reaction time, Roar falls off before the player is able "..
        "to utilize their combo points. This leads to Roar being cast instead and having to rebuild 5CP for Rip."..
        "This setting helps address that by widening the rip/roar clipping window.\n\n"..
        "Recommendation: 1\n\n"..
        "Default: 1",
    width = "full",
    min = 1,
    softMax = 10,
    step = 0.1,
} )

--spec:RegisterSetting( "max_ff_delay", 0.1, {
--    type = "range",
--    name = strformat( "Maximum %s Delay", Hekili:GetSpellLinkWithTexture( spec.abilities.faerie_fire_feral.id ) ),
--    desc = strformat( "Specify the maximum wait time for %s cooldown in seconds.\n\n"..
--        "Recommendation:\n - 0.07 in P2 BiS\n - 0.10 in P3 BiS\n\n"..
--        "Default: 0.1", Hekili:GetSpellLinkWithTexture( spec.abilities.faerie_fire_feral.id ) ),
--    width = "full",
--    min = 0,
--    softMax = 1,
--    step = 0.01,
-- })

--spec:RegisterSetting( "max_ff_energy", 15, {
--    type = "range",
--    name = strformat( "Maximum Energy for %s During %s", Hekili:GetSpellLinkWithTexture( spec.abilities.faerie_fire_feral.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.berserk.id ) ),
--    desc = strformat( "Specify the maximum Energy threshold for %s during %s.\n\n"..
--        "Recommendation: 15\n\n"..
--        "Default: 15", Hekili:GetSpellLinkWithTexture( spec.abilities.faerie_fire_feral.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.berserk.id ) ),
--    width = "full",
--    min = 0,
--    softMax = 100,
--    step = 1,
--} )

spec:RegisterSetting( "maintain_ff", true, {
    type = "toggle",
    name = "Maintain Faerie Fire",
    desc = "If checked, Keep up Sunder debuff if not provided externally.\n\n"..
        "Default: Checked",
    width = "full",
} )

spec:RegisterSetting( "maintain_roar", true, {
    type = "toggle",
    name = "Maintain Demoralizing Roar",
    desc = "If checked, Keep up AP debuff if not provided externally.\n\n"..
        "Default: Checked",
    width = "full",
} )
spec:RegisterSetting( "rake_dpe_check", true, {
    type = "toggle",
    name = "Compare Rake DPE with Shred",
    desc = "If checked, skip rake if shred has better DPE.\n\n"..
        "Default: Checked",
    width = "full",
} )

spec:RegisterSetting( "cancel_primal_madness", false, {
    type = "toggle",
    name = "Cancel Primal Madness",
    desc = "If checked, will recommend to cancel primal madness when on low energy.\n\n"..
        "Default: Unchecked",
    width = "full",
} )

spec:RegisterSetting( "optimize_trinkets", false, {
    type = "toggle",
    name = "Optimize Trinkets",
    desc = "If checked, Energy will be pooled for anticipated trinket procs.\n\n"..
        "Default: Unchecked",
    width = "full",
} )

spec:RegisterSetting( "druid_bite_header", nil, {
    type = "header",
    name = strformat( "Feral: %s", Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ) )
} )

-- TODO: This could probably just enable/disable the Ferocious Bite ability directly instead of being a unique setting.
spec:RegisterSetting( "ferociousbite_enabled", true, {
    type = "toggle",
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ) ),
    desc = strformat( "If unchecked, %s will not be recommended.", Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ) ),
    width = "full",
} )

spec:RegisterSetting( "min_bite_sr_remains", 11, {
    type = "range",
    name = strformat( "Minimum %s before %s", Hekili:GetSpellLinkWithTexture( spec.abilities.savage_roar.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ) ),
    desc = strformat( "If set above zero, %s will not be recommended unless %s has this much time remaining.\n\n" ..
        --"Recommendation: 4-8, depending on character gear level\n\n" ..
        "Default: 11", Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.savage_roar.id ) ),
    width = "full",
    min = 0,
    softMax = 14,
    step = 1
} )

spec:RegisterSetting( "min_bite_rip_remains", 11, {
    type = "range",
    name = strformat( "Minimum %s before %s", Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ) ),
    desc = strformat( "If set above zero, %s will not be recommended unless %s has this much time remaining.\n\n" ..
        --"Recommendation: 4-8, depending on character gear level\n\n" ..
        "Default: 11", Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ) ),
    width = "full",
    min = 0,
    softMax = 14,
    step = 1,
} )

--spec:RegisterSetting( "max_bite_energy", 25, {
--    type = "range",
--    name = strformat( "Maximum Energy for %s during %s", Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.berserk.id ) ),
--    desc = strformat( "Specify the maximum Energy consumed by %s during %s. "..
--        "When %s is not active, any amount of Energy is allowed if the above %s and %s requirements are met.\n\n"..
--        "Recommendation: 25\n\n"..
--        "Default: 25", Hekili:GetSpellLinkWithTexture( spec.abilities.ferocious_bite.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.berserk.id ), spec.abilities.berserk.name, spec.abilities.savage_roar.name, Hekili:GetSpellLinkWithTexture( spec.abilities.rip.id ) ),
--    width = "full",
--    min = 18,
--    softMax = 65,
--    step = 1
--} )

spec:RegisterSetting( "bear_form_mode", "tank", {
    type = "select",
    name = strformat( "%s Mode", Hekili:GetSpellLinkWithTexture( spec.abilities.bear_form.id ) ),
    --TODO: desc = strformat( "When %s is active and Bearweaving is disabled, specify whether to use %s abilities or to return to %s.\n\n" ..
    --    "Default: Tank", Hekili:GetSpellLinkWithTexture( spec.abilities.bear_form.id ), spec.abilities.bear_form.name, spec.abilities.bear_form.name, Hekili:GetSpellLinkWithTexture( spec.abilities.cat_form.id ) ),
    width = "full",
    values = {
        none = strformat( "Swap (%s)", Hekili:GetSpellLinkWithTexture( spec.abilities.cat_form.id ) ),
        tank = strformat( "Tank (%s)", Hekili:GetSpellLinkWithTexture( spec.abilities.bear_form.id ) )
    },
    sorting = { "tank", "none" }
} )

spec:RegisterSetting( "druid_leaveweaving_header", nil, {
    type = "header",
    name = "Feral: Leaveweaving [Experimental]"
} )

spec:RegisterSetting( "druid_leaveweaving_description", nil, {
    type = "description",
    name = "Leaveweaving Feral settings will change the parameters used when recommending Feral-Charge abilities.\n\n"
} )

spec:RegisterSetting( "leaveweaving_enabled", true, {
    type = "toggle",
    name = "Use Leaveweaving",
    desc = "If checked, Feral-Charge(Cat) may be recommended even in melee. (Run out to charge).",
    width = "full",
} )

spec:RegisterSetting( "druid_bearweaving_header", nil, {
    type = "header",
    name = "Feral: Bearweaving [Experimental]"
} )

spec:RegisterSetting( "druid_bearweaving_description", nil, {
    type = "description",
    name = "Bearweaving Feral settings will change the parameters used when recommending bearshifting abilities.\n\n"
} )

spec:RegisterSetting( "bearweaving_enabled", false, {
    type = "toggle",
    name = "Use Bearweaving",
    desc = "If checked, Bearweaving abilities may be recommended.",
    width = "full",
} )

spec:RegisterSetting( "bearweaving_instancetype", "raid", {
    type = "select",
    name = "Bearweaving: Instance Type",
    desc = strformat( "Specify the type of instance that is required before %s and %s may be recommended.\n\n" ..
        "- Any\n" ..
        "- Party / Dungeon (5+ members)\n" ..
        "- Raid (10 / 25)", Hekili:GetSpellLinkWithTexture( spec.abilities.mangle_bear.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.thrash.id ) ),
    width = "full",
    values = {
        any = "Any",
        dungeon = "Party / Dungeon",
        raid = "Raid"
    },
} )

spec:RegisterSetting( "bearweaving_bossonly", true, {
    type = "toggle",
    name = "Bearweaving: Boss Only",
    desc = "If checked, bearweaving abilities are reserved for boss encounters only.",
    width = "full",
} )

spec:RegisterSetting("druid_balance_header", nil, {
    type = "header",
    name = "Balance: General"
})

spec:RegisterSetting("druid_balance_description", nil, {
    type = "description",
    name = "General Balance settings will change the parameters used in the core balance rotation.\n\n"
})

spec:RegisterSetting("lunar_cooldown_leeway", 14, {
    type = "range",
    name = "Cooldown Leeway",
    desc = "Select the minimum amount of time left on lunar eclipse for consumable and cooldown recommendations",
    width = "full",
    min = 0,
    softMax = 15,
    step = 0.1,
    set = function( _, val )
        Hekili.DB.profile.specs[ 11 ].settings.lunar_cooldown_leeway = val
    end
})

spec:RegisterSetting("druid_balance_footer", nil, {
    type = "description",
    name = "\n\n"
})

if (Hekili.Version:match( "^Dev" )) then
    spec:RegisterSetting("druid_debug_header", nil, {
        type = "header",
        name = "Debug"
    })

    spec:RegisterSetting("druid_debug_description", nil, {
        type = "description",
        name = "Settings used for testing\n\n"
    })

    spec:RegisterSetting("dummy_ttd", 300, {
        type = "range",
        name = "Training Dummy Time To Die",
        desc = "Select the time to die to report when targeting a training dummy",
        width = "full",
        min = 0,
        softMax = 300,
        step = 1,
        set = function( _, val )
            Hekili.DB.profile.specs[ 11 ].settings.dummy_ttd = val
        end
    })


    spec:RegisterSetting("druid_debug_footer", nil, {
        type = "description",
        name = "\n\n"
    })
end

-- Options
spec:RegisterOptions( {
    enabled = true,

    aoe = 2,
    cycle = true,

    gcd = 1126,

    nameplates = true,
    nameplateRange = 8,

    damage = false,
    damageExpiration = 6,

    potion = "tolvir",

    package = "Feral DPS",
    usePackSelector = true
} )


-- Default Packs
spec:RegisterPack( "Balance (IV)", 20230228, [[Hekili:9IvZUTnoq4NfFXigBQw74MMgG6COOh20d9IxShLeTmvmr0FlfLnYcb9SVdffTO4pskfO9sRd5mFZhNz4mdL)g))2F)red7)J7wF3213D3N92S5(h)4g)9S3kW(7lqrVIEb(rgkf(3VIsqzr4MWBE(FwX39TKC0rokL5v0iqc)9hQijSNZ8pyf6TpcYwGJ8)XgWiNihpIfIIlJuW)B0kYXMWckjNsyV1egNtBc)l8RKecyxAEmjbSgkIrYZk9kO4O80di2FS7ptr0xdYJdyNWbxijhVLeVBrvXYfhQIJ9EHeZu31RQO572GHDkNMv2PSDrsZZZELKfaClDublY5R189R7cRfHssce)zqcPKDl3dVJKryQsrRYmfcLJ5MJV(zCaodNsWLpTDs9klqT88mIsqhsWE8fcYYVmPMXKYtk03JttqwjqcHsQYq0ajM3EgLuH3160XrjKIsCqRed84wbQmpzcGALyganeIRN7HmTUU3HmWYtGo3POG(chWVCXph8cuIqzbq6EKB3zcQKfGkksi4J7wxx)Vvy6Bbmsk(dti9t72UEkpylJhJeIqXCjHP0ZGecpHM7(QtvU(sn)VK0Z6eoj43OfeLOxxRh3L7Ss9cdhhW0LmenMqBV(k8lGo4YGlue7eKpV8gD0KeOU2uEkofrYk)IWiEsW9Ej6yDDA(zs2lRmOaVOLKcloIBrvUgNbc9mudQXfH5foZqSkk2(jdkPzQictj4GRMKFizOeCgZJKc(PZ4JbkY4HZ4NE4a8cnVQiifNEatlFA39UpsGpahXckVG6Qd3DSuxFqXIo9GwCNGtoxfb0lFjbwYRBDjvE3UqhHWL6IkJFBnSqB8DqP6HqnAILwMAVo9AXlbbADc6XtHUXqiaffHtWGzH9VTQKhQJdGePDB6Zv1QIV0YQDhPNkXmg4qlL3jYZtoMFbAPGXxqVzqerdYF)2LBqcdNw(730tvkWqHzMLdLqSsDzbeRC)HvgMZmf0v3llhihTcvtbHHygEfCI7Ec5nlZiw)ufLsGkVWmHNHuAyNRZD(G)EW1KXdn(7FoTiNYaCd)utOaIMq(CoLEnF3FF7V4JZYV0a))pANqUJl(F1FFemnkuRcXhZ1smlCjmACt4IMqxxCdRRBcDwkVj8lsAnOCUqTUsZHRKd(cJs3jKpdoVo5kWhZYuTKvazpEY954TLJNCdT6)Qgce9JQIkJrAYC)y0R33nJEdcVXG(dnHpTRj8EN(jfu4C5tZWvPDVQhl1n4G9GtWKebozwZU7XSBdoCFEgCtpm6mBBPPkQPABTh5F0jfCyOEyAtN5ySz90GmSbL1SAg)PHXOQeMTRJsf0FmL4MCG4rR8X(g)(bxZ(xsb5sd8mAViAa2q1NRxvM4S2vdCE4YL(6fllh4X0TT2vRN76BqhVuw)9VfD1MS8kzLmfThypzThvLfpRECFMMkQpZ2OyJyYHHLAyI4YON55FF8UzuBBqPsLErASQnQoJUk6pxMhAC39UnFD8PpuiN9r(83RmaeNGJgt)LZszu1KuUZA(LtQRdlAJx6xuhFqb7nWhTdPJ300pXHJZF)8goDapmOvPE7n39kDmzOLMbUBr6ysrx9cARLB5guo4sH4yVAsC5)cErVJ0Jw56kBQralxaENgr(rQunIMNYsc90gX1W1THANXefoOyD902PTU5ST9ey5WrFDtHRT8TK1pnfSekv)IsnHWOGRfUJ(Vdvt4hSEryOM8Pi3U2mTq(rDSDH4DsyZpb2CjSnnnj8WVpLTBFtt4Z6F)lBtzE1egEl1WR(4S)Sg)gJeRRFGVwhNzEz)(Rm9pkuumWqfFYe)9Fdh)FOiX8t())d]] )
spec:RegisterPack( "Feral DPS", 20240831, [[Hekili:TV1EVTnos8plglGpNTT(ITZREioa7E3Uan3IEfN7D9)KeJeDSUilzqjL0uyOp73m8HeffPSIBlUDboGIKiYHZmC4m)MHpQ3mVp6TkIuq9E)8tNF2PxTy20tpDXzZM7TQ45DuVv7iHpqUh(JuYw4N)kLrsQc(BFyf21ZjzKiKf5zLSqOBVv3vgNu8UuV7SX3fN9wG2D0qV3pBM3QnXrrubP08qVvFkR43(7vbkzWkJJQc(ij9HQGpWIZyXfX08QBRU9Jz3FFcTkGe9ijnKcuXYkifXzPWFrdZ2ULMgX)oVkigASydqDycjh(oBhVJPWeGLToobu7F4hmK6Tqd)mjh5mYZpL9PvXBHXo5NY(fKuAsEiJSU4euBWr)bUyVJuuDljuW)DQME1Y)8wc7b)S1(GE4)uCs0RJxVC0DLRxpnh0BF(FvUdyLTbxSjJLMZhcsJnscbMSoJTvs0ybVVJsy8MN6AC7Y4gTBvtJFItZB(T48IQGv0eAOOF5yHruMt9JlOGXqRrfBAAzd48WGvAAKpjmeyeJVC8AC4zRx7FFy0YzO2MtHPFwAz(uyXLD5ACvW)SDHlNnEcFsueFpWj)1LSNHPX(9HzzjrzpL2QdgDljon)MLZo)eD1GvM6l(YpbMtVgDIxIMLNOKhPO87yOgR6oo9EFAk5UeWlyiS0Va8u9jzoy7il8DmYOhPWN0TGR9nZ5c3FBwevWTxS8FbY(iff6QPpjvUEOCmNodHz2yK(4mCTvEQ)vsXFbIwPRjLjGV6)So()Pn0urqVAKnU(HCN(8Ntj7a)W8DmWEWdSkyp7R5pTFp2WDWNu2d73lnO8VAfkj4N2a76FBWzZXk5Q9Xj70CmHiMxch0414p85MsyYSfcD2sIsP58jLKU2DmMpzA3gU0bRzS7FEAyjJrtlUE(PMsDnHYIP(RJzWpWOuueOWZEACbHDpTyAwzrECeDENHYdQd3Gu5lxYBpKlnhYwskGWRiwWGIzZ8z01mA(guQMdHfVdPf(LTEZjpcPX8zzegNk43CvFKd6brMfgNvM7Fha3XDsHFZhYK22QBwkg502dzkG(LgTF)O8nzLjr(1OoNmE0ePq3VxPhN0Vbq(LTzn5bU2H)2w)UmKyE6iBdOg4GJoBO7GQBDTaMiMZO97BuAOvP6TFVfvOZK3MdJuvsq1GRlDTe4kSWwWxRT5fSHr5jFNq)Ci457tRx94DPw0easGSyHK8caLGN6Xahy)Ethb53BjF(nY)KrVNM(JjqLqPHpFIg4fKRn7xgmcwajfkfzlqymumdp0HxJcGsa)id6cs)vq4L6mBwvqujcTbdlJkhB4ZHyfti)ltfRmqRisnWbqgil(CvWJKKY2wweSVTFeNv(cTihqRGb63UTZDg0oEueLBgf8drEKibpfxSjoD(WNw0hrZeomaernb7xZheuICyFtZsi55rNPqoEv2IEYpO0(2WDynHffr3m)vsxrRJ5P4D12jJu5xSFVrllgBP8mBS9GXL10bizd03QTUC9LTDIwmEYeLFgYvES6e9gK1lETEBfXHpalaBPNCY4jOXYrN9A6e7CqbxcrXRbxu6FIHHEOxA2AEqhaniJl)4VkckdJSVG3dyScnPwCaCY)kxkuTk(qjkQTtcfGOppH8cjdIQGQPXPwJculcE4tzILY2f6cWQXs8tKoWUsIEwU7dd4t7CpuR6UgEANwAkdDK6OlJ0ugKI6IyQ1moaaYkb((RKDuSHrY3iAZUifuyjEyMD6f(byldFmAQxFkH9(6uv2lzr0X6KWRc33nU7aWPc2JwHf)O84u(UWv5J0fmFpfO(bleFjg2fiprOAxGGS3qjjfBMUlS46fNAFS5LShJHes(qKki)WICJbEMJb2Q8b1IHZco1hj3oXrQACJUz55NBN6DLjpcM)VWb3IYkMMqcXPOaUaSoJB1iSv)WhwUODJkKOZSlcfDdayC(W0IdiWUL5pqjlDsYNQYz7VE94j1z7)pzmFcBl8tOmRsr8hc80amRjzSSalTQu9l0bH1v(ikiass8xW95QY91vXWEQvnYoNAuh2PPxD7R2W6s76KUwVtj4MHV31lVYvWr7YtStKnKJgxDhWohRR3iR(EJCwwK9iPbkSd7NRI2Mi0GAj0ujFttnlDFBmfDvKRxmWWn34sMaZQDq4aD2yZcD4QScJJgGwv5ZrbsRe(Xbuxxy)GbRLJ47nGTAAz7Os(Fo(Ou5(DmgPAxsUqTAvSTdGR27uYnbVi8w7Bj0nH14fFnWIT3(A)t3HaJ81fd8vdJAX0mqysTWDVvGOYHUL3R0fZx4T6jclfxp8w9UT7Yyfie4LakiNpvb4PnNpT6wVv8)cVUQAwdF8E(DGjXo9(zVvHS4cy(q8w1GIvfCDvWIt9wjyQ3kRWMEfGAnuUDMg36cIISAHtwzarQPwMaQiFoZjF0D9RcUzzvW5N3WmUbhg)5ohVn3NQGX4wknxzRcaUVOBNsFgHjPr21ovOcCHHcOisXeqL0ZbJlPR6Kz2B18xUQ3w7av5shQsNaWJrNSLIGRtta16qjkQc2VxNY2PletnNPm4tWlQcob(honVY5sU9mfgAzN8fMkNTSg6QOZmhIvcPIwB97qoohElohuuirA1NuajZoDGHgxdoVxPfWkYEWzXmDXyKHWuCZ1PvKMZKKf6KOH9BsNzq93IyIrgE)6HfqFgPS4QHj2q343JqpgwSPjSYKgLuplLW1ZEMQAVj(C57omJuJXujCbEP(ATfeK2R4x12ZO0GGcmmGFxc1j1uexFN9gSSL7O4o8nOWDkix3BpFbzMAbHB2noIy(6rF3IVit0SZBfI74bfiMCYt1cN29MVt6btAEveOEInyC54nY14ARffr4lEmmQbs7plPDPoYQG5DHYR5CdbZrvW8AnT7v2pCLTUCkBzv)ku4Vj6LT0Rg6uO2teWLHAysvEe79NRZuMdM11PFSYwWqQZlLaeXW1VohBLM2e93(5ejEavS4DIUh0lxYqJ4Zv9hJu)fZYNdgjgA8xSo5E)Idb3u0SU07KxDFEdeq(CDf3(9)jNiM3njV923pPHPEq3u5l(cyTz7Tn9F5QITln9GMN(ZeyEVLC8D9RNSjbSwXdolzQxaCdzPvmLEJDtj4gCwtr7wTyVOKnHaffrkq6xb73KWVHvTzyZDX2pgNf4Slewpl9ik6XscwnbRUvY(H5AUwwnaoEB2WXAO4HHwr059njVMVzDZ4S6s6MOhykVmxZDtOFLUCgA9MBfBAqXx1AwpK6vVdHUguJAZCHvvdkAIqtpMBiUv9xgxgCn8PnOZVNbRUZrCSbR9d14myDavc2KvQ(f0PZERpyUMWSopAoExTFdqC3V5N2pMJ4vZP70RE5C9TDGEbJg2jcjHcCJazh(3wUN(ruepgmnWI4D9xtK6vJPYe3HdgGO9SZD170tfPBUaHBUqWvRVypreaOcDEUfsWJrCUQE2GCQB0(tAz51yUvyIgLU5TY5YApZDGM6X1zaoxOooHdSux)o8CkA3jK7AKQTqoQ0IBVSB8WV0EPJIEvVRr(x2E)I628g82clhorh1U5Xe2FatNJgyOjpN5oud9mLVbXw(KAVdrnWyZhPHnyArJ2C3BExIvbVP(t(rxxf8J1LS0YuY1drwL2BD8)FK5)b8iZ1C9)9XHm3FIo3Hn)X58NBDEDwpS332T2sBh1BRsqDCq2UJih8bz360apWbz7oo7fEgY1cS(qwRZ3yKlYML5CD6o4bO6oM44ck)QoWz7HT9KVW5jjB3eE4tlUzRd9IOR9Qmvh5wRx7zRvwJ0uMAq3k0DJ93i3gU050KC5cAO0gXaAZcJxgkFd8Yo1FDODcygWMnAuiCSg7EFwhOHEZA0ph0Gouq)ho45YdcpD1lj6Q3J78O8neoP4rz(psR)pEQ4)nOtE3)gJGkX)Nr6TAv5oklTmpNpeV)7p]] )
spec:RegisterPack( "Feral Guardian", 20240831, [[Hekili:TVvBVrUTr4FlgbWDDoFB3x8BPW2ajnnfNB61GkJEFts0sC9QATslOKSpFqq)27m8fjkksTRTVGMaeG72BfjNHdhoZdNhX98N7FRVxmPK6)XfZwCYSlwoF6SzZoz2j(ELpVL67TLe9a5E4lzKnWN)eLrsBc)7vewCcjd7)50CsmQNI8kwemgFV7Qssl)qM)D2u(YtaLxSLg5)X5Z99wNehtfdLwe579P8YF(F0ekNOFKvLe3eElj7HMWFHLKZsktOfn30CZT53FFkTjKe)ijlIcJILxsktYZGVrJY3SHMfZFUOjmbASCnm6Ousb8C(wEhtHfalFvsky2FZ30TUut8nqB)aPavoQ2pL)jVKn8zhh9VWNM7iLn3qIe6BRQP3D1FEdH9qq(QayEdEkjn(4KvxDWDvRwnTaSZa(3Q2Ax2Y15SScUeUgYDuclyvoBZOJABo3JCJYM)E(yE)pNuu2e6rtPrI(LYcsuvqdskP4YSRrLA6AzneEWGTrACajkcueJ7RpgfpF1QG7JIVAUUaSQSaXtbPWSFmgqDfFruc7UbKCkUq4EL2Lg4FoeL5rAanJUb25VEX(RtR6BNIhb7n6gd(8R2waHTPiD5gUpk2P8sY4X33sy3t1cXAxEGSRy0SVKaBbm69Grj3ca9SMsslxpDBu5LlNzx2Ik2JjpssdsYkktYIklme8ehcUctndIwJ2va2bkxj3kNMxvwKetp3UKBivP4GzaIY0Okgy9LxF1PNAF0BRsFKYs(cFRioVCAkjcxI0PLjrpaENd71iKuf9Wvl73iJUHaRVlpX(uOg3XrphLsdelIIRMF8gYNd632I9Zk2XeUIaRiAWQeg8b6h33zUGwcBs3xmfvFj83GvRoCsmLhzTH8FZzbe2g4tgnUIpXtJZFkRUwngTzgJKT0QY0p7OJSB8XuyciPjFbmKawUyJFOHH90AAKToTObQtZUg2xRJ1L1DhahrzpyVtAggZzg7D5vx4k545mYwajRyldxC2hu5AgPyTRqDm7LNE81j07aRXEhiX34l9ENMyptApNSDhNRY2MiSG2zaSH6AJM626(64kgAixUCpt3CJlPGD)NvPLjJG6INn8wqELY)6qFvt(Rdbwk9lafwkXV2iXQL1aWXFla8jnUFdd(jTqNWrQqUNs26ersog3GOYb8Iasvt8obtLdSfi4TG31gLpgaSRiUV65aVz8rlUM9e)tlDxbU9xbUkA0KswbeIKvLcePIWIB7uueNaHXMhhPH9CqzY9WMqWQk2Z11yddICeIRnU(udSOitzLQ0UCoMViKlykNC1X4hb8YWbBFdGyUHeNrl4Rb5463XHInMETH5Lia)9p3gSVyM5SAf5cN88NoSpU8IbIQJLlPl4ekpssSKhAlhSqbLZNdynWPsfRXz1uewYwEoBYwB9wqEesMBr1W)LB6h4y8WuMhLKxveCxIiKe)xUit67RU(kHKt7lYuG4ywCD9bfRZRsJ5zPprjpsp6WdMiN06ALDC04oa5t2w1KhKqvpyTFxos89xeBtaEULIRMPTdMU19cyHyUIQR7mAOvP5vxBXegS4TfWinLu0m42YqpXJTW289ABrbRHdRWHmH(5iiYpG2U7X7sTPjiZcZflIG1UCFhMwhWCDTzGG8zOMU3l)kV0PVnfqXYIE(OEyuFF(F7V0e(J0va4f84)UfY6P10mXRZrd4klUjCJOUTszDBGIauc4JCOl5HZWtZN3egxHizGy5uPS8AmfVINQmXod0kYYh0amhOk(CtiuUwvFpB)ZAWnJDxc7PotAp8G2YAq9HipsKGNskxNKTy)xw0hr3ekgaIOwGJB57fuI9t031HcdIoSPZx9jf9lDzSZhuwFF4Udq)Cz81lENmu0Qm8INK(jXjLTVgOZQRnAzP4Kenl2XIEN5LTJ7H9HE0PdTUlpVFqeusYevCgQvEU6e9guLJO3gwJdSbSHE0rhobDwo6CuxN41PQGlfLF8e9pXWupmknFfpPdGgK5L3(tIKYOy7B4Jag77bfxvasiF5ZNTyPV3tewggV679HnBZzLyw(zIcFWPbFTDftBUX3J)n8DA3wmf8Wh5VTCAg5oaEW)h89IyWrzSeIVxhVTMWlBcxoZ3tOuFpRef9lbZAF12jAABiTruvlDQkJkj0mltkKOEoXPE0l2Vj86RAcp90oLHLyIYFQt5TvWCt4HaQ1GAzBcbTVCyNYWsHlPBUBlJgnGZmma1Gukbmj98fCl1BqwKV3IxUP336at5ChMYGsfFn2KnsXCBAcyw7IACtyDT(i7tqwS0CssMVaHCMJG)GlZlCULBNBSHvoGHSPXzJNSUj6KRSyNqAOTE)bdhxdFhUguJqEUH(IcgY8z7zQXLqW7fAjSc(YCvmxFAmob1C6wOpwbXEZHSuFiASDnhNzs9xJCIdmI(1tlG(moTNBgMyddZFFf2X(LBAcRmPZi15Llc9SZnVnAIVw(vhMrAX4rj8j8C99Alii93XVOFKrLXakX0aEH1ThQPgC7D)zOYEHJI7c0ye8OrTY24RzLeoURqdv4(0hz8eP7s8WTX(15aNk1eUOBonUooXz6bIBXU3Riz8dUgm1VWzW2PsgAps7EbFBRlzTr2o(X9CU3QEC4EiJsxxTUmrax7vsBRoQUq1(xyU4NeaqEw09WlI3y(5Rm97wF8YSmSyXvUpE5uJSifHVJLJu2TbnQtqXiBprrov3aTZGtclBYUK3EFgMgU89IR5lMcTTTfBl)xUPyJ27oDpJVLBY8KFiHobZUtn0oXZ558JIZzmxAXM6nAGYok8LMHoSeNrHM4H6IiKYybiut47asscoYARWo20Jd8ybx7mH3ZspItQTWIwBIv8khhyQJyTgshVnFvTFwIdrITVMeqZLcCe(5dZZARdzIEIPKoUzjW6KY5k0k3BrLUk9Q2ZgzO(TL1o0HAuqHlSQo8pdK6xfh)EKhmPZZHp7FU9FWi)3HmYhJF4)x4Wosz1JIM97h6T9OdyLl53nefWgtYEGfo4j7oJCV5j3JSXo4jpAPAVekQTtylhUsf3zJstS5zovFC7KFM7CIxxs5BIpR9025Ud8Dsu1UlC3KrJSZky)lbB0QTCdQ)AR2A8AfDwTLfn56vZODj26Q36Dw3vN0G7TM3v)RHJVvTy24hniU4A9QwuxE9oqlDhyVFN6jRLZDSN963nZq3DjHI7JvRAVKT2kgutc5f3QGpgObJQGh59fQUQCvQR5geEuUqRwV0Cr0pycMLiPQ(7aUwv3CpF0Dw)r988AkFhG3DxxTlV9C3jAQ73wZFJvxpo(TLRc35u7UkPHoPwpKdQYC)LDNh(K2p2arVQFAb8NS9tiq3N37fgm4vIoWS7Up)Xtyg5eLXz)mcmpgzk)za0lMu7NcG2bmg)CaSskw0OTW9UFAanHVV9rE55nHFBlNZEUsUDWpabjgGVAO)vw7))ue))fzYh(pOav4B2X3ZRAlLLvvuWfX))9]] )


spec:RegisterPackSelector( "balance", "Balance (IV)", "|T136096:0|t Balance",
    "If you have spent more points in |T136096:0|t Balance than in any other tree, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab1 > max( tab2, tab3 )
    end )

spec:RegisterPackSelector( "feral_dps", "Feral DPS", "|T132115:0|t Feral DPS",
    "If you have spent more points in |T132276:0|t Feral than in any other tree and have not taken Thick Hide, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 ) and talent.thick_hide.rank == 0
    end )

spec:RegisterPackSelector( "feral_tank", "Feral Guardian", "|T132276:0|t Feral Tank",
    "If you have spent more points in |T132276:0|t Feral than in any other tree and have taken Thick Hide, this priority will be automatically selected for you.",
    function( tab1, tab2, tab3 )
        return tab2 > max( tab1, tab3 ) and talent.thick_hide.rank > 0
    end )