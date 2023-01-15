-- DeathKnightBlood.lua
-- October 2022

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local L = LibStub("AceLocale-3.0"):GetLocale( ns.addon_name )
local class, state = Hekili.Class, Hekili.State

local PTR = ns.PTR
local FindUnitDebuffByID = ns.FindUnitDebuffByID

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
spec:RegisterTalents( {
    abomination_limb               = { 76049, 383269, 1 }, -- Sprout an additional limb, dealing 5,467 Shadow damage over 12 sec to all nearby enemies. Deals reduced damage beyond 5 targets. Every 1 sec, an enemy is pulled to your location if they are further than 8 yds from you. The same enemy can only be pulled once every 4 sec. Gain 3 Bone Shield charges instantly, and again every 6 sec.
    acclimation                    = { 76047, 373926, 1 }, -- Icebound Fortitude's cooldown is reduced by 60 sec.
    antimagic_barrier              = { 76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by 20 sec and increases its duration and amount absorbed by 40%.
    antimagic_shell                = { 76070, 48707 , 1 }, -- Surrounds you in an Anti-Magic Shell for 5 sec, absorbing up to 10,782 magic damage and preventing application of harmful magical effects. Damage absorbed generates Runic Power.
    antimagic_zone                 = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 53,910 damage.
    asphyxiate                     = { 76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation                   = { 76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and grants up to 100 Runic Power based on the amount absorbed.
    blinding_sleet                 = { 76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_boil                     = { 76170, 50842 , 1 }, -- Deals 630 Shadow damage and infects all enemies within 10 yds with Blood Plague.  Blood Plague A shadowy disease that drains 950 health from the target over 24 sec.
    blood_draw                     = { 76079, 374598, 2 }, -- When you fall below 30% health you drain 1,777 health from nearby enemies. Can only occur every 3 min.
    blood_feast                    = { 76039, 391386, 1 }, -- Anti-Magic Shell heals you for 100% of the damage it absorbs.
    blood_scent                    = { 76066, 374030, 1 }, -- Increases Leech by 3%.
    blood_tap                      = { 76142, 221699, 1 }, -- Consume the essence around you to generate 1 Rune. Recharge time reduced by 2 sec whenever a Bone Shield charge is consumed.
    blooddrinker                   = { 76143, 206931, 1 }, -- Drains 3,378 health from the target over 2.7 sec. You can move, parry, dodge, and use defensive abilities while channeling this ability.
    bloodshot                      = { 76125, 391398, 1 }, -- While Blood Shield is active, you deal 25% increased Physical damage.
    bloodworms                     = { 76174, 195679, 1 }, -- Your auto attacks have a chance to summon a Bloodworm. Bloodworms deal minor damage to your target for 15 sec and then burst, healing you for 15% of your missing health. If you drop below 50% health, your Bloodworms will immediately burst and heal you.
    bonestorm                      = { 76127, 194844, 1 }, -- A whirl of bone and gore batters all nearby enemies, dealing 291 Shadow damage every 1 sec, and healing you for 3% of your maximum health every time it deals damage (up to 15%). Lasts 1 sec per 10 Runic Power spent. Deals reduced damage beyond 8 targets.
    brittle                        = { 76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    chains_of_ice                  = { 76081, 45524 , 1 }, -- Shackles the target with frozen chains, reducing movement speed by 70% for 8 sec.
    cleaving_strikes               = { 76073, 316916, 1 }, -- Heart Strike hits up to 3 additional enemies while you remain in Death and Decay.
    clenching_grasp                = { 76062, 389679, 1 }, -- Death Grip slows enemy movement speed by 50% for 6 sec.
    coagulopathy                   = { 76038, 391477, 1 }, -- Enemies affected by Blood Plague take 5% increased damage from you and Death Strike increases the damage of your Blood Plague by 25% for 8 sec, stacking up to 5 times.
    coldthirst                     = { 76045, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants 10 Runic Power and reduces its cooldown by 3 sec.
    consumption                    = { 76143, 274156, 1 }, -- Strikes all enemies in front of you with a hungering attack that deals 970 Physical damage and heals you for 150% of that damage. Deals reduced damage beyond 8 targets.
    control_undead                 = { 76059, 111673, 1 }, -- Dominates the target undead creature up to level 61, forcing it to do your bidding for 5 min.
    crimson_scourge                = { 76171, 81136 , 1 }, -- Your auto attacks on targets infected with your Blood Plague have a chance to make your next Death and Decay cost no runes and reset its cooldown.
    dancing_rune_weapon            = { 76138, 49028 , 1 }, -- Summons a rune weapon for 8 sec that mirrors your melee attacks and bolsters your defenses. While active, you gain 40% parry chance.
    death_pact                     = { 76077, 48743 , 1 }, -- Create a death pact that heals you for 50% of your maximum health, but absorbs incoming healing equal to 30% of your max health for 15 sec.
    death_strike                   = { 76071, 49998 , 1 }, -- Focuses dark power into a strike that deals 1,579 Physical damage and heals you for 25.00% of all damage taken in the last 5 sec, minimum 7.0% of maximum health.
    deaths_caress                  = { 76146, 195292, 1 }, -- Reach out with necrotic tendrils, dealing 281 Shadow damage and applying Blood Plague to your target and generating 2 Bone Shield charges.  Blood Plague A shadowy disease that drains 950 health from the target over 24 sec.
    deaths_echo                    = { 76056, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have 1 additional charge.
    deaths_reach                   = { 76057, 276079, 1 }, -- Increases the range of Death Grip by 10 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    empower_rune_weapon            = { 76050, 47568 , 1 }, -- TODO: Empower your rune weapon, gaining 15% Haste and generating 1 Rune and 5 Runic Power instantly and every 5 sec for 20 sec.
    enfeeble                       = { 76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by 30% and the damage they deal to you by 15% for 6 sec.
    everlasting_bond               = { 76130, 377668, 1 }, -- Summons 1 additional copy of Dancing Rune Weapon and increases its duration by 8 sec.
    foul_bulwark                   = { 76167, 206974, 1 }, -- Each charge of Bone Shield increases your maximum health by 1%.
    gloom_ward                     = { 76052, 391571, 1 }, -- Absorbs are 15% more effective on you.
    gorefiends_grasp               = { 76136, 108199, 1 }, -- Shadowy tendrils coil around all enemies within 15 yards of a hostile or friendly target, pulling them to the target's location.
    grip_of_the_dead               = { 76057, 273952, 1 }, -- Death and Decay reduces the movement speed of enemies within its area by 90%, decaying by 10% every sec.
    heart_strike                   = { 76169, 206930, 1 }, -- Instantly strike the target and 1 other nearby enemy, causing 532 Physical damage, and reducing enemies' movement speed by 20% for 8 sec.
    heartbreaker                   = { 76135, 221536, 2 }, -- Heart Strike generates 1 additional Runic Power per target hit.
    heartrend                      = { 76131, 377655, 1 }, -- Heart Strike has a chance to increase the damage of your next Death Strike by 20%.
    hemostasis                     = { 76137, 273946, 1 }, -- Each enemy hit by Blood Boil increases the damage and healing done by your next Death Strike by 8%, stacking up to 5 times.
    icebound_fortitude             = { 76084, 48792 , 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 30% for 8 sec.
    icy_talons                     = { 76051, 194878, 2 }, -- Your Runic Power spending abilities increase your melee attack speed by 3% for 6 sec, stacking up to 3 times.
    improved_bone_shield           = { 76042, 374715, 1 }, -- Bone Shield increases your Haste by 10%.
    improved_death_strike          = { 76067, 374277, 1 }, -- Death Strike's cost is reduced by 5, and its healing is increased by 10%.
    improved_heart_strike          = { 76126, 374717, 2 }, -- Heart Strike damage increased by 15%.
    improved_vampiric_blood        = { 76140, 317133, 2 }, -- Vampiric Blood's healing and absorb amount is increased by 5% and duration by 2 sec.
    insatiable_blade               = { 76129, 377637, 1 }, -- Dancing Rune Weapon generates 5 Bone Shield charges. When a charge of Bone Shield is consumed, the cooldown of Dancing Rune Weapon is reduced by 5 sec.
    insidious_chill                = { 76088, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by 5% for 30 sec, stacking up to 4 times.
    iron_heart                     = { 76172, 391395, 1 }, -- Blood Shield's duration is increased by 2 sec and it absorbs 20% more damage.
    leeching_strike                = { 76166, 377629, 1 }, -- Heart Strike heals you for 0.5% health for each enemy hit while affected by Blood Plague.
    march_of_darkness              = { 76069, 391546, 1 }, -- Death's Advance grants an additional 25% movement speed over the first 3 sec.
    mark_of_blood                  = { 76139, 206940, 1 }, -- Places a Mark of Blood on an enemy for 15 sec. The enemy's damaging auto attacks will also heal their victim for 3% of the victim's maximum health.
    marrowrend                     = { 76168, 195182, 1 }, -- Smash the target, dealing 789 Physical damage and generating 3 charges of Bone Shield.  Bone Shield Surrounds you with a barrier of whirling bones, increasing Armor by 689. Each melee attack against you consumes a charge. Lasts 30 sec or until all charges are consumed.
    merciless_strikes              = { 76085, 373923, 1 }, -- Increases Critical Strike chance by 2%.
    might_of_thassarian            = { 76076, 374111, 1 }, -- Increases Strength by 2%.
    mind_freeze                    = { 76082, 47528 , 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    ossuary                        = { 76144, 219786, 1 }, -- While you have at least 5 Bone Shield charges, the cost of Death Strike is reduced by 5 Runic Power. Additionally, your maximum Runic Power is increased by 10.
    permafrost                     = { 76083, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to 40% of the damage dealt.
    perseverance_of_the_ebon_blade = { 76124, 374747, 2 }, -- When Crimson Scourge is consumed, you gain 3% Versatility for 6 sec.
    proliferating_chill            = { 76086, 373930, 1 }, -- Chains of Ice affects 1 additional nearby enemy.
    purgatory                      = { 76133, 114556, 1 }, -- An unholy pact that prevents fatal damage, instead absorbing incoming healing equal to the damage prevented, lasting 3 sec. If any healing absorption remains when this effect expires, you will die. This effect may only occur every 4 min.
    raise_dead                     = { 76072, 46585 , 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts 1 min.
    rapid_decomposition            = { 76141, 194662, 1 }, -- Your Blood Plague and Death and Decay deal damage 15% more often. Additionally, your Blood Plague leeches 50% more Health.
    red_thirst                     = { 76132, 205723, 2 }, -- Reduces the cooldown on Vampiric Blood by 1.0 sec per 10 Runic Power spent.
    reinforced_bones               = { 76165, 374737, 1 }, -- Increases Armor gained from Bone Shield by 10%.
    relish_in_blood                = { 76147, 317610, 1 }, -- While Crimson Scourge is active, your next Death and Decay heals you for 355 health per Bone Shield charge and you immediately gain 10 Runic Power. -- TODO: Death's Due...
    rune_mastery                   = { 76080, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by 3% for 8 sec.
    rune_tap                       = { 76145, 194679, 1 }, -- Reduces all damage taken by 20% for 4 sec.
    runic_attenuation              = { 76087, 207104, 1 }, -- Auto attacks have a chance to generate 5 Runic Power.
    sacrificial_pact               = { 76074, 327574, 1 }, -- Sacrifice your ghoul to deal 1,110 Shadow damage to all nearby enemies and heal for 25% of your maximum health. Deals reduced damage beyond 8 targets.
    sanguine_ground                = { 76041, 391458, 1 }, -- You deal 5% more damage and receive 5% more healing while standing in your Death and Decay.
    shattering_bone                = { 76128, 377640, 2 }, -- When Bone Shield is consumed it shatters dealing 88 shadow damage to nearby enemies. This damage is tripled while you are within your Death and Decay.
    soul_reaper                    = { 76053, 343294, 1 }, -- Strike an enemy for 503 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 2,310 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    suppression                    = { 76075, 374049, 1 }, -- Increases Avoidance by 3%.
    tightening_grasp               = { 76134, 206970, 1 }, -- Enemies hit by Gorefiend's Grasp take 5% increased damage from you for 15 sec. Additionally, reduces the cooldown on Gorefiend's Grasp by 30 sec.
    tombstone                      = { 76139, 219809, 1 }, -- Consume up to 5 Bone Shield charges. For each charge consumed, you gain 6 Runic Power and absorb damage equal to 6% of your maximum health for 8 sec.
    umbilicus_eternus              = { 76040, 391517, 1 }, -- After Vampiric Blood expires, you absorb damage equal to 5 times the damage your Blood Plague dealt during Vampiric Blood.
    unholy_bond                    = { 76055, 374261, 2 }, -- Increases the effectiveness of your Runeforge effects by 10%.
    unholy_endurance               = { 76063, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground                  = { 76058, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    vampiric_blood                 = { 76173, 55233 , 1 }, -- Embrace your undeath, increasing your maximum health by 30% and increasing all healing and absorbs received by 30% for 10 sec.
    veteran_of_the_third_war       = { 76068, 48263 , 2 }, -- Stamina increased by 10%.
    voracious                      = { 76043, 273953, 1 }, -- Death Strike's healing is increased by 20% and grants you 15% Leech for 8 sec.
    will_of_the_necropolis         = { 76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk                    = { 76078, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    blood_for_blood  = 607 , -- (356456) Heart Strike deals 60% increased damage, but also costs 3% of your max health.
    dark_simulacrum  = 3511, -- (77606) Places a dark ward on an enemy player that persists for 12 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    death_chain      = 609 , -- (203173) Chains 3 enemies together, dealing 425.7 Shadow damage and causing 20% of all damage taken to also be received by the others in the chain. Lasts for 10 sec.
    decomposing_aura = 3441, -- (199720) All enemies within 8 yards slowly decay, losing up to 3% of their max health every 2 sec. Max 5 stacks. Lasts 6 sec.
    last_dance       = 608 , -- (233412) Reduces the cooldown of Dancing Rune Weapon by 50% and its duration by 25%.
    murderous_intent = 841 , -- (207018) You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    necrotic_aura    = 5513, -- (199642) All enemies within 8 yards take 8% increased magical damage.
    rot_and_wither   = 204 , -- (202727) Your Death and Decay rots enemies each time it deals damage, absorbing healing equal to 100% of damage dealt.
    spellwarden      = 5425, -- (356332) Rune of Spellwarding is applied to you with 25% increased effect.
    strangulate      = 206 , -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for 4 sec.
    walking_dead     = 205 , -- (202731) Your Death Grip causes the target to be unable to move faster than normal movement speed for 8 sec.
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
    -- Talent: You may not benefit from the effects of Blood Draw.
    -- https://wowhead.com/beta/spell=374609
    blood_draw = {
        id = 374609,
        duration = 180,
        max_stack = 1
    },
    -- Draining $w1 health from the target every $t1 sec.
    -- https://wowhead.com/beta/spell=55078
    blood_plague = {
        id = 55078,
        duration = 24,
        tick_time = function() return 3 * ( talent.rapid_decomposition.enabled and 0.85 or 1 ) end,
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
    -- Armor increased by ${$w1*$STR/100}.  $?a374715[Haste increased by $w4%.][]
    -- https://wowhead.com/beta/spell=195181
    bone_shield = {
        id = 195181,
        duration = function() return talent.iron_heart.enabled and 32 or 30 end,
        type = "Magic",
        max_stack = 10
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
    -- Strength increased by $s1%.
    -- https://wowhead.com/beta/spell=324165
    --[[ deaths_due = {
        id = 324165,
        duration = 12,
        max_stack = 4
    }, ]]
    -- Talent: Haste increased by $s3%.  Generating $s1 $LRune:Runes; and ${$m2/10} Runic Power every $t1 sec.
    -- https://wowhead.com/beta/spell=47568
    empower_rune_weapon = {
        id = 47568,
        duration = 20,
        tick_time = 5,
        max_stack = 1
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
        duration = 24,
        tick_time = 3,
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
    -- Time between attacks increased by 5%.
    -- https://wowhead.com/beta/spell=391568
    insidious_chill = {
        id = 391568,
        duration = 30,
        max_stack = 4,
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
    -- Covenant: Surrounded by a mist of Anima, increasing your chance to Dodge by $s2% and dealing $311730s1 Shadow damage every $t1 sec to nearby enemies.
    -- https://wowhead.com/beta/spell=311648
    swarming_mist = {
        id = 311648,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    -- Talent: Damage taken from $@auracaster increased by $s1%.
    -- https://wowhead.com/beta/spell=374776
    tightening_grasp = {
        id = 374776,
        duration = 15,
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
    -- Talent: Maximum health increased by $s4%. Healing and absorbs received increased by $s1%.
    -- https://wowhead.com/beta/spell=55233
    vampiric_blood = {
        id = 55233,
        duration = function () return ( level > 55 and 12 or 10 ) + ( legendary.vampiric_aura.enabled and 3 or 0 ) + ( talent.improved_vampiric_blood.enabled and 2 or 0 ) end,
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
        if data.cooldown == 0 and data.spendType == "runes" then
            setCooldown( action, 0 )
        end
    end

    if talent.umbilicus_eternus.enabled and buff.vampiric_blood.up then
        state:QueueAuraExpiration( "vampiric_blood", TriggerUmbilicusEternus, buff.vampiric_blood.expires )
    end

    if buff.empower_rune_weapon.up then
        local expires = buff.empower_rune_weapon.expires

        while expires >= query_time do
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, expires )
            expires = expires - 5
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


-- Abilities
spec:RegisterAbilities( {
    -- Talent: Sprout an additional limb, dealing ${$383313s1*13} Shadow damage over $d to a...
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
        cooldown = function () return talent.antimagic_barrier.enabled and 40 or 60 end,
        gcd = "off",

        talent = "antimagic_shell",
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
        cooldown = 120,
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

            if talent.hemostasis.enabled then
                applyBuff( "hemostasis", 15, min( 5, active_enemies ) )
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

    -- Talent: Drains $o1 health from the target over $d.    You can move, parry, dodge, and use defensive abilities while channeling this ability.
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

    -- Talent: A whirl of bone and gore batters all nearby enemies, dealing $196528s1 Shadow damage every $t3 sec, and healing you for $196545s1% of your maximum health every time it deals damage (up to ${$s1*$s4}%). Lasts $t3 sec per $s3 Runic Power spent. Deals reduced damage beyond $196528s2 targets.
    bonestorm = {
        id = 194844,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 10,
        spendType = "runic_power",

        talent = "bonestorm",
        startsCombat = true,

        handler = function ()
            local cost = min( runic_power.current, 90 )
            spend( cost, "runic_power" )
            applyBuff( "bonestorm", 1 + cost / 10 )
        end,
    },

    -- Talent: Shackles the target $?a373930[and $373930s1 nearby enemy ][]with frozen chains, reducing movement speed by $s1% for $d.
    chains_of_ice = {
        id = 45524,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "chains_of_ice",
        startsCombat = true,

        max_targets = function () return talent.proliferating_chill.enabled and 2 or 1 end,

        handler = function ()
            applyDebuff( "target", "chains_of_ice" )
            if talent.proliferating_chill.enabled then active_dot.chains_of_ice = min( true_active_enemies, active_dot.chains_of_ice + 1 ) end
        end,
    },

    -- Talent: Strikes all enemies in front of you with a hungering attack that deals $sw1 Physical damage and heals you for ${$e1*100}% of that damage. Deals reduced damage beyond $s3 targets.
    consumption = {
        id = 274156,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "consumption",
        startsCombat = true,

        handler = function ()
            -- trigger consumption [274893]
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

    -- Corrupts the targeted ground, causing ${$52212m1*11} Shadow damage over $d to targets within the area.$?!c2&(a316664|a316916)[    While you remain within the area, your ][]$?s223829&a316916[Necrotic Strike and ][]$?a316664[Heart Strike will hit up to $188290m3 additional targets.]?s207311&a316916[Clawing Shadows will hit up to ${$55090s4-1} enemies near the target.]?a316916[Scourge Strike will hit up to ${$55090s4-1} enemies near the target.][]
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

        spend = function () return ( ( talent.ossuary.enabled and buff.bone_shield.stack >= 5 ) and 40 or 45 ) - ( talent.improved_death_strike.enabled and 5 or 0 ) end,
        spendType = "runic_power",

        talent = "death_strike",
        startsCombat = true,

        handler = function ()
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

        talent = "deaths_caress",
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

        max_targets = function () return buff.death_and_decay.up and talent.cleaving_strikes.enabled and 5 or 2 end,

        handler = function ()
            applyDebuff( "target", "heart_strike" )
            active_dot.heart_strike = min( true_active_enemies, active_dot.heart_strike + action.heart_strike.max_targets )

            if pvptalent.blood_for_blood.enabled then
                health.current = health.current - 0.03 * health.max
            end

            if azerite.deep_cuts.enabled then applyDebuff( "target", "deep_cuts" ) end

            if legendary.gorefiends_domination.enabled and cooldown.vampiric_blood.remains > 0 then
                gainChargeTime( "vampiric_blood", 2 )
            end

            if talent.heartbreaker.enabled then
                gain( min( action.heart_strike.max_targets, true_active_enemies ), "runic_power" )
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
        cooldown = 120,
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
        cooldown = 60,
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


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_phantom_fire",

    package = "Blood",
} )


spec:RegisterSetting( "save_blood_shield", true, {
    name = L["Save |T237517:0|t Blood Shield"],
    desc = L["If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r expression) will try to avoid letting your |T237517:0|t Blood Shield fall off during lulls in damage."],
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "ibf_damage", 40, {
    name = L["|T237525:0|t Icebound Fortitude Damage Threshold"],
    desc = L["When set above zero, the default priority can recommend |T237525:0|t Icebound Fortitude if you've taken this percentage of your maximum health in the past 5 seconds.  Icebound Fortitude also requires the Defensives toggle by default."],
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "rt_damage", 30, {
    name = L["|T237529:0|t Rune Tap Damage Threshold"],
    desc = L["When set above zero, the default priority can recommend |T237529:0|t Rune Tap if you've taken this percentage of your maximum health in the past 5 seconds.  Rune Tap also requires the Defensives toggle by default."],
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterSetting( "vb_damage", 50, {
    name = L["|T136168:0|t Vampiric Blood Damage Threshold"],
    desc = L["When set above zero, the default priority can recommend |T136168:0|t Vampiric Blood if you've taken this percentage of your maximum health in the past 5 seconds.  Vampiric Blood also requires the Defensives toggle by default."],
    type = "range",
    min = 0,
    max = 100,
    step = 1,
    width = "full",
} )

spec:RegisterPack( "Blood", 20230106, [[Hekili:T3t)VnUTs(3sWb4yVRRp)rC2T9zhGR7(6EBrFff1BV73SmTKSTUvwYp9rstrG)B)nd)suuKsYjozZD4akAtehsoC4W57jD5OLFz5cpsM)YFD8WXtgoA41dg((jxnAYYfz3FWF5Ide3Vs2c)qezp8V)XW4yp8R3hgt8WzNgNN4cJSiyFEijlio6djKnzlxSopim7ZrlxBEhgbt9GVl85PdxUyxGNNpdw)u3LlwUiminlLIEj35KFa(PFLIT(rK1H(El)XLliU42b7eIuoRJdcztpj4aBG)i1)4kkkd)hy4JRc2i)WVfs2MdJhKECvuC2Xv4YDR)GLlGfiZpjGSCXfhx5fNnGTbhOtyqwG7xdI2UmdqDliuw8(1PzXr(MWNVigKHn3hNFC1oYTWVo9TiAIda0d)qahtZaYFA)JRgddLKh5J)8KHWV875rbUWHi(o)e4BKipCwKmeXJ2YwNuLdxgj0pkZhGko54Qp6tY2XN1h9Dj3Rcj78vIoSoFZMbRHL0jLIzdOi2Xv3ai9XvDy4g8RZbmv87bUohqSBGN)Ma3Gm2WtgshhiSDfi1GujE7G7r6aojLcPhIQoaM64HiQG8FCvp8gyILBa2SsZsc(QXlbobybfa2fXhIHRxGdo(ameNG4fFxeJIrwhNJeN4JR8)Zdbj(SpJt8ZUa0FHeghL24SQsvDPBlBthK4VNeGlZmGuT11BWEYFEC1dpCCff2a37DYOBKrircYv1rqsDCjj(PPwPixcl4hOGGhnvCTlhfuzckHdxXWttWXzwMDC1TeyXautDyNe)nWoUZ5wsi(EeyUhb3U0)XkNeaZqjJhWtS33jl2zcDefQXunQXPFEEIhM6pdJhwCbTNKKeFxIFKhI4xBfXzsPC8J83hGVWNtjxDWhtjB9ZK0IdUzotMsr0PMg3lWNIdDzI4aX4HaYtoaOOKo8w6C7vGKkqHy57SWSPcMcQ3egQF0keN8uWD37DdHzrxHuujcG4V3k59IAK40PKqls028a4IFBsCEKxHmlKRHdtE0U4W7RarpD5uY9cXTV3kUb6lddfNKbfA9y8su8ZDhoAQZMe2oqczKXrdgzuFjSFJgQTHXhGTYpRaEbJo(taxn9XZ4PusCzuANpjjJl194Q3iPd0VVgUH(kCdjjdVHI09ORVdZ8c1fWj5GdO7NII6A(lOjgFAHVFLVonSMSljLPYisYPOQ9WXlF)bhYE4kmZI(fedPMcig1fKqdZI9lfOncNUcRItsnxD0RwQKOD(7JbjqPbPkcIMA9QvxBqj6wHCZX0LPK(gRkWRJUwGhQdcysgsX2qYdZmzhxjLrFgSsjjj)q2afzJbWdeqUQ)F5BYSRgNpGh4R1q0mudgn0md)1t12fn7hiaX56PAMLnqLZ2klLbD2C8PSc4lKVMkPk3OChf(pJJt5s8adUuEpQDa)DMEmDdsXd6vc7spU6UaKkOz6qF0wkjc0Nzj0pQSL4NY25NCxaA4XuXYvIEzvNQ1Bjh)Wu4NNkV0UYKfaIjFiw8qw3qicE9H)oOjiNzm9hjrU0F43PM5(FdQAakBft58yG5GVTCUJbe45Ib15L21pqcHN6abb(xucuwktxiIcOBqkCYUaSoSFXbhI5NeNMjMTjvZLVCjbCt(8yMWgKHxFXBGF0nooenGvzttqWbfuept6ofqf46Vg1Z5Sjojlil3ZOH3FMd1Xv)KamPFqxIwvNrykBtbkki1byxH7bYEWhuU)kuhM8IJUmt43KXRhgB3)fzpy2n(KK71x(HbLnjjsQBpiYnEpE)X2oNPCtqcwVXrGbsxxQ5cxXWXB5BVd9fhDSEM0XxWsRcVj6xLd0ZhTZ4v1JG(D76hl5RklvbjSIzlsUvC1Yihmr9yhYVqo88q36x5(P)5Luc6uFKKsdCITJmBlOlpcpSbQyIKVvOrbDyEBm9GxNBYmdB4(GHyNWIOsdyZR4r2IuZJXTyDDIYiNODHEHbVhzQdQyfOn3bStxlf6gPeCwCScblT9UhXhv2xgF7vcNPq10)b1)KJR(e1bfoV6cUJnIpZ(ktt)hsc2NIYhatCZHvPsWYALRtwClsXaLADUQSphABj1xOjuhVL83UmS2jLJ08lHAdvYPXzFIXoQ)Ph4O(LLyT2pm(oUrdA4dACjSauRlRzw)NOf6fZs1Wvec0GlWqG(fH5IzGcLQZWwfCeCi)znYwgCyBwBCyRgFzQZhrbVy1Gomdd8eL7XMHLQ2wBnC08XzewlQGBsSIDRnh1wZnbpndiHpsRn5tMUHwdeeb2xKGtcDoaF0ebzrbma)hau7OkeAWI4c4ONMpTlopScRPA0APGToonDtW2Dv5I9bjnTNsleQDa4r2IBTcNlnYguM7yuNbaiDhDuHqYAZ0ZQBwTT7m34BbOI09rq(gfePqWZBj6d4ruGxTxSiVVlIhAeaX2niIModL7FjIqrFBw0YupBXCmUPaQ2Jj0tnMDJTXN(yxK6dka3XSdduY5UJQqJh5eMsQGioHABy8AKLs4qt)cLHuHHkx8UicWxffjESDlaj9uwo(ooHJpf7N(wnqlsZSSJmtn7ifbF5k1Gw3qq8EVuXw9X9ESnJJ3gdotdg46LcQwjPgVv(Kag0IIpHqXihFbzH9JOpkfFo9OmZsAgZs1JNjNcB7KbBaXrBww6VNkQw95Mj08VVNRj43Z9JuequMp66Q8rA8bmPjAmdAXXXTuCZOpFVU2i7pLEcRnqv0dX)XA0oFAAtrQ9VeSFnGWrgDdNual8OD)A6wy1sYQYSmAlJfPSulkvL2kSPKjw5eetsXsDtTQIi0NSSu9AsWwnAdKyKIdGTq2wDOSQyoE6NXtHUkFBIOtbx58ijE6hKU3TlafGOisznaEEQVxlpL9ARYzbkWI96HeFWFY1KIOVkwKnHGDEUSe2xCYOtsUegIyRUZzVYYmmtkQ4fKPlzPIykIPea9Iu3BiqZnhO4USet(SNzetHX(f187wLVKNjZVn7PMHaP7EYP79Lo91L42bKbKUJBGZ6qINFjU92XopRUZzpXwwxAckbHPef0uA3TeBfdXI)0VEEI3nnLn(Vbxjkj5QAbaif1BnFI6oE5(QSobSLYGx91jG9CXxry4OHkcMOkRYIt2Bms1UTiNVVx4EPT0(oNokG6FNUUg1cdONPqMvTYb6P7WMmdY1M59soXmZGiaT0axnoSTHuyVYfSRbu601nc2(UvfAPNZ7ASL5Dmr6wpzzkzFZG9snB4aF2dYgnyhj1bSj0brhUQWx0b1mS93scIb6AWF5xKueq0Ei1ul080CQ97YmxgFlncIYFpBhM04T0GrGlFQQznCWCg5Wg6rz0L8CmUUd5lYGMoBJloB28wJdQEWxK600jtlsdJZuMMbBF0w6XnT0JnU0JnP3UoS2gkxsCwDzRsPohmaLu9lcA70)Y1S3tMeIIBo5cibgxwBKg67)QeE9GTwhH3(s)QJ6mQTuNr2OoJzYflItynLWn3wrVC7zCbJpYhPfS9MwvaZ2tDBPvdJoKEATmfZ9gsTLmiiYds5CSQ8DvldVQ20uXJnSTKxMEhjHML49u3)neADoahx9pAFKuoUAdstMG(W6dwE6LwnlIFVEjOd0GyGjatn0A4UikF)A8JXBe2KL2RebT1mNt0nzNzvqxehO2(0v36MsufQV0t4kVniaUkn7NKrePsSe)T80S8q4h(7y9LfiRXKySVhWVVio8wAXdqPxg(ED9AaAD66GiVbhyBJJpFx0Y(PaSB5lVtkB11DHJYtPdKZU89KO4aAMOxeiQvohSwZSUYLaC)EFVaSq6wmYCyKkGLfwCeWA0pLUdSXcn8ENVtE0DXjz7mM37fm44Hy7p4qw5oAI149wMDfVj4PdfSC3CiEnW7nJzOpvWMiby1gFSgy0PXuvkbrcCj)U5qvw8VzpZRyh)M8K7LIqKd5NK6NqBILYEtA3EAlUCjYebJWuR31xR4EejXLauHd5yf7vBCBOmX86fam22pAB2okRRyPcXmmK68)K7TDVpRCkNQEwbQUpw(NHoy8s1oVLCYEtqIpVSRQ6ITK0r26eVXb0W5(1unaTxu52J4qfAc40yc7Cq5XaBPtXHfnpf8MdeVHjub29VGVec2FigtKpvO9LSOvFjMRQ)zoCG8qbg7bWi5zX7j0gac80kc80AWXF(xOL5X7)bAbBcBfD4lnxdgxYYoILrfSGauDh9N9AATlvbiARSXQdPyDp(ZMo2SIl(0o3JMC2rU6x4Nif14jx4N1jE01rqUvFmhbPp6eV2KyzzNf1HPmb4jV8c)PEeR8Esk8S7(6W7cqoVl(taRXh6Os3GSAX8YGD(3KNWjyhsAQd3faCox4Na(IINRdD5JFgxwBi7ylR64w8CXmmN5L)jG42EWyeKZ7I)eW66EOyfSZ)M8eobMF0yaGZ5c)eWxJpBQo(zCzTHStnR82G97xwwbEnrKPX9qI56bDXaYBaKNXfxUSx)cqxQShs5RnI6gb5zCXhWnhBtCi4fjlEt5jeW3iWkFFzvDiQgnMz(IkbznwSrm4OHdydRqRlG2ZJ2)rKmYAsQ)pag)HX6a5MTyhOOAnU8KSd8kZ3P6z9u7c1wsrBKr8mT6gjaYWmEAuaDt1Tgfgbw2yyA0Pcw3b9WSuzhSfHhvkXNPebCHFxzMm8iIv(t8MGqztZLoqwkqVD()EruBWv6F74QIEN84pZNaaMs3xwduk9yjfQw1HKQlGiWY9XSNm3wjL0NMZN5xpLUjpNDP4FZsxkAhNTw5bCK(Q(XhMtBSZ(yCvdWvz(fz10vNp8G9s1qoMPqb1VOLiNZivNwVnQEizTkz)GnZPQuTKEcCpAUtgvxx9cyJreLtKE)2MgvuDnlAvXId9RGwouffR2TviPL39xDQ25x3mVObe7Cr3AUdE4bMDL6T6vVcAXRG2hS87hvuTj6GSrcBfzWyxTPqkET1lGLyJXdug5qtuez)a2kksfgJwsPEATYN65svQUuGIwR91P6h52CnBUOCnkJATV98QGlcbUiYCbBJl1TEvicVs67UQevzMjPhflzRStxtXXuQjrleKp8qTTA3nt6XzGmK5Y6yE()7wUw8QWu57sFaiF0QxYU8rvs2WS5nwIULGxKCcL5PvAUiRIEj2nB0WIR7hv7TPsmuTMP4vz7m6WC)S1SnhI5jpflEv1tALmZwRJ6AIe1PBL(tB2yGfc2WoL6jTzaZtpDc6tOzZAMQlx8(Sg0y(i6HPuhNPXy9)f7vSkm)cf)DXzoB(4oLQBXRUbUO6uTAjVz(ObVVh95SsroIaxqdFSD2LkkQ3bzmtuQTBVkqGxUE2sfLn0qziwtjVx3XG8VBuCzQ5o0sDR07rlf9GwKDqTH4O9oTQKIIQpXB69Fbc8K7WknduR(GMT4LEn3eM9c11unlmsU7)SbJlFjl7mjQoqkFCErXJvVXDCgb1sqJBTq1YpB2vwnEtX0)xxvqMbAdQsuTGVqcuBkUSBMO(W)M5D)(HFx3AkKS3mPNcz5fTiXmFQlcEhEKTgvsWgEBHtSdJDPUseRVHc)cFyRvIxL(Kk2OV2kmwpRLZLfgfdLAMurqj(bWK2HQsco1)gcxS)mzIsv7yRlWEdB5pRWf75)B5VtWgoRYMOSWhF9UQ4MPuZAUHzEtffWZNmSZfcNvT1fODSiiS(qxCIEFwyI3P4aQjQY50nV6JaIL9wnyhDRCTixEqXq1rPxAZAUj7E7OE9mEJoAyhtMMwbtlAdUMrZhnwAgfhp0a(O00yicXEGlkeY5J6ySz1Mnv)7GFY301stO92P9AyJl1BAmlRSTVLrq891tgtEmbyQsOKmf4jtBwz5K2ACTBgBXfOrgwYYzPXWF3s55NP74PV1EBB)g(jWulB)MX2PBfp4pPiTG4vPGZCtZbZXaoOK4Ogj2wOOSaYQ3cIZMAy9updcnRf)vMDME8Pke3xhvavel2jEKAMxuDZTWGpWDkW24AkU6hE4IAYLwVkBps5K1qTPrvlW5QsnGhLm)0NnYOCORhAAn1Q0zPgKQvhTrmQuDqBccz9pB84Qw3Z1CI5LVSfUDQe2Izl856vGfdDALpdZhp1i2xRagHWLrdphcxu21ZP9eNQKMZvyJTDS(wBQIKtsVAuAfJYmByCVoxypH(DQtiuTgpPq9(MA(0ZgzZ4r1OQnLXFPTCZYw)nX2nfCr(3IanHYGU9HMFb2gRcEFNUMnlyE3PFNnR26PNrrvd6mJ91ArXvZS9mOnhHrTAdPrH)MrD6w(b4ScrQv1u9omwrux0o7npFbolaQI(h(aIgZLR)jtwTJvQ6Bq6C1b51wTXXuQCzJJtRryJJWQGXwFegB8iyOW1l2SQLhUXXmEe0lZzJJy9iGfuCqM)((yxqlqwwoTS200TEDgBEDgFQRdfFSHoDQVisUWEb9(WdTrapOIOh4HOKMQxuTp8GTdyV2FchB8eo(BXjSAzdB4eYP9yRBMNTloH()k1(aT9)w(V(d]] )