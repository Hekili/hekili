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
    resource = "runes",
    times = {},
    values = {},
    forecast = {},

    reset = function()
        local t = state.runes
        for i = 1, 6 do
            local start, duration, ready = GetRuneCooldown( i )
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
        t.actual = nil -- Reset actual to force recalculation
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

        t.actual = nil -- Reset actual to force recalculation
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
        duration = 3600,
        tick_time = 1,
        max_stack = 1,
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
        duration = 10,
        max_stack = function() return ( talent.smothering_offense.enabled and 5 or 3 ) + ( talent.dark_talons.enabled and 3 or 0 ) end,
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
        max_stack = 2,
    },
    -- Absorbing up to $w1 magic damage.; Duration of harmful magic effects reduced by $s2%.
    lesser_antimagic_shell = {
        id = 454863,
        duration = function() return 5.0 * ( talent.antimagic_barrier.enabled and 1.4 or 1 ) end,
        max_stack = 1,

        -- Affected by:
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

-- The War Within
spec:RegisterGear( "tww2", 229253, 229251, 229256, 229254, 229252 )
spec:RegisterAuras( {
    -- https://www.wowhead.com/spell=1216813
    -- Winning Streak! On a Winning Streak! Death Coil and Epidemic damage increased by 30%.  
    winning_streak = {
        id = 1217897,
        duration = 3600,
        max_stack = 6
    },
    -- https://www.wowhead.com/spell=1222698
    -- Murderous Frenzy Your Haste is increased by 12%.  
    murderous_frenzy = {
        id = 1222698,
        duration = 6,
        max_stack = 1,
    },
} )
-- Dragonflight
spec:RegisterGear( "tier29", 200405, 200407, 200408, 200409, 200410 )
spec:RegisterGear( "tier30", 202464, 202462, 202461, 202460, 202459, 217223, 217225, 217221, 217222, 217224 )
spec:RegisterAura( "wrath_of_the_frostwyrm", {
    id = 408368,
    duration = 30,
    max_stack = 10
} )
spec:RegisterAura( "lingering_chill", {
    id = 410879,
    duration = 12,
    max_stack = 1
} )

spec:RegisterGear( "tier31", 207198, 207199, 207200, 207201, 207203 )
spec:RegisterAura( "chilling_rage", {
    id = 424165,
    duration = 12,
    max_stack = 5
} )

--[[ Uncomment if enduring strength buff ever becomes referenced in APL
local TriggerEnduringStrengthBuff = setfenv( function()
    applyBuff( "enduring_strength_buff" )
end, state )
--]]

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

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 0.8, 'target':
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 434765, 'value': 10, 'schools': ['holy', 'nature'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'resource': runic_power, }
        -- #3: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Chain from Initial Target', 'Enforce Line Of Sight To Chain Targets'], 'ap_bonus': 1.5, 'target':

        -- Affected by:
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

spec:RegisterSetting( "bos_rp", 60, {
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


spec:RegisterPack( "Frost DK", 20241206, [[Hekili:S3ZFZTTTs(zX3nrXk)qwKYkPPNTNPTx700RVx7e3(Y)zjAjkj(cfPosQ44mE0N9Bxa(daqSGGsuoP37nDMAfsWf7Uy3f7UybWno38h3C9CVm)B(7UdDp3XD4Rgm8ndhp6n3CD29B8V56nEZ(G3s4hrERH))pLeNMTB6)9)d(M7dJ9MJqinEBYm4TRYY2K(TND2YGSvBVDWS41NLgSEBOxwqC0SeVfz4)E2z3C9TBdcZEB0n3QV7hFZ1EBZwfNCZ1xhS(haihmFUpV5(PZU5AS5V0X9LdF13UBk2KDt3UbH0UFz3VWFPZlDDGx(21Bc9x7hby91zydM(JFAtIFAkGs7M(FCBIVx2QjzbZ(q6Kq)fz)h7MMfVB6k)Wn7Mcn8JSpDEs8Mnbrl3nnEl8pJxSBk)l3nnma5iqlx7LTnXp8EruyiIc)jhZM(D)(VYbo024pcpiYpnZF(UPEZqguA1ho8LJgoWf(0)MFYsFfkC6Dby)(o)fW3fNSBAquyqu5ZFF87)zFV5YaJKln8LUVbE53fggFhGCjbrFWhiNTPLW73J)jG(ds9Un0F()f8Z4ONcT4oVuexENV3g)KNMcOQxYhKG7iaU)uWNGEoEByrlLAbsHoodgoyS0JDmGToIm0fjXR5nfWRvErZd9z47zFF81aI6NEF0SkU6W38s3Vb5PbrixZB()CBAgkzi1eNZFXUPytjXcSrdlOTnXXaZF5KKTWGzvt(Mx6(keoWF)go8gMd3HJZ)BXZFdVFQ3nVgg34WGJtWFhNdZZP)ggB)pwbmI37bu57HXWGOBUgLstz6Qa2g6pjZdeSYGh83z2a8JydV389GIhty8MRxGQ6tsbrIp4Zv7sc2WF11myaDddiWqBCMh)nqBY8tc8aZhEHaRDG3Kf(GKYK4ftaReHPdY7PDt7HJq3UDXIbjEFoojyM)G0mWAZUPxUB6y27ZHr6kVmeQaB(2qV5(sWGbHA9Y2n3KbgvuiTkSJ9vFiiKn2T2BgWJe7E3DtF4HCy7)j4Bwheb8zeSL8N4BdrOHwVGUAezxDAhqN954dakuoB30lyOi8LNu(XaCrlsFWpr4Zignb89Cs89JEWFGhpijyT)eeXtfrY69tvNSk(UWCSpnd7LXTBay7McIQejK0VOy(VISBweSCv2e02CayFD6vvCCuYDqgsIzXt2mlBYOXm(k57hk858rb4F6wHsOGh0tOroeNEnjorqEbZMSj(oWcj2bNk0MKnfJc5YaNyHedhjlG5G5(lcMfKXLCgYeOmiC8nMh2qbJIXkj0jFYuulmiAEI3Y4uVkucX(8gcVYhBw2k)jqN)z)OjZw5TEdGnYTFgWFMhFxKEqxoU23Gm4BoObItyKi2ntWjyg4UsIqmOYsZEDg2wuYNRckIgu6coQ2ZBe4f0RbeM2qAR1vDOTuEc6Cr2aEVVa88kza6xgasddVo0wYuSvQvFa1HhVpsYLuDwYwWmjV9fIRm4wk7c(XgHG6UGOmSV3MWMTC30xcU)mwr6vSPm6J2gQTORjAFyvF7LmZlcn3LKaW8g8)UEgqctw57Ly0vbq3fudXUpyMQVc)aaHDt)zgiOnmddslNnFWAVpvmwio4H87tYNoMyod(ONSEAH3bverXmVxbt9EohUw)j7M(nLte3HycdSTerCkSGB0hNkXJsnqj7RfDXgGo8sWrpMMxbDyG1H9pNs1caTJQpJ1ENDtFo7h5yg7dU7(K1PtwSn5EjKRu)rTrGW(875CaHHJTrRIdVhTA5hTmBLezO(oTyyFkbAJU3zbxEot58drOi)auUErm4DXGfEHH4eFjBtHzokNUX0ysjlHKLFf3KIWOJXHqsoxjBL4ZhzMFrBu2c(1jTIL1mr2fmvrdL1OwAt0wqQMqTggdp)WgdFJIpwM0Jh1iV(CJsezc(bGnWWSjc(lC9S7NvgSAk(jwgcXPAdEJtVgM65zSPB6Rmf2VjG47M(DaAIjVPmO39oqZsptS3kApX4ckJpZG7r0gU6EmRqyMR8cZKnzU)mV7lgtkr8LEt2KeaHcNDFfMVm0BwGx4eV5F0lsVre9zM4ldfPr0uJHGMW4doXavTXyIwy9IUKKOLkudNwRIztQH6bnDuXF5IuxnAx96sYtH1GTh6izywx0XzudtLsVqoZs60P4w5ieT48T(IiQ(PAl(WIwAeE66qkdSJetNfDEoe9)NJUEmdVt8J8xh4N7QtrMm0XrRfMDtAJAI6Ga5oy92(fMxAmbesHLQimihrQk)5sg)PEYk8NNB1RcBiyG0PsGt(88azk4C1jgBAi4RDoI60PwOLAdjPFQrTyqBNuSXK(OTxO9OTudzKXSwqNs2sa4uyGUIvGG1ugj(7ogtRk5urucOGz9nj(ZIxFRN2eCedFBQFwWcjF65ls2GmNbR8sNSnL7fwHSzUOLQlgkE9BBIBoTCr5W(R0v9QCi9edoWx1kqYFyPD3w03MZ)QewygnlravNR)Xp6fUfCPaup9kbsAvp)cCXh)yWCeNUfMBJtJ8LGLrLqd8xNl)WLTUdMApg)qCz(kwMwS9vO(tf6Hb7M(w4Lbz4drSXhxmr43r8LQfMfJfRzIF22eGuCWEmexG0INmCW4bSfozcFvYZPIjotWvGSs8Rqre)f0ntqOCZ1WxN)GBU2rx0ecsH6GKAV6M3RAKyDFKLyD)RHeRw0uuI14WL6Cc5dxKd71SGuL14Ak8YdxmwXxtVSFT3hKoidy8Zw5NeVnDswIxu66aCsw9ki84x1eSxl4IUM5IQc9sy8xdVuLl62sUOBfxuDE7wA6WzsH8pXeEMrSkLeHpbXnbWwO5mwxKMTeDDnJUnXh1GUUgrxvNpAj6k4zNw3Zu0kK9muzWMqkVsjaLOoPMQB177ReGdb8B0A(zAHr177xM6)bJzj)3KAWZKJiScE4mAIWQyzeKrVGWpgYwvnrjw2Z6ZquNHdlw2G(S4hp1chS0rGowrGASwsqGowrGoAiqxscuwc3Puu2vxopSusEU3ACL7pebADVxuMRgLHjxwHfyK0utKslMiHzFZleceAfqYB2(5pdrgDB8No4z5w7fT1luBsjAb65Ah61KzV6wrfqpIiGmHE5bIdoBXt1rkeV2ATL9XTbzydWfqOQ4HQqOK7QMiRwMdAgrGydfawU7FjBGUlpze7HJATSCvmulwsSHO5tcIMm3l5dr(PP64fP4IlmBIqo(1f8psbj(K0qDEr2kO5Ra(pgf2cVTHzmwaoSKo424uOnkXNXkA1)roq3n93yp(B3n9NX6fD92zyLOIHWJfEjlgmSaxXenaHEHPse(MzqW2SuF(9cXIDDPt5At4GLuMpkZurDjblxIc5L02RhAj58NP4GeVIxfb62i)cWYjT5(zSvucJZCLFegeiV8NXayrQLviT(rXBxUI)fSAP9hlcr9DSquFplevTzkzpOCbKuG2hDGK(MJmHRZBkliC2QqWP588zjqZNBjnZLE9IUNJxajKHLmlR53bXKIMtVxuwEbMlHFxi3d5vcpNTjUcHy6eGxeWsGqglRgl36bMGZ89FXUPyrhZFySx4agJq3KXwWikgNqteeQ2VYwX)VBD82O8cBxwDgjFu(aC4XGomNvDlasoGlh(FhGD8eT5f7RlfBfuO4IljJYX)iFrxrNT(1a5LIHiJFIjHFwOV3h5ZlH5gvZcJPz190KfMdmrRSU7Gx3aPe2qM9AD5((cwfprKxBQ0ABAjWilvpDDaD9Gy5kj0YkjUQwPgQvettSNDuQ8pGfLZULm9aLd13jmtq6ufR6ynUwRjP()LUulPRlxAcYWQvKvyJ2w7ETUAxe2Xckwnlmt3UQv54Ti8v6i4tfukvwmEJ7JIsbbXTMqEIomnta7DeLyLTvO1TXr(ltylfGaa6RL(ervQzPzIKv2YTkeJNTB6R2ju3JMSctAj9GRx6rdfuIz8M81FH7ugF1xkR2k113RgJHhGwrTx9m9fKzDLvQsTPvfPsnuSwXrBt9Xu1nQe387LglW99xsQFieZNaLyCjnv9nPSmsuMQbea2e6ffv8UCXQ8YcCzc4E3ClQiCPIM0OQHKHzrYvACd8WEY8O56s5K1CTwSJouf2EL5ftM2EVDELKv5QTgl8s2JFloANSDJGp9RX0aSiX3)Z(6Sk3C2juDXdh8u62cx9tLZTqPSIotUTVJVI1XvDG385P5ZIOZItZDaPKTKuNq3KNVZsk0pAolttZnTQigqaXXFn6Ak5Mrk7oEaiahhx5tSaQGCi(1EPPOGJsHIB29WkcuoVqelJIb6R08aeCu6kwee(rF(E1anyOtTgzOYUq(G(pQIwgPUSUbZUhSWgghLQT)fETn9SqZR6ZtzTHNsD(SmfXqToUiVLXlw4hLkxKwA(cmRD1qxHCUxoeTPAaIyHJAEaY0AYBYRMtB2XgTFU0(iyy1Qizcw9vBwJiTj)fSdmvTshSKMKQMXQlnwkWO9(QbXIalaNX8N9bDtJPTeHSCBlEvZfFVI98FkobppfW8Z4TztsS3Sv1YohltwOR4vzGfEukl3mbWaiJlmlgFFmUSuvrsLTYll)7Ro3gGFVc8rh4MG6Ku(Dlta4GDt)baDqoocaNXP4HsqoKGbMjCX8j8JkHzEHHkLlt9W6ivnYx0NM5B5kswnuOZRclxsmE6ilc0gz7MCizKyvjx6PDteZe)pTXFg7OIaRBUHYSIrItBEARG2ZlkH2ZeD7M9p5WIJOLn7zcpVIUEErnf3VOrodhQ1bll5P5dvwWuL8xp3Z1gsxGgoORchSbiSFCnvwM7qnmS2V8BLIsLiD9eKBvGUDEszgweECleiRthYcbvYiYB24S9AfdTIy7zJiHMaBfrColR(gpAuzSwwzMs1XPUAS0Yopp2Fn58OYYwtJ175qCz2lZ2R1XvIFqM28E2LaEDouCE5qJ1DvTwzFV5Q4QPyvJNrSmXnAfzFZst(0zLj)ZLjOibWZibOgR(8O)Ziwt4ghNn7wRyCd5Jw5HRCOBE4s4vO1vLVqiGUOYZvMEgZNi9BP61(fk86ck34QoCz5w35eR3fqvcTg34fNykAyLgqeoSSLoJNZgvIqlUBHq1syCpiO1dIZhMhhUaZyrqsA2eV1PtW6yGX)5M0BVDwRAyZEWig2GxeGmElbQbc2g8RwOU0eZcNuJymh1qslCfNOSHWQydIwyci6XwyIcqt(bAcgYKw5RKjCHe4Ozg42uMKYsBnpgz5CHxuKkEwEhIt5OHUz4vIG7p4iixcLARhMtfaFonmot8FlLCyXcxe3zNC5sURx6yknvhEffQwbl)0MlxpU1kDSQ6b03mZNUR6x1BMYzHgssQsoDfmykYa1v9ScVSuOOSV0ITvl2lFNMPUxxkg7ZpG2Y)SIIiHfT8kqcYhnZa)pqNL5umBYTxuuykyrwSLvYomltGH)i43B8csWNLFM9PwOk8cnHApMMJiUuIxU2jE52yzEAL4LZFHeVCTt8sT4RLeVC2lXlUpGsMhyL)Ql1UEL2MIQT9kHGJQbMtAmfMTzS9KMew6vFDA14uQW6ZwkK2OyXRuM6OEBloWAiNJR)JRHjI2jATed0qz(SE8P6upHNw5ff5Zgiqovj(Lw3IvzfHMJ2SzbDPknIkZskI52iXEmSz9VLyTqI9izRJ0cUvsSOygvb9rByuFrvTxg7eDGLyxuiU)0puRaIdoN2OJIDTGBEJufwlkpGg1LkMx3awlk6z25)Md)4QYKXk7qb5cq1SB)oJvx)FWUyCu494)hx4LO86JnhLXdq6yCxoNYQnye9Frrlq3czlsj)ZkPNDt)n4rblWZr6a(7BgA3gZkExr4WuoOQa0kBUMvgALDuBvgC1Qm0Admukd6NI4RDLbnyTrLbNVkug04Ok1jzHsrhlPg93aGM5HRTyE93)tyvVbc3VD2945rnUQ85re9NfvGa2wSeeuRSkQdONEMwZ4Uw6OFDOsxVv5n4oM2(eV78Ux77ByzbAAsF2OPb3CkOjDLthQQXgCPkpVnX8)QCgHw4oOC9E2KOxpluBSeeFDxsc2OL5Y2IYU0j9SjPdtgHi9cSuQcZbiyf33NVDkUf00zBDijRojS68nfezs(GuU0gBdf6iwS13gZow)cyLvW6Bz0UXkPSjYxh91q)zrjnwSNgTHf2qgXfTNqiIWbL1g5TBgHlkpRClISqDVEwTGcIhROj1Q21gweJ6vFUJq9BwhCSXa6Ib9iZTRWmW8xyiB9H8yLi0i66kTjHqBNBPjlFMStiWt1yPIranCWFzkI1tRV0WNNlQrUiJe76WEcfkJ22kT5m73mzzZzLCJ8DlmLCsdtQisyJTxRfA9RBy6zlNUYcEf9gXWcQ3wEPEv0wiaRqHmmNEdoCyOvpRxCOcTZAfbRuIImnJjx84QIvrWe5AZ5d)XASYmMr7ksJUf3B)s9LyD1vZIdaJVzOCOGg1JAwHmVGyAOXnMjn871xBq9lN3LhU3fLZWMiCk6jiGOJHwlDP4yd1Uku0dnfVX5QK84mK2UxZdYLvhvqNfvCGaWMK)mEm796i2p92MCeTZzvkEjbybweZ32vGPVzEH3VjLV2(f(hu(0jrX31OgrDhmAuXY8e5nf9ylmwYGC15OpJlz82rPzwGAKm8myYzbnnjKjs3I5zTDQoHrKeVG5ty3OBS9oYa)pH3kw5MkuExGsHwOW8ek0INx)JLoDGeLuklqfsTEJdxNB8MJP9dxs51OjoztIQuC3E1FvHjEn88lSrZ)L6)wnpU5rcZmCJ3MonZWBA(3dKTZvtqMc)Mdj7Uy2pAo8LEAUWrAMV3kDoDc9Frvfnps3Wz4FDMOWKMEbWyp4f3CDZ1EUXlpeYuP1Z0aOcPKo7EygmwNr79lL)McDutNC)Q7Y0MtSJ0vRGyfPvUVqp3OdSwHwsBeWgCTONzwELcjmN(28CCKx4Nst9OTduDnXk9qXy)uP0zRqNAsfxnKM1sVYaaRuhK1LrhGcJbQnptnIMFAUhvhOljDDjXtyo5AZhvwsQ5OLXdVfIzZ0V9JpN68(42W445CZaYzL(DScCD30VRyxtPn5sfmNQDi250PHK6RQqgqjYp5d5va95wKGrkiLVDN3Sf3HliSSirzuWkehftN8p3oFjEFPIGBmTNincoSEHHXtVWj4wbJbn6PzBeAlcs8zJHmarBfVPPIBqlnpGE1YexyOZBjlsIe8QeMHlh0LgvdwmiqhAuLsxDKnMZQ)n9nr4nMbgHRqifVHmnJOGDbZbvjgIFxv87vdzKv(UuR23TbEtH0DjXnwgOjjUnl534VL7I1YBXpC4PHZsjJRKD(lRUVS5RbnEOcaSQmPAdprENFkHsC4WqN9FfRAWVytuJDyP0vwfIR0M21ozKw2IXHk8usd7iAl)6c5U99dWmeUgOZpml(im7d(P8BJDhxay35LGE7bZ9Xkz5G1BItYYpo8EQeqEkUHG)F3Yld5u22l2BBwCEnmdoYaEBMoy3V8RSnPmE7A)dXrqpYE9tl0kuUJIaGI73yQxxinan7uNp1VjORUlsuGo1Mmrf6J(sa9QZuuf4w)WgvfIN35q81hvoW3Oh660Kv6bttlyzVKqFqmP0zgAjvF(MJkFZHyGUJzCoJpYDZUFrJTMQ5WANHgx9iROLDfKu30nQ8acOQKxbfaRM3I2za4aXyczJdeQeIc7nu1o0NFgl1UXDcmR0Tmf0QM7AwsPYUXPcuT(4Pc5xPhYQlEOcSPo6ESe6vNso1m(REy8yjeRFs6OAgJ8O2XYEq4K3rb0AotEuHjXuwkEpQaxImCAjS3BTGVaq9yYhoMWwt5lOaFdvJNAFOm9C8MCEzk)4S5PNEAtPcR8OS45o9FsECA9FYPNIDo8ONX(vXss)8X973)zodhwGXTd(Nva)ZAe(vZDpSrsuOaIRV5JPilXE1DOkv1ei1sjAbzfHq4I)bQDqb2oZ3M8UHW)HhPU5qzspsyV54SkounuNLr)rUrlb(b7k(FLX9ZBWgHGM5fAQkh8C94zUplxNUxI0HdYvcF8ti(4c8UR6NZO6NgdPrjvFkmuIebwJF21UIscWd3xukq3vIweE211woEK6gcFs66UPwMkY3kqcBlUsWNuFlZ1m8ECrB5nZynmV2RTfQQB8lnqwttoMqNeU1mPEIUbURg2JA3C17enVHVd76D6P1Fz(2ZRNPuI)WdNyXW8dpqb8(9mTisxPbHlwm6N42V3PNqib8WdgyXAWMIDq4Lo9lgJ(xBU7zhlUBL4DT8AwP2qAHY1GfkI8K21wOOqBhZwOQ9ABHAJ2q02KJj0jHRbluUM1HCj1HCnPd58vOoKlLfkhkDO6Syt6qUASq9VIC3ZowC3sXB3HDRpu1H3rXcfjAFq(qzaQnAdPzFO6yOxb3APMPcU7ZKm1H3XziKcTpOjzma1gzYnpjthd9k4wlXrDI4mnuBeBTqCUBHEZWDFTi94KuUhl0UtwZa3AjkRt09OHAJsewO71TqVz4UVMpjsczxlV9iH2DJ82Jtbyq1nhyA9PaRWXnIcu1CqKylqpuCLipLDZW4)Vd4D6QK6sKD1dDi94SE3Uez7SdswUlrAk6aqpIi(IdKzqb2o2a1OhhFrO6MdLjDmDjz0XP6UOaBxZXFCMGBuxxwzMbBxJ9uwCK2MOQMf0UhsTf0DnfqzyRdOacq3nkxea)qLBoM485eMK7aEnfO7g8MQc(7a8(4uBpuG9OYo6gGt5wN6wuvb8KBHvB7aLDfQc4j2ZO2cC192Pc0P26NQGF8XXlGXhNjQhtmdQu5TlXgIv3QC2cYoEsbQUPtQrgkGV31idjapCFZh31X)OTO33K4plE9TETSS3nNTz8WjaxKMs0toJxcVwIIpM22ECYcVfj0UyXO0WB01MJk4)3CN9H7uBnRjeV7DQzr0E2SoOaqmGJp5jLpsTtkAYLd7)Wdw1rLGsBZQ6stie0B9BqR)XGT84ZvAKPuknzEXPinDw71sY(hZCj84KLflw)lsTx9T5Oc()n3zF4o0MoDpQ2i0GJFznDQbH0A68XNT84ZvAKPuknDuwNvZaDpDL1mqzfWuTGPLHSAB6yWFai(AVuiiJ7nH3vnPBb(bG1W7sbrkiajJyUCZ6(o5aOGviRXeUx0GUeWha(INLiMq3833HGT9iBq6aIRwunDHXgl1H1YkqoqoOcqYmq3thhnduZws03Mog8haItzlrBt6wGFayTjBiKnR77KdGc0Bprtd6saFa4Rwlk1FFhc22JSTWqvdnwQdRLZ8slJBsINnGDWgUj1uEtOAxh3ni3As7bFlyBTX(ETuZwoozh9q3UoUBmY2ObFlyBTrARwP3iP0SNtlsb0dkOaAmD)ci(idElaSTZ3AC68dh8uw(OHCq4hd1j1XFSvaXrpqCAjqAESXISu31G3ca38yJfHCE4GVTd9DYO2Hi)uFZPrUHNi3avNsyfd3fu6nf1NERp17uZ5UXWEFQ)Zo1zW4NtOncVvZ3MEF0m87EUu3ImUxQmA0)jodh2VF)Ro1CE5nS9rvrqNgrqhTiOJcc6kHGfccFLpsE2xUrYZSAKSoc(OnsMJGvg(O3m9Tq1N(WpOfgHO30SGpsEHl9Zw5LmzZ2p)5qGze)jDGLQH23r265wBC4v9aDsKjBhPzOHTONSL2AJxPuhgtkx)GL9H23sUM3ulTEqg(Tyz3OayH3qcuIIgk5yEOIs1PhW57kfiVniA(KGOj45TxKFQAjBP(66GNvOllIddJVlaVdj8attWK435N4ZUGQNZNqNDNxZp6I3nfp1IXdZ5SI2ffZQsMTrsTE(CSXZ9Y8U1l1)B39lS7dgmwFIkSXlgtzXHuBnCQUJQJnI1RSJo5Dmd9d78O6yFAnOD0J)PTBa84usFFj05j2Rm5h6)ltqLdLEr6DTeU7nhs7qNc0AXa4X90PI6y1QJotYjQg7oc5PaFNuEMnG7hM5dQJtWUbZpog(29lVLjsJG81YtvHsR3CD6g)z41GUZnxVjjErqO)nx)FUB6p(rVWTGSnmNN3UI70)0QRyNxaZGf8XG5iCV9(Dt5R1peX7cq5brfOb5BvVI7as(M1dEoQBXTkYBVGvxHEyWUPVfEzqg(qeBaqScNdokgvfXDn8CgW9Z2MaKKd2JH4DIyXtgoymqICsoDqzDQ(8llJ94f4DmWLYbr8I4nxM6NfS4fSo9sh(FNGW(saKVywC08aeMxw50Sy8ju1yHXAROk4WJtr6zDTu8ed4bwlfTHH6UVmu3UKHECkDN2ZqjkoL2WqZtXqoJuw8Ra4IssICXQJNgnjCt7lZxGsTV7Jvl)N23Vc)wTVbD0TV4BOJZQnSgxTSgxcwJlbRrtAO1(YASg9RmQ23RWACjznMcbTnSMQeRutvCSOUy1qI2fhsRHVUbdDBjgsS8vATK0nyyXH1Kk(5kIEociWHKFqY0dUpzh8WsZRgfcRtqOs(bjt07HLNxnwZSodHkjiuotV2iEm3Bngt0rqkH(WBugBV6szIXgSUQV4NeB1MprFI2oggT1Iauz6R7mnMCN80f5UQlNrUQ5)RsOMnap3FG8dV5cdzV2MpnnZd3yxj4PdTge0qa4LiBvsZeWF50DT7xap8)UF)x3n9FK377M(BSltsigKFo(UDtxVDg4C(7WJM6Dt)DUx8yChBafvW5D8ENd(g8WRHLDSVxWB(Rl9bYgcUIxvEh5)I8RrfudcbF6GBJtHwGkvqt8ZmI()jl3C4b(ceoaomN3b4Xfci9SCzbPm3hKvwZI96Uv(ryydqyXjZyH8GuxiYi8JI3UCf)l2Ibx8Jfb18owqnVNfuJnuQiYSPavkP1xp8WiVnF9qCcC6sYBKDuhx2dMwNJbP5PmL187ah1XirVxusKLNMFxi2ZFcDIVGb9BIP8bcNeErqAEAzHOAxU1dSAK57dro(p3MM)WyVqRIAKLCio1I4ciOwsTNBh1(DRJ3gLXXBzvneG448C2UIMu)IXiUfZefdWLdJVdmFydjumIHwB0Qb(krPsgT8wCduNSDtwj8bOUgTVSiX3)Z(5nRGAtfBMQPUYRO5CJCYxyGx6q)Tc3JYA)2Rm8TP(WKVO185fgxRCwqaNe8TsO36td3A2SzUKGpDW2n9e7dft8LMPl3RWLb2kVpF7P9kc9IXMqQn6Mgr9kzQ3Pm4w7MAk)Sz7I8BUGNn6Hh03qoImQVWKqfxot5Ww42AIcQcnHdVth98tDFwrMUQDPm1x4Tc3RsIEUvJFu4Oj)U5vMROMDbgsPMEaCOmV9Izh28jkRZWQJSwXVQF1J1256oRRep(BPYhIMV7Hhu0qU0LIazkW)e4)Z2qp0MK3giylVzRQnZcZ2mE21v5ra8OuM9O8BIAmDE47HHSQm7HnZll)7tdW(b5gWVxfVnetVEMNK)gLtEbgX)baDqtJiaCgNkSWAk3pQO7jHcMY14eA974hvh3nNJN8XxrN7jZRurBR893kyFvtaKM(4tqLp3e7mguL6A314K9xtuImKrcuS49KYOXSlcLlC7znoCHZqAQnNjAMCfIP6WUYOePqx9u4ays0GzbzG2FpJ9RrYQGEqSPWkoJVvcY6(H0tNbQtnLSuPejuhdVAy)wmkPGzIJiwrNfmqzRZ6ZbRzgB5B1iC8Wdsxy1xmAyVtSsJSAsU2WFTc0xncy0kkjnX33p29sVQCvKRCuG)klPup5hxU8E9uNp5CGXqcKtSfkUgM8oN1n)(kxg7QBEjQB4jAKzXDlKCT6utEau4RdWHYDGs9(WVN2NR85ihUqkloYFzcBjWa)bJ(qX05cpVYJfI3Oc9(9ov1n6hEqRpNxogCcPHlJ(kncLvaTY)LshEfEKKhVv6AQco9zbAaoQ8ZbyeS)EUWmeufF8IfP8UPxabjbr1S4YNUklBt63E2z3D3DdUlgck2B(aW3KZs34hgEjys)vdpJjk8YGOfBXBx8NEvE0yVn)bxCM3vy80bHTaYJDCFTZzC5IxgV4L8vX9QAXSYbogE62nq8O8IncJ4f)LTDMZyx3x)MZ4YWyVjS0QxPpisE)IHrJEGv5IwWc7722rJEy5qzlO3BkYRSaS4sqGpJm5LIOIxbYnmBGGMDq0hJ)ai1)jqclceurj(IPLq)OlKiErWcc9CdEL3xBadMxBrUcRUzkA62VON24menJ5fbwa9wckzqeCHHinPZRLZh2tsbFrqceDS360jyw)UaTI20CEMqtZ(BuoPNcYwU(a9zbP8h8Sbl5dmUMEaHV(f4pGWoMaw3U0PWJFTjmgzbnon7RQqzHmi0t3cnyEzEmp(zPNcx8kW04TXPP9u9IbLYbwZ7zz9ddHc0L2ecbTLhL0FKuWcy)UmP5GAs6h2nDjy(pAGKQcWuNhpHG3nb)mfEnWojvsKrxNXYJJtzfHvodRilEzR()6UJ1DBBBUplgdqiklnWwoURdqraffBy)yddyx(BDvSvs0IJvGKZx)mqqF2hpKIu8Y5qsz7UfmuGIwzjYdp3VkXUgiUwbb1X(R6(MUIB49czMbH8GjAmtoRAVEMNkfDSLyPC0iDjkRt3MMDYIrWpoAfG715NLRt3h7gQp2z21KC46kg2(10)hJRGi8mdeE2R0VYqNoeo13UPzeiC3VDc()2cXLW(W9LB3wXZPmaD6D0LT0JQ4o97cU2vtreh5)tN8YeY0W5N8mXhTvpiRcex)vzcNX94LA(wn91U3t569POMns)AizH8RdcZfxBO5nbSDeKWMrtypE5Y)7typvsWO6A8ty)grZt2SDZE4VReE3Zlou)sWmn22anWPOdp5U8kVdWGlpB7MbfC5x(0V2kImyBvT43dVA30WDr3yDcX4jm6EiQlg8hJO1mUEgpnfJw2dOSNHRw7yyyz)SnBkp)gPKYhgTdKgyaCE0(CgY)2ISP0vJa3xtW5TGkqqPJrODimDmtNogVOMbDm71bDmliDC2xz6itFXVW(p7kHQP0xd9FS6)XInIPizfthYFWRTwVt1)PS(FW9cfauNr4(MpVPpnnD740)1nSWhH1C5TWsE5U6vpaPP2TIuhdfiD4Prd0w7BaevgC9RXVVmLiwSeW1dSFao4pYItQElu1300(YH)bmFPEQzNmNc4KlQc09QSQH48wzg6ikVP5X6TCS9Yn1pEd3HcekbPRbyMCz0niSuiavMYcG14gMqZDq7pPj7x(uvBhJ00(Gke6fXOwddKXyZqbn9fIT8nTDmxW766Fn0dlL6PKnKg1ren9OsjceQrsWs7X0uewDs(vYuwBpTQI8apBQGFW90HKDzd8CHzvVyImB2Wt8D5dgiMJdnOVfi83KmGbtohMujg))0iGaVo0Qx(X8RyKm0sEG2kyjMfkKOhTIbhn6mo2lcJRksaxlcZIM)DK6CPTXzOI183oiYngNye0A6To6DjjQubkRCKvl5WdKIsXiqakMfcvHtyh7PqFtWEi3ympvr4j6VadjMI3b(xrNd)qCKfZ9R0KmWq3YnZlMhZJVCMouoKAsp0nzDXQ9R2WeylBVRAxNajDgWbcoYaxtvuZ11m668uvNIPTil7Vga5jhbgWSDZ4)2N33(y3YBFUDpazdmDT1qXgBe9R8WNuhzjLn)i7eWY3ivf7ZrXiKErowtWHAthKUEg5WQr68iQtR0ftAsBz96LmhPbyz96UlR()WWCYyZTUETwDuSopQ6O8T2pKQaldKdvLUD4HpfymUB)JdL5EufOGe7ldAlCqk5H4WFJ7Z4CjFOPddRGgrY4Wljta4F59Sy0UC3NB4)dAFJsgU5S7d2MjE4iDXa)JXKAOWSSMHkz25whD5OCOuDR2ZuvnydYnKoYytmlX6(LR3U2uzOUf4(vruGvgfGb2Rk3BgHZqRiN4pogzF0MracH3lTgCM0YqcfcrYK68n8IW3Tb7iE4nhCn0gUxDpyXRds)tiE2cYfrYanWvB9jclO8Wawp1TOMUnsZcvkhSFlRG2bu9Pn4349nZx(07vTtRUVuBAAwR0QOOLsax0HZgpaJZPQfY8sKpalkRsORcFEtxvKpYgat0T8VEE9DpYoTr(uqxbXqhLBwcTSBKp0T1TvCCqK3)nL3XDfPTE1dDJoZd9ozB32wE3au)Nj54j2HGngMQ)59WPE(8EMkTaUzyA92Lw2F8YpIBAyOHlYuStOgWB3EaUCF49rMenA1gzddjrGXMa3FVRzOft7hMTpUElhEbiRUANMTeYSa3)dqko7wUP62DftdUj68humMKM89boHP3LnvghohLrHxc2oENk4eplgmppQ0HcD5)pbCuQ1xJlJNoiGibhighaSwMepgTBi8ost1NnXWfh(TP9vkKZbwC9vV8se327s7LYo095DrTnZmEHq4hLmk1lehEwSNbBCv(it3VxwUOLq67Miu4u1adnA1AhhAGqNYTmoyyMzBFURCTYnme0viZ)fZw0J4qXPeh6ESbYJm)4oUu6qTpV0q8HJj0cCoaOpkdUKy3Rgp297d7Ry(CsKZvdoKjB403Z1SXCqRzh)ymGbeAIzNE1PScl7nOQseMeZqwm4911sHZ)okdlwKyLeONwTB58f5OxFAXcJmOTykY25ucVHQXQp2IKkEPOP0mayTTUXOquCMtU(SNA13ivs1spL8N)wqNevfjrrfTBH1AOKncZojy9m78PshKOQbhAY7hsEP58kKEAyRS2xf0MHr6DlKJH716L2g5P1J60oMlzvFrN2wjRHX7(puCmxzfAkZWR)EmS3rF8ebeTRPTTp4gD65BJsuItI6NkyLEf9bv3N2f9d8HYm0RzL3S78sBk4qCCW6CTrXXEJXpvO6ZYjQySURCiAxi3AROao(npC6r0gwksWsOnretF0eJJggpyWHiAmYH9sgyL1RqsbK78IL0dGDqSSKR2j3UyvrwKm9iqVNarim4qlHzZMJvbimguIb2khYjvWiTXdspFH7IAMBHxErB0ALVYbevzmpl1odxZsPp2H4Bvb9HSDJKNovR9ZqM(upJVMDCT2dPMCQhhR(tLvHde58V35jcUv)a3jvxR3TYdnb1tV5KpaQ3av5ZmNG3PXZeqP)q5MW7B(b5ao(Lp9Z1AJN6LLnvMAx94aavMOdAKrSjhf6h)DyIhlpNHZlAZ1MFvQnCgwFDWWaWwisP1OjbIalNA)KhTq0iniCsPR0ObxS5iIOkBrOEcvbu(hKqZDvvaO3mZfp41lFnitjw(71qgqHEKfWwy(TBKJuBuDTkZioUxnwHLWUJzdjXYUc1BdjUH4pIufaG08mZPIEgdjdWWB2Uu69Lo4UHGlsCwWJcbbPHht2qREDol7xxpxdrmIvpYGZv2Vzhg45qeoYZmsJDqsKU(0qY7HZXtKJqRhaCCORjNPNyFFVXcIJhJGxYOFnorW(rcsJGeh2wR7s8Q1oHnO6AXWBxRHNmUpUJ9Np(3p]] )