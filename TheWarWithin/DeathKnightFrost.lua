-- DeathKnightFrost.lua
-- January 2025

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local PTR = ns.PTR

local strformat = string.format

local spec = Hekili:NewSpecialization( 251 )

spec:RegisterResource( Enum.PowerType.Runes, {
    rune_regen = {
        last = function () return state.query_time end,
        stop = function( x ) return x == 6 end,

        interval = function( time, val )
            val = floor( val )
            if val == 6 then return -1 end
            return state.runes.expiry[ val + 1 ] - time
        end,
        value = 1,
    },

    empower_rune = {
        aura = "empower_rune_weapon",

        last = function()
            local applied = state.buff.empower_rune_weapon.applied
            return applied + floor( ( state.query_time - applied ) / 5 ) * 5
        end,

        stop = function( x )
            return x == 6
        end,

        interval = 5,
        value = 1,
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
            t.expiry[ i ] = ready and 0 or ( start + duration )
            t.cooldown = duration
        end
        table.sort( t.expiry )
        t.actual = nil -- Reset actual to force recalculation
    end,

    gain = function( amount )
        local t = state.runes
        for i = 1, amount do
            table.insert( t.expiry, 0 )
            t.expiry[ 7 ] = nil
        end
        table.sort( t.expiry )
        t.actual = nil
    end,

    spend = function( amount )
        local t = state.runes
        for i = 1, amount do
            local nextReady = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
            table.remove( t.expiry, 1 )
            table.insert( t.expiry, nextReady )
        end

        if state.this_action == "obliterate" and state.buff.exterminate.up then
            state.gain( 20, "runic_power" )
        else
            state.gain( amount * 10, "runic_power" )
        end

        if state.talent.gathering_storm.enabled and state.buff.remorseless_winter.up then
            state.buff.remorseless_winter.expires = state.buff.remorseless_winter.expires + ( 0.5 * amount )
        end

        t.actual = nil
    end,

    timeTo = function( x )
        return state:TimeToResource( state.runes, x )
    end,
}, {
    __index = function( t, k )
        if k == "actual" then
            -- Calculate the number of runes available based on `expiry`.
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
                    if v.t <= q and v.v ~= nil then
                        index = i
                        slice = v
                    else
                        break
                    end
                end

                -- We have a slice.
                if index and slice and slice.v then
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
            return t.current == t.max and 0 or max( 0, t.expiry[ 6 ] - state.query_time )

        else
            local amount = k:match( "time_to_(%d+)" )
            amount = amount and tonumber( amount )
            if amount then return t.timeTo( amount ) end
        end
    end
}))

spec:RegisterStateExpr( "breath_ticks_left", function()
    if not buff.breath_of_sindragosa.up then
        return 0
    end
    return floor( runic_power.current / 17 ) + ( runic_power.current % 17 + ( floor( runes.current / 2 )  * 20 ) / gcd.max ) / 17
end )

spec:RegisterResource( Enum.PowerType.RunicPower, {
    breath_of_sindragosa = {
        aura = "breath_of_sindragosa",
        stop = function( x )
            return state.buff.breath_of_sindragosa.down or x < 17 or breath_ticks_left == 0
        end,
        interval = 1,
        value = -17,

        last = function()
            local app = state.buff.breath_of_sindragosa.applied
            return app + floor( state.query_time - app )
        end,
    },

    empower_rp = {
        aura = "empower_rune_weapon",
        last = function () return state.buff.empower_rune_weapon.applied + floor( ( state.query_time - state.buff.empower_rune_weapon.applied ) / 5 ) * 5 end,
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
    abomination_limb            = {  76049, 383269, 1 }, -- Sprout an additional limb, dealing 54,565 Shadow damage over 12 sec to all nearby enemies. Deals reduced damage beyond 5 targets. Every 1 sec, an enemy is pulled to your location if they are further than 8 yds from you. The same enemy can only be pulled once every 4 sec.
    antimagic_barrier           = {  76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by 20 sec and increases its duration and amount absorbed by 40%.
    antimagic_zone              = {  76065,  51052, 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 1.3 million damage.
    asphyxiate                  = {  76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation                = {  76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and its cooldown is reduced by 30 sec.
    blinding_sleet              = {  76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_draw                  = {  76056, 374598, 1 }, -- When you fall below 30% health you drain 17,735 health from nearby enemies, the damage you take is reduced by 10% and your Death Strike cost is reduced by 10 for 8 sec. Can only occur every 2 min.
    blood_scent                 = {  76078, 374030, 1 }, -- Increases Leech by 3%.
    brittle                     = {  76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    cleaving_strikes            = {  76073, 316916, 1 }, -- Obliterate hits up to 2 additional enemies while you remain in Death and Decay. When leaving your Death and Decay you retain its bonus effects for 4 sec.
    coldthirst                  = {  76083, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants 10 Runic Power and reduces its cooldown by 3 sec.
    control_undead              = {  76059, 111673, 1 }, -- Dominates the target undead creature up to level 71, forcing it to do your bidding for 5 min.
    death_pact                  = {  76075,  48743, 1 }, -- Create a death pact that heals you for 50% of your maximum health, but absorbs incoming healing equal to 30% of your max health for 15 sec.
    death_strike                = {  76071,  49998, 1 }, -- Focuses dark power into a strike with both weapons, that deals a total of 8,500 Physical damage and heals you for 40.00% of all damage taken in the last 5 sec, minimum 11.2% of maximum health.
    deaths_echo                 = { 102007, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have 1 additional charge.
    deaths_reach                = { 102006, 276079, 1 }, -- Increases the range of Death Grip by 10 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    enfeeble                    = {  76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by 30% and the damage they deal to you by 12% for 6 sec.
    gloom_ward                  = {  76052, 391571, 1 }, -- Absorbs are 15% more effective on you.
    grip_of_the_dead            = {  76057, 273952, 1 }, -- Death and Decay reduces the movement speed of enemies within its area by 90%, decaying by 10% every sec.
    ice_prison                  = {  76086, 454786, 1 }, -- Chains of Ice now also roots enemies for 4 sec but its cooldown is increased to 12 sec.
    icebound_fortitude          = {  76081,  48792, 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 30% for 8 sec.
    icy_talons                  = {  76085, 194878, 1 }, -- Your Runic Power spending abilities increase your melee attack speed by 6% for 10 sec, stacking up to 5 times.
    improved_death_strike       = {  76067, 374277, 1 }, -- Death Strike's cost is reduced by 10, and its healing is increased by 60%.
    insidious_chill             = {  76051, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by 5% for 30 sec, stacking up to 4 times.
    march_of_darkness           = {  76074, 391546, 1 }, -- Death's Advance grants an additional 25% movement speed over the first 3 sec.
    mind_freeze                 = {  76084,  47528, 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    null_magic                  = { 102008, 454842, 1 }, -- Magic damage taken is reduced by 8% and the duration of harmful Magic effects against you are reduced by 35%.
    osmosis                     = {  76088, 454835, 1 }, -- Anti-Magic Shell increases healing received by 15%.
    permafrost                  = {  76066, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to 40% of the damage dealt.
    proliferating_chill         = { 101708, 373930, 1 }, -- Chains of Ice affects 1 additional nearby enemy.
    raise_dead                  = {  76072,  46585, 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts 1 min.
    rune_mastery                = {  76079, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by 3% for 8 sec.
    runic_attenuation           = {  76045, 207104, 1 }, -- Auto attacks have a chance to generate 3 Runic Power.
    runic_protection            = {  76055, 454788, 1 }, -- Your chance to be critically struck is reduced by 3% and your Armor is increased by 6%.
    sacrificial_pact            = {  76060, 327574, 1 }, -- Sacrifice your ghoul to deal 11,084 Shadow damage to all nearby enemies and heal for 25% of your maximum health. Deals reduced damage beyond 8 targets.
    soul_reaper                 = {  76063, 343294, 1 }, -- Strike an enemy for 9,914 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 45,489 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    subduing_grasp              = {  76080, 454822, 1 }, -- When you pull an enemy, the damage they deal to you is reduced by 6% for 6 sec.
    suppression                 = {  76087, 374049, 1 }, -- Damage taken from area of effect attacks reduced by 3%. When suffering a loss of control effect, this bonus is increased by an additional 6% for 6 sec.
    unholy_bond                 = {  76076, 374261, 1 }, -- Increases the effectiveness of your Runeforge effects by 20%.
    unholy_endurance            = {  76058, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground               = {  76069, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    unyielding_will             = {  76050, 457574, 1 }, -- Anti-Magic shell now removes all harmful magical effects when activated, but it's cooldown is increased by 20 sec.
    vestigial_shell             = {  76053, 454851, 1 }, -- Casting Anti-Magic Shell grants 2 nearby allies a Lesser Anti-Magic Shell that Absorbs up to 55,050 magic damage and reduces the duration of harmful Magic effects against them by 50%.
    veteran_of_the_third_war    = {  76068,  48263, 1 }, -- Stamina increased by 20%.
    will_of_the_necropolis      = {  76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk                 = {  76077, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.

    -- Deathbringer
    absolute_zero               = { 102009, 377047, 1 }, -- Frostwyrm's Fury has 50% reduced cooldown and Freezes all enemies hit for 3 sec.
    arctic_assault              = {  76091, 456230, 1 }, -- Consuming Killing Machine fires a Glacial Advance through your target at 80% effectiveness.
    avalanche                   = {  76105, 207142, 1 }, -- Casting Howling Blast with Rime active causes jagged icicles to fall on enemies nearby your target, applying Razorice and dealing 4,963 Frost damage.
    biting_cold                 = {  76111, 377056, 1 }, -- Remorseless Winter damage is increased by 35%. The first time Remorseless Winter deals damage to 3 different enemies, you gain Rime.
    bonegrinder                 = {  76122, 377098, 2 }, -- Consuming Killing Machine grants 1% critical strike chance for 10 sec, stacking up to 5 times. At 5 stacks your next Killing Machine consumes the stacks and grants you 10% increased Frost damage for 10 sec.
    breath_of_sindragosa        = {  76093, 152279, 1 }, -- Continuously deal 25,472 Frost damage every 1 sec to enemies in a cone in front of you, until your Runic Power is exhausted. Deals reduced damage to secondary targets. Generates 2 Runes at the start and end.
    chill_streak                = {  76098, 305392, 1 }, -- Deals 25,420 Frost damage to the target and reduces their movement speed by 70% for 4 sec. Chill Streak bounces up to 12 times between closest targets within 10 yards.
    cold_heart                  = {  76035, 281208, 1 }, -- Every 2 sec, gain a stack of Cold Heart, causing your next Chains of Ice to deal 2,481 Frost damage. Stacks up to 20 times.
    cryogenic_chamber           = {  76109, 456237, 1 }, -- Each time Frost Fever deals damage, 15% of the damage dealt is gathered into the next cast of Remorseless Winter, up to 20 times.
    empower_rune_weapon         = {  76110,  47568, 1 }, -- Empower your rune weapon, gaining 15% Haste and generating 1 Rune and 5 Runic Power instantly and every 5 sec for 20 sec.
    enduring_chill              = {  76097, 377376, 1 }, -- Chill Streak's bounce range is increased by 2 yds and each time Chill Streak bounces it has a 25% chance to increase the maximum number of bounces by 1.
    enduring_strength           = {  76100, 377190, 1 }, -- When Pillar of Frost expires, your Strength is increased by 15% for 6 sec. This effect lasts 2 sec longer for each Obliterate and Frostscythe critical strike during Pillar of Frost.
    everfrost                   = {  76113, 376938, 1 }, -- Remorseless Winter deals 6% increased damage to enemies it hits, stacking up to 10 times.
    frigid_executioner          = {  76120, 377073, 1 }, -- Obliterate deals 15% increased damage and has a 15% chance to refund 2 runes.
    frost_strike                = {  76115,  49143, 1 }, -- Chill your weapon with icy power and quickly strike the enemy, dealing 26,260 Frost damage.
    frostscythe                 = {  76096, 207230, 1 }, -- A sweeping attack that strikes all enemies in front of you for 18,880 Frost damage. This attack always critically strikes and critical strikes with Frostscythe deal 4 times normal damage. Deals reduced damage beyond 5 targets. Consuming Killing Machine reduces the cooldown of Frostscythe by 1.0 sec.
    frostwhelps_aid             = {  76106, 377226, 1 }, -- Pillar of Frost summons a Frostwhelp who breathes on all enemies within 40 yards in front of you for 9,278 Frost damage. Each unique enemy hit by Frostwhelp's Aid grants you 8% Mastery for 15 sec, up to 40%.
    frostwyrms_fury             = { 101931, 279302, 1 }, -- Summons a frostwyrm who breathes on all enemies within 40 yd in front of you, dealing 81,901 Frost damage and slowing movement speed by 50% for 10 sec.
    gathering_storm             = {  76099, 194912, 1 }, -- Each Rune spent during Remorseless Winter increases its damage by 10%, and extends its duration by 0.5 sec.
    glacial_advance             = {  76092, 194913, 1 }, -- Summon glacial spikes from the ground that advance forward, each dealing 10,985 Frost damage and applying Razorice to enemies near their eruption point.
    horn_of_winter              = {  76089,  57330, 1 }, -- Blow the Horn of Winter, gaining 2 Runes and generating 25 Runic Power.
    howling_blast               = {  76114,  49184, 1 }, -- Blast the target with a frigid wind, dealing 4,770 Frost damage to that foe, and reduced damage to all other enemies within 10 yards, infecting all targets with Frost Fever.  Frost Fever A disease that deals 57,047 Frost damage over 24 sec and has a chance to grant the Death Knight 5 Runic Power each time it deals damage.
    hyperpyrexia                = {  76108, 456238, 1 }, -- Your Runic Power spending abilities have a chance to additionally deal 45% of the damage dealt over 4 sec.
    icebreaker                  = {  76033, 392950, 2 }, -- When empowered by Rime, Howling Blast deals 30% increased damage to your primary target.
    icecap                      = { 101930, 207126, 1 }, -- Reduces Pillar of Frost cooldown by 15 sec.
    icy_death_torrent           = { 101933, 435010, 1 }, -- Your auto attack critical strikes have a chance to send out a torrent of ice dealing 24,555 Frost damage to enemies in front of you.
    improved_frost_strike       = {  76103, 316803, 2 }, -- Increases Frost Strike damage by 10%.
    improved_obliterate         = {  76119, 317198, 1 }, -- Increases Obliterate damage by 10%.
    improved_rime               = {  76112, 316838, 1 }, -- Increases Howling Blast damage done by an additional 75%.
    inexorable_assault          = {  76037, 253593, 1 }, -- Gain Inexorable Assault every 8 sec, stacking up to 5 times. Obliterate consumes a stack to deal an additional 5,815 Frost damage.
    killing_machine             = {  76117,  51128, 1 }, -- Your auto attack critical strikes have a chance to make your next Obliterate deal Frost damage and critically strike.
    murderous_efficiency        = {  76121, 207061, 1 }, -- Consuming the Killing Machine effect has a 25% chance to grant you 1 Rune.
    obliterate                  = {  76116,  49020, 1 }, -- A brutal attack that deals 28,347 Physical damage.
    obliteration                = {  76123, 281238, 1 }, -- While Pillar of Frost is active, Frost Strike Soul Reaper, and Howling Blast always grant Killing Machine and have a 30% chance to generate a Rune. to deal additional damage.
    piercing_chill              = {  76097, 377351, 1 }, -- Enemies suffer 12% increased damage from Chill Streak each time they are struck by it.
    pillar_of_frost             = { 101929,  51271, 1 }, -- The power of frost increases your Strength by 30% for 12 sec.
    rage_of_the_frozen_champion = {  76120, 377076, 1 }, -- Obliterate has a 15% increased chance to trigger Rime and Howling Blast generates 6 Runic Power while Rime is active.
    runic_command               = {  76102, 376251, 2 }, -- Increases your maximum Runic Power by 5.
    shattered_frost             = {  76094, 455993, 1 }, -- When Frost Strike consumes 5 Razorice stacks, it deals 60% of the damage dealt to nearby enemies. Deals reduced damage beyond 8 targets.
    shattering_blade            = {  76095, 207057, 1 }, -- When Frost Strike damages an enemy with 5 stacks of Razorice it will consume them to deal an additional 115% damage.
    smothering_offense          = {  76101, 435005, 1 }, -- Your auto attack damage is increased by 10%. This amount is increased for each stack of Icy Talons you have and it can stack up to 2 additional times.
    the_long_winter             = { 101932, 456240, 1 }, -- While Pillar of Frost is active your auto-attack critical strikes increase its duration by 2 sec, up to a maximum of 6 sec.
    unleashed_frenzy            = {  76118, 376905, 1 }, -- Damaging an enemy with a Runic Power ability increases your Strength by 2% for 10 sec, stacks up to 3 times.

    -- Rider of the Apocalypse
    a_feast_of_souls            = {  95042, 444072, 1 }, -- While you have 2 or more Horsemen aiding you, your Runic Power spending abilities deal 20% increased damage.
    apocalypse_now              = {  95041, 444040, 1 }, -- Army of the Dead and Frostwyrm's Fury call upon all 4 Horsemen to aid you for 20 sec.
    death_charge                = {  95060, 444010, 1 }, -- Call upon your Death Charger to break free of movement impairment effects. For 10 sec, while upon your Death Charger your movement speed is increased by 100%, you cannot be slowed below 100% of normal speed, and you are immune to forced movement effects and knockbacks.
    fury_of_the_horsemen        = {  95042, 444069, 1 }, -- Every 50 Runic Power you spend extends the duration of the Horsemen's aid in combat by 1 sec, up to 5 sec.
    horsemens_aid               = {  95037, 444074, 1 }, -- While at your aid, the Horsemen will occasionally cast Anti-Magic Shell on you and themselves at 80% effectiveness. You may only benefit from this effect every 45 sec.
    hungering_thirst            = {  95044, 444037, 1 }, -- The damage of your diseases and Frost Strike are increased by 10%.
    mawsworn_menace             = {  95054, 444099, 1 }, -- Obliterate deals 10% increased damage and the cooldown of your Death and Decay is reduced by 10 sec.
    mograines_might             = {  95067, 444047, 1 }, -- Your damage is increased by 5% and you gain the benefits of your Death and Decay while inside Mograine's Death and Decay.
    nazgrims_conquest           = {  95059, 444052, 1 }, -- If an enemy dies while Nazgrim is active, the strength of Apocalyptic Conquest is increased by 3%. Additionally, each Rune you spend increase its value by 1%.
    on_a_paler_horse            = {  95060, 444008, 1 }, -- While outdoors you are able to mount your Acherus Deathcharger in combat.
    pact_of_the_apocalypse      = {  95037, 444083, 1 }, -- When you take damage, 5% of the damage is redirected to each active horsemen.
    riders_champion             = {  95066, 444005, 1, "rider_of_the_apocalypse" }, -- Spending Runes has a chance to call forth the aid of a Horsemen for 10 sec. Mograine Casts Death and Decay at his location that follows his position. Whitemane Casts Undeath on your target dealing 2,608 Shadowfrost damage per stack every 3 sec, for 24 sec. Each time Undeath deals damage it gains a stack. Cannot be Refreshed. Trollbane Casts Chains of Ice on your target slowing their movement speed by 40% and increasing the damage they take from you by 5% for 8 sec. Nazgrim While Nazgrim is active you gain Apocalyptic Conquest, increasing your Strength by 5%.
    trollbanes_icy_fury         = {  95063, 444097, 1 }, -- Obliterate shatters Trollbane's Chains of Ice when hit, dealing 31,015 Shadowfrost damage to nearby enemies, and slowing them by 40% for 4 sec. Deals reduced damage beyond 8 targets.
    whitemanes_famine           = {  95047, 444033, 1 }, -- When Obliterate damages an enemy affected by Undeath it gains 1 stack and infects another nearby enemy.

    -- Deathbringer
    bind_in_darkness            = {  95043, 440031, 1 }, -- Rime empowered Howling Blast deals 30% increased damage to its main target, and is now Shadowfrost. Shadowfrost damage applies 2 stacks to Reaper's Mark and 4 stacks when it is a critical strike.
    dark_talons                 = {  95057, 436687, 1 }, -- Consuming Killing Machine or Rime has a 25% chance to grant 3 stacks of Icy Talons and increase its maximum stacks by the same amount for 6 sec. Runic Power spending abilities count as Shadowfrost while Icy Talons is active.
    deaths_messenger            = {  95049, 437122, 1 }, -- Reduces the cooldowns of Lichborne and Raise Dead by 30 sec.
    expelling_shield            = {  95049, 439948, 1 }, -- When an enemy deals direct damage to your Anti-Magic Shell, their cast speed is reduced by 10% for 6 sec.
    exterminate                 = {  95068, 441378, 1 }, -- After Reaper's Mark explodes, your next 2 Obliterates cost 1 Rune and summon 2 scythes to strike your enemies. The first scythe strikes your target for 74,146 Shadowfrost damage and has a 30% chance to apply Reaper's Mark, the second scythe strikes all enemies around your target for 25,308 Shadowfrost damage. Deals reduced damage beyond 8 targets.
    grim_reaper                 = {  95034, 434905, 1 }, -- Reaper's Mark initial strike grants Killing Machine. Reaper's Mark explosion deals up to 30% increased damage based on your target's missing health.
    pact_of_the_deathbringer    = {  95035, 440476, 1 }, -- When you suffer a damaging effect equal to 25% of your maximum health, you instantly cast Death Pact at 50% effectiveness. May only occur every 2 min. When a Reaper's Mark explodes, the cooldowns of this effect and Death Pact are reduced by 5 sec.
    reaper_of_souls             = {  95034, 440002, 1 }, -- When you apply Reaper's Mark, the cooldown of Soul Reaper is reset, your next Soul Reaper costs no runes, and it explodes on the target regardless of their health. Soul Reaper damage is increased by 20%.
    reapers_mark                = {  95062, 439843, 1, "deathbringer" }, -- Viciously slice into the soul of your enemy, dealing 55,138 Shadowfrost damage and applying Reaper's Mark. Each time you deal Shadow or Frost damage, add a stack of Reaper's Mark. After 12 sec or reaching 40 stacks, the mark explodes, dealing 4,233 damage per stack. Reaper's Mark travels to an unmarked enemy nearby if the target dies, or explodes below 35% health when there are no enemies to travel to. This explosion cannot occur again on a target for 3 min.
    reapers_onslaught           = {  95057, 469870, 1 }, -- Reduces the cooldown of Reaper's Mark by 15 sec, but the amount of Obliterates empowered by Exterminate is reduced by 1.
    rune_carved_plates          = {  95035, 440282, 1 }, -- Each Rune spent reduces the magic damage you take by 1.5% and each Rune generated reduces the physical damage you take by 1.5% for 5 sec, up to 5 times.
    soul_rupture                = {  95061, 437161, 1 }, -- When Reaper's Mark explodes, it deals 30% of the damage dealt to nearby enemies and causes them to deal 5% reduced Physical damage to you for 10 sec.
    swift_and_painful           = {  95032, 443560, 1 }, -- If no enemies are struck by Soul Rupture, you gain 10% Strength for 8 sec. Wave of Souls is 100% more effective on the main target of your Reaper's Mark.
    wave_of_souls               = {  95036, 439851, 1 }, -- Reaper's Mark sends forth bursts of Shadowfrost energy and back, dealing 17,091 Shadowfrost damage both ways to all enemies caught in its path. Wave of Souls critical strikes cause enemies to take 5% increased Shadowfrost damage for 15 sec, stacking up to 2 times, and it is always a critical strike on its way back.
    wither_away                 = {  95058, 441894, 1 }, -- Frost Fever deals its damage 100% faster, and the second scythe of Exterminate applies Frost Fever.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bitter_chill      = 5435, -- (356470)
    bloodforged_armor = 5586, -- (410301)
    dark_simulacrum   = 3512, -- (77606) Places a dark ward on an enemy player that persists for 12 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    dead_of_winter    = 3743, -- (287250)
    deathchill        =  701, -- (204080)
    delirium          =  702, -- (233396)
    rot_and_wither    = 5510, -- (202727)
    shroud_of_winter  = 3439, -- (199719)
    spellwarden       = 5591, -- (410320)
    strangulate       = 5429, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for 4 sec.
} )

-- Auras
spec:RegisterAuras( {
    -- Your Runic Power spending abilities deal $w1% increased damage.
    a_feast_of_souls = {
        id = 440861,
        duration = 3600,
        max_stack = 1
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
        duration = 3600,
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
        max_stack = 20
    },
    cold_heart = {
        alias = { "cold_heart_item", "cold_heart_talent" },
        aliasMode = "first",
        aliasType = "buff",
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
        duration = function() return 6 + 2 * buff.enduring_strength.stack end,
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
        max_stack = 1
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
        duration = 10,
        max_stack = function() return ( talent.smothering_offense.enabled and 5 or 3 ) + ( talent.dark_talons.enabled and 3 or 0 ) end
    },
    inexorable_assault = {
        id = 253595,
        duration = 3600,
        max_stack = 5
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
        max_stack = 2
    },
    -- Absorbing up to $w1 magic damage.; Duration of harmful magic effects reduced by $s2%.
    lesser_antimagic_shell = {
        id = 454863,
        duration = function() return 5.0 * ( talent.antimagic_barrier.enabled and 1.4 or 1 ) end,
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
    -- You are a prey for the Deathbringer... This effect will explode for $436304s1 Shadowfrost damage for each stack.
    reapers_mark = {
        id = 434765,
        duration = 12.0,
        tick_time = 1.0,
        max_stack = 40
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
        max_stack = 1
    },
    -- Damage dealt to $@auracaster reduced by $w1%.
    subduing_grasp = {
        id = 454824,
        duration = 6.0,
        max_stack = 1
    },
    -- Damage taken from area of effect attacks reduced by an additional $w1%.
    suppression = {
        id = 454886,
        duration = 6.0,
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
        max_stack = 1
    },
    -- Your runeblade contains trapped magical energies, ready to be unleashed.
    dark_simulacrum_buff = {
        id = 77616,
        duration = 12,
        max_stack = 1
    },
    dead_of_winter = {
        id = 289959,
        duration = 4,
        max_stack = 5
    },
    deathchill = {
        id = 204085,
        duration = 4,
        max_stack = 1
    },
    delirium = {
        id = 233396,
        duration = 15,
        max_stack = 1
    },
    shroud_of_winter = {
        id = 199719,
        duration = 3600,
        max_stack = 1
    },

    -- Legendary
    absolute_zero = {
        id = 334693,
        duration = 3,
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
        max_stack = 1
    },
} )

spec:RegisterTotem( "ghoul", 1100170 )

spec:RegisterGear({
    -- The War Within
    tww2 = {
        items = { 229253, 229251, 229256, 229254, 229252 },
        auras = {
            -- https://www.wowhead.com/spell=1216813
            winning_streak = {
                id = 1217897,
                duration = 3600,
                max_stack = 6
            },
            -- https://www.wowhead.com/spell=1222698
            murderous_frenzy = {
                id = 1222698,
                duration = 6,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207198, 207199, 207200, 207201, 207203 },
        auras = {
            chilling_rage = {
                id = 424165,
                duration = 12,
                max_stack = 5
            }
        }
    },
    tier30 = {
        items = { 202464, 202462, 202461, 202460, 202459, 217223, 217225, 217221, 217222, 217224 },
        auras = {
            wrath_of_the_frostwyrm = {
                id = 408368,
                duration = 30,
                max_stack = 10
            },
            lingering_chill = {
                id = 410879,
                duration = 12,
                max_stack = 1
            }
        }
    },
    tier29 = {
        items = { 200405, 200407, 200408, 200409, 200410 }
    }
} )

local any_dnd_set = false

local spendHook = function( amt, resource )
    -- Runic Power
    if amt > 0 and resource == "runic_power" then
        if talent.icy_talons.enabled then addStack( "icy_talons", nil, 1 ) end
        if talent.unleashed_frenzy.enabled then addStack( "unleashed_frenzy") end
    end
    -- Runes
    if resource == "rune" and amt > 0 then
        if active_dot.shackle_the_unworthy > 0 then
            reduceCooldown( "shackle_the_unworthy", 4 * amt )
        end

        if talent.rune_carved_plates.enabled then
            addStack( "rune_carved_plates", nil, amt )
        end
    end
end

spec:RegisterHook( "spend", spendHook )

spec:RegisterHook( "reset_precast", function ()

    if covenant.night_fae then
        if state:IsKnown( "deaths_due" ) then
            class.abilities.any_dnd = class.abilities.deaths_due
            cooldown.any_dnd = cooldown.deaths_due
            setCooldown( "death_and_decay", cooldown.deaths_due.remains )
        elseif state:IsKnown( "defile" ) then
            class.abilities.any_dnd = class.abilities.defile
            cooldown.any_dnd = cooldown.defile
            setCooldown( "death_and_decay", cooldown.defile.remains )
        end
    else
        class.abilities.any_dnd = class.abilities.death_and_decay
        cooldown.any_dnd = cooldown.death_and_decay
    end

    if not any_dnd_set then
        class.abilityList.any_dnd = "|T136144:0|t |cff00ccff[Any]|r " .. class.abilities.death_and_decay.name
        any_dnd_set = true
    end
    --[[ Uncomment if enduring strength buff ever becomes referenced in APL
    if buff.pillar_of_frost.up and talent.enduring_strength.enabled then
        state:QueueAuraEvent( "pillar_of_frost", TriggerEnduringStrengthBuff, buff.pillar_of_frost.expires, "AURA_EXPIRATION" )
    end
    --]]

    local control_expires = action.control_undead.lastCast + 300
    if talent.control_undead.enabled and control_expires > now and pet.up then
        summonPet( "controlled_undead", control_expires - now )
    end

    -- Reset CDs on any Rune abilities that do not have an actual cooldown.
    for action in pairs( class.abilityList ) do
        local data = class.abilities[ action ]
        if data and data.cooldown == 0 and data.spendType == "runes" then
            setCooldown( action, 0 )
        end
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

        spend = 17,
        spendType = "runic_power",
        readySpend = function () return settings.bos_rp end,

        talent = "breath_of_sindragosa",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            gain( 2, "runes" )
            applyBuff( "breath_of_sindragosa" )
            if talent.unleashed_frenzy.enabled then addStack( "unleashed_frenzy", nil, 3 ) end
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
            if talent.unleashed_frenzy.enabled then addStack( "unleashed_frenzy", nil, 3 ) end
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
            if talent.unleashed_frenzy.enabled then addStack( "unleashed_frenzy", nil, 3 ) end
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
        cooldown = function () return ( conduit.accelerated_cold.enabled and 0.9 or 1 ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( level > 55 and 105 or 120 ) end,
        gcd = "off",

        talent = "empower_rune_weapon",
        startsCombat = false,

        handler = function ()
            stat.haste = state.haste + 0.15 + ( conduit.accelerated_cold.mod * 0.01 )
            gain( 1, "runes" )
            gain( 5, "runic_power" )
            applyBuff( "empower_rune_weapon" )
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
        school = function() if talent.dark_talons.enabled and buff.icy_talons.up then return "shadowfrost" end return "frost" end,

        talent = "frost_strike",
        startsCombat = true,

        cycle = function ()
            if debuff.mark_of_fyralath.up then return "mark_of_fyralath" end
            if death_knight.runeforge.razorice and debuff.razorice.stack == 5 then return "razorice" end
        end,

        handler = function ()

            if talent.obliteration.enabled and buff.pillar_of_frost.up then addStack( "killing_machine" ) end
            if talent.shattering_blade.enabled and debuff.razorice.stack == 5 then removeDebuff( "target", "razorice" ) end
            -- if debuff.razorice.stack > 5 then applyDebuff( "target", "razorice", nil, debuff.razorice.stack - 5 ) end 


            if death_knight.runeforge.razorice then applyDebuff( "target", "razorice", nil, min( 5, buff.razorice.stack + 1 ) ) end

            -- Legacy / PvP
            if pvptalent.bitter_chill.enabled and debuff.chains_of_ice.up then
                applyDebuff( "target", "chains_of_ice" )
            end

            if conduit.eradicating_blow.enabled then removeBuff( "eradicating_blow" ) end

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
            -- if talent.apocalypse_now.enabled then do stuff end
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
            if talent.unleashed_frenzy.enabled then addStack( "unleashed_frenzy", nil, 3 ) end
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
        school = function() return talent.bind_in_darkness.enabled and buff.rime.up and "shadowfrost" or "frost" end,

        spend = function () return buff.rime.up and 0 or 1 end,
        spendType = "runes",

        talent = "howling_blast",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "frost_fever" )
            active_dot.frost_fever = max( active_dot.frost_fever, active_enemies )

            if talent.bind_in_darkness.enabled and debuff.reapers_mark.up then applyDebuff( "target", "reapers_mark", nil, debuff.reapers_mark.stack + 2 ) end
            if talent.obliteration.enabled and buff.pillar_of_frost.up then addStack( "killing_machine" ) end

            if buff.rime.up then
                removeBuff( "rime" )
                if talent.rage_of_the_frozen_champion.enabled then gain( 6, "runic_power") end
                if talent.avalanche.enabled then applyDebuff( "target", "razorice", nil, min( 5, buff.razorice.stack + 1 ) ) end
                if legendary.rage_of_the_frozen_champion.enabled then gain( 8, "runic_power" ) end
                if set_bonus.tier30_2pc > 0 then addStack( "wrath_of_the_frostwyrm" ) end
            end

            if pvptalent.delirium.enabled then applyDebuff( "target", "delirium" ) end
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

        spend = function()
            if talent.exterminate.enabled and buff.exterminate.up then return 1 end
            return 2
        end,
        spendType = "runes",

        talent = "obliterate",
        startsCombat = true,
        school = function() if buff.killing_machine.up then return "frost" end return "physical" end,

        cycle = function ()
            if debuff.mark_of_fyralath.up then return "mark_of_fyralath" end
            if death_knight.runeforge.razorice and debuff.razorice.stack == 5 then return "razorice" end
        end,

        handler = function ()
            if talent.inexorable_assault.enabled then removeStack( "inexorable_assault" ) end

            if buff.exterminate.up then
                removeStack( "exterminate" )
                if talent.wither_away.enabled then
                    applyDebuff( "target", "frost_fever" )
                    active_dot.frost_fever = max ( active_dot.frost_fever, active_enemies ) -- it applies in AoE around your target
                end
            end

            if buff.killing_machine.up then
                if talent.bonegrinder.enabled and buff.bonegrinder_crit.stack_pct == 100 then
                    removeBuff( "bonegrinder_crit" )
                    applyBuff( "bonegrinder_frost" )
                else
                    addStack( "bonegrinder_crit" )
                end
                removeStack( "killing_machine" )
                if talent.arctic_assault.enabled then applyDebuff( "target", "razorice", nil, min( 5, buff.razorice.stack + 1 ) ) end
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

            -- Legacy
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
        cooldown = function() return 60.0 - ( 15 * talent.reapers_onslaught.rank ) end,
        gcd = "spell",

        spend = 2,
        spendType = 'runes',

        talent = "reapers_mark",
        startsCombat = true,

        handler = function()
            applyDebuff( "target", "reapers_mark" )

            if talent.grim_reaper.enabled then
                addStack( "killing_machine" )
            end

            if talent.reaper_of_souls.enabled then
                setCooldown( "soul_reaper", 0 )
                applyBuff( "reaper_of_souls" )
            end
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

            if talent.unleashed_frenzy.enabled then addStack( "unleashed_frenzy", nil, 3 ) end
        end,
    },

    -- Talent: Strike an enemy for $s1 Shadowfrost damage and afflict the enemy with Soul Reaper.     After $d, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    soul_reaper = {
        id = 343294,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function() if talent.reaper_of_souls.enabled and buff.reaper_of_souls.up then return 0 end return 1 end,
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

    potion = "tempered_potion",

    package = "Frost DK",
} )

--[[ Estimation of whether or not random RP gains can happen, in an attempt to smooth out changing recommendations
spec:RegisterStateExpr( "breath_possible_gains", function ()
    -- Initialize possible gains
    local possible_gains = 0

    -- Check for weapon swing before next GCD
    if state.nextMH and state.nextMH > 0 and state.nextMH <= ( state.now + state.gcd.remains ) then
        possible_gains = possible_gains + 5
    end

    -- Calculate next Frost Fever tick dynamically
    if state.debuff.frost_fever.up then
        local tick_time = state.debuff.frost_fever.tick_time or 3 -- Default tick time if unavailable
        local last_tick = state.debuff.frost_fever.last_tick or state.debuff.frost_fever.applied
        local next_tick = last_tick + tick_time

        -- Check if Frost Fever will tick before the next GCD ends
        if next_tick <= ( state.now + state.gcd.remains ) then
            possible_gains = possible_gains + ( active_dot.frost_fever * 3 )
        end
    end

    return possible_gains
end )--]]

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

spec:RegisterPack( "Frost DK", 20250325.1, [[Hekili:S3ZFZTTnY(zXZnrvYjvwKYkPTtSNPxFTZL(612jU9U)Zs0sus8cfPEKu21z8Op7VDb4pabXcakr5KoxFVBUZreCXUl2FJfG36C7VD7nl8Y8V9NDh5oz0y3jdDgnXz8xF7nzpU1)2B26n)dERG)iYBd8F)djXPz7N9)8)Ip5XWyVfiesJ3LmhE66SSTPFZfxSkiB9U7gopEZfPbB2f6LfehnpXBzg(VNFXT3C3UGWS3fD7DQN(V62B82LToo52BUjyZ3bqoyXcF(W9tNF7n4W)YrJ)s3jFZ(zzbB8NMfpDrG)(FS2tU5XO57N9aGoWFdaQ4XUFP7Rv84BVjminlLrsbrRcbO6LSYpd(HFMXQ8J8Ul0FXT)Da)MJe1T3Se5ittZsc(Gph7sc2YF0nmySF2VXaY(zVpoZJ)eymz(jbEax2l0pkBO30L(EaCIxofyMHPdZNP9Z6TF2c)72TC5WeVpgNem3FyAgSOSF2v7NnH98CyKU2ldHA0QP3f6TWVgmyqOXSSB7TzaVxI0QWo2B9HGWqeOB8MVoisC6D3p7PNYHT)FaVZMGiy1ebBj)j(UqeA4ImmvJjNQ(DaDoGJpaOs2fbm(3Yqr4npR8Lb4ExIV3h8teEnIvtaFVKeFxgSAD20e)nEbrP7NDDfsIl2dlKj3opB64jmur5Zrz2Qx(SCMPmlhW45zvyjU4btT3w)eejNqIK37b)pWppmbNoe0PvqzD8dH5mX0meoVUDYb72wGZLtZ24y2qq2FkLmWBEE5PCrb4F6sYa)ksmIG4cMpDB8d(jSjOVWys2Y5YLcINzHylhjlG5Wf(ldMhKXfFhXKQ1iH(16x0Wf(A6Jnw1DgDuu)zmYexXMU2lAXq31CA3ivRHMCKn2AeL8tziJiAqj(5qBUZa9QbHPTR1A1dhABoaSweNnKp7l9VhewYcM)baK6wFPnpizLuPqiQ4mPqoVsAgnIMTM5jjiArI3Q4uVQ1wuaOKQZs2b2E4JFoWbwe)qedUf)JHGJ(ieupeeLHZ9UeMFY9Z(Y9ZCMutuP(qz0hTzlBrxD0(OQ52lzUxeAHjjbG5T4))nZbsy6AFVeTbjmFnArdN(G5Yrj8Dae2p7FWabTTqyrA18fd349hfRfIlEi)MY3rUzA(QxD90I4cQiIcFUxdoDVKdxRFL9Z(QsxWDiMWaBlreNcZMAJUPs8OudewrAg20wGo8sWvpMMxbDOH1HZpNsvcaLRQNZgVZ(zVK9h5yg7fE4XKnPtxUl5XAixP(J8GaH9fpY5aclh7Iwhh(iA1YpAv26AKH8ZuIHdOeO1gyNfC5fmLZpeHI8dr56LXGd9Hl9cH3B68KDPGNJKArirSMuYsiz5xZnPiS6ODjKKZvYwjE9X65xAnYBIFDwRyzMjYUGPkAOSb1s7cYcsvhQzyn8YJBn8R5dXm9dAjJnYRVuRerMqCa4a04nriEHBM)48Y0utXxXYO27RmTno9QX1Z5m3ndKCH9lci((zFlGM37lKU7bNIzzKj2BfTNyW42K0dTHRUhZkeM5kVGNSPl8N79yXAsjIVYB62Kaij4ShRW8vHEZd8cN6T4EVi1gruxtIpnuKcrtfgcmHXhDjbQgJ2sSWMfvLhrjvqhX5jjdwpMc1u)i)nbyIoxXctONyQT1wmAQYtM5RCU4knXyYGIAMeDs1NeMKfP5lNQSABc1DfBWgkDgzmRKQ4lnY3MsbVEXXuzCGBUMqhHZ2giIPQJzO4flgPw4PAcP8umwSIC0vjrmrMbkf4VMjWpGMLAxXzRXpLtFIa5oAdqdkunnwjLA5xljmup1A1geAw1f)f5MVRWgcgOb)Zwufjz)OMwc(CNJq5BvJwQnKKAF8kXG26R0y1Ruol0(Yk1qgRT8l0LZTeaLERQyfiy1vALF2rBrzn6NtwafSRVnXFE8M78uwPMy4Dt9ZcwwbIcMj7VMY3)lGPh9b)SPottFmAETez4pzyMZW1EPt3LYd9SqooxmuoUkPuDSTAviaRMVY8tQkC2l0K1s1OaTKrL2OBXCxcALdUgwOhnlrGbitoChObhMcS5rdNK)d3EJJQ8hA5YLl9YL7Z8YL7FowUuIMwVCj7miF5s9If71KuFQQtCdP96lxmwXNtpCqJNhKomd3aV1(jX7sNML4fLUja9gP2YcpJvfP31cUOREUOSqFnm(ZHhkZfDBjx0TIlk7gTLMoCMwi)tyTxpIvPKi8kiUja2cnNjQYTSLORRE01eFub66QfDL9(3s0vieiLXXiPvupekPfBcP8kLauI6SgQUvpFGuMaeW3O18lucJQNpOSy)dNWk3Vo1GZRN6uf8sznVYGgBCqD0li8(q2(OjkXY(Tbme1z0OInkyalrR(weDHkc0XkcuH1scc0Xkc0rbb6ssG1LWDkfLDvvVclLKx4TXBfe56riqR65IYCnOmSCYsSaTKMCHpAHJeM9nVqiJH1ajVD3h)iKcXDX)Xr7LBJx0oVqLfePfONRDONjZEnTIkGEePkOd9YZyfc2IxtGuiXMn1ZyTi(TGmCa4wgu8Crek5Hkhznss3mIajNjaS8W)s2cthrw7MbzoENGc9qGKafIXP(rCtNw7TzBG4(3iqNQ67QASHOftdIMUWl5dr(PPQ4fP42jmFQqv9vLNosbj(K0qtEr2Ay4Rb(pwT5LE7cZySaCzjD4DXPWyK2UJV9x)P9Z(x5aD)SFH9ZFZ(z)J4h2pBZU5R3p79yUU7N9R8KDZI3pdZihYBfR5g8oZHSszfj8VZWJ9ZIxITGyrq5kZ)3skZhLzQOUKGvRqH8sA7nJSKC(9uCrI3DKIaDxKFby5K2c)m2EibV8dR9b7)awY6iuW8LhsTHiJXpkE3Q183aCaSF23VjVwaVNvNG)TV324iL1K4aOCbKuG2hFKK(2tmHRkAkliCw1650CEHFeO5lTKM5sVErpYXlGeaD79Zyd)biNu0C6JIYYGKmiHZYwLl)M3CWC2M4EcoC)S3bpiaGzum8hE7NTANhycoZ3)v7N9F2LM)JXEHdvw8hlzefRtOjccv7xBR4)3UjExugNYQRoJKpkFab8OrhMZQUdajhWLl)VhWoEfP8I9vvlQckuCtyQJYXFpFBwXGT(PG6BAbrPXeRw98qFV75(LWIiQyRWuSFEkQcZrwrs20D0fyVwbBilZRQIe)wwporuayQ6zRBZIiBopvtaDhGyzj3PBQcLIavDh1iLIykY9SJQ59rS7vQzDu7A5bkhQEsyMGuPkwnXkcTwr1V)tDZvs3CW0eKMY6NvyJ2w7ETU)weoDcswnlmt3U(t5uTz1vAi4VkOskTP1ApXeLIbvbfxwMdD(bypJOLQSTJSUloYFfyqEHFIaagOK(ervkF0mbYkl5wLGX57N969c95OoBWK2rPneBPk84rcQWmEJppcpEizpWIVRS7QK3gSgmgE6zf9A15QBaZMQQuBxyRALJgOyJMH(ph9ddP6e9UvkVoS4XAInaneNK6hcjNkW01UjLYbrv2zis(ebz1THErrfplxdiVJfxLaXHUWIMvVw)CQvlUMherYTMigKkW0frl07LZaxRnN2ezfJxRF)HPpJi2f)uwvsbk8fvZZX7WL7KDBfY(ydwWILj((F0xL)dZ1rrLqS00wKusA9QGukSOY9q7N4RztC1e4TyrAUgRkRJMNa1Y1Qca)AUx6Q5MvyyE8bkSOzEQj1QQjXlqH5ffUK56hTGvoUfPQSRzgbef9uONlvaRALaZdabeD9AFIDzgubW32lnfLzL6FE9XqxrG1lEgXM3OH(knnbzqMUMLMLF0hFuoBmg60yqA6tmKpO(LQOLXY79DW8hbhrHXrPkNFHhBZmlm8Q5SpBm89DG7mUirZnXff3nE5s)O06T8LI3alTzd0vyJjkxI2wTarSNe61aAtEe8i5unSQG5QIjtx7qOlKY(MJQu5Rx7qBmQAd80bRbYdZisRlyn7at1OubRAmCLMa1ZaRjDuKwhemS)8pOY3SW(wv5suFlGiYNnDyhK8r9dXj4b8hRoM32TjXEZx3O2OS6iIHYvv)B4NszvglawdzmI5X4ZJXnfSkp2S1Ez5VF1fja83RHG6agkONwR66LLFD4(zFhGoithbGZeyccIYHeS2mLR)mfpU)yX4ddhkYKvLunPox(wUzMVLRHA1sHYqLSChj5vdUOohiFxxuwJfBF6YuDmrnt9)JT(ZZqgm2FFJQZlglAoQFRG2llA13leZ7H9p5WIJOLd7CHFVIUEzrVppOyqoJgPmQrl5P5RvwWuRLWuE84gQwJco4ijoObiCyCnzwM7ifmS2hzBPOujs3C)jSQsdT0xMbE01fnVwRfVLOJ6cbvYi1pD3zhZURAtx9zwO6EPCZerColR5j9ACzgKwzNsoKSUAT0YjpV4lkk6uLLntR1h4sCzXJZi2e6weNg5Uw0tEiQ3)dvbvCz5sJ1tvJrz)S5kfMIy3TNrSx2gTICOLjl3Dwz1JCzck1a4fKauHvFEnnYi2yAJRZ6dTvmJK8vR8eHo2tRDj8k06QkylKQyu5v4tpTf0L(PuZAzwdQQ0G2n95QYJy0zwFALQeA1EarotxE2sdGir76w60EXMujcT8HLcnRI2ZkHYiiUCuEg(cmJLbjPzt92KofBJeg)NBsV92zTAGMJGrmVbViaz8wbudKgpeyTqBbkwBXAdIXCKt2TiwCIU2cRveKUWuq0JTVqfGM8fuKnKoTYxxNWfknKcpWTPlvRlTzEnYsFHVTyVqy51hNYrdvE4LsH734iixcL6msMtfaFonmot8FxRK3I9nkEuA5YL8qVuXum1gKf9jyblVV5ULuFjnAlZNEQgunB6QBHcsQwJ06kyWuKbQQ5LfEyPqr5CPeBR2RD(MKiFY9lw73p73yjPZ)Nf9WdlD51GeKpAMb(VaDwwqXmNBVQOVGWECzhRJPywMad)rWFV1lib)noOA0NqS(8XL6SWMJiUuIxU2jE5ASlBTs8Y5prIxU2jEj3771eVCoiXlEmG1mpW6(yxQ95N2MIST9kHGtQbMZmwgZ2S2EMjHLEn3OCfbLkSb5LcPgflETKRJMJT4gcI0h3GNxdteJt0AjMOHK)SECxDYxPwR9II8zleiNQe)sBAXQSHCZrBMxqxQgDRYSKKyUnsSNcBw)LeRfsSNiBDKwWTsIffZO6XqAdJQ7PTdYyNyaSehIfXZr)XAfqCXPVXaf7Ab38bjlSw00dg1Lk8RRbRff90h8V50pUUSyS1dOGCtOmh2VZe5MAaSlghf(i(FJ78suE7jNJYqaCjX3hSG1l7CoZRkgbgwiB7p5Vwj9SF2Va)uaa4i)a(ZndT7Iz9oTiCykhuxadv2C1Rm0k7O2Qm4QuzO1gyOugu7I4ZDLbfyTwLbNplugueOkvl0HVi7MNSrxgrXEo8Qd0RH5XgspV1gUMrdYwbf(6O5XvFnYkoFftfz9uTEUu72xZc2)eGqMhUVU5N8KFa74tWUY7M)iERRJTArEYO)ErBLGJf7Re5w1J6sCQNUTSVRvmh0eQ0nWx(aEGzODQ3dEpQ85g2rgtXBXwo1eHzbnPQvsrRCSfx6YE2soOLSptgi6zmQztmpJHZ(FXTRIrBa4jeGQ6TBJ5)VsxrYIjNr3ZTMw105uRhvwfLQkynLHOc895NoQ7aJRStcynVyjSonof0ds(qnBTtSHZ4iE2jUlMDVCgW6tLn3XOD6gX1KGgb9PF(gt3TULaR4ikBdl0WoSiAKKq0IdkRDizxegQ7kWISwLpg3vBwL4DeCsJ(d3WgK1S14DeA45MGJTEq30ZNyoFfMb23ddz79OhR)ZgtF2zmjqARPFDMBmzRrGNQWAhJamCfWQRAi9B22bxMl2rUb2ehO4EcnHLYXw7CxpWmzzZvmTr(UfMvoZGJjrcBI9AWWOFJH4pS0LNf8QJ6cQ2wEPAv0wialrHmmN(S3CCOL0YK(9ESEapLaSQD(lm6XwkB0J31QwPo3SjfhWhNARQQ4l0XCANi9XW90JzMVyd766Vk2CNnmnbW4RgzNVvwgb9iwGraRUFYgu6pLxIG3w65mr4gIuy9uf93iKrKvsTB1IrHjLUbxvJNGKYZyMZ4cMrrxQiaSP5)gVop9QcsGY8Kz7CxR7KoFjDayv6jjbyt5eZpRKGjT5EHpUnL3pif(9l)1PrXpyuaUzGdg1d07G2uEBTWiidYvFSlyCjTFVGmZcKZYP8afE85sAYyJTUWQVuv2vrg5CJ1Z4S5JJslyC1knIjAYKqtIxWIP(3ZqHflsh6)h4hNpUDdPhvLCqtwKEgGnF3s0Wam5i5izdCbOYkLnm7Hy2FyoG9Ek(E5y2w0rknQNvB4cVOjviyp3lay(q8alu5g4s6O3ott5P6PJdkrkPZFemUYMm6aUOICryIm9LFq(OaBUUcsFAo6P(uqlCwEVuBKr6WYgA7fMjPoL36Co2JyLjb)uhkP7aoM2LNaEEhVwZ(PY5q2)QqeokOJjfHeWMpT3poe28uFWPV0CWEDiZ2GbbXG7KN15RX4osf6jyZwl(uXt1weSpt5PowYtVwpiRD7Ty3ap3kKeWdoRg3q0xu0soI)NN915jA)Wu(8Vox5yeJZomgOX8c9jsIMxIBA0Eav2tot(eX6TOoJfeA(jrLSI(3fghVGhfq9Q6)Ew76VF23wCiqzZmDePKZC5mboi9t432lnJsycDOEgHC(1pX2D4HZdHfDSmgHviUkNo9)SBXQn(87YIjw8f8Le1IM7dR3EHtXJXQscNoIfJqFzqIpBbujGPJKWuCXg02YltK8jGryP2BflH3KG5FGl3O1rRj0XGMpb6qJQg2zb9bS08DgOJWP9gwywiU8ZrNuQj6IowWUI(C)lTp1V7oxpvlzKhQNAJ6qV7mmv5HRi(6xcAAIhHC(3n(YtOF5xewy5510oX0xuegEXFi2mcPtd9xYpsqJWlbgGvLvZmBs9t1EnuIdhg6qBy)y0rmu4s7WsXzMHR0Ucu6mtjBr7sfE)BIteTNb5jIFl9025bygRklT3T5x(q3dERWx9NDh5ozKlUP4p4LGz(b5rZongbB2gNKLFrR(f1aYxGx2b)F74NWIu2vNG3US48JNbethK5z6W9)4pXUagC(M9Z(U4iygzp(lk0kK(E3bafVlfOECH0amS(o)Xatqx(aYjbDQZpNm0h)Pa6v3w1sWT51yTme)Qtk(6m60c(jQbVk9APPqNtIgtZRpXtZ(FuHcuLH52P94QgzfnxjHKQSHkZdiGQuHZKaS0tBPu9rIXxEsGkHe3bdvLl95x0BTBDNqiTmwdzZLYXGitPuWRwSjYavzGlYq(nQHS8(SkbBQlXllHE19LvdBKYxlxwcXM3PwYMXiV0TSCgeUdUKaTIBNllTS3zgT0olsbEjnbevQ3syFW6AFcG6PKpCkHTIgprc(A6ft55qokG4T5mZu(1C1x0VVPYqvEd38sNbViphNbVOFFC2HF6C2Fv0KaVCYGbdo3z0OcuUDW)Ic4FHr4xrIogjrHEOV5DsafzjoRUJKPktGujLOeKveYPj8bkW2XwJCicL4zAAowM0Ze2tezK0DTJSZm13epTe4hDe))zg3NyWgHGM5Bv0Nu419Z5UNNRt3lP2Dg01cV8liE5c8URMNlOMNHMYCsQmzsmuIIO1GF21r8scWJpKxkq3vIwebq21woEMMMNNqxD(A5Pj)8NjCAzlbFsZtsRz498I21pJZnW8gp2wOk0uhSyLuazfd5ucDs42WK6zQw4UEupQt7yVZu8e(bVTx)(nFy(5GSNUYj)0tNzXY8tprb8b90TbmxRaHl2n9x4oOx)ZiKaE6jnSyfytXbl(kNbfRr)3n39Itf3Tu82Tr5tRuBiTq5sBHQj8ojwOirBh9wOA8yBHQrBikhYPe6KWvJfkx96qUK6qU60HC(muhYLYcLdLoutwSoDixfwO(VrU7fNkUBL4DJDtRsT5qIHQj8onwOOq7Jkgknq1OneZXq1XqVcUnkntfCpiNmppL6HeTpoNm0q1it2cNmDl0RGBJch1jIZ0q1i2AH4C3cDZW9qTi98uuUNl0Ut20a3gfkRt09OHQrjcl096wOBgUhQ5tIIq21YBptOD3iV1yx3pQ1Utl0nd3dZcNTy9Hb9k4EQB2f9tZrUfkuGv4AhscQkUqISfOhlU(8unvQPPB0mja(jI1CIa7jLvCsbENUp9UNMwJWLOU4hjyhtumRoy3Agt1bQDaOpn7Vofy7yBjJFEcoHAAowM0PmgLXDDNbQhSDnh)5XR)4tJDDkW2Xy)LuwCQDG7LnlO804BlO7AkGYWwhqbeGUtuUOa(rk3CAXzctYDbVMa0DdEtu5GUaVpn9nffypPSJUb4uH1jFdcibEYByaBNa5ZERe8PoAUnapreJDf4jIC8eb(M7nhBJxAEQT7v)CwDTtVANeVRN0R)zeN)SEvTIkXrB)kNELdHApFObsXw)8LMhY5grLPvNY(x8cNb4)xV(s0(KNEYaBxMBjU9C)fdUKb3P83sz8jebwiDNaiPbrCJbiRarb8os)CYPjAXjNM0CNqzSkw4CCvJnelFqNTfKDCuHuttN0LMua)G7stsaE8jN)6UomtLNURTj(ZJ3CNxlpFx070oUPkSR2qWIyj6vFpxeECnk(uga8ZZw5RPbekn(UtAPtr17fgZjf8)f35q4onImJq8UxF9IO9SPtCaGObhFXlidEOyixnAqPtB9tujOuoSQPuhcbZ2adA9phSLNFUIrMsP0eDhUO10zJhxt2)uMd(Zt1C104pg1EvpMtk4)lUZHWDOnD6EsTrOah)0A6ubcP005ZpB55NRyKPuknr3wshrN(OhOhyOS6bkRAbnQMwDilpMog8hbIVXlfsY4rD4D1q6wGFeyn8SuqKcsqslMxFyD)KCeuWAK1Od3lgqxc4JaFXBckDOB(Z7qW2EKniDiX38EftH2bxBcP7NnTgQ03cS6b6bg4OEGQ3sI6X0XG)iqCkBjkhs3c8JaR1zdHCyD)KCeuGA7jkgqxc4JaFvArP5Z7qW2EKTfgQmm4AtiD3MUnjE(q21A72uD1nHACD80GCRPTh8TGT1g77nAqLY1j7Oh6X1XtJw2gn4BbBRnsBn2cLAknhOBrkGEujfqJPhwcXNyWBbGT1FRw35hp4PS8rd5GW7dvj1X)zRaIJAG40sGyETXIQu31G3caBETXIuopEW32L(ozv7yKFA2cgKh5wYJWBFcRy45WvTPOb0h(2E91x7gnN(2bN33z4KxsOncpvX7M(y0C89EzTPfzCFP0QXGx4mA0GbdUUV(6YR5cmqgbDmIGokrqhje0Tgcwii8z(k5fF6wjVWQvYMi4Z2kzocwz4RrhuK)cTs1NciTYie9D4deJKx4k)S1Ejt3U7JFmeygX)HkWsnq7NiBJCRnb828UtUIjBhPPzGTyMSL2AtuPYxxIL9uIxTVDXLZHYNsUN3uBTEqg(UyB3ibyHNqcuI2anXBf(DMG9TmCzs8h9XVjfEB2kglHXr22j9iUVVjVJbdIwmniAkEXYg5Nk3YwYpUj4zn6YY4WW4hcWVgyEGPjWj(d(jWVdwIwWDONHdJ3ZB7NH3584vXFwX4IIzDjZUOAJEXcCWl8Y8UZl1)B2)JSpNqyU(eDyJxmwYIJP3A4uDh1hBe7xzhD3VPh6h3nI4PU)ZuU6XF12TaEAAS8pf68enNy(NSLvjOYH0Su7zTeUhmhs5sNe0AXciXXCQJ0riGEx9fL40(jLG0zzx0EMgW9JZ8bLZMUbZja(rI57)X3XePrq(M6UQqP1BVzBs8YGq)BV5V932pBDw220V5IlwfKTE3Dqq7BUinyZUqMgW8eVLz4)E(fWdGiHsVame8GxcEMZdIU4BzW(xZVxL(jCgUG1O48V2q5yi((7)rCY(9TCAb8ec0pcK9ZUjyZ3b8H)PxY81SpBr4NNfM)Xrxo(Y3mFjsr4l)937fUdErWNShagEuBPvFa4Efa3G7dwG09DpUFgVxeGmYxck3iIadi)Sex8n7KFAIHFh195wT5JxWRGWmmC)S3bpmid)reBaqSgJrikgnvGnE)cgW9Z2LaSChCgdXpm0f)YOHtGLa(ss6WY(O9LxvMB0RWVGnxvpjNxfV9Qu)SGLVInPx5W)FNIW(kaKVAEC0IaeMxvfuVy(tu9aI2E)Ok51ttteADVE8cn4b2RhTHH6EOmu3UKHEAATO2ZqjAEM2WqZlbsoJSU4xbWfLKe5IvxGBkkiOYhMVbQkF29vBpPYNVgFxLpbdeFG4tOZdSnSgxLSgxcwJlbRrrzYv(WgSg17CRYNlXACjzn6srUnSMQc)0qvCIOUy1sIYnVsPHVUbdDBjgsS9AkTK0nyyX1zOm(5kIEociWXu)sYYxEivV84kdTcfcRlGPu9ljle9XvhAfwZSUcMsfWSELOTr8yH3gmNTtGuc91BCDS96RQtm2G1vZf)UkTH)e1fc8uy0wjcqvjYUZ0yYd1DxKNkr9kgw5)VQGF2a884bY)8guyi7n28QPzE4bplb)(jOab1uGGsKTQOEc4F9YXbH4VF23(R)0(z)R8zF)SFH9DlgYn4Fe)W(zB2H5h8E8J3W(z)kpkEmxITGIke8o(vnfEh86DJv9U)Uq083ugdKneCfVkBDIF6AGf)Q8VNzOgec(0H3fNcJavQGH4NPf9)DwTd5z74JlZ5taEFgbspRwvqkl8bzLnSCdFyTFeM2aK2EYCwkpi1fImc)O4DRwZFJDyYfFFrsnVNLuZ)MLuJnuQiYSTavkP13m64iVTF(qCcC6sYBSDuhx2dCRZXG08s6Yg(dqG6yMOpkkjYQJ0VkK75pGbXxWG(fXssbPtcpiinVSXqwTR25bwnY89Hmh)p7sZ)XyVqRYAKv8ko1I4ciOwsTxAh1(TBI3fLXX76QAiaX15fSRTbs9lgJ4oSszmaxUm(EW8HnKqXkgATrPg4RfLkz0Y7Wd4DYUTzLWhG6g0(YYeF)p6NpScQnvCyYM6MUn0lc)KWMBKR(bt)kh631BXI08t3VY39AnVllOFgHN)QLoAfWONEQXPKxdL4dUZr)dlkmx3xnml)vb8FanCB4fGfKd(RSlUaH5qYPrPH)YthDzQY1pzZ9u(jT(Tt0HuBv5ys(RTyV(m424JWy(fMWBZ)AbD(4NEs9a5iY4bcU1k(UlMdBHpeJuqvyiC41F8l77EErT9A89wCGWtf(Kjkglyd(rrOR8VT8fR)6QmroYPSQb72oGSAhS3s1nyr(4fRMU(7aENrvxY8IV1GQFw5KR6Ybu8cRNQ(mkEpfkyue4aMfLFaciBxOhAK0BlK9N381nC1XCwGx3SvHOa)ukZajMpo7JC9C2ElaR4vLAehMxw(7xvqw4VxhVle3pImVAbav6nf8Q8Da6G2Qra4mjvyNiL(CGJXlfk4BrruXn)S8jNjH(IoLValMTbzHUkgBvYiwb7RnbqA6J7Xm3zj7AbwM6A3xEr7)YokYqglqXIFAZgpH9Tl7TUgVUxkXH36mIMAZzI6jxHK8oUVYJ1QPQAkCi4vpyEqgO(3t78QLSkOheBkCcW4BLGSzGr9uzHYGnsTy41JgyCv6)V9owBTXrs(BjSG3OHzYyPeNzwWXWWYDS3xUdUDoUVnok2Yo6IJvqYzZgiKF7xvDR(PQQBjBF7ewogyiiz1D117xD3gQKhKztr616uHaDn5rNu4Wiw9BjyoE5fNdTOPNpE0j9sI0yJCi43En0Zohq0EcjXW77h6EDUj5jE2q9Qb3i3hRRhANZ1Olaed7GCsFhLSa2(BrDlF24d7X6YsK7szKhyw90khpZonKlakxLamuR)xIEcqF(WbUvq(CVphXWkUSQTfRRf1KdCNC7Dk75wp34YcZB8h9UhVvPV8cPlRxnb8crEQzjRg6ziQfCbyDH(xAKi8kzSXbgT)YwpYXHzJSMpJtIQYP)sjgsTQmTquEs6Li09xVEke1geM1QR(rvTGF6PNo7Pkik98LYcc)qXMnxbQ0VC8hfScFOC7QhBGX4hN1gE4FR9bt)y(mma)YndyKNKM9P0pk5l(q1Qpil79SobrlhCmE5hFacqw2Dwyi44F13jlDsw2N(Ppk5HXzZQwVZOJQvoVyC9Ohygx0kx1)PDyRXCS)X67qV3ROCDhRj5GaFgf8lQW0Vf4Be6abj7YT)w1Dax)VdCyBbgvKJxzwcDKwXr8(YvmY5bClpHmIHWf7muelHVWQgrgOHTAS8TGgW81Gqgea4Mn4AIYRLlgpYraFvzneCD(9nZX0qof1IgZMxiWmS)gAJEEaRUGfYGu(Qm90o(aJ5Baw43)E8pGWoMdA3Ukv5XpzgSruquZSxAazReqmIQYhY6g05fzQSfCe8uy6LGQXBQAAg57fdYLdOM)TinKyiuGS0dBk2PIx7R1kuG4V1zXhetAU71RxdQ)3EMJOcGuxwnNb3nh)mpCnGozfsCb30jU0XRfDTwlctLwrbyJIRfyqDW)v22LAcdVVxLQsmXCYozvWQ2QN5HCzlUjhQoAKoJK1Pzt1ov1relhRkc(28M084D)0XD)K6xKuZZ1mSTJz47pZOi8mheE2B0lgWJhcN76wmLbH39sTj81bOqc7NVnF72crsUrOZUfZ8LE0vBQDwO1U6kI0r()4jVWFsYgM8CsiARDqwZiC9xNAEG7ji18sl91D)n5lFoH0SrY)lKSiERryE2voAEhH2oIsyZ4jShUC5F(jShljysDnHjS)GSBoR2U5z8)lKE3lQwv7qaMgRRWokv2YPcxEv)c0GRiz9UbfC2Rx)pQLrgSTOu((4J2nvcx0DgNymEsJU7J6cJ)ym9kYvPI0umyzpKYEkTATdHHfETpBQi)gjSYho9NKfyGCE8(CgZ)2zzJ5lhbTVMOZBrvGqsh7H2H40XmB6y)f1COJzVnOJzrPJPFNOJ4Vyo47WYGo1p8GGi7)AfafBngsmn6hhpt2suidI6hWU5VC7UCSStTD)WFT43GGibnUlaLTFvudZ2Op(xQ6SI)wSqR2y6BREAtB(SA2jeuwwbXzJJ58v4qE2UYf3H5ZVBT7oew1eZxtMrcR7CpUuDh20yBfxjmTlHR7GxGl87Hakl3IvxpjPTrg(zkNoFOc)RU(I8)l7R4JosL9LKLpZr3q(nv3xUvSiMVP8(BeoesGwyDTJYLjGDctRaMGHc5nXWnG09ASF6SeUZFOOUb4yQVtlPpPpQZOazkIcjOzpqWWxv3aHq100EVlGdL(RuD4i3sKm92kbvcQXOOLMfutf3CGDpAiD41FBAlZNF6yjFr3vjrvcCVTpCREjirVzJOag535GGom0H9uqWNZYignjRuMZOKdg3diiyGj2LrE6faPJS0vK9y4i3c(Y08F9bhn4mh3kktRsscxtIZQo9tSMe49vXXcG772lYnfNypO18tDVNLy7Djhdg6bW04CjQId610wIyL50DI0MzPXWI008HUaTNeQpQRP7Jvq8YwiXryA2Nhhw7j4HYicSC3gcquUvWN8PG2rXe5IoTnk9(fpVydikI3Bq7AADpb5TqpOWNPl78YsGSCEIUvaTgK5TpdH7r81zkM02m3(ju8UNEU((M5RES(zeYm8m1Ly5GRKT4U5AItv0F3loUi22gOs2qEN1d5sIL1j0qTRlqxLoyx)O9wMtVLblPBra6s1CmwnIybg2YbewYlxohcWah8LlBoR43Xn38i)hJEH0DTSFqnzyeddUhDIoy0Z29uL4p49yyK5hNDB0q(ge10rhqEjScbnVl7DnW6GaBw8mi9z0k2n8iwhQDRR7ZZxkduN2MWi27ZnJCTP9Phf25BLFLzcnJZYyGKd4kKJJWsIJayCXonhvNlGrg3pmkmhYn7wKEw64S6pGlqV4Du5FQwUVnVVah(fg43z8SsbO3LlyuKRrtqs3Q7FWRFrsH(NI2h71R)IURYT93Ctv1sP5NoAG161ulc5UgW5ZbnBf1yw22RphcGnhB82h30u0ZpzdIJAM)FEC567b8qp)kSX5aev(M5yxTVxW6QY6cb2AV(6BYxl8tSUCXDndoXpTbW431JbNaYyty5FzMHO9vPE3ReG)(DNlyfDYZbqfS3TbQDNI6sJ0cdzEOs(RRf(GnlfwXI9VnmvOrVUW0SfLISPLODg)kaT4gnK7UVWUJDFpkHVyNLxrSfrP9fyIVBMVPy1UzJJoj28hCmMS(ugcCItVZRkCwCDuHfFiGzCToYXadgU)80jjh3Km)cYrPhFlUmCQUfjs4cc4aWXYL4b0otOZSoDE6jo(ql(zw3kQcoWzxDXlV0JF2NtALY2355Z9AAsDoGxcJsgK6fMfF6yg)uTvEGhbcTZLxatgJREVqMLIKe921BWQ1om0aJoLvahmUh4RFSjFPoGcc0vmNgMLQCWNeNYSOBXgeFY5h2YLthQ)6LhI3FmHvwnIa6dYGll29IHJD)P45CA65SiNls0kUu9R9xeA2ah7Q2jwggmGutmS61RYcQuRrQkrAsmJyWWZhW5YWy7Ome8k2ldDpSy38ZNmTZZXm3nXj3KtgtmzDkRRP642Bzyw1UCuuEYp1E(WzFen70ozr1FpO)bLkQA(Z8I3DjQrIRk1KOI6T4yzQxM0OZiQgo)8Xk3J4kakzftmPf2DZ(KCCyQ8Mxn0Mrr6pM8z(w)9ZZIzwRdxzYweKOBui(A74k9dPu1)bK7VEfdPZ5BkjLvOGKmhQKajfLRJqvVxEYa02vvx3gSLnx0L9sawWy0EoaO1LzFyxesJM9cEFzbB1Ml2FkIQzl5l74u37SszG)etVQi1HoLPjbSDFKqNg7u7f5XHp5XtKP1(BKfSK6WKzFO3eJdgg3BWHjcq29NPkyoVJjxjK35WZnaG9hGwn2gd64kh9hYs0xpDq5qcypq8ymwE5f69L8OQsjLmdZ2(CkMqVOjCGoxftN0DqDtXYlVyTb9vN7jYczpnlPtYnt4x2XeL0X(smDdumlXQjwj2d7b2eS(Ic(B1v1ENEOQ01gQ2tKZ3V1tp4wddChv1)bNQa0esxEpN9diDqPyAQ75aW4(ZeWRkT1ZLVu9xuBt6xVgpxRnJDEvHRU1a(KWLg)O29KtYbH(PpiLcym8uAErFU2PxK4dNX1xhnEiQbIvAT3Kaz81J9)YdwiAGgeoQ0vE0qxS5acTmBsSgMwduH3oYUZQP6HPDXdbd8WcY0IL)AjMiySbYrSfvOeoPk2hvxQtquhp(gQWsCpe9HK(YUIBAdIqz6)sKRoiSMNbNkAzmumaMdSZe(59y6qiTczrhlWda8b8sfW1EqpWIFqjkweyypMyfF3KJr57RslJNC(hgnggCcjXPzoLoik5Gw59HTio5u7sCe6OpPF0Dg6RtRrDKG9deKgaIpU52UdXBwtf(GAxJgbBUsYfW4V9RnpuS4B)9SjPFBh8VV9F)]] )