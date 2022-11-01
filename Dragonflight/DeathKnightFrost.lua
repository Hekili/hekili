-- DeathKnightFrost.lua
-- October 2022

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local roundUp = ns.roundUp
local FindUnitBuffByID = ns.FindUnitBuffByID
local PTR = ns.PTR

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
spec:RegisterResource( Enum.PowerType.RunicPower )

-- Talents
spec:RegisterTalents( {
    abomination_limb            = { 76049, 383269, 1 }, -- Sprout an additional limb, dealing 4,766 Shadow damage over 12 sec to all nearby enemies. Deals reduced damage beyond 5 targets. Every 1 sec, an enemy is pulled to your location if they are further than 8 yds from you. The same enemy can only be pulled once every 4 sec. Gain Rime instantly, and again every 6 sec.
    absolute_zero               = { 76094, 377047, 1 }, -- Frostwyrm's Fury has 50% reduced cooldown and Freezes all enemies hit for 3 sec.
    acclimation                 = { 76047, 373926, 1 }, -- Icebound Fortitude's cooldown is reduced by 60 sec.
    antimagic_barrier           = { 76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by 20 sec and increases its duration and amount absorbed by 40%.
    antimagic_shell             = { 76070, 48707 , 1 }, -- Surrounds you in an Anti-Magic Shell for 5 sec, absorbing up to 10,902 magic damage and preventing application of harmful magical effects. Damage absorbed generates Runic Power.
    antimagic_zone              = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 47,400 damage.
    asphyxiate                  = { 76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation                = { 76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and grants up to 100 Runic Power based on the amount absorbed.
    avalanche                   = { 76105, 207142, 1 }, -- Casting Howling Blast with Rime active causes jagged icicles to fall on enemies nearby your target, applying Razorice and dealing 413 Frost damage.
    biting_cold                 = { 76036, 377056, 1 }, -- Remorseless Winter damage is increased by 35%. The first time Remorseless Winter deals damage to 3 different enemies, you gain Rime.
    blinding_sleet              = { 76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_draw                  = { 76079, 374598, 2 }, -- When you fall below 30% health you drain 1,549 health from nearby enemies. Can only occur every 3 min.
    blood_scent                 = { 76066, 374030, 1 }, -- Increases Leech by 3%.
    bonegrinder                 = { 76122, 377098, 2 }, -- Consuming Killing Machine grants 1% critical strike chance for 10 sec, stacking up to 5 times. At 5 stacks your next Killing Machine consumes the stacks and grants you 10% increased Frost damage for 10 sec.
    breath_of_sindragosa        = { 76093, 152279, 1 }, -- Continuously deal 1,094 Frost damage every 1 sec to enemies in a cone in front of you, until your Runic Power is exhausted. Deals reduced damage to secondary targets. Generates 2 Runes at the start and end.
    brittle                     = { 76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    chains_of_ice               = { 76081, 45524 , 1 }, -- Shackles the target with frozen chains, reducing movement speed by 70% for 8 sec.
    chill_streak                = { 76098, 305392, 1 }, -- Deals 1,564 Frost damage to the target and reduces their movement speed by 70% for 4 sec. Chill Streak bounces up to 9 times between closest targets within 6 yards.
    cleaving_strikes            = { 76073, 316916, 1 }, -- Obliterate hits up to 1 additional enemy while you remain in Death and Decay.
    clenching_grasp             = { 76062, 389679, 1 }, -- Death Grip slows enemy movement speed by 50% for 6 sec.
    cold_heart                  = { 76035, 281208, 1 }, -- Every 2 sec, gain a stack of Cold Heart, causing your next Chains of Ice to deal 206 Frost damage. Stacks up to 20 times.
    coldblooded_rage            = { 76123, 377083, 2 }, -- Frost Strike has a 10% chance on critical strikes to grant Killing Machine.
    coldthirst                  = { 76045, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants 10 Runic Power and reduces its cooldown by 3 sec.
    control_undead              = { 76059, 111673, 1 }, -- Dominates the target undead creature up to level 61, forcing it to do your bidding for 5 min.
    death_pact                  = { 76077, 48743 , 1 }, -- Create a death pact that heals you for 50% of your maximum health, but absorbs incoming healing equal to 30% of your max health for 15 sec.
    death_strike                = { 76071, 49998 , 1 }, -- Focuses dark power into a strike with both weapons, that deals a total of 757 Physical damage and heals you for 40.00% of all damage taken in the last 5 sec, minimum 11.2% of maximum health.
    deaths_echo                 = { 76056, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have 1 additional charge.
    deaths_reach                = { 76057, 276079, 1 }, -- Increases the range of Death Grip by 10 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    empower_rune_weapon         = { 76050, 47568 , 1 }, -- Empower your rune weapon, gaining 15% Haste and generating 1 Rune and 5 Runic Power instantly and every 5 sec for 20 sec. If you already know Empower Rune Weapon, instead gain 1 additional charge of Empower Rune Weapon.
    empower_rune_weapon_2       = { 76099, 47568 , 1 }, -- Empower your rune weapon, gaining 15% Haste and generating 1 Rune and 5 Runic Power instantly and every 5 sec for 20 sec. If you already know Empower Rune Weapon, instead gain 1 additional charge of Empower Rune Weapon.
    enduring_chill              = { 76097, 377376, 1 }, -- Chill Streak's bounce range is increased by 2 yds and each time Chill Streak bounces it has a 20% chance to increase the maximum number of bounces by 1.
    enduring_strength           = { 76100, 377190, 2 }, -- When Pillar of Frost expires, your Strength is increased by 10% for 6 sec. This effect lasts 2 sec longer for each Obliterate and Frostscythe critical strike during Pillar of Frost.
    enfeeble                    = { 76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by 30% and the damage they deal to you by 15% for 6 sec.
    everfrost                   = { 76107, 376938, 1 }, -- Remorseless Winter deals 6% increased damage to enemies it hits, stacking up to 10 times.
    frigid_executioner          = { 76120, 377073, 1 }, -- Obliterate deals 15% increased damage and has a 15% chance to refund 2 runes.
    frost_strike                = { 76115, 49143 , 1 }, -- Chill your weapon with icy power and quickly strike the enemy, dealing 1,137 Frost damage.
    frostreaper                 = { 76089, 317214, 1 }, -- Killing Machine also causes your next Obliterate to deal Frost damage.
    frostscythe                 = { 76096, 207230, 1 }, -- A sweeping attack that strikes all enemies in front of you for 316 Frost damage. This attack benefits from Killing Machine. Critical strikes with Frostscythe deal 4 times normal damage. Deals reduced damage beyond 5 targets.
    frostwhelps_aid             = { 76106, 377226, 2 }, -- Pillar of Frost summons a Frostwhelp who breathes on all enemies within 40 yards in front of you for 386 Frost damage. Each unique enemy hit by Frostwhelp's Aid grants you 2% Mastery for 15 sec, up to 10%.
    frostwyrms_fury             = { 76095, 279302, 1 }, -- Summons a frostwyrm who breathes on all enemies within 40 yd in front of you, dealing 6,198 Frost damage and slowing movement speed by 50% for 10 sec.
    gathering_storm             = { 76109, 194912, 1 }, -- Each Rune spent during Remorseless Winter increases its damage by 10%, and extends its duration by 0.5 sec.
    glacial_advance             = { 76092, 194913, 1 }, -- Summon glacial spikes from the ground that advance forward, each dealing 810 Frost damage and applying Razorice to enemies near their eruption point.
    gloom_ward                  = { 76052, 391571, 1 }, -- Absorbs are 15% more effective on you.
    grip_of_the_dead            = { 76057, 273952, 1 }, -- Death and Decay reduces the movement speed of enemies within its area by 90%, decaying by 10% every sec.
    horn_of_winter              = { 76110, 57330 , 1 }, -- Blow the Horn of Winter, gaining 2 Runes and generating 25 Runic Power.
    howling_blast               = { 76114, 49184 , 1 }, -- Blast the target with a frigid wind, dealing 305 Frost damage to that foe, and reduced damage to all other enemies within 10 yards, infecting all targets with Frost Fever.  Frost Fever A disease that deals 3,085 Frost damage over 24 sec and has a chance to grant the Death Knight 5 Runic Power each time it deals damage.
    icebound_fortitude          = { 76084, 48792 , 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 30% for 8 sec.
    icebreaker                  = { 76033, 392950, 2 }, -- When empowered by Rime, Howling Blast deals 30% increased damage to your primary target.
    icecap                      = { 76034, 207126, 1 }, -- Your Frost Strike and Obliterate critical strikes reduce the remaining cooldown of Pillar of Frost by 2 sec.
    icy_talons                  = { 76051, 194878, 2 }, -- Your Runic Power spending abilities increase your melee attack speed by 3% for 6 sec, stacking up to 3 times.
    improved_death_strike       = { 76067, 374277, 1 }, -- Death Strike's cost is reduced by 10, and its healing is increased by 60%.
    improved_frost_strike       = { 76103, 316803, 2 }, -- Increases Frost Strike damage by 10%.
    improved_obliterate         = { 76119, 317198, 1 }, -- Increases Obliterate damage by 10%.
    improved_rime               = { 76111, 316838, 1 }, -- Increases Howling Blast damage done by an additional 75%.
    inexorable_assault          = { 76037, 253593, 1 }, -- Gain Inexorable Assault every 8 sec, stacking up to 5 times. Obliterate consumes a stack to deal an additional 393 Frost damage.
    insidious_chill             = { 76088, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by 5% for 30 sec, stacking up to 4 times.
    invigorating_freeze         = { 76108, 377092, 2 }, -- Frost Fever critical strikes increase the chance to grant Runic Power by an additional 5%.
    killing_machine             = { 76117, 51128 , 1 }, -- Your auto attack critical strikes have a chance to make your next Obliterate deal Frost damage and critically strike.
    march_of_darkness           = { 76069, 391546, 1 }, -- Death's Advance grants an additional 25% movement speed over the first 3 sec.
    merciless_strikes           = { 76085, 373923, 1 }, -- Increases Critical Strike chance by 2%.
    might_of_thassarian         = { 76076, 374111, 1 }, -- Increases Strength by 2%.
    might_of_the_frozen_wastes  = { 76090, 81333 , 1 }, -- Wielding a two-handed weapon increases Obliterate damage by 30%, and your auto attack critical strikes always grant Killing Machine.
    mind_freeze                 = { 76082, 47528 , 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    murderous_efficiency        = { 76121, 207061, 1 }, -- Consuming the Killing Machine effect has a 50% chance to grant you 1 Rune.
    obliterate                  = { 76116, 49020 , 1 }, -- A brutal attack that deals 1,244 Physical damage.
    obliteration                = { 76091, 281238, 1 }, -- While Pillar of Frost is active, Frost Strike and Howling Blast always grant Killing Machine and have a 30% chance to generate a Rune.
    permafrost                  = { 76083, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to 40% of the damage dealt.
    piercing_chill              = { 76097, 377351, 1 }, -- Enemies suffer 10% increased damage from Chill Streak each time they are struck by it.
    pillar_of_frost             = { 76104, 51271 , 1 }, -- The power of frost increases your Strength by 25% for 12 sec. Each Rune spent while active increases your Strength by an additional 2%.
    proliferating_chill         = { 76086, 373930, 1 }, -- Chains of Ice affects 1 additional nearby enemy.
    rage_of_the_frozen_champion = { 76120, 377076, 1 }, -- Obliterate has a 15% increased chance to trigger Rime and Howling Blast generates 8 Runic Power while Rime is active.
    raise_dead                  = { 76072, 46585 , 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts 1 min.
    remorseless_winter          = { 76112, 196770, 1 }, -- Drain the warmth of life from all nearby enemies within 8 yards, dealing 1,489 Frost damage over 8 sec and reducing their movement speed by 20%.
    rime                        = { 76113, 59057 , 1 }, -- Obliterate has a 60% chance to cause your next Howling Blast to consume no runes and deal 300% additional damage.
    rune_mastery                = { 76080, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by 3% for 8 sec.
    runic_attenuation           = { 76087, 207104, 1 }, -- Auto attacks have a chance to generate 5 Runic Power.
    runic_command               = { 76102, 376251, 2 }, -- Increases your maximum Runic Power by 5.
    sacrificial_pact            = { 76074, 327574, 1 }, -- Sacrifice your ghoul to deal 968 Shadow damage to all nearby enemies and heal for 25% of your maximum health. Deals reduced damage beyond 8 targets.
    shattering_blade            = { 76101, 207057, 1 }, -- When Frost Strike damages an enemy with 5 stacks of Razorice it will consume them to deal an additional 100% damage.
    soul_reaper                 = { 76053, 343294, 1 }, -- Strike an enemy for 625 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 2,869 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    suppression                 = { 76075, 374049, 1 }, -- Increases Avoidance by 3%.
    unholy_bond                 = { 76055, 374261, 2 }, -- Increases the effectiveness of your Runeforge effects by 10%.
    unholy_endurance            = { 76063, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground               = { 76058, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    unleashed_frenzy            = { 76118, 376905, 1 }, -- Damaging an enemy with a Runic Power ability increases your Strength by 2% for 6 sec, stacks up to 3 times.
    veteran_of_the_third_war    = { 76068, 48263 , 2 }, -- Stamina increased by 10%.
    will_of_the_necropolis      = { 76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk                 = { 76078, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.
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
        max_stack = 1
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
        duration = 6,
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

        spend = 16,
        readySpend = function () return settings.bos_rp end,
        spendType = "runic_power",

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
        charges = function ()
            if not talent.deaths_echo.enabled then return end
            return 2
        end,
        cooldown = 30,
        recharge = function ()
            if not talent.deaths_echo.enabled then return end
            return 30
        end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,

        handler = function ()
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
        charges = function ()
            if not talent.deaths_echo.enabled then return end
            return 2
        end,
        cooldown = 25,
        recharge = function ()
            if not talent.deaths_echo.enabled then return end
            return 25
        end,
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
        charges = function ()
            if not talent.deaths_echo.enabled then return end
            return 2
        end,
        cooldown = 45,
        recharge = function ()
            if not talent.deaths_echo.enabled then return end
            return 45
        end,
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

        spend = 25,
        spendType = "runic_power",

        talent = "frost_strike",
        startsCombat = true,

        cycle = function ()
            if death_knight.runeforge.razorice then return "razorice" end
        end,

        handler = function ()
            applyDebuff( "target", "razorice", 20, 2 )
            if talent.obliteration.enabled and buff.pillar_of_frost.up then applyBuff( "killing_machine" ) end
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
            applyDebuff( "target", "frost_breath" )

            if legendary.absolute_zero.enabled then applyDebuff( "target", "absolute_zero" ) end
        end,

        auras = {
            -- Legendary.
            absolute_zero = {
                id = 334693,
                duration = 3,
                max_stack = 1,
            }
        }
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
            applyDebuff( "target", "razorice", nil, 1 )
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

            if talent.obliteration.enabled and buff.pillar_of_frost.up then applyBuff( "killing_machine" ) end
            if pvptalent.delirium.enabled then applyDebuff( "target", "delirium" ) end

            if legendary.rage_of_the_frozen_champion.enabled and buff.rime.up then
                gain( 8, "runic_power" )
            end

            removeBuff( "rime" )
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

        talent = "remorseless_winter",
        startsCombat = true,

        handler = function ()
            applyBuff( "remorseless_winter" )
            if set_bonus.tier28_2pc > 0 then applyBuff( "arctic_assault" ) end

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
    name = "Runic Power for |T1029007:0|t Breath of Sindragosa",
    desc = "The addon will recommend |T1029007:0|t Breath of Sindragosa only if you have this much Runic Power (or more).",
    icon = 1029007,
    iconCoords = { 0.1, 0.9, 0.1, 0.9 },
    type = "range",
    min = 16,
    max = 100,
    step = 1,
    width = 1.5
} )


spec:RegisterPack( "Frost DK", 20221101, [[Hekili:T3ZAVnUrs(BXiiAKMXXJEy5zsGLbsYU52K7qsqCwSFZuus0wChkrfsk74ad9B)Q(fz)Q6UPm9mBweSazht2S6QRQ66vxDPBgDZVEZ1RIRsU5hhpC84rJgo6SrJhF(53CD1J7sU56DXl)q8DW)yB8g4)(Df5LvhM)3(FjV5XS84veauMVVyj821vv7k)Q3(27sRwVFXzlZ382Y0n7ZIRsZ3USi(2kYFV8T3C9I9PzvF)2BwyD2N8L3CD8(Q15f3C91PB(waYPRwLWgEs5YBU(MRZslRkjtE(IS0QKc6CeTlpplD7DWZ)r6slzB8ISKv38naaxsgXnxxKSjVOmjlPSm6H0TWNYaAr6o2a(zgmom)7Ylom)NKa)xDy(1vXfvLhMpA4H5LjlZ3Uc(Jfj3MxKCy(pNMLfdFt(TWhZOuaniPK8e4rF7F7MRHPbGwA8nxFFm8)bi3zfpeTy)T3cJ6PNomNGM3NeLSnztk5lVA2H5JVPcOqARNgivUljllcqS7sQkp7US4LPXzrXRUpE7YeoeomV3H5vXzjBRo7wcQvU8XQ1jNjayn5r7ZjZ8e0zMG3N9byvd0ROnXlxNUfwpjaSOZNXArGiNCyE9YFvsC16YOv7tIyJVbxKqucECochTwcijmCdg1JlZseumIOca9PORs9Lbqphrxg1RbkIgvwvK(HKiIqX(uaUQRd(Rjt1fOtvJqrE1TlJks3irowN)aDXSilUSIaN398fjk2VnDjST5HKcGtCB6YuG1D5H5xm0PiX7ryfkRuj8bBAE3q7mJVSvSAa68f1e6IQpvcBtC62O1XBxD241S9wlZVhGjSdyBYYI8S8IvAp)dpcWB7H5dypVbUNtHRmeTJ3JggSuudypQDdeP48SvrRtafsU03TCnG1Lr53gLs0rROQ7BbiCy()Gacq9ei3MsEEPmAFB6DRRIaLMeOq5z3TC1zBI)DbLMrKUKkqriAWQX6wV97q5n94FsZc6SYkWWtnr6nSPb0YExYzFipRkTiUm6247ZleAWytEWW9W83hiy5YcD4Ak85ULljIrPGGlSMgyZMsiYm)ZsGDVAFb1ePWI3dGf)dZ)(LjlJ392VPGielleDsTThzR1n4JyvTJcoY8sf2f0xhchKLmJdyfawLBFnD8JO0QLGX(v5pSLPc)Hhl2aeR9fpsSuS6rvU)(TRZZEKODlz7DvRvWo93zDIRHeqFZlJwe3icP)yRF)aBwJdHN9t7RktxLW8mrWZ2xMaE21f8oQsROpSLOQ4SgPVBJZGVlAzX(Y4vjfcDDU401SdugjrmFQcppibdB8om2Hmphb4t4mdDxsAfz7Kwr58Vw7cA74HysuwCrkerVFUibmUsnVizRbm4waIB7Okrekty4LmrmakORvShjKZFjLq(sHRf(i6xk8AXdQoGz0xMw8ScZroWgWMrEvmNz60JLjQo(kIDXDak(Djq3jcoJpD5JGdwzGljM2kKEhMw(XcEa1HCGdNLexUozfWcs2(hpQaZgXaTb5b42)ioVJXBPwBrdgatFUQ3(HtnT4mmD4KyjWK6OVtiWtulLZJsm6wy3BXzvPl)aDl6a7U96unOlKnS4ucZTYvjS1s8FKxa6HK4btzGqFayC2Zv4xwI(bpurROytaXQlxjh6F2XgRhsz3gBmEGMDESX6rw6m2ylevLTnI0NGhcTEGMTleANsjgXc6li5gxgIVpodatt(zuS2zBlGKst0p2kbK8HyuwIQeyV)gqCipAmBnZ3OGe(RU1OJnZgJWImrrE2eda53fGHAU(kx2hDci7zUauumJQP58P0yh40B2iIRQs2UxZfLxt19mqZYlZhBMZ4xNUDvr8D5LXhM)109shM)lcBXonQ2M8hwNodPLcyaySvU8LAJ8TWw6lC6yHZCe2nZkZrzik4OvqCkp62OdM8CFT5GMDHPn56PgFMWy1kbU14DoWVsioYbQEjoZ9hep1xhVzNcRN8j(1mj5dHn7Zd6sgNXMSwAgZQj7)BWgMXw8lgAsFNqxE1A)AiQfBjYcn7eWnG9Yr5AD6sntglbdSTv4Cz3Jq06JN0ZwQ1h38H(wGPsXPgdHsULGSfGZ3vmRafuZXLUSaSilpFfnzpA6N)f63c6JxKcKpqlQHyNz8MU1vJ9rn4scOsTGAZYPY0(EJ5fr))avVOXdyMY8BKkMrTG1d5GcUIVzzGbZy3(SsRhAtlikzKSIug9V3V6UnmgRpvwUYFyYgkYhrwGrpKeVd0wlpBe32aFYaF4wgNLztFKNjRr39mAgE75MwhesDBArcvo1TgS2iqu7HEi5mLX75o6iLBcfZCN4CeyKbDtDsBgIVJAEfcs7dL3WpQd2j04CdDJ(sJJ5G91iBP7lVeSNRjj3RrtgfYoVEHKeiBEUXyude8QAvPqSd7ah83sdixX994vRk5hvdsc(9Bey0Kar56mi0q7wqDSLm2YA3Avir2wdn8VYhIl2qTMNYShGRh8yMtjQJJ5exFvOtOyFL1b2OO1o)evtl4P6qxSBhF4fE)W40vr000sFLcp(lToIKFNu(fgMvCTKRLOSoO6PCGdEdU2)Gex1YEhI8OG)ek7wnIcGApTnlxLZnnOPu2w7ICG(WQ8LS0nlCB0Y9gbBWc3GJlcxq8IjA55LC4twxJLRJx(bIlNqWw73(qEr16hD7MTNn8iWdprq(9zQmFF2cGvD2U9Lv7bGNuSFNPbK6HDFoPKOGXvMNr3tjlpjMo9bfTE)M4T5PRyNaXnxtJ4GmrrP3sRbl7axzGB2KSkLgoWijNmGy5xtlpl5XExw(I4mYa5wGzCvRwG96jIrjwXf64yWo2FBXGLyewCuYWiVabn1zJAZU(ChU4OnZ2kX(PgJUH4RCoCSbgOG1jbns5dTYMSm)9Mf8X4HUnghKAlzITref0N2NzP6l4jZ36bJU(Xs6KwNAnX4LZoZMDGVEG7JXBlVnbcjCzIrg5K4BUnCHrru0rzt4mexjuv75fE4M)cLd0jY3UnOvlI5YxaDBMIKW5BoOLKbInxj(HM0TBZIiMG65kyzNtfUvtFAJSLFYjtvWfDZ0Qhtn6BBzYlp(Go08E6oGlMqoD)OYQ8InMrfAMnz5ZH0huCZZXDrie)vnKXCxPrcS2VzaEfSihWRf0WTpjOb17nuB5Q3ZLBn(IiMrkobp0aQyN27iIiWYFYqhwBMCJAwoBQjlp5Aep(BF8mSLqp0vGFU8Bom)D6wzcIV0seYkm0l3anAiU7BbWY9i0qWg1QU1J)ZQFqVqOT1u1wtyPJ(zxhF1ZpsjhmRUKdob1tgX3CWw5HOXVWZIJFAfjzKtBapi(uMeb4enJIJWDQZ5Ujl7AdpraW3VlbuQVgCzTZ3cmX1UwltRkXVmgiaKeNeNfTdEiLgH7gNbnQMV3WN3rshA(M8TjLMo6zEQM8dWUlUhlyhZ8oX9BruZxhM)vqae1xSf4)iUqlFt(1hMNcpi((40mckeGiII3bUkqmXkPTNVxGAjUIAlX2bwHl13UZRYZzBGJ8yzQRpZ1G2uBbu49YDYI4XCGEGq9zoT(FqlI2DWYOlSXtTlof0jlRCTxgp0Yk2XT0jiHDjT8VG3yhoQhkgfYL7PnMZUY84PX2pDjlL5bsNDs8ADPC19leRKsWAXUIKL5Bwe3ChGITKwVgu3IE4CiE2YKksweL8eeI36dG9YQrNToUmAp41arPMKJ)TiPdsaRMYSAVO2J)ChItnJcysnHn0I52DofuWc3OPneWsIRvSb)3Vpod05rSogxd)YgK6uW)W07txr(2fpkkbEMnBkba(NWFUqYuEdY)kjaD2H5Fp8Y0kYdjtkixd8TdZ3MdsvuHo6fjOiPAFbSygbZCsg5Q8iEYWZMEg1aye7Q(Yr2OrrLpUDzJyLq)l5Fbttebk3Cn818hWYySHnwjHmBqsFwhZNvlcKJ7sbYX)5qG0kAgOaPt2KUlmw1fCIYwddQpkNHIxUzBE5fVvzaKpnQ5LdQVmxNX94aB2QhzT7dQsAICcFLbwzvxWBvgqWyLoXdhRgjHv66ukbBgw0PW31tuJawe2fZUunu)NeRaMge6J4FNUci67Awk1dNHVeRr7kYjJVe048pIz4GiAziy(8vq8tefnvGEN7OLZkmG1q8IKhURifc6T6r2RB(mXIaWgciFamxZ(xXYG8wIQW0BLx2KBVgzS5fI)12C4HmAh7ITvFWvw1UjWiF63gvVTzSn3I5BBqHsDMvqtLjl3HSlQc5oxW02O86MGkxKwrabPCBAcQSzXjf0fbLYtSfhPIm1xN)3LQ7yxXyAX)bJ0hj5(TzmVDzdg44chO9fomwL17i2q8aNe5iP(s30ZS2FizTHNsfljzyItQjw0oA(Q6OM3Rv4zj78kjwAmv)LCkLDlMRj19DWR2NfNc7vJ3b6va(ltZWsILrMQJDLj7xLRO6GIZhMt6aiCLcWxN9ilNg1PvJKZhIOVZa0Ax8(4hOGVD39CFChwKaEMH8IhJfoWAqZMxjDlQoxXrJJBPAn27JjalSaLoImOypivhjj)44iHDLw8Kfc6cCC3SaNihSOUEe1igz5a12ctBCy3qyp6EiF6fYtHwz1RnlVtEOAv)TYqRQn0BTSvuug9RIbYB1rGsULf7Rido632hVTA)MOvj3tVHZQUghOR)Uoee67SxmWTo(cpNrtqNXopOcpGQVTdd4l8pfn5ENKqPrcFVXlaLrS3OCukRslP8M0FBvuYVNSCpXGblKOEcJe1zxz3sWr)HSIpPr0Xbl2IBomXI7IVpjJSIOhGEAbiwhxSiLkLwVzcFmw82Hb3YLXfLmkmOjOylSxKSD5wjfk4dXItnIpQbfktVlnZW5Q2lqkWyDiBXPNAKGT3cCYOmlVs(VTRvTCxYsIt)RIQ9Z3ZgiLmaOheSJ4JXaBtE6MX6VcdKNg1OmBIUslGxz)OAQogJy9ACTPUKVvaKraMeCszxIUQmPa8eHbrJIJghgXRPeEmKR4HnEQi8Pfj0gdYkYeuqgz8w4FVloTG8mgOmAZzN5YTtoEm(p786rU41JokE9ytETrkoSWRv2dn2MdUD7(oRec9e54vS3CFJsEqyX)gqwZ51ENIapj1N5BZEK8Fti)hQqS0EarslOHuqMZtfJGSTiVIMDcYNjLp1FINTHTjPS37hAlYPzPvgo2IB45T1WQoiu2bMKPlo6rWomKjRiSOBJ3NzT5KPY9e1CCdLzd4Uamzjj)rJP4AZGKk78osxLu39tKCo7iRmaLk532NUBxYQZW9gGroQhOMHpj9f1umCyj8WsHaRbrfxKCp19cAbG1tEQfWoiLhXfj0iPzwbyA8J3xLdMlibQdretU9unjBYqi1M3i(5e6X)kFn1qkNJrnfzd69trbtLU0rhvo8mIrxUMyAzPWjvplwwHkNIk3eb3v2vPSdeNBOszfkFJhSys2)k0iXu8fw7kFu1Kvg0N0dVOiEV2Iukvnwm95FnwNL1I4vPlJRyP4j)bthfmgrt9D1Mwlefwo7Rq9nUCskRy5ONBAHkwmS4FXRvXrnD2hAKHI2Jj1FJBJtKrcZmDyjntI51BXj91Km2v3LC)osgVpLvlGvXKT3F)s4T)kT9oX9b9djjGi5V0a4dZ)xuitkKjAcIvtHjAQ07fuoS6hujW63ejrkbyjrlY3UVei3jfJFF057wkJhhv)nBGZ8M5Q7rP3DNQXvURd4owhs59fuMkK8s)zqBLOq2AwfTpZEuqzTXInZ21hSMszTlLfsvNeanpi6zVGt6IKDtFma3sFOPo0wUoFHiXDdLleP6wqDh2PuxLmNw5SKDn1FtNixQ81Fh3dhh2MONP9Gqvr2HecTdmq3dt17c468Cs8yF9swq0SJkICYsGtgnGK0OhIy)reziSUkp3ExtlhWvITDccrtiPo92TfacNYBY6DBHq9PFtbH3dWcPbo03TI2G3Sjx4(DvTZBlLXZSFxi8qPQ7M2esf(bO5sxbn600Lv0duT2zO9BrNv5Uvgjqx8R3sqe4a1M1pyfAxQLrmKqXg7puSWYOWL1DZ2wCbaiiHardNSlQXEczV1xOzFUV1AbbL(6kbLC2ovr9OS9bRfGBOTHT131Lg844P(JXVTeyfEFlVdmTMZYlcHXyNqJtTsGwXTRIlwXYOw9F9CUxixZbcTusVll5lefuHTEa89HCrowgq96GziVv3fdQKstokKf)MGf7JLSrzzoShInQxyoRUhVwT65Ya4LDF)Qf)Yp)cwPpyKUx(IXPtRneSLH)(fcxJlTtOPzXq5vkol)CRoNI9Q)KLy3qbzK9rURM2IIG)k7aBqaIdsBCDEHVrTR1PLdJDnrSCPyLFREmdJuUMfUlvfLtUWDPQap4(KIsYiz)CynCYWZaBmpexqSGcAJ(xF9V8JF)p()8vhMFyo9mEt3SlVqueCVYMfUxrkW)FBp74BlZjQq5jZN8aWBGT3rkL3F4)lLi3m(RO)mWaOb91VQrCvuWpVIfgLL3iOZWi6p63haW8Wp4bHBC5UDO5in0SrhR6p4jcKf79MO8Fb)qGpIyIS8NMCInxl1H6KxeOE(lcuN2Xq17wfni3InlimRMmQPHOMPAZh7h7qqea23HKyi(o0okxx(1AySrzz)ccqVmkPa6BhFsFtlM9mnCf1ENhUw(oU0ujRuPFLHN(p9KA8pxnB8tpjzh(YjJ7viFfghFP0B)8rxiW0ogYVfGmMsdJvvWqvcFd(BuWeDfnbfgUPg4aIz3JkohC2A)Q71xAzC1SZNsP)sD76lNX91N9IGXTNEYrtpNYNncF7YjdAb33QC1)fSU4YsE1VuNw6or7YrBW6LeQiwSSLOsnO7k5Ob6UrhpliUF0XZcI7i)PCwEhM)kKd4ZWxf5t9thsFPgKq7rIcO6Tjkg8mO3eonMbSwaAl80qKmW2Pi4c7KxT421OZir1RtoE)lSlm6KB(3lNnLxzeFQrIwceQDcfbb2DafXR4H0rC0ojeevwDao7unshaFV0K6MLr7OiggK4foRADZwJV2lRwDYWhhRC4OUXTA3c(BBmFsb)FrJ8d(J2EPViereS71)Kai6967Ar95Fo6zmkgYSHG70bnrUpA7MP0fcjpBQuTbE2N3jKJp(uJJLyG7pnhGJDRK041FcCshh19Vd1(y(Kc()Ig5h8hTssFjCcrWU1AfSSO(0QK0cc1gLKVaKJp(uJJLyG7BDx4jjgqFwAE)id0ozx(NmWtwRroaT(7deSesjnTIIoLec5wFmDm4Bl3SJCS9tg4DZnnFFGG1p52(y6yWhi30WW2jiWPhI0cOmet3VB16y7Bg86(JoB6BqGk8wJlBnR1UnyWv9D7TngVvFgh5DghXNrbT)Jfr7TF0jAV9fGOvllIKIOojLC6W24MIjal6viZhelS1N2eq16lpIuzjyiT8CGEzkDdDO29zA)LFg(0egL8HqA(7wKPqJRFDJ8AR4Od65JZj)GC0ehb(ICgsptPCDOg0biBJf690M1NzKJr4zUEg9YC8TJWRecPFmemPlw(LsOf6d5gtAP6qekqhly)Xzwq2KEeBFEbHe3Ra1gN0RSh3H0RdeO1EPWlbdla2Yq(0d8NzmhDNIZxqivVuDY5nEDGa1lZX6q(0d8NzUdmm0PqLpY8jHb0ozlWNiG)msALrvn8sc0ory7teWpkroVg25DrQx1k766B3cY7Rx1fUQ9PBM1f(X6ZnIjZxFWju43vL9TUtUp)aZ)euzpptFNFzGkw9VFeM1Xavh7ll208CjeiEI)mUme4GS902poXj8sf2x3FrtWbz7PTFCkLiSP55sBFzUBuVuGfPoqvUUFYa1SRJeki7y234poA3g)YSdCSUWxqUt8QUW3dJP(5UI86wyCoj7OTWLWU9UTYGjsgwpI7vMDNh5FxN4WcYoOob2VKoAH5kqhuVWU1z3btWHF47PcTeWoAc7h5dr)OIizY6EQ38JJNoI8l5x(TPz1T8GYZQRw53m7Tn)y(D4h(SdZ)t2VRCh(bBRjXbbEkPvNmJVi4Ng4P57Mr)Di7u6KoB0Pn)Amnda5PKGasjWCM9aqDxHrnvw0ltXOgCff95oWdZkkAqBiKJpwczBkvRgc5ltbR1EczqLM1a2UO)6xsTdh1VKATrmuGP6cIJLfehjjgEcYgA7INnvmbAbt4QitCxUewQrQalzcxLzI7cMWsL84QOjcHviU31CkVD7Vp9KrEvKVJSsvRaXUgS7PUTTxJcWel142LFSupBN(Tp7oqUmWvxSg9JC(QUFa9j9NEcRtRpqsre(3tA1vREKqj5dTYEJDFa(e1la00XIVPJRXx2Q30(zJ613StRD1OPp90j27VAdWNmPUnU1j7QzJbJh2bliAz95MOhNKD1uIkCYLVg2Hi1l0VA0WboWXMRgohfPBS4D4Cc2fsupbExX7vy2KIU69oqUBT10X44jw2z7rxag5SL2iOixdDSSUY(oSUq(L9VB5Qxp2bUA0pQ44js3LTNL2ifzJ)lrF)wgPnBVuNME7mdnB9SRdSXxh5Ot7H6fdN690t26Bv9SbQtOSbZ(jPcLxP5cCQspSgSucRNtqAH3G3yYE5aBQPtNvpNaXFh(Dv7VuRie8LNzpIvz5P1H6ili6Nz2vOPDRHxpUx9QsmGEoBU2ufpAucx(y62ftHcOrtTtucILkVv)OwWTz94MRh4QD4Zy1w)fjSDF6Qc6HP1WD)OMPLcCwAG9nQTgJbfsoBv0YRj920jtTyD74W)q5DdA)dS2riVJS2J8qgQihRewcNo18qGGIS11POgWi6BTpwoJ4rHNgHj4fKsJBMk8RihvO2wvzRePoS0PSwXktPOlH(Gak)2YlrFoIDxEIxvSubVwS6j2yCpXKCRer9la1EiUvzoveuWlzrEJKjX2CpLnBETAsKzcNy1QAyUSz14Bi0V(26EXOERALSgMV0wjfX5jkKzdhQ9Vrx0wq4rPP8l7DtWIWenZ0xjL3B3snNUkLCC9ps6v1skwBjW9oXr3ovdOQUebG1wZFIJB1PzpGLZjkXdOsUVC2eJov2ekr9JXpC1wjRcpiS4tOCD7G0kFVC24xdQyrC(9yi5E49iEzZO52AeSACGRg3gzevVoW)o28R3fDV88AlDHJVTLjzjcXl7pA6B4tSXrk86Pd8qIpo6tyO2v9h3kut)34gCmVn0nt5s5gUR(Bv7XUCLGFJ05CCDTXyyVjZyttRp)W8VIKnvWHOsYjprZffSrf2v(n5xdBnjbLEFCAgHG3mZsopyrPQv94p9Krxr0k88Y2COE1N5oIYm7tz726R(THR(3QeN7ndAX9jnxHQQWjYAdJM1FYhvuQ97sNnEkgWSyXZMkOXd9hqTxPjuK4yukcy0XpHww1EbwHCNz8CBYMxEUFQ0Xsc6g0ZJ2UVMj3zXBqPqQMfS83LZ6FEGMhKG)BWYrxh3Ly)8rxGn)AjzqFzDSGneLMH1FsdmFZV49Kuhl2q0YdUZ1j6gBM1J1uiolt2vcd57lgQsCMCfWCcKI8rDLBZQWyDzRZV0b2hIWl23Q6YLovCQqT03so6W5)ds2MO1Bd74ELC7PjBuZarCqALWAsz6VvtuejigYoPKlhlYXTfHV(NqgT4h4cMx8sLAi1RFyp4BA2SP2(7F6Pa((3J(5d47)owmdhYbHyJgIJzSuF(plzvOa1dyXpQ)SJB97Pzz(TCljw4qaB3Ghz9StWsuec3GKbgRFIeR)19h9MAdM03(WJfBG12(IhzNaRG0VF768ShJeNJE98Q)CjGZ)syXbY4lIz8l9hjnEgP8N2xvMUkHzZvqk3xMakV7EsksAvVnolJyDOyFz8QKc08E73XQrt5mbh8htsRnkNGrybqtg8SicyjxwNkGVooE6Z4HQfXGIMT87ta9H72r3vj2DXR)UaxWT5umW5uN3vCQVmGmppbLqF(aU()Fox1PZ6dVy2o6BQnHB5xBpM9JCTd7Obeavmzd1Eterui6HK4DmiAJwsTCCbwQERFQu9nix(hyKGPsJPPCnBIwPhAlPaSHH(obFXY5xPF8jeXY2tzSEghuk0u5WmUS)fd)I(iB6w)yzf5h)kWP)VOVSVRMnRcyid4cMihHI5YAWXSUyhuQ9VuJy6JACKckUoaioxf7uKKJsGeKGpyc28u(MlMIqZWx5m6fQEM2coLnCQr9mzkFwIxKVjDl7CFYs3SOr1K13euqrdAj3YEkFfLYTJu)cBAD)TiCaBCqQvUGfiUaZhjcs5tnfyChbX08KIGtQbGpBKDV5K9khZkLvB4HxCyPBVAYqdfEtoYfcT(qqPGbFuFx5Jw)M3nWV3SbpHQoDg4c3kzhLjjhwHiWklJtj6dFebsjc4NgG4PIx31bOF81FaX39ptCRmujLRFeCkb2vVHSRRiPmr94pXmAwBTKN6GlNnXNXoFQ2z7ApNi97Sq8vYCX7MAxcbKPktIa6YQqY64LZqatz8YIusAgIZI2bdazlM2UvFLJw)DjGY01GNqpR9htSTv1a0dq2dzj5GARSPYwIKAAr1P5GvrqhM)1lsHDDPjkoSYlxiP6PKmfTOCMmPZ(yJ6jsD2O2zK0c6tKbEig2DqYRrAPEsFQtc1OjEXoGF5uU2gIgigfgCLwQbcxN(k6we32QX6bHD(q7CdRd(c0bJSh5lrQtOb(2JgK2kejgDN6csfeREiTs26hO6qWB4WWBA2eDa0wSUAH01AWCfjHUGVS73(qEr16hvGGYs2l9Ac(vgRvZQx8Uje3gVxTLEchr9I(RHep(a9hhTE)M4T5PRir)EAQ4(NeLUztYQ04kY9iQ5P3LLViot5raIIoNC13)KCLR1uxa1KazDXbEy)t654S(LH3BmRty8KBls)Dn3UUuHPFILAlMUvYXneqKUiKRia)ZTpiwj0mr2QQ2kZFrTJTujR0RQDKs94S618mAiz6fgp)ukWrl0AcZ7PzzE6VUolcREPEj4lbYVY7uY9544nDrguzw8SpjkTz(5FiCEK519wPz7J8iRVWmbkXLA)azDFeQTrSXN0ryRFBBm4BXRRRr0RzrT2aPHAzrlx8rnuIcLZb(QzkNw4rqApcbO6mfZllRVJuJKYAK)QdZVUU6Si)CXtecKQslXrVqogg(DmAz(gYf8nNCRB)2)MDKkYD1BfsPj4gWhNeJOqnL2Z6DAcxVG2s4iugefAvl1wLcyvotxPCi6yl1ToK3AXp(lVyO3PYNYcBG9D(bRB(xTfyTme1CZEswwKNLxSs6zF4rGqULvVjWxFUsAJ8IqAYX673o3T0kvnYVqP5wJdNFxCMTilpFvDYYq8H14Za0BrcOMOGEhuA3hYlwc6ViLSi)X8C2qfZahPKJ6oytfbo1AyIZUq(OuAWPmsEAkJ(37xD3MewfC0MveiqtUF3zrKlKGJpMF1vnp1geaFBArcLbHcZ68u9E31zq4Z5I47iFo5ky8HsxRfd9qUtY5uHUCZEDvtmNMVZDc3NioA1Rf35dsxC5USKVOIFvdmJFrC9qc1uN5x(g9kTpeT7sFCiAC7zXvFRat38qOwdKaHTia8K54oWDEhRH6y8nzrns8HDtoAjzpi0ZMfMGVddOcrmnB3k)71BZ1jt(XsoV2IB2HWgKTRu2tp1x1S2jM3yvYr0B5thGDrYzcbiNBO171Mnf2bF)lqyxicc2V)esdX6LO4x1VwQIErs5mstxb4LBy3aTu0gxHC0mwZA3rOf3t7dc9WU8LrqwzKH(59vpDJVWh4yjg9YXJgmWSWngr0BiPXzvAjL6L(BRIs(9KL7RsMnShtPEDiA7wwfnE4Ltn5hahuLJCx89jzu7A1nBK4IfPkSF0pUCzCrjBTd7vl2cQkjsx3MeW3wP2CtoANd(mEpaSQPzfr72rKNrBjsKi9s4TZPv8o40PIoz0IerZKHIl8glXUywNdKbkJihpZ9YRmlVsCtTzrP3KWw9oqdQyD9X(ODR(51IHlJ)KsyJEn4vAvrcPq5UIKS5e2XbvJP8bv3JMMnAqZxQ1MIUsTgCdN6m()aOoJqOoMT7CxuNXdKPRUPoFgRX5LVL0UtYj9zqs(K3xklelAay07lkbCNkgbrUME(ZSpRgjpm)N4DURTjPS37hAlYP3gef4em3ZRSTorUPbC5seutUT(NhSakGfL6bZh67v4tFhKj6Btgbznhi6Ftf8)U5))]] )
