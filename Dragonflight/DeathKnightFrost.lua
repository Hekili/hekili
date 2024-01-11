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
    chilled = {
        id = 204206,
        duration = 4,
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
            if debuff.mark_of_fyralath.up then return "mark_of_fyralath" end
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

            if buff.rime.up then
                removeBuff( "rime" )

                if legendary.rage_of_the_frozen_champion.enabled then
                    gain( 8, "runic_power" )
                end
                if set_bonus.tier30_2pc > 0 then
                    addStack( "wrath_of_the_frostwyrm" )
                end
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
            if debuff.mark_of_fyralath.up then return "mark_of_fyralath" end
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


spec:RegisterPack( "Frost DK", 20240110.1, [[Hekili:S3ZAZTnos(BX1vrrkpKfPSItMZ2vn7CzUBMBND3A8S3(ntrrrzXnuI6iPIJt5s)2VUbijEq8I6HZU7nFzMybWg9l0O7gnaUZ7UF7UBNhwgF3FYFK)fJ88gn07DxCP)K7UT8XnX3D7MWOpfEp8pwhUc(V)yEwr5UP)h)3ylpMMfohHqr228iO1LLLBk(UZp)(KYLBNnmkB15fjR2MgwMKTokpCrj(3rNF3TZ2MKw(tRVBMYH37Y7UnCB5YS87U92Kv)aa5K5ZJPDpUi6UBXU)2rEV1B03TB6Vgx846ODtFag2DtXpy4UFE3px3NrVd6ZVKSolN24UPB3GdADNg)wp)36)EOt)vYVVB6I6Uk2Ll2nT3UP(tGE(JpMhcKfmCLH53hx(2Ihc3u8VVB6FEwAszCUi49ER)LWh9BlJZJFzb8nltG)B4xIhouOxExshbeHjiGcuf614VZqJEKV9Na2D8Q41LHPQ72iDDdO(8SvTiFGnoH8j)LWYiGSbjLF9NuW63Op8wFed(TKyGfo2B30n5XBeANm0vIJOLHRVVMH)Fc8Z48K13ddEzw(kUV6sG))D8JT3Wj7MUIcezYB07arvJAr8CvkgqVMqL5vyYM8KS8KYhvaUjuWXupyYyO3fHibqhHFB8iXVJkm(fE8KNzDXBhtLd)gq2FkgMyLMDFsuDxNRwwmAmvDsPsDHy)MWH4Gkx)vHjRtbISmJJmGjNde)mkE)JjFz30)qEmrppBboqRNNhEFwrOq3jkKCJcrAccPrdVKRFWeikX(9ZNNGJjQZfo)VVTOe1aR)U04phNsuccxp)C8xkd)e5V5XxkhpBlWY(4V(3egfVpunkiKrE4NdZtcNLgpCtwgc5G8TRr0SylQmvUmeaYJzBHbmhKKRZG)SQNWOSmEnFRHPa7yoWaXpAviWFiaBizYe8t486TRJsJdZXp(X656rlJJ(e286xc9ADC8CeZswteEvgi)b0a5B2nD22kaLh))UnjN2X3Epy)D4D3MMuuwqS5c4xACa18d8d)jIT841iLo)U)ayancb6D3UanzhuuMN8PyQ5Z8Kn0MULadq9JaeygtwziTfOpaRojeTuVyXWpLKs4CRcJwMSoEiWeIG(FfyRIyXcycjrbBYEioF484fjrjvToA30xdQD7Mc2oFfsAaWqowq2IGLpwqgJHB3SB6acCoJtAv(qwayEyEaH3DxjSgHefkHK5jRAWmawfXLbZYwVTyyjymA8Oa)nrKgusrfLHOacXzgRBz2dKonlnSOeXGXMXanSPECufrAue9iyQlO2MJKSI2koCxShdhdyznMPqynPtmpybbyo5WKO4zWp(jqSMhUg4pxBM)8oTdck0jS3l0RWCdU4ATcZeNuyQWZmotddRgF(2NrmIHWOGzcRgp5iN81yFEiznamKEUul9CMA7k1efzW7Z1N8nbiTaZQF6jdZx6c5JaAEmTlHFf0KIAuJVMaag9xag5kjRTIYQ5XmE0angkaI)9AjEgvbAnu6YGsXhoiM4zirIcVpTo5(LLeUbSqX9XneDnVwdV4kcVqfZcC9bwoSG0L7JMpKyph46Jfyl3NggLeMgeo)ZHG7eif5nQRKuCHU5LEY2T3R5muoWzoPWtzgraYnp7H1Q7AdR5gUEko)y48T1RfpW0Cip9MT1srJyammpke0)bhcZbcJaq9wHTOqPvxhSAgbezWsyDBJlMcoScSfKatIKxn9haiSB6)fbeC40cuTnqPUgvQ1iM9PsMZ0SefoTVroRzzs2cCm6PEIWnxt0KWHyF(6DtFFJzNtd(rgH9h98grWVbMDv4m7lAqgIna1fMJsAIUsn1zG3IJpL(vcaDwBG(7vB1VcZiFWdpMVQiyX28hfqUMzJYDQYX0bIcPTRxML(iQPhV((YLcKHCBkXWb6u(n6oKdCznw1xeMcFxquoez1C2AaMKjnSenS8G4VSjoIelaQMmrqmzuwQLf2WF185JnZ407yNdmo9RiQI3zNipQCxEt3TiB9(G6anBchTimVqOtMLNldZkcMfwzpBGDr9hKwp1oB6kIlgwKnxyudcwHPEDBKLzn(VQykexWQo0(EYXw)9WN(54oepyLyWCuokmlRWLi7df0LhJAc9TaPC7HMXIVXGNQgNwQfB0co9Q76DLZKNugJUQ7os1Odzs7rKOuR)ysDrrOcYoZsWumfbGH53s(xSvcb3rjX(GksGs1xrRBldxTrW(WRQDnX5qNS7MaVtzw892Xr1KKvw5DpMxWID)mBtevo)rVUVrGjyzvdojfXlHXHcB5ypzj(qEMJz(HoHZfJ4SE3ELd18bNMKrTH)UAvdWrvu7UmlWNmWc98CWy(7zKaDPB0N25XrHpAoldhNHewbklVionUOGtNtF49hNr1AEa2pHkAIuLCZqm5UVaG5GXfykVZIP1WS491U63N9rQrvCT4)ysrPbIPjKX5zvXneSi(ZapRmjctBU1GHSMaMwPWYyQrmgsGKUFnosggmx3B2epF4IQTwJyZFoqKRaM6Cwk1ybaPPJcXXmwGbTkm)tetavFkdd0Bls2W4bzBUAznCdc(m2dAgikueyKAU0(zBxVJioNWefIA9wk3VSDlBg0mJE)4eYg9eqLMnjXz(tTmPsSkXKyzywfQOpTOo77Hjxkmyp0faQYK2siCtc)1KHTvjGI7I844VkhUXpHOw(2ncMZO8KHvPMncmgcS4k702Cqt7I(YzxyrsoiDdxveGdaH1IRJXrTRH)o8EaGflJttD0qwf0dx91Gci2UKfjvZG7ROhHZkYYNfSjopcyOeuDKrX7LJ4TyewuKSkjTDKX1(EPmnU1H2AlzVKmhvzN0PmiBjK8bcguzC3VMT2OnvtRk(lGn9YqCltRkcLFexN7n7M(trpIBHzAgAYhmBUB6FDnyFfKKZX(gV(Rpkl(uVwjHScjbZeeVoEvcUlXyW4(1CABzNbzH2sLbfmgsxqJWWugp0fqA1sn1b4O3YVE6uXEw1ZozDmuB4AwR6Cp7AZSTUOHuQ6zTjCXz)DATT9KV5mF5BmHRpwKUs4DWuInDl96mgPf9r4itlxtYbVnz4)kQ7lTryg8kz)4zoZt(ws0g8vQJu9ZSsFlcrF8Rm89b(krO5NdNpVOAxkVZCMdkzaRqLNGzacweZfMDDVX)v62ydmvC3qdtMhaRkJ(8aO0qCb)QDTPYbf5Ee)fSMOiECi4WW)tdsIyqaTawb21M0W1R1eAC3XDz)d0HDKKGPPTETBIxPMMQmgnWlQu4PQDAOvoe615CUY5PtiavWK7YyLTYvcrnnlqnC1qIcpdTtmvJZ2AF(WGpax(u6KCRozOeq42cvPpIvyjJB2HOgQ9rimp0vuLJpxZUmYCDxCmf4FByCpz39CM7jBKHh5nTKvF72Xu(58Q3EJKJ9qnSgi3nRiD8ksyvKcWj4H4Wna4QdjYnWW6LkyjOVR3WGwZ4mHy9kCSIDu2duNfLCjdrPoOHK0RIegxxQDcH)KSAtE2NHPeSKZOHVTip5E002xIJ2IioVDar5G(KIXnbZyMZ6RGeAkQKZmNznfF4f1bYYKt62ytz3MRKwjlmMxDALiiLUNUTrYGRlIR69Jz5ybfJvrE4gqifskY5mK4b0yvcowa2tZacOsGLoa9NkW6BEwcipjmGOmS9SflyO0UQQLM89St2b8VxMTfl(jWkvoD0qhVWkyME0qWcK(hcX07sRCAVjf0QFMajGbeq1QdWYBggVW00H8SDIwMgN5KMheeNwa)7Xntl6lM1y7C1xt8gzazdnyLbd5p7ZvWwVUEUXRQ)rMW910fTRB2B0ivXJWPKOIyQjELUYApryvv3HJ(oxPkXZc91Xcndj3zFEgyF(JAZ)KJnXUjXCXkO02svDqj5koxNvPDYeFIvbQQOnSthUgtHJIORmhOKB5XsJ1StnpSzRjibIak8HBtz1)snhuil0mwDTh)1DdwejC99Ozm5Uj7uTyLEUmldTwwVhDuRwOzpabzqhnJXByJE6nQijwiugYhQriusp0qkD8ZjaWYNVc)nCcc1c7cvRb6eeYjzTPWC6AQx7NvPusR6RlBO1o7508Ng3C6BPU6f8MWCzPBDVHK6LIyPQC7vUmIVwtnAAwC1uJZgt1J1eYyZ2GwpErV2IqBGC5yqC1FbewOg3mNOgR48rk99g32JUqvwYxJn84asKOByj)itWv97fNYqFukSnQEILmrPX67xEGWeh19Xr8OZrwhztEm4V7SqLvsPdRptnfpS0ByceA)2zpg8WY40n0TtSsXsOppSmPytm5e5KSokmFnSeuqsuf0fTWh4blAgLUDE8(LYQMr23bSZVZyNpp2PjzuIbcXXkwgweSTGMaiPmk4wC5w9jQVaRVX9e2Px5fgCAH1RRj7x7GoSEsph8AwalmJMniGCEo)ikMPN82WgGuWg53alvL85eYjoD2JqOzeAKEIEjuj0HQSBu7Con)gWVJN)wkIt7pd1Fj3iar39tqJjL4psu62nfeS4HPfJbexYIuap5XLBZbsXdhXu0dQ6Fz0WjdvR5JNHBBb7bFDJYUYIz0XiTyA00rvHgR)ZSgR))COXQen51ynkU2J0wQZccsRIZ4B3(ZDJuPFtOoTSQlLJjw7n51DpsgOofwzgKQ2FUBuddY3cdYNXGmK)nxMWZv0ykl9ljrcbJvGUSgBZHz5qZo1wNxurfkgeQMtBddSAh5CHoGFBa3H6S50PnKwK7AfFn9ubcrVzwOzY5MwyLYf6oxOdoJvYZ60JvEmSs683jIBjPFoLCKe4OC6VrtNL3OMKujzHZRzEO)bK4V5HRWTI7qusvROXAVfLHUUlXcmsADpNC8qVyyyk4d(sGK3S9RFfCkFw2xuBlCv46THP7B(Z4itNhtF(XCpIjOkU)WQB1MGcYLAJQGnXIqtWJbE0PE)6vgdMD0aD(ICgAh6VuGkBD9A0kUlL(UlvyJfklSXHt(GKtQ)L8SY4i0T06tn0cYvBdUJbFMShmjLfXPW8wCw(h)1)g5YbccqRat0YM41ZjDcBelNWOKn0liN6Dyy307XeJaEI(lK9ZOzNhapnju0UPRineE)9qBfKdSeySqWRZyGx3Lnz4cMFmJhDx1XiVoJygQr2nz0)V0XhV(l542U5BPPCbWGq3sLaFYIF3))CdA1M7nsPsRiuC3ZEZzwya942wW3XTEE3YU(LmQBwAw280TI0ffM65l9pvv0INFBNy4QmN6CXARizhyscXD(CuWLvLRIoKmrhKFvUtq2pLRepr56egYBPYLJe1eg7wiAkliozBBv8TTPPaBJAQnqazBCSXex8w0FRmWdT7JMB9Ge2HqGTzQXnrqdJBslgNRZFqMKwZdoAMQ78Wt2bL3g9lQM1O8WvXzwM1QEYOh)jlzw2QK1empinz1mvX32IETQWSpyRzCY4D)KROLd6XhFmx)gPjDNO5jENOfTSA7ZWkauuJGlZ6yNixEcHFY8UiDwR7Gn24zBnhtvQt9UbASCHoZX(jJixDDD9wQJGnShuNcrD9hA1FPMP2Q6uJWu)uuU71njJdUTtvwNlCiuptCMebkeBKbCU0Xl)YrsmfRluErRCLQEKChIt4DqXKhfMz8wDYubE6GzNoyeBFeCMPjJhUoRoFPqEprQyNuphO5Kvj)5VZPpxHhcJhPgGVFVa4nuaoyF56QNztajtEOIZsek6DCt2ijF96BZ5NEoeFjF9pBjImhuUD1RmoBlMcXPVXZKWRB3klzLCgtWSKKUTmo4RX5zcCN9f4Mc(HB9AcvZUMWis695ubEaI66vO6qWI1oWRM3yZlwUPuVvnqu8ZcCwU1C7GIBhjsdqs(6iqsaA1FztUGCiIXEsPuw6(5RAQNPpx732ZUCT7ZT7KqSzD6d)sZRE8FgRJSbw1Air0u3bqzec7eg758Asy30h(GKHMBy3YSKdXF9DdZMOYaSAqBc8wLt2YwvmPXArDK0S(7CdAwaUP19RPHe(1bpJS6TIkxv4rdTFBR0PAfDSTYiN(rr2wmXpHBQUTimggNPOXu7JID5M5PLnQwwN965zxQ6KPfUtIKIOJ84Mu3ArYMzZwd5uXKHQLyfUVeEmy(650nuOA3OuUFcc7FWVv3XQNQdDxpocBMJX7eNEw5QNPmHM9Ck5C8RJ0(Qfsl2RiT7vvpOQD1tk1AmwSQo3okK9wz6kLxAeMNaBiWeR2z6qSUuuJSAHICGxZGQu7WQRmnRK)VLzPmUwN3j66D111LcSAZGDf8Qs7YH8KaREh0SVJxjenIov5wMP1U5ynyMjDl(AJieIUJMt(BiLsv94yOldCxFX0IG9eJ)0HAurUkxiMdvu9jcUY1AayxRGxxF(GeauR6bbTEkyUwJvrYRVtdGQFWwih)m8yqeJhGd4)KSkS6ndjDB8BWUHfi7m6EfphhQCSNKBzMnH0hNdkO(legjTkjjxqndvTzistV8LME53PPx(wl0JFF6L2Px(2NEPOlN2PxEUxcysZk2NPx(TNE1QiWAp9sXUtDiRzOEzHUTSbpRutntvBpXQvj2MXAYkRfpJCWoTtErCtZ5GKZ5stXTBdKY3v3UhqT8D5gPqDWxsQmm4kuvzBbV9v84HNmVQM0rg1BQ7bAYndRjk6N1GY7M(NHFkzb(8iLqB3o0MLrQmDE4OA)epeZUQTS2nlVUQH67WeBfAOkmu1rnu1qWM60)yPHQypBRL7iOjjBQwWZ9dgL8oFRKA0oMlYu9GXxjyuA8IgYOWj3ApVdApWleEUNtlhCT4kX3efsN5UVEveYNqAUuCVDQik9RyRaWuNmLnTEMZS0(rBNPnBk3TpxR9pB4wndxX1S2(8kL1YficM16UfhfwkY2YylOlPzNN62mp64EHc3oDS779BUf24zwyJQvS0VfcNzwVVXqL2BrZgVFD9f5tD0ed0zPYwX54g27qw3fsEJMR5QJ6RowZs791gFvo3Tfd1iLIjiEY6FoC7iAZKQtmwESticerI4WF26AP3y4r4ZbZ9Qm0uLbc1tFSC45L08nY7mOM3QwJoCH03qEMHAiYoElxBSJhzIV5Wd7HNvWEmF65uptLEo5nmjTvrz4GcGv04ujED(jg1KKtxOBcln2E0lzxLig84LSpf0nev0D3FL8TGJU13)vkt8wTNcU8K0Q7Jy4sCErCE9B0GEflRaQsnDZw8mPy0FmRGkfxnSi4VVD(9RQu51luTcnuFcVHDsdWRJbZoDyfylsYJjIpZl)BlhNMckU2F52B)pNul8E8JG5DrFYYTwZz7zgxzv5MgSrpMAW3cTPK0K)i6PB61alOcJT2869F3TpeMJ1Igm)HKV9KvBYYlREAVFPWfVXl3X9axxqUS5c3wMvLaE6ldp(AM)hjxzD4tI)pKTggrsZVubNfaiEfmPQPAMo0L(EFzGnOQkVUsq30w5jpkxQEuK9UrAe058Jm0jV4)NsIy3pRquYUkH6MC0)Kih1avIcoRiyKaSuR6G94tcgFXjbQtoYqvPONQ10nXUgD0C9x1Ws4PHE64K7SnvKzb9QN8LCUfD1431dDmK98wDdxRVW791yJZFZ5W3OZaW3qm59)daMOuPQE9)IUPxPzY5jvVsZy2KFaPrOvEdCeESloBja2(g12rJlYxK1sWv3nOTJqNDzv3cFLVtSD0SLKNksGvZob4iS3BtIFdG6PKpCkHTIT0xc(goZ2wSMlSionHNVuXY7I3d2octfxU1YQ06V(RDCmAFTy3c91DVz74iixeIsWxxnk(8cDBRm2VVZBy4R9g8IQ4xg8I(9rvQxpEWR6ZTa0RNmyWR8gnQgz7g0pVg6NBb6oVAl34BQM9urzEsJT)iTKMfq3IS0c6g66dNeRFEJoXbYyEy2BSxP)msqRdU0OjwgP80jHHAYINLPB1F9E76Y7vdVJuKTAG(rHtOtl44aCnUiDGaxPIwvwp7MoMg9G9EkGr51EdvL0B1n(D3OxnyMqsmew(kt(MM2rA9iBR6uodqdS3BBbpVlk8pOGvtEo2BWQCkqZLvC3Me0c3QkLiL3zXnyjRSLu3lr630qO9sfw9yzQ7cdARfmRaJYB74wJLUE5(q4oDzT7cdAR8c0Wm5VOdvW8KA2mqPAHhLWa1a7JSnr9SLgpERRFzf8gv95Kc(FN7SpCNwHkPr9UxFZQO9oZbEiaed44lEH2GeR7Y1Jg80tonqMdkJnKMqiy0gyzw)ZbB55NRyLP0On1Y)7g71gnD2QzbDFno1FumDQb2hzJd6zl2N9QUpNuW)7CN9H7O30P)j1gHcC8BRPtfiKstNp)SLNFUIvMsJ2uRC5Fm860mqjLLsDnSObYY95id(daXxfwaXV9Oj8M1LJlWpaSgARaK(qSNgXCXUD8hKdGcwISgt4EDhoMa(aWxSWWmHUvTFebRoKT1w60Ss0b4DKzGAEoO6(CKb)bG46MfQSlhxGFayTPzFA72XFqoakq9mrfD4yc4daFvoxSD7hrWQdzBLGFbOw7cGgGY1Sta1ZmqB1StaDFDl(edEha8M8SOHK7WNnfMaUU(5i(76WGQhbDh8UAw1Ov7dh8DvbFFte1jg8oay3KN67NJ4VRdZEP24Ud37LAJ7GV7Qn4lDJcGv9ZobeF1aX3fG0kQ9Z0DCY7P7aIle0jVj3ETHvZf5ZtpDMeRR(RGiq1psMJVvN1NbVQV3WjVwZuCOvfdi(unnyWn9nNmsDkUYJON1rK(4qHF3Rfgtug(wjz6Gx4nccEUjLc)tSm78NDz25FJKzNxjZAMj2AJWR(GonDwhq6KHLwBHodikF1QubwDDuyGAV93mA2TrYqhfhjn7iU0ZIvd8v2Ax3U9M3tljW26D2IbqY2SVilnn7bYzypeuglWhcv8nJAl5U)cnltU9AONjQ6N99zBlR736mYE0VDTqVNph788WYWzHfXF3UFMC9dJo1R9S1qNQ0XI6rdZ4OS)eh76A4BaupL8HtjSpQvr9P54x9nA)zoL4(rrIEAoLaFtp0IppJYbYH0ukAhPAw)0c9N5kt7ilp1nm03Oejal(WLCkbLgZEhrqDOIhnG9ylEoLw70b8dL18TaNfEUoKaTYNYJwa(uEER8onNgEDG9KIZNuGFukuAVJDDTBgSh7P8FBhMdLjDQwSvzGxvr32X4UEEmDFAUgcEMGAtEmAULrBGkxgI4A7Bb4oO9gtpqBs8v1rUtbGv0LtiWTcw33KaN2lIdFymUxeNgVoEMGktqQvt2xVM8Ze4oO93vpqTQ7QSlNqGBfSUVPRonX4WhgJtm0v8q7NvJtkWTc290u)PgChrxypLWwxnMSFttoPa3ky3tBBNAWDkLwhry7qDn0bH1jf4wb7(zQXrCE)a(qnbwGpXmK7J5x2Pil0DtdvuKSkjvLti8n5S35NK4vEMCG6Oa1ttE61a1JmF(33naBYHttMjEEsRIM0FCKhL)L6MxjmlUBwz1yt5GtXKr9KdmZK7(5FIq0ii9glwsciLD3TfBIJU7p5pX7UBHOjwKKgxFzUwmS5ce41xFEDX08g8vu86Qf3yVevVH8sODnBPCfNw(NEsOzThW9D)S7iGVgeq5X1NHaMpH97(5)TDt)icq4xkipMqvFyb7zG4n7MopbFTHaw7Sh3nL6zf9HDJ4Bf0HQDCV((UNUN7WVJkG0ze0(ZnTPq4PocF)KskXFKqE7MUeR2K1zOIl6kb55PipUCBoiu9WrmfFUJQ)LrdNmSlCtAbs9MSnxxexMSOIN6r))biSVga5Baw08eeMCYB(AVs3zJZ4zIJvIBNMdxTZNbUxyapWZaxxyO(7ld1)yYqpnh5YUZq1COc7cdTQqjBzUHNB90t9fBqOsG5Tc10y1HRrzBFMD0vu2(s8Bv2cw7wkkqZgJMDIY9vs5(6OCfLopV5p9uU6dTJY2LOCFRuU)Er51pqnYtJ85Ng5Xnj6qQV29Q8A3NQR1ubrRjZEsv8QcrSJ1zRPsJwt62LgBftSCUIBLk4wXAK2ffdnpnEhb9dvIBAlIy7nxlsmUG1SXI(O)PYLjfvkBxaTVAqRRiCDb05piA3PYXZqHcVTzDIMkN1fqx(qg5T1J(eounaOxnKFDO)sIFy)L8SY4i0ZR)qLhtWaSc8zQmm)ZKAWnPSioDb95D8J)6FJ45o9PJDE8MyqOJDcBmCDzsuYgQ795XfzBZXxWP7XCYaoB9lz5XSFh(CQ707MUI0q493dTvqEG7adUo5yvmW(QFEvW8dkRIoEeVo6f8Eci8WtfUQiaRNK8zbGhRraR(gWVHpGo4xHeWqVcw7fwdpo(RX8)m(0AS((TPaztyO)WYSm0jXVxO8KXWkaVu5)q814iG(NbyNOKunbwyVRv6Fo0ZMeFzVR1wUCaQv35H27i7E87njlQ1Xz)yV(NrS0j)QdTDJrhKgaw7v(cwD9eyTdlpSynU2jfJxZV3Cr7bl3i807E113hnFaprdqVnnxJXyKZVbdonQemscKpbHv6r32n9ueVDpYhi7f52noIbwhY(NPyqBy8cyYzAqf7CdEWWPd4cDwnQAqF7kFHzXc8FSdShtPBU23oik4FWumaSR9qlgGnGVp7Jmda)XeE71a6aJJWdUuJiI90mHkWAEx)KGKK(lcl2QSkE6Py(O18wWjbrYGsVXUjqtZR7ypRVSJCrWy7nD8QXvuSUxYXbYyzJQt8BeEhQ4MKP8vmRNMeh1thzY4MCmg2JJ5bkoSW870yBML0n6GQ5r5nMHMkDmngxBpliFnkSFiznG3iyrd1x53JdwdNhVa8QO8g)jYFU4ddx1NR87itkR9Vr(v0LbwQngvtpztAWxudQlRCd2n9VyYB7xNfHC9pMfV69dED)jVIoBhpNiq3w(igIycAntWbDoSPtSjJdGcWV3ZKCvJQzK6IYDV(6h5NEIN3FXKUtvQ4Cxm6PNSTwld(sMlKaQ1xTffqemfMLdUAdoblkQpeG2st(aHx3zR8ZB1JwsR)P4tmoB)Q3nsAwEVDtn)4zlpeux1ARLQX10EDs5Vb47XKT2QFnqRRSr9FOopWnabfgLCq43aahTExlx)bWtIDt)VW4fyGKfdb672sYtfbGtj0fEfDBh8AVxFQHtWxdDs1(CPOqi(zQ7PC3i5KqnU56l4ZgLlFX7huzM5im6VVRdUNq(GnZ(ufxGwN01WD8gvzhx(t4KkKSxvnwKgzpgC9yoqk2aQEp)Xb1SY2poJ9u(7CJ6HXg0eD5ci8bC1(8TfHOdW6cyQN2DhOcdBEWtUXBsfhujZvd1xXwu8jJpm6wxy1YeUEm(iWsqBcUrdDjiw9S5lQAspFEzywrWSqYK4b6z(F4PNCMkVASwM4fdASjkNRMMepJbZUjd)nKpOB)T0YkCEQF9mQ3HPRV9hnG9ZkhBvNzAKTQ7JQ)DfF3tpfgjfzVo6RvkD4xMINdQyymRwPMEiEzD1761Hh6ORUKI8K3A30T1OD)(TjY(NLhIprvFMK2Q5Zlgg)fS(daVKv(79K)5QX(gpF(Twbc)BtA4A8zKDGPjNv2HLyOJCNHI7Uw2IfbGrzhYqMr(mecg47Zv1ggLzE8omE5iQuzST9zTM70WyKt6mq7BttbsNMx8GkuyG4kTDKhyCNNvBA2Qc4KEDr)tBWqANDQHEdNLTkznbjdstwnRZgMTH0OmSr6GA0vQHAuML1v90m53aERE)67ao4(i2DfHdhpa)rbfACDUWpH4qrCzWSS1BlGifJZh7f4VjQA1PLvoXI58GjpCdSNPeUQmWPl3CAYLhtdTDlIG)QRNOHhiPRPtPTlm7k3i0TMxJAUQouXABR863v0)G1Dz7ya9m63J3U6nxoIJsmAq9cUcGPgsU9LtAC832Uc4ipPA4vBx9yX3uJuQallGCTBAdplFYOEw0DG1OfZz27S(jYEJoseaVVJa4MXJg0fULSEo85Q5FsbgISoXP4x7PT8USgzQwpivQQOFHrd(O1p))R7Uw)TTTbI)3srqtJAAsKKJx3gC8xgqX6hg2WA7(yJvsKt0I8dyzp3wu4)23DKuuKIhF5M0TwuG0ezXh3XJhpE3V7CVpOAoCNVJ7)0wCIi3XOv(dmmPZDNyAVMfn2EzUm1ZXWDrfDbAwkA2Ijz5ZyaPe3jMn24rsgsaEPip4jUwRcxSL84L44ThAZ)rTE8IOj2CGKpgTlPDVCZVa)2C4dFq)TzPoSWc2LdD6n0FEZInOD)fl5oavBl14HhYDTR076lVE9LdgcwH33eKC67BtZeLxbIoMmirpo3(YTpmN68uh9dDAhelVTYv)d22vB2fJGLB(nSJfTzki1rl2zHUKpHvoNIVzzo2n5BxZ4Sudt4Yaz6EQvhkxMmItTHcyU3Go4GDt(vOFreDjIbHabcn7M8oeqsJk2n5UvLtV4z3TE9YMF(SZ2UD7PBxS9oqah43ZoRzzzD9fzPP)q6zSv5tQMpDtd0hpB8FG)9UjVw8GrNvmE3KTGf9r0ZdZYFzMWmStwm9egNb6A2d4q1)v4J4DEfmX3S8f7MWRaK118Fl0blByE(l)jH9v4OPKfaJBJseoKVr(C(4IzpagWO2LsyMmn8HnoASaRrLH217nfviRkMCHQYBqbgGc5B1KOdd2Qvn)FwCpiD9byl5CqdjkNZbbd3gVwbcMxfJ2bbKk6CRrYLkM9tdZbOum83R2SujusQmbfK(XpyMPhxCSdMmYW(X(bytT9iqiNvClORKLxm2IT15P6XryA1kWcyelI4ymcp3Wx))PfZvbPJeoJF6smXJQMwHF5ez8z9H6ijqcEzA71RvZMv3Nq4)QFSBI4EvZ2jxjCH2Wyio4hS(hFe0gCHeVUi0V)gOmEDbwVyz7pH)dHDfO(51xdQsFBrnttkBd77MdkLHL2BW3TC(N(i9YKzqwTGPlsFE4ANIUDcpXT3zT6ipxgsOAsKknrGVjZjFhAzw2cVBI59(ie4gmGh6t6JFeSC6jElvN5(yq1oOWVrieNByjDAIL1p6zfFlHaSzuxG)7obQ9NI)FKW0EqepYcsRiHqv30qKSfkUCs52cIGQgkQHuNMuk7j1TYUQ6ilUvs5wU8xGcip9gwT1acefDu)lBM1D8B)BbFO9JdczkB7QzwN7ekJ(kpdyDHhOEXgDfxxQ0gjCVmI98aRZLVYWMoXkTl)ZWrI2QOG9PVniUCJXr2mvsymt3oJd7fePuwqKEIHQh7mckiB7EQPABjHxMK2UjZHKp)zsFwnAO5hO68WbSi(BqkmpXxokpPVDJzowU9POWjj3cBoIPIfNX1QmV5UI1R5PYgSWFdOKXnYXpYIYP(7WUiZoP6dvKUS79rH)9Faj7XhHDqao1AFscqZYrzH2(ytfcZBbT)lgF9z4HEGTD1Uc7p(t2CcS84kmZWRuseWtfjCh0lmKTiJCGKABp4G7cFYgwc2hTc1Kgzdfsdl3u3ugztRrfLnx(3BU52zcjPiAnUYG5yz9LyYzfzJNwTQKXRISDxvClECkMPx33GTngBtTHkZGgiYyqBBGSHlrVrr55dS4va9JFeIKVPcZ)n0jiOOkLXWnvkzihXvdCAxhH3NgLNE8rNBpnwSgOl7tjF7yPnKGCIlSI3d5hKDLbAlv)bqrlIZ()lGDiKdHZ0XlRDpA0zX87VWbvBjpLoFFYtPyVGF4IIEoBG2Alt5t3t)4TlkIvQUPOmz0S36Opf2V5T7PTSHknto9kDqIrk31D(pLGKFxyZDxI8T0h9oifyF(gEMV8GitluI)2(vlG2AWbEmeI)uyjygpup2U2jouUUTPxVSPGhx34v18(BUN264NLN33MfKJodJ3Ji3ok3NGZkDaw9fgPeXGMKOV6nHvR9e8GDt2wHb9J9nCh6iSsmWfWpQefzpw1V4f4RHHp9QY2Ve9yHAsenJLf8k0hVRmcu5PXW5BQxSUTUuKPPRAT3sbtBHBj(SpymMMrMImEGu5SIpCPOuM06CjAPXel52qBDRGqyQRQZiRDXJt1QOrkppXNOILrrfqDDLOgZYNKEnxsTGsj5psm9y0HT2IaxgsTiCrweJgRdbM9vWjNuWj3rne67pbNClco5pwcozER7wQl)Xi4KNOkYfMGZb8AZ4I51Fe)zjhrgBAuv9b9ewFi5fqsKsFr7BGAdxGvqjDGCC6Uj)(koAoMxwX)C)92vlyWQqRF2tb7E(MigvIDlywQoxOJ9TVXorRO9Picz9iBBkR8Eojy4shiZ69oEBSAs(fsEMeh)pNM)hIMf)8)Cx7ps0kDGrY)Z)MN)J9n7s6SfGaIaI1njozYuTlVF7i2CiSq(VeTv5GR2UdjW2FxutG6WQUOyJvCDFyNtIkBGTsJJ4KqgwL4vsoSpOje4WGMsD3cvmJ4xcSZtcbuxu6G1ExitmCaryZMLufuVnTi2bgyeWospNP)y1BSIhZlDtMXlYVZ7a1my5JW9Zqqcj67UhyTxvEL2(lesu39L6eA)n82SZyFmv6BPu8ne(iLl305MkVH76rt)51a1SKAgABbi605MdjroDv1T4EVpuE9gC6wUYvURz5dmqp8pkHcVz4N79QNlUF5RwSA2M6IQRb7FwcZxG84fTWBkHP8mwnuNzxfdoiWnjNYkAJWJqBKkKXQamsc)Cq)VkaAH7HVw0(MkCCqAf(97wSbRQhyTMKpAO7luQrKGfB)sbEubmeRXVnpBu(gDFLEHMdgVI66tdzHNTqCPRchzezQ9XzjpvSXo5PhXcv6XdsEUAgAD8WKKNNLQvmkhOulk1cO2qEY6Mh(z1JYsdHQjW1JdY2LxjOi5SEKmyfIbnNttZsxELLggwLcKG1CFOGcfEgKs7x48BPrgMcsroVAzb6QDirhvyCg5uJy1Mg(O9e(Eq4cVFn8V3)V]] )