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
        if data.cooldown == 0 and data.spendType == "runes" then
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


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 8,

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


spec:RegisterPack( "Frost DK", 20231105, [[Hekili:S3ZAZTnos(BX1wJIusSSiTvCYu2UQS5M5Um3o7o14zQ9BwIsIYIBOe1rszpoLl9B)6gGpaardaQho7E3(LzCeaB0DJg9l0a4oV7(T7UDwqE4D)v)b(N75nyyFVlo)dx4F3T5pTo8UBxhm9lb3d)XQGLW)9httYY3o()4)gB5P4KGzieYs2KofADrE(6SV)SZUpkFXMj9NMS8SSOLBIdYJswnnnyEo(VNE2D3oztuC(NxD3eTd)5V7UBd2KVij9UBVnA5NaihnBwiV7HztV7wS7N65D6GHF)2XBh)lb5txSDS3G((BhVzncYS(B)PT)eRFd(WP(Eq)(TOW0TJp3B741PHRLA3Ba0(phTkb6W0fbRUpC7454)4)miFryA0Q73o(28K0LcF1LN65)9IJTx)HBhVKdeosi073DQ)fqV)1WSNwnnC22XpcmjaOa5j0RHN6)(AmzDAusAu(tAa3qo42o(3zTSD8FBsCuEyk7V3KfGeaFe(TZhi)DESV7NfXtrM1fNE(awp(nGS)simBhNCF00YUcy(80KLnW8Zp1)sraJnRd8q)gkG4zBh3Dzq0QyGiZteidqIPN8NXX7Fm6p2o(pNggG0wYCCGwnln4(KSaPU7DU8OWMnHjPb9VuOF(N6Zj2poBweoMbXBhhm7FSjlFz4Q8YVlo8HWyMqqWQzNH)sEWxy)Br8LZXt2aSSF4x)7sJI3hkgfeYip8HG0OGjXH9xNKGqEu6MviAMTbfMYxeaa5PKnWaMcZKRsG)zrpHrzr4kXwdIb2XmGbIF0YaG)WawFCe)m8traC3SAACyqk(XiNEb(Btxeo9lyZREf0RvHHZqmlAfBYRyv7NWvTVD74jBkauA4)ZMOuEhp9EqPq)7UnoklpJPiaWV4Wr5bP3hMd)WFLPGjCfsPZU7pdRQNIa9UBNJ6rgLLNg9Lq(A60O18MULbdq8JbeyftsEaVfOpaRokavFmFE)VefZ4CldMUiAvyFGjmf6)vBhdkb6WycrthTo5XW0(ZcNhnnQO1bSMprysi)XKrWQ(zJySK7Yb9rkiUYyNgbe(M1maLfMpAsYQnz9ZbfmNpyK)6PSg0ILz5bithXJA2XIKhzDAsCqwoo8NBE4vbAbMurpm2B20NaDxJkvIOW85TIJ1fTDSQHusLsheqdDNNLhedlV6hnnCcmT9fygknyfWwU2mB5DKJakXZ4Qxqp3Fda8HIdFIWI3(fGvS9jm1mJsMpkRwjt5WlGLPRW(8y0kayiAEjjAEI(v(L4kBW7k0N01JqEhSU75NnirpK3(SqoJo4RWm(0kznGPkr2zG2LCMrnKZolSM07rScfOP3tst1ilmbZrxdtHFyV4nNGejoN8Lvr3ViVpoTdAOVpSIOlzHe8IRy8cDmR0q0ougRl3pDwFMI0xd(liXwUpoyAuq8OGzpea2XrkYBqBjPWmQLqEQkm3vj8UmELdYXCMXua5ML84k9DTI1CJqpLf77pBtPrWEMwA4rRyLKIgudWG0PbRadmjPPaHXaiTQslcuKY65aqaIC0cWGPrRyGNIaBbjWOPQMX(eaHTJ)VyGqutyswgBcAok)osRqhF6RA(2NpfDcHbLcnQDnzrR2CunHvUI4MRzIu4qSlF92XVhMY5F)Xb)yJWUJEEdy4xpZw1pXUrb2qSgOUGuCkNj0usDg4TEdkPFTaGsTd0FiqL3W(JcmJ9bp(u6YSrZ3K(KeYvTSuTtfUg2tEsAZQfjXpHI8HRUpFHezO2MwmSh1QaJoV4axMq9(8Gy47gnnfITzwTXatZjvSecw(OW)yD4uM34OyYqPPjJZLKSWk(lXNFUzghTNyoW4OnnQJ3zNipOCxrD4niBA)gDGMnHJwMmVqQtMNpxeKKnAsqH(SE2NQ)GIHv7SPRy(AyzU5cJsq5c(tGDWGTlzhZKTDjhu7hHV4HWweiMqio0koPS8jgQGzv2Wexad1gfUkCzeg98vxZ0AwyUSq6rXLnbVDRhqBXs2ksOALiAIAw40GNGidNI5lG296wgW3rh)04NRQ2jnEWAdTlwxEI1qvN(00Q8iKHcX2dV8GgtmDGMo5g2SKcR1JMh(a4oBb7vqRHtjq4eTrc2Zq0vgJ80b82TyRQxBf8qqmiFSiuoCIdAWx8VqFuXDAQd4gMkGE2IAtnEw9zMQn8pvh2jcIF)dsVHSHHmj4GAqePuzIC9O90VqKoe(gI20CndcXTpGAjQwVyIL5VgsrYzIsxy)ULBtNLGCH0ostOgck3cslHGSmrzAEL2ix1AhpRGvtkam63SvM6om1RAkYHPEROXXAUL2uMKRwgM2unQO1WFZHg8QKNnPD1n0YD5XKdOAs(ytjOByC3la9RNwXHtdUpeDvcDhaM2(kgG0IGLRLcX418SBy2pur9(DmLyot5ftDPXlTZvTEta2dNRODKZi80oVEXqN9HZmlLAA7IbcETreNj13cRC0YSP9stvX35VRCacbNdxIQ9g5ZGTuppdgR3xtHkE3RZDNd9qcoWLKMfghMLjivt7PWHzuT76WUnPJRv1QmLo98UQm1P8FZyjVZuEVRuUoIrzMuXkUSqVc2oQ7JDRd53j9bA0IUtQ50p3yjcA7tng9IO9EXsRLB3SqyCVpB)gNWm2opytCTStzFxgbAoMNgg(1qXrSC6RSBGBobRUhRta1Uz0ppcTScO6kqbqW9q)YweghBEQrkI1GLFDuWKSK0jJwhMofiugWhyuj9Lded7killAzuCZunwMMqTBqwzUcTTnASuXlNDkZ7nxhZ54SNoU2xtwP1mBciTMfMx)jLRwX)kEtiVHMowweDBq0SrHpW4rZML1hltKI0MxqqQ9i8pWYcHHKWinIxazG7XRJdwTct2KgH62JJmV1fCGMcly7ForBDA2K4wEouHgWouSZD6SMBNgAeMC325wkslMtatZ6ROQzjsryl714KGDkPyC2SkomawTYuBS6RpPDLtJoziPpcBuLYhvNkP6CdvrTpb2eItwLPD8fA2LrwO7YJPe)BDn3t1zhN5EQRSfrEtUD21(McP9ZfP(3PQpspO6P2nR4C4sMQww5om6XWG1a4kvt6gyQ7LoyjjUtRuGG)johwQ0UU4VA4fPZtLc(9OvguNFtueW5LP6tkZarlxNM8aSEO2LjcU280O7rLA)r40niwlQeqPJj4UEfSMShlzfRGSAPhb)CcZKNhQ)cSAdFaPuEYqY0QEIUtCQUbxruELylmyFRMp88YCcxpXt5KAdV8lM(JMBmcMHvrWiKnG2T)FGGNSh6)yskwjMy53gSgM4dyvhAcs9aAaoQbJfG(W)buKdYyyc75)ugwyOtIazeghyAc2EY851O02IYmL9911Pn83ls2GfVcO2lLpAyoRWs)KxO3yLL(jaDqKgbG3WmEzJYGeWagXxMmcRluy8cIJ7lY3zsUJkZdgI5KlSgfgNb)95vRZ6YemAbx9nLBhWzIvVa7F2viT9VPuc51L)y9K7B4Uau2S3GbAJKtqkrh1us9fo8jt(29qUyx5T5HzTMDuwYjEOzi5o)ZZa)ZFGggOAyc21YMkxdC2S(1cXKRecEvN8z98NCD8Pl9Z2Pdx993X5irKxJ4LKoxsMfH(SJnpSQA8mLxDtzj(NbSipav)uC4u(rClxF72XFE6tyvKJEWXQB)TJ)9sNjX(IEtQeKp522QZKIsChgzVUW)5GXa7Uk4rt(eAA)AkRcodBjanvQFx1SruUkOBkixHMjd(291k3yETsTmNU99HoXT7iJZzgZ3AkNo)XTLYBrQpSjDrl1yMyOtlnzgq()DI)sBLjM6p6nLF3yAoZu(Ms10j8VLu9lSyFdcHEFhQX3hfRtLQFwmDxvWx)(94R6sNCjXVijbdl5Jt5XzWdpaJVa8dOg0y8cIrqWpFzfEoKZpuImhV8PQinJqOuKHdckpomcIuMkfoaOTLwgKBDHC20CVXKc4K8svkc6AP0IKcB2CjEvlRswhcs9stsilRqwQJ7W1e1sU5zUQdLbY5PngBvTHTvywxEPeKReAkTVCiIsB70kIEG8T0X9qWovXOhAZN2WJ9WiNByPu1pJ7eL7wTuk7hJsIbj8I2TDwhCe4YhIw2o1TonCAYYjbA3Nxhc3KR0SFUx)Omyr)KNg94IW418nyRqesQppUikBDiR6dJwnniDvqE4OOPfqxwx8ipigWPXBMfwTfH7g257a253ASZxe7is5GCM9eyflcYgTjJVfjLliBvQRTASVReRVYFM6Jt33ziOW6EDnBBo71cdhDCilqsyHz0Scb6Py1)hWPz(zWpOciz1JmeP(SOhIyN98jqeUCAKF2(zuj0HInaOmzt8Taa(D8K4ZrCE)Rr9xjmc93o(ZqJr54pYe62ogMyXJvpMut0Ke7yXKgMVjfifpCeJrpvk)Lb9h2xVKpEBoyl7LWxxjSRTyRCmZH1s08rvJeR)lSeR))AiXQfnfLynoD1(nsNudcsRYR4B2(lDJ8z)k39BOvxzxtQBNfSWUTl(KcSQmiDT)s3ibdY3cdYVMbruIaUUGxO0nftxPMPS64n1GU6cURrRvbtyEXZzsDa)2rcNa8QtWkEJ48gdS2QEQbHqLCL7AWnnWkTgHotQdoJvQRiOXkpbSswRHxLST)owkf1yd4Itqm483cqsy9MV(vWBWjj)H(fHldwTjiEhR)G6Pf3hsFHHC33O87dkUxLgLXUwL0fodMdEjlvIOtzYkmTHTgqd0Op7mK33FHev24MGX0(8rwhAzARdT(d)GIZr)sAsE4u0DOYAXCo7Yvc361hyB9quEwymitIsW)WV(3zxpvqGbzyK8RdxnJ1jSrSaWMgTMFfnvUvTqu2ya3SRcOFMT1WvBIl4JdJM2oEjRHG7VhAlJv3NWsbj)DcbUDB2V2lQTG6pKhcdgY0oEoa(yYpuN0O)clCj9f3zDso0Vro6IprVgvNpBr3zkrZT8qDkNCcJfhHPIF4eB1HBfklu1TA8k1zoJrEWowS)kzY0XtMPJGuMU3VBRhR5k7oYCYASM83)JuItfFpj80vWWfMaY0TqUiXi6SHGgwtatX3pDg(D1dHUolX9nLViBBmTa)RR7X3GkqsvoJjVt(g8GmFD4364gsWrTYnKLQQ4l43alllojx8FRYs1SQsNtH6DAKBpxjyr7fvHUQYRY40vAoi(KLwyhP0HtmFl65hyJOOYg4L3D54yOl9CFoKelQGHPybuXfUlV1fDLsOgvSZkzdT(NxFiOUUSsBKYVoTBVyEnLY(UI11FJv(y8pV8oJKvixlGpke3Hg4)eTmO4AlemQ)wSByM5MWDvygoaPypzvzX6a(9dihu)Iq6CyfOrFDwgvK49vK49BLeVVfjE))vtI33UeVMUCCL49OL49mjX7Tts8(gK4Be(ztjEnE3Sp6yTf7TlQzTbdIiWL4z6fUlGrpDzBQHqshZsHUPyviMnt5y0MfB1Rmi1vtKWwnLZFMfVeELYMG(rHYeBYe1YHLqD0SIusJe)Bl7bQ4lbdnL)zcPq(Vb)u0C8EsnI3UDOnjHLyAr4OZL49r5Nrrah1)zdgePDXQOONbrrn6RAPOOEnEF7ffngJITf(wvv2ZPjnR(yiSPVOSfGElZAiMvCtiwwUegIEFDc))RCdiw(L6mwxc3Y7WpjD7nVCezPrWqW72SHxkzrDSu6iu5(VRKh3cPe4ZUSHTsHkNrXiNWXGR2YMbJW24ochFsnuOd5IWuri4aVRi5SS1IxTv6EYBsCsYS4nY0s3M1B8LdKNfoVXSG714LA(Q4d68nXXaBJ7X2ijKTxzkDnXfBU(WPBSpRBQLn)fDBkOIXnCNfFnkf6ScW2YdpAx)F2OFzXSDDvl9QspHYjjysYYOvmsyuC0YjMnt4QKZUG2MXjJjdZv0Ybb6dpMtNnnL7xnp8(vRgwtxashSR9XGVyoTzN04QAZR6QAdHMPJhGPe2AnHVYl9m3pve5QRlpaZueSHRBRJXSOatPCFESD8onQ6d7GXi0f9DQfRyvuAODFMEzwX2KJfnfeIwRcy18wE5afUJvdOx0WjA9JK7q0t86ZH0jdzBV648w98tdI6GAOwOuBxM5mttgVNKT6vgDwQBnAADDX5c(xQdNyKdTVqQ6KeVxjS5prhcB8ION4r434X(2jXcxD0ryzPPlDIUgV7mEtZwRtKLW6qC7KJ3Kho6RHPjsCNDf49CAIxz3RQVyXzt50UUz0EOnwRPjqeHBX94r5If9mjBEik4H8P6bIMFwIf3PodSTqcULePbi1Z8eOvxqpijfF)N17OKWdLhaGILSM(CYVTJDXajlzTr1qRM6RmtU)xo)LJ)l4bcPNvzn6qlSjR9V4cp)BPM9qQHfwxzhafFzHqeubZeLKYnEKovmQDt99SmE(kQUSbxpnFeEK3RsGIUaPuTGzsI1I4iRzQt(LjXrz)ZDXT1w7k5fdKrdt(TllCBfDS58LG0qwYgmDD41sdl3VgVvOTjO1XbQb6ZAqI4E86pXI)LnCVrYvPSaa3WYQbWK1WpYqF6yhTKEa9UZBxiZSoKQ1bwv145zxO0j9GIHdAigCpbvrA4ZdLK)nwLCeoHkDR590OzRMX3QJYJ1PHn6GLmBUYj5n74xzF72XFS8k3XHn9W8oAq9r14syAwyAzDnshmPvavuQxR3G1UPXKABfuX40z2O)XMz3JVFMMtVRvOHlHXBzY4r4bMZCktTcS5rPHSPpZP50MMDlRcimflmRfCp(rG060VO9s3tNATD6av29q5yGYfJNtUL04HZtLUzR4EaeHXwzp)Vd(aOJ82hdsXSsKvuysrq0fP5fpdRVs6Or(QTcpgPzS73QGn5jfvQe)v8fF5z)lSBjR399Bh)PKvWiYA(vA4SaaXdJUUMkz6qx669h9SbvDMyuGUjlLQJYL6hf1NicLrG6fKqf6EEhzIy7pPzQS(WC3U5r)JY8ibuvCivbWkTsb7Zpky8fhfOo8advTt9CPM2nTtiJMsFDPQGNg6PJl7swxqMz8B7Uxj428vN)UoPs3D53i06359(sSX5V5m4BQWK3)pnyYh(NamrRqvHZBTtQIqX6olURD2AVHQw6T4Y7UD0lHsdXl9Afmt39HTJQIoy2pmox9sQbOIPuEFNOYSuVhuCeE1xtZkaS593SJYAQxBYkWL6(A2rOxF1i3aFvVbMvH4h0drfFkvalrkZCe2786UVbq9yYhoMWwZMaOaFdBYV6y4nWG3y8d11R04jM81USRavZ9PSQqn9nUSRdsZRI5gea1D1S7drs5L4SoMtQ017SRaL(EFwzmSFbr76qQMqhLbIkFpV0G3ZIFqD7AlFyv7T4B869DfXn37762fxG8MZ796Uco(8MH969AVbdkX22b9ZkH(zwGEn557o5zQeq0rAEkdU)asAZcOBqxKGUMWoobJ59Y4ce1WSVy)HoQVJlypozYHcSh6Pqcxap0ddHNBVqdZ(oxCC85IcShyMIpHPNd9WCStBN5HzpNl8jwUjLwqjlZjQxJMUcYdndHyyu26rLrGyJjDf47CeN(hNuC4FCw4FSa7HwFI2mYuDjn(QwLtMgRVko3wAVRgRWY6ZiM(EjR4Z0qqEzkQFSm1DzMoXGQ9wESXyr1l3hc3PlRDxAqB4bzfZu8sKsdZtPzZaLlfEqczNa2hy1I0SLk35llmsn8gD95Oc()n3zx4onIdKq8UtxZIODoXbEiaed4439DKHax2LRh075NDAGmhXz9qAcHGrRNLv9VeSLxEUIvMsL0uJWxR0xBu1zJMLK9jIj(GO68LjSEA2I9vV67Zrf8)BUZUWDOvD6Fu1rObh)2Q6udcPv15lpB5LNRyLPujn1ixAhcVonduwXEvwzyeqwTphyWVhi(sC3hekzhn4DDxoSaFpWAOTmy2hI90iMl3Td)GShuWcK1yc3l7WHeW7b(ILBPj0TO9diyPq2gP(PYs0E4DKzGAEnO((CGb)EG4uRc12LdlW3dS20QpYUD4hK9Gc0VsuthoKaEpWxTRfB2(beSuiBJKXwb1DZzZJm4DaWRttM2NDkkwNzc4u9Zr831Hbz6JAp4DvzLrDH7p4BRyZUMENJm4DaWUnFs3phXFxhMDsSXD3y3jXg3bVJInnIa9eQ7HUou3SCp)mvlD6Ao2kQ1O9EDxV(dFdXcbOvndi(em0R3nDnNimQPx1r0Z6i6vmILS)xq(2zV48TZoc8TkjYgBVxLSU(3Fcnc8KDus0VXg(vaaQh6cnkKDBGOQZmL33Ik4RTvYcwGa4vpmgkGTXdMrnaz7x58K44KhzNR0aywndFjTWN(HnS7W5QxWF(r2Q895CYM8Y(TkHTzNBwj17zZWoplipysqw43V9Ny3kgO3rKh9hUmxllw)JZj)5BusmpM4(bj13hNI36LPenEzQXQJtLvquQchO6w94cDk9v7jlHun4bTOZFzkNkQHHF9LPay570SJjOi0TEab1(kdqa2d90ZXuL6XQ8D)wGZs3hzkGw7DvwdatyG5WG1VS1i8rfNpQa)Gu0Iu108(YTja7HHH8Ta4hgU9HUygnd2dTc2VTdZEYKOkT7dYelvLwV3oNPniSIiDBzmyVmojDCCH4fcQvP0O65POcQcPDrOTVfGJNUOYaXBaXgn7iqRYMuXH0sdG10LJiWTcw3ZrStPIE)hgJPI(4C61EHGA9ejPKSpTK8le48mVWOrZocuRYUA7Yre4wbR775Mtlm2)HX4cdhQIVwO14OcCRGDhv1FSb3b0)4JjSPRnhRtw2xdEybUvWUJ62o2G7yoBDaHnvjCSBtwhvGBfS7MQghX5Dd49jcSqXTHweCbHd6hKGRo03KpehuXd0vYhb0piCcQ0gFyaoXc69e4Af0cscBN8fHFU7D81gLW2Bk)ZmIgbjEZ4kU3SiLD3TG)tZJIREs(Z6xDouFZ1NvUN8VfFEUVUy5C9B36BzVNVxxR8sZHU85NLAM8CsU9NChb8jqaTN6ZAeW8b1C7p9N2o(hqac)sg7X4S4dZQVDIF72XZIWxRtGFo5PTJ52s4ppXmRjqhk21OYNun((gb)ok1XtJbV)c56it6PcfF)rJYXFKrEBhVa3R9vjO0kQ8Cgd4H5BsHzspCeJXNl0YFzq)H9Bd3KxNfVnz91zH5rZl4PE8))ie2xdG8TalAwectH5BXs4G6iwy8OvuFKkooNrpNpkfFNb8apkfTHH6VRmu3oZkoYqpoNCN2ZqjoBkTHHwuFunu3iYTE(5UYniv6BIAHQASOgT122d1vaT22z1AS2wWkxPJUA8QqNvROCFTuUpfLRPwrfv)rt56R9BTTRq5(wPC)DIYlF)Uvxg5lUmYtyr0rQS6mvnIezFqPu30mP4yb2zQUejsjOYyRzPGPsTRntqLVi56CcqtLV1gq7Rh0ufvNlGo9r5vsf(pjxiDvA(QQeoxaT8J6sXaG2Pz)AF)fmpl(L0K8WPOVe)5cFaGbyj4fqEq6dSAQlkplmEo)b)(h(1)oZbu(ZG0SW1HGyo2jSXGv5rtJwZ9snnmlztk(KPCpgxf4(W2X)CsAyDlaa4(fUD8swdb3Fp0ww0dHSA3ZjNfuFsCBSSCO46YleTUj9wVeSmBeUb)PtgbEHnfy23a2c)a6PAbsad9sWEcyxkm8RHI)mibdEKVjgiCXFgzhldUpAk3FV3gn)AHBXT(ZcXNsJ8BUyG(p6RjRcXVrbn)Ad0SJoOE5GoLX8jCv32PlBjNwlKBw)8ZMTHc)2mq3RrZ8NWgavR4Bw3tKiLNcfE0(kM0KFGlU2Rt3MVrz34neqf9VMyggmHhBeTd2nx73PlbyF(z9)EhIhUSBgAarsXBcAXL(mgh(Ra3QYfRu6l33kLcvb1x9l13VUMqG1608OEf6wiX04M1TGeVQ4Uk81N)8Z67i7vw6QZ7jGCLxMUfWw421LcQcDPeE0ewPqSKEpcxwjKwR4)Iz9rFNlr53vVWq8J6v)ZAhB9p)R0Fu5VR57E(5MIYe0hnZJ1d(voBTRosSqHEumb285EQjQCEpyzvPeqZBE2k6Q5ngRqtjLx4Rv)g9f0AnlunthvsIQn0PRcwJZPepHrDu665OtkG50FemxdwcIMcMZwdKjWs4PgzwiqPlzPuHvF583P9j4dmg)NWqLdkFMDW4UX2tMpVoeCSBb5fFpOuFdxPo834t70mUnB(OHMefS0cwF)eGoODzeaEdZeQ0DqeAexCyeV04XxLM(0IiSznJgDB394QR3sSIgYpxWoU09S)q29S)v(DCgdUYBanTwyJZrILWQjB8AZDgRduALHEVbDCA8nsML0hIvLgey8Xl6OtrO782kp6Bk04e2usUYQG065HBCHkesZmBLIbjIvr86ar7GQIFhxXFvW2XlsdNF9RwKNVo77p7ShF8X(pM84cWzlimRLNLTgCE8AqQ4DdoJHfNgTA(g89f6v38l8e695IF4QZcUz74hxef3cip0Z)sVZ4uZPjZpLV1u38lczq8hXFId8iqZXM1Vf0JWoMnXX8)Y1bZBOV)LF4moZhhnHKnEZFwijK3w978XftsjQQRwxy0C3h22rJb4bbYvqVZuuq1rpIl1bkN)P)0FQmv44QIOvpK8fqnWFaYIRcIzURvUcbT9xkhGrj0LWspPNe906JJ5CSzo4bZXfOZ3i2YGFgw1KhGwJytbW)dJYfKW(80N2o(3yE9vmN87LoxI9f9UuuhYIKhJl2bQSCKLCYSKcNggnhbjLPBMh)M4fsQd6EIbnaS4JO8P8ecNL6j5lRYwNGest8Ts1sPt8AvtBC(Wmwsmj7Ms2BmPK9WrRgOR)Pg9nUor38i1CLiUWLZ5oY2erGqO))iIm7oD(nxCzhq9JIOcG3jPzHXHzzJEe09ckBbSPEWFSrwOfFHwrv2FArsc68YhNYJ)Gh2ag3b4SK4qHrsigBHu6uZS3ZYjah6AXdLL9owFJBJKDzOGv)iOGNmOwdZgG50UAFGPVEyvqKKpR0vZZkAuQ(9Qu80dmVKKL1r69L9QRldSqAAwoSoP4zyYmi5Bu8xNaMlYx0dS1HSfgIDktJAXfrWiid4cDAwHHDHVGe9MjS)LWav)gHQt9bMQAyT5ht(H6fM)LiXTkagCD(jXfA5jEeLv171Kky0y8RENU0ebxtTBQqSoBqvyvZfHDOYDdvEAQrkDP2AFPk1VxymKuQ6Yylt)TdVvTTyEQGqDttjL0vOmETrIICROlpe(dv)8I3F58KuWx9CQT)a)oMGBzSsFKjxVD8VMKZtVvfy5R60jcxlBvLvDrK8MUxm80cA2qg1F977PDW2rUqfeeMyN(00QfXWAwtc6UkaunmkYEuWDpbRXpxIPFr75f63Fm6qQ0MqSl1mSkAhuglRpPNAGOEVO2tG2qWEpHx752AfGnAYqt)nUY)Q3nqzfFNTJ)Bc2ETRcG7)YrsKVc470YwsO1kEi9xr5CQbiOr9Ldt7vaWr14LtQFkb3jI)l0v6Aqw7En6FZcwEsbCkIBHvJhTfo02Plxxl4wc1CBxH6RrQGh4UWj8(6WCh)MRVqS8AC5lEFVcfqhGr)9TDW9KkjnZ8rD(ot6ilb3XBqh9PsuyM51D9EtzYdznw)yHxhYSsd8KJ1Rx12eR(493r7VlmQ7hBGicS5GV2OhaPBYcMHEgrXUCoT)34nSGdQL5sq9fSfnFY57hDtf6PkHtJXhawI)axPH2eOhnB(IQQwGIpViijB0KaE(xPz(FqOKySrLxDojt8IEvkhvZNrvL0Hr(Tob)njVSKlMbTr)lQ7weAAkraZSy91IaFdvFxh33t3RUStxD5osq3Nqn)0J09o9j7qwyYm5ILIAY85Ja1hcwTPs(GrUq3UOFxxvUeEsCsYS4nL4P424E1Ld48SZTvuYnYGOA1S98ZZ3ehdKoVK7gvGc9KTj0sEqR3Nghepg2kXdYzC6DRsp9gmjzz0kgsokoA5KwRcXgsJZHTtuUPaRNFRrETtnTbrCFeBV0W(JhG7tGunRyE(cIdzH5JMKSAtgeBty65EJ8xp1TV8enF6)B5D91BAdde)dZKqeTUksAz7fGpcBsBVthfY6yLcicOPjv1p7ZNJDIJ99Z)jL1wPPk1hGyh77oF357(DhlztWhk(qG4j5d(qDN(jthd2MwYuiHZuONTbiLfayEoNAyjJ7bucRPjbJ3GpBbyd0Ij7lBdm1Wo7tJcJv1AvRxpYe5H1ZuCJmxh3bG5cKoymrr9(5vXEUiC8lkUPT96KidIMK8pokPLbRC0vat3w3vGwyDpJrqaM3WGFqzsxwbccswgHp8saHfmp8KFV9NQRfIwK7A2r5CqrS)jjdqI7jfwQKmfsmPrjs4qtssU7TqMEB8x4dUd25JAOkrC71IOx4Dgf4KfdLL78TxLVQcQysIs5DcsC3OjOdycZqqXFie)qQqeF4iiD)zCZ)bN)uRI0Ehj78nmF6)aMK4CQ4snIjDf)3xT7eDPjcP4edSJgYzJhuhh3M4OVF5XBUAS4km2(1vWxgaiO2bb4fMjhQMwJ26mLKeV2YZ6h(8yPUlwEynf1xbJAV4bmVfHdag8Ud2l4c3ryx3YGTLPjGnnzjgUDL81J8UNZJfmd03PdHCJ3dp55Eolh6mBTZMmoENN5uucJX1VGJjDDCNIn9kMCFyolSfWRRihGBwgm26hWjJhwVt5WmYK9q7tL5TsY2QlgWU(ecFlpgZ6djfbxRmOf4fEf0RCufDQL5ynNTSTfswZtgFaqurz8sxdDwHgyKm0aTBDnmuYsH96BrfWg3qhWC94JSwmNm29lm1ps1s3qNTH9H)8m8gRZzmg5g8UuNooNxpyVmDSoal29iOSb(XOYqWHC7WVmnhVp9MZvO56KKh8UhCzsqkRJQ7ZpZ7vGEdxlMHl3m)fwtiBUNlf3tkYXNmh7mYgE5P2rzFfBXq5RWxLliHxcn1IyZuPWylfpjk9hn3qQzRQ9ZP(QkSdS8qv5bsBDIdujkS)0MQYeh6gsLC1n)60Q7EqjgLWOj2cvH)BUHaMzId(hRpukPvjoUBxCh5HGq6A59vOlHcD3u(5U3HlQxusGiaLM1G3wSPYU9fOMR0UV(T1e2xPIbIev5CCTd6yz8I0RBzhCXZYKIrW7SJFR(T3W6pc7ct5rDGT3zZtm7z3qfbEY7lvOnw40TcVxqYpSy79t9SzbaW8AaamtTUwIxikGkDgFIyLSyCVlKVsjqSBxfnqHfp6KTpg2l3E6sBSsJSlVspBXuLEg6lmjXM1PMNQ7BVnm141B8WT7Si2A0GB0DDjYSabAabv)bl0duxddUD6OwF96rWpMueIOBNhk5BceuPizrtkunSbzh4uTZF67)EnbivzBr4Ncr8sQUMe)BTQ1BkRc9lOhJk85Bl1)gdkmZtpPSiv3VOUVDwpvoLy8LPqVR2S7OUCPY7C6(OvVeJRlJv3SQ4dIzC5Ja0tt01ifdZUTDB104LNjZBa3NNfIvcElzd4AtzQU5MXlR7V3dM9gUMTFtqZDMqTDsHl4QyZD0FloBw3an3x(CblFUaYNlEv5Zfa(CX)k(CodFohWNDBj1(4Zf28zqB0ZHp)U6wJ6UTB(d9)Y6ovWPktfluhVz9kv)BL2UxOFcsxZoQDV1TbhC5tF)lhQ7YbBlxx)9HNTB3jB3aDMNEkhADl2uu4Ghfx7lSnVviP(Sonrtdbl4vGGACAcEUDM7czLYenRXatT0i2f8e7yo1Jhfx)A0dXo3LyxKkXU4ndXUYf4Jy5sFQmY8qI9zsjB(3QeBI5FUyC(8JI)M)3d]] )