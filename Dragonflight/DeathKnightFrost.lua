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


spec:RegisterPack( "Frost DK", 20240106, [[Hekili:S3ZAZTnos(BX1wrrkjwwK2kpMZ2vntUzUDYTZUtnjtTFZsusuwCdLOosk74uU0V9RBa(aaenaOE4mZD7xYdbWg9l0O7gnaUX7MpDZhNfKhEZF3FG)fd8g86(E(x86lgEZhZFyD4nFCDW0phCl8pwfSe(ZFknjlF74)Z)BSLhItcMHqilzt6uO1f55RZ(UZo72O8fBM0FAYYZYIwUjoipkz100G554)F6z38XjBIIZ)5v3mr7WF(f38XGn5lssV5JFmA57bihnBwiV7HztV5Jy3pDG3PdE93TD8VeTkjD7ySNBhVzncW(B)W2paD68t98p1)TqN(D2VVD88YUk3Ll2oUZ2X(dHE(tpKgaO8ITJZdsVnm)0S7dwN9FSD8)ysCuEyQm49o1)nWh9PfHPHppd(MfrWFg8LW(9L6L3B4JaIWmeqdQc968VZqJESV9Nbwz4YWv5bX672aQUbuFAYYgKpWghY(KFniFkq2Ed67x(jz19BW7o1hXGpffcSWZ92oEDA4AP2zdDH4y6IGv3wYW)Va(zyA0QBHbppjDPWx9gG))DIJTx)HBhVKdevYBWRbrf07Flm7HvtdNTD89rOKsMIgmKlZlWK1PrjPr5pObCd5GRw9Owgd9olaja(i8PZhi)DCHXViINImRlo9CUC4taz)5qystCYTrtl76m9YIbNZvN0QuNj3VHcioOY1Dzq0QyGiZteidyIxp5pJJ3)u0x2o(hsdz65jZXbA1S0GBtYcK6otHuyuystqinO)Be6hmbItSF)Szr4yI6CbZ(xBYYrnWYVlo8UWyMsqWQzNH)sEWNz)Fr8LZXt2aSSF83(NsJI37kgfeYip8UG0OGjXH9xNKGqEu6MviAMTbvMYxeaa5HKnWaMcsYvjW)TONWOSiCLyRbXa7ygWaXpAzaWFyaRpBYe8t486nRMghgKIF8dLZ1NUiC6NXMx9COxRcdNHyw0kMWRW437rJFVA74jBkauA4)ZMOuEhp9wW2A)B(yCuwEgZEkGFXHJ4MFGF4VZSthUcP0z38dGXXPiqV5JZrZXJYYtJ(Ci30yA0AEtFKbdq9JbeygtsEaVfOpaRokaTcpFE)phfZ4CldMUiAvyFGjmf6)LGTkMflGjenD06K7dt7plCE00OIwhSD8lb1UTJbBNVajnayihBuY8rlEiJng93SE74Em4CIG0k)(KrG5HzJy8UBYb7)kuOcsMgbCiewaGYcZhnjz1MS(5GLOZhmYF9uwdAjNS8au6GiCnFBrY9Sonjoilhh(Znp8QaTatQOhMCiB6dGrUrLwBuKs8wXX6I2ow1qkPY6ecOHUZZGfbG5H9JMgobKVFgeLPbRa2YvMzlVMCeqbnJREbTsY14cQLkjdDsjPaptemh0Vy8fBFcZWfcJSAZwL4Pa5KUc7Z9rRaGH0ZBiPNt0BlPKOydExH(KUEeslWm5hF0WCK2q(iGMfY7sWxbDOPvAVxXaqn9Nbg2YzRNIYQzH18OEeghaI)TKeFnvbQmC6YGsX72lM4jirIcVpVk62f5mUbS4WTHveDjVMGxCjJxOJzbU7albMX6YTtN1Nzdh46NlXwUnoyAuq8OGz3faUqGuK3G2ssHzutk9uTvVtZz4CGtCsHNZmMci3SK7xPVRvSMRf6P88J(Z2uU(BptZH8OnvtsrdQbyq60aq)hCcmfimgaPn(ArHIuxphacqKJwaRvBCbuWjvGTGey0u1vqFpaHTJ)RmqiABnjlJjGMJ6VJ0Q0XfFvYBFUi6eILOkSr310AK1lWvtyLZiU(kMkfoe7YxVD8BRS)CCWp2iS7ON3ag(1ZSFcNyF1d2qSgOUGuuKZuAkPod8wC850Vwaqz2b6VxP5)cmJ9b3)q6YSrZ3K(GeYvnTuTtfEL2twiTz1IK4hqv(Wv3MVqImuBtlg2JAwGr3HCGltyEFEqm8DJMMcHvnREXatYKkwcblFu4xwhoLfiaQMmusmzuwsYcR4VeF(5MzC0(25aJJEPrD8o7e5bL7kAdVbzt7jQd0SjC0IW8cPozwEUiijB0KGc7z9SlQFNYcR2ztxY81WIS5cJAq5c(tGDWWAxYoMjV2LC80Fp8f3f2IyafcAI2Wj1kFCNYWGpyHsQZQT(4xRrkqIgWW5rHRcxgHr0F5vmZPfRJwOwP4lNGBW1yIT4BBfTvnffx7Aw40GhGGqNI5Waq)hMwf0Egk2AFCLhnCZGZVTmC0cuSJC4q6caMlSuLJxxohHgDznJ5hz96Wz9NxKo2riSNbd)sy69S6qYQx3KOJsmSZRuHMLKdSU0pZySfFAng0RzOu1rWRAUttKaUZgpXAEe0PyrhzoLxMscUc6Np)BE4DaxQI0RSlwphM9zK5D5eTXf3ZqiKgJd3nS3TyiRnveChiHxbUBkh20bnit(x01sMcQIjGBKsZeepv9pntBvJM3MjvNySQrSqqe7FwkAO3yiNloyUxNHg(6f90p9Hohg608nY7mOM3iVc7Vq6BipZqMnSJ3s4ilZyM4BgtXaxd1ZkypKzAq)mv5SNQlXsQlU6GcGv04yjEDjDYw14vxxs7sJnhDaM88wTRo8wUvwMC1vtAoBQeDnFlnadzNwAkVGvNgCllVT4IZG87RyazlcwUwkKMxuMnfNt7R9mBiAvUZbjx7MYVN6CKDW5MIG32npBO9h1I3MDQJeKWoKsQ6zCnusFO80JsYCXabVQAgPBB9Wt1O35VUuVieCnBjAYBKpBGL65zWS)3wtckoFB2TSdZqc(oLKMfghMLjOWrVVehMr16gySBcvCPgT2rP3mHA7OIBQxtJOg3cbjoYRnLz9kJQJyuMjtRIQ96nS2rDt6BDsfCAttnKSGwzasVSXs442fngZVhjQqco6LCnP1rB72jBgUV1mSfzNhSjUw3PSVlJadhZtdd)AO4iwk(k7g4HtWQBXIGqTBulZmnig8MH9FgHfebVSigXl)SCET0KzwuqBgwGwxbgqcUf6x2IW4yZcdPGndw(1rbtYssNmADy6uGtXa(aJRn)MbIbgfKLfTmkUz2qlx)s7E4vMotB70hB3cKZtM5TpSJ50W2thx7RjRc1PXLaQ7zHcUiwoDh)xXBc5n00P0I4pdIMnk8ogpA2SS(yr0uKz)ccsThHFblAggscJuHAcOVSgc2FfM6lnlR1ECK5PVGZ3uybZbdI260SjXDLDOcnGDOyZf1TiPDAq0IwjQ3gpzrAXCUtAwujvnlrkcvvGMvFTtjfJZMvXHbWSvMDNvF9bTZCA0jd5RryV0u(O6SavNwNkQ9byrL4KvzAhFHMDzKf6U8ykX)wxZ9A4DHZSp1P2Iyp5CFj1M2TVQIK)RvniPhu9u7MvCoCjZwlRKmgDFyWAaCL2jDdm19shSK03PTkq6yFTqS0QDDjV1WnpNfLcEoPvj0q4p6OHZltiNuMfIwUon5oyorTFxemU5Pr3Ig2(s40niIlAiqwqGfp5DiMXZ8rMw7j0DIJIniHQYl4eZBPGMp8IYmTwlOOClTrsPkexrZngYYWQqwecHVD7PimNx2N8FkjflSuSAIdwdsPawXUMGupGgGRzWybOp8hGLxqNatoo)NYW6CDseiqzCGPjy7jZNxJsBlQAw23xx9(W)ErYgSGya7uP8rdtqfwjR8Y)hlu23hGBzdVcA9gMXRcwgKagGOxDW4b(51xKVZuZgvM0leZjNimkmod(3NxnVOR8obzNR(YYKSFMyfrW(VDfYe(llNC8IYFSw4(s(A2Ln7nyWn6sXOGwIoQPK6l8qtM8T7sBXo9BZLWAlXOUKip0NIhAgsUZ)8mW)8hOHbQ6xVDRIPY1vNTvRAHAYLcHRQt)Sw(jxBG6sNQD6WvN1DugjI8AuVKS5sYSiSNDS5Hvv4NPCkBkFW)cGf5bO5NIJS0pHBY5R2o(NN(awu8OlxSJHW2X)EP3FyFr3)ucRNCJs1TKIsGcgzVUW)5GXa7UkApt(WrNCI68p7rN9pAQuZge6Wmqxv0nfvQqZKrl7(CLRnpxPwNt3M8qNaZDKX5mJ5BnLtVnQTLYBrUkSPDrR1yKy8PZBlzkl()DQ)s7BjY0Otv9UX0CMP8nLQP3RUws1pXQ9nie6eIxJV3lw6hv)Sy(PQGV(n4Xx1Lo5YSFrscgwY3pLhNbp8am(cWpahZlCPaN55Lp1M2zeePmdcCaqNg9YquRlTZMlwtUsRW69ML2vrJ31sT2if0R5IHYHsgqQxAY5xznZsDaiUIO6Ynl5QoMgiNN2heRt6Tn)W6KdLquLqtP9rdru618TIOhipdDmL92Pkg9qVsUn8ypwIYnSuQEOXDoY9fQvQqhJAIbj8J(q7wrZrGlFIEz7S260WPjlNeODFzDiyr(wH1p3RFugmPFYdJUFry8A((zvOcj1N7xeLToKvoErRMgKUkipCu00cOlVdBJ8Gi4MgVzwy1w6TByNVdyNFRXoFrSZqgxe0IRzflcYgTjJVJeLtiBvIITUuDxjwFL3i1hWUNziKU6EDfBxf71Ifo64qoCKWcZOzfc0tzn7FefZ8leGGkGKvpYqC2ZIUlIDq4NaXNYPr(fnaJkHouKU9YufXt4o8741cahX59Vg1FUWi0hIKhAmkh)rMs32XGGfpJ)ykjXLKy1iEAy(MuGu8Wrmg9ZO8xg0FyF9A(4vlHTCpcFDLYU2YwYX8(vRrZhvnAS(pXAS()5qJvlAkQXAuCTdzNJYccsRYZ4B2(tDJCPFLZ6nSQRSNh1TZC1F32yFsfwvgKU2FQBKGb5BHb5xZGiQQaxNWlueKIjBuJiRoArnOBDJn5W1BPJDQTCF6KvOQHqpLW)iWaR2rotQd43os4CNxDUz7ZRLvsXxvp1GqOH0Y9v46gyL2f6otQdoJvQZ6OXkVASs5KblJBrX3fZQ8ybkN)B8nxXBq1wMOyHZRAEOVH6fXM25SGLyTHSpkP6v0QBVbLHoPRWcmsA7qbKia9S(bXGp4lasE9MV(vWP8jjFrVTWLbR2eeVRvDHaz68y6loM7qmbfb4huCzBnkJDxBPlSsCNmK8yqeDkt5JPT92aAGoFXoD)99xirLnU1FmTBPKLFxM2YVR)W3P4K6VMMKhofDlTSgwNZUXTWnW(o2g4eLNfgdZBXz5)4V9pz3zzqaAzygvwhUAgRtyJyDVnnAn)E7QCdV3o(wmXhS7hQFHTb7vBfo4RjJM2oEjRHGBVfAlJvVSG5cj)odbUDB217lQ9K58b8qjlZDLHc8DsCsYm29jGcx63yF72XFFzvbOnjGnREf6uGs9r14syAwy6NlQophsbjfGkky11BqgJgFWBbOIrLRSr)RnZUfVXY05IylGgMxnS0xJhHzfqN7uTayZJsdzIpDED4EEASSBcS2AEc6fKAb3IFeyQA6NZ0TeJ0se2WgtOsxsSHgtDPy7C6Gu34(csLUZfkdztvupXPrwYWMXJGSDzwv61qTJ4nnBGQ84uwMUQadlULpjXDnZ7lsEMU13qhJsaxPaElYNQNDORZsApMiABLEGqzw119yGrLKuLJg0RLV3xiZPl(ToULtvh83E6m9vYGk0VawwwCsU4)xLLQXmIR(Kv6FJscfSx2m6uQQw48sn3sdKf7zhPTmHqEl65EqwErTRWR4(MrT0Ol9CxgsIfvWOnrqPgdMs4OvSZkDdTXxvF82UQSwQK2dg6Wwq3QL2HgLf()eRab5FE5LCkRu9waFuiUhCWFeTmO4E2eC44vy3WS3oH7gZmCasXEYQJM1b8l0soO(vHu(XkbN(6wHwrJ3xrJ3VvA8(wJc5pzA8(21410LJRgVN75mqjdv7IgVVbn(gPpOPgVgV42hBS7sOVQMzf5PerBxox3QfJE6s(yd9bl(r4GnuNw196Q65uimttPN2givV)PuNKrcB1DR4NzH4HxnYj4onGQkBYen(Hf6E0SIDZazuVQShO9WemAA(NjS7d)d4NIMJ33Vr82TdTjjS90qeo6cnyFSjAl5lUyw0vnuFhMHRrdvJfRwQHQhc2uN(JLgQMq5kL7vPpPuWl8dgL8oFLjz0oMlYuAW4RfmAnEDtX90jVbJbtToH)3k3pNLFP9OPvwdP5v3P)qZj1WMVcoeXvvzQ)6sgyl0VGp7nnwtwOgSuwmv4eqwVcQHf7TXDeo5SAOqZPXXSBiUX7ksuoBg)LBLUfhLd(T2GJALR)MbYsHZBifCVAbvZzhFqNVjogyBCpdhjHSvPS3exuD2TXmA5AGTDS7xQBIGkg3WDw91OwOZMoBlp8OD5uAJ(LvZ21zT0Zk9eVSJMKSmAfJegfhTCI5Co6QMZUG2MXjJ38BUIwoOqF4XC60DQCX45j)GemDreVuqbcr(6J786bK1jw2md(SU94sInroEi0mDAumD4ilyOMpHMN4y)urKlVQ8aUtrWgU1uogIAbMs5gIz70)A0(i2bJPlq1JyttRfQyrfllA3xWNMP1n5yrtbLO1QawnjQVzGc3X6QSx0WhD9JK7qS6CAwjhTwqQ6y8w9oudE6GPQwy4BxeCMPjJ3iEw9CtJ8EOs0y6NmuDQ1iY5UlZLuU4LhOhGVDNa41Ca2mnyoY1zUd2yMndKc7SKgoltOq71NQHvXlpfBEo1HWBgrmuCBWmE1g4KYTRU0jyBX0nRsxJxqmVSzR1PguWycw8aXBYdh91W0ejUZUc8EUyvxyXEg5xFb)Ze50oPACrDBSwtcq2Sf3VSAkddqptYMVWcZTovpq08ZsSyob3wn4wsKgGK6LeOIa0QZ2hKTzy)L6DuYBJYdXrXuwtFo532XUAW2YlTG2AAOvI(QL537kiOA8Fcpgw9SQRT7fbYFYvE(3An7Hwdla2Yoag(YcHWadMjQjLB8mDRSO211x334PAQ6g5C908r41ervQI0fnO6kyM0yTOoYA24npnFBc8TRGkh2HlUJB1fzD(hlIgKFBpv1DROJn3Xe0pYs2GPQmyDrr9y8bqZuAd07ySD5M5PLvQwwN965zxQkAArLwQwFTYtAYUknSTypNkJmXui)EcgnA4WxL1cR5ErZKTc3fLUehFy0SvZ4B)cEQh3XRC7Vp5hRp12)n2jEujP)v3(GLM60FtQyENxexWH6krVQd1vYwjfO5MEWymV)r(njrX(o9tkAz3QSde2q2qBW0fTmtCjrbMaEA5A)Moailkagf1ou2T6rrcgn1E2QNrVBCID4L9W6eeRoqOhvO9fiDJJ3j9I2sA8ussVSJlauZ9vmydcmSKHnJpP8N757)2B(49bPyAzYkk6TiioR08I3K6NlD0SF(wHxM5m2TJxWM8KIQGJ)KMJpd3)n2DSh(wU)(KvWiYA(5Aw9faiEvwORPswp0LUEFPNnOQB5FfOBYdb1r5n6hf13SfLrG6jDrf6SNQ(JjrS9dAeL1xMeTto6FuKJeqvX1CfaR0kfSp)OGXxCuG6Wdmu1k65AnTtStOJMsF7iRGNg6PJtUtwxqMz87kZNly37YZFDh0mB9tDW1cT(mV3wIno)nNbFdLbGVHyYB)daMOvPQ4Cv1oTkcdR7S6UwE0EdvT0BXL9F7OxIP3I3X9kyMUR)EhnACWw)Wix9OAbGymRUVLuzwQ3dtocV6BLDfa286AxfIVtpevVL0vGl11ZUJqV(MqVb(QEHRRcrVb6bPsq5kWLi7HUc8DEM33eWEuzfhvGRztrugadvUrJbHyjFHGZEUg)XKVQ1DfOAUa1vvTPVI1DDqAE3R3GaOUC2DDiuteGYaqLNGNAW7BXlIUDTLTUQ9O8LE9EwrY879SUDrfRxEEVx0vWTHxoSxVx4nyqj22oOFwj0pZc0RjVZDN8mvpm6inpLb3FajTzb0nOlsqxtyhNGo8EACGGAy2xS)4KzHJfypoU8sb2dTiKWbQd9Wq43Zt0WSNYc)JJ7kuG9aZu8p2zJQyyiY4Zt0WSVYccJdsjvtAL5e1lbxxb5HMHqmmkP6wzeiseURaFNJxZ)4yT0)qNHGJlyp0MP0MpJQRy1N3QmA0WArXXyt7nTAfwwFK503lzZ0MgcYRcv9JLPUlZ0jguT3rRnglQE5(q4oDzT7sdAJKHxXmfVE20W8uA2mq5AHhKyDjG9b2SinBPUeh2OmvtZ5(uOphvW)V5o7c3PrCGeQ3D6AwfTZjoWdbGyahF2ZidbUSlxnO3Jp60azoIZ6H0ecbJwplZ6Fkylp9CfRmLkTPgbFxzV2OPZgnlP7ter)bX0jbSpWghOzl2N9QVphvW)V5o7c3H20P)r1gHgC8BRPtniKwtNp9SLNEUIvMsL2uJm)Di860mqzfUxzPNtaz1(CGb)EG4ldYG43EWeEx3LdlW3dSgAldK(qSNgXC5UD4hK9GcwGSgt4EzhoKaEpWxSianHUfTFablfY2i1pvReThEhzgOMNdQVphyWVhio1SqTD5Wc89aRnn7JSBh(bzpOa9Ze10HdjG3d8v7CXMTFablfY2izSsqT0facGk0Sta1ZmqB0StaDxDl(idEha860KP9zNgL1zMaov)Ce)DDyq1JrTh8UAw1Ov79h8TvbFxte1rg8oay3KN09Zr831HzNuBC3H7DsTXDW3E1g895qdWk(zNaIVEG47cqAe1(juxLHDOUCcLc6u0KBNMWQ6cE(XhprH1v(vqeO0JK54BPS(07fD96p8LetXHw1mG4dmtVEx31CYiPuCvhrpRJi)jTb)UxknMOm8ufzAVN5nacEUkLc)jwMD2tUm7SVrYSZkKzvZeBSvWfFqRMotbKwzyPXUhxdeTV1o6alvhLgOMvLAnn72izOJYJernQO8y(ubFTTsLXwkGx9kaPa2gVoq1aKTn7ZtIJtUNDGpdaLXm85BeFNB2WUu4rZYSBo5GIdhm)jDEYM8Y(TkHTh9Bwj17zZWoplipysqw43T9dSlfg0PEYZ7fFQslpHghN6N5BuU3pM4(bzhBoovi5ttLf90ubIhNccIOcBoqLB9Xf6pXNoINKZyWbwPH8uhWUdcvaS8ft4Xeue2wpGGAF1bEAkstQYA)Gys9yvZ8FlWzPRJpfqR9Q6RbGjwG5WG1hPkMNaShvC(Oc8dsT2(eFqcommKVfa)WWTp01GRzWEOnW(TDy2tMe1bFyV9FsBCsfbJEyct6aZGpo3KfprqTkTdvpinvqviHocT9TaC71wzrd0Q8uvC8)0aynD5icCRG19C670whS)dJXTo444J3teuRfKKAY(0AYprGBV2owAGAv3vBxoIa3kyDFpsDAIX(pmgNyqvRp7MvJJkWTc2D0u)XgChqxypMWMQKq2TPjhvGBfS7OTTJn4oMsRdiSDOmeAHW6OcCRGD3m14ioVBaVprGfkUnS)bxCqcSLiO5D(e7sCeypqxvIeq)GWjOs49Hb4e(sUNaxRIwqsy70ViWT9o(6JPmB7h(zgrJGeVrOf3(uKYU5JG)tZJIdlVcuZ6xDcNF5vNvUB)VcFs(VQy6C9718RyVH3xvB8sZX59XhLAM8e4U9dUJa(eiG2ZtCncy(iaV9d)LTJ)reGWVKXEPDl(WS6BF5xTD8Si8P4f4NtEy7y(Aj8NKC2Qjqhk2yNYRjE(w7a)oQ1XtJbV)c56qye6VDm(4chLJ)iJ82oEbUD4RsqTv04j7wHonmFtkij9WrmgFlGl)Lb9h2VnCtEfC8QK1xLfMhnVGN6X)7riSVca5Raw0SieMcYBXIdH6W7y8q7uxdohNt)PZhsNNzapWdPtByO(7kd1)qYqpoNjS2Zqjo1tTHHwujxnm3iYTE8XUYnivQIIwHQASO6)122D11wV22xGFR2wWIlrtfKvz0SvuUVwk3NIY1uBVIM)OPC9NQaTTRq5(wPC)DIYlVqZvNg5lonYtys0(uaG7u9)TlL)NPk2KixgkLKNgrSJfcOPA3KibJkJTMjwoxsGkveOCrC6IIbX7g)bq)qN4M3Im2E9vYeJlyD9yXFr815YKMs5RnG2xpOPQsqxaD69Y2Dk82uUYaRwNOQ0(Cb0Ypstfda6vd7x77VG5h2VMMKhof986hk8ycgGLGpt5bP3XksWO8SWyWrj0B2F83(Nm315p7kZcxhccDStyJbRYJMgTM7tFAywYMu8jq6wmkuWzRTJ)LK0W6waaW9IE74LSgcU9wOTSO7czfJOtUwP(yERQKE(arT0le9fq6TBkyz2iSIfsNmc8zDkWSVg8C4DOF9fibm0lHvFHvXdd)AO4pdZqH4x2edeU4ppnigIxG9FhHrbiPlLj2tKXbt5IMY9J(vrZVsZtOW1xmq)h91KvH43OqqFTbb1rhuFZGoLXslC1o3PlZ4Jwpp2S(Xhn7Bsk(gHIgWn4EZjSbq17OnR7jsKYcBHxPZcXl2Z6hmNR860T5Rt41Edbur)7iOHbt4nrs7GD9v(D6sa2hFu)V3H4jl86Hgqe8H4rYibJXv888u56Ak9LzDL5JQKLu9l13N0MqG16SrPELrxOX04MKUGeVS42f9fN)4J67i79v7YZ7jGCLxE0fWw42KMcQcDPeE0ewPsSKfsIqbi0wR4)IzttFNlr5xxpXq8J6v)ZAhB9VE10Fu5VR57E8XMQYe0hnZJ1dL3ehzwOqpkeGAF3IAInN3dMzvQe08AwUI0AE9ixZouZguLwLAdD6Qm8VfacXtKuhLUEb6qfSi6pblsd2)JMclITgWxG84PpAwiGYlzPDIvM84suBhpbFMa5)eMoHGjymaSh8RPSuJLmFEDAkWUfKx89Gb6nCd0W)ErYM4z8vQ5JgUqOW6RWAUVpaFYRGHihR1UmHc2huhexCcgpy5Q(0IBg734sTT7wu217OzXLVpxy1BP3iIHS3iIl974mgCP3aAATy9khjwIvazJxBUXMfPuF9uA1I2Ed6404BKmfEVPclnUZ4Jx0rNrn35TvE53uPXjSPKCLnNO1lc34cviKgjBLHbjIvr96ar7GPIFhNXFzW2XlsdNF1ZxKNVo77o7S7V)((3NC)cWXji4XLNLTgCe8kqR41doJHfNgTA(g8TX65x)R8KE(Zf)WLNfC92X3VikUfqEON)B8oJtnNMm)u(23D9VkKL1Fc)joWJalhBw)kWoc70cfhZ)xUoyEd99FZ7oJZ8XrtiHSx)dcjQ9Jv)oFCXe5IM6QTfgn39HTD0yaEEMCf07mffuDcQ4ADGX5p8x(lLBxaoRiA1DjFgmd8fqxCvqmZ1RYzi464L6bOh)Djw1M0RGEA9xXCEinhiGzF815NdBAWVaZAYdWvJyIa4VWyBbnSFE6dBh)jMhCfYKFV0rrSVONII2qKEJlrwYjeVtLQlDZ8E3eVqYCq3tmybGfRdL)HNO1Xhimhj)sv2EjKqAIVvMwkDixRz6DjMRIgieYUzK9AtgzpC0Qb66p0OVX5j6KJuYkrCHRNZDKTjIaHd))ruz2D68BU6YoG6hfvfaVtsZcJdZYkEeprSPEWlYdPqU1fFuOrt2VFrsc68s5RgmpSbmUdWzj7j(QKTMzVRfpDB27y9TypsmLb4v9JGzBcRVgxXdwKSR2h)9RgwfAi5t(EL0tXor1VxLegiGF8vLUJ0lk9LxvgUGKWtoynPOuyAci5BuPwNAJlAn0dS1HSflV6uUa1IlIGrqhWf60Sza7kFbj6n(B)lHbQ(vRvNrbmTZWmUgps31zehgCDE)WvA5Pge1v17lKky0SKw9o1OjUSM2SuHOqQF4oLX4XnZNI1hLBHDb32ZX9LNxqXupc39uXY6uk9kPhq5R8Q4LAZyvhQujrrM1CtDznBFfhwy(TASnZsAhDiT0NrOPthJWoAZPaIpm1fBDcMkiDPnXFO6Nl)mutTZl43XMrwgA33ZMWUD8VLKZZgxfy5Mt0n3SEstvc9frYR7EXWt76q68FXB79YUdFbFQoMuxOBlEalZGOawGf90InTInzCa0a(DyMeAa2r1PQHPnA2Mt5SiJ)IHTNK0X2UyazyGAGVITcfGA9TYvde17I3Ec0gQX7j8ApBvCslnAjUYNM(BCE(LVEGY87oBh)peCHW(eEUBynvrPu9BLMFfW3PPzKqRv8q6VIYhBdqqJTihe7vaWrJ2Lc13NGBtYFfJiOgK1rjGUPTGLexaNI4R3QXX8c)Y70LB4e81Gs22vOmxKQbdUNOcp9wSOkU(QleROjx(I327X)3Y7AV322gi(NLHbyyHMvijB10b44pcBaT)FuLJLB8IILHLngkGr)SpEuuu8XD8HTB6ggkq)dzrQJ3D8494hVC(w91)ySF8mnmf6MpIfcaP)4eCNS0j455urYWraL4BX)XX)k8pgpVXp0N5UKez9OFUT5BLdWTssqMpx5REDSbIaj3WczaoT)WPUkWbyYeWeCnjwMvi4GOmxIvVGTGmKzx36MkcAZfonfFdyj5PHUgIjEvA28Cj8iO4Zpx12vUQQp5W0m)Fxb7n(wLlMrYeNNinoAMwgj4fHay33cptZzlDutGMedvB3QZgcweCZIXb9qF1E)WKWl48I7NmflXwk2(uaxucPFC45SrxzY9YfWsC7MnLmZhkNAtLdfNCbwWcSZQxmSfEvtB76Mtd0PAnMxCFAppBMpuLBLEtta2D(8MtnnSLEpkalfKqI(zcrYdIUisbOEueL6bPeNUuA4R3QvTVUDhNilB2(6QOnH4JObzyCQY2kSze7pDq8OIMyiKW)IXRnC90bZ9jMwnywU6fGg6QpwUQD3PowSn1hMLvMV)jHX0Nf(CbHOpkucBA)f05T6j7stsLkjIup5c4t6t)Ihki4bgkCuAUXWShtcmkm0CSjw5yoSxqW3juVZJDbE1A3kawJ3y8MOA(D59P(rmBVD35PQ4FSFMcBKfspz9Lr7a5jIppU53BfFdNOWM2Xqnjl4GklVqbHu4kq8Y2RoKp4DiMUxLQpbFmYjy5S0Ky4wSZE10ZzdhN)zePdW60ncaiLg)yn3yxfc1IeROOQkUGIcj6PXrX97mF6WLNzeGZQ9CqlWw7EssWTLqyy3lhMBfpgwmyYlquJdU4yV2854GuT73ShS1JKCLaI9opycxBuHR7IzbY5gnXnuzrKA5APKwpxidP7bziuzpXN8yzwQRnhE57xrElMC7RVnL))bko)xSC6)bcj2(uwizSjDn(V31Ecc5RAFF6A1SqUSysFwOLvby)thlNvWcaZ0XZC8BlbfkgjWohVco8y8wMtlU9D5QD6jHUJedFeI3o5YabjA0qWTcD3AURoubaG5Uanl0L(jtY5u9nlZXUj5Ugt6uy7L5Hb5Ri)aPE38Te8XcZf)SeRlUrb9D8W6S5H0FfAvEufEKLoXutT)gir4VKYw9(xGx4fUYn5NLpshvuFQ5oUSrDtttbtO3CfcjtPFss7iOA4nMc4tHNsZ1BCzQZYZzDHLMrslVXaCjHCTFbvoSNveAn69TbXLT8PuavsC654oJjg5pjLN)KrACaps0mcmW14M08Cu7ulG9D(m6b3lkS)bvhIHB(40PwlfEiM1lYtmnIL5qC7ZqHZL8qborifcpsgYkLzBZkzIBm(mLW4K5oShYOxQoQITqdMET(dH)9tyj7XrjzzauRlJXCIwt9Aweubo(ybTM9rYxUW4TNHh6b20MDf(F8jonX88qEhqLtLaf0q6WGk7idFIOqCOdS(qx9bWsAKduOnS)utxDKdTbmu2v(xNw)1xfAsrmAqYa9tHMsa6Sro4nBpuZ5vroUvvFfooLPG90lDurOs6jm)52b4f0hkk8rqvbzVHskVD8UYIZSbxI)8waDYWLWcuvXCgwd)YMBq95x3bBO6Sip9DtNtd4qYO9PjjNyBc3lcuQw4cVN1(ndVxMZUI9d6j)s5cJ55hIB9fWrZQDV8GJflbksNFjOin2BIu4QFEopa3dlBDs3KF8(cfHyAKeLqfME0rFYRFxAVq)xdvpgL8QDSeJuVB8mFmfPqlfN8T0)6JPgNMEdhGI3eDALUu0qJ1coTbGzbJR)QOFDqeDjm7UcQ07naub2jUHLHDyAUjBDyI0FNBS7YwJ()6klvuN8L7tx5GEbcVY2IK4JkABi8ELRyL)9V83BbKhZBohpZ2zwd3Uo2)Tv0KC59cH7GxdU(9RQh(d2jZPh4n5xv69v9Dy3(PY6IU)(y43DnThh6wvzAgLo6TRUn0d2WZ3ByLUHOl5mCN(qe2JT6nzlsFzQwBeu55j(eLeFf1c2o2x4S7zH6n6q1U4OC5lRVG1eo4yalMer2pp6U9bUupN8xQCohvoN7O799ZuoNtiNZ)rjNZ82Bkv7tPXiNZnLZeTOsl58V23eJB318n4)R77xgN6unSanqPTRfDAzy5E3WBa2AAHwnOEB249F)l)5H(ETXU6T9)U)zBvlVPxOnpxOEOry9XyWzuQr0glHCItVzmrR72QOhrEmiLbgVN9Wo)FSivM1903GvrYCiqumo(Foo)pedb(5)5U2KKO1JDJK)N)FE(pm384B5cGakEa5MeNmzSXLBooKnhp(5o2Q(X)iVi7XJS)94)a]] )