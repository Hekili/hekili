-- DeathKnightUnholy.lua
-- October 2022

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local roundUp = ns.roundUp
local FindUnitBuffByID = ns.FindUnitBuffByID
local PTR = ns.PTR

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
    antimagic_shell           = { 76070, 48707 , 1 }, -- Surrounds you in an Anti-Magic Shell for 7 sec, absorbing up to 10,461 magic damage and preventing application of harmful magical effects. Damage absorbed generates Runic Power.
    antimagic_zone            = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 32,490 damage.
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
    soul_reaper               = { 76053, 343294, 1 }, -- Strike an enemy for 463 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 2,238 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    suppression               = { 76075, 374049, 1 }, -- Damage taken from area of effect attacks reduced by 3%.
    unholy_bond               = { 76055, 374261, 2 }, -- Increases the effectiveness of your Runeforge effects by 10%.
    unholy_endurance          = { 76063, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground             = { 76058, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    veteran_of_the_third_war  = { 76068, 48263 , 2 }, -- Stamina increased by 10%.
    will_of_the_necropolis    = { 76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk               = { 76078, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.

    -- Unholy
    all_will_serve            = { 76181, 194916, 1 }, -- Your Raise Dead spell summons an additional skeletal minion.
    apocalypse                = { 76185, 275699, 1 }, -- Bring doom upon the enemy, dealing 620 Shadow damage and bursting up to 4 Festering Wounds on the target. Summons an Army of the Dead ghoul for 20 sec for each burst Festering Wound. Generates 2 Runes.
    army_of_the_damned        = { 76153, 276837, 1 }, -- Apocalypse's cooldown is reduced by 45 sec. Additionally, Death Coil reduces the cooldown of Army of the Dead by 5 sec.
    army_of_the_dead          = { 76196, 42650 , 1 }, -- Summons a legion of ghouls who swarms your enemies, fighting anything they can for 30 sec.
    bursting_sores            = { 76164, 207264, 1 }, -- Bursting a Festering Wound deals 20% more damage, and deals 200 Shadow damage to all nearby enemies. Deals reduced damage beyond 8 targets.
    chains_of_ice             = { 76081, 45524 , 1 }, -- Shackles the target with frozen chains, reducing movement speed by 70% for 8 sec.
    clawing_shadows           = { 76183, 207311, 1 }, -- Deals 734 Shadow damage and causes 1 Festering Wound to burst.
    coil_of_devastation       = { 76156, 390270, 1 }, -- Death Coil causes the target to take an additional 30% of the direct damage dealt over 4 sec.
    commander_of_the_dead     = { 76149, 390259, 1 }, -- Dark Transformation also empowers your Gargoyle and Army of the Dead for 30 sec, increasing their damage by 35%.
    dark_transformation       = { 76187, 63560 , 1 }, -- Your geist deals 554 Shadow damage to 5 nearby enemies and transforms into a powerful undead monstrosity for 15 sec. Granting them 100% energy and the geist's abilities are empowered and take on new functions while the transformation is active.
    death_rot                 = { 76158, 377537, 1 }, -- Death Coil and Epidemic debilitate your enemy applying Death Rot causing them to take 1% increased Shadow damage, up to 10% from you for 10 sec. If Death Coil or Epidemic consume Sudden Doom it applies two stacks of Death Rot.
    death_strike              = { 76071, 49998 , 1 }, -- Focuses dark power into a strike that deals 436 Physical damage and heals you for 25.00% of all damage taken in the last 5 sec, minimum 7.0% of maximum health.
    defile                    = { 76180, 152280, 1 }, -- Defile the targeted ground, dealing 682 Shadow damage to all enemies over 10 sec. While you remain within your Defile, your Scourge Strike will hit 7 enemies near the target. If any enemies are standing in the Defile, it grows in size and deals increasing damage every sec.
    ebon_fever                = { 76164, 207269, 1 }, -- Virulent Plague deals 15% more damage over time in half the duration.
    epidemic                  = { 76161, 207317, 1 }, -- Causes each of your Virulent Plagues to flare up, dealing 282 Shadow damage to the infected enemy, and an additional 113 Shadow damage to all other enemies near them. Increases the duration of Dark Transformation by 1 sec.
    eternal_agony             = { 76195, 390268, 1 }, -- Death Coil and Epidemic increase the duration of Dark Transformation by 1 sec.
    feasting_strikes          = { 76193, 390161, 1 }, -- Festering Strike has a 15% chance to generate 1 Rune.
    festering_strike          = { 76189, 85948 , 1 }, -- Strikes for 1,308 Physical damage and infects the target with 2-3 Festering Wounds.  Festering Wound A pustulent lesion that will burst on death or when damaged by Scourge Strike, dealing 308 Shadow damage and generating 3 Runic Power.
    festermight               = { 76152, 377590, 2 }, -- Popping a Festering Wound increases your Strength by 1% for 20 sec stacking. Does not refresh duration.
    ghoulish_frenzy           = { 76154, 377587, 2 }, -- Dark Transformation also increases the attack speed and damage of you and your Monstrosity by 0%.
    harbinger_of_doom         = { 76175, 276023, 1 }, -- Sudden Doom triggers 30% more often and can accumulate up to 2 charges.
    improved_death_coil       = { 76184, 377580, 2 }, -- Death Coil deals 15% additional damage and seeks out 1 additional nearby enemy.
    improved_festering_strike = { 76192, 316867, 2 }, -- Festering Strike and Festering Wound damage increased by 10%.
    infected_claws            = { 76182, 207272, 1 }, -- Your ghoul's Claw attack has a 30% chance to cause a Festering Wound on the target.
    magus_of_the_dead         = { 76148, 390196, 1 }, -- Apocalypse and Army of the Dead also summon a Magus of the Dead who hurls Frostbolts and Shadow Bolts at your foes.
    morbidity                 = { 76197, 377592, 2 }, -- Diseased enemies take 1% increased damage from you per disease they are affected by.
    outbreak                  = { 76191, 77575 , 1 }, -- Deals 124 Shadow damage to the target and infects all nearby enemies with Virulent Plague.  Virulent Plague A disease that deals 1,394 Shadow damage over 27 sec. It erupts when the infected target dies, dealing 297 Shadow damage to nearby enemies.
    pestilence                = { 76157, 277234, 1 }, -- Death and Decay damage has a 10% chance to apply a Festering Wound to the enemy.
    pestilent_pustules        = { 76160, 194917, 1 }, -- Bursting a Festering Wound has a 10% chance to grant you Runic Corruption.
    plaguebringer             = { 76183, 390175, 1 }, -- Scourge Strike causes your disease damage to occur 100% more quickly for 5 sec.
    raise_dead                = { 76072, 46585 , 1 }, -- Raises a geist to fight by your side. You can have a maximum of one geist at a time. Lasts 1 min.
    raise_dead_2              = { 76188, 46584 , 1 }, -- Raises a geist to fight by your side. You can have a maximum of one geist at a time.
    reaping                   = { 76177, 377514, 1 }, -- Your Soul Reaper, Scourge Strike, Festering Strike, and Death Coil deal 25% addtional damage to enemies below 35% health.
    replenishing_wounds       = { 76163, 377585, 1 }, -- When a Festering Wound pops it generates an additional 2 Runic Power.
    rotten_touch              = { 76178, 390275, 1 }, -- Sudden Doom causes your next Death Coil to also increase your Scourge Strike damage against the target by 50% for 6 sec.
    runic_mastery             = { 76186, 390166, 2 }, -- Increases your maximum Runic Power by 10.
    ruptured_viscera          = { 76148, 390236, 1 }, -- When your ghouls expire, they explode in viscera dealing 138 Shadow damage to nearby enemies.
    scourge_strike            = { 76190, 55090 , 1 }, -- An unholy strike that deals 379 Physical damage and 275 Shadow damage, and causes 1 Festering Wound to burst.
    sudden_doom               = { 76179, 49530 , 1 }, -- Your auto attacks have a chance to make your next Death Coil cost no Runic Power.
    summon_gargoyle           = { 76176, 49206 , 1 }, -- Summon a Gargoyle into the area to bombard the target for 25 sec. The Gargoyle gains 1% increased damage for every 1 Runic Power you spend. Generates 50 Runic Power.
    superstrain               = { 76155, 390283, 1 }, -- Your Virulent Plague also applies Frost Fever and Blood Plague at 80% effectiveness.
    unholy_assault            = { 76151, 207289, 1 }, -- Strike your target dealing 1,261 Shadow damage, infecting the target with 4 Festering Wounds and sending you into an Unholy Frenzy increasing haste by 20% for 20 sec.
    unholy_aura               = { 76150, 377440, 2 }, -- All enemies within 8 yards take 10% increased damage from your minions.
    unholy_blight             = { 76162, 115989, 1 }, -- Surrounds yourself with a vile swarm of insects for 6 sec, stinging all nearby enemies and infecting them with Virulent Plague and an unholy disease that deals 394 damage over 14 sec, stacking up to 4 times.
    unholy_command            = { 76194, 316941, 2 }, -- The cooldown of Dark Transformation is reduced by 8 sec.
    unholy_pact               = { 76180, 319230, 1 }, -- Dark Transformation creates an unholy pact between you and your pet, igniting flaming chains that deal 2,781 Shadow damage over 15 sec to enemies between you and your pet.
    vile_contagion            = { 76159, 390279, 1 }, -- Inflict disease upon your enemies spreading Festering Wounds equal to the amount currently active on your target to 7 nearby enemies.
} )


-- PvP Talents
me:RegisterPvpTalents( {
    dark_simulacrum      = 41  , -- (77606) Places a dark ward on an enemy player that persists for 12 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    doomburst            = 5436, -- (356512) Sudden Doom also causes your next Death Coil to burst up to 2 Festering Wounds and reduce the target's movement speed by 45% per burst. Lasts 3 sec.
    life_and_death       = 40  , -- (288855) When targets afflicted by your Virulent Plague are healed, you are also healed for 5% of the amount. In addition, your Virulent Plague now erupts for 400% of normal eruption damage when dispelled.
    necromancers_bargain = 3746, -- (288848) The cooldown of your Apocalypse is reduced by 15 sec, but your Apocalypse no longer summons ghouls but instead applies Crypt Fever to the target. Crypt Fever Deals up to 8% of the targets maximum health in Shadow damage over 4 sec. Healing spells cast on this target will refresh the duration of Crypt Fever.
    necrotic_aura        = 3437, -- (199642) All enemies within 8 yards take 8% increased magical damage.
    necrotic_wounds      = 149 , -- (356520) Bursting a Festering Wound converts it into a Necrotic Wound, absorbing 5% of all healing received for 15 sec and healing you for the amount absorbed when the effect ends, up to 5% of your max health. Max 6 stacks. Adding a stack does not refresh the duration.
    raise_abomination    = 3747, -- (288853) Raises an Abomination for 25 sec which wanders and attacks enemies near where it was summoned, applying Festering Wound when it melees targets, and affecting all those nearby with Virulent Plague.
    reanimation          = 152 , -- (210128) Reanimates a nearby corpse, summoning a zombie with 5 health for 20 sec to slowly move towards your target. If it reaches your target, it explodes stunning all enemies within 6 yards for 3 sec and dealing 10% of enemies health in Shadow damage.
    rot_and_wither       = 5511, -- (202727) Your Death and Decay rots enemies each time it deals damage, absorbing healing equal to 100% of damage dealt.
    spellwarden          = 5423, -- (356332) Rune of Spellwarding is applied to you with 25% increased effect.
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
        max_stack = 1
    },
    commander_of_the_dead_window = {
        duration = 4,
        max_stack = 1,
        generate = function( t )
            if talent.commander_of_the_dead.enabled then
                local applied = action.dark_transformation.lastCast
                local expires = applied + 4

                if query_time < expires then
                    t.name = t.name or GetSpellInfo( 390264 ) or "commander_of_the_dead_window"
                    t.count = 1
                    t.expires = expires
                    t.duration = 4
                    t.applied = applied
                    t.caster = "player"
                    return
                end
            end

            t.name = t.name or GetSpellInfo( 390264 ) or "commander_of_the_dead_window"
            t.count = 0
            t.expires = 0
            t.duration = 4
            t.applied = 0
            t.caster = "nobody"
        end,
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
        duration = 5,
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
me:RegisterTotem( "abomination", 298667 )
me:RegisterPet( "apoc_ghoul", 24207, "apocalypse", 15 )
me:RegisterPet( "army_ghoul", 24207, "army_of_the_dead", 30 )


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


local any_dnd_set, wound_spender_set = false, false

local ExpireRunicCorruption = setfenv( function()
    local debugstr

    if Hekili.ActiveDebug then debugstr = format( "Runic Corruption expired; updating regen from %.2f to %.2f at %.2f + %.2f.", rune.cooldown, rune.cooldown * 2, offset, delay ) end
    rune.cooldown = rune.cooldown * 2

    for i = 1, 6 do
        local exp = rune.expiry[ i ] - query_time

        if exp > 0 then
            rune.expiry[ i ] = rune.expiry[ i ] + exp
            if Hekili.ActiveDebug then debugstr = format( "%s\n - rune %d extended by %.2f [%.2f].", debugstr, i, exp, rune.expiry[ i ] - query_time ) end
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

    local expires = action.summon_gargoyle.lastCast + 35
    if expires > now then
        summonPet( "gargoyle", expires - now )
    end

    local control_expires = action.control_undead.lastCast + 300
    if control_expires > now and pet.up and not pet.ghoul.up then
        summonPet( "controlled_undead", control_expires - now )
    end

    local apoc_expires = action.apocalypse.lastCast + 15
    if apoc_expires > now then
        summonPet( "apoc_ghoul", apoc_expires - now )
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
        class.abilityList.any_dnd = "|T136144:0|t |cff00ccff[Any]|r " .. class.abilities.death_and_decay.name
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
        cooldown = 120,
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
            if buff.sudden_doom.up then
                removeStack( "sudden_doom" )
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
        id = function () return IsActiveSpell( 46584 ) and 46584 or 46585 end,
        cast = 0,
        cooldown = 30,
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
        id = 49206,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "summon_gargoyle",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "gargoyle", 30 )
        end,
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
        name = function () return "|T136144:0|t |cff00ccff[Any]|r " .. ( class.abilities.death_and_decay and class.abilities.death_and_decay.name or "Death and Decay" ) end,
    },

    wound_spender = {
        name = "|T237530:0|t |cff00ccff[Wound Spender]|r",
    }
} )


me:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    cycle = true,
    cycleDebuff = "festering_wound",

    enhancedRecheck = true,

    potion = "potion_of_spectral_strength",

    package = "Unholy",
} )


me:RegisterSetting( "dps_shell", false, {
    name = "Use |T136120:0|t Anti-Magic Shell Offensively",
    desc = "If checked, |T136120:0|t Anti-Magic Shell will not be on the Defensives toggle by default.",
    type = "toggle",
    width = "full",
} )

me:RegisterSetting( "ob_macro", nil, {
    name = "|T348565:0|t Outbreak Macro",
    desc = "Using a macro makes it easier to apply |T348565:0|t Outbreak to other targets without switching targets.",
    type = "input",
    width = "full",
    multiline = true,
    get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.outbreak.name end,
    set = function () end,
} )


me:RegisterPack( "Unholy", 20230221, [[Hekili:T3t)VnUTs(3sWdv1E3TETKJt32l2a9ko8WR49XIME39Brw2wowVvwYNKCstrG)B)iPKOiPMHKYwjz7IfVpAJj1WHdNV5qYBDV93U9M1bfH3(p9g7nzSNN7i3p49HPxE7nfpUp82B2hS6tb3r(xsc2r())Vt2Mg)i9NFmonyn9ZZtpKTI002II95)47F)DrfBpSC0Q0DVppA3H4GIO0KvzbBkO)9Q3F7nlpefx83sUDj8y7rG5(WvKFM(VUnA96WY(gMV62BO997g79DEU)4Xfhx8RPhkIscpU4WEkSoUytw6UJlUHpY)mDK)poU4J)2VECbPlbhxKfUl9(W119nlmomiN8P3hMLt(Ir3EtCuEroDYTI0XKGe2F8pzulYFUmoC9T)NKgZIkcZIcU9M7di)dYppkVWFFCqssuYDhx4qG9HKOv(7tFimB06WnrRIkoUy(XfUxXAEWXfRstJxN(qYOG9PRcIFCFE4iccgeLKFCXtpDCXfhxueehMumkiB3J(PB8l2g6Voyxs46rvyddyCiToi7t(fzbj5BsZ2XOcnGCyjuxMMNZ(Qnr3TTWN381eCZ92Bcwr)kYcXdKbLmz83rOi3wqwtqPbANiLZvkuVp0pmjCxui5xNp74cpwJQTCnPLP6PGJpU4TGq9nhxCfBEs(A(ctW615vZYscqlCX0aEjzahQHYmP7ChKLwI0t8YOK1Ji8GR9x(OF4VhSBpPVIRSVoSjL0IWrfr7c9ls9VKrgwEyZMrL0OvPzzh2l)Dg4TgimJ)u49KF2pn9pcJjuKgKKSa69bjIDWYucTMHI(Xr7wsP3x2D6TTe71PfJoW005VmMnhO)cFEq5(CvP6s9)ui46NTtpJzlkHUA2gYwt3eMtHiHJ(H0dKVkVGO6Vug9YAUvk)ab3VJip1GJ5(BYct(JhBGlLYyzxDmWABGSCLzYIKK)jWtRhb(EZiG66IjP5kLBppc1M09pvqd3wcdqCiBipK8qAwX2hPt5pyEkRsZzCzbfB9dsw7VoCvWJKvGvFIrrymlbrR9dVNnrjFAdgtTd4EPSIxe06hqrlUGW(d5fhiFAy9sSehlVB3NsDDG0V80ygojsPVOIDrTt(BpSlijnA9Od7V9MOeYythf)OnciG6hj1XD7cxhr9h6gbdWBIdZ3Y8EsSV3fNUmiM2rQPNBYcwffeBWhfm7AEJBXvMFy3ocp(Dbz3L(ySaRjHd5UvRhTl43v5pv)ejk7(WIr8wkn8YffzaT0ja9kIOCNY6dYwfKqLIZYOKsToNmOAvBzCA6A)nhYEC06dzmXJsvCsOOOBlG4ELG0aRPaMjTKvIRgxB3Dq54Ye6VBlH7rKQP0IKSc(KSEDGQXbbMnT0byI7thQeVj1qAgZMv)Mg178fFLN4CFygfb(sELhAsEUR8yW85CLV9ykSYZBuVBGmiv5wwEbrhXDfBjkNRjZnRFLkC2j74gdpBuhv2QOIWcYcjH2v7jX6OqHpsDyn9HcQ1yoqM7)VpS(UDv61WD(Ba1K9xu8X0PZPZXw)1pp8MIEhfKSIWyKfe7tCGlwVVOiyt1caZH0glYgI8DwfvULDW9hIZd17sATUWnrzHm9NFbRkeAoE68vAb5ZdZgYqk4AyDB6Dkxf7MX8JQK(IQI0qyctLyaxgChl0KmYSlV0J07idh5pH8iT(RkPnRsJIltTxw0(Yg(RvFRWC4cHm5SNWfrDouq8OE6W9NCIg)o56OZpqZSij0(0DKfBsZkCPqXMDDzSzgDwDodhQwLbcZASE3vVqdRJJUuPrho5esCxgdV4cIdfym)ucZQ2ggQhU2V0Yuf0w94Qy(aiQ37r)1jRHC6QUlmW5NVpKa0mW4d3NUVKELFIsqeOYqVkmMYLb4laxsHViryYJ(uioRvnAbdFMDyi(3MXKX9t0whCiUGZ9x)j7iXasZas4Fek)nLSc1DJAwj5oA(Rv7gUBU7lkLcIswLwMwYG7iIhtkvQowJbLYmB2OVfuGPp1W3iGLq8bIHM5BdJJf0QkADtUt6D5JGM2qig0egpPtKW2j8P8KRqtn4dKfQ0hA0eAvpDmNxNPcjw9lILcvptt3tyFdlOj9O(RQLUO)BXhcH9gAshqAxRi1TsqRq)aZCMHH0kspB26xUvz028j0Id7HCo0aHQgim)riu9svE2Txl2AJI6KXLvRk(HuNhVXJVivAHs1vslXAHqMO5IC1NKndCbEgH0frMdqaznHZHhR27zTFjBFf4zVAi7)sz9CLjbMZg(ag763Xr2OKnHRkiMpxfh8qUGLwoX0mmDH8HRIARruYIuj3Kt2gwjBen4(GZbaWQAjGSy6XaM(bSlqIpPRCYjipNAWvsgOkVMYEdv3rrMkJs1SEbNoFlqAgRNopbfeCeCabiJ2M5hQMh3ttX8Q0KcIYAXSCls5u6Jionr1ef7xVACn1cIuiplA5HoD6qMQDD(OAQ46z1yxPjC19ni83PBCFjTwTn6wrmVmdbdfXwXjbflvJxP7yzZwM1DSSUnhnBkY8Yn4wYorZgUWMeQHwWnHlUnse)xuc96JzrPe10r)brB8pr667oU4FDOyjj6icNmX5NJl(hKrOG8)yC)Fmo4UdHlPm9YA4R4dbDzcDNT1U1vnb1zNZydv1XzgxmRPWg1oT36oRu9ya9mLSGjxYw2vJpipCLwNfeIzliQOlEyWnK6y3kcd9WDChiI2RBClSHmfUpAnP9va2PWCPWgSZYokkbYjaeVkChzHpPQ7D2RFqivgUkdKnlL7nvRFhComemuy6YmE6Q1QP81Ab0ej7l4fUAXj2YgE(RTE6Q4XiqLpmWg3a1xriIkR3LMTmADuHsXNCHUouzAaV0WA7Lgx1RN8wqlv0pmIOAet19mTYmQSvY2Be08YQp6(OSdu8Ns)iMyLsg)Rp)3amKCtwy(w6CxktK5h2hMrtQvuIQXFky2KLsyu2q80jZxSRTahTZLB7B5aI37HcyAldXQLOLaMArrCj3fPKemTowZb6N6VPo5WVvSR7fDMsQZET7C4ssCkmsgqphY4rHsGPl(2e86ZvzQJWrY6yIa6yKpKnvK)AafNy53MswXR9iXWLeYienhVrROFAdyP7JOF5F4tla5YYqgmBsEQHszfmQjWSGl9W2xgTGGG1jFIYprHawqgAHqDTkrbaE6SVGYouw61Jsstc7obRPYTPJeUNNGUKaoCKWzrhTGu2wV6zVRpm3B784uVVASTzyFwiraCzq7nAGWINxhGxd2aSLt4XfYbovsJLAWYn2RHpuB1MzmPi8W4TtrIKBbAJuSQK26u0FIj5MR8bIEjPV0oy781OCTf9gQHHu7UFPkCXtuOIlw7xv4pzA9wy3U9AxWMEsoAzYa2ePziTOqjozgSV0gI2yJThhSMw7OKHV5TpHdYzdL4TlrNs6Mn(edIIBikgspz8XpRQQedDoy9JcEnwgifGSALxn1to0(XhD6WEA1XYKXcFDNlzLjYRM7tz)tGTI6esBN580FzNyhfsLqBsj0grv39UVZ(wG)xxNucdHPEodG5Deb2dECh4Rk(LYD0ItoLYmJQBQWo02fR4vlZM5hoX5BHGlNa(Bu7B89HX1SvBIiU47hqI6VGoxQNIA6dGzEZ58VcRgv4okkFu2HLp6)W2W49LBnEvqLs95HTrekmJ6eLSkiljOi0pAvf0L9V231p83xfFyDiKDVoGDEwGDEDg78eXovdxDa7ChTni3NAwHY(Wv8RT9x6ghwZ4Yf1BVgbUas)8CiJKDGa5zGab1(lDJ4eipDeiVgc0jwBenK68htKkxqGLk2GvBCxyXUXVCEfV8ne1Atz(qo(iFt8RQoGXJMYxLCHmm1rC3ZmU7HG7ENnUJuVb2I77l3SWhXS5cr87WSJYLvpdnZI14UHSGCdeut7lcgyKe)EPoq)wFHQLILgUb0TeAklLD6eBEJC2YL5jQZK38wyfit77L6G1yfG2oeSYvaRK5RC5CvE6CYOcqKENhNwi(3kXv0bbz7IsaOVQHxIT)dQDRYdBcx3Ewn)WdUqABibCwx2zyKArtBqhd1gkrvRwqkqlSqRcK6hSCUoW00L2j1W2Rk73HwrmCWKEK0i0Q9ATw1jjqX2gNiif)2fA0mnSH4JkasNys7QelRXyjXTcoEkskEDssPTATVkP8vjLLq(VAJKIxlwCZskawGvLuAzafwsbBVkofBkMCrbXbaR1hu1oUaPmdUogqBLcTdAgbLtNLNBNO9ZD64yBQYfgDReh94LVOU0oQ)QrOqtL1DkkT1YMGhQI1cCySIUFLvSJ4WNHSIfIBOR29IBWxZf)Nd5I3WYkRBq5RhtJJCfCBApTT5k2OPC8Ae(kpUFYBrjCQPTF75MxU331te1nAs7UHPCNHCpqvCjSlID6MuQwGuyL9wOTux7EOWriGIFZMTcrH8BOEeFd3ZmJB(4zSN4wUPmaebGlciTSwUshAdStwJtDykCyHDAgOZ4ouI91NraUR7R1FozjyS0XKvLeJDqm4Q20vJ)t5qdBgmuD80CuKmSwQMlqUeut5q0L9fQS6ouL7Lo(gmi0V7PTKCGjt2v7pkKMmSuyDwedDYexO)8E3mNu6KOfC1d)Uoaw2xEwIblvq1StyNkoSI42QG97QlJTVh0myC)CqaexgBJdADx5ugpD9YuS)LCcwXGQZZepH9uoChRKrOhVRq)hcje1eWG0TWCGgS384HxBwIIcoyNxnD(i06G0u3z5QCYKqbIKL9fJ4FcRJPwN(dO(jvZj6Nz4(YImNhuwO4cdxdY)26RUeW1LoFb(40qy1eEI1wKUYyGFTkf58acssV(acI93t(XY4cPvJQ2icnyVzGERvvQLS(qAlf7GQkqqOW9pYG)xTUNsen9P9R(GkES8qwEbRqIsZcZr0eJ5pxhDZus1QRR((04jOTo8AgFTiVXogDQ0PXnoav0YhuaLQdTY4uL9jOtf9r5lEc(DodUsFUXs4I8VQzOdortR4hHa2SOdNrG8vPhiSB1LLM2WJhydFiJfR2Uw9(wzK1vVP)khaRzY5Y8AUILG0eEfh7AFNMCDRcru8mNDIxypg0DzS47uZXHOzowQNC0fMQzxQUUXeL2fiedrywqppQIrvhsHCAsbcmMRAbTdUnPANX8DxIhmoGvQOAkYXoCftHx)L2ia1qyvpiZcbORTKnTE8Gf4q3ZzuQJ5ypN3CCaSQZtRwFnAJw5gidS8qjmtvpBd8NrIX0tZEg1)BYh9BBjAmJiMNYikJiw4oU4BRUDU(wIgRW)Vdrzu(580DK(fCOiLycK(dR2gquYNp64V83zpVet(XJl(50eYyXA(BHdnJaZIu0wRxRj9AG7VpKd7lFgH9uyy3OYtbST3aAlHyVGTFpmSL9arb0WUNyjKf8(ubSa(LAaMPehpy(pLtV9Xiq6cGKH4GdENwooFyVZamVP)Mbx(MkVogoC(m3A0)zDqFV6GYPfFO35ZEXGOSXjfOcFSMSeY9ImXpadBzlZkGg2STkKD9GbnyscugbTzI9ZUbQhwIFfaD)tEqS0u7HGcSv9rPf4UQ3frXaj)ACqbITUEhE(biILeH4oBjN3kIuBbQ0LnamVL8DvWRoGFwidsXDRawWq2TfWnzdqL1VvAcmbYww)BNEY5AUzpCgCHnjO9PNSPxoAYG78PdDgy4274PNWxZk)ylUZoE6jBVVogsWOl0X8XXhWwBMTG3nhZDN(ndgGpHEZKHVDGoMP3410H28fKwhoSH75RR5FMSM)(N918gvbiU)D(QTq9R8KuYE8xaIgU6(44B7u0WioS0l(7(keP9zff4Rq8WNjSb5dQUzr6f(aPREEyVlKVw6nGB87YLUHDUiUN2A77vqr8933eVk2dmy9ay6bi0e8FbNbkpAGTMbipQGMK46BkeIe9z7FRQuDFtxuHV2NlX6bXQ3uXxVrcrBvpYTQMle0x2Vwllyp9FwpcQpDFTgbSxnqd62csd7fTANLnSxqykVxykGfEJYSeY9rgXEPHCpKzBuFXojFe1cZZiCzeiE2UiJyHSh4YE(GmInREaYi(I2d8VirI05mhcQdS6Cj1r37AXsvDmOaVrw4iyZzLcUx65Afhc0Rmf4Xsx31Z4vbgW7YLwJfwVSFiSFEzS76z75etX7GaaINsZDaOSeNKx9WMHaz1(0ZG)mq8DbuJSpQdVB6s)c8ZaRjTLtDesm36ayUC36)b5mMbBPKgD4EDh6taFg4lTyn0HUvT3JGfdzBz)HRxrRiERM7aq1ldc3NEg8NbIJjfc2L(f4NbwRt6dTB9)GCgZayjrGo0Na(mWxqzX2T3JGfdzBTFQCfhnf)v1T5aGYdO(8ScEma3A76WoK8od0b)V5BUC6SX89)5ebsjm4OAR8OWx4mtdG7JejUVbpgGntI9ArDaGVjsSDarHe3kCgjzJ6phr0qOz9XiX5D1c0wnBfqp1vRNzWBbG3NLUQSQQ3NRd4y9Zs832HHY943DWBRZbA9948bpMAACErZRRwOMUVbVfa2U1t8(zj(B7WCsSn2h24jX2yp4TKTPDjTIAHZk9YIk6CAdl(D32tpDbI6XHp9e(iP3eaMm)W3mWD003IiyrAfyaP3fIdhoFGE76ySlQJORXr0TAeRxo)t86W7FXxhE)ZW6axIbP8CpZTOxlSvVYIuao2nAKTq)0REZxdArpITvSbTV03055ttxEgbUfG9m8BfdO2Bm0kBUN)WO1MR74NrUpmG3tIIOG)05UFDih9j(YzpmkXa2LNtOBdCpJy(qHQ9r1yLezpmo6fjBTR3NLwWNxOBdCpdLSTHAFkpAtPUDgQN(kU3nG3x4o((pBKd3cDI9l0TbUNJoXNZAogd4pBRJFf3FEXDwrMSjnoo9b2vGqaXcv(XfpeMr(DsaERlZNrbTBLhb(JlOpZI0l6JI6(LKYQqLdjs9E9AANxhueSmip8hp(lhx8Dhxq3jf0QxUKJUJL3YZPElKdfxVFGdFPgNx8ZnEpurvpF4msTA17u9xNqm6VQj(R4)jG)NjWHp7jb1pQS9IkYENr)L68z)kpo9Wrz)fhY9oTbP4C79X558yJ9sz29LACWoyjNE2M6Fi2N5N(4V83y6hPa6hKDqLQ872Bi6e3MMD7n3eT7qml1l)CwWg2tcE6MOy(1wE(i(Z49BN9(MRW8J)cu7QUv)o53a8zEumR6djDFxuYA6jck8pcf)z6jli5okAfs7)F5VqTLmA8OV)4Ip(B)QypdsiGL4J0QYIu(DrBMTViZjkzf9ihDNFzBtYNp2b4ULB(LJDgaCz3q3ZkqPLNEIhZQQCu9XgM3bfuJNbSHLtiO5WFKMewpfGq3VFC91Wdrtx0UOY1TUnfgkrrNAGyEbg18L8CN)NOvog961M20RSj)pv7FzUiNs9MA(o6Z54SgFVEx6(zSN)X3XEo)MjFvpoF2elwgC1oLDBW4MwDmdu0jk(0IcFQwlcNV68YD87AE(cN59osKARJOqzMgC)A3Xo6UscVE2L4iJWPLJEvRU6tHzQiLoypFMRigRVRdM8Dv0k5GfhkmpT8ocRB3nyQxiz4KJM3k7Qj)aDmnn3qKnlPq8rdDA2UEac(tpzGe70gKM)goIR4eBnxJhxAwUdoim0oqxJ4gqJlh(0tsxHUeEvDe)wxvKvRcvyKC2lAMHWxBOxprul21xnwOCseFEaqXhHobQ356zti6KHVCLF6P2pGhZDNouJAHMBzueTCx2HrR83DqU6MNFvLnN)3THj0SoYYe53g(7K1WKG4YILHGX3N(PWV9Dhx8qe9P5(qEintJr5u)9sOxXUXPeJuLopUoKXwt938bgqP)i7l(y5Dm6FlzZb6LH5ivRDLdJV0GxZqqV5MJQ(qQDqOfqqdq6u2JQZMBEtXBthW3UbhW3TbCGFbg0zcqWx214qt)hPLIGym7TtBCvbAnPXFfvH6zEevQK10pw(Smgr86EXprMLeoN)1HILzHbFISGtZv9)G0)cY)JXV9rXtrRKdJQE7tw51fCMtJwAnxK9xpXoxJg2q0Hhny1MM036oUbUiACbhocsNMN7OqXNizt)HGOI3LhUsNBcuIOoViigiDSH8ioUR5xiWuOpOL6XMzC9XUDiS0QndSfDQw9gzU8g3rA94JoFF6PxsxQRSuwsZYszUS063eWojBf10pkDgWUWldn9li6P0nTclclRqPbWgGga5GMg0FyToe(D6yJKc)NeRJvbNduv(Y0o45kn7sR06(oPlMAIV6mfPFrDrW9sEbWbFXVz(cFd8s(d9IEd(cEJDXUjPZx8ArNP(9fCLQRrf5anrDawnzih4JzbveUo5b)Ca1F0FIrloU4VZEnteinemk2V8p9PzMSv6eidw0QIs5HMGcA6GzGX35CZDTQksSONvx4DM7i)whtEMu)ZJsstKsabjoO2ajinu6ZBzwXieQUy20afIpa1Rz)u6)L8swtMEjyYSQ3Yc28yn8ZEGG2xb9HodSj9ac(aEr7(tv9O7s)F(mPl8FAuVA79hAgf5BhfUREYHS2143UEMRlASDtjMHneACd6j3(qDHvulUkN8MQSUa)m7uPSrXJyIl2a5fyOe)anB9sVtncXaiQVOLEsynnMuRipYIoBnaEHKSIrMPx7YnjOSoRlTiZgpuiveaz9WzGQS4vSXtnJSxpPnvt9LybYfaCbmT5r8se1(bRFuOf53Kg9ji6AphqYxppRminqLyqKhuXdzoziSaufL(0Z6PokYM2bgeKzQkCKdptplNAGA6Kj0cPopzAIDh(LzzonYzJDAQtx0GxBu6JSNY6guMBwNG4LpZ1mDatgpFg07tUdqCxdPrbbN0gl2LIRgRTterTHvACrustrv025cLAsOvZVYn2mzC1xOMSl1uGj8fdrYBX4kp4A5)KeTxwmeIRrvdPNwHmAqYyQOUEcmoOq9HguKVu9D7K(PmZfEoqQhGbsZwIxUbGHYp)3WFeWIoEAt1MKldH6)gpTb4oFYydzrB4PnbKC8dDf1DmMZkMSfyTNy005pEOELoxR41iMtxd04khsg)fssPYMPHWsYxIGTNOr0zItlF6Rubzmutdj2SrPoUUQ5s(40Btjygkuximz(XHjEpPoWG2aG2(mSzcGZZDBZo64oru9ZTlNZNXn6Oe(ASCzgEDylqgAyJjN4azCYZ90wFe5H0GuD0yXeWDCfgiDWVuJWs45jUTnVzUoGplYxpv93PjwCQ1PpuRTeeXgre1CIo54zBphaW8bipuZVDkgYO8Chd7JYf6CDZk1Hxb6xLyUXQsc0Xf)0s6vuwuOKpwvjoIIXpeKvw(v0e6GPVbQqGCVYrxDriuceT1ayZKe23rxxlNhAqT2rw71Y62u45843Q8TV5QHGMrE6jLXagGxkBnOz(aPqaCP5cSBK(N5vhMXmU0YLZz80LtXvPz13I58HdyPCa2Ds)B8(W5svWjkurAPu07Vovin9UT2Fw187RJO0xyTcbrFkzOH1CH2le)Y8uH2So38pLPKOLWUWLGizVLmhPQ1jmOhsEinRy7J4ogPZeI4MVFQS9WkLMEIOUKFNiEn2oyeURkUxIS8SjomF7kAjxtho0hzGNEc91bOYiL6p7V9aXeEA0AIPQ3fLqygPGYpA3UW1rbfHuJU8F9U40LbXs)Ki2Oc7ABx)vIH4JlUrAlye2wgzN(n7KVLrPyZQ)CVoeqRmgduml6d9(l5QzbJk9zTtNYyQsAHO3jtPB24tCbR0Vtl560VQi4XGSNcs4YxtrzT(WtkfLiuvKCqPD9YGvAdl3iiIv76HqU4RRDz973WL84)fkwLUdgOQsgJGkTpeSGBfkcB5(AC7c0xWXMRlAiSMv9I)1YDZwaVk)Hwtad7DxDQGapwemCl)W61HjeVpt3rfywvOvvKP67NOQstvwlmlSAl2BfFKArVu(8OziZNT2UL2yJXfAaoYwHwXs7VH9cRzipv5j9SeLUU8Rk1UXOQI5ywq2QGeQXPmIh3fvcaTIg0BSGzFenVLLyhII76JQhiFNt1UpOxGEylKNmpllyQnhYESX2wZVXRj4xoJpvvqQ9MgWq5UAWahowZuISPyyqgC9imlpmJcmH1d(V9NN1J2O8PTEabN(z9OnKHwpyPii3)FFy9D7QKVzFEL2Y6l7wwXJwtMfQ8OklcqLQuBxBLlNgoOX)aqj6GKvH0QNj2NwCzmUi3PFgZV4oTRCg0V4C5bedSxG2vQmF)H4CWneMyTKz)NRxhjBIZUAm4AZMOSqMIGgHB(p9Ngz72yCxxarbZ5UQIayqfTb3XCrNyU)t5GXKoarqhCONYp5R)MA9GwFf(MpJglzur4U6cw9(W46WeiiDEHFq2ss7zT)03QECYQAW3T(ctU(O0LvFJNb8yCr81tSz03pRom(EiJp4JbwZ4R)97QdJF1LpDRzV41PmrkrUHsV0Rwrfjk8gREaBaB7(MNhgW23s)wWwOxvxdbU1R5lIDyI7boX9WM4a3R)IRg4tC43fhW2vM4EMN4ENWeV8IWU1rRw8CkpE0uHZCma5Mr6Ce4kAsjx9nOE572rhWlVZgVADFPJ)MK0b8AF5P27rvmZteZCfpJ2OemBW4t4cE)uUF31Dn7JChYQCNRdiry5n9UUlCFKRuALXgqnKU78DWvBUXe5muMhNwuV2lhNDl2FmFhepWtkz3wmtgQxfIvMcjlW7zfSKGdg4fxst(qmuVhGoQmu4idjpfaZoJrxI(bnym4HaRLdlAlXEXlkaabIwTvl6oZvuRkFwWZL6fWIF0YW3aF58zsUXCQmAEGmAEFLr7ZignxBy08e5y0WO5IYOHO8TNy0uYHxlvANGuIyYXv4CnxZATzBX(cKpWPdS5I7rPTiKv79ndYg5z9g7aDXdyEJZ72sSh8sClxn6a)j0sS7xxIp7L4Bli)NB)))d]] )