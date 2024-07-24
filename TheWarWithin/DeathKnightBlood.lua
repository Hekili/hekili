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

        for i = 1, amount do
            t.expiry[ 1 ] = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
            table.sort( t.expiry )
        end

        -- TODO:  Rampant Transference
        state.gain( amount * 10 * ( state.buff.rune_of_hysteria.up and 1.2 or 1 ), "runic_power" )

        if state.talent.rune_strike.enabled then state.gainChargeTime( "rune_strike", amount ) end

        if state.buff.dancing_rune_weapon.up and state.azerite.eternal_rune_weapon.enabled then
            if state.buff.dancing_rune_weapon.expires - state.buff.dancing_rune_weapon.applied < state.buff.dancing_rune_weapon.duration + 5 then
                state.buff.eternal_rune_weapon.expires = min( state.buff.dancing_rune_weapon.applied + state.buff.dancing_rune_weapon.duration + 5, state.buff.dancing_rune_weapon.expires + ( 0.5 * amount ) )
            end
        end

        t.actual = nil
    end,

    timeTo = function( x )
        return state:TimeToResource( state.runes, x )
    end,
}, {
    __index = function( t, k, v )
        if k == "actual" then
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
                    if v.t <= q then
                        index = i
                        slice = v
                    else
                        break
                    end
                end

                -- We have a slice.
                if index and slice then
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
    if amt > 0 and resource == "runic_power" then
        if talent.red_thirst.enabled then cooldown.vampiric_blood.expires = max( 0, cooldown.vampiric_blood.expires - amt / 10 ) end
        if talent.icy_talons.enabled then addStack( "icy_talons", nil, 1 ) end
    elseif resource == "rune" and amt > 0 and active_dot.shackle_the_unworthy > 0 then
        reduceCooldown( "shackle_the_unworthy", 4 * amt )
    end
end

spec:RegisterHook( "spend", spendHook )

-- Talents
-- Talents
spec:RegisterTalents( {
    -- DeathKnight
    abomination_limb               = { 76049, 383269, 1 }, -- Sprout an additional limb, dealing 57,508 Shadow damage over 12 sec to all nearby enemies. Deals reduced damage beyond 5 targets. Every 1 sec, an enemy is pulled to your location if they are further than 8 yds from you. The same enemy can only be pulled once every 4 sec.
    antimagic_barrier              = { 76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by 20 sec and increases its duration and amount absorbed by 40%.
    antimagic_zone                 = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 782,220 damage.
    asphyxiate                     = { 76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation                   = { 76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and its cooldown is reduced by 30 sec.
    blinding_sleet                 = { 76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_draw                     = { 76056, 374598, 1 }, -- When you fall below 30% health you drain 18,691 health from nearby enemies, the damage you take is reduced by 10% and your Death Strike cost is reduced by 10 for 8 sec. Can only occur every 2 min.
    blood_scent                    = { 76078, 374030, 1 }, -- Increases Leech by 3%.
    brittle                        = { 76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    cleaving_strikes               = { 76073, 316916, 1 }, -- Heart Strike hits up to 3 additional enemies while you remain in Death and Decay. When leaving your Death and Decay you retain its bonus effects for 4 sec.
    coldthirst                     = { 76083, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants 10 Runic Power and reduces its cooldown by 3 sec.
    control_undead                 = { 76059, 111673, 1 }, -- Dominates the target undead creature up to level 71, forcing it to do your bidding for 5 min.
    death_pact                     = { 76075, 48743 , 1 }, -- Create a death pact that heals you for 50% of your maximum health, but absorbs incoming healing equal to 30% of your max health for 15 sec.
    death_strike                   = { 76071, 49998 , 1 }, -- Focuses dark power into a strike that deals 17,283 Physical damage and heals you for 30.19% of all damage taken in the last 5 sec, minimum 8.5% of maximum health.
    deaths_echo                    = { 102007, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have 1 additional charge.
    deaths_reach                   = { 102006, 276079, 1 }, -- Increases the range of Death Grip by 10 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    enfeeble                       = { 76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by 30% and the damage they deal to you by 15% for 6 sec.
    gloom_ward                     = { 76052, 391571, 1 }, -- Absorbs are 15% more effective on you.
    grip_of_the_dead               = { 76057, 273952, 1 }, -- Death and Decay reduces the movement speed of enemies within its area by 90%, decaying by 10% every sec.
    ice_prison                     = { 76086, 454786, 1 }, -- Chains of Ice now also roots enemies for 4 sec but its cooldown is increased to 12 sec.
    icebound_fortitude             = { 76081, 48792 , 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 30% for 8 sec.
    icy_talons                     = { 76085, 194878, 1 }, -- Your Runic Power spending abilities increase your melee attack speed by 6% for 10 sec, stacking up to 3 times.
    improved_death_strike          = { 76067, 374277, 1 }, -- Death Strike's cost is reduced by 5, and its healing is increased by 5%.
    insidious_chill                = { 76051, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by 5% for 30 sec, stacking up to 4 times.
    march_of_darkness              = { 76074, 391546, 1 }, -- Death's Advance grants an additional 25% movement speed over the first 3 sec.
    mind_freeze                    = { 76084, 47528 , 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    null_magic                     = { 102008, 454842, 1 }, -- Magic damage taken is reduced by 10% and the duration of harmful Magic effects against you are reduced by 35%.
    osmosis                        = { 76088, 454835, 1 }, -- Anti-Magic Shell increases healing received by 15%.
    permafrost                     = { 76066, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to 40% of the damage dealt.
    proliferating_chill            = { 101708, 373930, 1 }, -- Chains of Ice affects 1 additional nearby enemy.
    raise_dead                     = { 76072, 46585 , 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts 1 min.
    rune_mastery                   = { 76079, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by 3% for 8 sec.
    runic_attenuation              = { 76045, 207104, 1 }, -- Auto attacks have a chance to generate 3 Runic Power.
    runic_protection               = { 76055, 454788, 1 }, -- Your chance to be critically struck is reduced by 3% and your Armor is increased by 6%.
    sacrificial_pact               = { 76060, 327574, 1 }, -- Sacrifice your ghoul to deal 11,682 Shadow damage to all nearby enemies and heal for 25% of your maximum health. Deals reduced damage beyond 8 targets.
    soul_reaper                    = { 76063, 343294, 1 }, -- Strike an enemy for 6,990 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 32,074 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    subduing_grasp                 = { 76080, 454822, 1 }, -- When you pull an enemy, the damage they deal to you is reduced by 6% for 6 sec.
    suppression                    = { 76087, 374049, 1 }, -- Damage taken from area of effect attacks reduced by 3%. When suffering a loss of control effect, this bonus is increased by an additional 6% for 6 sec.
    unholy_bond                    = { 76076, 374261, 1 }, -- Increases the effectiveness of your Runeforge effects by 20%.
    unholy_endurance               = { 76058, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground                  = { 76069, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    unyielding_will                = { 76050, 457574, 1 }, -- Anti-Magic Shell's cooldown is increased by 20 sec and it now also removes all harmful magic effects when activated.
    vestigial_shell                = { 76053, 454851, 1 }, -- Casting Anti-Magic Shell grants 2 nearby allies a Lesser Anti-Magic Shell that Absorbs up to 47,285 magic damage and reduces the duration of harmful Magic effects against them by 50%.
    veteran_of_the_third_war       = { 76068, 48263 , 1 }, -- Stamina increased by 20%.
    will_of_the_necropolis         = { 76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk                    = { 76077, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.
    -- Blood
    blood_boil                     = { 76170, 50842 , 1 }, -- Deals 8,770 Shadow damage and infects all enemies within 10 yds with Blood Plague.  Blood Plague A shadowy disease that drains 15,417 health from the target over 24 sec.
    blood_feast                    = { 102243, 391386, 1 }, -- Anti-Magic Shell heals you for 100% of the damage it absorbs.
    blood_tap                      = { 76039, 221699, 1 }, -- Consume the essence around you to generate 1 Rune. Recharge time reduced by 2 sec whenever a Bone Shield charge is consumed.
    blooddrinker                   = { 102244, 206931, 1 }, -- Drains 39,825 health from the target over 2.5 sec. The damage they deal to you is reduced by 20% for the duration and 5 sec after channeling it fully. You can move, parry, dodge, and use defensive abilities while channeling this ability. Generates 20 additional Runic Power over the duration.
    bloodied_blade                 = { 102242, 458753, 1 }, -- Parrying an attack grants you a charge of Bloodied Blade, increasing your Strength by 0.5%, up to 4.0% for 15 sec. At 8 stacks, your next parry consumes all charges to unleash a Heart Strike at 200% effectiveness, and increases your Strength by 10% for 6 sec.
    bloodshot                      = { 76125, 391398, 1 }, -- While Blood Shield is active, you deal 25% increased Physical damage.
    bloodworms                     = { 76174, 195679, 1 }, -- Your auto attacks have a chance to summon a Bloodworm. Bloodworms deal minor damage to your target for 15 sec and then burst, healing you for 15% of your missing health. If you drop below 50% health, your Bloodworms will immediately burst and heal you.
    bone_collector                 = { 76171, 458572, 1 }, -- When you would pull an enemy generate 1 charge of Bone Shield.  Bone Shield Surrounds you with a barrier of whirling bones, increasing Armor by 5,211. Each melee attack against you consumes a charge. Lasts 30 sec or until all charges are consumed.
    bonestorm                      = { 76127, 194844, 1 }, -- Consume your Bone Shield charges to create a whirl of bone and gore that batters all nearby enemies, dealing 3,520 Shadow damage every 1 sec, and healing you for 3% of your maximum health every time it deals damage (up to 15%). Deals reduced damage beyond 8 targets. Lasts 1 sec per Bone Shield charge spent and rapidly regenerates a Bone Shield every 1 sec.
    carnage                        = { 102245, 458752, 1 }, -- Blooddrinker and Consumption now contribute to your Mastery: Blood Shield. Each time an enemy strikes your Blood Shield, the cooldowns of Blooddrinker and Consumption have a chance to be reset.
    coagulopathy                   = { 76038, 391477, 1 }, -- Enemies affected by Blood Plague take 5% increased damage from you and Death Strike increases the damage of your Blood Plague by 30% for 8 sec, stacking up to 5 times.
    consumption                    = { 102244, 274156, 1 }, -- Strikes all enemies in front of you with a hungering attack that deals 12,246 Physical damage and heals you for 150% of that damage. Deals reduced damage beyond 8 targets. Causes your Blood Plague damage to occur 50% more quickly for 8 sec. Generates 2 Runes.
    dancing_rune_weapon            = { 76138, 49028 , 1 }, -- Summons a rune weapon for 16 sec that mirrors your melee attacks and bolsters your defenses. While active, you gain 40% parry chance.
    everlasting_bond               = { 76130, 377668, 1 }, -- Summons 1 additional copy of Dancing Rune Weapon and increases its duration by 8 sec.
    foul_bulwark                   = { 76167, 206974, 1 }, -- Each charge of Bone Shield increases your maximum health by 1%.
    gorefiends_grasp               = { 76042, 108199, 1 }, -- Shadowy tendrils coil around all enemies within 15 yards of a hostile or friendly target, pulling them to the target's location.
    heart_strike                   = { 76169, 206930, 1 }, -- Instantly strike the target and 1 other nearby enemy, causing 7,399 Physical damage, and reducing enemies' movement speed by 20% for 8 sec, plus 2 Runic Power per additional enemy struck.
    heartbreaker                   = { 76135, 221536, 1 }, -- Heart Strike generates 2 additional Runic Power per target hit.
    heartrend                      = { 76131, 377655, 1 }, -- Heart Strike has a chance to increase the damage of your next Death Strike by 20%.
    hemostasis                     = { 76137, 273946, 1 }, -- Each enemy hit by Blood Boil increases the damage and healing done by your next Death Strike by 8%, stacking up to 5 times.
    improved_bone_shield           = { 76142, 374715, 1 }, -- Bone Shield increases your Haste by 10%.
    improved_heart_strike          = { 76126, 374717, 2 }, -- Heart Strike damage increased by 15%.
    improved_vampiric_blood        = { 76140, 317133, 2 }, -- Vampiric Blood's healing and absorb amount is increased by 5% and duration by 2 sec.
    insatiable_blade               = { 76129, 377637, 1 }, -- Dancing Rune Weapon generates 5 Bone Shield charges. When a charge of Bone Shield is consumed, the cooldown of Dancing Rune Weapon is reduced by 5 sec.
    iron_heart                     = { 76172, 391395, 1 }, -- Blood Shield's duration is increased by 2 sec and it absorbs 20% more damage.
    leeching_strike                = { 76145, 377629, 1 }, -- Heart Strike heals you for 0.5% health for each enemy hit while affected by Blood Plague.
    mark_of_blood                  = { 76139, 206940, 1 }, -- Places a Mark of Blood on an enemy for 15 sec. The enemy's damaging auto attacks will also heal their victim for 3% of the victim's maximum health.
    marrowrend                     = { 76168, 195182, 1 }, -- Smash the target, dealing 9,961 Physical damage and generating 3 charges of Bone Shield.  Bone Shield Surrounds you with a barrier of whirling bones, increasing Armor by 5,211. Each melee attack against you consumes a charge. Lasts 30 sec or until all charges are consumed.
    ossified_vitriol               = { 76146, 458744, 1 }, -- When you lose a Bone Shield charge the damage of your next Marrowrend is increased by 15%, stacking up to 75%.
    ossuary                        = { 76144, 219786, 1 }, -- While you have at least 5 Bone Shield charges, the cost of Death Strike is reduced by 5 Runic Power. Additionally, your maximum Runic Power is increased by 10.
    perseverance_of_the_ebon_blade = { 76124, 374747, 1 }, -- When Crimson Scourge is consumed, you gain 6% Versatility for 6 sec.
    purgatory                      = { 76133, 114556, 1 }, -- An unholy pact that prevents fatal damage, instead absorbing incoming healing equal to the damage prevented, lasting 3 sec. If any healing absorption remains when this effect expires, you will die. This effect may only occur every 4 min.
    rapid_decomposition            = { 76141, 194662, 1 }, -- Your Blood Plague and Death and Decay deal damage 18% more often. Additionally, your Blood Plague leeches 50% more Health.
    red_thirst                     = { 76132, 205723, 1 }, -- Reduces the cooldown on Vampiric Blood by 2.0 sec per 10 Runic Power spent.
    reinforced_bones               = { 76143, 374737, 1 }, -- Increases Armor gained from Bone Shield by 10% and it can stack 2 additional times.
    relish_in_blood                = { 76147, 317610, 1 }, -- While Crimson Scourge is active, your next Death and Decay heals you for 3,338 health per Bone Shield charge and you immediately gain 10 Runic Power.
    rune_tap                       = { 76166, 194679, 1 }, -- Reduces all damage taken by 20% for 4 sec.
    sanguine_ground                = { 76041, 391458, 1 }, -- You deal 6% more damage and receive 5% more healing while standing in your Death and Decay.
    shattering_bone                = { 76128, 377640, 1 }, -- When Bone Shield is consumed it shatters dealing 771 Shadow damage to nearby enemies. This damage is tripled while you are within your Death and Decay.
    tightening_grasp               = { 76165, 206970, 1 }, -- Gorefiend's Grasp cooldown is reduced by 30 sec and it now also Silences enemies for 3 sec.
    tombstone                      = { 76139, 219809, 1 }, -- Consume up to 5 Bone Shield charges. For each charge consumed, you gain 6 Runic Power and absorb damage equal to 6% of your maximum health for 8 sec.
    umbilicus_eternus              = { 76040, 391517, 1 }, -- After Vampiric Blood expires, you absorb damage equal to 5 times the damage your Blood Plague dealt during Vampiric Blood.
    vampiric_blood                 = { 76173, 55233 , 1 }, -- Embrace your undeath, increasing your maximum health by 30% and increasing all healing and absorbs received by 40% for 14 sec.
    voracious                      = { 76043, 273953, 1 }, -- Death Strike's healing is increased by 15% and grants you 12% Leech for 8 sec.
    -- Deathbringer
    bind_in_darkness               = { 95043, 440031, 1 }, -- Shadowfrost damage applies 2 stacks to Reaper's Mark and 4 stacks when it is a critical strike. Additionally, Blood Boil deals Shadowfrost damage.
    blood_fever                    = { 95058, 440002, 1 }, -- Your Blood Plague has a chance to deal 30% increased damage as Shadowfrost.
    dark_talons                    = { 95057, 436687, 1 }, -- Marrowrend and Heart Strike have a 25% chance to increase the maximum stacks of an active Icy Talons by 1, up to 2 times. While Icy Talons is active, your Runic Power spending abilities also count as Shadowfrost damage.
    deaths_messenger               = { 95049, 437122, 1 }, -- Reduces the cooldowns of Lichborne and Raise Dead by 30 sec.
    expelling_shield               = { 95049, 439948, 1 }, -- When an enemy deals direct damage to your Anti-Magic Shell, their cast speed is reduced by 10% for 6 sec.
    exterminate                    = { 95068, 441378, 1 }, -- After Reaper's Mark explodes, your next Marrowrend costs no Rune and summons 2 scythes to strike your enemies. The first scythe strikes your target for 47,664 Shadowfrost damage and has a 20% chance to apply Reaper's Mark, the second scythe strikes all enemies around your target for 31,776 Shadowfrost damage. Deals reduced damage beyond 8 targets.
    grim_reaper                    = { 95034, 434905, 1 }, -- Reaper's Mark explosion deals up to 30% increased damage based on your target's missing health, and applies Soul Reaper to targets below 35% health.
    pact_of_the_deathbringer       = { 95035, 440476, 1 }, -- When you suffer a damaging effect equal to 25% of your maximum health, you instantly cast Death Pact at 50% effectiveness. May only occur every 2 min. When a Reaper's Mark explodes, the cooldowns of this effect and Death Pact are reduced by 5 sec.
    painful_death                  = { 95032, 443564, 1 }, -- Reaper's Mark deals 10% increased damage and Exterminate empowers an additional Marrowrend, but now reduces its cost by 1 Rune. Additionally, Exterminate now has a 30% chance to apply Reaper's Mark.
    reapers_mark                   = { 95062, 439843, 1 }, -- Viciously slice into the soul of your enemy, dealing 12,461 Shadowfrost damage and applying Reaper's Mark. Each time you deal Shadow or Frost damage, add a stack of Reaper's Mark. After 12 sec or reaching 40 stacks, the mark explodes, dealing 1,736 damage per stack. Reaper's Mark travels to an unmarked enemy nearby if the target dies, or explodes below 35% health when there are no enemies to travel to. This explosion cannot occur again on a target for 3 min.
    rune_carved_plates             = { 95035, 440282, 1 }, -- Each Rune spent reduces the magic damage you take by 2% and each Rune generated reduces the physical damage you take by 2% for 5 sec, up to 5 times.
    soul_rupture                   = { 95061, 437161, 1 }, -- When Reaper's Mark explodes, it deals 20% of the damage dealt damage to nearby enemies. Enemies hit by this effect deal 5% reduced physical damage to you for 10 sec.
    swift_end                      = { 95032, 443560, 1 }, -- Reaper's Mark's cost is reduced by 1 Rune and its cooldown is reduced by 30 sec.
    wave_of_souls                  = { 95036, 439851, 1 }, -- Reaper's Mark sends forth bursts of Shadowfrost energy and back, dealing 13,434 Shadowfrost damage both ways to all enemies caught in its path. Wave of Souls critical strikes cause enemies to take 5% increased Shadowfrost damage for 15 sec, stacking up to 2 times, and it is always a critical strike on its way back.
    wither_away                    = { 95057, 441894, 1 }, -- Blood Plague deals its damage in half the duration and the second scythe of Exterminate applies Blood Plague.
    -- San'layn
    bloodsoaked_ground             = { 95048, 434033, 1 }, -- While you are within your Death and Decay, your physical damage taken is reduced by 5% and your chance to gain Vampiric Strike is increased by 5%.
    bloody_fortitude               = { 95056, 434136, 1 }, -- Icebound Fortitude reduces all damage you take by up to an additional 20% based on your missing health. Killing an enemy that yields experience or honor reduces the cooldown of Icebound Fortitude by 3 sec.
    frenzied_bloodthirst           = { 95065, 434075, 1 }, -- Essence of the Blood Queen stacks 2 additional times and increases the damage of your Death Coil and Death Strike by 2% per stack.
    gift_of_the_sanlayn            = { 95053, 434152, 1 }, -- While Vampiric Blood or Dark Transformation is active you gain Gift of the San'layn. Gift of the San'layn increases the effectiveness of your Essence of the Blood Queen by 150%, and Vampiric Strike replaces your Heart Strike for the duration.
    incite_terror                  = { 95040, 434151, 1 }, -- Vampiric Strike and Heart Strike cause your targets to take 1% increased Shadow damage, up to 5% for 15 sec. Vampiric Strike benefits from Incite Terror at 400% effectiveness.
    infliction_of_sorrow           = { 95033, 434143, 1 }, -- When Vampiric Strike damages an enemy affected by your Blood Plague, it extends the duration of the disease by 3 sec, and deals 10% of the remaining damage to the enemy. After Gift of the San'layn ends, your next Heart Strike consumes the disease to deal 100% of their remaining damage to the target.
    newly_turned                   = { 95064, 433934, 1 }, -- Raise Ally revives players at full health and grants you and your ally an absorb shield equal to 20% of your maximum health.
    pact_of_the_sanlayn            = { 95055, 434261, 1 }, -- You store 50% of all Shadow damage dealt into your Blood Beast to explode for additional damage when it expires.
    sanguine_scent                 = { 95055, 434263, 1 }, -- Your Death Coil and Death Strike have a 15% increased chance to trigger Vampiric Strike when damaging enemies below 35% health.
    the_blood_is_life              = { 95046, 434260, 1 }, -- Vampiric Strike has a chance to summon a Blood Beast to attack your enemy for 10 sec. Each time the Blood Beast attacks, it stores a portion of the damage dealt. When the Blood Beast dies, it explodes, dealing 50% of the damage accumulated to nearby enemies and healing the Death Knight for the same amount.
    vampiric_aura                  = { 95056, 434100, 1 }, -- Your Leech is increased by 2%. While Lichborne is active, the Leech bonus of this effect is increased by 100%, and it affects 4 allies within 12 yds.
    vampiric_speed                 = { 95064, 434028, 1 }, -- Death's Advance and Wraith Walk movement speed bonuses are increased by 10%. Activating Death's Advance or Wraith Walk increases 4 nearby allies movement speed by 20% for 5 sec.
    vampiric_strike                = { 95051, 433901, 1 }, -- Your Death Coil and Death Strike have a 10% chance to make your next Heart Strike become Vampiric Strike. Vampiric Strike heals you for 1% of your maximum health and grants you Essence of the Blood Queen, increasing your Haste by 1.0%, up to 5.0% for 20 sec.
    visceral_strength              = { 95045, 434157, 1 }, -- When Crimson Scourge is consumed, you gain 5% Strength for 8 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bloodforged_armor = 5587, -- (410301) Death Strike reduces all Physical damage taken by 20% for 3 sec.
    dark_simulacrum   = 3511, -- (77606) Places a dark ward on an enemy player that persists for 12 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    death_chain       = 609 , -- (203173) Chains 3 enemies together, dealing 3198.4 Shadow damage and causing 20% of all damage taken to also be received by the others in the chain. Lasts for 10 sec.
    decomposing_aura  = 3441, -- (199720) All enemies within 8 yards slowly decay, losing up to 3% of their max health every 2 sec. Max 5 stacks. Lasts 6 sec.
    last_dance        = 608 , -- (233412) Reduces the cooldown of Dancing Rune Weapon by 50% and its duration by 25%.
    murderous_intent  = 841 , -- (207018) You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    necrotic_aura     = 5513, -- (199642) All enemies within 8 yards take 4% increased magical damage.
    rot_and_wither    = 204 , -- (202727) Your Death and Decay rots enemies each time it deals damage, absorbing healing equal to 100% of damage dealt.
    spellwarden       = 5592, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by 10 sec.
    strangulate       = 206 , -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for 5 sec.
    walking_dead      = 205 , -- (202731) Your Death Grip causes the target to be unable to move faster than normal movement speed for 8 sec.
} )


-- Auras
spec:RegisterAuras( {
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
        tick_time = function() return 3 * ( talent.rapid_decomposition.enabled and 0.82 or 1 ) * ( buff.consumption.up and 0.5 or 1 ) * ( spec.blood and talent.wither_away.enabled and 0.5 or 1 ) end,
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
        max_stack = 1,

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
    -- Talent: Movement slowed $w1% $?$w5!=0[and Haste reduced $w5% ][]by frozen chains.
    -- https://wowhead.com/beta/spell=45524
    chains_of_ice = {
        id = 45524,
        duration = 8,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
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
        duration = 8.0,
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
        duration = function () return ( pvptalent.last_dance.enabled and 6 or 8 ) + ( talent.everlasting_bond.enabled and 8 or 0 ) end,
        type = "Magic",
        max_stack = 1
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
        duration = function() return 24 * ( spec.frost and talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( spec.frost and talent.wither_away.enabled and 0.5 or 1 ) end,
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
        max_stack = 1,
    },
    -- Taking $w1% increased Shadow damage from $@auracaster.
    incite_terror = {
        id = 458478,
        duration = 15.0,
        max_stack = 1,
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
        max_stack = 1,
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
        duration = function () return ( level > 55 and 12 or 10 ) + ( legendary.vampiric_aura.enabled and 3 or 0 ) + ( talent.improved_vampiric_blood.enabled and 2 or 0 ) end,
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
    -- Talent: Movement speed increased by $w1%.  Cannot be slowed below $s2% of normal movement speed.  Cannot attack.
    -- https://wowhead.com/beta/spell=212552
    wraith_walk = {
        id = 212552,
        duration = 4,
        max_stack = 1
    },
} )


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


local TriggerUmbilicusEternus = setfenv( function()
    applyBuff( "umbilicus_eternus" )
end, state )

local TriggerERW = setfenv( function()
    gain( 1, "runes" )
    gain( 5, "runic_power" )
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

    if talent.vampiric_strike.enabled and IsActiveSpell( 433899 ) then applyBuff( "vampiric_strike" ) end

    --[[ if buff.empower_rune_weapon.up then
        local expires = buff.empower_rune_weapon.expires

        while expires >= query_time do
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, expires )
            expires = expires - 5
        end
    end ]]
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
        gcd = "spell",

        talent = "blood_boil",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "blood_plague" )
            active_dot.blood_plague = active_enemies

            if buff.vampiric_strength.up then buff.vampiric_strength.expires = buff.vampiric_strength.expires + 0.5 end

            if talent.hemostasis.enabled then
                applyBuff( "hemostasis", 15, min( 5, active_enemies ) )
            end

            if debuff.ashen_decay.up and set_bonus.tier31_4pc > 0 then
                debuff.ashen_decay.expires = debuff.ashen_decay.expires + 1
            end

            if legendary.superstrain.enabled then
                applyDebuff( "target", "frost_fever" )
                active_dot.frost_fever = active_enemies

                applyDebuff( "target", "virulent_plague" )
                active_dot.virulent_plague = active_enemies
            end

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
            applyBuff( "bonestorm", buff.bone_shield.stack )
            removeBuff( "bone_shield" )
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
            if azerite.eternal_rune_weapon.enabled then applyBuff( "dancing_rune_weapon" ) end
            if legendary.crimson_rune_weapon.enabled then addStack( "bone_shield", nil, buff.dancing_rune_weapon.up and 10 or 5 ) end
            if talent.insatiable_blade.enabled then addStack( "bone_shield", nil, buff.dancing_rune_weapon.up and 10 or 5 ) end
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
                if talent.relish_in_blood.enabled then gain( 10, "runic_power" ) end
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
            removeBuff( "blood_draw" )
            removeBuff( "heartrend" )
            applyBuff( "blood_shield" ) -- gain absorb shield
            gain( 0.075 * health.max * ( 1.2 * buff.haemostasis.stack ) * ( 1.08 * buff.hemostasis.stack ), "health" )
            removeBuff( "haemostasis" )
            removeBuff( "hemostasis" )

            -- TODO: Calculate real health gain from Death Strike to trigger Bryndaor's Might legendary.
            if talent.coagulopathy.enabled then applyBuff( "coagulopathy" ) end
            if talent.voracious.enabled then applyBuff( "voracious" ) end
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
            applyDebuff( "target", "blood_plague" )
            addStack( "bone_shield", nil, buff.dancing_rune_weapon.up and 4 or 2 )
        end,
    },

    -- Talent: Empower your rune weapon, gaining $s3% Haste and generating $s1 $LRune:Runes; and ${$m2/10} Runic Power instantly and every $t1 sec for $d.  $?s137006[  If you already know $@spellname47568, instead gain $392714s1 additional $Lcharge:charges; of $@spellname47568.][]
    empower_rune_weapon = {
        id = 47568,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "empower_rune_weapon",
        startsCombat = false,

        handler = function ()
            applyBuff( "empower_rune_weapon" )
            gain( 1, "runes" )
            gain( 5, "runic_power" )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 5 )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 10 )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 15 )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 20 )
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
        id = 206930,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "heart_strike",
        startsCombat = true,
        nobuff = "vampiric_strike",

        bind = "vampiric_strike",

        max_targets = function () return buff.death_and_decay.up and talent.cleaving_strikes.enabled and 5 or 2 end,

        handler = function ()
            applyDebuff( "target", "heart_strike" )
            active_dot.heart_strike = min( true_active_enemies, active_dot.heart_strike + action.heart_strike.max_targets )

            if buff.vampiric_strength.up then buff.vampiric_strength.expires = buff.vampiric_strength.expires + 0.5 end

            if talent.heartbreaker.enabled then
                gain( min( action.heart_strike.max_targets, true_active_enemies ), "runic_power" )
            end

            if buff.ashen_decay_proc.up then
                applyDebuff( "target", "ashen_decay" )
                removeBuff( "ashen_decay_proc" )
            end

            if debuff.ashen_decay.up and set_bonus.tier31_4pc > 0 then -- TODO: Check if refresh is before reapplication.
                debuff.ashen_decay.expires = debuff.ashen_decay.expires + 1
            end

            if buff.infliction_of_sorrow.up then
                removeDebuff( "target", "blood_plague" )
                removeBuff( "infliction_of_sorrow" )
            end

            if pvptalent.blood_for_blood.enabled then
                health.current = health.current - 0.03 * health.max
            end

            if azerite.deep_cuts.enabled then applyDebuff( "target", "deep_cuts" ) end

            if legendary.gorefiends_domination.enabled and cooldown.vampiric_blood.remains > 0 then
                gainChargeTime( "vampiric_blood", 2 )
            end

        end,
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

        spend = 2,
        spendType = "runes",

        talent = "marrowrend",
        startsCombat = true,

        handler = function ()
            addStack( "bone_shield", 30, buff.bone_shield.stack + ( buff.dancing_rune_weapon.up and 6 or 3 ) )
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
        cooldown = function() return 60.0 - ( talent.swift_end.enabled and 30 or 0 ) end,
        gcd = "spell",

        spend = function() return talent.swift_end.enabled and 1 or 2 end,
        spendType = 'runes',

        talent = "reapers_mark",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "reapers_mark" )
        end,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 0.8, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 434765, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'resource': runic_power, }
        -- #3: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 1.5, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- painful_death[443564] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- swift_end[443560] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- swift_end[443560] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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
        charges = function () return level > 43 and 2 or nil end,
        cooldown = 25,
        recharge = function () return level > 43 and 25 or nil end,
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

        spend = 1,
        spendType = "runes",

        talent = "soul_reaper",
        startsCombat = true,

        handler = function ()
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

            removeStack( "bone_shield", bs )
            if talent.insatiable_blade.enabled then reduceCooldown( "dancing_rune_weapon", bs * 5 ) end
            gain( 6 * bs, "runic_power" )

            -- This is the only predictable Bone Shield consumption that I have noted.
            if cooldown.dancing_rune_weapon.remains > 0 then
                cooldown.dancing_rune_weapon.expires = cooldown.dancing_rune_weapon.expires - ( 3 * bs )
            end

            if cooldown.blood_tap.charges_fractional < cooldown.blood_tap.max_charges then
                gainChargeTime( "blood_tap", 2 * bs )
            end

            if set_bonus.tier21_2pc == 1 then
                cooldown.dancing_rune_weapon.expires = max( 0, cooldown.dancing_rune_weapon.expires - ( 3 * bs ) )
            end

            applyBuff( "tombstone" )
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

    vampiric_strike = {
        id = 433895,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = 1,
        spendType = 'runes',

        startsCombat = true,
        buff = "vampiric_strike",

        bind = "heart_strike",

        handler = function ()
            gain( 0.01 * health.max, "health" )
            removeBuff( "vampiric_strike" )
            applyBuff( "essence_of_the_blood_queen" ) -- TODO: mod haste

            if talent.infliction_of_sorrow.enabled and dot.blood_plague.ticking then
                dot.blood_plague.expires = dot.blood_plague.expires + 3
                applyBuff( "infliction_of_sorrow")
            end
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

    potion = "potion_of_phantom_fire",

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

spec:RegisterPack( "Blood", 20240723, [[Hekili:S3ZAVTnUY(Bj4I6A3hU2kjT7UijaDl2d2DXEp7IMZJVfBfB5yDQSKVsYnnfb(3(LdLefj1mKuwYPN9Epyb62AsnCMHdNxCi5ntV5VDZ1l9ZdU5V6nX7SjVZ70Xt)UjNn9T3CD(dBdU56T(l(K)DS)sS)g2F(JrjjlHF9HOe)LWxNLSlDbRLRd3SlYppmj(dP(RYV56B3fgL)lX3Cl2imz67yF62GfSF(8j3C96WLldk6Bq2IBUg67RN8Ux7D6pSF(FBDW(5)t)u2FeMVom(MRJcZYZ4JEy8DrbZY9tVliN9d)voffe7FBuWYB(XcWLgUfWlahHEZaiV77N)XKC)Iwy9jpin0h(GB3TA14u)VMKgUiyCwoJdSF(L7NF((5d2pp3pkioFC2A)C4lIVB2Tr(ldgxoMY9XF2Qa)S8zjRMX4srzk9Hpkn6XUT3CT)IcCAvAcRPS80WpfCtoJrPrA14mhwFkmkcqNn(ly8OagO4JZN9zDH9jaHKhUywYTrWNXMrMbFww94v3cmANsoAd3pVZmPr7N)4J7NpSKpqG7P7IzZwxSFUh)FEIaWSX820a)pfKkbsAo3zK0IG7KgUPbdzDY9rL4EwoaNZpOzGHCmxmsBts49ciUSc2a6xxZt9uio1PP3sIseJjteyBY9bPvC0Lb(5RN9P4W7wNpgWPvjSfhIP2kkGyg)c(moqd6DinyJFyCgVl3Ty54n(Fz)8xSF(PkeZDr(lc9JM5V8Z(Xl4u076efnuQpPBlMrfYAN4GKzHyxfmhVmyv4IW8cPWjcb3UVaGwA97mlLbsQk6jAiM(9DIdEIktm)(KzR9JxoBX6aGebQVlu30jTf7ci1rnvxBVvyvrPgWpA1SWQLK8XfFXQGpZepyAu)ed0gMmMsRiTKncAYylbbBaHXlt9VljZxrE8KsneODSujdRplyK5YK7JX7Ny9iQEvo8lufaZ1ldw4)GIqMF8dZwgVKtr0Qt1am6cPRyTEUKIrN4cGuNJ03vs9CDsAm0V7dJZbCyxk3E)(5VE)8PNRiNQ2voDsRU3v02epyIeZnDHFmZlMK0ugmVb(VRxWiHzRd8tT7wZhyDD)8FM3xjKCfOsFgQE4cMV8SfWGpXS1yn7y6kgQ8PPgXR0kEftT4zfdXH817N)Dc9Uhh8Jpcho6nTWUGKW0I1aphKkcxyX3TArjHUngiA6Q4wgr7NcGKR)PIOnWYb0AqTpw6aGYanR)t3p)L8)sjMX)G7FiDt2Sv7sFqb5eR107eBHXYhkymsZD7IxNe9aOVni(U81kKHEBOyOjUmTQwh4YeocTYpI9DZwKUlJzIlvrHjXCIGLqWYNf8fwKp5W4EvHEiPPjJZLKSqb)L4Zp1mJJwJUdmoANiX4D2jYEL7kRMTbztRG3bA2eoAzY8SUnz(9A2dTZiUG73TfU)zgLrYLC(c6GnJs)UuN3p)9mO(5a8iUnf9JWvc3vHnqocaxIQ7aIR(WqlA)SuX678NTnnKfyr(dgJusxDhQlT2iNoXOn554IhwiYmtgiSGONXgg35WSg0TKXurKvWiDbKcf)Sm)Dr5vqaNu11TGebJTPgkUOXy(T7HermmAEdRTirpQCkXs18eHjsBma6I8jmsgB)gKFcrcdOZMGSVZfORpxf3SG4GnHbfXHmTYVqSzr9W8TTwaXHDcCRZRAgvj3BnzbkHWPjlOg9Mo75so7Pz2ecwwQZPgBW5F0z5OG6TMMKgzIW2mW)MZqAKnehwJ6cjHBxcfd0nL2rokXOq7MVybYPgdS3HeymLt6kScaSMcA3scdivXtjGc7Hcp7cw916h5DZSxwi(e1KeVsvLxzYn4Fbtft(60GS18Kn8A5Wdt9Vla4W5Rdar1VcU8V2FZwfNMzQwFREyYTWvmhZS0PtKwfY54bB49INiXz3h4VLHuvozRtOlFOPDqDHhkNUALDDHneYud5I3titUYesnUXS1LKMfefKLjrj2Lw3KCxkZizq2SnCZVn3sPzBJ8JJ5CTAdlLX0CxAYU4LOHnr4bmodrjYqJbMroNwZk0gzZUtzbwwDssr8vrrYBnQiPR7aatZHFsGv1gVp5Nk0zarO9BHz5oj5wppZKq9)m0CHIDexQnLrz1u53ZzDVTHg5IDWo7w1azLMKw3X8n4cEcujS7tRwqwArKI32ZmPcLPJ(v0H4dmexeM(4AC3qKmhOOHBo33AdzENBYieTVVUapSTBiLpvMzvNXh59JP242qg)ne2Boe9LvPMQi951J8Tq5JWtpS5182buaZEwkxUfz1ElaujVyllEFxlvakqfb2iZM9V2T8UnLkYPnXAfAWkkMWiB51c)OihTtrbSvHPbCEVzRuDmRN82AMqtPzn)74(jYwr)PmZltSzQFGBjGTZB3qrgbezK1PeJ1Okh0P7Cyr1kihswxV9H1jjzb1MPHkFIXAs4AoQhbqgzwX)ywe3so8NZkkARkXJmSfDobbgMh)jq7MbtRgbWA2AdUgES1yobHkr7mtwKmcHkvCgxkv5AtDkY1mFBkfBsbVBEFHfj4IoZvxkYCLJjbZH0oO0l)p7Z8DNPOGQD0KDwVBEjzfbqQVnZxsSzDMNCfB2TrfuCofrzqupumge5ivgrTrDpDrXtL4rNqsLnAXO5EDhfHGL8CKPdHiKBSGC0HoejMJaxTWm5Q82MgSizZT(Ok9sySMSG8AOxP0c(Br7Q1bnoF64Wm2IGBFy29RdI2olJ9NrLl(u6Z9RdZ2w4jEy8c)0yOOhdxucDvvBZMol4llI2TenAKwGDEoGDETg78KXoDnWLyx4kfH4AwXA)Sz7Yks6Jwui6sX4QcSwKldvy9InMSUEBEMHTRSUxm5R6sSRfJT5kdsblmJMceyKMz4FcMMztqSfb(cGKvpYVIPJo8ZHlbC6wwimf04(5jmgoNkzDOmtuvPXVixuSFpH9t3wMbpO)1O(ZLgHX7N)lSgdZHFKl0TFoBID)8yWxaU2x(wSNgKVlLrktHrmcCDO6xMm(8Xc51PKYYZGV6MRz9gFzs2dXlWSIljfIb5Ms0CaHjX69elX69Ndjwu0uwIfz6RCUgXLPwOstxds5MJzS9N6ghOv8x6A1lzqnfN5zchZNWwWG0fy1zqyT)u3ibdYZcdYRMbP7wwlxWlT1rO5wrBkHJXiOBDJn5WvRpCHAl9SwtGQgcJ0sNmbgyvpYBu6a8TZQBCKOI7gFoVM7iN(e9ebHafP7ll0URAGvOg6EJshCgR0x1rJvtRXkTAkuf3cJ(CeF7KKO8IFBehlNozsfPPPHBQyDOhM78okDU0FdS7vDrifxqRU9gug4KUglWiPP7(Fl0mX9d2pI5d(AgjVD3x)kZP8Bt(cUUWn(X78JqdkOfJPxlgtp5X8aIjOmGxMj0cpPZYts3OMl9kRYH5qhGinRlCNAek9(AfDn2gB7ic4(fVGHfvoSc1QunX8HGWhE70kvy5sK6Q0W7cxYu1fSyham5tjLQonv8scJPoSy5i7EUDuhoSF1WUAxL3YMmYW34C7GSnB9SeRP5bhdHQLQAqa5WCminGe9AsMI9nVoTFx)Uj6Bg3F8B7N)pkHZ(5)o)N)H9Z)5K73pFZUfSGd(iKB)9Z)JIOiGCac7hbl4biDqSVzHFwoFRy)rPOjUw4wjNyWmI7aXeaRpQjiMa2DWwF0EY5VNbZi3hcONmqHDNVeSfK2YaMG3MqEKsRdIHWykoQPqiya1gbmMG4KD3TU4l2bb78tvbz9rEqw)tEqwCkhZarlPCjKuI2pTJK(2JmHJz(WbcNV2VGMl32ljA(mhP5cPx)4hkWlgjKdhMxE3VpesmsE6dYYYRGOH)dPON)lqexvSn5IkgciM1qipe4CEC53TZp1popiGf77)Axw5pM4hnMNuhmBAoWiOQcgj2XBDv8)9Bs2fNxqzQlNbYhKpyUHzynCbR6wgilaSy6)JmSRinBvKa6E5zxXkwo)QC2n1hmR8zUzOLlZghglobdLUtR3JGVaNu7M5t5Fiqsf1VIYj5WschA2qLsCpf2XlghI2g0Sj5JA25AXnbDOmz4gsvNbAyiv91Oy5wAy0qGSG4LChDwMzilngqGIDJOQObgO6EFdlKkwxp0TuyG997xYtnfRZhSNd7IJc8ZwZR)IG4V(GEgA4OtJo5YEe24JQPLt1Zvu4IhMX(RjXzOJVuZUmYsDVEmhY7trSxE8pPQcu2Ku52CYQvbXzQvamYxS0p9tnqxPGZetrB7uAvSNOpo1sV1Vh0g4iVQgQ3SQeeycwJ07MvK2u5i6gyQ7fgSuC6LwFibduEsuRwcmNai0cqPqKVO4O0k7L2D2LMQBE9VWIYBxKpy(0F720e)fRB48e3rJCMYIAhKz)ug30zzTRa4b0EcKlJ6u)WIBnV87Ze3QjS)(6KDqTVYwAP4(TW)mMhjFGHoasday65SbimUesA73h4TEu0yz1(dBfB5LvhVG3iVFR8)zbSk44VSsPZlQ(X6zNxwDylkAE6Kj22uGtB6GyvjrLx4aYHMhMsNSuGMdL1uzHH64rdVuusMI8OMbmdj35(tnW99MOX(pOK9iwAjSs3019IerzrT4q33bfq7IJSQrhWcEnkrvQOwOr9sI4atBLlKBReXeipImTIXFYjccDOhBEOOKgpSKXvB4LS2whqAtAKyxtoXjWO2f8ITfBOoR9dvJE5(O5P5yK8jO5Ws0OUOHUWwzw14AuevyAWyywFwEYmpUwtfG8gsGGOFUOc45XzwMcx7Lm6FRQJL3HyREiLfMadyqs7wYG7gMBYl5vsRqFpuKYBaVnbz8Y(xFqfhyTuepXI7wdSEwegIwf2Lh8oxocLKKjsOTLXoILZCyZwy(NmJzLb4ZcWJ2zLnTWe)XMQejx1APvHuTZt0BvVfkiQlQwzrrCQlhHfIDfdQu(KXYYIsYL)36SuKcP1195PApt61ipemDXWPE(ofSjmPBMNiqkWtVlqEs04IHgrXqgSJaZmjBjVZJW5PUWU3v8cvO5UU2OlJCxEHeleWOXeMHDawFpK12oDbxxmDHU)W1hJHlRC(tbqn2TvWoHsnusO(S8EqSeqvzeLhBbuDTbGsF2FeUXN7ba3EXRQYYkKXWD88pVkmLNy0y2FFRFyk8BfGQrwxhJLajTLxEAlV8A1YlpRBJ6)z5f5Ylp7lVq6YXD51u3lWcTvfhYYlVMlVAuIfnxEHK1WUyZ4qkpaDZgYSsIksq5aIBsRuT7TM0YAXfkh0t7KxexTx(wt0HSBzdK63UpoN5m9DGakMYK4OhG)esbuC5gPi0VUnnbkOZm(MibmQxv1dqLlp1PfFMufA(7SFkKb44GWI2TdTBt47YJmCWsBAxu7IRzTDAEDvc1ZHf2isOikQAPekoeSjo9VxsOi5yTAExuGjvt8s)GXz(G)NDHqojhtfpcMbXg6XCzoLgmEOGbv51nLx(Hfnyp4Ypi6Pezp0oZMYzH2Ll()eKsFHODZRds5Ze62e()hj2u3pxmwCCriwiTfLuO2u5JR6TjBcJ9ltD(MBXc6BrBo4GyiI5HZHtfQcrnqlSztfTLjUMY9XgRD(Hv0)tMCHH1(2G0Szq2t04lv7XQupMv(BT)QMQ2557Xky3Jn7if9kTOthTvNsXHn9gKhlU9kxfHiRZX28KfoDY34JhzIbjk1Obs7jhAFvQiRUtAgVuQDL17WI7tSN5pbDlU5nBHnD2N9olHh5OI)rw5zgoAEoWgCLPsRx2Wm(uPtzOgfIU9bnW8deTg4ySRoMkXRC6u(8AfFe7axPtxdWDCk1mMz0GQvLpgtzc6AOPN3uR1vO7eH0To1a14qukckLSf0OWPmmNbxzuYNvFeYKZHO9bGfPxctvzaC3AXCOg(wWhBgXVWp6HTquEdQT9j(1zXj3RmR1ImTBEzRTPlBUk6OME(3vFJpZ5sUCNPBGfO7ERC1hAtFQjcZbBhUQ1wAQYu9eo0y5s(YMTwRUrkqu)BZsI2Lhm7Rmzmfs9qb(ixMLp18KSXlG02pjRuMM24)MMLbQQf1XzL7a4CYw4tWRXbcYplnpyMfB8vqXol2MTKoYOhOfNpYBeIRbdICt7BJZ3(1QdjqgzzErz8iuHID5Xia5t412XiRsl84geHg5hYKiyJ9szjOCKtcqTqLMkGRQVtZGObfLpW2f5ZGIr5cdTpr6ZBSd6iR0njJAraK3SX3oQR2R)4wyWSNRwET6a6GMo2C(ev0G8BBSBrwrhBg2KKDG716zfX)Zt1JX3IhtC3(oCE(pMT4bMFtCeZ4d7dhGeLTrvZ2U6kv8D0UWMfErjJG5ig)0BuRYqHxywf0vvvJPn22a1qw1zeIDNSoB82vOELbaQ47GQSj4MBucJGlFGDKflTpOxOwj7EwDlz6ujfWn8IqO5Te5mE9us4dIKiz9lEuU89xLTes)laJiD32C1yE5QjlTzuEo9glFDaTHT2MXFcc(QLRdtQkH9SIn8qXKdFV(N5ZSuadjNfwu(F10iuVa3Xai)AQblZQke3)nBQiNVKP8yz9xGYF6v7N)llEaEwfHtgqzTf83RofeqFHJbHEYiPkHk6jhHTCBA8KecSuSRges5VEngZZJfJqJK3Pl32gMs(cDLVP6kqJBQthYtTYnT5a0IGyGDUxlSn5c7ZPClynto6jpqTKxRyAipKgoCnn2k2MZSLVX0Tdz33n6UfERytYYUetjeikzxJeCBV7xjthX)VzvJlxUThhUOZCPVvSb9OP6z2WtYAkukR4yehKMbKtXZ28PmpYV(E)uiJQz3CnVsed3SnjnV8iB)CgQvFH)9C4urXS4XRUWm(zSYFxEszPjY8qn(o44s9R)g)KAn9h2p)djXSrK38ZvxGlQ2EgqHdDfvZvumRBdN(Lr2GU(R9Jg0PEUG0H(PhvCNa613IfAWT51BHoeF3rfFpUq)7pQqFkbZgB1N2qyAbAJH5SNMH58J8WS)xrucuFpU2onaE4iRScnnKetxNopGaQAjqtdWAT2YvMDeJjKn6iujefoyOIo1RbTwm5tq090YAcO3tQ)PGUsgX0HnA6Y0H83Du5keqxZLznGtKGAhHTM)64iUU38nuRn5iI4uaVJyo6YLcLSTBHcHNmP03bwAOQHE2sDhkpXpAJc6Z)JJW9G1jXzXRsIIsUNNOe)DPWLJ79bW5(V4KViok(foQxDx6F7U8Q(XVhHwbOTCVxUe68s)C)B9Zc(b2ekSZEAjyMyAUY1(S2nttPwP6(vrxJI(9UYtNAks5d17aLgIi4x(koc9675KNR7)R(1PIJqS5DHI(QCYllfhhbP7ofnqJCRQOdZ3IdtT450GlX2I6iSp4vIFdG6XKpCmHns1sPbFd1dU(yOf7vY2sEzwHUSNpCOTDKrurdVC6ONvUZmJE2WHWG)Yth9IHs79WlpF0OxmDYKk8TDq)nvq)nwGoLtfMOotP6bJYMQn2EtijnlGUbzrcAbDretBhxNqa1El4pZ(l9enmDKhn1CANouV9(2d8UgBWFQXDpl6jKwnEbsXMcx7fVWBqQYDMXvsF0Zi(Ok8TRW)nuWNkqIYx1ON3k)ljYtxhxrre43bdvu6vSt8TJIpo5R54a1JtwGEAY74XoTJg9N6Pzu648abu7fTRhN11eqTN52eAp65r5PXZO(2RounHI3tR2PjSHb4YZJl6ZQLalRp7V49s1kSPHG8DVcFSm1DLbTr2(lbd6dYvJXIQxUpeUtxw7UzBmcMP8BXbcZtRzxmC1lb7(0SpA0SL6czCN2sT0MhGDP(Cub))H7CiCNgUVtiEpyOzr0bN4apKbed44ZEM1dk4Ltg94JonqMtOq9qAcHyJ2ilR6Fkylp9CfRmfAxEf6RnQ6SrZU4hDVO68PXhDA2I9vV495Oc()d35q4o0Qo9oQ6iqWXVTQorqiuvNp9SLNEUIvMcDC89HxNMbkVefRo5meqwVp9m47aIVXpJf)2dMW76U0VaVdynRTm2Spl2tJyUA36)bPduWAG1yc3R6qFc4oGVq9aBcDlBVhblfY2iruclrDW7iZa18Aq8(0ZGVdio1Qq0U0VaVdyTPvFKDR)hKoqb4Rer6qFc4oGVORfB2EpcwkKTrMBvGALlaeavQzNa6uZaTrZob0d1T4Jm4DaWBttwmMFis3Mzc4u9Zr831HbepM1EW7QAvJAT7o4BRa(HMiQJm4DaWUnFs3phXFxhMdsSXDhUpiXg3bF7fBGhJzeGv(ZobepCG45cqAe1(j1xukfaQ6ozDqJgkVLvvc6uwL7GMWsCB4)4JNOX6Q(kweO0JK54BP0(m6fdNo(8xsSeN1kYacVM4JgD1qZjJKsWvFeNADelE)YHV7LkJjmh(AT50rpB6ewWZIuk8N45S38KpN9MVrZzVPCotSsSX(px(bTA5mfqALILg7ECnqqFy1XalvhvgOMvwxnn72izOJQJerzFP9YTlGpARuzSLc4sp57Aag5XGVbqj2OUEOM5PaDZ3TDnWt)WU3yiiQdN0J5zfHAqpOJR6t(b6acVI8ynwO0QLvzhHyzVStr)Fmy3Rvc)X50K(KwRF9GwgI6mRhG8FMRYS)Cw)xgHA)SU8ivK9prhrakpa65H54OzHcS9n2tPRr5AevxJa6DmQRGUVPachm6dkGa09ZIR((0U(neNvUrI1z1y3wXnamLHPEys8yEg(MsyGQpW7JJfvkWEuzhhvG3phZ)JJ1zkW236a)2omDKj5r4pqp4vQhvOf6xkRAqN8sB11bq7sqvd8exrQUcC9lXunOtDhNwd(N84OBEXiWVi0B(OdreSDzULAzS2pnUqDCIb8jcQISikEO8eqvk)SsT9TaCDANPPbQiTZLhwBeaJ0LJiWTcw33IoN2jWUpmg3jWN0JSyFd16jssjzpAj5NiW1PQRGgOwLDr7Yre4wbR7L8Gtlm6(WyCHbvP7DyAnoQa3kypqv9hBW1JXDCmHnvfEDyltoQa3kypqDBhBWDmNT6ry7qvf1IjRJkWTc2dtvJJ48Hb8XebwSmyvzWLTiUcc5aLl6uzrG6gAPKvphPcXO0ljqHkbEh6Tt3XBNQEsUrs8tcANm1Xku)cO)n5gPUJ3Ef7)1FHZsbqo1tnreaF7MRzoJTkms8CgKnwC7h8Ylf3zoVk2FtWLL6gMnTQqPEftaCN43hJEfg84JkntE683)RUJaEeia6Dnqncy(6by)V(FTF(pbaK9lWJTY(Qxu9S6R7(xTF(YWphUe4N3(W(5fgM2ppzftOfMcyDOCd1REPSk2sD2VdY0fAAk6VK6iPry8(5)cRXWC4h5K3(5RHelfNaRfanX8h1K0G8DPSzYPWigbpfMv)YKXNpUnCZIQ76vjBVmlipCvjpDAX)Fga7lzG8vmw0YqaMsZ3Yfog1b7Z4b6RU(8ooNmCNpaFpZaEahGV2Wq9ougQxFYqpoNx02ZqjorKTHHwwLNnu3iZTE8XHQnOugZYAHenwEYGqB7Z1N7g02xdFlAlq5oHuDPcLMTIY9qPCpkkhPU)Lv)rt54N4i021OCpRuU3br5vpoo6lJ8KxgnvAruxko4dQ2GpKsd2u1CtKyeTY1fzk2XIe2uDDtKTsTXgzHLZLlSw1cRwG3UiyS0Fdu5Khb5dSP7IwuX2RUuLyCbRRhRn(X78JWCzcPmFBdO9Wbnvfe7cOtVxvVtzumQvnCTDI6I(1fGR(W0woeGFn8Fv8U16cOYY9HGveXweGH2Qr0iW6M18R8ky1hpxhqLsRHL3QKv28FNlFAjvKcxBLi4VHcgwqm1f8l3n23)h)2(5)JYbz)8FN)kdYcW4NtUF)8n7wW8a9JWvJ5(5)rHRQqqfWdZeZdv4T0L9nLVLI7N)JsUSETWqVl0vnlr8uZ)QYCfC57MalCz)AqUrm(VZ3i17dbmiaellHjuSQmj97URc7xgWKa2WdLI58Fm4oCwYU0fCx5bckcO9G4KD3TU4l2bon)tvoR)rUZ6)tUZ6UqCYiZ2kuP3iVT)7dXjXPfK3PUrDfIBmJkfyadz57VnV73ZCafIW6bzHpEC))HumvLVgMfmOFxofcSWKyneMvUh6SO1UBNFQFCEqalIO)1USYFmXpYPOH46qkO2YxOmb1EMBu773KSloVaVvxDbaeMNlQhcYLuCgXTqko4awmn(rMIbxiHQzmqpc6IU3klvYPLpSojbgI3RuGcWiZ4eIXKnsl8JIMv8pNbDQyeRg)m7DT0SKd9uCr0AVRvo04aulVoFT3X6en(QWvx2i7JdgEc3bOMpmPgJBAeZjq0x28lpN5sPL3ZCreFA5ru87Imbw)lkg9yoNcV(VduE5FV4Y7wSCKmdHnYn5hfudWl4ypAuF72AfmY5)tIXk)Zd4dGEKP72o4exhz8zu)KayeHFV(zc8Ql9S)LSbQ(T3RjmUCA5YO3N8t1RH(nynKy5kBWzGV2dfbJSPa0aIeswWxqExU1geLxTwyCoH6Taw7dl6sXO9kL3TqMh0aCe(fv94nkDXApGqSEarcqfP1ql5Lp(OkZ9IZgzLalgyM(o(YpxjxTvrTNIRd5r6vC9XhrzexCEdYOwyOxNiAYTsJHvlf1hh85GMLl4xs66V01x5DU(NZ0G4dM(tszr6Lx(5OFhFjqLnT3ZNezgTsY5lQRbBX6xSPrbvv7cSmsEvn)MYe3RhA3z5x8w5anLWMwWMoDsL(FSJnfieQJQlFGrQyJRKkbKzAsBmOtctqGptlFsAwaZ4CMeTHIEiFTM2gUWxrQJA8()xNFfMS7wMDi4TmTA1VYBwvPI8MAYq51xoDIWCMSzccECRe0S8HgL9V4TySBJ6MQ82cIqE(pdUrudHAxlaZqR5VOlmXrMceakQwSzgShmSq8KPUJYmYWtiIJTWqI0oPY1qD1LNrg5lXx8DGdf90O)DTDWNQK9yZSpm5hs3mi4omXWHOFI0ScpxxIelKi)qxoqK1nTgyFV)YhgvXklxPikw6kes)3Lg1UXgiC6CfZtiqRz6UmM160Y1SiSlY9siv7Dj6QPNxYbrzUeuFjBb5toTB0nL326eong3dSezv2MPbusGcbizZN1E283)4JotpxCkj7cCJRu7NEWAIesdEGVnb(nGIP23lcIgsjVHpGYqn1hv97iFNUlQSyiOqk2QAvv3Yoyjt2(3MSjmMpTYc8yZTTEkV26Bq8sEEyxMPp4tBXGJUMbBqWbjZoalskqaZ)tkMCL(sMncICZsrLJWhSuPd)aQ)YvUK38qsOe)Kkmn63uvQXrzj9gHHi8rkyyiRd0lzqshGQkjR4ch0eXKl7px9R1eAco5pzt49rkZJ9bcBKrHBPWGcKc8(8bU)88DX7k112cvyeIhA96GenW1BGWMN61wKW5XR0EfHuKK9h0EuIGxzTOgET3e8mG1csdxaPTem(WH951rCrTgtq2ycOne(y(GjhsDJiQLcMwk)g(lxMvYTKCtxkopu26PtiKB18agOX1bPjSv5bqW)mVUaYeIDV(89wfjP6j(TwtRZ8(YvFuStAd5Tq1dcbEco(R6jXLtjR2hk7(4HgtPhHXVyHTVCwWN54cBADCWxGIa8XhhQ3qymZJ9xQ)RvlMeP5w5qPpODazeoB90(LRc(N1s26JpIZMAqFGfGMKCbw))2DxF922gXW)Seu0uRKMej56wSbh)sbkwFyydlDVMeLy5gVABzyjV00hYN9rE)t3jrE6KJBxBrbcCL19hYJhpEK)iDahgCs7g36rgM1tLRqP6QN8Ld5UvpVPnhYDT(Uys(KI78M4S3MgA8EpamrC2LMnhy9qNoL(7ll2U4kPrPTCYZe0Z5OnSMFhlxFB1vdhnM85XWR7k0p2sO3DfNDPv8feUYbzets9y8AhqfmuteNmkwpimVDuTmrWMV5BBt5TpaNYuFglPFS2pMYlWu1QP1JfH7p721QwheZVqYskkkPvg5ZyqQrsmYZU7AdFBsq3EhkNwEEA3oqycBNyu(vVY3iJ)7upYy1VA0hLsB8xcOsOXbgJms0TccxRJwK(14zpE9VnhrDXFQIdKoqGLc0D841JZE8AWYQzN)I7QQwx(RND293F)P3xC)DG6bqsz5zLRZxS48K44xhFMy)WjZxnBBj0hVyIcbbVx9GXNLnbXaY8f9ONhLK(MeLnTNum7ebtc6AXdSWzHSZrivSD9lF8Az1marPb(PqhSKrPPV5xuM0IJMfm3Nqd8b54Iq)adFQEvfMjZcFy7hnIWll4UENPOmtfEqktLpvkVO1sya6aOLy(Q)T4tG01Nbb7vWbm4UozmOL22RLie(hR33IK8ab)kV9FXSDrz8ZqXy4)Vz7ARWFyZewc9bmJZZ)IYZNIJ7uNARaKMJFBSBC2k4CXSpcAQfP9rJG2yIQ0RIDD89S5BGRZKbgrHdW4kbwBGP6Vd6iQYWAYHcdsVddPmST493cBX)q2cXoCHG0FVc0vad6u8DZx9LhONGbhEEkRyhqBUp558h4rXy20hy9cbRHaO16dW0WA968PNo7HnzlqoiQpEk0LlbIwePaKEeUyd7u1BPjkBtLS5kndgVTV2SIUE9jHWnvXPzjPvTEfl9t2DEnBV(GO59P1XNVYb7w7vc3dr(JdT4vrc1km)QO6TBaRe6jSCxhpqlAD78F6e)2FCGVJKd3de1EtGuf1lBqR6dDm29j1HfKQMLimIjiuwwbBrNge2Wo0eBMzoxiKrM9opukiyNtDTW(04oCZXDE60xiXPVPjyhawtgqHUITlua)R5tTv25E3u257oH1OWLn9ChAgtCIcw6Jy(2t43HZcBl(iCVdTNHgpQDNAj2C0q0SObTuHiWOv(40OM2XLeXt2Djrzq9dXW1tPTOd7aDJmo7Qz0VppXy)zJZC5jZoqj1oYC()JEcqA1)KBVQfmq4H2AnHeaKdzBaj64YhN4e13HXHleWP)qDe6Fj4XWHN3GzL6CRSn4ufQ(Ho9Mffftnoc3Wi0wA0mrUSAy(MY8nOsPE2qfBynOsoVNnDbQiQ8Q)z70pUuXc7rRrjnqiae7quR3Zgd33nxWR6z7Uj7JOqci7D7NkL3opCBH4aFuqdezKx5gObmJuNyP7OH(DgQsJVsK8I5yIbG(ba3(rzpx5CRuhO5E3VbMiWptSmgG)WFBq9MrLJLHtPCHDH98j4uvUzL8uqJ5p1P9ye)8je4M)u5wdiv9MxYatwjhi1ZKMWiC)hK8vZgNWxOdnPjQTCzWbCI7eUUBSafh9vyQhYf02I80O6dSsp(gXnT)ZyxzrgrU90mVh8TUZ7MMDHvmX2DNiCqqErWOYq0x(UJxB6Shjgs6i)isP3yzYD0RHYuYipciTTmZR7mijKy1rCFOzcBQRoc4H0yThbefxkdrbNhHfNZ5XNWD5tmgK3X6sHgrZdVUu33)KIQWpumB2vGgqWYAzse2UskuB6kbf0zWjt7sGXoa5VoEVavo4sPrUlUxlQ7AkEGorRfzPn6xTCmWhWFMRk4AI6sWl1jVnMQYYcDUiikQOHSotwT2KDvRaWDAF48LlkQ0zoCIZr3vDwdp0vCdAWq4ZuVjygFCaXXvErC3YSpFLkY3AForl)AfrBNiKPZSmcHPkt5cXuZoNe7ukASEEuxIkmJs0HuLrM219g3ILJDLaYWFma5PvhQVJ75jr2vpjYQpZexGXSRcoPKcoPEk(l)8j4KYi4K(1sWjPZcMK9YFFeCsJSf5ctW5zYIQxXQfpG)nxI0arXvWO6d6jSW(jR8FiL(s9BGAdlWsFJlafo9XR)JnsukSkFU877U3UPqaxaN(zhfSB4ZN(OsSEbJPSkjCgg7g7iNQTMLie7j6CkR68CYjPwvKUgVtNn2oFRcbJ99J)NsZ)drZs38)uF7pICQ5B9K)N(dp)h7BXvPelaDdmHbSBs8YKPAxAZ2rS5qzaTUeXyDWLU7qcu)zDnGYaPEv1FY1wweG4KqSgyR0iwokKH1cwHKdRa7jSihpqOsRLKgf0uYcX(QPu9MfNepW8ulIiOrOvH2Y(I)hApAzU1LRAOV3r9wHUMymomgG2Sb3Qa2wniJGnnigJmE609XTW(4qdGOB8IYP0WiRAi2dWnjrCnP676hW2RwVIS)gm84bPhPDTXYcDfJd2bNVQmpY6BNI3ku2yNsaipNX1l1U8NMQM4SiAxmQJXURVlt8uHQN3vSz52fzyjOkBnyks2T31QqIjmRraLctnFdEuPO8tPJZcyJc(9WINnUmHRbxPAF5CCCqUb857k2I13aqqWPIYzQvzGbtVnd1uddrf(dHyP1p6vBClAqybOBHDL7IxQqSM4aoKM1eYbHNKEhNe9CLqE0ZhiI66XdJoAG1LXpEuu0rjXX2fAYHwfAsNOGns7)PGNbJtIdHQjWeJhY2NtbOi5KgKmyeqlAoLMMnEskjomC(eib74KtffUXj3rLccITnQxMoZx2d(PlQhRNnMF0Oyki6wZID18r6AVGOI6PgH0en4sBiC)nJlyfECT0DLJ)Z1XQNaN(TJZG5LRO9bFRo5v(6e2Gy0EQecPQwle1MMA582PtT69uvC0Je(Lo3KCqPtSA0ZzA0LxKTT6UInxEXfZx(2lRG)D5)9d]] )