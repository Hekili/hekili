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

spec:RegisterHook( "recheck", function( times )
    if buff.breath_of_sindragosa.up then
        local applied = buff.breath_of_sindragosa.applied
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


spec:RegisterPack( "Frost DK", 20221107, [[Hekili:T3t7Unoos(SeCODB3PNel740DFioaZo3UyN52B3ftM7Vrw2wjwBKT8jj3zYGa)SFSOKOiPQIKY2k9EZTya6PBlYIvvSy9TOU37(F5(7wgKhE)FD0WrJ88g(Plg5n5ZEJV)U8x2gE)DBdw8uWJS)YMG1S)8pLMKLVF2)X)j8KxItcwcqilzx6c2txLNVn7F)YlFmkF1U5xSiz9LzrR3fhKhLSzrAWd5W)EXL3F38DrX5)4M7NJU8dhD)Db7YxLKE)D3fT(hyqoA5YWIHhMT4(7U)U4OS8m(IhT5X4q)8G0hdZz)WFLtuHBcMhhU8()adslGL)(7sdxNKMfghML5)C0M8W0cOLgTTya3XH0(z)chu7N9Zj5bfpHng2WJcU)UVgW(FmiFr6Z(Z39Wdz3NZqETvSE4WqUinAnB8Hm8y)SE7NLhehUj)IOfHZz)4tHPxKgS5P9ZMUF2OASDvYZXm8XFECqwoSiJjxKZ2ptGwBts4tlD3MWm(YXrHNII5)86GfRI2iJnIz(aS1MT4L8vH(BtJsyG)LA0r6PaYC1jhzQxQK5XaWaXc2knHCLaOUF2n7NDfh0S)z0c)TjpZyOldFiAreJaVLXtNiZ1faNTuxucw5NdBj5R8tEWNjxTmn4XKSGQXjV5KUbgtPyednVUTmKkCLV49Lgt62cbR9ZE9vcQ6McQAG22JFwEA0tCU2NirN61Hjvwkctl095JISyJzjND(0MOhxLFbSJ9qc7WftI)3ycylcRO(LHfNuk)5lYYz6D4e6Kc(G(ayhMdI2KXhYJlwEX6GFD)SpSF2yf2YJXblIcI9dw(1Gnl4CMV0wkkmJs00B4XlBAsMYtxtMc8Xb4WAagKUiydtXysAktYMdqAfvw2ojL0yNBxKeV0FvyqQrTVlwb7xabgbMkuu8(dmiSF2FMdcjC6bqOXhDNUqQrWLhviKCgHcMDBRMHmzM)CI)QGnl9xSkee2QupvtpvIH3oLVrclXHm79Z(mtQSy(Dd(XxHdh98gYXVbMTLDMDLO8LylJ6csHDAUSsf1zG3cRFb9JcaQZ6SX7TF257NTGjWUm55nf2WE(L01z(pSl9fWYYYxu5972Skj(fqaoCZJ5RuWo9NHUWdOKPTzJ2gZJqv5dbXS55ViDxwWYAfRMy1c(bjNe20NOW0nUZqY5eSvIPp2m)YOBe24x0wxWyz2jYtbtvw)BdQL2vghivtOML9WRugK5TXvbjz(ZdkvknW(o8xkgIDUZnCJZw2jUYO8cZ6qL)zaNYK5gz)vvn28h4qGJj)nj(9(zFpBQFne3TFtQTn7bnIkveVjSVuSH8YcrCozaLBuHJwKhg8XZ4HqsSHeCgDy)a8cI2Z6dYjiHm0rfQyLqKjzMgHkQkTeSCzwPZnMT7I4XUUtLCYMDa)kMo9VtO5Kf9siWlb5rMS5VbQexfSElODPiKZpu4AYbf1PSZxhSlU6YEhWrJ6qzpZ2zr0Jq0YRwwUdlYzAXzJWdDh)QjKlJEaGMzSuBExnuYaaHXhQ56nbNFBmKYcd6GFRldxe8Yf5rlEIX9Bs9G1eHGhZDx4OrEI)i(sRmYlzOY11maTvWCiHNMLerBI1OhpblBJZYnIN8WekgrSXAi6s3ng5zuHJcx5AlQ5t5X(Nzsp)84KKL8qf00V)Z85Y0VppIXAIGCaGCqTYPNIGSCulU2KQXLqMmskiTBwVRvavYl2UloZIt2wbvm4yDM))y3YhxxMdbA1LwHgKcgMBNbX(lyoO7OYqkG9quAiF7dtB3jZZAcpML21cEKBInLPOkZQ6nByJlo5F0bWwKLms16ULznD6MNhOIDk0tCw3zlWOMP8b02OLSOQLrGmBt4)FJN)SX6ReecxZ1WWZ8N)ZHbBzJR2sxHhpxxTH4uupFQA0yU(PL2MSC)TXbB2WT5nWIX3bK8mjnJi0JdboGMg8s2Gdzk3voA)Mw1)0qvEDPOky2J)V55QYm5D3UmWV3h8zIVL2MCjrdUqqNsPOjUkf5h(RBdxKdlrH4KrPIYeHwIP6JqGSTNh2LPV4apA0u03tQeAbZtwhTHJo(XrRNB2IJRsbhc2AgNOTEDAfop9yoTXUaEGX(HBcxhb1(dYUZOkSWIJ(L0bZdZGVcohwuSHSAArve3840rKBMYp5PKLjMyj3MzWtMdhOlyWk22PuBOKHnSbjoc40bdTZHwIgXvjWJH6ptUS4lc2Qay9WE)uzuP0ZqWRqr6AMLzwcTpm0RSdhdBXH6dHLAMMODqsNlF9WdgfOKbhl5xcgTBjaq9JYt51)PahTzURxl92De9ukTAzBN2v7WshbsdIw6h(vy8aR(IWFfAYLcq1V5JHDHYc5CEZNUCxvITLoRempljExEO)VfMMOEi7ab(at733RMEQ6kZX3PPDkZO1dBCut7BaEsXLrycvUSHZBAHFBFhoqq(zfoBV2xu0rTMinaj9omrBd8W9i8i3g7zUs5Lh9mnDtfk32(A7pB3QnrH39hDK(I1NO9AMkAVg6APQ0Po10SwN1OqZwKA4UGxnaMWilqd2AVuwscggTxXAkAUTkuQI0rkYq62f5(JNifQfMRGJuoKzkS3gjFFOQGMP56ITcBhzmjqlXXZs2fZ4nbBlZYSl5JICZSNBK3wgx)XvSf2I50gQ1vmrKfWWninZmmzl7h5OVX21Yuqe4oTyqHQ8PltL4FID9lIZDie8eLDB6yxWyxt1vkhS5f)LBwwL)nMo9Gn5gZ4nNLL5VCxZEWQy2e582c3w2lrLYDk0L2SiinuNIabKaeo8tq0Ev4MgFC)ph0GbO4mSIBYkYIwA3kY6Qn2ruw0WfTiGdmAq6e6ZbPR5fdnYw1HpK1uUI40RjTxJUUGUOTNC)ShDfpRSiqQ6HAIxBDIgCz7lOJOYFVbUBKQ9bn3yVH2HqNexBAXGCpOV7YxncSDsBi3BK7UuNwsl5mZHAEHEqODzo0eJZP9IXgZXISqWkMVKqXGxf6VBZZjP5REXCUbTCGNaEg9eWs6LbNIMZ2QUy7US8DmGhMUBBtdiIH91e4DwHnow0Y8ZuyEePpi)v7whSjjAzLlzCRCWc5h9qHJzOaxzGRxhUmIxiEpjVOzwnxXF)zKh7JXjZdIHbYn)VnnCrY65b1Tfh20v8Xw34tYwgAgMdyB1CR2R4)n)IxciMRkBEkm33Zp7Lnlu0ax8KlY9UyvqMpudbGvPDI1uiFUEiReG1RNqOUoa63zquVEumR4df6jBXABw)HcwygnfiWaGjhVJjDcvU)UHxmP8hk2JByTTLBxJO3Ug9gVDn6)BSDHIMoVDP7OI02LQFsgo0qUdXPEZBFwz4xQmayQ(kzFQSf7VOifGKRMyK15urrIRkhH32aRqpoCPYaCgR0zE0yLNewPfe0FmlpAnt7lZeyGa2zamyBRm1(VaYrR3YGiynLzHQwUA)SKhk)PY59rwitrFnAjidcZK)SAsrm8c8fCfCBAcm(Sl2p7phuGdvj4z)S1jlzrhd(WKNWCvI32PSbSk6XvWpw3OGWJRNwfrWWgaKphghx83cKb5djS)i6bzYMn2iySWtk(BBsy)ybV75ia2Io(4cm9nnBfszTt1hC8ehBgH5dz5XgsOi87)r2X6W0IGPtsxJgBiZd5unTyY6ryH9YMo0B6vpxMWKFLp19IZowcE5WZ0OiLJfNWlw618CALO0SUphKLxNsafwSssllS)hKeIf4VI893N8hl6zzqa8VaoTxNio0Mu05w6RonIj5fnWQ)daZUklb1lulAXy5Ccq9ogwN0GT6VnJiV9F0bpYPh6M91L81ykbjYKcN9q2VWU(6VAH5yKn4qmiMrsPNAooKdLUp6x8uZP2uJsKEZzn2mWhFdV7wx)scqS(CTsdp2P)c1fpg81WyHYLOugbhKohwxjPe6XGOhOAwLRntfEwCsU8)UMUmLWvrToitmHsgavDbP20RM3qYjDSo9DnCeO2KPitEkaQH3hqcdvk(GM61Fr4WW(z)IKNav2l5M75gSHlrHWsNnww6FXhRSZoNnkMJmlHflfgj3wX2GOu43ka1FNZml8IGFPmCbMQuTTPrD82INPTfVdABzuZTLgUQISTOinoctZFlLGT4NoHV2nkyObFOL8dXuex2tEd)nGspLv01Outg(hzytYM4xG)me(dUSOKOCLtQCFfbS)JvJaKUtY5EJcttGP7N93k9UCtyuXZTdT5jGyUcCWShArc3epNofcKBBibz8TBBRHmEUKruGPCmVGBU)QrgSaPOEgmz8g(QDzPjNp1VAxgBYyc)IvYOibcjNaFACwZHCdoCtDgsXviK8R6a)Q(YlrBtZWnFIvN1mw9n8DEAhCBe3sptuNbUOB(86CylUii0JOgMg91x3t6JF32f6RJ2xTxeaA0w)nnq1rD93dnhUBx8ScwKRGf6Mk1f2A73(B0XNoS)Bfn6ODxd9(P7A3A0wHOgEAU65GfWhc2fJEVcO6JuvnyQb(AM7XmB0HH)wOW4x1ZG35TnpcxdAHYWKoJ(1tTrwKW5NfBjgAHZstiKvjwJa)7P8bTFw22WfqkcxUxkBOZd5gUkcrPiCKGD5jSyzIwSFgB3iKhbubnKDrjx98PxwrnFeclDQa2(LG(JCACQCIUKBdb6uQ3c(L(7HGPwU9q6HYBRE7cQPb5QCEq53eZKvD5zm9w(RCuSC8bmOYoNUke9Ps3kDY(AkLe06RnSdknOLRZUnXHbzRc5hA28BVG2GgngevZci)(m2ys13LyJ19ypAXlmLaXGuk26l9yxwzPHRUMk8VT1CpDxiCM7DqnnRJrwubctVlkUbM6rHbRk6wI3ufKu97tTUZloZHKCnhDR1GR2yQmgVh9Dvzne(ktsR20cbd4H0Ohbng)A4IDaIlF8sBGj83ePTKJWELc03Jm)cszDqfuDdUc)1GTkP)gY8nYehxx)0QTE0aTqC4dTiQ6UGnEsLNzYjS1wi4QVMLmhavTj(NssHRYuWexWw2(otWzpVwBldzObZ(FvkqkEvvNd9pDXpbPZiOQPk5vqesucK)G6uLLVkiVC(1xzQS)o0vTlH65fuw4pWLmgPfwCNRcLk8hyOdG0aa8MWwGOnLqIXa8loO4dxxQS1liowPwDCbx)k38amN8Ovz16u6rlXPU(o1yrsC4ZRY46LQ9R(LvfjUyZ78kHLpu9J1B0NxyQT6XEdhI64UJDjrzMovzf2toF5DhM7ntgix1A(PzO6oV0ZaVC0qeMPUBWoR)LSjCBHmYnsrIGjOwV5PEDDIf1JZiU1EjXXnfzKhr2sr3ljZIqXwxZdf1qelMm8aVu1v(FXWICEZRwEHr)NGCE9X9Z(XfVa3VYGpsLL14)UYDnySG)ATiVz2CU3i71f(F)6uYySmjeDEOLCsWTbIfXQHKRoTrNXQKajBeKRc5MOAPhFcAN4BnFoXCUnORo(bY4CMX8TMYPtWzBP8ZCN4TjDrl1yMyOtLkz6o()DI)kPRl34l21HX0CMP8nLQPtaClP63yXEDczeD(LBbMzZgNc1)SE)rr0YxwV2dA1ly1yvSaTL)jqeDF4uFF1wLKabwv1nBfb4ariXCGPg0qepYXav8HJqTtfl(goq5NJrii6asoiOY8SrquDn1baGQYCwWHQ37paewVGBKU5DjC1b7EUvYBjZsLI0K0)n91owzuiP4SmVF63rbtjUyVnZVf339adN24LvTL2opzvRIwa(kOz1cdaNJO0gmSIONi3PnzwDqBOko9C43tphHTD3WsL2WaQZdT2Eu31CuseA5xa60ASXmk6iWzKT03vNYEnKfbwgm1QVxpJV)UNdsHYZWSRWB5TO1BtsZl7O83RaK3d5T6)zxrBSLXZcwzDJGFyXQGnpcj06N(l8CPn5FF)SFizdBf5p(9iBQVVqHp2JQ2VzdPV3VoWguX2T1GUj1E1RY(FcHluRXODSGrDclyCNa1R6eOEQfcq3Ek2zB3wZNvrSKTLlzz6xF)zePeVNu6vUz8i4FkDN(ER0tFN31vK2XdSlzatG7FXcU7muLqrNNJcM4n8FcqfuzcnjSwizqiYQ55IMulHFn6hh(ChcBpcTnhjWr5UL(82og7NoX6cmYspyOIsVLTar7Oxcbjd17xdrDOZaCuFRWHATvOHJ2ocV6UmqdGnB)aDiEnoe1R6VgCPA3ahHEDL9BGV6nqGoejKA18(udSevv)35WgPlb0GVH(iWXZ1s1zwd2iDmGJWePna0ftOBuahxJMnqqd0NQddCEfeDEagNjvPNeCeM09QG2syVPgCCf1BJbT1HQlhEBHUnhW6335k8DU3G3vMbJbVRFF4GX5Jh8H(sU5C(Kbd(G3WHviB7G(Lvq)slq3DN6KqatPjgJ080w8rdjPnlGUbDrc6AcZ7e7RGzhVozXKAEzowSVBcNSRaB3eMkfyp1BHDD2lkxgcVGEJwMJDVOBItGcSNAMcHLNt9Y8LVPlZrUxmA4Bc2tTmhl23nMrgrCCsj5JkER0OqqUcYtnFMyzoYmpyg4hCiTJ6g9lJo1jIOBb7P(GnAAtexPzVVvjoPHJoLV(UQV9Uc0d)L7TbfJtWNK4HFBCaKMT04wycH3GnMof8)lUZHWDAeSfH4DV(Mfr7DMd8qgqmGJV7DKXzwnKPdh86RoTqMdRREjnHqSvBGLt9VfSL3EUIvMIqAQruxLZCKzvNnESISprOCNevNeW(eRCGMTy)0l(y6uW)V4ohc3Hw15Oovhbco(Tv1jccHQ68TNT82ZvSYuestnsb0PWRtkGEu6JFJb6HDkTJbVdaEBAYIl4FHf2Mzc4uJZr831Lby6(Th8WEgVH2QUsqj2x1hZjg8TvS5q9lUJbVda2T9t6X5i(76YCqInEoSVIpMtm4DuSPz7xraNEeILmJg4pOxFZwKOoGo4d99UyY5eqL9urhXxoKYll5bdUTV5WhO2B1xrpRROx5kwX7FRyAx(MZ0USdyAczrQg(kq56i(9Q(xtCzfRlNtaBX1ySguBC9g7i8KU4J1GiYvISomjsWANu7FI2RTy7UL9tw3up03MqUEBQ3y3uSucOEsshWPUFHnkHFI52VnfySBQEr32VmDl0p1LYOaQ6DbthTDsTmfFWE0aS6xXNUeueL48ecQJD7HaSN6TNUm3NDvpY8TaNv(WeRbA0pAXnaCxAwHQXBowonby7uCUtb(jPK9VXDWZXc2o9LYGW40rB6d1r6YyCow)OldMs9s6xGHQb3j9yfcNgOIG7k7LteaJmKoe4wbR7jRXPCcD8lJXCcrvUfpZBNnESJa1khhDiDiWTcw3tzRtBNh)YCeP47KxwcRCC7NopTa3bWEkR6Xj0gBxc7gMVpfmdkGEyNd7uG7aypIJhDPNxDdSjYRw5flY7BL)aDuaBDcuFB6TSFpLtW3MxbH3MvHiGGdilf6UPt(bhUcQw)Ie78kO)5eUXkq9Xm2YP)GKW2DUNq(7OdvPa6Dtuw7)PFKt0ai9gvDN1xCBsbu293b3s9WnZKh8fwo5HOyXTtw2fI(t(8Pxw)rwE)pH98VQC33xAiPSAsFmz7u(vuB5nGV3hRVHyNo8IjFCrYMLramNIBFIQ3Bm2Zn19At308Mo3JnVZaEa9ytByOJougQBnZKJm0UPLUApdLOPL2)t)B7N9V(w3EGFRBBJ4yfMQlqoswG0tsC8mId44IP1vGNSa8MAAbIqm1kkost(4yP4n1(cezRqBTr6uetfL3LTMQ7bXYDIklfQ1JxCouur96tM1ve3LLt9t1B5IcbHO(TaUxj0PlgoySIDSv8TNrS4SLu6RpJ8pl9HNHp3t5N1fN)CUiJqAZO(J7s5yvVUYM61RFZVPn36n51xpd)BZYa6ft6INeDXUD6OE9ja7RVI)79i(mWC7edis9hqLs8GlDx)5Dry6jL(6BrimkEB1e)s9nOIjCyl2za9ljLE95Og1xHLBECXYpm(1xXhe)UE8MXdKqSQRkLs428RRIce1)AQWGfnbvPNr5ugHjCo01TbVBltOY0eW)COqpPQFhzE0KbFQAFfmujgPruYgrVCXF9vDP7XdyI3vBfnVose4BZ7rePhLuDpGi(nA9v1SgDx8fIe6pOxFnS(AgqOU7Z0g64s3A(DZNPdAPe(UMYfMSU7fT7k(aULnSD5Hi7VcCkDKKplkx4At4x4A3mQNZyWnEdPP1shDDKyrDlw96eX6vjIJuA1xbKB9g2ZP13izQ8bSq9eVCASAbtv4JutPfNqJk6ufzqdlXnY30f(TqJGcXQjxDIODMoIJ5ZtHmZt5tGXhJEy6zeFTk0vwX91aHKX5d9pJ0KfXd6DgTPHbkMr1YqcqenX1g3G69WqttIiuuq5dqfCyp1jjRBnjzD6Ovd01)uJ(gZyb2(i1ELmUuiJxy2UjIWCC)3jImhoD(nxC5aq9orujTXL7pxtPr2e2AvJULbWBFrWatd)IRbSuiICZeg)ediV663J2k5akZ(if5wY(qlV5uTpqrX7CzOvxemsmT6FSY(tZplagZwjlEJ(OFaaMor4vp51(VqeqtPN43fb(YcWu5s9)gWPnftCAUxR4xjx0aOAJhmXKJCrYNEHTUKTW9aQdH2zcYGH68YbPf2UmxqcUbm7ZKTq1xP8yk2ktu23N8hRp6(xGJUIS1Xw8Pn1yO8CmV7kKLfjQbKIj(4KPbjel3Nj06G4ZDtvZ6qSoWDbIH6SxpQiTPIQUgVWYfXXsy6ZxAnG52Q1wLf0o8w32O5DdcDrnLxs3aNeQT)ugjmwuJJMOpD1Vv8LthDECX7)a)KxHeouEKFojVizecWwC2erqxHvxznLWmOkWWovudjrInLP4B7F1KVRKbAiJMSNT5Pp85bOR4bYxfqqsur5d)(uplNECvQsSsAc0ga9rczJtxH)Fv75iym2RgshTjAArWwwnTofHmtOjk11RX)35DnYsHl2FKaTHW)rcV2VnGkFBZsfYumQT5MRhQPLP3(z)njVcSR2PWZQPUCEGja1QddfG2k3JyTiHwBzI0tKYDzdqardNdB9ca4OTJQD1FaQD5S)m4CFniRD4FktPmKpnggfvyux1dBMd296xOdM5de1EA)ALNQ1aTWLsPBFsEub3o9QxFTDZ4ZdkvjDcw9p32f3tPXuQFm43Qo7dnEwkLPeChVHL17Hi7N8AN137Crse4p95xsxN5)WUuOQDblFzGOCDRsIFXVQM6I1v)3La(XrTeX79aZfFWlG0DzblbxTO4k2s(lZEtj)bL1rq0LCdKPm(4ixQ4B1PxAm(W5eJg6kQ3MOjP5UxjQtmf7DvqsM)8a(jZb088V86R2iUBgtYYUAGq7ME2ueTHs20TjWVO4bLATJ1tNGSwxbyymtK66AMLIxa5IQLDDpRfS7Mp1RpMl6s6TK6NIbKoR1iFjQIlMjqO)IsE4bFM6ajJSwsBIHmHsWtKRl3nFAybpA8RVcEwDdtX7rGWTpVJ239MyF3RU2uFICNHSxciO3G5jRJ2Wrs)4O1ZB)j6wjpPk14nQ1ifklVn4G7Ry73LpE8G56rCmx7xWtaoeSOzj)OI1HilnMAHcvWFZ0jeOL2(oLqsBO)s99uDeJ4Sa2akLFCwEIg9pAXjP(HH3B)krn)PHYDuf8uNQotR3ekboUMNtfLIJuyGvl0HBVEyRwi9D1Xe2w08nT5XfO1)WvgI73SStWJOZznAo1P06AODaXBlXZ1)1QMATUD9KVjdA09GMbYGMC3dK5Y1f1gUlCQ2XoGeSj2KSC28431CYn(jbdXHaIg5mIRmlItmiCwuDPTJ32Jku1QGRrMcvSQ2y0MK2TYnpIyh7D6lf4aInj2glZPpgqxI)C49IIDec6IXgP242j9kYHKijEBxK7pEcZfpD7TJkL(OC(vwlkK7uZL()uwTpvQnyrAeK(hgJBlBaYEh1O2QgrXTmUYJqFoQPSvt3cHsjEF(VzjF5P8ccZqdXz8kzoQyGNqF2zqJUmDcDdP2qXzDqMfLxF)SVx0YOseEzT3NYj1m)L7cns59BwogXj50gjYw6WCJ5nOnvoUPzb76p0Ttpqc5LCfqYbbPDZbi8iqi95aOZCF0FDuJ0QxxqHXwXUBgB2Njme1rmYn4Iw6mJW1OlEgppIY2rlfdO(b9Sf2GVMCWegm)sJNu(UyytNx7DOUMpIf0NvPJc9vOST(M2huCiEIB4np14gaAlORwiDTIztfQdYQq)DBEojnF1lkqqHKTYVgRfce1PxBRQv8U(DNLFuJmFfKV00V(k5B7CPvn9F2F1U1bBsIwcwe(yu1lvLF061HlJcYH3kV6F9X4K5bXk)edrjxZsBeUwXmzDYeLRN2iR8Kp)GQjwARk1T26jnyllWHbF3BXAdT8mvvQkqSc)srQZhgPw10iimxtRrTDArVwk(jSwoPpHpAi2FDN1PrO9OXxsy22g(bJWnWMA4qsNSz8nG1BcDKt2TC1g0GjAnEdVXZ1536TUt4MXBpd31d106llvI)ZCCc1n)YEXD684KKLImciOv16k1yAqg4czA6tbTxTCILYcB3fNf2YPgdX7M5)p2T8X1LYrTy2W(c8wfh7dnNzlN8drPHCEvlN38Ghb)ayIxlEkJkPlKEnqKZcNwOwv4EQQGAn7iIx5vtoUoUkYZ7IG(FfEnLabvm)ju6qwx7)pIP7WzRE1ojcE6(eeGAWMNK1xOdsnVgq1pWI(2fdQM9MqFHLoUFqRRjUeAxkEfrxk22xhgl8sN7L1(nmi)6RiyiZqYGwirudurpGsp7wBiYAgcXtU4ntE9v9hOFI6OKtozcd0aY9g76KiEaQyQau1RVYuOg6mMX6I2V)XGVggZ1scnXBukd4bPZbMfx70ViUojy)DPliMQBuc(l8m)ECbExAclVdAwwETZ8XQRFL5Hvxef8LO8LXCBqXvrvbO(7CTLfxUm83JZlAI8mgGa9ZItYREPC4ULqLAXsTXe5TGNHnLRgLklyY3glYPVRiXzc(EU2DddZVM6zsCTOCRAEQDNqhDAiupccT5vROjcD0azwKBekCLNW2Gt2e)c8NWRK)gUSHKOv1Dje)k9biPpwncqAljNFPbbttGSSGZlVeG2egv8C7qBEci2PchN3ikK4OUEFWUUEKkzJI4M4RtJi9m6fAYwMDykmCPztSrsJujPg3GwgKri4dDejDFo7)U))9]] )
