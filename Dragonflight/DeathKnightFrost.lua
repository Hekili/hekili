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


spec:RegisterPack( "Frost DK", 20231127, [[Hekili:S3ZAZTnos(Bj1wrrkjwwK2kozkBxv2CZC3KBNDNAsMA)MLOKOS4gkrDKu2XPCPF7x3a8baiAaq9WzM72VKhcG9l0Or3nAaCJ3nF(Mpnlip8M)U)a)Z888VOp8hNp0)MpL)W6WB(06GPFj4w4FSkyj8N)uAsw(2X)h)3ylpeNemdHqwYM0PqRlYZxN9dNE6Tr5l2mP)0KLNMfTCtCqEuYQPPbZZX))0tV5tt2efN)ZRUzIE07DZNc2KVij9Mp9POLFaGC0SzH8UhMn9MpHD)epVt8V4h2o(ZlctdFr22X5lIG)m4RH973F7h3(XYE5DX2XD2o2)nqN3ogG42XBwJ4vUxN9dgA0J9T)mWgHldxLheRVBdO622XZttwYqWhK(KbdzFYVgKpDX2XEd67x(jz19BW7oXhPGphfMUD8zEBhVonCTu7mu)lrRsGomDrWQBruI)N)ZGCqafT6wa55jPlf(QloXZ)heXTx)HBhVKdev2BWBoX)CO3)wy2dRMgoB747HXzvoAWWt8FBnLSonkjnk)bnGBihCBh)7fcO)XK4O8Wu2)EtwaYaCm85Zgi)D8bJFrKoffwNFYz8XHpdS9xcbf24KBJMw21z6hlgCgxDQcWyZ6ap0VHceoOY1Dzq0QyGjZteydqPVN8NXP7Fk6RBh)xtddqElzoIOvZsdUnjlqQ7mfsbSWgnHbPb9VqOF(N4Zz23pBweItuNly2)AtwoQbw(DXH3fgZuccwn7u8xYd(c7)lsVCjEYgqK9J)2)uclEVRaliKrz4DbPrbtId7VojbH8O0nRqYmBdQmLViaaYdjBaeMcJKRsG)BrpbSSiCLyRbXG4ygiaXpAzaiFyaRpBYe8t486nRMghgKIF8dLZ1NUiC6xWMx9cOxRcdNHuw0k2GxHHNpGgEE92Xt2uaO0W)NnrP8oEYTGDT(38P4OS8mMTmG(IdhLhKEByo8d)DMnYWviNo7M)kyyAkc0B(0C0u4OS80OVeYnlLgTM30NyWau)yabMXKKhWBb6diQJcqlGZN3)lrXmj3YGPlIwf2hectH(FjyRIzXcecrthTo5(W0(ZcNhnnQO1bSMFMWGq(9jJGz9ZgXej3KdMuviCfCNgbm(M1maLfMpAsYQnz9ZbdmNnyK)6PSg0sLz5bOqhPJAXXIK7zDAsCqwoI(ZmJEvGwqjv8dt8Mn9bW21OsJikcFERiUoVT4QgsjvgDqan0DzgyBhME1pAA4eyy7lWiuAWkqSCLzXYBiXaQXZKQNtp2Fna8HIOpryYB)cWk2(eMzMrjZhLvBKPe9cuz6kSp3hTcagsMxqsMpt)m)sALH8Uc9jD9iu2bZ7E8rdA0d5TplKlOd(gmIpTsxdeQsSDgyDjNTOgkzNfwZ69iMHc80Bj5PAIfgG5KRHHW3TxYMNHmjoM8Lvr3UiVpoSdwOVnSIPlfHeYIlzYcDclWNdyDOmwxUD6S(mdPVe8xqsSCBCW0OG4rbZUlawhh5iVbTLLcZOMc5PAWCx1W7YKvoOhZfgtbIBwY9R031krZ1c9uwTV)SnLlc2Z0udpAdRKC0GAagKonyfSatsAkWymasBQ0IcfPUEoaeGjhTawW04QyGNIGybzWOPQlJ9bacBh)FXaHOLWKSm2a0Cu)DKwLo(Wx14TpFi6zelOuyrTRPv0QxoQMXkNrC9vmvkef7YxVD8BHHC(3FCOpgg2DYZBaJ(6zEv9NzFrbgkwdCxqkoKZuAk5odYwVbL8Vwaqz2b6peOYRy)JckJ9b3)q6YSrZ3K(GeXvnTuTtfUg2tEqAZQfjXpGQ8HRUnFHeBO2MwkSh1SaJoV4GuMW8(8Gy47gnnfITzw9IbMgtQejeI8rHFDD4uM34OAYqPHjJJLKIWk5lXNFMzbhTNyoi4OxAuNSZotEqLUI2WBW20(n6apBIgTmyEUuNmpEUiijB0KGc7z9Spu)oLfwTlMUK5RHLXMZnQbbl1uUaokYSgbwrqaYRCvgCDh1OBFp8P3f2IiYCkSenML14BKDubD5HPvbFMHCU9aPkIjXG)QgNtsskKGJwxN2Hot(tzmIO27ovLcKjvhzMsVYJjDfnbmO6slJsHzMNdwLpPY2h4oAiY(O(dOl9n0O2IGLRLml8sUhjMxUx05kJotBs2RQBTtQTL2XSe7UoD7wh4UdZgPssaTERr4PDC98HKOrvD2SiLAy78bc2NjwBG6B9UqVWMoMEj2dnI)MseaEQIA45jJ8zWwQNNc46T1CiFTB0P2zHtdEWCi3hguclbLKMfghMLjOvthG(HbRnmj2i(5DBqhNRQBGZqi1oUeGBXSYejVXIXvrpz2vtS75IYcjGKoSgQ4sLKygTWcgVdyK2OWvHlJWCBF5vSyAkcMTWMUscveYfvncTLP3wXcv(jxnxduENIzZNmHa28I4jN(0Kfk1fdEQxmYsYFpOlgr70JtjjzwsrS0JMhEhyfPq8kSMHtP3)zAZtBpdgsmMxyl0TA6Gisr8(Nc4g8MH8u7W0yKOuneWTdyiRQA1WOxoSXy2o5AU6cFAng4(y2tKiu7sEgZiTjIwD9mzhGvxx0HKv7zfSAsPRX00zvOQkQUwEtL0LbFkp5nm0BLmowJTw863b3zunvRDPIMOM5hY8GnX15vO8lxgbRvnpnm8BHIqU0bHYUbcYGv3I7SSA3OgaMgedcn2)zeUlZ89AEeVEAY5fOqM5yHOdsqqhCf4)AWTq)YweghBE9mPSSfS8BJcMKLKoz06W0PWynd4dmgJXfdeTfhKLfTmkUz2TkZmL29KPm9u225gw2FLD5Y82b1XCA16PtQ9TKvAxyob0dH1pR)KYzn4)kEtiVHM6(fl5fenBeScnkJMnlRpwzcfzQTGHu7r4xXkrGrKaMkuta9L1XbRwHEqPzr42tJmdkcZXPOc2w2s0wNMnjUlBdv4bSdfBwKULcTZdnwISB7YQcYlL6RaibJylc12QWw6x7tHiRiSlXAw01oNuGNnRIddGzRm7oR(2dAN50Otg2KxH9gr5JQJy6SQu)wXTpagjJtwLPf)cn7cMf6UmoLKFRRLEnwO3zXN6uBrQ3uAt6AFJiSgTZBuniPhu9u7MvAoCjZwlBl2hDFyWAaCL2jDdm19shSmUQDTvbc5N4GyPv76coQHZuopukeCKwLqIOtP4HZkJbqYbMOLRttUdMtu7KaHGBEA0TOHTVgoDds4IgcKhiWks7oKY4oyLP1EcDN4Kydwqu)IiqA9UjwY6sZ2O2YIg(OwmCfn3ygZgw6xGy2NB3EebZ5LZh0pLKIvRhwIMbRHrPawfeMGCpqgGRzHyb)H)by5f0jWDfK)tzyXdojcgqzsGPjy7jZNxtsBlkfr23xxoYW)ErYgSaha7uPCSH(bJLhiVEMXQp8da5GencaVHz8slKbjqai6vhGpWpV(IYDMA2OsFRrkNCIWOW4m4FFw18IUmfJwivFf3HBwQkR3HB2)TRqW3VQud5LL)y9G7R4Rzx2S3GbAdSqqlrh3uY9fEOjZ(2DPTyNBT5syTLyuxYjzOzi5U8ZZG8ZFGgbOQF92TkMkxNu2wTQfQjxke1No9Z6Xp5A9sxmx25dxDw3XXirIxJ6LKnxsHfH9SJTmSQITqjj1wezkL5)cqf5bO5NIZGXpHj(71Bh)ZtFaR0y0LlwTDVD8Vx69h2x09pL4(jtEivMhAUwQEXRlYFoymiURI2ZKpCMYbuzLs5rNRsAUutojDygORk6MIkvOzYOLDFUY1MNRyoxs0PPChfColy(EZ507CyB58wKRcBAx0AngzgF6uOsMYI)FN6V62K5tNq4DtO5Sq57kxtNU6wY1pXQ9nye6T5SMEVxC3MQ(zX8tvbF91xGVQlDYLn9IKemSK3pLhNbp8am(cWpahZlC5aoZZlFQSDBeePmdcCaqVBJLHOwxQEnxSMCLwH17npAxfnExlBVNuqVMpGeoSZes9sto)kRbsQcA)kIQf28ixvz3JsEAFqSoP328dRtoucrvImLQXsKqTS1KMi0dKNHoMYE7CfJFOxj3gDShlr5gvkvbn4oh5(c1kBeOrnXGeEHF0Uv0Ce4Yhts2oRTonCAYYjbARzxhcwKVvy9Z96hLbt6N8WO7xegVMVFwfQqs95(frzR5vaq0QPbPRcYdhfnTa6Y7W2ipicUPXBMfwTLE7g157a153AQZxK6mKXfbT4ArXIGSrBY47ir5eYwLOyRlv3vs0x5ns9bM65gcPRUxxX2vXETyHJooKdhjQWmzwra9uwZ(hXHz(PSoOciz1ygIZEw0DrStx8ei(uopYp92mUe6qr62ltvepH7WVJN1AoHZ7FnP)cbm0hIKhAmkh)rMs32XWalEWPXusIljXo4dPH5BsbwXdXym6Nr5VmO)W(618XZRVTCpcFDLYU2sZ1X8(vRrZXQgnw)Nynw))COXQLmf1ynoCTdzNJYccYRYZ4B2(tDJ8r)kN1ByvxzppQBN5Q)UTX(KkSQciDT)u3iHaY3IaYVwaruvbUoHxO2k1wKrkdjYXqQqoAMcJCB9w6yNBl3NozfQAi0tj8pckWQDKtL6a(TJeohXvNds8Ev5vgg(Q6PgccnKwUVcx3GQ0Uq3PsDWzQsDwhnv5vtvkN0tzAlk(Uy(5FPMZ5)gFZv8guTLjkw48QMh6BOErSPDolyjwBi7JsQEfT62BWzx3qcyKZ2H6hra6z9dIbxWxaC86nF7BGp5ts(QEtHldwTjiExl6cbU0zC6lIZDiKGI47dkUaJgLXU)I0fvjUrgsomisoLz8X0UEBGmqFVyhw7((lK4Ygx5kM2SuYQVltB131F47u8r9xttYdNIELwEc1MZUfJW9V(o2(3eLNfgdtBXj5)4V9pz3duq8zzycvwhUAgRtyJyzVnnAn)UqQC)U3o(wmVhS7CNFHT)6v7eo4QjJN2oEjRHGBVfAlJDQnaRfsUDgcs72SP3Nx7iJ)qEKKyKR74jl59j)yDM3(BSOw1xDP15As)UHPlmX2v9S3PMG0BmLT(wE(mKZrKXkmXufKiYhARtKkswOYA1eCGZsgJYGD8e6PKoyhpKfocsz(E)UwCSMYYBitSTXds3(FoqD6eZrcpDhtSILaYmnrE(dPbXOYjk6Nbg1wcF)mujrWyjm9Czq6xyrNv0)6tturforbhnZHlYnMU1Vq)EsapLUD6mKMRzpDDwAK3ukdTvzbcJDDDpex04vQYHs9nYxthKPSf)wh3rjoPvUJ6uL4EXyniYYItYf))QIunZOD1LRs)xuYxG9QIrxzqwTW4LAopFK1YzhPDeHy8w0XCy9PIstHxq9ndkPrx65(yijvubJ2eGKAiwkrBwjoR0n0g(u9PM(QYsLsAlwOJkbtTT0gWOSY(Nz1)h)ZlVyizvI3c4JcXTyd(JOLbf3nHGdfVg7gMC2jC3uMHiif7jRmzwhWVea5G6xfYOhRcB6RBDofnEFfnE)wPX7BniJ)KPX7BxJxtxoUA8EUNsaLeqTlA8(g04BKDGMA8A8bAFSXUlr2QAMvuMsemD5CDRwm6Pl3In0h6ywHZbBOoTQ71vLRPqyKMY(SnqQEDbPojJe2QBgXpZcHdVoztqx7qvLnzIg)W6ypAwXMvGcQxx2d0EycgTm)Ze2CH)b8trZX7i1iE72H2Ke2wwichDEvVp2eTLBfxml6QgQVdZW1OHQXIvl1q1dbBQt)Xsd1ySpDPmLumq6IyVALgA9b72xQvgrvoG8wM1q7R4YrK)TgdpzDc)VvUuel)sDlTxc3YR1pPvcAEFjYs4HH0myBf)sTqQtnuhHdQXBkLXTqlb(SlASYQqHsPSKOWXuSEDqdlzBt6iC8w1WHoK1etvTIdYUISzZM3E5wPRoVjXjjZI3iZlDBwE5xmqEu4SgJcUxsFQzwJJ05BIJbXg3)UrseBvE1njfBo)WPlXpR7cQnVlDBiOsWnCNvFnQf6SbW2kdpA3iG24Fz1SDDwl9SspH6pkysYYOvmwyuC0YjMt6MRAo7czBMMmM2oxjlhuOp8uoDE)uUux8Wl1LAynDbODWUjid(I5e89Sg3pmEv3pmi0mDAqmLAzRPMwEQN5(PsixEv5bmNIHnCbICmgffekL7iLTtFRrtFyhmgpVQlRooJvXOH2nM7PzgBtjw0uqjATkGvZY5fduKowxa98gorRhtUdrpXBNpsNmKx7vNK3QNFAiuhmd1cJA7YiNzEY4vNSvVYOZPDRjtRZlotW)sD0eJDO9fs1MK49(Hn)j6qSgVi5jEfly8u57KAHRo6imT00LcsxJ3TjVQzR1P9syEiUX3XBYdh9TW0ejPZUc8EonWRSpB1314SHCAx3mUEOnrRPbqKGBX9Ss5Kf9cjBEik4H8j6bIMFwse3PoFTTqdULmPbiP(iFOmaA1f0dsk03)r9okj8q5nbOykRPpN8B7yxnqALS2yAOvd9vltU)3x)L4)j8ee1ZQUgDOf201(tUYZ)wRzp0AyH1v2bWWxwiebvWmrnPCJhhzLf1UU(YXepqov3LXRNMpcVHdQsGIUaPuxbZKgRf1rwZe3wpDkZMZ1BvFqymKFWw4iBRDU88bYKHjp5Lv3Tso2Chtq)ilzdMaVG1ffSIXB(sBQEDCGBG(Sg0rUfV)BS4XzdhEKCEklaOnSKGakzn8JmYNoAsljmqVd(2v7mBvPAMHvJpEE2vkfTmQYlvUhufiazxLqBl2oOZgy13wppbBEAg(gknTYyHds4TR01N4dJMTAgFpvkpWXg2rfwwZ5wbL3vLFJ9TBh)(YRYjh2DfZBDc1hvtlHPzHPLL6PdNBCkavu9BR3GLZQXSNBfuX4Wz2O)1Mz3IVDNMZJSvOHwgW7R04r4r50CUzTcS5rPHSHpZ5t12siwMCrSMVWOwWT4hbARt)sM5eKAZeSfNR6EO8ar5gs0j)FA8O9PY3SzC3bQWyRLVEYV5MpDFqkM(JSI6LkccJjnV4jG9fshA3xSv4HqnJDVPfSjpPOaQ4VGW4RE7FJD7RHpDYFizfGrwZVqJKfaiEjhORPsHo0LUEFTNnOQBLlfOBAbyvSCHESOEbIRGbQ7xCvOZEzOpMmX2pQzOS(AgODJJ(hLXrcOQ45RcGvALc2NDuO4ZpkqD4bgQAh65AnTByNqhnL(EZvHon0thN2LSUGnZ43IIVqWB8lp7nDsLEdwUwO1N792sQX5V5u4BQOK3(hgk5D)bGs0Quv48w70QimSUZQ7AhT2BOQLFlUg4Bh)sm9w82pxHY0DXO7OrJd26hgLQhvlae4S6M4rvyPEd94i8QVVUvayZlYBvi(o9qu9(ZwbUuxC3oc967i7g0R6vXTke9gOhKkovQaxIKZ5kW35zEFxa7rvuCubUM9CqbbgQPGgiHyjFgLXpTBVqJ)yYxc3UcunxT2QQ20x(2UIKM3k3nyaQRTBxrHA6quqav2sEQbVVfVi621w2KQ2cWx5175frD275D7IkwV6SEVSRGBdVAyVEV0BWGsQTDq)0sOFQfOxZEN5o7zQsn0XAEki3FajVzb0n4lsqxZyhNGo8EACGGcn7l1FCYSWXcShhxEPa7HEiKWbQdnAi875jcn75yH)XXDfkWEGfk(h7SrvGgIm(8eHM9DSGW4Gus1Kwzor96r1vqEOfieOrz)avWaXUf6kW35418powl9p0zi44c2dTzkT5ZO6Y38fTkJgnSwuC8Q0EhCwrL1hLl99s2mTjuqEjzQhxM6USqNaPAV9oBGlQE5okCNVS2DjK2iz4vctXlUlncpLMnduUw4bjwxcyFGnlslwQ3c(nkt10CEef6Zrf8)BPZUiDAehiH6DNUMvr78mhKHaqmqJp)5KHax2LRg07XhDcrMJ4SgLMiiaB9SmR)PqS80lvSkuQ0MAe8DL9AJMoB0SKUpre9hetNeW(aBCGwSyF2R((Cub))w6SlshAtN(hvBeAOXVVMo1qqAnD(0lwE6LkwfkvAtnY83HWRtZaLvQuL1vfbKv7Zbg87bHVmidIF7bt0DDxoSaFpOAOTmy0hI90iLl3Tdps2doybkAmr7LD4qc49GEXIv0e5w0(beSueBJu)uTs0E4DKzGAEoO((CGb)Eq4uZc12LdlW3dQ20SpYUD4rYEWb6NjQPdhsaVh0R25InB)acwkITrYyLGAPlaeavOzNaQNzG2OzNa6U6w8rg8oa41Pjt7ZoTeRZmbCQ(5i97kAq1JrTh8UAw1Ov79h8TvbFxte1rg8oay3gpP7NJ0VROzNuBC3H7DsTXDW3E1g8PBqdWk(zNaIVEG47cqAe1(ZOUI96qDP5jf0POj3onHv1Dd8Jp(mfrx5xbrGsJjZX3sz9P3l761F4RiMIdTQbH4tpsVEx31CYiPuCvXONvmYFStWV7vs4ehdprzmT3Z9gabpxLsH)epMD6t(y2PFNgZoTymRAMyJTcU4dA10zkG0kdln294AGO9zyrhyP6OeIAwvQ18SByYqhLXernQO8oVubFTTsLXwkGx9aXOa2gpCm1aKTn7ZtIJtUNDgLdaLXm8H9dFcu2WUpXrZYSlDx(50R8X(DYM8Y(TkHTh9Bwj17zZWoplipysqw4pS9JS7Cf0PEYZ7fFQslpHghN6N57uU3pM0(bzhBoovi5ttLf90ubIhNccIOcBoqLB9Xf6pXNoINKZyWbwPH8uhWUC8uaS8nM3Xeue2wpGGAF1bEAkstQYA)Gys9yvZ8FpOzPB7ofqR9MWRbGjwG5Wq1hPkMNaShvA(Oc8dsT2(eFqcomcKVha)WiTp01GRzWEOnW(9fn7PqI6GpCqgyPoUd7TZzAdcRis3dtmyh4rVJZ1KXteuRYPr1dLsfufYwKqBFpa3ETpz0aTkjyfNTqnawtxoIa3kyDFddCAFj2F0yCFjoooq(eb16bssnzFAn5NiWTx71lnqTQ7QTlhrGBfSUVbSonXy)rJXjgufs0Uz14OcCRGDhn1FSb3b0)4JjSPQ3KDBAYrf4wb7oAB7ydUJ5O1be2ouJdTyW6OcCRGD3m14inVBaVprGfkUnS)bxCqcUIiI8D(4ataVd09W4Xm)bergFqGT61DYbc4A1ZcscBN6fbTT3HxFmhY2(XFMX0iiXBdzXTMf5SB(e4(08O4WYBx1S(vNE6xD1PLvsWRXxk(RkMnx)mc)A2tl9v12U0CuHF8rPMjpDVB)O7eGpbbO9SkxtaMpEXB)4Fz74Febi8lzSha2IpmR(gP(1BhplcFHyb55Kh2oMVuc)LYMTyc0HInnQ8gENVTrWVJAD8SyW7VqQoYKEEAX382OC8hzS32XlWTAFvcQTI2oNXaEy(MuyK0dXym(e1w(ld6pSFBKM8Qd51jRVklmpAEHm1J)3JqyFfaYxdIOzrimfgVfl8eQdgKXdeuD99CCozPoFaGEUb6apaqTrG6VRcu)dPa94CEZAVaL4ev1gbArvI1WCJO06Xh7k3GuzqkAfQQXItwG22URUU912(c8B12cw4kAQoTkJMTIZ91Y5(uCUM6gw08hnNR)elOTDfo33kN7VtCE5ZvT60iFXPrEctI2NIlCNQTWDP0cnvnOePYqPC)0me7yrgAQUqjYVOcU1mXY5YnuPAdLlquxumiEoZpa6h6gU5TitTxlZlUq01OI)oTRZJjnvjyBaTVEqtvaIUa607Ln7u4SPCrhwTmrvvd6cOLFELkqa6ud7x77VG5g2VMMKhofD86Vw4WeGGLGlt5bP3XQ)WO8SW458xK)F83(NmV15V4iZcxhcJ5yNWgdwLhnnAn3L(0WSKnP4Jx0TymOGVwBh)ljPH1TaaG7e92XlzneC7TqBzr3fYQZrN8Ss9XPUHo6qrL0ZfDfq6vxkyz2iSyisNmcCzDkiSVgCC4DOB9febG6LWIVWI4HHFlu8NXh7Iv3UjgyCXFgF9lgX)VJWGaK0LYe7jk4GzCrt5Ur)6O5xjCLo2Fwi(y3KF95d0)rFlzvi(nkm03AWqD0b1lg0PmsAHBn6oDz2E064XM1p(OzxtGFB2dO9BdE38mgcuDoAZ6EImP8GTWdTzXWR8BfZvED628Df8AVHaPO)fa0aYeEoG0ISRVYVtxcW(4J6)9oep2Gxp0aHKIxQ6Igjyco8xbPvLNRP03t2vMpQsvs1VuFvvBIawRZgL6TrDHgtJlP6cw8YIlU0xE2JpQVJSxgTlpRNaXvEVuxaBHlQAkOk0Ls4rZyLkXswijIeGqBTs(lMln9DUKKFt9edXpQx9pRf36FYMP)OYFxZ394JnvLj4pAHhRh87T5ApeKeHc9Oyau7t0wtQ5SEWmRsLGM3GZvSwZBE5AXHAYGQ0QuBOtxf0JJpepyyDu66zO)uWIO)eSiny)pAkSi2AGEb2JN9OzHajVKL1jwf4JlrTD8e8b(J)ty2eckF9PWutGTNmFEDwkWUfKx89Gb6nCd0W)gFi1MXxPMJnCHqH1xH1C)aqo4QXia8gMjCwaa1bXfNa8blx1NE4Mj(nUuB7UGMD96FwC57Zew9w65Nyi75N4s)ootbx6nGMxlwVYrMLyfqg(AZLbTdCA1I2Ed64e(nYML8hsvLg3zYXZ7OZOM7Y2kN8BQ04e1uYUYMt06fHBsHkcsZiBLHbjMvr96aX7GPIFhNXFzW2XlsdNF1lwKNVo7ho907V)((3NC)cWXji2XLNMTgCe8kqR4ndoLrfNeTA(g8z36fx)R8CE(Zf)WLNgC92X3VikUfqEON)fENY5MtsMFcFZ7U(xfsY6pH)eh4rGLJnRFnyhHDqKIJ5)lxrM3qF)lE3PCHpInH8XE9FvipTFQ6354fZJlAQR2wy0C3rB74Xa8Os5kO3zokO6WzX16aJZF8V8xk3TaCwr0Q7s(cyg4RGU4QGyMRxLZqW1Xl1dqp(7sSQnPxb906VI50qAoqaZ(4RZph20GFbM1KhGRgXgcG)cJTf0W(5PpSD8NzEWvmM87LokI9f9uu0gYIK7Jl2JoiclqK8SzjfEEmAocsQLUzEVBswizoO7ZmybGfRdL)HptRJpqyos(LQS7siJ0KERmTu6qUwZ07smxfnqmi7Mr2RnzK9WXRg4R)qt(gNNOBCKASsKw465ChzBsiq4W)FevMDNp)URUSdK(rrvbO7K0SW4WSSr3d2EbJTa1uJ8I8qkKADX3dz0K9hwKKGoV8(P84p4HnGXDaolzpXxLI1m7DT4vHZEhRVG8rMPmaVQFemBty914kEWIKD1(STF1WQqdjFS2Rg9uStu97vjHbc4hFqL7i9ykF5vLHlin4jhSMuukmnbK9nQuRtTXfTgAeBfLTy5vNYfOwAremc6aUWNMndyx5lirVXF7FjGO6hexDgfW0odZ4EFYpwpD7VfjM2Fa568(HR0YtniQRQ3xivWOzjT6nQrtCznTzPcX6K1urvnNe2HkJmuzFPMO0L8P9LRu)EbCizQ0fClZ)TJUvxXW8qbH5MMAkPRqD8At)fzmrx2f8hQ(5fp245jPGh45uBqb(Dmf3YiGEptVE74FljNN0QkWYN1PtfUw3QkV3Ie51DpF4jf8SHCE)Y32tlY2rPqfeegyN(W0QjXWCwtk6UQauHgfDpk4UNG14Nlj0pV9Yc97GfDGsAtZ1fAqRI1bfCz99Rvde17B0Ec0gk27j8AV0wRcSXLm00FJZ8V8nduMX3z74)HWAV2nbW9F5iPYxb8DAAlj0ALmK(ROCo1ae0y(YHH9ka4Oz8Yb1pKG7VW)f6kDniRDVg9Vzbl7NanfXxHvJhTfo02Pl3wl4wc1yBxHYdrQ4f4UWj8CyXCh)6RoxSsGC5lEBVcdqhaS)22ICpPAXZSCuNVZKoYsiD8g0rFccfgzyvoubUynw)Y4xhiSsd8uE1Rx1g5Uij(HrLLPufbP(7cyD)ederGnh81g9aiDtwWm0ZikXLZjZ)AVHfsqTcxcUVqSO5toB)4BQqpvzCAk(ais8h4kp0Ma9OfZNxvxbuY5fbjzJMeWZQkTW)DcfTInU8YZifIN3RY4OA(mQk6pmYV1j4Vj5LLC5gOn6FrB3IqtZM4BweRVAb4Bt6B64(o1E5fD6QlJqc2(eQkNEKU3jKSJ)3Y7AB3g3gi63srbmKqtdKOJ7(IJ)eAb6(E8AhRKQAzldjBuSab73E5qkkXlZWloU7fuea)GTif5mdNRhorF7we)2fWGB7lVSMR(qZQnvYh8sfYYa)UwQocVTPTDxZf16uV4Sl)qHKMnpeASDYlOnY0E7TxU00W36s4ZTEyjKBAtirAqYvFjcXJfjjEqYXPRbf((DZ22d1hflY1n1h2MSkKqlAGhMMOSRaBjl5fpkRjLfs8VX0LgE)RdU7tCPAqT8M9WAOV686TThV0ZJTPQBE5A2PNJBK)e2qrlBhv(HiYNKpqbzo9lFCbX20sMIs4mf65ucsrHOLNZPAwYWEGbH10KGP3GVBbynWCj6hDZ01WU6dfHrtQu16df6yduotXnYsvEhimxqPdMMOm8(XvXERiC4lkSPDkCskdI6K8FRiPLbQC0Cct3wXkalmZZyaiDXnm4h2KqWkKWueLr4dfeKa3fhaX)I93QU2gtyRvVt65GZx)tsobj(kPWcLKPqIbnkrcyzqsYDVfY07O)c)Q7GD(QrQserVYIEHBmkItwiuwSZ3Ev(oC5iwMOuUrsInZMGkHjidHk)dH4hcfI0hocs3Fhr(p72xAvkT3rYo)oMp9)aMe)CkpOg(KUd)37BVabnT5KmHNgAixTyMmpUJ5r)0ZNxpFbpegB)6y4a1NcaDeW2QdWRUikPvmA2DOR1B02PHYL41QE(1H)ou68MN7QH8)YzzN4pGE8eoqzW7o4eNF8kGnDlt3wgPiSUjUxKh3jE9u(5J57cnR035eUeK3JrLLEovpE61EDoydG7Pd5Jm(ckcQey18cCp5lZDU7clOVMdo(iOsKvS1RrxiISii2NyKxchc)20KpKpGtjuSENIHPvA8m7J5LthiS1)mJ(eDmRpkHrY1kc8d(kVcUQIEfDTQXyn3SY3fswZtjKiW8YG1q11MZkxdfICnmT1v4Ajpf2RpBgzbTBM5aqS3Ed1k8YfU)GUMw4g0LL5Sv4EklQ)wUTMGY88yoUHicrZfuL6dzvq4zHk5n29DP8z(X)sgX5D7u78yjnV0B9CjrWDCAPsHS9nyNsUw0tcUEvjSMq0kkxXJ(jYXNkiTCnJD9SHV(u7OmYrR2EWG9FkwqCt1J3BWXPAa5SqwIGIAmg3drnOqhyvxFvhOYmXboikC6stFvIdTbuk2V(VVS71ddIrjmAGTa3b)M1aCltCWVu3vjOvjoUTBEfmtZLUEEFpvOLKUok(E3iZI6fLe0aOkEAWyahVr1(s)YCLpKFSgq0kCXDarvmVhnW8kIRCE9nQZfLklzfKrIt)w9RPh1PaFU1gy7DZChYE21urqp5xlvykd3qeE75K8Unh3)ONnlbSkFGawLPEhuIxikGkDCFICLSqCWkKxkjqSNwfJaCLE0jBFmSFMxPtLXknIU8Q8Sftv6jZxkpITwsJpL5BFk5Z0R34br3nrSvRf0OAAsGzbakaCQ(HHMXWN5M)GDlO)yhFJFGV22jPMqarh20TxOcF45CJDeBQnHBG8sp42MJMCJ0xosOmJWcXpTlCL4nrK7Pi5(8GGK3cvrVkDyN)Lp9p1acwfDhH)IF6PcUEt8pQhAsPIlJ(DWJb3)5TvQ)zmY9GaEsXDv90gzhovovo3047tHE330Ew1UGknuCCoyx1s1eSWZ6zCfWGOnLOUuvim7PET1yhQEvHrBCt77ZdXkjEl5ZWAbBU9moZgnNEx0BC7pMLDNjuzcM7D)qU3o7V9TTYmZ0xlFMHYNzE6EAFl5Zmc(m7)k(CzWEdOEFImf(mZMpt0IaD4Z)SSjY2ES5ZWNvYgwWLEDflqhSPE3qNUf2U3PEcqxtl0R3m7Zb3)Lp9hDYMDWXQA5VhE222k66agZZvkhAfGCkkCM4AeTrqijT0hgZn6UOAYrKbtrPGjOThUn6Ps1yx9VqdwhrSXa1T0O)mC6Fmkcct)z(oKKB0JttK(Z(HI(37INYmszEV0SziJJzpoez9N(ypFt80VZwu(0z(Fp9Vp]] )