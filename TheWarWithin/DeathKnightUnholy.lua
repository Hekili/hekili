-- DeathKnightUnholy.lua
-- July 2024

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

            start = roundUp( start, 3 )

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
    abomination_limb          = { 76049, 383269, 1 }, -- Sprout an additional limb, dealing 50,684 Shadow damage over 12 sec to all nearby enemies. Deals reduced damage beyond 5 targets. Every 1 sec, an enemy is pulled to your location if they are further than 8 yds from you. The same enemy can only be pulled once every 4 sec.
    antimagic_barrier         = { 76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by 20 sec and increases its duration and amount absorbed by 40%.
    antimagic_zone            = { 76065, 51052 , 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 573,060 damage.
    asphyxiate                = { 76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation              = { 76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and its cooldown is reduced by 30 sec.
    blinding_sleet            = { 76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_draw                = { 76056, 374598, 1 }, -- When you fall below 30% health you drain 10,596 health from nearby enemies, the damage you take is reduced by 10% and your Death Strike cost is reduced by 10 for 8 sec. Can only occur every 2 min.
    blood_scent               = { 76078, 374030, 1 }, -- Increases Leech by 3%.
    brittle                   = { 76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    cleaving_strikes          = { 76073, 316916, 1 }, -- Scourge Strike hits up to 7 additional enemies while you remain in Death and Decay. When leaving your Death and Decay you retain its bonus effects for 4 sec.
    coldthirst                = { 76083, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants 10 Runic Power and reduces its cooldown by 3 sec.
    control_undead            = { 76059, 111673, 1 }, -- Dominates the target undead creature up to level 71, forcing it to do your bidding for 5 min.
    death_pact                = { 76075, 48743 , 1 }, -- Create a death pact that heals you for 50% of your maximum health, but absorbs incoming healing equal to 30% of your max health for 15 sec.
    death_strike              = { 76071, 49998 , 1 }, -- Focuses dark power into a strike that deals 4,099 Physical damage and heals you for 40.00% of all damage taken in the last 5 sec, minimum 11.2% of maximum health.
    deaths_echo               = { 102007, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have 1 additional charge.
    deaths_reach              = { 102006, 276079, 1 }, -- Increases the range of Death Grip by 10 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    enfeeble                  = { 76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by 30% and the damage they deal to you by 15% for 6 sec.
    gloom_ward                = { 76052, 391571, 1 }, -- Absorbs are 15% more effective on you.
    grip_of_the_dead          = { 76057, 273952, 1 }, -- Death and Decay reduces the movement speed of enemies within its area by 90%, decaying by 10% every sec.
    ice_prison                = { 76086, 454786, 1 }, -- Chains of Ice now also roots enemies for 4 sec but its cooldown is increased to 12 sec.
    icebound_fortitude        = { 76081, 48792 , 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 30% for 8 sec.
    icy_talons                = { 76085, 194878, 1 }, -- Your Runic Power spending abilities increase your melee attack speed by 6% for 10 sec, stacking up to 3 times.
    improved_death_strike     = { 76067, 374277, 1 }, -- Death Strike's cost is reduced by 10, and its healing is increased by 60%.
    insidious_chill           = { 76051, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by 5% for 30 sec, stacking up to 4 times.
    march_of_darkness         = { 76074, 391546, 1 }, -- Death's Advance grants an additional 25% movement speed over the first 3 sec.
    mind_freeze               = { 76084, 47528 , 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    null_magic                = { 102008, 454842, 1 }, -- Magic damage taken is reduced by 10% and the duration of harmful Magic effects against you are reduced by 35%.
    osmosis                   = { 76088, 454835, 1 }, -- Anti-Magic Shell increases healing received by 15%.
    permafrost                = { 76066, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to 40% of the damage dealt.
    proliferating_chill       = { 101708, 373930, 1 }, -- Chains of Ice affects 1 additional nearby enemy.
    raise_dead                = { 76072, 46585 , 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts 1 min.
    rune_mastery              = { 76079, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by 3% for 8 sec.
    runic_attenuation         = { 76045, 207104, 1 }, -- Auto attacks have a chance to generate 3 Runic Power.
    runic_protection          = { 76055, 454788, 1 }, -- Your chance to be critically struck is reduced by 3% and your Armor is increased by 6%.
    sacrificial_pact          = { 76060, 327574, 1 }, -- Sacrifice your ghoul to deal 10,296 Shadow damage to all nearby enemies and heal for 25% of your maximum health. Deals reduced damage beyond 8 targets.
    soul_reaper               = { 76063, 343294, 1 }, -- Strike an enemy for 7,085 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 32,509 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    subduing_grasp            = { 76080, 454822, 1 }, -- When you pull an enemy, the damage they deal to you is reduced by 6% for 6 sec.
    suppression               = { 76087, 374049, 1 }, -- Damage taken from area of effect attacks reduced by 3%. When suffering a loss of control effect, this bonus is increased by an additional 6% for 6 sec.
    unholy_bond               = { 76076, 374261, 1 }, -- Increases the effectiveness of your Runeforge effects by 20%.
    unholy_endurance          = { 76058, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground             = { 76069, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    unyielding_will           = { 76050, 457574, 1 }, -- Anti-Magic Shell's cooldown is increased by 20 sec and it now also removes all harmful magic effects when activated.
    vestigial_shell           = { 76053, 454851, 1 }, -- Casting Anti-Magic Shell grants 2 nearby allies a Lesser Anti-Magic Shell that Absorbs up to 37,527 magic damage and reduces the duration of harmful Magic effects against them by 50%.
    veteran_of_the_third_war  = { 76068, 48263 , 1 }, -- Stamina increased by 20%.
    will_of_the_necropolis    = { 76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk               = { 76077, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.

    -- Unholy
    all_will_serve            = { 76181, 194916, 1 }, -- Your Raise Dead spell summons an additional skeletal minion.
    apocalypse                = { 76185, 275699, 1 }, -- Bring doom upon the enemy, dealing 6,864 Shadow damage and bursting up to 4 Festering Wounds on the target. Summons 4 Army of the Dead ghouls for 20 sec. Generates 2 Runes.
    army_of_the_dead          = { 76196, 42650 , 1 }, -- Summons a legion of ghouls who swarms your enemies, fighting anything they can for 30 sec.
    bursting_sores            = { 76164, 207264, 1 }, -- Bursting a Festering Wound deals 20% more damage, and deals 2,491 Shadow damage to all nearby enemies. Deals reduced damage beyond 8 targets.
    clawing_shadows           = { 76183, 207311, 1 }, -- Deals 11,747 Shadow damage and causes 1 Festering Wound to burst.
    coil_of_devastation       = { 76156, 390270, 1 }, -- Death Coil causes the target to take an additional 30% of the direct damage dealt over 4 sec.
    commander_of_the_dead     = { 76149, 390259, 1 }, -- Dark Transformation also empowers your Gargoyle and Army of the Dead for 30 sec, increasing their damage by 35%.
    dark_transformation       = { 76187, 63560 , 1 }, -- Your ghoul deals 6,141 Shadow damage to 5 nearby enemies and transforms into a powerful undead monstrosity for 15 sec. Granting them 100% energy and the ghoul's abilities are empowered and take on new functions while the transformation is active.
    death_rot                 = { 76158, 377537, 1 }, -- Death Coil and Epidemic debilitate your enemy applying Death Rot causing them to take 1% increased Shadow damage, up to 10% from you for 10 sec. If Death Coil or Epidemic consume Sudden Doom it applies two stacks of Death Rot.
    decomposition             = { 76154, 455398, 2 }, -- Virulent Plague has a chance to abruptly flare up, dealing 50% of the damage it dealt to target in the last 4 sec. When this effect triggers, the duration of your active minions are increased by 1.0 sec, up to 3.0 sec.
    defile                    = { 76161, 152280, 1 }, -- Defile the targeted ground, dealing 22,651 Shadow damage to all enemies over 10 sec. While you remain within your Defile, your Scourge Strike will hit 7 enemies near the target. Every sec, if any enemies are standing in the Defile, it grows in size and deals increased damage.
    defile_2                  = { 76180, 152280, 1 }, -- Defile the targeted ground, dealing 22,651 Shadow damage to all enemies over 10 sec. While you remain within your Defile, your Scourge Strike will hit 7 enemies near the target. Every sec, if any enemies are standing in the Defile, it grows in size and deals increased damage.
    doomed_bidding            = { 76176, 455386, 1 }, -- Consuming Sudden Doom calls upon a Magus of the Dead to assist you for 8 sec.
    ebon_fever                = { 76160, 207269, 1 }, -- Diseases deal 15% more damage over time in half the duration.
    eternal_agony             = { 76182, 390268, 1 }, -- Death Coil and Epidemic increase the duration of Dark Transformation by 1 sec.
    festering_scythe          = { 76193, 455397, 1 }, -- Every 20 Festering Wound you burst empowers your next Festering Strike to become Festering Scythe for 12 sec. Festering Scythe
    festering_strike          = { 76189, 85948 , 1 }, -- Strikes for 14,749 Physical damage and infects the target with 2-3 Festering Wounds.  Festering Wound A pustulent lesion that will burst on death or when damaged by Scourge Strike, dealing 3,928 Shadow damage and generating 3 Runic Power.
    festermight               = { 76152, 377590, 2 }, -- Popping a Festering Wound increases your Strength by 1% for 20 sec stacking. Multiple instances may overlap.
    foul_infections           = { 76162, 455396, 1 }, -- Your diseases deal 10% more damage and have a 5% increased chance to critically strike.
    ghoulish_frenzy           = { 76194, 377587, 1 }, -- Dark Transformation also increases the attack speed and damage of you and your Monstrosity by 5%.
    harbinger_of_doom         = { 76178, 276023, 1 }, -- Sudden Doom triggers 30% more often, can accumulate up to 2 charges, and increases the damage of your next Death Coil by 20% or Epidemic by 10%.
    improved_death_coil       = { 76184, 377580, 1 }, -- Death Coil deals 15% additional damage and seeks out 1 additional nearby enemy.
    improved_festering_strike = { 76192, 316867, 2 }, -- Festering Strike and Festering Wound damage increased by 10%.
    infected_claws            = { 76195, 207272, 1 }, -- Your ghoul's Claw attack has a 30% chance to cause a Festering Wound on the target.
    magus_of_the_dead         = { 76148, 390196, 1 }, -- Apocalypse and Army of the Dead also summon a Magus of the Dead who hurls Frostbolts and Shadow Bolts at your foes.
    menacing_magus            = { 101882, 455135, 1 }, -- Your Magus of the Dead Shadow Bolt now fires a volley of Shadow Bolts at up to 4 nearby enemies.
    morbidity                 = { 76197, 377592, 2 }, -- Diseased enemies take 1% increased damage from you per disease they are affected by.
    pestilence                = { 76157, 277234, 1 }, -- Death and Decay damage has a 10% chance to apply a Festering Wound to the enemy.
    plaguebringer             = { 76183, 390175, 1 }, -- Scourge Strike causes your disease damage to occur 100% more quickly for 10 sec.
    raise_abomination         = { 76153, 455395, 1 }, -- Raises an Abomination for 30 sec which wanders and attacks enemies, applying Festering Wound when it melees targets, and affecting all those nearby with Virulent Plague.
    raise_dead_2              = { 76188, 46584 , 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time.
    reaping                   = { 76179, 377514, 1 }, -- Your Soul Reaper, Scourge Strike, Festering Strike, and Death Coil deal 30% additional damage to enemies below 35% health.
    rotten_touch              = { 76175, 390275, 1 }, -- Sudden Doom causes your next Death Coil to also increase your Scourge Strike damage against the target by 50% for 10 sec.
    runic_mastery             = { 76186, 390166, 2 }, -- Increases your maximum Runic Power by 10 and increases the Rune regeneration rate of Runic Corruption by 10%.
    ruptured_viscera          = { 76177, 390236, 1 }, -- When your ghouls expire, they explode in viscera dealing 1,594 Shadow damage to nearby enemies. Each explosion has a 25% chance to apply Festering Wounds to enemies hit.
    scourge_strike            = { 76190, 55090 , 1 }, -- An unholy strike that deals 5,151 Physical damage and 4,412 Shadow damage, and causes 1 Festering Wound to burst.
    sudden_doom               = { 76191, 49530 , 1 }, -- Your auto attacks have a 25% chance to make your next Death Coil or Epidemic cost 10 less Runic Power and critically strike. Additionally, your next Death Coil will burst 1 Festering Wound.
    summon_gargoyle           = { 76176, 49206 , 1 }, -- Summon a Gargoyle into the area to bombard the target for 25 sec. The Gargoyle gains 1% increased damage for every 1 Runic Power you spend. Generates 50 Runic Power.
    superstrain               = { 76155, 390283, 1 }, -- Your Virulent Plague also applies Frost Fever and Blood Plague at 80% effectiveness.
    unholy_assault            = { 76151, 207289, 1 }, -- Strike your target dealing 17,517 Shadow damage, infecting the target with 4 Festering Wounds and sending you into an Unholy Frenzy increasing all damage done by 20% for 20 sec.
    unholy_aura               = { 76150, 377440, 2 }, -- All enemies within 8 yards take 10% increased damage from your minions.
    unholy_blight             = { 76163, 460448, 1 }, -- Dark Transformation surrounds your ghoul with a vile swarm of insects for 6 sec, stinging all nearby enemies and infecting them with Virulent Plague and an unholy disease that deals 4,803 damage over 14 sec, stacking up to 4 times.
    unholy_pact               = { 76180, 319230, 1 }, -- Dark Transformation creates an unholy pact between you and your pet, igniting flaming chains that deal 30,810 Shadow damage over 15 sec to enemies between you and your pet.
    vile_contagion            = { 76159, 390279, 1 }, -- Inflict disease upon your enemies spreading Festering Wounds equal to the amount currently active on your target to 7 nearby enemies.

    -- Rider of the Apocalypse
    a_feast_of_souls          = { 95042, 444072, 1 }, -- While you have 2 or more Horsemen aiding you, your Runic Power spending abilities deal 30% increased damage.
    apocalypse_now            = { 95041, 444040, 1 }, -- Army of the Dead and Frostwyrm's Fury call upon all 4 Horsemen to aid you for 20 sec.
    death_charge              = { 95060, 444010, 1 }, -- Call upon your Death Charger to break free of movement impairment effects. For 10 sec, while upon your Death Charger your movement speed is increased by 100%, you cannot be slowed, and you are immune to forced movement effects and knockbacks.
    fury_of_the_horsemen      = { 95042, 444069, 1 }, -- Every 50 Runic Power you spend extends the duration of the Horsemen's aid in combat by 1 sec, up to 5 sec.
    horsemens_aid             = { 95037, 444074, 1 }, -- While at your aid, the Horsemen will occasionally cast Anti-Magic Shell on you and themselves at 80% effectiveness. You may only benefit from this effect every 45 sec.
    hungering_thirst          = { 95044, 444037, 1 }, -- The damage of your diseases and Death Coil are increased by 15%.
    mawsworn_menace           = { 95054, 444099, 1 }, -- Scourge Strike deals 15% increased damage and the cooldown of your Death and Decay is reduced by 10 sec.
    mograines_might           = { 95067, 444047, 1 }, -- Your damage is increased by 5% and you gain the benefits of your Death and Decay while inside Mograine's Death and Decay.
    nazgrims_conquest         = { 95059, 444052, 1 }, -- If an enemy dies while Nazgrim is active, the strength of Apocalyptic Conquest is increased by 3%. Additionally, each Rune you spend increase its value by 1%.
    on_a_paler_horse          = { 95060, 444008, 1 }, -- While outdoors you are able to mount your Acherus Deathcharger in combat.
    pact_of_the_apocalypse    = { 95037, 444083, 1 }, -- When you take damage, 5% of the damage is redirected to each active horsemen.
    riders_champion           = { 95066, 444005, 1, "rider_of_the_apocalypse" }, -- Spending Runes has a chance to call forth the aid of a Horsemen for 10 sec. Mograine Casts Death and Decay at his location that follows his position. Whitemane Casts Undeath on your target dealing 1,745 Shadowfrost damage per stack every 3 sec, for 24 sec. Each time Undeath deals damage it gains a stack. Cannot be Refreshed. Trollbane Casts Chains of Ice on your target slowing their movement speed by 40% and increasing the damage they take from you by 5% for 8 sec. Nazgrim While Nazgrim is active you gain Apocalyptic Conquest, increasing your Strength by 5%.
    trollbanes_icy_fury       = { 95063, 444097, 1 }, -- Scourge Strike shatters Trollbane's Chains of Ice when hit, dealing 32,947 Shadowfrost damage to nearby enemies, and slowing them by 40% for 4 sec. Deals reduced damage beyond 8 targets.
    whitemanes_famine         = { 95047, 444033, 1 }, -- When Scourge Strike damages an enemy affected by Undeath it gains 1 stack and infects another nearby enemy.

    -- San'layn
    bloodsoaked_ground        = { 95048, 434033, 1 }, -- While you are within your Death and Decay, your physical damage taken is reduced by 5% and your chance to gain Vampiric Strike is increased by 5%.
    bloody_fortitude          = { 95056, 434136, 1 }, -- Icebound Fortitude reduces all damage you take by up to an additional 20% based on your missing health. Killing an enemy that yields experience or honor reduces the cooldown of Icebound Fortitude by 3 sec.
    frenzied_bloodthirst      = { 95065, 434075, 1 }, -- Essence of the Blood Queen stacks 2 additional times and increases the damage of your Death Coil and Death Strike by 2% per stack.
    gift_of_the_sanlayn       = { 95053, 434152, 1 }, -- While Vampiric Blood or Dark Transformation is active you gain Gift of the San'layn. Gift of the San'layn increases the effectiveness of your Essence of the Blood Queen by 100%, and Vampiric Strike replaces your Scourge Strike for the duration.
    incite_terror             = { 95040, 434151, 1 }, -- Vampiric Strike and Scourge Strike cause your targets to take 1% increased Shadow damage, up to 5% for 15 sec. Vampiric Strike benefits from Incite Terror at 400% effectiveness.
    infliction_of_sorrow      = { 95033, 434143, 1 }, -- When Vampiric Strike damages an enemy affected by your Virulent Plague, it extends the duration of the disease by 3 sec, and deals 10% of the remaining damage to the enemy. After Gift of the San'layn ends, your next Scourge Strike consumes the disease to deal 100% of their remaining damage to the target.
    newly_turned              = { 95064, 433934, 1 }, -- Raise Ally revives players at full health and grants you and your ally an absorb shield equal to 20% of your maximum health.
    pact_of_the_sanlayn       = { 95055, 434261, 1 }, -- You store 50% of all Shadow damage dealt into your Blood Beast to explode for additional damage when it expires.
    sanguine_scent            = { 95055, 434263, 1 }, -- Your Death Coil, Epidemic and Death Strike have a 15% increased chance to trigger Vampiric Strike when damaging enemies below 35% health.
    the_blood_is_life         = { 95046, 434260, 1 }, -- Vampiric Strike has a chance to summon a Blood Beast to attack your enemy for 10 sec. Each time the Blood Beast attacks, it stores a portion of the damage dealt. When the Blood Beast dies, it explodes, dealing 25% of the damage accumulated to nearby enemies and healing the Death Knight for the same amount.
    vampiric_aura             = { 95056, 434100, 1 }, -- Your Leech is increased by 2%. While Lichborne is active, the Leech bonus of this effect is increased by 100%, and it affects 4 allies within 12 yds.
    vampiric_speed            = { 95064, 434028, 1 }, -- Death's Advance and Wraith Walk movement speed bonuses are increased by 10%. Activating Death's Advance or Wraith Walk increases 4 nearby allies movement speed by 20% for 5 sec.
    vampiric_strike           = { 95051, 433901, 1, "sanlayn" }, -- Your Death Coil, Epidemic and Death Strike have a 10% chance to make your next Scourge Strike become Vampiric Strike. Vampiric Strike heals you for 2% of your maximum health and grants you Essence of the Blood Queen, increasing your Haste by 1.0%, up to 5.0% for 20 sec.
    visceral_strength         = { 95045, 434157, 1 }, -- When Sudden Doom is consumed, you gain 5% Strength for 5 sec.
} )


-- PvP Talents
me:RegisterPvpTalents( {
    bloodforged_armor    = 5585, -- (410301) Death Strike reduces all Physical damage taken by 20% for 3 sec.
    dark_simulacrum      = 41  , -- (77606) Places a dark ward on an enemy player that persists for 12 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    doomburst            = 5436, -- (356512) Sudden Doom also causes your next Death Coil to burst up to 2 Festering Wounds and reduce the target's movement speed by 45% per burst. Lasts 3 sec.
    life_and_death       = 40  , -- (288855) When targets afflicted by your Virulent Plague are healed, you are also healed for 5% of the amount. In addition, your Virulent Plague now erupts for 400% of normal eruption damage when dispelled.
    necromancers_bargain = 3746, -- (288848) The cooldown of your Apocalypse is reduced by 15 sec, but your Apocalypse no longer summons ghouls but instead applies Crypt Fever to the target. Crypt Fever Deals up to 8% of the targets maximum health in Shadow damage over 4 sec. Healing spells cast on this target will refresh the duration of Crypt Fever.
    necrotic_aura        = 3437, -- (199642) All enemies within 8 yards take 4% increased magical damage.
    necrotic_wounds      = 149 , -- (356520) Bursting a Festering Wound converts it into a Necrotic Wound, absorbing 3% of all healing received for 15 sec and healing you for the amount absorbed when the effect ends, up to 3% of your max health. Max 6 stacks. Adding a stack does not refresh the duration.
    reanimation          = 152 , -- (210128) Reanimates a nearby corpse, summoning a zombie for 20 sec that slowly moves towards your target. If your zombie reaches its target, it explodes after 3.0 sec. The explosion stuns all enemies within 8 yards for 3 sec and deals 10% of their health in Shadow damage.
    rot_and_wither       = 5511, -- (202727) Your Death and Decay rots enemies each time it deals damage, absorbing healing equal to 100% of damage dealt.
    spellwarden          = 5590, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by 10 sec.
    strangulate          = 5430, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for 5 sec.
} )


-- Auras
me:RegisterAuras( {
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
        id = 108194,
        duration = 4.0,
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
        duration = function() return 24 * ( talent.ebon_fever.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.ebon_fever.enabled and 0.5 or 1 ) * ( buff.plaguebringer.up and 0.5 or 1 ) end,
        max_stack = 1,
        copy = "blood_plague_superstrain"
    },
    -- Physical damage taken reduced by $s1%.; Chance to gain Vampiric Strike increased by $434033s2%.
    bloodsoaked_ground = {
        id = 434034,
        duration = 3600,
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
    chains_of_ice_trollbane_slow = {
        id = 444826,
        duration = 8,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    chains_of_ice_trollbane_damage = {
        id = 444828,
        duration = 8,
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
    -- Inflicts $s1 Shadow damage every sec.
    death_and_decay = {
        id = 391988,
        duration = 3600,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- mastery_dreadblade[77515] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- mastery_dreadblade[77515] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 1.8, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- blood_death_knight[137008] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 48.2, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- death_rot[377540] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
    death_rot = {
        id = 377540,
        duration = 10,
        max_stack = 2,
    },
    -- Your movement speed is increased by $w1%, you cannot be slowed below $s2% of normal speed, and you are immune to forced movement effects and knockbacks.
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
    -- Haste increased by ${$W1}.1%. $?a434075[Damage of Death Strike and Death Coil increased by $W2%.][]
    essence_of_the_blood_queen = {
        id = 433925,
        duration = 20.0,
        max_stack = function() return 1 + ( talent.frenzied_bloodthirst.enabled and 2 or 0 ) end,
    },
    festering_scythe = {
        id = 458123,
        duration = 15,
        max_stack = 1,
        copy = "festering_scythe_buff"
    },
    festering_scythe_stacking_buff = {
        id = 459238,
        duration = 3600,
        max_stack = 20,
        copy = "festering_scythe_stack"
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
        duration = function() return 24 * ( talent.ebon_fever.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.ebon_fever.enabled and 0.5 or 1 ) * ( buff.plaguebringer.up and 0.5 or 1 ) end,
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
    gift_of_the_sanlayn = {
        id = 434153,
        duration = 10,
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
        max_stack = 1
    },
    -- Attack speed increased by $w1%$?a436687[, and Runic Power spending abilities deal Shadowfrost damage.][.]
    icy_talons = {
        id = 194879,
        duration = 6,
        max_stack = 3
    },
    -- Taking $w1% increased Shadow damage from $@auracaster.
    incite_terror = {
        id = 458478,
        duration = 15.0,
        max_stack = 1,
    },
    infliction_of_sorrow = {
        id = 460049,
        duration = 15,
        max_stack = 1
    },
    -- Time between auto-attacks increased by $w1%.
    insidious_chill = {
        id = 391568,
        duration = 30,
        max_stack = 4
    },
    -- Absorbing up to $w1 magic damage.; Duration of harmful magic effects reduced by $s2%.
    lesser_antimagic_shell = {
        id = 454863,
        duration = function() return 5.0 * ( taletn.antimagic_barrier.enabled and 1.4 or 1 ) end,
        max_stack = 1,
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
    -- Damage dealt increased by $s1%.; Healing received increased by $s2%.
    sanguine_ground = {
        id = 391459,
        duration = 3600,
        max_stack = 1,
    },
    -- Talent: Afflicted by Soul Reaper, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage.
    -- https://wowhead.com/beta/spell=343294
    soul_reaper = {
        id = 448229,
        duration = 5,
        tick_time = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Silenced.
    strangulate = {
        id = 47476,
        duration = 5,
        max_stack = 1
    },
    -- Damage dealt to $@auracaster reduced by $w1%.
    subduing_grasp = {
        id = 454824,
        duration = 6.0,
        max_stack = 1,
    },
    -- Your next Death Coil$?s207317[ or Epidemic][] cost ${$s1/-10} less Runic Power and is guaranteed to critically strike.
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
    -- Damage taken from area of effect attacks reduced by an additional $w1%.
    suppression = {
        id = 454886,
        duration = 6.0,
        max_stack = 1,
    },
    -- Movement slowed $w1%.
    trollbanes_icy_fury = {
        id = 444834,
        duration = 4.0,
        max_stack = 1,
    },
    -- Suffering $w1 Shadowfrost damage every $t1 sec.; Each time it deals damage, it gains $s3 $Lstack:stacks;.
    undeath = {
        id = 444633,
        duration = 24.0,
        tick_time = 3.0,
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
        dot = "buff",

        generate = function ()
            local ub = buff.unholy_blight_buff
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 115989 )

            if name then
                ub.name = name
                ub.count = count
                ub.expires = expires
                ub.applied = expires - duration
                ub.caster = caster
                return
            end

            ub.count = 0
            ub.expires = 0
            ub.applied = 0
            ub.caster = "nobody"
        end,
    },
    -- Suffering $s1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=115994
    unholy_blight = {
        id = 115994,
        duration = 14,
        tick_time = function() return 2 * ( buff.plaguebringer.up and 0.5 or 1 ) end,
        max_stack = 4,
        copy = { "unholy_blight_debuff", "unholy_blight_dot" }
    },
    -- Haste increased by $w1%.
    unholy_ground = {
        id = 374271,
        duration = 3600,
        max_stack = 1,
    },
    -- Deals $s1 Fire damage.
    unholy_pact = {
        id = 319240,
        duration = 0.0,
        max_stack = 1,
    },
    -- Strength increased by $s1%.
    -- https://wowhead.com/beta/spell=53365
    unholy_strength = {
        id = 53365,
        duration = 15,
        max_stack = 1
    },
    -- Vampiric Aura's Leech amount increased by $s1% and is affecting $s2 nearby allies.
    vampiric_aura = {
        id = 434105,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    vampiric_speed = {
        id = 434029,
        duration = 5.0,
        max_stack = 1,
    },
    vampiric_strike = {
        id = 433899,
        duration = 3600,
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.  Erupts for $191685s1 damage split among all nearby enemies when the infected dies.
    -- https://wowhead.com/beta/spell=191587
    virulent_plague = {
        id = 191587,
        duration = function () return 27 * ( talent.ebon_fever.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.ebon_fever.enabled and 0.5 or 1 ) * ( buff.plaguebringer.up and 0.5 or 1 ) end,
        type = "Disease",
        max_stack = 1,
        copy = 441277,
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

me:RegisterGear( "tier31", 207198, 207199, 207200, 207201, 207203, 217223, 217225, 217221, 217222, 217224 )
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

    if talent.vampiric_strike.enabled and IsActiveSpell( 433899 ) then applyBuff( "vampiric_strike" ) end

    if buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up then
        class.abilities.wound_spender = class.abilities.vampiric_strike
        cooldown.wound_spender = cooldown.vampiric_strike
    elseif state:IsKnown( "clawing_shadows" ) then
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
        cooldown = function() return 60 - ( talent.antimagic_barrier.enabled and 20 or 0 ) - ( talent.unyielding_will.enabled and -20 or 0 ) - ( pvptalent.spellwarden.enabled and 10 or 0 ) end,
        gcd = "off",

        startsCombat = false,

        toggle = function()
            if settings.dps_shell then return end
            return "defensives"
        end,

        handler = function ()
            applyBuff( "antimagic_shell" )
            if talent.unyielding_will.enabled then removeBuff( "dispellable_magic" ) end
        end,
    },

    -- Talent: Places an Anti-Magic Zone that reduces spell damage taken by party or raid me...
    antimagic_zone = {
        id = 51052,
        cast = 0,
        cooldown = function() return 120 - ( talent.assimilation.enabled and 30 or 0 ) end,
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
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( ( pvptalent.necromancers_bargain.enabled and 45 or 60 ) - ( level > 48 and 15 or 0 ) ) end,
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
        id = function () return talent.raise_abomination.enabled and 455395 or 42650 end,
        cast = 0,
        cooldown = function () return talent.raise_abomination.enabled and 90 or 180 end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "army_of_the_dead",
        startsCombat = false,
        texture = function () return talent.raise_abomination.enabled and 298667 or 237511 end,

        toggle = "cooldowns",

        handler = function ()
            if set_bonus.tier30_4pc > 0 then addStack( "master_of_death", nil, 20 ) end

            if pvptalent.raise_abomination.enabled then
                summonPet( "abomination" )
            else
                applyBuff( "army_of_the_dead", 4 )
                summonPet( "army_ghoul", 30 )
            end
        end,

        copy = { 455395, 42650, "army_of_the_dead", "raise_abomination" }
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
        cooldown = function() return talent.ice_prison.enabled and 12 or 0 end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "chains_of_ice",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "chains_of_ice" )
            if talent.ice_prison.enabled then applyDebuff( "target", "ice_prison" ) end
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
        nobuff = "vampiric_strike",

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

            if buff.infliction_of_sorrow.up then
                removeDebuff( "target", "virulent_plague" )
                removeBuff( "infliction_of_sorrow" )
            end
            -- gain( 3, "runic_power" ) -- ?
        end,

        bind = { "scourge_strike", "wound_spender", "vampiric_strike" }
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
        cooldown = 45,
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

            if talent.commander_of_the_dead.enabled then
                applyBuff( "commander_of_the_dead" ) -- 10.0.7
                applyBuff( "commander_of_the_dead_window" ) -- 10.0.5
            end

            if talent.unholy_blight.enabled then
                applyBuff( "unholy_blight_buff" )
                applyDebuff( "target", "unholy_blight" )
                applyDebuff( "target", "virulent_plague" )
                active_dot.virulent_plague = active_enemies

                if talent.superstrain.enabled then
                    applyDebuff( "target", "blood_plague_superstrain" )
                    applyDebuff( "target", "frost_fever_superstrain" )
                end
            end

            if talent.unholy_pact.enabled then applyBuff( "unholy_pact" ) end

            if talent.gift_of_the_sanlayn.enabled then applyBuff( "gift_of_the_sanlayn" ) end

            if azerite.helchains.enabled then applyBuff( "helchains" ) end
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
            return 30 - ( buff.sudden_doom.up and 10 or 0 ) - ( legendary.deadliest_coil.enabled and 10 or 0 ) end,
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
            return ( level > 27 and 35 or 45 ) - ( talent.improved_death_strike.enabled and 10 or 0 ) - ( buff.blood_draw.up and 10 or 0 )
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

    -- Defile the targeted ground, dealing ${($156000s1*($d+1)/$t3)} Shadow damage to all enemies over $d.; While you remain within your Defile, your $?s207311[Clawing Shadows][Scourge Strike] will hit ${$55090s4-1} enemies near the target$?a315442|a331119[ and inflict Death's Due for $324164d.; Death's Due reduces damage enemies deal to you by $324164s1%, up to a maximum of ${$324164s1*-$324164u}% and their power is transferred to you as an equal amount of Strength.][.]; Every sec, if any enemies are standing in the Defile, it grows in size and deals increased damage.
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

        spend = function () return 30 - ( buff.sudden_doom.up and 10 or 0 ) end,
        spendType = "runic_power",

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
        id = function() return buff.festering_scythe.up and 458128 or 85948 end,
        known = 85948,
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
            removeBuff( "festering_scythe" )
            applyDebuff( "target", "festering_wound", nil, debuff.festering_wound.stack + 2 )
        end,

        copy = { 85948, 458128 }
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
        gcd = function() return IsActiveSpell( 46584 ) and "spell" or "off" end,

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
        nobuff = function()
            if buff.gift_of_the_sanlayn.up then return "gift_of_the_sanlayn" end
            return "vampiric_strike"
        end,

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

            if buff.infliction_of_sorrow.up then
                removeDebuff( "target", "virulent_plague" )
                removeBuff( "infliction_of_sorrow" )
            end

            if conduit.lingering_plague.enabled and debuff.virulent_plague.up then
                debuff.virulent_plague.expires = debuff.virulent_plague.expires + ( conduit.lingering_plague.mod * 0.001 )
            end
        end,

        bind = { "clawing_shadows", "wound_spender", "vampiric_strike" }
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

    -- A vampiric strike that deals $?a137007[$s1][$s5] Shadow damage and heals you for $?a137007[$434422s2][$434422s3]% of your maximum health.; Additionally grants you Essence of the Blood Queen for $433925d.
    vampiric_strike = {
        id = 433895,
        flash = 55090,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = 1,
        spendType = 'runes',

        startsCombat = true,
        buff = function()
            if buff.gift_of_the_sanlayn.up then return "gift_of_the_sanlayn" end
            return "vampiric_strike"
        end,

        handler = function ()
            removeBuff( "vampiric_strike" )
            gain( 0.01 * health.max, "health" )
            applyBuff( "essence_of_the_blood_queen" ) -- TODO: mod haste

            if buff.vampiric_strike.down and buff.gift_of_the_sanlayn.down then
                if state:IsKnown( "clawing_shadows" ) then
                    class.abilities.wound_spender = class.abilities.clawing_shadows
                    cooldown.wound_spender = cooldown.clawing_shadows
                else
                    class.abilities.wound_spender = class.abilities.scourge_strike
                    cooldown.wound_spender = cooldown.scourge_strike
                end
            end

            if talent.infliction_of_sorrow.enabled and dot.virulent_plague.ticking then
                dot.virulent_plague.expires = dot.virulent_plague.expires + 3
                applyBuff( "infliction_of_sorrow" ) -- TODO: Apply on Gift of the San'layn expiry?
            end
        end,

        bind = { "scourge_strike", "clawing_shadows", "wound_spender" }
    },

    --[[ Talent: Surrounds yourself with a vile swarm of insects for $d, stinging all nearby e...
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

            if talent.superstrain.enabled then
                applyDebuff( "target", "blood_plague_superstrain" )
                applyDebuff( "target", "frost_fever_superstrain" )
            end
        end,
    }, ]]

    -- Talent: Inflict disease upon your enemies spreading Festering Wounds equal to the amount currently active on your target to $s1 nearby enemies.
    vile_contagion = {
        id = 390279,
        cast = 0,
        cooldown = 45,
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
    nameplateRange = 10,
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


me:RegisterPack( "Unholy", 20240905, [[Hekili:S3ZAVTnUY(Bj4I6A3hUwkjTzxKeGDxSxGtXIEaUzp373ISSKCSUvwYhj52nlc8V9lFij(qdFizPK2EZx2TXKA4mdhoZWzgsERZT)5T3e6xgD7NCx4E2IFAX5ZDCC(WIF62BkVFx0T3SZp4Z(3H(hP(Br)3)v6MSK7X)89jz(H4pViBFEaQPnLL7k(539U7Il3SF18GSTVRiE7(e)Y4S0GC)1L4)o4D3EZQ9XjL)J0Bxbp2FabZDrbOF(CxeyJddJO9nQi42BW99TlU4TUx8Mdlx8tVDX5)8HL3eV93oSC)om4o8XdFSUtl(aPtO)JJdQB)lshcpSCxECwEC59hwUopBB1338DF4TUNI69FUj6WY)h)C0)brsXP3EtsCrzbMM9ZI8kIk3Vd9hFIWeJs9xLefE7VIAmatXO)F69EHPHueppEh9x)LSFhnEKV9g0VwgLh7F7nNCyzyKF5gp)0qVWOa)7Nxgh85407oSCYHLtpSe1Js)KO0Y5R2NxuIAXRilpQyE1it6hRtFjojYlilT0)o0WY60dpupsFon(UnLZx)1S9PHrHEL(53fvwCy51xDyzW9bOVpknABCuH1F1f0EM7hh6f9fmA4hgIWW)cZ3iiOCt5rB9JtrTD5v45i9956dlp)WYz3wIenuWZjOLhs8bHC58m4WOv7xVEEWgmO8Yw7fhe5vMNLKSYpfnzMK91573rgFB6kdVpS8UGW5B9)l0OryAvCeSCbcrpvbIUoQaJz4zXY84phXJRbzzjHzFnvEsKFqp36jfPPsgbYqbY3nVOeTwNotCgf6sDRi4(Ynri0areWu7zsuRGa(x8r)lulZ3HOpm8Y3Ngh4Tl7Rr5e8ImCf7XR39cZY2wps18SODXHiQiapsNFm8v)Dzb(j3VRicAI0cEeIfTWQjGlL4)WST33x2giVbp3ew4H0rPt7KOSfaE1EXJcMX1ubgQAkDlERKQorRgI1yoPN0Nntf47IQf8yZebOkNfM)pLtQxwBSOUb9CIzu40mXHrNkkYcGGGX7LSz8PS03ImN8Ye)7rqGyb53QiKcDAd3tSw75xu4VpPKFgvjUn1e6HPrxsxTrn1Pnt5gSlnZo1N2rbgXSRBuGAgZyRYbSnlitj3ljgXm2etOF(NrMu8tlwNLVL4HKE1NHzyemFpgt92L4F3(icsWOCQnHQzqGENhTg5TWgmSPODfzVnlFvCiYxizhjicb3fVUeBceP33RWpflawVuO67l2Vlc5pcA1xQaeW4aY5QIsV1OfL5IJFv7RsYYcbrWzTD7PsyEvcrvRW0J(EWlQcW4zttadkISkI88xLTnoL2BObwtV4h82DJn0mzJS9LRqg((SoRCmdywTKazXiIQh80UAaccMC4bJw8sI3UQY6tsK)x0A8b214FJ(Dw5wmKApRnBYl)gVDxE2xIWGhpqbzXj1ZECRxBAtVsjBg3t62qZ70JS(bBC6reL2rvMBLFG93nWXW5mMGiQDVY4T17nYmv0BzEg)s1omA82cP4kpkuNm)USAzjor(BiFgV5Co8a)LFHZ1DSPxN26Ok2VDlA93DiQl7EewlOHQHTk3lEBHVFbNYpQ7pa6jR07F6ckMOSFnqgp(7IqUJLV9EV72KTpzoLKiWrQfb31oDb3xJNVH)AwlQ)AoTTYFoKI46VVYhUvzfGULs7MELqt5eAli2HttBCAawxDZKq1uBq22T(ybTABWinfH9WY2La(7yg2kK)mXAqCMZ5u1JNI5gb9kq7hpZe6Sqp6O2TR(HoCRJGzY4vsd1KbJ0KwHJC)h5Tr261EO91QqXm)w842hR)w02hxvG8m0d5CxacbjQjwu7mbZE2L0vlmFmqBoG3mpspnYD6aK6XOKeQ2sd7lvocoh12sPAl1THoZXutRHPRHnmjhZV)5VFu(Ra7nGQql9nxmW6JBl9ZDGhnVvm60HRDoDy7CMrzCtsPnX2QHf9f)T7IZXRnjuhLd1S1mOnBseSbOkeFfbI0phrcoERv2clf(ZQoEyjFqnQtVW67Z9tWRtjQary0282Cee2TfBSdjvw3F5GLlRSKz)RLAu0uLJrli8HGsLxfA82ruxV(DlY6NSPkPTEgVnIG(oNlyfqjlutCIkXZ9BIYZ2xqDHyBCzPixFQk7DcwcfSroRBoOCATqGkSrJkVkXphqV4RA0ZXdl3xuppANp0a91W8IPojSyvUx8lzRW75LoZzmX95eo3HLVczpE(5o8XNQY6DyCbEO88Zkh6WuypwnJJ15Uq0qjBcH9HTDP3sN91cve64m3LYeWyHXpWKMuPSeODVsvoMkk7WGPGudK3DU1CrBgLESpRoW761oPSe(ZeKr1TqepunniHcT3xRTJV17s(c(Dj3c0SuktTjtOP61kUS1kc7o(eH(SXVWRUFKHsorcqKbwsrYG1eQTm0ocsYk5uoQXvSQ(4QvbQ73RkqD)MubQESYgfOUJIcu3UQa19zfOM4DdLcui4)yQavf9n0kqDLuG6yHcuh7vG62hfOU62SiKhONaQ6wqhAt7H(B9VdVf7rYAI4wq0jKyJE6jwUFg7hvBgsBZmN1giCxm8Q3Dzbp2okFi53tSD)wTjEDOOvRUDxuJNGQzmhMwNZH8yrvetG8ybAbNBpwWneAFEAeaSFuTziFEbxxqZV)xW5sdMxHFQ364In449Pnj(Ir3xkZMn1R0)zfOgKSnCMHKUDI(W9FIIGFIRgxgDrlobTjQQvTkkMpb8pff6Tkomer61ZTQkOa1jGIgN15BI8tk3mFhoaTKupEo0ukUQM4sheYzvuB(7OHotDQFSHNiIVQtD(ut5Jh7T1Phw(wTUeBky2Wb)VwG3eTiNb)p9bnzfZqy(1rkAYKaFrAIRRkDlZGQvmvl1KknqBQnifRw0fU4wLoQL8RNlu0rOqrTPQjRN4E6Rh03lBOUJ1dQ2u1)Czp2RYESkhsVRjAtKT2RJorO5RB31OvipvOuTHEsj9vyHjPopdKh8yvfMFRXjyRC)(VOqlk1zKJ3zfjJBiwdEPXFI2TwPCwJpghL06gP4sR7YjA8G0uOq9)uLrJvx0aRBRTV8D070t0xpjeuKL0wSNqE57mVFHfD3bwJEqDg3YDoCMvOQnwAHRPdbMdGJwAC8fy404L4aCiDezAQD7ufRWOlbe)kutd0QVYJuSt6wn2uLrahDXFL8XwS9bw9KiOlxvLwXPixtXyf2TJBLLFdDzg7JijH5mM7XTotACsLaTrjzsR(iZa(feFjWQ4kAk9VQ5rkULJCkGFHMqX60QNS1oolQStOXzDtvwKHQbZohmL2xCRvQ8B)cAnQQ0sAc51xwuk3nOPIbR96agUPjKKhrbJDLYkgtwlHkwdyzzHJKtvSD6sPz9Czz1Y9rBcAirf2ZLL1TAtkMPmIrv2P(4hOSDEK2uHFSy(hoTEaFUsogjEUBF55dr6x(Ei5V8ei2jHgDhle2IHQGr0Mf0ckTZ2(Z5z28qABShM8CAVmza57I0Eng5zMFr0aS2gakDBT9qOt9PrwZ(r1MH8512Dbn)(FTTllxBdyE264X1f2r8kffvZBa114eTbr8eTFRzwLRHmPRdPhehgDCTenvL)kTbIqj6Bo0bN2jKIlS7AClVja(TJznwPUxzMxymv3oCASyEN(yFxGqyxXPRtIj0cnww55SdlyZQ)Fysj2tyoOuK4t1rXUhQDm59bxxGdVj3kOTewSvz9(sMFiwGbak3DnLKPWO1end1Q5R7nQRHEiHQO)oskwEY6)eVqs8tsoS8xcO7v8pi3(FnWeTOpXJ(hE4lgq61dOhnyj1S(c9kPQKAKJpzDFVb)3bLKJ9SvdRq8(0MxgMG9Gn48dSQDkRfa5(bX(jf68gx73ZDpCOn9k6jCIWh0Ik3UZs4lXh0NDr)NogbScJr)0qYKWkE6h2uXFCwmWmOEJreSr2tr16C758a9(oc)fQDddAo)0Av0YzFMpE7mlDAUwY4tPRwCLDJNIrx1A0uJUtnCnQXLLlGQPsBk8WdY0wP(JEuQQRKIUo5Wsuk(JuRiTpZp2JcKb3EB)nM(hAD7ydlvSc15bxj2yCXBpqOsQf)D5rbzBx532Mp1hl8EGnyYV(dAD1WWaojWl3EJlK18SDiSjQKbNAB)4)vYEMHX6aQGVwwWc7TIitCX8TXihRjxcmRrwdl3NJfZZ2sC3Ua6duMJiewiAxUo6Zq(f0bAWvhn42vAWTJ0GlJgKxvurdXRHPI2CJ6Saiy1B0MnqCrVOKcrXbmXWHhv8A6oZLxN1r6Zvp9n4Zua0NRw6t2)SosFoEf3NgCBhYSO(iTucezuwEIEbCrPZ6Wvn3iWvdd0(l734bbj5bEwVLgrMiBMyCGCsTJZlUMNxKdvUDZlGhx6rCEX441N5f7xf1AEr2v9ooVuNnGB7qoknoZjAuODMcen8jKDwCxmb)PMMoENH07oJ4f4u8bv(Cs93Q0mwtpbGhwGMhw1vYRi6fN8LeYPbHFri53MrquNfloWkX5RBbbq9aqeOJveOSVgQjqhRiqhac0vjbkkl7Wu9dUnplfLvKFRUirBkZDTinS78s8aD0wjlkg6o5C5b4sSRezOfPsskOt)xvFphvjFi4CBoBCr0)gYTwHIeIS5kAqwxVp)EojSxt2UcMmHVfaMOpxmtTkfv4EAvcGeUjs7XvYWvMjvmU0VBkdBGm02bD52dlWMFnLdeJJmtWI1f9XDSrIikVikhJg)4lrOMupwjc9qEmLiunYCsenDrF8GjWRkTjO9IhLEx5gUdZaBgLpQ)cZMTYjaFCMGs1vZhjpSM(qUYQKKGNcV)39H3TfRkfyFHcs9ox8dLKTZfhJ0B9xposOoxWzWlnicNzWepCqDG2DR(aQ52mbGT5npmADCqCjTTZRTfwBIuSzcxULP3D7tO5RvDwcQ1rUoopIOx9hEvKQP0(lJzbGhhXpTdmtEOPh6ZpJmo2eAZPk0HT38XPsSaXx5Fhj4J54m5FBDrROZlsZfSI47gJ(ZfoqvEaTZAEc4c2g9uVfEvZWwDrIFm1OIjSV5q28k(Ss3dkHkRstFH(7ymlROKJTmx4029JtTPOQ6sMAOatWGWyfMmRTFoMlYe1NDxzy9yv7ikMGeNaE1HQhJOUvMjglMe9heoGIfP1VxxcwaAwa96u0MhKbiGN9affl3Kou8k6Q)qJLOsvM068JJd7CqNtoi0qhcAdzewuYg4qnBxXrDPXtpTg5bstqv9dVwKPSO1cEp6iUSjRSenoLz7d2imLI7dlejcYQuVfdYYZ3VRsjnNDvlFSFiqkQOic5CBn1q1Y8V3hfjDkQyeF7RMgbYbI3WphP1oJU2bS9XO5wN25(ELe19c7QN3ArtnUGT(SLBYrGgnBq3MqtTEIXeLlQgsl0MbO6mM)00wzwZOclhT30sgo48FpElp1BaRzPGTNtF4Rzb7pO3tbmKAvDvYDCN513ntLkn1BZXW4O9YfqtTKzGpPaplzoDaUpiUSgy3g1or91cfH3j1g2zj2b5vWy8)DdEXLEcqpW)IyHuuNCpXu7jBj1Y8HiC7Rymakg5bGQMFpmVXMRtl6xptlLROyAms58lCzuUjn9olSy1u17FmVEeXnKjqHolePVtBOVpazg1s6J)cjrqTBFuTzVhWwPx3XoEdlnvIUDw3rEtNW7TGZeNGpEDvNO5oEMEZKuWagah7WdTlb6zDmbQhL3lnA92P46vJFgu)Rm(eOx8lTeuplCP6RHijj(tm4OVXDcmPQsmHfKQmA2o2Xx2Cm8M0KlC6WO5z7SUZawHCfqv8hHD)lm6l(ijfXD7lV3fUaW2kIYn(cj71q1AEo7UD9Ee6aqM8fNQP2OJYlWtQFYDH7zlUW9cKRb(54LWiLx)5geoIyyz5iwkAVihw(YMkj(Lism6FVpM8aywKHpzR(7lZqBxb)dbB8tVlQy(Hp(hXy(GZpJJGzkA0in)YkgP4DfecKLzQASMbJ60uN)AMjilUSqcYWRRyq(WhbO8Q6UVB0T7iGDuiF6Ob5ZGHCZXltcOTo2zwcpUqckbrGGfAjmfc7Neubdj4tmCBfnqjyRmOIpEWhETa5Spmilfa0hlHKA0yB5IIbAmuQwGESL6g7qHElPmf2ALby2gLzdky1GptPsJG2NY0NQXrH09aooGtTDwB)yyLdeZQQPTIbb9gaLeAHV8jZqc8QUZdSCT9GSGrbShxmFSGEv9ocurQnJGMQwDSbVjUYGjno0i(idEt8f2((LLtAfqaJO6yUYPIgBF7t1Ila2Lre4waw(6ChaKsnBJnQbHjRa2dKcKhzO3Eou56e4(mQG3exzWupn0i(idEt8LJq90J6kN2APvPbbSlJiWTaSAvp1QzbC9CZYdDqv6OcCla7rONUfqhqPnfWEG0KQa6dMgPN5mFJb)N58JkN59dQ67rf4wa2JW2qlGoMm5bv8tb0hmXVN5mFJb)N58JeNbmmJCpLKVStrAureheRhujueUyrnGHCxrxdcg(C6ZgJ0CnwWDm4bSx)ljq2(zbZsikCsdKak4PqWs4oyAuEIG)))C2ldrAeUvbsxwkcwtnCoAE4bvAkMCIMswEIAE5enh5Mj6oTnZMm9eDlBBqvWwNWIQK6cC)ANZFX0PUVsn2p71SMBpRY3k40ZSzCuHsr4gkrzpyut7U8isl1sKplfjX5F3yZ5FeLIgDA5L68aSOSBUwPinWchCjyNaeputYksvuTbhLtLAHmF5gkB7dOyfLHQcxmbwOjbCnNUe5Xqr8r(oAmaf7Ao5aDtY7rl3eIvdnSWSuPsBjxDa2aIQnGECsZpQqDGkylTJbqr8kngAkZxdYV83K3Dte(hSA05Ose0OcCla7rKLPHn1GJkWTaShrSLvLdpUN7miKKRTNcW1prQrf4wa2JqEDmZZYZzGQJW(7BoZyd)N58JkNrvggD1OH1vTg2hjW1ptFJkWTaShHD1XjlqAH9aT447Z8J9dmNzSH)ZC(rIZaV1ZogTofX(6iIwN6JjvxtsRQnR2)45m8q8509(Ob3bB544bFqz)MhIMUj9R(eMWF3W)sy)g4AwG0vdutVOiadKfFI9dUI3vb4HvDN1prlSxzLSWwnBjqTGFipqw8j2p42Ycn0z971OzoBxEwWCY1D3UcDN1jv9BGhg8uLx3bVftahRyV2b325SUi2REtx2Xmv3VbEy0oNPg8wmbCSRZ0o42oN1L1zFyW9mPfeBVD2oDcfhzWBItaKUFjwIMhhOXg5hzWBbG7GyzxuLinGTQEjvVxltMQuoDIos9fVO5N4(Y6wVArtjvOzY22bq3ta1vlMHgkl5ye27GZjgBgXqZhAKzUyWvL1cInAJnVEYIdl5qdEtCIbvv2qJ8Jm4TaWMxR1llSx0vvzUDybmaPoSQY0pa2Ve2g27GZjgBgXqZhAKz(jTBGSEybel1f7Eva9OsiGAmTFRthzWBbGXul9YXR6z5qbBwUpwI32cEvHbqnKXpZCqAQO)SvaXbgioDeiMNBSWz2Hg8wayZZnW9Xs82wW31P(bzw7yKFAzt7eLELQrhpSwShE4efQIqQvvdTP6ud8cGVRUTzVAQZ8ZFTIvJOwb(w8tHj(7ETWWIzCVvA2y2lCwSy2SzxZ1tiNKb4FQqqhJiOdic6iHGUciyTGW34ZKV7PBM8Dwnt2gbF0MjRqqMIpNfdXAFLqXs1qG5QO69p9LDktfkYH4rMEtkShZlVkf5bI75QrcUapKnYWCmRnhfrg7iHTQ812nzGHpZQkKQoci(dqUvh6JJ4aM7Zhh4Ry91ySMTxsAQUjr9ix0NdYAQJ6(eD8GmiLhgTU6iY0b6w1HZx8bJrc9KFoz6M85GaBf6NheyRiuIdcSBTvKbe2T9szibUQtr1GaCfvT1rc8dF8FqwHGbj(n8L(QkCyzc(nzb1(T3GwzSjlh)OXTDFcrz4VL7VU82B2LNTog)Ulq)MI5nvwYRV6DunO4QC7WhHAxUw4EttJKkT9kx4pR2133GFNhUQuCVhVH8CcCfZXtE)MzbBZCkZL6RI4Y1fm0fedDvGHMtqSuFhamKT)J3KT7kYBSrf26U4nSNTboUlyA1FtqwAymjaNpT87UrnkksaaQ5PzUbV)ozkXHNqwm)CoKTdz)BcJ1pO5mWs4ADiYhojJJLxQo9dtyt8JdVCGs7YqjxUlpolpU8(wRX45MoC8YJjSrkJAuFcA0Xf9pGW1BDCJKcBKY4)DCH)diQYwh4iP4gjgaqBepc936FxK3iiL0UL6PwrS96RejgSFov4ncBrBQleP4ok6VJo8X)dKxv(jjhw(lvE(8hKxJoUUJwRM4r)tpSBruISgtSOR8N)63GDelOerVXRVc2jnZaeeyN0xOvfKnZDK94IyxFRUk0SGKN4l8ixDnN7FMgbB4b9f89c5VYXkG3d82kitElCeaUeqSG2BEwTA)5xF1Ptoje(HHM7YWrQdvNcTlDwy3Gt2CVgIaJftvGfp8arTNCR73nH(tFoLe8L1KhPmSFB(KhT8RVAk9rmVAiEfYlao1D6q3UXLo8XugmZ3NcRVO6Ioey(ZP(wqc4cnzYjADgazXp8E93WsK2m)quFPHXH0PxBHOg9k9rN8Ad92zfBMGRsnMeRc)Y)83zg7qZYOHr4zQ9ncV590Hq3lH31OruLKjymTMa5Wy91WuJHqCB1poNsOB0U4qeTgq0W08bqpUW9Kod2GXfSysCa2EFwsYk)uK8us2xPl4m3TAbQ7ccLrd5hsAimrdp6siEuL2HwVd20xv(EGa6MYV0TVCwLsq6KjqSWkYtoSpeQBc0LYwJsjQmF2VFy5VILcfqCQ(yzjknJuZLrMOeDZECKe01Qy(sb1Yg6R4ACKo8ZOR54FrljOyfJQ1Vpzk5399whHp13izw8RiFbsA(Hhu98BFjHX3QvQiGZcENM5zM2klyyvgmWBj6IGhSKVkiyl6PsuvNOOEPllPOoIsxELBpiu(fg3GDjsegeVKqWGe4O0qY6cvEhPyrbZmKW9PfwGsR7kcllm27lE4HCW3D7jY)CTq9vooQA76ZNbZgSvMzmnC0Gm2iW0Oof(Hl(YZnYyL1oPta8m7T(0qfwBexHIUbG3ayAfX01sR44z1bT6hjPxTi9tzPV9g)0xI9LfNRek6ZbC02UqGfWJv8i0maCpC4tMQJjCboiuYXa8Hh8L2kGZm00EwrXeHx97lDxiJyIxvF9dNqtmVY1o8YTYDuah43VZwCMnaQWx5ViBF5kKK5NHe5O)XCCgG8kZ8cJJUg(MKLGokDOPOcHV88jwFt0YvCf0psXLjlsUw3TjRQRt2MXrOSi0DTTQ(6A1MRPvtSMxD6SwtLmWG2e12vkfaprRRt8v4q9gk5)nQ)bCRD4AeXpiVC(y)1VBdYXlEfXTLPNzqFRlOqSJlO(cIjEyLgEuN3fTr0v)pU(QZMmvLbvKLHtuyFwa5V(SzTbIzd5p8atNb1tLMwpvx8s0sn8rA3))R9UABUTT9H)zzVXXATjrpe7MUlw3TB7(VBVB3w3)xwBvBNeT6NoB5627Y5p7dKIsIKcGKswPjDnxFJRIfiiiWpcaccddOGhnVVWqmbRgWhIGfDG6BMbd7zB39OkLk1VHhgxABFdfwZYqhpGAOl23ejVwwtVwekFxc4Yuq7qeZYMhst7z3DEV6gVhD7uV5(rdbgDPqA3sxvYb3CMFZOiuQzcWwIgc4oNH6yREnuFNacHI0VGK(yGKkeUpvOPdDhnvWPYitFFb7q)JXaE7ZNST5BU1)FsiyDjpsPb0HaIfuSTGIe4HgXcRfQxp8i2Q55Apn3CZjeQpUUeigULpzaKgI7JoMWk3NBclzp(qlGJrnyWEMgAzfIfFIMU62fPCEpp9YSIg75pI1JgmJhQAdIvSJgBg3vGk0vSixTgBPXrIiMZ)kV(jirB4)zqaSznngt5cH2LPrY3e9RztbK(qFpZM)r(XJSbb8WdC0lwf8kJE1t7PLEnf5lEdD8oDuW6VHK6I8RuxlI9o44sWFaK8GO)V3n)4KBsoo5EWsz0z3NLTz3pD5LhoC4IdRpCpRHCoD9Yl3Tz(IfJc89h6Fjp7INdgS73bJ1zX)bpBJt(DXdU5YK4JtoCp4TJ7u(Q3g6p8Y8fOZlVLuX)M4t50mD3Xj7386JtsGpCyoR(KyFY1Xi8ndg(23kb(Ew8px(58rGDFioKMDV7eDy0aqKW0loxvV4S4FfE4XjVt5PIjYTUpaoY1UsoNe0G52XjRwNDCsUnfR2MyklOgLPR(06pcMIFgaewLSGx6z5LAaxrzCHIcHzlgCfUN)I8GvA(kP7RBsdirs57vZUVypf9QTV0JK6a2n0SlqkrEeeZzCIGR9ONj)a1uXaAgn1m)syYEBqRVkWpU87GPOmwvhPSQoRNy(iJq0Kjis3l7s12A31cw4wnszuifbBRLjSJ2tzbWfVhKZFlovQzVGJMhnGyswt5RPZs8Ht3pZIHttl41SlXXAyr(UPZY93SjdTy9gvWOOg7QOJsryf4(les(u4raczEEwKoKUKLqKuFa8i9dJbFqNcJySFpPZzdeh5HFv4nZVWR2qPrJ))FLtNhoYBnR8xpjRh5xbYgYV8sie25tsSeMXn66YXOkpEBY9H0Y5e76Xe3i2OPfkLfweHlup8F5O9QM4c9M)uRKJVqudYCWQPSJ4pdclcwhyKrwbmSsbS(RMhn0T73(fUbiN9REwjG7RIIhHTtApeyFav4u92Uz7bsZ0n1hAtushXiSh1Ek4UuttB01fiE25BzKtADP8zFlTUGX0TBDbNsDZ6cgTXwx4b)VB8)SF2Dlf2ACcisoWoXfhHfwyFKdRvbLkpQ5cgPEYweFzDst)cEOGdRMoNLAKfJzv8lxBk46NXAnmVJBM2b7novTGGRnaSUz)IDOvSoefrFg26fZMFB600S4rdK37V6XGCaJ(3MUDohsOYiV8rFdzJJXZnDr0aHo11wssJc8MCh3rXTSexwFnNftkHbp6GZQ6pTKM))YVMcvdU0DxOlC48kFAsx5HzE0s1p2n8suw(yjvPPQ)N8xwovHv5Ov9hYxkYXQCyq4LSj3Dibg39ZtwaY4ntZUzu0aTdLCGBSwtNy1CnZYH9fDorAaA6vsWJOkGPz1A(YMAPSEP41cDv47Zsp374sFjDxLXNxiWoe0sp18NN)JoJJraJmIwu4KYnnwwMlWo7JQvwLuEPF5BH1JC)Nf2g52AtbNT3VHZT6lmiviDbN6WTekQhXQFjZHDjMYnNB5XtPuoWLZaNmfDpF(62PKLCVr7SBUYK9eAuzS9eni5mndQYIaYF3tP49Kc5u6EpqCqibe2FEUOi90Jd1ysz1m2CcgmFjs6JTPJ1lArUjTtcCJ06QtBUjqCF328BNmfwBM4VdeNL1S0S5lZtI(TFb8SNnA8mBbwRl3wX3GKAjZSN1ZneFVQBwHQFnSKnQ5NvyaQhnxv4JynnmIZ4YuYUPYqnG1bH1ehWCFs(Of0KfZwpMOLmmolz3hRNHXCq4TW3lB8YKvjaw4DWmEz6UD2allVONKVDHekuy4mD7xGniMogEw229IzGldb6lQtDyEdbJYYq64vZ)8Ew3CG1OJUJV)YS0Ip60a6kTk5bh1ojwC4Oyyz1vkxVsza2ZnNfISZu7wSoROtaOwTmIhw10xSkZmXkiKTiQJF0)I3e1REBLOOJpWWMep7I6)isl1cpu7ThEy9WJQrnEKIrCpMDDZexHOIRWhhXvO7IRq52DJbXvGDXvyhkU0sJDn1ljEU4xkximoB(IG9sEsshIUisl1PAXblAOCxA8XTsVRrL7h6)6Gw4esO)jvFnW73MJv1bo2u9nkX06dP1u3eckp45dc72CmOzkZH4kZiTBOwOmh2uL52zX3LlNVOm)mtzwlRf8KwOCtLQu3DoYw6Gx1Y7bA6niZVM(L1sX1zcxQ1LdA8sdc3qQ8)yX3mElEwld81gIgNHPRavEKZY04P0QpVC7WrBROW2G14ZGoE0v1IMdxjedV97XO5KKdpcrYrzPvYLvvwUbVx9Semx3okUgiw3nWoOv(uffNn3sSebh1bHj9xquuj2n0(U0i(KifeZGaTl3)S0Dm2ECY6SzN2272gyWcVFOFSHOdXVzfKhvNPOBdUaCpl034xYygCzDjbZgk9RRHJCgHEwOsJoMtRZyIuUQ)yhPNhPRtiEdGxHRw5yRoHDTIZ4DuiLNuAkSHhyjffpr4biTn1Vo4budmfEqyNHhe6cEq4)LWd0NXNkEq4JoEGohFQ4bTlQ8tkpC2WdSLdoRzAODyCDzS2VKPbREm(1ntdUQ7zlLzw19AN9uxk9Fr37zMUhp3c)FHIJeoyHUetzS4ZfDZ1YWVm39(L6K4Q7CYV6KBrB5d17oEPRYJX3oJjfTylzmwzasXzA5UByt7JFXdDBsuvGd6tI3ipjIKMeMC1jW3wVWRsPs9ARxY4YjUJMXRsOLZcFtnqn0s(alreE2Aygb2MGSlZGGSQFb071Czz4ixoxovDiwYZhv578WdAv)PTrYTvRA5U05LnHSsT3IujKP6GJAxGjPFkamb2iYOSZmx12fslpOLGhRXGJTqYlJh9QTg0ryH4iidYLsspBP89AZ)2S)mB)HzZ)ucSgXyZIY)lcnx8puVN4YpDRs1r3tESN37ZG)9()9]] )