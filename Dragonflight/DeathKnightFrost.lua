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
    antimagic_shell             = { 76070, 48707 , 1 }, -- Surrounds you in an Anti-Magic Shell for 5 sec, absorbing up to 7,472 magic damage and preventing application of harmful magical effects. Damage absorbed generates Runic Power.
    antimagic_zone              = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 32,490 damage.
    asphyxiate                  = { 76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation                = { 76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and grants up to 100 Runic Power based on the amount absorbed.
    blinding_sleet              = { 76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_draw                  = { 76079, 374598, 2 }, -- When you fall below 30% health you drain 1,210 health from nearby enemies. Can only occur every 3 min.
    blood_scent                 = { 76066, 374030, 1 }, -- Increases Leech by 3%.
    brittle                     = { 76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    cleaving_strikes            = { 76073, 316916, 1 }, -- Obliterate hits up to 2 additional enemy while you remain in Death and Decay.
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
    soul_reaper                 = { 76053, 343294, 1 }, -- Strike an enemy for 510 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 2,298 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
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
    frost_strike                = { 76115, 49143 , 1 }, -- Chill your weapon with icy power and quickly strike the enemy, dealing 1,227 Frost damage.
    frostscythe                 = { 76096, 207230, 1 }, -- A sweeping attack that strikes all enemies in front of you for 317 Frost damage. This attack benefits from Killing Machine. Critical strikes with Frostscythe deal 4 times normal damage. Deals reduced damage beyond 5 targets.
    frostwhelps_aid             = { 76106, 377226, 2 }, -- Pillar of Frost summons a Frostwhelp who breathes on all enemies within 40 yards in front of you for 573 Frost damage. Each unique enemy hit by Frostwhelp's Aid grants you 2% Mastery for 15 sec, up to 10%.
    frostwyrms_fury             = { 76095, 279302, 1 }, -- Summons a frostwyrm who breathes on all enemies within 40 yd in front of you, dealing 4,604 Frost damage and slowing movement speed by 50% for 10 sec.
    gathering_storm             = { 76109, 194912, 1 }, -- Each Rune spent during Remorseless Winter increases its damage by 10%, and extends its duration by 0.5 sec.
    glacial_advance             = { 76092, 194913, 1 }, -- Summon glacial spikes from the ground that advance forward, each dealing 722 Frost damage and applying Razorice to enemies near their eruption point.
    horn_of_winter              = { 76110, 57330 , 1 }, -- Blow the Horn of Winter, gaining 2 Runes and generating 25 Runic Power.
    howling_blast               = { 76114, 49184 , 1 }, -- Blast the target with a frigid wind, dealing 226 Frost damage to that foe, and reduced damage to all other enemies within 10 yards, infecting all targets with Frost Fever.  Frost Fever A disease that deals 2,584 Frost damage over 24 sec and has a chance to grant the Death Knight 5 Runic Power each time it deals damage.
    icebreaker                  = { 76033, 392950, 2 }, -- When empowered by Rime, Howling Blast deals 30% increased damage to your primary target.
    icecap                      = { 76034, 207126, 1 }, -- Your Frost Strike and Obliterate critical strikes reduce the remaining cooldown of Pillar of Frost by 2 sec.
    improved_frost_strike       = { 76103, 316803, 2 }, -- Increases Frost Strike damage by 10%.
    improved_obliterate         = { 76119, 317198, 1 }, -- Increases Obliterate damage by 10%.
    improved_rime               = { 76111, 316838, 1 }, -- Increases Howling Blast damage done by an additional 75%.
    inexorable_assault          = { 76037, 253593, 1 }, -- Gain Inexorable Assault every 8 sec, stacking up to 5 times. Obliterate consumes a stack to deal an additional 292 Frost damage.
    invigorating_freeze         = { 76108, 377092, 2 }, -- Frost Fever critical strikes increase the chance to grant Runic Power by an additional 5%.
    killing_machine             = { 76117, 51128 , 1 }, -- Your auto attack critical strikes have a chance to make your next Obliterate deal Frost damage and critically strike.
    murderous_efficiency        = { 76121, 207061, 1 }, -- Consuming the Killing Machine effect has a 50% chance to grant you 1 Rune.
    obliterate                  = { 76116, 49020 , 1 }, -- A brutal attack that deals 1,453 Physical damage.
    obliteration                = { 76091, 281238, 1 }, -- While Pillar of Frost is active, Frost Strike, Glacial Advance, and Howling Blast always grant Killing Machine and have a 30% chance to generate a Rune.
    piercing_chill              = { 76097, 377351, 1 }, -- Enemies suffer 10% increased damage from Chill Streak each time they are struck by it.
    pillar_of_frost             = { 76104, 51271 , 1 }, -- The power of frost increases your Strength by 25% for 12 sec. Each Rune spent while active increases your Strength by an additional 2%.
    rage_of_the_frozen_champion = { 76120, 377076, 1 }, -- Obliterate has a 15% increased chance to trigger Rime and Howling Blast generates 8 Runic Power while Rime is active.
    raise_dead                  = { 76072, 46585 , 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts 60 sec.
    rime                        = { 76113, 59057 , 1 }, -- Obliterate has a 45% chance to cause your next Howling Blast to consume no runes and deal 300% additional damage.
    runic_command               = { 76102, 376251, 2 }, -- Increases your maximum Runic Power by 5.
    shattering_blade            = { 76101, 207057, 1 }, -- When Frost Strike damages an enemy with 5 stacks of Razorice it will consume them to deal an additional 100% damage.
    unleashed_frenzy            = { 76118, 376905, 1 }, -- Damaging an enemy with a Runic Power ability increases your Strength by 2% for 10 sec, stacks up to 3 times.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bitter_chill     = 5435, -- (356470) Chains of Ice reduces the target's Haste by 8%. Frost Strike refreshes the duration of Chains of Ice.
    dark_simulacrum  = 3512, -- (77606) Places a dark ward on an enemy player that persists for 12 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    dead_of_winter   = 3743, -- (287250) After your Remorseless Winter deals damage 5 times to a target, they are stunned for 4 sec. Remorseless Winter's cooldown is increased by 25 sec.
    deathchill       = 701 , -- (204080) Your Remorseless Winter aznd Chains of Ice apply Deathchill, rooting the target in place for 4 sec. Remorseless Winter All targets within 8 yards are afflicted with Deathchill when Remorseless Winter is cast. Chains of Ice When you Chains of Ice a target already afflicted by your Chains of Ice they will be afflicted by Deathchill.
    delirium         = 702 , -- (233396) Howling Blast applies Delirium, reducing the cooldown recovery rate of movement enhancing abilities by 50% for 12 sec.
    necrotic_aura    = 5512, -- (199642) All enemies within 8 yards take 8% increased magical damage.
    rot_and_wither   = 5510, -- (202727) Your Death and Decay rots enemies each time it deals damage, absorbing healing equal to 100% of damage dealt.
    shroud_of_winter = 3439, -- (199719) Enemies within 8 yards of you become shrouded in winter, reducing the range of their spells and abilities by 30%.
    spellwarden      = 5424, -- (356332) Rune of Spellwarding is applied to you with 25% increased effect.
    strangulate      = 5429, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for 4 sec.
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


spec:RegisterPack( "Frost DK", 20230430, [[Hekili:S3ZAZTnos(Bj1wrrkXrwKYYEYu2UQS5MPUm3(yQjZu33SeLeLf3qjQJKkooLl9B)6gGpaardaQho7T3(LzCea6xOrJUB0a8oV7(97(08G8W7(B(d8ho4IHd6777pA4v39P8h3eE3N2em7Zb3d)X6GvW)9NttYY3n5)4)cB5X4KG5ieYs2ModADzE(MSF88ZVpkF52P9NLS68SOvBJdYJswplnyro(VND(DFA62O48pU(UP6r)L39PGT5ltsV7tFkA1haihnFEiV7HzZU7ty3F7GlE7Wb)4Uj7M87PrR)CiqyXj3hnB3KTBqOoF3KfPjR2nbHr)D)YUFHpSHV1)k2W(RrRts5nxoMm5(nI1V)G30UjDxfeTo(XDtYt2n5VpnokpmLXC9KhMhBy)C0x3n5pNggKVC3KKfiIwppn4(KSaPU7nugllqIYBq)b9VsOF(V1NZSVF(8ieNbX7Mem)FSnlFv468YXfh(LW4O13dTTE(54VKh8z2)wKE3n5byokzliY(PF7)wclEVRaliKrz4xcsJcMgh2Ftscc5XPBxJKz22zaFLVmaaYJjBbeMgUBY6e4Fw0talldxl2AqmioMdcqCqRca5ddy9rm(r4NIa4UD9S4WGuCWOKEj(BZwgo7ZyZRFf0R1HHZrklAnBYRqb7dOc2z7MmDBbGsd)F2gLY74BVh0F7F3NIJYYZy6Sa9fhoopi9(WC4h(BS1cHRroD(D)zqbCgc07(uA4QK0SW4WSSXpeTgKGCLW0On8o8jgKaLqgO2n53sYd4Ta9b6EuWDFQsgM(W4PBxSaOUNEsq0gmFE2yatG61D5WQbfAPgq4G7)5Oy2eXQGzlJwh2plpaLoxVBI)UjDyY0OzJ3K8qyA)5HlIMfLZBDaR5xiG48hsgVe0ugZKW1C9cCH(4S80OphIu0W2rrB3WWufAyGlB2J5ldhVjnkbg9JkiJ3kIRlAlUQHusPoodqJmdO0OvvuAEqmSiQF0SWPGg6NbbxAWAqMEdi1Qb)YKhyOEACqwoIHljXaQxZe6xqpLCla8rIOpryjA)cWk2(uMXKXjlgNvBkPe9cuz6ASpfARazEfjz(c9RVlPvgY7k0N0nI6VKkAJ4TppKlOd(gmJpRsrfeQsSDgydbPhUKDEynR3JwJ8hi5PAIfMG5KRHPW3DqYMxGmjoN851r3VmVpoTd2HVpSIPlfHeYIRzYcDclU5GmwxUF28(mZLVE3KHsIL7JdMffepoy(xcwpJjz8g0wwkmJAjKNQzX9vdVltw5GEmxymdiU5jpSwFxRen3k0tz1((Z3wUvxptln8OT1sYrdQbyq6SG1W2ijPPaJXaiTPslkuK665aqaMC8syBrJ7vnBjkwqgmc9htABQpaqy3K)tgieTeMKLXMGwG6VJ1Q0XN(QMV95trVa3QL22FxtB0W6bB01mw5kIBVHPsjT)ylg9Uj)amLZh)PH(yyy)jpVbm6RN5n6FH9nfyOydWDbP4uotPPK7miB9guY)AbaLzhO)E7M8g2FuqzSb8WJPRYgVyB6Jsex1Ys1ov4ayp5jPTRxMe)iQYhU((8LsSHABAPWEuRcm68IdszcZ7lcIHXnEw62myhRQndmnNujsie5Jd)6MWzmFUr1KrsttgNljfHvYxIHp0SGJ2tmheC0BnQt2zNjpQsxrB4nyBA)gDGNnrJwMmVqQtMNpxgKKnEAqH9SE2NQFNYgR2ftxZ81WYCZfg1GYf8Na7WHeNLC8RVhg2xc1hTvaRTXHRdxffY9sy4riSk3nxw25Iimm49zlJRAFjjA3OBzWw7lbiBra3QCE4SGh7NhndZoHr)zvxoQXtvBKDX6VxynK0zpoRkRazOYQXG8mHR9l2xJrQnpPyp3Xlc)c4uAHWtYYJPOJBO9rhdLJX1qHvyt(z5LwZE(I8rnwoTk9YCPPPqno9sei8HhOBd9tdrJxV5RImqogkvZG3W8GRNELCdbnkAkB)11mejPlSTgbVrkH1CJncKtNJUyNv3J4avHCH1ovZOgD71erlrGS05yAELEhKQfpEwbRM4OP9cZfH6Em1RAN3HPERKXPAULEFchD8Wt12V2DvBIAWJoEkzoiF5kpvetEXD0YzUM8b2uF8w2C1fG563wnFLgCFi6vdUZnOe8nmMLLbR2i51)R5jCyV8XtC3LoMsHMPmyPU(7529ilzz)O6EeTRygHN2P7lg5SxyMfPutBxmqiQmIicPgly9tRW2bp2A4CTwJVdRu5cH(Tcn9o2NHAPEEoqkxwlauWGoFU0kxoauQXwIz3vooO1U)l7NsHpXeRH8q7QfDJ2zKejxAkd2vw4hZ4mt25fx2O3aFh1ZD2Kf)93EHg7)7Lzq9Znwcs3(uJX8O1ExPPT4UF7Gy8umB)rGKJ6clc2gxR7u23vrGPJfPHHFlueJLtFLDd81ky99456R2n1PIeqoLfMxp0s9e8VI3gYBOPFvfr3fenFmeknSxp6nrFSGcks9AXjCO2JWVIfqaB)Ej99FnL1PDtY2eolAre6zqoVQuGEpnKzgEBg(ZyLxaU7TnpzfScy2UjWKlsyCoiRFHS7n3CEjVCgw8n3ub5Xfa(mghEdJNhZRphWp1nXbRxdOtNEx7Lwm3Mf8KLsEWonyI260SjXdWBetAwZdk(1PQSBNhAeVA325rhYlf9paaj4Q(YqTTkuTavnlXkchaTMLz25Kc8SDDCyq2Yq2sN1Ft(GwQtxSsNmKffHJDrzq15MzyvwLR42hb7IXOkQo8l0SlywO7Y4us(TPw6P6tMZspvpVejEsxZkw(7kicxXSrYol9XpegSb0NAhyQ7LoyvY3cYMYe5xu5oA8n0zjKWwQANA1TLSUqwrJfdlZLLuKVrR2KM8fqnRE3ycUFrA09OTIVgoBls1IRTu6ycE0ibBi7Xk2jAlVA)byl0Wm5vZ1Jal8SVGCkpy)mTR6P7eNRBiva)TQqKjx01mWHfhvSW8oL)pQ(Hxm7hTWOVXJQ8nwio02DgrGR4Y7f(ZjPyn5HBTfSbM3dy1jycY8azaUaeIL1h(FaZJ4MJlss5)ugwIGtJaveMaywc2EYIf1K0UIcoKn(6Ilf(7LjBXcCamMKYXgMsgSia5vNkwJHFaihKOra4nkJxaHmibcGX8vjJXkeeWxqCCFrXotXDCzAEqkNCD14W4m4VhwTmRltVOfs13WZ9dlOK6t4M9p7kKw63uQG86YFSEY9n8nwlB2BWaTHnjOLOJBk5(IacKzF7UjwCYTowmpf6sojdndj3LFEgKF(d0iavdfYUr2u56KY2ri3c1KRfclsN(z98NCTEPlCt78Ht1UvRMTRiEnQxsMCjfwe2Zo1YWQk2sxy3vXfTgGqW9qFbhSIJvms(hOTURd2nzzA4IBEvzPZ)Wdp0)HKhwggmNx)8BGHEdO8D5GZzO8TrRxSndaXRU9x5S9hl(HRpp4wSOPJIBbKh55FL35CX0Btw8wMycan7h4vToRM)5aNvE2BodSGc)XdW45)LRiZBKV)vV7C(SnITA9IxDR(cLNJxSm2rJ817ceTWD02oEe2B2DqV3CuDTYZvXrF7SBp9cUni60jiDMTbR(24GPzjPthdojnJfEkaKbgt84vdeTsfKb7Xgf3CHxPRHAxJRwro68Ofc7k9(WmXZwT2pmR2yEHbx37PBj43apjzYoQIjqojlYRv)RGnJ8a0zHI7)YpJh)oSm4JZEeR7FmkMcfN)OmGkSVyevQPO1Wr4Bl2BJgdDXAzxZcoB5Q20PgwwqJnoeTAUNM9(I2Z21g3Cm0veA2jnzRvJSPT0Qv20D6J0NO3Ek4CwW89MZPptJ2Y5TWcInTlATgZmd9XHqMiY)FN6V0bQJ5(L(WC2pHMZcLVRCnDbX0sU(zwTVbJ4svSBLYSTbNe3)G616r)Pe6tFYn2WfrUT6quac2ievx2KVAgltsWWbE)mEUm4PGaZHb4XunOXCsiMLc(TzSi6KYdBGHnkNCmcHs9DoiOkggJGiLzpKda69ZkZJwDbft4KcvEhDsLQklK0vG4nvvG4lCUChlWnzP8i1lnhFqzLAtDTBUH4onyEMR6YbHsE69tTAZZ2QcR2gusKMezwIy2PkJek9ELwj0JKhXoghHDUID2K0BJzJooGDODJkLQcFKwDFZhLkNZOMyqc)c3qVJGUT2Ce4YxzB25mVjnecgFAG2QuWHuAXnA2p3RFugSOF6JJHi8J3WZytHkKuFEyzee5pRcEJwpliDDqE44Ozfqx2w8yVXHFDw8258Dj3FQZ3bQZV1uNVi1rCU6YNEGGOyzq24Tz8d3SCbzHsUBNYLv)b6kj6RCgR(AD(sd55RUx3Ws4rVwSXrhhY0SevyMmRia1sg4NWPz(l(qWoHIfOegNb7jf9Li2lDW0h3nzJq(QyCj0HImRuMqBEUvoJNWSPcPFsiTucyO)UjFeAmkh)rMs3UjlXe6TgD9GTLe76zLgMVnfyfpeJXONkL)YG(J6RxZp7X1Zi1TlYUpm6kLDwH2quVc2oDIAnAow1OX6)mRX6))n0y1sMIASgNUAFPzqAbb5v5v8nB)5Ur(SFL7(nSQRCWS1TZJnz)Q4dkfwvbKU2FUBKqa5Bra5BTOoCDbVqHjlgYPMPS6GL1qUfnI8kDRvbtyEXZ5sDah7yHxIGQBsD)rSJyKu0w1tneeAKR8KjVTbvPDtOZL6GZuL6kcAQYtGQKTA4vPB7F3(vKk1ud4Itqm483sqtyZ2V9nWBWPjFv)IWvbR3geFhDLr4ck9Bbk9fqj15SBcNfbwcMU5EWLLNKUsB4m4jhiTtLi5uLBK970QXn9zVLb99xkXLYpuqmVVrV9143TKxoVp5NQtSXFH5sVLuLyoOWQ66RmSD9hOsnwAX1X4foCHE(IAg4QXKM0b3YBxRCu4gl0itfs0lSvU0vKSqXrRz)CNLmgLb75D2qjFJoEfzDeKY8TXlvHvncRjf6oYmNA8UtC43mi3UKeKauxHDxySlt36(IuaOZAjUfscSPZ9ZMJJRgf66SK43uMrSvMhccWUU7jpAyjv5UcDP8BMczMPWX645gWjnQhcMsbuH8gezzXj5I)BvrQMLv6C)rV7r8DUeKuMe7IUAa2ulkxhELfuEo(g6sp3fLKurfmm58PkTW9XQUgsu8TTAERAksRdH13PSBklFmPe6s7NfMinP09QSv5VZQjs(WlVMaSQtCjmOq8ibG)t0QGIxLry76ZWUHPcAAy5Tlyruk2twXiSjG)8hYbvJ6DPVUDdvu88vu88BLINVffp)9uXZ3UINMUCAv88Ov88mP45TxkE(gu8Ae2rtfpnUMCiwCSfZLJgDmcdIiVKKz61XkGrpDzzOHsshZAHUzFtWxDt5wY2(xQpzr1O3cSvt1iMLVe2dxBc6wbQtSnt0ydwD(rZlsfjY8Nv2d0(tcgsICf41F3K)EkVm8whgXB3o0MMWsiPiC0535HydYOkG7MHSLhaRlFnQoRrvuJ9QwQkQ3I33FvrJHayBHVvtL9CAsZ6w9ch2hQBbK3QSgQzfVeJLhtUHlg7Me()x5fySCK62ZSeULVHGs22B(4mcoQBmyzBN4yPMf1nxQJWTc5YszCl0sGHDvJ9kfQycLn5eU4I17SzytyBshH7NQgo0CAam7EqhhdJWnzC3M1W(vdKL(f3Ao(66R5xQIEMzVMkUo9u(5cdDm1RgT36vgvpC2YuBLHNS3fqB8FPEWHTCIE5INW57hmnzv0AglmooA1uZ2VDvZzFiBZ0KX0a5kz5Gc9XNY3N6DLVbNPK(znPHYllm3pvc56BkVN2Lm2SLGQk7XPm4ZMtL1PqalitkZjo9TMvWCHP7PB1IqDDs0FJwSysz9SLKY5Qw7XrIfnd0H2Ocy1mFD1afPJ1QH9IgoEQhtUdrpXhshYnM7jPFQtYtxZt0eQdwiAH9M9zMZmpzS2BT6jdDEoBnzADDXqbFY0rtm2H2RmvtsIVJh22QVdX2VIKN4dvGH3206IYZOAHR(GiSS00tRrxJVvjVPzR1j)ryDiEzWI3Mho(BHPjssN9f49CAIx5aqQFmWzt50EMAC7qBIwttGib3IxRKYfl6fs2CEtW513QhiA(zjrCN6Sw2cn4wYKgGupZtG7VBXh40yhLO(vEf(lwdAA4KJTJ9512ViVvtIvB4D4pn(L4)zSm47zvRHftrzhaLriAla3Zf1KYnET4um0CB9BTlwFWvp1BBMLpgVw4vXBQZ3wvRkM0yTOoYAM6MlysDu2NjxCLO1BVFXazYWKVuYk3wjhBBikOnKLSngM3WxUf2uSXJF3MIwhh4gOpBanI7XNiel753ylhPTVYcaAdpSCGs2a)iJ8n(beYueB6DXYUsMzBivRdSAQXZZUsPt2bfDr3qCrEcMI0iNhjP)BS4xiCmq6MF)445RNZtzB51sYqcBNgNKmNBCsoPT)gBS7M8(YNLghsER5mZsnOAAjmnlmLvftgZtPvavuahB2IfINXCaAfuX40z24)X253JFTbnNnmRqdxcJVXFXJXl8H5mmzfylIsdztFMZkKnl7wwfqSvSWSwW94GaT1zFoZCAESzR0IppDpwogO8KS5KBjnEg(v5B2kUVaQWyR8VRNd9V6Up9qqkgPywrDoeTAtsAEXhTYxjD1EE1oHpDJzS3aQIxlr8hMbUPDp7705FH9ssD5pUBYhswdyK18R0izbaIxMsDnvk0HU017R9SbvDBXOaDt7uQILR0Jf1ptakyG6RiGk098oXmXUFrZuz9LrSDZJ(NK5rcOQ4qQcGvALc2dpju8fNeOo6idvTt9CTMJY0Ek9d1PcDAONucJFqgNjBkyZm(lc3REbHxBDe8N(6H(4)u4jL(wHwFP3LLK5HdSZbGvr7VZcT7mufirNhJeL4n4FcifT6Hf(71ofrcBX79keTQAhmu1YVfVyWTJFjSiCsx4rGZQRjVcgAC95DeE1VlVkaS5d2Rkej23x9DYvbUupqVoc963c3g0R6tURkej0AvCLtbSezQ6FXHTMJ1tb(godrhxxZOl(To4vA8Pq(n21ryQ5TZvvnH(111rC08v3Tb5t9S86mgskFUE1jzsLEiFDeM0pWVkOW(lbSJyunRek4HkPfpVq3MlcD7AlLovhzXB869YIq)69YUDXfgVzyVx3vyJ43mQxVx7nyqjX2oOFEj0p3c0D3TdbcW0jlRJ18uqU)asEZcOBWxKGUVTW12BFfkalHh2hTOanJMdL6jchs8HPubS6EZkDfShBHYXoSRtlypnPsHcShBznX2(hB0qy7(zcnh6CX7Ewb7rwO4p45bnN68Mzgnh4CH)ZJ9Ek0COu)PjPA(eghKswPKVwjQpoDUcYJTCMankhiQcgioUuxb(EhqU)PXSL)PXS1jcSdjmtT3GvBsFQE6ZEvRs7tdJof3kgTVaAvuz9nWrFVK3nWekiFIY0JltDxEUKaPAF70AGlQE5okCNVS2DzLjsHP4tZIgHNsZMbkxl8OK9fcyFKnlslwQIqRSe60iB01Ntk4)3sN9r60i0Ec17oDnRI25foidbGyGgF5ljZQrzxUzqVNEYjezojc1O0ebbyRNLv9phILNFPIvHsL2uJy8RSxB00zJML09jsCWrX05ZtsjOfl2x9QVpNuW)VLo7J0H20P)j1gHgA87RPtneKwtNp)ILNFPIvHsL2uJemEm860mqzLGwz9Qraz1(CKb)bq4RWttsOqI0q31D54c8dGQH2YGzFi2tJuUC3o(i5a4GLOOXeTx2HJjGpa6flcutKBr7hrWsrSnYkF1orhG3rMbQ51G67Zrg8haHtTkuBxoUa)aOAtR(i72XhjhahOFLOMoCmb8bqVAxl2S9JiyPi2gz3TcQ7NZMNyW7aG3KMmRp7UDSjZeWP6NJ0VRObf6JBp4D1yLrBHho4BRAZ(MENtm4DaWUnFs3phPFxrZEP24UBS7LAJ7G3r1MMvvn1R8vhQ3TRNEIQLoDnhBf1A0EVURx)rVHyHa0QgeIpS596DBxZjcJA6vfJEwXOxbglf)pJYTZF2LBNFcKBvAKnomYkDD9VQ7Au4j7OKQFJZrSaaupF8Ami7gIul(TQZ7nq6vJVc(ABLk1xuaV65MxbSnEg6Rbi78kxKehN8a72UgaZQz43Ng8ZE8w2dvB13EF(fjR8RE30T5L9J95rErY21s9E(CSZZdYdMgKf(J7(f27Na6De5fsIRZ1Y7dWPP(gEEo)NVtPk9OiHoLjy)0u3Cpp132Zt5M8SElyos178Pf6NMAeHaQh17OaL98JSkdfA4pMwkaw(f26uckIQR7icQduf4KF9ClqZPSypOa(HkA(EqZsVowkGw7lNvdaFk366uvZ3eG9KsZNuGFukmsQIj)qL2ppBI)DgnhQqIy)8JZelXgVhSZcAd9Oi(Uwg5XZZ(cuvZOWx0GkOleaVqBFpahpXdLH01aInA2rGwLxIIBWLgaRPlNqGBfSUNTrNsQ5HJgJj1KQIb9nOD4tRD8mbopZkBnA2rGAvFqBxoHa3kyD)erCsz7WrJrLnhQXQwSs8KcCRGDpnFEQb3r0pUtjSPRCcRtw2xdECbUvWUN22o1G7uoBDeHn1bSVFtwNuGBfS7NPghP59d4uoaRekqlCcMWp9J0tJgb0poHyqCYbhhGtKS5de4AN8cscB3CgHP8do2ko0pnHfU7x(iJPrqIVqPINgfYz39jWNKfr4xizEtz9RU5DV5MZlpfYZWp(P3uSeP(Bb4zSptJ3uBqqZ1m7PNKAM8MHT7xCNa8jiaT3ZTAcW8vtB3V8N2n5Nqac)sg7J7wXaZQFLypB3K5r4x)nqEo9XDt42N5F1jzwOHouKd7YVeq8Syd)oQ1XdHL3FH4CZK(0ZHFp7IYXFKXE7MSepDX1jO2kAqAod4H5BtHzspeJX4NFUYFzq)r9BJ0KFYYNLS5g23M(czQ3z1FMZVba5zGiAEectH5BXdTMQOYnwm51fr(P5wj5CXJ)sd0bw84TrG6VVcu3QsFhfONM7Qq7fOevJFBeOfvesdZnIsRNEQRCdsf7JOvOQglQkvTT9L6A(uB7SQRuBl4z13rxvTuyZQvCUVwo3NIZ1uDCIM)O5C9v7Q22v4CFRCU)EX5LFpyvxg5lUmYtyr0jQqImv)ver0RuCpAMuCSKImvjwePUsb3AwkyQ4IAZeu5x4wDobOPwFAdO91dAQYiYfqN(G8kPc)NKlDOklFv1(JlGw(JRrbcW9Pz)AF)LOByfGbg8kWyjy0nm8BHI)mm9aUBUngC(G5jYVMY(6LaUjSjCw0Ii0JJcbb4mW0qwHhXR1i(ha7cpxJMHE3TM5btfWLj4kioUaGf0Si5OmI6Vfsf9v(nQ)gVoDB(PF5wVrp90l0)rAPhnYe(EbOfz3EJFNUeG9PN0)7Di(EWC7idesk(YSkQ1WwhH)A)TBQ2DoL(HcTsFQ6LfP6xQFRonraB0P0Q(CC2PlJUA8kDwWIxx8wT96Hp9K(oY(qPC9WEcex5dZzbSfEPoPGQqxkHhnJvAwtAjdH3omOR6UY2nGMLPbO)tHh9Gk)DnJJMnydL)QxwVFLeZi0JcrzZVDkp9KQ(9WEGcE5CrZx)YkIT5ZwPqtjLp7Kv)g97ezTCrnC1kDc1g60vHQVeac1JbTsxhI70a24(zWMlyXdnzfSbytqKWJVDEiWPRyXfZkls(xh2P4xRh(pHX7eu(nRadEcBpzXI64OWUfKxm(SiepOic(B87KcgVFog4gITnWqWWNYs2Modd4FYhaYbTSIaWBuMqbAc6fJ5QdJ5v0j(jEOpTkcBwBmIbu2H8HQdnT7fL013RsrVKgk4LK0lq9i2lq91(DCMcU2BanVweqGJmR2WhQFIjD(1R0boT)8q8ZAt(TEd64e(nYML8hsvLMMzYXl6uSwrmVGTq2w5wwtLgNOMs2v2eK2O4CtkurqAMzRmmiXSkQxhjEhmv8h4k(Rd2nzzA4IBE1Y88nz)45N)Wdp0)HKhwggmh8vE15GRnXX3aAfxo4Cgv82O1l2IFSoE1T)kpRmFS4hU(8GBbFNwgf3cipYZ)kVZ5CZBtw8wEo7V9xfsd0pJ)eh4rGLJTBodSJWQo84y(F5kY8g57F17oNl8rSjKXOB)Zczs6tv)ohVyMMqtD12cJw4oABhpgG1VURGEV5OGQkMNR1bgN)L)0Fs0f3O1Fj5ZGzGVc6IRdIzoovUcb3qVup4SOf30TT(u0RYBprTDZjkHHdTlVerK2H(cnitYBQG1WcJG7HLASuCI8KoZDxmq)G(g4QaogPVgEbR(2ySqatNogCAygG)Bh0rhuVAqPDoX3I2c3Biy4Alb6Cmd8xo9(WSR9TjxiM34Et8xblk5b4o1m1t4)HHXbR((4Sh3n53z(MwOV(hLUaJ9f9bwuoTm5H4IJyjlhftVyEsHdvJxGGKYTgwCjM0tKmv2LIBkCOUzdf8Ftpi7jPCOCOaih0KqRS3wgJH29U2NjJIgSQiyANNBnTZZXJxnWx)tn5BCrIU5rQ5krAHRGZ9UVjHar4)ViQm7pF(DxDzpi9tIQcq3jPzHXHzzJFam6cwzrZKTDlnbYTi7C2rIoW0i85Aal(TNe3J4dltsqpjFpdnL3kpmiqy)irSJH1jgONuckZS3ZYjEh6AX3Zh7DS(v7vqsu)JL7OOlddgMAaFB6Q9tN7nJQION8dMB18QILSQFVkZx9GT1sYY6i9LZ86BkJYtAMxogBPGlzt8i7BCzNoTex0RPrSvu2ID(n4gJfAremuRg2lBS2v(cs0V9K9rciQ(RFOoZwy(XH1MVp5NQxy(xIet(oGCTweu7rdx34Q18m2IAZ6DKtfmA2wU(0L0eWDt7UQqSo5DvuvZLPLQTns1gvA1QjkDzI8q5k1XlGdCSTc3Y8F7OB1D9mpvqyqQPMs6ACvq9olfPctxep(JuhEX3E28Kui8HCQ4VWXXuTldT99mn)Dt(TKCE2iRalFDj52En2Pu4SlL2JRb8ASKOguvhVHitFB3lg92czyk9rB86FONwKTNs1kiiOOm7XzvMnaReMw44QcvfAu0LPG7bcwJdxsOFr7Lf6d4No4rT5dvhAvS2WJaMWcuQRFqdFP3LoRSFGaTHg)bcV2pnOvZ24EtA6VrtmxF5aftlD2n5Vl4gGDBnCxPorRfQa(ETEMeATsgspkk)Knabn21CyAVcaoUFr5K6hsWtO6)e9QVgK1E6JUATKL)CGMI4BLRX56cFR70LBeg8)HAUTRqXZivndCVjf(CHWIm42BUqS2zCze)qVclthbS)dTf5Es1BMz5O2avPSPsiD8g0rFkMfMzEDxV3uMuzwJ1FrMRZAGsdW4dM)yVEvhKV6xi9oA)DbSEyIbIGbxaU9JUgKUnlyo6cgL4Y5Jdc2yQqcQv4sW9fIfndz4HX3urbRY40u8rqK4pWvEOnXCslMVOQUsOKZldsYgpnGNcAAH)7E6jN5YRhskeVOxLXr1uRuvMCyqOBsWFtY9l5YnrBIieTDlcnnhxHzrS(cpHFq7x2X9Z6)6R60vNl(c2(eQkREK(9PpVlYktMzxSottwSymy(qyxBlPEXqUsjKqIhU)1xnGlXg(0tONAxdwWpacU9zM0(C5Ownxso9qFKJ653GPjRIwZiYXXrRM26172iAyfyl17AQD553AIx7utBie3Xy71goC6a81joMzdn4ZinemR5jhsfJfrwHmvZwYG)6Bgrqwk6auktTH)RteQMvpfldOkopJhsCHYv704OzWdwHtOe9yVVssgWU9QbcSJwBLLh(Zfdel8soKCBKELr7tylUxRN1lWVEtIhlbNEIshyRJvJA3grr(LdAfzOvpAiX(IkoI3Cjmwb06nKRp4bXib8PZzV2ZuGUiviRkA9vN9Bu)1YBrqDHll(Yq1OiQndKEeI49ucZms2grmArXXQbh1KAYB22QSA)932CWn(PkPIdHg67mHlnkIvwAKSAnY3ozBhQG2ltZGMHqf1UnbTjvEsP5)BZCTTJAdde9JPsOnQRw14T8gLpHwPUVdLlPukzjrKWd9L(TVEsItCSNJVaPxes8aeBhpZ4zgpxok6YDCz5ztFIrr6KLmwPxRYjDp))xvCnxEeIQNBIbo6i1Y5ZAJQwFunl3vV(55sFunDeqWwiBarYR4kocZK91(GbRoNILTtL)j(QwmMDkG6xTz3LJum4KmQs5dO7MOvMTDUdkLCHdufMBOH3qxgqjyt3CDEFZYJChKZehMb660HuUX5HN0uhNL9DMT17egp1stSADG54UmWYgGkkaHgSBDU)7rzCaZDmgoFaOnpF02amaZ6AYfTpGv4RnwZMHPL)Z7AjHRct2HVRfAgsag(gCtPki4u)XruNSKE4tkbwbP(ZeHF2KFtrSlIub2UAGfUfYtKM)HU(m94P6sALHpIZbHklfdjOUuLRBGzy1vJnXfLKzURrGha62nV48NsX7tNPIAA4Ro3dwuj4AARdD6zE)dO3W3f94iQhwxJjKnLCzlsdD8rZXMq2WFFQDqwQWAW7mA)1MxiP56(w3RFQ6Qcsksa5ff77VQcii(SdmtAz)cPxnYb2jkuEnVklYHMtkDRw)ZR7p8ANyueJMyluJFNVMkDUih83pEjRHwf542U5azXwkDT7uf62Gq)(A(D7ltf0cfvUvrzFY7126BjzxxX(zLFKVCKQorQ)qirvopihv)Iqxih0hhyfAzoTr5Mht1dSq8b4DY9SQtMFqMZUMcb8KJhUBBSdXSKUm2jjL4YMZN0vRApFSLN2hbLNwS93q48wpkWz8aILHZ4LMppJIGyp8w0xOG4rhT1qVETE)EM6wAK91lZXwmwPNhCfDIqZoq)tnE1hcNi(9n8AoAseB1q5efUYqgbOKXkP6VAKv22Ak3glxg8S7gI5WcHpIUz(cAwjqSCcKfTq0HMbnymy3oxbklnygWpKI4zuFMi)6yh4c20I2pspg1vWBZuy5I0Oo9KnDPy5MwKjSDQS6)2NIHExLxuRAFL0rNURnqljoCuQfoEWTS4Sb0)PhBvxsXVJ93t8r3bRsYmoutQdCP0wSXWKUouv1Zq7dSS1eQmQj9oUl(v1UrCPLJdg7TYueSmfbKPicNPiamfXFkMskdtjfWuSHiwxmfHjtbabxwmL31cRIfNZ)f9DwBdYFTs)ilb0kh33H9J029r1tqNIliOIACF1)0V)2xU02C9NZo2()(NTTfnD5(O55gfAmUnyuhLHJId6Zgsedsenzea8PjybVkbu9qF0GntfLp9)6flxifwtCeBbpXoOJOWrXH1Boi2P2eBrSeBX)ne7k7s1clx6sLrIdsSl9)jREHadTvFwmpDvT8ZQ3(d]] )