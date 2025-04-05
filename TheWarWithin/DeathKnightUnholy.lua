-- DeathKnightUnholy.lua
-- January 2025

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local roundUp = ns.roundUp
local FindUnitBuffByID = ns.FindUnitBuffByID
local PTR = ns.PTR

local strformat = string.format

local spec = Hekili:NewSpecialization( 252 )
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
    }
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

        state.gain( amount * 10, "runic_power" )
        if state.set_bonus.tier20_4pc == 1 then
            state.cooldown.army_of_the_dead.expires = max( 0, state.cooldown.army_of_the_dead.expires - 1 )
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

spec:RegisterResource( Enum.PowerType.RunicPower )

local spendHook = function( amt, resource, noHook )
    if amt > 0 and resource == "runes" and active_dot.shackle_the_unworthy > 0 then
        reduceCooldown( "shackle_the_unworthy", 4 * amt )
    end
end

spec:RegisterHook( "spend", spendHook )

-- Talents
spec:RegisterTalents( {
    -- DeathKnight
    abomination_limb          = {  76049, 383269, 1 }, -- Sprout an additional limb, dealing 75,598 Shadow damage over 12 sec to all nearby enemies. Deals reduced damage beyond 5 targets. Every 1 sec, an enemy is pulled to your location if they are further than 8 yds from you. The same enemy can only be pulled once every 4 sec.
    antimagic_barrier         = {  76046, 205727, 1 }, -- Reduces the cooldown of Anti-Magic Shell by 20 sec and increases its duration and amount absorbed by 40%.
    antimagic_zone            = {  76065,  51052, 1 }, -- Places an Anti-Magic Zone that reduces spell damage taken by party or raid members by 20%. The Anti-Magic Zone lasts for 8 sec or until it absorbs 1.2 million damage.
    asphyxiate                = {  76064, 221562, 1 }, -- Lifts the enemy target off the ground, crushing their throat with dark energy and stunning them for 5 sec.
    assimilation              = {  76048, 374383, 1 }, -- The amount absorbed by Anti-Magic Zone is increased by 10% and its cooldown is reduced by 30 sec.
    blinding_sleet            = {  76044, 207167, 1 }, -- Targets in a cone in front of you are blinded, causing them to wander disoriented for 5 sec. Damage may cancel the effect. When Blinding Sleet ends, enemies are slowed by 50% for 6 sec.
    blood_draw                = {  76056, 374598, 1 }, -- When you fall below 30% health you drain 16,964 health from nearby enemies, the damage you take is reduced by 10% and your Death Strike cost is reduced by 10 for 8 sec. Can only occur every 2 min.
    blood_scent               = {  76078, 374030, 1 }, -- Increases Leech by 3%.
    brittle                   = {  76061, 374504, 1 }, -- Your diseases have a chance to weaken your enemy causing your attacks against them to deal 6% increased damage for 5 sec.
    cleaving_strikes          = {  76073, 316916, 1 }, -- Scourge Strike hits up to 7 additional enemies while you remain in Death and Decay. When leaving your Death and Decay you retain its bonus effects for 4 sec.
    coldthirst                = {  76083, 378848, 1 }, -- Successfully interrupting an enemy with Mind Freeze grants 10 Runic Power and reduces its cooldown by 3 sec.
    control_undead            = {  76059, 111673, 1 }, -- Dominates the target undead creature up to level 71, forcing it to do your bidding for 5 min.
    death_pact                = {  76075,  48743, 1 }, -- Create a death pact that heals you for 50% of your maximum health, but absorbs incoming healing equal to 30% of your max health for 15 sec.
    death_strike              = {  76071,  49998, 1 }, -- Focuses dark power into a strike that deals 6,563 Physical damage and heals you for 40.00% of all damage taken in the last 5 sec, minimum 11.2% of maximum health.
    deaths_echo               = { 102007, 356367, 1 }, -- Death's Advance, Death and Decay, and Death Grip have 1 additional charge.
    deaths_reach              = { 102006, 276079, 1 }, -- Increases the range of Death Grip by 10 yds. Killing an enemy that yields experience or honor resets the cooldown of Death Grip.
    enfeeble                  = {  76060, 392566, 1 }, -- Your ghoul's attacks have a chance to apply Enfeeble, reducing the enemies movement speed by 30% and the damage they deal to you by 12% for 6 sec.
    gloom_ward                = {  76052, 391571, 1 }, -- Absorbs are 15% more effective on you.
    grip_of_the_dead          = {  76057, 273952, 1 }, -- Defile reduces the movement speed of enemies within its area by 90%, decaying by 10% every sec.
    ice_prison                = {  76086, 454786, 1 }, -- Chains of Ice now also roots enemies for 4 sec but its cooldown is increased to 12 sec.
    icebound_fortitude        = {  76081,  48792, 1 }, -- Your blood freezes, granting immunity to Stun effects and reducing all damage you take by 30% for 8 sec.
    icy_talons                = {  76085, 194878, 1 }, -- Your Runic Power spending abilities increase your melee attack speed by 6% for 10 sec, stacking up to 3 times.
    improved_death_strike     = {  76067, 374277, 1 }, -- Death Strike's cost is reduced by 10, and its healing is increased by 60%.
    insidious_chill           = {  76051, 391566, 1 }, -- Your auto-attacks reduce the target's auto-attack speed by 5% for 30 sec, stacking up to 4 times.
    march_of_darkness         = {  76074, 391546, 1 }, -- Death's Advance grants an additional 25% movement speed over the first 3 sec.
    mind_freeze               = {  76084,  47528, 1 }, -- Smash the target's mind with cold, interrupting spellcasting and preventing any spell in that school from being cast for 3 sec.
    null_magic                = { 102008, 454842, 1 }, -- Magic damage taken is reduced by 8% and the duration of harmful Magic effects against you are reduced by 35%.
    osmosis                   = {  76088, 454835, 1 }, -- Anti-Magic Shell increases healing received by 15%.
    permafrost                = {  76066, 207200, 1 }, -- Your auto attack damage grants you an absorb shield equal to 40% of the damage dealt.
    proliferating_chill       = { 101708, 373930, 1 }, -- Chains of Ice affects 1 additional nearby enemy.
    raise_dead                = {  76072,  46585, 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time. Lasts 1 min.
    rune_mastery              = {  76079, 374574, 2 }, -- Consuming a Rune has a chance to increase your Strength by 3% for 8 sec.
    runic_attenuation         = {  76045, 207104, 1 }, -- Auto attacks have a chance to generate 3 Runic Power.
    runic_protection          = {  76055, 454788, 1 }, -- Your chance to be critically struck is reduced by 3% and your Armor is increased by 6%.
    sacrificial_pact          = {  76060, 327574, 1 }, -- Sacrifice your ghoul to deal 15,357 Shadow damage to all nearby enemies and heal for 25% of your maximum health. Deals reduced damage beyond 8 targets.
    soul_reaper               = {  76063, 343294, 1 }, -- Strike an enemy for 10,568 Shadowfrost damage and afflict the enemy with Soul Reaper. After 5 sec, if the target is below 35% health this effect will explode dealing an additional 48,489 Shadowfrost damage to the target. If the enemy that yields experience or honor dies while afflicted by Soul Reaper, gain Runic Corruption.
    subduing_grasp            = {  76080, 454822, 1 }, -- When you pull an enemy, the damage they deal to you is reduced by 6% for 6 sec.
    suppression               = {  76087, 374049, 1 }, -- Damage taken from area of effect attacks reduced by 3%. When suffering a loss of control effect, this bonus is increased by an additional 6% for 6 sec.
    unholy_bond               = {  76076, 374261, 1 }, -- Increases the effectiveness of your Runeforge effects by 20%.
    unholy_endurance          = {  76058, 389682, 1 }, -- Increases Lichborne duration by 2 sec and while active damage taken is reduced by 15%.
    unholy_ground             = {  76069, 374265, 1 }, -- Gain 5% Haste while you remain within your Death and Decay.
    unyielding_will           = {  76050, 457574, 1 }, -- Anti-Magic shell now removes all harmful magical effects when activated, but it's cooldown is increased by 20 sec.
    vestigial_shell           = {  76053, 454851, 1 }, -- Casting Anti-Magic Shell grants 2 nearby allies a Lesser Anti-Magic Shell that Absorbs up to 55,050 magic damage and reduces the duration of harmful Magic effects against them by 50%.
    veteran_of_the_third_war  = {  76068,  48263, 1 }, -- Stamina increased by 20%.
    will_of_the_necropolis    = {  76054, 206967, 2 }, -- Damage taken below 30% Health is reduced by 20%.
    wraith_walk               = {  76077, 212552, 1 }, -- Embrace the power of the Shadowlands, removing all root effects and increasing your movement speed by 70% for 4 sec. Taking any action cancels the effect. While active, your movement speed cannot be reduced below 170%.

    -- Unholy
    all_will_serve            = {  76181, 194916, 1 }, -- Your Raise Dead spell summons an additional skeletal minion.
    apocalypse                = {  76185, 275699, 1 }, -- Bring doom upon the enemy, dealing 10,238 Shadow damage and bursting up to 4 Festering Wounds on the target. Summons 4 Army of the Dead ghouls for 20 sec. Generates 2 Runes.
    army_of_the_dead          = {  76196,  42650, 1 }, -- Summons a legion of ghouls who swarms your enemies, fighting anything they can for 30 sec.
    bursting_sores            = {  76164, 207264, 1 }, -- Bursting a Festering Wound deals 16% more damage, and deals 3,420 Shadow damage to all nearby enemies. Deals reduced damage beyond 8 targets.
    clawing_shadows           = {  76183, 207311, 1 }, -- Deals 21,909 Shadow damage and causes 1 Festering Wound to burst.
    coil_of_devastation       = {  76156, 390270, 1 }, -- Death Coil causes the target to take an additional 30% of the direct damage dealt over 4 sec.
    commander_of_the_dead     = {  76149, 390259, 1 }, -- Dark Transformation also empowers your Gargoyle and Army of the Dead for 30 sec, increasing their damage by 35%.
    dark_transformation       = {  76187,  63560, 1 }, -- Your ghoul deals 9,159 Shadow damage to 5 nearby enemies and transforms into a powerful undead monstrosity for 15 sec. Granting them 100% energy and the ghoul's abilities are empowered and take on new functions while the transformation is active.
    death_rot                 = {  76158, 377537, 1 }, -- Death Coil and Epidemic debilitate your enemy applying Death Rot causing them to take 1% increased Shadow damage, up to 10% from you for 10 sec. If Death Coil or Epidemic consume Sudden Doom it applies two stacks of Death Rot.
    decomposition             = {  76154, 455398, 2 }, -- Virulent Plague has a chance to abruptly flare up, dealing 50% of the damage it dealt to target in the last 4 sec. When this effect triggers, the duration of your active minions are increased by 1.0 sec, up to 3.0 sec.
    defile                    = {  76161, 152280, 1 }, -- Defile the targeted ground, dealing 33,785 Shadow damage to all enemies over 10 sec. While you remain within your Defile, your Scourge Strike will hit 7 enemies near the target. Every sec, if any enemies are standing in the Defile, it grows in size and deals increased damage.
    doomed_bidding            = {  76176, 455386, 1 }, -- Consuming Sudden Doom calls upon a Magus of the Dead to assist you for 8 sec.
    ebon_fever                = {  76160, 207269, 1 }, -- Diseases deal 12% more damage over time in half the duration.
    eternal_agony             = {  76182, 390268, 1 }, -- Death Coil and Epidemic increase the duration of Dark Transformation by 1 sec.
    festering_scythe          = {  76193, 455397, 1 }, -- Every 20 Festering Wound you burst empowers your next Festering Strike to become Festering Scythe for 12 sec. Festering Scythe Sweep through all enemies within 14 yds in front of you, dealing 45,047 Shadow damage and infecting them with 2-3 Festering Wounds.
    festering_strike          = {  76189,  85948, 1 }, -- Strikes for 21,646 Physical damage and infects the target with 2-3 Festering Wounds.  Festering Wound A pustulent lesion that will burst on death or when damaged by Scourge Strike, dealing 6,230 Shadow damage and generating 3 Runic Power.
    festermight               = {  76152, 377590, 2 }, -- Popping a Festering Wound increases your Strength by 1% for 20 sec stacking. Multiple instances may overlap.
    foul_infections           = {  76162, 455396, 1 }, -- Your diseases deal 10% more damage and have a 5% increased chance to critically strike.
    ghoulish_frenzy           = {  76194, 377587, 1 }, -- Dark Transformation also increases the attack speed and damage of you and your Monstrosity by 5%.
    harbinger_of_doom         = {  76178, 276023, 1 }, -- Sudden Doom triggers 30% more often, can accumulate up to 2 charges, and increases the damage of your next Death Coil by 20% or Epidemic by 10%.
    improved_death_coil       = {  76184, 377580, 1 }, -- Death Coil deals 15% additional damage and seeks out 1 additional nearby enemy.
    improved_festering_strike = {  76192, 316867, 2 }, -- Festering Strike and Festering Wound damage increased by 10%.
    infected_claws            = {  76195, 207272, 1 }, -- Your ghoul's Claw attack has a 30% chance to cause a Festering Wound on the target.
    magus_of_the_dead         = {  76148, 390196, 1 }, -- Apocalypse and Army of the Dead also summon a Magus of the Dead who hurls Frostbolts and Shadow Bolts at your foes.
    menacing_magus            = { 101882, 455135, 1 }, -- Your Magus of the Dead Shadow Bolt now fires a volley of Shadow Bolts at up to 4 nearby enemies.
    morbidity                 = {  76197, 377592, 2 }, -- Diseased enemies take 1% increased damage from you per disease they are affected by.
    pestilence                = {  76157, 277234, 1 }, -- Death and Decay damage has a 10% chance to apply a Festering Wound to the enemy.
    plaguebringer             = {  76183, 390175, 1 }, -- Scourge Strike causes your disease damage to occur 100% more quickly for 10 sec.
    raise_abomination         = {  76153, 455395, 1 }, -- Raises an Abomination for 30 sec which wanders and attacks enemies, applying Festering Wound when it melees targets, and affecting all those nearby with Virulent Plague.
    raise_dead_2              = {  76188,  46584, 1 }, -- Raises a ghoul to fight by your side. You can have a maximum of one ghoul at a time.
    reaping                   = {  76179, 377514, 1 }, -- Your Soul Reaper, Scourge Strike, Festering Strike, and Death Coil deal 30% additional damage to enemies below 35% health.
    rotten_touch              = {  76175, 390275, 1 }, -- Sudden Doom causes your next Death Coil to also increase your Scourge Strike damage against the target by 50% for 10 sec.
    runic_mastery             = {  76186, 390166, 2 }, -- Increases your maximum Runic Power by 10 and increases the Rune regeneration rate of Runic Corruption by 10%.
    ruptured_viscera          = {  76177, 390236, 1 }, -- When your ghouls expire, they explode in viscera dealing 2,876 Shadow damage to nearby enemies. Each explosion has a 25% chance to apply Festering Wounds to enemies hit.
    scourge_strike            = {  76190,  55090, 1 }, -- An unholy strike that deals 8,248 Physical damage and 6,581 Shadow damage, and causes 1 Festering Wound to burst.
    sudden_doom               = {  76191,  49530, 1 }, -- Your auto attacks have a 25% chance to make your next Death Coil or Epidemic cost 10 less Runic Power and critically strike. Additionally, your next Death Coil will burst 1 Festering Wound.
    summon_gargoyle           = {  76176,  49206, 1 }, -- Summon a Gargoyle into the area to bombard the target for 25 sec. The Gargoyle gains 1% increased damage for every 1 Runic Power you spend. Generates 50 Runic Power.
    superstrain               = {  76155, 390283, 1 }, -- Your Virulent Plague also applies Frost Fever and Blood Plague at 75% effectiveness.
    unholy_assault            = {  76151, 207289, 1 }, -- Strike your target dealing 26,127 Shadow damage, infecting the target with 4 Festering Wounds and sending you into an Unholy Frenzy increasing all damage done by 20% for 20 sec.
    unholy_aura               = {  76150, 377440, 2 }, -- All enemies within 8 yards take 10% increased damage from your minions.
    unholy_blight             = {  76163, 460448, 1 }, -- Dark Transformation surrounds your ghoul with a vile swarm of insects for 6 sec, stinging all nearby enemies and infecting them with Virulent Plague and an unholy disease that deals 7,164 damage over 14 sec, stacking up to 4 times.
    unholy_pact               = {  76180, 319230, 1 }, -- Dark Transformation creates an unholy pact between you and your pet, igniting flaming chains that deal 45,956 Shadow damage over 15 sec to enemies between you and your pet.
    vile_contagion            = {  76159, 390279, 1 }, -- Inflict disease upon your enemies spreading Festering Wounds equal to the amount currently active on your target to 7 nearby enemies.

    -- Rider of the Apocalypse
    a_feast_of_souls          = {  95042, 444072, 1 }, -- While you have 2 or more Horsemen aiding you, your Runic Power spending abilities deal 20% increased damage.
    apocalypse_now            = {  95041, 444040, 1 }, -- Army of the Dead and Frostwyrm's Fury call upon all 4 Horsemen to aid you for 20 sec.
    death_charge              = {  95060, 444010, 1 }, -- Call upon your Death Charger to break free of movement impairment effects. For 10 sec, while upon your Death Charger your movement speed is increased by 100%, you cannot be slowed below 100% of normal speed, and you are immune to forced movement effects and knockbacks.
    fury_of_the_horsemen      = {  95042, 444069, 1 }, -- Every 50 Runic Power you spend extends the duration of the Horsemen's aid in combat by 1 sec, up to 5 sec.
    horsemens_aid             = {  95037, 444074, 1 }, -- While at your aid, the Horsemen will occasionally cast Anti-Magic Shell on you and themselves at 80% effectiveness. You may only benefit from this effect every 45 sec.
    hungering_thirst          = {  95044, 444037, 1 }, -- The damage of your diseases and Death Coil are increased by 10%.
    mawsworn_menace           = {  95054, 444099, 1 }, -- Scourge Strike deals 15% increased damage and the cooldown of your Defile is reduced by 5 sec.
    mograines_might           = {  95067, 444047, 1 }, -- Your damage is increased by 5% and you gain the benefits of your Death and Decay while inside Mograine's Death and Decay.
    nazgrims_conquest         = {  95059, 444052, 1 }, -- If an enemy dies while Nazgrim is active, the strength of Apocalyptic Conquest is increased by 3%. Additionally, each Rune you spend increase its value by 1%.
    on_a_paler_horse          = {  95060, 444008, 1 }, -- While outdoors you are able to mount your Acherus Deathcharger in combat.
    pact_of_the_apocalypse    = {  95037, 444083, 1 }, -- When you take damage, 5% of the damage is redirected to each active horsemen.
    riders_champion           = {  95066, 444005, 1, "rider_of_the_apocalypse" }, -- Spending Runes has a chance to call forth the aid of a Horsemen for 10 sec. Mograine Casts Death and Decay at his location that follows his position. Whitemane Casts Undeath on your target dealing 2,466 Shadowfrost damage per stack every 3 sec, for 24 sec. Each time Undeath deals damage it gains a stack. Cannot be Refreshed. Trollbane Casts Chains of Ice on your target slowing their movement speed by 40% and increasing the damage they take from you by 5% for 8 sec. Nazgrim While Nazgrim is active you gain Apocalyptic Conquest, increasing your Strength by 5%.
    trollbanes_icy_fury       = {  95063, 444097, 1 }, -- Scourge Strike shatters Trollbane's Chains of Ice when hit, dealing 28,748 Shadowfrost damage to nearby enemies, and slowing them by 40% for 4 sec. Deals reduced damage beyond 8 targets.
    whitemanes_famine         = {  95047, 444033, 1 }, -- When Scourge Strike damages an enemy affected by Undeath it gains 1 stack and infects another nearby enemy.

    -- San'layn
    bloodsoaked_ground        = {  95048, 434033, 1 }, -- While you are within your Death and Decay, your physical damage taken is reduced by 5% and your chance to gain Vampiric Strike is increased by 5%.
    bloody_fortitude          = {  95056, 434136, 1 }, -- Icebound Fortitude reduces all damage you take by up to an additional 20% based on your missing health. Killing an enemy that yields experience or honor reduces the cooldown of Icebound Fortitude by 3 sec.
    frenzied_bloodthirst      = {  95065, 434075, 1 }, -- Essence of the Blood Queen stacks 2 additional times and increases the damage of your Death Coil and Death Strike by 5% per stack.
    gift_of_the_sanlayn       = {  95053, 434152, 1 }, -- While Dark Transformation is active you gain Gift of the San'layn. Gift of the San'layn increases the effectiveness of your Essence of the Blood Queen by 100%, and Vampiric Strike replaces your Scourge Strike for the duration.
    incite_terror             = {  95040, 434151, 1 }, -- Vampiric Strike and Scourge Strike cause your targets to take 1% increased Shadow damage, up to 5% for 15 sec. Vampiric Strike benefits from Incite Terror at 400% effectiveness.
    infliction_of_sorrow      = {  95033, 434143, 1 }, -- When Vampiric Strike damages an enemy affected by your Virulent Plague, it extends the duration of the disease by 3 sec, and deals 10% of the remaining damage to the enemy. After Gift of the San'layn ends, your next Scourge Strike consumes the disease to deal 100% of their remaining damage to the target.
    newly_turned              = {  95064, 433934, 1 }, -- Raise Ally revives players at full health and grants you and your ally an absorb shield equal to 20% of your maximum health.
    pact_of_the_sanlayn       = {  95055, 434261, 1 }, -- You store 50% of all Shadow damage dealt into your Blood Beast to explode for additional damage when it expires.
    sanguine_scent            = {  95055, 434263, 1 }, -- Your Death Coil, Epidemic and Death Strike have a 15% increased chance to trigger Vampiric Strike when damaging enemies below 35% health.
    the_blood_is_life         = {  95046, 434260, 1 }, -- Vampiric Strike has a chance to summon a Blood Beast to attack your enemy for 10 sec. Each time the Blood Beast attacks, it stores a portion of the damage dealt. When the Blood Beast dies, it explodes, dealing 25% of the damage accumulated to nearby enemies and healing the Death Knight for the same amount. Deals reduced damage beyond 8 targets.
    vampiric_aura             = {  95056, 434100, 1 }, -- Your Leech is increased by 2%. While Lichborne is active, the Leech bonus of this effect is increased by 100%, and it affects 4 allies within 12 yds.
    vampiric_speed            = {  95064, 434028, 1 }, -- Death's Advance and Wraith Walk movement speed bonuses are increased by 10%. Activating Death's Advance or Wraith Walk increases 4 nearby allies movement speed by 20% for 5 sec.
    vampiric_strike           = {  95051, 433901, 1, "sanlayn" }, -- Your Death Coil, Epidemic and Death Strike have a 25% chance to make your next Scourge Strike become Vampiric Strike. Vampiric Strike heals you for 2% of your maximum health and grants you Essence of the Blood Queen, increasing your Haste by 1.0%, up to 5.0% for 20 sec.
    visceral_strength         = {  95045, 434157, 1 }, -- When Sudden Doom is consumed, you gain 8% Strength for 5 sec.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bloodforged_armor    = 5585, -- (410301) Death Strike reduces all Physical damage taken by 20% for 3 sec.
    dark_simulacrum      =   41, -- (77606) Places a dark ward on an enemy player that persists for 12 sec, triggering when the enemy next spends mana on a spell, and allowing the Death Knight to unleash an exact duplicate of that spell.
    doomburst            = 5436, -- (356512) Sudden Doom also causes your next Death Coil to burst up to 2 Festering Wounds and reduce the target's movement speed by 45% per burst. Lasts 3 sec.
    life_and_death       =   40, -- (288855) When targets afflicted by your Virulent Plague are healed, you are also healed for 5% of the amount. In addition, your Virulent Plague now erupts for 400% of normal eruption damage when dispelled.
    necromancers_bargain = 3746, -- (288848) The cooldown of your Apocalypse is reduced by 15 sec, but your Apocalypse no longer summons ghouls but instead applies Crypt Fever to the target. Crypt Fever Deals up to 8% of the targets maximum health in Shadow damage over 4 sec. Healing spells cast on this target will refresh the duration of Crypt Fever.
    necrotic_wounds      =  149, -- (356520) Bursting a Festering Wound converts it into a Necrotic Wound, absorbing 3% of all healing received for 15 sec and healing you for the amount absorbed when the effect ends, up to 3% of your max health. Max 6 stacks. Adding a stack does not refresh the duration.
    reanimation          =  152, -- (210128) Reanimates a nearby corpse, summoning a zombie for 20 sec that slowly moves towards your target. If your zombie reaches its target, it explodes after 3.0 sec. The explosion stuns all enemies within 8 yards for 3 sec and deals 10% of their health in Shadow damage.
    rot_and_wither       = 5511, -- (202727) Your Death's Due rots enemies each time it deals damage, absorbing healing equal to 100% of damage dealt.
    spellwarden          = 5590, -- (410320) Anti-Magic Shell is now usable on allies and its cooldown is reduced by 10 sec.
    strangulate          = 5430, -- (47476) Shadowy tendrils constrict an enemy's throat, silencing them for 4 sec.
} )

-- Auras
spec:RegisterAuras( {
    -- Your Runic Power spending abilities deal $w1% increased damage.
    a_feast_of_souls = {
        id = 440861,
        duration = 3600,
        max_stack = 1
    },
    abomination_limb = {
        id = 383269,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Absorbing up to $w1 magic damage.  Immune to harmful magic effects.
    -- https://wowhead.com/spell=48707
    antimagic_shell = {
        id = 48707,
        duration = 5,
        max_stack = 1
    },
    apocalyptic_conquest = {
        id = 444763,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Summoning ghouls.
    -- https://wowhead.com/spell=42650
    army_of_the_dead = {
        id = 42650,
        duration = 4,
        tick_time = 0.5,
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/spell=221562
    asphyxiate = {
        id = 108194,
        duration = 4.0,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/spell=207167
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
    -- https://wowhead.com/spell=374609
    blood_draw_cd = {
        id = 374609,
        duration = 120,
        max_stack = 1
    },
    -- Draining $w1 health from the target every $t1 sec.
    -- https://wowhead.com/spell=55078
    blood_plague = {
        id = 55078,
        duration = function() return 24 * ( talent.ebon_fever.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.ebon_fever.enabled and 0.5 or 1 ) * ( buff.plaguebringer.up and 0.5 or 1 ) end,
        type = "Disease",
        max_stack = 1,
        copy = "blood_plague_superstrain"
    },
    -- Physical damage taken reduced by $s1%.; Chance to gain Vampiric Strike increased by $434033s2%.
    bloodsoaked_ground = {
        id = 434034,
        duration = 3600,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=374557
    brittle = {
        id = 374557,
        duration = 5,
        max_stack = 1
    },
    -- Talent: Movement slowed $w1% $?$w5!=0[and Haste reduced $w5% ][]by frozen chains.
    -- https://wowhead.com/spell=45524
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
    coil_of_devastation = {
        id = 390271,
        duration = 5,
        type = "Disease",
        max_stack = 1
    },
    commander_of_the_dead = {
        id = 390260,
        duration = 30,
        max_stack = 1,
        copy = "commander_of_the_dead_window"
    },
    -- Talent: Controlled.
    -- https://wowhead.com/spell=111673
    control_undead = {
        id = 111673,
        duration = 300,
        mechanic = "charm",
        type = "Magic",
        max_stack = 1
    },
    -- Taunted.
    -- https://wowhead.com/spell=56222
    dark_command = {
        id = 56222,
        duration = 3,
        mechanic = "taunt",
        max_stack = 1
    },
    -- Your next Death Strike is free and heals for an additional $s1% of maximum health.
    -- https://wowhead.com/spell=101568
    dark_succor = {
        id = 101568,
        duration = 20,
        max_stack = 1
    },
    -- Talent: $?$w2>0[Transformed into an undead monstrosity.][Gassy.]  Damage dealt increased by $w1%.
    -- https://wowhead.com/spell=63560
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
        end
    },
    -- Reduces healing done by $m1%.
    -- https://wowhead.com/spell=327095
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
        max_stack = 1
    },
    death_and_decay_cleave_buff = {
        id = 188290,
        duration = 10,
        type = "None",
        max_stack = 1,
        copy = "death_and_decay"
    },
    -- [444347] $@spelldesc444010
    death_charge = {
        id = 444347,
        duration = 10,
        max_stack = 1
    },
    -- Talent: The next $w2 healing received will be absorbed.
    -- https://wowhead.com/spell=48743
    death_pact = {
        id = 48743,
        duration = 15,
        max_stack = 1
    },
    death_rot = {
        id = 377540,
        duration = 10,
        max_stack = 10
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
        max_stack = function() return 5 + ( talent.frenzied_bloodthirst.enabled and 2 or 0 ) end
    },
    festering_scythe_ready = {
        id = 458123,
        duration = 15,
        max_stack = 1,
        copy = "festering_scythe"
    },
    festering_scythe_stack = {
        id = 459238,
        duration = 3600,
        max_stack = 20
    },
    -- Suffering from a wound that will deal [(20.7% of Attack power) / 1] Shadow damage when damaged by Scourge Strike.
    festering_wound = {
        id = 194310,
        duration = 30,
        max_stack = 6
    },
    -- Reduces damage dealt to $@auracaster by $m1%.
    -- https://wowhead.com/spell=327092
    famine = {
        id = 327092,
        duration = 6,
        max_stack = 3
    },
    -- Strength increased by $w1%.
    -- https://wowhead.com/spell=377591
    festermight = {
        id = 377591,
        duration = 20,
        max_stack = 20
    },
    -- Suffering $w1 Frost damage every $t1 sec.
    -- https://wowhead.com/spell=55095
    frost_fever = {
        id = 55095,
        duration = function() return 24 * ( talent.ebon_fever.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.ebon_fever.enabled and 0.5 or 1 ) * ( buff.plaguebringer.up and 0.5 or 1 ) end,
        max_stack = 1,
        type = "Disease",
        copy = "frost_fever_superstrain"
    },
    frost_shield = {
        id = 207203,
        duration = 10,
        type = "None",
        max_stack = 1
    },
    -- Movement speed slowed by $s2%.
    -- https://wowhead.com/spell=279303
    frostwyrms_fury = {
        id = 279303,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Damage and attack speed increased by $s1%.
    -- https://wowhead.com/spell=377588
    ghoulish_frenzy = {
        id = 377588,
        duration = 15,
        max_stack = 1,
        copy = 377589
    },
    -- https://www.wowhead.com/spell=434153
    -- Gift of the San'layn The effectiveness of Essence of the Blood Queen is increased by 100%. Scourge Strike has been replaced with Vampiric Strike.
    gift_of_the_sanlayn = {
        id = 434153,
        duration = 15,
        max_stack = 1,
        onRemove = function()
            removeBuff( "vampiric_strike" )
        end
    },
    -- Dealing $w1 Frost damage every $t1 sec.
    -- https://wowhead.com/spell=274074
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
        max_stack = 1
    },
    -- Dealing $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/spell=275931
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
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $w3%.  Immune to Stun effects.
    -- https://wowhead.com/spell=48792
    icebound_fortitude = {
        id = 48792,
        duration = 8,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=194879
    -- Icy Talons Attack speed increased by 18%.
    icy_talons = {
        id = 194879,
        duration = 10,
        max_stack = 3
    },
    -- Taking $w1% increased Shadow damage from $@auracaster.
    incite_terror = {
        id = 458478,
        duration = 15.0,
        max_stack = 5
    },
    -- https://www.wowhead.com/spell=460049
    -- Infliction of Sorrow Scourge Strike consumes your Virulent Plague to deal 100% of their remaining damage to the target.
    infliction_of_sorrow = {
        id = 460049,
        duration = 15,
        max_stack = 1
    },
    -- Time between auto-attacks increased by $w1%.
    -- https://www.wowhead.com/spell=391568
    insidious_chill = {
        id = 391568,
        duration = 30,
        max_stack = 4
    },
    -- Absorbing up to $w1 magic damage.; Duration of harmful magic effects reduced by $s2%.
    lesser_antimagic_shell = {
        id = 454863,
        duration = function() return 5.0 * ( taletn.antimagic_barrier.enabled and 1.4 or 1 ) end,
        max_stack = 1
    },
    -- Casting speed reduced by $w1%.
    -- https://wowhead.com/spell=326868
    lethargy = {
        id = 326868,
        duration = 6,
        max_stack = 1
    },
    -- Leech increased by $s1%$?a389682[, damage taken reduced by $s8%][] and immune to Charm, Fear and Sleep. Undead.
    -- https://wowhead.com/spell=49039
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
    mograines_might = {
        id = 444505,
        duration = 3600,
        max_stack = 1
    },
    -- Grants the ability to walk across water.
    -- https://wowhead.com/spell=3714
    path_of_frost = {
        id = 3714,
        duration = 600,
        tick_time = 0.5,
        max_stack = 1
    },
    -- Disease damage occurring ${100*(1/(1+$s1/100)-1)}% more quickly.
    -- https://www.wowhead.com/spell=390178
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
    -- https://wowhead.com/spell=51714
    razorice = {
        id = 51714,
        duration = 20,
        tick_time = 1,
        type = "Magic",
        max_stack = 5
    },
     -- https://www.wowhead.com/spell=390276
    rotten_touch = {
        id = 390276,
        duration = 10,
        max_stack = 1
    },
    -- Strength increased by $w1%
    -- https://wowhead.com/spell=374585
    rune_mastery = {
        id = 374585,
        duration = 8,
        max_stack = 1
    },
    -- Runic Power generation increased by $s1%.
    -- https://wowhead.com/spell=326918
    rune_of_hysteria = {
        id = 326918,
        duration = 8,
        max_stack = 1
    },
    -- Healing for $s1% of your maximum health every $t sec.
    -- https://wowhead.com/spell=326808
    rune_of_sanguination = {
        id = 326808,
        duration = 8,
        max_stack = 1
    },
    -- Absorbs $w1 magic damage.    When an enemy damages the shield, their cast speed is reduced by $w2% for $326868d.
    -- https://wowhead.com/spell=326867
    rune_of_spellwarding = {
        id = 326867,
        duration = 8,
        max_stack = 1
    },
    -- Haste and Movement Speed increased by $s1%.
    -- https://wowhead.com/spell=326984
    rune_of_unending_thirst = {
        id = 326984,
        duration = 10,
        max_stack = 1
    },
    -- Increases your rune regeneration rate for 3 sec.
    runic_corruption = {
        id = 51460,
        duration = function () return 3 * haste end,
        max_stack = 1
    },
    -- Damage dealt increased by $s1%.; Healing received increased by $s2%.
    sanguine_ground = {
        id = 391459,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Afflicted by Soul Reaper, if the target is below $s3% health this effect will explode dealing an additional $343295s1 Shadowfrost damage.
    -- https://wowhead.com/spell=343294
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
        max_stack = 1
    },
    -- Your next Death Coil$?s207317[ or Epidemic][] cost ${$s1/-10} less Runic Power and is guaranteed to critically strike.
    sudden_doom = {
        id = 81340,
        duration = 10,
        max_stack = function ()
            if talent.harbinger_of_doom.enabled then return 2 end
            return 1 end
    },
    -- Runic Power is being fed to the Gargoyle.
    -- https://wowhead.com/spell=61777
    summon_gargoyle = {
        id = 61777,
        duration = 25,
        max_stack = 1
    },
    summon_gargoyle_buff = { -- TODO: Buff on the gargoyle...
        id = 61777,
        duration = 25,
        max_stack = 1
    },
    -- Damage taken from area of effect attacks reduced by an additional $w1%.
    suppression = {
        id = 454886,
        duration = 6.0,
        max_stack = 1
    },
    -- Movement slowed $w1%.
    trollbanes_icy_fury = {
        id = 444834,
        duration = 4.0,
        max_stack = 1
    },
    -- Suffering $w1 Shadowfrost damage every $t1 sec.; Each time it deals damage, it gains $s3 $Lstack:stacks;.
    undeath = {
        id = 444633,
        duration = 24.0,
        tick_time = 3.0,
        max_stack = 1
    },
    -- Talent: Haste increased by $s1%.
    -- https://wowhead.com/spell=207289
    unholy_assault = {
        id = 207289,
        duration = 20,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Surrounded by a vile swarm of insects, infecting enemies within $115994a1 yds with Virulent Plague and an unholy disease that deals damage to enemies.
    -- https://wowhead.com/spell=115989
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
        end
    },
    -- Suffering $s1 Shadow damage every $t1 sec.
    -- https://wowhead.com/spell=115994
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
        max_stack = 1
    },
    -- Deals $s1 Fire damage.
    unholy_pact = {
        id = 319240,
        duration = 0.0,
        max_stack = 1
    },
    -- Strength increased by $s1%.
    -- https://wowhead.com/spell=53365
    unholy_strength = {
        id = 53365,
        duration = 15,
        max_stack = 1
    },
    -- Vampiric Aura's Leech amount increased by $s1% and is affecting $s2 nearby allies.
    vampiric_aura = {
        id = 434105,
        duration = 3600,
        max_stack = 1
    },
    -- Movement speed increased by $w1%.
    vampiric_speed = {
        id = 434029,
        duration = 5.0,
        max_stack = 1
    },
    vampiric_strike = {
        id = 433899,
        duration = 3600,
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.  Erupts for $191685s1 damage split among all nearby enemies when the infected dies.
    -- https://wowhead.com/spell=191587
    virulent_plague = {
        id = 191587,
        duration = function () return 27 * ( talent.ebon_fever.enabled and 0.5 or 1 ) end,
        tick_time = function() return 3 * ( talent.ebon_fever.enabled and 0.5 or 1 ) * ( buff.plaguebringer.up and 0.5 or 1 ) end,
        type = "Disease",
        max_stack = 1,
        copy = 441277
    },
    -- The touch of the spirit realm lingers....
    -- https://wowhead.com/spell=97821
    voidtouched = {
        id = 97821,
        duration = 300,
        max_stack = 1
    },
    -- Increases damage taken from $@auracaster by $m1%.
    -- https://wowhead.com/spell=327096
    war = {
        id = 327096,
        duration = 6,
        type = "Magic",
        max_stack = 3
    },
    -- Talent: Movement speed increased by $w1%.  Cannot be slowed below $s2% of normal movement speed.  Cannot attack.
    -- https://wowhead.com/spell=212552
    wraith_walk = {
        id = 212552,
        duration = 4,
        max_stack = 1
    },

    -- PvP Talents
    doomburst = {
        id = 356518,
        duration = 3,
        max_stack = 2
    },
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
    necrotic_wound = {
        id = 223929,
        duration = 18,
        max_stack = 1
    },
} )

-- Pets
spec:RegisterPets({
    apoc_ghoul = {
        id = 24207,
        spell = "apocalypse",
        duration = 15,
        copy = "army_ghoul",
    },
    magus_of_the_dead = {
        id = 148797,
        spell = "apocalypse",
        duration = 15,
        copy = "t31_magus",
    },
    ghoul = {
        id = 26125,
        spell = "raise_dead",
        duration = function() return talent.raise_dead_2.enabled and 3600 or 60 end
    },
    highlord_darion_mograine = {
        id = 221632,
        spell = "army_of_the_dead",
        duration = 20,
    },
    king_thoras_trollbane = {
        id = 221635,
        spell = "army_of_the_dead",
        duration = 20,
    },
    nazgrim = {
        id = 221634,
        spell = "army_of_the_dead",
        duration = 20,
    },
    high_inquisitor_whitemane = {
        id = 221633,
        spell = "army_of_the_dead",
        duration = 20,
    },
    risen_skulker = {
        id = 99541,
        spell = "raise_dead",
        duration = function() return talent.raise_dead_2.enabled and 3600 or 60 end,
    },
})

-- Totems (which are sometimes pets)
spec:RegisterTotems( {
    gargoyle = {
        id = 458967,
        copy = "dark_arbiter",
    },
    dark_arbiter = {
        id = 298674,
        copy = "gargoyle",
    },
    abomination = {
        id = 298667,
    },
} )

spec:RegisterStateTable( "death_and_decay",
setmetatable( { onReset = function( self ) end },
{ __index = function( t, k )
    if k == "ticking" then
        if state.query_time - class.abilities.any_dnd.lastCast < 10 then return true end
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
        if state.query_time - class.abilities.any_dnd.lastCast < 10 then return true end
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
    if talent.infected_claws.enabled and pet.ghoul.up then return false end -- Ghoul is dumping wounds for us, don't bother.
    return azerite.festermight.enabled and settings.cycle and settings.festermight_cycle and cooldown.death_and_decay.remains < 9 and active_dot.festering_wound < spell_targets.festering_strike
end )

spec:RegisterStateFunction( "time_to_wounds", function( x )
    if debuff.festering_wound.stack >= x then return 0 end
    return 3600
    --[[No timeable wounds mechanic in SL?
    if buff.unholy_frenzy.down then return 3600 end

    local deficit = x - debuff.festering_wound.stack
    local swing, speed = state.swings.mainhand, state.swings.mainhand_speed

    local last = swing + ( speed * floor( query_time - swing ) / swing )
    local fw = last + ( speed * deficit ) - query_time

    if fw > buff.unholy_frenzy.remains then return 3600 end
    return fw--]]
end )

spec:RegisterHook( "step", function ( time )
    if Hekili.ActiveDebug then Hekili:Debug( "Rune Regeneration Tispec: 1=%.2f, 2=%.2f, 3=%.2f, 4=%.2f, 5=%.2f, 6=%.2f\n", runes.time_to_1, runes.time_to_2, runes.time_to_3, runes.time_to_4, runes.time_to_5, runes.time_to_6 ) end
end )

local Glyphed = IsSpellKnownOrOverridesKnown

spec:RegisterGear({
    -- The War Within
    tww2 = {
        items = { 229253, 229251, 229256, 229254, 229252 },
        auras = {
            -- https://www.wowhead.com/spell=1216813
            winning_streak = {
                id = 1216813,
                duration = 3600,
                max_stack = 10
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207198, 207199, 207200, 207201, 207203, 217223, 217225, 217221, 217222, 217224 }
    },
    tier30 = {
        items = { 202464, 202462, 202461, 202460, 202459 },
        auras = {
            master_of_death = {
                id = 408375,
                duration = 30,
                max_stack = 20
            },
            death_dealer = {
                id = 408376,
                duration = 20,
                max_stack = 1
            },
            lingering_chill = {
                id = 410879,
                duration = 12,
                max_stack = 1
            }
        }
    },
    tier29 = {
        items = { 200405, 200407, 200408, 200409, 200410 },
        auras = {
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
        }
    }
})

local any_dnd_set, wound_spender_set = false, false

--[[local ExpireRunicCorruption = setfenv( function()
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
end, state )--]]

local TriggerInflictionOfSorrow = setfenv( function ()
    applyBuff( "infliction_of_sorrow" )
end, state )

local ApplyFestermight = setfenv( function ( woundsPopped )
    if woundsPopped > 0 and talent.festermight.enabled or azerite.festermight.enabled  then
        if buff.festermight.up then
            addStack( "festermight", buff.festermight.remains, woundsPopped )
        else
            applyBuff( "festermight", nil, woundsPopped )
        end
    end

    return woundsPopped -- Needs to be returned into the gain() function for runic power

end, state )

local PopWounds = setfenv( function ( attemptedPop, targetCount )
    targetCount = targetCount or 1
    local realPop = targetCount
    realPop = ApplyFestermight( removeDebuffStack( "target", "festering_wound", attemptedPop ) * targetCount )
    gain( realPop * 3, "runic_power" )

    if talent.festering_scythe.enabled then
        if realPop + buff.festering_scythe_stack.stack >= 20 then -- overflow stacks don't carry over
            removeBuff( "festering_scythe_stack" )
            applyBuff( "festering_scythe" )
        else
            addStack( "festering_scythe_stack", nil, realPop )
         end
    end

end, state )

spec:RegisterHook( "reset_precast", function ()
    --[[if buff.runic_corruption.up then
        state:QueueAuraExpiration( "runic_corruption", ExpireRunicCorruption, buff.runic_corruption.expires )
    end--]]

    if totem.dark_arbiter.remains > 0 then
        summonPet( "dark_arbiter", totem.dark_arbiter.remains )
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

    if IsActiveSpell( 433899 ) or IsActiveSpell( 433895 ) then applyBuff( "vampiric_strike" ) end

    if not talent.clawing_shadows.enabled or buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up then
        class.abilities.wound_spender = class.abilities.scourge_strike
        class.abilities[ 433895 ] = class.abilities.scourge_strike
        cooldown.wound_spender = cooldown.scourge_strike
    else
        class.abilities.wound_spender = class.abilities.clawing_shadows
        class.abilities[ 433895 ] = class.abilities.clawing_shadows
        cooldown.wound_spender = cooldown.clawing_shadows
    end

    if not wound_spender_set then
        class.abilityList.wound_spender = "|T237530:0|t |cff00ccff[Wound Spender]|r"
        wound_spender_set = true
    end

    if state:IsKnown( "deaths_due" ) and cooldown.deaths_due.remains then setCooldown( "death_and_decay", cooldown.deaths_due.remains )
    elseif talent.defile.enabled and cooldown.defile.remains then setCooldown( "death_and_decay", cooldown.defile.remains ) end

    if talent.infliction_of_sorrow.enabled and buff.gift_of_the_sanlayn.up then
        state:QueueAuraExpiration( "gift_of_the_sanlayn", TriggerInflictionOfSorrow, buff.gift_of_the_sanlayn.expires )
    end

    if Hekili.ActiveDebug then Hekili:Debug( "Pet is %s.", pet.alive and "alive" or "dead" ) end

    if IsSpellKnownOrOverridesKnown( 458128 ) then applyBuff( "festering_scythe" ) end
    if IsSpellKnownOrOverridesKnown( 433895 ) then applyBuff( "vampiric_strike" ) end

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
                if set_bonus.tww1_4pc > 0 then addStack( "unholy_commander" ) end
            end

            PopWounds( 4, 1 )

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
            if set_bonus.tww1_4pc > 0 then addStack( "unholy_commander" ) end

            if talent.raise_abomination.enabled then
                summonPet( "abomination", 30 )
            else
                applyBuff( "army_of_the_dead", 4 )
                summonPet( "army_ghoul", 30 )
            end

            if talent.apocalypse_now.enabled then
                summonPet( "highlord_darion_mograine", 20 )
                summonPet( "king_thoras_trollbane", 20 )
                summonPet( "nazgrim", 20 )
                summonPet( "high_inquisitor_whitemane", 20 )
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
        id = function()
            if ( buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up ) then return 433895 end
            return 207311
        end,
        known = 55090,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "clawing_shadows",
        startsCombat = true,
        max_targets = function()
            if talent.cleaving_strikes.enabled and buff.death_and_decay_cleave_buff.up then return 8 end
            return 1 end,

        texture = function() return ( buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up ) and 5927645 or 615099 end,

        cycle = function()
            if debuff.chains_of_ice_trollbane_slow.down and active_dot.chains_of_ice_trollbane_slow > 0 then return "chains_of_ice_trollbane_slow" end
            return "festering_wound"
        end,
        min_ttd = function () return min( cooldown.death_and_decay.remains + 3, 8 ) end, -- don't try to cycle onto targets that will die too fast to get consumed.
        cycle_to = true,

        handler = function ()
            PopWounds( 1, min( action.clawing_shadows.max_targets, active_enemies, active_dot.festering_wound ) )

            if debuff.undeath.up then
                applyDebuff( "target", "undeath", debuff.undeath.stack + 1 )
                active_dot.undeath = min( active_enemies, active_dot.undeath + 1 )
            end

            if buff.vampiric_strike.up then
                gain( 0.01 * health.max, "health" )
                applyBuff( "essence_of_the_blood_queen" ) -- TODO: mod haste

                if talent.infliction_of_sorrow.enabled and dot.virulent_plague.ticking then
                    dot.virulent_plague.expires = dot.virulent_plague.expires + 3
                end

                -- Vampiric Strike is consumed unless it's from Gift of the San'layn.
                if not buff.gift_of_the_sanlayn.up then
                    removeBuff( "vampiric_strike" )
                end
            end

            if buff.infliction_of_sorrow.up then
                removeDebuff( "target", "virulent_plague" )
                removeBuff( "infliction_of_sorrow" )
            end

            -- Legacy
            if conduit.convocation_of_the_dead.enabled and cooldown.apocalypse.remains > 0 then
                reduceCooldown( "apocalypse", conduit.convocation_of_the_dead.mod * 0.1 )
            end

        end,

        bind = { "scourge_strike", "wound_spender" },
        copy = { 207311, 433895 }
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
                    applyDebuff( "target", "frost_fever" )
                    active_dot.frost_fever = active_enemies
                    applyDebuff( "target", "blood_plague" )
                    active_dot.blood_plague = active_enemies
                end
            end

            if talent.unholy_pact.enabled then applyBuff( "unholy_pact" ) end

            if talent.gift_of_the_sanlayn.enabled then
                applyBuff( "gift_of_the_sanlayn" )
                applyBuff( "vampiric_strike" )
            end

            if azerite.helchains.enabled then applyBuff( "helchains" ) end
            if legendary.frenzied_monstrosity.enabled then
                applyBuff( "frenzied_monstrosity" )
                applyBuff( "frenzied_monstrosity_pet" )
            end

            if set_bonus.tww2 >= 4 then addStack( "winning_streak", nil, 10 ) end

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
        charges = function () if talent.deaths_echo.enabled then return 2 end end,
        cooldown = 30,
        recharge = function () if talent.deaths_echo.enabled then return 30 end end,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,
        notalent = "defile",

        handler = function ()
            applyBuff( "death_and_decay", 10 )
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

        startsCombat = true,

        handler = function ()

            if buff.sudden_doom.up then
                PopWounds( 1 + ( 1 * pvptalent.doomburst.rank ) )
                removeStack( "sudden_doom" )
                if talent.doomed_bidding.enabled then summonPet( "magus_of_the_dead", 6 ) end
                if talent.rotten_touch.enabled then applyDebuff( "target", "rotten_touch" ) end
                if talent.death_rot.enabled then applyDebuff( "target", "death_rot", nil, 2 ) end
            elseif talent.death_rot.enabled then applyDebuff( "target", "death_rot", nil, 1 ) end
            if buff.dark_transformation.up then buff.dark_transformation.expires = buff.dark_transformation.expires + 1 end
            if buff.gift_of_the_sanlayn.up then buff.gift_of_the_sanlayn.expires = buff.gift_of_the_sanlayn.expires + 1 end

            -- Legacy
            if legendary.deadliest_coil.enabled and buff.dark_transformation.up then buff.dark_transformation.expires = buff.dark_transformation.expires + 2 end
            if legendary.deaths_certainty.enabled then
                local spell = action.deaths_due.known and "deaths_due" or ( talent.defile.enabled and "defile" or "death_and_decay" )
                if cooldown[ spell ].remains > 0 then reduceCooldown( spell, 2 ) end
            end
            if set_bonus.tier30_2pc > 0 then addStack( "master_of_death" ) end
            if set_bonus.tier30_4pc > 0 then
                addStack( "master_of_death", nil, 2 )
                applyBuff( "doom_dealer" )
            end
            if set_bonus.tier30_2pc > 0 and buff.master_of_death.up then
                removeBuff( "master_of_death" )
                applyBuff( "death_dealer" )
            end
        end
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
        end
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
        end
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
        end
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
        end
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
        end
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

        bind = { "defile", "any_dnd" }
    },

    -- Talent: Causes each of your Virulent Plagues to flare up, dealing $212739s1 Shadow da...
    epidemic = {
        id = 207317,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 30 - ( buff.sudden_doom.up and 10 or 0 ) end,
        spendType = "runic_power",

        startsCombat = false,

        targets = {
            count = function() return active_dot.virulent_plague end,
        },

        usable = function() return active_dot.virulent_plague > 0, "requires active virulent_plague dots" end,
        handler = function ()

            if buff.sudden_doom.up then
                removeStack( "sudden_doom" )
                if talent.death_rot.enabled then applyDebuff( "target", "death_rot", nil, 2 ) end
            elseif talent.death_rot.enabled then applyDebuff( "target", "death_rot", nil, 1 ) end
            if buff.dark_transformation.up then buff.dark_transformation.expires = buff.dark_transformation.expires + 1 end
            if buff.gift_of_the_sanlayn.up then buff.gift_of_the_sanlayn.expires = buff.gift_of_the_sanlayn.expires + 1 end
            if set_bonus.tier30_2pc > 0 then addStack( "master_of_death" ) end
        end
    },

    -- Talent: Strikes for $s1 Physical damage and infects the target with $m2-$M2 Festering...
    festering_strike = {
        id = function ()
            if IsSpellKnownOrOverridesKnown( 458128 ) or buff.festering_scythe.up then return 458128 end
            return 85948 end,
        known = 85948,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 2,
        spendType = "runes",

        talent = "festering_strike",
        startsCombat = true,
        texture = function ()
            if IsSpellKnownOrOverridesKnown( 458128 ) or buff.festering_scythe.up then return 3997563 end
            return 879926 end,

        cycle = function() if debuff.festering_wound.stack_pct > 60 then return "festering_wound" end end,
        min_ttd = function() return min( cooldown.death_and_decay.remains + 3, 8 ) end, -- don't try to cycle onto targets that will die too fast to get consumed.

        handler = function ()

            if buff.festering_scythe.up then
                active_dot.festering_wound = active_enemies
            end
            removeBuff( "festering_scythe" )

            applyDebuff( "target", "festering_wound", nil, min( 6, debuff.festering_wound.stack + 2 ) )
        end,

        copy = { 85948, 458128 }
    },

    -- Talent: Your blood freezes, granting immunity to Stun effects and reducing all damage...
    icebound_fortitude = {
        id = 48792,
        cast = 0,
        cooldown = function() return 180 - ( azerite.cold_hearted.enabled and 15 or 0 ) + ( conduit.chilled_resilience.mod * 0.001 ) end,
        gcd = "off",

        talent = "icebound_fortitude",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "icebound_fortitude" )
            if azerite.cold_hearted.enabled then applyBuff( "cold_hearted" ) end
        end
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
        end
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
        end
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
            if talent.superstrain.enabled then
                applyDebuff( "target", "frost_fever" )
                active_dot.frost_fever = active_enemies
                applyDebuff( "target", "blood_plague" )
                active_dot.blood_plague = active_enemies
            end
        end
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
        end
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
        end
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

        usable = function() return not pet.alive end,
        handler = function ()
            summonPet( "ghoul", talent.raise_dead_2.enabled and 3600 or 60 )
            if talent.all_will_serve.enabled then summonPet( "risen_skulker", talent.raise_dead_2.enabled and 3600 or 60 ) end
            if set_bonus.tww1_4pc > 0 then addStack( "unholy_commander" ) end
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
        end
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

        usable = function() return pet.alive, "requires an undead pet" end,

        handler = function ()
            dismissPet( "ghoul" )
            gain( 0.25 * health.max, "health" )
        end
    },

    -- Talent: An unholy strike that deals $s2 Physical damage and $70890sw2 Shadow damage, ...
    scourge_strike = {
        id = function ()
            if buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up then return 433895 end
            return 55090
        end,
        known = 55090,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "scourge_strike",
        texture = function() return ( buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up ) and 5927645 or 237530 end,
        startsCombat = true,
        max_targets = function ()
            if talent.cleaving_strikes.enabled and buff.death_and_decay_cleave_buff.up then return 8 end
            return 1 end,

        notalent = function ()
            if buff.vampiric_strike.up or buff.gift_of_the_sanlayn.up then return end
            return "clawing_shadows"
        end,

        cycle = function ()
            if debuff.chains_of_ice_trollbane_slow.down and active_dot.chains_of_ice_trollbane_slow > 0 then return "chains_of_ice_trollbane_slow" end
            return "festering_wound"
        end,
        min_ttd = function() return min( cooldown.death_and_decay.remains + 3, 8 ) end, -- don't try to cycle onto targets that will die too fast to get consumed.
        cycle_to = true,

        handler = function ()
            PopWounds( 1, min( action.scourge_strike.max_targets, active_enemies, active_dot.festering_wound ) )

            if buff.vampiric_strike.up then
                gain( 0.01 * health.max, "health" )
                applyBuff( "essence_of_the_blood_queen" ) -- TODO: mod haste

                if talent.infliction_of_sorrow.enabled and dot.virulent_plague.ticking then
                    dot.virulent_plague.expires = dot.virulent_plague.expires + 3
                end

                -- Vampiric Strike is consumed unless it's from Gift of the San'layn.
                if not buff.gift_of_the_sanlayn.up then
                    removeBuff( "vampiric_strike" )
                end
            end

            if talent.plaguebringer.enabled then
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

        bind = { "clawing_shadows", "wound_spender" },
        copy = { 55090, "vampiric_strike", 433895 }
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
        end
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
        end
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
            if set_bonus.tww1_4pc > 0 then addStack( "unholy_commander" ) end
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
        end
    },
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

        -- usable = function() return debuff.festering_wound.up, "requires active festering wounds" end,
        cycle = "festering_wound",
        cycle_to = true,

        toggle = "cooldowns",
        debuff = "festering_wound",

        handler = function ()
            if debuff.festering_wound.up then
                active_dot.festering_wound = min( active_enemies, active_dot.festering_wound + 7 )
            end
        end
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
        name = function() return "|T136144:0|t |cff00ccff[Any " .. ( class.abilities.death_and_decay and class.abilities.death_and_decay.name or "Death and Decay" ) .. "]|r" end,
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

spec:RegisterRanges( "festering_strike", "mind_freeze", "death_coil" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 10,
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    cycle = true,
    cycleDebuff = "festering_wound",

    potion = "tempered_potion",

    package = "Unholy",
} )

spec:RegisterSetting( "dps_shell", false, {
    name = strformat( "Use %s Offensively", Hekili:GetSpellLinkWithTexture( spec.abilities.antimagic_shell.id ) ),
    desc = strformat( "If checked, %s will not be on the Defensives toggle by default.", Hekili:GetSpellLinkWithTexture( spec.abilities.antimagic_shell.id ) ),
    type = "toggle",
    width = "full",
} )

spec:RegisterSetting( "ob_macro", nil, {
    name = strformat( "%s Macro", Hekili:GetSpellLinkWithTexture( spec.abilities.outbreak.id ) ),
    desc = strformat( "Using a mouseover macro makes it easier to apply %s and %s to other enemies without retargeting.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.outbreak.id ), Hekili:GetSpellLinkWithTexture( spec.auras.virulent_plague.id ) ),
    type = "input",
    width = "full",
    multiline = true,
    get = function() return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.outbreak.name end,
    set = function() end,
} )

spec:RegisterPack( "Unholy", 20250328, [[Hekili:S3t7UnUrs(S4FensZSrJiL9eNGzmWUb7cSb7LdyDUFD4mfLeLeVHIuljLD8Ia9SFv38RMnRQ7MuKEgpNacsIfBwv1vxF1v1DXhSE43E4(1UPEp8R2ZSVz2C7BNA9JxBn3(H7tF(G3d3FWD1ND3c)pHU7H)9)v4UOGNz)8ZbrURzVEs0X4vWJ2LMEi5NE)736NU74YPRI2)(e)9hdCt9Jcxf7UjL93RE)d3V8OFq6Fp8HL44ga5bVvWVEdqf78xV2lBOEjRE4E2q)(zZ)E7B)Ptl(B()(PfhI9E0p6yYPfjphU60IPtpT4jVtlwhf(M0tloMa))UWF6T2FfGT1Nw8OBSV7Ya2VVIrCNwe4NKE6xkH9Ca237V)NH)ndKvpWI4bwvp44b2C6pbuJByG7ZaWxf45(iGSK0JB2u8o2zZGypGeoT47VJ9Icp7dWZ(NEztONagAg0F4EgHMW56UHoB8t25hUf(ZFLVq6fYMvRF4V8W9ztm4)gM6V3DR)kNKDEbbzCXy)dzpfE8BYOX)woOUhEyQhWEyJ0nDNZNd93UlDQ7(eh3LjrXlDo4bl3Hard08StlgbtIJHacoe9Kx8PfF80IRN9qkS8jrsvqEjWhM6hUjWNtLorBCaihh900JhQi9NIogU2befcx7fZa4CsaE1PfCyMrYUWRT2BL7Za440xXJF0D)b)ygVin2)ZE1WMB4ZoRdxZWZ1Qj8KJmjsN1rr7lqqQBaWrMY(jV1olbrwGxonheNw8h)bS47L6Smk8yY00NEY256dR4VjhIEjjEHR8y8H0DEoldIIw78Vo65fo1n1zV7VdemOgMiIRnXEH)BFg2yJoDNFCsAfgnCsNXVwf5hWM33qoVtDJ36LoDNNBq6UPhysSF8tNwm)goM2WKqCI9276hMWflUPcfG1Ha4zUhYwd)G21qZP3FGewJzQ7COTXlH9BHBD4Itt5msGgzupO2bwpG5L7YO9(HC7utzOIPScZRvrrbRJEc(TdrRCdE(qI3uXzzHze(ZDa9manNwmjB9w7CPH49TKth1ZLpQEQuHXQ3pJCaKMcpnYZbeobstHzKgVAD7i)5O)kyGIdezTfH3C1ZG0nJhO04WvS1U6QXP(R(mN3clkJ5s25kblpcs9Cyhf7Lil(NpOh9d8azMWuWmiWvQPvwZg3goBfuPYe3tYetw9my)2Xl0BVVxIXV1TzJm21FTJ3JmYWD9AGc)DM97mJMspQuYIPzzzPEmmDSmmOX0xHLjVnaxOAUpb1WNSbwCr1McMR2XOkM5lFWkwACuqWs3qqSki3KEgpmNbXKYqSYslQvt2q5IkoMKTRzcMk19Lqu1Qu5kGbsdsYqJ0zEIjcCn(KrPb0slshaYNb1AEMlC3G4alZurff(rby5DWFn8ZRkjKwBoUJuwfIkibmZKTA1eZsomx3UA9uWnRbRmFIhZJbl7FuAvhF18hplEwFSQznRRKa6Yd4qz1AiuXipvUtoY3fHJBsI7XGurCkpLadDwf29nrNCE2IJ2HEhlk1slOA8umbFXt2hwXSRoym3roZsX1ftwvM(VUKWv4FPzuzxZdobh8TXXungCU7dSfbv(LmItKhkfPmHwv1pGVWrVrIZs8RMtzJd(ajmNAmy5rjXOf8KV2n(ZG3x3WKnrX75XaQE7mRJyey8rgL6CiWD7rporKKl2u4LlB(Jn6ypyFij7yWoJSZN27Hnk6V2p9z0TKS1FtAXMDY3LSu8kjhH9la2XbIOgey0WM4OKuNnGeACD8N)8STpHrGtAgbzULOLbCZ41wEupcX9hGW4RwMqqkmTs8CedvhdXkgLiYBoSkuxjBeDmDjSlSpRkEOkNJgPsaUc8Y3hyBdvbdMc0r1CXjWF)YAUvycmQCTGPeqL0d(2w(5Cgjqg)3EGiR36)h(UPWN3mLcqSLzEfKpzjoIXe8tyzYbe5wX1FDHnd93)p(5k3N)jyGz5aI9(SXzglEScJOywg)4NYTjOW70W579ddIV3CFjrjOU1a0ApZmR8xCp)kX9mTdRlEH6Qxi2Ic4j)9Ced)J9PfVv98eiZ31COElbJYzZAnJmBQVKTWln4jFrDk(1gN4BjF0jPQCnlMkyjxYaRHPA8BUaPDAXVgf(9fEPF4SsdTYmnAA2RkO)wuqI6ATBJ5g(Wmcry)DCE2CzjwE7oGVvMxAMUavoRlE2wGpf9mlX05papDF02znj5dLdGZqCIpO1rT1mQKqqx5bTP((Abljc08HSbMi4Qdjt014miPhxH6bcUuiP05CJrXXOlwafFqRd57Ys6i1CiVub8uURsl3Ksf8x4aPpkvarzw4t3grhRi9yn9hrvBbbNrkk)G(SdktDD6LaNmZMMPcGMA3sHFKC(owBDlRIeAp8BS924ShCLHZmIJstbmKgDC1o58CiyQdggEQxR7lSU0U(k)sic8IUIILLFDVtpVGYFKlewIBsAwz1pgKu(IMTqGoYkdUwZKxReZopvvDgKsirfKKoKPWaOLalgR6TNxmuDjb9Cxhny1c4RJ1erFfOSXNUY1SGIR38vZZIt25HPptKZpNNDLYC50W3cDCw5A(cvgsuRxruyxP8DnjVfzdPt71NN2dLohZM2i7jmFQt(8AHSz)cmnOsnLIC4uBBqgKcHI3RClw9Dsf4CtIJ0KOJ0VTsPWnFP3j)nKfNJElfgK)NRqCYMFs9gvB3e758oJsAg3IAPLdDuGQTrzRBB4Gr2ZZYQ4gWjSQk7A7tyjlMOC73AIbu0ulMHftSTQ2445q9Lbk9wXf0omtSvBhMV9utMPTW(PooadzQXHGL3wANnp7nP(7bD1iN1(ECvyCBV5iFe(Z7NIuszlESgZX8aK1zpUtMKPZu4xqBS6xaEBrLOBNHysLqmZVs7XbX8BJFViSEedoIdRjBwkOprvHgf4Ni2V24o4SS1Zoh4qS9HF2lf1OFn76)w(apTOk9QzNR)nph7gWcrM5lAnO6UpU5UNabH9mdvGlRIXlF2mr2XZnewaH5VLwgW1Yllks7PB8(NvgNUA1bH1ugGY9ldBCyTKUfyaRSmcI5pKIfQOySPSOk25fhDmjZ8)E)006CDeM6DL2QXvHM0IO4YZlBMuaf5Ois8Czpl0CJM)qhlhMQqsnn4ZDRjiiz9Xy(4YtJYpmVaHng7Hy)iGCFw0Vx(ZMMApTYYybcleKQgZoxyNS5JRWIpBukPlMBFjH88G9an5GOub(PcVR5JXwjp3(LGNB3vEUTep3YaEUL58C7UWZTvLtjm58RqxTRX2fNGSCYvA8ywnpDu7eOjlObuM0GHV2DV7wpNbtwVUr1KJ73dEKkR5uBnPoYql0MJvtqPPbtjAhTbafJsQiniTdKQJ8YEwPeUzZ8(KFBShKMtEvKyjmLhKm8YOt8YzQnSbRBWSNkNOwv2tX0TTj0TT7fDBeO0oD7(WM6xgznZXQjO8IUDBiZx)622yvyVq3M9Eo7CdxlftToF3k1)1QMvBEAiCWCfRgowDGEmbDLMDo)GgVRSGHTtX0eP92S5oTaBKY9qAeouT)uSaIRT8PwirP6qr9yZukQe4ll4wFwPntYf8DLzYrvEwvKaLrdCH36EYHpFnI8QQzezEjZUDlZUxQrxoxUD2Dn2sNjX4C2Pd2aRi6cXwyii5s(LOoEDjLUR92W1YlmzxgkJF4AhqIY7F7jD(pKTLfDa8g4Lw9QfEx4)Fozj7tORfiUmOR8x3ycpQybQey1nGvl(GByevWry9nGvo)z5)5d3phZoNYPg)10vcV7O6Cdg5Bj3yKjhKitM)FSkWSAA8fduuRJ2WEo5u7i4zKW8DnGH6R8HIgMXekFmMiWWPdrHtHtvlIZi9cb5CtQBv0idUMsLKUC7Tz(S6uAZdTlIDUCs2FJAjxb70KNNsLdiZKhLab71fiuEFHyLFAPCyPaEv8z(7peh9Oh7GtvCS0K3TnIGPDnsL9smdKR9E0fwXR7pzsjz5LXEZ(B0DhYdzcZCEUU7zCYNlIIUALT4GTJL6inlNLGWnKZXC2lDx74KJI((t9ZKTO9rRsXf099Qx1yo)sQyYQ77eLdu3WHER4fcqCsZzR1a0UJSQBZweq6ArfJXfcGJnmUudBrUrGCYsa1w6AC4kroKK12HZp7geCAXFMZZoT4FW7YwLSqWpqGt2F4WAaxSl6smeejZ)CTWGZS5iDSrlqjV3DjixKVrpoTPSpqOdUcednflGCre3O9pugAs8k25VnfcqgqUe36F6UY3nO2EaLnsAx2AWY0Q5cRwYBbTwkz4lRzkbBog)80Qs48oUvbMYqnRcIBMqvYKgBuo2yJ0Omy9HzYfLUzsdg14jv(v(K(PAHbqKDapsX5tWqiJfPTDUDsIwsGUTRQfZvswvdHlsqVp8srcy3yEXm64BFrc6P65ksOgYdPibfMfejkhcxKGo3gCaMhImy2ZlCB6o076b6b8Pm6bXNkgVhwImkFjz0Q7ffoAi8TVN48)EC929mRPSjPYB5S1TFtjBBD75i)w82dJmQ1Tco9GOXyj(jWH5aLVm1U8vyxUcWC8vfEn7zn2mr9hZzZn8)E4yqw(4SOVLjf2j34h7XnU(nVzs6zA3LYmaWdJaOsexjquocU0a9fkfzZy1ZEnM5tL0yXXSV0AT7w(wwIz5QLtnu3)Odrz)36ftacUNj10YsjmKIIC(IIS6pFwgLqoUsixk)1Ab75ZohP3AVns2zg18rnEFdKvNZlDIf92vglSN)97DzN)rY6TzwkSXo0T6HnHCKUPiRzciAdUE1c5PADMykzBK)B5eZQFdp4ZfXdiYGpNTf7xV11zE4(JjSeuSXz7Q15PW3wvlvq4cV2QEg98g7xuWRC9EynJe026fi2TmjJAE73hTyhPIrtk7NcDKSS7mzXjjvT05wtpDNCeUXNmQIouMUrvwDJQkihLnNHxskItn0D2HEA9GVwWrfTzCune(K9kfb7uZMUI2wOyJarjTw1BQbYDoDNkLMChRGCl3zhXLdwZT3NHKXnU1)8tbD5rYW4zzwB1GnlP9yOCrHyIyojWrEhoue5kiy1avuj5kT(7Dx)CTjJQBhPMSNlkSzwug1J1g8crYQe)WlWyzT9GymsNnL2RsZiPCPhAFqKuJwJCDGGyed8thI9GWww62Sw2zboXdQskIjY8rlflwfW5hz28YH0(YfNw)OWYc3HjELzEq4H(jt37hhhXJ)AtmaVJXmZbr75NHKeSxG869uvPcPddgBo0HQDgx7O6tmhSB7CWULZb7Q5qll)ztUrX2GRfDWGSAGn0nSnjZyJGEbkSs83g6vAEIFmSFUED6egpJRimHAk4PI4EB2r87DAirQHHrOzxDz(w56yDnRwXvUo1RsCydv16KDlxNS1ToPM4qwaWirQHPzDIOmVMUoz5SdIIXjFgrPrPqvNS(ZYHR2scZwhHPZgejHjhCBljmlh2hFjrsI(87oYGZZQaNUkIKYu99D4NzPQb8PYV7a5OblAMUHpmijJ4jTWEA9vfiy4Y1fE2dAuX5wUWyRFHr(E6y2cJTogvpVWOfFDzHXC1LMlmY78OLlmf3fjPnqRuTr7sx18c)Ekvjq24UHYgIo4pw36X71C5sNWTrZQy30gw1Rhkw5irGx235nvJOYkPiolozn1Ng(bpgWpQEIQR8FBcFcznltWj7FURbeqTyGXiSmIrihxn900slJWQfmclegHnjJqPVKghsbdvniUTETrdb75IcXnMASSciXdun3sZ28)z0qp)p)RpixHEd7KNfy486xFJuNfNCZYk6SJD50c)GrTCE8L5H8Z5tN7PVvauSDo21oSyNANJuxpxvDXqDNwDS1oHm)HjOIsBuxVWZOdlEIQblsvnvDmDTQj6e0R1cq5GKOTQsDZDOumsfo0HM3JAQ3gWV0NAQYKAreTx6tndAFQPXZXALgxPjkvS4lfv6YpOSJ1D3tgP5ykukD16ZoGY46u8U3v0aiNiVtR(4cQ3TtrHrZfK3n)EklSpodOUoColmI(iAzasey7U4SNJmW7kQZKAjHoAeRJY6k1RY3(hYjyr3cWlrVysTDfB97UvkxmVwSRy)nKDfS5Yxt2vWOVVgSRy)QXUcMEvlSRyR1UYq0VXkF(LMaMEuo2qSo6sJcsx45nN8Ff2OGgIMaMrkCx6mxxu4A)m)1Vc3xHDMRwbamhJeaW8EX1iniOEEKADexwg1D9hPjsOsIqBHHau(JZO5BngydvlJdOtz2UmfEAb2iLjPZiCqfepvp6k)87POgmfF1(O(SjgZ)UjI9nt8k1Nx385d9hQqZSg9rTFSf5sBenFjQuCRSIkCas1vFWo7OIkGv7PK6BFM4InAJ2ixowSTvKjUYjGSkRScMHhpuB7fjGTILrHhtMM(0t2oxFyf)9QvliWw8T5QuKZgdpjSUPo7D)DhEPasexXv3ohgrsOCe(KFyyEnp8C)mcse(UJAezk6gAE7RTLrCjSAziSkR7amR0CPQNlQKKxHffc8QUXgQ(6NELEzfjh23XB9sfeI4hNvKOKL41u1fsFHOum1PVhgJ1b6pvCTI6w9aZ1LhBSWGoUDDpskHwPNwP5NWhPug003uYSoP7Rzk9vlrBwczKGUYhsYBZMF6foMRSbtvAoet4BIc5kLnxfTvL38pAIfRHioL0p3TKCNyFI(ZHzJJqNXLcw5x4vvTNfnCkckL1YJYUUrTo2MSpPFTisMXAeq1ht8e1rWyIWso0v0vLOwt1eOd23IsY1XoFiqKI4UdtdQ0zQ6CsGobZs6XO6B2QvD1RpwM3fClR8pOB93jrr9SOB(LmzoAz2bwbP6uM8LRMRd)OxCc7P)Q9m7BMnNDDHFYnMfbi8M)2oWGfiPefdbKar9CAXBeUIuVbmP59Vo6ZVX)jrStKG7X0ii0i2pSc2d0wVKPN(L)HpZU31)eRTaec4J)43GgJoaY0iQhwiFcdAS1VprhKXIcwc(QcuUclN(fe(q51xSDCbBCAT(jytIkXpEBYCbcixVdikbz8wOOHqM1Htc8KxX4)ylxPolAeD1j)Es3U1gRbG6YG88bdYeC0YMKSeqB08KneEcTnzjiI0qLneM16)XsqfT3i)fgUnYlKeSjZB0lh8vPlW2Ds70hgolkxKAFXG7qWd8wgfM1N0Laz1dAjeR9XXucOOF4mneU9Go1xu4))px9IGPgNBbXpZ(ub8MXA(ab8h)bLLIrxPixoJO5LJu8bbyKQpgatgn(kvQTLKk6thzsk5VZ6MVB8y73st9tEx1JBUQk(u0LNjteMfKIWLZeYrmsFvzFjMlfsKxKIK48VFO58VGsrd(C5nuXxLxz0K2fCfXMn6nhkeWxU2OsGNQ0PYqVXgAYRoC9tswjWJrpOzMdu5cPJayKHmGax3o7QYeKmdUrUj1sOd7cxpl29fc(9p)(1efFwIYdkWPJCm)LSuBWOXJvhoAjq1sROdzabUUqOpdXbki2pgm(cTXNHg(9p)(1efFwIYdkWlb7n9QDijAUFbUbG9mIkQbqZw1LoSNsYeeNxudHDpz6Ga69MIYfoZxzW)cNFq5mFOxT0oOa3aWEgX91aOdjtUxf)iGEVj(DHZ8vg8VW5huoZp0RwTguGRfSDl4tdP5UbCTGTBScdP5UbCTGTBScdP5UbCAWMRk399(zaZT4A8OI7kmMbf8AbmY1psfhUT0DxbVUvWEZAkLes)4l4c1Jt9Of(HFCcBrjFiYeCT7NLePHE3T0qwLFYbAh19IFYehoi3dNPuciVhg(kgzT3D7rzAU(dBjKfViAYYNi3rnzOsiB1d84HaY4Qt8Bkz7eAjQY5zOsPCs3dcwuLBAqw(7TJaDgwiYmnYXIqcjkUKugAd)vhoUThJKJuDjpKKKErPPhCtQe(9Kt((TaLdkWnaSNrHb63cVmOa3aWEgPdKQSlaH4MK9fKbJifE2xcW1nrQbf4ga2ZqEDitn(LIg0sy)6MZm0W)cNFq5muffYwHfwBAlSVqGRBU(guGBaypd)QdzI7VusJwc7x3CMHg(x48dkNXGS83cRwdkW1c2UfASH0C3aUwW2nwHH0C3aUwW2nwHH0C3aony7zDXxRL541n1JF7N59AM30hjiRt5UldIej9hPjSibAfTPfzCqKD2EchOm31EBCpg0YC2)cCHiYEX8m97MKKtKIqT(dBjpThUc8u7F78QdWlku7jjlL4G9kmRkR9Ee2VgMHbKr0stp968Gah9CLyiWYUJSlTiRWBOyq(XTf6UXl53kso7okAVm4LFof8jQnIudwswTc)dyUmS)Xbe2weog6LySTi8r0paNQaH8wp1EKEoHWtibkztlOpO4HC)mwesG9dWjebxfTFVlR1BPiik0X8fhr2eY99pIOAus9H2RnLZ8Eb4e(V6hGtOl0paNWAFVa85eg161sTpFiLAMpmsnOHtFi2duxw6EUbuxl5VfFCElPW6j)v4XQJPUeO6(S)JGidEfZroXhiqC0spy1X5xMNbLSWgp2qGAa)qgrg8kMJCtzHAgS6a4h61mLiCdB)DSfgqDKqIuEiMd8e)THELwN4FnyEghheJ0qubB6y1uEl09qIQJrn146z0WKXDAp4nqY9CTxCr2RJYE0LoTfmU2yLqjcvZ4qhI5a3igNQrAiQmtBIEC9mAuQ0QKHPtd8C9qDr2RJYE0fYPfmU2yTRXULh6vkIn2EgPiUbel5zLvjQv3tPbg864ei91njwcwNF7BDEZqRhiHWgTPsQpCyJgtkNos1u97(UYFs4nlE6NMv278uSyBkcWarfMMaOYqogN927CIHMr038HszgRz9UTSMGS0ESEnkdUBK9o81Ym6vZz9o5p0W3eiRxLRtoALXOEtA2TqrgzY2VM0uJaZvLnH)27CIHMr038HkHMgLdOum9mUEaKq9SodRkO1UPSo0W3eiZMWzFnQG1QWTP7iy1YJXuk3u4tL4tfG2p4Xamlwz)SzqXchkwTfk6xGmi62Eh(Maz9lqw)FS3vBVnoUr4FlbhoV2jzDKKTZLRWwaB3ET4o0R9qZ1pv0Zwrwown(TkzFEtHH)T3HuVrsndfLT82D7TFybYkjoC4WzE4mdhsFgkaMt)ARa0mtDNLAuPL4UI0zvnq(4yAhoCfbUeGYstT26qe(AK2L9Uox32U7GBimlH3I024xx5J)M5HppF8V6TyxaJU3iXwmj7BvMV6812wwD60Xv4lX8Tgr(snaSRCaytoaS1maSvgaosdGmnPpX1eU7txnH7mstO8a4tgnH0bGa6BPDUoTf1d8HIkgcesDbF8MATbXxIlGdQFQHQhN9rRsBpdk(r8NMLl1pcqn9pqlzTTbkA7po0NO6CoRYFJ68DEkAAK)WDv7F0UAElQMNIeZ2F5N)RMNUnMf0LJ(K6(jhDJVyc8ftGZIUnGk6LM(h)HVNR9ZiR99GYn)xS3JtwegVLPx)lpUjAn7hw1F5XV6Rooz(2TBI)D3D3ZHBNV7jWp7L3fhUC3co19J8MTL9)9VJv7THBJVB78G9Er7HVoC1DVJt7FITZYG(0FM1d3XpwdVSIjChNiQ7YiWXFG1B)9njJNPG12XjmQCCYJHlFpin(rVi)5SY2f(NLZa(pX7p9GLNVTfBqLmmI7MxxJ3m6UePbRiGXFV6Xi728xYpS(JCWBwwma3UYd(iLW3ULhjWOcFVfdTOi9Nvx3rkFlrMsRdh6GYHoeCy1fzHY32aCyriA3UEZO4GTHZkjpP7PRTlIPRCLpv6TyL)W1owjD44GfXI9kAjWCR)6vaqj8xJA65vLVsAKO8oSXrDe6ovk01n9kkwlx5kLEBne6e1DeIqVPuvv(kcHo54OocDX0gOk2DeLg2ukznG5MZ5WenNnpl1kQDVTy3B1DGaduJ97VvHeRr3DqdPRXBgwZnHEUYs6nASvXe)Lrw2qBWAtPxUj1RfJnmoNm6sMq3tjFUNxI9r2sUglLUkz0Lm1(NxM9r2tPglNUkP0vo3(MOEn1BP3ZbJVaAzLFtMQHm36osEWi49mWTqGdtHvqdc(pbjUKx8k5bsm)N12vRcx9CkZNY6SgaHshSkyzyq8iB9KXBke9DYLMHoY4AlYKkKaGCyoSxIt6jb8jieXqRsV4ogoO10aUUtsA5yPLEp)67nERN)ldTl(jIv5y9Nsa3b0C6M1BsiwSmJ2wdd5MpTkmozieQa0DA1whN7oQswFOJvl5GGt)GwQZPhoK2vshP)DB0k7CfAhXh0)TBa9sX4xt6za4BgpIrZMLChPrDzdieyFF0UvH(J3SEFqK8SrQiq(UvOq2PCNluWrceCyplAgiEtayJfTr1MV4hWybHAXVzXcpS1v4I)dhe4HUtdMf6hUfMv7WwDiHmixVaTARm96K3Pix4bD4DsWWEhoWMRYpHYj04WHeC3DtNc8f)G5ZyRcSPctGkMb7lGNwwe6TIZ6JxcANgJDY7UG44Gv(bzUUN8RI9)ExqWQ8EMUFd2eofKrGzimSd2MflDVBOLU3Kj5XUZfUoxUinI6K3i1RrHm7Zs3)bTqK7GaeqEFV3IfhN8U008WtcJ4aeqpwmo5)oMLdOcbC6YeX3YoyP(Bbrz4SCJd5dDA1eeLyxrrnGT)BE(HElKyvViFVvWANqmDqRyeq0KdaV4kMoInjz6D2UOxzFEBUqQ4z5ExCtp3rsAZPw1TquXbdGClvLJP)Hd5OeQhG)m087zgJCqowYNEgcWCrkDBP80mGLr0mDIjiFDHYuQ4PgrjL1Bh50krh2BftB2371UBd9Fb05GX)tRJJBjdiRH2sZhbrXbrmYimFK)SpNMpWy6tB(aNsnZ8bgTfNp4j5oE8)A30NxMAtXBy66)z(pZwApxilSFLPW9I7GzgdKGq2LLivWID80WS1gujnDdKwaWdaTz7HWIXmagU2J9dFcRLy)qD1gyT4CN1TFabWCZoyLqMeRe1bHcdZmZvb3rsEXu8yy8ls3zHrbCt9cJ48h9zKnmgpx3jnne6CNljjTeGQ3ZCxzGvpFjU8Cm40FBcdA0oDqIpdpc(xW2GO3Nk6LwgEZA2FHPpz36CNf58kwUEaaOEwUJiFFkvsN(mwpONvDNWZBrPGuAP(yH2qmfZctGVVxXbhNm074K5rbZg9MSnDB)(9D3VE)C21ydFN32eSyXiBlR7TUJBH(2WvZ2fd91BC)j2))4KVp9bdVZZ94K9ZHGvmNY9)whR7Vlzc6T53mrU)P0)kHMHXhNSBZTqi9WFSpG5Cj7VmTpC(Mb3)TF7Dc7NT77Y)7KEGTR8j79NPe9(EdarctV4TY6fVX9pap84KFw6PPdKzM3bgY1MsoJe0Gj4XjRwV94KeBkWGujvkHR(11Va2FFaw9DfSYiZ6ilixqByCM2bHTkcqClme7HJCCkY4GI9BwejQBMAEkKlTN0LStQW8HTU4v6jMX272p0HEKCf1qrdQen103imzFvqK3yB5M)nyZ9JLN2ZxYO8Ar90c1Ystd(kvYUKPU)5mVbYZCaYDXvlTPZpFnOczkovkPkJJU2tktCL0CeFPIa)w2U(TgKNp7pnjs1ePf(fmMOsWzXWodKD4fCf27zwuXZds84nzwjP4j66TmggoXRJEA8MGiFO3DTuYbfsaX4rNZkbk2VLFqy)geTFPXtpJ7btc)Ve5nCauudx1FmyAFCAe32iIFcYgJOmxSir86p25khbBH19rwkPhlFKO4fcg8kFqo4ULzDoVgXX782eDEA8MQVLNLAb7Oz80oYQwaEaOajB7)ki0Y6IRT6oqg3JKljeoeSHe60Uv4jHBwy880SLOo1NTYlY1xxRRQaP1B6RP8f2LFhiIQkxPzZFMGOFJb4dj)ImQtlnF8w7CpwfDjtdjpwO39x)U8UOlmjZI)npL1jFzEAteEH)RGitCwoTTCTTX89aii62enTunVe2RQnXHsPoDqiFykAv3DwsLDlsKnhvsip(L2fffSPH5FRAwZv7JS3xzpCQYs)5SXltno0NT3RRxS4jwIrIxSEpYuuPPxekRBleX3XotvqmP31UfLoNQyQ69nerjcCrkDSPEruYaAxZ2hTODmnZXjN(Jm05mRR1F3Xj)EMoRexNG3FoMA5uqrdMIvnv5TifhYwA57zMIbO21Agk3R16JH1L6JTRpOBbxE0yY)YXMbAi)Zjm6EoMV1Tj8i8QC9DqfqS4hef(sM2uI(gvIkT29LuGYFO34zbSFCVaOLyiqZ40GNOfuiVnTWcSOKHMA(whuUAtC6D0Nyw1eJrtT50RBziWrnhBdh5CcsmruThz(lltdUl0NfQwgf4Lf7kEi3KoFtyxv4VJuLmKf0pPBXswwv(1pC4aeY90Xb)kpLktNg3n4dSnFUL6JlsoJn17Cz5eOchFyBwXIGo4IltvZRLne5Sjc9XL5No9QSCuQCcsfOuNPqFCgToohIHHEA2)z9UXUnI13nGKhXZpaGxRKKvkS1y5RZxQ)rscNc79xwV6Tp6T6nSGiX28OU(tzrPHeQiACz6klUHpGvdCLt0jvQ2Suzk5kER(8dm1FTJz8KJUCdBk)w0by8QA9YvU9R3T9POaVxWuXlVv8UyEYNsCsV8ZkSZHdA1gV9ZGLJMZuQY91t4ScM0OzrRb)RMbRjej3a2ltYirzY1PtXIFsNNV8(r6OOl81LstCHZWL26HC1HYh7US1TQs0CDVoLMyliZ4fHlFcpLf0UKkwmgzjYr8zjEUjy(i8YS9rV8(EoaVKtRWdkuDzBhoCXxvcWG71eoQX4KizvmsruDvS1enAjwPSNWEtJ)jU9Tkg9YFshmUu(tQRJNUJ63QnLFq9bgHWTkjHSB)oLjs1(FjiksDWuumr5awvfYzjeqB9lsEpMq1Ofnmy(2Da1Cj5UEjivOsJDpufHCmw2uEdcsMFeT1NdxeivniQT0cOwfEQ0tnAF(UyGUOtfclxAcQbFJZe2xlrkvj(SBwyG0qBWl)hbWmyW0)j)KmltGJtCpoXo5odBl7clygR2FzNrB2zdNvagrbWCelJnqtH(57)X3FCsEPkdFiBlFsAp77cknoyQj1XOIW0x1YgezLL(P91La7((Zc72epTegaFbwVPH1tfSIWK)2cd01EWx3UTZ1L5Yo3u84GNaOgoVk(uzpy7CXGtBsEKsdOHqNZO2PGq)(umtc)plkUaAytkdjKdtlAnhI6InbivTZUMkUM0aQCWVAIqLo61cp8)OW10AnAAKU4EpbWhUSiC1SfH8omzJay35aFga(m4YHzWRJyMtop(Au4mWhNFEoZTLehyw696XjpfKDBkXVNLeZfA5jAedATO(LdpMDGW3woy4kwMJhcR(6KGm(wjWfCqL64ege0V8tyjK6caSGXHMKBSZeWOoSZzL6ldGb(Fy6V()cGLlgSshuTHQxThZ2PM4hyzs7SbpiWnsDfrganl6oiGVIJmFA9HVkiykdgDEqKyOECYCJH7vOMCBJcFG0p1zJjsjiYbMfHWY7ExM3j62Z5tINUQwmLj7vekFYKYTQ9jIEOdvjeXxARXzW6wGtvCTjyYSkIiP0kP)XK6HSGCcfj5nnqrt33II04kHei008xHPiv4cu1jdfnLvXXqUs1RLR9NdhId2ogcBBxC3T737mU)g)kl7tVTJx69HX8j14m6IDY2R9OGv(maQM3MeHB6AWZd8wSDE3n(BH49gOKmKbMjrQlNuAIUI7vJEexAf1U2l7yqX0iZQy1rIw7qkEnZod(E2sm)mx6ly3j1)8YGXKfvK9G45igJyKhedhG0JNHbisThrUcp2A1zU6HxfDO1lx(9KrQLqciJpWF72WhQSSNIybkag5(GvQgXjwK2MBTsbfSpKFd)WuVaNLviyAAyQKnY057z8KQUXBzRJC5pwLWNGYEIXL8S)ueE2iOkZD8tfhtJCbReBn8EWPG0yGgAH4gzvBVbyhOBntk6eofEBI8(osBYTGtqc1DjHZ42Dmrm3gRaoQnqEvxftuWWKlaGX71X1w9LKABmWWkl8ZKdxMrsvT0Q)5n2sx66NJsUGzOw0AB67zPZaIUmCBWYKthYSxJ8wW6n(X1dmRxgvW3GKAjdFa0cZ(UIqMKJPKvIeYpX1XgnRg9ZkZcK5F0JZQUZ)AU(QYHXeafdxg4ANLjoczX01JjUSeHafIFP8jHmbSpc(o2AbR8aqZNHr8YW44QqvZxXIS155Sj1qWp6vyXs)XWZ2gTlDeysxG2qvQdJ7fHpZxFBvWh2XUNfz342pZxhBAy2FAuhAkTY5bd1ojMC4qvkAB2Q6FaKNzEBzBvn3eVy92SBXjBPO1sFyX9WALclD8cczZogZxB19B61Q891y2LOiduk9zIxcMczXis8oUm7d6GDTAw0RUJKSE5z8TEIlhuXLZLrC5yU4Yr8gOvJ4YUAXLtdkUSLH8lPEjWZSJEbhMZQsxkWAuhbPdXfZ5jQtDcxYaAszkfTOifD6xfCKtPr5o04yDw5OfA)PCflyahRBRSeyA1UmV9ux8moGYd(Dse2M7mOEkZo4kZi3aWNGYStDvMpnl(MC68lkZFoQmZ(8XZ9ss3t7t4oiwNEhNNRUHLrFXBOTz9OwYwXnrvvRk7ABPBpW04ZoDBO01icyGKoubEGDnyNkiPNBq1PyL5Js2e5jtuQyVl07moJk0jnrxmNgFIUuZQzQeuo5LKjTxTU5LINJiopvBufEPgXaxCfZND5cJp3yP0f1o)X9B1gBNROpD7QdkZ20NtvouvNv7DDJFBaRKFbC9ymSZFlMFbb5Wfi3cuMzLZAxvNXkDPxOz7fttnqZ1XgOv(rpVcv5OCf5uqBq)KbHP33bKC9QtSw3Bksn5uGOnUdyLXB99QSE3bEvYxLAd4ptT9OG(2WSY(hXpCbgOQID7uMpUPh5mIryJgQ)qRo2rTQ10kLKZPsvwwvK(jT5hImIqrNR)VBGpNLrdsZzHU7IENZcD7NELZYObQCwyMCKiYzze5MZIqJujbhpMrhCXrhpgCmEmekThHgyrcM2B0XcC00EKAApqkLMnoGeJUWSusYBeaXZW)H5zGabQ9ZqSEuKG3oOPgEVR7S1sdWQpgj51KOQ8CqZWlQzCbNyPLKr(ffxWbd)2J2zq3E0XbcghG)]] )