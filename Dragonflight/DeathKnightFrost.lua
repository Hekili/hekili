-- DeathKnightFrost.lua
-- October 2022

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local roundUp = ns.roundUp
local FindUnitBuffByID = ns.FindUnitBuffByID
local PTR = ns.PTR

local strformat = string.format

local spec = Hekili:NewSpecialization( 251 )

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

    empower_rune = {
        aura = "empower_rune_weapon",

        last = function ()
            return state.buff.empower_rune_weapon.applied + floor( ( state.query_time - state.buff.empower_rune_weapon.applied ) / 5 ) * 5
        end,

        stop = function ( x )
            return x == 6
        end,

        interval = 5,
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

        state.gain( amount * 10, "runic_power" )

        if state.talent.gathering_storm.enabled and state.buff.remorseless_winter.up then
            state.buff.remorseless_winter.expires = state.buff.remorseless_winter.expires + ( 0.5 * amount )
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
    breath = {
        talent = "breath_of_sindragosa",
        aura = "breath_of_sindragosa",

        last = function ()
            return state.buff.breath_of_sindragosa.applied + floor( state.query_time - state.buff.breath_of_sindragosa.applied )
        end,

        stop = function ( x ) return x < 16 end,

        interval = 1,
        value = -16
    },

    empower_rp = {
        aura = "empower_rune_weapon",

        last = function ()
            return state.buff.empower_rune_weapon.applied + floor( ( state.query_time - state.buff.empower_rune_weapon.applied ) / 5 ) * 5
        end,

        interval = 5,
        value = 5
    },

    swarming_mist = {
        aura = "swarming_mist",

        last = function ()
            return state.buff.swarming_mist.applied + floor( state.query_time - state.buff.swarming_mist.applied )
        end,

        interval = 1,
        value = function () return min( 15, state.true_active_enemies * 3 ) end,
    },
} )

-- Talents
spec:RegisterTalents( {
    -- DeathKnight
    abomination_limb            = { 76049, 383269, 1 }, -- Sprout an additional limb, dealing 3,724 Shadow damage over 12 sec to all nearby enemies. Deals reduced damage beyond 5 targets. Every 1 sec, an enemy is pulled to your location if they are further than 8 yds from you. The same enemy can only be pulled once every 4 sec. Gain Rime instantly, and again every 6 sec.
    acclimation                 = { 76047, 373926, 1 }, -- Icebound Fortitude's cooldown is reduced by 60 sec.
    antimagic_barrier           = { 76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by 20 sec and increases its duration and amount absorbed by 40%.
    antimagic_shell             = { 76070, 48707 , 1 }, -- Surrounds you in an Anti-Magic Shell for 5 sec, absorbing up to 10,902 magic damage and preventing application of harmful magical effects. Damage absorbed generates Runic Power.
    antimagic_zone              = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 47,400 damage.
    asphyxiate                  = { 76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation                = { 76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and grants up to 100 Runic Power based on the amount absorbed.
    blinding_sleet              = { 76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_draw                  = { 76079, 374598, 2 }, -- When you fall below 30% health you drain 1,210 health from nearby enemies. Can only occur every 3 min.
    blood_scent                 = { 76066, 374030, 1 }, -- Increases Leech by 3%.
    brittle                     = { 76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    cleaving_strikes            = { 76073, 316916, 1 }, -- Obliterate hits up to 2 additional enemies while you remain in Death and Decay.
    clenching_grasp             = { 76062, 389679, 1 }, -- Death Grip slows enemy movement speed by 50% for 6 sec.
    coldthirst                  = { 76045, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants 10 Runic Power and reduces its cooldown by 3 sec.
    control_undead              = { 76059, 111673, 1 }, -- Dominates the target undead creature up to level 61, forcing it to do your bidding for 5 min.
    death_pact                  = { 76077, 48743 , 1 }, -- Create a death pact that heals you for 50% of your maximum health, but absorbs incoming healing equal to 30% of your max health for 15 sec.
    deaths_echo                 = { 76056, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have 1 additional charge.
    deaths_reach                = { 76057, 276079, 1 }, -- Increases the range of Death Grip by 10 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    empower_rune_weapon         = { 76050, 47568 , 1 }, -- Empower your rune weapon, gaining 15% Haste and generating 1 Rune and 5 Runic Power instantly and every 5 sec for 20 sec. If you already know Empower Rune Weapon, instead gain 1 additional charge of Empower Rune Weapon.
    enfeeble                    = { 76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by 30% and the damage they deal to you by 15% for 6 sec.
    gloom_ward                  = { 76052, 391571, 1 }, -- Absorbs are 15% more effective on you.
    grip_of_the_dead            = { 76057, 273952, 1 }, -- Death and Decay reduces the movement speed of enemies within its area by 90%, decaying by 10% every sec.
    icebound_fortitude          = { 76084, 48792 , 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 30% for 8 sec.
    icy_talons                  = { 76051, 194878, 2 }, -- Your Runic Power spending abilities increase your melee attack speed by 3% for 10 sec, stacking up to 3 times.
    improved_death_strike       = { 76067, 374277, 1 }, -- Death Strike's cost is reduced by 10, and its healing is increased by 60%.
    insidious_chill             = { 76088, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by 5% for 30 sec, stacking up to 4 times.
    march_of_darkness           = { 76069, 391546, 1 }, -- Death's Advance grants an additional 25% movement speed over the first 3 sec.
    merciless_strikes           = { 76085, 373923, 1 }, -- Increases Critical Strike chance by 2%.
    might_of_thassarian         = { 76076, 374111, 1 }, -- Increases Strength by 2%.
    mind_freeze                 = { 76082, 47528 , 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    permafrost                  = { 76083, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to 40% of the damage dealt.
    proliferating_chill         = { 76086, 373930, 1 }, -- Chains of Ice affects 1 additional nearby enemy.
    rune_mastery                = { 76080, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by 3% for 8 sec.
    runic_attenuation           = { 76087, 207104, 1 }, -- Auto attacks have a chance to generate 5 Runic Power.
    sacrificial_pact            = { 76074, 327574, 1 }, -- Sacrifice your ghoul to deal 756 Shadow damage to all nearby enemies and heal for 25% of your maximum health. Deals reduced damage beyond 8 targets.
    soul_reaper                 = { 76053, 343294, 1 }, -- Strike an enemy for 510 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 2,344 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    suppression                 = { 76075, 374049, 1 }, -- Damage taken from area of effect attacks reduced by 3%.
    unholy_bond                 = { 76055, 374261, 2 }, -- Increases the effectiveness of your Runeforge effects by 10%.
    unholy_endurance            = { 76063, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground               = { 76058, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    veteran_of_the_third_war    = { 76068, 48263 , 2 }, -- Stamina increased by 10%.
    will_of_the_necropolis      = { 76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk                 = { 76078, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.

    -- Frost
    absolute_zero               = { 76094, 377047, 1 }, -- Frostwyrm's Fury has 50% reduced cooldown and Freezes all enemies hit for 3 sec.
    avalanche                   = { 76105, 207142, 1 }, -- Casting Howling Blast with Rime active causes jagged icicles to fall on enemies nearby your target, applying Razorice and dealing 307 Frost damage.
    biting_cold                 = { 76112, 377056, 1 }, -- Remorseless Winter damage is increased by 35%. The first time Remorseless Winter deals damage to 3 different enemies, you gain Rime.
    bonegrinder                 = { 76122, 377098, 2 }, -- Consuming Killing Machine grants 1% critical strike chance for 10 sec, stacking up to 5 times. At 5 stacks your next Killing Machine consumes the stacks and grants you 10% increased Frost damage for 10 sec.
    breath_of_sindragosa        = { 76093, 152279, 1 }, -- Continuously deal 1,016 Frost damage every 1 sec to enemies in a cone in front of you, until your Runic Power is exhausted. Deals reduced damage to secondary targets. Generates 2 Runes at the start and end.
    chains_of_ice               = { 76081, 45524 , 1 }, -- Shackles the target with frozen chains, reducing movement speed by 70% for 8 sec.
    chill_streak                = { 76098, 305392, 1 }, -- Deals 1,161 Frost damage to the target and reduces their movement speed by 70% for 4 sec. Chill Streak bounces up to 9 times between closest targets within 6 yards.
    cold_heart                  = { 76035, 281208, 1 }, -- Every 2 sec, gain a stack of Cold Heart, causing your next Chains of Ice to deal 153 Frost damage. Stacks up to 20 times.
    coldblooded_rage            = { 76123, 377083, 2 }, -- Frost Strike has a 10% chance on critical strikes to grant Killing Machine.
    death_strike                = { 76071, 49998 , 1 }, -- Focuses dark power into a strike with both weapons, that deals a total of 597 Physical damage and heals you for 25.00% of all damage taken in the last 5 sec, minimum 7.0% of maximum health.
    empower_rune_weapon_2       = { 76099, 47568 , 1 }, -- Empower your rune weapon, gaining 15% Haste and generating 1 Rune and 5 Runic Power instantly and every 5 sec for 20 sec. If you already know Empower Rune Weapon, instead gain 1 additional charge of Empower Rune Weapon.
    enduring_chill              = { 76097, 377376, 1 }, -- Chill Streak's bounce range is increased by 2 yds and each time Chill Streak bounces it has a 20% chance to increase the maximum number of bounces by 1.
    enduring_strength           = { 76100, 377190, 2 }, -- When Pillar of Frost expires, your Strength is increased by 10% for 6 sec. This effect lasts 2 sec longer for each Obliterate and Frostscythe critical strike during Pillar of Frost.
    everfrost                   = { 76036, 376938, 1 }, -- Remorseless Winter deals 6% increased damage to enemies it hits, stacking up to 10 times.
    fatal_fixation              = { 76089, 405166, 1 }, -- Killing Machine can stack up to 1 additional time.
    frigid_executioner          = { 76120, 377073, 1 }, -- Obliterate deals 15% increased damage and has a 15% chance to refund 2 runes.
    frost_strike                = { 76115, 49143 , 1 }, -- Chill your weapon with icy power and quickly strike the enemy, dealing 1,300 Frost damage.
    frostscythe                 = { 76096, 207230, 1 }, -- A sweeping attack that strikes all enemies in front of you for 317 Frost damage. This attack benefits from Killing Machine. Critical strikes with Frostscythe deal 4 times normal damage. Deals reduced damage beyond 5 targets.
    frostwhelps_aid             = { 76106, 377226, 2 }, -- Pillar of Frost summons a Frostwhelp who breathes on all enemies within 40 yards in front of you for 573 Frost damage. Each unique enemy hit by Frostwhelp's Aid grants you 2% Mastery for 15 sec, up to 10%.
    frostwyrms_fury             = { 76095, 279302, 1 }, -- Summons a frostwyrm who breathes on all enemies within 40 yd in front of you, dealing 4,604 Frost damage and slowing movement speed by 50% for 10 sec.
    gathering_storm             = { 76109, 194912, 1 }, -- Each Rune spent during Remorseless Winter increases its damage by 10%, and extends its duration by 0.5 sec.
    glacial_advance             = { 76092, 194913, 1 }, -- Summon glacial spikes from the ground that advance forward, each dealing 722 Frost damage and applying Razorice to enemies near their eruption point.
    horn_of_winter              = { 76110, 57330 , 1 }, -- Blow the Horn of Winter, gaining 2 Runes and generating 25 Runic Power.
    howling_blast               = { 76114, 49184 , 1 }, -- Blast the target with a frigid wind, dealing 240 Frost damage to that foe, and reduced damage to all other enemies within 10 yards, infecting all targets with Frost Fever.  Frost Fever A disease that deals 2,876 Frost damage over 24 sec and has a chance to grant the Death Knight 5 Runic Power each time it deals damage.
    icebreaker                  = { 76033, 392950, 2 }, -- When empowered by Rime, Howling Blast deals 30% increased damage to your primary target.
    icecap                      = { 76034, 207126, 1 }, -- Your Frost Strike and Obliterate critical strikes reduce the remaining cooldown of Pillar of Frost by 2 sec.
    improved_frost_strike       = { 76103, 316803, 2 }, -- Increases Frost Strike damage by 10%.
    improved_obliterate         = { 76119, 317198, 1 }, -- Increases Obliterate damage by 10%.
    improved_rime               = { 76111, 316838, 1 }, -- Increases Howling Blast damage done by an additional 75%.
    inexorable_assault          = { 76037, 253593, 1 }, -- Gain Inexorable Assault every 8 sec, stacking up to 5 times. Obliterate consumes a stack to deal an additional 292 Frost damage.
    invigorating_freeze         = { 76108, 377092, 2 }, -- Frost Fever critical strikes increase the chance to grant Runic Power by an additional 5%.
    killing_machine             = { 76117, 51128 , 1 }, -- Your auto attack critical strikes have a chance to make your next Obliterate deal Frost damage and critically strike.
    murderous_efficiency        = { 76121, 207061, 1 }, -- Consuming the Killing Machine effect has a 50% chance to grant you 1 Rune.
    obliterate                  = { 76116, 49020 , 1 }, -- A brutal attack that deals 1,526 Physical damage.
    obliteration                = { 76091, 281238, 1 }, -- While Pillar of Frost is active, Frost Strike, Glacial Advance, and Howling Blast always grant Killing Machine and have a 30% chance to generate a Rune.
    piercing_chill              = { 76097, 377351, 1 }, -- Enemies suffer 10% increased damage from Chill Streak each time they are struck by it.
    pillar_of_frost             = { 76104, 51271 , 1 }, -- The power of frost increases your Strength by 25% for 12 sec. Each Rune spent while active increases your Strength by an additional 2%.
    rage_of_the_frozen_champion = { 76120, 377076, 1 }, -- Obliterate has a 15% increased chance to trigger Rime and Howling Blast generates 8 Runic Power while Rime is active.
    raise_dead                  = { 76072, 46585 , 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts 1 min.
    rime                        = { 76113, 59057 , 1 }, -- Obliterate has a 45% chance to cause your next Howling Blast to consume no runes and deal 300% additional damage.
    runic_command               = { 76102, 376251, 2 }, -- Increases your maximum Runic Power by 5.
    shattering_blade            = { 76101, 207057, 1 }, -- When Frost Strike damages an enemy with 5 stacks of Razorice it will consume them to deal an additional 100% damage.
    unleashed_frenzy            = { 76118, 376905, 1 }, -- Damaging an enemy with a Runic Power ability increases your Strength by 2% for 10 sec, stacks up to 3 times.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bitter_chill      = 5435, -- (356470) Chains of Ice reduces the target's Haste by 8%. Frost Strike refreshes the duration of Chains of Ice.
    bloodforged_armor = 5586, -- (410301) Death Strike reduces all Physical damage taken by 20% for 3 sec.
    dark_simulacrum   = 3512, -- (77606) Places a dark ward on an enemy player that persists for 12 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    dead_of_winter    = 3743, -- (287250) After your Remorseless Winter deals damage 5 times to a target, they are stunned for 4 sec. Remorseless Winter's cooldown is increased by 25 sec.
    deathchill        = 701 , -- (204080) Your Remorseless Winter and Chains of Ice apply Deathchill, rooting the target in place for 4 sec. Remorseless Winter All targets within 8 yards are afflicted with Deathchill when Remorseless Winter is cast. Chains of Ice When you Chains of Ice a target already afflicted by your Chains of Ice they will be afflicted by Deathchill.
    delirium          = 702 , -- (233396) Howling Blast applies Delirium, reducing the cooldown recovery rate of movement enhancing abilities by 50% for 12 sec.
    necrotic_aura     = 5512, -- (199642) All enemies within 8 yards take 8% increased magical damage.
    rot_and_wither    = 5510, -- (202727) Your Death's Due rots enemies each time it deals damage, absorbing healing equal to 100% of damage dealt.
    shroud_of_winter  = 3439, -- (199719) Enemies within 8 yards of you become shrouded in winter, reducing the range of their spells and abilities by 30%.
    spellwarden       = 5591, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by 10 sec.
    strangulate       = 5429, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for 4 sec.
} )


-- Auras
spec:RegisterAuras( {
    -- Talent: Absorbing up to $w1 magic damage.  Immune to harmful magic effects.
    -- https://wowhead.com/beta/spell=48707
    antimagic_shell = {
        id = 48707,
        duration = function () return ( legendary.deaths_embrace.enabled and 2 or 1 ) * 5 + ( conduit.reinforced_shell.mod * 0.001 ) end,
        max_stack = 1
    },
    antimagic_zone = { -- TODO: Modify expiration based on last cast.
        id = 145629,
        duration = 8,
        max_stack = 1
    },
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
        max_stack = 1
    },
    -- Draining $s1 health from the target every $t1 sec.
    -- https://wowhead.com/beta/spell=206931
    blooddrinker = {
        id = 206931,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Frost damage increased by $s1%.
    -- https://wowhead.com/beta/spell=377103
    bonegrinder = {
        id = 377103,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Continuously dealing Frost damage every $t1 sec to enemies in a cone in front of you.
    -- https://wowhead.com/beta/spell=152279
    breath_of_sindragosa = {
        id = 152279,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
        meta = {
            remains = function( t )
                if not t.up then return 0 end
                return ( runic_power.current + ( runes.current * 10 ) ) / 16
            end,
        }
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
    cold_heart_item = {
        id = 235599,
        duration = 3600,
        max_stack = 20
    },
    -- Talent: Your next Chains of Ice will deal $281210s1 Frost damage.
    -- https://wowhead.com/beta/spell=281209
    cold_heart_talent = {
        id = 281209,
        duration = 3600,
        max_stack = 20,
    },
    cold_heart = {
        alias = { "cold_heart_item", "cold_heart_talent" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
        max_stack = 20,
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
    -- Taunted.
    -- https://wowhead.com/beta/spell=56222
    dark_command = {
        id = 56222,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    dark_succor = {
        id = 101568,
        duration = 20,
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
    death_and_decay = { -- Buff.
        id = 188290,
        duration = 10,
        tick_time = 1,
        max_stack = 1
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
    -- Talent: Haste increased by $s3%.  Generating $s1 $LRune:Runes; and ${$m2/10} Runic Power every $t1 sec.
    -- https://wowhead.com/beta/spell=47568
    empower_rune_weapon = {
        id = 47568,
        duration = 20,
        tick_time = 5,
        max_stack = 1
    },
    -- Talent: When Pillar of Frost expires, you will gain $s1% Strength for $<duration> sec.
    -- https://wowhead.com/beta/spell=377192
    enduring_strength = {
        id = 377192,
        duration = 20,
        max_stack = 20
    },
    -- Talent: Strength increased by $w1%.
    -- https://wowhead.com/beta/spell=377195
    enduring_strength_buff = {
        id = 377195,
        duration = 6,
        max_stack = 1
    },
    everfrost = {
        id = 376974,
        duration = 8,
        max_stack = 10
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
    -- Talent: Grants ${$s1*$mas}% Mastery.
    -- https://wowhead.com/beta/spell=377253
    frostwhelps_aid = {
        id = 377253,
        duration = 15,
        type = "Magic",
        max_stack = 5
    },
    -- Talent: Movement speed slowed by $s2%.
    -- https://wowhead.com/beta/spell=279303
    frostwyrms_fury = {
        id = 279303,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    frozen_pulse = {
        -- Pseudo aura for legacy talent.
        name = "Frozen Pulse",
        meta = {
            up = function () return runes.current < 3 end,
            down = function () return runes.current >= 3 end,
            stack = function () return runes.current < 3 and 1 or 0 end,
            duration = 15,
            remains = function () return runes.time_to_3 end,
            applied = function () return runes.current < 3 and query_time or 0 end,
            expires = function () return runes.current < 3 and ( runes.time_to_3 + query_time ) or 0 end,
        }
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
    -- Deals $s1 Fire damage.
    -- https://wowhead.com/beta/spell=286979
    helchains = {
        id = 286979,
        duration = 15,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $w3%.  Immune to Stun effects.
    -- https://wowhead.com/beta/spell=48792
    icebound_fortitude = {
        id = 48792,
        duration = 8,
        max_stack = 1
    },
    icy_talons = {
        id = 194879,
        duration = 6,
        max_stack = 3
    },
    inexorable_assault = {
        id = 253595,
        duration = 3600,
        max_stack = 5,
    },
    insidious_chill = {
        id = 391568,
        duration = 30,
        max_stack = 4
    },
    -- Talent: Guaranteed critical strike on your next Obliterate$?s207230[ or Frostscythe][].
    -- https://wowhead.com/beta/spell=51124
    killing_machine = {
        id = 51124,
        duration = 10,
        max_stack = function() return 1 + talent.fatal_fixation.rank end,
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
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    march_of_darkness = {
        id = 391547,
        duration = 3,
        max_stack = 1
    },
    -- Talent: $@spellaura281238
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
    -- Suffering $o1 shadow damage over $d and slowed by $m2%.
    -- https://wowhead.com/beta/spell=327093
    pestilence = {
        id = 327093,
        duration = 6,
        tick_time = 1,
        type = "Magic",
        max_stack = 3
    },
    -- Talent: Strength increased by $w1%.
    -- https://wowhead.com/beta/spell=51271
    pillar_of_frost = {
        id = 51271,
        duration = 12,
        type = "Magic",
        max_stack = 1
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
    -- Talent: Dealing $196771s1 Frost damage to enemies within $196771A1 yards each second.
    -- https://wowhead.com/beta/spell=196770
    remorseless_winter = {
        id = 196770,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=211793
    remorseless_winter_snare = {
        id = 211793,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Howling Blast will consume no Runes, generate no Runic Power, and deals $s2% additional damage.
    -- https://wowhead.com/beta/spell=59052
    rime = {
        id = 59052,
        duration = 15,
        type = "Magic",
        max_stack = 1
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
    -- Talent: Afflicted by Soul Reaper, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage.
    -- https://wowhead.com/beta/spell=343294
    soul_reaper = {
        id = 343294,
        duration = 5,
        tick_time = 5,
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
    -- Talent: Strength increased by 0%
    unleashed_frenzy = {
        id = 376907,
        duration = 10, -- 20230206 Hotfix
        max_stack = 3
    },
    -- The touch of the spirit realm lingers....
    -- https://wowhead.com/beta/spell=97821
    voidtouched = {
        id = 97821,
        duration = 300,
        max_stack = 1
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

    -- PvP Talents
    -- Your next spell with a mana cost will be copied by the Death Knight's runeblade.
    dark_simulacrum = {
        id = 77606,
        duration = 12,
        max_stack = 1,
    },
    -- Your runeblade contains trapped magical energies, ready to be unleashed.
    dark_simulacrum_buff = {
        id = 77616,
        duration = 12,
        max_stack = 1,
    },
    dead_of_winter = {
        id = 289959,
        duration = 4,
        max_stack = 5,
    },
    deathchill = {
        id = 204085,
        duration = 4,
        max_stack = 1
    },
    delirium = {
        id = 233396,
        duration = 15,
        max_stack = 1,
    },
    shroud_of_winter = {
        id = 199719,
        duration = 3600,
        max_stack = 1,
    },
    -- Silenced.
    strangulate = {
        id = 47476,
        duration = 4,
        max_stack = 1
    },

    -- Legendary
    absolute_zero = {
        id = 334693,
        duration = 3,
        max_stack = 1,
    },

    -- Azerite Powers
    cold_hearted = {
        id = 288426,
        duration = 8,
        max_stack = 1
    },
    frostwhelps_indignation = {
        id = 287338,
        duration = 6,
        max_stack = 1,
    },
} )


spec:RegisterTotem( "ghoul", 1100170 )


-- Tier 29
spec:RegisterGear( "tier29", 200405, 200407, 200408, 200409, 200410 )

-- Tier 30
spec:RegisterGear( "tier30", 202464, 202462, 202461, 202460, 202459 )
-- 2 pieces (Frost) : Howling Blast damage increased by 20%. Consuming Rime increases the damage of your next Frostwyrm's Fury by 5%, stacking 10 times. Pillar of Frost calls a Frostwyrm's Fury at 40% effectiveness that cannot Freeze enemies.
spec:RegisterAura( "wrath_of_the_frostwyrm", {
    id = 408368,
    duration = 30,
    max_stack = 10
} )
-- 4 pieces (Frost) : Frostwyrm's Fury causes enemies hit to take 25% increased damage from your critical strikes for 12 sec.
spec:RegisterAura( "lingering_chill", {
    id = 410879,
    duration = 12,
    max_stack = 1
} )

spec:RegisterGear( "tier31", 207198, 207199, 207200, 207201, 207203 )
-- (2) Chill Streak's range is increased by $s1 yds and can bounce off of you. Each time Chill Streak bounces your damage is increased by $424165s2% for $424165d, stacking up to $424165u times.
-- (4) Chill Streak can bounce $s1 additional times and each time it bounces, you have a $s4% chance to gain a Rune, reduce Chill Streak cooldown by ${$s2/1000} sec, or reduce the cooldown of Empower Rune Weapon by ${$s3/1000} sec.
spec:RegisterAura( "chilling_rage", {
    id = 424165,
    duration = 12,
    max_stack = 5
} )



local TriggerERW = setfenv( function()
    gain( 1, "runes" )
    gain( 5, "runic_power" )
end, state )

local any_dnd_set = false

spec:RegisterHook( "reset_precast", function ()
    if state:IsKnown( "deaths_due" ) then
        class.abilities.any_dnd = class.abilities.deaths_due
        cooldown.any_dnd = cooldown.deaths_due
        setCooldown( "death_and_decay", cooldown.deaths_due.remains )
    elseif state:IsKnown( "defile" ) then
        class.abilities.any_dnd = class.abilities.defile
        cooldown.any_dnd = cooldown.defile
        setCooldown( "death_and_decay", cooldown.defile.remains )
    else
        class.abilities.any_dnd = class.abilities.death_and_decay
        cooldown.any_dnd = cooldown.death_and_decay
    end

    if not any_dnd_set then
        class.abilityList.any_dnd = "|T136144:0|t |cff00ccff[Any]|r " .. class.abilities.death_and_decay.name
        any_dnd_set = true
    end

    local control_expires = action.control_undead.lastCast + 300
    if control_expires > now and pet.up then
        summonPet( "controlled_undead", control_expires - now )
    end

    -- Reset CDs on any Rune abilities that do not have an actual cooldown.
    for action in pairs( class.abilityList ) do
        local data = class.abilities[ action ]
        if data and data.cooldown == 0 and data.spendType == "runes" then
            setCooldown( action, 0 )
        end
    end

    if buff.empower_rune_weapon.up then
        local expires = buff.empower_rune_weapon.expires

        while expires >= query_time do
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, expires )
            expires = expires - 5
        end
    end
end )


spec:RegisterHook( "recheck", function( times )
    if buff.breath_of_sindragosa.up then
        local applied = action.breath_of_sindragosa.lastCast
        local tick = applied + ceil( query_time - applied ) - query_time
        if tick > 0 then times[ #times + 1 ] = tick end
        times[ #times + 1 ] = tick + 1
        times[ #times + 1 ] = tick + 2
        times[ #times + 1 ] = tick + 3
        if Hekili.ActiveDebug then Hekili:Debug( "Queued BoS recheck times at %.2f, %.2f, %.2f, and %.2f.", tick, tick + 1, tick + 2, tick + 3 ) end
    end
end )


-- Abilities
spec:RegisterAbilities( {
    -- Talent: Surrounds you in an Anti-Magic Shell for $d, absorbing up to $<shield> magic damage and preventing application of harmful magical effects.$?s207188[][ Damage absorbed generates Runic Power.]
    antimagic_shell = {
        id = 48707,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "antimagic_shell",
        startsCombat = false,

        toggle = function()
            if settings.ams_usage == "defensives" or settings.ams_usage == "both" then return "defensives" end
        end,

        usable = function()
            if settings.ams_usage == "damage" or settings.ams_usage == "both" then return incoming_magic_3s > 0, "settings require magic damage taken in the past 3 seconds" end
        end,

        handler = function ()
            applyBuff( "antimagic_shell" )
        end,
    },

    -- Talent: Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by $145629m1%. The Anti-Magic Zone lasts for $d or until it absorbs $?a374383[${$<absorb>*1.1}][$<absorb>] damage.
    antimagic_zone = {
        id = 51052,
        cast = 0,
        cooldown = 45,
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
        startsCombat = false,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            applyDebuff( "target", "asphyxiate" )
            interrupt()
        end,
    },

    -- Talent: Targets in a cone in front of you are blinded, causing them to wander disoriented for $d. Damage may cancel the effect.    When Blinding Sleet ends, enemies are slowed by $317898s1% for $317898d.
    blinding_sleet = {
        id = 207167,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "blinding_sleet",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "blinding_sleet" )
            active_dot.blinding_sleet = max( active_dot.blinding_sleet, active_enemies )
        end,
    },

    -- Talent: Continuously deal ${$155166s2*$<CAP>/$AP} Frost damage every $t1 sec to enemies in a cone in front of you, until your Runic Power is exhausted. Deals reduced damage to secondary targets.    |cFFFFFFFFGenerates $303753s1 $lRune:Runes; at the start and end.|r
    breath_of_sindragosa = {
        id = 152279,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = 18,
        spendType = "runic_power",
        readySpend = function () return settings.bos_rp end,

        talent = "breath_of_sindragosa",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            gain( 2, "runes" )
            applyBuff( "breath_of_sindragosa" )
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

        handler = function ()
            applyDebuff( "target", "chains_of_ice" )
            removeBuff( "cold_heart_item" )
            removeBuff( "cold_heart_talent" )
        end,
    },

    -- Talent: Deals $204167s4 Frost damage to the target and reduces their movement speed by $204206m2% for $204206d.    Chill Streak bounces up to $m1 times between closest targets within $204165A1 yards.
    chill_streak = {
        id = 305392,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "chill_streak",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "chilled" )
            if set_bonus.tier31_2pc > 0 then
                applyBuff( "chilling_rage", 5 ) -- TODO: Check if reliable.
            end
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

        usable = function () return target.is_undead and target.level <= level + 1, "requires undead target up to 1 level above player" end,
        handler = function ()
            summonPet( "controlled_undead", 300 )
        end,
    },

    -- Command the target to attack you.
    dark_command = {
        id = 56222,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "dark_command" )
        end,
    },


    dark_simulacrum = {
        id = 77606,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

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
        charges = function() if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 30,
        recharge = function() if talent.deaths_echo.enabled then return 30 end end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,

        handler = function ()
            applyBuff( "death_and_decay" )
            applyDebuff( "target", "death_and_decay" )
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

        startsCombat = true,

        handler = function ()
            if buff.dark_transformation.up then buff.dark_transformation.up.expires = buff.dark_transformation.expires + 1 end
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
        charges = function() if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 25,
        recharge = function() if talent.deaths_echo.enabled then return 25 end end,

        gcd = "off",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "death_grip" )
            setDistance( 5 )
            if conduit.unending_grip.enabled then applyDebuff( "target", "unending_grip" ) end
        end,
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
            gain( health.max * 0.5, "health" )
            applyDebuff( "player", "death_pact" )
        end,
    },

    -- Talent: Focuses dark power into a strike$?s137006[ with both weapons, that deals a total of ${$s1+$66188s1}][ that deals $s1] Physical damage and heals you for ${$s2}.2% of all damage taken in the last $s4 sec, minimum ${$s3}.1% of maximum health.
    death_strike = {
        id = 49998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return ( talent.improved_death_strike.enabled and 35 or 45 ) end,
        spendType = "runic_power",

        talent = "death_strike",
        startsCombat = true,

        handler = function ()
            gain( health.max * 0.10, "health" )
        end,
    },

    -- For $d, your movement speed is increased by $s1%, you cannot be slowed below $s2% of normal speed, and you are immune to forced movement effects and knockbacks.    |cFFFFFFFFPassive:|r You cannot be slowed below $124285s1% of normal speed.
    deaths_advance = {
        id = 48265,
        cast = 0,
        charges = function() if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 45,
        recharge = function() if talent.deaths_echo.enabled then return 45 end end,

        gcd = "off",

        startsCombat = false,

        handler = function ()
            applyBuff( "deaths_advance" )
            if conduit.fleeting_wind.enabled then applyBuff( "fleeting_wind" ) end
        end,
    },

    -- Talent: Empower your rune weapon, gaining $s3% Haste and generating $s1 $LRune:Runes; and ${$m2/10} Runic Power instantly and every $t1 sec for $d.  $?s137006[  If you already know $@spellname47568, instead gain $392714s1 additional $Lcharge:charges; of $@spellname47568.][]
    empower_rune_weapon = {
        id = 47568,
        cast = 0,
        charges = function()
            if talent.empower_rune_weapon.rank + talent.empower_rune_weapon_2.rank > 1 then return 2 end
        end,
        cooldown = function () return ( conduit.accelerated_cold.enabled and 0.9 or 1 ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( level > 55 and 105 or 120 ) end,
        recharge = function ()
            if talent.empower_rune_weapon.rank + talent.empower_rune_weapon_2.rank > 1 then return ( conduit.accelerated_cold.enabled and 0.9 or 1 ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( level > 55 and 105 or 120 ) end
        end,
        gcd = "off",

        startsCombat = false,

        usable = function() return talent.empower_rune_weapon.rank + talent.empower_rune_weapon_2.rank > 0, "requires an empower_rune_weapon talent" end,

        handler = function ()
            stat.haste = state.haste + 0.15 + ( conduit.accelerated_cold.mod * 0.01 )
            gain( 1, "runes" )
            gain( 5, "runic_power" )
            applyBuff( "empower_rune_weapon" )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 5 )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 10 )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 15 )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 20 )
        end,

        copy = "empowered_rune_weapon"
    },

    -- Talent: Chill your $?$owb==0[weapon with icy power and quickly strike the enemy, dealing $<2hDamage> Frost damage.][weapons with icy power and quickly strike the enemy with both, dealing a total of $<dualWieldDamage> Frost damage.]
    frost_strike = {
        id = 49143,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        talent = "frost_strike",
        startsCombat = true,

        cycle = function ()
            if death_knight.runeforge.razorice then return "razorice" end
        end,

        handler = function ()
            applyDebuff( "target", "razorice", 20, 2 )
            if talent.obliteration.enabled and buff.pillar_of_frost.up then addStack( "killing_machine" ) end
            removeBuff( "eradicating_blow" )
            if conduit.unleashed_frenzy.enabled then addStack( "eradicating_frenzy", nil, 1 ) end
            if pvptalent.bitter_chill.enabled and debuff.chains_of_ice.up then
                applyDebuff( "target", "chains_of_ice" )
            end
        end,

        auras = {
            unleashed_frenzy = {
                id = 338501,
                duration = 6,
                max_stack = 5,
            }
        }
    },

    -- Talent: A sweeping attack that strikes all enemies in front of you for $s2 Frost damage. This attack benefits from Killing Machine. Critical strikes with Frostscythe deal $s3 times normal damage. Deals reduced damage beyond $s5 targets.
    frostscythe = {
        id = 207230,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "frostscythe",
        startsCombat = true,

        range = 7,

        handler = function ()
            removeStack( "inexorable_assault" )
        end,
    },

    -- Talent: Summons a frostwyrm who breathes on all enemies within $s1 yd in front of you, dealing $279303s1 Frost damage and slowing movement speed by $279303s2% for $279303d.
    frostwyrms_fury = {
        id = 279302,
        cast = 0,
        cooldown = function () return legendary.absolute_zero.enabled and 90 or 180 end,
        gcd = "spell",

        talent = "frostwyrms_fury",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "frostwyrms_fury" )
            if set_bonus.tier30_4pc > 0 then applyDebuff( "target", "lingering_chill" ) end
            if legendary.absolute_zero.enabled then applyDebuff( "target", "absolute_zero" ) end
        end,
    },

    -- Talent: Summon glacial spikes from the ground that advance forward, each dealing ${$195975s1*$<CAP>/$AP} Frost damage and applying Razorice to enemies near their eruption point.
    glacial_advance = {
        id = 194913,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        talent = "glacial_advance",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "razorice", nil, min( 5, buff.razorice.stack + 1 ) )
            if active_enemies > 1 then active_dot.razorice = active_enemies end
            if talent.obliteration.enabled and buff.pillar_of_frost.up then addStack( "killing_machine" ) end
        end,
    },

    -- Talent: Blow the Horn of Winter, gaining $s1 $LRune:Runes; and generating ${$s2/10} Runic Power.
    horn_of_winter = {
        id = 57330,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "horn_of_winter",
        startsCombat = false,

        handler = function ()
            gain( 2, "runes" )
            gain( 25, "runic_power" )
        end,
    },

    -- Talent: Blast the target with a frigid wind, dealing ${$s1*$<CAP>/$AP} $?s204088[Frost damage and applying Frost Fever to the target.][Frost damage to that foe, and reduced damage to all other enemies within $237680A1 yards, infecting all targets with Frost Fever.]    |Tinterface\icons\spell_deathknight_frostfever.blp:24|t |cFFFFFFFFFrost Fever|r  $@spelldesc55095
    howling_blast = {
        id = 49184,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.rime.up and 0 or 1 end,
        spendType = "runes",

        talent = "howling_blast",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "frost_fever" )
            active_dot.frost_fever = max( active_dot.frost_fever, active_enemies )

            if talent.obliteration.enabled and buff.pillar_of_frost.up then addStack( "killing_machine" ) end
            if pvptalent.delirium.enabled then applyDebuff( "target", "delirium" ) end

            if legendary.rage_of_the_frozen_champion.enabled and buff.rime.up then
                gain( 8, "runic_power" )
            end

            if buff.rime.up then
                removeBuff( "rime" )
                if set_bonus.tier30_2pc > 0 then addStack( "wrath_of_the_frostwyrm" ) end
            end
        end,
    },

    -- Talent: Your blood freezes, granting immunity to Stun effects and reducing all damage you take by $s3% for $d.
    icebound_fortitude = {
        id = 48792,
        cast = 0,
        cooldown = function () return 180 - ( azerite.cold_hearted.enabled and 15 or 0 ) + ( conduit.chilled_resilience.mod * 0.001 ) end,
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
            interrupt()
        end,
    },

    -- Talent: A brutal attack $?$owb==0[that deals $<2hDamage> Physical damage.][with both weapons that deals a total of $<dualWieldDamage> Physical damage.]
    obliterate = {
        id = 49020,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 2,
        spendType = "runes",

        talent = "obliterate",
        startsCombat = true,

        cycle = function ()
            if death_knight.runeforge.razorice then return "razorice" end
        end,

        handler = function ()
            removeStack( "inexorable_assault" )
            removeBuff( "killing_machine" )

            -- Koltira's Favor is not predictable.
            if conduit.eradicating_blow.enabled then addStack( "eradicating_blow", nil, 1 ) end
        end,

        auras = {
            -- Conduit
            eradicating_blow = {
                id = 337936,
                duration = 10,
                max_stack = 2
            }
        }
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

    -- Talent: The power of frost increases your Strength by $s1% for $d.    Each Rune spent while active increases your Strength by an additional $s2%.
    pillar_of_frost = {
        id = 51271,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "pillar_of_frost",
        startsCombat = false,

        handler = function ()
            applyBuff( "pillar_of_frost" )
            if set_bonus.tier30_2pc > 0 then
                applyDebuff( "target", "frostwyrms_fury" )
                applyDebuff( "target", "lingering_chill" )
            end
            if azerite.frostwhelps_indignation.enabled then applyBuff( "frostwhelps_indignation" ) end
            virtual_rp_spent_since_pof = 0
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
        startsCombat = true,

        usable = function () return not pet.alive, "cannot have an active pet" end,

        handler = function ()
            summonPet( "ghoul" )
        end,
    },

    -- Talent: Drain the warmth of life from all nearby enemies within $196771A1 yards, dealing ${9*$196771s1*$<CAP>/$AP} Frost damage over $d and reducing their movement speed by $211793s1%.
    remorseless_winter = {
        id = 196770,
        cast = 0,
        cooldown = function () return pvptalent.dead_of_winter.enabled and 45 or 20 end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,

        handler = function ()
            applyBuff( "remorseless_winter" )

            if active_enemies > 2 and legendary.biting_cold.enabled then
                applyBuff( "rime" )
            end

            if conduit.biting_cold.enabled then applyDebuff( "target", "biting_cold" ) end
            -- if pvptalent.deathchill.enabled then applyDebuff( "target", "deathchill" ) end
        end,

        auras = {
            -- Conduit
            biting_cold = {
                id = 337989,
                duration = 8,
                max_stack = 10
            }
        }
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

        usable = function () return pet.alive, "requires an undead pet" end,

        handler = function ()
            dismissPet( "ghoul" )
            gain( 0.25 * health.max, "health" )
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
            applyDebuff( "target", "soul_reaper" )
            if talent.obliteration.enabled and buff.pillar_of_frost.up then addStack( "killing_machine" ) end
        end,
    },


    strangulate = {
        id = 47476,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0,
        spendType = "runes",

        pvptalent = "strangulate",
        startsCombat = false,
        texture = 136214,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "strangulate" )
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


spec:RegisterRanges( "frost_strike", "mind_freeze", "death_coil" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    rangeChecker = "frost_strike",
    rangeFilter = false,

    damage = true,
    damageDots = false,
    damageExpiration = 8,

    potion = "potion_of_spectral_strength",

    package = "Frost DK",
} )


spec:RegisterSetting( "bos_rp", 50, {
    name = strformat( "%s for %s", _G.RUNIC_POWER, Hekili:GetSpellLinkWithTexture( spec.abilities.breath_of_sindragosa.id ) ),
    desc = strformat( "%s will only be recommended when you have at least this much |W%s|w.", Hekili:GetSpellLinkWithTexture( spec.abilities.breath_of_sindragosa.id ), _G.RUNIC_POWER ),
    type = "range",
    min = 18,
    max = 100,
    step = 1,
    width = "full"
} )

spec:RegisterSetting( "ams_usage", "damage", {
    name = strformat( "%s Requirements", Hekili:GetSpellLinkWithTexture( spec.abilities.antimagic_shell.id ) ),
    desc = strformat( "The default priority uses |W%s|w to generate |W%s|w regardless of whether there is incoming magic damage. "
        .. "You can specify additional conditions for |W%s|w usage here.\n\n"
        .. "|cFFFFD100Damage|r:\nRequires incoming magic damage within the past 3 seconds.\n\n"
        .. "|cFFFFD100Defensives|r:\nRequires the Defensives toggle to be active.\n\n"
        .. "|cFFFFD100Defensives + Damage|r:\nRequires both of the above.\n\n"
        .. "|cFFFFD100None|r:\nUse on cooldown if priority conditions are met.",
        spec.abilities.antimagic_shell.name, _G.RUNIC_POWER, _G.RUNIC_POWER,
        spec.abilities.antimagic_shell.name ),
    type = "select",
    width = "full",
    values = {
        ["damage"] = "Damage",
        ["defensives"] = "Defensives",
        ["both"] = "Defensives + Damage",
        ["none"] = "None"
    },
    sorting = { "damage", "defensives", "both", "none" }
} )


spec:RegisterPack( "Frost DK", 20231119, [[Hekili:S3ZAZTXns(BX1wMM02IIZirl7usQQS(sUZ(2SBQ4KA)MihsouCwpKdVzgAf5sf)TFDdmpaWGgadF5K72VKitGPr3nA0VqdG78U7xV7tZcYdV7V7pW)cppV3137sFF)3C3NYFCD4DFADW0phCp8hRcwc)3FmnjlF74)J)BSLhJtcMHqilzt6uO1f55RZ(UZp)(O8fBM0FAYYZZIwUjoipkz100G554)E6539PjBIIZ)WQ7MOF4hE3Nc2KVij9Up9POLVhGC0SzH8UhMn9UpHD)mpVZ8U672oE7yOtBhVzncQ(B)42pw18fFNHg9yF7hamlCz4Q8Gy9DBav32oEEAYs2a8EPpzWq2N8Zb5txSDS3G((LFswD)g8UZ8rm4xJct3o(cVTJxNgUwQD2q)trRsGomDrWQ7XHe)h)Nb5lctJwDpm45jPlf(QRoZZ)7ehBV(d3oEjhiQK3G3CM)LqV)LWShxnnC22XpatDQu0GHN5)2AmzDAusAu(JAa3qo42o(3kyq)JjXr5HPS)Etwasa8r4xVyG83XNm(jr8uKzD5zxWNh(vGS)CiidgNCF00YUot)CXGloZ)kraJnRd8q)gkG4zBh3Dzq0QyGiZteidqoUN8NXX7Fm633o(VMggG0wYCCGwnln4(KSaPUZeifgf2SjmjnO)vc9Z)mFoX(9ZMfHJjkZfm7FTjlhLal)U4WVegZeccwn7C8xYd(m7FlIVCoEYgGL9d)Y)uAu8ExXOGqg5HFjinkysCy)1jjiKhLUzfIMzBqHP8fbaqEmzdmGPWm5Qe4Fw0tyuweUsS1GyGDmdyG4hTma4pmG1NTyc(PiaUBwnnomif)yKtVa)TPlcN(zS5vVa61QWWziMfTIn5vOl59OUKxVD8Knfakn8)ztukVJNDpOQQ)DFkoklpJPEcWV4Wr5bP3hMd)WFNP2lCfsPZU7Vc6AMIa9Upnh1Unklpn6ZHCnnPrR5n9jgmaXpgqGvmj5b8wG(aS6OauP2859)CumJZTmy6IOvH9bMWuO)xVDmOeOdJjenD06Khct7plCE00OIwhWA(zctc5pKmcw1pBeJLCxoOLubXvg70iGW3SMbOSW8rtswTjRFoOG5IbJ8xpL1GwSmlpaz6iEuZowK8aRttIdYYXH)cZdVkqlWKk6HXEZM(iO7AuPsefMpVvCSUSTJvnKsQu6GaAO78mq3oS8QF00WjW02NHzO0GvaB5gZSL3qocOepJREj9C)TaWhko8jclE7xawX2NWuZmkz(OSALmLdVawMUc7ZdrRaGHO5vKO5Z0VYVexzdExH(KUEeY7G1Dp9Kbj6H82NfYz0bFfMXNwjRbmvjYod0UKZmQHC2zH1KEpIvOan9wsAQgzHjyo6Ayk8D7fV5zirIZjFEv09lY7Jt7Gg67dRi6swibV4AgVqhZc85aSdLX6Y9tN1NPi9LG)csSL7JdMgfepky2xca74if5nOTKuyg1sipvfM7QeExgVYb5yoZykGCZsEyL(UwXAUvONYI99NTP0iyptln8OvSssrdQbyq60GvGbMK0uGWyaKwvPfbksz9CaiaroAbyW0OvmWtrGTGey0uvZyVhGW2X)xmqiQjmjlJnbnhLFhPvOJp9vnF7ZNIEgHbLcnQDnzrR2CunHvUI42ByIu4qSlF92XVfMY5F)Xb)yJWUJEEdy4xpZw1FMDJcSHynqDbP4uotOPK6mWB9gus)AbaLAhO)qGkVI9hfyg7dE4X0LzJMVj9rjKRAzPANkCnSN8K0MvlsIFef5dxDF(cjYqTnTyypQvbgDEXbUmH695bXW3nAAkeBZSAJbMMtQyjeS8rH)(6WPmVXrXKHsttgNljzHv8xIp)cZmoApXCGXrBAuhVZorEq5UI6WBq20(n6anBchTmzEPuNmpFUiijB0KGc9z9Spv)ofdR2ztxZ81WYCZLgLGatnLgWrwM1iWkccq2YvzW1DuJU97Hp9lHTiImNclrJAzn(gzFOGU840QGpZqk3EGufXKyWFvJRjjrfsWrlRt7qNj)Pmgru7DNQsaYKOJmrPx4XKSIMaguDPLHPWkZlbTYNvP7dChnejFu(bKL(kQuBrWY1sQfEj3JeZM7fDUYOZ0M49QYw7KyBPEmlXURt2U1bU7WQrQKeql3AeEANxVCi5WOkoBMLsnTD5ab9Ze2gO(wVR0ZSPJPxI8qL4VPCaapvrj88Kr(myl1ZZHX6T1ui32n6u7SWPbpAoK7dZqcMGssZcJdZYeKQPdq)WmQnuj2i(5DBshxRQBIZqi1oAcWTywzSK3yr5QONm7Qk290OSqciPdRHkUujoMrnSGY7agQnkCv4Yim32xFdlMMIGzl0PRKqfHCrvpG2Y0BRiHk)KRwRbcVtXS5tMqaBErCYXpnzHs1yWP2yKLK)Eqngr70JtjjzwsrS0JMh(fqlsb7vWMHtP3)zAZtBpdksmMxyl4TA6Gisr8(Nc4g0MH8u7WYyePuveW1dyiRQALWOnh2yoBNCnx1WNwLbUpNDIyHAn5zmJ0MqAv7zYoaRAx0HKv7zfSAsPRX00zLPQYQUvEtL0LbFkp5nm1BfnowZTw863b3zuvvR1urZHM5hY8GnX15vO8lxgb2QMNgg(1qrix6Gqz3agzWQ7XDwwTB0gyP9XxqeAf4(zW9q)YweghBo2iPKKfS8RJcMKLKoz06W0PWufd4dmgIWvdevLgKLfTmkUzYPktSK2TuPm7s224fwYBL9yY8U50XCwX6PJR91KvAdYlbeJaZF1FsPqp(xXBc5n0u0TWIvq0SrGbwKhnBwwFSWcks0AbbP2JWFhlKagscJ0iEHqblaxhhSAf6aKgB)Thhz6dewIsHfSDCLOTonBsCtYgQqdyhk2RhD(byNgAyHRB7skcslLYRaibDqlc12QWoYx7sGiPiSjVASjBNskgNnRIddGvRm1gR(6JAx50Otg2JwHT2q5JQd45IQm3wrTpc64ItwLPD8fA2LrwO7YJPe)BDn3t1JdN5EQRSfrEtj9OR9TrWASkVrvFKEq1tTBwX5WLmvTSniF0dHbRbWvQM0nWu3lDWYOn3ALce8pX5WsL21LludpUCEQui0gTYGeXwsrdxu6bVK7hrlxNM8fyjrTjEcg380O7r9A)E40niIlQhqEIaRNSVGyg39OmTQtO7ehfBqcIYxeHbR3jVssxAXg1go0WZ1IPRO5gZ31Ws3ceZDC72HhqqroBo)yskwRDybwgSgMLcy1)xcs9aAaowfILRh(FafVGmbUNE8Fkdl9VjrWekJdmnbBpz(8AuABrHeY((66dg(7fjBWYtautLYhn0lwS4(4fymw7GVhqhePra4nmJxyGmibmGrCX6ryL)bJxqCCFr(otmBuPNXiMtUqyuyCg83xuTUOltWOfC1xXDxMLOX69NM9p7ke68RkLqEz5pwp5(kUj7YM9gmqBCicsj6OMsQVWbnzY3UhTf77QnpcR1eJYsoXdndj35FEg4F(d0WavDR3UwXu5QCYM1QwiMCTqmB6KpRN)KRulDXCzNoC1xDhNJerEnIxs6Cjzwe6Zo28WQ6TYuSNMs49pbyrEaQ(P4qr8JyA7E92XFy6JyDcJECXQm7TJ)TsN)W(IE)Pe1ozQ)OYBqtBP6zVUW)5GXa7Ukypt(WzkdoL15KhDgsPPsnzu0HvGUkOBkOuHMjdw291k3AETI5mbrNI2DKX5mJ5BnLtNE12s5Tivf2KUOLAmtm0BIjzgl()DI)QBYLpDwJ3nMMZmLVPunDsSBjvFIf7Bqi0znVgFFqCVIQ(zX0tvbF9vhGVQlDYf98IKemSKVFkpodE4by8fGFa1GgJxqmcc(jiQWZHC(XoJ54Lp1UAAecLImCqq5XHrqKYuPWbaTT0YGCRlvVMM7jTvl4XGz5LQ457Az79KcB28bKWHDMqQxAsAyznqsvq73quTWMN5Qk7EKZtBm2QAdBRWSU8sjixj0uQglre1YwtAcrpq(w6yo)Ttvm6H28Pn8ypmY5gwkvbn4oh5UvlLnc0OKyqcVWpAN1bhbU8XKKTZARtdNMSCsG2A21HWn5kn7N71pkdw0p5XrpSimEnFdXkeHK6ZdlIYwZRaGOvtdsxfKhokAAb0L1fpYdIbCA8MzHvBP3UHD(oGD(Tg78fXoIuoiNzpbwXIGSrBY4BPr5cYwLQzRg77kX6R8NP(at9Cdbfw3RByBlzVwy4OJdzbsclmJMviqpfR()aonZpL1bvajREKHi1Nf9Li2PlEceHlNg5NEBgvcDOiH9LjBINYE43XZAnhX59Vg1FHWi0F74pangLJ)itOB7yyIfp40ysnrtsSd(qAy(MuGu8Wrmg9uP8xg0FyF9s(4513w2lHVUsyxBP56yMdRLO5JQgjw)tSeR)FoKy1IMIsSgNUA)gFtQbbPv5v8nB)u3iF2VYD)gA1v21K62zblSB76oPaRkdsx7N6gjyq(wyq(1miIT031f8c1wP2Imszkrokuf0rZsyKAR3ui7uB5o9jlqvdHEkbqsGbw1JCUuhWVDKW5iU6CqI3RkVYW0xvp1GqOI0YDM42gyLwdDNl1bNXk1vD0yLxnwPCspLXTO4VeZp)l1uo)34BpJ3GQnDrrdNx16qFdLPHnPZzblXIlzFes1lOv3Edk72gCaJu2oucfcqpRFqm4c(cGIxV5RFf8jFsYVRxv4YGvBcI3196xGkDEm9fhZDiKGI47dkUaJgLXU)I0fvjUvisomiIoL5mY0oIAanqFVyhw7((lKOYgx5ku7wOSR7kLVxM2Y3R)W3P4J6pNMKhof9kT8eQnNDlgH7a(xy7auuEwymSSfxK)d)Y)KDpqbXNLHjuzD4QzSoHnI1n30O187cPYDmF747X8EWUZD(j2o0xTx6GRMmAA74LSgcU)EOTm2P2a0wi52ziWTBZ2MFzTJm(d5rswM6kdNUKjXjjZyhpCfU0VW(2TJ)(YYkqBweBw(loK6rLpQgxctZct)Cr19rxhOwburDeVEdYy04cElavmkCLn6FTz294TaLopeBb0W0QHv(A8imPa68MQfaBEuAiB6tNthUNMglBhbRTMhiAHzTG7Xpcuvn9ZAleqjle2WgtOsxsSHgtDPy9C644046FrLUZfYxTMfCf5ssN(E0pHeWZcySWVRwArxNL4MM4w22lFH6wQR7HeImTuLdX5BKVwlitXj(ToUhoCuRCpSPou4f8BGLLfNKl(VvzPAww5QlkL27vIV2EDOORWdRmKCTMZ)gz1t2rAheiMVfDKnilVOyq4vWEtN4B0LEUphsIfvWOnbuOgsIs0zvSZkzdTHBuFkJVPS4KK2scAV4XublTHfkgc)vwf3X)8YlsrwTVTa(OqCtTG)t0YGI7YpWa8RXUHjZCc3S(mCasXEYkmL1b8lnpoO(zHmGXQPL(6m(PiX7RiX73kjEFRoL)NmjEF7s8A6YXvI3Z9qOvsyZUiX7BqIVr00nL414J0(OJDxIeuvnRipLi4ZY16w1y0txU4AipyXxih0H6Kv3BRkqsHWUmLTwBGu961rDrgjSvtE)hyH8Gx)QjyI3rrLnzIk)WkhpAwrY9rg1Rl7bQpmbJUK)zcjJ)Fa)u0C8ofnI3UDOnjHLIFr4OZV79rNOTCr4IArxLq9DyfUgjunASAPeQEiytC6pwsOgdrQlLQKIjsxy7vwAOLhSRFPwyef5a0BzwdPVIltq(3AmM81j8)VYLiy5xApgrflbnVFbzjiWqO62S4xkfsDoD6iC0iEtjpUfsjWNDvdlRcLMKIjrHZfyTDqdMSTXDeopPAOqZjNWSZeUX7kY(lBD71BLUQ5yb8hVrMw62SGUVAG8SWfnMfCVi6uZefFqNVjogyBC)7gjHSv5H2exS56dNU07SURH28U0TPGkg3WDw81OuOZkaBlp8ODd6zJ(LfZ21vT0Rk9eQxNGjjlJwXiHrXrlNy2mHRso7cABgNmElF4kA5Ga9HhZPtINYLGIhEjOudRPlaPdw63c(SUnLrIdOdum6bHMPZFHPJdybVY8zs8zo2pve56Bkpr3ueSHlCJJXSOatPChCSDExnQ6d7GX45vDz1XvSkkn0UrwNMvSn5yrtbHO1QawnlNxnqH7y1a6LnCIw)i5oe9eVn7iDYq22RooVvp)0GOoOgQfk12LzoZ0KXRAyRELrNt7wJMwxxCHG)L6Wjg5q7lKQojXlAdB(t0PLB5HXZbVtIfU6OJWYst3chDnEzI8QMTwN2lH1H4gfhVjpC0xdttK4o7kW750eVWM3HKF9DZnBkN21nJ2dTXAnnbIiClUytkxSONjzZdrbpKptpq08ZsS4o15RTfsWTKinaPEMNaT6c6bjf67)SEhLeEOCh6xSK10Nt(TDSlgizjRnQgA1uFLzY9E3IRg)t4jUPNvzTDFd))tUWZ)wQzpKAyH1v2bqXxwiebvWmrjPCJNzwfJA3wFzsIhGLQ7(31tZhH3PavjqrxGuQwWmjXArCK1mX9JtNYS5C7w1hqfd5hSfoY2ANlVCGmAyYtEzXDROJn3XeKpYs2GjWlyDXX504nfPnrVooqnqFwdYi3J34mw84SHdpsopLfa4gEBPayYA4hzOpD0KwsyGEh8Tl2zwRs1kdRkF88Slu6KMrXaenevUNGYjn85HsY)gV1MiClv6If8XrZwnJV5h4bPBhVOR)(KFO(Oe)3yhIoLuUxDJ4vQsv)17H599q0Wg1L5zvhQU(2QOanx)aT86IUyU2fMVjrAr6GXeiVoLR0sy)vNXeNXipWHcM0msk0Q5m9UR09(9k9zv9OcL40tPx6MdWZsHtxG)KWtZTwpSUdwmLHnx(6bF1DF6HGum3hzfflveedtAEX7L6lKoHRVyRWRgAg7AklytEsr1tXFUDXNi2)g7Yo7nF32XVpzfmISMFHglBaaX7uaDnvY9HU01737zdQ6mBPaDtwFvhLR0pkQ322kJa1LXTk0zpJYhtIy7h1mvwFM8B38O)rzEKaQkU9QayLwPG9fhfm(YJcuhEGHQ2PEUut7M2jKrtPVLAvWtd90XLDjRliZm(Lw4le07D9fVPtQ0dwYTcT(CV3wIno)nNdFtfM82)WGjV7payIwHQIZNs7KQiuSUZI7ANT2BOQLElUZ0Bh9sO0q8UgxbZ0DnK7OQOdM9dJZvNsnavmLYRTgvML61zJJWR(2XwbGnV2SDuwt92QwbUuxt2oc96BK6g4R6fFTkeFNEiQehQcyjsmNJWENx39naQht(WXe2A2Qbf4BOucuhdVbg8gJhf2l04jM8TDTRavZDyTQqn9TCTRdsZR)6gea19JTRdHA89kdav4)NAW7zX)HUDTLBQQD(7vE9EEr2(698UDrbRxDrVx2vWHHxnSxVx6nyqj22oOFEj0p3c0RjpF3jptfOHosZtzW9hqsBwaDd6Ie01e2XjigVtJRdudZ(I9h6OLoUG94KbekWEONcjCD6qpmeE8CIgM9DU444RcfypWmfFctph6H5yNUlZdZEox4tSCtkDAswMtuVfrDfKhAgcXWOKNBLrGil4Uc8Dosn)JtQb8pol8pwG9qRprBMmQUJkFrRYLrJ1xfNQkTxvLvyz9j4sFVKv8zAiiVlj1pwM6UmtNyq1Ejx2ySO6L7dH70L1UlnOn8GSIzkE)wPH5P0SzGYLcpiH6sa7dSArA2sL78LLTOgEJU(Cub))M7SlCNgXbsiE3PRzr0opZbEiaed44ZFoziWLD5Mb9E6jNgiZrCwpKMqiy06zzv)PGTC65kwzkvstncFTsFTrvNnAws2NiM4dIQZtty90Sf7RE13NJk4)3CNDH7qR60)OQJqdo(Tv1PgesRQZtpB50ZvSYuQKMAKlTdHxNMbkRy8klOBciR2Ndm43deFzqge)2JMW76UCyb(EG1qBzWSpe7PrmxUBh(bzpOGfiRXeUx2HdjG3d8fl)ptOBr7hqWsHSns9tLLO9W7iZa18Aq995ad(9aXPwfQTlhwGVhyTPvFKD7Wpi7bfOFLOMoCib8EGVAxl2S9diyPq2gjJvcQLUaqauHMDcOEMbAJMDcO7QBXhzW7aGxNMmTp7SxSoZeWP6NJ4VRddkEmQ9G3v1Qg1AV)GVTc47AIOoYG3ba728jD)Ce)DDy2jXg3D4ENeBCh8TxSbFHd0aSIF2jG4Rhi(UaKgrT)mQBwVou3vEsbDkQYTttyvDLa)0tptH1v(vqeO0JK54BP0(07LD96p8velXHw1mG4l0rVE321CYiPeCvhrpRJi)nbb)UxjnM4C4zkZP9EU3ai45Quk8N45SZp5ZzN)nAo78I5SQvIn2k4IpOvlNPasRuS0y3JRbI2xReDGLQJsduZIwSMMDBKm0r5rIOQouEouQGV2wjRZgcGx9oQOa2gVVk1aKTn7ZtIJtEGDoodaHXm89VdFPq2WUgXr1YS7A3GIJcl)v1DYM8Y(TkHTh9Bwj17zZWoplipysqw43T9JSRAf0PEYt6fFPslpBghNd613OCVFmX9dYo2CCQ5WttLfDAknWJtbbruHnhOYT(4cDQAfFpzjuG9WEgdonvbi1WWVt8uaS8fL3Xeue6wpGGAFLbia7HE65yQs9yv15FlWzPl5ofqR9cWRbGjmWCyW6tBPTFuX5JkWpi1AlvP4VVCBcWEyyiFla(HHBFORbxZG9qRG9B7WSNmjQtKWbzIL6acS3oNPniSIiDBzmyNgNKooUqCIGAvonQEFuQGQq2IeA7Bb42R9jJgOvjbR4SfQbWA6Yre4wbR7ByGt7lX(pmg3xIJZHU8eb16jssjzFAj5te42R961HQhNs2vBxoIa3kyDFdyDAHX(pmgxy4qXN2cTghvGBfS7OQ(Jn4oG(hFmHnDjLzDYY(AWdlWTc2Du32XgChZzRdiSPQ8ODBY6OcCRGD3u14ioVBaVprGfkUn0IGliCq)GeC1j6IB6aDdmEmZFarKXheytDRGSNaxRCwqsy7eViWT9o86J5u22p(bgrJGeVBLf3AwKYU7tG7tZJIdlVyvZ6xD6PF1nNxwjbVgFG4VPy1C9Rh8RzVO03uR7sZrf(PNKAM809U9JUJa(eiG2ZQCncy(4fV9J)LTJ)beGWVKXE3xl(WS6736xVD8Si8HHf4NtEC7yUPe(dKnZyc0HInnQ8IDNVTrWVJsD8SyW7VqQoYKEvAXN62OC8hzK32XlWTAFvckTI6oNXaEy(MuyM0dhXy8LPT8xg0Fy)2Wn5vhYRtwFtwyE08cEQh))pcH9naiFnWIMfHWuy(wSWtOoyqgpqq113ZX5KL68ba65gWd8aa1ggQ)UYq9pKm0JZ5nR9muItuvByOfvjwd1nICRNEQRCdsLbPOwOQglozbAB7l11TV22xGFR2wWcxrt1PvP0SvuUVwk3NIY1u3WIQ)OPC9NybTTRq5(wPC)DIYlVv0vxg5lUmYtyr0(uCH7uTfUlLwOPQbLivgkL7NMPyhlYqt1fkr(fvgBnlSCUCdvQ2q5ce1fbdIxX8dG8HUPBElYy7TY0IliD9qXFE215XKMQeSnG2xpOPkarxaD6dYQDkC2uUOdRmtuv1GUaA5xvPIbaDQH9R99xWCd7NttYdNIoE9xlCycgGLGlt5bPFHv)Hr5zHXZ5pe))WV8pzERZFhYMfUoeMZXoHngSkpAA0AUl9PHzjBsX3SO7XyqbFT2o(NssdRBbaa3j6TJxYAi4(7H2YI(siRohDYZk13K6gYOdffsVu0vaPhBPGLzJWIHiDYiWL1PaZ(wWXH3HU1xGeWqVem(cgXdd)AO4pdlqHWx2edeU4pJSdyDu0uUZXVoA(nAETfU9Yb6)OVMSke)gf08RnqZo6G6vd6ugFSWTaDNUmnkADNyZ6NEYSdhWVn7ruRSbFwEgBauD5zZ6EIeP8uOWRMzXKM87jZnED628rc8wVHaQO)58ZWGj82(ODWU9g)oDja7tpP)37q8YbE7qdic(o1iT0NX4kE9AQ8hnL(EVUsPqvcqQ(L6REAtiWADAEuVDPlKyACPtxqIxxCDK(YlE6j9DK9mND9f9eqUY7z6cylCXttbvHUucpAcRuiwsVhH)9esRv8FXmKPVZLO8BQxyi(r9Q)zTJT(3Fz6pQ8318Dp9utrzc6JM5X6HYRLJmluOhftGAFV1AInx0dwzvke08EzUI0AEFkxZoutXtLuLAdD6Qm848dXtLuhLUEb6LeyA8hbtVGw9OPGPP1a(cKhpNqZcbuEjlxsS6Qhn8SD8e816J)tyoccMGo2ZEpSMYY3vY8515Ea7wqEX3dkO3Wvqd)n(QOnJB)LpAO5nbRMGL03dOdAJfbG3WmHk8hehgXNAhXpsatdIJ7tpDZy)gnG2URDzxVuNfnkFHGnzPNtIHSNtIR974mgCT3aAATWELJelHfq241MR4zhO0kJ2Ed6404BKmfEDQclvUZ4Jx2rNsn35TvUU3uOXjSPKCLvNO1lc34cviKMz2kfdseRI41bI2bvf)gUI)6GTJxKgo)MxSipFD23D(5p8Wd9Fi5HfGJtqeHlppBn4i4nGuXBgCodlolA18n4ZO1lU9N5zY8df)W1NhC72XpSikUfqEON)vENZPMZsMFgFl5U9NfsD6pI)eh4rGMJnRFnOhHD8IIJ5)LRdM3qF)RE35CMpoAczz92)Qq2x)u1VZhxm7SOQUADHrZDFyBhngGhakxb9otrbvh5kUuhOC(J)L)s5EaGRkIw9LKpdQb(DqwCvqmZ1RYviOD8s5a0J)UewTj9kONw)vmNCrZbcy2hFD(5Wwg8tWQM8a0AeBka(FyeRGe2hM(42X)kZdUI5KFR0rrSVONII6qKEcirwYZiEghvnDZ8E3eVqsDq3Nzqdalwhk)dFMwhFGWCK8lvzpJqcPj(wPAP0HCTQP3LyUkAGys2nLS3Asj7HJwnqx)Hg9nUor38i1CLiUWLZ5oY2erGWH))iIm7oD(nxCzhq9JIOcG3jPzHXHzzfp3Ni2up4fzxuiH5IpUXOk73VijbDEP8r1Lh2ag3b4SK4qHrsigBHuQrZS3ZYjah6AX7bN9owFb5JKDzOGv)iOGNqpTrBJG50UAFT2VzyvqKKVr7vZZkAuQ(9Q010dmVKKL1r6Pz(6BkdSqAAwoSoP4zyYmi5Bu8xNaMlYx0dS1HSfgIDkRHAXfrWiid4cDAwHHDHVGe9MjS)LWav)u4Qt9bM2zyTzJx766mIddUo)K4cT8KiIYQ69AsfmAm(vVrnAIGRP2nviwNwNkSQ5IWou5UHkpn1iLU0uTVuL63lmgskvDzSLP)2H3Q2wmpvqOUPPKI4BcDXErG5wrxEi8hQ(5Ypb0uBLb(Dmb3YyL(EMC92X)ssop9wvGLVQtNiCTSvvgYfrYB7E5WZkOzdzh)LVTN2bBh5cvqqyID6JtRwedRznjO7Qaq1WOi7rb39eSg)CjM(LTNxOFVUOdPsBcXUsZWQODqzSS(Y1QbI69IApbAdb79eETNBRva2Ojdn934k)RFZaLv8D2o(Fiy71UkaU)lhjr(kGVtlBjHwR4H0FfLZPgGGg1xomTxbahvJxoP((eCNi(VqxPRbzT71O)nly5jfWPiUfwnE0w4qBNUCDTGBjuZTDfkpePIxG7cNWZHfZD8BV5sXkbYLV4T9kuaDag9322b3tQw8mZh157mPJSeChVbD0NkrHzgwLdvmwSgRFt8RdzwPbEYX61RAlFxKe)4OYYuQcHu)DHrD)yderGnh81g9aiDtwWm0Zik2LZP9)wVHfCqTmxcQVGTO5tUy)OBQqpvjCAm(aWs8h4kn0Ma9OzZxwvbcu85fbjzJMeWZ)knZ)DcL3InQ86lizIx2Rs5OA(mQk6pmYV1j4Vj5LLCHjOn6FrD3IqtZ29BMfRVUc4BO6B64(E6E9vD6Ql3rc6(eQFNEKU3PpzhYctMjxSgCtMpFeO(qWQnvYhmYf62f9766YLWtItsMfVPepf3g3RVAaNNDHTQXUrgevRmTNEA(M4yG05Lp3)B5DTUBBRdd(zzyab2y9ueR0S9N08iCoaN()KMlEDE5MHDcgoaf9zFIYw26cPU4M1Udgkq(rILSejfjf5hzx2Ues1Tjejni680eG4X0Oepi540zRcF)UA9PdfhflYL7loSoAvi(w0apmorzBb2mw0lEuwtmlKWFJXln86xhC3N4s1GA5v7G1qD(5LRpD8sn)Un5vtYwYk3e2i)a2qrtWhv8HiINKl4dPp9ZUFkX20qMIs4mg6zFasrbZLJZPkwYWEGwH14KGP3GVAbyfyFj6hDJu1Wo)lJ9J70gvR3nwffHnZuyJmtg3bcZfu6GPjkTVFCvSxlch(IcBA7VojLbrvs(Nhh1YavoAcHPBJ7kalm9ZyaCEXnm4gGLWLvib0ikJWfEjiH4louJ)K53klBJEu4Q2j9SqeS7jjLGepqkSqjzmKyqJsGqBgKKS3B(m925VWFzpyRVQJQeWTxzbVW1gfXjlekl25BNkFBloIzrkLRfKy9OjidycYqOI)Gp(HqHi9HdV09xXn)hD9tTkL27azN)gZN(dGjXpNYVudFs3I)71NUaxAAvztap10qoF6OM442fh9YnNxozk)kmM(1XWH0pfu7ia4vfGSDXTKMZOz3(kR3GTtdPlXPv90HHupu68Qnvfq8F5SSs(dOEFclOm4ChuY5hpbOy3W0THrkcRBI6I84wXRNYpFmFxOzLUoNWLGCEmklZXPAFNEBC7eXf8SuRYtykDLmyzCxgbQqt0Ik3Nm7fMI6n1zdHdxkm2MhWk3hgVtXWuYPDI55ZSEjztfhJOpkgY6JskICTIGBG34vWGYwvWjzgJ1C1Y7Mpznh5(HaSkTMXKvgNrqcglcsq)wxciL0yyVUu2N41GxIfYUE(zuZNZMA)dQQiHIKljXARWDXvK4SutnbzPPHCCdreIMliZrhYQGWLazuxmBysPJCdCLeIZ7MXK5(mAEPZeXscs7W0sfdz7DyNsUwuJETA6emMq0ubNZV2sGJpw0vzBgB4SH3EQDqg5OvB3AW(FfliUP6UsdSBQAH8keEhiBeDxyHi5rOdmVQoVcuzg5aBffkVSVopYHUhukwV87x2(0HwXOignWwGINF)saNKro4VwuLlOvroU1REcmtZLU2SRM6oHK(8j(E7Ruf0lkQC6tL1tVxERROPDf3KjsFiFOaGIkuBoGOkM3JAGvfXvoN(gvzdVKzSXKxHM(T6wtpQtbUCR1Z27Q5oK5SROIGEYhkvOp00WvZ2Xj5vRoU7EhBwc8qEhbEiJTmtcxiYJkDCFISLSqCWYNxkrqS7xfDitLE0rBF0VFMd0PYqLgrxE5o2IXk9K4kwfHMeOUNs)T3h1y61B4OF7Qi2Q07yKD7iWSaKdFov)GrY8BkPa7MiuVVEdiceZy(i6MPfs8MiIStGSi(nvAQgurNaTDN)YJ)OaWhQOlf8nUiEouMr8pkABbOIIc)g4XG6qEDU8F1HCZ8WtkQz0Yvn9p0MPYQIFVng6D9(tNLvVuM2PB)9SkzlMcpMIHLEaI2fISKLqy29DYQU()88XAnjnLVp1hRK4TKocRbNz3r20BJBQ9OUUTFxmSTMqPDsUl4Tbi7S7MJ2C94(ou(mdLpZC0BYEp5Zmc(m7xfFoZBN3tTlmgdFMzYNjAaFw85p20IwpDC))bFM304aUuRQyb6KmfBB7JSW29g5ta6AobDsn9(nWTV84)u100boMx087(NT1Nev)V28mq5qJBXgJcNEUgrt6dIKk9HXuTE3PICe5nEOuW412d3qAFIqmZTMVbRI30qaswC0Fgo9pefb(P)mxhss16GOrs)z)VI(xBJwXeszEN0SriJJzooez9fpuZ3el(B20SfN5)T4Np]] )