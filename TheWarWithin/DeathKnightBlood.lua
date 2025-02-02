-- DeathKnightBlood.lua
-- July 2024

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local PTR = ns.PTR
local FindUnitDebuffByID = ns.FindUnitDebuffByID

local strformat = string.format

local spec = Hekili:NewSpecialization( 250 )

spec:RegisterResource( Enum.PowerType.Runes, {
    rune_regen = {
        last = function ()
            return state.query_time
        end,

        interval = function( time, val )
            local r = state.runes
            val = math.floor( val )

            if val == 6 then return -1 end
            return r.expiry[ val + 1 ] - time
        end,

        stop = function( x )
            return x == 6
        end,

        value = 1
    },
}, setmetatable( {
    expiry = { 0, 0, 0, 0, 0, 0 },
    cooldown = 10,
    regen = 0,
    max = 6,
    forecast = {},
    fcount = 0,
    times = {},
    values = {},
    resource = "runes",

    reset = function()
        local t = state.runes

        for i = 1, 6 do
            local start, duration, ready = GetRuneCooldown( i )

            start = start or 0
            duration = duration or ( 10 * state.haste )

            t.expiry[ i ] = ready and 0 or start + duration
            t.cooldown = duration
        end

        table.sort( t.expiry )

        t.actual = nil
    end,

    gain = function( amount )
        local t = state.runes

        for i = 1, amount do
            t.expiry[ 7 - i ] = 0
        end
        table.sort( t.expiry )

        t.actual = nil
    end,

    spend = function( amount )
        local t = state.runes
    
        -- Consume the specified number of runes.
        for i = 1, amount do
            t.expiry[ 1 ] = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
            table.sort( t.expiry )
        end
    
        -- Handle Runic Power gain, considering Rampant Transference or Rune of Hysteria.
        local rpGainMultiplier = state.buff.rune_of_hysteria.up and 1.2 or 1
        state.gain( amount * 10 * rpGainMultiplier, "runic_power" )
    
        -- Handle Rune Strike cooldown reduction if applicable.
        if state.talent.rune_strike.enabled then
            state.gainChargeTime( "rune_strike", amount )
        end
    
        -- Handle Eternal Rune Weapon interactions (Dancing Rune Weapon synergy).
        if state.buff.dancing_rune_weapon.up and state.azerite.eternal_rune_weapon.enabled then
            local maxExtension = state.buff.dancing_rune_weapon.duration + 5
            if state.buff.dancing_rune_weapon.expires - state.buff.dancing_rune_weapon.applied < maxExtension then
                state.buff.eternal_rune_weapon.expires = min(
                    state.buff.dancing_rune_weapon.applied + maxExtension,
                    state.buff.dancing_rune_weapon.expires + ( 0.5 * amount )
                )
            end
        end
    
        -- Invalidate the actual rune count to force recalculation.
        t.actual = nil
    end,

    timeTo = function( x )
        return state:TimeToResource( state.runes, x )
    end,
}, {
    __index = function( t, k )
        if k == "actual" then
            -- Calculate the number of runes available based on `expiry`.
            local amount = 0
            for i = 1, 6 do
                if t.expiry[ i ] <= state.query_time then
                    amount = amount + 1
                end
            end
            return amount

        elseif k == "current" then
            -- If this is a modeled resource, use our lookup system.
            if t.forecast and t.fcount > 0 then
                local q = state.query_time
                local index, slice

                if t.values[ q ] then return t.values[ q ] end

                for i = 1, t.fcount do
                    local v = t.forecast[ i ]
                    if v.t <= q and v.v ~= nil then
                        index = i
                        slice = v
                    else
                        break
                    end
                end

                -- We have a slice.
                if index and slice and slice.v then
                    t.values[ q ] = max( 0, min( t.max, slice.v ) )
                    return t.values[ q ]
                end
            end

            return t.actual

        elseif k == "deficit" then
            return t.max - t.current

        elseif k == "time_to_next" then
            return t[ "time_to_" .. t.current + 1 ]

        elseif k == "time_to_max" then
            return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

        elseif k == "add" then
            return t.gain

        else
            local amount = k:match( "time_to_(%d+)" )
            amount = amount and tonumber( amount )

            if amount then return state:TimeToResource( t, amount ) end
        end
    end
} ) )

spec:RegisterResource( Enum.PowerType.RunicPower, {
    swarming_mist = {
        aura = "swarming_mist",

        last = function ()
            local app = state.buff.swarming_mist.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.swarming_mist.tick_time ) * class.auras.swarming_mist.tick_time
        end,

        interval = function () return class.auras.swarming_mist.tick_time end,
        value = function () return min( 15, state.true_active_enemies * 3 ) end,
    },
    -- TODO: Add blooddrinker
} )

local spendHook = function( amt, resource )
    -- Runic Power
    if amt > 0 and resource == "runic_power" then
        if talent.red_thirst.enabled then reduceCooldown( "vampiric_blood", floor( amt / 5 ) ) end -- it seems to reduce it by intervals of 5, not 10
        if talent.icy_talons.enabled then addStack( "icy_talons", nil, 1 ) end
    end
    -- Runes
    if resource == "rune" and amt > 0 then
        if active_dot.shackle_the_unworthy > 0 then
            reduceCooldown( "shackle_the_unworthy", 4 * amt )
        end

        if talent.rune_carved_plates.enabled then
            addStack( "rune_carved_plates" )
        end
    end
    
end

spec:RegisterHook( "spend", spendHook )

-- Talents
spec:RegisterTalents( {
    -- DeathKnight
    abomination_limb               = {  76049, 383269, 1 }, -- Sprout an additional limb, dealing 109,767 Shadow damage over 12 sec to all nearby enemies. Deals reduced damage beyond 5 targets. Every 1 sec, an enemy is pulled to your location if they are further than 8 yds from you. The same enemy can only be pulled once every 4 sec.
    antimagic_barrier              = {  76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by 20 sec and increases its duration and amount absorbed by 40%.
    antimagic_zone                 = {  76065,  51052, 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 1.9 million damage.
    asphyxiate                     = {  76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation                   = {  76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and its cooldown is reduced by 30 sec.
    blinding_sleet                 = {  76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_draw                     = {  76056, 374598, 1 }, -- When you fall below 30% health you drain 35,677 health from nearby enemies, the damage you take is reduced by 10% and your Death Strike cost is reduced by 10 for 8 sec. Can only occur every 2 min.
    blood_scent                    = {  76078, 374030, 1 }, -- Increases Leech by 3%.
    brittle                        = {  76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    cleaving_strikes               = {  76073, 316916, 1 }, -- Heart Strike hits up to 3 additional enemies while you remain in Death and Decay. When leaving your Death and Decay you retain its bonus effects for 4 sec.
    coldthirst                     = {  76083, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants 10 Runic Power and reduces its cooldown by 3 sec.
    control_undead                 = {  76059, 111673, 1 }, -- Dominates the target undead creature up to level 71, forcing it to do your bidding for 5 min.
    death_pact                     = {  76075,  48743, 1 }, -- Create a death pact that heals you for 50% of your maximum health, but absorbs incoming healing equal to 30% of your max health for 15 sec.
    death_strike                   = {  76071,  49998, 1 }, -- Focuses dark power into a strike that deals 32,989 Physical damage and heals you for 30.19% of all damage taken in the last 5 sec, minimum 8.5% of maximum health.
    deaths_echo                    = { 102007, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have 1 additional charge.
    deaths_reach                   = { 102006, 276079, 1 }, -- Increases the range of Death Grip by 10 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    enfeeble                       = {  76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by 30% and the damage they deal to you by 12% for 6 sec.
    gloom_ward                     = {  76052, 391571, 1 }, -- Absorbs are 15% more effective on you.
    grip_of_the_dead               = {  76057, 273952, 1 }, -- Death and Decay reduces the movement speed of enemies within its area by 90%, decaying by 10% every sec.
    ice_prison                     = {  76086, 454786, 1 }, -- Chains of Ice now also roots enemies for 4 sec but its cooldown is increased to 12 sec.
    icebound_fortitude             = {  76081,  48792, 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 30% for 8 sec.
    icy_talons                     = {  76085, 194878, 1 }, -- Your Runic Power spending abilities increase your melee attack speed by 6% for 10 sec, stacking up to 3 times.
    improved_death_strike          = {  76067, 374277, 1 }, -- Death Strike's cost is reduced by 5, and its healing is increased by 5%.
    insidious_chill                = {  76051, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by 5% for 30 sec, stacking up to 4 times.
    march_of_darkness              = {  76074, 391546, 1 }, -- Death's Advance grants an additional 25% movement speed over the first 3 sec.
    mind_freeze                    = {  76084,  47528, 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    null_magic                     = { 102008, 454842, 1 }, -- Magic damage taken is reduced by 8% and the duration of harmful Magic effects against you are reduced by 35%.
    osmosis                        = {  76088, 454835, 1 }, -- Anti-Magic Shell increases healing received by 15%.
    permafrost                     = {  76066, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to 40% of the damage dealt.
    proliferating_chill            = { 101708, 373930, 1 }, -- Chains of Ice affects 1 additional nearby enemy.
    raise_dead                     = {  76072,  46585, 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts 1 min.
    rune_mastery                   = {  76079, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by 3% for 8 sec.
    runic_attenuation              = {  76045, 207104, 1 }, -- Auto attacks have a chance to generate 3 Runic Power.
    runic_protection               = {  76055, 454788, 1 }, -- Your chance to be critically struck is reduced by 3% and your Armor is increased by 6%.
    sacrificial_pact               = {  76060, 327574, 1 }, -- Sacrifice your ghoul to deal 22,298 Shadow damage to all nearby enemies and heal for 25% of your maximum health. Deals reduced damage beyond 8 targets.
    soul_reaper                    = {  76063, 343294, 1 }, -- Strike an enemy for 13,343 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 61,222 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    subduing_grasp                 = {  76080, 454822, 1 }, -- When you pull an enemy, the damage they deal to you is reduced by 6% for 6 sec.
    suppression                    = {  76087, 374049, 1 }, -- Damage taken from area of effect attacks reduced by 3%. When suffering a loss of control effect, this bonus is increased by an additional 6% for 6 sec.
    unholy_bond                    = {  76076, 374261, 1 }, -- Increases the effectiveness of your Runeforge effects by 20%.
    unholy_endurance               = {  76058, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground                  = {  76069, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    unyielding_will                = {  76050, 457574, 1 }, -- Anti-Magic shell now removes all harmful magical effects when activated, but it's cooldown is increased by 20 sec.
    vestigial_shell                = {  76053, 454851, 1 }, -- Casting Anti-Magic Shell grants 2 nearby allies a Lesser Anti-Magic Shell that Absorbs up to 66,240 magic damage and reduces the duration of harmful Magic effects against them by 50%.
    veteran_of_the_third_war       = {  76068,  48263, 1 }, -- Stamina increased by 20%.
    will_of_the_necropolis         = {  76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk                    = {  76077, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.

    -- Blood
    blood_boil                     = {  76170,  50842, 1 }, -- Deals 16,740 Shadow damage and infects all enemies within 10 yds with Blood Plague.  Blood Plague A shadowy disease that drains 28,388 health from the target over 24 sec.
    blood_feast                    = { 102243, 391386, 1 }, -- Anti-Magic Shell heals you for 100% of the damage it absorbs.
    blood_tap                      = {  76039, 221699, 1 }, -- Consume the essence around you to generate 1 Rune. Recharge time reduced by 2 sec whenever a Bone Shield charge is consumed.
    blooddrinker                   = { 102244, 206931, 1 }, -- Drains 76,016 health from the target over 2.4 sec. The damage they deal to you is reduced by 15% for the duration and 5 sec after channeling it fully. You can move, parry, dodge, and use defensive abilities while channeling this ability. Generates 20 additional Runic Power over the duration.
    bloodied_blade                 = { 102242, 458753, 1 }, -- Parrying an attack grants you a charge of Bloodied Blade, increasing your Strength by 0.5%, up to 4.0% for 15 sec. At 8 stacks, your next parry consumes all charges to unleash a Heart Strike at 200% effectiveness, and increases your Strength by 10% for 6 sec.
    bloodshot                      = {  76125, 391398, 1 }, -- While Blood Shield is active, you deal 25% increased Physical damage.
    bloodworms                     = {  76174, 195679, 1 }, -- Your auto attacks have a chance to summon a Bloodworm. Bloodworms deal minor damage to your target for 15 sec and then burst, healing you for 15% of your missing health. If you drop below 50% health, your Bloodworms will immediately burst and heal you.
    bone_collector                 = {  76171, 458572, 1 }, -- When you would pull an enemy generate 1 charge of Bone Shield.  Bone Shield Surrounds you with a barrier of whirling bones, increasing Armor by 10,088. Each melee attack against you consumes a charge. Lasts 30 sec or until all charges are consumed.
    bonestorm                      = {  76127, 194844, 1 }, -- Consume up to 5 Bone Shield charges to create a whirl of bone and gore that batters all nearby enemies, dealing 8,399 Shadow damage every 1 sec, and healing you for 2% of your maximum health every time it deals damage (up to 10%). Deals reduced damage beyond 8 targets. Lasts 2 sec per Bone Shield charge spent and rapidly regenerates a Bone Shield every 1 sec.
    carnage                        = { 102245, 458752, 1 }, -- Blooddrinker and Consumption now contribute to your Mastery: Blood Shield. Each time an enemy strikes your Blood Shield, the cooldowns of Blooddrinker and Consumption have a chance to be reset.
    coagulopathy                   = {  76038, 391477, 1 }, -- Enemies affected by Blood Plague take 5% increased damage from you and Death Strike increases the damage of your Blood Plague by 25% for 8 sec, stacking up to 5 times.
    consumption                    = { 102244, 274156, 1 }, -- Strikes all enemies in front of you with a hungering attack that deals 23,375 Physical damage and heals you for 150% of that damage. Deals reduced damage beyond 8 targets. Causes your Blood Plague damage to occur 30% more quickly for 6 sec. Generates 2 Runes.
    dancing_rune_weapon            = {  76138,  49028, 1 }, -- Summons a rune weapon for 14 sec that mirrors your melee attacks and bolsters your defenses. While active, you gain 35% parry chance.
    everlasting_bond               = {  76130, 377668, 1 }, -- Summons 1 additional copy of Dancing Rune Weapon and increases its duration by 6 sec.
    foul_bulwark                   = {  76167, 206974, 1 }, -- Each charge of Bone Shield increases your maximum health by 1%.
    gorefiends_grasp               = {  76042, 108199, 1 }, -- Shadowy tendrils coil around all enemies within 15 yards of a hostile or friendly target, pulling them to the target's location.
    heart_strike                   = {  76169, 206930, 1 }, -- Instantly strike the target and 1 other nearby enemy, causing 14,123 Physical damage, and reducing enemies' movement speed by 20% for 8 sec, plus 2 Runic Power per additional enemy struck.
    heartbreaker                   = {  76135, 221536, 1 }, -- Heart Strike generates 2 additional Runic Power per target hit.
    heartrend                      = {  76131, 377655, 1 }, -- Heart Strike has a chance to increase the damage of your next Death Strike by 20%.
    hemostasis                     = {  76137, 273946, 1 }, -- Each enemy hit by Blood Boil increases the damage and healing done by your next Death Strike by 8%, stacking up to 5 times.
    improved_bone_shield           = {  76142, 374715, 1 }, -- Bone Shield increases your Haste by 10%.
    improved_heart_strike          = {  76126, 374717, 2 }, -- Heart Strike damage increased by 15%.
    improved_vampiric_blood        = {  76140, 317133, 2 }, -- Vampiric Blood's healing and absorb amount is increased by 5% and duration by 2 sec.
    insatiable_blade               = {  76129, 377637, 1 }, -- Dancing Rune Weapon generates 5 Bone Shield charges. When a charge of Bone Shield is consumed, the cooldown of Dancing Rune Weapon is reduced by 5 sec.
    iron_heart                     = {  76172, 391395, 1 }, -- Blood Shield's duration is increased by 2 sec and it absorbs 20% more damage.
    leeching_strike                = {  76145, 377629, 1 }, -- Heart Strike heals you for 0.25% health for each enemy hit while affected by Blood Plague.
    mark_of_blood                  = {  76139, 206940, 1 }, -- Places a Mark of Blood on an enemy for 15 sec. The enemy's damaging auto attacks will also heal their victim for 3% of the victim's maximum health.
    marrowrend                     = {  76168, 195182, 1 }, -- Smash the target, dealing 19,014 Physical damage and generating 3 charges of Bone Shield.  Bone Shield Surrounds you with a barrier of whirling bones, increasing Armor by 10,088. Each melee attack against you consumes a charge. Lasts 30 sec or until all charges are consumed.
    ossified_vitriol               = {  76146, 458744, 1 }, -- When you lose a Bone Shield charge the damage of your next Marrowrend is increased by 15%, stacking up to 75%.
    ossuary                        = {  76144, 219786, 1 }, -- While you have at least 5 Bone Shield charges, the cost of Death Strike is reduced by 5 Runic Power. Additionally, your maximum Runic Power is increased by 10.
    perseverance_of_the_ebon_blade = {  76124, 374747, 1 }, -- When Crimson Scourge is consumed, you gain 6% Versatility for 6 sec.
    purgatory                      = {  76133, 114556, 1 }, -- An unholy pact that prevents fatal damage, instead absorbing incoming healing equal to the damage prevented, lasting 3 sec. If any healing absorption remains when this effect expires, you will die. This effect may only occur every 4 min.
    rapid_decomposition            = {  76141, 194662, 1 }, -- Your Blood Plague and Death and Decay deal damage 15% more often. Additionally, your Blood Plague leeches 50% more Health.
    red_thirst                     = {  76132, 205723, 1 }, -- Reduces the cooldown on Vampiric Blood by 2.0 sec per 10 Runic Power spent.
    reinforced_bones               = {  76143, 374737, 1 }, -- Increases Armor gained from Bone Shield by 10% and it can stack 2 additional times.
    relish_in_blood                = {  76147, 317610, 1 }, -- While Crimson Scourge is active, your next Death and Decay heals you for 4,675 health per Bone Shield charge and you immediately gain 10 Runic Power.
    rune_tap                       = {  76166, 194679, 1 }, -- Reduces all damage taken by 20% for 4 sec.
    sanguine_ground                = {  76041, 391458, 1 }, -- You deal 6% more damage and receive 5% more healing while standing in your Death and Decay.
    shattering_bone                = {  76128, 377640, 1 }, -- When Bone Shield is consumed it shatters dealing 1,271 Shadow damage to nearby enemies. This damage is tripled while you are within your Death and Decay.
    tightening_grasp               = {  76165, 206970, 1 }, -- Gorefiend's Grasp cooldown is reduced by 30 sec and it now also Silences enemies for 3 sec.
    tombstone                      = {  76139, 219809, 1 }, -- Consume up to 5 Bone Shield charges. For each charge consumed, you gain 6 Runic Power and absorb damage equal to 6% of your maximum health for 8 sec.
    umbilicus_eternus              = {  76040, 391517, 1 }, -- After Vampiric Blood expires, you absorb damage equal to 5 times the damage your Blood Plague dealt during Vampiric Blood.
    vampiric_blood                 = {  76173,  55233, 1 }, -- Embrace your undeath, increasing your maximum health by 30% and increasing all healing and absorbs received by 40% for 14 sec.
    voracious                      = {  76043, 273953, 1 }, -- Death Strike's healing is increased by 15% and grants you 12% Leech for 8 sec.

    -- Deathbringer
    bind_in_darkness               = {  95043, 440031, 1 }, -- Blood Boil deals 10% increased damage, and is now Shadowfrost. Shadowfrost damage applies 2 stacks to Reaper's Mark and 4 stacks when it is a critical strike.
    dark_talons                    = {  95057, 436687, 1 }, -- Marrowrend and Heart Strike have a 25% chance to grant 3 stacks of Icy Talons and increase its maximum stacks by the same amount for 6 sec. Runic Power spending abilities count as Shadowfrost while Icy Talons is active.
    deaths_messenger               = {  95049, 437122, 1 }, -- Reduces the cooldowns of Lichborne and Raise Dead by 30 sec.
    expelling_shield               = {  95049, 439948, 1 }, -- When an enemy deals direct damage to your Anti-Magic Shell, their cast speed is reduced by 10% for 6 sec.
    exterminate                    = {  95068, 441378, 1 }, -- After Reaper's Mark explodes, your next 2 Marrowrends cost 1 Rune and summon 2 scythes to strike your enemies. The first scythe strikes your target for 63,866 Shadowfrost damage and has a 30% chance to apply Reaper's Mark, the second scythe strikes all enemies around your target for 34,062 Shadowfrost damage. Deals reduced damage beyond 8 targets.
    grim_reaper                    = {  95034, 434905, 1 }, -- Reaper's Mark initial strike grants 3 charges of Bone Shield. Reaper's Mark explosion deals up to 30% increased damage based on your target's missing health.
    pact_of_the_deathbringer       = {  95035, 440476, 1 }, -- When you suffer a damaging effect equal to 25% of your maximum health, you instantly cast Death Pact at 50% effectiveness. May only occur every 2 min. When a Reaper's Mark explodes, the cooldowns of this effect and Death Pact are reduced by 5 sec.
    reaper_of_souls                = {  95034, 440002, 1 }, -- When you apply Reaper's Mark, the cooldown of Soul Reaper is reset, your next Soul Reaper costs no runes, and it explodes on the target regardless of their health. Soul Reaper damage is increased by 20%.
    reapers_mark                   = {  95062, 439843, 1, "deathbringer" }, -- Viciously slice into the soul of your enemy, dealing 34,785 Shadowfrost damage and applying Reaper's Mark. Each time you deal Shadow or Frost damage, add a stack of Reaper's Mark. After 12 sec or reaching 40 stacks, the mark explodes, dealing 2,532 damage per stack. Reaper's Mark travels to an unmarked enemy nearby if the target dies, or explodes below 35% health when there are no enemies to travel to. This explosion cannot occur again on a target for 3 min.
    reapers_onslaught              = {  95057, 469870, 1 }, -- Reduces the cooldown of Reaper's Mark by 15 sec, but the amount of Marrowrends empowered by Exterminate is reduced by 1.
    rune_carved_plates             = {  95035, 440282, 1 }, -- Each Rune spent reduces the magic damage you take by 1.5% and each Rune generated reduces the physical damage you take by 1.5% for 5 sec, up to 5 times.
    soul_rupture                   = {  95061, 437161, 1 }, -- When Reaper's Mark explodes, it deals 20% of the damage dealt to nearby enemies and causes them to deal 5% reduced Physical damage to you for 10 sec.
    swift_and_painful              = {  95032, 443560, 1 }, -- If no enemies are struck by Soul Rupture, you gain 10% Strength for 8 sec. Wave of Souls is 100% more effective on the main target of your Reaper's Mark.
    wave_of_souls                  = {  95036, 439851, 1 }, -- Reaper's Mark sends forth bursts of Shadowfrost energy and back, dealing 16,001 Shadowfrost damage both ways to all enemies caught in its path. Wave of Souls critical strikes cause enemies to take 5% increased Shadowfrost damage for 15 sec, stacking up to 2 times, and it is always a critical strike on its way back.
    wither_away                    = {  95058, 441894, 1 }, -- Blood Plague deals its damage 100% faster, and the second scythe of Exterminate applies Blood Plague.

    -- San'layn
    bloodsoaked_ground             = {  95048, 434033, 1 }, -- While you are within your Death and Decay, your physical damage taken is reduced by 5% and your chance to gain Vampiric Strike is increased by 5%.
    bloody_fortitude               = {  95056, 434136, 1 }, -- Icebound Fortitude reduces all damage you take by up to an additional 20% based on your missing health. Killing an enemy that yields experience or honor reduces the cooldown of Icebound Fortitude by 3 sec.
    frenzied_bloodthirst           = {  95065, 434075, 1 }, -- Essence of the Blood Queen stacks 2 additional times and increases the damage of your Death Coil and Death Strike by 6% per stack.
    gift_of_the_sanlayn            = {  95053, 434152, 1 }, -- While Dancing Rune Weapon is active you gain Gift of the San'layn. Gift of the San'layn increases the effectiveness of your Essence of the Blood Queen by 150%, and Vampiric Strike replaces your Heart Strike for the duration.
    incite_terror                  = {  95040, 434151, 1 }, -- Vampiric Strike and Heart Strike cause your targets to take 1% increased Shadow damage, up to 5% for 15 sec. Vampiric Strike benefits from Incite Terror at 400% effectiveness.
    infliction_of_sorrow           = {  95033, 434143, 1 }, -- When Vampiric Strike damages an enemy affected by your Blood Plague, it extends the duration of the disease by 3 sec, and deals 20% of the remaining damage to the enemy. After Gift of the San'layn ends, your next Heart Strike consumes the disease to deal 130% of their remaining damage to the target.
    newly_turned                   = {  95064, 433934, 1 }, -- Raise Ally revives players at full health and grants you and your ally an absorb shield equal to 20% of your maximum health.
    pact_of_the_sanlayn            = {  95055, 434261, 1 }, -- You store 50% of all Shadow damage dealt into your Blood Beast to explode for additional damage when it expires.
    sanguine_scent                 = {  95055, 434263, 1 }, -- Your Death Coil and Death Strike have a 15% increased chance to trigger Vampiric Strike when damaging enemies below 35% health.
    the_blood_is_life              = {  95046, 434260, 1 }, -- Vampiric Strike has a chance to summon a Blood Beast to attack your enemy for 10 sec. Each time the Blood Beast attacks, it stores a portion of the damage dealt. When the Blood Beast dies, it explodes, dealing 50% of the damage accumulated to nearby enemies and healing the Death Knight for the same amount. Deals reduced damage beyond 8 targets.
    vampiric_aura                  = {  95056, 434100, 1 }, -- Your Leech is increased by 2%. While Lichborne is active, the Leech bonus of this effect is increased by 100%, and it affects 4 allies within 12 yds.
    vampiric_speed                 = {  95064, 434028, 1 }, -- Death's Advance and Wraith Walk movement speed bonuses are increased by 10%. Activating Death's Advance or Wraith Walk increases 4 nearby allies movement speed by 20% for 5 sec.
    vampiric_strike                = {  95051, 433901, 1, "sanlayn" }, -- Your Death Coil and Death Strike have a 25% chance to make your next Heart Strike become Vampiric Strike. Vampiric Strike heals you for 1% of your maximum health and grants you Essence of the Blood Queen, increasing your Haste by 1.0%, up to 5.0% for 20 sec.
    visceral_strength              = {  95045, 434157, 1 }, -- When Crimson Scourge is consumed, you gain 12% Strength for 12 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bloodforged_armor = 5587, -- (410301) Death Strike reduces all Physical damage taken by 20% for 3 sec.
    dark_simulacrum   = 3511, -- (77606) Places a dark ward on an enemy player that persists for 12 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    death_chain       =  609, -- (203173) Chains 3 enemies together, dealing 5275.8 Shadow damage and causing 20% of all damage taken to also be received by the others in the chain. Lasts for 10 sec.
    decomposing_aura  = 3441, -- (199720) All enemies within 8 yards slowly decay, losing up to 3% of their max health every 2 sec. Max 5 stacks. Lasts 6 sec.
    last_dance        =  608, -- (233412) Reduces the cooldown of Dancing Rune Weapon by 50% and its duration by 25%.
    murderous_intent  =  841, -- (207018) You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    rot_and_wither    =  204, -- (202727) Your Death's Due rots enemies each time it deals damage, absorbing healing equal to 100% of damage dealt.
    spellwarden       = 5592, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by 10 sec.
    strangulate       =  206, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for 4 sec.
    walking_dead      =  205, -- (202731) Your Death Grip causes the target to be unable to move faster than normal movement speed for 8 sec.
} )


-- Auras
spec:RegisterAuras( {
    a_feast_of_souls = {
        id = 440861,
        duration = 3600,
        max_stack = 1
    },
    -- Pulling enemies to your location and dealing $323798s1 Shadow damage to nearby enemies every $t1 sec.
    -- https://wowhead.com/beta/spell=315443
    abomination_limb_covenant = {
        id = 315443,
        duration = function () return legendary.abominations_frenzy.enabled and 16 or 12 end,
        tick_time = 1,
        max_stack = 1
    },
    abomination_limb_talent = {
        id = 383269,
        duration = function () return legendary.abominations_frenzy.enabled and 16 or 12 end,
        tick_time = 1,
        max_stack = 1
    },
    abomination_limb = {
        alias = { "abomination_limb_covenant", "abomination_limb_talent" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
    },
    -- Talent: Recently pulled  by Abomination Limb and can't be pulled again.
    -- https://wowhead.com/beta/spell=323710
    abomination_limb_immune = {
        id = 323710,
        duration = 4,
        type = "Magic",
        copy = 383312
    },
    -- Talent: Absorbing up to $w1 magic damage.  Immune to harmful magic effects.
    -- https://wowhead.com/beta/spell=48707
    antimagic_shell = {
        id = 48707,
        duration = function () return ( legendary.deaths_embrace.enabled and 2 or 1 ) * ( ( azerite.runic_barrier.enabled and 1 or 0 ) + ( talent.antimagic_barrier.enabled and 7 or 5 ) ) + ( conduit.reinforced_shell.mod * 0.001 ) end,
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=221562
    asphyxiate = {
        id = 221562,
        duration = 5,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=207167
    blinding_sleet = {
        id = 207167,
        duration = 5,
        mechanic = "disorient",
        type = "Magic",
        max_stack = 1
    },
    -- Next Howling Blast deals Shadowfrost damage.
    bind_in_darkness = {
        id = 443532,
        duration = 3600,
        max_stack = 1,
    },
    blood_draw = {
        id = 454871,
        duration = 8,
        max_stack = 1
    },
    -- You may not benefit from the effects of Blood Draw.
    -- https://wowhead.com/beta/spell=374609
    blood_draw_cd = {
        id = 374609,
        duration = 120,
        max_stack = 1
    },
    -- Draining $w1 health from the target every $t1 sec.
    -- https://wowhead.com/beta/spell=55078
    blood_plague = {
        id = 55078,
        duration = function() return 24 * ( spec.blood and talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.rapid_decomposition.enabled and 0.85 or 1 ) * ( buff.consumption.up and 0.7 or 1 ) * ( spec.blood and talent.wither_away.enabled and 0.5 or 1 ) end,
        type = "Disease",
        max_stack = 1
    },
    -- Absorbs $w1 Physical damage$?a391398 [ and Physical damage increased by $s2%][].
    -- https://wowhead.com/beta/spell=77535
    blood_shield = {
        id = 77535,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Draining $s1 health from the target every $t1 sec.
    -- https://wowhead.com/beta/spell=206931
    blooddrinker = {
        id = 206931,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    blooddrinker_debuff = {
        id = 458687,
        duration = 5.0,
        max_stack = 1,
    },
    -- Strength increased by ${$W1}.1%.
    bloodied_blade = {
        id = 460499,
        duration = 15.0,
        max_stack = 1,
    },
    -- Physical damage taken reduced by $s1%.; Chance to gain Vampiric Strike increased by $434033s2%.
    bloodsoaked_ground = {
        id = 434034,
        duration = 3600,
        max_stack = 1,
    },
    -- Armor increased by ${$w1*$STR/100}.; $?a374715[Haste increased by $w4%.][]
    bone_shield = {
        id = 195181,
        duration = 30.0,
        max_stack = function() return talent.reinforced_bones.enabled and 12 or 10 end,

        -- Affected by:
        -- foul_bulwark[206974] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- improved_bone_shield[374715] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- reinforced_bones[374737] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- reinforced_bones[374737] #1: { 'type': APPLY_AREA_AURA_PARTY, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'value': 37, 'schools': ['physical', 'fire', 'shadow'], 'target': TARGET_UNIT_CASTER, }
    },
    -- Talent: Dealing $196528s1 Shadow damage to nearby enemies every $t3 sec, and healing for $196545s1% of maximum health for each target hit (up to ${$s1*$s4}%).
    -- https://wowhead.com/beta/spell=194844
    bonestorm = {
        id = 194844,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    brittle = {
        id = 374557,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Movement slowed $w1% $?$w5!=0[and Haste reduced $w5% ][]by frozen chains.
    -- https://wowhead.com/beta/spell=45524
    chains_of_ice = {
        id = 45524,
        duration = 8,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    coagulating_blood = PTR and {
        id = 463730,
        duration = 3600,
        max_stack = 100
    } or {},
    -- Talent: Blood Plague damage is increased by $s1%.
    -- https://wowhead.com/beta/spell=391481
    coagulopathy = {
        id = 391481,
        duration = 8,
        max_stack = 5
    },
    -- Your next Chains of Ice will deal $281210s1 Frost damage.
    -- https://wowhead.com/beta/spell=281209
    cold_heart = {
        id = 281209,
        duration = 3600,
        max_stack = 20
    },
    -- Your Blood Plague deals damage $w5% more often.
    consumption = {
        id = 274156,
        duration = 6,
        max_stack = 1,
    },
    -- Talent: Controlled.
    -- https://wowhead.com/beta/spell=111673
    control_undead = {
        id = 111673,
        duration = 300,
        mechanic = "charm",
        type = "Magic",
        max_stack = 1
    },
    -- Your next Death and Decay costs no Runes and generates no Runic Power.
    -- https://wowhead.com/beta/spell=81141
    crimson_scourge = {
        id = 81141,
        duration = 15,
        max_stack = 1,
    },
    -- Talent: Parry chance increased by $s1%.
    -- https://wowhead.com/beta/spell=81256
    dancing_rune_weapon = {
        id = 81256,
        duration = function () return ( pvptalent.last_dance.enabled and 6 or 8 ) + ( talent.everlasting_bond.enabled and 6 or 0 ) end,
        type = "Magic",
        max_stack = 1,
        active_weapons = function() return 
            buff.dancing_rune_weapon.up and 1 + talent.everlasting_bond.rank or 0
        end
    },
    -- Taunted.
    -- https://wowhead.com/beta/spell=56222
    dark_command = {
        id = 56222,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    -- Reduces healing done by $m1%.
    -- https://wowhead.com/beta/spell=327095
    death = {
        id = 327095,
        duration = 6,
        type = "Magic",
        max_stack = 3
    },
    -- $?s206930[Heart Strike will hit up to ${$m3+2} targets.]?s207311[Clawing Shadows will hit ${$55090s4-1} enemies near the target.]?s55090[Scourge Strike will hit ${$55090s4-1} enemies near the target.][Dealing Shadow damage to enemies inside Death and Decay.]
    -- https://wowhead.com/beta/spell=188290
    death_and_decay = {
        id = 188290,
        duration = 10,
        tick_time = function() return talent.rapid_decomposition.enabled and 0.85 or 1 end,
        max_stack = 1,
        copy = "death_and_decay_actual"
    },
    deaths_due = {
        id = 324165,
        duration = function () return legendary.rampant_transference.enabled and 12 or 10 end,
        max_stack = 1,
        copy = "deaths_due_buff"
    },
    -- Talent: The next $w2 healing received will be absorbed.
    -- https://wowhead.com/beta/spell=48743
    death_pact = {
        id = 48743,
        duration = 15,
        max_stack = 1
    },
    -- Your movement speed is increased by $s1%, you cannot be slowed below $s2% of normal speed, and you are immune to forced movement effects and knockbacks.
    -- https://wowhead.com/beta/spell=48265
    deaths_advance = {
        id = 48265,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Weakened by Death's Due, damage dealt to $@auracaster reduced by $s1%.$?a333388[    Toxins accumulate, increasing Death's Due damage by $s3%.][]
    -- https://wowhead.com/beta/spell=324164
    deaths_due_zone = {
        id = 324164,
        duration = 12,
        max_stack = 4
    },
    -- Casting speed reduced by $w1%.
    expelling_shield = {
        id = 440739,
        duration = 6.0,
        max_stack = 1,
    },
    exterminate = {
        id = 441416,
        duration = 30,
        max_stack = function () return talent.reapers_onslaught.enabled and 1 or 2 end,
        copy = { 447954, "exterminate_painful_death" }
    },
    -- Reduces damage dealt to $@auracaster by $m1%.
    -- https://wowhead.com/beta/spell=327092
    famine = {
        id = 327092,
        duration = 6,
        max_stack = 3
    },
    -- Suffering $w1 Frost damage every $t1 sec.
    -- https://wowhead.com/beta/spell=55095
    frost_fever = {
        id = 55095,
        duration = function() return 24 * ( state.spec.frost and talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( state.spec.frost and talent.wither_away.enabled and 0.5 or 1 ) end,
        max_stack = 1
    },
    -- Absorbs damage.
    -- https://wowhead.com/beta/spell=207203
    frost_shield = {
        id = 207203,
        duration = 10,
        max_stack = 1
    },
    -- Movement speed slowed by $s2%.
    -- https://wowhead.com/beta/spell=279303
    frostwyrms_fury = {
        id = 279303,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Dealing $w1 Frost damage every $t1 sec.
    -- https://wowhead.com/beta/spell=274074
    glacial_contagion = {
        id = 274074,
        duration = 14,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Dealing $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=275931
    harrowing_decay = {
        id = 275931,
        duration = 4,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s5%.
    -- https://wowhead.com/beta/spell=206930
    heart_strike_206930 = {
        id = 206930,
        duration = 8,
        max_stack = 1,
        copy = 228645
    },
    heart_strike_228645 = {
        id = 228645,
        duration = 8,
        max_stack = 1
    },
    heart_strike = {
        alias = { "heart_strike_206930", "heart_strike_228645" },
        aliasMode = "first",
        aliasType = "debuff",
        duration = 8
    },
    -- Talent: Your next Death Strike deals an additional $s2% damage.
    -- https://wowhead.com/beta/spell=377656
    heartrend = {
        id = 377656,
        duration = 20,
        max_stack = 1
    },
    -- Deals $s1 Fire damage.
    -- https://wowhead.com/beta/spell=286979
    helchains = {
        id = 286979,
        duration = 15,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage and healing done by your next Death Strike increased by $s1%.
    -- https://wowhead.com/beta/spell=273947
    hemostasis = {
        id = 273947,
        duration = 15,
        max_stack = 5,
        copy = "haemostasis"
    },
    -- Talent: Damage taken reduced by $w3%.  Immune to Stun effects.
    -- https://wowhead.com/beta/spell=48792
    icebound_fortitude = {
        id = 48792,
        duration = 8,
        max_stack = 1
    },
     -- Rooted.
    ice_prison = {
        id = 454787,
        duration = 4.0,
        max_stack = 1,
    },
    -- Attack speed increased by $w1%$?a436687[, and Runic Power spending abilities deal Shadowfrost damage.][.]
    icy_talons = {
        id = 194879,
        duration = 10.0,
        max_stack = function() return talent.dark_talons.enabled and 3 or 1 end,
        copy = { 443586, 436687, 443586, "dark_talons_icy_talons", "dark_talons_shadowfrost" }
    },
    -- Taking $w1% increased Shadow damage from $@auracaster.
    incite_terror = {
        id = 458478,
        duration = 15.0,
        max_stack = 5,
    },
    infliction_of_sorrow = {
        id = 460049,
        duration = 15,
        max_stack = 1
    },
    -- Time between auto-attacks increased by $w1%.
    insidious_chill = {
        id = 391568,
        duration = 30,
        max_stack = 4,
    },
    -- Absorbing up to $w1 magic damage.; Duration of harmful magic effects reduced by $s2%.
    lesser_antimagic_shell = {
        id = 454863,
        duration = function() return 5.0 * ( talent.antimagic_barrier.enabled and 1.4 or 1 ) end,
        max_stack = 1,
    },
    -- Casting speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=326868
    lethargy = {
        id = 326868,
        duration = 6,
        max_stack = 1
    },
    -- Leech increased by $s1%$?a389682[, damage taken reduced by $s8%][] and immune to Charm, Fear and Sleep. Undead.
    -- https://wowhead.com/beta/spell=49039
    lichborne = {
        id = 49039,
        duration = function() return talent.unholy_endurance.enabled and 12 or 10 end,
        tick_time = 1,
        max_stack = 1
    },
    -- Death's Advance movement speed increase by 25%.
    -- https://wowhead.com/beta/spell=391547
    march_of_darkness = {
        id = 391547,
        duration = 3,
        max_stack = 1,
    },
    -- Talent: Auto attacks will heal the victim for $206940s1% of their maximum health.
    -- https://wowhead.com/beta/spell=206940
    mark_of_blood = {
        id = 206940,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    mograines_might = {
        id = 444505,
        duration = 3600,
        max_stack = 1
    },
    -- $@spellaura281238
    -- https://wowhead.com/beta/spell=207256
    obliteration = {
        id = 207256,
        duration = 3600,
        max_stack = 1
    },
    ossified_vitriol = {
        id = 458745,
        duration = 8,
        max_stack = 5
    },
    ossuary = {
        id = 219788,
        duration = 3600,
        max_stack = 1
    },
    -- Grants the ability to walk across water.
    -- https://wowhead.com/beta/spell=3714
    path_of_frost = {
        id = 3714,
        duration = 600,
        tick_time = 0.5,
        max_stack = 1
    },
    -- Talent: Versatility increased by $w1%
    -- https://wowhead.com/beta/spell=374748
    perseverance_of_the_ebon_blade = {
        id = 374748,
        duration = 6,
        max_stack = 1
    },
    -- Suffering $o1 shadow damage over $d and slowed by $m2%.
    -- https://wowhead.com/beta/spell=327093
    pestilence = {
        id = 327093,
        duration = 6,
        tick_time = 1,
        type = "Magic",
        max_stack = 3
    },
    -- Strength increased by $w1%.
    -- https://wowhead.com/beta/spell=51271
    pillar_of_frost = {
        id = 51271,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    reaper_of_souls = {
        id = 469172,
        duration = 12,
        max_stack = 1
    },
    -- You are a prey for the Deathbringer... This effect will explode for $436304s1 Shadowfrost damage for each stack.
    reapers_mark = {
        id = 434765,
        duration = 12.0,
        tick_time = 1.0,
        max_stack = 40,
        copy = "reapers_mark_debuff"
    },
    -- Magical damage taken reduced by $w1%.
    rune_carved_plates = {
        id = 440290,
        duration = 5.0,
        max_stack = 5
    },
    -- Absorb...
    -- https://wowhead.com/beta/spell=116888
    shroud_of_purgatory = {
        id = 116888,
        duration = 3,
        max_stack = 1,
    },
    -- Frost damage taken from the Death Knight's abilities increased by $s1%.
    -- https://wowhead.com/beta/spell=51714
    razorice = {
        id = 51714,
        duration = 20,
        tick_time = 1,
        type = "Magic",
        max_stack = 5
    },
    -- Talent: Strength increased by $w1%
    -- https://wowhead.com/beta/spell=374585
    rune_mastery = {
        id = 374585,
        duration = 8,
        max_stack = 1
    },
    -- Runic Power generation increased by $s1%.
    -- https://wowhead.com/beta/spell=326918
    rune_of_hysteria = {
        id = 326918,
        duration = 8,
        max_stack = 1
    },
    -- Healing for $s1% of your maximum health every $t sec.
    -- https://wowhead.com/beta/spell=326808
    rune_of_sanguination = {
        id = 326808,
        duration = 8,
        max_stack = 1
    },
    -- Absorbs $w1 magic damage.    When an enemy damages the shield, their cast speed is reduced by $w2% for $326868d.
    -- https://wowhead.com/beta/spell=326867
    rune_of_spellwarding = {
        id = 326867,
        duration = 8,
        max_stack = 1
    },
    -- Haste and Movement Speed increased by $s1%.
    -- https://wowhead.com/beta/spell=326984
    rune_of_unending_thirst = {
        id = 326984,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $s1%.
    -- https://wowhead.com/beta/spell=194679
    rune_tap = {
        id = 194679,
        duration = 4,
        max_stack = 1
    },
    -- Talent: Afflicted by Soul Reaper, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage.
    -- https://wowhead.com/beta/spell=343294
    soul_reaper = {
        id = 343294,
        duration = 5,
        tick_time = 5,
        max_stack = 1,
    },
    grim_reaper_soul_reaper = {
        id = 448229,
        duration = 5,
        tick_time = 5,
        max_stack = 1
    },
    -- Silenced.
    strangulate = {
        id = 47476,
        duration = 5.0,
        max_stack = 1,
    },
    -- Damage dealt to $@auracaster reduced by $w1%.
    subduing_grasp = {
        id = 454824,
        duration = 6.0,
        max_stack = 1,
    },
    -- Damage taken from area of effect attacks reduced by an additional $w1%.
    suppression = {
        id = 454886,
        duration = 6.0,
        max_stack = 1,
    },
    -- Covenant: Surrounded by a mist of Anima, increasing your chance to Dodge by $s2% and dealing $311730s1 Shadow damage every $t1 sec to nearby enemies.
    -- https://wowhead.com/beta/spell=311648
    swarming_mist = {
        id = 311648,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    swift_and_painful = {
        id = 443560,
        duration =  8,
        max_stack = 1
    },
    -- Silenced.
    tightening_grasp = {
        id = 374776,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbing $w1 damage.
    -- https://wowhead.com/beta/spell=219809
    tombstone = {
        id = 219809,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Absorbing damage dealt by Blood Plague.
    -- https://wowhead.com/beta/spell=391519
    umbilicus_eternus = {
        id = 391519,
        duration = 10,
        max_stack = 1
    },
    -- Haste increased by $s1%.
    -- https://wowhead.com/beta/spell=207289
    unholy_assault = {
        id = 207289,
        duration = 20,
        type = "Magic",
        max_stack = 1
    },
    -- Deals $s1 Fire damage.
    -- https://wowhead.com/beta/spell=319245
    unholy_pact = {
        id = 319245,
        duration = 15,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Strength increased by $s1%.
    -- https://wowhead.com/beta/spell=53365
    unholy_strength = {
        id = 53365,
        duration = 15,
        max_stack = 1
    },
    -- Vampiric Aura's Leech amount increased by $s1% and is affecting $s2 nearby allies.
    vampiric_aura = {
        id = 434105,
        duration = 3600,
        max_stack = 1,
    },
    -- Talent: Maximum health increased by $s4%. Healing and absorbs received increased by $s1%.
    -- https://wowhead.com/beta/spell=55233
    vampiric_blood = {
        id = 55233,
        duration = function () return 10 + ( talent.improved_vampiric_blood.rank * 2 ) + ( legendary.vampiric_aura.enabled and 3 or 0 ) end,
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    vampiric_speed = {
        id = 434029,
        duration = 5.0,
        max_stack = 1,
    },
    vampiric_strike = {
        id = 433899,
        duration = 3600,
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.  Erupts for $191685s1 damage split among all nearby enemies when the infected dies.
    -- https://wowhead.com/beta/spell=191587
    virulent_plague = {
        id = 191587,
        duration = 27,
        tick_time = 3,
        max_stack = 1
    },
    -- The touch of the spirit realm lingers....
    -- https://wowhead.com/beta/spell=97821
    voidtouched = {
        id = 97821,
        duration = 300,
        max_stack = 1
    },
    -- Leech increased by 15%.
    -- https://wowhead.com/beta/spell=274009
    voracious = {
        id = 274009,
        duration = 8,
        max_stack = 1,
    },
    -- Increases damage taken from $@auracaster by $m1%.
    -- https://wowhead.com/beta/spell=327096
    war = {
        id = 327096,
        duration = 6,
        type = "Magic",
        max_stack = 3
    },
    wave_of_souls = {
        id = 443404,
        duration = 15,
        max_stack = 2,
    },
    -- Talent: Movement speed increased by $w1%.  Cannot be slowed below $s2% of normal movement speed.  Cannot attack.
    -- https://wowhead.com/beta/spell=212552
    wraith_walk = {
        id = 212552,
        duration = 4,
        max_stack = 1
    },
} )


-- TWW
spec:RegisterGear( "tww1", 212005, 212003, 212002, 212001, 212000 )
spec:RegisterAuras( {
    unbreakable = {
        id = 457468,
        duration = 3600,
        max_stack = 1
    },
    unbroken = {
        id = 457473,
        duration = 6,
        max_stack = 1
    },
    piledriver = {
        id = 457506,
        duration = 3600,
        max_stack = 10
    },

    icy_vigor = {
        id = 457189,
        duration = 8,
        max_stack = 1
    },

    unholy_commander = {
        id = 456698,
        duration = 8,
        max_stack = 1
    }
})

-- Tier 29
spec:RegisterGear( "tier29", 200405, 200407, 200408, 200409, 200410 )
-- TODO: Proactively count Bone Shields consumed and proactively model Vigorous Lifeblood proc.
spec:RegisterAura( "vigorous_lifeblood", {
    id = 394570,
    duration = 10,
    max_stack = 1
} )

-- Tier 30
spec:RegisterGear( "tier30", 202464, 202462, 202461, 202460, 202459, 217223, 217225, 217221, 217222, 217224 )
-- 2 pieces (Blood) : Heart Strike and Blood Boil deal 20% increased damage and have a 10% chance to grant Vampiric Blood for 5 sec.
-- 4 pieces (Blood) : When you would gain Vampiric Blood you are infused with Vampiric Strength, granting you 10% Strength for 5 sec. Your Heart Strike and Blood Boil extend the duration of Vampiric Strength by 0.5 sec.
spec:RegisterAura( "vampiric_strength", {
    id = 408356,
    duration = 5,
    max_stack = 1
} )

spec:RegisterGear( "tier31", 207198, 207199, 207200, 207201, 207203 )
-- (2) Consuming Runic Power has a chance to cause your next Heart Strike to apply Ashen Decay, reducing damage dealt to you by $425719s1% and increasing your damage dealt to afflicted targets by $425719s2% for $425719d.
-- (4) Soul Reaper's execute damage and Abomination Limb's damage applies Ashen Decay to enemy targets, and Heart Strike and Blood Boil's direct damage extends Ashen Decay by ${$s1/1000}.1 sec.
spec:RegisterAuras( {
    ashen_decay_proc = {
        id = 425721,
        duration = 20,
        max_stack = 1
    },
    ashen_decay = {
        id = 425719,
        duration = 8,
        max_stack = 1,
        copy = "ashen_decay_debuff"
    }
} )




-- Legacy Legendaries
spec:RegisterGear( "acherus_drapes", 132376 )
spec:RegisterGear( "cold_heart", 151796 ) -- chilled_heart stacks NYI
spec:RegisterGear( "consorts_cold_core", 144293 )
spec:RegisterGear( "death_march", 144280 )
-- spec:RegisterGear( "death_screamers", 151797 )
spec:RegisterGear( "draugr_girdle_of_the_everlasting_king", 132441 )
spec:RegisterGear( "koltiras_newfound_will", 132366 )
spec:RegisterGear( "lanathels_lament", 133974 )
spec:RegisterGear( "perseverance_of_the_ebon_martyr", 132459 )
spec:RegisterGear( "rethus_incessant_courage", 146667 )
spec:RegisterGear( "seal_of_necrofantasia", 137223 )
spec:RegisterGear( "service_of_gorefiend", 132367 )
spec:RegisterGear( "shackles_of_bryndaor", 132365 ) -- NYI (Death Strike heals refund RP...)
spec:RegisterGear( "skullflowers_haemostasis", 144281 )
    spec:RegisterAura( "haemostasis", {
        id = 235559,
        duration = 3600,
        max_stack = 5
    } )

spec:RegisterGear( "soul_of_the_deathlord", 151740 )
spec:RegisterGear( "soulflayers_corruption", 151795 )
spec:RegisterGear( "the_instructors_fourth_lesson", 132448 )
spec:RegisterGear( "toravons_whiteout_bindings", 132458 )
spec:RegisterGear( "uvanimor_the_unbeautiful", 137037 )


spec:RegisterTotem( "ghoul", 1100170 ) -- Texture ID

local TriggerInflictionOfSorrow = setfenv( function ()
    applyBuff( "infliction_of_sorrow" )
end, state )

local TriggerUmbilicusEternus = setfenv( function()
    applyBuff( "umbilicus_eternus" )
end, state )

local BonestormShield = setfenv( function()
    addStack( "bone_shield" )
    gain( min( 0.1, 0.02 * active_enemies ) * health.max, "health" )
end, state )


spec:RegisterHook( "reset_precast", function ()
    if UnitExists( "pet" ) then
        for i = 1, 40 do
            local expires, _, _, _, id = select( 6, UnitDebuff( "pet", i ) )

            if not expires then break end

            if id == 111673 then
                summonPet( "controlled_undead", expires - now )
                break
            end
        end
    end

    -- Reset CDs on any Rune abilities that do not have an actual cooldown.
    for action in pairs( class.abilityList ) do
        local data = class.abilities[ action ]
        if data and data.cooldown == 0 and data.spendType == "runes" then
            setCooldown( action, 0 )
        end
    end

    if talent.umbilicus_eternus.enabled and buff.vampiric_blood.up then
        state:QueueAuraExpiration( "vampiric_blood", TriggerUmbilicusEternus, buff.vampiric_blood.expires )
    end

    if talent.infliction_of_sorrow.enabled and buff.gift_of_the_sanlayn.up then
        state:QueueAuraExpiration( "gift_of_the_sanlayn", TriggerInflictionOfSorrow, buff.gift_of_the_sanlayn.expires )
    end

    if IsActiveSpell( 433899 ) or IsActiveSpell( 433895 ) then
        applyBuff( "vampiric_strike" )
    end

    if buff.bonestorm.up then
        local tick_time = buff.bonestorm.expires
        state:QueueAuraExpiration( "bonestorm", BonestormShield, tick_time )
        tick_time = tick_time - 1

        while( tick_time > query_time ) do
            state:QueueAuraEvent( "bonestorm", BonestormShield, tick_time, "AURA_TICK" )
            tick_time = tick_time - 1
        end
    end
end )

spec:RegisterStateExpr( "save_blood_shield", function ()
    return ( settings.save_blood_shield or false )
end )

spec:RegisterStateExpr( "ibf_damage", function ()
    return health.max * ( settings.ibf_damage or 0 ) * 0.01
end )

spec:RegisterStateExpr( "rt_damage", function ()
    return health.max * ( settings.rt_damage or 0 ) * 0.01
end )

spec:RegisterStateExpr( "vb_damage", function ()
    return health.max * ( settings.vb_damage or 0 ) * 0.01
end )


spec:RegisterStateTable( "death_and_decay", setmetatable(
{ onReset = function( self ) end },
{ __index = function( t, k )
    if k == "ticking" then
        return buff.death_and_decay.up

    elseif k == "remains" then
        return buff.death_and_decay.remains

    end

    return false
end } ) )



-- Abilities
spec:RegisterAbilities( {
    -- Sprout an additional limb, dealing ${$383313s1*13} Shadow damage over $d to all nearby enemies. Deals reduced damage beyond $s5 targets. Every $t1 sec, an enemy is pulled to your location if they are further than $383312s3 yds from you. The same enemy can only be pulled once every $383312d.
    abomination_limb = {
        id = function() return talent.abomination_limb.enabled and 383269 or 315443 end,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "abomination_limb" )
            if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
        end,

        copy = { 383269, 315443, "abomination_limb_talent", "abomination_limb_covenant" }
    },

    -- Talent: Surrounds you in an Anti-Magic Shell for $d, absorbing up to $<shield> magic damage and preventing application of harmful magical effects.$?s207188[][ Damage absorbed generates Runic Power.]
    antimagic_shell = {
        id = 48707,
        cast = 0,
        cooldown = function () return talent.osmosis.enabled and 40 or 60 end,
        gcd = "off",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "antimagic_shell" )
        end,
    },

    -- Talent: Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by $145629m1%. The Anti-Magic Zone lasts for $d or until it absorbs $?a374383[${$<absorb>*1.1}][$<absorb>] damage.
    antimagic_zone = {
        id = 51052,
        cast = 0,
        cooldown = function() return 120 - ( talent.assimilation.enabled and 30 or 0 ) end,
        gcd = "spell",

        talent = "antimagic_zone",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "antimagic_zone" )
        end,
    },

    -- Talent: Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for $d.
    asphyxiate = {
        id = 221562,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "asphyxiate",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "asphyxiate" )
        end,
    },

    -- Talent: Targets in a cone in front of you are blinded, causing them to wander disoriented for $d. Damage may cancel the effect.    When Blinding Sleet ends, enemies are slowed by $317898s1% for $317898d.
    blinding_sleet = {
        id = 207167,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "blinding_sleet",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "blinding_sleet" )
        end,
    },

    -- Talent: Deals $s1 Shadow damage$?s212744[ to all enemies within $A1 yds.][ and infects all enemies within $A1 yds with Blood Plague.    |Tinterface\icons\spell_deathknight_bloodplague.blp:24|t |cFFFFFFFFBlood Plague|r  $@spelldesc55078]
    blood_boil = {
        id = 50842,
        cast = 0,
        charges = 2,
        cooldown = 7.5,
        recharge = 7.5,
        hasteCD = true,
        school = function() return talent.bind_in_darkness.enabled and "shadowfrost" or "physical" end,
        gcd = "spell",

        talent = "blood_boil",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "blood_plague" )
            active_dot.blood_plague = active_enemies

            if talent.bind_in_darkness.enabled and debuff.reapers_mark.up then applyDebuff( "target", "reapers_mark", nil, debuff.reapers_mark.stack + 2 ) end

            if talent.hemostasis.enabled then
                addStack( "hemostasis", nil, min( 5, active_enemies ) )
            end

            if set_bonus.tier31_4pc > 0 and debuff.ashen_decay.up then
                debuff.ashen_decay.expires = debuff.ashen_decay.expires + 1
            end


            -- Legacy
            if legendary.superstrain.enabled then
                applyDebuff( "target", "frost_fever" )
                active_dot.frost_fever = active_enemies

                applyDebuff( "target", "virulent_plague" )
                active_dot.virulent_plague = active_enemies
            end
            if set_bonus.tier30_4pc > 0 and buff.vampiric_strength.up then buff.vampiric_strength.expires = buff.vampiric_strength.expires + 0.5 end
            if conduit.debilitating_malady.enabled then
                addStack( "debilitating_malady", nil, 1 )
            end
        end,

        auras = {
            -- Conduit
            debilitating_malady = {
                id = 338523,
                duration = 6,
                max_stack = 3
            }
        }
    },

    -- Talent: Consume the essence around you to generate $s1 Rune.    Recharge time reduced by $s2 sec whenever a Bone Shield charge is consumed.
    blood_tap = {
        id = 221699,
        cast = 0,
        charges = 2,
        cooldown = 60,
        recharge = 60,
        gcd = "off",

        talent = "blood_tap",
        startsCombat = false,

        handler = function ()
            gain( 1, "runes" )
        end
    },

    -- Drains $o1 health from the target over $d. The damage they deal to you is reduced by $s2% for the duration and $458687d after channeling it fully.; You can move, parry, dodge, and use defensive abilities while channeling this ability.; Generates ${$s3*4/10} additional Runic Power over the duration.
    blooddrinker = {
        id = 206931,
        cast = 3,
        channeled = true,
        cooldown = 30,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "blooddrinker",
        startsCombat = true,

        start = function ()
            applyDebuff( "target", "blooddrinker" )
        end,
    },

    -- Consume your Bone Shield charges to create a whirl of bone and gore that batters all nearby enemies, dealing $196528s1 Shadow damage every $t3 sec, and healing you for $196545s1% of your maximum health every time it deals damage (up to ${$s1*$s4}%). Deals reduced damage beyond $196528s2 targets.; Lasts $d per Bone Shield charge spent and rapidly regenerates a Bone Shield every $t3 sec.
    bonestorm = {
        id = 194844,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "bonestorm",
        startsCombat = true,

        buff = "bone_shield",

        handler = function ()
            local consume = min( 5, buff.bone_shield.stack )
            gain( consume * 0.02 * health.max, "health" )

            local dur = 2 * consume
            applyBuff( "bonestorm", dur )
            removeStack( "bone_shield", consume )

            for i = 1, dur do
                state:QueueAuraEvent( "bonestorm", BonestormShield, query_time + i, i == dur and "AURA_EXPIRATION" or "AURA_TICK" )
            end

            if set_bonus.tww1_4pc > 0 then
                if buff.bone_shield.up then applyBuff( "piledriver", nil, buff.bone_shield.stack )
                else removeBuff( "piledriver" ) end
            end
        end,

        -- TODO Bone Shield regeneration (1 per sec.)
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 196528, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Talent: Shackles the target $?a373930[and $373930s1 nearby enemy ][]with frozen chains, reducing movement speed by $s1% for $d.
    chains_of_ice = {
        id = 45524,
        cast = 0,
        cooldown = function() return talent.ice_prison.enabled and 12 or 0 end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,

        max_targets = function () return talent.proliferating_chill.enabled and 2 or 1 end,

        handler = function ()
            applyDebuff( "target", "chains_of_ice" )
            if talent.ice_prison.enabled then applyDebuff( "target", "ice_prison" ) end
            if talent.proliferating_chill.enabled then active_dot.chains_of_ice = min( true_active_enemies, active_dot.chains_of_ice + 1 ) end
        end,
    },

    -- Strikes all enemies in front of you with a hungering attack that deals $sw1 Physical damage and heals you for ${$e1*100}% of that damage. Deals reduced damage beyond $s3 targets.; Causes your Blood Plague damage to occur $s5% more quickly for $d. ; Generates $s4 Runes.
    consumption = {
        id = 274156,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "consumption",
        startsCombat = true,

        handler = function ()
            gain( 2, "runes" )
            applyBuff( "consumption" )
            if talent.carnage.enabled then applyBuff( "blood_shield" ) end
        end,
    },

    -- Talent: Dominates the target undead creature up to level $s1, forcing it to do your bidding for $d.
    control_undead = {
        id = 111673,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "control_undead",
        startsCombat = false,

        usable = function () return target.is_undead, "requires undead target" end,

        handler = function ()
            summonPet( "controlled_undead" )
        end,
    },

    -- Talent: Summons a rune weapon for $81256d that mirrors your melee attacks and bolsters your defenses.    While active, you gain $81256s1% parry chance.
    dancing_rune_weapon = {
        id = 49028,
        cast = 0,
        cooldown = function () return pvptalent.last_dance.enabled and 60 or 120 end,
        gcd = "spell",

        talent = "dancing_rune_weapon",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "dancing_rune_weapon" )
            if talent.gift_of_the_sanlayn.enabled then applyBuff( "gift_of_the_sanlayn", buff.dancing_rune_weapon.remains ) end
            if talent.insatiable_blade.enabled then addStack( "bone_shield", nil, buff.dancing_rune_weapon.up and 10 or 5 ) end

            if set_bonus.tww1_4pc > 0 then
                if buff.bone_shield.up then applyBuff( "piledriver", nil, buff.bone_shield.stack )
                else removeBuff( "piledriver" ) end
            end

            -- legacy
            if azerite.eternal_rune_weapon.enabled then applyBuff( "dancing_rune_weapon" ) end
            if legendary.crimson_rune_weapon.enabled then addStack( "bone_shield", nil, buff.dancing_rune_weapon.up and 10 or 5 ) end
        end,
    },

    -- Command the target to attack you.
    dark_command = {
        id = 56222,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,

        nopvptalent = "murderous_intent",

        handler = function ()
            applyDebuff( "target", "dark_command" )
        end,
    },


    dark_simulacrum = {
        id = 77606,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 0,
        spendType = "runic_power",

        startsCombat = true,
        texture = 135888,

        pvptalent = "dark_simulacrum",

        usable = function ()
            if not target.is_player then return false, "target is not a player" end
            return true
        end,

        handler = function ()
            applyDebuff( "target", "dark_simulacrum" )
        end,
    },

    -- Corrupts the targeted ground, causing ${$341340m1*11} Shadow damage over $d to targets within the area.$?!c2[; While you remain within the area, your ][]$?s223829&!c2[Necrotic Strike and ][]$?c1[Heart Strike will hit up to $188290m3 additional targets.]?s207311&!c2[Clawing Shadows will hit up to ${$55090s4-1} enemies near the target.]?!c2[Scourge Strike will hit up to ${$55090s4-1} enemies near the target.][; While you remain within the area, your Obliterate will hit up to $316916M2 additional $Ltarget:targets;.]
    death_and_decay = {
        id = 43265,
        noOverride = 324128,
        cast = 0,
        charges = function () if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 15,
        recharge = function () if talent.deaths_echo.enabled then return 15 end end,
        gcd = "spell",

        spend = function () return buff.crimson_scourge.up and 0 or 1 end,
        spendType = "runes",

        startsCombat = true,

        handler = function ()
            if buff.crimson_scourge.up then
                if talent.perseverance_of_the_ebon_blade.enabled then applyBuff( "perseverance_of_the_ebon_blade" ) end
                removeBuff( "crimson_scourge" )
                if talent.relish_in_blood.enabled then
                    gain( 10, "runic_power" ) 
                    gain( 0.25 * buff.bone_shield.stack, "health" )
                end
            end

            if legendary.phearomones.enabled and buff.death_and_decay.down then
                stat.haste = stat.haste + ( state.spec.blood and 0.1 or 0.15 )
            end

            applyBuff( "death_and_decay_actual" )
        end,
    },


    death_chain = {
        id = 203173,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = true,
        texture = 1390941,

        pvptalent = "death_chain",

        handler = function ()
            applyDebuff( "target", "death_chain" )
            active_dot.death_chain = min( 3, active_enemies )
        end,
    },

    -- Fires a blast of unholy energy at the target$?a377580[ and $377580s2 additional nearby target][], causing $47632s1 Shadow damage to an enemy or healing an Undead ally for $47633s1 health.$?s390268[    Increases the duration of Dark Transformation by $390268s1 sec.][]
    death_coil = {
        id = 47541,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        startsCombat = false,

        handler = function ()
        end,
    },

    -- Opens a gate which you can use to return to Ebon Hold.    Using a Death Gate while in Ebon Hold will return you back to near your departure point.
    death_gate = {
        id = 50977,
        cast = 4,
        cooldown = 60,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = false,

        handler = function ()
        end,
    },

    -- Harnesses the energy that surrounds and binds all matter, drawing the target toward you$?a389679[ and slowing their movement speed by $389681s1% for $389681d][]$?s137008[ and forcing the enemy to attack you][].
    death_grip = {
        id = 49576,
        cast = 0,
        charges = function () if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 15,
        recharge = function () if talent.deaths_echo.enabled then return 15 end end,
        gcd = "off",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "death_grip" )
            setDistance( 5 )

            if legendary.grip_of_the_everlasting.enabled and buff.grip_of_the_everlasting.down then
                applyBuff( "grip_of_the_everlasting" )
            else
                removeBuff( "grip_of_the_everlasting" )
            end

            if conduit.unending_grip.enabled then applyDebuff( "target", "unending_grip" ) end
        end,

        auras = {
            unending_grip = {
                id = 338311,
                duration = 5,
                max_stack = 1
            }
        }
    },

    -- Talent: Create a death pact that heals you for $s1% of your maximum health, but absorbs incoming healing equal to $s3% of your max health for $d.
    death_pact = {
        id = 48743,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "death_pact",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyDebuff( "target", "death_pact" )
        end,
    },

    -- Talent: Focuses dark power into a strike$?s137006[ with both weapons, that deals a total of ${$s1+$66188s1}][ that deals $s1] Physical damage and heals you for ${$s2}.2% of all damage taken in the last $s4 sec, minimum ${$s3}.1% of maximum health.
    death_strike = {
        id = 49998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return ( ( talent.ossuary.enabled and buff.bone_shield.stack >= 5 ) and 40 or 45 ) - ( talent.improved_death_strike.enabled and 5 or 0 ) - ( buff.blood_draw.up and 10 or 0 ) end,
        spendType = "runic_power",

        talent = "death_strike",
        startsCombat = true,

        handler = function ()

            applyBuff( "blood_shield" ) -- gain absorb shield
            gain( health.max * max( 0.074,  0.01 * buff.coagulating_blood.stack * 0.25 ) * ( talent.voracious.enabled and 1.15 or 1 ) * ( talent.improved_death_strike.enabled and 1.05 or 1 ) * ( talent.hemostasis.enabled and ( 1.08 * buff.hemostasis.stack ) or 1 ), "health" )
            removeBuff( "coagulating_blood" )

            if talent.hemostasis.enabled then removeBuff( "hemostasis" ) end
            if talent.coagulopathy.enabled then addStack( "coagulopathy" ) end
            if talent.voracious.enabled then applyBuff( "voracious" ) end
            if talent.heartrend.enabled then removeBuff( "heartrend" ) end
        end,
    },

    -- For $d, your movement speed is increased by $s1%, you cannot be slowed below $s2% of normal speed, and you are immune to forced movement effects and knockbacks.    |cFFFFFFFFPassive:|r You cannot be slowed below $124285s1% of normal speed.
    deaths_advance = {
        id = 48265,
        cast = 0,
        charges = function () if talent.deaths_echo.enabled then return 2 end end,
        cooldown = function () return azerite.march_of_the_damned.enabled and 40 or 45 end,
        recharge = function () if talent.deaths_echo.enabled then return ( azerite.march_of_the_damned.enabled and 40 or 45 ) end end,
        gcd = "off",

        startsCombat = false,

        handler = function ()
            applyBuff( "deaths_advance" )
            if talent.march_of_darkness.enabled then applyBuff( "march_of_darkness" ) end
            if conduit.fleeting_wind.enabled then applyBuff( "fleeting_wind" ) end
        end,

        auras = {
            -- Conduit
            fleeting_wind = {
                id = 338093,
                duration = 3,
                max_stack = 1
            }
        }
    },

    -- Talent: Reach out with necrotic tendrils, dealing $s1 Shadow damage and applying Blood Plague to your target and generating $s3 Bone Shield charges.    |Tinterface\icons\spell_deathknight_bloodplague.blp:24|t |cFFFFFFFFBlood Plague|r  $@spelldesc55078
    deaths_caress = {
        id = 195292,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,

        handler = function ()
            local RWStrikes = 1 + buff.dancing_rune_weapon.active_weapons -- the 1 is your actual spell hit
            applyDebuff( "target", "blood_plague" )
            addStack( "bone_shield", nil, ( 2 * RWStrikes ) )

            if set_bonus.tww1_4pc > 0 then
                if buff.bone_shield.up then applyBuff( "piledriver", nil, buff.bone_shield.stack )
                else removeBuff( "piledriver" ) end
            end
        end,
    },

    -- Talent: Shadowy tendrils coil around all enemies within $A2 yards of a hostile or friendly target, pulling them to the target's location.
    gorefiends_grasp = {
        id = 108199,
        cast = 0,
        cooldown = function () return talent.tightening_grasp.enabled and 90 or 120 end,
        gcd = "spell",

        talent = "gorefiends_grasp",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            if talent.tightening_grasp.enabled then applyDebuff( "target", "tightening_grasp" ) end
        end,
    },

    -- Talent: Instantly strike the target and 1 other nearby enemy, causing $s2 Physical damage, and reducing enemies' movement speed by $s5% for $d$?s316575[    |cFFFFFFFFGenerates $s3 bonus Runic Power][]$?s221536[, plus ${$210738s1/10} Runic Power per additional enemy struck][].|r
    heart_strike = {
        id = function () return ( buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up ) and 433895 or 206930 end,
        known = 206930,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "heart_strike",
        texture = function () return ( buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up ) and 5927645 or 135675 end,
        startsCombat = true,

        max_targets = function () return buff.death_and_decay.up and talent.cleaving_strikes.enabled and 5 or 2 end,

        handler = function ()
            local strikes = 1 + buff.dancing_rune_weapon.active_weapons
            if talent.heartbreaker.enabled then
                gain( 15 + ( talent.heartbreaker.enabled and ( 2 * min( action.heart_strike.max_targets, true_active_enemies ) ) or 0 ) + 3 * buff.dancing_rune_weapon.active_weapons, "runic_power" )
            end

            -- San'Layn stuff
            if buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up then
                gain( 0.02 * health.max, "health" )
                addStack( "essence_of_the_blood_queen" ) -- TODO: mod haste

                if talent.infliction_of_sorrow.enabled and dot.blood_plague.ticking then
                    dot.blood_plague.expires = dot.blood_plague.expires + 3
                end

                removeBuff( "vampiric_strike" )
            else
                applyDebuff( "target", "heart_strike" )
                active_dot.heart_strike = min( true_active_enemies, active_dot.heart_strike + action.heart_strike.max_targets )

            end

            if talent.infliction_of_sorrow.enabled and buff.infliction_of_sorrow.up then
                removeDebuff( "target", "blood_plague" )
                removeBuff( "infliction_of_sorrow" )
            end
            if talent.incite_terror.enabled then applyDebuff( "target", "incite_terror", nil, min( debuff.incite_terror.stack + 1, debuff.incite_terror.max_stack ) ) end

            -- PvP
            if pvptalent.blood_for_blood.enabled then
                health.current = health.current - 0.03 * health.max
            end 

            --- Legacy
            if set_bonus.tier31_4pc > 0 and debuff.ashen_decay.up and set_bonus.tier31_4pc > 0 then debuff.ashen_decay.expires = debuff.ashen_decay.expires + 1 end
            if azerite.deep_cuts.enabled then applyDebuff( "target", "deep_cuts" ) end
            if legendary.gorefiends_domination.enabled and cooldown.vampiric_blood.remains > 0 then gainChargeTime( "vampiric_blood", 2 ) end
            if set_bonus.tier31_4pc > 0 and buff.ashen_decay_proc.up then
                applyDebuff( "target", "ashen_decay" )
                removeBuff( "ashen_decay_proc" )
            end
            if set_bonus.tier30_4pc > 0 and  buff.vampiric_strength.up then buff.vampiric_strength.expires = buff.vampiric_strength.expires + 0.5 end
        end,


        bind = "vampiric_strike",
        copy = { 206930, "vampiric_strike", 433895 }
    },

    -- Talent: Your blood freezes, granting immunity to Stun effects and reducing all damage you take by $s3% for $d.
    icebound_fortitude = {
        id = 48792,
        cast = 0,
        cooldown = function () return 180 - ( talent.acclimation.enabled and 60 or 0 ) - ( azerite.cold_hearted.enabled and 15 or 0 ) + ( conduit.chilled_resilience.mod * 0.001 ) end,
        gcd = "off",

        talent = "icebound_fortitude",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "icebound_fortitude" )
        end,
    },

    -- Draw upon unholy energy to become Undead for $d, increasing Leech by $s1%$?a389682[, reducing damage taken by $s8%][], and making you immune to Charm, Fear, and Sleep.
    lichborne = {
        id = 49039,
        cast = 0,
        cooldown = function() return 120 - ( talent.deaths_messenger.enabled and 30 or 0 ) end,
        gcd = "off",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "lichborne" )
            if conduit.hardened_bones.enabled then applyBuff( "hardened_bones" ) end
        end,

        auras = {
            -- Conduit
            hardened_bones = {
                id = 337973,
                duration = 10,
                max_stack = 1
            }
        }

        -- deaths_messenger[437122] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Talent: Places a Mark of Blood on an enemy for $d. The enemy's damaging auto attacks will also heal their victim for $206940s1% of the victim's maximum health.
    mark_of_blood = {
        id = 206940,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        talent = "mark_of_blood",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mark_of_blood" )
        end,
    },

    -- Talent: Smash the target, dealing $s2 Physical damage and generating $s3 charges of Bone Shield.    |Tinterface\icons\ability_deathknight_boneshield.blp:24|t |cFFFFFFFFBone Shield|r  $@spelldesc195181
    marrowrend = {
        id = 195182,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return talent.exterminate.enabled and buff.exterminate.up and 1 or 2 end,
        spendType = "runes",

        talent = "marrowrend",
        startsCombat = true,

        handler = function ()
            local RWStrikes = 1 + buff.dancing_rune_weapon.active_weapons -- the 1 is your actual spell hit
            addStack( "bone_shield", 30, buff.bone_shield.stack + 3 * RWStrikes )

            if talent.exterminate.enabled and buff.exterminate.up then
                removeStack( "exterminate" )
                applyDebuff( "target", "blood_plague" )
            end

            if talent.ossified_vitriol.enabled then removeBuff( "ossified_vitriol" ) end

            if set_bonus.tww1_4pc > 0 then
                if buff.bone_shield.up then applyBuff( "piledriver", nil, buff.bone_shield.stack )
                else removeBuff( "piledriver" ) end
            end

            -- Legacy

            if azerite.bones_of_the_damned.enabled then applyBuff( "bones_of_the_damned" ) end
        end,
    },

    -- Talent: Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for $d.
    mind_freeze = {
        id = 47528,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        talent = "mind_freeze",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            if conduit.spirit_drain.enabled then gain( conduit.spirit_drain.mod * 0.1, "runic_power" ) end
            if talent.coldthirst.enabled then
                gain( 10, "runic_power" )
                reduceCooldown( "mind_freeze", 3 )
            end
            interrupt()
        end,
    },


    murderous_intent = {
        id = 207018,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        startsCombat = true,
        texture = 136088,

        pvptalent = "murderous_intent",

        handler = function ()
            applyDebuff( "target", "focused_assault" )
        end,
    },

    -- Activates a freezing aura for $d that creates ice beneath your feet, allowing party or raid members within $a1 yards to walk on water.    Usable while mounted, but being attacked or damaged will cancel the effect.
    path_of_frost = {
        id = 3714,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = false,

        handler = function ()
            applyBuff( "path_of_frost" )
        end,
    },

    --[[ Pours dark energy into a dead target, reuniting spirit and body to allow the target to reenter battle with $s2% health and at least $s1% mana.
    raise_ally = {
        id = 61999,
        cast = 0,
        cooldown = 600,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            -- trigger voidtouched [97821]
        end,
    }, ]]

    -- Talent: Raises a $?s58640[geist][ghoul] to fight by your side.  You can have a maximum of one $?s58640[geist][ghoul] at a time.  Lasts $46585d.
    raise_dead = {
        id = 46585,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "raise_dead",
        startsCombat = false,

        toggle = "cooldowns",

        usable = function () return not pet.alive, "cannot have an active pet" end,

        handler = function()
            summonPet( "ghoul" )
        end,
    },

    -- Viciously slice into the soul of your enemy, dealing $?a137008[$s1][$s4] Shadowfrost damage and applying Reaper's Mark.; Each time you deal Shadow or Frost damage, add a stack of Reaper's Mark. After $434765d or reaching $434765u stacks, the mark explodes, dealing $?a137008[$436304s1][$436304s2] damage per stack.; Reaper's Mark travels to an unmarked enemy nearby if the target dies, or explodes below 35% health when there are no enemies to travel to. This explosion cannot occur again on a target for $443761d.
    reapers_mark = {
        id = 439843,
        cast = 0.0,
        cooldown = function() return 60.0 - ( 15 * talent.reapers_onslaught.rank ) end,
        gcd = "spell",

        spend = 2,
        spendType = 'runes',

        talent = "reapers_mark",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "reapers_mark" )
            if talent.grim_reaper.enabled then
                addStack( "bone_shield", nil,  3 )
            end
            if talent.reaper_of_souls.enabled then
                setCooldown( "soul_reaper", 0 )
                applyBuff( "reaper_of_souls" )
            end
        end,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 0.8, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 434765, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'resource': runic_power, }
        -- #3: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 1.5, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Strike the target for $s1 Physical damage. This attack cannot be dodged, blocked, or parried.
    rune_strike = {
        id = 316239,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        notalent = "heart_strike",
        startsCombat = true,

        handler = function ()
        end,
    },

    -- Talent: Reduces all damage taken by $s1% for $d.
    rune_tap = {
        id = 194679,
        cast = 0,
        charges = function () if level > 43 then return 2 end end,
        cooldown = 25,
        recharge = function () if level > 43 then return 25 end end,
        gcd = "off",

        spend = 1,
        spendType = "runes",

        talent = "rune_tap",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "rune_tap" )
        end,
    },

    -- Talent: Sacrifice your ghoul to deal $327611s1 Shadow damage to all nearby enemies and heal for $s1% of your maximum health. Deals reduced damage beyond $327611s2 targets.
    sacrificial_pact = {
        id = 327574,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 20,
        spendType = "runic_power",

        talent = "sacrificial_pact",
        startsCombat = false,

        toggle = "defensives",

        usable = function () return pet.ghoul.alive, "requires an undead pet" end,

        handler = function ()
            gain( 0.25 * health.max, "health" )
            pet.ghoul.expires = query_time - 0.01
        end,
    },

    -- Talent: Strike an enemy for $s1 Shadowfrost damage and afflict the enemy with Soul Reaper.     After $d, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    soul_reaper = {
        id = 343294,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function() return buff.reaper_of_souls.up and 0 or 1 end,
        spendType = "runes",

        talent = "soul_reaper",
        startsCombat = true,

        handler = function ()
            if buff.reaper_of_souls.up then removeBuff( "reaper_of_souls" ) end
            applyBuff( "soul_reaper" )
        end,
    },


    strangulate = {
        id = 47476,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0,
        spendType = "runes",

        toggle = "interrupts",
        pvptalent = "strangulate",
        interrupt = true,

        startsCombat = true,
        texture = 136214,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "strangulate" )
        end,
    },

    -- Talent: Consume up to $s5 Bone Shield charges. For each charge consumed, you gain $s3 Runic Power and absorb damage equal to $s4% of your maximum health for $d.
    tombstone = {
        id = 219809,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "tombstone",
        startsCombat = true,

        buff = "bone_shield",

        handler = function ()
            local bs = min( 5, buff.bone_shield.stack )


            if talent.insatiable_blade.enabled then reduceCooldown( "dancing_rune_weapon", bs * 5 ) end
            if talent.blood_tap.enabled then  gainChargeTime( "blood_tap", bs * 2 ) end
            removeStack( "bone_shield", bs )
            gain( 6 * bs, "runic_power" )

            if set_bonus.tww1_4pc > 0 then
                if buff.bone_shield.up then applyBuff( "piledriver", nil, buff.bone_shield.stack )
                else removeBuff( "piledriver" ) end
            end

            applyBuff( "tombstone" )

            -- Legacy
            if set_bonus.tier21_2pc == 1 then
                cooldown.dancing_rune_weapon.expires = max( 0, cooldown.dancing_rune_weapon.expires - ( 3 * bs ) )
            end

        end,
    },

    -- Talent: Embrace your undeath, increasing your maximum health by $s4% and increasing all healing and absorbs received by $s1% for $d.
    vampiric_blood = {
        id = 55233,
        cast = 0,
        cooldown = function () return 90 * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) end,
        gcd = "off",

        talent = "vampiric_blood",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "vampiric_blood" )
            if set_bonus.tier30_4pc > 0 then applyBuff( "vampiric_strength" ) end
            if legendary.gorefiends_domination.enabled then gain( 45, "runic_power" ) end
            if talent.umbilicus_eternus.enabled then state:QueueAuraExpiration( "vampiric_blood", TriggerUmbilicusEternus, buff.vampiric_blood.expires ) end
        end,
    },

    -- Talent: Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by $s1% for $d. Taking any action cancels the effect.    While active, your movement speed cannot be reduced below $m2%.
    wraith_walk = {
        id = 212552,
        cast = 4,
        fixedCast = true,
        channeled = true,
        cooldown = 60,
        gcd = "spell",

        talent = "wraith_walk",
        startsCombat = false,

        start = function ()
            applyBuff( "wraith_walk" )
        end,
    },
} )


spec:RegisterRanges( "death_strike", "mind_freeze", "death_coil" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    potion = "tempered_potion",

    package = "Blood",
} )


spec:RegisterSetting( "save_blood_shield", true, {
    name = strformat( "Save %s", Hekili:GetSpellLinkWithTexture( spec.auras.blood_shield.id ) ),
    desc = strformat( "If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r) will try to avoid letting your %s fall off during "
        .. "lulls in damage.", Hekili:GetSpellLinkWithTexture( spec.auras.blood_shield.id ) ),
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "death_strike_pool_amount", 65, {
    name = strformat( "%s %s", Hekili:GetSpellLinkWithTexture( spec.abilities.death_strike.id ), _G.POWER_TYPE_RUNIC_POWER ),
    desc = strformat( "The default priority will (usually) avoid spending %s on %s unless you have pooled at least this much.", _G.POWER_TYPE_RUNIC_POWER, Hekili:GetSpellLinkWithTexture( spec.abilities.death_strike.id ) ),
    type = "range",
    min = 40,
    max = 125,
    step = 1,
    width = "full"
} )

spec:RegisterSetting( "ibf_damage", 40, {
    name = strformat( "%s Damage Threshold", Hekili:GetSpellLinkWithTexture( spec.abilities.icebound_fortitude.id ) ),
    desc = strformat( "When set above zero, the default priority can recommend %s if you've lost this percentage of your maximum health in the past 5 seconds.\n\n"
        .. "|W%s|w also requires the Defensives toggle by default.", Hekili:GetSpellLinkWithTexture( spec.abilities.icebound_fortitude.id ),
        spec.abilities.icebound_fortitude.name ),
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "rt_damage", 30, {
    name = strformat( "%s Damage Threshold", Hekili:GetSpellLinkWithTexture( spec.abilities.rune_tap.id ) ),
    desc = strformat( "When set above zero, the default priority can recommend %s if you've lost this percentage of your maximum health in the past 5 seconds.\n\n"
        .. "|W%s|w also requires the Defensives toggle by default.", Hekili:GetSpellLinkWithTexture( spec.abilities.rune_tap.id ), spec.abilities.rune_tap.name ),
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "vb_damage", 50, {
    name = strformat( "%s Damage Threshold", Hekili:GetSpellLinkWithTexture( spec.abilities.vampiric_blood.id ) ),
    desc = strformat( "When set above zero, the default priority can recommend %s if you've lost this percentage of your maximum health in the past 5 seconds.\n\n"
        .. "|W%s|w also requires the Defensives toggle by default.", Hekili:GetSpellLinkWithTexture( spec.abilities.vampiric_blood.id ),
        spec.abilities.vampiric_blood.name ),
    type = "range",
    min = 0,
    max = 200,
    step = 1,
    width = "full",
} )

spec:RegisterPack( "Blood", 20250202, [[Hekili:v3r)VTTn2)wcoax72upl562UbBdCT7gqlUB4qtV1FZs0w0XcvwYtsoPzWq)TFps9fffFKYFK0oGISerY3389ff1wyT4ZlUXJKsx872JSNmc(XqlBRjwVAXnPpSJU4MDKvFLCl8lHKTWpFxquKh7Ppeer8yRojAF8kyKB83UpGK6hf((yY60f3SCVFq6hcxSunggdlDhDf84jJwCZgFppA(CPjRwCdBUVCKn8VFjZ9F65b)iCfnjnMeK5(Esqq2hZ(imPx9slRxAZMeG)3N5UFhdxIdYHWNGLgftZC)W7(TRZC)J3b)4tFUEAJEP9pdtZYA4OHtKGL7lyRNSJgN5gTggmAFqI4sh9AyP)hsCC09X0qGu)Pm3)13sPXB9d5aWBFSF4TzU)6N(s16g9ZV0(T6xNWuhXM6Fq2UZp2FvMlxl0y8j5sGwcGrVnhnkh7nV0(vWyFEdqJFHaS3x8t34hU4Ma)K0eUYLegqEie(1FNBQqdjldOElE3IBI2bdtb9mzftPV4M7iX(Srz)wWEkF0uGVtg6rjPBCaLN)xPo7IIcCiBJ2hMYxJtUHvJ54TF7UY5KcwihnQThHc7DXuhAscfmNKXZ4JgpVrenlJcPojB8PbEoX01X0Kno5ZdG9RoAy3pZ12IB9b7tccCsjX3sttgUHsItl4Mm3NN5MscOHP5pFzmL8vA8WcmXh3oZDGiDkcaN4DoEX3ZOWjsu4QyFWw0NW2jVE9WvrKB3heTdeLpmmMUL4hMK5oDwM7TR8gUL8TAwruEZG8RLGSY5X34h7VlFO)xcWB)kBCW2TGv9HnFpaEBkT)DVHlRHbac52i(wS0Omx63GTj0HICqLPyc5oQZs2Yl0uzU9YC5mO4thUFhYak5CGhFdQ07QsWuBEaGxskK4SIagmjmq9wDGYlkTGG2fake6Wu)vFLZ6hoK52xXeQPyWb3OA2YJeUcwOt8EGUUhCWffYz7b1KwoCwg5hWORFwVbIA4vdSDr8)laiRrOqAhnvjGya5okN4XMsdnZ4A8Ukkmb2NxHCzhz1iVFPKHBxsc9C8ORipKlveSheuKjPq8Xm35zUt4tyf4DZl6(q9u4CGcTNiiNbiYcqTLtGYU7Qjqay(RapO3ZIfXaI1O3IVTZs2FwNuyC2G9ioxzvdEr3gCWl7sRTjFBbPm1wnghIgCb5hUoWNVCNO1ojrSiNn2PQdFTiFUxPYrJj(jq8akKtJabWM2BeNgzzep4mJec83UuEY4BDbBRRmSXdNl6S5NGbcaM1(R8tZnugp6OnpRXOAx)Z5rwEUc))PrBxcMZH5YzdUnqa(mjOZPgbHyziCWqiDtPl9)CpLMllzodnnVgiBCtKnqgFykTkezuI(AjmiSvO9s5P9G7MSKQURiLWc76sZOUPMNwBx00XsMBzYid7sQt1gkAe2LwQn9nl7YYg35CzSVsxL1b(Yvuy7nMkWnOzOPzZdyhosqnlIHMsYgQ0TvP1ZzlCx6FFzRECdCTMlnmYpnUhpouEyDhAiDRpfaflKgNQYt2fegBPoPro7wL6mEcNRNOACp)8Wvf5)a1KgascwnB1K5l4RvGkfMfNmXJNzYTDFTokN2YvwrQAk1mmPzLMvrQ61728b6jfyFkiSJBSbJ7)AGMTzgc0QYTsLnGUOW95)ROGeHeVQRhPoMs9Gfb4yy4k9Ro3TmEoWQgSraRr4jeylxMIUavnYKbX9nEjbNOINjGALcOAx1Iv2IBgGNUYQnSny1bIlSyxVpGTLjFuh2UVgfcPP4bB80a6w0kjTNuw9JXJv2LCzhJh3bnLSUKpwhznDLdmgp2XzrAxYufvN6xAHf3sw3VaFS)DRjsVUZn354BCu)8mSFYAUZjfBtvT7t6uvt4Usnywr8Eq2dY69X8QdXDNEuWKgNqJzrlwOTvlhdmjLTM2zfjWqRsY9gX8zAjZOPKDlQ6os5q7bbmS2TjYLAkVvsPt()M3unnTc5O7QMPUHyS)MTI)ke6g8AobpoRMoLWYwjpf0ehiR5V2kvMgdIMsjwuxnDurlMlc)7SoohUStDH3VPHtqrf(EEJmPQK5qd1BH7iGRiZXuEUP7dsAy1H2jdl1stPse00Fh0kz6BOyMQ8Qvr3dESk2rtxz6RWWtQO0o0L2wQ166wTZlpPkHFJT0g1Au9UerI9i6FLUKxXZUSFLEqnnmOSiB580eNrHGajFozhln6zQMoMK3sM6duuOind9e4uLADURhLfmltDdEAjq8qcykuHG(YTcwFleUYGHQz3GIlDrhkI)ulmO7j(xCAs6T)rkRXUr73n0xDnLsR3syCRwiRVFUsoa8Gkx(Ar3HWD9FegJcBLrAAGPdz7jqPIOX0uI9zrAxUcrfj9gNbHMY7)(2)1ZRXQAAnGMe4UanZz8yXnVI5N1CF7yC)H)G0cSX4or1kclnS3q3gbwej(jcggsB5uNcpZ(hv(INlDr3SYZ(PqAqRsn0MJFZfSm3GGUMWA1PSgNhQaz3qZZB9ZAY(G0fLD9PYe2h8qa7rO)fv2lVetBUlkPC)ZqMXwd3qsCy1kZ0kvw4Ah)PEWbTghmA26ZAEplPFUz2(yQhOh3YBQEIu57FoFLjIT7PaAowCKWl094BgvfjzBqmQA8N6bLfJ2Dqm2wEzxlVqEZS8xRwIv1RrYwcZTzba3f7hbBsFqk2s1MmjeNxxNapeCxH7fr7d(dzCBlWuQVZvHo0GeGKSQF)3ymMSRTsUz9dXKaMBq2z06bEN2YcOaP5iL)lZFfxKwm)6usZLaOWjf)v(QG(bknjikv8V1l2SeeB9f94Rwluw)TKLIGl5cVWLN5utRTY5Xdb2yp4)nhb()f716KJBELDb8mgIGfSN1JTcWbWp6owqQ6)oDdbC)ElVk5klq5SBLew2Meo2NGWXUL3iZchR2cNgArUvNCEY1PU4h6SbspuIBO)5E)D7OEdXmNAXwTSjmYidqHHTsyOYsPIzRzK02n6TTDEnZAYOwtDjYhoQQzvqf5tTJjnNNfAL45S2QO0pvL8v2wXI3fk5sk0z5BYS)hiX3PSzsNBEKTAONbG)k6siVxipRO4u)09EkpjGpumRm3FRCAvNhWZyVS8PK8kHsaAaYBKYEvFkD6ryRdMiR8PWNbdSHW8P9R5YRm3pXZt9lCjg4gmU9RVU7(DnooHusyvHx(HRyne4wNcxytkQWZF5ANskiVy(UO45tO6DAGNZAE3M4cr8IO6cfD3YtLGARKgk9632KK5eRCYDvnhIHf2biPqpNRk(mz3JJ296wQ2RZv4kTVobLou)XjkIvOZnl(t1EGnBOXrqevArXMLNT9nSkKwXwAdDIt(V7WUqf5xRcXtQUCXPApOgGHVqiT82CWRpBhu5F02LK2vOLxYxX7YxnrTKVo25TdfZYMi7c98kllBWl99K4qGMG8r5xMe)T7aHAM7AMzWZkQe8zGMKfSpM5KnjI1TbYEijDsk7bq12apLmm7J)BFMTf7w78(Oqax8HFwPFZMvvbWKD4KptYRQWW9T(2GocuUzbisPH3MUbbYYZ5cd(ZGW3ssadMh0r31t5Yc8ZGQz2sKu)aiTuDuEZPD5rYzWbByIgD0E5eUKa(mOxMJfDKBX4xqWE8eRPk6vGOoSKgiFmcYT17FP1Whbq17aq9CUWG)miCmxakNYLf4NbvRBRp60U8i5m4a1UbumHljGpd6vPJG2JFbb7XtSDWzHmI6WsAG8xHJ8G7cuHG8h3jGyPgiwkbYRrPe5IuvqvkMYJiW7ayzk8Y1HypimCdA9nOstJ0QYP8ic8oawTcIwd3GwF7fLwFubUrWEAgADKMpnGxb2FwgSODFQcSg7pLmP3chNfP)Oc8oa2Zy3T1ONaPDBKCww3pUqVlW9K8IWRXFDuqq098E3q2htsYCVNYAReen2J1lhaySPL3uHmxwBiyDEjTCEHr8geW7pu9S98yt2JKswssO)s2hZCFzMll4p7ZwXh49vGb)x1eYS(gWAPr0AF2P0LpuYlM9tcN2C2h)hzULNHA2hRNtzxxVM1LKzfCFzRxVMFIAZAkXkZ44WH(nhOro4hoOyWImDvoMqEKkhNNXMYrycObIJykDfZ8VTs(3gJ)vudsn90otFLJPK)LZyv5is8V501W5FKdn76ODZ4NkCHaX(66tEDM11RIc98zaC2vyNtrpbQdstBUGnf7VpCaT7)c0A51biNwXoYSR9xpt3j4Y3kCXpktL0j7ulk5ulgD1w(uWM96B6GlNzjQIL93D4WvnTmkNWaJeMTAcZUZeMT4EpneMvxjSQdzKtzgpJubsusQQJWgOyz2YlRTG2S8KROX1Z8TSQBEptwHgv(WHksrZ5Yn3EeWyNGDIIDGfsdZCSTso2(7bhFegG4(CgWDr8JYXekk(BFUnmrFX5i1R9zinFw9Hg27k9AI8OqYhA0GMbleh1eQRoDWoHzLhjLGM4hTdYtuUuEaKMKivhMxNKiT0fgKunOhXZbRi2UWPNDD(HNnJ7Rs9bSzeEfhOwdqDfgSQGwJN3o)dK3H1I8omEFy7iAqFNLlWZR7iCu8YJwaH(2tEb(LB95AUyRp3Eak2ZVjQmbTgRh0vxFHvrNs9LoLHedUFjEpGdOQBA6zcisJRx6zcSQRAkdoSLnDMf6Kld1Lu7d68U(OOys0AMrz43T0EC9U09kvXdlI9nDw5BdTwuxEtr57GZbwJlwANj88YruCzq4eYHdXTFDSNoEIb1f7fSUmNEvxZMEy3u0P2phW65c92Vj8ZNXEl4XaRWfcWivR8I)HbyHlXyLSU91MShQoyULwXHe4zZQ(kDoZcsXs1f5C6KIGsTPKb9AF1nN3h5sB(Ij4E9AQO6Jkr7R)Mz2wIZV0ctThafpFfM6aQYxPfqBRUsYaxbWThX5Z8Dtv3HioZIYTd6DL08Rgb4M8WdsJRzJC9vRPY0Q5TtSxFf7DHuVpDUTjk7RaNdU8iv(Q2PBhkECuHjZDzE52JxDtSQJX3sj2RLhAUD88j96u5sZSg1d3QQZso97wlU7GAJjmFmtx17QtjvgftxpUmek4jrSJI(QRR3jHEv7rMnE05twn3HELYBkyr19TORPv1wJMRTsc3Eur8ef3jWPZg31GeibTbN5TV3FvjjHdCHy6Doxiv56u3Kefvo0i9O51tveWn(YdEwIIC7j5BW3ubRzvPunhpVhroQm965SMwY(L67O3uSebNRv40bMvSiZIAtFXJx9LDcdiFZil7I(iZGZuLQVXmi0vKQ1LOi1AelVhqF9ax(6QWPKhZsQKWQ5QPuT0MBA1LoARHkPmRIeJuhlvPc7iBOq9cLQYXqM3g(Qvdo2vkseJk3hjU4GZnUS9KUy)0W1S1O3QAnYEa1is7X9oAHJ5gvbyoDEdebYxTYEhbCv18O6rXZoSEonYYPVU0(WOln66Zlji7jMkPqPM6ytcDghu9k4DTFeNlYcY8hWzGl5L80tReTaCAfcVwQ0j8nd5yQ93j1ojTNYulIBNuNOdsOZEMel5gemhkQ4KFStP97nD27kTkWkZOJGrm1vjKMkDYToYqUii(B6JNOcFlle19OtNVxHN3wFMIbJZbkPyLUUBVlR8uGq8P3Vp(3q4sVCIF9HhuFgSkwXa0Ey0EG6dK9S8wQo(Z3XYRWssROYQ5SxaIowxjAcuDXZjIGvzHxktT4POnhQtN67zho4FHE3NUjkM))NUEp)E8T4))d]] )