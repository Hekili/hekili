-- DeathKnightUnholy.lua
-- October 2022

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local roundUp = ns.roundUp
local FindUnitBuffByID = ns.FindUnitBuffByID
local PTR = ns.PTR

local spec = Hekili:NewSpecialization( 252 )

spec:RegisterResource( Enum.PowerType.Runes, {
    rune_regen = {
        last = function ()
            return state.query_time
        end,

        interval = function( time, val )
            local r = state.runes

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
spec:RegisterResource( Enum.PowerType.RunicPower )

-- Talents
spec:RegisterTalents( {
    abomination_limb          = { 76049, 383269, 1 }, -- Sprout an additional limb, dealing 6,258 Shadow damage over 12 sec to all nearby enemies. Deals reduced damage beyond 5 targets. Every 1 sec, an enemy is pulled to your location if they are further than 8 yds from you. The same enemy can only be pulled once every 4 sec. Gain Runic Corruption instantly, and again every 6 sec.
    acclimation               = { 76047, 373926, 1 }, -- Icebound Fortitude's cooldown is reduced by 60 sec.
    all_will_serve            = { 76181, 194916, 1 }, -- Your Raise Dead spell summons an additional skeletal minion.
    antimagic_barrier         = { 76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by 20 sec and increases its duration and amount absorbed by 40%.
    antimagic_shell           = { 76070, 48707 , 1 }, -- Surrounds you in an Anti-Magic Shell for 5 sec, absorbing up to 10,902 magic damage and preventing application of harmful magical effects. Damage absorbed generates Runic Power.
    antimagic_zone            = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 47,400 damage.
    apocalypse                = { 76185, 275699, 1 }, -- Bring doom upon the enemy, dealing 847 Shadow damage and bursting up to 4 Festering Wounds on the target. Summons an Army of the Dead ghoul for 15 sec for each burst Festering Wound. Generates 2 Runes.
    army_of_the_damned        = { 76153, 276837, 1 }, -- Apocalypse's cooldown is reduced by 45 sec. Additionally, Death Coil reduces the cooldown of Army of the Dead by 5 sec.
    army_of_the_dead          = { 76196, 42650 , 1 }, -- Summons a legion of ghouls who swarms your enemies, fighting anything they can for 30 sec.
    asphyxiate                = { 76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation              = { 76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and grants up to 100 Runic Power based on the amount absorbed.
    blinding_sleet            = { 76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_draw                = { 76079, 374598, 2 }, -- When you fall below 30% health you drain 1,471 health from nearby enemies. Can only occur every 3 min.
    blood_scent               = { 76066, 374030, 1 }, -- Increases Leech by 3%.
    brittle                   = { 76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    bursting_sores            = { 76164, 207264, 1 }, -- Bursting a Festering Wound deals 20% more damage, and deals 305 Shadow damage to all nearby enemies. Deals reduced damage beyond 8 targets.
    chains_of_ice             = { 76081, 45524 , 1 }, -- Shackles the target with frozen chains, reducing movement speed by 70% for 8 sec.
    clawing_shadows           = { 76183, 207311, 1 }, -- Deals 947 Shadow damage and causes 1 Festering Wound to burst.
    cleaving_strikes          = { 76073, 316916, 1 }, -- Scourge Strike hits up to 7 additional enemies while you remain in Death and Decay.
    clenching_grasp           = { 76062, 389679, 1 }, -- Death Grip slows enemy movement speed by 50% for 6 sec.
    coil_of_devastation       = { 76156, 390270, 1 }, -- Death Coil causes the target to take an additional 30% of the direct damage dealt over 4 sec.
    coldthirst                = { 76045, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants 10 Runic Power and reduces its cooldown by 3 sec.
    commander_of_the_dead     = { 76149, 390259, 1 }, -- Dark Transformation also empowers your Gargoyle and Army of the Dead for 30 sec, increasing their damage by 35%.
    control_undead            = { 76059, 111673, 1 }, -- Dominates the target undead creature up to level 61, forcing it to do your bidding for 5 min.
    dark_transformation       = { 76187, 63560 , 1 }, -- Your ghoul deals 758 Shadow damage to 5 nearby enemies and transforms into a powerful undead monstrosity for 15 sec. Granting them 100% energy and the ghoul's abilities are empowered and take on new functions while the transformation is active.
    death_pact                = { 76077, 48743 , 1 }, -- Create a death pact that heals you for 50% of your maximum health, but absorbs incoming healing equal to 30% of your max health for 15 sec.
    death_rot                 = { 76158, 377537, 1 }, -- Death Coil and Epidemic debilitate your enemy applying Death Rot causing them to take 1% increased Shadow damage, up to 10% for 10 sec. If Death Coil or Epidemic consume Sudden Doom it applies two stacks of Death Rot.
    death_strike              = { 76071, 49998 , 1 }, -- Focuses dark power into a strike that deals 569 Physical damage and heals you for 40.00% of all damage taken in the last 5 sec, minimum 11.2% of maximum health.
    deaths_echo               = { 76056, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have 1 additional charge.
    deaths_reach              = { 76057, 276079, 1 }, -- Increases the range of Death Grip by 10 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    defile                    = { 76180, 152280, 1 }, -- Defile the targeted ground, dealing 932 Shadow damage to all enemies over 10 sec. While you remain within your Defile, your Scourge Strike will hit 7 enemies near the target. If any enemies are standing in the Defile, it grows in size and deals increasing damage every sec.
    ebon_fever                = { 76164, 207269, 1 }, -- Virulent Plague deals 15% more damage over time in half the duration.
    empower_rune_weapon       = { 76050, 47568 , 1 }, -- Empower your rune weapon, gaining 15% Haste and generating 1 Rune and 5 Runic Power instantly and every 5 sec for 20 sec.
    enfeeble                  = { 76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by 30% and the damage they deal to you by 15% for 6 sec.
    epidemic                  = { 76161, 207317, 1 }, -- Causes each of your Virulent Plagues to flare up, dealing 386 Shadow damage to the infected enemy, and an additional 154 Shadow damage to all other enemies near them. Increases the duration of Dark Transformation by 1 sec.
    eternal_agony             = { 76195, 390268, 1 }, -- Death Coil and Epidemic increase the duration of Dark Transformation by 1 sec.
    feasting_strikes          = { 76193, 390161, 1 }, -- Festering Strike has a 15% chance to generate 1 Rune.
    festering_strike          = { 76189, 85948 , 1 }, -- Strikes for 1,707 Physical damage and infects the target with 2-3 Festering Wounds.  Festering Wound A pustulent lesion that will burst on death or when damaged by Scourge Strike, dealing 421 Shadow damage and generating 5 Runic Power.
    festermight               = { 76152, 377590, 2 }, -- Popping a Festering Wound increases your Strength by 1% for 20 sec stacking. Does not refresh duration.
    ghoulish_frenzy           = { 76154, 377587, 2 }, -- Dark Transformation also increases the attack speed and damage of you and your Monstrosity by 0%.
    gloom_ward                = { 76052, 391571, 1 }, -- Absorbs are 15% more effective on you.
    grip_of_the_dead          = { 76057, 273952, 1 }, -- Death and Decay reduces the movement speed of enemies within its area by 90%, decaying by 10% every sec.
    harbinger_of_doom         = { 76175, 276023, 1 }, -- Sudden Doom triggers 30% more often and can accumulate up to 2 charges.
    icebound_fortitude        = { 76084, 48792 , 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 30% for 8 sec.
    icy_talons                = { 76051, 194878, 2 }, -- Your Runic Power spending abilities increase your melee attack speed by 3% for 6 sec, stacking up to 3 times.
    improved_death_coil       = { 76184, 377580, 2 }, -- Death Coil deals 15% additional damage and seeks out 1 additional nearby enemy.
    improved_death_strike     = { 76067, 374277, 1 }, -- Death Strike's cost is reduced by 10, and its healing is increased by 60%.
    improved_festering_strike = { 76192, 316867, 2 }, -- Festering Strike and Festering Wound damage increased by 10%.
    infected_claws            = { 76182, 207272, 1 }, -- Your ghoul's Claw attack has a 30% chance to cause a Festering Wound on the target.
    insidious_chill           = { 76088, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by 5% for 30 sec, stacking up to 4 times.
    magus_of_the_dead         = { 76148, 390196, 1 }, -- Apocalypse and Army of the Dead also summon a Magus of the Dead who hurls Frostbolts and Shadow Bolts at your foes.
    march_of_darkness         = { 76069, 391546, 1 }, -- Death's Advance grants an additional 25% movement speed over the first 3 sec.
    merciless_strikes         = { 76085, 373923, 1 }, -- Increases Critical Strike chance by 2%.
    might_of_thassarian       = { 76076, 374111, 1 }, -- Increases Strength by 2%.
    mind_freeze               = { 76082, 47528 , 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    morbidity                 = { 76197, 377592, 2 }, -- Diseased enemies take 1% increased damage from you per disease they are affected by.
    outbreak                  = { 76191, 77575 , 1 }, -- Deals 169 Shadow damage to the target and infects all nearby enemies with Virulent Plague.  Virulent Plague A disease that deals 1,906 Shadow damage over 27 sec. It erupts when the infected target dies, dealing 406 Shadow damage to nearby enemies.
    permafrost                = { 76083, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to 40% of the damage dealt.
    pestilence                = { 76157, 277234, 1 }, -- Death and Decay damage has a 10% chance to apply a Festering Wound to the enemy.
    pestilent_pustules        = { 76160, 194917, 1 }, -- Bursting a Festering Wound has a 10% chance to grant you Runic Corruption.
    plaguebringer             = { 76183, 390175, 1 }, -- Scourge Strike causes your disease damage to occur 100% more quickly for 5 sec.
    proliferating_chill       = { 76086, 373930, 1 }, -- Chains of Ice affects 1 additional nearby enemy.
    raise_dead                = { 76188, 46584 , 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time.
    raise_dead                = { 76072, 46585 , 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts 1 min.
    reaping                   = { 76177, 377514, 1 }, -- Your Soul Reaper, Scourge Strike, Festering Strike, and Death Coil deal 20% addtional damage to enemies below 35% health.
    replenishing_wounds       = { 76163, 377585, 1 }, -- When a Festering Wound pops it generates an additional 2 Runic Power.
    rotten_touch              = { 76178, 390275, 1 }, -- Sudden Doom causes your next Death Coil to also increase your Scourge Strike damage against the target by 50% for 6 sec.
    rune_mastery              = { 76080, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by 3% for 8 sec.
    runic_attenuation         = { 76087, 207104, 1 }, -- Auto attacks have a chance to generate 5 Runic Power.
    runic_mastery             = { 76186, 390166, 2 }, -- Increases your maximum Runic Power by 10.
    ruptured_viscera          = { 76148, 390236, 1 }, -- When your ghouls expire, they explode in viscera dealing 188 Shadow damage to nearby enemies.
    sacrificial_pact          = { 76074, 327574, 1 }, -- Sacrifice your ghoul to deal 1,271 Shadow damage to all nearby enemies and heal for 25% of your maximum health. Deals reduced damage beyond 8 targets.
    scourge_strike            = { 76190, 55090 , 1 }, -- An unholy strike that deals 467 Physical damage and 355 Shadow damage, and causes 1 Festering Wound to burst.
    soul_reaper               = { 76053, 343294, 1 }, -- Strike an enemy for 576 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 2,783 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    sudden_doom               = { 76179, 49530 , 1 }, -- Your auto attacks have a chance to make your next Death Coil cost no Runic Power.
    summon_gargoyle           = { 76176, 49206 , 1 }, -- Summon a Gargoyle into the area to bombard the target for 25 sec. The Gargoyle gains 1% increased damage for every 1 Runic Power you spend. Generates 50 Runic Power.
    superstrain               = { 76155, 390283, 1 }, -- Your Virulent Plague also applies Frost Fever and Blood Plague at 80% effectiveness.
    suppression               = { 76075, 374049, 1 }, -- Increases Avoidance by 3%.
    unholy_assault            = { 76151, 207289, 1 }, -- Strike your target dealing 1,647 Shadow damage, infecting the target with 4 Festering Wounds and sending you into an Unholy Frenzy increasing haste by 20% for 20 sec.
    unholy_aura               = { 76150, 377440, 2 }, -- All enemies within 8 yards take 10% increased damage from your minions.
    unholy_blight             = { 76162, 115989, 1 }, -- Surrounds yourself with a vile swarm of insects for 6 sec, stinging all nearby enemies and infecting them with Virulent Plague and an unholy disease that deals 539 damage over 14 sec, stacking up to 4 times.
    unholy_bond               = { 76055, 374261, 2 }, -- Increases the effectiveness of your Runeforge effects by 10%.
    unholy_command            = { 76194, 316941, 2 }, -- The cooldown of Dark Transformation is reduced by 8 sec.
    unholy_endurance          = { 76063, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground             = { 76058, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    unholy_pact               = { 76180, 319230, 1 }, -- Dark Transformation creates an unholy pact between you and your pet, igniting flaming chains that deal 3,804 Shadow damage over 15 sec to enemies between you and your pet.
    veteran_of_the_third_war  = { 76068, 48263 , 2 }, -- Stamina increased by 10%.
    vile_contagion            = { 76159, 390279, 1 }, -- Inflict disease upon your enemies spreading Festering Wounds equal to the amount currently active on your target to 7 nearby enemies.
    will_of_the_necropolis    = { 76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk               = { 76078, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
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
spec:RegisterAuras( {
    -- Talent: Pulling enemies to your location and dealing $323798s1 Shadow damage to nearby enemies every $t1 sec.
    -- https://wowhead.com/beta/spell=383269
    abomination_limb = {
        id = 383269,
        duration = 12,
        tick_time = 1,
        max_stack = 1,
        copy = 315443
    },
    -- Recently pulled  by Abomination Limb and can't be pulled again.
    -- https://wowhead.com/beta/spell=323710
    abomination_limb_immune = {
        id = 323710,
        duration = 4,
        type = "Magic",
        max_stack = 1,
        copy = 383312
    },
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
        max_stack = 1
    },
    -- Movement speed slowed by $s2%.
    -- https://wowhead.com/beta/spell=279303
    frostwyrms_fury = {
        id = 279303,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Damage and attack speed increased by $s1%.
    -- https://wowhead.com/beta/spell=377588
    ghoulish_frenzy = {
        id = 377588,
        duration = 15,
        max_stack = 1
    },
    -- Damage and attack speed increased by $s1%.
    -- https://wowhead.com/beta/spell=377589
    ghoulish_frenzy = {
        id = 377589,
        duration = 15,
        max_stack = 1
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
    -- Movement speed reduced by $s5%.
    -- https://wowhead.com/beta/spell=206930
    heart_strike = {
        id = 206930,
        duration = 8,
        max_stack = 1,
        copy = 228645
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
    -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by $s1% for $d. Taking any action cancels the effect.    While active, your movement speed cannot be reduced below $m2%.
    -- https://wowhead.com/beta/spell=212654
    wraith_walk = {
        id = 212654,
        duration = 0.001,
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


spec:RegisterStateTable( "death_and_decay",
setmetatable( { onReset = function( self ) end },
{ __index = function( t, k )
    if k == "ticking" then
        return buff.death_and_decay.up

    elseif k == "remains" then
        return buff.death_and_decay.remains

    end

    return false
end } ) )

spec:RegisterStateTable( "defile",
setmetatable( { onReset = function( self ) end },
{ __index = function( t, k )
    if k == "ticking" then
        return buff.death_and_decay.up

    elseif k == "remains" then
        return buff.death_and_decay.remains

    end

    return false
end } ) )

spec:RegisterStateExpr( "dnd_ticking", function ()
    return death_and_decay.ticking
end )

spec:RegisterStateExpr( "dnd_remains", function ()
    return death_and_decay.remains
end )


spec:RegisterStateExpr( "spreading_wounds", function ()
    if talent.infected_claws.enabled and buff.dark_transformation.up then return false end -- Ghoul is dumping wounds for us, don't bother.
    return azerite.festermight.enabled and settings.cycle and settings.festermight_cycle and cooldown.death_and_decay.remains < 9 and active_dot.festering_wound < spell_targets.festering_strike
end )


spec:RegisterStateFunction( "time_to_wounds", function( x )
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

spec:RegisterHook( "step", function ( time )
    if Hekili.ActiveDebug then Hekili:Debug( "Rune Regeneration Time: 1=%.2f, 2=%.2f, 3=%.2f, 4=%.2f, 5=%.2f, 6=%.2f\n", runes.time_to_1, runes.time_to_2, runes.time_to_3, runes.time_to_4, runes.time_to_5, runes.time_to_6 ) end
end )

spec:RegisterPet( "ghoul", 26125, "raise_dead", 3600 )
spec:RegisterTotem( "gargoyle", 458967 )
spec:RegisterTotem( "abomination", 298667 )
spec:RegisterPet( "apoc_ghoul", 24207, "apocalypse", 15 )
spec:RegisterPet( "army_ghoul", 24207, "army_of_the_dead", 30 )


local ForceVirulentPlagueRefresh = setfenv( function ()
    StoreMatchingAuras( "target", { count = 1, [191587] = "virulent_plague" }, "HARMFUL", select( 2, UnitAuraSlots( "target", "HARMFUL" ) ) )
    Hekili:ForceUpdate( "VIRULENT_PLAGUE_REFRESH" )
end, state )

local After = C_Timer.After

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID )
    if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" and spellID == 77575 then
        After( state.latency, ForceVirulentPlagueRefresh )
        After( state.latency * 2, ForceVirulentPlagueRefresh )
    end
end, false )


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

spec:RegisterHook( "reset_precast", function ()
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

    rawset( cooldown, "army_of_the_dead", nil )
    rawset( cooldown, "raise_abomination", nil )

    if pvptalent.raise_abomination.enabled then
        cooldown.army_of_the_dead = cooldown.raise_abomination
    else
        cooldown.raise_abomination = cooldown.army_of_the_dead
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
end )

local mt_runeforges = {
    __index = function( t, k )
        return false
    end,
}

-- Not actively supporting this since we just respond to the player precasting AOTD as they see fit.
spec:RegisterStateTable( "death_knight", setmetatable( {
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
spec:RegisterAbilities( {
    -- Talent: Sprout an additional limb, dealing ${$383313s1*13} Shadow damage over $d to a...
    abomination_limb = {
        id = 383269,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = function()
            if covenant.necrolord then return end
            return "abomination_limb"
        end,
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "abomination_limb" )
            if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
        end,
    },

    -- Talent: Surrounds you in an Anti-Magic Shell for $d, absorbing up to $<shield> magic ...
    antimagic_shell = {
        id = 48707,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "antimagic_shell",
        startsCombat = false,

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

            if pvptalent.necromancers_bargain.enabled then applyDebuff( "target", "crypt_fever" ) end
        end,
    },

    -- Talent: Summons a legion of ghouls who swarms your enemies, fighting anything they ca...
    army_of_the_dead = {
        id = function () return pvptalent.raise_abomination.enabled and 288853 or 42650 end,
        cast = 0,
        cooldown = function () return pvptalent.raise_abomination.enabled and 120 or 480 end,
        cast = 0,
        cooldown = 480,
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

        talent = function() return not spec.frost and "chains_of_ice" or nil end,
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

        handler = function ()
            if debuff.festering_wound.up then
                if debuff.festering_wound.stack > 1 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )

                    if set_bonus.tier28_2pc > 0 then
                        if buff.harvest_time.up then
                            applyDebuff( "target", "soul_reaper" )
                            removeBuff( "harvest_time" )
                            summonPet( "army_ghoul", 15 )
                        else
                            addStack( "harvest_time_stack", nil, 1 )
                            if buff.harvest_time_stack.stack == 5 then
                                removeBuff( "harvest_time_stack" )
                                applyBuff( "harvest_time" )
                            end
                        end
                    end
                else removeDebuff( "target", "festering_wound" ) end

                if conduit.convocation_of_the_dead.enabled and cooldown.apocalypse.remains > 0 then
                    reduceCooldown( "apocalypse", conduit.convocation_of_the_dead.mod * 0.1 )
                end

                apply_festermight( 1 )
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

        usable = function () return pet.ghoul.alive end,
        handler = function ()
            applyBuff( "dark_transformation" )
            if azerite.helchains.enabled then applyBuff( "helchains" ) end
            if talent.unholy_pact.enabled then applyBuff( "unholy_pact" ) end

            if legendary.frenzied_monstrosity.enabled then
                applyBuff( "frenzied_monstrosity" )
                applyBuff( "frenzied_monstrosity_pet" )
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
        charges = function()
            if talent.deaths_echo.enabled then return 2 end
        end,
        cooldown = 30,
        recharge = function()
            if talent.deaths_echo.enabled then return 30 end
        end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,

        notalent = "defile",

        handler = function ()
            applyBuff( "death_and_decay" )
            if talent.grip_of_the_dead.enabled then applyDebuff( "target", "grip_of_the_dead" ) end
        end,

        bind = { "defile", "any_dnd" },

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
            end

            removeStack( "sudden_doom" )
            if cooldown.dark_transformation.remains > 0 then setCooldown( "dark_transformation", max( 0, cooldown.dark_transformation.remains - 1 ) ) end
            if legendary.deadliest_coil.enabled and buff.dark_transformation.up then buff.dark_transformation.expires = buff.dark_transformation.expires + 2 end
            if legendary.deaths_certainty.enabled then
                local spell = covenant.night_fae and "deaths_due" or ( talent.defile.enabled and "defile" or "death_and_decay" )
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
        charges = function () return talent.deaths_echo.enabled and 2 or 1 end,
        cooldown = 25,
        recharge = function ()
            if talent.deaths_echo.enabled then return 25 end
        end,
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

    -- Talent: Defile the targeted ground, dealing ${($156000s1*($d+1)/$t3)} Shadow damage t...
    defile = {
        id = 152280,
        cast = 0,
        charges = function ()
            if not talent.deaths_echo.enabled then return end
            return 2
        end,
        cooldown = 20,
        recharge = function ()
            if not talent.deaths_echo.enabled then return end
            return 20
        end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "defile",
        startsCombat = true,

        handler = function ()
            applyBuff( "death_and_decay" )
            setCooldown( "death_and_decay", 20 )

            applyDebuff( "target", "defile", 1 )
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
        charges = function()
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

        usable = function () return active_dot.virulent_plague > 0 end,
        handler = function ()
            removeBuff( "sudden_doom" )
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
        cooldown = function () return level < 29 and 120 or 30 end,
        gcd = "spell",

        talent = "raise_dead",
        startsCombat = false,
        texture = 1100170,

        essential = true, -- new flag, will allow recasting even in precombat APL.
        nomounted = true,

        usable = function () return not pet.alive end,
        handler = function ()
            summonPet( "ghoul", level > 28 and 3600 or 30 )
            if talent.all_will_serve.enabled then summonPet( "skeleton", level > 28 and 3600 or 30 ) end
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

        handler = function ()
            if debuff.festering_wound.stack > 1 then
                applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )

                if set_bonus.tier28_2pc > 0 then
                    if buff.harvest_time.up then
                        applyDebuff( "target", "soul_reaper" )
                        removeBuff( "harvest_time" )
                        summonPet( "army_ghoul", 15 )
                    else
                        addStack( "harvest_time_stack", nil, 1 )
                        if buff.harvest_time_stack.stack == 5 then
                            removeBuff( "harvest_time_stack" )
                            applyBuff( "harvest_time" )
                        end
                    end
                end
            else removeDebuff( "target", "festering_wound" ) end
            apply_festermight( 1 )

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

        talent = "soul_reaper",

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


spec:RegisterOptions( {
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


spec:RegisterSetting( "disable_iqd_execute", false, {
    name = "Disable |T2000857:0|t Inscrutable Quantum Device Execute",
    desc = "If checked, the default Unholy priority will not try to use Inscrutable Quantum Device solely because your enemy is in execute range.",
    type = "toggle",
    width = "full"
} )


spec:RegisterPack( "Unholy", 20220911, [[Hekili:T3tAZnUnY(BXvQOrY2r2u2YzY8S8wjJZB3KnBMPIN94tMMIIsI7qjQWd74uU0V9x34IaGaGqYEMnVQ2ARSJmjoA0OV7gG3gC7hU9Mzrvj3(ZJoD0Ot)MGGHbbNE(5b3Et1JBsU9MnrXFmAb8J1rRG)))(6L5zpIp(XS8Ozy3lZRlIHxTSQAt5Bo5KfPvlRNomoF1jLPRQZIQsZxhxenVc)74tU9MP1Pzv)W6BNAEUHHCtsm80XJGrnD2SeAttkJV9MRtIQwU9U)660flR2EhfE2(J3KSPkz10KIT3feC827WrC7pU9hF7YO1lskFZ2F8R2E33o7FxxwTkzDv527QY3E31RV(KRtMNMLCczCHhFDDc9D5RHX9U4861W0ufvSib71dlHxfvaTj53aGSkzgT1zP3dpllF9c4nRZRxSK(8vrvviq1pkpjSmPQEZ27(IGbdjWZ1PLrtZWH4MO4I05PXPrzBV79rXWuonjoQUeg0zjrqlwSmVoRehWpcpBEomML4ZV(VwshS)Ezko5)taGXbCtY6z4ehnnnlTknb7Aoc3ZZs(T0P4ARFemnNFemqvWMm0G01LvKjlF(27gF0G)hy4F)nBVBDsDvbczr4qVkc67MIK7tqmtz(kyqxN)vfjXWFLwvt2VvbQ)3eyGli)8MQIuCfKUg2pE33d)aMRhZR3E3YO7jJu1ssdtYkz7eZYzZ8d5RFfmL53NuehTb)ByTIWDPkGsNB6wpbGxdq8RMJumHfjRIG15RWT21ZsrynkJroeTzdIxqqBAEj8qsxk50c9ZsWh(2RHzocwq4ZHowevUKTH(TaT6meyHfbI8FxD10IKOpI0evfpsNfGky7DiDqzvbqVGT773KolzvAmdR9ljzr)gGQ(W27UhEefpLLViLGHxhJOpymksYi7RiualM5rtrMneakIsNfs2GyJ4hE31V7nBVd2jaAlK2b2gswVa5K2uKht27ryd2Cw)re(iZ2WBVjlTSQe5Yf0VWF8ZeXgjRjeV3(D3Edq8I7VritkWgf(rc35W5KnOKzHc2NRMaG6JXzjHjRHfmc9p9eHeVREnM2YdqEXmyHnCADrzfqPewcK1LdzqdTvSMmJWA38QE0n960QHpKI7qy3xuGtNA)BWFdJMndg8FdrdKbq)vm6PT3D5eu0dT)uQNEmcOqT2aiZyKUd(31pgoB9SBRaHDwrPWs((i4xWBgUjppdb6I61PXHBYFaPEG5PpmN1ZNpCwuXhdbkY1LGeIveoXHiPgc41RtGhUizikqbPCQcJZtZuqpiGDV0MdcWNrxt6VcEZOT3nOzXq3eXHexpNTVRNMbmHXvGd35AdhVnZ5swcljcwuPfj4KMMqiSgsK2jwAeAI8Sz5pSEy0M84OSh3uMiTTcTcgucnlJGeP)bqA8lpibuhMNRl2J5c3WhwLUcgR8WZjJEZkLs4XxMMN0V2YKsG5WsQggQE5I0n039pxMSMRUeew9q0MsM(YzmLDGYzqcpQknnduPKHTJi)NmGu60YteI2Lvj9quAfr3ar9NUY7xr1Epugh0NiXaKBH9RCizv6TihnbvdielU3bVIttPG8pZnYVc(Fe5RerAULVAIbDCZwtCw0deQHLrWuv6wWIbo6lyRXoXnN5CoTZ83HWBQOmpM)9tjYzKDrjneoGdwl0wDknXJzmWgBJbzAkKTeQSYA043Wz55RaQfIzHmLGU1im4pOkf0fzQiSId(e12XOboxswdbNU9UJ6ezFiF3T79Ll505DIhj6YjBepevScF9kWqaa5zwjLUu6UxEJg7daFfX8NUbyZqLUyCfnXDmZDpNuKKUDoc712llPuePjVuEnXsuZQHAwHqd)MxuRpaXZlas8cOrGyAtcOlb)vVriGh8iodqgrBGDBHgwbydkXmiruUpQIHWTcHQKnXvHNnMJHBBHPGuXfWW5SwepJW4C6WVEmN3XiZUB9i99KiXMiT)OkTYUwSNHWz)mVvXMQFyEJfvOEpIjqOfusMuvco0edEZnLygcXvULjeVfxKL8v8EZOIXWvuwjmUAydmbaAi93HytacBWSY4kKGxA5RP8LQMdBFinirSPXLrYAmVketoThhiWdg7YsmKwHAoqhgQDUeLxB5xcGGstebq7SK4OhBGKJOQMmi(7QowddE5mY)LYhNX(G0S7FInxfCb6DTn7CxUti61Edrk8AFG4Ac(FjZNNqKxGH(b8YidfJ9WYuKlRmDvPAiNogLEHE8GHPBMu8XIGNfdWrrAo29e0vicRjOZddCZYOsPGEHmUfjX5RwbmgdnyS(S8kDCHrdI9bZDUIQn3(D0PaEjj4wemA2giugm1aV(Yc4lIwTjADftraG1whlfiNdjuh6gf207LpswZr8woqy3)gqx6cGqj)ryHqXPcvlk6kAlraz2P2d1HKhMgDWIXhdZNhc72HZIwTozMj)lQjbWoCAgzji3agiX5GLfmQ2jzjsCv6uBHV0jJFipe22ua6uLVLySHiG4CG2h29gs2xcNhLiOayBqBwMevKVkFTStxcPX2nOG7R3ZjaFdCyY6aJXMZUHaDZJ5L0x(U2ihYPC6WOaxnRE1MqEWt6uiaXd1UGWWMmDWu((vAmR2SgBGlhiskD4ASDhf7uT(zUNuN65y2z2M0OFxyYdzBId8rp6vEqxOI17IZxIWh(37HbJydhx6dAKhhBAhPB39vpjZ9yN2ezTthu9ZwAv5w66(9DH0WoiK9oQlQPDzxmyKDSp6titSzPBvXcib432KfTEnXYHEwuWIt7fTuGysoKA6v6q7vJ5XgCxRXq3oshIA2qucYIj9pMBOQbC3G(5GMrrYDA08kssqHLl1Qo0KlmbEOvxyRe2PXsQ4gcY8xEpXupmwXSyhtZy3BV(vLEBclfLR7Z5vt4evMCuDS7nsHHs699qsiTOYBf0hyuvyiBZ()Evxt45NIQeDQb0k1ig3DWw4PPa)vgiakC6Ja3aywNMc7)Zqw2tle9NtwVeHduKrCErr9g1(1fT8i(2JyH)XK7rPa55)Eck0qXc2rVw1EJP5anDeZ37vt9uHVoA3xCo6iHIYeIRfkUzhOJ8TBRQN4D3Rw7k97E1Afr3ZdL3ipPqdwJznsWyz4CWfKF)rT0e7xt7YaWoql2vlBMtFpiTDda21pBDFPlM6RAIDYlpVDxSPsbxUCjqaGXoaMY61pKxuT8r3wqyfNlYBvtOIQsJ)ibJyks4nGeA1X5kKb2al7H1wWiSPUSQgJeaFlwHIv0S7ZX6YcAxzEgbMKX0hWix0Bu4Y6vrRZtNrYas6AyUXzjmDUeaO3jLgUAvYSuSKVUrsV)8SKYLKcetUTlYYNgLHnKyC0gsyrMg1KFuE33Kt)3g8c30brunJslPwbR1QZKBLmyO0kB1EGc9kzWvSCLhy)6vGFUHIGoOHOB7RS0Ane5HV9MZDfj1Npu4diCMjjr5BWmFuHB)s5ZGwcrdRcgUmQmemdlejM48isVUHHUUGWfV9UVeeepMerzILhQM2993hLvdepLKOQXgOYgbdhJre)(usjyn9rCKgU9oAa9EaT3lEzEjwDc4VPQYWsiR4JmZcXjUmbDJcj)lkzrBpPKhBVLuJgZ5vuw8ScEyczwtUGeoPijzv)M0IdbUsSYfszXDF7DyO9tRWkxaxBjIWbIrbefpqkHVIKQ6cO)yDnsRko(toD44HersSaVZWjHbHLpUoUHgHl0c)fmnH4OC7nqVzpGYL1sqV0(RPrsFwhXMvd0cJCtlmYhAbNGUUaBJKMhOq(1cIScTKio5EP05Q5e92G9oS59x9NWTZtd4bR8qAUVhsJZP2StNzrRe6Ku3j4d1vTGqJ8ENO3M9dcd8ccdKGqD28sqKJb2CghYusv5UAtubr1kjw68vdTmHipI1pDzcK31SMenNcVOBpBkYX2J1D5FjIcdLIILCv(S05PitPc7(sqWj(WnfP5a1gVqpfDJVioMk85HeSYNydEZqsQQjSCyBw28QKcFd9xRZXSmqWDyioBw7LgLeWHOUKfeiyNgzYqdg7K1rrKg7oTHZZGuztWFCDrbTUJP1snbNr2b)1Aqfgb3JBQFRWOt0R9FriNwghnVolleeIJl4Gt35vSs8pRwwggNuubYSRESvy87oNgYW1S4WIkEiHyBUEgsOvr)78IqrVc5z4WvQpuEUIvPJUOtJPhDrldXCM4aFmIxkOzWm8AUi2KFToDZgGGAr09jzCYM5PGM6WOIPPvS0qjMIQhsb9SZc)31ZwGf9F4zx81FZ4ZuI8(RfoH41WJT1RgAez5pKbcup7uPmI0v8Ff4j3EQ7L78Ijfi)dNMVUUeCKjPy0RdpFtmBsSvtkNlMdZD2CYYhDQ6ALBoAsCrEwEHUl0AUOQGfceKlE6CUIxrwJIWaX6YZHTNAaWSoWMZeLhRvgfcdQmHZg4Whb3v3ID29ZoLNLr3dU9axPhdsri37QqN0E)S0eULnyGRmwLthPNtpPw5YLk5MjBnBhqO9q9U)WoNA2uWIzzQ2kBQ9am3VJATsn4waOTMyr2mSkyxbyRcdsloOJ4FykPWuR)2LAHrrMLMzc)fGPbwMFh5DmtdWvdAlMW3oMNAYwq1yRayF27W0gdINXFtsHaTnxdykWzsvu1lqOWu1191CuLpTNLm226iCgFmE2Mj61DrdmWZq)1kldUSwiW2oPFXCZaUTJ4y7NgVgOYa2WDG32l8qW30UIxSLeDWbQVXhqSLfSEiZ13WI3xnfOCdNPRtdp2pJwUIw6pku8(zwiRN98yV1lcatd0gaRPiMtwFQGVKG5DDC48db7Iw5cRZRT8Jk1mhubnQN8fkTlI3Sq8a72yyUyWObcVx3Koyl1kSr)OCiDustVAyrja9EK0ToRpIrCEc0zlC7jKCEEhk7FMtPX98pHk(0oprCI27rwvoRLO9OYYO6mIS9aBMAP10xaY1xcSTQijBfamxvQftycSN4UdyEDlbv3AkBfKyaWdEKPqaW7dapXf1v4ZdjbcPEfmc3NgRib4ZHmzRwSY2)4rIG41q7Tfl7y0HuvanJMrvuVsbHYQp(WO8QgF4mggKUPVhf4ycs)1zaMijUgpu40aw32QF0FbedDj54Tqd1JJ9ndHrHvD9wd7qd9GJ2yW1p64wghvuI9zEbyRFX6OmsnAnxI00EtCKMSgqOmDrA2of3k2(E6kQdtsE8kIcJDuiHZKfounyWHZFyHa9WYKmsbgruqfgx8iiC5ZkK3tTPAWV0kZb46WnkMmLGwv)EIsONjXUgFgja3ygXsybNFglE8hZJl90eI)sZqEhsUZi3ydBIslWNP7OfGCWaDZI6Ej1tgHdAOJB4DTWa6pPo0DY1FG1RfGdPKGSvTmATsxhOjKTrHniLcJY(SqXQRNHSIOLXdsM5h7LYxUqthPprmwFMedJD2Usu3((jz1VwQNAs1IYYvkNxk(E1kXpnPiH6fYG2cFDGdNOjA2TpQ7mfqRSY9COaANIV))ofqGlkGG9IcyKBkG24Wwua6Y0gzkwcDi3dtdp9oEjhR7xCIiX(rqQWtkij3CiiXJoer6i72EHEpSWWbBV7DSS5TojL((UhTP5OysLXz3ON7id399GJTnlFZqmWDSq2n4RJAcWg9KRL4aZudTcnIHJ8f)GBrlByS8oy7QuDWyxXm6s3Syxcp0TlX6RmlhZtn52Uikdusn7rK)JCfsrumMxiDulrOgqCRy3)dGtWepG0RUjqV(mm7cj)EI8sWG1HDNXY(EA8bIMTB6HYBTB(HPitAFshYqxkY70MAv6arRSdcnDGjGP)l46YdmPgH27f3zwCEJTsL3W0eAzMx2yVuuDvoktMCGDjhJIMKe3I)YKH9DtsiWI6fiMSVp8eW0zLK1YhnxLk8NKq70iJORi(2GknDYsm4pt3iZook)AhQKUsNu78K6v(IO8gTZ1sZoOXtnNiyhK3jVBOumXJSG4skn5tv3OmDZteHMMA6HTRpcCrQ)U0gtSu2ELcwNjxI2DySXeQDhiLU)l67OMGVsCISBtfWIhNYAuk5dMmjU71yFV4VpWEvK0TGevgtRtJqRbX(uTy9SBhX29n8FUmo2WwKD6dRjevzZZCiemzgB37Jo8sPDQd5ANnkSWkSlWo0QEAwDI6bbuGExfvuactNfUaSYPcSSgqrGh7XjRisM3i10QLfPzzHLjjFeeQP8ksLvG65aYf8gtSeCDqTf6N0fLxgVmkVmCA06K2r2vJ4stLNYEK05Q1KnWIGhXUWh108)3GXflnmc(7FKwuNrSd49zrlWsAmL6jqtT6jLajqE)9SoGIXG2dWjGtkxsnjTNhA765qmLr7JBVC2niQljMDNYUoxq(5cDFkH(jTbPJO6sBVsuTy00k5STokCHwjdSnUeTLleRGMlmKVddafHGuhqErWYDHb7PkfMLGDk3pjca61U7pqRNwIhqKljxoSTkTKEvW(pEpweSSlAvGhOpP06XkENE90sJPxoX)QnO)xx0eDVHgZ6PssfzjtVSg6liTawg6unKBqdqmciPdygkuPDrKc2GPz55ZmsDpWWoQPuDYBK2fDJc26xOdmIFKU(HXtda1Dw82kgDmyobZmJ1Kz1ee7mTtI6oleVF7xZOOKfe2V52jGuQ3dK1F2ObqUlSKIzkxQ)N7EYYsjyPfBVN5LLfA9QX0DQEhzgLYlpj5lUs2LzjnOr)mUnIxxVilbwQ5KamikOCk9b9YEkQmAJoMT9oJDeRfshhJvZUSlCGUH26qOSJgphORLdlDcz6MhRS78TX0in(tud1jPX4DBW7ih4V6Z(1j3aU)J1VDjEuIaPnBYliwwHoHqUzFgkjOamelt9A1s6YYIhbacKzlULohHM7naCiSzAIZHOicV6XP3xO2mgOdyGz9kzi8Os11p(KngUQE7Os9R)0gWOq)kktckAUKQrOW)B(0oTyx5IqZxiHEDUIqI96GXoK4QEkfQ4Tx9zQSVMkFHMsb5aRHgqBKuz1AgaN9Ul(32sx4o56hQw(Qzer27wTh7j9DZvAxvd3IJcYiQigC5a00qoUk669z9VR6HcWdxiCtZOJ37Kp1Ka50m4y1aBkoY7qsUXPF3pwjeBhOwynVU4rPJGgXYch3D626zdEV5LMIh6oS061zzQSplAq1rsbYdRTOTUwB3bP1Q4LMcxzZAv2eEUjek3HTeZ6lfNgftrYtqxJ68Wl8UqKDrx1j)LBV7TryrbeJ2Ydcoxq(khCoGFYRGjG8vUaHk8aXLeH3OEzrL0RzfPS5pC7D)9Q0S0FhjHxgHNPH4CYj5JwwfSdqNy8r7K(ysYg(xhHOzKD4DABF)2Cdg3nTBWytrFStnbS0wyG3LZtBqUb86lufGYKhTPoRSJ7CPprOiASCslsiCO7kpF7o2S0eVZueZCl8NlB1chshaN(PlzA0csWib9eFKMvpqWp4Izj(w634MxJva)drfyKGa5))ZV9x(5F4N)ZKVmhKAVjDfAijZ5GxjmN5vi58VwtRLg6xCfwUHWhet)g3mC7p(tPyggcGX7T5RHzM86xX0o8VEfLfr83C9dWZ7p63gyT)8dTPyaepqEecKgHrAJqJJ5IXq6rThLT)OhygI5v7gM5S9aZCM0668p1RlUZa72YAF2WL3UUqV)S8RhinenPC)FPJvS19rg6o9zkKBF9Up7(0DhZUmW)6DF2d8O7EU2)MDF29P7oMDpjez27(PNo0LGNDL9YSWhFGIxsHxMhLDxi6ZvydDugVpWb(Hb77F3p5p5IieeF6jyKxC7J8Cx9xCEDfJqZtSr0QVnTRWGE)9fgCTj7pPYihJY(ajTKgVJydDjA(cdJ8JovCTgTB0Pp39yDm7U2FnnS3KU6TKJWAf(zI7l)s6O8t10BtK6SAW608njGHY4IU)xo45RV3Hg3Nl0ShkWhzxdSg0ibmKRFjIlhsqZjdCpC(GBo3JU7yXm2Lc9DKqrV)7L0EMS5t3xHkV0JN)kHyUQUBm37J9cJErSxW1OSBc(EUQbCAsRh4dx0G7hu0ICXhW4m)iuKIy8UrQ8CTxz)jv8KfGvfX72QAFSIYLxX(0FNEW5r)p7fuOPoP2(Oc5zt6Q4h0ZLol45sOXgM9zNvHEFFiT4MY9dR4jvftgeniB0VCriPlEfvMJPB62B(IVGLi92FwOXxz7tdn(UMpp04F9hTpr0my6L7ZenBa)J3NkAva7Z)NlA28)5(tgTGO75)zJMnuVWF6OzJ6E(5Jg5YO8TLdfEED0KtOxuCMFxZPF387BULEn)E9BJQJvVjBNC(XPZNCatUJwct7DGHSvVxZYzUMfttcGN)VxVTMUEBnJ)5jP6ym78ty4k2Lk6X5BMqU6xpMmPtcoU5IUCcmKhl4IN04CN85iRx)MN3uNcS15x(LNpEYPd2fWA0(cwJSawgUGzfGfsi9FVav3UxxGQ7YMkhs13whjVTgiTPEGfInZB2p9KnIaNubsVeBT4GZE1FcV5Ehm4W(bdhFK6qJneErRZPlLSDWGR67KFq6LEmLboNYa2uQlp85ERV6Zgl)2RITpYKD3(eM0RJ7WwFMlYn8kBIASdx)AKTxZRmD1XYTH97Px8ia)jwpZiRdP6iiOhM6AYbm4(O0mc2waHtKoCPeu(Z(ekkg6wl5wNxr2YVVhNJYNEY2P2u6n2pXMd61xq2AFsgsobQp9KOPwo9PsTO7tE6GNEQ)Ze29a)qPd(hm8TJnbdN0r22qtfqB(4BD54EwSMPp75kNrGEUpzbxgCwtl850DcD4PNoW0mnWRvlyLJcBTuDEt4YUCupJfqoSSv8b4Q(woaMhnEasyOByhhPrRmYEwkLYlrqO5iw6GjQ5OmYwpQv1YKGE9pW8585PNAFEjVkySd0NujLACYUAYODy2OpVxFlh5XRg)0tQy6Gth4a4mxCsCzk2mV3qzl1Rlk)g6oTgaIvKRBOMJOiO72QYdJhjXNEY6XnSEtpRVtc11ENXsTd7aLkDe30fk44Wec0qO41we(wM)E6hCesafU8CgkORJmiRz6hxq2JTCubzVT9XeK9cLJiOK4DZhpWlhtnpz3otFYOD(5gc9rSJttxpJY86zHRZ4KOCi1als9ysnXNBcoee6QqxF3c)VQFW4VuDkoYXrXBqBQ7Zywi(j(0MzeDYo8EtUarKmaZa0FPkmVdOu3iVEYIC0ppEdSrL1yiP0bJRxFhhfUNEY1XGJI(FMhFnzGv5uYHq8oirPV7tX2L9xep7qWhKbCXSToXbxcTqb3HhcPJb6ajZIARYhbtdMtyZoI2haTRg3Z14tbC84MnONUAEc()tW5iZnsOnMZYwLJEG4Adlh3tRSXsDpLkMwzE6aS3l258sg41pdjkXmOS7wkQJQUBk7qOqT9VPXLmaws8uJXHhy96X0I190Pc)RWCcg5nCXkVr)l5B7hOnwVrpOPVHcn41DncTeMt5VD81BKAH8plJZRbMj28q0O54kH9QZ39oOVwEPWYwmLKIMzy4UrS04N)gfTaVXGfIVPXUTUPNe2sl30c1ZDfZXaEEQWvVPtGwdZO2H57YGt9A0jXN(y6rUJAYsB9N2oCCDn(sj)38aFGvfnhyAXkPX2YrTdCLrSXtLoP0hzXvytB1YDr8k62u371mCGjQxEuL(28VF7DFhjpbIaAj2AMeNf9aHGCzeaiLThOlNm2q)qaQREo5IEk8pZjCMyCJOMWcM)zEKBzdbdrsEpzkb7qk5MlyD0P2lZagWmOoGLbcJG1Mh2t1wVDT2cmV2uLu2VLOsqICmy7ydbQHi9W9x1IBMkXHu6lrqp9n2Z0niFYObMH6ew(jzMGQFqLUSFWPh5eFC4zdCJWU8IEoxZmt(u(GHJhSN9cChnUJDVXUbMUN1dCo(DTuvIFYLJTgdglHG5slCSk8vESgCJcKKUCdjy(kdirTYeMwdQE6xqM1XnXYrLzvWdlIthne)pqU5oXMTOahSDgLojiaibZllvdJi(Cdl8wm6oXLF2yN5W2oSlBQ76MXymYeomlda1EoIi1LN9jAATSt5Z4Qex3ZV0MzruV5wIjVN2DWfThI2uYcRbZcYzhJXRGKUFsImZW2rkfgcVj9mIwEIOkxKRqh0PksarOElQvttmhhhAEH2sVA)dGxHdx5qYAUt(ofUuuIUdBVpRNcs7mhinQOK3Rvmjc7yNqntwXivZHn(PNmfyytNL1lNm6cJm0JUGvqzTSIUbGoYqDJqCMDxseYR713JpaHnmkD8Pg8YxdYe9yaLswLJzvfN4lmC0zNoORGgcRBZHlZCsH6130xfnlXM5Cyum1C9msm6ukCYThN)P2tsQKLpxFxgaBBnsKn8Ld8PNS9TcemW8aNDT3b26QUjbDcNWobmBTxHd8NA2aVXzNEeEL8yCiKI7LrFP3HOP5i1CDp3geEBBQvHr0JXDdy613GkyJKRTCPYPkFW4KM6fO9NSpyET5zRjNmjHyheO9HV76JPX(cvfTm)bACexcdswcvHeRob)ByXE(qePwyHwet(knql)hm3)yrHkJLbDr1Rj7kmTs3aylmOYrKaXtRVaYNYWpm61S4Z9NrrphtJSjT(gMnJvuzttq1NLBIEaVfqvIxJTn9qIKmCR2hzBgjhUAmdlTmbR5eXcvOgpgqRfP5Cv5PyMNqrGymeZNnJx7O0soN(jZGMXO0KspxfL4vJHYQ4bytzdZ2e8L4cIAYOLfbJUIhx4W01HZtIYQEmeV)ecXc6z9IMeMzODRWQBT4rFA6sSP(0W7tkkJWlaKkPXLM6Hp7FQhnlbrrPJIHgszQxs1MJ8OE5xlfui35BvwzPdBgWqF7mZYwelAFrPe1ltgbfyEenm92rwo)Go2zrGStZBxRNGV5O(28J6WVXMsXgsmtk0CA87KZLdYiVI0E6PwpQlZLaBvKJXOhgwc9WCYMTGY1Bm(5sCGxOKUWaM2iUOZb2Gc82kQ7AQTPG0I9dAbX3syJco)tq1q5K1LvXcw5XC6U7OE93JIuXHORRco1POnmM3(S8XqBBMn1pSXZMcz)qnDNFa10pRSeAoneKGUO)rdKAGW1nXhGMYDsjodwhKHMxSgHfYhORLr3NslC2isn5)qEb5eCuxuwtcoq66VAr0Qex2D0CaKiC8MrIh4fLIRT6l0DDH4ab3fBQTQG2CXbwsc5XsG6eLy(ALvWad7vbx4uLDJarJfhC3RoluX00sFtcZ(z6hIM5KJggce0skcTwgpnrrmJBehUk2PCAdzJ8xEpEm0ifbalunuZJE71VYeUc3y1Xwoqa6oWGB5TDvXiM90J067HxmONz9XAZH5b88thyE9O7HRvcGgNN1QpSpX0aQH568RiSm0LyCErr9g5wBMGz0r9T55)HJE9ZfXyhV40cTRWiEB2IbVWlVuqTgcbt7xh6(7i(mUJbJdAL9zjjNm9DHqXcZ9synI6(aA061eX(pUxERquL)CP8ntmpEpbDzmvRkbteFd75N5ClBpnNZqC6eKvBafS1yWSziEP42DFEg6TAsyzEgotm1G6poCz9QO15PZgIfqXAGyehQW0vRsMLgvHhAOMNUilFAuMYJKHg9XMRI8gyrJc))anmeIfilV)t29SmzizZMS1DYOtLDzY0Xw5WXQ58TP1lFKWAgD44bdmhsESTKWLPr8CkA5Ur2B3vJTrXuKj5SU8WcdP5HNn4sF8zV1gaY(3KJZ(kjFKFu4nfuozPqBwMevKdoGGPuPFFJBI(NzZbTsF8atqDRKE1H)CxEUZu2H4WrMMNw5CsS6KQs9oCNlW1ulhpLVYQt(dmNYDzdoDaZDKNlR7ywjL1Kz6uL2HOtfwhlwDU5hgYnJG)NhUNfz0oSrSds3E(7Jazwb9aezbc9dhhiUsk(ZuaHvJeVx)8dmuQ(1M8POoLvZ51(wIYxkxLwsGCRThZcU0RFhDTpFEQLjv4wU8hSPtSdIn(zwGLDamIeeFZqp7KYYFjiDgVuSP1Ln5Ivat2rjrR(xX79coHcwxFsN6ElGFHJIHuPulvYwVCbPPoEQSjgcUIBdjhBt6nQX2TulyZ3sEnTeGLJqZwvPR9ZED1vSpv8XZPawg7EHFP1TcFamxBgw3leZ7xWVPjW)JEOQbMgm8sGvfzK81TmfjzltxvQE7QWVEj4FGDfrSiQj9yy3tksAsQhgMd2Dfb7(DPICPreNdMjV2orUjflmgCYHDrD9PvzkUXcNteqV9UFHx39CiGvi(tu)KpyjAWxDXyAqe1mT16PmKBoilGb8HrU8AzaaS8B(6hOyZ0ZVQxi4fdF4fmxCB2ATrqw8rmWdqUNXpjd7(cP9xvbDZFT2qtRbTVFccfem7LKVr5jN8K)q(zsW0ct9R9GhBq7YwrWylLgPrsB5pGbgJ68tp1xJdXyedNCHCidBgFXxrGx4vjvIsRpFboyCm8rsWeFJ8hBG2ie8KGBHg04uJU7XkLHcTdRe)25OCc)two12HuR3hbQA)F5sqzRsNHST7qMqRm1OFBfWYnKwfmkFKDmhjcZbXAuGLbk9xNbRdY10XKtnz59OtLR(AochZHLck3E5P4rNlJJkkXophOQskwdC1OsY5jE0xTRUcp4ramnS(UIuqzECfwmWdGW(TKXlp807aBxBhdywdLOChdrUKIWNrUjJq7Xty3ctZyx8shZRB3Pj87qfYOYl7Ni6T1PEDQS9U(y1oH8YuRVcKRVfmDE4vm3a6pP1dZjx)bwVwqQbRc(5CwQRMX3SFgO63CRRULE9TDP)GsVDMlyKT3sFz3KaV8snmD9i4W7rSq54Gi9gsIpJYxktcOGnJsfPbRrIRiQjbd4YlST0NO(TLXXEZi)3Bg9m2B0V)O(d4EtGL9MGDAVzuR9g9LU(EdZjE6f8yoEnNIERqsxRqGa)oqJy5foC8smJiJGDnpsV8fzG627Eh7YlBDsk99DpAtZrHfQJZZHV22DuMP7CmbUvJzH3jNsy6Kk2YGA8Q5RnKeOdjc)x5EHsZUoEnhY2mOI7rObpF8uCm7cZKILf7gLz5v865mkJCRrHflb5AGLivpVW8UaxBg(1oTUAzEXT3Ct6k8I3eA5BXunr(KrD7)h]] )