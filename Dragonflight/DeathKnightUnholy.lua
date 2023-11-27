-- DeathKnightUnholy.lua
-- October 2022

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local roundUp = ns.roundUp
local FindUnitBuffByID = ns.FindUnitBuffByID
local PTR = ns.PTR

local strformat = string.format

local me = Hekili:NewSpecialization( 252 )

me:RegisterResource( Enum.PowerType.Runes, {
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

            start = roundUp( start, 2 )

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
            if t.expiry[ 4 ] > state.query_time then
                t.expiry[ 1 ] = t.expiry[ 4 ] + t.cooldown
            else
                t.expiry[ 1 ] = state.query_time + t.cooldown
            end
            table.sort( t.expiry )
        end

        if amount > 0 then
            state.gain( amount * 10, "runic_power" )

            if state.set_bonus.tier20_4pc == 1 then
                state.cooldown.army_of_the_dead.expires = max( 0, state.cooldown.army_of_the_dead.expires - 1 )
            end
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
me:RegisterResource( Enum.PowerType.RunicPower )


me:RegisterStateFunction( "apply_festermight", function( n )
    if azerite.festermight.enabled or talent.festermight.enabled then
        if buff.festermight.up then
            addStack( "festermight", buff.festermight.remains, n )
        else
            applyBuff( "festermight", nil, n )
        end
    end
end )


local spendHook = function( amt, resource, noHook )
    if amt > 0 and resource == "runes" and active_dot.shackle_the_unworthy > 0 then
        reduceCooldown( "shackle_the_unworthy", 4 * amt )
    end
end

me:RegisterHook( "spend", spendHook )


-- Talents
me:RegisterTalents( {
    -- DeathKnight
    abomination_limb          = { 76049, 383269, 1 }, -- Sprout an additional limb, dealing 4,574 Shadow damage over 12 sec to all nearby enemies. Deals reduced damage beyond 5 targets. Every 1 sec, an enemy is pulled to your location if they are further than 8 yds from you. The same enemy can only be pulled once every 4 sec. Gain Runic Corruption instantly, and again every 6 sec.
    acclimation               = { 76047, 373926, 1 }, -- Icebound Fortitude's cooldown is reduced by 60 sec.
    antimagic_barrier         = { 76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by 20 sec and increases its duration and amount absorbed by 40%.
    antimagic_shell           = { 76070, 48707 , 1 }, -- Surrounds you in an Anti-Magic Shell for 7 sec, absorbing up to 15,262 magic damage and preventing application of harmful magical effects. Damage absorbed generates Runic Power.
    antimagic_zone            = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 47,400 damage.
    asphyxiate                = { 76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation              = { 76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and grants up to 100 Runic Power based on the amount absorbed.
    blinding_sleet            = { 76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_draw                = { 76079, 374598, 2 }, -- When you fall below 30% health you drain 1,127 health from nearby enemies. Can only occur every 2 min.
    blood_scent               = { 76066, 374030, 1 }, -- Increases Leech by 3%.
    brittle                   = { 76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    cleaving_strikes          = { 76073, 316916, 1 }, -- Scourge Strike hits up to 7 additional enemies while you remain in Death and Decay.
    clenching_grasp           = { 76062, 389679, 1 }, -- Death Grip slows enemy movement speed by 50% for 6 sec.
    coldthirst                = { 76045, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants 10 Runic Power and reduces its cooldown by 3 sec.
    control_undead            = { 76059, 111673, 1 }, -- Dominates the target undead creature up to level 61, forcing it to do your bidding for 5 min.
    death_pact                = { 76077, 48743 , 1 }, -- Create a death pact that heals you for 50% of your maximum health, but absorbs incoming healing equal to 30% of your max health for 15 sec.
    deaths_echo               = { 76056, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have 1 additional charge.
    deaths_reach              = { 76057, 276079, 1 }, -- Increases the range of Death Grip by 10 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    empower_rune_weapon       = { 76050, 47568 , 1 }, -- Empower your rune weapon, gaining 15% Haste and generating 1 Rune and 5 Runic Power instantly and every 5 sec for 20 sec.
    enfeeble                  = { 76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by 30% and the damage they deal to you by 15% for 6 sec.
    gloom_ward                = { 76052, 391571, 1 }, -- Absorbs are 15% more effective on you.
    grip_of_the_dead          = { 76057, 273952, 1 }, -- Death and Decay reduces the movement speed of enemies within its area by 90%, decaying by 10% every sec.
    icebound_fortitude        = { 76084, 48792 , 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 30% for 8 sec.
    icy_talons                = { 76051, 194878, 2 }, -- Your Runic Power spending abilities increase your melee attack speed by 3% for 10 sec, stacking up to 3 times.
    improved_death_strike     = { 76067, 374277, 1 }, -- Death Strike's cost is reduced by 10, and its healing is increased by 60%.
    insidious_chill           = { 76088, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by 5% for 30 sec, stacking up to 4 times.
    march_of_darkness         = { 76069, 391546, 1 }, -- Death's Advance grants an additional 25% movement speed over the first 3 sec.
    merciless_strikes         = { 76085, 373923, 1 }, -- Increases Critical Strike chance by 2%.
    might_of_thassarian       = { 76076, 374111, 1 }, -- Increases Strength by 2%.
    mind_freeze               = { 76082, 47528 , 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    permafrost                = { 76083, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to 40% of the damage dealt.
    proliferating_chill       = { 76086, 373930, 1 }, -- Chains of Ice affects 1 additional nearby enemy.
    rune_mastery              = { 76080, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by 3% for 8 sec.
    runic_attenuation         = { 76087, 207104, 1 }, -- Auto attacks have a chance to generate 5 Runic Power.
    sacrificial_pact          = { 76074, 327574, 1 }, -- Sacrifice your ghoul to deal 929 Shadow damage to all nearby enemies and heal for 25% of your maximum health. Deals reduced damage beyond 8 targets.
    soul_reaper               = { 76053, 343294, 1 }, -- Strike an enemy for 532 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 2,445 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    suppression               = { 76075, 374049, 1 }, -- Damage taken from area of effect attacks reduced by 3%.
    unholy_bond               = { 76055, 374261, 2 }, -- Increases the effectiveness of your Runeforge effects by 10%.
    unholy_endurance          = { 76063, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground             = { 76058, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    veteran_of_the_third_war  = { 76068, 48263 , 2 }, -- Stamina increased by 10%.
    will_of_the_necropolis    = { 76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk               = { 76078, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.

    -- Unholy
    all_will_serve            = { 76181, 194916, 1 }, -- Your Raise Dead spell summons an additional skeletal minion.
    apocalypse                = { 76185, 275699, 1 }, -- Bring doom upon the enemy, dealing 620 Shadow damage and bursting up to 4 Festering Wounds on the target. Summons an Army of the Dead ghoul for 20 sec for each Festering Wound you burst. Generates 2 Runes.
    army_of_the_damned        = { 76153, 276837, 1 }, -- Apocalypse's cooldown is reduced by 45 sec. Additionally, Death Coil and Epidemic reduce the cooldown of Army of the Dead by 5 sec.
    army_of_the_dead          = { 76196, 42650 , 1 }, -- Summons a legion of ghouls who swarms your enemies, fighting anything they can for 30 sec.
    bursting_sores            = { 76164, 207264, 1 }, -- Bursting a Festering Wound deals 20% more damage, and deals 200 Shadow damage to all nearby enemies. Deals reduced damage beyond 8 targets.
    chains_of_ice             = { 76081, 45524 , 1 }, -- Shackles the target with frozen chains, reducing movement speed by 70% for 8 sec.
    clawing_shadows           = { 76183, 207311, 1 }, -- Deals 1,012 Shadow damage and causes 1 Festering Wound to burst.
    coil_of_devastation       = { 76156, 390270, 1 }, -- Death Coil causes the target to take an additional 30% of the direct damage dealt over 4 sec.
    commander_of_the_dead     = { 76149, 390259, 1 }, -- Dark Transformation also empowers your Gargoyle and Army of the Dead for 30 sec, increasing their damage by 35%.
    dark_transformation       = { 76187, 63560 , 1 }, -- Your geist deals 554 Shadow damage to 5 nearby enemies and transforms into a powerful undead monstrosity for 15 sec. Granting them 100% energy and the geist's abilities are empowered and take on new functions while the transformation is active.
    death_rot                 = { 76158, 377537, 1 }, -- Death Coil and Epidemic debilitate your enemy applying Death Rot causing them to take 1% increased Shadow damage, up to 10% from you for 10 sec. If Death Coil or Epidemic consume Sudden Doom it applies two stacks of Death Rot.
    death_strike              = { 76071, 49998 , 1 }, -- Focuses dark power into a strike that deals 436 Physical damage and heals you for 40.00% of all damage taken in the last 5 sec, minimum 11.2% of maximum health.
 -- defile                    = { 76180, 152280, 1 }, -- Defile the targeted ground, dealing 682 Shadow damage to all enemies over 10 sec. While you remain within your Defile, your Scourge Strike will hit 7 enemies near the target. Every sec, if any enemies are standing in the Defile, it grows in size, dealing increased damage, and increasing your Mastery by 1%, up to 8%.
    defile                    = { 76160, 152280, 1 }, -- Defile the targeted ground, dealing 682 Shadow damage to all enemies over 10 sec. While you remain within your Defile, your Scourge Strike will hit 7 enemies near the target. Every sec, if any enemies are standing in the Defile, it grows in size, dealing increased damage, and increasing your Mastery by 1%, up to 8%.
    ebon_fever                = { 76164, 207269, 1 }, -- Virulent Plague deals 15% more damage over time in half the duration.
    epidemic                  = { 76162, 207317, 1 }, -- Causes each of your Virulent Plagues to flare up, dealing 282 Shadow damage to the infected enemy, and an additional 113 Shadow damage to all other enemies near them. Increases the duration of Dark Transformation by 1 sec.
    eternal_agony             = { 76195, 390268, 1 }, -- Death Coil and Epidemic increase the duration of Dark Transformation by 1 sec.
    feasting_strikes          = { 76193, 390161, 1 }, -- Festering Strike has a 15% chance to generate 1 Rune and grant Runic Corruption.
    festering_strike          = { 76189, 85948 , 1 }, -- Strikes for 1,090 Physical damage and infects the target with 2-3 Festering Wounds.  Festering Wound A pustulent lesion that will burst on death or when damaged by Scourge Strike, dealing 282 Shadow damage and generating 5 Runic Power.
    festermight               = { 76152, 377590, 2 }, -- Popping a Festering Wound increases your Strength by 1% for 20 sec stacking. Does not refresh duration.
    ghoulish_frenzy           = { 76154, 377587, 2 }, -- Dark Transformation also increases the attack speed and damage of you and your Monstrosity by 0%.
    harbinger_of_doom         = { 76175, 276023, 1 }, -- Sudden Doom triggers 30% more often, can accumulate up to 2 charges, and increases the damage of your next Death Coil by 20% or Epidemic by 10%.
    improved_death_coil       = { 76184, 377580, 2 }, -- Death Coil deals 15% additional damage and seeks out 1 additional nearby enemy.
    improved_festering_strike = { 76192, 316867, 2 }, -- Festering Strike and Festering Wound damage increased by 10%.
    infected_claws            = { 76182, 207272, 1 }, -- Your ghoul's Claw attack has a 30% chance to cause a Festering Wound on the target.
    magus_of_the_dead         = { 76148, 390196, 1 }, -- Apocalypse and Army of the Dead also summon a Magus of the Dead who hurls Frostbolts and Shadow Bolts at your foes.
    morbidity                 = { 76197, 377592, 2 }, -- Diseased enemies take 1% increased damage from you per disease they are affected by.
    outbreak                  = { 76191, 77575 , 1 }, -- Deals 124 Shadow damage to the target and infects all nearby enemies with Virulent Plague.  Virulent Plague A disease that deals 1,603 Shadow damage over 13.5 sec. It erupts when the infected target dies, dealing 297 Shadow damage to nearby enemies.
    pestilence                = { 76157, 277234, 1 }, -- Death and Decay damage has a 10% chance to apply a Festering Wound to the enemy.
    plaguebringer             = { 76183, 390175, 1 }, -- Scourge Strike causes your disease damage to occur 100% more quickly for 10 sec.
    raise_dead                = { 76072, 46585 , 1 }, -- Raises a geist to fight by your side. You can have a maximum of one geist at a time. Lasts 1 min.
    raise_dead_2              = { 76188, 46584 , 1 }, -- Raises a geist to fight by your side. You can have a maximum of one geist at a time.
    reaping                   = { 76177, 377514, 1 }, -- Your Soul Reaper, Scourge Strike, Festering Strike, and Death Coil deal 30% addtional damage to enemies below 35% health.
    replenishing_wounds       = { 76163, 377585, 1 }, -- When a Festering Wound pops it generates an additional 2 Runic Power.
    rotten_touch              = { 76178, 390275, 1 }, -- Sudden Doom causes your next Death Coil to also increase your Scourge Strike damage against the target by 50% for 10 sec.
    runic_mastery             = { 76186, 390166, 2 }, -- Increases your maximum Runic Power by 10 and increases the Rune regeneration rate of Runic Corruption by 10%.
    ruptured_viscera          = { 76148, 390236, 1 }, -- When your ghouls expire, they explode in viscera dealing 152 Shadow damage to nearby enemies. Each explosion has a 25% chance to apply Festering Wounds to enemies hit.
    scourge_strike            = { 76190, 55090 , 1 }, -- An unholy strike that deals 523 Physical damage and 380 Shadow damage, and causes 1 Festering Wound to burst.
    sudden_doom               = { 76179, 49530 , 1 }, -- Your auto attacks have a chance to make your next Death Coil or Epidemic cost no Runic Power.
    summon_gargoyle           = { 76176, 49206 , 1 }, -- Summon a Gargoyle into the area to bombard the target for 25 sec. The Gargoyle gains 1% increased damage for every 1 Runic Power you spend. Generates 50 Runic Power.
    superstrain               = { 76155, 390283, 1 }, -- Your Virulent Plague also applies Frost Fever and Blood Plague at 80% effectiveness.
    unholy_assault            = { 76151, 207289, 1 }, -- Strike your target dealing 1,261 Shadow damage, infecting the target with 4 Festering Wounds and sending you into an Unholy Frenzy increasing haste by 20% for 20 sec.
    unholy_aura               = { 76150, 377440, 2 }, -- All enemies within 8 yards take 10% increased damage from your minions.
    unholy_blight             = { 76161, 115989, 1 }, -- Surrounds yourself with a vile swarm of insects for 6 sec, stinging all nearby enemies and infecting them with Virulent Plague and an unholy disease that deals 394 damage over 14 sec, stacking up to 4 times.
    unholy_command            = { 76194, 316941, 2 }, -- The cooldown of Dark Transformation is reduced by 8 sec.
    unholy_pact               = { 76180, 319230, 1 }, -- Dark Transformation creates an unholy pact between you and your pet, igniting flaming chains that deal 2,781 Shadow damage over 15 sec to enemies between you and your pet.
    vile_contagion            = { 76159, 390279, 1 }, -- Inflict disease upon your enemies spreading Festering Wounds equal to the amount currently active on your target to 7 nearby enemies.
} )


-- PvP Talents
me:RegisterPvpTalents( {
    bloodforged_armor    = 5585, -- (410301)
    dark_simulacrum      = 41  , -- (77606) Places a dark ward on an enemy player that persists for 12 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    doomburst            = 5436, -- (356512)
    life_and_death       = 40  , -- (288855) When targets afflicted by your Virulent Plague are healed, you are also healed for 5% of the amount. In addition, your Virulent Plague now erupts for 400% of normal eruption damage when dispelled.
    necromancers_bargain = 3746, -- (288848)
    necrotic_aura        = 3437, -- (199642)
    necrotic_wounds      = 149 , -- (356520) Bursting a Festering Wound converts it into a Necrotic Wound, absorbing 4% of all healing received for 15 sec and healing you for the amount absorbed when the effect ends, up to 4% of your max health. Max 6 stacks. Adding a stack does not refresh the duration.
    reanimation          = 152 , -- (210128) Reanimates a nearby corpse, summoning a zombie for 20 sec that slowly moves towards your target. If your zombie reaches its target, it explodes after 3.0 sec. The explosion stuns all enemies within 8 yards for 3 sec and deals 10% of their health in Shadow damage.
    rot_and_wither       = 5511, -- (202727)
    spellwarden          = 5590, -- (410320)
    strangulate          = 5430, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for 4 sec.
} )


-- Auras
me:RegisterAuras( {
    -- Talent: Absorbing up to $w1 magic damage.  Immune to harmful magic effects.
    -- https://wowhead.com/beta/spell=48707
    antimagic_shell = {
        id = 48707,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Summoning ghouls.
    -- https://wowhead.com/beta/spell=42650
    army_of_the_dead = {
        id = 42650,
        duration = 4,
        tick_time = 0.5,
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=221562
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
    -- You may not benefit from the effects of Blood Draw.
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
        max_stack = 1,
        copy = "blood_plague_superstrain"
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
    commander_of_the_dead = { -- 10.0.7 PTR
        id = 390260,
        duration = 30,
        max_stack = 1,
        copy = "commander_of_the_dead_window"
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
    -- Your next Death Strike is free and heals for an additional $s1% of maximum health.
    -- https://wowhead.com/beta/spell=101568
    dark_succor = {
        id = 101568,
        duration = 20,
        max_stack = 1
    },
    -- Talent: $?$w2>0[Transformed into an undead monstrosity.][Gassy.]  Damage dealt increased by $w1%.
    -- https://wowhead.com/beta/spell=63560
    dark_transformation = {
        id = 63560,
        duration = 15,
        type = "Magic",
        max_stack = 1,
        generate = function( t )
            local name, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = FindUnitBuffByID( "pet", 63560 )

            if name then
                t.name = t.name or name or class.abilities.dark_transformation.name
                t.count = count > 0 and count or 1
                t.expires = expires
                t.duration = duration
                t.applied = expires - duration
                t.caster = "player"
                return
            end

            t.name = t.name or class.abilities.dark_transformation.name
            t.count = 0
            t.expires = 0
            t.duration = class.auras.dark_transformation.duration
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    -- Reduces healing done by $m1%.
    -- https://wowhead.com/beta/spell=327095
    death = {
        id = 327095,
        duration = 6,
        type = "Magic",
        max_stack = 3
    },
    -- $?s206930[Heart Strike will hit up to ${$m3+2} targets.]?s207311[Clawing Shadows will hit ${$55090s4-1} enemies near the target.]?s55090[Scourge Strike will hit ${$55090s4-1} enemies near the target.][Dealing Shadow damage to enemies inside Death and Decay.]
    -- https://wowhead.com/beta/spell=188290
    death_and_decay = {
        id = 188290,
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
    death_rot = {
        id = 377540,
        duration = 10,
        max_stack = 2,
    },
    -- Your movement speed is increased by $s1%, you cannot be slowed below $s2% of normal speed, and you are immune to forced movement effects and knockbacks.
    -- https://wowhead.com/beta/spell=48265
    deaths_advance = {
        id = 48265,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Defile the targeted ground, dealing 918 Shadow damage to all enemies over 10 sec. While you remain within your Defile, your Scourge Strike will hit 7 enemies near the target. If any enemies are standing in the Defile, it grows in size and deals increasing damage every sec.
    defile = {
        id = 152280,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    defile_buff = {
        id = 218100,
        duration = 10,
        max_stack = 8,
        copy = "defile_mastery"
    },
    -- Talent: Haste increased by $s3%.  Generating $s1 $LRune:Runes; and ${$m2/10} Runic Power every $t1 sec.
    -- https://wowhead.com/beta/spell=47568
    empower_rune_weapon = {
        id = 47568,
        duration = 20,
        tick_time = 5,
        max_stack = 1
    },
    -- Suffering from a wound that will deal [(20.7% of Attack power) / 1] Shadow damage when damaged by Scourge Strike.
    festering_wound = {
        id = 194310,
        duration = 30,
        max_stack = 6,
    },
    -- Reduces damage dealt to $@auracaster by $m1%.
    -- https://wowhead.com/beta/spell=327092
    famine = {
        id = 327092,
        duration = 6,
        max_stack = 3
    },
    -- Strength increased by $w1%.
    -- https://wowhead.com/beta/spell=377591
    festermight = {
        id = 377591,
        duration = 20,
        max_stack = 20
    },
    -- Suffering $w1 Frost damage every $t1 sec.
    -- https://wowhead.com/beta/spell=55095
    frost_fever = {
        id = 55095,
        duration = 24,
        tick_time = 3,
        max_stack = 1,
        copy = "frost_fever_superstrain"
    },
    -- Movement speed slowed by $s2%.
    -- https://wowhead.com/beta/spell=279303
    frostwyrms_fury = {
        id = 279303,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    -- Damage and attack speed increased by $s1%.
    -- https://wowhead.com/beta/spell=377588
    ghoulish_frenzy = {
        id = 377588,
        duration = 15,
        max_stack = 1,
        copy = 377589
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
    grip_of_the_dead = {
        id = 273977,
        duration = 3600,
        max_stack = 1,
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
    -- Talent: Damage taken reduced by $w3%.  Immune to Stun effects.
    -- https://wowhead.com/beta/spell=48792
    icebound_fortitude = {
        id = 48792,
        duration = 8,
        max_stack = 1
    },
    -- Attack speed increased $w1%.
    icy_talons = {
        id = 194879,
        duration = 6,
        max_stack = 3
    },
    -- Time between attacks increased by $w1%.
    insidious_chill = {
        id = 391568,
        duration = 30,
        max_stack = 4
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
    -- Death's Advance movement speed increased by $w1%.
    march_of_darkness = {
        id = 391547,
        duration = 3,
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
    -- Disease damage occurring ${100*(1/(1+$s1/100)-1)}% more quickly.
    plaguebringer = {
        id = 390178,
        duration = 10,
        max_stack = 1
    },
    raise_abomination = { -- TODO: Is a totem.
        id = 288853,
        duration = 25,
        max_stack = 1
    },
    raise_dead = { -- TODO: Is a pet.
        id = 46585,
        duration = 60,
        max_stack = 1
    },
    reanimation = { -- TODO: Summons a zombie (totem?).
        id = 210128,
        duration = 20,
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
    rotten_touch = {
        id = 390276,
        duration = 10,
        max_stack = 1
    },
    -- Strength increased by $w1%
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
    -- Increases your rune regeneration rate for 3 sec.
    runic_corruption = {
        id = 51460,
        duration = function () return 3 * haste end,
        max_stack = 1,
    },
    -- Talent: Afflicted by Soul Reaper, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage.
    -- https://wowhead.com/beta/spell=343294
    soul_reaper = {
        id = 343294,
        duration = 5,
        tick_time = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Silenced.
    strangulate = {
        id = 47476,
        duration = 4,
        max_stack = 1
    },
    -- Your next Death Coil$?s207317[ or Epidemic][] consumes no Runic Power.
    -- https://wowhead.com/beta/spell=81340
    sudden_doom = {
        id = 81340,
        duration = 10,
        max_stack = function () return talent.harbinger_of_doom.enabled and 2 or 1 end,
    },
    -- Runic Power is being fed to the Gargoyle.
    -- https://wowhead.com/beta/spell=61777
    summon_gargoyle = {
        id = 61777,
        duration = 25,
        max_stack = 1
    },
    summon_gargoyle_buff = { -- TODO: Buff on the gargoyle...
        id = 61777,
        duration = 25,
        max_stack = 1,
    },
    -- Talent: Haste increased by $s1%.
    -- https://wowhead.com/beta/spell=207289
    unholy_assault = {
        id = 207289,
        duration = 20,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Surrounded by a vile swarm of insects, infecting enemies within $115994a1 yds with Virulent Plague and an unholy disease that deals damage to enemies.
    -- https://wowhead.com/beta/spell=115989
    unholy_blight_buff = {
        id = 115989,
        duration = 6,
        tick_time = 1,
        type = "Magic",
        max_stack = 1,
        dot = "buff"
    },
    -- Suffering $s1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=115994
    unholy_blight = {
        id = 115994,
        duration = 14,
        tick_time = 2,
        max_stack = 4,
        copy = { "unholy_blight_debuff", "unholy_blight_dot" }
    },
    -- Strength increased by $s1%.
    -- https://wowhead.com/beta/spell=53365
    unholy_strength = {
        id = 53365,
        duration = 15,
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.  Erupts for $191685s1 damage split among all nearby enemies when the infected dies.
    -- https://wowhead.com/beta/spell=191587
    virulent_plague = {
        id = 191587,
        duration = function () return 27 * ( talent.ebon_fever.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.ebon_fever.enabled and 0.5 or 1 ) end,
        type = "Disease",
        max_stack = 1
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
    doomburst = {
        id = 356518,
        duration = 3,
        max_stack = 2,
    },
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
    necrotic_wound = {
        id = 223929,
        duration = 18,
        max_stack = 1,
    },
} )


me:RegisterStateTable( "death_and_decay",
setmetatable( { onReset = function( self ) end },
{ __index = function( t, k )
    if k == "ticking" then
        return buff.death_and_decay.up

    elseif k == "remains" then
        return buff.death_and_decay.remains

    end

    return false
end } ) )

me:RegisterStateTable( "defile",
setmetatable( { onReset = function( self ) end },
{ __index = function( t, k )
    if k == "ticking" then
        return buff.death_and_decay.up

    elseif k == "remains" then
        return buff.death_and_decay.remains

    end

    return false
end } ) )

me:RegisterStateExpr( "dnd_ticking", function ()
    return death_and_decay.ticking
end )

me:RegisterStateExpr( "dnd_remains", function ()
    return death_and_decay.remains
end )


me:RegisterStateExpr( "spreading_wounds", function ()
    if talent.infected_claws.enabled and buff.dark_transformation.up then return false end -- Ghoul is dumping wounds for us, don't bother.
    return azerite.festermight.enabled and settings.cycle and settings.festermight_cycle and cooldown.death_and_decay.remains < 9 and active_dot.festering_wound < spell_targets.festering_strike
end )


me:RegisterStateFunction( "time_to_wounds", function( x )
    if debuff.festering_wound.stack >= x then return 0 end
    return 3600
    --[[ No timeable wounds mechanic in SL?
    if buff.unholy_frenzy.down then return 3600 end

    local deficit = x - debuff.festering_wound.stack
    local swing, speed = state.swings.mainhand, state.swings.mainhand_speed

    local last = swing + ( speed * floor( query_time - swing ) / swing )
    local fw = last + ( speed * deficit ) - query_time

    if fw > buff.unholy_frenzy.remains then return 3600 end
    return fw ]]
end )

me:RegisterHook( "step", function ( time )
    if Hekili.ActiveDebug then Hekili:Debug( "Rune Regeneration Time: 1=%.2f, 2=%.2f, 3=%.2f, 4=%.2f, 5=%.2f, 6=%.2f\n", runes.time_to_1, runes.time_to_2, runes.time_to_3, runes.time_to_4, runes.time_to_5, runes.time_to_6 ) end
end )

local Glyphed = IsSpellKnownOrOverridesKnown

me:RegisterPet( "ghoul", 26125, "raise_dead", 3600 )

me:RegisterTotem( "gargoyle", 458967 )
me:RegisterTotem( "dark_arbiter", 298674 )

me:RegisterTotem( "abomination", 298667 )
me:RegisterPet( "apoc_ghoul", 24207, "apocalypse", 15 )
me:RegisterPet( "army_ghoul", 24207, "army_of_the_dead", 30 )
me:RegisterPet( "magus_of_the_dead", 148797, "apocalypse", 15 )
me:RegisterPet( "t31_magus", 148797, "apocalypse", 15 )

-- Tier 29
me:RegisterGear( "tier29", 200405, 200407, 200408, 200409, 200410 )
me:RegisterAuras( {
    vile_infusion = {
        id = 3945863,
        duration = 5,
        max_stack = 1,
        shared = "pet"
    },
    ghoulish_infusion = {
        id = 394899,
        duration = 8,
        max_stack = 1
    }
} )

-- Tier 30
me:RegisterGear( "tier30", 202464, 202462, 202461, 202460, 202459 )
-- 2 pieces (Unholy) : Death Coil and Epidemic damage increased by 10%. Casting Death Coil or Epidemic grants a stack of Master of Death, up to 20. Dark Transformation consumes Master of Death and grants 1% Mastery for each stack for 20 sec.
me:RegisterAura( "master_of_death", {
    id = 408375,
    duration = 30,
    max_stack = 20
} )
me:RegisterAura( "death_dealer", {
    id = 408376,
    duration = 20,
    max_stack = 1
} )
-- 4 pieces (Unholy) : Army of the Dead grants 20 stacks of Master of Death. When Death Coil or Epidemic consumes Sudden Doom gain 2 extra stacks of Master of Death and 10% Mastery for 6 sec.
me:RegisterAura( "lingering_chill", {
    id = 410879,
    duration = 12,
    max_stack = 1
} )

me:RegisterGear( "tier31", 207198, 207199, 207200, 207201, 207203 )
-- (2) Apocalypse summons an additional Magus of the Dead. Your Magus of the Dead Shadow Bolt now fires a volley of Shadow Bolts at up to $s2 nearby enemies.
-- (4) Each Rune you spend increases the duration of your active Magi by ${$s1/1000}.1 sec and your Magi will now also cast Amplify Damage, increasing the damage you deal by $424949s2% for $424949d.


local any_dnd_set, wound_spender_set = false, false

local ExpireRunicCorruption = setfenv( function()
    local debugstr

    local mod = ( 2 + 0.1 * talent.runic_mastery.rank )

    if Hekili.ActiveDebug then debugstr = format( "Runic Corruption expired; updating regen from %.2f to %.2f at %.2f + %.2f.", rune.cooldown, rune.cooldown * mod, offset, delay ) end
    rune.cooldown = rune.cooldown * mod

    for i = 1, 6 do
        local exp = rune.expiry[ i ] - query_time

        if exp > 0 then
            rune.expiry[ i ] = query_time + exp * mod
            if Hekili.ActiveDebug then debugstr = format( "%s\n - rune %d extended by %.2f [%.2f].", debugstr, i, exp * mod, rune.expiry[ i ] - query_time ) end
        end
    end

    table.sort( rune.expiry )
    rune.actual = nil
    if Hekili.ActiveDebug then debugstr = format( "%s\n - %d, %.2f %.2f %.2f %.2f %.2f %.2f.", debugstr, rune.current, rune.expiry[1] - query_time, rune.expiry[2] - query_time, rune.expiry[3] - query_time, rune.expiry[4] - query_time, rune.expiry[5] - query_time, rune.expiry[6] - query_time ) end
    forecastResources( "runes" )
    if Hekili.ActiveDebug then debugstr = format( "%s\n - %d, %.2f %.2f %.2f %.2f %.2f %.2f.", debugstr, rune.current, rune.expiry[1] - query_time, rune.expiry[2] - query_time, rune.expiry[3] - query_time, rune.expiry[4] - query_time, rune.expiry[5] - query_time, rune.expiry[6] - query_time ) end
    if debugstr then Hekili:Debug( debugstr ) end
end, state )


local TriggerERW = setfenv( function()
    gain( 1, "runes" )
    gain( 5, "runic_power" )
end, state )

me:RegisterHook( "reset_precast", function ()
    if buff.runic_corruption.up then
        state:QueueAuraExpiration( "runic_corruption", ExpireRunicCorruption, buff.runic_corruption.expires )
    end

    if totem.dark_arbiter.remains > 0 then
        summonPet( "dark_arbiter", totem.dark_arbiter.remains )
        summonTotem( "gargoyle", nil, totem.dark_arbiter.remains )
        summonPet( "gargoyle", totem.dark_arbiter.remains )
    elseif totem.gargoyle.remains > 0 then
        summonPet( "gargoyle", totem.gargoyle.remains )
    end

    local control_expires = action.control_undead.lastCast + 300
    if control_expires > now and pet.up and not pet.ghoul.up then
        summonPet( "controlled_undead", control_expires - now )
    end

    local apoc_expires = action.apocalypse.lastCast + 15
    if apoc_expires > now then
        summonPet( "apoc_ghoul", apoc_expires - now )
        if talent.magus_of_the_dead.enabled then
            summonPet( "magus_of_the_dead", apoc_expires - now )
        end

        -- TODO: Accommodate extensions from spending runes.
        if set_bonus.tier31_2pc > 0 then
            summonPet( "t31_magus", apoc_expires - now )
        end
    end

    local army_expires = action.army_of_the_dead.lastCast + 30
    if army_expires > now then
        summonPet( "army_ghoul", army_expires - now )
    end

    if talent.all_will_serve.enabled and pet.ghoul.up then
        summonPet( "skeleton" )
    end

    if query_time - action.unholy_blight.lastCast < 2 and debuff.virulent_plague.down then
        applyDebuff( "target", "virulent_plague" )
    end

    if query_time - action.outbreak.lastCast < 2 and debuff.virulent_plague.down then
        applyDebuff( "target", "virulent_plague" )
    end

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
        class.abilityList.any_dnd = "|T136144:0|t |cff00ccff[Any " .. class.abilities.death_and_decay.name .. "]|r"
        any_dnd_set = true
    end

    if state:IsKnown( "clawing_shadows" ) then
        class.abilities.wound_spender = class.abilities.clawing_shadows
        cooldown.wound_spender = cooldown.clawing_shadows
    else
        class.abilities.wound_spender = class.abilities.scourge_strike
        cooldown.wound_spender = cooldown.scourge_strike
    end

    if not wound_spender_set then
        class.abilityList.wound_spender = "|T237530:0|t |cff00ccff[Wound Spender]|r"
        wound_spender_set = true
    end

    if state:IsKnown( "deaths_due" ) and cooldown.deaths_due.remains then setCooldown( "death_and_decay", cooldown.deaths_due.remains )
    elseif talent.defile.enabled and cooldown.defile.remains then setCooldown( "death_and_decay", cooldown.defile.remains ) end

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

    if Hekili.ActiveDebug then Hekili:Debug( "Pet is %s.", pet.alive and "alive" or "dead" ) end
end )

local mt_runeforges = {
    __index = function( t, k )
        return false
    end,
}

-- Not actively supporting this since we just respond to the player precasting AOTD as they see fit.
me:RegisterStateTable( "death_knight", setmetatable( {
    disable_aotd = false,
    delay = 6,
    runeforge = setmetatable( {}, mt_runeforges )
}, {
    __index = function( t, k )
        if k == "fwounded_targets" then return state.active_dot.festering_wound end
        if k == "disable_iqd_execute" then return state.settings.disable_iqd_execute and 1 or 0 end
        return 0
    end,
} ) )


local runeforges = {
    [6243] = "hysteria",
    [3370] = "razorice",
    [6241] = "sanguination",
    [6242] = "spellwarding",
    [6245] = "apocalypse",
    [3368] = "fallen_crusader",
    [3847] = "stoneskin_gargoyle",
    [6244] = "unending_thirst"
}

local function ResetRuneforges()
    table.wipe( state.death_knight.runeforge )
end

local function UpdateRuneforge( slot, item )
    if ( slot == 16 or slot == 17 ) then
        local link = GetInventoryItemLink( "player", slot )
        local enchant = link:match( "item:%d+:(%d+)" )

        if enchant then
            enchant = tonumber( enchant )
            local name = runeforges[ enchant ]

            if name then
                state.death_knight.runeforge[ name ] = true

                if name == "razorice" and slot == 16 then
                    state.death_knight.runeforge.razorice_mh = true
                elseif name == "razorice" and slot == 17 then
                    state.death_knight.runeforge.razorice_oh = true
                end
            end
        end
    end
end

Hekili:RegisterGearHook( ResetRuneforges, UpdateRuneforge )


-- Abilities
me:RegisterAbilities( {
    -- Talent: Surrounds you in an Anti-Magic Shell for $d, absorbing up to $<shield> magic ...
    antimagic_shell = {
        id = 48707,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "antimagic_shell",
        startsCombat = false,

        toggle = function()
            if settings.dps_shell then return end
            return "defensives"
        end,

        handler = function ()
            applyBuff( "antimagic_shell" )
        end,
    },

    -- Talent: Places an Anti-Magic Zone that reduces spell damage taken by party or raid me...
    antimagic_zone = {
        id = 51052,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "antimagic_zone",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "antimagic_zone" )
        end,
    },

    -- Talent: Bring doom upon the enemy, dealing $sw1 Shadow damage and bursting up to $s2 ...
    apocalypse = {
        id = 275699,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( ( pvptalent.necromancers_bargain.enabled and 75 or 90 ) - ( level > 48 and 15 or 0 ) ) end,
        gcd = "spell",

        talent = "apocalypse",
        startsCombat = true,

        toggle = function () return not talent.army_of_the_damned.enabled and "cooldowns" or nil end,

        debuff = "festering_wound",

        handler = function ()
            if pvptalent.necrotic_wounds.enabled and debuff.festering_wound.up and debuff.necrotic_wound.down then
                applyDebuff( "target", "necrotic_wound" )
            else
                summonPet( "apoc_ghoul", 15 )
            end

            if debuff.festering_wound.stack > 4 then
                applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.remains - 4 )
                apply_festermight( 4 )
                if conduit.convocation_of_the_dead.enabled and cooldown.apocalypse.remains > 0 then
                    reduceCooldown( "apocalypse", 4 * conduit.convocation_of_the_dead.mod * 0.1 )
                end
                gain( 12, "runic_power" )
            else
                gain( 3 * debuff.festering_wound.stack, "runic_power" )
                apply_festermight( debuff.festering_wound.stack )
                if conduit.convocation_of_the_dead.enabled and cooldown.apocalypse.remains > 0 then
                    reduceCooldown( "apocalypse", debuff.festering_wound.stack * conduit.convocation_of_the_dead.mod * 0.1 )
                end
                removeDebuff( "target", "festering_wound" )
            end

            if level > 57 then gain( 2, "runes" ) end
            if set_bonus.tier29_2pc > 0 then applyBuff( "vile_infusion" ) end
            if pvptalent.necromancers_bargain.enabled then applyDebuff( "target", "crypt_fever" ) end
        end,
    },

    -- Talent: Summons a legion of ghouls who swarms your enemies, fighting anything they ca...
    army_of_the_dead = {
        id = function () return pvptalent.raise_abomination.enabled and 288853 or 42650 end,
        cast = 0,
        cooldown = function () return pvptalent.raise_abomination.enabled and 120 or 480 end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "army_of_the_dead",
        startsCombat = false,
        texture = function () return pvptalent.raise_abomination.enabled and 298667 or 237511 end,

        toggle = "cooldowns",

        handler = function ()
            if set_bonus.tier30_4pc > 0 then addStack( "master_of_death", nil, 20 ) end

            if pvptalent.raise_abomination.enabled then
                summonPet( "abomination" )
            else
                applyBuff( "army_of_the_dead", 4 )
            end
        end,

        copy = { 288853, 42650, "army_of_the_dead", "raise_abomination" }
    },

    -- Talent: Lifts the enemy target off the ground, crushing their throat with dark energy...
    asphyxiate = {
        id = 221562,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "asphyxiate",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            applyDebuff( "target", "asphyxiate" )
        end,
    },

    -- Talent: Targets in a cone in front of you are blinded, causing them to wander disorie...
    blinding_sleet = {
        id = 207167,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "blinding_sleet",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "blinding_sleet" )
        end,
    },

    -- Talent: Shackles the target $?a373930[and $373930s1 nearby enemy ][]with frozen chain...
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
        end,
    },

    -- Talent: Deals $s2 Shadow damage and causes 1 Festering Wound to burst.
    clawing_shadows = {
        id = 207311,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "clawing_shadows",
        startsCombat = true,

        aura = "festering_wound",
        cycle_to = true,

        handler = function ()
            if debuff.festering_wound.up then
                if debuff.festering_wound.stack > 1 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                else removeDebuff( "target", "festering_wound" ) end

                if conduit.convocation_of_the_dead.enabled and cooldown.apocalypse.remains > 0 then
                    reduceCooldown( "apocalypse", conduit.convocation_of_the_dead.mod * 0.1 )
                end

                apply_festermight( 1 )
                if set_bonus.tier29_2pc > 0 then applyBuff( "vile_infusion" ) end
            end
            gain( 3, "runic_power" )
        end,

        bind = { "scourge_strike", "wound_spender" }
    },

    -- Talent: Dominates the target undead creature up to level $s1, forcing it to do your b...
    control_undead = {
        id = 111673,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "control_undead",
        startsCombat = false,

        usable = function () return target.is_undead and target.level <= level + 1 end,
        handler = function ()
            dismissPet( "ghoul" )
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
        gcd = "off",

        pvptalent = "dark_simulacrum",
        startsCombat = false,
        texture = 135888,

        usable = function ()
            if not target.is_player then return false, "target is not a player" end
            return true
        end,
        handler = function ()
            applyDebuff( "target", "dark_simulacrum" )
        end,
    },

    -- Talent: Your $?s207313[abomination]?s58640[geist][ghoul] deals $344955s1 Shadow damag...
    dark_transformation = {
        id = 63560,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "dark_transformation",
        startsCombat = false,

        usable = function ()
            if Hekili.ActiveDebug then Hekili:Debug( "Pet is %s.", pet.alive and "alive" or "dead" ) end
            return pet.alive, "requires a living ghoul"
        end,
        handler = function ()
            applyBuff( "dark_transformation" )

            if buff.master_of_death.up then
                applyBuff( "death_dealer" )
            end

            if azerite.helchains.enabled then applyBuff( "helchains" ) end
            if talent.unholy_pact.enabled then applyBuff( "unholy_pact" ) end

            if legendary.frenzied_monstrosity.enabled then
                applyBuff( "frenzied_monstrosity" )
                applyBuff( "frenzied_monstrosity_pet" )
            end

            if talent.commander_of_the_dead.enabled then
                applyBuff( "commander_of_the_dead" ) -- 10.0.7
                applyBuff( "commander_of_the_dead_window" ) -- 10.0.5
            end
        end,

        auras = {
            frenzied_monstrosity = {
                id = 334895,
                duration = 15,
                max_stack = 1,
            },
            frenzied_monstrosity_pet = {
                id = 334896,
                duration = 15,
                max_stack = 1
            }
        }
    },

    -- Corrupts the targeted ground, causing ${$52212m1*11} Shadow damage over $d to...
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
        notalent = "defile",

        handler = function ()
            applyBuff( "death_and_decay" )
            if talent.grip_of_the_dead.enabled then applyDebuff( "target", "grip_of_the_dead" ) end
        end,

        bind = { "defile", "any_dnd", "deaths_due" },

        copy = "any_dnd"
    },

    -- Fires a blast of unholy energy at the target$?a377580[ and $377580s2 addition...
    death_coil = {
        id = 47541,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.sudden_doom.up then return 0 end
            return 30 - ( legendary.deadliest_coil.enabled and 10 or 0 ) end,
        spendType = "runic_power",

        startsCombat = false,

        handler = function ()
            if set_bonus.tier30_2pc > 0 then addStack( "master_of_death" ) end

            if pvptalent.doomburst.enabled and buff.sudden_doom.up and debuff.festering_wound.up then
                if debuff.festering_wound.stack > 2 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 2 )
                    applyDebuff( "target", "doomburst", debuff.doomburst.up and debuff.doomburst.remains or nil, 2 )
                else
                    removeDebuff( "target", "festering_wound" )
                    applyDebuff( "target", "doomburst", debuff.doomburst.up and debuff.doomburst.remains or nil, debuff.doomburst.stack + 1 )
                end
                if set_bonus.tier29_2pc > 0 then applyBuff( "vile_infusion" ) end
            end

            if buff.sudden_doom.up then
                removeStack( "sudden_doom" )
                if set_bonus.tier30_4pc > 0 then
                    addStack( "master_of_death", nil, 2 )
                    applyBuff( "doom_dealer" )
                end
                if buff.master_of_death.up then
                    removeBuff( "master_of_death" )
                    applyBuff( "death_dealer" )
                end
                if talent.rotten_touch.enabled then applyDebuff( "target", "rotten_touch" ) end
                if talent.death_rot.enabled then applyDebuff( "target", "death_rot", nil, 2 ) end
            elseif talent.death_rot.enabled then applyDebuff( "target", "death_rot" ) end
            if cooldown.dark_transformation.remains > 0 then setCooldown( "dark_transformation", max( 0, cooldown.dark_transformation.remains - 1 ) ) end
            if legendary.deadliest_coil.enabled and buff.dark_transformation.up then buff.dark_transformation.expires = buff.dark_transformation.expires + 2 end
            if legendary.deaths_certainty.enabled then
                local spell = action.deaths_due.known and "deaths_due" or ( talent.defile.enabled and "defile" or "death_and_decay" )
                if cooldown[ spell ].remains > 0 then reduceCooldown( spell, 2 ) end
            end
        end,
    },

    -- Opens a gate which you can use to return to Ebon Hold.    Using a Death Gate ...
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

    -- Harnesses the energy that surrounds and binds all matter, drawing the target ...
    death_grip = {
        id = 49576,
        cast = 0,
        charges = function() if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 25,
        recharge = function() if talent.deaths_echo.enabled then return 25 end end,

        gcd = "off",
        icd = 0.5,

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "death_grip" )
            setDistance( 5 )
            if conduit.unending_grip.enabled then applyDebuff( "target", "unending_grip" ) end
        end,
    },

    -- Talent: Create a death pact that heals you for $s1% of your maximum health, but absor...
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

    -- Talent: Focuses dark power into a strike$?s137006[ with both weapons, that deals a to...
    death_strike = {
        id = 49998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            if buff.dark_succor.up then return 0 end
            return ( level > 27 and 35 or 45 )
        end,
        spendType = "runic_power",

        talent = "death_strike",
        startsCombat = true,

        handler = function ()
            removeBuff( "dark_succor" )

            if legendary.deaths_certainty.enabled then
                local spell = conduit.night_fae and "deaths_due" or ( talent.defile.enabled and "defile" or "death_and_decay" )
                if cooldown[ spell ].remains > 0 then reduceCooldown( spell, 2 ) end
            end
        end,
    },

    -- For $d, your movement speed is increased by $s1%, you cannot be slowed below ...
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

    -- Talent: Defile the targeted ground, dealing ${($156000s1*($d+1)/$t3)} Shadow damage t...
    defile = {
        id = 152280,
        cast = 0,
        charges = function() if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 20,
        recharge = function() if talent.deaths_echo.enabled then return 20 end end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "defile",
        startsCombat = true,

        handler = function ()
            applyBuff( "death_and_decay" )
            applyDebuff( "target", "defile" )
            applyBuff( "defile_buff" )
        end,

        bind = { "defile", "any_dnd" },
    },

    -- Talent: Empower your rune weapon, gaining $s3% Haste and generating $s1 $LRune:Runes;...
    empower_rune_weapon = {
        id = 47568,
        cast = 0,
        charges = function()
            if spec.frost and talent.empower_rune_weapon.enabled then return 2 end
        end,
        cooldown = 120,
        recharge = function()
            if spec.frost and talent.empower_rune_weapon.enabled then return ( level > 55 and 105 or 120 ) end
        end,
        gcd = "off",

        talent = "empower_rune_weapon",
        startsCombat = false,

        handler = function ()
            applyBuff( "empower_rune_weapon" )
            gain( 1, "runes" )
            gain( 5, "runic_power" )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 5 )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 10 )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 15 )
            state:QueueAuraExpiration( "empower_rune_weapon", TriggerERW, query_time + 20 )
        end,
    },

    -- Talent: Causes each of your Virulent Plagues to flare up, dealing $212739s1 Shadow da...
    epidemic = {
        id = 207317,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.sudden_doom.up and 0 or 30 end,
        spendType = "runic_power",

        talent = "epidemic",
        startsCombat = false,

        targets = {
            count = function () return active_dot.virulent_plague end,
        },

        usable = function () return active_dot.virulent_plague > 0, "requires active virulent_plague dots" end,
        handler = function ()
            if set_bonus.tier30_2pc > 0 then addStack( "master_of_death" ) end

            if buff.sudden_doom.up then
                removeStack( "sudden_doom" )
                if set_bonus.tier30_4pc > 0 then
                    addStack( "master_of_death", nil, 2 )
                    applyBuff( "doom_dealer" )
                end
                if talent.death_rot.enabled then applyDebuff( "target", "death_rot", nil, 2 ) end
            elseif talent.death_rot.enabled then applyDebuff( "target", "death_rot" ) end
        end,
    },

    -- Talent: Strikes for $s1 Physical damage and infects the target with $m2-$M2 Festering...
    festering_strike = {
        id = 85948,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 2,
        spendType = "runes",

        talent = "festering_strike",
        startsCombat = true,

        aura = "festering_wound",
        cycle = "festering_wound",

        min_ttd = function () return min( cooldown.death_and_decay.remains + 3, 8 ) end, -- don't try to cycle onto targets that will die too fast to get consumed.

        handler = function ()
            applyDebuff( "target", "festering_wound", nil, debuff.festering_wound.stack + 2 )
        end,
    },

    -- Talent: Your blood freezes, granting immunity to Stun effects and reducing all damage...
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
            if azerite.cold_hearted.enabled then applyBuff( "cold_hearted" ) end
        end,
    },

    -- Draw upon unholy energy to become Undead for $d, increasing Leech by $s1%$?a3...
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

    -- Talent: Smash the target's mind with cold, interrupting spellcasting and preventing a...
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

    -- Talent: Deals $s1 Shadow damage to the target and infects all nearby enemies with Vir...
    outbreak = {
        id = 77575,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "outbreak",
        startsCombat = true,

        cycle = "virulent_plague",

        handler = function ()
            applyDebuff( "target", "virulent_plague" )
            active_dot.virulent_plague = active_enemies

            if legendary.superstrain.enabled or talent.superstrain.enabled then
                applyDebuff( "target", "blood_plague_superstrain" )
                applyDebuff( "target", "frost_fever_superstrain" )
            end
        end,
    },


    -- Activates a freezing aura for $d that creates ice beneath your feet, allowing...
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


    raise_ally = {
        id = 61999,
        cast = 0,
        cooldown = 600,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        startsCombat = false,
        texture = 136143,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    -- Talent: Raises $?s207313[an abomination]?s58640[a geist][a ghoul] to fight by your si...
    raise_dead = {
        id = function() return IsActiveSpell( 46584 ) and 46584 or 46585 end,
        cast = 0,
        cooldown = function() return IsActiveSpell( 46584 ) and 30 or 120 end,
        gcd = "spell",

        talent = "raise_dead",
        startsCombat = false,
        texture = 1100170,

        essential = true, -- new flag, will allow recasting even in precombat APL.
        nomounted = true,

        usable = function () return not pet.alive end,
        handler = function ()
            summonPet( "ghoul", talent.raise_dead_2.enabled and 3600 or 30 )
            if talent.all_will_serve.enabled then summonPet( "skeleton", talent.raise_dead_2.enabled and 3600 or 30 ) end
        end,

        copy = { 46584, 46585 }
    },


    reanimation = {
        id = 210128,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        pvptalent = "reanimation",
        startsCombat = false,
        texture = 1390947,

        handler = function ()
        end,
    },


    -- Talent: Sacrifice your ghoul to deal $327611s1 Shadow damage to all nearby enemies an...
    sacrificial_pact = {
        id = 327574,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 20,
        spendType = "runic_power",

        talent = "sacrificial_pact",
        startsCombat = false,

        toggle = "cooldowns",

        usable = function () return pet.alive, "requires an undead pet" end,

        handler = function ()
            dismissPet( "ghoul" )
            gain( 0.25 * health.max, "health" )
        end,
    },

    -- Talent: An unholy strike that deals $s2 Physical damage and $70890sw2 Shadow damage, ...
    scourge_strike = {
        id = 55090,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "scourge_strike",
        startsCombat = true,

        notalent = "clawing_shadows",
        aura = "festering_wound",
        cycle_to = true,

        handler = function ()
            if debuff.festering_wound.up then
                if debuff.festering_wound.stack > 1 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                else
                    removeDebuff( "target", "festering_wound" )
                end
                apply_festermight( 1 )
                if set_bonus.tier29_2pc > 0 then applyBuff( "vile_infusion" ) end
            end

            if talent.plaguebringer.enabled then
                removeBuff( "plaguebringer" )
                applyBuff( "plaguebringer" )
            end

            if conduit.lingering_plague.enabled and debuff.virulent_plague.up then
                debuff.virulent_plague.expires = debuff.virulent_plague.expires + ( conduit.lingering_plague.mod * 0.001 )
            end
        end,

        bind = { "clawing_shadows", "wound_spender" }
    },


    -- Talent: Strike an enemy for $s1 Shadowfrost damage and afflict the enemy with Soul Re...
    soul_reaper = {
        id = 343294,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "soul_reaper",
        startsCombat = true,

        aura = "soul_reaper",

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

    -- Talent: Summon a Gargoyle into the area to bombard the target for $61777d.    The Gar...
    summon_gargoyle = {
        id = function() return IsSpellKnownOrOverridesKnown( 207349 ) and 207349 or 49206 end,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "summon_gargoyle",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "gargoyle", 25 )
            gain( 50, "runic_power" )
        end,

        copy = { 49206, 207349 }
    },

    -- Talent: Strike your target dealing $s2 Shadow damage, infecting the target with $s3 F...
    unholy_assault = {
        id = 207289,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "unholy_assault",
        startsCombat = true,

        toggle = "cooldowns",

        cycle = "festering_wound",

        handler = function ()
            applyDebuff( "target", "festering_wound", nil, min( 6, debuff.festering_wound.stack + 4 ) )
            applyBuff( "unholy_frenzy" )
            stat.haste = stat.haste + 0.1
        end,
    },

    -- Talent: Surrounds yourself with a vile swarm of insects for $d, stinging all nearby e...
    unholy_blight = {
        id = 115989,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "unholy_blight",
        startsCombat = false,

        handler = function ()
            applyBuff( "unholy_blight_buff" )
            applyDebuff( "target", "unholy_blight" )
            applyDebuff( "target", "virulent_plague" )
            active_dot.virulent_plague = active_enemies
        end,
    },

    -- Talent: Inflict disease upon your enemies spreading Festering Wounds equal to the amount currently active on your target to $s1 nearby enemies.
    vile_contagion = {
        id = 390279,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        talent = "vile_contagion",
        startsCombat = false,

        toggle = "cooldowns",

        debuff = "festering_wound",

        handler = function ()
            if debuff.festering_wound.up then
                active_dot.festering_wound = min( active_enemies, active_dot.festering_wound + 7 )
            end
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

    -- Stub.
    any_dnd = {
        name = function () return "|T136144:0|t |cff00ccff[Any " .. ( class.abilities.death_and_decay and class.abilities.death_and_decay.name or "Death and Decay" ) .. "]|r" end,
        cast = 0,
        cooldown = 0,
        copy = "any_dnd_stub"
    },

    wound_spender = {
        name = "|T237530:0|t |cff00ccff[Wound Spender]|r",
        cast = 0,
        cooldown = 0,
        copy = "wound_spender_stub"
    }
} )


me:RegisterRanges( "festering_strike", "mind_freeze", "death_coil" )

me:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    rangeChecker = "festering_strike",
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    cycle = true,
    cycleDebuff = "festering_wound",

    potion = "potion_of_spectral_strength",

    package = "Unholy",
} )


me:RegisterSetting( "dps_shell", false, {
    name = strformat( "Use %s Offensively", Hekili:GetSpellLinkWithTexture( me.abilities.antimagic_shell.id ) ),
    desc = strformat( "If checked, %s will not be on the Defensives toggle by default.", Hekili:GetSpellLinkWithTexture( me.abilities.antimagic_shell.id ) ),
    type = "toggle",
    width = "full",
} )

me:RegisterSetting( "ob_macro", nil, {
    name = strformat( "%s Macro", Hekili:GetSpellLinkWithTexture( me.abilities.outbreak.id ) ),
    desc = strformat( "Using a mouseover macro makes it easier to apply %s and %s to other enemies without retargeting.",
        Hekili:GetSpellLinkWithTexture( me.abilities.outbreak.id ), Hekili:GetSpellLinkWithTexture( me.auras.virulent_plague.id ) ),
    type = "input",
    width = "full",
    multiline = true,
    get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.outbreak.name end,
    set = function () end,
} )


me:RegisterPack( "Unholy", 20231127, [[Hekili:S3ZFVTnoY(zj4W6A324yjhN0Ui2a9237oSf7TyXLU7Fgzzj6y9QSKEsYjnfb(Z(Ju)KKIdjLTuAF9mWIUTwuZmC(fNz4qQ7mU7t3DRRDk6UF3CI5uddZRhJ)JRmNE3TPpfHU72iBNpBFp(VeyVf)N)zWMq)Ni)8t(H2UKxpjCxSd(rBstJs(5lU4EV0n7wn2jC7fjEB35BN6fg4eBVoL8VDU4UBxTZZp9xdUBLyCBIHzeYb)ZZW)1nEUUO8XIsCU7wYyp3W4CZR)59l)0gum6vj7xMUXd)N2FbnE849FC)hlhLbzu7xER32Fz)YDre0X(8z4N)p8(cgcXEbFgLUF5d2XE2R8rjSd8sUbY(4je48h2PoB2V0yYyZsKrnQjV)CJjmJYy81Ig31yaYnUz7x6BVlWzd1WU6Ctcn9Vrjpf4SF5Jy2E(eLAmZo3KGYp46UF5F5z7xr9mJjJj9Nz0r90dZnV32lGAGxE(0jnhiMYcV3dtaRJd32GaUmNd)V8ccJXVYJi7pJ)FH4PDcge)duskcdM7XVhgCFg)tEb7xgfJISJZ0BWGL8IFik0X2)POeedSNqya5QKLmsa6yAoJ4FfgJQy5fWgZGNm(AMXAmLAEspO7U13ljnHO2BhISsqP7IW)JFpZocfquBCV7VJFOdH4X))GNSCdCZ1DJ9IY)1pe(FJjWS39w8Vsyb23D7W9lpdZBS9rbPJxTlojfZySsWuCY4cqVF5ZpVFPlYoDJ1Nd8UFt641pgUlWf5ALAhFFMyBX89lDEYXhzHcqB9iZtnFR3LpYyBpxl0deYW21fJ8VqMZ7xoO5JIrBX6i4NDd(1nmKpMf7xI1JhDxk2YgGFTUuHWkjtFGJ)4IwTB96X1JkBAm2n8XaTMK30GZmkJKLY0X0q27uafIWgpdMYndQPZZQDHmokm0NaW4DbEowrHpIIZj01ek0QM9r0WQzdOipxmb6qq0LF3WQeZiMDa0NdMTqOKX212108Ik(h55wPEBZCrmaCwLKIxLk7nVumrE1HlTgqBwwkyQ1nkNU5StNqpFm(sV72yBhS)2ePohIDSdWuAyCmg2C(i(3fVpfPsrwJDrR9C8sZmQmNKrLyHEfFnz32THbw3JzcHp5ZYCV3XD8w7VKRfup14Ffgxor4vmQEcH(FaLBRVlaLbut9epga2)mQUzWyLFyOR16DXpn2Dx5AbVz)YP5UQyiOQz3aakDu(SyO2Zx1msmF)QjL(pgMJx74TpzD)MWD(08iUNW4Yu1uTK3NzhigY1pP1qohu1w4egBPGKOnBh4A5ICSFACQNZNZSbl4KRctYz38(XuI5A1)6Hi3FALgbkobftiJF81iGNQhRgHCi3NAeqyMsJOAiIw4RwJidE7Yc7JS4ck4(0nJ3fvY4RLO5oI2MTehJ0KYnv(tPDqMV0bEgUL4C2Y1dr9s8Ov1loQE65tWuI1)Zo373sC4lyXtgTEJ39dLMTX7ogT3Y3UF0qnEhDm7oyfJyBFlCOj(YJEaGAkeaKvhPwPEEw8V5RAkyH85fC5gbieTZpbrOJRv6JCTxmkZV6p8UiHNPhUoMgaUFu)KIyQqQlhbrz4DARuoplURCooORtPKyrIB1oQTV3kCTfoUENpNKhVljD4S8NKfXBvEncYh(VN9Yhs(WvbHAK)Vv8kkJtfZVQus1j9GHIvlUQI6AASJj2PtawkQMkmNOiD5mY2kjcHZDlMM3jFcsOoJVZsRTfiAWbKrw(kTa8TAYOuv(auI)NyHFmPoyyT5wnDa5BhIGNcvr5c9e9e0v(yKK2o7uro8FHLVzPpV2ENFT)NYXT1dZQwhJqFfXkQZ5ULdJSKFW9KYvZpmyBcOmYVCc9kCnwzTfjER1AQ1Ltjah7P99yAkzdY3NAHe6OkyhKCHftvIS3(vl7vy3PRSIqXoyIpd9tKeuZ(LxN)4IjRDsI3wV89eGXL8rYReo)(Ayasuu2HryXnk1Bn9mTadEBJIdFarwfVu9IHoRPfYJiRc6IEWg7yTXms0ActzwH6qGWL8SeveSWiw48D9xLB5rMdeR8T6P0YZkk2leZMEQMfxA)s(B(7WaNeG6Ttk(N3DRWAUrX1fbNs0sKT5fwhpx2g5JsrQI4EAlSvQIesAnixufmrnJMAC1QDARGMj2XjgwuXoPCo(481KZrvS02uSvJjAet0n5QEdO4BfrrITOjUDz5DCZpZQ531IcDvZ5hvqs4qpXKf7sFNbxMszLdyGGqWQRLaCHcUi7544IFnvjvhL9FfXxrZbuhq2Wm94ZRTRdwJCsX21o(2pMW4PRGxQgMzAtV)W42mlWthuUkdhXfVxlBPCEEfaeiWZbKgZCoN1IqyBGKsT(BQQdFbg5giT(w1emj1kY3oiOIdvqoXHPPOaR0WDovf2slkvJPuMD8iOWoNPlUK6adB)FG6CnchuWs0p4HJ20jmifVip3kMvIjUXqpfNYhUs2VE1Kg57rjDKpB5ZuqZzld81l99ZG3D2SCn5EgzZ0jUJNv72aykWNOHMtbcwk0FuTiT5boh0z3NxKLTTIPiFy8AofZsYYkgER6zmwzxVx2aYv2Gm4Lv5GmXzj3CO2bckOmf1vRuNishXvUfQATjmS9SzwYos77y5ggUflVWpMlwTJjOKfv0G4mt1beZl9hQq7bAB4JclZgLkE6FX23F)Yp4KN71VL1YiuQpIRdljeRYIc1dfDvXGTDFIsRkJL5Ah)zY6UbjRdJ3MRmuSyeHoxmxY4QWEPgs7lZBjV4WQL70jAv51PzLzXaEFyujdgOJi4Mk7mnLQsQe70zuP6syDKcXUbrS6ZQlSb8UviWdWnZPTHaQ5cxf7LeHnoJTT2KAsrtvnJ1w8Wk0Tu5AyMk4qR5BEntqr5UgXEB5IQQ(3PXuDy9qvv0aElzasEFaTl7xi2vNYaOlIRb8Mqa42ToZQdlnc57eZ09Sn0fo8Q73HwrWpEnuUfdRSdJqXKI)5fiC17I44x5ZM24OAXdlweW)GQBlHdYNDMGs5YKLq1Q(QZTrkhMHpTnmELNRx6tSa4mzdOW5ATyQouqL(WmnQzjm83SQYYN8q5id3LUcVq1NzDp3Cl3XkpUHK0eI3riERC5dZgEoeAiRJrjBiyMrhqOosnywhhILrRXrMgBrp0gGJm482EjhHWJEeLp3ZuPlQwBDqZmylgctzBMvwwdfMhVU0u7n0dfWA71zl(Xpy0k8IFzSmbJmpCmrBRGjFUwf5H4JhZgCm7r7(6xXV0QqSr3Uee2H5AlSvi5TRx1u0GfuVmzlNxTr(OQAJP5Y7nJ6HoM5gE1kZxvSDMgrRrPCizhrP2cHSowwuW4NjBtU5Ia(tfDrEMmJp5YCzMxmEHKDjwRJTZ7hgqbwZrYetdumjaHzJNpx1bsRMpHhfJ(2ksLiRicf(0HZfkp4zNLaODGhgH4KjZ73aqrd04zt2P9HVx2UpYxLBGgmQVtz)85twuncW9y5UBlp5gPgJ9sghVB1twpUb5hLVnEfKfZyECJhouJSOV8cCSJdWsilpNcOxuFJIxXYWc9fh)DUz7yMjWwMPd5zQb5z2AYZKH8a2BjjK3qgMZg7elIknro3GZ9T)Hn79KMsjHIqYRN7ZfypK0KdzkJA)E4HWCitzCitko0bUlu1mBY5Usya7CYJQeoQf3vl3wVd9)eoiIzvnFexXOgpJTCuMh4M6uZhus8MaeV5rt8tb2DaDCUK5xtqaCIC)Xh2GOXaT(Li5noh8D2zP9pfOI)6mdm1BgyQXmWSDZat6zWbwW)syv3taIBShrMaTqfJySxQMP2sVoubwhQ1qGpzvakqPE(fmdG8Uwu9ytwgmyyKDEnFJCVxVMDRoznmltcArdQsORJlygG2uLGvDaOkJAQQawLzZXsBE(p4NVh2uQOz)2OmQ0yYeQ87ODsyuzOyMPEEGBwJR9w77rwhJwQynT6N3yQTOblq(uJpYVtzW2jXBF8zWseo8X9Ekv1xczNcHcF0(Nsv9fL9ZNkrjdTWRhMfN4hMs)V5fbQ8(MhxI4GemASeTE2c8JLFVYGQvo)WkK14ynIY6hlMnuLP9yD9siq0YomLFlZeOvrE9HQ0AeQvmVSmPQ0PkSQb8kmIr9qLBfH7WV6fAW8Q314e)8TIzmakMlM4iB88YOikBfhUyWRycvtA(Or5JNDunZhmSnYeJzJtYmf5ZzLZu0KZu0STMIMsnfBgT8jtr91(ozkQ2u0OnMIMnSHuBkkiXqEtXg51j2uKVcm96QIQsAHMxcKduN59Q45WEhydgsM2SUUe0dAkb1Gw7CXCsBiaDMo00G0gNIc7AzBBwLIJqFefA5coOzZiQZxcTP79YklQYXwx15UWdaK6SXj15wsdFpPoZxGw(E3vU4wQcv1QxkDck1nlvlvrSKWK32KggvKPc8DLtf2jShUZmvEX4ZowJEoPmjchVlWk)VBrUnZYVtZAC6RYWn8rFSc3mDXUaSrUefarxjBjBj1lHpgIIsaU9yJCg1zXi0LxLuWuE1oraaCZwcMZ(XvOknPX6BNocvEiDPii(peUE(ndaHu0)AlGPHjHzAl0GP10lpJqzK(ZKS5aCp7XphYAV22ZYY4vPmwJYUhXQcqN)iPJFDbx0GA1r8dQlUK02pfSYLMnARyfD7QIlgmEw78YJfdxlag5KAnDgvjUbArqQ2OobN)dwzWokVNmLEhiaQHnq5rniZFCLqR4MHmv5fDem7VvS3bCN5Pm5mfbXTySOLIG7s(wwxBsOBu3RjOTz0e5yFHSEelhW)yQSRDNJdDSNmpcMG9pEm82wjGQjpbHrrOXw3Q1m3MjuLxaO601Eyf3h5tzpPRkv3VPAlL4pQDn5maKK4G)Q5unURksBEAxRzt1B1fLByxUlrc2qeK40L9agExZMvvBbuTdxPrgmv0LMZVqhnd71zbV5C9CqQlo6B0rIqIIYzUEAkw2LvoQ)9TwXQhn(DMyHmPCxUkCRxGDXYLBxjYVPO1dByj3(BfiMlwozU)RteIBqvtQbnp9CYay(yNxEDeXYRB)eHvFJanCOfwRcd2LGrlkEQHLzKJMqa4(dckGAoFUABCCZCwnrXLuumTi9sFnZXcvHpRj1yBVK6JtL07CnDcLVqCbDC(huwE8kybD0LZCLQ)HJT8S)wvYxMcKl8c)LpelwfoOJDDv(WkU4NlGg0uOHcUKlaHdEPsP6qkchbELLZuFGj1Uijf73VKdptJdvuInMuihpyBFRi8pMVswumchWXk7Mxisuk4SRkaDBt14ygYo3r)V78IIqUJx)uSTprjlBG4aQ3gxCbvvrmKdYvrNWq8cOZkTnwjJzzWB)0f)IpYMeay9IH9si0YtpPfUuGx8vvmyZuQ63U1efvehn9)dCrBdNIaiUAFBXmxu2LTTuQ2BdqUn2BnjDpJ4TktpcaOuQnPbP(roe8jBuQ2KoPoIMZEm(ADoC0bcnGQYmm1tuw4FqTLcCOgIXHi1y9Rsv)vgcOnyKEymX3kh)8eE9DYbaLnm)8ksHUAtW3uEJGkG5vVjrcDRl(yIv0txWRGqfWiMO2suAXwrLJVz1rbHKaV4LL((bKFPP5ApC01w2XRiyTgQsgJah7N6StnCOPoDgDIYwwQzJeTW4Pg78Lq0jxMiUzBp1xNVmCF(LMl5N9sdSOQ7vo1lzTQ9Pia4uVK9DBBDwf0mvJeqMfQAQmfDAD32eoQ6aNtMKTsl8KjPAtYVHT3ztts96ZtfDCD3UkP4bWyvQvFX1fEZyd9rVInCQT3(222Bk6j5UD9dXdO9kRDHDE3kD1hAkb1jLvqL1gxsWmjul1vOs9Lx2E0mL8vk((n1h3yj7MHW7l0)OYEi)odL)k3wdDbTfAmFaMuTTv)GDpFkD7BuUnwLmnvIIb6ijQ7WcnfUsVsq3Z(zdBBJBfuPFEf5d170Lck3VtJj1xkOW9ZNOyQ)r7obfEhav2Fnsj7f0Lll6h4ReunAP8)d7gbfQSiNUqqpDHGcVtT)iVEEA2zeqsyMuRiX1VmyHbrF6tzCrOe(A8TFIs1RAqqF82QDtv8Ptq5eoRj1KhG23wst4kDh85eqqixlOseMXW9(4Sfj5CY0(yLZ6ztzFXggaTzLKclEOX3x)USsNd6l0afZH85WWVrvObREQKAHkz)UvvKZk)XUY7SsYmi31ftNvYRcKx3oMpKDGhreXbpiYCHMxdfJK0pGT61NxLeuJwYhWbtRubUbSDZYIvsKpVAsts8dGCVdMsH7mUmF24f3siy(3nNyo1WW49yAWoMeghoJ)pTbR35Tnkmof7ike7W6vvNIVxTFzmz9SyIYEsi5ZiN9U0WS97gRCTXgVcBY49F838in9HXptAgYam2YE8RkmAy3PymitdHEyPLfEqdn(YOkiB2Bq(kXqU0Flhm5tgTgA7)Oa(iXPqhYifM7fhfknno(j)LVq456FWWZ7eJN6SB4aEZ8I6tikuvS60W2jAIDGHx)bzaT6UXKUTmWPIjgMOS4OiHrGXpjbGBEakCaKnQfftWItzE7MLa(N5seHJSastrZzANaBavfQtgghCfCsZ4H5SEKEbCWDKWwOEaZol0oTbat7JKk7FnT(e2aAXT2PKuO15l09sfGaGndtHC4GVWI8OjCPQLudPzJQmPjmzQMLyp6SfdJhUarIEqHaifIvLqLdGnkTAFdpqVzhH0baMhT05fgU9bp4OTMaGBDfu59I1O0QkGyiEQLvQdCoVKI3)QMvvFHKkQpyOIAP)8ZWmX8xwJkO)8Z6w98rJgm8mzkdv0JWNoqELYxym7NgoeEc96PJEZqzI3xBwpGMIk8thnQwGEsoiroCrVlhgRirXojgL(b2GPJwYwBzUgaX(CuXSdeNt)LmAhazaVXShFDoil(STRjKzpi(Cqw8P0xtiFu0Sq9Rdu36LQWB9zoIaWU5baMd8WNqynXWjQVNGTqn8IgiSLk49zXuaGDh4QdWjANq19NdAiv5dpHoai2b0kqQDDchgkXwU2lqMbTexPVyPn3R8IoKAlAS4M9vCfOHB94(f4Aaw62Rxai5ESw0QX4O4qN8dXDus1NVQgqhECDmAyo(p8GVFQWRuy3rgIqq)WvT)wWl6qQTsXqPTIWH0JaxdWk1qSXJ1Iwn10cbECDmAKAi2iz4JY1xVcCna7r4xTFQkGuy3rEKor5Ta2DeL)(o1rvVcCna7r4fSbq7qriaS7lr4jkV3PCJjDQQD)cD1W9WwhtxQ(WG(yGcP4IwtUW2E13n1rbOIe2jjEB98zdMP5JAju7ekgOUey(CC4disJ9w2HSCWxWiAjoiVcXaZf9GDsQiMJGr8Dio6uE1lqvg6qThGasoQnfqkKpQTkIdMn2Y6ZeCAagad(buT1D5vu(GHn(XcNy)0WzVU4K8nA0I5gLKFVI0l4rQY1epC9SxmiYEBDYbv2hQ)A25VDhSpzgaRVehMMIcSsd35SHdW0p67eW2P(0GqsN6C2OpxL0OF2DOxcG3vNsc5GRZ3MvJxQdeGbWknhDlxbb4JQ)WGa6r3mBgDV7BiqEWnDyNdqtGLbokreeqpAr0loG7f2WrBxbb4JOxg5b5PMzSDnr3PMz87d5WlyZmA2RNuK(7eMz2NNueiG3f0nqm0hX6ZqGSlO2gbJxv1sVKXX7w9K1JBq(rwj4)SoZI6cxkEuTahpUXljk)4w7f4yhhyNIS8CeUR(kgolwBeSEvLn1zMbnQwGd9NzkholwHBpcYMLqUc7iLzqa)J7XTbQzfUa7NcfCF6gaqZpMUg(hdPV1MuZLNKr51dPJH(Xq34NLGJWXNoOzb0o7W6bSCmZHneUJmQVCaDkKpgkMCDriJGlEExcxqYfUhmKAT34XTbQYTgfpMUg(hdPdzpkCiDm0pg6wMDi4W6bSCmZbX2KcgqNc5JHIfAv285DjCbjxO2lIAlIL02JIgt)cFqi3i1COR83bdLHGF6NUC28jv5vEGajhg10ku3OyQbxq8yy5YDn8bHSAUSzdgKaeOIlRhq44YtH7icC4Uc(AyjqHdCGm8B5yI)Z7Ky0iyuTahI)qfjgtGJLfFnsTUshstUNKb2cmPK7bnQwGdn5EYhll(AKGpJ75dSnnbH6r1fBsO1dZBrFdFDGSU9hSwTHChGhI)lW(qwH2IorRknA4oa(qbmirLuTWvJag6C4RdK1tOQ5HjPdWZHP8OFHnomLh9H)bO845)GWY9L)Z6bftXqXulO0SPFaJ9tRWvO9apOjSQ(II98ZNXX9kFRrp)mmMKhzeKJOrVEOX4zVbWwh)ubim5PaNrJwmuEeVqAV8y0qjgnYXi(9EddojcXZ5eQJ(jJjtO2gO)FSm7IxCz2fFJKzxuiZQnfBSFdfVr7mOHGs7CU0NDleeW7GnwzAF2RqqaVlO7UVVwHazxqT95Xxec4D0Xrae8hbN(Bc7OlP3khnvEhBXPpOFHUoW9yYTe(CIQByQ6fo8XJh5Hd3NNRoiG3vMKD5ve83s2rxsVvQhknAuFiP6yORdCpMcZaFwF1Zur3YBC84rUjPgLJUfoc7xORdCpg3S955xec4DL7Pt0E7aEhr7x2ThTZ(f66a3JWNytO2HYriG3BYXt0(lcTdT5phMgE)cD1W9WwxtxQ(WG(4IJD96qF)Wh9iFmQSXrdKSF5JOy8VVlHGesDutjdl)RKZ(L(EjPKpgsPLJlim7mBVlGz0UUKb7ANAVYob9Z7)4(LNVFjP9gGV6rFvRoR3D33tIFnJqiaXWKDIsW2D3IJOI8LAO8lfucoelKt42v2PVz(fX2Ej56Y7)OONZRX)2Qhs(KvIMB(wV1Zpt9xNUpwbEmq36f4ATogH(kI(NjnfEW97WVpZpBhGXK99Eo5TKkbHuFj0Y(ou44LU4Yjdgk4aRsQuQqxdp)CLofVtJY2wVAaCKqvCPJetNFnmaritx6pLw2B)QL9QKW4vwrOyhmfTyYartKRNuEiBPpb(TBYHjS)2(L)vrvstOjZYsN(2aBS8RXhGU3ggnpbL6T(Tpy7Vdn3i))BH8tqZN8wNWaxpcOMxGybh2YbLeLGZi5a2pzxlMpT6KfOZOVSEglcX8d3eEIt4u5FfLWV62iFuks7PUG5GsDjJbdRvNQtkT6X1tS6NosIYlX6BH5e4jibmfFwz5NyxtpXmPMysOWBmMmq2NlSBMFzJtbs5rDUAskHCPoI4KVqDoFgfZt2Yq)cwPL8HoC65LkrmN4)ruScnp87T7qVZFs7Hzh1FO20wRuQ(v93X2A1cHQCdQ3BfbIKNFwHqyqtqQ(DuO3CJzLhr2buVNAuFdHRqhZHmhlvuqfkiZlXgJmFqnVzMkikt624l6P2I5cob7r(VMfYDvausStPxQ5MRMqT5I0F)LbPyQbPnLY6MelNhEgoCdxl0dzkiUUjJrFHeMYZpZ)7EblmMnsIZT6VgZhi5GxCOf0t(VpG)NlTUUscPw(XzvB6S6G4rRaxTkj9po4mXQ6y6VzCf3GzOdQofEIw9CiNaZu2sZJYqc6g8AFcdmjVln256IPl3WWTyEf(rulu2(LywGX1zc(uwQWo8Yr5rd9l2((7x(HI4J)nIaf)7)n8t(ZeCa53yVF5My065VAtAAuYpFXfp(4JJFm8XnKe9WXiCbws67p3yYKRMCrgR9C8Yh7iFdmF1I)i)RY7Vw8d3CH9cCggB88BbKV89MtU6I8v6pVk)2f)ZI)wom9Wz4Sl6T4a9Zs1HmLi)nDXH51ZU69V)cQ6LV4dv)9CmqYN5rV0n6d0RModZsiFCzpN9Jl7Rw8FH)X9l)eZVwmrwRpc0KQ1fCAXOTRYom3iaNG1hjkl125Ebpe(zS5YxWADb2(z9MqP)DS2GvP2bjvarEBfgs)arF3IVzUPjySGdakoXaHFnG5)1kmy8oymCgekYS7e)vfggAYFjr8evrx)gJjl()AVRTDBBJMWplb)acIWb(xKkY1xykG2GIEBrDU2m0wYoUrYsqhsramYZE3zpX9Wm7bj744uIEtJi5UZoN3zNV163btSO3X2Jp6L8UmDnkcAg(FjHlSC5VE1oPGgx8nE0Jpo8W3i6zJc(sTZ(ArWvXGXJMwt(C5SiCKNUcdSMq)Br9a8)SDdFblQb8NN8b2zsXEG1gPDR5aJTsOkfJZDbTzdkLmEIjH0fBeibNWJxaB77no1NPa3Mwhgf52FryoGFXWWKCHIxoj03Q0DQ(fDMTI1dlzbJ0H7(n1OQ2GIjNqT(a(G3EYhm85A99eq5w)zXwuug0KfGTTL7gOozmI7KcL026MmyaY1Fa(DQqHGHzFpiyScnxCwFiDyMHyBklWIvVe0xtnDA66FYSrdnshh1SQYAVqR2V7AMtRp)wR)YIZsiMBN)SFnA8986Zaxeh)6Ya9AlH8AYa)6XGFTyWZ89dI6OBvgqOzkVF38LVf(FwD7TnmvlMiqS7kFi0aYMOoBNmGVLaZQ056WgneJNv04byQwrculNr7(OZW)c0tbpmZCZgVHk2EQmkxqaXdtKCsDLNLjFIkuC5zfpNSWJLlHdGjvYsPN(GzgQDoTcNo5llxXUsaYJZQPu1f3Ykb0D8Di3ahSP38XK3zgXN2kIPf9I)OBAdFvDeFAL9)UCshAFM8Qw62Cv6HXd0hkHKo6Z(shCVrF(NGVf9jWj8vG049Arw81Bf(6TIy9Iaik0h6TEXH3o6ZDwVvXxVvPVEfDEF4QBD6eJ6BHWC5CSbdrohBn8oeyTno5uD0KJhUmOHpCCYPSHL27(2fyM6iHzDS2DJV48yChRXjQkCIIc(So(cOjQaWvnorrDaKvMIUsZtOHurkfr6bG0MdbOnHWgfrZo6a(fehejc5MqOKIO3NDMBeNXjd(ghS3ydxkA1HzTlBVJL7)tVwbMqw8eBACQ9ki1SC6tAorgvFsZPWL(VBsZeCLTlwTtfSGxQamlDrCn)aa6umOkcRzrsCk)OzPsC7)pjBMfSynVpc4vQ1QTFMD)wGsAAxTBMS6GEcpJAdBwHghXqDvriXwbr9BlmQbIV5I352fZF10Zh98UmgGfBthm27zQaeWb4Je0vs1grXTd9xuyMtfAmXP1wfZktv1kCv1ksv1QEv1xXQQLPOQwzQZfqvTKuvLi1XJtvnMxv6uR64dePVDGwNMN3VJ9r(hwz(hGAggtvJYNG6g)aNkhFKJQPxXYldXgXRNLkNKPorm3x0jvhxN4WmdW0jk71jEQ1j26OuajPhGXtliHJgH2iM2PGvoHSTi1i(xnqJT72cVVLT707VzNGm1tw3Z1T4BT1bnZ87VWFyveYw8rLOD5WhR2vZBImEgPuhF820EdBFbBJ)IWelyneZ1bThV0MxEo)wlw34QVJAJajnbehcn1cAAGfKPZedMtrC6i4k8I6XaIh(FF7J)b7xyV13(4VU631d6PSfXj2hQUzFT51BOEwSJChk7t5g5CvngEvBZ5ogDNioSW(8CSHbR97ChNzwDnrWf2a3(NqY1aM1h)nqnYAWfAwoCoDIC2B1u2EIL07eLNzhApdwpYSM4y09qx9VZW75sOhzmMhrZGlMJkJYhBT4IkltTTJjzzhJYMEapoXC0fUPMW7vEqT)oTJvOiIwT9C(CT3r7pCm9S6e6L(fBVE1Y7FOv6dz51abX1pRO0pyET6YEW4PiV)(1(Oqql9Qcqu6D(G3jgzy2aDpdLpwJuACEbjroq1iXuda886rgOHjnIsjAF8rwKWMRx9W(TSHC(MXLnvRVj5U33JVzdcHC11UOwjZX3vj982HvpUfhp3oJ90s)Hite3ZzOuaKCABaYmyy33Gd0GKBDEOd)zUzTkaXTC2eBYKmZlS9Y2j)TNBwgMunM)e23GtqgAtoGaIMpoFPOXEb9XM)zoZ(HZhpiH522B2CpeKODrZA2lXfPbgP02yWzOTFfVRX6CNEjKxOnLXtveCjiuecgxnOiBATWCqlYI82NNScJAXuxwsIdJjf4lRusTziHrRypNH1tTwZ6UNZMXHtzpzHLFzwQhon057XVVp7sjVRxldd(W3HtihxokClMl)W))9lM3YCVILgsGKb0EgOA91ohqOVb(KKCmGe8)hsembFKcNYa2EKJfCgFEi80IobPF2H1vJZRGpTlFyEqCu4xx5Sk4Jy8dEoAXgp3FpCz3XA(EJMZ90KYzDmkUlXhK45kL(yTLXNzKD7ArJCBNCqD5aNEhE9n7Agp5IjU)o0tXeQ3MZq8Mtwpb2ucGSqKPK31XgtGsR8eiOLOwbSpYl6CxrSSn)syhndd6(b3eX0cb9lliiTNhHJ9QVl5eY9AeKNmII2D8C7v5ZJXpUjWBzsfkAGWJxo(2igzhtWNMbLiKsomIKJ)znXE5weXqOEKUcqgT)qOqFJvq0pskhwv85cZ1JXeHvbEkwQvYkIMcQu6A4pLNzIc)Q9ixTh5QzJC1tuQDFILaa)y4KL1gc91dM1dlpSWFegpr77H4G7EzbZANYb4V5etOTEuay9NgaQ6XGWGRA8BeldabARqfJxMpKwdiCN1JWvu(YRu8U6To(5f9REl1xHyH1Bn0JmwTK47aYyZXH(py(Z5Bk4VCAgKtLDhcFjCt7dGEYgg1TtUFcVBAWQrgw9uKN0jdjrQUskrVhGehTxv4DsvwGTeeAx3UFZx5HM4FF3VPZb6KXtrVZnWAz0IJ8s4q1nPjNbcnrNBMjHgjxNWvKTzpEYn0JnQCHz0nFdmCgYf9V9AsUGr0hMCbFKEAKlyJnMCH7OCBZFVFMgvn8bq6ivHFlXr1lz2H7RafH4h5r(YUdn9hGAH3(WnZb)3lAGwSIRnvE(pWAnWMkZt7a(IJvlO88ao4xVFXw0(HJfuzi47v7RVEc6LnB9zJqLn3E)M5AehjVplv)0RiBCmAoxHyGb6yLTKdnQJ3274zLSHnKBrRX(qcdE0jxNgXLm6dk23h4wTDZCWU8Y7Ed2SlFXoE1USXL3hIOevPP2OxFR99F2t5ih86fWk3CBVBdKTdbuui07MwxIF1kIwtTPNNxXrG3)GUkf1lnWbcGfjekKWaJGcd2muW2hMLv)M4Au4krJ2DLiCLmm0DMTu6eISLdMD7GJrAUl2SNB(j2JFPcPAUF(X(QqwI4UDMypt8csW2i5sq2ZCTPEpFMj5qFx7xMVqTznMNu2oxBzBkFh0aPH(4EaChaeUPYX6rYDwSR)JcP7eyp5GcrKNauDpGz9mG8clhZv2lbGzFMX2nplVoWPLfQzZuXngujrEsVI7Rxf3NzKEBP4MjCVZuXnMh3xeCFtOEqBpKBdfKH9ZRpG8MPgqmxxViO8otgEVgqunGxEmDF1LT739PvBU6YlVF5EXFzRE)M2B3Df8Fx9V]] )