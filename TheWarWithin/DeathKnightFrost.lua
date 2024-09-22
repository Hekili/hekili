-- DeathKnightFrost.lua
-- July 2024

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

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
    abomination_limb            = { 76049, 383269, 1 }, -- Sprout an additional limb, dealing 33,252 Shadow damage over 12 sec to all nearby enemies. Deals reduced damage beyond 5 targets. Every 1 sec, an enemy is pulled to your location if they are further than 8 yds from you. The same enemy can only be pulled once every 4 sec.
    antimagic_barrier           = { 76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by 20 sec and increases its duration and amount absorbed by 40%.
    antimagic_zone              = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 756,426 damage.
    asphyxiate                  = { 76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation                = { 76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and its cooldown is reduced by 30 sec.
    blinding_sleet              = { 76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_draw                  = { 76056, 374598, 1 }, -- When you fall below 30% health you drain 10,807 health from nearby enemies, the damage you take is reduced by 10% and your Death Strike cost is reduced by 10 for 8 sec. Can only occur every 2 min.
    blood_scent                 = { 76078, 374030, 1 }, -- Increases Leech by 3%.
    brittle                     = { 76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    cleaving_strikes            = { 76073, 316916, 1 }, -- Obliterate hits up to 2 additional enemies while you remain in Death and Decay. When leaving your Death and Decay you retain its bonus effects for 4 sec.
    coldthirst                  = { 76083, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants 10 Runic Power and reduces its cooldown by 3 sec.
    control_undead              = { 76059, 111673, 1 }, -- Dominates the target undead creature up to level 71, forcing it to do your bidding for 5 min.
    death_pact                  = { 76075, 48743 , 1 }, -- Create a death pact that heals you for 50% of your maximum health, but absorbs incoming healing equal to 30% of your max health for 15 sec.
    death_strike                = { 76071, 49998 , 1 }, -- Focuses dark power into a strike with both weapons, that deals a total of 5,222 Physical damage and heals you for 40.00% of all damage taken in the last 5 sec, minimum 11.2% of maximum health.
    deaths_echo                 = { 102007, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have 1 additional charge.
    deaths_reach                = { 102006, 276079, 1 }, -- Increases the range of Death Grip by 10 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    enfeeble                    = { 76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by 30% and the damage they deal to you by 15% for 6 sec.
    gloom_ward                  = { 76052, 391571, 1 }, -- Absorbs are 15% more effective on you.
    grip_of_the_dead            = { 76057, 273952, 1 }, -- Death and Decay reduces the movement speed of enemies within its area by 90%, decaying by 10% every sec.
    ice_prison                  = { 76086, 454786, 1 }, -- Chains of Ice now also roots enemies for 4 sec but its cooldown is increased to 12 sec.
    icebound_fortitude          = { 76081, 48792 , 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 30% for 8 sec.
    icy_talons                  = { 76085, 194878, 1 }, -- Your Runic Power spending abilities increase your melee attack speed by 6% for 10 sec, stacking up to 5 times.
    improved_death_strike       = { 76067, 374277, 1 }, -- Death Strike's cost is reduced by 10, and its healing is increased by 60%.
    insidious_chill             = { 76051, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by 5% for 30 sec, stacking up to 4 times.
    march_of_darkness           = { 76074, 391546, 1 }, -- Death's Advance grants an additional 25% movement speed over the first 3 sec.
    mind_freeze                 = { 76084, 47528 , 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    null_magic                  = { 102008, 454842, 1 }, -- Magic damage taken is reduced by 10% and the duration of harmful Magic effects against you are reduced by 35%.
    osmosis                     = { 76088, 454835, 1 }, -- Anti-Magic Shell increases healing received by 15%.
    permafrost                  = { 76066, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to 40% of the damage dealt.
    proliferating_chill         = { 101708, 373930, 1 }, -- Chains of Ice affects 1 additional nearby enemy.
    raise_dead                  = { 76072, 46585 , 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts 1 min.
    rune_mastery                = { 76079, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by 3% for 8 sec.
    runic_attenuation           = { 76045, 207104, 1 }, -- Auto attacks have a chance to generate 3 Runic Power.
    runic_protection            = { 76055, 454788, 1 }, -- Your chance to be critically struck is reduced by 3% and your Armor is increased by 6%.
    sacrificial_pact            = { 76060, 327574, 1 }, -- Sacrifice your ghoul to deal 6,755 Shadow damage to all nearby enemies and heal for 25% of your maximum health. Deals reduced damage beyond 8 targets.
    soul_reaper                 = { 76063, 343294, 1 }, -- Strike an enemy for 6,533 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 29,977 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    subduing_grasp              = { 76080, 454822, 1 }, -- When you pull an enemy, the damage they deal to you is reduced by 6% for 6 sec.
    suppression                 = { 76087, 374049, 1 }, -- Damage taken from area of effect attacks reduced by 3%. When suffering a loss of control effect, this bonus is increased by an additional 6% for 6 sec.
    unholy_bond                 = { 76076, 374261, 1 }, -- Increases the effectiveness of your Runeforge effects by 20%.
    unholy_endurance            = { 76058, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground               = { 76069, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    unyielding_will             = { 76050, 457574, 1 }, -- Anti-Magic Shell's cooldown is increased by 20 sec and it now also removes all harmful magic effects when activated.
    vestigial_shell             = { 76053, 454851, 1 }, -- Casting Anti-Magic Shell grants 2 nearby allies a Lesser Anti-Magic Shell that Absorbs up to 37,527 magic damage and reduces the duration of harmful Magic effects against them by 50%.
    veteran_of_the_third_war    = { 76068, 48263 , 1 }, -- Stamina increased by 20%.
    will_of_the_necropolis      = { 76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk                 = { 76077, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.

    -- Deathbringer
    absolute_zero               = { 102009, 377047, 1 }, -- Frostwyrm's Fury has 50% reduced cooldown and Freezes all enemies hit for 3 sec.
    arctic_assault              = { 76091, 456230, 1 }, -- Consuming Killing Machine fires a Glacial Advance through your target.
    avalanche                   = { 76105, 207142, 1 }, -- Casting Howling Blast with Rime active causes jagged icicles to fall on enemies nearby your target, applying Razorice and dealing 3,271 Frost damage.
    biting_cold                 = { 76111, 377056, 1 }, -- Remorseless Winter damage is increased by 35%. The first time Remorseless Winter deals damage to 3 different enemies, you gain Rime.
    bonegrinder                 = { 76122, 377098, 2 }, -- Consuming Killing Machine grants 1% critical strike chance for 10 sec, stacking up to 5 times. At 5 stacks your next Killing Machine consumes the stacks and grants you 10% increased Frost damage for 10 sec.
    breath_of_sindragosa        = { 76093, 152279, 1 }, -- Continuously deal 16,653 Frost damage every 1 sec to enemies in a cone in front of you, until your Runic Power is exhausted. Deals reduced damage to secondary targets. Generates 2 Runes at the start and end.
    chill_streak                = { 76098, 305392, 1 }, -- Deals 16,751 Frost damage to the target and reduces their movement speed by 70% for 4 sec. Chill Streak bounces up to 9 times between closest targets within 6 yards.
    cold_heart                  = { 76035, 281208, 1 }, -- Every 2 sec, gain a stack of Cold Heart, causing your next Chains of Ice to deal 1,635 Frost damage. Stacks up to 20 times.
    cryogenic_chamber           = { 76109, 456237, 1 }, -- Each time Frost Fever deals damage, 15% of the damage dealt is gathered into the next cast of Remorseless Winter, up to 20 times.
    empower_rune_weapon         = { 76110, 47568 , 1 }, -- Empower your rune weapon, gaining 15% Haste and generating 1 Rune and 5 Runic Power instantly and every 5 sec for 20 sec.
    enduring_chill              = { 76097, 377376, 1 }, -- Chill Streak's bounce range is increased by 2 yds and each time Chill Streak bounces it has a 25% chance to increase the maximum number of bounces by 1.
    enduring_strength           = { 76100, 377190, 1 }, -- When Pillar of Frost expires, your Strength is increased by 20% for 6 sec. This effect lasts 2 sec longer for each Obliterate and Frostscythe critical strike during Pillar of Frost.
    everfrost                   = { 76113, 376938, 1 }, -- Remorseless Winter deals 6% increased damage to enemies it hits, stacking up to 10 times.
    frigid_executioner          = { 76120, 377073, 1 }, -- Obliterate deals 15% increased damage and has a 15% chance to refund 2 runes.
    frost_strike                = { 76115, 49143 , 1 }, -- Chill your weapon with icy power and quickly strike the enemy, dealing 17,046 Frost damage.
    frostscythe                 = { 76096, 207230, 1 }, -- A sweeping attack that strikes all enemies in front of you for 12,442 Frost damage. This attack always critically strikes and critical strikes with Frostscythe deal 4 times normal damage. Deals reduced damage beyond 5 targets. Consuming Killing Machine reduces the cooldown of Frostscythe by 1.0 sec.
    frostwhelps_aid             = { 76106, 377226, 1 }, -- Pillar of Frost summons a Frostwhelp who breathes on all enemies within 40 yards in front of you for 6,114 Frost damage. Each unique enemy hit by Frostwhelp's Aid grants you 8% Mastery for 15 sec, up to 0%.
    frostwyrms_fury             = { 101931, 279302, 1 }, -- Summons a frostwyrm who breathes on all enemies within 40 yd in front of you, dealing 53,973 Frost damage and slowing movement speed by 50% for 10 sec.
    gathering_storm             = { 76099, 194912, 1 }, -- Each Rune spent during Remorseless Winter increases its damage by 10%, and extends its duration by 0.5 sec.
    glacial_advance             = { 76092, 194913, 1 }, -- Summon glacial spikes from the ground that advance forward, each dealing 9,463 Frost damage and applying Razorice to enemies near their eruption point.
    horn_of_winter              = { 76089, 57330 , 1 }, -- Blow the Horn of Winter, gaining 2 Runes and generating 25 Runic Power.
    howling_blast               = { 76114, 49184 , 1 }, -- Blast the target with a frigid wind, dealing 3,143 Frost damage to that foe, and reduced damage to all other enemies within 10 yards, infecting all targets with Frost Fever.  Frost Fever A disease that deals 37,594 Frost damage over 24 sec and has a chance to grant the Death Knight 5 Runic Power each time it deals damage.
    hyperpyrexia                = { 76108, 456238, 1 }, -- Your Runic Power spending abilities have a chance to additionally deal 45% of the damage dealt over 4 sec.
    icebreaker                  = { 76033, 392950, 2 }, -- When empowered by Rime, Howling Blast deals 30% increased damage to your primary target.
    icecap                      = { 101930, 207126, 1 }, -- Reduces Pillar of Frost cooldown by 15 sec.
    icy_death_torrent           = { 101933, 435010, 1 }, -- Your auto attack critical strikes have a chance to send out a sleet of ice dealing 22,835 Frost damage to enemies in front of you.
    improved_frost_strike       = { 76103, 316803, 2 }, -- Increases Frost Strike damage by 10%.
    improved_obliterate         = { 76119, 317198, 1 }, -- Increases Obliterate damage by 10%.
    improved_rime               = { 76112, 316838, 1 }, -- Increases Howling Blast damage done by an additional 75%.
    inexorable_assault          = { 76037, 253593, 1 }, -- Gain Inexorable Assault every 8 sec, stacking up to 5 times. Obliterate consumes a stack to deal an additional 3,832 Frost damage.
    killing_machine             = { 76117, 51128 , 1 }, -- Your auto attack critical strikes have a chance to make your next Obliterate deal Frost damage and critically strike.
    murderous_efficiency        = { 76121, 207061, 1 }, -- Consuming the Killing Machine effect has a 25% chance to grant you 1 Rune.
    obliterate                  = { 76116, 49020 , 1 }, -- A brutal attack that deals 18,101 Physical damage.
    obliteration                = { 76123, 281238, 1 }, -- While Pillar of Frost is active, Frost Strike, Soul Reaper, and Howling Blast always grant Killing Machine and have a 30% chance to generate a Rune. to deal additional damage.
    piercing_chill              = { 76097, 377351, 1 }, -- Enemies suffer 12% increased damage from Chill Streak each time they are struck by it.
    pillar_of_frost             = { 101929, 51271 , 1 }, -- The power of frost increases your Strength by 30% for 12 sec.
    rage_of_the_frozen_champion = { 76120, 377076, 1 }, -- Obliterate has a 15% increased chance to trigger Rime and Howling Blast generates 6 Runic Power while Rime is active.
    runic_command               = { 76102, 376251, 2 }, -- Increases your maximum Runic Power by 5.
    shattered_frost             = { 76094, 455993, 1 }, -- When Frost Strike consumes 5 Razorice stacks, it deals 65% of the damage dealt to nearby enemies. Deals reduced damage beyond 8 targets.
    shattering_blade            = { 76095, 207057, 1 }, -- When Frost Strike damages an enemy with 5 stacks of Razorice it will consume them to deal an additional 125% damage.
    smothering_offense          = { 76101, 435005, 1 }, -- Your auto attack damage is increased by 10%. This amount is increased for each stack of Icy Talons you have and it can stack up to 2 additional times.
    the_long_winter             = { 101932, 456240, 1 }, -- While Pillar of Frost is active your auto-attack critical strikes increase its duration by 2 sec, up to a maximum of 6 sec.
    unleashed_frenzy            = { 76118, 376905, 1 }, -- Damaging an enemy with a Runic Power ability increases your Strength by 2% for 10 sec, stacks up to 3 times.

    -- Rider of the Apocalypse
    a_feast_of_souls            = { 95042, 444072, 1 }, -- While you have 2 or more Horsemen aiding you, your Runic Power spending abilities deal 30% increased damage.
    apocalypse_now              = { 95041, 444040, 1 }, -- Army of the Dead and Frostwyrm's Fury call upon all 4 Horsemen to aid you for 20 sec.
    death_charge                = { 95060, 444010, 1 }, -- Call upon your Death Charger to break free of movement impairment effects. For 10 sec, while upon your Death Charger your movement speed is increased by 100%, you cannot be slowed, and you are immune to forced movement effects and knockbacks.
    fury_of_the_horsemen        = { 95042, 444069, 1 }, -- Every 50 Runic Power you spend extends the duration of the Horsemen's aid in combat by 1 sec, up to 5 sec.
    horsemens_aid               = { 95037, 444074, 1 }, -- While at your aid, the Horsemen will occasionally cast Anti-Magic Shell on you and themselves at 80% effectiveness. You may only benefit from this effect every 45 sec.
    hungering_thirst            = { 95044, 444037, 1 }, -- The damage of your diseases and Frost Strike are increased by 15%.
    mawsworn_menace             = { 95054, 444099, 1 }, -- Obliterate deals 10% increased damage and the cooldown of your Death and Decay is reduced by 10 sec.
    mograines_might             = { 95067, 444047, 1 }, -- Your damage is increased by 5% and you gain the benefits of your Death and Decay while inside Mograine's Death and Decay.
    nazgrims_conquest           = { 95059, 444052, 1 }, -- If an enemy dies while Nazgrim is active, the strength of Apocalyptic Conquest is increased by 3%. Additionally, each Rune you spend increase its value by 1%.
    on_a_paler_horse            = { 95060, 444008, 1 }, -- While outdoors you are able to mount your Acherus Deathcharger in combat.
    pact_of_the_apocalypse      = { 95037, 444083, 1 }, -- When you take damage, 5% of the damage is redirected to each active horsemen.
    riders_champion             = { 95066, 444005, 1, "rider_of_the_apocalypse" }, -- Spending Runes has a chance to call forth the aid of a Horsemen for 10 sec. Mograine Casts Death and Decay at his location that follows his position. Whitemane Casts Undeath on your target dealing 1,122 Shadowfrost damage per stack every 3 sec, for 24 sec. Each time Undeath deals damage it gains a stack. Cannot be Refreshed. Trollbane Casts Chains of Ice on your target slowing their movement speed by 40% and increasing the damage they take from you by 5% for 8 sec. Nazgrim While Nazgrim is active you gain Apocalyptic Conquest, increasing your Strength by 5%.
    trollbanes_icy_fury         = { 95063, 444097, 1 }, -- Obliterate shatters Trollbane's Chains of Ice when hit, dealing 21,615 Shadowfrost damage to nearby enemies, and slowing them by 40% for 4 sec. Deals reduced damage beyond 8 targets.
    whitemanes_famine           = { 95047, 444033, 1 }, -- When Obliterate damages an enemy affected by Undeath it gains 1 stack and infects another nearby enemy.

    -- Deathbringer
    bind_in_darkness            = { 95043, 440031, 1 }, -- Shadowfrost damage applies 2 stacks to Reaper's Mark and 4 stacks when it is a critical strike. Additionally, Rime empowered Howling Blast deals Shadowfrost damage.
    blood_fever                 = { 95058, 440002, 1 }, -- Your Frost Fever has a chance to deal 30% increased damage as Shadowfrost.
    dark_talons                 = { 95057, 436687, 1 }, -- Consuming Killing Machine or Rime has a 25% chance to increase the maximum stacks of an active Icy Talons by 1, up to 2 times. While Icy Talons is active, your Runic Power spending abilities also count as Shadowfrost damage.
    deaths_messenger            = { 95049, 437122, 1 }, -- Reduces the cooldowns of Lichborne and Raise Dead by 30 sec.
    expelling_shield            = { 95049, 439948, 1 }, -- When an enemy deals direct damage to your Anti-Magic Shell, their cast speed is reduced by 10% for 6 sec.
    exterminate                 = { 95068, 441378, 1 }, -- After Reaper's Mark explodes, your next Obliterate costs no Rune and summons 2 scythes to strike your enemies. The first scythe strikes your target for 34,450 Shadowfrost damage and has a 20% chance to apply Reaper's Mark, the second scythe strikes all enemies around your target for 22,048 Shadowfrost damage. Deals reduced damage beyond 8 targets.
    grim_reaper                 = { 95034, 434905, 1 }, -- Reaper's Mark explosion deals up to 30% increased damage based on your target's missing health, and applies Soul Reaper to targets below 35% health.
    pact_of_the_deathbringer    = { 95035, 440476, 1 }, -- When you suffer a damaging effect equal to 25% of your maximum health, you instantly cast Death Pact at 50% effectiveness. May only occur every 2 min. When a Reaper's Mark explodes, the cooldowns of this effect and Death Pact are reduced by 5 sec.
    painful_death               = { 95032, 443564, 1 }, -- Reaper's Mark deals 10% increased damage and Exterminate empowers an additional Obliterate, but now reduces its cost by 1 Rune. Additionally, Exterminate now has a 30% chance to apply Reaper's Mark.
    reapers_mark                = { 95062, 439843, 1, "deathbringer" }, -- Viciously slice into the soul of your enemy, dealing 13,509 Shadowfrost damage and applying Reaper's Mark. Each time you deal Shadow or Frost damage, add a stack of Reaper's Mark. After 12 sec or reaching 40 stacks, the mark explodes, dealing 2,296 damage per stack. Reaper's Mark travels to an unmarked enemy nearby if the target dies, or explodes below 35% health when there are no enemies to travel to. This explosion cannot occur again on a target for 3 min.
    rune_carved_plates          = { 95035, 440282, 1 }, -- Each Rune spent reduces the magic damage you take by 2% and each Rune generated reduces the physical damage you take by 2% for 5 sec, up to 5 times.
    soul_rupture                = { 95061, 437161, 1 }, -- When Reaper's Mark explodes, it deals 30% of the damage dealt damage to nearby enemies. Enemies hit by this effect deal 5% reduced physical damage to you for 10 sec.
    swift_end                   = { 95032, 443560, 1 }, -- Reaper's Mark's cost is reduced by 1 Rune and its cooldown is reduced by 30 sec.
    wave_of_souls               = { 95036, 439851, 1 }, -- Reaper's Mark sends forth bursts of Shadowfrost energy and back, dealing 8,933 Shadowfrost damage both ways to all enemies caught in its path. Wave of Souls critical strikes cause enemies to take 5% increased Shadowfrost damage for 15 sec, stacking up to 2 times, and it is always a critical strike on its way back.
    wither_away                 = { 95057, 441894, 1 }, -- Frost Fever deals its damage in half the duration and the second scythe of Exterminate applies Frost Fever.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bitter_chill      = 5435, -- (356470) Chains of Ice reduces the target's Haste by 8%. Frost Strike refreshes the duration of Chains of Ice.
    bloodforged_armor = 5586, -- (410301) Death Strike reduces all Physical damage taken by 20% for 3 sec.
    dark_simulacrum   = 3512, -- (77606) Places a dark ward on an enemy player that persists for 12 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    dead_of_winter    = 3743, -- (287250) After your Remorseless Winter deals damage 5 times to a target, they are stunned for 4 sec. Remorseless Winter's cooldown is increased by 10 sec.
    deathchill        = 701 , -- (204080) Your Remorseless Winter and Chains of Ice apply Deathchill, rooting the target in place for 4 sec. Remorseless Winter All targets within 8 yards are afflicted with Deathchill when Remorseless Winter is cast. Chains of Ice When you Chains of Ice a target already afflicted by your Chains of Ice they will be afflicted by Deathchill.
    delirium          = 702 , -- (233396) Howling Blast applies Delirium, reducing the cooldown recovery rate of movement enhancing abilities by 50% for 12 sec.
    necrotic_aura     = 5512, -- (199642) All enemies within 8 yards take 4% increased magical damage.
    rot_and_wither    = 5510, -- (202727) Your Death and Decay rots enemies each time it deals damage, absorbing healing equal to 100% of damage dealt.
    shroud_of_winter  = 3439, -- (199719) Enemies within 8 yards of you become shrouded in winter, reducing the range of their spells and abilities by 30%.
    spellwarden       = 5591, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by 10 sec.
    strangulate       = 5429, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for 5 sec.
} )


-- Auras
spec:RegisterAuras( {
    -- Your Runic Power spending abilities deal $w1% increased damage.
    a_feast_of_souls = {
        id = 440861,
        duration = 3600,
        max_stack = 1,
    },
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
        id = 108194,
        duration = 4,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Next Howling Blast deals Shadowfrost damage.
    bind_in_darkness = {
        id = 443532,
        duration = 3600,
        max_stack = 1,
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
        duration = function() return 24 * ( talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.wither_away.enabled and 0.5 or 1 ) end,
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
    bonegrinder_crit = {
        id = 377101,
        duration = 10,
        max_stack = 5
    },
    -- Talent: Frost damage increased by $s1%.
    -- https://wowhead.com/beta/spell=377103
    bonegrinder_frost = {
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
    cryogenic_chamber = {
        id = 456370,
        duration = 30,
        max_stack = 20
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
    -- [444347] $@spelldesc444010
    death_charge = {
        id = 444347,
        duration = 10,
        max_stack = 1,
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
        duration = function() return 24 * ( talent.wither_away.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.wither_away.enabled and 0.5 or 1 ) end,
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
    -- Rooted.
    ice_prison = {
        id = 454787,
        duration = 4.0,
        max_stack = 1,
    },
    -- Talent: Damage taken reduced by $w3%.  Immune to Stun effects.
    -- https://wowhead.com/beta/spell=48792
    icebound_fortitude = {
        id = 48792,
        duration = 8,
        tick_time = 1.0,
        max_stack = 1
    },
    icy_talons = {
        id = 194879,
        duration = 6,
        max_stack = function() return talent.smothering_offense.enabled and 5 or 3 end,
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
    -- Absorbing up to $w1 magic damage.; Duration of harmful magic effects reduced by $s2%.
    lesser_antimagic_shell = {
        id = 454863,
        duration = function() return 5.0 * ( talent.antimagic_barrier.enabled and 1.4 or 1 ) end,
        max_stack = 1,

        -- Affected by:
        -- fatal_fixation[405166] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- antimagic_barrier[205727] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- antimagic_barrier[205727] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- osmosis[454835] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- unyielding_will[457574] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- spellwarden[410320] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
    painful_death = {
        id = 447954,
        duration = 3600,
        max_stack = 1,
        copy = "exterminate_painful_death"
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
    -- You are a prey for the Deathbringer... This effect will explode for $436304s1 Shadowfrost damage for each stack.
    reapers_mark = {
        id = 434765,
        duration = 12.0,
        tick_time = 1.0,
        max_stack = 40,
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
    -- Magical damage taken reduced by $w1%.
    rune_carved_plates = {
        id = 440290,
        duration = 5.0,
        max_stack = 1,
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
    -- https://wowhead.com/beta/spell=448229
    soul_reaper = {
        id = 448229,
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
spec:RegisterGear( "tier30", 202464, 202462, 202461, 202460, 202459, 217223, 217225, 217221, 217222, 217224 )
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
        cooldown = function() return 60 - ( talent.antimagic_barrier.enabled and 15 or 0 ) - ( talent.unyielding_will.enabled and -20 or 0 ) - ( pvptalent.spellwarden.enabled and 10 or 0 ) end,
        gcd = "off",

        startsCombat = false,

        toggle = function()
            if settings.ams_usage == "defensives" or settings.ams_usage == "both" then return "defensives" end
        end,

        usable = function()
            if settings.ams_usage == "damage" or settings.ams_usage == "both" then return incoming_magic_3s > 0, "settings require magic damage taken in the past 3 seconds" end
        end,

        handler = function ()
            applyBuff( "antimagic_shell" )
            if talent.unyielding_will.enabled then removeBuff( "dispellable_magic" ) end
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
        cooldown = function() return 0 + ( talent.ice_prison.enabled and 12 or 0 ) end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "chains_of_ice" )
            if talent.ice_prison.enabled then applyDebuff( "target", "ice_prison" ) end
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

    -- Corrupts the targeted ground, causing ${$341340m1*11} Shadow damage over $d to targets within the area.$?!c2[; While you remain within the area, your ][]$?s223829&!c2[Necrotic Strike and ][]$?c1[Heart Strike will hit up to $188290m3 additional targets.]?s207311&!c2[Clawing Shadows will hit up to ${$55090s4-1} enemies near the target.]?!c2[Scourge Strike will hit up to ${$55090s4-1} enemies near the target.][; While you remain within the area, your Obliterate will hit up to $316916M2 additional $Ltarget:targets;.]
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

        spend = function ()
            if buff.dark_succor.up then return 0 end
            return ( talent.improved_death_strike.enabled and 40 or 50 ) - ( buff.blood_draw.up and 10 or 0 )
        end,
        spendType = "runic_power",

        talent = "death_strike",
        startsCombat = true,

        handler = function ()
            removeBuff( "dark_succor" )
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

        talent = "empower_rune_weapon",
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
            if death_knight.runeforge.razorice and debuff.razorice.stack == 5 then return "razorice" end
        end,

        handler = function ()
            applyDebuff( "target", "razorice", 20, 2 )

            if talent.obliteration.enabled and buff.pillar_of_frost.up then addStack( "killing_machine" ) end
            removeBuff( "eradicating_blow" )

            if talent.shattering_blade.enabled then
                if debuff.razorice.stack == 5 then removeDebuff( "target", "razorice" )
                elseif debuff.razorice.stack > 5 then applyDebuff( "target", "razorice", nil, debuff.razorice.stack - 5 ) end
            end

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

    -- A sweeping attack that strikes all enemies in front of you for $s2 Frost damage. This attack always critically strikes and critical strikes with Frostscythe deal $s3 times normal damage. Deals reduced damage beyond $s5 targets. ; Consuming Killing Machine reduces the cooldown of Frostscythe by ${$s1/1000}.1 sec.
    frostscythe = {
        id = 207230,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 2,
        spendType = "runes",

        talent = "frostscythe",
        startsCombat = true,

        range = 7,

        handler = function ()
            removeStack( "inexorable_assault" )

            if buff.killing_machine.up and talent.bonegrinder.enabled then
                if buff.bonegrinder_crit.stack_pct == 100 then
                    removeBuff( "bonegrinder_crit" )
                    applyBuff( "bonegrinder_frost" )
                else
                    addStack( "bonegrinder_crit" )
                end
                removeBuff( "killing_machine" )
            end
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
        cooldown = function () return 120 - ( azerite.cold_hearted.enabled and 15 or 0 ) + ( conduit.chilled_resilience.mod * 0.001 ) end,
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

        spend = function() return buff.painful_death.up and 1 or 2 end,
        spendType = "runes",

        talent = "obliterate",
        startsCombat = true,

        cycle = function ()
            if debuff.mark_of_fyralath.up then return "mark_of_fyralath" end
            if death_knight.runeforge.razorice and debuff.razorice.stack == 5 then return "razorice" end
        end,

        handler = function ()
            removeStack( "inexorable_assault" )
            removeBuff( "painful_death" )

            if buff.killing_machine.up and talent.bonegrinder.enabled then
                if buff.bonegrinder_crit.stack_pct == 100 then
                    removeBuff( "bonegrinder_crit" )
                    applyBuff( "bonegrinder_frost" )
                else
                    addStack( "bonegrinder_crit" )
                end
                removeBuff( "killing_machine" )
            end

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

    -- The power of frost increases your Strength by $s1% for $d.
    pillar_of_frost = {
        id = 51271,
        cast = 0,
        cooldown = function() return 60 - ( talent.icecap.enabled and 15 or 0 ) end,
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
        cooldown = function() return 120 - ( talent.deaths_messenger.enabled and 30 or 0 ) end,
        gcd = "off",

        talent = "raise_dead",
        startsCombat = true,

        usable = function () return not pet.alive, "cannot have an active pet" end,

        handler = function ()
            summonPet( "ghoul" )
        end,
    },

    -- Viciously slice into the soul of your enemy, dealing $?a137008[$s1][$s4] Shadowfrost damage and applying Reaper's Mark.; Each time you deal Shadow or Frost damage,
    reapers_mark = {
        id = 439843,
        cast = 0.0,
        cooldown = function() return 60.0 - ( talent.swift_end.enabled and 30 or 0 ) end,
        gcd = "spell",

        spend = function() return 2 - ( talent.swift_end.enabled and 1 or 0 ) end,
        spendType = 'runes',

        talent = "reapers_mark",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 0.8, 'target':
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 434765, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'resource': runic_power, }
        -- #3: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 1.5, 'target':

        -- Affected by:
        -- painful_death[443564] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- swift_end[443560] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- swift_end[443560] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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
            removeBuff( "cryogenic_chamber" )

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
        cooldown = 45,
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
    nameplateRange = 10,
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


spec:RegisterPack( "Frost DK", 20240921, [[Hekili:S3t)ZTTnY(3sM3efR8HSeTDsthBptV(ANR9131oX3h)MLOLOK4zjs9iPIRZ4H)T)waWpaa3fauIso9UB6mnjcGl2DXI9lSa42r3(xV9Mz(zb3(x8g6D(Wp6nAWW3F2hp)IBVj7Xnb3EZg)P37Va(lr(RH))pMeNMLp5)()H1YJRI9NXGqA82KPqRlZY2K(TNE6IWSLBVBW041NMgUE7k)SW4OPj(ZZy)7PNE7n3TnCv2pfD7DOd)zWW7VnBzCYT3Ct46VhGC4SzbIUhKo92ByD)Dd)47gD(BZNa)P3OVnFcRR5t2UHbX8Fo)NR60qOXFm83ZNSjoEvy0IXjBJcsR7Y38oV3ZGd8NFJaEdlG7Wlk(ZYF)JIXP5W8H3D2qbme4e8NxuaZZP)gVZG2(RldYN8p8tG)hW4cJU9MvHPzPColGTRcgN5NSiid(H)cFgliY)UvbZU9pbSPPmE7T3mNnXmonlj8(abtkjCJOPB4WaggoqYN8P4mFrlqFYcsc9HjB)vbrzd8hppWhGt88XWC6Q0bfJu(KE5tMfC325ZhK4)L4KWPbdsZazJ8jxLp5cE7fWiDPFgdQaB(Uv(ZcuGbhcngLTBUndeb0iTASJ)v3hUIp3T2FkWJKhEV8jp9ubSd(D4Bwhgb8zaS4nmEJFy08TRgplWpBjB0RyJX3TInOmrsaJoJeJojFYlQO47syWHtoHrZs8xeN6xt1mm4Z(Wxb)ZbzjBdgx0)PGW4S4hIYNCD(KY)XaqOpIbQhcJGXAWSTj8jR8jVlFYiGr3NZhR6(gGR4NW(aUeWGKG1aXLMp5sPrLtvJlf(ZczRKlPy1XJr1NBIQ3BHG(cocak2IqoE6X)YA(jaxgl6EG8R)mcrDaFVGeFRyajajpMH4PYe(dRkWV0mgCEF7K)ysxc0UAyuuVqju9bYHHauHtHPUhcskhoUu747JcxSeMVHHAEmSWUAkH3n6zQl5ZuSPa9oil6Sy6SbR9bnMVoFYzkC)fR8Ng6VAS)Sp7hnLtrFZErrNi1NKnIzPkzKx4GevpUOujmhmlyE40WmHK1qUaNbHNpAEsNj4uot3Y18fDeAkG1TSLbSLOFjiA80L(R3ayJA)RwsJc6QjN(gKGhnCVMjEbNgzJZ4L(rZg4TuHsmSMMM)os3GLvuIELZiAlewipd4hToENMPfSnUScAhr0sGBdOhMcroCfR3HjeWE1u)hvSx5h944zrZ4ucTEBMsJ4SbcAFEWNHvjzHtVhysMeMO1RQHOOR(aBAExSlRB6sBLMmZnIwFVRORjAFO0KuYu)iWjU4KeaM3Y(VBMcKW4Lb(jg9Qd0ual6zdF4uD36(Eac5t(ZCqiH7ZzMfgJQlVxdZUm(DPygH9nXSNQsHsh5QjIsRlxdocCUaUo)j5t(Mk3c6qmHd2wIiJkTxy0D0AXJk9tkAZlhcDFZkOddSo24lOuuaqzHg6)O8jVH)xkWm(h8WJjRthpFBYJkix16h9obc7ZEuWbKMo2gTmE1JmDMbrl4(lxtg6THIH9PeOn6ITdCzcpHM7VAfZmBY2uWmvIIYuI5e7(tFTqLI0SJXPqsoxfBL4ZpZm)YOsEB8lANhXyz2jYUGPkROSb1sBcYbs1eQzzo889Bo8JAE0zAD8zw51NBuIitYljwhmynrYBQBM(40Q8kKY(ehd35K9joBr3myH61CRs91S09Rs0x(KVdOMphiLgJDo1bvoW4UY2EYbR4sqL0636EmJ2HrveFH)4njHqqFzpAmUoDDn45A65HIqKGr0xydJ37Szu3hJPoJpkyP9cLk0DmfD9RTvR4Gwp5d4YTQwvSOoGo4c(kzmSqpHbuYGQPEct(fptgkP6OVmI(mK6KQCzqNOdzxYfORpxj34GOG1HbfEFuMkdmoQEAmSj4JehabUT3lr6xUs2A(hucuutwqngrD2ZvC2tZCvemRqbtn2GZ)mK5eb5lYdKPWLDlZ8oNYINDoIUnvhwK6cjHBfcfd0TDUNCuIrH2J6QviNzmpcoKNKrCsxHvWaRPCeyj)eKA9PeqbT6IKzCW8quAdz0CG7pXh4266gIJwnzJxRQxTiFn8Va0JLTmjiDjprjVto6yNsklO)(9YbdVtzrJ2)phtI2zdL0ei8WEnVx8CLo(Ha)nasx6BTUiwdgZMXt57GRWt7xJhLU99eANCjPbk2iJzU4thIasbXn7rL5cWOCCsAWQG0ujkX4QkD)mRCKPNQygiaSzLFuuzBfIvfXkUijEB0mhstOsK0gJOvXaTm5QmVjLny6DzYcxRHem9U7OlS9EJ6ZCBNwmQaZpoWvTxk6F(U4FqO8Hf)4VeQ6HRj3BlMtaHs)pZAwyZbX3EKauq0T5I32KQyWwB0Xwi50ZE7WxpznTKUDG50YL8Kht4qcTDA3KFidoCpDOzpImbNq5AOWKPRXDdrYTJt94OIX1(Uy96R7TaIwLen9yqfxwTY1um9uXG0zAqwnek7n7VTABrrz00lEbdmXpC2yqLalxdZMLoimQkP0fENO3JGFNvgrnZN2FVcjzyWyrLDjzsdt1v7X9RVQu44eJyh3NaI261Sj5ChlMFRPbwhksSiM2r70aPnEfPsPHrdbsdIMXwynDwkMkl7iGSQmeVoaz7PJLDhwkapFaeG(RLb65bVS9KPSV2pn1F7QmxQSRlBYHLY5jIgv70xLJsGf10LCRcbrF5rDJhC0PrNmKLfPnRs7JQPL6KXuvNrpc67wfhLIo(sn7Yil196X8eEFe7mNWF7s7IRJHGp4MpJNppikvnJjiFXm)K7BGU9ltkK0u0M6jiDNDDEcspbTnC4HEFvSTZmOFUY2SnSsJMry1xVBwrAtro5gyQ7fgSm6CtT(qcgO8KyP9niS0GP3JzVVyQmCUSzlhRHORTV3uAMm(X4ewD8gofORnBsIb3Kbormt1rgF7EaNbYyLXkR4cbkKLyvXpLc)H)DHWeiNlmnM1oiYxJcSU5Nv8911lm83xgVLf6oSCkrmAmhxatcbIcooDq(KVhqhghNbGrxadqyubKGjMXcX8XSYPfgp)vRgiZKX8UGCPX4GvPstm08TIfsonvG5JL0elgQuI8y10jDOzNDrPBAYETzJygh87BcMMX4VSKynuLvCMSzZtAf0Etz6Spvobe8)PawceTQBVw63RPR3uMF)(LDA0WHy(15ilTyMYbEQIpHfHWBXPvegONgd0ce2nMMohRSKiL5xnY(TD7evssviTqGKRoSGdkhUiP5Gop0GH5owJ0Qs3A0HQqqTmIAHkIL3F78oNi2EUisGKHpzeVW7K4uHR0n349ZQY(KtQR0DGICsLq9JTzKDCIOkgwSTTW(0HIeiz(kCmZhyw9ppxAxaDBOA0l3hnpn)bL3NfSDvXodApsQCHnNbSzpis5XE8LOka8usaIOBwKSsEO2lbPzoLzkLGGNj8ibc(sGMhn)eljajB3OK)nr2pguep0u)0my4isMNDddNpSi6kPnDEEyceyP)60XmOZzNIvQTxvOtD0UHjzNb9JaKXFbqnqiuG3s1PtrjlZkDYuEi1s0PYeW)lSIpJhcDXHk7hz578T5t(PPpYoSsSaDaj8iGi(BLb1X6llQo3YzQPLi6SB60UBtx3jQ6pBQAJxtLvHjse4e9w6LxvrQ0za9ZOjGSh6M67GnzxLSEHB0KPcJ3r7oxB2qhDYCDBdKAfBZz2YZmDtVtxTKUDvPKdsw2LymBC0ib32uItMT1)TzvJl58)WWfDMl9CXgABfv1s2WrznfkLb2H3KemnE9D(ON9e0elbKB09GNrzJgS0pD82urwGlna2QmNzLGzaSE8QMKRDg5LgS3w3RRkJfSnolDInPkfSWmAwHa6BaZpWCS2pJjM4xbK06rgCcAw4NdNXWP7anZcAKL2miiogvcDOi)JLr9lYaj87XWpjqCr)Rr9xjncda3SGgdZy)i3n)8jWeB(KOyw(1ylC4hdGKGSTjaPmInIRy5YR8xgo4cTKPXPIXJgN(y0uBPrd(6QWlgzy)MSLYMYr1RyurKy9oYsSE)XqIffnLLynoD1(Gi10Guh)rJf8QtxCwXxtn2hxQVApxA)M(PjQsYA0LKvqZVgAeL14zD)cDDr(OXLsQeMMctHyCdGiNcsI3MoolXpkDDiZpsvXzPpHHBsGTug)cd7EMRORNz01R9ORNr01Woe5c6kvmUOfnIMOUQVnAt2eIU1s2L74gLsH(nY2lk8TQ39uuyiLwJQZp5Gl4PhNw2USNiWJz7rgwL7FRk6fU6ZR41LISel)3ejXF0WHs7MX1nGaQpgye4iNiWg61ijWrorGJqiqpscuvcFuLOS3ESLyZ8xZQR39rGgRDzzUguglDsASaJKgXwt5I1bU(n)vGN8lbsEZ2V8fW1(7I)9g2RmRxPPw11(rB9xTJBeKQ(m7ONn1En1IkHE78ETSWVSAlsZItwJNi1WmET7aRXQt3qncL8qTHSDyxgg9bzGPLO7DlV8f4TtfZUszVOF96iJznkYioYH5utsaj61KmRQeFwOqZzvG0T3WQxy16093(L8jLvNw(KFL)ZFB(K)C8d5twVLvZbFILR98j)Mi2N6AcOSIdkYzF(K)Kumq3u5mmNyWCdXbIjGjbutqjHlwWezRiNp4k583szZipeYqpzGY260cWMRxCfpSmisQYhGahzu7kgJjikE7IIYXylleTFOm0WpXdn8FWdnKt5yE00skxcjLO9Z2tsFZbMWX8nYbcV5EAlrZN7inlKE9JEuGxajWRpfE3FaIfKPC8rzz55Sy4)nPy(l2GebBt(0qZcJhAiKh4EgpBcl26dkuZccGi2)NBtl(Xy)vd4mcmtRoWikNN0pxn7YQ5VBD82OmbLPUCMr(m5dW9fdRHfSQ741vedWvt)FILmpEcUs45ggTiClPY7wfhpJFTxOH2FI)TaAww0sOzoV0vS6c0YHdYK2hvJlbjPbj3xu6T0hziRaQOKK3SL56HB7yefOwX2UY0X)ZTZwSoicTa6Bb0yPOpfS0VAmRkSCC3jOa28WKa(0hwupYBM7UM3uEZ82AE7pinR5VGB2njC69OvYLIBN2WgtOYjKydnM6sjR60XWVXnaNoDNv5Sg6cUs35i84JfasmeulmE8dzy5Oq(btBwTJMOJ3xYbDnDEf1PbNbrU5douksxQD8bnwgoA6G(RL8te9k1miEFaww6Q4m5)nAUryogvuuqIS8Hf(UTqHkJvyx4P2zOUVDoyXex1(PsNJENMiDLkOwLQx8Y9LzpQ5tqndisn2KmqZ)r9U1k2Fj9DwOuWP4sLT4ZkDDG73bRUzcy(fa)VW1(86FJhqXBlDhHzADl3rnE1QuuegB8b1UvoV1W9KbyMU0Kv9iseMtYMEwdt)RmztSj1VoLn1Z(Mw(e2fztrvOPOzYdZJe7AZ0nqyt721DJ2nlEh0sbmx2n7eTZ1Ef(HefDJD(HOSJKzdshoPs7shn1ue9totLSmPPzASNWQP(fF4s)OOaoRvK5YSkLE66VQYkqbAJUlenvsPj26IiONBIGTsj2)MkcEG0grUJcojcIeXIDvx7xEN1D2QQde55w(sFzFxvlp3OTheiI5DTKyrN0L(kVWdSU4O5Ul1aRLL8OxLQy53KPvV69TVMtqwCb2Jiy0f6LRmONloA1JS)Fa7)vKZJcugCpljMvXiP889Wq)3w2dMtF8dBO4ZQON8j)k8tHaGJccfTBhA3fZtiJmCWIc3KJF22JfR6fDDTGh6AHwREHATaUk)V2xlGG1gxlm6RI1cnCKmRo8FJP5BtS4p1U6Kl)sjXYtSJR9CGp7ii(6(OO6Y0I3fMZ6PTeEzX7gCFgCquPkLJ3fZVgsd5ha013zo1Q1CtsegdJmpCoK(1YDv0anRRuH6G8lRoHykTjt7AXXsSKksqVZKCiXVhgmUgXMUeANNDt)7n5mg0(MGKuWCrY9YiA5vCGuZJl(nHzGEUR3UxDS7uAcCsr5OwvSFOfZ7(L(Bhgv7k9mPIqsYcrjL5CM3UGvKpwAeBSypPZ)mAFv2Atl4n9vhtl4RoO05fwSxituv31o2L(GE)HIPV90GwFRSkd3TMoq9UYl3j7fYcOAu4Ty1BsdmFhrREoNqXYvFnUxtK3jkmuFVE(c2t(UzmZOr42TQ3XuuKODv3QdJVr2j4DoFgmiJFeR7xfiIWT7lRU0asKUHqL3InegqJ0qHvxo18s2wNbAZcyxFMZc4KbRaHGfLt9x94gwSC9Qnqx9RJJIFW68Btl8wftmBcX4KUdUIkTmMd5630IBXk4hS1cgyb6UplFRCzt9Ojs3blaUQewAgX09S1jgVgXEtZwRZnMKxk(3LgVABwW4VaYykK6UcC32LuZtYU8C(0IjzLZjSn(Vnb8wC)MvQMdHtEPlw2Fh(3I8ZOhUBmoRXxSo7CwBgB2t(RyveJ6vF1YSeFP6h0ZfwBBxmIo8Ys0v1yrXAZcl97zrEizTPq5CCuWIKq2j6AqIFu1JMzjuLAxLhr0k1Owr4gVcrl4IUCv8xZSnE3Nx0h3FF60KV5XGqvhkWQgOfaBNjVgG9z0Ha0mg7YRov(1lr5LHXMPzJz3mkxAO9HsFUUkQlrmezAvMLLq8MjUiCf(PCDU(JgMrl62EkqQITr7TKbVjKxtgk1cMww4QdlNyZTKEn9J8IHQChBU00c)NS5OGKio7XfzSirh8m0z8rH00Ko9KS26P0Ppc(wYhmJp3JI0TWPu6xNgLBxt7cUMiG6LfGVR8AkTw1PIgeZsrxxEpJztYVNAae6u60LS13PY7nHDJoxBaGQENvlIWC0FvmqTf3kUYcs2hXlB(GmrfCZi53xLgEqvPUVaTmEnAt4)f6TBEwDzhxM6)YoPCH)OOVwpGyTAkioMfsu5LeU4gdKvzXWACPSq6VAL8LkO4L6UOgPlLGtnvjugHqX(BGEmsDca13jsgQZbJqqPsjOsYQriuw71UKCsPx8mnDVMun5SAC5TT7i6tIsV21RLxBXdDfXdSO5j3QhD0Do1RStieWmYuDss9U2uzqfWXCotT58IlEUqIVUGKYJSLCwIQOcLRyCUG9wgyofJyPDO9JdWmwuTRb3wEnLhKKY(uW5aVZh(XrNF7np4NWUQRtV9gELJgUEtCswXzr5vka5vSJJZ)3wr1GMYVpx93MfxukPGrUOfSRM1F(x4NFNrFB(KVpocgrEZVQuSx7Xq7vcTTunxknaD7Kr)EFBqxpuanOtfPGo0pdh6ysAAJGj9s6JY5huAGa61hcqn4280bQdXV5GIVF8OWZjgLe6JsP2GzONKYQdpOmUrhhP1rxCCgM3FGhM8FgrpxTbY2PKZdhzLTQOHKyM605beqvlfgAawR1wQABpXycLn7jujK42zOIo1RbTwm5tGED0YAcO3r2pj0d2r4ob01CCwd4eUv7iS1U3aXrC9BvWgkFiCROtqCkGVNyoQqTqvy7eNj06CqnnsOSx59utBuqFR1CeUDRMJQ4(BhFMqxzv8I6RO1JJ0rDVQXxQdu0GpDufKEjj0ycc)nEXrOx)CQ8kDhu1F1wCeInFYv0xJr(MS44ii9eTObAKhVfhLv1I6vdUeBcLJWENxh8ma1djF4qcBKIIsd(gkFx9Xql0R4nf8YuX7EYRo5eBP3T6rp4nJ6)YIei1)LNCcBWHF618)w5MA8Ml63V)RhnCyjg3o4FAj8p1k8PmRJqHsvOEZJDnfvjpOEd1jkBGeLqqbzTvEIG92ZfhuGTZclYSpkhPHzFzseUWSNEy5eW3xxM)dnUFMLfVslzUePU9yxfwV271fl26LO8WrCT0h)sIpUeV7QX5uQXHYvWI9(4vTYrWpCqweqKLUDgQO0B1(n1okMqmSJ1UCCgLdtIuomq9WKEgcO2X85JtAhp0zD8zWX5oXYXHrhfbu7yUnHMWoEuEw33IDEEavRE1Zdq70Q3WzUIJCQ6fnBf6PEECLAw1NIdyeBhjNCjzl111ZwTPoKJJSuFoOG))WD2fUtdxDjeV7DIzr0EVWbEiaed44lFjzm6LD5QH9F6jNgiZNsP6H0ecbJwFlR6pgSLJpxXktH2v1IV0ZSQZgn7I)VDIQZJJV10Sf7REX7Zbf8)hUZUWDOvD6Dq1rGGJpVQorqiuvNhF2YXNRyLPqhPSIxNLFmH9hPMnh(Tcq3rxznduEnmwwD6eqwVpDm43deFTFkeKXJMW76U0TaFpWAOTuqKccqYiMR2TUFq2dkyjJ1yc3l7qxc49aFzv3Qj0TO9oeSuiBJSwvzEZOEJgn3cGUJ(XzgOMxyJ3Nog87bItT0gTlDlW3dS20sAYU19dYEqb4lVr6qxc49aFrxG3S9oeSuiBJ8qxPnAts80b8dP0MutzvGQFD8WWq(XTh80VopiJHXoRmGnsoD1KHB0dD)64HXiBJg8TGTzPZkdyJmKRidVJwPOa6E5YmnMUBHlEGbVda2vZFgTUU)GNsrenKzpczysDIF2jGmchiJAjqSp34qoC7AW7aGTp34qaz7p4B7uFNmRTpYpnYLZlOUpr7rDfWQKkczfop90liuf1)PNOHM5mBG8DLT1)1NmAWfVHy1i0kY3YENezF3BugwgJ7DAZg9F5OHd73V)1NyoR1i8pkeCKveCekcosdb9uqWsbHVYNjp95BM8uNMjBIGhTzYceSwXxJDeV4dA1sFkG0kLqn2p7AGG(ysIbwQo6(a5QNBTXH3MvQznt2nsZqhBXi5kT1gVsjpFm(kVYMvJbARK7im1gpx)8CQbyKhUZgaLOGQsoKNQfQbDNo7T860yE8QvXpeYU5V9bDhPS39F27BXw(RDbZIl)2E3x5wS4UTzL9J)iboNDIzK79SzSopZpZ)o)0GVn)N5xxySyJjpMKcLBTSqhFgQLJ)Oc7o9udCyoDQh1su8WDkM6ai)Sw0GD8O8h5c97pMLGNrO2n6y(pNffhgMdJwskW21ypLEtLRLtDTBO3zNUc6UMcO0p3buabO7MfxD9TtWZioRCX(QZQXU0FBaycJuDXK4H8SBoIWavxG3hglQuG9GYooOaVBUCfiaExDc3omg)PaBxRI95Dy2tMKhvOs6xTNAWM8Q)01bq720ud8e31MUcC97etnOtDLzwdE0a0lYQt3eFEhlEqvxPspsFvqxkFQsTzgChBKUmrVfhaEmCVzxoGa)ReoZETd1ou7XuCe0UCabofynDIqQeMVAyZDpPCBvW2WfXJGyVtCPMEF6j(wmI2LTBE6PkkbThfK31gK0EPx)ENyEmCbp7XbbX1jX1Jg2NrU4Inp9KHzgKTsQ81H8QryhiL)1yw50)qpRuTAIQOp9myLWJ2kXX5Ur0asVdAwoOa)ReoZEvYr0a1khXUr5Uf4uG10HFXO(ips9rEpN6JAkP9CyLyeL(OMZmM0h5HD2B(xJzLNdReD3Ss1QjQs8DhJL44KPZJ8jpWQ6k7ME6wGxbwQIqEhTXFCUHqORC69WsgnqTYGTBjRBbEfyPRf69qmMgOwXv7IXDlWTc2Duj0XzFEpoiDNKW4JA5QVBlkoOa3ky3r9LhNnL)4G07PGgAsulEIHEvRYHkb(PCXYlJAnFbCCKIp0ttcq0jBkd1MRTR30XuWB)RKNUENlqLR8JdANm1HARdqJiT8Z7ODmZm03VlLSd9f7v(p)t8jogWh5PwwLSzNBVzts88Wvb3EZ)v(KFaeB3ctGqK8(WOj0LLw)GR928jZc)C4mg0U7X8jcLs5tINdcgmYe6qrr9v(ElkkRp43zYncCw0FjctAegKp5NGgdZy)idBaqSKvKOrXm5nM1KzCGhKTnbOJrSrCf7zpR8xgo4cGUe0z6GQ7bS3Cvv1R)w2Rk0vfuxrzO)24nxLgKfo)T8b9QrI)Cmd2xbG8TtJJMfYG5vQ2UTDhwy8URO(4fGDUj2)7ScNVRkEPb8GDxv0ggQ3UYq96sgk2jL55GHIGhTLHwK3(cgjURJYssYCX6uuGCKTqBS4eNJ22NRpp3OTVK9TOTWQe7wr0EOeThbr7rq0ihrr0gBq0EwiA9JloAlTMORponnw(CH86NAgm6rcgvzf9rJOnyOxlXqIdTm6Q)UbdltYMo(5jJEJKqG95uHrEOW2LZegMkl3psyiI6oFSW0ovyKhVpmRuUFMWq0a585ct7yHPE((Cr8yM)A2PF5aiLGLOCrlQy71xPsmUG11JLi17nSbGF8QKvb3nRQ8WraQZ3LS6W9dbsEq1qqruB(kNdRAB21hJkxaEHn8IRe9sfzFWLpnnZNfmwc7oxhbbtOpQvviB9rLk)NbNV)UF7xYN83lgK8j)k)z9fcp4ph)q(K1BNc(n)j296E(KFt4GnlAGnW6rWVA2R8k8nSuoWpzv)jjhTVPY9exORAws2YKG0LaN8Tfzr4Q3pKTCb(1GmJy8FJFuUEiKHbbSjWcyYoMpGCXIfLy)SGm(tJoloHLbrmN4tJ3MmLhacJGwXO9GO4Tlwk(ITmx9)HYqm(epeJ)bpedxiozKztjQurEFypjVnF9qCsC6kY7m3OoH4gyWwGbaYYpHD8U)a42mlUWhLf(4ze43KIe8hzUuxYG(v5Klab3bneMwCk(GymxS1h0hKfeaXX9p3Mw8JX(RCkgoEMleuldxar)kQ9C3O2VBD82OmbERU6Ibq28SOYljxsXze3Xs(bhWvtJFcum4cjuoJX0JyFrxfeb4i9mHZjrJV)3YFO(BTRarkrRu7DTq3Ud9S6XvWExl9SWbOw8evyVJ1zM8THZVQr6k7DYl4EJ08b62yqG9bF2qFkUV6cWdqlpa3vHVQL4XQFVk1H1)IsE)aFjzpO29uEmTV8QftN1xMHO9srllS9wX7Vm4EdWumTb6wHNCMdL4WY)m(2RVDtVx46iJp16hhOqhSou)stF9vE2bbmI1Vi0ga2vJyl8ykrI)H6Lx)cB5v1cCaDGXPIWdQyTnLT6rKCtbNsi(4dlTNfm1)rzErXGSm(Hvf5SeOKPpoTIgsfy)lMfx8gQoEEae96aq65EMomnaj6Iy0rHtLJTfkxhl9UY0JyfqpIKRwLohTeJ(0tQm7lpVVzcUKXY0yIWD0ww1E6QoGKf(vHj80tOK7Lx0azRfb6u2DtEsseBvJOI9zFotvZLE9K(gqwAE40WSR9UWCj7OeDAZxpSRRc6tDuRIb8DJAYhaLw(mNqItGi9YkqqemRyPvP11VJlmaMpJZ4GUgScKsDr20h))7UJUEBCCJ)wcwS(Ss2KyjVo7Efo(LcC4Uh6hO3w03wBfBLy34yzizFztXH8BVZqrkrsndjLTd6EfhWICYIKdNz48nh1clsEORI3mHyYAXBvJjASSxhNoPH9GtZ9L997dW53efH6k8Dqvdo7a9E4aLMnQBypQDRtFDPIonebR1THhyaX8d61YlkZaZrk12Z2G6IxOXwIWnTzrLWqlbQsCS25Ca9Vfu5UbFQK0z8LzLehFB8GAf06670olPdKu4qEEpFBpxNTgFdf(0Jm0kdirVMN9ZOLrnZqJ1sOE0LOXgiFiiceNftJqa(LE9R4lbMBo1F9pdF7PlbsYvjlR06PLczXz1j3(XF)3d41(CKSmdp015ZbTmXgrS3nkHIPG1iiMnpWB1NCiAyAr8XKRL4hB(GP3RwGT1paJpDXlrkKMKlV(sLPai7NRTQhhAGX247bZZqHJf7lblfkKMgsGUyZFtD5AosI4iXPmBAj2GyidpUTlNVa27xEi(WXe6svDd6Kqo36YID)y3XU)OwraZXOpKf5G2jkfBz74yDuQrB)3MJpd3OCjuKzV2u(WKdGt1k3GupNyC22adEVWbu0E)HMrrT3tVl)PvBeKuWVNNURZK7gDKzBwiIS6IssiiUdqa5zfQvIEk9yAGkGXKZyJDWMovRuxrGWn3OGQaAOcu7a(yI89PpAaph3QZHcs3MvucA7kEKY(lLZkAV2u5Ze5n1Dk0zpp470kQN0zKtO3neNiyzuDb4SWn1jggYidSiMAMyv0J0yAYadl(oTs)o6XgVlqMtmcTwjhIVQaWr98(nYE8NKY17GCtgMzR36Gi9blNIJUZdebVE9CxAisiqPMCDwA5srqqY28FmdZJh4IMO2vOLE5Og(hWYQi)(7NcM)jJurOhhMq4BzTFYnUkOpIpJx4ghCFG9RmuBtc9quuuFS8Bhd2rjwPyggqlJKXDiMRs44ygggaWcneaqV4BAxkkhfnBGkE050rPwoqYmMbWWCtSbpJg(nTd52y2IWIZGbAxI5eiaOMI0vlMM9BcyzXIYRY(gwzIaPZ(hwTbSU)c7NQcbvTAhJE8tVUnjr0O1HNwSkADxhrRWres0uR9hE8R1wESpH5x2EmTEuno6yrgusV6i6ONHN98wp1ZW1EFybxSPKlGMBXa)kJ7p(9OgftjLpKVj7HcrfUEvr6MhvUbO98M9gZVOpZaGFYZtv9bn7a8ZzQA6kGWdl2ct9i0VDz((1tRmBTv4LMG5wanYT(dD)257MoC0yYNpaEDZZDJ1eNzY9XYMj(bIqlHORjj8mEmbLQkNbjklW(wv9bKUlRzX0E40TWU(EaFiOu1KChCH(QD1GvBpAGAVXR)PZgE6sYr58xa9Rn2wqGZ5W1m(DQfb4k)EScdSUZTOaojxgpZahCPyPA1JMymqUMBoYHGRglGSH75lrE9YBtcWDm2jPrRPIqz1cO8kSCSm3aNNezB5v8iqUJLkVr1CMTY6zlLJvX15DVo7NxHfgZFxMcovMxlffGZRZgN(6mWuY7V9hwUB32Y)01x)8ZpF1Z5pVeK1a8cpDD52S1RVnEWGBgCTGV(s88ujmh)WezrE8lYhm(60jyz6SADhM5rXjFkwAH(L53FPabbtT4bALct1KJv9Y(TF41zvT8ASqAW)k0flEusYN(rPb64QPD)jMqxBkvRlwDoy(QvuuasUp8LTB7XuSPCh6uFW7O062aEfpv2Ik(fLCG6IobKdSAZVL)iWDHIv3aAXWdCvz)VY9xfhHi(GD2Hws9jUfc7sQ6Hju9DiBm8)xSFRwEB0rcAvkuLJTcTLstdK1mOHKu9bNUbuRM(aOBa8xD9ARSnvNpSpoWm6(3VQOC30uWEqCbgJQM9Le6GCH1DcQTawDRwb00FbKpTlf7rjYsu7NWSUchj)L5G4LVKUwiDrWe)pvoOJVl6HonYPvA14sPlLpa0(krAHYzU9iMnwmSMWONpl9nKD5tOhjtT6HOHEaE0JlrjPD9o5MDdYCMPeuqwAf3bvfvSZOQ8oPBChBY)4SxCk)HIcZtfnDtqvUp0aC1bg(sJPvyj()o2Vthg47i(WtWM6KXqktwOE5i7QAJ0NZloWYDr6lHPFEsr1U8ZZ2GAmz)jrSWgDPDW57PlFsefWrdnOUaOyxAcbnh3I73xnn5xSGLp(U3gy8GbNUwjLYNNcwyGTyc8mr((1Ymly)uxa2bXvhiFivboYEoHZQjEM(akZZowiNiuOBalriXOJM24rTNu9JUdXi81VLOnrApYgNezBAyCe)22hRuDkviwUoYMf1ZtDYYgGqBX62HmuzlqxfP1QIF7iY5)D7Na4wDdCNuXFbwOXTOjKvG6q2bqwLIzJJnYx(WbHZeWj)qQA)FiWXGs97W7Q9kTlYYvYlmcmP3TopFrDkkQreklGMoFz28hjhywrzwbkuQJduIg2cYIZ64qxJcIkN(V3V4HNKOWomAKtdyca2o86p0XbdUVNjWvDCC3L(aYKG3LIhlRc2q42OXvczbTqKPfNBHo4S1C(q3H1vkXxYs(RRWBycgAb84hLDMLR0Udk2NDBqFT013rH5byBGnKOzCGttMWirFy25YV2TL18MF)f8hX761qGzyC)Xh9KlHCSAHXmHxvP)kmqZ1goYfg0)9A4OO9ONYu6rYCmTeUl4wT3BMfzHtWc9Yc1yNv)Z4oese30XjgLwUxYOUHqbgp1cxxf9GC9)KHUoRVzI75y6dLZSZCGDcC5NgTSlE4rD5mNcT6Po171BtV8m(VMr(L)w89YTlRfPOLvModze5gyGuD9xSVxZQo6bAWbw9caR3twLdN8crt2FlqOXRALB8H980JRDIChFdxnnnaZzgSN)xIwtaElXNN)021z7YKx4)VuO2sI)UUNDmBxA5JVo7bWLOnxzM4nnS1cr5ZrHuMIJVDnfYyPw7KlBsPMjAoHYfw1ZbeWpgiYmmjpW)Ss2vcfTOJpO6Jb4T2V6RoSizvYm)awPu00FhALOZRCZCuUoFN6(Xl2x7QBelVPFBooTDB9t(hkfNrvZQjRZ9L4ORFiocNqLOtOEJBp(Nwc1j)BvqxiuCnd)U2l8LDVI0nBYeDCdee07(K2NwR72nYvXJ8AZJKTe8qCaDYHDaLVAECZqCQkNA35iMS2KJElo4r8Rn9eSjMf1xpu3u40VeE6xIB6xaNB)Jo97uDEKSz15M(9UQ22A(M1VG)BwvjhjAeoYPauSwKJTo2QEllIY(G6nq115yd9YSsLU61z)TIQYvAt2QQF3)SDxUOUHmMNG5VSIpAho834jitNMdJB8HCwdjX9PfsDm8LWpBZnwDr1zpgy0Dd1adKfK74wafPyYGi(cSY7Dn0hbnHMGgG0a)e0eDcA4h(miOjFFqqt8sqJFJjOcziQg0LMgbfGGuy1FR6aF1TTbzV3dhJ5TxH8(Faqh91PikKLvRyHjx2Qs7I7ATe494qHlhfeiPPqqcsKn3cn56ABIGwHwT5qZ4qPTAPMDfXM7LJN2AfDeThhgcqf8nZEWO9LSRoQ)w39oTqdkkP5H1ThbRxScKggP1bhFbCNflBq5C38a2zv7vQMV(dVOFY5QqH9uUQZwcw5KTPmls7xxGxK3QbB02t5XmQtRvzSXe)yD2Kpzj7cnZkn(j0ibWOAv)U8o1le98t5fpTFDk2aat3cgxKoFzR24OWqfr8(R9bbEuPO5)PY5iggf0Cg0fgfYhFT0DYXxUcxheBa)9Y89ypxbyem6NN1DksWeO)maoOxp4eeps(n2tmtfMTKnS9FUwVVjYZvqfQi7oHBqoIQ3TC9PyqRz6g0CpX3egYoTDUAS3N99ExNNM9TTzZ3LT4I4O3R6jsVVViVmWJox8xkB8VyeCY884bd0rnd127gz)EKkmVbddJ1Bab87BjI19gxtjFB(bUnR(EftEH9EnHEVwhT14bUlM7a3Ggb8xUJkmUD9vKEHib5ltF3dpMyxpWFEdBOCwqgDcedAhRqQMYZjJNJBICRM)LoqXe44ENf0X3i6sz3I93h27yrAA1lJITNPYKztDUTEKpg1ohF1tcBU)APnki136gY3WK3UBt0epbZw3Mq8s99ImzI2GFpZG)6Vwc8RF9VMmk(R7G)7R)3]] )