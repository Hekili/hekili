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
    raise_dead_2              = { 76188, 46584 , 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time.
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
    commander_of_the_dead_window = {
        duration = 4,
        max_stack = 1,
        generate = function( t )
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

            if talent.commander_of_the_dead.enabled then applyBuff( "commander_of_the_dead_window" ) end
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


me:RegisterSetting( "disable_iqd_execute", false, {
    name = "Disable |T2000857:0|t Inscrutable Quantum Device Execute",
    desc = "If checked, the default Unholy priority will not try to use Inscrutable Quantum Device solely because your enemy is in execute range.",
    type = "toggle",
    width = "full"
} )


me:RegisterPack( "Unholy", 20230111, [[Hekili:T3ZApUnos(BPXIrXojRJL629MSODdm3IdhMb7Jbx27wCFPvlBRUT2yl5tso90dm8V9JKsKIpQIKYp6KnxWSZSjwuflwSEZILUl8U)(DFCrsD6D)1OXrxoommC04pm5dtU7J1pVj9UpUjz(NsEK8hYtwt(V)x5llw9m9NFEvrYc6BxvSTCo5rlRR3u9hF37EmRE52zJMxS(DvzR3UkPoRiFEzYd10)(83D3hNTnBv9pLF3mWP(Q3tG5M05KFEsebSzlwK2m20Q539X7(4QSQ6k6mpVOy1IINYP)L)kBLKMNmBv6I7(3ipSmRoTml5Upoy)9xoE)93oD)9BsRh9ys5JfpVkDuz66KS8Q93hO9GK51zFoD)9d3F)UD7VN8(xS)(6KvP51JQ2UEDrESySTZyZi5iKXOet1T7V)6XohCYINzZEaBYNT9HhgTiP8tX1Lj5vpuuUMrthTDdBi8fh64eZoDAPR0KY1ph)4YITReR1aJNiERBM2mhI3EtXCK3U7jgVDlXCwrvdf)HShxwhRnS7(ifIf5egSc2)FnHlqBJLpIpNTknEErEDYJS)E3gEdwfNMNUolTQH4eXM0fPmI0dPv0HM)y8tfBZxmQQMWL3mURyJtS3KK)C8cYi6WtcAsMRNNtM8AYowkHvKW7rWZlrzaHWNl7wiA7)uyDfkSk3MNYWIMf0Nti)6mkp7IfvTuZoiNmRyDwoJjiEv26zuqpbf0x0kgiTZ2bQYKSQ04fewtkqUgficeQQoEZQK8CcvMZi3kcr0mSojFrAzCXdX1lBGANGKc5NWqLS65nvPk7apoFXO1j)6(7FnJoOinb9k32XaFHVOXWU1oGmfLi8hCteK2v4ebRSwHJzdRfdZYFiDED6I45RsEQsHcnqfwQYcQc8KDUfXPFMcqk6mk9xP6pzqr)ruS82gSyyR8ss9Y4pLtLvh9atyHGoT89mmUrsqWARsI1qRoAlFnOJaY7yteqdBfmuF(WiyU3lFpIsMoUjBc0mLxkQRbzUIFklNSDX0B3lErfgCRA4B50hcRI6d9AvIOSS1QJnE8l4CoK1ezPmp55r1zZ)exvq3srBqYwKfk6USz9BdGnJLSjGV0dh7wAfqLfOFbMw74prDxf1xHorCM9w(EEY68uvfHomwFmiWf(IdwD)4qMpBJY6K5HlerHDC1PR3u8erKIYDe)ukHAXe1dX9ueLN2cA5E(0DGbWy(LQIusmI2nMhQ70bFWBz(PhNuvLSDvTlUDergDVq6bW1jG2D8I6odcoG7UIUsyYUFyROffcefeRjqRiEZ864lNWMKjqpFrwk3EJq7L)6WD63HI1hsSsRiKLKnPLSvNUFuqJtAj7ALH74lYAMSAxuqKi7MUoK)nmOIPof35hCK4c3XY4TvURDOlq4KOernHGKpKnplzvmjS267O)dXk3dmUyEiK8rtK1we)qzA6VLkVq5bKiakfhFKgLR(W0fnliQkQsRZEqkeMwXf6FA12uKifCgUyhvjuLiIWtgQR3wACGUH7yk9YiaB1g3Kfb6ZIj0cI2tGGDCqO4aHz9JWq3O)sW(5k2HwxSDOqIgjy7UsC6kQFrrInjIReaXr5jw3mHRzCRewN5Fsvc)cCxoAjVsaW0YP8dBLOga8ib94DSNFflqkrqvdz)pkRxOkjWD0ZdySR)EFCiVLy6gMHqbC2sTTiknWTCqN1QowjFeneHViaaWUk3RvNlpDVXaMW(ajXIw1kTImqKsyMAdS)oTb7aThinJ1R1Rotf4e5mjbNnfBAE7kOyVDZp4iK0apIMw4OgXVTS5XmV9y)61J5ulyVRKxffRO0bjiaf(P7LJ1qqTeZmugb4H9pPvWKJSYRbGOh7ps2LGT(JKwsBHMFbkRb58IbfgOW7A5GGOz5ILU5YSnnp(xkZkikPZ(nIU4FKm03U)()226zeFMi8XeNe3F)FHmd1K)LX7)lRsECB6mklVUhC(eVFGA2DS6luxeY(50QrstCJlU1t4JsNqJmW5LIhpsnI1CkFfymFvPZT6QqhJXtjz19X)cHz0a)2rCeI4atV6VPZPWoYu6MSfKNphWkfMdf(GDEoqzjq5KZgoYdpsLjA0fvFdbZVr6clAIaCOSZHnPCQSq4lLXVdUgKZ2iBKZlYwbgTU9GMU6l9gOls23WBCCXjR5bPO1cGLq05bAtJY(ZzLBPYQuJQeRdkz78lpPBagssIbUAjDT3mZc)b3Kwsd(nlx3Uffmpuwq8E4bIr6Yy5HAao6GNTQOyr7eIp6HsyQHnKzRudisctrgbGvR2HOeD7eEqsdSV0FDtQEyPnPBOBK9dqzWr8fewcwSEoDEV9paZ78a(IYDKhwzHgk7HW6IYzzlYQFwfaxyBaT(JaN5qhP4jkurOvzB0A(1(UK73LCpojxLbNoJeAmJK1pzC8KO(LNRY1aHtEsGlcyGt(q2sr9TbSwl5GonPaXvBsPRCgzvpAAfvNc8wkjK0S4MnN(QDGLSMxf38xIPvCutDhbMaZqSZv1km4eyw(mIWIl1kiiyD(NO8tuiOhIJxqOmHMo8gaGheYfu2bs82jKTT8I80(tW4VEZm1t)GbNUYT5OZwsbRkAIWlJgWyQ6988i59lzojw39xaQfnGWbutVW)r77IWQcK1iU(u9JjhmwbHgIQT0IPlErrXAIqf5XEyH33CMFlxpkA28QnlMlL1RTJ4hio42dwY0GXJLm8kvns4f2RLfk0ukMfPCd1uPoqhQdSsiOteTl)LnOmYQjaLmaBdbl2KUnjkp9NsXzTePvfe(tKpSlz(3U5KX93jGBTwmrDgvI1MeMg9u6QBmJFnF73ktQQBMoQOb)sSMRQnGGBsQjQEImPuY9AQscRC6wxiwz1dGtg0e7uWXCVv0F3x3KUu2BJ7)TbU4AcVASIx5gugCT)OChKTw6zupJ4kZOvuNAM9CC6VMSEJ2jr8LHnPHwKkcD4kgzGPRSHgnVOSC7g13ZgV1aPL7Ns)m53Ilk(TuQnavhmFVcLgQcrWnbIsS9LstdaqX)74ffA(GBC4WE4sVDQT9vlEqZUxTOe62vRZZF7koRkLzGG7pseM6WXkAXeK)BAHg75qD5pUdYIhLRREb70xgA7iGhLklq2jCfcI5jkCQKODP4FIK6TLegaQztYuUn)PIY6LpdDKEEqZhyXfigZc25ErnceELQwxe0spuLo0siiSzBv9wQFq8TyfowXW(Cb9QDqgxvXkgojtP5bVQpO4LBjHOwKTGv5Cz5K5MolX0YMafYkdC960fzSQTrY67dRsRwYUJjYJ9XvfZswrhiZfLnLPKiKNLywRpsf3UIFnO39aZtluaCAOWSYfHnN84RS6ueMH02JPFGpvIJEU494K7rdxiqkScFU3e3WQ9azDqLZtYPAoklPBFw9gAqlNstQKEyB5ZJwSTKjsU)RQ7SJY5P1)Bqd(IKVpauoVb2Vxn2HzVJWWTQplZz3UF3dT7TNyNpTSkTKIaFlVZdTip2DEmyEo35nNtPDEXdT76jdsTUcscpnn)X6LsNyr3(hyXUjYMbyjTDd9LnZKV4L0NwxVOKAnMtRvX)ZTlECDREnChoh0Kc6VH4JdNCmCS83(8WBk7rws(8uAELxfttjPD)FrWM2naMtWDwKDeQ90wQSHDWnBPLpPv3G56cFiRmLP)8ByvHqRXdNVYkippmBitPK7O8NzpqaDSBkVgohGORsCAp4HMmrHbCwYJm3uljRUQgpsfNzaGlP8d34ZPR4E3swkKiZskNrr6oaBzmaE75UsbBXQr1HJwMufVL4ooLci4JT(8x6hQuGHTJkoK9WkixE6XYpYXYh65V0peC5h1T8pW65VJqw9C(CWaM1O1CzfPnQUi8f6b(H93F1ePBhOCfTpE0eXEqiK98EI7rUX9ieCp6OX9(xJ8seUSQrLBN9C8tltxTjUI8FxzifqgZtlZQ20ecyw(8KYCsK4XzZBHUXoz6VoF12fG2(6b2f5b2f1BSlsg7qkaBF3330uEWpJDklqmU9GZGk)X5oypgc2I1tdL5cdfyDqqVMBqWaNSNVtza03nU7HdzPOM6g8OjStGaxHcFKaievEAFBzuCRbwbkW)oLb4nwzOLhfRcLWkvzYqbZBeuY24SsTaIm6Qvf1Y)D60xqq4hNVGDk0(Re0FN9CngmVk92rXpy4OOPxDg(NIv9ziUW1aFMxswUUWbySvkIkgpNloZDjtttJGiiw06cC6ISdn9ReNfLUcvCSJYkHEXfAHtKgVuuV4Lmf8)oVKN8sH9HxkYWMQBEjaL3O8sgkHH5LWQpLdrVKlZCigr8w0P954SSCa4b3QxCCrIlZLTyRTF6q1a3PJJrG1kba3jyV5PWiYHFDtKPEpwKA)WvUWzDf9zlNhNT8qg4inKg3rhqOi0S036tQb6E8wVxhpMTLeVoR0GkktR0p3U2bHDrjPG6qUBESS0fAFm3k66pdK4JS1CJCJVEOCpqae7DCjgqa6YhQvHR2TAR16rlhnuDXPKXgPAnd)mZCubTwQk5UNIxFUSvrpka3Q5fBjSB8cnZ1z(4MpKXIXpaYqfhnSW6A)mkBdHMZKlK5TuALqElCTa7mta8nIEVeNYiFlIoWc1ZVAIKv4(QlCg(aQWWgz6g(vYoWpzWBesSWfRbRtggi)u9UEgsTXRNiMtd5Y565w5(oMlnlWyo2DobTer7v9EIFec(Wv3TO0VVOD4P6Dw0VAPh6ATdkfGfrmkXPl(ESEfMuHa51GN0QTWPDtTQbgy3Ow5MayPWV7Kj0l8BYRV)(p2Cle0oGuNxNd1LSJgMtuFBaIovP2uB((yOY9mnW3vY)V(6UlFYIAfGKvRU6wYeh0KRgk1xpTklhftGxiGNu5gFuL1CYkQzjutRHTQh4MR6c47DJyH)7h2XiFc6gXD7MDDAy8YeWB2gp0y2lErjZY(1eA90pjjl3DxlfN4)n8IC2rE2oMjWD)qc2XiChvAdLGQ0dZlNE7wIZRc1v(4TDxxBQ3RxMZhKq7QO4zBduF87PTRKsAjut8x5VVKSQZirRwsInHWZS)(x12R7Efr9w6)72Ss6(vvXAY4s2wxqyQO)W8LjKy(QgT)N)Zzuc3L)X93)NkYjZf7XVYapjGRUa6b8fazadc)1HUGOMMhnWIOQth2tGHTAG9AGgoQFpHSusD0alq6ECaZcIXoMKnrwHMdQxDbGLGaCWhyKpQTBcgGLKQFyWvVUny(HdVDAih9pRt670NubT46toF2lgev9StdQWU95jKpjYe)byyRgxRgOHd6vhYHJHbnOnnTzWQDVV6MOtWw8xaqF6jprWtepgFnyRNLbdWDfgBViZMgS8g580xGQC3ZGjZQ3lTV4a(SqguYSRgybtkSlaBy1YmQXBT0fvcgCHpHWTBNpJkWsqM3ozyWahDkLD7WjWnVSh9hLD78T3OmKGrxyJtrGpGpnqpreQ9bLBdN8ddgGVGE9LdFZaB78VoA4WHDSiFFx9RKD13Dc2v7eNrCS9iCtcdKI2)KgenAluNFaI6V1XOX1U7HhH9HxAaFwidhVHhea3DqN6UFyCcOUa53TL91RwVJ2wMyaM8fF3s3xN75hTLoN75DQcqct(4vBHa4duj7(FgiZET3Z8x1Rm7Hel3jjNdNZC8HeyZPmtCNu8fD))OGniFqBti7KWh0kt20nTG9UqTtB5a3eTiQ(HDHiUNA0Qp0qr8EbIlEvSgGdFcC1GCCb)xWvGwtTXyfG00BCjXDQPqNReROlvFQPl6W3A78HpjE1ZF(YntiARoHCRFaBxrVZZySTG1AA8Eg0BTmgZawxTXHUTKI0tIwTJYg2limvRdtnWcxKMEc5tXPs8sd5tWPlI6l2b5JOvyEeHlJaXJ2fzelKNaUSZhKr8y8eWLHObU3NXcOMQ2R2rpDcZyJV9MKOEPjfywj4DQ0j3KcqzHlx126dqGS(yoXG)iq81juvRpBdV7gYPf4hbwtEwf18NCgvbWC1HD6NKJyfSKsASH78bCkb8rGV0skYg62(8tiyXqwdnLTVwKDrCJh3dGAxgeEmNyWFeioMui4qoTa)iWABsFOd70pjhXkawseyaNsaFe4lOSO5ZpHGfdzncZwO4OR47BV6WakpGgZzf8ya24qAWU3QbdSb)F4hUAY0XIS(FGaPbg4Efk24CtdGhJDNopsWJby3K4idQda8DrI9diAKyJtbuWMb0Myay0GhLcz26uG2LzGNlBd3UB)I9wFwxyJY)PW)1LZHRmPV3QUm(2nIQmPh7fqdTduJh7fqpuPRZm49aWBklM3CNl3uzd4yJZt833PHkTh3FW7RZCw9v84bpMzvCEr37REyw9udEpaSF7N4JZt833P5GyB8pm)dITXFW7jBJzX)J6rIx2rLv0fyclrpqA3UlqupoC3o8zYUjBmz(HVEq4OjVbrWI8uKwa2WH3oWUFyySl6ZyOZzmSDg5BN)l8(W7EX3hE3zyFqiXOFSoIuHFuhK(xmyFevyPbeBjRMDyjBEs0nKZiW9aShHFGya1FJlEzd74NgR2WWU)gNeUVVia)i4TnbPGy7K)dCiNtO7dCpIisqHQ)(C7f)9jyESZGBCYPhLoLZl09bUhHkltOEkLhXpCaNKcpeEoTq3h4EmcpNNcCKDOQpuSAvXtz0wlucHNN4Z(tPLKFN4qZIg)3RPdR5IKV)E6hnuAprOMpU8c2jYYAutDJEXc6GxKuNmlPk9pU)N3F)VF)90m9IwtDnl9EECUNtoqKI0)KFveFPMhKtJ)euZhNV7L75dNnch(mr1)Y40YPRg3(o(Fa4)rcC4kIoH3GUojQip5m6i2O(wBEobxY9xCiFYPniL58jFEoNxMHxkZUVuZdw5oF4XVE6H4Pm)r7)5FIPFKcOpO6Gkv53DFKOtCzr5DF8JzR3UIfm3FQ5dRjjqWhYOT7SM3PAK4BE5BM(UsXNqZ9)m0Z1ByDVv9dM50ikM1(IKHVolFbTo1t)Tu5FMwVR5psrlYp)7(D7V)V()8tn)HUXKKtaiX7O5nhb6BZEykq7A92RghmaOr3qZclO8WUDIWx0Lu4xxnXa0qbruZdXX1FRipLIQlK7lLjR)T4KzvfLZI3KwoNGv3ooaAXC9yEd6HOPlBDwZ(w)wGTi3)DBAyRKP78CZ(w6N9KPDMuFBXMPSptkVL9zVyQAJg82Px6bvl06DEmSdF7EAGBGIUmXxwS(fhz)GeuN(6kC8B7(mFmn6TehWxKrHYul4(nHJdS1)VUz6v4iJuP5t76BZ)uAPoszd23onugJTp0bx(7BPvQXamuAD6ztHQFndQ2oqfRrqHtk66GCTl8b2yy66M7DBNq8qdd6oXbaI9UDoiVbMG097iqCn)s4Cmrc5y1beGWm3DcusF(SDGgxnC3oL2qoHp1gX3OZ(2Ul0IrQbK2TcH7WY3CPS(RBi6TUaAjGJpsdcuNZntVmyWf6Dy(Mgu)UD6)Ew(THtgArLq3xeaenCx1JzR53d0)zoN71TAG)hltZPjsILCPxL(RK9W8KvnN3hbJ)CXNsF1B3F)tz0pcwBRsPjpkRIAcpN2CxxvqSN04pWIugBn1fINyaL(JS34xAASP)u(dBPDqWr6gMAMMyLjNZqq7(9zTVi1Kf0giOPhBk6r1xlmSP5arayRdnaSLGId8lWGotacUnNIdn7VKvkcIHS3mPZRcO9Koxl0fQNgruPs2t)LMV)mzehPU)hjRscNZFBB9SY0Kpr2WPPF8VqgFn5Fz8B)I811rwWWWboYoVn)Td60sBPlWEZL(1xeg2r0HNny1MU03goUdUiACbNocsxuvfOrXVuXE(tjz1VTkDUnxeOerBEqqmog4d5rEExi6SPuOpWq9y3kMFZHgclT6Ze7XG4Q3iRLxhoYQ3E017UDVK9tJwlLn0SYcM7kg)Me2PyRGt)O0za7cVm00VHONfT6LERs)UL4jltvZ3u9KLxYEXcCpyXDVxbSF7G2ZvyDtf5DtfWs3c9AlrYRCf3jga5UTLnMHClcIwbwNEpXpjxyvsU6bQDpk878QFdXRc0xGm4Gv6(3mJPVG7u9ng3aOfAaWUjd5uVv2skKBce4pLqJT4hN3KBW)m7R7LeHHGpRIB(RX0ehAKwiYuLnVUrAOlaVUb4gyId229qBRgapgzBxsY9afTQg1vc)NhLxKRKijsmTMajPiv51nCrWjeA7MpwGcXFoAItP7z)yX)U6wwxIyjyY02p8sS1Xc4V4qs6EL0ggWLuSMMhj)5VWC8ufp2(G7C7uLp2o0myyD0VVBwuVS(c32vt)qFJf)MPHHOXPpH4sLJ0C0HEQpFOTqe5cRQjHRn7zWF25Av1OfDdjCjGC8muHFGMmDLVBBsXZjRTWqljSEgxkvuNzzhNhaVrs2XiR0Bcfge02NTLIRPJhkLwjGmyfmqxw8A28PNx9BU0KQ1nJT0nahaWfWANxGVxB3yibGVaV5QHbUybVzcM)rjlEwY6I63JTt8Y1bosfLqeu0XdvBXaibcoOdh1OJTZLOhNSn2yRqQ3lMUuNa)Hm7wAIlCoOjb9rPl3oYVW(E40HYclXeeV5BLdtS9YX3of6dyuaqyVdPbHkuU03Jv76XwheHDEyRsse9Quuf95cn2wYNOXNHiIz3XTVHEUg1ZaP0BmejTrJBD6YWLhfAVQacexJUsTiRAjP5OatnWnxcJdAuFOjf5nLAazehCwpR9yztVjkaYPdyG0DiZmrogNM8x(jWxcythpR12s6NRmT86iRrKE7LJDKeZHh2cqXxn0D0WXy(x4slT3oprpnLXdTR0r3mhMFsdS49fYbUiLJyTZXeHLuSf5wyIDSs(ewNJTyzT24kJUvXVd)XzeXDIkqyMfud3UmTeWeDVK7NUjaOpFk2IaWx2(Dos98qE4zoYO4hpJNHud8TyvYn86XPlHyzjk8W2aKzsSmR9ut)LGNwnmquJObIx)Sal5fUvhWJqSp29rR0uhY0WaWV3M3mr)3PzmCI35f0Qnherqze1Dgmf4PPhgayolDHstahzEZemKjzEzgnGRKvXBida2xMlS5INxAvVgukHfFk3dSM87S)(FCgT5fLLQ4lwBoHOy8tj0Zv)X410C1GP7cQsTcVoWw5RivPkMAt8zrcRjim0Z1HfuZmO5OaDJKtGxZJFJ27(6RhcAsA3oT5agGxPAzPB9aP7bCR5cSou8zE3HzyuiTC1TmE6ML48IsExTvmDMBLdWArXVo69hlrbNMqLOvs9oldgC5QWqJtrxpV92OjNkSwJGqt5O9OFUWA)rUjduOp2w0ahYss20tFysqeSxswJuT6e(ZT5pvuwV8zCFSSzbrUejouUEyDstoquxXfwehqnJzr4uu4viBppSkTA5CATotNo0Eo9UDOnl6wBu6)C8YTel4fzupXFBwoHzKcQ4S1RtxKLuNsT5k(1hxvmlzLYpjJn6WMz6A)9sFh57wCDN3IAKde41tplSzvnYvyTUYcbgc)9coQB6qOrFv7VPkMQL5iPpz6nUC63CBFprYxbIpciyY3ZHjxt4bLdteQkssQog9co2TrqeVoWcPK1ZRTC7X7DLijcsLFs)bduvJJrqvoOcwa0sfjV6yDEEc2liC31Toew3y3P5eQLWRMFWyb448445tc8cRWWTQTlwKMt87SynvGzETvfrUU7fefvwQcEPvHxhBUrGr6LXsZ3jhhPg148ymXgNB0aCKgXuXoxahhww3uEOYt2zjAI3()uREmg1wGgttkNNKtnnvs81UUvaWimWOXs28r082ucKikU53ooq(UG2JNWUa9qdKNSoBkbQh2wYCCTrVE3VjQz7xoJpTv4R)MgWq5(AWahoEZuIKBtmidUFKwwLwsbM0(H43(xN9dtu(W2pGGZPz)WeYq7hSKduf)p3U4X1TY3SxVvBjVFkYkhuozwQAIATiav(rMo2QwImcqJ)cGs0j5ZtPveZQyAbJX4IcN8vm)s4K(YzqFJJLhqoKEjAxJY8nBxvbEIXeRLm7)c96iPrC61Jb3BEiRmLPiOt4w8t)lJSTjg33nquWCS7QiagurBYJmx0jM7)ufyePdqe0bNA6bg04PWFxVgp5DjYQP0ijZQtxZlc1pNUIhMabPRQJtkNrEEP5R(g9R7x7d493t(fDSuUxuX7yLeUe1h04LA7kI4aO5dB)Moa(Sp39fta85lPVl4tODhQH9yXfbU4IWwCaTh5o0W8dwb4ZaxC6F4faFsFxCn9muJRVT8DHE8Ojs3RzHNRA79bs7UD5vI3SzBAj99aVIoA8YO1YI3U97bEfY7(Sg86aDtEz2pBna(Em)riZpy3SxMd5en)BAUDKpRVZejVZekFp4rzy8zh7a6fWhsRa2whzgPHoQ1EEbK69SPaBR3mJ0Tu1MBa1P2ApWG72cJcQ5zSAvrnFVxnEzdXFCFaqkpdWux40FHpi8xWSGtaVZtgwZTwt5YD5aaUmJNXLhMgklSjwfIenEbmp9qUleo2XVDQIH(dDlmcClm6B)TWqF2cJK1xBzlm0(wiIcJt0wOw(JmedpaMq5eZQXtGMjip2MJghaDf(DF4M9JGebtqmmM0JTuics4lob5UAY)C3)3p]] )